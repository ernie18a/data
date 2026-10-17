# Crypto: Fear & Greed Index [invincible3]

- url: https://www.tradingview.com/script/rtxWf16s-Crypto-Fear-Greed-Index-invincible3/
- type: indicator
- pine_id: PUB;68d3b60c20ea4879867fd20d4aba9dc7
- version: 1.0

## Description

[b]Crypto: Fear & Greed Index [invincible3][/b]

Crypto: Fear & Greed Index is a multi-factor sentiment oscillator designed to estimate crypto market risk appetite directly inside TradingView. Instead of relying on a single RSI or momentum reading, this indicator combines several market proxies into one smoothed 0–100 sentiment index.

The model uses price momentum, volatility behavior, RSI strength, volume pressure, range position, crypto breadth, stablecoin dominance, TOTAL market trend, and BTC dominance context. These factors are auto-normalized into a composite Fear & Greed score.

The oscillator is divided into clear sentiment zones:

0–25: Extreme Fear
25–45: Fear
45–55: Neutral
55–75: Greed
75–100: Extreme Greed

The indicator also includes a market-regime layer to classify conditions as Bull / Risk-On, Bear / Risk-Off, or Mixed / Transition. This helps traders avoid interpreting fear and greed in isolation.

[b]Key features:[/b]

• Multi-factor crypto sentiment model
• Auto-normalized Fear & Greed score
• Adaptive dark/light chart colors
• Risk-on / risk-off regime detection
• Crypto breadth using major market symbols
• Stablecoin dominance and BTC dominance context
• TOTAL and TOTAL2 market trend integration
• Fear, Neutral, and Greed oscillator zones
• Dashboard with index value, regime, bias, factor scores, and weights
• Visual Fear-to-Greed meter
• Accumulation, Risk, Trend, and Trim context markers
• Regular bullish and bearish divergence detection
• Divergence plotted on both price chart and oscillator
• Alerts for major sentiment transitions and divergence signals

[b]How to interpret:[/b]

Extreme Fear does not automatically mean buy. In a bear regime, fear can continue and price may keep falling. Extreme Fear becomes more useful when the broader regime is improving or when bullish divergence appears.

Extreme Greed does not automatically mean sell. In a strong bull regime, greed can support continuation. However, extreme greed with fading momentum may indicate crowding risk, where trimming or reducing exposure may be considered.

The indicator works best as a sentiment and risk-context tool, not as a standalone buy/sell system. It should be combined with price structure, support and resistance, volume, trend filters, and risk management.

This indicator is designed primarily for crypto markets. It can be applied to BTC, ETH, altcoins, and other crypto symbols. BTC is not the only supported asset; BTC is used as one part of the broader market-context model.

[b]Disclaimer:[/b]

This script is for educational and analytical purposes only. It does not provide financial advice. Always use proper risk management and confirm signals with your own trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3
//@version=6

indicator("Crypto: Fear & Greed Index [invincible3]", shorttitle="FGI Pro", overlay=false, precision=0, max_labels_count=200, max_lines_count=300)

// ------------------------------------------------------------
// INPUTS
// ------------------------------------------------------------
grpW = "Factor Weights - Auto Normalized"
wMom    = input.float(18, "Momentum weight", minval=0, group=grpW, tooltip="Weight given to price momentum.")
wVol    = input.float(14, "Volatility weight", minval=0, group=grpW, tooltip="Weight given to price volatility.")
wRsi    = input.float(10, "RSI / Strength weight", minval=0, group=grpW, tooltip="Weight given to RSI strength.")
wVolu   = input.float(12, "Volume pressure weight", minval=0, group=grpW, tooltip="Weight given to volume pressure.")
wRng    = input.float(10, "Range position weight", minval=0, group=grpW, tooltip="Weight given to range position.")
wBrth   = input.float(16, "Crypto breadth weight", minval=0, group=grpW, tooltip="Weight given to crypto breadth.")
wStable = input.float(10, "Stablecoin dominance weight", minval=0, group=grpW, tooltip="Weight given to stablecoin dominance.")
wMkt    = input.float(6,  "TOTAL market trend weight", minval=0, group=grpW, tooltip="Weight given to TOTAL market trend.")
wDom    = input.float(4,  "BTC dominance context weight", minval=0, group=grpW, tooltip="Weight given to BTC dominance.")

