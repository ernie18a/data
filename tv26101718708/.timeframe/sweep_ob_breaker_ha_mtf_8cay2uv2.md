# Sweep OB + Breaker [HA] MTF

- url: https://www.tradingview.com/script/8CAY2Uv2/
- type: indicator
- pine_id: PUB;b24aed0d1ec04426ae54dc95306a1bbb
- version: 1.0

## Description

# Sweep OB + Breaker [HA] MTF

## Overview

This indicator detects **Order Blocks (OB)** and **Breaker Blocks (BRK)** using **Heikin-Ashi** candles across two timeframes simultaneously — your current chart timeframe (LTF) and a configurable higher timeframe (HTF, default 15m).

The logic is rooted in **SMC (Smart Money Concepts)**: it only marks a zone after a complete sequence of **Liquidity Sweep → Change of Character (CHoC) → Order Block identification**, ensuring every zone has a structural narrative behind it.

---

## Core Logic

### Step 1 — Liquidity Sweep
The indicator detects when a Heikin-Ashi wick pierces below a prior swing low (or above a prior swing high) and **closes back inside** — signaling a stop hunt rather than a genuine breakout.

### Step 2 — Change of Character (CHoC)
After a sweep, the script watches for the HA close to break the **opposite swing level**, confirming a structural reversal. This is the CHoC — the market has changed hands.

### Step 3 — Order Block
Once the CHoC is confirmed, the script looks back from the CHoC candle and marks the **last opposing-color HA candle** before the reversal. This candle is the Order Block — the last footprint of institutional activity before the move.

### Step 4 — Breaker Block
When price fully **closes through an OB**, that zone doesn't disappear — it flips into a **Breaker Block** with inverted polarity (a former support becomes resistance, and vice versa), displayed with a dashed border.

---

## Zone States

Each zone is tracked in real time:

| State | Description |
|---|---|
| **Naked** | Zone untouched since creation |
| **Mitigated** | Price has entered the zone |
| **Liquidated → Breaker** | Price closed fully through the zone — converts to Breaker |

---

## Multi-Timeframe Confluence

The HTF engine runs the same Sweep → CHoC → OB/BRK logic independently on your chosen higher timeframe. This gives you two layers of information simultaneously:

- **HTF direction** — a real-time label (▲ Bullish / ▼ Bearish / — Neutral) shows the current HTF trend based on the last HTF CHoC
- **HTF zones** — displayed with a thicker border and labeled "HTF OB ▲/▼" or "HTF BRK ▲/▼" so they're immediately distinguishable from LTF zones
- **Confluence highlight** — when price is inside an HTF zone AND the HTF direction aligns with the LTF signal, the bar background turns green (long) or red (short), giving you a clear visual cue that all timeframes agree

---

## How to Use

**Scalping (e.g. 1m chart):** set HTF to 5m or 15m. Look for LTF CHoC labels that appear while price is inside an HTF zone and the HTF label reads Bullish/Bearish.

**Intraday (e.g. 5m–15m chart):** set HTF to 1h or 4h. Use HTF zones as macro support/resistance and enter on LTF OB retests.

**Swing (e.g. 1h–4h chart):** set HTF to Daily. Only trade LTF setups that occur inside Daily OB or BRK zones.

The ideal entry sequence:
1. HTF CHoC confirms direction
2. Price pulls back into an HTF OB or BRK zone
3. On the LTF, a new Sweep → CHoC fires in the same direction
4. Bar background highlights — this is your entry window

---

## Inputs

| Parameter | Description |
|---|---|
| LTF Swing Lookback | Number of candles left/right to confirm a swing pivot on the chart TF |
| LTF OB Search Bars | How many bars back to look for the last opposing HA candle |
| Higher Timeframe | The HTF to run the second analysis on (default: 15m) |
| HTF Swing Lookback | Same as LTF but for the HTF engine |
| Show LTF / HTF Zones | Toggle visibility of each layer independently |
| LTF / HTF Colors | Fully customizable colors for all 4 zone types on each timeframe |

