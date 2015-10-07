% This is a general script for moving data. Its inputs are the src dir, the
% target dir and the wild card of the files within the src dir to be moved.
% it will also take supplementary extensions. For example if you want to
% move c
ui=0;
put_dir='';
src_dir=cell(0);
tar_dir=cell(0);
wild_card=cell(0);
if ui
    while true
        src_dir=[src_dir,uigetdir('','Please select the source directory')];
        tar_dir=[tar_dir,uigetdir('','Please select the target directory')];
        wild_card=[wild_card,input('Please enter the wild card for the files that you want to move. For files recorded on 18th August 2014 in EvTAF, type ''*_180814_*''  ','s')]; % wild card of the files that need to be moved
        go_more=input('Enter 1 if you want to enter information for another transfer. Else enter zero');
        if ~go_more
            break
        end   
    end
else
   
 %%
   src_dir{1}='F:\5026';
   tar_dir{1}='F:\5026\5026_2014_09_23';
   wild_card{1}='*September_23*';
   %%
   src_dir{2}='F:\5026';
   tar_dir{2}='F:\5026\5026_2014_09_24';
   wild_card{2}='*September_24*';
   %%
   src_dir{3}='F:\5026';
   tar_dir{3}='F:\5026\5026_2014_09_25';
   wild_card{3}='*September_25*';

end

no_tranfers=length(wild_card);

for i=1:no_tranfers
    tic
    disp([num2str(i) ' out of ' num2str(no_tranfers)]);
    src_dir{i}
    tar_dir{i}
    
    if ~exist(tar_dir{i},'dir')
        mkdir(tar_dir{i})
    end
    
    wild_files=dir([src_dir{i} filesep wild_card{i}]);
    no_wild_files=length(wild_files);
    
    if no_wild_files==0
       warndlg(['No files found satisfying the wild card ' wild_card ' in the source directory ' src_dir ' Skipping that transfer'],'No Files Found','modal')
       continue
    end

    for k=1:no_wild_files
       filename=wild_files(k).name;
       movefile([src_dir{i} filesep filename],[tar_dir{i} filesep filename])   
    end
    toc
end