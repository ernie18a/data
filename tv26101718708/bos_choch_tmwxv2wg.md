# BOS & CHoCH

- url: https://www.tradingview.com/script/Tmwxv2Wg/
- type: indicator
- pine_id: PUB;0e7e479acf914cb7b0bdd6d9093e1c6b
- version: 1.0

## Description

A clean, no-nonsense market structure indicator that automatically detects Break of Structure (BOS) and Change of Character (CHoCH) on any asset and any timeframe.

How it works
The script tracks swing highs and lows using pivot detection. When price breaks the last swing level, it's labeled as:

BOS — break in the direction of the current trend (continuation)
CHoCH — break against the current trend (potential reversal)

Since the logic is fully relative (pivot-based, no fixed values), it behaves identically on crypto, forex, indices, or stocks — from 1-minute charts to weekly.

Features
- BOS & CHoCH detection with clear on-chart labels
- Break confirmation mode: Close (filters fakeouts) or Wick
- Dotted extension of unbroken swing highs/lows — these act as resting liquidity targets
- Optional trend background & bar coloring
- Alerts for all four events (Bullish/Bearish BOS & CHoCH)
- Non-repainting: once printed, labels never change

Settings

Swing Length — higher values = only major structure, lower = more granular
Break Confirmation — Close is recommended to avoid wick fakeouts

Market structure is the foundation of any SMC or orderflow-based approach. Use CHoCH as an early warning for trend shifts and BOS as confirmation of continuation ideally combined with your own confluence (liquidity sweeps, volume, higher timeframe bias).

## Source Code

````pine
//@version=6
indicator("BOS & CHoCH", "BOS/CHoCH", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ════════════════════════ Inputs ════════════════════════
grpS = "Structure"
grpV = "Visuals"

swingLen   = input.int(10, "Swing Length", minval = 2, group = grpS, tooltip = "Pivot lookback/lookforward. Higher = only major structure. Relative logic → works identically on any timeframe & asset.")
brkMode    = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = grpS, tooltip = "Close = body must close beyond the level (fewer fakeouts). Wick = any poke counts.")
showLevels = input.bool(true, "Extend Active Swing Levels", group = grpS, tooltip = "Dotted lines = unbroken swing high/low (resting liquidity).")

bullCol    = input.color(#26a69a, "Bullish", group = grpV, inline = "c")
bearCol    = input.color(#ef5350, "Bearish", group = grpV, inline = "c")
showBg     = input.bool(false, "Trend Background", group = grpV)
colorBars  = input.bool(false, "Color Bars by Trend", group = grpV)

// ════════════════════════ State ═════════════════════════
var float hi     = na
var int   hiBar  = na
var bool  hiLive = false   // pivot high exists & not yet broken
var float lo     = na
var int   loBar  = na
var bool  loLive = false
var int   trend  = 0       //  1 = bullish, -1 = bearish, 0 = undefined
int evt = 0                //  1 BOS↑, 2 CHoCH↑, -1 BOS↓, -2 CHoCH↓

// ════════════════════════ Logic ═════════════════════════
// Pivot detection (confirms swingLen bars later — standard, non-repainting once printed)
float ph = ta.pivothigh(swingLen, swingLen)
float pl = ta.pivotlow(swingLen, swingLen)
if not na(ph)
    hi     := ph
    hiBar  := bar_index - swingLen
    hiLive := true
if not na(pl)
    lo     := pl
    loBar  := bar_index - swingLen
    loLive := true

float upSrc = brkMode == "Close" ? close : high
float dnSrc = brkMode == "Close" ? close : low

// Bullish break
if hiLive and upSrc > hi
    bool choch = trend == -1
    evt    := choch ? 2 : 1
    trend  := 1
    hiLive := false
    line.new(hiBar, hi, bar_index, hi, color = bullCol, width = 2)
    label.new(int(math.avg(hiBar, bar_index)), hi, choch ? "CHoCH" : "BOS", style = label.style_label_down, color = color.new(color.white, 100), textcolor = bullCol, size = size.small)

// Bearish break
if loLive and dnSrc < lo
    bool choch = trend == 1
    evt    := choch ? -2 : -1
    trend  := -1
    loLive := false
    line.new(loBar, lo, bar_index, lo, color = bearCol, width = 2)
    label.new(int(math.avg(loBar, bar_index)), lo, choch ? "CHoCH" : "BOS", style = label.style_label_up, color = color.new(color.white, 100), textcolor = bearCol, size = size.small)

// ════════════════ Active liquidity levels ═══════════════
var line hiLn = na
var line loLn = na
if showLevels
    if hiLive
        if na(hiLn) or line.get_y1(hiLn) != hi
            hiLn := line.new(hiBar, hi, bar_index, hi, color = color.new(color.gray, 30), style = line.style_dotted)
        line.set_x2(hiLn, bar_index)
    else if not na(hiLn)
        line.delete(hiLn)
        hiLn := na
    if loLive
        if na(loLn) or line.get_y1(loLn) != lo
            loLn := line.new(loBar, lo, bar_index, lo, color = color.new(color.gray, 30), style = line.style_dotted)
        line.set_x2(loLn, bar_index)
    else if not na(loLn)
        line.delete(loLn)
        loLn := na

// ════════════════════════ Visuals ═══════════════════════
bgcolor(showBg ? (trend == 1 ? color.new(bullCol, 94) : trend == -1 ? color.new(bearCol, 94) : na) : na)
barcolor(colorBars ? (trend == 1 ? bullCol : trend == -1 ? bearCol : na) : na)

// ════════════════════════ Alerts ════════════════════════
alertcondition(evt ==  1, "Bullish BOS",   "Bullish BOS — structure broken up")
alertcondition(evt ==  2, "Bullish CHoCH", "Bullish CHoCH — trend shift up")
alertcondition(evt == -1, "Bearish BOS",   "Bearish BOS — structure broken down")
alertcondition(evt == -2, "Bearish CHoCH", "Bearish CHoCH — trend shift down")
````
