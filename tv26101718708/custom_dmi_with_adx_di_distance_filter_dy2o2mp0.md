# Custom DMI with ADX + DI Distance Filter

- url: https://www.tradingview.com/script/dY2o2mp0-Custom-DMI-with-ADX-DI-Distance-Filter/
- type: indicator
- pine_id: PUB;451354364b0f41d19ae061354a2bd5e2
- version: 1.0

## Description

This is to filter out the noise with ADX and identify strength

## Source Code

````pine
//@version=5
indicator("Custom DMI with ADX + DI Distance Filter", overlay=false)

// Input length
length = input.int(14, "DMI Length")
slopeThreshold = input.float(0.5, "Slope Sensitivity")   // slope filter
distanceThreshold = input.float(5.0, "DI Distance Filter") // minimum gap between DI+ and DI-

// DMI calculations
upMove   = high - high[1]
downMove = low[1] - low

plusDM   = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM  = (downMove > upMove and downMove > 0) ? downMove : 0.0

tr        = ta.rma(ta.tr, length)
plusDI    = 100 * ta.rma(plusDM, length) / tr
minusDI   = 100 * ta.rma(minusDM, length) / tr
adx       = ta.rma(math.abs(plusDI - minusDI) / (plusDI + minusDI) * 100, length)

// 🔎 ADX slope and DI distance
adxSlope     = adx - adx[1]
diDistance   = math.abs(plusDI - minusDI)

// 🔎 ADX dynamic color logic
// Green: ADX rising strongly, above 20, and DI distance wide enough
// Red: ADX falling strongly OR DI distance shrinking (noise filter)
// Gray: neutral zone
adxColor = (adx >= 20 and adxSlope > slopeThreshold and diDistance > distanceThreshold) ? color.green :
           (adxSlope < -slopeThreshold or diDistance <= distanceThreshold) ? color.red : color.gray

// Plot DI+ and DI-
plot(plusDI,  color=color.green, title="DI+")
plot(minusDI, color=color.red,   title="DI-")

// Plot ADX with dynamic color
plot(adx, title="ADX", color=adxColor, linewidth=2)

// Optional: horizontal guide lines
hline(20, "Trend Watch", color=color.gray, linestyle=hline.style_dotted)
hline(30, "Strong Trend", color=color.gray, linestyle=hline.style_dotted)
hline(40, "Very Strong Trend", color=color.gray, linestyle=hline.style_dotted)
hline(50, "Extreme Trend", color=color.gray, linestyle=hline.style_dotted)
````
