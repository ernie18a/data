# Structural Divergence [Proozac]

- url: https://www.tradingview.com/script/DkUFWZNx-Structural-Divergence-Proozac/
- type: indicator
- pine_id: PUB;d4ac9d383c2d47779ab82114ae19e3b9
- version: 1.0

## Description

[b]Structural Divergence [Proozac] — Pine Script v6 — Overlay Indicator[/b]

[b]What It Does[/b]
Structural Divergence merges two of the most reliable concepts in technical analysis into a single confluence-based signal: Market Structure (HH/HL/LH/LL, BOS/CHoCH) and RSI/MACD divergence detected precisely at structural swing points — not anywhere on the chart, but exactly where it matters.
Most divergence indicators flag every RSI/price disagreement, drowning traders in low-quality signals. Structural Divergence only calculates divergence at confirmed swing highs and lows, then cross-references it against real structural breaks. A signal only fires when both align.
## How It Works

Swing Detection: identifies significant highs and lows using a configurable pivot length, then labels each one HH, HL, LH, or LL relative to the prior swing of the same type.
BOS / CHoCH: automatically draws Break of Structure and Change of Character lines whenever price closes beyond the last confirmed swing level, tracking trend direction in real time.
Divergence Engine: at every swing high/low, RSI (and optionally MACD histogram, for stricter confirmation) is compared against the prior swing of the same type to detect classic bearish/bullish divergence.
Confluence Signal: when a divergence and a BOS/CHoCH occur within a configurable bar window in the same direction, a triangle signal fires with a built-in alert — filtering out the noise of standalone divergence or structure signals used alone.

[b]Why It's Different[/b]
Instead of stacking indicators and hoping for visual confluence, this script computes it algorithmically. The result is fewer, higher-conviction signals: you're not just seeing "RSI diverged" or "structure broke" — you're seeing both happen together, which historically marks higher-probability reversal and continuation zones.
## Settings

Swing Detection Length (pivot sensitivity)
RSI Length
Optional MACD confirmation (stricter mode)
Confluence window (max bars between divergence and structural break)
Full color customization for bullish/bearish elements

[b]Alerts[/b]
Two ready-to-use alert conditions: Confluence Buy Signal and Confluence Sell Signal — plug straight into TradingView's alert system or your own webhook automation.

## Source Code

````pine
//@version=6
indicator("Structural Divergence [Proozac]", overlay=true, max_lines_count=300, max_labels_count=300, max_bars_back=500)

// ============================================================
// STRUCTURAL DIVERGENCE [Proozac]
// Combines Market Structure (HH/HL/LH/LL, BOS/CHoCH) with
// RSI / MACD divergence detected exactly at swing points.
// A "Confluence Signal" only fires when a divergence and a
// structural break (BOS/CHoCH) align — filtering out the noise
// of standalone divergence signals.
// ============================================================

// ---------------- INPUTS ----------------
grpSwing = "Swing / Structure"
swingLen      = input.int(5, "Swing Detection Length", minval=2, group=grpSwing)
showStructure = input.bool(true, "Show HH/HL/LH/LL Labels", group=grpSwing)
showBOSCHoCH  = input.bool(true, "Show BOS / CHoCH Lines", group=grpSwing)

grpDiv = "Divergence"
rsiLen       = input.int(14, "RSI Length", group=grpDiv)
useMACD      = input.bool(false, "Require MACD Confirmation (stricter)", group=grpDiv)
macdFast     = input.int(12, "MACD Fast", group=grpDiv)
macdSlow     = input.int(26, "MACD Slow", group=grpDiv)
macdSig      = input.int(9,  "MACD Signal", group=grpDiv)
showDivLines = input.bool(true, "Show Divergence Lines", group=grpDiv)

grpConf = "Confluence"
confWindow = input.int(15, "Max Bars Between Divergence and BOS/CHoCH", minval=1, group=grpConf)

