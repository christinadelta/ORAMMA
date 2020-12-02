function [set] = loadimages(set, workingdir)

% INFO

% the function loads stimuli path, xls files and stimuli for each task
% all requirements to get to correct paths and images are:

% 1. Task number (we need this to get the correct stimuli for each task)
% 2. Stimuli directory

% task nb: useful to go get the right stimulus materials, 
% which vary from task to task 
taskNb              = set.taskNb;
imgsize             = set.stimsize;

% initial paths
exceldir            = fullfile(workingdir, 'excel_folders');
imgdir              = fullfile(workingdir, 'stimuli');

% how many lines of no interest do we have in the excel file? (useful to
% remove headers
headers             = 1; 
% how many columns?
columns             = 5; 

if taskNb == 1 % rts version 1
    
    % get the correct stimuli
    task_stimuli        = fullfile(imgdir, 'stimuli36');

    % read the excel file
    [vars, ~ ,raw]      = xlsread(fullfile(exceldir, 'imageset36.xls'));

    % remove the headers
    raw(headers,:)      = [];
    vars(headers,:)     = [];

    set.animacy         = vars(:,1);
    set.category        = vars(:,2);
    set.item            = vars(:,3);

    % ------------------------------
    % create a stucture to store the image files 
    data                = [];
    set.allitems        = length(raw);      

    for i=1:length(raw)

            Img             = fullfile(task_stimuli,raw{i});
            image           = imread(Img);
            data(i).file    = imresize(image,[set.stimsize set.stimsize]); % should resize or not?

    end

    % update settings structure
    set.data        = data;

    set.stimw       = size(data(1).file,1);   % width of objects
    set.stimh       = set.stimw;              % height of objects
    
    clear image data raw vars
    
elseif taskNb == 2 % ab version 1
    
    % go AB stimuli directoey
    correct_stimuli         = fullfile(imgdir, 'AB_stimuli');
    
    % extract letters and digits 
    abletters               = fullfile(correct_stimuli, 'letters');
    abdigits                = fullfile(correct_stimuli, 'digits');
    
    % read the associated excel file
    [letterIdx,~,letters]   = xlsread(fullfile(exceldir, 'ab_letters.xls'));    % letters xls file
    [digitIdx,~,digits]     = xlsread(fullfile(exceldir, 'ab_digits.xls'));     % digits xls file
    
    % remove the headers
    letters(headers,:)      = [];
    letterIdx(headers,:)    = [];
    digitIdx(headers,:)     = [];
    digits(headers,:)       = [];
    
    set.Lindex              = letterIdx(:, 1);  % stimlulus type distractors (2)
    set.Dindex              = digitIdx(:, 1);   % stimlulus type targets (1)
    set.Litems              = letterIdx(:, 2);  % item number (1-26) letters/distrctors
    set.Ditems              = digitIdx(:, 2);   % item number (1-10) digits/targets
    
    % --------------------------------
    % create a stucture to store the distractor image files 
    distractordata          = [];
    set.alldistractors      = length(letters);  
    
    for i=1:length(letters)

            Img                     = fullfile(abletters,letters{i});
            image                   = imread(Img);
            distractordata(i).file  = imresize(image,[set.stimsize set.stimsize]); % should resize or not?

    end
    
    % update settings structure
    set.distrctordata   = distractordata;

    set.dstrw           = size(distractordata(1).file,1);   % width of objects
    set.dstrh           = set.dstrw;                        % height of objects
    
    clear Img image
    
    % -----------------------
    % create a stucture to store the target image files 
    targetdata                  = [];
    set.alltargets              = length(digits);  
    
    for i=1:length(digits)

            Img                 = fullfile(abdigits,digits{i});
            image               = imread(Img);
            targetdata(i).file  = imresize(image,[set.stimsize set.stimsize]); % should resize or not?

    end
    
    % update settings structure
    set.targetdata  = targetdata;

    set.trgw        = set.dstrw;  % same widht and height like the distractor objects
    set.trgh        = set.dstrw; 
    
    clear Img image
    
end % end of task if statement



end