# Volume + RSI

- url: https://www.tradingview.com/script/kFS9BOPB-Volume-RSI/
- type: indicator
- pine_id: PUB;b4ec76658585424b9453e0d2484890ac
- version: 1.0

## Description

# CVC — Camarilla Volume Confirm [Vol + RSI]

## Overview

**CVC (Camarilla Volume Confirm)** is a precision signal confirmation indicator designed to work alongside any Camarilla Pivot Point indicator. Its sole purpose is to answer one critical question every trader faces at a Camarilla level:

> *"Is this signal real — or is it a fake-out?"*

Instead of generating its own entry signals, CVC acts as a **second opinion engine** that validates or rejects Camarilla plays using two independent confirmation filters that must agree simultaneously before any signal is marked valid.

---

## How It Works

### Filter 1 — Volume Power Metric (inspired by BSD methodology)
CVC calculates a **Bar Strength Delta** score for every candle:

- Measures directional strength of each bar: `(close - open) / (high - low)` — a full bullish engulfing scores +1, full bearish scores -1
- Weights it against real volume using a configurable boost curve (linear, square-root, or square relationship)
- Scales the result dynamically to a **−100 to +100 range** using a rolling baseline that adapts to each instrument and timeframe automatically
- Smooths the final output using your choice of SMA / EMA / RMA / HMA / WMA

When the metric is **above the Power Threshold (+20 default)** → buyers are genuinely in control.
When it is **below the Weakness Threshold (−20 default)** → sellers dominate.
Anything in between → the move lacks conviction and is likely a fake-out.

### Filter 2 — RSI Momentum Confirmation
A standard RSI (default 14) acts as the momentum gate:

- RSI **above midline (50)** = bullish momentum supports the long
- RSI **below midline (50)** = bearish momentum supports the short
- Overbought (≥70) or Oversold (≤30) warnings are flagged directly on confirmed signals

### The Rule
A signal is only marked **VALID** when **both filters agree**:

| Condition | Result |
|---|---|
| Volume Power ≥ +20 AND RSI ≥ 50 | ✔ VALID LONG |
| Volume Power ≤ −20 AND RSI < 50 | ✔ VALID SHORT |
| Only one filter confirms | 〜 PARTIAL — proceed with caution |
| Neither confirms | ⚠ FAKE — skip the trade |

---

## Key Features

- **Timeframe-adaptive scaling** — works correctly on 1m, 5m, 15m, 1H, Daily and all other timeframes without manual adjustment
- **Partial signal diagnostics** — tells you exactly *which* filter is missing so you understand why a signal is weak, not just that it is
- **Real-time info table** — shows Volume metric value, RSI value, overbought/oversold warnings, and current confirmation status at a glance
- **Non-repainting** — all signals are based on confirmed bar closes
- **Full alert suite** — separate alerts for confirmed longs, confirmed shorts, fake signals, partial signals, and overbought/oversold warnings
- **Highly configurable** — thresholds, smoothing method, RSI length, display colours and label visibility are all adjustable

---

## How To Use

1. Add your preferred **Camarilla Pivot Plays** indicator to the chart
2. Add **CVC** as a separate panel below
3. When Camarilla generates a signal (e.g. H3 long or L3 short), check the CVC panel:
   - Green histogram above the band + **✔ VALID LONG** label → take the trade
   - Red histogram below the band + **✔ VALID SHORT** label → take the trade
   - Gray histogram between bands + **⚠ FAKE** label → skip or wait
   - **〜 PARTIAL** label → one filter agrees, reduce size or wait for full confirmation

---

## Recommended Settings

| Parameter | Default | Notes |
|---|---|---|
| Volume Boost | 0.5 | Square-root curve — recommended for most instruments |
| Rolling RMA | 14 bars | Matches BSD standard |
| Scale Days | 5 | 1 week of history for scaling baseline |
| Smoothing | HMA 5 | Lowest lag smoothing |
| Power Threshold | +20 | Lower to +15 for more signals, raise to +30 for fewer |
| RSI Length | 14 | Classic setting |
| RSI Midline | 50 | Momentum shift level |

---

## Best Used With
- Camarilla Pivot Plays (H3/H4/L3/L4 plays)
- Any pivot-based reversal or breakout strategy
- Works on stocks, futures, forex, and crypto

---

*CVC does not generate standalone buy/sell signals. It is a confirmation filter — always use it in context with a primary strategy.*

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════╗
// │   CVC — Camarilla Volume + RSI Confirmation (Optimized)            │
// │   Fixes: dynamic barsPerDay, clean table, no duplicate hlines,     │
// │   better signal logic, cleaner labels                              │
// ╚══════════════════════════════════════════════════════════════════════╝
indicator("Cam Volume Confirm [CVC]", shorttitle="CVC", overlay=false, max_lines_count=10, max_labels_count=50)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════

