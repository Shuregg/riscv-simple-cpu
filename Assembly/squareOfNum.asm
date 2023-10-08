li a0, 7	#addi a0, zero, 5 #load a constant value

#save const to stack
addi sp, sp, -8	#increase stack size
sw ra, 0(sp)	#save returnadress to stack
sw a0, 4(sp)	#save our constant value to stack

jal ra, square 	#square procedure call

lw a1, 4(sp)	#restore the const value from stack
lw ra, 0(sp)	#restore the returnadress from stack

addi sp, sp, 8 	#decrease stack size

square:
	#prologue
	addi sp, sp, -8
    sw s0, 8(sp)
    sw s1, 12(sp)
    
    add s0, zero, zero	#s0 = s0 - s0 = 0	
    addi s0, zero, 1	#s0 = 0 + 1			#s0 - is a loop counter in range [1:a0]
    
    sub s1, s1, s1	#s1 = s1 - s1 = 0
	j compare	#compoare with number		#s1 - is a temporary result (accumulator)
    
    loop:
    addi s0, s0, 1	#s0 += 1
    add s1, s1, a0	#s1 = s1 + a0	#calculating temp. result
    j compare

    compare:
    	ble s0, a0, loop	#if(s0 == a0) go to loop
        j end

    end:
        add a0, s1, zero
    #epilogue
	lw s0, 8(sp)
    lw s1, 12(sp)
    addi sp, sp, 8
    ret
