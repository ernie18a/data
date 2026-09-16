<!-- tradingview-pine-id: PUB;dd82ccd534df44e3b044d8af07daac9a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Average Index

Source: https://www.tradingview.com/script/qYmub49o/

## Description

Moving Average Index is an overlay indicator that manages up to ten moving averages at once and highlights their relationship to each other, rather than just displaying them side by side. It's built for anyone who wants to track several moving averages at the same time without the chart turning into a tangle of lines — for example to compare short- and long-term trends, or to keep multiple timeframes in view at once, and see at a glance how these averages relate to one another.

Each moving average can independently be calculated as SMA, EMA, WMA, VWMA, HMA, or RMA — standard formulas from TradingView's own library, with no custom modification.

**Moving Average** (present ten times, MA 1–MA 10, each instance identically structured)

- Length: number of bars the average is calculated over.
- Type: calculation method: SMA, EMA, WMA, VWMA, HMA, or RMA.
- Source: the price or value the calculation is based on (e.g. close).
- Timeframe: a separate timeframe for this average; left empty, it uses the chart's timeframe. On a higher timeframe, the value updates within that timeframe's still-forming bar and can shift slightly until that bar closes.
- Line style: Line, Stepline, or Circles.
- Line width: thickness of the plotted line.
- Color: color of the line.

https://de.tradingview.com/x/WlYbkShv/

**Fill** (present three times, Fill 1–Fill 3, each instance identically structured)

- Connect: the two moving averages the area is drawn between.
- Bull / Bear: two colors: one for when the first selected average is above the second, the other for the opposite case.

https://de.tradingview.com/x/wT1hwbvj/

Each enabled moving average is plotted as its own line, in the chosen style, width, and color. Up to three areas can also be shown between any two of these averages: their color switches automatically whenever the order of the two connected averages changes — one color while the first one is above, the other once it drops below. Once such an area is active, the indicator hides the two lines it connects; only the colored area remains visible, making trend changes stand out more clearly than with two crossing lines.

https://de.tradingview.com/x/hnCo2ZQs/
https://de.tradingview.com/x/lhjIfv3L/

This indicator is intended solely for market analysis and does not constitute investment advice or a guarantee of success. Use it at your own discretion and risk; past results are not indicative of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © graefe

//@version=6
indicator(title = "Moving Average Index", overlay = true, behind_chart = false)

/////-----CONSTANTS-----/////

// Group names for the settings panel
const string con_grpMa   = "Moving Average"
const string con_grpFill = "Fill"

// Tooltips defined once as constants so they stay identical across all 10 MAs / 3 fills
const string con_maTooltip     = "Length and type of this moving average."
const string con_sourceTooltip = "Source and timeframe.\nLeave the timeframe empty to use the chart timeframe."
const string con_styleTooltip  = "Line style, width and color."
const string con_fillTooltip   = "The fill is only drawn when both selected moving averages are enabled and are not the same one."
const string con_colorTooltip  = "Left: primary above secondary.\nRight: primary below secondary.\nMoving averages that border a drawn fill are hidden, so only the fill stays visible."

/////-----FUNCTIONS-----/////

// Calculates the selected moving average type for a given source/length
f_movingAverage(maType, source, length) =>
    switch maType
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "WMA"  => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        "HMA"  => ta.hma(source, length)
        "RMA"  => ta.rma(source, length)
        =>        na

// Translates the selected line style into the matching plot() style constant
f_plotStyle(lineStyle) =>
    switch lineStyle
        "Stepline" => plot.style_stepline
        "Circles"  => plot.style_circles
        =>            plot.style_line

// Checks by ID ("MA 1" etc.) whether this specific MA is enabled
f_isMaEnabled(maId, showMa1, showMa2, showMa3, showMa4, showMa5, showMa6, showMa7, showMa8, showMa9, showMa10) =>
    bool result =
         maId == "MA 1"  ? showMa1  :
         maId == "MA 2"  ? showMa2  :
         maId == "MA 3"  ? showMa3  :
         maId == "MA 4"  ? showMa4  :
         maId == "MA 5"  ? showMa5  :
         maId == "MA 6"  ? showMa6  :
         maId == "MA 7"  ? showMa7  :
         maId == "MA 8"  ? showMa8  :
         maId == "MA 9"  ? showMa9  :
         maId == "MA 10" ? showMa10 :
         false
    result

