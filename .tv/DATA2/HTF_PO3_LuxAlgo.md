<!-- tradingview-pine-id: PUB;979d222970d5437f8b6ec6fa1b3be87b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF PO3 [LuxAlgo]

Source: https://www.tradingview.com/script/bNFVH7o6-Multi-Timeframe-Candles-HTF-P03/

## Description

[Quantum Edge] — Multi-Timeframe Higher Timeframe Candle Projection with Volume Delta
Project higher timeframe candles onto your lower timeframe chart — with live intrabar tracking, volume delta, and precise LTF↔HTF mapping lines.

🎯 What It Does
This indicator pulls a higher timeframe (HTF) candle structure and projects it onto your current chart as a horizontal sequence of boxes (bodies) and lines (wicks) to the right of price action. It tracks one live forming HTF candle in real time — updating its high, low, and volume delta intrabar — while optionally displaying up to 10 completed historical HTF candles.

Key innovation: The live HTF candle draws dashed connector lines from the exact lower-timeframe bars that created its open, high, low, and current close — so you see precisely where each HTF level originated on your execution timeframe.

✨ Core Features
Feature	Description
🕐 Single HTF Selection	Any timeframe ≥ current chart (e.g., 1H on 5m, 4H on 15m, 1D on 1H)
📊 1–10 Candles Display	Show 1 live candle, or 1 live + up to 9 completed history candles
🔴🟢 Live Intrabar Updates	High/low/delta update tick-by-tick as the HTF candle forms
📈 Volume Delta Tracking	Running buy/sell volume delta (+vol / ‑vol) on the live candle
🔗 LTF→HTF Mapping Lines	Dashed lines from LTF open/high/low/close bars → projected HTF levels (live candle only)
🏷️ Price & Time Labels	OHL labels + HTF timestamp (on history candles) + delta label (live)
🎨 Full Style Control	Bull/bear colors, live/history transparency, label toggles, right offset
⚙️ Input Groups
Higher Timeframe Settings
Input	Default	Description
HTF Timeframe	60 (1H)	Target higher timeframe (must be ≥ chart TF)
Candles to Show	1	1 = live only; 2–10 = live + N history
Right Offset (Bars)	15	Horizontal gap from current bar to first projected candle
Visual Style
Input	Default	Description
Bullish Color	#089981	Body/wick/label color for bullish HTF candles
Bearish Color	#F23645	Body/wick/label color for bearish HTF candles
Live Body Transparency	0	0–100% transparency for the forming candle
Show Price Labels	On	OHL labels on live candle
Show Running Delta	On	Volume delta label below live candle low
🧠 How to Use
Open a lower timeframe chart (1m, 3m, 5m, 15m — your execution TF).

Add the indicator and set HTF Timeframe to your analysis timeframe (e.g., 240 for 4H, D for daily).

Set Candles to Show:

1 → clean live projection only (best for real-time bias)

3–6 → live + recent context (swing structure, PO3 zones)

Watch the live candle build: high/low extend, delta accumulates, mapping lines trace back to the exact LTF bars that printed each level.

Use for: HTF bias confirmation, PO3/CHoCH/BOS projection, delta divergence on the forming HTF bar, precise entry timing at HTF extremes.

📐 Visual Guide
text
Live HTF Candle (updating intrabar)
┌─────────────────────────┐
│  ████████████████████  │  ← Body (transparency controlled)
│  │         │         │  │  ← Wick
│  │    Δ +1.2K      │  │  ← Volume delta (live only)
└─────────────────────────┘
   ▲           ▲           ▲
   │           │           │
   ▼           ▼           ▼
 LTF Open   LTF High    LTF Low   (dashed lines to source bars)
⚡ Performance Notes
max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500 — supports up to 10 candles × full drawing set without cleanup issues.

Runs entirely on barstate.islast — zero overhead during historical bar processing.

Uses ta.change(time(htfInput)) for reliable HTF boundary detection (no request.security repaint risk).

Volume delta uses tick volume (volume built-in) — works on all markets (crypto, forex, futures, stocks).

🏷️ Credits & Attribution
Original Concept & Base Logic: LuxAlgo — HTF PO3 (Price–Orderflow–Projection) framework

Pine Script v6 Implementation: Quantum Edge

Inspired by: Institutional orderflow analysis, multi-timeframe candle projection, and delta-based HTF confirmation techniques

This is a derivative implementation for educational and analytical purposes. LuxAlgo retains credit for the core PO3 methodology.

📋 Suggested Tags (TradingView)
multi-timeframe htf candle-projection volume-delta orderflow price-action swing-trading scalping luxalgo po3 market-structure

