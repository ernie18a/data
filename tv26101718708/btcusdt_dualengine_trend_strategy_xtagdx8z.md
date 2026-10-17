# Btcusdt Dual-Engine Trend Strategy

- url: https://www.tradingview.com/script/XTAGdX8Z/
- type: strategy
- pine_id: PUB;290121de5df344218770530d8a177eca
- version: 1.0

## Description

This strategy was built and tuned primarily for BINANCE:BTCUSDT on the 1D chart.

It is a long-only dual-engine trend-following strategy. The script combines a trend/regime layer with a breakout-and-risk engine, then manages positions through ATR-based initial risk, adaptive trailing protection, and optional regime-aware exits.

How it works

The first layer is the regime engine. The script can run with the regime filter disabled, with a stricter EMA-based regime filter, or with a lighter mode. When enabled, the regime logic evaluates price location versus the regime EMA, optional EMA slope direction, optional ADX confirmation, and a softer scoring model based on distance from EMA, slope, range position, and reclaim behavior. This allows the strategy to separate stronger trend conditions from weaker or less reliable ones.

The second layer is the entry engine. The script can enter through several conditions:
1) breakout continuation above a prior high range,
2) pullback recovery after weakness below a faster EMA,
3) soft-regime reclaim entries when the softer regime model is constructive even if the stricter regime is not fully confirmed,
4) a capped reclaim setup below the fixed EMA200 reference.

Entries are placed as stop-style orders, so the strategy reacts when price actually reaches the trigger level rather than assuming a simple bar-close fill. This makes the script more sensitive to intrabar movement than close-only strategies.

Risk and position sizing

The script includes multiple position control layers. Exposure can be reduced automatically as strategy drawdown increases. Optional volatility targeting can adjust effective leverage using ATR%. Position size can also be capped by a stop-distance-based risk limit, while max exposure and fee reserve settings help keep sizing within defined limits.

Exit logic

Open positions are managed with an ATR-based initial stop and a monotonic trailing stop that tightens after sufficient favorable excursion. An optional breakeven rule can move protection to entry after a defined profit threshold. After a minimum holding period, the strategy can also use a Donchian-style exit. If regime exits are enabled, the script can additionally tighten or force exits when regime conditions deteriorate.

How to use

Start on BINANCE:BTCUSDT 1D with the default script settings before changing anything.
First calibrate trading costs and execution assumptions.
Then adjust exposure and risk controls.
Only after that should you tune signal-speed parameters such as breakout length, exit length, and trailing settings.

Inputs that matter most

commission_value
Use this to approximate your actual fee level.

slippage
Use this to approximate execution friction. If live fills are worse than TradingView fills, adjust this before touching the signal logic.

regimeMode, useSoftRegime, requireSlope
These define how strict the regime filter is and whether the script can use softer trend qualification.

useAdxFilter, adxMin
These reduce participation when trend strength is weak.

useAtrGuard, atrPctGuard
These can block entries during unstable volatility conditions.

ddStart, ddEnd, ddMinScale
These reduce exposure during equity drawdowns.

useVolTarget, volTargetPct, volMinLev, volMaxLev
These define the optional volatility-targeting layer.

maxExposurePct, entryPct, feeReservePct, useRiskCap, riskCapPct
These are the main capital allocation and position-risk controls.

entryLen, exitLen, addLen, pullbackPct, breakBufPct
These define the entry and exit speed and how the strategy reacts to breakout versus pullback recovery conditions.

initStopATR, trailBase, trailTight, tightenAtR, useBE, beR, minHoldBars
These define the protection and trailing behavior after entry.

Important notes

This is not a low-volatility or low-turnover script. It can still experience meaningful drawdowns, especially when trend persistence breaks down or execution quality is worse than assumed.

TradingView results may differ from live execution because of fees, slippage, intrabar behavior, data revisions, exchange-specific matching, and alert-to-execution differences.

The strategy includes some generic market-structure inputs such as daily limit handling and offline cost placeholders. For BTCUSDT, users should review whether those settings are relevant to their own venue before relying on results.

This script is provided for research and educational use only. It is not investment advice.

## Source Code

