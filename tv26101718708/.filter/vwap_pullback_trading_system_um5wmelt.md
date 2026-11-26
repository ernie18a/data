# VWAP Pullback Trading System

- url: https://www.tradingview.com/script/um5WMElt-VWAP-Pullback-Trading-System/
- type: indicator
- pine_id: PUB;dea9a7b4475347cfa83b28284daf8d23
- version: 1.0

## Description

1. How the BUY signal is generated
Price must trade above VWAP (bullish institutional bias).
A pullback cycle activates when a candle's low touches or comes within the configurable tolerance % of VWAP.
Price must not be over-extended (beyond maxExtendedPct) — this prevents chasing moves.
After the pullback zone is tagged, a bullish confirmation is required (any of: bullish close, bullish engulfing, wick rejection, higher-low).
The signal fires only once per pullback cycle. Cycle resets when price either extends well above VWAP again or breaks below it.
2. How Stop Loss is calculated
SL = minimum of the recent swing low (swingLookback) or current VWAP value — whichever is lower — then a small SL buffer (%) is subtracted.
This keeps SL beneath the most recent structural low and below the institutional VWAP reference.
3. How Targets are calculated
Risk = Entry − SL
T1 = Entry + (Risk × rrT1) → default 1:1
T2 = Entry + (Risk × rrT2) → default 1:2
T3 = Entry + (Risk × rrT3) → default 1:3
All RR multipliers are user-configurable.
4. When to avoid this strategy
Choppy / sideways markets where price whipsaws across VWAP repeatedly — pullbacks won't produce real directional moves.
Strong bearish trends (price consistently below VWAP) — this system is long-only.
Pre-market / ultra-low-volume sessions where VWAP is not statistically meaningful.
Major news / event-driven candles where price gaps violently through VWAP.
Over-extended parabolic moves — the maxExtendedPct filter helps, but extra discretion is advised.

## Source Code

