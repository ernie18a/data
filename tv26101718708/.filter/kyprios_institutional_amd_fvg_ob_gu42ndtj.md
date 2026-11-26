# KYPRIOS INSTITUTIONAL AMD + FVG + OB

- url: https://www.tradingview.com/script/gu42nDtj-KYPRIOS-INSTITUTIONAL-AMD-FVG-OB/
- type: indicator
- pine_id: PUB;40eab15c3a7f4462814c8b7419165a1b
- version: 1.0

## Description

KYPRIOS INSTITUTIONAL AMD + FVG PRO

Advanced institutional trading indicator designed for XAUUSD scalping and smart money analysis.

This tool combines:

* AMD Cycles (Accumulation → Manipulation → Distribution)
* ICT Fair Value Gaps (FVG)
* Smart Order Blocks (OB)
* Liquidity Sweeps
* CHOCH & BOS market structure
* HH / HL / LH / LL structure mapping
* Volume & HTF trend confirmation
* Displacement candle detection
* Session filtering for London & New York

The indicator is optimized for:

* XAUUSD 1M / 5M scalping
* Institutional price action
* Sniper reversals
* Liquidity grab setups
* Retracement entries into imbalance zones

Key Features:

* Detects smart money manipulation
* Filters weak FVGs using displacement + liquidity logic
* Identifies probable reversal zones
* Highlights mitigation areas where price may return before continuing
* Shows market structure shifts in real time
* Designed for high precision intraday trading

Best used with:

* London session
* New York session
* HTF bias confirmation
* Liquidity sweep reactions

Recommended Timeframes:

* 1 Minute
* 5 Minute
* 15 Minute

Recommended Markets:

* XAUUSD
* BTCUSD
* NAS100
* US30
* High volatility instruments

Built for traders who focus on:
institutional order flow, liquidity engineering, ICT concepts, and sniper entries.

## Source Code

````pine
//@version=6
indicator('KYPRIOS INSTITUTIONAL AMD + FVG + OB', overlay = true, max_boxes_count = 500)

//====================================================
// GENERAL
//====================================================

rangeLen = input.int(10, 'Range Length', group = 'GENERAL')
atrLen = input.int(14, 'ATR Length', group = 'GENERAL')
extendBars = input.int(10, 'Extend Boxes', group = 'GENERAL')

showFVG = input.bool(true, 'Show FVG', group = 'GENERAL')
showAMD = input.bool(true, 'Show AMD', group = 'GENERAL')
showOB = input.bool(true, 'Show Order Blocks', group = 'GENERAL')

//====================================================
// FILTERS
//====================================================

useHTFTrend = input.bool(true, 'Use HTF Trend', group = 'FILTERS')
htfTF = input.timeframe('3', 'HTF TF', group = 'FILTERS')

useVolumeFilter = input.bool(true, 'Use Volume Filter', group = 'FILTERS')
volumeMultiplier = input.float(1.0, 'Volume Sensitivity', step = 0.1, group = 'FILTERS')

useSessionFilter = input.bool(false, 'Use Session Filter', group = 'FILTERS')
useTFScaling = input.bool(true, 'Use Auto TF Scaling', group = 'FILTERS')
//====================================================
// ACCUMULATION
//====================================================

accumulationATR = input.float(2.1, 'ATR Sensitivity', step = 0.1, group = 'ACCUMULATION')

accumulationMomentum = input.float(0.2, 'Momentum Sensitivity', step = 0.1, group = 'ACCUMULATION')

accumulationCandles = input.float(1.2, 'Candle Sensitivity', step = 0.1, group = 'ACCUMULATION')

accumulationColor = input.color(color.purple, 'Color', group = 'ACCUMULATION')

accumTransparency = input.int(78, 'Transparency', minval = 0, maxval = 100, group = 'ACCUMULATION')

//====================================================
// MANIPULATION
//====================================================

manipulationBodyATR = input.float(0.6, 'Body Strength', step = 0.1, group = 'MANIPULATION')

manipulationLookback = input.int(2, 'Sweep Lookback', group = 'MANIPULATION')

manipulationColor = input.color(color.red, 'Color', group = 'MANIPULATION')

manipTransparency = input.int(70, 'Transparency', minval = 0, maxval = 100, group = 'MANIPULATION')

//====================================================
// DISTRIBUTION
//====================================================

