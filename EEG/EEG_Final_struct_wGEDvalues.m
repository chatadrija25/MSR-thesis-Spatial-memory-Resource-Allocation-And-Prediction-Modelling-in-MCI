% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.

% About the code: 
% The code  uses already preprocessed EEG files for baseline and experiment for each participant 
% to build a struct that includes the trial data, baseline data(extracted
% from one experiment file using trial timestamps) filtered across theta,
% alpha, beta and broad frequency band. 

% It also computes and saves in the struct(per trial, per participant): 
% 1. Compmap or component map parameter was obtained from each trial.  
% compmap= evecs( : , 1 )* CovS;
% 2. Evecs (: , 1 )-The first eigenvector captures the most task-specific variance relative to baseline. 
% 3. CovS- or signal covariance matrix represents the spatial covariance structure of the EEG data during the experimental condition (here, trials).
% It captures how EEG signals from different channels co-vary across time.
% 4. CovR - similar to CovS but for reference/baseline data.
% All variables: ["compmap", "evals","evecs","comp_tS","comp_tR","time1", "time2","EEG_trial","covS","covR"];

% This matrix is used in GED to find spatial filters (eigenvectors) that maximize task-specific variance (CovS) relative to baseline variance (CovR). 

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

mydir = '/Users/adrijachatterjee/Downloads/Preprocessed_setfiles';
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/firfilt');
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/ICLabel');
%addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/clean_rawdata-master');
% addpath('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/timefragmData_complete.xlsx');

%% creating EEG master struct

files = dir (fullfile(mydir, '*set'));
% files1= dir(fullfile(mydir, '*set'));

%% Extracting preprocessed files for baseline(BO) and experiment and putting in the struct

EEG_str = [];
for a = 1:length(files)
    currentfile = files(a).name;
        check2 = contains(currentfile, {'BC'});
        check = contains(currentfile, {'BO'});
            if check == 1 
                name  =  extractBefore(currentfile, "_");
                EEG_base = pop_loadset(currentfile);
        
                temp_struct.Base =  [];
                temp_struct.Base =  EEG_base;
            elseif check2 == 1
                continue
                
            else 
                name = extractBefore(currentfile, "(");
                EEG_exp= pop_loadset(currentfile);
                temp_struct.Trl =  EEG_exp
        
            end
        
           EEG_str.(name) = temp_struct;
end


%% Getting time stamps for to extract trial wise data 

addpath('/Users/adrijachatterjee/Library/Mobile Documents/com~apple~Numbers/Documents/timefragmData_complete.xlsx');
filename = 'timefragmData_complete.xlsx';
Table = readtable(filename, ReadVariableNames =false);
% Convert table to cell array for easier indexing
data = table2cell(Table);

 data{3,4}='11:39:00';
 data{5,7}= '12:06:00'; %approx.

% Extract participant IDs from the first row, excluding the first column
pid = data(1, 1:24);
% disp('Participant IDs:');
disp(pid);
%%
% Initialize cell arrays to hold start and end times
startTimes = cell(1,24);
endTimes = cell(1,24);

% Loop over each participant
for i = 1:24
    %disp(i);
    % Extract start times from odd-indexed rows (1, 3, 5, ...)
    p_id_start = data(2:2:11, i); %all trial start times 
    % Extract end times from even-indexed rows (2, 4, 6, ...)
    p_id_end = data(3:2:11, i); %all trial end times 
    
    % Store the start and end times in the respective cell arrays
    startTimes{i} = p_id_start;
    endTimes{i} = p_id_end;
    
    % Display the start and end times for the current participant
    % disp(['Start times for Participant ' pid{i} ':']);
    % disp(p_id_start);
    % disp(['End times for Participant ' pid{i} ':']);
    % disp(p_id_end);
end
%% 
% data{2,4}= "11:39:00";

for i= 1:24
    for j= 1:5
        start_t= datetime((startTimes{1,i}{j,1}),'InputFormat','HH:mm:ss');
        end_t=datetime((endTimes{1,i}{j,1}),'InputFormat','HH:mm:ss');
        tri{j}= seconds(end_t - start_t);
     storetrials{i}= tri;
    end 
end 

%%
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB');

