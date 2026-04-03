% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
%Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% All the plots related to EGG power across bands, trials and groups. 

% For every participant, we had 4 files - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data for experiment. From
% that, we got their trial data across these 4 bands and calculated power and saved both.

% this data is obtained from the struct- EEG_master_array_latest and used accordingly. 

% For selection of best electrode for every participant- see code EGG_select_electrode. 
% Best electrode is the one with highest power in the broadband range. 
% For filtering across bands, see code filt_tbnbr- filters the data - tachy, brady, normo, broad. 
% Uses padding and 50% window overlap to increase resolution. 
% 3. For power calculation- see code power_spec.m- to calculate power spectrum. 
% It is a function, which takes the signal and the returns the maximum power (if there are multiple peaks, 
% returns the max among those).
% 4. For calculating baseline power for 4 bands check code- baseline_4bands.

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% loading the final struct with trials and bandpowers 

load('Final_EGG_str.mat'); % from EEG_master_array_latest. 

%%
list = ["F5";"F6";"F7";"F8";"F10";"F11";"F12";"M6";"M7";"M8";"M9";"M10";"M11" ;"M12" ;"M13" ;"M14";"M15"];
bands = {'broad', 'brady', 'tachy', 'normo'};
nbands = numel(bands);
nppt = length(list);
trials = 5;

pwr_table = table(); %final table with all participants 

for i = 1:nppt
    ppt = list{i}; 
    participant_data = NaN(trials, nbands); 

    for j = 1:nbands
        band = bands{j}; 
        pow_band = NaN(trials, 1); 

        % Loop over all trials
        for tri = 1:trials
            trial = append('trial', num2str(tri), '_power');
            if isfield(Final.(ppt).(band), trial)
                trial_pow = Final.(ppt).(band).(trial);
                pow_band(tri) = trial_pow; %as pow_band is a column vector, tri means rows
                %form of row indexing.
            end
        end %trial 
        participant_data(:, j) = pow_band; %now it will store according to bands 
    end %bands 

    % Array to table 
    participant_table = array2table(participant_data, ...
        'VariableNames', bands); 
    participant_table.Participant = repmat(string(ppt), trials, 1); 
    %repeats a given input array- repeats ppt for 5 times- last two are
    %dim- 5x1 
    participant_table.Trial = (1:trials)'; %converts row into column
    pwr_table = [pwr_table; participant_table]; %appends 
end %ppt

% Rearrange columns to have Participant and Trial first
pwr_table = pwr_table(:, ['Participant', 'Trial', bands]);

%% PLOTTING POWER ACROSS BANDS 

broad_data = pwr_table.broad;
brady_data = pwr_table.brady;
tachy_data = pwr_table.tachy;
normo_data = pwr_table.normo;

% removing NaN values
broad_data = broad_data(~isnan(broad_data));
brady_data = brady_data(~isnan(brady_data));
tachy_data = tachy_data(~isnan(tachy_data));
normo_data = normo_data(~isnan(normo_data));

all_data = [broad_data, brady_data, tachy_data, normo_data];


% calculate mean and std error 
means = [mean(broad_data), mean(brady_data), mean(tachy_data), mean(normo_data)];
std_err = [std(broad_data)/sqrt(length(broad_data)), ...
           std(brady_data)/sqrt(length(brady_data)), ...
           std(tachy_data)/sqrt(length(tachy_data)), ...
           std(normo_data)/sqrt(length(normo_data))];



figure;
boxplot(all_data, 'Labels', {'Broad', 'Brady', 'Tachy', 'Normo'}, 'Widths', 0.5);


% error bars
% x_positions = 1:4; % no. of labels on x-axis
% errorbar(x_positions, means, std_err, 'o', 'MarkerSize', 8, ...
%     'LineWidth', 1.5, 'Color', 'b', 'CapSize', 10);

% Customize the plot
title('Boxplots of Bands','FontSize', 20);
xlabel('Bands','FontSize', 20);
ylabel('Normalised Power Values(Baseline substracted)','FontSize', 20);

ax = gca; % Get current axes
ax.XAxis.FontSize = 20; % Font size for group labels on x-axis
ax.YAxis.FontSize = 20; % Font size for tick labels on y-axis

