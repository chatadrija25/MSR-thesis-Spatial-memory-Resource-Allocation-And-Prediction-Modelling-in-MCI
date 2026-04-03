

% The authors of this code are Adrija Chatterjee, Shreelekha BS and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% About the code: 
% Contains code for the plots used in the paper: 
% 1.Chatterjee, A., B. S., S., Tiwari, H. P., Balasubramani, N. P., Ramakrishnan, S., Singh, A., & Balasubramani, P. P. (2026). 
% Operations near the edge of cognitive decline: Behavioral and neural correlates of cognitive load in mild cognitive impairment.
% https://doi.org/10.64898/2026.01.04.697587

% 2. Bs, S., Chatterjee, A., & Balasubramani, P. (2025). Disentangling the loading values of Ego‐ versus Allo‐centric navigation performance, Working memory, Error processing-based cognition and cortical energy distribution for precision medicine in mild cognitively impaired patients. Alzheimer S & Dementia, 21(S2), e104124.
% https://doi.org/10.1002/alz70856_104124; PMC12739001


% For any query, please contact: 
% Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% PLOTS FOR THE PAPER

low_vals = merged_table.DNT(merged_table.dntcond == 0);
high_vals = merged_table.DNT(merged_table.dntcond == 1);
% high_h = (merged_table.dntcond == 1) & (merged_table.Group_logical == 0);
% high_m = (merged_table.dntcond == 1) & (merged_table.Group_logical == 1);

medians = [median(low_vals, 'omitnan'), median(high_vals, 'omitnan')];
sems = [std(low_vals, 'omitnan')/sqrt(sum(~isnan(low_vals))), ...
std(high_vals, 'omitnan')/sqrt(sum(~isnan(high_vals)))];

% dnt_low_h= merged_table.DNT(low_h);
% dnt_low_m= merged_table.DNT(low_m);
% dnt_high_h= merged_table.DNT(high_h);
% dnt_high_m=merged_table.DNT(high_m);

bar_positions = [0, 1];
scatter_positions = {0 + 0.1*randn(sum(low),1), ...
1 + 0.1*randn(sum(high),1)}; %scatter 

bar_color = [0.8 0.8 0.8];
color_healthy = [0 0.6 0.8];
color_mci = [0.9 0.3 0.3];

figure;
hold on;
for i = 1:2
bar(bar_positions(i), medians(i), 0.3, ...
'FaceColor', bar_color, ...
'EdgeColor', 'none');
end

errorbar(bar_positions, medians, sems, 'k', 'LineStyle', 'none', ...
'LineWidth', 1.5, 'CapSize', 8);
% scatter(scatter_positions{1}, dnt_low_h, 50, color_healthy, 'filled', 'MarkerFaceAlpha', 0.6);
% scatter(scatter_positions{2}, dnt_, 50, color_healthy, 'filled', 'MarkerFaceAlpha', 0.6);
scatter(scatter_positions{1}, low_vals, 50, color_mci, 'filled', 'MarkerFaceAlpha', 0.6);
scatter(scatter_positions{2}, high_vals, 50, color_mci, 'filled', 'MarkerFaceAlpha', 0.6);

xticks([0 1]);
xticklabels({'Low load', 'High load'});
% xticklabels({'Healthy', ' MCI'});
xlabel('DNT load levels', 'FontSize', 14);
% xlabel('Groups','FontSize', 14);
ylabel('Working memory task performance (in percentage)', 'FontSize', 14);
title('Working memory task performance across load conditions','FontSize', 14);
% title('DNT Accuracy across groups', 'FontSize', 16);
set(gca, 'FontSize', 14);
xlim([-0.5 1.5]);

x1 = 0;
x2 = 1;
y = max([medians(1) + sems(1), medians(1) + sems(2)]) + 4; 

line([x1 x2], [y y], 'Color', 'k', 'LineWidth', 1.5);       
line([x1 x1], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);     
line([x2 x2], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);     
text(mean([x1 x2]), y + 2, '***', 'HorizontalAlignment', 'center', ...
     'FontSize', 18, 'FontWeight', 'bold');

