<!-- tradingview-pine-id: PUB;9b9721cb58d44d8183e05f1044f2bb11 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Impulse Candle Acceptance Guard

Source: https://www.tradingview.com/script/G0S8oBrv/

## Description

A large candle is easy to spot. The harder question is whether the market accepts it.

Impulse Candle Acceptance Guard follows unusually forceful candles through a defined sequence: detection, continued holding, efficient extension, rejection, full reversal, or an unresolved timeout. It freezes the original candle’s range and ATR reference so later price action is judged against the event that started the observation.

VISUAL GUIDE

• I+ / I− — A bullish or bearish impulse candle entered observation.
• Teal or red zone — The frozen high-low range of the impulse candle.
• Orange line — The acceptance and rejection boundary inside the frozen range.
• Blue line — The minimum extension required beyond the impulse candle.
• A+ / A− — The move satisfied the hold, extension, and path-efficiency rules.
• R — A confirmed close crossed the acceptance line against the impulse.
• X — A confirmed close crossed the opposite edge of the entire impulse candle.
• T — The observation window ended without another terminal result.

The script is intentionally chart-first: it uses no table and has no dependency on another indicator.

1 — DETECT THE IMPULSE

The default setup requires the candle’s range to reach at least 1.5 times the ATR measured on the previous completed bar. Its real body must occupy at least 60% of the candle’s range, and the close must finish within the outer 20% in the direction of the move. Zero-range candles cannot qualify.

An optional volume filter requires current volume to exceed a configurable multiple of its moving average. It is disabled by default so the script also remains usable on symbols without meaningful volume data.

2 — FREEZE THE EVENT

At the confirmed close of a qualifying candle, the script freezes the impulse high, low and close; ATR from the bar immediately before the impulse; the acceptance line inside the impulse range; and the required extension beyond the impulse extreme. These levels remain fixed throughout the observation. Only one episode can be active at a time.

3 — MEASURE ACCEPTANCE

Acceptance requires all three default conditions:

1. Two consecutive closes remain beyond the orange acceptance line in the impulse direction.
2. Price reaches at least 0.25 frozen ATR beyond the impulse high or low.
3. Follow-through efficiency is at least 45%.

Follow-through efficiency compares directional progress from the impulse close with the cumulative close-to-close path traveled after it:

efficiency = max(0, directional progress) ÷ cumulative path × 100

A direct continuation produces a high value. Repeated back-and-forth movement increases the path without producing equal progress and lowers the value. The efficiency value is available in TradingView’s Data Window while an episode is active.

WORKED EXAMPLE

Assume a bullish impulse has a low of 100, a high of 110, a close of 109, and a frozen ATR of 4.

• Acceptance line: 100 + 50% × (110 − 100) = 105
• Required extension: 110 + 0.25 × 4 = 111

If the next two candles close above 105, price reaches 111, and directional progress represents at least 45% of the traveled path, A+ is printed. A close below 105 produces R. A close below 100 produces X and takes priority over the ordinary rejection label.

EVENT PRIORITY AND CONFIRMED-BAR BEHAVIOR

Full reversal has first priority, followed by acceptance-line rejection, acceptance, and timeout. An otherwise valid acceptance on the final permitted bar is recorded before timeout. Wicks alone do not reject or fully reverse an episode; those outcomes require confirmed closes.

Markers and state transitions update only after a candle closes. The script uses no future bars, pivot backdating, or lookahead requests.

USAGE AND LIMITATIONS

The mirrored rules operate on bullish and bearish candles across stocks, cryptocurrencies, futures, and forex. Use standard candles when interpreting the price-based rules. Thresholds describe a rule set rather than probabilities, and their meaning changes with symbol and timeframe.

Acceptance means that the specified conditions were observed; it does not guarantee continued movement or establish a profitable strategy. The indicator does not place trades, calculate position sizes, or model fees, slippage, gaps, liquidity, or execution. Historical results can change when settings, available history, or source data change.

BotTradeLab — Human judgment, AI-assisted analysis.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BotTradeLab
//@version=6
indicator("Impulse Candle Acceptance Guard", shorttitle="Impulse Acceptance Guard", overlay=true, precision=2)

const string G_DETECT = "Impulse detection"
const string G_GUARD = "Acceptance guard"
const string G_DISPLAY = "Display"