💡 Pro Tip
Pair with a lower-timeframe structure/CHOCH/BOS indicator (e.g., LuxAlgo Premium, Smart Money Concepts, or your own SMC tool). Use the HTF PO3 live candle’s high/low as macro invalidation levels and the delta flip as early momentum shift signal before the HTF candle closes.

---

## Source Code

````pine
// © Quantum Edge 

//@version=6
indicator("HTF PO3 [LuxAlgo]", "Multi Timeframe - HTF PO3", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// Constants & Inputs
//---------------------------------------------------------------------------------------------------------------------{
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color NEUTRAL_COLOR = #787b86

string HTF_GROUP      = "Higher Timeframe Settings"
string htfInput       = input.timeframe("60", "HTF Timeframe", group = HTF_GROUP)
int candleCountInput  = input.int(1, "Candles to Show", minval = 1, maxval = 10, group = HTF_GROUP)
int offsetInput       = input.int(15, "Right Offset (Bars)", minval = 5, group = HTF_GROUP)

string STYLE_GROUP    = "Visual Style"
color bullColorInput  = input.color(BULL_COLOR, "Bullish Color", inline = "colors", group = STYLE_GROUP)
color bearColorInput  = input.color(BEAR_COLOR, "Bearish Color", inline = "colors", group = STYLE_GROUP)
int transparency      = input.int(0, "Live Body Transparency", minval = 0, maxval = 100, group = STYLE_GROUP)
bool showLabelsInput  = input.bool(true, "Show Price Labels", group = STYLE_GROUP)
bool showDeltaInput   = input.bool(true, "Show Running Delta", group = STYLE_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// Types & Methods
//---------------------------------------------------------------------------------------------------------------------{
type HTFData
    float o
    float h
    float l
    float c
    int   oIdx
    int   hIdx
    int   lIdx
    float delta
    int   startTime

type HTFCandleUI
    box   body
    line  wick
    line  oM
    line  hM
    line  lM
    line  cM
    label oL
    label hL
    label lL
    label cL
    label dL
    label tL

//---------------------------------------------------------------------------------------------------------------------}
// Calculations
//---------------------------------------------------------------------------------------------------------------------{
var htfHistory = array.new<HTFData>()
bool htfNew = ta.change(time(htfInput)) != 0

// Tracking for current forming HTF candle
var float curO = na, var float curH = na, var float curL = na
var int   curOIdx = na, var int   curHIdx = na, var int   curLIdx = na
var float curDelta = 0.0
var int   curStartTime = na

if htfNew
    // Save finished candle to history
    if not na(curO)
        htfHistory.unshift(HTFData.new(curO, curH, curL, close[1], curOIdx, curHIdx, curLIdx, curDelta, curStartTime))
        if htfHistory.size() > 10
            htfHistory.pop()
    
    // Initialize new candle
    curO := open
    curH := high
    curL := low
    curOIdx := bar_index
    curHIdx := bar_index
    curLIdx := bar_index
    curDelta := (close > open ? volume : close < open ? -volume : 0)
    curStartTime := time
else
    if high > curH or na(curH)
        curH := high
        curHIdx := bar_index
    if low < curL or na(curL)
        curL := low
        curLIdx := bar_index
    curDelta += (close > open ? volume : close < open ? -volume : 0)

// Formatting Delta
formatDelta(float val) =>
    string sign = val > 0 ? "+" : ""
    float absVal = math.abs(val)
    absVal >= 1000000 ? sign + str.format("{0,number,#.#}M", val / 1000000) : absVal >= 1000 ? sign + str.format("{0,number,#.#}K", val / 1000) : sign + str.tostring(val)

//---------------------------------------------------------------------------------------------------------------------}
// Visuals
//---------------------------------------------------------------------------------------------------------------------{
var uiElements = array.new<HTFCandleUI>()

if barstate.islast
    // Cleanup previous UI elements
    if uiElements.size() > 0
        for i = 0 to uiElements.size() - 1
            HTFCandleUI ui = uiElements.get(i)
            ui.body.delete()
            ui.wick.delete()
            if not na(ui.oM) 
                ui.oM.delete()
            if not na(ui.hM) 
                ui.hM.delete()
            if not na(ui.lM) 
                ui.lM.delete()
            if not na(ui.cM) 
                ui.cM.delete()
            if not na(ui.oL) 
                ui.oL.delete()
            if not na(ui.hL) 
                ui.hL.delete()
            if not na(ui.lL) 
                ui.lL.delete()
            if not na(ui.cL) 
                ui.cL.delete()
            if not na(ui.dL) 
                ui.dL.delete()
            if not na(ui.tL) 
                ui.tL.delete()
    uiElements.clear()

    int candleWidth = 6
    int candleGap   = 10

    // Render candles chronologically: [Oldest] ... [Prev] [Live]
    for p = 0 to candleCountInput - 1
        bool isLive = (p == candleCountInput - 1)
        HTFData data = na
        
        if isLive
            data := HTFData.new(curO, curH, curL, close, curOIdx, curHIdx, curLIdx, curDelta, curStartTime)
        else
            int histIdx = (candleCountInput - 2) - p
            if htfHistory.size() > histIdx
                data := htfHistory.get(histIdx)
        
        if not na(data)
            // Coordinates for the projection
            int startIdx = last_bar_index + offsetInput + (p * (candleWidth + candleGap))
            int endIdx   = startIdx + candleWidth
            int midIdx   = (startIdx + endIdx) / 2
            int labelIdx = endIdx + 1
            
            color baseColor = data.c >= data.o ? bullColorInput : bearColorInput
            color wickColor = isLive ? baseColor : color.new(baseColor, 70)
            int bodyTrans   = isLive ? transparency : 85
            
            // 1. HTF Candle (Drawn using absolute prices and index grid)
            line wLine = line.new(midIdx, data.h, midIdx, data.l, color = wickColor, width = 2)
            box  bBox  = box.new(startIdx, math.max(data.o, data.c), endIdx, math.min(data.o, data.c), border_color = wickColor, bgcolor = color.new(baseColor, bodyTrans))

            // 2. Mapping & Labels (ONLY for the LIVE candle)
            line oM = na, line hM = na, line lM = na, line cM = na
            label oL = na, label hL = na, label lL = na, label cL = na

            if isLive
                // Direct connectors from LTF bar origin to HTF projection
                oM := line.new(data.oIdx, data.o, startIdx, data.o, color = NEUTRAL_COLOR, style = line.style_dashed)
                hM := line.new(data.hIdx, data.h, midIdx, data.h, color = bullColorInput, style = line.style_dashed)
                lM := line.new(data.lIdx, data.l, midIdx, data.l, color = bearColorInput, style = line.style_dashed)
                cM := line.new(bar_index, data.c, endIdx, data.c, color = baseColor, style = line.style_dashed)

                if showLabelsInput
                    oL := label.new(labelIdx, data.o, "Open: " + str.tostring(data.o, format.mintick), color = #00000000, textcolor = NEUTRAL_COLOR, style = label.style_label_left, size = size.small)
                    hL := label.new(labelIdx, data.h, "High: " + str.tostring(data.h, format.mintick), color = #00000000, textcolor = bullColorInput, style = label.style_label_left, size = size.small)
                    lL := label.new(labelIdx, data.l, "Low: " + str.tostring(data.l, format.mintick), color = #00000000, textcolor = bearColorInput, style = label.style_label_left, size = size.small)
                    cL := label.new(labelIdx, data.c, "Close: " + str.tostring(data.c, format.mintick), color = #00000000, textcolor = baseColor, style = label.style_label_left, size = size.small)

            // 3. Timeframe Header
            int totalMins = timeframe.in_seconds(htfInput) / 60
            string tfStr = totalMins >= 1440 ? str.tostring(totalMins/1440) + "D" : totalMins >= 60 ? str.tostring(totalMins/60) + "H" : str.tostring(totalMins) + "m"
            string headText = tfStr
            if not isLive
                headText += "\n" + str.format_time(data.startTime, "HH:mm", syminfo.timezone)
            color tfColor = isLive ? NEUTRAL_COLOR : color.new(NEUTRAL_COLOR, 60)
            label tL = label.new(midIdx, data.h, headText, color = #00000000, textcolor = tfColor, style = label.style_label_down, size = size.normal)

            // 4. Delta (Centered below Low)
            label dL = na
            if showDeltaInput
                color dCol = data.delta >= 0 ? bullColorInput : bearColorInput
                color fDCol = isLive ? dCol : color.new(dCol, 60)
                dL := label.new(midIdx, data.l, "Delta: " + formatDelta(data.delta), color = #00000000, textcolor = fDCol, style = label.style_label_up, size = size.normal)

            uiElements.push(HTFCandleUI.new(bBox, wLine, oM, hM, lM, cM, oL, hL, lL, cL, dL, tL))

//---------------------------------------------------------------------------------------------------------------------}
// End of Script
//---------------------------------------------------------------------------------------------------------------------{
````
