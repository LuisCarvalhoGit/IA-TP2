% Script: run_PSO_2D.m
% Visualização 2D (Vista de Topo) + Gráficos de Análise Separados
clear; clc; close all;

% --- CONFIGURAÇÕES ---
OPCAO_FUNCAO = 2;  % 1 ou 2
VELOCIDADE = 2;    % 1=Rápido, 2=Normal

SWARM_SIZE = 40;   
MAX_IT = 80;       

% Cores Dark Mode
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if VELOCIDADE == 1, PAUSE_TIME = 0.01; else, PAUSE_TIME = 0.05; end

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

fprintf('=== Visualização 2D PSO: %s ===\n', nome);

% --- AMBIENTE 2D (ANIMAÇÃO) ---
figure('Name', ['Animação 2D - ' nome], 'Position', [50, 100, 700, 600]);
[X, Y] = meshgrid(linspace(lim_min, lim_max, 100));
Z = fobj(X, Y);

contourf(X, Y, Z, n_cnt); colormap jet; colorbar; hold on; 
axis equal; axis([lim_min lim_max lim_min lim_max]);
xlabel('x1'); ylabel('x2'); title([nome ' - Inicialização']);
plot(0, 0, 'w+', 'MarkerSize', 15, 'LineWidth', 2); 

% --- INICIALIZAÇÃO PSO ---
num_vars = 2;
vmax = 0.15 * (lim_max - lim_min);
c1 = 2.0; c2 = 2.0;

pos = lim_min + (lim_max - lim_min) * rand(SWARM_SIZE, num_vars);
vel = zeros(SWARM_SIZE, num_vars);

pbest_pos = pos;
pbest_val = inf(SWARM_SIZE, 1);
gbest_val = Inf;
gbest_sol = zeros(1, num_vars);

hist_gbest_val = zeros(1, MAX_IT);
hist_gbest_pos = zeros(MAX_IT, 2);

for i = 1:SWARM_SIZE
    val = fobj(pos(i,1), pos(i,2));
    pbest_val(i) = val;
    if val < gbest_val
        gbest_val = val; gbest_sol = pos(i,:);
    end
end

h_swarm = plot(pos(:,1), pos(:,2), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 6);
h_best = plot(gbest_sol(1), gbest_sol(2), 'p', ...
    'MarkerSize', 18, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

% --- LOOP PRINCIPAL ---
for it = 1:MAX_IT
    w = 0.9 - ((0.9 - 0.4) * it / MAX_IT);
    
    for i = 1:SWARM_SIZE
        r1 = rand(1, num_vars); r2 = rand(1, num_vars);
        vel(i,:) = w*vel(i,:) + c1*r1.*(pbest_pos(i,:)-pos(i,:)) + c2*r2.*(gbest_sol-pos(i,:));
        vel(i,:) = max(min(vel(i,:), vmax), -vmax);
        pos(i,:) = pos(i,:) + vel(i,:);
        pos(i,:) = max(min(pos(i,:), lim_max), lim_min);
        
        curr_val = fobj(pos(i,1), pos(i,2));
        if curr_val < pbest_val(i)
            pbest_val(i) = curr_val; pbest_pos(i,:) = pos(i,:);
            if curr_val < gbest_val
                gbest_val = curr_val; gbest_sol = pos(i,:);
            end
        end
    end
    
    hist_gbest_val(it) = gbest_val;
    hist_gbest_pos(it, :) = gbest_sol;
    
    set(h_swarm, 'XData', pos(:,1), 'YData', pos(:,2));
    set(h_best, 'XData', gbest_sol(1), 'YData', gbest_sol(2));
    title(sprintf('%s\nÉpoca: %d/%d | gBest: %.6f', nome, it, MAX_IT, gbest_val));
    drawnow;
    pause(PAUSE_TIME);
end

fprintf('Animação concluída. A gerar gráficos de análise...\n');

% =========================================================================
% --- GRÁFICOS FINAIS INDEPENDENTES (DARK MODE) ---
% =========================================================================

% FIGURA 1: Evolução das Variáveis
figure('Name', 'Evolução das Variáveis', 'Color', BG_COLOR);
plot(1:MAX_IT, hist_gbest_pos(:,1), 'c-', 'LineWidth', 1.5, 'DisplayName', 'x1'); hold on;
plot(1:MAX_IT, hist_gbest_pos(:,2), 'y-', 'LineWidth', 1.5, 'DisplayName', 'x2');
yline(0, 'w--');
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
title('Evolução das Variáveis x1 e x2', 'Color', AX_COLOR);
xlabel('Geração', 'Color', AX_COLOR); ylabel('Valor', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% FIGURA 2: Convergência do Custo
figure('Name', 'Convergência do Custo', 'Color', BG_COLOR);
plot(1:MAX_IT, hist_gbest_val, 'g-', 'LineWidth', 2);
title('Convergência da Função Custo', 'Color', AX_COLOR);
xlabel('Geração', 'Color', AX_COLOR); ylabel('Fitness f(x)', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;