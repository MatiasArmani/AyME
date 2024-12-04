% Script MATLAB para el desarrollo simbólico de las funciones de transferencia
% G_{V_{qs}}(s) y G_{T_{ld}}(s) del sistema descrito

% Asegúrate de tener el Symbolic Math Toolbox instalado

% Limpiar el entorno
clear; clc; close all;

% Definir variables simbólicas
syms s
syms theta_m omega_m i_qs_r v_qsr T_ld
syms J_eq P_p lambda_m_r b_eq r L_q R_s g k_l

% Definir las ecuaciones en el dominio de Laplace
% Ecuación 1: s*theta_m = omega_m
eq1 = s*theta_m == omega_m;

% Ecuación 2: s*omega_m = (1/J_eq)*( (3/2)*P_p*lambda_m_r*i_qs_r - b_eq*omega_m - (1/r)*T_ld - (g*k_l/r)*theta_m )
eq2 = s*omega_m == (1/J_eq)*( (3/2)*P_p*lambda_m_r*i_qs_r - b_eq*omega_m - (1/r)*T_ld - (g*k_l/r)*theta_m );

% Ecuación 3: s*i_qs_r = (1/L_q)*( v_qsr - R_s*i_qs_r - lambda_m_r*P_p*omega_m )
eq3 = s*i_qs_r == (1/L_q)*( v_qsr - R_s*i_qs_r - lambda_m_r*P_p*omega_m );

% Resolver el sistema de ecuaciones para theta_m, omega_m, y i_qs_r
% Utilizamos 'solve' para resolver el sistema completo
[theta_m_sol, omega_m_sol, i_qs_r_sol] = solve([eq1, eq2, eq3], [theta_m, omega_m, i_qs_r], 'ReturnConditions', false);

% Verificar si se encontraron soluciones
if isempty(theta_m_sol)
    error('No se pudo encontrar una solución explícita para theta_m(s). Verifica las ecuaciones y parámetros.');
end

% Expresar theta_m(s) en términos de v_qsr(s) y T_ld(s)
% Como el sistema es lineal, theta_m(s) se puede expresar como:
% theta_m(s) = G_Vqs(s)*v_qsr(s) + G_Tld(s)*T_ld(s)

% Sustituir las soluciones en theta_m_sol
% theta_m_sol ya está en términos de v_qsr y T_ld

% Simplificar la expresión de theta_m
theta_m_expr = simplify(theta_m_sol);

% Separar las funciones de transferencia G_Vqs(s) y G_Tld(s)
% Para ello, identificamos los coeficientes que multiplican a cada entrada

% Definir las entradas
entradas = [v_qsr, T_ld];

% Inicializar las funciones de transferencia
G_Vqs = 0;
G_Tld = 0;

% Extraer los coeficientes para cada entrada
for i = 1:length(entradas)
    % Obtener los coeficientes de la expresión respecto a cada entrada
    coeffi = coeffs(theta_m_expr, entradas(i));
    
    % coeffs devuelve un vector de coeficientes. Como la relación es lineal,
    % el coeficiente relevante es el que multiplica directamente a la entrada
    % Normalmente, es el segundo elemento para términos lineales, pero se verifica.
    
    % Verificar si la entrada está presente en la expresión
    if ~isempty(coeffi)
        % Asignar el coeficiente correspondiente
        if entradas(i) == v_qsr
            G_Vqs = simplify(coeffi(2)); % El coeficiente de v_qsr
        elseif entradas(i) == T_ld
            G_Tld = simplify(coeffi(2)); % El coeficiente de T_ld
        end
    else
        % Si la entrada no está presente, el coeficiente es cero
        if entradas(i) == v_qsr
            G_Vqs = 0;
        elseif entradas(i) == T_ld
            G_Tld = 0;
        end
    end
end

% Mostrar las funciones de transferencia
fprintf('Función de Transferencia G_{V_{qs}}(s):\n');
pretty(G_Vqs)
fprintf('\n\nFunción de Transferencia G_{T_{ld}}(s):\n');
pretty(G_Tld)

% Opcional: Mostrar las expresiones en formato LaTeX
disp(' ');
disp('Expresión de G_{V_{qs}}(s):');
latex(G_Vqs)
disp(' ');
disp('Expresión de G_{T_{ld}}(s):');
latex(G_Tld)
