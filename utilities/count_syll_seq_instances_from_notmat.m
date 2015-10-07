prob_path=pwd;
in_message1='Please select a batch file';
in_message2='Please enter the strinf you want to look for';
[filename,filepath]=uigetfile([prob_path filesep '*.*'],in_message1);   % file input
tar_str=input([in_message2 '\n' list '\n-->  '],'s');

filelist=make_filelist_from_batch(filename,filepath);
no_files=length(filelist);

for i=1:nofiles
    notmat=[filepath filename '.not.mat'];
    load(notmat);
    
    
end