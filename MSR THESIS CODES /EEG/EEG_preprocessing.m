
% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% Preprocessing EEG pipeline for all participants. 
% it includes filtering, doing ICA, removing bad components and channels,
% interpolate bad channels, re-reference the data. 

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% eeg pre-processing files
%to add the file to the path 


%% automated looping of files

myDir =  '/Users/adrijachatterjee/Downloads/Raw_setfiles4'; %upto F5
destination_path = '/Users/adrijachatterjee/Downloads/Preprocessed_setfiles1';

% myDir =  '/Users/adrijachatterjee/Downloads/Malnutrition_setfiles'
% destination_path = '/Users/adrijachatterjee/Downloads/Mal_preprocess';
Rawfiles = dir(fullfile(myDir, '*.set'));

%adding path 
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB');
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/firfilt');
addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/ICLabel');
%addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/clean_rawdata-master');

%% Loading the .mat file into the EEG struct 
for k = 4
    setf = fullfile(myDir, Rawfiles(k).name);
    EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',setf,'srate',256,'pnts',0,'xmin',0);
    EEG_length= size(EEG.data,2);
    disp(EEG_length);
 
end
%% getting chanlocs(channel locations)
% channel list 
    labels = {'fp2','f4','c4','p4','fp1','f3','c3','p3','f8','t4','t6','o2','f7','t3','t5','o1','cz','pz','fz'};
    required_labels = {'cz','pz','fz'};
    labels_to_remove = {'f8','t4','t6','o2','f7','t3','t5','o1','fp2','f4','c4','p4','fp1','f3','c3','p3',};
    
    %reading the chanlocs txt file 
    chansinfo = readmatrix('/Users/adrijachatterjee/Downloads/codes/chanlocs.txt');
    temp = readtable('/Users/adrijachatterjee/Downloads/codes/chanlocs.txt');
    chanlabels = table2array(temp(:,1));
    chansinfo = chansinfo(:,2:end);
    chanlocs_new = [];
    nchans = length(labels);
    %indx=[]
    indices_to_remove = [];
    for i=1:nchans
    
        idx = find(strcmpi(chanlabels,labels{i}));
        if any(strcmp(labels_to_remove, labels{i}))
            indices_to_remove = [indices_to_remove i];
        end
    
        chanlocs_new(:,i).X = chansinfo(idx,1);
        chanlocs_new(:,i).Y = chansinfo(idx,2);
        chanlocs_new(:,i).Z = chansinfo(idx,3);
    
        [sph_theta, sph_phi, chanlocs_new(:,i).sph_radius] = cart2sph(chanlocs_new(:,i).X,chanlocs_new(:,i).Y,chanlocs_new(:,i).Z);
        chanlocs_new(:,i).sph_phi = rad2deg(sph_phi);
        chanlocs_new(:,i).sph_theta = rad2deg(sph_theta);
    
        [chanlocs_new(:,i).urchanlocs] = i;
        [~,chanlocs_new(:,i).theta,chanlocs_new(:,i).radius] = sph2topo([chanlocs_new(:,i).urchanlocs,chanlocs_new(:,i).sph_phi,chanlocs_new(:,i).sph_theta]);
        chanlocs_new(:,i).labels = char(chanlabels(idx));
    
        chanlocs_new(:,i).theta = chanlocs_new(:,i).theta + 90 ; %this was done because the positions were rotated by 90 degrees
    
    
    end
    chanlocs_new_removed = chanlocs_new;
    chanlocs_new_removed(:, indices_to_remove) = []; %channel locations of the required channels.
    EEG_raw =[];
    EEG_raw = EEG;
    EEG_raw.data(indices_to_remove, :) = []; %data after removing the extra channels.
    
      
    %% Creating the EEG struct
                % channel_indices = [];
                % ch_rqd= {'fp2','f4','c4','p4','fp1','f3','c3','p3','cz','pz','fz'};
                % 
                % for i = 1:length(ch_rqd)
                %     indx = find(strcmp({EEG_raw.chanlocs.labels}, ch_rqd{i}));
                % 
                % channel_indices = [channel_indices, indx];
                % 
                % end
                %%
             
                EEG_raw.trials = 1;
                EEG_raw.nbchan = size(EEG_raw.data,1);
                EEG_raw.pnts = size(EEG_raw.data,2);
                EEG_raw.srate = 256; %Hz sampling rate
                EEG_raw.xmin = 0;
                EEG_raw.xmax = size(EEG_raw.data,2)/EEG_raw.srate;
                EEG_raw.times = linspace(EEG_raw.xmin,EEG_raw.xmax,EEG_raw.pnts);
                EEG_raw.etc = [];
    
                %reading channel locations 
                EEG_raw.chanlocs = chanlocs_new_removed;
    %% Resampling the EEG_raw data to match that of EGG sampling rate
    
                EEG_raw = pop_resample(EEG_raw,250);
    
    %% Trimming some data at the end because it is just flat 
    
                end_rem_dur = 5; % had flatline totally for 10 seconds in M4_BO, M4_exp, it was 2 seconds at the end.
                %M7 raw - 4 , M7- BO-6.
                EEG_pop = pop_select(EEG_raw,"time",[EEG_raw.xmin EEG_raw.xmax-end_rem_dur]);
                fprintf('Data removal done');
     %% Filtering the data (FIR filter)
    
                EEG_filt = pop_eegfiltnew(EEG_pop, 'locutoff',  0.5, 'hicutoff',  40, 'filtorder', 9000, 'plotfreqz', 0);
                % this gives better results
    %  %% to visualise in GUI
    % 
    % %setting the normalised data in eeglab 
    % eeglab
    % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG_raw, CURRENTSET, 'setname', 'new', 'gui', 'off');
    % %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'new2', 'gui', 'off');
    % eeglab redraw
    
    %% Remove bad channels using clean_channels function
    
    %not sure if this is needed.. need to plot the scroll data and check 
    
                % EEG_filt_rmchan = clean_channels(EEG_filt);
                % fprintf('Bad channels removed');
    
    %% Performing ICA
      
                ch_list = 1:EEG_filt.nbchan;
    
                EEG_filt = pop_runica(EEG_filt,'runica');
                EEG_filt.icachansind = double(1:EEG_filt.nbchan);
                EEG_filt = iclabel(EEG_filt);
        
                fprintf('ICA done\n')
                %%
    
                classes = EEG_filt.etc.ic_classification.ICLabel.classes;
                cls_scores = EEG_filt.etc.ic_classification.ICLabel.classifications;
                
                % Display class names
                % disp('ICLabel Classes:');
                % disp(classes);
                % 
                % %Display classification scores for the first component
                % disp('Classification scores for the first component:');
                % disp(cls_scores(1, :));
                % 
                % for i = 1:length(classes)
                %     fprintf('Class %d: %s\n', i, classes{i});
                % end
               
    %%           
    plots_topo= pop_topoplot(EEG_filt, 0, 1:size(EEG_filt.icaweights, 1), 'Independent Components', 0, 'electrodes', 'on');
    
    
    %% plotting the components with the the percentages of each class
    
    num_components = size(EEG_filt.icaweights, 1);
    num_classes = length(classes);
    figure;
    for comp = 1:num_components
        % Create subplot for each component
        ax = subplot(ceil(sqrt(num_components)), ceil(sqrt(num_components)), comp, 'Parent', gcf);
        
        % Plot the topography of the component
        topoplot(EEG_filt.icawinv(:, comp), EEG_filt.chanlocs, 'electrodes', 'off');
        title(sprintf('IC %d', comp));
        
        % Calculate and display the percentages of each class
        percentages = cls_scores(comp, :) * 100;
        percentage_text = '';
        for cls_idx = 1:num_classes
            percentage_text = sprintf('%s%.1f%% %s\n', percentage_text, percentages(cls_idx), classes{cls_idx});
        end
        
        % Display the classification percentages below the topography
        text(1.2, 0.5, percentage_text, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontSize', 12, 'Units', 'normalized', 'Parent', ax);
        
        % Remove axis for cleaner presentation
        axis(ax, 'off');
    end
    
    
    %% Remove bad components 
    
    
    % should i set the criteria on some basis or use this one itself?
    
    
                th_signal = 0.80; % brain component with less than 5% confidence is removed
                classes = EEG_filt.etc.ic_classification.ICLabel.classes; %classes 
                cls_score = EEG_filt.etc.ic_classification.ICLabel.classifications;%classification scores
                bad_comp = []; %to store bad components
    
                for cmp = 1:size(cls_score, 1)
                    if any(cls_score(cmp, 2:6) > th_signal) || any(cls_score(cmp,1)<0.05)
                        bad_comp = [bad_comp, cmp];
                    end
                  
                end
                EEG_ica = pop_subcomp(EEG_filt, bad_comp, 0);
        
                fprintf('Bad components removed\n');
    
    plots_topo_rm= pop_topoplot(EEG_ica, 0, 1:size(EEG_ica.icaweights, 1), 'Independent Components', 0, 'electrodes', 'on');
    %%
    addpath('/Users/adrijachatterjee/Library/Application Support/MathWorks/MATLAB Add-Ons/Collections/EEGLAB/plugins/clean_rawdata-master');
    %EEG_ica= pop_clean_rawdata(EEG_ica);
    EEG_ica1= clean_rawdata(EEG_ica,5,[0.25 0.75],0.8,4,5,-1);
    % function cleanEEG = clean_rawdata(EEG, arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window)

     %% Interpolate bad channels
                EEG_interpol = pop_interp(EEG_ica1, EEG_raw.chanlocs, 'spherical');
                fprintf('Bad channels interpolated\n');
    
     %% Re-reference the data
                EEG_reref = pop_reref(EEG_interpol,[]);
                fprintf('Data rereferenced\n');
    % %%
    % eeglab
    % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG_reref, CURRENTSET, 'setname', 'new', 'gui', 'off');
    % 
    % eeglab redraw
    %              
    %% Save the pre-processed file.         
                % addpath('/Users/adrijachatterjee/Downloads/Preprocessed_setfiles');
                EEG_reref.setname = Rawfiles(k).name;
                EEG_reref.filepath = destination_path;
                name = append(Rawfiles(k).name(1:end-8));
                pop_saveset(EEG_reref,'filename', name ,'filepath', destination_path);


        fprintf('saved dataset\n'); 
% end
%% END
            