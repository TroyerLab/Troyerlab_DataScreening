function []=transfer_files_in_batch(batchfile,batchpath,src,dest,exts,transfer_type,varargin)
%% Syntax
%
% []=transfer_files_in_batch(batchfile,batchpath,src,dest,exts,transfer_type,varargin)
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
narg_min=6;

prob_path=pwd;

in_message1='Please select the batch file';
in_message2='Please select the source directory';
in_message3='Please select the destination directory';
in_message4=['Please select other file extensions that you want to transfer.\n'...
             'Specify them as a cell array. e.g. {''.rec'',''.wav.not.mat''}. Hit enter if you dont want to use other file extensions'];
in_message5='Please enter the type of transfer you want. ''copy'' or ''move''';
if nargin<narg_min
     [batchfile,batchpath]=uigetfile([prob_path filesep '*.*'],in_message1);   
     src=uigetdir(prob_path,in_message2); 
     dest=uigetdir(prob_path,in_message3); 
     exts=input([in_message4 '\n-->  ']); 
     transfer_type=input([in_message5 '\n-->  '],'s');     
end


% putting file separators at the end of all input paths
if ~isempty(batchpath)
    if ~strcmpi(batchpath(end),filesep)
        batchpath=[batchpath,filesep];
    end
end
if ~isempty(src)
    if ~strcmpi(src(end),filesep)
        src=[src,filesep];
    end
end

if ~isempty(dest)
    if ~strcmpi(dest(end),filesep)
        dest=[dest,filesep];
    end
end


%% Body of the function
switch transfer_type
    case 'copy'
        transfer_func=@copyfile;
    case 'move'
        transfer_func=@movefile;
    otherwise
        error('The transfer type is invalid')
end
filelist=make_filelist_from_batch(batchfile,batchpath);
no_files=length(filelist);

for i=1:no_files
   transfer_func([src filelist{i}],[dest filelist{i}]);
   for j=1:length(exts)
      [~,name,~]=fileparts(filelist{i});
      transfer_func([src name exts{j}],[dest name exts{j}]) 
   end    
end
