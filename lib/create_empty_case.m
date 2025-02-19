function mpc = create_empty_case()
    % Create an empty Matpower case structure
    mpc.version = '2';  % Version of the Matpower case format
    mpc.baseMVA = 100;  % Base power in MVA (Mega Volt-Amperes)
    
    % Bus data (at least one bus is needed)
    mpc.bus = [
        0 % Bus number (ID)
        0 % Bus type (1 - PQ bus, 2 - PV bus, 3 - reference bus, 4 - isolated)
        0 % Real power demand (MW)
        0 % Reactive power demand (MVar)
        0 % Shunt conductance (Gs)
        0 % Shunt susceptance (Bs)
        0 % Area number
        0 % Voltage magnitude (Vm)
        0 % Voltage angle (Va) in degrees
        0 % Base voltage (kV)
        0 % Zone
        0 % Maximum voltage magnitude (Vmax)
        0 % Minimum voltage magnitude (Vmin)
    ]';

    % Generator data (generators can be absent)
    mpc.gen = [
        0 % Bus location
        0 % Real power output (MW)
        0 % Reactive power output (MVar)
        0 % Reactive power capability maximum (Qmax,MVar)
        0 % Reactive power capability minimum (Qmin,MVar)
        0 % Voltage magnitude setpoint (Vg)
        0 % BaseMVA, total MVA base of this machine, defaults to baseMVA
        0 % Status (1 - machine in-service, 0 - machine out-of-service)
        0 % Maximum real power output (Pmax,MW)
        0 % Minimum real power output (Pmin,MW)
        0 % PC1, for user-defined model
        0 % PC2, for user-defined model
        0 % QC1MIN, minimum reactive power output at PC1 (Qg at PC1)
        0 % QC1MAX, maximum reactive power output at PC1 (Qg at PC1)
        0 % QC2MIN, minimum reactive power output at PC2 (Qg at PC2)
        0 % QC2MAX, maximum reactive power output at PC2 (Qg at PC2)
        0 % Ramp rate for load following/AGC (MW/min)
        0 % Ramp rate for 10 minute reserves (MW)
        0 % Ramp rate for 30 minute reserves (MW)
        0 % Ramp rate for reactive power (MVAR/min)
        0 % Initial commitment status (1 = committed, 0 = decommitted)
    ]';

    % Branch data (branches can be absent)
    mpc.branch = [
        0 % From bus number
        0 % To bus number
        0 % Resistance (R), per unit
        0 % Reactance (X), per unit
        0 % Line charging susceptance (B), per unit
        0 % MVA rating A (long term rating, MW)
        0 % MVA rating B (short term rating)
        0 % MVA rating C (emergency rating)
        0 % Status: 1 = in-service, 0 = out-of-service
        0 % Minimum angle difference (AngleMin)
        0 % Maximum angle difference (AngleMax)
        0 % Tap ratio (for transformers)
        0 % Phase shift angle (for transformers)
    ]';

    % Additional fields such as areas, costs etc. can be added as needed
end
