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
  
  + ¿Cuál de ellas le parece que contiene más información?

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los
  parámetros 2 y 3, y rellene la tabla siguiente con los valores obtenidos.

  |                        | LP   | LPCC | MFCC |
  |------------------------|:----:|:----:|:----:|
  | &rho;<sub>x</sub>[2,3] |      |      |      |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.
  
- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.

### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.

### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
 
### Test final y trabajo de ampliación.

- Recuerde adjuntar los ficheros `class_test.log` y `verif_test.log` correspondientes a la evaluación
  *ciega* final.

- Recuerde, también, enviar a Atenea un fichero en formato zip o tgz con la memoria con el trabajo
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como
  resultado del mismo.
