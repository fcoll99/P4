PAV - P4: reconocimiento y verificación del locutor
===================================================

Obtenga su copia del repositorio de la práctica accediendo a [Práctica 4](https://github.com/albino-pav/P4)
y pulsando sobre el botón `Fork` situado en la esquina superior derecha. A continuación, siga las
instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para crear una rama con el apellido de
los integrantes del grupo de prácticas, dar de alta al resto de integrantes como colaboradores del proyecto
y crear la copias locales del repositorio.

También debe descomprimir, en el directorio `PAV/P4`, el fichero [db_8mu.tgz](https://atenea.upc.edu/pluginfile.php/3145524/mod_assign/introattachment/0/spk_8mu.tgz?forcedownload=1)
con la base de datos oral que se utilizará en la parte experimental de la práctica.

Como entrega deberá realizar un *pull request* con el contenido de su copia del repositorio. Recuerde
que los ficheros entregados deberán estar en condiciones de ser ejecutados con sólo ejecutar:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  make release
  run_spkid mfcc train test classerr verify verifyerr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recuerde que, además de los trabajos indicados en esta parte básica, también deberá realizar un proyecto
de ampliación, del cual deberá subir una memoria explicativa a Atenea y los ficheros correspondientes al
repositorio de la práctica.

A modo de memoria de la parte básica, complete, en este mismo documento y usando el formato *markdown*, los
ejercicios indicados.

## Ejercicios.

### SPTK, Sox y los scripts de extracción de características.

- Analice el script `wav2lp.sh` y explique la misión de los distintos comandos, y sus opciones, involucrados
  en el *pipeline* principal (`sox`, `$X2X`, `$FRAME`, `$WINDOW` y `$LPC`).
  
   -**sox**:Todas las señales y ficheros que SPTK es capaz de leer, tienen el mismo formato de sucesión de reales en coma foltante de 32 bits sin ningun tipo de cabecera y forato (es decir raw); por lo tanto, el comando sox sirve para generar una señal con el formato adecuado a partir de una señal con otro formato (por ejemplo WAVE). En definitiva, convierte el archivo de entrada en formato raw.
   
   -**$X2X**:El comando X2X tal y como indica su nombre en inglés, permite la conversión a distinto formato de audio; convierte la señal de entrada a reales en coma flotante de 32 bits sin cabecera.
   
   -**$FRAME**: Divide la señal de entrada en tramas de X (comando -l)muestras con desplazamiento de ventana de Y(comando -p) muestras. En nuestro caso tramas de 240muestras y deslazamiento de 80muestras y, teniendo en cuenta que en esta práctica la frecuencia de muestreo es de 8kHz, equivale a 30ms y 10ms respectivamente.
   
   -**$WINDOW**: Multiplica cada trama por la ventana asignada (opción por defecto: Blackman).
   
   -**$LPC**: Calcula los `lpc_order` primeros coeficientes de predicción lineal, precedidos por el factor de ganancia del predictor.
  

- Explique el procedimiento seguido para obtener un fichero de formato *fmatrix* a partir de los ficheros
  de salida de SPTK (líneas 41 a 47 del script `wav2lp.sh`).
  
  Primeramente, observamos el comando orincipal para la extracción de caracteristicas que encadena los métodos acabados de explicar(sox, X2X, FRAME, WINDOW y LPC) y redireccionamos el resultado a un archivo base.FEAT siendo FEAT al tipo de parámetro (lp, lpcc o mfcc). Una vez almacenado el resultado de la parametrización en un fichero temporal, hemos de almacenar la información en un fichero fmatrix, cuyo numero de filas será 1+orden (debido a que el primer elemento correspnde a la ganancia de predicción) y, cuyo numero de columnas será el numero de tramas. Este es más dificl de calcular que el numero de filas ya que depende de la longitud de la señal y es variable; por lo tanto, usamos el comando x2x para convertiro a un formato con el que podamos contar el numero de líneas mediante wc-l.

  * ¿Por qué es conveniente usar este formato (u otro parecido)?
  
  Este formato nos permite tener los datos de una forma mucho más clara y accesible.

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales de predicción lineal
  (LPCC) en su fichero <code>scripts/wav2lpcc.sh</code>:
  
  ``` cpp
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 400 -p 80 | $WINDOW -l 400 -L 512 |
	$LPC -l 400 -m $lpc_order | $lpc2c -m $lpc_order -M $num_cepstral_coef> $base.lpcc
  ```

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales en escala Mel (MFCC) en
  su fichero <code>scripts/wav2mfcc.sh</code>:
  
  ``` cpp
  sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 240 -p 80 | $WINDOW -l 240 -L 240 |
	$MFCC -l 240 -m $mfcc_order > $base.mfcc
  ```

### Extracción de características.

- Inserte una imagen mostrando la dependencia entre los coeficientes 2 y 3 de las tres parametrizaciones
  para una señal de prueba.
  
  <img width="803" alt="coef2,3" src="https://user-images.githubusercontent.com/61736138/82123020-60510600-9797-11ea-95f4-fe4c97486300.png">
  
  + ¿Cuál de ellas le parece que contiene más información?
  
  Las parametrización que contiene más información son la MFCC y la LPCC debido a que los coeficientes están más incorrelados entre si; es decir, cada coeficiente nos aporta información distitna y no repetida. En el caso que estuvieran bastante correlados, la información que obtendriamos sería redundante en ocasiones, como podemos observar en el LP debido a que el coeficiente i+1 se calcula a aprtir del i. La correlación equivale a una cierta linealidad en la representación en la gráfica (como una especie de recta), mientras que la incorrelación, corresponde a la dispersión.
  

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los
  parámetros 2 y 3, y rellene la tabla siguiente con los valores obtenidos.
  
  Usando el comando el comando `pearson work/lp/BLOCK00/SES000/*.lp` se nos muestra una lista en orden descendiente de los coeficientes pearson entre todas las combinaciones posibles de coeficientes. Aplicando el comando superior también con los archivos .lpcc y .mfcc podemos rellenar la siguiente tabla:

  |                        |    LP     |    LPCC    |    MFCC    |
  |------------------------|:---------:|:----------:|:----------:|
  | &rho;<sub>x</sub>[2,3] | -0.816179 |  0.206626  |  0.0946808 |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
  Como se puede observar en la siguiente gráfica, el coeficiente pearson da cierta infromación acerca de la correlación entre coeficientes, de tal manera que cuanto más cercano sea a 0, más incorreladas y dispersas estan las muestras y, como más cercano a +-1 sea, mayor correlación y linealidad hay. Por lo tanto, observamos que el que presenta un coeficiente pearson más cercano a 0 es el MFCC que como ya habíamos dicho, era la parametrización más incorrelada y, el que presenta un coeficiente más eleveado es el LP, presentando cierta linealidad en su gráfico.
  
  ![Correlation_coefficient](https://user-images.githubusercontent.com/61736138/82122694-634af700-9795-11ea-9353-5d046084b778.png)

  
- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

Teóricamente, los valores adecuados para el orden del LPCC varian entre 8 y 12 puesto que siguen la formula (3/2)·p y,por otro lado, para el MFCC los valores presentan un rango distinto puesto que oscilan entre 14 y 20 coeficientes, en función del uso de la aplicación.

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.
  
 <img width="420" alt="ses061" src="https://user-images.githubusercontent.com/61736138/82124173-96918400-979d-11ea-90ce-7dc5342cd2fb.png">
  
  <img width="445" alt="gmm ses209" src="https://user-images.githubusercontent.com/61736138/82123843-cf305e00-979b-11ea-8979-2fe91eb3a8ac.png">
  
- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.
  
<img width="415" alt="gm061 mfcc061" src="https://user-images.githubusercontent.com/61736138/82124445-61863100-979f-11ea-85f5-cbef444bd0c2.png"><img width="437" alt="gm061 mfcc209" src="https://user-images.githubusercontent.com/61736138/82124448-66e37b80-979f-11ea-9093-bad3e469c972.png">

<img width="421" alt="gm209 mfcc209" src="https://user-images.githubusercontent.com/61736138/82124453-6b0f9900-979f-11ea-83ad-6578711b1370.png"><img width="422" alt="gm209 mfcc061" src="https://user-images.githubusercontent.com/61736138/82124456-6ea32000-979f-11ea-8beb-29d58f593fb1.png">

Hemos representado el locutor 061 en color verde (tanto su población como sus GMM) y el locutor 209 en color rojo. Podemos observar, como el modelado GMM es capaz de diferenciar considerablemente bien las señales de uno u otro. En el caso de que la población no corresponda al locutor, se pueden apreciar claros huecos en blanco (escasa población) que la GMM detecta como población elevada y al contrario, sitios donde hay mucha población que la GMM no incluye en su área. Por contra, si miramos los casos en los que si se trabaja con su correspondiente población, la aproximación es bastante buena.


### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.
  
  |                        |    LP    |   LPCC   |   MFCC   |
  |------------------------|:--------:|:--------:|:--------:|
  |      nºerrors          |    58    |    15    |    10    |
  |       total            |   785    |   785    |   785    |
  |       Error rate       |   7,39%  |   1,91%  |  1,27%   |

### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
  
  |                      |         MFCC       |  
  |----------------------|:------------------:|
  |        Threshold     |    0,645843653376  |                   
  |         Missed       |    41/250 = 0,164  |                   	   
  |       False alarm    |     0/1000 = 0     |  
  |     COST DETECTION   |      **16.4**      |  
 
 
### Test final y trabajo de ampliación.

- Recuerde adjuntar los ficheros `class_test.log` y `verif_test.log` correspondientes a la evaluación
  *ciega* final.
  
  Los archivos `class_test.log` y `verif_test.log` se encuentran en la carpeta `work`

- Recuerde, también, enviar a Atenea un fichero en formato zip o tgz con la memoria con el trabajo
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como
  resultado del mismo.
