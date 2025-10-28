% Função Objectivo- Função 1

function F = fobj_F1(x,y)

  F=0.5+ ((sin(sqrt(x^2+y^2)))^2-0.5)/((1+0.001*(x^2+y^2))^2);


end