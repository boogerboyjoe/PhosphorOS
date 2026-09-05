default rel

bits 64

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
    .FirmwareRevision     RESD 1
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

_start:
    MOV [REL System_Table], RDX

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

codesize equ $ - $$

section .data
    Msg_Boot_Sucessful: DW 'Boot Sucessful!',13,10,0
    System_Table: DQ 0

datasize equ $ - $$