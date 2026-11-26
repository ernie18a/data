# RSI Bottom/Top Retest Scalper [josseliani]

- url: https://www.tradingview.com/script/qvMFG6Ea-RSI-Bottom-Top-Retest-Scalper-josseliani/
- type: indicator
- pine_id: PUB;f238890a2200488eaa4e75beb609ee5f
- version: 1.0

## Description

[b]RSI Bottom/Top Retest Scalper[/b] is a short-term reversal tool built around a simple idea: the first RSI extreme is not always the best moment to act.

Instead, the indicator waits for RSI to leave the extreme area, cool down, form a second structured signal, and then waits for confirmation from price.

The logic is separated into two parts:

→ [b]RSI setup[/b]
→ [b]Price entry confirmation[/b]

[b]How it works[/b]

For a bearish setup:

→ RSI first reaches the upper extreme area.
→ RSI cools down below the selected cooling level.
→ A second local RSI peak forms below the first peak.
→ The second RSI signal is confirmed when RSI starts turning down.
→ Price is then checked against the selected confirmation line.
→ A candle must place the required percentage of its body beyond that line.
→ That candle confirms and arms the setup.
→ The trade calculation starts from the [b]OPEN of the next candle[/b].

The bullish logic is the opposite: RSI forms an extreme bottom, rebounds, returns with a higher second bottom, and price must then confirm above the selected line.

[b]RSI signals[/b]

The RSI setup is shown in two stages.

→ The [b]circle[/b] marks the first RSI extreme.
→ The [b]triangle[/b] marks the confirmed second RSI signal after the cooling and retest process.

These two markers belong to the [b]RSI setup itself[/b]. They are not price-entry signals.

[b]Price entry confirmation[/b]

After the second RSI signal, the script searches for price confirmation using the selected confirmation line.

A candle must place the required percentage of its body beyond that line.

This candle [b]confirms and arms the setup[/b], but it is not used as the entry candle.

The hollow entry arrow and trade calculation appear on the [b]next candle[/b], using that candle's [b]open[/b] as the reference entry price.

So the sequence is:

→ [b]1 — Circle: first RSI extreme[/b]
→ [b]2 — Triangle: second RSI retest signal[/b]
→ [b]3 — Price confirmation and entry[/b]
[image]https://www.tradingview.com/x/8F5GcWJL/ [/image]

[b]Trade markup[/b]

When Trade Markup is enabled, the script automatically displays:

→ Stop Loss
→ 1R
→ 2R

The stop is normally derived from the price structure formed between the RSI retest signal and the price-confirmation event.

If a suitable structural stop cannot be established, or if the calculated risk is too small to be practical, the script can use an ATR-based fallback stop.

The 1R and 2R levels are calculated from the confirmed entry price and the resulting risk distance.

These levels are visual planning references. They are not predictions that price will necessarily reach a target.


[b]Confirmation line[/b]

The confirmation line can be selected from:

→ EMA
→ SMA
→ WMA
→ RMA / SMMA
→ VWMA
→ HMA
→ DEMA
→ TEMA
→ ZLEMA
→ KAMA
→ Kalman
→ ALMA
→ Kijun

The default confirmation line is [b]Kijun 34[/b].

The user can also select how much of the candle body must be beyond the confirmation line before the setup is considered confirmed.

[b]How I use it[/b]

The default settings are tuned for [b]5-minute gold scalping[/b].

I use [b]Kijun 34[/b] as the default confirmation line because I personally like this line a lot. I use it for both 5-minute and 15-minute scalping.

If you move to a lower timeframe, expect more signals, but also more noise. In that case, pay closer attention to entries and Stop Loss placement and consider using a shorter, faster confirmation line.

The script includes a wide selection of moving averages for scalpers, including some less conventional alternatives.

Besides Kijun, I also like [b]ALMA[/b] for scalping. On the 1-minute chart I often use a shorter ALMA because it reacts faster, but this naturally creates a more aggressive trading style.

As a general approach:

→ [b]Lower timeframe → shorter / faster confirmation line → more signals and more noise.[/b]

→ [b]Higher timeframe → longer / slower confirmation line → fewer and more selective signals.[/b]

You can replace Kijun with EMA, ALMA or another available line and adjust its length for the market and timeframe you trade.

[b]Main settings[/b]

→ RSI Length and Source
→ Upper and Lower Extreme Levels
→ Cooling Levels
→ Second Peak / Bottom Re-Entry Levels
→ Minimum Lower High / Higher Low Gap
→ Peak / Bottom Strength
→ Maximum Setup Search Window
→ Optional Midline Invalidation
→ Confirmation Line Type and Length
→ Required Body Beyond Line %
→ Entry Search Window
→ Signal Display
→ Trade Markup
→ RSI / Chart Highlighting

[b]Important[/b]

Local RSI peaks and bottoms require confirmed bars on their right side before they can be identified.

For this reason, a second peak or bottom is marked only after its required confirmation is available.

The indicator separates the oscillator setup from price confirmation so that an RSI retest alone is not automatically treated as a trade entry.

The trade levels shown on the chart are generated from the detected setup and are intended for analysis and trade planning. They do not guarantee future performance. 


[b]Why the second signal?[/b]

The general idea of paying attention to a second oscillator signal has also been discussed in professional technical-analysis research.

Mohamed Ashraf, MFTA, CFTe, CETA presented [i]The Stochastic Oscillator Second Signal[/i] through the International Federation of Technical Analysts (IFTA), examining the second oscillator signal as a distinct technical setup across different timeframes and market conditions.

