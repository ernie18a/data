# Session Highs and Lows - Fully Customizable + Session Markers

- url: https://www.tradingview.com/script/4I7EyO30-Session-Highs-and-Lows-Fully-Customizable-Session-Markers/
- type: indicator
- pine_id: PUB;12a5a6cb7be44fc7bdf384c4326a5301
- version: 1.0

## Description

Session Highs & Lows + Market Time Markers

A TradingView Pine Script indicator designed to clearly track Asia, London, Pre-Market, and New York session highs and lows, while also marking key market times throughout the trading day.

The indicator is built to keep unswept session liquidity levels persistent, allowing multiple previous session highs and lows to remain visible until price actually trades through them.

🕒 Session Times

All times are based on New York time (America/New_York):

🟠 Asia: 6:00 PM – 3:00 AM
🔵 London: 3:00 AM – 8:30 AM
🔴 Pre-Market: 8:30 AM – 9:30 AM
🟢 New York: 9:30 AM – 5:00 PM

Session times are fully customizable through the indicator settings.

📈 Session High & Low Levels

At the completion of each session, the indicator plots that session's actual high and low.

The levels:

Begin at the exact candle where the session high or low was formed
Remain on the chart until price actually trades through them
Do not disappear simply because a new session begins
Allow multiple historical session levels to remain active simultaneously
Continue independently until each individual level is swept
Stop exactly on the candle that sweeps the level
Display a session label at the right edge of each active level

Opening candles can also establish a valid session high or low when they form an actual local extreme as part of the price movement.

🎯 Sweep Logic

A level is considered swept only when price trades beyond it:

High swept → High > Session High

Low swept → Low < Session Low

A simple wick that touches the level exactly does not count as a sweep.

Once price trades beyond a level, the horizontal line stops on that candle and its corresponding session label is removed.

🏷️ Session Labels

Active session levels can display labels identifying their originating session:

🟠 Asia
🔵 London
🟣 Pre-Market
🟢 New York

Labels remain attached to their corresponding levels until that level is swept.

Label visibility and size can be customized through the settings.

🎨 Visual Markers

The script uses customizable vertical markers for important market times:

6:00 PM
🟠 Orange — Asia Open

3:00 AM
🔵 Blue — London Open

8:30 AM
🔴 Red — Pre-Market

9:30 AM
🟢 Green — New York Open

15 Minutes After New York Open
🟣 Purple — First 15 Minutes

Each marker has its own:

Enable/disable setting
Color
Line style
Width
⚙️ Customization

The indicator includes settings to:

Change all session times
Enable/disable individual session highs and lows
Customize each session's line color
Customize each session's line style
Adjust session level width
Enable/disable session labels
Adjust session label size
Enable/disable individual time markers
Customize each marker's color
Customize each marker's line style
Adjust vertical marker width
💡 Designed For

This indicator can be useful for traders who use:

Liquidity levels
Session ranges
Previous session highs & lows
Liquidity sweeps
Breakouts
Reversals
FVGs
IFVGs
Order Blocks
Range trading
Price-action setups
Intraday market structure

The goal is to provide a clean and customizable view of important session liquidity levels and key intraday market times, while allowing previous unswept levels to remain on the chart rather than being automatically replaced by new session levels.

Timezone: America/New_York

## Source Code

````pine
//@version=6
indicator("Session Highs & Lows - Persistent Levels", overlay=true, max_lines_count=500, max_labels_count=500)

//====================================================
// TIME ZONE
//====================================================

string TZ = "America/New_York"

//====================================================
// SESSION TIMES
//====================================================

string ASIA      = input.session("1800-0300", "Asia Session")
string LONDON    = input.session("0300-0830", "London Session")
string PREMARKET = input.session("0830-0930", "Pre-Market Session")
string NY         = input.session("0930-1700", "New York Session")

//====================================================
// SESSION HIGH / LOW VISIBILITY
//====================================================

bool showAsia   = input.bool(true, "Show Asia High/Low")
bool showLondon = input.bool(true, "Show London High/Low")
bool showNY     = input.bool(true, "Show New York High/Low")

