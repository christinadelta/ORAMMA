function [set] = TaskSettings(taskNb)

% THIS IS A SUBFUNCTION, PART OF THE ORAMMA EXPERIMENTS

% it takes as input the task number (from the main script) and outputs a
% structure with a few important starting settings and parameters for each
% task

% FOR DETAILED INFORMATION ABOUT EACH EXPERIMENTAL TASK, SETTINGS, HOW TO,
% etc.. REFER TO DOCUMENTATION FILE IN :
% /ORAMMA/documentation/oramma_tasksettings or
% /ORAMMA/documentation/oramma_runtasks

% ChristinaDelta (christina.delta.k@gmail.com)

% NOTE:
% All parameters in this function can change as appropreate 

% GLOBAL PARAMETERS AND SETTINGS:
set.taskNb      = taskNb; % initialize settings structure

% STIMULI SETTINGS
set.stimdeg     = 5;    % stimulus visual angle
set.stimsize    = 200;  % should resize to 220x200 or leave it as 252x252?


if taskNb == 1
    
    % create a list of settings and parameters for the rts task
    
    % BASIC IMPORTANT SETTINGS
    set.name        = 'rts'; % task name
    set.runs        = 2; % number of blocks (or runs)
    set.break       = 5; % default break between runs
    set.EEG         = 0; % set to 1 when in testing room
    set.MEG         = 0; % set to 1 when in testing room

    % EXPERIMENTAL SETTINGS
    set.fixation    = '+';  % fixation cross 
    set.duration    = .200; % stimulus duration = 200 ms
    set.response    = 1.5;  % response time in seconds
    set.isi         = 1.7;  % in seconds
    set.jitter      = .2;   % 200 ms
    
elseif taskNb == 2
    
    % BASIC IMPORTANT SETTINGS
    set.name        = 'rts'; % task name
    set.runs        = 2; % number of blocks (or runs)
    set.break       = 5; % default break between runs
    set.EEG         = 0; % set to 1 when in testing room
    set.MEG         = 0; % set to 1 when in testing room
    

    % EXPERIMENTAL SETTINGS
    set.fixation    = '+';      % fixation cross 
    set.iti         = 3.5;      % RSVP duration + responses 
    set.response    = 1;        % response time in seconds
    set.isi         = 0.100;    % in seconds ( this is 17 ms stimulus + 83 ms blank)
    set.jitter      = .2;       % 200 ms jitter
    set.rsvp        = 15;       % length of hte RSVP stream (13 letters/distractors + 2 targets = 15 items)
    set.post1       = 5;        % position of the 1st target (T1) in the RSVP
    set.post2       = [7 12];   % potential posiitons of the 2nd target (T2)- lag 2 and lag 7
    

end % end of if statement


end