ASM = nasm
QEMU = qemu-system-x86_64

SRC = boot.asm
TARGET_DIR = build
EFI_FILE = $(TARGET_DIR)/BOOTX64.EFI
IMG_DIR = $(TARGET_DIR)/disk
OVMF_CODE = /usr/share/OVMF/OVMF_CODE.fd

NASMFLAGS = -f bin

.PHONY: all clean run

all: $(EFI_FILE)

$(EFI_FILE): $(SRC)
	@mkdir -p $(TARGET_DIR)
	$(NASM) $(NASMFLAGS) $(SRC) -o $(EFI_FILE)

run: $(EFI_FILE)
	@mkdir -p $(IMG_DIR)/EFI/BOOT
	cp $(EFI_FILE) $(IMG_DIR)/EFI/BOOT/BOOTX64.EFI
	$(QEMU) -drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE) \
	        -drive file=fat:rw:$(IMG_DIR),format=raw

clean:
	rm -rf $(TARGET_DIR)
