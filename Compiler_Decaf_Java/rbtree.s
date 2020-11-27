    # start of header
    .text
    .globl main
    # end of header

    .data
    .align 2
_V_Main:  # virtual table for Main
    .word 0    # parent: none
    .word _S0    # class name

    .data
    .align 2
_V_Node:  # virtual table for Node
    .word 0    # parent: none
    .word _S1    # class name

    .data
    .align 2
_V_RBTree:  # virtual table for RBTree
    .word _V_Node    # parent: Node
    .word _S2    # class name
    .word _L_RBTree_delete    # member method
    .word _L_RBTree_delete_fix    # member method
    .word _L_RBTree_insert    # member method
    .word _L_RBTree_insert_fix    # member method
    .word _L_RBTree_print    # member method
    .word _L_RBTree_print_impl    # member method
    .word _L_RBTree_rotate    # member method
    .word _L_RBTree_transplant    # member method

    .data
    .align 2
_V_Rng:  # virtual table for Rng
    .word 0    # parent: none
    .word _S3    # class name
    .word _L_Rng_next    # member method

    .text
_L_Node_new:  # function FUNCTION<Node.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 24
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_Node
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_Node_new_exit
    # end of body

_L_Node_new_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_new:  # function FUNCTION<RBTree.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 32
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_RBTree
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_RBTree_new_exit
    # end of body

_L_RBTree_new_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Rng_new:  # function FUNCTION<Rng.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 8
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_Rng
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_Rng_new_exit
    # end of body

_L_Rng_new_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Main_new:  # function FUNCTION<Main.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 4
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_Main
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_Main_new_exit
    # end of body

_L_Main_new_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

main:  # function main
    # start of prologue
    addiu   $sp, $sp, -88  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 19260817
    move    $a0, $v1
    jal     _L_Rng_make
    move    $v1, $v0
    move    $t3, $v1
    sw      $t3, 48($sp)
    jal     _L_RBTree_make1
    lw      $t3, 48($sp)
    move    $v1, $v0
    move    $t2, $v1
    li      $v1, 0
    move    $t4, $v1
_L2:
    li      $v1, 5
    slt     $v1, $t4, $v1
    beqz    $v1, _L1
    li      $v1, 0
    move    $t1, $v1
_L4:
    li      $v1, 500
    slt     $v1, $t1, $v1
    beqz    $v1, _L3
    lw      $v1, 0($t3)
    lw      $v1, 8($v1)
    move    $a0, $t3
    sw      $v1, 52($sp)
    sw      $t1, 56($sp)
    sw      $t2, 60($sp)
    sw      $t3, 48($sp)
    sw      $t4, 64($sp)
    jalr    $v1
    lw      $v1, 52($sp)
    lw      $t1, 56($sp)
    lw      $t2, 60($sp)
    lw      $t3, 48($sp)
    lw      $t4, 64($sp)
    move    $t0, $v0
    li      $v1, 500
    rem     $t0, $t0, $v1
    lw      $v1, 0($t2)
    lw      $v1, 16($v1)
    move    $a0, $t2
    move    $a1, $t0
    sw      $v1, 68($sp)
    sw      $t1, 56($sp)
    sw      $t2, 60($sp)
    sw      $t3, 48($sp)
    sw      $t4, 64($sp)
    jalr    $v1
    lw      $v1, 68($sp)
    lw      $t1, 56($sp)
    lw      $t2, 60($sp)
    lw      $t3, 48($sp)
    lw      $t4, 64($sp)
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L4
_L3:
    li      $v1, 0
    move    $t1, $v1
_L6:
    li      $v1, 500
    slt     $v1, $t1, $v1
    beqz    $v1, _L5
    lw      $v1, 0($t3)
    lw      $v1, 8($v1)
    move    $a0, $t3
    sw      $v1, 72($sp)
    sw      $t1, 76($sp)
    sw      $t2, 60($sp)
    sw      $t3, 48($sp)
    sw      $t4, 64($sp)
    jalr    $v1
    lw      $v1, 72($sp)
    lw      $t1, 76($sp)
    lw      $t2, 60($sp)
    lw      $t3, 48($sp)
    lw      $t4, 64($sp)
    move    $t0, $v0
    li      $v1, 500
    rem     $t0, $t0, $v1
    lw      $v1, 0($t2)
    lw      $v1, 8($v1)
    move    $a0, $t2
    move    $a1, $t0
    sw      $v1, 80($sp)
    sw      $t1, 76($sp)
    sw      $t2, 60($sp)
    sw      $t3, 48($sp)
    sw      $t4, 64($sp)
    jalr    $v1
    lw      $v1, 80($sp)
    lw      $t1, 76($sp)
    lw      $t2, 60($sp)
    lw      $t3, 48($sp)
    lw      $t4, 64($sp)
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L6
_L5:
    li      $v1, 1
    add     $v1, $t4, $v1
    move    $t4, $v1
    j       _L2
