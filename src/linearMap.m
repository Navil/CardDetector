function mappedValue = linearMap(value, minIn, maxIn, minOut, maxOut)
% function for linear mapping between two ranges
% inputs:
% vin: the input vector you want to map, range [min(vin),max(vin)]
% rout: the range of the resulting vector
% output:
% vout: the resulting vector in range rout
% usage:
% >> v1 = linspace(-2,9,100);
% >> v2 = linmap(v1,[-5,5]);
%

mappedValue = ((minOut+maxOut) + ...
               (maxOut-minOut) * ... 
               ((2*value - (minIn+maxIn)) / (maxIn-minIn))) / 2;

        
                
end

