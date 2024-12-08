% Cargar datos de la simulación
out1 = sim('SimulacionDT');
omega = out1.Wm(:,2);  % Velocidad angular
Tm = out1.Tm(:,2);     % Torque electromagnético
t = out1.tout;         % Vector de tiempo

% Calcular la derivada para detectar cambios bruscos de dirección
d_omega = diff(omega);
d_Tm = diff(Tm);
velocidad = sqrt(d_omega.^2 + d_Tm.^2);

% Calcular curvatura con ventana más grande
ventana = 50;  % Aumentar tamaño de la ventana
curvatura = zeros(size(velocidad));
for i = ventana+1:length(velocidad)-ventana
    v1 = [d_omega(i), d_Tm(i)];
    v2 = [d_omega(i-ventana), d_Tm(i-ventana)];
    curvatura(i) = abs(atan2(v1(1)*v2(2)-v1(2)*v2(1), v1(1)*v2(1)+v1(2)*v2(2)));
end

% Ajustar umbrales para detectar solo los cambios más significativos
umbral_curvatura = 0.95 * max(curvatura);  % Umbral más alto
umbral_velocidad = 0.05 * max(velocidad);   % Umbral más bajo
idx_candidatos = find(curvatura > umbral_curvatura & velocidad < umbral_velocidad);

% Aumentar la distancia mínima entre puntos
distancia_min = 500;  % Distancia mínima mucho mayor
idx_equilibrio = [1];  % Incluir punto inicial
for i = 1:length(idx_candidatos)
    if all(abs(idx_candidatos(i) - idx_equilibrio) > distancia_min)
        idx_equilibrio = [idx_equilibrio; idx_candidatos(i)];
    end
end
if length(idx_equilibrio) < 6  % Si detectamos menos de 6 puntos
    idx_equilibrio = [idx_equilibrio; length(omega)];  % Incluir punto final
end

% Asegurarnos de tener solo 6 puntos
if length(idx_equilibrio) > 6
    % Seleccionar los puntos más significativos basados en la curvatura
    [~, idx_sort] = sort(curvatura(idx_equilibrio(2:end-1)), 'descend');
    idx_equilibrio = sort([1; idx_equilibrio(idx_sort(1:4)+1); length(omega)]);
end

% Graficar los segmentos entre puntos de equilibrio con diferentes colores
colores = {'b', 'r', 'g', 'm', 'c', 'y'};
figure
hold on
grid on

% Graficar cada segmento
for i = 1:length(idx_equilibrio)-1
    segmento = idx_equilibrio(i):idx_equilibrio(i+1);
    plot(omega(segmento), Tm(segmento), colores{mod(i-1,length(colores))+1}, 'LineWidth', 1.5)
    % Marcar puntos de equilibrio
    plot(omega(idx_equilibrio(i)), Tm(idx_equilibrio(i)), 'k.', 'MarkerSize', 15)
end
% Marcar el último punto de equilibrio
plot(omega(idx_equilibrio(end)), Tm(idx_equilibrio(end)), 'k.', 'MarkerSize', 15)

% Mostrar coordenadas de los puntos de equilibrio
for i = 1:length(idx_equilibrio)
    fprintf('Punto de equilibrio %d: ω = %.2f rad/s, Tm = %.2f N.m\n', ...
        i, omega(idx_equilibrio(i)), Tm(idx_equilibrio(i)))
end

xlabel('\omega_m [rad/s]')
ylabel('T_m [N.m]')
title('Curva Paramétrica \omega_m - T_m con Transitorios')