<!-- tradingview-pine-id: PUB;cc03c0b67aee489890f98cde2a18088a -->
<!-- tradingviewscripts-format: 1 -->
# My Rules Watermark

Source: https://www.tradingview.com/script/uoG3h8Z9-Rules-Watermark/

## Description

Rules Watermark turns your chart into an accountability tool. Instead of a generic ticker watermark, it prints your trading rules directly on the chart — always visible, always in front of you at the moment you're about to click buy or sell.

Discipline isn't a knowledge problem, it's a memory problem under pressure. This indicator solves that by keeping your checklist permanently on screen.

Features
Custom title — name your ruleset (e.g. "MY TRADING RULES", "PRE-TRADE CHECKLIST")
Up to 8 editable rules — leave any blank and they're automatically skipped, no empty gaps
9 chart positions — top/middle/bottom × left/center/right
Full styling control — independent size and color for the title and rule text
Text alignment — left, center, or right
Adjustable background — fully transparent by default for a true watermark feel
Optional symbol + timeframe line — toggle on for a classic watermark header
Zero chart clutter — table-based rendering, no plots, no repainting, no signals
How to Use
Add the indicator to your chart.
Open Settings → Rules and type your own rules into slots 1–8.
Under Style, choose the position and sizes that suit your layout.
Increase the color transparency (60–80%) for a subtle background watermark, or lower it for a bold, hard-to-ignore reminder.
Save as a chart template so it loads on every chart automatically.
Suggested Rule Sets
Risk-focused

1. Risk max 1% per trade
2. Stop loss set BEFORE entry
3. No averaging into losers
4. 2 losses = done for the day
Process-focused

1. Is this an A+ setup?
2. Did I wait for confirmation?
3. Is R:R at least 1:2?
4. Am I trading the plan or the emotion?
Notes
Display-only tool. It generates no buy/sell signals and gives no financial advice.
Works on all symbols, all timeframes, and all chart types.
The watermark renders on the last bar only, so it has negligible impact on chart performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IQ_Pips

//@version=6
indicator('My Rules Watermark', overlay = true)

// ── Inputs ──────────────────────────────────────────────
grpT = 'Title'
title = input.string('MY TRADING RULES', 'Title', group = grpT)
titleSize = input.string('huge', 'Title Size', options = ['tiny', 'small', 'normal', 'large', 'huge'], group = grpT)
titleCol = input.color(color.new(color.gray, 60), 'Title Color', group = grpT)

grpR = 'Rules'
r1 = input.string('1. Trade only A+ setups', 'Rule 1', group = grpR)
r2 = input.string('2. Risk max 1% per trade', 'Rule 2', group = grpR)
r3 = input.string('3. Wait for confirmation', 'Rule 3', group = grpR)
r4 = input.string('4. No revenge trading', 'Rule 4', group = grpR)
r5 = input.string('5. Respect the stop loss', 'Rule 5', group = grpR)
r6 = input.string('6. 2 losses = stop for the day', 'Rule 6', group = grpR)
r7 = input.string('', 'Rule 7', group = grpR)
r8 = input.string('', 'Rule 8', group = grpR)

grpS = 'Style'
rulesSize = input.string('normal', 'Rules Size', options = ['tiny', 'small', 'normal', 'large', 'huge'], group = grpS)
rulesCol = input.color(color.new(color.gray, 40), 'Rules Color', group = grpS)
pos = input.string('Middle Center', 'Position', options = ['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group = grpS)
align = input.string('center', 'Text Align', options = ['left', 'center', 'right'], group = grpS)
bgCol = input.color(color.new(color.black, 100), 'Background', group = grpS)
showSym = input.bool(false, 'Show Symbol / Timeframe', group = grpS)

// ── Helpers ─────────────────────────────────────────────
f_size(s) =>
    s == 'tiny' ? size.tiny : s == 'small' ? size.small : s == 'normal' ? size.normal : s == 'large' ? size.large : size.huge

f_vpos(p) =>
    str.startswith(p, 'Top') ? position.top_center : str.startswith(p, 'Middle') ? position.middle_center : position.bottom_center

f_pos(p) =>
    p == 'Top Left' ? position.top_left : p == 'Top Center' ? position.top_center : p == 'Top Right' ? position.top_right : p == 'Middle Left' ? position.middle_left : p == 'Middle Center' ? position.middle_center : p == 'Middle Right' ? position.middle_right : p == 'Bottom Left' ? position.bottom_left : p == 'Bottom Center' ? position.bottom_center : position.bottom_right

f_align(a) =>
    a == 'left' ? text.align_left : a == 'right' ? text.align_right : text.align_center

// ── Build text ──────────────────────────────────────────
body = ''
body := showSym ? syminfo.ticker + '  •  ' + timeframe.period + '\n' : ''
body := body + (r1 != '' ? r1 + '\n' : '')
body := body + (r2 != '' ? r2 + '\n' : '')
body := body + (r3 != '' ? r3 + '\n' : '')
body := body + (r4 != '' ? r4 + '\n' : '')
body := body + (r5 != '' ? r5 + '\n' : '')
body := body + (r6 != '' ? r6 + '\n' : '')
body := body + (r7 != '' ? r7 + '\n' : '')
body := body + (r8 != '' ? r8 : '')

// ── Render ──────────────────────────────────────────────
var table wm = table.new(f_pos(pos), 1, 2, bgcolor = bgCol, frame_width = 0, border_width = 0)

if barstate.islast
    table.cell(wm, 0, 0, title, text_color = titleCol, text_size = f_size(titleSize), text_halign = f_align(align), bgcolor = bgCol)
    table.cell(wm, 0, 1, body, text_color = rulesCol, text_size = f_size(rulesSize), text_halign = f_align(align), bgcolor = bgCol)
````
