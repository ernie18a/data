# Quant Synthesis Strategy [JOAT]

- url: https://www.tradingview.com/script/vxQ5o39J-Quant-Synthesis-Strategy-JOAT/
- type: strategy
- pine_id: PUB;4cbbbe63ec684210ba1ecc3bc97020c4
- version: 1.0

## Description

[b]Quant Synthesis Strategy [JOAT][/b]

[b]Introduction[/b]

QSS Quant Synthesis Strategy is an open-source TradingView strategy that integrates regime detection, higher-timeframe bias, confirmed structure, session opening-range context, volume participation, trend energy, ATR exits, cooldowns, and session risk controls.

The strategy is designed as a realistic research baseline, not an optimized profit promise. Its purpose is to demonstrate how the JOAT indicator concepts can be combined into a non-repainting strategy framework with explicit risk management.

[image]https://www.tradingview.com/x/hq343vJ0/[/image]

[b]Core Concepts[/b]

[b]1. Market Regime Detection[/b]
The regime model uses EMA spread, ADX from DMI, and ATR percentage context to classify Trend, Expansion, Balance, or Transition.

[b]2. Higher-Timeframe Bias[/b]
The strategy requests higher-timeframe EMAs with lookahead disabled. Long bias requires the HTF fast EMA above the slow EMA with positive slope; short bias is mirrored.

[b]3. Confirmed Structure[/b]
Pivot-based structure checks whether recent highs and lows form bullish or bearish structure. Pivot confirmation is delayed by design to avoid repainting.

[b]4. Session Opening Range[/b]
The strategy tracks a configurable trading session and opening range. Entries can require session context so trades are not taken randomly outside the selected window.

[b]5. Risk and Exits[/b]
Position size is estimated from a percentage of equity and ATR stop distance. Exits include ATR stop, ATR target, maximum bars in trade, regime/bias exit, cooldown, and session flattening.

[b]Features[/b]

[list]
[*][b]Regime engine:[/b] Trend, Expansion, Balance, and Transition classification
[*][b]HTF bias filter:[/b] Uses non-lookahead request.security() higher-timeframe EMAs
[*][b]Confirmed structure filter:[/b] Pivot-based bullish/bearish structure state
[*][b]Session opening range:[/b] Optional session context for entries
[*][b]Volume participation filter:[/b] Uses volume z-score and directional volume
[*][b]Confluence score:[/b] Separate long and short scores gate entries
[*][b]ATR exits:[/b] Stop loss and take profit scale with volatility
[*][b]Risk controls:[/b] Risk percent, cooldown, max entries per session, max bars in trade, and session flattening
[*][b]Visuals:[/b] EMA cloud, opening-range lines, stop/target plots, and top-right dashboard
[/list]

[b]Default Strategy Properties[/b]

[list]
[*]Initial capital: 100000
[*]Commission: 0.01 percent
[*]Slippage: 1 tick
[*]Pyramiding: 0
[*]Order processing: process orders on close
[*]Position sizing: fixed quantity calculated internally from risk settings
[/list]

[b]How to Use[/b]

[b]Step 1:[/b] Select a market and timeframe with enough historical data.

[b]Step 2:[/b] Review the dashboard regime and HTF bias before interpreting trades.

[b]Step 3:[/b] Adjust risk percent, ATR stop, ATR target, cooldown, and session settings conservatively.

[b]Step 4:[/b] Evaluate results across multiple symbols and timeframes. Avoid optimizing only one market segment.

[b]Limitations[/b]

[list]
[*]Backtest results are historical simulations and do not guarantee future performance
[*]More trades can increase sample size but can also increase noise and transaction costs
[*]Pivot confirmation creates intentional signal delay
[*]Strategy results depend on symbol liquidity, timeframe, session settings, slippage, and commission assumptions
[*]The strategy is a research framework, not a recommendation to trade
[/list]

