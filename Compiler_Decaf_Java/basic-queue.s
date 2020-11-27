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
_V_Queue:  # virtual table for Queue
    .word 0    # parent: none
    .word _S1    # class name
    .word _L_Queue_DeQueue    # member method
    .word _L_Queue_EnQueue    # member method
    .word _L_Queue_Init    # member method

    .data
    .align 2
_V_QueueItem:  # virtual table for QueueItem
    .word 0    # parent: none
    .word _S2    # class name
    .word _L_QueueItem_GetData    # member method
    .word _L_QueueItem_GetNext    # member method
    .word _L_QueueItem_GetPrev    # member method
    .word _L_QueueItem_Init    # member method
    .word _L_QueueItem_SetNext    # member method
    .word _L_QueueItem_SetPrev    # member method

    .text
_L_QueueItem_new:  # function FUNCTION<QueueItem.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 16
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_QueueItem
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_QueueItem_new_exit
    # end of body

_L_QueueItem_new_exit:
    # start of epilogue
    lw      $ra, 36($sp)  # restore the return address
    addiu   $sp, $sp, 40  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Queue_new:  # function FUNCTION<Queue.new>
    # start of prologue
    addiu   $sp, $sp, -40  # push stack frame
    sw      $ra, 36($sp)  # save the return address
    # end of prologue

    # start of body
    li      $v1, 12
    move    $a0, $v1
    li      $v0, 9
    syscall
    move    $t0, $v0
    la      $v1, _V_Queue
    sw      $v1, 0($t0)
    move    $v0, $t0
    j       _L_Queue_new_exit
    # end of body

_L_Queue_new_exit:
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

_L_QueueItem_Init:  # function FUNCTION<QueueItem.Init>
    # start of prologue
    addiu   $sp, $sp, -56  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    sw      $a2, 8($sp)  # save arg 2
    sw      $a3, 12($sp)  # save arg 3
    lw      $t2, 0($sp)
    lw      $t1, 4($sp)
    lw      $t0, 8($sp)
    lw      $v1, 12($sp)
    sw      $t1, 4($t2)
    sw      $t0, 8($t2)
    sw      $t2, 12($t0)
    sw      $v1, 12($t2)
    sw      $t2, 8($v1)
    j       _L_QueueItem_Init_exit
    # end of body

_L_QueueItem_Init_exit:
    # start of epilogue
    addiu   $sp, $sp, 56  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_QueueItem_GetData:  # function FUNCTION<QueueItem.GetData>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $v1, 0($sp)
    lw      $v1, 4($v1)
    move    $v0, $v1
    j       _L_QueueItem_GetData_exit
    # end of body

_L_QueueItem_GetData_exit:
    # start of epilogue
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_QueueItem_GetNext:  # function FUNCTION<QueueItem.GetNext>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $v1, 0($sp)
    lw      $v1, 8($v1)
    move    $v0, $v1
    j       _L_QueueItem_GetNext_exit
    # end of body

_L_QueueItem_GetNext_exit:
    # start of epilogue
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_QueueItem_GetPrev:  # function FUNCTION<QueueItem.GetPrev>
    # start of prologue
    addiu   $sp, $sp, -44  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $v1, 0($sp)
    lw      $v1, 12($v1)
    move    $v0, $v1
    j       _L_QueueItem_GetPrev_exit
    # end of body

_L_QueueItem_GetPrev_exit:
    # start of epilogue
    addiu   $sp, $sp, 44  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_QueueItem_SetNext:  # function FUNCTION<QueueItem.SetNext>
    # start of prologue
    addiu   $sp, $sp, -48  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t0, 0($sp)
    lw      $v1, 4($sp)
    sw      $v1, 8($t0)
    j       _L_QueueItem_SetNext_exit
    # end of body

_L_QueueItem_SetNext_exit:
    # start of epilogue
    addiu   $sp, $sp, 48  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_QueueItem_SetPrev:  # function FUNCTION<QueueItem.SetPrev>
    # start of prologue
    addiu   $sp, $sp, -48  # push stack frame
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t0, 0($sp)
    lw      $v1, 4($sp)
    sw      $v1, 12($t0)
    j       _L_QueueItem_SetPrev_exit
    # end of body

