% Script para análisis de migración de polos del controlador PID
clear all; close all; clc;

% Parámetros constantes
Jm = 14e-6;          % kg.m^2
m = 1.0;             % kg
lcm = 0.25;          % m
Jcm = 0.0208;        % kg.m^2
ll = 0.50;           % m
r = 120;             % relación de reducción
n = 2.5;             % parámetro de sintonía serie
zeta = 0.75;         % amortiguamiento deseado
wn = 800;            % frecuencia natural deseada (rad/s)

% Vector de masa de carga útil
ml_vector = linspace(0, 0.375, 100);
polos = zeros(length(ml_vector), 3); % Matriz para almacenar los polos

% Cálculo de Jl y Jeq nominal (ml = 0)
Jl_nom = (m*lcm^2 + Jcm) + 0*ll^2;
Jeq_nom = Jm + Jl_nom/r^2;

% Cálculo de ganancias con Jeq nominal (se mantienen fijas)
ba = Jeq_nom * n * wn;
Ksa = Jeq_nom * n * wn^2;
Ksia = Jeq_nom * wn^3;

% Cálculo de polos para cada valor de ml
for i = 1:length(ml_vector)
    % Cálculo de nueva Jeq para cada ml
    Jl = (m*lcm^2 + Jcm) + ml_vector(i)*ll^2;
    Jeq = Jm + Jl/r^2;
    
    % Polinomio característico con ganancias fijas y nueva Jeq
    coef = [Jeq, ba, Ksa, Ksia];
    polos(i,:) = roots(coef);
end

% Gráfico de migración de polos
figure('Name', 'Migración de Polos')
hold on; grid on;

% Graficar trayectorias de polos del controlador
plot(real(polos(:,1)), imag(polos(:,1)), 'b.', 'DisplayName', 'Polo 1')
plot(real(polos(:,2)), imag(polos(:,2)), 'r.', 'DisplayName', 'Polo 2')
plot(real(polos(:,3)), imag(polos(:,3)), 'g.', 'DisplayName', 'Polo 3')

% Agregar polos de lazo abierto de la planta
polo_planta1 = 0;
polo_planta2 = complex(-88.5, 149.9);
polo_planta3 = complex(-88.5, -149.9);

plot(real(polo_planta1), imag(polo_planta1), 'ko', 'MarkerSize', 10, ...
    'DisplayName', 'Polo planta = 0')
plot(real(polo_planta2), imag(polo_planta2), 'ko', 'MarkerSize', 10, ...
    'DisplayName', sprintf('Polos planta = -88.5 ± 149.9j'))
plot(real(polo_planta3), imag(polo_planta3), 'ko', 'MarkerSize', 10, 'HandleVisibility', 'off')

% Agregar polo del lazo de corriente
polo_corriente = -5000;
plot(polo_corriente, 0, 'mo', 'MarkerSize', 10, ...
    'DisplayName', 'Polo lazo corriente = -5000')

% Puntos límites para Jeq nominal (ml = 0)
plot(real(polos(1,1)), imag(polos(1,1)), 'bs', 'MarkerSize', 10, ...
    'DisplayName', sprintf('Polo 1 (nom) = %.2f', real(polos(1,1))))
plot(real(polos(1,2)), imag(polos(1,2)), 'rs', 'MarkerSize', 10, ...
    'DisplayName', sprintf('Polo 2,3 (nom) = %.2f ± %.2fi', real(polos(1,2)), abs(imag(polos(1,2)))))
plot(real(polos(1,3)), imag(polos(1,3)), 'gs', 'MarkerSize', 10, 'HandleVisibility', 'off')

% Puntos límites para Jeq máxima (ml = 0.375)
plot(real(polos(end,1)), imag(polos(end,1)), 'bd', 'MarkerSize', 10, ...
    'DisplayName', sprintf('Polo 1 (max) = %.2f', real(polos(end,1))))
plot(real(polos(end,2)), imag(polos(end,2)), 'rd', 'MarkerSize', 10, ...
    'DisplayName', sprintf('Polo 2,3 (max) = %.2f ± %.2fi', real(polos(end,2)), abs(imag(polos(end,2)))))
plot(real(polos(end,3)), imag(polos(end,3)), 'gd', 'MarkerSize', 10, 'HandleVisibility', 'off')

xlabel('Eje Real')
ylabel('Eje Imaginario')
title('Migración de polos al variar la masa de carga útil')
legend('Location', 'best')

% Hacer zoom en la región relevante (ajustar según necesidad)
xlim([-850 -450])
ylim([-800 800])

% Agregar líneas de ejes
plot([0 0], ylim, 'k--', 'HandleVisibility', 'off')
plot(xlim, [0 0], 'k--', 'HandleVisibility', 'off')

% Mostrar valores de polos para casos extremos
disp('Polos para ml = 0:')
disp(polos(1,:))
disp('Polos para ml = 0.375:')
disp(polos(end,:))

% Cálculo de amortiguamiento y frecuencia natural efectivos
for i = 1:length(ml_vector)
    polo_complejo = polos(i,2); % Tomamos uno de los polos complejos conjugados
    wn_eff(i) = abs(polo_complejo);
    zeta_eff(i) = -real(polo_complejo)/wn_eff(i);
end

% Gráfico de variación de parámetros
figure('Name', 'Variación de Parámetros')
subplot(2,1,1)
plot(ml_vector, wn_eff)
grid on
title('Frecuencia natural efectiva vs masa de carga')
xlabel('Masa de carga [kg]')
ylabel('\omega_n [rad/s]')

subplot(2,1,2)
plot(ml_vector, zeta_eff)
grid on
title('Amortiguamiento efectivo vs masa de carga')
xlabel('Masa de carga [kg]')
ylabel('\zeta')