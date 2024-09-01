import shutil
import os

def move_files(src, dst):
    # Проверяем существование исходной папки
    if not os.path.exists(src):
        print(f"Исходная папка '{src}' не существует.")
        return
    
    # Проверяем существование папки назначения
    if not os.path.exists(dst):
        print(f"Папка назначения '{dst}' не существует.")
        return
    
    for filename in os.listdir(src):
        shutil.move(os.path.join(src, filename), dst)

source_folder = 'Top secret'
destination_folder = 'My-server'

move_files(source_folder, destination_folder)
