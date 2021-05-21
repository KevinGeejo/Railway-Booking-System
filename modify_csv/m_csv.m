clear;
add = '/Users/birdpeople/classObject/DB/train/';
file = {'0';'g';'t';'c';'k';'y';'z';'d'}';
%file = {'0';'g'}';
for this = 1:size(file,2)
address = strcat(add,file{this},'/');
File = dir(fullfile(address,'*.csv'));
FileNames = {File.name}';
Length_Names = size(FileNames,1); 

global B;
for i = 1:Length_Names
    B = string([]);
    C = string([]);
     K_Trace = strcat(address, FileNames(i));
     A = readmatrix(K_Trace{1}, 'OutputType', 'string');
     BB = A(:,[1,2,3,4,6,8,9,10,]);
     
      CC = getSeat(BB);
     num = size(BB,1);
     index = 1;
     for ii = 1:num
         if ~(BB(ii,5) ~= '-' && str2double(BB(ii,5))< 0 && CC(ii,1)=='0'&&CC(ii,2)=='0'&&CC(ii,3)=='0'&&CC(ii,4)=='0'&&CC(ii,5)=='0'&&CC(ii,6)=='0'&&CC(ii,7)=='0')
             B(index,:) = BB(ii,[1,2,3,4,6,7,8]); 
             C(index,:) = CC(ii,:);index = index+1;
         end
     end
     
     mnptime(B);
     
    
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
    
   
    
    clear A,B,C,D,E,F,K_Trace,g,Fi,BB,CC;
    
end

end

 Fu = string([]);inde = 1;
   
    for m = 1: size(Final,1)
        if ~(Final(m,6) == '0' && Final(m,7) == '0' && Final(m,8) == '0' && Final(m,9) == '0' && Final(m,10) == '0' && Final(m,11) == '0' && Final(m,12) == '0')
            Fu(inde,:) = Final(m,:); inde = inde + 1;
        end
    end
    
newname = '_trainItem.csv';
newnameinfo = '_trainstaticInfo.csv';

cell2csv(strcat(add,newnameinfo),FinalInfo,',');
cell2csv(strcat(add,newname),Fu,',');

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
        tmp1 = strsplit(B(i,6),'/');
        tmp2 = strsplit(B(i,7),'/');
        tmp3 = strsplit(B(i,8),'/');
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

