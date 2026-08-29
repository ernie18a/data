<!-- tradingview-pine-id: PUB;31d6cb0cf8ea4327addfe4a00df1e224 -->
<!-- tradingviewscripts-format: 1 -->
# Keltner Channel Clouds

Source: https://www.tradingview.com/script/eQNWsoyN-Keltner-Channel-Clouds/

## Description

Keltner Channel Clouds allows the user to apply up to 4 ATR Keltner Bands on the chart. It also allows for color changing and opacity of clouds. Lines also can be turned off for cleaner charts. The screenshot of this indicator is how I use it for day trading with VWAP to spot reversals and and/or trend exhaustion. I got tired of having lines on the chart. Also useful for swing trading. Good luck trading. Hope you enjoy

---

## Source Code

````pine
//@version=6
indicator(
     title      = "Keltner Channel Clouds",
     shorttitle = "KC Clouds",
     overlay    = true
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

string groupCalculation = "Calculation"
string groupDisplay     = "Display"
string groupLineColors  = "Line Colors"
string groupCloudColors = "Cloud Colors"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculation Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int lookback = input.int(
     defval  = 20,
     title   = "Lookback Candles",
     minval  = 1,
     maxval  = 100,
     group   = groupCalculation,
     tooltip = "EMA and ATR calculation length. Maximum: 100 candles."
)

source = input.source(
     defval = hlc3,
     title  = "Source",
     group  = groupCalculation
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Display Controls
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool showBasis = input.bool(
     defval = true,
     title  = "Show Center Line",
     group  = groupDisplay
)

bool showBandLines = input.bool(
     defval = true,
     title  = "Show Keltner Lines",
     group  = groupDisplay
)

bool shadeBand12 = input.bool(
     defval = true,
     title  = "Shade 1–2 Bands",
     group  = groupDisplay
)

bool shadeBand23 = input.bool(
     defval = true,
     title  = "Shade 2–3 Bands",
     group  = groupDisplay
)

bool shadeBand34 = input.bool(
     defval = true,
     title  = "Shade 3–4 Bands",
     group  = groupDisplay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Line Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color basisColor = input.color(
     defval = color.blue,
     title  = "Center Line",
     group  = groupLineColors
)

color upper1Color = input.color(
     defval = color.red,
     title  = "Upper 1",
     inline = "Upper12",
     group  = groupLineColors
)

color upper2Color = input.color(
     defval = color.red,
     title  = "Upper 2",
     inline = "Upper12",
     group  = groupLineColors
)

color upper3Color = input.color(
     defval = color.red,
     title  = "Upper 3",
     inline = "Upper34",
     group  = groupLineColors
)

color upper4Color = input.color(
     defval = color.red,
     title  = "Upper 4",
     inline = "Upper34",
     group  = groupLineColors
)

color lower1Color = input.color(
     defval = color.green,
     title  = "Lower 1",
     inline = "Lower12",
     group  = groupLineColors
)

color lower2Color = input.color(
     defval = color.green,
     title  = "Lower 2",
     inline = "Lower12",
     group  = groupLineColors
)

color lower3Color = input.color(
     defval = color.green,
     title  = "Lower 3",
     inline = "Lower34",
     group  = groupLineColors
)

color lower4Color = input.color(
     defval = color.green,
     title  = "Lower 4",
     inline = "Lower34",
     group  = groupLineColors
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cloud Colors
// Transparency is adjustable in each color picker.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color upper12CloudColor = input.color(
     defval = color.new(color.red, 88),
     title  = "Upper 1–2",
     inline = "Cloud12",
     group  = groupCloudColors
)

color lower12CloudColor = input.color(
     defval = color.new(color.green, 88),
     title  = "Lower 1–2",
     inline = "Cloud12",
     group  = groupCloudColors
)

color upper23CloudColor = input.color(
     defval = color.new(color.red, 84),
     title  = "Upper 2–3",
     inline = "Cloud23",
     group  = groupCloudColors
)

color lower23CloudColor = input.color(
     defval = color.new(color.green, 84),
     title  = "Lower 2–3",
     inline = "Cloud23",
     group  = groupCloudColors
)

color upper34CloudColor = input.color(
     defval = color.new(color.red, 80),
     title  = "Upper 3–4",
     inline = "Cloud34",
     group  = groupCloudColors
)

color lower34CloudColor = input.color(
     defval = color.new(color.green, 80),
     title  = "Lower 3–4",
     inline = "Cloud34",
     group  = groupCloudColors
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Keltner Channel Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float basis    = ta.ema(source, lookback)
float atrValue = ta.atr(lookback)

float upper1 = basis + atrValue
float upper2 = basis + atrValue * 2.0
float upper3 = basis + atrValue * 3.0
float upper4 = basis + atrValue * 4.0

float lower1 = basis - atrValue
float lower2 = basis - atrValue * 2.0
float lower3 = basis - atrValue * 3.0
float lower4 = basis - atrValue * 4.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Center Line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     series    = showBasis ? basis : na,
     title     = "EMA Center Line",
     color     = basisColor,
     linewidth = 2
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Upper Channel Lines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pUpper1 = plot(
     series = upper1,
     title  = "Upper 1 ATR",
     color  = showBandLines ? upper1Color : na
)

pUpper2 = plot(
     series = upper2,
     title  = "Upper 2 ATR",
     color  = showBandLines ? upper2Color : na
)

pUpper3 = plot(
     series = upper3,
     title  = "Upper 3 ATR",
     color  = showBandLines ? upper3Color : na
)

pUpper4 = plot(
     series = upper4,
     title  = "Upper 4 ATR",
     color  = showBandLines ? upper4Color : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Lower Channel Lines
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pLower1 = plot(
     series = lower1,
     title  = "Lower 1 ATR",
     color  = showBandLines ? lower1Color : na
)

pLower2 = plot(
     series = lower2,
     title  = "Lower 2 ATR",
     color  = showBandLines ? lower2Color : na
)

pLower3 = plot(
     series = lower3,
     title  = "Lower 3 ATR",
     color  = showBandLines ? lower3Color : na
)

pLower4 = plot(
     series = lower4,
     title  = "Lower 4 ATR",
     color  = showBandLines ? lower4Color : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Upper Clouds
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fill(
     pUpper1,
     pUpper2,
     title = "Upper 1–2 Cloud",
     color = shadeBand12 ? upper12CloudColor : na
)

fill(
     pUpper2,
     pUpper3,
     title = "Upper 2–3 Cloud",
     color = shadeBand23 ? upper23CloudColor : na
)

fill(
     pUpper3,
     pUpper4,
     title = "Upper 3–4 Cloud",
     color = shadeBand34 ? upper34CloudColor : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Lower Clouds
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fill(
     pLower1,
     pLower2,
     title = "Lower 1–2 Cloud",
     color = shadeBand12 ? lower12CloudColor : na
)

fill(
     pLower2,
     pLower3,
     title = "Lower 2–3 Cloud",
     color = shadeBand23 ? lower23CloudColor : na
)

fill(
     pLower3,
     pLower4,
     title = "Lower 3–4 Cloud",
     color = shadeBand34 ? lower34CloudColor : na
)
````
