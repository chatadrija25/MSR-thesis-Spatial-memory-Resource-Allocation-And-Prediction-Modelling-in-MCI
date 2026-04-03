% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% The code computes the power in the baseline or eyes-open resting
% condition for each participant in the Broadband frequency range. The
% electrode with highest power is selected as the best electrode for that
% participant. 

% For every participant, we had 4 files - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data for experiment. From
% that, we got their baseline period data and calculated power.

% For filtering across bands, see code filt_tbnbr- filters the data - tachy, brady, normo, broad. 
% Uses padding and 50% window overlap to increase resolution. 
% For power calculation- see code power_spec.m- to calculate power spectrum. 
% It is a function, which takes the signal and the returns the maximum power (if there are multiple peaks, 
% returns the max among those).

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in


%% For selection of electrode- we have to calculate the peak power in the broadband range from the baseline data 

% egg_raw_file= readtable("/Users/adrijachatterjee/Downloads/EGG files/M7.txt");

mydir_egg = '/Users/adrijachatterjee/Downloads/EGG files/';

%ADD THE PATH FOR EGG_BROADBAND 

mydir_egg_broad= '/Users/adrijachatterjee/Downloads/filtered_EGG_broad/';

%% loading the egg files in loop 

% The find function locates the index of the participant_id in participant_list.
% bo start and participant list should have same index.
participant_list = ["F5";"F6";"F7";"F8";"F10";"F11";"F12";"M6";"M7";"M8";"M9";"M10";"M11" ;"M12" ;"M13" ;"M14";"M15"];
BO_start=["15:39:49","11:18:33","16:27:57","11:31:19","12:23:15","16:21:21","12:10:46","11:04:06","09:13:56","09:21:09","09:48:44","09:25:49","10:54:25","13:09:58","11:39:01","12:07:47","15:22:01"];
% participant_list=["F11"];
% BO_start=["16:21:21"];

BO_start_dt = datetime(BO_start, 'InputFormat', 'HH:mm:ss');
files = dir(fullfile(mydir_egg, '*txt'));
% files_broad= dir(fullfile(mydir_egg_broad, '*txt'));

% colNames = {'ppt_ID', 'Channel_id','MaxPower'};
% best_electrode.Properties.VariableNames = colNames;


for a =1:length(files)
    currentfile = files(a).name;
    % EGG_id= currentfile; %ppt_id
    [~,EGG_id, ~] = fileparts(currentfile);
    currentfile_broad = [(currentfile(1:end-4)), '.mat'];  % Construct the .mat file name
    fullpath_broad = fullfile(mydir_egg_broad, currentfile_broad);  % Path for the broad file

    % EGG_broad = EGG_id + "_broad" + ".txt";  
   
    fullpath = fullfile(mydir_egg, currentfile);  % Construct the full path
    fullpath_broad = fullfile(mydir_egg_broad, currentfile_broad);
    egg_raw_file = readtable(fullpath, ReadVariableNames=true);    % Read the file using the full path
    egg_broad_file= load(fullpath_broad);

   
    idx = find(participant_list == EGG_id, 1); % Get the index of the participant
    base_st = BO_start_dt(idx);
   
%% Time variation 

    rec_t= egg_raw_file{1,25};  
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



