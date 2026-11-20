%defining my directory
rootDir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Input/ABIDE_I';

% finding the xmlfiles per subject
xmlFiles = dir(fullfile(rootDir, '**', 'report', 'cat_*.xml')); 

% make order deterministic
paths = fullfile({xmlFiles.folder}, {xmlFiles.name});
[~, idx] = sort(lower(paths));
xmlFiles = xmlFiles(idx);

n = numel(xmlFiles); %had to do this so that the data structure matches that of the pheno data
Site   = strings(n,1);
SUB_ID = strings(n,1);
IQR = zeros(n,1);

for i = 1:n
    
    %monitoring progress
    fprintf('%d / %d\n', i, n);
    
    %extracting the sub ID
    f = fullfile(xmlFiles(i).folder, xmlFiles(i).name);

    [~, subjFolder] = fileparts(fileparts(fileparts(f)));

    parts = split(subjFolder, '_');
    Site(i)   = parts(1);
    SUB_ID(i) = parts(end);

    try
        IQR(i) = str2double(xmlread(f).getElementsByTagName('IQR').item(0).getTextContent);
    catch
        IQR(i) = NaN; %added because code didnt run fully, meaning not all subjects have a IQR
    end

end

T = table(Site, SUB_ID, IQR);
writetable(T, fullfile(rootDir,'CAT12_IQR_ABIDE1.csv'));
%% 

