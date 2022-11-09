# Este script renombra las columnas de un libro de excel
#
# Al script se le debe de pasar, como argumentos:
# 1 - Nombre del libro que se quiere modificar
# 2 - El nombre del libro resultante, con las columnas modificadas
# 3 - Un archivo txt donde se indique el texto de las columnas que se quiere renombrar. El archivo txt debe de
#     estar estructurado de la siguiente forma:
#
# ejemplo.txt:
#
# 04SE430: COL-1
# 04SE431: COL-2
# 04SE432: COL-3
# 04SE433: COL-4
# 04SE434: MAM-1
# 04SE435: MAM-2
# 04SE436: MAM-3
# 04SE437: MAM-4
# 04SE438: LEU-6
# 04SE439: LEU-7
# 04SE440: LEU-8
#
# El libro cuyas columnas se quieren renombrar, debe de encontrarse en el mismo directorio donde se ejecuta el script
#

# --- REQUISITOS --- #
# DLLs:
# - pandas (hay veces que viene por defecto)
# - xlrd
# - openpyxl
# - xlsxwriter
#
# Para instalar una dependencia, desde una consola de cmd, ejecutar el comando:
# > python -m pip install "dependencia"

# --- LIBRERÍAS --- #
import sys
import pandas as pd


# --- FUNCIONES --- #
def rename_df_columns(df, dict_old_new):
    """
    Esta función renombra las columnas de un dataframe,
    reemplazando texto "viejo" por texto "nuevo"
    :param df: el dataframe que se va a modificar
    :param dict_old_new: diccionario que contiene texto "viejo" (keys) y texto "nuevo" (values)
    """
    # Creamos un diccionario que contendrá los nuevos nombres de las columnas
    dict_new_column_names = dict()

    # Para columna del dataframe...
    for col in df.columns.to_list():
        # Guardamos el nombre antiguo
        old_name = col

        # Iteramos para cada entrada del diccionario
        for old_text, new_text in dict_old_new.items():
            # Si la el nombre de la columna contiene el texto a reemplazar...
            if old_text in col:
                # Remplazamos el texto viejo por el nuevo
                col = col.replace(old_text, new_text)

                # TODO: mostrar el texto que se esta reemplazando
                print(f"{old_name} -> {col}")

        # Guardamos la entrada en el diccionario
        dict_new_column_names[old_name] = col

    # Renombramos
    df.rename(columns=dict_new_column_names, inplace=True)


# --- PROGRAMA --- #

# (0) Nos aseguramos que han pasado los argumentos necesarios
if len(sys.argv) == 4:
    in_book = sys.argv[1]
    out_book = sys.argv[2]
    text_file = sys.argv[3]

    # (1) Leemos el archivo y guardamos la información
    hash_codes = dict()
    with open(text_file, "r") as f:
        for line in f:
            split_line = line.split(": ")
            if len(split_line) >= 2:
                hash_codes[split_line[0]] = split_line[1].strip('\n')
            elif len(split_line) == 1:
                hash_codes[split_line[0].strip('\n').strip(':')] = ""

    f.close()

    # (2) Cargamos en memoria las hojas de un libro de excel como dataframes
    dict_df = pd.read_excel(in_book, sheet_name=None)
    for sheet_name, df in dict_df.items():
        # (3) Con el diccionario "viejo" : "nuevo", pasamos a remplazar el texto viejo por el texto nuevo
        rename_df_columns(df, hash_codes)

    # (4) Guardamos los dataframes con las columnas renombradas
    with pd.ExcelWriter(out_book, engine="xlsxwriter") as writer:
        for sheet_name, df in dict_df.items():
            df.to_excel(writer, sheet_name=sheet_name, index=False)

    print(f"save to file: {out_book}")

