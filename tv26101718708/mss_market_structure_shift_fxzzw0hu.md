# MSS - Market Structure Shift

- url: https://www.tradingview.com/script/fXzzw0hu-MSS-Market-Structure-Shift/
- type: indicator
- pine_id: PUB;f6f82fa6608146eba05d3cdc8b7827ab
- version: 1.0

## Description

Indicator to help identify clear market structure shifts

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sas413
//@version=6
indicator("MSS - Market Structure Shift", overlay=true, max_bars_back=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
lookback      = input.int(10, "Swing Lookback", minval=3, maxval=50)
showBullMSS   = input.bool(true, "Show Bullish MSS")
showBearMSS   = input.bool(true, "Show Bearish MSS")
showBullCHoCH = input.bool(true, "Show Bullish CHoCH")
showBearCHoCH = input.bool(true, "Show Bearish CHoCH")
showSwings    = input.bool(true, "Show Swing Points")

bullMSSColor   = input.color(#00E5FF, "Bullish MSS Color")
bearMSSColor   = input.color(#FF1744, "Bearish MSS Color")
bullCHoCHColor = input.color(#69F0AE, "Bullish CHoCH Color")
bearCHoCHColor = input.color(#FF6D00, "Bearish CHoCH Color")

// ─── PIVOTS ───────────────────────────────────────────────────────────────────
// Pivot confirmed lookback bars ago — we draw AT that historical bar
ph = ta.pivothigh(lookback, lookback)
pl = ta.pivotlow (lookback, lookback)

// ─── SWING TRACKING ───────────────────────────────────────────────────────────
var float prevHigh    = na
var float prevLow     = na
var float lastHigh    = na
var float lastLow     = na
var int   lastHighBar = na
var int   lastLowBar  = na
var int   trendDir    = 0   // 1 = bull, -1 = bear

// Update swing highs
if not na(ph)
    prevHigh    := lastHigh
    lastHigh    := ph
    lastHighBar := bar_index[lookback]

// Update swing lows
if not na(pl)
    prevLow    := lastLow
    lastLow    := pl
    lastLowBar := bar_index[lookback]

// ─── SWING POINT LABELS ───────────────────────────────────────────────────────
if showSwings and not na(ph)
    phTxt = not na(prevHigh) ? (ph > prevHigh ? "HH" : "LH") : "SH"
    label.new(bar_index[lookback], ph, phTxt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_down,
         color     = color.new(color.gray, 30),
         textcolor = color.white,
         size      = size.tiny)

if showSwings and not na(pl)
    plTxt = not na(prevLow) ? (pl > prevLow ? "HL" : "LL") : "SL"
    label.new(bar_index[lookback], pl, plTxt,
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_up,
         color     = color.new(color.gray, 30),
         textcolor = color.white,
         size      = size.tiny)

// ─── MSS DETECTION ────────────────────────────────────────────────────────────
bullMSS  = trendDir == -1 and not na(lastHigh) and close > lastHigh
bearMSS  = trendDir ==  1 and not na(lastLow)  and close < lastLow
bullCHoCH = trendDir == -1 and not na(prevHigh) and close > prevHigh and close <= lastHigh
bearCHoCH = trendDir ==  1 and not na(prevLow)  and close < prevLow  and close >= lastLow

// Update trend
if bullMSS
    trendDir := 1
if bearMSS
    trendDir := -1
// First swing detected
if trendDir == 0
    if not na(lastHigh) and not na(lastLow)
        trendDir := close > (lastHigh + lastLow) / 2 ? 1 : -1

// ─── DRAW MSS LABELS ──────────────────────────────────────────────────────────
if bullMSS and showBullMSS and not na(lastHigh)
    line.new(lastHighBar, lastHigh, bar_index, lastHigh,
         xloc  = xloc.bar_index,
         color = bullMSSColor,
         width = 2,
         style = line.style_dashed)
    label.new(bar_index, lastHigh, "▲ MSS",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_up,
         color     = bullMSSColor,
         textcolor = color.white,
         size      = size.normal)

if bearMSS and showBearMSS and not na(lastLow)
    line.new(lastLowBar, lastLow, bar_index, lastLow,
         xloc  = xloc.bar_index,
         color = bearMSSColor,
         width = 2,
         style = line.style_dashed)
    label.new(bar_index, lastLow, "▼ MSS",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_down,
         color     = bearMSSColor,
         textcolor = color.white,
         size      = size.normal)

// ─── DRAW CHoCH LABELS ────────────────────────────────────────────────────────
if bullCHoCH and showBullCHoCH and not na(prevHigh)
    line.new(lastHighBar, prevHigh, bar_index, prevHigh,
         xloc  = xloc.bar_index,
         color = bullCHoCHColor,
         width = 1,
         style = line.style_dotted)
    label.new(bar_index, prevHigh, "↑ CHoCH",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_up,
         color     = bullCHoCHColor,
         textcolor = color.white,
         size      = size.normal)

if bearCHoCH and showBearCHoCH and not na(prevLow)
    line.new(lastLowBar, prevLow, bar_index, prevLow,
         xloc  = xloc.bar_index,
         color = bearCHoCHColor,
         width = 1,
         style = line.style_dotted)
    label.new(bar_index, prevLow, "↓ CHoCH",
         xloc      = xloc.bar_index,
         yloc      = yloc.price,
         style     = label.style_label_down,
         color     = bearCHoCHColor,
         textcolor = color.white,
         size      = size.normal)

// ─── BACKGROUND BIAS ──────────────────────────────────────────────────────────
bgcolor(trendDir ==  1 ? color.new(bullMSSColor, 93) :
        trendDir == -1 ? color.new(bearMSSColor, 93) : na,
        title = "Bias")

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(bullMSS,   "Bullish MSS",   "▲ Bullish MSS confirmed")
alertcondition(bearMSS,   "Bearish MSS",   "▼ Bearish MSS confirmed")
alertcondition(bullCHoCH, "Bullish CHoCH", "↑ Bullish CHoCH confirmed")
alertcondition(bearCHoCH, "Bearish CHoCH", "↓ Bearish CHoCH confirmed")

//@version=6

plot(close)
````
