# GEM Logic 1.5

- url: https://www.tradingview.com/script/LRLbucGS-GEM-Logic-1-5/
- type: indicator
- pine_id: PUB;ba59161f69274615ae8c3ca27dce22e0
- version: 2.0

## Description

GEM Logic 1.5

GEM Logic 1.5 is a multi-layer market context indicator built to help traders quickly spot when several important signals begin to align.

Instead of relying on a single condition, this script combines RSI behavior, divergence logic, candlestick confirmation, multi-timeframe scoring, ADX, and recent range-based support/resistance zones into one clean visual framework.

The goal is simple:
show when market conditions are becoming more meaningful, not just more noisy.

What this indicator does

GEM Logic 1.5 combines several layers of analysis:

1. RSI context

The script tracks RSI and highlights when price is moving into overbought or oversold territory.

This helps identify areas where momentum may be stretched and where reversals or pauses may become more likely.

2. Divergence detection

The indicator looks for bullish and bearish RSI divergence between price and momentum.

It also tracks repeated divergence events over a lookback window, so the script can distinguish between a single weak signal and a stronger multi-event setup.

3. Execution state

Once a stronger divergence setup appears, the script monitors whether price has actually triggered an entry condition.

This gives a cleaner separation between:

a market that is only preparing
and a market that is already activating
4. Candlestick confirmation

The indicator also includes a candlestick layer using common price action patterns such as:

Engulfing
Pin bars / rejection candles
Morning / Evening Star
Inside bar breakout
Outside bar
Marubozu

These patterns act as an additional confirmation layer around momentum shifts.

5. GEM logic

The core idea of the script is the GEM concept:

A setup becomes more interesting when multiple elements begin to align at the same time, such as:

RSI extreme
divergence
candlestick confirmation

When these layers cluster together, the script can display a stronger confirmation event.

6. Multi-timeframe dashboard

The table on the right shows the current state across:

5m
15m
H1
H4
D
W

Each timeframe receives a score based on how many active factors are currently present.

This helps traders quickly see where market structure is strongest instead of manually switching charts all the time.

7. ADX reading

The bottom row displays ADX, giving a quick view of trend strength.

This helps distinguish between quieter conditions and stronger directional conditions.

8. Recent range support / resistance zones

The script also builds a recent range and marks support/resistance areas based on that range.

This provides a practical structure layer so signals can be interpreted in context rather than in isolation.

How to read the dashboard

The dashboard is designed to be simple.

Main rows
DIVERGENCE → shows whether bullish or bearish divergence is active
EXECUTION → shows whether a setup is waiting or already triggered
RSI → current RSI value
ADX → current ADX value
Timeframe score rows

The rows for 5, 15, H1, H4, D, W show how many factors are active on each timeframe.

General interpretation:

0 = no meaningful alignment
1 = one factor is active
2 = the setup is getting stronger
3+ = a more important cluster is forming
4+ = strong confluence

This score does not mean automatic buy or sell.
It simply means:
more parts of the logic are lining up on that timeframe right now.

Who this script is for

GEM Logic 1.5 may be useful for traders who want:

RSI-based context
divergence confirmation
candlestick confirmation
multi-timeframe awareness
a cleaner way to read market confluence
fewer separate indicators on the chart

It is especially helpful for traders who prefer to make decisions based on several confirming conditions, rather than reacting to one isolated signal.

Suggested workflow

A simple way to use this script:

Look at the dashboard and identify which timeframe has the strongest score.
Check whether divergence is present.
Check whether execution is still waiting or has triggered.
Look for GEM confirmation and candlestick support.
Review price location relative to the recent range zones.
Build your trade idea only after context is clear.
Important note

This script is a decision-support tool, not a prediction engine.

It does not guarantee entries, reversals, or outcomes.
It should be used together with:

risk management
position sizing
personal trade rules
market context

Nothing in this script should be treated as financial advice.

Summary

GEM Logic 1.5 is designed to help traders answer one practical question:

“Is there real confluence here, or is this just random noise?”

## Source Code

