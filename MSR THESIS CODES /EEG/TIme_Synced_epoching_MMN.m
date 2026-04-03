% The authors of this code are Shreelekha BS, Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.

% About the code: 
% The code uses event markers of mismatch negativity(MMN)(Standard and Deviant) from the trials of the experiments and 
% calculates the ERP(100-400ms) range. 

% To determine the MMN peak, the difference waveform in each channel was searched for the five most negative
% local minima. For each minimum, the mean amplitude within a ±10 sample window was computed, and 
% the minimum of these local averages was saved as the peak MMN amplitude. 
% Electrodes were classified into frontal (Fz, F3, F4), central (Cz, C3, C4), and parietal (Pz, P3, P4) regions. 
% Regional MMN values were calculated as the mean of constituent channel amplitudes.

% For any query, please contact: 
% Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% Load the struct with trial data and event markers.

%  load Final_Arrary_complete.mat % MAIN STRUCT - only contains broadband
%  filtered trial wise data which are logged with mismatch negativity(MMN)
%  Markers- Standard and Deviant. 

load('MMN_connectivity.mat'); %contains broadband and theta-filtered
%  filtered trial wise data which are logged with mismatch negativity(MMN)
%  Markers- Standard and Deviant. 

%% MAIN code 

% Plottig trialwise channel data
% participant_list = ["F2", "F3", "F4", "M2", "M3", "M4", "M5", "M6", "M7", "M8"];
participant_list = ["F2", "F3", "F5", "F6", "F7", "F8","M4", "M5", "M7", "M8", "M9","M11","M12", "M14"];

datafields_normalised = fieldnames(Final);

[isMember, idx] = ismember(datafields_normalised, participant_list);
data = datafields_normalised(isMember);

% channels_19 = [2, 4, 6, 8, 9, 10, 11];
% channels_32 = [4, 8, 3, 7, 17, 18, 19];
% channel_names = ["F4", "P4", "F3", "P3", "Cz", "Pz", "Fz"];
% channel_list = [];

% Initialize the table to store data
resultsTable = table('Size', [0 15], ...
                     'VariableTypes', ['string', repmat({'double'}, 1, 14)], ...
                     'VariableNames', {'NAME', ...
                                       'Channel_1', 'Channel_2', 'Channel_3', 'Channel_4', 'Channel_5', ...
                                       'Channel_6', 'Channel_7', 'Channel_8', 'Channel_9', 'Channel_10', 'Channel_11', ...
                                       'FRONTAL', 'CENTRAL', 'PARIETAL'});

% Define channel indices for regions
frontal_channels = [11, 6, 2];
central_channels = [9, 7, 3];
parietal_channels = [4, 8, 10];