h1 = scatter(scatter_positions{1}, low_vals, 50, color_healthy, 'filled', 'MarkerFaceAlpha', 0.6);
h2 = scatter(scatter_positions{2}, high_vals, 50, color_mci, 'filled', 'MarkerFaceAlpha', 0.6);
legend([h1, h2], {'Low load', 'High load'}, 'Location', 'best', 'FontSize', 14);
% legend([h1, h2], {'Healthy', 'MCI'}, 'Location', 'best', 'FontSize', 14);

%%

% Logical indexing
low  = merged_table.dntcond == 0;
high = merged_table.dntcond == 1;
healthy = merged_table.Group_logical == 0;
mci     = merged_table.Group_logical == 1;

% DNT accuracies by condition
dnt_low  = merged_table.DNT(low);
dnt_high = merged_table.DNT(high);

% Bar plot stats (pooled across both groups)
medians = [median(dnt_low, 'omitnan'), median(dnt_high, 'omitnan')];
sems = [std(dnt_low, 'omitnan')/sqrt(sum(~isnan(dnt_low))), ...
        std(dnt_high, 'omitnan')/sqrt(sum(~isnan(dnt_high)))];

% Prepare scatter data
dnt_low_h  = merged_table.DNT(low & healthy);
dnt_high_h = merged_table.DNT(high & healthy);
dnt_low_m  = merged_table.DNT(low & mci);
dnt_high_m = merged_table.DNT(high & mci);

% Scatter jitter
scatter_pos_low  = 0 + 0.1 * randn(sum(low), 1);
scatter_pos_high = 1 + 0.1 * randn(sum(high), 1);

% Define colors
color_healthy = [0, 0.6, 0.2];   % Green
color_mci = [0.8, 0.1, 0.1];     % Red
bar_color = [0.75 0.8 0.95]; 

% Plot
figure; hold on;

% Bar plot
bar_positions = [0, 1];
for i = 1:2
    bar(bar_positions(i), medians(i), 0.3, ...
        'FaceColor', bar_color, ...
        'EdgeColor', 'k');
end

% Error bars
errorbar(bar_positions, medians, sems, 'k', ...
         'LineStyle', 'none', 'LineWidth', 1.5, 'CapSize', 8);

% Scatter plot - healthy (green)
h1 = scatter(0 + 0.1*randn(length(dnt_low_h),1), dnt_low_h, 50, ...
             color_healthy, 'filled', 'MarkerFaceAlpha', 0.6);
h2 = scatter(1 + 0.1*randn(length(dnt_high_h),1), dnt_high_h, 50, ...
             color_healthy, 'filled', 'MarkerFaceAlpha', 0.6);

% Scatter plot - MCI (red)
h3 = scatter(0 + 0.1*randn(length(dnt_low_m),1), dnt_low_m, 50, ...
             color_mci, 'filled', 'MarkerFaceAlpha', 0.6);
h4 = scatter(1 + 0.1*randn(length(dnt_high_m),1), dnt_high_m, 50, ...
             color_mci, 'filled', 'MarkerFaceAlpha', 0.6);

% Axes and labels
xticks([0 1]);
xticklabels({'Low Load', 'High Load'});
xlabel('Working Memory(WM) Load', 'FontSize', 14);
ylabel('Working memory task performance (in percentage)', 'FontSize', 14);
title('Working memory task performance across WM load conditions','FontSize', 14);
set(gca, 'FontSize', 14);
xlim([-0.5 1.5]);

% Optional significance marker (e.g., from test)
x1 = 0;
x2 = 1;
y = max([medians + sems]) + 4;

