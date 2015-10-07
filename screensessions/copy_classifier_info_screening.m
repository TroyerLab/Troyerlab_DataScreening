function []=copy_classifier_info_screening(classfier_file,classifier_path,is_consolidated,use_dists,varargin)
%% Syntax
%
% []=copy_classifier_info_func(classfier_file,classifier_path,ftrs_dists_file,ftrs_dists_path,varargin)
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
% Its is assumed that the screening_ftrs_dists files are stored at the same
% location as the classifier file. 
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
in_message3='Is the screening info for the audio files stored in a single consolidated .mat file (1) or distributed in indivudual files(0)?\n Enter 1 or 0';
in_message2='Do you have screening_ftrs_dists files or screening_ftrs?\n Enter 1 for screening_ftrs_dists and 0 for screening_ftrs files';
in_message4='Please select the .mat file storing the consolidated screening info';
if nargin<narg_min
    [classfier_file,classifier_path]=uigetfile([prob_path filesep '*.mat'],in_message1);  
    is_consolidated=input([in_message3 '\n-->  ']);
    if is_consolidated==1
        [consol_file,consol_path]=uigetfile([prob_path filesep '*.mat'],in_message4); 
    else
        consol_path=[];
        consol_file=[];
    end
    use_dists=input([in_message2 '\n-->  ']);    
end

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir=classifier_path;


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
if ~isempty(classifier_path)
    if ~strcmpi(classifier_path(end),filesep)
        classifier_path=[classifier_path,filesep];
    end
end

if ~isempty(consol_path)
    if ~strcmpi(consol_path(end),filesep)
        consol_path=[consol_path,filesep];
    end
end


if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end




%% Body of the function
load([classifier_path classfier_file]) % loads a var called classifier
no_files_classifier=length(classifier);
if is_consolidated
   load([consol_path consol_file]) % loads variables called 'prc_vec' and 'screening_ftrs_dists' or 'screening_ftrs'
   if use_dists
     no_consol_files=length(screening_ftrs_dists);
   else
       no_consol_files=length(screening_ftrs);
   end
end

for i=1:no_files_classifier
    [~,classif_name,~]=fileparts(classifier(i).filename);
    
    if ~is_consolidated
        
        if use_dists
           ftr_file_name=[classifier_path classif_name '_screening_ftrs_dists.mat']; 
        else
            ftr_file_name=[classifier_path classif_name '_screening_ftrs.mat']; 
        end

        if ~exist(ftr_file_name,'file')
            error(['File ' classif_name ' does not have a corresponding features file.'])    
        end

        load(ftr_file_name); % loads variables called screening_ftrs_dists and prc_vec
        
        if use_dists
           screening_ftrs_dists.classification_label=classifier(i).classification_label; 
           if supp_inputs.write_to_disk_q==1       
                save(ftr_file_name,'screening_ftrs_dists','prc_vec');    
            end
        else
            screening_ftrs.classification_label=classifier(i).classification_label; 
            if supp_inputs.write_to_disk_q==1       
                save(ftr_file_name,'screening_ftrs');    
            end
        end       
        
    else
        match_found=0;
        for j=1:no_consol_files
            if use_dists
                [~,consol_filename,~]=fileparts(screening_ftrs_dists(j).filename);                   
            else
                [~,consol_filename,~]=screening_ftrs(j).filename;              
            end   
            if strcmpi(consol_filename,classif_name)
                consol_label=classifier(i).classification_label;
                match_found=1;
                break
            end
        end
        if match_found
            if use_dists
                screening_ftrs_dists(j).classification_label=consol_label;                   
            else
                screening_ftrs(j).classification_label=consol_label;              
            end   
        else
           error(['File ' classifier(i).filename ' does not have a corresponding entry in consolidated screening file.'])    
        end
    end

end

if is_consolidated
   % loads variables called 'prc_vec' and 'screening_ftrs_dists' or 'screening_ftrs'
   if use_dists
    save([consol_path consol_file],'screening_ftrs_dists','prc_vec') 
   else
       save([consol_path consol_file],'screening_ftrs') 
   end
end




