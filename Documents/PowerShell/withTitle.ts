#!/usr/bin/env bun
// withTitle.ts — run a command under a persistent title strip pinned to the top
// of the pane, with the child's output scrolling in the region below it.
//
//   withTitle "web-1" bun run dev
//   withTitle "api"   node server.js
//
// How it works: switches to the alternate screen buffer (ESC[?1049h) — an
// isolated fullscreen surface, like less/vim — so nothing leaks into the pane's
// scrollback. On it, a DECSTBM scroll region (ESC[<top>;<bottom>r) excludes the
// top row and the child's output scrolls below the header. The header is redrawn
// with a save/restore-cursor pair (ESC7/ESC8) so it never disturbs the child's
// cursor. A short timer re-draws it to survive screen clears; on resize the
// region is recomputed. On exit it leaves the alt screen, restoring the prior view.
//
// Trade-off: no native scrollback within the wrapped view while it runs.
// Caveat: aimed at line-oriented output (logs, dev servers). Full-screen TUIs
// run *inside* the wrapper (vim, htop) drive the alt screen themselves and will
// fight the header — run those without withTitle.

const ESC = "\x1b";
const [title, cmd, ...args] = process.argv.slice(2);

if (!title || !cmd) {
  process.stderr.write('Usage: withTitle "<title>" <command> [args...]\n');
  process.exit(2);
}

const out = (s: string) => process.stdout.write(s);
const rows = () => process.stdout.rows ?? 24;
const cols = () => process.stdout.columns ?? 80;

const HEADER_ROWS = 1;

function drawHeader() {
  const label = ` ▶ ${title}`;
  const width = cols();
  const line =
    label.length >= width ? label.slice(0, width) : label + " ".repeat(width - label.length);
  // ESC7 save cursor+attrs, home, blue bg / bold white fg, text, reset, ESC8 restore.
  out(`${ESC}7${ESC}[1;1H${ESC}[44m${ESC}[1;97m${line}${ESC}[0m${ESC}8`);
}

function setRegion() {
  // Scroll region from the row below the header down to the last row.
  out(`${ESC}[${HEADER_ROWS + 1};${rows()}r`);
}

function setup() {
  out(`${ESC}[?1049h`); // enter the alternate screen (exclusive fullscreen)
  out(`${ESC}[2J`); // clear it
  setRegion();
  drawHeader();
  out(`${ESC}[${HEADER_ROWS + 1};1H`); // park cursor at top of the scroll region
}

function teardown() {
  out(`${ESC}[r`); // reset scroll region
  out(`${ESC}[0m`); // reset attrs
  out(`${ESC}[?1049l`); // leave the alternate screen, restoring the prior view
}

function onResize() {
  setRegion(); // recompute bottom margin for the new size
  drawHeader();
}

setup();
const redraw = setInterval(drawHeader, 500);
process.stdout.on("resize", onResize);

const child = Bun.spawn([cmd, ...args], {
  stdin: "inherit",
  stdout: "inherit",
  stderr: "inherit",
});

// Forward termination to the child; its exit drives ours.
const forward = (sig: NodeJS.Signals) => () => child.kill(sig);
process.on("SIGINT", forward("SIGINT"));
process.on("SIGTERM", forward("SIGTERM"));

const code = await child.exited;

clearInterval(redraw);
process.stdout.off("resize", onResize);
teardown();
process.exit(code ?? 0);