% Loop through participants
for i = 1:length(data)
    for t = 1:length(fieldnames(Final.(data{i}))) % Adjust this
        dummy_EEG = Final.(data{i}).(append("Trial", string(t))).EEG; % Adjust this
        %Added by Adrija 
        dummy_EEG = pop_eegfiltnew(dummy_EEG, 'locutoff', 4 , 'hicutoff',  7, 'filtorder', 9000, 'plotfreqz', 0);


        try
            % Perform standard and deviant epoching

            EEG_standard = pop_epoch(dummy_EEG, {1}, [-0.5 1]); % 1- standard, 2- deviant events in the struct
            try
                EEG_standard = pop_rmbase(EEG_standard, [-0.5 0]);
            catch ME
                if contains(ME.message, 'Bad time range')
                    warning('Skipping baseline removal for standard epochs due to bad time range.');
                else
                    rethrow(ME);
                end
            end
        
            EEG_devient = pop_epoch(dummy_EEG, {2}, [-0.5 1]);
            try
                EEG_devient = pop_rmbase(EEG_devient, [-0.5 0]);
            catch ME
                if contains(ME.message, 'Bad time range')
                    warning('Skipping baseline removal for deviant epochs due to bad time range.');
                else
                    rethrow(ME);
                end
            end
        
            % Autoreject bad epochs for EEG_standard
            try
                [EEG_standard, ~] = pop_autorej(EEG_standard, 'maxrej', 10, 'nogui', 'on');
            catch ME
                warning('Skipping artifact rejection for standard epochs due to an error: %s', ME.message);
                % Continue to the next step
            end
            
            % Autoreject bad epochs for EEG_devient
            try
                [EEG_devient, ~] = pop_autorej(EEG_devient, 'maxrej', 10, 'nogui', 'on');
            catch ME
                warning('Skipping artifact rejection for deviant epochs due to an error: %s', ME.message);
                % Continue to the next step
            end
        
        catch ME
            % Check if the error is related to empty epochs
            if contains(ME.message, 'empty epoch range (no epochs were found)')
                warning('Skipping trial %s due to empty epoch range.', append(data{i}, "_Trial", string(t)));
                continue; % Skip to the next trial
            else
                % Re-throw error for debugging if it's not related to epochs
                rethrow(ME);
            end
        end

        % Compute ERPs- across standards and deviants for a single trial
        erp_standard = mean(EEG_standard.data, 3);
        erp_devient = mean(EEG_devient.data, 3);

       % saving in the struct in trial as normal_std and normal_dev
        normal_standard = (erp_standard-mean(erp_standard,2));  
        normal_deviant = (erp_devient- mean(erp_devient,2));
        Final.(data{i}).(append("Trial", string(t))).EEG_standard_norm_th= normal_standard;
        Final.(data{i}).(append("Trial", string(t))).EEG_deviant_norm_th = normal_deviant;

        Final_erp = ((erp_devient- mean(erp_devient,2))- (erp_standard-mean(erp_standard,2)))%%%% this is what I have used till April 16th 2025, never been edited

        % figure;
        % plot(normal_standard(1,:));
        % hold on
        % plot(normal_deviant(1,:));
        % legend('stan','deviant')
        % hold on 
        % plot(Final_erp(1,:));
        % legend('stan','deviant','difference')
        % hold off
        
%% -------------------------------------TRUNCATING TO DESIRED LENGTH----------------------------------------------------
        if length(erp_standard) > 375
            % final_erp_truncated = Final_erp(:,[250:end])
            print(".........IT HAS 500 hertzzzz...........................................................")
            final_erp_truncated = Final_erp(:,[300:450]) % use this for 100-400 ms
            final_std_truncated = normal_standard(:,[300:450])
            final_dev_truncated = normal_deviant(:,[300:450])
        else
            % final_erp_truncated = Final_erp(:,[125:end])
            final_erp_truncated = Final_erp(:,[150:225]) %use this for 100-400 ms
            final_std_truncated = normal_standard(:,[150:225])
            final_dev_truncated = normal_deviant(:,[150:225])
        end
        
%------------------------------------- FINDING MINIMA ----------------------------------------------------

        % Initialize to store the minimum average value for each channel
        channel_min_averages = zeros(11, 1); % For 11 channels
        channel_max_averages= zeros(11,1);
        
        % Loop through each channel
        for l = 1:11
            % Extract the current channel's data
            channel_data = final_erp_truncated(l, :);
        
            % Sort the data and get the indices of the top 5 minima
            [sorted_values, sorted_indices] = sort(channel_data, 'ascend'); % Sort in ascending order
            min_indices = sorted_indices(1:5); % Top 5 minima indices % top 5 max indices
        
            % Initialize an array to store averages around each minimum
            averages = zeros(1, 5);
        
            % Calculate averages around each minimum
            for k = 1:5
                current_index = min_indices(k);
        
                % Define the range for averaging (previous 10, current, and next 10 points)
                start_index = max(1, current_index - 10); % Avoid going out of bounds
                end_index = min(size(final_erp_truncated, 2), current_index + 10); % Avoid out-of-bounds indexing
        
                % Compute the average over the range
                averages(l) = mean(channel_data(start_index:end_index));
            end
        
            % Find the minimum of these averages
            channel_min_averages(l) = min(averages);
            % channel_max_averages(l) = max(averages);

        end
        
        % Display the results
        disp('Minimum averages for each channel:');
        disp(channel_min_averages);
