# Timeframe Heikin Ashi RSI Oscillator

- url: https://www.tradingview.com/script/N05NQ9CN-Timeframe-Heikin-Ashi-RSI-Oscillator/
- type: indicator
- pine_id: PUB;1f08059ad509469aa5851729f47d8068
- version: 1.0

## Description

[b]T-HARSI • Timeframe Heikin Ashi RSI Oscillator (HTF Edition)[/b]

[b]What it is[/b]

An RSI-based oscillator that renders RSI values as Heikin Ashi candles instead of a line, with a full higher-timeframe (HTF) signal engine layered on top. The core idea — originally from [i]JayRogers[/i] — is that translating RSI into HA-style OHLC preserves the oscillating nature of RSI while smoothing out noise and making trend/exhaustion visually obvious. The [i]gggoaaat[/i] mods add a multi-condition overbought/oversold signal system that runs entirely on a user-selectable HTF.

[b]How it's built[/b]

Everything is zero-median: RSI values have 50 subtracted so the oscillator swings around 0 instead of 50, with configurable OB/OS and "extreme" OB/OS bands above and below. Three core pieces generate the visuals:

[list=1]
[*][b]HARSI candles[/b] — RSI is computed separately on close, high, and low, then combined into synthetic OHLC using Heikin Ashi math. Open smoothing biases toward the prior open for cleaner trend reads.
[*][b]RSI overlay line + histogram[/b] — a second RSI (independent length) plotted on top, optionally smoothed using a recursive HA-style average of current vs prior RSI.
[*][b]Stochastic RSI ribbon[/b] — stoch computed from that RSI, with K/D smoothing and a vertical scaling knob so it doesn't distort the channel.
[/list]

[b]The HTF signal engine[/b]

All stateful logic lives inside [i]f_signalLogic()[/i] and is pulled through a single [i]request.security[/i] call, so every counter, [i]ta.barssince[/i], and crossover naturally operates on HTF bars. The engine produces two composite signals:

[list=1]
[*][b]bullishWays[/b] (overbought / fade-long / 🔥OB label) fires when RSI has been above the extreme upper band for N consecutive HTF bars [b]and[/b] a confirming reversal condition hits within a hold window — either a crossover-based resistance touch or a reversal-candle pattern where the HARSI close flips bearish near the extreme.
[*][b]bearishWays[/b] (oversold / fade-short / 🥶OS label) is the symmetric opposite at the lower extreme.
[/list]

A [i]barsBetweenCalls[/i] cooldown prevents back-to-back repeats, and an [i]htfBarEdge[/i] gate ([i]ta.change(time(tf))[/i]) ensures plotshapes, circle-dot plots, and alerts fire exactly once per HTF bar transition rather than repeating across every chart bar that falls inside the same HTF window.

[b]What you see on the chart[/b]

HARSI candles in the pane, OB/OS channel bands with tinted fills, optional RSI line and stoch ribbon, background shading when RSI is sustained beyond an extreme, warning triangles when the sustained-extreme threshold first trips, and 🔥OB / 🥶OS labels with orange/teal price dots on the main chart when a full composite signal fires. Alerts fire on confirmed HTF bar close for both directions.

[b]Intended use[/b]

A mean-reversion / exhaustion tool — the signals flag spots where an HTF RSI has pushed to an extreme, held there, and then showed a reversal confirmation. Best paired with trend context on the main chart; the HARSI pane tells you [i]when[/i] the stretch is exhausted, not [i]which direction the trend actually is[/i].

## Source Code

````pine
// This source code is free to use, copy, and alter in any way you choose.
// ...but credit is always nice :)

//@version=6
//@author=JayRogers and gggoaaat mods

indicator("Timeframe Heikin Ashi RSI Oscillator", "T-HARSI •", false, format=format.price, precision=2)

tf = input.timeframe("", "TF", inline = "11")
_lookahead2 =  input.string("No", title="Look Ahead", options= ['Yes', 'No'], inline = "11") == "Yes" ? true : false

i_barsThreshold = input.int(3, "Bars Cross Threshold", group="RSI Above/Below exTreme", minval=1, tooltip="Number of consecutive HTF bars RSI must be above/below extreme levels", inline = "11a")
holdAbove = input.int(5, "Bars Ago", group="RSI Above/Below exTreme", inline = "11a")
rsiCrossLookback = input.int(2, "RSI Cross Lookback")

