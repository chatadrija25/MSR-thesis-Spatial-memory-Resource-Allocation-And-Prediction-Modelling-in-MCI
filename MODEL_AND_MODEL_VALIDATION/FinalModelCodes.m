
 %The authors of this code are Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.
% For any query, please contact: Adrija Chatterjee: adrijac23@iitk.ac.in or
%Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in 

% merged_table contains trial wise behavioural and electrophysiological
%features for each participant. 

% This file contains the code for classifying Mild Cognitive impaired
% population from 1) Behavioural 2)Neural 3) Gastric features; and
% validating them through K-fold and 80-20(train-test) split. 


%%  BEHAVIOURAL MODEL 

load("merged_table.mat");

% beh_table1 = merged_table(:,{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Switch','Group_logical'});
beh_table1 = merged_table(:,{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Switch','ERP_Minima_Central_100_400','ERP_Minima_Frontal_100_400', ...
    'ERP_Minima_100_400_','Region','brady', 'tachy', 'normo','broad','Group_logical'});
nRows= height(beh_table1.Group_logical);
rng(42);
cv = cvpartition(beh_table1.Group_logical, 'HoldOut', 0.2, 'Stratify',true);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = beh_table1(trainIdx, :);
testTable = beh_table1(testIdx, :);
mdl = fitglm(beh_table1,'interactions','ResponseVar','Group_logical',...
    'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
% mdl = removeTerms(mdl,'AE_cat:DNT_cat + AE_cat:Switch + AE_cat:Allo_cat + AE_cat+ Switch+ Ego_cat:Switch');
% disp(mdl);

%% BEH - K-fold

rng(42); % final_table
cv = cvpartition(beh_table1.Group_logical, 'KFold', 3);  % 5-fold CV
auc_values = zeros(cv.NumTestSets,1);  % Store AUCs
optSensitivity = zeros(cv.NumTestSets,1);
optSpecificity = zeros(cv.NumTestSets,1);
optThreshold = zeros(cv.NumTestSets, 1);
accuracy_values = zeros(cv.NumTestSets, 1);

for i = 1:cv.NumTestSets
    trainIdx = training(cv, i);
    testIdx = test(cv, i);
    % Train the model on training set
    trainData = beh_table1(trainIdx, :);
    testData = beh_table1(testIdx, :);
   % modelspec = [ ...
   %  'Group_logical ~ AE_cat + Allo_cat + DNT_cat + Ego_cat + Switch + Region + ' ...
   %  'AE_cat:DNT_cat + Allo_cat:Ego_cat + DNT_cat:Ego_cat + DNT_cat:Switch + ERP_Minima_Central_100_400'];
   % mdl_cv = fitglm(trainData,modelspec,...
   %  'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Region'});
     mdl_cv = fitglm(trainData, 'interactions', 'ResponseVar','Group_logical',...
    'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
   pred_y = predict(mdl_cv, testData);    
   true_y = double(testData.Group_logical);  % Convert to 0/1 if needed
   % ROC curve and AUC 
   [X, Y, T, auc_values(i)] = perfcurve(true_y, pred_y, 1); 
   [~, optIdx]= max(Y-X);
   optThreshold(i)= T(optIdx);
   optSensitivity(i)= Y(optIdx);          % TPR
   optSpecificity(i)= 1 - X(optIdx);      % 1–FPR

   true = pred_y >= optThreshold(i);
   accuracy_values(i) = mean(true == true_y);
end

mean_auc = mean(auc_values); % Final average AUC
mean_sensitivity= mean(optSensitivity);
mean_specificity=mean(optSpecificity);
mean_accuracy = mean(accuracy_values);
sdv_auc= std(auc_values);
sdv_sen= std(optSensitivity);
sdv_spf= std(optSpecificity);
sdv_acc= std(accuracy_values);

fprintf('Average cross-validated AUC = %.4f\n', mean_auc);
fprintf('Average cross-validated sensitivity = %.4f\n', mean_sensitivity);
fprintf('Average cross-validated specificity = %.4f\n', mean_specificity);
fprintf('Average cross-validated accuracy = %.4f\n', mean_accuracy);

fprintf('sd cross-validated AUC = %.4f\n', sdv_auc);
fprintf('sd cross-validated sensitivity = %.4f\n', sdv_sen);
fprintf('sd cross-validated specificity = %.4f\n', sdv_spf);
fprintf('sd cross-validated accuracy = %.4f\n', sdv_acc);

%% BEH - ROC- AUC 
rng(42);
cv = cvpartition(beh_table1.Group_logical, 'HoldOut', 0.2);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = beh_table1(trainIdx, :);
testTable = beh_table1(testIdx, :);


mdl1 = fitglm(trainTable,'interactions','ResponseVar','Group_logical',...
    'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});

scores      = predict(mdl1, testTable);
true_labels = testTable.Group_logical;    % logical 0/1

% X = FPR, Y = TPR, T = thresholds, AUC
[X,Y,T,AUC] = perfcurve(true_labels, scores, 1);

% Youden’s J = max( TPR – FPR )
[~, optIdx]       = max(Y - X);
optThreshold      = T(optIdx);
optSensitivity    = Y(optIdx);          % TPR
optSpecificity    = 1 - X(optIdx);      % 1–FPR

fprintf('Optimal Threshold ≈ %.3f\n',   optThreshold);
fprintf('Sensitivity       ≈ %.2f%%\n', 100*optSensitivity);
fprintf('Specificity       ≈ %.2f%%\n', 100*optSpecificity);

%PLOT ROC_AUC: 
figure;
plot(X, Y, 'b-', 'LineWidth', 2);      hold on;
plot([0 1], [0 1], 'k--');             % chance line
plot(X(optIdx), Y(optIdx), 'ro', ...   % optimal point
'MarkerSize', 8, 'LineWidth', 2);
hold off;

title(sprintf('ROC Curve (AUC = %.3f)', AUC), 'FontSize', 20);
xlabel('False Positive Rate',     'FontSize', 16);
ylabel('True Positive Rate',      'FontSize', 16);
legend('Model','Random Chance','Youden Optimal','Location','SouthEast');
grid on;
set(gca, 'FontSize', 16);

%% PLOT ROC_AUC: 
% figure;
% plot(X, Y, 'b-', 'LineWidth', 2);      hold on;
% plot([0 1], [0 1], 'k--');             % chance line
% plot(X(optIdx), Y(optIdx), 'ro', ...   % optimal point
% 'MarkerSize', 8, 'LineWidth', 2);
% hold off;
% 
% title(sprintf('ROC Curve (AUC = %.3f)', auc_values), 'FontSize', 20);
% xlabel('False Positive Rate',     'FontSize', 16);
% ylabel('True Positive Rate',      'FontSize', 16);
% legend('Model','Random Chance','Youden Optimal','Location','SouthEast');
% grid on;
% set(gca, 'FontSize', 16);



%% -----------------------------------------------------------------------------------
 %% NEURAL FEATURES 

% MODEL CODE- WHOLE DATA
load('merged_table.mat');
neural_table1 = merged_table(:,{'ERP_Minima_Central_100_400','ERP_Minima_Frontal_100_400','ERP_Minima_100_400_','Region','Group_logical'});

mdl_eeg= fitglm(neural_table1, 'interactions', 'CategoricalVars','Region'); 
disp(mdl_eeg);
%% cohen's F2

predictors = mdl_eeg.PredictorNames;      % cell array of strings
R2_full    = mdl_eeg.Rsquared.Ordinary;   % full-model R²
fprintf("Full‐model R² = %.4f\n", R2_full);

% 2) Preallocate
f2_vals = zeros(size(predictors));

% 3) Loop: drop each predictor in turn and refit reduced model
for i = 1:numel(predictors)
    B = predictors{i};                                % the term to drop
    A = setdiff(predictors, B, 'stable');             % all the others

    % fit reduced model without B
    mdl_red = fitglm(neural_table1, 'interactions', ...
        'ResponseVar',    'Group_logical', ...
        'PredictorVars',  A, ...
        'CategoricalVars', 'Region');

    R2_residual= mdl_red.Rsquared.Ordinary;
    f2_vals(i)   = (R2_full - R2_residual) / (1 - R2_full);
end

% 4) Display
f2_table = table(predictors(:), f2_vals(:), ...
    'VariableNames', {'Predictor','f2'});
disp("Cohen's f² for each term in your model:");
disp(f2_table);

%% K-fold 

rng(42); % final_table
cv = cvpartition(neural_table1.Group_logical, 'KFold', 3);  % 5-fold CV
auc_values = zeros(cv.NumTestSets,1);  % Store AUCs
optSensitivity = zeros(cv.NumTestSets,1);
optSpecificity = zeros(cv.NumTestSets,1);
optThreshold = zeros(cv.NumTestSets, 1);
accuracy_values = zeros(cv.NumTestSets, 1);

for i = 1:cv.NumTestSets
    trainIdx = training(cv, i);
    testIdx = test(cv, i);
    % Train the model on training set
    trainData = neural_table1(trainIdx, :);
    testData = neural_table1(testIdx, :);
   % modelspec = [ ...
   %  'Group_logical ~ AE_cat + Allo_cat + DNT_cat + Ego_cat + Switch + Region + ' ...
   %  'AE_cat:DNT_cat + Allo_cat:Ego_cat + DNT_cat:Ego_cat + DNT_cat:Switch + ERP_Minima_Central_100_400'];
   % mdl_cv = fitglm(trainData,modelspec,...
   %  'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Region'});
    mdl_cv= fitglm(trainData, 'interactions', 'CategoricalVars','Region'); 
   predicted_scores = predict(mdl_cv, testData);  
   pred_y = predict(mdl_cv, testData);    
   true_y = double(testData.Group_logical);  % Convert to 0/1 if needed
   % ROC curve and AUC 
   [X, Y, T, auc_values(i)] = perfcurve(true_y, pred_y, 1); 
   [~, optIdx]= max(Y-X);
   optThreshold(i)= T(optIdx);
   optSensitivity(i)= Y(optIdx);          % TPR
   optSpecificity(i)= 1 - X(optIdx);      % 1–FPR

   y_class = pred_y >= optThreshold(i);
   accuracy_values(i) = mean(y_class == true_y);
 
