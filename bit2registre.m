function[registre]=bit2registre(X,errorCrc,LatRef,Lonref)
    registre= struct('adresse',[],'format',[],'type',[],'nom',[],'altitude',[],'timeFlag',[],'cprFlag',[],'longitude',[],'latitude',[]);
    if errorCrc==0
        nom="";
        adress="";
        %Le format de la voie descendante
        if(X(1:5) == de2bi(17))
            registre.format="ADS-B";
        end
       %----------champs adresse--------------
       %registe.adresse=binaryVectorToHex(X(9:32));%pour donner le format en exa
       
        for i=9:4:32
            for j=1:4
                a=X(i+j-1)*2^(4-i);
            end
            adress=adress + int2str(a);
            a=0;
        end
        registre.adresse=adress;
       %----------champs type----------------
       inttype=bi2de(flip(X(33:37)));
       if(inttype>0 && inttype<5)
                  registre.type='signe identification';
       elseif(inttype>4 && inttype<9) 
                  registre.type='position au sol';
       elseif(inttype>8 && inttype<19) 
                  registre.type='position au vol';
       elseif(inttype>19 && inttype<23) 
                  registre.type='position au vol';
       elseif(inttype == 19) 
                  registre.type='vitess';
       elseif(inttype == 23) 
                  registre.type='reservd for test purpose';
        elseif(inttype == 24) 
                  registre.type='reservd for surface systeme';
       elseif(inttype>24 && inttype<28) 
                  registre.type='reserved';
       elseif(inttype>28 && inttype<31) 
                  registre.type='reserved';
       elseif(inttype == 28) 
                  registre.type='extended squitter';
       
       elseif(inttype == 31) 
                  registre.type='aircaft operatoinal status';
       elseif(inttype == 0) 
                  registre.type='no pisition information';
       end
       %-----------identification---------------
       if registre.type == "signe identification"
           intnom=bi2de(flip(X(i:i+5)));
           for i=41:6:87
               c='';
              if(intnom>0 && intnom<28)
                   c=char(intnom + 64);
              elseif(intnom>48 && intnom<58)
                    c=char(intnom);
              elseif(intnom==32)
                    c=char(32);
                    
              end
              nom=strcat(nom,c);
            end
            registre.nom=nom;
        end
       %--------------------- position au vol----------------------
        if registre.type == "position au vol"
            %decodage de l'altitude
            somme=X(41)*2^10 +X(42)*2^9 +X(43)*2^8 +X(44)*2^7 +X(45)*2^6 +X(46)*2^5 +X(47)*2^4 +X(49)*2^3 +X(50)*2^2 +X(51)*2 +X(52);
            altitude=somme*25-1000;
            registre.altitude=altitude;
            %décodege de la latitude 
            Dlat=360/(4*15 - X(54));
            LAT=bi2de(fliplr(X(55:71)));
            j=floor(LatRef/Dlat) +floor( (0.5 + (mod(LatRef,Dlat)/Dlat) - (LAT/(2^17))));
            lat=Dlat*(j+ (LAT/2^17));
            registre.latitude=lat;
            %décodage de longitude 
            %% implimentation de la fonction Nl
            LON=bi2de(fliplr(X(72:88)));
            N_lat=cprNL(lat);
            if N_lat-X(54)>0
                     Dlon=360/(N_lat-X(54));
            elseif N_lat-X(54)==0
                     Dlon=360;
            end
            %% calcule de m
            m=floor(Lonref/Dlon) + floor((0.5 + (mod(Lonref,Dlon)/Dlon) - (LON/(2^17)) ));
            lon=Dlon*(m+LON/(2^17));
            registre.longitude=lon;
         end
    end 
end






            


               
            




                
                

