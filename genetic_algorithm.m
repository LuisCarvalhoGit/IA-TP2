function [best_sol, best_fit, history_fit, viz_data] = genetic_algorithm(fobj, interval_min, interval_max, pop_size, generations, p_cross, p_mut, lchrome)
    % Parâmetros
    num_vars = 2; 
    total_bits = lchrome * num_vars; 
    
    % Inicialização da População
    CHROME = randi([0, 1], pop_size, total_bits);
    
    best_fit = Inf;
    best_sol = [0, 0];
    history_fit = zeros(1, generations);
    
    % Inicializar variável para guardar o elite binário
    elite_chrome = zeros(1, total_bits); 
    
    % Históricos para os gráficos de evolução das variáveis
    viz_data.hist_best_x = zeros(1, generations);
    viz_data.hist_best_y = zeros(1, generations);
    
    for gen = 1:generations
        % 1. Descodificação e Avaliação
        cost_val = zeros(pop_size, 1);
        fitness = zeros(pop_size, 1);
        pop_x = zeros(pop_size, 1);
        pop_y = zeros(pop_size, 1);
        
        for i = 1:pop_size
            bits_x = CHROME(i, 1:lchrome);
            bits_y = CHROME(i, lchrome+1:end);
            
            % Conversão Binário -> Decimal
            int_x = sum(bits_x .* (2.^(lchrome-1:-1:0)));
            int_y = sum(bits_y .* (2.^(lchrome-1:-1:0)));
            
            val_x = interval_min + (int_x / (2^lchrome - 1)) * (interval_max - interval_min);
            val_y = interval_min + (int_y / (2^lchrome - 1)) * (interval_max - interval_min);
            
            pop_x(i) = val_x;
            pop_y(i) = val_y;
            
            % Custo e Fitness
            cost_val(i) = fobj(val_x, val_y);
            fitness(i) = 1 / (cost_val(i) + 1e-6); % Minimização
        end
        
        % Dados para os gráficos
        if gen == 1
            viz_data.gen1.x = pop_x;
            viz_data.gen1.y = pop_y;
            viz_data.gen1.probs = fitness / sum(fitness); 
        end
        if gen == generations
            viz_data.final.x = pop_x;
            viz_data.final.y = pop_y;
        end
        
        % Estatísticas e Encontrar o Melhor
        [min_cost, idx_best] = min(cost_val);
        history_fit(gen) = min_cost;
        
        % Guardamos a sequência de bits do melhor indivíduo atual antes de modificar a população
        elite_chrome = CHROME(idx_best, :);
        
        % Guardar evolução das variáveis
        viz_data.hist_best_x(gen) = pop_x(idx_best);
        viz_data.hist_best_y(gen) = pop_y(idx_best);
        
        if min_cost < best_fit
            best_fit = min_cost;
            best_sol = [pop_x(idx_best), pop_y(idx_best)];
        end
        
        if gen == generations, break; end
        
        % Seleção (Roleta)
        sumfit = sum(fitness);
        probs = fitness / sumfit;
        cum_probs = cumsum(probs);
        New_CHROME = zeros(size(CHROME));
        
        for i = 1:pop_size
            r = rand();
            sel_idx = find(r <= cum_probs, 1, 'first');
            New_CHROME(i, :) = CHROME(sel_idx, :);
        end
        
        % Cruzamento
        for i = 1:2:pop_size
            if rand() < p_cross
                cut = randi([1, total_bits-1]);
                New_CHROME(i, :) = [New_CHROME(i, 1:cut), New_CHROME(i+1, cut+1:end)];
                New_CHROME(i+1, :) = [New_CHROME(i+1, 1:cut), New_CHROME(i, cut+1:end)];
            end
        end
        
        % Mutação
        mask = rand(pop_size, total_bits) < p_mut;
        CHROME = xor(New_CHROME, mask);
        % Substituímos o primeiro indivíduo da nova população pelo Elite guardado
        CHROME(1, :) = elite_chrome;
        
    end
end