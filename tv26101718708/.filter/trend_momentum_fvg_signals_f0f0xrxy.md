# Trend + Momentum + FVG Signals

- url: https://www.tradingview.com/script/F0F0xrXY-Trend-Momentum-FVG-Signals/
- type: indicator
- pine_id: PUB;b020e5d9722c49f6905897f7cdcd7341
- version: 2.0

## Description

This is my first attempt at writing a Pine Script. It is a trend-following and momentum indicator that also shows fair value gaps, with buy and sell signals. This is my first attempt at writing a Pine Script so any advice would be greatly appreciated. Thanks in advance, and I hope it is helpful.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © abearisto89

//@version=6
// ============================================================================
// Trend Continuation & Reversal Probability [TCR]
// Not financial advice. This is a heuristic composite score, not a
// statistically validated probability. Backtest/forward-test before use,
// especially on leveraged perpetual futures where funding rate and
// liquidation risk are NOT accounted for by this script.
// ============================================================================
indicator("Trend Continuation & Reversal Probability [TCR]", shorttitle="TCR", overlay=false, max_labels_count=500, max_lines_count=500)

// ============================================================================
// INPUTS
// ============================================================================
grp_trend = "Trend"
fastLen   = input.int(21, "Fast EMA", minval=2, group=grp_trend)
slowLen   = input.int(50, "Slow EMA", minval=2, group=grp_trend)
macroLen  = input.int(200, "Macro EMA (Regime Filter)", minval=10, group=grp_trend)
adxLen    = input.int(14, "ADX / DI Length", minval=2, group=grp_trend)

grp_mom = "Momentum"
rsiLen     = input.int(14, "RSI Length", minval=2, group=grp_mom)
macdFast   = input.int(12, "MACD Fast", group=grp_mom)
macdSlow   = input.int(26, "MACD Slow", group=grp_mom)
macdSignal = input.int(9,  "MACD Signal", group=grp_mom)

grp_vol = "Volatility & Volume"
atrLen    = input.int(14, "ATR Length", group=grp_vol)
atrMultSL = input.float(1.5, "Stop Loss (x ATR)", step=0.1, group=grp_vol)
atrMultTP = input.float(3.0, "Take Profit (x ATR)", step=0.1, group=grp_vol)
volLen    = input.int(20, "Volume MA Length", group=grp_vol)
extLen    = input.int(50, "Extension Lookback (mean reversion)", group=grp_vol)

grp_sig = "Signals"
confThreshold = input.int(60, "Minimum Confidence to Fire Signal", minval=50, maxval=95, group=grp_sig)
useHTF        = input.bool(true, "Use Higher Timeframe Filter", group=grp_sig)
htfTF         = input.timeframe("240", "Higher Timeframe", group=grp_sig)
showTable     = input.bool(true, "Show Dashboard", group=grp_sig)
showBarColor  = input.bool(true, "Color Price Bars by Trend", group=grp_sig)
showSLTP      = input.bool(true, "Plot ATR Stop/Target Lines on Signal", group=grp_sig)

// ============================================================================
// CORE CALCULATIONS
// ============================================================================
emaFast  = ta.ema(close, fastLen)
emaSlow  = ta.ema(close, slowLen)
emaMacro = ta.ema(close, macroLen)

[diplus, diminus, adx] = ta.dmi(adxLen, adxLen)

rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)

atr    = ta.atr(atrLen)
volMA  = ta.sma(volume, volLen)
volRatio = volMA == 0 ? 1.0 : volume / volMA

// Regime (macro) vs local trend
bullRegime = close > emaMacro
bearRegime = close < emaMacro
bullStack  = emaFast > emaSlow
bearStack  = emaFast < emaSlow

trendUp      = bullStack and bullRegime
trendDown    = bearStack and bearRegime
trendNeutral = not trendUp and not trendDown

// Higher timeframe trend filter
htfEmaFast = request.security(syminfo.tickerid, htfTF, ta.ema(close, fastLen), lookahead=barmerge.lookahead_off)
htfEmaSlow = request.security(syminfo.tickerid, htfTF, ta.ema(close, slowLen), lookahead=barmerge.lookahead_off)
htfBull = htfEmaFast > htfEmaSlow
htfBear = htfEmaFast < htfEmaSlow