---

## Alerts

4 alert conditions are available:

- **LTF Bullish CHoC** — a bullish CHoC was confirmed on the chart timeframe
- **LTF Bearish CHoC** — a bearish CHoC was confirmed on the chart timeframe
- **Long Confluence** — HTF is bullish, price is in an HTF bull zone, and LTF aligned
- **Short Confluence** — HTF is bearish, price is in an HTF bear zone, and LTF aligned

The **Long/Short Confluence** alerts are the highest-quality signals — set these with "Once per bar close" to avoid noise.

---

## Notes

- All structure detection runs on **Heikin-Ashi values** fetched via `request.security` for accuracy regardless of your chart candle type. Entry/exit decisions are left to the trader and use real price levels.
- HTF data uses `lookahead=barmerge.lookahead_off` to prevent repainting.
- Only the **most recent** OB and Breaker per direction are kept active at any time, keeping the chart clean.
- Works on any instrument and any timeframe. Recommended to keep LTF Swing Lookback between 3–10 for scalping and 5–15 for intraday.

## Source Code

````pine
// © Océan — Sweep OB + Breaker [HA] MTF
//@version=6
indicator("Sweep OB + Breaker [HA] MTF", overlay=true, max_boxes_count=50, max_labels_count=50)

// ─────────────────────────────────────────────
// INPUTS — LTF STRUCTURE
// ─────────────────────────────────────────────
ltfSwingLen  = input.int(5,  "LTF Swing Lookback",  minval=3, maxval=50, group="LTF Structure")
ltfSearchLen = input.int(30, "LTF OB Search Bars",  minval=5, maxval=60, group="LTF Structure")
showLTF      = input.bool(true, "Show LTF Zones",                        group="LTF Structure")

// ─────────────────────────────────────────────
// INPUTS — HTF STRUCTURE
// ─────────────────────────────────────────────
htfTF        = input.timeframe("15", "Higher Timeframe",                 group="HTF Structure")
htfSwingLen  = input.int(5,  "HTF Swing Lookback",  minval=3, maxval=50, group="HTF Structure")
htfSearchLen = input.int(30, "HTF OB Search Bars",  minval=5, maxval=60, group="HTF Structure")
showHTF      = input.bool(true, "Show HTF Zones",                        group="HTF Structure")

