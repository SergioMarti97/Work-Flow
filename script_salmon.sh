#!/bin/bash

# Este script de bash sirve para ejecutar SALMON sobre un conjunto de archivos .fastq
#
# 	      /`·.¸
#	     /¸...¸`:·
#	 ¸.·´  ¸   `·.¸.·´)
#	: © ):´;      ¸  {
#	 `·.¸ `·  ¸.·´\`·¸)
#	     `\\´´\¸.
#
# Se supone que los archivos se encuentran estructurados de esta forma:
#
# carpeta_fastq
#   ┣━ muestra_1
#   ┃  ┣━ muestra_1_right.fastq
#   ┃  ┗━ muestra_1_left.fastq
#   ┣━ muestra_2
#   ┃  ┣━ muestra_2_right.fastq
#   ┃  ┗━ muestra_2_left.fastq
#   ┣━ muestra_3
#   ┃  ┣━ muestra_3_right.fastq
#   ┃  ┗━ muestra_3_left.fastq
#   ...
#   ┗━ muestra_n
#      ┣━ muestra_n_right.fastq
#      ┗━ muestra_n_left.fastq
#
# Por parámetro, indicaremos en este orden:
# 1 - La dirección de "carpeta_fastq" (según el ejemplo de arriba)
# 2 - El indice de la especie que usará SALMON para contar los transcritos
# 3 - La carpeta de salida donde se guadarán los archivos de salida
#
# NOTA: ¡Las direcciones de las carpetas tienen que ir sin la "/" final!
#
# Se ha hecho para cuantificar la expresion de los transcritos de
# la secuenciación realizada por Luis Miguel Valor.
#
# @see: https://combine-lab.github.io/salmon/getting_started/
# @date: 12/11/2022
# @autor: Sergio Martí

# --- SCRIPT --- #

# Compruebo que el número de parámetros del script sea correcto
if [[ $# == 3 ]]; then
	# Limpio el archivo .csv con los nombres de los archivos procesados
	rm -f "$3/salmon_quant_files.csv"
	# Añado la cabecera del archivo .csv
	echo "sample,ubi,timestamp" >> "$3/salmon_quant_files.csv"

	# Recorro todos los archivos dentro del directorio pasado por parámetro 1
	for f in $1/*; do
		fastq_l="" # nombre del archivo .fastq con los reads left
		fastq_r="" # nombre del archivo .fastq con los reads right

		# Recorro todos los archivos dentro del subdirectorio
		for fastq_file in $f/*; do

			# Medinate el comando "test" (su versión abreviada: "[[ ]]") utilizo el operador "=~"
			# que se utiliza para usar expresiones regex.

			# Si el archivo contiene "_R1_" en el nombre, es el archivo .fastq left
			if [[ "$fastq_file" =~ "_R1_" ]]; then
				fastq_l="$fastq_file"
			fi

			# Si el archivo contiene "_R2_" en el nombre, es el archivo .fastq right
			if [[ "$fastq_file" =~ "_R2_" ]]; then
				fastq_r="$fastq_file"
			fi

		done

		# Compruebo que el subdirectorio tiene los archivos .fastq con los reads left y right
		if [[ "$fastq_l" = "" || "$fastq_r" = "" ]]; then
			echo "No encontrado los archivos .fastq necesarios en $f"
		else
			# Elimino el path de delante
			output_sample_dir=${fastq_l##*/}
			# Elimino todas las extensiones del nombre del archivo
			output_sample_dir=${output_sample_dir%%.*}
			# Eliminar la parte _R1_001
			output_sample_dir=${output_sample_dir%_R1_001}

			# Muestro por consola que se va a ejecutar SALMON
			echo "Procesando los archivos .fastq de $f"

			# Ejecuto SALMON:
			# Flag --gcBias recomendada por Luis Miguel
			salmon quant -i $2 -l A -1 $fastq_l -2 $fastq_r -p 10 --validateMappings --gcBias -o "$3/$output_sample_dir"

			# Para trabajar posteriormente con los datos generados, guardo la información en un archivo .csv
			echo "$output_sample_dir,$3/$output_sample_dir,$(date +'%Y%m%d_%H%M%S')" >> "$3/salmon_quant_files.csv"

			# Para que la carpeta con los resultados pese menos, comprimo el archivo generado .sf
			gzip "$3/$output_sample_dir/quant.sf"

		fi

	done
else
	# Si no se han pasado el número correcto de parámetros, se muestra por consola el funcionamiento del script
	echo "Uso: $0 carpeta_fastq idx_specie carpeta_output"
fi
