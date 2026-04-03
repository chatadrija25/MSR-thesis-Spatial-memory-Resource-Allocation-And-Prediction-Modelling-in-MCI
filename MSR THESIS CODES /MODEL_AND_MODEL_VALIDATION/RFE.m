
% The authors of this code are Shreelekha BS, Adrija Chatterjee and Prof. Pragathi P.
% Balasubramani, Translational Neuroscience and Technology Lab(Transit),
% Department of Cognitive Science, Indian Institute of Technology, Kanpur.

% About the code: 
% The code uses a method to optimise the model and select the best features
% using a method known as recursive feature elimination method(RFE). 

% Feature Removal and AUC Evaluation:
% At each iteration, we removed one feature at a time, refit the model, and calculated AUC.
% The feature whose removal resulted in the highest AUC was eliminated,
% repeating this process until all features were evaluated. 
% Removal feature (j*) selected based of AUC of model devoid of j. 

% j∗ = argjmax​ ( AUC−j​ )
% Performance Metrics and Model Selection :
% For each model, we recorded AUC, accuracy, sensitivity, and specificity. 
% Finally, after all features have been evaluated and removed, the model with the best AUC, accuracy, 
% sensitivity, and specificity is selected as the final model.


% For any query, please contact: 
% Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in
% Adrija Chatterjee: adrijac23@iitk.ac.in or
% Prof. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

%% 
% CODE FOR BASE MODEL 
clc
load("merged_table.mat");
beh_table1 = merged_table(:,{'AE_cat','Allo_cat','DNT_cat','Ego_cat','Switch','Group_logical'});

rng(42);
cv = cvpartition(beh_table1.Group_logical, 'HoldOut', 0.2, 'Stratify', true); 

trainIdx = training(cv); % logical indices for training
testIdx = test(cv);      % logical indices for validation

trainTable = beh_table1(trainIdx, :);
testTable = beh_table1(testIdx, :);

% we can substitute the model to be glm and lm and run for the RFE: 
mdl = fitlm(trainTable,'interactions','ResponseVar','Group_logical',...
 'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
disp(mdl); 

mdl1= fitglm(trainTable,'interactions','ResponseVar','Group_logical',...
 'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
mdl2= fitlm(trainTable,'interactions','ResponseVar','Group_logical',...
 'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});

% this list will save the values for each model after removing terms using
% RFE: 

accuracy_list = [];
removed_terms = {};
final_auc = [];
final_sensitivity = []; 
final_specificity = [];

%% 
true_y= testTable.Group_logical;
pred_y = predict(mdl, testTable);
[X0,Y0,T0,AUC0] = perfcurve(true_y, pred_y, true);
fprintf('AUC for the first model ≈ %.3f\n', AUC0);
% Youden’s J = max( TPR – FPR )
[~, optIdx] = max(Y0 - X0);
optThreshold = T0(optIdx);
optSensitivity = Y0(optIdx); % TPR
optSpecificity = 1 - X0(optIdx); % 1–FPR
y_class = pred_y >= optThreshold;
accuracy = mean(y_class == true_y);
accuracy_list(end+1) = accuracy;
final_auc(end+1) = AUC0;
final_sensitivity(end+1) = optSensitivity;
final_specificity(end+1) = optSpecificity;

%% RFE

coefNames = mdl.CoefficientNames(2:end);
currentFeatures = coefNames
figure;
subplot(2, 2, 1);
plot(X0, Y0, 'LineWidth',2); % plot initial model
hold on;
% Loop until all features are removed
while length(currentFeatures) > 0
 AUC_values = []; % Store AUC for each model

 % Evaluate AUC for each model with one feature removed
 for i = 1:length(currentFeatures)
 % mdl = fitglm(trainTable,'interactions','ResponseVar','Group_logical',...
 % 'CategoricalVars',{'AE_cat','Allo_cat','DNT_cat','Ego_cat'});
 tempFeatures = setdiff(currentFeatures, currentFeatures{i}); % Remove one feature
 cleanedTerm = regexprep(currentFeatures{i}, '_\d+', '');
 model_updated = mdl;
 try
 mdl_updated = removeTerms(model_updated, cleanedTerm);
 catch
 warning('Failed to remove term: %s (as %s)', cleanedTerm);
 break;
 end
 % Predict and calculate AUC
 pred_y = predict(mdl_updated, testTable);
 true_y = testTable.Group_logical;

 [X, Y, T, AUC] = perfcurve(true_y, pred_y, true); % Compute AUC

 AUC_values(i) = AUC; % Store AUC
 end

 % Find the index of the feature that gives the highest AUC
 [maxAUC, maxIdx] = max(AUC_values); % Find max AUC and index
 bestFeature = currentFeatures{maxIdx}; % Feature corresponding to max AUC
 currentFeatures = setdiff(currentFeatures, bestFeature);
 % Remove the feature with the highest AUC
 bestFeature = regexprep(bestFeature, '_\d+', '');
 % Fit the model after removing the best feature
 mdl = removeTerms(mdl, bestFeature);
 disp(mdl)
 % Predict and calculate performance metrics
 pred_y = predict(mdl, testTable);
 true_y = testTable.Group_logical;

 [X, Y, T, AUC] = perfcurve(true_y, pred_y, true);
 fprintf('AUC for the model ≈ %.3f\n', AUC);
 plot(X, Y, 'LineWidth', 1);
 % Calculate optimal threshold (Youden’s J)
 [~, optIdx] = max(Y - X);
 optThreshold = T(optIdx);
 y_class = pred_y >= optThreshold;
 accuracy = mean(y_class == true_y);
 optSensitivity = Y(optIdx); % TPR
 optSpecificity = 1 - X(optIdx);

 % Store results
 accuracy_list(end+1) = accuracy;
 removed_terms{end+1} = bestFeature; % Record removed feature
 final_auc(end+1) = AUC;
 final_sensitivity(end+1) = optSensitivity;
 final_specificity(end+1) = optSpecificity;
 fprintf('Removed %s, AUC: %.3f, Accuracy: %.2f%%\n', bestFeature, maxAUC, accuracy*100);
end

removed_terms_trans = transpose(removed_terms);

title('All ROC Curves as Features Are Removed','FontSize',18);
xlabel('False Positive Rate', 'FontSize', 16);
ylabel('True Positive Rate', 'FontSize', 16);
legendEntries = arrayfun(@num2str, 1:16, 'UniformOutput', false);
legend(legendEntries,'Location','best');

%% 

% Plot AUC values vs model index (number of features removed)
subplot(2, 2, 2);
plot(1:length(accuracy_list), accuracy_list, '-o');
xlabel('Number of Features Removed');
ylabel('Accuracy');
title('Accuracy after Feature Removal');

% Plot AUC for all models
subplot(2, 2, 3);
plot(1:length(final_auc), final_auc, '-o');
xlabel('Model Index (Number of Features Removed)');
ylabel('AUC');
title('AUC for All Models');

subplot(2,2,4);
plot(1:length(final_sensitivity), final_sensitivity , '-b');
hold on
plot(1:length(final_specificity), final_specificity , '-r');
xlabel('Model Index (Number of Features Removed)');
ylabel('sensitivity and specificity');
legend({'Sensitivity', 'Specificity'}, 'Location', 'best');
title('for all models');


hold off;
%%
