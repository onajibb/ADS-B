
function Y=intercorr(r_l, preambule,Fse)   %r_l est le buffer
    Y= sum(r_l.* preambule)*Fse / (sqrt(sum(abs(preambule).^2)) * sqrt(sum(r_l.^2))*Fse); 
end