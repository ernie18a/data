# Mobile Wallstreet Confidence Indicator

- url: https://www.tradingview.com/script/yg4scw7O-Mobile-Wallstreet-Confidence-Indicator/
- type: indicator
- pine_id: PUB;4b00e9a2b111420e9d5419fda2e59764
- version: 11.0

## Description

Mobile Wallstreet Confidence Indicator
Most indicators lie to you. They fire signals on every candle, flood your chart with noise, and leave you holding the bag wondering what went wrong. This one is different.
The Mobile Wallstreet Confidence Indicator was engineered to stay silent until the market is genuinely ready — and when it fires, you'll know exactly why and exactly how confident the setup is.

HOW IT WORKS
Every signal passes through a strict 6-layer filter system before a single arrow appears on your chart:
1. Multi-Timeframe Stack (M15 / H1 / H4 / D1)
The indicator reads all four timeframes simultaneously using a triple EMA alignment model. You control how many must agree before a signal is even considered. No more trading against the higher timeframe trend.
2. Hull MA Momentum Gate
Price must be on the correct side of a rising or falling Hull MA. If momentum isn't confirmed, the signal is blocked — full stop.
3. ATR Depth & Range Filter
The market must show meaningful range and retrace depth relative to ATR. Flat, choppy, low-conviction price action gets filtered out automatically.
4. Structure Clearance
Signals won't fire into overhead resistance or below key support. The indicator measures structure clearance in ATR units so it adapts to every market and every volatility environment.
5. Pattern Rank (0–10)
Each setup is scored across 5 criteria — EMA alignment, RSI momentum, structure break, candle body strength, and price position. Only setups above your minimum rank threshold make the cut.
6. Confidence Score (0–100)
Every signal comes with a live confidence score weighted across MTF agreement, trend alignment, Hull momentum, RSI strength, and pattern rank. You see the number. You decide your conviction.

WHAT YOU GET ON THE CHART
🟢 BUY arrow — all layers aligned bullish, confidence threshold met
🔴 SELL arrow — all layers aligned bearish, confidence threshold met
📊 MTF Dashboard — live top-right panel showing M15 / H1 / H4 / D1 direction, bull/bear counts, confidence scores, pattern ranks, and a plain-English status message telling you exactly what the market is waiting on
🏷️ Signal Labels — confidence score and pattern rank printed directly on every arrow so you never have to guess signal quality

FULLY CUSTOMIZABLE
Every parameter is adjustable to fit your trading style:

Execution timeframe
Fast / Slow EMA periods
Hull MA period
ATR period
Number of MTF timeframes required to agree
Minimum confidence score threshold
Minimum pattern rank threshold
Retrace depth multiplier
Structure clearance multiplier
Structure lookback window
Toggle new signals only, labels, and dashboard on/off


BUILT-IN ALERTS
Set TradingView alerts on BUY and SELL signals and never miss a setup — whether you're watching the screen or not.

WHO THIS IS FOR
This indicator is for traders who are done with noise. If you want a tool that thinks before it speaks, filters relentlessly, and gives you full transparency on every signal it generates — this was built for you.
Swing traders. Day traders. Multi-timeframe operators. Anyone who trades with a plan.

Mobile Wallstreet. Confidence on every candle.

## Source Code

