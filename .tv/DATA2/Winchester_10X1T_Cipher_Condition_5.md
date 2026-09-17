<!-- tradingview-pine-id: PUB;4cfd9c6bfe7b40a7802002f510ba25a0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Winchester 10X1T Cipher | Condition 5

Source: https://www.tradingview.com/script/vuxjsTU2-Winchester-10X1T-Cipher-Zone-Gated-WaveTrend-Dots/

## Description

WHAT THIS IS
A single-pane momentum panel that marks the exact bar on which a WaveTrend cycle turns while price sits in an extreme zone. It is a confluence display: WaveTrend for the cycle turn, an RSI+MFI pressure band for money-flow context, RSI for the trend regime, and a Stochastic RSI pair for the short-term swing. All four sit in one pane, so a trader does not have to read four windows to answer one question: is this turn happening in a place where a turn matters?

HOW IT IS CALCULATED
WaveTrend follows the classic construction published by LazyBear: an EMA of the source (HLC3, channel length 9), an EMA of the absolute distance to it, a channel index scaled by 0.015, then an EMA of that index (length 12) as the fast line and a 3-period SMA of the fast line as the signal line. The area between both lines is filled so the cycle body is visible at a glance.
The pressure band uses the RSI+MFI area concept popularised by VuManChu's Cipher B: the average of (close-open)/(high-low) over 60 bars, scaled and drawn as a band at the bottom of the pane - white above zero, gold below.
RSI (14) is plotted in three states: white at or below 30, gold at or above 60, purple in between.
Stochastic RSI (14/14, K and D smoothed by 3) is plotted on a log-transformed source.

THE DOTS
A dot is printed only when the WaveTrend fast line crosses its signal line AND the signal line is already inside an extreme zone. Two sizes are used on each side, so the quality of the location is visible without reading numbers:
- Small dot: the cross happens between the first and the second zone (53 to 60 above, -53 to -60 below).
- Large dot: the cross happens beyond the second zone (60 and above, -60 and below).
Top dots are sky blue; bottom dots are white with a gold core. Each of the four dot types has its own alert condition.

WHY THE COMBINATION
WaveTrend on its own crosses constantly in the middle of the range, which is where most of its false signals live. Gating the cross on the zone removes those. The RSI colour states and the pressure band then answer the second question - whether the turn is a counter-trend stab or a continuation in the direction of the dominant flow. RSI at 60+ (gold) with a top dot is a different situation from RSI at 30 (white) with a bottom dot, and the panel shows both facts on the same bar without adding a second indicator.

HOW TO USE IT
Add it to any symbol and any timeframe. Nothing repaints once a bar has closed, so wait for the bar to close before acting on a dot. Treat the large dots as the primary event and the small dots as early warnings. All lengths, zone levels and visibility switches are inputs, so the zones can be tightened or widened per market. The four alert conditions can be wired to TradingView alerts.

CREDITS
The WaveTrend oscillator is the open-source work of LazyBear; the RSI+MFI area concept comes from VuManChu's open-source Cipher B. This script re-implements both in Pine v6 and adds the zone-gated two-size dot logic, the RSI regime colouring, the combined pane layout and the alert set. It is published open source so that anyone can read exactly what it does.

---

## Source Code

````pine
//@version=6
indicator("Winchester 10X1T Cipher | Condition 5", shorttitle="10X1TCipher", overlay=false, precision=2)

// =====================
// INPUTS
// =====================
wtShow       = input.bool(true, "Show WaveTrend", group="WaveTrend Settings")
wtBuyShow    = input.bool(true, "Show Buy dots", group="WaveTrend Settings")
wtSellShow   = input.bool(true, "Show Sell dots", group="WaveTrend Settings")
wtFastShow   = input.bool(true, "Show Fast WT", group="WaveTrend Settings")
wtChannelLen = input.int(9, "WT Channel Length", group="WaveTrend Settings")
wtAverageLen = input.int(12, "WT Average Length", group="WaveTrend Settings")
wtMALen      = input.int(3, "WT MA Length", group="WaveTrend Settings")
wtSource     = input.source(hlc3, "WT Source", group="WaveTrend Settings")

