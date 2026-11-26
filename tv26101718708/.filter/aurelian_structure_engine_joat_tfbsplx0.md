# Aurelian Structure Engine [JOAT]

- url: https://www.tradingview.com/script/TfbSplx0-Aurelian-Structure-Engine-JOAT/
- type: indicator
- pine_id: PUB;970a2bca7b184cee9464085ca24c7d1c
- version: 1.0

## Description

[b]Aurelian Structure Engine [JOAT][/b]

[b]Introduction[/b]

Aurelian Structure Engine is a market structure and execution-context model that combines confirmed pivots, break events, HTF bias, anchored value, relative volume, and pressure scoring. It is built to separate meaningful structural breaks from ordinary candle noise.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/hpjft1bq/[/image]

[b]Core Concepts[/b]

[b]1. Confirmed Swing Structure[/b]

Swing highs and lows are confirmed with pivot logic before the script evaluates breaks. ATR buffering helps prevent small wick violations from becoming structure events.

[b]2. Bid and Offer Block Geometry[/b]

Recent opposing candles can become bid or offer blocks only when their vertical placement makes structural sense. Invalidated or overlapping blocks are removed.

[b]3. Anchored Value Context[/b]

An EMA and yearly anchored VWAP stack define whether price is operating above or below value.

[b]4. Tiered Quality Score[/b]

Pressure, RVOL, HTF bias, structure, and proximity are converted into B, A, and A+ style states.

[pine]
bullScore = structure + pressure + rvol + htfBias + valueContext
[/pine]

[b]Features[/b]

[list]
[*]Confirmed BOS and CHoCH-style structure tracking
[*]Bid and offer blocks with invalidation logic
[*]EMA/VWAP value spine and structure bands
[*]Volume pressure and RVOL scoring
[*]A/B/A+ state labels and compact dashboard
[/list]

[b]Input Parameters[/b]

[list]
[*]Swing pivot length and ATR buffer
[*]Block search and extension controls
[*]HTF bias timeframe
[*]Pressure, RVOL, cooldown, and A+ score gates
[*]Display toggles for bands, blocks, candles, and panel
[/list]


[b]How to Use This Script[/b]

Read the structure side first, then check whether pressure, RVOL, and HTF bias confirm the break. A+ labels require stronger agreement than A or B labels.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Aurelian is original in combining guarded bid/offer block geometry, confirmed structure, anchored value, and multi-factor signal quality into one restrained overlay.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aurelian Structure Engine [JOAT]", shorttitle="ASE [JOAT]", overlay=true, scale=scale.none, max_bars_back=700, max_labels_count=160, max_lines_count=120, max_boxes_count=60)

string gCore = "Core"
string gGate = "Signal Gates"
string gViz = "Visual System"
string gDash = "Panel"
int swingLen = input.int(5, "Swing pivot length", minval=2, maxval=25, group=gCore)
int atrLen = input.int(14, "ATR length", minval=5, maxval=100, group=gCore)
float bosBufferAtr = input.float(0.06, "Structure buffer ATR", minval=0.0, maxval=1.0, step=0.01, group=gCore)
int obLookback = input.int(14, "Block search bars", minval=3, maxval=50, group=gCore)
int obExtend = input.int(140, "Block extension bars", minval=20, maxval=500, group=gCore)
bool fadeTouchedBlocks = input.bool(true, "Fade touched blocks", group=gCore)
bool useHtf = input.bool(true, "Use HTF bias", group=gGate)
string htf = input.timeframe("240", "HTF", group=gGate)
float deltaNeed = input.float(0.05, "Pressure threshold", minval=0.0, step=0.01, group=gGate)
float rvolNeed = input.float(1.25, "Relative volume threshold", minval=0.1, step=0.05, group=gGate)
int cooldownBars = input.int(8, "Signal cooldown", minval=0, maxval=100, group=gGate)
float tierPlus = input.float(92.0, "A+ score", minval=70, maxval=100, step=1, group=gGate)
bool showBands = input.bool(true, "Show structure bands", group=gViz)
bool showBlocks = input.bool(true, "Show active blocks", group=gViz)
bool paintBars = input.bool(true, "Paint signal candles", group=gViz)
bool showPanel = input.bool(true, "Show panel", group=gDash)

color C_BULL = #00ffd5
color C_BEAR = #ff00f2
color C_BLUE = #4f7cff
color C_GOLD = #ffb300
color C_TEXT = #e8f2ff
color C_MUTED = #6b778d
color C_BG = #080a12

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

near(float price, float level, float tolerance) =>
    not na(level) and math.abs(price - level) <= tolerance

