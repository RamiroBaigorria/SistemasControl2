% --------------------------- Circuito RLC - ITEM 3 ---------------------------
% Ramiro Javier Baigorria - 45833004 - Ing. Computacion
% Ejercicio: Validar el Item 2 usando la corriente
% Salida: Corriente
% Metodo: Respuesta al Escalon (Chen)
% ---------------------------------------------------------------------------------

%pkg install -forge io
clear all; close all; clc
pkg load control
pkg load io
s=tf('s');

datos = xlsread("C:/Users/ramir/OneDrive/Escritorio/Rami/Facu/Cuarto Año - Primer Semestre - Plan Nuevo/Sistemas de Control 2/Curvas_Medidas_RLC_2026.xlsx", 1, '', 'OCT');

tiempo = datos(:,1);   % Tiempo [Seg.]
i = datos(:,2);     % Corriente [A]
Vc = datos(:,3);    % Tensión en el capacitor [V]
Ve = datos(:,4);    % Tensión de entrada [V]
Vr = datos(:,5);    % Tensión de salida en la resistencia [V]

maxU = max(Ve)
K_I = abs(i(end)/maxU)    % K_I = valor final (asintótico) de la corriente.

% ----------------------------------------------PUNTOS CLAVE (Corriente)----------------------------------------------
% Tres valores de corriente equidistantes a partir de que inicia la respuesta al escalón

t0Corriente = 0.1015
dtCorriente = 0.05

%t1Corriente = 2 * (t0Corriente - dt) + dt
%t2Corriente = 3 * (t0Corriente - dt) + dt
%t3Corriente = 4 * (t0Corriente - dt) + dt

t1Corriente = t0Corriente + dtCorriente
t2Corriente = t0Corriente + 2*dtCorriente
t3Corriente = t0Corriente + 3*dtCorriente

IRespectoT1 = interp1(tiempo, i, t1Corriente)
IRespectoT2 = interp1(tiempo, i, t2Corriente)
IRespectoT3 = interp1(tiempo, i, t3Corriente)

% ----------------------------------------------NORMALIZACION (Corriente)----------------------------------------------
% Para eliminar la dependencia del valor final de la corriente, el método define unos coeficientes de error o desviación

k1Corriente = ( IRespectoT1 / (K_I * maxU)) - 1;
k2Corriente = ( IRespectoT2 / (K_I * maxU)) - 1;
k3Corriente = ( IRespectoT3 / (K_I * maxU)) - 1;

bCorriente = ( 4 * (k1Corriente^3) * k3Corriente ) - ( 3 * k1Corriente^2 * k2Corriente^2 ) - ( 4 * k2Corriente^3 ) + ( k3Corriente^2 ) + ( 6 * k1Corriente * k2Corriente * k3Corriente )

alpha1Corriente = ((k1Corriente * k2Corriente ) + k3Corriente - (sqrt(bCorriente))) / ( 2 * (( k1Corriente^2 ) + k2Corriente));
alpha2Corriente = ((k1Corriente * k2Corriente ) + k3Corriente + (sqrt(bCorriente))) / ( 2 * (( k1Corriente^2 ) + k2Corriente));

betaCorriente = ( k1Corriente + alpha2Corriente ) / ( alpha1Corriente - alpha2Corriente )
T1Corriente = -( dtCorriente / (log(alpha1Corriente)))
T2Corriente = -( dtCorriente / (log(alpha2Corriente)))

realT1Corriente = real(T1Corriente);
realT2Corriente = real(T2Corriente);
T3Corriente = betaCorriente * ( realT1Corriente - realT2Corriente ) + realT1Corriente

% ----------------------------------------------Sistema de segundo orden con 2 polos diferentes y un cero (Simulacion)----------------------------------------------

G_I = ( K_I * (( T3Corriente * s ) + 1 )) / ((( realT1Corriente * s ) + 1 ) * (( realT2Corriente * s ) + 1))
%G_I = ( K_I ) / ((( realT1Corriente * s ) + 1 ) * (( realT2Corriente * s ) + 1))
I_simulada = lsim(G_I, Ve, tiempo);

% ----------------------------------------------Graficos----------------------------------------------

subplot(1,1,1);
  plot(tiempo, i, 'g', 'LineWidth', 1.8); hold on;
  %plot(tiempo,Ve,'r--','LineWidth', 1.5);
  %plot(t1Corriente,IRespectoT1, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  %plot(t2Corriente,IRespectoT2, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  %plot(t3Corriente,IRespectoT3, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  plot(tiempo, I_simulada, 'b--', 'LineWidth', 1.5); hold off;
  h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Corriente[A]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Corriente Excel (Verde) VS Corriente Simulada (Azul)');
  grid on;
