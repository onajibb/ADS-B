

function synchronisation = synchronisation(r_l)
   P0 = [zeros(1,10) ones(1,10)]; 
   P1 = [ones(1,10) zeros(1,10)]; 
   S_p = [P1 P1 zeros(1,20) P0 P0 zeros(1,60)]'; 
   
   estimation = zeros(1,100);
   for i=1:100
       estimation(i) = sum(r_l(i:i+length(S_p)).* S_p) / sqrt(sum(abs(S_p).^2)) * sqrt(sum(r_l(i:i+length(S_p)).^2)); 
   end
   argmax = max(estimation); 
    synchronisation = argmax; 

end