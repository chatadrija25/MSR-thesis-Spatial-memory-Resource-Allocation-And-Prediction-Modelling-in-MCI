% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
%Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% merged_table contains trial wise behavioural and electrophysiological
%features for each participant. 

% load('MMN_connectivity.mat'); % latest mat files with Mismatch negativity
% markers 

% This file connects the code to compute connectivity across regions and
% different frequency bands. This connectivity measures was obtained to
% understand the frontal-parietal dynamics and resource neural alloctaion
% under cognitive overload in MCI. 

% Connectivity was computed between the parietal and frontal electrode using trial-level data 
% Connectivity was also computed between the data logged in with standard and deviant auditory
% tone Mismatch negativity markers across the same regions and bands. 

% The code also runs simulations to check if ms_cohere() function can be
% used to compute connectivity across different frequency band. Hence,
% connectivity was compared across random-random(baseline), theta-beta, theta and theta modulated beta,
% beta and beta modulated theta.

%1.random-random mscohere()-  cxy_1000_rn
%2.theta-beta mscohere()- cxy_1000_th_beta
%3.theta and theta mod beta mscohere()- cxy_th_thb
%4 beta and beta modulated theta mscohere()- cxy_beta_modbeta

%% Previous mat files 
% load('/Users/adrijachatterjee/Downloads/codes/Final_eyecheckGED.mat');
% load('/Users/adrijachatterjee/Downloads/Coherence_thth.mat'); dont use
% this use final_th_thbt.mat % load('/Users/adrijachatterjee/Downloads/coherence_final_th&th_bt.mat');

%% Rough structure created to facilitate coding the final struct: 

% for each ppt 
%     for each trial 
%         for c1 
%             for c2 
%                 mscohere
%             end 
%         end 
%         avg 
%     end 
% end 
% later, we get into the electrodes of our interest. 


%% Code 1: Connectivity between frontal and parietal region electrodes- trial wise- in theta frequency range. 
%  theta and theta 

frontal_idx = [1, 4, 9]; % Frontal channel index
parietal_idx = [3, 6, 8]; % Parietal channel index

ppt_names = fieldnames(Final); % participant ids
band_nm = 'theta'; 
fs = 250; 
nfft = 250;

for d = 1:length(ppt_names)
    ppt_demo = ppt_names{d};
    
    for trial_no = 1:5
        tr_name = sprintf('Trial%d', trial_no);
        try
            e_tri = Final.(ppt_demo).(band_nm).(tr_name).EEG_trial; %trial data
        catch
            continue;  % Skip if trial doesn't exist
        end
        
        cohxy1 = [];  % Initializing for this trial
        
        for fi = 1:length(frontal_idx)
            c1 = frontal_idx(fi);
            x = e_tri.data(c1, :);
            N = round(size(x,2)/(fs*5));
            x_segment = buffer(x,N);
            for pi = 1:length(parietal_idx)
                c2 = parietal_idx(pi);
                y = e_tri.data(c2, :);
                y_segment = buffer(y, N);
                
                cxy = NaN(nfft/2+1, N); 
                
                for n = 1:N
                    x_seg = x_segment(:, n);
                    y_seg = y_segment(:, n);
                    
                    % Skip segment if too short
                    if length(x_seg) < 8 || length(y_seg) < 8
                        continue
                    end
                    
                    % win = min(length(x_seg), nfft);      % Window ≤ segment length
                    % noverlap = floor(win/2);             % 50% overlap
                    
                    [cxy(:, n), f] = mscohere(x_segment(:, n), y_segment(:, n), [], [], nfft, fs);
                end
                
                % Mean coherence across valid segments
                cohxy(fi, pi, :) = mean(cxy, 2);
            end
        end  
         freq_avg = mean(cohxy, 3); % Average over frequencies
         th_coh= mean(freq_avg(:)); % Average of the 9 values. 
        % Save coherence in the structure
        Final.(ppt_demo).(band_nm).(tr_name).cohxy_theta = th_coh; %saving per trial.
    end