This script does [b]not[/b] reproduce that methodology. The referenced work uses the Slow Stochastic Oscillator, while this indicator applies its own RSI-based logic using extreme levels, cooling, second-peak / second-bottom structure and subsequent price confirmation.

[b]Reference[/b]
IFTA Journal 2026 — The Stochastic Oscillator Second Signal
[url=https://www.ifta.org/assets/docs/Journal26_IFTA.pdf ]https://www.ifta.org/assets/docs/Journal26_IFTA.pdf [/url]

## Source Code

````pine
//@version=6
indicator("RSI Bottom/Top Retest Scalper [josseliani]", shorttitle="RSI Retest Scalper [josseliani]", overlay=false, max_labels_count=500, max_lines_count=500)
// Public release.
// Entry search starts from the second RSI retest only.
// No Conservative mode and no Entry Mode menu.
// Body-beyond-line candle only ARMS the trade.
// Hollow arrow + SL / 1R / 2R are drawn on the NEXT candle, from that candle's OPEN.
//====================================================
// RSI SETTINGS
//====================================================
groupRSI = "RSI Settings"
rsiLength = input.int(14, "RSI Length", minval=1, group=groupRSI)
rsiSource = input.source(close, "RSI Source", group=groupRSI)
//====================================================
// EXTREME LEVELS
//====================================================
groupExtremes = "Extreme Levels"
upperExtreme = input.float(70.0, "Upper Extreme", minval=0.0, maxval=100.0, step=0.1, group=groupExtremes)
lowerExtreme = input.float(30.0, "Lower Extreme", minval=0.0, maxval=100.0, step=0.1, group=groupExtremes)
//====================================================
// COOLING LEVELS
//====================================================
groupCooling = "Cooling Levels"
upperCoolLevel = input.float(65.0, "Upper Cooling Level", minval=0.0, maxval=100.0, step=0.1, group=groupCooling, tooltip="After the first bearish peak, RSI must fall to/below this level AND below the re-entry minimum — a real pullback before hunting the second peak.")
lowerCoolLevel = input.float(35.0, "Lower Cooling Level", minval=0.0, maxval=100.0, step=0.1, group=groupCooling, tooltip="After the first bullish bottom, RSI must rise to/above this level AND above the re-entry maximum — a real bounce before hunting the second bottom.")
//====================================================
// SECOND PEAK / BOTTOM SETTINGS
//====================================================
groupRetest = "Second Peak / Bottom"
upperRetestMin = input.float(68.0, "Second Peak Re-Entry Minimum", minval=0.0, maxval=100.0, step=0.1, group=groupRetest, tooltip="Floor only: after cooling, the second bearish peak must reach at least this level. The ceiling is always the first peak value (minus gap), so 75→72 is valid.")
lowerRetestMax = input.float(32.0, "Second Bottom Re-Entry Maximum", minval=0.0, maxval=100.0, step=0.1, group=groupRetest, tooltip="Ceiling only: after bounce, the second bullish bottom must stay at/below this level. The floor is always the first bottom value (plus gap).")
minLowerHighGap = input.float(0.3, "Min Lower High / Higher Low Gap", minval=0.0, maxval=20.0, step=0.1, group=groupRetest, tooltip="Second peak ≤ first peak − gap (never higher than the real first peak). Second bottom ≥ first bottom + gap.")
peakStrength = input.int(1, "Peak / Bottom Strength", minval=1, maxval=3, group=groupRetest, tooltip="Requires a true local peak/bottom, not just entering the zone. 1 = 3-bar pivot. Higher = stricter.")
peakTolerance = 0.3
//====================================================
// SETUP INVALIDATION
//====================================================
groupAbort = "Setup Invalidation"
useMidlineAbort = input.bool(false, "Abort on Midline Cross", group=groupAbort, tooltip="Cancel an unfinished setup if RSI crosses the abort level (~50). Stops endless highlight when momentum flips and no second peak is coming.")
bearishAbortLevel = input.float(50.0, "Bearish Abort Level (RSI ≤)", minval=0.0, maxval=100.0, step=0.5, group=groupAbort)
bullishAbortLevel = input.float(50.0, "Bullish Abort Level (RSI ≥)", minval=0.0, maxval=100.0, step=0.5, group=groupAbort)
maxSearchBars = input.int(40, "Max Search Bars (0 = off)", minval=0, maxval=500, group=groupAbort)
//====================================================
// SIGNAL CONFIRMATION
//====================================================
groupConfirmation = "Signal Confirmation"
confirmBars = input.int(1, "Reversal Confirmation Bars", minval=1, maxval=5, group=groupConfirmation)
requireBarClose = input.bool(true, "Confirm Signals on Bar Close", group=groupConfirmation)
//====================================================
// ENTRY CONFIRMATION LINE
//====================================================
groupEntry = "Entry Confirmation"
useEntryConfirmation = input.bool(true, "Use Price Entry Confirmation", group=groupEntry, tooltip="After the RSI retest, wait for a candle whose body is beyond the confirmation line. The entry is NOT that candle: arrow and markup open on the next candle, from its OPEN.")
fastBodyPercent = input.float(50.0, "Body Beyond Line %", minval=1.0, maxval=100.0, step=1.0, group=groupEntry, tooltip="Minimum percentage of the candle BODY that must be beyond the confirmation line. Candle color does not matter. Entry is taken on the OPEN of the following candle.")
entryLineType = input.string("Kijun", "Confirmation Line", options=["EMA", "SMA", "WMA", "RMA / SMMA", "VWMA", "HMA", "DEMA", "TEMA", "ZLEMA", "KAMA", "Kalman", "ALMA", "Kijun"], group=groupEntry, tooltip="Opening logic is the same for every line: EMA, ALMA, Kijun, and the rest. Only the drawn line changes.")
entryLineLength = input.int(34, "Line Length", minval=1, maxval=1000, group=groupEntry)
entryLineSource = input.source(close, "Line Source", group=groupEntry)
almaOffset = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.05, group=groupEntry)
almaSigma = input.float(6.0, "ALMA Sigma", minval=0.5, maxval=20.0, step=0.5, group=groupEntry)
kalmanProcessNoise = input.float(0.01, "Kalman Process Noise", minval=0.000001, step=0.001, group=groupEntry, tooltip="Higher values make the Kalman line react faster to price changes.")
kalmanMeasurementNoise = input.float(0.10, "Kalman Measurement Noise", minval=0.000001, step=0.01, group=groupEntry, tooltip="Higher values smooth the Kalman line more strongly.")
entryWindowBars = input.int(40, "Entry Search Window", minval=3, maxval=200, group=groupEntry, tooltip="Maximum bars after the RSI retest signal to find a body-beyond-line candle.")
entryBullColor = input.color(color.rgb(45, 210, 125), "Long Arrow Color", group=groupEntry)
entryBearColor = input.color(color.rgb(235, 75, 85), "Short Arrow Color", group=groupEntry)
entryLineColor = input.color(color.rgb(105, 145, 255), "Line Color", group=groupEntry)
//====================================================
// ENTRY LINE HELPERS
//====================================================
dema(float source, int length) =>
    float e1 = ta.ema(source, length)
    float e2 = ta.ema(e1, length)
    2.0 * e1 - e2
