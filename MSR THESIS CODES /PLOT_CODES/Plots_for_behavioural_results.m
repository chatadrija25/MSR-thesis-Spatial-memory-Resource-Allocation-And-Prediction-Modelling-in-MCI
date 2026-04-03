% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
%Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% All the plots related to behaviour across trials and groups. 

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% NAVIGATIONAL LOAD 

dataTable = readtable('/Users/adrijachatterjee/Downloads/Final_sheet_smallest_updated_1.xlsx');
data{1,4}=27;
% dataTable.MMSE(1) = 22;
% dataTable.MMSE(36) = 27;
participants = unique(dataTable.P_ID);
n = numel(participants);
healthy_high = [];  % To store high load DNT for healthy participants
healthy_low = [];   % To store low load DNT for healthy participants
mci_high = [];      % To store high load DNT for MCI participants
mci_low = [];       % To store low load DNT for MCI participants
%%
for i = 1:n
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    mmse = dataTable.MMSE(rows); 
    % dnt = dataTable.DNT(rows);    
    AE= dataTable.AngleError(rows);
    
    % Calculate high and low load DNT
    hightr = mean([AE(4,1), AE(5,1)]);  % Average of high load trials
    lowtr = mean([AE(2,1), AE(3,1)]);   % Average of low load trials
    
    % Check MMSE score and assign group
    if mmse > 22  % Healthy condition
        healthy_high = [healthy_high; hightr];  % Append high load DNT for Healthy
        healthy_low = [healthy_low; lowtr];     % Append low load DNT for Healthy
    else  % MCI condition
        mci_high = [mci_high; hightr];          % Append high load DNT for MCI
        mci_low = [mci_low; lowtr];             % Append low load DNT for MCI
    end
end

% Calculate averages and standard deviations
healthy_high_avg = mean(healthy_high,"omitnan"); % Average high load DNT for Healthy group
healthy_high_std = std(healthy_high,"omitnan");    % Std dev for high load Healthy
healthy_low_avg = mean(healthy_low,"omitnan");    % Average low load DNT for Healthy group
healthy_low_std = std(healthy_low,"omitnan");    % Std dev for low load Healthy

mci_high_avg = mean(mci_high,"omitnan");          % Average high load DNT for MCI group
mci_high_std = std(mci_high,"omitnan");           % Std dev for high load MCI
mci_low_avg = mean(mci_low,"omitnan");            % Average low load DNT for MCI group
mci_low_std = std(mci_low,"omitnan");             % Std dev for low load MCI

% X-axis as categorical
load_levels = categorical({'Low Load', 'High Load'});
load_levels = reordercats(load_levels, {'Low Load', 'High Load'});  % Ensure correct order

% Plot Healthy group
figure;
hold on;
% errorbar(load_levels, [healthy_low_avg, healthy_high_avg], [healthy_low_std, healthy_high_std], '-o', ...
%     'Color', [0, 0.5, 0], 'DisplayName', 'Healthy', 'LineWidth', 1.5);

% Plot MCI group
errorbar(load_levels, [mci_low_avg, mci_high_avg], [mci_low_std, mci_high_std], '-o', ...
    'Color', [0.75, 0, 0], 'DisplayName', 'MCI', 'LineWidth', 1.5);

% Customize the plot
legend('show','Fontsize',20);
xlabel('Navigational Load Levels','Fontsize',20);
ylabel('Egocentric Angle Error','Fontsize',20);
title('Egocentric Angle Error for Healthy and MCI Participants Across Navigational Load Levels','Fontsize',20);
ax = gca; % Get current axes
ax.XAxis.FontSize = 20; 
ax.YAxis.FontSize = 20; 
grid on;              
hold off;

%%

% dataTable = readtable('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/DNTvsAngle_egoallo_complete_mmse.xlsx');
% data{1,4}=27;
% dataTable.MMSE(1) = 22;
% dataTable.MMSE(36) = 27;
% participants = unique(dataTable.P_ID);
% n = numel(participants);
healthy_AE = [];  % To store DNT for healthy participants
mci_AE = [];      % To store DNT for MCI participants
healthy_trials = [0,1,2,3,4]; % Store corresponding trials for Healthy participants
mci_trials = [0,1,2,3,4];     % Store corresponding trials for MCI participants

