% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
%Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% This code computes  how many windows have max power in a particular band; 
% windows have no overlap.

% For every participant, we had 4 files - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data for experiment. From
% that, we got their trial data across these 4 bands and calculated power and saved both.
% This data is obtained from the struct- EEG_master_array_latest and used accordingly. 

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
% Load the final EGG struct. 

%% LOAD EGG STRUCT 
% get total data for each participant - broad- trial 1, 2...5 
% calculate psd ( get window index from here, no overlap, see code ). 
load('/Users/adrijachatterjee/Downloads/Final_EGG_str.mat');

%% 
participant_list = ["F5";"F6";"F7";"F8";"F10";"F11";"F12";"M6";"M7";"M8";"M9";"M10";"M11" ;"M12" ;"M13" ;"M14";"M15"];
fs = 250;           % Sampling frequency
wl = 60 * fs;       % Window length in samples (60 seconds)
overlap = 0; 
pad_length = 2000;
tachy_perc = [];
brady_perc = [];
normo_perc = [];
results= table();
for p= 1:length(participant_list)
    participant = char(participant_list(p));% participant 
    for trial= 1:5 %trial 
        tr_nm = append("trial", num2str(trial));
        if ~isfield(Final.(participant).broad, tr_nm)
           continue;
        end
        egg_sig = Final.(participant).broad.(tr_nm); %egg signal 

        n_win = floor(size(egg_sig,1)/wl); %number of windows 

        pxx = [];
        freq = [];

        %storing the number of windows with max power in each band 
        normo_count = 0;
        tachy_count = 0;
        brady_count = 0;
        dom_freq = [];
        dom_power = [];

        if n_win==0
           wl= size(egg_sig,1);
           egg_sig_padded = [zeros(pad_length, size(egg_sig, 2)); egg_sig; zeros(pad_length, size(egg_sig, 2))];
           fft_length = size(egg_sig_padded, 1);
           [pxx,freq]= pwelch(egg_sig_padded, wl, overlap, fft_length, fs);
           freq_idx= find(freq<0.15);
           
           dom_power = max(pxx(freq_idx));
           dom_freq = freq(find(pxx == dom_power));
            if dom_freq > 0.0083 && dom_freq < 0.03
                brady_count = brady_count + 1;
            elseif dom_freq > 0.03 && dom_freq < 0.07
                normo_count = normo_count + 1;
            elseif dom_freq > 0.07 && dom_freq < 0.15
                tachy_count = tachy_count + 1;
            end
        else
            for w=1:n_win %window 
                egg_sig_w = egg_sig(((wl)*(w-1))+1:wl*w,:); %Taking a window of the signal
                egg_sig_padded = [zeros(pad_length, size(egg_sig_w, 2)); egg_sig_w; zeros(pad_length, size(egg_sig_w, 2))];
                fft_length = size(egg_sig_padded, 1);
                [pxx(:,w),freq] = pwelch(egg_sig_padded,wl,overlap,fft_length,fs);
                freq_idx= find(freq<0.15);
                pxx_filtered = pxx(freq_idx, w);  
                freq_filtered = freq(freq_idx);
                % Finding the dominant power and its corresponding frequency
                [dom_power(w), idx] = max(pxx_filtered); 
                dom_freq(w) = freq_filtered(idx);
                if dom_freq(w) >= 0.0083 && dom_freq(w) <= 0.03
                    brady_count = brady_count + 1;
                elseif dom_freq(w) > 0.03 && dom_freq(w) < 0.07
                    normo_count = normo_count + 1;
                elseif dom_freq(w) > 0.07 && dom_freq(w) < 0.15
                    tachy_count = tachy_count + 1;
                end
            end
           
        end
        total_classified = brady_count + normo_count + tachy_count;
        if total_classified == 0
            brady_perc = 0;
            normo_perc = 0;
            tachy_perc = 0;
        else
            brady_perc = (brady_count / total_classified) * 100;
            normo_perc = (normo_count / total_classified) * 100;
            tachy_perc = (tachy_count / total_classified) * 100;
        end
        new_row = table(string(participant), trial, brady_perc, normo_perc, tachy_perc, ...
                        'VariableNames', {'P_ID', 'Trial', 'Brady_Percentage', ...
                        'Normo_Percentage', 'Tachy_Percentage'});
        results = [results; new_row];
    end 
    % save p_id and trial in a table 
end 
%%
%psd plot code 
% figure;
% plot(freq, pxx, 'b', 'LineWidth', 1.5); 
% xlabel('Frequency (Hz)');
% ylabel('Power');
% title('Power Spectrum');
% grid on;
% xlim([0, 0.2]); 

%% saving the results 

results_tbl= table();
for p= 1:length(participant_list)
    participant = char(participant_list(p));% participant 
    for trial= 1:5 %trial 
        tr_nm = append("trial", num2str(trial));
        if ~isfield(Final.(participant).broad, tr_nm)
           continue;
        end
        egg_sig = Final.(participant).broad.(tr_nm); %egg signal 
        wl= size(egg_sig,1);
        egg_sig_padded = [zeros(pad_length, size(egg_sig, 2)); egg_sig; zeros(pad_length, size(egg_sig, 2))];
        fft_length = size(egg_sig_padded, 1);
        [pxx,freq]= pwelch(egg_sig_padded, wl, overlap, fft_length, fs);
        freq_idx= find(freq<0.15);
        
        dom_power = max(pxx(freq_idx));
        dom_freq = freq(find(pxx == dom_power));
        if dom_freq > 0.0083 && dom_freq < 0.03
            dom_band = "brady";
        elseif dom_freq > 0.03 && dom_freq < 0.07
            dom_band = "normo";
        elseif dom_freq > 0.07 && dom_freq < 0.15
            dom_band = "tachy";
        end
        tbl_row = table(string(participant), trial, dom_band, ...
            'VariableNames', {'P_ID', 'Trial','Dom_band_trial'});
        results_tbl = [results_tbl; tbl_row];
    end
end

%% stores the results and merges with the final merged_table.mat 

result_merge= table();
result_merge = outerjoin(results, results_tbl, "Keys",{'P_ID','Trial'},"MergeKeys",true);













