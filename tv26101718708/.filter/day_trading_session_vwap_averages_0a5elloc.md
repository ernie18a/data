# Day Trading Session VWAP & Averages

- url: https://www.tradingview.com/script/0A5ElLOC-Day-Trading-Session-VWAP-Averages/
- type: indicator
- pine_id: PUB;0d813e2cdd9641ab8d0cd3c964ed39ab
- version: 2.0

## Description

A clean, session‑aware VWAP and Moving Averages indicator designed for intraday traders who want accurate, stable, session‑anchored levels without chart clutter.

This tool tracks RTH VWAP, Overnight VWAP, and VWAP Standard Deviation Bands, resetting cleanly at each session boundary for precise institutional‑style reference levels.

📌 Key Features
[b]Session‑Anchored VWAP[/b]
[list]
[*]VWAP resets at RTH open
[*]VWAP resets again at RTH close
[*]ON session (PM → AH → Globex PM → Globex AM) uses one continuous VWAP
[*]Fully stable — no shifting when inputs change
[/list]
[b]VWAP Standard Deviation Bands[/b]
[list]
[*]Optional ±1σ and ±2σ bands
[*]True variance‑based calculation (not ATR or SMA approximations)
[*]Independent visibility toggles
[*]Cloud shading for fast visual context
[/list]
[b]Moving Averages[/b]
[list]
[*]Up to three customizable MAs
[*]EMA or SMA
[*]Independent visibility, length, and color controls
[*]Clean plot() rendering for perfect price‑scale alignment
[/list]
🎯 Designed For
[list]
[*]Futures and equities intraday traders
[*]RTH vs ON session structure analysis
[*]VWAP‑based mean reversion and volatility expansion setups
[*]Traders who want a lightweight, stable indicator without noise or chart clutter
[/list]
🧠 How It Works
Session logic automatically adapts to equities or futures
VWAP anchor resets at:
[list]
[*]RTH open → start of new day VWAP
[*]RTH close → start of ON VWAP
[/list]
Standard deviation bands are computed from the same anchor for perfect alignment.

## Source Code

````pine
//@version=6
indicator("Day Trading Session VWAP & Averages", overlay = true, max_lines_count = 500, max_labels_count = 500)

//────────────────────────────────────────────────────────────
// User Inputs
//────────────────────────────────────────────────────────────
// VWAP
groupVWAP = "Session VWAP"
useVWAP   = input.bool(true, "Show Session VWAP", group = groupVWAP)

vwapSrcOpt = input.string("HLC3", "VWAP Price Source", options = ["Close", "HLC3", "HL2", "OHLC4", "Open"], group = groupVWAP)

f_vwap_src(opt) =>
    opt == "Close"  ? close : opt == "Open"   ? open  : opt == "HL2"    ? hl2   : opt == "OHLC4"  ? ohlc4 : hlc3

vwapSrc = f_vwap_src(vwapSrcOpt)

vwapColor = input.color(color.new(color.purple, 40), "VWAP Color", group = groupVWAP)

// VWAP Bands
showBand1 = input.bool(true,  "Show ±1σ Bands", group = groupVWAP)
showBand2 = input.bool(false, "Show ±2σ Bands", group = groupVWAP)
bandColor = input.color(color.new(color.purple, 70), "Band Color", group = groupVWAP)

// Moving Averages
groupMA = "Moving Averages"

showMA1 = input.bool(true,  "Show MA 1", group = groupMA)
ma1Type = input.string("EMA", "MA 1 Type", options = ["EMA", "SMA"], group = groupMA)
ma1Len  = input.int(20, "MA 1 Length", minval = 1, group = groupMA)
ma1Col  = input.color(color.new(color.yellow, 40), "MA 1 Color", group = groupMA)

showMA2 = input.bool(false, "Show MA 2", group = groupMA)
ma2Type = input.string("EMA", "MA 2 Type", options = ["EMA", "SMA"], group = groupMA)
ma2Len  = input.int(50, "MA 2 Length", minval = 1, group = groupMA)
ma2Col  = input.color(color.new(color.orange, 40), "MA 2 Color", group = groupMA)

showMA3 = input.bool(false, "Show MA 3", group = groupMA)
ma3Type = input.string("SMA", "MA 3 Type", options = ["EMA", "SMA"], group = groupMA)
ma3Len  = input.int(100, "MA 3 Length", minval = 1, group = groupMA)
ma3Col  = input.color(color.new(color.red, 40), "MA 3 Color", group = groupMA)

//────────────────────────────────────────────────────────────
// Session Logic (Equities vs Futures) — same structure as main script
//────────────────────────────────────────────────────────────
isFutures = syminfo.type == "futures"

bool inRTH      = false
bool inAH       = false
bool inPM       = false
bool inGlobexPM = false
bool inGlobexAM = false
bool inDead     = false

