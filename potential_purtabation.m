clc; clear all;

% Ask user to input number of phi values (repetitions)
num_phi = input('Enter the number of phi values per radius level (e.g., 360): ');

% Read data from CSV files
data1 = readmatrix('gravitational_potential_r_phi_rd.csv');
data2 = readmatrix('gravitational_potential_r_rd.csv');

% Extract necessary columns
r = data1(:,1);
phi = data1(:,2);
poten_r_phi = data1(:,3);

% Extract potential_r values
poten_r = data2(:,2);

% Repeat each poten_r value 'num_phi' times
repeated_poten_r = repelem(poten_r, num_phi);

% Check dimension match
if length(poten_r_phi) ~= length(repeated_poten_r)
    error('Mismatch: The length of poten_r_phi and repeated_poten_r must be equal. Check your num_phi input.');
end

% Subtract repeated_poten_r from poten_r_phi
difference = poten_r_phi - repeated_poten_r;

% Combine all into one matrix: r, phi, poten_r_phi, repeated_poten_r, difference
final_data = [r, phi, poten_r_phi, repeated_poten_r, difference];

% Convert result to a table 
T = array2table(final_data, 'VariableNames', {'r', 'phi', 'poten_r_phi', 'poten_r', 'poten_perturb'});

% Write the table to a CSV file
filename = 'poten_perturbation_new.csv';
writetable(T, filename);

disp(['Potential perturbation data saved to "' filename '" with column headers.']);