grpStyle = "Colors"
bullColor = input.color(color.new(color.teal, 0), "Bullish", group=grpStyle)
bearColor = input.color(color.new(color.red, 0), "Bearish", group=grpStyle)
neutColor = input.color(color.new(color.gray, 40), "Structure Labels", group=grpStyle)

// ---------------- OSCILLATORS ----------------
rsiVal = ta.rsi(close, rsiLen)
[macdLine, macdSignal, _] = ta.macd(close, macdFast, macdSlow, macdSig)
macdHist = macdLine - macdSignal

// ---------------- PIVOTS ----------------
pivHigh = ta.pivothigh(high, swingLen, swingLen)
pivLow  = ta.pivotlow(low, swingLen, swingLen)

// ---------------- STATE: STRUCTURE ----------------
var float prevPivHighPrice = na
var float prevPivLowPrice  = na

var float structureHigh = na   // last confirmed swing high level (break reference)
var float structureLow  = na   // last confirmed swing low level (break reference)
var int   structureHighBar = na
var int   structureLowBar  = na

var string trend = "neutral"   // "bull" / "bear" / "neutral"

var bool brokenHighFlag = false // avoid re-triggering same level
var bool brokenLowFlag  = false

// ---------------- STATE: DIVERGENCE ----------------
var float prevPivHighRSI  = na
var float prevPivLowRSI   = na
var float prevPivHighMACD = na
var float prevPivLowMACD  = na

var int lastBullDivBar = na
var int lastBearDivBar = na
var float lastBullDivPrice = na
var float lastBearDivPrice = na

var float lastBullDivLowPrice = na  // price of the low that caused the div (for line drawing)
var float lastBearDivHighPrice = na

// ============================================================
// HANDLE NEW PIVOT HIGH
// ============================================================
if not na(pivHigh)
    pivBarIdx = bar_index - swingLen
    currRSI   = rsiVal[swingLen]
    currMACD  = macdHist[swingLen]

    // --- structure label HH / LH ---
    if showStructure and not na(prevPivHighPrice)
        isHH = pivHigh > prevPivHighPrice
        label.new(pivBarIdx, pivHigh, isHH ? "HH" : "LH",
             style=label.style_label_down, textcolor=neutColor,
             color=color.new(color.black, 100), size=size.tiny)

    // --- bearish divergence check: price HH, oscillator LH ---
    if not na(prevPivHighPrice) and not na(prevPivHighRSI)
        priceHigherHigh = pivHigh > prevPivHighPrice
        rsiLowerHigh    = currRSI < prevPivHighRSI
        macdOk = useMACD ? (currMACD < prevPivHighMACD) : true
        if priceHigherHigh and rsiLowerHigh and macdOk
            lastBearDivBar := pivBarIdx
            lastBearDivPrice := pivHigh
            lastBearDivHighPrice := prevPivHighPrice
            if showDivLines
                line.new(pivBarIdx - swingLen*0, pivHigh, pivBarIdx, pivHigh, xloc=xloc.bar_index,
                     color=bearColor, width=1, style=line.style_dashed)
                label.new(pivBarIdx, pivHigh, "Bear Div",
                     style=label.style_label_down, textcolor=color.white,
                     color=bearColor, size=size.small)

    // update structure break reference
    structureHigh := pivHigh
    structureHighBar := pivBarIdx
    brokenHighFlag := false

    prevPivHighPrice := pivHigh
    prevPivHighRSI   := currRSI
    prevPivHighMACD  := currMACD

