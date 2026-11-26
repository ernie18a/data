# Trend-Aware Oscillator [Indicatr]

- url: https://www.tradingview.com/script/3be3uVSh-Trend-Aware-Oscillator-Indicatr/
- type: indicator
- pine_id: PUB;3a62f17c1dd0492eb5540b116789b1a7
- version: 1.0

## Description

[b]Trend-Aware Oscillator[/b] puts classic oscillators into the context of the prevailing trend. Overbought in an uptrend is shown as strength, oversold in a downtrend as weakness, and pullback signals are only marked in the direction of the trend - for long and short.

[b]WHAT IT DOES[/b]
Oscillators such as RSI or Stochastic are often read as "overbought = sell, oversold = buy". In trending markets this reading fails: an oscillator can stay overbought for weeks in an uptrend and oversold for weeks in a downtrend. This script adds a trend regime and changes how readings are coloured and signalled.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Choose one oscillator:[/b] RSI, Stochastic, Stochastic RSI, Williams %R, CCI, MFI, WaveTrend or Fisher Transform. All use their standard formulas.
[*][b]Trend filter[/b] classifies every bar as uptrend, downtrend or no trend:
EMA - price above a rising EMA (default 200) = uptrend, below a falling EMA = downtrend.
ADX / DMI - ADX above the threshold with +DI above -DI = uptrend, the opposite = downtrend.
EMA + ADX - both must agree.
[*][b]Uptrend:[/b] overbought readings are coloured as strength, not as a sell signal. A trend pullback long (green triangle) is marked when the oscillator dips below the uptrend pullback level and crosses back above it.
[*][b]Downtrend:[/b] oversold readings are coloured as weakness, not as a buy signal. A trend pullback short (red triangle) is marked when the oscillator rises above the downtrend pullback level and crosses back below it.
[*][b]No trend:[/b] classic overbought/oversold reversal marks can optionally be shown (grey circles).
[/list]
Each oscillator has its own default levels, e.g. RSI 70/30 with pullback levels 60/40, Williams %R -20/-80 with -30/-70. Custom levels can be set in the inputs.

[b]HOW TO USE[/b]
[list]
[*]Use it as a context tool: is an extreme reading more likely continuation or exhaustion, given the trend?
[*]Combine the pullback marks with your own entry rules, levels and risk management.
[*]Alerts: trend pullback long, trend pullback short, range long, range short.
[/list]

[b]THE CHART[/b]
BTCUSD daily with RSI 14 and the EMA 200 trend filter. Red background = downtrend regime, green background = uptrend regime. In the downtrend phase the red triangles mark RSI rejections from the 60 level (pullback short). After the regime turns up, RSI above 70 is coloured as strength instead of an exit signal.

[b]WHAT IS ORIGINAL[/b]
The built-in oscillators show readings without context. This script adds a selectable trend regime, regime-dependent colouring (strength/weakness instead of overbought/oversold), oscillator-specific pullback levels and symmetric long/short pullback logic. Combining eight oscillators in one script is intentional: the same trend logic is applied to interchangeable momentum sources so they can be compared on equal terms.

[b]CREDITS[/b]
RSI and ADX/DMI (J. Welles Wilder), Stochastic (George Lane), Williams %R (Larry Williams), CCI (Donald Lambert), MFI (Gene Quong and Avrum Soudack), Fisher Transform (John Ehlers). The WaveTrend calculation follows the community version popularised on TradingView by LazyBear; it is re-implemented here and credited accordingly.

[b]LIMITATIONS[/b]
[list]
[*]The trend filter lags by design - regime changes are confirmed after the move has started.
[*]In choppy markets the regime can switch often.
[*]Signals can appear and disappear on the current, unclosed bar.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Trend-Aware Oscillator [Indicatr]", shorttitle="TAO [Indicatr]", overlay=false, precision=2)