grpL = "Core Lengths"
momLen     = input.int(20, "Momentum length", minval=2, group=grpL, tooltip="Length for Momentum calculation.")
volLen     = input.int(20, "ATR volatility length", minval=2, group=grpL, tooltip="Length for ATR Volatility calculation.")
rankLen    = input.int(100, "Percentile ranking length", minval=20, group=grpL, tooltip="Length for Percentile Ranking.")
rsiLen     = input.int(14, "RSI length", minval=2, group=grpL, tooltip="Length for RSI calculation.")
voluLen    = input.int(20, "Volume pressure length", minval=2, group=grpL, tooltip="Length for Volume Pressure calculation.")
rngLen     = input.int(20, "Range position length", minval=2, group=grpL, tooltip="Length for Range Position calculation.")
breadthLen = input.int(50, "Breadth EMA length", minval=5, group=grpL, tooltip="Length for Breadth EMA.")
marketLen  = input.int(50, "TOTAL market EMA length", minval=5, group=grpL, tooltip="Length for TOTAL Market EMA.")
domLen     = input.int(20, "Dominance lookback", minval=2, group=grpL, tooltip="Lookback period for Dominance.")
regimeLen  = input.int(200, "Asset regime EMA length", minval=20, group=grpL, tooltip="Length for Asset Regime EMA.")

grpS = "Smoothing"
smoothLen  = input.int(5, "Index smoothing length", minval=1, group=grpS, tooltip="Length used to smooth the final Index.")
smoothType = input.string("EMA", "Smoothing type", options=["SMA", "EMA", "RMA", "WMA"], group=grpS, tooltip="Type of moving average used for smoothing.")
useHyst    = input.bool(true, "Use regime hysteresis", group=grpS, tooltip="Smooth out transitions between zones to avoid flickering.")

grpM = "Market Symbols"
btcSym     = input.symbol("BINANCE:BTCUSDT", "BTC symbol", group=grpM, tooltip="Symbol for Bitcoin.")
ethSym     = input.symbol("BINANCE:ETHUSDT", "ETH symbol", group=grpM, tooltip="Symbol for Ethereum.")
solSym     = input.symbol("BINANCE:SOLUSDT", "SOL symbol", group=grpM, tooltip="Symbol for Solana.")
bnbSym     = input.symbol("BINANCE:BNBUSDT", "BNB symbol", group=grpM, tooltip="Symbol for Binance Coin.")
totalSym   = input.symbol("CRYPTOCAP:TOTAL", "Crypto TOTAL symbol", group=grpM, tooltip="Symbol for Crypto Total Market Cap.")
total2Sym  = input.symbol("CRYPTOCAP:TOTAL2", "Crypto TOTAL2 symbol", group=grpM, tooltip="Symbol for Crypto Total Market Cap excluding BTC.")
btcDomSym  = input.symbol("CRYPTOCAP:BTC.D", "BTC dominance symbol", group=grpM, tooltip="Symbol for BTC Dominance.")
usdtDomSym = input.symbol("CRYPTOCAP:USDT.D", "USDT dominance symbol", group=grpM, tooltip="Symbol for USDT Dominance.")

grpD = "Display"
showDash       = input.bool(true, "Show dashboard on chart", group=grpD, tooltip="Toggle dashboard visibility.")
showFactors    = input.bool(true, "Show factor breakdown", group=grpD, tooltip="Show individual factor values on the dashboard.")
dashPos        = input.string("Top Right", "Dashboard position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpD, tooltip="Position of the dashboard.")
panelTransp    = input.int(8, "Dashboard background transparency", minval=0, maxval=90, group=grpD, tooltip="Transparency of the dashboard background.")
rowTransp      = input.int(92, "Dashboard row tint transparency", minval=70, maxval=100, group=grpD, tooltip="Transparency of the dashboard rows.")
showSignals    = input.bool(true, "Show signal markers", group=grpD, tooltip="Toggle signal markers on the oscillator.")
showDivs       = input.bool(true, "Show FGI divergence markers", group=grpD, tooltip="Toggle FGI divergence markers.")
divLen         = input.int(5, "Divergence pivot length", minval=2, maxval=20, group=grpD, tooltip="Pivot length for detecting divergences.")
maxDivLen      = input.int(60, "Maximum divergence lookback", minval=10, maxval=200, group=grpD, tooltip="Maximum distance between divergence pivot points.")
divExtremeOnly = input.bool(true, "Only show divergence in fear/greed zones", group=grpD, tooltip="Filters weak divergence by requiring bullish divergence near fear and bearish divergence near greed.")
bullDivZoneMax = input.float(45, "Bullish divergence max FGI", minval=0, maxval=100, group=grpD)
bearDivZoneMin = input.float(55, "Bearish divergence min FGI", minval=0, maxval=100, group=grpD)
textSizeIn     = input.string("Small", "Dashboard text size", options=["Tiny", "Small", "Normal"], group=grpD, tooltip="Text size for the dashboard.")

// ------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------
clamp100(x) =>
    math.max(0.0, math.min(100.0, x))

nz50(x) =>
    nz(x, 50.0)

maSmooth(src, len) =>
    float out = na
    if smoothType == "SMA"
        out := ta.sma(src, len)
    else if smoothType == "EMA"
        out := ta.ema(src, len)
    else if smoothType == "RMA"
        out := ta.rma(src, len)
    else
        out := ta.wma(src, len)
    out

secTrend(sym, len) =>
    request.security(sym, timeframe.period, close > ta.ema(close, len) ? 1.0 : 0.0, ignore_invalid_symbol=true)

secMarketScore(sym, len) =>
    request.security(
         sym,
         timeframe.period,
         math.max(0.0, math.min(100.0, 50.0 + ((close - ta.ema(close, len)) / ta.ema(close, len)) * 250.0)),
         ignore_invalid_symbol=true
     )

secRoc(sym, len) =>
    request.security(sym, timeframe.period, ta.roc(close, len), ignore_invalid_symbol=true)

secChange(sym, len) =>
    request.security(sym, timeframe.period, ta.change(close, len), ignore_invalid_symbol=true)

luma(c) =>
    0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)