tema(float source, int length) =>
    float e1 = ta.ema(source, length)
    float e2 = ta.ema(e1, length)
    float e3 = ta.ema(e2, length)
    3.0 * e1 - 3.0 * e2 + e3
zlema(float source, int length) =>
    int lag = math.max(1, int(math.floor((length - 1) / 2.0)))
    float adjusted = source + (source - source[lag])
    ta.ema(adjusted, length)
kamaFilter(float source, int length) =>
    float change = math.abs(source - source[length])
    float volatility = ta.sma(math.abs(source - source[1]), length) * length
    float efficiencyRatio = volatility != 0.0 ? change / volatility : 0.0
    float fastSC = 2.0 / (2.0 + 1.0)
    float slowSC = 2.0 / (30.0 + 1.0)
    float smoothingConstant = math.pow(efficiencyRatio * (fastSC - slowSC) + slowSC, 2.0)
    var float kamaValue = na
    kamaValue := na(kamaValue[1]) ? source : kamaValue[1] + smoothingConstant * (source - kamaValue[1])
    kamaValue
kalmanFilter(float source, float processNoise, float measurementNoise) =>
    var float estimate = na
    var float errorEstimate = 1.0
    if na(estimate)
        estimate := source
    float prediction = estimate
    float predictionError = errorEstimate + processNoise
    float kalmanGain = predictionError / (predictionError + measurementNoise)
    estimate := prediction + kalmanGain * (source - prediction)
    errorEstimate := (1.0 - kalmanGain) * predictionError
    estimate
entryLineValue(string lineType, float source, int length) =>
    switch lineType
        "EMA"        => ta.ema(source, length)
        "SMA"        => ta.sma(source, length)
        "WMA"        => ta.wma(source, length)
        "RMA / SMMA" => ta.rma(source, length)
        "VWMA"       => ta.vwma(source, length)
        "HMA"        => ta.hma(source, length)
        "DEMA"       => dema(source, length)
        "TEMA"       => tema(source, length)
        "ZLEMA"      => zlema(source, length)
        "KAMA"       => kamaFilter(source, length)
        "Kalman"     => kalmanFilter(source, kalmanProcessNoise, kalmanMeasurementNoise)
        "ALMA"       => ta.alma(source, length, almaOffset, almaSigma)
        "Kijun"      => (ta.highest(high, length) + ta.lowest(low, length)) / 2.0
        => ta.ema(source, length)
