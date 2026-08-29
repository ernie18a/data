<!-- tradingview-pine-id: PUB;71dc373bc0a346e4a6f6cfee048365ce -->
<!-- tradingviewscripts-format: 1 -->
# Delta Volume Channels [LucF]

Source: https://www.tradingview.com/script/zkBuiFk7-Delta-Volume-Channels-LucF/

## Description

█ OVERVIEW

This indicator displays on-chart visuals aimed at making the most of delta ​volume information. It can color bars and display two channels: one for delta ​volume, another calculated from the price levels of bars where delta ​volume divergences occur. Markers and alerts can also be configured using key conditions, and filtered in many different ways. The indicator caters to traders who prefer chart visuals over raw values. It will work on historical bars and in real time, using intrabar analysis to calculate delta ​volume in both conditions.

█ CONCEPTS

Delta Volume

​The ​volume delta concept divides a bar's ​volume in "up" and "down" ​volumes. The delta is calculated by subtracting down ​volume from up ​volume. Many calculation techniques exist to isolate up and down ​volume within a bar. The simplest techniques use the polarity of interbar price changes to assign their ​volume to up or down slots, e.g., [On Balance Volume](https://www.tradingview.com/u/?solution=43000502593) or the [Klinger Oscillator](https://www.tradingview.com/u/?solution=43000589157). Others such as [Chaikin Money Flow](https://www.tradingview.com/chart/?solution=43000501974) use assumptions based on a bar's OHLC values. The most precise calculation method uses tick data and assigns the ​volume of each tick to the up or down slot depending on whether the transaction occurs at the bid or ask price. While this technique is ideal, it requires huge amounts of data on historical bars, which usually limits the historical depth of charts and the number of symbols for which tick data is available.

This indicator uses intrabar analysis to achieve a compromise between the simplest and most precise methods of calculating ​volume delta. In the context where historical tick data is not yet available on TradingView, intrabar analysis is the most precise technique to calculate ​volume delta on historical bars on our charts. TradingView's [Volume Profile built-in indicators](https://www.tradingview.com/u/?solution=43000502040) use it, as do the [CVD - Cumulative ​Volume Delta Candles](https://www.tradingview.com/script/NlM312nK-CVD-Cumulative-Volume-Delta-Candles/) and [CVD - Cumulative Volume Delta (Chart)](https://www.tradingview.com/script/hFcy7CIq-CVD-Cumulative-Volume-Delta-Chart/) indicators published from the [TradingView account](https://www.tradingview.com/u/TradingView/#published-scripts). My [Volume Delta Columns Pro](https://www.tradingview.com/script/F2ylEYOO-Delta-Volume-Columns-Pro-LucF/) indicator also uses intrabar analysis. Other ​volume delta indicators such as my [Realtime 5D Profile](https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/) use realtime chart updates to achieve more precise ​volume delta calculations. Indicators of that type cannot be used on historical bars however; they only work in real time.

This is the logic I use to assign intrabar ​volume to up or down slots:
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are different, their relative position is used.
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are the same, the difference between the intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and the previous intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is used.
 • As a last resort, when there is no movement during an intrabar and it closes at the same price as the previous intrabar, the last known polarity is used.

Once all intrabars making up a chart bar have been analyzed and the up or down property of each intrabar's ​volume determined, the up volumes are added and the down volumes subtracted. The resulting value is ​volume delta for that chart bar, which can be used as an estimate of the buying/selling pressure on an instrument.

Delta ​Volume Percent (DV%)

This value is the proportion that delta ​volume represents of the total intrabar ​volume in the chart bar. Note that on some symbols/timeframes, the total intrabar ​volume may differ from the chart's ​volume for a bar, but that will not affect our calculations since we use the total intrabar ​volume.

Delta ​Volume Channel

The ​​DV channel is the space between two moving averages: the reference line and a DV%-weighted version of that reference. The reference line is a moving average of a type, source and length which you select. The DV%-weighted line uses the same settings, but it averages the DV%-weighted price source.

The weight applied to the source of the reference line is calculated from two values, which are multiplied: DV% and the relative size of the bar's ​volume in relation to previous bars. The effect of this is that DV% values on bars with higher total ​volume will carry greater weight than those with lesser ​volume.

The ​DV channel can be in one of four states, each having its corresponding color:
 • Bull (teal): The DV%-weighted line is above the reference line.
 • Strong bull (lime): The bull condition is fulfilled and the bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is above the reference line and both the reference and the DV%-weighted lines are rising.
 • Bear (maroon): The DV%-weighted line is below the reference line.
 • Strong bear (pink): The bear condition is fulfilled and the bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is below the reference line and both the reference and the DV%-weighted lines are falling.

Divergences

In the context of this indicator, a divergence is any bar where the slope of the reference line does not match that of the DV%-weighted line. No directional bias is assigned to divergences when they occur.

Divergence Channel

