% Visualização 3D Interativa (População Inicial vs Final)
% + Gráficos de Análise Completos
clear; clc; close all;

% =========================================================================
%                                CONFIGURAÇÕES 
% =========================================================================
OPCAO_FUNCAO = 2;   % 1 (Schaffer) ou 2 (Rastrigin)

% Parâmetros do Genético 
POP_SIZE = 100;     
GENERATIONS = 100;  
L_CHROME = 10;      % 10 bits 
P_CROSS = 0.75;    
P_MUT = 0.03;

% cores
BG_COLOR = [0.1 0.1 0.1]; 
AX_COLOR = [1 1 1]; 

if OPCAO_FUNCAO == 1
    nome = 'Função 1 (Schaffer)';
    lim_min = -2.048; lim_max = 2.048;
    fobj = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
    z_lift = 0.01; 
else
    nome = 'Função 2 (Rastrigin)';
    lim_min = -5.12; lim_max = 5.12;
    fobj = @(x,y) 20 + (x.^2 - 10*cos(2*pi.*x)) + (y.^2 - 10*cos(2*pi.*y));
    z_lift = 2;
end

fprintf('=== Executando GA para Visualização 3D: %s ===\n', nome);

% =========================================================================
%               EXECUÇÃO DO ALGORITMO (Recolha de Dados)
% =========================================================================
total_bits = L_CHROME * 2;
CHROME = randi([0, 1], POP_SIZE, total_bits);

best_fit_global = Inf;
best_sol_global = [NaN, NaN];

hist_best_val = zeros(1, GENERATIONS);
hist_best_pos = zeros(GENERATIONS, 2);

% Estruturas para guardar dados da Gen 1 e Gen Final para o 3D
data_gen1 = struct('x', [], 'y', [], 'z', []);
data_final = struct('x', [], 'y', [], 'z', []);
roulette_probs = [];

for gen = 1:GENERATIONS
    
    % Descodificação
    cost = zeros(POP_SIZE, 1);
    pop_x = zeros(POP_SIZE, 1);
    pop_y = zeros(POP_SIZE, 1);
    
    for i = 1:POP_SIZE
        bits_x = CHROME(i, 1:L_CHROME);
        bits_y = CHROME(i, L_CHROME+1:end);
        
        int_x = sum(bits_x .* (2.^(L_CHROME-1:-1:0)));
        int_y = sum(bits_y .* (2.^(L_CHROME-1:-1:0)));
        
        val_x = lim_min + (int_x / (2^L_CHROME - 1)) * (lim_max - lim_min);
        val_y = lim_min + (int_y / (2^L_CHROME - 1)) * (lim_max - lim_min);
        
        pop_x(i) = val_x; pop_y(i) = val_y;
        cost(i) = fobj(val_x, val_y);
    end
    
    % Guardar Estatísticas
    [min_cost, idx] = min(cost);
    if min_cost < best_fit_global
        best_fit_global = min_cost;
        best_sol_global = [pop_x(idx), pop_y(idx)];
    end
    
    hist_best_val(gen) = best_fit_global;
    hist_best_pos(gen, :) = best_sol_global;
    
    % Captura de Dados para Visualização
    if gen == 1
        data_gen1.x = pop_x; data_gen1.y = pop_y; data_gen1.z = cost;
        fitness = 1 ./ (cost + 1e-6);
        roulette_probs = fitness / sum(fitness);
    end
    if gen == GENERATIONS
        data_final.x = pop_x; data_final.y = pop_y; data_final.z = cost;
    end
    
    % Operadores Genéticos
    if gen < GENERATIONS
        fitness = 1 ./ (cost + 1e-6);
        probs = fitness / sum(fitness);
        cum_probs = cumsum(probs);
        New_CHROME = zeros(size(CHROME));
        
        % Seleção
        for i = 1:POP_SIZE
            r = rand();
            sel = find(r <= cum_probs, 1, 'first');
            New_CHROME(i,:) = CHROME(sel,:);
        end
        % Cruzamento
        for i = 1:2:POP_SIZE
            if rand() < P_CROSS
                cut = randi([1, total_bits-1]);
                New_CHROME(i,:) = [New_CHROME(i,1:cut), New_CHROME(i+1,cut+1:end)];
                New_CHROME(i+1,:) = [New_CHROME(i+1,1:cut), New_CHROME(i,cut+1:end)];
            end
        end
        % Mutação
        mask = rand(POP_SIZE, total_bits) < P_MUT;
        CHROME = xor(New_CHROME, mask);
    end
end

fprintf('GA Concluído. A gerar figuras...\n');

