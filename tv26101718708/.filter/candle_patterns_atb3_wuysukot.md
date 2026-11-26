# Candle Patterns - ATB3

- url: https://www.tradingview.com/script/WuYSuKOT/
- type: indicator
- pine_id: PUB;99b20a825dec4046857b6e0acdc7b0e8
- version: 15.0

## Description

What it does
Marks the most reliable candlestick patterns directly on the chart, sorted by strength. Every pattern uses strict rule-based detection — no approximations, no "looks kinda like it" matches.

Top-6 Reversal Setups (ranked from strongest):

#	Pattern	Direction	Bars	Core rule
1	Retracing Wicks	Bearish	2	green→red, both with similar upper wicks (10-20% diff)
2	Advancing Wicks	Bullish	2	red→green, both with similar lower wicks (10-20% diff)
3	Evening Star	Bearish	3	green → small body → red, closes below midpoint of first candle
4	Morning Star	Bullish	3	red → small body → green, closes above midpoint of first candle
5	Tweezer Top	Bearish	2	green→red, highs aligned (±15% of range)
6	Tweezer Bottom	Bullish	2	red→green, lows aligned (±15% of range)
Other strong setups (toggleable):

Hammer / Shooting Star — single-candle reversals with long wick (≥2× body)
Dragonfly / Gravestone Doji — doji variants with one-sided rejection
Inverted Hammer / Hanging Man — same shape, opposite context
Bullish / Bearish Engulfing — body engulfs prior body, requires wick on breakout side
3 Line Strike — three same-direction candles + a fourth that engulfs all three
Worst patterns (off by default, available for awareness):

3 White Soldiers / 3 Black Crows — late entry, poor R:R
Bullish / Bearish Marubozu — no wicks, weak momentum-shift signal
Key features

Trend context filter — Reversal patterns only fire in the correct trend direction. Sideways markets are detected via EMA slope and skipped (default: EMA21, 5-bar lookback, threshold 0.2× ATR20).
Color sequence guard — Reversal patterns require the proper candle-color sequence (e.g. Retracing Wicks needs a green candle followed by a red candle).
Consecutive-bar deduplication — Multi-bar patterns don't fire twice in a row.
Wick minimum size — Both relative (≥30% of body) and absolute (≥10% of ATR), filtering out micro-wick noise.
Mutually exclusive logic — Tweezer and Retracing/Advancing Wicks won't both fire on the same candle pair.
Auto label stacking — When multiple patterns fire on the same candle, labels stack vertically instead of overlapping.
Confirmed-bar only — Labels appear only after the bar closes (barstate.isconfirmed), no flickering realtime signals.
Alerts for all Top-6 plus Hammer and Shooting Star.
Tunable inputs

Min wick % of body (default 30) — threshold for a "significant" wick
Max wick diff % (default 20) — upper bound for Adv/Retr Wicks
Tweezer max wick diff % (default 5) — boundary between Tweezer and Wicks patterns
Tweezer high/low align % (default 15) — how close wick tips must be
Min absolute wick size (× ATR) (default 0.10) — minimum wick size in ATR units
Doji max body % (default 10) — body size threshold for doji classification
EMA length / slope lookback / slope strength — trend filter tuning
Label stack spacing / first label offset — visual layout tuning
Recommended usage

Never trade patterns in isolation — A pattern is the confirmation, not the reason. Combine with support/resistance, Fibonacci, order blocks, or RSI divergence.
Never in sideways markets — The built-in trend filter handles this by default, but can be turned off.
Prioritize the Top-6 — The "other strong patterns" are useful confluences, but the numbered setups have the best statistical win rate.
Backtest on your symbol/timeframe — Default thresholds are starting points; each asset has its own volatility profile worth tuning for.
Credits
Pattern definitions, ranking, and rule set are based on the "Ultimate Candlestick Patterns Guide" from the VIP Bootcamp series by Crypto Claudius Deutsch. Pine v6 implementation.

Disclaimer
This is a pattern visualization tool, not financial advice or a trading signal. Trade at your own risk. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Candle Patterns - ATB", "CP", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)
//
gT = "Top-6 Setups (numbered)"
sWicks   = input.bool(true , "#1/#2 Retracing / Advancing Wicks", group=gT)
sStar    = input.bool(true , "#3/#4 Evening / Morning Star",      group=gT)
sTweezer = input.bool(true , "#5/#6 Tweezer Top / Bottom",        group=gT)
sSBS     = input.bool(true , "#7/#8 Side by Side (4-candle Reversal)", group=gT)

gS = "Other strong patterns"
sHammer  = input.bool(true , "Hammer / Shooting Star (top single)", group=gS)
sDoji    = input.bool(true , "Dragonfly / Gravestone Doji",         group=gS)
sHanging = input.bool(true , "Inv. Hammer / Hanging Man",           group=gS)
sEngulf  = input.bool(true , "Bullish / Bearish Engulfing",         group=gS)
s3Line   = input.bool(true , "3 Line Strike",                       group=gS)

gW = "Worst patterns (off by default)"
sSoldiers = input.bool(false, "3 White Soldiers / Black Crows", group=gW)
sMarubozu = input.bool(false, "Marubozu",                       group=gW)

