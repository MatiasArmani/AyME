clc; clear; close all;

% Cargar Parámetros desde Parametros.m
Parametros;

%% Definición del Polinomio Característico
% Polinomio: J_eq * L_q * s^2 + (J_eq * Rs_ref + b_eq * L_q) * s + (b_eq * Rs_ref + (3/2)*P_p^2*lambda_m^2) = 0

% Coeficientes del polinomio cuadrático
a = J_eq * L_q;
b_coeff = J_eq * Rs_ref + b_eq * L_q;
c = b_eq * Rs_ref + (3/2) * P_p^2 * lambda_m^2;

%% Solución Simbólica utilizando la Fórmula Resolvente
syms s

% Definición del polinomio
polinomio = a * s^2 + b_coeff * s + c;

% Aplicación de la fórmula resolvente
soluciones = solve(polinomio == 0, s);

% Asignación de las soluciones a s2 y s3
s2 = soluciones(1);
s3 = soluciones(2);

% Definir el polo en el origen
s1 = 0;

% Mostrar las soluciones simbólicas
disp('Las soluciones simbólicas del polinomio característico son:');
disp(['s1 = ', num2str(s1)]);
disp(['s2 = ', char(s2)]);
disp(['s3 = ', char(s3)]);

% Convertir soluciones simbólicas a formato LaTeX
s2_latex = latex(s2);
s3_latex = latex(s3);
disp('En LaTeX:');
fprintf('s_1 &= 0 \\\\ \n');
fprintf('s_2 &= %s \\\\ \n', s2_latex);
fprintf('s_3 &= %s \\\\ \n', s3_latex);

%% Sustitución de Valores Numéricos para Obtener las Soluciones Reales
valores = struct('J_eq', J_eq, ...
                'L_q', L_q, ...
                'Rs_ref', Rs_ref, ...
                'b_eq', b_eq, ...
                'P_p', P_p, ...
                'lambda_m', lambda_m);

% Sustituir los valores numéricos en las soluciones simbólicas
s2_num = double(subs(s2, valores));
s3_num = double(subs(s3, valores));

% Mostrar las soluciones numéricas
disp('Las soluciones numéricas del polinomio característico son:');
disp(['s1 = ', num2str(s1), ' rad/s']);
disp(['s2 = ', num2str(s2_num), ' rad/s']);
disp(['s3 = ', num2str(s3_num), ' rad/s']);

%% Cálculo de Frecuencia Natural y Factor de Amortiguamiento
% Para polos complejos conjugados s2 y s3 = -sigma ± j*omega_n

% Parte real e imaginaria de los polos
sigma = real(s2_num);
omega_n_imag = abs(imag(s2_num));

% Cálculo correcto de la frecuencia natural
omega_n = sqrt(sigma^2 + omega_n_imag^2);

% Factor de amortiguamiento
zeta = abs(sigma) / omega_n;

% Mostrar los resultados
fprintf('Frecuencia natural (omega_n) = %.2f rad/s\n', omega_n);
fprintf('Factor de amortiguamiento (zeta) = %.2f\n', zeta);

%% Determinación de los Ceros del Sistema
% G_Vqs(s) no tiene ceros finitos
% G_Tl(s) tiene un cero en s = -Rs_ref / L_q

zero_G_Tl = -Rs_ref / L_q;

disp(['El sistema tiene un cero en s = ', num2str(zero_G_Tl), ' rad/s']);

%% Graficar Polos y Ceros en el Plano s
figure;
hold on; grid on; axis equal;
title('Diagrama de Polos y Ceros del Sistema');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

% Dibujar el eje real y el eje imaginario
xline(0, '--r', 'Eje Real');
yline(0, '--k', 'Eje Imaginario');

% Dibujar los polos
plot(real(s2_num), imag(s2_num), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
plot(real(s3_num), imag(s3_num), 'bx', 'MarkerSize', 10, 'LineWidth', 2);

% Dibujar el cero
plot(zero_G_Tl, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Cero G_{T_l}(s)');

% Dibujar el polo en el origen
plot(real(s1), imag(s1), 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Polo en el Origen');

% Anotar los polos y el cero
text(real(s2_num) + 5, imag(s2_num) + 5, sprintf('s_2 = %.1f%+.1fj', real(s2_num), imag(s2_num)), 'FontSize', 8);
text(real(s3_num) + 5, imag(s3_num) - 10, sprintf('s_3 = %.1f%+.1fj', real(s3_num), imag(s3_num)), 'FontSize', 8);
text(zero_G_Tl + 5, 5, sprintf('Cero = %.1f rad/s', zero_G_Tl), 'FontSize', 8, 'Color', 'r');
text(real(s1) + 5, imag(s1) + 5, sprintf('s_1 = %.1f rad/s', real(s1)), 'FontSize', 8, 'Color', 'k');

% Agregar leyenda
legend('Polos', 'Cero G_{T_l}(s)', 'Polo en el Origen', 'Location', 'Best');

% Ajustar límites del gráfico
buffer = 50;
x_min = min([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) - buffer;
x_max = max([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) + buffer;
y_min = min([imag(s2_num), imag(s3_num), imag(s1)]) - buffer;
y_max = max([imag(s2_num), imag(s3_num), imag(s1)]) + buffer;
xlim([x_min, x_max]);
ylim([y_min, y_max]);

% Mejorar visualización
grid on;
box on;
hold off;

%% Evaluación de Estabilidad Completa
% Estabilidad completa: todos los polos tienen partes reales negativas
if all(real([s2_num, s3_num, s1]) < 0)
    disp('El sistema es completamente estable (todos los polos tienen partes reales negativas).');
else
    disp('El sistema no es completamente estable (existe al menos un polo con parte real no negativa).');
end