[b]Originality Statement[/b]

QSS is an original JOAT strategy framework that integrates regime detection, HTF bias, structure, session context, volume participation, and ATR risk management into one non-repainting Pine Script v6 strategy.

[b]Disclaimer[/b]

This strategy is for educational and informational purposes only. It is not financial advice and does not guarantee profitability. Trading involves substantial risk of loss. Historical backtests can be inaccurate or misleading if assumptions do not match live execution.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Quant Synthesis Strategy [JOAT]", "QSS [JOAT]", overlay=true, pyramiding=0, initial_capital=100000, default_qty_type=strategy.fixed, default_qty_value=1, commission_type=strategy.commission.percent, commission_value=0.01, slippage=1, max_bars_back=500, calc_on_every_tick=false, process_orders_on_close=true)

//-----------------------------------------------------------------------------
// Inputs
//-----------------------------------------------------------------------------
qssGroupRegime = "Regime"
qssGroupBias = "Bias"
qssGroupSession = "Session"
qssGroupRisk = "Risk"
qssGroupVisuals = "Visuals"
qssGroupDash = "Dashboard"

fastLen = input.int(12, "Fast EMA", minval=1, group=qssGroupRegime)
slowLen = input.int(34, "Slow EMA", minval=2, group=qssGroupRegime)
signalLen = input.int(9, "Signal Length", minval=1, group=qssGroupRegime)
adxLen = input.int(14, "ADX Length", minval=1, group=qssGroupRegime)
atrLen = input.int(14, "ATR Length", minval=1, group=qssGroupRegime)
htfTf = input.timeframe("240", "Higher Timeframe", group=qssGroupBias)
htfFast = input.int(34, "HTF Fast EMA", minval=2, group=qssGroupBias)
htfSlow = input.int(89, "HTF Slow EMA", minval=3, group=qssGroupBias)
pivotLeft = input.int(3, "Pivot Left", minval=1, group=qssGroupBias)
pivotRight = input.int(3, "Pivot Right", minval=1, group=qssGroupBias)

tradeSession = input.session("0930-1600", "Trade Session", group=qssGroupSession)
openingRangeBars = input.int(6, "Opening Range Bars", minval=1, group=qssGroupSession)
useSessionFilter = input.bool(true, "Require Session Context", group=qssGroupSession)

riskPct = input.float(0.50, "Risk % of Equity", minval=0.05, step=0.05, group=qssGroupRisk)
stopATR = input.float(1.6, "Stop ATR", minval=0.2, step=0.1, group=qssGroupRisk)
takeATR = input.float(2.8, "Take Profit ATR", minval=0.2, step=0.1, group=qssGroupRisk)
maxBarsInTrade = input.int(40, "Max Bars In Trade", minval=1, group=qssGroupRisk)
cooldownBars = input.int(8, "Cooldown Bars", minval=0, group=qssGroupRisk)
maxEntriesPerSession = input.int(2, "Max Entries Per Session", minval=1, group=qssGroupRisk)
minConfluence = input.int(70, "Min Confluence", minval=1, maxval=100, group=qssGroupRisk)
htfBiasOn = input.bool(true, "Use HTF Bias Filter", group=qssGroupBias)

bullColor = input.color(color.rgb(28, 198, 157), "Bull Color", group=qssGroupVisuals)
bearColor = input.color(color.rgb(244, 103, 117), "Bear Color", group=qssGroupVisuals)
accentColor = input.color(color.rgb(238, 193, 83), "Accent Color", group=qssGroupVisuals)
neutralColor = input.color(color.rgb(146, 156, 172), "Neutral Color", group=qssGroupVisuals)

showDashboard = input.bool(true, "Show Dashboard", group=qssGroupDash)
showSessionRange = input.bool(true, "Show Session Range", group=qssGroupDash)
showCloud = input.bool(true, "Show EMA Cloud", group=qssGroupDash)
dashTransp = input.int(82, "Dashboard Transparency", minval=0, maxval=100, group=qssGroupDash)

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------
f_clamp(float v, float lo, float hi) =>
    math.min(math.max(v, lo), hi)