````pine
//@version=6
indicator("GEM Logic 1.5", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// INPUTS
grpRSI  = "RSI / Divergence"
grpMFI  = "MFI / Divergence"
grpExec = "Execution"
grpVis  = "Visuals"
grpMTF  = "MTF Matrix"
grpCndl = "Candlestick Combinations"
grpGEM  = "Universal GEM Mode"
grpSR   = "Support / Resistance Range Zones"
grpUI   = "Terminal UI"

rsiLength       = input.int(14, "RSI length", group=grpRSI)
overboughtLevel = input.int(72, "RSI overbought", group=grpRSI)
oversoldLevel   = input.int(28, "RSI oversold", group=grpRSI)
lookbackBars    = input.int(84, "Divergence lookback bars", group=grpRSI)
divCountReq     = input.int(3, "Events required", minval=1, group=grpRSI)

mfiLength       = input.int(14, "MFI length", group=grpMFI)
mfiOverbought   = input.int(80, "MFI overbought", group=grpMFI)
mfiOversold     = input.int(20, "MFI oversold", group=grpMFI)

signalLifeBars  = input.int(4, "Signal life", minval=1, group=grpExec)
stopBufferPct   = input.float(0.15, "Stop buffer %", step=0.05, group=grpExec)
tp1RR           = input.float(1.0, "TP1 R:R", step=0.1, group=grpExec)
tp2RR           = input.float(2.0, "TP2 R:R", step=0.1, group=grpExec)

showRSIFade     = input.bool(true, "MTF RSI extreme fade", group=grpVis)
showDivFade     = input.bool(true, "Divergence fade", group=grpVis)
showTable       = input.bool(true, "Dashboard", group=grpVis)
showBaseSignals = input.bool(true, "Show base setup / entry markers", group=grpVis)

showCandles        = input.bool(true, "Enable candlestick combinations", group=grpCndl)
showEngulfing      = input.bool(true, "Show Engulfing", group=grpCndl)
showPinBars        = input.bool(true, "Show Pin Bars / Rejection", group=grpCndl)
showStars          = input.bool(true, "Show Morning / Evening Star", group=grpCndl)
showInsideBars     = input.bool(true, "Show Inside Bar Breakout", group=grpCndl)
showOutsideBars    = input.bool(true, "Show Outside Bar", group=grpCndl)
showMarubozu       = input.bool(true, "Show Marubozu", group=grpCndl)

showUniversalGems  = input.bool(true, "Show GEM confirmations on all TF", group=grpGEM)
fullLayeredAllTF   = input.bool(true, "Full layered Emerald / Ruby on all TF", group=grpGEM)
compactBelowH4     = input.bool(false, "Compact style below H4", group=grpGEM)
showGemLabels      = input.bool(true, "Show GEM labels", group=grpGEM)
gemConfirmWindow   = input.int(8, "Confirmation window", minval=1, maxval=30, group=grpGEM)
gemUseStrongDiv    = input.bool(false, "Require 3rd RSI divergence only", group=grpGEM)

showSRZones        = input.bool(true, "Show S/R zones", group=grpSR)
rangeLookback      = input.int(50, "Range lookback", minval=10, maxval=500, group=grpSR)
zonePctOfRange     = input.float(0.10, "Zone size % of range", minval=0.01, maxval=0.50, step=0.01, group=grpSR)
showMidline        = input.bool(true, "Show midline", group=grpSR)
showSRLabels       = input.bool(true, "Show S/R labels", group=grpSR)
extendBarsRight    = input.int(8, "Extend zones right", minval=1, maxval=100, group=grpSR)

useTF15 = input.bool(true, "Use 15m", group=grpMTF)
tf15    = input.timeframe("15", "15m TF", group=grpMTF)
useTFH1 = input.bool(true, "Use H1", group=grpMTF)
tfH1    = input.timeframe("60", "H1 TF", group=grpMTF)
useTFH4 = input.bool(true, "Use H4", group=grpMTF)
tfH4    = input.timeframe("240", "H4 TF", group=grpMTF)
useTFD  = input.bool(true, "Use D", group=grpMTF)
tfD     = input.timeframe("D", "D TF", group=grpMTF)

tablePosOpt      = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpUI)
tableBodySizeOpt = input.string("Normal", "Table text size", options=["Small", "Normal", "Large"], group=grpUI)
useWideCells     = input.bool(true, "Wider cells", group=grpUI)
topSpacerRows    = input.int(1, "Top spacer rows", minval=0, maxval=3, group=grpUI)

// PALETTE
C_BG_DARK    = color.rgb(8, 10, 18)
C_BULL       = color.rgb(60, 220, 130)
C_BEAR       = color.rgb(255, 70, 110)
C_MIXED      = color.rgb(170, 90, 255)

C_EMERALD_CORE  = color.rgb(0, 255, 165)
C_EMERALD_MID   = color.rgb(0, 190, 120)
C_EMERALD_GLOW  = color.rgb(0, 255, 200)
C_EMERALD_SHINE = color.rgb(180, 255, 230)

C_RUBY_CORE     = color.rgb(255, 0, 85)
C_RUBY_MID      = color.rgb(190, 0, 70)
C_RUBY_GLOW     = color.rgb(255, 45, 120)
C_RUBY_SHINE    = color.rgb(255, 190, 210)

C_SUPPORT_FILL  = color.rgb(40, 175, 125)
C_RESIST_FILL   = color.rgb(185, 55, 95)
C_MIDLINE       = color.rgb(120, 150, 210)

C_TERM_FRAME      = color.rgb(34, 40, 52)
C_TERM_HEADER     = color.new(color.rgb(14, 18, 28), 90)
C_TERM_HEADER_TX  = color.rgb(102, 112, 128)
C_TERM_CELL       = color.new(color.rgb(9, 13, 22), 96)
C_TERM_TF         = color.new(color.rgb(11, 15, 24), 94)
C_TERM_TF_TX      = color.rgb(90, 100, 116)
C_TERM_NEUTRAL_TX = color.rgb(92, 100, 114)
C_TERM_SCORE_TX   = color.rgb(182, 190, 204)
C_TERM_SPACER     = color.new(C_BG_DARK, 100)

f_text_size(_opt) =>
    _opt == "Small" ? size.small : _opt == "Large" ? size.large : size.normal

TABLE_HEADER_SIZE = size.small
TABLE_BODY_SIZE   = f_text_size(tableBodySizeOpt)

f_table_position(_opt) =>
    _opt == "Top Left" ? position.top_left :
     _opt == "Bottom Right" ? position.bottom_right :
     _opt == "Bottom Left" ? position.bottom_left :
     position.top_right

TABLE_POS = f_table_position(tablePosOpt)

f_pad(_txt) =>
    useWideCells ? "  " + _txt + "  " : _txt

f_mfi(_h, _l, _c, _v, _len) =>
    _tp = (_h + _l + _c) / 3.0
    _rmf = _tp * _v
    _pos = _tp > _tp[1] ? _rmf : 0.0
    _neg = _tp < _tp[1] ? _rmf : 0.0
    _sumPos = math.sum(_pos, _len)
    _sumNeg = math.sum(_neg, _len)
    _sumNeg == 0.0 ? 100.0 : 100.0 - (100.0 / (1.0 + _sumPos / _sumNeg))

// TIMEFRAME MODES
isH4 = timeframe.isintraday and timeframe.multiplier == 240
useFullLayered = fullLayeredAllTF and not compactBelowH4 ? true : isH4
useCompact = compactBelowH4 and not isH4

// CORE CURRENT TF
rsi = ta.rsi(close, rsiLength)
mfi = f_mfi(high, low, close, volume, mfiLength)

