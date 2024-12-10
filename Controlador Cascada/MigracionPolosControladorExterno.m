clc; clear; close all;

% Parámetros conocidos
J_m = 14e-6; % Momento de inercia del motor [kg·m²]
r = 120; % Relación de transmisión
J_l_min = 0.0833; % Momento de inercia de carga mínimo [kg·m²]
J_l_nom = 0.4583; % Momento de inercia de carga nominal [kg·m²]
J_l_max = 0.4583; % Momento de inercia de carga máximo [kg·m²]

% Parámetros del controlador PID
omega_n = 800; % Frecuencia natural [rad/s]
zeta = 0.75; % Factor de amortiguamiento
n = 2.5; % Relación entre frecuencias características

% Cálculo de inercia equivalente
J_eq_min = J_m + J_l_min / r^2; % J_eq mínimo
J_eq_nom = J_m + J_l_nom / r^2; % J_eq nominal
J_eq_max = J_m + J_l_max / r^2; % J_eq máximo

% Imprimir valores de J_eq para verificar que cambian
fprintf('J_eq_min = %.4e kg·m²\n', J_eq_min);
fprintf('J_eq_nom = %.4e kg·m²\n', J_eq_nom);
fprintf('J_eq_max = %.4e kg·m²\n', J_eq_max);

% Calcular ganancias y polos para cada caso
[b_a_nom, K_sa_nom, K_sia_nom, poles_nominal] = calculate_controller_gains(J_eq_nom, omega_n, n);
[b_a_min, K_sa_min, K_sia_min, poles_min] = calculate_controller_gains(J_eq_min, omega_n, n);
[b_a_max, K_sa_max, K_sia_max, poles_max] = calculate_controller_gains(J_eq_max, omega_n, n);

% Imprimir resultados de las ganancias
fprintf('Ganancias para J_eq_min:\n');
fprintf('  b_a = %.4f Nm/(rad/s), K_sa = %.4f Nm/rad, K_sia = %.4f Nm/(rad·s)\n', b_a_min, K_sa_min, K_sia_min);
fprintf('Ganancias para J_eq_nom:\n');
fprintf('  b_a = %.4f Nm/(rad/s), K_sa = %.4f Nm/rad, K_sia = %.4f Nm/(rad·s)\n', b_a_nom, K_sa_nom, K_sia_nom);
fprintf('Ganancias para J_eq_max:\n');
fprintf('  b_a = %.4f Nm/(rad/s), K_sa = %.4f Nm/rad, K_sia = %.4f Nm/(rad·s)\n', b_a_max, K_sa_max, K_sia_max);

% Imprimir polos para verificar que cambian
fprintf('\nPolos para J_eq_min:\n');
disp(poles_min);
fprintf('Polos para J_eq_nom:\n');
disp(poles_nominal);
fprintf('Polos para J_eq_max:\n');
disp(poles_max);

% Graficar polos
figure;
hold on; grid on; axis equal;
title('Migración de Polos del Controlador PID');
xlabel('Re(s) [rad/s]');
ylabel('Im(s) [rad/s]');

% Ejes imaginarios y reales
xline(0, '--k', 'Eje Real');
yline(0, '--k', 'Eje Imaginario');

% Marcar polos
scatter(real(poles_min), imag(poles_min), 100, 'g', 'x', 'LineWidth', 2, 'DisplayName', 'Polos PID Mínimos');
scatter(real(poles_nominal), imag(poles_nominal), 100, 'm', 'x', 'LineWidth', 2, 'DisplayName', 'Polos PID Nominales');
scatter(real(poles_max), imag(poles_max), 100, 'c', 'x', 'LineWidth', 2, 'DisplayName', 'Polos PID Máximos');

% Etiquetas y leyenda
legend('Location', 'best');
hold off;

% Función para calcular ganancias y polos del controlador
function [b_a, K_sa, K_sia, poles] = calculate_controller_gains(J_eq, omega_n, n)
    % Ganancias del controlador
    b_a = J_eq * n * omega_n; % Ganancia proporcional (velocidad)
    K_sa = J_eq * n * omega_n^2; % Ganancia proporcional (posición)
    K_sia = J_eq * omega_n^3; % Ganancia integral (posición)
    
    % Polinomio característico del controlador: J_eq * s^3 + b_a * s^2 + K_sa * s + K_sia
    poly_controller = [J_eq, b_a, K_sa, K_sia]; % Coeficientes [s^3, s^2, s, 1]
    
    % Raíces del polinomio característico (polos)
    poles = roots(poly_controller);
end