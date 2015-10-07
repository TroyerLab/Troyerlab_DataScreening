function []=write_screening_info_aggregate_and_delete(batchname,batchpath,use_dists,delete_q)
%% Syntax
%
% []=write_screening_info_aggregate(batchname,batchpath,use_dists)
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

prob_path=pwd;

in_message1='Please select the batch file for which you want to aggregate screening info';
in_message2='Are the screening files screening_ftrs files (1) or screening_ftrs_dists files (0)? Enter 1 or 0';
in_message3='Do you want to delete the screening files after they have been aggregated? Enter 1 for deletion and 0 for non deletion';
if nargin<narg_min
     [batchname,batchpath]=uigetfile([prob_path filesep '*.*'],in_message1);   % file input 
     use_dists=input([in_message2 '\n-->  ']); % non string input
     delete_q=input([in_message3 '\n-->  ']);
end

% putting file separators at the end of all input paths
if ~isempty(batchpath)
    if ~strcmpi(batchpath(end),filesep)
        batchpath=[batchpath,filesep];
    end
end

%% Body of the function
if use_dists==0
   [screening_ftrs_dists,prc_vec,~]=aggregate_screening_ftrs_dists(1,batchname,batchpath);
   [outfile,outpath]=uiputfile([batchpath '*.mat'],'Please select the location and the name of the aggregate file','screening_ftrs_dists_agg*');
   save([outpath outfile],'screening_ftrs_dists','prc_vec')     
   data_ext='_screening_ftrs_dists.mat';     
elseif use_dists==1    
    [screening_ftrs,~]=aggregate_screening_ftrs(1,batchname,batchpath,0,0);    
    [outfile,outpath]=uiputfile([batchpath '*.mat'],'Please select the location and the name of the aggregate file','screening_ftrs_dists_agg*');
    save([outpath outfile],'screening_ftrs')
    data_ext='_screening_ftrs.mat';
else
    error('Incorrect value for the variable use_dists')    
end

if delete_q==1
    filelist=make_filelist_from_batch(batchname,batchpath);

    no_files=length(filelist);

    for i=1:no_files 
        [~,nm,~]=fileparts(filelist{i});
        screening_file=[batchpath nm data_ext];   
        delete(screening_file)
    end  
end
    
   
   
   