````pine
//@version=6
// Offline cost model:
// - buy fee  = commission + transfer fee
// - sell fee = commission + transfer fee + stamp duty
// - slippage = layered by order notional / equity using tiers: 20:1,60:2,200:4
// Pine approximates the above with averaged commission and fixed slippage.
strategy("BINANCE:BTCUSDT | G1 DUAL ENGINE ddfix 20260414",
     overlay=true,
     pyramiding=1,
     initial_capital=100000,
     commission_type=strategy.commission.percent,
     commission_value=0.1000,
     margin_long=100,
     slippage=4,
     process_orders_on_close=false,
     calc_on_order_fills=false,
     calc_on_every_tick=true)
lotShares = input.int(1, "A-share lot shares", minval=1)
roundToLot(shares) =>
    s = math.floor(shares)
    math.floor(s / lotShares) * lotShares
limitPct = input.float(1.00, "Daily limit (%)", minval=0.01, maxval=1.00, step=0.01)
sellStampDutyPct = input.float(0.0000, "Offline sell stamp duty (%)", minval=0.0, step=0.001)
transferFeePct = input.float(0.0000, "Offline transfer fee per side (%)", minval=0.0, step=0.0001)
offlineSlipTiers = input.string("20:1,60:2,200:4", "Offline slip tiers (exp%:ticks)")
blockEntryOnLimitUp  = input.bool(false,  "Block entry on limit-up")
blockExitOnLimitDown = input.bool(false, "Conservative: block exits on limit-down")
isLimitUp   = not na(close[1]) and close >= close[1] * (1 + limitPct - 0.001)
isLimitDown = not na(close[1]) and close <= close[1] * (1 - limitPct + 0.001)
canEnterBar = not (blockEntryOnLimitUp and isLimitUp)
canExitBar  = not (blockExitOnLimitDown and isLimitDown)
useHardDD = input.bool(false, "Hard max drawdown guard")
hardDDPct = input.float(14.5, "Hard max drawdown %", minval=1.0, maxval=50.0, step=0.1)
strategy.risk.max_drawdown(useHardDD ? hardDDPct : 100.0, strategy.percent_of_equity)
atr = ta.atr(14)
atrPct = atr / close * 100.0
ema200Ref = ta.ema(close, 200)
emaLen = input.int(200, "Regime EMA length", minval=20, maxval=200)
emaRegime = ta.ema(close, emaLen)
regimeMode = input.string("off", "Regime mode", options=["ema", "light", "off"])
useRegimeFilter = regimeMode != "off"
regimeLight = regimeMode == "light"
requireSlope = input.bool(false, "Require EMA slope up")
slopeBars    = input.int(23, "EMA slope lookback", minval=5, maxval=120)
emaUp        = emaRegime > emaRegime[slopeBars]
diLen = input.int(14, "DMI length", minval=5, maxval=50)
adxSmooth = input.int(14, "ADX smoothing", minval=5, maxval=50)
[pdi, mdi, adx] = ta.dmi(diLen, adxSmooth)
useAdxFilter = input.bool(false, "Use ADX filter")
adxMin       = input.float(20.66, "ADX min", minval=5, step=0.5)
useAtrGuard = input.bool(true, "ATR% guard")
atrPctGuard = input.float(20.54, "Block entry/add if ATR% >", minval=3.0, step=0.1)
atrOk = (not useAtrGuard) or (atrPct <= atrPctGuard)
clip01(x) => math.max(0.0, math.min(1.0, x))
useSoftRegime = input.bool(true, "Use soft regime gate")
softGateEnabled = useRegimeFilter and (useSoftRegime or regimeLight)
softEntryScore = input.float(0.52, "Soft regime entry score", minval=0.05, maxval=0.95, step=0.01)
softExitScore = input.float(0.37, "Soft regime exit score", minval=0.05, maxval=0.95, step=0.01)
softRecoveryMin = input.float(0.41, "Soft recovery floor", minval=0.05, maxval=0.95, step=0.01)
softBelowScale = input.float(0.65, "Soft below-EMA scale", minval=0.05, maxval=1.0, step=0.01)
softRangeLb = input.int(108, "Soft regime range lookback", minval=20, maxval=240)
softAtrMult = input.float(4.21, "Soft ATR band mult", minval=0.5, maxval=6.0, step=0.1)
var float peakEq = na
peakEq := na(peakEq) ? strategy.equity : math.max(peakEq, strategy.equity)
ddPct = peakEq > 0 ? (peakEq - strategy.equity) / peakEq * 100.0 : 0.0
ddStart = input.float(5.44, "DD scale start %", minval=0.5, step=0.5)
ddEnd   = input.float(16.55, "DD scale end %", minval=1.0, step=0.5)
ddMinScale = input.float(0.82, "Min scale", minval=0.1, maxval=1.0, step=0.01)
scaleDD = ddPct <= ddStart ? 1.0 : ddPct >= ddEnd ? ddMinScale : (1.0 - (ddPct - ddStart)/(ddEnd - ddStart) * (1.0 - ddMinScale))
useVolTarget = input.bool(false, "Volatility targeting")
volTargetPct = input.float(2.08, "Target ATR%", minval=0.5, step=0.1)
volMinLev = input.float(0.65, "Min lev", minval=0.1, maxval=3.0, step=0.01)
volMaxLev = input.float(1.96, "Max lev", minval=0.5, maxval=5.0, step=0.01)
lev = (useVolTarget and atrPct > 0) ? math.min(volMaxLev, math.max(volMinLev, volTargetPct/atrPct)) : 1.0
scale = scaleDD * lev
maxExposurePct = input.float(100.0, "Max exposure cap (% equity)", minval=10, maxval=250, step=5)
entryPct       = input.float(109.9, "Entry exposure (% equity)", minval=1, maxval=250, step=1)
feeReservePct  = input.float(0.120, "Fee+slip reserve (%)", minval=0.0, step=0.01)
useRiskCap = input.bool(true, "Risk cap sizing")
riskCapPct = input.float(12.19, "Max loss at stop (% equity)", minval=0.1, step=0.1)
qtyFromPct(pct, fillPrice) =>
    safeEq        = strategy.equity * math.max(0.0, 1.0 - feeReservePct/100.0)
    px            = na(fillPrice) or fillPrice <= 0 ? close : fillPrice
    clampedPct    = math.max(0.0, math.min(pct, 100.0))
    desiredValue  = safeEq * (clampedPct/100.0)
    desiredShares = desiredValue / px
    capValue      = safeEq * (maxExposurePct/100.0)
    capShares     = capValue / px
    cashCapShares = safeEq / px
    remainShares  = math.max(0.0, math.min(capShares, cashCapShares) - math.max(strategy.position_size, 0))
    roundToLot(math.min(desiredShares, remainShares))
