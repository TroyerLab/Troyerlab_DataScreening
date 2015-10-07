function []=plot_size_and_file_no_details_for_subdirs(path,varargin)
%% Syntax
%
% []=plot_size_and_file_no_details_for_subdirs(path,varargin)
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
%  it plots sub-directories on the X axis and the following things on the Y
%  axis. 1. size of each subdirectory. 2. no files in each subdir 3. no. of 
% directories in the subdir
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
supp_inputs.size_fac=1024*1024*1024; % gives you size in GB
supp_inputs.size_unit='Gb';
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

% creating a figure and axes
main_fig=figure;
size_axes=subplot(3,1,1,'parent',main_fig);
no_files_axes=subplot(3,1,2,'parent',main_fig);
no_dirs_axes=subplot(3,1,3,'parent',main_fig);


%% Body of the function
subdir_size_details=folderSizeTree(path);
no_subdirs=length(subdir_size_details.size);
subdir_sizes=zeros(0);
subdir_no=1;
subdir_names_cell=cell(0);

for i=1:no_subdirs
   if subdir_size_details.level{i}==1
       [~,subdir_names_cell{subdir_no},~]=fileparts(subdir_size_details.name{i});
       subdir_sizes(subdir_no)=subdir_size_details.size{i}/supp_inputs.size_fac;
       subdir_no=subdir_no+1;
   end       
end

bar(size_axes,subdir_sizes)
set(size_axes,'xticklabel',subdir_names_cell)
ylabel(size_axes,['Size in ' supp_inputs.size_unit])

subdirs=get_no_things_in_subdirs(path);
no_subdirs=length(subdirs);
subdir_names_cell=cell(1,no_subdirs);
subdir_no_files=zeros(1,no_subdirs);
subdir_no_dirs=zeros(1,no_subdirs);

for i=1:no_subdirs
   subdir_names_cell{i}=subdirs(i).name; 
   subdir_no_files(i)=subdirs(i).no_files;
   subdir_no_dirs(i)=subdirs(i).no_dirs;
end

bar(no_files_axes,subdir_no_files)
set(no_files_axes,'xticklabel',subdir_names_cell)
ylabel(no_files_axes,'No. of files')


bar(no_dirs_axes,subdir_no_dirs)
set(no_dirs_axes,'xticklabel',subdir_names_cell)
xlabel(no_dirs_axes,'Directories');
ylabel(no_dirs_axes,'No. of subdirectories')
