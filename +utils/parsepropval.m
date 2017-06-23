function prop = parsepropval(prop, varargin)
%PARSEPROPVAL2: Parse property/value pairs and return a structure.
%  Manages property/value pairs like MathWorks Handle Graphics functions.
%  This means that in addition to passing in Property name strings and
%  Values, you can also include structures with appropriately named fields.
%  The full, formal property names are defined by the defaults structure
%  (first input argument). This is followed by any number of property/value
%  pairs and/or structures with property names for the field names.  The
%  property name matching is case-insensitive and needs only be
%  unambiguous.
%
%  For example,
%
%    params.FileName = 'Untitled';
%    params.FileType = 'text';
%    params.Data = [1 2 3];
%    s.dat = [4 5 6];
%    parsepropval(params,'filenam','mydata.txt',s,'filety','binary')
%
%  returns a structure with the same field names as params, filled in
%  according to the property/value pairs and structures passed in.
%    ans = 
%        FileName: 'mydata.txt'
%        FileType: 'binary'
%        Data: [4 5 6]
%
%  The inputs are processed from left to right so if any property is
%  specified more than once the latest value is retained.
%
%  An error is generated if property names are ambiguous.  Values can be
%  any MATLAB variable.
%
%  Typical use is in a function with a variable number of input arguments.
%  For example,
%
%  function myfun(varargin)
%    properties.prop1 = [];
%    properties.prop2 = 'default';
%    properties = parsepropval(properties,varargin{:});


% Version: 1.0, 13 January 2009
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})

% Some modifications by Matthew J.P. Barrett, Kim David Ferrari et al.

% Process inputs and set prop fields.
properties = fieldnames(prop);
arg_index = 1;

% Loop through the arguments
nVarArgs = numel(varargin);
while arg_index <= nVarArgs
    
	arg = varargin{arg_index};
    
	if ischar(arg)
        
        % Check that we have an attribute/value pair
        isLast = isequal(arg_index, nVarArgs);
        if isLast
            error('ParsePropVal:MissingValue', ['No value was ' ...
                'specified for the attribute "%s"'], arg)
        end
        
        prop_index = match_property(arg, properties);
        if ~isempty(prop_index)
            prop.(properties{prop_index}) = varargin{arg_index + 1};
        end
		arg_index = arg_index + 2;
        
	elseif isstruct(arg) || isobject(arg)
        
		arg_fn = fieldnames(arg);
        for i = 1:length(arg_fn)
            
            prop_index = match_property(arg_fn{i}, properties);
            if ~isempty(prop_index)
                prop.(properties{prop_index}) = arg.(arg_fn{i});
            end
            
        end
        
		arg_index = arg_index + 1;
        
	else
		error('ParsePropVal:BadArgFormat', ['Properties must be ' ...
            'specified by property/value pairs, structures, or objects.'])
	end
    
end

end

% ====================================================================== %

function prop_index = match_property(arg, properties)
    
prop_index = find(strcmpi(arg, properties));
if isempty(prop_index)
	prop_index = find(strncmpi(arg, properties, length(arg)));
end

if isempty(prop_index)
    warning('ParsePropVal:UnknownAttr', ['Property ''%s'' ' ...
        'does not exist.'], arg)
elseif length(prop_index) > 1
	error('ParsePropVal:AmbiguousAttr', 'Property ''%s'' is ambiguous.', arg)
end

end
