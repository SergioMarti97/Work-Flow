# Este script fusiona libros de excel
#
# Al script se le debe de pasar, como argumentos:
# 1 - El nombre del archivo final de salida
# 2 - El nombre de la columna común, necesaria para realizar la fusión (merge)
# 3 - Un archivo txt donde se indique las columnas de los libros que se quieran fusionar, estructurado
#     de la siguiente forma:
#
# ejemplo.txt:
#
# Libro1, hoja1: 2, 3, 4
# Libro2, hoja3: 3, 4, 5
# Libro3, hoja1: 3, 4, 5
# Libro3, hoja2: 3, 4, 5
# Libro4, hoja1: 3, 4, 5
#
# Los libros deben de econtrarse en el mismo directorio donde se ejecuta el script

# --- REQUISITOS --- #
# DLLs:
# - pandas (hay veces que viene por defecto)
# - xlrd
# - openpyxl
# - tabulate
#
# Para instalar una dependencia, desde una consola de cmd, ejecutar el comando:
# > python -m pip install "dependencia"

# --- LIBRERÍAS --- #
import sys
import pandas as pd
from tabulate import tabulate


# --- FUNCIONES --- #
def print_df_info(title, dataframe):
    """
    Esta función sirve para mostrar la información de un dataframe

    Es necesario que este instalada la libreria "tabulate"

    :param title: el nombre del dataframe (o el exel del que proviene)
    :param dataframe: el propio dataframe
    """
    # Mostrar el título
    print(f"# --- {title} --- #")

    # Mostrar las dimensiones del dataframe
    print(f"Shape: {dataframe.shape}")

    # Mostrar el forma de tabla las primeras líneas del dataframe
    print(tabulate(dataframe.head()))

    # Mostrar las columnas del dataframe
    print("Columns: ")
    for column in dataframe.columns.to_list():
        print(f"- {column}")


# --- PROGRAMA --- #

# (0) Nos aseguramos que han pasado el número de argumentos necesarios
if len(sys.argv) == 4:
    # El nombre del archivo con las columnas fusionadas
    out_file = sys.argv[1]
    # La columna necesaria para realizar el merge
    col_on_merge = sys.argv[2]
    # El archivo de texto con la información
    text_file = sys.argv[3]

    # NOTA: Es necesario una columna con las mismas filas, o en su defecto, el mismo número de filas,
    # para poder fusionar varias columnas de un excel

    # Nos aseguramos que el nombre del archivo de salida contiene la terminación ".xlsx"
    if ".xlsx" not in out_file:
        out_file += ".xlsx"

    # (1) Leemos el archivo y guardamos la información
    info_list = list()
    with open(text_file, "r") as f:
        for line in f:
            # ejemplo: Libro1, hoja1: 2, 3, 4
            split_line1 = line.split(": ")
            split_line2 = split_line1[0].split(", ")

            # Nombre del libro y de la hoja
            book_name = split_line2[0]
            sheet_name = split_line2[1]

            # Columnas
            wanted_cols = list()
            for col_idx in split_line1[1].split(", "):
                wanted_cols.append(int(col_idx))

            t = (book_name, sheet_name, wanted_cols)

            info_list.append(t)

    f.close()

    # (2) Con la información extraida, fusionamos los excels indicados
    big_df = pd.DataFrame()
    df = pd.DataFrame()
    for count in range(len(info_list)):
        book_name = info_list[count][0]
        sheet_name = info_list[count][1]
        wanted_cols = info_list[count][2]

        # Cargamos la hoja de excel
        df = pd.read_excel(book_name, sheet_name=sheet_name)

        # Seleccionamos las columnas que queremos
        df = df.iloc[:, wanted_cols]

        # Fusionamos los dataframes
        if count == 0:
            # Si es el primer dataframe no hay nada que fusionar
            big_df = df
        else:
            # Fusionamos cuando hay más de 1 dataframe
            # @see https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.merge.html
            big_df = pd.merge(big_df, df, how="outer", on=col_on_merge)

        # Mostramos datos del dataframe
        print_df_info(book_name, df)
        print("")

    # (3) Guardamos el dataframe con las columnas fusionadas
    big_df.to_excel(out_file, index=False)

    print(f"save to file: {out_file}")

else:
    print("No se ha indicado el archivo de texto con la información de los libros de excel a fusionar")
