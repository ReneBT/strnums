function [ numfromstr, txtfromstr ] = strnums( tempstr , opt , sep , real )
% strnums is a function to scan through a string and isolate just the
% numbers before converting to a number.
% INPUTS:   tempstr:    the string containing mixed numeric and non-numeric
%                       characters
%           opt:        optional handling of splitting, default 1
%           sep:        cell array of seperator characters to choose what
%                       characters define new number sequence. Default is
%                       space. Only relevant to option 3
%           real:       logical with true for only real numbers or false to
%                       interpret i as imaginary number
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
% OUTPUTS:  numfromstr: array of numeric output, double or double
%                       imaginary if i or j present and real=false
%           txtfromstr: cell array of strings preceeding or following
%                       numeric groups.
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
% num = strnums('A123-231',3); gives num = -108 NOTE evaluates the minus
%                                               operation
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
% 
% ['Test setup: Param1 = 30 pa, Rate = 1.00, Limits = 65','Technical ',...
% 'Note:Temp=20 C, CrossWind 12.385m/s, Elevation 7.5km (Cloudy)']
% opt 1 => test = [] 
% >Warning: more than one format character present in extracted string, try option 2 or 3 to
% >separate out each numeric group 
%
% opt 2 => test = 1.0000   30.0000   -1.0000   65.0000   20.0000   12.3850    7.5000
%
% opt 3 => test = 1.0000   30.0000   -1.0000   65.0000   20.0000   12.3850    7.5000
%
% opt 4 => test =   1     3     0     1     0     0     6     5     2     0     1     2     3     8
%                   5     7     5

% ['Test setup: Param1 = 30 pa, Rate = 1.00, Limits = 65','Technical ',...
% 'Note:Temp=20 C, CrossWind 12.385m/s, Elevation 7.5km (Cloudy)']
% opt 3, real = true
% opt 3 => test = 1.0000   30.0000   -1.0000   65.0000   20.0000   12.3850    7.5000
%
% opt 3, real = false
% opt 3 => test =   1.0000 + 0.0000i  30.0000 + 0.0000i  -1.0000 + 0.0000i  
%                   65.0000 + 0.0000i 20.0000 + 0.0000i  12.3850 + 0.0000i   
%                   0.0000 + 7.5000i

% Copyright 2019 Rene Beattie, J Renwick Beattie Consulting
% First created 11/03/2019
% modified 13/03/2019 to handle mathematical format characters +,- and . as
% well as handling i and j as imaginary numbers

if nargin < 4 %default to ignoring imaginary number
    real = true;
end
if nargin < 3
    sep = ' '; %default seperator to space
end
if nargin < 2
    opt = 1; %default option is return as all one number, dropping leading zeros
end
if ~any( opt == 1:4 )
    error(sprintf(['options are\n1 for returning concatenated number\n2 ',...
        'for bunched numbers (i.e. consecutive numeric digits treated as ',...
        'one number)\n3 for multiple digits where spaces exist\n4 for every ',...
        'digit returned seperately'])) %#ok<SPERR>
end

%initialise nustr variable to store the numeric strings
nustr = [ ];
    
if real
    numChar = { '0' , '1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9'};
else
    numChar = { '0' , '1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' ,...
        'i' , 'j' };
end
numForm = { '+' , '-' , '.' }; %note does not currently interpret commas as decimal point

if iscell( sep )
    for iS = 1:length( sep )
        numForm = numForm( ~strcmp( sep{iS} , numForm ) ); %if defined as a separator, overule number format
    end
else
    numForm = numForm( ~strcmp( sep , numForm ) ); %if defined as a separator, overule number format
end

for iD = 1:length( tempstr )
    if any( strcmp( tempstr( iD ) , [ numChar , numForm] ) ) %exclude spaces to make one number
        if any( strcmp( tempstr( iD ) , {'i' , 'j'} ) ) && ...
                any( strcmp( tempstr( iD-1 ) , [ numChar( 1:10 ) , numForm] ) )                
            % imaginary i should be proceeded by space, plus,
            % minus or real number
            switch opt
                case 4
                    if any( strcmp( tempstr( iD ) , numChar( 1:10 ) ) )
                        nustr = [ nustr , tempstr( iD ) , ' ']; %#ok<*AGROW>
                        tempstr( iD ) = char(1029); %remove numbers once read
                    else
                        nustr = [ nustr , ' ']; 
                    end
                otherwise
                    nustr = [ nustr , tempstr( iD )];
                    tempstr( iD ) = char(1029); %remove numbers once read
            end
        elseif ~any( strcmp( tempstr( iD ) , {'i' , 'j'} ) )
            switch opt
                case 4
                    if any( strcmp( tempstr( iD ) , numChar( 1:10 ) ) )
                        nustr = [ nustr , tempstr( iD ) , ' '];
                        tempstr( iD ) = char(1029); %remove numbers once read
                    else
                        nustr = [ nustr , ' '];
                    end
                otherwise
                    nustr = [ nustr , tempstr( iD )];
                    tempstr( iD ) = char(1029); %remove numbers once read
            end  
        elseif opt==2
            nustr = [ nustr , ' ']; %separate out numbers split by anything non-numeric
        end
    elseif opt == 3 && any( strcmp( tempstr( iD ) , sep ) )
        nustr = [ nustr , ' ']; % separate out numbers split by defined separators
        tempstr( iD ) = char(1029); %  remove separators once read
    elseif opt ==2
        nustr = [ nustr , ' ']; %separate out numbers split by anything non-numeric   
    end
end

if ~isempty( nustr )
    numfromstr = str2num( nustr ); %#ok<ST2NM>
    if isempty( numfromstr )
        nForms = 0;
        for iF = 1:length( numForm )
            nForms = nForms+numel( strfind( nustr , numForm{iF} ) );
        end
        if nForms>1
            warning( [ 'more than one format character present in extracted ',...
                'string, try option 2 or 3 to separate out each numeric group' ] )
        end
    end
else
    numfromstr = NaN;
end

spcs = strfind(tempstr,char(1029));
cons = [2,spcs(2:end)-spcs(1:end-1)]; %first value means that leading marker retained
spcs(cons==1) = [];
txtfromstr = cell(0);
if isempty(spcs)
    warning('STRNUMS:NONUMBER','No number was found in the string')
    txtfromstr{1} = tempstr;
end
if spcs(1) ~=1 %if first character is not a digit
    spcs = [0,spcs];
end
for iSp = 2:numel( spcs )
    temp = tempstr( spcs ( iSp-1 ) +1 : spcs( iSp ) -1 );
    temp( strfind( temp , char( 1029 ) ) ) = [ ]; %remove separator characters
    txtfromstr{ iSp-1 } = temp; %take string between spacers
end
if spcs( end ) ~= length( tempstr ) && ~isequal( spcs, 1)
    temp = tempstr( spcs( iSp ) +1 : end );
    temp( strfind( temp , char( 1029 ) ) ) = [ ]; %remove separator characters
    txtfromstr{ iSp } = temp;
else
    txtfromstr{1} = '';
end
