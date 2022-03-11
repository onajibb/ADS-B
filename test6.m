close all
clear
clc

load('adsb_msgs.mat');
addpath('Client', 'General', 'MAC', 'PHY');
% Coordonnees de reference (endroit de l'antenne)
REF_LON = -0.606629; % Longitude de l'ENSEIRB-Matmeca
REF_LAT = 44.806884; % Latitude de l'ENSEIRB-Matmeca

%% ---------- afficher la carte avec la fonction affiche_carte et la superposer avec la trajet de l'avion ----------- %%
affiche_carte(REF_LON, REF_LAT);
hold on
for i=1:27
    registre=bit2registre(adsb_msgs(:,i)',0,44.806884,-0.606629);
    plot(registre.longitude,registre.latitude,'.r','MarkerSize',20);
end
