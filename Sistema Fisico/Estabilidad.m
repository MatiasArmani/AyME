clc; clear; close all;

% Crear carpeta 'Imagenes' si no existe
if ~exist('Imagenes', 'dir')
    mkdir('Imagenes')
end

% Cargar Parámetros desde Parametros.m
Parametros;

%% Definición del Polinomio Característico
a = J_eq * L_q;
b_coeff = J_eq * Rs_ref + b_eq * L_q;
c = b_eq * Rs_ref + (3/2) * P_p^2 * lambda_m^2;

syms s
polinomio = a * s^2 + b_coeff * s + c;
soluciones = solve(polinomio == 0, s);

s2 = soluciones(1);
s3 = soluciones(2);
s1 = 0;

valores = struct('J_eq', J_eq, ...
                 'L_q', L_q, ...
                 'Rs_ref', Rs_ref, ...
                 'b_eq', b_eq, ...
                 'P_p', P_p, ...
                 'lambda_m', lambda_m);

s2_num = double(subs(s2, valores));
s3_num = double(subs(s3, valores));

disp('Las soluciones numéricas del polinomio característico son:');
disp(['s1 = ', num2str(s1), ' rad/s']);
disp(['s2 = ', num2str(s2_num), ' rad/s']);
disp(['s3 = ', num2str(s3_num), ' rad/s']);

zero_G_Tl = -Rs_ref / L_q;
disp(['El sistema tiene un cero en s = ', num2str(zero_G_Tl), ' rad/s']);

if all(real([s2_num, s3_num]) < 0)
    disp('El sistema es completamente estable (todos los polos tienen partes reales negativas).');
else
    disp('El sistema no es completamente estable (existe al menos un polo con parte real no negativa).');
end

sigma = real(s2_num);
omega_n_imag = abs(imag(s2_num));
omega_n = sqrt(sigma^2 + omega_n_imag^2);
zeta = abs(sigma) / omega_n;

fprintf('Frecuencia natural (omega_n) = %.2f rad/s\n', omega_n);
fprintf('Factor de amortiguamiento (zeta) = %.2f\n', zeta);

%% Gráfico de Polos y Ceros
figure;
hold on; grid on; axis equal;
title('Diagrama de Polos y Ceros del Sistema');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

xline(0, '--r', 'Eje Real');
yline(0, '--k', 'Eje Imaginario');