gC = "Context filter"
useTrend       = input.bool(true , "Skip sideways (require trend)",       group=gC)
useTrendForStar= input.bool(false, "Apply trend filter to Morning/Evening Star",  group=gC)
emaLen    = input.int (21   , "Trend EMA length",      minval=2,     group=gC)
slopeBack = input.int (5    , "Slope lookback (bars)", minval=1,     group=gC)
slopeMult = input.float(0.2 , "Slope strength (x ATR20)", step=0.05, group=gC)

gP = "Pattern thresholds"
wickMinPct    = input.float(30.0, "Min wick % of candle RANGE (Adv/Retr/Tweezer)", group=gP)
tweezerLenTol = input.float(10.0, "Tweezer max wick length diff %", group=gP)
hiAlignPct    = input.float(15.0, "Tweezer high/low align % of range",  group=gP, tooltip="How close Tweezer tips must be to count as aligned.")
advRetrTipPct = input.float(30.0, "Adv/Retr max wick-tip distance % of range", group=gP, tooltip="Tops (Retr) / bottoms (Adv) of the two wicks must be within this percent of the smaller candle's range.")
sbsCloseTolPct= input.float(20.0, "SBS: C3.close vs C2.open distance % of avg range", group=gP, tooltip="SBS rule: the 3rd candle close must be within this percent of the 4-bar avg range of the 2nd candle OPEN.")
minWickAtr    = input.float(0.10, "Min absolute wick size (x ATR)", step=0.05, group=gP)
dojiBodyPct   = input.float(10.0, "Doji max body % of range",           group=gP)
starBodyPct   = input.float(40.0, "M/E Star: middle body max % of its range", group=gP)

