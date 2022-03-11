clear
close all
clc

%% Bits émis

fe = 20e6;   %Fréquence d'échantillonage
T_s = 1e-6; 
T_e = 1/fe; 
Fse = T_s/T_e; 

P0 = [zeros(1,10) ones(1,10)]; 
P1 = [ones(1,10) zeros(1,10)]; 
n_bits = 1000; 
bits_emis = randi([0 1], n_bits,1);
Sb = randi([0 1],n_bits,1);
p_conv = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5];
Eg = sum((abs(p_conv).^2));     %Energie du filtre de mise en forme 
eb_n0_dB = 0:1:10; %Liste des Eb/N0 en dB

eb_n0 = 10.^(eb_n0_dB/10); %Liste des Eb/N0
Pb=qfunc(sqrt(2*eb_n0));
sigA2 = 1; %Variance théorique des symboles
eb_n0 = 10.^(eb_n0_dB/10); %Liste des Eb/N0
sigma2 =(Eg./eb_n0)/2 ; % Variance du bruit complexe en bande basse 

TEB = zeros(size(eb_n0));
 


%% Calcul de la TEB
    for a = 1:length(eb_n0)
        error_cnt = 0; 
        bit_cnt = 0;     
    while error_cnt < 100 
        %% Calcul de s_l
        
            s_l = zeros(length(bits_emis)*20,1); 
            for ii=1:n_bits
                if bits_emis(ii) == 1
                    s_l(20*(ii-1)+1:20*ii) = P1';
                elseif bits_emis(ii) == 0
                    s_l(20*(ii-1)+1:20*ii) = P0';
                end
            end 
            
            
        %% Ajout du bruit 

            nl = sqrt(sigma2(a))*(randn(size(s_l)));


        %% Chaine de réception 
           
            s_l = s_l + nl; 
            r_l = conv(p_conv,s_l);
            r_m =r_l(Fse:Fse:length(r_l));       %Echantillonage au rythme Ts + prise en considération du retard
            
            %% Bloc de décision 
            bits_recieved = zeros(length(r_m),1); 
            for ii=1:length(bits_recieved)
                if real(r_m(ii)) > 0
                    bits_recieved(ii) = 0; 
                elseif real(r_m(ii)) < 0
                    bits_recieved(ii) = 1; 
                end 
            end 
            
             %% calcul de proba d'erreur binaire et incrementation des compteurs
        
        nbr_erreur=sum(abs(bits_recieved - bits_emis));                                 % Matrice des différences entre les deux sequences TX et RX
                                        % Probabilité d'erreur binaire
        
        error_cnt=error_cnt +nbr_erreur;
        bit_cnt = bit_cnt + n_bits;
            
      TEB(a)=error_cnt/bit_cnt; 
   
   
      end
    end
    

        

    


%% Figures


time = [0:length(r_l)-1]*T_e;


figure,
semilogy(eb_n0_dB,TEB);
hold on
semilogy(eb_n0_dB,Pb);
title("Taux d'erreur binaire en fonction de Eb/N0");

 xlabel('Eb/N0'), ylabel('TEB et Pb'); 
 legend('TEB (dB)','Pb (dB)');




