% Visualização 3D do Multiple Restart Hill Climbing
% Animação + Gráficos de Análise 
clear; clc; close all;

% --- CONFIGURAÇÕES ---
OPCAO_FUNCAO = 1;   % 1 (Schaffer) ou 2 (Rastrigin)
VELOCIDADE = 2;     % 1=Rápido, 2=Normal

% Parametros iniciais
NUM_RESTARTS = 10;  
ITERATIONS = 50;    
STEP_SIZE = 0.1;    

% Cores 
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if VELOCIDADE == 1, PAUSE_TIME = 0.001; else, PAUSE_TIME = 0.02; end

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

fprintf('=== Visualização 3D HC: %s ===\n', nome);

% --- AMBIENTE 3D ---
figure('Name', ['Animação 3D HC - ' nome], 'Position', [50, 100, 800, 600]);
[X, Y] = meshgrid(linspace(lim_min, lim_max, 80));
Z = fobj(X, Y);

surf(X, Y, Z, 'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
colormap jet; hold on; axis tight; grid on;
view(45, 40); xlabel('x'); ylabel('y'); zlabel('Fitness');
title(nome); rotate3d on;

% --- INICIALIZAÇÃO GLOBAL ---
global_best_fit = Inf;
global_best_sol = [NaN, NaN];

% Históricos para gráficos finais
total_steps = NUM_RESTARTS * ITERATIONS;
hist_global_val = zeros(1, total_steps);
hist_global_pos = zeros(total_steps, 2);
counter = 0;

% Elementos Gráficos
h_curr = plot3(0,0,0, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
h_path = plot3(0,0,0, 'k-', 'LineWidth', 1);
h_best = plot3(0,0,0, 'p', 'MarkerSize', 20, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k');

%  LOOP DE RESTARTS 
for r = 1:NUM_RESTARTS
    
    % Reinicialização Aleatória
    curr_x = lim_min + (lim_max - lim_min) * rand();
    curr_y = lim_min + (lim_max - lim_min) * rand();
    curr_fit = fobj(curr_x, curr_y);
    
    % Limpar rastro visual para o novo restart
    path_x = [curr_x]; path_y = [curr_y]; path_z = [curr_fit + z_lift];
    
    for i = 1:ITERATIONS
        counter = counter + 1;
        
        % Gerar Vizinho
        nx = curr_x + (rand() - 0.5) * 2 * STEP_SIZE;
        ny = curr_y + (rand() - 0.5) * 2 * STEP_SIZE;
        nx = max(lim_min, min(lim_max, nx));
        ny = max(lim_min, min(lim_max, ny));
        
        nfit = fobj(nx, ny);
        
        % Aceita se for melhor
        if nfit < curr_fit
            curr_x = nx; curr_y = ny; curr_fit = nfit;
            % Atualizar rastro apenas se moveu
            path_x(end+1) = curr_x; path_y(end+1) = curr_y; path_z(end+1) = curr_fit + z_lift;
        end
        
        % Atualizar Melhor Global
        if curr_fit < global_best_fit
            global_best_fit = curr_fit;
            global_best_sol = [curr_x, curr_y];
            set(h_best, 'XData', global_best_sol(1), 'YData', global_best_sol(2), ...
                'ZData', global_best_fit + z_lift);
        end
        
        % Guardar histórico global
        hist_global_val(counter) = global_best_fit;
        hist_global_pos(counter, :) = global_best_sol;
        
        % Atualizar Animação
        set(h_curr, 'XData', curr_x, 'YData', curr_y, 'ZData', curr_fit + z_lift);
        set(h_path, 'XData', path_x, 'YData', path_y, 'ZData', path_z);
        
        title(sprintf('Restart %d/%d | Iter: %d | Global Best: %.5f', r, NUM_RESTARTS, i, global_best_fit));
        drawnow;
        if mod(i, 5) == 0 
            pause(PAUSE_TIME);
        end
    end
end

fprintf('HC Concluído. A gerar gráficos...\n');

% =========================================================================
% --- GRÁFICOS FINAIS ---
% =========================================================================

% FIGURA 1: Evolução das Variáveis (Do Melhor Global)
figure('Name', 'Evolução das Variáveis (Global Best)', 'Color', BG_COLOR);
plot(1:total_steps, hist_global_pos(:,1), 'c-', 'LineWidth', 1.5, 'DisplayName', 'x1'); hold on;
plot(1:total_steps, hist_global_pos(:,2), 'y-', 'LineWidth', 1.5, 'DisplayName', 'x2');
yline(0, 'w--');
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
title('Evolução das Variáveis (Melhor Global)', 'Color', AX_COLOR);
xlabel('Iterações Totais', 'Color', AX_COLOR); ylabel('Valor', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% FIGURA 2: Convergência do Custo
figure('Name', 'Convergência do Custo', 'Color', BG_COLOR);
plot(1:total_steps, hist_global_val, 'g-', 'LineWidth', 2);
title('Convergência da Função Custo (Melhor Global)', 'Color', AX_COLOR);
xlabel('Iterações Totais', 'Color', AX_COLOR); ylabel('Fitness f(x)', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;