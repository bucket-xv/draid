all: main read

clean:
	rm -f main read

main: main.c
	gcc  main.c -o main -lrados

read: read.cpp
	g++ -std=c++11 read.cpp -o read -lrados