````pine
//@version=6
indicator("Mobile Wallstreet Confidence Indicator", shorttitle="Mobile Wallstreet Confidence Indicator", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

//====================================================
// MOBILE WALLSTREET CONFIDENCE INDICATOR v5.6 CLEAN PROJECTION RIBBON
// Fixes:
// - Reduced unique request.security calls so TradingView can load/update chart
// - Dashboard no longer offers Bottom Left, avoiding conflict with trade-plan panel
// - Removed confusing "exit" wording from status/sentiment guidance
// - Reversal detection checks pattern names correctly
// - Pane Labels / candle score clutter now defaults OFF
// - Bottom ribbon now shows projected next-candle color after support, resistance, patterns, MTF, confidence, and ribbon logic
// - Indicator status/name area cleaned so it does not show extra ribbon plot numbers
//====================================================

//==============================
// CORE SETTINGS
//==============================
execTf              = input.timeframe("30", "Execution / scanner timeframe")
fastLen             = input.int(9, "Fast EMA period", minval=1)
slowLen             = input.int(21, "Slow EMA period", minval=2)
midLen              = input.int(50, "Middle EMA period", minval=5)
longLen             = input.int(200, "Long EMA period", minval=20)
hullLen             = input.int(34, "Hull MA period", minval=2)
atrLen              = input.int(14, "ATR period", minval=1)

mtfRequired         = input.int(3, "MTF timeframes required to agree", minval=2, maxval=4)
minConfidence       = input.int(45, "Minimum confidence score", minval=0, maxval=100)
minRank             = input.int(4, "Minimum rank", minval=0, maxval=10)
strongConfidence    = input.int(80, "STRONG signal confidence", minval=50, maxval=100)
strongRank          = input.int(8, "STRONG signal rank", minval=4, maxval=10)
earlyConfidence     = input.int(65, "EARLY signal confidence", minval=35, maxval=100)

structureLookback   = input.int(20, "Structure lookback bars", minval=5)
minRetraceDepth     = input.float(0.10, "Minimum retrace/depth ATR", minval=0.0, step=0.05)
structureAtr        = input.float(0.50, "Structure clearance ATR", minval=0.0, step=0.05)

//==============================
// FRACTAL RIBBON SETTINGS
//==============================
useFractalRibbonGate = input.bool(true, "Use built-in Fractal Ribbon verification")
frFastLen            = input.int(10, "Fractal Ribbon fast length", minval=1)
frSlowLen            = input.int(21, "Fractal Ribbon slow length", minval=2)
frUpper              = input.float(75.0, "Fractal Ribbon upper guide", minval=1, maxval=100)
frLower              = input.float(25.0, "Fractal Ribbon lower guide", minval=0, maxval=99)
frPivotLeft          = input.int(1, "Fractal pivot left bars", minval=1, maxval=10)
frPivotRight         = input.int(1, "Fractal pivot right bars", minval=1, maxval=10)

//==============================
// ZONE SETTINGS
//==============================
showZones            = input.bool(true, "Show Buy/Sell support-resistance zones")
zoneTf               = input.timeframe("60", "Zone timeframe")
zoneLookback         = input.int(60, "Zone lookback", minval=10, maxval=300)
zoneAtrMult          = input.float(0.45, "Zone thickness ATR", minval=0.05, step=0.05)
zonePastBars         = input.int(80, "Zone starts bars back", minval=10, maxval=500)
zoneFutureBars       = input.int(40, "Zone projects bars forward", minval=5, maxval=500)
zoneTransparency     = input.int(82, "Zone transparency", minval=0, maxval=100)
requireZoneExit      = input.bool(true, "Signals only after clean zone move")
zoneExitBars         = input.int(5, "Bars after zone touch allowed", minval=1, maxval=50)
postRetestBars       = input.int(20, "Post-retest lookback bars", minval=2, maxval=100)
retestToleranceAtr   = input.float(0.25, "Retest tolerance ATR", minval=0.0, step=0.05)
strongRequiresRetest = input.bool(true, "STRONG signals require post-retest")

//==============================
// HTF SUPPORT / RESISTANCE SHORT LINES
//==============================
showHTFSRShortLines  = input.bool(true, "Show 4H/D/W/M support-resistance short lines")
htfShortLineLen      = input.int(12, "HTF short line length (bars)", minval=2, maxval=100)
htfShortLineWidth    = input.int(2, "HTF short line width", minval=1, maxval=4)

//==============================
// UNIQUE SWING TRENDLINES
//==============================
showUniqueTrendlines = input.bool(true, "Show unique swing trendlines")
swingTrendLeft       = input.int(3, "Swing trendline left bars", minval=1, maxval=20)
swingTrendRight      = input.int(3, "Swing trendline right bars", minval=1, maxval=20)
swingTrendWidth      = input.int(2, "Swing trendline width", minval=1, maxval=4)

//==============================
// FAKEOUT / REPEAT CONTROL
//==============================
useClosedTf          = input.bool(true, "Use closed execution candle only")
requireConfirmBody   = input.bool(true, "Require candle body confirmation")
oneSignalPerTrend    = input.bool(true, "Block repeat arrows until trend changes/upgrades")
cooldownBars         = input.int(6, "Minimum bars between repeat signals", minval=0, maxval=100)

showEarlySignals     = input.bool(true, "Show EARLY BUY / EARLY SELL")
showStrongSignals    = input.bool(true, "Show STRONG BUY / STRONG SELL")
showNormalSignals    = input.bool(true, "Show normal BUY / SELL")
showHistorical       = input.bool(true, "Show historical signal labels")

//==============================
// CANDLE SCORE SETTINGS
//==============================
showCandleScores     = input.bool(false, "Pane Labels")
candleScoreMode      = input.string("Confidence", "Candle number type", options=["Confidence", "Rank", "Both"])
scoreEveryBars       = input.int(1, "Show score every N candles", minval=1, maxval=20)
scoreSide            = input.string("Winning Side", "Candle score side", options=["Winning Side", "Buy Only", "Sell Only"])
scoreLabelSizeOpt    = input.string("Tiny", "Candle score size", options=["Tiny", "Small", "Normal"])
scoreOffsetAtr       = input.float(0.10, "Candle score distance ATR", minval=0.0, step=0.05)
scoreLocationOpt     = input.string("Auto", "Candle score location", options=["Auto", "Above Candle", "Below Candle"])

//==============================
// LOOK / FEEL SETTINGS
//==============================
showDashboard        = input.bool(true, "Show dashboard")
dashPositionOpt      = input.string("Top Right", "Dashboard position", options=["Top Right", "Top Left", "Bottom Right", "Middle Right"])
dashTextSizeOpt      = input.string("Tiny", "Dashboard text size", options=["Tiny", "Small", "Normal"])

signalSizeOpt        = input.string("Tiny", "Signal label size", options=["Tiny", "Small", "Normal", "Large"])
signalDetailOpt      = input.string("Compact", "Signal label detail", options=["Arrow Only", "Compact", "Full"])
signalOffsetAtr      = input.float(0.25, "Signal distance from candle ATR", minval=0.0, step=0.05)
signalAnchorOpt      = input.string("Auto", "Signal label anchor", options=["Auto", "Candle", "Support/Resistance Zone"])

enableTalkingAlerts  = input.bool(true, "Enable talk-style active sentiment alerts")

showTradePlanPanel   = input.bool(true, "Show lower-left active signal trade plan")
entryBandAtr         = input.float(0.15, "Entry range thickness ATR", minval=0.01, step=0.01)
slBufferAtr          = input.float(0.10, "SL buffer beyond zone ATR", minval=0.0, step=0.05)
tp1RR                = input.float(1.00, "TP1 risk/reward", minval=0.10, step=0.05)
tp2RR                = input.float(1.50, "TP2 risk/reward", minval=0.10, step=0.05)

showFutureForecast   = input.bool(true, "Show 10-candle future forecast")
forecastStyleOpt     = input.string("Both", "Forecast display style", options=["Candles", "Line", "Both"])
forecastBars         = input.int(10, "Forecast candles forward", minval=1, maxval=50)
forecastLookback     = input.int(20, "Forecast slope lookback", minval=5, maxval=100)
forecastAtrMult      = input.float(1.00, "Forecast ATR strength", minval=0.10, step=0.05)
forecastOnlyActive   = input.bool(false, "Forecast only when active signal/sentiment exists")
forecastCandleWickAtr= input.float(0.35, "Forecast candle wick ATR", minval=0.01, step=0.01)
forecastCandleBodyMin= input.float(0.18, "Forecast minimum candle body ATR", minval=0.01, step=0.01)
forecastRespectMTFSR = input.bool(true, "Forecast respects MTF support/resistance")
forecastVisualMinAtr = input.float(1.00, "Minimum visible forecast distance ATR", minval=0.0, step=0.10)
forecastDrawRail     = input.bool(true, "Draw forecast visibility rail")
forecastSRLookback   = input.int(50, "MTF S/R forecast lookback", minval=10, maxval=300)
forecastSRBufferAtr  = input.float(0.15, "Forecast S/R buffer ATR", minval=0.0, step=0.05)

showActivePatternLabel = input.bool(true, "Show active major pattern label")
showHistoricalPatternLabels = input.bool(true, "Show historical pattern labels")
showCurrentPatternBadge = input.bool(true, "Show current active pattern badge")
patternLabelSizeOpt    = input.string("Tiny", "Pattern label size", options=["Tiny", "Small", "Normal", "Large"])
patternAnchorOpt       = input.string("Candle", "Pattern label anchor", options=["Auto", "Candle", "Support/Resistance Zone"])
minPatternLabelScore   = input.int(5, "Minimum pattern score to label", minval=0, maxval=10)
patternTrapBars        = input.int(5, "Failed breakout trap bars", minval=1, maxval=20)
doublePatternToleranceAtr = input.float(0.35, "Double top/bottom ATR tolerance", minval=0.05, step=0.05)
flagLookback           = input.int(8, "Flag pattern pullback lookback", minval=3, maxval=30)
usePatternCompatibilityGate = input.bool(true, "Block signals against strong opposite pattern")

showRibbonMarks      = input.bool(true, "Show projected next-candle ribbon at chart bottom")
showBarColor         = input.bool(false, "Color candles by MWCI ribbon")
showBackground       = input.bool(false, "Show soft MWCI background color")

//==============================
// VISUAL SIZE MAPPING
//==============================
sigSize = signalSizeOpt == "Tiny" ? size.tiny : signalSizeOpt == "Small" ? size.small : signalSizeOpt == "Normal" ? size.normal : size.large
dashSize = dashTextSizeOpt == "Tiny" ? size.tiny : dashTextSizeOpt == "Small" ? size.small : size.normal
scoreSize = scoreLabelSizeOpt == "Tiny" ? size.tiny : scoreLabelSizeOpt == "Small" ? size.small : size.normal
patternSize = patternLabelSizeOpt == "Tiny" ? size.tiny : patternLabelSizeOpt == "Small" ? size.small : patternLabelSizeOpt == "Normal" ? size.normal : size.large

dashPos = dashPositionOpt == "Top Left" ? position.top_left : dashPositionOpt == "Bottom Right" ? position.bottom_right : dashPositionOpt == "Middle Right" ? position.middle_right : position.top_right

//==============================
// MTF DIRECTION FUNCTION
// 1 = bullish, -1 = bearish, 0 = neutral
// FIXED: one request.security call per timeframe instead of four.
//==============================
f_mtfDir(tf) =>
    [c, f, s, sp] = request.security(syminfo.tickerid, tf, [useClosedTf ? close[1] : close, useClosedTf ? ta.ema(close, fastLen)[1] : ta.ema(close, fastLen), useClosedTf ? ta.ema(close, slowLen)[1] : ta.ema(close, slowLen), useClosedTf ? ta.ema(close, slowLen)[2] : ta.ema(close, slowLen)[1]], barmerge.gaps_off, barmerge.lookahead_off)
    bull = f > s and c > s and s > sp
    bear = f < s and c < s and s < sp
    bull ? 1 : bear ? -1 : 0

//==============================
// EXECUTION TIMEFRAME DATA
//==============================
[oX, hX, lX, cX, vX, fastX, slowX, midX, longX, slowPrevX, midPrevX, longPrevX, hmaX, hmaPrevX, atrX, rsiX, rsiPrevX, cciX, mfiX, stochKX, stochDX, willrX, vwmaX, vwmaPrevX, bbBasisX, bbUpperX, bbLowerX, donHiX, donLoX, sarX, obvX, obvPrevX, highPrevX, lowPrevX, high10X, low10X] = request.security(syminfo.tickerid, execTf, [open, high, low, close, volume, ta.ema(close, fastLen), ta.ema(close, slowLen), ta.ema(close, midLen), ta.ema(close, longLen), ta.ema(close, slowLen)[1], ta.ema(close, midLen)[1], ta.ema(close, longLen)[1], ta.hma(close, hullLen), ta.hma(close, hullLen)[1], ta.atr(atrLen), ta.rsi(close, 14), ta.rsi(close, 14)[1], ta.cci(hlc3, 20), ta.mfi(hlc3, 14), ta.stoch(close, high, low, 14), ta.sma(ta.stoch(close, high, low, 14), 3), (ta.highest(high, 14) - close) / math.max(ta.highest(high, 14) - ta.lowest(low, 14), syminfo.mintick) * -100.0, ta.vwma(close, 20), ta.vwma(close, 20)[1], ta.sma(close, 20), ta.sma(close, 20) + ta.stdev(close, 20) * 2.0, ta.sma(close, 20) - ta.stdev(close, 20) * 2.0, ta.highest(high, 20)[1], ta.lowest(low, 20)[1], ta.sar(0.02, 0.02, 0.2), ta.cum(math.sign(ta.change(close)) * volume), ta.cum(math.sign(ta.change(close)) * volume)[1], ta.highest(high, structureLookback)[1], ta.lowest(low, structureLookback)[1], ta.highest(high, 10), ta.lowest(low, 10)], barmerge.gaps_off, barmerge.lookahead_off)

[macdLineX, macdSignalX, macdHistX] = request.security(syminfo.tickerid, execTf, ta.macd(close, 12, 26, 9), barmerge.gaps_off, barmerge.lookahead_off)
[pdiX, mdiX, adxX] = request.security(syminfo.tickerid, execTf, ta.dmi(14, 14), barmerge.gaps_off, barmerge.lookahead_off)

//==============================
// BUILT-IN FRACTAL RIBBON
//==============================
frOscRaw = request.security(syminfo.tickerid, execTf, ta.rsi(close, 14), barmerge.gaps_off, barmerge.lookahead_off)
frFast = ta.ema(frOscRaw, frFastLen)
frSlow = ta.ema(frOscRaw, frSlowLen)
frPivotHigh = request.security(syminfo.tickerid, execTf, ta.pivothigh(high, frPivotLeft, frPivotRight), barmerge.gaps_off, barmerge.lookahead_off)
frPivotLow  = request.security(syminfo.tickerid, execTf, ta.pivotlow(low, frPivotLeft, frPivotRight), barmerge.gaps_off, barmerge.lookahead_off)

var float lastFractalHigh = na
var float lastFractalLow = na
if not na(frPivotHigh)
    lastFractalHigh := frPivotHigh
if not na(frPivotLow)
    lastFractalLow := frPivotLow

frBreakBull = not na(lastFractalHigh) and cX > lastFractalHigh
frBreakBear = not na(lastFractalLow) and cX < lastFractalLow
frRibbonBull = frFast > frSlow and frFast > 50 and (frBreakBull or cX > slowX)
frRibbonBear = frFast < frSlow and frFast < 50 and (frBreakBear or cX < slowX)
frRibbonNeutral = not frRibbonBull and not frRibbonBear

//==============================
// SWING TRENDLINE DETECTION
//==============================
swingPivotHigh = ta.pivothigh(high, swingTrendLeft, swingTrendRight)
swingPivotLow = ta.pivotlow(low, swingTrendLeft, swingTrendRight)

var float lastSwingHigh1 = na
var float lastSwingHigh2 = na
var int lastSwingHighBar1 = na
var int lastSwingHighBar2 = na
var float lastSwingLow1 = na
var float lastSwingLow2 = na
var int lastSwingLowBar1 = na
var int lastSwingLowBar2 = na

if not na(swingPivotHigh)
    lastSwingHigh2 := lastSwingHigh1
    lastSwingHighBar2 := lastSwingHighBar1
    lastSwingHigh1 := swingPivotHigh
    lastSwingHighBar1 := bar_index - swingTrendRight

if not na(swingPivotLow)
    lastSwingLow2 := lastSwingLow1
    lastSwingLowBar2 := lastSwingLowBar1
    lastSwingLow1 := swingPivotLow
    lastSwingLowBar1 := bar_index - swingTrendRight

//==============================
// MTF STACK
//==============================
dirM15 = f_mtfDir("15")
dirH1  = f_mtfDir("60")
dirH4  = f_mtfDir("240")
dirD1  = f_mtfDir("D")
dirW1  = f_mtfDir("W")
dirMN1 = f_mtfDir("M")

[h4ResClosed, h4SupClosed] = request.security(syminfo.tickerid, "240", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[d1ResClosed, d1SupClosed] = request.security(syminfo.tickerid, "D", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[w1ResClosed, w1SupClosed] = request.security(syminfo.tickerid, "W", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)
[mn1ResClosed, mn1SupClosed] = request.security(syminfo.tickerid, "M", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_off)

bullCount = (dirM15 == 1 ? 1 : 0) + (dirH1 == 1 ? 1 : 0) + (dirH4 == 1 ? 1 : 0) + (dirD1 == 1 ? 1 : 0)
bearCount = (dirM15 == -1 ? 1 : 0) + (dirH1 == -1 ? 1 : 0) + (dirH4 == -1 ? 1 : 0) + (dirD1 == -1 ? 1 : 0)

mtfBullOK = bullCount >= mtfRequired and bullCount > bearCount
mtfBearOK = bearCount >= mtfRequired and bearCount > bullCount

//==============================
// 36-FACTOR CONFIDENCE ENGINE
//==============================
body = math.abs(cX - oX)
candleRange = math.max(hX - lX, syminfo.mintick)
upperWick = hX - math.max(oX, cX)
lowerWick = math.min(oX, cX) - lX
bodyBullOK = cX > oX and body >= atrX * 0.12
bodyBearOK = cX < oX and body >= atrX * 0.12
confirmBullOK = not requireConfirmBody or bodyBullOK
confirmBearOK = not requireConfirmBody or bodyBearOK
range10 = high10X - low10X
depthOK = range10 >= atrX * minRetraceDepth
structureBullOK = cX > highPrevX or (highPrevX - cX) >= atrX * structureAtr
structureBearOK = cX < lowPrevX or (cX - lowPrevX) >= atrX * structureAtr
donMidX = (donHiX + donLoX) / 2.0
bbMidUpper = (bbBasisX + bbUpperX) / 2.0
bbMidLower = (bbBasisX + bbLowerX) / 2.0

f_sum36(bull) =>
    int s = 0
    if bull
        s += mtfBullOK ? 1 : 0
        s += bullCount > bearCount ? 1 : 0
        s += dirM15 == 1 ? 1 : 0
        s += dirH1 == 1 ? 1 : 0
        s += (dirH4 == 1 or dirD1 == 1) ? 1 : 0
        s += cX > fastX ? 1 : 0
        s += fastX > slowX ? 1 : 0
        s += cX > slowX ? 1 : 0
        s += slowX > slowPrevX ? 1 : 0
        s += midX > longX ? 1 : 0
        s += cX > midX ? 1 : 0
        s += hmaX > hmaPrevX ? 1 : 0
        s += cX > hmaX ? 1 : 0
        s += rsiX > 50 ? 1 : 0
        s += rsiX > rsiPrevX ? 1 : 0
        s += macdLineX > macdSignalX ? 1 : 0
        s += macdHistX > 0 ? 1 : 0
        s += cciX > 0 ? 1 : 0
        s += stochKX > stochDX ? 1 : 0
        s += stochKX > 50 ? 1 : 0
        s += mfiX > 50 ? 1 : 0
        s += willrX > -50 ? 1 : 0
        s += adxX > 15 and pdiX > mdiX ? 1 : 0
        s += sarX < cX ? 1 : 0
        s += obvX > obvPrevX ? 1 : 0
        s += vwmaX > vwmaPrevX ? 1 : 0
        s += cX > vwmaX ? 1 : 0
        s += cX > bbBasisX ? 1 : 0
        s += cX > bbMidUpper ? 1 : 0
        s += cX > donMidX ? 1 : 0
        s += cX > highPrevX ? 1 : 0
        s += bodyBullOK ? 1 : 0
        s += body >= atrX * 0.12 ? 1 : 0
        s += lowerWick > upperWick ? 1 : 0
        s += frRibbonBull ? 1 : 0
        s += structureBullOK ? 1 : 0
    else
        s += mtfBearOK ? 1 : 0
        s += bearCount > bullCount ? 1 : 0
        s += dirM15 == -1 ? 1 : 0
        s += dirH1 == -1 ? 1 : 0
        s += (dirH4 == -1 or dirD1 == -1) ? 1 : 0
        s += cX < fastX ? 1 : 0
        s += fastX < slowX ? 1 : 0
        s += cX < slowX ? 1 : 0
        s += slowX < slowPrevX ? 1 : 0
        s += midX < longX ? 1 : 0
        s += cX < midX ? 1 : 0
        s += hmaX < hmaPrevX ? 1 : 0
        s += cX < hmaX ? 1 : 0
        s += rsiX < 50 ? 1 : 0
        s += rsiX < rsiPrevX ? 1 : 0
        s += macdLineX < macdSignalX ? 1 : 0
        s += macdHistX < 0 ? 1 : 0
        s += cciX < 0 ? 1 : 0
        s += stochKX < stochDX ? 1 : 0
        s += stochKX < 50 ? 1 : 0
        s += mfiX < 50 ? 1 : 0
        s += willrX < -50 ? 1 : 0
        s += adxX > 15 and mdiX > pdiX ? 1 : 0
        s += sarX > cX ? 1 : 0
        s += obvX < obvPrevX ? 1 : 0
        s += vwmaX < vwmaPrevX ? 1 : 0
        s += cX < vwmaX ? 1 : 0
        s += cX < bbBasisX ? 1 : 0
        s += cX < bbMidLower ? 1 : 0
        s += cX < donMidX ? 1 : 0
        s += cX < lowPrevX ? 1 : 0
        s += bodyBearOK ? 1 : 0
        s += body >= atrX * 0.12 ? 1 : 0
        s += upperWick > lowerWick ? 1 : 0
        s += frRibbonBear ? 1 : 0
        s += structureBearOK ? 1 : 0
    s

bullRaw = f_sum36(true)
bearRaw = f_sum36(false)
bullConf = int(math.round(bullRaw / 36.0 * 100.0))
bearConf = int(math.round(bearRaw / 36.0 * 100.0))
bullRank = int(math.round(bullRaw / 3.6))
bearRank = int(math.round(bearRaw / 3.6))

winningBuy = bullConf >= bearConf
candleConf = scoreSide == "Buy Only" ? bullConf : scoreSide == "Sell Only" ? bearConf : winningBuy ? bullConf : bearConf
candleRank = scoreSide == "Buy Only" ? bullRank : scoreSide == "Sell Only" ? bearRank : winningBuy ? bullRank : bearRank
candleDir = scoreSide == "Buy Only" ? 1 : scoreSide == "Sell Only" ? -1 : winningBuy ? 1 : -1
candleScoreText = candleScoreMode == "Rank" ? str.tostring(candleRank) : candleScoreMode == "Both" ? str.tostring(candleConf) + "/" + str.tostring(candleRank) : str.tostring(candleConf)

//==============================
// MWCI RIBBON ENGINE
//==============================
rawPressure = bullConf - bearConf
ribbonFast = ta.ema(rawPressure, 5)
ribbonSlow = ta.ema(rawPressure, 13)
ribbonBull = ribbonFast > ribbonSlow and ribbonFast > 5 and frRibbonBull
ribbonBear = ribbonFast < ribbonSlow and ribbonFast < -5 and frRibbonBear
ribbonNeutral = not ribbonBull and not ribbonBear
ribbonText = ribbonBull ? "BULL" : ribbonBear ? "BEAR" : "NEUTRAL"
ribbonColor = ribbonBull ? color.new(color.green, 0) : ribbonBear ? color.new(color.red, 0) : color.new(color.gray, 0)

bgcolor(showBackground ? ribbonBull ? color.new(color.green, 90) : ribbonBear ? color.new(color.red, 90) : na : na)
barcolor(showBarColor ? ribbonBull ? color.new(color.green, 0) : ribbonBear ? color.new(color.red, 0) : na : na)

//==============================
// BUY / SELL ZONES
//==============================
[zoneHigh, zoneLow, zoneAtr] = request.security(syminfo.tickerid, zoneTf, [ta.highest(high, zoneLookback), ta.lowest(low, zoneLookback), ta.atr(atrLen)], barmerge.gaps_off, barmerge.lookahead_off)
buyZoneLow = zoneLow
buyZoneHigh = zoneLow + zoneAtr * zoneAtrMult
sellZoneHigh = zoneHigh
sellZoneLow = zoneHigh - zoneAtr * zoneAtrMult

var box buyZoneBox = na
var box sellZoneBox = na
if showZones and barstate.islast
    if na(buyZoneBox)
        buyZoneBox := box.new(bar_index - zonePastBars, buyZoneHigh, bar_index + zoneFutureBars, buyZoneLow, bgcolor=color.new(color.green, zoneTransparency), border_color=color.new(color.green, 35))
    else
        box.set_left(buyZoneBox, bar_index - zonePastBars)
        box.set_right(buyZoneBox, bar_index + zoneFutureBars)
        box.set_top(buyZoneBox, buyZoneHigh)
        box.set_bottom(buyZoneBox, buyZoneLow)
    if na(sellZoneBox)
        sellZoneBox := box.new(bar_index - zonePastBars, sellZoneHigh, bar_index + zoneFutureBars, sellZoneLow, bgcolor=color.new(color.red, zoneTransparency), border_color=color.new(color.red, 35))
    else
        box.set_left(sellZoneBox, bar_index - zonePastBars)
        box.set_right(sellZoneBox, bar_index + zoneFutureBars)
        box.set_top(sellZoneBox, sellZoneHigh)
        box.set_bottom(sellZoneBox, sellZoneLow)

if not showZones and barstate.islast
    if not na(buyZoneBox)
        box.delete(buyZoneBox)
        buyZoneBox := na
    if not na(sellZoneBox)
        box.delete(sellZoneBox)
        sellZoneBox := na

//==============================
// ZONE CONTEXT + POST-RETEST VERIFICATION
//==============================
inBuyZone = lX <= buyZoneHigh and hX >= buyZoneLow
inSellZone = hX >= sellZoneLow and lX <= sellZoneHigh
barsSinceBuyZone = ta.barssince(inBuyZone)
barsSinceSellZone = ta.barssince(inSellZone)
recentBuyZoneTouch = not na(barsSinceBuyZone) and barsSinceBuyZone <= zoneExitBars
recentSellZoneTouch = not na(barsSinceSellZone) and barsSinceSellZone <= zoneExitBars
recentBuyZoneTouchPrev = not na(barsSinceBuyZone[1]) and barsSinceBuyZone[1] <= zoneExitBars
recentSellZoneTouchPrev = not na(barsSinceSellZone[1]) and barsSinceSellZone[1] <= zoneExitBars

buyZoneExit = recentBuyZoneTouchPrev and cX > buyZoneHigh and cX > oX
sellZoneExit = recentSellZoneTouchPrev and cX < sellZoneLow and cX < oX
buyBreakoutNow = cX > buyZoneHigh and cX[1] <= buyZoneHigh[1]
sellBreakoutNow = cX < sellZoneLow and cX[1] >= sellZoneLow[1]
barsSinceBuyBreakout = ta.barssince(buyBreakoutNow)
barsSinceSellBreakout = ta.barssince(sellBreakoutNow)
buyPostRetest = not na(barsSinceBuyBreakout) and barsSinceBuyBreakout > 0 and barsSinceBuyBreakout <= postRetestBars and lX <= buyZoneHigh + atrX * retestToleranceAtr and cX > buyZoneHigh and cX > oX
sellPostRetest = not na(barsSinceSellBreakout) and barsSinceSellBreakout > 0 and barsSinceSellBreakout <= postRetestBars and hX >= sellZoneLow - atrX * retestToleranceAtr and cX < sellZoneLow and cX < oX

buyZoneOK = not requireZoneExit or buyZoneExit or buyPostRetest
sellZoneOK = not requireZoneExit or sellZoneExit or sellPostRetest
zoneBullEvent = buyPostRetest or buyZoneExit
zoneBearEvent = sellPostRetest or sellZoneExit

activeSentimentDir = 0
activeSentimentText = requireZoneExit ? "WAITING FOR ALIGNED SENTIMENT" : "SENTIMENT FILTER OFF"
activeSentimentColor = color.new(color.gray, 35)
activeBuySentimentStart = false
activeSellSentimentStart = false

//==============================
// MAJOR PATTERN ENGINE
//==============================
prevBodyHigh = math.max(oX[1], cX[1])
prevBodyLow = math.min(oX[1], cX[1])
currBodyHigh = math.max(oX, cX)
currBodyLow = math.min(oX, cX)
bodyPct = body / candleRange
upperWickPct = upperWick / candleRange
lowerWickPct = lowerWick / candleRange

bullEngulf = cX > oX and cX[1] < oX[1] and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow
bearEngulf = cX < oX and cX[1] > oX[1] and currBodyHigh >= prevBodyHigh and currBodyLow <= prevBodyLow
doji = bodyPct <= 0.15
bullMarubozu = cX > oX and bodyPct >= 0.75 and upperWickPct <= 0.12 and lowerWickPct <= 0.12
bearMarubozu = cX < oX and bodyPct >= 0.75 and upperWickPct <= 0.12 and lowerWickPct <= 0.12
hammer = lowerWick >= body * 2.0 and upperWick <= body * 0.75 and cX > lX + candleRange * 0.55
shootingStar = upperWick >= body * 2.0 and lowerWick <= body * 0.75 and cX < lX + candleRange * 0.45

bullResistanceBreak = cX > sellZoneHigh and cX[1] <= sellZoneHigh[1] and bodyBullOK
bearSupportBreak = cX < buyZoneLow and cX[1] >= buyZoneLow[1] and bodyBearOK
barsSinceBullResistanceBreak = ta.barssince(bullResistanceBreak)
barsSinceBearSupportBreak = ta.barssince(bearSupportBreak)
bullTrap = not na(barsSinceBullResistanceBreak) and barsSinceBullResistanceBreak > 0 and barsSinceBullResistanceBreak <= patternTrapBars and cX < sellZoneLow and cX < oX
bearTrap = not na(barsSinceBearSupportBreak) and barsSinceBearSupportBreak > 0 and barsSinceBearSupportBreak <= patternTrapBars and cX > buyZoneHigh and cX > oX

bullImpulse = cX[flagLookback] < cX and (cX - cX[flagLookback]) > atrX * 1.5
bearImpulse = cX[flagLookback] > cX and (cX[flagLookback] - cX) > atrX * 1.5
pullbackHigh = ta.highest(hX, flagLookback)[1]
pullbackLow = ta.lowest(lX, flagLookback)[1]
bullFlag = bullImpulse and cX > pullbackHigh and cX > fastX and fastX > slowX and bodyBullOK
bearFlag = bearImpulse and cX < pullbackLow and cX < fastX and fastX < slowX and bodyBearOK

doubleTop = math.abs(hX - highPrevX) <= atrX * doublePatternToleranceAtr and cX < oX and cX < fastX and recentSellZoneTouch
doubleBottom = math.abs(lX - lowPrevX) <= atrX * doublePatternToleranceAtr and cX > oX and cX > fastX and recentBuyZoneTouch
normalBullStructureBreak = cX > highPrevX and bodyBullOK
normalBearStructureBreak = cX < lowPrevX and bodyBearOK

patternName = "No Active Pattern"
patternDir = 0
patternScore = 0
patternBias = "Neutral"
forecastBias = "Neutral"
patternForecastBoost = 0.0

if normalBullStructureBreak
    patternName := "Bull Structure Break"
    patternDir := 1
    patternScore := 6
    patternBias := "BUY"
    forecastBias := "Bull"
    patternForecastBoost := 0.10
if normalBearStructureBreak
    patternName := "Bear Structure Break"
    patternDir := -1
    patternScore := 6
    patternBias := "SELL"
    forecastBias := "Bear"
    patternForecastBoost := -0.10
if doji and recentBuyZoneTouch
    patternName := "Doji at Support"
    patternDir := 1
    patternScore := 5
    patternBias := "BUY WATCH"
    forecastBias := "Bull Watch"
    patternForecastBoost := 0.05
else if doji and recentSellZoneTouch
    patternName := "Doji at Resistance"
    patternDir := -1
    patternScore := 5
    patternBias := "SELL WATCH"
    forecastBias := "Bear Watch"
    patternForecastBoost := -0.05
else if doji and (bullConf >= 70 or bearConf >= 70)
    patternName := "Doji Exhaustion Warning"
    patternDir := 0
    patternScore := 4
    patternBias := "REVERSAL WATCH"
    forecastBias := "Flatten"
    patternForecastBoost := 0.0
if hammer and recentBuyZoneTouch
    patternName := "Hammer at Support"
    patternDir := 1
    patternScore := 8
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.18
if shootingStar and recentSellZoneTouch
    patternName := "Shooting Star at Resistance"
    patternDir := -1
    patternScore := 8
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.18
if doubleBottom
    patternName := "Double Bottom"
    patternDir := 1
    patternScore := cX > highPrevX ? 9 : 7
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.22
if doubleTop
    patternName := "Double Top"
    patternDir := -1
    patternScore := cX < lowPrevX ? 9 : 7
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.22
if bullFlag
    patternName := "Bull Flag Breakout"
    patternDir := 1
    patternScore := buyPostRetest ? 9 : 8
    patternBias := "BUY"
    forecastBias := "Bull Continuation"
    patternForecastBoost := 0.25
if bearFlag
    patternName := "Bear Flag Breakdown"
    patternDir := -1
    patternScore := sellPostRetest ? 9 : 8
    patternBias := "SELL"
    forecastBias := "Bear Continuation"
    patternForecastBoost := -0.25
if bullEngulf
    patternName := recentBuyZoneTouch ? "Bullish Engulfing at Support" : "Bullish Engulfing"
    patternDir := 1
    patternScore := buyPostRetest ? 9 : recentBuyZoneTouch ? 8 : 6
    patternBias := "BUY"
    forecastBias := recentBuyZoneTouch ? "Bull Reversal" : "Bull"
    patternForecastBoost := recentBuyZoneTouch ? 0.25 : 0.15
if bearEngulf
    patternName := recentSellZoneTouch ? "Bearish Engulfing at Resistance" : "Bearish Engulfing"
    patternDir := -1
    patternScore := sellPostRetest ? 9 : recentSellZoneTouch ? 8 : 6
    patternBias := "SELL"
    forecastBias := recentSellZoneTouch ? "Bear Reversal" : "Bear"
    patternForecastBoost := recentSellZoneTouch ? -0.25 : -0.15
if bullMarubozu
    patternName := buyPostRetest ? "Bull Marubozu Post-Retest" : recentBuyZoneTouch ? "Bull Marubozu at Support" : "Bull Marubozu"
    patternDir := 1
    patternScore := mtfBullOK and frRibbonBull ? 10 : buyPostRetest ? 9 : 7
    patternBias := patternScore >= 9 ? "STRONG BUY" : "BUY"
    forecastBias := patternScore >= 9 ? "Strong Bull" : "Bull"
    patternForecastBoost := patternScore >= 9 ? 0.35 : 0.22
if bearMarubozu
    patternName := sellPostRetest ? "Bear Marubozu Post-Retest" : recentSellZoneTouch ? "Bear Marubozu at Resistance" : "Bear Marubozu"
    patternDir := -1
    patternScore := mtfBearOK and frRibbonBear ? 10 : sellPostRetest ? 9 : 7
    patternBias := patternScore >= 9 ? "STRONG SELL" : "SELL"
    forecastBias := patternScore >= 9 ? "Strong Bear" : "Bear"
    patternForecastBoost := patternScore >= 9 ? -0.35 : -0.22
if bearTrap
    patternName := "Bear Trap Reversal"
    patternDir := 1
    patternScore := 9
    patternBias := "BUY"
    forecastBias := "Bull Reversal"
    patternForecastBoost := 0.32
if bullTrap
    patternName := "Bull Trap Reversal"
    patternDir := -1
    patternScore := 9
    patternBias := "SELL"
    forecastBias := "Bear Reversal"
    patternForecastBoost := -0.32
if buyPostRetest
    patternName := "Breakout Retest BUY"
    patternDir := 1
    patternScore := 10
    patternBias := "STRONG BUY"
    forecastBias := "Strong Bull"
    patternForecastBoost := 0.40
if sellPostRetest
    patternName := "Breakout Retest SELL"
    patternDir := -1
    patternScore := 10
    patternBias := "STRONG SELL"
    forecastBias := "Strong Bear"
    patternForecastBoost := -0.40

patternBuyCompatible = not usePatternCompatibilityGate or patternDir >= 0 or patternScore < 7
patternSellCompatible = not usePatternCompatibilityGate or patternDir <= 0 or patternScore < 7
patternLabelText = patternName + "\n" + patternBias + " " + str.tostring(patternScore) + "/10"
patternLabelColor = patternDir == 1 ? color.new(color.green, 0) : patternDir == -1 ? color.new(color.red, 0) : color.new(color.orange, 0)
patternLabelStyle = patternDir == -1 ? label.style_label_down : label.style_label_up
patternWantsZoneAnchor = patternAnchorOpt == "Support/Resistance Zone" or (patternAnchorOpt == "Auto" and patternScore >= 8 and patternDir != 0)
patternZonePrice = patternDir == 1 ? buyZoneHigh : patternDir == -1 ? sellZoneLow : na
patternCanUseZoneAnchor = patternWantsZoneAnchor and not na(patternZonePrice)
patternAnchorY = patternCanUseZoneAnchor ? patternZonePrice : na
patternYLoc = patternCanUseZoneAnchor ? yloc.price : patternDir == -1 ? yloc.abovebar : yloc.belowbar
patternReady = showActivePatternLabel and patternScore >= minPatternLabelScore and patternName != "No Active Pattern"
patternChanged = patternReady and (patternName != patternName[1] or patternDir != patternDir[1] or patternScore != patternScore[1])
patternHistoricalPrint = showHistoricalPatternLabels and patternChanged

if patternHistoricalPrint
    label.new(bar_index, patternAnchorY, text=patternLabelText, xloc=xloc.bar_index, yloc=patternYLoc, style=patternLabelStyle, color=patternLabelColor, textcolor=color.white, size=patternSize)

var label currentPatternBadge = na
if showCurrentPatternBadge and barstate.islast
    if not na(currentPatternBadge)
        label.delete(currentPatternBadge)
    if patternReady
        currentPatternBadge := label.new(bar_index, patternAnchorY, text="ACTIVE PATTERN\n" + patternLabelText, xloc=xloc.bar_index, yloc=patternYLoc, style=patternLabelStyle, color=patternLabelColor, textcolor=color.white, size=patternSize)

//==============================
// FINAL SIGNALS
//==============================
buyBase = mtfBullOK and bullConf >= minConfidence and bullRank >= minRank and depthOK and structureBullOK and confirmBullOK and buyZoneOK and patternBuyCompatible
sellBase = mtfBearOK and bearConf >= minConfidence and bearRank >= minRank and depthOK and structureBearOK and confirmBearOK and sellZoneOK and patternSellCompatible
buyCore = buyBase and (not useFractalRibbonGate or frRibbonBull)
sellCore = sellBase and (not useFractalRibbonGate or frRibbonBear)
earlyBuy = showEarlySignals and not buyCore and bullCount >= 2 and dirM15 == 1 and dirH1 == 1 and bearCount <= 1 and bullConf >= earlyConfidence and bullRank >= minRank and frRibbonBull and confirmBullOK and buyZoneOK and patternBuyCompatible
earlySell = showEarlySignals and not sellCore and bearCount >= 2 and dirM15 == -1 and dirH1 == -1 and bullCount <= 1 and bearConf >= earlyConfidence and bearRank >= minRank and frRibbonBear and confirmBearOK and sellZoneOK and patternSellCompatible
strongBuy = showStrongSignals and buyCore and bullConf >= strongConfidence and bullRank >= strongRank and bullCount >= mtfRequired and frRibbonBull and (not strongRequiresRetest or buyPostRetest)
strongSell = showStrongSignals and sellCore and bearConf >= strongConfidence and bearRank >= strongRank and bearCount >= mtfRequired and frRibbonBear and (not strongRequiresRetest or sellPostRetest)
normalBuy = showNormalSignals and buyCore and not strongBuy
normalSell = showNormalSignals and sellCore and not strongSell

//==============================
// REPEAT CONTROL
//==============================
var int lastSignalDir = 0
var int lastSignalStrength = -1
var int lastBuyBar = na
var int lastSellBar = na
var label lastSignalLabel = na

buyCooldownOK = na(lastBuyBar) or bar_index - lastBuyBar >= cooldownBars
sellCooldownOK = na(lastSellBar) or bar_index - lastSellBar >= cooldownBars
allowEarlyBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 0) and buyCooldownOK
allowNormalBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 1) and (buyCooldownOK or lastSignalStrength < 1)
allowStrongBuy = (not oneSignalPerTrend or lastSignalDir != 1 or lastSignalStrength < 2) and (buyCooldownOK or lastSignalStrength < 2)
allowEarlySell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 0) and sellCooldownOK
allowNormalSell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 1) and (sellCooldownOK or lastSignalStrength < 1)
allowStrongSell = (not oneSignalPerTrend or lastSignalDir != -1 or lastSignalStrength < 2) and (sellCooldownOK or lastSignalStrength < 2)

