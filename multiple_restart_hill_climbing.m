% Implementação do algoritmo Subida da Colina com Reinicialização Múltipla
% para minimização.

% ENTRADAS:
%   fobj          - Handle da função objetivo (ex: @fobj_F1)
%   interval_min  - Limite inferior do espaço de busca (ex: -2.048)
%   interval_max  - Limite superior do espaço de busca (ex: 2.048)
%   num_restarts  - Número de reinicializações (quantas vezes correr o HC)
%   num_iterations- Número de passos/iterações por cada subida (HC)
%   step_size     - Tamanho máximo do passo para encontrar um vizinho
%
% SAÍDAS:
%   global_best_sol - A melhor solução [x, y] encontrada
%   global_best_fit - O valor da função (fitness) na melhor solução

function [global_best_sol, global_best_fit] = multiple_restart_hill_climbing(fobj, interval_min, interval_max, num_restarts, num_iterations, step_size)
    
    % Inicializa o melhor global 
    global_best_fit = Inf;
    global_best_sol = [NaN, NaN];
    
    % Loop principal 
    for r = 1:num_restarts
        
        % Gerar uma solução inicial aleatória dentro do intervalo
        current_sol_x = interval_min + (interval_max - interval_min) * rand();
        current_sol_y = interval_min + (interval_max - interval_min) * rand();
        current_fit = fobj(current_sol_x, current_sol_y);
        
        % Loop da Subida da Colina 
        for i = 1:num_iterations
            
            % Gerar um vizinho aleatório
            neighbor_x = current_sol_x + (rand() - 0.5) * 2 * step_size;
            neighbor_y = current_sol_y + (rand() - 0.5) * 2 * step_size;
            
            % Garantir que o vizinho está dentro dos limites (clamping)
            neighbor_x = max(interval_min, min(interval_max, neighbor_x));
            neighbor_y = max(interval_min, min(interval_max, neighbor_y));
            
            % Avaliar o vizinho
            neighbor_fit = fobj(neighbor_x, neighbor_y);
            
            % Se o vizinho for melhor move-se para ele
            if neighbor_fit < current_fit
                current_sol_x = neighbor_x;
                current_sol_y = neighbor_y;
                current_fit = neighbor_fit;
            end
            % Se não for melhor, fica na solução atual e tenta outro
            % vizinho na próxima iteração
        end
        
        % Atualizar o melhor global
        % Compara o mínimo local encontrado com o melhor global já registado
        if current_fit < global_best_fit
            global_best_fit = current_fit;
            global_best_sol = [current_sol_x, current_sol_y];
        end
    end 
end