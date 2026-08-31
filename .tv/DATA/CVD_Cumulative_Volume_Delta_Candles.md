<!-- tradingview-pine-id: PUB;fb6471a4d9d84f8ebaf879ba690d6b23 -->
<!-- tradingviewscripts-format: 1 -->
# CVD - Cumulative Volume Delta Candles

Source: https://www.tradingview.com/script/NlM312nK-CVD-Cumulative-Volume-Delta-Candles/

## Description

█  OVERVIEW

This indicator displays cumulative ​volume delta in candle form. It uses intrabar information to obtain more precise ​volume delta information than methods using only the chart's timeframe.

█  CONCEPTS

Bar polarity

By bar polarity, we mean the direction of a bar, which is determined by looking at the bar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) vs its [open](https://www.tradingview.com/pine-script-reference/v5/#var_open).

Intrabars

Intrabars are chart bars at a lower timeframe than the chart's. Each 1H chart bar of a 24x7 market will, for example, usually contain 60 bars at the lower timeframe of 1min, provided there was market activity during each minute of the hour. Mining information from intrabars can be useful in that it offers traders visibility on the activity inside a chart bar.

Lower timeframes (LTFs)

A lower timeframe is a timeframe that is smaller than the chart's timeframe. This script uses a ​LTF to access intrabars. The lower the ​LTF, the more intrabars are analyzed, but the less chart bars can display ​CVD information because there is a limit to the total number of intrabars that can be analyzed.

Volume delta

The ​volume delta concept divides a bar's ​volume in "up" and "down" ​volumes. The delta is calculated by subtracting down ​volume from up ​volume. Many calculation techniques exist to isolate up and down ​volume within a bar. The simplest techniques use the polarity of interbar price changes to assign their ​volume to up or down slots, e.g., [On Balance Volume](https://www.tradingview.com/u/?solution=43000502593) or the [Klinger Oscillator](https://www.tradingview.com/u/?solution=43000589157). Others such as [Chaikin Money Flow](https://www.tradingview.com/chart/?solution=43000501974) use assumptions based on a bar's OHLC values. The most precise calculation method uses tick data and assigns the ​volume of each tick to the up or down slot depending on whether the transaction occurs at the bid or ask price. While this technique is ideal, it requires huge amounts of data on historical bars, which usually limits the historical depth of charts and the number of symbols for which tick data is available.

This indicator uses intrabar analysis to achieve a compromise between the simplest and most precise methods of calculating ​volume delta. In the context where historical tick data is not yet available on TradingView, intrabar analysis is the most precise technique to calculate ​volume delta on historical bars on our charts. Our [Volume Profile indicators](https://www.tradingview.com/u/?solution=43000502040) use it. Other ​volume delta indicators in our Community Scripts such as the [Realtime 5D Profile](https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/) use realtime chart updates to achieve more precise ​volume delta calculations, but that method cannot be used on historical bars, so those indicators only work in real time.

This is the logic we use to assign intrabar ​volume to up or down slots:
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are different, their relative position is used.
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are the same, the difference between the intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and the previous intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is used.
 • As a last resort, when there is no movement during an intrabar and it closes at the same price as the previous intrabar, the last known polarity is used.

Once all intrabars making up a chart bar have been analyzed and the up or down property of each intrabar's ​volume determined, the up volumes are added and the down volumes subtracted. The resulting value is ​volume delta for that chart bar.

█  FEATURES

CVD Candles

Cumulative ​Volume Delta Candles present ​volume delta information as it evolves during a period of time.

This is how each candle's levels are calculated:
 • open: Each candle's' open level is the cumulative ​volume delta for the current period at the start of the bar.
  This value becomes zero on the first candle following a ​CVD reset.
  The candles after the first one always open where the previous candle closed.
  The candle's high, low and close levels are then calculated by adding or subtracting a ​volume value to the open.
 • high: The highest ​​volume delta value found in intrabars. If it is not higher than the ​volume delta for the bar, then that candle will have no upper wick.
 • low: The lowest ​​volume delta value found in intrabars.  If it is not lower than the ​volume delta for the bar, then that candle will have no lower wick.
 • close: The aggregated ​volume delta for all intrabars. If ​volume delta is positive for the chart bar, then the candle's close will be higher than its open, and vice versa.

The candles are plotted in one of two configurable colors, depending on the polarity of ​volume delta for the bar.

CVD resets

The "cumulative" part of the indicator's name stems from the fact that calculations accumulate during a period of time. This allows you to analyze the progression of ​volume delta across manageable chunks, which is often more useful than looking at ​volume delta cumulated from the beginning of a chart's history.

You can configure the reset period using the "CVD Resets" input, which offers the following selections:
 • None: Calculations do not reset.
 • On a fixed higher timeframe: Calculations reset on the higher timeframe you select in the "Fixed higher timeframe" field.
 • At a fixed time that you specify.
 • At the beginning of the regular session.
 • On a stepped higher timeframe: Calculations reset on a higher timeframe automatically stepped using the chart's timeframe and following these rules:

[pine]
    Chart TF        ​HTF

     <  1min        1H
     <  3H          1D
     <= 12H         1W
     <  1W          1M
     >= 1W          1Y
[/pine]

The indicator's background shows where resets occur.

Intrabar precision

The precision of calculations increases with the number of intrabars analyzed for each chart bar. It is controlled through the script's "Intrabar precision" input, which offers the following selections:
 • Least precise, covering many chart bars
 • Less precise, covering some chart bars 
 • More precise, covering less chart bars
 • Most precise, 1min intrabars

As there is a limit to the number of intrabars that can be analyzed by a script, a tradeoff occurs between the number of intrabars analyzed per chart bar and the chart bars for which calculations are possible.

Total ​volume candles

You can choose to display candles showing the total intrabar ​volume for the chart bar. This provides you with more context to evaluate a bar's ​volume delta by showing it relative to the sum of intrabar ​volume. Note that because of the reasons explained in the "NOTES" section further down, the total ​volume is the sum of all intrabar ​​volume rather than the ​volume of the bar at the chart's timeframe.

Total ​volume candles can be configured with their own up and down colors. You can also control the opacity of their bodies to make them more or less prominent. This publication's chart shows the indicator with total ​volume candles. They are turned off by default, so you will need to choose to display them in the script's inputs for them to plot.

Divergences

Divergences occur when the polarity of ​volume delta does not match that of the chart bar. You can identify divergences by coloring the ​CVD candles differently for them, or by coloring the indicator's background.

Information box

An information box in the lower-left corner of the indicator displays the HTF used for resets, the ​LTF used for intrabars, and the average quantity of intrabars per chart bar. You can hide the box using the script's inputs.

█  INTERPRETATION

The first thing to look at when analyzing ​CVD candles is the side of the zero line they are on, as this tells you if ​CVD is generally ​bullish or ​bearish. Next, one should consider the relative position of successive candles, just as you would with a price chart. Are successive candles trending up, down, or stagnating? Keep in mind that whatever trend you identify must be considered in the context of where it appears with regards to the zero line; an uptrend in a negative ​CVD (below the zero line) may not be as powerful as one taking place in positive ​CVD values, but it may also predate a movement into positive ​CVD territory. The same goes with stagnation; a trader in a long position will find stagnation in positive ​CVD territory less worrisome than stagnation under the zero line.

After consideration of the bigger picture, one can drill down into the details. Exactly what you are looking for in markets will, of course, depend on your trading methodology, but you may find it useful to:
  • Evaluate ​volume delta for the bar in relation to price movement for that bar.
  • Evaluate the proportion that ​​volume delta represents of total ​volume.
  • Notice divergences and if the chart's candle shape confirms a hesitation point, as a Doji would.
  • Evaluate if the progress of ​CVD candles correlates with that of chart bars.
  • Analyze the wicks. As with price candles, long wicks tend to indicate weakness.

Always keep in mind that unless you have chosen not to reset it, your ​CVD resets for each period, whether it is fixed or automatically stepped. Consequently, any trend from the preceding period must re-establish itself in the next.

█  NOTES

Know your volume

Traders using ​volume information should understand the ​volume data they are using: where it originates and what transactions it includes, as this can vary with instruments, sectors, exchanges, timeframes, and between historical and realtime bars. The information used to build a chart's bars and display ​volume comes from data providers (exchanges, brokers, etc.) who often maintain distinct feeds for intraday and ​end-of-day (​EOD) timeframes. How ​volume data is assembled for the two feeds depends on how instruments are traded in that sector and/or the ​volume reporting policy for each feed. Instruments from crypto and forex markets, for example, will often display similar ​volume on both feeds. Stocks will often display variations because [block trades](https://en.wikipedia.org/wiki/Block_trade) or other types of trades may not be included in their intraday ​volume data. ​Futures will also typically display variations.

Note that as intraday vs ​EOD variations exist for historical bars on some instruments, differences may also exist between the realtime feeds used on intraday vs 1D or greater timeframes for those same assets. Realtime reporting rules will often be different from historical feed reporting rules, so variations between realtime feeds will often be different from the variations between historical feeds for the same instrument. The [Volume X-ray](https://www.tradingview.com/script/tPsEizhp-Volume-X-ray-LucF/) indicator can help you analyze differences between intraday and ​EOD ​volumes for the instruments you trade.

If every unit of ​volume is both bought by a buyer and sold by a seller, how can ​volume delta make sense?

Traders who do not understand the mechanics of matching engines (the exchange software that matches orders from buyers and sellers) sometimes argue that the concept of ​volume delta is flawed, as every unit of ​volume is both bought and sold. While they are rigorously correct in stating that every unit of ​volume is both bought and sold, they overlook the fact that information can be mined by analyzing variations in the price of successive ticks, or in our case, intrabars.

Our calculations model the situation where, in fully automated order handling, market orders are generally matched to limit orders sitting in the order book. Buy market orders are matched to quotes at the ask level and sell market orders are matched to quotes at the bid level. As explained earlier, we use the same logic when comparing intrabar prices. While using intrabar analysis does not produce results as precise as when individual transactions — or ticks — are analyzed, results are much more precise than those of methods using only chart prices.

Not only does the concept underlying ​volume delta make sense, it provides a window on an oft-overlooked variable which, with price and time, is the only basic information representing market activity. Furthermore, because the calculation of ​volume delta also uses price and time variations, one could conceivably surmise that it can provide a more complete model than ones using price and time only. Whether or not ​volume delta can be useful in your trading practice, as usual, is for you to decide, as each trader's methodology is different.

For Pine Script™ coders

As our latest [Polarity Divergences](https://in.tradingview.com/script/84Sr3GS4-Polarity-Divergences/) publication, this script uses the recently released [request.security_lower_tf()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security_lower_tf) Pine Script™ function discussed in [this blog post](https://www.tradingview.com/blog/en/request-more-data-from-your-scripts-31944/). It works differently from the usual [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) in that it can only be used at LTFs, and it returns an array containing one value per intrabar. This makes it much easier for programmers to access intrabar information.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView

//@version=6
indicator("CVD - Cumulative Volume Delta Candles", "CVD Candle", format = format.volume)

// CVD - Cumulative Volume Delta Candles
// v8, 2026.01.09

// This code's style is based on the recommendations from the Pine Script User Manual's Style guide:
//    https://www.tradingview.com/pine-script-docs/writing/style-guide/



import PineCoders/Time/5 as PCtime
import PineCoders/lower_tf/5 as PCltf
import TradingView/ta/12 as TVta



//#region ———————————————————— Constants and inputs


// ————— Constants

int     MS_IN_MIN   = 60 * 1000
int     MS_IN_HOUR  = MS_IN_MIN  * 60
int     MS_IN_DAY   = MS_IN_HOUR * 24

// Default colors
color   GRAY        = #808080ff
color   LIME        = #00FF00ff
color   MAROON      = #800000ff
color   ORANGE      = #FF8000ff
color   PINK        = #FF0080ff
color   TEAL        = #008080ff
color   BG_DIV      = color.new(ORANGE, 90)
color   BG_RESETS   = color.new(GRAY, 90)

// Reset conditions
string  RST1 = "None"
string  RST2 = "On a stepped higher timeframe"
string  RST3 = "On a fixed higher timeframe..."
string  RST4 = "At a fixed time..."
string  RST5 = "At the beginning of the regular session"
string  RST6 = "At the first visible chart bar"
string  RST7 = "On trend changes..."

// Trend types
string  TR01 = "Supertrend"
string  TR02 = "Aroon"
string  TR03 = "Parabolic SAR"

// Volume delta calculation modes
string  VD01 = "Volume delta"
string  VD02 = "Volume delta percent"

// LTF precision options
string LTF1  = "Covering most chart bars (least precise)"
string LTF2  = "Covering some chart bars (less precise)"
string LTF3  = "Covering less chart bars (more precise)"
string LTF4  = "Covering few chart bars (very precise)"
string LTF5  = "Covering the least chart bars (most precise)"
string LTF6  = "~12 intrabars per chart bar"
string LTF7  = "~24 intrabars per chart bar"
string LTF8  = "~50 intrabars per chart bar"
string LTF9  = "~100 intrabars per chart bar"
string LTF10 = "~250 intrabars per chart bar"

// Tooltips
string TT_RST = (
    "Specifies the reset behavior of the CVD calculation. When selecting one of the last three options, use the "
    + "inputs below to specify additional settings for the reset conditions."
)
string TT_RST_HTF = (
    "Specifies the higher timeframe to use for the 'On a fixed higher timeframe' CVD reset option. "
    + "The CVD calculation resets at the open of a bar on the specified timeframe."
)
string TT_RST_TIME = (
    "Hour: 0-23\nMinute: 0-59\nThese values specify the fixed time of day to use for the 'At a fixed time' CVD reset "
    + "option. The CVD calculation resets when the time of day is after or equal to the bar's opening time and "
    + "before the bar's closing time."
)
string TT_RST_TREND = (
    "These values control the settings of the trend indicator to use for the 'On trend changes' CVD reset option. "
    + "The CVD calculation resets when the indicator signals a change in trend direction.\n\n"
    + "The first field specifies the length for the Aroon indicator or the ATR length for the Supertrend indicator.\n\n"
    + "The second field specifies the ATR multiplier for the Supertrend indicator.\n\n"
    + "The Parabolic SAR uses predefined settings. Neither field affects it."
)
string TT_TOTVOL = (
    "If enabled and the calculation mode is 'Volume delta', the indicator projects each bar's total volume from the "
    + "open of each CVD candle for visual comparison.\n\nThe 'Bodies' field specifies the transparency of the total "
    + "volume candle bodies. A value of 0 means fully opaque, and 100 means completely transparent."
)
string TT_LINE = "Select to view a line plot displaying the close values of the CVD candles."
string TT_LTF  = (
    "Controls the number of intrabars that the indicator analyzes per chart bar. "
    + "Increasing the intrabars per chart bar enables more precise calculations. However, it also reduces the number "
    + "of chart bars that the indicator can analyze. "
    + "The first five options determine the requested lower timeframe based on a desired relative amount of chart bar "
    + "coverage. The last five determine the timeframe based on an approximate number of intrabars per chart bar."
)
string TT_MA = (
    "Select to plot an average of the CVD. If the 'CVD resets' input is 'None', the indicator calculates a moving "
    + "average with the length specified by the 'Length' field. Otherwise, it calculates the cumulative average of the "
    + "CVD since the last reset."
)


// ————— Inputs

string  resetInput              = input.string(RST2,         "CVD resets",                       inline = "00", options = [RST1, RST2, RST5, RST6, RST3, RST4, RST7], tooltip = TT_RST)
string  fixedTfInput            = input.timeframe("D",       "  Fixed higher timeframe:",        tooltip = TT_RST_HTF)
int     hourInput               = input.int(9,               "  Fixed time: Hour",               inline = "01", minval  = 0, maxval = 23)
int     minuteInput             = input.int(30,              "Minute",                           inline = "01", minval  = 0, maxval = 59, tooltip = TT_RST_TIME)
string  trendInput              = input.string(TR01,         "  Trend: ",                        inline = "02", options = [TR02, TR03, TR01])
int     trendPeriodInput        = input.int(14,              " Length",                          inline = "02", minval = 2)
float   trendValue2Input        = input.float(3.0,           "",                                 inline = "02", minval = 0.25, step = 0.25, tooltip = TT_RST_TREND)
string  ltfModeInput            = input.string(LTF3,         "Intrabar precision",               inline = "03", options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], tooltip = TT_LTF)
string  vdCalcModeInput         = input.string(VD01,         "Volume delta calculation",         inline = "04", options = [VD01, VD02])

string  GRP1 = "Visuals"
bool    showCandlesInput        = input.bool(true,           "CVD candles",                      inline = "11", group = GRP1)
color   upColorInput            = input.color(LIME,          " 🡑",                               inline = "11", group = GRP1)
color   dnColorInput            = input.color(PINK,          "🡓",                                inline = "11", group = GRP1)
bool    colorDivBodiesInput     = input.bool(true,           "Color CVD bodies on divergences ", inline = "12", group = GRP1)
color   upDivColorInput         = input.color(TEAL,          "🡑",                                inline = "12", group = GRP1)
color   dnDivColorInput         = input.color(MAROON,        "🡓",                                inline = "12", group = GRP1)
bool    showTotVolInput         = input.bool(false,          "Total volume candle borders",      inline = "13", group = GRP1)
color   upTotVolColorInput      = input.color(TEAL,          "🡑",                                inline = "13", group = GRP1)
color   dnTotVolColorInput      = input.color(MAROON,        "🡓",                                inline = "13", group = GRP1)
int     totVolBodyTranspInput   = input.int(80,              "bodies",                           inline = "13", group = GRP1, minval = 0, maxval = 100, tooltip = TT_TOTVOL)
bool    showLineInput           = input.bool(false,          "CVD line",                         inline = "14", group = GRP1)
color   lineUpColorInput        = input.color(LIME,          " 🡑",                               inline = "14", group = GRP1)
color   lineDnColorInput        = input.color(PINK,          "🡓",                                inline = "14", group = GRP1, tooltip = TT_LINE)
bool    showMaInput             = input.bool(false,          "CVD MA",                           inline = "15", group = GRP1)
color   maUpColorInput          = input.color(TEAL,          "  🡑",                              inline = "15", group = GRP1)
color   maDnColorInput          = input.color(MAROON,        "🡓",                                inline = "15", group = GRP1)
int     maPeriodInput           = input.int(20,              " Length",                          inline = "15", group = GRP1, minval = 2, tooltip = TT_MA)
bool    bgDivInput              = input.bool(false,          "Color background on divergences ", inline = "16", group = GRP1)
color   bgDivColorInput         = input.color(BG_DIV,        "",                                 inline = "16", group = GRP1)
bool    bgResetInput            = input.bool(true,           "Color background on resets ",      inline = "17", group = GRP1)
color   bgResetColorInput       = input.color(BG_RESETS,     "",                                 inline = "17", group = GRP1)
bool    showZeroLineInput       = input.bool(true,           "Zero line",                        inline = "18", group = GRP1)
bool    showInfoBoxInput        = input.bool(true,           "Show information box ",                           group = GRP1)
string  infoBoxSizeInput        = input.string("small",      "Size ",                            inline = "19", group = GRP1, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput        = input.string("bottom",     "↕",                                inline = "19", group = GRP1, options = ["top", "middle", "bottom"])
string  infoBoxXPosInput        = input.string("right",      "↔",                                inline = "19", group = GRP1, options = ["left", "center", "right"])
color   infoBoxColorInput       = input.color(color.gray,  "",                                 inline = "19", group = GRP1)
color   infoBoxTxtColorInput    = input.color(color.white, "T",                                inline = "19", group = GRP1)
//#endregion



//#region ———————————————————— Functions


// @function            Categorizes volume as upward or downward based on price action.
// @returns             ([float, float]) A tuple containing the upward and downward volume values. The first value
//                      is the bar's volume if the volume is upward. Otherwise, the second value is the bar's volume.
//                      If a call to `request.security_lower_tf()` uses a call to this function as its `expression`
//                      argument, it returns a tuple of "float" arrays containing the upward and downward volume for
//                      each available intrabar in the chart bar.
upDnIntrabarVolumes() =>
    float upVol = 0.0
    float dnVol = 0.0
    switch
        close > open     => upVol += volume
        close < open     => dnVol -= volume
        close > close[1] => upVol += volume
        close < close[1] => dnVol -= volume
        upVol[1] > 0     => upVol += volume
        dnVol[1] < 0     => dnVol -= volume
        close == open    => upVol += volume
    [upVol, dnVol]


// @function            Selects a string representing a higher timeframe based on the chart's timeframe.
// @returns             (simple string) A timeframe string.
htfStep() =>
    int tfInMs = timeframe.in_seconds() * 1000
    string result = switch
        tfInMs <= MS_IN_MIN       => "60"
        tfInMs <  MS_IN_HOUR * 3  => "1D"
        tfInMs <= MS_IN_HOUR * 12 => "1W"
        tfInMs <  MS_IN_DAY  * 7  => "1M"
        =>                           "12M"


// @function            Determines whether an intraday bar opens before or at a specified time of day and closes after
//                      that time.
// @param hours         (series int) The hour of the day.
// @param minutes       (series int) The minute within the hour.
// @returns             (bool) `true` if the bar's span includes the specified time of day, and `false` otherwise.
timeReset(int hours, int minutes) =>
    int openTime = timestamp(year, month, dayofmonth, hours, minutes, 0)
    bool timeInBar = time <= openTime and time_close > openTime
    bool result = timeframe.isintraday and not timeInBar[1] and timeInBar
//#endregion



//#region ———————————————————— Calculations


// @variable A string representing the lower timeframe for which to retrieve intrabar data.
var string ltfString = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)

// Retrieve the IDs of arrays containing upward and downward volume for each available intrabar in the current bar.
[upVolumes, dnVolumes] = request.security_lower_tf(
    syminfo.tickerid, ltfString, upDnIntrabarVolumes(), calc_bars_count = 200000
)

// Calculate the maximum volumes, total volume, and volume delta values.
float totalUpVolume = nz(upVolumes.sum())
float totalDnVolume = nz(dnVolumes.sum())
float maxUpVolume   = nz(upVolumes.max())
float maxDnVolume   = nz(dnVolumes.min())
float totalVolume   = totalUpVolume - totalDnVolume
float delta         = totalUpVolume + totalDnVolume
float deltaPct      = delta / totalVolume
bool  isDelta       = vdCalcModeInput == VD01
float barDelta      = isDelta ? delta : deltaPct

// Declare variables to track CVD and reset information.
var float cvd = 0.0
[reset, hasTrendDirection, trendIsUp, resetDescription] = switch resetInput
    RST1 => [false, false, false, "No resets"]
    RST2 => [timeframe.change(htfStep()), false, false, "Resets every " + htfStep()]
    RST3 => [timeframe.change(fixedTfInput), false, false, "Resets every " + fixedTfInput]
    RST4 => [
         timeReset(hourInput, minuteInput), false, false,
         str.format("Resets at {0,number,00}:{1,number,00}", hourInput, minuteInput)
     ]
    RST5 => [session.isfirstbar_regular, false, false, "Resets at the beginning of the session"]
    RST6 => [time == chart.left_visible_bar_time, false, false, "Resets at the beginning of visible bars"]
    RST7 =>
        switch trendInput
            TR01 =>
                [_, direction] = ta.supertrend(trendValue2Input, trendPeriodInput)
                [ta.change(direction, 1) != 0, true, direction == -1, "Resets on Supertrend changes"]
            TR02 =>
                [up, dn] = TVta.aroon(trendPeriodInput)
                [ta.cross(up, dn), true, ta.crossover(up, dn), "Resets on Aroon changes"]
            TR03 =>
                float psar = ta.sar(0.02, 0.02, 0.2)
                [ta.cross(psar, close), true, ta.crossunder(psar, close), "Resets on PSAR changes"]
    => [false, false, false, na]

// Rest the CVD to 0 when the `reset` value is `true`.
if reset
    cvd := 0

// Calculate OHLC values for the CVD candles.
float cvdO = cvd
float cvdC = cvdO + barDelta
float cvdH = not isDelta ? math.max(cvdO, cvdC) : cvdO + maxUpVolume
float cvdL = not isDelta ? math.min(cvdO, cvdC) : cvdO + maxDnVolume
cvd += barDelta

// Calculate the average CVD.
var float ma = cvd
var cvdValues = array.new<float>()
if resetInput == RST1
    ma := ta.sma(cvdC, maPeriodInput)
else
    if reset
        cvdValues.clear()
        cvdValues.push(cvd)
    else
        cvdValues.push(cvd)
    ma := cvdValues.avg()

// Calculate OHLC values for the total volume candles.
float totalVolumeLevel = cvdO + (totalVolume * math.sign(barDelta))
[totalVolO, totalVolH, totalVolL, totalVolC] = if showTotVolInput and isDelta
    [cvdO, math.max(cvdO, totalVolumeLevel), math.min(cvdO, totalVolumeLevel), totalVolumeLevel]
else
    [na, na, na, na]

// Retrieve intrabar and chart bar information for the table display.
[intrabars, chartBarsCovered, avgIntrabars] = PCltf.ltfStats(upVolumes)
int chartBars = bar_index + 1

// Detect divergences between volume delta and the bar's polarity.
bool divergence = delta != 0 and math.sign(delta) != math.sign(close - open)
//#endregion



//#region ———————————————————— Visuals


// Calculate candle colors.
color candleColor = (
    delta > 0 ?
    colorDivBodiesInput and divergence ?
    upDivColorInput : upColorInput : colorDivBodiesInput and divergence ?
    dnDivColorInput : dnColorInput
)
color totVolCandleColor = delta > 0 ? upTotVolColorInput : dnTotVolColorInput

// Display key values in the Data Window.
displayLocation = display.data_window
plot(delta,             "Volume delta for the bar",     candleColor,  display = displayLocation)
plot(totalUpVolume,     "Up volume for the bar",        upColorInput, display = displayLocation)
plot(totalDnVolume,     "Dn volume for the bar",        dnColorInput, display = displayLocation)
plot(totalVolume,       "Total volume",                 display = displayLocation)
plot(na,                "═════════════════",            display = displayLocation)
plot(cvdO,              "CVD before this bar",          display = displayLocation)
plot(cvdC,              "CVD after this bar",           display = displayLocation)
plot(maxUpVolume,       "Max intrabar up volume",       upColorInput, display = displayLocation)
plot(maxDnVolume,       "Max intrabar dn volume",       dnColorInput, display = displayLocation)
plot(intrabars,         "Intrabars in this bar",        display = displayLocation)
plot(avgIntrabars,      "Average intrabars",            display = displayLocation)
plot(chartBarsCovered,  "Chart bars covered",           display = displayLocation)
plot(bar_index + 1,     "Chart bars",                   display = displayLocation)
plot(na,                "═════════════════",            display = displayLocation)

// Plot the total volume candles.
plotcandle(
    totalVolO, totalVolH, totalVolL, totalVolC, "CVD", color = color.new(totVolCandleColor, totVolBodyTranspInput),
    wickcolor = totVolCandleColor, bordercolor = totVolCandleColor
)
// Plot the CVD candles.
plotcandle(
    showCandlesInput ? cvdO : na, cvdH, cvdL, cvdC, "CVD", color = candleColor,
    wickcolor = candleColor, bordercolor = candleColor
)
// Plot the CVD line and average.
plot(showLineInput ? cvdC : na, "CVD line", cvdC > 0 ? lineUpColorInput : lineDnColorInput)
plot(showMaInput ? ma : na, "CVD MA", reset ? na : ma > 0 ? maUpColorInput : maDnColorInput)
// Display a horizontal line at 0.
hline(showZeroLineInput ? 0 : na, "Zero", GRAY, hline.style_dotted)

// Plot an up or down arrow when a reset occurs based on trend changes.
plotchar(hasTrendDirection and reset and trendIsUp,     "Up trend", "▲", location.top, upColorInput)
plotchar(hasTrendDirection and reset and not trendIsUp, "Dn trend", "▼", location.top, dnColorInput)

// Color the background on bars where resets or divergences occur.
bgcolor(bgResetInput and reset ? bgResetColorInput : bgDivInput and divergence ? bgDivColorInput : na)

// Create a table to display intrabar information on the last historical bar.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    color infoBoxBgColor = infoBoxColorInput
    string txt = str.format(
        "{0}\nUses intrabars at {1}\nAvg intrabars per chart bar: {2,number,#.##}\n"
        + "Chart bars covered: {3} / {4} ({5,number,percent})",
        resetDescription, PCtime.formattedNoOfPeriods(timeframe.in_seconds(ltfString) * 1000),
        avgIntrabars, chartBarsCovered, bar_index + 1, chartBarsCovered / (bar_index + 1)
    )
    if avgIntrabars < 5
        txt += "\nThis quantity of intrabars is dangerously small.\nResults will not be as reliable with so few."
        infoBoxBgColor := color.red
    table.cell(
        infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = infoBoxBgColor
    )
//#endregion



//#region ———————————————————— Errors


if resetInput == RST3 and timeframe.in_seconds(fixedTfInput) <= timeframe.in_seconds()
    runtime.error("The higher timeframe for resets must be greater than the chart's timeframe.")
else if resetInput == RST4 and not timeframe.isintraday
    runtime.error("Resets at a fixed time of day work on intraday charts only.")
else if ta.cum(totalVolume) == 0 and barstate.islast
    runtime.error("No volume is provided by the data vendor.")
else if ta.cum(intrabars) == 0 and barstate.islast
    runtime.error("No intrabar information is available for the '" + ltfString + "' timeframe.")
//#endregion
````
