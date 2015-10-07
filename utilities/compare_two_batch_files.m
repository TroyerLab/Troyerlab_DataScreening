function []=compare_two_batch_files(batch1_name,batch1_path,batch2_name,batch2_path,varargin)
%% Syntax
%
% []=compare_two_batch_files(batch1_name,batch1_path,batch2_name,batch2_path,varargin)
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
narg_min=4;

prob_path=pwd;


in_message1='Please select the first batch file';
in_message2='Please select the second batch file';

if nargin<narg_min
     [batch1_name,batch1_path]=uigetfile([prob_path filesep '*.*'],in_message1);   % file input 
     [batch2_name,batch2_path]=uigetfile([prob_path filesep '*.*'],in_message2);
          
     % sets defaults
     supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
     supp_inputs.disk_write_dir=batch1_path;    
else
     % sets defaults
     supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
     supp_inputs.disk_write_dir=batch1_path;
    % processing supplementary inputs
    supp_inputs=parse_pv_pairs(supp_inputs,varargin);
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
inputs=struct('batch1_name',batch1_name,'batch1_path',batch1_path,'batch2_name',batch2_name,'batch2_path',batch2_path);

% Checking if output directories need to specified and if they have been specified 

if supp_inputs.write_to_disk_q
    if ~exist(supp_inputs.disk_write_dir,'dir')
        supp_inputs.disk_write_dir=uigetdir(prob_path,'Please select the directory where to store the output mat file. Hit cancel if you don''t want the function to write a mat file');
        if supp_inputs.disk_write_dir==0
            supp_inputs.write_to_disk_q=0;
        end
    end
end

% putting file separators at the end of all input paths
if ~isempty(batch1_path)
    if ~strcmpi(batch1_path(end),filesep)
        batch1_path=[batch1_path,filesep];
    end
end
if ~isempty(batch2_path)
    if ~strcmpi(batch2_path(end),filesep)
        batch2_path=[batch2_path,filesep];
    end
end

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end

%% Body of the function
filelist1=make_filelist_from_batch(batch1_name,batch1_path);
filelist2=make_filelist_from_batch(batch2_name,batch2_path);

batch1_only=setdiff(filelist1,filelist2);
batch2_only=setdiff(filelist2,filelist1);

quest_msg=[num2str(length(batch1_only)) ' files out of ' num2str(length(filelist1)) ' are unique to the first batch file. Do want to you write a batch file using these?'];
quest_dialog_title='';
quest_option1='Yes';
quest_option2='No';
quest_default_option=quest_option2;

quest_resp=questdlg(quest_msg,quest_dialog_title,quest_option1,quest_option2,quest_default_option);
if strcmpi(quest_resp,quest_option1)
  selected_batchname=uiputfile([supp_inputs.disk_write_dir '*.*'],'What name do you want to give to the batch file of files unique to batch 1?','batch1_*');
  spawning_func=mfilename('fullpath');
  write_batch_from_filelist(batch1_only,selected_batchname,supp_inputs.disk_write_dir,...
                                                                    'batch_inputs',inputs,...
                                                                    'batch_supp_inputs',supp_inputs,...
                                                                    'spawning_func',spawning_func);
end


quest_msg=[num2str(length(batch2_only)) ' files out of ' num2str(length(filelist2)) ' are unique to the second batch file. Do want to you write a batch file using these?'];
quest_dialog_title='';
quest_option1='Yes';
quest_option2='No';
quest_default_option=quest_option2;

quest_resp=questdlg(quest_msg,quest_dialog_title,quest_option1,quest_option2,quest_default_option);
if strcmpi(quest_resp,quest_option1)
  selected_batchname=uiputfile([supp_inputs.disk_write_dir '*.*'],'What name do you want to give to the batch file of files unique to batch 2?','batch2_*');
  spawning_func=mfilename('fullpath');
  write_batch_from_filelist(batch2_only,selected_batchname,supp_inputs.disk_write_dir,...
                                                                    'batch_inputs',inputs,...
                                                                    'batch_supp_inputs',supp_inputs,...
                                                                    'spawning_func',spawning_func);
end



