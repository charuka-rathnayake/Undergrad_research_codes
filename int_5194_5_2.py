# -*- coding: utf-8 -*-
"""
Created on Sun Sep 14 13:44:27 2025

@author: CHARUKA
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from astropy.io import fits




def calculate_intensity(fits_file, center,x_mag_factor, radial_bin_size, max_radius, min_radius, azimuthal_bins, pixel_scale, galaxy_distance):
    # Load the FITS file
    hdu = fits.open(fits_file)[0]
    data = hdu.data

    if data is None or len(data.shape) < 2:
        raise ValueError("FITS file does not contain valid 2D image data.")

    y_size, x_size = data.shape
    x_center, y_center = center

    # Create coordinate grid
    y, x = np.indices((y_size, x_size))
    x_shifted = (x - x_center)*x_mag_factor
    y_shifted = y - y_center

    # Convert to polar coordinates (r, phi)
    r_indices = np.hypot(x_shifted, y_shifted)
    phi_indices = np.arctan2(y_shifted, x_shifted)
    phi_indices[phi_indices < 0] += 2*np.pi  # Normalize to 0-360 degrees

    # Define radial bins
    radial_bins = np.arange(min_radius, max_radius+radial_bin_size, radial_bin_size)
    azimuthal_bins = np.linspace(0, 2 * np.pi, azimuthal_bins + 1)


    # Create a 2D grid to store mean intensity
    intensity_map = np.zeros((len(radial_bins) - 1, len(azimuthal_bins) - 1))

    # Compute mean intensity in each bin
    for i in range(len(radial_bins) - 1):
        for j in range(len(azimuthal_bins) - 1):
            mask = (r_indices >= radial_bins[i]) & (r_indices < radial_bins[i + 1]) & \
                   (phi_indices >= azimuthal_bins[j]) & (phi_indices < azimuthal_bins[j + 1])
            if np.any(mask):
                intensity_map[i, j] = np.mean(data[mask])

    # Convert to physical units (kpc)
    kpc_per_arcsec = (galaxy_distance * 1e3) * (np.pi / 648000)  # Conversion factor 
    radial_bin_centers = 0.5 * (radial_bins[:-1] + radial_bins[1:]) *pixel_scale*kpc_per_arcsec
    azimuthal_bin_centers = 0.5 * (azimuthal_bins[:-1] + azimuthal_bins[1:])

    return intensity_map, radial_bin_centers, azimuthal_bin_centers

def save_csv(intensity_map, radial_bin_centers, azimuthal_bin_centers):
    polar_data = []
    for i, r in enumerate(radial_bin_centers):
        for j, phi in enumerate(azimuthal_bin_centers):
            polar_data.append([r, phi, intensity_map[i, j]])

    df = pd.DataFrame(polar_data, columns=["Radius (kpc)", "Azimuthal Angle (radians)", "Intensity"])
    df.to_csv("intensity_r_phi_5_2.csv", index=False)
    print("CSV file saved as intensity_r_phi_5_2.csv")

def visualize_radial_profile(intensity_map, radial_bin_centers):
    mean_intensity_radial = np.mean(intensity_map, axis=1)

    plt.figure(figsize=(8, 5))
    plt.plot(radial_bin_centers, mean_intensity_radial, marker='o', color='blue')
    plt.xlabel("Radius (kpc)")
    plt.ylabel("Mean Intensity")
    plt.title("Radial Intensity Profile")
    plt.grid(True)
    plt.tight_layout()
    plt.show()

def visualize_3d_plot(intensity_map, radial_bin_centers, azimuthal_bin_centers):
    azimuthal_grid, radial_grid = np.meshgrid(azimuthal_bin_centers, radial_bin_centers)

    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')
    surf = ax.plot_surface(azimuthal_grid, radial_grid, intensity_map, cmap='inferno', edgecolor='none')

    ax.set_xlabel("Azimuthal Angle (radians)")
    ax.set_ylabel("Radius (kpc)")
    ax.set_zlabel("Mean Intensity")
    ax.set_title("Galaxy Light Intensity Distribution (3D Surface)")

    fig.colorbar(surf, ax=ax, shrink=0.5, aspect=10, label='Mean Intensity')
    ax.view_init(elev=30, azim=135)
    plt.tight_layout()
    plt.show()

# Example usage:
fits_file = "NGC5194_3.6_crop.fits"
center = (570, 564)  # Example pixel coordinates of the galaxy center
x_mag_factor = 1.3466
radial_bin_size = 5   #pixels
max_radius = 337     #pixels
min_radius = 50       #pixels
azimuthal_bins = 180
pixel_scale = 1.2233  # arcseconds per pixel
galaxy_distance = 7.55  # Mpc

intensity_map, radial_bin_centers, azimuthal_bin_centers = calculate_intensity(
    fits_file, center, x_mag_factor, radial_bin_size, max_radius, min_radius, azimuthal_bins, pixel_scale, galaxy_distance)

save_csv(intensity_map, radial_bin_centers, azimuthal_bin_centers)
visualize_radial_profile(intensity_map, radial_bin_centers)
visualize_3d_plot(intensity_map, radial_bin_centers, azimuthal_bin_centers)