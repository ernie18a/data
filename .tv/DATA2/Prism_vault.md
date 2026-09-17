<!-- tradingview-pine-id: PUB;9ae40d60c7d24f9284018e747c31d2ef -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Prism [vault]

Source: https://www.tradingview.com/script/n2lwjCfw-Prism-vault/

## Description

Prism [vault]

Prism takes eight independent reads of the market and fuses them into one confluence score. Instead of watching ten indicators and guessing which one matters, you get a single dashboard that tells you what the trend is, who is in control, where the liquidity sits and whether enough conditions line up to justify a trade.

How it works

Eight engines run on every bar. Each one votes bullish, bearish or neutral. The votes are counted and a signal fires only when one side clearly outweighs the other and the total score clears your threshold.

1. Momentum: Laguerre RSI, Fisher Transform, TSI, MFI, VFI, OBV and CMF blended into one normalized Momentum Index. Positive and rising = bullish vote.
2. Structure: supply and demand zones from volume-confirmed pivots, fair value gaps, mitigation tracking (wick, close or average fill). Price inside demand or above an FVG = bullish vote.
3. Wave: ALMA-smoothed momentum against five EMA basis levels. All basis levels aligned or momentum beyond 2 standard deviations = vote. Spread shows expansion or exhaustion.
4. Liquidity: buy side (BSL) and sell side (SSL) levels from swing points. A sweep is a wick through the level with a close back inside. Bullish sweep = bullish vote.
5. Trend matrix: Hull MA, SuperTrend, ADX, EMA 9/21/50 and SMA 100/200 combined into five regimes from Strong Bear to Strong Bull. Counter-trend setups (CTR dots) flag momentum turning against a weak trend at the Hull MA.
6. Divergence: price pivots checked against RSI, MACD, TSI and Stochastic. Regular divergence (solid line) needs at least two oscillators to agree. Hidden divergence drawn dashed.
7. Volatility: Bollinger inside Keltner = compression. Breakout direction on release becomes a vote. Volatility percentile ranks the regime as Low, Normal or High.
8. Flow: CMF, MFI, OBV and A/D tracked as a Flow Index with five phases from Strong Distribution to Strong Accumulation. Also feeds a sentiment gauge (Fear / Greed).

Two extra votes come from value (discount or premium relative to the 100-bar range) and volume surges on directional candles.

Signals

LONG fires when bullish votes reach the minimum score and beat bearish votes by at least the set margin, with price above the Hull MA. SHORT is the mirror. Strength: Weak (under 4), Moderate (4), Strong (5), Very Strong (6 to 7), Extreme (8+). A minimum bar gap between signals prevents clustering.

On the chart

- Hull MA colored by regime, SuperTrend band, gradient fill between them that gets denser as ADX rises
- SUP / DEM boxes, FVG boxes, BSL / SSL dashed levels
- Equilibrium line with discount and premium markers
- Optional candle coloring by flow phase or momentum
- Background tint for strong trends and compression
- Volume surge squares on the bottom

Dashboard

Three blocks: Context (trend, ADX, flow, volatility, value, structure), Engines (momentum, Laguerre, Fisher, CMF, MFI, wave, divergence, liquidity) and Confluence (score, sentiment). Live signal and strength sit in the header. Four color schemes, three text sizes, four positions.

How to trade it

1. Read Context first. Sideways plus Compression means wait for the breakout, do not chase.
2. Look for alignment: bullish trend, accumulation, discount value, price at demand.
3. Take LONG / SHORT labels only at Strong or better, and only in the direction of the higher timeframe.
4. Enter at the zone, stop beyond it, so risk is defined by structure not by feel.
5. Exit on the opposite signal or when Flow flips phase against you.

Alerts

Buy, Sell, Strong Bull, Strong Bear, Squeeze Breakout, Bullish Divergence, Bearish Divergence, Strong Accumulation, Strong Distribution, Bullish Sweep, Bearish Sweep, Extreme Greed, Extreme Fear.

Limits

Best on liquid instruments with real volume. On symbols without volume the flow and volume votes stay neutral, so max score drops. Signals describe current conditions, they do not predict. Use a stop every time.

Disclaimer

Educational tool, not financial advice. Trading carries substantial risk. Past signals do not guarantee future results. You are responsible for your own decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// Prism [vault] : 8 engine confluence system
//@version=6
indicator("Prism [vault]", "Prism [vault]", overlay = true, max_boxes_count = 200, max_lines_count = 200, max_labels_count = 300)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
gV = "Visual"
scheme      = input.string("Vault Mint", "Color scheme", ["Vault Mint", "Amber Ice", "Mono Ink", "Classic"], group = gV)
candleMode  = input.string("Flow phase", "Candle coloring", ["Off", "Flow phase", "Momentum"], group = gV)
showDash    = input.bool(true, "Dashboard", group = gV)
dashPos     = input.string("Top right", "Dashboard position", ["Top right", "Top left", "Bottom right", "Bottom left"], group = gV)
dashSize    = input.string("small", "Dashboard text size", ["tiny", "small", "normal"], group = gV)
showSig     = input.bool(true, "Signals", group = gV)
showCTR     = input.bool(true, "Counter-trend markers", group = gV)
showStruct  = input.bool(true, "Supply / demand / imbalance", group = gV)
showLiq     = input.bool(true, "Liquidity levels", group = gV)
showEq      = input.bool(true, "Equilibrium + premium/discount", group = gV)
showBg      = input.bool(true, "Trend / squeeze background", group = gV)
showEMAs    = input.bool(true, "EMA 9/21/50 layers", group = gV)
showDiv     = input.bool(true, "Divergence lines", group = gV)
showVolBars = input.bool(true, "Volume surge bars", group = gV)