earlyBuySignal = earlyBuy and not earlyBuy[1] and allowEarlyBuy
buySignal = normalBuy and not normalBuy[1] and allowNormalBuy
strongBuySignal = strongBuy and not strongBuy[1] and allowStrongBuy
earlySellSignal = earlySell and not earlySell[1] and allowEarlySell
sellSignal = normalSell and not normalSell[1] and allowNormalSell
strongSellSignal = strongSell and not strongSell[1] and allowStrongSell

//==============================
// CANDLE SCORE LABELS
//==============================
scoreColor = candleDir == 1 ? color.new(color.green, 0) : color.new(color.red, 0)
scoreAbove = scoreLocationOpt == "Above Candle" or (scoreLocationOpt == "Auto" and candleDir == -1)

buyText = signalDetailOpt == "Arrow Only" ? "▲" : signalDetailOpt == "Compact" ? "Buy " + str.tostring(bullConf) : "BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
sellText = signalDetailOpt == "Arrow Only" ? "▼" : signalDetailOpt == "Compact" ? "Sell " + str.tostring(bearConf) : "SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)
earlyBuyText = signalDetailOpt == "Arrow Only" ? "△" : signalDetailOpt == "Compact" ? "Early Buy " + str.tostring(bullConf) : "EARLY BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
earlySellText = signalDetailOpt == "Arrow Only" ? "▽" : signalDetailOpt == "Compact" ? "Early Sell " + str.tostring(bearConf) : "EARLY SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)
strongBuyText = signalDetailOpt == "Arrow Only" ? "▲" : signalDetailOpt == "Compact" ? "Strong Buy " + str.tostring(bullConf) : "STRONG BUY\nConf " + str.tostring(bullConf) + "\nRank " + str.tostring(bullRank)
strongSellText = signalDetailOpt == "Arrow Only" ? "▼" : signalDetailOpt == "Compact" ? "Strong Sell " + str.tostring(bearConf) : "STRONG SELL\nConf " + str.tostring(bearConf) + "\nRank " + str.tostring(bearRank)

