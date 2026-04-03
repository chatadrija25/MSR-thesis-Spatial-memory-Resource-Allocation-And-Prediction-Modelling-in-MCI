
% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% For every participant, we have one raw EGG file. From that, 
% we generate 4 files filtered across - Bradygastric, Normogastric,
% Tachygastric and Broadband with their entire data experiment(includes baseline. 

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in
%% Read files

% mydir_egg = '/Users/adrijachatterjee/Downloads/txt files'; 
mydir_egg = '/Users/adrijachatterjee/Downloads/Malnutrition EEG and EGG files'; 
files = dir(fullfile(mydir_egg, '*txt'));
for a =1:length(files)
    currentfile = files(a).name;
    EGG_id= currentfile; %ppt_id
    [~,EGG_id, ~] = fileparts(currentfile);
    fullpath = fullfile(mydir_egg, currentfile);  %Construct the full path
    egg_raw_file = readtable(fullpath, ReadVariableNames=true); % Read the file using 
    low=[0.0083,0.0083,0.03,0.07];
    high=[0.15,0.03,0.07,0.15];
    egg_length = size(egg_raw_file,1);
    egg_sig_padded = [table2array(egg_raw_file(:,[7,8,9])); zeros(300000 - egg_length,3)];
   
%% filter parameters 
    for h=1:4
        srate               = 250;
        low_frequency       = low(h);
        high_frequency      = high(h);
        transition_width    = 0.001;
        nyquist             = srate/2;
        ffreq(1)            = 0;
        ffreq(2)            = low_frequency - transition_width;
        ffreq(3)            = low_frequency;
        ffreq(4)            = high_frequency;
        ffreq(5)            = high_frequency + transition_width;
        ffreq(6)            = nyquist;
        ffreq               = ffreq/nyquist;
        fOrder              = 3; % in cycles
        filterOrder         = fOrder*fix(srate/(low_frequency)); % in samples
        idealresponse       = [ 0 0 1 1 0 0 ];
        filterweights       = fir2(filterOrder,ffreq,idealresponse);
    
%% filter of tachy, brady, normo
disp('Filtering EGG - this will take some time');
filt_data_crop = filtfilt(filterweights,1,egg_sig_padded);
filt_data_crop = filt_data_crop(1:egg_length,:);

%%

if h==1
    save(['/Users/adrijachatterjee/Downloads/Mal_preprocess/broad/' EGG_id '.mat'], 'filt_data_crop');
elseif h==2
    save(['/Users/adrijachatterjee/Downloads/Mal_preprocess/brady/' EGG_id '.mat'], 'filt_data_crop');
elseif h==3
    save(['/Users/adrijachatterjee/Downloads/Mal_preprocess/normo/' EGG_id '.mat'], 'filt_data_crop');
elseif h==4
    save(['/Users/adrijachatterjee/Downloads/Mal_preprocess/tachy/' EGG_id '.mat'], 'filt_data_crop');
end

    end
end 


