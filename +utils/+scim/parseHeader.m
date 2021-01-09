function header = parseHeader(input, prefix)
% PARSEHEADER   - Read ScanImage Header String and return structure.
%   PARSEHEADER will output the value of the header fields as a structure.
%   Input is the header from ScanImage TIF File (char array).
%   prefix is the 'name' given to each data point
%
% See also

out={};
prefixLen = numel(prefix);
tempcell=strread(input,'%q'); 
for lineCounter=1:length(tempcell)
    data=tempcell{lineCounter};
    if ~strncmp(data, prefix, prefixLen)
        out{end}=[out{end} ' ' data(1:end-1)];
        continue
    end
    equal=findstr('=',data);
    param=data(prefixLen + 1:equal-1);
    val=data(equal+1:end);
    if isempty(val)
        val=[];
    elseif ~strcmp(val(1),'''')
        val=str2num(val);
    else
        if strcmp(val(end),'''')
            val=val(2:end-1);
        else
            val=val(2:end);
        end
    end
    out=[out {param} {val}];
end

while length(out)>2
    eval(['header.' out{1} '=out{2};']);
    out=out(3:end);
end
