clear all

%% Calculating Reynolds Number (Re)

% Formula:
% Re = rho*v*L / mu

% rho - density of the fluid [kg*m^-3]
% v - mean flow velocity [m/s]
% L - characteristic length describing geometry of the system [m]
% mu - dynamic viscosity of a fluid [Pa*s]

% DENSITY, rho & VISCOSITY, mu
% for cDC (row 1) and xDC (row 3) we approximate the fluid density and dynamic vesocity
% as being equal to those of water at 25 C
% for sDC (row 2) the density of medium  (0.5% methylcellusoe in PBS) is roughly
% that of water, but viscosity is increased;
% shear-thinning-adjusted viscosity value corresponding
% to experiemntal coniditions is used here (after Herold 2017 arXiv:1704.00572)

rho(1, 1) = 997.54; %[kg/m^3]
rho(2, 1) = 997.54; %[kg/m^3]
rho(3, 1) = 997.54; %[kg/m^3]

mu(1, 1) = 9.31 * 10^-4; %[Pa*s]
mu(2, 1) = 5.7 * 10^-3; %[Pa*s]
mu(3, 1) = 9.31 * 10^-4; %[Pa*s]

% CHARACTERISTIC LENGTH, L
% For a rectangular duct with side lengths a and b, the characteristic length
% is equivalent to its hydraulic diameter Dh
% L = Dh = 4ab/[2(a+b)]=2ab/(a+b)
% A - cross section area of the measurment channel [m^2]
%       (= channel height * channel width)

% For cDC a = 6 um, b = 15 um
L(1, 1) = 2 * 6 * 15 * 10^-12 ./ (6 * 10^-6 + 15 * 10^-6); %[m]
A(1, 1) = 6 * 15 * 10^-12;

% For sDC a = b = 20 um
L(2, 1) = 20 * 10^-6; %[m]
A(2, 1) = 20 * 20 * 10^-12;

% For xDC a = 60;  b = 30 um
L(3, 1) = 2 * 60 * 30 * 10^-12 ./ (60 * 10^-6 + 30 * 10^-6); %[m]
A(3, 1) = 30 * 60 * 10^-12;

% MEAN FLOW VELOCITY, v
% The volumetric flow rate Q (set via syringe pump) can be converted to
% mean flow velocity v simply by dividing its value by channel
% cross-section area A
%   v = Q/A,
%   Q - volumetric flow rate [m^3/s],
%   A - cross section area of the measurment channel [m^2]

%cDC
Q0(1, 1) = 0.06; %[ul/min]
%sDC
Q0(2, 1) = 2.4; %[ul/min]
%xDC
Q0(3, 1) = 750./2; %[ul/min]

Q = Q0 * 10^-9 ./ 60; %[m3/s]

v = Q ./ A; %[m/s]


% Calculate Re

Re = rho .* v .* L ./ mu;