entryLine = entryLineValue(entryLineType, entryLineSource, entryLineLength)
entryATR = ta.atr(14)
//====================================================
// TRADE PARAMETERS
//====================================================
groupTrade = "Trade Parameters"
showTradeParameters = input.bool(true, "Show Trade Markup (SL / 1R / 2R)", group=groupTrade, tooltip="Adds the separate trade markup after a confirmed entry: Stop Loss, 1R and 2R. Price Entry Confirmation remains the small hollow entry arrow layer.")
tradeProjectionBars = input.int(18, "Trade Level Length", minval=1, maxval=20, group=groupTrade)
//====================================================
// DISPLAY SETTINGS
//====================================================
groupDisplay = "Display"
signalDisplay = input.string("Both", "Signal Display", options=["None (Background Only)", "First Signal Only", "Second Signal Only", "Both"], group=groupDisplay)
iconSizeMode = input.string("Normal", "Icon Size", options=["Small", "Normal"], group=groupDisplay)
showSecondSignalOnChart = input.bool(true, "Show Second Signal on Price Chart", group=groupDisplay)
highlightMode = input.string("RSI Pane Only", "Highlight From First Extreme", options=["Off", "RSI Pane Only", "RSI Pane + Chart"], group=groupDisplay, tooltip="Backlight from the first extreme (when the setup arms) until the second signal or abort. RSI Pane = indicator only. RSI Pane + Chart = also on price.")
//====================================================
// RSI
//====================================================
rsi = ta.rsi(rsiSource, rsiLength)
plot(rsi, title="RSI", color=color.rgb(105, 145, 255), linewidth=2)
hline(upperExtreme, "Upper Extreme", color=color.red, linestyle=hline.style_dashed)
hline(lowerExtreme, "Lower Extreme", color=color.lime, linestyle=hline.style_dashed)
hline(upperCoolLevel, "Upper Cooling Level", color=color.new(color.red, 55), linestyle=hline.style_dotted)
hline(lowerCoolLevel, "Lower Cooling Level", color=color.new(color.lime, 55), linestyle=hline.style_dotted)
hline(upperRetestMin, "Second Peak Re-Entry Min", color=color.new(color.red, 70), linestyle=hline.style_dotted)
hline(lowerRetestMax, "Second Bottom Re-Entry Max", color=color.new(color.lime, 70), linestyle=hline.style_dotted)
plot(useMidlineAbort ? bearishAbortLevel : na, "Bearish Abort", color=color.new(color.orange, 55), linewidth=1, style=plot.style_line)
plot(useMidlineAbort ? bullishAbortLevel : na, "Bullish Abort", color=color.new(color.teal, 55), linewidth=1, style=plot.style_line)
//====================================================
// HELPER FUNCTIONS
//====================================================
isFallingForBars(float source, int bars) =>
    bool result = true
    for index = 0 to bars - 1
        result := result and source[index] < source[index + 1]
    result
isRisingForBars(float source, int bars) =>
    bool result = true
    for index = 0 to bars - 1
        result := result and source[index] > source[index + 1]
    result
isLocalPeak(float source, int strength) =>
    bool result = true
    for index = 0 to strength - 1
        result := result and source[strength] > source[index]
    for index = strength + 1 to strength + strength
        result := result and source[strength] >= source[index]
    result
isLocalBottom(float source, int strength) =>
    bool result = true
    for index = 0 to strength - 1
        result := result and source[strength] < source[index]
    for index = strength + 1 to strength + strength
        result := result and source[strength] <= source[index]
    result
