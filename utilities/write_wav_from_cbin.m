[filename,pathname]=uigetfile('*.*','Please select the batch file');
filelist=make_filelist_from_batch(filename,pathname);
no_files=length(filelist);

for i=1:no_files
   curr_file=filelist{i};
   [data,fs,DOFILT,~] = ReadDataFile([pathname curr_file],'0',0);
   fs=44150.110375;
   [~,nm,~]=fileparts(curr_file);
   wavfilename=[pathname nm '.wav'];
   wavwrite(int16(data),fs,16,wavfilename)   
end
