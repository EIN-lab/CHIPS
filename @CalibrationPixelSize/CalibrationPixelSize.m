classdef CalibrationPixelSize
%CalibrationPixelSize - Class containing a pixel size calibration
%
%   The CalibrationPixelSize class is a data class that is designed to
%   contain a calibration relating a given microscope zoom factor to a
%   known physical pixel size (in units of distance).
%
%   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_md_Calibration.html'))">CalibrationPixelSize quick start guide</a> for additional
%   documentation and examples.
%
% CalibrationPixelSize public properties
%   date            - The date that the calibration was performed
%   funRaw          - The raw (unparameterised) calibration function
%   imgSize         - The size of the calibration images [number of pixels]
%   name            - The name of the calibration
%   objective       - The objective lens that was used for the calibration
%   person          - The person who performed the calibration
%   pixelSize       - The measured pixelSize for a given zoom [um]
%   zoom            - The zoom values at which pixelSize was measured
%
% CalibrationPixelSize public methods:
%   CalibrationPixelSize - CalibrationPixelSize class constructor
%   calc_pixel_size - Calculate the pixel size
%   eq              - Test two CalibrationPixelSize objects for equality
%   isequal         - Test CalibrationPixelSize objects for equality
%   plot            - Plot CalibrationPixelSize objects
%   save            - Save CalibrationPixelSize objects
%
% CalibrationPixelSize static methods
%   funRawDummy     - A dummy function
%   funRawHyperbola - A two parameter rectangular hyperbolic function
%   load            - Load a CalibrationPixelSize object
%
%   See also CalibrationPixelSize.CalibrationPixelSize, Metadata