line([x1 x2], [y y], 'Color', 'k', 'LineWidth', 1.5);
line([x1 x1], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
line([x2 x2], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
text(mean([x1 x2]), y + 2, '***', 'HorizontalAlignment', 'center', ...
     'FontSize', 18, 'FontWeight', 'bold');

% Legend
legend([h1, h3], {'Healthy', 'MCI'}, 'Location', 'best', 'FontSize', 14);

%%
gr = [merged_table.dntcond, merged_table.Group_logical];

boxplot(abs(merged_table.Switch_angle), gr, ...
    'FactorSeparator', 1, ...        % Separate by dntcond first
    'Labels', {'Low-Healthy','Low-MCI','High-Healthy','High-MCI'}, ...
    'Positions', (1:4) - 0.15, ...   % Shift all boxes left
    'Colors', 'k', ...
    'Widths', 0.2);

hold on
colors = lines(4);  % or custom colormap for 4 groups
labels = {'Low-Healthy','Low-MCI','High-Healthy','High-MCI'};
positions = 1:4;

for i = 0:1  % dntcond
    for j = 0:1  % Group_logical
        idx = merged_table.dntcond == i & merged_table.Group_logical == j;
        x_jittered = positions(i*2 + j + 1) + 0.1 * randn(sum(idx), 1);
        scatter(x_jittered, abs(merged_table.Switch_angle(idx)), 50, colors(i*2 + j + 1, :), ...
                'filled', 'MarkerFaceAlpha', 0.5);
    end
end

xlim([0.5 4.5]);
xticks(positions);
xticklabels(labels);
xlabel('DNT Condition × Group');
ylabel('DNT Accuracy (in percentage)');
title('Grouped Scatter Plot');
set(gca, 'FontSize', 14);
legend(labels, 'Location', 'best');

%% 
% Combine grouping variables
switch_angle = merged_table.Switch_angle;
gr = [merged_table.dntcond, merged_table.Group_logical];

% Remove rows with NaNs in any column
% valid_rows = all(~isnan([switch_angle, gr]), 2);

% switch_angle_clean = switch_angle(valid_rows);
% Create the boxplot
boxplot(switch_angle, gr, ...
    'FactorSeparator', 1, ...
    'Labels', {'Low-Healthy','Low-MCI','High-Healthy','High-MCI'}, ...
    'Positions', (1:4) - 0.15, ...
    'Colors', 'k', ...
    'Widths', 0.2);

hold on;

% Create a numeric group ID for each unique group combo
[uniqueGroups, ~, groupIDs] = unique(gr, 'rows');

% Now compute means per group
groupMeans = accumarray(groupIDs, switch_angle, [], @mean);

% Match number of means to number of box positions
% Assuming you want to plot at the same positions as the boxes
x_positions = (1:length(groupMeans)) - 0.15;

% Plot the group means as red filled circles
plot(x_positions, groupMeans, 'ro', 'MarkerFaceColor', 'r');

hold off;

%%
% Prepare data
% Extract data
dnt_data = merged_table.DNT;
group = merged_table.Group_logical;

% Compute mean switch per group (for overlay)
switch_mean = [ ...
    mean(merged_table.Switch(merged_table.Group_logical == 0)), ...
    mean(merged_table.Switch(merged_table.Group_logical == 1)) ];

% Colors
violin_colors = [0.2 0.6 1; 1 0.4 0.4]; % Healthy (blue), MCI (red)

figure; hold on;

% Violin plot for DNT
for g = 0:1
    data_g = dnt_data(group == g);
    pos = g + 1;  % violinplot x-axis position
    % violinplot function (e.g., from MATLAB File Exchange or custom)
    violin(data_g, pos, ...
        'ShowMean', true, ...
        'ViolinColor', violin_colors(g+1,:), ...
        'EdgeColor', 'none');
end

% Overlay horizontal lines for Switch
for g = 0:1
    plot([g+0.75, g+1.25], [switch_mean(g+1)*100, switch_mean(g+1)*100], ...
        'k-', 'LineWidth', 2);
end

% Formatting
xlim([0.5 2.5]);
ylim([0 110]);
xticks([1 2]);
xticklabels({'Healthy', 'MCI'});
ylabel('DNT Accuracy (%) & Switch Rate (%)');
legend({'DNT Distribution', 'Mean Switch Rate'}, 'Location', 'northoutside');
title('DNT Accuracy (Violin) with Switch Rate Overlay');
set(gca, 'FontSize', 14);

%%
rng(42);
nRows= height(merged_table.Group_logical);
cv = cvpartition(nRows, 'HoldOut', 0.2);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = merged_table(trainIdx, :);
testTable = merged_table(testIdx, :);

% mdl = fitglm(trainTable, 'Switch~dntcond*Group_logical+ Condition*Group_logical', 'CategoricalVars',{'dntcond', 'Condition'}, ...
%     'Distribution','binomial');
 mdl = fitglm(trainTable, 'Region~dntcond*Group_logical+ Condition*Group_logical', 'CategoricalVars',{'dntcond', 'Condition'}, ...
    'Distribution','normal');
[group_vals, dnt_vals, cond_vals] = ndgrid(0:1, 0:1, 0:1);
combo = table(group_vals(:), dnt_vals(:), cond_vals(:), ...
    'VariableNames', {'Group_logical', 'dntcond', 'Condition'});
pred_probs = predict(mdl, testTable);

[G, group_labels] = findgroups(testTable(:, {'Group_logical', 'dntcond'}));
mean_probs = splitapply(@mean, pred_probs, G);
prob_matrix = reshape(mean_probs, 2, 2)';  % Rows = dntcond, Cols = Group_logical
%%
% Fit model
mdl = fitglm(trainTable, ...
    'Switch ~ dntcond*Group_logical + ERP_Minima_Central_100_400*Group_logical', ...
    'CategoricalVars', {'dntcond','Group_logical'}, ...
    'Distribution', 'normal');

% Predict on test data
pred_probs = predict(mdl, testTable);

% Group by only the categorical variables
[G, group_labels] = findgroups(testTable(:, {'Group_logical', 'dntcond'}));

% Mean predicted probabilities per group
mean_probs = splitapply(@(x) mean(x, 'omitnan'), pred_probs, G);

% Arrange into 2×2 matrix (Low/High load × Healthy/MCI)
prob_matrix = reshape(mean_probs, 2, 2)';


%%
figure; 
hold on;
% x_jitter = merged_table.Group_logical + 0.05 * randn(size(merged_table.Group_logical));
color = lines(2);

for i = 1:length(mean_probs)
    x = group_labels.dntcond(i) * 2 + group_labels.Group_logical(i) + 1; 
    y = mean_probs(i)*100;
    d = group_labels.dntcond(i);
    plot(x, y, 'o', ...
        'MarkerSize', 10, ...
        'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', color(d+1,:));
end
 
hold on; 
gr = [merged_table.dntcond, merged_table.Group_logical]; 

boxplot(merged_table.DNT, gr, ...
    'FactorSeparator', 1, ...        % Separate by dntcond first
    'Labels', {'Low-Healthy','Low-MCI','High-Healthy','High-MCI'}, ...
    'Positions', (1:4), ...   % Shift all boxes left
    'Colors', 'k', ...
    'Widths', 0.2);
hold on; 
% Set axis limits and labels
xlim([0.5 4.5]);
ylim([0 125]);
xticks(1:4);
xticklabels({'Low-Healthy','Low-MCI','High-Healthy','High-MCI'});
ylabel('DNT Accuracy (%) / Predicted Parietal Region dominance using GED(%)');
xlabel('Group × DNT Load');
title('Predicted Parietal Region dominance using GED along with performance in the working memory task','DNT Accuracy (boxplot) and Predicted Parietal Region dominance using GED(dots)');
legend({'Predicted Parietal Region dominance using GED'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
set(gca, 'FontSize', 14);
grid on;

% xlim([-0.5 1.5]); ylim([0 1.05])
% xticks([0 1]); xticklabels({'Healthy', 'MCI'});
% xlabel('Group'); ylabel('Predicted Probability of Switch');
% title('Switch: Group × DNT Load');
% legend({'Low DNT', 'High DNT'}, 'Location', 'best');
% set(gca, 'FontSize', 14);
% grid on; hold off;

%% SWITCH PROB(BAR) AND DNT AS Scatter

positions = 1:4;
labels = {'Low-Healthy','High-Healthy','Low-MCI','High-MCI'};
color = lines(4);
dnt_medians = zeros(1,4);
dnt_sems = zeros(1,4);
figure;
b = bar(positions, (mean_probs)*100, 0.5, 'FaceColor', [0.75 0.8 0.95], 'EdgeColor', 'k');
hold on; 

for i = 0:1 % group
    for j = 0:1  % dnt_load
        idx = merged_table.dntcond == j & merged_table.Group_logical == i;
        dnt_vals = merged_table.AngleError(idx);
        k = i*2 + j + 1;
        % dnt_medians(k) = mean(dnt_vals, 'omitnan');
        % dnt_sems(k) = std(dnt_vals, 'omitnan') / sqrt(sum(~isnan(dnt_vals)));
        x_jittered = positions(k) + 0.1 * randn(sum(idx), 1);
        scatter(x_jittered, merged_table.AngleError(idx), 50, color(1, :), ...
                'filled', 'MarkerFaceAlpha', 0.5);
        hold on; 
    end
end


% errorbar(positions, dnt_medians, dnt_sems, 'k.', 'LineWidth', 1.5);

% for i = 1:length(mean_probs)
%     x = group_labels.dntcond(i) * 2 + group_labels.Group_logical(i) + 1; 
%     y = mean_probs(i)*100;
%     d = group_labels.dntcond(i);
%     bar(x, y, 'o', ...
%         'MarkerSize', 10, ...
%         'MarkerEdgeColor', 'k', ...
%         'MarkerFaceColor', color(d+1,:));
% end

% y_max = max(mean_probs)*100+ 40;  % Find space above bars
y_max= 82;
x_start = 3 ;  % Position of "Low-MCI"
x_end = 4;    % Position of "High-MCI"
plot([x_start, x_end], [y_max y_max], 'k', 'LineWidth', 1.5);
plot([x_start x_start], [y_max-3 y_max], 'k', 'LineWidth', 1.5);
plot([x_end x_end], [y_max-3 y_max], 'k', 'LineWidth', 1.5);
text(mean([x_start x_end]), y_max + 3, '**', ...
     'HorizontalAlignment', 'center', 'FontSize', 18, 'FontWeight', 'bold');
hold on; 

x_start = 1 ;  % Position of "Low-Healthy"
x_end = 3; % Position of "Low-MCI"
y_max=86;
plot([x_start, x_end], [y_max y_max], 'k', 'LineWidth', 1.5);
plot([x_start x_start], [y_max-3 y_max], 'k', 'LineWidth', 1.5);
plot([x_end x_end], [y_max-3 y_max], 'k', 'LineWidth', 1.5);
text(mean([x_start x_end]), y_max+1 + 2, '*', ...
     'HorizontalAlignment', 'center', 'FontSize', 18, 'FontWeight', 'bold');


xticks(positions);
xticklabels(labels);
xlabel('Working memory Load x Group');
% ylabel('DNT Accuracy(%)/Mean Predicted Parietal Region dominance(%)');
ylabel({'DNT Accuracy (%)','Mean Predicted Probability of Switch(%)'});
% ylabel('Egocentric Angle Error(degrees) / Mean Predicted Probability of Switch(%)');
% ylabel('Allocentric Angle Error(degrees)/ Mean Predicted Probability of Switch(%)');
% ylabel({'Preference of the non-intrinsic frame of reference(degrees)','/Mean Predicted Probability of Switch(%)'});
% ylim([-3 3]);
ylim([0 180]);
title({'Mean Predicted Probability Of Odds Of Switch', 'Across Working memory load and Groups'});
% title(['Mean Predicted Parietal Region dominance using GED Across ' ...
%     'Working memory load and Groups']);
     % ,['DNT Accuracy (boxplot) ' ...
     % 'and Predicted Parietal Region dominance using GED(dots)']);

% legend({'Mean Predicted Parietal Region dominance','DNT Accuracy'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
 legend({'Mean Predicted Probability of Odds Of Switch','DNT Accuracy'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
% legend({'Mean Predicted Probability of Switch','Egocentric Angle Error'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
% legend({'Mean Predicted Probability of Switch','Allocentric Angle Error'}, 'Location', 'northoutside', 'Orientation', 'horizontal');
% legend({'Mean Predicted Probability of Switch','Preference of the non-intrinsic frame of reference(degrees)'}, 'Interpreter', 'tex');

set(gca, 'FontSize', 25);
grid on;

%% SWITCH-DNT BASED ON GROUP ONLY 
group_labels = {'Healthy', 'MCI'};
positions = [1, 2];
colors = [0.3 0.7 0.9; 0.9 0.3 0.3];  % Healthy = blue, MCI = red

% model = fitglm(trainTable, 'Switch~dntcond*Group_logical+ Condition*Group_logical', 'CategoricalVars',{'dntcond', 'Condition'}, ...
%     'Distribution','binomial');
model = fitglm(trainTable, 'Region~dntcond*Group_logical+ Condition*Group_logical', 'CategoricalVars',{'dntcond', 'Condition'}, ...
    'Distribution','normal');
[group_vals, dnt_vals, cond_vals] = ndgrid(0:1, 0:1, 0:1);
combo = table(group_vals(:), dnt_vals(:), cond_vals(:), ...
    'VariableNames', {'Group_logical', 'dntcond', 'Condition'});

pred_probs_all = predict(model, testTable);
[G, labels] = findgroups(testTable.Group_logical);
mean_switch = splitapply(@(x) mean(x, 'omitnan'), pred_probs_all, G) * 100;
% Bar plot of Predicted Switch 
figure; 
b = bar(positions, mean_switch, 0.5, 'FaceColor', [0.75 0.8 0.95], 'EdgeColor', 'k');
hold on; 

% dnt_medians = zeros(1,2);
% dnt_sems = zeros(1,2);
for g = 0:1
    idx = merged_table.Group_logical == g;
    group_dnt = merged_table.DNT(idx);
    % dnt_medians(g+1) = median(group_dnt, 'omitnan');
    % dnt_sems(g+1) = std(group_dnt, 'omitnan') / sqrt(sum(~isnan(group_dnt)));
    x_jittered = positions(g+1) + 0.1 * randn(sum(idx), 1);
        scatter(x_jittered, merged_table.DNT(idx), 50, colors(1, :), ...
                'filled', 'MarkerFaceAlpha', 0.5);
        hold on; 
end


% --- 2. Predict Switch Probabilities across all dntcond & condition ---
% You already have the model `mdl` from earlier.

x1 = 1;
x2 = 2;
% y = max([dnt_medians(1) + dnt_sems(1), dnt_medians(1) + dnt_sems(2)]) + 12; 
y= 102; %82 for switch
line([x1 x2], [y y], 'Color', 'k', 'LineWidth', 1.5);       
line([x1 x1], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);     
line([x2 x2], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);     
text(mean([x1 x2]), y + 2, '**', 'HorizontalAlignment', 'center', ...
     'FontSize', 18, 'FontWeight', 'bold');

% --- Aesthetics ---
xticks(positions);
xticklabels(group_labels);
xlabel('Group');
ylabel({'DNT Accuracy(%)','Mean Predicted Parietal Region dominance(%)'});
% ylabel({'DNT Accuracy (%)',' Mean Predicted Probability of Odds Of Switch(%)'});
% ylabel({'Preference of the non-intrinsic frame of reference(degrees)',' / Mean Predicted Probability of Switch(%)'});

ylim([0 109]);
% title('Mean Predicted Probability of Odds Of Switch Across Groups');
title('Mean Predicted Parietal Region dominance Across Groups');

legend({'Mean Predicted Parietal Region dominance', 'DNT Accuracy'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal');

% lgd = legend({'Mean Predicted Parietal Region dominance', 'DNT Accuracy'}, ...
%     'Location', 'northoutside');
% lgd.NumColumns = 1;

% legend({'Mean Predicted Probability of Odds Of Switch','DNT Accuracy'}, ...
%     'Location', 'northoutside', 'Orientation', 'horizontal');
% legend({'Mean Predicted Probability of Switch','Preference of the non-intrinsic frame of reference(degrees)'}, ...
%     'Interpreter', 'tex');

set(gca, 'FontSize', 25);
grid on;
hold off; 

%%
% ----------------------
% Add ERP Central (scattered) on right Y-axis
% ----------------------
yyaxis right;
hold on;
colors = [0.3 0.7 0.9; 0.9 0.3 0.3];  % Same group colors (Healthy = blue, MCI = red)
for g = 0:1
    idx = merged_table.Group_logical == g;
    erp_vals = merged_table.ERP_Minima_Central_100_400(idx);  % Replace with actual column name
    x_jittered = positions(g+1) + 0.1 * randn(sum(idx), 1);  % Slight jitter to avoid overlap
    scatter(x_jittered, erp_vals, 45, colors(g+1, :), ...
        'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName', 'ERP Central');
end
ylabel('ERP Minima Central (100-400 ms)');
ylim([-3.5 0.5]);  % Or manually set if needed

%%
% --- Setup ---
rng(42);
nRows = height(merged_table);
cv = cvpartition(nRows, 'HoldOut', 0.2);

trainIdx = training(cv);
testIdx  = test(cv);

trainTable = merged_table(trainIdx, :);
testTable  = merged_table(testIdx, :);

% --- Fit Linear Model with Normal Distribution ---
mdl = fitglm(trainTable, ...
    'Switch ~ ERP_Minima_Central_100_400*Group_logical', ...
    'CategoricalVars', {'Group_logical'}, 'Distribution', 'normal');

% --- Predict on Test Data ---
pred_switch = predict(mdl, testTable); % Now continuous predictions

% --- Group Mean Predicted Switch ---
[G, ~] = findgroups(testTable.Group_logical);
mean_switch = splitapply(@(x) mean(x, 'omitnan'), pred_switch, G);

% --- Plot ---
group_labels = {'Healthy', 'MCI'};
positions = [1, 2];

% Two different bar colors (example palette)
bar_colors = [0.2 0.8 0.2;  % Healthy (green)
              0.9 0.2 0.2]; % MCI (red)

figure;
b = bar(positions, (mean_switch)*100, 0.5, 'FaceColor', 'flat', 'EdgeColor', 'k');
b.CData = bar_colors; % Assign colors per bar
hold on;

for g = 0:1
    idx = merged_table.Group_logical == g;
    x_jittered = positions(g+1) + 0.1 * randn(sum(idx), 1);
    scatter(x_jittered, merged_table.DNT(idx), 50, colors(g+1, :), ...
        'filled', 'MarkerFaceAlpha', 0.5);
end

% Significance annotation (manual Y value)
y = max(mean_switch)*100 + 5;
line([1 2], [y y], 'Color', 'k', 'LineWidth', 1.5);
line([1 1], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
line([2 2], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
text(1.5, y+2, '*', 'HorizontalAlignment', 'center', ...
     'FontSize', 18, 'FontWeight', 'bold');

% Labels & Style
xticks(positions);
xticklabels(group_labels);
xlabel('Group');
ylabel('DNT Accuracy (%) / Mean Predicted Switch');
ylim([0 max(mean_switch)*100+55]);
title('Mean Predicted Switch Across Groups (Linear Model)');
legend({'Mean Predicted Switch','DNT Accuracy'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal');
set(gca, 'FontSize', 14);
grid on;
hold off;

%%
% --- Fit model with normal distribution ---
mdl = fitglm(trainTable, ...
    'Switch ~ dntcond*Group_logical+ ERP_Minima_Central_100_400*Group_logical', ...
    'CategoricalVars', {'Group_logical','dntcond'}, 'Distribution', 'normal');

% --- Predict on test data ---
pred_probs_all = predict(mdl, testTable);

% --- Group by Group_logical & dntcond (4 conditions) ---
[G, labels] = findgroups(testTable.Group_logical, testTable.dntcond);
mean_switch = splitapply(@(x) mean(x, 'omitnan'), pred_probs_all, G) * 100;

% --- Setup labels and colors ---
cond_labels = {'Healthy-Low', 'Healthy-High', 'MCI-Low', 'MCI-High'};
positions = 1:4;
colors = [0.3 0.7 0.9;  % Healthy Low
          0.1 0.4 0.8;  % Healthy High
          0.9 0.3 0.3;  % MCI Low
          0.6 0.1 0.1]; % MCI High

% --- Bar plot ---
figure;
b = bar(positions, mean_switch, 0.5, 'FaceColor', 'flat', 'EdgeColor', 'k');
for i = 1:4
    b.CData(i,:) = colors(i,:);
end
hold on;

% --- Overlay scatter of raw DNT scores ---
% for i = 1:4
%     idx = testTable.Group_logical == floor((i-1)/2) & testTable.dntcond == mod(i-1,2);
%     x_jittered = positions(i) + 0.1 * randn(sum(idx), 1);
%     scatter(x_jittered, testTable.DNT(idx), 50, colors(i,:), ...
%         'filled', 'MarkerFaceAlpha', 0.5);
% end

% --- Example significance annotation (Healthy-Low vs MCI-Low) ---
x1 = 1; x2 = 3; y = max(mean_switch) + 5;
line([x1 x2], [y y], 'Color', 'k', 'LineWidth', 1.5);
line([x1 x1], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
line([x2 x2], [y-2 y], 'Color', 'k', 'LineWidth', 1.5);
text(mean([x1 x2]), y + 2, '*', 'HorizontalAlignment', 'center', ...
    'FontSize', 18, 'FontWeight', 'bold');

% --- Aesthetics ---
xticks(positions);
xticklabels(cond_labels);
xlabel('Group & Load');
ylabel('Mean Predicted Probability of Switch (%)');
ylim([0 110]);
title('Predicted Switch Probability Across 4 Conditions');
legend({'Predicted Switch','DNT Accuracy'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal');
set(gca, 'FontSize', 14);
grid on;
hold off;