inOB = rsi > overboughtLevel
inOS = rsi < oversoldLevel

mfiOB = mfi > mfiOverbought
mfiOS = mfi < mfiOversold

// MTF RSI
f_tf_rsi(_tf) =>
    request.security(syminfo.tickerid, _tf, ta.rsi(close, rsiLength), barmerge.gaps_off, barmerge.lookahead_off)

rsiTF15 = f_tf_rsi(tf15)
rsiTFH1 = f_tf_rsi(tfH1)
rsiTFH4 = f_tf_rsi(tfH4)
rsiTFD  = f_tf_rsi(tfD)

obTF15 = useTF15 and rsiTF15 > overboughtLevel
obTFH1 = useTFH1 and rsiTFH1 > overboughtLevel
obTFH4 = useTFH4 and rsiTFH4 > overboughtLevel
obTFD  = useTFD and rsiTFD > overboughtLevel

osTF15 = useTF15 and rsiTF15 < oversoldLevel
osTFH1 = useTFH1 and rsiTFH1 < oversoldLevel
osTFH4 = useTFH4 and rsiTFH4 < oversoldLevel
osTFD  = useTFD and rsiTFD < oversoldLevel

obCount = (inOB ? 1 : 0) + (obTF15 ? 1 : 0) + (obTFH1 ? 1 : 0) + (obTFH4 ? 1 : 0) + (obTFD ? 1 : 0)
osCount = (inOS ? 1 : 0) + (osTF15 ? 1 : 0) + (osTFH1 ? 1 : 0) + (osTFH4 ? 1 : 0) + (osTFD ? 1 : 0)

extremePower  = math.max(obCount, osCount)
extremeTransp = extremePower >= 5 ? 82 : extremePower == 4 ? 85 : extremePower == 3 ? 88 : extremePower == 2 ? 91 : extremePower == 1 ? 94 : 100

mtfExtremeCol = not showRSIFade ? na :
     obCount > osCount and obCount > 0 ? color.new(C_BEAR, extremeTransp) :
     osCount > obCount and osCount > 0 ? color.new(C_BULL, extremeTransp) :
     obCount == osCount and obCount > 0 ? color.new(C_MIXED, 91) : na

// RSI DIVERGENCE MEMORY ENGINE
var float prevHighRSI    = na
var float prevRsiHigh    = na
var int   prevBarHighRSI = na

if inOB
    if na(prevHighRSI) or rsi > prevRsiHigh
        prevHighRSI    := high
        prevRsiHigh    := rsi
        prevBarHighRSI := bar_index

if not na(prevBarHighRSI) and bar_index - prevBarHighRSI > lookbackBars
    prevHighRSI    := na
    prevRsiHigh    := na
    prevBarHighRSI := na

var float prevLowRSI    = na
var float prevRsiLow    = na
var int   prevBarLowRSI = na

if inOS
    if na(prevLowRSI) or rsi < prevRsiLow
        prevLowRSI    := low
        prevRsiLow    := rsi
        prevBarLowRSI := bar_index

if not na(prevBarLowRSI) and bar_index - prevBarLowRSI > lookbackBars
    prevLowRSI    := na
    prevRsiLow    := na
    prevBarLowRSI := na

rawSellRSI = inOB and not na(prevHighRSI) and high > prevHighRSI and rsi < prevRsiHigh
rawBuyRSI  = inOS and not na(prevLowRSI) and low < prevLowRSI and rsi > prevRsiLow

sellEventRSI = rawSellRSI
buyEventRSI  = rawBuyRSI

sellCountRSI = math.sum(sellEventRSI ? 1 : 0, lookbackBars)
buyCountRSI  = math.sum(buyEventRSI ? 1 : 0, lookbackBars)

sell3 = sellEventRSI and sellCountRSI >= divCountReq
buy3  = buyEventRSI and buyCountRSI >= divCountReq

// MFI DIVERGENCE MEMORY ENGINE
var float prevHighMFI    = na
var float prevMfiHigh    = na
var int   prevBarHighMFI = na

if mfiOB
    if na(prevHighMFI) or mfi > prevMfiHigh
        prevHighMFI    := high
        prevMfiHigh    := mfi
        prevBarHighMFI := bar_index

if not na(prevBarHighMFI) and bar_index - prevBarHighMFI > lookbackBars
    prevHighMFI    := na
    prevMfiHigh    := na
    prevBarHighMFI := na

var float prevLowMFI    = na
var float prevMfiLow    = na
var int   prevBarLowMFI = na

if mfiOS
    if na(prevLowMFI) or mfi < prevMfiLow
        prevLowMFI    := low
        prevMfiLow    := mfi
        prevBarLowMFI := bar_index

if not na(prevBarLowMFI) and bar_index - prevBarLowMFI > lookbackBars
    prevLowMFI    := na
    prevMfiLow    := na
    prevBarLowMFI := na

rawSellMFI = mfiOB and not na(prevHighMFI) and high > prevHighMFI and mfi < prevMfiHigh
rawBuyMFI  = mfiOS and not na(prevLowMFI) and low < prevLowMFI and mfi > prevMfiLow

// EXECUTION
var int   sellBar  = na
var float sellHigh = na
var float sellLow  = na

if sell3
    sellBar  := bar_index
    sellHigh := high
    sellLow  := low

sellActive = not na(sellBar) and bar_index > sellBar and bar_index - sellBar <= signalLifeBars
sellEntry  = sellActive and close < sellLow

sellStop = math.max(sellHigh * (1 + stopBufferPct / 100), close * (1 + stopBufferPct / 100))
sellRisk = math.max(sellStop - close, syminfo.mintick)
sellTp1  = close - sellRisk * tp1RR
sellTp2  = close - sellRisk * tp2RR

if sellEntry or (sellActive and high > sellHigh)
    sellBar := na

