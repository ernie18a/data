# Macd matrix elite

- url: https://www.tradingview.com/script/0IUGbnDX-Macd-matrix-elite/
- type: indicator
- pine_id: PUB;b734b337d53546448922e123e174ee38
- version: 1.0

## Description

MACD Matrix Elite is a momentum dashboard built around the MACD, with additional context from dynamic overbought/oversold zones, RSI, Stochastic, divergences, confluence points, and live signal scoring.

The main idea is to keep the MACD readable while adding enough context to avoid looking at a simple crossover in isolation. A MACD cross can be useful, but it is often more meaningful when it happens near an extreme zone, with improving histogram momentum, or with confirmation from another oscillator.

The script uses the standard MACD structure:
- Fast EMA
- Slow EMA
- MACD line
- Signal line
- Histogram

Around that core, the indicator adds dynamic OB/OS zones based on normalized ATR. This means the extreme areas can adapt to current market volatility instead of relying only on fixed horizontal levels.

Additional filters are used as context:
- RSI overbought/oversold readings
- Stochastic overbought/oversold readings
- MACD histogram direction
- MACD zero-line crosses
- Regular and hidden divergences
- Bullish and bearish confluence points
- Strength score and reversal pressure panels

The background is designed to help quickly identify the current environment. Green-toned areas usually represent bullish pressure, red-toned areas bearish pressure, and neutral zones show when the market is less extended.

How to read the main signals:

A bullish MACD cross happens when the MACD line crosses above the signal line. This can show that momentum is improving. It becomes more interesting when the histogram is rising, price is recovering from an oversold area, or RSI/Stochastic are also showing exhaustion to the downside.

A bearish MACD cross happens when the MACD line crosses below the signal line. This can show that momentum is weakening. It becomes more interesting when the histogram is falling, price is coming from an overbought area, or RSI/Stochastic are also showing exhaustion to the upside.

The zero line is an important reference. When MACD crosses above zero, bullish momentum is usually gaining broader confirmation. When MACD crosses below zero, bearish momentum is usually gaining broader confirmation.

The confluence points appear when several conditions align. They are not meant to be blind entry signals. They are visual markers showing that multiple parts of the momentum model are pointing in the same direction.

Beginner example 1:
The MACD line crosses above the signal line while the histogram starts rising from below zero. RSI and Stochastic are also coming from oversold levels. This does not guarantee a reversal, but it gives a trader a cleaner bullish setup to investigate on price action.

Beginner example 2:
The MACD line crosses below the signal line after a strong upside move. The histogram begins to fall and the script shows an overbought environment. This can warn that bullish momentum is cooling. A beginner can then check whether price is rejecting resistance or breaking a local support.

Beginner example 3:
Price makes a higher high, but the MACD makes a lower high. If a bearish divergence is confirmed, it can show that the new price high is not supported by stronger momentum. This can help traders become more cautious with long positions.

Beginner example 4:
Price makes a lower low, but the MACD makes a higher low. If a bullish divergence is confirmed, it can show that downside pressure is weakening. It is usually better to wait for confirmation from price structure instead of entering only because the divergence appeared.

About the score:
The score is a visual summary of several conditions inside the script. It compares bullish and bearish momentum factors such as crosses, histogram direction, OB/OS zones, confluence, and divergences. A higher score means more conditions are aligned, not that the trade is guaranteed to work.

About the signal history:
The signal history panel is designed as a visual tracking tool. It helps review how previous marked conditions evolved using the script’s internal SL/TP model. It should not be treated as a full backtest or as a guarantee of future results.

Useful settings:
- Use Dynamic OB/OS if you want the zones to adapt to volatility.
- Lower the minimum signal score if you want more signals.
- Raise the minimum signal score if you want fewer but more selective signals.
- Disable panels if you prefer a cleaner chart.
- Keep divergence labels enabled if you use momentum divergence in your analysis.

Best use:
MACD Matrix Elite works best as a momentum context tool. It can help identify shifts in pressure, exhaustion zones, confluence areas, and possible momentum divergences. For better decision-making, combine it with trend structure, support and resistance, volume, and risk management.

Limitations:
This indicator does not predict future price movement. Strong trends can keep MACD, RSI, or Stochastic extended for a long time. Divergences can fail in high momentum markets. The score and panels are there to organize information, not to replace a complete trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("MACD MATRIX ELITE", shorttitle="MATRIX", overlay=false, max_labels_count=500, max_lines_count=500)

g1 = "MACD ENGINE"
fastLen   = input.int(12, "Fast Length", group=g1, minval=2)
slowLen   = input.int(26, "Slow Length", group=g1, minval=3)
sigLen    = input.int(9, "Signal Length", group=g1, minval=1)
macdSrc   = input.string("close", "Source", group=g1, options=["close", "open", "hl2", "hlc3", "ohlc4"])

g2 = "OB/OS ZONES"
obLevel     = input.float(0.0030, "Overbought Level", group=g2, step=0.0001)
osLevel     = input.float(-0.0030, "Oversold Level", group=g2, step=0.0001)
useDynZone  = input.bool(true, "Dynamic OB/OS (ATR-based)", group=g2)
atrZoneMul  = input.float(2.0, "ATR Zone Multiplier", group=g2, step=0.1)

g3 = "DIVERGENCES"
divLook        = input.int(5, "Pivot Lookback", group=g3, minval=2, maxval=20)
showRegDiv     = input.bool(true, "Regular Divergences", group=g3)
showHidDiv     = input.bool(true, "Hidden Divergences", group=g3)
showDivLines   = input.bool(true, "Show Divergence Lines", group=g3)
showDivLabels  = input.bool(true, "Show Divergence Labels", group=g3)
divLineWidth   = input.int(1, "Divergence Line Width", group=g3, minval=1, maxval=3)