// Returns the current value of the MA with the given ID
f_maValue(maId, ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma8, ma9, ma10) =>
    float result =
         maId == "MA 1"  ? ma1  :
         maId == "MA 2"  ? ma2  :
         maId == "MA 3"  ? ma3  :
         maId == "MA 4"  ? ma4  :
         maId == "MA 5"  ? ma5  :
         maId == "MA 6"  ? ma6  :
         maId == "MA 7"  ? ma7  :
         maId == "MA 8"  ? ma8  :
         maId == "MA 9"  ? ma9  :
         maId == "MA 10" ? ma10 :
         na
    result

// A fill is only drawn when it is enabled, both connected MAs are on, and it doesn't connect an MA to itself
f_isFillDrawn(showFill, primaryId, secondaryId, showMa1, showMa2, showMa3, showMa4, showMa5, showMa6, showMa7, showMa8, showMa9, showMa10) =>
    bool isPrimaryOn   = f_isMaEnabled(primaryId,   showMa1, showMa2, showMa3, showMa4, showMa5, showMa6, showMa7, showMa8, showMa9, showMa10)
    bool isSecondaryOn = f_isMaEnabled(secondaryId, showMa1, showMa2, showMa3, showMa4, showMa5, showMa6, showMa7, showMa8, showMa9, showMa10)
    bool result = showFill and primaryId != secondaryId and isPrimaryOn and isSecondaryOn
    result

// Hides an MA's line (na) as soon as it borders an active fill
f_maLineColor(maId, maColor, isFill1Drawn, primaryId1, secondaryId1, isFill2Drawn, primaryId2, secondaryId2, isFill3Drawn, primaryId3, secondaryId3) =>
    bool isBorder1 = isFill1Drawn and (primaryId1 == maId or secondaryId1 == maId)
    bool isBorder2 = isFill2Drawn and (primaryId2 == maId or secondaryId2 == maId)
    bool isBorder3 = isFill3Drawn and (primaryId3 == maId or secondaryId3 == maId)
    color result = isBorder1 or isBorder2 or isBorder3 ? color(na) : maColor
    result

/////-----INPUTS-----/////

// The following ten blocks are identically structured for MA 1-MA 10:
// visibility, length, type, source, timeframe, line style, width, color
bool   inp_showMa1     = input.bool(defval = true, title = "MA 1", group = con_grpMa)
int    inp_length1     = input.int(defval = 21, title = "", minval = 1, maxval = 5000, inline = "ma1_calc", group = con_grpMa, active = inp_showMa1)
string inp_maType1     = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma1_calc", group = con_grpMa, active = inp_showMa1, tooltip = con_maTooltip)
float  inp_source1     = input.source(defval = close, title = "", inline = "ma1_source", group = con_grpMa, active = inp_showMa1)
string inp_timeframe1  = input.timeframe(defval = "", title = "", inline = "ma1_source", group = con_grpMa, active = inp_showMa1, tooltip = con_sourceTooltip)
string inp_lineStyle1  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma1_style", group = con_grpMa, active = inp_showMa1)
int    inp_lineWidth1  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma1_style", group = con_grpMa, active = inp_showMa1)
color  inp_lineColor1  = input.color(defval = color.new(color.gray, 0), title = "", inline = "ma1_style", group = con_grpMa, active = inp_showMa1, tooltip = con_styleTooltip)

bool   inp_showMa2     = input.bool(defval = true, title = "MA 2", group = con_grpMa)
int    inp_length2     = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "ma2_calc", group = con_grpMa, active = inp_showMa2)
string inp_maType2     = input.string(defval = "EMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma2_calc", group = con_grpMa, active = inp_showMa2, tooltip = con_maTooltip)
float  inp_source2     = input.source(defval = close, title = "", inline = "ma2_source", group = con_grpMa, active = inp_showMa2)
string inp_timeframe2  = input.timeframe(defval = "", title = "", inline = "ma2_source", group = con_grpMa, active = inp_showMa2, tooltip = con_sourceTooltip)
string inp_lineStyle2  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma2_style", group = con_grpMa, active = inp_showMa2)
int    inp_lineWidth2  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma2_style", group = con_grpMa, active = inp_showMa2)
color  inp_lineColor2  = input.color(defval = color.new(color.orange, 0), title = "", inline = "ma2_style", group = con_grpMa, active = inp_showMa2, tooltip = con_styleTooltip)