grid on;
%% DNT accuracies and Normo percentage 

% try with normo power as well**
load('merged_table.mat');
% Healthy, low DNT
normo_healthy_lowdnt = merged_table.normo( ...
    merged_table.MMSE > 22 & merged_table.dntcond == 0 & ...
    ~isnan(merged_table.normo));

% Healthy, high DNT
normo_healthy_highdnt = merged_table.normo( ...
    merged_table.MMSE > 22 & merged_table.dntcond == 1 & ...
    ~isnan(merged_table.normo));

% MCI, high DNT
normo_MCI_highdnt = merged_table.normo( ...
    merged_table.MMSE <= 22 & merged_table.dntcond  == 1 & ...
    ~isnan(merged_table.normo));

% MCI, low DNT
normo_MCI_lowdnt = merged_table.normo( ...
    merged_table.MMSE <= 22 & merged_table.dntcond  == 0 & ...
    ~isnan(merged_table.normo));

means= [mean(normo_MCI_highdnt), mean(normo_MCI_lowdnt) mean(normo_healthy_highdnt), mean(normo_healthy_lowdnt)]

std_err = [std(normo_MCI_highdnt)/sqrt(length(normo_MCI_highdnt)), ...
           std(normo_MCI_lowdnt)/sqrt(length(normo_MCI_lowdnt)), ...
           std(normo_healthy_highdnt)/sqrt(length(normo_healthy_highdnt)), ...
           std(normo_healthy_lowdnt)/sqrt(length(normo_healthy_lowdnt))];

accuracy_levels = categorical({'Low Load', 'High Load'});
accuracy_levels = reordercats(accuracy_levels, {'Low Load', 'High Load'});  % Ensure correct order


figure;
hold on;

% Healthy group
errorbar(accuracy_levels, [means(4), means(3)], [std_err(4), std_err(3)], '-o', ...
    'Color', [0, 0.5, 0], 'DisplayName', 'Healthy', 'LineWidth', 1.5);

% MCI group
errorbar(accuracy_levels, [means(2), means(1)], [std_err(2), std_err(1)], '-o', ...
    'Color', [0.7, 0, 0], 'DisplayName', 'MCI', 'LineWidth', 1.5);

ylabel('Normogastric Power (Normalised and Baseline subtracted)');
xlabel('Working memory task Loads');
legend('Location', 'best','FontSize', 16);
title('Normogastric Activity Across working memory task Loads and Groups','FontSize', 16);
grid on;
ax = gca; % Get current axes
ax.XAxis.FontSize = 16; % Font size for group labels on x-axis
ax.YAxis.FontSize = 16; % Font size for tick labels on y-axis
hold off;

%% POWER ACROSS TRIALS FOR DIFFERENT BANDS 
band_tables = struct();

for band_idx = 1:nbands
    band = bands{band_idx};
   
    band_data = pwr_table(:, {'Participant', 'Trial', band}); % Extract ppt, trial, and current band
    
    band_trials = [];
    participants = unique(band_data.Participant); % Get unique participant IDs
    for ppt_idx = 1:length(participants)
        ppt = participants(ppt_idx); 
        ppt_data = band_data(strcmp(band_data.Participant, ppt), :); 
        
        % Reshape the data: Trials as columns, one row per participant
        ppt_trials = ppt_data{:, band}'; 
        band_trials = [band_trials; ppt_trials]; % Append this participant's trials
    end
    
    % Creating the table for this band
    band_table = array2table(band_trials, 'VariableNames', strcat('Trial', string(1:5)));
    band_table.Participant = participants; % Add participant column
    
    % Creating the table for each band
    band_tables.(band) = band_table;
end
%% PLOTTING 

for band_idx = 1:nbands
    band = bands{band_idx};

    tab= band_tables.(band)(:,1:5); 
    
    figure(band_idx);
    boxplot(tab{:,:}, 'Labels', {'Trial0','Trial1', 'Trial2', 'Trial3', 'Trial4'}, 'Widths', 0.5);
    title(['Boxplots across trials - ', band],'FontSize', 25); 
    xlabel('Trials','FontSize', 25);
    ylabel('Normalised Power Values (Baseline subtracted)','FontSize', 25);
    grid on;
    ax = gca; % Get current axes
    ax.XAxis.FontSize = 16; % Font size for group labels on x-axis
    ax.YAxis.FontSize = 16; % Font size for tick labels on y-axis
    
    grid on;
