function result = aggregate_lines(params)
    % params: Lx4 matrix where columns represent r, x, b, P_max for each line
    % result: 1x4 vector [r_eq, x_eq, b_eq, P_max_eq]
    
    % Extract r, x, b, P_max columns
    r = params(:, 1);
    x = params(:, 2);
    b = params(:, 3);
    P_max = params(:, 4);

    % % Compute complex impedances Z
    % Z = r + 1i * x;
    % 
    % % Compute admittances Y = 1/Z
    % Y = 1 ./ Z;
    % 
    % % Aggregate admittances
    % Y_total = sum(Y);
    % 
    % % Compute equivalent impedance Z_eq = 1/Y_total
    % Z_eq = 1 / Y_total;
    % 
    % % Extract real and imaginary parts of Z_eq
    % r_eq = real(Z_eq);
    % x_eq = imag(Z_eq);
    
    r_eq = max(r);
    x_eq = max(x);

    % Aggregate susceptances (b values)
    b_eq = sum(b);

    % Aggregate power limits
    P_max_eq = sum(P_max);

    % Return result as a row vector
    result = [r_eq, x_eq, b_eq, P_max_eq];
end