barsBetweenCalls = input.int(4, "Bars Between Calls")
////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// ====== ABOUT THIS INDICATOR                                                //
//                                                                            //
//  - RSI based Heikin Ashi candle oscillator                                 //
//                                                                            //
// ====== ARTICLES and FURTHER READING                                        //
//                                                                            //
//  - https://www.investopedia.com/terms/h/heikinashi.asp                     //
//                                                                            //
//    "Heikin-Ashi is a candlestick pattern technique that aims to reduce     //
//    some of the market noise, creating a chart that highlights trend        //
//    direction better than typical candlestick charts"                       //
//                                                                            //
// ====== REASON FOR STUDY                                                    //
//                                                                            //
//  - Mostly experimental. I wanted to see if I could translate RSI into a    //
//    Heikin Ashi function and retain it's oscillating nature. That goal      //
//    was met more easily than I anticipated with quite delightful results.   //
//                                                                            //
// ====== DISCLAIMER                                                          //
//                                                                            //
//    Any trade decisions you make are entirely your own responsibility.      //
//    I've made an effort to squash all the bugs, but you never know!         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                           ====== TOOLTIPS ======                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

string TT_HARSI = "Period for the RSI calculations used to generate the" +
                  "candles. This seperate from the RSI plot/histogram length."

string TT_PBIAS = "Smoothing feature for the OPEN of the HARSI candles." +
                  "\n\nIncreases bias toward the prior open value which can" +
                  " help provide better visualisation of trend strength." +
                  "\n\n** By changing the Open values, High and Low can also" +
                  " be distorted - however Close will remain unchanged."

string TT_SMRSI = "This option smoothes the RSI in a manner similar to HA" +
                  " open, but uses the realtime rsi rather than the prior" +
                  " close value."

string TT_STOCH = "Uses the RSI generated by the above settings, and as such" +
                  " will be affected by the smoothing option."

string TT_STFIT = "Adjusts the vertical scaling of the stochastic, can help" +
                  " to prevent distortion of other data in the channel." +
                  "\n\nHas no impact cross conditions."

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            ====== INPUTS ======                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// -- Candle config

string GROUP_CAND = "Config » HARSI Candles"
i_lenHARSI = input.int(14, "Length", group=GROUP_CAND, minval=1, tooltip=TT_HARSI)
i_smoothing = input.int(1, "Open Smoothing", group=GROUP_CAND, minval=1, maxval=100, tooltip=TT_PBIAS)
string INLINE_COL = "Colour Pallette"
i_colUp = input.color(color.rgb(0, 137, 123, 75), "Colour Pallette  ", group=GROUP_CAND, inline=INLINE_COL)
i_colDown = input.color(color.rgb(255, 82, 82, 72), " ", group=GROUP_CAND, inline=INLINE_COL)
i_colWick = input.color(color.rgb(120, 123, 134, 100), " ", group=GROUP_CAND, inline=INLINE_COL)

// -- RSI plot config

string GROUP_PLOT = "Config » RSI Plot"
// i_source = input.source(ohlc4, "Source", group=GROUP_PLOT)
i_source = input.source(hlcc4, "Source", group=GROUP_PLOT)
i_lenRSI = input.int(7, "Length", group=GROUP_PLOT, minval=1)
i_mode = input.bool(true, "Smoothed Mode RSI?", group=GROUP_PLOT, tooltip=TT_SMRSI)
i_showPlot = input.bool(true, "Show RSI Plot?", group=GROUP_PLOT)
i_showHist = input.bool(true, "Show RSI Histogram?", group=GROUP_PLOT)

// -- Stochastic RSI plots config

string GROUP_STOCH = "Config » Stochastic RSI Plot"
string INLINE_STDS = "Stoch Draw States"
i_showStoch = input.bool(false, "Show Stochastic? ", group=GROUP_STOCH, inline=INLINE_STDS, tooltip=TT_STOCH)
i_ribbon = input.bool(true, "Ribbon?", group=GROUP_STOCH, inline=INLINE_STDS)
i_smoothK = input.int(3, "Smoothing K", group=GROUP_STOCH, minval=1)
i_smoothD = input.int(3, "Smoothing D", group=GROUP_STOCH, minval=1)
i_stochLen = input.int(14, "Stochastic Length", group=GROUP_STOCH, minval=1)
i_stochFit = input.int(80, "Stoch Scaling %", group=GROUP_STOCH, minval=1, maxval=100, tooltip=TT_STFIT)

