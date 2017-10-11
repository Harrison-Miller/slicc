slicc: slicc.y slicc.l main.c
	bison -y -d slicc.y
	flex slicc.l
	gcc -o slicc lex.yy.c y.tab.c main.c -lfl

clean:
	rm -f slicc lex.yy.c y.tab.c y.tab.h