// Extension from mean (z-score) - overextension raises reversal risk
smaExt = ta.sma(close, extLen)
stdExt = ta.stdev(close, extLen)
zExt   = stdExt == 0 ? 0.0 : (close - smaExt) / stdExt

// ---- Simple confirmed-pivot RSI divergence (non-repainting) ----
lookbackL = 5
lookbackR = 5
plFound = ta.pivotlow(low, lookbackL, lookbackR)
phFound = ta.pivothigh(high, lookbackL, lookbackR)

var float lastPL = na
var float lastPLRsi = na
var float prevPL = na
var float prevPLRsi = na
var float lastPH = na
var float lastPHRsi = na
var float prevPH = na
var float prevPHRsi = na

if not na(plFound)
    prevPL := lastPL
    prevPLRsi := lastPLRsi
    lastPL := plFound
    lastPLRsi := rsi[lookbackR]

if not na(phFound)
    prevPH := lastPH
    prevPHRsi := lastPHRsi
    lastPH := phFound
    lastPHRsi := rsi[lookbackR]

bullDiv = not na(lastPL) and not na(prevPL) and lastPL < prevPL and lastPLRsi > prevPLRsi
bearDiv = not na(lastPH) and not na(prevPH) and lastPH > prevPH and lastPHRsi < prevPHRsi

// ============================================================================
// CONTINUATION vs REVERSAL COMPOSITE SCORE
// Heuristic weighted score, 0-100. NOT a statistical probability.
// ============================================================================
float contScore = 0.0
float revScore  = 0.0

// ADX: strong/rising ADX favors continuation; weak or exhausting ADX favors reversal
contScore += adx > 25 ? 20 : adx > 20 ? 10 : 0.0
revScore  += adx < 20 ? 15 : 0.0
revScore  += (adx < adx[3] and adx > 25) ? 10 : 0.0

// EMA stack alignment vs price
contScore += ((trendUp and close > emaFast) or (trendDown and close < emaFast)) ? 15 : 0.0
revScore  += ((trendUp and close < emaFast) or (trendDown and close > emaFast)) ? 10 : 0.0

// MACD histogram momentum
contScore += ((trendUp and histLine > histLine[1] and histLine > 0) or (trendDown and histLine < histLine[1] and histLine < 0)) ? 15 : 0.0
revScore  += ((trendUp and histLine < histLine[1] and histLine[1] < histLine[2]) or (trendDown and histLine > histLine[1] and histLine[1] > histLine[2])) ? 10 : 0.0

// RSI positioning
revScore  += ((trendUp and rsi > 70) or (trendDown and rsi < 30)) ? 15 : 0.0
contScore += ((trendUp and rsi > 50 and rsi < 70) or (trendDown and rsi < 50 and rsi > 30)) ? 10 : 0.0

// Volume confirmation
contScore += volRatio > 1.2 ? 10 : 0.0
revScore  += (volRatio > 1.5 and ((trendUp and close < open) or (trendDown and close > open))) ? 10 : 0.0

// Mean-reversion extension
revScore += math.abs(zExt) > 2 ? 15 : math.abs(zExt) > 1.5 ? 8 : 0.0

// Higher timeframe agreement/conflict
contScore += ((trendUp and htfBull) or (trendDown and htfBear)) ? 10 : 0.0
revScore  += ((trendUp and htfBear) or (trendDown and htfBull)) ? 10 : 0.0

// Divergence against current trend
revScore += ((trendUp and bearDiv) or (trendDown and bullDiv)) ? 15 : 0.0

totalScore = contScore + revScore
contPct = totalScore == 0.0 ? 50.0 : (contScore / totalScore) * 100.0
revPct  = 100.0 - contPct

// ============================================================================
// SIGNAL LOGIC
// ============================================================================
bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

buySignal  = bullCross and bullRegime and contPct >= confThreshold and (not useHTF or htfBull)
sellSignal = bearCross and bearRegime and contPct >= confThreshold and (not useHTF or htfBear)

// Early heads-up warnings that the CURRENT trend may be running out of steam
reversalWarningLong  = trendUp   and revPct >= confThreshold and (bearDiv or rsi > 75 or math.abs(zExt) > 2)
reversalWarningShort = trendDown and revPct >= confThreshold and (bullDiv or rsi < 25 or math.abs(zExt) > 2)

