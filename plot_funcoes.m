% Script para plotar as funções de benchmark do Trabalho 2

% --- Plot para Função 1 ---
figure; % Cria uma nova janela de figura

% Define o intervalo conforme a legenda da imagem a) [-2, 2] [cite: 93]
intervalo1_min = -2;
intervalo1_max = 2;

% Cria uma grelha (mesh) de pontos
[X, Y] = meshgrid(linspace(intervalo1_min, intervalo1_max, 100));

% Calcula o valor de Z (F) para cada ponto (X,Y)
% Isto requer que a função fobj_F1 esteja vetorizada (use .*, ./, .^)
% Se fobj_F1 não estiver vetorizada, usamos um loop:
Z = zeros(size(X));
for i = 1:size(X, 1)
    for j = 1:size(X, 2)
        Z(i,j) = fobj_F1(X(i,j), Y(i,j));
    end
end

% 'mesh' é o equivalente mais próximo do 'wireframe' do PDF
mesh(X, Y, Z);
colormap('gray'); % Para um visual P&B similar ao PDF

% Define os rótulos dos eixos conforme o PDF
xlabel('x1');
ylabel('x2');
zlabel('f');
title('a) Função 1: Intervalo [-2,2]');

% --- Plot para Função 2 ---
figure; % Cria uma nova janela de figura

% Define o intervalo conforme a legenda da imagem b) [-5, 5] 
intervalo2_min = -5;
intervalo2_max = 5;

% Cria uma grelha (mesh) de pontos
[X, Y] = meshgrid(linspace(intervalo2_min, intervalo2_max, 100));

% Calcula o valor de Z (F) para cada ponto (X,Y)
Z = zeros(size(X));
for i = 1:size(X, 1)
    for j = 1:size(X, 2)
        Z(i,j) = fobj_F2(X(i,j), Y(i,j));
    end
end

% 'mesh' é o equivalente mais próximo do 'wireframe' do PDF
mesh(X, Y, Z);
colormap('gray');

% Define os rótulos dos eixos conforme o PDF
xlabel('x1');
ylabel('x2');
zlabel('f');
title('b) Função 2: Intervalo [-5,5]');