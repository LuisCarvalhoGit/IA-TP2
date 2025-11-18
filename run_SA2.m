% =========================================================================
% --- Visualização para a FUNÇÃO 2 (Rastrigin) ---
% =========================================================================
pause; % Espera que o utilizador pressione uma tecla
fprintf('A visualizar Simulated Annealing para a Função 2...\n');

% Intervalos da F2 
interval_min_F2 = -5.12; 
interval_max_F2 = 5.12;

% 1. Desenhar o "mapa" da função
figure('Name', 'Visualização Simulated Annealing - Função 2');
[X, Y] = meshgrid(linspace(interval_min_F2, interval_max_F2, 100));

% Definir a função F2 de forma vetorizada 
% f2(x, y) = 20 + (x² - 10cos2πx) + (y² – 10cos2πy)
fobj_F2_vec = @(x,y) (20 + (x.^2 - 10*cos(2*pi.*x)) + (y.^2 - 10*cos(2*pi.*y)));

Z = fobj_F2_vec(X, Y);
contourf(X, Y, Z, 30); % Mais níveis de contorno
colorbar;
hold on;
axis equal;
title('Função 2 (Rastrigin): Percurso do Simulated Annealing'); % Título corrigido
xlabel('x1');
ylabel('x2');

% Marcar o mínimo global REAL
plot(0, 0, 'k+', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Mínimo Global (Real)');

% 2. Gerar solução inicial aleatória
current_sol_x = interval_min_F2 + (interval_max_F2 - interval_min_F2) * rand();
current_sol_y = interval_min_F2 + (interval_max_F2 - interval_min_F2) * rand();
current_fit = fobj_F2_vec(current_sol_x, current_sol_y); % Usa a função F2

global_best_fit_F2 = current_fit;
global_best_sol_F2 = [current_sol_x, current_sol_y];

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
        neighbor_x = max(interval_min_F2, min(interval_max_F2, neighbor_x)); % Limites F2
        neighbor_y = max(interval_min_F2, min(interval_max_F2, neighbor_y)); % Limites F2
        
        neighbor_fit = fobj_F2_vec(neighbor_x, neighbor_y); % Usa a função F2
        
        % Calcular dE
        dE = neighbor_fit - current_fit;
        
        % Decisão do SA
        if (dE < 0)
            % Aceita melhor
            current_sol_x = neighbor_x;
            current_sol_y = neighbor_y;
            current_fit = neighbor_fit;
            
            % Atualizar melhor global
            if current_fit < global_best_fit_F2
                global_best_fit_F2 = current_fit;
                global_best_sol_F2 = [current_sol_x, current_sol_y];
            end
        else
            % Aceita pior com probabilidade p
            p = exp(-dE / T);
            if (rand() < p)
                current_sol_x = neighbor_x;
                current_sol_y = neighbor_y;
                current_fit = neighbor_fit;
            end
        end
    end % Fim do loop nRep
    
    % --- ANIMAÇÃO (1x por ciclo de Temp.) ---
    path_x(end+1) = current_sol_x;
    path_y(end+1) = current_sol_y;
    
    set(h_path, 'XData', path_x, 'YData', path_y);
    set(h_current, 'XData', current_sol_x, 'YData', current_sol_y);
    
    temp_ratio = max(0, (T - T_min) / (T_inicial - T_min));
    set(h_current, 'MarkerFaceColor', [temp_ratio, 0, 1-temp_ratio]);
    
    drawnow;
    pause(PAUSE_TIME);
    % --- FIM DA ANIMAÇÃO ---
    
    % 5. Arrefecer
    T = T * alfa;
    
end % Fim do loop de arrefecimento

% 6. Marcar o melhor global ENCONTRADO
% Corrigido: global_best_sol_F2(2)
plot(global_best_sol_F2(1), global_best_sol_F2(2), 'c*', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Melhor Global Encontrado');
legend('Location', 'northwest');
hold off;

fprintf('Visualização concluída.\n');