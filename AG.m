% -------------------------------------------------------------------------
% Gerador de Gráficos para Relatório - Algoritmo Genético (GA)
% Código Limpo e Corrigido
% -------------------------------------------------------------------------
clear; clc; close all;

%% 1. PARÂMETROS E CONFIGURAÇÃO
pop_size = 100;          % Tamanho da população
lchrome = 12;           % Tamanho do cromossoma (bits)
maxgen = 150;            % Número de gerações
p_cross = 0.75;         % Probabilidade de cruzamento
p_mut = 0.003;           % Probabilidade de mutação
num_vars = 2;           
total_bits = lchrome * num_vars; 

% --- ESCOLHA DA FUNÇÃO (1 ou 2) ---
funcao_escolhida = 2;   % <--- Mude para 1 ou 2 conforme necessário

if funcao_escolhida == 1
    limit_range = [-2.048, 2.048]; 
else
    limit_range = [-5.12, 5.12];   
end
min_val = limit_range(1);
max_val = limit_range(2);

%% 2. INICIALIZAÇÃO
CHROME = randi([0, 1], pop_size, total_bits);

% Arrays para guardar histórico
hist_best_cost = zeros(1, maxgen);
hist_best_x = zeros(1, maxgen);
hist_best_y = zeros(1, maxgen);

% Variáveis para guardar "fotos" da população
pop_gen_1_x = []; pop_gen_1_y = [];
pop_gen_final_x = []; pop_gen_final_y = [];
roulette_probs_gen1 = []; % Para guardar a roleta

%% 3. CICLO EVOLUTIVO
for gen = 1:maxgen
    
    % --- DECODIFICAÇÃO ---
    x_pop = zeros(pop_size, 1);
    y_pop = zeros(pop_size, 1);
    
    for i = 1:pop_size
        bits_x = CHROME(i, 1:lchrome);
        bits_y = CHROME(i, lchrome+1:end);
        % Conversão manual Binário -> Decimal
        % (Garante funcionamento sem toolbox extra)
        int_x = sum(bits_x .* (2.^(lchrome-1:-1:0)));
        int_y = sum(bits_y .* (2.^(lchrome-1:-1:0)));
        % Mapeamento real
        x_pop(i) = min_val + (int_x / (2^lchrome - 1)) * (max_val - min_val);
        y_pop(i) = min_val + (int_y / (2^lchrome - 1)) * (max_val - min_val);
    end
    
    % --- GUARDAR DADOS DA GERAÇÃO 1 ---
    if gen == 1
        pop_gen_1_x = x_pop;
        pop_gen_1_y = y_pop;
    end
    % --- GUARDAR DADOS DA ÚLTIMA GERAÇÃO ---
    if gen == maxgen
        pop_gen_final_x = x_pop;
        pop_gen_final_y = y_pop;
    end
    
    % --- AVALIAÇÃO (CUSTO) ---
    Cost_Values = zeros(pop_size, 1);
    for i = 1:pop_size
        xx = x_pop(i); yy = y_pop(i);
        if funcao_escolhida == 1
            % Função 1 (Schaffer)
            num = (sin(sqrt(xx^2+yy^2)))^2 - 0.5;
            den = (1 + 0.001*(xx^2+yy^2))^2;
            Cost_Values(i) = 0.5 + num/den;
        else
            % Função 2 (Rastrigin)
            term1 = xx^2 - 10*cos(2*pi*xx);
            term2 = yy^2 - 10*cos(2*pi*yy);
            Cost_Values(i) = 20 + term1 + term2;
        end
    end
    
    % --- APTIDÃO (FITNESS) ---
    % Inverter custo para aptidão (Minimização)
    POP = 1 ./ (Cost_Values + 1e-6); 
    sumfit = sum(POP);
    
    % Guardar probabilidades da roleta para a Geração 1
    if gen == 1
        roulette_probs_gen1 = POP / sumfit;
    end

    % --- ESTATÍSTICAS ---
    [min_cost, idx_best] = min(Cost_Values);
    hist_best_cost(gen) = min_cost;
    hist_best_x(gen) = x_pop(idx_best);
    hist_best_y(gen) = y_pop(idx_best);
    
    % Parar se for a última geração
    if gen == maxgen, break; end

    % --- SELEÇÃO (Roleta) ---
    New_CHROME = zeros(size(CHROME));
    probs = POP / sumfit;
    cum_probs = cumsum(probs);
    
    for i = 1:pop_size
        r = rand();
        sel_idx = find(r <= cum_probs, 1, 'first');
        if isempty(sel_idx), sel_idx = pop_size; end
        New_CHROME(i, :) = CHROME(sel_idx, :);
    end
    
    % --- CRUZAMENTO & MUTAÇÃO ---
    idx_parents = randperm(pop_size);
    for i = 1:2:pop_size
        if rand() < p_cross
            cut = randi([1, total_bits-1]);
            p1 = idx_parents(i); p2 = idx_parents(i+1);
            New_CHROME(p1,:) = [New_CHROME(p1, 1:cut), New_CHROME(p2, cut+1:end)];
            New_CHROME(p2,:) = [New_CHROME(p2, 1:cut), New_CHROME(p1, cut+1:end)];
        end
    end
    
    % Mutação bit a bit
    mask = rand(pop_size, total_bits) < p_mut;
    New_CHROME = xor(New_CHROME, mask);
    CHROME = New_CHROME;
