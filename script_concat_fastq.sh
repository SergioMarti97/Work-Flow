#!/bin/bash


# Este escript fusiona los archivos .fastq.gz
#
#  	 ,_     _
#	 |\\_,-~/
#	 / _  _ |    ,--.
# 	(  @  @ )   / ,-'
#	 \  _T_/-._( (
#	 /         `. \
#	|         _  \ |
#	 \ \ ,  /      |
#	  || |-_\__   /
#	 ((_/`(____,
#
# Era necesario para trabajar con los datos de Luis Miguel
#
# Supongamos que los archivos se encuentran de esta forma:
#
# carpeta_fastq
#   ┃
#   ┣━ muestra_1_L001
#   ┃  ┣━ muestra_1_L001_right.fastq
#   ┃  ┗━ muestra_1_L001_left.fastq
#   ┣━ muestra_1_L002
#   ┃  ┣━ muestra_1_L002_right.fastq
#   ┃  ┗━ muestra_1_L002_left.fastq
#   ┃
#   ┣━ muestra_2_L001
#   ┃  ┣━ muestra_2_L001_right.fastq
#   ┃  ┗━ muestra_2_L001_left.fastq
#   ┣━ muestra_2_L002
#   ┃  ┣━ muestra_2_L002_right.fastq
#   ┃  ┗━ muestra_2_L002_left.fastq
#   ┃
#   ...
#   ┗━ muestra_n
#      ┣━ muestra_n_right.fastq
#      ┗━ muestra_n_left.fast
#
# Esto pasa porque habian muchas muestras y tubieron que utilizar dos cartuchos
# y secuenciar en dos flows cells. En resumen: L001 y L002 tienen la mitad de los
# reads cada uno. Hay que fusionar los archivos .fastq así:
# - muestra_x_L001_right + muestra_x_L002_right => muestra_x_right
# - muestra_x_L001_left + muestra_x_L002_left => muestra_x_left
#
# Antonio Galina nos ha recomendado usar la función concat "cat" para fusionar los
# .fastq
#
# Por parámetro, indicaremos en este orden:
# 1 - La dirección de "carpeta_fastq" (según el ejemplo de arriba)
# 2 - La dirección de salida. La carpeta donde se guardarán los archivos .fastq fusionados
#
# @date: 14/11/22
# @autor: Sergio Martí

# --- FUNCIONES --- #

function GetSampleName() {
	# Elimino el texto que no interesa y deja solo el nombre de la muestra
	sample_name=${1##*/}
	sample_name=${sample_name%%-ds.*}
	echo "$sample_name"
}

# --- SCRIPT --- #

# Compruebo que el número de parámetros del script sea el correcto
if [[ $# == 2 ]]; then
	# Para cada archivo en el directorio, que contenga "L001"
	for f1 in $1/*L001*; do
		file1=""
		file2=""
		# Compruebo que es un subdirectorio
		if [[ -d $f1 ]]; then
			# Guardo el nombre de la muestra 1
			sample_name1=$(GetSampleName $f1)
			dir1=$f1

			# Recorro todos los archivos del directorio que contengan "L002"
			for f2 in $1/*L002*; do
				# Compruebo que es un subdirectorio
				if [[ -d $f2 ]]; then
					# Guardo el nombre de la muestra 2
					sample_name2=$(GetSampleName $f2)

					# Compruebo que son la misma muestra
					if [[ ${sample_name1%%_L001*} = ${sample_name2%%_L002*} ]]; then
						# Guardo el nombre de la muestra 2
						sample_name=${sample_name1%%_L001*}
						dir2=$f2

						# Creamos en el directorio de salida, un subdirectorio para esta muestra
						output_sub_dir="$2/$sample_name"
						mkdir -p "$output_sub_dir"

						# Muestro por pantalla las muestras que se van a fusionar
						echo "$sample_name1 <-> $sample_name2"
						echo "Se van a concatenar los archivos de los directorios:"
						echo "Directorio 1: $dir1"
						echo "Directorio 2: $dir2"
						echo "El resultado se guardará en la carpeta: $output_sub_dir"

						# --- R1 --- #

						echo "Concatenando archivos R1"

						# Unir los .fastq R1 de L001 con los archivos .fastq R1 de L002
						file_R1_L001="$(find $dir1 -maxdepth 1 -name '*_R1_*' -print | head -n 1)"
						file_R1_L002="$(find $dir2 -maxdepth 1 -name '*_R1_*' -print | head -n 1)"
						echo "Archivo R1 L001: $file_R1_L001"
						echo "Archivo R1 L002: $file_R1_L002"

						out_file_R1=${file_R1_L001##*/}
						out_file_R1=${out_file_R1//"_L001"}
						echo "Se va a guardar el resultado de R1 en el archivo: $out_file_R1"
						echo "Ruta completa: $output_sub_dir/$out_file_R1"

						cat "$file_R1_L001" "$file_R1_L002" > "$output_sub_dir/$out_file_R1"

						# --- R2 --- #

						echo "Concatenando archivos R2"

						# Unir los .fastq R2 de L001 con los archivos .fastq R2 de L002
						file_R2_L001="$(find $dir1 -maxdepth 1 -name '*_R2_*' -print | head -n 1)"
						file_R2_L002="$(find $dir2 -maxdepth 1 -name '*_R2_*' -print | head -n 1)"
						echo "Archivo R2 L001: $file_R2_L001"
						echo "Archivo R2 L002: $file_R2_L002"

						out_file_R2=${file_R2_L001##*/}
						out_file_R2=${out_file_R2//"_L001"}
						echo "Se va a guardar el resultado de R1 en el archivo: $out_file_R2"
						echo "Ruta completa: $output_sub_dir/$out_file_R2"

						cat "$file_R2_L001" "$file_R2_L002" > "$output_sub_dir/$out_file_R2"

					fi
				fi
			done

			echo "-~-~"
		fi
	done
fi
