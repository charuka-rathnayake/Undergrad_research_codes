clc;clear all;close all;
% Load the data
data = readmatrix('poten_perturbation_new.csv');

r_all = data(:,1);
phi_all = data(:,2);
nu1_all = data(:,5);

% Get unique radius values
r_unique = unique(r_all);

% Initialize result array
result = [];

% Loop over each radius
for i = 1:length(r_unique)
    r_val = r_unique(i);
    
    % Extract data for this radius
    idx = (r_all == r_val);
    phi_vals = phi_all(idx);
    nu1_vals = nu1_all(idx);
    
    % Ensure phi is sorted
    [phi_sorted, sort_idx] = sort(phi_vals);
    nu1_sorted = nu1_vals(sort_idx);
    
    % Interpolation using spline
    pp = spline(phi_sorted, nu1_sorted);  
    
    % Differentiate the spline
    pp_derivative = fnder(pp);  
    
    % Evaluate derivative at original phi points
    dnu1_dphi = ppval(pp_derivative, phi_sorted);
    
    % Collect results
    r_column = r_val * ones(size(phi_sorted));
    result = [result; r_column, phi_sorted, dnu1_dphi];
end

% Convert result to a table 
T = array2table(result, 'VariableNames', {'r', 'phi', 'dNu1_dphi'});

% Write the table to a CSV file
filename = 'dNu1_dphi_interpolated_rd.csv';
writetable(T, filename);

disp(['dNu1_dphi data saved to "' filename '" with column headers.']);

