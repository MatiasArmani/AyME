% Análisis de Controlabilidad para el Modelo LTI Equivalente Aumentado
% Entrada Manipulada: v_qsr(t), sin considerar la perturbación de la carga mecánica

% Limpiar el entorno de trabajo
clear; clc; close all;

% Definir variables simbólicas
syms beq Jeq Pp lambda_m_prime Lq Rs s

% Definir la matriz de estado A para el sistema LTI equivalente aumentado
A = [0, 1, 0;
     0, -beq/Jeq, (3*Pp*lambda_m_prime)/(2*Jeq);
     0, (-Pp*lambda_m_prime)/Lq, -Rs/Lq];

% Definir la matriz de entrada B para la entrada manipulada v_qsr(t)
B = [0;
     0;
     1/Lq];

% Orden del sistema
n = size(A,1);

% Construir la matriz de controlabilidad
C = controllability_matrix(A, B, n);

% Calcular el rango de la matriz de controlabilidad
rank_C = rank(C);

% Mostrar resultados en la consola
fprintf('=== Análisis de Controlabilidad ===\n\n');

% Controlabilidad desde v_qsr(t)
fprintf('**Controlabilidad desde la entrada manipulada $v_{qsr}(t)$:**\n');
disp('Matriz de Controlabilidad C:');
disp(C);
fprintf('Rango de C: %d\n', rank_C);
if rank_C == n
    fprintf('El sistema es completamente controlable desde $v_{qsr}(t)$.\n\n');
else
    fprintf('El sistema NO es completamente controlable desde $v_{qsr}(t)$.\n\n');
end

% Generar expresiones simbólicas en LaTeX para la matriz de controlabilidad
fprintf('=== Expresiones Simbólicas en LaTeX ===\n\n');

% Generar LaTeX para C
latex_C = matrix_to_latex(C);
fprintf('\\textbf{Matriz de Controlabilidad para $v_{qsr}(t)$}:\\\\\n\\[\nC = \\begin{bmatrix}\n%s\n\\end{bmatrix}\n\\]\n\n', latex_C);

% Generar LaTeX para los rangos
fprintf('\\textbf{Rangos de la Matriz de Controlabilidad:}\\\n\n');
fprintf('\\begin{itemize}\n');
fprintf('    \\item Rango de $C$: %d\n', rank_C);
fprintf('\\end{itemize}\n\n');

% Generar LaTeX para conclusiones sobre la controlabilidad
if rank_C == n
    controlabilidad = 'completamente controlable';
else
    controlabilidad = 'NO completamente controlable';
end

fprintf('\\textbf{Conclusiones:}\\\n\n');
fprintf('El sistema es %s desde la entrada manipulada $v_{qsr}(t)$.\\\\\n', controlabilidad);

% Definición de funciones al final del script
% -------------------------------------------

% Función para construir la matriz de controlabilidad
function C = controllability_matrix(A, B, n)
    C = B;
    for i = 1:n-1
        C = [C, A^i * B];
    end
end

% Función para convertir matrices simbólicas a LaTeX
function latex_matrix = matrix_to_latex(C)
    latex_matrix = latex(C);
    % Reemplazar ',' por '&' y 'newline' por '\\\\' para formato LaTeX
    latex_matrix = strrep(latex_matrix, ',', ' & ');
    latex_matrix = strrep(latex_matrix, ';', ' \\\\ ');
end