end

%% --- GERAÇÃO DAS FIGURAS PARA O RELATÓRIO ---

% Preparar o fundo (Contour Plot)
grid_res = (max_val - min_val) / 100;
[Xg, Yg] = meshgrid(min_val:grid_res:max_val, min_val:grid_res:max_val);
Zg = zeros(size(Xg));
for r=1:size(Xg,1)
    for c=1:size(Xg,2)
        xx=Xg(r,c); yy=Yg(r,c);
        if funcao_escolhida == 1
            num = (sin(sqrt(xx^2+yy^2)))^2 - 0.5; den = (1 + 0.001*(xx^2+yy^2))^2;
            Zg(r,c) = 0.5 + num/den;
        else
            term1 = xx^2 - 10*cos(2*pi*xx); term2 = yy^2 - 10*cos(2*pi*yy);
            Zg(r,c) = 20 + term1 + term2;
        end
    end
end

%% FIGURA 1: Comparação Geração 1 vs Última Geração
figure('Name', 'Comparação de Populações', 'Position', [100, 100, 1000, 500]);

subplot(1, 2, 1);
contourf(Xg, Yg, Zg, 20); colormap jet; hold on;
scatter(pop_gen_1_x, pop_gen_1_y, 50, 'k', 'filled', 'MarkerEdgeColor', 'w');
title('Geração 1 (Início)'); xlabel('x'); ylabel('y'); axis square;

subplot(1, 2, 2);
contourf(Xg, Yg, Zg, 20); colormap jet; hold on;
scatter(pop_gen_final_x, pop_gen_final_y, 50, 'k', 'filled', 'MarkerEdgeColor', 'w');
title(['Geração ' num2str(maxgen) ' (Final)']); xlabel('x'); ylabel('y'); axis square;

%% FIGURA 2: Evolução das Variáveis e da Função
figure('Name', 'Evolução das Variáveis', 'Position', [150, 150, 600, 700]);

subplot(3, 1, 1);
plot(1:maxgen, hist_best_x, 'b-', 'LineWidth', 1.5);
title('Evolução da Melhor Coordenada X'); ylabel('Valor de X'); grid on;

subplot(3, 1, 2);
plot(1:maxgen, hist_best_y, 'r-', 'LineWidth', 1.5);
title('Evolução da Melhor Coordenada Y'); ylabel('Valor de Y'); grid on;

subplot(3, 1, 3);
plot(1:maxgen, hist_best_cost, 'k-', 'LineWidth', 1.5);
title('Evolução do Valor da Função (Custo)'); 
xlabel('Geração'); ylabel('f(x,y)'); grid on;

%% FIGURA 3: Representação da Roleta Viciada (Baseada na Geração 1)
figure('Name', 'Roleta Viciada', 'Position', [200, 200, 600, 500]);

% Ordenar para melhor visualização
[sorted_probs, idx] = sort(roulette_probs_gen1, 'descend');
% Destacar as 3 melhores fatias
explode = zeros(size(sorted_probs));
explode(1:3) = 0.1; 

p = pie(sorted_probs, explode);
title('Representação da "Roleta Viciada" (Probabilidade de Seleção - Gen 1)');
legend(['Melhor Indivíduo (' num2str(round(max(sorted_probs)*100,1)) '%)'], ...
       'Location', 'BestOutside');

% Remover textos percentuais muito pequenos para limpar o gráfico
for k = 1:numel(p)
    if isgraphics(p(k),'Text') && str2double(strrep(p(k).String,'%','')) < 2
        p(k).String = '';
    end
end