f_meter(x) =>
    int slots = 20
    int pos = int(math.round(clamp100(x) / 100.0 * slots))
    string bar = ""
    for i = 0 to slots
        bar += i == pos ? "●" : i < pos ? "━" : "─"
    bar

// ------------------------------------------------------------
// CHART-ADAPTIVE THEME
// ------------------------------------------------------------
chartBg = chart.bg_color
chartFg = chart.fg_color
isDark  = luma(chartBg) < 128

cFear  = isDark ? color.rgb(239, 83, 80)  : color.rgb(213, 45, 60)
cGreed = isDark ? color.rgb(38, 166, 154) : color.rgb(0, 128, 105)
cNeut  = isDark ? color.rgb(255, 183, 77) : color.rgb(230, 126, 0)

cTxt   = chartFg
cDim   = color.new(chartFg, isDark ? 35 : 45)
cPanel = color.new(chartBg, panelTransp)
cHead  = color.new(chartFg, isDark ? 88 : 92)
cHair  = color.new(chartFg, isDark ? 72 : 78)
cRow   = color.new(chartFg, rowTransp)

scoreColor(x) =>
    x <= 44 ? cFear : x >= 56 ? cGreed : cNeut

cellBg(row) =>
    row % 2 == 0 ? cPanel : cRow

txtSize = textSizeIn == "Tiny" ? size.tiny : textSizeIn == "Small" ? size.small : size.normal

// ------------------------------------------------------------
// FACTORS
// ------------------------------------------------------------
roc = ta.roc(close, momLen)
rocMean = ta.sma(roc, rankLen)
rocDev = ta.stdev(roc, rankLen)
zMom = rocDev > 0 ? (roc - rocMean) / rocDev : 0.0
fMom = clamp100(50 + zMom * 15)

atrp = ta.atr(volLen) / close * 100
volRank = ta.percentrank(atrp, rankLen)
shortRet = ta.roc(close, 5)
fVol = shortRet < 0 ? clamp100(100 - volRank) : clamp100(50 + volRank * 0.5)

fRsi = clamp100(ta.rsi(close, rsiLen))

vol = volume
upVol = close > close[1] ? vol : 0.0
dnVol = close < close[1] ? vol : 0.0
volBase = ta.sma(upVol + dnVol, voluLen)
buyPressure = volBase > 0 ? ta.sma(upVol, voluLen) / volBase : 0.5
fVolu = clamp100(buyPressure * 100)

hh = ta.highest(high, rngLen)
ll = ta.lowest(low, rngLen)
fRng = hh > ll ? clamp100((close - ll) / (hh - ll) * 100) : 50

bBTC = secTrend(btcSym, breadthLen)
bETH = secTrend(ethSym, breadthLen)
bSOL = secTrend(solSym, breadthLen)
bBNB = secTrend(bnbSym, breadthLen)

breadthCount = (not na(bBTC) ? 1 : 0) + (not na(bETH) ? 1 : 0) + (not na(bSOL) ? 1 : 0) + (not na(bBNB) ? 1 : 0)
breadthSum = nz(bBTC) + nz(bETH) + nz(bSOL) + nz(bBNB)
fBrth = breadthCount > 0 ? clamp100(breadthSum / breadthCount * 100) : 50

usdtDomChange = secChange(usdtDomSym, domLen)
fStable = na(usdtDomChange) ? 50 : clamp100(50 - usdtDomChange * 20)

totalScore = secMarketScore(totalSym, marketLen)
total2Score = secMarketScore(total2Sym, marketLen)

mktCount = (not na(totalScore) ? 1 : 0) + (not na(total2Score) ? 1 : 0)
mktSum = nz(totalScore) + nz(total2Score)
fMkt = mktCount > 0 ? clamp100(mktSum / mktCount) : 50

btcDomChange = secChange(btcDomSym, domLen)
totalRoc = secRoc(totalSym, domLen)

fDom =
     na(btcDomChange) or na(totalRoc) ? 50 :
     totalRoc > 0 and btcDomChange < 0 ? 75 :
     totalRoc > 0 and btcDomChange >= 0 ? 60 :
     totalRoc < 0 and btcDomChange > 0 ? 25 :
     totalRoc < 0 and btcDomChange <= 0 ? 35 :
     50