bullSignalStrength = strongBuySignal ? 2 : buySignal ? 1 : earlyBuySignal ? 0 : -1
bearSignalStrength = strongSellSignal ? 2 : sellSignal ? 1 : earlySellSignal ? 0 : -1
hasBullSignal = bullSignalStrength >= 0
hasBearSignal = bearSignalStrength >= 0
printBullSignal = false
printBearSignal = false

if hasBullSignal and not hasBearSignal
    printBullSignal := true
else if hasBearSignal and not hasBullSignal
    printBearSignal := true
else if hasBullSignal and hasBearSignal
    if bullSignalStrength > bearSignalStrength
        printBullSignal := true
    else if bearSignalStrength > bullSignalStrength
        printBearSignal := true
    else
        printBullSignal := bullConf >= bearConf
        printBearSignal := bearConf > bullConf

hasAnySignalThisBar = printBullSignal or printBearSignal
if showCandleScores and not hasAnySignalThisBar and bar_index % scoreEveryBars == 0
    label.new(bar_index, na, text=candleScoreText, xloc=xloc.bar_index, yloc=scoreAbove ? yloc.abovebar : yloc.belowbar, style=label.style_none, textcolor=scoreColor, size=scoreSize)

useBuyZoneAnchor = signalAnchorOpt == "Support/Resistance Zone" or (signalAnchorOpt == "Auto" and (buyZoneExit or buyPostRetest))
useSellZoneAnchor = signalAnchorOpt == "Support/Resistance Zone" or (signalAnchorOpt == "Auto" and (sellZoneExit or sellPostRetest))
buyAnchorY = useBuyZoneAnchor ? buyZoneHigh : na
sellAnchorY = useSellZoneAnchor ? sellZoneLow : na
buyAnchorLoc = useBuyZoneAnchor ? yloc.price : yloc.belowbar
sellAnchorLoc = useSellZoneAnchor ? yloc.price : yloc.abovebar