end

%% CLUSTER-WISE, BAND-WISE PLOTS 

% get the lists- from the other file-  extract those trials- from the EGG
% struct, create a new table- for each cluster- columns- brady,
% normo,tachy, broad 

addpath('/Users/adrijachatterjee/Downloads/clusterlists.mat');

%%
% converting participant columns into string and trials into numeric for
% easier comparision.
cl4 = cell2table(lists4); 
cl4.Participant = string(cl4{:, 1}); 
cl4.Trial = double(cl4{:, 2});    
participants = string(pwr_table.Participant); 
trials = pwr_table.Trial;                     

cluster4_table = []; %final table for cluster1.

for cl = 1:height(cl4)
    ppt = cl4.Participant(cl); 
    trial = cl4.Trial(cl);     
    if any(participants == ppt & trials == trial)
        match_idx = (participants == ppt) & (trials == trial); 
        extracted_data = pwr_table(match_idx, :);
        % Append to the filtered table
        if isempty(cluster4_table)
            cluster4_table = extracted_data; % Initialize with the first match
        else
            cluster4_table = [cluster4_table; extracted_data]; % Append matches
        end
    else
        continue;
    end
end


%% PLOTTING CLUSTER 1 BOXPLOT 

cluster4_data = table2array(cluster4_table(:, 3:6));

figure;
boxplot(cluster4_data, 'Labels', {'Broad', 'Brady', 'Tachy', 'Normo'}, 'Widths', 0.5);
title(['Boxplots across trials for Cluster 4'],'FontSize', 30); 
xlabel('Trials','FontSize', 30);
ylabel('Normalised Power Values (Baseline subtracted)','FontSize', 30);
ax = gca; % Get current axes
ax.XAxis.FontSize = 16; % Font size for group labels on x-axis
ax.YAxis.FontSize = 16; % Font size for tick labels on y-axis
grid on;

%%
rows= pwr_table.Trial==5
normo_tb= [];
normo_tb5= pwr_table.normo(rows);

%%
load('/Users/adrijachatterjee/Downloads/EGG_wincount.mat');
results.Trial= results.Trial-1;


%%
% Define your percentages

participants= unique(merged_table.P_ID);

for i= 1:length(participants)
    ppt= participants{i};

    figure;
    hold on 
    rows= strcmp(merged_table.P_ID, ppt);
    % Trial is a column in merged table 
    brady = merged_table.Brady_Percentage(8)
    normo = merged_table.Normo_Percentage(8)
    tachy = merged_table.Tachy_Percentage(8)
    
    % X-axis categories (numerical for plotting)
    x = [3, 6, 9];
    y = [brady, normo, tachy];
    
    % Plot the line
    plot(x, y, '-o', 'LineWidth', 2)
    xticks(x)
    xticklabels({'Brady', 'Normo', 'Tachy'})
    ylabel('Percentage')
end
%%
load('merged_table.mat');
participants = unique(merged_table.P_ID);

for i = 1:length(participants)
    ppt = participants{i};

    % Filter rows for this participant
    rows = strcmp(merged_table.P_ID, ppt);
    ppt_data = merged_table(rows, :);

    figure;
    hold on;

    % For each of 5 trials
    trials = unique(ppt_data.Trial);  % assuming 'Trial' is numeric or sortable

    for t = 1:min(5, length(trials))
        trial_data = ppt_data(ppt_data.Trial == trials(t), :);

        % Extract percentages
        brady = trial_data.Brady_Percentage;
        normo = trial_data.Normo_Percentage;
        tachy = trial_data.Tachy_Percentage;

        % X-axis categories (numerical for plotting)
        x = [3, 6, 9];
        y = [brady, normo, tachy];

        % Plot line for this trial
        plot(x, y, '-o', 'LineWidth', 2, 'DisplayName', ['Trial ' num2str(trials(t))]);
    end

    % Customize plot
    xticks(x);
    xticklabels({'Brady', 'Normo', 'Tachy'});
    ylabel('Percentage');
    title(['Participant: ' ppt]);
    legend('show');
    grid on;
end

%%  



