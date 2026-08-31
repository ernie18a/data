<!-- tradingview-pine-id: PUB;8jaTc6L9rs236iaMSRPbHYlPXleWmDS2 -->
<!-- tradingviewscripts-format: 1 -->
# MTF Oscillator Framework [PineCoders]

Source: https://www.tradingview.com/script/Wvcqygsx-MTF-Oscillator-Framework-PineCoders/

## Description

This framework allows Pine coders to quickly build a complete multi-timeframe oscillator from any calculation producing values around a centerline, whether the values are bounded or not. Insert your calculation in the script and you have a ready-to-publish MTF Oscillator offering a plethora of presentation options and features.

█ HOW TO USE THE FRAMEWORK

1 — Insert your calculation in the `f_signal()` function at the top of the "Helper Functions" section of the script.
2 — Change the script's name in the `study()` declaration statement and the `alertcondition()` text in the last part of the "Plots" section.
3 — Adapt the default value used to initialize the CENTERLINE constant in the script's "Constants" section.
4 — If you want to publish the script, copy/paste the following description in your new publication's description and replace the "OVERVIEW" section with a description of your calculations.
5 — Voilà!

═════════════════════════════════════════════════════════════════════════

█ OVERVIEW

This oscillator calculates a directional value of True Range. When a bar is up, the positive value of True Range is used. A negative value is used when the bar is down. When there is no movement during the bar, a zero value is generated, even if True Range is different than zero. Because the unit of measure of True Range is price, the oscillator is unbounded (it does not have fixed upper/lower bounds).

True Range can be used as a metric for volatility, but by using a signed value, this oscillator will show the directional bias of progressively increasing/decreasing volatility, which can make it more useful than an always positive value of True Range.

The True Range calculation appeared for the first time in J. Welles Wilder's New Concepts in Technical Trading Systems book published in 1978. Wilder's objective was to provide a reliable measure of the effective movement—or range—between two bars, to measure volatility. True Range is also the building block used to calculate ATR (Average True Range), which calculates the average of True Range values over a given period using the `rma` averaging method—the same used in the calculation of another of Wilder's remarkable creations: RSI.

█ CONCEPTS

This oscillator's design stems from a few key concepts.

Relative Levels
Other than the centerline, relative rather than absolute levels are used to identify levels of interest. Accordingly, no fixed levels correspond to overbought/oversold conditions. Relative levels of interest are identified using:
 • A Donchian channel (historical highs/lows).
 • The oscillator's position relative to higher timeframe values.
 • Oscillator levels following points in time where a divergence is identified.

Higher timeframes
Two progressively higher timeframes are used to calculate larger-context values for the oscillator. The rationale underlying the use of timeframes higher than the chart's is that, while they change less frequently than the values calculated at the chart's resolution, they are more meaningful because more work (trader activity) is required to calculate them. Combining the immediacy of values calculated at the chart's resolution to higher timeframe values achieves a compromise between responsiveness and reliability.

Divergences as points of interest rather than directional clues
A very simple interpretation of what constitutes a divergence is used. A divergence is defined as a discrepancy between any bar's direction and the direction of the signal line on that same bar. No attempt is made to attribute a directional bias to divergences when they occur. Instead, the oscillator's level is saved and subsequent movement of the oscillator relative to the saved level is what determines the bullish/bearish state of the oscillator.

Conservative coloring scheme
Several additive coloring conditions allow the bull/bear coloring of the oscillator's main line to be restricted to specific areas meeting all the selected conditions. The concept is built on the premise that most of the time, an oscillator's value should be viewed as mere noise, and that somewhat like price, it only occasionally conveys actionable information.

█ FEATURES

