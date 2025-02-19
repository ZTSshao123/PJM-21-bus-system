function [R, X, B, P_max] = estimate_line_params(V_level, L, RateA)
% ESTIMATE_LINE_PARAMS Estimates transmission line R, X, B, and approximate P_max (rough)
%
%   Inputs:
%       V_level : String, Voltage level, must be '345kV', '500kV', or '765kV'
%       L       : Line length in meters (m)
%
%   Outputs:
%       R     : Total line resistance, in Ohms (Ω)
%       X     : Total line reactance, in Ohms (Ω)
%       B     : Total line susceptance, in Siemens (S)
%       P_max : Approximate maximum power transmission capacity, in MW (based on the minimum of thermal limit and SIL)
%
%   Example call:
%       [R, X, B, P_max] = estimate_line_params('345kV', 100e3);
%       disp(R); disp(X); disp(B); disp(P_max);

    % 1. Convert line length from meters to kilometers
    L_km = L / 1000;

    % 2. Select typical parameters based on the voltage level
    switch V_level
        case 69
            r = 0.12;      % Ω/km (estimated)
            x = 0.30;      % Ω/km (estimated)
            b = 1.5e-6;    % S/km (estimated)
            Pmax_ref = 70; % MW (estimated)
            
        case 115
            r = 0.10;      % Ω/km (estimated)
            x = 0.28;      % Ω/km (estimated)
            b = 2.0e-6;    % S/km (estimated)
            Pmax_ref = 120; % MW (estimated)
        
        case 138
            r = 0.08;      % Ω/km (estimated)
            x = 0.25;      % Ω/km (estimated)
            b = 2.5e-6;    % S/km (estimated)
            Pmax_ref = 150; % MW (estimated)
        
        case 161
            r = 0.06;      % Ω/km (estimated)
            x = 0.22;      % Ω/km (estimated)
            b = 3.0e-6;    % S/km (estimated)
            Pmax_ref = 200; % MW (estimated)
            
        case 230
            r = 0.5;      % Ω/km (estimated)
            x = 0.18;      % Ω/km (estimated)
            b = 3e-6;    % S/km (estimated)
            Pmax_ref = 500; % MW (estimated)
            
        case 232
            r = 0.05;      % Ω/km (estimated)
            x = 0.18;      % Ω/km (estimated)
            b = 3e-6;    % S/km (estimated)
            Pmax_ref = 500; % MW (estimated)
        
        case 345
            r = 0.03;      % Ω/km (example)
            x = 0.15;      % Ω/km (example)
            b = 4e-6;    % S/km (example)
            Pmax_ref = 1500; % MW (estimated)
            
        case 500
            r = 0.01;      
            x = 0.12;      
            b = 6e-6;    % S/km (example)
            Pmax_ref = 2500; % MW (estimated)
    
        case 765
            r = 0.005;      
            x = 0.10;      
            b = 10e-6;    % S/km (example)
            Pmax_ref = 3000; % MW (estimated)
  
        otherwise
            error('V_level must be either ''345kV'', ''500kV'', or ''765kV''.');
    end

    % 3. Calculate total line resistance R, reactance X, and susceptance B
    R = r * L_km;   % Ω
    X = x * L_km;   % Ω
    B = b * L_km;   % S (Siemens)
    
    % Tow Methods
    % Calculate from the maximum static cuurent limitation by RateA
    CMD = 'M2';
    switch CMD
        case 'M1'
            P_max = RateA*V_level*1000/1e6; % (MW)
        case 'M2'
            P_max = Pmax_ref;
    end

end
