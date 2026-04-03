# MSR-thesis-codes-EEG-EGG-Model-Plots-
Understanding the effects of cognitive overload on spatial navigation and neural resource allocation in Mild cognitively impaired cohort.

EEG (Electroencephalography) folder: 
Contains all the files related to EEG Preprocessing and Analysis. It includes basic EEG preprocessing, Connectivity analysis, Generalised EIigen decomposition(GED), Mismatch Negativity logged ERP analysis. Most of the code uses a struct that contains EEG data preprocessed and filtered across bands and segmented across trials using timestamps. Each file has a detailed introduction and the code for the structured is also uploaded. 
For any query, please contact: 
Adrija Chatterjee: adrijac23@iitk.ac.in/ chatadrija@gmail.com or 
Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in or
Prof. Dr. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

EGG (Electrogastrography) folder: 
Contains all the files related to EGG Preprocessing and Analysis. It includes EGG preprocessing- includes filtering, selection of best electrode, baseline power, trial wise power calculation and relative contribution of each band(by window count). Most of the code uses a struct that contains EGG data preprocessed and filtered across bands and segmented across trials using timestamps. Each file has a detailed introduction and the code for the structured is also uploaded. 
For any query, please contact: 
Adrija Chatterjee: adrijac23@iitk.ac.in/ chatadrija@gmail.com or 
Prof. Dr. Pragathi P. Balasubramani: pbalasub@iitk.ac.in

Model and validation folder: 
This file contains the codes for: 
1) Optimisation of the model for selection of the model with the best features using a method called Recursive Feature Elimination (RFE) 
2) classifying Mild Cognitive impaired population compared to healthy from 1) Behavioural 2)Neural 3) Gastric features and validating them through K-fold and 80-20(train-test) split- taking inputs from the RFE analysis.
For any query, please contact: 
Adrija Chatterjee: adrijac23@iitk.ac.in/ chatadrija@gmail.com or 
Shreelekha BS, Shreelekha.bs@students.iiserpune.ac.in or
Prof. Dr. Pragathi P. Balasubramani: pbalasub@iitk.ac.in







 
