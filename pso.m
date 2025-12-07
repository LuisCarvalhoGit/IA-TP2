function [gbest_sol, gbest_val, history_fit] = pso(fobj, interval_min, interval_max, swarm_size, maxit)
% Implementação do Particle Swarm Optimization (PSO)
% Variáveis baseadas no protocolo: swarm_size, x, v, pbest, gbest, w, vmax 
%
% ENTRADAS:
%   fobj          - Função objetivo
%   interval_min/max - Limites do espaço de pesquisa
%   swarm_size    - Número de partículas (população)
%   maxit         - Número de épocas (iterações)

    % --- Parâmetros do PSO ---
    num_vars = 2;        % x e y
    c1 = 2.0;            % Coeficiente Cognitivo (puxa para o pbest)
    c2 = 2.0;            % Coeficiente Social (puxa para o gbest)
    
    % Velocidade Máxima (Clamping) - Evita que as partículas voem para "fora do mapa"
    % Geralmente 10% a 20% do tamanho do intervalo
    vmax = 0.15 * (interval_max - interval_min);
    
    % --- Inicialização ---
    % Posições Iniciais (x)
    pos = interval_min + (interval_max - interval_min) * rand(swarm_size, num_vars);
    
    % Velocidades Iniciais (v) - começam a zero
    vel = zeros(swarm_size, num_vars);
    
    % Melhores Pessoais (pbest)
    pbest_pos = pos;
    pbest_val = inf(swarm_size, 1);
    
    % Melhor Global (gbest)
    gbest_val = Inf;
    gbest_sol = zeros(1, num_vars);
    
    % Histórico para o gráfico de convergência
    history_fit = zeros(1, maxit);
    
    % Avaliação Inicial
    for i = 1:swarm_size
        val = fobj(pos(i,1), pos(i,2));
        pbest_val(i) = val;
        
        if val < gbest_val
            gbest_val = val;
            gbest_sol = pos(i,:);
        end
    end
    
    % --- Loop Principal (Épocas) [cite: 41] ---
    for it = 1:maxit
        
        % Atualização da Inércia (w) - Decaimento Linear [cite: 48]
        % w começa alto (0.9) para explorar e baixa (0.4) para focar
        w = 0.9 - ((0.9 - 0.4) * it / maxit);
        
        for i = 1:swarm_size
            
            % 1. Atualizar Velocidade (v)
            % v = w*v + c1*r1*(pbest-x) + c2*r2*(gbest-x)
            r1 = rand(1, num_vars);
            r2 = rand(1, num_vars);
            
            vel(i,:) = w * vel(i,:) ...
                     + c1 * r1 .* (pbest_pos(i,:) - pos(i,:)) ...
                     + c2 * r2 .* (gbest_sol - pos(i,:));
            
            % Limitar Velocidade (Clamping vmax)
            vel(i,:) = max(min(vel(i,:), vmax), -vmax);
            
            % 2. Atualizar Posição (x)
            pos(i,:) = pos(i,:) + vel(i,:);
            
            % Garantir limites do mapa (Boundaries)
            pos(i,:) = max(min(pos(i,:), interval_max), interval_min);
            
            % 3. Avaliação
            current_val = fobj(pos(i,1), pos(i,2));
            
            % 4. Atualizar pbest
            if current_val < pbest_val(i)
                pbest_val(i) = current_val;
                pbest_pos(i,:) = pos(i,:);
                
                % 5. Atualizar gbest
                if current_val < gbest_val
                    gbest_val = current_val;
                    gbest_sol = pos(i,:);
                end
            end
        end
        
        % Guardar histórico
        history_fit(it) = gbest_val;
    end
    
end