g4 = "CONFLUENCE"
useRSI       = input.bool(true, "RSI Confluence", group=g4)
rsiLen       = input.int(14, "RSI Length", group=g4, minval=2)
rsiOB        = input.float(70, "RSI OB", group=g4)
rsiOS        = input.float(30, "RSI OS", group=g4)
useStoch     = input.bool(true, "Stoch Confluence", group=g4)
stochK       = input.int(14, "Stoch K", group=g4, minval=1)
stochD       = input.int(3, "Stoch D", group=g4, minval=1)
stochSmooth  = input.int(3, "Stoch Smooth", group=g4, minval=1)
stochOB      = input.float(80, "Stoch OB", group=g4)
stochOS      = input.float(20, "Stoch OS", group=g4)

g5 = "VISUALS"
showMatrixBG     = input.bool(true, "Show Matrix Background", group=g5)
showGlow         = input.bool(true, "Show Histogram Glow", group=g5)
showParticles    = input.bool(true, "Show Confluence Points", group=g5)
showCrossDots    = input.bool(true, "Show MACD Cross Dots", group=g5)
showZeroArrows   = input.bool(true, "Show Zero-Line Arrows", group=g5)
showStrengthLab  = input.bool(true, "Show Strength Labels", group=g5)
showBiasDots     = input.bool(true, "Show Bias Dots", group=g5)
bgIntensity      = input.int(92, "Background Opacity", group=g5, minval=75, maxval=99)

