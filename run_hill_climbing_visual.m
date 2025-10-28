% Script para VISUALIZAR o algoritmo Subida da Colina com
% Reinicialização Múltipla, iteração a iteração.

clear;
clc;
close all;

% --- Parâmetros do Algoritmo (Ajustados para visualização) ---
NUM_RESTARTS = 10;   % Reduzido para a visualização não ser muito longa
ITERATIONS = 100;    % Passos por cada subida
STEP_SIZE = 0.1;     % Tamanho do passo
PAUSE_TIME = 0.005;  % Pausa entre CADA passo (iteração). Aumente se for rápido demais.

% =========================================================================
% --- Visualização para a FUNÇÃO 1 ---
% =========================================================================
fprintf('A visualizar Hill Climbing para a Função 1...\n');
fprintf('Pressione qualquer tecla na janela de comando para avançar para a F2.\n');

% Intervalos da F1
interval_min_F1 = -2.048;
interval_max_F1 = 2.048;

% 1. Desenhar o "mapa" da função (gráfico de contorno)
figure('Name', 'Visualização Hill Climbing - Função 1');
[X, Y] = meshgrid(linspace(interval_min_F1, interval_max_F1, 100));

% Definir a função F1 de forma vetorizada (para o plot)
fobj_F1_vec = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
Z = fobj_F1_vec(X, Y);

% contourf = gráfico de contorno preenchido
contourf(X, Y, Z, 20); % 20 níveis de contorno
colorbar;
hold on;
axis equal; % Eixos com a mesma escala
title('Função 1: Percurso do Hill Climbing (10 Restarts)');
xlabel('x1');
ylabel('x2');

