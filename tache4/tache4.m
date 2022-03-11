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
n_bits = 112; 
bits_emis = randi([0 1], n_bits,1);
Sb = randi([0 1],n_bits,1);
p_conv = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5 -0.5];
Eg = sum((abs(p_conv).^2));     %Energie du filtre de mise en forme 
eb_n0_dB = 0:1:12; %Liste des Eb/N0 en dB

eb_n0 = 10.^(eb_n0_dB/10); %Liste des Eb/N0
Pb=qfunc(sqrt(2*eb_n0));
sigA2 = 1; %Variance théorique des symboles
eb_n0 = 10.^(eb_n0_dB/10); %Liste des Eb/N0
sigma2 =(Eg./eb_n0)/2 ; % Variance du bruit complexe en bande basse 

TEB = zeros(size(eb_n0));
preambule = [P1 P1 zeros(1,20) P0 P0 zeros(1,60)]';    %ajout du préambule suivant fse
delai_propagation = floor(rand*(T_e*100)/T_e);               %délai de propagation
delta_f =   rand*(1000+1000) - 1000;                            %décalage fréquence


%% Calcul de la TEB
R = zeros(size(eb_n0)); 

    for a = 1:length(eb_n0)
        error_cnt = 0; 
        bit_cnt = 0;     
         Retards = zeros(1,1); 
    while error_cnt < 100 
        %% Calcul de s_l
        
            sl = zeros(length(bits_emis)*20,1); 
            for ii=1:n_bits
                if bits_emis(ii) == 1
                    sl(20*(ii-1)+1:20*ii) = P1';
                elseif bits_emis(ii) == 0
                    sl(20*(ii-1)+1:20*ii) = P0';
                end
            end 
            
            
        %% Ajout du retard et du préambule
            
            %______Ajout du préambule
            
                s_l = [preambule; sl];                  %ajout du préambule
                
            
            %______Ajout du retard de propagation 
            
                 retard = zeros(delai_propagation,1); 
                 S_l = [retard; s_l]; 
           %_______Ajout du décalage en fréquence
           
                for i=1:length(S_l)
                    S_l(i) = S_l(i) * exp(-1i*2*pi*delta_f); 
                end   
                 
        %% Ajout du bruit 
        
                nl = sqrt(sigma2(a))*(randn(size(S_l)));
                Y_l = S_l + nl;
                 
        %% Chaine de réception 
            
            r_l = abs(Y_l).^2; 
            
            %Synchronisation temps
                estimation = zeros(1,100);
                for i=1:100
                    estimation(i) = (sum(r_l(i:i+length(preambule)-1).* preambule)*Fse )/ (sqrt(sum(abs(preambule).^2)) * sqrt(sum(r_l(i:i+length(preambule)-1).^2))*Fse); 
                end
                [argretard,  retard]=max(abs(estimation)); 
                retard = retard - 1; 
                Retards = [Retards abs(delai_propagation - retard)];                          
                if retard > delai_propagation
                    retard = delai_propagation;
                end 
                recieved = r_l(retard-1+length(preambule):length(r_l));
            v_l = conv(p_conv,recieved);
            v_m =v_l(Fse:Fse:length(v_l));       %Echantillonage au rythme Ts 
            
            
            %% Bloc de décision 
            bits_recieved = zeros(length(v_m),1); 
            for ii=1:length(bits_recieved)
                if real(v_m(ii)) > 0
                    bits_recieved(ii) = 0; 
                elseif real(v_m(ii)) < 0
                    bits_recieved(ii) = 1; 
                end 
            end 
            
             %% calcul de proba d'erreur binaire et incrementation des compteurs
        
        nbr_erreur=sum(abs(bits_recieved(1:112) - bits_emis));                                 % Matrice des différences entre les deux sequences TX et RX
                                        % Probabilité d'erreur binaire
        
        error_cnt=error_cnt +nbr_erreur;
        bit_cnt = bit_cnt + n_bits;
        R(a) = mean(Retards); 
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
 
figure, 
semilogy(eb_n0_dB,R); 