// ============================================================
// HANDLE NEW PIVOT LOW
// ============================================================
if not na(pivLow)
    pivBarIdx = bar_index - swingLen
    currRSI   = rsiVal[swingLen]
    currMACD  = macdHist[swingLen]

    // --- structure label HL / LL ---
    if showStructure and not na(prevPivLowPrice)
        isLL = pivLow < prevPivLowPrice
        label.new(pivBarIdx, pivLow, isLL ? "LL" : "HL",
             style=label.style_label_up, textcolor=neutColor,
             color=color.new(color.black, 100), size=size.tiny)

    // --- bullish divergence check: price LL, oscillator HL ---
    if not na(prevPivLowPrice) and not na(prevPivLowRSI)
        priceLowerLow = pivLow < prevPivLowPrice
        rsiHigherLow  = currRSI > prevPivLowRSI
        macdOk = useMACD ? (currMACD > prevPivLowMACD) : true
        if priceLowerLow and rsiHigherLow and macdOk
            lastBullDivBar := pivBarIdx
            lastBullDivPrice := pivLow
            lastBullDivLowPrice := prevPivLowPrice
            if showDivLines
                line.new(pivBarIdx, pivLow, pivBarIdx, pivLow, xloc=xloc.bar_index,
                     color=bullColor, width=1, style=line.style_dashed)
                label.new(pivBarIdx, pivLow, "Bull Div",
                     style=label.style_label_up, textcolor=color.white,
                     color=bullColor, size=size.small)

    structureLow := pivLow
    structureLowBar := pivBarIdx
    brokenLowFlag := false

    prevPivLowPrice := pivLow
    prevPivLowRSI   := currRSI
    prevPivLowMACD  := currMACD

// ============================================================
// BOS / CHoCH DETECTION (on closing price break of structure)
// ============================================================
bullBreak = not na(structureHigh) and not brokenHighFlag and close > structureHigh
bearBreak = not na(structureLow)  and not brokenLowFlag  and close < structureLow

bosUp = false
chochUp = false
bosDown = false
chochDown = false

if bullBreak
    if trend == "bear"
        chochUp := true
    else
        bosUp := true
    trend := "bull"
    brokenHighFlag := true

if bearBreak
    if trend == "bull"
        chochDown := true
    else
        bosDown := true
    trend := "bear"
    brokenLowFlag := true

if showBOSCHoCH and (bosUp or chochUp)
    line.new(structureHighBar, structureHigh, bar_index, structureHigh, xloc=xloc.bar_index,
         color=bullColor, width=1, style=line.style_dotted)
    label.new(bar_index, structureHigh, chochUp ? "CHoCH" : "BOS",
         style=label.style_label_down, textcolor=color.white,
         color=bullColor, size=size.small)

if showBOSCHoCH and (bosDown or chochDown)
    line.new(structureLowBar, structureLow, bar_index, structureLow, xloc=xloc.bar_index,
         color=bearColor, width=1, style=line.style_dotted)
    label.new(bar_index, structureLow, chochDown ? "CHoCH" : "BOS",
         style=label.style_label_up, textcolor=color.white,
         color=bearColor, size=size.small)

// ============================================================
// CONFLUENCE SIGNAL: divergence + structural break within window
// ============================================================
confluenceBuy  = (bosUp or chochUp) and not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= confWindow
confluenceSell = (bosDown or chochDown) and not na(lastBearDivBar) and (bar_index - lastBearDivBar) <= confWindow

plotshape(confluenceBuy, title="Confluence Buy", style=shape.triangleup, location=location.belowbar,
     color=bullColor, size=size.normal, text="BUY")
plotshape(confluenceSell, title="Confluence Sell", style=shape.triangledown, location=location.abovebar,
     color=bearColor, size=size.normal, text="SELL")

// consume the divergence once used, so it can't trigger twice
if confluenceBuy
    lastBullDivBar := na
if confluenceSell
    lastBearDivBar := na

alertcondition(confluenceBuy, title="Confluence Buy Signal",
     message="Structural Divergence [Proozac]: Bullish confluence (Divergence + BOS/CHoCH) on {{ticker}} {{interval}}")
alertcondition(confluenceSell, title="Confluence Sell Signal",
     message="Structural Divergence [Proozac]: Bearish confluence (Divergence + BOS/CHoCH) on {{ticker}} {{interval}}")
````
