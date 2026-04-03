
%% 
% The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% The code contains the function to compute the power spectrum. 
% It is a function, which takes the signal and the returns the maximum power 
% (if there are multiple peaks, returns the max among those). Its for
% easier computation during building struct. 

% Uses: pwelch(). 

% For any query, please contact: 
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% 
load('Mal_preprocess/brady/N3C1.mat');
d= floor(size(filt_data_crop,1)/250);
% function [peaks, max_peak] = power_spec(S1, d)
        fs = 250;           % Sampling frequency
        wl = 60 * fs;       % Window length in samples (60 seconds)
        overlap = 30 * fs;  % Overlap in samples (30 seconds)
        dur= d;          % Duration in seconds
        pxx = [];
        freq = [];

        step = wl - overlap;  % Step size in samples (30 seconds)
        num_windows = floor((dur * fs - overlap) / step);  % Number of windows

        %%
        S1= filt_data_crop;

        if num_windows==0
            egg_sig = S1;
            pad_length = 2000;
            wl= dur*fs;
            
            egg_sig_padded = [zeros(pad_length, size(egg_sig, 2)); egg_sig; zeros(pad_length, size(egg_sig, 2))];
            fft_length = size(egg_sig_padded, 1);
            [pxx, freq] = pwelch(egg_sig_padded, wl, overlap, fft_length, fs);
            % power_norm = pxx./ sum(pxx); %normalizing the PSD 
        
        
        else  
        for w = 1:num_windows
            start_idx = (w - 1) * step + 1;
            stop_idx = start_idx + wl - 1;
        
           
            egg_sig = S1(start_idx:stop_idx, :);
            % disp(start_idx);
            % disp(stop_idx);
            % egg_sig_br = S1(start_idx:stop_idx, :);
        
            % Zero-pad signals
            pad_length = 2000;
            egg_sig_padded = [zeros(pad_length, size(egg_sig, 2)); egg_sig; zeros(pad_length, size(egg_sig, 2))];
            % egg_sig_broad_padded = [zeros(pad_length, size(egg_sig_br, 2)); egg_sig_br; zeros(pad_length, size(egg_sig_br, 2))];
        
            % FFT length (after padding)
            fft_length = size(egg_sig_padded, 1);
        
            % Calculate PSD
            
            % [pxx_filt(:, :, w), freq] = pwelch(egg_sig_broad_padded, wl, overlap, fft_length, fs);
            [pxx(:, :, w), freq] = pwelch(egg_sig_padded, wl, overlap, fft_length, fs);
             % time_samples,
           
        end

        end
%%
            psd = mean(pxx,3);
            power_norm = psd./ sum(psd); %normalizing the PSD 
            % psd_f= mean(pxx_filt,3);
            
            
            freq_idx= find(freq<0.15);
            
            figure(1);
        
            plot(freq(freq_idx), power_norm(freq_idx));
            % figure(2);
            % plot(freq(freq_idx), psd_f(freq_idx));
            % 
            [peaks, locs] = findpeaks(power_norm(freq_idx));
            if numel(peaks)==1
                max_peak= peaks;
            else 
                max_peak = max(peaks);
            end 
% end 