bool useSmallIcons = iconSizeMode == "Small"
bool useNormalIcons = iconSizeMode == "Normal"
//====================================================
// STATE VARIABLES
//====================================================
var int sellState = 0
var int buyState = 0
var float firstSellPeak = na
var float firstBuyBottom = na
var float secondSellPeak = na
var float secondBuyBottom = na
var int secondSellPeakBar = na
var int secondBuyBottomBar = na
var int sellSetupStartBar = na
var int buySetupStartBar = na
bool firstSellSignal = false
bool firstBuySignal = false
bool secondSellSignal = false
bool secondBuySignal = false
bool sellAborted = false
bool buyAborted = false
bool processBar = requireBarClose ? barstate.isconfirmed : true
//====================================================
// CONDITIONS
//====================================================
bool sellCooled = rsi <= upperCoolLevel and rsi < upperRetestMin
bool buyCooled = rsi >= lowerCoolLevel and rsi > lowerRetestMax
float secondPeakValue = rsi[peakStrength]
float secondBottomValue = rsi[peakStrength]
bool secondPeakReEntered = secondPeakValue >= upperRetestMin
bool secondBottomReEntered = secondBottomValue <= lowerRetestMax
bool validLowerHigh = not na(firstSellPeak) and secondPeakValue <= firstSellPeak - minLowerHighGap
bool validHigherLow = not na(firstBuyBottom) and secondBottomValue >= firstBuyBottom + minLowerHighGap
bool bearishLocalPeak = isLocalPeak(rsi, peakStrength)
bool bullishLocalBottom = isLocalBottom(rsi, peakStrength)
//====================================================
// MAIN LOGIC
//====================================================
if processBar
    firstSellSignal := false
    firstBuySignal := false
    secondSellSignal := false
    secondBuySignal := false
    sellAborted := false
    buyAborted := false
    if rsi <= lowerExtreme and sellState > 0
        sellState := 0
        firstSellPeak := na
        secondSellPeak := na
        secondSellPeakBar := na
        sellSetupStartBar := na
        sellAborted := true
    if rsi >= upperExtreme and buyState > 0
        buyState := 0
        firstBuyBottom := na
        secondBuyBottom := na
        secondBuyBottomBar := na
        buySetupStartBar := na
        buyAborted := true
    if sellState > 0
        bool sellMidAbort = useMidlineAbort and rsi <= bearishAbortLevel
        bool sellTimeAbort = maxSearchBars > 0 and not na(sellSetupStartBar) and (bar_index - sellSetupStartBar) >= maxSearchBars
        if sellMidAbort or sellTimeAbort
            sellState := 0
            firstSellPeak := na
            secondSellPeak := na
            secondSellPeakBar := na
            sellSetupStartBar := na
            sellAborted := true
    if buyState > 0
        bool buyMidAbort = useMidlineAbort and rsi >= bullishAbortLevel
        bool buyTimeAbort = maxSearchBars > 0 and not na(buySetupStartBar) and (bar_index - buySetupStartBar) >= maxSearchBars
        if buyMidAbort or buyTimeAbort
            buyState := 0
            firstBuyBottom := na
            secondBuyBottom := na
            secondBuyBottomBar := na
            buySetupStartBar := na
            buyAborted := true
    if sellState == 0
        if rsi >= upperExtreme
            sellState := 1
            firstSellPeak := rsi
            secondSellPeak := na
            secondSellPeakBar := na
            sellSetupStartBar := bar_index
            firstSellSignal := true
    else if sellState == 1
        if rsi > firstSellPeak
            firstSellPeak := rsi
        if sellCooled
            sellState := 2
            secondSellPeak := na
            secondSellPeakBar := na
    else if sellState == 2
        if rsi > firstSellPeak + peakTolerance
            firstSellPeak := rsi
            sellState := 1
            secondSellPeak := na
            secondSellPeakBar := na
            sellSetupStartBar := bar_index
            firstSellSignal := true
        else if bearishLocalPeak and secondPeakReEntered and validLowerHigh
            secondSellPeak := secondPeakValue
            secondSellPeakBar := bar_index - peakStrength
            sellState := 3
    else if sellState == 3
        if bearishLocalPeak and secondPeakReEntered and validLowerHigh and secondPeakValue > secondSellPeak
            secondSellPeak := secondPeakValue
            secondSellPeakBar := bar_index - peakStrength
        if rsi > firstSellPeak + peakTolerance
            firstSellPeak := rsi
            secondSellPeak := na
            secondSellPeakBar := na
            sellState := 1
            sellSetupStartBar := bar_index
            firstSellSignal := true
        else
            bool confirmSell = isFallingForBars(rsi, confirmBars)
            if confirmSell and bar_index > secondSellPeakBar
                secondSellSignal := true
                if rsi >= upperExtreme
                    sellState := 1
                    firstSellPeak := rsi
                    sellSetupStartBar := bar_index
                else
                    sellState := 0
                    firstSellPeak := na
                    sellSetupStartBar := na
                secondSellPeak := na
                secondSellPeakBar := na
    if buyState == 0
        if rsi <= lowerExtreme
            buyState := 1
            firstBuyBottom := rsi
            secondBuyBottom := na
            secondBuyBottomBar := na
            buySetupStartBar := bar_index
            firstBuySignal := true
    else if buyState == 1
        if rsi < firstBuyBottom
            firstBuyBottom := rsi
        if buyCooled
            buyState := 2
            secondBuyBottom := na
            secondBuyBottomBar := na
    else if buyState == 2
        if rsi < firstBuyBottom - peakTolerance
            firstBuyBottom := rsi
            buyState := 1
            secondBuyBottom := na
            secondBuyBottomBar := na
            buySetupStartBar := bar_index
            firstBuySignal := true
        else if bullishLocalBottom and secondBottomReEntered and validHigherLow
            secondBuyBottom := secondBottomValue
            secondBuyBottomBar := bar_index - peakStrength
            buyState := 3
    else if buyState == 3
        if bullishLocalBottom and secondBottomReEntered and validHigherLow and secondBottomValue < secondBuyBottom
            secondBuyBottom := secondBottomValue
            secondBuyBottomBar := bar_index - peakStrength
        if rsi < firstBuyBottom - peakTolerance
            firstBuyBottom := rsi
            secondBuyBottom := na
            secondBuyBottomBar := na
            buyState := 1
            buySetupStartBar := bar_index
            firstBuySignal := true
        else
            bool confirmBuy = isRisingForBars(rsi, confirmBars)
            if confirmBuy and bar_index > secondBuyBottomBar
                secondBuySignal := true
                if rsi <= lowerExtreme
                    buyState := 1
                    firstBuyBottom := rsi
                    buySetupStartBar := bar_index
                else
                    buyState := 0
                    firstBuyBottom := na
                    buySetupStartBar := na
                secondBuyBottom := na
                secondBuyBottomBar := na
//====================================================
// BODY BEYOND LINE
//====================================================
bodyBelowLinePercent(float lineValue) =>
    float bodyHigh = math.max(open, close)
    float bodyLow = math.min(open, close)
    float bodySize = bodyHigh - bodyLow
    float belowPart = bodySize > 0.0 ? math.max(0.0, math.min(bodyHigh, lineValue) - bodyLow) : 0.0
    bodySize > 0.0 ? belowPart / bodySize * 100.0 : 0.0
bodyAboveLinePercent(float lineValue) =>
    float bodyHigh = math.max(open, close)
    float bodyLow = math.min(open, close)
    float bodySize = bodyHigh - bodyLow
    float abovePart = bodySize > 0.0 ? math.max(0.0, bodyHigh - math.max(bodyLow, lineValue)) : 0.0
    bodySize > 0.0 ? abovePart / bodySize * 100.0 : 0.0
//====================================================
// PRICE ENTRY — Fast only
// Candle N: body is beyond EMA / Kijun / …  → arm only, no arrow.
// Candle N+1: hollow arrow + markup from OPEN.
//====================================================
float tightStopAtr = 2.0
float minStopRisk = math.max(nz(entryATR, 0.0) * 0.50, syminfo.mintick * 3.0)
drawTinyProfitCorner(int bar, float target, color col, string lineStyle, bool isLong) =>
    float h = math.max(syminfo.mintick * 8.0, nz(entryATR, syminfo.mintick) * 0.10)
    float yStem = isLong ? target - h : target + h
    line.new(x1=bar, y1=yStem, x2=bar, y2=target, xloc=xloc.bar_index, extend=extend.none, color=col, style=lineStyle, width=2, force_overlay=true)
    line.new(x1=bar, y1=target, x2=bar + 1, y2=target, xloc=xloc.bar_index, extend=extend.none, color=col, style=lineStyle, width=2, force_overlay=true)