% Marcar o mínimo global REAL (para referência)
plot(0, 0, 'k+', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Mínimo Global (Real)');

% Inicializar o melhor global
global_best_fit_F1 = Inf;
global_best_sol_F1 = [NaN, NaN];

% 2. Loop de Reinicialização Múltipla
for r = 1:NUM_RESTARTS
    
    % 3. Gerar ponto inicial aleatório
    current_sol_x = interval_min_F1 + (interval_max_F1 - interval_min_F1) * rand();
    current_sol_y = interval_min_F1 + (interval_max_F1 - interval_min_F1) * rand();
    current_fit = fobj_F1(current_sol_x, current_sol_y); % Usa a função original (não-vetorizada)
    
    % Guardar o caminho (path) desta reinicialização
    path_x = [current_sol_x];
    path_y = [current_sol_y];
    
    % Plotar o ponto de início (Círculo Verde)
    h_start = plot(current_sol_x, current_sol_y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'DisplayName', 'Início (Restart)');
    
    % Handles (referências) para os plots que vamos animar
    h_path = plot(path_x, path_y, 'r.-', 'LineWidth', 1, 'DisplayName', 'Caminho HC'); % Linha do caminho
    h_current = plot(current_sol_x, current_sol_y, 'rs', 'MarkerSize', 8, 'DisplayName', 'Posição Atual'); % Posição atual
    
    % 4. Loop da Subida da Colina (iteração a iteração)
    for i = 1:ITERATIONS
        
        % Gerar vizinho
        neighbor_x = current_sol_x + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_y = current_sol_y + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_x = max(interval_min_F1, min(interval_max_F1, neighbor_x));
        neighbor_y = max(interval_min_F1, min(interval_max_F1, neighbor_y));
        
        neighbor_fit = fobj_F1(neighbor_x, neighbor_y);
        
        % Se o vizinho for melhor (minimizar), move-se
        if neighbor_fit < current_fit
            current_sol_x = neighbor_x;
            current_sol_y = neighbor_y;
            current_fit = neighbor_fit;
            
            % Adicionar ao caminho
            path_x(end+1) = current_sol_x;
            path_y(end+1) = current_sol_y;
            
            % --- AQUI ACONTECE A ANIMAÇÃO ---
            % Atualizar os dados dos plots
            set(h_path, 'XData', path_x, 'YData', path_y);
            set(h_current, 'XData', current_sol_x, 'YData', current_sol_y);
            
            % Forçar o MATLAB/Octave a redesenhar agora
            drawnow;
            pause(PAUSE_TIME); % Pausa para ser visível
            % --- FIM DA ANIMAÇÃO ---
        end
    end
    
    % Fim do HC (Mínimo Local Encontrado)
    % Marcar o mínimo local (X Vermelho)
    plot(current_sol_x, current_sol_y, 'rx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Mínimo Local');
    delete(h_current); % Apagar o quadrado da "posição atual"
    
    % Atualizar o melhor global
    if current_fit < global_best_fit_F1
        global_best_fit_F1 = current_fit;
        global_best_sol_F1 = [current_sol_x, current_sol_y];
    end
end

% 5. Marcar o melhor global ENCONTRADO (Estrela Ciano)
plot(global_best_sol_F1(1), global_best_sol_F1(2), 'c*', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Melhor Global Encontrado');

% Limpar legendas (para não ter 10x "Início", "Caminho", etc.)
h = findobj(gca, 'Type', 'line');
legend(h([end, end-1, end-2, end-3, end-4]), {'Mínimo Global (Real)', 'Início (Restart)', 'Caminho HC', 'Mínimo Local', 'Melhor Global Encontrado'}, 'Location', 'northwest');
hold off;


% =========================================================================
% --- Visualização para a FUNÇÃO 2 ---
% =========================================================================
pause; % Espera que o utilizador pressione uma tecla

fprintf('A visualizar Hill Climbing para a Função 2...\n');

% Intervalos da F2
interval_min_F2 = -5.12;
interval_max_F2 = 5.12;

% 1. Desenhar o "mapa" da função (gráfico de contorno)
figure('Name', 'Visualização Hill Climbing - Função 2');
[X, Y] = meshgrid(linspace(interval_min_F2, interval_max_F2, 100));

% Definir a função F2 de forma vetorizada (para o plot)
fobj_F2_vec = @(x,y) (10 + x.^2 - 10.*cos(2*pi.*x)) + (10 + y.^2 - 10.*cos(2*pi.*y));
Z = fobj_F2_vec(X, Y);

contourf(X, Y, Z, 30); % Mais níveis de contorno
colorbar;
hold on;
axis equal;
title('Função 2 (Rastrigin): Percurso do Hill Climbing (10 Restarts)');
xlabel('x1');
ylabel('x2');

% Marcar o mínimo global REAL (para referência)
plot(0, 0, 'k+', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Mínimo Global (Real)');

% Inicializar o melhor global
global_best_fit_F2 = Inf;
global_best_sol_F2 = [NaN, NaN];

% 2. Loop de Reinicialização Múltipla
for r = 1:NUM_RESTARTS
    
    % 3. Gerar ponto inicial aleatório
    current_sol_x = interval_min_F2 + (interval_max_F2 - interval_min_F2) * rand();
    current_sol_y = interval_min_F2 + (interval_max_F2 - interval_min_F2) * rand();
    current_fit = fobj_F2(current_sol_x, current_sol_y);
    
    path_x = [current_sol_x];
    path_y = [current_sol_y];
    
    % Plotar o ponto de início (Círculo Verde)
    h_start = plot(current_sol_x, current_sol_y, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'DisplayName', 'Início (Restart)');
    
    % Handles para animar
    h_path = plot(path_x, path_y, 'r.-', 'LineWidth', 1, 'DisplayName', 'Caminho HC');
    h_current = plot(current_sol_x, current_sol_y, 'rs', 'MarkerSize', 8, 'DisplayName', 'Posição Atual');
    
    % 4. Loop da Subida da Colina (iteração a iteração)
    for i = 1:ITERATIONS
        
        % Gerar vizinho
        neighbor_x = current_sol_x + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_y = current_sol_y + (rand() - 0.5) * 2 * STEP_SIZE;
        neighbor_x = max(interval_min_F2, min(interval_max_F2, neighbor_x));
        neighbor_y = max(interval_min_F2, min(interval_max_F2, neighbor_y));
        
        neighbor_fit = fobj_F2(neighbor_x, neighbor_y);
        
        % Se o vizinho for melhor (minimizar), move-se
        if neighbor_fit < current_fit
            current_sol_x = neighbor_x;
            current_sol_y = neighbor_y;
            current_fit = neighbor_fit;
            
            % Adicionar ao caminho
            path_x(end+1) = current_sol_x;
            path_y(end+1) = current_sol_y;
            
            % --- ANIMAÇÃO ---
            set(h_path, 'XData', path_x, 'YData', path_y);
            set(h_current, 'XData', current_sol_x, 'YData', current_sol_y);
            drawnow;
            pause(PAUSE_TIME);
            % --- FIM DA ANIMAÇÃO ---
        end
    end
    
    % Fim do HC (Mínimo Local Encontrado)
    plot(current_sol_x, current_sol_y, 'rx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Mínimo Local');
    delete(h_current);
    
    % Atualizar o melhor global
    if current_fit < global_best_fit_F2
        global_best_fit_F2 = current_fit;
        global_best_sol_F2 = [current_sol_x, current_sol_y];
    end
end

% 5. Marcar o melhor global ENCONTRADO
plot(global_best_sol_F2(1), global_best_sol_F2(2), 'c*', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Melhor Global Encontrado');

% Limpar legendas
h = findobj(gca, 'Type', 'line');
legend(h([end, end-1, end-2, end-3, end-4]), {'Mínimo Global (Real)', 'Início (Restart)', 'Caminho HC', 'Mínimo Local', 'Melhor Global Encontrado'}, 'Location', 'northwest');
hold off;

fprintf('Visualização concluída.\n');