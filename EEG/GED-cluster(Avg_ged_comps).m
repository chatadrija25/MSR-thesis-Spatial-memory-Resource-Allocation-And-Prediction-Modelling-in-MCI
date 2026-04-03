
% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.

% References: 
% 1. https://github.com/mikexcohen/GED_tutorial
% 2. https://doi.org/10.1016/j.neuroimage.2021.118809              
% Please add the topoplotindie.m file in your path- which is shared in the EEG folder. 

% Generalised Eigen Decomposition (GED) spatially localise the EEG signals
% that orthogonally differentiates the two conditions. 
% Here, we use this to get the difference between task and
% baseline (EEG- resting eyes-open data). 

% We also average the GED values of trials of each behavioural performance clusters to
% find out the signatures specific to performance of people in a cluster. 

% For any query, please contact: 
% Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% 

% save the trials and p_id for each cluster 
% add the 1st component of that to the evecs_sum matrix 
% average over the 2nd dimension 
% use it for plotting the topoplots.

% Has only eeg data collected by mud EEG. 

%addpath('/Users/adrijachatterjee/Downloads/codes');
% F_str1= load('/Users/adrijachatterjee/Downloads/codes/Final_Arrary_complete.mat'); 

%% STRUCT WITH Trial wise EEG data, filtered and ready for direct use:  

F_str1= load('/Users/adrijachatterjee/Downloads/codes/Final_eyecheckGED.mat');
% F_str2= load('/Users/adrijachatterjee/Downloads/FinalRun.mat');

%% Extracting behavioural measures of the trials. 

% we saved it as merged_table later that has every measure(beh, eeg, egg). 

% filename = 'DNTVSAngle3.xlsx';
% Table=readtable('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/DNTvsAngle_complete_mmse.xlsx');
Table = readtable('/Users/adrijachatterjee/Downloads/Final_sheet_smallest_updated_1.xlsx');
Table{1,4}=27;%Convert table to cell array for easier indexing
data1 = table2cell(Table);
% data1{27,1}=40;
% data1{36,1}=100;data1{37,1}=50;data1{38,1}=100;data1{39,1}=100;data1{40,1}=50;
% data1{36,2}=3.016;data1{37,2}=10.579;data1{38,2}=8.327;data1{39,2}=0.362;data1{40,2}=9.79;
% data1{36,3}='M7';data1{37,3}='M7';data1{38,3}='M7';data1{39,3}='M7';data1{40,3}='M7';

dataTable = cell2table(data1, 'VariableNames', {'DNT', 'AngleError', 'P_ID','MMSE','AlloAngleError','Trial','Hit','EgoType'});
% digit numbering task accuracy(DNT),Angle_error(Egocentric error),
% MMSE_score(MMSE), Allocentric error(AlloAngleError), Trial no.(Trial),
% Landmark recognition (Hit), Reference Frame Proclivity(EgoType). 

participants = unique(dataTable.P_ID);
colors = lines(numel(participants));

%%
figure;
hold on;

for i = 1:numel(participants)
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    dnt = dataTable.DNT(rows);
    angleError = dataTable.AngleError(rows);
    plot(dnt, angleError, 'o', 'MarkerEdgeColor', colors(i, :),'MarkerFaceColor', colors(i, :), 'DisplayName', participant);
end
legend('show');
xlabel('DNT accuracy(in %)');
ylabel('Allocentric Angle Error (in degrees)');
title('DNT vs Angle Error for Each Participant');
hold off;
%% for eeg unavailability 

rowstoremove=[1;2;3;4;5;6;7;8;9;10;31;32;33;34;35];
data1(rowstoremove, :) = [];
dataTable = cell2table(data1, 'VariableNames', {'DNT', 'AngleError', 'P_ID','MMSE','AlloAngleError','Trial','Hit','EgoType'});
participants = unique(dataTable.P_ID);
colors = lines(numel(participants));

%% for trial wise MCI and Healthy plots 

