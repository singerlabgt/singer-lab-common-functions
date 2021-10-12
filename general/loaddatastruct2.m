function out = loaddatastruct2(animaldir, sessindex, datatype, files)
% out = loaddatastruct2(animaldir, sessindex, datatype, )
% out = loaddatastruct2(animaldir, sessindex, datatype, files)
%
% Load the components of a data cell array and combines them into one
% variable.  Data cell array is Datatype{sessindex(1)}{sessindex(2)}{file}.
% Datatype is a string with the base name of the files.  If
% files is omitted, all files are loaded.  Otherwise, only the specified files will be included.
% can be used for wholecell data if input file#s for days and animalprefix
% is ''

if (nargin < 4)
    files = [];
end
out = [];
datafiles = dir([animaldir, datatype,'*']);

if strcmp(datatype, 'eeg')
    datafiles=datafiles(2:end); 
else
    datafiles;
end

for i = 1:length(datafiles)
    if isempty(files)
        load([animaldir,datafiles(i).name]);
        eval(['out = datavaradd(out, sessindex, ',datatype,');']);
    else
        s = datafiles(i).name;
        fileday = str2num(s(strfind(s,datatype)+length(datatype):strfind(s,'.')-1));  %get the experiment day from the filename
        if (isempty(fileday))|(ismember(fileday,files))
            load([animaldir,datafiles(i).name]);
            eval(['out = datavaradd(out, sessindex,',datatype,');']);
        end
    end
end


%--------------------------------------
function out = datavaradd(origvar, sessindex, addcell)
out = origvar;
for i = 1:length(addcell{sessindex(1)}{sessindex(2)})
    if (~isempty(addcell{sessindex(1)}{sessindex(2)}{i}))
        out{sessindex(1)}{sessindex(2)}{i} = addcell{sessindex(1)}{sessindex(2)}{i};
    end
end
        
