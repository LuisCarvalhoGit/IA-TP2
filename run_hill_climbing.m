% Script principal para executar o algoritmo Subida da Colina com
% Reinicialização Múltipla  nas funções F1 e F2.

clear;
clc;
close all;

% --- Parâmetros do Algoritmo ---
% (Estes valores podem e devem ser ajustados para o vosso relatório)
NUM_RESTARTS = 50;   % Número de reinicializações
ITERATIONS = 100;    % Número de passos em cada subida (para achar o min. local)
STEP_SIZE = 0.1;     % Tamanho do "passo" ao procurar vizinhos

% --- Execução para a Função 1 ---
fprintf('A executar Multiple Restart Hill-Climbing para a Função 1...\n');

% Intervalos conforme definição da função 1 no PDF [cite: 11]
interval_min_F1 = -2.048;
interval_max_F1 = 2.048;

% Chama o algoritmo
[sol_F1, fit_F1] = multiple_restart_hill_climbing(@fobj_F1, ...
    interval_min_F1, interval_max_F1, NUM_RESTARTS, ITERATIONS, STEP_SIZE);

% Apresenta resultados para F1
fprintf('Resultado para Função 1:\n');
fprintf('  Mínimo Global encontrado: f(%.5f, %.5f) = %.5f\n', sol_F1(1), sol_F1(2), fit_F1);
fprintf('  (O mínimo global real é 0.0 em (0,0) )\n\n');


% --- Execução para a Função 2 ---
fprintf('A executar Multiple Restart Hill-Climbing para a Função 2...\n');

% Intervalos conforme definição da função 2 no PDF [cite: 14]
interval_min_F2 = -5.12;
interval_max_F2 = 5.12;

% Chama o algoritmo
[sol_F2, fit_F2] = multiple_restart_hill_climbing(@fobj_F2, ...
    interval_min_F2, interval_max_F2, NUM_RESTARTS, ITERATIONS, STEP_SIZE);

% Apresenta resultados para F2
fprintf('Resultado para Função 2:\n');
fprintf('  Mínimo Global encontrado: f(%.5f, %.5f) = %.5f\n', sol_F2(1), sol_F2(2), fit_F2);
fprintf('  (O mínimo global real é 0.0 em (0,0) )\n');