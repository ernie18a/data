<!-- tradingview-pine-id: PUB;aecd7075290f4d89aa21ffd44ecf1779 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NASH BBv2: TRADE BY HAND FOR NOW

Source: https://www.tradingview.com/script/NYQxgLrO-NASH-BBv2-TRADE-BY-HAND-FOR-NOW/

## Description

### Overview

**NASH BBv2** is an all-in-one intraday market structure and trend-analysis script designed for futures and equity traders. It combines three distinct institutional concepts into a single chart overlay:

1. **Higher Timeframe Trend Anchoring:** A customizable HTF EMA filter (default: 15-minute 21 EMA) to keep trades aligned with the dominant trend.
2. **Session Open Basis Hierarchy:** Time-anchored opening price levels (Globex, Midnight, and NY Equities Open in Central Time) to score directional bias based on structural alignment.
3. **Automated Fair Value Gap (FVG) Engine:** Real-time 15-minute imbalance detection, complete with 50% equilibrium midlines and real-time mitigation tracking.

---

### Core Components & Mechanics

#### 1. HTF Trend Anchor (15m 21 EMA)

* **Calculation:** Fetches the 21-period Exponential Moving Average from a higher timeframe (default: 15m) using non-repainting `request.security` calls.
* **Trend Filtering:** Flags the market as bullish when price trades above the anchor line, and bearish when below.
* **Visuals:** Features an optional background shading gradient and serves as an execution filter for breakout signals.

#### 2. Session Open Basis Hierarchy (Chicago / CT Timezone)

Anchoring price relative to major institutional shift points provides crucial context for daily expansion:

* **5:00 PM CT (Globex Open):** Establishes the initial baseline for the trading day.
* **11:00 PM CT (MNO / Midnight Open):** Captures the European/London liquidity anchor.
* **8:30 AM CT (NY Open):** Marks the New York Cash Equities opening bell.

**Directional Scoring System:**
At 8:30 AM CT, the script automatically evaluates the spatial hierarchy of these three open levels:

* **Bulls Strong (`Score = +2`):** `5:00 PM Open < 11:00 PM Open < 8:30 AM Open` (Higher highs across session opens).
* **Bears Strong (`Score = -2`):** `5:00 PM Open > 11:00 PM Open > 8:30 AM Open` (Lower lows across session opens).
* **Mixed / No Edge (`Score = 0`):** Opens are out of sequence, signaling choppy or non-trending structural conditions.

#### 3. Intraday Breakout Signals

* **Logic:** Detects when intraday price pierces or closes beyond any of the three anchored open levels (5pm, 11pm, 8:30am CT).
* **Detection Modes:**
* `Wick/Touch`: Fires immediately when high or low crosses the level intraday.
* `Close`: Requires a full candle close beyond the level for strict confirmation.

* **Filter:** Breakout signals are aligned with the HTF EMA (Longs only above EMA, Shorts only below EMA).

#### 4. 15-Minute Fair Value Gap (FVG) Tracker

* **Imbalance Detection:** Identifies 3-bar price inefficiencies on the 15-minute timeframe (`High[2] < Low[0]` for Bullish FVGs; `Low[2] > High[0]` for Bearish FVGs).
* **Mitigation Tracking:** Dynamically extends FVG boxes and draws a 50% equilibrium line until price enters the zone. Once mitigated, the box dims to gray and stops extending.

---

### How to Use

1. **Determine Bias:** Check the 8:30 AM CT NY Open label and background tint. Look for **BULLS STRONG** or **BEARS STRONG** readings for high-conviction daily bias.
2. **Confirm Trend:** Ensure price is on the correct side of the HTF 21 EMA line before taking setups.
3. **Identify Key Zones:** Use the 15m FVG boxes and 50% midlines as high-probability entry or target zones during retests.
4. **Execute Breakouts:** Use the signal triangles (green/red) to catch momentum expansion off key session open lines.

---

### Key Inputs & Customization

| Parameter Group | Option | Description |
| --- | --- | --- |
| **EMA Settings** | `EMA Anchor Timeframe` | Timeframe for the higher timeframe EMA anchor (Default: `15`). |
|  | `EMA Period` | Length of the anchor EMA (Default: `21`). |
|  | `Filter Signals via EMA` | Enforces trend direction on breakout signals. |
| **Open Levels** | `Timezone` | Primary timezone for session anchors (Default: `America/Chicago`). |
|  | `Breakout Detection` | Toggle between `Wick/Touch` or `Close` break modes. |
|  | `Show Breakout Signals` | Plot/hide signal triangles on the chart. |
| **FVG Settings** | `FVG Master Timeframe` | Timeframe used for FVG detection (Default: `15`). |
|  | `Bullish / Bearish Color` | Custom opacity and color schemes for gap boxes and midlines. |

---

### Alert Setup

This script includes pre-configured alert conditions for seamless execution monitoring:

* **NY Open Alignment:** Fires when the 8:30 AM CT structural score resolves to Bulls Strong, Bears Strong, or Mixed.
* **Breakout Alerts:** Fires real-time notifications on Long or Short open-level breakouts.