for i = 1:numel(participants)
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    dnt = dataTable.DNT(rows);
    angleError = dataTable.AngleError(rows);
    mmse= dataTable.MMSE(rows);
end    

valid_rows_m=dataTable.MMSE<=22; % mci 
valid_rows_h=dataTable.MMSE>22; % Healthy 
MCI= dataTable.P_ID(valid_rows_m);
MCI_list= unique(MCI);

Healthy= dataTable.P_ID(valid_rows_h); 
Healthy_list= unique(Healthy);


%%
figure(8);
hold on;

for i = 1:numel(participants)
    participant = participants{i};
    rows = strcmp(dataTable.P_ID, participant);
    dnt = dataTable.DNT(rows);
    angleError = dataTable.AngleError(rows);
    mmse= dataTable.MMSE(rows);
    
    plot(dnt, angleError, 'o', 'MarkerEdgeColor', colors(i, :),'MarkerFaceColor', colors(i, :), 'DisplayName', participant);
end
legend('show');
xlabel('DNT accuracy(in %)');
ylabel('Allocentric Angle Error (in degrees)');
title('DNT vs Angle Error for Each Participant');
hold off;

%%  
% Initialize cell arrays to store indices
% store_tr1 = {};
% store_tr2 = {};
% store_tr3 = {};

lists1={};  %participant_id, trials
lists2={};
lists3={};
lists4={};
lists5={}; % 5 and 6 for allocentric only 
lists6={};

for i = 1:length(participants) 
    participant = participants{i}; %participant id 
    rows = strcmp(dataTable.P_ID, participant); %finding the rows with that participant id in the dnt vs angle error plot.
    dnt = dataTable.DNT(rows); 
    angleError = dataTable.AngleError(rows);
    %disp(length(dnt))


    
    for j = 1:length(dnt) %length of dnt= no. of trials per participant.
         % Cluster1
        if (dnt(j) < 20) && (angleError(j) < 70)
            lists1{end+1, 1} = participants{i};
            lists1{end, 2} = j;
        end
    
         % Cluster2
         if (dnt(j) > 20) && (dnt(j) < 80) &&  (angleError(j) < 70)
            lists2{end+1, 1} = participants{i};
            lists2{end, 2} = j;
         end

         % Cluster3
         if (dnt(j) > 20) && (dnt(j) < 80) &&  (angleError(j) > 70)
            lists3{end+1, 1} = participants{i};
            lists3{end, 2} = j;
         end

         % Cluster4
         if (dnt(j) > 80) && (angleError(j) < 70)
            lists4{end+1, 1} = participants{i};
            lists4{end, 2} = j;
         end

          % Cluster5
         if (dnt(j) < 20) && (angleError(j) > 70)
            lists5{end+1, 1} = participants{i};
            lists5{end, 2} = j;
        end

          % Cluster6
         if (dnt(j) > 80) && (angleError(j) > 70)
            lists6{end+1, 1} = participants{i};
            lists6{end, 2} = j;
         end

    end
end

%% GED

%cluster 1
band_nm= 'theta';
% evecs1_th=[];
% covS1_th=[];
compmp_cluster1=[];
% executed_trials={};

for d= 1:length(MCI_list)
    ppt_demo= char(MCI_list(d));
    trial_no= 5;
    tr_name = sprintf('Trial%d',trial_no);
    try
        e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
    catch
            continue;
    end

        % colevec= e_tri.evecs(:,1);
        % evecs1_th=[evecs1_th, colevec];
        % covS1= e_tri.covS;
        % covS1_th=[covS1_th, covS1];

        col_compmp1= e_tri.compmap; % 1x9 

        mean_c = mean(col_compmp1,2);
        sd_c= std(col_compmp1, 0, 2);
        col_compmp1_st= (col_compmp1-mean_c)./sd_c;

        compmp_cluster1= [compmp_cluster1; col_compmp1_st];
        compmp_avg1= mean(compmp_cluster1,1);
        % executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};