% =========================================================================
% --- FIGURA 1: 3D INTERATIVO (INÍCIO vs FIM) ---
% =========================================================================
figure('Name', 'Comparação 3D de Populações', 'Position', [50, 50, 1200, 600], 'Color', BG_COLOR);

% Preparar Terreno
[X, Y] = meshgrid(linspace(lim_min, lim_max, 80));
Z = fobj(X, Y);

% --- SUBPLOT 1: GERAÇÃO 1 ---
ax1 = subplot(1, 2, 1);
surf(X, Y, Z, 'FaceAlpha', 0.7, 'EdgeColor', 'none'); 
shading interp; colormap jet; hold on;
% Pontos Pretos (População)
scatter3(data_gen1.x, data_gen1.y, data_gen1.z + z_lift, 40, 'k', 'filled', 'MarkerEdgeColor', 'w');
title('Geração 1 (Início)', 'Color', AX_COLOR, 'FontSize', 12);
xlabel('x1'); ylabel('x2'); zlabel('Fitness');
axis tight; view(45, 40); grid on;
% Configurar Eixos Dark Mode
set(ax1, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'ZColor', AX_COLOR, 'GridColor', AX_COLOR);

% --- SUBPLOT 2: GERAÇÃO FINAL ---
ax2 = subplot(1, 2, 2);
surf(X, Y, Z, 'FaceAlpha', 0.7, 'EdgeColor', 'none'); 
shading interp; colormap jet; hold on;
% Pontos Pretos (População Final)
scatter3(data_final.x, data_final.y, data_final.z + z_lift, 40, 'k', 'filled', 'MarkerEdgeColor', 'w');
% Melhor Global (Estrela Magenta)
plot3(best_sol_global(1), best_sol_global(2), best_fit_global + z_lift + 0.5, 'p', ...
    'MarkerSize', 20, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'w');

title(['Geração ' num2str(GENERATIONS) ' (Final)'], 'Color', AX_COLOR, 'FontSize', 12);
xlabel('x1'); ylabel('x2'); zlabel('Fitness');
axis tight; view(45, 40); grid on;
% Configurar Eixos Dark Mode
set(ax2, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'ZColor', AX_COLOR, 'GridColor', AX_COLOR);

% ATIVAR ROTAÇÃO
rotate3d on;
fprintf('> Dica: A Figura 1 é rotacionável. Clique e arraste para ver em 3D.\n');

% =========================================================================
% --- FIGURA 2: EVOLUÇÃO DAS VARIÁVEIS ---
% =========================================================================
figure('Name', 'Evolução das Variáveis', 'Color', BG_COLOR, 'Position', [100, 100, 600, 500]);
plot(1:GENERATIONS, hist_best_pos(:,1), 'c-', 'LineWidth', 1.5, 'DisplayName', 'x1'); hold on;
plot(1:GENERATIONS, hist_best_pos(:,2), 'y-', 'LineWidth', 1.5, 'DisplayName', 'x2');
yline(0, 'w--');
legend('Location', 'best', 'TextColor', AX_COLOR, 'EdgeColor', AX_COLOR);
title('Evolução das Variáveis (Melhor Indivíduo)', 'Color', AX_COLOR);
xlabel('Geração', 'Color', AX_COLOR); ylabel('Valor', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% =========================================================================
% --- FIGURA 3: CONVERGÊNCIA DO CUSTO ---
% =========================================================================
figure('Name', 'Convergência do Custo', 'Color', BG_COLOR, 'Position', [750, 100, 600, 500]);
plot(1:GENERATIONS, hist_best_val, 'g-', 'LineWidth', 2);
title('Convergência da Função Custo', 'Color', AX_COLOR);
xlabel('Geração', 'Color', AX_COLOR); ylabel('Fitness f(x)', 'Color', AX_COLOR);
set(gca, 'Color', BG_COLOR, 'XColor', AX_COLOR, 'YColor', AX_COLOR, 'GridColor', AX_COLOR);
grid on;

% =========================================================================
% --- FIGURA 4: ROLETA VICIADA (Bónus) ---
% =========================================================================
figure('Name', 'Roleta Viciada (Gen 1)', 'Color', BG_COLOR, 'Position', [400, 400, 600, 500]);
[sorted_probs, idx] = sort(roulette_probs, 'descend');
explode = zeros(size(sorted_probs));
explode(1:3) = 0.1; 
p = pie(sorted_probs, explode);
title('Probabilidade de Seleção (Gen 1)', 'Color', AX_COLOR);
% Ajustar cores do texto da Pie Chart
for k = 1:numel(p)
    if isgraphics(p(k),'Text')
        p(k).Color = AX_COLOR;
        val = str2double(strrep(p(k).String,'%',''));
        if val < 2, p(k).String = ''; end 
    end
end