% Implementação do algoritmo Simulated Annealing (SA) para minimização.
% Baseado nos requisitos do Trabalho 2. [cite: 29]
%
% ENTRADAS:
%   fobj          - Handle da função objetivo (ex: @fobj_F1)
%   interval_min  - Limite inferior do espaço de busca
%   interval_max  - Limite superior do espaço de busca
%   T             - Temperatura inicial [cite: 31]
%   T_min         - Temperatura mínima (critério de paragem)
%   alfa          - Fator de decaimento da temperatura [cite: 31]
%   nRep          - N. de repetições por temperatura [cite: 31]
%   step_size     - Tamanho máximo do passo para encontrar um vizinho
%
% SAÍDAS:
%   global_best_sol - A melhor solução [x, y] encontrada
%   global_best_fit - O valor da função (fitness) na melhor solução
%   historico_best  - Vetor com a evolução do melhor 'fit' (para gráficos)
%
function [global_best_sol, global_best_fit, historico_best] = simulated_annealing(fobj, interval_min, interval_max, T, T_min, alfa, nRep, step_size)
    
    % 1. Gerar solução inicial aleatória
    current_sol_x = interval_min + (interval_max - interval_min) * rand();
    current_sol_y = interval_min + (interval_max - interval_min) * rand();
    current_fit = fobj(current_sol_x, current_sol_y);
    
    % O melhor global começa como a solução inicial
    global_best_fit = current_fit;
    global_best_sol = [current_sol_x, current_sol_y];
    
    % Para guardar dados para o relatório [cite: 49]
    historico_best = [global_best_fit];
    
    fprintf('Iniciando SA... T inicial: %.2f, Fit inicial: %.5f\n', T, current_fit);
    
    % 2. Loop Principal - ARREFECIMENTO
    while T > T_min
        
        temp_ratio = (T - T_min) / (T_inicial - T_min);
        dynamic_step = max(0.05, temp_ratio * STEP_SIZE); % O passo diminui com T

        % 3. Loop Interno - Repetições na mesma temperatura [cite: 31]
        for i = 1:nRep
            
            % Gerar um vizinho aleatório
            neighbor_x = current_sol_x + (rand() - 0.5) * 2 * dynamic_step;
            neighbor_y = current_sol_y + (rand() - 0.5) * 2 * dynamic_step;
            
            % Garantir que o vizinho está dentro dos limites
            neighbor_x = max(interval_min, min(interval_max, neighbor_x));
            neighbor_y = max(interval_min, min(interval_max, neighbor_y));
            
            % Avaliar o vizinho
            neighbor_fit = fobj(neighbor_x, neighbor_y);
            
            % Calcular o gradiente de energia (dE) 
            dE = neighbor_fit - current_fit;
            
            % --- AQUI ESTÁ A LÓGICA DO SA ---
            if (dE < 0)
                % Vizinho é MELHOR (menor custo). Aceita sempre.
                current_sol_x = neighbor_x;
                current_sol_y = neighbor_y;
                current_fit = neighbor_fit;
                
                % Atualizar o melhor global (se este for o melhor já visto)
                if current_fit < global_best_fit
                    global_best_fit = current_fit;
                    global_best_sol = [current_sol_x, current_sol_y];
                end
            else
                % Vizinho é PIOR.
                % Aceita com probabilidade 'p' 
                p = exp(-dE / T);
                if (rand() < p)
                    % Aceitou o salto "pior"!
                    current_sol_x = neighbor_x;
                    current_sol_y = neighbor_y;
                    current_fit = neighbor_fit;
                end
                % Se rand() >= p, rejeita o vizinho e fica onde está.
            end
            
        end % Fim do loop nRep
        
        % Guardar o melhor 'fit' desta temperatura para o gráfico
        historico_best(end+1) = global_best_fit;
        
        % 4. Arrefecer a temperatura [cite: 31]
        T = T * alfa;
        
    end % Fim do loop de arrefecimento
    
    fprintf('Arrefecimento concluído. T final: %.5f\n', T);
    
end