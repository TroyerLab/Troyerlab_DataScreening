function [out_filename]=extract_audio_filename(in_filename,varargin)
%% Syntax
%
% [out_filename]=extract_audio_filename(in_filename,varargin)
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
narg_min=1;

if nargin<narg_min
     error(['The number of inputs should at least be ' narg_min])
end

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.audiofile_exts={'.cbin','.wav'};
supp_inputs.write_to_disk_q=0; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir='';


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

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end

%% Body of the function
while true
   [~,name,ext]=fileparts(in_filename);
   if any(strcmpi(ext,supp_inputs.audiofile_exts))
       out_filename=[name ext];
       break
   elseif isempty(ext)
       error('Audio file name cannot be extracted from the input file name')
   end    
end