%   Copyright (C) 2017  Matthew J.P. Barrett, Kim David Ferrari et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%   
%   You should have received a copy of the GNU General Public License 
%   along with this program.  If not, see <http://www.gnu.org/licenses/>
    
    % ================================================================== %
    
    properties (SetAccess=protected)
        
        %date - The date that the calibration was performed
        %
        %   The date must be a single row character array.
        date
        
        %funRaw - The raw (unparameterised) calibration function
        %
        %   The funRaw must be a handle to a function of the form:
        %
        %       [pixelSize, strFun] = ff(zoom, params)
        %
        %   where pixelSize is the predicted pixel size for given values of
        %   zoom and function parameters, and strFun is a string describing
        %   the parameterised function.
        %
        %   See also CalibrationPixelSize.pixelSize, 
        %   CalibrationPixelSize.zoom
        funRaw = @CalibrationPixelSize.funRawHyperbola;
        
        %imgSize - The size of the calibration images [number of pixels]
        %
        %   The imgSize must be a scalar integer
        imgSize
        
        %name - The name of the calibration
        %
        %   The name must be a single row character array.
        name
        
        %objective - The objective lens that was used for the calibration
        %
        %   The objective must be a single row character array.
        objective
        
        %person - The person who performed the calibration
        %
        %   The person must be a single row character array
        person
        
        %pixelSize - The measured pixelSize for a given zoom [um]
        %
        %   The pixelSize must be a vector of positive real numbers
        %   corresponding to the measured pixel size (in micrometers) at
        %   given zoom values
        %
        %   See also CalibrationPixelSize.zoom
        pixelSize
        
        %zoom - The zoom values at which pixelSize was measured
        %
        %   The zoom must be a vector of positive real numbers
        %   corresponding to the zoom values at which pixelSize was
        %   measured
        %
        %   See also CalibrationPixelSize.pixelSize
        zoom
        
    end
    
    % ------------------------------------------------------------------ %
    
    properties (Access=protected)
        
        %funFitted - The fitted (parameterised) calibration function
        %
        %   See also CalibrationPixelSize.funRaw,
        %   CalibrationPixelSize.paramsOpt
        funFitted
        
        %paramsOpt - The parameters for the fitted calibration function
        %
        %   See also CalibrationPixelSize.funRaw,
        %   CalibrationPixelSize.funFitted
        paramsOpt
        
    end
    
    % ================================================================== %
    
    methods
        
        function CalObj = CalibrationPixelSize(varargin)
        %CalibrationPixelSize - CalibrationPixelSize class constructor
        %
        %   OBJ = CalibrationPixelSize(ZOOM, PXSIZE, IMGSIZE)
        %   uses the specified ZOOM, PXSIZE, and IMGSIZE, prompts for all 
        %   other required information and creates a CalibrationPixelSize 
        %   object.
        %   ZOOM must be a vector of zoom values of the format expected by
        %   the CalibrationPixelSize.zoom property.
        %   PXSIZE must be a vector of measured pixel size values the same
        %   size as ZOOM, and of the format expected by the
        %   CalibrationPixelSize.pixelSize property.
        %   IMGSIZE must be a scalar integer specifying the number of
        %   pixels in the calibration images.
        %
        %   OBJ = CalibrationPixelSize(ZOOM, PXSIZE, IMGSIZE, OBJECTIVE, 
        %       DATE, NAME, PERSON, FUNRAW) also specifies the DATE, NAME,
        %       PERSON, and FUNRAW.
        %   OBJECTIVE must be a single row character array describing the
        %   objective that was used for this calibration.
        %   DATE must be a  single row character array specifying the date
        %   that the calibration was performed on.
        %   NAME must be a single row character array specifying a name for
        %   the calibration.
        %   PERSON must be a single row character array representing the
        %   person who performed the calibration.
        %   FUNRAW must be a function handle of a raw (unparameterised)
        %   function of the format expected by the
        %   CalibrationPixelSize.funRaw property.
        %
        %   Please see the <a href="matlab:web(fullfile(utils.CHIPS_rootdir, 'doc', 'html', 'id_md_Calibration.html'))">CalibrationPixelSize quick start guide</a> for 
        %   additional documentation and examples.
        %
        %   See also CalibrationPixelSize.zoom,
        %   CalibrationPixelSize.pixelSize, CalibrationPixelSize.imgSize,
        %   CalibrationPixelSize.objective, CalibrationPixelSize.date,
        %   CalibrationPixelSize.name, CalibrationPixelSize.person,
        %   CalibrationPixelSize.funRaw, CalibrationPixelSize.load
            
            % Parse arguments
            [zoomIn, pixelSizeIn, imgSizeIn, objectiveIn, dateIn, ...
                nameIn, personIn, funRawIn] = utils.parse_opt_args(...
                {[], [], [], [], [], [], [], ...
                @CalibrationPixelSize.funRawHyperbola}, varargin);
            
            if ~isempty(zoomIn)
                CalObj.zoom = zoomIn;
            else
                error('CalibrationPixelSize:NoZoom', ['You must ' ...
                    'supply a vector of zoom values.'])
            end
            
            if ~isempty(pixelSizeIn)
                CalObj.pixelSize = pixelSizeIn;
            else
                error('CalibrationPixelSize:NoPixelSize', ['You must ' ...
                    'supply a vector of measured pixel size values.'])
            end
            
            % Check the two arrays are the same size
            utils.checks.same_size(CalObj.pixelSize, CalObj.zoom, ...
                'pixelSize and zoom');
            
            if ~isempty(imgSizeIn)
                CalObj.imgSize = imgSizeIn;
            else
                error('CalibrationPixelSize:NoImgSize', ['You must ' ...
                    'supply the number of pixels per line on the ' ...
                    'images that were used to measure the pixel size.'])
            end
            
            if ~isempty(objectiveIn)
                CalObj.objective = objectiveIn;
            else
                fprintf('\n')
                CalObj.objective = ...
                    CalibrationPixelSize.choose_objective();
             end
            
            if ~isempty(dateIn)
                CalObj.date = dateIn;
            else
                fprintf('\n')
                CalObj.date = CalibrationPixelSize.choose_date();
            end
            
            if ~isempty(personIn)
                CalObj.person = personIn;
            else
                fprintf('\n')
                CalObj.person = CalibrationPixelSize.choose_person();
            end
            
            if ~isempty(nameIn)
                CalObj.name = nameIn;
            else
                fprintf('\n')
                CalObj.name = CalibrationPixelSize.choose_name();
            end
            
            if ~isempty(funRawIn)
                CalObj.funRaw = funRawIn;
            end
            
            % Perform the fit to generate the calibration curve function
            CalObj = CalObj.fit();
        
        end
        
        % -------------------------------------------------------------- %
        
        pixelSizeOut = calc_pixel_size(self, zoomIn, imgSizeIn)
        
        % -------------------------------------------------------------- %
        
        rr = eq(aa, bb)
        
        % -------------------------------------------------------------- %
        
        rr = isequal(self, varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = plot(self, varargin)
        
        % -------------------------------------------------------------- %
        
        save(self, varargin)
        
        % -------------------------------------------------------------- %
        
        function self = set.name(self, name)
            utils.checks.not_empty(name, 'name');
            utils.checks.single_row_char(name, 'name');
            self.name = name;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.date(self, date)
            utils.checks.not_empty(date, 'date');
            utils.checks.single_row_char(date, 'date');
            self.date = date;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.imgSize(self, imgSize)
            utils.checks.scalar(imgSize, 'imgSize');
            utils.checks.real_num(imgSize, 'imgSize');
            utils.checks.integer(imgSize, 'imgSize');
            self.imgSize = imgSize;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.objective(self, objective)
            utils.checks.not_empty(objective, 'objective');
            utils.checks.single_row_char(objective, 'objective');
            self.objective = objective;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.person(self, person)
            utils.checks.not_empty(person, 'person');
            utils.checks.single_row_char(person, 'person');
            self.person = person;
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.pixelSize(self, pixelSize)
            utils.checks.rfv(pixelSize, 'pixelSize');
            utils.checks.positive(pixelSize, 'pixelSize');
            self.pixelSize = pixelSize(:);
        end
        
        % -------------------------------------------------------------- %
        
        function self = set.zoom(self, zoom)
            utils.checks.rfv(zoom, 'zoom');
            utils.checks.positive(zoom, 'zoom');
            utils.checks.length(zoom, 1, 'zoom', 'greater')
            self.zoom = zoom(:);
            
        end
        
    end
    
    % ================================================================== %
    
    methods (Access=protected)
        
        self = fit(self)
        
    end
    
    % ================================================================== %
    
    methods (Static)
        
        CalObj = load(varargin)
        
        % -------------------------------------------------------------- %
        
        varargout = funRawHyperbola(zoomIn, params)
        
        % -------------------------------------------------------------- %
        
        varargout = funRawDummy(zoomIn, varargin)
        
    end
    
    % ================================================================== %
    
    methods (Static, Access=protected)
        
        function objective = choose_objective()
            objective = input(['Which objective lens is this ' ...
                'calibration for: '], 's');
        end
        
        % -------------------------------------------------------------- %
        
        function date = choose_date()
            date = input('What was the date of this calibration: ', ...
                's');
        end
        
        % -------------------------------------------------------------- %
        
        function person = choose_person()
            person = input('Who performed this calibration: ', 's');
        end
        
        % -------------------------------------------------------------- %
        
        function name = choose_name()
            name = input('Enter a name for this calibration: ', 's');
        end
        
        % -------------------------------------------------------------- %
        
        function objOut = loadobj(structIn)
            objOut = CalibrationPixelSize(structIn.zoom, ...
                structIn.pixelSize, structIn.imgSize, ...
                structIn.objective, structIn.date, structIn.name, ...
                structIn.person, structIn.funRaw);
        end
        
    end
    
    % ================================================================== %
    
end
