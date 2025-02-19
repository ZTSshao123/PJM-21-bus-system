clc; clear;

% Add directories to MATLAB's path for data and library functions
addpath('data\');
addpath('lib\');

% Set random number generator for reproducibility
rng(88);

% Initialize an empty bus matrix
mpc = create_empty_case();

% Load zone data from file
pjm_zone = readtable('data/pjm_zone.csv');
pjm_zone(14,:) = []; % Remove the MECK zone entry

% Assign zone names to bus names
mpc.bus_name = pjm_zone.LOC_NAME;
NB = length(mpc.bus_name); % Number of buses

%% Create the bus data
% Create the bus matrix
mpc.bus = ones(NB,1) * mpc.bus;
mpc.bus(:,1) = 1:NB; % Assign bus IDs
% Default bus settings: type, load, generation, shunt, base voltage, area, VM, VA
default_index_of_matpower = [2,7,8,9,10,11,12,13];
mpc.bus(:,default_index_of_matpower) = ones(NB,1)*[1,1,1,0,345,1,1.1,0.9];
REFERENCE_BUS = 13;
mpc.bus(REFERENCE_BUS,2) = 3; % Set the first bus as reference

% Processing the annual peak load
% Create a containers.Map to store the data
peak.keys = {'DEOK', 'COMED', 'DAY', 'AECO', 'BGE', 'DOM', 'DPL', 'JCPL', 'PEPCO', 'PSEG', ...
        'PECO', 'METED', 'PPL', 'RECO', 'DUQ', 'PENELEC', 'ATSI', 'APS', 'AEP', 'EKPC', 'OVEC'};
peak.values = [5170.9, 21559.6, 3365, 2566, 6765.9, 23117.8, 4188.5, 6183.6, 6161.7, 10151.7, ...
          8651.5, 3066.9, 7459.6, 403.6, 2690.7, 2953.2, 12508.3, 8937.6, 22318, 3748.3, 104];

% peak.keys = {'AECO', 'AEP', 'APS', 'BGE', 'COMED', 'DAY', 'DEOK', 'DOM', 'DPL', 'DUQ', ...
%              'EKPC', 'JCPL', 'METED', 'ATSI', 'OVEC', 'PECO', 'PEPCO', 'PPL', 'PENELEC', 'PSEG', 'RECO'};
% peak.values = [2247.5, 21108.3, 8065.9, 5958.1, 12154.1, 3292, 5086.6, 19613.5, 3568.7, 2187.8,...
%               2560.0, 4310.8, 2587.2, 8567, 46, 6872.7, 5346.8, 6128.3, 2332.6, 7920.6, 304.8];

LOAD_P = 3;
for i = 1:NB
    mid_index = find(cellfun(@(x) strcmp(x, mpc.bus_name{i}), peak.keys));
    mpc.bus(i,LOAD_P) = peak.values(mid_index);
end

%% Create the line data
% Load branch data
Target_voltage = 161;
pjm_line = readtable('data/pjm_line.csv');
line_rating = readtable('data/line_ratings.csv');
pjm_line.ratingA = zeros(size(pjm_line,1),1); % In Ampere

for i = 1:size(pjm_line,1)
    idx = find(line_rating.line_ID == pjm_line.ID(i));
    if isempty(idx)
        pjm_line.ratingA(i) = 996.97107;

    else
        pjm_line.ratingA(i) = line_rating.FMAX(idx);
    end
end

pjm_line = pjm_line(pjm_line.VOLTAGE >= Target_voltage,:);
for i = 1:size(pjm_line, 1)
    a = correct_zone_ID(pjm_line.start_zone(i));
    b = correct_zone_ID(pjm_line.end_zone(i));
    pjm_line.start_zone(i) = min(a,b);
    pjm_line.end_zone(i)   = max(a,b);
end
pjm_line(pjm_line.start_zone == pjm_line.end_zone, :) = [];
pjm_line = sortrows(pjm_line, 'start_zone');

% Update branch data with correct zone IDs
NL = size(pjm_line,1);
mpc.branch = ones(NL,1) * mpc.branch;
FROM_BUS = 1;
TO_BUS = 2;
for i = 1:NL
    mpc.branch(i,FROM_BUS) = pjm_line.start_zone(i);
    mpc.branch(i,TO_BUS) = pjm_line.end_zone(i);
end

% Calculate branch parameters
BASE_V = 10;
for i = 1:NL
    V_line = pjm_line.VOLTAGE(i);
    V_base = mpc.bus(1,BASE_V);
    Length_in_meter = pjm_line.SHAPE_Length(i);
    RateA = pjm_line.ratingA(i);
    [R, X, B, P_max] = estimate_line_params(V_line, Length_in_meter, RateA);
    [R_pu, X_pu, B_pu] = linePU(R, X, B, V_line, V_base, mpc.baseMVA);
    mpc.branch(i, [3, 4, 5, 6]) = [R_pu, X_pu, B_pu, P_max];
    mpc.branch(i, [11,12,13]) = [1,-360,360];
end

%% Create the gen data
% Load generator data
pjm_power = readtable('data/pjm_power.csv');
pjm_power.Var1 = [];
pjm_power.Longitude = [];
pjm_power.Latitude = [];
columnNames = pjm_power.Properties.VariableNames;

pjm_power = table2array(pjm_power);
pjm_power(isnan(pjm_power)) = 0;

% Correct generator zone IDs
ZONE_ID_INDEX = 13;
for i = 1:size(pjm_power,1)
    pjm_power(i,ZONE_ID_INDEX) = correct_zone_ID(pjm_power(i,ZONE_ID_INDEX));
end

% Aggregate generator data by zone
SOURCE_TYPE = 1:12;
unique_zone_ID = unique(pjm_power(:, ZONE_ID_INDEX));
num_zones = length(unique_zone_ID);
pjm_sum_gen = zeros(num_zones, size(pjm_power, 2)); % Preallocate memory for aggregation

for i = 1:num_zones
    mid_index = pjm_power(:, ZONE_ID_INDEX) == unique_zone_ID(i);
    pjm_sum_gen(i, ZONE_ID_INDEX) = unique_zone_ID(i); % Store zone ID
    pjm_sum_gen(i, SOURCE_TYPE) = sum(pjm_power(mid_index, SOURCE_TYPE), 1); % Sum data for each month
end

% Moeve the aggregated gen data to MPC
NGX   = size(mpc.gen,2);
INI_SERVICE = 8;
PGMAX = 9;
PGMIN = 10;
n = 0;
for i = 1:size(pjm_sum_gen,1)
    for j = SOURCE_TYPE
        if pjm_sum_gen(i,j) ~=0
            n = n + 1;
            mpc.gen(n,:) = zeros(1,NGX);
            mpc.gen(n, 1) = pjm_sum_gen(i,ZONE_ID_INDEX);
            mpc.gen(n, INI_SERVICE) = 1;
            mpc.gen(n, PGMAX) = pjm_sum_gen(i,j);
            mpc.fuel_type{n,1} = columnNames{j};
            if strcmp(columnNames{j}, 'Bat_MW')
                mpc.gen(n, PGMIN) = -pjm_sum_gen(i,j);
                cost_a = 0;
                cost_b = 0.001;
                mpc.gencost(n,:) = [2 0 0 3 cost_a cost_b 0];
            else
                cost_a = unifrnd(0.01,0.02);
                cost_b = unifrnd(35,45);
                mpc.gencost(n,:) = [2 0 0 3 cost_a cost_b 0];
            end
        end
    end
end
%% Estimated Interface
% Accoring to the "Interregional Data Map" and "System Map" 
% in PJM DATA MINER 2
% The interfaces are treated as bi-direction generators

% PSEG-> NYISO InterfaceLimits = 2000 MW
% JCPL -> NYISO InterfaceLimits = 1500 MW
% DOM  -> SOUTH InterfaceLimits = 2500 MW
% AEP  -> SOUTH InterfaceLimits = 1000 MW
% AEP  -> MISO  InterfaceLimits = 3500 MW
% EKPC -> MISO  InterfaceLimits = 500 MW

NIT = 6;
n = size(mpc.gen, 1);
ZONE_NAME = {'PSEG','JCPL','DOM','AEP','AEP','EKPC'};
INTERFACE_NAME = {'INTER_NYISO_1', 'INTER_NYISO_2', 'INTER_SOUTH_1', ...
    'INTER_SOUTH_2','INTER_MISO_1','INTER_MISO_2'};

INTER_PMAX = [2000, 1500, 2500, 1000, 3500, 500]';
TYPICAL_LMP = [39.21, 45.96, 34.7, 34.7, 33.58, 33.1]'; % $/MWh

for i = 1:NIT
    n = n + 1;
    mpc.gen(n,:) = zeros(1,NGX);
    mpc.gen(n, 1) = find(strcmp(mpc.bus_name, ZONE_NAME{i}));
    mpc.gen(n, INI_SERVICE) = 1;
    mpc.gen(n, PGMAX) = INTER_PMAX(i);
    mpc.gen(n, PGMIN) = -INTER_PMAX(i);
    mpc.fuel_type{n,1} = INTERFACE_NAME{i};
    cost_a = 0;
    cost_b = TYPICAL_LMP(i);
    mpc.gencost(n,:) = [2 0 0 3 cost_a cost_b 0];
end

%% Save the case
filename = 'case21pjm';
save_mpc_to_mfile(mpc, filename);

%% Test and correction

mpc = case21pjm;
% sol = dc_opf_lines(mpc);
sol = rundcopf(mpc);
