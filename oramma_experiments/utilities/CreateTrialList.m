function [trials] = CreateTrialList(set)

% Uses the task number to create a list of trials for each task 
% part of the ORAMMA experiments

taskNb = set.taskNb;

if taskNb == 1 % if task is RTs 
    
    itemreps        = 2; % how many times will each item be presented?
    listoftrials    = repmat(cat(2, set.item, set.animacy, set.category),itemreps,1); % create total trial list
    
    runtrials       = length(listoftrials)/set.runs; % how many trials per run? 
    randomizedlist  = listoftrials(randperm(length(listoftrials)),:); % randomize original trial list
    
    temp                = 0; % used to split trials in runs 
       
    % split trials in runs 
    for i = 1:set.runs
        
        trials.list{i}  = randomizedlist(1 + temp:runtrials * i,:); 
        
        temp            = temp + runtrials;
        
    end % end of for loop
    
    trials.runtrials    = runtrials; % add runtrials to the trials struct (we'll use this when running trials)
    
elseif taskNb == 2 % if task is ab
    
    % Create a triallist for the ab task.
    % we control for : t1 is not the same as t2 in trials
    % something to consider: should also make sure that we don't get the
    % same t1s in subsequent trials?
    
    targetreps  = 12; % each digit will be presented the same nb of times as t1, t2, lag2 and lag7
   
    optionst1   = set.Ditems; % digit items (targets)
    optionst2   = optionst1;
    
    targets     = length(optionst2);
    
    allt1s      = repmat(optionst1',targetreps,1);
    
    
    randomize   = 1;
    while randomize % % make sure that t1 ~= t2
        
        
        temp    = randperm(length(allt1s));
        randt1s = allt1s(temp);
        same    = (randt1s - allt1s) == 0;
        
        if not(any(same))
            
            randomize   = 0;
            templist    = cat(2, randt1s, allt1s);
            
        end
        
    end % end of while loop
    
    clear temp
    
    % add a lag index (1=lag2, 2=lag7)
    halflist        = length(allt1s)/2;
    
    templist(:,3)   = cat(1, ones(halflist,1), ones(halflist,1)*2);

end % end of if statement 


end