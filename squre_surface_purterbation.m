clc;clear all;close all;
% Read data from the CSV file
data1 = readmatrix('surf_perturbation_new.csv'); 

% Extract columns
radius = data1(:,1);      % First column: Radius values
phi = data1(:,2);         % Second column: phi values
surf_nu = data1(:,5);     % fifth column: Surface density perturbation values

% Find unique radius values
unique_radii = unique(radius);

% Initialize storage for integrated intensity
sqrt_surf_dens = zeros(size(unique_radii));
integrated_surf_dens = zeros(size(unique_radii));

% Loop over each unique radius
for i = 1:length(unique_radii)
    % Find indices where radius matches the current unique radius
    idx = (radius == unique_radii(i));
    
    % Extract corresponding theta and surface density values
    phi_subset = phi(idx);
    surf_dens_subset = surf_nu(idx);
    
    % Sort by theta
    [phi_sorted, sort_idx] = sort(phi_subset);
    surf_dens_sorted = surf_dens_subset(sort_idx);
    
    % Use quadratic interpolation (spline method gives smooth curve)
    surf_dens_function = @(t) interp1(phi_sorted, (surf_dens_sorted).^2, t, 'spline', 'extrap');
    
    % Integrate the interpolated function
    integrated_surf_dens(i) = (1/(2*pi))*integral(surf_dens_function, min(phi_sorted), max(phi_sorted));
    sqrt_surf_dens(i) =sqrt(integrated_surf_dens(i));
end

% Display the results in a table
disp('Integrated squre of surf dens over theta for each radius:');
result_table = table(unique_radii, sqrt_surf_dens);
disp(result_table);

% Save the results to a CSV file
writetable(result_table, 'integrated_sqr_surf_dens_rd.csv');

% Plot the results
figure;
plot(unique_radii, sqrt_surf_dens, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Radius');
ylabel('sqrt surf dens');
title('Radius vs sqrt surf dens');
grid on;