function []=delete_files_in_batch(batchname,batchpath,recycle_q)
%% Syntax
%
% []=delete_files_in_batch(batchname,batchpath,recycle)
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
% The code assumes that the batch file is located in the same diretory as
% the files to be deleted. 
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
narg_min=3;

prob_path=pwd;

in_message1='Please select the batch file';
in_message2='Should the files be recycled (1) or not(0)? Enter 1 or 0';

if nargin<narg_min
     [batchname,batchpath]=uigetfile([prob_path filesep '*.*'],in_message1);   % file input 
     recycle_q=input([in_message2 '\n-->  ']); % non string input   

end


% putting file separators at the end of all input paths
if ~isempty(batchpath)
    if ~strcmpi(batchpath(end),filesep)
        batchpath=[batchpath,filesep];
    end
end

%% Body of the function
filelist=make_filelist_from_batch(batchname,batchpath);
no_files=length(filelist);

orig_state=recycle;

if recycle_q==1
    recycle('on');
elseif recycle_q==0
    recycle('off');    
else
    error('Incorrect value for the variable recycle')
end

for i=1:no_files
    
   filename=[batchpath filelist{i}];
   
   if ~exist(filename,'file')
        quest_msg=['File ' filename ' could not be found. Do you want to skip it and continue or abort the program?'];
        quest_dialog_title='';
        quest_option1='Skip and Continue';
        quest_option2='Abort';
        quest_default_option=quest_option2;

        quest_resp=questdlg(quest_msg,quest_dialog_title,quest_option1,quest_option2,quest_default_option);
        if strcmpi(quest_resp,quest_option1)
            fprintf('\nSkipping file %s since it cannot be found\n',filename)
            continue
        elseif strcmpi(quest_resp,quest_option2) ||isempty(quest_resp)
           fprintf('\nAborting the program since the file %s cannot be found.\n',filename)
           return         
        end
   end
   
   delete(filename)   
end

recycle(orig_state);







