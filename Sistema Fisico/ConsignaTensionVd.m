% Primera simulación con V*ds = +1.9596V
set_param('SimulacionDT/Vds*', 'After', '1.9596');      % Final value
set_param('SimulacionDT/Vds*', 'Before', '0');         % Initial value
set_param('SimulacionDT/Vds*', 'Time', '0.5');         % Step time
out1 = sim('SimulacionDT');
omega1 = out1.Wm(:,2);  % Tomar solo la primera columna
Tm1 = out1.Tm(:,2);
t1 = out1.tout;

% Segunda simulación con V*ds = -1.9596V
set_param('SimulacionDT/Vds*', 'After', '-1.9596');
set_param('SimulacionDT/Vds*', 'Before', '0');
set_param('SimulacionDT/Vds*', 'Time', '0.5');
out2 = sim('SimulacionDT');
omega2 = out2.Wm(:,2);
Tm2 = out2.Tm(:,2);
t2 = out2.tout;

% Tercera simulación con V*ds = 0V
set_param('SimulacionDT/Vds*', 'After', '0');
set_param('SimulacionDT/Vds*', 'Before', '0');
set_param('SimulacionDT/Vds*', 'Time', '0.5');
out3 = sim('SimulacionDT');
omega3 = out3.Wm(:,2);
Tm3 = out3.Tm(:,2);
t3 = out3.tout;

% Graficar todas las respuestas
figure
plot(t1, omega1, 'y-')
hold on
plot(t2, omega2, 'r-')
plot(t3, omega3, 'b-')
grid on
xlabel('Tiempo [s]')
ylabel('\omega_m [rad/s]')
legend('\omega_m Vds*>0', '\omega_m Vds*<0', '\omega_m Vds*=0')
title('Respuesta de Velocidad Angular para diferentes V_{ds}^*')

figure
plot(t1, Tm1, 'y-')
hold on
plot(t2, Tm2, 'r-')
plot(t3, Tm3, 'b-')
grid on
xlabel('Tiempo [s]')
ylabel('T_m [N.m]')
legend('T_m V_{ds}^*>0', 'T_m V_{ds}^*<0', 'T_m V_{ds}^*=0')
title('Respuesta de Torque Electromagnético para diferentes V_{ds}^*')