f_norm(float v, float scale) =>
    scale == 0.0 ? 0.0 : v / scale

f_qtyFromRisk(float riskPercent, float stopDistance) =>
    riskCapital = strategy.equity * riskPercent * 0.01
    contractValue = math.max(stopDistance * syminfo.pointvalue, syminfo.mintick)
    qty = riskCapital / contractValue
    math.max(qty, 0.0)

f_boolScore(bool condition, int points) =>
    condition ? points : 0

//-----------------------------------------------------------------------------
// Regime engine
//-----------------------------------------------------------------------------
atrValue = ta.atr(atrLen)
atrSafe = math.max(atrValue, syminfo.mintick)
atrPct = f_norm(atrValue, close)
atrAvg = nz(ta.sma(atrPct, 50), atrPct)

fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
signalEma = ta.ema(fastEma - slowEma, signalLen)
emaSpread = fastEma - slowEma
emaSpreadNorm = f_norm(emaSpread, atrSafe)
signalNorm = f_norm(signalEma, atrSafe)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)
trendRegime = adxValue >= 18 and math.abs(emaSpreadNorm) >= 0.20
balanceRegime = adxValue < 16 or atrPct < atrAvg * 0.90
expansionRegime = atrPct > atrAvg * 1.12
regimeText = trendRegime ? "Trend" : expansionRegime ? "Expansion" : balanceRegime ? "Balance" : "Transition"

//-----------------------------------------------------------------------------
// Higher timeframe bias
//-----------------------------------------------------------------------------
htfFastEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfSlope = htfFastEma - htfFastEma[1]

htfBull = htfFastEma > htfSlowEma and htfSlope > 0
htfBear = htfFastEma < htfSlowEma and htfSlope < 0

//-----------------------------------------------------------------------------
// Confirmed market structure
//-----------------------------------------------------------------------------
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var float prevHighPivot = na
var float lastHighPivot = na
var float prevLowPivot = na
var float lastLowPivot = na

if not na(ph)
    prevHighPivot := lastHighPivot
    lastHighPivot := ph

if not na(pl)
    prevLowPivot := lastLowPivot
    lastLowPivot := pl

structureBull = not na(lastHighPivot) and not na(prevHighPivot) and not na(lastLowPivot) and not na(prevLowPivot) and lastHighPivot > prevHighPivot and lastLowPivot > prevLowPivot
structureBear = not na(lastHighPivot) and not na(prevHighPivot) and not na(lastLowPivot) and not na(prevLowPivot) and lastHighPivot < prevHighPivot and lastLowPivot < prevLowPivot
structureScore = structureBull ? 1 : structureBear ? -1 : 0

//-----------------------------------------------------------------------------
// Trend energy module
//-----------------------------------------------------------------------------
trendSlope = ta.linreg(close, 20, 0) - ta.linreg(close, 20, 1)
trendSlopeNorm = f_norm(trendSlope, atrSafe)
trendPulse = ta.ema(emaSpreadNorm + trendSlopeNorm, 5)

var float lastBearDivPrice = na
var float lastBearDivOsc = na
var float lastBullDivPrice = na
var float lastBullDivOsc = na

bullDiv = false
bearDiv = false

oscAtHigh = not na(ph) ? (emaSpreadNorm[pivotRight] + trendSlopeNorm[pivotRight] + signalNorm[pivotRight]) : na
oscAtLow = not na(pl) ? (emaSpreadNorm[pivotRight] + trendSlopeNorm[pivotRight] + signalNorm[pivotRight]) : na

if not na(ph) and not na(oscAtHigh)
    bearDiv := not na(lastBearDivPrice) and ph > lastBearDivPrice and oscAtHigh < lastBearDivOsc
    lastBearDivPrice := ph
    lastBearDivOsc := oscAtHigh

