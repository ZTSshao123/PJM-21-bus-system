function save_mpc_to_mfile(mpc, filename)
%SAVE_MPC_TO_MFILE Save a MATPOWER case structure to a .m file that returns the structure
%   save_mpc_to_mfile(mpc, filename)
%   mpc - MATPOWER case struct
%   filename - Name of the file to save (should not include .m extension)

    % Open a new file
    fid = fopen([filename,'.m'], 'w');
    
    % Write the function definition
    fprintf(fid, 'function mpc = %s\n', filename);
    % Write comments to the file
    fprintf(fid, '%%\n');
    fprintf(fid, '%% CASE DESCRIPTION FOR PJM ELECTRICAL SYSTEM SIMULATION\n');
    fprintf(fid, '%% This MATLAB case study models the PJM electrical system using 21 nodes, each representing\n');
    fprintf(fid, '%% one of the transmission zones in PJM. The model incorporates:\n');
    fprintf(fid, '%% - Line, generator, and area data sourced from the U.S. Energy Information Administration (EIA),\n');
    fprintf(fid, '%%   available at https://atlas.eia.gov/search.\n');
    fprintf(fid, '%% - Load and additional operational data obtained from the official PJM website.\n');
    fprintf(fid, '%%\n');
    fprintf(fid, '%% The simulation provides a detailed representation of the interconnections and operational dynamics\n');
    fprintf(fid, '%% within the PJM zones, facilitating analysis and research into large-scale power systems.\n');
    fprintf(fid, '%%\n');
    fprintf(fid, '%% Developed in December 2024 by Dr. Zhen Tong Shao and Professor Nanpeng Yu, \n');
    fprintf(fid, '%% University of California, Riverside.\n');
    fprintf(fid, '%%\n');
    
    % Save the MATPOWER case version
    fprintf(fid, 'mpc.version = ''%s'';\n\n', mpc.version);
    
    % Save the baseMVA
    fprintf(fid, 'mpc.baseMVA = %d;\n\n', mpc.baseMVA);
    
    % Save the bus data
    fprintf(fid, '%%%% bus data\n');
    fprintf(fid, '%% bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin\n');
    fprintf(fid, 'mpc.bus = [\n');
    printData(fid, mpc.bus);
    fprintf(fid, '];\n\n');
    
    % Save the generator data
    fprintf(fid, '%%%% generator data\n');
    fprintf(fid, '%% bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf\n');
    fprintf(fid, 'mpc.gen = [\n');
    printData(fid, mpc.gen);
    fprintf(fid, '];\n\n');
    
    % Save the branch data
    fprintf(fid, '%%%% branch data\n');
    fprintf(fid, '%%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax\n');
    fprintf(fid, 'mpc.branch = [\n');
    printData(fid, mpc.branch);
    fprintf(fid, '];\n\n');
    
    % Save the generator cost data
    fprintf(fid, '%%%% generator cost data\n');
    fprintf(fid, '%%	1	startup	shutdown	n	x1	y1	...	xn	yn\n');
    fprintf(fid, '%%	2	startup	shutdown	n	c(n-1)	...	c0\n');
    fprintf(fid, 'mpc.gencost = [\n');
    printData(fid, mpc.gencost);
    fprintf(fid, '];\n\n');
    
    % Save additional data fields if present
    if isfield(mpc, 'bus_name')
        fprintf(fid, 'mpc.bus_name = {\n');
        fprintf(fid, '''%s''\n', mpc.bus_name{:});
        fprintf(fid, '};\n\n');
    end

    if isfield(mpc, 'fuel_type')
        fprintf(fid, 'mpc.fuel_type = {\n');
        fprintf(fid, '''%s''\n', mpc.fuel_type{:});
        fprintf(fid, '};\n\n');
    end
    
    % Close function and file
    fprintf(fid, 'end\n');
    fclose(fid);
end

function printData(fid, data)
    [rows, cols] = size(data);
    for i = 1:rows
        for j = 1:cols
            if floor(data(i,j)) == data(i,j) % Check if the number is an integer
                fprintf(fid, '%d', data(i,j));
            else
                fprintf(fid, '%.5f', data(i,j));
            end
            if j < cols
                fprintf(fid, '\t');
            end
        end
        fprintf(fid, '\n');
    end
end