// ===== Inputs =====
grpO = "Oscillator"
oscType = input.string("RSI", "Oscillator", options=["RSI", "Stochastic", "Stochastic RSI", "Williams %R", "CCI", "MFI", "WaveTrend", "Fisher Transform"], group=grpO)
oscLen  = input.int(14, "Length", minval=2, group=grpO)
smoothK = input.int(3, "Smoothing (Stoch / Stoch RSI / WaveTrend)", minval=1, group=grpO)
useCustom = input.bool(false, "Use custom levels", group=grpO, tooltip="Off = sensible default levels for the selected oscillator.")
cOB  = input.float(70, "Custom overbought", group=grpO, inline="c1")
cOS  = input.float(30, "Custom oversold", group=grpO, inline="c1")
cPBH = input.float(60, "Custom pullback level (downtrend)", group=grpO, inline="c2")
cPBL = input.float(40, "Custom pullback level (uptrend)", group=grpO, inline="c2")

grpT = "Trend filter"
filterType = input.string("EMA", "Trend filter", options=["EMA", "ADX / DMI", "EMA + ADX"], group=grpT)
emaLen  = input.int(200, "EMA length", minval=10, group=grpT)
slopeBars = input.int(5, "EMA slope lookback (bars)", minval=1, group=grpT)
adxLen  = input.int(14, "ADX length", minval=2, group=grpT)
adxThr  = input.float(20, "ADX trend threshold", minval=1, group=grpT)

grpS = "Signals & display"
showTrendSig = input.bool(true, "Show trend pullback signals", group=grpS)
showRangeSig = input.bool(false, "Show classic OB/OS signals when no trend", group=grpS)
showBg       = input.bool(true, "Shade background by trend regime", group=grpS)