e_st=['00:00:00';'00:00:00';'03:54:37';'11:36:34';'04:46:05';'03:24:01';'00:00:00';'11:25:02';'09:29:52';'09:40:19';'10:01:12';'09:44:32';
    '11:29:26';'01:29:24';'12:09:19';'12:28:12';'04:03:30';'11:41:43';'16:47:03';'11:53:56';'12:51:13';'16:38:09';'12:28:23';'15:37:47'];
s_rate= 250;

% * * *  * * * * * * * uncomment loop for all partiticipants * *
% 
%for x= 3:7 %looping over each participant, donot have the eeg data for m2, m3.so, from 3-7.
%e_stime= datetime(e_st(x,:),'InputFormat','h:m:s'); %recording started 

%e_stime= datetime(e_st(8,:),'InputFormat','h:m:s');

%% Actual code
%first loop : participant based

participant_list = ["F2", "F3", "M4", "M5", "M6", "M7","M8" ,"M9" ,"M10" ,"M11" ,"M12" ,"M13" ,"M14","F5","F6","F7","F8","F10",'F11',"F12","M15"];

p_id = fieldnames(EEG_str);
[isMember, idx] = ismember(p_id, participant_list);
peeps = p_id(isMember);
Final = [];
range1= 3:6;
range2= 8:24;
c_ranges=[range1 range2];