end


%% Average for a group - MCI or Healthy 

% Average all the trials of a subject 
% Average over all subjects 
% why is this approach followed? Because if any subject has less number of
% useable trials, that will not be overshadowed by a subject with more
% number of trials. 

band_nm= 'theta';
compmp_cluster2 = [];  % will hold all z-scored trials for all subjects
for d = 1:length(MCI_list)
    ppt_demo = char(MCI_list(d));
    trial_range = 2:5;   
    subj_trials = [];

    for t = trial_range
        tr_name = sprintf('Trial%d', t);
        try
            e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
        catch
            continue; % skip if trial missing
        end
        
        % Extract compmap
        col_compmp2 = e_tri.compmap;  % 1x9
        
        % Z-score per trial 
        mean_c = mean(col_compmp2, 2);
        sd_c   = std(col_compmp2, 0, 2);
        col_compmp2_st = (col_compmp2 - mean_c) ./ sd_c;
        
        subj_trials = [subj_trials; col_compmp2_st];  % for an individual. 
    end
    
    if ~isempty(subj_trials)
        %  Average of the z-scored trials for this subject 
        subj_mean = mean(subj_trials, 1);
        
        % Add subject average to cluster
        compmp_cluster2 = [compmp_cluster2; subj_mean];
    end
end

% Grand average across all participants of a group 
compmp_avg2 = mean(compmp_cluster2, 1);

%% for Healthy 

band_nm= 'theta';
compmp_cluster2 = [];  % will hold all z-scored trials for all subjects
for d = 1:length(Healthy_list)
    ppt_demo = char(Healthy_list(d));
    trial_range = 2:5;   
    subj_trials = [];

    for t = trial_range
        tr_name = sprintf('Trial%d', t);
        try
            e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
        catch
            continue; % skip if trial missing
        end
        
        % Extract compmap 
        col_compmp2 = e_tri.compmap;  % 1x9
        
        % Z-score per trial
        mean_c = mean(col_compmp2, 2);
        sd_c   = std(col_compmp2, 0, 2);
        col_compmp2_st = (col_compmp2 - mean_c) ./ sd_c;
        
        subj_trials = [subj_trials; col_compmp2_st];  % for an individual. 
    end
    
    if ~isempty(subj_trials)
        % Average of the z-scored trials for this subject
        subj_mean = mean(subj_trials, 1);
        
        % Add subject average to cluster
        compmp_cluster2 = [compmp_cluster2; subj_mean];
    end
end

% Grand average across all participants of a group
compmp_avg2 = mean(compmp_cluster2, 1);




%% Plotting graphs for four conditions - High - MCI, Low- MCI.

band_nm= 'theta';
compmp_cluster1 = [];  % will hold all z-scored trials for all subjects
for d = 1:length(MCI_list)
    ppt_demo = char(MCI_list(d));
    % trial_range = [3,4];   %LOW
    trial_range= [2,5]; %HIGH
    subj_trials = [];

    for t = 1:length(trial_range)
        tr_name = sprintf('Trial%d', trial_range(t));
        try
            e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
        catch
            continue; % skip if trial missing
        end

        %  Extract compmap 
        col_compmp1 = e_tri.compmap;  % 1x9

        %  Z-score per trial 
        mean_c = mean(col_compmp1, 2);
        sd_c   = std(col_compmp1, 0, 2);
        col_compmp1_st = (col_compmp1 - mean_c) ./ sd_c;

        subj_trials = [subj_trials; col_compmp1_st];  % for an individual. 
    end

    if ~isempty(subj_trials)
        %  Average of the z-scored trials for this subject 
        subj_mean = mean(subj_trials, 1);

        % Add subject average to cluster
        compmp_cluster1 = [compmp_cluster1; subj_mean];
    end
end

%Grand average across all participants of a group 
compmp_avg1 = mean(compmp_cluster1, 1);

