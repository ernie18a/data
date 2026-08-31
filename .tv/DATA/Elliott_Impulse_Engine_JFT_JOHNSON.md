<!-- tradingview-pine-id: PUB;94dd1e26669d4dadbdf86c35204fd080 -->
<!-- tradingviewscripts-format: 1 -->
# Elliott Impulse Engine JFT [JOHNSON]

Source: https://www.tradingview.com/script/tcQ0ZZQK-Elliott-Impulse-Engine-JFT-JOHNSON/

## Description

Elliott Impulse Engine JFT is designed to help traders identify market impulse movements, momentum strength, and potential trend continuation opportunities. For the best performance, use this indicator on the 1 Hour (1H) timeframe with proper price action confirmation.

Chart Setup
Open your preferred trading instrument:

• XAUUSD (Gold)
• XAGUSD (Silver)
• Forex Pairs
• Crypto Markets
• Indices

Set the chart timeframe to 1H (60 Minutes).
Apply Elliott Impulse Engine JFT on the chart.
Keep the chart clean and focus on high-probability market conditions.
BUY Strategy — Bullish Impulse Confirmation

Look for a BUY opportunity when the following conditions align:

1. Bullish Momentum Detection
Wait for the indicator to identify a strong bullish impulse movement or positive market pressure.

2. Market Location
Price should react from a strong support zone, demand area, or previous structure level.

3. Candle Confirmation
A strong bullish 1H candle should confirm buyer strength before entering.

4. Entry Execution
Enter the BUY position after confirmation and avoid entering during weak momentum.

Stop Loss Placement:
Place the stop loss below the latest swing low or important support level.

Profit Targets:

Target 1: First resistance zone
Target 2: Previous market high
Target 3: Extended impulse continuation area

SELL Strategy — Bearish Impulse Confirmation

Look for a SELL opportunity when:

1. Bearish Momentum Detection
The indicator identifies a strong bearish impulse or increasing selling pressure.

2. Market Location
Price rejects from a strong resistance zone, supply area, or previous structure level.

3. Candle Confirmation
A strong bearish 1H candle confirms seller control.

4. Entry Execution
Enter the SELL position after confirmation.

Stop Loss Placement:
Place the stop loss above the latest swing high or resistance zone.

Profit Targets:

Target 1: First support zone
Target 2: Previous market low
Target 3: Extended bearish continuation area

Professional Trading Rules

For higher-quality setups, combine Elliott Impulse Engine JFT with:

✓ Market Structure Analysis
✓ Support & Resistance Zones
✓ Trend Direction
✓ Breakout Confirmation
✓ Strong Candle Patterns
✓ Risk Management

Maintain a minimum Risk-to-Reward ratio of 1:2 for professional trade execution.

Avoid Low-Quality Signals

Do not trade when:

• Market is moving sideways with no clear direction
• Momentum is extremely weak
• High-impact news creates abnormal volatility
• Signal appears against the main market trend

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnsonForexTrader

//@version=6
indicator("Elliott Impulse Engine JFT [JOHNSON]", overlay=true, max_labels_count=500)

// ───── Inputs ─────
pivotLength = input.int(5, "Swing Strength", minval=2)
showWaves = input.bool(true, "Show Elliott Waves")

// ───── Swing Detection ─────
pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)
pivotLow  = ta.pivotlow(low, pivotLength, pivotLength)

// ───── Arrays ─────
var float[] swingPrices = array.new_float()
var int[] swingBars = array.new_int()
var int[] swingTypes = array.new_int()

// High = 1 , Low = -1
if not na(pivotHigh)
    array.push(swingPrices, pivotHigh)
    array.push(swingBars, bar_index - pivotLength)
    array.push(swingTypes, 1)

if not na(pivotLow)
    array.push(swingPrices, pivotLow)
    array.push(swingBars, bar_index - pivotLength)
    array.push(swingTypes, -1)


// ───── Elliott Wave Label Engine ─────
if showWaves and array.size(swingPrices) >= 5
    
    last = array.size(swingPrices)

    p1 = array.get(swingPrices, last - 5)
    p2 = array.get(swingPrices, last - 4)
    p3 = array.get(swingPrices, last - 3)
    p4 = array.get(swingPrices, last - 2)
    p5 = array.get(swingPrices, last - 1)

    b1 = array.get(swingBars, last - 5)
    b2 = array.get(swingBars, last - 4)
    b3 = array.get(swingBars, last - 3)
    b4 = array.get(swingBars, last - 2)
    b5 = array.get(swingBars, last - 1)


    bullishImpulse = p1 < p3 and p3 < p5 and p2 < p4
    bearishImpulse = p1 > p3 and p3 > p5 and p2 > p4


    if bullishImpulse
        label.new(b1, p1, "1", style=label.style_label_up)
        label.new(b2, p2, "2", style=label.style_label_down)
        label.new(b3, p3, "3", style=label.style_label_up)
        label.new(b4, p4, "4", style=label.style_label_down)
        label.new(b5, p5, "5", style=label.style_label_up)


    if bearishImpulse
        label.new(b1, p1, "1", style=label.style_label_down)
        label.new(b2, p2, "2", style=label.style_label_up)
        label.new(b3, p3, "3", style=label.style_label_down)
        label.new(b4, p4, "4", style=label.style_label_up)
        label.new(b5, p5, "5", style=label.style_label_down)


