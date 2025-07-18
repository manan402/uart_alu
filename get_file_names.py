import os

with open("filelist.txt", "w") as f:
    for file in os.listdir("."):
        if file.endswith(".v"):
            f.write(f"{file}\n")
    