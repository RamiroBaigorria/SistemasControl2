% --------------------------- Circuito RLC serie ---------------------------
% Ramiro Javier Baigorria - 45833004 - Ing. Computacion
% Variables de ESTADO: x = [ i(t) , V_c(t) ]
% Entrada escalon: u = V_e(t)
% Salida: y = V_r(t) = R * i(t)
%
% Modelo en espacio de estados:
%   x_punto = ( A * x(t) ) + ( b * u(t) );
%   y = ( c^T ) * ( x(t) )

% ---------------------------------------------------------------------------------
% Item 1 - Asignar valores a :
% R = 2200 Ohm
% L = 500 mH = 0,5H
% C = 10uF = 00001F
% Obtener simulaciones que permitan estudiar la dinámica del sistema, con una entrada de...
% ... tensión escalón de 12V, que cada 10 ms cambia de signo.
% ---------------------------------------------------------------------------------

%Inicializacion del codigo
clear all; close all; clc;
pkg load control

% 1.1 Asigno los valores dados a los parametros
R = 2200;
L = 0.5;
C = 0.00001;
V_amplitud = 12.0;
T_cambioSigno = 0.01; % Periodo de cambio de signo de escalon

% ---------------------------------------------------------------------------------

% 1.2 Declaro las matricess
A = [ -R/L , -1/L ; 1/C , 0 ];
B = [ 1/L ; 0];
C = [ R ; 0 ]'; % Matriz C traspuesta
D= [ 0 ];

disp('Matriz del sistema (A):'), disp(A), fprintf('\n\n');
disp('Matriz de entrada (B):'), disp(B), fprintf('\n\n');
disp('Matriz de salida (C):'), disp(C), fprintf('\n\n');

% ---------------------------------------------------------------------------------

% 1.3 Usando la funcion ss (state-space) de octave, empaqueto las matrices y, posteriormente, lo grafico
sys=ss(A,B,C,D);

% ---------------------------------------------------------------------------------

% 1.4 Veo los polos para saber si es estable (o no)

disp('Polos del sistema:'), disp(pole(sys))

if all(real(pole(sys)) < 0)
  fprintf('  => Sistema ESTABLE \n\n');
else
  fprintf('  => Sistema INESTABLE\n\n');
end

% ---------------------------------------------------------------------------------

% 1.5 Declaracionde variables para la configuracion de la simulacion
deltaTiempo = 0.00001; % Paso [s]
totalTiempo = 0.1; % Tiempo total [s]
vectorTiempo = 0:deltaTiempo:totalTiempo; % Seteo vector "vectorTiempo" de 0 a 0.1s con pasos de 0.00001
tamanioTiempo = length(vectorTiempo); %Obtengo el valor del tamaño del vector "vectorTiempo"

% Generacion de la entrada escalon +12V/-12V que cambia de signo cada "T_cambioSigno"
senialEscalon = zeros(1, tamanioTiempo); % Asigno vector de entrada U que cambia de signo cada 10ms
for k = 1:tamanioTiempo
  n_periodo = floor(vectorTiempo(k) / T_cambioSigno);
  if mod(n_periodo, 2) == 0
    senialEscalon(k) = +V_amplitud;
  else
    senialEscalon(k) = -V_amplitud;
  end
end

% ---------------------------------------------------------------------------------

% 1.6 Simulacion
[y, vectorTiempo, x] = lsim(sys, senialEscalon, vectorTiempo); %LSIM toma el sistema (sys), la señal de entrada cuadrada (senialEscalon) y el vector de tiempo (vectorTiempo)
                                                    % y -> Guarda la salida del sistema (La tensión en la resistencia V_r)
                                                    % vectorTiempo -> Devuelve el vector de tiempo (útil si Octave lo ajusta).
                                                    % x(:,1) -> corriente i (t)
                                                    % x(:,2) -> tensión del capacitor Vc (t)
                                                    %tiempoMilisegundos = vectorTiempo * 1000; Si quisiese el tiempo en ms para graficos
figure;

% ---------------------------------------------------------------------------------

%1.7 Division de la ventana y Grafico
              % ( "rotation", 0 ) = Pone el texto del eje Y horizontal
              % ( "horizontalalignment", "right" ) = Alinea el texto para que no se choque con los números del eje.
              % ( grid on ) =  Pone la rejilla de fondo para poder medir valores a simple vista.
              %subplot(m, n, p) --> Sirve para dividir una sola ventana (figure) en una cuadricula con varios graficos pequeños. M=Numero de filas; N=Numero de columnas; P=Posicion de celda dividida que quiero modificar
              %plot(x, y, 'estilo', ...) --> Crea un gráfico de líneas conectando puntos de coordenadas. X=Vector con los datos del eje "x"; Y=Vector con los datos del eje "y"; ESTILO=Diseño de la celda; LINEWIDTH=Define el grosor de la linea

subplot(4,1,1); %Funcion que divide la ventana en 4 filas y 1 columna, y se posiciona en el primer espacio
  plot(vectorTiempo, senialEscalon, 'b', 'LineWidth', 1.5);
  h = xlabel("tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Tension[V]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Circuito RLC - | Entrada Escalon | V_e(t)');
  grid on;

subplot(4,1,2); %Funcion que divide la ventana en 4 filas y 1 columna, y se posiciona en el segundo espacio
  plot(vectorTiempo, x(:,2), 'm', 'LineWidth', 1.5);
  h = xlabel("tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Tension[V]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Circuito RLC - | Tension Capacitor | V_c(t)');
  grid on;

subplot(4,1,3); %Funcion que divide la ventana en 4 filas y 1 columna, y se posiciona en el tercer espacio
  plot(vectorTiempo, y, 'k', 'LineWidth', 1.5);
  h = xlabel("tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Tension[V]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Circuito RLC - | Señal Salida | Vr(t)');
  grid on;

subplot(4,1,4); %Funcion que divide la ventana en 4 filas y 1 columna, y se posiciona en el cuarto espacio
  plot(vectorTiempo, 10 * x(:,1), 'r', 'LineWidth', 1.5); %Multiplica la corriente por 1000 para verla en mA
  h = xlabel("tiempo[S]", "fontweight", "bold"); set(h, "horizontalalignment", "right");
  ylabel("Corriente [mA]", "rotation", 0, "fontweight", "bold", "horizontalalignment", "right"); title('Circuito RLC - | Corriente | i(t)');
  grid on;