end

mean_auc = mean(auc_values); % Final average AUC
mean_sensitivity= mean(optSensitivity);
mean_specificity=mean(optSpecificity);
mean_accuracy = mean(accuracy_values);

sdv_auc= std(auc_values);
sdv_sen= std(optSensitivity);
sdv_spf= std(optSpecificity);
sdv_acc= std(accuracy_values);

fprintf('Average cross-validated AUC = %.4f\n', mean_auc);
fprintf('Average cross-validated sensitivity = %.4f\n', mean_sensitivity);
fprintf('Average cross-validated specificity = %.4f\n', mean_specificity);
fprintf('Average cross-validated accuracy = %.4f\n', mean_accuracy);

fprintf('sd cross-validated AUC = %.4f\n', sdv_auc);
fprintf('sd cross-validated sensitivity = %.4f\n', sdv_sen);
fprintf('sd cross-validated specificity = %.4f\n', sdv_spf);
fprintf('sd cross-validated accuracy = %.4f\n', sdv_acc);

    
   
%% ROC 

rng(42);
cv = cvpartition(neural_table1.Group_logical, 'HoldOut', 0.2);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = neural_table1(trainIdx, :);
testTable = neural_table1(testIdx, :);


mdl1= fitglm(trainTable, 'interactions', 'CategoricalVars','Region'); 
predicted_scores = predict(mdl1, testTable);  
scores      = predict(mdl1, testTable);
true_labels = testTable.Group_logical;    % logical 0/1