// ------------------------------------------------------------
// COMPOSITE INDEX
// ------------------------------------------------------------
fMomN    = nz50(fMom)
fVolN    = nz50(fVol)
fRsiN    = nz50(fRsi)
fVoluN   = nz50(fVolu)
fRngN    = nz50(fRng)
fBrthN   = nz50(fBrth)
fStableN = nz50(fStable)
fMktN    = nz50(fMkt)
fDomN    = nz50(fDom)

wSum = wMom + wVol + wRsi + wVolu + wRng + wBrth + wStable + wMkt + wDom

raw =
     wSum > 0 ?
     (
         fMomN * wMom +
         fVolN * wVol +
         fRsiN * wRsi +
         fVoluN * wVolu +
         fRngN * wRng +
         fBrthN * wBrth +
         fStableN * wStable +
         fMktN * wMkt +
         fDomN * wDom
     ) / wSum :
     50

fgi = clamp100(maSmooth(raw, smoothLen))
fgiR = math.round(fgi)

// ------------------------------------------------------------
// REGIME LOGIC
// ------------------------------------------------------------
assetEma = ta.ema(close, regimeLen)
bullRegime = close > assetEma and fMktN >= 50
bearRegime = close < assetEma and fMktN < 50
mixedRegime = not bullRegime and not bearRegime

regimeTxt = bullRegime ? "BULL / RISK-ON" : bearRegime ? "BEAR / RISK-OFF" : "MIXED / TRANSITION"

// ------------------------------------------------------------
// ZONE CLASSIFICATION
// ------------------------------------------------------------
zoneBase = fgi <= 24 ? -2 : fgi <= 44 ? -1 : fgi <= 55 ? 0 : fgi <= 75 ? 1 : 2

var int zone = 0

if not useHyst
    zone := zoneBase
else
    if barstate.isfirst or na(fgi[1])
        zone := zoneBase
    else
        if zone == -2
            zone := fgi > 50 ? 0 : fgi > 30 ? -1 : -2
        else if zone == -1
            zone := fgi <= 24 ? -2 : fgi > 50 ? 0 : -1
        else if zone == 0
            zone := fgi <= 24 ? -2 : fgi < 40 ? -1 : fgi > 76 ? 2 : fgi > 60 ? 1 : 0
        else if zone == 1
            zone := fgi >= 76 ? 2 : fgi < 50 ? 0 : 1
        else
            zone := fgi < 70 ? 1 : 2

stateTxt =
     zone == -2 ? "EXTREME FEAR" :
     zone == -1 ? "FEAR" :
     zone == 0 ? "NEUTRAL" :
     zone == 1 ? "GREED" :
     "EXTREME GREED"

stCol = scoreColor(fgi)

// ------------------------------------------------------------
// TRADER SIGNAL CONTEXT
// ------------------------------------------------------------
momentumFading = fgi > 75 and ta.roc(close, 5) < ta.roc(close, 20)

accumulationWatch = fgi < 25 and bullRegime
riskOffWarning = fgi < 35 and bearRegime
trendContinuation = fgi > 55 and bullRegime and not momentumFading
crowdingRisk = momentumFading
recoverySignal = ta.crossover(fgi, 50)
sentimentBreakdown = ta.crossunder(fgi, 50)

biasTxt =
     accumulationWatch ? "ACCUMULATION WATCH" :
     riskOffWarning ? "RISK-OFF / AVOID KNIFE" :
     crowdingRisk ? "CROWDING RISK" :
     trendContinuation ? "TREND CONTINUATION" :
     mixedRegime ? "WAIT / TRANSITION" :
     "NEUTRAL"

// ------------------------------------------------------------
// OSCILLATOR PLOT
// ------------------------------------------------------------
lineCol = scoreColor(fgi)

pFgi = plot(fgi, "FGI Pro", color=lineCol, linewidth=3)

p100 = plot(100, "100", color=color.new(cDim, 85), linewidth=1)
p75  = plot(75, "Extreme Greed", color=color.new(cGreed, 35), linewidth=1)
p55  = plot(55, "Greed", color=color.new(cGreed, 65), linewidth=1)
p50  = plot(50, "Neutral", color=color.new(cDim, 50), linewidth=1)
p45  = plot(45, "Fear", color=color.new(cFear, 65), linewidth=1)
p25  = plot(25, "Extreme Fear", color=color.new(cFear, 35), linewidth=1)
p0   = plot(0, "0", color=color.new(cDim, 85), linewidth=1)

fill(p75, p100, color=color.new(cGreed, 88), title="Extreme Greed Zone")
fill(p0, p25, color=color.new(cFear, 88), title="Extreme Fear Zone")
fill(p45, p55, color=color.new(cNeut, 92), title="Neutral Zone")

bgcolor(color.new(stCol, 94), title="Sentiment Tint")

// ------------------------------------------------------------
// SIGNAL MARKERS - CLEAN / NO LABEL SPAM
// ------------------------------------------------------------
signalCooldown = 20

