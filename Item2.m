% --------------------------- Circuito RLC - ITEM 2 ---------------------------
% Ramiro Javier Baigorria - 45833004 - Ing. Computacion
% Ejercicio: Deducir los valores de R, L y C del circuito
% Salida: Tension en el capacitor
% Metodo: Respuesta al Escalon (Chen)
% ---------------------------------------------------------------------------------

%pkg install -forge io
clear all; close all; clc
pkg load control
pkg load io
s=tf('s');

% ----------------------------------------------LECTURA DATOS DE EXCEL----------------------------------------------

datos = xlsread("C:/Users/ramir/OneDrive/Escritorio/Rami/Facu/Cuarto Año - Primer Semestre - Plan Nuevo/Sistemas de Control 2/Curvas_Medidas_RLC_2026.xlsx", 1, '', 'OCT');

tiempo = datos(:,1);   % Tiempo [Seg.]
i = datos(:,2);     % Corriente [A]
Vc = datos(:,3);    % Tensión en el capacitor [V]
Ve = datos(:,4);    % Tensión de entrada [V]
Vr = datos(:,5);    % Tensión de salida en la resistencia [V]

maxU = max(Ve)
K_Vc = abs(Ve(end)/maxU)  % K_Vc = valor final (asintótico) del capacitor.
K_I = abs(i(end)/maxU)    % K_I = valor final (asintótico) de la corriente.

% ----------------------------------------------PUNTOS CLAVE(Tension Capacitor)----------------------------------------------
% Tres valores de tiempo equidistantes a partir de que inicia la respuesta al escalón
t0_Vc = 0.1
dt = 0.01

%t1_Vc = t0_Vc + (t0_Vc - (2 * dt))
%t2_Vc = t0_Vc + (t0_Vc - (3 * dt))
%t3_Vc = t0_Vc + (t0_Vc - (4 * dt))

t1_Vc = t0_Vc + dt
t2_Vc = t0_Vc + ( 2 * dt )
t3_Vc = t0_Vc + ( 3 * dt )

VcRespectoT1 = interp1(tiempo, Vc, t1_Vc)
VcRespectoT2 = interp1(tiempo, Vc, t2_Vc)
VcRespectoT3 = interp1(tiempo, Vc, t3_Vc)

% ----------------------------------------------NORMALIZACION----------------------------------------------
% Para eliminar la dependencia del valor final del voltaje, el método define unos coeficientes de error o desviación

k1 = (VcRespectoT1 /(K_Vc * maxU)) - 1 % Coeficiente normalizado respecto al valor final
k2 = (VcRespectoT2 /(K_Vc * maxU)) - 1 % Coeficiente normalizado respecto al valor final
k3 = (VcRespectoT3 /(K_Vc * maxU)) - 1 % Coeficiente normalizado respecto al valor final

b = ( 4 * (k1^3) * k3 ) - ( 3 * (k1^2) * (k2^2) ) - ( 4 * (k2^3) ) + ( k3^2 ) + ( 6 * k1 * k2 * k3 )

alpha1 = ((k1 * k2 ) + k3 - (sqrt(b))) / ( 2 * (( k1^2 ) + k2));
alpha2 = ((k1 * k2 ) + k3 + (sqrt(b))) / ( 2 * (( k1^2 ) + k2));

%beta = ((2 * k1^3) + (3 * k1 * k2 ) + k3 - (sqrt(b))) / (sqrt(b)) --> MAL
beta = ( k1 + alpha2 ) / ( alpha1 - alpha2 )

T1 = -( dt / (log(alpha1)))
T2 = -( dt / (log(alpha2)))
realT1 = real(T1);
realT2 = real(T2);
T3 = beta * ( realT1 - realT2 ) + realT1


% ----------------------------------------------PUNTOS CLAVE (Corriente)----------------------------------------------
% Tres valores de corriente equidistantes a partir de que inicia la respuesta al escalón

t0Corriente = 0.1015
dtCorriente = 0.095

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
G_Vc = ( K_Vc ) / (((realT1 * s) + 1) * (( realT2 * s ) + 1 )) % Para T1 menor que T2 ; T3 distinto a T1 ; T3 distinto a T2
Vc_simulada = lsim(G_Vc, Ve, tiempo);

G_I = ( K_I * (( T3Corriente * s ) + 1 )) / ((( realT1Corriente * s ) + 1 ) * (( realT2Corriente * s ) + 1))
%G_I = ( K_I ) / ((( realT1Corriente * s ) + 1 ) * (( realT2Corriente * s ) + 1))
I_simulada = lsim(G_I, Ve, tiempo);


%----------------------------------------------Obtencion de parametros R, L y C----------------------------------------------



% ----------------------------------------------Graficos----------------------------------------------

%subplot(3,1,1); %Funcion que divide la ventana en 3 filas y 1 columna, y se posiciona en el primer espacio
  %plot(tiempo,Ve,'r','LineWidth', 1.5); hold on;
  %h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  %ylabel("Tension[V]","rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title("Entrada Escalon");
  %grid on;

subplot(2,1,1); %Funcion que divide la ventana en 3 filas y 1 columna, y se posiciona en el segundo espacio
  plot(tiempo, Vc, 'b', 'LineWidth', 1.7); hold on;
  plot(tiempo,Ve,'r--','LineWidth', 1.5);
  plot(t1_Vc,VcRespectoT1, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  plot(t2_Vc,VcRespectoT2, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  plot(t3_Vc,VcRespectoT3, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  plot(tiempo, Vc_simulada, 'g--', 'LineWidth', 1.5); hold off;
  h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Tension[V]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Tension Excel (Azul) VS Tension Simulada (Verde)');
  grid on;

subplot(2,1,2); %Funcion que divide la ventana en 3 filas y 1 columna, y se posiciona en el tercer espacio
  plot(tiempo, i, 'b', 'LineWidth', 1.5); hold on;
  %plot(tiempo,Ve,'r--','LineWidth', 1.5);
  %plot(t1Corriente,IRespectoT1, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  %plot(t2Corriente,IRespectoT2, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  %plot(t3Corriente,IRespectoT3, 'kx', 'MarkerSize', 2, 'LineWidth', 9);
  plot(tiempo, I_simulada, 'g', 'LineWidth', 1.5); hold off;
  h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Corriente[A]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Corriente Excel (Azul) VS Corriente Simulada (Verde)');
  grid on;