// -- Channel OB/OS config

string GROUP_CHAN = "Config » OB/OS Boundaries"
i_upper = input.int(18, "OB", group=GROUP_CHAN, inline="OB", minval=1, maxval=50)
i_upperx = input.int(27, "OB Extreme", group=GROUP_CHAN, inline="OB", minval=1, maxval=50)

i_lower = input.int(-15, "OS", group=GROUP_CHAN, inline="OS", minval=-50, maxval=-1)
i_lowerx = input.int(-19, "OS Extreme", group=GROUP_CHAN, inline="OS", minval=-50, maxval=-1)

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                          ====== FUNCTIONS ======                           //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

//  zero median rsi helper function, just subtracts 50.
f_zrsi(_source, _length) =>
    ta.rsi(_source, _length) - 50

//  zero median stoch helper function, subtracts 50 and includes % scaling
f_zstoch(_source, _length, _smooth, _scale) =>
    float _zstoch = ta.stoch(_source, _source, _source, _length) - 50
    float _smoothed = ta.sma(_zstoch, _smooth)
    float _scaled = (_smoothed / 100) * _scale

//  mode selectable rsi function for standard, or smoothed output
f_rsi(_source, _length, _mode) =>
    //  get base rsi
    float _zrsi = f_zrsi(_source, _length)

    //  smoothing in a manner similar to HA open, but rather using the realtime
    //  rsi in place of the prior close value.
    var float _smoothed = na
    _smoothed := na(_smoothed[1]) ? _zrsi : (_smoothed[1] + _zrsi) / 2

    //  return the requested mode
    _mode ? _smoothed : _zrsi

