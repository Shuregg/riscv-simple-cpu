li t2, 31 	#counter
li a0, 0xBEA9	# num 1011 1110 1010 1001 = BEA9
li a1, 0		# res 1001 0101 0111 1101 = 957D
word_reverse:
	andi t1, a0, 1
  or a1, a1, t1
	slli a1, a1, 1
	srli a0, a0, 1
  addi t2, t2, -1
  bne t2, zero, word_reverse