if printBullSignal
    if not showHistorical and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    txt = bullSignalStrength == 2 ? strongBuyText : bullSignalStrength == 1 ? buyText : earlyBuyText
    col = bullSignalStrength == 2 ? color.new(color.green, 0) : bullSignalStrength == 1 ? color.new(color.green, 15) : color.new(color.teal, 20)
    lastSignalLabel := label.new(bar_index, buyAnchorY, text=txt, xloc=xloc.bar_index, yloc=buyAnchorLoc, style=label.style_label_up, color=col, textcolor=color.white, size=sigSize)
    lastSignalDir := 1
    lastSignalStrength := bullSignalStrength
    lastBuyBar := bar_index

if printBearSignal
    if not showHistorical and not na(lastSignalLabel)
        label.delete(lastSignalLabel)
    txt = bearSignalStrength == 2 ? strongSellText : bearSignalStrength == 1 ? sellText : earlySellText
    col = bearSignalStrength == 2 ? color.new(color.red, 0) : bearSignalStrength == 1 ? color.new(color.red, 15) : color.new(color.orange, 20)
    lastSignalLabel := label.new(bar_index, sellAnchorY, text=txt, xloc=xloc.bar_index, yloc=sellAnchorLoc, style=label.style_label_down, color=col, textcolor=color.white, size=sigSize)
    lastSignalDir := -1
    lastSignalStrength := bearSignalStrength
    lastSellBar := bar_index

if ribbonNeutral
    lastSignalStrength := -1

//==============================
// ALIGNED ACTIVE SENTIMENT
//==============================
patternBullReversal = patternDir == 1 and (str.contains(patternName, "Reversal") or str.contains(patternName, "Doji") or str.contains(patternName, "Hammer") or str.contains(patternName, "Double Bottom") or str.contains(patternName, "Trap"))
patternBearReversal = patternDir == -1 and (str.contains(patternName, "Reversal") or str.contains(patternName, "Doji") or str.contains(patternName, "Shooting Star") or str.contains(patternName, "Double Top") or str.contains(patternName, "Trap"))
patternBullContinuation = patternDir == 1 and not patternBullReversal
patternBearContinuation = patternDir == -1 and not patternBearReversal
bullBreakoutEvent = bullResistanceBreak or str.contains(patternName, "Bull Flag Breakout") or patternName == "Breakout Retest BUY"
bearBreakdownEvent = bearSupportBreak or str.contains(patternName, "Bear Flag Breakdown") or patternName == "Breakout Retest SELL"
bullBreakoutRetest = patternName == "Breakout Retest BUY" or (buyPostRetest and bullBreakoutEvent)
bearBreakdownRetest = patternName == "Breakout Retest SELL" or (sellPostRetest and bearBreakdownEvent)

bullSentimentScore = 0
bullSentimentScore += zoneBullEvent ? 2 : 0
bullSentimentScore += bullBreakoutEvent ? 2 : 0
bullSentimentScore += buyPostRetest or bullBreakoutRetest ? 1 : 0
bullSentimentScore += patternDir == 1 and patternScore >= minPatternLabelScore ? 2 : 0
bullSentimentScore += patternBullReversal ? 1 : 0
bullSentimentScore += patternBullContinuation ? 1 : 0
bullSentimentScore += bullConf > bearConf ? 1 : 0
bullSentimentScore += bullCount > bearCount ? 1 : 0
bullSentimentScore += ribbonBull ? 1 : 0
bullSentimentScore += frRibbonBull ? 1 : 0
bullSentimentScore += strongBuy or buyCore or earlyBuy ? 2 : 0

bearSentimentScore = 0
bearSentimentScore += zoneBearEvent ? 2 : 0
bearSentimentScore += bearBreakdownEvent ? 2 : 0
bearSentimentScore += sellPostRetest or bearBreakdownRetest ? 1 : 0
bearSentimentScore += patternDir == -1 and patternScore >= minPatternLabelScore ? 2 : 0
bearSentimentScore += patternBearReversal ? 1 : 0
bearSentimentScore += patternBearContinuation ? 1 : 0
bearSentimentScore += bearConf > bullConf ? 1 : 0
bearSentimentScore += bearCount > bullCount ? 1 : 0
bearSentimentScore += ribbonBear ? 1 : 0
bearSentimentScore += frRibbonBear ? 1 : 0
bearSentimentScore += strongSell or sellCore or earlySell ? 2 : 0

bullSentimentQualified = bullSentimentScore >= 4 and bullSentimentScore > bearSentimentScore + 1
bearSentimentQualified = bearSentimentScore >= 4 and bearSentimentScore > bullSentimentScore + 1
activeSentimentDir := bullSentimentQualified ? 1 : bearSentimentQualified ? -1 : 0

activeSentimentText := activeSentimentDir == 1 ? bullBreakoutRetest ? "BUY BREAKOUT RETEST" : bullResistanceBreak ? "BUY BREAKOUT ABOVE RESISTANCE" : buyPostRetest and patternBullReversal ? "BUY REVERSAL POST-RETEST" : buyPostRetest ? "BUY POST-RETEST" : buyZoneExit and patternBullReversal ? "BUY REVERSAL FROM SUPPORT" : buyZoneExit ? "BUY FROM SUPPORT" : patternBullReversal ? "BULL REVERSAL WATCH" : patternBullContinuation ? "BULL CONTINUATION" : strongBuy ? "STRONG BUY SENTIMENT" : buyCore ? "BUY SENTIMENT ACTIVE" : earlyBuy ? "EARLY BUY SENTIMENT" : "BULL SENTIMENT ACTIVE" : activeSentimentDir == -1 ? bearBreakdownRetest ? "SELL BREAKDOWN RETEST" : bearSupportBreak ? "SELL BREAKDOWN BELOW SUPPORT" : sellPostRetest and patternBearReversal ? "SELL REVERSAL POST-RETEST" : sellPostRetest ? "SELL POST-RETEST" : sellZoneExit and patternBearReversal ? "SELL REVERSAL FROM RESISTANCE" : sellZoneExit ? "SELL FROM RESISTANCE" : patternBearReversal ? "BEAR REVERSAL WATCH" : patternBearContinuation ? "BEAR CONTINUATION" : strongSell ? "STRONG SELL SENTIMENT" : sellCore ? "SELL SENTIMENT ACTIVE" : earlySell ? "EARLY SELL SENTIMENT" : "BEAR SENTIMENT ACTIVE" : requireZoneExit ? "WAITING FOR ALIGNED SENTIMENT" : "SENTIMENT FILTER OFF"
activeSentimentColor := activeSentimentDir == 1 ? color.new(color.green, 0) : activeSentimentDir == -1 ? color.new(color.red, 0) : color.new(color.gray, 35)
activeBuySentimentStart := activeSentimentDir == 1 and activeSentimentDir[1] != 1
activeSellSentimentStart := activeSentimentDir == -1 and activeSentimentDir[1] != -1