//  RSI Heikin-Ashi generation function
f_rsiHeikinAshi(_length) =>
    //  get close rsi
    float _closeRSI = f_zrsi(close, _length)

    //  emulate "open" simply by taking the previous close rsi value
    float _openRSI = nz(_closeRSI[1], _closeRSI)

    //  the high and low are tricky, because unlike "high" and "low" by
    //  themselves, the RSI results can overlap each other. So first we just go
    //  ahead and get the raw results for high and low, and then..
    float _highRSI_raw = f_zrsi(high, _length)
    float _lowRSI_raw = f_zrsi(low, _length)
    //  ..make sure we use the highest for high, and lowest for low
    float _highRSI = math.max(_highRSI_raw, _lowRSI_raw)
    float _lowRSI = math.min(_highRSI_raw, _lowRSI_raw)

    //  ha calculation for close
    float _close = (_openRSI + _highRSI + _lowRSI + _closeRSI) / 4

    //  ha calculation for open, standard, and smoothed/lagged
    var float _open = na
    _open := na(_open[i_smoothing]) ? (_openRSI + _closeRSI) / 2 :
             ((_open[1] * i_smoothing) + _close[1]) / (i_smoothing + 1)

    //  ha high and low min-max selections
    float _high = math.max(_highRSI, math.max(_open, _close))
    float _low = math.min(_lowRSI, math.min(_open, _close))

    //  return the OHLC values
    [_open, _high, _low, _close]

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//             ====== SIGNAL LOGIC (runs in HTF context) ======               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// All signal logic lives here so that every ta.*, var counter, and
// ta.barssince call operates in HTF time when invoked via request.security.
f_signalLogic() =>
    // --- core series (HTF-native when called inside request.security)
    float _RSI = f_rsi(i_source, i_lenRSI, i_mode)
    float _StochK = f_zstoch(_RSI, i_stochLen, i_smoothK, i_stochFit)
    float _StochD = ta.sma(_StochK, i_smoothD)
    [_O, _H, _L, _C] = f_rsiHeikinAshi(i_lenHARSI)

    float _atrCustom = _H - _L

    // --- cross-based resistance / support
    bool rsiResistance        = ta.crossover(_C,  i_upper)[rsiCrossLookback] and _RSI > i_upper
    bool rsiExtremeResistance = ta.crossover(_C,  i_upperx)[rsiCrossLookback]
    bool rsiSupport           = ta.crossunder(_C, i_lower)[rsiCrossLookback] and _RSI < i_lower
    bool rsiExtremeSupport    = ta.crossunder(_C, i_lowerx)[rsiCrossLookback]
    bool rsiSellDue           = ta.ema(_atrCustom, 13) > _atrCustom / 3 and ta.crossover(_RSI, 0)
    bool rsiBuyDue            = ta.ema(_atrCustom, 13) > _atrCustom / 3 and ta.crossunder(_RSI, 0)

    bool __rsiResistance        = ta.barssince(rsiResistance)[1]        > 5 and rsiResistance        and _RSI < i_upper
    bool __rsiSupport           = ta.barssince(rsiSupport)[1]           > 5 and rsiSupport           and _RSI > i_lower
    bool __rsiExtremeResistance = ta.barssince(rsiExtremeResistance)[1] > 5 and rsiExtremeResistance and _RSI < i_upper
    bool __rsiExtremeSupport    = ta.barssince(rsiExtremeSupport)[1]    > 5 and rsiExtremeSupport    and _RSI > i_lower

    bool overbought = __rsiResistance or __rsiExtremeResistance
    bool oversold   = __rsiSupport    or __rsiExtremeSupport

    // --- reversal-candle confirmations (HTF bars, not chart bars)
    bool overbought2 = false
    bool oversold2   = false
    if ta.barssince(_RSI > i_upperx) < rsiCrossLookback and _C[1] > _C and _C[0] < _O[0] and _C[1] > i_upper
        overbought2 := true
    if ta.barssince(_RSI < i_lower)  < rsiCrossLookback and _C[1] < _C and _C[0] > _O[0] and _C[1] < i_lower
        oversold2 := true

    // --- consecutive-bar counters (now counting HTF bars)
    var int barsAboveUpperX = 0
    var int barsBelowLowerX = 0
    if _RSI > i_upperx
        barsAboveUpperX += 1
        barsBelowLowerX := 0
    else if _RSI < i_lowerx
        barsBelowLowerX += 1
        barsAboveUpperX := 0
    else
        barsAboveUpperX := 0
        barsBelowLowerX := 0

    bool rsiAboveUpperX            = barsAboveUpperX >= i_barsThreshold
    bool rsiBelowLowerX            = barsBelowLowerX >= i_barsThreshold
    bool rsiJustCrossedAboveUpperX = barsAboveUpperX == i_barsThreshold
    bool rsiJustCrossedBelowLowerX = barsBelowLowerX == i_barsThreshold

    // --- composite signals with hold window + cooldown (HTF bars)
    bool bullishWays = ta.barssince(rsiJustCrossedAboveUpperX) < holdAbove and (overbought2 or overbought)
    bool bearishWays = ta.barssince(rsiJustCrossedBelowLowerX) < holdAbove and (oversold2   or oversold)

    if ta.barssince(bullishWays)[1] < barsBetweenCalls
        bullishWays := false
    if ta.barssince(bearishWays)[1] < barsBetweenCalls
        bearishWays := false

    [_RSI, _StochK, _StochD, _O, _H, _L, _C,
     bullishWays, bearishWays,
     rsiJustCrossedAboveUpperX, rsiJustCrossedBelowLowerX,
     rsiAboveUpperX, rsiBelowLowerX]

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                   ====== HTF REQUEST.SECURITY CALL ======                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

[_RSI, _StochK, _StochD, _O, _H, _L, _C, bullishWays, bearishWays, rsiJustCrossedAboveUpperX, rsiJustCrossedBelowLowerX, rsiAboveUpperX, rsiBelowLowerX] =
     request.security(syminfo.tickerid, tf, f_signalLogic(),
      lookahead = _lookahead2 ? barmerge.lookahead_on : barmerge.lookahead_off,
      gaps = barmerge.gaps_off)

// Edge detection: true on the first chart bar where a new HTF bar has begun.
// Used to avoid repeating plots/alerts across every chart bar inside one HTF bar.
htfBarEdge = ta.change(time(tf)) != 0

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                         ====== COLOURS ======                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

//  candle body colouring
color bodyColour = _C > _O ? i_colUp : i_colDown
color wickColour = i_colWick

//  shadow, invisible
color colShadow = color.rgb(0, 0, 0, 20)
color colNone = color.rgb(0, 0, 0, 100)

//  rsi color
color colRSI = color.rgb(250, 200, 50, 0)

