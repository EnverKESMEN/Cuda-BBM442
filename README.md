This repository can be a good start for GPU programming.  
(If you don't have a GPU you can use TESLA P100 or K80 on Google cloud)

decode.cu is parallel programs written in C (cuda) for decode the encode.txt. decode.cu processes	the decoding stage both in serial	on	CPU	and	parallel on CUDA. 

Each	line	the	next	character	after	commas	are	the	secret	message	characters(Decoding Rule).

For	parallel	version	the	file	resides	in	the	CPU	side and	CPU	is	responsible	for	reading	the	file	and	sending the	lines	and	inputs	to	GPU.	
After	all	process	done,	the	final	formed	hidden	message	should	be	available	in	CPU	
side	and	write	to	the	output	file	named	decoded.txt	as	a	one	line	of	massage.  

	
For	simplicity,	in	the	input	file,	each	line	will	be	100	characters	long,	there	will	be	
exactly	4	commas	per	line,	commas	will	not	be	the	last	character	and	there	will	be	
15360 lines	in	the	encodedfile.txt.

# Algorithm
I created one thread for each row. Each line has 101 characters and 4 commas, so
each thread can easily calculate it's starting point. After calculating the starting points, each
thread checks the line and find the characters which is after comma. This part of the
program is parallel. The average speedup is around 4,7. 15360 lines mean 15360 thread and this number is too low for Tesla P100. This is really bad speedup for GPU especially for TESLA P100.

# Compile 

Open your terminal and write 
```
$ make
```
That's It.

# Usage
```
./decode
```
