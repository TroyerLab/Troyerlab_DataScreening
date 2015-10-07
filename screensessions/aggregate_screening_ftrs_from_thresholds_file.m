function [screening_ftrs,classification_labels_present]=aggregate_screening_ftrs_from_thresholds_file(is_batch,fname,fpath,thresholds_file,thresholds_path)
%% Syntax
%
% [screening_ftrs,classification_labels_present]=aggregate_screening_ftrs(batchname,batchpath,selected_ftrs_file,selected_ftrs_path)
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
% This function assumes that scr_ftrs_dists.mat/scr_ftrs.mat files are located in the
% same directory as the batch file. 
%
% There is also an assumption that the way you obtain the
% scr_ftrs_dists.mat/scr_ftrs.mat file is by using fileparts() on the name given in the
% batch file and then concatenating _scr_ftrs.mat to it. 
%
% If the features being loaded are different across different files, one
% will get an error. 
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
narg_min=5;

prob_path=pwd;

in_message1=['Would you like load a batch file or a .mat file containing the\n'...
             'screening features or their distributions for all the relevant files.\n'...
             'Enter 1 for batch file and 0 for .mat screening file'];
in_message2='Please select the relevant file';
in_message3='Please select a thresholds file. If you don''t want to select one, click cancel';

if nargin<narg_min
    is_batch=input([in_message1 '\n-->  ']); 
    [fname,fpath]=uigetfile([prob_path filesep '*.*'],in_message2); 
     [thresholds_file,thresholds_path]=uigetfile([prob_path filesep '*.mat'],in_message3);
end


% putting file separators at the end of all input paths
if ~isempty(fpath)
    if ~strcmpi(fpath(end),filesep)
        fpath=[fpath,filesep];
    end
end

if ~isempty(thresholds_path)
    if ~strcmpi(thresholds_path(end),filesep)
        thresholds_path=[thresholds_path,filesep];
    end
end

%% Body of the function
if ~(thresholds_file==0)
     thresholds_fullfile=[thresholds_path thresholds_file];
     load(thresholds_fullfile) % loads threshold_criteria
     no_ftrs=length(threshold_criteria);
     
    % code to obtain features and prc
    features=cell(1,no_ftrs);
    prc=zeros(1,no_ftrs);

    for i=1:no_ftrs
        temp_ftr=threshold_criteria(i).ftr;
        dist_loc=strfind(temp_ftr,'_dist_');
        prc_loc=strfind(temp_ftr,'_prc_');
        features{1,i}=['ftr_dist_' temp_ftr(dist_loc+6:prc_loc-1)];
        prc(1,i)=str2double(temp_ftr(prc_loc+5:end));
    end   
    
    no_ftrs=length(features);
    new_ftr_names=cell(1,no_ftrs);
     for j=1:no_ftrs
        new_ftr_names{j}=[features{j} '_prc_' num2str(prc(j))];
     end
      data_ext='_screening_ftrs_dists.mat';
else
     data_ext='_screening_ftrs.mat';    
end


if is_batch==1
    filelist=make_filelist_from_batch(fname,fpath);
    no_files=length(filelist);
    temp_screening_ftrs=[];

       
    for i=1:no_files 
        [~,nm,~]=fileparts(filelist{i});
        screening_ftrs_file=[fpath nm data_ext];

        load(screening_ftrs_file); % loads variables called 'prc_vec' and 'screening_ftrs_dists' or 'screening_ftrs'

        if ~(thresholds_file==0)
            screening_ftrs=[];
            screening_ftrs.filename=screening_ftrs_dists.filename;
            screening_ftrs.classification_label=screening_ftrs_dists.classification_label;
            for j=1:no_ftrs
                prc_ind=find(prc_vec==prc(j));
                screening_ftrs.(new_ftr_names{j})=screening_ftrs_dists.(features{j})(prc_ind);           
            end
        end

        temp_screening_ftrs=[temp_screening_ftrs;screening_ftrs]; 
    end

   
    screening_ftrs=temp_screening_ftrs;

elseif is_batch==0
    load([fpath fname]) % loads variables called 'prc_vec' and 'screening_ftrs_dists' or 'screening_ftrs'
        
    if ~(thresholds_file==0)
            prc_inds=zeros(1,no_ftrs);
            for j=1:no_ftrs
               prc_inds(j)=find(prc_vec==prc(j)); 
            end
            [screening_ftrs(1:length(screening_ftrs_dists)).filename]=deal(screening_ftrs_dists.filename);
            [screening_ftrs(1:length(screening_ftrs_dists)).classification_label]=deal(screening_ftrs_dists.classification_label);
            for j=1:no_ftrs
                for k=1:length(screening_ftrs_dists)
                    screening_ftrs(k).(new_ftr_names{j})=screening_ftrs_dists(k).(features{j})(prc_inds(j));        
                end
            end
    end
    
    
else
    error('Incorrect value for is_batch')
end

% updating classification_labels_present
classification_labels_present=cell(0);

no_files=length(screening_ftrs);
for i=1:no_files
    if ~isempty(classification_labels_present)
        for j=1:length(classification_labels_present)
            match_found=0;
            if isequal(screening_ftrs(i).classification_label,classification_labels_present{j})
                match_found=1;    
                break
            end
        end
        if ~match_found
            classification_labels_present=[classification_labels_present,screening_ftrs(i).classification_label];
        end
    else
        classification_labels_present{1}=screening_ftrs(i).classification_label;
    end
end

dbclear if error