plot(real(s2_num), imag(s2_num), 'bx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName','s_2 nominal');
plot(real(s3_num), imag(s3_num), 'bx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName','s_3 nominal');
plot(zero_G_Tl, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Cero nominal');
plot(real(s1), imag(s1), 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Polo en el Origen');

buffer = 50;
x_min = min([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) - buffer;
x_max = max([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) + buffer;
y_min = min([imag(s2_num), imag(s3_num), imag(s1)]) - buffer;
y_max = max([imag(s2_num), imag(s3_num), imag(s1)]) + buffer;

if x_min >= x_max
    error('Error en los límites del eje X: x_min >= x_max');
end
if y_min >= y_max
    error('Error en los límites del eje Y: y_min >= y_max');
end

xlim([x_min, x_max]);
ylim([y_min, y_max]);
grid on; box on;
legend('Location', 'Best');
hold off;

saveas(gcf, 'Imagenes/polos_ceros_inicial.png');

%% Análisis de Variación de Parámetros (Ítem 4.b)
Rs_values = linspace(Rs_ref * 0.8, Rs_ref * 1.2, 50);
s2_vals = zeros(length(Rs_values), 1);
s3_vals = zeros(length(Rs_values), 1);
zero_vals = zeros(length(Rs_values), 1);
omega_n_vals = zeros(length(Rs_values), 1);
zeta_vals = zeros(length(Rs_values), 1);

for i = 1:length(Rs_values)
    Rs_temp = Rs_values(i);
    b_coeff_temp = J_eq * Rs_temp + b_eq * L_q;
    c_temp = b_eq * Rs_temp + (3/2) * P_p^2 * lambda_m^2;

    soluciones_temp = solve(a * s^2 + b_coeff_temp * s + c_temp == 0, s);
    s2_temp = double(soluciones_temp(1));
    s3_temp = double(soluciones_temp(2));
    
    s2_vals(i) = s2_temp;
    s3_vals(i) = s3_temp;
    zero_vals(i) = -Rs_temp / L_q;
    
    sigma_temp = real(s2_temp);
    omega_n_imag_temp = abs(imag(s2_temp));
    omega_n_temp = sqrt(sigma_temp^2 + omega_n_imag_temp^2);
    zeta_temp = abs(sigma_temp) / omega_n_temp;
    
    omega_n_vals(i) = omega_n_temp;
    zeta_vals(i) = zeta_temp;
end

%% Crear vector s1
s1_vec = real(s1) * ones(length(Rs_values), 1);

%% Índices para marcar mínimo, nominal y máximo
idx_min = 1;                                
idx_max = length(Rs_values);               
[~, idx_nominal] = min(abs(Rs_values - Rs_ref));

%% Graficar la migración de los polos y ceros
figure;
hold on; grid on; axis equal;
title('Migración de Polos y Ceros ante Variación de Rs');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

xline(0, '--r', 'Eje Real');
yline(0, '--k', 'Eje Imaginario');

% Trayectorias
plot(real(s2_vals), imag(s2_vals), 'b-', 'LineWidth', 1.5, 'DisplayName', 'Trayectoria s_2');
plot(real(s3_vals), imag(s3_vals), 'b-', 'LineWidth', 1.5, 'DisplayName', 'Trayectoria s_3');
plot(zero_vals, zeros(size(zero_vals)), 'r-', 'LineWidth', 1.5, 'DisplayName', 'Trayectoria Cero');
plot(real(s1), imag(s1), 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Polo en el Origen');

% Polos y Cero en min, nominal y max (con valores en la leyenda)
s2_min_str = sprintf('s_2 (min) = %.2f%+.2fj', real(s2_vals(idx_min)), imag(s2_vals(idx_min)));
s2_nom_str = sprintf('s_2 (nom) = %.2f%+.2fj', real(s2_vals(idx_nominal)), imag(s2_vals(idx_nominal)));
s2_max_str = sprintf('s_2 (max) = %.2f%+.2fj', real(s2_vals(idx_max)), imag(s2_vals(idx_max)));

s3_min_str = sprintf('s_3 (min) = %.2f%+.2fj', real(s3_vals(idx_min)), imag(s3_vals(idx_min)));
s3_nom_str = sprintf('s_3 (nom) = %.2f%+.2fj', real(s3_vals(idx_nominal)), imag(s3_vals(idx_nominal)));
s3_max_str = sprintf('s_3 (max) = %.2f%+.2fj', real(s3_vals(idx_max)), imag(s3_vals(idx_max)));

zero_min_str = sprintf('Cero (min) = %.2f', zero_vals(idx_min));
zero_nom_str = sprintf('Cero (nom) = %.2f', zero_vals(idx_nominal));
zero_max_str = sprintf('Cero (max) = %.2f', zero_vals(idx_max));

plot(real(s2_vals(idx_min)), imag(s2_vals(idx_min)), 'bd', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s2_min_str);
plot(real(s2_vals(idx_nominal)), imag(s2_vals(idx_nominal)), 'b^', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s2_nom_str);
plot(real(s2_vals(idx_max)), imag(s2_vals(idx_max)), 'bs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s2_max_str);

plot(real(s3_vals(idx_min)), imag(s3_vals(idx_min)), 'gd', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s3_min_str);
plot(real(s3_vals(idx_nominal)), imag(s3_vals(idx_nominal)), 'g^', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s3_nom_str);
plot(real(s3_vals(idx_max)), imag(s3_vals(idx_max)), 'gs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', s3_max_str);

plot(zero_vals(idx_min), 0, 'rd', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', zero_min_str);
plot(zero_vals(idx_nominal), 0, 'r^', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', zero_nom_str);
plot(zero_vals(idx_max), 0, 'rs', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', zero_max_str);

% Mostrar sobre el gráfico s1, s2, s3 y cero para identificar grupos
% Se tomarán las posiciones nominales para colocar el texto:
text(real(s2_vals(idx_nominal)) + 5, imag(s2_vals(idx_nominal)) + 5, 's_2', 'FontSize', 8);
text(real(s3_vals(idx_nominal)) + 5, imag(s3_vals(idx_nominal)) - 10, 's_3', 'FontSize', 8);
text(zero_vals(idx_nominal) + 5, 5, 'cero', 'FontSize', 8, 'Color', 'r');
text(real(s1) + 5, imag(s1) + 5, 's_1', 'FontSize', 8, 'Color', 'k');

% Ajustar límites del gráfico
buffer = 50;
x_min = min([real(s2_vals); real(s3_vals); zero_vals; s1_vec]) - buffer;
x_max = max([real(s2_vals); real(s3_vals); zero_vals; s1_vec]) + buffer;
y_min = min([imag(s2_vals); imag(s3_vals)]) - buffer;
y_max = max([imag(s2_vals); imag(s3_vals)]) + buffer;

if x_min >= x_max
    error('Error en los límites del eje X: x_min >= x_max');
end
if y_min >= y_max
    error('Error en los límites del eje Y: y_min >= y_max');
end

xlim([x_min, x_max]);
ylim([y_min, y_max]);

legend('Location', 'Best');
grid on; box on;
hold off;