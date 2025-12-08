function [global_best_sol, global_best_fit, hist_best, hist_current, hist_T] = simulated_annealing(fobj, interval_min, interval_max, T, T_min, alfa, nRep, step_size)
%Script algoritmo Simulated Anealing

    % Inicialização
    current_sol_x = interval_min + (interval_max - interval_min) * rand();
    current_sol_y = interval_min + (interval_max - interval_min) * rand();
    current_fit = fobj(current_sol_x, current_sol_y);
    
    global_best_fit = current_fit;
    global_best_sol = [current_sol_x, current_sol_y];
    
    % Históricos
    hist_best = [];     % melhor global
    hist_current = [];  % atual
    hist_T = [];        % A temperatura em cada passo
    
    % Loop Principal
    while T > T_min
        
        for i = 1:nRep
            % Vizinho
            dx = (rand() - 0.5) * 2 * step_size;
            dy = (rand() - 0.5) * 2 * step_size;
            
            neighbor_x = max(interval_min, min(interval_max, current_sol_x + dx));
            neighbor_y = max(interval_min, min(interval_max, current_sol_y + dy));
            neighbor_fit = fobj(neighbor_x, neighbor_y);
            
            dE = neighbor_fit - current_fit;
            
            % Decisão
            accept = false;
            if dE < 0
                accept = true;
                if neighbor_fit < global_best_fit
                    global_best_fit = neighbor_fit;
                    global_best_sol = [neighbor_x, neighbor_y];
                end
            else
                p = exp(-dE / T);
                if rand() < p
                    accept = true;
                end
            end
            
            if accept
                current_sol_x = neighbor_x;
                current_sol_y = neighbor_y;
                current_fit = neighbor_fit;
            end
        end 
        
        % Registar dados no final de cada patamar de temperatura
        hist_best(end+1) = global_best_fit;
        hist_current(end+1) = current_fit;
        hist_T(end+1) = T;
        
        % Arrefecimento
        T = T * alfa;
    end
end