---

*Disclaimer: This indicator is designed solely for technical analysis, educational, and research purposes. It does not constitute financial advice, and past structural setups do not guarantee future market performance.*

---

## Source Code

````pine
//@version=6
indicator("NASH BBv2: TRADE BY HAND FOR NOW", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ==========================================
// HTF 21 EMA Anchor Inputs
// ==========================================
htfSource    = input.timeframe("15", "EMA Anchor Timeframe", group="EMA Settings")
emaPeriod    = input.int(21, "EMA Period", group="EMA Settings")
emaColor     = input.color(color.new(#00ffbb, 100), "Line Color", group="EMA Settings")
showEmaBg    = input.bool(true, "Show EMA Trend Background", group="EMA Settings")
useEmaFilter = input.bool(true, "Filter Signals via EMA", group="EMA Settings")

// ==========================================
// Open Basis Level Inputs
// ==========================================
tz          = input.string("America/Chicago", "Timezone", group="Open Levels")
ltf         = input.timeframe("1", "Lower TF for exact opens (recommended: 1)", group="Open Levels")
showLines   = input.bool(true, "Plot 5pm / 11pm / 8:30am open levels", group="Open Levels")
showLabel   = input.bool(true, "Show label at 8:30am CT (NY Open)", group="Open Levels")
showOpenBg  = input.bool(false, "Background tint after NY Open", group="Open Levels")
showSignals = input.bool(true, "Show Breakout Signals", group="Open Levels")
breakType   = input.string("Wick/Touch", "Breakout Detection", options=["Close", "Wick/Touch"], group="Open Levels", tooltip="Choose 'Close' for strict body closes, or 'Wick/Touch' to catch every intraday high/low pierce.")

// ==========================================
// 15m FVG Inputs
// ==========================================
fvg_tf     = input.timeframe("15", "FVG Master Timeframe", group="FVG Settings")
bull_col   = input.color(color.new(#3cff00, 100), "Bullish FVG Color", group="FVG Settings")
bear_col   = input.color(color.new(#ff1745, 100), "Bearish FVG Color", group="FVG Settings")
mid_col    = input.color(color.new(#f77c18, 5), "50% Midline Color", group="FVG Settings")
max_bars   = input.int(500, "Max Lookback (Bars)", group="FVG Settings")

// Anchor times in CT
G_H = 17, G_M = 0
M_H = 23, M_M = 0
N_H = 8 , N_M = 30

// ==========================================
// HTF 21 EMA Core Logic
// ==========================================
htfEma = request.security(syminfo.tickerid, htfSource, ta.ema(close, emaPeriod), gaps=barmerge.gaps_off)
plot(htfEma, color=emaColor, linewidth=2, title="HTF Anchor EMA")

emaBullish = close > htfEma
emaBearish = close < htfEma

bgcolor(showEmaBg ? (emaBullish ? color.new(#4caf4f, 100) : color.new(#ff5252, 100)) : na, title="EMA Trend BG")

// ==========================================
// Open Basis Core Logic
// ==========================================
var float globexOpen = na
var float mnoOpen    = na
var float nyOpen     = na
var int   score      = na
var bool  nyEvent    = false

arr_t = request.security_lower_tf(syminfo.tickerid, ltf, time)
arr_o = request.security_lower_tf(syminfo.tickerid, ltf, open)

nyEvent := false

if array.size(arr_t) > 0
    for i = 0 to array.size(arr_t) - 1
        t = array.get(arr_t, i)
        o = array.get(arr_o, i)

        hr = hour(t, tz)
        mn = minute(t, tz)

        if (hr == G_H and mn == G_M)
            globexOpen := o
            mnoOpen    := na
            nyOpen     := na
            score      := na

        if (hr == M_H and mn == M_M)
            mnoOpen := o

        if (hr == N_H and mn == N_M)
            nyOpen := o
            if not na(globexOpen) and not na(mnoOpen) and not na(nyOpen)
                s1 = mnoOpen > globexOpen ? 1 : -1
                s2 = nyOpen  > mnoOpen    ? 1 : -1
                score := s1 + s2
            nyEvent := true

bullStrong = (score == 2)
bearStrong = (score == -2)
mixed      = (score == 0 or na(score))

plot(showLines ? globexOpen : na, "5:00pm CT (Globex Open)", style=plot.style_linebr, linewidth=2)
plot(showLines ? mnoOpen    : na, "11:00pm CT (MNO)",        style=plot.style_linebr, linewidth=2)
plot(showLines ? nyOpen     : na, "8:30am CT (NY Open)",     style=plot.style_linebr, linewidth=2)

if showLabel and nyEvent and not na(globexOpen) and not na(mnoOpen) and not na(nyOpen)
    txt = bullStrong ? "NY OPEN: BULLS STRONG\n(5pm < 11pm < 8:30)" : bearStrong ? "NY OPEN: BEARS STRONG\n(5pm > 11pm > 8:30)" : "NY OPEN: MIXED / NO EDGE\n(hierarchy not clean)"
    txt += "\n5pm: " + str.tostring(globexOpen, format.mintick)
    txt += "\n11pm: " + str.tostring(mnoOpen, format.mintick)
    txt += "\n8:30: " + str.tostring(nyOpen, format.mintick)
    label.new(bar_index, nyOpen, txt, style=label.style_label_down, textalign=text.align_left)

var int regime = 0
if nyEvent
    regime := bullStrong ? 1 : bearStrong ? -1 : 0
if not na(globexOpen) and array.size(arr_t) > 0
    if na(score) and na(mnoOpen) and na(nyOpen)
        regime := 0

bgcolor(showOpenBg ? (regime == 1 ? color.new(#4caf4f, 100) : regime == -1 ? color.new(#ff5252, 100) : na) : na, title="Open Basis BG")

// ==========================================
// Immediate Breakout Logic (EMA Filtered)
// ==========================================
emaLongCondition  = useEmaFilter ? emaBullish : true
emaShortCondition = useEmaFilter ? emaBearish : true

f_break_long(lvl) =>
    if na(lvl)
        false
    else
        isCloseBreak = close[1] < lvl and close > lvl
        isWickBreak  = close[1] <= lvl and high > lvl
        breakType == "Close" ? isCloseBreak : isWickBreak

f_break_short(lvl) =>
    if na(lvl)
        false
    else
        isCloseBreak = close[1] > lvl and close < lvl
        isWickBreak  = close[1] >= lvl and low < lvl
        breakType == "Close" ? isCloseBreak : isWickBreak

breakGlobexLong = f_break_long(globexOpen)
breakMnoLong    = f_break_long(mnoOpen)
breakNyLong     = f_break_long(nyOpen)
longSignal      = showSignals and emaLongCondition and (breakGlobexLong or breakMnoLong or breakNyLong)

breakGlobexShort = f_break_short(globexOpen)
breakMnoShort    = f_break_short(mnoOpen)
breakNyShort     = f_break_short(nyOpen)
shortSignal      = showSignals and emaShortCondition and (breakGlobexShort or breakMnoShort or breakNyShort)

plotshape(longSignal,  title="Long Breakout",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.small)
plotshape(shortSignal, title="Short Breakout", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.small)

// ==========================================
// 15m Fair Value Gap Logic (Upgraded to v6)
// ==========================================
[h0, l0, h2, l2, b_idx] = request.security(syminfo.tickerid, fvg_tf, [high[0], low[0], high[2], low[2], bar_index])

bull_fvg = h2 < l0
bear_fvg = l2 > h0

var array<box> boxes      = array.new<box>()
var array<float> tops     = array.new<float>()
var array<float> bots     = array.new<float>()
var array<bool> mitigated = array.new<bool>()

is_new_15m_bar = ta.change(b_idx) != 0

if is_new_15m_bar
    if bull_fvg
        _top = l0
        _bot = h2
        _mid = (_top + _bot) / 2
        b = box.new(bar_index, _top, bar_index + 1, _bot, bgcolor=bull_col, border_color=na)
        line.new(bar_index, _mid, bar_index + 10, _mid, color=mid_col, width=1)
        array.push(boxes, b)
        array.push(tops, _top)
        array.push(bots, _bot)
        array.push(mitigated, false)

    if bear_fvg
        _top = l2
        _bot = h0
        _mid = (_top + _bot) / 2
        b = box.new(bar_index, _top, bar_index + 1, _bot, bgcolor=bear_col, border_color=na)
        line.new(bar_index, _mid, bar_index + 10, _mid, color=mid_col, width=1)
        array.push(boxes, b)
        array.push(tops, _top)
        array.push(bots, _bot)
        array.push(mitigated, false)

if array.size(boxes) > 0
    for i = array.size(boxes) - 1 to 0
        b      = array.get(boxes, i)
        is_mit = array.get(mitigated, i)
        top_v  = array.get(tops, i)
        bot_v  = array.get(bots, i)
        
        if not is_mit
            box.set_right(b, bar_index + 1)
            // Real-time mitigation check
            if high >= bot_v and low <= top_v
                array.set(mitigated, i, true)
                box.set_bgcolor(b, color.new(color.gray, 90)) 

// ==========================================
// Alerts
// ==========================================
alertcondition(nyEvent and bullStrong, "NY Open — Bulls Strong", "Nash 3-Open: Bulls strong at NY Open (CT).")
alertcondition(nyEvent and bearStrong, "NY Open — Bears Strong", "Nash 3-Open: Bears strong at NY Open (CT).")
alertcondition(nyEvent and mixed,      "NY Open — Mixed",        "Nash 3-Open: Mixed / no clean hierarchy at NY Open (CT).")
alertcondition(longSignal,  "Breakout — Long Signal",  "Price broke up through an anchor open level (Long).")
alertcondition(shortSignal, "Breakout — Short Signal", "Price broke down through an anchor open level (Short).")
````