distributionATR = input.float(2.5, 'Target Size', step = 0.5, group = 'DISTRIBUTION')

distributionBodyATR = input.float(0.4, 'DM Strength', step = 0.1, group = 'DISTRIBUTION')

distributionBreak = input.bool(true, 'Require Structure Break', group = 'DISTRIBUTION')

distributionColor = input.color(color.gray, 'Color', group = 'DISTRIBUTION')

distTransparency = input.int(72, 'Transparency', minval = 0, maxval = 100, group = 'DISTRIBUTION')
//====================================================
// FVG
//====================================================

fvgGapATR = input.float(0.2, 'FVG Gap Sensitivity', step = 0.05, group = 'FVG')

fvgBodyATR = input.float(0.3, 'FVG Impulse Strength', step = 0.1, group = 'FVG')

fvgColor = input.color(color.yellow, 'FVG Color', group = 'FVG')

fvgTransparency = input.int(78, 'Transparency', minval = 0, maxval = 100, group = 'FVG')

//====================================================
// ORDER BLOCK
//====================================================

obImpulseATR = input.float(1.7, 'OB Impulse Strength', step = 0.1, group = 'ORDER BLOCK')

obLookback = input.int(10, 'OB Lookback', group = 'ORDER BLOCK')

bullOBColor = input.color(color.aqua, 'Bull OB Color', group = 'ORDER BLOCK')

bearOBColor = input.color(color.orange, 'Bear OB Color', group = 'ORDER BLOCK')

obTransparency = input.int(80, 'OB Transparency', minval = 0, maxval = 100, group = 'ORDER BLOCK')

//====================================================
// LIQUIDITY
//====================================================

showLiquidity = input.bool(true, 'Show Liquidity', group = 'LIQUIDITY')

liqLookback = input.int(5, 'Swing Length', group = 'LIQUIDITY')

liqColor = input.color(color.white, 'Liquidity Color', group = 'LIQUIDITY')

liqStyle = input.string('Dashed', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'LIQUIDITY')

showSweeps = input.bool(true, 'Show Liquidity Sweeps', group = 'LIQUIDITY')

sweepPivot = input.int(9, 'Sweep Swing Size', minval = 2, group = 'LIQUIDITY')

sweepDistance = input.int(20, 'Minimum Swing Distance', minval = 5, group = 'LIQUIDITY')

sweepColorBull = input.color(color.aqua, 'Bull Sweep Color', group = 'LIQUIDITY')

sweepColorBear = input.color(color.orange, 'Bear Sweep Color', group = 'LIQUIDITY')

sweepWidth = input.int(2, 'Sweep Line Width', minval = 1, maxval = 5, group = 'LIQUIDITY')
//====================================================
// CHOCH
//====================================================

showCHOCH = input.bool(true, 'Show CHOCH', group = 'CHOCH')

chochPivot = input.int(5, 'CHOCH Swing Size', minval = 2, group = 'CHOCH')

chochColorBull = input.color(color.lime, 'Bullish CHOCH', group = 'CHOCH')

chochColorBear = input.color(color.red, 'Bearish CHOCH', group = 'CHOCH')

chochLineWidth = input.int(2, 'CHOCH Width', minval = 1, maxval = 5, group = 'CHOCH')

//====================================================
// BOS
//====================================================

showBOS = input.bool(true, 'Show BOS', group = 'BOS')

bosPivot = input.int(6, 'BOS Swing Size', minval = 2, group = 'BOS')

bosColorBull = input.color(color.aqua, 'Bullish BOS', group = 'BOS')

bosColorBear = input.color(color.orange, 'Bearish BOS', group = 'BOS')

bosLineWidth = input.int(2, 'BOS Width', minval = 1, maxval = 5, group = 'BOS')

//====================================================
// STRUCTURE
//====================================================

showStructure = input.bool(true, 'Show HH HL LH LL', group = 'STRUCTURE')

structurePivot = input.int(6, 'Structure Pivot', minval = 2, group = 'STRUCTURE')

buyArrowColor = input.color(color.lime, 'Buy Arrow', group = 'STRUCTURE')

sellArrowColor = input.color(color.red, 'Sell Arrow', group = 'STRUCTURE')

//====================================================
// CANDLES
//====================================================

bullCandleColor = input.color(color.rgb(0, 120, 255), 'Bull Candle', group = 'CANDLES')

