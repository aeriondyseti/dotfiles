#!/bin/bash
# Preview proposed WORK palette (Favor Delivery brand: blue + gold)
# Close the terminal tab/window to reset back to normal.

# Brand reference:
#   Favor Blue:  #0099E5
#   Navy:        #003349
#   Gold:        #F7AD2D
#   Red:         #E1251B
#   Green:       #228702

# Normal variants: ~60-70% sat, ~35-40% lightness
# Bright variants: ~100% sat, ~42-46% lightness
printf '\e]4;0;#0a1a24\e\\'    # deep navy-black (from #003349)
printf '\e]4;1;#942020\e\\'    # muted red (from brand red)
printf '\e]4;2;#1e7a10\e\\'    # muted green (from brand green)
printf '\e]4;3;#a07020\e\\'    # muted gold (from brand gold)
printf '\e]4;4;#1a6a9a\e\\'    # deep favor blue (from #0099E5)
printf '\e]4;5;#7a29a3\e\\'    # purple (same as personal)
printf '\e]4;6;#206880\e\\'    # muted teal
printf '\e]4;7;#dcdcdc\e\\'    # light gray
printf '\e]4;8;#3a5060\e\\'    # navy-tinted gray (comments)
printf '\e]4;9;#e0251b\e\\'    # bright red (brand red)
printf '\e]4;10;#28a702\e\\'   # bright green (brand green)
printf '\e]4;11;#f0a820\e\\'   # bright gold (brand gold)
printf '\e]4;12;#0099e5\e\\'   # Favor blue (brand primary!)
printf '\e]4;13;#d600d6\e\\'   # bright magenta (same as personal)
printf '\e]4;14;#00c8e0\e\\'   # bright cyan
printf '\e]4;15;#f5f5f5\e\\'   # bright white

echo ""
echo "══════════════════════════════════════════════════"
echo "  PROPOSED WORK PALETTE (Favor Delivery)"
echo "══════════════════════════════════════════════════"
echo ""

printf "  Normal:  "
for i in {0..7}; do printf "\e[48;5;${i}m    \e[0m"; done
echo ""
printf "  Bright:  "
for i in {8..15}; do printf "\e[48;5;${i}m    \e[0m"; done
echo ""
echo ""

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

echo "  ── Simulated prompt ──"
printf "  \e[90m╭─\e[0m\e[94m:\e[1m~/Development/favor-app\e[0m "
printf "\e[95m main\e[0m"
printf " \e[32m✓2\e[0m \e[33m~3\e[0m \e[96m⇡1\e[0m"
echo ""
printf "  \e[90m╰─\e[0m \e[96m\e[1mkdub\e[36m@macbook\e[0m \e[90m❯\e[0m"
echo ""
echo ""

echo "  ── Simulated diff ──"
printf "  \e[90m@@ -1,3 +1,4 @@\e[0m\n"
printf "  \e[37m context line\e[0m\n"
printf "  \e[31m- removed line\e[0m\n"
printf "  \e[32m+ added line\e[0m\n"
printf "  \e[33m! modified line\e[0m\n"
echo ""

echo "  ── Simulated syntax ──"
printf "  \e[35mconst\e[0m \e[36mserver\e[0m \e[37m=\e[0m \e[32m\"localhost\"\e[0m\n"
printf "  \e[35mif\e[0m \e[37m(\e[0m\e[36merr\e[0m\e[37m)\e[0m \e[37m{\e[0m \e[31mthrow\e[0m \e[91mnew Error()\e[0m \e[37m}\e[0m\n"
printf "  \e[90m// this is a comment\e[0m\n"
printf "  \e[34mfunction\e[0m \e[33mhandler\e[0m\e[37m(\e[0m\e[36mreq\e[0m\e[37m)\e[0m \e[37m{\e[0m\e[37m}\e[0m\n"
echo ""
echo "══════════════════════════════════════════════════"
echo "  Close and reopen Ghostty to reset colors"
echo "══════════════════════════════════════════════════"