Plots
 • Three lines can be plotted. They are named Main line, Line 2 and Line 3. You decide which calculation to use for each line:
   • The oscillator's value at the chart's resolution.
   • The oscillator's value at a medium timeframe higher than the chart's resolution.
   • The oscillator's value at the highest timeframe.
   • An aggregate line calculated using a weighed average of the three previous lines (see the Aggregate Weights section of Inputs to configure the weights).
 • The coloring conditions, divergence levels and the Hi/Lo channel always apply to the Main line, whichever calculation you decide to use for it.
 • The color of lines 2 and 3 are fixed but can be set in the "Colors" section of Inputs.
 • You can change the thickness of each line.
 • When the aggregate line is displayed, higher timeframe values are only used in its calculation when they become available in the chart's history,
  otherwise the aggregate line would appear much later on the chart. To indicate when each higher timeframe value becomes available,
  a small label appears near the centerline.
 • Divergences can be shown as small dots on the centerline.
 • Divergence levels can be shown. The level and fill are determined by the oscillator's position relative to the last saved divergence level.
 • Bull/bear markers can be displayed. They occur whenever a new bull/bear state is determined by the "Main Line Coloring Conditions".
 • The Hi/Lo (Donchian) channel can be displayed, and its period defined.
 • The background can display the state of any one of 11 different conditions.
 • The resolutions used for the higher timeframes can be displayed to the right of the last bar's value.
 • Four key values are always displayed in the Data Window (fourth icon down to the right of your chart):
  oscillator values for the chart, medium and highest timeframes, and the oscillator's instant value before it is averaged.

Main Line Coloring Conditions
 • Nine different conditions can be selected to determine the bull/bear coloring of the main line. All conditions set to "ON" must be met to determine the bull/bear state.
 • A volatility state can also be used to filter the conditions.
 • When the coloring conditions and the filter do not allow for a bull/bear state to be determined, the neutral color is used.

Signal
 • Seven different averages can be used to calculate the average of the oscillator's value.
 • The average's period can be set. A period of one will show the instant value of the oscillator,
  provided you don't use linear regression or the Hull MA as they do not work with a period of one.
 • An external signal can be used as the oscillator's instant value. If an already averaged external value is used, set the period to one in this indicator.
 • For the cases where an external signal is used, a centerline value can be set.

Higher Timeframes
 • The two higher timeframes are named Medium timeframe and Highest timeframe. They can be determined using one of three methods:
  • Auto-steps: the higher timeframes are determined using the chart's resolution. If the chart uses a seconds resolution, for example,
   the medium and highest resolutions will be 15 and 60 minutes.
  • Multiples: the timeframes are calculated using a multiple of the chart's resolution, which you can set.
  • Fixed: the set timeframes do not change with the chart's resolution.

Repainting
 • Repainting can be controlled separately for the chart's value and the higher timeframe values.
 • The default is a repainting chart value and non-repainting higher timeframe values. The Aggregate line will thus repaint by default,
  as it uses the chart's value along with the higher timeframes values.

Aggregate Weights
 • The weight of each component of the Aggregate line can be set.
 • The default is equal weights for the three components, meaning that the chart's value accounts for one third of the weight in the Aggregate.

High Volatility
 • This provides control over the volatility filter used in the Main line's coloring conditions and the background display.
 • Volatility is determined to be high when the short-term ATR is greater than the long-term ATR.

Colors
 • You can define your own colors for all of the oscillator's plots.
 • The default colors will perform well on both white and black chart backgrounds.

Alerts
 • An alert can be defined for the script. The alert will trigger whenever a bull/bear marker appears in the indicator's display.
  The particular combination of coloring conditions and the display of bull/bear markers when you create the alert will thus determine when the alert triggers.
  Once the alerts are created, subsequent changes to the conditions controlling the display of markers will not affect the existing alert(s).
 • You can create multiple alerts from this script, each triggering on different conditions.