````pine
//@version=5
indicator("VWAP Pullback Trading System", shorttitle="VWAP Pullback", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// ===================== INPUTS ===============================
// ============================================================

// --- Pullback Settings ---
grpPB = "Pullback Settings"
tolerancePct    = input.float(0.30, "VWAP Pullback Tolerance (%)", minval=0.01, step=0.05, group=grpPB, tooltip="Max % distance from VWAP to consider price as 'pulled back'")
maxExtendedPct  = input.float(1.50, "Max Extension From VWAP (%)", minval=0.1, step=0.1, group=grpPB, tooltip="If price is further than this % above VWAP, pullback is invalidated / no chase entries")
swingLookback   = input.int(10, "Swing Lookback Period", minval=3, maxval=50, group=grpPB)

// --- Confirmation Toggles ---
grpConf = "Confirmation Conditions"
useBullClose    = input.bool(true,  "Require Bullish Candle Close", group=grpConf)
useEngulfing    = input.bool(true,  "Use Bullish Engulfing Confirmation", group=grpConf)
useWickReject   = input.bool(true,  "Use Wick Rejection Near VWAP", group=grpConf)
useHigherLow    = input.bool(true,  "Use Higher-Low Confirmation", group=grpConf)

// --- Risk-Reward ---
grpRR = "Risk / Reward"
rrT1 = input.float(1.0, "Target 1 RR", minval=0.1, step=0.1, group=grpRR)
rrT2 = input.float(2.0, "Target 2 RR", minval=0.1, step=0.1, group=grpRR)
rrT3 = input.float(3.0, "Target 3 RR", minval=0.1, step=0.1, group=grpRR)
slBuffer = input.float(0.05, "SL Buffer (%)", minval=0.0, step=0.01, group=grpRR, tooltip="Extra buffer below swing low/VWAP for SL")

// --- Display ---
grpShow = "Display"
showVWAP   = input.bool(true, "Show VWAP", group=grpShow)
showLines  = input.bool(true, "Show Entry/SL/Target Lines", group=grpShow)
showLabels = input.bool(true, "Show Buy Label", group=grpShow)
lineLength = input.int(30, "Line Projection (bars)", minval=5, maxval=200, group=grpShow)

// ============================================================
// ===================== VWAP =================================
// ============================================================
vwapVal = ta.vwap(hlc3)
plot(showVWAP ? vwapVal : na, "VWAP", color=color.new(color.orange, 0), linewidth=2)

// ============================================================
// ================ CORE CONDITIONS ===========================
// ============================================================

// Bullish bias: price above VWAP
priceAboveVWAP = close > vwapVal

// Distance from VWAP (%)
distFromVWAPPct = ((close - vwapVal) / vwapVal) * 100

// Price is near VWAP within tolerance (pullback zone)
nearVWAP = math.abs((low - vwapVal) / vwapVal) * 100 <= tolerancePct or (low <= vwapVal and close >= vwapVal)

// Not extended (avoid chasing)
notExtended = distFromVWAPPct <= maxExtendedPct

// ============================================================
// ================ PULLBACK DETECTION ========================
// ============================================================
// We detect a valid pullback when:
// 1. Price was above VWAP (bullish bias)
// 2. A candle touches / comes within tolerance of VWAP
var bool pullbackActive = false
var float pullbackLow  = na

// Activate pullback once price touches/near VWAP with bullish bias intact above
if priceAboveVWAP and nearVWAP and notExtended
    pullbackActive := true
    pullbackLow := na(pullbackLow) ? low : math.min(pullbackLow, low)

// Reset pullback if price moves far above VWAP (new extension; ready for next pullback)
if distFromVWAPPct > maxExtendedPct
    pullbackActive := false
    pullbackLow := na

// Reset if price closes below VWAP (bias lost)
if close < vwapVal
    pullbackActive := false
    pullbackLow := na

// ============================================================
// ================ CONFIRMATION SIGNALS ======================
// ============================================================

// Bullish close
bullClose = close > open

// Bullish engulfing
bullEngulf = close > open and close[1] < open[1] and close >= open[1] and open <= close[1]

// Wick rejection near VWAP: lower wick long and close near high, low touched/close to VWAP
candleRange   = high - low
lowerWick     = math.min(open, close) - low
wickReject    = candleRange > 0 and (lowerWick / candleRange) >= 0.5 and low <= vwapVal * (1 + tolerancePct/100) and close > open

// Higher low formation vs last N bars low
priorLow = ta.lowest(low, swingLookback)[1]
higherLow = low > priorLow and close > open

// Combine confirmations (any active)
confirmations = (useBullClose  and bullClose)
             or (useEngulfing  and bullEngulf)
             or (useWickReject and wickReject)
             or (useHigherLow  and higherLow)

// If none enabled, default to bullish close
noneEnabled = not (useBullClose or useEngulfing or useWickReject or useHigherLow)
confirmed = noneEnabled ? bullClose : confirmations

// ============================================================
// ================ SIGNAL GENERATION =========================
// ============================================================
var bool signalFiredThisCycle = false

// Reset signal when pullback ends / bias lost
if not pullbackActive
    signalFiredThisCycle := false

buySignal = pullbackActive and priceAboveVWAP and notExtended and confirmed and not signalFiredThisCycle

// Swing low for SL
swingLow = ta.lowest(low, swingLookback)

// Risk Management calculations
var float entryPrice = na
var float slPrice    = na
var float t1Price    = na
var float t2Price    = na
var float t3Price    = na
var int   signalBar  = na

if buySignal
    entryPrice := close
    // SL: lower of swing low or VWAP, minus buffer
    rawSL       = math.min(swingLow, vwapVal)
    slPrice    := rawSL * (1 - slBuffer/100)
    risk        = entryPrice - slPrice
    t1Price    := entryPrice + risk * rrT1
    t2Price    := entryPrice + risk * rrT2
    t3Price    := entryPrice + risk * rrT3
    signalBar  := bar_index
    signalFiredThisCycle := true

// ============================================================
// ================ PLOTTING ==================================
// ============================================================

// Buy label
if buySignal and showLabels
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

// Draw lines for the latest trade
var line lnEntry = na
var line lnSL    = na
var line lnT1    = na
var line lnT2    = na
var line lnT3    = na
var label lbEntry = na
var label lbSL    = na
var label lbT1    = na
var label lbT2    = na
var label lbT3    = na

if buySignal and showLines
    // Delete old lines
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbT3)

    endBar = bar_index + lineLength
    lnEntry := line.new(bar_index, entryPrice, endBar, entryPrice, color=color.blue,   width=2, style=line.style_solid)
    lnSL    := line.new(bar_index, slPrice,    endBar, slPrice,    color=color.red,    width=2, style=line.style_dashed)
    lnT1    := line.new(bar_index, t1Price,    endBar, t1Price,    color=color.green,  width=1, style=line.style_dotted)
    lnT2    := line.new(bar_index, t2Price,    endBar, t2Price,    color=color.green,  width=1, style=line.style_dotted)
    lnT3    := line.new(bar_index, t3Price,    endBar, t3Price,    color=color.green,  width=2, style=line.style_dotted)

    lbEntry := label.new(endBar, entryPrice, "Entry: " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=color.new(color.blue, 70),  textcolor=color.white, size=size.small)
    lbSL    := label.new(endBar, slPrice,    "SL: "    + str.tostring(slPrice,    format.mintick), style=label.style_label_left, color=color.new(color.red, 70),   textcolor=color.white, size=size.small)
    lbT1    := label.new(endBar, t1Price,    "T1: "    + str.tostring(t1Price,    format.mintick), style=label.style_label_left, color=color.new(color.green, 70), textcolor=color.white, size=size.small)
    lbT2    := label.new(endBar, t2Price,    "T2: "    + str.tostring(t2Price,    format.mintick), style=label.style_label_left, color=color.new(color.green, 50), textcolor=color.white, size=size.small)
    lbT3    := label.new(endBar, t3Price,    "T3: "    + str.tostring(t3Price,    format.mintick), style=label.style_label_left, color=color.new(color.green, 30), textcolor=color.white, size=size.small)