// ───── Swing Markers ─────
plotshape(not na(pivotHigh), 
     title="Swing High",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny)

plotshape(not na(pivotLow),
     title="Swing Low",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny)
     // ───── Part 2 : Elliott Momentum & Fibonacci Engine ─────

// Inputs
showTargets = input.bool(true, "Show Fibonacci Targets")
showSignals = input.bool(true, "Show Trade Signals")

rsiLength = input.int(14, "Momentum RSI")
rsiValue = ta.rsi(close, rsiLength)

emaFast = ta.ema(close, 50)
emaSlow = ta.ema(close, 200)

trendBull = emaFast > emaSlow
trendBear = emaFast < emaSlow


// ───── Latest Swing Data ─────
var float wave1 = na
var float wave2 = na
var float wave3 = na
var float wave4 = na
var float wave5 = na


if array.size(swingPrices) >= 5
    sz = array.size(swingPrices)

    wave1 := array.get(swingPrices, sz - 5)
    wave2 := array.get(swingPrices, sz - 4)
    wave3 := array.get(swingPrices, sz - 3)
    wave4 := array.get(swingPrices, sz - 2)
    wave5 := array.get(swingPrices, sz - 1)



// ───── Fibonacci Projection ─────
waveRange = math.abs(wave3 - wave2)

target161 = wave3 + (waveRange * 1.618)
target261 = wave3 + (waveRange * 2.618)

bearTarget161 = wave3 - (waveRange * 1.618)
bearTarget261 = wave3 - (waveRange * 2.618)



// ───── Draw Targets ─────
if showTargets and not na(wave3)

    if wave3 > wave2
        line.new(bar_index, target161, bar_index + 20, target161)
        line.new(bar_index, target261, bar_index + 20, target261)

    if wave3 < wave2
        line.new(bar_index, bearTarget161, bar_index + 20, bearTarget161)
        line.new(bar_index, bearTarget261, bar_index + 20, bearTarget261)



// ───── Wave 3 Momentum ─────
strongBullWave = 
     wave3 > wave1 and 
     rsiValue > 55 and 
     trendBull


strongBearWave = 
     wave3 < wave1 and 
     rsiValue < 45 and 
     trendBear



// ───── Elliott Entry Signals ─────
buySignal = strongBullWave and close > emaFast
sellSignal = strongBearWave and close < emaFast


plotshape(showSignals and buySignal,
     title="Elliott Buy",
     style=shape.labelup,
     text="ELLIOTT BUY",
     location=location.belowbar)

plotshape(showSignals and sellSignal,
     title="Elliott Sell",
     style=shape.labeldown,
     text="ELLIOTT SELL",
     location=location.abovebar)



// ───── Wave 5 Exhaustion ─────
wave5Warning = 
     not na(wave5) and 
     math.abs(wave5 - wave3) < math.abs(wave3 - wave1) * 0.5


plotshape(wave5Warning,
     title="Wave 5 Exhaustion",
     style=shape.xcross,
     location=location.abovebar,
     text="W5")
     // ───── Part 3 : Elliott Pro Dashboard Engine ─────

// Inputs
showDashboard = input.bool(true, "Show Elliott Dashboard")
higherTF = input.timeframe("240", "Higher Timeframe")


// ───── Higher Timeframe Trend ─────
htfEMA50 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close,50))

htfEMA200 = request.security(
     syminfo.tickerid,
     higherTF,
     ta.ema(close,200))


htfBull = htfEMA50 > htfEMA200
htfBear = htfEMA50 < htfEMA200



// ───── Elliott Condition ─────
waveStatus = "Searching Wave..."

if not na(wave1) and not na(wave5)
    if wave5 > wave1
        waveStatus := "Bullish Impulse"
    else
        waveStatus := "Bearish Impulse"



momentumStatus = 
     rsiValue > 50 ? "Positive" : "Weak"



trendStatus =
     trendBull ? "Bullish" :
     trendBear ? "Bearish" : "Neutral"


htfStatus =
     htfBull ? "HTF Bullish" :
     htfBear ? "HTF Bearish" : "HTF Neutral"



// ───── Dashboard ─────
var table dash = table.new(
     position.top_right,
     2,
     5)


if showDashboard and barstate.islast

    table.cell(dash,0,0,"Elliott Engine PRO")
    table.cell(dash,1,0,"ACTIVE")

    table.cell(dash,0,1,"Wave Status")
    table.cell(dash,1,1,waveStatus)

    table.cell(dash,0,2,"Trend")
    table.cell(dash,1,2,trendStatus)

    table.cell(dash,0,3,"Momentum")
    table.cell(dash,1,3,momentumStatus)

    table.cell(dash,0,4,"MTF")
    table.cell(dash,1,4,htfStatus)



// ───── Alerts ─────

alertcondition(
     buySignal,
     title="Elliott BUY Signal",
     message="Elliott Impulse Engine PRO: BUY Signal")


alertcondition(
     sellSignal,
     title="Elliott SELL Signal",
     message="Elliott Impulse Engine PRO: SELL Signal")
````