//  stoch ribbon fill
color colStochK = color.new(#0094FF, 0)
color colStochD = color.new(#FF6A00, 0)
color colStochFill = _StochK >= _StochD ? color.new(colStochK, 50) : color.new(colStochD, 50)

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                     ====== DRAWING and PLOTTING ======                     //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

//  zero median RSI channel hlines
upperx = hline(i_upperx, "OB Extreme", color.new(color.silver, 60))
upper = hline(i_upper, "OB", color.new(color.silver, 80))
median = hline(0, "Median", color.orange, hline.style_dotted)
lower = hline(i_lower, "OS", color.new(color.silver, 80))
lowerx = hline(i_lowerx, "OS Extreme", color.new(color.silver, 60))

//  channel fill
fill(upper, upperx, color.new(color.red, 90), title="Background Fill OB")
fill(upper, lower, color.new(color.blue, 90), title="Background Channel")
fill(lower, lowerx, color.new(color.green, 90), title="Background Fill OS")

//  histogram first, so it is on the bottom of the plot/candle draw stack
plot(i_showHist ? _RSI : na, "RSI Histogram", color.new(color.silver, 80), 3, plot.style_histogram)

//  HARSI candles
plotcandle(_O, _H, _L, _C, "HARSI", bodyColour, wickColour, bordercolor=bodyColour)

//  RSI overlay plot
plot(i_showPlot ? _RSI : na, "RSI Shadow", colShadow, 3)
plot_rsi = plot(i_showPlot ? _RSI : na, "RSI Overlay", colRSI, 1)

//  Stochastic RSI plots and fill
plot(i_showStoch ? _StochK : na, "Stoch K Shadow", not i_ribbon ? colShadow : colNone, 3)
plot(i_showStoch ? _StochD : na, "Stoch D Shadow", not i_ribbon ? colShadow : colNone, 3)
plot_stochK = plot(i_showStoch ? _StochK : na, "Stoch K", not i_ribbon ? colStochK : colNone, 1)
plot_stochD = plot(i_showStoch ? _StochD : na, "Stoch D", not i_ribbon ? colStochD : colNone, 1)
fill(plot_stochK, plot_stochD, i_ribbon ? colStochFill : na)

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                     ====== SIGNAL VISUALS + ALERTS ======                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

//  Visual feedback - plot background colors
bgcolor(rsiAboveUpperX ? color.new(color.red,   90) : na, title="RSI Above Upper Extreme")
bgcolor(rsiBelowLowerX ? color.new(color.green, 90) : na, title="RSI Below Lower Extreme")

//  Plot shapes when sustained-extreme condition first triggers
plotshape(rsiJustCrossedAboveUpperX and htfBarEdge and barstate.isconfirmed, "RSI Sustained Above",
     style=shape.triangledown, location=location.abovebar,
     color=color.rgb(255, 82, 82, 100), size=size.small, text="⚠️", force_overlay=true)

plotshape(rsiJustCrossedBelowLowerX and htfBarEdge and barstate.isconfirmed, "RSI Sustained Below",
     style=shape.triangleup, location=location.belowbar,
     color=color.rgb(76, 175, 79, 100), size=size.small, text="⚠️", force_overlay=true)

//  Composite bullish/bearish signal labels
plotshape(bullishWays and htfBarEdge and barstate.isconfirmed, "Overbought",
     style=shape.labeldown, location=location.abovebar, color=color.rgb(255, 82, 82, 100),
     size=size.tiny, text="🔥\n\OB", textcolor=color.white, editable=true, force_overlay=true, offset=0)

plotshape(bearishWays and htfBarEdge and barstate.isconfirmed, "Oversold",
     style=shape.labelup, location=location.belowbar, color=color.rgb(33, 149, 243, 100),
     size=size.tiny, text="OS\n\n🥶", textcolor=color.white, editable=true, force_overlay=true, offset=0)

//  Persistent signal-price dots
var float bullPlot = na
var float bearPlot = na

if bullishWays and htfBarEdge
    bullPlot := close

if bearishWays and htfBarEdge
    bearPlot := close

plot(bullPlot, "Overbought", color=color.orange, style=plot.style_circles, linewidth=1, force_overlay=true)
plot(bearPlot, "Oversold",   color=color.teal,   style=plot.style_circles, linewidth=1, force_overlay=true)

//  Alerts - fire once per HTF bar transition
if bearishWays and htfBarEdge and barstate.isconfirmed
    alert(syminfo.ticker + " Overbought " + str.tostring(close), alert.freq_once_per_bar_close)

if bullishWays and htfBarEdge and barstate.isconfirmed
    alert(syminfo.ticker + " Oversold "   + str.tostring(close), alert.freq_once_per_bar_close)
````
