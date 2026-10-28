# Multiple MA Ribbon

- url: https://www.tradingview.com/script/LOeEydl0-Multiple-MA-Ribbon/
- type: indicator
- pine_id: PUB;0e2776f836484b93b679fe1cda6c3f51
- version: 1.0

## Description

[b]DESCRIPTION[/b]

The [b]Multiple MA Ribbon[/b] is a multi-layer moving average framework designed to provide a structured view of trend strength, alignment, and transition across different time horizons.

The indicator plots a dense ribbon of moving averages, ranging from short-term to longer-term periods, allowing traders to visually assess the consistency and quality of a trend. By observing how these averages align and interact with price, users can better identify trending conditions, consolidation phases, and potential shifts in market direction.

A key feature of the ribbon is its color-coding logic, which reflects the relative position of price with respect to each moving average and a long-term reference (MA100). This creates a gradient-like structure that helps distinguish:
[list]
[*]strong directional trends
[*]weakening momentum
[*]neutral or transitional phases
[/list]
The indicator supports multiple moving average types (including EMA, SMA, HMA, JMA, and others), offering flexibility to adapt to different trading styles and instruments.
Additionally, the script includes:
[list]
[*]optional trend change markers, highlighting moments when full alignment occurs
[*]an integrated VWAP, providing a volume-based reference level
[*]configurable display options for cleaner chart integration
[/list]
Overall, the Multiple MA Ribbon is designed as a visual trend analysis tool, helping traders interpret market structure and momentum through the interaction of multiple smoothed price layers, rather than relying on a single indicator signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SaxaCapital

//@version=6
indicator('Multiple MA Ribbon', shorttitle = 'Multi MA Ribbon', format = format.inherit, max_labels_count = 500, overlay = true)
import TradingView/ta/9

// --- RIBBON CONFIGURATION --

string g_RIB = 'Ribbon Configuration'

showRibbon   = input.bool(defval = true, group = g_RIB, title = 'Show Ribbon', display = display.data_window)
showMarkers  = input.bool(defval = false, title = 'Show trend change markers', group = g_RIB, display = display.data_window)
statusLine   = input.string(defval = 'Display Pane Only', title = 'Display values on status line', group = g_RIB, options = ['Display Pane Only', 'Display Status Line'], display = display.data_window)
MaSRC        = input.source(defval = ohlc4, group = g_RIB, title = 'Moving Average Source', display = display.data_window)
typeMA       = input.string(title = 'Moving Average Type', defval = 'EMA', group = g_RIB, options = ['SMA', 'EMA', 'RMA', 'TMA', 'WMA', 'SMMA', 'HMA', 'ALMA', 'JMA', '2PSS', 'LSMA'], display = display.data_window)

displayMode  = statusLine == 'Display Status Line' ? (display.all - display.price_scale) : (display.pane + display.data_window)
 
// --- DEFINITION OF MOVING AVERAGES --

// Kaufman Adaptive Moving Average
kama(source, length) =>
    Change = math.abs(ta.change(source, length))
    Volatility = math.sum(math.abs(ta.change(source)), length)
    EffRatio = Volatility != 0 ? Change / Volatility : 0
    kama = 0.0
    Fast = 0.666
    Slow = 0.0645
    SmoothConst = math.pow(EffRatio * (Fast - Slow) + Slow, 2)
    kama := nz(kama[1]) + SmoothConst * (source - nz(kama[1]))
    kama

// Smoothed Simple Moving Average
smma(source, length) =>
    smma = 0.0
    smma := na(smma[1]) ? ta.sma(source, length) : (smma[1] * (length - 1) + source) / length
    smma

