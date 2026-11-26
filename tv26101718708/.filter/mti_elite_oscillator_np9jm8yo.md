# MTI Elite Oscillator

- url: https://www.tradingview.com/script/NP9jm8yO-MTI-Elite-Oscillator/
- type: indicator
- pine_id: PUB;37b82cef37d44c618e078c4ddb9192ae
- version: 1.0

## Description

Gabungan 2 Indikator yaitu RSI + MFI dalam 1 Indikator

## Source Code

````pine
//@version=5
// ╔══════════════════════════════════════════════════════════════╗
// ║      MINDS ELITE OSCILLATOR  —  Script 2 of 2 (Sub-Pane)    ║
// ║  Add this BELOW the main chart (overlay = false)             ║
// ║  Pair it with Minds_Elite_Signal for on-chart signals        ║
// ╚══════════════════════════════════════════════════════════════╝
indicator("Minds Elite Oscillator", shorttitle="ME_OSC", overlay=false,
          max_labels_count=500, max_lines_count=300)

// ================================================================
//  GROUP LABELS
// ================================================================
G_RSI = "⚙️ RSI Settings"
G_MFI = "⚙️ MFI Settings"
G_DIV = "🔍 Divergence Settings"
G_VIS = "🎨 Visual Settings"

// ================================================================
//  A. INPUTS
// ================================================================

rsiLen      = input.int (13,   "RSI Length",               minval=1,              group=G_RSI)
rsiOB       = input.int (70,   "RSI Overbought Level",     minval=50, maxval=100, group=G_RSI)
rsiOS       = input.int (30,   "RSI Oversold Level",       minval=0,  maxval=50,  group=G_RSI)

mfiLen      = input.int (13,   "MFI Length",               minval=1,              group=G_MFI)
mfiOB       = input.int (80,   "MFI Overbought Level",     minval=50, maxval=100, group=G_MFI)
mfiOS       = input.int (20,   "MFI Oversold Level",       minval=0,  maxval=50,  group=G_MFI)

divLookback = input.int (5,    "Pivot Lookback Period",    minval=2,  maxval=20,  group=G_DIV)
showDivLine = input.bool(true, "Show Divergence Lines",                            group=G_DIV)
showDivMark = input.bool(true, "Show Divergence Markers + Labels",                 group=G_DIV)

showBg      = input.bool(true, "Show Zone Backgrounds",                            group=G_VIS)
showLabels  = input.bool(true, "Show BUY / SELL Labels",                           group=G_VIS)
showRibbon  = input.bool(true, "Show RSI–MFI Ribbon Fill",                         group=G_VIS)

// ================================================================
//  B. CALCULATIONS
// ================================================================

rsiVal = ta.rsi(close, rsiLen)
mfiVal = ta.mfi(hlc3,  mfiLen)

longSignal  = rsiVal < rsiOS and mfiVal < mfiOS   // Both in oversold
shortSignal = rsiVal > rsiOB and mfiVal > mfiOB   // Both in overbought

// ================================================================
//  C. HORIZONTAL LEVELS  (all four required levels, dashed)
// ================================================================

h80  = hline(80, "OB 80",  color=color.new(color.red,    20), linestyle=hline.style_dashed, linewidth=1)
h70  = hline(70, "OB 70",  color=color.new(color.orange, 35), linestyle=hline.style_dashed, linewidth=1)
h50  = hline(50, "Mid 50", color=color.new(color.gray,   55), linestyle=hline.style_dotted, linewidth=1)
h30  = hline(30, "OS 30",  color=color.new(color.teal,   35), linestyle=hline.style_dashed, linewidth=1)
h20  = hline(20, "OS 20",  color=color.new(color.green,  20), linestyle=hline.style_dashed, linewidth=1)

// Zone backgrounds
fill(h80, h70, color = showBg ? color.new(color.red,   92) : na, title="OB Mild Zone")
fill(h30, h20, color = showBg ? color.new(color.green, 92) : na, title="OS Mild Zone")
fill(h70, h30, color = showBg ? color.new(color.teal,  96) : na, title="Neutral Zone")

// ================================================================
//  D. DIVERGENCE DETECTION  (Correct Method: Price Pivot Bars)
//
//  Key insight: we detect PRICE pivots first, then read RSI & MFI
//  values at those SAME bars (rsiVal[divLookback] / mfiVal[divLookback]).
//  This ensures the oscillator values correspond to the actual
//  swing high / low bars on the price chart.
// ================================================================

