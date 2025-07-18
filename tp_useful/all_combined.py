with open("filelist.txt") as file:
    with open("alu_core.v", "w") as fwrite:
        for each in file:
            each = each.strip() 
            with open(each) as rf:
                fwrite.write(f"{rf.read()}\n") 