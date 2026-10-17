# MA + Sweep CHoCH 1.9

- url: https://www.tradingview.com/script/M6Q67PFB-MA-Sweep-CHoCH-1-9/
- type: indicator
- pine_id: PUB;b9b5e5c86ff94c8380fe9bea03545c1b
- version: 1.0

## Description

MA BREAKER BANDS + SWEEP CHoCH 2.0
A fully customizable price action confluence indicator built around three core concepts: structure, momentum, and liquidity.
Moving Averages — choose between EMA and SMA independently for each of the three lines (fast/mid/slow), with fully adjustable lengths and colors. Not locked to any preset — every parameter is yours.
Market Sweep Detection — identifies candles that grab liquidity beyond a recent high or low and close back inside the range. Detected sweeps color the entire candle (bull sweep = military green, bear sweep = brick red-brown) rather than adding chart noise with labels or markers. ATR-filtered so only candles with real range qualify.
Hammer / Doji Tint — same color scheme as sweep but lower saturation, applied only when no sweep is present on that bar. Gives visual weight to rejection candles without competing with sweep signals.
CHoCH (Change of Character) — detects structural breaks using pivot highs and lows (wick-based, not close-based). Draws a short white dashed line at the broken level lasting only a few bars — subtle enough to not clutter the chart, visible enough to mark the shift.
Candle Trend Color — entire candle body reflects MA trend state. Dark green when fast MA is above slow MA, dark red when below. Instant visual context without reading lines.
Everything — lengths, colors, MA types, wick ratios, body ratios, sweep lookback, CHoCH pivot length, line duration — is adjustable from the settings panel.

## Source Code

````pine
//@version=6
indicator('MA + Sweep CHoCH 1.9', overlay = true)

// ============================================================
// MA BANDS SETTINGS (CAMO) - EMA/SMA switch per line
// ============================================================
gEMA = 'MA Bands'
maFastType = input.string('SMA', 'Fast MA Type', options = ['EMA', 'SMA'], group = gEMA)
maFastLen = input.int(21, 'Fast Length', group = gEMA)
maMidType = input.string('SMA', 'Mid MA Type', options = ['EMA', 'SMA'], group = gEMA)
maMidLen = input.int(44, 'Mid Length', group = gEMA)
maSlowType = input.string('SMA', 'Slow MA Type', options = ['EMA', 'SMA'], group = gEMA)
maSlowLen = input.int(89, 'Slow Length', group = gEMA)