gE = "EMAs (overlay)"
showEma21  = input.bool(true ,   "Show EMA 21",       group=gE, inline="21")
ema21Len   = input.int (21,      "Length",            group=gE, inline="21", minval=1)
ema21Col   = input.color(#E2FF00, "",                 group=gE, inline="21")
ema21W     = input.int (2,       "Width",             group=gE, inline="21", minval=1, maxval=5)

showEma50  = input.bool(true ,   "Show EMA 50",       group=gE, inline="50")
ema50Len   = input.int (50,      "Length",            group=gE, inline="50", minval=1)
ema50Col   = input.color(#9598A1, "",                 group=gE, inline="50")
ema50W     = input.int (2,       "Width",             group=gE, inline="50", minval=1, maxval=5)

showEma200 = input.bool(true ,   "Show EMA 200",      group=gE, inline="200")
ema200Len  = input.int (200,     "Length",            group=gE, inline="200", minval=1)
ema200Col  = input.color(#FF9800, "",                 group=gE, inline="200")
ema200W    = input.int (3,       "Width",             group=gE, inline="200", minval=1, maxval=5)

gF = "Fibonacci retracement (last 2 pivots)"
showFib        = input.bool(true , "Show Fib of last 2 pivots",                  group=gF)
fibPivLen4h    = input.int (2    , "Pivot length @ 4h tier", minval=1, maxval=50, group=gF, tooltip="Pivot left/right length applied when the Fib uses the 4h timeframe (i.e. on any chart TF below Daily). Default 2 = aggressive.")
fibPivLen1D    = input.int (3    , "Pivot length @ Daily/Weekly tier", minval=1, maxval=50, group=gF, tooltip="Pivot left/right length applied when the Fib uses Daily/Weekly timeframe (i.e. on D / W chart). Default 3.")
fibColor       = input.color(color.gray, "Default line color (0/0.382/0.5/1)",  group=gF)
fibColor618    = input.color(#FFD700, "0.618 Golden line color",                group=gF)
fibColor786    = input.color(#2196F3, "0.786 line color",                       group=gF)
fibColor882    = input.color(#2196F3, "0.882 line color",                       group=gF)
fibTransp      = input.int (50   , "Line transparency (0-100)", minval=0, maxval=100, group=gF)
fibWidth       = input.int (1    , "Line width", minval=1, maxval=4,            group=gF)
showFibLabel   = input.bool(true , "Show value labels",                          group=gF)
fibLabelOffset = input.int (8    , "Label X-offset (bars right of current)", minval=0, maxval=100, group=gF, tooltip="Pushes Fib labels right of the current bar so they don't overlap the price action.")
fibLabelTextCol = input.color(color.white, "Label text color",                  group=gF)
fibLabelBgTransp= input.int (60, "Label background transparency", minval=0, maxval=100, group=gF)
fibLabelSize   = input.string("small", "Label text size", options=["tiny","small","normal","large"], group=gF)
showPivotMarks = input.bool(true , "Show pivot markers (PH/PL)", group=gF, tooltip="Draws small markers at the detected pivot points so you can see what the Fib is anchored to.")
show0_100      = input.bool(true , "Show 0% / 100% boundary lines",              group=gF)
showFib236     = input.bool(false, "0.236", group=gF, inline="fibA")
showFib382     = input.bool(true , "0.382", group=gF, inline="fibA")
showFib500     = input.bool(true , "0.500", group=gF, inline="fibB")
showFib618     = input.bool(true , "0.618 (Golden Pocket)", group=gF, inline="fibB")
showFib786     = input.bool(true , "0.786", group=gF, inline="fibC")
showFib882     = input.bool(true , "0.882", group=gF, inline="fibC")
showGoldenPocket = input.bool(true, "Fill Golden Pocket (0.5–0.618)", group=gF)
goldenColor    = input.color(#FFD700, "Golden Pocket color", group=gF, inline="gp")
goldenTransp   = input.int (85, "Transparency", minval=0, maxval=100, group=gF, inline="gp")

gFVG = "Fair Value Gaps (FVG)"
showFVG        = input.bool(true,  "Show Fair Value Gaps", group=gFVG)
fvgBullCol     = input.color(color.new(#00FF7F, 75), "Bullish FVG (BISI)", group=gFVG)
fvgBearCol     = input.color(color.new(#FF6347, 75), "Bearish FVG (SIBI)", group=gFVG)
fvgMinAtrPct   = input.float(10.0, "Min FVG size (% of ATR20)", group=gFVG, minval=0, tooltip="Filters micro-gaps below this size. Set to 0 to show all.")
fvgMaxAge      = input.int(150,   "Max FVG age (bars)", group=gFVG, minval=10, maxval=500, tooltip="Remove unfilled FVGs older than this.")
fvgShowIFVG    = input.bool(true,  "Mark Inverse FVG (wick-through)", group=gFVG, tooltip="When a wick reaches past an FVG (low<bot for bull / high>top for bear), the FVG is treated as inverted and stops extending.")

gLSOB = "LSOB (Liquidity Sweep Order Block)"
showLSOB      = input.bool(true,  "Show LSOB", group=gLSOB)
lsobLookback  = input.int(20,     "Sweep lookback (bars)", minval=3, maxval=200, group=gLSOB, tooltip="A bar's wick must reach beyond the lowest low / highest high of the previous N bars to count as a sweep.")
lsobConfR     = input.int(3,      "Swing confirmation (bars right)", minval=1, maxval=20, group=gLSOB, tooltip="Bars after the sweep candle that must NOT break its extreme. Only real swing tops/bottoms become LSOBs. Higher = stricter & more delay. 3 = solid default.")
lsobBullCol   = input.color(color.new(#00FF7F, 80), "Bullish LSOB", group=gLSOB)
lsobBearCol   = input.color(color.new(#FF6347, 80), "Bearish LSOB", group=gLSOB)
lsobMaxAge    = input.int(200,    "Max LSOB age (bars)", minval=10, maxval=1000, group=gLSOB, tooltip="Remove untouched LSOBs older than this.")
lsobBorderCol = input.color(color.new(color.white, 60), "Border color", group=gLSOB)
lsobShowText  = input.bool(true,  "Show 'LSOB' text in box", group=gLSOB)
lsobTextCol   = input.color(color.white, "Text color", group=gLSOB, inline="ltxt")
lsobTextSize  = input.string("small", "Text size", options=["tiny","small","normal","large"], group=gLSOB, inline="ltxt")

gGUSS = "GUSS Sniper Entry (Kryptomano)"
showGUSS         = input.bool(true,  "Show GUSS setups", group=gGUSS, tooltip="HH overextended above EMA21 → correction WITHOUT counter-candle → entry at EMA50 (ideally Fib 0.5/0.618/0.786). Mirror for shorts.")
gussLookback     = input.int(20,     "HH/LL lookback (bars)", minval=5, maxval=200, group=gGUSS)
gussOverExtAtr   = input.float(1.5,  "Overextension from EMA21 (x ATR20)", step=0.1, minval=0.0, group=gGUSS, tooltip="Required distance of the HH above EMA21 (LL below EMA21), in ATR units. Higher = stricter.")
gussRequireImp   = input.bool(true,  "Require impulsive HH/LL candle", group=gGUSS, tooltip="HH candle must close green; LL candle must close red.")
gussMaxWait      = input.int(30,     "Max bars to wait for EMA50 touch", minval=3, maxval=200, group=gGUSS)

gV = "Visuals"
labelSize  = input.string("small", "Label size", options=["tiny","small","normal","large"], group=gV)
stackSpace = input.float(0.9, "Label stack spacing (x ATR)", step=0.1, minval=0.2, group=gV)
firstOff   = input.float(0.5, "First label offset (x ATR)", step=0.1, minval=0.0, group=gV)
labelDecay = input.int(6, "Cross-bar collision range (bars)", minval=0, maxval=30, group=gV, tooltip="Within this many bars, new labels avoid overlapping the previous same-direction label. 0 disables.")

bodyV   = math.abs(close - open)
uWick   = high - math.max(open, close)
lWick   = math.min(open, close) - low
rng     = high - low
green   = close > open
red     = close < open
hasBody = bodyV > 0

ema21V  = ta.ema(close, ema21Len)
ema50V  = ta.ema(close, ema50Len)
ema200V = ta.ema(close, ema200Len)
plot(showEma21  ? ema21V  : na, "EMA 21",  color=ema21Col,  linewidth=ema21W)
plot(showEma50  ? ema50V  : na, "EMA 50",  color=ema50Col,  linewidth=ema50W)
plot(showEma200 ? ema200V : na, "EMA 200", color=ema200Col, linewidth=ema200W)

ema   = ta.ema(close, emaLen)
slope = ema - ema[slopeBack]
atrV  = ta.atr(20)
trendUp     = useTrend ? slope >  atrV * slopeMult : true
trendDn     = useTrend ? slope < -atrV * slopeMult : true
notSideways = useTrend ? (trendUp or trendDn) : true
minWickAbs  = atrV * minWickAtr

mStarTrend = useTrendForStar ? trendDn : true
eStarTrend = useTrendForStar ? trendUp : true

bullEngRaw = green and red[1] and close > open[1] and open < close[1] and lWick > 0 and notSideways
bearEngRaw = red and green[1] and open > close[1] and close < open[1] and uWick > 0 and notSideways
bullEng = bullEngRaw and not bullEngRaw[1]
bearEng = bearEngRaw and not bearEngRaw[1]

hmrShape   = hasBody and lWick >= bodyV * 2.0 and uWick <= bodyV * 0.3 and lWick >= minWickAbs
sStarShape = hasBody and uWick >= bodyV * 2.0 and lWick <= bodyV * 0.3 and uWick >= minWickAbs
hammer     = hmrShape   and green and trendDn
shootStar  = sStarShape and red   and trendUp
invHammer  = sStarShape and green and trendUp
hangingMan = hmrShape   and red   and trendUp

isDoji     = rng > 0 and bodyV <= rng * (dojiBodyPct / 100)
dragonfly  = isDoji and lWick >= rng * 0.6 and uWick <= rng * 0.1 and trendDn
gravestone = isDoji and uWick >= rng * 0.6 and lWick <= rng * 0.1 and trendUp

wmF        = wickMinPct / 100
hiAlignF   = hiAlignPct / 100
tweezerWmF = tweezerLenTol / 100
advRetrTipF= advRetrTipPct / 100
lw0 = lWick
lw1 = lWick[1]
uw0 = uWick
uw1 = uWick[1]
rng0 = rng
rng1 = rng[1]

lwOK = rng0 > 0 and rng1 > 0 and lw0 >= rng0 * wmF and lw1 >= rng1 * wmF and lw0 >= minWickAbs and lw1 >= minWickAbs
uwOK = rng0 > 0 and rng1 > 0 and uw0 >= rng0 * wmF and uw1 >= rng1 * wmF and uw0 >= minWickAbs and uw1 >= minWickAbs

lwMaxLen = math.max(lw0, lw1)
uwMaxLen = math.max(uw0, uw1)
lwLenDiff = lwMaxLen > 0 ? math.abs(lw0 - lw1) / lwMaxLen : 1.0
uwLenDiff = uwMaxLen > 0 ? math.abs(uw0 - uw1) / uwMaxLen : 1.0

bearSeq = green[1] and red
bullSeq = red[1]   and green
rngMin   = math.min(rng0, rng1)
tweezerAlign = rngMin * hiAlignF
advRetrAlign = rngMin * advRetrTipF
diffHi   = high - high[1]
diffLo   = low  - low[1]

tweezerTopRaw = bearSeq and uwOK and uwLenDiff <= tweezerWmF and rngMin > 0 and math.abs(diffHi) <= tweezerAlign and trendUp
tweezerBotRaw = bullSeq and lwOK and lwLenDiff <= tweezerWmF and rngMin > 0 and math.abs(diffLo) <= tweezerAlign and trendDn

retrWicksRaw  = uwOK and uw0 < uw1 and uwLenDiff > tweezerWmF and rngMin > 0 and high < high[1] and math.abs(diffHi) <= advRetrAlign and trendUp
advWicksRaw   = lwOK and lw0 < lw1 and lwLenDiff > tweezerWmF and rngMin > 0 and low  > low[1]  and math.abs(diffLo) <= advRetrAlign and trendDn

tweezerTop = tweezerTopRaw and not tweezerTopRaw[1]
tweezerBot = tweezerBotRaw and not tweezerBotRaw[1]
retrWicks  = retrWicksRaw  and not retrWicksRaw[1]
advWicks   = advWicksRaw   and not advWicksRaw[1]

sbsCloseF = sbsCloseTolPct / 100
sbsAvgRng = (rng + rng[1] + rng[2] + rng[3]) / 4
sbs23Aligned = sbsAvgRng > 0 and math.abs(close[1] - open[2]) <= sbsAvgRng * sbsCloseF
sbsBullSeq = red[3]   and green[2] and red[1]   and green
sbsBearSeq = green[3] and red[2]   and green[1] and red
sbsBullRaw = sbsBullSeq and sbs23Aligned
sbsBearRaw = sbsBearSeq and sbs23Aligned
sbsBull = sbsBullRaw and not sbsBullRaw[1]
sbsBear = sbsBearRaw and not sbsBearRaw[1]

starBodyMax  = starBodyPct / 100
midIsStar    = rng[1] > 0 and bodyV[1] <= rng[1] * starBodyMax
midNotBigger = bodyV[1] <= bodyV[2]
mStar_body  = red[2] and green[1] and midIsStar and midNotBigger and green and hasBody
mStar_lvl   = (uWick > 0 or lWick > 0) and close > (open[2] + close[2]) / 2.0 and mStarTrend
mStar_spike = low[1] < low[2] and low[1] < low
mStarRaw    = mStar_body and mStar_lvl and mStar_spike
mStar       = mStarRaw and not mStarRaw[1]
eStar_body  = green[2] and red[1] and midIsStar and midNotBigger and red and hasBody
eStar_lvl   = (uWick > 0 or lWick > 0) and close < (open[2] + close[2]) / 2.0 and eStarTrend
eStar_spike = high[1] > high[2] and high[1] > high
eStarRaw    = eStar_body and eStar_lvl and eStar_spike
eStar       = eStarRaw and not eStarRaw[1]

tlsBullRaw = red[3] and red[2] and red[1] and green and close > open[3] and notSideways
tlsBearRaw = green[3] and green[2] and green[1] and red and close < open[3] and notSideways
tlsBull = tlsBullRaw and not tlsBullRaw[1]
tlsBear = tlsBearRaw and not tlsBearRaw[1]

threeWhiteSoldiers = green and green[1] and green[2] and close > close[1] and close[1] > close[2]
threeBlackCrows    = red   and red[1]   and red[2]   and close < close[1] and close[1] < close[2]
bullMaru = green and rng > 0 and uWick <= rng * 0.02 and lWick <= rng * 0.02
bearMaru = red   and rng > 0 and uWick <= rng * 0.02 and lWick <= rng * 0.02

lSize = labelSize == "tiny" ? size.tiny : labelSize == "normal" ? size.normal : labelSize == "large" ? size.large : size.small
fibLSize = fibLabelSize == "tiny" ? size.tiny : fibLabelSize == "normal" ? size.normal : fibLabelSize == "large" ? size.large : size.small
lsobTSize = lsobTextSize == "tiny" ? size.tiny : lsobTextSize == "normal" ? size.normal : lsobTextSize == "large" ? size.large : size.small

var int[]   stack       = array.new_int(2, 0)
var int[]   lastBarRef  = array.new_int(1, -1)
var float[] prevLblY    = array.new_float(2, na)
var int[]   prevLblBar  = array.new_int(2, -1)

if bar_index != array.get(lastBarRef, 0)
    array.set(stack, 0, 0)
    array.set(stack, 1, 0)
    array.set(lastBarRef, 0, bar_index)

f_lbl(cond, txt, bull, rank) =>
    if cond and barstate.isconfirmed
        slotIdx = bull ? 0 : 1
        idx = array.get(stack, slotIdx)
        array.set(stack, slotIdx, idx + 1)
        c = bull ? (rank == 1 ? color.lime : rank == 2 ? color.green : color.new(color.green, 30)) : (rank == 1 ? color.red : rank == 2 ? color.maroon : color.new(color.red, 30))
        baseOff = atrV * (firstOff + idx * stackSpace)
        y_c = bull ? low - baseOff : high + baseOff
        prevY   = array.get(prevLblY, slotIdx)
        prevBar = array.get(prevLblBar, slotIdx)
        minGap  = atrV * stackSpace
        if labelDecay > 0 and not na(prevY) and (bar_index - prevBar) <= labelDecay
            if bull and y_c > prevY - minGap
                y_c := prevY - minGap
            if not bull and y_c < prevY + minGap
                y_c := prevY + minGap
        array.set(prevLblY, slotIdx, y_c)
        array.set(prevLblBar, slotIdx, bar_index)
        st = bull ? label.style_label_up : label.style_label_down
        label.new(bar_index, y_c, txt, style=st, color=c, textcolor=color.white, size=lSize)

f_lbl(retrWicks  and sWicks  , "#1 Retr.Wicks"  , false, 1)
f_lbl(advWicks   and sWicks  , "#2 Adv.Wicks"   , true , 1)
f_lbl(eStar      and sStar   , "#3 EveningStar" , false, 2)
f_lbl(mStar      and sStar   , "#4 MorningStar" , true , 2)
f_lbl(tweezerTop and sTweezer, "#5 TweezerTop"  , false, 3)
f_lbl(tweezerBot and sTweezer, "#6 TweezerBot"  , true , 3)
f_lbl(sbsBear    and sSBS    , "#7 SBS Bear"    , false, 2)
f_lbl(sbsBull    and sSBS    , "#8 SBS Bull"    , true , 2)
f_lbl(hammer     and sHammer , "Hammer"         , true , 1)
f_lbl(shootStar  and sHammer , "ShootStar"      , false, 1)
f_lbl(dragonfly  and sDoji   , "Dragonfly"      , true , 2)
f_lbl(gravestone and sDoji   , "Gravestone"     , false, 2)
f_lbl(invHammer  and sHanging, "Inv.Hammer"     , false, 3)
f_lbl(hangingMan and sHanging, "HangingMan"     , false, 3)
f_lbl(bullEng    and sEngulf , "BullEng"        , true , 3)
f_lbl(bearEng    and sEngulf , "BearEng"        , false, 3)
f_lbl(tlsBull    and s3Line  , "3LStrike+"      , true , 3)
f_lbl(tlsBear    and s3Line  , "3LStrike-"      , false, 3)
f_lbl(threeWhiteSoldiers and sSoldiers, "3WS(w)", true , 4)
f_lbl(threeBlackCrows    and sSoldiers, "3BC(w)", false, 4)
f_lbl(bullMaru   and sMarubozu, "Maru+(w)"      , true , 4)
f_lbl(bearMaru   and sMarubozu, "Maru-(w)"      , false, 4)

// ─── FAIR VALUE GAPS (FVG + iFVG) ───────────────────────────────────────
fvgMinSizeAbs = atrV * fvgMinAtrPct / 100

bullFVGForm = showFVG and high[2] < low  and (low - high[2]) >= fvgMinSizeAbs
bearFVGForm = showFVG and low[2]  > high and (low[2] - high) >= fvgMinSizeAbs

var box[]   fvgBoxes    = array.new_box()
var int[]   fvgBoxBar   = array.new_int()
var float[] fvgTop      = array.new_float()
var float[] fvgBot      = array.new_float()
var bool[]  fvgIsBull   = array.new_bool()
var bool[]  fvgInverted = array.new_bool()

if bullFVGForm
    t = low
    b = high[2]
    bx = box.new(bar_index - 2, t, bar_index, b, bgcolor=fvgBullCol, border_color=na, extend=extend.right)
    array.push(fvgBoxes, bx)
    array.push(fvgBoxBar, bar_index)
    array.push(fvgTop, t)
    array.push(fvgBot, b)
    array.push(fvgIsBull, true)
    array.push(fvgInverted, false)

if bearFVGForm
    t = low[2]
    b = high
    bx = box.new(bar_index - 2, t, bar_index, b, bgcolor=fvgBearCol, border_color=na, extend=extend.right)
    array.push(fvgBoxes, bx)
    array.push(fvgBoxBar, bar_index)
    array.push(fvgTop, t)
    array.push(fvgBot, b)
    array.push(fvgIsBull, false)
    array.push(fvgInverted, false)

fvgN = array.size(fvgBoxes)
if fvgN > 0
    fvgToRemove = array.new_int()
    for i = 0 to fvgN - 1
        isInverted = array.get(fvgInverted, i)
        fbar       = array.get(fvgBoxBar, i)
        age        = bar_index - fbar
        if not isInverted and age >= 1
            isBull = array.get(fvgIsBull, i)
            ftop   = array.get(fvgTop, i)
            fbot   = array.get(fvgBot, i)
            iFVGevent = isBull ? (low < fbot and low[1] >= fbot) : (high > ftop and high[1] <= ftop)
            if iFVGevent
                bx = array.get(fvgBoxes, i)
                box.set_right(bx, bar_index)
                box.set_extend(bx, extend.none)
                array.set(fvgInverted, i, true)
                if fvgShowIFVG and barstate.isconfirmed
                    offset = atrV * 0.5
                    yPos = isBull ? (high + offset) : (low - offset)
                    txt  = isBull ? "iFVG ▼" : "iFVG ▲"
                    lblC = isBull ? color.red : color.lime
                    st   = isBull ? label.style_label_down : label.style_label_up
                    label.new(bar_index, yPos, txt, color=lblC, textcolor=color.white, style=st, size=size.tiny)
        if age > fvgMaxAge
            array.push(fvgToRemove, i)
    rmN = array.size(fvgToRemove)
    if rmN > 0
        for j = 0 to rmN - 1
            idx = array.get(fvgToRemove, rmN - 1 - j)
            box.delete(array.get(fvgBoxes, idx))
            array.remove(fvgBoxes, idx)
            array.remove(fvgBoxBar, idx)
            array.remove(fvgTop, idx)
            array.remove(fvgBot, idx)
            array.remove(fvgIsBull, idx)
            array.remove(fvgInverted, idx)

// ─── LSOB (Liquidity Sweep Order Block) ─────────────────────────────────
lsobPivLow  = ta.pivotlow (low,  lsobLookback, lsobConfR)
lsobPivHigh = ta.pivothigh(high, lsobLookback, lsobConfR)

candLow_l   = low [lsobConfR]
candHigh_l  = high[lsobConfR]
candClose_l = close[lsobConfR]
candPrevLowMin  = ta.lowest(low,  lsobLookback)[lsobConfR + 1]
candPrevHighMax = ta.highest(high, lsobLookback)[lsobConfR + 1]

bullLSOBForm = showLSOB and not na(lsobPivLow)  and candClose_l > candPrevLowMin  and barstate.isconfirmed
bearLSOBForm = showLSOB and not na(lsobPivHigh) and candClose_l < candPrevHighMax and barstate.isconfirmed

var box[]   lsobBoxes    = array.new_box()
var int[]   lsobBoxBar   = array.new_int()
var float[] lsobTop      = array.new_float()
var float[] lsobBot      = array.new_float()
var bool[]  lsobIsBull   = array.new_bool()
var bool[]  lsobTouched  = array.new_bool()

lsobLabel = lsobShowText ? "LSOB" : ""

if bullLSOBForm
    leftIdxB = bar_index - lsobConfR
    bx = box.new(leftIdxB, candHigh_l, bar_index, candLow_l, bgcolor=lsobBullCol, border_color=lsobBorderCol, extend=extend.right, text=lsobLabel, text_color=lsobTextCol, text_size=lsobTSize, text_halign=text.align_center, text_valign=text.align_center)
    array.push(lsobBoxes, bx)
    array.push(lsobBoxBar, leftIdxB)
    array.push(lsobTop, candHigh_l)
    array.push(lsobBot, candLow_l)
    array.push(lsobIsBull, true)
    array.push(lsobTouched, false)

if bearLSOBForm
    leftIdxS = bar_index - lsobConfR
    bx = box.new(leftIdxS, candHigh_l, bar_index, candLow_l, bgcolor=lsobBearCol, border_color=lsobBorderCol, extend=extend.right, text=lsobLabel, text_color=lsobTextCol, text_size=lsobTSize, text_halign=text.align_center, text_valign=text.align_center)
    array.push(lsobBoxes, bx)
    array.push(lsobBoxBar, leftIdxS)
    array.push(lsobTop, candHigh_l)
    array.push(lsobBot, candLow_l)
    array.push(lsobIsBull, false)
    array.push(lsobTouched, false)

lsobN = array.size(lsobBoxes)
if lsobN > 0
    lsobToRemove = array.new_int()
    for i = 0 to lsobN - 1
        isTouched = array.get(lsobTouched, i)
        lbar      = array.get(lsobBoxBar, i)
        age       = bar_index - lbar
        isBull    = array.get(lsobIsBull, i)
        ltop      = array.get(lsobTop, i)
        lbot      = array.get(lsobBot, i)
        // INVALIDATION: price closes beyond the WRONG side of the LSOB
        //   Bull-LSOB invalid when close < lbot (price fell through support)
        //   Bear-LSOB invalid when close > ltop (price broke through resistance)
        invalidated = age >= 1 and (isBull ? close < lbot : close > ltop)
        markRemove = false
        if invalidated
            markRemove := true
        else
            if not isTouched and age >= 1
                touched = isBull ? (low <= ltop and high[1] > ltop) : (high >= lbot and low[1] < lbot)
                if touched
                    bx = array.get(lsobBoxes, i)
                    box.set_right(bx, bar_index)
                    box.set_extend(bx, extend.none)
                    array.set(lsobTouched, i, true)
            if age > lsobMaxAge
                markRemove := true
        if markRemove
            array.push(lsobToRemove, i)
    rmN = array.size(lsobToRemove)
    if rmN > 0
        for j = 0 to rmN - 1
            idx = array.get(lsobToRemove, rmN - 1 - j)
            box.delete(array.get(lsobBoxes, idx))
            array.remove(lsobBoxes, idx)
            array.remove(lsobBoxBar, idx)
            array.remove(lsobTop, idx)
            array.remove(lsobBot, idx)
            array.remove(lsobIsBull, idx)
            array.remove(lsobTouched, idx)

// ─── GUSS SNIPER ENTRY (Kryptomano) ─────────────────────────────────────
gussPrevHi = ta.highest(high[1], gussLookback)
gussPrevLo = ta.lowest (low[1],  gussLookback)
gussExt    = atrV * gussOverExtAtr

gussNewHH = high > gussPrevHi and (high - ema21V) >= gussExt and (not gussRequireImp or green)
gussNewLL = low  < gussPrevLo and (ema21V - low ) >= gussExt and (not gussRequireImp or red)

var int   gussLState = 0
var int   gussLBar   = -1
var float gussLHHigh = na
var int   gussSState = 0
var int   gussSBar   = -1
var float gussSLLow  = na

gussLongEntry  = false
gussShortEntry = false
gussLongInval  = false
gussShortInval = false
gussLongStart  = false
gussShortStart = false

if showGUSS and barstate.isconfirmed
    if gussLState == 1
        ageL = bar_index - gussLBar
        if green
            gussLongInval := true
            gussLState := 0
        else if low <= ema21V
            gussLState := 0
        else if low <= ema50V
            gussLongEntry := true
            gussLState := 0
        else if ageL > gussMaxWait
            gussLState := 0
    if gussLState == 0 and gussNewHH
        gussLState := 1
        gussLBar   := bar_index
        gussLHHigh := high
        gussLongStart := true

    if gussSState == 1
        ageS = bar_index - gussSBar
        if red
            gussShortInval := true
            gussSState := 0
        else if high >= ema21V
            gussSState := 0
        else if high >= ema50V
            gussShortEntry := true
            gussSState := 0
        else if ageS > gussMaxWait
            gussSState := 0
    if gussSState == 0 and gussNewLL
        gussSState := 1
        gussSBar   := bar_index
        gussSLLow  := low
        gussShortStart := true

f_lbl(gussLongEntry  and showGUSS, "GUSS Long" , true , 1)
f_lbl(gussShortEntry and showGUSS, "GUSS Short", false, 1)

// ─── FIBONACCI (4h MIN / Daily UP — separate pivot lengths per tier) ────
chartTfSecFib = timeframe.in_seconds()
useDailyTier  = chartTfSecFib >= 1440 * 60
fibTfStr      = useDailyTier ? timeframe.period : "240"
effPivLen     = useDailyTier ? fibPivLen1D : fibPivLen4h

ph4 = request.security(syminfo.tickerid, fibTfStr, ta.pivothigh(high, effPivLen, effPivLen), lookahead=barmerge.lookahead_off)
pl4 = request.security(syminfo.tickerid, fibTfStr, ta.pivotlow (low,  effPivLen, effPivLen), lookahead=barmerge.lookahead_off)

var float lastPHVal = na
var int   lastPHBar = -1
var float lastPLVal = na
var int   lastPLBar = -1

chartTfMinFib  = math.max(1.0, chartTfSecFib / 60.0)
effFibTfMin    = useDailyTier ? chartTfMinFib : 240.0
barsPerRefBar  = math.max(1, int(math.round(effFibTfMin / chartTfMinFib)))
pivConfOffset  = effPivLen * barsPerRefBar

if not na(ph4) and (na(lastPHVal) or ph4 != lastPHVal)
    lastPHVal := ph4
    lastPHBar := bar_index - pivConfOffset
    if showPivotMarks
        label.new(lastPHBar, ph4, "PH", style=label.style_label_down, color=color.new(color.red, 70), textcolor=color.white, size=size.tiny)

if not na(pl4) and (na(lastPLVal) or pl4 != lastPLVal)
    lastPLVal := pl4
    lastPLBar := bar_index - pivConfOffset
    if showPivotMarks
        label.new(lastPLBar, pl4, "PL", style=label.style_label_up, color=color.new(color.green, 70), textcolor=color.white, size=size.tiny)

swingEndIsHi  = lastPHBar > lastPLBar
swingEnd      = swingEndIsHi ? lastPHVal : lastPLVal
swingStart    = swingEndIsHi ? lastPLVal : lastPHVal
swingEndBar   = swingEndIsHi ? lastPHBar : lastPLBar
swingStartBar = swingEndIsHi ? lastPLBar : lastPHBar

fibPrice(f) => swingEnd - f * (swingEnd - swingStart)

var line[]  fibLines  = array.new_line(0)
var label[] fibLabels = array.new_label(0)
var box     goldenBox = na

f_drawFibCol(f, txt, baseCol) =>
    p = fibPrice(f)
    c = color.new(baseCol, fibTransp)
    array.push(fibLines, line.new(swingStartBar, p, bar_index, p, color=c, extend=extend.right, width=fibWidth))
    if showFibLabel
        array.push(fibLabels, label.new(bar_index + fibLabelOffset, p, txt + "  " + str.tostring(p, format.mintick), color=color.new(baseCol, fibLabelBgTransp), textcolor=fibLabelTextCol, style=label.style_label_left, size=fibLSize))
    0

if barstate.islast and showFib and not na(swingEnd) and not na(swingStart) and lastPHBar > 0 and lastPLBar > 0 and swingStartBar != swingEndBar
    while array.size(fibLines) > 0
        line.delete(array.pop(fibLines))
    while array.size(fibLabels) > 0
        label.delete(array.pop(fibLabels))
    if not na(goldenBox)
        box.delete(goldenBox)
        goldenBox := na
    if showGoldenPocket
        p05 = fibPrice(0.500)
        p06 = fibPrice(0.618)
        topP = math.max(p05, p06)
        botP = math.min(p05, p06)
        goldenBox := box.new(swingStartBar, topP, bar_index, botP, border_color=na, bgcolor=color.new(goldenColor, goldenTransp), extend=extend.right)
    if show0_100
        f_drawFibCol(0.0, "0%", fibColor)
        f_drawFibCol(1.0, "100%", fibColor)
    if showFib236
        f_drawFibCol(0.236, "0.236", fibColor)
    if showFib382
        f_drawFibCol(0.382, "0.382", fibColor)
    if showFib500
        f_drawFibCol(0.500, "0.500", fibColor)
    if showFib618
        f_drawFibCol(0.618, "0.618 Golden", fibColor618)
    if showFib786
        f_drawFibCol(0.786, "0.786", fibColor786)
    if showFib882
        f_drawFibCol(0.882, "0.882", fibColor882)

alertcondition(retrWicks   and sWicks  , "Retracing Wicks", "Retracing Wicks (#1)")
alertcondition(advWicks    and sWicks  , "Advancing Wicks", "Advancing Wicks (#2)")
alertcondition(eStar       and sStar   , "Evening Star",    "Evening Star (#3)")
alertcondition(mStar       and sStar   , "Morning Star",    "Morning Star (#4)")
alertcondition(tweezerTop  and sTweezer, "Tweezer Top",     "Tweezer Top (#5)")
alertcondition(tweezerBot  and sTweezer, "Tweezer Bottom",  "Tweezer Bottom (#6)")
alertcondition(sbsBull     and sSBS    , "SBS Bullish",     "Side by Side Bullish Reversal (#8)")
alertcondition(sbsBear     and sSBS    , "SBS Bearish",     "Side by Side Bearish Reversal (#7)")
alertcondition(hammer      and sHammer , "Hammer",          "Hammer (single)")
alertcondition(shootStar   and sHammer , "Shooting Star",   "Shooting Star (single)")
alertcondition(invHammer   and sHanging, "Inverted Hammer", "Inverted Hammer (bearish)")
alertcondition(bullFVGForm , "Bullish FVG",     "Bullish Fair Value Gap formed")
alertcondition(bearFVGForm , "Bearish FVG",     "Bearish Fair Value Gap formed")
alertcondition(bullLSOBForm, "Bullish LSOB",    "Bullish Liquidity Sweep OB formed")
alertcondition(bearLSOBForm, "Bearish LSOB",    "Bearish Liquidity Sweep OB formed")
alertcondition(gussLongEntry  and showGUSS, "GUSS Long",  "GUSS Long entry: EMA50 touch after HH overextension (no bull counter-candle)")
alertcondition(gussShortEntry and showGUSS, "GUSS Short", "GUSS Short entry: EMA50 touch after LL overextension (no bear counter-candle)")
````
