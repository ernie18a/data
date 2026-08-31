<!-- tradingview-pine-id: PUB;fe9368b0b7484387a3a48f17a72c8dc4 -->
<!-- tradingviewscripts-format: 1 -->
# Signs of the Times [LucF]

Source: https://www.tradingview.com/script/ZKF0qji2-Signs-of-the-Times-LucF/

## Description

█ OVERVIEW

This oscillator calculates the directional strength of bars using a primitive weighing mechanism based on a small number of what I consider to be fundamental properties of a bar. It does not consider the amplitude of price movements, so can be used as a complement to momentum-based oscillators. It thus belongs to the same family of indicators as my [Bar Balance](https://www.tradingview.com/script/lcgCwWwI-Bar-Balance-LucF/), [​Volume Ticks](https://www.tradingview.com/script/1ul3GgrZ-Volume-Ticks-Increasing-Volume-Bar-Count-LucF/), [Efficient work](https://www.tradingview.com/script/yG0rpNzO-Efficient-Work-LucF/), [​Volume Buoyancy](https://www.tradingview.com/script/18fu8TxD-Volume-Buoyancy-LucF/) or my Delta ​Volume indicators.

█ CONCEPTS

The calculations underlying Signs of the Times (SOTT) use a simple, oft-explored concept: measure bar attributes, assign a weight to them, and aggregate results to provide an evaluation of a bar's directional strength. Bull and bear weights are added independently, then subtracted and divided by the maximum possible weight, so the final calculation looks like this:[pine]
(up - ​dn) / weightRange[/pine]

SOTT has a zero centerline and oscillates between +1 and -1. Ten elementary properties are evaluated. Most carry a weight of one, a few are doubly weighted. All properties are evaluated using only the current bar's values or by comparing its values to those of the preceding bar. The bull conditions follow; their inverse applies to bear conditions:

 Weight of 1
 • Bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is greater than the bar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) (bar is considered to be of "up" polarity)
 • Rising [open](https://www.tradingview.com/pine-script-reference/v5/#var_open)
 • Rising [high](https://www.tradingview.com/pine-script-reference/v5/#var_high)
 • Rising [low](https://www.tradingview.com/pine-script-reference/v5/#var_low)
 • Rising [close](https://www.tradingview.com/pine-script-reference/v5/#var_close)
 • Bar is up and its body size is greater than that of the previous bar
 • Bar is up and its body size is greater than the combined size of wicks

 Weight of 2
 • Gap to the upside
 • [Efficient Work](https://www.tradingview.com/script/yG0rpNzO-Efficient-Work-LucF/) when it is positive
 • Bar is up and ​volume is greater than that of the previous bar (this only kicks in if ​volume is actually available on the chart's data feed)

Except for the Efficient Work weight, which is a +1 to -1 float value multiplied by 2, all weights are discrete; either zero or the full weight of 1 or 2 is generated. This will cause any gap, for example, to generate a weight of +2 or -2, regardless of the gap's size. That is the reason why the oscillator is oblivious to the amplitude of price movements.

You can see the code used to calculate SOTT in my [ta library](https://www.tradingview.com/script/UZQxuS7X-ta/)'s `sott()` function.

█ HOW TO USE THE INDICATOR

No videos explain this indicator and none are planned; reading this description or the script's code is the only way to understand what Signs of the Times does.

Load the indicator on an active chart (see [here](https://www.tradingview.com/u/?solution=43000555216) if you don't know how).

The default configuration displays:
 • An Arnaud-Legoux moving average of length 20 of the instant SOTT value. This is the signal line.
 • A fill between the MA and the centerline.
 • Levels at arbitrary values of +0.3 and -0.3.
 • A channel between the signal line and its MA (a simple MA of length 20), which can be one of four colors:
  • Bull (green): The signal line is above its MA.
  • Strong bull (lime): The bull condition is fulfilled and the signal line is above the centerline.
  • Bear (red): The signal line is below its MA.
  • Strong bear (pink): The bear condition is fulfilled and the signal line is below the centerline.

The script's "Inputs" tab allows you to:
 • Choose a higher timeframe to calculate the indicator's values. This can be useful to get a wider perspective of the indicator's values.
  If you elect to use a higher timeframe, make sure that your chart's timeframe is always lower than the higher timeframe you specified, 
  as calculating on a timeframe lower than the chart's does not make much sense because the indicator is then displaying only the value of the last intrabar in the chart bar.
 • Specify the type of MA used to produce the signal line. Use a length of 1 or the Data Window to see the instant value of SOTT. It is quite noisy, thus the need to average it.
 • Specify the type of MA applied to the signal line. The idea here is to provide context to the signal.
 • Control the display and colors of the lines and fills.

The first pane of this publication's chart shows the default setup. The second one shows only a monochrome signal line.

Using the "Style" tab of the indicator's settings, you can change the type and width of the lines, and the level values.

█ INTERPRETATION

Remember that Signs of the Times evaluates directional bar strength — not price movement. Its highs and lows do not reflect price, but the strength of chart bars. The fact that SOTT knows nothing of how far price moves or of trends is easy to forget. As such, I think SOTT is best used as a confirmation tool. Chart movements may appear to be easy to read when looking at historical bars, but when you have to make go-no-go decisions on the last bar, the landscape often becomes murkier. By providing a quantitative evaluation of the strength of the last few bars, which is not always easily discernible by simply looking at them, SOTT aims to help you decide if the short-term past favors the bets you are considering. Can SOTT predict the future? Of course not.

While SOTT uses completely different calculations than classical momentum oscillators, its profile shares many of their characteristics. This could lead one to infer that directional bar strength correlates with price movement, which could in turn lead one to conclude that indicators such as this one are useless, or that they can be useful tools to confirm momentum oscillators or other models of price movement. The call is, of course, up to you. You can try, for example, to compare a Wilder MA of SOTT to an RSI of the same length.

One key difference with momentum oscillators is that SOTT is much less sensitive to large price movements. The default Arnaud-Legoux MA used for the signal line makes it quite active; you can use a more quiet SMA or EMA if you prefer to tone it down.

In systems where it can be useful to only enter or exit on short-term strength, an average of SOTT values over the last 3 to 5 bars can be used as a more quiet filter than a momentum oscillator would.

█ NOTES

My publications often go through a long gestation period where I use them on my charts or in systems before deciding if they are worth a publication. With an incubation period of more than three years, Signs of the Times holds the record. The properties SOTT currently evaluates result from the systematic elimination of contaminants over that lengthy period of time. It was long because of my usual, slow gear, but also because I had to try countless combinations of conditions before realizing that, contrary to my intuition, best results were achieved by:
 • Keeping the number of evaluated properties to the absolute minimum.
 • Limiting the evaluation's ​scope to the current and preceding bar.
 • Choosing properties that, in my view, were unmistakably indicative of ​bullish/​bearish conditions.

Repainting

As most oscillators, the indicator provides live realtime values that will recalculate with chart updates. It will thus repaint in real time, but not on historical values. To learn more about repainting, see the [Pine Script™ User Manual's page on the subject](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html).

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LucF

//@version=5

indicator("Signs of the Times [LucF]", "SOTT", timeframe = "", timeframe_gaps = false, precision = 2)

// Signs of the Times [LucF]
// v2, 2022.11.06 12:54 — LucF

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html


import LucF/ta/2 as LucfTa



//#region ———————————————————— Constants and inputs


// Key levels
float LEVEL_MID =  0.0
float LEVEL_HI  =  0.3
float LEVEL_LO  = -0.3

// Colors
color BLUE    = #3179f5
color BLUE_DK = #013bca
color GRAY    = #434651
color GRAY_LT = #9598a1
color GREEN   = #006200
color LIME    = #3CEB14
color MAROON  = #800000
color ORANGE  = #e65100
color PINK    = #FF0080
color PURPLE  = #C314EB
color YELLOW  = #fbc02d

// MAs
string MA01 = "Simple MA"
string MA02 = "Exponential MA"
string MA03 = "Wilder MA"
string MA04 = "Weighted MA"
string MA05 = "Volume-weighted MA"
string MA06 = "Arnaud Legoux MA"
string MA07 = "Hull MA"
string MA08 = "Symmetrically-weighted MA"

// Bar coloring modes
string CB1 = "SOTT MA"
string CB2 = "MA of MA"
string CB3 = "Channel fill"
string CB4 = "MA fill"

// Tooltips
string TT_SIGNAL  = "You specify here the type and length of the MA you want applied to the instant SOTT value. 
  You can view the instant value by using a length of 1.
  \n\nNOTE: The length of this MA must be smaller than that of the second MA defined below.
  \n\n'🡑' and '🡓' indicate bull/bear conditions, which occur when the line is above/below the centerline."
string TT_MA      = "You specify here the type and length of the MA you want applied to the MA of SOTT defined above, so this is an MA of an MA.
  \n\n'🡑' and '🡓' indicate bull/bear conditions, which occur when the line is above/below the centerline."
string TT_CHANNEL = "'🡑' and '🡓' indicate bull/bear conditions, which occur when the first MA is above/below the second MA while not also being above/below the centerline.
  \n\n'🡑🡑' and '🡓🡓' indicate strong bull/bear conditions, which require the first MA to be above/below the second MA, and above/below the centerline."
string TT_MAFILL  = "'🡑' and '🡓' indicate bull/bear conditions, which occur when the second MA is above/below the centerline."

// Inputs
bool    signalShowInput         = input.bool(true,      "SOTT MA",      inline = "signal")
color   signalUpColorInput      = input.color(GREEN,    "  🡑",          inline = "signal")
color   signalDnColorInput      = input.color(MAROON,   "🡓",            inline = "signal")
string  signalTypeInput         = input.string(MA06,    "",             inline = "signal", options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07, MA08])
int     signalLengthInput       = input.int(20,         "Length",       inline = "signal", minval = 1, tooltip = TT_SIGNAL)

bool    maShowInput             = input.bool(false,     "MA of MA",     inline = "ma")
color   maUpColorInput          = input.color(YELLOW,   " 🡑",           inline = "ma")
color   maDnColorInput          = input.color(BLUE_DK,  "🡓",            inline = "ma")
string  maTypeInput             = input.string(MA01,    "",             inline = "ma", options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07, MA08])
int     maLengthInput           = input.int(20,         "Length",       inline = "ma", minval = 2, tooltip = TT_MA)

bool    channelShowInput        = input.bool(true,      "Channel",      inline = "channel")
color   channelUpColorInput     = input.color(GREEN,    "  🡑",          inline = "channel")
color   channelDnColorInput     = input.color(MAROON,   "🡓",            inline = "channel")
color   channelUpUpColorInput   = input.color(LIME,     "🡑🡑",           inline = "channel")
color   channelDnDnColorInput   = input.color(PURPLE,   "🡓🡓",           inline = "channel", tooltip = TT_CHANNEL)

bool    maFillShowInput         = input.bool(true,      "MA fill",      inline = "maFill")
color   maFillUpColorInput      = input.color(YELLOW,   "   🡑",         inline = "maFill")
color   maFillDnColorInput      = input.color(BLUE,     "🡓",            inline = "maFill", tooltip = TT_MAFILL)

bool    colorBarsInput          = input.bool(false,     "Color chart bars using the color of", inline = "bars")
string  colorBarsModeInput      = input.string(CB3,     "",                 inline = "bars", options = [CB1, CB2, CB3, CB4])
//#endregion



//#region ———————————————————— Calculations


// Validate MA lengths.
if signalLengthInput > maLengthInput
	runtime.error("The length of the SOTT MA must be less than or equal to that of the second MA.")

// Instant SOTT
float sott 	 = LucfTa.sott()

// MAs
float signal = LucfTa.ma(signalTypeInput, sott, signalLengthInput)
float ma     = LucfTa.ma(maTypeInput, signal, maLengthInput)

// States
bool  maIsBull      = ma     > LEVEL_MID
bool  signalIsBull  = signal > LEVEL_MID
bool  channelIsBull = signal > ma
//#endregion



//#region ———————————————————— Plots


// Plotting colors
color channelColor      = channelIsBull ? signalIsBull ? channelUpUpColorInput : channelUpColorInput : signalIsBull ? channelDnColorInput : channelDnDnColorInput
color signalColor       = signalIsBull ? signalUpColorInput : signalDnColorInput
color maColor           = maIsBull ? maUpColorInput : maDnColorInput
color maChannelTopColor = maIsBull ? maFillUpColorInput : color.new(maFillDnColorInput, 95)
color maChannelBotColor = maIsBull ? color.new(maFillUpColorInput, 95) : maFillDnColorInput

// Plots
signalPlot = plot(signalShowInput or channelShowInput ? signal : na, "SOTT MA", signalShowInput ? signalColor : na, 2)
maPlot     = plot(ma, "MA of MA", maShowInput ? maColor : na)
zeroPlot   = plot(LEVEL_MID, "Phantom Mid Level", display = display.none)

// Fill the MA channel (the space between the middle level and the MA).
fill(maPlot, zeroPlot, not maFillShowInput ? na : maIsBull ? LEVEL_HI * 0.7 : LEVEL_MID, maIsBull ? LEVEL_MID : LEVEL_LO * 0.7, maChannelTopColor, maChannelBotColor)

// Fill the signal channel (between the two MAs).
fill(maPlot, signalPlot, ma, not channelShowInput ? na : signal, color.new(channelColor, 70), channelColor)

// Levels
hline(LEVEL_HI,  "High level", signalUpColorInput, hline.style_dotted)
hline(LEVEL_MID, "Mid level",  color.gray, hline.style_dotted)
hline(LEVEL_LO,  "Low level",  signalDnColorInput, hline.style_dotted)

// Instant SOTT for Data Window.
plot(sott, "Instant SOTT", display = display.data_window)

// Color bars
color barColor = 
  switch colorBarsModeInput
    CB1 => signalColor
    CB2 => maColor
    CB3 => channelColor
    CB4 => maIsBull ? maFillUpColorInput : maFillDnColorInput
    => na
barcolor(colorBarsInput ? barColor : na)
//#endregion
````
