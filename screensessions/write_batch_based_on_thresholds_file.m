function []=write_batch_based_on_thresholds_file(is_batch,fname,fpath,thresholds_filename,thresholds_filepath,write_complementary_batch,use_ftrs_dists,varargin)
%% Syntax
%
% [outputs]=function_template(inp1,inp2,inp3,inp4,varargin)
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
narg_min=7;

in_message1=['Would you like load a batch file or a .mat file containing the\n'...
             'screening features or their distributions for all the relevant files.\n'...
             'Enter 1 for batch file and 0 for .mat screening file'];
in_message2='Please select the relevant file';
in_message3='Please select the thresholds file';
in_message4='Do you want to write a batch for files that do not satisfy these thresholds? 1 or 0';
in_message5='Do you want to use features dists file to retrieve feature information? 1 or 0';
prob_path=pwd;
if nargin<narg_min   
    is_batch=input([in_message1 '\n-->  ']); 
    [fname,fpath]=uigetfile([prob_path filesep '*.*'],in_message2);      
    [thresholds_filename,thresholds_filepath]=uigetfile([prob_path filesep '*.mat'],in_message3); 
    write_complementary_batch=input([in_message4 '\n-->  ']);
    use_ftrs_dists=input([in_message5 '\n-->  ']);
end

% packaging the inputs into the inputs structure. This can be useful in
% case you need to store the inputs as meta-data with the output. 
inputs=struct('is_batch',is_batch,'fname',fname,'fpath',fpath,'thresholds_filename',thresholds_filename,...
              'thresholds_filepath',thresholds_filepath,'write_complementary_batch',write_complementary_batch,'use_ftrs_dists',use_ftrs_dists);

% processing supplementary inputs

% Assigning default values to supplementary inputs
supp_inputs.write_to_disk_q=1; % should the function write a file to disk containing its output  
supp_inputs.disk_write_dir=fpath;


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
if ~isempty(thresholds_filepath)
    if ~strcmpi(thresholds_filepath(end),filesep)
        thresholds_filepath=[thresholds_filepath,filesep];
    end
end

if supp_inputs.write_to_disk_q
    if ~strcmpi(supp_inputs.disk_write_dir(end),filesep)
        supp_inputs.disk_write_dir=[supp_inputs.disk_write_dir,filesep];
    end
end

%% Body of the function
if use_ftrs_dists
    [screening_ftrs,~]=aggregate_screening_ftrs_from_thresholds_file(is_batch,fname,fpath,thresholds_filename,thresholds_filepath);
else
    [screening_ftrs,~]=aggregate_screening_ftrs_from_thresholds_file(is_batch,fname,fpath,'','');
end


% listing all the features for which dists are avl for the files
names=fieldnames(screening_ftrs(1));
ftrs=cell(0);
test_str='ftr_';
for i=1:length(names)    
   if strcmpi(names{i}(1:length(test_str)),test_str)
       ftrs=[ftrs;names{i}];
   end
end

%listing all the ftrs from the thresholds file and checking if they are
load([thresholds_filepath thresholds_filename])
%in ftrs as well
no_criteria=length(threshold_criteria);
thr_ftrs=cell(no_criteria,1);
for i=1:no_criteria
    thr_ftrs{i}=threshold_criteria(i).ftr;
    if ~ismember(thr_ftrs{i},ftrs)
        error('One of the threshold features is not present in the screening features')
    end
end




% obtaining the complete and perfect screening_ftrs
% if strcmpi(files_insync,'n')
%     fid=fopen([batchpath batchname]);
%     file=fgetl(fid);
%     first_file_done=0;
%     file_no=0;
%     while ischar(file)
%         file_no=file_no+1;
%         for i=1:length(screening_ftrs)
%             if strcmpi(screening_ftrs(i).filename,file)
%                 if ~first_file_done
%                     temp_screening_ftrs=screening_ftrs(i);
%                     first_file_done=1;
%                     break
%                 else                   
%                     temp_screening_ftrs=[temp_screening_ftrs,screening_ftrs(i)]; 
%                     break
%                 end
%             end
%         end
%         file=fgetl(fid);
%     end
%     fclose(fid);
%     if length(temp_screening_ftrs)~=file_no
%         response=questdlg(['Information for some files in the batch file could not '...
%             'be found in the mat file. What should the program do?'],'','Continue','Abort','Abort');
%         if strcmpi(response,'Abort')
%             error(['Program stopped.Information for some files in the batch file could not '...
%             'be found in the mat file.'])
%         end    
%     end  
%     screening_ftrs=temp_screening_ftrs; 
% elseif ~strcmpi(files_insync,'y')
%     error('Incorrect input for the variable files_insync')
% end

