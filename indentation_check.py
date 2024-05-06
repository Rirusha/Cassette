#!/bin/bash

import sys
import os
import re

def check_indentation(file_path, root_dir) -> list[str]:
    file_err_list = []
    
    with open(file_path, 'r') as file:
        lines = file.readlines()

    for i, line in enumerate(lines):
        if "ind-check=skip-file" in line:
            return
        
        if re.match(r'^(?!.*(?:new|if|else| => |try|catch|switch|}|get |set |while|namespace|class|foreach|throws|ind-check=ignore| = {))(?=(?:.*?\s+\w+\s+\w+.*?){1}).*{', line):
            indentation = len(re.match(r'^(\s*)', line).group(1))
            if indentation != 4:
                file_err_list.append (f"Indentation error in file '{file_path.replace (root_dir, "")}' at line {i+1}: \"{line.rstrip ()}\". {indentation} spaces instead of 4.")

    return file_err_list

def scan_directory (directory) -> list[str]:
    err_list = []
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.vala'):
                file_path = os.path.join(root, file)

                file_err_list = check_indentation (file_path, directory)

                if (file_err_list):
                    err_list += file_err_list

    return err_list


if __name__ == "__main__":
    err_list = scan_directory (sys.argv[1])
    
    print (*err_list, sep="\n", end="\n\n")
    print (f"Total errors: {len (err_list)}")

    if (len (err_list) != 0):
        sys.exit (1)