var int lastAccumBar = na
var int lastRiskBar  = na
var int lastTrendBar = na
var int lastTrimBar  = na

canFire(lastBar) =>
    na(lastBar) or bar_index - lastBar > signalCooldown

rawAccumTrig = ta.crossover(fgi, 25) and bullRegime
rawRiskTrig  = ta.crossunder(fgi, 35) and bearRegime
rawTrendTrig = ta.crossover(fgi, 55) and bullRegime

// TRIM should only appear when crowding risk first starts,
// not on every candle while the condition remains true.
rawTrimTrig = fgi > 75 and momentumFading and not momentumFading[1]

accumTrig = showSignals and rawAccumTrig and canFire(lastAccumBar)
riskOffTrig = showSignals and rawRiskTrig and canFire(lastRiskBar)
trendTrig = showSignals and rawTrendTrig and canFire(lastTrendBar)
trimTrig = showSignals and rawTrimTrig and canFire(lastTrimBar)

if accumTrig
    lastAccumBar := bar_index

if riskOffTrig
    lastRiskBar := bar_index

if trendTrig
    lastTrendBar := bar_index

if trimTrig
    lastTrimBar := bar_index

plotshape(
     accumTrig ? fgi : na,
     title="Accumulation Watch",
     style=shape.labelup,
     location=location.absolute,
     text="ACC",
     color=cGreed,
     textcolor=color.white,
     size=size.tiny
 )

plotshape(
     riskOffTrig ? fgi : na,
     title="Risk-Off Warning",
     style=shape.labeldown,
     location=location.absolute,
     text="RISK",
     color=cFear,
     textcolor=color.white,
     size=size.tiny
 )

plotshape(
     trendTrig ? fgi : na,
     title="Trend Continuation",
     style=shape.labelup,
     location=location.absolute,
     text="TREND",
     color=cGreed,
     textcolor=color.white,
     size=size.tiny
 )

plotshape(
     trimTrig ? fgi : na,
     title="Crowding Risk",
     style=shape.labeldown,
     location=location.absolute,
     text="TRIM",
     color=cNeut,
     textcolor=color.black,
     size=size.tiny
 )
// ------------------------------------------------------------
// DIVERGENCE LOGIC - MAJOR REGULAR DIVERGENCE ONLY
// ------------------------------------------------------------

hidBullDiv = false
hidBearDiv = false

regBullDiv = false
regBearDiv = false

float regBullPlot = na
float regBearPlot = na

// Internal clean filters
int   minDivGap      = math.max(divLen * 3, 12)
float minFgiDelta    = 6.0
int   pivotMemory    = 12
int   maxStoredLines = 12

// Recent pivot memory
var int[]   lowIdxArr   = array.new_int()
var float[] lowPriceArr = array.new_float()
var float[] lowFgiArr   = array.new_float()

var int[]   highIdxArr   = array.new_int()
var float[] highPriceArr = array.new_float()
var float[] highFgiArr   = array.new_float()

// Auto-remove old lines
var line[] divLineArr = array.new_line()

f_keepLine(l) =>
    array.push(divLineArr, l)
    if array.size(divLineArr) > maxStoredLines
        line.delete(array.shift(divLineArr))

f_cleanBetween(src, prevVal, curVal, bars, isBull) =>
    bool ok = true
    int lim = math.min(bars - 1, maxDivLen)

    if lim > 0
        for k = 1 to lim
            float v = src[divLen + k]
            float lineVal = prevVal + (curVal - prevVal) * (bars - k) / bars

            if not na(v)
                if isBull and v < lineVal
                    ok := false
                    break

                if not isBull and v > lineVal
                    ok := false
                    break

    ok

pricePL = ta.pivotlow(low, divLen, divLen)
pricePH = ta.pivothigh(high, divLen, divLen)

