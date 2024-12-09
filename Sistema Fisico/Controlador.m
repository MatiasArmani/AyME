% Obtener handles
ti_park_block = find_system('SimulacionDT', 'Name', 'TI_Park');
vqs_in = find_system('SimulacionDT', 'Name', '3');
vds_in = find_system('SimulacionDT', 'Name', '4');
v0s_block = find_system('SimulacionDT', 'Name', 'V0s*');
controlador = find_system('SimulacionDT', 'Name', 'Controlador');

% Mover los bloques al subsistema Controlador
Simulink.SubSystem.moveBlock(ti_park_block, controlador);
Simulink.SubSystem.moveBlock(vqs_in, controlador);
Simulink.SubSystem.moveBlock(vds_in, controlador);
Simulink.SubSystem.moveBlock(v0s_block, controlador);