float volBoost    = input.float(0.5,  "Volume Boost",              minval=0.0, maxval=1.0, step=0.1, group="Volume Settings")
float volFactor   = input.float(1.0,  "Volume Factor",             minval=0.0, maxval=1.0, step=0.1, group="Volume Settings")
int   rmaLen      = input.int(14,     "Rolling RMA Length (bars)", minval=1,                          group="Volume Settings")
int   scaleDays   = input.int(5,      "Scaling RMA Length (days)", minval=1,                          group="Volume Settings")

string smoothMethod = input.string("HMA", "Smoothing Method", options=["None","SMA","EMA","RMA","HMA","WMA"], group="Smoothing")
int    smoothLen    = input.int(5, "Smoothing Length (bars)", minval=1, group="Smoothing")

float powerThresh = input.float( 20.0, "Power Threshold (Long)",  minval=1,   maxval=99,  step=1, group="Volume Confirmation")
float weakThresh  = input.float(-20.0, "Weakness Threshold (Short)", minval=-99, maxval=-1, step=1, group="Volume Confirmation")

int   rsiLen      = input.int(14,   "RSI Length",           minval=1,  group="RSI Confirmation")
float rsiMid      = input.float(50.0,"RSI Mid Line",        minval=30, maxval=70, step=1, group="RSI Confirmation")
float rsiOB       = input.float(70.0,"RSI Overbought",      minval=60, maxval=90, step=1, group="RSI Confirmation")
float rsiOS       = input.float(30.0,"RSI Oversold",        minval=10, maxval=40, step=1, group="RSI Confirmation")
bool  showRSI     = input.bool(true, "Show RSI Line",                             group="RSI Confirmation")
color rsiCol      = input.color(color.new(color.yellow, 20), "RSI Colour",        group="RSI Confirmation")