// -----------------------------
// REGULAR BULLISH DIVERGENCE
// -----------------------------
if not na(pricePL)
    int curPLIndex = bar_index - divLen
    float curPricePL = pricePL
    float curFgiPL = fgi[divLen]

    int bestIdx = na
    float bestPrice = na
    float bestFgi = na
    float bestScore = na

    int lowCount = array.size(lowIdxArr)

    if lowCount > 0
        for n = 0 to lowCount - 1
            int prevIdx = array.get(lowIdxArr, n)
            float prevPrice = array.get(lowPriceArr, n)
            float prevFgi = array.get(lowFgiArr, n)

            int bars = curPLIndex - prevIdx

            bool validDistance = bars >= minDivGap and bars <= maxDivLen
            bool validZone = not divExtremeOnly or (prevFgi <= bullDivZoneMax and curFgiPL <= bullDivZoneMax)
            bool validRegularBull = curPricePL < prevPrice and curFgiPL > prevFgi + minFgiDelta

            if validDistance and validZone and validRegularBull
                bool cleanPrice = f_cleanBetween(low, prevPrice, curPricePL, bars, true)
                bool cleanOsc = f_cleanBetween(fgi, prevFgi, curFgiPL, bars, true)

                if cleanPrice and cleanOsc
                    float priceMovePct = prevPrice != 0 ? math.abs((curPricePL - prevPrice) / prevPrice) * 100 : 0
                    float score = (curFgiPL - prevFgi) + priceMovePct

                    if na(bestScore) or score > bestScore
                        bestScore := score
                        bestIdx := prevIdx
                        bestPrice := prevPrice
                        bestFgi := prevFgi

    if not na(bestIdx)
        regBullDiv := true
        regBullPlot := curFgiPL

        if showDivs
            line bullPriceLine = line.new(
                 bestIdx,
                 bestPrice,
                 curPLIndex,
                 curPricePL,
                 color=cGreed,
                 width=2,
                 force_overlay=true
             )

            line bullOscLine = line.new(
                 bestIdx,
                 bestFgi,
                 curPLIndex,
                 curFgiPL,
                 color=color.new(cGreed, 20),
                 width=2
             )

            f_keepLine(bullPriceLine)
            f_keepLine(bullOscLine)

    array.push(lowIdxArr, curPLIndex)
    array.push(lowPriceArr, curPricePL)
    array.push(lowFgiArr, curFgiPL)

    if array.size(lowIdxArr) > pivotMemory
        array.shift(lowIdxArr)
        array.shift(lowPriceArr)
        array.shift(lowFgiArr)

// -----------------------------
// REGULAR BEARISH DIVERGENCE
// -----------------------------
if not na(pricePH)
    int curPHIndex = bar_index - divLen
    float curPricePH = pricePH
    float curFgiPH = fgi[divLen]

    int bestIdx = na
    float bestPrice = na
    float bestFgi = na
    float bestScore = na

    int highCount = array.size(highIdxArr)

    if highCount > 0
        for n = 0 to highCount - 1
            int prevIdx = array.get(highIdxArr, n)
            float prevPrice = array.get(highPriceArr, n)
            float prevFgi = array.get(highFgiArr, n)

            int bars = curPHIndex - prevIdx

            bool validDistance = bars >= minDivGap and bars <= maxDivLen
            bool validZone = not divExtremeOnly or (prevFgi >= bearDivZoneMin and curFgiPH >= bearDivZoneMin)
            bool validRegularBear = curPricePH > prevPrice and curFgiPH < prevFgi - minFgiDelta

            if validDistance and validZone and validRegularBear
                bool cleanPrice = f_cleanBetween(high, prevPrice, curPricePH, bars, false)
                bool cleanOsc = f_cleanBetween(fgi, prevFgi, curFgiPH, bars, false)

                if cleanPrice and cleanOsc
                    float priceMovePct = prevPrice != 0 ? math.abs((curPricePH - prevPrice) / prevPrice) * 100 : 0
                    float score = (prevFgi - curFgiPH) + priceMovePct

                    if na(bestScore) or score > bestScore
                        bestScore := score
                        bestIdx := prevIdx
                        bestPrice := prevPrice
                        bestFgi := prevFgi

    if not na(bestIdx)
        regBearDiv := true
        regBearPlot := curFgiPH

        if showDivs
            line bearPriceLine = line.new(
                 bestIdx,
                 bestPrice,
                 curPHIndex,
                 curPricePH,
                 color=cFear,
                 width=2,
                 force_overlay=true
             )

            line bearOscLine = line.new(
                 bestIdx,
                 bestFgi,
                 curPHIndex,
                 curFgiPH,
                 color=color.new(cFear, 20),
                 width=2
             )

            f_keepLine(bearPriceLine)
            f_keepLine(bearOscLine)

    array.push(highIdxArr, curPHIndex)
    array.push(highPriceArr, curPricePH)
    array.push(highFgiArr, curFgiPH)

    if array.size(highIdxArr) > pivotMemory
        array.shift(highIdxArr)
        array.shift(highPriceArr)
        array.shift(highFgiArr)

// Divergence labels in oscillator pane
plotshape(
     showDivs and regBullDiv ? regBullPlot : na,
     title="Regular Bullish Divergence",
     style=shape.labelup,
     location=location.absolute,
     offset=-divLen,
     text="Bull Div",
     color=cGreed,
     textcolor=color.white,
     size=size.tiny
 )

plotshape(
     showDivs and regBearDiv ? regBearPlot : na,
     title="Regular Bearish Divergence",
     style=shape.labeldown,
     location=location.absolute,
     offset=-divLen,
     text="Bear Div",
     color=cFear,
     textcolor=color.white,
     size=size.tiny
 )
// ------------------------------------------------------------
// DASHBOARD ON MAIN CHART
// ------------------------------------------------------------
dashPosition =
     dashPos == "Top Right" ? position.top_right :
     dashPos == "Top Left" ? position.top_left :
     dashPos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(
     dashPosition,
     3,
     17,
     bgcolor=cPanel,
     border_color=cHair,
     border_width=1,
     frame_color=cHair,
     frame_width=1,
     force_overlay=true
 )

