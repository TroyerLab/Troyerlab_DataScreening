function []=write_batch_from_filelist(filelist,batchname,batchpath,varargin)
%% Syntax
%
% []=write_batch_from_filelist(filelist,batchname,batchpath,varargin)
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
narg_min=3;

if nargin<narg_min
     error(['The number of inputs should at least be ' narg_min])
end

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir=batchpath;
supp_inputs.batch_inputs='';
supp_inputs.batch_supp_inputs='';
supp_inputs.spawning_func='';
supp_inputs.batch_timestamp='';


supp_inputs=parse_pv_pairs(supp_inputs,varargin);

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

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end

%% Body of the function



%% Processing outputs 
arch_timestamp=supp_inputs.batch_timestamp;
arch_inputs=supp_inputs.batch_inputs;
arch_supp_inputs=supp_inputs.batch_supp_inputs;
spawning_func=supp_inputs.spawning_func;

if supp_inputs.write_to_disk_q==1
    % writing the batch file
    batch_full=[supp_inputs.disk_write_dir batchname];
    fid=fopen(batch_full,'w');
    no_files=length(filelist);
    for i=1:no_files
        fprintf(fid,'%s\n',filelist{i});
    end
    fclose(fid);
    
    % writing the input parsms file for the batch
    batch_mat_full=[supp_inputs.disk_write_dir batchname '_input_params.mat'];
    save(batch_mat_full,'arch_inputs','arch_supp_inputs','spawning_func','arch_timestamp');
end

