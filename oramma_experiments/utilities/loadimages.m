function [set] = loadimages(set)

% INFO

% the function loads stimuli path, xls files and stimuli for each task
% all requirements to get to correct paths and images are:

% 1. Task number (we need this to get the correct stimuli for each task)
% 2. Stimuli directory

% task no: useful to go get the right stimulus materials, 
% which vary from task to task 
taskNo              = set.nb;
imgsize             = set.stimsize;

% initial paths
workingdir          = set.workingdir;
exceldir            = fullfile(workingdir, 'excel_folder');
imgdir              = fullfile(workingdir, 'stimuli36');

% how many lines of no interest do we have in the excel file? (useful to
% remove headers
headers             = 1; 
% how many columns?
columns             = 7; 

% read the excel file
[vars,txt,raw]       = xlsread(fullfile(exceldir, 'imageset36.xls'));

% remove the headers
raw(headers,:)      = [];
vars(headers,:)     = [];

set.animacy         = vars(:,1);
set.category        = vars(:,2);
set.item            = vars(:,3);

% create a stucture to store the image files 
data                = [];
allitems            = length(raw);      

for i=1:length(raw)

        thisImg         = fullfile(imgdir,raw{i});
        image           = imread(thisImg);
        data(i).file    = imresize(image,[set.stimsize set.stimsize]); % should resize or not?
       
end

% update settings structure
set.allitems    = allitems;
set.data        = data;

% make textures of the images
texture = cell(1,allitems);

for i = 1:allitems
    
    texture{i} = Screen('MakeTexture', window, set.data(i).file); 
    
end

% width and height 
set.w           = imgsize;
set.h           = set.w;

set.stimw       = size(data(1).file,1);   % width of objects
set.stimh       = set.stimw;                    % height of objects


clear image data raw txt vars

end