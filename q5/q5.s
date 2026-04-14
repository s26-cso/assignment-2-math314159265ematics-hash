.data
    filename: .string "input.txt"
    output_yes: .string "Yes\n"
    output_no: .string "No\n"
    buffer: .space 1

.text
    .global main
    
    main:

    addi sp, sp, -48
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)
    sd s3, 32(sp)

    li a0,-100      #this is the first arguement and is set to -100 so that it reads the file in the same/current working directory
    la a1,filename  #here we load the address of the string into a1
    li a2,0         #here we are passing the arguement as 0 which is just the mode (Here it is read only mode,as we want to read the file and need not alter it)
    li a7,56        #this is the syscall code to the commmand 'openat'(which opens a file and gives us access to that file by returning a file descriptor)(similar to a pointer to a file,like the same concept we learnt in CPro the last sem in file handling)
    ecall
    mv s0,a0        #Here a0 is the file descriptor returned by ecall ,which we are storing it in s0
    
    li a1,0         #We are setting the offset to zero(The lseek command puts the cursor at the position of offset + wherever your a2 tells it to put it,so now since the offset is zero it wil put the cursor at the end of the fiel
    li a2,2         #Here a2 arguement is 2 that means it wants to go the end of the file 
    li a7,62
    ecall
    mv s1,a0        #This is the total length in s1(let us assume this length is n)


    beq s1,x0,print_yes


    li s2,0         # Front pointer = 0
    addi s3,s1,-1   # Back pointer = n-1

    loop:
    bge s2,s3,print_yes

    #In the bnelow code we are just moving the cursor to the required byte to read it,to read the front byte
    mv a0, s0      
    mv a1, s2             # offset = front pointer
    li a2, 0              # SEEK_SET(this points the cursor at the starting of the file)
    li a7, 62             # Syscall: lseek
    ecall


    mv a0,s0
    la a1,buffer         #This is loading the address  of the buffer in a1
    li a2,1              #number of bytes to read
    li a7,63             # Syscall code is for  read
    ecall

    la t0,buffer
    lb t1,0(t0)

    mv a0,s0             
    mv a1,s3             # offset = back pointer
    li a2,0              # This is the starting of the file(Seekset)
    li a7,62             # Syscall here is lseek(this basically moves the cursor there and returns the number of bytes it moves accross)
    ecall

    mv a0,s0
    la a1,buffer         # Point to buffer
    li a2,1              # Read 1 byte
    li a7,63             # Syscall: read
    ecall

    la t0,buffer
    lb t2,0(t0)          # t2 = back byte

    bne t1,t2,print_no

    addi s2,s2, 1        # front++
    addi s3,s3, -1       # back-- (these are the pointers)
    j loop 

    print_yes:
    la a0,output_yes      # Argument 0 is the  Pointer to the "Yes\n" string here
    call printf           
    j closefile

    print_no:
    la a0,output_no       # Argument 0 is the  Pointer to the "No\n" string here
    call printf           # Call printf function from the library
    j closefile

    closefile:
    mv a0, s0
    li a7, 57              #This syscall for closing the file
    ecall                   
    
    exit:
    ld ra, 0(sp)
    ld s0, 8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    addi sp, sp, 48
    li a0, 0
    ret