//====================================================
// SESSION LINE COLORS
//====================================================

color asiaLineColor      = input.color(color.orange, "Asia Line Color")
color londonLineColor    = input.color(color.blue, "London Line Color")
color preMarketLineColor = input.color(color.purple, "Pre-Market Line Color")
color nyLineColor        = input.color(color.green, "New York Line Color")

//====================================================
// SESSION LINE STYLES
//====================================================

string asiaLineStyleInput = input.string(
     "Solid",
     "Asia Line Style",
     options=["Solid", "Dashed", "Dotted"])

string londonLineStyleInput = input.string(
     "Solid",
     "London Line Style",
     options=["Solid", "Dashed", "Dotted"])

string preMarketLineStyleInput = input.string(
     "Solid",
     "Pre-Market Line Style",
     options=["Solid", "Dashed", "Dotted"])

string nyLineStyleInput = input.string(
     "Solid",
     "New York Line Style",
     options=["Solid", "Dashed", "Dotted"])

//====================================================
// CONVERT SESSION LINE STYLES
//====================================================

string asiaLineStyle = switch asiaLineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string londonLineStyle = switch londonLineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string preMarketLineStyle = switch preMarketLineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string nyLineStyle = switch nyLineStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

//====================================================
// SESSION LINE WIDTH
//====================================================

int levelWidth = input.int(
     1,
     "Session Level Width",
     minval=1,
     maxval=4)

//====================================================
// SESSION MARKER SETTINGS
//====================================================

bool showSessionMarkers = input.bool(true, "Show Session Markers")

bool showAsiaMarker      = input.bool(true, "Asia Session Start")
bool showLondonMarker    = input.bool(true, "London Session Start")
bool showPreMarketMarker = input.bool(true, "Pre-Market Session Start")
bool showNYMarker        = input.bool(true, "New York Session Start")
bool showFirst15Marker   = input.bool(true, "First 15 Minutes")

//====================================================
// SESSION MARKER COLORS
//====================================================

color asiaMarkerColor      = input.color(color.orange, "Asia Marker Color")
color londonMarkerColor    = input.color(color.blue, "London Marker Color")
color preMarketMarkerColor = input.color(color.red, "Pre-Market Marker Color")
color nyMarkerColor        = input.color(color.green, "New York Marker Color")
color first15MarkerColor   = input.color(color.purple, "First 15 Minutes Marker Color")

//====================================================
// SESSION MARKER STYLES
//====================================================

string asiaMarkerStyleInput = input.string(
     "Dotted",
     "Asia Marker Style",
     options=["Solid", "Dashed", "Dotted"])

string londonMarkerStyleInput = input.string(
     "Dotted",
     "London Marker Style",
     options=["Solid", "Dashed", "Dotted"])

string preMarketMarkerStyleInput = input.string(
     "Dotted",
     "Pre-Market Marker Style",
     options=["Solid", "Dashed", "Dotted"])

string nyMarkerStyleInput = input.string(
     "Dotted",
     "New York Marker Style",
     options=["Solid", "Dashed", "Dotted"])

string first15MarkerStyleInput = input.string(
     "Dotted",
     "First 15 Minutes Marker Style",
     options=["Solid", "Dashed", "Dotted"])

//====================================================
// CONVERT SESSION MARKER STYLES
//====================================================

string asiaMarkerStyle = switch asiaMarkerStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string londonMarkerStyle = switch londonMarkerStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string preMarketMarkerStyle = switch preMarketMarkerStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string nyMarkerStyle = switch nyMarkerStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

string first15MarkerStyle = switch first15MarkerStyleInput
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

//====================================================
// SESSION MARKER WIDTH
//====================================================

int markerWidth = input.int(
     1,
     "Session Marker Width",
     minval=1,
     maxval=4)

//====================================================
// SESSION LABEL SETTINGS
//====================================================

bool showSessionLabels = input.bool(true, "Show Session Labels")

string sessionLabelSizeInput = input.string(
     "Small",
     "Session Label Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"])