bool   inp_showMa3     = input.bool(defval = false, title = "MA 3", group = con_grpMa)
int    inp_length3     = input.int(defval = 100, title = "", minval = 1, maxval = 5000, inline = "ma3_calc", group = con_grpMa, active = inp_showMa3)
string inp_maType3     = input.string(defval = "WMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma3_calc", group = con_grpMa, active = inp_showMa3, tooltip = con_maTooltip)
float  inp_source3     = input.source(defval = close, title = "", inline = "ma3_source", group = con_grpMa, active = inp_showMa3)
string inp_timeframe3  = input.timeframe(defval = "", title = "", inline = "ma3_source", group = con_grpMa, active = inp_showMa3, tooltip = con_sourceTooltip)
string inp_lineStyle3  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma3_style", group = con_grpMa, active = inp_showMa3)
int    inp_lineWidth3  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma3_style", group = con_grpMa, active = inp_showMa3)
color  inp_lineColor3  = input.color(defval = color.new(color.yellow, 0), title = "", inline = "ma3_style", group = con_grpMa, active = inp_showMa3, tooltip = con_styleTooltip)

bool   inp_showMa4     = input.bool(defval = false, title = "MA 4", group = con_grpMa)
int    inp_length4     = input.int(defval = 100, title = "", minval = 1, maxval = 5000, inline = "ma4_calc", group = con_grpMa, active = inp_showMa4)
string inp_maType4     = input.string(defval = "VWMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma4_calc", group = con_grpMa, active = inp_showMa4, tooltip = con_maTooltip)
float  inp_source4     = input.source(defval = close, title = "", inline = "ma4_source", group = con_grpMa, active = inp_showMa4)
string inp_timeframe4  = input.timeframe(defval = "", title = "", inline = "ma4_source", group = con_grpMa, active = inp_showMa4, tooltip = con_sourceTooltip)
string inp_lineStyle4  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma4_style", group = con_grpMa, active = inp_showMa4)
int    inp_lineWidth4  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma4_style", group = con_grpMa, active = inp_showMa4)
color  inp_lineColor4  = input.color(defval = color.new(color.red, 0), title = "", inline = "ma4_style", group = con_grpMa, active = inp_showMa4, tooltip = con_styleTooltip)

bool   inp_showMa5     = input.bool(defval = false, title = "MA 5", group = con_grpMa)
int    inp_length5     = input.int(defval = 9, title = "", minval = 1, maxval = 5000, inline = "ma5_calc", group = con_grpMa, active = inp_showMa5)
string inp_maType5     = input.string(defval = "HMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma5_calc", group = con_grpMa, active = inp_showMa5, tooltip = con_maTooltip)
float  inp_source5     = input.source(defval = close, title = "", inline = "ma5_source", group = con_grpMa, active = inp_showMa5)
string inp_timeframe5  = input.timeframe(defval = "", title = "", inline = "ma5_source", group = con_grpMa, active = inp_showMa5, tooltip = con_sourceTooltip)
string inp_lineStyle5  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma5_style", group = con_grpMa, active = inp_showMa5)
int    inp_lineWidth5  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma5_style", group = con_grpMa, active = inp_showMa5)
color  inp_lineColor5  = input.color(defval = color.new(color.blue, 0), title = "", inline = "ma5_style", group = con_grpMa, active = inp_showMa5, tooltip = con_styleTooltip)

