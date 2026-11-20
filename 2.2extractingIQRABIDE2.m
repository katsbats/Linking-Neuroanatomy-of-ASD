%defining my directory
rootDir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Input';

% finding the xmlfiles per subject
xmlFiles = dir(fullfile(rootDir,'ABIDE_II*', '**', 'report', 'cat_*.xml')); %necessary for my folder structure in ABIDE2
numel(xmlFiles)

% make order deterministic
paths = fullfile({xmlFiles.folder}, {xmlFiles.name});
[~, idx] = sort(lower(paths));
xmlFiles = xmlFiles(idx);

n = numel(xmlFiles);
Site   = strings(n,1);
SUB_ID = strings(n,1);
IQR = zeros(n,1);
%%
for i = 1:n
    
    %monitoring progress
    fprintf('%d / %d\n', i, n);
    
    % Full XML path
    f = fullfile(xmlFiles(i).folder, xmlFiles(i).name);

    % skip anat2/anat3/... (keep anat1 or single cat_*.xml)
    if ~isempty(regexp(xmlFiles(i).name, '_anat\d+\.xml$', 'once')) && ...
       isempty(regexp(xmlFiles(i).name, '_anat1\.xml$', 'once'))
        continue
    end %necessary because in ONRC they did multiple anats per subject, i just want to keep the 1st
    
    %extracting sub ID
    [~, subjFolder] = fileparts(fileparts(fileparts(f)));

    parts = split(subjFolder, '_');
    Site(i)   = parts(1);
    SUB_ID(i) = parts(end);

    try
        IQR(i) = str2double( ...
            xmlread(f).getElementsByTagName('IQR').item(0).getTextContent ...
        );
    catch
        IQR(i) = NaN; %because code didnt run fully, meaning not all subjects have a IQR
    end

end

%%
T = table(Site, SUB_ID, IQR);
% remove empty rows caused by skipped files
T = T(SUB_ID ~= "", :);
writetable(T, fullfile(rootDir,'CAT12_IQR_ABIDE2.csv'));
 

