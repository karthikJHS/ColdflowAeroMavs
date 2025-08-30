% Generate Test Conditions
r = (4*2.54/100);
V_tank = r * (20*2.54/100);
T = 298;
x_test = 0.2;
% Reference thermodynamic conditions
rho_vap = py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 1, 'NitrousOxide');
rho_liq = py.CoolProp.CoolProp.PropsSI('D', 'T', T, 'Q', 0, 'NitrousOxide');
u_liq = py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 0, 'NitrousOxide');
u_vap = py.CoolProp.CoolProp.PropsSI('U', 'T', T, 'Q', 1, 'NitrousOxide');
% total conditions 
m_tot = V_tank*(x_test/rho_vap + (1-x_test)/rho_liq)^(-1); 
U_tot = ((1-x_test)*u_liq+x_test*u_vap)*m_tot;

% Resduals anonymous function given U_tot m_tot and V_tank 
residual_function = @(x) [(1-x(1)) * py.CoolProp.CoolProp.PropsSI('U', 'T', x(2), 'Q', 0, 'NitrousOxide') + x(1) * py.CoolProp.CoolProp.PropsSI('U', 'T', x(2), 'Q', 1, 'NitrousOxide')-U_tot/m_tot;
         (x(1)/py.CoolProp.CoolProp.PropsSI('D', 'T', x(2), 'Q', 1, 'NitrousOxide') + (1-x(1))/py.CoolProp.CoolProp.PropsSI('D', 'T', x(2), 'Q', 0, 'NitrousOxide'))*m_tot-V_tank];
% Innitial guess
x0 = [0.5; T];
% solve
options = optimoptions('fsolve','Display','iter');
[x,fval] = fsolve(residual_function,x0,options);