% Script para gerar graficos Algoritmo Genético
clear; clc; close all;

% Parametros iniciais 
POP_SIZE = 100;
GENERATIONS = 100;
L_CHROME = 10;
P_CROSS = 0.75;
P_MUT = 0.03;

% Escolher função(1 ou 2)
funcao_escolhida = 2; 

if funcao_escolhida == 1
    fobj = @fobj_F1;
    lim_min = -2.048; lim_max = 2.048;
    nome_func = 'Função 1 (Schaffer)';
    % Definição inline para o contour plot (Visualização)
    f_vis = @(x,y) 0.5 + ((sin(sqrt(x.^2+y.^2))).^2-0.5) ./ ((1+0.001.*(x.^2+y.^2)).^2);
else
    fobj = @fobj_F2;
    lim_min = -5.12; lim_max = 5.12;
    nome_func = 'Função 2 (Rastrigin)';
    % Definição inline para o contour plot (Visualização)
    f_vis = @(x,y) 20 + (x.^2 - 10*cos(2*pi.*x)) + (y.^2 - 10*cos(2*pi.*y));
end

fprintf('A executar GA para %s...\n', nome_func);

% Execução do algoritmo
[best_sol, best_fit, history_fit, viz_data] = genetic_algorithm(...
    fobj, lim_min, lim_max, POP_SIZE, GENERATIONS, P_CROSS, P_MUT, L_CHROME);

fprintf('Melhor Solução: f(%.4f, %.4f) = %.5f\n', best_sol(1), best_sol(2), best_fit);

% =========================================================
%                       GRÁFICOS
% =========================================================


[Xg, Yg] = meshgrid(linspace(lim_min, lim_max, 100));
Zg = f_vis(Xg, Yg);

% FIGURA 1: Comparação de Populações (Geração 1 vs Final)
figure('Name', 'Figure 1: Comparacao de Populacoes', 'Position', [100, 100, 1000, 500]);

subplot(1, 2, 1);
contourf(Xg, Yg, Zg, 20); colormap jet; hold on;
scatter(viz_data.gen1.x, viz_data.gen1.y, 40, 'k', 'filled', 'MarkerEdgeColor', 'w');
title('Geração 1 (Início)'); xlabel('x'); ylabel('y'); axis square;

subplot(1, 2, 2);
contourf(Xg, Yg, Zg, 20); colormap jet; hold on;
scatter(viz_data.final.x, viz_data.final.y, 40, 'k', 'filled', 'MarkerEdgeColor', 'w');
title(['Geração ' num2str(GENERATIONS) ' (Final)']); xlabel('x'); ylabel('y'); axis square;


% FIGURA 2: Evolução das Variáveis e Custo
figure('Name', 'Figure 2: Evolucao das Variaveis', 'Position', [150, 150, 500, 600]);

subplot(3, 1, 1);
plot(1:GENERATIONS, viz_data.hist_best_x, 'b-', 'LineWidth', 1.5);
title('Evolução da Melhor Coordenada X'); ylabel('Valor de X'); grid on;
xlim([1 GENERATIONS]);

subplot(3, 1, 2);
plot(1:GENERATIONS, viz_data.hist_best_y, 'r-', 'LineWidth', 1.5);
title('Evolução da Melhor Coordenada Y'); ylabel('Valor de Y'); grid on;
xlim([1 GENERATIONS]);

subplot(3, 1, 3);
plot(1:GENERATIONS, history_fit, 'k-', 'LineWidth', 1.5);
title('Evolução do Valor da Função (Custo)'); 
xlabel('Geração'); ylabel('f(x,y)'); grid on;
xlim([1 GENERATIONS]);


% FIGURA 3: Roleta Viciada
figure('Name', 'Figure 3: Roleta Viciada', 'Position', [200, 200, 600, 500]);

probs = viz_data.gen1.probs;
[sorted_probs, idx] = sort(probs, 'descend');

explode = zeros(size(sorted_probs));
explode(1:min(3, length(explode))) = 0.1; 

p = pie(sorted_probs, explode);
title('Representação da "Roleta Viciada" (Probabilidade de Seleção - Gen 1)');

legend_str = sprintf('Melhor Indivíduo (%.1f%%)', max(sorted_probs)*100);
legend({legend_str}, 'Location', 'northeast');

for k = 1:numel(p)
    if isgraphics(p(k),'Text') 
        val = str2double(strrep(p(k).String,'%',''));
        if val < 2 % Esconde textos menores que 2%
            p(k).String = '';
        end
    end
end