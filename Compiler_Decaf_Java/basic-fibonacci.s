    # start of header
    .text
    .globl main
    # end of header

    .data
    .align 2
_V_Fibonacci:  # virtual table for Fibonacci
    .word 0    # parent: none
    .word _S0    # class name
    .word _L_Fibonacci_get    # member method

    .data
    .align 2
_V_Main:  # virtual table for Main
    .word 0    # parent: none
    .word _S1    # class name

    .text
_L_Fibonacci_new:  # function FUNCTION<Fibonacci.new>
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
    la      $v1, _V_Fibonacci
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_Fibonacci_new_exit
    # end of body

_L_Fibonacci_new_exit:
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
    addiu   $sp, $sp, -60  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 0
    move    $t1, $v1
    sw      $t1, 48($sp)
    jal     _L_Fibonacci_new
    lw      $t1, 48($sp)
    move    $v1, $v0
    move    $t0, $v1
_L2:
    li      $v1, 10
    slt     $v1, $t1, $v1
    beqz    $v1, _L1
    lw      $v1, 0($t0)
    lw      $v1, 8($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 52($sp)
    sw      $t0, 56($sp)
    sw      $t1, 48($sp)
    jalr    $v1
    lw      $v1, 52($sp)
    lw      $t0, 56($sp)
    lw      $t1, 48($sp)
    move    $v1, $v0
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L2
_L1:
    j       main_exit
    # end of body

main_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 60  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Fibonacci_get:  # function FUNCTION<Fibonacci.get>
    # start of prologue
    addiu   $sp, $sp, -60  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t3, 0($sp)
    lw      $t2, 4($sp)
    li      $v1, 2
    lw      $t2, 4($sp)
    slt     $v1, $t2, $v1
    beqz    $v1, _L3
    li      $v1, 1
    move    $v0, $v1
    j       _L_Fibonacci_get_exit
_L3:
    li      $v1, 1
    sub     $t0, $t2, $v1
    lw      $t3, 0($sp)
    lw      $v1, 0($t3)
    lw      $v1, 8($v1)
    move    $a0, $t3
    move    $a1, $t0
    sw      $v1, 48($sp)
    sw      $t2, 4($sp)
    sw      $t3, 0($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t2, 4($sp)
    lw      $t3, 0($sp)
    move    $t1, $v0
    li      $v1, 2
    sub     $t0, $t2, $v1
    lw      $v1, 0($t3)
    lw      $v1, 8($v1)
    move    $a0, $t3
    move    $a1, $t0
    sw      $v1, 52($sp)
    sw      $t1, 56($sp)
    jalr    $v1
    lw      $v1, 52($sp)
    lw      $t1, 56($sp)
    move    $v1, $v0
    add     $v1, $t1, $v1
    move    $v0, $v1
    j       _L_Fibonacci_get_exit
    # end of body

_L_Fibonacci_get_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 60  # pop stack frame
    # end of epilogue

    jr      $ra  # return

    # start of constant strings
    .data
_S0:
    .asciiz "Fibonacci"
_S1:
    .asciiz "Main"
_S2:
    .asciiz "\n"
    # end of constant strings