%% Time domain and bandpassing
    ppt_peakpower= cell(17,6);
    columnNames = {'ChannelID', 'MultiplePeaks', 'PeakFrequencies', 'MaxPower','freq_maxpower', 'fr_maxpower_mult'};
    ppt_peakpower = cell2table(ppt_peakpower, 'VariableNames', columnNames);
   
    for ch = 7:9  
        chan_ind = ch - 6;  
        s1 = table2array(egg_raw_file(:, ch));
        s1_broad = egg_broad_file.filt_data_crop(:, chan_ind);
        fs = 250;           % Sampling frequency
        wl = 60 * fs;       % Window length in samples (60 seconds)
        overlap = 30 * fs;  % Overlap in samples (30 seconds)
        dur = 300;          % Duration in seconds
    
        step = wl - overlap;  % Step size in samples (30 seconds)
        % num_windows = floor((dur * fs - overlap) / step);  % Number of windows
    
        for w = 1:9
            start_idx = (w - 1) * step + 1;
            stop_idx = start_idx + wl - 1;
    
           
            egg_sig = s1(start_idx:stop_idx, :);
            egg_sig_br = s1_broad(start_idx:stop_idx, :);
    
            % Zero-pad signals
            pad_length = 2000;
            egg_sig_padded = [zeros(pad_length, size(egg_sig, 2)); egg_sig; zeros(pad_length, size(egg_sig, 2))];
            egg_sig_broad_padded = [zeros(pad_length, size(egg_sig_br, 2)); egg_sig_br; zeros(pad_length, size(egg_sig_br, 2))];
    
            % FFT length (after padding)
            fft_length = size(egg_sig_padded, 1);
    
            % Calculate PSD
            [pxx_filt(:, :, w), freq] = pwelch(egg_sig_broad_padded, wl, overlap, fft_length, fs);
            [pxx(:, :, w), freq] = pwelch(egg_sig_padded, wl, overlap, fft_length, fs);
            
            % [pxx_filt(freq_bins, channels(which is always 1 
            % because we are looping across channels, window length), freq]
            % CHANGES MADE

            % power_norm= pxx./sum(pxx); %normalizing the PSD 
            % power_norm_f = pxx_filt./ sum(pxx_filt); %normalizing the PSD 
            
        end
            % mean across windows 
            psd = mean(pxx,3);
            psd_f= mean(pxx_filt,3);

            power_norm= psd./sum(psd); %normalizing the PSD 
            power_norm_f = psd_f./ sum(psd_f); %normalizing the PSD 

            
            
            freq_idx= find(freq<0.15);
            
            figure(1);

            plot(freq(freq_idx), psd(freq_idx));

            figure(2);
            plot(freq(freq_idx), psd(freq_idx));

            [peaks, locs] = findpeaks(psd_f(freq_idx));
            
            locations= freq(freq_idx(locs)); % contains the corresponding freq of the power peaks

        %%
            ppt_peakpower{chan_ind, 1} = {chan_ind};  % channel index
            ppt_peakpower{chan_ind, 2} = {numel(peaks)}; % count of peaks
        %%
            if numel(peaks) == 1
                ppt_peakpower{chan_ind, 3} = {peaks}; % single peak power
                ppt_peakpower{chan_ind,4}= {peaks};
                ppt_peakpower{chan_ind,5}= {locations};
                ppt_peakpower{chan_ind,6}={locations};

            else
                % Multiple peaks, store all peak powers in a cell array
                ppt_peakpower{chan_ind, 3} = {peaks}; % Store all peak powers
                ppt_peakpower{chan_ind, 4}= {max(peaks)}; % max among the peaks 
                max_peak_idx = find(peaks == max(peaks), 1); % indx of that max oeak 
                max_peak_freq = locations(max_peak_idx); % corresponding freq of the max peak 
                ppt_peakpower{chan_ind,5}= {locations}; %saving all the corresponding freqs of the peaks 
                ppt_peakpower{chan_ind,6}={max_peak_freq}; % saving the corresponding freq of the max among the peaks 
            end

        end
        
        %SAVING THE SELECTED ELECTRODE AND BROADBAND PEAK POWER
        
        power_values = ppt_peakpower.MaxPower; %saving all the peak powers 
        % of a participant from the ppt_peakpower  

        locats= cell2mat(ppt_peakpower.fr_maxpower_mult); % the corresponding freq of the max among the peaks 

        % %Find the max power and corresponding channel
        [max_value, max_idx] = max(cell2mat(power_values));
        selected_elec = cell2mat(ppt_peakpower.ChannelID(max_idx));

        best_electrode{a,1}= currentfile(1:end-4);
        best_electrode{a,2}= selected_elec;
        best_electrode{a,3}= max_value;
        best_electrode{a,4}= locats(max_idx);

    
    
end


%% extra 

% addpath('/Users/adrijachatterjee/Downloads/timefragmData_tillF5.xlsx');
% filename = 'timefragmData_tillF5.xlsx';
% 
% Table = readtable(filename, ReadVariableNames =false);
% 
% % Convert table to cell array for easier indexing
% data = table2cell(Table);
% 
% data{3,4}='11:39:00';
% data{5,7}= '12:06:00'; %approx.
% 
% % Extract participant IDs from the first row, excluding the first column
% pid = data(1, 1:17);
% %%
% startTimes = cell(1,17);
% endTimes = cell(1,17);
% 
% % Loop over each participant
% for i = 1:17   
%     exp_start = data(2, i); %experiment start time  for all participants
%     exp_end = data(11, i); %experiment end time for all participants
% 
%     % Store the start and end times in the respective cell arrays
%     startExp{i} = exp_start;
%     endExp{i} = exp_end;
% 
% end
    % sgtitle(append('Plots-'," ", char(band(h)),"for chn9 ","M7"));
    % 
    % filename= append("Plots for-"," ", char(band(h)),"for chn9 M7",".png");
    % filepath= filepaths{h};
    % saveas(gcf, fullfile(filepath, filename)); %gcf handles the current plot
    % %put ppt_no., %channel_indx %time_duration