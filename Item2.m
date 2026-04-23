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
K_Vc = abs(Ve(end)/maxU)  % K_Vc = valor final (asintótico) del capacitor

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

% ----------------------------------------------Sistema de segundo orden con 2 polos diferentes y un cero (Simulacion)----------------------------------------------
% G(s) = (K * 1) / (((T1 * s) + 1) * ((T2 * s) + 1))

G_Vc = ( K_Vc ) / (((realT1 * s) + 1) * (( realT2 * s ) + 1 )) % Para T1 menor que T2 ; T3 distinto a T1 ; T3 distinto a T2
Vc_simulada = lsim(G_Vc, Ve, tiempo);

%----------------------------------------------Obtencion de parametros R, L y C----------------------------------------------
% i(t) = (( C * dVc ) / dt ) => C = (( i * dt) / (dVc))

idx = find(tiempo >= 0.12 & tiempo <= 0.18);
dVc = diff(Vc(idx)); %La funcion diff se encarga de calcular la diferencia entre elementos adyacentes de un vector
dt  = diff(tiempo(idx));
iPromedio = i(idx(1:end-1));
cVector = ((iPromedio .* dt) ./ (dVc));
c = mean(cVector) %La función mean() calcula el promedio aritmético de los elementos de un vector. Es decir, suma todos los valores dentro del vector y los divide por la cantidad total de elementos.

[num, den] = tfdata(G_Vc, 'v'); % Extrae los coeficientes [LC, RC, 1]
% Como G_Vc = 1 / (T1*T2*s^2 + (T1+T2)s + 1)
L = den(1) / c
R = den(2) / c

% ----------------------------------------------Graficos----------------------------------------------

%subplot(3,1,1); %Funcion que divide la ventana en 3 filas y 1 columna, y se posiciona en el primer espacio
  %plot(tiempo,Ve,'r','LineWidth', 1.5); hold on;
  %h = xlabel("Tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  %ylabel("Tension[V]","rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title("Entrada Escalon");
  %grid on;

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