_L1:
    lw      $v1, 0($t2)
    lw      $v1, 24($v1)
    move    $a0, $t2
    sw      $v1, 84($sp)
    jalr    $v1
    lw      $v1, 84($sp)
    j       main_exit
    # end of body

main_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 88  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Rng_make:  # function FUNCTION<Rng.make>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    sw      $ra, 40($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $t0, 0($sp)
    sw      $t0, 0($sp)
    jal     _L_Rng_new
    lw      $t0, 0($sp)
    move    $v1, $v0
    move    $v1, $v1
    sw      $t0, 4($v1)
    move    $v0, $v1
    j       _L_Rng_make_exit
    # end of body

_L_Rng_make_exit:
    # start of epilogue
    lw      $ra, 40($sp)  # restore the return address
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Rng_next:  # function FUNCTION<Rng.next>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $t2, 0($sp)
    li      $t1, 15625
    lw      $t0, 4($t2)
    li      $v1, 10000
    rem     $v1, $t0, $v1
    mul     $t0, $t1, $v1
    li      $v1, 22221
    add     $t0, $t0, $v1
    li      $v1, 65536
    rem     $v1, $t0, $v1
    sw      $v1, 4($t2)
    lw      $v1, 4($t2)
    move    $v0, $v1
    j       _L_Rng_next_exit
    # end of body

