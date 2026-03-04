% Clear environment
clc; clear all; close all;

% Gravitational constant
G = 1;  

% extract CSV data
data = readmatrix('intensity_r_phi_5_2.csv');
r = data(:,1);         % Column 1: r values
phi = data(:,2);       % Column 2: phi values
surf_dens = data(:,5); % Column 5: surface density values

r_prime = data(:,1);   % Column 1: r' values
phi_prime = data(:,2); % Column 2: phi' values

% Get unique values
unique_r = unique(r);
unique_phi = unique(phi);
unique_r_prime = unique(r_prime);
unique_phi_prime = unique(phi_prime);

 % Preallocate output 
 n_r = length(unique_r);
 n_phi = length(unique_phi);
 potential_r_phi = zeros(n_r, n_phi);

% Loop over each evaluation point (r, phi)
for i = 1:n_r
    radius = unique_r(i);
    
    for k = 1:n_phi
        phii = unique_phi(k);
        
        % Preallocate for inner integrals at each r_prime
        inner_integrals = zeros(length(unique_r_prime), 1);
        
        % Calculate inner integral for each r_prime
        for l = 1:length(unique_r_prime)
            radius_prime = unique_r_prime(l);
            
            % Get all data points for this r_prime
            idx = (r_prime == radius_prime);
            phi_prime_subset = phi_prime(idx);
            surf_dens_subset = surf_dens(idx);
            
            % Sort by phi_prime
            [phi_prime_sorted, sortIdx] = sort(phi_prime_subset);
            surf_dens_sorted = surf_dens_subset(sortIdx);
            
           % Calculate denominator
            denom = sqrt(radius^2 + radius_prime^2 - 2*radius*radius_prime.*cos(phii - phi_prime_sorted));

           % Mask for valid (non-zero) denominators
            valid_idx = denom > 1e-12;  % tollerence

           % Skip if no valid data points
            if nnz(valid_idx) < 2  % need at least 2 points for spline interpolation
               inner_integrals(l) = 0;
            continue;
            end

          % Filter valid values
            phi_valid = phi_prime_sorted(valid_idx);
            surf_valid = surf_dens_sorted(valid_idx);
            denom_valid = denom(valid_idx);

         % Calculate integrand only for valid data
           integrand = (surf_valid * radius_prime) ./ denom_valid;

         % Interpolate and integrate
         inner_integrand_function = @(t) interp1(phi_valid, integrand, t, 'spline', 'extrap');
         inner_integrals(l) = integral(inner_integrand_function, min(phi_valid), max(phi_valid));

         end
        
        % Create outer integrand function and compute outer integral
        outer_integrand_function = @(t) interp1(unique_r_prime, inner_integrals, t, 'spline', 'extrap');
        potential_r_phi(i,k) = -G * integral(outer_integrand_function, min(unique_r_prime), max(unique_r_prime));
    end
end


% Combine into output matrix
result = zeros(n_r * n_phi, 3);
idx = 1;
for i = 1:n_r
    for k = 1:n_phi
        result(idx, :) = [unique_r(i), unique_phi(k), potential_r_phi(i,k)];
        idx = idx + 1;
    end
end


% Convert result to a table 
T = array2table(result, 'VariableNames', {'r', 'phi', 'potential'});

% Write the table to a CSV file
filename = 'gravitational_potential_r_phi_rd.csv';
writetable(T, filename);

disp(['Potential data saved to "' filename '" with column headers.']);


% Create meshgrid for r and phi
[R, PHI] = meshgrid(unique_r, unique_phi);

Z = potential_r_phi';  

% Convert polar coordinates (R, PHI) to Cartesian for 3D visualization
X = R .* cos(PHI);
Y = R .* sin(PHI);

% 3D surface plot
figure;
surf(X, Y, Z, 'EdgeColor', 'none');
xlabel('X (kpc)');
ylabel('Y (kpc)');
zlabel('Potential \nu(r,\phi)');
title('3D Gravitational Potential Distribution');
colorbar;
colormap jet;
axis tight;
view(45, 30); % adjust angle for better 3D visualization