g6 = "PANELS"
showMainPanel    = input.bool(true, "Show Main Panel", group=g6)
showStatsPanel   = input.bool(true, "Show Stats Panel", group=g6)
showSignalPanel  = input.bool(true, "Show Signal Panel", group=g6)
mainPanelPos     = input.string("Top Right", "Main Panel Position", group=g6, options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
statsPanelPos    = input.string("Bottom Right", "Stats Panel Position", group=g6, options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
signalPanelPos   = input.string("Bottom Left", "Signal Panel Position", group=g6, options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"])

g7 = "SIGNAL HISTORY"
enableHistory    = input.bool(true, "Enable Signal History", group=g7)
historyMax       = input.int(200, "Stored Signals", group=g7, minval=50, maxval=500)
historyLabels    = input.bool(true, "Show Historical Labels", group=g7)
historyLabelCnt  = input.int(35, "Historical Labels On Chart", group=g7, minval=5, maxval=100)
signalATR        = input.float(1.5, "Signal SL/TP ATR", group=g7, step=0.1)
signalRR         = input.float(1.5, "Reward/Risk", group=g7, step=0.1)
signalMinScore   = input.int(60, "Min Score For Tracked Signal", group=g7, minval=10, maxval=100)

g8 = "PRO ENGINE"
showProb         = input.bool(true, "Show Reversal Probability", group=g8)
showScore        = input.bool(true, "Show Signal Strength Score", group=g8)

g9 = "SELL QUALITY FILTER"
useSellQuality   = input.bool(true, "Filter SELL Signals", group=g9)
sellTrendLen     = input.int(200, "SELL Trend EMA Length", group=g9, minval=20, maxval=500)
sellScoreGap     = input.int(15, "SELL Min Bear/Bull Score Gap", group=g9, minval=0, maxval=50)
sellNeedMacdZero = input.bool(true, "SELL Trend Mode Needs MACD Below Zero", group=g9)

f_round(v, decimals) =>
    m = math.pow(10, decimals)
    math.round(v * m) / m

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(v, hi))

f_panelPos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Top Right" ? position.top_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.bottom_right

src = macdSrc == "open"  ? open  :
      macdSrc == "hl2"   ? hl2   :
      macdSrc == "hlc3"  ? hlc3  :
      macdSrc == "ohlc4" ? ohlc4 :
      close

C_BULL      = color.new(#087500, 17)
C_BULL_D    = color.new(#7CB342, 45)
C_BULL_G    = color.new(#7CB342, 82)

C_BEAR      = color.new(#b40401, 16)
C_BEAR_D    = color.new(#EF5350, 45)
C_BEAR_G    = color.new(#EF5350, 82)

C_NEUTRAL   = color.new(#90A4AE, 0)
C_NEUTRAL_D = color.new(#90A4AE, 45)

C_DIV_BULL  = color.new(#4DB6AC, 0)
C_DIV_BEAR  = color.new(#FF8A65, 0)
C_HDIV_BULL = color.new(#64B5F6, 0)
C_HDIV_BEAR = color.new(#BA68C8, 0)

C_CROSS_BULL = color.new(#00b3ff, 0)
C_CROSS_BEAR = color.new(#ffbb00, 0)

C_MAX_BULL  = color.new(#26A69A, 0)
C_MAX_BEAR  = color.new(#FF7043, 0)

C_PANEL_BG   = color.new(#0F1115, 8)
C_PANEL_BG_2 = color.new(#161A20, 10)
C_PANEL_HDR  = color.new(#2A2F36, 0)
C_PANEL_TXT  = color.new(#ECEFF1, 0)
C_PANEL_DIM  = color.new(#B0BEC5, 0)

C_LINE       = color.new(#CFD8DC, 25)
C_BLACK_BG   = color.new(#000000, 0)

fastEMA  = ta.ema(src, fastLen)
slowEMA  = ta.ema(src, slowLen)
macdLine = fastEMA - slowEMA
sigLine  = ta.ema(macdLine, sigLen)
hist     = macdLine - sigLine

histRising  = hist > hist[1]
histFalling = hist < hist[1]
histBull    = hist >= 0
histBear    = hist < 0

bullCross = ta.crossover(macdLine, sigLine)
bearCross = ta.crossunder(macdLine, sigLine)
zeroBull  = ta.crossover(macdLine, 0)
zeroBear  = ta.crossunder(macdLine, 0)

atr14   = ta.atr(14)
atrNorm = atr14 / ta.sma(close, 20)
dynOB   = useDynZone ? atrNorm * atrZoneMul : obLevel
dynOS   = useDynZone ? -atrNorm * atrZoneMul : osLevel

inOB = macdLine >= dynOB
inOS = macdLine <= dynOS

rsi     = ta.rsi(close, rsiLen)
rsiInOB = rsi >= rsiOB
rsiInOS = rsi <= rsiOS

stochRaw = ta.stoch(high, low, close, stochK)
stochK_s = ta.sma(stochRaw, stochSmooth)
stochD_s = ta.sma(stochK_s, stochD)
stInOB   = stochK_s >= stochOB
stInOS   = stochK_s <= stochOS

confBull_rsi   = useRSI and rsiInOS and histBull and histRising
confBull_stoch = useStoch and stInOS and histBull and histRising
confBull_both  = useRSI and useStoch and (rsiInOS or rsi < 45) and stInOS and histBull and histRising

confBear_rsi   = useRSI and rsiInOB and histBear and histFalling
confBear_stoch = useStoch and stInOB and histBear and histFalling
confBear_both  = useRSI and useStoch and (rsiInOB or rsi > 55) and stInOB and histBear and histFalling

maxConfBull = confBull_both and inOS
maxConfBear = confBear_both and inOB

ph = ta.pivothigh(high, divLook, divLook)
pl = ta.pivotlow(low, divLook, divLook)

var float lastHighPrice = na
var float prevHighPrice = na
var float lastHighMacd  = na
var float prevHighMacd  = na
var int   lastHighBar   = na
var int   prevHighBar   = na

var float lastLowPrice  = na
var float prevLowPrice  = na
var float lastLowMacd   = na
var float prevLowMacd   = na
var int   lastLowBar    = na
var int   prevLowBar    = na

regDivBull = false
regDivBear = false
hidDivBull = false
hidDivBear = false

if not na(ph)
    prevHighPrice := lastHighPrice
    prevHighMacd  := lastHighMacd
    prevHighBar   := lastHighBar

    lastHighPrice := high[divLook]
    lastHighMacd  := macdLine[divLook]
    lastHighBar   := bar_index - divLook

    regDivBear := showRegDiv and not na(prevHighPrice) and not na(prevHighMacd) and lastHighPrice > prevHighPrice and lastHighMacd < prevHighMacd
    hidDivBear := showHidDiv and not na(prevHighPrice) and not na(prevHighMacd) and lastHighPrice < prevHighPrice and lastHighMacd > prevHighMacd

    if showDivLines and regDivBear and not na(prevHighBar) and not na(lastHighBar)
        line.new(prevHighBar, prevHighMacd, lastHighBar, lastHighMacd, color=color.new(C_DIV_BEAR, 0), width=2)

    if showDivLines and hidDivBear and not na(prevHighBar) and not na(lastHighBar)
        line.new(prevHighBar, prevHighMacd, lastHighBar, lastHighMacd, color=color.new(C_HDIV_BEAR, 0), width=2)

    if showDivLabels and regDivBear
        label.new(lastHighBar, lastHighMacd, "DIV-", color=color.new(C_DIV_BEAR, 18), textcolor=color.white, style=label.style_label_down, size=size.tiny)

    if showDivLabels and hidDivBear
        label.new(lastHighBar, lastHighMacd, "hDIV-", color=color.new(C_HDIV_BEAR, 18), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if not na(pl)
    prevLowPrice := lastLowPrice
    prevLowMacd  := lastLowMacd
    prevLowBar   := lastLowBar

    lastLowPrice := low[divLook]
    lastLowMacd  := macdLine[divLook]
    lastLowBar   := bar_index - divLook

    regDivBull := showRegDiv and not na(prevLowPrice) and not na(prevLowMacd) and lastLowPrice < prevLowPrice and lastLowMacd > prevLowMacd
    hidDivBull := showHidDiv and not na(prevLowPrice) and not na(prevLowMacd) and lastLowPrice > prevLowPrice and lastLowMacd < prevLowMacd

    if showDivLines and regDivBull and not na(prevLowBar) and not na(lastLowBar)
        line.new(prevLowBar, prevLowMacd, lastLowBar, lastLowMacd, color=color.new(C_DIV_BULL, 0), width=2)

    if showDivLines and hidDivBull and not na(prevLowBar) and not na(lastLowBar)
        line.new(prevLowBar, prevLowMacd, lastLowBar, lastLowMacd, color=color.new(C_HDIV_BULL, 0), width=2)

    if showDivLabels and regDivBull
        label.new(lastLowBar, lastLowMacd, "DIV+", color=color.new(C_DIV_BULL, 18), textcolor=color.black, style=label.style_label_up, size=size.tiny)

    if showDivLabels and hidDivBull
        label.new(lastLowBar, lastLowMacd, "hDIV+", color=color.new(C_HDIV_BULL, 18), textcolor=color.black, style=label.style_label_up, size=size.tiny)

bullScore = 0.0
bearScore = 0.0

bullScore += bullCross      ? 18 : 0
bullScore += zeroBull       ? 12 : 0
bullScore += histBull       ? 10 : 0
bullScore += histRising     ? 10 : 0
bullScore += inOS           ? 12 : 0
bullScore += confBull_rsi   ? 10 : 0
bullScore += confBull_stoch ? 10 : 0
bullScore += confBull_both  ? 8  : 0
bullScore += maxConfBull    ? 10 : 0
bullScore += regDivBull     ? 12 : 0
bullScore += hidDivBull     ? 8  : 0

bearScore += bearCross      ? 18 : 0
bearScore += zeroBear       ? 12 : 0
bearScore += histBear       ? 10 : 0
bearScore += histFalling    ? 10 : 0
bearScore += inOB           ? 12 : 0
bearScore += confBear_rsi   ? 10 : 0
bearScore += confBear_stoch ? 10 : 0
bearScore += confBear_both  ? 8  : 0
bearScore += maxConfBear    ? 10 : 0
bearScore += regDivBear     ? 12 : 0
bearScore += hidDivBear     ? 8  : 0

bullScore := f_clamp(bullScore, 0, 100)
bearScore := f_clamp(bearScore, 0, 100)

signalScore = bullScore > bearScore ? bullScore : bearScore
isBuySig    = bullScore > bearScore
isSellSig   = bearScore > bullScore

bullProb = 0.0
bearProb = 0.0

bullProb += inOS        ? 20 : 0
bullProb += rsiInOS     ? 15 : 0
bullProb += stInOS      ? 15 : 0
bullProb += regDivBull  ? 20 : 0
bullProb += hidDivBull  ? 10 : 0
bullProb += bullCross   ? 10 : 0
bullProb += histRising  ? 10 : 0

bearProb += inOB        ? 20 : 0
bearProb += rsiInOB     ? 15 : 0
bearProb += stInOB      ? 15 : 0
bearProb += regDivBear  ? 20 : 0
bearProb += hidDivBear  ? 10 : 0
bearProb += bearCross   ? 10 : 0
bearProb += histFalling ? 10 : 0

bullProb := f_clamp(bullProb, 0, 100)
bearProb := f_clamp(bearProb, 0, 100)

sellTrendEMA = ta.ema(close, sellTrendLen)
bearTrend = close < sellTrendEMA
scoreGapBear = bearScore - bullScore >= sellScoreGap
bearTrendSell = bearTrend and bearCross and histBear and histFalling and (not sellNeedMacdZero or macdLine < 0)
bearReversalSell = inOB and rsiInOB and stInOB and (regDivBear or maxConfBear)
cleanBearTriggerRaw = scoreGapBear and (bearTrendSell or bearReversalSell)
cleanBearTrigger = useSellQuality ? cleanBearTriggerRaw : (bearCross or maxConfBear)

float intensity = math.abs(macdLine) / (dynOB > 0 ? dynOB : 0.001)
intensity := math.min(intensity, 1.0)

color bgColor = na

if showMatrixBG
    if inOB
        bgColor := intensity > 0.8 ? color.new(#5e0707, 72) :
                   intensity > 0.5 ? color.new(#1E1515, 88) :
                                     color.new(#141414, 94)
    else if inOS
        bgColor := intensity > 0.8 ? color.new(#0b3814, 72) :
                   intensity > 0.5 ? color.new(#151E17, 88) :
                                     color.new(#141414, 94)
    else if histBull and histRising
        bgColor := color.new(#121815, 86)
    else if histBear and histFalling
        bgColor := color.new(#181212, 86)
    else
        bgColor := color.new(#141414, 88)
else
    bgColor := na

bgcolor(bgColor, title="Matrix BG")
bgcolor(barstate.islast ? color.new(#9E9E9E, 96) : na, title="Scanner Line")

color histColor = histBull and histRising ? C_BULL :
                  histBull and not histRising ? C_BULL_D :
                  histBear and histFalling ? C_BEAR :
                  C_BEAR_D

plot(hist, title="MACD Hist", color=histColor, style=plot.style_columns, linewidth=2)

color glowColor = histBull ? color.new(#7CB342, 88) : color.new(#EF5350, 88)
plot(showGlow ? hist * 1.03 : na, title="Glow", color=glowColor, style=plot.style_columns, linewidth=3)

color macdColor = macdLine >= 0 ? color.new(#7bff00, 0) : color.new(#ff0000, 0)
pMacd = plot(macdLine, title="MACD", color=macdColor, linewidth=2)
pSig  = plot(sigLine, title="Signal", color=color.new(#0095ff, 0), linewidth=1)
fill(pMacd, pSig, color=macdLine > sigLine ? color.new(#7cb342, 99) : color.new(#ef5350, 99))

hline(0, "Zero", color=color.new(#757575, 15), linestyle=hline.style_solid, linewidth=1)
plot(dynOB, title="OB Level", color=color.new(#9E9E9E, 60), linewidth=1)
plot(dynOS, title="OS Level", color=color.new(#9E9E9E, 60), linewidth=1)

plot(showParticles and maxConfBear ? hist : na, title="Max Bear", color=C_MAX_BEAR, style=plot.style_circles, linewidth=4)
plot(showParticles and maxConfBull ? hist : na, title="Max Bull", color=C_MAX_BULL, style=plot.style_circles, linewidth=4)
plot(showParticles and (confBull_rsi or confBull_stoch) and not maxConfBull ? hist : na, title="Bull Conf", color=C_DIV_BULL, style=plot.style_circles, linewidth=3)
plot(showParticles and (confBear_rsi or confBear_stoch) and not maxConfBear ? hist : na, title="Bear Conf", color=C_DIV_BEAR, style=plot.style_circles, linewidth=3)

plot(showCrossDots and bullCross ? hist : na, title="Bull Cross", color=C_CROSS_BULL, style=plot.style_circles, linewidth=5)
plot(showCrossDots and bearCross ? hist : na, title="Bear Cross", color=C_CROSS_BEAR, style=plot.style_circles, linewidth=5)

plot(showBiasDots and bullScore > bearScore ? 0.0 : na, title="Bull Bias Marker", color=color.new(C_BULL, 0), style=plot.style_circles, linewidth=2)
plot(showBiasDots and bearScore > bullScore ? 0.0 : na, title="Bear Bias Marker", color=color.new(C_BEAR, 0), style=plot.style_circles, linewidth=2)

if showZeroArrows and zeroBull
    label.new(bar_index, 0, "▲", color=color.new(C_BULL, 18), textcolor=color.black, style=label.style_label_up, size=size.tiny)

if showZeroArrows and zeroBear
    label.new(bar_index, 0, "▼", color=color.new(C_BEAR, 18), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if showStrengthLab and bullCross and bullScore >= 60
    label.new(bar_index, hist, "S " + str.tostring(f_round(bullScore, 0)), color=color.new(C_CROSS_BULL, 25), textcolor=color.black, style=label.style_label_up, size=size.tiny)

if showStrengthLab and bearCross and bearScore >= 60
    label.new(bar_index, hist, "S " + str.tostring(f_round(bearScore, 0)), color=color.new(C_CROSS_BEAR, 25), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if showDivLabels and maxConfBull
    label.new(bar_index, dynOS * 1.10, "★ BULL", color=color.new(C_MAX_BULL, 20), textcolor=color.black, style=label.style_label_up, size=size.tiny)

if showDivLabels and maxConfBear
    label.new(bar_index, dynOB * 1.10, "★ BEAR", color=color.new(C_MAX_BEAR, 20), textcolor=color.black, style=label.style_label_down, size=size.tiny)

var int[]   sigTime   = array.new_int()
var float[] sigPrice  = array.new_float()
var bool[]  sigBull   = array.new_bool()
var float[] sigSL     = array.new_float()
var float[] sigTP     = array.new_float()
var int[]   sigState  = array.new_int()
var float[] sigScore  = array.new_float()
var float[] sigY      = array.new_float()
var label[] sigLabels = array.new_label()

bool newBullSignal = enableHistory and isBuySig and signalScore >= signalMinScore and (bullCross or maxConfBull)
bool newBearSignal = enableHistory and isSellSig and signalScore >= signalMinScore and cleanBearTrigger

float oscPad = math.max(math.abs(dynOB), math.abs(dynOS)) * 0.18 + math.abs(hist) * 0.08

if newBullSignal
    float entryBull = close
    float slBull    = entryBull - atr14 * signalATR
    float tpBull    = entryBull + (entryBull - slBull) * signalRR
    float yBull     = math.min(hist, macdLine) - oscPad

    array.unshift(sigTime, time)
    array.unshift(sigPrice, entryBull)
    array.unshift(sigBull, true)
    array.unshift(sigSL, slBull)
    array.unshift(sigTP, tpBull)
    array.unshift(sigState, 0)
    array.unshift(sigScore, signalScore)
    array.unshift(sigY, yBull)
    array.unshift(sigLabels, na)

if newBearSignal
    float entryBear = close
    float slBear    = entryBear + atr14 * signalATR
    float tpBear    = entryBear - (slBear - entryBear) * signalRR
    float yBear     = math.max(hist, macdLine) + oscPad

    array.unshift(sigTime, time)
    array.unshift(sigPrice, entryBear)
    array.unshift(sigBull, false)
    array.unshift(sigSL, slBear)
    array.unshift(sigTP, tpBear)
    array.unshift(sigState, 0)
    array.unshift(sigScore, signalScore)
    array.unshift(sigY, yBear)
    array.unshift(sigLabels, na)

int minSize = array.size(sigTime)
minSize := math.min(minSize, array.size(sigPrice))
minSize := math.min(minSize, array.size(sigBull))
minSize := math.min(minSize, array.size(sigSL))
minSize := math.min(minSize, array.size(sigTP))
minSize := math.min(minSize, array.size(sigState))
minSize := math.min(minSize, array.size(sigScore))
minSize := math.min(minSize, array.size(sigY))
minSize := math.min(minSize, array.size(sigLabels))

if minSize > historyMax
    if array.size(sigLabels) > 0
        label oldLbl = array.pop(sigLabels)
        if not na(oldLbl)
            label.delete(oldLbl)

    if array.size(sigTime) > 0
        array.pop(sigTime)
    if array.size(sigPrice) > 0
        array.pop(sigPrice)
    if array.size(sigBull) > 0
        array.pop(sigBull)
    if array.size(sigSL) > 0
        array.pop(sigSL)
    if array.size(sigTP) > 0
        array.pop(sigTP)
    if array.size(sigState) > 0
        array.pop(sigState)
    if array.size(sigScore) > 0
        array.pop(sigScore)
    if array.size(sigY) > 0
        array.pop(sigY)

int sigCount = math.min(array.size(sigState), math.min(array.size(sigBull), math.min(array.size(sigSL), array.size(sigTP))))
if enableHistory and sigCount > 0
    for i = 0 to sigCount - 1
        int st = array.get(sigState, i)
        if st == 0
            bool  isBullHist = array.get(sigBull, i)
            float slH        = array.get(sigSL, i)
            float tpH        = array.get(sigTP, i)

            bool hitWin  = isBullHist ? high >= tpH : low <= tpH
            bool hitLoss = isBullHist ? low <= slH  : high >= slH

            if hitWin
                array.set(sigState, i, 1)
            else if hitLoss
                array.set(sigState, i, -1)

int lblCount = array.size(sigLabels)
if enableHistory and historyLabels and barstate.islast and lblCount > 0
    for i = 0 to lblCount - 1
        label oldLb = array.get(sigLabels, i)
        if not na(oldLb)
            label.delete(oldLb)
            array.set(sigLabels, i, na)

    int maxLb = math.min(historyLabelCnt, math.min(array.size(sigTime), math.min(array.size(sigBull), math.min(array.size(sigState), math.min(array.size(sigScore), array.size(sigY))))))
    if maxLb > 0
        float zonePad = math.max(math.abs(dynOB), math.abs(dynOS)) * 0.10

        for i = 0 to maxLb - 1
            int   t  = array.get(sigTime, i)
            bool  bu = array.get(sigBull, i)
            int   st = array.get(sigState, i)
            float sc = array.get(sigScore, i)
            float y0 = array.get(sigY, i)

            float yPos = bu ? math.min(y0, dynOS - zonePad) : math.max(y0, dynOB + zonePad)

            string sideTxt   = bu ? "BUY " : "SELL "
            string scoreTxt  = str.tostring(f_round(sc, 0))
            string stateTxt  = st == 1 ? " ✅" : st == -1 ? " ❌" : " ⏳"
            string txt       = sideTxt + scoreTxt + stateTxt

            color bgCol = bu ?
                 (st == 1 ? color.new(#2E7D32, 45) : st == -1 ? color.new(#2E7D32, 60) : color.new(#2E7D32, 75))
                 :
                 (st == 1 ? color.new(#C62828, 45) : st == -1 ? color.new(#C62828, 60) : color.new(#C62828, 75))

            label lb = label.new(
                 x=t,
                 y=yPos,
                 text=txt,
                 xloc=xloc.bar_time,
                 color=bgCol,
                 textcolor=color.white,
                 style=bu ? label.style_label_up : label.style_label_down,
                 size=size.tiny)

            array.set(sigLabels, i, lb)

totalSignals = array.size(sigState)
wins = 0
losses = 0
openSigs = 0
bullSignals = 0
bearSignals = 0
bullWins = 0
bearWins = 0
avgScoreAcc = 0.0

if totalSignals > 0
    for i = 0 to totalSignals - 1
        int   st = array.get(sigState, i)
        bool  bu = array.get(sigBull, i)
        float sc = array.get(sigScore, i)

        avgScoreAcc += sc

        if bu
            bullSignals += 1
        else
            bearSignals += 1

        if st == 1
            wins += 1
            if bu
                bullWins += 1
            else
                bearWins += 1
        else if st == -1
            losses += 1
        else
            openSigs += 1

globalWR = wins + losses > 0 ? (wins / (wins + losses)) * 100.0 : na
bullWR   = bullSignals > 0 ? (bullWins / bullSignals) * 100.0 : na
bearWR   = bearSignals > 0 ? (bearWins / bearSignals) * 100.0 : na
avgScore = totalSignals > 0 ? avgScoreAcc / totalSignals : na

var table mainTbl   = table.new(f_panelPos(mainPanelPos), 2, 15, border_color=color.new(#39FF14, 35), border_width=1, frame_color=color.new(#39FF14, 20), frame_width=1)
var table statsTbl  = table.new(f_panelPos(statsPanelPos), 2, 10, border_color=color.new(#39FF14, 35), border_width=1, frame_color=color.new(#39FF14, 20), frame_width=1)
var table signalTbl = table.new(f_panelPos(signalPanelPos), 2, 10, border_color=color.new(#39FF14, 35), border_width=1, frame_color=color.new(#39FF14, 20), frame_width=1)

if showMainPanel and barstate.islast
    table.cell(mainTbl, 0, 0, "MATRIX ELITE", bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)
    table.cell(mainTbl, 1, 0, syminfo.ticker + " " + timeframe.period, bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)

    table.cell(mainTbl, 0, 1, "MACD", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 1, str.tostring(f_round(macdLine, 6)), bgcolor=C_PANEL_BG, text_color=macdColor, text_size=size.tiny)

    table.cell(mainTbl, 0, 2, "HIST", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 2, str.tostring(f_round(hist, 6)), bgcolor=C_PANEL_BG, text_color=histColor, text_size=size.tiny)

    table.cell(mainTbl, 0, 3, "RSI", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 3, str.tostring(f_round(rsi, 1)), bgcolor=C_PANEL_BG, text_color=rsiInOB ? C_HDIV_BEAR : rsiInOS ? C_HDIV_BULL : C_PANEL_TXT, text_size=size.tiny)

    table.cell(mainTbl, 0, 4, "STOCH", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 4, str.tostring(f_round(stochK_s, 1)), bgcolor=C_PANEL_BG, text_color=stInOB ? C_HDIV_BEAR : stInOS ? C_HDIV_BULL : C_PANEL_TXT, text_size=size.tiny)

    zoneStr = inOB ? "OVERBOUGHT" : inOS ? "OVERSOLD" : macdLine > 0 ? "BULL" : "BEAR"
    table.cell(mainTbl, 0, 5, "ZONE", bgcolor=C_PANEL_BG_2, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 5, zoneStr, bgcolor=C_PANEL_BG_2, text_color=inOB ? C_DIV_BEAR : inOS ? C_DIV_BULL : C_PANEL_TXT, text_size=size.tiny)

    divStr = regDivBull ? "DIV+ BULL" : regDivBear ? "DIV- BEAR" : hidDivBull ? "hDIV+ BULL" : hidDivBear ? "hDIV- BEAR" : "NONE"
    divCol = regDivBull ? C_DIV_BULL : regDivBear ? C_DIV_BEAR : hidDivBull ? C_HDIV_BULL : hidDivBear ? C_HDIV_BEAR : C_PANEL_DIM
    table.cell(mainTbl, 0, 6, "DIV", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 6, divStr, bgcolor=C_PANEL_BG, text_color=divCol, text_size=size.tiny)

    confStr = maxConfBull ? "MAX BULL" : maxConfBear ? "MAX BEAR" : confBull_both ? "BULL x2" : confBear_both ? "BEAR x2" : confBull_rsi or confBull_stoch ? "BULL" : confBear_rsi or confBear_stoch ? "BEAR" : "NONE"
    confCol = maxConfBull ? C_MAX_BULL : maxConfBear ? C_MAX_BEAR : confBull_rsi or confBull_stoch ? C_DIV_BULL : confBear_rsi or confBear_stoch ? C_DIV_BEAR : C_PANEL_DIM
    table.cell(mainTbl, 0, 7, "CONF", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 7, confStr, bgcolor=C_PANEL_BG, text_color=confCol, text_size=size.tiny)

    crossStr = bullCross ? "BULL CROSS" : bearCross ? "BEAR CROSS" : zeroBull ? "ZERO UP" : zeroBear ? "ZERO DOWN" : "NONE"
    crossCol = bullCross or zeroBull ? C_CROSS_BULL : bearCross or zeroBear ? C_CROSS_BEAR : C_PANEL_DIM
    table.cell(mainTbl, 0, 8, "CROSS", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 8, crossStr, bgcolor=C_PANEL_BG, text_color=crossCol, text_size=size.tiny)

    momStr = histRising and histBull ? "STRONG UP" : histRising ? "RECOVERING" : histBear and histFalling ? "STRONG DOWN" : "WEAKENING"
    momCol = histRising and histBull ? C_BULL : histRising ? C_HDIV_BULL : histBear and histFalling ? C_BEAR : C_HDIV_BEAR
    table.cell(mainTbl, 0, 9, "MOM", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 9, momStr, bgcolor=C_PANEL_BG, text_color=momCol, text_size=size.tiny)

    sigTxt = isBuySig and signalScore >= 55 ? "BUY" : isSellSig and signalScore >= 55 and cleanBearTrigger ? "SELL" : "WAIT"
    sigCol = isBuySig and signalScore >= 55 ? C_BULL : isSellSig and signalScore >= 55 and cleanBearTrigger ? C_BEAR : C_PANEL_DIM
    table.cell(mainTbl, 0, 10, "SIGNAL", bgcolor=C_PANEL_BG_2, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 10, sigTxt, bgcolor=C_PANEL_BG_2, text_color=sigCol, text_size=size.tiny)

    table.cell(mainTbl, 0, 11, "SCORE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 11, str.tostring(f_round(signalScore, 0)) + "/100", bgcolor=C_PANEL_BG, text_color=isBuySig ? C_BULL : isSellSig ? C_BEAR : C_PANEL_DIM, text_size=size.tiny)

    probTxt = bullProb > bearProb ? "BULL " + str.tostring(f_round(bullProb, 0)) + "%" : bearProb > bullProb ? "BEAR " + str.tostring(f_round(bearProb, 0)) + "%" : "50/50"
    probCol = bullProb > bearProb ? C_HDIV_BULL : bearProb > bullProb ? C_HDIV_BEAR : C_PANEL_DIM
    table.cell(mainTbl, 0, 12, "REV", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 12, probTxt, bgcolor=C_PANEL_BG, text_color=probCol, text_size=size.tiny)

    table.cell(mainTbl, 0, 13, "OB/OS", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 13, str.tostring(f_round(dynOB, 5)) + " / " + str.tostring(f_round(dynOS, 5)), bgcolor=C_PANEL_BG, text_color=C_PANEL_DIM, text_size=size.tiny)

    table.cell(mainTbl, 0, 14, "BIAS", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(mainTbl, 1, 14, bullScore > bearScore ? "BULL" : bearScore > bullScore ? "BEAR" : "NEUTRAL", bgcolor=C_PANEL_BG, text_color=bullScore > bearScore ? C_BULL : bearScore > bullScore ? C_BEAR : C_PANEL_TXT, text_size=size.tiny)

if showStatsPanel and barstate.islast
    table.cell(statsTbl, 0, 0, "SIGNAL STATS", bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)
    table.cell(statsTbl, 1, 0, str.tostring(totalSignals), bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)

    table.cell(statsTbl, 0, 1, "WINS", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 1, str.tostring(wins), bgcolor=C_PANEL_BG, text_color=C_BULL, text_size=size.tiny)

    table.cell(statsTbl, 0, 2, "LOSSES", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 2, str.tostring(losses), bgcolor=C_PANEL_BG, text_color=C_BEAR, text_size=size.tiny)

    table.cell(statsTbl, 0, 3, "OPEN", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 3, str.tostring(openSigs), bgcolor=C_PANEL_BG, text_color=C_NEUTRAL, text_size=size.tiny)

    table.cell(statsTbl, 0, 4, "WINRATE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 4, na(globalWR) ? "—" : str.tostring(f_round(globalWR, 1)) + "%", bgcolor=C_PANEL_BG, text_color=na(globalWR) ? C_PANEL_DIM : globalWR >= 50 ? C_BULL : C_BEAR, text_size=size.tiny)

    table.cell(statsTbl, 0, 5, "BULL SIG", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 5, str.tostring(bullSignals), bgcolor=C_PANEL_BG, text_color=C_DIV_BULL, text_size=size.tiny)

    table.cell(statsTbl, 0, 6, "BEAR SIG", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 6, str.tostring(bearSignals), bgcolor=C_PANEL_BG, text_color=C_DIV_BEAR, text_size=size.tiny)

    table.cell(statsTbl, 0, 7, "BULL WR", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 7, na(bullWR) ? "—" : str.tostring(f_round(bullWR, 1)) + "%", bgcolor=C_PANEL_BG, text_color=C_DIV_BULL, text_size=size.tiny)

    table.cell(statsTbl, 0, 8, "BEAR WR", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 8, na(bearWR) ? "—" : str.tostring(f_round(bearWR, 1)) + "%", bgcolor=C_PANEL_BG, text_color=C_DIV_BEAR, text_size=size.tiny)

    table.cell(statsTbl, 0, 9, "AVG SCORE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(statsTbl, 1, 9, na(avgScore) ? "—" : str.tostring(f_round(avgScore, 1)), bgcolor=C_PANEL_BG, text_color=C_NEUTRAL, text_size=size.tiny)

if showSignalPanel and barstate.islast
    table.cell(signalTbl, 0, 0, "LIVE ENGINE", bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)
    table.cell(signalTbl, 1, 0, "PRO", bgcolor=color.new(C_PANEL_HDR, 0), text_color=color.rgb(255, 255, 255), text_size=size.tiny)

    table.cell(signalTbl, 0, 1, "BULL SCORE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 1, str.tostring(f_round(bullScore, 0)), bgcolor=C_PANEL_BG, text_color=C_BULL, text_size=size.tiny)

    table.cell(signalTbl, 0, 2, "BEAR SCORE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 2, str.tostring(f_round(bearScore, 0)), bgcolor=C_PANEL_BG, text_color=C_BEAR, text_size=size.tiny)

    table.cell(signalTbl, 0, 3, "BULL REV", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 3, str.tostring(f_round(bullProb, 0)) + "%", bgcolor=C_PANEL_BG, text_color=C_HDIV_BULL, text_size=size.tiny)

    table.cell(signalTbl, 0, 4, "BEAR REV", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 4, str.tostring(f_round(bearProb, 0)) + "%", bgcolor=C_PANEL_BG, text_color=C_HDIV_BEAR, text_size=size.tiny)

    table.cell(signalTbl, 0, 5, "LAST CROSS", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 5, bullCross ? "BULL" : bearCross ? "BEAR" : "NONE", bgcolor=C_PANEL_BG, text_color=bullCross ? C_CROSS_BULL : bearCross ? C_CROSS_BEAR : C_PANEL_DIM, text_size=size.tiny)

    table.cell(signalTbl, 0, 6, "LAST DIV", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 6, regDivBull ? "REG BULL" : regDivBear ? "REG BEAR" : hidDivBull ? "HID BULL" : hidDivBear ? "HID BEAR" : "NONE", bgcolor=C_PANEL_BG, text_color=regDivBull ? C_DIV_BULL : regDivBear ? C_DIV_BEAR : hidDivBull ? C_HDIV_BULL : hidDivBear ? C_HDIV_BEAR : C_PANEL_DIM, text_size=size.tiny)

    table.cell(signalTbl, 0, 7, "MAX CONF", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 7, maxConfBull ? "BULL" : maxConfBear ? "BEAR" : "NO", bgcolor=C_PANEL_BG, text_color=maxConfBull ? C_MAX_BULL : maxConfBear ? C_MAX_BEAR : C_PANEL_DIM, text_size=size.tiny)

    table.cell(signalTbl, 0, 8, "TRACKING", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 8, enableHistory ? "ON" : "OFF", bgcolor=C_PANEL_BG, text_color=enableHistory ? C_NEUTRAL : C_PANEL_DIM, text_size=size.tiny)

    table.cell(signalTbl, 0, 9, "MIN SCORE", bgcolor=C_PANEL_BG, text_color=C_PANEL_TXT, text_size=size.tiny)
    table.cell(signalTbl, 1, 9, str.tostring(signalMinScore), bgcolor=C_PANEL_BG, text_color=C_NEUTRAL, text_size=size.tiny)

strongBull  = bullScore >= 70
strongBear  = bearScore >= 70 and cleanBearTrigger
revBullHigh = bullProb >= 70
revBearHigh = bearProb >= 70 and cleanBearTrigger

alertcondition(bullCross,      "MATRIX — MACD Bull Cross", "MACD Bull Cross")
alertcondition(bearCross,      "MATRIX — MACD Bear Cross", "MACD Bear Cross")
alertcondition(zeroBull,       "MATRIX — Zero Line Bull", "MACD Zero Bull")
alertcondition(zeroBear,       "MATRIX — Zero Line Bear", "MACD Zero Bear")
alertcondition(maxConfBull,    "MATRIX — MAX BULL", "Max Confluence Bull")
alertcondition(maxConfBear,    "MATRIX — MAX BEAR", "Max Confluence Bear")
alertcondition(regDivBull,     "MATRIX — Divergence BULL", "Regular Bull Divergence")
alertcondition(regDivBear,     "MATRIX — Divergence BEAR", "Regular Bear Divergence")
alertcondition(hidDivBull,     "MATRIX — Hidden Div BULL", "Hidden Bull Divergence")
alertcondition(hidDivBear,     "MATRIX — Hidden Div BEAR", "Hidden Bear Divergence")
alertcondition(strongBull,     "MATRIX — Strong Bull Signal", "Strong Bull Signal")
alertcondition(strongBear,     "MATRIX — Strong Bear Signal", "Strong Bear Signal")
alertcondition(revBullHigh,    "MATRIX — High Bull Reversal Probability", "High Bull Reversal Probability")
alertcondition(revBearHigh,    "MATRIX — High Bear Reversal Probability", "High Bear Reversal Probability")
alertcondition(newBullSignal,  "MATRIX — New Tracked Bull Signal", "New Tracked Bull Signal")
alertcondition(newBearSignal,  "MATRIX — New Tracked Bear Signal", "New Tracked Bear Signal")
````