_L_Rng_next_exit:
    # start of epilogue
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Node_make:  # function FUNCTION<Node.make>
    # start of prologue
    addiu   $sp, $sp, -52  # push stack frame
    sw      $ra, 48($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    sw      $a2, 8($sp)  # save arg 2
    lw      $t3, 0($sp)
    lw      $t2, 4($sp)
    lw      $t1, 8($sp)
    sw      $t1, 8($sp)
    sw      $t2, 4($sp)
    sw      $t3, 0($sp)
    jal     _L_Node_new
    lw      $t1, 8($sp)
    lw      $t2, 4($sp)
    lw      $t3, 0($sp)
    move    $v1, $v0
    move    $t0, $v1
    sw      $t1, 8($t0)
    sw      $t3, 16($t0)
    sw      $t2, 12($t0)
    sw      $t2, 20($t0)
    li      $v1, 1
    sw      $v1, 4($t0)
    move    $v0, $t0
    j       _L_Node_make_exit
    # end of body

_L_Node_make_exit:
    # start of epilogue
    lw      $ra, 48($sp)  # restore the return address
    addiu   $sp, $sp, 52  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_make1:  # function FUNCTION<RBTree.make1>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    jal     _L_RBTree_new
    move    $v1, $v0
    move    $t0, $v1
    sw      $t0, 40($sp)
    jal     _L_Node_new
    lw      $t0, 40($sp)
    move    $v1, $v0
    move    $v1, $v1
    sw      $v1, 16($v1)
    sw      $v1, 12($v1)
    sw      $v1, 20($v1)
    sw      $v1, 28($t0)
    sw      $v1, 24($t0)
    move    $v0, $t0
    j       _L_RBTree_make1_exit
    # end of body

_L_RBTree_make1_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_transplant:  # function FUNCTION<RBTree.transplant>
    # start of prologue
    addiu   $sp, $sp, -52  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    sw      $a2, 8($sp)  # save arg 2
    lw      $t3, 0($sp)
    lw      $t2, 4($sp)
    lw      $t1, 8($sp)
    lw      $v1, 16($t2)
    move    $t0, $v1
    lw      $v1, 24($t3)
    seq     $v1, $t0, $v1
    beqz    $v1, _L7
    sw      $t1, 28($t3)
    j       _L8
_L7:
    lw      $v1, 20($t0)
    seq     $v1, $v1, $t2
    beqz    $v1, _L9
    sw      $t1, 20($t0)
    j       _L10
_L9:
    sw      $t1, 12($t0)
_L10:
_L8:
    sw      $t0, 16($t1)
    j       _L_RBTree_transplant_exit
    # end of body

_L_RBTree_transplant_exit:
    # start of epilogue
    addiu   $sp, $sp, 52  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_rotate:  # function FUNCTION<RBTree.rotate>
    # start of prologue
    addiu   $sp, $sp, -48  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t3, 0($sp)
    lw      $t2, 4($sp)
    lw      $v1, 16($t2)
    move    $t1, $v1
    lw      $v1, 16($t1)
    move    $t0, $v1
    sw      $t0, 16($t2)
    lw      $v1, 24($t3)
    seq     $v1, $t0, $v1
    beqz    $v1, _L11
    sw      $t2, 28($t3)
    j       _L12
_L11:
    lw      $v1, 20($t0)
    seq     $v1, $v1, $t1
    beqz    $v1, _L13
    sw      $t2, 20($t0)
    j       _L14
_L13:
    sw      $t2, 12($t0)
_L14:
_L12:
    lw      $v1, 12($t1)
    seq     $v1, $v1, $t2
    beqz    $v1, _L15
    lw      $v1, 20($t2)
    sw      $v1, 12($t1)
    lw      $v1, 20($t2)
    sw      $t1, 16($v1)
    sw      $t1, 20($t2)
    j       _L16
_L15:
    lw      $v1, 12($t2)
    sw      $v1, 20($t1)
    lw      $v1, 12($t2)
    sw      $t1, 16($v1)
    sw      $t1, 12($t2)
_L16:
    sw      $t2, 16($t1)
    j       _L_RBTree_rotate_exit
    # end of body

_L_RBTree_rotate_exit:
    # start of epilogue
    addiu   $sp, $sp, 48  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_insert_fix:  # function FUNCTION<RBTree.insert_fix>
    # start of prologue
    addiu   $sp, $sp, -60  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t1, 0($sp)
    lw      $t3, 4($sp)
_L18:
    lw      $v1, 16($t3)
    lw      $v1, 4($v1)
    beqz    $v1, _L17
    lw      $v1, 16($t3)
    move    $t2, $v1
    lw      $v1, 16($t2)
    move    $t5, $v1
    lw      $v1, 12($t5)
    seq     $v1, $v1, $t2
    move    $t4, $v1
    beqz    $t4, _L19
    lw      $v1, 12($t5)
    move    $t0, $v1
    j       _L20
_L19:
    lw      $v1, 20($t5)
    move    $t0, $v1
_L20:
    lw      $v1, 4($t0)
    beqz    $v1, _L21
    li      $v1, 0
    sw      $v1, 4($t2)
    li      $v1, 0
    sw      $v1, 4($t0)
    li      $v1, 1
    sw      $v1, 4($t5)
    move    $t3, $t5
    j       _L22
_L21:
    lw      $v1, 12($t2)
    seq     $v1, $v1, $t3
    sne     $v1, $v1, $t4
    beqz    $v1, _L23
    lw      $v1, 0($t1)
    lw      $v1, 32($v1)
    move    $a0, $t1
    move    $a1, $t3
    sw      $v1, 48($sp)
    sw      $t1, 0($sp)
    sw      $t2, 52($sp)
    sw      $t3, 4($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t1, 0($sp)
    lw      $t2, 52($sp)
    lw      $t3, 4($sp)
    move    $v1, $t3
    move    $t3, $t2
    move    $t2, $v1
    lw      $v1, 16($t2)
    move    $t5, $v1
_L23:
    li      $v1, 0
    sw      $v1, 4($t2)
    li      $v1, 1
    sw      $v1, 4($t5)
    lw      $v1, 0($t1)
    lw      $v1, 32($v1)
    move    $a0, $t1
    move    $a1, $t2
    sw      $v1, 56($sp)
    sw      $t1, 0($sp)
    sw      $t3, 4($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    lw      $t1, 0($sp)
    lw      $t3, 4($sp)
_L22:
    j       _L18
_L17:
    lw      $t0, 28($t1)
    li      $v1, 0
    sw      $v1, 4($t0)
    j       _L_RBTree_insert_fix_exit
    # end of body

_L_RBTree_insert_fix_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 60  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_insert:  # function FUNCTION<RBTree.insert>
    # start of prologue
    addiu   $sp, $sp, -60  # push stack frame
    sw      $ra, 48($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t1, 0($sp)
    lw      $t3, 4($sp)
    lw      $v1, 28($t1)
    move    $t0, $v1
    lw      $v1, 24($t1)
    move    $t2, $v1
_L25:
    lw      $v1, 24($t1)
    sne     $v1, $t0, $v1
    beqz    $v1, _L24
    move    $t2, $t0
    lw      $v1, 8($t0)
    seq     $v1, $v1, $t3
    beqz    $v1, _L26
    j       _L_RBTree_insert_exit
    j       _L27
_L26:
    lw      $v1, 8($t0)
    slt     $v1, $v1, $t3
    beqz    $v1, _L28
    lw      $v1, 20($t0)
    move    $t0, $v1
    j       _L29
_L28:
    lw      $v1, 12($t0)
    move    $t0, $v1
_L29:
_L27:
    j       _L25
_L24:
    lw      $v1, 24($t1)
    move    $a0, $t2
    move    $a1, $v1
    move    $a2, $t3
    sw      $t1, 0($sp)
    sw      $t2, 52($sp)
    sw      $t3, 4($sp)
    jal     _L_Node_make
    lw      $t1, 0($sp)
    lw      $t2, 52($sp)
    lw      $t3, 4($sp)
    move    $v1, $v0
    move    $t0, $v1
    lw      $v1, 24($t1)
    seq     $v1, $t2, $v1
    beqz    $v1, _L30
    sw      $t0, 28($t1)
    j       _L31
_L30:
    lw      $v1, 8($t2)
    slt     $v1, $v1, $t3
    beqz    $v1, _L32
    sw      $t0, 20($t2)
    j       _L33
_L32:
    sw      $t0, 12($t2)
_L33:
_L31:
    lw      $v1, 0($t1)
    lw      $v1, 20($v1)
    move    $a0, $t1
    move    $a1, $t0
    sw      $v1, 56($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    j       _L_RBTree_insert_exit
    # end of body

_L_RBTree_insert_exit:
    # start of epilogue
    lw      $ra, 48($sp)  # restore the return address
    addiu   $sp, $sp, 60  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_delete_fix:  # function FUNCTION<RBTree.delete_fix>
    # start of prologue
    addiu   $sp, $sp, -68  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t1, 0($sp)
    lw      $t2, 4($sp)
_L35:
    lw      $v1, 28($t1)
    sne     $t0, $t2, $v1
    lw      $v1, 4($t2)
    not     $v1, $v1
    and     $v1, $t0, $v1
    beqz    $v1, _L34
    lw      $v1, 16($t2)
    move    $t3, $v1
    lw      $v1, 12($t3)
    seq     $v1, $v1, $t2
    move    $t5, $v1
    beqz    $t5, _L36
    lw      $v1, 20($t3)
    move    $t4, $v1
    j       _L37
_L36:
    lw      $v1, 12($t3)
    move    $t4, $v1
_L37:
    lw      $v1, 4($t4)
    beqz    $v1, _L38
    li      $v1, 0
    sw      $v1, 4($t4)
    li      $v1, 1
    sw      $v1, 4($t3)
    lw      $v1, 0($t1)
    lw      $v1, 32($v1)
    move    $a0, $t1
    move    $a1, $t4
    sw      $v1, 48($sp)
    sw      $t1, 0($sp)
    sw      $t3, 52($sp)
    sw      $t5, 56($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t1, 0($sp)
    lw      $t3, 52($sp)
    lw      $t5, 56($sp)
    beqz    $t5, _L39
    lw      $v1, 20($t3)
    move    $t4, $v1
    j       _L40
_L39:
    lw      $v1, 12($t3)
    move    $t4, $v1
_L40:
_L38:
    lw      $v1, 12($t4)
    lw      $v1, 4($v1)
    not     $t0, $v1
    lw      $v1, 20($t4)
    lw      $v1, 4($v1)
    not     $v1, $v1
    and     $v1, $t0, $v1
    beqz    $v1, _L41
    li      $v1, 0
    sw      $v1, 4($t4)
    move    $t2, $t3
    j       _L42
_L41:
    lw      $v1, 20($t4)
    move    $t2, $v1
    lw      $v1, 12($t4)
    move    $t0, $v1
    beqz    $t5, _L43
    move    $v1, $t2
    move    $t2, $t0
    move    $t0, $v1
_L43:
    lw      $v1, 4($t0)
    not     $v1, $v1
    beqz    $v1, _L44
    li      $v1, 0
    sw      $v1, 4($t2)
    li      $v1, 1
    sw      $v1, 4($t4)
    lw      $v1, 0($t1)
    lw      $v1, 32($v1)
    move    $a0, $t1
    move    $a1, $t2
    sw      $v1, 60($sp)
    sw      $t1, 0($sp)
    sw      $t3, 52($sp)
    sw      $t5, 56($sp)
    jalr    $v1
    lw      $v1, 60($sp)
    lw      $t1, 0($sp)
    lw      $t3, 52($sp)
    lw      $t5, 56($sp)
    beqz    $t5, _L45
    lw      $v1, 20($t3)
    move    $t4, $v1
    lw      $v1, 20($t4)
    move    $t0, $v1
    j       _L46
_L45:
    lw      $v1, 12($t3)
    move    $t4, $v1
    lw      $v1, 12($t4)
    move    $t0, $v1
_L46:
_L44:
    lw      $v1, 4($t3)
    sw      $v1, 4($t4)
    li      $v1, 0
    sw      $v1, 4($t3)
    li      $v1, 0
    sw      $v1, 4($t0)
    lw      $v1, 0($t1)
    lw      $v1, 32($v1)
    move    $a0, $t1
    move    $a1, $t4
    sw      $v1, 64($sp)
    sw      $t1, 0($sp)
    jalr    $v1
    lw      $v1, 64($sp)
    lw      $t1, 0($sp)
    lw      $v1, 28($t1)
    move    $t2, $v1
_L42:
    j       _L35
_L34:
    li      $v1, 0
    sw      $v1, 4($t2)
    j       _L_RBTree_delete_fix_exit
    # end of body

_L_RBTree_delete_fix_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 68  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_delete:  # function FUNCTION<RBTree.delete>
    # start of prologue
    addiu   $sp, $sp, -88  # push stack frame
    sw      $ra, 48($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t0, 0($sp)
    lw      $t1, 4($sp)
    lw      $v1, 28($t0)
    move    $t2, $v1
_L48:
    lw      $v1, 24($t0)
    sne     $v1, $t2, $v1
    beqz    $v1, _L47
    lw      $v1, 8($t2)
    seq     $v1, $v1, $t1
    beqz    $v1, _L49
    j       _L47
    j       _L50
_L49:
    lw      $v1, 8($t2)
    slt     $v1, $v1, $t1
    beqz    $v1, _L51
    lw      $v1, 20($t2)
    move    $t2, $v1
    j       _L52
_L51:
    lw      $v1, 12($t2)
    move    $t2, $v1
_L52:
_L50:
    j       _L48
_L47:
    move    $t3, $t2
    lw      $v1, 4($t3)
    move    $t4, $v1
    lw      $t1, 12($t2)
    lw      $v1, 24($t0)
    seq     $v1, $t1, $v1
    beqz    $v1, _L53
    lw      $v1, 20($t2)
    move    $t1, $v1
    lw      $v1, 0($t0)
    lw      $v1, 36($v1)
    move    $a0, $t0
    move    $a1, $t2
    move    $a2, $t1
    sw      $v1, 52($sp)
    sw      $t0, 0($sp)
    sw      $t1, 56($sp)
    sw      $t4, 60($sp)
    jalr    $v1
    lw      $v1, 52($sp)
    lw      $t0, 0($sp)
    lw      $t1, 56($sp)
    lw      $t4, 60($sp)
    j       _L54
_L53:
    lw      $t1, 20($t2)
    lw      $v1, 24($t0)
    seq     $v1, $t1, $v1
    beqz    $v1, _L55
    lw      $v1, 12($t2)
    move    $t1, $v1
    lw      $v1, 0($t0)
    lw      $v1, 36($v1)
    move    $a0, $t0
    move    $a1, $t2
    move    $a2, $t1
    sw      $v1, 64($sp)
    sw      $t0, 0($sp)
    sw      $t1, 56($sp)
    sw      $t4, 60($sp)
    jalr    $v1
    lw      $v1, 64($sp)
    lw      $t0, 0($sp)
    lw      $t1, 56($sp)
    lw      $t4, 60($sp)
    j       _L56
_L55:
    lw      $v1, 20($t2)
    move    $t3, $v1
_L58:
    lw      $t1, 12($t3)
    lw      $v1, 24($t0)
    sne     $v1, $t1, $v1
    beqz    $v1, _L57
    lw      $v1, 12($t3)
    move    $t3, $v1
    j       _L58
_L57:
    lw      $v1, 4($t3)
    move    $t4, $v1
    lw      $v1, 20($t3)
    move    $t1, $v1
    lw      $v1, 16($t3)
    seq     $v1, $v1, $t2
    beqz    $v1, _L59
    sw      $t3, 16($t1)
    j       _L60
_L59:
    lw      $v1, 0($t0)
    lw      $v1, 36($v1)
    move    $a0, $t0
    move    $a1, $t3
    move    $a2, $t1
    sw      $v1, 68($sp)
    sw      $t0, 0($sp)
    sw      $t1, 56($sp)
    sw      $t2, 72($sp)
    sw      $t3, 76($sp)
    sw      $t4, 60($sp)
    jalr    $v1
    lw      $v1, 68($sp)
    lw      $t0, 0($sp)
    lw      $t1, 56($sp)
    lw      $t2, 72($sp)
    lw      $t3, 76($sp)
    lw      $t4, 60($sp)
    lw      $v1, 20($t2)
    sw      $v1, 20($t3)
    lw      $v1, 20($t3)
    sw      $t3, 16($v1)
_L60:
    lw      $v1, 0($t0)
    lw      $v1, 36($v1)
    move    $a0, $t0
    move    $a1, $t2
    move    $a2, $t3
    sw      $v1, 80($sp)
    sw      $t0, 0($sp)
    sw      $t1, 56($sp)
    sw      $t2, 72($sp)
    sw      $t3, 76($sp)
    sw      $t4, 60($sp)
    jalr    $v1
    lw      $v1, 80($sp)
    lw      $t0, 0($sp)
    lw      $t1, 56($sp)
    lw      $t2, 72($sp)
    lw      $t3, 76($sp)
    lw      $t4, 60($sp)
    lw      $v1, 12($t2)
    sw      $v1, 12($t3)
    lw      $v1, 12($t3)
    sw      $t3, 16($v1)
    lw      $v1, 4($t2)
    sw      $v1, 4($t3)
_L56:
_L54:
    not     $v1, $t4
    beqz    $v1, _L61
    lw      $v1, 0($t0)
    lw      $v1, 12($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 84($sp)
    jalr    $v1
    lw      $v1, 84($sp)
_L61:
    j       _L_RBTree_delete_exit
    # end of body

_L_RBTree_delete_exit:
    # start of epilogue
    lw      $ra, 48($sp)  # restore the return address
    addiu   $sp, $sp, 88  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_print:  # function FUNCTION<RBTree.print>
    # start of prologue
    addiu   $sp, $sp, -52  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $t1, 0($sp)
    lw      $t0, 28($t1)
    lw      $v1, 0($t1)
    lw      $v1, 28($v1)
    move    $a0, $t1
    move    $a1, $t0
    sw      $v1, 48($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    j       _L_RBTree_print_exit
    # end of body

_L_RBTree_print_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 52  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_RBTree_print_impl:  # function FUNCTION<RBTree.print_impl>
    # start of prologue
    addiu   $sp, $sp, -56  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t2, 0($sp)
    lw      $t1, 4($sp)
    lw      $v1, 24($t2)
    seq     $v1, $t1, $v1
    beqz    $v1, _L62
    j       _L_RBTree_print_impl_exit
    j       _L63
_L62:
    lw      $t0, 12($t1)
    lw      $v1, 0($t2)
    lw      $v1, 28($v1)
    move    $a0, $t2
    move    $a1, $t0
    sw      $v1, 48($sp)
    sw      $t1, 4($sp)
    sw      $t2, 0($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t1, 4($sp)
    lw      $t2, 0($sp)
    lw      $v1, 8($t1)
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S4
    move    $a0, $v1
    li      $v0, 4
    syscall
    lw      $t0, 20($t1)
    lw      $v1, 0($t2)
    lw      $v1, 28($v1)
    move    $a0, $t2
    move    $a1, $t0
    sw      $v1, 52($sp)
    jalr    $v1
    lw      $v1, 52($sp)
_L63:
    j       _L_RBTree_print_impl_exit
    # end of body

_L_RBTree_print_impl_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 56  # pop stack frame
    # end of epilogue

    jr      $ra  # return

    # start of constant strings
    .data
_S0:
    .asciiz "Main"
_S1:
    .asciiz "Node"
_S2:
    .asciiz "RBTree"
_S3:
    .asciiz "Rng"
_S4:
    .asciiz " "
    # end of constant strings
