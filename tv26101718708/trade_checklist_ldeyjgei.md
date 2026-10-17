# Trade Checklist

- url: https://www.tradingview.com/script/LDeYJGei-Trade-Checklist/
- type: indicator
- pine_id: PUB;3dcffad01e09459da7c32ec1e65bd398
- version: 1.0

## Description

somaliske krigere kun til ganget waleowwwww sk sk sk

## Source Code

````pine
//@version=5
indicator("Trade Checklist", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
smt    = input.bool(false, "✦ SMT Divergence",   group="Checklist")
absorb = input.bool(false, "✦ Absorption Candle", group="Checklist")
pbps   = input.bool(false, "✦ PB / PS Structure", group="Checklist")
stdv   = input.bool(false, "✦ STDV Level",        group="Checklist")

// ─── SCORE ────────────────────────────────────────────────────────────────────
score    = (smt ? 1 : 0) + (absorb ? 1 : 0) + (pbps ? 1 : 0) + (stdv ? 1 : 0)
allGreen = score == 4

// ─── COLORS ───────────────────────────────────────────────────────────────────
colCheck  = color.new(#26a69a, 0)
colCross  = color.new(#ef5350, 0)
colBg     = color.new(#131722, 85)
colBorder = allGreen ? color.new(#26a69a, 0) : color.new(#363a45, 0)
colScore  = allGreen ? color.new(#26a69a, 0) : color.new(#ffffff, 0)
colDark   = color.new(#1e222d, 0)
colText   = color.new(#d1d4dc, 0)
colHead   = color.new(#ffffff, 30)

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table t = table.new(
     position.top_right, 2, 6,
     bgcolor      = colBg,
     border_color = colBorder,
     border_width = 1,
     frame_color  = colBorder,
     frame_width  = 1)

// Header
table.cell(t, 0, 0, "CHECKLIST",     text_color=colHead,  text_size=size.small, text_halign=text.align_left,  bgcolor=colDark)
table.cell(t, 1, 0, str.tostring(score) + " / 4", text_color=colScore, text_size=size.small, text_halign=text.align_right, bgcolor=colDark)

// Row 1 — SMT
table.cell(t, 0, 1, "  SMT Divergence",  text_color=colText,  text_size=size.small, text_halign=text.align_left)
table.cell(t, 1, 1, smt    ? "●" : "○",  text_color=smt    ? colCheck : colCross, text_size=size.small, text_halign=text.align_center)

// Row 2 — Absorption
table.cell(t, 0, 2, "  Absorption",       text_color=colText,  text_size=size.small, text_halign=text.align_left)
table.cell(t, 1, 2, absorb ? "●" : "○",  text_color=absorb ? colCheck : colCross, text_size=size.small, text_halign=text.align_center)

// Row 3 — PB/PS
table.cell(t, 0, 3, "  PB / PS",          text_color=colText,  text_size=size.small, text_halign=text.align_left)
table.cell(t, 1, 3, pbps   ? "●" : "○",  text_color=pbps   ? colCheck : colCross, text_size=size.small, text_halign=text.align_center)

// Row 4 — STDV
table.cell(t, 0, 4, "  STDV Level",       text_color=colText,  text_size=size.small, text_halign=text.align_left)
table.cell(t, 1, 4, stdv   ? "●" : "○",  text_color=stdv   ? colCheck : colCross, text_size=size.small, text_halign=text.align_center)

// Footer
table.cell(t, 0, 5, allGreen ? "  ✦ READY TO TRADE" : "  " + str.tostring(score) + " of 4 confirmed", text_color=colScore, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(#1e222d, 40))
table.cell(t, 1, 5, "", bgcolor=color.new(#1e222d, 40))
````
