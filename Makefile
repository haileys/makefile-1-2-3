all: A1 B1 C1 A2 B2 C2

A1: Makefile
	echo 4 > A1
B1: Makefile
	echo 2 > B1
C1: Makefile  A1 B1 
	echo '$(shell cat A1)+$(shell cat B1)' | bc > C1
A2: Makefile  C1 B1 
	echo '$(shell cat C1)*$(shell cat B1)' | bc > A2
B2: Makefile  A1 A2 
	echo '$(shell cat A1)*$(shell cat A2)' | bc > B2
C2: Makefile  A1 A2 B1 B2 C1 
	echo '$(shell cat A1)*$(shell cat A2)*$(shell cat B1)*$(shell cat B2)*$(shell cat C1)' | bc > C2
clean:
	rm -f  A1 B1 C1 A2 B2 C2
Makefile: compiler.sh spreadsheet.csv
	./compiler.sh spreadsheet.csv
