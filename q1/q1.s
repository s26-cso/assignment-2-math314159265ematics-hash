.text
.global make_node
.global insert
.global get
.global getAtMost

make_node:
    addi sp,sp,-16      #ALLOCATE SPACE FOR RETURN AND THE ARGUEMENT REGISTER
    sw a0,0(sp)         #THIS IS TO STORE THE INPUT VALUE
    sd x1,8(sp)         #THIS STORES THE RETURN ADDRESS

    li a0,24            #This is for storing int(4 bytes+padding of 4 bytes) and a left and right pointer to integers(8bytes each)
    call malloc         #now a0 holds the pointer to the struct

    lw t0,0(sp)         #This is just loading value into the temp reg
    sw t0,0(a0)         
    sd x0,8(a0)         #This is just initializing the left pointer to null
    sd x0,16(a0)        #This is just initializing the left pointer to null

    ld x1,8(sp)
    addi sp,sp,16
    ret


insert:
    addi sp,sp,-32  
    sd x1,0(sp)                 #save address
    sd a0,8(sp)                 #save root
    sd a1,16(sp)                #save val

    beq a0,x0,return_new_node
    lw t0,0(a0)                 #root->value
    blt t0,a1,go_right

go_left:
    ld t1,8(a0)                 #root->left
    mv a0,t1
    call insert                 #returns the root of the tree with the inserted node(assuming that a0 is the new root)
    #ld x1,0(sp)
    #ld a1,16(sp)
    ld t2,8(sp)                 #this is the original root
    sd a0,8(t2)
    mv a0,t2
    j done_with_inserting

go_right:
    ld t1,16(a0)
    mv a0,t1
    call insert
    ld t2,8(sp)
    sd a0,16(t2)
    mv a0,t2
    j done_with_inserting

return_new_node:
    ld a0,16(sp)
    call make_node
    ld x1,0(sp)
    addi sp,sp,32
    ret

done_with_inserting:
    ld x1,0(sp)
    addi sp,sp,32
    ret

get:
    addi sp,sp,-24
    sd x1,0(sp)                 #save address
    sd a0,8(sp)                 #save root
    sd a1,16(sp)                #save value
    beq a0,x0,return_null
    lw t0,0(a0)

    blt t0,a1,search_right
    blt a1,t0,search_left
    ld x1,0(sp)
    addi sp,sp,24
    ret

search_right:
    ld a0,16(a0)
    call get
    ld x1,0(sp)
    addi sp,sp,24
    ret

search_left:
    ld a0,8(a0)
    call get
    ld x1,0(sp)
    addi sp,sp,24
    ret

return_null:
    li a0,0
    ld x1,0(sp)
    addi sp,sp,24
    ret


getAtMost:
    li t0, -1          # ans = -1

    loop:
    beq a1, x0, done   # if root == NULL

    lw t1, 0(a1)       # root->val
    ble t1, a0, update

    # go left
    ld a1, 8(a1)
    j loop

update:
    mv t0, t1
    ld a1, 16(a1)
    j loop

done:
    mv a0, t0
    ret