# Bystry Prime-Style Oscillator Pro

- url: https://www.tradingview.com/script/9CAEs7VR/
- type: indicator
- pine_id: PUB;7b70fdec869b49e49b6c10481ae6fa87
- version: 1.0

## Description

Bystry Prime-Style Oscillator Pro is a multi-layer momentum, money-flow and volume oscillator designed to help traders read market pressure, exhaustion zones and potential momentum shifts in a clean oscillator panel.

This indicator is an original Pine Script v6 tool. It is not affiliated with, endorsed by, or intended to reproduce any proprietary or closed-source indicator. The goal of this script is to provide a transparent, self-contained oscillator framework that combines momentum, volume pressure, money flow and trend confirmation into one visual dashboard.

What the indicator does:

The script builds a normalized oscillator using several market components:

1. Price momentum
   The indicator measures price impulse and deviation from a smoothed trend baseline. This helps identify whether price is expanding away from its average behavior or returning toward balance.

2. Momentum confirmation
   RSI, CCI and MFI-style components are normalized and blended into the main oscillator. This allows the tool to react not only to price movement, but also to changes in internal momentum.

3. Money Flow Tracker
   The money-flow module estimates buying and selling pressure by combining candle body pressure, close location inside the candle range and volume. This helps identify whether volume is supporting bullish or bearish movement.

4. Volume Matrix
   The volume matrix compares bullish and bearish volume participation. It is designed to show whether the current move has meaningful volume support or whether price is moving with weak participation.

5. True 7 Rank System
   The True 7 model scores market conditions using seven bullish and seven bearish checks, including oscillator direction, signal-line relationship, money flow, volume pressure and trend alignment. The result is displayed as a simple strength framework that helps traders avoid relying on one signal alone.

6. Dynamic Bands
   The oscillator includes adaptive upper and lower bands based on recent oscillator behavior. These bands help identify overbought, oversold and extreme conditions without relying only on fixed levels.

7. Peak Seekers and Divergences
   Confirmed oscillator pivots can mark potential exhaustion areas. The script can also highlight bullish and bearish divergence when price makes a new extreme while the oscillator fails to confirm that move.

How to read the indicator:

Bullish conditions are generally stronger when:

* the oscillator is above its signal line,
* the oscillator is above the zero line,
* money flow is positive,
* the volume matrix supports buyers,
* the True 7 bullish score is high.

Bearish conditions are generally stronger when:

* the oscillator is below its signal line,
* the oscillator is below the zero line,
* money flow is negative,
* the volume matrix supports sellers,
* the True 7 bearish score is high.

The overbought and oversold zones should not be used as automatic buy or sell signals. Strong trends can remain overbought or oversold for long periods. These zones are most useful when combined with momentum shifts, money-flow changes, divergence or market-structure confirmation.

Signals and alerts:

The indicator includes alert conditions for:

* bullish reversal signal,
* bearish reversal signal,
* bullish momentum shift,
* bearish momentum shift,
* bullish peak seeker,
* bearish peak seeker,
* bullish divergence,
* bearish divergence.

For cleaner alerts, it is recommended to use “Once Per Bar Close” when creating TradingView alerts.

Important behavior:

Peak seeker and divergence markers are confirmed only after the required right-side pivot bars have closed. For visual clarity, these markers are plotted on the original pivot candle, but they are not known in real time until confirmation. This avoids misleading users about when the signal becomes available.

The indicator does not guarantee future performance and should not be used as a standalone trading system. It is designed as a decision-support tool and should be combined with market structure, risk management, session context and higher-timeframe analysis.

Suggested use:

This oscillator can be useful for:

* identifying momentum expansion and exhaustion,
* confirming trend continuation,
* filtering weak signals with volume and money flow,
* spotting divergence near important zones,
* building confluence with support/resistance, liquidity zones or session-based strategies.

Risk disclaimer:

This script is for educational and analytical purposes only. It does not provide financial advice. No indicator can predict market movement with certainty. Past signals or historical behavior do not guarantee future results. Always use proper risk management and test the indicator on your own markets and timeframes before using it in live trading.

## Source Code

