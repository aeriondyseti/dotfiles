#!/bin/bash
# Temporarily override ANSI palette for this session to preview proposed colors.
# Close the terminal tab/window to reset back to normal.

# Proposed palette (keeping anchors: 3,5,6,11,12,13,14)
printf '\e]4;0;#1c1c1c\e\\'
printf '\e]4;1;#aa2020\e\\'
printf '\e]4;2;#1a9050\e\\'
# 3 keep: #cca300
printf '\e]4;4;#2a6099\e\\'
# 5 keep: #7a29a3
# 6 keep: #277b8e
printf '\e]4;7;#dcdcdc\e\\'
printf '\e]4;8;#555555\e\\'
printf '\e]4;9;#e62020\e\\'
printf '\e]4;10;#00e060\e\\'
# 11 keep: #d6d600
# 12 keep: #0090ff
# 13 keep: #d600d6
# 14 keep: #00e9e9
printf '\e]4;15;#f5f5f5\e\\'

echo ""
echo "══════════════════════════════════════════════════"
echo "  PROPOSED PALETTE PREVIEW"
echo "══════════════════════════════════════════════════"
echo ""

# Show all 16 colors as blocks
printf "  Normal:  "
for i in {0..7}; do printf "\e[48;5;${i}m    \e[0m"; done
echo ""
printf "  Bright:  "
for i in {8..15}; do printf "\e[48;5;${i}m    \e[0m"; done
echo ""
echo ""

# Show foreground text samples
echo "  ── Foreground samples ──"
printf "  \e[30m██ 0  black       \e[0m  \e[90m██ 8  bright black  \e[0m\n"
printf "  \e[31m██ 1  red         \e[0m  \e[91m██ 9  bright red    \e[0m\n"
printf "  \e[32m██ 2  green       \e[0m  \e[92m██ 10 bright green  \e[0m\n"
printf "  \e[33m██ 3  yellow      \e[0m  \e[93m██ 11 bright yellow \e[0m\n"
printf "  \e[34m██ 4  blue        \e[0m  \e[94m██ 12 bright blue   \e[0m\n"
printf "  \e[35m██ 5  magenta     \e[0m  \e[95m██ 13 bright magenta\e[0m\n"
printf "  \e[36m██ 6  cyan        \e[0m  \e[96m██ 14 bright cyan   \e[0m\n"
printf "  \e[37m██ 7  white       \e[0m  \e[97m██ 15 bright white  \e[0m\n"
echo ""

# Simulated OMP prompt
echo "  ── Simulated prompt ──"
printf "  \e[90m╭─\e[0m\e[94m:\e[1m~/Development/myproject\e[0m "
printf "\e[95m main\e[0m"
printf " \e[32m✓2\e[0m \e[33m~3\e[0m \e[96m⇡1\e[0m"
echo ""
printf "  \e[90m╰─\e[0m \e[96m\e[1maerion\e[36m@desktop\e[0m \e[90m❯\e[0m"
echo ""
echo ""

# Simulated diff output
echo "  ── Simulated diff ──"
printf "  \e[90m@@ -1,3 +1,4 @@\e[0m\n"
printf "  \e[37m context line\e[0m\n"
printf "  \e[31m- removed line\e[0m\n"
printf "  \e[32m+ added line\e[0m\n"
printf "  \e[33m! modified line\e[0m\n"
echo ""

# Simulated code
echo "  ── Simulated syntax ──"
printf "  \e[35mconst\e[0m \e[36mserver\e[0m \e[37m=\e[0m \e[32m\"localhost\"\e[0m\n"
printf "  \e[35mif\e[0m \e[37m(\e[0m\e[36merr\e[0m\e[37m)\e[0m \e[37m{\e[0m \e[31mthrow\e[0m \e[91mnew Error()\e[0m \e[37m}\e[0m\n"
printf "  \e[90m// this is a comment\e[0m\n"
printf "  \e[34mfunction\e[0m \e[33mhandler\e[0m\e[37m(\e[0m\e[36mreq\e[0m\e[37m)\e[0m \e[37m{\e[0m\e[37m}\e[0m\n"
echo ""
echo "══════════════════════════════════════════════════"
echo "  Close and reopen Ghostty to reset colors"
echo "══════════════════════════════════════════════════"
