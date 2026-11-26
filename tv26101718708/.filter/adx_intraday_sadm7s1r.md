# ADX Intraday

- url: https://www.tradingview.com/script/sAdm7S1R-ADX-Intraday/
- type: indicator
- pine_id: PUB;65fff6baa00b4c9c99f065dff230663d
- version: 1.0

## Description

A trend tool for NQ on the 5-minute, aimed at the first couple hours after the open. ADX is the gatekeeper. If it's under the threshold the market's chopping and you do nothing. When ADX says we're trending, +DI versus -DI gives direction, VWAP and the 20 EMA set the bias, and a candle handles the timing. Long wants a trending read, +DI over -DI, price on the right side of VWAP and the EMA, and a confirming bar. Short is the flip. The ADX filter is the whole point, it keeps you out of the grind. Single timeframe, no outside data pulls, so nothing repaints.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  ADX Intraday NQ - trend-regime entries
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  A trend tool for NQ on the 5-minute, aimed at the first couple hours after
//  the open. ADX is the gatekeeper. If it's under the threshold the market's
//  chopping and you do nothing. When ADX says we're trending, +DI versus -DI
//  gives direction, VWAP and the 20 EMA set the bias, and a candle handles
//  the timing. Long wants a trending read, +DI over -DI, price on the right
//  side of VWAP and the EMA, and a confirming bar. Short is the flip. The ADX
//  filter is the whole point, it keeps you out of the grind. Single
//  timeframe, no outside data pulls, so nothing repaints.
// ============================================================================
//
//@version=6
// ============================================================
// ADX Intraday Trend Strategy — NQ Futures
// Built for Michael's 9:30–11:30 ET window (5-min chart)
// ADX = regime filter | DI = direction | VWAP+EMA20 = bias | candle = trigger
// ============================================================
indicator('ADX Intraday NQ', overlay = true, max_labels_count = 500)

// ---------------- Inputs ----------------
adxLen = input.int(14, 'ADX / DI Length', minval = 1, group = 'Trend')
adxSmooth = input.int(14, 'ADX Smoothing', minval = 1, group = 'Trend')
adxTrend = input.float(25, 'ADX Trend Threshold', minval = 1, group = 'Trend')
adxChop = input.float(20, 'ADX Chop Threshold', minval = 1, group = 'Trend')
emaLen = input.int(20, 'EMA Length', minval = 1, group = 'Bias')
pbBars = input.int(4, 'Pullback Lookback (bars)', minval = 1, group = 'Entry')
pbBuffer = input.float(0.3, 'Pullback Zone (xATR)', minval = 0, step = 0.1, group = 'Entry')
cooldown = input.int(5, 'Bars Between Signals', minval = 0, group = 'Entry')
useSession = input.bool(true, 'Restrict to Session', group = 'Time')
sess = input.session('0930-1130', 'Session (no new entries after end)', group = 'Time')
showZones = input.bool(true, 'Shade No-Trade (ADX<chop)', group = 'Visuals')

// ---------------- Calculations ----------------
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmooth)
ema20 = ta.ema(close, emaLen)
vwap = ta.vwap(hlc3)
atr = ta.atr(14)

// Session gate (exchange time)
inSess = not useSession or not na(time(timeframe.period, sess, 'America/New_York'))

// Regime + bias
adxRising = adx > adx[1]
trendOn = adx > adxTrend and adxRising
chop = adx < adxChop

longBias = diPlus > diMinus and close > vwap and close > ema20
shortBias = diMinus > diPlus and close < vwap and close < ema20

// Pullback into the EMA20 zone within the lookback window
pulledDownToZone = ta.lowest(low, pbBars) <= ema20 + atr * pbBuffer
pulledUpToZone = ta.highest(high, pbBars) >= ema20 - atr * pbBuffer

// Momentum trigger candle (breaks prior bar extreme in trade direction)
bullTrigger = close > open and close > high[1]
bearTrigger = close < open and close < low[1]

longRaw = trendOn and longBias and pulledDownToZone and bullTrigger and inSess
shortRaw = trendOn and shortBias and pulledUpToZone and bearTrigger and inSess

// Cooldown so we don't stack signals on the same leg
var int lastSig = na
canFire = na(lastSig) or bar_index - lastSig > cooldown
longSig = longRaw and canFire
shortSig = shortRaw and canFire
if longSig or shortSig
    lastSig := bar_index
    lastSig

// ---------------- Plots ----------------
plot(ema20, 'EMA20', color = color.new(color.orange, 0), linewidth = 2)
plot(vwap, 'VWAP', color = color.new(color.blue, 0), linewidth = 2)

bgcolor(showZones and chop ? color.new(color.gray, 90) : na, title = 'No-Trade Zone')

plotshape(longSig, 'Long', shape.triangleup, location.belowbar, color.new(color.green, 0), size = size.small, text = 'LONG')
plotshape(shortSig, 'Short', shape.triangledown, location.abovebar, color.new(color.red, 0), size = size.small, text = 'SHORT')

// Suggested stop reference (swing of the pullback) — visual dots
longStop = ta.lowest(low, pbBars)
shortStop = ta.highest(high, pbBars)
plot(longSig ? longStop : na, 'Long Stop', color = color.new(color.green, 0), style = plot.style_circles, linewidth = 2)
plot(shortSig ? shortStop : na, 'Short Stop', color = color.new(color.red, 0), style = plot.style_circles, linewidth = 2)

// ---------------- Info table ----------------
var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    regimeTxt = chop ? 'CHOP — stand aside' : trendOn ? 'TREND — armed' : 'building / weak'
    regimeCol = chop ? color.gray : trendOn ? color.green : color.orange
    table.cell(t, 0, 0, 'ADX', text_color = color.white)
    table.cell(t, 1, 0, str.tostring(adx, '#.0'), text_color = color.white)
    table.cell(t, 0, 1, '+DI/-DI', text_color = color.white)
    table.cell(t, 1, 1, str.tostring(diPlus, '#.0') + ' / ' + str.tostring(diMinus, '#.0'), text_color = color.white)
    table.cell(t, 0, 2, 'Regime', text_color = color.white)
    table.cell(t, 1, 2, regimeTxt, text_color = regimeCol)
    table.cell(t, 0, 3, 'Session', text_color = color.white)
    table.cell(t, 1, 3, inSess ? 'OPEN' : 'closed', text_color = inSess ? color.green : color.gray)

// ---------------- Alerts ----------------
alertcondition(longSig, 'ADX NQ Long', 'ADX Long setup — pullback + bull trigger in uptrend')
alertcondition(shortSig, 'ADX NQ Short', 'ADX Short setup — pullback + bear trigger in downtrend')

if longSig
    alert('ADX NQ LONG @ ' + str.tostring(close) + ' | ADX ' + str.tostring(adx, '#.0') + ' | stop≈' + str.tostring(longStop), alert.freq_once_per_bar_close)
if shortSig
    alert('ADX NQ SHORT @ ' + str.tostring(close) + ' | ADX ' + str.tostring(adx, '#.0') + ' | stop≈' + str.tostring(shortStop), alert.freq_once_per_bar_close)
````
