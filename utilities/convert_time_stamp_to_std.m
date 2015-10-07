function [std_time]=convert_time_stamp_to_std(filename,software)
%% Syntax
%
% [std_time]=convert_time_stamp_to_std(filename,software)
%
%% Inputs  
%
% filename -  Name of the file from which the time stamp needs to be
% extracted
% 
% software - name of the software in which the recording was made
%
%
%% Computation/Processing     
% 
% It isolates the time stamp from the filename with the help of the
% software variable and converts it into a standard format, which it
% returns. 
%
% 
%
%% Outputs  
% 
% std_time - standard time as a real number between 0 and 24. 0 included in
% the interval and 24 excluded from the interval. [0,24)
%
%
%% Assumptions
% It will work only on files with usual extensions like .cbin and .wav. It
% will not work on filenames ending in .not.mat. 
%
%
%
% % % Triple percentage sign indicates that the code is part of the code
% template and may be activated if necessary in later versions. 
%% Version and Author Identity Notes  
% 
% Last modified by Anand S. Kulkarni
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

%% Body of the function
switch software
    case 'sap'
        [~,filename,~]=fileparts(filename);
        underscores=strfind(filename,'_');
        time_stamp=str2num(filename(underscores(end)+1:end));
        std_time=time_stamp/1000/60/60;
    case 'evtaf'
        [~,filename,~]=fileparts(filename); % should be cbin
        [~,filename,~]=fileparts(filename);
        hour=str2num(filename(end-3:end-2));
        minute=str2num(filename(end-1:end));
        minute=minute/60;
        std_time=hour+minute;        
    otherwise
        error('The software argument supplied does not match any in my list')
end