# ZENFlow ADX | Trend Strength & Directional Pressure

- url: https://www.tradingview.com/script/G1WtRJZR-ZENFlow-ADX-Trend-Strength-Directional-Pressure/
- type: indicator
- pine_id: PUB;e4245089fc5648c4b7f50943107072c6
- version: 1.0

## Description

ZENFlow ADX

ZENFlow ADX is an open-source ADX / DI trend-strength indicator designed to help traders read directional pressure, trend development, and possible trend-ending conditions.

This script is based on the classic ADX and Directional Movement concept, using +DI, -DI, ADX smoothing, and threshold levels to classify market conditions.

The goal of this indicator is not to predict price direction, but to make trend strength and directional pressure easier to read.

Core Logic

The indicator calculates:

• +DI
Directional strength from upward price movement.

• -DI
Directional strength from downward price movement.

• ADX
A smoothed measure of trend strength based on the difference between +DI and -DI.

• Range / Trend Thresholds
User-defined levels are used to separate lower-strength range conditions from stronger trend conditions.

How It Works

The ADX line changes color based on directional pressure and whether trend strength is increasing or decreasing.

• White ADX
The market is below the range threshold. Trend strength is not clear.

• Dark Green ADX
Bullish directional pressure is dominant and ADX is rising.

• Light Green ADX
Bullish directional pressure remains dominant, but ADX is not rising.

• Dark Red ADX
Bearish directional pressure is dominant and ADX is rising.

• Light Red ADX
Bearish directional pressure remains dominant, but ADX is not rising.

The area between +DI and -DI is also filled to make the dominant side easier to see visually.

Signal Markers

The script includes visual markers for:

• Bullish Trend
A bullish directional condition begins.

• Bearish Trend
A bearish directional condition begins.

• Strong Bullish Trend
Bullish directional pressure is dominant and above the trend threshold.

• Strong Bearish Trend
Bearish directional pressure is dominant and above the trend threshold.

• End Trend
A possible trend-ending condition appears when DI lines cross or ADX falls back into the range zone.

How to Use

Use the ADX line to check whether the market has enough trend strength.
Use +DI and -DI to identify which side has stronger directional pressure.
Use the color of the ADX line to see whether trend strength is increasing or fading.
Use signal markers as context alerts, not as automatic entry or exit instructions.
Combine this indicator with price structure, support/resistance, volatility, and risk management.

Suggested Interpretation

A stronger bullish trend condition appears when:

• ADX is above the trend threshold
• +DI is above -DI
• +DI is also above the trend level
• ADX is rising

A stronger bearish trend condition appears when:

• ADX is above the trend threshold
• -DI is above +DI
• -DI is also above the trend level
• ADX is rising

A lower-quality or range condition may appear when:

• ADX is below the range threshold
• +DI and -DI cross frequently
• ADX is flat or falling
• Directional pressure is unclear

Inputs

• ADX Smoothing
Controls the smoothing length of the ADX line.

• DI Length
Controls the calculation length for +DI and -DI.

• Level Range
Defines the ADX level used to identify lower-strength range conditions.

• Level Trend
Defines the DI level used to classify stronger directional pressure.

Alerts

The script includes alert conditions for:

• Any Alert
• Buy Weak Alert
• Sell Weak Alert
• Buy Strong Alert
• Sell Strong Alert
• Buy Close Alert
• Sell Close Alert

These alerts are intended to notify users when a condition appears. They should not be treated as standalone trading signals.

Limitations

This indicator does not predict future price movement.
It does not guarantee profitable trades.
It does not replace risk management.
It can produce false signals in choppy, low-volume, or highly volatile markets.
ADX and DI are lagging indicators and should be interpreted with market context.

This script is intended for educational and analytical use only.
It is not financial advice.

## Source Code

````pine
//@version=6
indicator(title='ZENFlow ADX', shorttitle='ZENFlowADX', overlay=false, format=format.price, precision=2, timeframe='')

// === Colors ===
color C_GREEN      = #006400
color C_GREENLIGHT = #388e3c
color C_RED        = #8B0000
color C_REDLIGHT   = #b71c1c

// === Inputs ===
i_sigLen  = input.int(14, 'ADX Smoothing')
i_diLen   = input.int(8,  'DI Length')
i_hlRange = input.int(25, 'Level Range')
i_hlTrend = input.int(25, 'Level Trend')

// === Functions ===
f_dirMov(_len) =>
    _up        = ta.change(high)
    _down      = -ta.change(low)
    _plusDM    = na(_up)   ? na : _up   > _down and _up   > 0 ? _up   : 0
    _minusDM   = na(_down) ? na : _down > _up   and _down > 0 ? _down : 0
    _trueRange = ta.rma(ta.tr(true), _len)
    _plus      = fixnan(100 * ta.rma(_plusDM,  _len) / _trueRange)
    _minus     = fixnan(100 * ta.rma(_minusDM, _len) / _trueRange)
    [_plus, _minus]

f_sig(_diLen, _sigLen) =>
    [_plus, _minus] = f_dirMov(_diLen)
    _sum = _plus + _minus
    100 * ta.rma(math.abs(_plus - _minus) / (_sum == 0 ? 1 : _sum), _sigLen)

// === Calculations ===
var float condition = 0.0

sig = f_sig(i_diLen, i_sigLen)
[diPlus, diMinus] = f_dirMov(i_diLen)

