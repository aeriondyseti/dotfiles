# Omarchy boot menu (reference — not deployed by chezmoi)

Themed GRUB menu in front of Omarchy's Limine bootloader, on a dual-boot
machine with Windows. Lives in `/boot`, which chezmoi doesn't manage, so these
files are run by hand.

## How it boots

```
firmware → GRUB (themed menu, 30s, default Windows)
             ├─ Windows       → chainloads \EFI\Microsoft\Boot\bootmgfw.efi
             └─ Omarchy Linux → chainloads \EFI\limine\limine_x64.efi
                                  → Limine: quiet, 0.5s, boots Omarchy
                                    (press a key during the 0.5s for snapshots)
```

Omarchy's updates keep managing Limine (kernel cmdline, snapshot entries), so
GRUB never needs to know about kernels. `grub.cfg` is hand-written — do not run
`grub-mkconfig`.

## Files

| File | Purpose |
|------|---------|
| `bootloader.png` | Source wallpaper (green circuit art, top-left) |
| `build-theme.sh W H` | Generates `omarchy-green/` (fonts, icons, highlight, theme.txt) for a GRUB resolution |
| `grub.cfg` | Two chainload entries + theme; `gfxmode=1920x1080,auto` |
| `install.sh` | First install: `grub-install` to `/boot`, copy theme + cfg, make Limine a quiet pass-through |
| `update.sh` | Re-copy theme + `grub.cfg` into `/boot/grub` after changes |
| `limine-header.conf` | Reference copy of the top of `/boot/limine.conf` (timeout, quiet, default entry, appearance) |

## Machine-specific values in `grub.cfg`

The `search --fs-uuid` lines use this machine's EFI partition UUIDs:
`6CD4-8998` (Windows ESP) and `97E0-0DF8` (Omarchy ESP). Check with `lsblk -f`
on a new machine.

## Lessons learned

- **Don't force a resolution change** on this hardware (3 GPUs, 4K HDMI TV):
  GRUB is fine at `1920x1080`, but forcing modes in Limine blanked the screen.
- The GPU's pre-boot (GOP) modes top out at **2048x1536**; there is no 4K or
  1440p mode, and the TV doesn't offer 1440p at all. **1920x1080** is the best
  16:9 mode. Check with `set pager=1` then `videoinfo` at the GRUB prompt (`c`).
- GRUB's PNG loader only reads **8-bit RGB/RGBA**. ImageMagick writes palette or
  16-bit PNGs for small images by default — always write `PNG32:` / `-depth 8`.
- GRUB draws `selected_item_pixmap_style` borders *outside* the item row, so
  `item_spacing` must exceed the slice size or highlights overlap.

## Usage

```bash
./build-theme.sh 1920 1080          # regenerate omarchy-green/
sudo bash ./install.sh              # first time only
sudo bash ./update.sh               # after theme / cfg changes
```