Backtesting & Trading Engine Signal Line
 • An invisible plot named "BTE Signal" is provided. It can be used as an entry signal when connected to the [PineCoders Backtesting & Trading Engine](https://www.tradingview.com/script/dYqL95JB-Backtesting-Trading-Engine-PineCoders/) as an external input.
  It will generate an entry whenever a marker is displayed.

[Look first. Then leap.](https://www.tradingview.com/athletes/)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// REUSING THIS CODE: You are welcome to reuse this code without permission, but only if you also publish open-source. Credits are appreciated.

//@version=4
//@author=LucF, for PineCoders
// PineCoders, Tools and ideas for all Pine coders: pinecoders.com

// MTF Oscillator Framework - PineCoders FAQ
//  v1.2, 2020.12.23 02:02 — LucF

// This indicator provides a framework that coders can use to build a multi-timeframe oscillator from their own calculations.

// This code was written using the following standards:
//  • PineCoders Coding Conventions for Pine: http://www.pinecoders.com/coding_conventions/
//  • A modified version of the PineCoders MTF Selection Framework: https://www.tradingview.com/script/90mqACUV-MTF-Selection-Framework-PineCoders-FAQ/

study("MTF Oscillator Framework [PineCoders]")



// ———————————————————— Constants {

// ————— Options for inputs.
BGC0 = "None", BGC1 = "Main Line Above/Below Centerline", BGC2 = "Main Line Above/Below Hi/Lo Channel", BGC3 = "Main Line Above/Below Divergence Levels", BGC4 = "Main Line Above/Below Medium TF", BGC5 = "Main Line Above/Below Highest TF"
BGC6 = "Chart TF Above/Below Medium TF", BGC7 = "Chart TF Above/Below Highest TF", BGC8 = "Medium TF Above/Below Centerline", BGC9 = "Highest TF Above/Below Centerline", BGC10 = "High volatility", BGC11 = "Low Volatility"
DIV0 = "None", DIV1 = "Show On Centerline", DIV2 = "Color Chart Bars", DIV3 = "Both"
LIN0 = "None", LIN1 = "Aggregate", LIN2 = "Chart Timeframe", LIN3 = "Medium Timeframe", LIN4 = "Highest Timeframe"
MAT1 = "Simple (SMA)", MAT2 = "Exponential (EMA)", MAT3 = "Weighed (WMA)", MAT4 = "Volume-Weighed (VWMA)", MAT5 = "Arnaud-Legoux (ALMA)", MAT6 = "Linear Regression", MAT7 = "Hull (HMA)"
ON   = "On", OFF = "Off"
TF1  = "Auto-Steps", TF2 = "Multiples", TF3 = "Fixed"
VOL1 = "All", VOL2 = "High only", VOL3 = "Low only"

// ————— Signal's centerline.
CENTERLINE    = 0
// ————— Default colors for color inputs.
c_BULL_BRIGHT = #40FF00ff
c_BULL_MEDIUM = #40FF0080
c_BULL_DARK   = #40FF0040
c_BEAR_BRIGHT = #FF0080ff
c_BEAR_MEDIUM = #FF008080
c_BEAR_DARK   = #FF008040
c_LINE2       = color.orange
c_LINE3       = color.purple
c_NEUTRAL     = color.gray
c_CENTERLINE  = color.silver
c_BACKGR_BULL = #40FF0010
c_BACKGR_BEAR = #FF008010
c_MARKER_BULL = c_BULL_MEDIUM
c_MARKER_BEAR = c_BEAR_MEDIUM
c_DIV_CHART   = color.new(color.orange, 0)
// }



// ———————————————————— Inputs {

_10                 = input(true,           "═════════════ Plots ═══════════════")
i_line1             = input(LIN2,           "Main Line",                            options = [LIN0, LIN1, LIN2, LIN3, LIN4])
i_line1Width        = input(3,              "  Thickness",                          minval  = 1, maxval = 10)
i_line2             = input(LIN0,           "Line 2",                               options = [LIN0, LIN1, LIN2, LIN3, LIN4])
i_line2Width        = input(2,              "  Thickness",                          minval  = 1, maxval = 10)
i_line3             = input(LIN0,           "Line 3",                               options = [LIN0, LIN1, LIN2, LIN3, LIN4])
i_line3Width        = input(1,              "  Thickness",                          minval  = 1, maxval = 10)
i_showDiv           = input(DIV1,           "Divergences",                          options = [DIV0, DIV1, DIV2, DIV3])
i_showDivLevels     = input(ON,             "Divergence Levels",                    options = [OFF, ON]) == ON
i_showMarkersBull   = input(OFF,            "Bull Markers On Color Transitions",    options = [OFF, ON]) == ON
i_showMarkersBear   = input(OFF,            "Bear Markers On Color Transitions",    options = [OFF, ON]) == ON
i_showHiLoChannel   = input(OFF,            "Hi/Lo Channel",                        options = [OFF, ON]) == ON
i_channelLookback   = input(100,            "  Lookback",                           minval  = 1)
i_bgColor           = input(BGC0,           "Background Color",                     options = [BGC0, BGC1, BGC2, BGC3, BGC4, BGC5, BGC6, BGC7, BGC8, BGC9, BGC10, BGC11])
i_tfShow            = input(ON,             "Show Resolution",                      options = [OFF, ON]) == ON
i_offsetTf          = input(3,              "  Label Horizontal Offset")

_20                 = input(true,           "═════ Main Line Coloring Conditions ═══════")
i_colorCond1        = input(OFF,            "Above/Below Centerline",               options = [OFF, ON]) == ON
i_colorCond2        = input(OFF,            "Above/Below Hi/Lo Channel",            options = [OFF, ON]) == ON
i_colorCond3        = input(OFF,            "Above/Below Divergence Levels",        options = [OFF, ON]) == ON
i_colorCond4        = input(OFF,            "Above/Below Medium TF",                options = [OFF, ON]) == ON
i_colorCond5        = input(OFF,            "Above/Below Highest TF",               options = [OFF, ON]) == ON
i_colorCond6        = input(OFF,            "Chart TF Above/Below Medium TF",       options = [OFF, ON]) == ON
i_colorCond7        = input(OFF,            "Chart TF Above/Below Highest TF",      options = [OFF, ON]) == ON
i_colorCond8        = input(OFF,            "Medium TF Above/Below Centerline",     options = [OFF, ON]) == ON
i_colorCond9        = input(OFF,            "Highest TF Above/Below Centerline",    options = [OFF, ON]) == ON
i_colorFilter1      = input(VOL1,           "Filter Conditions On Volatility",      options = [VOL1, VOL2, VOL3])

_30                 = input(true,           "════════════ Signal ═══════════════")
i_maType            = input(MAT5,           "MA Type",                              options = [MAT1, MAT2, MAT3, MAT4, MAT5, MAT6, MAT7])
i_maPeriod          = input(20,             "MA Period",                            minval  = 1)
i_alternateSource   = input(close,          "Alternate Input Source")
i_centerline        = input(CENTERLINE,     "Centerline")

_40                 = input(true,           "══════════ Higher Timeframes ═════════")
i_tfType            = input(TF1,            "Selection Mode",                       options = [TF1, TF2, TF3])
i_mtfMult           = input(5,              "  Multiple For Medium Timeframe")
i_htfMult           = input(10,             "  Multiple For Highest Timeframe")
i_mtfFixedRes       = input("D",            "  Fixed For Medium Timeframe",         type = input.resolution)
i_htfFixedRes       = input("W",            "  Fixed For Highest Timeframe",        type = input.resolution)

_50                 = input(true,           "═══════════ Repainting ═════════════")
i_signalRepaint     = input(ON,             "Repainting of Chart's Timeframe",      options = [OFF, ON]) == ON
i_tfRepaint         = input(OFF,            "Repainting of Higher Timeframes",      options = [OFF, ON]) == ON

_60                 = input(true,           "═════════ Aggregate Weights ══════════")
i_ctfWeight         = input(1.0,            "Weight of Chart TF",                   minval = 0, step = 0.25)
i_mtfWeight         = input(1.0,            "Weight of Medium TF",                  minval = 0, step = 0.25)
i_htfWeight         = input(1.0,            "Weight of Highest TF",                 minval = 0, step = 0.25)

_70                 = input(true,           "══════════ High Volatility ════════════")
i_fastVolatility    = input(7,              "When Short-term ATR",                  minval = 1)
i_slowVolatility    = input(40,             "Is Higher Than Long-term ATR",         minval = 2)

_80                 = input(true,           "════════════ Colors ═══════════════")
i_c_bullBright      = input(c_BULL_BRIGHT,  "Main Line: Bull Bright")
i_c_bullMedium      = input(c_BULL_MEDIUM,  "Main Line: Bull Medium")
i_c_bullDark        = input(c_BULL_DARK,    "Main Line: Bull Dark")
i_c_bearBright      = input(c_BEAR_BRIGHT,  "Main Line: Bear Bright")
i_c_bearMedium      = input(c_BEAR_MEDIUM,  "Main Line: Bear Medium")
i_c_bearDark        = input(c_BEAR_DARK,    "Main Line: Bear Dark")
i_c_neutral         = input(c_NEUTRAL,      "Main Line: Neutral")
i_c_line2           = input(c_LINE2,        "Line 2")
i_c_line3           = input(c_LINE3,        "Line 3")
i_c_centerline      = input(c_CENTERLINE,   "Centerline")
i_c_backgroundBull  = input(c_BACKGR_BULL,  "Background: Bull")
i_c_backgroundBear  = input(c_BACKGR_BEAR,  "Background: Bear")
i_c_markerBull      = input(c_MARKER_BULL,  "Marker: Bull")
i_c_markerBear      = input(c_MARKER_BEAR,  "Marker: Bear")
i_c_div_chart       = input(c_DIV_CHART,    "Chart Bars On Divergences")
// }



// ———————————————————— Helper Functions. {

// ————— Function returning the signal's value.
f_signal() =>
    var noExternalSource = i_alternateSource == close
    if noExternalSource
        // No user-selectable alternate source was given; use this indicator's signal.
        // ▼▼▼▼▼▼▼▼▼▼ YOUR CALCULATIONS GO HERE ▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
        // As an example, we calculate a directional True Range value for our signal.
        sign(close - open) * tr
        // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    else
        // An alternate source was specified by the user; use that as our source.
        i_alternateSource

// ————— Returns 1 when _c boolean is true, 0 if false.
f_01(_c) => _c ? 1 : 0

// ————— Converts current chart resolution into a float minutes value.
f_resInMinutes() => 
    _resInMinutes = timeframe.multiplier * (
      timeframe.isseconds ? 1. / 60             :
      timeframe.isminutes ? 1.                  :
      timeframe.isdaily   ? 60. * 24            :
      timeframe.isweekly  ? 60. * 24 * 7        :
      timeframe.ismonthly ? 60. * 24 * 30.4375  : na)

// ————— Returns resolution of _res string timeframe in minutes.
f_tfResInMinutes(_res) =>
    // _res: resolution of any TF (in `timeframe.period` string format).
    security(syminfo.tickerid, _res, f_resInMinutes())

// ————— Returns a multiple of current resolution as a string in `timeframe.period` format usable with `security()`.
f_multipleOfRes(_res, _mult) => 
    // _res :  current resolution in minutes, in the fractional format supplied by f_resInMinutes() companion function.
    // _mult: Multiple of current TF to be calculated.
    // ————— Convert current float TF in minutes to target string TF in `timeframe.period` string format.
    _targetResInMin = _res * max(_mult, 1)
    // ————— Find best string to express the resolution.
    _targetResInMin   <= 0.083 ? "5S"  :
      _targetResInMin <= 0.251 ? "15S" :
      _targetResInMin <= 0.501 ? "30S" :
      _targetResInMin <= 1440  ? tostring(round(_targetResInMin)) :
      _targetResInMin <= 43800 ? tostring(round(min(_targetResInMin / 1440, 365))) + "D" :
      tostring(round(min(_targetResInMin / 43800, 12))) + "M"

// ————— Given a _res timeframe in float minutes, returns the first higher step for the medium timeframe.
f_resNextStep1(_res) =>
    // _res: current TF in fractional minutes.
    _res   <= 1     ? "15"  :
      _res <= 5     ? "60"  :
      _res <= 30    ? "240" :
      _res <= 360   ? "1D"  :
      _res <= 1440  ? "1W"  :
      _res <= 10080 ? "1M"  : "12M"

// ————— Given a _res timeframe in float minutes, returns the second highest step for the highest timeframe.
f_resNextStep2(_res) =>
    _res   <= 1     ? "60"  :
      _res <= 30    ? "D"   :
      _res <= 1440  ? "1M"  : "12M"

// ————— Print a label at end of chart.
f_print(_txt, _y, _color, _offsetLabels) => 
    var label _lbl = na
    _t = int(time + (time - time[1]) * _offsetLabels)
    if barstate.islast and _txt != ""
        if na(_lbl)
            // Only create label once.
            _lbl := label.new(_t, _y, _txt, xloc.bar_time, yloc.price, #00000000, label.style_none, _color, size.large)
            // Fudge return type of `if` block so compiler doesn't complain (thx to midtownsk8rguy for the trick).
            int(na)
        else
            // Rather than delete and recreate the label on every realtime bar update, update the label's information; it's more efficient.
            label.set_xy(_lbl, _t, _y)
            label.set_text(_lbl, _txt)
            label.set_textcolor(_lbl, _color)
            int(na)

// ————— Function rounding _price to tick precision.
f_roundToTick(_price) => round(_price / syminfo.mintick) * syminfo.mintick

// —————————— Bar up/dn state.
o = f_roundToTick(open)
c = f_roundToTick(close)
// ————— Function returning true when a bar is considered to be an up bar.
f_barUp() => 
    // Dependencies: `o` and `c`, which are the open and close values rounded to tick precision.
    // Account for the normal "close > open" condition, but also for zero movement bars when their close is higher than previous close.
    _result = c > o or (c == o and c > nz(c[1], c))
// ————— Function returning true when a bar is considered to be a down bar.
f_barDn() => 
    // Dependencies: `o` and `c`, which are the open and close values rounded to tick precision.
    // Account for the normal "close < open" condition, but also for zero movement bars when their close is lower than previous close.
    _result = c < o or (c == o and c < nz(c[1], c))

// ————— Function returning true when a high volatility condition is detected.
f_highVolatility() =>
    // Dependencies : i_fastVolatility, i_slowVolatility
    atr(i_fastVolatility) > atr(i_slowVolatility)
// }



// ———————————————————— Calculations. {

// ————— Function returning the MA of the signal.
f_avgSignal(_src, _p, _maType) =>
    // _p           : Initial MA period.
    // _maType      : MA type.
    // Dependencies : MATx constants.
    _maType   == MAT1 ? sma(   _src, _p)          :
      _maType == MAT2 ? ema(   _src, _p)          :
      _maType == MAT3 ? wma(   _src, _p)          :
      _maType == MAT4 ? vwma(  _src, _p)          :
      _maType == MAT5 ? alma(  _src, _p, 0.85, 6) :
      _maType == MAT6 ? linreg(_src, _p, 0)       :
      _maType == MAT7 ? hma(   _src, _p)          : float(na)

// ————— Higher resolutions calcs.
chartResInMinutes = f_resInMinutes()
// Medium timeframe.
mtf = i_tfType == TF1 ? f_resNextStep1(chartResInMinutes) : i_tfType == TF2 ? f_multipleOfRes(chartResInMinutes, i_mtfMult) : i_tfType == TF3 ? i_mtfFixedRes : timeframe.period
// Highest timeframe.
htf = i_tfType == TF1 ? f_resNextStep2(chartResInMinutes) : i_tfType == TF2 ? f_multipleOfRes(chartResInMinutes, i_htfMult) : i_tfType == TF3 ? i_htfFixedRes : timeframe.period

// ————— Signal calculation at chart and higher resolutions.
signal  = f_signal()
sCtf    = f_avgSignal(signal, i_maPeriod, i_maType)[not i_signalRepaint and barstate.isrealtime ? 1 : 0]
sMtf    = i_tfRepaint ? security(syminfo.tickerid, mtf, signal) : security(syminfo.tickerid, mtf, signal[1], false, true)
sHtf    = i_tfRepaint ? security(syminfo.tickerid, htf, signal) : security(syminfo.tickerid, htf, signal[1], false, true)
// ————— Aggregate signal.
// Only use higher TFs when they return a value (thx to scarf for the remark leading to this fix).
mtfWeight = na(sMtf) ? 0 : i_mtfWeight
htfWeight = na(sHtf) ? 0 : i_htfWeight
sAgg = ((sCtf * i_ctfWeight) + (nz(sMtf) * mtfWeight) + (nz(sHtf) * htfWeight)) / (i_ctfWeight + mtfWeight + htfWeight)

// ————— Returns the signal corresponding to _userSelection.
f_line(_userSelection) =>
    // Dependency: LINx constants for line type.
    _userSelection   == LIN1 ? sAgg :
      _userSelection == LIN2 ? sCtf :
      _userSelection == LIN3 ? sMtf :
      _userSelection == LIN4 ? sHtf : na

// ————— Assign lines as per user selections.
line1 = f_line(i_line1)
line2 = f_line(i_line2)
line3 = f_line(i_line3)

// ————— Divergences, defined by the bar's direction being different than the signal's direction.
var float divLevel = na
div = (f_barDn() and rising(line1, 1)) or (f_barUp() and falling(line1, 1))
if div
    // On new divergences, save line1's current level.
    divLevel := line1

// ————— Hi/Lo channel.
channelHi = highest(line1, i_channelLookback)
channelLo = lowest( line1, i_channelLookback)

// ————— Function returning +1/0/-1 as per bull/neutral/bear state of _condNo if _useCond is true.
f_conditionState(_condNo, _useCond) =>
    // _condNo      : condition to be evaluated.
    // _useCond     : boolean determining if the condition must be evaluated.
    // Dependencies : CENTERLINE, channelHi, channelLo, line1, sCtf, sMtf, sHtf.
    if _useCond
        if _condNo == 1
            sign(line1 - i_centerline)
        else if _condNo == 2
            line1 > channelHi[1] ? 1 : line1 < channelLo[1] ? -1 : 0
        else if _condNo == 3
            sign(line1 - divLevel)
        else if _condNo == 4
            sign(line1 - sMtf)
        else if _condNo == 5
            sign(line1 - sHtf)
        else if _condNo == 6
            sign(sCtf - sMtf)
        else if _condNo == 7
            sign(sCtf - sHtf)
        else if _condNo == 8
            sign(sMtf - i_centerline)
        else if _condNo == 9
            sign(sHtf - i_centerline)
        else
            0
    else
        0
        
// ————— Determine main line's color from bull/bear/neutral states of user-selected coloring conditions.
// The Volatility selection in Inputs is applied as a filter, as opposed to a bull/neutral/bear color selection criterion.
filterOk         = (i_colorFilter1 == VOL1 or (i_colorFilter1 == VOL2 and f_highVolatility()) or (i_colorFilter1 == VOL3 and not f_highVolatility()))
// Count how many conditions user has turned on.
qtyOfConditions  = f_01(i_colorCond1) + f_01(i_colorCond2) + f_01(i_colorCond3) + f_01(i_colorCond4) + f_01(i_colorCond5) + f_01(i_colorCond6) + f_01(i_colorCond7) + f_01(i_colorCond8) + f_01(i_colorCond9)
// Add states of all coloring condition.
conditionsStates = f_conditionState(1, i_colorCond1) + f_conditionState(2, i_colorCond2) + f_conditionState(3, i_colorCond3) + f_conditionState(4, i_colorCond4) + f_conditionState(5, i_colorCond5) + f_conditionState(6, i_colorCond6) + f_conditionState(7, i_colorCond7) + f_conditionState(8, i_colorCond8) + f_conditionState(9, i_colorCond9)
// Bull/Bear state triggers when all selected conditions are in agreement.
stateBull        = qtyOfConditions > 0 and conditionsStates ==   qtyOfConditions
stateBear        = qtyOfConditions > 0 and conditionsStates == - qtyOfConditions
// Build color using compound coloring conditions and filter.
c_line1          = not filterOk ? i_c_neutral : stateBull ? i_c_bullBright : stateBear ? i_c_bearBright: i_c_neutral
// }



// ———————————————————— Plots {

// ————— Data Window diplay.
plotchar(sCtf,   "Chart TF",      "", location.top, sCtf   > i_centerline ? i_c_bullBright : i_c_bearBright)
plotchar(sMtf,   "Medium TF",     "", location.top, sMtf   > i_centerline ? i_c_bullBright : i_c_bearBright)
plotchar(sHtf,   "Highest TF",    "", location.top, sHtf   > i_centerline ? i_c_bullBright : i_c_bearBright)
plotchar(signal, "Instant value", "", location.top, signal > i_centerline ? i_c_bullBright : i_c_bearBright)
plotchar(na,     "════════════",  "", location.top, na)

// ————— Hi/Lo channel
plot(i_showHiLoChannel ? channelHi : na, "Channel High")
plot(i_showHiLoChannel ? channelLo : na, "Channel Low")

// ————— Signal lines.
p_line1 = plot(line1, "Main Line", c_line1,   i_line1Width)
plot(line2, "Line 2",    i_c_line2, i_line2Width)
plot(line3, "Line 3",    i_c_line3, i_line3Width)

// ————— Center line.
hline(i_centerline, "Center Line", i_c_centerline, hline.style_dotted)

// ————— Divergences.
c_divLine = change(divLevel) ? color(na) : line1 > divLevel ? i_c_bullMedium : line1 < divLevel ? i_c_bearMedium : i_c_neutral
c_divFill = change(divLevel) ? color(na) : line1 > divLevel ? i_c_bullDark   : line1 < divLevel ? i_c_bearDark   : i_c_neutral
p_div = plot(i_showDivLevels ? divLevel : na, "Divergence Level", c_divLine)
fill(p_line1, p_div, c_divFill, 50)
plotchar((i_showDiv == DIV1 or i_showDiv == DIV3) and div ? i_centerline : na, "Divergence", "•", location.absolute, i_c_centerline, size = size.tiny)

// ————— Markers.
markerUp = i_showMarkersBull and c_line1 == i_c_bullBright and c_line1[1] != i_c_bullBright
markerDn = i_showMarkersBear and c_line1 == i_c_bearBright and c_line1[1] != i_c_bearBright
plotchar(markerUp, "Marker Up", "▲", location.bottom, i_c_markerBull, size = size.tiny)
plotchar(markerDn, "Marker Dn", "▼", location.top,    i_c_markerBear, size = size.tiny)

// ————— Backtesting & Trading Engine external signal line.
plot(markerUp ? 2 : markerDn ? -2 : na, "BTE Signal", display = display.none)

// ————— Chart bars on divergences.
barcolor((i_showDiv == DIV2 or i_showDiv == DIV3) and div ? i_c_div_chart : na)

// —————————— Background.
// ————— Function returning a bull/bear background color from one of the coloring conditions.
f_c_bgColorFromCondition(_condNo) =>
    // _condNo: color condition to evaluate.
    // Dependencies: f_conditionState(), i_c_backgroundBull, i_c_backgroundBear.
    _state = f_conditionState(_condNo, true)
    _state == 1 ? i_c_backgroundBull : _state == -1 ? i_c_backgroundBear : color(na)
// ————— Function returning a bull/bear color from the user-selected background coloring mode.
f_c_background(_userSelection) =>
    // _userSelection : background coloring type.
    // Dependencies : BGCx constants, f_getBgColorFromCondition(), i_c_backgroundBull, i_c_backgroundBear.
    _userSelection   == BGC1  ? f_c_bgColorFromCondition(1) :
      _userSelection == BGC2  ? f_c_bgColorFromCondition(2) :
      _userSelection == BGC3  ? f_c_bgColorFromCondition(3) :
      _userSelection == BGC4  ? f_c_bgColorFromCondition(4) :
      _userSelection == BGC5  ? f_c_bgColorFromCondition(5) :
      _userSelection == BGC6  ? f_c_bgColorFromCondition(6) :
      _userSelection == BGC7  ? f_c_bgColorFromCondition(7) :
      _userSelection == BGC8  ? f_c_bgColorFromCondition(8) :
      _userSelection == BGC9  ? f_c_bgColorFromCondition(9) :
      _userSelection == BGC10 ?     f_highVolatility() ? i_c_backgroundBull : color(na) :
      _userSelection == BGC11 ? not f_highVolatility() ? i_c_backgroundBull : color(na) : color(na)

bgcolor(f_c_background(i_bgColor))

// ————— Show warning or higher timeframes, if needed.
labelText = ""
if chartResInMinutes >= f_tfResInMinutes(mtf) or chartResInMinutes >= f_tfResInMinutes(htf)
    // Chart resolution is higher than one of the fixed TFs.
    labelText := "Chart\nresolution\nmust be < " + mtf + " and " + htf
else
    // Display higher timeframe values.
    if i_tfShow
        labelText := mtf + "\n" + htf
f_print(labelText, 0, color.silver, i_offsetTf)

// ————— When a higher TF signal kicks in, show a label indicating this.
f_higherTfIsUsed(_userSelection) => _userSelection == LIN1 or _userSelection == LIN3 or _userSelection == LIN4
var higherTfIsUsed = f_higherTfIsUsed(i_line1) or f_higherTfIsUsed(i_line2) or f_higherTfIsUsed(i_line3)
if higherTfIsUsed
    if na(sMtf[1]) and not na(sMtf)
        label.new(bar_index, i_centerline, mtf + "►", textcolor = i_c_centerline, style = label.style_none)
    else if na(sHtf[1]) and not na(sHtf)
        label.new(bar_index, i_centerline, htf + "►", textcolor = i_c_centerline, style = label.style_none)

// ————— Alert.
alertcondition(markerUp or markerDn, "MTF Oscillator", "MTF Oscillator")
// }
````