````pine
//@version=6
indicator("Bystry Prime-Style Oscillator Pro", shorttitle="Bystry Prime Osc", overlay=false, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grp_main = "Main Oscillator"
mode = input.string("Prime Oscillator", "Mode", options=["Prime Oscillator", "MVP Oscillator"], group=grp_main)
src = input.source(close, "Source", group=grp_main)
mainLen = input.int(34, "Main Length", minval=2, group=grp_main)
smoothLen = input.int(8, "Low-Lag Smooth", minval=1, group=grp_main)
signalLen = input.int(9, "Signal Length", minval=1, group=grp_main)
normLen = input.int(100, "Normalization Length", minval=20, group=grp_main)

grp_money = "Money Flow / Volume"
mfLen = input.int(21, "Money Flow Length", minval=2, group=grp_money)
mfSmooth = input.int(5, "Money Flow Smooth", minval=1, group=grp_money)
moneyTf = input.timeframe("", "Money Flow MTF / empty = chart", group=grp_money)
volSensitivity = input.float(1.0, "Volume Sensitivity", minval=0.1, step=0.1, group=grp_money)

grp_levels = "Levels"
upperLevel = input.float(120.0, "Overbought", step=5, group=grp_levels)
lowerLevel = input.float(-120.0, "Oversold", step=5, group=grp_levels)
extremeUpper = input.float(170.0, "Extreme Overbought", step=5, group=grp_levels)
extremeLower = input.float(-170.0, "Extreme Oversold", step=5, group=grp_levels)

grp_visual = "Visual"
showRibbon = input.bool(true, "Show Main Ribbon", group=grp_visual)
showBands = input.bool(true, "Show Dynamic Bands", group=grp_visual)
showMoneyTracker = input.bool(true, "Show Money Flow Tracker", group=grp_visual)
showVolMatrix = input.bool(true, "Show Volume Matrix", group=grp_visual)
showPowerBars = input.bool(true, "Show Top / Bottom Power Bars", group=grp_visual)
showTrue7 = input.bool(true, "Show True 7 Rank", group=grp_visual)
showSignals = input.bool(true, "Show Reversal Signals", group=grp_visual)
showPeakSeekers = input.bool(true, "Show Peak Seekers", group=grp_visual)
showDivergences = input.bool(true, "Show Money Flow Divergences", group=grp_visual)
showDashboard = input.bool(true, "Show Dashboard", group=grp_visual)
colorBars = input.bool(false, "Color Candles By Oscillator", group=grp_visual)

grp_sig = "Signal Logic"
pivotLeft = input.int(4, "Peak Left Bars", minval=1, group=grp_sig)
pivotRight = input.int(4, "Peak Right Bars", minval=1, group=grp_sig)
powerConfirm = input.int(5, "Power Confirmation / 7", minval=1, maxval=7, group=grp_sig)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cBull = color.rgb(0, 232, 190)
cBear = color.rgb(255, 54, 91)
cBullSoft = color.rgb(0, 130, 112)
cBearSoft = color.rgb(160, 25, 55)
cBlue = color.rgb(0, 165, 255)
cPurple = color.rgb(150, 85, 255)
cOrange = color.rgb(255, 166, 0)
cGray = color.rgb(130, 140, 155)
cWhite = color.rgb(235, 240, 250)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(x, lo, hi) =>
    math.min(math.max(x, lo), hi)

f_tanh(x) =>
    e = math.exp(2.0 * x)
    (e - 1.0) / (e + 1.0)

f_zlema(x, len) =>
    lag = int(math.floor((len - 1) / 2))
    ta.ema(x + (x - nz(x[lag], x)), len)

f_norm(x, len) =>
    basis = ta.sma(x, len)
    dev = ta.stdev(x, len)
    z = dev != 0.0 ? (x - basis) / dev : 0.0
    f_clamp(200.0 * f_tanh(z / 2.0), -220.0, 220.0)

f_trans(strength) =>
    int(f_clamp(92.0 - math.abs(strength) * 0.35, 25.0, 92.0))

f_money_flow(_len, _smooth, _norm) =>
    v = nz(volume, 1.0)
    rng = math.max(high - low, syminfo.mintick)
    bodyPressure = (close - open) / rng
    closePressure = ((close - low) - (high - close)) / rng
    signedVol = v * ((bodyPressure * 0.60) + (closePressure * 0.40))
    sm = f_zlema(ta.ema(signedVol, _len), _smooth)
    f_norm(sm, _norm)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE COMPONENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiLen = math.max(7, int(mainLen / 2))
cciLen = math.max(10, int(mainLen / 1.5))
mfiLen = math.max(10, int(mfLen))

priceImpulse = f_norm(f_zlema(src - nz(src[mainLen], src), smoothLen), normLen)
trendDev = f_norm(src - f_zlema(src, mainLen), normLen)
rsiComp = f_clamp((ta.rsi(src, rsiLen) - 50.0) * 4.0, -200.0, 200.0)
cciComp = f_clamp(ta.cci(hlc3, cciLen) * 0.75, -200.0, 200.0)
mfiComp = f_clamp((ta.mfi(hlc3, mfiLen) - 50.0) * 4.0, -200.0, 200.0)

tfSafe = moneyTf == "" ? timeframe.period : moneyTf
mfLocal = f_money_flow(mfLen, mfSmooth, normLen)
mfMTF = request.security(syminfo.tickerid, tfSafe, f_money_flow(mfLen, mfSmooth, normLen), barmerge.gaps_off, barmerge.lookahead_off)

v = nz(volume, 1.0)
upVol = close >= open ? v : 0.0
dnVol = close < open ? v : 0.0
volBase = math.max(ta.ema(v, mfLen), 1.0)
volBalance = 200.0 * ta.ema(upVol - dnVol, mfLen) / volBase
volMatrix = f_zlema(volBalance * volSensitivity, mfSmooth)
volMatrixNorm = f_clamp(volMatrix, -200.0, 200.0)

// Prime mode
primeRaw = priceImpulse * 0.28 + trendDev * 0.20 + rsiComp * 0.18 + cciComp * 0.14 + mfiComp * 0.12 + mfMTF * 0.08
primeOsc = f_zlema(primeRaw, smoothLen)

// MVP mode
mvpRaw = volMatrixNorm * 0.42 + mfMTF * 0.28 + priceImpulse * 0.18 + mfiComp * 0.12
mvpOsc = f_zlema(mvpRaw, smoothLen)

isMVP = mode == "MVP Oscillator"
osc = isMVP ? mvpOsc : primeOsc
sig = f_zlema(osc, signalLen)

oscColor = isMVP ? (osc >= sig ? cBlue : cPurple) : (osc >= sig ? cBull : cBear)
sigColor = osc >= sig ? color.new(cBull, 25) : color.new(cBear, 25)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRUE 7 RANK SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)
emaLong = ta.ema(close, 200)

