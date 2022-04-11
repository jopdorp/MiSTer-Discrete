#!/bin/bash

##################################################################################\
#
#  MiSTer Discrete test bench runner
#
#  Copyright 2022 by Jegor van Opdorp. 
#  This program is free software under the terms of the GPLv3, see LICENCSE.txt
#
##################################################################################/

# check whether user had supplied -h or --help . If yes display usage
MODULE=$1

if [[ ( $@ == "--help") ||  $@ == "-h" || -z "$MODULE" ]]
then 
	echo "Usage: $0 <module>"
    echo "The module has to have the same name as the file"
    echo "The testbench name relates to the module like:"
    echo "module.sv module_tb.sv"
	exit 0
fi 
 

iverilog -grelative-include -y ./ ${MODULE}.sv -g2012 -o ${MODULE}_tb.sv.vvp ${MODULE}_tb.sv
vvp ${MODULE}_tb.sv.vvp