bearCandleColor = input.color(color.white, 'Bear Candle', group = 'CANDLES')
//====================================================
// ATR
//====================================================

atr = ta.atr(atrLen)

//====================================================
// AUTO TF SCALING
//====================================================

tfMultiplier = useTFScaling ? timeframe.isminutes and timeframe.multiplier <= 5 ? 1.0 : timeframe.isminutes and timeframe.multiplier <= 15 ? 1.5 : timeframe.isminutes and timeframe.multiplier <= 60 ? 2.0 : 3.0 : 1.0

//====================================================
// HTF TREND
//====================================================

htfEMA = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50))

bullHTF = close > htfEMA
bearHTF = close < htfEMA

trendBull = useHTFTrend ? bullHTF : true
trendBear = useHTFTrend ? bearHTF : true

//====================================================
// SESSION FILTER
//====================================================

london = hour >= 8 and hour <= 11
newyork = hour >= 13 and hour <= 16

sessionOK = useSessionFilter ? london or newyork : true

//====================================================
// VOLUME FILTER
//====================================================

volMA = ta.sma(volume, 20)

highVolume = useVolumeFilter ? volume > volMA * volumeMultiplier : true
//====================================================
// SMART ACCUMULATION
//====================================================

ema20 = ta.ema(close, 20)

rangeHigh = ta.highest(high, rangeLen)
rangeLow = ta.lowest(low, rangeLen)

tightRange = rangeHigh - rangeLow < atr * accumulationATR * tfMultiplier

lowMomentum = math.abs(ema20 - ema20[5]) < atr * accumulationMomentum

smallCandles = ta.sma(high - low, 5) < atr * accumulationCandles

isAccumulation = tightRange and lowMomentum and smallCandles

var box accBox = na

if showAMD

    if isAccumulation and not isAccumulation[1]

        accBox := box.new(left = bar_index - rangeLen, right = bar_index, top = rangeHigh, bottom = rangeLow, bgcolor = color.new(accumulationColor, accumTransparency), border_color = color.new(accumulationColor, 5), text = 'AM', text_color = color.white, text_size = size.small)
        accBox

    if isAccumulation and not na(accBox)

        box.set_right(accBox, bar_index)
        box.set_top(accBox, rangeHigh)
        box.set_bottom(accBox, rangeLow)

//====================================================
// SWEEP LEVELS
//====================================================

hh = ta.highest(high, rangeLen)
ll = ta.lowest(low, rangeLen)

//====================================================
// MANIPULATION
//====================================================

sweepHigh = high > hh[manipulationLookback] and close < hh

sweepLow = low < ll[manipulationLookback] and close > ll

bearManipulation = sweepHigh and close < open and math.abs(close - open) > atr * manipulationBodyATR and highVolume and sessionOK

bullManipulation = sweepLow and close > open and math.abs(close - open) > atr * manipulationBodyATR and highVolume and sessionOK

//====================================================
// MANIPULATION BOXES
//====================================================

if showAMD

    if bearManipulation

        box.new(left = bar_index - 1, right = bar_index + 1, top = high, bottom = low, bgcolor = color.new(manipulationColor, manipTransparency), border_color = color.new(manipulationColor, 5), text = 'MU', text_color = color.white, text_size = size.small)

    if bullManipulation

        box.new(left = bar_index - 1, right = bar_index + 1, top = high, bottom = low, bgcolor = color.new(manipulationColor, manipTransparency), border_color = color.new(manipulationColor, 5), text = 'MU', text_color = color.white, text_size = size.small)
        //====================================================
        // DISTRIBUTION
        //====================================================

bearDistribution = bearManipulation and trendBear and close < low[1] and math.abs(close - open) > atr * distributionBodyATR and highVolume

bullDistribution = bullManipulation and trendBull and close > high[1] and math.abs(close - open) > atr * distributionBodyATR and highVolume
//====================================================
// DISTRIBUTION BOXES
//====================================================

if showAMD

    // BEARISH DM
    if bearDistribution

        box.new(left = bar_index, right = bar_index + extendBars, top = close + atr * distributionATR, bottom = close, bgcolor = color.new(distributionColor, distTransparency), border_color = color.new(distributionColor, 10), text = 'DM', text_color = color.white, text_size = size.small)

    // BULLISH DM
    if bullDistribution

        box.new(left = bar_index, right = bar_index + extendBars, top = close, bottom = close - atr * distributionATR, bgcolor = color.new(distributionColor, distTransparency), border_color = color.new(distributionColor, 10), text = 'DM', text_color = color.white, text_size = size.small)
        //====================================================
        // DISPLACEMENT FILTER
        //====================================================