var int   buyBar  = na
var float buyHigh = na
var float buyLow  = na

if buy3
    buyBar  := bar_index
    buyHigh := high
    buyLow  := low

buyActive = not na(buyBar) and bar_index > buyBar and bar_index - buyBar <= signalLifeBars
buyEntry  = buyActive and close > buyHigh

buyStop = math.min(buyLow * (1 - stopBufferPct / 100), close * (1 - stopBufferPct / 100))
buyRisk = math.max(close - buyStop, syminfo.mintick)
buyTp1  = close + buyRisk * tp1RR
buyTp2  = close + buyRisk * tp2RR

if buyEntry or (buyActive and low < buyLow)
    buyBar := na

// CANDLESTICK FORMATIONS
body      = math.abs(close - open)
bodyPrev  = math.abs(close[1] - open[1])
rangeBar  = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
avgBody   = ta.sma(body, 20)

bullCandle = close > open
bearCandle = close < open

priorDown = close[1] < close[5]
priorUp   = close[1] > close[5]

rawBullEngulf = bullCandle and close[1] < open[1] and close > open[1] and open < close[1] and body > bodyPrev
rawBearEngulf = bearCandle and close[1] > open[1] and close < open[1] and open > close[1] and body > bodyPrev

rawBullPin = lowerWick >= body * 2.0 and upperWick <= body * 1.2 and close > low + rangeBar * 0.60
rawBearPin = upperWick >= body * 2.0 and lowerWick <= body * 1.2 and close < high - rangeBar * 0.60

rawHammer = priorDown and lowerWick >= body * 2.0 and upperWick <= body * 0.8 and close > low + rangeBar * 0.60
rawShootingStar = priorUp and upperWick >= body * 2.0 and lowerWick <= body * 0.8 and close < high - rangeBar * 0.60

rawMorningStar = close[2] < open[2] and math.abs(close[2] - open[2]) > avgBody[2] * 0.8 and math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.55 and bullCandle and close > (open[2] + close[2]) / 2
rawEveningStar = close[2] > open[2] and math.abs(close[2] - open[2]) > avgBody[2] * 0.8 and math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.55 and bearCandle and close < (open[2] + close[2]) / 2

insidePrev = high[1] < high[2] and low[1] > low[2]
rawInsideBullBreak = insidePrev and close > high[1]
rawInsideBearBreak = insidePrev and close < low[1]

rawOutsideBar = high > high[1] and low < low[1] and body > bodyPrev
rawOutsideBull = rawOutsideBar and bullCandle
rawOutsideBear = rawOutsideBar and bearCandle

rawMarubozu = body / rangeBar >= 0.75 and upperWick <= rangeBar * 0.12 and lowerWick <= rangeBar * 0.12
rawBullMarubozu = rawMarubozu and bullCandle
rawBearMarubozu = rawMarubozu and bearCandle

bullEngulf = showCandles and showEngulfing and rawBullEngulf
bearEngulf = showCandles and showEngulfing and rawBearEngulf

bullPin = showCandles and showPinBars and rawBullPin
bearPin = showCandles and showPinBars and rawBearPin

hammer = showCandles and showPinBars and rawHammer
shootingStar = showCandles and showPinBars and rawShootingStar

morningStar = showCandles and showStars and rawMorningStar
eveningStar = showCandles and showStars and rawEveningStar

insideBullBreak = showCandles and showInsideBars and rawInsideBullBreak
insideBearBreak = showCandles and showInsideBars and rawInsideBearBreak

outsideBull = showCandles and showOutsideBars and rawOutsideBull
outsideBear = showCandles and showOutsideBars and rawOutsideBear

bullMarubozu = showCandles and showMarubozu and rawBullMarubozu
bearMarubozu = showCandles and showMarubozu and rawBearMarubozu

bullCandleSignal = bullEngulf or bullPin or hammer or morningStar or insideBullBreak or outsideBull or bullMarubozu
bearCandleSignal = bearEngulf or bearPin or shootingStar or eveningStar or insideBearBreak or outsideBear or bearMarubozu

// GEM MODE
buyDivBase  = gemUseStrongDiv ? buy3 : (buy3 or rawBuyRSI)
sellDivBase = gemUseStrongDiv ? sell3 : (sell3 or rawSellRSI)

recentOS = nz(ta.barssince(inOS), 100000) <= gemConfirmWindow
recentOB = nz(ta.barssince(inOB), 100000) <= gemConfirmWindow

recentBuyDiv  = nz(ta.barssince(buyDivBase), 100000) <= gemConfirmWindow
recentSellDiv = nz(ta.barssince(sellDivBase), 100000) <= gemConfirmWindow

recentBullCandle = nz(ta.barssince(bullCandleSignal), 100000) <= gemConfirmWindow
recentBearCandle = nz(ta.barssince(bearCandleSignal), 100000) <= gemConfirmWindow

buyGemRaw  = showUniversalGems and recentOS and recentBuyDiv and recentBullCandle
sellGemRaw = showUniversalGems and recentOB and recentSellDiv and recentBearCandle

buyGem  = buyGemRaw and not buyGemRaw[1]
sellGem = sellGemRaw and not sellGemRaw[1]

// RANGE SUPPORT / RESISTANCE
rangeHigh = ta.highest(high, rangeLookback)
rangeLow  = ta.lowest(low, rangeLookback)
rangeSize = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangeMid  = (rangeHigh + rangeLow) / 2.0

zoneSize = math.max(rangeSize * zonePctOfRange, syminfo.mintick * 10)

resTop    = rangeHigh
resBottom = rangeHigh - zoneSize

supBottom = rangeLow
supTop    = rangeLow + zoneSize

resTouches = math.sum(high >= resBottom ? 1 : 0, rangeLookback)
supTouches = math.sum(low <= supTop ? 1 : 0, rangeLookback)