//==============================
// PROJECTED NEXT-CANDLE RIBBON
// This replaces the old raw ribbon dots.
// The bottom ribbon now grades the NEXT candle bias after the full engine has
// considered support/resistance zones, breakout/retest behavior, major chart
// patterns, MTF alignment, confidence, fractal ribbon, and active sentiment.
// Color key with no text on the chart:
//   Green  = strong projected bullish candle
//   Blue   = bullish projected candle / buy watch
//   Gray   = neutral or mixed projection
//   Orange = bearish projected candle / sell watch
//   Red    = strong projected bearish candle
//==============================
nextBullProjectionScore = 0
nextBullProjectionScore += activeSentimentDir == 1 ? 5 : 0
nextBullProjectionScore += zoneBullEvent ? 2 : 0
nextBullProjectionScore += buyZoneExit ? 1 : 0
nextBullProjectionScore += buyPostRetest ? 2 : 0
nextBullProjectionScore += bullBreakoutEvent ? 2 : 0
nextBullProjectionScore += bullBreakoutRetest ? 2 : 0
nextBullProjectionScore += patternDir == 1 ? patternScore >= 8 ? 3 : 2 : 0
nextBullProjectionScore += patternBullReversal ? 2 : 0
nextBullProjectionScore += patternBullContinuation ? 1 : 0
nextBullProjectionScore += mtfBullOK ? 2 : 0
nextBullProjectionScore += bullCount > bearCount ? 1 : 0
nextBullProjectionScore += bullConf > bearConf ? 1 : 0
nextBullProjectionScore += frRibbonBull ? 1 : 0
nextBullProjectionScore += ribbonBull ? 1 : 0
nextBullProjectionScore += strongBuy ? 3 : buyCore ? 2 : earlyBuy ? 1 : 0

nextBearProjectionScore = 0
nextBearProjectionScore += activeSentimentDir == -1 ? 5 : 0
nextBearProjectionScore += zoneBearEvent ? 2 : 0
nextBearProjectionScore += sellZoneExit ? 1 : 0
nextBearProjectionScore += sellPostRetest ? 2 : 0
nextBearProjectionScore += bearBreakdownEvent ? 2 : 0
nextBearProjectionScore += bearBreakdownRetest ? 2 : 0
nextBearProjectionScore += patternDir == -1 ? patternScore >= 8 ? 3 : 2 : 0
nextBearProjectionScore += patternBearReversal ? 2 : 0
nextBearProjectionScore += patternBearContinuation ? 1 : 0
nextBearProjectionScore += mtfBearOK ? 2 : 0
nextBearProjectionScore += bearCount > bullCount ? 1 : 0
nextBearProjectionScore += bearConf > bullConf ? 1 : 0
nextBearProjectionScore += frRibbonBear ? 1 : 0
nextBearProjectionScore += ribbonBear ? 1 : 0
nextBearProjectionScore += strongSell ? 3 : sellCore ? 2 : earlySell ? 1 : 0

projectionGap = nextBullProjectionScore - nextBearProjectionScore
projectedNextCode = projectionGap >= 6 ? 2 : projectionGap >= 2 ? 1 : projectionGap <= -6 ? -2 : projectionGap <= -2 ? -1 : 0
projectedNextText = projectedNextCode == 2 ? "STRONG BULL NEXT" : projectedNextCode == 1 ? "BULL NEXT" : projectedNextCode == -1 ? "BEAR NEXT" : projectedNextCode == -2 ? "STRONG BEAR NEXT" : "NEUTRAL NEXT"
projectedRibbonColor = projectedNextCode == 2 ? color.new(color.green, 0) : projectedNextCode == 1 ? color.new(color.blue, 0) : projectedNextCode == -1 ? color.new(color.orange, 0) : projectedNextCode == -2 ? color.new(color.red, 0) : color.new(color.gray, 55)

// One clean plot only. display.pane keeps the indicator-name/status area from
// filling with extra plot numbers.
plotshape(showRibbonMarks ? true : false, title="MWCI Next Candle Projection", style=shape.square, location=location.bottom, color=projectedRibbonColor, size=size.tiny, display=display.pane)

//==============================
// DASHBOARD TEXT
//==============================
m15Text = dirM15 == 1 ? "BULL" : dirM15 == -1 ? "BEAR" : "NEUTRAL"
h1Text  = dirH1 == 1 ? "BULL" : dirH1 == -1 ? "BEAR" : "NEUTRAL"
h4Text  = dirH4 == 1 ? "BULL" : dirH4 == -1 ? "BEAR" : "NEUTRAL"
d1Text  = dirD1 == 1 ? "BULL" : dirD1 == -1 ? "BEAR" : "NEUTRAL"
w1Text  = dirW1 == 1 ? "BULL" : dirW1 == -1 ? "BEAR" : "NEUTRAL"
mn1Text = dirMN1 == 1 ? "BULL" : dirMN1 == -1 ? "BEAR" : "NEUTRAL"
m15Color = dirM15 == 1 ? color.new(color.green, 0) : dirM15 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
h1Color  = dirH1 == 1 ? color.new(color.green, 0) : dirH1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
h4Color  = dirH4 == 1 ? color.new(color.green, 0) : dirH4 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
d1Color  = dirD1 == 1 ? color.new(color.green, 0) : dirD1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
w1Color  = dirW1 == 1 ? color.new(color.green, 0) : dirW1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)
mn1Color = dirMN1 == 1 ? color.new(color.green, 0) : dirMN1 == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)

statusText = "WAIT"
if strongBuy
    statusText := "STRONG BUY"
else if strongSell
    statusText := "STRONG SELL"
else if buyCore
    statusText := "BUY PASSED"
else if sellCore
    statusText := "SELL PASSED"
else if earlyBuy
    statusText := "EARLY BUY"
else if earlySell
    statusText := "EARLY SELL"
else if not (mtfBullOK or mtfBearOK)
    statusText := "WAIT: MTF failed need " + str.tostring(mtfRequired) + " | B=" + str.tostring(bullCount) + " S=" + str.tostring(bearCount)
else if requireZoneExit and mtfBullOK and not buyZoneOK
    statusText := "WAIT: Buy needs clean move from support zone"
else if requireZoneExit and mtfBearOK and not sellZoneOK
    statusText := "WAIT: Sell needs clean move from resistance zone"
else if mtfBullOK and not patternBuyCompatible
    statusText := "WAIT: Opposite pattern - " + patternName
else if mtfBearOK and not patternSellCompatible
    statusText := "WAIT: Opposite pattern - " + patternName
else if strongRequiresRetest and buyCore and bullConf >= strongConfidence and bullRank >= strongRank and not buyPostRetest
    statusText := "BUY PASSED: waiting post-retest for STRONG"
else if strongRequiresRetest and sellCore and bearConf >= strongConfidence and bearRank >= strongRank and not sellPostRetest
    statusText := "SELL PASSED: waiting post-retest for STRONG"
else if useFractalRibbonGate and mtfBullOK and not frRibbonBull
    statusText := "WAIT: Bull fractal ribbon not confirmed"
else if useFractalRibbonGate and mtfBearOK and not frRibbonBear
    statusText := "WAIT: Bear fractal ribbon not confirmed"
else if mtfBullOK and bullConf < minConfidence
    statusText := "WAIT: Bull confidence " + str.tostring(bullConf)
else if mtfBearOK and bearConf < minConfidence
    statusText := "WAIT: Bear confidence " + str.tostring(bearConf)
else if mtfBullOK and bullRank < minRank
    statusText := "WAIT: Bull rank " + str.tostring(bullRank)
else if mtfBearOK and bearRank < minRank
    statusText := "WAIT: Bear rank " + str.tostring(bearRank)
else if not depthOK
    statusText := "WAIT: Retrace/depth failed"
else if mtfBullOK and not structureBullOK
    statusText := "WAIT: Bull structure failed"
else if mtfBearOK and not structureBearOK
    statusText := "WAIT: Bear structure failed"
else if requireConfirmBody and mtfBullOK and not confirmBullOK
    statusText := "WAIT: Bull candle not confirmed"
else if requireConfirmBody and mtfBearOK and not confirmBearOK
    statusText := "WAIT: Bear candle not confirmed"

//==============================
// TRADE PLAN
//==============================
activePlanDir = strongBuy or buyCore or earlyBuy ? 1 : strongSell or sellCore or earlySell ? -1 : activeSentimentDir
activePlanName = strongBuy ? "STRONG BUY" : buyCore ? "BUY" : earlyBuy ? "EARLY BUY" : strongSell ? "STRONG SELL" : sellCore ? "SELL" : earlySell ? "EARLY SELL" : activeSentimentDir == 1 ? "BUY SETUP" : activeSentimentDir == -1 ? "SELL SETUP" : "WAIT"
planIsBuy = activePlanDir == 1
planIsSell = activePlanDir == -1

buyEntryLow = buyZoneHigh
buyEntryHigh = buyZoneHigh + atrX * entryBandAtr
buyEntryMid = (buyEntryLow + buyEntryHigh) / 2.0
buySL = buyZoneLow - atrX * slBufferAtr
buyRisk = math.max(buyEntryMid - buySL, syminfo.mintick)
buyTP1 = buyEntryMid + buyRisk * tp1RR
buyTP2 = buyEntryMid + buyRisk * tp2RR
sellEntryHigh = sellZoneLow
sellEntryLow = sellZoneLow - atrX * entryBandAtr
sellEntryMid = (sellEntryLow + sellEntryHigh) / 2.0
sellSL = sellZoneHigh + atrX * slBufferAtr
sellRisk = math.max(sellSL - sellEntryMid, syminfo.mintick)
sellTP1 = sellEntryMid - sellRisk * tp1RR
sellTP2 = sellEntryMid - sellRisk * tp2RR

planEntryLow = planIsBuy ? buyEntryLow : planIsSell ? sellEntryLow : na
planEntryHigh = planIsBuy ? buyEntryHigh : planIsSell ? sellEntryHigh : na
planSL = planIsBuy ? buySL : planIsSell ? sellSL : na
planTP1 = planIsBuy ? buyTP1 : planIsSell ? sellTP1 : na
planTP2 = planIsBuy ? buyTP2 : planIsSell ? sellTP2 : na

//==============================
// FORECAST
//==============================
baseForecastPressure = (bullConf - bearConf) / 100.0
forecastPressure = math.max(-1.0, math.min(1.0, baseForecastPressure + patternForecastBoost))
forecastDir = activePlanDir != 0 ? activePlanDir : activeSentimentDir != 0 ? activeSentimentDir : patternDir != 0 and patternScore >= 7 ? patternDir : bullConf > bearConf ? 1 : bearConf > bullConf ? -1 : 0
forecastAllowed = showFutureForecast and (not forecastOnlyActive or activePlanDir != 0 or activeSentimentDir != 0)
lrNow = ta.linreg(close, forecastLookback, 0)
lrPrev = ta.linreg(close, forecastLookback, 1)
slopeMove = (lrNow - lrPrev) * forecastBars
forecastBaseMove = slopeMove + ta.atr(atrLen) * forecastAtrMult * forecastPressure
forecastEndRaw = close + forecastBaseMove
forecastEndUncapped = forecastDir == 1 ? math.max(forecastEndRaw, close + ta.atr(atrLen) * 0.10) : forecastDir == -1 ? math.min(forecastEndRaw, close - ta.atr(atrLen) * 0.10) : na