hlRange = sig <= i_hlRange
diUp    = diPlus  >= diMinus
diUpUp  = diPlus  >= i_hlTrend
diDn    = diMinus >  diPlus
diDnDn  = diMinus >  i_hlTrend
crossDi = ta.cross(diPlus, diMinus)
sigUp   = sig > sig[1]

sigDir =
     sig > sig[1] and diUp and not hlRange ?  1 :
     sig > sig[1] and diDn and not hlRange ? -1 : 0

// Rules
entryLong    = (not hlRange and diUp and sigUp and not diUp[1]) or (not hlRange and diUp and sigUp and sig > i_hlRange and hlRange[1])
entryShort   = (not hlRange and diDn and sigUp and not diDn[1]) or (not hlRange and diDn and sigUp and sig > i_hlRange and hlRange[1])
entryLongStr = not hlRange and diUp and sigUp and diUpUp
entryShortSt = not hlRange and diDn and sigUp and diDnDn
exitLong     = (crossDi and diUp[1]) or (hlRange and not hlRange[1])
exitShort    = (crossDi and diDn[1]) or (hlRange and not hlRange[1])

condition :=
     condition[1] !=  1   and entryLongStr ?  1   :
     condition[1] != -1   and entryShortSt ? -1   :
     condition[1] !=  0.5 and entryLong    ?  0.5 :
     condition[1] != -0.5 and entryShort   ? -0.5 :
     condition[1] !=  0   and exitLong     ?  0   :
     condition[1] !=  0   and exitShort    ?  0   : nz(condition[1])

longE     = barstate.isconfirmed and condition[1] !=  0.5 and condition ==  0.5
shortE    = barstate.isconfirmed and condition[1] != -0.5 and condition == -0.5
longEStr  = barstate.isconfirmed and condition[1] !=  1   and condition ==  1
shortEStr = barstate.isconfirmed and condition[1] != -1   and condition == -1
longX     = barstate.isconfirmed and ((condition[1] ==  0.5 and condition == 0) or (condition[1] ==  1 and condition == 0))
shortX    = barstate.isconfirmed and ((condition[1] == -0.5 and condition == 0) or (condition[1] == -1 and condition == 0))

// === Colors ===
// ADX line color
color c_sig = color.white
if hlRange
    c_sig := color.white
else if sigUp and diUp
    c_sig := color.new(C_GREEN, 0)
else if not sigUp and diUp
    c_sig := color.new(C_GREENLIGHT, 0)
else if sigUp and diDn
    c_sig := color.new(C_RED, 0)
else if not sigUp and diDn
    c_sig := color.new(C_REDLIGHT, 0)

// Fill color between +DI / -DI
color c_fillAdx = color.new(color.white, 90)
if hlRange
    c_fillAdx := color.new(color.white, 90)
else if not hlRange and diUp and diUpUp
    c_fillAdx := color.new(C_GREEN, 90)
else if not hlRange and diUp and not diUpUp
    c_fillAdx := color.new(C_GREENLIGHT, 90)
else if not hlRange and diDn and diDnDn
    c_fillAdx := color.new(C_RED, 90)
else if not hlRange and diDn and not diDnDn
    c_fillAdx := color.new(C_REDLIGHT, 90)

// === Plots ===
plot(sig, title='ADX', color=c_sig, linewidth=3)
p_diPlus  = plot(diPlus,  title='+DI', color=C_GREEN)
p_diMinus = plot(diMinus, title='-DI', color=C_RED)

fill(p_diPlus, p_diMinus, title='Fill ADX', color=c_fillAdx)

plot(crossDi ? diPlus : na, title='Cross Di', color=color.yellow, style=plot.style_circles, linewidth=2)

hline(i_hlRange, title='Level Range', color=color.gray, linestyle=hline.style_dotted, linewidth=1)
hline(i_hlTrend, title='Level Trend', color=color.gray, linestyle=hline.style_dotted, linewidth=1)

// ไม่มี barcolor อีกต่อไป

// === Alerts ===
// Alerts จะทำงานตลอด ไม่ต้องมี Alert On/Off
plotshape(longE ? i_hlTrend + 10 : na, title='Bullish\nTrend', color=C_GREEN, style=shape.triangleup, size=size.tiny, location=location.absolute)
plotshape(shortE ? i_hlTrend + 10 : na, title='Bearish\nTrend', color=C_RED, style=shape.triangledown, size=size.tiny, location=location.absolute)
plotshape(longEStr ? i_hlTrend + 10 : na, title='Strong\nBullish\nTrend', color=C_GREEN, style=shape.triangleup, size=size.small, location=location.absolute)
plotshape(shortEStr ? i_hlTrend + 10 : na, title='Strong\nBearish\nTrend', color=C_RED, style=shape.triangledown, size=size.small, location=location.absolute)
plotshape((longX or shortX) ? i_hlTrend + 10 : na, title='End\nTrend', color=color.new(color.orange, 0), style=shape.xcross, size=size.small, location=location.absolute)

alertcondition(longE or shortE or longEStr or shortEStr or longX or shortX, title='Any Alert', message='Any Alert')
alertcondition(longE, title='Buy Weak Alert', message='Buy Weak Alert')
alertcondition(shortE, title='Sell Weak Alert', message='Sell Weak Alert')
alertcondition(longEStr, title='Buy Strong Alert', message='Buy Strong Alert')
alertcondition(shortEStr, title='Sell Strong Alert', message='Sell Strong Alert')
alertcondition(longX, title='Buy Close Alert', message='Buy Close Alert')
alertcondition(shortX, title='Sell Close Alert', message='Sell Close Alert')
````