end

%% Frontal theta and Parietal beta coherence: 

% Connectivity between frontal(theta) and parietal(beta) region electrodes- 
% trial wise

frontal_idx = [1, 4, 9]; % Frontal channel index
parietal_idx = [3, 6, 8]; % Parietal channel index

ppt_names = fieldnames(Final); % participant ids
band_nm1 = 'theta'; 
band_nm2= 'beta';
band_nm= 'theta_beta'
fs = 250; 
nfft = 250;

for d = 1:lenth(ppt_names)
    ppt_demo = ppt_names{d};
    
    for trial_no = 1:5
        tr_name = sprintf('Trial%d', trial_no);
        try %trial data extraction 
            e_tri_th = Final.(ppt_demo).(band_nm1).(tr_name).EEG_trial; % theta filtered data
            e_tri_bt = Final.(ppt_demo).(band_nm2).(tr_name).EEG_trial; % beta filtered data
        catch
            continue;  % Skip if trial doesn't exist
        end
        
        cohxy = [];  
        
         for fi = 1:length(frontal_idx)
            c1 = frontal_idx(fi);
            x = e_tri_th.data(c1, :);
            N = round(size(x,2)/(fs*5));
            x_segment = buffer(x,N);
            for pi = 1:length(parietal_idx)
                c2 = parietal_idx(pi);
                y = e_tri_bt.data(c2, :);
                y_segment = buffer(y, N);
                
                cxy = NaN(nfft/2+1, N);  
                
                for n = 1:N
                    x_seg = x_segment(:, n);
                    y_seg = y_segment(:, n);
                    
                    % Skip segment if too short
                    if length(x_seg) < 8 || length(y_seg) < 8
                        continue
                    end
                    
                    % win = min(length(x_seg), nfft);      % Window ≤ segment length
                    % noverlap = floor(win/2);             % 50% overlap
                    
                    [cxy(:, n), f] = mscohere(x_segment(:, n), y_segment(:, n), [], [], nfft, fs);
                end
                
                % Mean coherence across valid segments
                cohxy(fi, pi, :) = mean(cxy, 2);
            end
        end  
         freq_avg = mean(cohxy, 3); % Average over frequencies
         th_beta= mean(freq_avg(:)); % Average of the 9 values. 
        % Save coherence in the structure
       Final.(ppt_demo).(band_nm).(tr_name).cohxy_frth_prbt = th_beta; %saving per trial.
    end
end

%% Saving the values per trial across participants in the main struct 

load('/Users/adrijachatterjee/Downloads/coherence_final_th&th_bt.mat'); 
%saved the matrix after executing the above codes

load('merged_table.mat');   % loads variable 'merged_table' - main table
merged_table.coh_theta = NaN(height(merged_table),1);
merged_table.coh_theta_beta = NaN(height(merged_table),1);

for i = 1:height(merged_table)
    pid = merged_table.P_ID{i};      
    trial_no = merged_table.Trial(i); 
    str_tr= trial_no+1;
    tr_name = sprintf('Trial%d', str_tr);

    % Theta coherence
    if isfield(Final, pid) && isfield(Final.(pid), 'theta') && ...
       isfield(Final.(pid).theta, tr_name) && ...
       isfield(Final.(pid).theta.(tr_name), 'cohxy_theta')
       merged_table.coh_theta(i) = Final.(pid).theta.(tr_name).cohxy_theta;
    else
        merged_table.coh_theta(i) = NaN;
    end

    %Theta–Beta coherence
    if isfield(Final, pid) && isfield(Final.(pid), 'theta_beta') && ...
       isfield(Final.(pid).theta_beta, tr_name) && ...
       isfield(Final.(pid).theta_beta.(tr_name), 'cohxy_frth_prbt')
       merged_table.coh_theta_beta(i) = Final.(pid).theta_beta.(tr_name).cohxy_frth_prbt;
    else
        merged_table.coh_theta_beta(i) = NaN;
    end

