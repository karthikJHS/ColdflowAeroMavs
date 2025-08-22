clear; clc;

T_triple = 183;   % Triple point temperature [K]
T_crit   = 309;  % Critical point temperature [K]

T_range = T_triple:1:T_crit;
u_liq = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U','T',T,'Q',0,'NitrousOxide'), T_range);
u_vap = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('U','T',T,'Q',1,'NitrousOxide'), T_range);
rho_liq = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D','T',T,'Q',0,'NitrousOxide'), T_range);
rho_vap = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('D','T',T,'Q',1,'NitrousOxide'), T_range);
p = arrayfun(@(T) py.CoolProp.CoolProp.PropsSI('P','T',T,'Q',0,'NitrousOxide'), T_range);
save('CoolPropLookup.mat', 'T_range', 'u_liq', 'u_vap', 'rho_liq', 'rho_vap', 'p');

%% Generate Test Condition
r = (4*2.54/100);
V_tank = r * (20*2.54/100);
T = 298;
x_test = 1.0;
% total conditions 
m_tot = V_tank*(x_test/py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 1, 'NitrousOxide') + (1-x_test)/py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 0, 'NitrousOxide'))^(-1); 
U_tot = ((1-x_test)*py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide')+x_test*py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 1, 'NitrousOxide'))*m_tot;



