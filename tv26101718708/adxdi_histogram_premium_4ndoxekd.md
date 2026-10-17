# ADX/DI Histogram [Premium]

- url: https://www.tradingview.com/script/4NdOxekd-ADX-DI-Histogram-Premium/
- type: indicator
- pine_id: PUB;ab89e289162442e0bc6c18fb072fe450
- version: 4.0

## Description

[image]https://www.tradingview.com/x/cqJZmRWR/[/image]

⚡ [b]Key Features[/b]
[b]Directional Pressure Histogram[/b]
[list]
[*]Teal = bullish control
[*]Red = bearish control
[*]Bar expansion = increasing momentum
[*]Compression = weakening or chop
[*]Built-In Trend Intelligence
[/list]
[b]Automatically classifies trend as:[/b]
[list]
[*]Weak
[*]Building
[*]Moderate
[*]Strong
[*]Extreme
[/list]
[b]Minimalist Professional Design[/b]
[list]
[*]No unnecessary lines
[*]No cluttered DI crossings
[*]Optimized for fast decision-making
[*]Integrated Trend Panel
[*]Displays:
[*]Market bias (Bullish / Bearish / Neutral)
[*]Current ADX value
[*]Interpreted strength level
[/list]

🧠 [b]Why This Indicator Exists[/b]
Traditional ADX is powerful — but hard to use in real time.
This script focuses on what actually matters:
Direction (Who is in control?)
Strength (Is the trend tradable?)
Momentum (Is pressure increasing or fading?)
Everything else is removed.

🎯 [b]How to Use[/b]
Best used as a confirmation tool, not a standalone signal.
Combine with:
[list]
[*]Market structure (break of structure / CHOCH)
[*]Fair Value Gaps (FVG)
[*]Session highs & lows
[*]Trend-following systems
[*]Multi-timeframe alignment
[/list]

⚠️ [b]Important Notes[/b]
[list]
[*]Weak conditions = avoid forcing trades
[*]Strong expansion = trend continuation potential
[*]Direction ≠ entry signal — always confirm with structure
[/list]

🧩 [b]Design Philosophy[/b]
[list]
[*]Clean > Complex
[*]This indicator was built to:
[*]Reduce noise
[*]Improve clarity
[*]Speed up decisions
[*]Feel like a professional tool
[/list]

## Source Code

````pine
//@version=6
indicator("ADX/DI Histogram [Premium]", overlay=false, scale=scale.left)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

len         = input.int(14, "Length", minval=1)
threshold   = input.int(25, "ADX Threshold", minval=1)
showADX     = input.bool(false, "Show ADX Line")
showDILine  = input.bool(false, "Show DI Bias Line")
showBg      = input.bool(false, "Show Background Bias")
showZones   = input.bool(true, "Show Strength Zones")
showPanel   = input.bool(true, "Show Trend Panel")

