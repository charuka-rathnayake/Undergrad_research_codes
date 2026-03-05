clc;clear all;close all;
% Read data from the CSV file
data2 = readmatrix('poten_perturbation_new.csv');

% Extract columns
radius = data2(:,1);      % First column: Radius values
phi = data2(:,2);         % Second column: phi values
poten = data2(:,5);       % fifth column: potential perturbation values

% Find unique radius values
unique_radii = unique(radius);

% Initialize storage for squreroot of integrated squre of potential perturbation
sqrt_poten = zeros(size(unique_radii));
integrated_poten = zeros(size(unique_radii));

% Loop over each unique radius
for i = 1:length(unique_radii)
    % Find indices where radius matches the current unique radius
    idx = (radius == unique_radii(i));
    
    % Extract corresponding theta and potential values
    phi_subset = phi(idx);
    poten_subset = poten(idx);
    
    % Sort by theta
    [phi_sorted, sort_idx] = sort(phi_subset);
    poten_sorted = poten_subset(sort_idx);
    
    % Use quadratic interpolation (spline method gives smooth curve)
    poten_function = @(t) interp1(phi_sorted, (poten_sorted).^2, t, 'spline', 'extrap');
    
    % Integrate the interpolated function
    integrated_poten(i) =(1/(2*pi))*integral(poten_function, min(phi_sorted), max(phi_sorted));
    sqrt_poten(i) =sqrt(integrated_poten(i));
end

% Display the results in a table
disp('Integrated squre of potential over theta for each radius:');
result_table = table(unique_radii, sqrt_poten);
disp(result_table);

% Save the results to a CSV file
writetable(result_table, 'integrated_sqr_poten_rd.csv');

% Plot the results
figure;
plot(unique_radii, sqrt_poten, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('Radius');
ylabel('squre of  potential');
title('Radius vs squre of  potential');
grid on;