riskCapShares(stopDist) =>
    raw = stopDist > 0 ? (strategy.equity * (riskCapPct/100.0) / stopDist) : 1e18
    roundToLot(raw)
breakBufPct  = input.float(0.00, "Breakout buffer %", minval=0.0, step=0.05)
cooldownBars = input.int(6, "Cooldown bars after exit", minval=0, maxval=200)
minHoldBars  = input.int(94, "Min hold bars before Donchian exit", minval=0, maxval=400)
var int lastExitBar = na
flatExit = (strategy.position_size==0) and (strategy.position_size[1]>0)
if flatExit
    lastExitBar := bar_index
coolOk = cooldownBars==0 ? (na(lastExitBar) or bar_index > lastExitBar) : (na(lastExitBar) or (bar_index-lastExitBar>=cooldownBars))
entryLen = input.int(35, "Entry breakout len", minval=8, maxval=400)
exitLen  = input.int(5,  "Exit breakout len", minval=4, maxval=280)
addLen   = input.int(109,   "Fast EMA len (pullback)", minval=5, maxval=160)
pullbackPct = input.float(1.44, "Pullback below fast EMA %", minval=0.0, step=0.1)
hiEntry = ta.highest(high, entryLen)[1]
loExit  = ta.lowest(low,  exitLen)[1]
emaFastEntry = ta.ema(close, addLen)
emaMidEntry = ta.ema(close, math.min(120, math.max(addLen + 4, addLen * 2)))
softRangeHi = ta.highest(high, softRangeLb)[1]
softRangeLo = ta.lowest(low, softRangeLb)[1]
rsiPull = ta.rsi(close, 14)
rsiEntryThr = math.max(24.0, math.min(45.0, 18.0 + 0.8 * adxMin))
breakLevel = not na(hiEntry) ? hiEntry * (1 + breakBufPct/100.0) : na
reclaimOk = not na(emaFastEntry) and close > emaFastEntry and ((close[1] <= emaFastEntry[1]) or (low[1] <= emaFastEntry[1]))
hardBull = close > emaRegime and (not requireSlope or emaUp) and (not useAdxFilter or adx >= adxMin)
softAtrRef = math.max(syminfo.mintick, atr * math.max(0.5, softAtrMult))
distScore = clip01(0.5 + 0.5 * (close - emaRegime) / softAtrRef)
slopeRef = nz(emaRegime[slopeBars], emaRegime)
slopeScore = clip01(0.5 + 1.8 * (emaRegime - slopeRef) / softAtrRef)
rangeSpan = (not na(softRangeHi) and not na(softRangeLo) and softRangeHi > softRangeLo) ? math.max(softRangeHi - softRangeLo, atr * 0.5, syminfo.mintick) : na
rangeScore = na(rangeSpan) ? distScore : clip01((close - softRangeLo) / rangeSpan)
fastScore = clip01(0.5 + 0.7 * (close - emaFastEntry) / math.max(syminfo.mintick, atr))
stackScore = emaFastEntry > emaMidEntry ? 1.0 : 0.0
reclaimScore = 0.65 * fastScore + 0.20 * stackScore + 0.15 * (reclaimOk ? 1.0 : 0.0)
softScore = clip01(0.35 * distScore + 0.20 * slopeScore + 0.25 * rangeScore + 0.20 * reclaimScore)
softRecovery = na(rangeSpan) ? 0.5 : clip01((close - softRangeLo) / rangeSpan)
softBull = softGateEnabled and softScore >= softEntryScore and softRecovery >= softRecoveryMin and close > emaFastEntry and (emaFastEntry > emaMidEntry or reclaimOk)
softBull := softBull and (not useAdxFilter or adx >= adxMin)
belowRegime = close < emaRegime
bullRegime = regimeMode == "off" ? true : regimeLight ? true : (hardBull or softBull)
softScale = regimeMode == "off" ? 1.0 : regimeLight and not belowRegime ? 1.0 : hardBull ? 1.0 : softScore < softEntryScore ? 0.0 : clip01(softBelowScale + (softScore - softEntryScore) / math.max(0.0001, 1.0 - softEntryScore) * (1.0 - softBelowScale))
scale := scale * softScale
breakSetup = bullRegime and atrOk and coolOk and canEnterBar and not na(breakLevel)
pullPrev = bullRegime[1] and rsiPull[1] < rsiEntryThr and close[1] < emaFastEntry[1] * (1 - pullbackPct/100.0)
pullSetup = bullRegime and atrOk and coolOk and canEnterBar and pullPrev and close > close[1]
softReclaimSetup = useRegimeFilter and softGateEnabled and softBull and not hardBull and atrOk and coolOk and canEnterBar and reclaimOk and close >= close[1]
belowEMA200SoftSetup = useRegimeFilter and softGateEnabled and softBull and close < ema200Ref and atrOk and coolOk and canEnterBar and reclaimOk and close >= close[1]
entryStopLevel = breakSetup ? breakLevel : na
entryStopLevel := pullSetup and not na(emaFastEntry) ? (na(entryStopLevel) ? emaFastEntry : math.min(entryStopLevel, emaFastEntry)) : entryStopLevel
softReclaimLevel = math.max(math.max(close, emaFastEntry), high[1]) * (1 + math.max(0.0005, breakBufPct/100.0 * 0.35))
entryStopLevel := softReclaimSetup and not na(emaFastEntry) ? (na(entryStopLevel) ? softReclaimLevel : math.min(entryStopLevel, softReclaimLevel)) : entryStopLevel
belowEMA200ReclaimRaw = math.max(math.max(close, emaFastEntry), high[1]) * (1 + math.max(0.0005, breakBufPct/100.0 * 0.20))
belowEMA200Cap = ema200Ref * (1 - math.max(0.0010, breakBufPct/100.0 * 0.25))
belowEMA200ReclaimLevel = math.min(belowEMA200ReclaimRaw, belowEMA200Cap)
entryStopLevel := belowEMA200SoftSetup and not na(emaFastEntry) ? (na(entryStopLevel) ? belowEMA200ReclaimLevel : math.min(entryStopLevel, belowEMA200ReclaimLevel)) : entryStopLevel
entrySignal = not na(entryStopLevel) and high >= entryStopLevel
initStopATR = input.float(1.20, "Init stop ATR mult", minval=0.5, step=0.1)
trailBase   = input.float(19.68, "Trail ATR mult (base)", minval=1.0, step=0.1)
trailTight  = input.float(15.84, "Trail ATR mult (tight)", minval=1.0, step=0.1)
tightenAtR  = input.float(6.17, "Tighten after MFE >= R", minval=0.5, step=0.1)
useBE = input.bool(false, "Breakeven after +R")
beR   = input.float(3.25, "BE trigger (R)", minval=0.2, step=0.1)
useRegimeExit = input.bool(false, "Regime exit (close < EMA)")
inPos = strategy.position_size > 0
avg   = strategy.position_avg_price
var float entryStopDist = na
var float hhSince = na
var float trailMono = na
var int entryBar = na
var int lastFilledEntryBar = na
var float effStopPlot = na
newPos = (strategy.position_size > 0) and (strategy.position_size[1] <= 0)
if newPos
    entryStopDist := initStopATR * atr
    hhSince := high
    trailMono := na
    entryBar := bar_index
    lastFilledEntryBar := bar_index
