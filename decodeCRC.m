function[outdata,error]=decodeCRC(encoded)
    det = crc.detector([ones(13,1);0;1;zeros(6,1);1;0;0;1]');
    [outdata error] = detect(det, encoded);  % Detect the error
end