nearResistance = close >= resBottom
nearSupport    = close <= supTop

resStrength = 1 +
     (resTouches >= 2 ? 1 : 0) +
     (resTouches >= 4 ? 1 : 0) +
     (nearResistance and rawSellRSI ? 1 : 0) +
     (nearResistance and rawSellMFI ? 1 : 0) +
     (nearResistance and bearCandleSignal ? 1 : 0) +
     (nearResistance and sellGem ? 1 : 0) +
     (obCount >= 3 ? 1 : 0)

supStrength = 1 +
     (supTouches >= 2 ? 1 : 0) +
     (supTouches >= 4 ? 1 : 0) +
     (nearSupport and rawBuyRSI ? 1 : 0) +
     (nearSupport and rawBuyMFI ? 1 : 0) +
     (nearSupport and bullCandleSignal ? 1 : 0) +
     (nearSupport and buyGem ? 1 : 0) +
     (osCount >= 3 ? 1 : 0)

resBorderColor = resStrength >= 5 ? color.new(C_RUBY_CORE, 18) : resStrength >= 3 ? color.new(C_RUBY_MID, 28) : color.new(C_RESIST_FILL, 42)
supBorderColor = supStrength >= 5 ? color.new(C_EMERALD_CORE, 18) : supStrength >= 3 ? color.new(C_EMERALD_MID, 28) : color.new(C_SUPPORT_FILL, 42)

resFillColor = nearResistance ? color.new(C_RESIST_FILL, 90) : color.new(C_RESIST_FILL, 96)
supFillColor = nearSupport ? color.new(C_SUPPORT_FILL, 90) : color.new(C_SUPPORT_FILL, 96)

leftX  = math.max(bar_index - rangeLookback + 1, 0)
rightX = bar_index + extendBarsRight

var box   resBox   = na
var box   supBox   = na
var line  midLine  = na
var label resLabel = na
var label supLabel = na

if barstate.islast
    if not na(resBox)
        box.delete(resBox)
        resBox := na
    if not na(supBox)
        box.delete(supBox)
        supBox := na
    if not na(midLine)
        line.delete(midLine)
        midLine := na
    if not na(resLabel)
        label.delete(resLabel)
        resLabel := na
    if not na(supLabel)
        label.delete(supLabel)
        supLabel := na

    if showSRZones
        resBox := box.new(leftX, resTop, rightX, resBottom, border_color=color.new(resBorderColor, 40), border_width=1, bgcolor=resFillColor, xloc=xloc.bar_index)
        supBox := box.new(leftX, supTop, rightX, supBottom, border_color=color.new(supBorderColor, 40), border_width=1, bgcolor=supFillColor, xloc=xloc.bar_index)

        if showMidline
            midLine := line.new(leftX, rangeMid, rightX, rangeMid, xloc=xloc.bar_index, extend=extend.none, color=color.new(C_MIDLINE, 74), width=1, style=line.style_dotted)

        if showSRLabels
            resLabel := label.new(rightX, (resTop + resBottom) / 2.0, "R " + str.tostring(resStrength), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.rgb(218, 224, 232), color=color.new(resBorderColor, 82), size=size.tiny)
            supLabel := label.new(rightX, (supTop + supBottom) / 2.0, "S " + str.tostring(supStrength), xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.rgb(218, 224, 232), color=color.new(supBorderColor, 82), size=size.tiny)

// VISUALS
divFadeCol = not showDivFade ? na : sell3 ? color.new(C_BEAR, 95) : buy3 ? color.new(C_BULL, 95) : sellEntry ? color.new(C_BEAR, 93) : buyEntry ? color.new(C_BULL, 93) : na

bgcolor(divFadeCol)
bgcolor(mtfExtremeCol)

plotshape(showBaseSignals and sell3, title="Sell setup", location=location.abovebar, style=shape.diamond, size=size.small, color=C_BEAR, text="3", textcolor=color.white)
plotshape(showBaseSignals and buy3, title="Buy setup", location=location.belowbar, style=shape.diamond, size=size.small, color=C_BULL, text="3", textcolor=color.white)

plotshape(showBaseSignals and sellEntry, title="Sell entry", location=location.abovebar, style=shape.labeldown, size=size.normal, color=C_BEAR, textcolor=color.white, text="ENTRY")
plotshape(showBaseSignals and buyEntry, title="Buy entry", location=location.belowbar, style=shape.labelup, size=size.normal, color=C_BULL, textcolor=color.white, text="ENTRY")

plotshape(buyGem and useFullLayered, title="Gem Buy Glow Full", location=location.belowbar, style=shape.arrowup, size=size.large, color=color.new(C_EMERALD_GLOW, 82))
plotshape(buyGem and useFullLayered, title="Gem Buy Body Full", location=location.belowbar, style=shape.arrowup, size=size.normal, color=color.new(C_EMERALD_MID, 42))
plotshape(buyGem and useFullLayered, title="Gem Buy Core Full", location=location.belowbar, style=shape.arrowup, size=size.small, color=color.new(C_EMERALD_CORE, 8))
plotshape(buyGem and useFullLayered, title="Gem Buy Shine Full", location=location.belowbar, style=shape.arrowup, size=size.tiny, color=color.new(C_EMERALD_SHINE, 16))

plotshape(sellGem and useFullLayered, title="Gem Sell Glow Full", location=location.abovebar, style=shape.arrowdown, size=size.large, color=color.new(C_RUBY_GLOW, 82))
plotshape(sellGem and useFullLayered, title="Gem Sell Body Full", location=location.abovebar, style=shape.arrowdown, size=size.normal, color=color.new(C_RUBY_MID, 42))
plotshape(sellGem and useFullLayered, title="Gem Sell Core Full", location=location.abovebar, style=shape.arrowdown, size=size.small, color=color.new(C_RUBY_CORE, 8))
plotshape(sellGem and useFullLayered, title="Gem Sell Shine Full", location=location.abovebar, style=shape.arrowdown, size=size.tiny, color=color.new(C_RUBY_SHINE, 16))

