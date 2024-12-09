% Cargar datos de la simulación
out1 = sim('SimulacionControlador');
Tm = out1.Tm(:,2);     % Torque electromagnético
TmConsigna = out1.TmConsigna(:,2);
TorqueEq = out1.TorqueEq(:,2);
Tl = out1.Tl(:,2);
TFriccion = out1.TFriccion(:,2);
t = out1.tout;         % Vector de tiempo
figure
plot(t,TmConsigna,'g'); title('Torques en función del tiempo')
hold on
grid on
plot(t,Tm,'b');
plot(t,TorqueEq,'k');
plot(t,Tl,'r');
plot(t,TFriccion,'c');
legend('Consigna de Torque','Tm','Torque total aplicado','Torque Perturbacion','Torque Friccion');
xlabel('Tiempo [s]');
ylabel('Torque[N.m]')


%% Comparacion Rs constante y Rs variable
% Primera simulación con Rs constante
set_param('SimulacionControlador/Condicion_Rs', 'Value', '0');      % Resistencia constante
out2 = sim('SimulacionControlador');
TorqueEq2 = out2.TorqueEq(:,2);
omega1 = out2.Wm(:,2);
t2 = out2.tout;

% Segunda simulación con Rs constante
set_param('SimulacionControlador/Condicion_Rs', 'Value', '1');      % Resistencia variable
out3 = sim('SimulacionControlador');
TorqueEq3 = out3.TorqueEq(:,2);
omega2 = out3.Wm(:,2);
t3 = out3.tout;

%% Comparacion Torques
figure
plot(t,TmConsigna,'g');
hold on
plot(t2, TorqueEq2, 'r-')
plot(t3, TorqueEq3, 'b-')
grid on
xlabel('Tiempo [s]')
ylabel('T_m [N.m]')
legend('Consigna T*m','Torque equivalente Rs constante', 'Torque equivalente Rs variable')
title('Comparación de torques aplicados con Rs constante o variable')
%% Comparacion velocidades
figure
plot(t2, omega1, 'r-')
hold on
plot(t3, omega2, 'b-')
grid on
xlabel('Tiempo [s]')
ylabel('\omega_m [rad/s]')
legend('\omega_m Rs constante', '\omega_m Rs variable')
title('Respuesta de Velocidad Angular con Rs constante o variable')