if not na(pl) and not na(oscAtLow)
    bullDiv := not na(lastBullDivPrice) and pl < lastBullDivPrice and oscAtLow > lastBullDivOsc
    lastBullDivPrice := pl
    lastBullDivOsc := oscAtLow

divBias = bullDiv ? 1.0 : bearDiv ? -1.0 : 0.0

breakoutLong = close > nz(ta.highest(high, 10)[1], high)
breakoutShort = close < nz(ta.lowest(low, 10)[1], low)
momentumScore = f_clamp(emaSpreadNorm * 16.0 + trendSlopeNorm * 8.0 + trendPulse * 5.0 + divBias * 6.0, -25.0, 25.0)

//-----------------------------------------------------------------------------
// Session opening range module
//-----------------------------------------------------------------------------
inSession = not na(time(timeframe.period, tradeSession))
prevInSession = bar_index > 0 ? inSession[1] : false
newSession = inSession and not prevInSession

var float sessionOpen = na
var float sessionHigh = na
var float sessionLow = na
var float openingHigh = na
var float openingLow = na
var int sessionBars = 0
var int entriesThisSession = 0

if newSession
    sessionOpen := open
    sessionHigh := high
    sessionLow := low
    openingHigh := high
    openingLow := low
    sessionBars := 1
    entriesThisSession := 0
else if inSession
    sessionHigh := na(sessionHigh) ? high : math.max(sessionHigh, high)
    sessionLow := na(sessionLow) ? low : math.min(sessionLow, low)
    if sessionBars < openingRangeBars
        openingHigh := na(openingHigh) ? high : math.max(openingHigh, high)
        openingLow := na(openingLow) ? low : math.min(openingLow, low)
    sessionBars += 1

orReady = inSession and sessionBars >= openingRangeBars
orHigh = orReady ? openingHigh : na
orLow = orReady ? openingLow : na
orMid = orReady and not na(orHigh) and not na(orLow) ? (orHigh + orLow) * 0.5 : na

sessionLong = not useSessionFilter or (orReady and close > orHigh and close > orMid)
sessionShort = not useSessionFilter or (orReady and close < orLow and close < orMid)
sessionBiasLong = orReady and close > sessionOpen and close > orMid
sessionBiasShort = orReady and close < sessionOpen and close < orMid

//-----------------------------------------------------------------------------
// Volume participation module
//-----------------------------------------------------------------------------
volSma = ta.sma(volume, 20)
volStdev = ta.stdev(volume, 20)
volZ = volStdev == 0.0 ? 0.0 : (volume - volSma) / volStdev
volSurprise = volZ > 0.8
volExpansion = volZ > 1.2
directionalVolume = f_norm(volume * (close - open), math.max(ta.sma(volume * math.abs(close - open), 20), syminfo.mintick))
volumeScore = f_clamp(volZ * 8.0 + directionalVolume * 10.0, -15.0, 15.0)

//-----------------------------------------------------------------------------
// Confluence score
//-----------------------------------------------------------------------------
regimeScoreLong = trendRegime and emaSpreadNorm > 0 ? 22 : expansionRegime and emaSpreadNorm > 0 ? 14 : 0
regimeScoreShort = trendRegime and emaSpreadNorm < 0 ? 22 : expansionRegime and emaSpreadNorm < 0 ? 14 : 0

biasScoreLong = (htfBiasOn ? f_boolScore(htfBull, 20) : 10) + f_boolScore(structureBull, 10)
biasScoreShort = (htfBiasOn ? f_boolScore(htfBear, 20) : 10) + f_boolScore(structureBear, 10)

momentumLong = momentumScore > 0 ? math.min(momentumScore, 25) : 0
momentumShort = momentumScore < 0 ? math.min(math.abs(momentumScore), 25) : 0

