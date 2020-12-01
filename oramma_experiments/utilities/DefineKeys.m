function[keys] = DefineKeys(taskNb)

% ChristinaDelta (christina.delta.k@gmail.com)

% This subfunction is part of the ORAMMA EXPERIMENTS
% It runs via the main script of each task using the task number (taskNb)

% it creates a list of keys for each experiment alongside with the "global" 
% keys used in all experiments:

% GLOBAL KEYS
% 1. Escape key (allows subject to quit the experiment)
% 2. Space key (allows subject to move to next runs

KbName('UnifyKeyNames');
KbChecklist     = [KbName('space'),KbName('ESCAPE')];

% CREATE A LIST WITH TASK SPECIFIC KEYS
if taskNb == 1 % if task is rts
    
    responsekeys    = {'q','p'}; % q = animate, p = inanimate
    
    for i = 1:length(responsekeys)
        KbChecklist = [KbName(responsekeys{i}),KbChecklist];
    end
    
    RestrictKeysForKbCheck(KbChecklist);


    keys.animatekey      = KbChecklist(1); % 'q'
    keys.inanimatekey    = KbChecklist(2); % 'p'
    keys.spacekey        = KbChecklist(3); % 'space'
    keys.esckey          = KbChecklist(4); % 'escape'
    
elseif taskNb == 2
    
    responsekeys    = {'1','2', '3'}; % 1 = upper left option, 2 = upper right option,  3 = center option
    
    for i = 1:length(responsekeys)
        
        KbChecklist = [KbName(responsekeys{i}),KbChecklist];
    end
    
    RestrictKeysForKbCheck(KbChecklist);
    
    keys.option1    = KbChecklist(1); % '1'- upper left
    keys.option2    = KbChecklist(2); % '2'- upper right
    keys.option3    = KbChecklist(1); % '3'- center
    keys.spacekey   = KbChecklist(3); % 'space'
    keys.esckey     = KbChecklist(4); % 'escape'

    
end % end of if statement



end