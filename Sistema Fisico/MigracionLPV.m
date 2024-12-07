clc; clear; close all;

% Cargar parámetros desde Parametros.m
Parametros;

% Ajustar variables a partir de los parámetros cargados
R_s = Rs_ref;      
i_qsO = 0;        
i_0sO = 0;         
i_dsO_nom = I_d0;  % Valor nominal de i_ds desde Parametros.m

% Rango de valores de i_ds para el análisis
i_ds_values = linspace(i_dsO_nom - 1, i_dsO_nom + 1, 30);

theta_mO = 0; 
cos_term = cos(theta_mO/r);

% Función psi_O
psi_function = @(i_ds) -((1/R_tsamb) - (3*Rs_ref*alfa_cu*(2*i_0sO^2 + i_ds^2 + i_qsO^2)/2))/C_ts;

% Matriz A0
A0_function = @(i_ds) [
    0,                                                   1,                                                              0,                                                          0,                                        0,                                                     0;
    -(g*k_l*cos_term)/(J_eq*r^2),                        -b_eq/J_eq,                                                     (3*P_p*(lambda_m+(i_ds*(L_d - L_q))))/(2*J_eq),        (3*P_p*i_qsO*(L_d - L_q))/(2*J_eq),        0,                                                     0;
    0,                                                   -P_p*(lambda_m+L_d*i_ds)/L_q,                                  -R_s/L_q,                                                 -(L_d*P_p*(0))/L_q,                       0,                                                     -(Rs_ref*alfa_cu*i_qsO)/L_q;
    0,                                                   (L_q*P_p*i_qsO)/L_d,                                           (L_q*P_p*(0))/L_d,                                        -R_s/L_d,                                 0,                                                     -(Rs_ref*alfa_cu*i_ds)/L_d;
    0,                                                   0,                                                              0,                                                          0,                                        -R_s/L_ls,                                           -(Rs_ref*alfa_cu*i_0sO)/L_ls;
    0,                                                   0,                                                              (3*R_s*i_qsO)/C_ts,                                    (3*R_s*i_ds)/C_ts,                       (6*R_s*i_0sO)/C_ts,                                   psi_function(i_ds)
];

% Cálculo de autovalores
eigenvalues = zeros(length(i_ds_values),6);
for k = 1:length(i_ds_values)
    A0_k = A0_function(i_ds_values(k));
    eig_vals = eig(A0_k);
    eigenvalues(k,:) = eig_vals.';
end

%% Graficar Migración de Autovalores
figure;
hold on; grid on; axis equal;
title('Migración de Autovalores ante Variación de i_{dsO}');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

% Ejes imaginario y real (referencias)
xline(0, 'k--', 'Eje Real');
yline(0, 'k--', 'Eje Imaginario');

colors = lines(6);

% Graficar las trayectorias de los autovalores con leyenda
for n = 1:6
    plot(real(eigenvalues(:,n)), imag(eigenvalues(:,n)), 'o-', 'Color', colors(n,:), 'LineWidth',1.5, ...
        'DisplayName', ['Autovalor ',num2str(n)]);
end

% Índices min, nominal, max
[~, idx_nominal] = min(abs(i_ds_values - i_dsO_nom));
idx_min = 1;
idx_max = length(i_ds_values);

% Agregar puntos min, nominal, max con borde negro y en la leyenda
for n = 1:6
    val_min = eigenvalues(idx_min,n);
    val_nom = eigenvalues(idx_nominal,n);
    val_max = eigenvalues(idx_max,n);
    
    str_min = sprintf('Min (A%d): %.1f%+.1fj', n, real(val_min), imag(val_min));
    str_nom = sprintf('Nom (A%d): %.1f%+.1fj', n, real(val_nom), imag(val_nom));
    str_max = sprintf('Max (A%d): %.1f%+.1fj', n, real(val_max), imag(val_max));
    
    plot(real(val_min), imag(val_min), 'd', 'Color', colors(n,:), 'MarkerSize',8,'LineWidth',2, ...
        'MarkerFaceColor', colors(n,:), 'MarkerEdgeColor','k', 'DisplayName', str_min);
    plot(real(val_nom), imag(val_nom), '^', 'Color', colors(n,:), 'MarkerSize',8,'LineWidth',2, ...
        'MarkerFaceColor', colors(n,:), 'MarkerEdgeColor','k', 'DisplayName', str_nom);
    plot(real(val_max), imag(val_max), 's', 'Color', colors(n,:), 'MarkerSize',8,'LineWidth',2, ...
        'MarkerFaceColor', colors(n,:), 'MarkerEdgeColor','k', 'DisplayName', str_max);
end

% Ajustar la leyenda
legend('Location','bestoutside');

hold off;

%% Generar Tabla en LaTeX
% Mostrar distintos valores de i_ds y los autovalores correspondientes
fprintf('\\begin{table}[H]\n');
fprintf('    \\centering\n');
fprintf('    \\label{tab:variacion_i_ds}\n');
fprintf('    \\begin{tabular}{|c|c|}\n');
fprintf('        \\hline\n');
fprintf('        \\textbf{i\\_ds [A]} & \\textbf{Autovalores} \\\\\n');
fprintf('        \\hline\n');

% Seleccionar algunos puntos para la tabla (por ejemplo, cada 5 puntos)
step_tab = 5;
for i = 1:step_tab:length(i_ds_values)
    val = i_ds_values(i);
    vals_eig = eigenvalues(i,:);
    eig_str = '';
    for ev = 1:length(vals_eig)
        eig_str = [eig_str, sprintf('%.1f%+.1fj ', real(vals_eig(ev)), imag(vals_eig(ev)))];
    end
    fprintf('        %.3f & %s \\\\\n', val, eig_str);
    fprintf('        \\hline\n');
end

fprintf('    \\end{tabular}\n');
fprintf('    \\caption{Variación de autovalores ante cambios en i\\_ds}\n');
fprintf('\\end{table}\n');