end

% save('merged_table_with_coherence.mat', 'merged_table');
% disp('Saved updated table as merged_table_with_coherence.mat');

%% Connectivity between Standard (Frontal-Parietal) and Deviant (Frontal-Parietal): 

% For every trial, here, we are checking connectivity between
% standard tone logged connectivity and Deviant tone logged connectivity between 
% frontal and parietal regions (F-P) in broadnand frequency range. 

% load('MMN_connectivity.mat'); 

frontal_idx = [11, 6, 2]; %shreelekha's struct idx was different- event marker struct.
parietal_idx = [4, 8, 10];

ppt_names = fieldnames(Final);
band_nm= 'theta'; 
fs=250; 
nbchann= 9;  
nfft=250;
for d= 1:length(ppt_names)
    ppt_demo = ppt_names{d};
    for trial_no=1:5;
    tr_name = sprintf('Trial%d',trial_no);
    try
        e_tri = Final.(ppt_demo).(tr_name).EEG_deviant_norm;
    catch
            continue;
    end
        for fi = 1:length(frontal_idx) %Frontal channel indices only 
            c1 = frontal_idx(fi);
            x = e_tri(c1,:);
            x_segment = x;
            for pi = 1:length(parietal_idx)
                c2 = parietal_idx(pi);
                y = e_tri(c2,:);
                y_segment = y;
                
                % Compute coherence
                [cxy, f] = mscohere(x, y, [], [], nfft, fs);
                
                % Store full spectrum
                cohxy(fi, pi, :) = cxy;
            end
        end
        
        freq_avg = mean(cxy, 3);   % average over frequency dimension
        coh_broad = mean(freq_avg(:));  % average across all channel pairs
        
        % Store result
        Final.(ppt_demo).(tr_name).coh_dv_fp = coh_broad;
        
    end
end
%%  Same thing was done in theta band range. 


frontal_idx = [11, 6, 2]; % MMN data struct idx was different 
parietal_idx = [4, 8, 10];

ppt_names = fieldnames(Final);
band_nm= 'theta'; 
fs=250; 
nbchann= 9;  
nfft=250;
for d= 1:length(ppt_names)
    ppt_demo = ppt_names{d};
    for trial_no=1:5;
    tr_name = sprintf('Trial%d',trial_no);
    try
        e_tri = Final.(ppt_demo).(tr_name).EEG_deviant_norm_th; % Deviant marker logged EEG trial wise data
        % standard= EEG.standard_norm_th %same code was used by replacing
        % the variable.
    catch
            continue;
    end
        for fi = 1:length(frontal_idx) %Frontal channel indices only 
            c1 = frontal_idx(fi);
            x = e_tri(c1,:);
            x_segment = x;
            for pi = 1:length(parietal_idx)
                c2 = parietal_idx(pi);
                y = e_tri(c2,:);
                y_segment = y;
                
                % Computing coherence
                [cxy, f] = mscohere(x, y, [], [], nfft, fs);
                cohxy(fi, pi, :) = cxy;
            end
        end
        
        freq_avg = mean(cxy, 3);   % averaging  over frequency dimension
        coh_theta_dv = mean(freq_avg(:));  % averaging across all channel pairs
        % coh_theta_sn = mean(freq_avg(:));  % averaging across all channel pairs
        % Storing result
        Final.(ppt_demo).(tr_name).coh_theta_dev = coh_theta_dv; %
        %Final.(ppt_demo).(tr_name).coh_theta_stn = coh_theta_sn; % for standard marker 

    end
end

%% loaded into the final main table. 

load('merged_table.mat');   
merged_table.coh_standard_th = NaN(height(merged_table),1);
merged_table.coh_deviant_th = NaN(height(merged_table),1);
merged_table.coh_standard = NaN(height(merged_table),1);
merged_table.coh_deviant = NaN(height(merged_table),1);