bull1 = osc > 0
bull2 = osc > sig
bull3 = ta.rising(osc, 3)
bull4 = mfMTF > 0
bull5 = volMatrixNorm > 0
bull6 = close > emaFast and emaFast > emaSlow
bull7 = close > emaLong

bear1 = osc < 0
bear2 = osc < sig
bear3 = ta.falling(osc, 3)
bear4 = mfMTF < 0
bear5 = volMatrixNorm < 0
bear6 = close < emaFast and emaFast < emaSlow
bear7 = close < emaLong

bullPower = (bull1 ? 1 : 0) + (bull2 ? 1 : 0) + (bull3 ? 1 : 0) + (bull4 ? 1 : 0) + (bull5 ? 1 : 0) + (bull6 ? 1 : 0) + (bull7 ? 1 : 0)
bearPower = (bear1 ? 1 : 0) + (bear2 ? 1 : 0) + (bear3 ? 1 : 0) + (bear4 ? 1 : 0) + (bear5 ? 1 : 0) + (bear6 ? 1 : 0) + (bear7 ? 1 : 0)

true7 = (bullPower - bearPower) * 12.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bandLen = math.max(21, int(mainLen * 1.5))
bandBasis = ta.ema(osc, bandLen)
bandSpread = ta.ema(math.abs(osc - bandBasis), bandLen)
upperBand = bandBasis + bandSpread * 1.65
lowerBand = bandBasis - bandSpread * 1.65

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullShift = ta.crossover(osc, sig) and bullPower >= powerConfirm
bearShift = ta.crossunder(osc, sig) and bearPower >= powerConfirm

buySignal = ta.crossover(osc, sig) and osc < lowerLevel and mfMTF > mfMTF[1]
sellSignal = ta.crossunder(osc, sig) and osc > upperLevel and mfMTF < mfMTF[1]

mvpWarningBull = isMVP and osc < lowerLevel and ta.rising(osc, 2)
mvpWarningBear = isMVP and osc > upperLevel and ta.falling(osc, 2)

