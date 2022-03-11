clear 
close all
clc



%% 
Fe = 20e6; % Frequence d'echantillonnage (imposee par le serveur)
Rb = 1e6;% Debit binaire (=debit symbole)
Fse = floor(Fe/Rb); % Nombre d'echantillons par symboles
Nfft = 1024;
Nb = 112;

%% Chaîne TX
b = randi([0,1],Nb,1);
c = encodeCRC(b);

%% Chaîne RX sans erreur
[d, error_flag] = decodeCRC(c);

%% Affichage du resultat
disp(['Flag d''erreur : ', num2str(error_flag)])

%% Chaîne RX avec une erreur
idx_error = randi(Nb,1,1);
c(idx_error) = 1 - c(idx_error);
[d, error_flag] = decodeCRC(c);

%% Affichage du resultat
disp(['Flag d''erreur : ', num2str(error_flag)])