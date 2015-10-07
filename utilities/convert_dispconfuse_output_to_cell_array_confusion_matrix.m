% converts dispconfuse answer to cell array confusion matrix.
% ans is the output of dispconfuse
% hh=ans;
gg=cell(length(hh.rowlabelkey)+3,length(hh.collabelkey)+3);
gg(2:end-2,1)=(mat2cell(hh.rowlabelkey,1,[ones(1,length(hh.rowlabelkey))]))';
gg(1,2:end-2)=(mat2cell(hh.collabelkey,1,[ones(1,length(hh.collabelkey))]))';
gg(2:end-2,2:end-2)=num2cell(hh.m);

row_accuracy=cell(length(hh.rowlabelkey),1);
row_instances=cell(length(hh.rowlabelkey),1);


for i=1:length(hh.rowlabelkey)
   row_syll=hh.rowlabelkey(i);
   row_sum=sum(hh.m(i,:));
   tru_class_freq=0;
   for j=1:length(hh.collabelkey)
       col_syll=hh.collabelkey(j);
       if strcmpi(row_syll,col_syll)
           tru_class_freq=hh.m(i,j);
           break
       end       
   end
   row_accuracy{i,1}=tru_class_freq/row_sum;  
   row_instances{i,1}=row_sum;  
end

gg(2:end-2,end-1)=row_accuracy;
gg(2:end-2,end)=row_instances;

col_accuracy=cell(1,length(hh.collabelkey));
col_instances=cell(1,length(hh.collabelkey));

for i=1:length(hh.collabelkey)
   col_syll=hh.collabelkey(i);
   col_sum=sum(hh.m(:,i));
   tru_class_freq=0;
   for j=1:length(hh.rowlabelkey)
       row_syll=hh.rowlabelkey(j);
       if strcmpi(col_syll,row_syll)
           tru_class_freq=hh.m(j,i);
           break
       end       
   end
   col_accuracy{1,i}=tru_class_freq/col_sum;  
   col_instances{1,i}=col_sum;  
end

gg(end-1,2:end-2)=col_accuracy;
gg(end,2:end-2)=col_instances;







