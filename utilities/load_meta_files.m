% this script will load a meta data file like a rec file or a tmp or notmat file.
% right now it can do ony these file types.
% there is an assumption that batchpath and file path are the same ie the batch file and the actual
% files are located in the same place. what is needed is a batch file. the
% files listed in the batch file can have extensions other than the
% extension of the metadata file you want to open

clear all
close all
prob_path=pwd;
[batchfile,batchpath]=uigetfile([prob_path filesep 'batch*'],'Please select a batch file');
meta_ext=input('Please enter the extension of the meta data file that you want to load. For example .rec for rec files\n','s');
meta_data=[];
flag=1;
fid=fopen([batchpath batchfile],'r');

filename=fgetl(fid);

while ischar(filename)
        
        switch meta_ext
            
            case '.rec'
                 [~,name,~]=fileparts(filename);
                 meta_filename=[batchpath name meta_ext];
                try 
                    rdat=readrecf(meta_filename);
                catch e
                    filename
                    e.message
                    filename=fgetl(fid);
                    continue
                end
                if flag
                    meta_data=rdat;
                    flag=0;
                else                    
                    meta_data=[meta_data;rdat];      
                end
            case '.tmp'
                [~,name,~]=fileparts(filename);
                meta_filename=[batchpath name meta_ext];
                tmp=load(meta_filename);
                 if flag
                     meta_data=cell(0);
                    meta_data{1}=tmp;
                    flag=0;
                 else  
                    meta_data=[meta_data;tmp];   
                 end
            case '.not.mat'
                
                meta_filename=[batchpath filename meta_ext];
                notmat=load(meta_filename);
                meta_data=[meta_data;notmat];                               
            otherwise
                error('The program is not set up to read files of this extension')            
        end        

    
    filename=fgetl(fid);
end

fclose(fid);

% optional code for determining the percentage of catch songs and catch
% trials. can be un-commented when needed
if strcmpi(meta_ext,'.rec')
    catch_songs=[meta_data(:).iscatch];
    tt=['Catch songs ' num2str(sum(catch_songs)) ' / ' num2str(length(catch_songs))];
    disp(tt)
    non_catch_songs=~catch_songs;
    catch_trials=vertcat(meta_data(non_catch_songs).catch);
    tt=['Catch trials ' num2str(sum(catch_trials)) ' / ' num2str(length(catch_trials))];
    disp(tt)
    no_trigs=0;
    for i=1:length(meta_data)
        no_trigs=no_trigs+size(meta_data(i).ttimes,1);
    end

    tt=['No of trigs ' num2str(no_trigs)];
    disp(tt)
end

% optional code for determining the no instances of a given sequence
if strcmpi(meta_ext,'.not.mat')
    seq='g';
    no_files=length(meta_data);
    no_instances=0;
    for i=1:no_files
        labels=meta_data(i).labels;
        inds=strfind(labels,seq);
        no_instances=no_instances+length(inds);       
        
    end   
    yy=['No of instances of ' seq ' are ' num2str(no_instances)];
    disp(yy)
    
end


