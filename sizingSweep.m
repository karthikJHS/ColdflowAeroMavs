% Rocket Sweep + Interpolated Surface & Contour Plot
model = 'SizingFlightModel';

% === CONSTANTS ===
g0 = 9.80665;
payload_mass = 20;            % kg
M = 28.8e-3;               % kg/mol (molar mass)
T_c = 3200;                % K
gamma = 1.23;
p_c = 520 * 6894.76;       % psi to Pa
isp = 205;                 % s
ve = isp * g0;
r = 0.08;                  % m

% === SWEEP SETUP ===
fuel_mass_list = linspace(0.5, 15, 30);
thrust_list = linspace(1000, 4000, 10);
n_total = numel(fuel_mass_list) * numel(thrust_list);
results = [];
i_sim = 0;
wb = waitbar(0, 'Running simulations...');

for m_fuel = fuel_mass_list
    for thrust = thrust_list
        i_sim = i_sim + 1;
        waitbar(i_sim / n_total, wb, ...
            sprintf('Sim %d/%d: Fuel = %.2f kg, Thrust = %.2f', i_sim, n_total, m_fuel, thrust));

        dry_mass = m_payload + 0.15*m_fuel; % take in account larger tank size
        m_0 = dry_mass + m_fuel; 
        mdot = thrust / ve;
        burn_time = m_fuel / mdot;
        mass_fraction = m_0/dry_mass;

        simIn = Simulink.SimulationInput(model);
        simIn = simIn.setVariable('mdot', mdot);
        simIn = simIn.setVariable('m_fuel', m_fuel);
        simIn = simIn.setVariable('m_0', m_0);
        simIn = simIn.setVariable('isp', isp);
        simIn = simIn.setVariable('T_c', T_c);
        simIn = simIn.setVariable('gamma', gamma);
        simIn = simIn.setVariable('p_c', p_c);
        simIn = simIn.setVariable('r', r);
        simIn = simIn.setVariable('M', M);

        try
            simOut = sim(simIn);
            altitude = simOut.logsout.getElement('x').Values.Data(end);  % use logged signal 'x'
        catch ME
            altitude = NaN;
            warning('Simulation failed: Fuel=%.2f, TWR=%.2f\n%s', m_fuel, TWR, ME.message);
        end

        results = [results; m_fuel, m_0, mass_fraction, thrust, mdot, burn_time, altitude];
        fprintf('[%3d/%3d] Fuel = %.2f kg, Thrust = %.2f, Mass_ratio = %.2f → Apogee = %.1f m\n', ...
            i_sim, n_total, m_fuel, thrust, mass_fraction, altitude);
    end
end

close(wb);

% === TABLE OUTPUT ===
result_table = array2table(results, ...
    'VariableNames', {'FuelMass_kg', 'InitialMass_kg', 'Mass_fractoion', 'Thrust_N', ...
                      'MassFlowRate_kgps', 'BurnTime_s', 'Apogee_m'});
writetable(result_table, 'RocketSweepResults.csv');

%% === INTERPOLATION & PLOTTING ===
target_apogee = 3048;  % 10,000 ft in meters

F = result_table.FuelMass_kg;
T = result_table.Thrust_N;
A = result_table.Apogee_m;
mdot = result_table.MassFlowRate_kgps;

[Fq, Tq] = meshgrid(linspace(min(F), max(F), 100), linspace(min(T), max(T), 100));
Aq = griddata(F, T, A, Fq, Tq, 'cubic');

% Start figure with subplots
figure('Name', 'Apogee Surface + Contour Analysis', 'Position', [100, 100, 1200, 500]);

% === SUBPLOT 1: 3D Surface + Contour Slice ===
subplot(1, 2, 1);
surf(Fq, Tq, Aq, 'EdgeColor', 'none');
hold on;
[C, hContour] = contour3(Fq, Tq, Aq, [target_apogee target_apogee], 'k', 'LineWidth', 2);
clabel(C, hContour, 'Color', 'white');
xlabel('Fuel Mass (kg)');
ylabel('Thrust(N)');
zlabel('Apogee (m)');
title('Apogee Surface with 3048 m Contour');
view(45, 30);
grid on;
colorbar;

% Extract intersection points from contour
x_contour = C(1, 2:end);  % fuel mass
y_contour = C(2, 2:end);  % Thrust
mdot_interp = griddata(F, T, mdot, x_contour, y_contour, 'linear');

% === SUBPLOT 2: 2D Plot of mdot vs Fuel Mass along Contour ===
subplot(1, 2, 2);
plot(x_contour, mdot_interp, 'b-', 'LineWidth', 2);
xlabel('Fuel Mass (kg)');
ylabel('Mass Flow Rate (kg/s)');
title('Mass Flow Rate vs Fuel Mass at Apogee = 3048 m');
grid on;

