classdef Test_XSectScan_ui < matlab.unittest.TestCase
        
    % ================================================================== %
    
    methods (TestMethodSetup)
        function clear_persistent(~)
            utils.clear_persistent();
        end
    end
    
    % ================================================================== %
    
    methods (Test, TestTags = {'interactive'})
        
        function testNoArgs(self)
            
            % Setup the timers
            tArray = Test_XSectScan.select_xsectscan();
            
            % Create the object
            start(tArray)
            XSectScanObj1 = XSectScan();
            wait(tArray)
            
            % Run the verification
            self.verifyClass(XSectScanObj1, 'XSectScan');
            
        end
        
    end
    
    % ================================================================== %
    
end