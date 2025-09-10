clear; clc;

T_triple = 183;   % Triple point temperature [K]
T_crit = 309;  % Critical point temperature [K]

T_range = T_triple:1:T_crit;
u_liq = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U','T',T,'Q',0,'NitrousOxide'), T_range);
u_vap = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U','T',T,'Q',1,'NitrousOxide'), T_range);
rho_liq = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D','T',T,'Q',0,'NitrousOxide'), T_range);
rho_vap = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D','T',T,'Q',1,'NitrousOxide'), T_range);
h_liq = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('H','T',T,'Q',0,'NitrousOxide'), T_range);
h_vap = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('H','T',T,'Q',1,'NitrousOxide'), T_range);
p = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('P','T',T,'Q',0,'NitrousOxide'), T_range);
save('CoolPropLookup.mat', 'T_range', 'u_liq', 'u_vap', 'rho_liq', 'rho_vap', 'h_liq', 'h_vap', 'p');

%% Generate Testing Conditions
p_fill= 600*6894.76; % Fill Line Pressure (600 psi)
p_amb = 101325;
r = (4*2.54/100);
L = 2*r;
x_full = 0.12; % Assuming 12% Ullage @ Full Tank Capacity
H=20*2.54/100; % Tank height of 20 in
V_tank = pi * r^2 * H;
A = 2*pi*r*(r+H); % Tank Surface Area
T = 298;
x_test = 1.0;

m_tot0 = V_tank*(x_test/py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 1, 'NitrousOxide') + (1-x_test)/py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 0, 'NitrousOxide'))^(-1); 
U_tot0 = ((1-x_test)*py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide')+x_test*py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 1, 'NitrousOxide'))*m_tot0;
mu = 1.48e-5; % Nitrous Vapor Dynamic Viscosity @ Standard Conditions

%% Convection Parameters
k_liq=0.109;
k_vap=0.0152;
k_al=236;

% Nusselt # Constants
C_liq = 0.021;
C_vap = 0.021;
C_atm = 0.59;
n_liq = 0.4;
n_vap = 0.4;
n_atm = 0.25;


% Rayleigh # Expressions
g = 9.79346; % Gravity @ Hearne
c_p= 0.88; % Specific Heat @ Constant Pressure (20 C)
Pr_liq = mu*c_p/k_liq^2;
Pr_vap = mu*c_p/k_vap^2;
Pr_al = mu*c_p/k_al^2;
B_liq = 1.2e-3;
B_vap = 3.33e-3;
B_al = 69e-6;



