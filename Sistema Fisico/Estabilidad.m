clc; clear; close all;

% Crear carpeta 'Imagenes' si no existe
if ~exist('Imagenes', 'dir')
    mkdir('Imagenes')
end

% Cargar Parámetros desde Parametros.m
% Asegúrate de que Parametros.m define todas las variables necesarias:
% J_eq, L_q, Rs_ref, b_eq, P_p, lambda_m
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

%% Determinación de los Ceros del Sistema
% G_Vqs(s) no tiene ceros finitos
% G_Tl(s) tiene un cero en s = -Rs_ref / L_q

zero_G_Tl = -Rs_ref / L_q;

disp(['El sistema tiene un cero en s = ', num2str(zero_G_Tl), ' rad/s']);

%% Evaluación de Estabilidad Completa
% Estabilidad completa: todos los polos tienen partes reales negativas
if all(real([s2_num, s3_num]) < 0)
    disp('El sistema es completamente estable (todos los polos tienen partes reales negativas).');
else
    disp('El sistema no es completamente estable (existe al menos un polo con parte real no negativa).');
end

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

% Ajustar límites del gráfico
buffer = 50;
x_min = min([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) - buffer;
x_max = max([real(s2_num), real(s3_num), zero_G_Tl, real(s1)]) + buffer;
y_min = min([imag(s2_num), imag(s3_num), imag(s1)]) - buffer;
y_max = max([imag(s2_num), imag(s3_num), imag(s1)]) + buffer;

% Verificar que x_min < x_max y y_min < y_max
if x_min >= x_max
    error('Error en los límites del eje X: x_min >= x_max');
end
if y_min >= y_max
    error('Error en los límites del eje Y: y_min >= y_max');
end

xlim([x_min, x_max]);
ylim([y_min, y_max]);

% Mejorar visualización
grid on;
box on;
hold off;

% Guardar el gráfico
saveas(gcf, 'Imagenes/polos_ceros_inicial.png');

%% Análisis de Variación de Parámetros (Ítem 4.b)
% Variación de Rs y observación de la migración de polos y ceros

% Definir un rango de variación para Rs_ref (por ejemplo, de 0.8*Rs_ref a 1.2*Rs_ref)
Rs_values = linspace(Rs_ref * 0.8, Rs_ref * 1.2, 50); % 50 puntos alrededor de Rs_ref

% Inicializar arrays para almacenar polos, ceros, omega_n y zeta
s2_vals = zeros(length(Rs_values), 1);
s3_vals = zeros(length(Rs_values), 1);
zero_vals = zeros(length(Rs_values), 1);
omega_n_vals = zeros(length(Rs_values), 1);
zeta_vals = zeros(length(Rs_values), 1);

for i = 1:length(Rs_values)
    % Actualizar Rs_ref en valores
    Rs_temp = Rs_values(i);
    
    % Recalcular coeficientes del polinomio con Rs_temp
    b_coeff_temp = J_eq * Rs_temp + b_eq * L_q;
    c_temp = b_eq * Rs_temp + (3/2) * P_p^2 * lambda_m^2;
    
    % Resolver el polinomio cuadrático
    soluciones_temp = solve(a * s^2 + b_coeff_temp * s + c_temp == 0, s);
    
    % Asignar soluciones
    s2_temp = double(soluciones_temp(1));
    s3_temp = double(soluciones_temp(2));
    
    % Almacenar los polos
    s2_vals(i) = s2_temp;
    s3_vals(i) = s3_temp;
    
    % Calcular y almacenar el cero correspondiente
    zero_vals(i) = -Rs_temp / L_q;
    
    % Calcular Frecuencia Natural y Factor de Amortiguamiento para s2
    sigma_temp = real(s2_temp);
    omega_n_imag_temp = abs(imag(s2_temp));
    omega_n_temp = sqrt(sigma_temp^2 + omega_n_imag_temp^2);
    zeta_temp = abs(sigma_temp) / omega_n_temp;
    
    % Almacenar los resultados
    omega_n_vals(i) = omega_n_temp;
    zeta_vals(i) = zeta_temp;
end

%% Generar Tabla en Formato LaTeX
fprintf('\\begin{table}[H]\n');
fprintf('    \\centering\n');
fprintf('    \\label{tab:variacion_Rs}\n');
% Definir el entorno tabular con 5 columnas
fprintf('    \\begin{tabular}{|c|c|c|c|c|}\n');
fprintf('        \\hline\n');
% Actualizar los títulos de las columnas, asegurando que coincidan con 5 columnas
fprintf('        \\textbf{Rs [ohms]} & \\textbf{Polos} & \\textbf{Cero} & \\textbf{\\(\\omega_n\\) [rad/s]} & \\textbf{\\(\\zeta\\)} \\\\\n');
fprintf('        \\hline\n');

for i = 1:4:length(Rs_values)
    % Formatear los polos como una única expresión compacta: s_{2,3} = a \pm bj
    fprintf('        %.3f & $s_{2,3} = %.1f \\pm %.1fj$ & %.2f & %.1f & %.2f \\\\\n', ...
            Rs_values(i), real(s2_vals(i)), abs(imag(s2_vals(i))), zero_vals(i), omega_n_vals(i), zeta_vals(i));
    fprintf('        \\hline\n');
end

fprintf('    \\end{tabular}\n');
fprintf('    \\caption{Variación de Rs y sus Efectos en Polos y Ceros}\n');
fprintf('\\end{table}\n');

%% Crear un vector de ceros para s1
s1_vec = real(s1) * ones(length(Rs_values), 1);

%% Ajustar límites del gráfico
buffer = 50;
x_min = min([real(s2_vals); real(s3_vals); zero_vals; s1_vec]) - buffer;
x_max = max([real(s2_vals); real(s3_vals); zero_vals; s1_vec]) + buffer;
y_min = min([imag(s2_vals); imag(s3_vals); imag(s1)*ones(length(Rs_values),1)]) - buffer;
y_max = max([imag(s2_vals); imag(s3_vals); imag(s1)*ones(length(Rs_values),1)]) + buffer;

% Verificar que x_min < x_max y y_min < y_max
if x_min >= x_max
    error('Error en los límites del eje X: x_min >= x_max');
end
if y_min >= y_max
    error('Error en los límites del eje Y: y_min >= y_max');
end

%% Graficar la migración de los polos y ceros
figure;
hold on; grid on; axis equal;
title('Migración de Polos y Ceros ante Variación de Rs');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

% Dibujar el eje real y el eje imaginario
xline(0, '--r', 'Eje Real');
yline(0, '--k', 'Eje Imaginario');

% Graficar la trayectoria de los polos s2 y s3
plot(real(s2_vals), imag(s2_vals), 'b-', 'LineWidth', 1.5);
plot(real(s3_vals), imag(s3_vals), 'b-', 'LineWidth', 1.5);

% Graficar la trayectoria de los ceros
plot(zero_vals, zeros(size(zero_vals)), 'r-', 'LineWidth', 1.5);

% Marcar el polo en el origen
plot(real(s1), imag(s1), 'ko', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Polo en el Origen');

% Agregar leyenda
legend('Trajectoria s_2', 'Trajectoria s_3', 'Trajectoria Ceros', 'Polo en el Origen', 'Location', 'Best');

% Ajustar límites del gráfico
xlim([x_min, x_max]);
ylim([y_min, y_max]);

% Mejorar visualización
grid on;
box on;
hold off;

%% Agregar anotaciones para algunos puntos específicos (opcional)
% Por ejemplo, anotar el punto central (Rs_ref)
idx_center = round(length(Rs_values)/2);
text(real(s2_num) + 5, imag(s2_num) + 5, 's_2', 'FontSize', 8);
text(real(s3_num) + 5, imag(s3_num) - 10, 's_3', 'FontSize', 8);
text(zero_G_Tl + 5, 5, 'cero', 'FontSize', 8, 'Color', 'r');