gM = "1. Momentum engine"
momLen   = input.int(14, "Calculation period", 2, group = gM)
momSmooth= input.int(3, "Smoothing", 1, group = gM)
lagGamma = input.float(0.5, "Laguerre gamma", 0.1, 0.9, 0.05, group = gM)
fishLen  = input.int(10, "Fisher length", 2, group = gM)
mfiLen   = input.int(14, "Money flow period", 2, group = gM)

gS = "2. Structure engine"
stPiv    = input.int(10, "Detection period (pivot)", 2, group = gS)
maxZones = input.int(3, "Max supply/demand zones", 1, 10, group = gS)
maxImb   = input.int(4, "Max imbalance zones", 1, 10, group = gS)
mitMode  = input.string("Wick", "Zone break method", ["Wick", "Close", "Average"], group = gS)
showMit  = input.bool(false, "Show mitigated zones (faded)", group = gS)
valLen   = input.int(100, "Value range period", 20, group = gS)

gW = "3. Wave system"
wvLen    = input.int(10, "Momentum length", 2, group = gW)
almaOff  = input.float(0.85, "ALMA offset", 0, 1, 0.05, group = gW)
almaSig  = input.float(6, "ALMA sigma", 1, group = gW)
e1 = input.int(5, "EMA 1", 1, group = gW), e2 = input.int(8, "EMA 2", 1, group = gW), e3 = input.int(13, "EMA 3", 1, group = gW)
e4 = input.int(21, "EMA 4", 1, group = gW), e5 = input.int(34, "EMA 5", 1, group = gW)
wvSdLen  = input.int(50, "StDev length", 5, group = gW)
wvSdMult = input.float(2.0, "StDev multiplier", 0.5, group = gW)

gL = "4. Liquidity engine"
liqPiv   = input.int(8, "Pivot length", 2, group = gL)
volMult  = input.float(1.8, "Volume surge multiplier", 1.0, group = gL)
volLook  = input.int(20, "Volume lookback", 5, group = gL)
maxLiq   = input.int(6, "Max key levels", 1, 20, group = gL)
liqExt   = input.int(50, "Extension (bars)", 5, group = gL)

gT = "5. Trend matrix"
hullLen  = input.int(34, "Hull length", 2, group = gT)
atrLen   = input.int(10, "ATR period", 1, group = gT)
atrFac   = input.float(3.0, "ATR factor", 0.5, group = gT)
adxLen   = input.int(14, "ADX length", 2, group = gT)
adxSm    = input.int(14, "ADX smoothing", 2, group = gT)
adxThr   = input.float(25, "Strength threshold", 5, group = gT)
emaA = input.int(9, "EMA fast", 1, group = gT), emaB = input.int(21, "EMA mid", 1, group = gT), emaC = input.int(50, "EMA slow", 1, group = gT)
smaA = input.int(100, "SMA 1", 1, group = gT), smaB = input.int(200, "SMA 2", 1, group = gT)
gradLayers = input.int(6, "Gradient layers", 1, 12, group = gT)

gD = "6. Divergence engine"
dvL      = input.int(5, "Pivot left", 1, group = gD)
dvR      = input.int(5, "Pivot right", 1, group = gD)
dvMax    = input.int(60, "Max lookback", 10, group = gD)
dvMin    = input.int(5, "Min lookback", 1, group = gD)
rsiLen   = input.int(14, "RSI length", 2, group = gD)
macF = input.int(12, "MACD fast", 1, group = gD), macS = input.int(26, "MACD slow", 1, group = gD), macSig = input.int(9, "MACD signal", 1, group = gD)
tsiL = input.int(25, "TSI long", 1, group = gD), tsiS = input.int(13, "TSI short", 1, group = gD)
stoK = input.int(14, "Stoch K", 1, group = gD), stoD = input.int(3, "Stoch D", 1, group = gD)
dvMinConf= input.int(2, "Min confluence (oscillators)", 1, 4, group = gD)

gVo = "7. Volatility engine"
vAtrLen  = input.int(14, "ATR length", 1, group = gVo)
bbLen = input.int(20, "BB length", 2, group = gVo), bbMult = input.float(2.0, "BB multiplier", 0.5, group = gVo)
kcLen = input.int(20, "KC length", 2, group = gVo), kcMult = input.float(1.5, "KC multiplier", 0.5, group = gVo)
hvLen    = input.int(20, "Historical vol length", 2, group = gVo)
lowVolP  = input.float(25, "Low vol percentile", 1, 50, group = gVo)
highVolP = input.float(75, "High vol percentile", 50, 99, group = gVo)

gF = "8. Flow tracker"
cmfLen   = input.int(20, "Flow period (CMF)", 2, group = gF)
fMfiLen  = input.int(14, "Money flow period", 2, group = gF)
volMaLen = input.int(20, "Volume MA period", 2, group = gF)
showFG   = input.bool(true, "Sentiment index in dashboard", group = gF)

gSig = "Signals"
minConf  = input.int(4, "Min confluence score", 2, 10, group = gSig)
minEdge  = input.int(2, "Min bull/bear difference", 1, 10, group = gSig)
sigGap   = input.int(5, "Min bars between signals", 0, group = gSig)

