% Script para VISUALIZAR o algoritmo Simulated Annealing (SA),
% iteração a iteração (por ciclo de temperatura).
clear;
clc;
close all;

% --- Parâmetros do Algoritmo (Valores de exemplo) ---
% Parâmetros sugeridos no protocolo [cite: 31]
T_inicial = 100;    % Temperatura inicial
T_min = 0.1;      % Temperatura mínima (critério de paragem)
alfa = 0.98;      % Fator de decaimento (0.8 = rápido, 0.99 = lento)
nRep = 50;        % N. de repetições por temperatura
STEP_SIZE = 0.1;    % Tamanho do passo
PAUSE_TIME = 0.01;  % Pausa entre CADA ciclo de temperatura

% (Assuma que as funções fobj_F1 e fobj_F2 estão definidas ou no path)

% =========================================================================
% --- Visualização para a FUNÇÃO 1 ---
% =========================================================================
fprintf('A visualizar Simulated Annealing para a Função 1...\n');
fprintf('Pressione qualquer tecla para avançar para a F2.\n');

% Intervalos da F1
interval_min_F1 = -2.048;
interval_max_F1 = 2.048;

% 1. Desenhar o "mapa" da função
figure('Name', 'Visualização Simulated Annealing - Função 1');
[X, Y] = meshgrid(linspace(interval_min_F1, interval_max_F1, 100));
fobj_F1_vec = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
Z = fobj_F1_vec(X, Y);
contourf(X, Y, Z, 20);
colorbar;
hold on;
axis equal;
title('Função 1: Percurso do Simulated Annealing');
xlabel('x1');
ylabel('x2');

% Marcar o mínimo global REAL
plot(0, 0, 'k+', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Mínimo Global (Real)');

% 2. Gerar solução inicial aleatória
current_sol_x = interval_min_F1 + (interval_max_F1 - interval_min_F1) * rand();
current_sol_y = interval_min_F1 + (interval_max_F1 - interval_min_F1) * rand();
current_fit = fobj_F1_vec(current_sol_x, current_sol_y);

global_best_fit_F1 = current_fit;
global_best_sol_F1 = [current_sol_x, current_sol_y];

T = T_inicial;

% Handles (referências) para os plots que vamos animar
path_x = [current_sol_x];
path_y = [current_sol_y];
h_path = plot(path_x, path_y, 'r.-', 'LineWidth', 1, 'DisplayName', 'Caminho (por Temp.)');
h_current = plot(current_sol_x, current_sol_y, 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Posição Atual');

% 3. Loop Principal - ARREFECIMENTO
while T > T_min
    
    % 4. Loop Interno - Repetições na mesma temperatura
    for i = 1:nRep
        
        % Gerar vizinho
        neighbor_x = current_sol_x + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_y = current_sol_y + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_x = max(interval_min_F1, min(interval_max_F1, neighbor_x));
        neighbor_y = max(interval_min_F1, min(interval_max_F1, neighbor_y));
        
        neighbor_fit = fobj_F1_vec(neighbor_x, neighbor_y);
        
        % Calcular dE 
        dE = neighbor_fit - current_fit;
        
        % Decisão do SA
        if (dE < 0)
            % Aceita melhor
            current_sol_x = neighbor_x;
            current_sol_y = neighbor_y;
            current_fit = neighbor_fit;
            
            % Atualizar melhor global
            if current_fit < global_best_fit_F1
                global_best_fit_F1 = current_fit;
                global_best_sol_F1 = [current_sol_x, current_sol_y];
            end
        else
            % Aceita pior com probabilidade p
            p = exp(-dE / T); % 
            if (rand() < p)
                current_sol_x = neighbor_x;
                current_sol_y = neighbor_y;
                current_fit = neighbor_fit;
            end
        end
    end % Fim do loop nRep
    
    % --- AQUI ACONTECE A ANIMAÇÃO (1x por ciclo de Temp.) ---
    path_x(end+1) = current_sol_x;
    path_y(end+1) = current_sol_y;
    
    set(h_path, 'XData', path_x, 'YData', path_y);
    set(h_current, 'XData', current_sol_x, 'YData', current_sol_y);
    
    % Bónus: Mudar a cor do marcador de Vermelho (quente) para Azul (frio)
    temp_ratio = max(0, (T - T_min) / (T_inicial - T_min)); % Normaliza 0-1
    set(h_current, 'MarkerFaceColor', [temp_ratio, 0, 1-temp_ratio]);
    
    drawnow;
    pause(PAUSE_TIME);
    % --- FIM DA ANIMAÇÃO ---
    
    % 5. Arrefecer
    T = T * alfa; % [cite: 31]
    
end % Fim do loop de arrefecimento

% 6. Marcar o melhor global ENCONTRADO
plot(global_best_sol_F1(1), global_best_sol_F1(2), 'c*', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Melhor Global Encontrado');
legend('Location', 'northwest');
hold off;

% =========================================================================
% --- Visualização para a FUNÇÃO 2 (Rastrigin) ---
% =========================================================================
pause; % Espera que o utilizador pressione uma tecla
fprintf('A visualizar Simulated Annealing para a Função 2...\n');

% (Implementação idêntica à da F1, mas com os limites e a fobj_F2)
% ...
% (Isto fica como exercício, é só copiar a secção da F1 e trocar
%  'interval_min_F1' por 'interval_min_F2', 'fobj_F1' por 'fobj_F2', etc.)
% ...

fprintf('Visualização concluída.\n');