volumeLong = volSurprise and close > open ? math.min(volumeScore, 15) : 0
volumeShort = volSurprise and close < open ? math.min(math.abs(volumeScore), 15) : 0

sessionScoreLong = sessionBiasLong ? 12 : sessionLong and breakoutLong ? 12 : 0
sessionScoreShort = sessionBiasShort ? 12 : sessionShort and breakoutShort ? 12 : 0

longScore = regimeScoreLong + biasScoreLong + momentumLong + volumeLong + sessionScoreLong
shortScore = regimeScoreShort + biasScoreShort + momentumShort + volumeShort + sessionScoreShort

longCandidate = barstate.isconfirmed and longScore >= minConfluence and longScore > shortScore and trendRegime and not balanceRegime
shortCandidate = barstate.isconfirmed and shortScore >= minConfluence and shortScore > longScore and trendRegime and not balanceRegime

//-----------------------------------------------------------------------------
// Risk controls and execution
//-----------------------------------------------------------------------------
stopDistance = math.max(atrValue * stopATR, syminfo.mintick * 10.0)
takeDistance = math.max(atrValue * takeATR, syminfo.mintick * 10.0)
tradeQty = f_qtyFromRisk(riskPct, stopDistance)

var int lastTradeBar = na
var int entryBar = na

canTrade = na(lastTradeBar) ? true : bar_index - lastTradeBar >= cooldownBars
sessionTradeRoom = entriesThisSession < maxEntriesPerSession

enterLong = longCandidate and canTrade and sessionTradeRoom and strategy.position_size <= 0
enterShort = shortCandidate and canTrade and sessionTradeRoom and strategy.position_size >= 0

if enterLong
    strategy.entry("Long", strategy.long, qty=tradeQty, comment="QSS Long")
    lastTradeBar := bar_index
    entriesThisSession += 1

if enterShort
    strategy.entry("Short", strategy.short, qty=tradeQty, comment="QSS Short")
    lastTradeBar := bar_index
    entriesThisSession += 1

if strategy.position_size != 0 and strategy.position_size[1] == 0
    entryBar := bar_index
if strategy.position_size == 0
    entryBar := na

longStop = strategy.position_avg_price - stopDistance
longTake = strategy.position_avg_price + takeDistance
shortStop = strategy.position_avg_price + stopDistance
shortTake = strategy.position_avg_price - takeDistance

if strategy.position_size > 0
    strategy.exit("Long Exit", "Long", stop=longStop, limit=longTake, comment="ATR Exit")
if strategy.position_size < 0
    strategy.exit("Short Exit", "Short", stop=shortStop, limit=shortTake, comment="ATR Exit")

timeExitLong = strategy.position_size > 0 and not na(entryBar) and bar_index - entryBar >= maxBarsInTrade
timeExitShort = strategy.position_size < 0 and not na(entryBar) and bar_index - entryBar >= maxBarsInTrade

if timeExitLong
    strategy.close("Long", comment="Time Exit")
if timeExitShort
    strategy.close("Short", comment="Time Exit")

regimeExitLong = strategy.position_size > 0 and (structureBear or htfBear or balanceRegime)
regimeExitShort = strategy.position_size < 0 and (structureBull or htfBull or balanceRegime)

if regimeExitLong and barstate.isconfirmed
    strategy.close("Long", comment="Bias Exit")
if regimeExitShort and barstate.isconfirmed
    strategy.close("Short", comment="Bias Exit")

sessionClose = not inSession and prevInSession
if sessionClose and strategy.position_size != 0
    strategy.close_all(comment="Session Flat")

//-----------------------------------------------------------------------------
// Visual architecture
//-----------------------------------------------------------------------------
fastPlot = plot(fastEma, "Fast EMA", color=color.new(bullColor, 0), linewidth=2)
slowPlot = plot(slowEma, "Slow EMA", color=color.new(bearColor, 0), linewidth=2)
cloudColor = fastEma > slowEma ? color.new(bullColor, showCloud ? 85 : 100) : color.new(bearColor, showCloud ? 85 : 100)
fill(fastPlot, slowPlot, color=cloudColor)

