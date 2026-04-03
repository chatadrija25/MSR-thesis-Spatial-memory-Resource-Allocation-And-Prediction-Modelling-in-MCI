
% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 


% About the code: 
% The code  uses already filtered EGG data for whole experiment per participant 
% (across four frequency ranges- Bradygastric, Normogastric, Tachygastric and Broadband) 
% to build a struct that includes the trial data(extracted from one experiment file using trial timestamps 
% and power for each band. 

% For every participant, we had 4 files - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data for experiment. From
% that, we got their trial data across these 4 bands and calculated power and saved both.

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


%% EGG files stored 

%add that path 
mydir_egg_broad= '/Users/adrijachatterjee/Downloads/filtered_EGG_broad/';
mydir_egg_brady= '/Users/adrijachatterjee/Downloads/filtered_EGG_brady/';
mydir_egg_normo= '/Users/adrijachatterjee/Downloads/filtered_EGG_normo/';
mydir_egg_tachy= '/Users/adrijachatterjee/Downloads/filtered_EGG_tachy/';

%load other mat files 

baselinepows= load("/Users/adrijachatterjee/Downloads/EGG_baseline_4powers.mat"); %all normalised 
%colnm= {'P_id', 'SelectedElectrode','broad_power','brady_power','normo_power','tachy_power'};


%% creating EEG master struct

participant_list = ["F5";"F6";"F7";"F8";"F10";"F11";"F12";"M6";"M7";"M8";"M9";"M10";"M11" ;"M12" ;"M13" ;"M14";"M15"];
BO_start=["15:39:49","11:18:33","16:27:57","11:31:19","12:23:15","16:21:21","12:10:46","11:04:06","09:13:56","09:21:09","09:48:44","09:25:49","10:54:25","13:09:58","11:39:01","12:07:47","15:22:01"];
BO_rec=["15:42:31","11:19:20","16:28:54","11:28:28","12:32:12","16:20:20","12:10:38","11:04:06","09:13:56","09:21:09","09:48:44","09:25:49","10:54:25","13:01:28","11:31:02","12:15:00","15:21:27"];

BO_start_dt = datetime(BO_start, 'InputFormat', 'HH:mm:ss', 'Format', 'HH:mm:ss');
BO_rec_dt = datetime(BO_rec, 'InputFormat', 'HH:mm:ss', 'Format', 'HH:mm:ss');

% "M7";"M8"; "M9"; 09:13:56","09:21:09","09:48:44",
files = dir (fullfile(mydir_egg_brady, '*mat')); %change it later to text 

%% running through the files 

% STRUCT FOR LOADING ALL THE DATA FOR FURTHER USE 
EGG_str = [];
for a = 1:17
    current = files(a).name; %gets the name of the file 
    EGG_id = current(1:end-4);

    idx = find(participant_list == EGG_id, 1); % Get the index of the participant
    base_st = BO_start_dt(idx);

    rec_t= BO_rec_dt(idx);  
    diff = seconds(base_st-rec_t);
    if diff>0
        strt_time= base_st;
        strt_idx=abs(diff*250);
    else 
        strt_time= rec_t; 
        strt_idx=1;
    end
    fullpath_br=  fullfile(mydir_egg_brady, current); 
    fullpath_nr=  fullfile(mydir_egg_normo, current); 
    fullpath_tc=  fullfile(mydir_egg_tachy, current); 
    fullpath_broad= fullfile(mydir_egg_broad, current);

    s1_brady= load(fullpath_br);
    s1_normo= load(fullpath_nr);
    s1_tachy= load(fullpath_tc);
    s1_broad= load(fullpath_broad);
    
    % P_id= current(1:end-4);
    indx = find(strcmp(baselinepows.baseline_4bandspower.P_id, EGG_id), 1); %finding the index of the participant of egg_id
    chn_id= baselinepows.baseline_4bandspower.SelectedElectrode(indx); %best electroded selected already 
    
    temp_struct=[];

    name = EGG_id;

    temp_struct.EGG_brady = s1_brady.filt_data_crop;
    temp_struct.EGG_normo = s1_normo.filt_data_crop;
    temp_struct.EGG_tachy = s1_tachy.filt_data_crop;
    temp_struct.EGG_broad = s1_broad.filt_data_crop;
    temp_struct.chan_id= chn_id;
    temp_struct.start_idx= strt_idx;
    temp_struct.start_time= strt_time;

    EGG_str.(name) = temp_struct;
    
    end
        

%% time fragmentation code 

%load the datatable for time fragm
addpath('/Users/adrijachatterjee/Downloads');
filename = 'EGG_timefragmData_complete.xlsx';
Table = readtable(filename, ReadVariableNames =false);
% Convert table to cell array for easier indexing
data = table2cell(Table);

data{3,4}='11:39:00';
data{5,7}= '12:06:00'; %approx.

% Extract participant IDs from the first row, excluding the first column
pid = data(1, 1:24);


%% final struct 

Final = [];
trial_strt_indx = cell(17, 5); % Initialize as a cell array with 5 elements
trial_end_indx= cell(17,5);
% tri = cell(17, 5);            % Initialize as a cell array with 5 elements
time_dur_ppt=[];

for i= 1:17
    current = files(i).name;
    % curent= current(1:end-4);
    p_id= char(current(1:end-4));

    % extracting data for selected channels of each participant
    EGG_broad= EGG_str.(p_id).EGG_broad(:,(EGG_str.(p_id).chan_id));
    EGG_brady= EGG_str.(p_id).EGG_brady(:,(EGG_str.(p_id).chan_id));
    EGG_tachy= EGG_str.(p_id).EGG_tachy(:,(EGG_str.(p_id).chan_id));
    EGG_normo= EGG_str.(p_id).EGG_normo(:,(EGG_str.(p_id).chan_id));

    temp_str2=[];
    temp_str2.chan_id= EGG_str.(p_id).chan_id;

    temp_str2.brady= EGG_brady;
    temp_str2.tachy= EGG_tachy;
    temp_str2.normo= EGG_normo;
    temp_str2.broad= EGG_broad;
    
    % Final.(p_id)= temp_str2;
    Final.(p_id).('best_el') = temp_str2.chan_id; 
   
    f=find(strcmp(pid, p_id), 1);
    exp_st= EGG_str.(p_id).start_time;
    exp_st_idx= EGG_str.(p_id).start_idx;

    tri = cell(1, 5); % Reset trial durations


    for j= 1:5
        k=2:2:11;
        start_t= datetime(char(data{k,f}),'InputFormat','HH:mm:ss','Format', 'HH:mm:ss');
        end_t=datetime(char(data{k+1,f}),'InputFormat','HH:mm:ss', 'Format', 'HH:mm:ss');
        tri{j}= seconds(end_t(j) - start_t(j));
    end 

    storetrials{i}= tri;

    for ad= 1:5
       
        timefromstart= seconds(start_t(ad,1)- exp_st);  
        trial_strt_indx{i, ad} = timefromstart * 250 + exp_st_idx; % Start index
        trial_end_indx{i, ad} = trial_strt_indx{i, ad} + (storetrials{i}{ad}) * 250; % End index
        
    end


    temp_str2_brady = cell(1, 5); % Store trials for the brady band
    temp_str2_broad = cell(1, 5); % Store trials for the broad band
    temp_str2_tachy = cell(1, 5); % Store trials for the tachy band
    temp_str2_normo = cell(1, 5); % Store trials for the normo band

    

    bands= ["broad","brady","tachy","normo"];
    time_dur=[];
    for b = 1:length(bands)
        Final.(p_id).(bands(b)).('totaldata') = temp_str2.(bands(b)); 
            
        
        for trial = 1:5
            tr_nm= append("trial", char(trial));
            % Extract the start and end indices for the current trial
            s_idx= trial_strt_indx{i, trial};
            e_idx = trial_end_indx{i, trial};
        
        
            % Check if the indices are valid
            if ~isempty(s_idx) && e_idx > size(temp_str2.brady, 1)
                e_idx= size(temp_str2.brady, 1);
            elseif isempty(s_idx) && isempty(e_idx)
                warning('Start or end index is missing for trial %d.', trial);
                continue;
            end
            trial_data=temp_str2.(bands(b))(s_idx:e_idx);

            if isempty(trial_data)
                continue;
            end
            
            baseline_p_id= baselinepows.baseline_4bandspower.P_id;
            b_id= find(strcmp(baseline_p_id,p_id));

            b_power= baselinepows.baseline_4bandspower.broad(b_id);
            tim= floor(size(trial_data,1)/250);

     

            [peaks_trial, max_peak_trial] = power_spec(trial_data ,tim);
            trial_power= max_peak_trial-b_power;

                % Store trial-specific data for each band
                % switch bands(b)
                %     case "broad"
                %         temp_str2_broad{trial} = trial_data;
                %         % temp_str2_broad{}
                %     case "brady"
                %         temp_str2_brady{trial} = trial_data;
                %     case "tachy"
                %         temp_str2_tachy{trial} = trial_data;
                %     case "normo"
                %         temp_str2_normo{trial} = trial_data;
                % end
            Final.(p_id).(bands(b)).(sprintf('trial%d', trial)) = trial_data;     
            Final.(p_id).(bands(b)).(sprintf('trial%d_power', trial)) = trial_power;    
            % time_dur = [time_dur, tim];
          
        end %trial 
           

    end %band 

% time_dur_ppt(end+1,:) = time_dur;

end %ppt
%%


