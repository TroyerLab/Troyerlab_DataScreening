function []=write_batch_based_on_classifier_old(classifier_filename,classifier_filepath,numbers_include,numbers_exclude,varargin)
%% Syntax
%
% []=write_batch_based_on_classifier(classifier_filename,classifier_filepath,varargin)
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

in_message2='Please select the classifier file';
in_message3='Please enter the markers (numbers)for the files to be included. e.g [0,2]';
in_message4='Please enter the markers (numbers)for the files to be excluded. e.g [1]';
if nargin<narg_min
     [classifier_filename,classifier_filepath]=uigetfile([prob_path filesep '*.mat'],in_message2); 
     numbers_include=input([in_message3 '\n-->  ']); 
     numbers_exclude=input([in_message4 '\n-->  ']); 
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
inputs=struct('classifier_filename',classifier_filename,'classifier_filepath',...
             classifier_filepath,'numbers_include',numbers_include,'number_exclude',numbers_exclude);

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir=classifier_filepath;


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

if ~isempty(classifier_filepath)
    if ~strcmpi(classifier_filepath(end),filesep)
        classifier_filepath=[classifier_filepath,filesep];
    end
end

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end


%% Body of the function
load([classifier_filepath,classifier_filename]) % loads a variable called classifier
no_files=length(classifier);

comm=intersect(numbers_include,numbers_exclude);
if ~isempty(comm) 
    error('Please check the include and exclude markers. They have certain values in common');
end

filelist=cell(0);


for i=1:no_files
    mark=classifier(i).is_marked;    
    if ~isempty(find(mark==numbers_include,1)) 
        [~,name,ext]=fileparts(classifier(i).fname);
        filelist=[filelist;[name ext]];
    elseif isempty(find(mark==numbers_exclude,1))
        error(['The mark for the file ' classifier.fname ' is listed neither in the included or the excluded list.'])
    end   
end

if isempty(filelist)
    error('Not a single file was included. Please check the inputs.')
end


%% Processing outputs 
arch_timestamp=datestr(now,'yyyy-mmm-dd HH:MM:SS');
arch_inputs=inputs;
arch_supp_inputs=supp_inputs;

if supp_inputs.write_to_disk_q==1
    [~,name_template,~]=fileparts(classifier_filename);
    sub_batchname=uiputfile([supp_inputs.disk_write_dir '*.*'],'What name do you want to give to this batch file?',[name_template '_*']);
    spawning_func=mfilename('fullpath');
    write_batch_from_filelist(filelist,sub_batchname,supp_inputs.disk_write_dir,...
        'batch_inputs',arch_inputs,'batch_supp_inputs',arch_supp_inputs,...
        'spawning_func',spawning_func,'batch_timestamp',arch_timestamp);
end

