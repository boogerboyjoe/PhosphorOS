ORG 0x7C00
BITS 16

main:
    MOV AX,0
    MOV DS,AX
    MOV ES,AX
    MOV SS,AX

    MOV SP,0x7C00
    MOV SI,os_boot_msg
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
    OR AL,AL
    JZ done_print

    MOV AH,0x0E
    MOV BH,0
    INT 0x10

    JMP print_loop

done_print:
    POP BX
    POP AX
    POP SI
    RET
os_boot_msg: DB 'OS load sucessful.',0x0D,0x0A,0

TIMES 510-($-$$) DB 0
DW 0AA55h