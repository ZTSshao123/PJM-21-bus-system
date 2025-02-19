function [R_pu, X_pu, B_pu] = linePU(R_line, X_line, B_line, lineVoltage, baseVoltage, basePower)
% linePU Calculates the per-unit values of line resistance, reactance, and susceptance, 
% adjusting for differences in line and system voltage levels
%
%   [R_pu, X_pu, B_pu] = linePU(R_line, X_line, B_line, lineVoltage, baseVoltage, basePower)
%
%   Inputs:
%       R_line      - Line resistance, in ohms (Ω)
%       X_line      - Line reactance, in ohms (Ω)
%       B_line      - Line susceptance, in Siemens (S)
%       lineVoltage - Nominal voltage of the line, in kilovolts (kV)
%       baseVoltage - Chosen base voltage, in kilovolts (kV)
%       basePower   - Chosen base power, in MVA
%
%   Outputs:
%       R_pu        - Per-unit value of line resistance
%       X_pu        - Per-unit value of line reactance
%       B_pu        - Per-unit value of line susceptance
%
%   Notes:
%       - This calculation includes a transformation factor for impedance and admittance
%         when lineVoltage differs from baseVoltage.
%       - Base impedance: Z_base = (V_base^2) / S_base
%       - Base admittance: Y_base = S_base / (V_base^2)
%       - Voltage ratio squared for impedance scaling: a^2 = (V_base / V_line)^2

    % 1. Calculate base impedance (in ohms) and base admittance (in Siemens)
    Z_base = (baseVoltage * 1e3)^2 / (basePower * 1e6);  % Convert kV to V and MVA to VA
    Y_base = (basePower * 1e6) / ((baseVoltage * 1e3)^2);  % Convert MVA to VA and kV to V

    % 2. Calculate the square of the voltage ratio (impedance transformation factor)
    a2 = (baseVoltage / lineVoltage)^2;

    % 3. Adjust line resistance, reactance to baseVoltage side and compute per-unit values
    R_eq = a2 * R_line;  % Adjusted line resistance
    X_eq = a2 * X_line;  % Adjusted line reactance
    R_pu = R_eq / Z_base;
    X_pu = X_eq / Z_base;

    % 4. Adjust line susceptance to baseVoltage side and compute per-unit value
    B_eq = B_line / a2;  % Adjusted line susceptance
    B_pu = B_eq / Y_base;

end
