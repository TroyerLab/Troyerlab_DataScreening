function [screening_ftrs_dists,prc_vec,classification_labels_present]=aggregate_screening_ftrs_dists(is_batch,fname,fpath)
%% Syntax
%
%  [screening_ftrs_dists,prc_vec,classification_labels_present]=aggregate_screening_ftrs_dists(is_batch,fname,fpath)
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
% This function assumes that scr_ftrs_dists.mat files are located in the
% same directory as the batch file. 
%
% There is also an assumption that the way you obtain the
% scr_ftrs_dists.mat file is by using fileparts() on the name given in the
% batch file and then concatenating _scr_ftrs_dists.mat to it. 
%
% The fucntion will throw an error if the prc_vec, the vector sepcifying the
% percentiles of the feature distributions, for any two files within the
% batch file are different. 
%
% The function will also throw an error if the set of features contained in any
% two screening_ftrs_dists.mat files are different. 
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
nargin_min=3;

prob_path=pwd;

in_message1=['Would you like load a batch file or a .mat file containing the'...
             'screening features distributions for all the relevant files.\n'...
             'Enter 1 for batch file and 0 for .mat screening file'];
in_message2='Please select the file';

if nargin<nargin_min 
     is_batch=input([in_message1 '\n-->  ']); 
    [fname,fpath]=uigetfile([prob_path filesep '*.*'],in_message2); 
end


% putting file separators at the end of all input paths
if ~isempty(fpath)
    if ~strcmpi(fpath(end),filesep)
        fpath=[fpath,filesep];
    end
end

%% Body of the function

if is_batch==1
    
    filelist=make_filelist_from_batch(fname,fpath);
    no_files=length(filelist);
    temp_screening_ftrs_dists=[];
    
    for i=1:no_files
        [~,nm,~]=fileparts(filelist{i});
        screening_ftrs_file=[fpath nm '_screening_ftrs_dists.mat'];
        load(screening_ftrs_file); % loads variables called 'prc_vec' and 'screening_ftrs_dists'
        if i>1
            if temp_prc_vec~=prc_vec 
               error('The prc_vec in two files within the batch are different') 
            end
        end
        temp_prc_vec=prc_vec;

        temp_screening_ftrs_dists=[temp_screening_ftrs_dists;screening_ftrs_dists];    
    end

    screening_ftrs_dists=temp_screening_ftrs_dists;
    
elseif is_batch==0
    load([fpath fname]);
    if ~exist('screening_ftrs_dists','var')|| ~exist('prc_vec','var')
        error('The screening ftrs dists file does not contain the necessary variables')
    end

else
    error('Incorrect input value for is_batch')    
end

% updating classification_labels_present

classification_labels_present=cell(0);

no_files=length(screening_ftrs_dists);

for i=1:no_files
    if ~isempty(classification_labels_present)
        for j=1:length(classification_labels_present)
            match_found=0;
            if isequal(screening_ftrs_dists(i).classification_label,classification_labels_present{j})
                match_found=1;    
                break
            end
        end
        if ~match_found
            classification_labels_present=[classification_labels_present,screening_ftrs_dists(i).classification_label];
        end
    else
        classification_labels_present{1}=screening_ftrs_dists(i).classification_label;
    end
end

dbclear if error






