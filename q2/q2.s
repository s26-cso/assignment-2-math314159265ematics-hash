.data
    format_str: .string "%d "
    newline: .string "\n"
.text
.global main
main:
    addi sp,sp,-56
    sd a0,0(sp)
    sd s1,8(sp)
    sd s2,16(sp)
    sd a1,24(sp)
    sd x1,32(sp)
    sd s0,40(sp)
    sd s3,48(sp)
    mv s0,a0        #storing the total number of arguements
    addi s0,s0,-1   #total number of elements in the array are as follows
    li t1,4 
    mul t1,s0,t1    #total number of bytes that need to be allocated
    mv a0,t1        #just copying t1 to a0,which is the input parameter for malloc and we do not restore any registers after malloc as they are not temporary registers
    call malloc
    mv s1,a0        #now this s1 holds the array starting address(array of elements)

    li t1,4 
    mul t1,s0,t1
    mv a0,t1
    call malloc
    mv s2,a0        #this s2 holds the NGE array starting address
    ld a0,0(sp)     #restore the value of num of arguements

    addi t3,x0,0    #counter of the loop
    addi t4,s1,0    #temporary pointer to access the array
    addi t0,s2,0    #temporary pointer to access the nge array
    ld t5,24(sp)    #this register is used to store the arguement a1 which is nothing but the pointer to the pointer of input arguement strings 
    addi t5,t5,8    #skip the first word of the string that is skip the pointer to the first string

loop:

    bge t3,s0,start_nge
    li t1,-1        #initialise the nge array with -1,so we keep a register with value -1 ready 
    sw t1,0(t0)     #put -1 in nge array using temporary pointer
    addi t0,t0,4    #next element of the array in nge using temporary pointer

    ld t2,0(t5)     #This takes the string number arguement
    li t6,0         #This is the integer value of the string initialised to zero
    li a5,0         #This is the flag to check if the number is negative we have initialised it to zero(meaning positive)
    mv a2,t2        #t2 is havig the string number,we move that to a2(Note that all a1,a2,a3, here are not used and are also similar to temporary register i.e can be used without needing to save it



    lb a3, 0(a2)
    li a4, 45               # ASCII value for '-'(minus sign)
    bne a3, a4, convert     # If not minus, jump to normal conversion
    li a5, 1                # Set negative flag
    addi a2, a2, 1          # Move pointer past the '-' character


    convert:
        lb a3,0(a2)
        beq a3,x0,done

        addi a3,a3,-48

        li a4,10
        mul t6,t6,a4
        add t6,t6,a3

        addi a2,a2,1
        j convert

    done:
        beq a5,x0,store_val
        neg t6,t6
    store_val:
        sw t6,0(t4)

        addi t4,t4,4
        addi t3,t3,1
        addi t5,t5,8
        j loop          #loop starts again until we hit the branch condition(after the counter is n+1)

start_nge:

    li t1, 4                #Here we are allocating space for a stack array for n integers
    mul t1, s0, t1
    mv a0, t1                   
    call malloc             #all temporary registers might be lost here
    mv s3, a0               #s3 holds stack array starting address

    addi t0, s0, -1         # t0 = i (start at n-1)
    li t1, 0                # t1 = stack_size (start at 0)

nge_outer_loop:
    blt t0, x0, print_results        # if i < 0, we are done

    # Load arr[i]
    li t5,4                 
    mul t5,t5,t0
    add t6, s1, t5          #here t6 is having int* arr[i]
    lw t2, 0(t6)            # t2 = arr[i]

    nge_inner_loop:
        beq t1, x0, stack_empty

        
        addi t5, t1, -1 
        slli t5, t5, 2  
        add t6, s3, t5          #we can get top element of the stack
        lw t3, 0(t6)            # t3 = INDEX

        slli t5, t3, 2          #arr[INDEX] for comparison
        add t6, s1, t5
        lw t4, 0(t6)            # t4 = VALUE at arr[stack.top()]

        blt t2, t4, found_nge   # Compare arr[i] with arr[stack.top()]

        
        addi t1, t1, -1         #This is just pop
        j nge_inner_loop        

    stack_empty:
        li t4, -1               # NGE is -1
        j store_nge

    found_nge:
        mv t4, t3               # NGE is stack.top()

    store_nge:
        slli t5, t0, 2          
        add t6, s2, t5          
        sw t4, 0(t6)            # Store the NGE index in result array

        slli t5, t1, 2          
        add t6, s3, t5          
        sw t0, 0(t6)            # push index 't0'
        
        addi t1, t1, 1          # stack_size++
        addi t0, t0, -1         # i--
        j nge_outer_loop

print_results:
    li t0, 0                # counter = 0
    mv s4, s2               # pointer to nge array

print_loop:
    bge t0, s0, exit        # if counter >= N, exit

    la a0, format_str       # "%d "
    lw a1, 0(s4)            # Load nge[i]
    
    addi sp, sp, -8
    sd t0, 0(sp)
    call printf
    ld t0, 0(sp)
    addi sp, sp, 8
    
    addi s4, s4, 4          # Next element
    addi t0, t0, 1          # counter++
    j print_loop
    
exit:
    ld a0,0(sp)
    ld s1,8(sp)
    ld s2,16(sp)
    ld a1,24(sp)
    ld x1,32(sp)
    ld s0,40(sp)
    ld s3,48(sp)
    addi sp,sp,56
    
    li a0, 0
    ret
    