% X = FPR, Y = TPR, T = thresholds, AUC
[X,Y,T,AUC] = perfcurve(true_labels, scores, 1);

% Youden’s J = max( TPR – FPR )
[~, optIdx]       = max(Y - X);
optThreshold      = T(optIdx);
optSensitivity    = Y(optIdx);          % TPR
optSpecificity    = 1 - X(optIdx);      % 1–FPR

true_y = predicted_scores >= optThreshold;
accuracy = mean(true_labels == true_y);

fprintf('Validation Accuracy: %.2f%%\n', accuracy*100);

fprintf('Optimal Threshold ≈ %.3f\n',   optThreshold);
fprintf('Sensitivity       ≈ %.2f%%\n', 100*optSensitivity);
fprintf('Specificity       ≈ %.2f%%\n', 100*optSpecificity);

%% PLOT ROC_AUC: 

% figure;
% plot(X, Y, 'b-', 'LineWidth', 2);      hold on;
% plot([0 1], [0 1], 'k--');             % chance line
% plot(X(optIdx), Y(optIdx), 'ro', ...   % optimal point
% 'MarkerSize', 8, 'LineWidth', 2);
% hold off;
% 
% title(sprintf('ROC Curve (AUC = %.3f)', AUC), 'FontSize', 20);
% xlabel('False Positive Rate',     'FontSize', 16);
% ylabel('True Positive Rate',      'FontSize', 16);
% legend('Model','Random Chance','Youden Optimal','Location','SouthEast');
% grid on;
% set(gca, 'FontSize', 16);