longSL  = close - atr * atrMultSL
longTP  = close + atr * atrMultTP
shortSL = close + atr * atrMultSL
shortTP = close - atr * atrMultTP

// ============================================================================
// PLOTS - oscillator pane
// ============================================================================
contPlot = plot(contPct, "Continuation %", color=color.new(color.teal, 0), linewidth=2)
midPlot  = plot(50, "Neutral (fill ref)", color=color.new(color.gray, 100), display=display.none)
zeroL    = hline(0, "0", color=color.new(color.gray, 80))
midL     = hline(50, "Neutral", color=color.gray, linestyle=hline.style_dashed)
hundredL = hline(100, "100", color=color.new(color.gray, 80))
fill(contPlot, midPlot, color = contPct >= 50 ? color.new(color.teal, 85) : color.new(color.red, 85))
plot(revPct, "Reversal %", color=color.new(color.red, 0), linewidth=1)

bgcolor(contPct >= confThreshold ? color.new(color.teal, 90) : revPct >= confThreshold ? color.new(color.red, 90) : na)

// ============================================================================
// PLOTS - forced onto main price chart
// ============================================================================
trendColor = trendUp ? color.teal : trendDown ? color.red : color.gray

plot(emaFast, "Fast EMA", color=color.new(color.orange, 0), force_overlay=true)
plot(emaSlow, "Slow EMA", color=color.new(color.blue, 0), force_overlay=true)
plot(emaMacro, "Macro EMA", color=color.new(color.purple, 0), linewidth=2, force_overlay=true)

barcolor(showBarColor ? trendColor : na)

plotshape(buySignal, title="Buy", style=shape.triangleup, location=location.belowbar, color=color.teal, size=size.small, text="BUY", force_overlay=true)
plotshape(sellSignal, title="Sell", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", force_overlay=true)

plotshape(reversalWarningLong, title="Reversal Risk (Long)", style=shape.xcross, location=location.abovebar, color=color.new(color.orange, 0), size=size.tiny, force_overlay=true)
plotshape(reversalWarningShort, title="Reversal Risk (Short)", style=shape.xcross, location=location.belowbar, color=color.new(color.orange, 0), size=size.tiny, force_overlay=true)

var line slLine = na
var line tpLine = na
if showSLTP and (buySignal or sellSignal)
    line.delete(slLine)
    line.delete(tpLine)
    slLevel = buySignal ? longSL : shortSL
    tpLevel = buySignal ? longTP : shortTP
    slLine := line.new(bar_index, slLevel, bar_index + 20, slLevel, color=color.red, style=line.style_dashed, force_overlay=true)
    tpLine := line.new(bar_index, tpLevel, bar_index + 20, tpLevel, color=color.teal, style=line.style_dashed, force_overlay=true)

// ============================================================================
// DASHBOARD
// ============================================================================
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast and showTable
    table.cell(dash, 0, 0, "TCR Dashboard", text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.small)
    table.cell(dash, 1, 0, "", bgcolor=color.new(color.gray, 50))

    table.cell(dash, 0, 1, "Trend", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, trendUp ? "UP" : trendDown ? "DOWN" : "NEUTRAL", text_color=trendUp ? color.teal : trendDown ? color.red : color.gray, text_size=size.small)

    table.cell(dash, 0, 2, "Continuation %", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(math.round(contPct)) + "%", text_color=color.teal, text_size=size.small)

    table.cell(dash, 0, 3, "Reversal %", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(math.round(revPct)) + "%", text_color=color.red, text_size=size.small)

    table.cell(dash, 0, 4, "ADX", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(math.round(adx, 1)), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 5, "RSI", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(math.round(rsi, 1)), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 6, "Vol Ratio", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(math.round(volRatio, 2)) + "x", text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 7, "HTF Trend", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, htfBull ? "BULL" : htfBear ? "BEAR" : "FLAT", text_color=htfBull ? color.teal : htfBear ? color.red : color.gray, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buySignal, title="TCR Buy Signal", message="TCR: Buy - trend continuation confirmed")
alertcondition(sellSignal, title="TCR Sell Signal", message="TCR: Sell - trend continuation confirmed")
alertcondition(reversalWarningLong, title="TCR Reversal Risk (Long)", message="TCR: Uptrend showing reversal risk")
alertcondition(reversalWarningShort, title="TCR Reversal Risk (Short)", message="TCR: Downtrend showing reversal risk")
````
