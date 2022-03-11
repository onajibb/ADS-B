%%%%%%%
clc;
clear;
close all ; 

%%



%%% 
% Initialisation of the parameters 

fe = 20*10^(6) ;    % frequence d'echantillonnage
Te  = 1/fe    ;      % periode echantillonnage 
Ts  = 10^(-6) ;     % periode symbole
Fse = Ts/fe;        % facteur sur echantillonnage 
Nfft = 256 ;        % 
freq=[-1/2 : 1/Nfft :1 /2-1/Nfft].*fe;



N = Nfft * 100 ; %100 window de 256 

p0=[zeros(1,10) ones(1,10)];              %p0(t) 
p1=[ones(1,10) zeros(1,10)];              % p1(t) 
p=[-0.5*ones(1,10) 0.5*ones(1,10)];       %p(t) 

b = randi([0,1] , N,1) ; % la sequence binaire ( suit la loi discrete  uniforme ) 
%% sl(t) à l'aide de l'expression de la :  tache1 -> soutache1

Ak = (-2*b)+1;   % Ak vaut -1 ou 1 selon bk

sl_t = 0.5 + conv(Ak, p);


%% la DSP analytique de sl(t)  : 
D = zeros(1,length(freq)) ; 

for i = 1 : length(freq) 
    if freq(i) == 0 
        D(i) = 1 ;
    end 
end 



DSP_analytique  = 0.25*D +  (((Ts^3)*(pi*freq).^2)/16 ).*(sinc(freq*Ts/2)).^4 ;    %% expression demontre :tache2 -> soutache4                       
%0.25*dirac(freq)



%% la DSP à l aide de la fonction Mon_welch (DSP exp) 

DSP_welch =   Mon_Welch(sl_t,Nfft,fe) ; 




%% affichage 

semilogy(freq,DSP_analytique ,'m')
hold all
semilogy(freq,DSP_welch,'r')
legend('DSP analytique','DSP experimentale' )

title('DSP de sl(t) ');
xlabel('frequence');
%% resultat : 
 %les courbes ne sont pas confondues , il faut multiplier my_welch par Fse 