%%  High- Healthy, Low- Healthy.


band_nm= 'theta';
compmp_cluster2 = [];  % will hold all z-scored trials for all subjects
for d = 1:length(Healthy_list)
    ppt_demo = char(Healthy_list(d));
    % trial_range = [3,4];   %LOW
    trial_range= [2,5]; %HIGH
    subj_trials = [];

    for t = 1:length(trial_range)
        tr_name = sprintf('Trial%d', trial_range(t));
        try
            e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
        catch
            continue; % skip if trial missing
        end

        % ---- Extract compmap ----
        col_compmp2 = e_tri.compmap;  % 1x9

        % ---- Z-score per trial ----
        mean_c = mean(col_compmp2, 2);
        sd_c   = std(col_compmp2, 0, 2);
        col_compmp2_st = (col_compmp2 - mean_c) ./ sd_c;

        subj_trials = [subj_trials; col_compmp2_st];  % for an individual. 
    end

    if ~isempty(subj_trials)
        % ---- Average of the z-scored trials for this subject ----
        subj_mean = mean(subj_trials, 1);

        % Add subject average to cluster
        compmp_cluster2 = [compmp_cluster2; subj_mean];
    end
end

% ---- Grand average across all participants of a group ----
compmp_avg2 = mean(compmp_cluster2, 1);


%%
%topoplot
% compmap_diff = compmp_avg1-compmp_avg2; % MCI- Healthy 
compmap_diff = compmp_avg2; % MCI- Healthy 

