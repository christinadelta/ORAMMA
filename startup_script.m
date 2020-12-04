%% STARTUP SCRIPT 

% CLEAN UP        
clear;
clc  
close all hidden;

% THE SCRIPT SHOULD RUN IN DIRECTORY : '/ORAMMA'
% PRESS RUN OR TYPE "startup_script" IN THE COMMAND WINDOW AND ENTER 
% THE TASK CODE NAME. THIS WILL ADD THE CORRECT PATHS OF THE CURRENT
% EXPERIMENT TO YOUR MATLAB PATH. AND THEN RUN THE CORRECT "main_task"
% SCRIPT.

% TASK CODE NAMES:

% ab                = attentional blink 
% rts               = reaction times
% dt                = discriminability task
% wm                = working memory task
% vs                = visual search task

% WORKING DIRECTORIES AND INFO:

% startpath (or root)                   = /ORAMMA/
% working_dir                           = /startpath/oramma_experiments

% core experimental functions           = /working_dir/utilities
% experimental stimuli                  = /working_dir/stimuli
% tasks directory                       = /working_dir/experiments
% participant log files                 = /working_dir/results
% ORAMMA project read me files          = /startpath/documentation

% DEFINE INITIAL PATHS
startpath           = pwd;
workingpath         = fullfile(startpath, 'oramma_experiments');
% taskpath            = fullfile(workingpath, 'experiments');

% create a user input dialog to gather information
prompt          = {'Enter task name (e.g. rts):','Enter subject number (e.g. 01:'};
dlgtitle        = 'Info window';
dims            = [1 30];
definput        = {'rts','01'}; % this is a default input (this should change)
answer          = inputdlg(prompt,dlgtitle,dims,definput);

startup.answer  = answer;    % participant number and task name
getpath         = answer{1}; % usefull to read the correct task name and run the main script

switch getpath
    
    case 'ab'
        
        taskpath = fullfile(workingpath, 'ab');
        addpath(genpath(taskpath));
        main_abV1
        
    case 'rts'
        
        taskpath = fullfile(workingpath, 'rts');
        addpath(genpath(taskpath));
        main_rts
        
    case 'pw'
        
        taskpath = fullfile(workingpath, 'pw');
        addpath(genpath(taskpath));
        main_pw
        
    otherwise
        
        disp('wrong task name, try again!');
        
end

clear startpath workingpath