plotshape(buyGem and useCompact, title="Gem Buy Body Compact", location=location.belowbar, style=shape.arrowup, size=size.normal, color=color.new(C_EMERALD_MID, 38))
plotshape(buyGem and useCompact, title="Gem Buy Core Compact", location=location.belowbar, style=shape.arrowup, size=size.small, color=color.new(C_EMERALD_CORE, 8))
plotshape(sellGem and useCompact, title="Gem Sell Body Compact", location=location.abovebar, style=shape.arrowdown, size=size.normal, color=color.new(C_RUBY_MID, 38))
plotshape(sellGem and useCompact, title="Gem Sell Core Compact", location=location.abovebar, style=shape.arrowdown, size=size.small, color=color.new(C_RUBY_CORE, 8))

plotshape(buyGem and showGemLabels and useFullLayered, title="Gem Buy Label Full", location=location.belowbar, style=shape.labelup, size=size.tiny, text="RSI DIV START", textcolor=color.new(C_EMERALD_SHINE, 0), color=color.new(color.black, 100))
plotshape(sellGem and showGemLabels and useFullLayered, title="Gem Sell Label Full", location=location.abovebar, style=shape.labeldown, size=size.tiny, text="RSI DIV START", textcolor=color.new(C_RUBY_SHINE, 0), color=color.new(color.black, 100))

plotshape(buyGem and showGemLabels and useCompact, title="Gem Buy Label Compact", location=location.belowbar, style=shape.labelup, size=size.tiny, text="DIV", textcolor=color.new(C_EMERALD_SHINE, 0), color=color.new(color.black, 100))
plotshape(sellGem and showGemLabels and useCompact, title="Gem Sell Label Compact", location=location.abovebar, style=shape.labeldown, size=size.tiny, text="DIV", textcolor=color.new(C_RUBY_SHINE, 0), color=color.new(color.black, 100))