atrLen = input.int(14, "ATR length", minval=2, group=G_DETECT)
minRangeAtr = input.float(1.50, "Minimum candle range (ATR)", minval=0.50, step=0.05, group=G_DETECT)
minBodyPercent = input.float(60.0, "Minimum body / range (%)", minval=10.0, maxval=100.0, step=5.0, group=G_DETECT)
extremePercent = input.float(20.0, "Close must finish within extreme (%)", minval=1.0, maxval=50.0, step=1.0, group=G_DETECT)
useVolumeFilter = input.bool(false, "Require elevated volume", group=G_DETECT)
volumeLen = input.int(20, "Volume average length", minval=2, group=G_DETECT)
minRelativeVolume = input.float(1.20, "Minimum relative volume", minval=0.10, step=0.05, group=G_DETECT)

windowBars = input.int(5, "Observation window (bars)", minval=2, maxval=30, group=G_GUARD)
holdFraction = input.float(0.50, "Acceptance line inside impulse range", minval=0.10, maxval=0.90, step=0.05, group=G_GUARD, tooltip="For a bullish impulse, 0.50 places the acceptance line halfway from the frozen low to the high. Bearish logic is mirrored.")
requiredHoldCloses = input.int(2, "Consecutive closes beyond acceptance line", minval=1, maxval=10, group=G_GUARD)
minExtensionAtr = input.float(0.25, "Minimum extension beyond impulse (ATR)", minval=0.0, step=0.05, group=G_GUARD)
minEfficiency = input.float(45.0, "Minimum follow-through efficiency (%)", minval=0.0, maxval=100.0, step=5.0, group=G_GUARD)

showRange = input.bool(true, "Show active impulse range", group=G_DISPLAY)
showBackground = input.bool(true, "Shade active observation", group=G_DISPLAY)
showMarkers = input.bool(true, "Show event markers", group=G_DISPLAY)

float atr = ta.atr(atrLen)
float frozenAtrCandidate = atr[1]
float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyPercent = candleRange > 0 ? candleBody / candleRange * 100.0 : 0.0
float closeLocation = candleRange > 0 ? (close - low) / candleRange : 0.5
float avgVolume = ta.sma(volume, volumeLen)
float relativeVolume = not na(avgVolume) and avgVolume > 0 ? volume / avgVolume : na
bool volumePass = not useVolumeFilter or not na(relativeVolume) and relativeVolume >= minRelativeVolume
bool ready = bar_index > math.max(atrLen, useVolumeFilter ? volumeLen : atrLen) and not na(frozenAtrCandidate) and frozenAtrCandidate > 0
bool rangePass = ready and candleRange >= minRangeAtr * frozenAtrCandidate
bool bodyPass = bodyPercent >= minBodyPercent
bool bullishImpulse = rangePass and bodyPass and volumePass and close > open and closeLocation >= 1.0 - extremePercent / 100.0
bool bearishImpulse = rangePass and bodyPass and volumePass and close < open and closeLocation <= extremePercent / 100.0

var bool active = false
var int direction = 0
var int impulseBar = na
var float impulseHigh = na
var float impulseLow = na
var float impulseClose = na
var float frozenAtr = na
var float acceptanceLine = na
var float extensionLine = na
var float cumulativePath = na
var float maxProgress = na
var int holdStreak = 0
var float lastEfficiency = na

bool startedBull = false
bool startedBear = false
bool acceptedBull = false
bool acceptedBear = false
bool rejected = false
bool fullyReversed = false
bool timedOut = false

