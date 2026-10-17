# Macro Candles+ (M1D)

- url: https://www.tradingview.com/script/G0Y5c2yI-Macro-Candles-M1D/
- type: indicator
- pine_id: PUB;50301e7b64274e0d97a778a9eb6a58f7
- version: 2.0

## Description

Macro Candles+ 
Colours the candles that print inside each ICT macro window and grades every macro against the one before it. A macro runs from ten minutes before the hour to ten minutes after it, New York time. Inside the window the candles take the macro's colour; outside it the chart's own candles show untouched. It draws nothing else: one dotted line at each macro's open and one dot carrying the reading.

[b]What it does[/b]

[b]1 · The window.[/b] Every macro is XX:50 to XX+1:10 on the New York clock, resolved through the exchange-independent time zone so it stays true across daylight saving on any symbol. A macro exists only if its opening candle printed. Around a session close the last candles of one hour can run straight into the first candles of a later one with nothing between them; those candles belong to a window that never opened and are left alone.

[b]2 · The grade.[/b] Each macro opens against the previous macro's high and low. Opening above that high grades it bullish, opening below that low grades it bearish, and opening inside the range grades it consolidation. The grade is set on the opening candle and held.

[b]3 · The re-grade.[/b] A macro can change its grade once. One that opened above the previous high turns bearish on the first candle that closes back below that high, and one that opened below the previous low turns bullish on the first close back above it. A consolidation macro turns bearish on the first close below the previous low and bullish on the first close above its high. Candles already printed keep the colour they had, so the candle where the grade changed stays visible. One change per macro, then it holds to the close.

[b]4 · The candles.[/b] Body, border and wick take the macro's colour, so a coloured run reads at any zoom. The wick can be set to its own colour instead. Two other colour modes are available: each candle in its own up or down colour, or every macro candle in one colour.

[b]5 · The open line and the dot.[/b] One dotted vertical at each macro open. Beside it, a small dot in the macro's colour: above price for a bearish or consolidation macro, below price for a bullish one, sitting a set distance clear of the surrounding candles and stepping away from any candle that later reaches it. Hovering the dot shows the reading in words, and a re-grade recolours the dot, moves it to the other side of price and rewrites the reading.

[b]6 · Which macros.[/b] Every hour by default. Spacing shows a macro every two, three or up to twelve hours, counted from midnight New York, and each of the twenty-four opening hours has its own switch on top of that.

[b]Visual grammar[/b]

Bullish is blue, bearish is red and consolidation is a dark grey, all three adjustable. The open line is a neutral grey dotted line of width one. Nothing carries a background or a text label; the dot is the only marker, and its reading lives in the hover.

[b]Method & repainting[/b]

The opening grade is read from the opening candle's open and never revised. A re-grade evaluates on confirmed candles only, so a colour change is never undone by a later tick. The previous macro's high and low are its full range, wick to wick, and the first macro on a loaded chart has no previous range to read against, so it stays uncoloured. On one-hour and higher charts a twenty-minute window has no candle to colour; the script draws nothing and says so in a small corner note.

[b]Settings[/b]

Colour mode, bullish, bearish and consolidation colours, the re-grade switch, candle colouring on or off, wick colour; the open line, its colour and width; the bias dot, its cushion from price and its size; spacing in hours, history in days, and a switch for each of the twenty-four hours.

Built by M1D. For education and study of price delivery — not financial advice.

## Source Code

````pine
//@version=6
// © mayb1dayy
indicator("Macro Candles+ (M1D)", shorttitle = "Macro Candles+ (M1D)", overlay = true, max_lines_count = 500, max_labels_count = 500)

// Colours every candle that prints inside an ICT macro window (XX:50 to XX+1:10, New York) and
// marks each window with one dotted vertical line at its open and a dot carrying its grade. A
// macro is graded once, at its open, against the previous macro's range: bullish when it opens
// above that high, bearish when it opens below that low, consolidation when it opens inside. The
// grade holds to the close and nothing repaints. Outside a window the chart's own candles show. A
// window the bar stream breaks inside, at the futures halt or a session close, is not a macro.
// Spacing picks a macro every N hours counted from midnight New York (an engineering choice, not
// doctrine), and each clock hour can be switched off on its own. Works on every timeframe below
// one hour; on 1H and above a twenty-minute window has no candle to colour, so nothing draws.

