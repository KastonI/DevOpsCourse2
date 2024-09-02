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
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
destination_folder = 'My-server'
=======
destination_folder = 'Internet'
>>>>>>> 6c34774 (create:feature-1)
=======
destination_folder = 'My-server'
>>>>>>> e8f5322 (create:feature-2)
=======
destination_folder = 'My-server'
>>>>>>> 7b7023c463265c6df919c4dabe5beb91feb8b922

move_files(source_folder, destination_folder)