%% -------------------------------------EXTRACTING PARAMETERS FOR PLOTTING----------------------------------------------------


         % Define the channel to plot (e.g., channel 1)
        channel_to_plot = 9;

        % Extract the data for the chosen channel
        channel_data = final_erp_truncated(channel_to_plot, :);
        % Extracting for normal and deviant

        % Find the top 5 minima and their indices
        [sorted_values, sorted_indices] = sort(channel_data, 'ascend'); % Sort in ascending order
        min_indices = sorted_indices(1:5); % Top 5 minima indices
        % ###############chnaged from sorted_indices(1:5) to sorted
        % indices(end-5:end)

        % Initialize an array to store averages around each minimum
        averages = zeros(1, 5);

        % Loop through the top 5 minima to calculate averages
        for m = 1:5
            current_index = min_indices(m);

            % Define the range for averaging (previous 10, current, and next 10 points)
            start_index = max(1, current_index - 10); % Avoid out-of-bounds indexing
            end_index = min(length(channel_data), current_index + 10); % Avoid out-of-bounds indexing

            % Compute the average over the range
            averages(m) = mean(channel_data(start_index:end_index));
        end

        % Find the minimum average and its corresponding index
        [~, final_minima_idx] = min(averages); % Index of the minimum average in the averages array 
        % ########### changed min(averages) to max(averages)
        final_minima_position = min_indices(final_minima_idx); % Get the actual position in the signal
%-------------------------------------STANDARD AND DEVIANT WITH ERP----------------------------------------------------
        % normal_standard_truncated = normal_standard(:,[250:end])
        % normal_deviant_truncated = normal_deviant(:,[250:end])


%% ---------------------- Plot ERP with Standard and Deviant (Zoomed View) ----------------------
        % Compute the same window as used for the minima average
        start_index = max(1, final_minima_position - 10);
        end_index = min(size(channel_data, 2), final_minima_position + 10);

        % Extract corresponding time axis
        time_vector = dummy_EEG.times(1, t + 250 - 1); % Adjusted to match truncated ERP window
        % window_time = time_vector(start_index:end_index);  % Optional: you can use 1:end_index-start_index+1 if EEG.times doesn't match

        % Get channel signals for this range
        final_erp_segment = final_erp_truncated(channel_to_plot, start_index:end_index);
        standard_segment = final_std_truncated(channel_to_plot, start_index:end_index);
        deviant_segment = final_dev_truncated(channel_to_plot, start_index:end_index);

        % Plot all three
        figure;
        plot(final_erp_segment, 'k', 'LineWidth', 1.8); hold on;
        plot(standard_segment, 'b--', 'LineWidth', 1.2);
        plot(deviant_segment, 'r--', 'LineWidth', 1.2);

        legend('ERP Difference', 'Standard', 'Deviant');
        title(['Zoomed ERP View: ', data{i}, ' | Trial ', num2str(t), ' | Channel ', num2str(channel_to_plot)]);
        xlabel('Sample Index (Window)');
        ylabel('Amplitude (uV)');
        grid on;
        hold off;



%-------------------------------------PLOTTING-------------------------------------------------------------------------  
        % 
        % % Plot the full signal with the minima
        % figure;
        % plot(channel_data, 'b-', 'LineWidth', 1.5); % Plot the full signal
        % hold on;
        % %with standard and deviant
        % 
        % % Mark the top 5 minima
        % scatter(min_indices, channel_data(min_indices), 100, 'r', 'filled', 'DisplayName', 'Top 5 Minima');
        % 
        % % Mark the final chosen minimum
        % scatter(final_minima_position, channel_data(final_minima_position), 150, 'g', 'filled', 'DisplayName', 'Final Chosen Minimum');
        % 
        % % Add legend, labels, and title
        % legend('Signal', 'Top 5 Minima', 'Final Chosen Minimum', 'Location', 'best');
        % xlabel('Sample Index');
        % ylabel('Amplitude');
        % title(['Channel ', num2str(channel_to_plot), ': Final ERP with Minima']);
        % grid on;
        % hold off;

%--------------------------------------------LOADING RESULTS (minima)--------------------------------
  

        
        % frontal_avg = mean(channel_min_averages(frontal_channels));
        % central_avg = mean(channel_min_averages(central_channels));
        % parietal_avg = mean(channel_min_averages(parietal_channels));   
        % filename_trial = append(data{i}, "_Trial", string(t));
        % 
        % newRow = {filename_trial, ...
        %   channel_min_averages(1), channel_min_averages(2), channel_min_averages(3), ...
        %   channel_min_averages(4), channel_min_averages(5), channel_min_averages(6), ...
        %   channel_min_averages(7), channel_min_averages(8), channel_min_averages(9), ...
        %   channel_min_averages(10), channel_min_averages(11), ...
        %   frontal_avg, central_avg, parietal_avg};
        % 
        % resultsTable = [resultsTable; newRow];
