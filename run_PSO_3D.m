% Visualização 3D (Animação) + Gráficos de Análise Separados
clear; clc; close all;

% --- CONFIGURAÇÕES ---
OPCAO_FUNCAO = 2;  % 1 (Schaffer) ou 2 (Rastrigin)
VELOCIDADE = 2;    % 1 = Rápido, 2 = Normal

% Parâmetros do PSO
SWARM_SIZE = 30;   
MAX_IT = 80;       

% Cores Dark Mode
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if VELOCIDADE == 1, PAUSE_TIME = 0.01; else, PAUSE_TIME = 0.05; end

if OPCAO_FUNCAO == 1
    nome = 'Função 1 (Schaffer)';
    lim_min = -2.048; lim_max = 2.048;
    fobj = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
    z_lift = 0.01;
else
    nome = 'Função 2 (Rastrigin)';
    lim_min = -5.12; lim_max = 5.12;
    fobj = @(x,y) 20 + (x.^2 - 10*cos(2*pi.*x)) + (y.^2 - 10*cos(2*pi.*y));
    z_lift = 2;
end

fprintf('=== Visualização 3D PSO: %s ===\n', nome);

% --- AMBIENTE 3D (ANIMAÇÃO) ---
figure('Name', ['Animação 3D - ' nome], 'Position', [50, 100, 800, 600]);
[X, Y] = meshgrid(linspace(lim_min, lim_max, 80));
Z = fobj(X, Y);

surf(X, Y, Z, 'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
colormap jet; hold on; axis tight; grid on;
view(45, 40); xlabel('x'); ylabel('y'); zlabel('Fitness');
title(nome); rotate3d on;

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

% Históricos para os gráficos finais
hist_gbest_val = zeros(1, MAX_IT);
hist_gbest_pos = zeros(MAX_IT, 2);

% Avaliação Inicial
for i = 1:SWARM_SIZE
    val = fobj(pos(i,1), pos(i,2));
    pbest_val(i) = val;
    if val < gbest_val
        gbest_val = val; gbest_sol = pos(i,:);
    end
end

h_swarm = scatter3(pos(:,1), pos(:,2), pbest_val + z_lift, 50, 'k', 'filled');
h_best = plot3(gbest_sol(1), gbest_sol(2), gbest_val + z_lift, 'p', ...
    'MarkerSize', 20, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k');

% LOOP PRINCIPAL 
for it = 1:MAX_IT
    w = 0.9 - ((0.9 - 0.4) * it / MAX_IT);
    vals_plot = zeros(SWARM_SIZE, 1);
    
    for i = 1:SWARM_SIZE
        r1 = rand(1, num_vars); r2 = rand(1, num_vars);
        vel(i,:) = w*vel(i,:) + c1*r1.*(pbest_pos(i,:)-pos(i,:)) + c2*r2.*(gbest_sol-pos(i,:));
        vel(i,:) = max(min(vel(i,:), vmax), -vmax);
        pos(i,:) = pos(i,:) + vel(i,:);
        pos(i,:) = max(min(pos(i,:), lim_max), lim_min);
        
        curr_val = fobj(pos(i,1), pos(i,2));
        vals_plot(i) = curr_val;
        
        if curr_val < pbest_val(i)
            pbest_val(i) = curr_val; pbest_pos(i,:) = pos(i,:);
            if curr_val < gbest_val
                gbest_val = curr_val; gbest_sol = pos(i,:);
            end
        end
    end
    
    hist_gbest_val(it) = gbest_val;
    hist_gbest_pos(it, :) = gbest_sol;
    
    set(h_swarm, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', vals_plot + z_lift);
    set(h_best, 'XData', gbest_sol(1), 'YData', gbest_sol(2), 'ZData', gbest_val + z_lift);
    title(sprintf('%s\nÉpoca: %d/%d | gBest: %.6f', nome, it, MAX_IT, gbest_val));
    drawnow;
    pause(PAUSE_TIME);
end

fprintf('Animação concluída. A gerar gráficos de análise...\n');

% =========================================================================
% --- GRÁFICOS FINAIS ---
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