# QuantLine Auction State Engine

- url: https://www.tradingview.com/script/rokjc7a8-QuantLine-Auction-State-Engine/
- type: indicator
- pine_id: PUB;c2970b93d02245eb80d903939c18e939
- version: 4.0

## Description

QuantLine Auction State Engine asks one question: what is price doing with the
edge of its prior range?

Many breakout tools mark the first trade above a rolling high or below a rolling
low. That does not distinguish a wick from acceptance, and the rolling level can
move while the event is still being judged. This script separates the process
into explicit states and locks the point-in-time range when a test begins.

States

- BAL — price remains in balance inside the prior range.
- CMP — balance with low ATR percentile: potential energy, no direction.
- T↑ / T↓ — price is testing beyond a locked range edge; acceptance is not yet confirmed.
- A↑ / A↓ — the required closes remain outside the edge and the move passes the selected efficiency and relative-volume checks.
- FA↑ / FA↓ — price returns inside after an attempted auction beyond the edge.
- RT↑ / RT↓ — the first retest holds on the accepted side of the locked edge.

How it is calculated

1. The reference range is the highest high and lowest low of prior bars. The
   current bar is excluded.
2. When a close moves beyond an edge by the selected ATR distance, both edges
   are locked. They cannot slide while the test is active.
3. Acceptance requires a user-selected number of closes beyond the locked edge.
4. Kaufman-style efficiency ratio separates directional travel from a noisy
   path. Optional relative volume checks whether participation is above its
   recent average.
5. ATR percentile identifies compression. It does not predict the direction of
   the next expansion.
6. A return inside the edge marks a failed auction. After acceptance, the first
   touch that closes on the accepted side marks a held retest.

State transitions and alerts occur on confirmed bars. No future bars are used,
and the active range is locked at the time of the test.

How to use it

The tool is a market-structure classifier. It can help a trader distinguish
between “price traded beyond a level” and “price was accepted beyond a level.”
It does not provide an entry, stop, target, position size, probability, or
profitability claim.

All defaults are round research hypotheses and are user-adjustable. Market
quality, fees, slippage and higher-timeframe context remain outside this script.
Educational context only. Not financial advice.

## Source Code

````pine
// ============================================================================
// QuantLine · Auction State Engine
// Public, educational market-structure classifier.
// Classifies balance, compression, breakout testing, acceptance, discovery,
// retest and failed auction around a point-in-time prior range.
// No entries, targets or performance claims. Confirmed bars only.
// ============================================================================
//@version=6
indicator("QuantLine Auction State Engine", shorttitle="QL Auction V2", overlay=true, max_labels_count=100)

// ── Inputs ───────────────────────────────────────────────────────────────────
groupModel = "Model"
rangeLen = input.int(60, "Prior-range lookback", minval=10, group=groupModel)
atrLen = input.int(14, "ATR length", minval=2, group=groupModel)
erLen = input.int(20, "Efficiency-ratio length", minval=5, group=groupModel)
volRankLen = input.int(120, "Volatility percentile lookback", minval=30, group=groupModel)
acceptBars = input.int(2, "Closes required for acceptance", minval=1, maxval=5, group=groupModel)
maxTestBars = input.int(8, "Maximum breakout-test bars", minval=2, maxval=20, group=groupModel)
maxDiscoveryBars = input.int(24, "Maximum discovery-state bars", minval=4, maxval=120, group=groupModel)
breakAtr = input.float(0.10, "Minimum break distance, ATR", minval=0.0, step=0.05, group=groupModel)
failAtr = input.float(0.05, "Failure distance back inside, ATR", minval=0.0, step=0.05, group=groupModel)
retestAtr = input.float(0.15, "Retest tolerance, ATR", minval=0.0, step=0.05, group=groupModel)
minER = input.float(0.25, "Minimum efficiency for acceptance", minval=0.0, maxval=1.0, step=0.05, group=groupModel)
compressionPct = input.float(25.0, "Compression below volatility percentile", minval=1.0, maxval=50.0, step=1.0, group=groupModel)

groupVolume = "Volume confirmation"
useVolume = input.bool(true, "Require relative volume", group=groupVolume)
volumeLen = input.int(20, "Volume average length", minval=5, group=groupVolume)
minVolumeRatio = input.float(1.05, "Minimum volume / average", minval=0.1, step=0.05, group=groupVolume)

