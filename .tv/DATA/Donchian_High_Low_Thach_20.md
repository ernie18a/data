<!-- tradingview-pine-id: PUB;49fff6b2bc044bdaa305b4c083052091 -->
<!-- tradingviewscripts-format: 1 -->
# Donchian High Low Thach 2.0

Source: https://www.tradingview.com/script/j9IlQRr8/

## Description

Chỉ báo báo gồm:
- Đường cân bằng trong 65 phiên biểu thị bằng đường màu cam
công thức tính: (cao nhất 65 phiên + thấp nhất 65 phiên)/2

- Đường cân bằng 129 phiên biểu thị bằng đường màu tím. 
công thức tính: (cao nhất 129 phiên + thấp nhất 129 phiên)/2

- 2 đường màu cam và màu tím cho ta biết trung bình của 65 phiên và 129 phiên, giúp ta nhận biết hiện tại giá đang thấp hay quá cao so với 3 tháng hoặc nữa năm.
========================
- Kênh Donchian cho ta biết đỉnh và đáy của 20 phiên
========================
- Đường trễ cho ta biết giá hiện tại đang cao hay thấp hơn 20 phiên trước, giúp ta xác nhận xu hướng Tăng, giảm, hoặc đi ngang.

---

## Source Code

````pine
//@version=6
indicator(title="Donchian High Low Thach 2.0", shorttitle="H/L Thach", overlay=true, max_lines_count=10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DONCHIAN CHANNELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

length = input.int(20, minval=1, title="Donchian Length")
offset = input.int(0, "Offset")

lower = ta.lowest(length)
upper = ta.highest(length)
basis = math.avg(upper, lower)

plot(basis, "Basis", color=color.rgb(242, 54, 69, 50), offset=offset)

u = plot(upper, "Upper", color=color.rgb(41, 98, 255, 60), offset=offset)
l = plot(lower, "Lower", color=color.rgb(41, 98, 255, 60), offset=offset)

fill(u, l, color=color.rgb(33, 150, 243, 95), title="Background")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CÁC MỐC NẾN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int candle199 = 199
int candle128 = 128
int candle64 = 64
int candle25 = 25
int candle16 = 16
int candle8 = 8

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MÀU SẮC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

color color199 = input.color(color.rgb(76, 175, 80, 80), "Màu nến 200")
color color128 = input.color(color.rgb(156, 39, 176, 80), "Màu nến 129")
color color64 = input.color(color.rgb(245, 124, 0, 80), "Màu nến 65")
color color25 = input.color(color.rgb(128, 128, 128, 80), "Màu nến 26")
color color16 = input.color(color.rgb(242, 54, 69, 80), "Màu nến 17")
color color8 = input.color(color.rgb(41, 98, 255, 80), "Màu nến 9")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// XÁC ĐỊNH VỊ TRÍ CÁC NẾN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool is199 = bar_index == last_bar_index - candle199
bool is128 = bar_index == last_bar_index - candle128
bool is64 = bar_index == last_bar_index - candle64
bool is25 = bar_index == last_bar_index - candle25
bool is16 = bar_index == last_bar_index - candle16
bool is8 = bar_index == last_bar_index - candle8

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ICHIMOKU - CÁC ĐƯỜNG CƠ BẢN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

conversionPeriods = input.int(65, minval=1, title="Conversion Line Length")
basePeriods = input.int(129, minval=1, title="Base Line Length")
displacement = input.int(26, minval=1, title="Lagging Span")

donchian(len) =>math.avg(ta.lowest(len), ta.highest(len))

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)
leadLine1 = math.avg(conversionLine, baseLine)

plot(conversionLine, color=color.rgb(245, 124, 0), title="Conversion Line")
plot(baseLine, color=#9c27b0, title="Base Line")
plot(close, offset=-displacement + 1, color=color.rgb(76, 175, 80, 30), title="Lagging Span")
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VẼ ĐƯỜNG THẲNG ĐỨNG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if is199
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color199, width=3)

if is128
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color128, width=3)

if is64
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color64, width=3)

if is25
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color25, width=3)

if is16
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color16, width=3)

if is8
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=color8, width=3)

