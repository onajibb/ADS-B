function [encoded]=encodeCRC(message)
    gen = crc.generator([ones(13,1);0;1;zeros(6,1);1;0;0;1]');
    encoded = generate(gen, message);% générer la trame complète avec les bits de crc
end
                                     