var int shortEntryState = 0
var int longEntryState = 0
var int shortEntryStartBar = na
var int longEntryStartBar = na
bool confirmedShortEntry = false
bool confirmedLongEntry = false
var float confirmedShortEntryPrice = na
var float confirmedLongEntryPrice = na
var bool shortRangeActive = false
var bool longRangeActive = false
var int shortSignalBar = na
var int longSignalBar = na
var float shortRangeHigh = na
var float longRangeLow = na
var int shortRangeHighBar = na
var int longRangeLowBar = na
var int tradeShortEntryBar = na
var float tradeShortEntryPrice = na
var int tradeShortTriangleBar = na
var float tradeShortStop = na
var int tradeShortStopBar = na
var bool tradeShortStopReady = false
var bool shortMarkupWaitOpen = false
var int shortWaitOpenFromBar = na
var int tradeLongEntryBar = na
var float tradeLongEntryPrice = na
var int tradeLongTriangleBar = na
var float tradeLongStop = na
var int tradeLongStopBar = na
var bool tradeLongStopReady = false
var bool longMarkupWaitOpen = false
var int longWaitOpenFromBar = na
if processBar
    confirmedShortEntry := false
    confirmedLongEntry := false
    confirmedShortEntryPrice := na
    confirmedLongEntryPrice := na
    // Open the trade FIRST, before a new RSI signal can cancel the wait.
    if shortMarkupWaitOpen and not na(shortWaitOpenFromBar) and bar_index > shortWaitOpenFromBar
        tradeShortEntryBar := bar_index
        tradeShortEntryPrice := open
        confirmedShortEntry := true
        confirmedShortEntryPrice := open
        if na(tradeShortStop) or not (tradeShortStop > tradeShortEntryPrice + minStopRisk)
            tradeShortStop := tradeShortEntryPrice + nz(entryATR, 0.0) * tightStopAtr
            tradeShortStopBar := bar_index
        tradeShortStopReady := true
        shortMarkupWaitOpen := false
        shortWaitOpenFromBar := na
    if longMarkupWaitOpen and not na(longWaitOpenFromBar) and bar_index > longWaitOpenFromBar
        tradeLongEntryBar := bar_index
        tradeLongEntryPrice := open
        confirmedLongEntry := true
        confirmedLongEntryPrice := open
        if na(tradeLongStop) or not (tradeLongStop < tradeLongEntryPrice - minStopRisk)
            tradeLongStop := tradeLongEntryPrice - nz(entryATR, 0.0) * tightStopAtr
            tradeLongStopBar := bar_index
        tradeLongStopReady := true
        longMarkupWaitOpen := false
        longWaitOpenFromBar := na
    if secondSellSignal
        shortEntryStartBar := useEntryConfirmation ? bar_index : na
        shortEntryState := useEntryConfirmation ? 1 : 0
        shortRangeActive := useEntryConfirmation
        shortSignalBar := useEntryConfirmation ? bar_index : na
        shortRangeHigh := useEntryConfirmation ? high : na
        shortRangeHighBar := useEntryConfirmation ? bar_index : na
        shortMarkupWaitOpen := false
        shortWaitOpenFromBar := na
    if secondBuySignal
        longEntryStartBar := useEntryConfirmation ? bar_index : na
        longEntryState := useEntryConfirmation ? 1 : 0
        longRangeActive := useEntryConfirmation
        longSignalBar := useEntryConfirmation ? bar_index : na
        longRangeLow := useEntryConfirmation ? low : na
        longRangeLowBar := useEntryConfirmation ? bar_index : na
        longMarkupWaitOpen := false
        longWaitOpenFromBar := na
    if shortRangeActive
        if na(shortRangeHigh) or high >= shortRangeHigh
            shortRangeHigh := high
            shortRangeHighBar := bar_index
    if longRangeActive
        if na(longRangeLow) or low <= longRangeLow
            longRangeLow := low
            longRangeLowBar := bar_index
    if shortEntryState > 0 and not na(shortEntryStartBar) and bar_index - shortEntryStartBar > entryWindowBars
        shortEntryState := 0
        shortEntryStartBar := na
    if longEntryState > 0 and not na(longEntryStartBar) and bar_index - longEntryStartBar > entryWindowBars
        longEntryState := 0
        longEntryStartBar := na
    // SHORT: first candle with enough BODY below the line. Color does not matter.
    // Do not draw here — wait for the next open.
    if shortEntryState > 0 and bodyBelowLinePercent(entryLine) >= fastBodyPercent
        tradeShortTriangleBar := shortSignalBar
        tradeShortStop := shortRangeHigh
        tradeShortStopBar := shortRangeHighBar
        shortMarkupWaitOpen := true
        shortWaitOpenFromBar := bar_index
        shortRangeActive := false
        shortSignalBar := na
        shortRangeHigh := na
        shortRangeHighBar := na
        shortEntryState := 0
        shortEntryStartBar := na
    // LONG: first candle with enough BODY above the line. Color does not matter.
    if longEntryState > 0 and bodyAboveLinePercent(entryLine) >= fastBodyPercent
        tradeLongTriangleBar := longSignalBar
        tradeLongStop := longRangeLow
        tradeLongStopBar := longRangeLowBar
        longMarkupWaitOpen := true
        longWaitOpenFromBar := bar_index
        longRangeActive := false
        longSignalBar := na
        longRangeLow := na
        longRangeLowBar := na
        longEntryState := 0
        longEntryStartBar := na
