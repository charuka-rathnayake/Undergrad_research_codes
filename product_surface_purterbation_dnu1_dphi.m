clc;clear al1;close all;
% Read data from the CSV file
data1 = readmatrix('surf_perturbation_new.csv');
data2 = readmatrix('dNu1_dphi_interpolated_rd.csv');

% Extract columns
radius = data1(:,1);      % First column: Radius values
phi = data1(:,2);         % Second column: Theta values
surf_dens = data1(:,5);   % fifth column: Surface density values
dnu1_dphi = data2(:,3); 

% Find unique radius values
unique_radii = unique(radius);

% Initialize storage for integrated intensity
integrated_surf_dnu1_dphi = zeros(size(unique_radii));

% Loop over each unique radius
for i = 1:length(unique_radii)
    % Find indices where radius matches the current unique radius
    idx = (radius == unique_radii(i));
    
    % Extract corresponding theta and surface density values
    theta_subset = phi(idx);
    surf_dens_subset = surf_dens(idx);
    dnu1_dphi_subset = dnu1_dphi(idx);
    
    % Sort by theta
    [phi_sorted, sort_idx] = sort(theta_subset);
    surf_dens_sorted = surf_dens_subset(sort_idx);
    dnu1_dphi_sorted = dnu1_dphi_subset(sort_idx);
    
    product = (surf_dens_sorted.*dnu1_dphi_sorted); 
    
    % Use quadratic interpolation (spline method gives smooth curve)
    surf_dnu1_dphi_function = @(t) interp1(phi_sorted, product, t, 'spline', 'extrap');
    
    % Integrate the interpolated function
    integrated_surf_dnu1_dphi(i) = integral(surf_dnu1_dphi_function, min(phi_sorted), max(phi_sorted));
end

% Display the results in a table
disp('Integrated product of surface density purterbation and dnu1/dphi over phi for each radius:');
result_table = table(unique_radii, integrated_surf_dnu1_dphi);
disp(result_table);

% Save the results to a CSV file
writetable(result_table, 'integrated_surf_purterb_dnu1_dphi_rd.csv');

% Plot the results
figure;
plot(unique_radii, integrated_surf_dnu1_dphi, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Radius');
ylabel('Integrated product of surface density purterbation and dnu1/dphi');
title('Radius vs Integrated product of surface density purterbation and dnu1/dph');
grid on;
