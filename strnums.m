function numfromstr = strnums(tempstr,opt,sep)
% strnums is a function to scan through a string and isolate just the
% numbers before converting to a number.
% INPUTS:   tempstr:    the string containing mixed numeric and non-numeric
%                       characters
%           opt:        optional handling of splitting, default 1
%           sep:        cell array of seperator characters to choose what
%                       characters define new number sequence. Default is
%                       space. Only relevant to option 3
%   Optional handling choices are as follows
%       1. Concatenate all numeric characters together to convert to a
%           single number, disregarding any separating characters. Leading
%           zeros are lost except where only zeros exist.
%       2. Concatenate only adjacent numeric characters, returning a
%           number per separate block. Leading zeros in any block are lost
%           except where only zeros exist
%       3. Concatenate adjacent numeric characters, ignoring undefined
%           separator characters, but grouping characters according
%           the characters listed in sep
%       4. Return each digit separately
%
% num = strnums('A123 231'); gives num = 123231
% num = strnums('A123 231',1); gives num = 123231
% num = strnums('A123 231',2); gives num = [123, 231]
% num = strnums('A123 231',3); gives num = [123, 231]
% num = strnums('A123 231',4); gives num = [1,2,3,2,3,1]
% for non space seperator
% num = strnums('A123-231'); gives num = 123231
% num = strnums('A123-231',1); gives num = 123231
% num = strnums('A123-231',2); gives num = [123, 231]
% num = strnums('A123-231',3); gives num = 123231 NOTE this ignores ndash
%                                           as default separator is space
% num = strnums('A123-231',3,'-'); gives num = [123, 231]
% num = strnums('A123-231',4); gives num = [1,2,3,2,3,1]
% 
%Some more examples of separator control:
% test = strnums('A12/3-23 1',3,{'-','/'})
% test =    12     3   231
% 
% test = strnums('A12/3-23 1',3,{'-','/',' '})
% test =    12     3    23     1
% 
% test = strnums('A12B3-23 1',3,{'-','B',' '})
% test =     12     3    23     1
% 
% %examples with leading zero character
% test = strnums('012B3-23 1',3,{'-','B',' '})
% test = 12     3    23     1 %leading zero dropped
%      
% test = strnums('012B3-23 1',1,{'-','B',' '})
% test = 123231 %leading zero dropped
% 
% test = strnums('012B3-23 1',4,{'-','B',' '})
% test =     0     1     2     3     2     3     1 
% %NOTE leading zero captured



% Copyright 2019 Rene Beattie, J Renwick Beattie Consulting
% First created 11/03/2019

if nargin<3
    sep = ' '; %default seperator to space
end
if nargin<2
    opt = 1; %default option is return as all one number, dropping leading zeros
end
if ~any(opt ==1:4)
    error(sprintf(['options are\n1 for returning concatenated number\n2 ',...
        'for bunched numbers (i.e. consecutive numeric digits treated as ',...
        'one number)\n3 for multiple digits where spaces exist\n4 for every ',...
        'digit returned seperately']))
end

%initialise nustr variable to store the numeric strings
nustr = [];

if opt==1
    for iD = 1:length(tempstr)
        if ~isnan(str2double(tempstr(iD))) %exclude spaces to make one number
            nustr = [nustr,tempstr(iD)]; %#ok<*AGROW>
        end
    end
elseif opt==2
    for iD = 1:length(tempstr)
        if ~isnan(str2double(tempstr(iD)))
            nustr = [nustr,tempstr(iD)];
        else
            nustr = [nustr,' ']; %this will seperate out non-consectutive numeric digits
        end
    end
elseif opt == 3
    for iD = 1:length(tempstr)
        if ~isnan(str2double(tempstr(iD))) 
            nustr = [nustr,tempstr(iD)];
        elseif any(strcmp(tempstr(iD),sep)) %if using str2num spaces return multiple numbers isolated by space
            nustr = [nustr,' '];
        end
    end
elseif opt == 4
    for iD = 1:length(tempstr)
        if ~isnan(str2double(tempstr(iD))) %place space between each digit
            nustr = [nustr,tempstr(iD),' '];
        end
    end
end

if ~isempty(nustr)
    numfromstr = str2num(nustr);
else
    numfromstr = NaN;
end