colUp   = input.color(#1B5E40, "Uptrend", group=grpS, inline="col")
colDn   = input.color(#C0412F, "Downtrend", group=grpS, inline="col")
colFlat = input.color(#8A8A8A, "No trend", group=grpS, inline="col")

// ===== Oscillators (all calculated every bar, then selected) =====
rsiV   = ta.rsi(close, oscLen)
stochV = ta.sma(ta.stoch(close, high, low, oscLen), smoothK)
srsiV  = ta.sma(ta.stoch(rsiV, rsiV, rsiV, oscLen), smoothK)
wprV   = ta.wpr(oscLen)
cciV   = ta.cci(hlc3, oscLen)
mfiV   = ta.mfi(hlc3, oscLen)

// WaveTrend (channel length = oscLen, average length = oscLen * 2, smoothed by smoothK)
esa  = ta.ema(hlc3, oscLen)
dev  = ta.ema(math.abs(hlc3 - esa), oscLen)
ci   = (hlc3 - esa) / (0.015 * math.max(dev, syminfo.mintick))
wt1  = ta.ema(ci, oscLen * 2)
wtV  = ta.sma(wt1, smoothK)

// Fisher Transform
hiH = ta.highest(hl2, oscLen)
loL = ta.lowest(hl2, oscLen)
var float fVal = 0.0
fVal := 0.66 * ((hl2 - loL) / math.max(hiH - loL, syminfo.mintick) - 0.5) + 0.67 * nz(fVal[1])
fVal := math.max(math.min(fVal, 0.999), -0.999)
var float fishV = 0.0
fishV := 0.5 * math.log((1 + fVal) / (1 - fVal)) + 0.5 * nz(fishV[1])

osc = switch oscType
    "RSI"              => rsiV
    "Stochastic"       => stochV
    "Stochastic RSI"   => srsiV
    "Williams %R"      => wprV
    "CCI"              => cciV
    "MFI"              => mfiV
    "WaveTrend"        => wtV
    => fishV

// Default levels per oscillator: [overbought, oversold, pullback level in downtrend, pullback level in uptrend]
[dOB, dOS, dPBH, dPBL] = switch oscType
    "RSI"              => [70.0, 30.0, 60.0, 40.0]
    "Stochastic"       => [80.0, 20.0, 70.0, 30.0]
    "Stochastic RSI"   => [80.0, 20.0, 80.0, 20.0]
    "Williams %R"      => [-20.0, -80.0, -30.0, -70.0]
    "CCI"              => [100.0, -100.0, 50.0, -50.0]
    "MFI"              => [80.0, 20.0, 60.0, 40.0]
    "WaveTrend"        => [60.0, -60.0, 40.0, -40.0]
    => [1.5, -1.5, 0.5, -0.5]

ob  = useCustom ? cOB  : dOB
os  = useCustom ? cOS  : dOS
pbH = useCustom ? cPBH : dPBH
pbL = useCustom ? cPBL : dPBL

// ===== Trend regime =====
ema = ta.ema(close, emaLen)
emaUp = close > ema and ema > ema[slopeBars]
emaDn = close < ema and ema < ema[slopeBars]
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxUp = adx > adxThr and diPlus > diMinus
adxDn = adx > adxThr and diMinus > diPlus

regime = switch filterType
    "EMA"       => emaUp ? 1 : emaDn ? -1 : 0
    "ADX / DMI" => adxUp ? 1 : adxDn ? -1 : 0
    => (emaUp and adxUp) ? 1 : (emaDn and adxDn) ? -1 : 0

// ===== Signals =====
// Uptrend: oscillator dips below the uptrend pullback level and crosses back up -> long pullback
// Downtrend: oscillator rises above the downtrend pullback level and crosses back down -> short pullback
xUpPB = ta.crossover(osc, pbL)
xDnPB = ta.crossunder(osc, pbH)
xUpOS = ta.crossover(osc, os)
xDnOB = ta.crossunder(osc, ob)
longPB     = showTrendSig and regime == 1  and xUpPB
shortPB    = showTrendSig and regime == -1 and xDnPB
rangeLong  = showRangeSig and regime == 0  and xUpOS
rangeShort = showRangeSig and regime == 0  and xDnOB

// Overbought in an uptrend = strength, oversold in a downtrend = weakness (not reversal signals)
strength = regime == 1  and osc > ob
weakness = regime == -1 and osc < os

lineCol = strength ? colUp : weakness ? colDn : regime == 1 ? color.new(colUp, 30) : regime == -1 ? color.new(colDn, 30) : colFlat

// ===== Plots =====
pOB = plot(ob, "Overbought", color=color.new(colFlat, 40))
pOS = plot(os, "Oversold",   color=color.new(colFlat, 40))
plot(pbH, "Pullback level (downtrend)", color=color.new(colDn, 60), style=plot.style_circles, linewidth=1)
plot(pbL, "Pullback level (uptrend)",   color=color.new(colUp, 60), style=plot.style_circles, linewidth=1)
fill(pOB, pOS, color=color.new(colFlat, 94), title="Neutral zone")

plot(osc, "Oscillator", color=lineCol, linewidth=2)

plotshape(longPB,    "Trend pullback long",  shape.triangleup,   location.bottom, colUp, size=size.tiny)
plotshape(shortPB,   "Trend pullback short", shape.triangledown, location.top,    colDn, size=size.tiny)
plotshape(rangeLong, "Range long (classic)", shape.circle,       location.bottom, colFlat, size=size.tiny)
plotshape(rangeShort,"Range short (classic)",shape.circle,       location.top,    colFlat, size=size.tiny)

bgcolor(showBg ? (regime == 1 ? color.new(colUp, 93) : regime == -1 ? color.new(colDn, 93) : na) : na, title="Trend regime")

// ===== Alerts =====
alertcondition(longPB,  "Trend pullback long",  "Trend-Aware Oscillator: pullback long in uptrend")
alertcondition(shortPB, "Trend pullback short", "Trend-Aware Oscillator: pullback short in downtrend")
alertcondition(rangeLong,  "Range long (classic)",  "Trend-Aware Oscillator: oversold reversal, no trend")
alertcondition(rangeShort, "Range short (classic)", "Trend-Aware Oscillator: overbought reversal, no trend")
````