//====================================================
// DISPLAY
//====================================================
bool showFirstSignals = signalDisplay == "First Signal Only" or signalDisplay == "Both"
bool showSecondSignals = signalDisplay == "Second Signal Only" or signalDisplay == "Both"
bool sellActive = sellState > 0
bool buyActive = buyState > 0
bool highlightPane = highlightMode == "RSI Pane Only" or highlightMode == "RSI Pane + Chart"
bool highlightChart = highlightMode == "RSI Pane + Chart"
plot(sellActive ? firstSellPeak - minLowerHighGap : na, "Max Allowed Second Peak", color=color.new(color.red, 40), linewidth=1, style=plot.style_linebr)
plot(buyActive ? firstBuyBottom + minLowerHighGap : na, "Min Allowed Second Bottom", color=color.new(color.lime, 40), linewidth=1, style=plot.style_linebr)
bgcolor(highlightPane and sellActive ? color.new(color.red, 90) : na, title="Bearish Setup (RSI)")
bgcolor(highlightPane and buyActive ? color.new(color.green, 90) : na, title="Bullish Setup (RSI)")
bgcolor(highlightChart and sellActive ? color.new(color.red, 92) : na, title="Bearish Setup (Chart)", force_overlay=true)
bgcolor(highlightChart and buyActive ? color.new(color.green, 92) : na, title="Bullish Setup (Chart)", force_overlay=true)
plotshape(showFirstSignals and useSmallIcons and firstSellSignal ? rsi : na, title="First Bearish Signal Small", style=shape.circle, location=location.absolute, color=color.red, size=size.tiny)
plotshape(showFirstSignals and useNormalIcons and firstSellSignal ? rsi : na, title="First Bearish Signal Normal", style=shape.circle, location=location.absolute, color=color.red, size=size.small)
plotshape(showFirstSignals and useSmallIcons and firstBuySignal ? rsi : na, title="First Bullish Signal Small", style=shape.circle, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(showFirstSignals and useNormalIcons and firstBuySignal ? rsi : na, title="First Bullish Signal Normal", style=shape.circle, location=location.absolute, color=color.lime, size=size.small)
plotshape(showSecondSignals and useSmallIcons and secondSellSignal ? rsi : na, title="Second Bearish Signal Small", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny)
plotshape(showSecondSignals and useNormalIcons and secondSellSignal ? rsi : na, title="Second Bearish Signal Normal", style=shape.triangledown, location=location.absolute, color=color.red, size=size.small)
plotshape(showSecondSignals and useSmallIcons and secondBuySignal ? rsi : na, title="Second Bullish Signal Small", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(showSecondSignals and useNormalIcons and secondBuySignal ? rsi : na, title="Second Bullish Signal Normal", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.small)
plotshape(showSecondSignals and showSecondSignalOnChart and useSmallIcons and secondSellSignal, title="Second Bearish on Chart Small", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, force_overlay=true)
plotshape(showSecondSignals and showSecondSignalOnChart and useNormalIcons and secondSellSignal, title="Second Bearish on Chart Normal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, force_overlay=true)
plotshape(showSecondSignals and showSecondSignalOnChart and useSmallIcons and secondBuySignal, title="Second Bullish on Chart Small", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny, force_overlay=true)
plotshape(showSecondSignals and showSecondSignalOnChart and useNormalIcons and secondBuySignal, title="Second Bullish on Chart Normal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, force_overlay=true)
plot(useEntryConfirmation ? entryLine : na, title="Entry Confirmation Line", color=entryLineColor, linewidth=2, force_overlay=true)
if useEntryConfirmation and confirmedLongEntry
    label.new(x=bar_index, y=low, text="⇧", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_none, textcolor=entryBullColor, size=useNormalIcons ? size.large : size.normal, force_overlay=true)
if useEntryConfirmation and confirmedShortEntry
    float shortArrowY = high + entryATR * 0.45
    label.new(x=bar_index, y=shortArrowY, text="⇩", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBearColor, size=useNormalIcons ? size.large : size.normal, force_overlay=true)
if useEntryConfirmation and showTradeParameters and tradeShortStopReady and not na(tradeShortEntryBar) and not na(tradeShortEntryPrice) and not na(tradeShortStop)
    float shortRisk = tradeShortStop - tradeShortEntryPrice
    if shortRisk > syminfo.mintick
        float shortTP1 = tradeShortEntryPrice - shortRisk
        float shortTP2 = tradeShortEntryPrice - shortRisk * 2.0
        int shortStopX1 = not na(tradeShortStopBar) ? tradeShortStopBar : nz(tradeShortTriangleBar, tradeShortEntryBar)
        line.new(x1=shortStopX1, y1=tradeShortStop, x2=tradeShortEntryBar + tradeProjectionBars, y2=tradeShortStop, xloc=xloc.bar_index, extend=extend.none, color=entryBearColor, style=line.style_solid, width=1, force_overlay=true)
        label.new(x=tradeShortEntryBar + tradeProjectionBars, y=tradeShortStop, text="Stop Loss", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBearColor, size=size.small, force_overlay=true)
        line.new(x1=tradeShortEntryBar, y1=shortTP1, x2=tradeShortEntryBar + tradeProjectionBars, y2=shortTP1, xloc=xloc.bar_index, extend=extend.none, color=entryBearColor, style=line.style_solid, width=1, force_overlay=true)
        line.new(x1=tradeShortEntryBar, y1=tradeShortEntryPrice, x2=tradeShortEntryBar, y2=shortTP1, xloc=xloc.bar_index, extend=extend.none, color=entryBearColor, style=line.style_solid, width=1, force_overlay=true)
        drawTinyProfitCorner(tradeShortEntryBar, shortTP1, entryBearColor, line.style_solid, false)
        label.new(x=tradeShortEntryBar + 2, y=shortTP1, text="1R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBearColor, size=size.small, force_overlay=true)
        line.new(x1=tradeShortEntryBar, y1=shortTP2, x2=tradeShortEntryBar + tradeProjectionBars, y2=shortTP2, xloc=xloc.bar_index, extend=extend.none, color=entryBearColor, style=line.style_dashed, width=1, force_overlay=true)
        line.new(x1=tradeShortEntryBar + 1, y1=tradeShortEntryPrice, x2=tradeShortEntryBar + 1, y2=shortTP2, xloc=xloc.bar_index, extend=extend.none, color=entryBearColor, style=line.style_dashed, width=1, force_overlay=true)
        drawTinyProfitCorner(tradeShortEntryBar + 1, shortTP2, entryBearColor, line.style_dashed, false)
        label.new(x=tradeShortEntryBar + 3, y=shortTP2, text="2R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBearColor, size=size.small, force_overlay=true)
    tradeShortEntryBar := na
    tradeShortEntryPrice := na
    tradeShortTriangleBar := na
    tradeShortStop := na
    tradeShortStopBar := na
    tradeShortStopReady := false
if useEntryConfirmation and showTradeParameters and tradeLongStopReady and not na(tradeLongEntryBar) and not na(tradeLongEntryPrice) and not na(tradeLongStop)
    float longRisk = tradeLongEntryPrice - tradeLongStop
    if longRisk > syminfo.mintick
        float longTP1 = tradeLongEntryPrice + longRisk
        float longTP2 = tradeLongEntryPrice + longRisk * 2.0
        int longStopX1 = not na(tradeLongStopBar) ? tradeLongStopBar : nz(tradeLongTriangleBar, tradeLongEntryBar)
        line.new(x1=longStopX1, y1=tradeLongStop, x2=tradeLongEntryBar + tradeProjectionBars, y2=tradeLongStop, xloc=xloc.bar_index, extend=extend.none, color=entryBullColor, style=line.style_solid, width=1, force_overlay=true)
        label.new(x=tradeLongEntryBar + tradeProjectionBars, y=tradeLongStop, text="Stop Loss", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBullColor, size=size.small, force_overlay=true)
        line.new(x1=tradeLongEntryBar, y1=longTP1, x2=tradeLongEntryBar + tradeProjectionBars, y2=longTP1, xloc=xloc.bar_index, extend=extend.none, color=entryBullColor, style=line.style_solid, width=1, force_overlay=true)
        line.new(x1=tradeLongEntryBar, y1=tradeLongEntryPrice, x2=tradeLongEntryBar, y2=longTP1, xloc=xloc.bar_index, extend=extend.none, color=entryBullColor, style=line.style_solid, width=1, force_overlay=true)
        drawTinyProfitCorner(tradeLongEntryBar, longTP1, entryBullColor, line.style_solid, true)
        label.new(x=tradeLongEntryBar + 2, y=longTP1, text="1R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBullColor, size=size.small, force_overlay=true)
        line.new(x1=tradeLongEntryBar, y1=longTP2, x2=tradeLongEntryBar + tradeProjectionBars, y2=longTP2, xloc=xloc.bar_index, extend=extend.none, color=entryBullColor, style=line.style_dashed, width=1, force_overlay=true)
        line.new(x1=tradeLongEntryBar + 1, y1=tradeLongEntryPrice, x2=tradeLongEntryBar + 1, y2=longTP2, xloc=xloc.bar_index, extend=extend.none, color=entryBullColor, style=line.style_dashed, width=1, force_overlay=true)
        drawTinyProfitCorner(tradeLongEntryBar + 1, longTP2, entryBullColor, line.style_dashed, true)
        label.new(x=tradeLongEntryBar + 3, y=longTP2, text="2R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=entryBullColor, size=size.small, force_overlay=true)
    tradeLongEntryBar := na
    tradeLongEntryPrice := na
    tradeLongTriangleBar := na
    tradeLongStop := na
    tradeLongStopBar := na
    tradeLongStopReady := false
plot(sellState, title="Sell State", display=display.data_window)
plot(buyState, title="Buy State", display=display.data_window)
plot(firstSellPeak, title="First Sell Peak", display=display.data_window)
plot(firstBuyBottom, title="First Buy Bottom", display=display.data_window)
alertcondition(secondSellSignal, title="Bearish RSI Retest Signal", message="RSI Retest Fast: bearish RSI retest signal.")
alertcondition(secondBuySignal, title="Bullish RSI Retest Signal", message="RSI Retest Fast: bullish RSI retest signal.")
alertcondition(confirmedShortEntry, title="Confirmed Short Entry", message="RSI Retest Fast: confirmed SHORT entry.")
alertcondition(confirmedLongEntry, title="Confirmed Long Entry", message="RSI Retest Fast: confirmed LONG entry.")
````