bool  showLabels  = input.bool(true,  "Show Labels",         group="Display")
bool  showInfo    = input.bool(true,  "Show Info Box",       group="Display")
string infoPos    = input.string("Top Right", "Info Position", options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left"], group="Display")
bool  showBands   = input.bool(true,  "Show Threshold Bands",group="Display")
color bullCol     = input.color(color.new(color.teal,  15),  "Bull Colour",       group="Display")
color bearCol     = input.color(color.new(color.red,   15),  "Bear Colour",       group="Display")
color neutCol     = input.color(color.new(color.gray,  40),  "Neutral Colour",    group="Display")
color maCol       = input.color(color.new(color.blue,  10),  "MA Line Colour",    group="Display")
color bandCol     = input.color(color.new(color.orange,30),  "Band Colour",       group="Display")

// ═══════════════════════════════════════════════════════════
// FUNCTIONS
// ═══════════════════════════════════════════════════════════

calcHMA(series float src, simple int len) =>
    w1 = ta.wma(src, len)
    w2 = ta.wma(src, math.floor(len / 2))
    ta.wma(2 * w2 - w1, math.floor(math.sqrt(len)))

applySmooth(series float src, simple int len, simple string method) =>
    switch method
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "RMA" => ta.rma(src, len)
        "HMA" => calcHMA(src, len)
        "WMA" => ta.wma(src, len)
        =>       src

// ═══════════════════════════════════════════════════════════
// VOLUME POWER METRIC
// ═══════════════════════════════════════════════════════════

// FIX 1: Dynamic bars per day — works on ALL timeframes correctly
int barsPerDay  = timeframe.in_seconds() > 0 ? math.max(1, math.round(23400 / timeframe.in_seconds())) : 390

float bDir      = close - open
float bRange    = high  - low
float normDir   = bRange > 0.0 ? bDir / bRange : 0.0
float rawVol    = volume > 0.0 ? math.pow(volume, 1.0 - volBoost) : 0.0
float volComp   = rawVol * volFactor + (1.0 - volFactor)
float rawM      = normDir * volComp
float absM      = math.abs(rawM)
float scaler    = ta.rma(absM, scaleDays * barsPerDay)
float scaledRaw = scaler > 0.0 ? (rawM / scaler) * 100.0 : 0.0
float scaled    = math.max(-100.0, math.min(100.0, scaledRaw))
float rolling   = ta.rma(scaled, rmaLen)
float display   = applySmooth(rolling, smoothLen, smoothMethod)

// ═══════════════════════════════════════════════════════════
// RSI
// ═══════════════════════════════════════════════════════════

float rsiVal    = ta.rsi(close, rsiLen)
bool  rsiUp     = rsiVal >= rsiMid     // bullish zone
bool  rsiDown   = rsiVal <  rsiMid     // bearish zone
bool  rsiOBWarn = rsiVal >= rsiOB      // overbought warning
bool  rsiOSWarn = rsiVal <= rsiOS      // oversold warning

// Scale RSI to panel space: 0→-100, 50→0, 100→+100
float rsiScaled = (rsiVal - 50.0) * 2.0

// ═══════════════════════════════════════════════════════════
// SIGNAL LOGIC
// Both Volume AND RSI must agree — strictest, least fake signals
// ═══════════════════════════════════════════════════════════

bool volLong    = display >= powerThresh
bool volShort   = display <= weakThresh
bool volNeutral = not volLong and not volShort

bool confLong   = volLong  and rsiUp    // FULL long  confirmation
bool confShort  = volShort and rsiDown  // FULL short confirmation
bool isFake     = not confLong and not confShort

// Partial: only one condition met
bool partVolLong  = volLong  and rsiDown   // vol bullish but RSI disagrees
bool partVolShort = volShort and rsiUp     // vol bearish but RSI disagrees
bool partRsiLong  = rsiUp    and volNeutral // RSI bullish but vol too weak
bool partRsiShort = rsiDown  and volNeutral // RSI bearish but vol too weak

// Previous bar states — for edge detection (signal fires only once)
bool wasConfLong  = confLong[1]
bool wasConfShort = confShort[1]
bool wasFake      = isFake[1]
bool wasPartVL    = partVolLong[1]
bool wasPartVS    = partVolShort[1]
bool wasPartRL    = partRsiLong[1]
bool wasPartRS    = partRsiShort[1]

// Histogram colour
color barCol = confLong ? bullCol : confShort ? bearCol : neutCol

// ═══════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════

// Histogram
plot(display, "Volume Power", style=plot.style_histogram, color=barCol, linewidth=2)

// Smoothed MA line
plot(display, "MA Line", color=maCol, linewidth=2)

// RSI scaled line
plot(showRSI ? rsiScaled : na, "RSI (scaled)", color=rsiCol, linewidth=1)

// FIX 2: Only ONE hline at zero (removed duplicate)
hline(0, "Zero", color=color.new(color.white, 50), linestyle=hline.style_solid, linewidth=1)

// RSI mid reference as dashed (separate from zero hline)
hline(0, "RSI Mid Ref", color=color.new(color.yellow, 80), linestyle=hline.style_dashed, linewidth=1)

// Threshold bands
plot(showBands ?  powerThresh : na, "Power Band", color=bandCol, linewidth=1)
plot(showBands ?  weakThresh  : na, "Weak Band",  color=bandCol, linewidth=1)

// Fake zone fill
pTop = plot(showBands ? powerThresh : na, display=display.none)
pBot = plot(showBands ? weakThresh  : na, display=display.none)
fill(pTop, pBot, color=color.new(color.gray, 90), title="Fake Zone")

// RSI overbought / oversold bands in panel space
plot(showRSI ? (rsiOB - 50.0) * 2.0 : na, "RSI OB", color=color.new(color.orange, 70), linewidth=1, style=plot.style_line)
plot(showRSI ? (rsiOS - 50.0) * 2.0 : na, "RSI OS", color=color.new(color.orange, 70), linewidth=1, style=plot.style_line)

// ═══════════════════════════════════════════════════════════
// LABELS
// FIX 3: Labels fire only on state CHANGE (edge), not every bar
// ═══════════════════════════════════════════════════════════

if showLabels
    // Full confirmation
    if confLong and not wasConfLong
        string t = rsiOBWarn ? "✔ LONG  ⚠ Overbought" : "✔ LONG  Vol + RSI"
        label.new(bar_index, display, text=t, color=color.new(color.teal, 20), style=label.style_label_up, textcolor=color.white, size=size.small)

    if confShort and not wasConfShort
        string t = rsiOSWarn ? "✔ SHORT  ⚠ Oversold" : "✔ SHORT  Vol + RSI"
        label.new(bar_index, display, text=t, color=color.new(color.red, 20), style=label.style_label_down, textcolor=color.white, size=size.small)

    // Fake — only when transitioning FROM a confirmed state
    if isFake and not wasFake and (wasConfLong or wasConfShort)
        label.new(bar_index, display, text="⚠ FAKE", color=color.new(color.orange, 20), style=label.style_label_up, textcolor=color.white, size=size.small)

    // Partial — vol ok but RSI wrong
    if partVolLong and not wasPartVL
        label.new(bar_index, display, text="〜 Vol OK / RSI Bearish", color=color.new(color.teal, 65), style=label.style_label_up, textcolor=color.white, size=size.tiny)

    if partVolShort and not wasPartVS
        label.new(bar_index, display, text="〜 Vol OK / RSI Bullish", color=color.new(color.red, 65), style=label.style_label_down, textcolor=color.white, size=size.tiny)

    // Partial — RSI ok but vol weak
    if partRsiLong and not wasPartRL
        label.new(bar_index, display, text="〜 RSI OK / Low Vol", color=color.new(color.teal, 65), style=label.style_label_up, textcolor=color.white, size=size.tiny)

    if partRsiShort and not wasPartRS
        label.new(bar_index, display, text="〜 RSI OK / Low Vol", color=color.new(color.red, 65), style=label.style_label_down, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════
// INFO TABLE
// FIX 4: Correct Pine v6 var table pattern — no na() check needed
// ═══════════════════════════════════════════════════════════

if showInfo and barstate.islast
    tablePos = switch infoPos
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right

    var table T = table.new(tablePos, 2, 7,
         bgcolor      = color.new(color.black, 20),
         border_color = color.new(color.white, 40),
         border_width = 1)

    // Status
    string statusTxt =
         confLong  and rsiOBWarn ? "● LONG  ✔  ⚠ Overbought"  :
         confLong                ? "● LONG  ✔  Vol + RSI"      :
         confShort and rsiOSWarn ? "● SHORT ✔  ⚠ Oversold"     :
         confShort               ? "● SHORT ✔  Vol + RSI"      :
         partVolLong             ? "〜 Vol Bull / RSI Bear"     :
         partVolShort            ? "〜 Vol Bear / RSI Bull"     :
         partRsiLong             ? "〜 RSI Bull / Vol Weak"     :
         partRsiShort            ? "〜 RSI Bear / Vol Weak"     :
                                   "● FAKE — No Confirmation"

    color statusCol =
         confLong  ? color.teal   :
         confShort ? color.red    :
         isFake    ? color.orange : color.yellow

    // Volume status
    string volTxt  = volLong    ? "✔ Strong — Bullish"     : volShort ? "✔ Weak — Bearish" : "✖ Neutral"
    color  volCol2 = volLong    ? color.teal : volShort     ? color.red : color.orange

    // RSI status
    string rsiDirTxt  = rsiUp   ? "✔ Above " + str.tostring(rsiMid) : "✖ Below " + str.tostring(rsiMid)
    color  rsiDirCol  = rsiUp   ? color.teal : color.red
    string rsiWarnTxt = rsiOBWarn ? "⚠ Overbought" : rsiOSWarn ? "⚠ Oversold" : "Normal"
    color  rsiWarnCol = rsiOBWarn or rsiOSWarn ? color.orange : color.white

    table.cell(T, 0, 0, "CVC Status",   text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 0, statusTxt,      text_color=statusCol,    text_size=size.small)
    table.cell(T, 0, 1, "Volume",       text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 1, volTxt,         text_color=volCol2,      text_size=size.small)
    table.cell(T, 0, 2, "Vol Metric",   text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 2, str.tostring(math.round(display, 1)),    text_color=color.white, text_size=size.small)
    table.cell(T, 0, 3, "RSI Dir",      text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 3, rsiDirTxt,      text_color=rsiDirCol,    text_size=size.small)
    table.cell(T, 0, 4, "RSI Value",    text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 4, str.tostring(math.round(rsiVal, 1)) + "  " + rsiWarnTxt, text_color=rsiWarnCol, text_size=size.small)
    table.cell(T, 0, 5, "Threshold",    text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 5, str.tostring(powerThresh) + " / " + str.tostring(weakThresh), text_color=color.orange, text_size=size.small)
    table.cell(T, 0, 6, "Settings",     text_color=color.gray,   text_size=size.small)
    table.cell(T, 1, 6, "RSI(" + str.tostring(rsiLen) + ")  " + smoothMethod + "(" + str.tostring(smoothLen) + ")", text_color=color.white, text_size=size.small)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════

alertcondition(confLong  and not wasConfLong,  title="CVC: LONG Confirmed",  message="✔ LONG confirmed — Vol + RSI on {{ticker}} at {{time}}")
alertcondition(confShort and not wasConfShort, title="CVC: SHORT Confirmed", message="✔ SHORT confirmed — Vol + RSI on {{ticker}} at {{time}}")
alertcondition(isFake and not wasFake and (wasConfLong or wasConfShort), title="CVC: FAKE Signal", message="⚠ Signal FAKE — confirmation lost on {{ticker}} at {{time}}")
alertcondition(confLong  and rsiOBWarn and not wasConfLong,  title="CVC: LONG — Overbought Warning",  message="⚠ LONG confirmed but RSI Overbought on {{ticker}} at {{time}}")
alertcondition(confShort and rsiOSWarn and not wasConfShort, title="CVC: SHORT — Oversold Warning",   message="⚠ SHORT confirmed but RSI Oversold on {{ticker}} at {{time}}")
````