The divergence channel is the space between two levels (by default, the bar's [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) and [high](https://www.tradingview.com/pine-script-reference/v5/#var_high)) saved when divergences occur. When price has breached a channel and a new divergence occurs, a new channel is created. Until that new channel is breached, bars where additional divergences occur will expand the channel's levels if the bar's price points are outside the channel.

Prices breaches of the divergence channel will change its state. Divergence channels can be in one of five different states:
 • Bull (teal): Price has breached the channel to the upside.
 • Strong bull (lime): The bull condition is fulfilled and the ​DV channel is in the strong bull state.
 • Bear (maroon): Price has breached the channel to the downside.
 • Strong bear (pink): The bear condition is fulfilled and the ​DV channel is in the strong bear state.
 • Neutral (gray): The channel has not been breached.

█ HOW TO USE THE INDICATOR

Load the indicator on an active chart (see [here](https://www.tradingview.com/u/?solution=43000555216) if you don't know how).

The default configuration displays:
 • The ​DV channel, without the reference or DV%-weighted lines.
 • The Divergence channel, without its level lines.
 • Bar colors using the state of the ​DV channel.

The default settings use an Arnaud-Legoux moving average on the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and a length of 20 bars. The DV%-weighted version of it uses a combination of DV% and relative ​volume to calculate the ultimate weight applied to the reference. The DV%-weighted line is capped to 5 standard deviations of the reference. The lower timeframe used to access intrabars automatically adjusts to the chart's timeframe and achieves optimal balance between the number of intrabars inspected in each chart bar, and the number of chart bars covered by the script's calculations.

The Divergence channel's levels are determined using the high and low of the bars where divergences occur. Breaches of the channel require a bar's [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) to move above the top of the channel, and the bar's [high](https://www.tradingview.com/pine-script-reference/v5/#var_high) to move below the channel's bottom.

No markers appear on the chart; if you want to create alerts from this script, you will need first to define the conditions that will trigger the markers, then create the alert, which will trigger on those same conditions.

To learn more about how to use this indicator, you must understand the concepts it uses and the information it displays, which requires reading this description. There are no videos to explain it.

█ FEATURES

The script's inputs are divided in four sections: "DV channel", "Divergence channel", "Other Visuals" and "Marker/Alert Conditions". The first setting is the selection method used to determine the intrabar precision, i.e., how many lower timeframe bars (intrabars) are examined in each chart bar. The more intrabars you analyze, the more precise the calculation of DV% results will be, but the less chart coverage can be covered by the script's calculations.

DV Channel

Here, you control the visibility and colors of the reference line, its weighted version, and the DV channel between them.

You also specify what type of moving average you want to use as a reference line, its source and length. This acts as the ​DV channel's baseline. The DV%-weighted line is also a moving average of the same type and length as the reference line, except that it will be calculated from the DV%-weighted source used in the reference line. By default, the DV%-weighted line is capped to five standard deviations of the reference line. You can change that value here. This section is also where you can disable the relative ​volume component of the weight.

Divergence Channel

This is where you control the appearance of the divergence channel and the key price values used in determining the channel's levels and breaching conditions. These choices have an impact on the behavior of the channel. More generous level prices like the default [low](https://www.tradingview.com/pine-script-reference/v5/#var_low) and [high](https://www.tradingview.com/pine-script-reference/v5/#var_high) selection will produce more conservative channels, as will the default choice for breach prices.

In this section, you can also enable a mode where an attempt is made to estimate the channel's bias before price breaches the channel. When it is enabled, successive increases/decreases of the channel's top and bottom levels are counted as new divergences occur. When one count is greater than the other, a bull/bear bias is inferred from it.

Other Visuals

You specify here:
 • The method used to color chart bars, if you choose to do so.
 • The display of a mark appearing above or below bars when a divergence occurs.
 • If you want raw values to appear in tooltips when you hover above chart bars. The default setting does not display them, which makes the script faster.
 • If you want to display an information box which by default appears in the lower left of the chart. 
  It shows which lower timeframe is used for intrabars, and the average number of intrabars per chart bar.

Marker/Alert Conditions

Here, you specify the conditions that will trigger up or down markers. The trigger conditions can include a combination of state transitions of the ​DV and the divergence channels. The triggering conditions can be filtered using a variety of conditions.

Configuring the marker conditions is necessary before creating an alert from this script, as the alert will use the marker conditions to trigger.

Markers only appear on bar closes, so they will not repaint. Keep in mind, when looking at markers on historical bars, that they are positioned on the bar when it closes — NOT when it opens.

Raw values

The raw values calculated by this script can be inspected using a tooltip and the Data Window. The tooltip is visible when you hover over the top of chart bars. It will display on the last 500 bars of the chart, and shows the values of ​DV, DV%, the combined weight, and the intermediary values used to calculate them.

█ INTERPRETATION

The aim of the ​DV channel is to provide a visual representation of the buying/selling pressure calculated using delta ​volume. The simplest characteristic of the channel is its bull/bear state. One can then distinguish between its bull and strong bull states, as transitions from strong bull to bull states will generally happen when buyers are losing steam. While one should not infer a reversal from such transitions, they can be a good place to tighten stops. Only time will tell if a reversal will occur. One or more divergences will often occur before reversals.

The nature of the divergence channel's design makes it particularly adept at identifying consolidation areas if its settings are kept on the conservative side. A gray divergence channel should usually be considered a no-trade zone. More adventurous traders can use the ​DV channel to orient their trade entries if they accept the risk of trading in a neutral divergence channel, which by definition will not have been breached by price.

If your charts are already busy with other stuff you want to hold on to, you could consider using only the chart bar coloring component of this indicator:

[image]https://www.tradingview.com/x/WJqTPtMA/[/image]

At its simplest, one way to use this indicator would be to look for overlaps of the strong bull/bear colors in both the ​DV channel and a divergence channel, as these identify points where price is breaching the divergence channel when buy/sell pressure is consistent with the direction of the breach. I have highlighted all those points in the chart below. Not all of them would have produced profitable trades, but nothing is perfect in the markets. Also, keep in mind that the circles identify the visual you would be looking for — not the trade's entry level.

[image]https://www.tradingview.com/x/OyFmF81T/[/image]

█ LIMITATIONS

 • The script will not work on symbols where no ​volume is available. An error will appear when that is the case.
 • Because a maximum of 100K intrabars can be analyzed by a script, a compromise is necessary between the number of intrabars analyzed per chart bar 
  and chart coverage. The more intrabars you analyze per chart bar, the less coverage you will obtain. 
  The setting of the "Intrabar precision" field in the "DV channel" section of the script's inputs 
  is where you control how the lower timeframe is calculated from the chart's timeframe.

█ NOTES

Volume Quality
If you use ​volume, it's important to understand its nature and quality, as it varies with sectors and instruments. My [Volume X-ray](https://www.tradingview.com/script/tPsEizhp-Volume-X-ray-LucF/) indicator is one way you can appraise the quality of an instrument's intraday ​volume.

For Pine Script™ Coders

 • This script uses the new overload of the [fill()](https://www.tradingview.com/pine-script-reference/v5/#fun_fill) function which now makes it possible to do vertical gradients in Pine. I use it for both channels displayed by this script.
 • I use the new arguments for [plot()](https://www.tradingview.com/pine-script-reference/v5/#fun_plot)'s `display` parameter to control where the script plots some of its values, 
  namely those I only want to appear in the script's status line and in the Data Window.
 • I wrote my script using the revised recommendations in the [Style Guide](https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html) from the Pine v5 User Manual.

█ THANKS

To [PineCoders](https://www.tradingview.com/u/PineCoders/#published-scripts). I have used their [lower_tf library ](https://www.tradingview.com/script/UxiDkNg0-lower-tf/) in this script, to manage the calculation of the LTF and intrabar stats, and their [Time library](https://www.tradingview.com/script/tyeeNU9I-Time/) to convert a timeframe in seconds to a printable form for its display in the Information box.

To TradingView's Pine Script™ team. Their innovations and improvements, big and small, constantly expand the boundaries of the language. What this script does would not have been possible just a few months back.

And finally, thanks to all the users of my scripts who take the time to comment on my publications and suggest improvements. I do not reply to all but I do read your comments and do my best to implement your suggestions with the limited time that I have.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LucF

//@version=5
indicator("Delta Volume Channels [LucF]", "DV Channels", true, precision = 6, max_labels_count = 500)

// Delta Volume Channels [LucF]
// v5, 2023.04.16 17:55

// This code was written using the recommendations from the Pine Script™ User Manual's Style Guide:
//   https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html

import PineCoders/Time/2 as PCtime
import PineCoders/lower_tf/4 as PCltf
import LucF/ta/3 as LucfTa



//#region ———————————————————— Constants


// Colors
color  LIME      = #00FF00ff
color  LIME_MD   = #00FF0090
color  LIME_LT   = #00FF0040
color  TEAL      = #008080ff
color  TEAL_MD   = #00808090
color  TEAL_LT   = #00808040
color  PINK      = #FF0080ff
color  PINK_MD   = #FF008090
color  PINK_LT   = #FF008040
color  MAROON    = #800000ff
color  MAROON_MD = #80000090
color  MAROON_LT = #80000040
color  ORANGE    = #c56606ff
color  ORANGE_BR = #FF8000ff
color  GRAY      = #808080ff
color  GRAY_MD   = #80808090
color  GRAY_LT   = #80808030
color  WHITE     = #FFFFFFff
color  BLACK     = #000000ff

// Reference MAs
string MA01 = "Simple MA"
string MA02 = "Exponential MA"
string MA03 = "Wilder MA"
string MA04 = "Weighted MA"
string MA05 = "Volume-weighted MA"
string MA06 = "Arnaud Legoux MA"
string MA07 = "Hull MA"
string MA08 = "Symmetrically-weighted MA"

// Intrabar precisions
string LTF1   = "Covering most chart bars (least precise)"
string LTF2   = "Covering some chart bars (less precise)"
string LTF3   = "Covering less chart bars (more precise)"
string LTF4   = "Covering few chart bars (very precise)"
string LTF5   = "Covering the least chart bars (most precise)"
string LTF6   = "~12 intrabars per chart bar"
string LTF7   = "~24 intrabars per chart bar"
string LTF8   = "~50 intrabars per chart bar"
string LTF9   = "~100 intrabars per chart bar"
string LTF10  = "~250 intrabars per chart bar"

// Line styles
string STL1 = "Line"
string STL2 = "Circles"
string STL3 = "Crosses"

// Marker DV channel transitions
string ST0 = "None"
string ST1 = "DV channel strong bull state"
string ST2 = "DV channel bull or strong bull state"
string ST3 = "DV channel strong bear state"
string ST4 = "DV channel bear or strong bear state"

// Marker Divergence channel transitions
string SV0 = "None"
string SV1 = "Divergence channel strong bull state"
string SV2 = "Divergence channel bull or strong bull state"
string SV3 = "Divergence channel strong bear state"
string SV4 = "Divergence channel bear or strong bear state"

// Bar color choices
string CB0 = "None"
string CB1 = "On divergences only"
string CB2 = "On divergences and on the state of the DV channel"
string CB3 = "On divergences and on the state of the divergence channel"
string CB4 = "On divergences and on the combined state of both channels"

// Channel level sources
string CH1 = "High and Low"
string CH2 = "Open and Close"

// Channel breach sources
string BR1 = "`low` must breach channel's top, `high` must breach channel's bottom"
string BR2 = "`high` must breach channel's top, `low` must breach channel's bottom"
string BR3 = "Close"
string BR4 = "Open"
string BR5 = "The average of high and low (hl2)"
string BR6 = "The average of high, low and close (hlc3)"
string BR7 = "The average of high, low and two times the close (hlcc4)"
string BR8 = "The average of high, low and close and open (ohlc4)"

// Tooltips
string TT_REF       = "Your choices here determine the reference that will be used as the DV channel's baseline.
  The MA type and length defined here are also used to calculate the MA of the DV% weights."
string TT_CAP       = "This is the maximum number of standard deviations away from the reference line that the DV%-weighted line can extend to.
  It limits swings of the DV%-weighted line, keeping the chart's vertical scale within acceptable boundaries."
string TT_RVOL      = "In addition to the weight of DV, use the weight of the relative volume for the bar. 
  This weight is determined using the percentile rank of the bar's volume in the specified number of bars."
string TT_LTF       = "Your selection here controls how many intrabars will be analyzed for each chart bar. 
  The more intrabars you analyze, the more precise the calculations will be,
  but the less chart bars will be covered by the indicator's calculations because a maximum of 100K intrabars can be analyzed.\n\n
  The first five choices determine the lower timeframe used for intrabars using how much chart coverage you want.
  The last five choices allow you to select approximately how many intrabars you want analyzed per chart bar."
string TT_LTF_BOX   = "Displays the LTF used and intrabar statistics in a configurable position and color."
string TT_BIAS      = "This option enables a guess on the bull/bear bias of the channel before it is breached.
  It uses the number of changes of the top/bottom channel levels to determine a bias.
  When more changes of the top level occur, the bias is bullish. When more changes of the bottom level occur, the bias is bearish.
  \n\n Note that enabling this setting will make the channel's states less reliable."
string TT_COLORS    = "'🡑🡑' and '🡓🡓' indicate the colors used for strong bull/bear conditions.
  \n'🡑' and '🡓' indicate bull/bear conditions."
string TT_MARKERS   = "The conditions you use to determine when markers appear will also be used to trigger alerts created from this script.
  \n\nMarkers are non-repainting; they appear on the close of bars."
string TT_BARS      = "If the coloring of bars on divergences is active, their body will always be colored in the divergence color, regardless of this checkbox's state."
string TT_DIV       = "A divergence occurs when the slope of the reference line does not match that of the DV%-weighted line."
string TT_FILTERS   = "The filters are additional conditions that must be true for a marker to appear.
  \n\n'Bar polarity' means that the bar's up/dn polarity must match that of the marker.
  \n\n'Close-to-close polarity' means that the `close` must be higher than the previous one for an up marker, and vice versa.
  \n\n'Bull/bear CCI' means that CCI (using the same source and length as the reference line) must be above/below 0.
  \n\n'Rising volume' means the volume of the bar must be higher than that of the previous bar. This condition is the same for up/dn markers.
  \n\nThe filter on divergences requires a divergence to have occurred in the last number of bars you specify.
  \n\nThe filter on 'Efficient Work' requires its bull/bear state to match the direction of the marker. ('Efficient Work' is one of my indicators).
  \n\nAs markers are non-repainting, keep in mind that marker conditions must be true on the bar's close, which is when the marker will appear."
//#endregion



//#region ———————————————————— Inputs

string  ltfModeInput            = input.string(LTF8,        "Intrabar precision",                   inline = "ltf", options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], tooltip = TT_LTF)

string  GRP0 = "DV channel"
bool    reflLineShowInput       = input.bool(false,         "Reference line ",                      group = GRP0, inline = "refLine")
int     refLineWidthInput       = input.int(1,              " Width",                               group = GRP0, inline = "refLine", minval = 1)
string  refLineStyleInput       = input.string(STL1,        "",                                     group = GRP0, inline = "refLine", options = [STL1, STL2, STL3])
color   refLineUpUpColorInput   = input.color(LIME,         "  🡑🡑",                                 group = GRP0, inline = "refLineColors")
color   refLineDnDnColorInput   = input.color(PINK,         "🡓🡓",                                   group = GRP0, inline = "refLineColors")
color   refLineUpColorInput     = input.color(TEAL,         " 🡑",                                   group = GRP0, inline = "refLineColors")
color   refLineDnColorInput     = input.color(MAROON,       "🡓",                                    group = GRP0, inline = "refLineColors", tooltip = TT_COLORS)
string  refTypeInput            = input.string(MA06,        "  ",                                   group = GRP0, inline = "ref", options = [MA01, MA02, MA03, MA04, MA05, MA06, MA07, MA08], tooltip = TT_REF)
float   refSourceInput          = input.source(close,       "",                                     group = GRP0, inline = "ref")
int     refLengthInput          = input.int(20,             " Length",                              group = GRP0, inline = "ref", minval = 2)

bool    dvlLineShowInput        = input.bool(false,         "DV%-weighted line",                    group = GRP0, inline = "dvLine")
int     dvLineWidthInput        = input.int(2,              " Width",                               group = GRP0, inline = "dvLine", minval = 1)
string  dvLineStyleInput        = input.string(STL1,        "",                                     group = GRP0, inline = "dvLine", options = [STL1, STL2, STL3])
color   dvLineUpUpColorInput    = input.color(LIME,         "  🡑🡑",                                 group = GRP0, inline = "dvLineColors")
color   dvLineDnDnColorInput    = input.color(PINK,         "🡓🡓",                                   group = GRP0, inline = "dvLineColors")
color   dvLineUpColorInput      = input.color(TEAL,         " 🡑",                                   group = GRP0, inline = "dvLineColors")
color   dvLineDnColorInput      = input.color(MAROON,       "🡓",                                    group = GRP0, inline = "dvLineColors")
int     sigmaCapInput           = input.int(5,              "   Cap (in standard deviations)",      group = GRP0, inline = "cap", minval = 1, tooltip = TT_CAP)
bool    useRelVolWeightInput    = input.string("Use",       "  ",                                   group = GRP0, inline = "RelVolW", options = ["Use", "Don't use"], tooltip = TT_RVOL) == "Use"
int     relVolLookbackInput     = input.int(100,            "relative volume over n bars",          group = GRP0, inline = "RelVolW", minval = 2)

bool    dvFillShowInput         = input.bool(true,          "DV channel",                           group = GRP0, inline = "dvFill")
color   dvFillUpUpColorInput    = input.color(LIME_MD,      " 🡑🡑",                                  group = GRP0, inline = "dvFill")
color   dvFillDnDnColorInput    = input.color(PINK_MD,      "🡓🡓",                                   group = GRP0, inline = "dvFill")
color   dvFillUpColorInput      = input.color(TEAL_MD,      " 🡑",                                   group = GRP0, inline = "dvFill")
color   dvFillDnColorInput      = input.color(MAROON_MD,    "🡓",                                    group = GRP0, inline = "dvFill")

string  GRP1 = "Divergence channel"
bool    divLinesShowInput       = input.bool(false,         "Divergence levels",                    group = GRP1, inline = "divLines")
int     divLinesWidthInput      = input.int(1,              " Width",                               group = GRP1, inline = "divLines", minval = 1)
string  divLinesStyleInput      = input.string(STL1,        "",                                     group = GRP1, inline = "divLines", options = [STL1, STL2, STL3])
color   divLinesUpUpColorInput  = input.color(LIME,         "  🡑🡑",                                 group = GRP1, inline = "divLinesColors")
color   divLinesDnDnColorInput  = input.color(PINK,         "🡓🡓",                                   group = GRP1, inline = "divLinesColors")
color   divLinesUpColorInput    = input.color(TEAL,         " 🡑",                                   group = GRP1, inline = "divLinesColors")
color   divLinesDnColorInput    = input.color(MAROON,       "🡓",                                    group = GRP1, inline = "divLinesColors")
color   divLinesNtColorInput    = input.color(GRAY,         "N",                                    group = GRP1, inline = "divLinesColors")

bool    divFillShowInput        = input.bool(true,          "Divergence channel",                   group = GRP1, inline = "divFill")
color   divFillUpUpColorInput   = input.color(LIME_MD,      " 🡑🡑",                                  group = GRP1, inline = "divFill")
color   divFillDnDnColorInput   = input.color(PINK_MD,      "🡓🡓",                                   group = GRP1, inline = "divFill")
color   divFillUpColorInput     = input.color(TEAL_MD,      " 🡑",                                   group = GRP1, inline = "divFill")
color   divFillDnColorInput     = input.color(MAROON_MD,    "🡓",                                    group = GRP1, inline = "divFill")
color   divFillNtColorInput     = input.color(GRAY_MD,      "N",                                    group = GRP1, inline = "divFill")

string  divChannelLevelsInput   = input.string(CH1,         "   Levels are defined using",          group = GRP1, options = [CH1, CH2])
string  divChannelBreachesInput = input.string(BR1,         "   Breaches are determined using",     group = GRP1, options = [BR1, BR2, BR3, BR4, BR5, BR6, BR7, BR8])
bool    divChannelBiasInput     = input.string("Off",       "   Estimate unbreached channel bias",  group = GRP1, options = ["On", "Off"], tooltip = TT_BIAS) == "On"

string  GRP2 = "Other visuals"
string  colorBarModeInput       = input.string(CB2,         "Bar colors",                           group = GRP2, inline = "barMode", options = [CB0, CB1, CB2, CB3, CB4])
bool    barsEmptyOnDecVolInput  = input.bool(false,         "Don't color falling volume bars",      group = GRP2, inline = "barMode", tooltip = TT_BARS)
color   barsUpUpColorInput      = input.color(LIME,         "     🡑🡑",                              group = GRP2, inline = "barColors")
color   barsDnDnColorInput      = input.color(PINK,         "🡓🡓",                                   group = GRP2, inline = "barColors")
color   barsUpColorInput        = input.color(TEAL,         "🡑",                                    group = GRP2, inline = "barColors")
color   barsDnColorInput        = input.color(MAROON,       "🡓",                                    group = GRP2, inline = "barColors")
color   barsNtColorInput        = input.color(GRAY,         "N",                                    group = GRP2, inline = "barColors")
color   barsDivColorInput       = input.color(ORANGE,       "D",                                    group = GRP2, inline = "barColors")

bool    showCharDivInput        = input.bool(false,         "Divergence mark",                      group = GRP2, inline = "divChar")
string  charDivInput            = input.string("•",         "",                                     group = GRP2, inline = "divChar")
color   charDivColorInput       = input.color(ORANGE,       "",                                     group = GRP2, inline = "divChar")
bool    charDivAboveInput       = input.bool(true,          "Above bar",                            group = GRP2, inline = "divChar", tooltip = TT_DIV)


bool    showTooltipsInput       = input.bool(false,         "Tooltips of raw values",               group = GRP2)
bool    showInfoBoxInput        = input.bool(true,          "Information box",                      group = GRP2, tooltip = TT_LTF_BOX)
string  infoBoxSizeInput        = input.string("small",     "  ",                                   group = GRP2, inline = "infoBox", options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput        = input.string("bottom",    "↕",                                    group = GRP2, inline = "infoBox", options = ["top", "middle", "bottom"])
string  infoBoxXPosInput        = input.string("left",      "↔",                                    group = GRP2, inline = "infoBox", options = ["left", "center", "right"])
color   infoBoxColorInput       = input.color(GRAY_MD,      "",                                     group = GRP2, inline = "infoBox")
color   infoBoxTxtColorInput    = input.color(BLACK,        "T",                                    group = GRP2, inline = "infoBox")

string  GRP3 = "Marker/Alert conditions"
string  markerUpDvModeInput     = input.string(ST0,         "Up markers on transitions to  ",       group = GRP3, inline = "upMarker", options = [ST0, ST1, ST2])
string  markerUpDivModeInput    = input.string(SV0,         "",                                     group = GRP3, inline = "upMarker", options = [SV0, SV1, SV2])
color   markerUpColorInput		= input.color(ORANGE_BR,      "🡑",			                               group = GRP3, inline = "upMarker", tooltip = TT_MARKERS)
string  markerDnDvModeInput     = input.string(ST0,         "Down markers on transitions to",       group = GRP3, inline = "dnMarker", options = [ST0, ST3, ST4])
string  markerDnDivModeInput    = input.string(SV0,         "",                                     group = GRP3, inline = "dnMarker", options = [SV0, SV3, SV4])
color   markerDnColorInput		= input.color(ORANGE_BR,      "🡓",                                    group = GRP3, inline = "dnMarker")
bool    markerBarPolarityInput  = input.bool(false,         "Filter on bar polarity  ",             group = GRP3, inline = "Filters1")
bool    markerClosePolarityInput= input.bool(false,         "Filter on close-to-close polarity",    group = GRP3, inline = "Filters1", tooltip = TT_FILTERS)
bool    markerCciStateInput     = input.bool(false,         "Filter on bull/bear CCI     ",         group = GRP3, inline = "Filters2")
bool    markerRisingVolInput    = input.bool(false,         "Filter on rising volume",              group = GRP3, inline = "Filters2")
bool    markerDivInput          = input.bool(false,         "Filter on divergence in last n bars",  group = GRP3, inline = "Filters3")
int     markerDivBarsInput      = input.int(5,              "",                                     group = GRP3, inline = "Filters3", minval = 1)
bool    markerEwInput           = input.bool(false,         "Filter on bull/bear Efficient Work",   group = GRP3, inline = "Filters4")
string  alertUpMsgInput         = input.text_area("▲",      "Up alert text",                        group = GRP3)
string  alertDnMsgInput         = input.text_area("▼",      "Down alert text",					            group = GRP3)
//#endregion



//#region ———————————————————— Functions


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


// Lower timeframe (LTF) used to mine intrabars.
var string intrabarTf = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)

// Get two arrays, one each for up and dn volumes of intrabars. `dnVolumes` values are negative.
[upVolumes, dnVolumes] = request.security_lower_tf(syminfo.tickerid, intrabarTf, LucfTa.upDnIntrabarVolumesByPolarity())

// Total up/dn volumes for intrabars.
float totalUpVolume = array.sum(upVolumes)
float totalDnVolume = array.sum(dnVolumes)

// Total volume for intrabars.
float intrabarVolume = totalUpVolume - totalDnVolume

// Delta volume
float dv = totalUpVolume + totalDnVolume

// Delta volume percent
float dvPct    = (dv / intrabarVolume) * 100
float dvWeight = math.abs(dvPct / 100)

// Relative volume weight
float relVolPctRank   = ta.percentrank(intrabarVolume, relVolLookbackInput) / 100.
float relVolumeWeight = na(dv) ? na : useRelVolWeightInput ? relVolPctRank : 1

// Combined weight
float combinedWeight  = dvWeight * relVolumeWeight

// MAs of reference source and capped dv%-weighted source.
float weightedSource = refSourceInput + (math.sign(dvPct) * math.min(refSourceInput * combinedWeight, sigmaCapInput * ta.stdev(refSourceInput, refLengthInput)))
float reference      = LucfTa.ma(refTypeInput, refSourceInput, refLengthInput)
float dvWeightedRef  = LucfTa.ma(refTypeInput, weightedSource, refLengthInput)

// Determine bull/bear and strong bull/bear states of the DV channel.
bool dvChannelBull = dvWeightedRef > reference
bool dvChannelBear = not dvChannelBull
bool dvChannelBullStrong = dvChannelBull and close > reference and ta.rising(reference, 1)  and ta.rising(dvWeightedRef, 1)
bool dvChannelBearStrong = dvChannelBear and close < reference and ta.falling(reference, 1) and ta.falling(dvWeightedRef, 1)

// Intrabar stats
[intrabars, chartBarsCovered, avgIntrabars] = PCltf.ltfStats(upVolumes)
float volumeOnAllIntrabars = ta.cum(intrabarVolume)
float allIntrabars = ta.cum(intrabars)

// Error detection
if volumeOnAllIntrabars == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")
else if allIntrabars == 0 and barstate.islast
    runtime.error("No intrabar information exists at the '" + intrabarTf + "' timeframe.")


// ————— Divergence channel

// Detect divergences between the slope of the reference line and that of the DV-weighted line.
bool divergence = dv != 0 and math.sign(ta.change(reference)) != math.sign(ta.change(dvWeightedRef))

// Level sources
float divChannelHiSrc = divChannelLevelsInput == CH1 ? high : math.max(open, close)
float divChannelLoSrc = divChannelLevelsInput == CH1 ? low  : math.min(open, close)

// Breach sources
[divBreachHiSrc, divBreachLoSrc] =
  switch divChannelBreachesInput
    BR1 => [low,    high]
    BR2 => [high,   low]
    BR3 => [close,  close]
    BR4 => [open,   open]
    BR5 => [hl2,    hl2]
    BR6 => [hlc3,   hlc3]
    BR7 => [hlcc4,  hlcc4]
    BR8 => [ohlc4,  ohlc4]
    => [float(na), float(na)]

// Update the divergence channel.
[divChannelHi, divChannelLo, divChannelBull, divChannelBear, divChannelBreached, newDivChannel, preBreachUpChanges, preBreachDnChanges] = 
  LucfTa.divergenceChannel(divergence, divChannelHiSrc, divChannelLoSrc, divBreachHiSrc, divBreachLoSrc)

// If needed, take a guess on the state of the channel when it has not yet been breached.
bool preBreachBiasBull = not divChannelBreached and divChannelBiasInput and preBreachUpChanges > preBreachDnChanges
bool preBreachBiasBear = not divChannelBreached and divChannelBiasInput and preBreachUpChanges < preBreachDnChanges

// Strong bull/bear states occur when the divergence channel's bull/bear state matches that of the DV channel.
bool divChannelBullStrong = divChannelBull and dvChannelBullStrong
bool divChannelBearStrong = divChannelBear and dvChannelBearStrong



// ————— Marker filters and triggers

// Bar polarity
bool barUp = close > open
bool barDn = close < open

// Close-to-close polarity
bool closeToCloseUp = ta.change(close) > 0
bool closeToCloseDn = ta.change(close) < 0

// CCI bull/bear
float cciSignal = ta.cci(close, refLengthInput)
bool cciBull    = cciSignal > 0
bool cciBear    = cciSignal < 0

// RIsing volume
bool risingVolume = ta.change(volume) > 0

// Divergence in last n bars
bool divPresent = ta.barssince(divergence) <= markerDivBarsInput

// Efficient work
float ew = LucfTa.efficientWork(refLengthInput)
bool ewBull = ew > 0
bool ewBear = ew < 0

// Base conditions for markers to appear.
bool upMarkerDvCondition = 
  switch markerUpDvModeInput
    ST1 => transitionTo(dvChannelBullStrong)
    ST2 => transitionTo(dvChannelBull) or transitionTo(dvChannelBullStrong)
    => false
bool upMarkerDivCondition = 
  switch markerUpDivModeInput
    SV1 => transitionTo(divChannelBullStrong)
    SV2 => transitionTo(divChannelBull) or transitionTo(divChannelBullStrong)
    => false
bool dnMarkerDvCondition = 
  switch markerDnDvModeInput
    ST3 => transitionTo(dvChannelBearStrong)
    ST4 => transitionTo(dvChannelBear) or transitionTo(dvChannelBearStrong)
    => false
bool dnMarkerDivCondition = 
  switch markerDnDivModeInput
    SV3 => transitionTo(divChannelBearStrong)
    SV4 => transitionTo(divChannelBear) or transitionTo(divChannelBearStrong)
    => false

// Apply filters to base conditions.
bool upMarker = upMarkerDvCondition or upMarkerDivCondition
bool dnMarker = dnMarkerDvCondition or dnMarkerDivCondition
upMarker := 
  (markerUpDvModeInput != ST0 or markerUpDivModeInput != SV0) and upMarker and barstate.isconfirmed and
  (not markerBarPolarityInput   or barUp)          and 
  (not markerClosePolarityInput or closeToCloseUp) and 
  (not markerCciStateInput      or cciBull)        and
  (not markerRisingVolInput     or risingVolume)   and
  (not markerDivInput           or divPresent)     and
  (not markerEwInput            or ewBull)
dnMarker := 
  (markerDnDvModeInput != ST0 or markerDnDivModeInput != SV0) and dnMarker and barstate.isconfirmed and
  (not markerBarPolarityInput   or barDn)          and 
  (not markerClosePolarityInput or closeToCloseDn) and 
  (not markerCciStateInput      or cciBear)        and
  (not markerRisingVolInput     or risingVolume)   and
  (not markerDivInput           or divPresent)     and
  (not markerEwInput            or ewBear)
//#endregion



//#region ———————————————————— Visuals


// ————— DV Channel lines and fill.

// Determine colors.
[refLineColor, dvLineColor, dvFillColor] =
  switch
    dvChannelBullStrong => [refLineUpUpColorInput, dvLineUpUpColorInput, dvFillUpUpColorInput]
    dvChannelBearStrong => [refLineDnDnColorInput, dvLineDnDnColorInput, dvFillDnDnColorInput]
    dvChannelBull       => [refLineUpColorInput,   dvLineUpColorInput,   dvFillUpColorInput]
    dvChannelBear       => [refLineDnColorInput,   dvLineDnColorInput,   dvFillDnColorInput]
    => [color(na), color(na), color(na)]
color dvColor = dv > 0 ? dvLineUpUpColorInput : dv < 0 ? dvLineDnDnColorInput : color.silver

// Styles for lines.
var refLineStyle = lineStyleFromUserInput(refLineStyleInput)
var dvLineStyle  = lineStyleFromUserInput(dvLineStyleInput)

// Plot lines and fill them.
var bool plotDvLineValues = reflLineShowInput or dvlLineShowInput or dvFillShowInput
dvRefPlot = plot(plotDvLineValues ? dvWeightedRef : na,            "DV-weighted Reference",  dvlLineShowInput  ? dvLineColor  : na, dvLineWidthInput,  dvLineStyle)
refPlot   = plot(plotDvLineValues and not na(dv) ? reference : na, "Reference",              reflLineShowInput ? refLineColor : na, refLineWidthInput, refLineStyle)
fill(dvRefPlot, refPlot, reference, dvWeightedRef, dvFillShowInput ? dvFillColor : na, dvFillShowInput ? color.new(dvFillColor, 90) : na, "Fill")


// ————— Divergence channel lines and fill.

// Determine colors.
[divLinesColor, divFillColor] =
  switch
    divChannelBreached =>
        switch
            divChannelBullStrong => [divLinesUpUpColorInput, divFillUpUpColorInput]
            divChannelBearStrong => [divLinesDnDnColorInput, divFillDnDnColorInput]
            divChannelBull       => [divLinesUpColorInput,   divFillUpColorInput]
            divChannelBear       => [divLinesDnColorInput,   divFillDnColorInput]
            => [divLinesNtColorInput, divFillNtColorInput]
    =>
        switch
            divChannelBiasInput and preBreachBiasBull => [divLinesUpColorInput, divFillUpColorInput]
            divChannelBiasInput and preBreachBiasBear => [divLinesDnColorInput, divFillDnColorInput]
            => [divLinesNtColorInput, divFillNtColorInput]

// Plot the channel levels and fill.
var bool plotDivLineValues = divLinesShowInput or divFillShowInput
var divLineStyle = lineStyleFromUserInput(divLinesStyleInput)
float divChannelMid = math.avg(divChannelHi, divChannelLo)
divChannelHiPlot = plot(plotDivLineValues ? divChannelHi  : na, "Divergence Channel Hi", not newDivChannel and divLinesShowInput ? divLinesColor : na, divLinesWidthInput, divLineStyle)
divChannelLoPlot = plot(plotDivLineValues ? divChannelLo  : na, "Divergence Channel Lo", not newDivChannel and divLinesShowInput ? divLinesColor : na, divLinesWidthInput, divLineStyle)

// This midline is used to start/end the two different gradient fills used to fill the divergence channel.
divChannelMidPlot = plot(plotDivLineValues ? divChannelMid : na, "Divergence Channel Mid", na, display = display.none)

// Fill from the middle going up and down.
fill(divChannelHiPlot, divChannelMidPlot, divChannelHi, divChannelMid, not newDivChannel and divFillShowInput ? divFillColor : na, not newDivChannel and divFillShowInput ? color.new(divFillColor, 99) : na)
fill(divChannelMidPlot, divChannelLoPlot, divChannelMid, divChannelLo, not newDivChannel and divFillShowInput ? color.new(divFillColor, 99) : na, not newDivChannel and divFillShowInput ? divFillColor : na)


// ————— Display key values in indicator values and Data Window.

float signedDvWeight = dvPct / 100
float signedCombinedWeight = math.sign(signedDvWeight) * combinedWeight
displayLocations = display.status_line + display.data_window
plot(na,                    "═════════════════",      display = displayLocations)
plot(signedDvWeight,        "DV% weight (1=100%)",    display = displayLocations, color = dvColor)
plot(relVolumeWeight,       "Relative Volume weight", display = displayLocations)
plot(signedCombinedWeight,  "Combined weight",        display = displayLocations, color = dvColor)
plot(na,                    "═════════════════",      display = displayLocations)
plot(dv,                    "Volume delta",           display = displayLocations, color = dvColor)
plot(totalUpVolume,         "Up volume for the bar",  display = displayLocations, color = dvLineUpUpColorInput)
plot(totalDnVolume,         "Dn volume for the bar",  display = displayLocations, color = dvLineDnDnColorInput)
plot(intrabarVolume,        "Total intrabar volume",  display = displayLocations)
plot(na,                    "═════════════════",      display = displayLocations)
plot(intrabars,             "Intrabars in this bar",  display = displayLocations)
plot(avgIntrabars,          "Average intrabars",      display = displayLocations)
plot(chartBarsCovered,      "Chart bars covered",     display = displayLocations)
plot(bar_index + 1,         "Chart bars",             display = displayLocations)


// ————— Markers

plotchar(upMarker, "Up Marker",   "▲", location.belowbar, markerUpColorInput, size = size.tiny)
plotchar(dnMarker, "Down Marker", "▼", location.abovebar, markerDnColorInput, size = size.tiny)


// ————— Alerts

switch
    upMarker => alert(alertUpMsgInput)
    dnMarker => alert(alertDnMsgInput)


// ————— Chart bars.

// Color
color barColor =
  switch colorBarModeInput
    CB0 =>
        na
    CB1 =>
        switch
            divergence           => barsDivColorInput
    CB2 =>
        switch
            divergence           => barsDivColorInput
            dvChannelBullStrong  => barsUpUpColorInput
            dvChannelBearStrong  => barsDnDnColorInput
            dvChannelBull        => barsUpColorInput
            dvChannelBear        => barsDnColorInput
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
            dvChannelBullStrong and divChannelBullStrong => barsUpUpColorInput
            dvChannelBearStrong and divChannelBearStrong => barsDnDnColorInput
            (dvChannelBull or dvChannelBullStrong) and (divChannelBull or divChannelBullStrong) => barsUpColorInput
            (dvChannelBear or dvChannelBearStrong) and (divChannelBear or divChannelBearStrong) => barsDnColorInput
            => barsNtColorInput
    => na

// Empty bodies on decreasing chart volume.
if barsEmptyOnDecVolInput and ta.falling(volume, 1) and not divergence
    barColor := na

barcolor(barColor)


// ————— Plot character showing divergences. 

plotchar(showCharDivInput ? divergence : na, "Divergence character", charDivInput, charDivAboveInput ? location.abovebar : location.belowbar, charDivColorInput, size = size.tiny)


// ————— Tooltips containing bar stats.
if showTooltipsInput
    string tooltipText = 
      "DV = "    + str.tostring(totalUpVolume, format.volume) +
      " − "      + str.tostring(math.abs(totalDnVolume), format.volume) +
      " = "      + str.tostring(dv, format.volume) +
      "\nDV% = " + str.tostring(dv, format.volume) +
      " / "      + str.tostring(intrabarVolume, format.volume) +
      " = "      + str.tostring(dvPct, format.percent) +
      str.format("\n\nDV weight = {0,number,0.000}\nRelVol weight = {1,number,0.000}\nCombined weight = {2,number,0.000}", signedDvWeight, relVolumeWeight, signedCombinedWeight)
    label.new(bar_index, high, " \n \n \n \n \n \n ", style = label.style_none, color = color(na), tooltip = tooltipText)


// ————— Display information box only once on the last historical bar because it doesn't need to update in real time.
// Display information box only once on the last historical bar, instead of on all realtime updates, as when `barstate.islast` is used.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    color infoBoxBgColor = infoBoxColorInput
    string txt = str.format(
      "Uses intrabars at {0}\nAvg intrabars per chart bar: {1,number,#.##}\nChart bars covered: {2} / {3} ({4,number,percent})", 
      PCtime.formattedNoOfPeriods(timeframe.in_seconds(intrabarTf) * 1000), 
      avgIntrabars, chartBarsCovered, bar_index + 1, chartBarsCovered / (bar_index + 1))
    if avgIntrabars < 5
        txt += "\nThis quantity of intrabars is dangerously small.\nResults will not be as reliable with so few."
        infoBoxBgColor := color.red
    table.cell(infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = infoBoxBgColor)
//#endregion
````
