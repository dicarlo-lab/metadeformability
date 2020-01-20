function writeWithHeader(fname,header,data)
% Write data with headers
%
% fname: filename
% header: cell of row titles
% data: matrix of data

f = fopen(fname,'w');

%Write the header:
fprintf(f,'%-10s\t',header{1:end-1});
fprintf(f,'%-10s\n',header{end});

%Write the data:
for m = 1:size(data,1)
    fprintf(f,'%-10.4f\t',data(m,1:end-1));
    fprintf(f,'%-10.4f\n',data(m,end));
end

fclose(f);
