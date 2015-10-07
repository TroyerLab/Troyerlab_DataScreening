function []=show_classifier_results(fname,fpath)
%% Syntax
%
% []=show_classifier_results(fname,fpath)
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

prob_path=pwd;

in_message1='Please select the classifier file';

if nargin<narg_min
     [fname,fpath]=uigetfile([prob_path filesep '*.mat'],in_message1);   % file input 
end


% putting file separators at the end of all input paths
if ~isempty(fpath)
    if ~strcmpi(fpath(end),filesep)
        fpath=[fpath,filesep];
    end
end

%% Body of the function
load([fpath fname]); % should load a variable called classifier
no_files=length(classifier);
classification_labels_present=cell(0);
classification_labels_count=zeros(0);

for i=1:no_files
    if ~isempty(classification_labels_present)
            for j=1:length(classification_labels_present)
                match_found=0;
                if isequal(classifier(i).classification_label,classification_labels_present{j})
                    match_found=1;    
                    break
                end
            end
            if ~match_found
                classification_labels_present=[classification_labels_present,classifier(i).classification_label];
                classification_labels_count(end+1)=1;
            else
                classification_labels_count(j)=classification_labels_count(j)+1;
            end
    else
            classification_labels_present{1}=classifier(i).classification_label;
             classification_labels_count(1)=1;
    end
end

results=['labels',classification_labels_present;'counts',num2cell(classification_labels_count)]




