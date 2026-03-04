clc;clear all;close all;
% Constants
G = 1; % gravitational constant 

% Load data from CSV file
data = readmatrix('integrated_surf_dens_rd.csv');  
rp = data(:, 1);         % r' values
Sigma_rp = data(:, 2);   % Surface density 

% Define the r values where we want to compute the potential
r_eval = data(:, 1); 

% Preallocate output array
potential_r = zeros(size(r_eval));

% Compute potential at each r
for i = 1:length(r_eval)
    r = r_eval(i);
    
    % Compute denominator
     denom = sqrt(r^2 + rp.^2 - 2*r*rp);

    % Identify valid (non-zero) denominator entries
     valid_idx = denom > 1e-12;  % Avoid singularities

    % Skip if not enough valid points for spline
     if nnz(valid_idx) < 2
        potential_r(i) = 0;
        continue;
     end
   % Filter valid values
    rp_valid = rp(valid_idx);
    Sigma_valid = Sigma_rp(valid_idx);
    denom_valid = denom(valid_idx);

  % Compute integrand for valid data
    integrand = (Sigma_valid .* rp_valid) ./ denom_valid;

  % Interpolate and integrate
    integrand_function = @(t) interp1(rp_valid, integrand, t, 'spline', 'extrap');
    potential_r(i) = -G * integral(integrand_function, min(rp_valid), max(rp_valid));

end

% Combine r and nu into a result matrix
result = [r_eval(:), potential_r(:)];  % Ensure both are column vectors

% Convert result to a table 
T = array2table(result, 'VariableNames', {'r', 'potential_r'});

% Write the table to a CSV file
filename = 'gravitational_potential_r_rd.csv';
writetable(T, filename);

disp(['Potential data saved to "' filename '" with column headers.']);

%Plot the result
figure;
plot(r_eval, potential_r, 'LineWidth', 2);
xlabel('Radius r (kpc)');
ylabel('Potential');
title('Gravitational Potential of Axisymmetric Disk');
grid on;

