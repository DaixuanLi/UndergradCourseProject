/* 各种使能信号*/
`define RstEnable 1'b1
`define RstDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define ChipEnable 1'b0 //低有效，与sram使能信号保持一致
`define ChipDisable 1'b1
`define Enable_N 1'b0
`define Disable_N 1'b1

`define PcRst 32'h80000000
`define PcStep 32'h4 //PC 每次加4

`define ZERO32 32'h00000000 //对应书上的ZEROWORD，因为可能还要16位的0
`define ZERO16 16'h0000
`define ZERO8 8'h00


`define InstAddrBus 31:0
`define InstDataBus 31:0

`define RegAddrBus 4:0
`define RegDataBus 31:0
`define SerialDataBus 7:0
`define RegAddrBitNum 5
`define ZeroRegAddr 5'h0

`define AluTypeBus 2:0
`define AluOpBus 7:0

`define RegNum 32

`define EXE_NOP_OP 8'b00000000 //*_OP：在*对应的指令码前面加00，扩展成8位
`define EXE_OR_OP 8'b00100101
`define EXE_AND_OP 8'b00100100
`define EXE_XOR_OP 8'b00100110
`define EXE_SLL_OP 8'b00000000
`define EXE_SRL_OP 8'b00000010
`define EXE_SRA_OP 8'b00000011
`define EXE_ADD_OP 8'b00100001
`define EXE_CLO_OP 8'b01100001 //ADD占用了00100001，所以做一些变化
`define EXE_MOVN_OP 8'b00001011
`define EXE_JR_OP 8'b00001000
`define EXE_J_OP 8'b01000010
`define EXE_JAL_OP 8'b01000011
`define EXE_BEQ_OP 8'b00000100
`define EXE_BGTZ_OP 8'b00000111
`define EXE_BNE_OP 8'b00000101
`define EXE_LB_OP 8'b00100000
`define EXE_LW_OP 8'b00100011
`define EXE_SB_OP 8'b00101000
`define EXE_SW_OP 8'b00101011
`define EXE_MFC0_OP 8'b10000000 //there are no operation codes for intterruptions
`define EXE_MTC0_OP 8'b10000001 //so we give them special code by setiing the first bit to 1
`define EXE_SYSCALL_OP 8'b10000010
`define EXE_ERET_OP 8'b10000011

`define EXE_NOP 6'b000000
`define EXE_AND 6'b100100
`define EXE_OR 6'b100101
`define EXE_XOR 6'b100110

`define EXE_ANDI 6'b001100
`define EXE_ORI 6'b001101
`define EXE_XORI 6'b001110
`define EXE_LUI 6'b001111

`define EXE_MOVN 6'b001011

`define EXE_SPECIAL 6'b000000 //AND OR XOR
`define EXE_SPECIAL2 6'b011100

`define LOGIC_OP2 5'b00000
`define SHIFT_OP 11'b00000000000

`define EXE_SLL 6'b000000
`define EXE_SRL 6'b000010
`define EXE_SRA 6'b000011

`define EXE_ADDU 6'b100001
// `define EXE_SUBU 6'b100011
`define EXE_ADDIU 6'b001001
`define EXE_CLO 6'b100001

`define EXE_SYSCALL 6'b001100
`define EXE_ERET 32'b01000010000000000000000000011000

`define EXE_TYPE_NOP 3'b000 //这里的type对应书上的RES，RES不知道什么意思，所以改成TYPE
`define EXE_TYPE_LOGIC 3'b001
`define EXE_TYPE_SHIFT 3'b010
`define EXE_TYPE_ARITH 3'b011
`define EXE_TYPE_MOVE 3'b0100
`define EXE_TYPE_J_B 3'b0101
`define EXE_TYPE_L_S 3'b0110

`define NOPRegAddr 5'b00000

`define InstValid 1'b0 //为啥反过来？
`define InstInvalid 1'b1

`define HasReadReg 1'b1
`define NoReadReg 1'b0

`define Stop 1'b1
`define NoStop 1'b0

`define Branch 1'b1
`define NoBranch 1'b0

`define EXE_J 6'b000010
`define EXE_JAL 6'b000011
`define EXE_JR 6'b001000
`define EXE_BEQ 6'b000100
`define EXE_BGTZ 6'b000111
`define EXE_BNE 6'b000101

`define EXE_LB 6'b100000
`define EXE_LW 6'b100011
`define EXE_SB 6'b101000
`define EXE_SW 6'b101011

`define InDelay 1'b1
`define NotInDelay 1'b0

`define RstRamType 2'b00
`define CodeRamType 2'b01
`define DataRamType 2'b10
`define UartType 2'b11

`define KernelCodeLo 32'h80000000
`define KernelCodeHi 32'h800FFFFF
`define UserCodeLo 32'h80100000
`define UserCodeHi 32'h803FFFFF
`define UserDataLo 32'h80400000
`define UserDataHi 32'h807EFFFF
`define KernelDataLo 32'h807F0000
`define KernelDataHi 32'h807FFFFF
`define UartDataLo 32'hBFD003F8
`define UartDataHi 32'hBFD003FC
`define InterruptAddr 32'h80001180

`define Busy 0
`define Ready 1
`define SerialNone 2'b00
`define SerialRead 2'b01
`define SerialWrite 2'b10

`define CP0_REG_STATUS    5'b01100
`define CP0_REG_CAUSE     5'b01101
`define CP0_REG_EPC       5'b01110
`define CP0_REG_EBASE     5'b01111

`define InterruptAssert    1'b1
`define InterruptNotAssert 1'b0

`define False_v 1'b0
`define True_v 1'b1

