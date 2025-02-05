clc; clear; close all;


%% Carga mecánica -- Parámetros equivalentes variables (valor nominal +- var máx.)
b_l = 0.1;      %Fricción viscosa en la articulación
m = 1;          %Masa del brazo manipulador
l_cm = 0.25;    %Longitud equivalente (centro de masa)
J_cm = 0.0208;  %Inercia equivalente (centro de masa)
l_l=0.5;        %Longitud total (extremo)
dm = 0.1;
m_l = 0:dm:1.5;%Masa de Carga útil en extremo
J_l = (m*l_cm^2 + J_cm) + m_l(1)*l_l^2; %Momento de inercia total
k_l = m*l_cm + m_l(1)*l_l; % Coeficiente kl en torque de carga Tl
g = 9.80665;    %aceleración de gravedad
T_ld = 0;       % Torque de perturbación por contacto: 0 +- 5Nm (escalón)

%% Tren de Transmisión
r = 120;
n_lnom = 60; w_lnom = 6.28; %Velocidad nominal (salida)
T_qnom = 17;                %Torque nominal (salida)
T_qmax = 45;                %Torque pico (salida)

%% Máquina Eléctrica PMSM -- Parámetros (valores nominales medidos, tolerancia error+/- 1%; salvo aclaración específica)
J_m = 14E-6;    %Momento de inercia (motor y caja)
b_m = 15E-6;    %Coef. fricción viscosa (motor y caja)
P_p = 3;        %Pares de Polos magnéticos
lambda_m = 0.016; %Flujo magnético equivalente de imanes concatenado por espiras del bobinado de estator
L_q = 5.8E-3;   %Inductancia de estator (eje en cuadratura)
L_d = 6.6E-3;   %Inductancia de estator (eje directo)
L_ls = 0.8E-3;  %Inductancia de dispersión de estator
Rs_ref = 1.02;      %Resistencia de estator, por fase. Valor nominal para una Tref = 20°C
Tsref = 20;
alfa_cu = 3.9E-3; %Coef. aumento de Rs con T°s
C_ts = 0.818;   %Capacitancia térmica de estator. Almacenamiento interno de calor.
R_tsamb = 146.7;%Resistencia térmica estator-ambiente. Disipación al ambiente.
%Nota: Se puede definir constante de tiempo térmica:

n_mnom = 6600; w_mnom = 691.15;         %Velocidad nominal rotor
V_slnom = 30; V_sfnom = V_slnom/sqrt(3);%Tensión nominal de línea
I_snom = 0.4;                           %Corriente nominal
I_smax = 2;                             %Corriente máxima
T_smax = 115;                           %Temperatura máxima de bobinado estator
dT = 1;
T_amb = -15:dT:40;                      %Rango de temperatura ambiente de Operación

%% Inversor trifásico de alimentación (modulador de tensión)
dV = 1;
V_sl = 0:dV:48;
df = 1;
f_e = -330:df:330;

%% Parametros equivalentes
J_eq = J_m + J_l/(r^2);
b_eq = b_m + b_l/(r^2);

%% Condiciones Iniciales
I_d0 = 0;
Tita_0 = 0;
Ts_0 = 20;

%% Parametros de simulacion
Rs_condicion = 0;

%% Ganancias de Controlador 
% b_a = 1;
% K_sa = 1;
% K_sia = 1;

b_a = 0.039;
K_sa = 31.656*20;
K_sia = 10129.78;

%% Observador
Ke_w = 1.024e7;
Ke_t = 6.4e3;
Ke_int = 3.2768e10;

%% Sensores No Ideales
% Parámetros para cada sensor
wn_iabc = 30000;    % Frecuencia natural para sensores de corriente [rad/s] min= 25800
xi_iabc = 1;       % Factor de amortiguamiento para sensores de corriente

wn_pos = 30000;     % Frecuencia natural para sensor de posición [rad/s]
xi_pos = 1;        % Factor de amortiguamiento para sensor de posición

tau = 0.1;          % Constante de tiempo para sensor de temperatura [s]

% Matrices para sensores de corriente
Sni_A_iabc = [0 -1; wn_iabc^2 -2*wn_iabc*xi_iabc];
Sni_B_iabc = [1; 0];
Sni_C_iabc = [0 1];
Sni_D_iabc = 0;

% Matrices para sensor de posición
Sni_A_pos = [0 -1; wn_pos^2 -2*wn_pos*xi_pos];
Sni_B_pos = [1; 0];
Sni_C_pos = [0 1];
Sni_D_pos = 0;

% Matrices para sensor de temperatura
Sni_A_T = -1/tau;
Sni_B_T = 1;
Sni_C_T = 1/tau;
Sni_D_T = 0;

%Parámetros para modulador de tensión No Ideal
wn_mod = 20000;
zita_mod = 1;
V_slmax = 48;

% Matrices para modulador de tension No Ideal
Mni_A = [0 -1; wn_mod^2 -2*zita_mod*wn_mod];
Mni_B = [1;0];
Mni_C = [0 1];
Mni_D = 0;

%% Tiempo de muestreo para controlador discretizado
%Ts = 1.25E-4; 

Ts = 3.14E-5;
%Ts = 1.25E-5; 

function f = frecuencia(f_e,elemento)
    f = f_e(elemento);
end