if not inPos
    entryStopDist := na
    hhSince := na
    trailMono := na
    entryBar := na
    effStopPlot := na
canEnterNew = na(lastFilledEntryBar) or bar_index > lastFilledEntryBar
if (not inPos) and canEnterNew and not na(entryStopLevel)
    stopDistNow = initStopATR * atr
    entryStopDist := stopDistNow
    planFillPx = math.max(entryStopLevel, open)
    q = useRiskCap ? math.min(qtyFromPct(entryPct * scale, planFillPx), riskCapShares(stopDistNow)) : qtyFromPct(entryPct * scale, planFillPx)
    if q >= lotShares
        strategy.entry("BUY", strategy.long, qty=q, stop=entryStopLevel)
if inPos and not na(entryStopDist)
    hhSince := na(hhSince) ? high : math.max(hhSince, high)
    profitR_mfe = (hhSince - avg)/entryStopDist
    tMult = (profitR_mfe >= tightenAtR) ? trailTight : trailBase
    trailRaw = hhSince - tMult*atr
    trailMono := na(trailMono[1]) ? trailRaw : math.max(trailMono[1], trailRaw)
    initStop = avg - entryStopDist
    effStop  = math.max(initStop, trailMono)
    if useBE and (close-avg >= beR*entryStopDist)
        effStop := math.max(effStop, avg)
    holdOk = (minHoldBars==0) ? true : (not na(entryBar) and (bar_index-entryBar>=minHoldBars))
    dynExit = effStop
    dynExit := holdOk and not na(loExit) ? math.max(dynExit, loExit) : dynExit
    softExitHit = useRegimeFilter and softGateEnabled and not hardBull and softScore < softExitScore
    dynExit := (useRegimeExit and useRegimeFilter and not softGateEnabled) ? math.max(dynExit, emaRegime) : dynExit
    dynExit := (useRegimeExit and useRegimeFilter and softGateEnabled and hardBull) ? math.max(dynExit, emaRegime) : dynExit
    dynExit := (useRegimeExit and softExitHit) ? math.max(dynExit, close * 0.999) : dynExit
    effStopPlot := dynExit
    if canExitBar
        strategy.exit("SELL", from_entry="BUY", stop=dynExit)
else
    effStopPlot := na
plot(emaRegime, "Regime EMA (200)", linewidth=2)
plot(ema200Ref, "Fixed EMA200 Ref", linewidth=1)
plot(effStopPlot, "Stop", style=plot.style_linebr, linewidth=2)
if strategy.position_size == 0 and entrySignal
    alert("Long intrabar trigger reached.", alert.freq_once_per_bar)
if strategy.position_size > 0 and canExitBar and not na(effStopPlot) and low <= effStopPlot
    alert("Exit intrabar stop reached.", alert.freq_once_per_bar)
````