_L_QueueItem_SetPrev_exit:
    # start of epilogue
    addiu   $sp, $sp, 48  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Queue_Init:  # function FUNCTION<Queue.Init>
    # start of prologue
    addiu   $sp, $sp, -60  # push stack frame
    sw      $ra, 52($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $t0, 0($sp)
    sw      $t0, 0($sp)
    jal     _L_QueueItem_new
    lw      $t0, 0($sp)
    move    $v1, $v0
    sw      $v1, 4($t0)
    li      $t3, 0
    lw      $t2, 4($t0)
    lw      $t1, 4($t0)
    lw      $t0, 4($t0)
    lw      $v1, 0($t0)
    lw      $v1, 20($v1)
    move    $a0, $t0
    move    $a1, $t3
    move    $a2, $t2
    move    $a3, $t1
    sw      $v1, 56($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    j       _L_Queue_Init_exit
    # end of body

_L_Queue_Init_exit:
    # start of epilogue
    lw      $ra, 52($sp)  # restore the return address
    addiu   $sp, $sp, 60  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Queue_EnQueue:  # function FUNCTION<Queue.EnQueue>
    # start of prologue
    addiu   $sp, $sp, -68  # push stack frame
    sw      $ra, 52($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    sw      $a1, 4($sp)  # save arg 1
    lw      $t4, 0($sp)
    lw      $t3, 4($sp)
    sw      $t3, 4($sp)
    sw      $t4, 0($sp)
    jal     _L_QueueItem_new
    lw      $t3, 4($sp)
    lw      $t4, 0($sp)
    move    $v1, $v0
    move    $t2, $v1
    lw      $t0, 4($t4)
    lw      $v1, 0($t0)
    lw      $v1, 12($v1)
    move    $a0, $t0
    sw      $v1, 56($sp)
    sw      $t2, 60($sp)
    sw      $t3, 4($sp)
    sw      $t4, 0($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    lw      $t2, 60($sp)
    lw      $t3, 4($sp)
    lw      $t4, 0($sp)
    move    $t1, $v0
    lw      $t0, 4($t4)
    lw      $v1, 0($t2)
    lw      $v1, 20($v1)
    move    $a0, $t2
    move    $a1, $t3
    move    $a2, $t1
    move    $a3, $t0
    sw      $v1, 64($sp)
    jalr    $v1
    lw      $v1, 64($sp)
    j       _L_Queue_EnQueue_exit
    # end of body

_L_Queue_EnQueue_exit:
    # start of epilogue
    lw      $ra, 52($sp)  # restore the return address
    addiu   $sp, $sp, 68  # pop stack frame
    # end of epilogue

    jr      $ra  # return

_L_Queue_DeQueue:  # function FUNCTION<Queue.DeQueue>
    # start of prologue
    addiu   $sp, $sp, -100  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    sw      $a0, 0($sp)  # save arg 0
    lw      $t1, 0($sp)
    lw      $t0, 4($t1)
    lw      $v1, 0($t0)
    lw      $v1, 16($v1)
    move    $a0, $t0
    sw      $v1, 48($sp)
    sw      $t1, 0($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t1, 0($sp)
    move    $t0, $v0
    lw      $v1, 4($t1)
    seq     $v1, $t0, $v1
    beqz    $v1, _L1
    la      $v1, _S3
    move    $a0, $v1
    li      $v0, 4
    syscall
    li      $v1, 0
    move    $v0, $v1
    j       _L_Queue_DeQueue_exit
    j       _L2
_L1:
    lw      $t0, 4($t1)
    lw      $v1, 0($t0)
    lw      $v1, 16($v1)
    move    $a0, $t0
    sw      $v1, 52($sp)
    jalr    $v1
    lw      $v1, 52($sp)
    move    $v1, $v0
    move    $t2, $v1
    lw      $v1, 0($t2)
    lw      $v1, 8($v1)
    move    $a0, $t2
    sw      $v1, 56($sp)
    sw      $t2, 60($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    lw      $t2, 60($sp)
    move    $v1, $v0
    move    $t3, $v1
    lw      $v1, 0($t2)
    lw      $v1, 12($v1)
    move    $a0, $t2
    sw      $v1, 64($sp)
    sw      $t2, 60($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 64($sp)
    lw      $t2, 60($sp)
    lw      $t3, 68($sp)
    move    $t1, $v0
    lw      $v1, 0($t2)
    lw      $v1, 16($v1)
    move    $a0, $t2
    sw      $v1, 72($sp)
    sw      $t1, 76($sp)
    sw      $t2, 60($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 72($sp)
    lw      $t1, 76($sp)
    lw      $t2, 60($sp)
    lw      $t3, 68($sp)
    move    $t0, $v0
    lw      $v1, 0($t0)
    lw      $v1, 24($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 80($sp)
    sw      $t2, 60($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 80($sp)
    lw      $t2, 60($sp)
    lw      $t3, 68($sp)
    lw      $v1, 0($t2)
    lw      $v1, 16($v1)
    move    $a0, $t2
    sw      $v1, 84($sp)
    sw      $t2, 60($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 84($sp)
    lw      $t2, 60($sp)
    lw      $t3, 68($sp)
    move    $t1, $v0
    lw      $v1, 0($t2)
    lw      $v1, 12($v1)
    move    $a0, $t2
    sw      $v1, 88($sp)
    sw      $t1, 92($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 88($sp)
    lw      $t1, 92($sp)
    lw      $t3, 68($sp)
    move    $t0, $v0
    lw      $v1, 0($t0)
    lw      $v1, 28($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 96($sp)
    sw      $t3, 68($sp)
    jalr    $v1
    lw      $v1, 96($sp)
    lw      $t3, 68($sp)
_L2:
    move    $v0, $t3
    j       _L_Queue_DeQueue_exit
    # end of body

_L_Queue_DeQueue_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 100  # pop stack frame
    # end of epilogue

    jr      $ra  # return

main:  # function main
    # start of prologue
    addiu   $sp, $sp, -76  # push stack frame
    sw      $ra, 44($sp)  # save the return address
    # end of prologue

    # start of body
    jal     _L_Queue_new
    move    $v1, $v0
    move    $t0, $v1
    lw      $v1, 0($t0)
    lw      $v1, 16($v1)
    move    $a0, $t0
    sw      $v1, 48($sp)
    sw      $t0, 52($sp)
    jalr    $v1
    lw      $v1, 48($sp)
    lw      $t0, 52($sp)
    li      $v1, 0
    move    $t1, $v1
_L4:
    li      $v1, 10
    slt     $v1, $t1, $v1
    beqz    $v1, _L3
    lw      $v1, 0($t0)
    lw      $v1, 12($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 56($sp)
    sw      $t0, 52($sp)
    sw      $t1, 60($sp)
    jalr    $v1
    lw      $v1, 56($sp)
    lw      $t0, 52($sp)
    lw      $t1, 60($sp)
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L4
_L3:
    li      $v1, 0
    move    $t1, $v1
_L6:
    li      $v1, 4
    slt     $v1, $t1, $v1
    beqz    $v1, _L5
    lw      $v1, 0($t0)
    lw      $v1, 8($v1)
    move    $a0, $t0
    sw      $v1, 64($sp)
    sw      $t0, 52($sp)
    sw      $t1, 60($sp)
    jalr    $v1
    lw      $v1, 64($sp)
    lw      $t0, 52($sp)
    lw      $t1, 60($sp)
    move    $v1, $v0
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S4
    move    $a0, $v1
    li      $v0, 4
    syscall
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L6
_L5:
    la      $v1, _S5
    move    $a0, $v1
    li      $v0, 4
    syscall
    li      $v1, 0
    move    $t1, $v1
_L8:
    li      $v1, 10
    slt     $v1, $t1, $v1
    beqz    $v1, _L7
    lw      $v1, 0($t0)
    lw      $v1, 12($v1)
    move    $a0, $t0
    move    $a1, $t1
    sw      $v1, 68($sp)
    sw      $t0, 52($sp)
    sw      $t1, 60($sp)
    jalr    $v1
    lw      $v1, 68($sp)
    lw      $t0, 52($sp)
    lw      $t1, 60($sp)
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L8
_L7:
    li      $v1, 0
    move    $t1, $v1
_L10:
    li      $v1, 17
    slt     $v1, $t1, $v1
    beqz    $v1, _L9
    lw      $v1, 0($t0)
    lw      $v1, 8($v1)
    move    $a0, $t0
    sw      $v1, 72($sp)
    sw      $t0, 52($sp)
    sw      $t1, 60($sp)
    jalr    $v1
    lw      $v1, 72($sp)
    lw      $t0, 52($sp)
    lw      $t1, 60($sp)
    move    $v1, $v0
    move    $a0, $v1
    li      $v0, 1
    syscall
    la      $v1, _S4
    move    $a0, $v1
    li      $v0, 4
    syscall
    li      $v1, 1
    add     $v1, $t1, $v1
    move    $t1, $v1
    j       _L10
_L9:
    la      $v1, _S5
    move    $a0, $v1
    li      $v0, 4
    syscall
    j       main_exit
    # end of body

main_exit:
    # start of epilogue
    lw      $ra, 44($sp)  # restore the return address
    addiu   $sp, $sp, 76  # pop stack frame
    # end of epilogue

    jr      $ra  # return

    # start of constant strings
    .data
_S0:
    .asciiz "Main"
_S1:
    .asciiz "Queue"
_S2:
    .asciiz "QueueItem"
_S3:
    .asciiz "Queue Is Empty"
_S4:
    .asciiz " "
_S5:
    .asciiz "\n"
    # end of constant strings
