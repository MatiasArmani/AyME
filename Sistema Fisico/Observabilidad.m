% Análisis de Observabilidad para el Modelo LTI Equivalente Aumentado
% Salidas Medidas: θm(t) y ωm(t)

% Limpiar el entorno de trabajo
clear; clc; close all;

% Definir variables simbólicas
syms beq Jeq Pp lambda_m_prime Lq Rs s

% Definir la matriz de estado A para el sistema LTI equivalente aumentado
A = [0, 1, 0;
     0, -beq/Jeq, (3*Pp*lambda_m_prime)/(2*Jeq);
     0, (-Pp*lambda_m_prime)/Lq, -Rs/Lq];

% Definir las matrices de salida C para las dos salidas medidas
C_theta = [1, 0, 0];  % Medición de θm(t)
C_omega = [0, 1, 0];  % Medición de ωm(t)

% Orden del sistema
n = size(A,1);

% Construir las matrices de observabilidad para ambas salidas
O_theta = observability_matrix(A, C_theta, n);
O_omega = observability_matrix(A, C_omega, n);

% Calcular el rango de las matrices de observabilidad
rank_O_theta = rank(O_theta);
rank_O_omega = rank(O_omega);

% Mostrar resultados en la consola
fprintf('=== Análisis de Observabilidad ===\n\n');

% Observabilidad desde θm(t)
fprintf('**Observabilidad desde la salida medida θm(t):**\n');
disp('Matriz de Observabilidad O_{\theta}:');
disp(O_theta);
fprintf('Rango de O_{\theta}: %d\n', rank_O_theta);
if rank_O_theta == n
    fprintf('El sistema es completamente observable desde θm(t).\n\n');
else
    fprintf('El sistema NO es completamente observable desde θm(t).\n\n');
end

% Observabilidad desde ωm(t)
fprintf('**Observabilidad desde la salida medida ωm(t):**\n');
disp('Matriz de Observabilidad O_{\omega}:');
disp(O_omega);
fprintf('Rango de O_{\omega}: %d\n', rank_O_omega);
if rank_O_omega == n
    fprintf('El sistema es completamente observable desde ωm(t).\n\n');
else
    fprintf('El sistema NO es completamente observable desde ωm(t).\n\n');
end

% Generar expresiones simbólicas en LaTeX para la matriz de observabilidad
fprintf('=== Expresiones Simbólicas en LaTeX ===\n\n');

% Generar LaTeX para O_theta
latex_O_theta = matrix_to_latex(O_theta);
fprintf('\\textbf{Matriz de Observabilidad para }$\\theta_m(t)$:\\\\\n\\[\nO_{\\theta} = \\begin{bmatrix}\n%s\n\\end{bmatrix}\n\\]\n\n', latex_O_theta);

% Generar LaTeX para O_omega
latex_O_omega = matrix_to_latex(O_omega);
fprintf('\\textbf{Matriz de Observabilidad para }$\\omega_m(t)$:\\\\\n\\[\nO_{\\omega} = \\begin{bmatrix}\n%s\n\\end{bmatrix}\n\\]\n\n', latex_O_omega);

% Generar LaTeX para los rangos
fprintf('\\textbf{Rangos de las Matrices de Observabilidad:}\\\n\n');
fprintf('\\begin{itemize}\n');
fprintf('    \\item Rango de $O_{\\theta}$: %d\n', rank_O_theta);
fprintf('    \\item Rango de $O_{\\omega}$: %d\n', rank_O_omega);
fprintf('\\end{itemize}\n\n');

% Generar LaTeX para conclusiones sobre la observabilidad
if rank_O_theta == n
    observabilidad_theta = 'completamente observable';
else
    observabilidad_theta = 'NO completamente observable';
end

if rank_O_omega == n
    observabilidad_omega = 'completamente observable';
else
    observabilidad_omega = 'NO completamente observable';
end

fprintf('\\textbf{Conclusiones:}\\\n\n');
fprintf('El sistema es %s desde la salida medida $\\theta_m(t)$.\\\\\n', observabilidad_theta);
fprintf('El sistema es %s desde la salida medida $\\omega_m(t)$.\\\\\n', observabilidad_omega);

% Definición de funciones al final del script
% -------------------------------------------

% Función para construir la matriz de observabilidad
function O = observability_matrix(A, C, n)
    O = C;
    for i = 1:n-1
        O = [O; C*A^i];
    end
end

% Función para convertir matrices simbólicas a LaTeX
function latex_matrix = matrix_to_latex(O)
    latex_matrix = latex(O);
    % Reemplazar ',' por '&' y 'newline' por '\\\\' para formato LaTeX
    latex_matrix = strrep(latex_matrix, ',', ' & ');
    latex_matrix = strrep(latex_matrix, ';', ' \\\\ ');
end
