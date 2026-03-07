This repository mainly includes the Python and MATLAB scripts used at each step to find the corotation radii using the potential–density phase shift method. To obtain the corotation radii using this method, run the codes in the following order, because each script outputs a CSV file that is used as input for the next script.

1). int_5194_5_2.py
This gives the surface brightness distribution of the galaxy. The Python script used for NGC 5194 is uploaded here. The FITS image of NGC 5194, which should be used as input, is also uploaded here. Surface brightness distributions for other galaxies can be obtained by changing the input arguments in this script.

2). surface_density_r.m
This MATLAB script file provides the radial surface mass density distribution of the galaxy.

3). surface_perturbation.m
This MATLAB script file provides the galaxy’s surface mass density perturbation distribution.

4). gravitational_potential_r.m
This provides the gravitational potential distribution of the galaxy for the axisymmetric case.

5). gravitational_potential_r_phi.m
This MATLAB script computes the gravitational potential distribution of the galaxy in the non axisymmetric case.

6). potential_perturbation.m
This MATLAB script file provides the galaxy’s gravitational potential perturbation distribution.

7). squre_surface_perturbation.m
This MATLAB script uses numerical integration to obtain √(∫ Σ₁² dφ).

8). squre_potential_perturbation.m
This MATLAB script evaluates √(∫ ν₁² dφ) using numerical integration.

9). differentiate_potential_perturbation.m
This MATLAB script computes ∂ν₁/∂φ using numerical differentiation.

10). product_surface_perturbation_dnu1_dphi.m
This MATLAB script uses numerical integration to compute ∫ Σ₁(∂ν₁/∂φ) dφ from the ∂ν₁/∂φ
 values produced by the previous code.

11). phase_shift.m
This MATLAB script obtains the potential–density phase shift distribution of the galaxy.

Also, the resonances.py script used to obtain corotation radii and Lindblad resonance locations from the rotation‑curve method is included in this repository.
