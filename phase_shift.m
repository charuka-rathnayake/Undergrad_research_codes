clc; clear all; close all;

% User input
m = input('number of spiral arms: ');

% Read data
data1 = readmatrix('integrated_sqr_surf_dens_rd.csv');
data2 = readmatrix('integrated_sqr_poten_rd.csv');
data3 = readmatrix('integrated_surf_purterb_dnu1_dphi_rd.csv');

% Extract columns
radius = data1(:,1); 
int_sqr_surf_dens = data1(:,2);
int_sqr_poten = data2(:,2);
int_surf_purterb_dnu1_dphi = data3(:,2);

% Sort data by radius
[r_sorted, sort_idx] = sort(radius);
int_sqr_surf_dens_sorted = int_sqr_surf_dens(sort_idx);
int_sqr_poten_sorted = int_sqr_poten(sort_idx);
int_surf_purterb_dnu1_dphi_sorted = int_surf_purterb_dnu1_dphi(sort_idx);

% Compute the intermediate function
func_1 = (1/m) * (int_surf_purterb_dnu1_dphi_sorted ./ ...
                 (int_sqr_surf_dens_sorted .* int_sqr_poten_sorted));
func_1_sorted = func_1(sort_idx);

% Interpolation function
func_2 = @(t) interp1(r_sorted, func_1_sorted, t, 'spline', 'extrap');

% Evaluate func_2 at each radius
func_vals = arrayfun(func_2, r_sorted);

% Filter values where func_2 is between -1 and 1
valid_idx = find(func_vals >= -1 & func_vals <= 1);
r_filtered = r_sorted(valid_idx);
func_filtered = func_vals(valid_idx);

% Compute phase shift only for valid values
phase_shift = (1/m) * asind(func_filtered);

% Display result
disp('Filtered phase shift results (only valid domain):');
result_table = table(r_filtered, phase_shift);
disp(result_table);

% Save to CSV
writetable(result_table, 'phase_shift_filtered.csv');


phase_shift_func = @(t) interp1(r_filtered,phase_shift, t, 'spline', 'extrap');
r_fill_set = linspace(min(r_filtered),max(r_filtered),200);
phase_shift_set = phase_shift_func(r_fill_set);

%find positive to negative zero crossings
crossing_indices =[];
for i=1:length(phase_shift_set)-1
    if phase_shift_set(i)>=0 && phase_shift_set(i+1)<0
        x1=r_fill_set(i);
        x2=r_fill_set(i+1);
        y1=phase_shift_set(i);
        y2=phase_shift_set(i+1);
        %solve for x where y=0 using linear interpolation
        crossing_x = x1-(y1*(x2-x1)/(y2-y1));
        crossing_indices = [crossing_indices; crossing_x];
    end
end
fprintf('Positive-to-negative zero crossings at r values:\n');
disp(crossing_indices);
%plot
figure;
plot(r_fill_set, phase_shift_set, 'b-o', 'LineWidth', 2, 'MarkerSize', 1);
hold on;
plot(crossing_indices, zeros(size(crossing_indices)), 'ro', 'MarkerSize', 2, 'MarkerFaceColor', 'r');
xlabel('Radius (kpc)');
ylabel('Phase Shift (degrees)');
title('Filtered Radius vs Phase Shift');
grid on;
legend('Phase Shift', 'Zero Crossings(positive to negative)');
hold off;