% checking the numberf of files that satisfy the criteria

no_files=length(screening_ftrs);
no_files_selected=0;
no_files_rejected=0;
file_selected_list=cell(no_files_selected);
file_rejected_list=cell(no_files_selected);
no_criteria=length(threshold_criteria);

for i=1:no_files
    [threshold_satisfied]=determine_if_file_satisfies_threshold(screening_ftrs(i),threshold_criteria);
    if threshold_satisfied
        no_files_selected=no_files_selected+1;
        file_selected_list{no_files_selected}=screening_ftrs(i).filename;
    else
        no_files_rejected=no_files_rejected+1;
        file_rejected_list{no_files_rejected}=screening_ftrs(i).filename;
    end
end

quest_msg=[num2str(no_files_selected) ' files have been selected out of ' num2str(no_files) ' based on the threshold criteria you entered. What do you want to do?'];
quest_dialog_title='';
quest_option1='Write batch files using these files';
quest_option2='Quit';
quest_default_option=quest_option1;

quest_resp=questdlg(quest_msg,quest_dialog_title,quest_option1,quest_option2,quest_default_option);
if strcmpi(quest_resp,quest_option2)
   warning('Terminating the function as per user input')
   return         
end

% picking a random sample of files from those selected
selected_batch_fraction=input(['Please enter the fraction of the ' num2str(no_files_selected) ...
               ' selected files you want to write into the batch file? Enter no less than or equal to 1 \n -->  ']);
selected_no=floor(selected_batch_fraction*no_files_selected);
selected_filelist=cell(selected_no,1);
selected_files_indices=randperm(no_files_selected,selected_no);

for i=1:selected_no
    selected_filelist{i,1}=file_selected_list{1,selected_files_indices(i)};    
end

if write_complementary_batch
    % picking a random sample of files from those rejected
    rejected_batch_fraction=input(['Please enter the fraction of the ' num2str(no_files_rejected) ...
                   ' rejected files you want to write into the batch file? Enter no less than or equal to 1 \n -->  ']);
    rejected_no=floor(rejected_batch_fraction*no_files_rejected);
    rejected_filelist=cell(rejected_no,1);
    rejected_files_indices=randperm(no_files_rejected,rejected_no);

    for i=1:rejected_no
        rejected_filelist{i,1}=file_rejected_list{1,rejected_files_indices(i)};    
    end
end


%% Processing outputs 
arch_timestamp=datestr(now,'yyyy-mmm-dd HH:MM:SS');
inputs.('threshold_criteria')=threshold_criteria;
inputs.('hand_screen_fraction')=selected_batch_fraction;
arch_inputs=inputs;
arch_supp_inputs=supp_inputs;

if supp_inputs.write_to_disk_q==1
    % writing the selected files batch file
    selected_batchname=uiputfile([supp_inputs.disk_write_dir '*.*'],'What name do you want to give to the selected files batch file?',[fname '_*']);
    spawning_func=mfilename('fullpath');
    write_batch_from_filelist(selected_filelist,selected_batchname,supp_inputs.disk_write_dir,...
                                                                    'batch_inputs',arch_inputs,...
                                                                    'batch_supp_inputs',arch_supp_inputs,...
                                                                    'spawning_func',spawning_func,...
                                                                    'batch_timestamp',arch_timestamp);
    
    if write_complementary_batch
        % writing the rejected files batch file
        rejected_batchname=uiputfile([supp_inputs.disk_write_dir '*.*'],'What name do you want to give to the rejected files batch file?',[fname '_*']);
        spawning_func=mfilename('fullpath');
        write_batch_from_filelist(rejected_filelist,rejected_batchname,supp_inputs.disk_write_dir,...
                                                                    'batch_inputs',arch_inputs,...
                                                                    'batch_supp_inputs',arch_supp_inputs,...
                                                                    'spawning_func',spawning_func,...
                                                                    'batch_timestamp',arch_timestamp);
    end
end