displacement = math.abs(close - open) > ta.sma(math.abs(close - open), 20) * 1.5

//====================================================
// FVG IMPULSE
//====================================================

bullImpulse = close > open and close > high[1] and displacement and highVolume

bearImpulse = close < open and close < low[1] and displacement and highVolume

bullFVG = low > high[2] and low - high[2] > atr * fvgGapATR

bearFVG = high < low[2] and low[2] - high > atr * fvgGapATR

if showFVG

    if bullFVG and bullImpulse and trendBull and sessionOK

        box.new(left = bar_index - 2, right = bar_index + extendBars, top = low, bottom = high[2], bgcolor = color.new(fvgColor, fvgTransparency), border_color = color.new(fvgColor, 0), text = 'FVG', text_color = color.white, text_size = size.small)

    if bearFVG and bearImpulse and trendBear and sessionOK

        box.new(left = bar_index - 2, right = bar_index + extendBars, top = low[2], bottom = high, bgcolor = color.new(fvgColor, fvgTransparency), border_color = color.new(fvgColor, 0), text = 'FVG', text_color = color.white, text_size = size.small)

//====================================================
// SMART ORDER BLOCKS
//====================================================

// BULLISH OB
bullOB = close[1] < open[1] and close > high[1] and close > open and close - open > atr * obImpulseATR and trendBull and highVolume

// BEARISH OB
bearOB = close[1] > open[1] and close < low[1] and close < open and open - close > atr * obImpulseATR and trendBear and highVolume

//====================================================
// ORDER BLOCK BOXES
//====================================================

if showOB

    // BULLISH OB
    if bullOB

        box.new(left = bar_index - 1, right = bar_index + extendBars, top = open[1], bottom = low[1], bgcolor = color.new(bullOBColor, obTransparency), border_color = color.new(bullOBColor, 0), text = 'BULL OB', text_color = color.white, text_size = size.small)

    // BEARISH OB
    if bearOB

        box.new(left = bar_index - 1, right = bar_index + extendBars, top = high[1], bottom = open[1], bgcolor = color.new(bearOBColor, obTransparency), border_color = color.new(bearOBColor, 0), text = 'BEAR OB', text_color = color.white, text_size = size.small)
        //====================================================
        // LIQUIDITY
        //====================================================

swingHigh = ta.pivothigh(high, liqLookback, liqLookback)

swingLow = ta.pivotlow(low, liqLookback, liqLookback)

liqLineStyle = liqStyle == 'Solid' ? line.style_solid : liqStyle == 'Dotted' ? line.style_dotted : line.style_dashed

if showLiquidity

    // SWING HIGH LIQUIDITY
    if not na(swingHigh)

        line.new(x1 = bar_index - liqLookback, y1 = swingHigh, x2 = bar_index + extendBars, y2 = swingHigh, color = liqColor, width = 1, style = liqLineStyle)

        label.new(x = bar_index + extendBars, y = swingHigh, text = 'BSL', textcolor = liqColor, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)

    // SWING LOW LIQUIDITY
    if not na(swingLow)

        line.new(x1 = bar_index - liqLookback, y1 = swingLow, x2 = bar_index + extendBars, y2 = swingLow, color = liqColor, width = 1, style = liqLineStyle)

        label.new(x = bar_index + extendBars, y = swingLow, text = 'SSL', textcolor = liqColor, color = color.new(color.black, 100), style = label.style_label_left, size = size.small)

//====================================================
// TRUE ICT LIQUIDITY SWEEPS
//====================================================

swingHighSweep = ta.pivothigh(high, sweepPivot, sweepPivot)

swingLowSweep = ta.pivotlow(low, sweepPivot, sweepPivot)

var float prevHigh = na
var float prevLow = na

var int prevHighBar = na
var int prevLowBar = na

if not na(swingHighSweep)

    prevHigh := swingHighSweep
    prevHighBar := bar_index - sweepPivot
    prevHighBar

if not na(swingLowSweep)

    prevLow := swingLowSweep
    prevLowBar := bar_index - sweepPivot
    prevLowBar

//====================================================
// BEARISH SWEEP
//====================================================