// ─────────────────────────────────────────────
// INPUTS — COLORS LTF
// ─────────────────────────────────────────────
cLtfObBull  = input.color(color.new(#00e676, 80), "LTF Bull OB",  group="LTF Colors")
cLtfObBear  = input.color(color.new(#ef5350, 80), "LTF Bear OB",  group="LTF Colors")
cLtfBrkBull = input.color(color.new(#00bcd4, 80), "LTF Bull BRK", group="LTF Colors")
cLtfBrkBear = input.color(color.new(#ff9800, 80), "LTF Bear BRK", group="LTF Colors")

// ─────────────────────────────────────────────
// INPUTS — COLORS HTF
// ─────────────────────────────────────────────
cHtfObBull  = input.color(color.new(#00e676, 88), "HTF Bull OB",  group="HTF Colors")
cHtfObBear  = input.color(color.new(#ef5350, 88), "HTF Bear OB",  group="HTF Colors")
cHtfBrkBull = input.color(color.new(#00bcd4, 88), "HTF Bull BRK", group="HTF Colors")
cHtfBrkBear = input.color(color.new(#ff9800, 88), "HTF Bear BRK", group="HTF Colors")

// ─────────────────────────────────────────────
// HEIKIN-ASHI — LTF
// ─────────────────────────────────────────────
haClose = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close)
haOpen  = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open)
haHigh  = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high)
haLow   = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low)

// ─────────────────────────────────────────────
// HEIKIN-ASHI — HTF
// ─────────────────────────────────────────────
htfHaClose = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, close, lookahead=barmerge.lookahead_off)
htfHaOpen  = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, open,  lookahead=barmerge.lookahead_off)
htfHaHigh  = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, high,  lookahead=barmerge.lookahead_off)
htfHaLow   = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, low,   lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// ══════════════════════════════════════════════
//  LTF BLOCK
// ══════════════════════════════════════════════
// ─────────────────────────────────────────────

// Swings
ltfSwHigh = ta.pivothigh(haHigh, ltfSwingLen, ltfSwingLen)
ltfSwLow  = ta.pivotlow(haLow,  ltfSwingLen, ltfSwingLen)

var float ltfLastSH = na
var float ltfLastSL = na
if not na(ltfSwHigh)
    ltfLastSH := ltfSwHigh
if not na(ltfSwLow)
    ltfLastSL := ltfSwLow

// Sweep
ltfSweepBull = not na(ltfLastSL) and haLow  < ltfLastSL and haClose > ltfLastSL
ltfSweepBear = not na(ltfLastSH) and haHigh > ltfLastSH and haClose < ltfLastSH

// CHoC state machine
var bool  ltfPBull = false
var bool  ltfPBear = false
var float ltfCBull = na
var float ltfCBear = na

if ltfSweepBull and not ltfPBull
    ltfPBull := true
    ltfCBull := ltfLastSH
if ltfSweepBear and not ltfPBear
    ltfPBear := true
    ltfCBear := ltfLastSL

if ltfPBull and not na(ltfLastSL) and haClose < ltfLastSL
    ltfPBull := false
if ltfPBear and not na(ltfLastSH) and haClose > ltfLastSH
    ltfPBear := false

ltfChocBull = ltfPBull and not na(ltfCBull) and haClose > ltfCBull
ltfChocBear = ltfPBear and not na(ltfCBear) and haClose < ltfCBear

if ltfChocBull
    ltfPBull := false
if ltfChocBear
    ltfPBear := false

// OB search — unconditional (CW10003 fix)
ltfSafe = math.min(ltfSearchLen, bar_index)

ltfObBearOff = 0
for i = 1 to ltfSafe
    if haClose[i] < haOpen[i]
        ltfObBearOff := i
        break

ltfObBullOff = 0
for i = 1 to ltfSafe
    if haClose[i] > haOpen[i]
        ltfObBullOff := i
        break

// LTF zones
var float ltfObBullTop  = na
var float ltfObBullBot  = na
var bool  ltfObBullOn   = false
var float ltfObBearTop  = na
var float ltfObBearBot  = na
var bool  ltfObBearOn   = false
var float ltfBrkBullTop = na
var float ltfBrkBullBot = na
var bool  ltfBrkBullOn  = false
var float ltfBrkBearTop = na
var float ltfBrkBearBot = na
var bool  ltfBrkBearOn  = false

var box ltfBxObBull  = na
var box ltfBxObBear  = na
var box ltfBxBrkBull = na
var box ltfBxBrkBear = na

// Create LTF OB on CHoC
if ltfChocBull and ltfObBearOff > 0
    ltfObBullTop := haHigh[ltfObBearOff]
    ltfObBullBot := haLow[ltfObBearOff]
    ltfObBullOn  := true
    if showLTF
        if not na(ltfBxObBull)
            box.delete(ltfBxObBull)
        ltfBxObBull := box.new(bar_index - ltfObBearOff, ltfObBullTop, bar_index + 1, ltfObBullBot, border_color=color.new(#00e676, 0), border_width=1, bgcolor=cLtfObBull)

if ltfChocBear and ltfObBullOff > 0
    ltfObBearTop := haHigh[ltfObBullOff]
    ltfObBearBot := haLow[ltfObBullOff]
    ltfObBearOn  := true
    if showLTF
        if not na(ltfBxObBear)
            box.delete(ltfBxObBear)
        ltfBxObBear := box.new(bar_index - ltfObBullOff, ltfObBearTop, bar_index + 1, ltfObBearBot, border_color=color.new(#ef5350, 0), border_width=1, bgcolor=cLtfObBear)

// Extend LTF boxes
if ltfObBullOn  and showLTF and not na(ltfBxObBull)
    box.set_right(ltfBxObBull,  bar_index + 1)
if ltfObBearOn  and showLTF and not na(ltfBxObBear)
    box.set_right(ltfBxObBear,  bar_index + 1)
if ltfBrkBullOn and showLTF and not na(ltfBxBrkBull)
    box.set_right(ltfBxBrkBull, bar_index + 1)
if ltfBrkBearOn and showLTF and not na(ltfBxBrkBear)
    box.set_right(ltfBxBrkBear, bar_index + 1)

// LTF OB liquidated → Breaker
if ltfObBullOn and close < ltfObBullBot
    ltfObBullOn   := false
    ltfBrkBearTop := ltfObBullTop
    ltfBrkBearBot := ltfObBullBot
    ltfBrkBearOn  := true
    if showLTF
        if not na(ltfBxBrkBear)
            box.delete(ltfBxBrkBear)
        ltfBxBrkBear := box.new(bar_index, ltfBrkBearTop, bar_index + 1, ltfBrkBearBot, border_color=color.new(#ff9800, 0), border_width=1, border_style=line.style_dashed, bgcolor=cLtfBrkBear)

if ltfObBearOn and close > ltfObBearTop
    ltfObBearOn   := false
    ltfBrkBullTop := ltfObBearTop
    ltfBrkBullBot := ltfObBearBot
    ltfBrkBullOn  := true
    if showLTF
        if not na(ltfBxBrkBull)
            box.delete(ltfBxBrkBull)
        ltfBxBrkBull := box.new(bar_index, ltfBrkBullTop, bar_index + 1, ltfBrkBullBot, border_color=color.new(#00bcd4, 0), border_width=1, border_style=line.style_dashed, bgcolor=cLtfBrkBull)

if ltfBrkBullOn and close < ltfBrkBullBot
    ltfBrkBullOn := false
if ltfBrkBearOn and close > ltfBrkBearTop
    ltfBrkBearOn := false

// ─────────────────────────────────────────────
// ══════════════════════════════════════════════
//  HTF BLOCK
// ══════════════════════════════════════════════
// ─────────────────────────────────────────────

// Swings HTF
htfSwHigh = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, ta.pivothigh(high, htfSwingLen, htfSwingLen), lookahead=barmerge.lookahead_off)
htfSwLow  = request.security(ticker.heikinashi(syminfo.tickerid), htfTF, ta.pivotlow(low,  htfSwingLen, htfSwingLen), lookahead=barmerge.lookahead_off)

var float htfLastSH = na
var float htfLastSL = na
if not na(htfSwHigh)
    htfLastSH := htfSwHigh
if not na(htfSwLow)
    htfLastSL := htfSwLow

// Sweep HTF
htfSweepBull = not na(htfLastSL) and htfHaLow  < htfLastSL and htfHaClose > htfLastSL
htfSweepBear = not na(htfLastSH) and htfHaHigh > htfLastSH and htfHaClose < htfLastSH

// CHoC HTF state machine
var bool  htfPBull = false
var bool  htfPBear = false
var float htfCBull = na
var float htfCBear = na

if htfSweepBull and not htfPBull
    htfPBull := true
    htfCBull := htfLastSH
if htfSweepBear and not htfPBear
    htfPBear := true
    htfCBear := htfLastSL

if htfPBull and not na(htfLastSL) and htfHaClose < htfLastSL
    htfPBull := false
if htfPBear and not na(htfLastSH) and htfHaClose > htfLastSH
    htfPBear := false

htfChocBull = htfPBull and not na(htfCBull) and htfHaClose > htfCBull
htfChocBear = htfPBear and not na(htfCBear) and htfHaClose < htfCBear

if htfChocBull
    htfPBull := false
if htfChocBear
    htfPBear := false

// HTF direction (updated on each CHoC)
var bool htfBullish = false
var bool htfBearish = false
if htfChocBull
    htfBullish := true
    htfBearish := false
if htfChocBear
    htfBullish := false
    htfBearish := true

// OB search HTF — unconditional
htfSafe = math.min(htfSearchLen, bar_index)

htfObBearOff = 0
for i = 1 to htfSafe
    if htfHaClose[i] < htfHaOpen[i]
        htfObBearOff := i
        break

htfObBullOff = 0
for i = 1 to htfSafe
    if htfHaClose[i] > htfHaOpen[i]
        htfObBullOff := i
        break

// HTF zones
var float htfObBullTop  = na
var float htfObBullBot  = na
var bool  htfObBullOn   = false
var float htfObBearTop  = na
var float htfObBearBot  = na
var bool  htfObBearOn   = false
var float htfBrkBullTop = na
var float htfBrkBullBot = na
var bool  htfBrkBullOn  = false
var float htfBrkBearTop = na
var float htfBrkBearBot = na
var bool  htfBrkBearOn  = false

var box htfBxObBull  = na
var box htfBxObBear  = na
var box htfBxBrkBull = na
var box htfBxBrkBear = na

// Create HTF OB on CHoC
if htfChocBull and htfObBearOff > 0
    htfObBullTop := htfHaHigh[htfObBearOff]
    htfObBullBot := htfHaLow[htfObBearOff]
    htfObBullOn  := true
    if showHTF
        if not na(htfBxObBull)
            box.delete(htfBxObBull)
        htfBxObBull := box.new(bar_index - htfObBearOff, htfObBullTop, bar_index + 1, htfObBullBot, border_color=color.new(#00e676, 0), border_width=2, bgcolor=cHtfObBull, text=" HTF OB ▲", text_color=color.new(#00e676, 20), text_size=size.small, text_halign=text.align_left)

if htfChocBear and htfObBullOff > 0
    htfObBearTop := htfHaHigh[htfObBullOff]
    htfObBearBot := htfHaLow[htfObBullOff]
    htfObBearOn  := true
    if showHTF
        if not na(htfBxObBear)
            box.delete(htfBxObBear)
        htfBxObBear := box.new(bar_index - htfObBullOff, htfObBearTop, bar_index + 1, htfObBearBot, border_color=color.new(#ef5350, 0), border_width=2, bgcolor=cHtfObBear, text=" HTF OB ▼", text_color=color.new(#ef5350, 20), text_size=size.small, text_halign=text.align_left)

// Extend HTF boxes
if htfObBullOn  and showHTF and not na(htfBxObBull)
    box.set_right(htfBxObBull,  bar_index + 1)
if htfObBearOn  and showHTF and not na(htfBxObBear)
    box.set_right(htfBxObBear,  bar_index + 1)
if htfBrkBullOn and showHTF and not na(htfBxBrkBull)
    box.set_right(htfBxBrkBull, bar_index + 1)
if htfBrkBearOn and showHTF and not na(htfBxBrkBear)
    box.set_right(htfBxBrkBear, bar_index + 1)

// HTF OB liquidated → Breaker
if htfObBullOn and close < htfObBullBot
    htfObBullOn   := false
    htfBrkBearTop := htfObBullTop
    htfBrkBearBot := htfObBullBot
    htfBrkBearOn  := true
    if showHTF
        if not na(htfBxBrkBear)
            box.delete(htfBxBrkBear)
        htfBxBrkBear := box.new(bar_index, htfBrkBearTop, bar_index + 1, htfBrkBearBot, border_color=color.new(#ff9800, 0), border_width=2, border_style=line.style_dashed, bgcolor=cHtfBrkBear, text=" HTF BRK ▼", text_color=color.new(#ff9800, 20), text_size=size.small, text_halign=text.align_left)

if htfObBearOn and close > htfObBearTop
    htfObBearOn   := false
    htfBrkBullTop := htfObBearTop
    htfBrkBullBot := htfObBearBot
    htfBrkBullOn  := true
    if showHTF
        if not na(htfBxBrkBull)
            box.delete(htfBxBrkBull)
        htfBxBrkBull := box.new(bar_index, htfBrkBullTop, bar_index + 1, htfBrkBullBot, border_color=color.new(#00bcd4, 0), border_width=2, border_style=line.style_dashed, bgcolor=cHtfBrkBull, text=" HTF BRK ▲", text_color=color.new(#00bcd4, 20), text_size=size.small, text_halign=text.align_left)

if htfBrkBullOn and close < htfBrkBullBot
    htfBrkBullOn := false
if htfBrkBearOn and close > htfBrkBearTop
    htfBrkBearOn := false

// ─────────────────────────────────────────────
// CONFLUENCE
// ─────────────────────────────────────────────
inHtfBullZone = (htfObBullOn and low <= htfObBullTop and low >= htfObBullBot) or (htfBrkBullOn and low <= htfBrkBullTop and low >= htfBrkBullBot)
inHtfBearZone = (htfObBearOn and high >= htfObBearBot and high <= htfObBearTop) or (htfBrkBearOn and high >= htfBrkBearBot and high <= htfBrkBearTop)

confluenceLong  = htfBullish and inHtfBullZone
confluenceShort = htfBearish and inHtfBearZone

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
plotshape(ltfSweepBull, style=shape.triangleup,   location=location.belowbar, color=color.new(#00e676, 40), size=size.tiny, title="LTF Sweep Bull")
plotshape(ltfSweepBear, style=shape.triangledown, location=location.abovebar, color=color.new(#ef5350, 40), size=size.tiny, title="LTF Sweep Bear")
plotshape(ltfChocBull,  style=shape.labelup,      location=location.belowbar, color=color.new(#00e676, 0),  size=size.tiny, text="CHoC", textcolor=color.white, title="LTF CHoC Bull")
plotshape(ltfChocBear,  style=shape.labeldown,    location=location.abovebar, color=color.new(#ef5350, 0),  size=size.tiny, text="CHoC", textcolor=color.white, title="LTF CHoC Bear")

// Bar highlight when full confluence is active
bgcolor(confluenceLong  ? color.new(#00e676, 92) : na, title="Confluence Long BG")
bgcolor(confluenceShort ? color.new(#ef5350, 92) : na, title="Confluence Short BG")

// HTF direction label (top right, real-time)
var label htfLabel = na
if barstate.islast
    if not na(htfLabel)
        label.delete(htfLabel)
    lTxt = htfBullish ? "HTF ▲ Bullish" : htfBearish ? "HTF ▼ Bearish" : "HTF — Neutral"
    lCol = htfBullish ? color.new(#00e676, 0) : htfBearish ? color.new(#ef5350, 0) : color.gray
    htfLabel := label.new(bar_index + 2, high, lTxt, color=color.new(lCol, 75), textcolor=lCol, style=label.style_label_left, size=size.normal)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(ltfChocBull,    title="LTF Bullish CHoC",    message="Sweep OB MTF — LTF Bullish CHoC detected")
alertcondition(ltfChocBear,    title="LTF Bearish CHoC",    message="Sweep OB MTF — LTF Bearish CHoC detected")
alertcondition(confluenceLong,  title="Long Confluence",     message="Sweep OB MTF — LONG confluence: HTF Bullish + HTF zone + LTF aligned")
alertcondition(confluenceShort, title="Short Confluence",    message="Sweep OB MTF — SHORT confluence: HTF Bearish + HTF zone + LTF aligned")
````