groupDisplay = "Research terminal"
showRange = input.bool(true, "Show active range", group=groupDisplay)
showZone = input.bool(true, "Show subtle balance zone", group=groupDisplay)
showStateField = input.bool(true, "Show state-field tint", group=groupDisplay)
showGlow = input.bool(true, "Neon range rails", group=groupDisplay)
showBarPulse = input.bool(true, "Color confirmed discovery bars", group=groupDisplay)
showEvents = input.bool(true, "Show state-transition markers", group=groupDisplay)
markerCooldown = input.int(18, "Minimum bars between event labels", minval=0, maxval=200, group=groupDisplay)
showTerminal = input.bool(true, "Show state terminal", group=groupDisplay)
terminalPosition = input.string("top_right", "Terminal position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=groupDisplay)

// ── Research-terminal palette ────────────────────────────────────────────────
carbon = color.rgb(11, 15, 20)
panel = color.rgb(20, 27, 35)
ice = color.rgb(76, 201, 240)
amber = color.rgb(246, 200, 95)
magenta = color.rgb(255, 77, 109)
violet = color.rgb(151, 117, 250)
muted = color.rgb(132, 145, 160)

f_terminal_position(simple string value) =>
    value == "top_left" ? position.top_left : value == "bottom_right" ? position.bottom_right : value == "bottom_left" ? position.bottom_left : position.top_right

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

// ── Point-in-time features ───────────────────────────────────────────────────
atr = ta.atr(atrLen)
atrPct = atr / math.max(close, 1e-9) * 100.0
volatilityPctRank = ta.percentrank(atrPct, volRankLen)
path = ta.sma(math.abs(ta.change(close)), erLen) * erLen
efficiency = math.abs(close - close[erLen]) / math.max(path, 1e-9)
volumeAverage = ta.sma(volume, volumeLen)
volumeRatio = volume / math.max(volumeAverage, 1e-9)

// The current bar is excluded. A candidate break locks these levels so the
// reference cannot slide while acceptance/retest is being evaluated.
priorHigh = ta.highest(high[1], rangeLen)
priorLow = ta.lowest(low[1], rangeLen)
priorWidth = priorHigh - priorLow
compression = volatilityPctRank < compressionPct
qualityConfirmed = efficiency >= minER and (not useVolume or volumeRatio >= minVolumeRatio)

// armedDir: 0 balance, 1 test up, -1 test down, 2 accepted up, -2 accepted down.
var int armedDir = 0
var int state = 0
var int closesBeyond = 0
var int testStartBar = na
var int acceptedBar = na
var float lockedHigh = na
var float lockedLow = na
var bool retestDone = false

bool eventAcceptUp = false
bool eventAcceptDown = false
bool eventTestUp = false
bool eventTestDown = false
bool eventFailUp = false
bool eventFailDown = false
bool eventRetestUp = false
bool eventRetestDown = false
var int lastVisualEventBar = na

if barstate.isconfirmed
    // One-bar event states fall back to their persistent state on the next bar.
    if state == 6 or state == 7
        state := compression ? 1 : 0
    else if state == 8
        state := 4
    else if state == 9
        state := 5

    if armedDir == 0
        state := compression ? 1 : 0
        bool candidateUp = not na(priorHigh) and close > priorHigh + atr * breakAtr
        bool candidateDown = not na(priorLow) and close < priorLow - atr * breakAtr
        if candidateUp and not candidateDown
            eventTestUp := true
            lockedHigh := priorHigh
            lockedLow := priorLow
            armedDir := 1
            closesBeyond := 1
            testStartBar := bar_index
            state := 2
        else if candidateDown and not candidateUp
            eventTestDown := true
            lockedHigh := priorHigh
            lockedLow := priorLow
            armedDir := -1
            closesBeyond := 1
            testStartBar := bar_index
            state := 3

    else if armedDir == 1
        if close < lockedHigh - atr * failAtr
            eventFailUp := true
            state := 6
            armedDir := 0
        else
            closesBeyond := close > lockedHigh + atr * breakAtr ? closesBeyond + 1 : closesBeyond
            if closesBeyond >= acceptBars and qualityConfirmed
                eventAcceptUp := true
                state := 4
                armedDir := 2
                acceptedBar := bar_index
                retestDone := false
            else if bar_index - testStartBar >= maxTestBars
                armedDir := 0
                state := compression ? 1 : 0

    else if armedDir == -1
        if close > lockedLow + atr * failAtr
            eventFailDown := true
            state := 7
            armedDir := 0
        else
            closesBeyond := close < lockedLow - atr * breakAtr ? closesBeyond + 1 : closesBeyond
            if closesBeyond >= acceptBars and qualityConfirmed
                eventAcceptDown := true
                state := 5
                armedDir := -2
                acceptedBar := bar_index
                retestDone := false
            else if bar_index - testStartBar >= maxTestBars
                armedDir := 0
                state := compression ? 1 : 0

    else if armedDir == 2
        state := 4
        if close < lockedHigh - atr * failAtr
            eventFailUp := true
            state := 6
            armedDir := 0
        else if bar_index - acceptedBar >= maxDiscoveryBars
            armedDir := 0
            state := compression ? 1 : 0
            lockedHigh := na
            lockedLow := na
        else if not retestDone and bar_index > acceptedBar and low <= lockedHigh + atr * retestAtr and close >= lockedHigh
            eventRetestUp := true
            retestDone := true
            state := 8

    else if armedDir == -2
        state := 5
        if close > lockedLow + atr * failAtr
            eventFailDown := true
            state := 7
            armedDir := 0
        else if bar_index - acceptedBar >= maxDiscoveryBars
            armedDir := 0
            state := compression ? 1 : 0
            lockedHigh := na
            lockedLow := na
        else if not retestDone and bar_index > acceptedBar and high >= lockedLow - atr * retestAtr and close <= lockedLow
            eventRetestDown := true
            retestDone := true
            state := 9

// ── State display ────────────────────────────────────────────────────────────
bool useLockedRange = armedDir != 0 or state == 6 or state == 7 or state == 8 or state == 9
displayHigh = useLockedRange ? lockedHigh : priorHigh
displayLow = useLockedRange ? lockedLow : priorLow
displayWidth = displayHigh - displayLow
rangePosition = f_clamp((close - displayLow) / math.max(displayWidth, 1e-9), 0.0, 1.0) * 100.0

stateCode = state == 1 ? "CMP" : state == 2 ? "T↑" : state == 3 ? "T↓" : state == 4 ? "A↑" : state == 5 ? "A↓" : state == 6 ? "FA↑" : state == 7 ? "FA↓" : state == 8 ? "RT↑" : state == 9 ? "RT↓" : "BAL"
stateName = state == 1 ? "COMPRESSION" : state == 2 ? "BREAK TEST UP" : state == 3 ? "BREAK TEST DOWN" : state == 4 ? "DISCOVERY UP" : state == 5 ? "DISCOVERY DOWN" : state == 6 ? "FAILED AUCTION UP" : state == 7 ? "FAILED AUCTION DOWN" : state == 8 ? "RETEST HELD UP" : state == 9 ? "RETEST HELD DOWN" : "BALANCE"
stateColor = state == 4 or state == 8 ? ice : state == 5 or state == 9 ? violet : state == 6 or state == 7 ? magenta : state == 1 or state == 2 or state == 3 ? amber : muted

displayMid = (displayHigh + displayLow) * 0.5
highGlow = plot(showRange and showGlow ? displayHigh : na, "Upper range glow", color=color.new(stateColor, 78), linewidth=8, style=plot.style_linebr)
lowGlow = plot(showRange and showGlow ? displayLow : na, "Lower range glow", color=color.new(stateColor, 78), linewidth=8, style=plot.style_linebr)
highPlot = plot(showRange ? displayHigh : na, "Locked range high", color=stateColor, linewidth=2, style=plot.style_linebr)
lowPlot = plot(showRange ? displayLow : na, "Locked range low", color=stateColor, linewidth=2, style=plot.style_linebr)
plot(showRange ? displayMid : na, "Auction equilibrium", color=color.new(stateColor, 62), linewidth=1, style=plot.style_linebr)
fill(highPlot, lowPlot, color=showZone ? color.new(stateColor, 91) : na, title="Active auction range")
bgcolor(showStateField ? color.new(stateColor, state == 4 or state == 5 ? 95 : 98) : na, title="Auction-state field")
barcolor(showBarPulse and barstate.isconfirmed and (state == 4 or state == 8) ? color.new(ice, 5) : showBarPulse and barstate.isconfirmed and (state == 5 or state == 9) ? color.new(violet, 5) : na)

// Alerts keep every confirmed transition. The cooldown is display-only: it
// prevents overlapping labels without changing the state machine or alerts.
bool anyEvent = eventTestUp or eventTestDown or eventAcceptUp or eventAcceptDown or eventFailUp or eventFailDown or eventRetestUp or eventRetestDown
bool visualEventAllowed = showEvents and anyEvent and (na(lastVisualEventBar) or bar_index - lastVisualEventBar >= markerCooldown)
if visualEventAllowed
    lastVisualEventBar := bar_index

plotshape(visualEventAllowed and eventTestUp, title="Range test up", style=shape.triangleup, location=location.belowbar, color=amber, text="T↑", textcolor=carbon, size=size.tiny)
plotshape(visualEventAllowed and eventTestDown, title="Range test down", style=shape.triangledown, location=location.abovebar, color=amber, text="T↓", textcolor=carbon, size=size.tiny)
plotshape(visualEventAllowed and eventAcceptUp, title="Acceptance up", style=shape.labelup, location=location.belowbar, color=ice, text="A↑", textcolor=carbon, size=size.tiny)
plotshape(visualEventAllowed and eventAcceptDown, title="Acceptance down", style=shape.labeldown, location=location.abovebar, color=violet, text="A↓", textcolor=color.white, size=size.tiny)
plotshape(visualEventAllowed and eventFailUp, title="Failed auction up", style=shape.labeldown, location=location.abovebar, color=magenta, text="FA↑", textcolor=color.white, size=size.tiny)
plotshape(visualEventAllowed and eventFailDown, title="Failed auction down", style=shape.labelup, location=location.belowbar, color=magenta, text="FA↓", textcolor=color.white, size=size.tiny)
plotshape(visualEventAllowed and eventRetestUp, title="Retest held up", style=shape.diamond, location=location.belowbar, color=ice, text="RT↑", textcolor=carbon, size=size.tiny)
plotshape(visualEventAllowed and eventRetestDown, title="Retest held down", style=shape.diamond, location=location.abovebar, color=violet, text="RT↓", textcolor=color.white, size=size.tiny)

var table terminal = table.new(f_terminal_position(terminalPosition), 2, 7, bgcolor=color.new(carbon, 2), frame_color=color.new(stateColor, 30), frame_width=1, border_color=color.new(muted, 74), border_width=1)
if barstate.islast and showTerminal
    table.cell(terminal, 0, 0, "QL // AUCTION // V2", text_color=color.white, bgcolor=panel, text_size=size.small)
    table.cell(terminal, 1, 0, stateCode, text_color=stateColor, bgcolor=panel, text_size=size.large)
    table.cell(terminal, 0, 1, "REGIME", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 1, stateName, text_color=stateColor, text_size=size.small)
    table.cell(terminal, 0, 2, "RANGE POSITION", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 2, str.tostring(rangePosition, "#") + "%", text_color=color.white, text_size=size.small)
    table.cell(terminal, 0, 3, "EFFICIENCY", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 3, str.tostring(efficiency, "0.00"), text_color=efficiency >= minER ? ice : amber, text_size=size.small)
    table.cell(terminal, 0, 4, "VOLATILITY PCTL", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 4, str.tostring(volatilityPctRank, "#") + "%", text_color=compression ? amber : color.white, text_size=size.small)
    table.cell(terminal, 0, 5, "RELATIVE VOLUME", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 5, str.tostring(volumeRatio, "0.00") + "×", text_color=volumeRatio >= minVolumeRatio ? ice : muted, text_size=size.small)
    table.cell(terminal, 0, 6, "MODEL", text_color=muted, text_size=size.tiny)
    table.cell(terminal, 1, 6, "PIT RANGE · CLOSE-CONFIRMED", text_color=muted, text_size=size.tiny)

alertcondition(eventAcceptUp, "Auction State: acceptance up", "Confirmed acceptance above the locked prior range. Context only, not an entry.")
alertcondition(eventAcceptDown, "Auction State: acceptance down", "Confirmed acceptance below the locked prior range. Context only, not an entry.")
alertcondition(eventFailUp, "Auction State: failed auction up", "Price returned inside after testing above the locked range.")
alertcondition(eventFailDown, "Auction State: failed auction down", "Price returned inside after testing below the locked range.")
alertcondition(eventRetestUp, "Auction State: retest held up", "First confirmed retest held above the accepted range high.")
alertcondition(eventRetestDown, "Auction State: retest held down", "First confirmed retest held below the accepted range low.")
````