string sessionLabelSize = switch sessionLabelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

//====================================================
// SESSION DETECTION
//====================================================

bool inAsia      = not na(time(timeframe.period, ASIA, TZ))
bool inLondon    = not na(time(timeframe.period, LONDON, TZ))
bool inPreMarket = not na(time(timeframe.period, PREMARKET, TZ))
bool inNY        = not na(time(timeframe.period, NY, TZ))

bool asiaStart      = inAsia and not inAsia[1]
bool londonStart    = inLondon and not inLondon[1]
bool preMarketStart = inPreMarket and not inPreMarket[1]
bool nyStart        = inNY and not inNY[1]

//====================================================
// CALCULATE NEW YORK FIRST-15-MINUTE MARKER
//====================================================

// Extract New York session start time.
int nyStartHour = int(str.tonumber(str.substring(NY, 0, 2)))
int nyStartMinute = int(str.tonumber(str.substring(NY, 2, 4)))

// Current day's New York session start timestamp.
int nyStartTimestamp = timestamp(
     TZ,
     year(time, TZ),
     month(time, TZ),
     dayofmonth(time, TZ),
     nyStartHour,
     nyStartMinute)

// 15 minutes after New York session starts.
int first15Timestamp = nyStartTimestamp + 15 * 60 * 1000

bool first15Start =
     inNY and
     time >= first15Timestamp and
     time[1] < first15Timestamp

//====================================================
// ASIA SESSION DATA
//====================================================

var float asiaHigh = na
var float asiaLow = na

var int asiaHighBar = na
var int asiaLowBar = na

var float asiaOpeningHigh = na
var float asiaOpeningLow = na

var bool asiaOpeningHighCandidate = false
var bool asiaOpeningLowCandidate = false

var int asiaBars = 0

//====================================================
// LONDON SESSION DATA
//====================================================

var float londonHigh = na
var float londonLow = na

var int londonHighBar = na
var int londonLowBar = na

var float londonOpeningHigh = na
var float londonOpeningLow = na

var bool londonOpeningHighCandidate = false
var bool londonOpeningLowCandidate = false

var int londonBars = 0

//====================================================
// PRE-MARKET SESSION DATA
//====================================================

var float preMarketHigh = na
var float preMarketLow = na

var int preMarketHighBar = na
var int preMarketLowBar = na

var float preMarketOpeningHigh = na
var float preMarketOpeningLow = na

var bool preMarketOpeningHighCandidate = false
var bool preMarketOpeningLowCandidate = false

var int preMarketBars = 0

//====================================================
// NEW YORK SESSION DATA
//====================================================

var float nyHigh = na
var float nyLow = na

var int nyHighBar = na
var int nyLowBar = na

var float nyOpeningHigh = na
var float nyOpeningLow = na

var bool nyOpeningHighCandidate = false
var bool nyOpeningLowCandidate = false

var int nyBars = 0

//====================================================
// PERSISTENT ACTIVE LEVEL ARRAYS
//====================================================

// Asia
var array<line> asiaHighLines = array.new<line>()
var array<float> asiaHighLevels = array.new<float>()
var array<label> asiaHighLabels = array.new<label>()

var array<line> asiaLowLines = array.new<line>()
var array<float> asiaLowLevels = array.new<float>()
var array<label> asiaLowLabels = array.new<label>()

// London
var array<line> londonHighLines = array.new<line>()
var array<float> londonHighLevels = array.new<float>()
var array<label> londonHighLabels = array.new<label>()

var array<line> londonLowLines = array.new<line>()
var array<float> londonLowLevels = array.new<float>()
var array<label> londonLowLabels = array.new<label>()

// Pre-Market
var array<line> preMarketHighLines = array.new<line>()
var array<float> preMarketHighLevels = array.new<float>()
var array<label> preMarketHighLabels = array.new<label>()

var array<line> preMarketLowLines = array.new<line>()
var array<float> preMarketLowLevels = array.new<float>()
var array<label> preMarketLowLabels = array.new<label>()