if isFutures
    // Futures RTH: 08:30–14:59 (exchange TZ)
    inRTH := time(timeframe.period, "0830-1459") != 0

    // Globex PM: 15:00–23:59
    inGlobexPM := time(timeframe.period, "1500-2359") != 0

    // Globex AM: 00:00–08:29
    inGlobexAM := time(timeframe.period, "0000-0829") != 0

    // Map to generic AH/PM for combined ON logic if needed later
    inAH := inGlobexPM
    inPM := inGlobexAM

    // Dead zone disabled
    inDead := false
else
    // Equities RTH: 09:30–16:00
    inRTH := time(timeframe.period, "0930-1600") != 0

    // After‑Hours: 16:00–23:59
    inAH := time(timeframe.period, "1600-2359") != 0

    // Pre‑Market: 00:00–09:29
    inPM := time(timeframe.period, "0000-0929") != 0

    inDead := false

// Detect RTH open (for VWAP reset)
bool newRTHSession = inRTH and not inRTH[1]

//────────────────────────────────────────────────────────────
// VWAP Calculation Logic — RTH Open Reset + RTH Close Reset
//────────────────────────────────────────────────────────────
// Declare VWAP variable
var float sessionVWAP = na

// Detect RTH open (start of new RTH VWAP)
bool rthOpen  = inRTH and not inRTH[1]

// Detect RTH close (start of ON VWAP)
bool rthClose = not inRTH and inRTH[1]

// Anchor index resets at BOTH boundaries
var int anchorIndex = na
if rthOpen or rthClose
    anchorIndex := bar_index

// Compute VWAP only after anchor is known
if na(anchorIndex)
    sessionVWAP := na
else
    int rel = bar_index - anchorIndex

    if rel >= 0
        float volSum      = 0.0
        float volPriceSum = 0.0

        for i = 0 to rel
            volSum      += volume[i]
            volPriceSum += volume[i] * vwapSrc[i]

        sessionVWAP := volSum > 0 ? volPriceSum / volSum : na
    else
        sessionVWAP := na

plot(useVWAP ? sessionVWAP : na,
     title = "Session VWAP",
     color = vwapColor,
     linewidth = 3)

//────────────────────────────────────────────────────────────
// VWAP Standard Deviation Bands (1σ and 2σ)
//────────────────────────────────────────────────────────────

float sessionStd = na

if not na(anchorIndex)
    int rel2 = bar_index - anchorIndex

    if rel2 >= 1
        float varSum = 0.0
        float count  = rel2 + 1

        // Compute variance relative to VWAP
        for i = 0 to rel2
            float diff = vwapSrc[i] - sessionVWAP[i]
            varSum += diff * diff

        sessionStd := math.sqrt(varSum / count)
    else
        sessionStd := na

// Compute bands
float vwapUpper1 = sessionVWAP + sessionStd
float vwapLower1 = sessionVWAP - sessionStd

float vwapUpper2 = sessionVWAP + sessionStd * 2
float vwapLower2 = sessionVWAP - sessionStd * 2

// Plot bands
plot(showBand1 ? vwapUpper1 : na, "VWAP +1σ", bandColor, 1)
plot(showBand1 ? vwapLower1 : na, "VWAP -1σ", bandColor, 1)

plot(showBand2 ? vwapUpper2 : na, "VWAP +2σ", bandColor, 1)
plot(showBand2 ? vwapLower2 : na, "VWAP -2σ", bandColor, 1)

//────────────────────────────────────────────────────────────
// VWAP Cloud Shading
//────────────────────────────────────────────────────────────

// 1σ shading (between +1σ and -1σ)
fill(
    plot(showBand1 ? vwapUpper1 : na, title="Upper 1σ", display=display.none),
    plot(showBand1 ? vwapLower1 : na, title="Lower 1σ", display=display.none),
    color = color.new(bandColor, 80)
)

// 2σ shading (between +2σ and -2σ)
fill(
    plot(showBand2 ? vwapUpper2 : na, title="Upper 2σ", display=display.none),
    plot(showBand2 ? vwapLower2 : na, title="Lower 2σ", display=display.none),
    color = color.new(bandColor, 90)
)

//────────────────────────────────────────────────────────────
// Moving Averages (on chart timeframe price)
//────────────────────────────────────────────────────────────
f_ma(src, len, typ) =>
    typ == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

maSrc = close

ma1 = showMA1 ? f_ma(maSrc, ma1Len, ma1Type) : na
ma2 = showMA2 ? f_ma(maSrc, ma2Len, ma2Type) : na
ma3 = showMA3 ? f_ma(maSrc, ma3Len, ma3Type) : na

plot(showMA1 ? ma1 : na, title = "MA 1", color = ma1Col, linewidth = 1)
plot(showMA2 ? ma2 : na, title = "MA 2", color = ma2Col, linewidth = 1)
plot(showMA3 ? ma3 : na, title = "MA 3", color = ma3Col, linewidth = 1)
````