[h1Res, h1Sup] = request.security(syminfo.tickerid, "60", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[h4Res, h4Sup] = request.security(syminfo.tickerid, "240", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[d1Res, d1Sup] = request.security(syminfo.tickerid, "D", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[w1Res, w1Sup] = request.security(syminfo.tickerid, "W", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)
[mnRes, mnSup] = request.security(syminfo.tickerid, "M", [ta.highest(high, forecastSRLookback)[1], ta.lowest(low, forecastSRLookback)[1]], barmerge.gaps_off, barmerge.lookahead_off)

nearestRes = na(h1Res) or h1Res <= close ? na : h1Res
nearestRes := not na(h4Res) and h4Res > close and (na(nearestRes) or h4Res < nearestRes) ? h4Res : nearestRes
nearestRes := not na(d1Res) and d1Res > close and (na(nearestRes) or d1Res < nearestRes) ? d1Res : nearestRes
nearestRes := not na(w1Res) and w1Res > close and (na(nearestRes) or w1Res < nearestRes) ? w1Res : nearestRes
nearestRes := not na(mnRes) and mnRes > close and (na(nearestRes) or mnRes < nearestRes) ? mnRes : nearestRes
nearestSup = na(h1Sup) or h1Sup >= close ? na : h1Sup
nearestSup := not na(h4Sup) and h4Sup < close and (na(nearestSup) or h4Sup > nearestSup) ? h4Sup : nearestSup
nearestSup := not na(d1Sup) and d1Sup < close and (na(nearestSup) or d1Sup > nearestSup) ? d1Sup : nearestSup
nearestSup := not na(w1Sup) and w1Sup < close and (na(nearestSup) or w1Sup > nearestSup) ? w1Sup : nearestSup
nearestSup := not na(mnSup) and mnSup < close and (na(nearestSup) or mnSup > nearestSup) ? mnSup : nearestSup

srBuffer = ta.atr(atrLen) * forecastSRBufferAtr
buyCap = not na(nearestRes) ? math.max(close + syminfo.mintick, nearestRes - srBuffer) : na
sellCap = not na(nearestSup) ? math.min(close - syminfo.mintick, nearestSup + srBuffer) : na
forecastEndCapped = forecastRespectMTFSR and forecastDir == 1 and not na(buyCap) ? math.min(forecastEndUncapped, buyCap) : forecastRespectMTFSR and forecastDir == -1 and not na(sellCap) ? math.max(forecastEndUncapped, sellCap) : forecastEndUncapped
minVisibleMove = ta.atr(atrLen) * forecastVisualMinAtr
forecastEndVisible = forecastDir == 1 and math.abs(forecastEndCapped - close) < minVisibleMove ? close + minVisibleMove : forecastDir == -1 and math.abs(forecastEndCapped - close) < minVisibleMove ? close - minVisibleMove : forecastEndCapped
forecastEnd = forecastEndVisible
forecastCapText = forecastRespectMTFSR and forecastDir == 1 and not na(nearestRes) ? "MTF resistance cap " + str.tostring(nearestRes, format.mintick) : forecastRespectMTFSR and forecastDir == -1 and not na(nearestSup) ? "MTF support cap " + str.tostring(nearestSup, format.mintick) : "No MTF cap"
forecastText = forecastDir == 1 ? "10C BUY Forecast" : forecastDir == -1 ? "10C SELL Forecast" : "10C WAIT Forecast"
forecastColor = forecastDir == 1 ? color.new(color.green, 0) : forecastDir == -1 ? color.new(color.red, 0) : color.new(color.gray, 35)
showForecastLine = forecastStyleOpt == "Line" or forecastStyleOpt == "Both"
showForecastCandleBodies = forecastStyleOpt == "Candles" or forecastStyleOpt == "Both"

var line forecastLine = na
var line forecastRailTop = na
var line forecastRailBottom = na
var label forecastStartLabel = na
var label forecastLabel = na
var box[] forecastBodyBoxes = array.new_box()
var line[] forecastWickLines = array.new_line()

f_clearForecastCandles() =>
    bodyCount = array.size(forecastBodyBoxes)
    if bodyCount > 0
        for i = 0 to bodyCount - 1
            box.delete(array.get(forecastBodyBoxes, i))
        array.clear(forecastBodyBoxes)
    wickCount = array.size(forecastWickLines)
    if wickCount > 0
        for i = 0 to wickCount - 1
            line.delete(array.get(forecastWickLines, i))
        array.clear(forecastWickLines)

if barstate.islast
    if not na(forecastLine)
        line.delete(forecastLine)
    if not na(forecastRailTop)
        line.delete(forecastRailTop)
    if not na(forecastRailBottom)
        line.delete(forecastRailBottom)
    if not na(forecastStartLabel)
        label.delete(forecastStartLabel)
    if not na(forecastLabel)
        label.delete(forecastLabel)
    f_clearForecastCandles()
    if forecastAllowed and forecastDir != 0 and not na(forecastEnd)
        if forecastDrawRail
            railPad = ta.atr(atrLen) * math.max(forecastCandleWickAtr, 0.15)
            railTop = math.max(close, forecastEnd) + railPad
            railBottom = math.min(close, forecastEnd) - railPad
            forecastRailTop := line.new(bar_index, railTop, bar_index + forecastBars, railTop, xloc=xloc.bar_index, extend=extend.none, color=color.new(forecastColor, 20), style=line.style_dotted, width=1)
            forecastRailBottom := line.new(bar_index, railBottom, bar_index + forecastBars, railBottom, xloc=xloc.bar_index, extend=extend.none, color=color.new(forecastColor, 20), style=line.style_dotted, width=1)
        forecastStartLabel := label.new(bar_index, close, text="FORECAST START", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(forecastColor, 0), textcolor=color.white, size=size.tiny)
        if showForecastLine
            forecastLine := line.new(bar_index, close, bar_index + forecastBars, forecastEnd, xloc=xloc.bar_index, extend=extend.none, color=forecastColor, style=line.style_dashed, width=2)
        if showForecastCandleBodies
            stepMove = (forecastEnd - close) / forecastBars
            baseWick = ta.atr(atrLen) * forecastCandleWickAtr
            minBody = ta.atr(atrLen) * forecastCandleBodyMin
            prevClose = close
            for i = 1 to forecastBars
                x = bar_index + i
                projectedClose = close + stepMove * i
                projectedOpen = prevClose
                if math.abs(projectedClose - projectedOpen) < minBody
                    projectedClose := projectedOpen + forecastDir * minBody
                candleBull = projectedClose >= projectedOpen
                bodyTop = math.max(projectedOpen, projectedClose)
                bodyBottom = math.min(projectedOpen, projectedClose)
                wickBoost = baseWick * (1.0 + (i % 3) * 0.15)
                projectedHigh = bodyTop + wickBoost
                projectedLow = bodyBottom - wickBoost
                candleColor = candleBull ? color.new(color.green, 5) : color.new(color.red, 5)
                wickColor = candleBull ? color.new(color.green, 0) : color.new(color.red, 0)
                b = box.new(left=x - 1, top=bodyTop, right=x, bottom=bodyBottom, xloc=xloc.bar_index, border_color=wickColor, bgcolor=candleColor)
                w = line.new(x, projectedHigh, x, projectedLow, xloc=xloc.bar_index, extend=extend.none, color=wickColor, style=line.style_solid, width=1)
                array.push(forecastBodyBoxes, b)
                array.push(forecastWickLines, w)
                prevClose := projectedClose
        forecastLabel := label.new(bar_index + forecastBars, forecastEnd, text=forecastText + "\n" + str.tostring(forecastEnd, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=forecastDir == 1 ? label.style_label_up : label.style_label_down, color=forecastColor, textcolor=color.white, size=size.tiny)

//==============================
// HTF S/R SHORT LINES + UNIQUE SWING TRENDLINES
//==============================
var line h4ResLine = na
var line h4SupLine = na
var line d1ResLine = na
var line d1SupLine = na
var line w1ResLine = na
var line w1SupLine = na
var line mn1ResLine = na
var line mn1SupLine = na
var line swingHighTrendLine = na
var line swingLowTrendLine = na

if barstate.islast
    srLineX1 = bar_index - 1
    srLineX2 = bar_index - 1 + htfShortLineLen
    if showHTFSRShortLines
        if na(h4ResLine)
            h4ResLine := line.new(srLineX1, h4ResClosed, srLineX2, h4ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(h4ResLine, srLineX1, h4ResClosed)
            line.set_xy2(h4ResLine, srLineX2, h4ResClosed)
            line.set_color(h4ResLine, color.new(color.red, 0))
            line.set_style(h4ResLine, line.style_solid)
            line.set_width(h4ResLine, htfShortLineWidth)
        if na(h4SupLine)
            h4SupLine := line.new(srLineX1, h4SupClosed, srLineX2, h4SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(h4SupLine, srLineX1, h4SupClosed)
            line.set_xy2(h4SupLine, srLineX2, h4SupClosed)
            line.set_color(h4SupLine, color.new(color.blue, 0))
            line.set_style(h4SupLine, line.style_solid)
            line.set_width(h4SupLine, htfShortLineWidth)
        if na(d1ResLine)
            d1ResLine := line.new(srLineX1, d1ResClosed, srLineX2, d1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(d1ResLine, srLineX1, d1ResClosed)
            line.set_xy2(d1ResLine, srLineX2, d1ResClosed)
            line.set_color(d1ResLine, color.new(color.red, 0))
            line.set_style(d1ResLine, line.style_solid)
            line.set_width(d1ResLine, htfShortLineWidth)
        if na(d1SupLine)
            d1SupLine := line.new(srLineX1, d1SupClosed, srLineX2, d1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(d1SupLine, srLineX1, d1SupClosed)
            line.set_xy2(d1SupLine, srLineX2, d1SupClosed)
            line.set_color(d1SupLine, color.new(color.blue, 0))
            line.set_style(d1SupLine, line.style_solid)
            line.set_width(d1SupLine, htfShortLineWidth)
        if na(w1ResLine)
            w1ResLine := line.new(srLineX1, w1ResClosed, srLineX2, w1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(w1ResLine, srLineX1, w1ResClosed)
            line.set_xy2(w1ResLine, srLineX2, w1ResClosed)
            line.set_color(w1ResLine, color.new(color.red, 0))
            line.set_style(w1ResLine, line.style_solid)
            line.set_width(w1ResLine, htfShortLineWidth)
        if na(w1SupLine)
            w1SupLine := line.new(srLineX1, w1SupClosed, srLineX2, w1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(w1SupLine, srLineX1, w1SupClosed)
            line.set_xy2(w1SupLine, srLineX2, w1SupClosed)
            line.set_color(w1SupLine, color.new(color.blue, 0))
            line.set_style(w1SupLine, line.style_solid)
            line.set_width(w1SupLine, htfShortLineWidth)
        if na(mn1ResLine)
            mn1ResLine := line.new(srLineX1, mn1ResClosed, srLineX2, mn1ResClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.red, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(mn1ResLine, srLineX1, mn1ResClosed)
            line.set_xy2(mn1ResLine, srLineX2, mn1ResClosed)
            line.set_color(mn1ResLine, color.new(color.red, 0))
            line.set_style(mn1ResLine, line.style_solid)
            line.set_width(mn1ResLine, htfShortLineWidth)
        if na(mn1SupLine)
            mn1SupLine := line.new(srLineX1, mn1SupClosed, srLineX2, mn1SupClosed, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.blue, 0), style=line.style_solid, width=htfShortLineWidth)
        else
            line.set_xy1(mn1SupLine, srLineX1, mn1SupClosed)
            line.set_xy2(mn1SupLine, srLineX2, mn1SupClosed)
            line.set_color(mn1SupLine, color.new(color.blue, 0))
            line.set_style(mn1SupLine, line.style_solid)
            line.set_width(mn1SupLine, htfShortLineWidth)
    else
        if not na(h4ResLine)
            line.delete(h4ResLine)
            h4ResLine := na
        if not na(h4SupLine)
            line.delete(h4SupLine)
            h4SupLine := na
        if not na(d1ResLine)
            line.delete(d1ResLine)
            d1ResLine := na
        if not na(d1SupLine)
            line.delete(d1SupLine)
            d1SupLine := na
        if not na(w1ResLine)
            line.delete(w1ResLine)
            w1ResLine := na
        if not na(w1SupLine)
            line.delete(w1SupLine)
            w1SupLine := na
        if not na(mn1ResLine)
            line.delete(mn1ResLine)
            mn1ResLine := na
        if not na(mn1SupLine)
            line.delete(mn1SupLine)
            mn1SupLine := na

    if showUniqueTrendlines
        if not na(lastSwingHigh2) and not na(lastSwingHigh1) and not na(lastSwingHighBar2) and not na(lastSwingHighBar1)
            if na(swingHighTrendLine)
                swingHighTrendLine := line.new(lastSwingHighBar2, lastSwingHigh2, lastSwingHighBar1, lastSwingHigh1, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.red, 0), style=line.style_solid, width=swingTrendWidth)
            else
                line.set_xy1(swingHighTrendLine, lastSwingHighBar2, lastSwingHigh2)
                line.set_xy2(swingHighTrendLine, lastSwingHighBar1, lastSwingHigh1)
                line.set_extend(swingHighTrendLine, extend.right)
                line.set_color(swingHighTrendLine, color.new(color.red, 0))
                line.set_style(swingHighTrendLine, line.style_solid)
                line.set_width(swingHighTrendLine, swingTrendWidth)
        if not na(lastSwingLow2) and not na(lastSwingLow1) and not na(lastSwingLowBar2) and not na(lastSwingLowBar1)
            if na(swingLowTrendLine)
                swingLowTrendLine := line.new(lastSwingLowBar2, lastSwingLow2, lastSwingLowBar1, lastSwingLow1, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.blue, 0), style=line.style_solid, width=swingTrendWidth)
            else
                line.set_xy1(swingLowTrendLine, lastSwingLowBar2, lastSwingLow2)
                line.set_xy2(swingLowTrendLine, lastSwingLowBar1, lastSwingLow1)
                line.set_extend(swingLowTrendLine, extend.right)
                line.set_color(swingLowTrendLine, color.new(color.blue, 0))
                line.set_style(swingLowTrendLine, line.style_solid)
                line.set_width(swingLowTrendLine, swingTrendWidth)
    else
        if not na(swingHighTrendLine)
            line.delete(swingHighTrendLine)
            swingHighTrendLine := na
        if not na(swingLowTrendLine)
            line.delete(swingLowTrendLine)
            swingLowTrendLine := na

//==============================
// TABLES
//==============================
planColor = planIsBuy ? color.new(color.green, 0) : planIsSell ? color.new(color.red, 0) : color.new(color.gray, 40)
planTextColor = color.white
f_priceText(v) => na(v) ? "-" : str.tostring(v, format.mintick)

var table tradePlan = table.new(position.bottom_left, 2, 9, border_width=1)
if showTradePlanPanel and barstate.islast
    table.cell(tradePlan, 0, 0, "MWCI ACTIVE SIGNAL", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=size.tiny)
    table.cell(tradePlan, 1, 0, activePlanName, text_color=planTextColor, bgcolor=planColor, text_size=size.tiny)
    table.cell(tradePlan, 0, 1, "Entry Range", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 1, f_priceText(planEntryLow) + " - " + f_priceText(planEntryHigh), text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 0, 2, "SL", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 2, f_priceText(planSL), text_color=color.white, bgcolor=color.new(color.red, 15), text_size=size.tiny)
    table.cell(tradePlan, 0, 3, "TP1", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 3, f_priceText(planTP1) + " (" + str.tostring(tp1RR) + "R)", text_color=color.white, bgcolor=color.new(color.green, 15), text_size=size.tiny)
    table.cell(tradePlan, 0, 4, "TP2", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 4, f_priceText(planTP2) + " (" + str.tostring(tp2RR) + "R)", text_color=color.white, bgcolor=color.new(color.green, 5), text_size=size.tiny)
    table.cell(tradePlan, 0, 5, "RR Model", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 5, "TP2 = 1.5 : 1", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 0, 6, "Sentiment", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 6, activeSentimentText, text_color=color.white, bgcolor=activeSentimentColor, text_size=size.tiny)
    table.cell(tradePlan, 0, 7, "10C Forecast", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 7, forecastDir == 0 or na(forecastEnd) ? "WAIT" : (forecastDir == 1 ? "BUY → " : "SELL → ") + f_priceText(forecastEnd), text_color=color.white, bgcolor=forecastColor, text_size=size.tiny)
    table.cell(tradePlan, 0, 8, "Forecast Cap", text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
    table.cell(tradePlan, 1, 8, forecastCapText, text_color=color.white, bgcolor=color.new(color.black, 25), text_size=size.tiny)
if not showTradePlanPanel and barstate.islast
    for r = 0 to 8
        table.cell(tradePlan, 0, r, "", bgcolor=color.new(color.black, 100), text_size=size.tiny)
        table.cell(tradePlan, 1, r, "", bgcolor=color.new(color.black, 100), text_size=size.tiny)

var table dash = table.new(dashPos, 2, 17, border_width=1)
statusColor = strongBuy or buyCore or earlyBuy ? color.new(color.green, 0) : strongSell or sellCore or earlySell ? color.new(color.red, 0) : color.new(color.gray, 35)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "MOBILE WALLSTREET", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=dashSize)
    table.cell(dash, 1, 0, syminfo.ticker + " | Exec " + execTf, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=dashSize)
    table.cell(dash, 0, 1, "M15", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 1, m15Text, text_color=color.white, bgcolor=m15Color, text_size=dashSize)
    table.cell(dash, 0, 2, "H1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 2, h1Text, text_color=color.white, bgcolor=h1Color, text_size=dashSize)
    table.cell(dash, 0, 3, "H4", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 3, h4Text, text_color=color.white, bgcolor=h4Color, text_size=dashSize)
    table.cell(dash, 0, 4, "D1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 4, d1Text, text_color=color.white, bgcolor=d1Color, text_size=dashSize)
    table.cell(dash, 0, 5, "W1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 5, w1Text, text_color=color.white, bgcolor=w1Color, text_size=dashSize)
    table.cell(dash, 0, 6, "MN1", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 6, mn1Text, text_color=color.white, bgcolor=mn1Color, text_size=dashSize)
    table.cell(dash, 0, 7, "Core Counts", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 7, "B=" + str.tostring(bullCount) + " S=" + str.tostring(bearCount) + " Need=" + str.tostring(mtfRequired), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 8, "Confidence", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 8, "Buy " + str.tostring(bullConf) + " | Sell " + str.tostring(bearConf), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 9, "Rank", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 9, "Buy " + str.tostring(bullRank) + " | Sell " + str.tostring(bearRank), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 10, "Next Candle Ribbon", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 10, projectedNextText, text_color=color.white, bgcolor=projectedRibbonColor, text_size=dashSize)
    table.cell(dash, 0, 11, "Active Sentiment", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 11, activeSentimentText, text_color=color.white, bgcolor=activeSentimentColor, text_size=dashSize)
    table.cell(dash, 0, 12, "36 Indicator MTF Status", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 12, statusText, text_color=color.white, bgcolor=statusColor, text_size=dashSize)
    table.cell(dash, 0, 13, "W/M Context", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 13, "W1 " + w1Text + " | MN1 " + mn1Text, text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 0, 14, "Active Pattern", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 14, patternName, text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)
    table.cell(dash, 0, 15, "Pattern Direction", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 15, patternBias + " | " + str.tostring(patternScore) + "/10", text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)
    table.cell(dash, 0, 16, "Forecast Bias", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=dashSize)
    table.cell(dash, 1, 16, forecastBias, text_color=color.white, bgcolor=patternLabelColor, text_size=dashSize)

//==============================
// ALERTS
//==============================
if enableTalkingAlerts and barstate.isconfirmed and activeBuySentimentStart
    alert("Mobile Wallstreet says: Active BUY sentiment on " + syminfo.ticker + ". Confidence " + str.tostring(bullConf) + ". Rank " + str.tostring(bullRank) + ". Entry range " + f_priceText(buyEntryLow) + " to " + f_priceText(buyEntryHigh) + ". Stop loss " + f_priceText(buySL) + ". TP1 " + f_priceText(buyTP1) + ". TP2 " + f_priceText(buyTP2) + ". Pattern " + patternName + " " + patternBias + " score " + str.tostring(patternScore) + " out of 10. Ten candle forecast " + str.tostring(forecastEnd, format.mintick) + ". " + forecastCapText + ". " + activeSentimentText, alert.freq_once_per_bar_close)

if enableTalkingAlerts and barstate.isconfirmed and activeSellSentimentStart
    alert("Mobile Wallstreet says: Active SELL sentiment on " + syminfo.ticker + ". Confidence " + str.tostring(bearConf) + ". Rank " + str.tostring(bearRank) + ". Entry range " + f_priceText(sellEntryLow) + " to " + f_priceText(sellEntryHigh) + ". Stop loss " + f_priceText(sellSL) + ". TP1 " + f_priceText(sellTP1) + ". TP2 " + f_priceText(sellTP2) + ". Pattern " + patternName + " " + patternBias + " score " + str.tostring(patternScore) + " out of 10. Ten candle forecast " + str.tostring(forecastEnd, format.mintick) + ". " + forecastCapText + ". " + activeSentimentText, alert.freq_once_per_bar_close)

alertcondition(activeBuySentimentStart, title="Mobile Wallstreet ACTIVE BUY SENTIMENT", message="MWCI ACTIVE BUY SENTIMENT on {{ticker}}")
alertcondition(activeSellSentimentStart, title="Mobile Wallstreet ACTIVE SELL SENTIMENT", message="MWCI ACTIVE SELL SENTIMENT on {{ticker}}")
alertcondition(patternScore >= minPatternLabelScore and patternDir == 1, title="Mobile Wallstreet BULLISH PATTERN", message="MWCI bullish active pattern on {{ticker}}")
alertcondition(patternScore >= minPatternLabelScore and patternDir == -1, title="Mobile Wallstreet BEARISH PATTERN", message="MWCI bearish active pattern on {{ticker}}")
alertcondition(earlyBuySignal, title="Mobile Wallstreet EARLY BUY", message="MWCI EARLY BUY on {{ticker}}")
alertcondition(earlySellSignal, title="Mobile Wallstreet EARLY SELL", message="MWCI EARLY SELL on {{ticker}}")
alertcondition(buySignal, title="Mobile Wallstreet BUY", message="MWCI BUY on {{ticker}}")
alertcondition(sellSignal, title="Mobile Wallstreet SELL", message="MWCI SELL on {{ticker}}")
alertcondition(strongBuySignal, title="Mobile Wallstreet STRONG BUY", message="MWCI STRONG BUY on {{ticker}}")
alertcondition(strongSellSignal, title="Mobile Wallstreet STRONG SELL", message="MWCI STRONG SELL on {{ticker}}")
````
