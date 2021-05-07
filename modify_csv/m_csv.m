clear;
add = '/Users/birdpeople/classObject/DB/train/';
file = {'0';'g';'t';'c';'k';'y';'z';'d'}';

for this = 1:size(file,2)
address = strcat(add,file{this},'/');
File = dir(fullfile(address,'*.csv'));
FileNames = {File.name}';
Length_Names = size(FileNames,1); 

global B;
for i = 1:Length_Names
     K_Trace = strcat(address, FileNames(i));
     A = readmatrix(K_Trace{1}, 'OutputType', 'string');
     B = A(:,[1,2,3,4,8,9,10]);
     mnptime(B);
     C = getSeat(B);
     D = [B(2:end,[1,2,3,4]),C(2:end,:)];
     g = strsplit(FileNames{i},'.');
     E = string(zeros(size(B,1)-1,1));
     for col = 1:(size(B,1)-1)
         E(col,1) = g{1}; 
     end
    if i==1 && this ==1
        Final = [E,D];
        F = [];
        Fi = [];
        FinalInfo = [E(1,1),B(1,2),B(end,2),B(1,4)];
    else
        F = [E,D];
        Final = [Final;F];
        Fi = [E(1,1),B(1,2),B(end,2),B(1,4)];
        FinalInfo = [FinalInfo;Fi];
    end
    clear A,B,C,D,E,F,K_Trace,g,Fi;
    
end

end

newname = '_trainItem.csv';
newnameinfo = '_trainstaticInfo.csv';

cell2csv(strcat(add,newnameinfo),FinalInfo,',');
cell2csv(strcat(add,newname),Final,',');

function  mnptime(B)
global B;
for i = 1: size(B,1)
    B(i,3) = strcat(B(i,3),':00');
    B(i,4) = strcat(B(i,4),':00');
    B(end,4) = "00:00:00";
end
end

function C = getSeat(B)
    for i = 1:size(B,1)
        tmp1 = strsplit(B(i,5),'/');
        tmp2 = strsplit(B(i,6),'/');
        tmp3 = strsplit(B(i,7),'/');
        C(i,[1,2]) =tmp1;
        C(i,[3,4,5]) =tmp2;
        C(i,[6,7]) =tmp3;
        for j = 1:7
            if C(i,j) == '-'
                C(i,j) = '0';
            end
        end
        
    end
end



function cell2csv(filename,cellArray,delimiter)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
if nargin<3
    delimiter = ',';
end
 
datei = fopen(filename,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval(['cellArray{z,s}']);
        
        if size(var,1) == 0
            var = '';
        end
        
        if isnumeric(var) == 1
            var = num2str(var);
        end
        
        fprintf(datei,var);
        
        if s ~= size(cellArray,2)
            fprintf(datei,[delimiter]);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);
end