if barstate.isfirst
    table.merge_cells(dash, 0, 0, 2, 0)
    table.merge_cells(dash, 0, 5, 2, 5)

pMom = wSum > 0 ? wMom / wSum * 100 : 0
pVol = wSum > 0 ? wVol / wSum * 100 : 0
pRsi = wSum > 0 ? wRsi / wSum * 100 : 0
pVolu = wSum > 0 ? wVolu / wSum * 100 : 0
pRng = wSum > 0 ? wRng / wSum * 100 : 0
pBrth = wSum > 0 ? wBrth / wSum * 100 : 0
pStable = wSum > 0 ? wStable / wSum * 100 : 0
pMkt = wSum > 0 ? wMkt / wSum * 100 : 0
pDom = wSum > 0 ? wDom / wSum * 100 : 0

delta = fgiR - nz(fgiR[1], fgiR)
deltaTxt = delta > 0 ? "▲ +" + str.tostring(delta, "#") : delta < 0 ? "▼ " + str.tostring(delta, "#") : "● 0"

meterTxt = "FEAR  " + f_meter(fgi) + "  GREED"

if barstate.islast and showDash
    table.cell(
         dash,
         0,
         0,
         "CRYPTO FEAR & GREED INDEX PRO",
         text_color=cTxt,
         text_size=txtSize,
         bgcolor=cHead,
         text_halign=text.align_center
     )

    table.cell(dash, 0, 1, "Index", text_color=cDim, text_size=txtSize, bgcolor=cellBg(1))
    table.cell(dash, 1, 1, str.tostring(fgiR, "#"), text_color=stCol, text_size=size.huge, bgcolor=cellBg(1))
    table.cell(dash, 2, 1, deltaTxt, text_color=cDim, text_size=txtSize, bgcolor=cellBg(1))

    table.cell(dash, 0, 2, "State", text_color=cDim, text_size=txtSize, bgcolor=cellBg(2))
    table.cell(dash, 1, 2, stateTxt, text_color=stCol, text_size=txtSize, bgcolor=cellBg(2))
    table.cell(dash, 2, 2, "", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(2))

    table.cell(dash, 0, 3, "Regime", text_color=cDim, text_size=txtSize, bgcolor=cellBg(3))
    table.cell(dash, 1, 3, regimeTxt, text_color=bullRegime ? cGreed : bearRegime ? cFear : cNeut, text_size=txtSize, bgcolor=cellBg(3))
    table.cell(dash, 2, 3, "", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(3))

    table.cell(dash, 0, 4, "Bias", text_color=cDim, text_size=txtSize, bgcolor=cellBg(4))
    table.cell(
         dash,
         1,
         4,
         biasTxt,
         text_color=accumulationWatch or trendContinuation ? cGreed : riskOffWarning ? cFear : crowdingRisk ? cNeut : cDim,
         text_size=txtSize,
         bgcolor=cellBg(4)
     )
    table.cell(dash, 2, 4, "", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(4))

    table.cell(
         dash,
         0,
         5,
         meterTxt,
         text_color=stCol,
         text_size=txtSize,
         bgcolor=color.new(stCol, 88),
         text_halign=text.align_center
     )

    if showFactors
        table.cell(dash, 0, 6, "Factor", text_color=cDim, text_size=txtSize, bgcolor=cHead)
        table.cell(dash, 1, 6, "Score", text_color=cDim, text_size=txtSize, bgcolor=cHead)
        table.cell(dash, 2, 6, "Weight", text_color=cDim, text_size=txtSize, bgcolor=cHead)

        table.cell(dash, 0, 7, "Momentum", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(7))
        table.cell(dash, 1, 7, str.tostring(math.round(fMomN), "#"), text_color=scoreColor(fMomN), text_size=txtSize, bgcolor=cellBg(7))
        table.cell(dash, 2, 7, str.tostring(pMom, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(7))

        table.cell(dash, 0, 8, "Volatility", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(8))
        table.cell(dash, 1, 8, str.tostring(math.round(fVolN), "#"), text_color=scoreColor(fVolN), text_size=txtSize, bgcolor=cellBg(8))
        table.cell(dash, 2, 8, str.tostring(pVol, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(8))

        table.cell(dash, 0, 9, "RSI Strength", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(9))
        table.cell(dash, 1, 9, str.tostring(math.round(fRsiN), "#"), text_color=scoreColor(fRsiN), text_size=txtSize, bgcolor=cellBg(9))
        table.cell(dash, 2, 9, str.tostring(pRsi, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(9))

        table.cell(dash, 0, 10, "Volume Pressure", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(10))
        table.cell(dash, 1, 10, str.tostring(math.round(fVoluN), "#"), text_color=scoreColor(fVoluN), text_size=txtSize, bgcolor=cellBg(10))
        table.cell(dash, 2, 10, str.tostring(pVolu, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(10))

        table.cell(dash, 0, 11, "Range Position", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(11))
        table.cell(dash, 1, 11, str.tostring(math.round(fRngN), "#"), text_color=scoreColor(fRngN), text_size=txtSize, bgcolor=cellBg(11))
        table.cell(dash, 2, 11, str.tostring(pRng, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(11))

        table.cell(dash, 0, 12, "Crypto Breadth", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(12))
        table.cell(dash, 1, 12, str.tostring(math.round(fBrthN), "#"), text_color=scoreColor(fBrthN), text_size=txtSize, bgcolor=cellBg(12))
        table.cell(dash, 2, 12, str.tostring(pBrth, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(12))

        table.cell(dash, 0, 13, "USDT Dominance", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(13))
        table.cell(dash, 1, 13, str.tostring(math.round(fStableN), "#"), text_color=scoreColor(fStableN), text_size=txtSize, bgcolor=cellBg(13))
        table.cell(dash, 2, 13, str.tostring(pStable, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(13))

        table.cell(dash, 0, 14, "TOTAL Trend", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(14))
        table.cell(dash, 1, 14, str.tostring(math.round(fMktN), "#"), text_color=scoreColor(fMktN), text_size=txtSize, bgcolor=cellBg(14))
        table.cell(dash, 2, 14, str.tostring(pMkt, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(14))

        table.cell(dash, 0, 15, "BTC Dominance", text_color=cTxt, text_size=txtSize, bgcolor=cellBg(15))
        table.cell(dash, 1, 15, str.tostring(math.round(fDomN), "#"), text_color=scoreColor(fDomN), text_size=txtSize, bgcolor=cellBg(15))
        table.cell(dash, 2, 15, str.tostring(pDom, "#.0") + "%", text_color=cDim, text_size=txtSize, bgcolor=cellBg(15))

        table.cell(dash, 0, 16, "Model", text_color=cDim, text_size=txtSize, bgcolor=cHead)
        table.cell(dash, 1, 16, "Multi-Market", text_color=cTxt, text_size=txtSize, bgcolor=cHead)
        table.cell(dash, 2, 16, "Proxy", text_color=cDim, text_size=txtSize, bgcolor=cHead)
    else
        table.clear(dash, 0, 6, 2, 16)

else if barstate.islast and not showDash
    table.clear(dash, 0, 0, 2, 16)

// ------------------------------------------------------------
// DATA WINDOW FACTOR PLOTS
// ------------------------------------------------------------
plot(fMomN, "Factor - Momentum", display=display.data_window)
plot(fVolN, "Factor - Volatility", display=display.data_window)
plot(fRsiN, "Factor - RSI Strength", display=display.data_window)
plot(fVoluN, "Factor - Volume Pressure", display=display.data_window)
plot(fRngN, "Factor - Range Position", display=display.data_window)
plot(fBrthN, "Factor - Crypto Breadth", display=display.data_window)
plot(fStableN, "Factor - USDT Dominance", display=display.data_window)
plot(fMktN, "Factor - TOTAL Market Trend", display=display.data_window)
plot(fDomN, "Factor - BTC Dominance Context", display=display.data_window)

// ------------------------------------------------------------
// ALERTS
// ------------------------------------------------------------
alertcondition(ta.crossunder(fgi, 25), "Entered Extreme Fear", "FGI Pro entered EXTREME FEAR.")
alertcondition(ta.crossover(fgi, 75), "Entered Extreme Greed", "FGI Pro entered EXTREME GREED.")
alertcondition(recoverySignal, "Crossed Above Neutral", "FGI Pro crossed above 50. Sentiment recovery.")
alertcondition(sentimentBreakdown, "Crossed Below Neutral", "FGI Pro crossed below 50. Sentiment deterioration.")
alertcondition(accumTrig, "Accumulation Watch", "FGI Pro: Extreme fear recovery inside bull/risk-on regime.")
alertcondition(riskOffTrig, "Risk-Off Warning", "FGI Pro: Fear worsening inside bear/risk-off regime.")
alertcondition(trendTrig, "Trend Continuation", "FGI Pro: Greed expansion inside bull/risk-on regime.")
alertcondition(trimTrig, "Crowding Risk", "FGI Pro: Extreme greed with fading momentum. Consider trimming or hedging.")
alertcondition(regBullDiv, "Regular Bullish FGI Divergence", "FGI Pro regular bullish divergence detected.")
alertcondition(hidBullDiv, "Hidden Bullish FGI Divergence", "FGI Pro hidden bullish divergence detected.")
alertcondition(regBearDiv, "Regular Bearish FGI Divergence", "FGI Pro regular bearish divergence detected.")
alertcondition(hidBearDiv, "Hidden Bearish FGI Divergence", "FGI Pro hidden bearish divergence detected.")

plotchar(fgiR, "FGI Pro Index", "", location.top, color.new(color.gray, 100))
````