obLevel1 = input.int(53, "WT Overbought Level 1", group="WaveTrend Settings")
obLevel2 = input.int(60, "WT Overbought Level 2", group="WaveTrend Settings")
obLevel3 = input.int(100, "WT Overbought Level 3", group="WaveTrend Settings")
osLevel1 = input.int(-53, "WT Oversold Level 1", group="WaveTrend Settings")
osLevel2 = input.int(-60, "WT Oversold Level 2", group="WaveTrend Settings")
osLevel3 = input.int(-75, "WT Oversold Level 3", group="WaveTrend Settings")

mfiShow       = input.bool(true, "Show MFI", group="MFI Settings")
mfiPeriod     = input.int(60, "MFI Period", group="MFI Settings")
mfiMultiplier = input.float(150.0, "MFI Area Multiplier", group="MFI Settings")
mfiPosY       = input.float(2.5, "MFI Area Y Pos", group="MFI Settings")

rsiShow       = input.bool(true, "Show RSI", group="RSI Settings")
rsiSource     = input.source(close, "RSI Source", group="RSI Settings")
rsiLen        = input.int(14, "RSI Length", group="RSI Settings")
rsiOversold   = input.int(30, "RSI Oversold", group="RSI Settings")
rsiOverbought = input.int(60, "RSI Overbought", group="RSI Settings")

stochShow     = input.bool(true, "Show Stochastic RSI", group="Stoch Settings")
stochUseLog   = input.bool(true, "Use Log", group="Stoch Settings")
stochAvg      = input.bool(false, "Use Average of both K & D", group="Stoch Settings")
stochSource   = input.source(close, "Stochastic RSI Source", group="Stoch Settings")
stochLen      = input.int(14, "Stochastic RSI Length", group="Stoch Settings")
stochRsiLen   = input.int(14, "RSI Length", group="Stoch Settings")
stochKSmooth  = input.int(3, "Stochastic RSI K Smooth", group="Stoch Settings")
stochDSmooth  = input.int(3, "Stochastic RSI D Smooth", group="Stoch Settings")

// =====================
// COLORS
// =====================
skyBlue      = color.rgb(84, 235, 255)
darkBlue     = color.rgb(56, 145, 230)
pureWhite    = color.rgb(255, 255, 255)
gold         = color.rgb(184, 138, 16)
purple       = color.rgb(107, 53, 201)
grayNeutral  = color.rgb(105, 110, 125)
nearBlack    = color.rgb(17, 17, 17)
vwapDark     = color.new(color.rgb(15, 95, 102), 35)

// =====================
// FUNCTIONS
// =====================
f_wavetrend(_src, _chlen, _avg, _malen) =>
    esa = ta.ema(_src, _chlen)
    de  = ta.ema(math.abs(_src - esa), _chlen)
    ci  = (_src - esa) / (0.015 * de)
    wt1 = ta.ema(ci, _avg)
    wt2 = ta.sma(wt1, _malen)
    vwap = wt1 - wt2
    [wt1, wt2, vwap]

f_rsimfi(_period, _multiplier) =>
    ta.sma(((close - open) / math.max(high - low, syminfo.mintick)) * _multiplier, _period) - mfiPosY

f_stochrsi(_src, _stochlen, _rsilen, _smoothk, _smoothd, _log, _avg) =>
    srcAdj = _log ? math.log(math.max(_src, syminfo.mintick)) : _src
    rsiVal = ta.rsi(srcAdj, _rsilen)
    kRaw   = ta.sma(ta.stoch(rsiVal, rsiVal, rsiVal, _stochlen), _smoothk)
    dVal   = ta.sma(kRaw, _smoothd)
    kVal   = _avg ? (kRaw + dVal) / 2.0 : kRaw
    [kVal, dVal]

// =====================
// CALCULATIONS
// =====================
[wt1, wt2, wtVwap] = f_wavetrend(wtSource, wtChannelLen, wtAverageLen, wtMALen)
mfiArea = f_rsimfi(mfiPeriod, mfiMultiplier)
rsiVal  = ta.rsi(rsiSource, rsiLen)
[stochK, stochD] = f_stochrsi(stochSource, stochLen, stochRsiLen, stochKSmooth, stochDSmooth, stochUseLog, stochAvg)

rsiColor = rsiVal <= rsiOversold ? pureWhite : rsiVal >= rsiOverbought ? gold : purple
mfiColor = mfiArea > 0 ? color.new(pureWhite, 45) : color.new(gold, 45)

wtCrossUp   = ta.crossover(wt1, wt2)
wtCrossDown = ta.crossunder(wt1, wt2)