%--------------------------------------------LOADING RESULTS (maxima)--------------------------------
    %     frontal_avg = mean(channel_max_averages(frontal_channels));
    %     central_avg = mean(channel_max_averages(central_channels));
    %     parietal_avg = mean(channel_max_averages(parietal_channels));   
    %     filename_trial = append(data{i}, "_Trial", string(t));
    % 
    %     newRow = {filename_trial, ...
    %       channel_max_averages(1), channel_max_averages(2), channel_max_averages(3), ...
    %       channel_max_averages(4), channel_max_averages(5), channel_max_averages(6), ...
    %       channel_max_averages(7), channel_max_averages(8), channel_max_averages(9), ...
    %       channel_max_averages(10), channel_max_averages(11), ...
    %       frontal_avg, central_avg, parietal_avg};
    % 
    %     resultsTable = [resultsTable; newRow];
     end
end


% %%
% % Display the results table
% disp(resultsTable);
% 
% 
% % Display the results table
% disp(resultsTable);
% 
%         % Extract range 500–1500 data points
%         if length(erp_standard) > 375
%             range_indices = 300:500;
%         else
%             range_indices = 150:250;
%         end
%         % compute maxima of each erp standard vs deviant
% 
%         % Compute metrics for 500-1500 range
%         mean_erp_standard = mean(erp_standard(:, range_indices), 2);
%         mean_erp_devient = mean(erp_devient(:, range_indices), 2);
%         erp_difference = erp_standard(:, range_indices) - erp_devient(:, range_indices);
%         mean_difference = mean(erp_difference, 2);
% 
%         % Compute regional metrics (frontal, central, parietal)
%         % Frontal
%         frontal_standard = mean(erp_standard(frontal_channels, range_indices), 'all');
%         frontal_deviant = mean(erp_devient(frontal_channels, range_indices), 'all');
%         frontal_channel_difference = erp_standard(frontal_channels, range_indices) - erp_devient(frontal_channels, range_indices);
%         frontal_difference = mean(frontal_channel_difference, "all");
%         % Central
%         central_standard = mean(erp_standard(central_channels, range_indices), 'all');
%         central_deviant = mean(erp_devient(central_channels, range_indices), 'all');
%         central_difference = mean(erp_standard(central_channels, range_indices) - erp_devient(central_channels, range_indices), 'all');
% 
%         % Parietal
%         parietal_standard = mean(erp_standard(parietal_channels, range_indices), 'all');
%         parietal_deviant = mean(erp_devient(parietal_channels, range_indices), 'all');
%         parietal_difference = mean(erp_standard(parietal_channels, range_indices) - erp_devient(parietal_channels, range_indices), 'all');
% 
%         % Append to the table
%         filename_trial = append(data{i}, "_Trial", string(t));
%         resultsTable = [resultsTable; [{filename_trial}, num2cell(mean_difference'), ...
%                                        frontal_difference, central_difference, parietal_difference]];







%% extra 
%% plotting for ERP

% EEG_standard = pop_epoch(EEG,{1},[-0.5 1]);

% EEG_standard = pop_rmbase(EEG_standard,[-0.5 0]);
% 
% % devient epoch
% EEG_devient = pop_epoch(EEG,{2},[-0.5 1]);
% EEG_devient = pop_rmbase(EEG_devient,[-0.5 0]);
% 
% %% Autoreject bad epochs


% [EEG_standard, rmepochs_standard] = pop_autorej( EEG_standard,'maxrej',10,'nogui','on');
% [EEG_devient, rmepochs_devient] = pop_autorej( EEG_devient,'maxrej',10,'nogui
% ','on');
% 
% %% ERP data
% elec_idx = 1:11;
% t = EEG.times;
% 
% erp_standard = mean(EEG_standard.data,3);
% erp_devient = mean(EEG_devient.data,3); %mean amongst number of epochs
% 
% %need to take mean from 250 data points to


% low = [4,8,13];
% high = [7,12,30];
% band_name = ["theta","alpha","beta"];