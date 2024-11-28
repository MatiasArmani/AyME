clc, clear, close

% Definir las variables simbólicas
syms theta_m(t) omega_m(t) i_qs(t) i_ds(t) i_0s(t) T_s(t) % Variables de estado
syms J_eq P_p L_d L_q lambda_m b_eq g k_l r T_ld(t)       % Parámetros del sistema
syms v_qs(t) v_ds(t) v_0s(t) R_s R_s_ref alpha_cu Ts_ref L_ls C_ts R_ts_amb T_amb(t) % Parámetros adicionales

% Definir las expresiones de las ecuaciones (a la derecha del =)
f1 = omega_m(t); % Primera ecuación: theta_m_dot = omega_m(t)
f2 = (1 / J_eq) * ( (3/2) * P_p * (lambda_m * i_qs(t) + (L_d - L_q) * i_ds(t) * i_qs(t)) - b_eq * omega_m(t) - g * k_l * sin(theta_m(t) / r) + (1 / r) * T_ld(t) );
f3 = (1 / L_q) * ( v_qs(t) - R_s * i_qs(t) - (lambda_m + L_d * i_ds(t)) * P_p * omega_m(t) );
f4 = (1 / L_d) * ( v_ds(t) - R_s * i_ds(t) + L_q * i_qs(t) * P_p * omega_m(t) );
f5 = (1 / L_ls) * (v_0s(t) - R_s * i_0s(t));
f6 = (1 / C_ts) * ( (3/2) * R_s * (i_qs(t)^2 + i_ds(t)^2 + 2 * i_0s(t)^2) - (1 / R_ts_amb) * (T_s(t) - T_amb(t)) );

% Variables de estado
states = [theta_m(t), omega_m(t), i_qs(t), i_ds(t), i_0s(t), T_s(t)];

% Entradas de control
inputs_control = [v_qs(t), v_ds(t), v_0s(t)];

% Entradas de perturbación
inputs_disturbance = [T_ld(t), T_amb(t)];

% Definir las ecuaciones como un vector
equations = [f1, f2, f3, f4, f5, f6];

% Inicializar matrices Jacobianas
jacobian_matrix = sym(zeros(length(equations), length(states))); % Matriz A0
B0c_matrix = sym(zeros(length(equations), length(inputs_control))); % Matriz B0c
B0d_matrix = sym(zeros(length(equations), length(inputs_disturbance))); % Matriz B0d

% Calcular derivadas parciales para A0 (respecto a los estados)
for i = 1:length(equations)
    for j = 1:length(states)
        if j == 6  % Si estamos derivando respecto al estado T_s(t)
            % Reemplazar R_s con su expresión completa solo cuando derivamos respecto a T_s(t)
            equations_with_R_s = equations(i);
            equations_with_R_s = subs(equations_with_R_s, R_s, R_s_ref * (1 + alpha_cu * (T_s(t) - Ts_ref)));
            jacobian_matrix(i, j) = diff(equations_with_R_s, states(j)); % Derivada parcial con la expresión completa de R_s
        else
            jacobian_matrix(i, j) = diff(equations(i), states(j)); % Derivada normal
        end
    end
end

% Calcular derivadas parciales para B0c (respecto a las entradas de control)
for i = 1:length(equations)
    for j = 1:length(inputs_control)
        B0c_matrix(i, j) = diff(equations(i), inputs_control(j));
    end
end

% Calcular derivadas parciales para B0d (respecto a las entradas de perturbación)
for i = 1:length(equations)
    for j = 1:length(inputs_disturbance)
        B0d_matrix(i, j) = diff(equations(i), inputs_disturbance(j));
    end
end

% Mostrar las matrices Jacobianas simbólicas
disp('--- Matriz A0 (respecto a estados) ---');
disp(jacobian_matrix);

disp('--- Matriz B0c (respecto a entradas de control) ---');
disp(B0c_matrix);

disp('--- Matriz B0d (respecto a entradas de perturbación) ---');
disp(B0d_matrix);

% Generar las expresiones en LaTeX para las tres matrices
disp('--- Expresiones en LaTeX ---');

latex_A0 = latex(jacobian_matrix);
latex_B0c = latex(B0c_matrix);
latex_B0d = latex(B0d_matrix);

disp('Matriz A0 en LaTeX:');
disp(latex_A0);

disp('Matriz B0c en LaTeX:');
disp(latex_B0c);

disp('Matriz B0d en LaTeX:');
disp(latex_B0d);