// New York
var array<line> nyHighLines = array.new<line>()
var array<float> nyHighLevels = array.new<float>()
var array<label> nyHighLabels = array.new<label>()

var array<line> nyLowLines = array.new<line>()
var array<float> nyLowLevels = array.new<float>()
var array<label> nyLowLabels = array.new<label>()

//====================================================
// COLLECT ASIA HIGH / LOW
//====================================================

if asiaStart
    asiaHigh := na
    asiaLow := na

    asiaHighBar := na
    asiaLowBar := na

    asiaBars := 1

    asiaOpeningHigh := high
    asiaOpeningLow := low

    asiaOpeningHighCandidate := high > high[1]
    asiaOpeningLowCandidate := low < low[1]

else if inAsia
    asiaBars += 1

    // Confirm opening candle after the next candle.
    if asiaBars == 2
        if asiaOpeningHighCandidate and high <= asiaOpeningHigh
            asiaHigh := asiaOpeningHigh
            asiaHighBar := bar_index - 1

        if asiaOpeningLowCandidate and low >= asiaOpeningLow
            asiaLow := asiaOpeningLow
            asiaLowBar := bar_index - 1

        asiaOpeningHighCandidate := false
        asiaOpeningLowCandidate := false

    // Normal high tracking.
    if na(asiaHigh) or high > asiaHigh
        asiaHigh := high
        asiaHighBar := bar_index

    // Normal low tracking.
    if na(asiaLow) or low < asiaLow
        asiaLow := low
        asiaLowBar := bar_index

//====================================================
// COLLECT LONDON HIGH / LOW
//====================================================

if londonStart
    londonHigh := na
    londonLow := na

    londonHighBar := na
    londonLowBar := na

    londonBars := 1

    londonOpeningHigh := high
    londonOpeningLow := low

    londonOpeningHighCandidate := high > high[1]
    londonOpeningLowCandidate := low < low[1]

else if inLondon
    londonBars += 1

    // Confirm opening candle after the next candle.
    if londonBars == 2
        if londonOpeningHighCandidate and high <= londonOpeningHigh
            londonHigh := londonOpeningHigh
            londonHighBar := bar_index - 1

        if londonOpeningLowCandidate and low >= londonOpeningLow
            londonLow := londonOpeningLow
            londonLowBar := bar_index - 1

        londonOpeningHighCandidate := false
        londonOpeningLowCandidate := false

    // Normal high tracking.
    if na(londonHigh) or high > londonHigh
        londonHigh := high
        londonHighBar := bar_index

    // Normal low tracking.
    if na(londonLow) or low < londonLow
        londonLow := low
        londonLowBar := bar_index

//====================================================
// COLLECT PRE-MARKET HIGH / LOW
//====================================================

if preMarketStart
    preMarketHigh := na
    preMarketLow := na

    preMarketHighBar := na
    preMarketLowBar := na

    preMarketBars := 1

    preMarketOpeningHigh := high
    preMarketOpeningLow := low

    preMarketOpeningHighCandidate := high > high[1]
    preMarketOpeningLowCandidate := low < low[1]

else if inPreMarket
    preMarketBars += 1

    // Confirm opening candle after the next candle.
    if preMarketBars == 2
        if preMarketOpeningHighCandidate and high <= preMarketOpeningHigh
            preMarketHigh := preMarketOpeningHigh
            preMarketHighBar := bar_index - 1

        if preMarketOpeningLowCandidate and low >= preMarketOpeningLow
            preMarketLow := preMarketOpeningLow
            preMarketLowBar := bar_index - 1

        preMarketOpeningHighCandidate := false
        preMarketOpeningLowCandidate := false

    // Normal high tracking.
    if na(preMarketHigh) or high > preMarketHigh
        preMarketHigh := high
        preMarketHighBar := bar_index

    // Normal low tracking.
    if na(preMarketLow) or low < preMarketLow
        preMarketLow := low
        preMarketLowBar := bar_index

//====================================================
// COLLECT NEW YORK HIGH / LOW
//====================================================

if nyStart
    nyHigh := na
    nyLow := na

    nyHighBar := na
    nyLowBar := na

    nyBars := 1

    nyOpeningHigh := high
    nyOpeningLow := low

    nyOpeningHighCandidate := high > high[1]
    nyOpeningLowCandidate := low < low[1]

else if inNY
    nyBars += 1

    // Confirm opening candle after the next candle.
    if nyBars == 2
        if nyOpeningHighCandidate and high <= nyOpeningHigh
            nyHigh := nyOpeningHigh
            nyHighBar := bar_index - 1

        if nyOpeningLowCandidate and low >= nyOpeningLow
            nyLow := nyOpeningLow
            nyLowBar := bar_index - 1

        nyOpeningHighCandidate := false
        nyOpeningLowCandidate := false

    // Normal high tracking.
    if na(nyHigh) or high > nyHigh
        nyHigh := high
        nyHighBar := bar_index

    // Normal low tracking.
    if na(nyLow) or low < nyLow
        nyLow := low
        nyLowBar := bar_index

//====================================================
// ASIA SESSION COMPLETE
//====================================================

if londonStart and showAsia

    if not na(asiaHigh)
        line newAsiaHigh = line.new(
             x1=asiaHighBar,
             y1=asiaHigh,
             x2=bar_index,
             y2=asiaHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=asiaLineColor,
             style=asiaLineStyle,
             width=levelWidth)

        array.push(asiaHighLines, newAsiaHigh)
        array.push(asiaHighLevels, asiaHigh)

        if showSessionLabels
            label newAsiaHighLabel = label.new(
                 x=bar_index,
                 y=asiaHigh,
                 text="Asia",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=asiaLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(asiaHighLabels, newAsiaHighLabel)
        else
            array.push(asiaHighLabels, na)

    if not na(asiaLow)
        line newAsiaLow = line.new(
             x1=asiaLowBar,
             y1=asiaLow,
             x2=bar_index,
             y2=asiaLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=asiaLineColor,
             style=asiaLineStyle,
             width=levelWidth)

        array.push(asiaLowLines, newAsiaLow)
        array.push(asiaLowLevels, asiaLow)

        if showSessionLabels
            label newAsiaLowLabel = label.new(
                 x=bar_index,
                 y=asiaLow,
                 text="Asia",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=asiaLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(asiaLowLabels, newAsiaLowLabel)
        else
            array.push(asiaLowLabels, na)

//====================================================
// LONDON SESSION COMPLETE
//====================================================

if preMarketStart and showLondon

    if not na(londonHigh)
        line newLondonHigh = line.new(
             x1=londonHighBar,
             y1=londonHigh,
             x2=bar_index,
             y2=londonHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=londonLineColor,
             style=londonLineStyle,
             width=levelWidth)

        array.push(londonHighLines, newLondonHigh)
        array.push(londonHighLevels, londonHigh)

        if showSessionLabels
            label newLondonHighLabel = label.new(
                 x=bar_index,
                 y=londonHigh,
                 text="London",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=londonLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(londonHighLabels, newLondonHighLabel)
        else
            array.push(londonHighLabels, na)

    if not na(londonLow)
        line newLondonLow = line.new(
             x1=londonLowBar,
             y1=londonLow,
             x2=bar_index,
             y2=londonLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=londonLineColor,
             style=londonLineStyle,
             width=levelWidth)

        array.push(londonLowLines, newLondonLow)
        array.push(londonLowLevels, londonLow)

        if showSessionLabels
            label newLondonLowLabel = label.new(
                 x=bar_index,
                 y=londonLow,
                 text="London",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=londonLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(londonLowLabels, newLondonLowLabel)
        else
            array.push(londonLowLabels, na)

//====================================================
// PRE-MARKET SESSION COMPLETE
//====================================================

if nyStart

    if not na(preMarketHigh)
        line newPreMarketHigh = line.new(
             x1=preMarketHighBar,
             y1=preMarketHigh,
             x2=bar_index,
             y2=preMarketHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=preMarketLineColor,
             style=preMarketLineStyle,
             width=levelWidth)

        array.push(preMarketHighLines, newPreMarketHigh)
        array.push(preMarketHighLevels, preMarketHigh)

        if showSessionLabels
            label newPreMarketHighLabel = label.new(
                 x=bar_index,
                 y=preMarketHigh,
                 text="Pre-Market",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=preMarketLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(preMarketHighLabels, newPreMarketHighLabel)
        else
            array.push(preMarketHighLabels, na)

    if not na(preMarketLow)
        line newPreMarketLow = line.new(
             x1=preMarketLowBar,
             y1=preMarketLow,
             x2=bar_index,
             y2=preMarketLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=preMarketLineColor,
             style=preMarketLineStyle,
             width=levelWidth)

        array.push(preMarketLowLines, newPreMarketLow)
        array.push(preMarketLowLevels, preMarketLow)

        if showSessionLabels
            label newPreMarketLowLabel = label.new(
                 x=bar_index,
                 y=preMarketLow,
                 text="Pre-Market",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=preMarketLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(preMarketLowLabels, newPreMarketLowLabel)
        else
            array.push(preMarketLowLabels, na)

//====================================================
// NEW YORK SESSION COMPLETE
//====================================================

if asiaStart and showNY

    if not na(nyHigh)
        line newNYHigh = line.new(
             x1=nyHighBar,
             y1=nyHigh,
             x2=bar_index,
             y2=nyHigh,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=nyLineColor,
             style=nyLineStyle,
             width=levelWidth)

        array.push(nyHighLines, newNYHigh)
        array.push(nyHighLevels, nyHigh)

        if showSessionLabels
            label newNYHighLabel = label.new(
                 x=bar_index,
                 y=nyHigh,
                 text="New York",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=nyLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(nyHighLabels, newNYHighLabel)
        else
            array.push(nyHighLabels, na)

    if not na(nyLow)
        line newNYLow = line.new(
             x1=nyLowBar,
             y1=nyLow,
             x2=bar_index,
             y2=nyLow,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=nyLineColor,
             style=nyLineStyle,
             width=levelWidth)

        array.push(nyLowLines, newNYLow)
        array.push(nyLowLevels, nyLow)

        if showSessionLabels
            label newNYLowLabel = label.new(
                 x=bar_index,
                 y=nyLow,
                 text="New York",
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=nyLineColor,
                 textcolor=color.white,
                 size=sessionLabelSize)

            array.push(nyLowLabels, newNYLowLabel)
        else
            array.push(nyLowLabels, na)

//====================================================
// EXTEND + CHECK ASIA HIGH LEVELS
//====================================================

if array.size(asiaHighLines) > 0
    int i = array.size(asiaHighLines) - 1

    while i >= 0
        line currentLine = array.get(asiaHighLines, i)
        float currentLevel = array.get(asiaHighLevels, i)
        label currentLabel = array.get(asiaHighLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        // Exact touch does NOT count.
        if high > currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(asiaHighLines, i)
            array.remove(asiaHighLevels, i)
            array.remove(asiaHighLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK ASIA LOW LEVELS
//====================================================

if array.size(asiaLowLines) > 0
    int i = array.size(asiaLowLines) - 1

    while i >= 0
        line currentLine = array.get(asiaLowLines, i)
        float currentLevel = array.get(asiaLowLevels, i)
        label currentLabel = array.get(asiaLowLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        // Exact touch does NOT count.
        if low < currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(asiaLowLines, i)
            array.remove(asiaLowLevels, i)
            array.remove(asiaLowLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK LONDON HIGH LEVELS
//====================================================

if array.size(londonHighLines) > 0
    int i = array.size(londonHighLines) - 1

    while i >= 0
        line currentLine = array.get(londonHighLines, i)
        float currentLevel = array.get(londonHighLevels, i)
        label currentLabel = array.get(londonHighLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if high > currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(londonHighLines, i)
            array.remove(londonHighLevels, i)
            array.remove(londonHighLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK LONDON LOW LEVELS
//====================================================

if array.size(londonLowLines) > 0
    int i = array.size(londonLowLines) - 1

    while i >= 0
        line currentLine = array.get(londonLowLines, i)
        float currentLevel = array.get(londonLowLevels, i)
        label currentLabel = array.get(londonLowLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if low < currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(londonLowLines, i)
            array.remove(londonLowLevels, i)
            array.remove(londonLowLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK PRE-MARKET HIGH LEVELS
//====================================================

if array.size(preMarketHighLines) > 0
    int i = array.size(preMarketHighLines) - 1

    while i >= 0
        line currentLine = array.get(preMarketHighLines, i)
        float currentLevel = array.get(preMarketHighLevels, i)
        label currentLabel = array.get(preMarketHighLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if high > currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(preMarketHighLines, i)
            array.remove(preMarketHighLevels, i)
            array.remove(preMarketHighLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK PRE-MARKET LOW LEVELS
//====================================================

if array.size(preMarketLowLines) > 0
    int i = array.size(preMarketLowLines) - 1

    while i >= 0
        line currentLine = array.get(preMarketLowLines, i)
        float currentLevel = array.get(preMarketLowLevels, i)
        label currentLabel = array.get(preMarketLowLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if low < currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(preMarketLowLines, i)
            array.remove(preMarketLowLevels, i)
            array.remove(preMarketLowLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK NEW YORK HIGH LEVELS
//====================================================

if array.size(nyHighLines) > 0
    int i = array.size(nyHighLines) - 1

    while i >= 0
        line currentLine = array.get(nyHighLines, i)
        float currentLevel = array.get(nyHighLevels, i)
        label currentLabel = array.get(nyHighLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if high > currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(nyHighLines, i)
            array.remove(nyHighLevels, i)
            array.remove(nyHighLabels, i)

        i -= 1

//====================================================
// EXTEND + CHECK NEW YORK LOW LEVELS
//====================================================

if array.size(nyLowLines) > 0
    int i = array.size(nyLowLines) - 1

    while i >= 0
        line currentLine = array.get(nyLowLines, i)
        float currentLevel = array.get(nyLowLevels, i)
        label currentLabel = array.get(nyLowLabels, i)

        line.set_x2(currentLine, bar_index)

        if not na(currentLabel)
            label.set_x(currentLabel, bar_index)

        if low < currentLevel
            line.set_x2(currentLine, bar_index)

            if not na(currentLabel)
                label.delete(currentLabel)

            array.remove(nyLowLines, i)
            array.remove(nyLowLevels, i)
            array.remove(nyLowLabels, i)

        i -= 1

//====================================================
// VERTICAL SESSION TIME MARKERS
//====================================================

//----------------------------------------------------
// ASIA SESSION START
//----------------------------------------------------

if showSessionMarkers and showAsiaMarker and asiaStart
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=asiaMarkerColor,
         style=asiaMarkerStyle,
         width=markerWidth)

//----------------------------------------------------
// LONDON SESSION START
//----------------------------------------------------

if showSessionMarkers and showLondonMarker and londonStart
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=londonMarkerColor,
         style=londonMarkerStyle,
         width=markerWidth)

//----------------------------------------------------
// PRE-MARKET SESSION START
//----------------------------------------------------

if showSessionMarkers and showPreMarketMarker and preMarketStart
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=preMarketMarkerColor,
         style=preMarketMarkerStyle,
         width=markerWidth)

//----------------------------------------------------
// NEW YORK SESSION START
//----------------------------------------------------

if showSessionMarkers and showNYMarker and nyStart
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=nyMarkerColor,
         style=nyMarkerStyle,
         width=markerWidth)

//----------------------------------------------------
// FIRST 15 MINUTES
//----------------------------------------------------

if showSessionMarkers and showFirst15Marker and first15Start
    line.new(
         x1=bar_index,
         y1=low,
         x2=bar_index,
         y2=high,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=first15MarkerColor,
         style=first15MarkerStyle,
         width=markerWidth)
````