for i = 1:height(merged_table)
    pid = merged_table.P_ID{i};      
    trial_no = merged_table.Trial(i); 
   
    str_tr = trial_no + 1; % adjusted according to the merged_table index. 
    tr_name = sprintf('Trial%d', str_tr);

      % Standard coherence
    if isfield(Final, pid) && ...
       isfield(Final.(pid), tr_name) && ...
       isfield(Final.(pid).(tr_name), 'coh_st_fp')

        merged_table.coh_standard(i) = Final.(pid).(tr_name).coh_st_fp;
    else
        merged_table.coh_standard(i) = NaN;
    end
    % Standard theta coherence 
    if isfield(Final, pid) && ...
       isfield(Final.(pid), tr_name) && ...
       isfield(Final.(pid).(tr_name), 'coh_theta_stn')

        merged_table.coh_standard_th(i) = Final.(pid).(tr_name).coh_theta_stn;
    else
        merged_table.coh_standard_th(i) = NaN;
    end
    % 
    %  Deviant coherence
    if isfield(Final, pid) && ...
       isfield(Final.(pid), tr_name) && ...
       isfield(Final.(pid).(tr_name), 'coh_dv_fp')

        merged_table.coh_deviant(i) = Final.(pid).(tr_name).coh_dv_fp;
    else
        merged_table.coh_deviant(i) = NaN;
    end
    % Deviant theta coherence 
    if isfield(Final, pid) && ...
       isfield(Final.(pid), tr_name) && ...
       isfield(Final.(pid).(tr_name), 'coh_theta_dev')
       
       merged_table.coh_deviant_th(i) = Final.(pid).(tr_name).coh_theta_dev;
    else
        merged_table.coh_deviant_th(i) = NaN;
    end
end

% save('merged_table_with_coherence.mat', 'merged_table');
% disp('Saved updated table as merged_table_with_coherence.mat');


%% STATISTICS AND MODEL PART 

%% Calculating correlation of switch with the connectivity values obtained 

x1 = merged_table.Switch;
y1 = merged_table.coh_theta;
y2 = merged_table.coh_theta_beta;

% point biserial (same function as Pearson)
[r1, p1] = corr(x1, y1, 'type', 'Pearson', 'rows', 'complete');
[r2, p2] = corr(x1, y2, 'type', 'Pearson', 'rows', 'complete');

fprintf('Theta: r = %.3f, p = %.4f\n', r1, p1);
fprintf('Theta-Beta: r = %.3f, p = %.4f\n', r2, p2);

%% ONLY THETA 
% for switch - 
group0_theta  = merged_table.coh_theta(merged_table.Switch == 0);
group1_theta  = merged_table.coh_theta(merged_table.Switch == 1);

[h_theta, p_theta] = ttest2(group0_theta, group1_theta);

%% for angle error - 
group0_stn= merged_table.coh_standard(merged_table.AE_cat == 0);
group1_stn = merged_table.coh_standard(merged_table.AE_cat == 1);

[h_tbeta, p_tbeta] = ttest2(group0_stn, group1_stn);

fprintf('standard coh t-test: p = %.4f\n', p_tbeta);

%% Checking if they are significant - theta_beta 

group0_theta  = merged_table.coh_theta(merged_table.Switch == 0);
group1_theta  = merged_table.coh_theta(merged_table.Switch == 1);

[h_theta, p_theta] = ttest2(group0_theta, group1_theta);

group0_tbeta = merged_table.coh_theta_beta(merged_table.Switch == 0);
group1_tbeta = merged_table.coh_theta_beta(merged_table.Switch == 1);

[h_tbeta, p_tbeta] = ttest2(group0_tbeta, group1_tbeta);

fprintf('Theta t-test: p = %.4f\n', p_theta);
fprintf('Theta-Beta t-test: p = %.4f\n', p_tbeta);


%% SAME MODEL WAS USED for all 
% only the connectivity variable was replaced accordingly. 