// ─────────────────────────────────────────────────────────────
// COLOR SCHEME
// ─────────────────────────────────────────────────────────────
cBull = scheme == "Vault Mint" ? color.new(#16f0a3, 0) : scheme == "Amber Ice" ? color.new(#7ad7ff, 0) : scheme == "Mono Ink" ? color.new(#f2f2f2, 0) : color.new(#26a69a, 0)
cBear = scheme == "Vault Mint" ? color.new(#ff5c7a, 0) : scheme == "Amber Ice" ? color.new(#ffb84d, 0) : scheme == "Mono Ink" ? color.new(#8a8a8a, 0) : color.new(#ef5350, 0)
cNeu  = scheme == "Vault Mint" ? color.new(#6b7a90, 0) : scheme == "Amber Ice" ? color.new(#8c96a8, 0) : scheme == "Mono Ink" ? color.new(#4d4d4d, 0) : color.new(#787b86, 0)
cImb  = scheme == "Vault Mint" ? color.new(#ffb84d, 0) : scheme == "Amber Ice" ? color.new(#c792ea, 0) : scheme == "Mono Ink" ? color.new(#bdbdbd, 0) : color.new(#5c6bc0, 0)
cBg   = color.new(#0d1117, 0)
cGrid = color.new(#22283a, 0)

// ─────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────
atr     = ta.atr(vAtrLen)
volMa   = ta.sma(volume, volLook)
volSurge= volume > volMa * volMult
hasVol  = not na(volume) and volume > 0

// ─────────────────────────────────────────────────────────────
// 1. MOMENTUM ENGINE
// ─────────────────────────────────────────────────────────────
// Laguerre RSI
var float L0 = 0.
var float L1 = 0.
var float L2 = 0.
var float L3 = 0.
L0 := (1 - lagGamma) * close + lagGamma * nz(L0[1])
L1 := -lagGamma * L0 + nz(L0[1]) + lagGamma * nz(L1[1])
L2 := -lagGamma * L1 + nz(L1[1]) + lagGamma * nz(L2[1])
L3 := -lagGamma * L2 + nz(L2[1]) + lagGamma * nz(L3[1])
cu = (L0 > L1 ? L0 - L1 : 0) + (L1 > L2 ? L1 - L2 : 0) + (L2 > L3 ? L2 - L3 : 0)
cd = (L0 < L1 ? L1 - L0 : 0) + (L1 < L2 ? L2 - L1 : 0) + (L2 < L3 ? L3 - L2 : 0)
lagRsi = cu + cd == 0 ? 0.5 : cu / (cu + cd)

// Fisher transform
fHi = ta.highest(hl2, fishLen)
fLo = ta.lowest(hl2, fishLen)
var float fVal = 0.
fRaw = fHi - fLo == 0 ? 0 : 2 * ((hl2 - fLo) / (fHi - fLo) - 0.5)
fVal := math.max(math.min(0.66 * fRaw + 0.67 * nz(fVal[1]), 0.999), -0.999)
var float fish = 0.
fish := 0.5 * math.log((1 + fVal) / (1 - fVal)) + 0.5 * nz(fish[1])

// TSI, MFI, VFI-style, OBV / AD slope
tsiV  = ta.tsi(close, tsiS, tsiL)
mfiV  = ta.mfi(hlc3, mfiLen)
vfi   = ta.sma((close > close[1] ? 1 : close < close[1] ? -1 : 0) * volume, momLen) / math.max(volMa, 1)
obvSl = ta.change(ta.obv, 3) / math.max(ta.stdev(ta.change(ta.obv), 50), 1)
adSl  = ta.change(ta.accdist, 3) / math.max(ta.stdev(ta.change(ta.accdist), 50), 1)
mfv   = high == low ? 0 : ((close - low) - (high - close)) / (high - low) * volume
cmf   = math.sum(mfv, cmfLen) / math.max(math.sum(volume, cmfLen), 1)

momRaw = (lagRsi - 0.5) * 60 + fish * 15 + tsiV * 0.6 + (mfiV - 50) * 0.3 + (hasVol ? vfi * 10 + obvSl * 5 + adSl * 5 + cmf * 30 : 0)
momIdx = ta.ema(momRaw, momSmooth)
momUp  = momIdx > 0 and momIdx > momIdx[1]
momDn  = momIdx < 0 and momIdx < momIdx[1]

// ─────────────────────────────────────────────────────────────
// 5. TREND MATRIX (needed early for other engines)
// ─────────────────────────────────────────────────────────────
hull = ta.hma(close, hullLen)
[stLine, stDir] = ta.supertrend(atrFac, atrLen)
[diP, diM, adx] = ta.dmi(adxLen, adxSm)
emA = ta.ema(close, emaA)
emB = ta.ema(close, emaB)
emC = ta.ema(close, emaC)
smA = ta.sma(close, smaA)
smB = ta.sma(close, smaB)
emaBull = emA > emB and emB > emC
emaBear = emA < emB and emB < emC
hullUp = hull > hull[2]
trendScore = (hullUp ? 1 : -1) + (stDir < 0 ? 1 : -1) + (emaBull ? 1 : emaBear ? -1 : 0) + (close > smA ? 0.5 : -0.5) + (close > smB ? 0.5 : -0.5)
strongTrend = adx > adxThr
trendState = trendScore >= 2 and strongTrend ? 2 : trendScore >= 1 ? 1 : trendScore <= -2 and strongTrend ? -2 : trendScore <= -1 ? -1 : 0
trendTxt = trendState == 2 ? "STRONG BULL" : trendState == 1 ? "WEAK BULL" : trendState == -2 ? "STRONG BEAR" : trendState == -1 ? "WEAK BEAR" : "SIDEWAYS"
trendCol = trendState > 0 ? cBull : trendState < 0 ? cBear : cNeu

// counter-trend setups
ctrBull = trendState < 0 and momIdx > momIdx[1] and momIdx[1] > momIdx[2] and close > hull and close[1] <= hull[1]
ctrBear = trendState > 0 and momIdx < momIdx[1] and momIdx[1] < momIdx[2] and close < hull and close[1] >= hull[1]

// ─────────────────────────────────────────────────────────────
// 2. STRUCTURE ENGINE — supply / demand / FVG / equilibrium
// ─────────────────────────────────────────────────────────────
var supply = array.new<box>()
var demand = array.new<box>()
var imbs = array.new<box>()
var supplyLbl = array.new<label>()
var demandLbl = array.new<label>()
var imbLbl = array.new<label>()

f_mit(bx, isBull) =>
    float t = box.get_top(bx)
    float b = box.get_bottom(bx)
    isBull ? (mitMode == "Wick" ? low < b : mitMode == "Close" ? close < b : close < (t + b) / 2) : (mitMode == "Wick" ? high > t : mitMode == "Close" ? close > t : close > (t + b) / 2)

f_manage(arr, lblArr, isBull) =>
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            bx = array.get(arr, i)
            if f_mit(bx, isBull)
                lb = array.get(lblArr, i)
                array.remove(arr, i)
                array.remove(lblArr, i)
                if showMit
                    box.set_bgcolor(bx, color.new(isBull ? cBull : cBear, 94))
                    box.set_border_color(bx, color.new(isBull ? cBull : cBear, 85))
                    box.set_right(bx, bar_index)
                else
                    box.delete(bx)
                    label.delete(lb)
            else
                box.set_right(bx, bar_index + 1)

f_push(arr, lblArr, bx, lb, mx) =>
    array.push(arr, bx)
    array.push(lblArr, lb)
    if array.size(arr) > mx
        box.delete(array.shift(arr))
        label.delete(array.shift(lblArr))

ph = ta.pivothigh(high, stPiv, stPiv)
pl = ta.pivotlow(low, stPiv, stPiv)
volOk = not hasVol or volume[stPiv] > volMa[stPiv]
if showStruct
    f_manage(supply, supplyLbl, false)
    f_manage(demand, demandLbl, true)
    // imbalance mitigated once fully filled
    if array.size(imbs) > 0
        for i = array.size(imbs) - 1 to 0
            bx = array.get(imbs, i)
            filled = low < box.get_bottom(bx) and high > box.get_top(bx)
            if filled
                lb = array.get(imbLbl, i)
                array.remove(imbs, i)
                array.remove(imbLbl, i)
                box.delete(bx)
                label.delete(lb)
            else
                box.set_right(bx, bar_index + 1)
    if not na(ph) and volOk
        t = high[stPiv]
        b = math.max(math.min(open[stPiv], close[stPiv]), high[stPiv] - atr)
        bx = box.new(bar_index - stPiv, t, bar_index + 1, b, border_color = color.new(cBear, 40), bgcolor = color.new(cBear, 80))
        lb = label.new(bar_index - stPiv, t, "SUP", style = label.style_label_down, color = cBear, textcolor = color.white, size = size.tiny)
        f_push(supply, supplyLbl, bx, lb, maxZones)
    if not na(pl) and volOk
        b = low[stPiv]
        t = math.min(math.max(open[stPiv], close[stPiv]), low[stPiv] + atr)
        bx = box.new(bar_index - stPiv, t, bar_index + 1, b, border_color = color.new(cBull, 40), bgcolor = color.new(cBull, 80))
        lb = label.new(bar_index - stPiv, b, "DEM", style = label.style_label_up, color = cBull, textcolor = color.black, size = size.tiny)
        f_push(demand, demandLbl, bx, lb, maxZones)
    // fair value gaps
    if low > high[2] and close[1] > open[1]
        bx = box.new(bar_index - 2, low, bar_index + 1, high[2], border_color = color.new(cImb, 50), bgcolor = color.new(cImb, 82), border_style = line.style_dashed)
        lb = label.new(bar_index - 2, (low + high[2]) / 2, "FVG", style = label.style_label_right, color = cImb, textcolor = color.white, size = size.tiny)
        f_push(imbs, imbLbl, bx, lb, maxImb)
    if high < low[2] and close[1] < open[1]
        bx = box.new(bar_index - 2, low[2], bar_index + 1, high, border_color = color.new(cImb, 50), bgcolor = color.new(cImb, 82), border_style = line.style_dashed)
        lb = label.new(bar_index - 2, (high + low[2]) / 2, "FVG", style = label.style_label_right, color = cImb, textcolor = color.white, size = size.tiny)
        f_push(imbs, imbLbl, bx, lb, maxImb)

// active structure test (price inside a zone)
f_inside(arr) =>
    r = false
    if array.size(arr) > 0
        for bx in arr
            if close <= box.get_top(bx) and close >= box.get_bottom(bx)
                r := true
    r
inDemand = f_inside(demand)
inSupply = f_inside(supply)
imbBull = array.size(imbs) > 0 and close > box.get_top(array.last(imbs))
imbBear = array.size(imbs) > 0 and close < box.get_bottom(array.last(imbs))
structTxt = inDemand ? "IN DEMAND" : inSupply ? "IN SUPPLY" : imbBull ? "ABOVE FVG" : imbBear ? "BELOW FVG" : "CLEAR"

// equilibrium / value zone
rngHi = ta.highest(high, valLen)
rngLo = ta.lowest(low, valLen)
eq = (rngHi + rngLo) / 2
valPct = (close - rngLo) / math.max(rngHi - rngLo, syminfo.mintick)
valTxt = valPct > 0.85 ? "EXTREME HIGH" : valPct > 0.6 ? "HIGH" : valPct < 0.15 ? "EXTREME LOW" : valPct < 0.4 ? "LOW" : "FAIR VALUE"
discount = valPct < 0.4
premium = valPct > 0.6
plot(showEq ? eq : na, "Equilibrium", color.new(cNeu, 30), 1, plot.style_linebr)
plot(showEq ? rngLo + (rngHi - rngLo) * 0.25 : na, "Discount", color.new(cBull, 70), 1, plot.style_circles)
plot(showEq ? rngLo + (rngHi - rngLo) * 0.75 : na, "Premium", color.new(cBear, 70), 1, plot.style_circles)

// ─────────────────────────────────────────────────────────────
// 3. WAVE SYSTEM
// ─────────────────────────────────────────────────────────────
wvMom = ta.alma(ta.change(close, wvLen) / math.max(atr, syminfo.mintick) * 10, wvLen, almaOff, almaSig)
we1 = ta.ema(wvMom, e1)
we2 = ta.ema(wvMom, e2)
we3 = ta.ema(wvMom, e3)
we4 = ta.ema(wvMom, e4)
we5 = ta.ema(wvMom, e5)
b1 = (we1 + we2) / 2
b2 = (we2 + we3) / 2
b3 = (we3 + we4) / 2
b4 = (we4 + we5) / 2
waveAllBull = wvMom > b1 and wvMom > b2 and wvMom > b3 and wvMom > b4
waveAllBear = wvMom < b1 and wvMom < b2 and wvMom < b3 and wvMom < b4
wBasis = (b1 + b2 + b3 + b4) / 4
wSd = ta.stdev(wBasis, wvSdLen)
waveExtBull = wvMom > wBasis + wSd * wvSdMult
waveExtBear = wvMom < wBasis - wSd * wvSdMult
spread = b1 - b4
waveTxt = waveAllBull ? "ALL BULL" : waveAllBear ? "ALL BEAR" : "MIXED"

// ─────────────────────────────────────────────────────────────
// 4. LIQUIDITY ENGINE
// ─────────────────────────────────────────────────────────────
var bsl = array.new<line>()
var ssl = array.new<line>()
var bslL = array.new<label>()
var sslL = array.new<label>()
lph = ta.pivothigh(high, liqPiv, liqPiv)
lpl = ta.pivotlow(low, liqPiv, liqPiv)
sweepBull = false
sweepBear = false

f_liq(arr, lblArr, isBuy) =>
    swept = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            ln = array.get(arr, i)
            lvl = line.get_y1(ln)
            hit = isBuy ? high > lvl : low < lvl
            if hit
                rev = isBuy ? close < lvl : close > lvl
                if rev
                    swept := true
                array.remove(arr, i)
                array.remove(lblArr, i)
                line.set_x2(ln, bar_index)
                line.set_style(ln, line.style_dotted)
            else
                line.set_x2(ln, bar_index + liqExt)
                label.set_x(array.get(lblArr, i), bar_index + liqExt)
    swept

if showLiq
    sweepBear := f_liq(bsl, bslL, true)
    sweepBull := f_liq(ssl, sslL, false)
    if not na(lph)
        ln = line.new(bar_index - liqPiv, lph, bar_index + liqExt, lph, color = color.new(cBear, 35), style = line.style_dashed, width = 1)
        lb = label.new(bar_index + liqExt, lph, "BSL", style = label.style_label_left, color = color.new(cBear, 20), textcolor = color.white, size = size.tiny)
        array.push(bsl, ln)
        array.push(bslL, lb)
        if array.size(bsl) > maxLiq
            line.delete(array.shift(bsl))
            label.delete(array.shift(bslL))
    if not na(lpl)
        ln = line.new(bar_index - liqPiv, lpl, bar_index + liqExt, lpl, color = color.new(cBull, 35), style = line.style_dashed, width = 1)
        lb = label.new(bar_index + liqExt, lpl, "SSL", style = label.style_label_left, color = color.new(cBull, 20), textcolor = color.black, size = size.tiny)
        array.push(ssl, ln)
        array.push(sslL, lb)
        if array.size(ssl) > maxLiq
            line.delete(array.shift(ssl))
            label.delete(array.shift(sslL))

// ─────────────────────────────────────────────────────────────
// 6. DIVERGENCE ENGINE
// ─────────────────────────────────────────────────────────────
rsiV = ta.rsi(close, rsiLen)
[macdL, _s, _h] = ta.macd(close, macF, macS, macSig)
stoV = ta.sma(ta.stoch(close, high, low, stoK), stoD)
oscArr = array.from(rsiV, macdL, tsiV, stoV)

dPh = ta.pivothigh(high, dvL, dvR)
dPl = ta.pivotlow(low, dvL, dvR)
var int lastPlBar = na
var float lastPl = na
var float o1L = na
var float o2L = na
var float o3L = na
var float o4L = na
var int lastPhBar = na
var float lastPh = na
var float o1H = na
var float o2H = na
var float o3H = na
var float o4H = na
regBullDiv = false
regBearDiv = false
hidBullDiv = false
hidBearDiv = false
divTxt = "NONE"

if not na(dPl)
    r1 = rsiV[dvR]
    r2 = macdL[dvR]
    r3 = tsiV[dvR]
    r4 = stoV[dvR]
    if not na(lastPlBar) and bar_index - dvR - lastPlBar >= dvMin and bar_index - dvR - lastPlBar <= dvMax
        regC = (dPl < lastPl and r1 > o1L ? 1 : 0) + (dPl < lastPl and r2 > o2L ? 1 : 0) + (dPl < lastPl and r3 > o3L ? 1 : 0) + (dPl < lastPl and r4 > o4L ? 1 : 0)
        hidC = (dPl > lastPl and r1 < o1L ? 1 : 0) + (dPl > lastPl and r2 < o2L ? 1 : 0) + (dPl > lastPl and r3 < o3L ? 1 : 0) + (dPl > lastPl and r4 < o4L ? 1 : 0)
        regBullDiv := regC >= dvMinConf
        hidBullDiv := hidC >= dvMinConf
        if showDiv and (regBullDiv or hidBullDiv)
            line.new(lastPlBar, lastPl, bar_index - dvR, dPl, color = cBull, width = 2, style = regBullDiv ? line.style_solid : line.style_dashed)
    lastPlBar := bar_index - dvR
    lastPl := dPl
    o1L := r1
    o2L := r2
    o3L := r3
    o4L := r4
if not na(dPh)
    r1 = rsiV[dvR]
    r2 = macdL[dvR]
    r3 = tsiV[dvR]
    r4 = stoV[dvR]
    if not na(lastPhBar) and bar_index - dvR - lastPhBar >= dvMin and bar_index - dvR - lastPhBar <= dvMax
        regC = (dPh > lastPh and r1 < o1H ? 1 : 0) + (dPh > lastPh and r2 < o2H ? 1 : 0) + (dPh > lastPh and r3 < o3H ? 1 : 0) + (dPh > lastPh and r4 < o4H ? 1 : 0)
        hidC = (dPh < lastPh and r1 > o1H ? 1 : 0) + (dPh < lastPh and r2 > o2H ? 1 : 0) + (dPh < lastPh and r3 > o3H ? 1 : 0) + (dPh < lastPh and r4 > o4H ? 1 : 0)
        regBearDiv := regC >= dvMinConf
        hidBearDiv := hidC >= dvMinConf
        if showDiv and (regBearDiv or hidBearDiv)
            line.new(lastPhBar, lastPh, bar_index - dvR, dPh, color = cBear, width = 2, style = regBearDiv ? line.style_solid : line.style_dashed)
    lastPhBar := bar_index - dvR
    lastPh := dPh
    o1H := r1
    o2H := r2
    o3H := r3
    o4H := r4
divTxt := regBullDiv ? "BULL DIV" : regBearDiv ? "BEAR DIV" : hidBullDiv ? "HID BULL" : hidBearDiv ? "HID BEAR" : "NONE"
divActiveBull = ta.barssince(regBullDiv) <= dvR + 2
divActiveBear = ta.barssince(regBearDiv) <= dvR + 2

// ─────────────────────────────────────────────────────────────
// 7. VOLATILITY ENGINE
// ─────────────────────────────────────────────────────────────
bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen) * bbMult
kcBasis = ta.ema(close, kcLen)
kcRange = ta.atr(kcLen) * kcMult
squeeze = bbBasis + bbDev < kcBasis + kcRange and bbBasis - bbDev > kcBasis - kcRange
hv = ta.stdev(math.log(close / close[1]), hvLen) * math.sqrt(252) * 100
volIdx = (atr / close * 100) * 0.4 + (bbDev * 2 / close * 100) * 0.3 + hv * 0.003
volPct = ta.percentrank(volIdx, 100)
sqBreakUp = squeeze[1] and not squeeze and close > kcBasis
sqBreakDn = squeeze[1] and not squeeze and close < kcBasis
volTxt = squeeze ? "COMPRESSION" : volPct > highVolP ? "HIGH" : volPct < lowVolP ? "LOW" : "NORMAL"
volCol = squeeze ? cImb : volPct > highVolP ? cBear : volPct < lowVolP ? cBull : color.new(#ffb300, 0)

// ─────────────────────────────────────────────────────────────
// 8. FLOW TRACKER
// ─────────────────────────────────────────────────────────────
fMfi = ta.mfi(hlc3, fMfiLen)
obvUp = ta.obv > ta.ema(ta.obv, 10)
adUp = ta.accdist > ta.ema(ta.accdist, 10)
flowIdx = cmf * 100 * 0.4 + (fMfi - 50) * 0.4 + (obvUp ? 10 : -10) + (adUp ? 10 : -10)
flowIdx := ta.ema(flowIdx, 3)
flowVel = ta.change(flowIdx)
flowAcc = ta.change(flowVel)
flowPhase = flowIdx > 25 ? 2 : flowIdx > 8 ? 1 : flowIdx < -25 ? -2 : flowIdx < -8 ? -1 : 0
flowTxt = flowPhase == 2 ? "STRONG ACCUM" : flowPhase == 1 ? "ACCUMULATION" : flowPhase == -2 ? "STRONG DISTRIB" : flowPhase == -1 ? "DISTRIBUTION" : "NEUTRAL"
buyPress  = cmf > 0 and fMfi > 50 and obvUp and volSurge
sellPress = cmf < 0 and fMfi < 50 and not obvUp and volSurge
cmfTxt = cmf > 0.15 ? "STRONG +" : cmf > 0 ? "POSITIVE" : cmf < -0.15 ? "STRONG -" : "NEGATIVE"

// fear & greed
fgVol = 100 - volPct
fgMom = math.min(math.max(50 + momIdx, 0), 100)
fgDist = math.min(math.max(50 + (close - smB) / math.max(atr, syminfo.mintick) * 5, 0), 100)
fgVolu = hasVol ? math.min(math.max(50 + (volume / math.max(volMa, 1) - 1) * 50 * (close > open ? 1 : -1), 0), 100) : 50
fg = (fgVol * 0.2 + fgMom * 0.3 + fgDist * 0.2 + fgVolu * 0.1 + rsiV * 0.2)
fgTxt = fg > 75 ? "EXTREME GREED" : fg > 58 ? "GREED" : fg < 25 ? "EXTREME FEAR" : fg < 42 ? "FEAR" : "NEUTRAL"

// ─────────────────────────────────────────────────────────────
// CONFLUENCE + SIGNALS
// ─────────────────────────────────────────────────────────────
bullCnt = (momUp ? 1 : 0) + (inDemand or imbBull ? 1 : 0) + (waveAllBull or waveExtBull ? 1 : 0) + (sweepBull ? 1 : 0) + (trendState > 0 or ctrBull ? 1 : 0) + (divActiveBull ? 1 : 0) + (sqBreakUp ? 1 : 0) + (flowPhase > 0 or buyPress ? 1 : 0) + (discount and trendState >= 0 ? 1 : 0) + (volSurge and close > open ? 1 : 0)
bearCnt = (momDn ? 1 : 0) + (inSupply or imbBear ? 1 : 0) + (waveAllBear or waveExtBear ? 1 : 0) + (sweepBear ? 1 : 0) + (trendState < 0 or ctrBear ? 1 : 0) + (divActiveBear ? 1 : 0) + (sqBreakDn ? 1 : 0) + (flowPhase < 0 or sellPress ? 1 : 0) + (premium and trendState <= 0 ? 1 : 0) + (volSurge and close < open ? 1 : 0)
score = math.max(bullCnt, bearCnt)
strTxt = score >= 8 ? "EXTREME" : score >= 6 ? "VERY STRONG" : score >= 5 ? "STRONG" : score >= 4 ? "MODERATE" : "WEAK"

var int lastSigBar = -1000
rawBuy  = bullCnt >= minConf and bullCnt - bearCnt >= minEdge and close > hull
rawSell = bearCnt >= minConf and bearCnt - bullCnt >= minEdge and close < hull
buySig  = rawBuy and not rawBuy[1] and bar_index - lastSigBar > sigGap
sellSig = rawSell and not rawSell[1] and bar_index - lastSigBar > sigGap
if buySig or sellSig
    lastSigBar := bar_index
sigTxt = buySig ? "BUY SIGNAL" : sellSig ? "SELL SIGNAL" : rawBuy ? "BUY ACTIVE" : rawSell ? "SELL ACTIVE" : "NO SIGNAL"
mktStruct = trendScore + (flowPhase > 0 ? 1 : flowPhase < 0 ? -1 : 0) > 0.5 ? "BULLISH" : trendScore + (flowPhase > 0 ? 1 : flowPhase < 0 ? -1 : 0) < -0.5 ? "BEARISH" : "NEUTRAL"

// ─────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────
hullCol = trendState > 0 ? cBull : trendState < 0 ? cBear : hullUp ? color.new(cBull, 40) : color.new(cBear, 40)
pHull = plot(hull, "Hull MA", hullCol, 3)
pST   = plot(stLine, "SuperTrend", color.new(stDir < 0 ? cBull : cBear, 60), 1)
// gradient fill between Hull and SuperTrend, opacity by ADX strength
gradAlpha = math.round(math.max(math.min(95 - adx, 92), 60))
fill(pHull, pST, color.new(stDir < 0 ? cBull : cBear, gradAlpha), "Trend gradient")
plot(showEMAs ? emA : na, "EMA 9", color.new(cNeu, 55), 1)
plot(showEMAs ? emB : na, "EMA 21", color.new(cNeu, 70), 1)
plot(showEMAs ? emC : na, "EMA 50", color.new(cNeu, 82), 1)

bgcolor(showBg and squeeze ? color.new(cImb, 82) : showBg and trendState == 2 ? color.new(cBull, 88) : showBg and trendState == -2 ? color.new(cBear, 88) : na, title = "Regime background")

plotshape(showSig and buySig, "Buy", shape.labelup, location.belowbar, cBull, text = "LONG", textcolor = color.black, size = size.small)
plotshape(showSig and sellSig, "Sell", shape.labeldown, location.abovebar, cBear, text = "SHORT", textcolor = color.white, size = size.small)
plotshape(showCTR and ctrBull, "CTR bull", shape.circle, location.belowbar, color.new(cBull, 30), size = size.tiny)
plotshape(showCTR and ctrBear, "CTR bear", shape.circle, location.abovebar, color.new(cBear, 30), size = size.tiny)
barcolor(candleMode == "Flow phase" ? (flowPhase > 0 ? cBull : flowPhase < 0 ? cBear : cNeu) : candleMode == "Momentum" ? (momIdx > 0 ? cBull : cBear) : na, title = "Candle coloring")
plotshape(showVolBars and volSurge, "Volume surge", shape.square, location.bottom, color.new(close > open ? cBull : cBear, 30), size = size.tiny)

// ─────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────
pos = dashPos == "Top right" ? position.top_right : dashPos == "Top left" ? position.top_left : dashPos == "Bottom right" ? position.bottom_right : position.bottom_left
tsz = dashSize == "tiny" ? size.tiny : dashSize == "small" ? size.small : size.normal
var table dash = table.new(pos, 4, 12, bgcolor = cBg, border_width = 1, border_color = cGrid, frame_color = cGrid, frame_width = 1)

f_cell(c, r, k, v, col) =>
    table.cell(dash, c, r, k, text_color = color.new(cNeu, 0), text_size = tsz, bgcolor = cBg, text_halign = text.align_left)
    table.cell(dash, c + 1, r, v, text_color = col, text_size = tsz, bgcolor = color.new(col, 88), text_halign = text.align_right)

f_head(r, t) =>
    table.cell(dash, 0, r, t, text_color = cImb, text_size = tsz, bgcolor = color.new(cImb, 90), text_halign = text.align_left)
    table.merge_cells(dash, 0, r, 3, r)

if showDash and barstate.islast
    yel = color.new(#ffb300, 0)
    sigCol = str.contains(sigTxt, "BUY") ? cBull : str.contains(sigTxt, "SELL") ? cBear : cNeu
    table.cell(dash, 0, 0, "PRISM [vault]", text_color = color.white, text_size = tsz, bgcolor = cBg, text_halign = text.align_left)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 2, 0, sigTxt + "  |  " + strTxt, text_color = color.black, text_size = tsz, bgcolor = sigCol, text_halign = text.align_center)
    table.merge_cells(dash, 2, 0, 3, 0)
    f_head(1, "CONTEXT")
    f_cell(0, 2, "Trend", trendTxt, trendCol)
    f_cell(2, 2, "ADX", str.tostring(adx, "#.#"), strongTrend ? cBull : yel)
    f_cell(0, 3, "Flow", flowTxt, flowPhase > 0 ? cBull : flowPhase < 0 ? cBear : cNeu)
    f_cell(2, 3, "Volatility", volTxt, volCol)
    f_cell(0, 4, "Value", valTxt, valPct > 0.6 ? cBear : valPct < 0.4 ? cBull : yel)
    f_cell(2, 4, "Structure", structTxt, inDemand or imbBull ? cBull : inSupply or imbBear ? cBear : cNeu)
    f_head(5, "ENGINES")
    f_cell(0, 6, "Momentum", str.tostring(momIdx, "#.##"), momIdx > 0 ? cBull : cBear)
    f_cell(2, 6, "Laguerre", lagRsi > 0.8 ? "EXT +" : lagRsi < 0.2 ? "EXT -" : "NEUTRAL", lagRsi > 0.8 ? cBear : lagRsi < 0.2 ? cBull : cNeu)
    f_cell(0, 7, "Fisher", fish > 2 ? "EXTREME +" : fish > 0 ? "POSITIVE" : fish < -2 ? "EXTREME -" : "NEGATIVE", fish > 0 ? cBull : cBear)
    f_cell(2, 7, "CMF", cmfTxt, cmf > 0 ? cBull : cBear)
    f_cell(0, 8, "MFI", str.tostring(fMfi, "#.#"), fMfi > 80 ? cBear : fMfi < 20 ? cBull : yel)
    f_cell(2, 8, "Wave", waveTxt + " (" + str.tostring(spread, "#.#") + ")", waveAllBull ? cBull : waveAllBear ? cBear : cNeu)
    f_cell(0, 9, "Divergence", divTxt, str.contains(divTxt, "BULL") ? cBull : str.contains(divTxt, "BEAR") ? cBear : cNeu)
    f_cell(2, 9, "Liquidity", str.tostring(array.size(bsl)) + " BSL / " + str.tostring(array.size(ssl)) + " SSL", array.size(bsl) > array.size(ssl) ? cBull : array.size(bsl) < array.size(ssl) ? cBear : cNeu)
    f_head(10, "CONFLUENCE")
    f_cell(0, 11, "Score", str.tostring(bullCnt) + " BULL / " + str.tostring(bearCnt) + " BEAR", bullCnt > bearCnt ? cBull : bullCnt < bearCnt ? cBear : cNeu)
    f_cell(2, 11, showFG ? "Sentiment" : "Bias", showFG ? fgTxt : mktStruct, showFG ? (fg > 58 ? cBull : fg < 42 ? cBear : yel) : (mktStruct == "BULLISH" ? cBull : mktStruct == "BEARISH" ? cBear : cNeu))

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(buySig, "Buy Signal", "PRISM: BUY signal on {{ticker}} {{interval}}")
alertcondition(sellSig, "Sell Signal", "PRISM: SELL signal on {{ticker}} {{interval}}")
alertcondition(trendState == 2 and trendState[1] != 2, "Strong Bull Trend", "PRISM: Strong Bull regime {{ticker}}")
alertcondition(trendState == -2 and trendState[1] != -2, "Strong Bear Trend", "PRISM: Strong Bear regime {{ticker}}")
alertcondition(sqBreakUp or sqBreakDn, "Squeeze Breakout", "PRISM: squeeze breakout {{ticker}}")
alertcondition(regBullDiv, "Bullish Divergence", "PRISM: bullish divergence {{ticker}}")
alertcondition(regBearDiv, "Bearish Divergence", "PRISM: bearish divergence {{ticker}}")
alertcondition(flowPhase == 2 and flowPhase[1] != 2, "Strong Accumulation", "PRISM: strong accumulation {{ticker}}")
alertcondition(flowPhase == -2 and flowPhase[1] != -2, "Strong Distribution", "PRISM: strong distribution {{ticker}}")
alertcondition(sweepBull, "Bullish Liquidity Sweep", "PRISM: sell-side liquidity swept {{ticker}}")
alertcondition(sweepBear, "Bearish Liquidity Sweep", "PRISM: buy-side liquidity swept {{ticker}}")
alertcondition(fg > 75 and fg[1] <= 75, "Extreme Greed", "PRISM: extreme greed {{ticker}}")
alertcondition(fg < 25 and fg[1] >= 25, "Extreme Fear", "PRISM: extreme fear {{ticker}}")
````
