% Cargar datos de la simulación
out1 = sim('SimulacionDT');
omega = out1.Wm(:,2);  % Velocidad angular
Tm = out1.Tm(:,2);     % Torque electromagnético
t = out1.tout;         % Vector de tiempo

% Definir los puntos de equilibrio conocidos
puntos_equilibrio = [
    0.00, 0.00;        % Punto 1
    404.14, 0.02;      % Punto 2
    387.23, 0.08;      % Punto 3
    414.55, -0.023;    % Punto 4
    9.36, -0.03;       % Punto 5
    -5.08, 0.02        % Punto 6
];

% Encontrar los índices más cercanos a los puntos de equilibrio
idx_equilibrio = zeros(size(puntos_equilibrio, 1), 1);
for i = 1:size(puntos_equilibrio, 1)
    [~, idx_equilibrio(i)] = min((omega - puntos_equilibrio(i,1)).^2 + ...
                                (Tm - puntos_equilibrio(i,2)).^2);
end
idx_equilibrio = sort(idx_equilibrio);  % Ordenar índices cronológicamente

% Graficar con diferentes colores
colores = {'b', 'r', 'g', 'm', 'c'};
nombres_colores = {'azul', 'rojo', 'verde', 'magenta', 'cian'};
figure
hold on
grid on

% Crear cell array para las leyendas
leyendas = cell(1, length(colores) + length(idx_equilibrio));

% Graficar cada segmento
for i = 1:length(idx_equilibrio)-1
    segmento = idx_equilibrio(i):idx_equilibrio(i+1);
    plot(omega(segmento), Tm(segmento), colores{mod(i-1,length(colores))+1}, 'LineWidth', 1.5)
    leyendas{i} = sprintf('Transitorio %d: línea %s', i, nombres_colores{mod(i-1,length(colores))+1});
end

% Marcar y etiquetar puntos de equilibrio
offset_y = 0.02;  % Offset vertical para el texto
for i = 1:length(idx_equilibrio)
    % Graficar punto
    plot(omega(idx_equilibrio(i)), Tm(idx_equilibrio(i)), 'k.', 'MarkerSize', 15)
    % Agregar número del punto centrado justo arriba del punto
    text(omega(idx_equilibrio(i)), Tm(idx_equilibrio(i)) + offset_y, num2str(i), ...
         'FontSize', 10, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', ... % Centrar horizontalmente
         'VerticalAlignment', 'bottom')       % Alinear desde abajo
    % Agregar a leyenda
    leyendas{length(colores)+i} = sprintf('P.E. %d: (%.2f rad/s, %.2f N.m)', ...
        i, omega(idx_equilibrio(i)), Tm(idx_equilibrio(i)));
end

xlabel('\omega_m [rad/s]')
ylabel('T_m [N.m]')
title('Curva Paramétrica \omega_m - T_m con Transitorios')

% Agregar leyenda completa
legend(leyendas, 'Location', 'best', 'FontSize', 8)