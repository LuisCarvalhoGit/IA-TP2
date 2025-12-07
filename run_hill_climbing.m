% Script: run_hill_climbing_2D.m
% Visualização 2D (Vista de Topo) do Multiple Restart Hill Climbing
% Inclui Animação + Gráficos de Análise Finais (Dark Mode)
clear; clc; close all;

% =========================================================================
% --- CONFIGURAÇÕES ---
% =========================================================================
OPCAO_FUNCAO = 2;  % 1 (Schaffer) ou 2 (Rastrigin)
VELOCIDADE = 1;    % 1 = Rápido, 2 = Normal

% Parâmetros do Hill Climbing
NUM_RESTARTS = 10;   % Quantas vezes reinicia
ITERATIONS = 50;     % Passos por reinicialização
STEP_SIZE = 0.1;     % Tamanho do passo

% Cores Dark Mode
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

% Configuração de Tempo
if VELOCIDADE == 1
    PAUSE_TIME = 0.001; 
else
    PAUSE_TIME = 0.02; 
end

% Configuração da Função
if OPCAO_FUNCAO == 1
    nome = 'Função 1 (Schaffer)';
    lim_min = -2.048; lim_max = 2.048;
    fobj = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
    n_cnt = 40;
else
    nome = 'Função 2 (Rastrigin)';
    lim_min = -5.12; lim_max = 5.12;
    fobj = @(x,y) 20 + (x.^2 - 10*cos(2*pi.*x)) + (y.^2 - 10*cos(2*pi.*y));
    n_cnt = 30;
end

fprintf('=== Visualização 2D HC: %s ===\n', nome);

% =========================================================================
% --- AMBIENTE 2D (ANIMAÇÃO) ---
% =========================================================================
figure('Name', ['Animação 2D HC - ' nome], 'Position', [50, 100, 700, 600]);

% Criar Mapa de Contorno
[X, Y] = meshgrid(linspace(lim_min, lim_max, 100));
Z = fobj(X, Y);

contourf(X, Y, Z, n_cnt); colormap jet; colorbar; hold on; 
axis equal; axis([lim_min lim_max lim_min lim_max]);
xlabel('x1'); ylabel('x2'); title([nome ' - Inicialização']);

% Marcar Mínimo Global Real
plot(0, 0, 'w+', 'MarkerSize', 15, 'LineWidth', 2); 

% --- INICIALIZAÇÃO GLOBAL ---
global_best_fit = Inf;
global_best_sol = [NaN, NaN];

% Históricos para gráficos finais
total_steps = NUM_RESTARTS * ITERATIONS;
hist_global_val = zeros(1, total_steps);
hist_global_pos = zeros(total_steps, 2);
counter = 0;

% Elementos Gráficos Móveis
% Ponto Atual (Círculo Vermelho)
h_curr = plot(0, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
% Rastro Atual (Linha Preta)
h_path = plot(0, 0, 'k-', 'LineWidth', 1);
% Melhor Global Encontrado (Estrela Magenta)
h_best = plot(0, 0, 'p', 'MarkerSize', 18, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

% =========================================================================
% --- LOOP DE RESTARTS ---
% =========================================================================
for r = 1:NUM_RESTARTS
    
    % 1. Reinicialização (Ponto Aleatório)
    curr_x = lim_min + (lim_max - lim_min) * rand();
    curr_y = lim_min + (lim_max - lim_min) * rand();
    curr_fit = fobj(curr_x, curr_y);
    
    % Marcar o início deste restart (X Branco pequeno)
    plot(curr_x, curr_y, 'wx', 'MarkerSize', 8);
    
    path_x = [curr_x]; path_y = [curr_y];
    
    % 2. Subida da Colina (Descida do Vale)
    for i = 1:ITERATIONS
        counter = counter + 1;
        
        % Gerar Vizinho
        nx = curr_x + (rand() - 0.5) * 2 * STEP_SIZE;
        ny = curr_y + (rand() - 0.5) * 2 * STEP_SIZE;
        
        % Limites
        nx = max(lim_min, min(lim_max, nx));
        ny = max(lim_min, min(lim_max, ny));
        
        nfit = fobj(nx, ny);
        
        % Aceita APENAS se for melhor
        if nfit < curr_fit
            curr_x = nx; curr_y = ny; curr_fit = nfit;
            path_x(end+1) = curr_x; 
            path_y(end+1) = curr_y;
        end
        
        % Atualizar Melhor Global
        if curr_fit < global_best_fit
            global_best_fit = curr_fit;
            global_best_sol = [curr_x, curr_y];
            set(h_best, 'XData', global_best_sol(1), 'YData', global_best_sol(2));
        end
        
        % Guardar histórico
        hist_global_val(counter) = global_best_fit;
        hist_global_pos(counter, :) = global_best_sol;
        
        % Atualizar Animação
        set(h_curr, 'XData', curr_x, 'YData', curr_y);
        set(h_path, 'XData', path_x, 'YData', path_y);
        
        title(sprintf('Restart %d/%d | Iter: %d | Global Best: %.5f', r, NUM_RESTARTS, i, global_best_fit));
        drawnow;
        
        % Pausa (apenas a cada poucos frames para não travar muito se for rápido)
        if VELOCIDADE == 2 || mod(i, 5) == 0
            pause(PAUSE_TIME);
        end
    end
    
    % Marcar o final deste restart (onde ficou preso) - Quadrado preto
    plot(curr_x, curr_y, 'ks', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
end

fprintf('HC Concluído. A gerar gráficos de análise...\n');

% =========================================================================
% --- GRÁFICOS FINAIS INDEPENDENTES (DARK MODE) ---
% =========================================================================

% FIGURA 1: Evolução das Variáveis (Do Melhor Global)
figure('Name', 'Evolução das Variáveis (HC)', 'Color', BG_COLOR);
plot(1:total_steps, hist_global_pos(:,1), 'c-', 'LineWidth', 1.5, 'DisplayName', 'x1'); hold on;
plot(1:total_steps, hist_global_pos(:,2), 'y-', 'LineWidth', 1.5, 'DisplayName', 'x2');
yline(0, 'w--');
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
title('Evolução das Variáveis (Melhor Global)', 'Color', AX_COLOR);
xlabel('Iterações Totais (Acumuladas)', 'Color', AX_COLOR); ylabel('Valor', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% FIGURA 2: Convergência do Custo
figure('Name', 'Convergência do Custo (HC)', 'Color', BG_COLOR);
plot(1:total_steps, hist_global_val, 'g-', 'LineWidth', 2);
title('Convergência da Função Custo (Melhor Global)', 'Color', AX_COLOR);
xlabel('Iterações Totais (Acumuladas)', 'Color', AX_COLOR); ylabel('Fitness f(x)', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;