% Função Objectivo- Função 1

function F = fobj_F2(x,y)

  F=10 + x^2 - 10*cos(2*pi*x) + 10+ y^2 - 10*cos(2*pi*y);

end