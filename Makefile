slicc: slicc.y slicc.l *.c
	bison -y -d slicc.y
	flex slicc.l
	gcc -o slicc *.c -lfl

clean:
	rm -f slicc lex.yy.c y.tab.c y.tab.h
