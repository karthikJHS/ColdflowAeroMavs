% One-shot simulation for debugging
model = 'SizingFlightModel';

% Inputs
g0 = 9.80665;
m_payload = 20;             % kg
m_fuel = 4.6;              % kg
TWR = 6.0;                 % dimensionless
isp = 205;                 % s
T_c = 3200;                % K
gamma = 1.23;
p_c = 520 * 6894.76;       % psi to Pa
M = 28.8e-3;               % kg/mol
R = 8.31446 / M;           % J/kg·K
ve = isp * g0;             % m/s
r = 0.08;           % rocket radius in meters (0.16 m diameter / 2)
M = 28.8e-3;        % kg/mol, molar mass of combustion gases

% Derived
dry_mass = m_payload + 0.15 * m_fuel;
m_0 = dry_mass + m_fuel;
thrust = TWR * m_0 * g0;
mdot = thrust / ve;
mass_fraction = (m_0)/dry_mass;
burn_time = m_fuel / mdot;

% Display summary
fprintf('Testing single config:\n Dry mass: %.2f kg, Fuel = %.2f kg, TWR = %.2f, mdot = %.3f kg/s, Burn = %.2f s\n', ...
    dry_mass, m_fuel, TWR, mdot, burn_time);

% Set up Simulink input
simIn = Simulink.SimulationInput(model);
simIn = simIn.setVariable('mdot', mdot);
simIn = simIn.setVariable('m_fuel', m_fuel);
simIn = simIn.setVariable('m_0', m_0);
simIn = simIn.setVariable('isp', isp);
simIn = simIn.setVariable('T_c', T_c);
simIn = simIn.setVariable('gamma', gamma);
simIn = simIn.setVariable('p_c', p_c);
simIn = simIn.setVariable('R', R);
simIn = simIn.setVariable('r', r);
simIn = simIn.setVariable('M', M);

% Run simulation
try
    simOut = sim(simIn);
    altitude = simOut.logsout.getElement('x').Values.Data(end);
    fprintf('Simulation succeeded. Apogee: %.2f m\n', altitude);
catch ME
    fprintf(2, 'Simulation failed: %s\n', ME.message);
end