peakHigh = ta.pivothigh(osc, pivotLeft, pivotRight)
peakLow = ta.pivotlow(osc, pivotLeft, pivotRight)

peakSell = showPeakSeekers and not na(peakHigh) and peakHigh > upperLevel
peakBuy = showPeakSeekers and not na(peakLow) and peakLow < lowerLevel

// Divergences on oscillator vs price
prevOscLow = ta.valuewhen(not na(peakLow), peakLow, 1)
prevPriceLow = ta.valuewhen(not na(peakLow), low[pivotRight], 1)
prevOscHigh = ta.valuewhen(not na(peakHigh), peakHigh, 1)
prevPriceHigh = ta.valuewhen(not na(peakHigh), high[pivotRight], 1)

bullDiv = showDivergences and not na(peakLow) and not na(prevOscLow) and low[pivotRight] < prevPriceLow and peakLow > prevOscLow
bearDiv = showDivergences and not na(peakHigh) and not na(prevOscHigh) and high[pivotRight] > prevPriceHigh and peakHigh < prevOscHigh

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS - LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hline(0, "Zero", color=color.new(cGray, 70), linestyle=hline.style_solid)
hline(upperLevel, "Overbought", color=color.new(cBear, 70), linestyle=hline.style_dotted)
hline(lowerLevel, "Oversold", color=color.new(cBull, 70), linestyle=hline.style_dotted)
hline(extremeUpper, "Extreme OB", color=color.new(cBear, 85), linestyle=hline.style_dashed)
hline(extremeLower, "Extreme OS", color=color.new(cBull, 85), linestyle=hline.style_dashed)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS - BACKGROUND COMPONENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pUB = plot(showBands ? upperBand : na, "Dynamic Upper Band", color=color.new(cBullSoft, 55), linewidth=1)
pLB = plot(showBands ? lowerBand : na, "Dynamic Lower Band", color=color.new(cBullSoft, 55), linewidth=1)
fill(pUB, pLB, color=showBands ? color.new(cBullSoft, 91) : na, title="Band Fill")

plot(showTrue7 ? true7 : na, "True 7 Rank", style=plot.style_columns, histbase=0, color=true7 >= 0 ? color.new(cBull, 82) : color.new(cBear, 82))

// Money Flow Tracker - top row
plot(showMoneyTracker and mfMTF > 0 ? 185 : na, "Money Flow Tracker Bull", style=plot.style_columns, histbase=170, color=color.new(cBull, f_trans(mfMTF)))
plot(showMoneyTracker and mfMTF < 0 ? 185 : na, "Money Flow Tracker Bear", style=plot.style_columns, histbase=170, color=color.new(cBear, f_trans(mfMTF)))

// Volume Matrix - lower rows
plot(showVolMatrix and volMatrixNorm > 0 ? -168 : na, "Volume Matrix Bull", style=plot.style_columns, histbase=-178, color=color.new(cBull, f_trans(volMatrixNorm)))
plot(showVolMatrix and volMatrixNorm < 0 ? -188 : na, "Volume Matrix Bear", style=plot.style_columns, histbase=-198, color=color.new(cBear, f_trans(volMatrixNorm)))

// Power Bars
plot(showPowerBars and bullPower >= powerConfirm ? 150 : na, "Top Power Bars", style=plot.style_columns, histbase=138, color=color.new(cBull, int(f_clamp(95 - bullPower * 10, 20, 88))))
plot(showPowerBars and bearPower >= powerConfirm ? -150 : na, "Bottom Power Bars", style=plot.style_columns, histbase=-138, color=color.new(cBear, int(f_clamp(95 - bearPower * 10, 20, 88))))

// MVP overextension warning bars
plot(isMVP and mvpWarningBull ? lowerLevel : na, "MVP Bull Warning", style=plot.style_columns, histbase=extremeLower, color=color.new(cBull, 45))
plot(isMVP and mvpWarningBear ? upperLevel : na, "MVP Bear Warning", style=plot.style_columns, histbase=extremeUpper, color=color.new(cBull, 45))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN OSCILLATOR / RIBBON
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pSig = plot(showRibbon ? sig : na, "Signal / Ribbon Base", color=color.new(sigColor, 15), linewidth=2)
pOscGlow = plot(osc, "Oscillator Glow", color=color.new(oscColor, 75), linewidth=4)
pOsc = plot(osc, "Main Oscillator", color=oscColor, linewidth=2)