// =====================
// CLEAN DOT LOGIC
// =====================

// TOP SECTION
topBigDot   = wtCrossDown and wt2 >= obLevel2
topSmallDot = wtCrossDown and wt2 >= obLevel1 and wt2 < obLevel2

// BOTTOM SECTION
bottomBigDot   = wtCrossUp and wt2 <= osLevel2
bottomSmallDot = wtCrossUp and wt2 <= osLevel1 and wt2 > osLevel2

// =====================
// PLOTS
// =====================
plot(0, title="Zero", color=color.new(pureWhite, 55), linewidth=1)

mfiTop = plot(mfiShow ? -95 : na, title="MFI Top", color=color.new(color.black, 100))
mfiBot = plot(mfiShow ? -99 : na, title="MFI Bottom", color=color.new(color.black, 100))
fill(mfiTop, mfiBot, title="MFI Bar", color=mfiColor)

wt1Area = plot(wtShow ? wt1 : na, title="WT Wave 1 Area", color=color.new(darkBlue, 0), linewidth=2, style=plot.style_area)
wt2Area = plot(wtShow ? wt2 : na, title="WT Wave 2 Area", color=color.new(skyBlue, 0), linewidth=2, style=plot.style_area)
fill(wt1Area, wt2Area, title="WT Fill", color=wt1 >= wt2 ? color.new(skyBlue, 35) : color.new(darkBlue, 35))

plot(wtFastShow ? wtVwap : na, title="VWAP", color=vwapDark, style=plot.style_area, linewidth=2)
plot(mfiShow ? mfiArea : na, title="MFI Area", color=mfiColor, style=plot.style_area)

plot(wtShow ? wt1 : na, title="WT1 Line", color=color.new(darkBlue, 0), linewidth=2)
plot(wtShow ? wt2 : na, title="WT2 Line", color=color.new(skyBlue, 0), linewidth=2)

plot(rsiShow ? rsiVal : na, title="RSI", color=rsiColor, linewidth=2)
plot(stochShow ? stochK : na, title="Stoch K", color=grayNeutral, linewidth=1)
plot(stochShow ? stochD : na, title="Stoch D", color=nearBlack, linewidth=1)

hline(obLevel1, "OB1", color=color.new(color.red, 40), linestyle=hline.style_dotted)
hline(osLevel1, "OS1", color=color.new(color.green, 40), linestyle=hline.style_dotted)
hline(0, "Center", color=color.new(pureWhite, 70), linestyle=hline.style_dotted)

// =====================
// DOTS
// =====================

// TOP small = sky blue
plotshape(wtSellShow and topSmallDot ? wt2 : na, title="Top Small Dot", style=shape.circle, location=location.absolute, color=skyBlue, size=size.tiny)

// TOP big = outer sky blue, inner dark blue
plotshape(wtSellShow and topBigDot ? wt2 : na, title="Top Big Dot Outer", style=shape.circle, location=location.absolute, color=skyBlue, size=size.small)
plotshape(wtSellShow and topBigDot ? wt2 : na, title="Top Big Dot Inner", style=shape.circle, location=location.absolute, color=darkBlue, size=size.tiny)

// BOTTOM small = white
plotshape(wtBuyShow and bottomSmallDot ? wt2 : na, title="Bottom Small Dot", style=shape.circle, location=location.absolute, color=pureWhite, size=size.tiny)

// BOTTOM big = outer white, inner gold
plotshape(wtBuyShow and bottomBigDot ? wt2 : na, title="Bottom Big Dot Outer", style=shape.circle, location=location.absolute, color=pureWhite, size=size.small)
plotshape(wtBuyShow and bottomBigDot ? wt2 : na, title="Bottom Big Dot Inner", style=shape.circle, location=location.absolute, color=gold, size=size.tiny)

// =====================
// ALERTS
// =====================
alertcondition(topBigDot, title="Top Big Dot", message="Winchester 10X1T Cipher Top Big Dot")
alertcondition(topSmallDot, title="Top Small Dot", message="Winchester 10X1T Cipher Top Small Dot")
alertcondition(bottomBigDot, title="Bottom Big Dot", message="Winchester 10X1T Cipher Bottom Big Dot")
alertcondition(bottomSmallDot, title="Bottom Small Dot", message="Winchester 10X1T Cipher Bottom Small Dot")
````
