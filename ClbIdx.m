function idxS = ClbIdx(fmt_str)
%convert 'ImageIndex.ColumbusIDX.csv' into matlab
%structure
fname = fopen(fmt_str);
header = textscan(fname,repmat('%s ', 1, 43), 1, 'delimiter','\t');
data = textscan(fname,['%s %d %d %s %s ', repmat('%s ', 1, 23), ...
    repmat('%s ', 1, 3), repmat('%d ', 1, 4), '%s %d %d %s %d %s %d %s'],'delimiter','\t');
fclose(fname);

%%
outCell = cell(size(data{1},1), length(header));
for i = 1:length(header)
    if isnumeric(data{i})
        outCell(:,i) = num2cell(data{i});
    else
        outCell(:,i) = data{i};
    end
end

for i = 1 : length(header)
    temp = strrep(header{i}, '@', '_');
    header{i} = temp;
end
idxS = cell2struct(outCell, [header{:}], 2);