// Confirmed price pivot at bar_index - divLookback
pivLowPrice  = ta.pivotlow (low,  divLookback, divLookback)
pivHighPrice = ta.pivothigh(high, divLookback, divLookback)

// Persistent storage for the two most-recent confirmed pivots
var float prevLowPrice  = na,  var float currLowPrice  = na
var float prevHighPrice = na,  var float currHighPrice = na
var float prevLowRSI    = na,  var float currLowRSI    = na
var float prevHighRSI   = na,  var float currHighRSI   = na
var float prevLowMFI    = na,  var float currLowMFI    = na
var float prevHighMFI   = na,  var float currHighMFI   = na
var int   prevLowBar    = na,  var int   currLowBar    = na
var int   prevHighBar   = na,  var int   currHighBar   = na

// When a new LOW pivot is confirmed, rotate prev ← curr ← new
if not na(pivLowPrice)
    prevLowPrice := currLowPrice
    prevLowRSI   := currLowRSI
    prevLowMFI   := currLowMFI
    prevLowBar   := currLowBar
    currLowPrice := pivLowPrice
    currLowRSI   := rsiVal[divLookback]   // RSI value AT the pivot bar
    currLowMFI   := mfiVal[divLookback]   // MFI value AT the pivot bar
    currLowBar   := bar_index - divLookback

// When a new HIGH pivot is confirmed, rotate prev ← curr ← new
if not na(pivHighPrice)
    prevHighPrice := currHighPrice
    prevHighRSI   := currHighRSI
    prevHighMFI   := currHighMFI
    prevHighBar   := currHighBar
    currHighPrice := pivHighPrice
    currHighRSI   := rsiVal[divLookback]
    currHighMFI   := mfiVal[divLookback]
    currHighBar   := bar_index - divLookback

// ── Bullish Divergence (fire on the bar the new low pivot is confirmed) ──
//   Price: Lower Low   |   RSI/MFI: Higher Low

bullDivRSI = not na(prevLowPrice) and not na(currLowPrice) and
             not na(prevLowRSI)   and not na(currLowRSI)   and
             currLowPrice < prevLowPrice and   // Price Lower Low
             currLowRSI   > prevLowRSI   and   // RSI  Higher Low
             not na(pivLowPrice)                // only on confirmation bar

bullDivMFI = not na(prevLowPrice) and not na(currLowPrice) and
             not na(prevLowMFI)   and not na(currLowMFI)   and
             currLowPrice < prevLowPrice and
             currLowMFI   > prevLowMFI   and
             not na(pivLowPrice)

bullDiv = bullDivRSI or bullDivMFI

// ── Bearish Divergence ──────────────────────────────────────────────────
//   Price: Higher High   |   RSI/MFI: Lower High

bearDivRSI = not na(prevHighPrice) and not na(currHighPrice) and
             not na(prevHighRSI)   and not na(currHighRSI)   and
             currHighPrice > prevHighPrice and  // Price Higher High
             currHighRSI   < prevHighRSI   and  // RSI  Lower  High
             not na(pivHighPrice)

bearDivMFI = not na(prevHighPrice) and not na(currHighPrice) and
             not na(prevHighMFI)   and not na(currHighMFI)   and
             currHighPrice > prevHighPrice and
             currHighMFI   < prevHighMFI   and
             not na(pivHighPrice)

bearDiv = bearDivRSI or bearDivMFI

// ================================================================
//  E. DIVERGENCE LINES  (drawn in the oscillator pane)
//     Solid line = RSI divergence | Dashed line = MFI divergence
//
//  NOTE: line.style_* and line.extend.* cannot be resolved as
//  namespace constants inside if-blocks in Pine Script v5.
//  Pre-declaring them as plain variables fixes the parser error.
// ================================================================

_LS_SOLID  = line.style_solid
_LS_DASHED = line.style_dashed
_LE_NONE   = extend.none

if showDivLine and bullDivRSI and not na(prevLowBar) and not na(currLowBar)
    _l = line.new(prevLowBar, prevLowRSI, currLowBar, currLowRSI, color=color.lime, width=2, style=_LS_SOLID, extend=_LE_NONE)

if showDivLine and bullDivMFI and not na(prevLowBar) and not na(currLowBar)
    _l = line.new(prevLowBar, prevLowMFI, currLowBar, currLowMFI, color=color.new(color.lime, 40), width=1, style=_LS_DASHED, extend=_LE_NONE)

if showDivLine and bearDivRSI and not na(prevHighBar) and not na(currHighBar)
    _l = line.new(prevHighBar, prevHighRSI, currHighBar, currHighRSI, color=color.red, width=2, style=_LS_SOLID, extend=_LE_NONE)