% Loop through each participant
for i = 1:n
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    mmse = dataTable.MMSE(rows);  % Get MMSE score
    AE = dataTable.AlloAngleError(rows);    % Get DNT values for the participant
    % dnt= dataTable.DNT(rows);
    % disp(participant);
    % Check MMSE score and assign group
    if mmse > 22  % Healthy condition
        healthy_AE = [healthy_AE; AE'];  % Append DNT values for Healthy
    else  % MCI condition
        mci_AE = [mci_AE; AE'];           % Append DNT values for MCI
    end
end

% Calculate average DNT for each group across trials (0 to 4)
healthy_avg_dnt = mean(healthy_AE, 1,'omitnan');  % Average DNT for Healthy group
mci_avg_dnt = mean(mci_AE, 1,'omitnan');          % Average DNT for MCI group
healthy_std_dnt = std(healthy_AE,'omitnan');
mci_std_dnt= std(mci_avg_dnt,'omitnan');

trials = 0:4;

% Plot Healthy group average DNT
figure;
hold on;
% plot(healthy_trials, healthy_avg_dnt, '-o', 'Color', [0, 0.5, 0], 'DisplayName', 'Healthy');
% errorbar(trials, healthy_avg_dnt, healthy_std_dnt, '-o', ...
%     'Color', [0, 0.5, 0], 'DisplayName', 'Healthy', 'LineWidth', 1.5);
% 
% Plot MCI group average DNT
plot(mci_trials, mci_avg_dnt, '-o', 'Color', [0.75, 0, 0], 'DisplayName', 'MCI');
errorbar(trials, mci_avg_dnt, mci_std_dnt, '-o', ...
    'Color', [0.75, 0, 0], 'DisplayName', 'MCI', 'LineWidth', 1.5);

% Customize the plot
% legend('show');
xlabel('Trials','Fontsize',20);
ylabel('Average Angle Error','Fontsize',20);
title('Average Allocentric Angle Error Across Trials for MCI and Healthy Participants','Fontsize',20);
xticks(trials);  % Set the x-axis for trials 0-4
ax = gca; % Get current axes
ax.XAxis.FontSize = 20; % Font size for group labels on x-axis
ax.YAxis.FontSize = 20; % Font size for tick labels on y-axis
grid on;              
hold off;

%% SWITCH BETWEEN ALLO AND EGO 

% dataTable=readtable('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/DNTvsAngle_egoallo_complete_mmse.xlsx');
dataTable= readtable('/Users/adrijachatterjee/Downloads/Model_sheet.xlsx');

% dataTable{1,4}=27;
% participants = unique(dataTable.P_ID);
% colors = hsv(24); % 
% n=numel(participants);
% trialColumn = repmat((0:4)', n, 1);
% dataTable.Trial = trialColumn;
% AE = dataTable.AngleError;
% AlloAE = dataTable.AlloAngleError;
% diff_AE = AlloAE - AE;    
% dataTable.Diff_AE = diff_AE; 

%% AVERAGE ACROSS TRIALS 

avg_across_trials=[];
std_across_trials=[];

for i = 0:4
     rows = dataTable.Trial == i;
    % dnt = dataTable.DNT(rows);
     trial_diff= dataTable.Switch(rows);

     validrows= ~isnan(trial_diff);
     trial_diff= trial_diff(validrows);
     avg_trial= mean(trial_diff,1);
     st_trial= std(trial_diff,1);
     avg_across_trials=[avg_across_trials; avg_trial];
     std_across_trials=[std_across_trials; st_trial];
    % plot(trials, diff, '-o', 'Color',colors(i, :), 'DisplayName', participant);
end


%%
figure;
errorbar(0:4, avg_across_trials, std_across_trials, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b');

% Customize the plot
xlabel('Trial', 'FontSize', 20);
ylabel('Switch', 'FontSize', 20);
title('Switch Across Trials', 'FontSize', 20);
xticks(0:4);  % Set x-axis ticks for each trial
ax = gca;  % Get current axes
ax.XAxis.FontSize = 20;  % Font size for group labels on x-axis
ax.YAxis.FontSize = 20;  % Font size for tick labels on y-axis
grid on;
hold off;

%% SWITCH ACROSS TRIALS- HEALTHY VS MCI 

% dataTable = readtable('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/Final_sheet_smallest.xlsx');
% dataTable{1,4}=27;
% dataTable.MMSE(1) = 22;
% dataTable.MMSE(36) = 27;


%%
participants = unique(dataTable.P_ID);
colors = hsv(24); % 
n=numel(participants);
trialColumn = repmat((0:4)', n, 1);
dataTable.Trial = trialColumn;
AE = dataTable.AngleError;
AlloAE = dataTable.AlloAngleError;
diff_AE = AlloAE - AE;    
dataTable.Diff_AE = diff_AE; 

%%
load('merged_table.mat');
dataTable= merged_table;
avg_healthy = [];
std_healthy = [];
avg_mci = [];
std_mci = [];


for i = 0:4
    rows = dataTable.Trial == i;
    trial_diff = dataTable.Switch(rows);
     
    validrows = ~isnan(trial_diff);
    trial_diff = trial_diff(validrows);

    mmse_scores = dataTable.MMSE(rows); 
    mmse_scores = mmse_scores(validrows);
    
    healthy_diff = trial_diff(mmse_scores > 22);
    mci_diff = trial_diff(mmse_scores <= 22);
    
    avg_healthy = [avg_healthy; mean(healthy_diff, 1)];
    std_healthy = [std_healthy; std(healthy_diff, 1)];
    avg_mci = [avg_mci; mean(mci_diff, 1)];
    std_mci = [std_mci; std(mci_diff, 1)];
end

figure;
errorbar(0:4, avg_healthy, std_healthy, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0.0,0.5,0.0], 'DisplayName', 'Healthy');
hold on;
errorbar(0:4, avg_mci, std_mci, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0.75,0.0,0.0], 'DisplayName', 'MCI');
xlabel('Trial', 'FontSize', 20);
ylabel('Switch', 'FontSize', 20);
title('Switch Across Trials for Healthy and MCI Groups', 'FontSize', 20);
xticks(0:4); 
legend('show', 'FontSize', 20);
ax = gca;  
ax.XAxis.FontSize = 20;  
ax.YAxis.FontSize = 20;  
grid on;
hold off;

%% Switch after grouping into loads - mci vs healthy 

MMSE= dataTable.MMSE;
MMSE_n= dataTable(dataTable.MMSE>22,:);
validrows= ~isnan(MMSE_n.AlloAngleError)
MMSE_h= MMSE_n(validrows,:);

healthy_high_load=  MMSE_h(MMSE_h.Trial > 2, :).Diff_AE;
MCI_low_load =  MMSE_h(MMSE_h.Trial > 2, :).Diff_AE;

avg_hh= mean(healthy_high_load,1);
avg_hl= mean(MCI_low_load,1);

std_hh= std(healthy_high_load);
std_hl=std(MCI_low_load);

%FOR MCI 

MMSE_M= dataTable(dataTable.MMSE<=22,:);
validrows= ~isnan(MMSE_M.AlloAngleError)
MMSE_M= MMSE_M(validrows,:);

MCI_high_load= MMSE_M(MMSE_M.Trial > 2, :).Diff_AE;
MCI_low_load = MMSE_M(MMSE_M.Trial > 0, :).Diff_AE;

avg_mh= mean(MCI_high_load,1);
avg_ml= mean(MCI_low_load,1);

std_hh= std(MCI_high_load);
std_hl=std(MCI_low_load);

%%
load_levels=  categorical({'Low Load', 'High Load'});
load_levels = reordercats(load_levels, {'Low Load', 'High Load'});  % Ensure correct order

figure;
errorbar(load_levels, [avg_hl, avg_hh], [std_hl, std_hh], '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color',[0.0,0.5,0.0] , 'DisplayName', 'Healthy');
hold on;
errorbar(load_levels, [avg_ml, avg_mh], [std_hl, std_hh], '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0.75,0.0,0.0], 'DisplayName', 'MCI');
xlabel('Load Level', 'FontSize', 20);
ylabel('Average Angle Error Difference (AlloAE - AE)', 'FontSize', 20);
title('Angle Error Difference for Healthy and MCI Groups Across Load Levels', 'FontSize', 20);
xticks(load_levels);
xticklabels({'Low Load', 'High Load'});
% xlim([2-0.5, 4+0.5]);
legend('show', 'FontSize', 20);
ax = gca;
ax.XAxis.FontSize = 20;
ax.YAxis.FontSize = 20;
grid on;
hold off;

%% error accumulation check 

dataTable = readtable('/Users/adrijachatterjee/Downloads/Final_sheet_smallest_updated_1.xlsx');
dataTable{1,4}=27;
participants = unique(dataTable.P_ID);
colors = hsv(24); % 
n=numel(participants);
error_tab = cell(5, n); 

for i = 1:24
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    egoerror= dataTable.AngleError(rows);
    error_acc = NaN(4,1); 
    error_acc(1)= egoerror(2);
    for j= 2:4
        error_acc(j)= egoerror(j+1)-egoerror(j);
    end 
    error_tab{1, i} = participant; 
    error_tab(2:5, i) = num2cell(error_acc);  
    % 
end

error_tab= error_tab';
%% 
%********************** HIT/MISS LANDMARK TASK ********************************

% landmark= dataTable.Landmark;
% search="H";
% hit_h = dataTable(dataTable.Landmark == search, :);
% miss_h=dataTable(dataTable.Landmark=="M",:);
% hit_healthy= hit_h(hit_h.MMSE>22,:);
% miss_healthy=miss_h(miss_h.MMSE>22,:);
% 
% hit_m = dataTable(dataTable.Landmark == search, :);
% miss_m=dataTable(dataTable.Landmark=="M",:);
% hit_healthy= hit_m(hit_m.MMSE<=22,:);
% miss_healthy=miss_m(miss_m.MMSE<=22,:);

%%

% Separate data based on Landmark (Hit = 'H', Miss = 'M') out of which - 32
% are NA; Total- 47 hits and 41 misses 

dataTable=readtable('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/DNTvsAngle_egoallo_complete_mmse.xlsx');
trialColumn = repmat((0:4)', 24, 1);
dataTable.Trial = trialColumn;
trials = unique(dataTable.Trial); 

hit_data = dataTable(strcmp(dataTable.Landmark, 'H'), :);
miss_data = dataTable(strcmp(dataTable.Landmark, 'M'), :);

% Split data into Healthy and MCI groups for Hit and Miss
hit_healthy = hit_data(hit_data.MMSE > 22, :); 
hit_mci = hit_data(hit_data.MMSE <= 22, :);
miss_healthy = miss_data(miss_data.MMSE > 22, :);
miss_mci = miss_data(miss_data.MMSE <= 22, :);

proportion_hit_healthy = [];
proportion_miss_healthy = [];
proportion_hit_mci = [];
proportion_miss_mci = [];

for t = trials'
    total_healthy = sum(hit_healthy.Trial == t) + sum(miss_healthy.Trial == t);
   
    if total_healthy > 0
        proportion_hit_healthy = [proportion_hit_healthy; sum(hit_healthy.Trial == t) / total_healthy];
        proportion_miss_healthy = [proportion_miss_healthy; sum(miss_healthy.Trial == t) / total_healthy];
    else
        proportion_hit_healthy = [proportion_hit_healthy; NaN];
        proportion_miss_healthy = [proportion_miss_healthy; NaN];
    end
    
    total_mci = sum(hit_mci.Trial == t) + sum(miss_mci.Trial == t);
    
    if total_mci > 0
        proportion_hit_mci = [proportion_hit_mci; sum(hit_mci.Trial == t) / total_mci];
        proportion_miss_mci = [proportion_miss_mci; sum(miss_mci.Trial == t) / total_mci];
    else
        proportion_hit_mci = [proportion_hit_mci; NaN];
        proportion_miss_mci = [proportion_miss_mci; NaN];
    end
end

% disp(table(trials, proportion_hit_healthy, proportion_miss_healthy, ...
%            proportion_hit_mci, proportion_miss_mci, ...
%            'VariableNames', {'Trial', 'Hit_Healthy', 'Miss_Healthy', 'Hit_MCI', 'Miss_MCI'}));

figure;

subplot(1, 2, 1);
hold on;
plot(trials, proportion_hit_healthy, '-o', 'LineWidth', 2, 'Color', 'g', 'DisplayName', 'Hit (Healthy)');
plot(trials, proportion_hit_mci, '-o', 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'Hit (MCI)');
xlabel('Trials');
ylabel('Proportion');
title('Proportion of Hit for Healthy VS MCI Groups');
legend('show');
grid on;

subplot(1, 2, 2);
hold on;
plot(trials, proportion_miss_healthy, '-o', 'LineWidth', 2, 'Color', 'r', 'DisplayName', 'Miss (MCI)');
plot(trials, proportion_miss_mci, '-o', 'LineWidth', 2, 'Color', 'm', 'DisplayName', 'Miss (MCI)');
xlabel('Trials');
ylabel('Proportion');
title('Proportion of Miss for Healthy VS MCI Groups');
legend('show');
grid on;

%% Visualisation of switch-- 
%---- if egoAE< alloAE, then 1 
%---- if alloAE<egoAE, then 0 
%--- if any of the value is Nan, that trial is eliminated or taken as NaN. 

% ************      PLOTTING ACROSS TRIALS     ****************************
dataTable= readtable('/Users/adrijachatterjee/Downloads/Model_sheet.xlsx');
dataTable{1,4}=27;
% dataTable.MMSE(1) = 22;
% dataTable.MMSE(36) = 27;
participants = unique(dataTable.P_ID);
colors = hsv(24); % 
n=numel(participants);
trialColumn = repmat((0:4)', n, 1);
dataTable.Trial = trialColumn;
AE = dataTable.AngleError;
AlloAE = dataTable.AlloAngleError;
diff_AE = AlloAE - AE;    
dataTable.Diff_AE = diff_AE; 

trials=0:4;

switch_nav_table = array2table(nan(length(trials), n), 'VariableNames', participants);

for i = 1:n
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    participant_AE = dataTable.AngleError(rows);
    participant_AlloAE = dataTable.AlloAngleError(rows);
    participant_trials = dataTable.Trial(rows);
    ppt_ego= dataTable.Egotype(rows);
    
    
    switch_nav = nan(size(trials));
    for t=trials
        trial_rows = participant_trials == t; % Get rows for this trial
        if any(trial_rows) 
           if (isnan(participant_AlloAE(trial_rows))) && (ppt_ego(trial_rows)<0.5)
              switch_nav(t+1) = 1; % ego preference.. missed the allo angle
              % continue;
           elseif (participant_AE(trial_rows) < participant_AlloAE(trial_rows)) && (ppt_ego(trial_rows)<0.5)
                switch_nav(t+1) = 1; % ego preference
           elseif (participant_AlloAE(trial_rows) < participant_AE(trial_rows)) && (ppt_ego(trial_rows)>0.5)
                switch_nav(t+1) = 1;
           else 
               switch_nav(t+1)=0;
            end
        end
    
    end
    switch_nav_table{:, participant} = switch_nav';
% switch_nav_table = addvars(switch_nav_table, trials', 'Before', 1, 'NewVariableNames', 'Trials');
end
%%
% % mean across rows 
% mean_trials= mean(switch_nav_table{:, :}, 1,'omitnan');
% mean_row = array2table(mean_trials, 'VariableNames', switch_nav_table.Properties.VariableNames);
% switch_nav_table = [switch_nav_table; mean_row];

row_means = mean(switch_nav_table{:, :}, 2,'omitnan');
errorbrs= std(switch_nav_table{:, :},0, 2,'omitnan');
switch_nav_table.Acrosstrials = row_means;
switch_nav_table.StdAcrosstrials = errorbrs;

figure;
errorbar(trials, row_means, errorbrs, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b');
xlabel('Trials','FontSize', 20);
ylabel('Switch Navigation (Mean ± SD)','FontSize', 20);
title('Switch Navigation Across Trials','FontSize', 20);
xticks(trials); 
grid on;
ax = gca;  % Get current axes
ax.XAxis.FontSize = 20; 
ax.YAxis.FontSize = 20;  
grid on;

%%

healthy_participants = unique(dataTable.P_ID(dataTable.MMSE > 22));
healthy_switch_nav_table = switch_nav_table(:, ismember(switch_nav_table.Properties.VariableNames, healthy_participants));
mci_participants = unique(dataTable.P_ID(dataTable.MMSE <= 22));
mci_switch_nav_table = switch_nav_table(:, ismember(switch_nav_table.Properties.VariableNames, mci_participants));

%%


healthy_row_means = mean(healthy_switch_nav_table{:, :}, 2, 'omitnan');
healthy_errorbrs = std(healthy_switch_nav_table{:, :}, 0, 2, 'omitnan');

healthy_switch_nav_table.Acrosstrials = healthy_row_means;
healthy_switch_nav_table.StdAcrosstrials = healthy_errorbrs;

mci_row_means = mean(mci_switch_nav_table{:, :}, 2, 'omitnan');
mci_errorbrs = std(mci_switch_nav_table{:, :}, 0, 2, 'omitnan');

mci_switch_nav_table.Acrosstrials = mci_row_means;
mci_switch_nav_table.StdAcrosstrials = mci_errorbrs;

figure;

% Plot for Healthy participants
subplot(1, 2, 1); 
errorbar(trials, healthy_row_means, healthy_errorbrs, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'g');
xlabel('Trials');
ylabel('Switch Navigation (Mean ± SD)','FontSize',20);
title('Healthy Participants','FontSize',20);
xticks(trials);
ax = gca;  % Get current axes
ax.XAxis.FontSize = 20; 
ax.YAxis.FontSize = 20;  
grid on;


% Plot for MCI participants

subplot(1, 2, 2); 
errorbar(trials, mci_row_means, mci_errorbrs, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'r');
xlabel('Trials');
ylabel('Switch Navigation (Mean ± SD)','FontSize',20);
title('MCI Participants','FontSize',20);
xticks(trials);
ax = gca;  % Get current axes
ax.XAxis.FontSize = 20; 
ax.YAxis.FontSize = 20;  
grid on;

%%
hit_data = dataTable(strcmp(dataTable.Landmark, 'H'), :);
miss_data = dataTable(strcmp(dataTable.Landmark, 'M'), :);

% Split data into Healthy and MCI groups for Hit and Miss
hit_healthy = hit_data(hit_data.MMSE > 22, :); 
hit_mci = hit_data(hit_data.MMSE <= 22, :);
miss_healthy = miss_data(miss_data.MMSE > 22, :);
miss_mci = miss_data(miss_data.MMSE <= 22, :);

% Initialize variables to store counts across trials
trials = unique(dataTable.Trial); % Assume trials are labeled numerically
count_hit_healthy = [];
count_miss_healthy = [];
count_hit_mci = [];
count_miss_mci = [];

% Loop through each trial and count occurrences for each group
for t = trials'
    % Healthy group
    count_hit_healthy = [count_hit_healthy; sum(hit_healthy.Trial == t)];
    count_miss_healthy = [count_miss_healthy; sum(miss_healthy.Trial == t)];
    
    % MCI group
    count_hit_mci = [count_hit_mci; sum(hit_mci.Trial == t)];
    count_miss_mci = [count_miss_mci; sum(miss_mci.Trial == t)];
end
%%

figure;
plot(trials, count_hit_healthy, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'g', 'DisplayName', 'Healthy (Hit)');
hold on;
plot(trials, count_miss_healthy, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'b', 'DisplayName', 'Healthy (Miss)');

plot(trials, count_hit_mci, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'r', 'DisplayName', 'MCI (Hit)');
plot(trials, count_miss_mci, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'black', 'DisplayName', 'MCI (Miss)');

xlabel('Trials', 'FontSize', 20);
ylabel('Count', 'FontSize', 20);
title('Hit vs. Miss Counts Across Trials for Healthy and MCI Groups', 'FontSize', 20);
legend('show', 'FontSize', 14, 'Location', 'best');
xticks(trials);  
ax = gca;
ax.XAxis.FontSize = 16; 
ax.YAxis.FontSize = 16; 
grid on;
hold off;


%%





