<!-- tradingview-pine-id: PUB;d4664f160feb4a2095c11a16ff7613e7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# PO3 Candle (M1D)

Source: https://www.tradingview.com/script/5euQMqvk-Minimalistic-Po3-M1D/

## Description

Minimalistic Po3 (M1D) 
Draws the current higher timeframe candle once to the right of price, so the accumulation, manipulation and distribution taking place inside it can be read against your execution chart without switching timeframes.

One candle only — the live one. It is rebuilt on every tick of the last bar and never left behind as history, so the chart never accumulates old projections. Four dotted reference lines carry its open, high, low and close back to the bar that opened it, and each price is named at the candle's right edge, so the levels that candle is building from are on your chart at the prices they actually sit at.

Why one candle

A higher-timeframe candle is a whole session of intent compressed into one shape. On a low timeframe that shape is what you are trading inside of, but you cannot see it — you either flip timeframes and lose your place, or you keep a second chart and split your attention. Drawing the one candle you are inside of, beside live price, puts that context on the chart you are already executing on. It is deliberately one candle and no history: a chart full of past projections is a chart you stop reading.

What it draws

THE CANDLE — the forming higher-timeframe candle, body and wick, projected clear of live price with an adjustable gap and width. Up and down bodies take their own colours and the outline and wick are drawn separately, so it reads cleanly on a light or a dark chart.

OPEN / HIGH / LOW / CLOSE LINES — one dotted line per price, running from the bar that opened the candle out to the drawn one. These are the levels the candle is dealing between while it forms.

OPEN DIVIDER — a dotted vertical at the bar that opened the candle, joining the high and low lines so the whole period reads as one zone. It can run the full height of the pane like a session divider, or stop at the candle's high and low.

PRICE TAGS — the four prices named at the right edge of the drawn candle, so you can read the level without hovering.

CONSOLE — the timeframe in use, the time left in the candle, and its range so far. It also tells you when nothing is being drawn and why.

How to use it

Pick the timeframe you take your bias from and leave it there — the candle is context, not a signal, and changing it mid-session changes the story you are reading.

The open line is the reference the period is being measured from: price above it and price below it are two different days. The high and low are the extremes taken so far, and the divider marks where the period began, so a sweep of one side and a return inside the body is visible as it happens rather than after the candle closes.

The countdown tells you how much of the period is left. The same displacement means something different with five hours to run than it does with ten minutes.

Settings worth knowing

Timeframe is 4H by default, with 15m, 1H, 4H, 1D and 1W available.

The chart timeframe must be below the chosen candle timeframe. If it is not, nothing is drawn and the console says so rather than leaving you looking at an empty chart wondering.

Gap from live price, candle width, body and outline colours, line colour, divider height, price tags, text size and console corner are all adjustable. Every element can be turned off on its own.

How it differs from a plain higher-timeframe overlay

The candle is built from your chart's own bars as they print, not requested as a finished higher-timeframe bar, so it is the candle in progress from the first bar of the load rather than the last closed one. Its levels are carried back to the bar that opened the period instead of only being drawn beside it, so they are usable as levels on the chart you are executing on. And it draws exactly one, always the live one, with no history retained.

Notes

The drawn candle is the FORMING one and updates live, which is the point of it — you are watching that timeframe build. Its history is not kept: this shows you the candle in progress, not a record of previous ones.

The countdown reads --:-- when there is no live tick to count against, such as a closed market.

Everything drawn is context. There are no entries, no exits, no directional calls and no performance claims.

This is a market-analysis tool, not financial advice. Past market behaviour does not indicate future results. Test any tool thoroughly and trade your own plan.

---

## Source Code

````pine
//@version=6
// ============================================================================
// PO3 Candle (M1D)
// ----------------------------------------------------------------------------
// The current higher-timeframe candle, drawn once, to the right of price, so
// the accumulation / manipulation / distribution of that candle can be read
// against the chart timeframe without switching charts.
//
// One candle only - the live one. It is rebuilt on every tick of the last bar
// and never left behind as history. Four dotted reference lines carry its
// open, high, low and close back to the bar that opened it, and each price is
// named at the candle's right edge. A small console reads the timeframe, the
// time left in the candle and its range.
//
// Default 4H; 15m, 1H, 4H, 1D and 1W available. Nothing is drawn when the
// chart timeframe is not below the chosen one, and the console says so.
// ============================================================================
indicator("PO3 Candle (M1D)", "PO3 Candle (M1D)", overlay = true, max_lines_count = 50, max_labels_count = 50, max_boxes_count = 10)

// == CONSTANTS ===============================================================

//@variable Build stamp - bump on every edit. Printed to the Pine Logs pane, which is private to
// whoever has the script open. NEVER in the shorttitle: that is chart furniture he looks at all
// day and he removed one himself (2026-08-20). b5 had it there; b6 moved it here.
const string BUILD = "b7"
if barstate.isfirst
    log.info("PO3 Candle (M1D) BUILD " + BUILD)
//@variable Milliseconds in one chart bar
int msPerBar = timeframe.in_seconds() * 1000