if showDivLine and bearDivMFI and not na(prevHighBar) and not na(currHighBar)
    _l = line.new(prevHighBar, prevHighMFI, currHighBar, currHighMFI, color=color.new(color.red, 40), width=1, style=_LS_DASHED, extend=_LE_NONE)


// ================================================================
//  F. PLOTS — RSI & MFI Lines
// ================================================================

rsiPlot = plot(rsiVal, "RSI", color=color.new(color.purple, 0), linewidth=2)
mfiPlot = plot(mfiVal, "MFI", color=color.new(color.blue,   0), linewidth=2)

// Ribbon fill between RSI and MFI
fill(rsiPlot, mfiPlot,
     color = showRibbon
             ? (rsiVal > mfiVal ? color.new(color.purple, 87) : color.new(color.blue, 87))
             : na,
     title = "RSI–MFI Ribbon")

// Extreme zone highlight (both oscillators simultaneously in danger zone)
bgcolor(longSignal  ? color.new(color.green, 80) : na, title="Both Oversold  BG")
bgcolor(shortSignal ? color.new(color.red,   80) : na, title="Both Overbought BG")

// ================================================================
//  G. BUY / SELL LABELS  (inside the oscillator pane)
// ================================================================

if showLabels and longSignal
    label.new(bar_index, rsiOS - 6, text="BUY", style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=size.small)

if showLabels and shortSignal
    label.new(bar_index, rsiOB + 6, text="SELL", style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=size.small)

// ================================================================
//  H. DIVERGENCE MARKERS + LABELS  (inside the oscillator pane)
// ================================================================

// Circle markers at top/bottom of pane
plotshape(showDivMark and bullDiv,
          title    = "Bullish Divergence Dot",
          style    = shape.circle,
          location = location.bottom,
          color    = color.new(color.lime, 0),
          size     = size.small)

plotshape(showDivMark and bearDiv,
          title    = "Bearish Divergence Dot",
          style    = shape.circle,
          location = location.top,
          color    = color.new(color.red, 0),
          size     = size.small)

// Text labels for divergence type
if showDivMark and bullDiv
    divSrc = bullDivRSI and bullDivMFI ? " RSI+MFI" : bullDivRSI ? " RSI" : " MFI"
    label.new(bar_index, 4, text="▲ Bull Div" + divSrc, style=label.style_label_up, color=color.new(color.lime, 15), textcolor=color.white, size=size.tiny)

if showDivMark and bearDiv
    divSrc = bearDivRSI and bearDivMFI ? " RSI+MFI" : bearDivRSI ? " RSI" : " MFI"
    label.new(bar_index, 96, text="▼ Bear Div" + divSrc, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.tiny)

// ================================================================
//  I. ALERT CONDITIONS
// ================================================================

alertcondition(bullDiv,
               title   = "🟢 Bullish Divergence (ME_OSC)",
               message = "Minds Elite OSC | BULLISH DIVERGENCE on {{ticker}} {{interval}} — Price made Lower Low while RSI or MFI made Higher Low. Possible reversal up.")

alertcondition(bearDiv,
               title   = "🔴 Bearish Divergence (ME_OSC)",
               message = "Minds Elite OSC | BEARISH DIVERGENCE on {{ticker}} {{interval}} — Price made Higher High while RSI or MFI made Lower High. Possible reversal down.")

alertcondition(longSignal,
               title   = "⚡ Both Oscillators Oversold (ME_OSC)",
               message = "Minds Elite OSC | RSI and MFI both entered Oversold zone simultaneously on {{ticker}} {{interval}}. Momentum exhaustion — watch for long trigger.")

alertcondition(shortSignal,
               title   = "⚡ Both Oscillators Overbought (ME_OSC)",
               message = "Minds Elite OSC | RSI and MFI both entered Overbought zone simultaneously on {{ticker}} {{interval}}. Momentum exhaustion — watch for short trigger.")

alertcondition(bullDiv or longSignal,
               title   = "🟢 Any Bullish OSC Signal",
               message = "Minds Elite OSC | Bullish oscillator signal on {{ticker}} {{interval}} — Divergence or Oversold extreme detected.")

alertcondition(bearDiv or shortSignal,
               title   = "🔴 Any Bearish OSC Signal",
               message = "Minds Elite OSC | Bearish oscillator signal on {{ticker}} {{interval}} — Divergence or Overbought extreme detected.")
````