colorTheme = input.string(
     "Graphite",
     "Color Theme",
     options=["Graphite", "Classic Navy"],
     group="Appearance",
     tooltip="Controls the histogram, DI line, background bias, and dashboard signal colors. Graphite uses the refined teal and magenta palette, while Classic Navy restores the original published colors.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Color Theme
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isGraphite = colorTheme == "Graphite"

BULL_COLOR    = isGraphite ? #26C6B8 : #00c89b
BEAR_COLOR    = isGraphite ? #A83A68 : #f23645
NEUTRAL_COLOR = isGraphite ? #667582 : #636b79

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADX / DI Calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trueRange = math.max(
     math.max(high - low, math.abs(high - nz(close[1]))),
     math.abs(low - nz(close[1])))

dmPlus =
     high - nz(high[1]) > nz(low[1]) - low
     ? math.max(high - nz(high[1]), 0)
     : 0

dmMinus =
     nz(low[1]) - low > high - nz(high[1])
     ? math.max(nz(low[1]) - low, 0)
     : 0

smTR      = ta.rma(trueRange, len)
smDMPlus  = ta.rma(dmPlus, len)
smDMMinus = ta.rma(dmMinus, len)

diPlus  = smDMPlus / smTR * 100
diMinus = smDMMinus / smTR * 100

dx =
     math.abs(diPlus - diMinus) /
     math.max(diPlus + diMinus, 0.000001) * 100

adx = ta.sma(dx, len)

// Histogram centered around threshold
diBias = threshold + (diPlus - diMinus)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullBias    = diPlus > diMinus
bearBias    = diMinus > diPlus
neutralBias = math.abs(diPlus - diMinus) < 3

weakTrend     = adx < 20
buildingTrend = adx >= 20 and adx < threshold
moderateTrend = adx >= threshold and adx < 35
strongTrend   = adx >= 35 and adx < 50
extremeTrend  = adx >= 50

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Histogram Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color bullColor = na

if weakTrend
    bullColor := color.new(BULL_COLOR, 65)
else if buildingTrend
    bullColor := color.new(BULL_COLOR, 45)
else if moderateTrend
    bullColor := color.new(BULL_COLOR, 35)
else if strongTrend
    bullColor := color.new(BULL_COLOR, 10)
else
    bullColor := color.new(BULL_COLOR, 0)

color bearColor = na

if weakTrend
    bearColor := color.new(BEAR_COLOR, 65)
else if buildingTrend
    bearColor := color.new(BEAR_COLOR, 45)
else if moderateTrend
    bearColor := color.new(BEAR_COLOR, 35)
else if strongTrend
    bearColor := color.new(BEAR_COLOR, 10)
else
    bearColor := color.new(BEAR_COLOR, 0)

histColor = bullBias ? bullColor : bearColor

diLineColor =
     bullBias
     ? color.new(BULL_COLOR, 0)
     : color.new(BEAR_COLOR, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Optional Background Bias
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bgcolor(
     showBg and bullBias and adx >= threshold
     ? color.new(BULL_COLOR, 92)
     : na)

bgcolor(
     showBg and bearBias and adx >= threshold
     ? color.new(BEAR_COLOR, 92)
     : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Strength Zones
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

hline(
     threshold,
     "Trend Threshold",
     color=color.new(color.white, 65),
     linestyle=hline.style_dashed)

hline(
     35,
     "Strong Trend",
     color=showZones ? color.new(color.white, 82) : na,
     linestyle=hline.style_dotted)

hline(
     50,
     "Extreme Trend",
     color=showZones ? color.new(color.white, 88) : na,
     linestyle=hline.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     diBias,
     title="DI Bias Histogram",
     style=plot.style_histogram,
     histbase=threshold,
     linewidth=4,
     color=histColor,
     display=display.all - display.price_scale)

plot(
     showDILine ? diBias : na,
     title="DI Bias Line",
     color=color.new(diLineColor, 10),
     linewidth=2)

plot(
     showADX ? adx : na,
     title="ADX",
     color=color.new(color.gray, 70),
     linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendText =
     neutralBias ? "NEUTRAL" :
     bullBias ? "BULLISH" :
     "BEARISH"

trendColor =
     neutralBias ? color.new(NEUTRAL_COLOR, 20) :
     bullBias ? color.new(BULL_COLOR, 0) :
     color.new(BEAR_COLOR, 0)

trendBg =
     neutralBias ? color.new(NEUTRAL_COLOR, 82) :
     bullBias ? color.new(BULL_COLOR, 82) :
     color.new(BEAR_COLOR, 82)

strengthText =
     weakTrend ? "Weak" :
     buildingTrend ? "Building" :
     moderateTrend ? "Moderate" :
     strongTrend ? "Strong" :
     "Extreme"

strengthColor =
     weakTrend ? color.new(NEUTRAL_COLOR, 10) :
     buildingTrend ? color.new(color.yellow, 0) :
     moderateTrend ? color.new(BULL_COLOR, 0) :
     strongTrend ? color.new(color.lime, 0) :
     color.new(color.green, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Premium Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

panelBg     = color.new(#111317, 0)
labelBg     = color.new(#15181d, 0)
borderColor = color.new(#3a3f46, 0)

var table panel = table.new(
     position.top_right,
     2,
     3,
     border_width=1,
     frame_color=borderColor,
     border_color=borderColor)

if barstate.islast and showPanel
    table.cell(
         panel, 0, 0, "Trend",
         text_color=color.white,
         bgcolor=labelBg,
         text_size=size.normal)

    table.cell(
         panel, 1, 0, trendText,
         text_color=trendColor,
         bgcolor=trendBg,
         text_size=size.normal)

    table.cell(
         panel, 0, 1, "ADX",
         text_color=color.white,
         bgcolor=labelBg,
         text_size=size.normal)

    table.cell(
         panel, 1, 1, str.tostring(adx, "#.0"),
         text_color=color.white,
         bgcolor=panelBg,
         text_size=size.normal)

    table.cell(
         panel, 0, 2, "Strength",
         text_color=color.white,
         bgcolor=labelBg,
         text_size=size.normal)

    table.cell(
         panel, 1, 2, strengthText,
         text_color=strengthColor,
         bgcolor=panelBg,
         text_size=size.normal)
````
