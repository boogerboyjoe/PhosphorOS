default rel

bits 64

section_alignment equ 0x1000

image_start:
header_start:
dos_header:
    db 'MZ'
    times 58 db 0
    dd pe_header - image_start

pe_header:
    db 'PE', 0, 0
    dw 0x8664
    dw 2                     ; Section Ammount
    dd 0
    dd 0, 0
    dw optional_header_end - optional_header
    dw 0x0206                ; (Executable, 64-bit)

optional_header:
    dw 0x020B
    db 0, 0
    dd code_end - code_start ; Size of code
    dd data_end - data_start ; Size of data
    dd 0                     ; Size of BSS
    dd code_start - image_start ; Entry Point address
    dd code_start - image_start ; Base of code address
    dq 0x00400000            ; Image Base
    dd section_alignment     ; Section Alignment
    dd section_alignment     ; File Alignment
    dw 0, 0, 0, 0
    dw 6, 0
    dd 0
    dd image_end - image_start
    dd header_end - header_start
    dd 0
    dw 10
    dw 0
    dq 0x8000, 0x1000 
    dq 0x8000, 0x1000
    dd 0, 16
    times 16 * 8 db 0
optional_header_end:

; Maps where .text and .data live in memory
section_table:
    db '.text', 0, 0, 0
    dd code_end - code_start
    dd code_start - image_start
    dd code_end - code_start
    dd code_start - image_start
    dd 0, 0
    dw 0, 0
    dd 0x60000020

    db '.data', 0, 0, 0
    dd data_end - data_start
    dd data_start - image_start
    dd data_end - data_start
    dd data_start - image_start
    dd 0, 0
    dw 0, 0
    dd 0xC0000040

times section_alignment - ($ - image_start) db 0
header_end:

struc EFI_TABLE_HEADER
    .Signature  RESQ 1
    .Revision   RESD 1
    .HeaderSize RESD 1
    .CRC32      RESD 1
    .Reserved   RESD 1
endstruc

struc EFI_SYSTEM_TABLE
    .Hdr                  RESB EFI_TABLE_HEADER_size
    .FirmwareVendor       RESQ 1
    .FirmwareRevision     RESQ 1
    .ConsoleInHandle      RESQ 1
    .ConIn                RESQ 1
    .ConsoleOutHandle     RESQ 1
    .ConOut               RESQ 1
    .StandardErrorHandle  RESQ 1
    .StdErr               RESQ 1
    .RuntimeServices      RESQ 1
    .BootServices         RESQ 1
    .NumberOfTableEntries RESQ 1
    .ConfigurationTable   RESQ 1
endstruc

struc EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    .Reset             RESQ 1
    .OutputString      RESQ 1
    .TestString        RESQ 1
    .QueryMode         RESQ 1
    .SetMode           RESQ 1
    .SetAttribute      RESQ 1
    .ClearScreen       RESQ 1
    .SetCursorPosition RESQ 1
    .EnableCursor      RESQ 1
    .Mode              RESQ 1
endstruc

section .text

global _start

code_start:
_start:
    MOV [REL System_Table], RDX
    MOV [REL Image_Handle], RCX

    LEA RDX, [REL Msg_Boot_Sucessful]
    CALL print

    JMP halt

halt:
    JMP halt

; RDX is the message input
print:
    MOV RBX, [REL System_Table]
    MOV RBX, [RBX + EFI_SYSTEM_TABLE.ConOut]
    MOV RAX, [RBX + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
    MOV RCX, RBX

    SUB RSP, 40
    CALL RAX
    ADD RSP, 40
    RET

align section_alignment, db 0
code_end:

section .data
data_start:

    Msg_Boot_Sucessful: DW __utf16__ 'Bootloader Successful',13,10,0
    System_Table: DQ 0
    Image_Handle: DQ 0

align section_alignment, db 0
data_end:
image_end: