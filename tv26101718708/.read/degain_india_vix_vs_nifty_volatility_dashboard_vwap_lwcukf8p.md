# Degain INDIA VIX v/s Nifty Volatility Dashboard + VWAP

- url: https://www.tradingview.com/script/lWcUkf8p-Degain-INDIA-VIX-v-s-Nifty-Volatility-Dashboard-VWAP/
- type: indicator
- pine_id: PUB;8eed84f0fbb34cc3884715e5b5d53cd8
- version: 1.0

## Description

Short Description

An institutional-grade volatility mapping toolkit designed specifically for the Indian Stock Market (NSE). This indicator dynamically translates the INDIA VIX (Annual Volatility) into actionable intraday and positional price bands (Monthly, Weekly, Daily, Hourly, and 30-Minute) directly onto your Nifty chart. It features an integrated intraday VWAP tracking engine and a highly responsive dashboard for an at-a-glance view of market risk.

Detailed Overview
Most retail traders view the INDIA VIX as just a "fear gauge number," but institutional desks use it mathematically to calculate exactly where a benchmark index is expected to trade over specific time horizons. This script closes that gap.

By extracting real-time and historical volatility metrics from NSE:INDIAVIX and projecting them mathematically onto NSE:NIFTY, this toolkit automatically calculates the maximum standard deviation thresholds the market expects the index to contain.

Why the Time Horizons Matter:
Monthly & Weekly Bands: Perfect for option writers setting up Iron Condors, Strangles, or defining safe premium-decay boundaries.

Daily Bands: Vital for intraday momentum traders to identify overextended markets or absolute "reversal zones."

Hourly & 30-Minute Bands: Tailored specifically for micro-trend scalpers to capture high-probability statistical breakout zones during volatile market hours.

## Source Code

````pine
//@version=6
indicator(title = 'Artharjan INDIA VIX v/s Nifty Volatility Dashboard + VWAP', shorttitle = 'AVIX + VWAP', overlay = true)

// ==========================================
// INPUTS & SETTINGS
// ==========================================
DEBUG = input.bool(defval=false, title="Debug Mode On/Off?")
ShowTable = input.bool(defval = true, title="Show Table?", inline = "L0", group="Table Display Settings")
TableLocation = input.string('top_right', title = 'Position', options = ['top_left', 'top_center', 'top_right', 'middle_left', 'middle_center', 'middle_right', 'bottom_left', 'bottom_center', 'bottom_right'], group = "Table Display Settings", inline = "Table", tooltip = 'Default location is at Centre Top')
TableTextSize = input.string('Auto', title = 'Text Size', options = ['Auto', 'Huge', 'Large', 'Normal', 'Small', 'Tiny'], group = "Table Display Settings", inline = "Table", tooltip = 'Default Text Size is Auto')
ShowAll = input.bool(defval=true, title = 'Always show all levels in the table', group = "Table Display Settings")

StaticDynamic = input.bool(defval = true, title="Static or Dynamic?", inline = "L1", group="Show Levels", tooltip = "Static is recommended since levels are plotted based on NIFTY/INDIAVIX previous day's closing price else NIFTY/INDIAVIX LTP will be used to calculate levels dynamically")
ShowLevelsOnChart = input.bool(defval = true, title="On Chart", inline = "L2", group="Show Levels")
ShowLevelsOnPriceScale = input.bool(defval = true, title="On Price Scale", inline = "L2", group="Show Levels")

ShowRCP = input.bool(defval = true, title="RCP", inline = "L2.0", group="Levels to show ?", tooltip = "Plots the Reference Closing Price of Benchmark Index used for calculation of Levels")
ShowDL = input.bool(defval = true, title="Daily", inline = "L3", group="Levels to show ?")
ShowWL = input.bool(defval = true, title="Weekly", inline = "L3", group="Levels to show ?")
ShowML = input.bool(defval = true, title="Monthly", inline = "L4", group="Levels to show ?")
ShowHL = input.bool(defval = true, title="Hourly", inline = "L4", group="Levels to show ?")
Show30MinL = input.bool(defval = true, title="30 Minutes", inline = "L4", group="Levels to show ?")

LevelColor = input.color(defval=color.fuchsia, title="Level Color", inline = "L5", group="Levels to show ?")
PlotThickness = input.int(defval = 1, title="Level Thickness", minval=1, maxval=10, inline = "L5", group="Levels to show ?")
lineStyleInput = input.string(defval = "Arrow Right", title = "Level Style", options = ["Solid", "Dotted", "Dashed", "Arrow Left", "Arrow Right", "Arrow Both"], inline = "L6", group="Levels to show ?")
lineExtensionSettings = input.string(defval = "Right", title = "Extend Levels", options = ["Right", "Left", "Both"], inline = "L6", group="Levels to show ?")

// VWAP Specific Settings
ShowVWAP = input.bool(defval = true, title = "Show VWAP on Chart?", group = "VWAP Settings")
VwapColor = input.color(defval = color.blue, title = "VWAP Line Color", group = "VWAP Settings")
VwapThickness = input.int(defval = 2, title = "VWAP Thickness", minval=1, maxval=5, group = "VWAP Settings")

comparativeTickerId = input.symbol(defval = 'NSE:INDIAVIX', title = 'Volatility Index')
NiftyTickerId = input.symbol(defval = 'NSE:NIFTY', title = 'Benchmark Index')

// ==========================================
// DATA ACQUISITION & OPTIMIZATION
// ==========================================
isNiftyChart = ticker.standard(syminfo.tickerid) == ticker.standard(NiftyTickerId)

if not isNiftyChart and bar_index == last_bar_index
    label.new(bar_index, high, "WARNING: \nTo plot volatility levels correctly\nPlease select chart symbol as " + NiftyTickerId, style=label.style_label_left, color=color.red, textcolor=color.white, textalign = text.align_left, size=size.small)

// Consolidated Security Tuple Calls to maximize data pipeline speed
[AnnualVol, AnnualVolPrev] = request.security(comparativeTickerId, 'D', [close[0], close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)
[NiftyCurrentValue, NiftyPrevValue] = request.security(NiftyTickerId, 'D', [close[0], close[1]], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)

isSessionClosed = time_close("D") < time
INDEX = ((isSessionClosed or (barstate.isconfirmed and timeframe.isdaily)) and StaticDynamic)? 0: (isSessionClosed and (not StaticDynamic))? 0: ((not isSessionClosed) and StaticDynamic) ? 1: ((not isSessionClosed) and not (StaticDynamic))? 0:1

NiftyDClose = request.security(NiftyTickerId, 'D', close[INDEX], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)
VIXDClose = request.security(comparativeTickerId, 'D', close[INDEX], ignore_invalid_symbol = true, lookahead = barmerge.lookahead_on, gaps = barmerge.gaps_off)

VixPctChange = math.round((AnnualVol - AnnualVolPrev) / AnnualVolPrev * 100, 2)
VixChangeTxt = VixPctChange > 0? " ↑" : " ↓"
NiftyPctChange = math.round((NiftyCurrentValue - NiftyPrevValue) / NiftyPrevValue * 100, 2)
NiftChangeTxt = NiftyPctChange > 0? " ↑" : " ↓"

// ==========================================
// MATHEMATICAL VOLATILITY CRUNCHING
// ==========================================
RefCloseVix   = VIXDClose
MonthlyVol    = RefCloseVix / math.sqrt(12)
WeeklyVol     = RefCloseVix / math.sqrt(52)
DailyVol      = RefCloseVix / math.sqrt(252)
HourlyVol     = RefCloseVix / math.sqrt(int(252 * 375 / 60))    // Custom tailored to 375 mins for NSE
Min30Vol      = RefCloseVix / math.sqrt(int(252 * 375 / 30))    // Tailored to 30 min intervals for NSE

RefCloseNifty = NiftyDClose

if DEBUG
    PriceLabel = label.new(x=bar_index, y=high, text="Session Close? " + str.tostring(isSessionClosed) + " BAR_INDEX = " + str.tostring(INDEX) + "\nReference Price = " + str.tostring(RefCloseNifty), style=label.style_label_lower_left, textcolor=color.white, size=size.small, color=#ff0000)
    label.delete(PriceLabel[1])

NiftyMMax = RefCloseNifty * (1 + MonthlyVol / 100)
NiftyMMin = RefCloseNifty * (1 - MonthlyVol / 100)
NiftyWMax = RefCloseNifty * (1 + WeeklyVol / 100)
NiftyWMin = RefCloseNifty * (1 - WeeklyVol / 100)
NiftyDMax = RefCloseNifty * (1 + DailyVol / 100)
NiftyDMin = RefCloseNifty * (1 - DailyVol / 100)
NiftyHMax = RefCloseNifty * (1 + HourlyVol / 100)
NiftyHMin = RefCloseNifty * (1 - HourlyVol / 100)
Nifty30MinMax = RefCloseNifty * (1 + Min30Vol / 100)
Nifty30MinMin = RefCloseNifty * (1 - Min30Vol / 100)

// ==========================================
// VWAP CALCULATION & PLOTTING
// ==========================================
myVwap = ta.vwap
plot(ShowVWAP and timeframe.isintraday ? myVwap : na, title="VWAP", color=VwapColor, linewidth=VwapThickness, style=plot.style_line)

// ==========================================
// PRICE SCALE PLOTTING
// ==========================================
plot(ShowLevelsOnPriceScale and ShowML? math.round(NiftyMMax):na,title="MMax", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowML? math.round(NiftyMMin):na,title="MMin", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowWL? math.round(NiftyWMax):na,title="WMax", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowWL? math.round(NiftyWMin):na,title="WMin", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowDL? math.round(NiftyDMax):na,title="DMax", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowDL? math.round(NiftyDMin):na,title="DMin", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowHL? math.round(NiftyHMax):na,title="HMax", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and ShowHL? math.round(NiftyHMin):na,title="HMin", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and Show30MinL? math.round(Nifty30MinMax):na,title="30MinMax", color = LevelColor, display = display.price_scale)
plot(ShowLevelsOnPriceScale and Show30MinL? math.round(Nifty30MinMin):na,title="30MinMin", color = LevelColor, display = display.price_scale)
plot((DEBUG or ShowRCP)? RefCloseNifty:na,title="RCP", color = color.orange, display = display.price_scale)

// ==========================================
// DYNAMIC LINE GENERATION
// ==========================================
var line NiftyMMaxLine = na 
var line NiftyMMinLine = na
var line NiftyWMaxLine = na
var line NiftyWMinLine = na
var line NiftyDMaxLine = na
var line NiftyDMinLine = na
var line NiftyHMaxLine = na
var line NiftyHMinLine = na
var line Nifty30MinMaxLine = na
var line Nifty30MinMinLine = na
var line RefPriceLine = na

lineStyle = line.style_solid
if lineStyleInput == "Dotted"
    lineStyle := line.style_dotted
else if lineStyleInput == "Dashed"
    lineStyle := line.style_dashed
else if lineStyleInput == "Arrow Left"
    lineStyle := line.style_arrow_left
else if lineStyleInput == "Arrow Right"
    lineStyle := line.style_arrow_right
else if lineStyleInput == "Arrow Both"
    lineStyle := line.style_arrow_both

lineExtension = extend.right
if lineExtensionSettings == "Right"
    lineExtension := extend.right
else if lineExtensionSettings == "Left"
    lineExtension := extend.left
else if lineExtensionSettings == "Both"
    lineExtension := extend.both

if bool(ta.change(time('D'))) and ShowLevelsOnChart and isNiftyChart
    line.delete(NiftyMMaxLine[1])
    line.delete(NiftyMMinLine[1])
    line.delete(NiftyWMaxLine[1])
    line.delete(NiftyWMinLine[1])
    line.delete(NiftyDMaxLine[1])
    line.delete(NiftyDMinLine[1])
    line.delete(NiftyHMaxLine[1])
    line.delete(NiftyHMinLine[1])
    line.delete(Nifty30MinMaxLine[1])
    line.delete(Nifty30MinMinLine[1])
    line.delete(RefPriceLine[1])
    
    if DEBUG or ShowRCP
        RefPriceLine := line.new(bar_index, math.round(RefCloseNifty,2), bar_index + 1, math.round(RefCloseNifty,2), xloc = xloc.bar_index, extend = lineExtension, color = #ff7b00, style = lineStyle, width = PlotThickness)
    if ShowML
        NiftyMMaxLine := line.new(bar_index, math.round(NiftyMMax), bar_index + 1, math.round(NiftyMMax), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
        NiftyMMinLine := line.new(bar_index, math.round(NiftyMMin), bar_index + 1, math.round(NiftyMMin), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
    if ShowWL
        NiftyWMaxLine := line.new(bar_index, math.round(NiftyWMax), bar_index + 1, math.round(NiftyWMax), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
        NiftyWMinLine := line.new(bar_index, math.round(NiftyWMin), bar_index + 1, math.round(NiftyWMin), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
    if ShowDL
        NiftyDMaxLine := line.new(bar_index, math.round(NiftyDMax), bar_index + 1, math.round(NiftyDMax), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
        NiftyDMinLine := line.new(bar_index, math.round(NiftyDMin), bar_index + 1, math.round(NiftyDMin), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
    if ShowHL
        NiftyHMaxLine := line.new(bar_index, math.round(NiftyHMax), bar_index + 1, math.round(NiftyHMax), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
        NiftyHMinLine := line.new(bar_index, math.round(NiftyHMin), bar_index + 1, math.round(NiftyHMin), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
    if Show30MinL
        Nifty30MinMaxLine := line.new(bar_index, math.round(Nifty30MinMax), bar_index + 1, math.round(Nifty30MinMax), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)
        Nifty30MinMinLine := line.new(bar_index, math.round(Nifty30MinMin), bar_index + 1, math.round(Nifty30MinMin), xloc = xloc.bar_index, extend = lineExtension, color = LevelColor, style = lineStyle, width = PlotThickness)

// ==========================================
// DASHBOARD TABLE DISPLAY LOGIC
// ==========================================
getBGColor(PctChange) =>
    PctChange > 0 ? #388e3c : #ed0606

AssignedPosition = switch TableLocation
    'top_left'      => position.top_left
    'top_center'    => position.top_center
    'top_right'     => position.top_right
    'middle_left'   => position.middle_left
    'middle_center' => position.middle_center
    'middle_right'  => position.middle_right
    'bottom_left'   => position.bottom_left
    'bottom_center' => position.bottom_center
    'bottom_right'  => position.bottom_right

CellTextSize = switch TableTextSize
    'Auto'   => size.auto
    'Huge'   => size.huge
    'Large'  => size.large
    'Normal' => size.normal
    'Small'  => size.small
    'Tiny'   => size.tiny

BorderThickness = 1
TableWidth = 0
pos1 = str.pos(comparativeTickerId, ':')
pos2 = str.pos(NiftyTickerId, ':')

var table t = table.new(AssignedPosition, 4, 8, frame_width = BorderThickness, border_width = BorderThickness, frame_color = color.navy, border_color = color.white)
if ShowTable and barstate.islast and (timeframe.isintraday or timeframe.isdaily)
    table.cell(t, 0, 0, 'Volatility Index', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 0, 1, str.substring(comparativeTickerId, pos1 + 1), width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 0, 2, 'Forecast Period', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 1, 0, 'Current Value', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 1, 1, str.tostring(math.round(AnnualVol, 2)) + " (" + str.tostring(VixPctChange,format.percent) + VixChangeTxt + ")", width = TableWidth, text_color = color.white, bgcolor = getBGColor(VixPctChange), text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 1, 2, 'Forecast Volatility', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 2, 0, 'Benchmark Index', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 2, 1, str.substring(NiftyTickerId, pos2 + 1), width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 2, 2, 'Min Range', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 3, 0, 'Current Value', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 3, 1, str.tostring(math.round(NiftyCurrentValue,2)) + " ("+ str.tostring(NiftyPctChange,format.percent) + NiftChangeTxt + ")", width = TableWidth, text_color = color.white, bgcolor = getBGColor(NiftyPctChange), text_size = CellTextSize, text_formatting = text.format_bold)
    table.cell(t, 3, 2, 'Max Range', width = TableWidth, text_color = color.white, bgcolor = #340370, text_size = CellTextSize, text_formatting = text.format_bold)
    
    if ShowAll or ShowML
        table.cell(t, 0, 3, 'Monthly', width = TableWidth, text_color = color.white, bgcolor = #388e3c, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 1, 3, '+/- ' + str.tostring(math.round(MonthlyVol, 2)) + ' %', width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 2, 3, str.tostring(math.round(NiftyMMin)), width = TableWidth, text_color = color.navy, bgcolor = #fffdce, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 3, 3, str.tostring(math.round(NiftyMMax)), width = TableWidth, text_color = color.navy, bgcolor = #d4ffdc, text_size = CellTextSize, text_formatting = text.format_bold)
    if ShowAll or ShowWL
        table.cell(t, 0, 4, 'Weekly', width = TableWidth, text_color = color.white, bgcolor = #388e3c, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 1, 4, '+/- ' + str.tostring(math.round(WeeklyVol, 2)) + ' %', width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 2, 4, str.tostring(math.round(NiftyWMin)), width = TableWidth, text_color = color.navy, bgcolor = #fffdce, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 3, 4, str.tostring(math.round(NiftyWMax)), width = TableWidth, text_color = color.navy, bgcolor = #d4ffdc, text_size = CellTextSize, text_formatting = text.format_bold)
    if ShowAll or ShowDL
        table.cell(t, 0, 5, 'Daily', width = TableWidth, text_color = color.white, bgcolor = #388e3c, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 1, 5, '+/- ' + str.tostring(math.round(DailyVol, 2)) + ' %', width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 2, 5, str.tostring(math.round(NiftyDMin)), width = TableWidth, text_color = color.navy, bgcolor = #fffdce, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 3, 5, str.tostring(math.round(NiftyDMax)), width = TableWidth, text_color = color.navy, bgcolor = #d4ffdc, text_size = CellTextSize, text_formatting = text.format_bold)
    if ShowAll or ShowHL
        table.cell(t, 0, 6, 'Hourly', width = TableWidth, text_color = color.white, bgcolor = #388e3c, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 1, 6, '+/- ' + str.tostring(math.round(HourlyVol, 2)) + ' %', width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 2, 6, str.tostring(math.round(NiftyHMin)), width = TableWidth, text_color = color.navy, bgcolor = #fffdce, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 3, 6, str.tostring(math.round(NiftyHMax)), width = TableWidth, text_color = color.navy, bgcolor = #d4ffdc, text_size = CellTextSize, text_formatting = text.format_bold)
    if ShowAll or Show30MinL
        table.cell(t, 0, 7, '30 Mins', width = TableWidth, text_color = color.white, bgcolor = #388e3c, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 1, 7, '+/- ' + str.tostring(math.round(Min30Vol, 2)) + ' %', width = TableWidth, text_color = color.navy, bgcolor = #bbd9fb, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 2, 7, str.tostring(math.round(Nifty30MinMin)), width = TableWidth, text_color = color.navy, bgcolor = #fffdce, text_size = CellTextSize, text_formatting = text.format_bold)
        table.cell(t, 3, 7, str.tostring(math.round(Nifty30MinMax)), width = TableWidth, text_color = color.navy, bgcolor = #d4ffdc, text_size = CellTextSize, text_formatting = text.format_bold)

// ==========================================
// ACTIONABLE REAL-TIME BREAKOUT ALERTS
// ==========================================
alertcondition(ta.crossover(close, NiftyDMax), title="Nifty Daily Max Breached", message="Nifty has broken out above the Daily Volatility Max level!")
alertcondition(ta.crossunder(close, NiftyDMin), title="Nifty Daily Min Breached", message="Nifty has crashed down below the Daily Volatility Min level!")
````