const string TZ       = "America/New_York"
const color  C_INK    = #000000
const color  C_CLEAR  = #FFFFFF
const int    DAY_MS   = 24 * 60 * 60 * 1000
const int    MAX_OBJ  = 480
const int    LIFT_BARS = 15
// A break in the bar stream long enough to be a closed session rather than a thin patch. The
// shortest real break on any instrument this draws on is the CME's 60-minute daily halt; the
// longest hole inside a live session is a few blank minutes on a thin contract. 30 minutes sits
// clear of both, so it separates "the market was shut" from "nothing traded for a moment".

// ═════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═════════════════════════════════════════════════════════════════════════════

string G_CANDLE = "Macro candles"
int    macroMaxTf = input.int(15, "Highest chart timeframe (minutes)", minval = 1, maxval = 59, group = G_CANDLE, tooltip = "The script draws on this chart timeframe and everything below it, and stays off above it. A macro window is twenty minutes, so 1m and 5m read best.")
string colMode  = input.string("Vs previous macro", "Colour by", options = ["Vs previous macro", "Per candle", "One colour"], group = G_CANDLE, tooltip = "Vs previous macro: graded once, at the macro's open. Bullish when it opens above the previous macro's high, bearish when it opens below its low, grey (consolidation) when it opens inside that range. The grade holds to the close and never changes. Per candle: each candle's own up or down. One colour: every macro candle takes the bullish colour.")
color  upCol    = input.color(#1E88E5, "Bullish",  group = G_CANDLE, inline = "c", tooltip = "Body, wick and border all take this colour.")
color  dnCol    = input.color(#E53935, "Bearish",  group = G_CANDLE, inline = "c")
color  flatCol  = input.color(#5C5C5C, "Consolidation", group = G_CANDLE, inline = "c")
bool   paintOn  = input.bool(true, "Colour the candles", group = G_CANDLE)

string G_LINES  = "Macro lines"
bool   linesOn  = input.bool(true, "Open line", group = G_LINES, tooltip = "One dotted vertical at the macro open (XX:50). The colour stopping is the close.")
color  lineCol  = input.color(#787B86, "Colour", group = G_LINES, inline = "l")
int    lineW    = input.int(1, "Width", minval = 1, maxval = 3, group = G_LINES, inline = "l")
bool   tagsOn   = input.bool(true, "Grade dot", group = G_LINES, tooltip = "A dot on the open line in the macro's colour: above price for a bearish macro, below for a bullish one, above for consolidation. Hover it for the reading.")
float  cushion  = input.float(1.0, "Dot cushion (× ATR14)", minval = 0.25, maxval = 1.5, step = 0.25, group = G_LINES, tooltip = "How far clear of the surrounding candles the dot sits. Kept at or under 1.5 so the dots do not stretch the price scale.")
int    dotPts   = input.int(5, "Dot size (points)", minval = 2, maxval = 20, group = G_LINES)

string G_WHICH  = "Which macros"
int    spacing  = input.int(1, "Spacing (hours)", minval = 1, maxval = 12, group = G_WHICH, tooltip = "H1 shows every hour's macro. H2 every second hour, H3 every third, and so on up to H12. Spacing counts from midnight New York, so H4 shows the 00:50, 04:50, 08:50 and 20:50 windows.")
int    daysBack = input.int(5, "History (days)", minval = 1, maxval = 60, group = G_WHICH, tooltip = "How many days of macro lines and tags stay on the chart. Candle colour is not limited by this.")

string G_HOURS  = "Hours (New York, the hour the macro opens in)"
bool h00 = input.bool(true, "00", group = G_HOURS, inline = "r1")
bool h01 = input.bool(true, "01", group = G_HOURS, inline = "r1")
bool h02 = input.bool(true, "02", group = G_HOURS, inline = "r1")
bool h03 = input.bool(true, "03", group = G_HOURS, inline = "r1")
bool h04 = input.bool(true, "04", group = G_HOURS, inline = "r1")
bool h05 = input.bool(true, "05", group = G_HOURS, inline = "r1")
bool h06 = input.bool(true, "06", group = G_HOURS, inline = "r2")
bool h07 = input.bool(true, "07", group = G_HOURS, inline = "r2")
bool h08 = input.bool(true, "08", group = G_HOURS, inline = "r2")
bool h09 = input.bool(true, "09", group = G_HOURS, inline = "r2")
bool h10 = input.bool(true, "10", group = G_HOURS, inline = "r2")
bool h11 = input.bool(true, "11", group = G_HOURS, inline = "r2")
bool h12 = input.bool(true, "12", group = G_HOURS, inline = "r3")
bool h13 = input.bool(true, "13", group = G_HOURS, inline = "r3")
bool h14 = input.bool(true, "14", group = G_HOURS, inline = "r3")
bool h15 = input.bool(true, "15", group = G_HOURS, inline = "r3")
bool h16 = input.bool(true, "16", group = G_HOURS, inline = "r3")
bool h17 = input.bool(true, "17", group = G_HOURS, inline = "r3")
bool h18 = input.bool(true, "18", group = G_HOURS, inline = "r4")
bool h19 = input.bool(true, "19", group = G_HOURS, inline = "r4")
bool h20 = input.bool(true, "20", group = G_HOURS, inline = "r4")
bool h21 = input.bool(true, "21", group = G_HOURS, inline = "r4")
bool h22 = input.bool(true, "22", group = G_HOURS, inline = "r4")
bool h23 = input.bool(true, "23", group = G_HOURS, inline = "r4")

// ═════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═════════════════════════════════════════════════════════════════════════════

//@function Whether the macro opening in a given New York hour is switched on.
//@param h (int) The hour, 0 to 23.
//@returns (bool) True when that hour's toggle is on and it lands on the spacing grid.
f_hourOn(int h) =>
    bool toggled = switch h
        0  => h00
        1  => h01
        2  => h02
        3  => h03
        4  => h04
        5  => h05
        6  => h06
        7  => h07
        8  => h08
        9  => h09
        10 => h10
        11 => h11
        12 => h12
        13 => h13
        14 => h14
        15 => h15
        16 => h16
        17 => h17
        18 => h18
        19 => h19
        20 => h20
        21 => h21
        22 => h22
        =>    h23
    toggled and h % spacing == 0

//@function Drops the oldest line while a store is over its cap.
//@param store (array<line>) The store.
f_pruneLines(array<line> store) =>
    while store.size() > MAX_OBJ
        line.delete(store.shift())

//@function Drops the oldest label while a store is over its cap.
//@param store (array<label>) The store.
f_pruneLabels(array<label> store) =>
    while store.size() > MAX_OBJ
        label.delete(store.shift())

// ═════════════════════════════════════════════════════════════════════════════
//  THE MACRO CLOCK
// ═════════════════════════════════════════════════════════════════════════════

bool   tfOk    = timeframe.isintraday and timeframe.in_seconds() <= macroMaxTf * 60
int    nyHour  = hour(time, TZ)
int    nyMin   = minute(time, TZ)

// The hour whose macro this bar sits in: the :50–:59 part belongs to this clock hour, the
// :00–:09 part to the hour before it. A candle is named by its open, so the :09 candle is the
// last one inside: it closes at :10.
bool   tail     = nyMin >= 50
bool   head     = nyMin < 10
int    macroHr  = tail ? nyHour : head ? (nyHour + 23) % 24 : -1
bool   clockOn  = tfOk and macroHr >= 0 and f_hourOn(macroHr)

// A macro is twenty minutes of continuous trade. Where the bar stream breaks inside a window, at
// the futures halt or a session close, the :50 candles on one side and the :00 candles on the other
// are not one macro, so neither half is one. A break is a gap of more than thirty minutes between
// bars: a quiet minute with no trade drops a bar on a 1m chart and is not a break. The :00 half is
// known at once: its first bar arrives after a break. The :50 half cannot see the halt ahead, so
// the script remembers each clock hour a break has been seen in and leaves that hour alone from
// then on - the hour whose :00 candles arrived late, and the hour whose :50 candles ran into it.
bool   broken     = bar_index > 0 and time - time[1] > 30 * 60 * 1000
var array<bool> hourBreaks = array.new<bool>(24, false)
if head and broken and macroHr >= 0
    hourBreaks.set(macroHr, true)
    if tail[1] and macroHr[1] >= 0
        hourBreaks.set(macroHr[1], true)
bool   onClock  = clockOn and not hourBreaks.get(macroHr >= 0 ? macroHr : 0)

// The window's own timestamp. Stepping the bar time back ten minutes lands every macro bar inside
// the clock hour the macro opened in, so the calendar day and hour read straight off it.
int    ref        = time - 10 * 60 * 1000
int    macroOpen  = onClock ? timestamp(TZ, year(ref, TZ), month(ref, TZ), dayofmonth(ref, TZ), hour(ref, TZ), 50, 0) : na
bool   inMacro    = onClock

// ═════════════════════════════════════════════════════════════════════════════
//  CANDLES
// ═════════════════════════════════════════════════════════════════════════════

// The previous macro's range is what this one opens against. The grade is decided once, on the
// macro's first bar, and held to the close.
var float  prevHi = na
var float  prevLo = na
var float  curHi  = na
var float  curLo  = na
var int    grade  = na        // 1 bullish · -1 bearish · 0 consolidation · na not graded
var string gradeNote   = ""
bool  newMacro  = inMacro and (not inMacro[1] or macroOpen != macroOpen[1])
bool  macroDone = not inMacro and inMacro[1]

if macroDone
    prevHi := curHi
    prevLo := curLo
if newMacro
    curHi := high
    curLo := low
    if na(prevHi)
        grade := na
        gradeNote  := "Not graded: no previous macro to read against"
    else if open > prevHi
        grade := 1
        gradeNote  := "Bullish: opened above the previous macro's high"
    else if open < prevLo
        grade := -1
        gradeNote  := "Bearish: opened below the previous macro's low"
    else
        grade := 0
        gradeNote  := "Consolidation: opened inside the previous macro's range"
else if inMacro
    curHi := math.max(curHi, high)
    curLo := math.min(curLo, low)

color gradeCol  = na(grade) ? color(na) : grade == 1 ? upCol : grade == -1 ? dnCol : flatCol
color candleCol = switch
    not paintOn or not inMacro   => na
    colMode == "Per candle"      => close > open ? upCol : dnCol
    colMode == "One colour"      => upCol
    =>                              gradeCol
barcolor(candleCol, title = "Macro candle colour")

// ═════════════════════════════════════════════════════════════════════════════
//  OPEN LINE AND GRADE DOT — both at the macro's open
// ═════════════════════════════════════════════════════════════════════════════

var array<line>  lineStore = array.new<line>(0)
var array<label> tagStore  = array.new<label>(0)
var array<int>   tagBorn   = array.new<int>(0)
var array<bool>  tagSide   = array.new<bool>(0)
var int          lastOpen  = na

float atr     = ta.atr(14)
float hi15    = ta.highest(high, 15)
float lo15    = ta.lowest(low, 15)
bool  recent  = time >= last_bar_time - daysBack * DAY_MS

if inMacro and recent and linesOn and (na(lastOpen) or macroOpen != lastOpen)
    lastOpen := macroOpen
    lineStore.push(line.new(macroOpen, low, macroOpen, high, xloc = xloc.bar_time, extend = extend.both, color = lineCol, style = line.style_dotted, width = lineW))
    f_pruneLines(lineStore)

if newMacro and recent and tagsOn
    bool  above = grade != 1
    float pad   = atr * cushion
    float dotY  = above ? hi15 + pad : lo15 - pad
    color dotC  = na(gradeCol) ? lineCol : gradeCol
    label dot = label.new(macroOpen, dotY, "", xloc = xloc.bar_time, style = label.style_circle, color = dotC, size = dotPts, tooltip = gradeNote)
    tagStore.push(dot)
    tagBorn.push(bar_index)
    tagSide.push(above)
    f_pruneLabels(tagStore)
    while tagBorn.size() > tagStore.size()
        tagBorn.shift()
        tagSide.shift()

// Self-lift: a fresh dot moves away from any candle that reaches it, then freezes as history.
if tagStore.size() > 0
    float pad = atr * cushion
    for i = tagStore.size() - 1 to 0
        if bar_index - tagBorn.get(i) > LIFT_BARS
            break
        label dot   = tagStore.get(i)
        bool  above = tagSide.get(i)
        float y     = label.get_y(dot)
        if above and high + pad > y
            label.set_y(dot, high + pad)
        else if not above and low - pad < y
            label.set_y(dot, low - pad)

// ═════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME NOTE
// ═════════════════════════════════════════════════════════════════════════════

var table tfNote = na
if barstate.islast and not tfOk
    if na(tfNote)
        tfNote := table.new(position.top_center, 1, 1, bgcolor = C_CLEAR, frame_color = C_INK, frame_width = 1)
    table.cell(tfNote, 0, 0, " Macro Candles+ is off above " + str.tostring(macroMaxTf) + "m (Highest chart timeframe) \n A macro window is 20 minutes - 1m or 5m reads best ", text_color = C_INK, text_size = size.normal, text_font_family = font.family_monospace)
````
