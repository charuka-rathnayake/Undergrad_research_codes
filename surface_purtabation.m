clc; clear all;

% Ask user to input number of phi values (repetitions)
num_phi = input('Enter the number of phi values per radius level (e.g., 360): ');

% Read data from CSV files
data1 = readmatrix('intensity_r_phi_5_2.csv');
data2 = readmatrix('integrated_surf_dens_rd.csv');

% Extract necessary columns
r = data1(:,1);
phi = data1(:,2);
surf_dens = data1(:,5);

% Extract integrated surface density
integrated_surf_dens = data2(:,2);

% Repeat each integrated_surf_dens value 'num_phi' times
repeated_integrated_surf_dens = repelem(integrated_surf_dens, num_phi);

% Check dimension match
if length(surf_dens) ~= length(repeated_integrated_surf_dens)
    error('Mismatch: The length of surf_dens and repeated_integrated_surf_dens must be equal. Check your num_phi input.');
end

% Subtract repeated integrated surface density from surf_dens
difference = surf_dens - repeated_integrated_surf_dens;

% Combine all into one matrix: r, phi, surf_dens, repeated integrated_surf_dens, difference
final_data = [r, phi, surf_dens, repeated_integrated_surf_dens, difference];

% Convert result to a table 
T = array2table(final_data, 'VariableNames', {'r', 'phi', 'surf_dens_r_phi', 'surf_dens_r', 'surf_perturb'});

% Write the table to a CSV file
filename = 'surf_perturbation_new.csv';
writetable(T, filename);

disp(['surface density perturbation data saved to "' filename '" with column headers.']);


