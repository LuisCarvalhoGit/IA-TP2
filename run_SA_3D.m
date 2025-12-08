% Visualização 3D do Simulated Annealing + Gráficos de Análise
% Fundo Escuro (Dark Mode)
clear; clc; close all;

% --- CONFIGURAÇÕES ---
OPCAO_FUNCAO = 2;  % 1 ou 2
VELOCIDADE = 2;    % 1=Rápido, 2=Normal

T_inicial = 100;
T_min = 0.001;
alfa = 0.90;      
nRep = 20;
STEP_SIZE = 0.2; 

% Cores Dark Mode
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if VELOCIDADE == 1, PAUSE_TIME = 0.001; else, PAUSE_TIME = 0.05; end

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

fprintf('=== Visualização 3D SA: %s ===\n', nome);

% --- AMBIENTE 3D ---
figure('Name', ['Animação 3D SA - ' nome], 'Position', [50, 100, 800, 600]);
[X, Y] = meshgrid(linspace(lim_min, lim_max, 80));
Z = fobj(X, Y);

surf(X, Y, Z, 'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
colormap jet; hold on; axis tight; grid on;
view(45, 40); xlabel('x'); ylabel('y'); zlabel('Fitness');
title(nome); rotate3d on;

% --- INICIALIZAÇÃO SA ---
curr_x = lim_min + (lim_max - lim_min) * rand();
curr_y = lim_min + (lim_max - lim_min) * rand();
curr_fit = fobj(curr_x, curr_y);

best_x = curr_x; best_y = curr_y; best_fit = curr_fit;

hist_T = [];
hist_best = [];
hist_curr = [];
iteracoes = [];
it_count = 0;

h_path = plot3(curr_x, curr_y, curr_fit+z_lift, 'k-', 'LineWidth', 1);
h_curr = plot3(curr_x, curr_y, curr_fit+z_lift, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
h_best = plot3(best_x, best_y, best_fit+z_lift, 'p', 'MarkerSize', 20, 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k');

path_x = [curr_x]; path_y = [curr_y]; path_z = [curr_fit+z_lift];

T = T_inicial;

% LOOP PRINCIPAL
while T > T_min
    it_count = it_count + 1;
    
    for i = 1:nRep
        nx = curr_x + (rand() - 0.5) * 2 * STEP_SIZE;
        ny = curr_y + (rand() - 0.5) * 2 * STEP_SIZE;
        nx = max(lim_min, min(lim_max, nx));
        ny = max(lim_min, min(lim_max, ny));
        
        nfit = fobj(nx, ny);
        dE = nfit - curr_fit;
        
        accept = false;
        if dE < 0
            accept = true;
            if nfit < best_fit
                best_fit = nfit; best_x = nx; best_y = ny;
                set(h_best, 'XData', best_x, 'YData', best_y, 'ZData', best_fit+z_lift);
            end
        else
            p = exp(-dE / T);
            if rand() < p
                accept = true;
            end
        end
        
        if accept
            curr_x = nx; curr_y = ny; curr_fit = nfit;
        end
    end
    
    % Atualizar Caminho
    path_x(end+1) = curr_x; path_y(end+1) = curr_y; path_z(end+1) = curr_fit+z_lift;
    set(h_path, 'XData', path_x, 'YData', path_y, 'ZData', path_z);
    set(h_curr, 'XData', curr_x, 'YData', curr_y, 'ZData', curr_fit+z_lift);
    
    % Guardar Dados
    hist_T(end+1) = T;
    hist_best(end+1) = best_fit;
    hist_curr(end+1) = curr_fit;
    iteracoes(end+1) = it_count;
    
    title(sprintf('Temp: %.4f | Melhor: %.5f', T, best_fit));
    drawnow;
    pause(PAUSE_TIME);
    
    T = T * alfa;
end

fprintf('SA Concluído. A gerar gráficos...\n');

% =========================================================================
% --- GRÁFICOS DE ANÁLISE ---
% =========================================================================

% FIGURA 1: Temperatura
figure('Name', 'Curva de Temperatura', 'Color', BG_COLOR);
plot(iteracoes, hist_T, 'r-', 'LineWidth', 2);
title('Decaimento da Temperatura', 'Color', AX_COLOR);
xlabel('Ciclos', 'Color', AX_COLOR); ylabel('Temperatura (T)', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% FIGURA 2: Dinâmica
figure('Name', 'Dinâmica de Convergência', 'Color', BG_COLOR);
plot(iteracoes, hist_curr, 'c-', 'LineWidth', 1, 'DisplayName', 'Solução Atual (Instável)'); hold on;
plot(iteracoes, hist_best, 'g-', 'LineWidth', 2, 'DisplayName', 'Melhor Global');
title('Dinâmica: Aceitação de Erros vs Otimização', 'Color', AX_COLOR);
xlabel('Ciclos', 'Color', AX_COLOR); ylabel('Fitness', 'Color', AX_COLOR);
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;