fill(pOsc, pSig, color=showRibbon ? color.new(oscColor, 82) : na, title="Main Ribbon Fill")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHAPES / SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(showSignals and buySignal ? lowerLevel : na, title="BUY Signal", style=shape.triangleup, location=location.absolute, color=cBull, size=size.tiny, text="BUY", textcolor=color.white)
plotshape(showSignals and sellSignal ? upperLevel : na, title="SELL Signal", style=shape.triangledown, location=location.absolute, color=cBear, size=size.tiny, text="SELL", textcolor=color.white)

plotshape(bullShift ? 0 : na, title="Bull Diamond Shift", style=shape.diamond, location=location.absolute, color=color.new(cBull, 0), size=size.tiny)
plotshape(bearShift ? 0 : na, title="Bear Diamond Shift", style=shape.diamond, location=location.absolute, color=color.new(cBear, 0), size=size.tiny)

plotshape(peakBuy ? peakLow : na, title="Peak Seeker Buy", style=shape.circle, location=location.absolute, offset=-pivotRight, color=cBlue, size=size.tiny)
plotshape(peakSell ? peakHigh : na, title="Peak Seeker Sell", style=shape.circle, location=location.absolute, offset=-pivotRight, color=cBlue, size=size.tiny)

plotshape(bullDiv ? peakLow : na, title="Bullish Divergence", style=shape.diamond, location=location.absolute, offset=-pivotRight, color=color.new(cBull, 0), size=size.small, text="DIV", textcolor=color.white)
plotshape(bearDiv ? peakHigh : na, title="Bearish Divergence", style=shape.diamond, location=location.absolute, offset=-pivotRight, color=color.new(cBear, 0), size=size.small, text="DIV", textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 2, 4, border_width=1)

trendTxt = osc > sig and osc > 0 ? "BULL" : osc < sig and osc < 0 ? "BEAR" : "NEUTRAL"
trendBg = trendTxt == "BULL" ? color.new(cBull, 15) : trendTxt == "BEAR" ? color.new(cBear, 15) : color.new(cGray, 30)
rankTxt = str.tostring(bullPower) + " / 7"
bearTxt = str.tostring(bearPower) + " / 7"

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "MODE", text_color=cWhite, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 0, isMVP ? "MVP" : "PRIME", text_color=cWhite, bgcolor=color.new(color.black, 10))
    table.cell(dash, 0, 1, "TREND", text_color=cWhite, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 1, trendTxt, text_color=color.white, bgcolor=trendBg)
    table.cell(dash, 0, 2, "BULL 7", text_color=cWhite, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 2, rankTxt, text_color=color.white, bgcolor=color.new(cBull, 35))
    table.cell(dash, 0, 3, "BEAR 7", text_color=cWhite, bgcolor=color.new(color.black, 10))
    table.cell(dash, 1, 3, bearTxt, text_color=color.white, bgcolor=color.new(cBear, 35))

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR COLORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barcolor(colorBars ? color.new(oscColor, 0) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, title="BUY Signal", message="Bystry Prime Oscillator: BUY signal on {{ticker}} / {{interval}}")
alertcondition(sellSignal, title="SELL Signal", message="Bystry Prime Oscillator: SELL signal on {{ticker}} / {{interval}}")
alertcondition(bullShift, title="Bullish Diamond Shift", message="Bystry Prime Oscillator: Bullish diamond shift on {{ticker}} / {{interval}}")
alertcondition(bearShift, title="Bearish Diamond Shift", message="Bystry Prime Oscillator: Bearish diamond shift on {{ticker}} / {{interval}}")
alertcondition(peakBuy, title="Peak Seeker Bullish", message="Bystry Prime Oscillator: bullish peak seeker on {{ticker}} / {{interval}}")
alertcondition(peakSell, title="Peak Seeker Bearish", message="Bystry Prime Oscillator: bearish peak seeker on {{ticker}} / {{interval}}")
alertcondition(bullDiv, title="Bullish Divergence", message="Bystry Prime Oscillator: bullish divergence on {{ticker}} / {{interval}}")
alertcondition(bearDiv, title="Bearish Divergence", message="Bystry Prime Oscillator: bearish divergence on {{ticker}} / {{interval}}")
````