bool   inp_showMa6     = input.bool(defval = false, title = "MA 6", group = con_grpMa)
int    inp_length6     = input.int(defval = 21, title = "", minval = 1, maxval = 5000, inline = "ma6_calc", group = con_grpMa, active = inp_showMa6)
string inp_maType6     = input.string(defval = "SMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma6_calc", group = con_grpMa, active = inp_showMa6, tooltip = con_maTooltip)
float  inp_source6     = input.source(defval = close, title = "", inline = "ma6_source", group = con_grpMa, active = inp_showMa6)
string inp_timeframe6  = input.timeframe(defval = "", title = "", inline = "ma6_source", group = con_grpMa, active = inp_showMa6, tooltip = con_sourceTooltip)
string inp_lineStyle6  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma6_style", group = con_grpMa, active = inp_showMa6)
int    inp_lineWidth6  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma6_style", group = con_grpMa, active = inp_showMa6)
color  inp_lineColor6  = input.color(defval = color.new(#f7c9ff, 0), title = "", inline = "ma6_style", group = con_grpMa, active = inp_showMa6, tooltip = con_styleTooltip)

bool   inp_showMa7     = input.bool(defval = false, title = "MA 7", group = con_grpMa)
int    inp_length7     = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "ma7_calc", group = con_grpMa, active = inp_showMa7)
string inp_maType7     = input.string(defval = "SMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma7_calc", group = con_grpMa, active = inp_showMa7, tooltip = con_maTooltip)
float  inp_source7     = input.source(defval = close, title = "", inline = "ma7_source", group = con_grpMa, active = inp_showMa7)
string inp_timeframe7  = input.timeframe(defval = "", title = "", inline = "ma7_source", group = con_grpMa, active = inp_showMa7, tooltip = con_sourceTooltip)
string inp_lineStyle7  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma7_style", group = con_grpMa, active = inp_showMa7)
int    inp_lineWidth7  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma7_style", group = con_grpMa, active = inp_showMa7)
color  inp_lineColor7  = input.color(defval = color.new(#eb7aff, 0), title = "", inline = "ma7_style", group = con_grpMa, active = inp_showMa7, tooltip = con_styleTooltip)

bool   inp_showMa8     = input.bool(defval = false, title = "MA 8", group = con_grpMa)
int    inp_length8     = input.int(defval = 200, title = "", minval = 1, maxval = 5000, inline = "ma8_calc", group = con_grpMa, active = inp_showMa8)
string inp_maType8     = input.string(defval = "HMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma8_calc", group = con_grpMa, active = inp_showMa8, tooltip = con_maTooltip)
float  inp_source8     = input.source(defval = close, title = "", inline = "ma8_source", group = con_grpMa, active = inp_showMa8)
string inp_timeframe8  = input.timeframe(defval = "", title = "", inline = "ma8_source", group = con_grpMa, active = inp_showMa8, tooltip = con_sourceTooltip)
string inp_lineStyle8  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma8_style", group = con_grpMa, active = inp_showMa8)
int    inp_lineWidth8  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma8_style", group = con_grpMa, active = inp_showMa8)
color  inp_lineColor8  = input.color(defval = color.new(#e030ff, 0), title = "", inline = "ma8_style", group = con_grpMa, active = inp_showMa8, tooltip = con_styleTooltip)

bool   inp_showMa9     = input.bool(defval = false, title = "MA 9", group = con_grpMa)
int    inp_length9     = input.int(defval = 21, title = "", minval = 1, maxval = 5000, inline = "ma9_calc", group = con_grpMa, active = inp_showMa9)
string inp_maType9     = input.string(defval = "RMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma9_calc", group = con_grpMa, active = inp_showMa9, tooltip = con_maTooltip)
float  inp_source9     = input.source(defval = close, title = "", inline = "ma9_source", group = con_grpMa, active = inp_showMa9)
string inp_timeframe9  = input.timeframe(defval = "", title = "", inline = "ma9_source", group = con_grpMa, active = inp_showMa9, tooltip = con_sourceTooltip)
string inp_lineStyle9  = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma9_style", group = con_grpMa, active = inp_showMa9)
int    inp_lineWidth9  = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma9_style", group = con_grpMa, active = inp_showMa9)
color  inp_lineColor9  = input.color(defval = color.new(#49e04e, 0), title = "", inline = "ma9_style", group = con_grpMa, active = inp_showMa9, tooltip = con_styleTooltip)

bool   inp_showMa10    = input.bool(defval = false, title = "MA 10", group = con_grpMa)
int    inp_length10    = input.int(defval = 50, title = "", minval = 1, maxval = 5000, inline = "ma10_calc", group = con_grpMa, active = inp_showMa10)
string inp_maType10    = input.string(defval = "RMA", title = "", options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "RMA"], inline = "ma10_calc", group = con_grpMa, active = inp_showMa10, tooltip = con_maTooltip)
float  inp_source10    = input.source(defval = close, title = "", inline = "ma10_source", group = con_grpMa, active = inp_showMa10)
string inp_timeframe10 = input.timeframe(defval = "", title = "", inline = "ma10_source", group = con_grpMa, active = inp_showMa10, tooltip = con_sourceTooltip)
string inp_lineStyle10 = input.string(defval = "Line", title = "", options = ["Line", "Stepline", "Circles"], inline = "ma10_style", group = con_grpMa, active = inp_showMa10)
int    inp_lineWidth10 = input.int(defval = 1, title = "", minval = 1, maxval = 5, inline = "ma10_style", group = con_grpMa, active = inp_showMa10)
color  inp_lineColor10 = input.color(defval = color.new(#1e6921, 0), title = "", inline = "ma10_style", group = con_grpMa, active = inp_showMa10, tooltip = con_styleTooltip)

// The following three blocks are identically structured for Fill 1-Fill 3:
// visibility, connected MAs, bull/bear color
bool   inp_showFill1      = input.bool(defval = true, title = "Fill 1", group = con_grpFill)
string inp_fillPrimary1   = input.string(defval = "MA 1", title = "Connect", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill1_ma", group = con_grpFill, active = inp_showFill1)
string inp_fillSecondary1 = input.string(defval = "MA 2", title = "", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill1_ma", group = con_grpFill, active = inp_showFill1, tooltip = con_fillTooltip)
color  inp_fillBullColor1 = input.color(defval = color.new(color.green, 60), title = "Bull / Bear", inline = "fill1_color", group = con_grpFill, active = inp_showFill1)
color  inp_fillBearColor1 = input.color(defval = color.new(color.red, 60), title = "", inline = "fill1_color", group = con_grpFill, active = inp_showFill1, tooltip = con_colorTooltip)

bool   inp_showFill2      = input.bool(defval = false, title = "Fill 2", group = con_grpFill)
string inp_fillPrimary2   = input.string(defval = "MA 5", title = "Connect", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill2_ma", group = con_grpFill, active = inp_showFill2)
string inp_fillSecondary2 = input.string(defval = "MA 6", title = "", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill2_ma", group = con_grpFill, active = inp_showFill2, tooltip = con_fillTooltip)
color  inp_fillBullColor2 = input.color(defval = color.new(color.blue, 60), title = "Bull / Bear", inline = "fill2_color", group = con_grpFill, active = inp_showFill2)
color  inp_fillBearColor2 = input.color(defval = color.new(color.navy, 60), title = "", inline = "fill2_color", group = con_grpFill, active = inp_showFill2, tooltip = con_colorTooltip)

bool   inp_showFill3      = input.bool(defval = false, title = "Fill 3", group = con_grpFill)
string inp_fillPrimary3   = input.string(defval = "MA 9", title = "Connect", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill3_ma", group = con_grpFill, active = inp_showFill3)
string inp_fillSecondary3 = input.string(defval = "MA 10", title = "", options = ["MA 1", "MA 2", "MA 3", "MA 4", "MA 5", "MA 6", "MA 7", "MA 8", "MA 9", "MA 10"], inline = "fill3_ma", group = con_grpFill, active = inp_showFill3, tooltip = con_fillTooltip)
color  inp_fillBullColor3 = input.color(defval = color.new(color.fuchsia, 60), title = "Bull / Bear", inline = "fill3_color", group = con_grpFill, active = inp_showFill3)
color  inp_fillBearColor3 = input.color(defval = color.new(color.maroon, 60), title = "", inline = "fill3_color", group = con_grpFill, active = inp_showFill3, tooltip = con_colorTooltip)

/////-----CALCULATION-----/////

// Checks for each of the three fills whether it is currently actually being drawn
bool cal_isFill1Drawn = f_isFillDrawn(showFill = inp_showFill1, primaryId = inp_fillPrimary1, secondaryId = inp_fillSecondary1, showMa1 = inp_showMa1, showMa2 = inp_showMa2, showMa3 = inp_showMa3, showMa4 = inp_showMa4, showMa5 = inp_showMa5, showMa6 = inp_showMa6, showMa7 = inp_showMa7, showMa8 = inp_showMa8, showMa9 = inp_showMa9, showMa10 = inp_showMa10)
bool cal_isFill2Drawn = f_isFillDrawn(showFill = inp_showFill2, primaryId = inp_fillPrimary2, secondaryId = inp_fillSecondary2, showMa1 = inp_showMa1, showMa2 = inp_showMa2, showMa3 = inp_showMa3, showMa4 = inp_showMa4, showMa5 = inp_showMa5, showMa6 = inp_showMa6, showMa7 = inp_showMa7, showMa8 = inp_showMa8, showMa9 = inp_showMa9, showMa10 = inp_showMa10)
bool cal_isFill3Drawn = f_isFillDrawn(showFill = inp_showFill3, primaryId = inp_fillPrimary3, secondaryId = inp_fillSecondary3, showMa1 = inp_showMa1, showMa2 = inp_showMa2, showMa3 = inp_showMa3, showMa4 = inp_showMa4, showMa5 = inp_showMa5, showMa6 = inp_showMa6, showMa7 = inp_showMa7, showMa8 = inp_showMa8, showMa9 = inp_showMa9, showMa10 = inp_showMa10)

// Hides each MA's line as soon as it borders one of the three active fills
color cal_lineColor1  = f_maLineColor(maId = "MA 1",  maColor = inp_lineColor1,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor2  = f_maLineColor(maId = "MA 2",  maColor = inp_lineColor2,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor3  = f_maLineColor(maId = "MA 3",  maColor = inp_lineColor3,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor4  = f_maLineColor(maId = "MA 4",  maColor = inp_lineColor4,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor5  = f_maLineColor(maId = "MA 5",  maColor = inp_lineColor5,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor6  = f_maLineColor(maId = "MA 6",  maColor = inp_lineColor6,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor7  = f_maLineColor(maId = "MA 7",  maColor = inp_lineColor7,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor8  = f_maLineColor(maId = "MA 8",  maColor = inp_lineColor8,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor9  = f_maLineColor(maId = "MA 9",  maColor = inp_lineColor9,  isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)
color cal_lineColor10 = f_maLineColor(maId = "MA 10", maColor = inp_lineColor10, isFill1Drawn = cal_isFill1Drawn, primaryId1 = inp_fillPrimary1, secondaryId1 = inp_fillSecondary1, isFill2Drawn = cal_isFill2Drawn, primaryId2 = inp_fillPrimary2, secondaryId2 = inp_fillSecondary2, isFill3Drawn = cal_isFill3Drawn, primaryId3 = inp_fillPrimary3, secondaryId3 = inp_fillSecondary3)

// Calculates the value of each enabled MA, optionally on its own timeframe
float cal_ma1  = inp_showMa1  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe1,  expression = f_movingAverage(maType = inp_maType1,  source = inp_source1,  length = inp_length1))  : na
float cal_ma2  = inp_showMa2  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe2,  expression = f_movingAverage(maType = inp_maType2,  source = inp_source2,  length = inp_length2))  : na
float cal_ma3  = inp_showMa3  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe3,  expression = f_movingAverage(maType = inp_maType3,  source = inp_source3,  length = inp_length3))  : na
float cal_ma4  = inp_showMa4  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe4,  expression = f_movingAverage(maType = inp_maType4,  source = inp_source4,  length = inp_length4))  : na
float cal_ma5  = inp_showMa5  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe5,  expression = f_movingAverage(maType = inp_maType5,  source = inp_source5,  length = inp_length5))  : na
float cal_ma6  = inp_showMa6  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe6,  expression = f_movingAverage(maType = inp_maType6,  source = inp_source6,  length = inp_length6))  : na
float cal_ma7  = inp_showMa7  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe7,  expression = f_movingAverage(maType = inp_maType7,  source = inp_source7,  length = inp_length7))  : na
float cal_ma8  = inp_showMa8  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe8,  expression = f_movingAverage(maType = inp_maType8,  source = inp_source8,  length = inp_length8))  : na
float cal_ma9  = inp_showMa9  ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe9,  expression = f_movingAverage(maType = inp_maType9,  source = inp_source9,  length = inp_length9))  : na
float cal_ma10 = inp_showMa10 ? request.security(symbol = syminfo.tickerid, timeframe = inp_timeframe10, expression = f_movingAverage(maType = inp_maType10, source = inp_source10, length = inp_length10)) : na

// Resolves the two connected MA values for each fill based on their selected ID
float cal_fill1Primary   = f_maValue(maId = inp_fillPrimary1,   ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)
float cal_fill1Secondary = f_maValue(maId = inp_fillSecondary1, ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)
float cal_fill2Primary   = f_maValue(maId = inp_fillPrimary2,   ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)
float cal_fill2Secondary = f_maValue(maId = inp_fillSecondary2, ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)
float cal_fill3Primary   = f_maValue(maId = inp_fillPrimary3,   ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)
float cal_fill3Secondary = f_maValue(maId = inp_fillSecondary3, ma1 = cal_ma1, ma2 = cal_ma2, ma3 = cal_ma3, ma4 = cal_ma4, ma5 = cal_ma5, ma6 = cal_ma6, ma7 = cal_ma7, ma8 = cal_ma8, ma9 = cal_ma9, ma10 = cal_ma10)

// Bull color when the first connected value is higher, otherwise bear color
color cal_fill1Color = cal_fill1Primary > cal_fill1Secondary ? inp_fillBullColor1 : inp_fillBearColor1
color cal_fill2Color = cal_fill2Primary > cal_fill2Secondary ? inp_fillBullColor2 : inp_fillBearColor2
color cal_fill3Color = cal_fill3Primary > cal_fill3Secondary ? inp_fillBullColor3 : inp_fillBearColor3

/////-----OUTPUT-----/////

// Plots each enabled MA as a line
plot(series = cal_ma1,  style = f_plotStyle(inp_lineStyle1), title = "MA 1",  color = cal_lineColor1,  linewidth = inp_lineWidth1,  editable = false)
plot(series = cal_ma2,  style = f_plotStyle(inp_lineStyle2), title = "MA 2",  color = cal_lineColor2,  linewidth = inp_lineWidth2,  editable = false)
plot(series = cal_ma3,  style = f_plotStyle(inp_lineStyle3), title = "MA 3",  color = cal_lineColor3,  linewidth = inp_lineWidth3,  editable = false)
plot(series = cal_ma4,  style = f_plotStyle(inp_lineStyle4), title = "MA 4",  color = cal_lineColor4,  linewidth = inp_lineWidth4,  editable = false)
plot(series = cal_ma5,  style = f_plotStyle(inp_lineStyle5), title = "MA 5",  color = cal_lineColor5,  linewidth = inp_lineWidth5,  editable = false)
plot(series = cal_ma6,  style = f_plotStyle(inp_lineStyle6), title = "MA 6",  color = cal_lineColor6,  linewidth = inp_lineWidth6,  editable = false)
plot(series = cal_ma7,  style = f_plotStyle(inp_lineStyle7), title = "MA 7",  color = cal_lineColor7,  linewidth = inp_lineWidth7,  editable = false)
plot(series = cal_ma8,  style = f_plotStyle(inp_lineStyle8), title = "MA 8",  color = cal_lineColor8,  linewidth = inp_lineWidth8,  editable = false)
plot(series = cal_ma9,  style = f_plotStyle(inp_lineStyle9), title = "MA 9",  color = cal_lineColor9,  linewidth = inp_lineWidth9,  editable = false)
plot(series = cal_ma10, style = f_plotStyle(inp_lineStyle10), title = "MA 10", color = cal_lineColor10, linewidth = inp_lineWidth10, editable = false)

// Two invisible helper plots mark the fill boundaries; fill() creates the actual area between them
outp_fill1Primary   = plot(series = cal_isFill1Drawn ? cal_fill1Primary   : na, title = "Fill 1 Primary Anchor",   color = na, editable = false)
outp_fill1Secondary = plot(series = cal_isFill1Drawn ? cal_fill1Secondary : na, title = "Fill 1 Secondary Anchor", color = na, editable = false)
fill(plot1 = outp_fill1Primary, plot2 = outp_fill1Secondary, title = "Fill 1", color = cal_fill1Color, editable = false)

outp_fill2Primary   = plot(series = cal_isFill2Drawn ? cal_fill2Primary   : na, title = "Fill 2 Primary Anchor",   color = na, editable = false)
outp_fill2Secondary = plot(series = cal_isFill2Drawn ? cal_fill2Secondary : na, title = "Fill 2 Secondary Anchor", color = na, editable = false)
fill(plot1 = outp_fill2Primary, plot2 = outp_fill2Secondary, title = "Fill 2", color = cal_fill2Color, editable = false)

outp_fill3Primary   = plot(series = cal_isFill3Drawn ? cal_fill3Primary   : na, title = "Fill 3 Primary Anchor",   color = na, editable = false)
outp_fill3Secondary = plot(series = cal_isFill3Drawn ? cal_fill3Secondary : na, title = "Fill 3 Secondary Anchor", color = na, editable = false)
fill(plot1 = outp_fill3Primary, plot2 = outp_fill3Secondary, title = "Fill 3", color = cal_fill3Color, editable = false)
````
