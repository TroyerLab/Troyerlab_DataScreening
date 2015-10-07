function [threshold_satisfied]=determine_if_file_satisfies_threshold(screening_ftrs,threshold_criteria)
%% Syntax
%
% [outputs]=function_template(inp1,inp2,inp3,inp4,varargin)
%
%% Inputs  
%
%
%
%
%% Computation/Processing     
% 
%
%
% 
%
%% Outputs  
% 
% 
%
%
%% Assumptions
%
%
%
%
% % % Triple percentage sign indicates that the code is part of the code
% template and may be activated if necessary in later versions. 
%% Version and Author Identity Notes  
% 
% Last modified by The Big Foot on 1/1/1400
% 
% previous version:
% next version: 
%% Related procedures and functions 
% 
%
%
%
%% Detailed notes
%
%
%
%
%% Processing inputs and beginning stuff

% putting in a stop for easier debugging
dbstop if error

% processing mandatory inputs
narg_min=2;

if nargin<narg_min
     error(['The number of inputs should at least be ' narg_min])
end



%% Body of the function
if length(screening_ftrs)>1
   error('# of files submitted for determination are greater than 1') 
end
no_criteria=length(threshold_criteria);

threshold_satisfied=0;
for j=1:no_criteria
    file_in=0;
    val=screening_ftrs.(threshold_criteria(j).ftr);
    switch threshold_criteria(j).thr_type
        case 'distance within'
            anchor=threshold_criteria(j).thr_param_1;
            dist=threshold_criteria(j).thr_param_2;
            if abs(val-anchor)<=dist
                file_in=1;
            end
            
        case 'distance outside'
            anchor=threshold_criteria(j).thr_param_1;
            dist=threshold_criteria(j).thr_param_2;
            if abs(val-anchor)>=dist
                file_in=1;
            end
            
        case 'one bound'
            anchor=threshold_criteria(j).thr_param_1;
            eval(['if val' threshold_criteria(j).thr_param_2 'anchor' ' file_in=1; end'])                
        case 'two bounds within'
            anchor1=threshold_criteria(j).thr_param_1;
            anchor2=threshold_criteria(j).thr_param_2;
            lo_bound=min(anchor1,anchor2);
            hi_bound=max(anchor1,anchor2);
            if val>=lo_bound && val<=hi_bound
                file_in=1;
            end
        case 'two bounds outside'
            anchor1=threshold_criteria(j).thr_param_1;
            anchor2=threshold_criteria(j).thr_param_2;
            lo_bound=min(anchor1,anchor2);
            hi_bound=max(anchor1,anchor2);
            if val<=lo_bound || val>=hi_bound
                file_in=1;
            end
        otherwise
            error('The threshold criteria have an invalid value for threshold type')            
    end
     if j==1
         
        threshold_satisfied=file_in;
    else
       if strcmpi(threshold_criteria(j-1).rel_to_next_criterion,'and')
          threshold_satisfied=file_in && threshold_satisfied; 
       else
           threshold_satisfied=file_in || threshold_satisfied;
       end
    end
end
return 