for x= c_ranges %:10 %looping over each participant, donot have the eeg data for m2, m3. So, from 3-7.
    e_stime= datetime(e_st(x,:),'InputFormat','HH:mm:ss');
    EEG_tr= EEG_str.(char(data(1,x))).Trl;
    EEG_b = EEG_str.(char(data(1,x))).Base;

    EEG_T = EEG_tr; % Fresh copy before filtering
    EEG_B = EEG_b;

    Pre_final = [];
  
        low = [4,8,13];
        high = [7,12,30];
        band_name = ["theta","alpha","beta"];
        % file_theta='/Users/adrijachatterjee/Downloads/theta_GED';
        % file_alpha='/Users/adrijachatterjee/Downloads/alpha_GED';
        % file_beta='/Users/adrijachatterjee/Downloads/beta_GED';
        % filepaths={file_theta,file_alpha,file_beta};

        for h = 1:3   %second loop : filter based
            EEG_T= pop_eegfiltnew(EEG_T, 'locutoff', low(h) , 'hicutoff',high(h), 'filtorder', 9000, 'plotfreqz', 0);
            EEG_base = pop_eegfiltnew(EEG_B, 'locutoff', low(h) , 'hicutoff',high(h), 'filtorder', 9000, 'plotfreqz', 0);
 
                temp = [];
               
                for trial= 1:5
                    ppt_id= char(data(1,x));
                    st_point= datetime((startTimes{1,x}{trial,1}),'InputFormat','HH:mm:ss'); 
                    time_fromstart= seconds(st_point-e_stime);
                    point_trialst= time_fromstart* s_rate;
                    endpoint= point_trialst + ((storetrials{1,x}{1,trial})*s_rate);
                    disp(endpoint);
                    disp(point_trialst);

                    if point_trialst< size(EEG_T.data, 2)
                        if endpoint < size(EEG_T.data,2)
                        EEG_trial= pop_select(EEG_T, 'point', [point_trialst endpoint]);
                        EEG_BB= EEG_base;
                        elseif endpoint > size(EEG_T.data, 2)
                        EEG_trial= pop_select(EEG_T, 'point', [point_trialst size(EEG_T.data, 2)]);
                        EEG_BB= EEG_base;
                        end
                    else 
                        continue
                    end 
                    

                    %REMOVING fp1 and fp2 - to remove excess eye component.
                    row_to_remove=[1,5];
                    
                    EEG_BB.data(row_to_remove,:)=[];
                    tmpd_R= EEG_BB.data; %for reference matrix
                    mean_vals = mean(tmpd_R,2);
                    sd_vals = std(tmpd_R, 0, 2);
                    tmpd_R= (tmpd_R-mean_vals)./sd_vals;
                    
                    EEG_trial.data(row_to_remove,:)=[];
                    tmpd_S= EEG_trial.data; %for signal matrix  
                    mean_vals = mean(tmpd_S,2);
                    sd_vals = std(tmpd_S, 0, 2);
                    tmpd_S= (tmpd_S-mean_vals)./sd_vals;
                    
                    % compute covariance matrix R(reference- baseline eyes open)
                    pnts_R= size(tmpd_R,2);
                    covR = (tmpd_R*tmpd_R')/pnts_R;
                    % compute covariance matrix S1(diff) 
                    pnts_S= size(tmpd_S,2);
                    covS = (tmpd_S*tmpd_S')/pnts_S;

                    % Generalized eigendecomposition (GED)
                    [evecs,evals] = eig(covS,covR);
                    %run GED and plots, save the files separately.[evecs,evals] = eig(covS1,covR);

                    [evals,sidx]  = sort(diag(evals),'descend');
                    evecs = evecs(:,sidx);
                    
                    %%% compute the component time series
                    
                    comp_tR = evecs(:,1)'*EEG_BB.data; %reference 
                    time1 = (0:(pnts_R-1))/250; % note time changed to time 1


                    % 1st figure will come here : plot(time1, comp_tR(1, :));

                    % plot(time1, comp_tR(1, :));
                    % figure(1)
                    % plot(time1, comp_tR(1, :));
                    % xlabel('Time (s)');
                    % ylabel('Amplitude');
                    % title(append('component timeseries-reference for trial',num2str(trial),' for',...
                    %         ppt_id,'',char(band_name(h))));
                    % grid on;
                    % fileName = append('cts-reference trial',num2str(trial),' for','','',...
                    %     ppt_id,' ',  char(band_name(h)), '.png');
                    % filePath = filepaths{h};
                    % %Save the figure as a PNG file
                    % saveas(figure(1), fullfile(filePath, fileName));



                    % Extract the time series for the first component
                    component_data = comp_tR(1, :); % Time series of the first component

                    
                    comp_tS = evecs(:,1)'*EEG_trial.data; 
                    component_data = comp_tS(1, :);
                    %mean_c= mean(component_data,2);
                    %sd_c= std(component_data,0,2);
                    pnts= size(component_data,2);
                    time2 = (0:(pnts-1))/250;  %note time changed to time 2

                    % 2nd figure : 
                    % figure(2)
                    % plot(time2,component_data);
                    % xlabel('Time (s)');
                    % ylabel('Amplitude');
                    % % yline(mean_c, '--r', 'LineWidth', 1.5);
                    % % yline(mean_c + sd_c*3, '--r', 'LineWidth', 1.5);
                    % % yline(mean_c - sd_c*3, '--r', 'LineWidth', 1.5);
                    % title(append('component timeseries-Signal for trial',num2str(trial),' for',...
                    %         ppt_id,'',band_name(h)));
                    % grid on;
                    % fileName = append('cts-Signal trial',num2str(trial),' for','',...
                    %     ppt_id,' ',  char(band_name(h)),'.png');
                    % filePath = filepaths{h};
                    % %Save the figure as a PNG file
                    % saveas(figure(2), fullfile(filePath, fileName));

                    compmap = evecs(:,1)' * covS;

                    [~,se] = max(abs( compmap ));
                    compmap = compmap * sign(compmap(se));

                    %topoplot
                    % addpath('/Users/adrijachatterjee/Downloads/GED_tutorial-main');
                    % figure(3)
                    % topoplotIndie(compmap, EEG_base.chanlocs,'numcontour',0);
                    % title(append('topoplot for trial',num2str(trial),' for','',...
                    %     ppt_id,'',band_name(h))) %put the filter name as well.
                    % colorbar
                    % fileName = append('topoplot for trial',num2str(trial),' for',...
                    %     ppt_id,' ', char(band_name(h)), '.png');
                    % filePath = filepaths{h};
                    % %Save the figure as a PNG file
                    % saveas(figure(3), fullfile(filePath, fileName));
                    
                    list = {compmap, evals,evecs,comp_tS,comp_tR,time1, time2,EEG_trial,covS,covR};
                    list_name = ["compmap", "evals","evecs","comp_tS","comp_tR","time1", "time2","EEG_trial","covS","covR"];
                    for e = 1:length(list)
                        temp.(append("Trial", string(trial))).(list_name(e)) = cell2mat(list(e));                        
                    end
%                       temp.eeg = EEG_tr;

                end %trial loop 
                Pre_final.(band_name(h)) = temp;

        end %filter loop
        Final.(char(data(1,x))) = Pre_final;

end %participant loop
%%
% newpath = '/Users/adrijachatterjee/Downloads/codes/';
% matname =  append(newpath, 'Final_Arrary_complete.mat');
% save(matname, 'Final');





