function [subdirs]=get_no_things_in_subdirs(path,varargin)
%% Syntax
%
% [subdirs]=get_no_things_in_subdirs(path,varargin)
%
%% Inputs  
%
% path - the direcotry for which you want the details
%
%
%% Computation/Processing     
% 
% digs into the selected directory and gives you infiormation about the
% subdirectories
%
% 
%
%% Outputs  
% 
% subdirs.name -  name of the subdirectory
% 
% subdirs.things - structure array of things in the directory. fields the
% same as the ones you get with the dir function
% 
% subdirs.no_dirs -  number of directories in the subdirectory
%
% subdirs.no_files -  number of files in the subdirectory
%                     
% subdirs.dir_indices -  logical array indicating which of the things are
% directories 
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
% Last modified by Anand Kulkarni
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

prob_path=pwd;

in_message2='Please select the directory for which you want the details';
if nargin<narg_min
     path=uigetdir(prob_path,in_message2);      
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
inputs=struct('path',path);

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=0; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir='';


supp_inputs=parse_pv_pairs(supp_inputs,varargin);

% Checking if output directories need to specified and if they have been specified 

if supp_inputs.write_to_disk_q
    if ~exist(supp_inputs.disk_write_dir,'dir')
        supp_inputs.disk_write_dir=uigetdir('Please select the directory where to store the output mat file. Hit cancel if you don''t want the function to write a mat file');
        if supp_inputs.disk_write_dir==0
            supp_inputs.write_to_disk_q=0;
        end
    end
end

% putting file separators at the end of all input paths
if ~isempty(path)
    if ~strcmpi(path(end),filesep)
        path=[path,filesep];
    end
end



%% Body of the function
subdirs=struct;
elements=dir(path);
no_elements=length(elements);
curr_subdir_no=1;

for i=1:no_elements
   if elements(i).isdir && ~any(strcmpi(elements(i).name,{'.','..'}))
      subdirs(curr_subdir_no).name=elements(i).name; 
      sub_elements=dir([path subdirs(curr_subdir_no).name]);
      no_sub_elements=length(sub_elements);
      current_thing_no=1;
      no_dirs=0;
      no_files=0;
      for j=1:no_sub_elements
          if ~any(strcmpi(sub_elements(j).name,{'.','..'}))
              if sub_elements(j).isdir
                 no_dirs=no_dirs+1; 
              else
                  no_files=no_files+1;
              end
            subdirs(curr_subdir_no).things(current_thing_no)=sub_elements(j);
            current_thing_no=current_thing_no+1;
          end
      end
      subdirs(curr_subdir_no).no_dirs=no_dirs;
      subdirs(curr_subdir_no).no_files=no_files;
      if isfield(subdirs,'things')
        subdirs(curr_subdir_no).dir_indices=[subdirs(curr_subdir_no).things(:).isdir];
      else
        subdirs(curr_subdir_no).dir_indices=[];
      end
      curr_subdir_no=curr_subdir_no+1;
   end    
   
end