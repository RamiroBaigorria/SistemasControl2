% --------------------------- Motor de Corriente Continua con Torque de Carga - ITEM 4 ---------------------------
% Ramiro Javier Baigorria - 45833004 - Ing. Computacion
% Ejercicio: Obtener el torque máximo que puede soportar el motor modelado mediante las ecuaciones dadas
% ----------------------------------------------------------------------------------------------------------------

clear all; close all; clc
pkg load control
pkg load io
s=tf('s');

% ----------------------------------------------Parametros del Motor de Corriente Continua con Torque de Carga no Nulo----------------------------------------------
Laa = 0.000366; %366e-6;
J = 0.000000005; %5e-9;
Ra = 55.6;
Bm = 0;
Ki = 0.00649; %6.49e-3;
Km = 0.00653; %6.53e-3;


% ----------------------------------------------Parametros para la Simulacion----------------------------------------------

dt = 0.0000001; %1e-7 ----> paso de integracion [S]
Va = 12; %Tension de entrada [V]
tFinal = 5; %Tiempo final [S] para la velocidad angular y corriente ia
N = round(tFinal / dt)   % numero de pasos

TorqueMaximoTeorico = Ki * Va / Ra
tasaDeCambioTorque = (1.2 * TorqueMaximoTeorico) / tFinal   % El torque de carga: crece linealmente hasta 120% del maximo teorico[N·m/s]

% ----------------------------------------------Matrices del Sistema en Espacio de Estados----------------------------------------------
%  x = [ia, wr, theta]^T
%  xpunto = A*x + B*Va + E*TL

A = [-Ra/Laa,  -Km/Laa,  0;
      Ki/J,    -Bm/J,    0;
      0,        1,       0];

B = [1/Laa; 0; 0];

E = [0; -1/J; 0];

% ----------------------------------------------Vectores para guardar los resultados----------------------------------------------
i_vector = zeros(1, N);
wr_vector = zeros(1, N);
tiempo_vector  = zeros(1, N);
torque_vector = zeros(1, N);
theta_vector = zeros(1, N);


% ----------------------------------------------Condiciones iniciales para la Simulacion----------------------------------------------
ia = 0; % corriente inicial [A]
wr = 0; % velocidad angular inicial [rad/s]
theta = 0;  % posicion angular inicial [rad]

% ----------------------------------------------Euler----------------------------------------------
%  x[k+1] = x[k] + dt * (A*x[k] + B*Va + E*TL[k])
%
% Por componentes:
%  ia[k+1] = ia[k] + dt * (-Ra/Laa * ia[k] - Km/Laa * wr[k] + Va/Laa)
%  wr[k+1] = wr[k] + dt * ( Ki/J   * ia[k] - Bm/J   * wr[k] - TL[k]/J)
%  th[k+1] = th[k] + dt * ( wr[k] )

for k = 1:N

    tiempo_k  = k * dt;
    Torque_k = tasaDeCambioTorque * tiempo_k;

    tiempo_vector(k)  = tiempo_k; % Guardo el estado actual
    i_vector(k) = ia; % Guardo el estado actual
    wr_vector(k) = wr;  % Guardo el estado actual
    theta_vector(k) = theta;  % Guardo el estado actual
    torque_vector(k) = Torque_k;  % Guardo el estado actual

    di = -Ra/Laa * ia  -  Km/Laa * wr  +  Va/Laa; % Calculo derivada de la corriente
    dwr =  Ki/J   * ia  -  Bm/J   * wr  -  Torque_k/J;  % Calculo derivada de wr
    dtheta =  wr;

    ia = ia + dt * di;  %  ia[k+1] por euler
    wr = wr + dt * dwr; %  wr[k+1] por euler
    theta = theta + dt * dtheta;  %  th[k+1] por euler

end

% ----------------------------------------------Paso de Wr por cero (Momento STALL)----------------------------------------------
wrCero = find(wr_vector <= 0 & tiempo_vector > 0.01, 1);

fprintf('Motor detenido en t = ', tiempo_vector(wrCero), '[s]\n');
fprintf('Torque en STALL     = ', torque_vector(wrCero), '[N·m]\n');
fprintf('Corriente en STALL  = ', i_vector(wrCero)), '[A]\n';

% ----------------------------------------------Graficos----------------------------------------------

dec = 1000;
idx_plot = 1:dec:N;

tiempo_p  = tiempo_vector(idx_plot);
i_p = i_vector(idx_plot);
wr_p = wr_vector(idx_plot);
Torque_p = torque_vector(idx_plot);

figure(1);

subplot(1,1,1);
  plot(tiempo, Vc, 'b', 'LineWidth', 1.7); hold on;
  plot(tiempo,Ve,'r--','LineWidth', 1.5);
  plot(t1_Vc,VcRespectoT1, 'kx', 'MarkerSize', 4, 'LineWidth', 7);
  plot(t2_Vc,VcRespectoT2, 'kx', 'MarkerSize', 4, 'LineWidth', 7);
  plot(t3_Vc,VcRespectoT3, 'kx', 'MarkerSize', 4, 'LineWidth', 7);
  plot(tiempo, Vc_simulada, 'g--', 'LineWidth', 1.5); hold off;
  h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Tension[V]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Entrada Escalon(Rojo) VS Tension Excel (Azul) VS Tension Simulada (Verde)');
  grid on;

subplot(3,1,1);
  plot(tiempo_p, i_p * 1e3, 'b', 'LineWidth', 1.4);
  xline(tiempo_vector(wrCero), '--r', 'LineWidth', 1.2);
  yline(i_vector(wrCero) * 1e3, '--r', 'LineWidth', 1.2);
  ylabel('i_a(t) [mA]',"rotation", 0, "fontweight", "bold", "horizontalalignment", "right");
  title('Motor DC - TL creciente lineal | Va=12V, dt=1e-7s');
  grid on;

subplot(3,1,2);
  plot(tiempo_p, wr_p, 'r', 'LineWidth', 1.4);
  yline(0, 'k--', 'LineWidth', 1.0);
  xline(tiempo_vector(wrCero), '--r', 'LineWidth', 1.2);
  ylabel('\omega_r(t) [rad/s]',"rotation", 0, "fontweight", "bold", "horizontalalignment", "right");
  grid on;

subplot(3,1,3);
  plot(tiempo_p, Torque_p * 1e6, 'k', 'LineWidth', 1.4);
  xline(tiempo_vector(wrCero), '--r', 'Label', sprintf('t_{stall}=%.2fs', tiempo_vector(wrCero)), 'LineWidth', 1.2); % TL stall simulado
  yline(torque_vector(wrCero)*1e6, '--g', 'Label', sprintf('TL_{max}=%.2e N·m', torque_vector(wrCero)), 'LineWidth', 1.2); % TL stall teorico
  ylabel('T_L(t) [\muN·m]',"rotation", 0, "fontweight", "bold", "horizontalalignment", "right");
  xlabel('Tiempo [s]');
  grid on;
