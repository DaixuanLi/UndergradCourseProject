    # start of header
    .text
    .globl main
    # end of header

    .data
    .align 2
_V_Main:  # virtual table for Main
    .word 0    # parent: none
    .word _S0    # class name

    .text
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
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 2
    move    $t3, $v1
    li      $v1, 3
    move    $t2, $v1
    li      $v1, 1
    move    $t1, $v1
    la      $v1, _S1
    move    $t0, $v1
    move    $a0, $t3
    li      $v0, 1
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    move    $a0, $t2
    li      $v0, 1
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    add     $v1, $t3, $t2
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    mul     $v1, $t3, $t2
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    move    $a0, $t1
    jal     _PrintBool
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    move    $a0, $t0
    li      $v0, 4
    syscall
    la      $v1, _S2
    move    $a0, $v1
    li      $v0, 4
    syscall
    j       main_exit
    # end of body

main_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

    # start of intrinsics
_PrintBool:  # intrinsic: print bool
    .data
_PrintBool_S_true:
    .asciiz "true"
_PrintBool_S_false:
    .asciiz "false"
    .text
    li $v0, 4    # print string
    beqz $a0, _PrintBool_false
    la $a0, _PrintBool_S_true
    syscall
    jr $ra
_PrintBool_false:
    la $a0, _PrintBool_S_false
    syscall
    jr $ra
    # end of intrinsics

    # start of constant strings
    .data
_S0:
    .asciiz "Main"
_S1:
    .asciiz "Hello THU"
_S2:
    .asciiz "\n"
    # end of constant strings