mdl1= fitglm(merged_table, 'AE_cat ~coh_standard_th + coh_deviant_th + ERP_Minima_100_400_  + diff');
disp(mdl1);
% AE_cat is egocentric angle error- categorical variable.


%% STATISTICS FOR MMN 
% Did same for MMN logged data - MISMATCH NEGATIVITY PARADIGM COHERENCE 

group0_dv= merged_table.coh_standard_th(merged_table.Group_logical== 0);
group1_dv = merged_table.coh_standard_th(merged_table.Group_logical == 1);

[h_tbeta, p_tbeta] = ttest2(group0_dv, group1_dv);

fprintf('standard coh t-test: p = %.4f\n', p_tbeta);

%% 
m_s= mean(group0_stn, 'omitnan'); % 0.3791
m_s_he= mean(group1_stn, 'omitnan'); % 0.3112
m_d= mean(group0_dv, 'omitnan'); % 0.3479
m_d_he= mean(group1_dv, 'omitnan'); % 0.3196



%% RUNNING THE SIMULATIONS TO CHECK THE MS_COHERE FUNCTION: 

% The code also runs simulations to check if ms_cohere() function can be
% used to compute connectivity across different frequency band. Hence,
% connectivity was compared across random-random(baseline), theta-beta, theta and theta modulated beta,
% beta and beta modulated theta.

%1.random-random mscohere()-  cxy_1000_rn
%2.theta-beta mscohere()- cxy_1000_th_beta
%3.theta and theta mod beta mscohere()- cxy_th_thb
%4 beta and beta modulated theta mscohere()- cxy_beta_modbeta

%% simulating 

fs = 250;             % Sampling frequency (Hz)
t = 0:1/fs:60;          % Time vector (60 seconds)

% Frequencies
f_theta = 6;           % Theta frequency (Hz)
f_beta = 20;           % Beta frequency (Hz)

num=250*60;
% mu=0; sigma=1;
% rnsig= mu+random(0,num)*sigma;

rnsig = random('Normal', 0, 1, num, 1);

theta = sin(2*pi*f_theta*t).*rand(size(t))*0.01;
beta = sin(2*pi*f_beta*t).*rand(size(t))*0.01;
theta_mod_beta = theta .* beta;


 %% 
