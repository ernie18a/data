<!-- tradingview-pine-id: PUB;93a820fb49bb4119bf57158f2c458b8a -->
<!-- tradingviewscripts-format: 1 -->
# Oscillator Workbench — Chart [LucF]

Source: https://www.tradingview.com/script/BY9mAioc-Oscillator-Workbench-Chart-LucF/

## Description

█ OVERVIEW

This indicator uses an on-chart visual framework to help traders with the interpretation of any oscillator's behavior. The advantage of using this tool is that you do not need to know all the ins and outs of a particular oscillator such as RSI, CCI, Stochastic, etc. Your choice of oscillator and settings in this indicator will change its visuals, which allows you to evaluate different configurations in the context of how the workbench models oscillator behavior. My hope is that by using the workbench, you may come up with an oscillator selection and settings that produce visual cues you find useful in your trading.

The workbench works on any symbol and timeframe. It uses the same presentation engine as my [Delta ​Volume Channels](https://www.tradingview.com/script/zkBuiFk7-Delta-Volume-Channels-LucF/) indicator; those already familiar with it will feel right at home here.

█ CONCEPTS

Oscillators

An oscillator is any signal that moves up and down a centerline. The centerline value is often zero or 50. Because the range of oscillator values is different than that of the symbol prices we look at on our charts, it is usually impossible to display an oscillator on the chart, so we typically put oscillators in a separate pane where they live in their own space. Each oscillator has its own profile and properties that dictate its behavior and interpretation. Oscillators can be bounded, meaning their values oscillate between fixed values such as 0 to 100 or +1 to -1, or unbounded when their maximum and minimum values are undefined.

Oscillator weight

How do you display an oscillator's value on a chart showing prices when both values are not on the same scale? The method I use here converts the oscillator's value into a percentage that is used to weigh a reference line. The weight of the oscillator is calculated by maintaining its highest and lowest value above and below its centerline since the beginning of the chart's history. The oscillator's relative position in either of those spaces is then converted to a percentage, yielding a positive or negative value depending on whether the oscillator is above or below its centerline. This method works equally well with bounded and unbounded oscillators.

Oscillator Channel

The ​​oscillator channel is the space between two moving averages: the reference line and a weighted version of that line. The reference line is a moving average of a type, source and length which you select. The weighted line uses the same settings, but it averages the oscillator-weighted price source.

The weight applied to the source of the reference line can also include the relative size of the bar's ​volume in relation to previous bars. The effect of this is that the oscillator's weight on bars with higher total ​volume will carry greater weight than those with lesser ​volume.

The ​oscillator channel can be in one of four states, each having its corresponding color:
 • Bull (teal): The weighted line is above the reference line.
 • Strong bull (lime): The bull condition is fulfilled and the bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is above the reference line and both the reference and the weighted lines are rising.
 • Bear (maroon): The weighted line is below the reference line.
 • Strong bear (pink): The bear condition is fulfilled and the bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is below the reference line and both the reference and the weighted lines are falling.

Divergences

In the context of this indicator, a divergence is any bar where the slope of the reference line does not match that of the weighted line. No directional bias is assigned to divergences when they occur. You can also choose to define divergences as differences in polarity between the oscillator's slope and the polarity of close-to-close values. This indicator's divergences are designed to identify transition levels. They have no polarity; their ​bullish/​bearish bias is determined by the behavior of price relative to the divergence channel after the divergence channel is built.

Divergence Channel

The divergence channel is the space between two levels (by default, the bar's [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) and [high](https://www.tradingview.com/pine-script-reference/v5/#var_high)) saved when divergences occur. When price has breached a channel and a new divergence occurs, a new channel is created. Until that new channel is breached, bars where additional divergences occur will expand the channel's levels if the bar's price points are outside the channel.

Price breaches of the divergence channel will change its state. Divergence channels can be in one of five different states:
 • Bull (teal): Price has breached the channel to the upside.
 • Strong bull (lime): The bull condition is fulfilled and the ​oscillator channel is in the strong bull state.
 • Bear (maroon): Price has breached the channel to the downside.
 • Strong bear (pink): The bear condition is fulfilled and the ​oscillator channel is in the strong bear state.
 • Neutral (gray): The channel has not been breached.

█ HOW TO USE THE INDICATOR

Load the indicator on an active chart (see [here](https://www.tradingview.com/u/?solution=43000555216) if you don't know how).

The default configuration displays:
 • The Divergence channel's levels.
 • Bar colors using the state of the ​oscillator channel.

The default settings use:
 • RSI as the oscillator, using the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) source and a length of 20 bars.
 • An Arnaud-Legoux moving average on the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and a length of 20 bars as the reference line.
 • The weighted version of the reference line uses only the oscillator's weight, i.e., without the relative ​volume's weight. 
  The weighted line is capped to three standard deviations of the reference.
 • The divergence channel's levels are determined using the high and low of the bars where divergences occur. 
  Breaches of the channel require a bar's [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) to move above the top of the channel, and the bar's [high](https://www.tradingview.com/pine-script-reference/v5/#var_high) to move below the channel's bottom.

No markers appear on the chart; if you want to create alerts from this script, you will need first to define the conditions that will trigger the markers, then create the alert, which will trigger on those same conditions.

To learn more about how to use this indicator, you must understand the concepts it uses and the information it displays, which requires reading this description. There are no videos to explain it.

█ FEATURES

The script's inputs are divided in five sections: "Oscillator", "Oscillator channel", "Divergence channel", "Bar Coloring" and "Marker/Alert Conditions".

Oscillator

This is where you configure the oscillator you want to study. Thirty oscillators are available to choose from, but you can also use an oscillator from another indicator that is on your chart, if you want. When you select an external indicator's plot as the oscillator, you must also specify the value of its centerline.

Oscillator Channel

Here, you control the visibility and colors of the reference line, its weighted version, and the oscillator channel between them.

You also specify what type of moving average you want to use as a reference line, its source and its length. This acts as the ​oscillator channel's baseline. The weighted line is also a moving average of the same type and length as the reference line, except that it will be calculated from the weighted version of the source used in the reference line. By default, the weighted line is capped to three standard deviations of the reference line. You can change that value, and also elect to cap using a multiple of ATR instead. The cap provides a mechanism to control how far the weighted line swings from the reference line. This section is also where you can enable the relative ​volume component of the weight.

Divergence Channel

This is where you control the appearance of the divergence channel and the key price values used in determining the channel's levels and breaching conditions. These choices have an impact on the behavior of the channel. More generous level prices like the default [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) and [high](https://www.tradingview.com/pine-script-reference/v5/#var_high) selection will produce more conservative channels, as will the default choice for breach prices.

In this section, you can also enable a mode where an attempt is made to estimate the channel's bias before price breaches the channel. When it is enabled, successive increases/decreases of the channel's top and bottom levels are counted as new divergences occur. When one count is greater than the other, a bull/bear bias is inferred from it. You can also change the detection mode of divergences, and choose to display a mark above or below bars where divergences occur.

Bar Coloring

You specify here:
 • The method used to color chart bars, if you choose to do so.
 • If you want to hollow out the bodies of bars where ​volume has not increased since the last bar.

Marker/Alert Conditions

Here, you specify the conditions that will trigger up or down markers. The trigger conditions can include a combination of state transitions of the ​oscillator and the divergence channels. The triggering conditions can be filtered using a variety of conditions.

Configuring the marker conditions is necessary before creating an alert from this script, as the alert will use the marker conditions to trigger.

Realtime values will repaint, as is usually the case with oscillators, but markers only appear on bar closes, so they will not repaint. Keep in mind, when looking at markers on historical bars, that they are positioned on the bar when it closes — NOT when it opens.

Raw values

The raw values calculated by this script can be inspected using the Data Window, including the oscillator's value and the weights.

█ INTERPRETATION

Except when mentioned otherwise, this section's charts use the indicator's default settings, with different visual components turned on or off.

The aim of the ​oscillator channel is to provide a visual representation of an oscillator's general behavior. The simplest characteristic of the channel is its bull/bear state, determined by whether the weighted line is above or below the reference line. One can then distinguish between its bull and strong bull states, as transitions from strong bull to bull states will generally happen when trends are losing steam. While one should not infer a reversal from such transitions, they can be a good place to tighten stops. Only time will tell if a reversal will occur. One or more divergences will often occur before reversals. This shows the oscillator channel, with the reference line and the thicker, weighted line: https://www.tradingview.com/x/6gk5v4tA/

The nature of the divergence channel's design makes it particularly adept at identifying consolidation areas if its settings are kept on the conservative side. The divergence channel will also reveal transition areas. A gray divergence channel should usually be considered a no-trade zone. More adventurous traders can use the oscillator ​ channel to orient their trade entries if they accept the risk of trading in a neutral divergence channel, which by definition will not have been breached by price. This show only the divergence channels: https://www.tradingview.com/x/fCW2oYAs/

This chart shows divergence channels and their levels, and colors bars on divergences and on the state of the oscillator channel, which is not visible on the chart: https://www.tradingview.com/x/6yB5zqoe/

If your charts are already busy with other stuff you want to hold on to, you could consider using only the chart bar coloring component of this indicator. Here we only color bars using the combined state of the oscillator and divergence channel, and we do not color the bodies of bars where ​volume has not increased. Note that my chart's settings do not color the candle bodies: https://www.tradingview.com/x/rRU5yHcs/

At its simplest, one way to use this indicator would be to look for overlaps of the strong bull/bear colors in both the ​oscillator channel and a divergence channel, as these identify points where price is breaching the divergence channel when the oscillator's state is consistent with the direction of the breach.

Tip

One way to use the Workbench is to combine it with my [Delta ​Volume Channels](https://www.tradingview.com/script/zkBuiFk7-Delta-Volume-Channels-LucF/) indicator. If both indicators use the same MA as a reference line, you can display its delta ​volume channel instead of the oscillator channel.

This chart shows such a setup. The Workbench displays its divergence levels, the weighted reference line using the default ​RSI oscillator, and colors bars on divergences. The ​DV Channels indicator only displays its delta ​volume channel, which uses the same MA as the workbench for its baseline. This way you can ascertain the ​volume delta situation in contrast with the visuals of the Workbench: https://www.tradingview.com/x/enmAYop8/

█ LIMITATIONS

 • For some of the oscillators, assumptions are made concerning their different parameters when they are more complex than just a source and length.
  See the `oscCalc()` function in this indicator's code for all the details, and ask me in a comment if you can't find the information you need.
 • When an oscillator using ​volume is selected and no ​volume information is available for the chart's symbol, an error will occur.
 • The method I use to convert an oscillator's value into a percentage is fragile in the early history of datasets 
  because of the nascent expression of the oscillator's range during those early bars.

█ NOTES

Working with this workbench

This indicator is called a workbench for a reason; it is designed for traders interested in exploring its behavior with different oscillators and settings, in the hope they can come up with a setup that suits their trading methodology. I cannot tell you which setup is the best because its setup should be compatible with your trading methodology, which may require faster or slower transitions, thus different configurations of the settings affecting the calculations of the divergence channels.

For Pine Script™ Coders

 • This script uses the new overload of the [fill()](https://www.tradingview.com/pine-script-reference/v5/#fun_fill) function which now makes it possible to do vertical gradients in Pine. I use it for both channels displayed by this script.
 • I use the new arguments for [plot()](https://www.tradingview.com/pine-script-reference/v5/#fun_plot)'s `display` parameter to control where the script plots some of its values, 
  namely those I only want to appear in the script's status line and in the Data Window.
 • I used my [ta](https://www.tradingview.com/script/UZQxuS7X-ta/) library for some of the oscillator calculations and helper functions.
 • I also used TradingView's [ta](https://www.tradingview.com/script/BICzyhq0-ta/) library for other oscillator calculations.
 • I wrote my script using the revised recommendations in the [Style Guide](https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html) from the Pine v5 User Manual.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LucF

//@version=5
indicator("Oscillator Workbench — Chart [LucF]", "OWC", true, precision = 4, max_bars_back = 1000)

// Oscillator Workbench — Chart [LucF]
// v3, 2022.10.27 17:58 — LucF

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html


import TradingView/ta/4 as TvTa
import LucF/ta/2 as LucfTa



//#region ———————————————————— Constants


// Colors
color LIME      = #00FF00ff
color LIME_MD   = #00FF0090
color LIME_LT   = #00FF0040
color TEAL      = #008080ff
color TEAL_MD   = #00808090
color TEAL_LT   = #00808040
color PINK      = #FF0080ff
color PINK_MD   = #FF008090
color PINK_LT   = #FF008040
color MAROON    = #800000ff
color MAROON_MD = #80000090
color MAROON_LT = #80000040
color ORANGE    = #c56606ff
color ORANGE_BR = #FF8000ff
color GRAY      = #808080ff
color GRAY_MD   = #80808090
color GRAY_LT   = #80808030
color WHITE     = #FFFFFFff

// Reference MAs
string MA01 = "Simple MA"
string MA02 = "Exponential MA"
string MA03 = "Wilder MA"
string MA04 = "Weighted MA"
string MA05 = "Volume-weighted MA"
string MA06 = "Arnaud Legoux MA"
string MA07 = "Hull MA"
string MA08 = "Symmetrically-weighted MA"

// Oscillators
string OS00 = "None"
string OS01 = "RSI (SL)"
string OS02 = "MACD (S)"
string OS03 = "CCI (SL)"
string OS04 = "Chande Momentum Oscillator (SL)"
string OS05 = "Stochastic (SL)"
string OS06 = "Stochastic RSI (SL)"
string OS09 = "MFI (L)"
string OS10 = "True Strength Index (SL)"
string OS11 = "Williams % Range (L)"
string OS12 = "Ultimate Oscillator (L)"
string OS13 = "Klinger Volume Oscillator (L)"
string OS14 = "Schaff Trend Cycle (SL)"
string OS15 = "Volume Zone Oscillator (L)"
string OS16 = "Price Zone Oscillator (L)"
string OS17 = "Sentiment Zone Oscillator (SL)"
string OS18 = "Wave Period Oscillator (L)"
string OS19 = "Volume Buoyancy (L)"
string OS20 = "Coppock Curve (SL)"
string OS21 = "Aroon (L)"
string OS22 = "DMI (L)"
string OS23 = "TRIX (SL)"
string OS24 = "Ease of Movement (L)"
string OS25 = "Fisher Transform (SL)"
string OS26 = "Signs of the Times"
string OS27 = "Hilbert Transform (S)"
string OS28 = "Intraday Intensity Index"
string OS52 = "True Range"
string OS54 = "Momentum (SL)"
string OS55 = "Rate of Change (SL)"
string OS90 = "Efficient Work (L)"

// Oscillator Channel capping mode
string CAP1 = "Standard deviations"
string CAP2 = "Multiples of ATR"

// Divergence detection mode
string DIV1 = "Opposite directions of the weighted and reference lines"
string DIV2 = "Opposite directions of the oscillator and the polarity of close to close"

// Line styles
string STL1 = "Line"
string STL2 = "Circles"
string STL3 = "Crosses"

// Marker oscillator channel transitions
string ST0 = "None"
string ST1 = "Oscillator channel strong bull state"
string ST2 = "Oscillator channel bull or strong bull state"
string ST3 = "Oscillator channel strong bear state"
string ST4 = "Oscillator channel bear or strong bear state"

// Marker Divergence channel transitions
string SV0 = "None"
string SV1 = "Divergence channel strong bull state"
string SV2 = "Divergence channel bull or strong bull state"
string SV3 = "Divergence channel strong bear state"
string SV4 = "Divergence channel bear or strong bear state"

// Bar color choices
string CB0  = "None"
string CB1  = "On divergences only"
string CB2  = "On divergences and on the state of the oscillator channel"
string CB3  = "On divergences and on the state of the divergence channel"
string CB4  = "On divergences and on the combined state of both channels"

// Channel level sources
string CH1  = "High and Low"
string CH2  = "Open and Close"

// Channel breach sources
string BR1  = "`low` must breach channel's top, `high` must breach channel's bottom"
string BR2  = "`high` must breach channel's top, `low` must breach channel's bottom"
string BR3  = "Close"
string BR4  = "Open"
string BR5  = "The average of high and low (hl2)"
string BR6  = "The average of high, low and close (hlc3)"
string BR7  = "The average of high, low and two times the close (hlcc4)"
string BR8  = "The average of high, low, close and open (ohlc4)"

// Tooltips
string TT_OSC1      = "To use one of the oscillators provided in the Workbench, select it here.
  \n\nThe 'S' or 'L' in parentheses indicates when the 'Source' or 'Length' fields of this line are taken into account when calculating the oscillator's value.
  \n\nNote that for some of the oscillators, assumptions are made concerning their different parameters when they are more complex than just a source and length.
  See the `oscCalc()` function in this indicator's code for all the details, and ask me in a comment if you can't find the information you need."
string TT_OSC2      = "To use a second oscillator provided in the Workbench, select it here.
  If you select two oscillators, each of their weight will count for an equal part in the aggregate oscillator weight."
string TT_OSCX      = "To use an external oscillator, check the checkbox, select the external indicator you want to use, and specify its center value.
  \n\nIf you want only the external oscillator to be used, remember to select 'None' for the 'Oscillator 1' and 'Oscillator 2' choices above.
  If you do have oscillators selected for 'Oscillator 1' and/or 'Oscillator 2', their weight will be combined with that of the external oscillator.
  This way you can have up to three oscillator weights composing the aggregate oscillator weight."
string TT_RVOL      = "When checked, the aggregate weight of the oscillator(s) will be multiplied by the weight of the relative volume for the bar.
  This weight is determined using the percentile rank of the bar's volume in the number of bars you specify. The range of the weight is 0 to 1."
string TT_REF       = "Your choices here determine the reference that will be used as the oscillator channel's baseline.
  The MA type and length defined here are also used to calculate the MA of the weighted version of the reference's source."
string TT_CAP       = "This allows you to control the Oscillator channel's maximum height by limiting how far the weighted line can extend from the reference line.
  It is useful to keep the chart's vertical scale in check. The lower you set it, the less contours you will get in the weighted line.\n\n
  Keep in mind that this setting can also impact where divergences will occur on the chart.\n\n
  Using '" + CAP2 + "' will restrict the height more agressively. The ATR unit value used is its average over 20 bars."
string TT_LTF       = "Your selection here controls how many intrabars will be analyzed for each chart bar. 
  The more intrabars you analyze per chart bar, the less chart bars will be covered by the indicator's calculations
  because a maximum of 100K intrabars can be analyzed.\n\n
  With the first four choices the quantity of intrabars is determined from the type of chart bar coverage you want.
  The last four choices allow you to select approximately how many intrabars you want analyzed per chart bar."
string TT_BIAS      = "This option enables a guess on the bull/bear bias of the channel before it is breached.
  It uses the number of changes of the top/bottom channel levels to determine a bias.
  When more changes of the top level occur, the bias is bullish. When more changes of the bottom level occur, the bias is bearish.
  \n\n Note that enabling this setting will make the channel's states less reliable."
string TT_COLORS    = "'🡑🡑' and '🡓🡓' indicate the colors used for strong bull/bear conditions.
  \n'🡑' and '🡓' indicate bull/bear conditions."
string TT_MARKERS   = "The conditions you use to determine when markers appear will also be used to trigger alerts created from this script.
  \n\nMarkers are non-repainting; they appear on the close of bars."
string TT_DIV       = "Using the second option here will produce less divergences with oscillators such as RSI, which closely follow price movements. 
  It will also produce vastly different behaviors between oscillators."
string TT_BARS      = "If the coloring of bars on divergences is active, their body will always be colored in the divergence color, regardless of this checkbox's state."
string TT_FILTERS   = "The filters are additional conditions that must be true for a marker to appear.
  \n\n'Close-to-close polarity' means that the `close` must be higher than the previous one for an up marker, and vice versa.
  \n\n'Rising volume' means the volume of the bar must be higher than that of the previous one. This condition is the same for up/dn markers.
  \n\nThe filter on divergences requires a divergence to have occurred in the last number of bars you specify.
  \n\n'Bull/bear Oscillator' means that the value of the oscillator you select must be above/below its centerline.
  \n\nAs markers are non-repainting, keep in mind that marker conditions must be true on the bar's close, which is when the marker will appear."
//#endregion



//#region ———————————————————— Inputs


string  GRP1 = "Oscillators and relative volume"
string  osc1TypeInput           = input.string(OS01,        "Oscillator 1",                         group = GRP1, inline = "osc1", options = [OS00, OS21, OS03, OS04, OS20, OS22, OS24, OS90, OS25, OS27, OS28, OS13, OS02, OS09, OS54, OS16, OS55, OS01, OS14, OS17, OS26, OS05, OS06, OS23, OS52, OS10, OS12, OS19, OS15, OS18, OS11])
string  osc1SourceInput         = input.string("close",     "",                                     group = GRP1, inline = "osc1", options = ["open", "high", "low", "close", "hl2", "hlc3", "ohlc4", "hlcc4", "volume"])
int     osc1LengthInput         = input.int(20,             " Length",                              group = GRP1, inline = "osc1", minval = 2, tooltip = TT_OSC1)
string  osc2TypeInput           = input.string(OS00,        "Oscillator 2",                         group = GRP1, inline = "osc2", options = [OS00, OS21, OS03, OS04, OS20, OS22, OS24, OS90, OS25, OS27, OS28, OS13, OS02, OS09, OS54, OS16, OS55, OS01, OS14, OS17, OS26, OS05, OS06, OS23, OS52, OS10, OS12, OS19, OS15, OS18, OS11])
string  osc2SourceInput         = input.string("close",     "",                                     group = GRP1, inline = "osc2", options = ["open", "high", "low", "close", "hl2", "hlc3", "ohlc4", "hlcc4", "volume"])
int     osc2LengthInput         = input.int(20,             " Length",                              group = GRP1, inline = "osc2", minval = 2, tooltip = TT_OSC2)
bool    oscXInput               = input.bool(false,         "Oscillator 3 (external)",              group = GRP1, inline = "oscX")
float   oscXSourceInput         = input.source(close,       "",                                     group = GRP1, inline = "oscX")
float   oscXCenterInput         = input.int(0,              "Center",                               group = GRP1, inline = "oscX", tooltip = TT_OSCX)
bool    useRelVolWeightInput    = input.bool(false,         "Use weight of relative volume over n bars", group = GRP1, inline = "RelVolW", tooltip = TT_RVOL)
int     relVolLookbackInput     = input.int(100,            "",                                     group = GRP1, inline = "RelVolW", minval = 2)

string  GRP2 = "Oscillator channel"
bool    reflLineShowInput       = input.bool(false,         "Reference line ",                      group = GRP2, inline = "refLine")
int     refLineWidthInput       = input.int(1,              " Width",                               group = GRP2, inline = "refLine", minval = 1)
string  refLineStyleInput       = input.string(STL1,        "",                                     group = GRP2, inline = "refLine", options = [STL1, STL2, STL3])
color   refLineUpUpColorInput   = input.color(LIME,         "  🡑🡑",                                 group = GRP2, inline = "refLineColors")
color   refLineDnDnColorInput   = input.color(PINK,         "🡓🡓",                                   group = GRP2, inline = "refLineColors")
color   refLineUpColorInput     = input.color(TEAL,         " 🡑",                                   group = GRP2, inline = "refLineColors")
color   refLineDnColorInput     = input.color(MAROON,       "🡓",                                    group = GRP2, inline = "refLineColors", tooltip = TT_COLORS)
string  refTypeInput            = input.string(MA06,        "  ",                                   group = GRP2, inline = "ref", options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07, MA08], tooltip = TT_REF)
string  refSourceInput          = input.string("close",     "",                                     group = GRP2, inline = "ref", options = ["open", "high", "low", "close", "hl2", "hlc3", "ohlc4", "hlcc4", "volume"])
int     refLengthInput          = input.int(20,             " Length",                              group = GRP2, inline = "ref", minval = 2)

bool    osclLineShowInput       = input.bool(false,         "Weighted line",                        group = GRP2, inline = "oscLine")
int     oscLineWidthInput       = input.int(2,              "    Width",                            group = GRP2, inline = "oscLine", minval = 1)
string  oscLineStyleInput       = input.string(STL1,        "",                                     group = GRP2, inline = "oscLine", options = [STL1, STL2, STL3])
color   oscLineUpUpColorInput   = input.color(LIME,         "  🡑🡑",                                 group = GRP2, inline = "oscLineColors") 
color   oscLineDnDnColorInput   = input.color(PINK,         "🡓🡓",                                   group = GRP2, inline = "oscLineColors") 
color   oscLineUpColorInput     = input.color(TEAL,         " 🡑",                                   group = GRP2, inline = "oscLineColors") 
color   oscLineDnColorInput     = input.color(MAROON,       "🡓",                                    group = GRP2, inline = "oscLineColors") 
float   oscChannelCapInput      = input.float(3.0,          "  Cap the channel's height to",        group = GRP2, inline = "cap", minval = 1, step = 0.5)
string  oscChannelCapModeInput  = input.string(CAP1,        "",                                     group = GRP2, inline = "cap", options = [CAP1, CAP2], tooltip = TT_CAP)

bool    oscChannelShowInput     = input.bool(false,         "Oscillator channel",                   group = GRP2, inline = "oscChannel")
color   oscChannelUpUpColorInput= input.color(LIME_MD,      "  🡑🡑",                                 group = GRP2, inline = "oscChannelColors")
color   oscChannelDnDnColorInput= input.color(PINK_MD,      "🡓🡓",                                   group = GRP2, inline = "oscChannelColors")
color   oscChannelUpColorInput  = input.color(TEAL_MD,      " 🡑",                                   group = GRP2, inline = "oscChannelColors")
color   oscChannelDnColorInput  = input.color(MAROON_MD,    "🡓",                                    group = GRP2, inline = "oscChannelColors")

string  GRP3 = "Divergence channel"
bool    divLinesShowInput       = input.bool(true,          "Divergence levels",                    group = GRP3, inline = "divLines")
int     divLinesWidthInput      = input.int(1,              " Width",                               group = GRP3, inline = "divLines", minval = 1)
string  divLinesStyleInput      = input.string(STL1,        "",                                     group = GRP3, inline = "divLines", options = [STL1, STL2, STL3])
color   divLinesUpUpColorInput  = input.color(LIME,         "  🡑🡑",                                 group = GRP3, inline = "divLinesColors")
color   divLinesDnDnColorInput  = input.color(PINK,         "🡓🡓",                                   group = GRP3, inline = "divLinesColors")
color   divLinesUpColorInput    = input.color(TEAL,         " 🡑",                                   group = GRP3, inline = "divLinesColors")
color   divLinesDnColorInput    = input.color(MAROON,       "🡓",                                    group = GRP3, inline = "divLinesColors")
color   divLinesNtColorInput    = input.color(GRAY,         "N",                                    group = GRP3, inline = "divLinesColors")

bool    divChannelShowInput     = input.bool(false,         "Divergence channel",                   group = GRP3, inline = "divChannel")
color   divChannelUpUpColorInput= input.color(LIME_MD,      "  🡑🡑",                                 group = GRP3, inline = "divChannelColors")
color   divChannelDnDnColorInput= input.color(PINK_MD,      "🡓🡓",                                   group = GRP3, inline = "divChannelColors")
color   divChannelUpColorInput  = input.color(TEAL_MD,      " 🡑",                                   group = GRP3, inline = "divChannelColors")
color   divChannelDnColorInput  = input.color(MAROON_MD,    "🡓",                                    group = GRP3, inline = "divChannelColors")
color   divChannelNtColorInput  = input.color(GRAY_MD,      "N",                                    group = GRP3, inline = "divChannelColors")

string  divChannelLevelsInput   = input.string(CH1,         "  Levels are defined using",           group = GRP3, options = [CH1, CH2])
string  divChannelBreachesInput = input.string(BR1,         "  Breaches are determined using",      group = GRP3, options = [BR1, BR2, BR3, BR4, BR5, BR6, BR7, BR8])
string  divDetectionModeInput   = input.string(DIV1,        "  Detect divergences on",              group = GRP3, inline = "divDetection", options = [DIV1, DIV2], tooltip = TT_DIV)
bool    divChannelBiasInput     = input.string("Off",       "  Estimate unbreached channel bias",   group = GRP3, options = ["On", "Off"], tooltip = TT_BIAS) == "On"

bool    charDivShowInput        = input.bool(false,         "Divergence mark",                      group = GRP3, inline = "divChar")
string  charDivInput            = input.string("•",         "",                                     group = GRP3, inline = "divChar")
color   charDivColorInput       = input.color(ORANGE,       "",                                     group = GRP3, inline = "divChar")
bool    charDivAboveInput       = input.bool(true,          "Above bar",                            group = GRP3, inline = "divChar")

string  GRP4 = "Bar coloring"
bool    barColorsShowInput      = input.bool(true,          "Color bars",                           group = GRP4, inline = "barMode")
string  colorBarModeInput       = input.string(CB2,         "",                                     group = GRP4, inline = "barMode", options = [CB1, CB2, CB3, CB4])
bool    barsEmptyOnDecVolInput  = input.bool(false,         "Don't color falling volume bars",      group = GRP4, inline = "barMode", tooltip = TT_BARS)
color   barsUpUpColorInput      = input.color(LIME,         "  🡑🡑",                                 group = GRP4, inline = "barColors")
color   barsDnDnColorInput      = input.color(PINK,         "🡓🡓",                                   group = GRP4, inline = "barColors")
color   barsUpColorInput        = input.color(TEAL,         "🡑",                                    group = GRP4, inline = "barColors")
color   barsDnColorInput        = input.color(MAROON,       "🡓",                                    group = GRP4, inline = "barColors")
color   barsNtColorInput        = input.color(GRAY,         "N",                                    group = GRP4, inline = "barColors")
color   barsDivColorInput       = input.color(ORANGE,       "D",                                    group = GRP4, inline = "barColors")

string  GRP5 = "Markers & Alert conditions"
string  markerUpOscModeInput    = input.string(ST0,         "Up markers on transitions to  ",       group = GRP5, inline = "upMarker", options = [ST0, ST1, ST2])
string  markerUpDivModeInput    = input.string(SV0,         "",                                     group = GRP5, inline = "upMarker", options = [SV0, SV1, SV2])
color   markerUpColorInput	    = input.color(ORANGE_BR,    "",			                            group = GRP5, inline = "upMarker", tooltip = TT_MARKERS)
string  markerDnOscModeInput    = input.string(ST0,         "Down markers on transitions to",       group = GRP5, inline = "dnMarker", options = [ST0, ST3, ST4])
string  markerDnDivModeInput    = input.string(SV0,         "",                                     group = GRP5, inline = "dnMarker", options = [SV0, SV3, SV4])
color   markerDnColorInput	    = input.color(ORANGE_BR,    "",                                     group = GRP5, inline = "dnMarker")
bool    markerClosePolarityInput= input.bool(false,         "Filter on close to close polarity  ",  group = GRP5, inline = "Filters1", tooltip = TT_FILTERS)
bool    markerRisingVolInput    = input.bool(false,         "Filter on rising volume",              group = GRP5, inline = "Filters1")
bool    markerDivInput          = input.bool(false,         "Filter on divergence in last n bars",  group = GRP5, inline = "Filters2")
int     markerDivBarsInput      = input.int(5,              "",                                     group = GRP5, inline = "Filters2", minval = 1)
bool    markerOscInput          = input.bool(false,         "Filter on bull/bear",                  group = GRP5, inline = "Filters3")
string  markerOscTypeInput      = input.string(OS01,        "",                                     group = GRP5, inline = "Filters3", options = [OS21, OS03, OS04, OS20, OS22, OS24, OS90, OS25, OS27, OS28, OS13, OS02, OS09, OS54, OS16, OS55, OS01, OS14, OS17, OS05, OS06, OS23, OS52, OS10, OS12, OS19, OS15, OS18, OS11])
string  markerOscSourceInput    = input.string("close",     "",                                     group = GRP5, inline = "Filters3", options = ["open", "high", "low", "close", "hl2", "hlc3", "ohlc4", "hlcc4", "volume"])
int     markerOscLengthInput    = input.int(20,             "",                                     group = GRP5, inline = "Filters3", minval = 2)
string  alertUpMsgInput         = input.text_area("▲",      "Up alert text",                        group = GRP5)
string  alertDnMsgInput         = input.text_area("▼",      "Down alert text",					    group = GRP5)
//#endregion



//#region ———————————————————— Functions


//@function         Returns the centerline value for the `type` oscillator.
//@param type       (simple string) The type of oscillator (uses constants that must be defined earlier in the script).
//@returns          (series float) The centerline's value.
oscCenter(simple string type) =>
    float result = 
      switch type
        OS01 => 50.
        OS05 => 50.
        OS06 => 50.
        OS09 => 50.
        OS11 => -50.
        OS12 => 50.
        OS14 => 50.
        => 0.


//@function         Returns the calculation of the `type` oscillator.
//@param type       (simple string) The type of oscillator (uses constants that must be defined earlier in the script).
//@param src        (series float) The source value used to calculate the oscillator, when one is needed.
//@param length     (simple int) The length value used to calculate the oscillator, when one is needed.
//@returns          (series float) The oscillator's value.
oscCalc(simple string type, series float src, simple int length) =>
    float result = 
      switch type
        OS00 => na
        OS01 => ta.rsi(src, length)
        OS02 => 
            [_, _, histLine] = ta.macd(src, 12, 26, 9)
            histLine
        OS03 => ta.cci(src, length)
        OS04 => ta.cmo(src, length)
        OS05 => ta.stoch(src, high, low, length)
        OS06 => 
            float rsi = ta.rsi(src, length)
            ta.sma(ta.stoch(rsi, rsi, rsi, length), 3)
        OS09 => ta.mfi(hlc3, length)
        OS10 => ta.tsi(src, length, length * 2)
        OS11 => ta.wpr(length)
        OS12 => TvTa.uo(length / 2, length, length * 2)
        OS13 => 
            [kvo, _] = TvTa.kvo(length, length * 2, length / 2)
            kvo
        OS14 => TvTa.stc(src, length, length * 2, length / 2, 3, 3)
        OS15 => TvTa.vzo(length)
        OS16 => TvTa.pzo(length)
        OS17 => TvTa.szo(src, length)
        OS18 => TvTa.wpo(length)
        OS19 => LucfTa.buoyancy(volume, length, 1000)
        OS20 => TvTa.coppock(src, length, length / 2, length / 2)
        OS21 => 
            [up, dn] = TvTa.aroon(length)
            up - dn
        OS22 => 
            [up, dn, _] = ta.dmi(length, length)
            up - dn
        OS23 => 
            [trix, signal, hist] = TvTa.trix(src, length, int(length * 0.66))
            trix
        OS24 => TvTa.eom(length)
        OS25 => TvTa.ft(src, length)
        OS26 => LucfTa.sott()
        OS27 => TvTa.ht(src)
        OS28 => ta.iii
        OS52 => ta.tr * math.sign(ta.change(close))
        OS54 => ta.mom(src, length)
        OS55 => ta.roc(src, length)
        OS90 => LucfTa.efficientWork(length)
        => na


//@function         Returns the weight of an oscillator's value.
//@param osc        (series float) The oscillator's value.
//@param center     (simple float) The oscillator's centerline value.
//@returns          (series float) The weight (-1 to +1) of the oscillator's value.
oscWeight(series float osc, simple float center = 0.0) =>
    float normalizedOsc = osc - center
    float historicalMax = math.abs(ta.max(normalizedOsc))
    float historicalMin = math.abs(ta.min(normalizedOsc))
    float result =
      switch 
        osc > center => normalizedOsc / historicalMax
        osc < center => - math.abs(normalizedOsc / historicalMin)
        => 0.


//@function         Throws a runtime error if the oscillator requires volume and none is available.
//@param type       (simple string) The type of oscillator (uses constants that must be defined earlier in the script).
//@returns          (void) Nothing.
checkForNoVolume(simple string type) =>
    bool oscUsesVolume = type == OS09 or type == OS15 or type == OS19 or type == OS24
    if barstate.islast and ta.cum(nz(volume)) == 0 and oscUsesVolume
        runtime.error("No volume is provided by the data vendor.")


//@function     Determines when a state is entered on a bar where the previous state was different.
//@param state  (series bool) The state whose transition into must be identified.
//@returns      (series bool) `true` on the bar where we transition into the state, `false` otherwise.
transitionTo(series bool state) =>
    bool result = (not state[1] and state)


//@function     Determines a "plot_style" to be used from a user's input.
//@param state  (input string) The user selection string of his line style choice (depends on the `STL1`, `STL2` and `STL3` string constants).
//@returns      (plot_style) The `style` named argument required in `plot()`.
lineStyleFromUserInput(userSelection) =>
    result = switch userSelection
        STL1 => plot.style_line
        STL2 => plot.style_circles
        STL3 => plot.style_cross
        => plot.style_line
//#endregion



//#region ———————————————————— Calculations


// Stop the indicator when the oscillator requires volume to calculate.
checkForNoVolume(osc1TypeInput)
checkForNoVolume(osc2TypeInput)

// Oscillator value and weight.
var float osc1Center = oscCenter(osc1TypeInput)
var float osc2Center = oscCenter(osc2TypeInput)
var float oscXCenter = oscXCenterInput
float osc1 = oscCalc(osc1TypeInput, LucfTa.sourceStrToFloat(osc1SourceInput), osc1LengthInput)
float osc2 = oscCalc(osc2TypeInput, LucfTa.sourceStrToFloat(osc2SourceInput), osc2LengthInput)
float oscX = oscXInput ? oscXSourceInput : na
int qtyOfOscillators = (not na(osc1) ? 1 : 0) + (not na(osc2) ? 1 : 0) + (not na(oscX) ? 1 : 0)
float weight1 = oscWeight(osc1, osc1Center)
float weight2 = oscWeight(osc2, osc2Center)
float weightX = oscWeight(oscX, oscXCenter)
float weight = (weight1 + weight2 + weightX) / qtyOfOscillators

// Relative volume weight
float relVolPctRank   = ta.percentrank(volume, relVolLookbackInput) / 100.
float relVolumeWeight = useRelVolWeightInput and not na(volume) ? relVolPctRank : 1.
// Combined weight
float combinedWeight  = weight * relVolumeWeight

// MAs of reference source and capped weighted source.
float refSource      = LucfTa.sourceStrToFloat(refSourceInput)
float capUnits       = oscChannelCapModeInput == CAP1 ? ta.stdev(refSource, refLengthInput) : ta.atr(20)
float weightedSource = refSource + (math.sign(combinedWeight) * math.min(refSource * math.abs(combinedWeight), capUnits * oscChannelCapInput))
float reference      = LucfTa.ma(refTypeInput, refSource, refLengthInput)
float weightedRef    = LucfTa.ma(refTypeInput, weightedSource, refLengthInput)

// Determine bull/bear and strong bull/bear states of the oscillator channel.
bool oscChannelBull = weightedRef > reference
bool oscChannelBear = not oscChannelBull
bool oscChannelBullStrong = oscChannelBull and close > reference and ta.rising(reference, 1)  and ta.rising(weightedRef, 1)
bool oscChannelBearStrong = oscChannelBear and close < reference and ta.falling(reference, 1) and ta.falling(weightedRef, 1)


// ————— Divergence channel

// Detect divergences between the slope of the reference line and that of the weighted line.
bool divergence = divDetectionModeInput == DIV1 ? math.sign(ta.change(reference)) != math.sign(ta.change(weightedRef)) : math.sign(ta.change(combinedWeight)) != math.sign(ta.change(close))

// Level sources
float divChannelHiSrc = divChannelLevelsInput == CH1 ? high : math.max(open, close)
float divChannelLoSrc = divChannelLevelsInput == CH1 ? low  : math.min(open, close)

// Breach sources
float divBreachHiSrc  = na
float divBreachLoSrc  = na
switch divChannelBreachesInput
    BR1 =>
        divBreachHiSrc := low
        divBreachLoSrc := high
    BR2 =>
        divBreachHiSrc := high
        divBreachLoSrc := low
    BR3 =>
        divBreachHiSrc := close
        divBreachLoSrc := close
    BR4 =>
        divBreachHiSrc := open
        divBreachLoSrc := open
    BR5 =>
        divBreachHiSrc := hl2
        divBreachLoSrc := hl2
    BR6 =>
        divBreachHiSrc := hlc3
        divBreachLoSrc := hlc3
    BR7 =>
        divBreachHiSrc := hlcc4
        divBreachLoSrc := hlcc4
    BR8 =>
        divBreachHiSrc := ohlc4
        divBreachLoSrc := ohlc4

// Update the divergence channel.
[divChannelHi, divChannelLo, divChannelBull, divChannelBear, divChannelBreached, newDivChannel, preBreachUpChanges, preBreachDnChanges] = 
  LucfTa.divergenceChannel(divergence, divChannelHiSrc, divChannelLoSrc, divBreachHiSrc, divBreachLoSrc)

// If needed, take a guess on the state of the channel when it has not yet been breached.
bool preBreachBiasBull = not divChannelBreached and divChannelBiasInput and preBreachUpChanges > preBreachDnChanges
bool preBreachBiasBear = not divChannelBreached and divChannelBiasInput and preBreachUpChanges < preBreachDnChanges

// Strong bull/bear states occur when the divergence channel's bull/bear state matches that of the oscillator channel.
bool divChannelBullStrong = divChannelBull and oscChannelBullStrong
bool divChannelBearStrong = divChannelBear and oscChannelBearStrong



// ————— Marker filters and triggers

// Close-to-close polarity
bool closeToCloseUp = ta.change(close) > 0
bool closeToCloseDn = ta.change(close) < 0

// Oscillator is bull/bear
var float markerOscCenter = oscCenter(markerOscTypeInput)
float markerOsc = oscCalc(markerOscTypeInput, LucfTa.sourceStrToFloat(markerOscSourceInput), markerOscLengthInput)
bool  oscBull   = markerOsc > markerOscCenter
bool  oscBear   = markerOsc < markerOscCenter

// RIsing volume
bool risingVolume = ta.change(volume) > 0

// Divergence in last n bars
bool divPresent = ta.barssince(divergence) <= markerDivBarsInput

// Base conditions for markers to appear.
bool upMarkerOscCondition = 
  switch markerUpOscModeInput
    ST1 => transitionTo(oscChannelBullStrong)
    ST2 => transitionTo(oscChannelBull) or transitionTo(oscChannelBullStrong)
    => false
bool upMarkerDivCondition = 
  switch markerUpDivModeInput
    SV1 => transitionTo(divChannelBullStrong)
    SV2 => transitionTo(divChannelBull) or transitionTo(divChannelBullStrong)
    => false
bool dnMarkerOscCondition = 
  switch markerDnOscModeInput
    ST3 => transitionTo(oscChannelBearStrong)
    ST4 => transitionTo(oscChannelBear) or transitionTo(oscChannelBearStrong)
    => false
bool dnMarkerDivCondition = 
  switch markerDnDivModeInput
    SV3 => transitionTo(divChannelBearStrong)
    SV4 => transitionTo(divChannelBear) or transitionTo(divChannelBearStrong)
    => false

// Apply filters to base conditions.
bool upMarker = upMarkerOscCondition or upMarkerDivCondition
bool dnMarker = dnMarkerOscCondition or dnMarkerDivCondition
upMarker := 
  (markerUpOscModeInput != ST0 or markerUpDivModeInput != SV0) and upMarker and barstate.isconfirmed and
  (not markerClosePolarityInput or closeToCloseUp) and 
  (not markerOscInput           or oscBull)        and
  (not markerRisingVolInput     or risingVolume)   and
  (not markerDivInput           or divPresent)
dnMarker := 
  (markerDnOscModeInput != ST0 or markerDnDivModeInput != SV0) and dnMarker and barstate.isconfirmed and
  (not markerClosePolarityInput or closeToCloseDn) and 
  (not markerOscInput           or oscBear)        and
  (not markerRisingVolInput     or risingVolume)   and
  (not markerDivInput           or divPresent)
//#endregion



//#region ———————————————————— Visuals


// ————— Oscillator Channel lines and fill.

// Determine colors.
color refLineColor = na
color oscLineColor  = na
color oscChannelColor  = na
switch
    oscChannelBullStrong =>
        refLineColor    := refLineUpUpColorInput
        oscLineColor    := oscLineUpUpColorInput
        oscChannelColor := oscChannelUpUpColorInput
    oscChannelBearStrong =>
        refLineColor    := refLineDnDnColorInput
        oscLineColor    := oscLineDnDnColorInput
        oscChannelColor := oscChannelDnDnColorInput
    oscChannelBull =>
        refLineColor    := refLineUpColorInput
        oscLineColor    := oscLineUpColorInput
        oscChannelColor := oscChannelUpColorInput
    oscChannelBear =>
        refLineColor    := refLineDnColorInput
        oscLineColor    := oscLineDnColorInput
        oscChannelColor := oscChannelDnColorInput
color oscColor = combinedWeight > 0 ? oscLineUpUpColorInput : combinedWeight < 0 ? oscLineDnDnColorInput : color.silver

// Styles for lines.
var refLineStyle = lineStyleFromUserInput(refLineStyleInput)
var oscLineStyle = lineStyleFromUserInput(oscLineStyleInput)

// Plot lines and fill them.
var bool plotOscLineValues = reflLineShowInput or osclLineShowInput or oscChannelShowInput
weightedPlot = plot(plotOscLineValues ? weightedRef : na, "Weighted Reference",  osclLineShowInput  ? oscLineColor  : na, oscLineWidthInput, oscLineStyle)
refPlot      = plot(plotOscLineValues and not na(combinedWeight) ? reference : na, "Reference", reflLineShowInput ? refLineColor : na, refLineWidthInput, refLineStyle)
fill(weightedPlot, refPlot, reference, weightedRef, oscChannelShowInput ? oscChannelColor : na, oscChannelShowInput ? color.new(oscChannelColor, 90) : na, "Fill")


// ————— Divergence channel lines and fill.

// Determine colors.
color divLinesColor = na
color divChannelColor  = na
if divChannelBreached
    switch
        divChannelBullStrong =>
            divLinesColor := divLinesUpUpColorInput
            divChannelColor  := divChannelUpUpColorInput
        divChannelBearStrong =>
            divLinesColor := divLinesDnDnColorInput
            divChannelColor  := divChannelDnDnColorInput
        divChannelBull =>
            divLinesColor := divLinesUpColorInput
            divChannelColor  := divChannelUpColorInput
        divChannelBear =>
            divLinesColor := divLinesDnColorInput
            divChannelColor  := divChannelDnColorInput
        =>
            divLinesColor := divLinesNtColorInput
            divChannelColor  := divChannelNtColorInput
else
    switch
        divChannelBiasInput and preBreachBiasBull =>
            divLinesColor := divLinesUpColorInput
            divChannelColor  := divChannelUpColorInput
        divChannelBiasInput and preBreachBiasBear =>
            divLinesColor := divLinesDnColorInput
            divChannelColor  := divChannelDnColorInput
        =>
            divLinesColor := divLinesNtColorInput
            divChannelColor  := divChannelNtColorInput

// Plot the channel levels and fill.
var bool plotDivLineValues = divLinesShowInput or divChannelShowInput
var divLineStyle = lineStyleFromUserInput(divLinesStyleInput)
float divChannelMid = math.avg(divChannelHi, divChannelLo)
divChannelHiPlot  = plot(plotDivLineValues ? divChannelHi  : na, "Divergence Channel Hi", not newDivChannel and divLinesShowInput ? divLinesColor : na, divLinesWidthInput, divLineStyle)
divChannelLoPlot  = plot(plotDivLineValues ? divChannelLo  : na, "Divergence Channel Lo", not newDivChannel and divLinesShowInput ? divLinesColor : na, divLinesWidthInput, divLineStyle)

// This midline is used to start/end the two different gradient fills used to fill the divergence channel.
divChannelMidPlot = plot(plotDivLineValues ? divChannelMid : na, "Divergence Channel Mid", na, display = display.none)

// Fill from the middle going up and down.
fill(divChannelHiPlot, divChannelMidPlot, divChannelHi, divChannelMid, not newDivChannel and divChannelShowInput ? divChannelColor : na, not newDivChannel and divChannelShowInput ? color.new(divChannelColor, 99) : na)
fill(divChannelMidPlot, divChannelLoPlot, divChannelMid, divChannelLo, not newDivChannel and divChannelShowInput ? color.new(divChannelColor, 99) : na, not newDivChannel and divChannelShowInput ? divChannelColor : na)


// ————— Display key values in indicator values and Data Window.

displayLocations  = display.status_line + display.data_window
color osc1Color   = weight1 > 0 ? color.lime : color.fuchsia
color osc2Color   = weight2 > 0 ? color.lime : color.fuchsia
color oscXColor   = weightX > 0 ? color.lime : color.fuchsia
color weightColor = weight  > 0 ? color.lime : color.fuchsia
plot(refSource,             "Reference source",         display = displayLocations, color = refLineColor)
plot(weightedSource,        "Weighted source",          display = displayLocations, color = oscLineColor)
plot(na,                    "═════════════════",        display = displayLocations)
plot(osc1,                  "Oscillator 1",             display = displayLocations, color = osc1Color)
plot(osc2,                  "Oscillator 2",             display = displayLocations, color = osc2Color)
plot(oscX,                  "Oscillator X",             display = displayLocations, color = oscXColor)
plot(weight1,               "Weight 1",                 display = displayLocations, color = osc1Color)
plot(weight2,               "Weight 2",                 display = displayLocations, color = osc2Color)
plot(weightX,               "Weight X",                 display = displayLocations, color = oscXColor)
plot(relVolumeWeight,       "Relative Volume weight",   display = displayLocations)
plot(combinedWeight,        "Combined weight",          display = displayLocations, color = weightColor)
plot(na,                    "═════════════════",        display = displayLocations)


// ————— Markers

plotchar(upMarker, "Up Marker",   "▲", location.belowbar, markerUpColorInput, size = size.tiny)
plotchar(dnMarker, "Down Marker", "▼", location.abovebar, markerDnColorInput, size = size.tiny)


// ————— Alerts

switch
    upMarker => alert(alertUpMsgInput)
    dnMarker => alert(alertDnMsgInput)


// ————— Chart bar coloring

// Color
color barColor = if barColorsShowInput
    switch colorBarModeInput
        CB1 =>
            switch
                divergence           => barsDivColorInput
        CB2 =>
            switch
                divergence           => barsDivColorInput
                oscChannelBullStrong => barsUpUpColorInput
                oscChannelBearStrong => barsDnDnColorInput
                oscChannelBull       => barsUpColorInput
                oscChannelBear       => barsDnColorInput
                => barsNtColorInput
        CB3 =>
            switch
                divergence           => barsDivColorInput
                divChannelBullStrong => barsUpUpColorInput
                divChannelBearStrong => barsDnDnColorInput
                divChannelBull       => barsUpColorInput
                divChannelBear       => barsDnColorInput
                => barsNtColorInput
        CB4 =>
            switch
                divergence => barsDivColorInput
                oscChannelBullStrong and divChannelBullStrong => barsUpUpColorInput
                oscChannelBearStrong and divChannelBearStrong => barsDnDnColorInput
                (oscChannelBull or oscChannelBullStrong) and (divChannelBull or divChannelBullStrong) => barsUpColorInput
                (oscChannelBear or oscChannelBearStrong) and (divChannelBear or divChannelBearStrong) => barsDnColorInput
                => barsNtColorInput
        => na
else
    na

// Empty bodies on decreasing chart volume.
if barsEmptyOnDecVolInput and ta.falling(volume, 1) and not divergence
    barColor := na

barcolor(barColor)


// ————— Plot character showing divergences. 

plotchar(charDivShowInput ? divergence : na, "Divergence character", charDivInput, charDivAboveInput ? location.abovebar : location.belowbar, charDivColorInput, size = size.tiny)
//#endregion
````
