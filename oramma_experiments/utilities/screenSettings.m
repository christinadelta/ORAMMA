function [scrn] = screenSettings(set)

% screen settings of the ORAMMA tasks
% 1. defines screen settings
% 2. defines image size

% parameters here can be changed according to your screen and direcories

% unpack settings 
stimdeg         = set.stimdeg;

ptbdir          = '/Applications/Psychtoolbox'; % change to your directory
addpath(genpath(ptbdir))

scrn.ptbdir     = ptbdir;
scrn.screenRes  = [1440 900]; % change to your screen's resolution

%% define screen parameters 
scrn.hz         = 60; 
scrn.distview   = 700;
scrn.width      = 380;
scrn.height     = 677;

%% define the image size 

% don't change anything here

angleradn   = 2 * atan(scrn.width / 2 /scrn.distview);
angledeg    = angleradn * (180/pi);
pix         = scrn.screenRes(1) / angledeg;
scrn.x      = round(stimdeg * pix);
scrn.y      = round(stimdeg * pix);


end