// Jurik Moving Average
jma(source, length, power, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    jbeta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    jalpha = math.pow(jbeta, power)
    jma = 0.0
    jma0 = 0.0
    jma0 := (1 - jalpha) * source + jalpha * nz(jma0[1])
    jma1 = 0.0
    jma1 := (source - jma0) * (1 - jbeta) + jbeta * nz(jma1[1])
    jma2 = 0.0
    jma2 := (jma0 + phaseRatio * jma1 - nz(jma[1])) * math.pow(1 - jalpha, 2) + math.pow(jalpha, 2) * nz(jma2[1])
    jma := jma2 + nz(jma[1])
    jma

// Ehlers 2 Pole Super Smoother (2PSS)
float PI = 2 * math.asin(1)

e2pss(source, length) =>
    var _a0 = math.sqrt(2) * PI / length
    var _a1 = math.exp(-_a0)
    var _b1 = 2 * _a1 * math.cos(_a0)
    var _c2 = -math.pow(_a1, 2)
    var _c1 = _b1
    var _c0 = 1 - _c1 - _c2
    var _z = 0.0
    _src1 = nz(source[1], source)
    _src2 = nz(source[2], _src1)
    _z    := _c0 * source +
      _c1 * nz(_z[1], _src1) +
      _c2 * nz(_z[2], _src2)

// --- SETTING MOVING AVERAGE TYPE ---

f_ma(maType, maSource, maPeriod) =>
    switch maType
        'SMA'          => ta.sma(maSource, maPeriod) // Simple Moving Average
        'EMA'          => ta.ema(maSource, maPeriod) // Exponential Moving Average
        'RMA'          => ta.rma(maSource, maPeriod) // Exponential Moving Average (RSI)
        'TMA'          => ta.sma(ta.sma(maSource, maPeriod), maPeriod) // Triangular Moving Average
        'WMA'          => ta.wma(maSource, maPeriod) // Weighted Moving Average
        'SMMA'         => smma(maSource, maPeriod) // Smoothed Moving Average
        'HMA'          => ta.hma(maSource, maPeriod) // Hull Moving Average
        'ALMA'         => ta.alma(maSource, maPeriod, 0.85, 6) // Arnaud Legoux Moving Average
        'JMA'          => jma(maSource, maPeriod, 2, 50) // Jurik Moving Average
        '2PSS'         => e2pss(maSource, maPeriod) // Ehlers 2 Pole Super Smoother
        'LSMA'         => ta.linreg(maSource, maPeriod, 0) // Least Squares Moving Average

// --- VWAP ---

string g_VWAP = 'VWAP Settings'

showVWAP    = input.bool(defval = true, title = "Show VWAP", group = g_VWAP, display = display.data_window)
VWAPSRC     = input.source(defval = ohlc4, group = g_VWAP, title = 'VWAP Source', display = display.data_window)

vwapValue = ta.vwap(VWAPSRC)

// --- MOVING AVERAGES ---

ma002   = (f_ma(typeMA, MaSRC, 2))
ma004   = (f_ma(typeMA, MaSRC, 4))
ma006   = (f_ma(typeMA, MaSRC, 6))
ma008   = (f_ma(typeMA, MaSRC, 8))
ma010   = (f_ma(typeMA, MaSRC, 10))
ma014   = (f_ma(typeMA, MaSRC, 14))
ma018   = (f_ma(typeMA, MaSRC, 18))
ma020   = (f_ma(typeMA, MaSRC, 20))
ma022   = (f_ma(typeMA, MaSRC, 22))
ma024   = (f_ma(typeMA, MaSRC, 24))
ma026   = (f_ma(typeMA, MaSRC, 26))
ma028   = (f_ma(typeMA, MaSRC, 28))
ma030   = (f_ma(typeMA, MaSRC, 30))
ma033   = (f_ma(typeMA, MaSRC, 33))
ma036   = (f_ma(typeMA, MaSRC, 36))
ma038   = (f_ma(typeMA, MaSRC, 38))
ma040   = (f_ma(typeMA, MaSRC, 40))
ma043   = (f_ma(typeMA, MaSRC, 43))
ma045   = (f_ma(typeMA, MaSRC, 45))
ma050   = (f_ma(typeMA, MaSRC, 50))
ma055   = (f_ma(typeMA, MaSRC, 55))
ma060   = (f_ma(typeMA, MaSRC, 60))
ma065   = (f_ma(typeMA, MaSRC, 65))
ma070   = (f_ma(typeMA, MaSRC, 70))
ma075   = (f_ma(typeMA, MaSRC, 75))
ma080   = (f_ma(typeMA, MaSRC, 80))
ma085   = (f_ma(typeMA, MaSRC, 85))
ma090   = (f_ma(typeMA, MaSRC, 90))
ma095   = (f_ma(typeMA, MaSRC, 95))
ma100   = (f_ma(typeMA, MaSRC, 100))

// --- ENTRY CONDITIONS ---

string g_ENTRY = 'Entry Conditions'

trendSys(ma) =>
    var int trendDir = na

    if barstate.isconfirmed and close > ma and close > ma100
        trendDir := 1 
    else if barstate.isconfirmed and close[1] > ma[1] and close > ma and close < ma100
        trendDir := 0
    else if barstate.isconfirmed and close > ma and close < ma100
        trendDir := 0
    else if barstate.isconfirmed and close < ma and close < ma100
        trendDir := -1
    else if barstate.isconfirmed and close[1] < ma[1] and close < ma and close > ma100
        trendDir := 0
    else if barstate.isconfirmed and close < ma and close > ma100
        trendDir := 0
    else if barstate.isconfirmed
        trendDir := 0

bullTrend = trendSys(ma002) == 1 and
 trendSys(ma004) == 1 and 
 trendSys(ma006) == 1 and
 trendSys(ma008) == 1 and
 trendSys(ma010) == 1 and
 trendSys(ma014) == 1 and
 trendSys(ma018) == 1 and
 trendSys(ma020) == 1 and
 trendSys(ma022) == 1 and
 trendSys(ma024) == 1 and
 trendSys(ma026) == 1 and
 trendSys(ma028) == 1 and
 trendSys(ma030) == 1 and
 trendSys(ma033) == 1 and
 trendSys(ma036) == 1 and
 trendSys(ma038) == 1 and
 trendSys(ma040) == 1 and
 trendSys(ma043) == 1 and
 trendSys(ma045) == 1 and
 trendSys(ma050) == 1 and
 trendSys(ma055) == 1 and
 trendSys(ma060) == 1 and
 trendSys(ma065) == 1 and
 trendSys(ma070) == 1 and
 trendSys(ma075) == 1 and
 trendSys(ma075) == 1 and
 trendSys(ma080) == 1 and
 trendSys(ma085) == 1 and
 trendSys(ma090) == 1 and
 trendSys(ma095) == 1 and
 trendSys(ma100) == 1

bearTrend = trendSys(ma002) == -1 and
 trendSys(ma004) == -1 and 
 trendSys(ma006) == -1 and
 trendSys(ma008) == -1 and
 trendSys(ma010) == -1 and
 trendSys(ma014) == -1 and
 trendSys(ma018) == -1 and
 trendSys(ma020) == -1 and
 trendSys(ma022) == -1 and
 trendSys(ma024) == -1 and
 trendSys(ma026) == -1 and
 trendSys(ma028) == -1 and
 trendSys(ma030) == -1 and
 trendSys(ma033) == -1 and
 trendSys(ma036) == -1 and
 trendSys(ma038) == -1 and
 trendSys(ma040) == -1 and
 trendSys(ma043) == -1 and
 trendSys(ma045) == -1 and
 trendSys(ma050) == -1 and
 trendSys(ma055) == -1 and
 trendSys(ma060) == -1 and
 trendSys(ma065) == -1 and
 trendSys(ma070) == -1 and
 trendSys(ma075) == -1 and
 trendSys(ma075) == -1 and
 trendSys(ma080) == -1 and
 trendSys(ma085) == -1 and
 trendSys(ma090) == -1 and
 trendSys(ma095) == -1 and
 trendSys(ma100) == -1

// --- RIBBON COLOR FUNCTION ---

colorSys(ma) =>
    var color colorMA = na

    if barstate.isconfirmed and close > ma and close > ma100
        colorMA := color.rgb(0, 230, 118)
    else if barstate.isconfirmed and close[1] > ma[1] and close > ma and close < ma100
        colorMA := color.rgb(76, 175, 80)
    else if barstate.isconfirmed and close > ma and close < ma100
        colorMA := color.rgb(120, 123, 134)
    else if barstate.isconfirmed and close < ma and close < ma100
        colorMA := color.rgb(255, 82, 82)
    else if barstate.isconfirmed and close[1] < ma[1] and close < ma and close > ma100
        colorMA := color.rgb(136, 14, 79)
    else if barstate.isconfirmed and close < ma and close > ma100
        colorMA := color.rgb(120, 123, 134)
    else if barstate.isconfirmed
        colorMA := color.rgb(255, 255, 255)

// --- PLOTTING SECTION ---

var label bullLabel = na
var label bearLabel = na

if bullTrend[1] == false and bullTrend and showMarkers
    bullLabel := label.new(bar_index, low, text='L', tooltip='entry price : ' + str.tostring(close), color= color.rgb(0, 230, 118), style = label.style_label_up, textcolor= color.white, textalign =text.align_center, size=size.small)

if bearTrend[1] == false and bearTrend and showMarkers
    bearLabel := label.new(bar_index, high, text='S', tooltip='entry price : ' + str.tostring(close), color= color.rgb(255, 82, 82), style = label.style_label_down, textcolor= color.white, textalign =text.align_center, size=size.small)

plot01 = plot( showRibbon ? ma002 : na, title = 'MA2',   color = colorSys(ma002), linewidth = 1, display = displayMode )
plot02 = plot( showRibbon ? ma004 : na, title = 'MA4',   color = colorSys(ma004), linewidth = 1, display = displayMode )
plot03 = plot( showRibbon ? ma006 : na, title = 'MA6',   color = colorSys(ma006), linewidth = 1, display = displayMode )
plot04 = plot( showRibbon ? ma008 : na, title = 'MA8',   color = colorSys(ma008), linewidth = 1, display = display.pane )
plot05 = plot( showRibbon ? ma010 : na, title = 'MA10',  color = colorSys(ma010), linewidth = 1, display = displayMode )
plot06 = plot( showRibbon ? ma014 : na, title = 'MA14',  color = colorSys(ma014), linewidth = 1, display = display.pane )
plot07 = plot( showRibbon ? ma018 : na, title = 'MA18',  color = colorSys(ma018), linewidth = 1, display = displayMode )
plot08 = plot( showRibbon ? ma020 : na, title = 'MA20',  color = colorSys(ma020), linewidth = 1, display = displayMode )
plot09 = plot( showRibbon ? ma022 : na, title = 'MA22',  color = colorSys(ma022), linewidth = 1, display = displayMode )
plot10 = plot( showRibbon ? ma024 : na, title = 'MA24',  color = colorSys(ma024), linewidth = 1, display = displayMode )
plot11 = plot( showRibbon ? ma026 : na, title = 'MA26',  color = colorSys(ma026), linewidth = 1, display = displayMode )
plot12 = plot( showRibbon ? ma028 : na, title = 'MA28',  color = colorSys(ma028), linewidth = 1, display = displayMode )
plot13 = plot( showRibbon ? ma030 : na, title = 'MA30',  color = colorSys(ma030), linewidth = 1, display = displayMode )
plot14 = plot( showRibbon ? ma033 : na, title = 'MA33',  color = colorSys(ma033), linewidth = 1, display = display.pane )
plot15 = plot( showRibbon ? ma036 : na, title = 'MA36',  color = colorSys(ma036), linewidth = 1, display = displayMode )
plot16 = plot( showRibbon ? ma038 : na, title = 'MA38',  color = colorSys(ma038), linewidth = 1, display = displayMode )
plot17 = plot( showRibbon ? ma040 : na, title = 'MA40',  color = colorSys(ma040), linewidth = 1, display = displayMode )
plot18 = plot( showRibbon ? ma043 : na, title = 'MA43',  color = colorSys(ma043), linewidth = 1, display = displayMode )
plot19 = plot( showRibbon ? ma045 : na, title = 'MA45',  color = colorSys(ma045), linewidth = 1, display = displayMode )
plot20 = plot( showRibbon ? ma050 : na, title = 'MA50',  color = colorSys(ma050), linewidth = 1, display = displayMode )
plot21 = plot( showRibbon ? ma055 : na, title = 'MA55',  color = colorSys(ma055), linewidth = 1, display = displayMode )
plot22 = plot( showRibbon ? ma060 : na, title = 'MA60',  color = colorSys(ma060), linewidth = 1, display = displayMode )
plot23 = plot( showRibbon ? ma065 : na, title = 'MA65',  color = colorSys(ma065), linewidth = 1, display = displayMode )
plot24 = plot( showRibbon ? ma070 : na, title = 'MA70',  color = colorSys(ma070), linewidth = 1, display = displayMode )
plot25 = plot( showRibbon ? ma075 : na, title = 'MA75',  color = colorSys(ma075), linewidth = 1, display = displayMode )
plot26 = plot( showRibbon ? ma080 : na, title = 'MA80',  color = colorSys(ma080), linewidth = 1, display = displayMode )
plot27 = plot( showRibbon ? ma085 : na, title = 'MA85',  color = colorSys(ma085), linewidth = 1, display = display.pane )
plot28 = plot( showRibbon ? ma090 : na, title = 'MA90',  color = colorSys(ma090), linewidth = 1, display = displayMode )
plot29 = plot( showRibbon ? ma095 : na, title = 'MA95',  color = colorSys(ma095), linewidth = 1, display = display.pane )
plot30 = plot( showRibbon ? ma100 : na, title = 'MA100', color = colorSys(ma100), linewidth = 1, display = displayMode )

plot31 = plot( showVWAP ? vwapValue : na, title = "VWAP", color = color.rgb(41, 98, 255), linewidth = 2, display = display.pane )
````
