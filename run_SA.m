% Visualização 2D do Simulated Annealing + Gráficos de Análise
clear; clc; close all;

% =========================================================================
% --- CONFIGURAÇÕES ---
% =========================================================================
OPCAO_FUNCAO = 2;  % 1 (Schaffer) ou 2 (Rastrigin)
VELOCIDADE = 1;    % 1 = Rápido (Resultado), 2 = Lento (Animação)

% Parâmetros do SA 
T_inicial = 1000;
T_min = 0.01;
alfa = 0.995;      
nRep = 20;
STEP_SIZE = 0.5; 

% Cores Dark Mode
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if VELOCIDADE == 1, PAUSE_TIME = 0.001; else, PAUSE_TIME = 0.05; end

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

fprintf('=== Visualização 2D SA: %s ===\n', nome);

% --- AMBIENTE 2D (ANIMAÇÃO) ---
figure('Name', ['Animação 2D SA - ' nome], 'Position', [50, 100, 700, 600]);
[X, Y] = meshgrid(linspace(lim_min, lim_max, 100));
Z = fobj(X, Y);

contourf(X, Y, Z, n_cnt); colormap jet; colorbar; hold on; 
axis equal; axis([lim_min lim_max lim_min lim_max]);
xlabel('x1'); ylabel('x2'); title([nome ' - Inicialização']);
plot(0, 0, 'w+', 'MarkerSize', 15, 'LineWidth', 2); % Alvo

% Inicialização Simulated Anealing
curr_x = lim_min + (lim_max - lim_min) * rand();
curr_y = lim_min + (lim_max - lim_min) * rand();
curr_fit = fobj(curr_x, curr_y);

best_x = curr_x; best_y = curr_y; best_fit = curr_fit;

% Históricos para gráficos finais
hist_T = [];
hist_best = [];
hist_curr = [];
iteracoes = [];
it_count = 0;

% Elementos Gráficos
h_path = plot(curr_x, curr_y, 'k-', 'LineWidth', 1);
h_curr = plot(curr_x, curr_y, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 6);
h_best = plot(best_x, best_y, 'p', 'MarkerSize', 18, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

path_x = [curr_x]; path_y = [curr_y];

T = T_inicial;

% LOOP PRINCIPAL 
while T > T_min
    it_count = it_count + 1;
    
    for i = 1:nRep
        % Vizinho 
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
                set(h_best, 'XData', best_x, 'YData', best_y);
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
    
    % Atualizar Caminho Visual
    path_x(end+1) = curr_x; path_y(end+1) = curr_y;
    set(h_path, 'XData', path_x, 'YData', path_y);
    set(h_curr, 'XData', curr_x, 'YData', curr_y);
    
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

% FIGURA 2: Dinâmica (Atual vs Melhor)
figure('Name', 'Dinâmica de Convergência', 'Color', BG_COLOR);
plot(iteracoes, hist_curr, 'c-', 'LineWidth', 1, 'DisplayName', 'Solução Atual (Instável)'); hold on;
plot(iteracoes, hist_best, 'g-', 'LineWidth', 2, 'DisplayName', 'Melhor Global');
title('Dinâmica: Aceitação de Erros vs Otimização', 'Color', AX_COLOR);
xlabel('Ciclos', 'Color', AX_COLOR); ylabel('Fitness', 'Color', AX_COLOR);
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;