// Tooltips
string TT_AT = "If selected, the indicator automatically chooses the timeframe of the displayed bars. The chosen higher"
 + " timeframe is:\n\n"
 + " • '2 hours' if the chart timeframe is a seconds-based timeframe.\n"
 + " • '1 day' if the chart timeframe is lower than one day and not a seconds-based timeframe.\n"
 + " • '1 week' if the chart timeframe is higher than one day and lower than one week.\n"
 + " • '1 month' if the chart timeframe is higher than one week and lower than one month.\n"
 + " • '3 months' if the chart timeframe is higher than one month and lower than three months.\n"
 + " • '12 months' if the chart timeframe is higher than three months."
 + " \n\nIf not selected, it uses the timeframe specified in the 'Timeframe' input."
    
string TT_UC = "When this option is unchecked, MTPC will use intraday data while calculating on intraday charts."
 + " If Extended Hours are displayed on the chart, they will be taken into account during the calculation."
 + " If intraday OHLC values are different from daily-based values (normal for stocks), the MTPC will also differ."

// Color constants
color UP_COLOR   = color.rgb(0, 150, 136, 80)
color DN_COLOR   = color.rgb(244, 67, 54, 80)
color UPBD_COLOR = color.new(UP_COLOR, 90)
color DNBD_COLOR = color.new(DN_COLOR, 90)

//@enum An enumeration of named values representing display modes.
enum CalcType
    hl   = "High/Low Range"
    oc   = "Open/Close Range"
    ohlc = "OHLC"
    tr   = "True Range"

// Inputs
bool     autoTFInput        = input(true,             "Auto-timeframe", tooltip = TT_AT)
string   tfInput            = input.timeframe("1M",   "Timeframe", active = not autoTFInput)
CalcType calcTypeInput      = input.enum(CalcType.hl, "Calculation")
bool     useHaInput         = input.bool(false,       "Display Heikin Ashi values")
bool     useDailyInput      = input.bool(false,       "Use daily-based values", tooltip = TT_UC)

string   GRP01              = "Border and fill colors"
color    upBorderColorInput = input(UP_COLOR,       "Up bars  ", inline = "10", group = GRP01)
color    upBodyColorInput   = input(UPBD_COLOR,         "",      inline = "10", group = GRP01)
color    dnBorderColorInput = input(DN_COLOR,       "Down bars", inline = "11", group = GRP01)
color    dnBodyColorInput   = input(DNBD_COLOR,         "",      inline = "11", group = GRP01)

// @type A custom type for storing HTF bar information.
type OHLC
    float o
    float h
    float l
    float c
    float prevC

// @function Sets the position and colors of a box based on direction, or hides the box if `cond` is `true`. 
method setBox(box bx, cond, left, right, top, bottom, diff, upBodyColor, dnBodyColor, upBorderColor, dnBorderColor) =>
    color bodyColor   = diff < 0 ? dnBodyColor   : upBodyColor
    color borderColor = diff < 0 ? dnBorderColor : upBorderColor
    switch 
        cond => bx.set_bgcolor(na), bx.set_border_color(na)
        => 
            bx.set_left(left), bx.set_right(right)
            bx.set_top(top),   bx.set_bottom(bottom)
            bx.set_bgcolor(bodyColor), bx.set_border_color(borderColor)

// @function Returns a default higher-timeframe string based on the current chart's timeframe. 
selectAutoTimeframe() =>
    int secondsInTF = timeframe.in_seconds()
    string result = switch
        timeframe.isseconds   => "120"
        secondsInTF < 86400   => "1440"
        secondsInTF < 604800  => "1W"
        secondsInTF < 2628003 => "1M"
        secondsInTF < 7884009 => "3M"
        => "12M"

// @function Returns an adjusted timeframe, converting "1D" to "1440" during extended sessions.
selectTimeframeFromInput(tf) =>
    syminfo.session == session.extended and tf == "1D" ? "1440" : tf 

// @function Creates an `OHLC` object containing past bar prices.
makeOHLC(offset = 0) =>
    OHLC.new(open[offset], high[offset], low[offset], close[offset], close[offset + 1])

