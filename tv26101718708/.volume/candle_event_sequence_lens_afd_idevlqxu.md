# Candle Event Sequence Lens [AFD]

- url: https://www.tradingview.com/script/idEVlQxU-Candle-Event-Sequence-Lens-AFD/
- type: indicator
- pine_id: PUB;9a198e65b3ca43a68d4757bc3a81dc16
- version: 1.0

## Description

[image]https://www.tradingview.com/x/2IJoHp7h/[/image]
[b]Which printed first — the high or the low?[/b]
A 15-minute candle shows four prices but hides the order they printed in. Candle Event Sequence Lens opens the last closed candle into its 1-minute and 5-minute candles, with recent higher time frame candles beside it, so the sequence sits right on your chart.

[b]What you see[/b]
[image]https://www.tradingview.com/x/qPZjhdfb/[/image]
[list]
[*]The last closed candle split into smaller candles (1m and 5m by default), drawn to the right of the price bars
[*]Up to 6 recent candles of up to 3 other time frames next to it (30m, 1h and 2h by default)
[*]Cyan outline: the first 1-minute bar that reached the candle's high. Magenta: the low
[*]Amber outline: one bar holds both, so the order inside it is unknown
[*]High/Low price tags on every row. Hover a breakdown tag for the times, e.g. "Low first 15:45 · high 15:51"
[*]An orange box on the price chart marks the candle being broken down
[*]An arrow above each row's newest candle
[/list]

[b]Setup[/b]
[list]
[*]Runs on standard 5 to 60 minute charts. It draws right of the last bar; if it is cut off, scroll the chart left
[*]Stacked (default): each row has its own scale; read prices from the tags
[*]Beside: real prices, lined up with the price axis. A group too tall for the view is scaled to fit and marked "scaled"
[*]Up to 3 breakdowns (Auto or 1, 2, 3, 5, 10, 15, 30 min) and up to 3 other time frames (Auto, minutes, D or W)
[*]Custom levels: enter two prices to see which 1-minute bar reached each one first
[/list]

[b]Good to know[/b]
[list]
[*]Order inside a single minute is never known. Amber says so instead of guessing
[*]"Reached" means a 1-minute bar's range included the price, not a confirmed trade or fill
[*]Missing, gapped or mismatched 1-minute data shows "order unknown"
[*]On a coarser row like 5m, amber means both fell in that group, not in the same minute
[*]The breakdown moves to the newest candle as each chart candle closes. The newest side candle (dashed outline) keeps changing until its period closes
[*]Fixed choices do not adapt to the chart: a time frame equal to the chart is hidden, a shorter one shows only the last chart bar's candles, and a breakdown must be shorter than the candle. Auto follows the chart
[/list]

Describes chart history only: no signals, no forecasts. Educational use; not financial advice. Open-source under MPL 2.0.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry
//@version=6
indicator("Candle Event Sequence Lens [AFD]", "CESL [AFD]", overlay = true, format = format.price, max_boxes_count = 401, max_lines_count = 210, max_labels_count = 224)

// Constants
const int MAX_SUBBARS         = 60
const int MINUTE_MS           = 60000
const int HISTORY_INTRABARS   = 100000
const int STRIP_COUNT         = 3
const int TAG_BARS            = 16
const int MAX_STRIP_REACH     = 410
const int REF_ROWS            = 6
const int MAX_SIDE_REACH      = 498
const string HOVER_TARGET     = "   "
const float STACK_FILL        = 0.9
const float ROW_GAP_FRACTION  = 0.05
const float ARROW_ROW_GAP_FRACTION = 0.07
const float FIT_MARGIN        = 0.08
const float VOLUME_FRACTION   = 0.2
const float VOLUME_GAP        = 0.06
const string BREAKDOWN_GROUP  = "Candle breakdown"
const string SIDE_GROUP       = "Other time frame candles"
const string LAYOUT_GROUP     = "Layout"
const string COLOR_GROUP      = "Colors"
const string TEXT_GROUP       = "Text"
const int SIDE_MAX            = 6
const int SIDE_GROUPS         = 3

