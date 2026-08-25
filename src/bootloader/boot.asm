ORG 0x7C00
BITS 16

JMP SHORT main
NOP

bdb_oem:    DB          'MSWIN4.1'
bdb_bytes_per_sector:   DW 512
bdb_sectors_per_cluster: DB 1
bdb_reserved_sectors:   DW 1
bdb_fat_count:          DB 2
bdb_dir_entries_count:  DW 0E0h
bdb_total_sectors:      DW 2880
bdb_media_descriptor_type: DB 0F0h
bdb_sectors_per_fat:    DW 9
bdb_sectors_per_track:  DW 18
bdb_heads:              DW 2
bdb_hidden_sectors:     DD 0
bdb_large_sector_count: DD 0

ebr_drive_number:       DB 0
                        DB 0
ebr_signature:          DB 29h
ebr_volume_id:          DB 12h,34h,56h,78h
ebr_volume_label:       DB 'TUNGSTENOS '
ebr_system_id:          DB 'FAT12   '

main:
    MOV AX, 0
    MOV DS,AX
    MOV ES,AX
    MOV SS,AX

    MOV SP, 0x7C00

    MOV [ebr_drive_number], DL
    MOV AX, 1
    MOV CL, 1
    MOV BX, 0x7E00
    CALL disk_read

    MOV SI, os_boot_msg
    CALL print
    HLT

halt:
    JMP halt

;Input: LBA index in AX
;CX [bits 0-5]: sector number
;CX [bits 6-15]: cylinder
;DH: head
lba_to_chs:
    PUSH AX
    PUSH DX

    XOR DX, DX
    DIV word [bdb_sectors_per_track]
    INC DX ;Sector
    MOV CX, DX

    XOR DX, DX
    DIV word [bdb_heads]

    MOV DH, DL ;Head
    MOV CH, AL
    SHL AH, 6
    OR CL, AH ;Cylinder

    POP AX
    MOV DL,AL
    POP AX
    
    RET

disk_read:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    CALL lba_to_chs

    MOV AH, 02h
    MOV DI, 3 ;Retry counter for reading

retry:
    STC
    INT 13h
    JNC successful_disk_read

    CALL disk_reset

    DEC DI
    TEST DI,DI
    JNZ retry

failed_disk_read:
    MOV SI, read_failure
    CALL print
    HLT
    JMP halt

disk_reset:
    PUSHA
    MOV AH, 0
    STC
    INT 13h
    JC failed_disk_read
    POPA

    RET

successful_disk_read:
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

print:
    PUSH SI
    PUSH AX
    PUSH BX

print_loop:
    LODSB
    OR AL, AL
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

os_boot_msg: DB 'OS load sucessful.',0x0D,0x0A,0
read_failure: DB 'Failed to read disk.',0x0D,0x0A,0

TIMES 510-($-$$) DB 0
DW 0AA55h