bearSweep = not na(prevHigh) and high > prevHigh and close < prevHigh

//====================================================
// BULLISH SWEEP
//====================================================

bullSweep = not na(prevLow) and low < prevLow and close > prevLow

if showSweeps

    // BUY SIDE LIQUIDITY SWEEP
    if bearSweep

        line.new(x1 = prevHighBar, y1 = prevHigh, x2 = bar_index, y2 = prevHigh, color = sweepColorBear, width = sweepWidth)

        label.new(x = bar_index, y = prevHigh, text = 'LSH', style = label.style_label_down, color = color.new(sweepColorBear, 80), textcolor = color.white, size = size.small)

    // SELL SIDE LIQUIDITY SWEEP
    if bullSweep

        line.new(x1 = prevLowBar, y1 = prevLow, x2 = bar_index, y2 = prevLow, color = sweepColorBull, width = sweepWidth)

        label.new(x = bar_index, y = prevLow, text = 'LSL', style = label.style_label_up, color = color.new(sweepColorBull, 80), textcolor = color.white, size = size.small)
        //====================================================
        // TRUE ICT CHOCH
        //====================================================

chochHigh = ta.pivothigh(high, chochPivot, chochPivot)

chochLow = ta.pivotlow(low, chochPivot, chochPivot)

var float internalHigh = na
var float internalLow = na

var int internalHighBar = na
var int internalLowBar = na

if not na(chochHigh)

    internalHigh := chochHigh
    internalHighBar := bar_index - chochPivot
    internalHighBar

if not na(chochLow)

    internalLow := chochLow
    internalLowBar := bar_index - chochPivot
    internalLowBar

//====================================================
// BULLISH CHOCH
//====================================================

bullCHOCH = not na(internalHigh) and close > internalHigh and close[1] <= internalHigh

//====================================================
// BEARISH CHOCH
//====================================================

bearCHOCH = not na(internalLow) and close < internalLow and close[1] >= internalLow

//====================================================
// CHOCH LABELS
//====================================================

var int lastBullCHOCHBar = na
var int lastBearCHOCHBar = na

if showCHOCH

//====================================================
// BULLISH CHOCH
//====================================================

    if bullCHOCH and lastBullCHOCHBar != internalHighBar

        line.new(x1 = internalHighBar, y1 = internalHigh, x2 = bar_index, y2 = internalHigh, color = chochColorBull, width = 1, style = line.style_dashed)

        midXBullCHOCH = math.round((internalHighBar + bar_index) / 2)

        label.new(x = midXBullCHOCH, y = internalHigh, text = 'CHOCH', style = label.style_none, textcolor = chochColorBull, size = size.small)

        lastBullCHOCHBar := internalHighBar
        lastBullCHOCHBar

//====================================================
// BEARISH CHOCH
//====================================================

    if bearCHOCH and lastBearCHOCHBar != internalLowBar

        line.new(x1 = internalLowBar, y1 = internalLow, x2 = bar_index, y2 = internalLow, color = chochColorBear, width = 1, style = line.style_dashed)

        midXBearCHOCH = math.round((internalLowBar + bar_index) / 2)

        label.new(x = midXBearCHOCH, y = internalLow, text = 'CHOCH', style = label.style_none, textcolor = chochColorBear, size = size.small)

        lastBearCHOCHBar := internalLowBar
        lastBearCHOCHBar
        //====================================================
        // TRUE ICT BOS
        //====================================================

bosHigh = ta.pivothigh(high, bosPivot, bosPivot)

bosLow = ta.pivotlow(low, bosPivot, bosPivot)

var float trendHigh = na
var float trendLow = na

var int trendHighBar = na
var int trendLowBar = na

var bool bullishTrend = true
var bool bearishTrend = false

if not na(bosHigh)

    trendHigh := bosHigh
    trendHighBar := bar_index - bosPivot
    trendHighBar

if not na(bosLow)

    trendLow := bosLow
    trendLowBar := bar_index - bosPivot
    trendLowBar

//====================================================
// TREND SHIFT
//====================================================

if close > trendHigh and close[1] <= trendHigh

    bullishTrend := true
    bearishTrend := false
    bearishTrend

if close < trendLow and close[1] >= trendLow

    bullishTrend := false
    bearishTrend := true
    bearishTrend

//====================================================
// SMART BOS
//====================================================

