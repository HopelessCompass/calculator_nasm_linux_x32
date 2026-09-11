# Learning Assembly a hard way.
# It was my first project using this lang so it sucks.
# Best way to learn programming language is starting coding with this lang
# P.S. Sorry 4 my bad english



# calculator_nasm_linux
Calculator on Assembly language, NASM dialect

#Download NASM

sudo apt -y install nasm


#Check NASM version

nasm -v


#Assembling 

nasm -f elf64 calculator_nasm_linux.asm -o output.o


#Create executive file

ld -o run_program output.o


#Run file

./run_program
