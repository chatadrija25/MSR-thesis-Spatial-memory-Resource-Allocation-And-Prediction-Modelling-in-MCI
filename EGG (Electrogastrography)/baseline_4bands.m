% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% The code computes the power in the baseline or eyes-open resting
% condition for each participant across 4 gastric frequency bands (including Broadband). 

% For every participant, we had 4 files - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data for experiment. From
% that, we got their baseline period data across these 4 bands and calculated power.

% For selection of best electrode for every participant- see code EGG_select_electrode. 
% Best electrode is the one with highest power in the broadband range. 
% For filtering across bands, see code filt_tbnbr- filters the data - tachy, brady, normo, broad. 
% Uses padding and 50% window overlap to increase resolution. 
% For power calculation- see code power_spec.m- to calculate power spectrum. 
% It is a function, which takes the signal and the returns the maximum power (if there are multiple peaks, 
% returns the max among those).

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% load the mat file for the best electrode 

select_el= load('/Users/adrijachatterjee/Downloads/EGG_selected_elec_broad.mat');
addpath('/Users/adrijachatterjee/Downloads/power_spec.m');

% load the variable needed to get the channel idx and ppt_id 
best_el= table;
best_el= select_el.best_electrode;
col = {'P_id', 'SelectedElectrode', 'peak_power(bro)', 'corresponding_freq'};
best_el = cell2table(best_el, 'VariableNames', col);

%% add the directories for the four bands 

mydir_egg_brady= '/Users/adrijachatterjee/Downloads/filtered_EGG_brady/';
mydir_egg_normo= '/Users/adrijachatterjee/Downloads/filtered_EGG_normo/';
mydir_egg_tachy= '/Users/adrijachatterjee/Downloads/filtered_EGG_tachy/';
mydir_egg_broad= '/Users/adrijachatterjee/Downloads/filtered_EGG_broad/';

%% loading the time data and other stuff 

participant_list = ["F5";"F6";"F7";"F8";"F10";"F11";"F12";"M6";"M7";"M8";"M9";"M10";"M11" ;"M12" ;"M13" ;"M14";"M15"];
% baseline start 
BO_start=["15:39:49","11:18:33","16:27:57","11:31:19","12:23:15","16:21:21","12:10:46","11:04:06","09:13:56","09:21:09","09:48:44","09:25:49","10:54:25","13:09:58","11:39:01","12:07:47","15:22:01"];
% baseline_end
BO_rec=["15:42:31","11:19:20","16:28:54","11:28:28","12:32:12","16:20:20","12:10:38","11:04:06","09:13:56","09:21:09","09:48:44","09:25:49","10:54:25","13:01:28","11:31:02","12:15:00","15:21:27"];

BO_start_dt = datetime(BO_start, 'InputFormat', 'HH:mm:ss');
BO_rec_dt = datetime(BO_rec, 'InputFormat', 'HH:mm:ss');

%% Obtaining files

files_band= dir(fullfile(mydir_egg_brady, '*mat'));

%%

baseline_4bandspower= table;

for i= 1:length(files_band)
    current= files_band(i).name;
    EGG_id = current(1:end-4);

    idx = find(participant_list == EGG_id, 1); % Get the index of the participant
    base_st = BO_start_dt(idx);

    rec_t= BO_rec_dt(idx);  
    rec_t= string(rec_t);
    rec_t = datetime(rec_t, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss'); % Specify format if needed
    rec_t= extractAfter(string(rec_t), "2024 ");     % Extract only the time component
    rec_t=datetime(rec_t,'InputFormat', 'HH:mm:ss');
    diff = seconds(base_st-rec_t);
    if diff>0
        strt_time= base_st;
        strt_idx=diff*250;
    else 
        strt_time= rec_t; 
        strt_idx=1;
    end

    fullpath_br=  fullfile(mydir_egg_brady, current); 
    fullpath_nr=  fullfile(mydir_egg_normo, current); 
    fullpath_tc=  fullfile(mydir_egg_tachy, current); 
    fullpath_broad= fullfile(mydir_egg_broad, current);
    
    P_id= current(1:end-4);

    indx = find(strcmp(best_el.P_id, P_id), 1); 
    chn_id= best_el.SelectedElectrode(indx); %best electrode selected already 
   
    % get the data 
    s1_brady= load(fullpath_br);
    s1_normo= load(fullpath_nr);
    s1_tachy= load(fullpath_tc);
    s1_broad= load(fullpath_broad);
    
    %trial time 
    dur_ind= strt_idx+ 300*250; % 5 minutes 
    time_base= floor(dur_ind/250);

    % Gets the data for the selected electrode only. 
    s1_br = s1_brady.filt_data_crop(:, chn_id);
    s1_nr = s1_normo.filt_data_crop(:, chn_id);
    s1_tc = s1_tachy.filt_data_crop(:, chn_id);
    s1_broad= s1_broad.filt_data_crop(:,chn_id);

    % Calculates peak power for each band. 
    [peaks_br, max_peak_br] = power_spec(s1_br,time_base);
    [peaks_nr, max_peak_nr] = power_spec(s1_nr,time_base);
    [peaks_tc, max_peak_tc] = power_spec(s1_tc,time_base);
    [peaks_bro, max_peak_bro] = power_spec(s1_broad,time_base);
    
    % Saves all the information 
    baseline_4bandspower{i,1}= {EGG_id}; %Partcipant id
    baseline_4bandspower{i,2}= chn_id; % best electrode
    % Peak power across all bands.
    baseline_4bandspower{i,3}= max_peak_bro; %broad
    baseline_4bandspower{i,4}= max_peak_br; %brady
    baseline_4bandspower{i,5}= max_peak_nr;%normo
    baseline_4bandspower{i,6}= max_peak_tc; %tachy
   
    
end

%% Putting variable names.   

colnm= {'P_id', 'SelectedElectrode','broad','brady','normo','tachy'};
baseline_4bandspower.Properties.VariableNames = colnm;









   