// Inputs
string strip1Input          = input.string("1", "Breakdown (min)", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30"], inline = "strips", group = BREAKDOWN_GROUP, display = display.none)
string strip2Input          = input.string("5", "", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30"], inline = "strips", group = BREAKDOWN_GROUP, display = display.none)
string strip3Input          = input.string("Off", "", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30"], tooltip = "• Splits the candle into smaller candles, up to 3 rows\n• Auto: usually 15 candles or fewer; a number must divide the candle and be shorter\n• Coarser rows outline the group holding the high or low minute", inline = "strips", group = BREAKDOWN_GROUP, display = display.none)
string referenceSourceInput = input.string("High/Low", "Levels", options = ["High/Low", "Custom"], tooltip = "• High/Low: outlines the first 1-minute bar that reached the high, and the low\n• Custom: the first 1-minute bar whose range includes each price below", group = BREAKDOWN_GROUP, display = display.none)
float referenceAInput       = input.price(0.0, "Level A", inline = "levels", group = BREAKDOWN_GROUP, active = referenceSourceInput == "Custom", display = display.none)
float referenceBInput       = input.price(0.0, "B", tooltip = "• Used with Custom\n• A bar's range includes the price; the time inside the minute is unknown", inline = "levels", group = BREAKDOWN_GROUP, active = referenceSourceInput == "Custom", display = display.none)
int stripGapInput           = input.int(20, "Gap from last bar", minval = 1, maxval = 100, tooltip = "• Empty bars before the breakdown\n• Cut off? Scroll the chart left", group = BREAKDOWN_GROUP, display = display.none)

string sideTf1Input         = input.string("30", "Time frames", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30", "60", "120", "240", "D", "W"], inline = "sides", group = SIDE_GROUP, display = display.none)
string sideTf2Input         = input.string("60", "", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30", "60", "120", "240", "D", "W"], inline = "sides", group = SIDE_GROUP, display = display.none)
string sideTf3Input         = input.string("120", "", options = ["Off", "Auto", "1", "2", "3", "5", "10", "15", "30", "60", "120", "240", "D", "W"], tooltip = "• Recent candles of up to 3 other time frames; minutes unless D or W\n• Auto: the next higher time frame; a shorter one shows only the last chart bar's candles\n• Dashed outline: newest period not complete", inline = "sides", group = SIDE_GROUP, display = display.none)
int sideCountInput          = input.int(3, "Candles each", minval = 1, maxval = SIDE_MAX, tooltip = "• Oldest on the left", group = SIDE_GROUP, active = sideTf1Input != "Off" or sideTf2Input != "Off" or sideTf3Input != "Off", display = display.none)
int sideGapInput            = input.int(12, "Gap between groups", minval = 6, maxval = 30, tooltip = "• Empty bars before each group, 6 or more\n• Beside layout only", group = SIDE_GROUP, active = sideTf1Input != "Off" or sideTf2Input != "Off" or sideTf3Input != "Off", display = display.none)

string layoutInput          = input.string("Stacked", "Layout", options = ["Beside", "Stacked"], tooltip = "• Beside: real prices; a group taller than the view is scaled to fit and marked \"scaled\"\n• Stacked: each row has its own scale; the High/Low tags carry the real prices", group = LAYOUT_GROUP, display = display.none)
string sizeInput            = input.string("Small", "Candle size", options = ["Small", "Medium", "Large", "X-large"], tooltip = "• 3, 5, 7 or 9 bars wide\n• Stacked: also row height", group = LAYOUT_GROUP, display = display.none)
bool volumeInput            = input.bool(false, "Volume bars", tooltip = "• Scaled to each row's largest bar\n• Blank where volume is missing", group = LAYOUT_GROUP, display = display.none)
bool markLatestInput        = input.bool(true, "Mark newest candle", inline = "latest", group = LAYOUT_GROUP, display = display.none)
color latestColorInput      = input.color(#2962FF, "", tooltip = "• Arrow above each row's newest candle\n• Beside: one height, just above the tallest candle shown", inline = "latest", group = LAYOUT_GROUP, display = display.none, active = markLatestInput)
bool panelInput             = input.bool(false, "Background panel", tooltip = "• A faint panel behind the candles", group = LAYOUT_GROUP, display = display.none)

color upBodyColorInput      = input.color(#1A7F75, "Candles", inline = "candles", group = COLOR_GROUP, display = display.none)
color downBodyColorInput    = input.color(#B03A38, "", inline = "candles", group = COLOR_GROUP, display = display.none)
bool bodyFillInput          = input.bool(true, "Fill", tooltip = "• Up and down colors, also used by the volume bars\n• Fill off: hollow candles", inline = "candles", group = COLOR_GROUP, display = display.none)
color borderColorInput      = input.color(#9598A1, "Border", inline = "border", group = COLOR_GROUP, display = display.none)
int borderWidthInput        = input.int(1, "", minval = 1, maxval = 4, tooltip = "• Candle borders, and wicks on hollow candles\n• Bars holding a level use the level colors", inline = "border", group = COLOR_GROUP, display = display.none)
color aColorInput           = input.color(#00BCD4, "Levels A / B / both", inline = "levelColors", group = COLOR_GROUP, display = display.none)
color bColorInput           = input.color(#E040FB, "", inline = "levelColors", group = COLOR_GROUP, display = display.none)
color sharedColorInput      = input.color(#FFB300, "", tooltip = "• Outline of the bar holding the high (or A), the low (or B), or both\n• Both: one bar holds both", inline = "levelColors", group = COLOR_GROUP, display = display.none)
string referenceStyleInput  = input.string("Dashed", "Level lines", options = ["Solid", "Dashed", "Dotted", "Off"], tooltip = "• Line across the breakdown at each level\n• Off: tags only", group = COLOR_GROUP, display = display.none)
bool parentOnInput          = input.bool(true, "Chart outline", inline = "outline", group = COLOR_GROUP, display = display.none)
color parentColorInput      = input.color(#FF9800, "", inline = "outline", group = COLOR_GROUP, display = display.none)
int parentWidthInput        = input.int(1, "", minval = 1, maxval = 4, inline = "outline", group = COLOR_GROUP, display = display.none)
bool parentFillInput        = input.bool(false, "Fill", tooltip = "• Box around the broken-down candle on the price chart\n• Untick to hide it", inline = "outline", group = COLOR_GROUP, display = display.none)

color laneLabelColorInput   = input.color(#2962FF, "Time frame names", tooltip = "• The name under or beside each row, in bold\n• Text size follows Candle size", inline = "names", group = TEXT_GROUP, display = display.none)
color tagTextColorInput     = input.color(#9598A1, "High/Low tags", inline = "tags", group = TEXT_GROUP, display = display.none)
bool tagFillInput           = input.bool(false, "Colored background", tooltip = "• Price tags at each row's high and low; breakdown tags take the level colors, a key to the outlines\n• Colored background uses white text\n• Hover a tag for the full result and data notes", inline = "tags", group = TEXT_GROUP, display = display.none)
bool showTextInput          = input.bool(false, "Summary", tooltip = "• Symbol, 1-minute coverage, the result and any notes above the candles\n• Off: the same facts stay in the High/Low tag hovers", group = TEXT_GROUP, display = display.none)
string textSizeInput        = input.string("Normal", "Note text", options = ["Small", "Normal", "Large"], inline = "note", group = TEXT_GROUP, display = display.none)
color noteTextColorInput    = input.color(#9598A1, "", tooltip = "• Size and color of the summary and notes", inline = "note", group = TEXT_GROUP, display = display.none)

string referenceStyle = switch referenceStyleInput
    "Dotted" => line.style_dotted
    "Solid" => line.style_solid
    => line.style_dashed
string labelSize = switch textSizeInput
    "Small" => size.small
    "Large" => size.large
    => size.normal
string laneSize = switch sizeInput
    "Small" => size.normal
    "Large" => size.huge
    "X-large" => size.huge
    => size.large
string tagSize = switch sizeInput
    "Small" => size.tiny
    "Large" => size.normal
    "X-large" => size.normal
    => size.small
string arrowSize = sizeInput == "Small" ? size.small : size.large
float rowGapFraction = markLatestInput ? ARROW_ROW_GAP_FRACTION : ROW_GAP_FRACTION
int pitch = switch sizeInput
    "Small" => 3
    "Large" => 7
    "X-large" => 9
    => 5
int halfBody = int((pitch - 1) / 2)
float rowShare = switch sizeInput
    "Small" => 0.1
    "Large" => 0.18
    "X-large" => 0.22
    => 0.14

// Types
type Strip
    int minutes
    bool available
    array<int> starts
    array<int> ends
    array<float> opens
    array<float> highs
    array<float> lows
    array<float> closes
    array<float> volumes
    array<string> tips
    int posA
    int posB

type SideRaw
    array<float> data

type SideLtf
    array<int> times
    array<int> ends
    array<float> opens
    array<float> highs
    array<float> lows
    array<float> closes
    array<float> volumes

type Side
    string frame
    string note
    int omitted
    bool show
    bool developing
    bool partial
    bool missing
    bool newestOmitted
    float top
    float low
    float span
    array<int> times
    array<int> ends
    array<float> opens
    array<float> highs
    array<float> lows
    array<float> closes
    array<float> volumes

type SideDraw
    array<box> bodies
    array<box> volumeBars
    array<line> wicks
    array<label> tags
    label header
    label arrowDown

type StripDraw
    array<box> bodies
    array<box> volumeBars
    array<line> wicks
    array<label> tips
    label caption
    label arrowDown

// Functions
validOhlc(float o, float h, float l, float c) =>
    not na(o) and not na(h) and not na(l) and not na(c) and l <= math.min(o, c) and math.max(o, c) <= h

priceText(float price) =>
    str.tostring(price, format.mintick)

volumeText(float v) =>
    str.tostring(v, format.volume)

// Price to y: the real price (Beside) or its place in a row's band (Stacked).
mapY(float price, bool stackedMode, float lo, float span, float bottom, float height) =>
    stackedMode ? bottom + (span > 0 ? (price - lo) / span : 0.5) * height : price

setRef(line ln, label tg, bool show, int x1, int x2, float y, string txt, color lineColor, string tip, string tagStyle, color textColor) =>
    bool lineOn = show and referenceStyleInput != "Off"
    line.set_xy1(ln, x1, lineOn ? y : na)
    line.set_xy2(ln, x2, lineOn ? y : na)
    line.set_color(ln, lineColor)
    line.set_style(ln, referenceStyle)
    label.set_xy(tg, x2 + 2, show ? y : na)
    label.set_style(tg, tagStyle)
    label.set_text(tg, txt)
    label.set_color(tg, tagFillInput ? lineColor : color.new(chart.bg_color, 100))
    label.set_textcolor(tg, tagFillInput ? color.white : textColor)
    label.set_tooltip(tg, tip)

clockText(int t) =>
    str.format_time(t, "HH:mm", syminfo.timezone)

intervalText(int startTime, int endTime) =>
    clockText(startTime) + "–" + clockText(endTime)

dateIntervalText(int startTime, int endTime) =>
    str.format_time(startTime, "yyyy-MM-dd", syminfo.timezone) + "–" + str.format_time(endTime, "yyyy-MM-dd", syminfo.timezone)

referenceText(float price, int firstIndex, int jumpIndex, array<int> timesArray, array<int> endsArray) =>
    string result = priceText(price) + "\n• Not inside any 1-minute bar's range"
    if not na(firstIndex)
        result := priceText(price) + "\n• First inside the " + intervalText(array.get(timesArray, firstIndex), array.get(endsArray, firstIndex)) + " bar's range"
    result + (not na(jumpIndex) ? "\n• Price gapped across it at " + clockText(array.get(timesArray, jumpIndex)) : "")

relationshipText(string state, string coverage, int firstA, int firstB, bool jumpA, bool jumpB, array<int> timesArray) =>
    string result = "Order unknown"
    if state == "Observed"
        if coverage != "Continuous observed intervals"
            result := "1-minute data incomplete or differs from the candle · order unknown"
        else if jumpA or jumpB
            result := "Price gapped across a level · order unknown"
        else if not na(firstA) and not na(firstB) and firstA == firstB
            result := "A and B in the same minute (" + clockText(array.get(timesArray, firstA)) + ") · order unknown"
        else if not na(firstA) and not na(firstB)
            result := (firstA < firstB ? "A first in a range " + clockText(array.get(timesArray, firstA)) + " · B " + clockText(array.get(timesArray, firstB)) : "B first in a range " + clockText(array.get(timesArray, firstB)) + " · A " + clockText(array.get(timesArray, firstA))) + " · a range is not a confirmed trade"
        else if not na(firstA) or not na(firstB)
            result := "Only " + (na(firstA) ? "B" : "A") + " inside a 1-minute range · order unknown"
        else
            result := "Neither level inside a 1-minute range · order unknown"
    result

verdictText(string state, string coverage, int firstHigh, int firstLow, array<int> timesArray) =>
    string result = state
    if state == "Observed"
        if coverage == "Observed intervals have gaps"
            result := "Missing 1-minute data · order unknown"
        else if coverage == "Observed OHLC differs from parent"
            result := "1-minute data differs from the candle · order unknown"
        else if na(firstHigh) or na(firstLow)
            result := "High or low not found in the 1-minute data"
        else if firstHigh == firstLow
            result := "High and low in the same minute (" + clockText(array.get(timesArray, firstHigh)) + ") · order unknown"
        else if firstHigh < firstLow
            result := "High first " + clockText(array.get(timesArray, firstHigh)) + " · low " + clockText(array.get(timesArray, firstLow))
        else
            result := "Low first " + clockText(array.get(timesArray, firstLow)) + " · high " + clockText(array.get(timesArray, firstHigh))
    result

// Auto breakdown: the finest dividing resolution, usually 15 candles or fewer.
autoMinutesOf(int parentMinutes) =>
    array<int> choices = array.from(1, 2, 3, 5, 10, 15, 30)
    int best15 = na
    int best30 = na
    for m in choices
        if (m == 1 or (m < parentMinutes and parentMinutes % m == 0))
            if na(best15) and parentMinutes <= 15 * m
                best15 := m
            if na(best30) and parentMinutes <= 30 * m
                best30 := m
    na(best15) ? (na(best30) ? 1 : best30) : best15

newStrip() =>
    Strip.new(0, false, array.new<int>(), array.new<int>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<string>(), na, na)

newDraw() =>
    array<box> bodies = array.new<box>()
    array<box> volumeBars = array.new<box>()
    array<line> wicks = array.new<line>()
    array<label> tips = array.new<label>()
    for i = 0 to MAX_SUBBARS - 1
        array.push(bodies, box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = borderColorInput, border_width = borderWidthInput, bgcolor = na, xloc = xloc.bar_index))
        array.push(volumeBars, box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = na, bgcolor = na, xloc = xloc.bar_index))
        array.push(wicks, line.new(x1 = bar_index, y1 = na, x2 = bar_index, y2 = na, color = borderColorInput, width = borderWidthInput, xloc = xloc.bar_index))
        array.push(tips, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_none, textcolor = chart.fg_color, size = size.small))
    StripDraw.new(bodies, volumeBars, wicks, tips, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(chart.bg_color, 100), textcolor = laneLabelColorInput, size = laneSize, text_formatting = text.format_bold), label.new(x = bar_index, y = na, text = "⬇", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = latestColorInput, size = arrowSize))

newSideDraw() =>
    array<box> bodies = array.new<box>()
    array<box> volumeBars = array.new<box>()
    array<line> wicks = array.new<line>()
    array<label> tags = array.new<label>()
    for i = 0 to SIDE_MAX - 1
        array.push(bodies, box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = borderColorInput, border_width = borderWidthInput, bgcolor = na, xloc = xloc.bar_index))
        array.push(volumeBars, box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = na, bgcolor = na, xloc = xloc.bar_index))
        array.push(wicks, line.new(x1 = bar_index, y1 = na, x2 = bar_index, y2 = na, color = borderColorInput, width = borderWidthInput, xloc = xloc.bar_index))
        array.push(tags, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_none, textcolor = chart.fg_color, size = size.small))
    SideDraw.new(bodies, volumeBars, wicks, tags, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(chart.bg_color, 100), textcolor = laneLabelColorInput, size = laneSize, text_formatting = text.format_bold, textalign = text.align_left), label.new(x = bar_index, y = na, text = "⬇", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = latestColorInput, size = arrowSize))

sideFrameText(string tf) =>
    tf == "D" or tf == "W" ? tf : int(str.tonumber(tf)) >= 60 and int(str.tonumber(tf)) % 60 == 0 ? str.tostring(int(str.tonumber(tf)) / 60) + "h" : tf + "m"

sideSecondsOf(string tf) =>
    tf == "Off" ? 0 : tf == "D" ? 86400 : tf == "W" ? 604800 : int(str.tonumber(tf)) * 60

sideCaseOf(string tf, bool chartOk, int chartSeconds) =>
    int selected = sideSecondsOf(tf)
    tf == "Off" ? "off" : not chartOk ? "chart" : selected == chartSeconds ? "equal" : selected > chartSeconds ? "higher" : chartSeconds % selected == 0 ? "lower" : "divide"

// Auto side time frame: the next higher on the 5m, 15m, 1h, 4h, D, W ladder.
sideAutoOf(string tf, bool chartOk, int chartSeconds) =>
    tf != "Auto" ? tf : not chartOk ? "60" : chartSeconds < 300 ? "5" : chartSeconds < 900 ? "15" : chartSeconds < 3600 ? "60" : chartSeconds < 14400 ? "240" : chartSeconds < 86400 ? "D" : "W"

sideRequestTfOf(string tf, string sideCase) =>
    sideCase == "higher" or sideCase == "lower" ? tf : timeframe.period

sideHtfRequest(string tf, string sideCase) =>
    string requestTf = sideRequestTfOf(tf, sideCase)
    SideRaw raw = SideRaw.new(array.new<float>())
    if sideCase == "higher"
        raw := request.security(syminfo.tickerid, requestTf, SideRaw.new(array.from(time * 1.0, time_close * 1.0, open, high, low, close, volume, time[1] * 1.0, time_close[1] * 1.0, open[1], high[1], low[1], close[1], volume[1], time[2] * 1.0, time_close[2] * 1.0, open[2], high[2], low[2], close[2], volume[2], time[3] * 1.0, time_close[3] * 1.0, open[3], high[3], low[3], close[3], volume[3], time[4] * 1.0, time_close[4] * 1.0, open[4], high[4], low[4], close[4], volume[4], time[5] * 1.0, time_close[5] * 1.0, open[5], high[5], low[5], close[5], volume[5])), barmerge.gaps_off, barmerge.lookahead_off)
        // The request can return na; an empty object keeps the field reads safe.
        if na(raw)
            raw := SideRaw.new(array.new<float>())
    raw

sideLtfRequest(string tf, string sideCase) =>
    string requestTf = sideRequestTfOf(tf, sideCase)
    [lowerTimes, lowerEnds, lowerOpens, lowerHighs, lowerLows, lowerCloses, lowerVolumes] = if sideCase == "lower"
        request.security_lower_tf(syminfo.tickerid, requestTf, [time, time_close, open, high, low, close, volume], ignore_invalid_timeframe = true, calc_bars_count = HISTORY_INTRABARS)
    else
        [array.new<int>(), array.new<int>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>()]
    SideLtf.new(lowerTimes, lowerEnds, lowerOpens, lowerHighs, lowerLows, lowerCloses, lowerVolumes)

readSide(string sideTf, string sideCase, SideRaw raw, SideLtf ltf) =>
    array<int> sideT = array.new<int>()
    array<int> sideE = array.new<int>()
    array<float> sideO = array.new<float>()
    array<float> sideH = array.new<float>()
    array<float> sideL = array.new<float>()
    array<float> sideC = array.new<float>()
    array<float> sideV = array.new<float>()
    int sideOmitted = 0
    bool sideNewestOmitted = false
    bool sideInconsistent = false
    if sideCase == "higher"
        int avail = array.size(raw.data) / 7
        if avail > 0
            for k = math.min(sideCountInput, avail) - 1 to 0
                int base = k * 7
                float t = array.get(raw.data, base)
                float te = array.get(raw.data, base + 1)
                float o = array.get(raw.data, base + 2)
                float h = array.get(raw.data, base + 3)
                float l = array.get(raw.data, base + 4)
                float c = array.get(raw.data, base + 5)
                float v = array.get(raw.data, base + 6)
                if not na(t) and not na(te) and validOhlc(o, h, l, c)
                    array.push(sideT, int(t))
                    array.push(sideE, int(te))
                    array.push(sideO, o)
                    array.push(sideH, h)
                    array.push(sideL, l)
                    array.push(sideC, c)
                    array.push(sideV, v)
                else
                    sideOmitted += 1
                    sideNewestOmitted := sideNewestOmitted or k == 0
    else if sideCase == "lower"
        int intraCount = array.size(ltf.times)
        sideInconsistent := array.size(ltf.ends) != intraCount or array.size(ltf.opens) != intraCount or array.size(ltf.highs) != intraCount or array.size(ltf.lows) != intraCount or array.size(ltf.closes) != intraCount or array.size(ltf.volumes) != intraCount
        if intraCount > 0 and not sideInconsistent
            for j = math.max(0, intraCount - sideCountInput) to intraCount - 1
                float o = array.get(ltf.opens, j)
                float h = array.get(ltf.highs, j)
                float l = array.get(ltf.lows, j)
                float c = array.get(ltf.closes, j)
                if validOhlc(o, h, l, c)
                    array.push(sideT, array.get(ltf.times, j))
                    array.push(sideE, array.get(ltf.ends, j))
                    array.push(sideO, o)
                    array.push(sideH, h)
                    array.push(sideL, l)
                    array.push(sideC, c)
                    array.push(sideV, array.get(ltf.volumes, j))
                else
                    sideOmitted += 1
                    sideNewestOmitted := sideNewestOmitted or j == intraCount - 1
    int sideN = array.size(sideT)
    string sideFrame = sideTf == "Off" ? "" : sideFrameText(sideTf)
    string sideNote = sideCase == "chart" ? "needs a standard chart in seconds, minutes, days or weeks" : sideCase == "equal" ? "selected time frame equals the chart time frame" : sideCase == "divide" ? "selected time frame does not divide the chart time frame" : sideInconsistent ? "inconsistent " + sideFrame + " data" : (sideCase == "higher" or sideCase == "lower") and sideN == 0 ? (sideOmitted > 0 ? "invalid " + sideFrame + " data" : "no " + sideFrame + " data returned") : ""
    bool sideShow = sideN > 0 and sideNote == ""
    bool newestDeveloping = sideShow and barstate.isrealtime and timenow < array.get(sideE, sideN - 1)
    bool newestPartial = sideShow and not barstate.isrealtime and sideCase == "higher" and array.get(sideE, sideN - 1) > time_close
    bool newestMissing = sideShow and sideCase == "higher" and array.get(sideE, sideN - 1) <= time
    float sideTop = sideShow ? array.max(sideH) : na
    float sideLow = sideShow ? array.min(sideL) : na
    float sideSpan = sideShow ? sideTop - sideLow : na
    Side.new(sideFrame, sideNote, sideOmitted, sideShow, newestDeveloping, newestPartial, newestMissing, sideShow and sideNewestOmitted, sideTop, sideLow, sideSpan, sideT, sideE, sideO, sideH, sideL, sideC, sideV)

buildStrip(Strip s, int minutes, array<int> timesArray, array<int> endsArray, array<float> opensArray, array<float> highsArray, array<float> lowsArray, array<float> closesArray, array<float> volumesArray, int parentStart, int parentEnd, int firstAIndex, int firstBIndex) =>
    array.clear(s.starts)
    array.clear(s.ends)
    array.clear(s.opens)
    array.clear(s.highs)
    array.clear(s.lows)
    array.clear(s.closes)
    array.clear(s.volumes)
    array.clear(s.tips)
    int parentMinutes = int((parentEnd - parentStart) / MINUTE_MS)
    int resolved = minutes < 0 ? autoMinutesOf(parentMinutes) : minutes
    s.minutes := resolved
    s.posA := na
    s.posB := na
    s.available := resolved > 0 and (resolved == 1 or (resolved < parentMinutes and parentMinutes % resolved == 0))
    if s.available
        int bucketMs = resolved * MINUTE_MS
        int count = array.size(timesArray)
        int bucket = -1
        int pos = -1
        float bo = na
        float bh = na
        float bl = na
        float bc = na
        float bv = na
        bool bvValid = true
        int covered = 0
        for i = 0 to count
            bool tail = i == count
            int thisBucket = tail ? -2 : int(math.floor((array.get(timesArray, i) - parentStart) / bucketMs))
            if thisBucket != bucket
                if bucket >= 0
                    int bStart = parentStart + bucket * bucketMs
                    int bEnd = math.min(bStart + bucketMs, parentEnd)
                    array.push(s.starts, bStart)
                    array.push(s.ends, bEnd)
                    array.push(s.opens, bo)
                    array.push(s.highs, bh)
                    array.push(s.lows, bl)
                    array.push(s.closes, bc)
                    array.push(s.volumes, bvValid and covered == bEnd - bStart ? bv : na)
                    array.push(s.tips, intervalText(bStart, bEnd) + " · " + syminfo.timezone + "\nVolume: " + (bvValid and covered == bEnd - bStart ? volumeText(bv) : "Unavailable"))
                if not tail
                    bucket := thisBucket
                    pos += 1
                    bo := array.get(opensArray, i)
                    bh := array.get(highsArray, i)
                    bl := array.get(lowsArray, i)
                    bc := array.get(closesArray, i)
                    float v = array.get(volumesArray, i)
                    bvValid := not na(v) and v >= 0
                    bv := bvValid ? v : 0.0
                    covered := array.get(endsArray, i) - array.get(timesArray, i)
            else
                bh := math.max(bh, array.get(highsArray, i))
                bl := math.min(bl, array.get(lowsArray, i))
                bc := array.get(closesArray, i)
                float v = array.get(volumesArray, i)
                if na(v) or v < 0
                    bvValid := false
                else
                    bv += v
                covered += array.get(endsArray, i) - array.get(timesArray, i)
            if not tail
                if not na(firstAIndex) and firstAIndex == i
                    s.posA := pos
                if not na(firstBIndex) and firstBIndex == i
                    s.posB := pos

// Data requests
int chartSeconds = timeframe.isminutes ? timeframe.in_seconds() : 0
bool supportedChart = chart.is_standard and timeframe.isminutes and chartSeconds >= 300 and chartSeconds <= 3600
string safeLowerTimeframe = supportedChart ? "1" : timeframe.period
[timesArray, endsArray, opensArray, highsArray, lowsArray, closesArray, volumesArray] = if supportedChart
    request.security_lower_tf(syminfo.tickerid, safeLowerTimeframe, [time, time_close, open, high, low, close, volume], ignore_invalid_timeframe = true, calc_bars_count = HISTORY_INTRABARS)
else
    [array.new<int>(), array.new<int>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>()]

bool sideChartOk = chart.is_standard and (timeframe.isseconds or timeframe.isminutes or timeframe.isdaily or timeframe.isweekly)
int sideChartSeconds = sideChartOk ? timeframe.in_seconds() : 0
string sideTf1 = sideAutoOf(sideTf1Input, sideChartOk, sideChartSeconds)
string sideTf2 = sideAutoOf(sideTf2Input, sideChartOk, sideChartSeconds)
string sideTf3 = sideAutoOf(sideTf3Input, sideChartOk, sideChartSeconds)
string sideCase1 = sideCaseOf(sideTf1, sideChartOk, sideChartSeconds)
string sideCase2 = sideCaseOf(sideTf2, sideChartOk, sideChartSeconds)
string sideCase3 = sideCaseOf(sideTf3, sideChartOk, sideChartSeconds)
SideRaw sideHtf1 = sideHtfRequest(sideTf1, sideCase1)
SideRaw sideHtf2 = sideHtfRequest(sideTf2, sideCase2)
SideRaw sideHtf3 = sideHtfRequest(sideTf3, sideCase3)
SideLtf sideLtf1 = sideLtfRequest(sideTf1, sideCase1)
SideLtf sideLtf2 = sideLtfRequest(sideTf2, sideCase2)
SideLtf sideLtf3 = sideLtfRequest(sideTf3, sideCase3)

// Snapshot of the last closed candle.
bool defaultReferences = referenceSourceInput == "High/Low"
var string inspectionState = "No closed candle loaded"
var string coverageState = "Unavailable"
var int parentStart = na
var int parentEnd = na
var int parentIndex = na
var float parentHigh = na
var float parentLow = na
var float referenceA = na
var float referenceB = na
var bool referencesDefault = true
var string volumeState = "Volume check unavailable"
var int firstAIndex = na
var int firstBIndex = na
var bool jumpAObserved = false
var bool jumpBObserved = false
var int firstJumpAIndex = na
var int firstJumpBIndex = na
var array<int> selectedTimesArray = array.new<int>()
var array<int> selectedEndsArray = array.new<int>()
var array<float> selectedOpensArray = array.new<float>()
var array<float> selectedHighsArray = array.new<float>()
var array<float> selectedLowsArray = array.new<float>()
var array<float> selectedClosesArray = array.new<float>()
var array<float> selectedVolumesArray = array.new<float>()
var array<Strip> strips = array.new<Strip>()
var array<StripDraw> draws = array.new<StripDraw>()
var box outlineBox = box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = parentColorInput, border_width = parentWidthInput, bgcolor = na, xloc = xloc.bar_index)
var array<line> refLinesA = array.new<line>()
var array<line> refLinesB = array.new<line>()
var array<label> refTagsA = array.new<label>()
var array<label> refTagsB = array.new<label>()
var box panelMain = na
var array<box> panelSides = array.new<box>()
var label headerLabel = label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_lower_left, color = color.new(chart.bg_color, 100), textcolor = noteTextColorInput, size = labelSize, textalign = text.align_left)
var label statusLabel = label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = noteTextColorInput, size = labelSize, textalign = text.align_left)
var array<SideDraw> sideDraws = array.new<SideDraw>()

arrowLabelAt(int row) =>
    label result = na
    if row < STRIP_COUNT
        StripDraw d = array.get(draws, row)
        result := d.arrowDown
    else
        SideDraw sd = array.get(sideDraws, row - STRIP_COUNT)
        result := sd.arrowDown
    result

if barstate.isfirst
    panelMain := box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = na, bgcolor = na, xloc = xloc.bar_index)
    for r = 0 to REF_ROWS - 1
        array.push(refLinesA, line.new(x1 = bar_index, y1 = na, x2 = bar_index, y2 = na, color = aColorInput, xloc = xloc.bar_index))
        array.push(refLinesB, line.new(x1 = bar_index, y1 = na, x2 = bar_index, y2 = na, color = bColorInput, xloc = xloc.bar_index))
        array.push(refTagsA, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = tagTextColorInput, size = tagSize, text_formatting = text.format_bold))
        array.push(refTagsB, label.new(x = bar_index, y = na, text = "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = tagTextColorInput, size = tagSize, text_formatting = text.format_bold))
    for k = 0 to STRIP_COUNT - 1
        array.push(strips, newStrip())
        array.push(draws, newDraw())
    for g = 0 to SIDE_GROUPS - 1
        array.push(panelSides, box.new(left = bar_index, top = na, right = bar_index, bottom = na, border_color = na, bgcolor = na, xloc = xloc.bar_index))
        array.push(sideDraws, newSideDraw())

int stripMinutes1 = strip1Input == "Off" ? 0 : strip1Input == "Auto" ? -1 : int(str.tonumber(strip1Input))
int stripMinutes2 = strip2Input == "Off" ? 0 : strip2Input == "Auto" ? -1 : int(str.tonumber(strip2Input))
int stripMinutes3 = strip3Input == "Off" ? 0 : strip3Input == "Auto" ? -1 : int(str.tonumber(strip3Input))
array<int> stripMinutes = array.from(stripMinutes1, stripMinutes2, stripMinutes3)

bool captureBar = supportedChart and (barstate.islastconfirmedhistory or (barstate.isrealtime and barstate.isconfirmed))
float captureA = defaultReferences ? high : referenceAInput
float captureB = defaultReferences ? low : referenceBInput
if captureBar
    parentStart := time
    parentIndex := bar_index
    parentEnd := time_close
    if not validOhlc(open, high, low, close) or time_close <= time or time_close - time > MAX_SUBBARS * MINUTE_MS
        inspectionState := "Invalid parent data"
    else if na(captureA) or na(captureB)
        inspectionState := "Invalid reference"
    else
        int count = array.size(timesArray)
        bool aligned = array.size(endsArray) == count and array.size(opensArray) == count and array.size(highsArray) == count and array.size(lowsArray) == count and array.size(closesArray) == count and array.size(volumesArray) == count
        if not aligned
            inspectionState := "Inconsistent subbar arrays"
        else if count == 0
            inspectionState := "1-minute history unavailable"
        else if count > MAX_SUBBARS
            inspectionState := "Subbar capacity exceeded"
        else
            bool validBatch = true
            bool continuous = true
            int previousEnd = time
            float previousClose = na
            float observedHigh = na
            float observedLow = na
            float totalVolume = 0.0
            bool completeVolume = not na(volume) and volume >= 0
            int candidateA = na
            int candidateB = na
            bool candidateJumpA = false
            bool candidateJumpB = false
            int candidateJumpAIndex = na
            int candidateJumpBIndex = na
            for i = 0 to count - 1
                int startTime = array.get(timesArray, i)
                int endTime = array.get(endsArray, i)
                float o = array.get(opensArray, i)
                float h = array.get(highsArray, i)
                float l = array.get(lowsArray, i)
                float c = array.get(closesArray, i)
                float v = array.get(volumesArray, i)
                bool validInterval = not na(startTime) and not na(endTime) and validOhlc(o, h, l, c) and time <= startTime and startTime < endTime and endTime <= time_close and endTime - startTime <= MINUTE_MS and startTime >= previousEnd
                if not validInterval
                    validBatch := false
                continuous := continuous and startTime == previousEnd
                observedHigh := na(observedHigh) ? h : math.max(observedHigh, h)
                observedLow := na(observedLow) ? l : math.min(observedLow, l)
                completeVolume := completeVolume and not na(v) and v >= 0
                if not na(v) and v >= 0
                    totalVolume += v
                if na(candidateA) and l <= captureA and captureA <= h
                    candidateA := i
                if na(candidateB) and l <= captureB and captureB <= h
                    candidateB := i
                if i > 0 and startTime == previousEnd
                    candidateJumpA := candidateJumpA or math.min(previousClose, o) < captureA and captureA < math.max(previousClose, o)
                    candidateJumpB := candidateJumpB or math.min(previousClose, o) < captureB and captureB < math.max(previousClose, o)
                    if na(candidateJumpAIndex) and candidateJumpA
                        candidateJumpAIndex := i
                    if na(candidateJumpBIndex) and candidateJumpB
                        candidateJumpBIndex := i
                previousEnd := endTime
                previousClose := c
            continuous := continuous and previousEnd == time_close
            bool agrees = array.get(opensArray, 0) == open and previousClose == close and observedHigh == high and observedLow == low
            if not validBatch
                inspectionState := "Inconsistent subbar data"
            else
                inspectionState := "Observed"
                coverageState := not continuous ? "Observed intervals have gaps" : not agrees ? "Observed OHLC differs from parent" : "Continuous observed intervals"
                parentHigh := high
                parentLow := low
                referenceA := captureA
                referenceB := captureB
                referencesDefault := defaultReferences
                volumeState := completeVolume ? math.abs(totalVolume - volume) <= math.max(0.00000001, math.max(math.abs(totalVolume), math.abs(volume)) * 0.000000001) ? "Volume matches the candle" : "Volume differs from the candle" : "Volume check unavailable"
                firstAIndex := candidateA
                firstBIndex := candidateB
                jumpAObserved := candidateJumpA
                jumpBObserved := candidateJumpB
                firstJumpAIndex := candidateJumpAIndex
                firstJumpBIndex := candidateJumpBIndex
                selectedTimesArray := array.copy(timesArray)
                selectedEndsArray := array.copy(endsArray)
                selectedOpensArray := array.copy(opensArray)
                selectedHighsArray := array.copy(highsArray)
                selectedLowsArray := array.copy(lowsArray)
                selectedClosesArray := array.copy(closesArray)
                selectedVolumesArray := array.copy(volumesArray)
                for k = 0 to STRIP_COUNT - 1
                    buildStrip(array.get(strips, k), array.get(stripMinutes, k), selectedTimesArray, selectedEndsArray, selectedOpensArray, selectedHighsArray, selectedLowsArray, selectedClosesArray, selectedVolumesArray, parentStart, parentEnd, firstAIndex, firstBIndex)

var int visibleBars = 0
var float visibleHigh = na
var float visibleLow = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visibleBars += 1
    visibleHigh := na(visibleHigh) ? high : math.max(visibleHigh, high)
    visibleLow := na(visibleLow) ? low : math.min(visibleLow, low)

// Drawing
if barstate.islast
    array<Side> sides = array.from(readSide(sideTf1, sideCase1, sideHtf1, sideLtf1), readSide(sideTf2, sideCase2, sideHtf2, sideLtf2), readSide(sideTf3, sideCase3, sideHtf3, sideLtf3))
    int sideShownCount = 0
    for g = 0 to SIDE_GROUPS - 1
        Side q = array.get(sides, g)
        if q.show
            sideShownCount += 1

    bool observed = supportedChart and inspectionState == "Observed"
    int selectedCount = array.size(selectedTimesArray)
    float priceHigh = observed and selectedCount > 0 ? array.max(selectedHighsArray) : na
    float priceLow = observed and selectedCount > 0 ? array.min(selectedLowsArray) : na
    float priceRange = priceHigh - priceLow
    float unit = na(priceHigh) ? na : priceRange > 0 ? priceRange : math.max(syminfo.mintick, math.abs(priceHigh) * 0.0001)
    float visiblePad = visibleBars > 0 ? (visibleHigh - visibleLow) * 0.15 : 0.0
    bool inRange = not na(unit) and visibleBars > 0 and priceHigh <= visibleHigh + visiblePad and priceLow >= visibleLow - visiblePad
    bool stacked = layoutInput == "Stacked"
    bool useStack = stacked and visibleBars > 0 and visibleHigh > visibleLow
    int separation = 2 * pitch
    int activeStrips = 0
    int stripBars = 0
    int widestStrip = 0
    string unavailableNote = ""
    for k = 0 to STRIP_COUNT - 1
        Strip p = array.get(strips, k)
        if observed and p.available and array.size(p.starts) > 0
            int w = pitch * array.size(p.starts)
            stripBars += w + (activeStrips > 0 ? separation : 0)
            widestStrip := math.max(widestStrip, w)
            activeStrips += 1
        else if observed and p.minutes > 0 and not p.available
            unavailableNote += (unavailableNote == "" ? "" : " · ") + str.tostring(p.minutes) + "-minute strip unavailable for this candle length" + "\n(" + str.tostring(int((parentEnd - parentStart) / MINUTE_MS)) + " min; a strip must be shorter and divide it)"
    int stripsEndOffset = stripGapInput + (useStack ? widestStrip : stripBars)
    int stripReach = stripsEndOffset + TAG_BARS
    bool reachOk = stripReach <= MAX_STRIP_REACH
    bool placeOk = useStack or (not stacked and inRange)
    bool layoutValid = observed and activeStrips > 0 and placeOk and reachOk
    bool stripsOff = stripMinutes1 == 0 and stripMinutes2 == 0 and stripMinutes3 == 0
    string blockedNote = not observed ? "" : activeStrips == 0 ? (stripsOff ? "" : "no strip resolution fits this candle") : not placeOk ? (stacked ? "stacked layout needs a visible price range" : "the candle is outside the visible price range") : not reachOk ? "strips need " + str.tostring(stripReach) + " bars right of the last bar" : ""
    int sideRows = useStack ? sideShownCount : 0
    int shownRows = (layoutValid ? activeStrips : 0) + sideRows

    float visSpan = useStack ? visibleHigh - visibleLow : na
    float rowFraction = shownRows > 0 ? math.min(rowShare, (STACK_FILL - rowGapFraction * (shownRows - 1)) / shownRows) : 0.0
    float rowHeight = visSpan * rowFraction
    float rowStep = rowHeight + visSpan * rowGapFraction
    float stackHeight = rowHeight * shownRows + visSpan * rowGapFraction * math.max(shownRows - 1, 0)
    float stackTop = (visibleHigh + visibleLow) / 2 + stackHeight / 2
    float stackBottom = stackTop - stackHeight
    float volumeHeight = volumeInput ? rowHeight * VOLUME_FRACTION : 0.0
    float volumeGapHeight = volumeInput ? rowHeight * VOLUME_GAP : 0.0

    float bandTop = layoutValid ? priceLow - unit * 0.08 : na
    float bandHeight = unit * 0.3
    bool stripVolumeOn = false
    if volumeInput and layoutValid
        for k = 0 to STRIP_COUNT - 1
            Strip volumeStrip = array.get(strips, k)
            if volumeStrip.available
                for v in volumeStrip.volumes
                    if not na(v) and v > 0
                        stripVolumeOn := true
    float bandBottom = layoutValid ? bandTop - (stripVolumeOn ? bandHeight : 0.0) : na

    bool sameReference = referenceA == referenceB
    string shownState = supportedChart ? inspectionState : "Unsupported chart"
    string coverageShort = coverageState == "Observed intervals have gaps" ? "gaps" : coverageState == "Observed OHLC differs from parent" ? "differs from candle" : "continuous"
    string coverageText = coverageState == "Observed intervals have gaps" ? "1-minute data has gaps" : coverageState == "Observed OHLC differs from parent" ? "1-minute data differs from the candle" : "1-minute data complete"
    string headerText = observed ? syminfo.ticker + " · " + timeframe.period + "m · " + str.tostring(selectedCount) + " × 1-min · " + coverageShort : "CESL · " + shownState
    string resultText = shownState
    if observed
        if referencesDefault
            resultText := verdictText(shownState, coverageState, firstAIndex, firstBIndex, selectedTimesArray)
        else
            resultText := "A " + priceText(referenceA) + ", B " + priceText(referenceB) + " · " + relationshipText(shownState, coverageState, firstAIndex, firstBIndex, jumpAObserved, jumpBObserved, selectedTimesArray)
    string disclaimer = "1-minute highs and lows only · order inside a minute not visible"
    string summaryTip = headerText + "\n" + resultText + "\n• " + coverageText + "\n• " + volumeState + "\n• Volume bars: 1-minute volume only" + (unavailableNote == "" ? "" : "\n• " + unavailableNote) + "\n• Needs " + str.tostring(stripReach) + " bars of right margin; scroll the chart left if cut off\n• " + disclaimer + (useStack ? "\n• Stacked: own scale per row; read prices from the High/Low tags" : "")

    for r = 0 to REF_ROWS - 1
        setRef(array.get(refLinesA, r), array.get(refTagsA, r), false, bar_index, bar_index, na, "", aColorInput, "", label.style_label_left, tagTextColorInput)
        setRef(array.get(refLinesB, r), array.get(refTagsB, r), false, bar_index, bar_index, na, "", bColorInput, "", label.style_label_left, tagTextColorInput)
    string aName = referencesDefault ? (sameReference ? "High/Low " : "High ") : (sameReference ? "A/B " : "A ")
    string bName = referencesDefault ? "Low " : "B "
    color aColor = sameReference ? sharedColorInput : aColorInput
    string stripDisclosureBody = headerText + "\n" + resultText + "\n• " + coverageText + "\n• " + volumeState + "\n• " + disclaimer + (unavailableNote == "" ? "" : "\n• " + unavailableNote) + (useStack ? "\n• Stacked: own scale per row; the tags carry the real prices" : "")
    string stripDisclosure = "\n\n" + stripDisclosureBody
    string aTip = (referencesDefault ? (sameReference ? "High/Low " : "High ") : "Level A ") + referenceText(referenceA, firstAIndex, firstJumpAIndex, selectedTimesArray, selectedEndsArray) + (sameReference ? "\n• " + (referencesDefault ? "Low" : "Level B") + " is the same price" : "") + stripDisclosure
    string bTip = (referencesDefault ? "Low " : "Level B ") + referenceText(referenceB, firstBIndex, firstJumpBIndex, selectedTimesArray, selectedEndsArray) + stripDisclosure
    bool aOutside = observed and not stripsOff and not referencesDefault and (referenceA < parentLow or referenceA > parentHigh)
    bool bOutside = observed and not stripsOff and not referencesDefault and (referenceB < parentLow or referenceB > parentHigh)
    string levelNote = aOutside or bOutside ? "Level " + (aOutside and bOutside ? "A and B" : aOutside ? "A" : "B") + " outside this candle's range" : ""
    bool aInRange = observed and referenceA >= priceLow and referenceA <= priceHigh
    bool bInRange = observed and referenceB >= priceLow and referenceB <= priceHigh and not sameReference
    bool tagsMissing = layoutValid and not (aInRange and (bInRange or sameReference))
    string tagNote = tagsMissing ? (levelNote != "" ? levelNote : resultText) : levelNote

    float arrowSpan = visibleBars > 0 ? visibleHigh - visibleLow : na
    float arrowGap = arrowSpan * 0.01
    array<int> arrowXs = array.new<int>(STRIP_COUNT + SIDE_GROUPS, na)
    array<float> arrowTops = array.new<float>(STRIP_COUNT + SIDE_GROUPS, na)
    float tallestTop = na
    int cursor = stripGapInput
    int shownStrips = 0
    for k = 0 to STRIP_COUNT - 1
        Strip s = array.get(strips, k)
        StripDraw d = array.get(draws, k)
        int barCount = array.size(s.starts)
        bool active = layoutValid and s.available and barCount > 0
        int startX = bar_index + (useStack ? stripGapInput : cursor)
        float rowTop = useStack ? stackTop - shownStrips * rowStep : na
        float rowBottom = rowTop - rowHeight
        float maxVolume = na
        if active
            maxVolume := 0.0
            for j = 0 to barCount - 1
                float v = array.get(s.volumes, j)
                if not na(v)
                    maxVolume := math.max(maxVolume, v)
        float stripRowVolume = volumeInput and maxVolume > 0 ? volumeHeight : 0.0
        float stripRowVolumeGap = stripRowVolume > 0 ? volumeGapHeight : 0.0
        float candleBottom = useStack ? rowBottom + stripRowVolume + stripRowVolumeGap : na
        float candleHeight = useStack ? rowHeight - stripRowVolume - stripRowVolumeGap : na
        float volumeBottom = useStack ? rowBottom : bandBottom
        float volumeSpan = useStack ? stripRowVolume : bandHeight
        float captionY = (useStack ? rowBottom : bandBottom) - arrowGap
        label.set_xy(d.arrowDown, bar_index, na)
        for j = 0 to MAX_SUBBARS - 1
            box body = array.get(d.bodies, j)
            box volumeBar = array.get(d.volumeBars, j)
            line wick = array.get(d.wicks, j)
            label tip = array.get(d.tips, j)
            if active and j < barCount
                float o = array.get(s.opens, j)
                float h = array.get(s.highs, j)
                float l = array.get(s.lows, j)
                float c = array.get(s.closes, j)
                float v = array.get(s.volumes, j)
                int leftX = startX + pitch * j + 1
                int rightX = leftX + pitch - 1
                int centerX = leftX + halfBody
                float yo = mapY(o, useStack, priceLow, priceRange, candleBottom, candleHeight)
                float yh = mapY(h, useStack, priceLow, priceRange, candleBottom, candleHeight)
                float yl = mapY(l, useStack, priceLow, priceRange, candleBottom, candleHeight)
                float yc = mapY(c, useStack, priceLow, priceRange, candleBottom, candleHeight)
                bool isA = not na(s.posA) and s.posA == j
                bool isB = not na(s.posB) and s.posB == j
                color edge = isA and isB ? sharedColorInput : isA ? aColorInput : isB ? bColorInput : borderColorInput
                color directionColor = c >= o ? upBodyColorInput : downBodyColorInput
                box.set_lefttop(body, leftX, math.max(yo, yc))
                box.set_rightbottom(body, rightX, math.min(yo, yc))
                box.set_border_color(body, edge)
                box.set_border_width(body, isA or isB ? borderWidthInput + 1 : borderWidthInput)
                box.set_bgcolor(body, bodyFillInput ? directionColor : na)
                line.set_xy1(wick, h == l ? leftX : centerX, yl)
                line.set_xy2(wick, h == l ? rightX : centerX, yh)
                line.set_color(wick, bodyFillInput ? directionColor : edge)
                line.set_width(wick, borderWidthInput)
                bool volumeKnown = volumeInput and not na(v) and maxVolume > 0
                box.set_lefttop(volumeBar, leftX, volumeKnown ? volumeBottom + volumeSpan * v / maxVolume : na)
                box.set_rightbottom(volumeBar, rightX, volumeKnown ? volumeBottom : na)
                box.set_bgcolor(volumeBar, c >= o ? color.new(upBodyColorInput, 20) : color.new(downBodyColorInput, 20))
                label.set_xy(tip, centerX, (yh + yl) / 2)
                label.set_style(tip, label.style_label_center)
                label.set_text(tip, HOVER_TARGET)
                label.set_color(tip, color.new(chart.bg_color, 100))
                label.set_textcolor(tip, chart.fg_color)
                label.set_tooltip(tip, array.get(s.tips, j))
                tallestTop := na(tallestTop) ? yh : math.max(tallestTop, yh)
                bool newest = markLatestInput and j == barCount - 1
                if newest
                    array.set(arrowXs, k, centerX)
                    array.set(arrowTops, k, useStack ? rowTop : yh)
            else
                box.set_lefttop(body, bar_index, na)
                box.set_rightbottom(body, bar_index, na)
                box.set_lefttop(volumeBar, bar_index, na)
                box.set_rightbottom(volumeBar, bar_index, na)
                line.set_xy1(wick, bar_index, na)
                line.set_xy2(wick, bar_index, na)
                label.set_xy(tip, bar_index, na)
        string rowName = str.tostring(s.minutes) + "m"
        label.set_xy(d.caption, active ? (useStack ? startX - 1 : startX + int(pitch * barCount / 2)) : bar_index, active ? (useStack ? rowBottom + rowHeight / 2 : captionY) : na)
        label.set_style(d.caption, useStack ? label.style_label_right : label.style_label_up)
        label.set_text(d.caption, active ? rowName : "")
        label.set_color(d.caption, color.new(chart.bg_color, 100))
        label.set_textcolor(d.caption, laneLabelColorInput)
        if active and useStack
            int endX = startX + pitch * barCount
            setRef(array.get(refLinesA, shownStrips), array.get(refTagsA, shownStrips), aInRange, startX, endX, mapY(referenceA, true, priceLow, priceRange, candleBottom, candleHeight), aName + priceText(referenceA), aColor, aTip, label.style_label_left, aColor)
            setRef(array.get(refLinesB, shownStrips), array.get(refTagsB, shownStrips), bInRange, startX, endX, mapY(referenceB, true, priceLow, priceRange, candleBottom, candleHeight), bName + priceText(referenceB), bColorInput, bTip, label.style_label_left, bColorInput)
        if active
            cursor += pitch * barCount + separation
            shownStrips += 1

    int refLeftX = bar_index + stripGapInput
    int refRightX = bar_index + stripsEndOffset
    if layoutValid and not useStack
        setRef(array.get(refLinesA, 0), array.get(refTagsA, 0), aInRange, refLeftX, refRightX, referenceA, aName + priceText(referenceA), aColor, aTip, referenceA >= referenceB ? label.style_label_lower_left : label.style_label_upper_left, aColor)
        setRef(array.get(refLinesB, 0), array.get(refTagsB, 0), bInRange, refLeftX, refRightX, referenceB, bName + priceText(referenceB), bColorInput, bTip, referenceB > referenceA ? label.style_label_lower_left : label.style_label_upper_left, bColorInput)

    float fitSpan = visibleBars > 0 ? visibleHigh - visibleLow : na
    int sideCursor = layoutValid and not useStack ? stripsEndOffset + TAG_BARS : 0
    int sideRowIndex = layoutValid ? activeStrips : 0
    int sideStackedRows = 0
    int sideStackWidth = 0
    int blockRightX = layoutValid ? refRightX : bar_index + stripGapInput - TAG_BARS - 1
    string sideNotes = ""
    string sideTips = ""
    color panelFill = color.new(chart.fg_color, 94)
    color panelEdge = color.new(chart.fg_color, 82)
    for g = 0 to SIDE_GROUPS - 1
        Side q = array.get(sides, g)
        SideDraw sd = array.get(sideDraws, g)
        int sideN = array.size(q.times)
        int sideOffset = useStack ? stripGapInput : sideCursor + sideGapInput
        int sideBaseX = bar_index + sideOffset
        bool sideShow = q.show and (useStack or sideOffset + pitch * sideN + 2 <= MAX_SIDE_REACH)
        bool sideStacked = useStack and sideShow
        int sideMargin = sideOffset + pitch * sideN + TAG_BARS
        float sideRowTop = sideStacked ? stackTop - sideRowIndex * rowStep : na
        float sideRowBottom = sideRowTop - rowHeight
        float sideUnit = sideShow ? (q.span > 0 ? q.span : syminfo.mintick * 4) : na
        bool sideFit = sideShow and not sideStacked and fitSpan > 0 and (q.top > visibleHigh or q.low < visibleLow)
        bool sideMapped = sideStacked or sideFit
        float sideMaxVolume = sideShow and volumeInput ? array.max(q.volumes) : na
        float sideVolSpan = volumeInput and sideMaxVolume > 0 ? (sideStacked ? volumeHeight : sideFit ? fitSpan * 0.04 : sideUnit * 0.3) : 0.0
        float sideRowVolumeGap = sideVolSpan > 0 ? volumeGapHeight : 0.0
        float sideBottom = sideStacked ? sideRowBottom + sideVolSpan + sideRowVolumeGap : sideFit ? visibleLow + fitSpan * FIT_MARGIN : na
        float sideHeight = sideStacked ? rowHeight - sideVolSpan - sideRowVolumeGap : sideFit ? fitSpan * (1 - 2 * FIT_MARGIN) : na
        float sideVolTop = (sideFit ? sideBottom - fitSpan * 0.01 : q.low - sideUnit * 0.08)
        float sideVolBottom = sideStacked ? sideRowBottom : sideVolTop - sideVolSpan
        float sideCaptionY = (sideStacked ? sideRowBottom : sideVolSpan > 0 ? sideVolBottom : sideFit ? sideBottom : q.low) - arrowGap
        label.set_xy(sd.arrowDown, bar_index, na)
        for j = 0 to SIDE_MAX - 1
            box body = array.get(sd.bodies, j)
            box volumeBar = array.get(sd.volumeBars, j)
            line wick = array.get(sd.wicks, j)
            label tag = array.get(sd.tags, j)
            if sideShow and j < sideN
                float o = array.get(q.opens, j)
                float h = array.get(q.highs, j)
                float l = array.get(q.lows, j)
                float c = array.get(q.closes, j)
                int leftX = sideBaseX + pitch * j + 1
                int rightX = leftX + pitch - 1
                int centerX = leftX + halfBody
                float yo = mapY(o, sideMapped, q.low, q.span, sideBottom, sideHeight)
                float yh = mapY(h, sideMapped, q.low, q.span, sideBottom, sideHeight)
                float yl = mapY(l, sideMapped, q.low, q.span, sideBottom, sideHeight)
                float yc = mapY(c, sideMapped, q.low, q.span, sideBottom, sideHeight)
                bool newestSide = j == sideN - 1
                bool developing = q.developing and newestSide
                bool partial = q.partial and newestSide
                color directionColor = c >= o ? upBodyColorInput : downBodyColorInput
                box.set_lefttop(body, leftX, math.max(yo, yc))
                box.set_rightbottom(body, rightX, math.min(yo, yc))
                box.set_border_color(body, developing ? color.new(borderColorInput, 20) : borderColorInput)
                box.set_border_style(body, developing or partial ? line.style_dashed : line.style_solid)
                box.set_bgcolor(body, bodyFillInput ? (developing ? color.new(directionColor, 25) : directionColor) : na)
                line.set_xy1(wick, centerX, yl)
                line.set_xy2(wick, centerX, yh)
                line.set_style(wick, developing or partial ? line.style_dashed : line.style_solid)
                line.set_color(wick, bodyFillInput ? (developing ? color.new(directionColor, 25) : directionColor) : borderColorInput)
                float sideVol = array.get(q.volumes, j)
                bool sideVolumeKnown = volumeInput and not na(sideVol) and sideMaxVolume > 0
                box.set_lefttop(volumeBar, leftX, sideVolumeKnown ? sideVolBottom + sideVolSpan * sideVol / sideMaxVolume : na)
                box.set_rightbottom(volumeBar, rightX, sideVolumeKnown ? sideVolBottom : na)
                box.set_bgcolor(volumeBar, c >= o ? color.new(upBodyColorInput, 20) : color.new(downBodyColorInput, 20))
                label.set_xy(tag, centerX, (yh + yl) / 2)
                label.set_style(tag, label.style_label_center)
                label.set_text(tag, HOVER_TARGET)
                label.set_color(tag, color.new(chart.bg_color, 100))
                label.set_textcolor(tag, chart.fg_color)
                label.set_tooltip(tag, (q.frame == "D" or q.frame == "W" ? dateIntervalText(array.get(q.times, j), array.get(q.ends, j)) : intervalText(array.get(q.times, j), array.get(q.ends, j))) + " · " + syminfo.timezone + "\nVolume: " + (na(array.get(q.volumes, j)) ? "Unavailable" : volumeText(array.get(q.volumes, j))))
                tallestTop := na(tallestTop) ? yh : math.max(tallestTop, yh)
                if markLatestInput and newestSide and not q.newestOmitted
                    array.set(arrowXs, STRIP_COUNT + g, centerX)
                    array.set(arrowTops, STRIP_COUNT + g, sideStacked ? sideRowTop : yh)
            else
                box.set_lefttop(body, bar_index, na)
                box.set_rightbottom(body, bar_index, na)
                box.set_lefttop(volumeBar, bar_index, na)
                box.set_rightbottom(volumeBar, bar_index, na)
                line.set_xy1(wick, bar_index, na)
                line.set_xy2(wick, bar_index, na)
                label.set_xy(tag, bar_index, na)
                label.set_text(tag, "")
                label.set_style(tag, label.style_none)
        int sideEndX = sideBaseX + pitch * sideN
        int refRow = STRIP_COUNT + g
        string sidePillTip = sideShow ? q.frame + " candles · " + str.tostring(sideN) + " shown\n• Another time frame's history, not a forecast\n• Needs " + str.tostring(sideMargin) + " bars of right margin; scroll the chart left if cut off" + (q.omitted > 0 ? "\n• " + str.tostring(q.omitted) + " invalid candle(s) left out" : "") + (q.newestOmitted ? "\n• Newest left out (invalid data): no arrow" : "") + (q.developing ? "\n• Newest still forming: changes until it closes" : "") + (q.partial ? "\n• Newest period: data up to the last chart bar only" : "") + (q.missing ? "\n• Newest period not returned yet" : "") + (sideStacked ? "\n• Stacked: own scale; read prices from the High/Low tags" : sideFit ? "\n• Scaled to fit the view; read prices from the High/Low tags" : "") : ""
        setRef(array.get(refLinesA, refRow), array.get(refTagsA, refRow), sideShow, sideBaseX, sideEndX, mapY(q.top, sideMapped, q.low, q.span, sideBottom, sideHeight), "High " + priceText(q.top), borderColorInput, q.frame + " high of the candles shown" + (sideShow ? "\n\n" + sidePillTip : ""), sideStacked ? label.style_label_left : label.style_label_lower_left, tagTextColorInput)
        setRef(array.get(refLinesB, refRow), array.get(refTagsB, refRow), sideShow and q.span > 0, sideBaseX, sideEndX, mapY(q.low, sideMapped, q.low, q.span, sideBottom, sideHeight), "Low " + priceText(q.low), borderColorInput, q.frame + " low of the candles shown" + (sideShow ? "\n\n" + sidePillTip : ""), sideStacked ? label.style_label_left : label.style_label_upper_left, tagTextColorInput)
        sideTips += sideShow ? (sideTips == "" ? "" : "\n\n") + sidePillTip : ""
        label.set_xy(sd.header, sideShow ? (sideStacked ? sideBaseX - 1 : sideEndX) : bar_index, sideShow ? (sideStacked ? sideRowBottom + rowHeight / 2 : sideCaptionY) : na)
        label.set_text(sd.header, sideShow ? q.frame + (sideFit ? " · scaled" : "") : "")
        label.set_style(sd.header, sideStacked ? label.style_label_right : label.style_label_upper_right)
        label.set_color(sd.header, color.new(chart.bg_color, 100))
        label.set_textcolor(sd.header, laneLabelColorInput)
        bool sidePanel = panelInput and sideShow and not sideStacked
        box panelBox = array.get(panelSides, g)
        box.set_lefttop(panelBox, sideBaseX, sidePanel ? (sideFit ? sideBottom + sideHeight + fitSpan * 0.03 : q.top + sideUnit * 0.1) : na)
        box.set_rightbottom(panelBox, sideEndX + TAG_BARS - 2, sidePanel ? (sideVolSpan > 0 ? sideVolBottom - (sideFit ? fitSpan * 0.01 : sideUnit * 0.05) : sideFit ? sideBottom - fitSpan * 0.02 : q.low - sideUnit * 0.05) : na)
        box.set_bgcolor(panelBox, panelFill)
        box.set_border_color(panelBox, panelEdge)
        if sideShow
            sideCursor := sideOffset + pitch * sideN + TAG_BARS
            blockRightX := math.max(blockRightX, sideEndX)
            if sideStacked
                sideRowIndex += 1
                sideStackedRows += 1
                sideStackWidth := math.max(sideStackWidth, pitch * sideN)
        else if q.show
            sideNotes += (sideNotes == "" ? "" : "\n") + "Side candles (" + q.frame + ") need " + str.tostring(sideMargin) + " bars right of the last bar"
        else if q.frame != ""
            sideNotes += (sideNotes == "" ? "" : "\n") + "Side candles unavailable (" + q.frame + "): " + q.note

    float arrowCeiling = tallestTop
    for i = 0 to STRIP_COUNT + SIDE_GROUPS - 1
        float arrowTop = array.get(arrowTops, i)
        label.set_xy(arrowLabelAt(i), na(arrowTop) ? bar_index : array.get(arrowXs, i), na(arrowTop) ? na : useStack ? arrowTop + 2 * arrowGap : arrowCeiling + arrowGap)
        label.set_textcolor(arrowLabelAt(i), latestColorInput)

    float panelPad = useStack ? visSpan * 0.02 : 0.0
    float panelTopPad = useStack and markLatestInput ? visSpan * 0.06 : panelPad
    int stackWidth = math.max(layoutValid ? widestStrip : 0, sideStackWidth)
    bool mainPanel = panelInput and (layoutValid or sideStackedRows > 0)
    int nameBars = 2 * pitch + 2
    int mainLeft = useStack ? math.max(bar_index + 1, bar_index + stripGapInput - nameBars) : refLeftX
    int mainRight = useStack ? bar_index + stripGapInput + stackWidth + TAG_BARS : refRightX + TAG_BARS - 2
    float mainTop = useStack ? stackTop + panelTopPad : priceHigh + unit * 0.1
    float mainBottom = useStack ? stackBottom - panelPad : bandBottom - unit * 0.05
    box.set_lefttop(panelMain, mainLeft, mainPanel ? mainTop : na)
    box.set_rightbottom(panelMain, mainRight, mainPanel ? mainBottom : na)
    box.set_bgcolor(panelMain, panelFill)
    box.set_border_color(panelMain, panelEdge)

    string hintText = not supportedChart ? "Standard 5–60 minute charts only" : ""
    bool summaryOn = showTextInput and layoutValid
    bool headerOn = layoutValid and (showTextInput or unavailableNote != "")
    label.set_xy(headerLabel, headerOn ? refLeftX : bar_index, headerOn ? mainTop + (useStack ? visSpan * 0.01 : 0.0) : na)
    label.set_text(headerLabel, summaryOn ? headerText + "\n" + resultText + "\n" + disclaimer + (unavailableNote == "" ? "" : "\n" + unavailableNote) : headerOn ? unavailableNote : "")
    label.set_textcolor(headerLabel, noteTextColorInput)
    label.set_tooltip(headerLabel, summaryOn ? ticker.standard(syminfo.tickerid) + "\nTimes in " + syminfo.timezone + "\n" + summaryTip + (sideTips == "" ? "" : "\n\n" + sideTips) : "")
    string statusText = layoutValid or stripsOff ? "" : "CESL · " + (blockedNote != "" ? blockedNote : shownState) + (hintText == "" ? "" : "\n" + hintText)
    statusText += layoutValid or unavailableNote == "" ? "" : (statusText == "" ? "" : "\n") + unavailableNote
    statusText += sideNotes == "" ? "" : (statusText == "" ? "" : "\n") + sideNotes
    statusText += tagNote == "" ? "" : (statusText == "" ? "" : "\n") + tagNote
    label.set_xy(statusLabel, statusText == "" ? bar_index : math.min(blockRightX + TAG_BARS + 1, bar_index + MAX_SIDE_REACH), statusText == "" ? na : close)
    label.set_text(statusLabel, statusText)
    label.set_tooltip(statusLabel, observed and not stripsOff ? stripDisclosureBody : "")
    // Drawings anchor at bar centres: the outline spans the previous to the next bar.
    bool outlineOn = observed and not stripsOff and parentOnInput
    box.set_lefttop(outlineBox, observed ? parentIndex - 1 : bar_index, outlineOn ? parentHigh : na)
    box.set_rightbottom(outlineBox, observed ? parentIndex + 1 : bar_index, outlineOn ? parentLow : na)
    box.set_border_color(outlineBox, parentColorInput)
    box.set_border_width(outlineBox, parentWidthInput)
    box.set_bgcolor(outlineBox, parentFillInput ? color.new(parentColorInput, 85) : na)
````