// @function Calculate Heikin Ashi values from standard OHLC values and previous HA open and close values. 
haFrom(o, h, l, c, prevHO, prevHC) =>
    float haC = (o + h + l + c) / 4
    float haO = na(prevHO) or na(prevHC) ? (o + c) / 2 : (prevHO + prevHC) / 2
    float haH = math.max(h, haO, haC)
    float haL = math.min(l, haO, haC)
    [haO, haH, haL, haC]

// @function Creates an `OHLC` object containing HTF values based on chart prices, with optional Heikin Ashi conversion. 
chartOHLC(tf, useHA) =>
    var float htfOpen   = na 
    var float htfHigh   = na 
    var float htfLow    = na 
    var float prevClose = na
    var float haClose   = na
    var float haOpen    = na
    var float prevHaC   = na
    var float prevHaO   = na
    if timeframe.change(tf)
        htfOpen   := open
        htfHigh   := high
        htfLow    := low
        prevClose := close[1]
        prevHaO   := haOpen
        prevHaC   := haClose
    htfHigh := math.max(high, htfHigh)
    htfLow  := math.min(low,  htfLow)
    switch 
        useHA => 
            [haO, haH, haL, haC] = haFrom(htfOpen, htfHigh, htfLow , close, prevHaO, prevHaC)
            haOpen  := haO
            haClose := haC
            OHLC.new(haO, haH, haL, haC, prevHaC)
        => OHLC.new(htfOpen, htfHigh, htfLow, close, prevClose)

//@variable The leftmost bar index for the box.
var int prevBarIndex = bar_index

// Determine the higher timeframe to use, and select the ticker (Heikin Ashi or regular).
var string timeframe = autoTFInput ? selectAutoTimeframe() : selectTimeframeFromInput(tfInput)
var string ticker    = useHaInput  ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid

// Get HTF bar data using either chart-based aggregation or context requests. 
[bar0, bar1] = switch 
    not useDailyInput => [chartOHLC(timeframe, useHaInput), chartOHLC(timeframe, useHaInput)[1]]
    => request.security(ticker, timeframe, [makeOHLC(0), makeOHLC(1)], lookahead = barmerge.lookahead_on)

// Determine HTF bar coordinates based on the selected calculation mode.
bool isNewPeriod = timeframe.change(timeframe)
bool drawCurrent = barstate.islast and not isNewPeriod
OHLC bar = drawCurrent ? bar0 : bar1
bar := na(bar) ? OHLC.new() : bar
float diff  = bar.c - bar.o
int   left  = prevBarIndex
int   right = drawCurrent ? bar_index : bar_index - 1
[top, bottom] = switch calcTypeInput
    CalcType.oc => [bar.c, bar.o]
    CalcType.tr => [math.max(bar.h, bar.prevC), math.min(bar.l, bar.prevC)]
    =>             [bar.h, bar.l]

// On each new HTF bar, update the index and draw the finalized boxes.
if isNewPeriod
    prevBarIndex := bar_index
    box htBar = box.new(na, na, na, na)
    htBar.setBox(
         false, left, right, top, bottom, diff, upBodyColorInput, dnBodyColorInput, upBorderColorInput, 
         dnBorderColorInput
     )
    // Draw body open-close range if OHLC mode is enabled. 
    if calcTypeInput == CalcType.ohlc
        box htBody = box.new(na, na, na, na)
        htBody.setBox(
             false, left, right, bar.o, bar.c, diff, upBodyColorInput, dnBodyColorInput, upBorderColorInput, 
             dnBorderColorInput
         )

// For the current realtime HTF bar, draw the developing box. 
if barstate.islast
    var box rtBox = box.new(na, na, na, na)
    rtBox.setBox(
         isNewPeriod, left, right, top, bottom, diff, upBodyColorInput, dnBodyColorInput, upBorderColorInput,
         dnBorderColorInput
     )
    // Draw body open-close if OHLC mode is enabled. 
    if calcTypeInput == CalcType.ohlc
        var box rtBody = box.new(na, na, na, na)
        rtBody.setBox(
             isNewPeriod, left, right, bar.o, bar.c, diff, upBodyColorInput, dnBodyColorInput, upBorderColorInput,
             dnBorderColorInput
         )
````