if barstate.isconfirmed
    bool wasActive = active
    if wasActive
        int age = bar_index - impulseBar
        float stepPath = math.abs(close - close[1])
        cumulativePath += na(stepPath) ? 0.0 : stepPath
        float progress = direction == 1 ? close - impulseClose : impulseClose - close
        maxProgress := math.max(maxProgress, progress)
        lastEfficiency := cumulativePath > 0 ? math.max(0.0, progress) / cumulativePath * 100.0 : 0.0
        bool holds = direction == 1 ? close > acceptanceLine : close < acceptanceLine
        holdStreak := holds ? holdStreak + 1 : 0
        bool reverseBreak = direction == 1 ? close < impulseLow : close > impulseHigh
        bool midpointReject = direction == 1 ? close < acceptanceLine : close > acceptanceLine
        bool extended = direction == 1 ? high >= extensionLine : low <= extensionLine
        bool acceptedNow = age >= requiredHoldCloses and holdStreak >= requiredHoldCloses and extended and lastEfficiency >= minEfficiency
        if reverseBreak
            active := false
            fullyReversed := true
        else if midpointReject
            active := false
            rejected := true
        else if acceptedNow
            active := false
            acceptedBull := direction == 1
            acceptedBear := direction == -1
        else if age >= windowBars
            active := false
            timedOut := true
    else if bullishImpulse or bearishImpulse
        active := true
        direction := bullishImpulse ? 1 : -1
        impulseBar := bar_index
        impulseHigh := high
        impulseLow := low
        impulseClose := close
        frozenAtr := frozenAtrCandidate
        acceptanceLine := direction == 1 ? impulseLow + holdFraction * candleRange : impulseHigh - holdFraction * candleRange
        extensionLine := direction == 1 ? impulseHigh + minExtensionAtr * frozenAtr : impulseLow - minExtensionAtr * frozenAtr
        cumulativePath := 0.0
        maxProgress := 0.0
        holdStreak := 0
        lastEfficiency := na
        startedBull := direction == 1
        startedBear := direction == -1

bool showEpisode = active or startedBull or startedBear or acceptedBull or acceptedBear or rejected or fullyReversed or timedOut
color directionColor = direction == 1 ? color.teal : color.red
float rangeTop = showRange and showEpisode ? impulseHigh : na
float rangeBottom = showRange and showEpisode ? impulseLow : na

pTop = plot(rangeTop, "Frozen impulse high", color=color.new(directionColor, 30), linewidth=1, style=plot.style_linebr)
pBottom = plot(rangeBottom, "Frozen impulse low", color=color.new(directionColor, 30), linewidth=1, style=plot.style_linebr)
plot(showRange and showEpisode ? acceptanceLine : na, "Acceptance / rejection line", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(showRange and showEpisode ? extensionLine : na, "Required extension", color=color.new(color.blue, 15), linewidth=1, style=plot.style_linebr)
fill(pTop, pBottom, color=showRange and showEpisode ? color.new(directionColor, 91) : na, title="Impulse range")
bgcolor(showBackground and active ? color.new(directionColor, 94) : na, title="Active observation")

plotshape(showMarkers and startedBull, title="Bullish impulse", text="I+", style=shape.labelup, location=location.belowbar, color=color.teal, textcolor=color.white, size=size.tiny)
plotshape(showMarkers and startedBear, title="Bearish impulse", text="I−", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)
plotshape(showMarkers and acceptedBull, title="Bullish impulse accepted", text="A+", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(showMarkers and acceptedBear, title="Bearish impulse accepted", text="A−", style=shape.labeldown, location=location.abovebar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(showMarkers and rejected, title="Impulse rejected", text="R", style=shape.xcross, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(showMarkers and fullyReversed, title="Impulse fully reversed", text="X", style=shape.xcross, location=location.abovebar, color=color.fuchsia, size=size.small)
plotshape(showMarkers and timedOut, title="Observation ended", text="T", style=shape.square, location=location.abovebar, color=color.gray, size=size.tiny)

plot(active ? lastEfficiency : na, "Follow-through efficiency (%)", display=display.data_window)
plot(active ? relativeVolume : na, "Relative volume", display=display.data_window)
plot(active ? bar_index - impulseBar : na, "Observation age", display=display.data_window)

alertcondition(startedBull, "Bullish impulse detected", "A bullish impulse candle entered observation on {{ticker}}.")
alertcondition(startedBear, "Bearish impulse detected", "A bearish impulse candle entered observation on {{ticker}}.")
alertcondition(acceptedBull, "Bullish impulse accepted", "The bullish impulse met the hold, extension and efficiency rules on {{ticker}}.")
alertcondition(acceptedBear, "Bearish impulse accepted", "The bearish impulse met the hold, extension and efficiency rules on {{ticker}}.")
alertcondition(rejected, "Impulse rejected", "Price closed through the frozen acceptance line on {{ticker}}.")
alertcondition(fullyReversed, "Impulse fully reversed", "Price closed beyond the opposite edge of the impulse candle on {{ticker}}.")
alertcondition(timedOut, "Impulse observation ended", "The impulse did not reach a terminal condition within the observation window on {{ticker}}.")
````