camoF = color.new(#D2B48C, 0)
camoM = color.new(#8B7355, 0)
camoS = color.new(#696969, 0)

fEma = ta.ema(close, maFastLen)
fSma = ta.sma(close, maFastLen)
mEma = ta.ema(close, maMidLen)
mSma = ta.sma(close, maMidLen)
sEma = ta.ema(close, maSlowLen)
sSma = ta.sma(close, maSlowLen)

f = maFastType == 'EMA' ? fEma : fSma
m = maMidType == 'EMA' ? mEma : mSma
s = maSlowType == 'EMA' ? sEma : sSma

plot(f, color = camoF, title = 'MA Fast', linewidth = 2)
plot(m, color = camoM, title = 'MA Mid', linewidth = 2)
plot(s, color = camoS, title = 'MA Slow', linewidth = 2)

// ============================================================
// MARKET SWEEP (liquidity grab)
// ============================================================
gSWEEP = 'Market Sweep'
sweepLookback = input.int(10, 'Sweep Lookback Bars', group = gSWEEP, minval = 2)
sweepWickRatio = input.float(0.5, 'Min Wick Ratio', group = gSWEEP, minval = 0.1, maxval = 0.95, step = 0.05)
showSweepGlow = input.bool(true, 'Show Sweep Candle Glow', group = gSWEEP)
sweepBullGlow = color.new(#4B5320, 0)
sweepBearGlow = color.new(#8B3A3A, 0)

prevHighest = ta.highest(high, sweepLookback)[1]
prevLowest = ta.lowest(low, sweepLookback)[1]

candleRange = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

bullishSweep = low < prevLowest and close > prevLowest and candleRange > 0 and lowerWick / candleRange >= sweepWickRatio
bearishSweep = high > prevHighest and close < prevHighest and candleRange > 0 and upperWick / candleRange >= sweepWickRatio

sweepBarColor = bullishSweep ? sweepBullGlow : bearishSweep ? sweepBearGlow : na

barcolor(showSweepGlow ? sweepBarColor : na, title = 'Sweep Candle Glow')

// ============================================================
// HAMMER / DOJI (large wicks) - subtle candle tint
// ============================================================
gHAM = 'Hammer Doji'
hamWickRatio = input.float(0.6, 'Min Wick Ratio Hammer', group = gHAM, minval = 0.3, maxval = 0.9, step = 0.05)
hamBodyMax = input.float(0.3, 'Max Body Ratio Hammer', group = gHAM, minval = 0.05, maxval = 0.6, step = 0.05)
dojiBodyMax = input.float(0.1, 'Max Body Ratio Doji', group = gHAM, minval = 0.02, maxval = 0.2, step = 0.01)
showHamTint = input.bool(true, 'Show Hammer Doji Candle Tint', group = gHAM)

hamBullTint = color.new(#4B5320, 60)
hamBearTint = color.new(#8B3A3A, 60)

bodySize = math.abs(close - open)
bodyRatio = candleRange > 0 ? bodySize / candleRange : 0

isHammerBull = candleRange > 0 and bodyRatio <= hamBodyMax and lowerWick / candleRange >= hamWickRatio and upperWick < lowerWick
isHammerBear = candleRange > 0 and bodyRatio <= hamBodyMax and upperWick / candleRange >= hamWickRatio and lowerWick < upperWick
isDoji = candleRange > 0 and bodyRatio <= dojiBodyMax

hamBarColor = isHammerBull ? hamBullTint : isHammerBear ? hamBearTint : na
hamShown = showHamTint and na(sweepBarColor)

barcolor(hamShown ? hamBarColor : na, title = 'Hammer Doji Candle Tint')

// ============================================================
// CHoCH (Change of Character) - short white dashed-style line
// ============================================================
gCHOCH = 'CHoCH'
chochSwingLen = input.int(5, 'Swing Pivot Length', group = gCHOCH, minval = 2)
chochLineBars = input.int(8, 'CHoCH Line Length Bars', group = gCHOCH, minval = 3, maxval = 15)
chochWhiteColor = color.new(color.white, 20)

swingHigh = ta.pivothigh(high, chochSwingLen, chochSwingLen)
swingLow = ta.pivotlow(low, chochSwingLen, chochSwingLen)

var float hiSwing = na
var float loSwing = na
var int internalTrend = 0

newHigh = not na(swingHigh)
newLow = not na(swingLow)

hiSwing := newHigh ? swingHigh : hiSwing
loSwing := newLow ? swingLow : loSwing

chochBear = internalTrend >= 0 and not na(loSwing) and low < loSwing and close < loSwing
chochBull = internalTrend <= 0 and not na(hiSwing) and high > hiSwing and close > hiSwing

internalTrend := chochBear ? -1 : chochBull ? 1 : internalTrend

var float chochLevel = na
var int chochStartBar = na

chochLevel := chochBear ? loSwing : chochBull ? hiSwing : chochLevel
chochStartBar := chochBear or chochBull ? bar_index : chochStartBar

barsSinceChoch = na(chochStartBar) ? 999999 : bar_index - chochStartBar
chochLineVisible = barsSinceChoch <= chochLineBars

plot(chochLineVisible ? chochLevel : na, style = plot.style_circles, color = chochWhiteColor, linewidth = 2, title = 'CHoCH Short Line')

// ============================================================
// ALERTS
// ============================================================
alertcondition(bullishSweep, title = 'Bullish Sweep', message = 'Liquidity sweep detected at the low')
alertcondition(bearishSweep, title = 'Bearish Sweep', message = 'Liquidity sweep detected at the high')
alertcondition(chochBull, title = 'CHoCH Bull', message = 'Change of Character - bullish structure break')
alertcondition(chochBear, title = 'CHoCH Bear', message = 'Change of Character - bearish structure break')
````
