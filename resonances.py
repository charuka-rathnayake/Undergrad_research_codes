# -*- coding: utf-8 -*-
"""
Created on Fri oct 03 11:01:54 2025

@author: vishwa
@edited: charuka
Galaxy Kinematics Analysis Script

Description:
This script calculates various kinematic parameters of a galaxy based on given data points for radii and rotational speeds. It includes interpolation of data points, calculation of angular velocity and epicyclic frequency, and determination of resonant angular speeds. Additionally, the script features an option to extend the rotation curve of the galaxy to a specified radius.

Features:
1. Data Interpolation: The interpolation now occurs between every pair of points in your dataset. This is done by iterating over each pair and generating a specified number of intermediate points between them.

2. Kinematic Calculations:
   - Angular Velocity (Ω): Calculated as the rotational speed divided by the radius for each point.
   - Epicyclic Frequency (κ): Computed using the formula κ = sqrt(R * d(Ω²)/dR + 4Ω²), an essential parameter in galactic dynamics.
   - Inner Lindblad Resonance (ILR), Outer Lindblad Resonance (OLR), Inner 4:1 Resonance and Outer 4:1 Resonance: Calculated based on provided formulas.

3. Curve Extension: Offers an option to extend the rotation curve to a user-defined maximum radius, using a simple fitting model. This extension is critical for exploring the kinematic behavior beyond the initially provided data.

4. Output: Generates a comprehensive output of all calculated parameters, including radii, rotation speed, angular velocity, epicyclic frequency, and angular speeds for various resonances, written to a file named 'galaxy_data.txt'.

Usage:
Run the script in a Python environment. The user will be prompted to decide whether to extend the rotation curve. If extended, the script will ask for the maximum radius and perform calculations for the extended range.

Note:
It is essential to validate the output, especially for research purposes. The curve fitting model, while basic, can be adjusted for more complex galaxy data. The user should ensure that the model aligns well with the expected physical behavior of the galaxy's rotation curve.
"""



import numpy as np
import pandas as pd
from scipy.interpolate import interp1d
from scipy.optimize import curve_fit

# Function to extend rotation curve based on a simple model
def rotation_curve_model(r, a, b, c):
    return a / (r + b) + c

def extend_curve_radii(radii, rot_speed, max_radius):
    popt, _ = curve_fit(rotation_curve_model, radii, rot_speed, maxfev=10000)
    
    # Start extending just beyond the last original radius point to avoid duplicates
    extended_radii = np.linspace(radii[-1] + (radii[1]-radii[0])/100, max_radius, 100)  # <--- Edited part
    extended_rot_speed = rotation_curve_model(extended_radii, *popt)
    return np.concatenate([radii, extended_radii]), np.concatenate([rot_speed, extended_rot_speed])


# load data from excel file
file_name = "rotational_speed_1566.xlsx"
df = pd.read_excel(file_name)

#extract columns
radii = df.iloc[:,0].to_numpy()        #kpc
rot_speed = df.iloc[:,1].to_numpy()    #km/s


# Ensure data is sorted by radii
sorted_indices = np.argsort(radii)
radii = radii[sorted_indices]
rot_speed = rot_speed[sorted_indices]

# Ask if the user wants to extend the curve
extend = input("Do you want to extend the curve (yes/no)? ")
if extend.lower() == 'yes':
    max_radius = float(input("Enter the maximum radius to extend to: "))
    all_radii, all_rot_speed = extend_curve_radii(radii, rot_speed, max_radius)
else:
    all_radii, all_rot_speed = radii, rot_speed

# Interpolate between each pair of points
interp_func = interp1d(all_radii, all_rot_speed, kind='cubic')
interpolated_radii = []
interpolated_rot_speed = []
num_intermediate_points = 50

for i in range(len(all_radii) - 1):
    intermediate_radii = np.linspace(all_radii[i], all_radii[i+1], num=num_intermediate_points+2)[1:-1]
    intermediate_speeds = interp_func(intermediate_radii)
    interpolated_radii.extend(intermediate_radii)
    interpolated_rot_speed.extend(intermediate_speeds)

# Add the last original point
interpolated_radii.append(all_radii[-1])
interpolated_rot_speed.append(all_rot_speed[-1])

# Perform calculations
angular_velocity = np.array(interpolated_rot_speed) / np.array(interpolated_radii)
angular_velocity_sq = angular_velocity**2
d_omega_sq_dr = np.gradient(angular_velocity_sq, np.array(interpolated_radii))
inside = np.array(interpolated_radii) * d_omega_sq_dr + 4 * angular_velocity_sq
inside[inside < 0] = np.nan
kappa = np.sqrt(inside)

angular_speed_ILR = angular_velocity - kappa / 2
angular_speed_OLR = angular_velocity + kappa / 2
angular_speed_I_4_1 = angular_velocity - kappa / 4
angular_speed_O_4_1 = angular_velocity + kappa / 4

# Write results to a xlsx file

results_df = pd.DataFrame({"Radius (kpc)": interpolated_radii,"Rot. Speed (km/s)": interpolated_rot_speed,"Angular Speed (km/s/kpc)": angular_velocity,"Kappa (km²/s²/kpc)": kappa,"ILR (km/s/kpc)": angular_speed_ILR,"OLR (km/s/kpc)": angular_speed_OLR,"I_4:1 (km/s/kpc)": angular_speed_I_4_1,"O_4:1 (km/s/kpc)": angular_speed_O_4_1})    
results_df = results_df.round({"Radius (kpc)": 3,"Rot. Speed (km/s)": 2,"Angular Speed (km/s/kpc)": 2,"Kappa (km²/s²/kpc)": 2,"ILR (km/s/kpc)": 2,"OLR (km/s/kpc)": 2,"I_4:1 (km/s/kpc)": 2,"O_4:1 (km/s/kpc)": 2})   

results_df.to_excel("resonances_data_NGC1566_test.xlsx", index=False)   
print("Data written to resonances_data_NGC1566_test.xlsx")   
    
    
    
    



