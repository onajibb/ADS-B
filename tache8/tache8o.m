close all
clear all
clc

load('buffers.mat'); 

%% Paramètres
P0 = [zeros(1,2) ones(1,2)]; 
P1 = [ones(1,2) zeros(1,2)]; 
seuil = 0.70; 
s_p = [P1 P1 zeros(1,4) P0 P0 zeros(1,12)]';    %ajout du préambule suivant fse
p_conv = [0.5 0.5 -0.5 -0.5];

Fse = 4; 
size = size(buffers);
 
Y = reshape(buffers,[size(1)*size(2),1]); 

Y = abs(Y).^2; 
J = zeros(size(1)*size(2),1);
 
trames = zeros(112,1); 
 for i=1:(size(1)*size(2))-length(s_p)
    J(i) = intercorr(Y(i:length(s_p)+i-1), s_p,Fse);
 end 

 for i=1:size(1)*size(2)-1000
    if(J(i) >= 0.7) 
       estimation = zeros(1,100);
                for j=1:100
                    estimation(j) = (sum(Y(j+i:j+i+length(s_p)-1).* s_p)*Fse )/ (sqrt(sum(abs(s_p).^2)) * sqrt(sum(Y(j+i:j+i+length(s_p)-1).^2))*Fse); 
                end
                [argretard,  retard]=max(abs(estimation)); 
                retard = retard - 1; 
                recieved = Y(retard+length(s_p)+i:112*4+i+retard+length(s_p)-1);
        
       v_l = conv(p_conv,recieved);
       v_m =v_l(Fse:Fse:length(v_l));
       bits_recieved = zeros(length(v_m),1); 
           for ii=1:length(bits_recieved)
               if real(v_m(ii)) > 0
                  bits_recieved(ii) = 0; 
               elseif real(v_m(ii)) < 0
                  bits_recieved(ii) = 1; 
               end 
           end 

        
       [outdata,error]=decodeCRC(bits_recieved);
        if error == 0
           trames = [trames bits_recieved]; 
        end 
    end
 end
 
 load('adsb_msgs.mat');
%load('adsb_msgs.mat');
addpath('Client', 'General', 'MAC', 'PHY');
% Coordonnees de reference (endroit de l'antenne)
REF_LON = -0.606629; % Longitude de l'ENSEIRB-Matmeca
REF_LAT = 44.806884; % Latitude de l'ENSEIRB-Matmeca
%registre1=bit2registre(adsb_msgs(:,1)',0,44.806884,-0.606629);

affiche_carte(REF_LON, REF_LAT);
hold on
for i=1:length(trames)
    registre=bit2registre(trames(:,i)',0,44.806884,-0.606629);
    plot(registre.longitude,registre.latitude,'.r','MarkerSize',20);
end
 
 
 
 
 
 


 
        
    