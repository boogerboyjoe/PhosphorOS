ORG 0x0
BITS 16

main:
    MOV SI, os_boot_msg
    CALL print
    HLT

halt:
    JMP halt

print:
    PUSH SI
    PUSH AX
    PUSH BX

print_loop:
    LODSB
    TEST AL, AL
    JZ done_print

    MOV AH, 0x0E
    MOV BH, 0
    INT 0x10

    JMP print_loop

done_print:
    POP BX
    POP AX
    POP SI
    RET

os_boot_msg: DB 'OS boot sucessful.',0x0D,0x0A,0