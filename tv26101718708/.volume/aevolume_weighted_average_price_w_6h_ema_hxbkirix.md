# AE_Volume Weighted Average Price w 6H & EMA

- url: https://www.tradingview.com/script/HxbkiRix-AE-Volume-Weighted-Average-Price-w-6H-EMA/
- type: indicator
- pine_id: PUB;e182d025e2b049e0a798aa2bb1ab3bc7
- version: 1.0

## Description

AE_VWAP w 6H & EMA

Description
AE_VWAP w 6H & EMA
A simple VWAP-based context tool combining:
• Session VWAP
• 6H VWAP
• EMA 9
• EMA 21
• Optional VWAP deviation bands

The 6H VWAP provides a higher-timeframe intraday reference, while Session VWAP provides current-session context. EMA 9 and EMA 21 can be used as additional short-term structure references.
The VWAP bands are optional and can be calculated using Standard Deviation or Percentage.
This indicator was developed and coded with the assistance of ChatGPT.

MyToolsMyRulesMyLife

How to use / Help

6H VWAP
Use the 6H VWAP as an intraday higher-timeframe reference.

Session VWAP
Use Session VWAP to understand where price is trading relative to the current session's volume-weighted average.

EMA 9 / EMA 21
Configurable short-term moving averages that can be used to observe price structure and momentum.

VWAP Bands
Optional bands provide additional context around Session VWAP. They can be calculated using Standard Deviation or Percentage.

Suggested workflow
Start with price structure. Use the 6H VWAP and Session VWAP as reference points, then use EMA 9/21 and the optional bands as additional context.

This tool does not generate automatic buy/sell signals.

Other AE MyTools

AE_Multi Range 90m
Identifies predefined intraday 90-minute ranges and projects their High, Low and CE levels. The levels are intended as structural reference points for observing price reaction, breakouts and retests.

AE_RSI HARMONY
A visual RSI-based structure tool designed to help observe RSI behavior, momentum, extremes and divergence-related structure. It is intended as additional context alongside price action rather than as a standalone signal generator.

AE_VWAP w 6H & EMA
Combines Session VWAP, 6H VWAP and EMA 9/21 to provide another layer of intraday structure and context.

Risk Disclaimer
Educational / informational purposes only.
This indicator is not investment advice and does not provide personalized investment recommendations or guaranteed buy/sell/hold signals. Trading financial markets involves substantial risk, and past performance does not guarantee future results. Always use appropriate risk management and make your own independent trading decisions. The responsibility for any investment or trading decision remains entirely with the user.

## Source Code

````pine
//@version=6

indicator(title="AE_Volume Weighted Average Price w 6H & EMA", shorttitle="AE_VWAP w 6H & EMA", overlay=true, timeframe="", timeframe_gaps=true)

hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings", display = display.none)

src = input(title = "Source", defval = hlc3, group="VWAP Settings", display = display.none)

offset = input.int(0, title="Offset", group="VWAP Settings", display = display.none)


//────────────────────────────────────────────────────────────
// 6H VWAP SETTINGS
//────────────────────────────────────────────────────────────

show6H = input.bool(true, title="Show 6H VWAP", group="VWAP Settings")

color6H = input.color(color.orange, title="6H VWAP Color", group="VWAP Settings")

width6H = input.int(2, title="6H VWAP Width", minval=1, maxval=5, group="VWAP Settings")


//────────────────────────────────────────────────────────────
// BANDS SETTINGS
//────────────────────────────────────────────────────────────

BANDS_GROUP = "Bands Settings"

CALC_MODE_TOOL_TIP = "Determines the units used to calculate the distance of the bands. When 'Percentage' is selected, a multiplier of 1 means 1%."

calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode", options = ["Standard Deviation", "Percentage"], group = BANDS_GROUP, tooltip = CALC_MODE_TOOL_TIP, display = display.none)

showBand_1 = input(true, title = "", group = BANDS_GROUP, inline = "band_1", display = display.none)

bandMult_1 = input.float(1.0, title = "Bands Multiplier #1", group = BANDS_GROUP, inline = "band_1", step = 0.5, minval=0, display = display.none, active = showBand_1)

showBand_2 = input(false, title = "", group = BANDS_GROUP, inline = "band_2", display = display.none)

bandMult_2 = input.float(2.0, title = "Bands Multiplier #2", group = BANDS_GROUP, inline = "band_2", step = 0.5, minval=0, display = display.none, active = showBand_2)

showBand_3 = input(false, title = "", group = BANDS_GROUP, inline = "band_3", display = display.none)

bandMult_3 = input.float(3.0, title = "Bands Multiplier #3", group = BANDS_GROUP, inline = "band_3", step = 0.5, minval=0, display = display.none, active = showBand_3)


//────────────────────────────────────────────────────────────
// VOLUME CHECK
//────────────────────────────────────────────────────────────

cumVolume = ta.cum(volume)