chanloc= e_tri.EEG_trial.chanlocs;
rows_to_remove=[1,5];
chanloc(rows_to_remove)=[];
[~,se] = max(abs( compmap_diff ));
% compmp_avg1 = compmp_avg1 * sign(compmp_avg1(se));
compmap_diff = compmap_diff * sign(compmap_diff(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');

% plotting 
figure(4)
ax = gca; % Get current axes
ax.XAxis.FontSize = 20; 
ax.YAxis.FontSize = 20; 
topoplotIndien(compmap_diff,chanloc,'numcontour',0);
% title(append('topoplot for cluster 1 ','',band_nm)) %put the filter name as well.
% title(sprintf('Spatial activity difference between MCI and Healthy from GED \nAcross Low Working memory load trials in Theta'), ...
%       'FontSize', 20);
% \nAcross Low Working memory load trials
colorbar('fontsize', 16);
% caxis([-0.75 1.3]);
caxis([-0.45, 0.65]); 


%%
%cluster2
band_nm= 'theta';
compmp_cluster2=[];
executed_trials={};


for d= 1:length(lists2)
    ppt_demo= char(lists2(d,1));
    trial_no= lists2(d,2);
    tr_name = sprintf('Trial%d', trial_no{1});
    try
        e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
    catch
            continue;
    end
        % colevec= e_tri.evecs(:,1);
        % evecs2_th=[evecs2_th, colevec];
        % covS2= e_tri.covS;
        % covS2_th=[covS2_th, covS2];
        col_compmp2= e_tri.compmap; % 1x11
        mean_c = mean(col_compmp2,2);
        sd_c= std(col_compmp2, 0, 2);

        col_compmp2_st= (col_compmp2-mean_c)./sd_c;

        compmp_cluster2= [compmp_cluster2; col_compmp2];
        compmp_avg2= mean(compmp_cluster2,1);
        executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};
end

% evecs2_th1= mean(evecs2_th,2);
% num_matrices = size(covS2_th, 2) / 11;
% covS2_th1= reshape(covS2_th, 11, 11, num_matrices);
% avg_covS2_th1 = mean(covS2_th1, 3);


%topoplot
% compmap = evecs2_th1(:,1)' * avg_covS2_th;
% chanloc= e_tri.EEG_trial.chanlocs;

[~,se] = max(abs( compmp_avg2 ));
compmp_avg2 = compmp_avg2 * sign(compmp_avg2(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');

%plotting 
figure(9)
topoplotIndien(compmp_avg2,chanloc,'numcontour',0);
% title(append('topoplot for cluster 2 ','',band_nm)) %put the filter name as well.
title(append('topoplot for cluster 2 ','',band_nm)) %put the filter name as well.

colorbar
% caxis([-0.5 1.1])


%%
%cluster3
band_nm= 'theta';
% evecs3_th=[];
% covS3_th=[];
compmp_cluster3=[];
executed_trials={};

for d= 1:length(lists3)
    ppt_demo= char(lists3(d,1));
    trial_no= lists3(d,2);
    tr_name = sprintf('Trial%d', trial_no{1});
    try
        e_tri = F_str1.Final.(ppt_demo).(band_nm).(tr_name);
    catch
            continue;
    end
   
        % colevec= e_tri.evecs(:,1);
        % evecs3_th=[evecs3_th, colevec];
        % covS3= e_tri.covS;
        % covS3_th=[covS3_th, covS3];
        col_compmp3= e_tri.compmap; % 1x11
        mean_c = mean(col_compmp3,2);
        sd_c= std(col_compmp3, 0, 2);
        col_compmp3_st= (col_compmp3-mean_c)./sd_c;
        compmp_cluster3= [compmp_cluster3; col_compmp3_st];
        compmp_avg3= mean(compmp_cluster3,1);
        executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};

end

% evecs2_th1= mean(evecs2_th,2);
% num_matrices = size(covS2_th, 2) / 11;
% covS2_th1= reshape(covS2_th, 11, 11, num_matrices);
% avg_covS2_th1 = mean(covS2_th1, 3);


%topoplot
% compmap = evecs2_th1(:,1)' * avg_covS2_th;
% chanloc= e_tri.EEG_trial.chanlocs;
[~,se] = max(abs( compmp_avg3 ));
compmp_avg3 = compmp_avg3 * sign(compmp_avg3(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');
figure(5)
topoplotIndien(compmp_avg3,chanloc,'numcontour',0);
% title(append('topoplot for cluster 3 ','',band_nm)) %put the filter name as well.
title(append('topoplot for cluster 3 ','',band_nm)) %put the filter name as well.

colorbar
% caxis([-0.5 1.1])


%% cluster 4
band_nm= 'theta';
% evecs4_th=[];
% covS4_th=[];
compmp_cluster4=[];
executed_trials={};
for d= 1:length(lists4)
    ppt_demo= char(lists4(d,1));
    trial_no= lists4(d,2);
    tr_name = sprintf('Trial%d', trial_no{1});
    try
        e_tri = F_str.Final.(ppt_demo).(band_nm).(tr_name); %trial 
    catch
            continue;
    end
  
        col_compmp4= e_tri.compmap; % 1x11
        % col_compmp4= e_tri.comp_tS; % 1x11
        % time= e_tri.time2;
        % figure(d);
        % plot(time,col_compmp4);
        mean_c = mean(col_compmp4,2);
        sd_c= std(col_compmp4, 0, 2);
        col_compmp4_st= (col_compmp4-mean_c)./sd_c; % normalised 
        compmp_cluster4= [compmp_cluster4; col_compmp4_st];
        compmp_avg4= mean(compmp_cluster4,1); %averaged over trials
        executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};
end

% evecs2_th1= mean(evecs2_th,2);
% num_matrices = size(covS2_th, 2) / 11;
% covS2_th1= reshape(covS2_th, 11, 11, num_matrices);
% avg_covS2_th1 = mean(covS2_th1, 3);


%topoplot
% chanloc= e_tri.EEG_trial.chanlocs;
[~,se] = max(abs( compmp_avg4 ));
compmp_avg4 = compmp_avg4 * sign(compmp_avg4(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');
figure(5)
topoplotIndien(compmp_avg4,chanloc,'numcontour',0);
% title(append('topoplot for cluster 4 ','',band_nm)) %put the filter name as well.
title(append('topoplot for cluster 4 ','',band_nm)) %put the filter name as well.

colorbar
% caxis([-0.5 1.1])


%% cluster 5 
band_nm= 'theta';
% evecs4_th=[];
% covS4_th=[];
executed_trials={};
compmp_cluster5=[];
for d= 1:length(lists5)
    ppt_demo= char(lists5(d,1));
    trial_no= lists5(d,2);
    tr_name = sprintf('Trial%d', trial_no{1});
    try
        e_tri = F_str.Final.(ppt_demo).(band_nm).(tr_name); %trial 
    catch
            continue;
    end
  
        col_compmp5= e_tri.compmap; % 1x11
        mean_c = mean(col_compmp5,2);
        sd_c= std(col_compmp5, 0, 2);
        col_compmp5_st= (col_compmp5-mean_c)./sd_c; % normalised 
        compmp_cluster5= [compmp_cluster5; col_compmp5_st];
        compmp_avg5= mean(compmp_cluster5,1); %averaged over trials
        executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};
end

% evecs2_th1= mean(evecs2_th,2);
% num_matrices = size(covS2_th, 2) / 11;
% covS2_th1= reshape(covS2_th, 11, 11, num_matrices);
% avg_covS2_th1 = mean(covS2_th1, 3);


%topoplot
% chanloc= e_tri.EEG_trial.chanlocs;
[~,se] = max(abs( compmp_avg5 ));
compmp_avg5 = compmp_avg5 * sign(compmp_avg5(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');
figure(6)
topoplotIndien(compmp_avg5,chanloc,'numcontour',0);
% title(append('topoplot for cluster 5 ','',band_nm)) %put the filter name as well.
title(append('topoplot for cluster 5 ','',band_nm)) %put the filter name as well.

colorbar
% caxis([-0.5 1.1])


%% cluster 6 

band_nm= 'theta';
% evecs4_th=[];
% covS4_th=[];
% Ppt_in_clusters=[];
% trial_clusters=[];
executed_trials={};
compmp_cluster6=[];
for d= 1:length(lists6)
    ppt_demo= char(lists6(d,1));
    trial_no= lists6(d,2);
    tr_name = sprintf('Trial%d', trial_no{1});
    try
        e_tri = F_str.Final.(ppt_demo).(band_nm).(tr_name); %trial 
    catch
            continue;
    end
  
        col_compmp6= e_tri.compmap; % 1x11
        % Ppt_in_clusters(end+1,:) = ppt_demo;
        % trial_clusters[end+1,:]= trial_no;

        mean_c = mean(col_compmp6,2);
        sd_c= std(col_compmp6, 0, 2);
        col_compmp6_st= (col_compmp6-mean_c)./sd_c; % normalised 
        compmp_cluster6= [compmp_cluster6; col_compmp6_st];
        compmp_avg6= mean(compmp_cluster6,1); %averaged over trials
        executed_trials(end + 1, :) = {ppt_demo, trial_no{1}};
end




% evecs2_th1= mean(evecs2_th,2);
% num_matrices = size(covS2_th, 2) / 11;
% covS2_th1= reshape(covS2_th, 11, 11, num_matrices);
% avg_covS2_th1 = mean(covS2_th1, 3);


%topoplot
% chanloc= e_tri.EEG_trial.chanlocs;
[~,se] = max(abs( compmp_avg6 ));
compmp_avg6 = compmp_avg6 * sign(compmp_avg6(se));
addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');
figure(7)

topoplotIndien(compmp_avg6,chanloc,'numcontour',0);
% title(append('topoplot for cluster 6 ','',band_nm)) %put the filter name as well.
title(append('topoplot for cluster 6 ','',band_nm)) %put the filter name as well.

colorbar
% caxis([-0.5 1.1])

%% 
% writematrix(compmp_cluster3,'/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/GED_details_allo.csv');

