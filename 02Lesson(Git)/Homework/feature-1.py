import shutil
import os

def move_files(src, dst):
    for filename in os.listdir(src):
        shutil.move(os.path.join(src, filename), dst)

source_folder = 'Top secret'
destination_folder = 'Internet'

move_files(source_folder, destination_folder)