plot(showSessionRange ? orHigh : na, "Opening Range High", color=color.new(accentColor, 10), linewidth=1, style=plot.style_linebr)
plot(showSessionRange ? orLow : na, "Opening Range Low", color=color.new(accentColor, 10), linewidth=1, style=plot.style_linebr)
plot(showSessionRange ? orMid : na, "Opening Range Mid", color=color.new(neutralColor, 35), linewidth=1, style=plot.style_linebr)

plot(strategy.position_size > 0 ? longStop : na, "Long Stop", color=color.new(bearColor, 0), linewidth=2, style=plot.style_linebr)
plot(strategy.position_size > 0 ? longTake : na, "Long Target", color=color.new(bullColor, 0), linewidth=2, style=plot.style_linebr)
plot(strategy.position_size < 0 ? shortStop : na, "Short Stop", color=color.new(bearColor, 0), linewidth=2, style=plot.style_linebr)
plot(strategy.position_size < 0 ? shortTake : na, "Short Target", color=color.new(bullColor, 0), linewidth=2, style=plot.style_linebr)

bgcolor(trendRegime ? color.new(color.rgb(20, 30, 25), 90) : balanceRegime ? color.new(color.rgb(28, 24, 34), 92) : na)

//-----------------------------------------------------------------------------
// Dashboard
//-----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 8, frame_color=color.new(color.rgb(28, 34, 46), dashTransp), border_color=color.new(color.rgb(63, 74, 92), dashTransp))

if showDashboard and barstate.islast
    regimeColor = trendRegime ? color.new(accentColor, 0) : expansionRegime ? color.new(bullColor, 0) : color.new(neutralColor, 0)
    biasColor = htfBull ? color.new(bullColor, 0) : htfBear ? color.new(bearColor, 0) : color.new(neutralColor, 0)
    longColor = longScore >= minConfluence ? color.new(bullColor, 0) : color.new(neutralColor, 0)
    shortColor = shortScore >= minConfluence ? color.new(bearColor, 0) : color.new(neutralColor, 0)
    volColor = volExpansion ? color.new(accentColor, 0) : volSurprise ? color.new(bullColor, 0) : color.new(neutralColor, 0)
    riskColor = strategy.position_size > 0 ? color.new(bullColor, 0) : strategy.position_size < 0 ? color.new(bearColor, 0) : color.new(neutralColor, 0)
    stateText = enterLong ? "Long Setup" : enterShort ? "Short Setup" : strategy.position_size > 0 ? "Long" : strategy.position_size < 0 ? "Short" : "Flat"

    table.cell(dash, 0, 0, "QSS", text_color=color.white, bgcolor=color.new(color.rgb(20, 24, 32), dashTransp))
    table.cell(dash, 1, 0, "Quant Synthesis", text_color=color.white, bgcolor=color.new(color.rgb(20, 24, 32), dashTransp))

    table.cell(dash, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 2, "Bias", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 2, htfBull ? "HTF Bull" : htfBear ? "HTF Bear" : "Mixed", text_color=biasColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 3, "Long Score", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 3, str.tostring(longScore), text_color=longColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 4, "Short Score", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 4, str.tostring(shortScore), text_color=shortColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 5, "Volume", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 5, str.tostring(volZ, format.mintick), text_color=volColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 6, "Risk", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 6, str.tostring(riskPct, format.mintick) + "%", text_color=riskColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))

    table.cell(dash, 0, 7, "State", text_color=color.white, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
    table.cell(dash, 1, 7, stateText, text_color=riskColor, bgcolor=color.new(color.rgb(24, 28, 38), dashTransp))
````