// ALERTS
alertcondition(sell3, "Sell setup", "EDGE: 3rd bearish RSI divergence on {{ticker}} {{interval}}")
alertcondition(buy3, "Buy setup", "EDGE: 3rd bullish RSI divergence on {{ticker}} {{interval}}")
alertcondition(rawBuyMFI, "Bullish MFI divergence", "Bullish MFI divergence on {{ticker}} {{interval}}")
alertcondition(rawSellMFI, "Bearish MFI divergence", "Bearish MFI divergence on {{ticker}} {{interval}}")
alertcondition(sellEntry, "Sell entry", "EDGE: short trigger on {{ticker}} {{interval}} @ {{close}}")
alertcondition(buyEntry, "Buy entry", "EDGE: long trigger on {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullCandleSignal, "Bullish Candlestick Formation", "Candlestick: Bullish formation on {{ticker}} {{interval}}")
alertcondition(bearCandleSignal, "Bearish Candlestick Formation", "Candlestick: Bearish formation on {{ticker}} {{interval}}")
alertcondition(buyGem, "Universal Buy GEM", "EDGE GEM: RSI + RSI divergence + bullish candle on {{ticker}} {{interval}}")
alertcondition(sellGem, "Universal Sell GEM", "EDGE GEM: RSI + RSI divergence + bearish candle on {{ticker}} {{interval}}")
alertcondition(nearResistance, "Near Resistance Zone", "Price is near recent range resistance on {{ticker}} {{interval}}")
alertcondition(nearSupport, "Near Support Zone", "Price is near recent range support on {{ticker}} {{interval}}")

// DASHBOARD HELPERS
f_local_tf_pack() =>
    _r = ta.rsi(close, rsiLength)
    _m = f_mfi(high, low, close, volume, mfiLength)

    _rOB = _r > overboughtLevel
    _rOS = _r < oversoldLevel
    _mOB = _m > mfiOverbought
    _mOS = _m < mfiOversold

    _rState = _rOS ? 1 : _rOB ? -1 : 0
    _mState = _mOS ? 1 : _mOB ? -1 : 0

    _body = math.abs(close - open)
    _bodyPrev = math.abs(close[1] - open[1])
    _rangeBar = math.max(high - low, syminfo.mintick)
    _upperWick = high - math.max(open, close)
    _lowerWick = math.min(open, close) - low
    _avgBody = ta.sma(_body, 20)

    _bullCandle = close > open
    _bearCandle = close < open

    _priorDown = close[1] < close[5]
    _priorUp = close[1] > close[5]

    _rawBullEngulf = _bullCandle and close[1] < open[1] and close > open[1] and open < close[1] and _body > _bodyPrev
    _rawBearEngulf = _bearCandle and close[1] > open[1] and close < open[1] and open > close[1] and _body > _bodyPrev

    _rawBullPin = _lowerWick >= _body * 2.0 and _upperWick <= _body * 1.2 and close > low + _rangeBar * 0.60
    _rawBearPin = _upperWick >= _body * 2.0 and _lowerWick <= _body * 1.2 and close < high - _rangeBar * 0.60

    _rawHammer = _priorDown and _lowerWick >= _body * 2.0 and _upperWick <= _body * 0.8 and close > low + _rangeBar * 0.60
    _rawShootingStar = _priorUp and _upperWick >= _body * 2.0 and _lowerWick <= _body * 0.8 and close < high - _rangeBar * 0.60

    _rawMorningStar = close[2] < open[2] and math.abs(close[2] - open[2]) > _avgBody[2] * 0.8 and math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.55 and _bullCandle and close > (open[2] + close[2]) / 2
    _rawEveningStar = close[2] > open[2] and math.abs(close[2] - open[2]) > _avgBody[2] * 0.8 and math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.55 and _bearCandle and close < (open[2] + close[2]) / 2

    _insidePrev = high[1] < high[2] and low[1] > low[2]
    _rawInsideBullBreak = _insidePrev and close > high[1]
    _rawInsideBearBreak = _insidePrev and close < low[1]

    _rawOutsideBar = high > high[1] and low < low[1] and _body > _bodyPrev
    _rawOutsideBull = _rawOutsideBar and _bullCandle
    _rawOutsideBear = _rawOutsideBar and _bearCandle

    _rawMarubozu = _body / _rangeBar >= 0.75 and _upperWick <= _rangeBar * 0.12 and _lowerWick <= _rangeBar * 0.12
    _rawBullMarubozu = _rawMarubozu and _bullCandle
    _rawBearMarubozu = _rawMarubozu and _bearCandle

    _bullCandleSignal = _rawBullEngulf or _rawBullPin or _rawHammer or _rawMorningStar or _rawInsideBullBreak or _rawOutsideBull or _rawBullMarubozu
    _bearCandleSignal = _rawBearEngulf or _rawBearPin or _rawShootingStar or _rawEveningStar or _rawInsideBearBreak or _rawOutsideBear or _rawBearMarubozu
    _cState = _bullCandleSignal ? 1 : _bearCandleSignal ? -1 : 0

    _prevHighRSI = ta.valuewhen(_rOB, high, 1)
    _prevRsiH = ta.valuewhen(_rOB, _r, 1)
    _prevLowRSI = ta.valuewhen(_rOS, low, 1)
    _prevRsiL = ta.valuewhen(_rOS, _r, 1)

    _rawSellRSI = _rOB and not na(_prevHighRSI) and high > _prevHighRSI and _r < _prevRsiH
    _rawBuyRSI  = _rOS and not na(_prevLowRSI) and low < _prevLowRSI and _r > _prevRsiL
    _rdvState = _rawBuyRSI ? 1 : _rawSellRSI ? -1 : 0

    _prevHighMFI = ta.valuewhen(_mOB, high, 1)
    _prevMfiH = ta.valuewhen(_mOB, _m, 1)
    _prevLowMFI = ta.valuewhen(_mOS, low, 1)
    _prevMfiL = ta.valuewhen(_mOS, _m, 1)

    _rawSellMFI = _mOB and not na(_prevHighMFI) and high > _prevHighMFI and _m < _prevMfiH
    _rawBuyMFI  = _mOS and not na(_prevLowMFI) and low < _prevLowMFI and _m > _prevMfiL
    _mdvState = _rawBuyMFI ? 1 : _rawSellMFI ? -1 : 0

    _sellCountRSI = math.sum(_rawSellRSI ? 1 : 0, lookbackBars)
    _buyCountRSI = math.sum(_rawBuyRSI ? 1 : 0, lookbackBars)
    _sell3RSI = _rawSellRSI and _sellCountRSI >= divCountReq
    _buy3RSI = _rawBuyRSI and _buyCountRSI >= divCountReq

    _buyDivBase = gemUseStrongDiv ? _buy3RSI : (_buy3RSI or _rawBuyRSI)
    _sellDivBase = gemUseStrongDiv ? _sell3RSI : (_sell3RSI or _rawSellRSI)

    _recentOS = nz(ta.barssince(_rOS), 100000) <= gemConfirmWindow
    _recentOB = nz(ta.barssince(_rOB), 100000) <= gemConfirmWindow
    _recentBuyDiv = nz(ta.barssince(_buyDivBase), 100000) <= gemConfirmWindow
    _recentSellDiv = nz(ta.barssince(_sellDivBase), 100000) <= gemConfirmWindow
    _recentBullCandle = nz(ta.barssince(_bullCandleSignal), 100000) <= gemConfirmWindow
    _recentBearCandle = nz(ta.barssince(_bearCandleSignal), 100000) <= gemConfirmWindow

    _buyGemRaw = showUniversalGems and _recentOS and _recentBuyDiv and _recentBullCandle
    _sellGemRaw = showUniversalGems and _recentOB and _recentSellDiv and _recentBearCandle
    _buyGem = _buyGemRaw and not _buyGemRaw[1]
    _sellGem = _sellGemRaw and not _sellGemRaw[1]
    _gState = _buyGem ? 1 : _sellGem ? -1 : 0

    _score = (_rState != 0 ? 1 : 0) + (_rdvState != 0 ? 1 : 0) + (_mState != 0 ? 1 : 0) + (_mdvState != 0 ? 1 : 0) + (_cState != 0 ? 1 : 0) + (_gState != 0 ? 1 : 0)

    _biasSum = _rState + _rdvState + _mState + _mdvState + _cState + _gState
    _bias = _gState != 0 ? _gState : _biasSum > 0 ? 1 : _biasSum < 0 ? -1 : 0

    (_rState + 1) * 100000000 + (_rdvState + 1) * 10000000 + (_mState + 1) * 1000000 + (_mdvState + 1) * 100000 + (_cState + 1) * 10000 + (_gState + 1) * 1000 + (_bias + 1) * 100 + _score

f_tf_pack(_tf) =>
    request.security(syminfo.tickerid, _tf, f_local_tf_pack(), barmerge.gaps_off, barmerge.lookahead_off)

pack15 = useTF15 ? f_tf_pack(tf15) : 111111100
packH1 = useTFH1 ? f_tf_pack(tfH1) : 111111100
packH4 = useTFH4 ? f_tf_pack(tfH4) : 111111100
packD  = useTFD  ? f_tf_pack(tfD)  : 111111100

f_unpack_rsi(_pack) =>
    math.floor(_pack / 100000000) % 10 - 1

f_unpack_rdv(_pack) =>
    math.floor(_pack / 10000000) % 10 - 1

f_unpack_mfi(_pack) =>
    math.floor(_pack / 1000000) % 10 - 1

f_unpack_mdv(_pack) =>
    math.floor(_pack / 100000) % 10 - 1

f_unpack_cdl(_pack) =>
    math.floor(_pack / 10000) % 10 - 1

f_unpack_gem(_pack) =>
    math.floor(_pack / 1000) % 10 - 1

f_unpack_bias(_pack) =>
    math.floor(_pack / 100) % 10 - 1

f_unpack_score(_pack) =>
    _pack % 100

f_rsi_text(_state) =>
    _state > 0 ? "OS" : _state < 0 ? "OB" : "0"

f_dir_text(_state) =>
    _state > 0 ? "B" : _state < 0 ? "S" : "0"

f_state_bg(_state) =>
    _state > 0 ? color.new(C_EMERALD_CORE, 97) : _state < 0 ? color.new(C_RUBY_CORE, 97) : color.new(C_TERM_CELL, 100)

f_state_txt(_state) =>
    _state > 0 ? color.rgb(188, 246, 215) : _state < 0 ? color.rgb(248, 190, 206) : C_TERM_NEUTRAL_TX

f_header_bg() =>
    C_TERM_HEADER

f_header_txt() =>
    C_TERM_HEADER_TX

f_tf_bg() =>
    C_TERM_TF

f_tf_txt() =>
    C_TERM_TF_TX

f_score_bg(_score, _bias) =>
    _score == 0 ? color.new(C_TERM_CELL, 100) :
     _bias > 0 ? color.new(C_EMERALD_CORE, _score >= 6 ? 70 : _score == 5 ? 76 : _score == 4 ? 82 : _score == 3 ? 87 : _score == 2 ? 91 : 95) :
     _bias < 0 ? color.new(C_RUBY_CORE, _score >= 6 ? 70 : _score == 5 ? 76 : _score == 4 ? 82 : _score == 3 ? 87 : _score == 2 ? 91 : 95) :
     color.new(C_TERM_CELL, 100)

f_score_txt(_score, _bias) =>
    _score == 0 ? C_TERM_NEUTRAL_TX :
     _score >= 5 ? color.rgb(228, 234, 240) :
     _score >= 3 ? color.rgb(205, 214, 225) :
     _bias > 0 ? color.rgb(192, 218, 202) :
     _bias < 0 ? color.rgb(221, 190, 200) :
     C_TERM_SCORE_TX

TOTAL_ROWS = 6 + topSpacerRows
TOTAL_COLS = 8

var table tbl = na
if barstate.isfirst
    tbl := table.new(
         TABLE_POS,
         TOTAL_COLS,
         TOTAL_ROWS,
         bgcolor=color.new(C_BG_DARK, 100),
         frame_color=color.new(C_TERM_FRAME, 88),
         frame_width=1,
         border_color=color.new(C_TERM_FRAME, 96),
         border_width=1)

drawHeader(_row) =>
    table.cell(tbl, 0, _row, f_pad("TF"),    text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 1, _row, f_pad("RSI"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 2, _row, f_pad("RDV"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 3, _row, f_pad("MFI"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 4, _row, f_pad("MDV"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 5, _row, f_pad("CDL"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 6, _row, f_pad("GEM"),   text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())
    table.cell(tbl, 7, _row, f_pad("Score"), text_color=f_header_txt(), text_size=TABLE_HEADER_SIZE, bgcolor=f_header_bg())

drawTfRow(_row, _tfLabel, _pack) =>
    _rsiState = f_unpack_rsi(_pack)
    _rdvState = f_unpack_rdv(_pack)
    _mfiState = f_unpack_mfi(_pack)
    _mdvState = f_unpack_mdv(_pack)
    _cdlState = f_unpack_cdl(_pack)
    _gemState = f_unpack_gem(_pack)
    _bias     = f_unpack_bias(_pack)
    _score    = f_unpack_score(_pack)

    table.cell(tbl, 0, _row, f_pad(_tfLabel), text_color=f_tf_txt(), text_size=TABLE_BODY_SIZE, bgcolor=f_tf_bg())
    table.cell(tbl, 1, _row, f_pad(f_rsi_text(_rsiState)), text_color=f_state_txt(_rsiState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_rsiState))
    table.cell(tbl, 2, _row, f_pad(f_dir_text(_rdvState)), text_color=f_state_txt(_rdvState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_rdvState))
    table.cell(tbl, 3, _row, f_pad(f_rsi_text(_mfiState)), text_color=f_state_txt(_mfiState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_mfiState))
    table.cell(tbl, 4, _row, f_pad(f_dir_text(_mdvState)), text_color=f_state_txt(_mdvState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_mdvState))
    table.cell(tbl, 5, _row, f_pad(f_dir_text(_cdlState)), text_color=f_state_txt(_cdlState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_cdlState))
    table.cell(tbl, 6, _row, f_pad(f_dir_text(_gemState)), text_color=f_state_txt(_gemState), text_size=TABLE_BODY_SIZE, bgcolor=f_state_bg(_gemState))
    table.cell(tbl, 7, _row, f_pad(str.tostring(_score)), text_color=f_score_txt(_score, _bias), text_size=TABLE_BODY_SIZE, bgcolor=f_score_bg(_score, _bias))

if showTable and barstate.islast and not na(tbl)
    table.clear(tbl, 0, 0, TOTAL_COLS - 1, TOTAL_ROWS - 1)

    if topSpacerRows > 0
        for row = 0 to topSpacerRows - 1
            for col = 0 to TOTAL_COLS - 1
                table.cell(tbl, col, row, "", text_color=color.new(color.white, 100), bgcolor=C_TERM_SPACER)

    headerRow = topSpacerRows
    drawHeader(headerRow)
    drawTfRow(headerRow + 1, "15", pack15)
    drawTfRow(headerRow + 2, "H1", packH1)
    drawTfRow(headerRow + 3, "H4", packH4)
    drawTfRow(headerRow + 4, "D", packD)
````
