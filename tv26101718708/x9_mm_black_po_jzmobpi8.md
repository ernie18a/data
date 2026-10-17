# x9 mm black po

- url: https://www.tradingview.com/script/jzMobPi8/
- type: indicator
- pine_id: PUB;e0f754cf97af4e528e1e98b8b7f07dd9
- version: 1.0

## Description

x9 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// SM BPCT - Brinks Power Confirmation Trade (Steve Mauro BTMM)
// Original: "!SM_BPCT.ex4" (2011-05, dal rar BTMM New Template & Indicator)
//
// "Brinks" nel metodo BTMM è la finestra 15-min PRIMA dell'apertura NY (9:30
// New York time → Brinks = 9:15-9:30 NY). È la fascia di accumulazione/stop
// hunt da cui parte la "real move" della sessione US.
//
// Cosa fa:
//   1. Disegna un box sulla Brinks zone (configurabile)
//   2. Cattura High e Low della Brinks
//   3. "Confirmation" = candela successiva che CHIUDE oltre Brinks H/L
//   4. Optional: alert + visual signal sulla rottura
// =============================================================================
indicator("x9 mm black po", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ---- Inputs ----
brinksTz       = input.string("America/New_York", "Timezone Brinks", tooltip="Brinks è ancorato a NY 9:15-9:30 — su TV usa 'America/New_York'")
brinksStart    = input.int(915, "Brinks start (HHMM, NY time)",  minval=0, maxval=2359, tooltip="Default 915 = 9:15 NY")
brinksEnd      = input.int(930, "Brinks end (HHMM, NY time)",    minval=0, maxval=2359, tooltip="Default 930 = 9:30 NY (NY open)")
showBox        = input.bool(true,  "Disegna box Brinks zone")
showHL         = input.bool(true,  "Mostra Brinks High/Low lines (estese)")
showConfirm    = input.bool(true,  "Segnala confirmation breakout")
extendBars     = input.int(60, "Estendi H/L per N barre dopo Brinks", minval=0, maxval=500)

boxCol         = input.color(color.new(color.purple, 80), "Box color")
hCol           = input.color(color.new(color.lime, 0),    "Brinks H color")
lCol           = input.color(color.new(color.red, 0),     "Brinks L color")
confirmCol     = input.color(color.new(color.yellow, 0),  "Confirmation color")

alertOnBreak   = input.bool(true, "Alert sulla confirmation")

// ---- Time helpers (in NY timezone) ----
hm = hour(time, brinksTz) * 100 + minute(time, brinksTz)
inBrinks = brinksStart <= brinksEnd ? (hm >= brinksStart and hm < brinksEnd) : (hm >= brinksStart or hm < brinksEnd)

// ---- Track Brinks H/L per session ----
var float bH = na
var float bL = na
var int   bStartBar = na
var int   bEndBar   = na
var box   bBox      = na
var line  bHLine    = na
var line  bLLine    = na
var bool  confirmedUp = false
var bool  confirmedDn = false

newBrinks = inBrinks and not inBrinks[1]
endBrinks = not inBrinks and inBrinks[1]

if newBrinks
    bH := high
    bL := low
    bStartBar := bar_index
    bEndBar := bar_index
    confirmedUp := false
    confirmedDn := false
    if showBox
        bBox := box.new(left=bar_index, top=high, right=bar_index, bottom=low, bgcolor=boxCol, border_color=color.new(boxCol, 50))

if inBrinks and not na(bH)
    bH := math.max(bH, high)
    bL := math.min(bL, low)
    bEndBar := bar_index
    if showBox and not na(bBox)
        box.set_top(bBox, bH)
        box.set_bottom(bBox, bL)
        box.set_right(bBox, bar_index)

if endBrinks and showHL and not na(bH)
    rightX = bar_index + extendBars
    bHLine := line.new(bEndBar, bH, rightX, bH, color=hCol, width=2, extend=extend.none)
    bLLine := line.new(bEndBar, bL, rightX, bL, color=lCol, width=2, extend=extend.none)
    label.new(rightX, bH, "Brinks H " + str.tostring(bH, format.mintick), style=label.style_label_left, color=color.new(hCol, 70), textcolor=color.white, size=size.small)
    label.new(rightX, bL, "Brinks L " + str.tostring(bL, format.mintick), style=label.style_label_left, color=color.new(lCol, 70), textcolor=color.white, size=size.small)

// ---- Confirmation breakout (post-Brinks, candle close oltre H or L) ----
postBrinks = not inBrinks and not na(bH) and bar_index > bEndBar and bar_index <= bEndBar + extendBars
confirmBreakUp = showConfirm and postBrinks and not confirmedUp and close > bH
confirmBreakDn = showConfirm and postBrinks and not confirmedDn and close < bL

if confirmBreakUp
    confirmedUp := true
    label.new(bar_index, high, "BPCT ▲", style=label.style_label_down, color=confirmCol, textcolor=color.black, size=size.normal)
if confirmBreakDn
    confirmedDn := true
    label.new(bar_index, low, "BPCT ▼", style=label.style_label_up, color=confirmCol, textcolor=color.black, size=size.normal)

plotshape(confirmBreakUp, "BPCT Long",  shape.triangleup,   location.belowbar, color=color.new(color.lime, 0),  size=size.small)
plotshape(confirmBreakDn, "BPCT Short", shape.triangledown, location.abovebar, color=color.new(color.red, 0),   size=size.small)

alertcondition(alertOnBreak and confirmBreakUp, "BPCT Long confirmation",  "BPCT: close above Brinks High — long bias")
alertcondition(alertOnBreak and confirmBreakDn, "BPCT Short confirmation", "BPCT: close below Brinks Low — short bias")
````