if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")


//────────────────────────────────────────────────────────────
// SESSION VWAP
//────────────────────────────────────────────────────────────

isNewSession = timeframe.change("D")


//────────────────────────────────────────────────────────────
// 6H VWAP
// Fixed 6-hour periods
//────────────────────────────────────────────────────────────

isNew6H = timeframe.change("360")

// ─────────────────────────────────────
// EMA — configurable length
// ─────────────────────────────────────

emaLength1 = input.int(9, "EMA Length", minval=1, group="EMA Settings")

ema = ta.ema(close, emaLength1)

plot(ema, title="EMA1", color=color.black, linewidth=2)

emaLength2 = input.int(21, "EMA Length", minval=1, group="EMA Settings")

ema2 = ta.ema(close, emaLength2)

plot(ema2, title="EMA2", color=color.blue, linewidth=2)

//────────────────────────────────────────────────────────────
// INITIAL VALUES
//────────────────────────────────────────────────────────────

float vwapValue = na
float vwap6HValue = na

float upperBandValue1 = na
float lowerBandValue1 = na

float upperBandValue2 = na
float lowerBandValue2 = na

float upperBandValue3 = na
float lowerBandValue3 = na


//────────────────────────────────────────────────────────────
// VWAP CALCULATIONS
//────────────────────────────────────────────────────────────

if not (hideonDWM and timeframe.isdwm)

    // Session VWAP
    [_sessionVwap, _sessionStdevUpper, _] = ta.vwap(src, isNewSession, 1)

    vwapValue := _sessionVwap

    stdevAbs = _sessionStdevUpper - _sessionVwap

    bandBasis = calcModeInput == "Standard Deviation" ? stdevAbs : _sessionVwap * 0.01

    upperBandValue1 := _sessionVwap + bandBasis * bandMult_1
    lowerBandValue1 := _sessionVwap - bandBasis * bandMult_1

    upperBandValue2 := _sessionVwap + bandBasis * bandMult_2
    lowerBandValue2 := _sessionVwap - bandBasis * bandMult_2

    upperBandValue3 := _sessionVwap + bandBasis * bandMult_3
    lowerBandValue3 := _sessionVwap - bandBasis * bandMult_3


    // 6H VWAP
    [_6hVwap, _, _] = ta.vwap(src, isNew6H, 1)

    vwap6HValue := _6hVwap


//────────────────────────────────────────────────────────────
// VWAP PLOTS
//────────────────────────────────────────────────────────────

// Session VWAP
plot(vwapValue, title = "VWAP", color = #2962FF, offset = offset)

// 6H VWAP
plot(show6H ? vwap6HValue : na,
     title = "6H VWAP",
     color = color6H,
     linewidth = width6H,
     offset = offset)


//────────────────────────────────────────────────────────────
// BANDS #1
//────────────────────────────────────────────────────────────

displayBand1 = showBand_1 ? display.all : display.none

upperBand_1 = plot(
     upperBandValue1,
     title="Upper Band #1",
     color = color.green,
     offset = offset,
     display = displayBand1,
     editable = showBand_1)

lowerBand_1 = plot(
     lowerBandValue1,
     title="Lower Band #1",
     color = color.green,
     offset = offset,
     display = displayBand1,
     editable = showBand_1)

fill(
     upperBand_1,
     lowerBand_1,
     title="Bands Fill #1",
     color = color.new(color.green, 95),
     display = displayBand1,
     editable = showBand_1)


//────────────────────────────────────────────────────────────
// BANDS #2
//────────────────────────────────────────────────────────────

displayBand2 = showBand_2 ? display.all : display.none

upperBand_2 = plot(
     upperBandValue2,
     title="Upper Band #2",
     color = color.olive,
     offset = offset,
     display = displayBand2,
     editable = showBand_2)

lowerBand_2 = plot(
     lowerBandValue2,
     title="Lower Band #2",
     color = color.olive,
     offset = offset,
     display = displayBand2,
     editable = showBand_2)

fill(
     upperBand_2,
     lowerBand_2,
     title="Bands Fill #2",
     color = color.new(color.olive, 95),
     display = displayBand2,
     editable = showBand_2)


//────────────────────────────────────────────────────────────
// BANDS #3
//────────────────────────────────────────────────────────────

displayBand3 = showBand_3 ? display.all : display.none

upperBand_3 = plot(
     upperBandValue3,
     title="Upper Band #3",
     color = color.teal,
     offset = offset,
     display = displayBand3,
     editable = showBand_3)

lowerBand_3 = plot(
     lowerBandValue3,
     title="Lower Band #3",
     color = color.teal,
     offset = offset,
     display = displayBand3,
     editable = showBand_3)

fill(
     upperBand_3,
     lowerBand_3,
     title="Bands Fill #3",
     color = color.new(color.teal, 95),
     display = displayBand3,
     editable = showBand_3)
````