float atr = ta.atr(atrLen)
float ema50 = ta.ema(close, 50)

var float avSum = 0.0
var float avVol = 0.0
if timeframe.change("12M")
    avSum := 0.0
    avVol := 0.0
avSum += hlc3 * nz(volume, 1.0)
avVol += nz(volume, 1.0)
float yvwap = avVol > 0 ? avSum / avVol : hlc3

bool bullishStack = close > ema50 and close > yvwap and ema50 > yvwap
bool bearishStack = close < ema50 and close < yvwap and ema50 < yvwap
float htfClose = useHtf ? request.security(syminfo.tickerid, htf, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : na
float htfEma = useHtf ? request.security(syminfo.tickerid, htf, ta.ema(close, 50)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : na
bool htfBull = not useHtf or htfClose > htfEma
bool htfBear = not useHtf or htfClose < htfEma

float pivotHigh = ta.pivothigh(high, swingLen, swingLen)
float pivotLow = ta.pivotlow(low, swingLen, swingLen)
var float lastHigh = na
var float prevHigh = na
var float lastLow = na
var float prevLow = na
var int lastHighBar = na
var int lastLowBar = na
if not na(pivotHigh)
    prevHigh := lastHigh
    lastHigh := pivotHigh
    lastHighBar := bar_index - swingLen
if not na(pivotLow)
    prevLow := lastLow
    lastLow := pivotLow
    lastLowBar := bar_index - swingLen

float bosBuffer = atr * bosBufferAtr
bool bullBreakRaw = not na(lastHigh) and not na(prevHigh) and close > lastHigh + bosBuffer
bool bearBreakRaw = not na(lastLow) and not na(prevLow) and close < lastLow - bosBuffer
bool bullBreak = barstate.isconfirmed and bullBreakRaw and not bullBreakRaw[1]
bool bearBreak = barstate.isconfirmed and bearBreakRaw and not bearBreakRaw[1]

var int structureSide = 0
bool bullChoCh = bullBreak and structureSide == -1
bool bearChoCh = bearBreak and structureSide == 1
if bullBreak
    structureSide := 1
if bearBreak
    structureSide := -1

float bandMidRaw = bullishStack ? math.max(ema50, yvwap) : bearishStack ? math.min(ema50, yvwap) : (ema50 + yvwap) * 0.5
float bandMid = ta.ema(bandMidRaw, 8)
float width = math.max(ta.ema(atr, 10) * 0.90, ta.ema(math.abs(ema50 - yvwap), 10) * 0.65)
float upperOuter = bandMid + width * 1.70
float upperInner = bandMid + width * 0.65
float lowerInner = bandMid - width * 0.65
float lowerOuter = bandMid - width * 1.70

plotUpperOuter = plot(showBands ? upperOuter : na, "ASE upper outer", color=color.new(C_BEAR, 86))
plotUpperInner = plot(showBands ? upperInner : na, "ASE upper inner", color=color.new(C_BEAR, 92))
plotLowerInner = plot(showBands ? lowerInner : na, "ASE lower inner", color=color.new(C_BULL, 92))
plotLowerOuter = plot(showBands ? lowerOuter : na, "ASE lower outer", color=color.new(C_BULL, 86))
plotMid = plot(showBands ? bandMid : na, "ASE value spine", color=bullishStack ? color.new(C_BULL, 12) : bearishStack ? color.new(C_BEAR, 12) : color.new(C_BLUE, 20), linewidth=2)
fill(plotUpperOuter, plotUpperInner, color=color.new(C_BEAR, 88), title="ASE resistance field")
fill(plotLowerInner, plotLowerOuter, color=color.new(C_BULL, 88), title="ASE support field")
fill(plotUpperInner, plotLowerInner, color=color.new(C_BLUE, 94), title="ASE neutral channel")

var box bullBlock = na
var box bearBlock = na
if bullBreak and not na(bearBlock) and close > box.get_top(bearBlock)
    box.delete(bearBlock)
    bearBlock := na
if bearBreak and not na(bullBlock) and close < box.get_bottom(bullBlock)
    box.delete(bullBlock)
    bullBlock := na
if bullBreak and showBlocks
    float bestScore = na
    int bestIndex = na
    for i = 1 to obLookback
        float body = math.abs(close[i] - open[i])
        float span = math.max(high[i] - low[i], syminfo.mintick)
        bool downCandle = close[i] < open[i]
        float candidateTop = math.max(open[i], close[i])
        float candidateBottom = low[i]
        bool correctSide = candidateTop < close - atr * 0.08 and candidateBottom < candidateTop
        bool separated = na(bearBlock) or candidateTop < box.get_bottom(bearBlock) - atr * 0.05
        float score = math.abs(candidateTop - bandMid[i]) + span * 0.35 + i * atr * 0.015 - body * 0.25
        if downCandle and correctSide and separated and (na(bestScore) or score < bestScore)
            bestScore := score
            bestIndex := i
    if not na(bestIndex)
        if not na(bullBlock)
            box.delete(bullBlock)
        float bidTop = math.max(open[bestIndex], close[bestIndex])
        float bidBottom = low[bestIndex]
        bullBlock := box.new(bar_index - bestIndex, bidTop, bar_index + obExtend, bidBottom, bgcolor=color.new(C_BULL, 91), border_color=color.new(C_BULL, 58), text="ASE bid block", text_color=color.new(C_TEXT, 40), text_size=size.tiny)
if bearBreak and showBlocks
    float bestScore = na
    int bestIndex = na
    for i = 1 to obLookback
        float body = math.abs(close[i] - open[i])
        float span = math.max(high[i] - low[i], syminfo.mintick)
        bool upCandle = close[i] > open[i]
        float candidateTop = high[i]
        float candidateBottom = math.min(open[i], close[i])
        bool correctSide = candidateBottom > close + atr * 0.08 and candidateTop > candidateBottom
        bool separated = na(bullBlock) or candidateBottom > box.get_top(bullBlock) + atr * 0.05
        float score = math.abs(candidateBottom - bandMid[i]) + span * 0.35 + i * atr * 0.015 - body * 0.25
        if upCandle and correctSide and separated and (na(bestScore) or score < bestScore)
            bestScore := score
            bestIndex := i
    if not na(bestIndex)
        if not na(bearBlock)
            box.delete(bearBlock)
        float offerTop = high[bestIndex]
        float offerBottom = math.min(open[bestIndex], close[bestIndex])
        bearBlock := box.new(bar_index - bestIndex, offerTop, bar_index + obExtend, offerBottom, bgcolor=color.new(C_BEAR, 91), border_color=color.new(C_BEAR, 58), text="ASE offer block", text_color=color.new(C_TEXT, 40), text_size=size.tiny)

if not showBlocks
    if not na(bullBlock)
        box.delete(bullBlock)
        bullBlock := na
    if not na(bearBlock)
        box.delete(bearBlock)
        bearBlock := na
if not na(bullBlock) and close < box.get_bottom(bullBlock) - atr * 0.10
    box.delete(bullBlock)
    bullBlock := na
if not na(bearBlock) and close > box.get_top(bearBlock) + atr * 0.10
    box.delete(bearBlock)
    bearBlock := na
if not na(bullBlock) and not na(bearBlock) and box.get_top(bullBlock) >= box.get_bottom(bearBlock)
    if structureSide >= 0
        box.delete(bearBlock)
        bearBlock := na
    else
        box.delete(bullBlock)
        bullBlock := na

bool bullBlockTouch = not na(bullBlock) and low <= box.get_top(bullBlock) and close >= box.get_bottom(bullBlock)
bool bearBlockTouch = not na(bearBlock) and high >= box.get_bottom(bearBlock) and close <= box.get_top(bearBlock)
if fadeTouchedBlocks and bullBlockTouch
    box.set_bgcolor(bullBlock, color.new(C_BULL, 96))
if fadeTouchedBlocks and bearBlockTouch
    box.set_bgcolor(bearBlock, color.new(C_BEAR, 96))

float rng = math.max(high - low, syminfo.mintick)
float pressure = ta.ema((((close - low) / rng) - ((high - close) / rng)) * nz(volume, 0), 7) / math.max(ta.ema(nz(volume, 0), 7), 1)
float rvol = nz(volume, 0) / math.max(ta.sma(nz(volume, 0), 20), 1)
bool pressureBull = pressure > deltaNeed
bool pressureBear = pressure < -deltaNeed
bool rvolOk = rvol >= rvolNeed
bool nearBid = bullBlockTouch or near(close, lowerInner, atr * 0.45) or near(close, yvwap, atr * 0.45)
bool nearOffer = bearBlockTouch or near(close, upperInner, atr * 0.45) or near(close, yvwap, atr * 0.45)

float bullScore = clamp((bullishStack ? 18 : 0) + (nearBid ? 18 : 0) + (bullBreak ? 18 : 0) + (bullChoCh ? 8 : 0) + (pressure > 0 ? clamp(pressure / math.max(deltaNeed, 0.01) * 9, 0, 18) : 0) + clamp(rvol / rvolNeed * 9, 0, 14) + (htfBull ? 12 : 0), 0, 100)
float bearScore = clamp((bearishStack ? 18 : 0) + (nearOffer ? 18 : 0) + (bearBreak ? 18 : 0) + (bearChoCh ? 8 : 0) + (pressure < 0 ? clamp(math.abs(pressure) / math.max(deltaNeed, 0.01) * 9, 0, 18) : 0) + clamp(rvol / rvolNeed * 9, 0, 14) + (htfBear ? 12 : 0), 0, 100)

var int lastSignalBar = na
bool cooled = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars
bool longA = cooled and bullBreak and bullishStack and pressureBull and rvolOk and htfBull and nearBid
bool shortA = cooled and bearBreak and bearishStack and pressureBear and rvolOk and htfBear and nearOffer
bool longB = cooled and bullBreak and bullishStack and htfBull and (pressureBull or rvolOk) and not longA
bool shortB = cooled and bearBreak and bearishStack and htfBear and (pressureBear or rvolOk) and not shortA
if longA or shortA or longB or shortB
    lastSignalBar := bar_index

bool longPlus = longA and bullScore >= tierPlus
bool shortPlus = shortA and bearScore >= tierPlus
barcolor(paintBars ? longPlus ? color.new(C_BULL, 0) : shortPlus ? color.new(C_BEAR, 0) : longA ? color.new(C_BULL, 18) : shortA ? color.new(C_BEAR, 18) : longB ? color.new(C_BULL, 55) : shortB ? color.new(C_BEAR, 55) : na : na)
plotshape(longPlus, "ASE long A plus", shape.labelup, location.belowbar, color=C_BULL, text="A+", textcolor=C_BG, size=size.tiny)
plotshape(shortPlus, "ASE short A plus", shape.labeldown, location.abovebar, color=C_BEAR, text="A+", textcolor=C_TEXT, size=size.tiny)
plotshape(longA and not longPlus, "ASE long A", shape.labelup, location.belowbar, color=color.new(C_BULL, 12), text="A", textcolor=C_BG, size=size.tiny)
plotshape(shortA and not shortPlus, "ASE short A", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 12), text="A", textcolor=C_TEXT, size=size.tiny)
plotshape(longB, "ASE long B", shape.labelup, location.belowbar, color=color.new(C_BULL, 48), text="B", textcolor=C_BG, size=size.tiny)
plotshape(shortB, "ASE short B", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 48), text="B", textcolor=C_TEXT, size=size.tiny)
plot(showBands ? lastHigh : na, "ASE swing ceiling", color=color.new(C_BEAR, 78), style=plot.style_linebr)
plot(showBands ? lastLow : na, "ASE swing floor", color=color.new(C_BULL, 78), style=plot.style_linebr)

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(C_TEXT, 75), frame_width=1)
    color stateColor = structureSide == 1 ? C_BULL : structureSide == -1 ? C_BEAR : C_MUTED
    table.cell(panel, 0, 0, "AURELIAN", text_color=C_TEXT, bgcolor=color.new(C_BLUE, 72), text_size=size.small)
    table.cell(panel, 1, 0, "ASE", text_color=C_TEXT, bgcolor=color.new(C_BLUE, 72), text_size=size.small)
    table.cell(panel, 0, 1, "Bias", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 1, structureSide == 1 ? "Bull" : structureSide == -1 ? "Bear" : "Neutral", text_color=stateColor, text_size=size.small)
    table.cell(panel, 0, 2, "Bull score", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 2, str.tostring(bullScore, "#"), text_color=C_BULL, text_size=size.small)
    table.cell(panel, 0, 3, "Bear score", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(bearScore, "#"), text_color=C_BEAR, text_size=size.small)
    table.cell(panel, 0, 4, "Pressure", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(pressure, "#.###"), text_color=pressure >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 0, 5, "RVOL", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 5, str.tostring(rvol, "#.##") + "x", text_color=rvolOk ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(panel, 0, 6, "HTF", text_color=color.new(C_TEXT, 20), text_size=size.small)
    table.cell(panel, 1, 6, htfBull ? "Bull" : htfBear ? "Bear" : "Flat", text_color=htfBull ? C_BULL : htfBear ? C_BEAR : C_MUTED, text_size=size.small)

alertcondition(longA or longB, "ASE Long [JOAT]", "Aurelian Structure Engine long state")
alertcondition(shortA or shortB, "ASE Short [JOAT]", "Aurelian Structure Engine short state")
````
