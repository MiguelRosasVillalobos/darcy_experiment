#!/bin/bash
#Miguel Rosas

# Lista de valores para lc
valores_porosidad=("0.9" "0.8" "0.7" "0.6" "0.5" "0.4" "0.3")

# Verifica si se proporciona la cantidad como argumento
if [ $# -eq 0 ]; then
	echo "Uso: $0 cantidad"
	exit 1
fi

# Obtiene la cantidad desde el primer argumento
cantidad=$1

# Bucle para crear y mover carpetas, editar y genrar mallado
for ((i = 1; i <= $cantidad; i++)); do
	# Genera el nombre de la carpeta
	nombre_carpeta="Case_$i"

	# Crea la carpeta del caso
	mkdir "$nombre_carpeta"

	# Copia carpetas del caso dentro de las carpetasgeneradas
	cp -r "Case_0/0/" "$nombre_carpeta/"
	cp -r "Case_0/0.orig/" "$nombre_carpeta/"
	cp -r "Case_0/constant/" "$nombre_carpeta/"
	cp -r "Case_0/system/" "$nombre_carpeta/"

	# Copia un archivo dentro de la carpeta
	archivo_geo="Case_0/geometry.geo"
	archivo_geoi="geometry_Case_$i.geo"
	touch "$archivo_geo"
	cp "$archivo_geo" "$nombre_carpeta/$archivo_geoi"

	# Realiza el intercambio en el archivo
	valor_porosidad="${valores_porosidad[i - 1]}"
	sed -i "s/\$p/$valor_porosidad/g" "$nombre_carpeta/system/setFieldsDict"

	#Generar mallado gmsh
	cd "$nombre_carpeta/"
	gmsh "$archivo_geoi" -3

	#Genera mallado OpenFoam
	gmshToFoam "geometry_Case_$i.msh"

	#Lineas a eliminar en polymesh/bondary
	lineas_eliminar=("24" "30" "36" "42" "48" "54")

	#Itera sobre las líneas a eliminar y utiliza sed para quitarlas
	for numero_linea in "${lineas_eliminar[@]}"; do
		sed -i "${numero_linea}d" "constant/polyMesh/boundary"
	done

	# Reemplaza "patch" por "wall" en las líneas 23, 29, 35 y 41
	sed -i '23s/patch/wall/; 29s/patch/wall/; 35s/patch/wall/; 41s/patch/wall/' "constant/polyMesh/boundary"

	setFields
	decomposePar
	mpirun -np 6 interIsoFoam -parallel
	cd ..
done

echo "Proceso completado."
