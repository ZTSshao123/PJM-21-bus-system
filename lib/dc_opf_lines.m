function sol = dc_opf_lines(mpc)

% Parameters
SF = makePTDF(mpc);
NG = size(mpc.gen,1);
NB = size(mpc.bus,1);
NL = size(SF, 1);
PD = mpc.bus(:,3);
AG = sparse(mpc.gen(:,1), 1:NG, 1, NB, NG);
Fmax = mpc.branch(:, 6);
PGmax = mpc.gen(:, 9);
M = 100000;
ca = mpc.gencost(:, 5);
cb = mpc.gencost(:, 6);
cc = mpc.gencost(:, 7);

% Variables
pg = sdpvar(NG, 1, 'full');
fr = sdpvar(NL, 1, 'full');
%% Constraints
st = [];
% Balance
st = st + ( sum(pg) == sum(PD) );
% Line limits
st = st + (fr >= 0);
st = st + ( -Fmax - fr <= SF*(AG*pg - PD) <= Fmax + fr);
% Gen capacity
st = st + ( 0 <= pg <= PGmax);
% Cost
obj = pg'*diag(ca)*pg + cb'*pg + sum(cc) + M*sum(fr);

%% Optimize
opts = sdpsettings('solver','gurobi');
sol = optimize(st, obj, opts);
sol.pg = value(pg);
sol.obj = value(obj);
sol.fr = value(fr);
sol.pl = value(SF*(AG*pg - PD));
end