bullBOS = bullishTrend and close > trendHigh and close[1] <= trendHigh and displacement and bullImpulse and highVolume

bearBOS = bearishTrend and close < trendLow and close[1] >= trendLow and displacement and bearImpulse and highVolume

//====================================================
// BOS LABELS
//====================================================

var int lastBullBOSBar = na
var int lastBearBOSBar = na

if showBOS

//====================================================
// BULLISH BOS
//====================================================

    if bullBOS and lastBullBOSBar != trendHighBar

        line.new(x1 = trendHighBar, y1 = trendHigh, x2 = bar_index, y2 = trendHigh, color = bosColorBull, width = 1, style = line.style_dashed)

        midXBullBOS = math.round((trendHighBar + bar_index) / 2)

        label.new(x = midXBullBOS, y = trendHigh, text = 'BOS', style = label.style_none, textcolor = bosColorBull, size = size.small)

        lastBullBOSBar := trendHighBar
        lastBullBOSBar

//====================================================
// BEARISH BOS
//====================================================

    if bearBOS and lastBearBOSBar != trendLowBar

        line.new(x1 = trendLowBar, y1 = trendLow, x2 = bar_index, y2 = trendLow, color = bosColorBear, width = 1, style = line.style_dashed)

        midXBearBOS = math.round((trendLowBar + bar_index) / 2)

        label.new(x = midXBearBOS, y = trendLow, text = 'BOS', style = label.style_none, textcolor = bosColorBear, size = size.small)

        lastBearBOSBar := trendLowBar
        lastBearBOSBar
        //====================================================
        // MARKET STRUCTURE HH HL LH LL
        //====================================================

ph = ta.pivothigh(high, structurePivot, structurePivot)
pl = ta.pivotlow(low, structurePivot, structurePivot)

var float lastHigh = na
var float lastLow = na

var int lastHighBar = na
var int lastLowBar = na

//====================================================
// HIGH STRUCTURE
//====================================================

if showStructure

    if not na(ph)

        currentHigh = ph
        currentHighBar = bar_index - structurePivot

        if not na(lastHigh)

            // HH
            if currentHigh > lastHigh

                line.new(x1 = lastHighBar, y1 = currentHigh, x2 = currentHighBar, y2 = currentHigh, color = color.aqua, style = line.style_dashed, width = 1)

                label.new(x = currentHighBar, y = currentHigh, text = 'HH', style = label.style_none, textcolor = color.aqua, size = size.small)

                // SELL ARROW
                label.new(x = currentHighBar, y = currentHigh + atr * 0.3, text = '▼', style = label.style_none, textcolor = sellArrowColor, size = size.large)

            // LH
            if currentHigh < lastHigh

                line.new(x1 = lastHighBar, y1 = currentHigh, x2 = currentHighBar, y2 = currentHigh, color = color.orange, style = line.style_dashed, width = 1)

                label.new(x = currentHighBar, y = currentHigh, text = 'LH', style = label.style_none, textcolor = color.orange, size = size.small)

        lastHigh := currentHigh
        lastHighBar := currentHighBar
        lastHighBar

//====================================================
// LOW STRUCTURE
//====================================================

if showStructure

    if not na(pl)

        currentLow = pl
        currentLowBar = bar_index - structurePivot

        if not na(lastLow)

            // HL
            if currentLow > lastLow

                line.new(x1 = lastLowBar, y1 = currentLow, x2 = currentLowBar, y2 = currentLow, color = color.lime, style = line.style_dashed, width = 1)

                label.new(x = currentLowBar, y = currentLow, text = 'HL', style = label.style_none, textcolor = color.lime, size = size.small)

                // BUY ARROW
                label.new(x = currentLowBar, y = currentLow - atr * 0.3, text = '▲', style = label.style_none, textcolor = buyArrowColor, size = size.large)

            // LL
            if currentLow < lastLow

                line.new(x1 = lastLowBar, y1 = currentLow, x2 = currentLowBar, y2 = currentLow, color = color.red, style = line.style_dashed, width = 1)

                label.new(x = currentLowBar, y = currentLow, text = 'LL', style = label.style_none, textcolor = color.red, size = size.small)

        lastLow := currentLow
        lastLowBar := currentLowBar
        lastLowBar

//====================================================
// CLEAN CANDLES
//====================================================

barcolor(close > open ? bullCandleColor : bearCandleColor)
````