% nfft=250;
% fs=250;
% N = round(size(theta,2)/(fs*5)); 
% x_segment = buffer(theta,N);
% y_segment = buffer(beta,N);
% for n = 1:N 
%     [cxy(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
% end

%% Calculating MEAN FOR THAT FREQUENCY POINT ONLY f=6 ; theta mod beta with random first. 

cxy_1000_rn= zeros(1,1000);
for i= 1:1000
    N = round(size(theta,2)/(fs*5)); 
    rnsig=random('Normal', 0, 1, 250*60, 1);
    x_segment = buffer(rnsig,N);
    y_segment = buffer(theta_mod_beta,N);
    idx_theta = dsearchn(f, 6);
    for n = 1:N 
        [cxythb(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
    end
    meanthb= mean(cxythb,2); 
    cxy_1000_rn(i)= meanthb(idx_theta);
end

%% Calculating MEAN FOR THAT FREQUENCY POINT ONLY f=6; then theta with theta-mod-beta. 

cxy_1000= zeros(1,1000);
for i= 1:1000
    N = round(size(theta,2)/(fs*5)); 
    % rnsig=random('Normal', 0, 1, 250*60, 1);
    x_segment = buffer(theta,N);
    y_segment = buffer(theta_mod_beta,N);
    idx_theta = dsearchn(f, 6);
    for n = 1:N 
        [cxythb(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
    end
    meanthb= mean(cxythb,2); 
    cxy_1000(i)= meanthb(idx_theta);
end

%% calculating MEAN Overall

cxy_1000_mean= zeros(1,1000);
for i= 1:1000
    N = round(size(theta,2)/(fs*5)); 
    % rnsig=random('Normal', 0, 1, 250*60, 1);
    x_segment = buffer(theta,N);
    y_segment = buffer(theta_mod_beta,N);
    idx_theta = dsearchn(f, 6);
    for n = 1:N 
        [cxythb(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
    end
    meanthb= mean(cxythb,2); 
    cxy_1000_mean(i)= mean(meanthb,1);
end
%% FINAL CODE: 
% Firstly, checking if theta-beta is different from a random-random
% coherence measure. 

% Then, checking if theta-beta distribution is different from
% theta_mod_beta-theta distribution and beta-beta_modulated_theta
% coherence. 

%% CHECK: IF MS_Cohere() can be used for two different frequency bands coupling 

%1.theta-beta mscohere()- cxy_1000_th_beta
%2.random mscohere()-  cxy_1000_rn
%3.theta and theta mod beta mscohere()- cxy_th_thb
%4 beta and beta modulated theta mscohere()- cxy_beta_modbeta

fs=250; nfft=250;
cxy_beta_modbeta= zeros(1,1000);
for i= 1:1000
    fs = 250;               % Sampling frequency (Hz)
    t = 0:1/fs:60;          % Time vector (60 seconds)
    
    % Frequencies
    f_theta = 6;           % Theta frequency (Hz)
    f_beta = 20;           % Beta frequency (Hz)
  
    theta = sin(2*pi*f_theta*t).*rand(size(t))*0.001;
    beta = sin(2*pi*f_beta*t).*rand(size(t))*0.001;
    % theta_mod_beta= theta .* beta;
    beta_mod_theta = beta .* theta;

    N = round(size(theta,2)/(fs*5));
    % rnsig=random('Normal', 0, 1, 250*60, 1);
    % rnsig2= random('Normal',0,1,250*60,1);
    x_segment = buffer(theta,N);
    y_segment = buffer(beta_mod_theta,N);
   
    for n = 1:N
        [cxythb(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
    end
    meanthb= mean(cxythb,2); 
    cxy_beta_modbeta(i)= mean(meanthb,1);
end



%% We compared the four distributions 

figure(1); 
hold on;

histogram(cxy_1000_rn, 'DisplayStyle', 'bar', 'FaceAlpha', 0.4);
histogram(cxy_1000_th_beta, 'DisplayStyle', 'bar', 'FaceAlpha', 0.4);
histogram(cxy_1000_th_thb, 'DisplayStyle', 'bar', 'FaceAlpha', 0.4);
histogram(cxy_beta_modbeta, 'DisplayStyle', 'bar', 'FaceAlpha', 0.4);


%checked the difference between rn and th_beta , highly significant in the
%range of 1.0083e-10; check ttest(), [h,p,ci,stats] = ttest(cxy_1000_rn, cxy_1000_th_beta);
%checks for shape of distribution
% [h,p,ksstat] = kstest2(cxy_1000_rn, cxy_1000_th_beta);
% fprintf('KS test p-value = %.6f\n', p);
%Non-parametric mean/median difference
%p = ranksum(cxy_1000_rn, cxy_1000_th_beta);fprintf('Mann-Whitney p-value = %.6f\n', p);

hold off;
legend('RN','Theta-Beta','Theta-mod-Theta','Beta-mod-Beta');
title('Comparison of Histograms');
xlabel('Value');
ylabel('Count');







%% EXTRA codes - initial tryouts 

%% Overall connectivity across trials 

% % load('MMN_connectivity.mat'); % latest mat files with Mismatch negativity
% % markers 
% 
% ppt_names = fieldnames(Final);
% band_nm= 'theta'; 
% fs=250; 
% nbchann= 9;  % no. of channels
% nfft=250;
% for d= 1:2
%     ppt_demo = ppt_names{d};
%     for trial_no=1:5;
%     tr_name = sprintf('Trial%d',trial_no);
%     try
%         e_tri = Final.(ppt_demo).(band_nm).(tr_name).EEG_trial; %trial data 
%     catch
%             continue;
%     end
%         for c1=1:nbchann
% %               disp(c1);
%                 x = e_tri.data(c1,:);
%                 N = round(size(x,2)/(fs*5)); 
%                 x_segment = buffer(x,N);
%                 for c2=1:nbchann
%                     y = e_tri.data(c2,:);
%                     y_segment = buffer(y,N);
% 
%                     csdxy = [];
%                     csdx = [];
%                     csdy = [];
%                     for n = 1:N 
%                         [cxy(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
%                     end
%                     cohxy(c1,c2,:) = mean(cxy,1);
%                 end
%         end
%         Final.(ppt_demo).(band_nm).(tr_name).cohxy = cohxy;
%         cohxy=[];
%     end 
% 
% end 

%%
% %code 1: Connectivity between frontal and parietal region electrodes- trial
% %wise- in theta frequency range. 
% 
% % theta and theta 
% 
% frontal_idx = [1, 4, 9]; % Frontal channel index
% parietal_idx = [3, 6, 8]; % Parietal channel index
% 
% ppt_names = fieldnames(Final); % participant ids
% band_nm= 'theta'; 
% fs=250; 
% nfft=250;
% for d= 8
%     ppt_demo = ppt_names{d};
%     for trial_no=5
%     tr_name = sprintf('Trial%d',trial_no);
%     try
%         e_tri = Final.(ppt_demo).(band_nm).(tr_name).EEG_trial;
%     catch
%             continue;
%     end
%         for fi = 1:length(frontal_idx) % Frontal channel indices only 
%             c1 = frontal_idx(fi);
%             x = e_tri.data(c1,:);
%             N = round(size(x,2)/(fs*5)); 
%             x_segment = buffer(x,N);
%             for pi = 1:length(parietal_idx)
%                 c2 = parietal_idx(pi);
%                 y = e_tri.data(c2,:);
%                 y_segment = buffer(y,N);
%                 for n = 1:N  % calculate coherence for all segments
%                     x_seg = x_segment(:, n);
%                     y_seg = y_segment(:, n);
% 
%                     % Skip segment if too short(Ms-cohere can't handle less
%                     % than 8) 
%                     if length(x_seg) < 8 || length(y_seg) < 8
%                         continue
%                     end
% 
%                     [cxy(:, n), f] = mscohere(x_segment(:, n), y_segment(:, n), [], [], nfft, fs);
%                 end
% 
%                 % Mean across segments
%                 cohxy(fi, pi, :) = mean(cxy, 2);
%             end
% 
%         end 
%         %for saving in the struct 
%         % Final.(ppt_demo).(band_nm).(tr_name).cohxy_theta = cohxy;
% 
%     end 
% 
% end 
%% SIMULATION CODE SAMPLE 


% fs=250; nfft=250;
% cxy_1000_rn= zeros(1,1000);
% for i= 1:1000
%     fs = 250;             % Sampling frequency (Hz)
%     t = 0:1/fs:60;        % Time vector (60 seconds)
% 
%     % Frequencies
%     f_theta = 6;           % Theta frequency (Hz)
%     f_beta = 20;           % Beta frequency (Hz)
% 
% 
%     theta = sin(2*pi*f_theta*t).*rand(size(t))*0.01;
%     beta = sin(2*pi*f_beta*t).*rand(size(t))*0.01;
%     % random= sin(2*pi*f_noise*t);
%     theta_mod_beta = theta .* beta;
% 
% 
%     N = round(size(theta,2)/(fs*5));
%     rnsig=random('Normal', 0, 1, 250*60, 1);
%     x_segment = buffer(rnsig,N);
%     y_segment = buffer(theta_mod_beta,N);
%     % idx_theta = dsearchn(f, 6);
%     for n = 1:N
%         [cxythb(:,n),f] = mscohere(x_segment(:,n),y_segment(:,n),[],[],nfft,fs);
%     end
%     meanthb= mean(cxythb,2); 
%     cxy_1000_rn_mn(i)= mean(meanthb,1);
% end
