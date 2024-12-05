clc; clear; close all;

% Inicialización del Toolbox Simbólico
syms J_eq L_q R_s b_eq P_p lambda_r_m s

% Definición de los coeficientes del polinomio cuadrático
a = J_eq * L_q;
b_coeff = J_eq * R_s + b_eq * L_q; % Renombrado para evitar conflicto con la variable 'b'
c = b_eq * R_s + (3/2) * P_p^2 * lambda_r_m^2;

% Definición del polinomio cuadrático igualado a cero
polinomio = a * s^2 + b_coeff * s + c == 0;

% Aplicación de la fórmula resolvente para encontrar las soluciones
soluciones = solve(polinomio, s);

% Asignación de las soluciones a s2 y s3
s2 = soluciones(1);
s3 = soluciones(2);

% Mostrar las soluciones simbólicas
disp('Las soluciones del polinomio característico son:');
disp(['s2 = ', char(s2)]);
disp(['s3 = ', char(s3)]);

% Mostrar las soluciones en formato LaTeX
disp('En LaTeX:');
fprintf('s_2 = %s\n', latex(s2));
fprintf('s_3 = %s\n', latex(s3));