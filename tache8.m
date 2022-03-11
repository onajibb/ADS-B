clear;
close all;
clc;

load('buffers.mat');
P0 = [zeros(1,10) ones(1,10)]; 
P1 = [ones(1,10) zeros(1,10)]; 
fe = 20e6;   %Fréquence d'échantillonage
preambule = [P1 P1 zeros(1,20) P0 P0 zeros(1,60)]';    %ajout du préambule suivant fse
p_conv = [0.5*ones(1,10) -0.5*ones(1,10)];
T_s = 1e-6; 
T_e = 1/fe; 
Fse = T_s/T_e;
buffersv=buffers(:);
buffersv=abs(buffersv).^2;
a=1;
b=100;
tab_indice=0;
%% -------- produit de corrélation ---------%%
while(b<length(buffersv)-2400)
    estimation = zeros(1,100);
    for i=a:b
        estimation(i-a+1) = (sum(buffersv(i:i+length(preambule)-1).* preambule)*Fse )/ (sqrt(sum(abs(preambule).^2)) * sqrt(sum(buffersv(i:i+length(preambule)-1).^2))*Fse); 
    end
    [argretard,  indice]=max(abs(estimation));
    %%---- Extraire la tram utile ----%%
    recieved=buffersv(a+indice+length(preambule)+1:a+indice+length(preambule)+2240);
    %%---- produit de convolution + sous-echantillonage ----%%
    v_l = conv(p_conv',recieved);
    v_m =v_l(Fse:Fse:length(v_l));
    %%---- décodage PPM ----%%
    bits_recieved = zeros(length(v_m),1); 
       for ii=1:length(bits_recieved)
           if real(v_m(ii)) > 0
               bits_recieved(ii) = 0; 
           elseif real(v_m(ii)) < 0
               bits_recieved(ii) = 1; 
           end 
       end
    %%----remplire le tableau tab_indice avec la trame finale-----%%
    tab_indice = [tab_indice ; bits_recieved]; 
    %%---- invrémenter la valeur de a et b-----%%
    a=a+indice+2400;
    b=a+99;
end
tab_indice=tab_indice(2:length(tab_indice));

%%  ------- décodage des trams ---------%%

addpath('Client', 'General', 'MAC', 'PHY');
% Coordonnees de reference (endroit de l'antenne)
REF_LON = -0.606629; % Longitude de l'ENSEIRB-Matmeca
REF_LAT = 44.806884; % Latitude de l'ENSEIRB-Matmeca
%registre1=bit2registre(adsb_msgs(:,1)',0,44.806884,-0.606629);
began=1;
endd=112;
affiche_carte(REF_LON, REF_LAT);
hold on
for i=1:112:length(tab_indice)
    if((tab_indice(i:i+4))' == de2bi(17))
        registre=bit2registre((tab_indice(i:i+111))',0,44.806884,-0.606629);
        plot(registre.longitude,registre.latitude,'.r','MarkerSize',20);
    end
end


