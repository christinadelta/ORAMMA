function [scrn] = screenSettings(set)

% screen settings of the ORAMMA tasks
% 1. defines screen settings
% 2. defines image size
% 3. defines text font, colours, etc..

% parameters here can be changed according to your screen and direcories
% Add PTB to your path
ptbdir          = '/Applications/Psychtoolbox'; % change to your ptb directory
addpath(genpath(ptbdir))

scrn.ptbdir     = ptbdir;
scrn.screenRes  = [1440 900]; % change to your screen's resolution

%% define screen parameters 

% change these parameters as appropreate 

scrn.hz         = 60; 
scrn.distview   = 700;
scrn.width      = 380;
scrn.height     = 677;

%% define the image size 

% don't change anything here

angleradn       = 2 * atan(scrn.width / 2 /scrn.distview);
angledeg        = angleradn * (180/pi);
pix             = scrn.screenRes(1) / angledeg;
scrn.objectx    = round(set.stimdeg * pix);
scrn.objecty    = round(set.stimdeg * pix);

%% define screen fonts sizes and colours

% you may change these parameters as appropreate 
% define colours
scrn.black      = [0 0 0];
scrn.white      = [255 255 255];
scrn.grey       = [128 128 128];

% text settings
scrn.textfont       = 'Verdana';
scrn.textsize       = 20;
scrn.fixationsize   = 30;
scrn.textbold       = 1; 

end