// Every drawing here is anchored with xloc.bar_time, and the anchor is the HTF candle's OPEN time -
// which on a low chart timeframe sits a long way back. To place a time on a bar the drawing engine
// walks the `time` series back to it, and Pine had auto-sized that buffer to 1700 bars: a 4H candle on
// a 1m chart, or a 1D candle on a 5m, asks for one more than that and the script dies mid-session
// ("requested historical offset (1700) is beyond the historical buffer's limit (1699)"). The function
// form buffers `time` ALONE, not every series in the security tuple, which is what the declaration form
// would have done.
max_bars_back(time, 5000)

// == INPUTS ==================================================================

string tfChoice   = input.string("4H", "Candle timeframe", options = ["15m", "1H", "4H", "1D", "1W"], group = "Candle")
int    candleGap  = input.int(10, "Gap from live candle (bars)", minval = 1, maxval = 500, group = "Candle", tooltip = "How many chart bars of clear space sit between the last candle and the drawn one.")
int    candleWide = input.int(6, "Candle width (bars)", minval = 1, maxval = 100, group = "Candle")
color  bullColor  = input.color(#FFFFFF, "Up body", group = "Candle", inline = "col")
color  bearColor  = input.color(#4A4A4A, "Down body", group = "Candle", inline = "col")
color  edgeColor  = input.color(#000000, "Outline / wick", group = "Candle")

bool   showLevels = input.bool(true, "Open / high / low / close lines", group = "Levels", tooltip = "Dotted lines from the bar that opened the candle to the drawn candle, one per price.")
color  lineColor  = input.color(color.new(#000000, 0), "Line colour", group = "Levels")
bool   showDivider = input.bool(true, "Open divider", group = "Levels", tooltip = "A dotted vertical line at the bar that opened the candle, joining the high and low lines so the whole thing reads as one zone of that timeframe.")
bool   fullDivider = input.bool(true, "Divider runs full height", group = "Levels", tooltip = "On: the divider extends through the whole pane like a session divider. Off: it stops at the high and low.")
bool   showPrices = input.bool(true, "Price tags", group = "Levels", tooltip = "The four prices, named at the right edge of the drawn candle.")
string labelSizeIn = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = "Levels")

bool   showConsole = input.bool(true, "Console", group = "Console", tooltip = "Timeframe, time left in the candle, and its range so far.")
string consolePos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = "Console")

// == HELPERS =================================================================

//@function Resolves the friendly timeframe choice to a Pine timeframe string
//@param choice (string) One of the input options
//@returns (string) Pine timeframe
resolveTf(string choice) => switch choice
    "15m" => "15"
    "1H"  => "60"
    "4H"  => "240"
    "1D"  => "D"
    =>       "W"

//@function Resolves the text-size input to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal"
//@returns (string) Matching size.* constant
resolveSize(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    =>          size.small

//@function Resolves the console position input to a table position constant
//@param posName (string) One of the position options
//@returns (string) Matching position.* constant
resolvePos(string posName) => switch posName
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    =>                position.top_right

//@function Formats a millisecond span as a countdown
//@param ms (int) Milliseconds remaining
//@returns (string) "hh:mm:ss", prefixed with days when over a day
fmtCountdown(int ms) =>
    int totalSec = math.max(math.floor(ms / 1000), 0)
    int days  = math.floor(totalSec / 86400)
    int hrs   = math.floor((totalSec % 86400) / 3600)
    int mins  = math.floor((totalSec % 3600) / 60)
    int secs  = totalSec % 60
    string hhmmss = str.format("{0,number,00}:{1,number,00}:{2,number,00}", hrs, mins, secs)
    days > 0 ? str.tostring(days) + "d " + hhmmss : hhmmss

// == DATA ====================================================================

string htfTf    = resolveTf(tfChoice)
string labelSize = resolveSize(labelSizeIn)

//@variable True when the chart timeframe is below the chosen candle timeframe
bool tfValid = timeframe.in_seconds() < timeframe.in_seconds(htfTf)

// The developing candle: on the last bar request.security returns the live
// higher-timeframe values, which is exactly what a PO3 candle is.
[htfOpen, htfHigh, htfLow, htfClose, htfTime, htfCloseTime] = request.security(syminfo.tickerid, htfTf, [open, high, low, close, time, time_close])

// == DRAWINGS (last bar only, rebuilt in place) ==============================

var box   body    = na
var line  wickUp  = na
var line  wickDn  = na
var line  lvlOpen = na
var line  lvlHigh = na
var line  lvlLow  = na
var line  lvlClose = na
var line  divider  = na
var label tagOpen  = na
var label tagHigh  = na
var label tagLow   = na
var label tagClose = na
var table console  = table.new(resolvePos(consolePos), 1, 3, frame_color = color.new(#000000, 0), frame_width = 1, border_color = color.new(#000000, 0), border_width = 1)

//@function Creates a level line once, then moves it
//@param existing (line)  The stored handle, na on first call
//@param x1       (int)   Left time
//@param x2       (int)   Right time
//@param price    (float) The level
//@returns (line) The live handle
placeLevel(line existing, int x1, int x2, float price) =>
    line handle = existing
    if na(handle)
        handle := line.new(x1, price, x2, price, xloc = xloc.bar_time, color = lineColor, width = 1, style = line.style_dotted)
    else
        line.set_xy1(handle, x1, price)
        line.set_xy2(handle, x2, price)
    handle

//@function Creates a price tag once, then moves it
//@param existing (label) The stored handle, na on first call
//@param x        (int)   Anchor time
//@param price    (float) The level
//@returns (label) The live handle
placeTag(label existing, int x, float price) =>
    label handle = existing
    string txt = str.tostring(price, format.mintick)
    if na(handle)
        handle := label.new(x, price, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = lineColor, size = labelSize, textalign = text.align_left)
        label.set_text_font_family(handle, font.family_monospace)
    else
        label.set_xy(handle, x, price)
        label.set_text(handle, txt)
    handle

if barstate.islast and tfValid
    int   leftX   = time + candleGap * msPerBar
    int   rightX  = leftX + candleWide * msPerBar
    int   midX    = leftX + math.round(candleWide * msPerBar / 2)
    bool  isBull  = htfClose >= htfOpen
    color bodyCol = isBull ? bullColor : bearColor
    float bodyTop = math.max(htfOpen, htfClose)
    float bodyBot = math.min(htfOpen, htfClose)

    // Body - a candle IS a block, so it shows a hard black edge; the fill says direction.
    if na(body)
        body := box.new(leftX, bodyTop, rightX, bodyBot, xloc = xloc.bar_time, border_color = edgeColor, border_width = 1, bgcolor = bodyCol)
    else
        box.set_lefttop(body, leftX, bodyTop)
        box.set_rightbottom(body, rightX, bodyBot)
        box.set_bgcolor(body, bodyCol)

    // Wicks - from the body to each extreme, up the centre of the body.
    if na(wickUp)
        wickUp := line.new(midX, bodyTop, midX, htfHigh, xloc = xloc.bar_time, color = edgeColor, width = 1)
        wickDn := line.new(midX, bodyBot, midX, htfLow,  xloc = xloc.bar_time, color = edgeColor, width = 1)
    else
        line.set_xy1(wickUp, midX, bodyTop)
        line.set_xy2(wickUp, midX, htfHigh)
        line.set_xy1(wickDn, midX, bodyBot)
        line.set_xy2(wickDn, midX, htfLow)

    // Reference lines - each price carried back to the bar that opened the candle.
    // Open and close meet the body's left edge; high and low run on to the wick itself.
    if showLevels
        lvlOpen  := placeLevel(lvlOpen,  htfTime, leftX, htfOpen)
        lvlHigh  := placeLevel(lvlHigh,  htfTime, midX, htfHigh)
        lvlLow   := placeLevel(lvlLow,   htfTime, midX, htfLow)
        // The close is the live price, so its line runs only from the live candle to the
        // drawn one - a lead, not a level. Dragging it back to the open would just trace
        // the current price across the whole candle.
        lvlClose := placeLevel(lvlClose, time, leftX, htfClose)

    // Open divider - the left wall of the zone, at the bar that opened the candle.
    if showDivider
        if na(divider)
            divider := line.new(htfTime, htfHigh, htfTime, htfLow, xloc = xloc.bar_time, color = lineColor, width = 1, style = line.style_dotted, extend = fullDivider ? extend.both : extend.none)
        else
            line.set_xy1(divider, htfTime, htfHigh)
            line.set_xy2(divider, htfTime, htfLow)

    // Price tags at the candle's right edge.
    if showPrices
        tagOpen  := placeTag(tagOpen,  rightX, htfOpen)
        tagHigh  := placeTag(tagHigh,  rightX, htfHigh)
        tagLow   := placeTag(tagLow,   rightX, htfLow)
        tagClose := placeTag(tagClose, rightX, htfClose)

// == CONSOLE =================================================================
// Verdict first: the timeframe, then the time left, then the range. When the
// chart timeframe is too high the single row says so instead of staying silent.

if barstate.islast and showConsole
    color ink = color.new(#000000, 0)
    color bg  = color.new(color.white, 0)
    if tfValid
        table.cell(console, 0, 0, tfChoice + " CANDLE PO3", text_color = ink, bgcolor = bg, text_size = size.small, text_font_family = font.family_monospace, text_formatting = text.format_bold)
        table.cell(console, 0, 1, fmtCountdown(htfCloseTime - timenow), text_color = ink, bgcolor = bg, text_size = size.small, text_font_family = font.family_monospace)
        table.cell(console, 0, 2, "Range " + str.tostring(htfHigh - htfLow, format.mintick), text_color = ink, bgcolor = bg, text_size = size.small, text_font_family = font.family_monospace)
    else
        table.cell(console, 0, 0, "PO3 - chart must be below " + tfChoice, text_color = color.new(#DB1D9C, 0), bgcolor = bg, text_size = size.small, text_font_family = font.family_monospace)
        table.cell(console, 0, 1, "", bgcolor = color.new(color.white, 100))
        table.cell(console, 0, 2, "", bgcolor = color.new(color.white, 100))
````