// ============================================================
// ================ TARGET / SL HIT TRACKING ==================
// ============================================================
var bool t1Hit = false
var bool t2Hit = false
var bool t3Hit = false
var bool slHit = false
var bool tradeActive = false

if buySignal
    t1Hit := false
    t2Hit := false
    t3Hit := false
    slHit := false
    tradeActive := true

if tradeActive
    if not t1Hit and high >= t1Price
        t1Hit := true
        alert("VWAP Pullback: Target 1 Hit", alert.freq_once_per_bar)
    if not t2Hit and high >= t2Price
        t2Hit := true
        alert("VWAP Pullback: Target 2 Hit", alert.freq_once_per_bar)
    if not t3Hit and high >= t3Price
        t3Hit := true
        tradeActive := false
        alert("VWAP Pullback: Target 3 Hit - Trade Complete", alert.freq_once_per_bar)
    if not slHit and low <= slPrice
        slHit := true
        tradeActive := false
        alert("VWAP Pullback: Stop Loss Hit", alert.freq_once_per_bar)

// ============================================================
// ================ ALERTS ====================================
// ============================================================
alertcondition(buySignal, title="BUY Signal", message="VWAP Pullback BUY Signal Triggered")
alertcondition(tradeActive and high >= t1Price and not t1Hit[1], title="Target 1 Hit", message="VWAP Pullback T1 Hit")
alertcondition(tradeActive and high >= t2Price and not t2Hit[1], title="Target 2 Hit", message="VWAP Pullback T2 Hit")
alertcondition(tradeActive and high >= t3Price and not t3Hit[1], title="Target 3 Hit", message="VWAP Pullback T3 Hit")
alertcondition(tradeActive and low <= slPrice and not slHit[1],  title="SL Hit",      message="VWAP Pullback SL Hit")

// Plot shape for BUY
plotshape(buySignal, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.new(color.green,0), size=size.small)
````