%% EGG MODEL - PREDICTING MCI FROM ELECTROGASTROGRAPHY FEATURES: 

load('merged_table.mat');
% egg_table= merged_table(:, {', 'Group_logical'}); 
egg_table= merged_table(:, {'brady', 'tachy', 'normo','Group_logical'});
    %Brady_Percentage','Normo_Percentage', 'Tachy_Percentage', 

nRows= height(egg_table.Group_logical);
rng(42);
cv = cvpartition(egg_table.Group_logical, 'HoldOut', 0.2, 'Stratify',true);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = egg_table(trainIdx, :);
testTable = egg_table(testIdx, :);
mdl = fitglm(egg_table,'interactions','ResponseVar','Group_logical');
% mdl = removeTerms(mdl,'AE_cat:DNT_cat + AE_cat:Switch + AE_cat:Allo_cat + AE_cat+ Switch+ Ego_cat:Switch');
% disp(mdl);

%% K-fold

rng(42); % final_table
cv = cvpartition(egg_table.Group_logical, 'KFold', 3);  % 5-fold CV
auc_values = zeros(cv.NumTestSets,1);  % Store AUCs
optSensitivity = zeros(cv.NumTestSets,1);
optSpecificity = zeros(cv.NumTestSets,1);
optThreshold = zeros(cv.NumTestSets, 1);
accuracy_values = zeros(cv.NumTestSets, 1);

for i = 1:cv.NumTestSets
    trainIdx = training(cv, i);
    testIdx = test(cv, i);
    % Train the model on training set
    trainData = egg_table(trainIdx, :);
    testData = egg_table(testIdx, :);
   % modelspec = [ ...
   %  'Group_logical ~ AE_cat + Allo_cat + DNT_cat + Ego_cat + Switch + Region + ' ...
   %  'AE_cat:DNT_cat + Allo_cat:Ego_cat + DNT_cat:Ego_cat + DNT_cat:Switch + ERP_Minima_Central_100_400'];
   % mdl_cv = fitglm(trainData,modelspec,...
   %  'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Region'});
    %  mdl_cv = fitglm(trainData, 'interactions', 'ResponseVar','Group_logical',...
    % 'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
    mdl_cv = fitglm(trainData,'interactions','ResponseVar','Group_logical'); 

   pred_y = predict(mdl_cv, testData);    
   true_y = double(testData.Group_logical);  % Convert to 0/1 if needed
   % ROC curve and AUC 
   [X, Y, T, auc_values(i)] = perfcurve(true_y, pred_y, 1); 
   [~, optIdx]= max(Y-X);
   optThreshold(i)= T(optIdx);
   optSensitivity(i)= Y(optIdx);          % TPR
   optSpecificity(i)= 1 - X(optIdx);      % 1–FPR

   true = pred_y >= optThreshold(i);
   accuracy_values(i) = mean(true == true_y);
end

mean_auc = mean(auc_values); % Final average AUC
mean_sensitivity= mean(optSensitivity);
mean_specificity=mean(optSpecificity);
mean_accuracy = mean(accuracy_values);
sdv_auc= std(auc_values);
sdv_sen= std(optSensitivity);
sdv_spf= std(optSpecificity);
sdv_acc= std(accuracy_values);

fprintf('Average cross-validated AUC = %.4f\n', mean_auc);
fprintf('Average cross-validated sensitivity = %.4f\n', mean_sensitivity);
fprintf('Average cross-validated specificity = %.4f\n', mean_specificity);
fprintf('Average cross-validated accuracy = %.4f\n', mean_accuracy);

fprintf('sd cross-validated AUC = %.4f\n', sdv_auc);
fprintf('sd cross-validated sensitivity = %.4f\n', sdv_sen);
fprintf('sd cross-validated specificity = %.4f\n', sdv_spf);
fprintf('sd cross-validated accuracy = %.4f\n', sdv_acc);

%% ROC- AUC 
rng(42);
cv = cvpartition(egg_table.Group_logical, 'HoldOut', 0.2);

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = egg_table(trainIdx, :);
testTable = egg_table(testIdx, :);


mdl1 =fitglm(trainTable,'interactions','ResponseVar','Group_logical');
predicted_scores = predict(mdl1, testTable);  
scores      = predict(mdl1, testTable);
true_labels = double(testTable.Group_logical);    % logical 0/1
% ROC curve and AUC 
[X, Y, T, AUC] = perfcurve(true_labels, predicted_scores, 1); 

% X = FPR, Y = TPR, T = thresholds, AUC
% [X,Y,T,AUC] = perfcurve(true_labels, scores, true);

% Youden’s J = max( TPR – FPR )
[~, optIdx]       = max(Y - X);
optThreshold      = T(optIdx);
optSensitivity    = Y(optIdx);          % TPR
optSpecificity    = 1 - X(optIdx);      % 1–FPR

true_y = predicted_scores >= optThreshold;
accuracy_values = mean(true_y == true_labels);

fprintf('Optimal Threshold ≈ %.3f\n',   optThreshold);
fprintf('Sensitivity       ≈ %.2f%%\n', 100*optSensitivity);
fprintf('Specificity       ≈ %.2f%%\n', 100*optSpecificity);
fprintf('Accuracy       ≈ %.2f%%\n', 100*accuracy_values);

%PLOT ROC_AUC: 
figure;
plot(X, Y, 'b-', 'LineWidth', 2);      
hold on;
plot([0 1], [0 1], 'k--');             % chance line
plot(X(optIdx), Y(optIdx), 'ro', ...   % optimal point
'MarkerSize', 8, 'LineWidth', 2);
hold off;

title(sprintf('ROC Curve (AUC = %.3f)', AUC), 'FontSize', 20);
xlabel('False Positive Rate',     'FontSize', 16);
ylabel('True Positive Rate',      'FontSize', 16);
legend('Model','Random Chance','Youden Optimal','Location','SouthEast');
grid on;
set(gca, 'FontSize', 16);

%% PLOT ROC_AUC: 
figure;
plot(X, Y, 'b-', 'LineWidth', 2);      hold on;
plot([0 1], [0 1], 'k--');             % chance line
plot(X(optIdx), Y(optIdx), 'ro', ...   % optimal point
'MarkerSize', 8, 'LineWidth', 2);
hold off;

title(sprintf('ROC Curve (AUC = %.3f)', auc_values), 'FontSize', 20);
xlabel('False Positive Rate',     'FontSize', 16);
ylabel('True Positive Rate',      'FontSize', 16);
legend('Model','Random Chance','Youden Optimal','Location','SouthEast');
grid on;
set(gca, 'FontSize', 16);

%%%% EGG MEASURES COMPUTATION(EXTRA)- Averages across groups and participants in general 

load('merged_table.mat'); 
%MCI 


% HEALTHY 
% 1. Average band power 
mean_power_broad = mean(merged_table.broad(merged_table.Group_logical==0), 'omitnan'); % 0.009
mean_power_brady = mean(merged_table.brady(merged_table.Group_logical==0), 'omitnan'); 
mean_power_tachy = mean(merged_table.tachy(merged_table.Group_logical==0), 'omitnan'); 
mean_power_normo = mean(merged_table.normo(merged_table.Group_logical==0), 'omitnan'); 


sd_power_broad = std(merged_table.broad(merged_table.Group_logical==0), 'omitnan'); 
sd_power_brady = std(merged_table.brady(merged_table.Group_logical==0), 'omitnan'); 
sd_power_tachy = std(merged_table.tachy(merged_table.Group_logical==0), 'omitnan'); 
sd_power_normo = std(merged_table.normo(merged_table.Group_logical==0), 'omitnan'); 

% OVERALL 



%% Relative Contribution 

pm_power_bradyp = mean(merged_table.Brady_Percentage, 'omitnan'); 
pm_power_tachyp = mean(merged_table.Tachy_Percentage , 'omitnan'); 
pm_power_normop = mean(merged_table.Normo_Percentage, 'omitnan'); 

psdv_power_bradyp = std(merged_table.Brady_Percentage, 'omitnan'); 
psdv_power_tachyp = std(merged_table.Tachy_Percentage , 'omitnan'); 
psdv_power_normop = std(merged_table.Normo_Percentage, 'omitnan'); 

%% Most dominant band 

col = merged_table.Dom_band_trial(merged_table.Group_logical==1);

[uniqueWords, ~, idx] = unique(col);
counts = accumarray(idx, 1);
[maxCount, maxIdx] = max(counts);
mostFrequentWord = uniqueWords(maxIdx);

disp(mostFrequentWord);

%% EGG MODEL - PREDICTING MCI FROM ELECTROGASTROGRAPHY FEATURES: 

egg_table = merged_table(:,{'normo','brady','tachy','Group_logical'});
mdl_egg = fitglm(egg_table,'Group_logical~ normo+brady+tachy');
disp(mdl_egg);


egg_table1 = merged_table(:,{'Normo_Percentage','Brady_Percentage','Tachy_Percentage','Group_logical'});
mdl_egg1 = fitglm(egg_table1,'Group_logical~Normo_Percentage+ Brady_Percentage+Tachy_Percentage');
disp(mdl_egg1);

%% Load data
load('merged_table.mat');   % should load variable: merged_table

% Define groups
idx_H = merged_table.Group_logical == 0;   % Healthy
idx_M = merged_table.Group_logical == 1;   % MCI


% VARIABLES FOR FREQ BAND POWER AND RELATIVE CONTRIBUTION
% vars = {'broad','brady','tachy','normo'};
vars = {'Brady_Percentage','Tachy_Percentage','Normo_Percentage'};

nVar = length(vars);

mean_H = zeros(nVar,1);  sd_H = zeros(nVar,1);
mean_M = zeros(nVar,1);  sd_M = zeros(nVar,1);
mean_all = zeros(nVar,1); sd_all = zeros(nVar,1);

% Compute statistics
for v = 1:nVar
    varname = vars{v};
    data = merged_table.(varname);

    mean_H(v) = mean(data(idx_H), 'omitnan'); 
    sd_H(v)   = std(data(idx_H), 'omitnan');
      
    mean_M(v) = mean(data(idx_M), 'omitnan');
    sd_M(v)   = std(data(idx_M), 'omitnan');
    
    mean_all(v) = mean(data, 'omitnan');
    sd_all(v)   = std(data, 'omitnan');
end

%summary table
summary_table = table(vars', ...
    mean_H, sd_H, ...
    mean_M, sd_M, ...
    mean_all, sd_all, ...
    'VariableNames', {'Measure', ...
                      'Mean_Healthy','SD_Healthy', ...
                      'Mean_MCI','SD_MCI', ...
                      'Mean_Overall','SD_Overall'});

disp('NUMERIC SUMMARY TABLE');
disp(summary_table);

% FORMATTED table (Mean ± SD)
fmt = @(m,s) sprintf('%.4f ± %.4f', m, s);

MeanSD_Healthy = arrayfun(fmt, mean_H, sd_H, 'UniformOutput', false);
MeanSD_MCI     = arrayfun(fmt, mean_M, sd_M, 'UniformOutput', false);
MeanSD_Overall = arrayfun(fmt, mean_all, sd_all, 'UniformOutput', false);

summary_table_formatted = table(vars', ...
    MeanSD_Healthy, ...
    MeanSD_MCI, ...
    MeanSD_Overall, ...
    'VariableNames', {'Measure','Healthy','MCI','Overall'});

disp('FORMATTED TABLE (Mean ± SD)');
disp(summary_table_formatted);

%% Save tables to Excel
% writetable(summary_table, 'summary_numeric.xlsx');
% writetable(summary_table_formatted, 'summary_formatted.xlsx');
% 
% disp('Tables saved as summary_numeric.xlsx and summary_formatted.xlsx');


%% T-test FOR EGG BAND POWER AND PERCENTAGE
load('merged_table.mat');

% groups
idx_H = merged_table.Group_logical == 0;   % Healthy
idx_M = merged_table.Group_logical == 1;   % MCI

% VARIABLES FOR FREQ BAND POWER AND RELATIVE CONTRIBUTION
% vars = {'broad','brady','tachy','normo'};
vars = {'Brady_Percentage','Tachy_Percentage','Normo_Percentage'};

nVar = length(vars);

p_ttest   = zeros(nVar,1);
p_ranksum = zeros(nVar,1);
h_ttest   = zeros(nVar,1);
h_ranksum = zeros(nVar,1);

for v = 1:nVar
    varname = vars{v};
    data = merged_table.(varname);
    
    data_H = data(idx_H);
    data_M = data(idx_M);
    
    % Remove NaNs
    data_H = data_H(~isnan(data_H));
    data_M = data_M(~isnan(data_M));
    
    % Parametric test (t-test)
    [h_ttest(v), p_ttest(v)] = ttest2(data_H, data_M);
    
    % Non-parametric test (Mann–Whitney)
    [p_ranksum(v), h_ranksum(v)] = ranksum(data_H, data_M);
end

stats_table = table(vars', ...
    p_ttest, h_ttest, ...
    p_ranksum, h_ranksum, ...
    'VariableNames', {'Measure', ...
                      'p_ttest','h_ttest', ...
                      'p_ranksum','h_ranksum'});

disp('GROUP COMPARISON RESULTS');
disp(stats_table);

%% ranova- SAMPLE CODE FOR EGG ANALYSIS ACROSS GROUPS: 

%load your raw data table
grp = table2array(tableforanova(:,21)); %group

%i create a variable data matrix called test
test = [table2array(tableforanova(:,1:20)), grp]; %the dataset with the group as the first column

varNames = tableforanova.Properties.VariableNames;

t = array2table(test,'VariableNames',varNames);

% Create a table reflecting the within subject factors 'Block', 'Performance', and their levels
factorNames = {'Task','Feature'};

within = table({'T1';'T1';'T1';'T1';'T1';'T2';'T2';'T2';'T2';'T2';'T3';'T3';'T3';'T3';'T3';'T4';'T4';'T4';'T4';'T4';},...
    {'Ft1';'Ft2';'Ft3';'Ft4';'Ft5';'Ft1';'Ft2';'Ft3';'Ft4';'Ft5';'Ft1';'Ft2';'Ft3';'Ft4';'Ft5';'Ft1';'Ft2';'Ft3';'Ft4';'Ft5';},'VariableNames',factorNames);

% fit the repeated measures model
rm = fitrm(t,'T1_ft1-T4_ft6~Group','WithinDesign',within); 
% run my repeated measures anova here
[ranovatbl] = ranova(rm, 'WithinModel','Task*Feature')

multcompare(rm,'Task')
multcompare(rm,'Feature')
multcompare(rm,'Task','by','Feature')

TE ~ trialtype + sessionnum + band + interaction

%%




