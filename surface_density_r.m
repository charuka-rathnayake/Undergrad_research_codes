clc;clear all;close all;
 
% Read data from the CSV file
data = readmatrix('intensity_r_phi_5_2.csv'); 

% Extract columns
radius = data(:,1);      % First column: Radius values
phi = data(:,2);         % Second column: Theta values
surf_dens = data(:,5);   % fifth column: Surface density values

% Find unique radius values
unique_radii = unique(radius);

% Initialize storage for integrated surface density
integrated_surf_dens = zeros(size(unique_radii));

% Loop over each unique radius
for i = 1:length(unique_radii)
    % Find indices where radius matches the current unique radius
    idx = (radius == unique_radii(i));
    
    % Extract corresponding theta and surface density values
    phi_subset = phi(idx);
    surf_dens_subset = surf_dens(idx);
    
    % Sort by theta
    [phi_sorted, sort_idx] = sort(phi_subset);
    surf_dens_sorted = surf_dens_subset(sort_idx);
    
    % Use quadratic interpolation (spline method gives smooth curve)
    surf_dens_function = @(t) interp1(phi_sorted, surf_dens_sorted, t, 'spline', 'extrap');
    
    % Integrate the interpolated function
    integrated_surf_dens(i) = (1/(2*pi))*integral(surf_dens_function, min(phi_sorted), max(phi_sorted));
end

% Display the results in a table
disp('Integrated intensity over theta for each radius:');
result_table = table(unique_radii, integrated_surf_dens);
disp(result_table);

% Save the results to a CSV file
writetable(result_table, 'integrated_surf_dens_rd.csv');

% Plot the results
figure;
plot(unique_radii, integrated_surf_dens, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Radius(kpc)');
ylabel('Integrated surface density over phi');
title('Radius vs Integrated surface density');
grid on;
