# Midnight Open Suite+ (M1D)

- url: https://www.tradingview.com/script/b9M8v9Xp-Midnight-Open-Suite-M1D/
- type: indicator
- pine_id: PUB;1c6453283ae645caba1e7a54b31fdb8f
- version: 3.0

## Description

[b]Midnight Open[/b] — is ICT's primary intraday bias reference. 

Price trading above it is at a premium to that open; price trading below it is at a discount. It is a level the market returns to often enough that where price sits relative to it is worth knowing before anything else about the day.

This script marks that open and the three that follow it, measures the range the first half hour builds, and reports where price stands against each. It takes no directional opinion of its own.


[b]THE OPENS[/b]

Four New York opens are drawn, each on its own settings:

- 12am, the Midnight Open.
- 3am, the London open.
- 8:30am, the release time that begins the New York morning.
- 9:30am, the cash open.

Each is a ray beginning at the candle that genuinely opened on its own time, carrying that candle's opening price. No level is drawn back across bars that closed before the price it marks existed, and no price is borrowed from a neighbouring bar.

Each open also carries an optional vertical line marking the minute itself, stamped with its own time. That stamp is derived from the time the open is configured to, so it cannot drift out of agreement with the level it names — move an open to a different minute and its stamp moves with it.

By default a level stops where the following day's level begins, so only one of each is ever live. It can instead be set to run on indefinitely.


[b]THE OPENING RANGE[/b]

The 12:00–12:30am window is drawn as a single zone from its own high to its own low, with an optional equilibrium — the 50% — running across it. The window opens on the Midnight Open's own time and its length is adjustable, so moving the open moves the range with it.

The 50% of a range is its equilibrium. 

Zone and equilibrium are both kept for several days. Four days is the default, which leaves the previous three equilibria on the chart behind the current one.


[b]WHY A LEVEL IS SOMETIMES WITHHELD[/b]

An open can only be read from a bar that opens on that exact minute. A bar that merely contains the minute opened earlier and carries an earlier price. On a 60-minute chart there is no bar that opens at 8:30 or at 9:30, so those two are not drawn at all rather than being placed a few points out — a level that is slightly wrong still looks right, which makes it worse than one that is visibly absent.

Withheld levels are never silent. The dashboard names each one and states the bar size that dropped it, so an empty row reads as "this timeframe cannot measure it" rather than "it has not happened yet".

An open is placeable when the chart's bar length divides evenly into the minutes between midnight and that open. With the four default times and the half-hour range, that means any bar length dividing 30 minutes — the 1, 2, 3, 5, 10, 15 and 30 minute charts. Move an open to a different minute and the arithmetic follows it.


[b]THE DASHBOARD[/b]

Bias is read from the Midnight Open alone, and is stated as both a direction and the premium or discount it implies.

Below it each open is listed with its price and the signed distance price currently sits from it, in points or in ticks. The opening range is listed with its size and whether price stands above, inside or below it, and the equilibrium with its own price and distance.

A level carried in from a previous day is still the level drawn on the chart, so it is still listed — but it is named as carried over, because reading a stale open as today's is how it gets traded by mistake.


[b]WHAT IT DRAWS[/b]

- Four opens as dotted rays, each from the candle that set it, named above its own line.
- An optional full-height vertical line on each open, stamped with its time.

- The 12:00–12:30am range as a soft zone whose border matches its fill, captioned with the window it covers. The caption re-centres on the span the zone currently occupies, so it tracks across with it rather than trailing at the left edge.

- The equilibrium as a thin dashed line through the zone, named inline on its own level so the text sits exactly at the price.

- Optional rays extending the range's high and low.

- A dashboard carrying bias, every open with its distance, and the range with its position.

Labels are transparent callouts throughout: nothing carries a background, and every offset is in pixels rather than price, so the spacing holds at any zoom level.


[b]SETTINGS[/b]

- Each open has its own show toggle, name, hour and minute, ray colour, style and width, and the same four controls again for its vertical line and time stamp.

- How many days of levels stay on the chart, and whether a ray stops at the next day's level or runs to the right edge.

- Opening range: window length, zone colour and transparency, how far the zone extends, whether the high and low extend as rays, and the zone's caption.

- Equilibrium: visibility, colour, line style, and whether it is named.

- Labels: whether levels are named, whether the price is included in the name, whether every kept day is named or only the newest, time stamp position, and label size.

- Dashboard: position, text and background colours, header fill, the two directional colours, text size, and whether distance is reported in points or ticks.


[b]NOTES[/b]

- Non-repainting. Levels are set on confirmed bars only and none is revised once its bar has closed.

- All times are New York and resolve through the exchange-independent New York clock, so they stay correct across daylight saving on any symbol.

- At the default times every level is measurable on the 1, 2, 3, 5, 10, 15 and 30 minute charts. Any other timeframe drops whichever levels its bars cannot open on, and names them.

- Four alert conditions: price crossing the Midnight Open, price crossing the opening range equilibrium, and the range's high or low being closed through.

- Every drawn element is black by default. Only the dashboard's directional readings carry colour, and all of them are inputs.

- This is a mapping tool. It draws reference levels and reports where price sits relative to them; it produces no entries, targets or stops.

[b]Disclaimer-[/b]
This is not financial advice. A level drawn by a model is context, not a recommendation to trade, and where price opened yesterday says nothing certain about where it goes today.

## Source Code

````pine
//@version=6
// ============================================================================
// Midnight Open Suite (M1D)
// ----------------------------------------------------------------------------
// The New York opens that frame an ICT trading day, drawn the way they
// would be marked out by hand: one dotted ray per open, an optional vertical
// stamp on the candle that set it, and nothing else on the chart.
//
// THE OPENS (New York time, each on its own inputs)
//   12am    The Midnight Open, ICT's primary intraday bias reference. Price
//           above it is trading at a premium to that open, price below it at a
//           discount.
//   3am     The London open.
//   8:30am  The economic-release open that begins the New York morning.
//   9:30am  The cash open.
//   5th     Off by default. Its own time and its own clock - 00:00 UTC out of the
//           box, the UTC day boundary, which falls at 20:00 New York in US summer
//           and 19:00 in winter. An open at 18:00 New York or later belongs to the
//           trading day that follows it, not the evening it prints on.
//
// Every ray begins at the candle that genuinely opened on its own time and
// carries that candle's opening price. Nothing is read off a neighbouring bar.
// A timeframe whose bars cannot open on a given minute has that open withheld
// with an on-chart notice rather than placed a few points out, because a level
// that is slightly wrong still looks right and is therefore worse than one
// that is visibly absent.
//
// THE OPENING RANGE
// The 12:00-12:30am window is drawn as a single box from its own high to its
// own low, with an optional equilibrium - the 50% - running across it. Box and
// equilibrium are both kept for several days, so the prior days' equilibria
// stay on the chart as forward reference.
//
// The 50% of a range is its equilibrium. Consequent encroachment is the 50% of
// an imbalance, and the terms are not interchangeable, so this level is named
// for what it actually measures.
//
// THE TABLE
// Every drawn open and the range's high, low and equilibrium, highest first, with price slotted
// in where it sits - so the day's premium or discount to the Midnight Open is read
// from the order. Each row is the level's distance from the last close, with a tick
// once price has traded back through it and a cross while it has not. Hover a row
// for the arithmetic and when it was traded. A level carried over from a previous
// trading day is marked prev, so a stale reference is never mistaken for today's.
//
// Every level, zone and label drawn on the chart is black by default. Every
// colour, style and width is an input, so the whole suite recolours without
// touching the code.
//
// Nothing repaints. Levels are set on confirmed bars only, and no level, zone
// or equilibrium is ever revised once its bar has closed.
// ============================================================================
indicator("Midnight Open Suite+ (M1D)", "M1D Opens+", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == CONSTANTS ===============================================================

//@variable Exchange-independent New York clock used by every time function
const string TZ = "America/New_York"
//@variable A fully transparent fill, so a callout label renders as text alone
const color INVISIBLE = color.new(color.white, 100)

// Real black, NOT Pine's built-in black constant — that one is #363A45, a dark slate
// grey out of TradingView's own UI chrome, so on a white chart every line and every
// label that used it rendered grey. Where black is the requirement it is written as
// the hex. A grep proving this file is CONSISTENT is not a check that it is BLACK;
// only the hex value is.
const color C_INK = #000000

// The build stamp stays off the chart — not in the shorttitle, not in a table. It
// prints once to the Pine Logs pane (Pine Editor → Logs) instead, so it is there when
// you go looking and invisible when you are not.
const string BUILD = "b9"

if barstate.islastconfirmedhistory
    log.info("Midnight Open Suite+ (M1D) BUILD " + BUILD)
//@variable Length of one chart bar in minutes, floored at 1 on sub-minute timeframes
int barMinutes = math.max(math.round(timeframe.in_seconds() / 60), 1)

// == INPUTS - GENERAL ========================================================

string chartTheme = input.string("Light", "Chart theme", options = ["Light", "Dark"], group = "General", tooltip = "Dark turns every black line, name and the table's ink light, and gives the table the dark chart's own ground, so nothing disappears into a dark background. Any colour you have set that is not black is left as it is.")
bool   isDark     = chartTheme == "Dark"

//@function A colour for the chart theme: pure black becomes light ink on Dark, anything
//          else is left exactly as set. Keeps its transparency either way.
//@param c (color) The colour as set
//@returns (color) The colour to draw with
inkCol(color c) =>
    isDark and color.r(c) == 0 and color.g(c) == 0 and color.b(c) == 0 ? color.new(#E6E6EF, color.t(c)) : c

int openDays = input.int(1, "Days of opens kept", minval = 1, maxval = 10, group = "General", tooltip = "How many days of open levels stay on the chart, newest first. One keeps today only: when the next day's open prints, the previous day's ray and its name are removed together, so the right edge carries one line per open.")
int daysKept = input.int(4, "Days of ranges kept", minval = 1, maxval = 10, group = "General", tooltip = "How many days of opening ranges stay on the chart, newest first. Four keeps today plus the three prior days, so the previous three equilibria remain visible as forward reference.")

string extendMode = input.string("Until the next open", "Rays extend", options = ["Until the next open", "To the right edge"], group = "General", tooltip = "Until the next open: each day's level stops where the following day's begins, so only one of each is ever live. To the right edge: every kept level runs on indefinitely.")

// == INPUTS - MIDNIGHT OPEN ==================================================

bool   moShow      = input.bool(true, "Show", group = "Midnight Open (12am)", inline = "moOn")
string moName      = input.string("Midnight Open", "", group = "Midnight Open (12am)", inline = "moOn")
int    moHr        = input.int(0, "Time", minval = 0, maxval = 23, group = "Midnight Open (12am)", inline = "moT")
int    moMn        = input.int(0, ":", minval = 0, maxval = 59, group = "Midnight Open (12am)", inline = "moT", tooltip = "New York hour and minute. The time tag drawn on the chart is derived from these, so it can never disagree with the level it names.")
color  moRayCol    = inkCol(input.color(color.new(#000000, 0), "Ray", group = "Midnight Open (12am)", inline = "moR"))
string moRayStyle  = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "Midnight Open (12am)", inline = "moR")
int    moRayWidth  = input.int(1, "", minval = 1, maxval = 4, group = "Midnight Open (12am)", inline = "moR")
bool   moVert      = input.bool(false, "Vertical", group = "Midnight Open (12am)", inline = "moV")
color  moVertCol   = inkCol(input.color(color.new(#000000, 0), "", group = "Midnight Open (12am)", inline = "moV"))
string moVertStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "Midnight Open (12am)", inline = "moV")
int    moVertWidth = input.int(1, "", minval = 1, maxval = 4, group = "Midnight Open (12am)", inline = "moV")
bool   moTag       = input.bool(true, "Time tag on the vertical", group = "Midnight Open (12am)", tooltip = "Stamps the vertical line with its own time, centred on the line so the two read as one marker. The text is derived from the time above it and cannot disagree with it.")

// == INPUTS - 3AM OPEN =======================================================

bool   l3Show      = input.bool(true, "Show", group = "3am Open", inline = "l3On")
string l3Name      = input.string("3am Open", "", group = "3am Open", inline = "l3On")
int    l3Hr        = input.int(3, "Time", minval = 0, maxval = 23, group = "3am Open", inline = "l3T")
int    l3Mn        = input.int(0, ":", minval = 0, maxval = 59, group = "3am Open", inline = "l3T")
color  l3RayCol    = inkCol(input.color(color.new(#000000, 0), "Ray", group = "3am Open", inline = "l3R"))
string l3RayStyle  = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "3am Open", inline = "l3R")
int    l3RayWidth  = input.int(1, "", minval = 1, maxval = 4, group = "3am Open", inline = "l3R")
bool   l3Vert      = input.bool(false, "Vertical", group = "3am Open", inline = "l3V")
color  l3VertCol   = inkCol(input.color(color.new(#000000, 0), "", group = "3am Open", inline = "l3V"))
string l3VertStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "3am Open", inline = "l3V")
int    l3VertWidth = input.int(1, "", minval = 1, maxval = 4, group = "3am Open", inline = "l3V")
bool   l3Tag       = input.bool(true, "Time tag on the vertical", group = "3am Open")

// == INPUTS - 8:30AM OPEN ====================================================

bool   n8Show      = input.bool(true, "Show", group = "8:30am Open", inline = "n8On")
string n8Name      = input.string("8:30 Open", "", group = "8:30am Open", inline = "n8On")
int    n8Hr        = input.int(8, "Time", minval = 0, maxval = 23, group = "8:30am Open", inline = "n8T")
int    n8Mn        = input.int(30, ":", minval = 0, maxval = 59, group = "8:30am Open", inline = "n8T")
color  n8RayCol    = inkCol(input.color(color.new(#000000, 0), "Ray", group = "8:30am Open", inline = "n8R"))
string n8RayStyle  = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "8:30am Open", inline = "n8R")
int    n8RayWidth  = input.int(1, "", minval = 1, maxval = 4, group = "8:30am Open", inline = "n8R")
bool   n8Vert      = input.bool(false, "Vertical", group = "8:30am Open", inline = "n8V")
color  n8VertCol   = inkCol(input.color(color.new(#000000, 0), "", group = "8:30am Open", inline = "n8V"))
string n8VertStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "8:30am Open", inline = "n8V")
int    n8VertWidth = input.int(1, "", minval = 1, maxval = 4, group = "8:30am Open", inline = "n8V")
bool   n8Tag       = input.bool(true, "Time tag on the vertical", group = "8:30am Open")

// == INPUTS - 9:30AM OPEN ====================================================

bool   n9Show      = input.bool(true, "Show", group = "9:30am Open", inline = "n9On")
string n9Name      = input.string("9:30 Open", "", group = "9:30am Open", inline = "n9On")
int    n9Hr        = input.int(9, "Time", minval = 0, maxval = 23, group = "9:30am Open", inline = "n9T")
int    n9Mn        = input.int(30, ":", minval = 0, maxval = 59, group = "9:30am Open", inline = "n9T")
color  n9RayCol    = inkCol(input.color(color.new(#000000, 0), "Ray", group = "9:30am Open", inline = "n9R"))
string n9RayStyle  = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "9:30am Open", inline = "n9R")
int    n9RayWidth  = input.int(1, "", minval = 1, maxval = 4, group = "9:30am Open", inline = "n9R")
bool   n9Vert      = input.bool(false, "Vertical", group = "9:30am Open", inline = "n9V")
color  n9VertCol   = inkCol(input.color(color.new(#000000, 0), "", group = "9:30am Open", inline = "n9V"))
string n9VertStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "9:30am Open", inline = "n9V")
int    n9VertWidth = input.int(1, "", minval = 1, maxval = 4, group = "9:30am Open", inline = "n9V")
bool   n9Tag       = input.bool(true, "Time tag on the vertical", group = "9:30am Open")

// == INPUTS - 5TH OPEN ========================================================

bool   x5Show      = input.bool(false, "Show", group = "5th Open", inline = "x5On", tooltip = "Off by default. A fifth open on its own time and its own clock.")
string x5Name      = input.string("UTC Open", "", group = "5th Open", inline = "x5On")
int    x5Hr        = input.int(0, "Time", minval = 0, maxval = 23, group = "5th Open", inline = "x5T")
int    x5Mn        = input.int(0, ":", minval = 0, maxval = 59, group = "5th Open", inline = "x5T")
string x5Zone      = input.string("UTC", "", options = ["UTC", "New York"], group = "5th Open", inline = "x5T", tooltip = "The clock the time is read on. 00:00 UTC is the UTC day boundary: 20:00 New York in US summer and 19:00 in winter, followed automatically. Any open that lands at 18:00 New York or later is counted toward the next trading day.")
color  x5RayCol    = inkCol(input.color(color.new(#000000, 0), "Ray", group = "5th Open", inline = "x5R"))
string x5RayStyle  = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "5th Open", inline = "x5R")
int    x5RayWidth  = input.int(1, "", minval = 1, maxval = 4, group = "5th Open", inline = "x5R")
bool   x5Vert      = input.bool(false, "Vertical", group = "5th Open", inline = "x5V")
color  x5VertCol   = inkCol(input.color(color.new(#000000, 0), "", group = "5th Open", inline = "x5V"))
string x5VertStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "5th Open", inline = "x5V")
int    x5VertWidth = input.int(1, "", minval = 1, maxval = 4, group = "5th Open", inline = "x5V")
bool   x5Tag       = input.bool(true, "Time tag on the vertical", group = "5th Open")

// == INPUTS - OPENING RANGE ==================================================

bool   orShow    = input.bool(true, "Show the opening range", group = "Opening Range", tooltip = "The window opens on the Midnight Open's own time, so moving that time moves the range with it.")
int    orMinutes = input.int(30, "Range length (minutes)", minval = 1, maxval = 720, group = "Opening Range")
color  orCol     = inkCol(input.color(color.new(#000000, 92), "Zone", group = "Opening Range", inline = "orZ", tooltip = "The border is drawn in this exact colour and transparency, so the zone reads as a single soft block rather than a outlined box."))
string orExtend  = input.string("Until the next day", "Zone extends", options = ["The range only", "Until the next day", "To the right edge"], group = "Opening Range")
bool   orEdges   = input.bool(false, "Extend the high and low as rays", group = "Opening Range", tooltip = "Off by default. The zone alone is usually enough; turn this on when the range's edges are being traded rather than just referenced.")
color  orEdgeCol = inkCol(input.color(color.new(#000000, 0), "Edge rays", group = "Opening Range", inline = "orE"))
string orEdgeSty = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "Opening Range", inline = "orE")
bool   orCaptOn  = input.bool(true, "Name the zone", group = "Opening Range", inline = "orC")
string orCaption = input.string("", "", group = "Opening Range", inline = "orC", tooltip = "Leave empty to name the zone from its own window, for example 12 - 12:30am. Where both ends of the window fall in the same half of the day they share one am or pm, and it is carried once at the far end.")
color  orTextCol = inkCol(input.color(color.new(#000000, 0), "Zone text", group = "Opening Range"))

// == INPUTS - CONSEQUENT ENCROACHMENT ========================================

bool   eqShow  = input.bool(true, "Show equilibrium", group = "Equilibrium", tooltip = "The 50% of the opening range. Drawn thin and dashed so it reads as a internal level, never as a edge of the zone. Equilibrium is the 50% of a range; consequent encroachment is the 50% of a imbalance, and the two are not interchangeable.")
color  eqCol   = inkCol(input.color(color.new(#000000, 0), "Equilibrium", group = "Equilibrium", inline = "eqL"))
string eqStyle = input.string("Dashed", "", options = ["Solid", "Dotted", "Dashed"], group = "Equilibrium", inline = "eqL")
bool   eqLabel = input.bool(true, "Name the equilibrium", group = "Equilibrium")

// == INPUTS - STANDARD DEVIATIONS ============================================

bool   sdShow  = input.bool(false, "Project the range's standard deviations", group = "Standard Deviations", tooltip = "Off by default. Projects the opening range's own height, wick to wick, above its high and below its low: -1 is one range away, -2 two, and so on. They sit far from price on a wide range, so they are a setting rather than the frame.")
int    sdCount = input.int(4, "How many", minval = 1, maxval = 6, group = "Standard Deviations")
int    sdDays  = input.int(1, "Days of projections kept", minval = 1, maxval = 10, group = "Standard Deviations", tooltip = "One keeps today's ladder only: yesterday's projections are removed when today's range completes. Two or more keep earlier days' ladders as well. Where one day's range ends is where the next begins, so kept ladders share a column at every day boundary and their names can meet there.")
color  sdCol   = inkCol(input.color(color.new(#000000, 0), "Lines", group = "Standard Deviations", inline = "sdL"))
string sdStyle = input.string("Dotted", "", options = ["Solid", "Dotted", "Dashed"], group = "Standard Deviations", inline = "sdL")
bool   sdLabel = input.bool(true, "Name the levels", group = "Standard Deviations", tooltip = "Each level carries its count only: -1, -2, -3, -4. The upward set is named at the right end, the downward set at the left, so the two never share a column.")

// == INPUTS - LABELS =========================================================

bool   showRayTags  = input.bool(true, "Name the open levels", group = "Labels")
bool   showRayPrice = input.bool(false, "Include the price in the name", group = "Labels", tooltip = "Off by default - the price is already on the axis and in the dashboard, so carrying it in the name as well is a third copy of the same number.")
string labelDays    = input.string("Newest day only", "Name levels for", options = ["Every day kept", "Newest day only"], group = "Labels", tooltip = "Every day kept names all of them. Each name sits at the end of its own ray, where the following day's level takes over, so the days do not stack on top of each other. Newest day only leaves the older rays bare, for when several days of levels sit within a few points and their names crowd.")
string labelPlace   = input.string("Right of the line", "Label placement", options = ["Right of the line", "Above the line"], group = "Labels", tooltip = "Right of the line: the name sits at the ray's right end, centred on the price it names and reading to the right. Above the line: the name sits on top of the ray's end, centred over it.")
int    nameOffset   = input.int(10, "Right offset (bars)", minval = 0, maxval = 100, group = "Labels", tooltip = "Runway between the live candle and the end of the newest ray, where its name sits. Only the right-of-the-line placement uses it.")
string tagPos       = input.string("Top", "Time tag position", options = ["Top", "Bottom"], group = "Labels", tooltip = "Top places the time above its vertical line, at the high of that trading day. Bottom places it below, at the day's low. Either way it is centred on the line and the clearance is a pixel offset, so it holds at every zoom level.")
string labelSizeIn  = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = "Labels")

// == INPUTS - DASHBOARD ======================================================

bool   dashShow  = input.bool(true, "Show the table", group = "Dashboard", tooltip = "Every drawn open and the opening range high, low and equilibrium, highest first, with price slotted in where it sits. Each row is the distance from the last close, with a tick once price has traded back through the level and a cross while it has not. Hover a row for the arithmetic.")
string dashPos   = input.string("Top right", "Position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = "Dashboard")
string distUnits = input.string("Points", "Distance in", options = ["Points", "Ticks"], group = "Dashboard")
string dashSize  = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = "Dashboard")
color  dashText  = inkCol(input.color(color.new(#000000, 0), "Text and frame", group = "Dashboard"))

// == TYPES ===================================================================

//@type One open's full set of user settings, so all five are driven by a single
//      body of code rather than five copies of it
type OpenSpec
    bool   show      = false
    int    hh        = 0
    int    mm        = 0
    string zone      = "America/New_York"
    string name      = ""
    color  rayCol    = #000000
    string rayStyle  = "Dotted"
    int    rayWidth  = 1
    bool   showVert  = false
    color  vertCol   = #000000
    string vertStyle = "Dotted"
    int    vertWidth = 1
    bool   showTag   = false

//@type One day's occurrence of one open, holding every drawing it owns so they
//      are all retired together when the day falls out of the kept window
type OpenMark
    float price     = na
    int   originBar = 0
    int   dayId     = 0
    bool  taken     = false
    int   takenT    = 0
    line  ray       = na
    label rayTag    = na
    line  vert      = na
    label vertTag   = na

//@type One open across every kept day - its settings and its history
type OpenSeries
    OpenSpec        spec  = na
    array<OpenMark> marks = na

//@type One day's opening range and everything drawn from it
type RangeMark
    float top      = na
    float bot      = na
    int   startBar = 0
    int   endBar   = 0
    int   dayId    = 0
    bool  taken    = false
    int   takenT   = 0
    bool  topTaken = false
    int   topT     = 0
    bool  botTaken = false
    int   botT     = 0
    box   zone     = na
    line  eq       = na
    line  topRay   = na
    line  botRay   = na
    label caption  = na
    label eqTag    = na
    array<line>  sdLines  = na
    array<label> sdUpTags = na
    array<label> sdDnTags = na

// == HELPER FUNCTIONS ========================================================

//@function Resolves a style input string to a Pine line-style constant
//@param styleName (string) One of "Solid", "Dotted", "Dashed"
//@returns (string) Matching line.style_* constant
resolveLineStyle(string styleName) => switch styleName
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed
    =>          line.style_dotted

//@function Resolves a size input string to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal"
//@returns (string) Matching size.* constant
resolveSize(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    =>          size.small

//@function Resolves a dashboard position input to a Pine position constant
//@param posName (string) The chosen corner
//@returns (string) Matching position.* constant
resolvePosition(string posName) => switch posName
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    =>                position.top_right

//@function Zero-pads a clock component to two digits
//@param value (int) Hour or minute
//@returns (string) Two-character string
pad2(int value) => (value < 10 ? "0" : "") + str.tostring(value)

//@function Renders a 24-hour New York time as the plain 12-hour tag it is
//          spoken as, so 00:00 reads "12am" and 08:30 reads "8:30am"
//@param hourValue    (int)  Hour, 0-23
//@param minuteValue  (int)  Minute, 0-59
//@param withMeridiem (bool) False drops the am/pm, for the near end of a window
//                           whose two halves share one
//@returns (string) Clock tag
fmtClock(int hourValue, int minuteValue, bool withMeridiem) =>
    int    h12  = hourValue % 12 == 0 ? 12 : hourValue % 12
    string mrdm = hourValue < 12 ? "am" : "pm"
    str.tostring(h12) + (minuteValue == 0 ? "" : ":" + pad2(minuteValue)) + (withMeridiem ? mrdm : "")

//@function True when this timeframe's bars can open exactly on a New York
//          clock time. A bar that merely contains the time opened earlier and
//          carries an earlier price, so that open is withheld instead.
//@param hourValue   (int) Target hour
//@param minuteValue (int) Target minute
//@returns (bool) True when the minute is a whole number of bars from midnight
canPlace(int hourValue, int minuteValue) =>
    barMinutes <= 60 and not timeframe.isdwm and (hourValue * 60 + minuteValue) % barMinutes == 0

//@function True on the single bar that opens on the given clock time
//@param hourValue   (int)    Target hour
//@param minuteValue (int)    Target minute
//@param zone        (string) Clock the time is read on
//@returns (bool) True on that bar only
opensAt(int hourValue, int minuteValue, string zone) =>
    bool onMinute = hour(time, zone) == hourValue and minute(time, zone) == minuteValue
    // Sub-minute charts put sixty bars inside one minute, so the second has to
    // be tested as well or every one of them would claim to be the open.
    onMinute and (timeframe.in_seconds() >= 60 or second(time, zone) == 0)

//@function An open's time as it is written on the chart and in the table, naming
//          the clock when it is not New York
//@param spec (OpenSpec) The open's settings
//@returns (string) e.g. "8:30am" or "12am UTC"
openClock(OpenSpec spec) =>
    fmtClock(spec.hh, spec.mm, true) + (spec.zone == "UTC" ? " UTC" : "")

//@function The trading day an open belongs to. An open at 18:00 New York or later
//          prints the evening before the session it frames, so it is counted
//          toward the following day - otherwise it would read as carried over for
//          the whole of the day it actually belongs to.
//@param t (int) Bar time
//@returns (int) New York day as a sortable integer
tradingDayOf(int t) =>
    int shifted = hour(t, TZ) >= 18 ? t + 6 * 3600000 : t
    year(shifted, TZ) * 10000 + month(shifted, TZ) * 100 + dayofmonth(shifted, TZ)

// == RESOLVED SETTINGS =======================================================

string labelSize   = resolveSize(labelSizeIn)
string cellSize    = resolveSize(dashSize)
// A downward callout sits its body above the anchor and an upward one below, and
// both centre it horizontally on that anchor. The time therefore sits squarely on
// its own vertical line, clear of it by a pixel offset that holds at any zoom.
string tagStyle    = tagPos == "Top" ? label.style_label_down : label.style_label_up
bool   rayToEdge   = extendMode == "To the right edge"
// Right of the line is the house placement for a level's name: a leftward callout
// anchors its pointer on the price and lays the text out to the right, so the
// name is centred on the level it names and reads at the ray's end like every
// other level script. Above the line is the older treatment, kept one option away.
bool   nameRight   = labelPlace == "Right of the line"
string rayTagStyle = nameRight ? label.style_label_left : label.style_label_down
string rayTagAlign = nameRight ? text.align_left : text.align_center
int    rayRunway   = nameRight ? nameOffset : 0
string eqStyleCode = resolveLineStyle(eqStyle)
string orEdgeCode  = resolveLineStyle(orEdgeSty)
string sdStyleCode = resolveLineStyle(sdStyle)

// == DRAWING FUNCTIONS =======================================================

//@function Builds the name that rides an open's ray
//@param spec       (OpenSpec) The open's settings
//@param openPrice  (float)    The price the ray sits at
//@returns (string) Ray label text
rayText(OpenSpec spec, float openPrice) =>
    spec.name + (showRayPrice ? "  " + str.tostring(openPrice, format.mintick) : "")

//@function Draws one day's occurrence of one open - the ray from the candle
//          that opened on the time, its optional vertical marker, and the text
//          belonging to each
//@param spec      (OpenSpec) The open's settings
//@param originBar (int)      Bar index of the candle that opened on the time
//@param openPrice (float)    That candle's opening price
//@param dayStamp  (int)      New York calendar day the open belongs to
//@param wantName  (bool)     False leaves the ray bare
//@returns (OpenMark) The constructed mark
makeMark(OpenSpec spec, int originBar, float openPrice, int dayStamp, bool wantName) =>
    OpenMark created = OpenMark.new(price = openPrice, originBar = originBar, dayId = dayStamp)

    created.ray := line.new(originBar, openPrice, originBar + 1, openPrice, xloc = xloc.bar_index, extend = rayToEdge ? extend.right : extend.none, color = spec.rayCol, style = resolveLineStyle(spec.rayStyle), width = spec.rayWidth)

    if wantName
        // The name rides the ray's right end. With the callout pointing left it is
        // centred on the price and reads to the right of the end; with it pointing
        // down the text body sits on top of the end instead. Either way the
        // clearance is a pixel offset that holds at every zoom level.
        created.rayTag := label.new(originBar + 1, openPrice, rayText(spec, openPrice), style = rayTagStyle, color = INVISIBLE, textcolor = spec.rayCol, size = labelSize, textalign = rayTagAlign, xloc = xloc.bar_index)
        label.set_text_font_family(created.rayTag, font.family_monospace)

    if spec.showVert
        // The two prices only seed the line; extend.both then carries it the
        // full height of the chart, so neither value is ever seen.
        created.vert := line.new(originBar, openPrice, originBar, openPrice + syminfo.mintick, xloc = xloc.bar_index, extend = extend.both, color = spec.vertCol, style = resolveLineStyle(spec.vertStyle), width = spec.vertWidth)

        if spec.showTag
            created.vertTag := label.new(originBar, openPrice, openClock(spec), style = tagStyle, color = INVISIBLE, textcolor = spec.vertCol, size = labelSize, textalign = text.align_center, xloc = xloc.bar_index)
            label.set_text_font_family(created.vertTag, font.family_monospace)
    created

//@function Deletes every drawing one mark owns
//@param target (OpenMark) Mark to erase
//@returns (bool) Always true
eraseMark(OpenMark target) =>
    line.delete(target.ray)
    line.delete(target.vert)
    label.delete(target.rayTag)
    label.delete(target.vertTag)
    true

//@function Deletes the standard-deviation ladder one range owns, leaving the range itself
//@param target (RangeMark) Range whose projections are retired
//@returns (bool) Always true
eraseProjections(RangeMark target) =>
    if not na(target.sdLines) and target.sdLines.size() > 0
        for i = 0 to target.sdLines.size() - 1
            line.delete(target.sdLines.get(i))
    if not na(target.sdUpTags) and target.sdUpTags.size() > 0
        for i = 0 to target.sdUpTags.size() - 1
            label.delete(target.sdUpTags.get(i))
    if not na(target.sdDnTags) and target.sdDnTags.size() > 0
        for i = 0 to target.sdDnTags.size() - 1
            label.delete(target.sdDnTags.get(i))
    target.sdLines  := na
    target.sdUpTags := na
    target.sdDnTags := na
    true

//@function Deletes every drawing one opening range owns
//@param target (RangeMark) Range to erase
//@returns (bool) Always true
eraseRange(RangeMark target) =>
    box.delete(target.zone)
    line.delete(target.eq)
    line.delete(target.topRay)
    line.delete(target.botRay)
    label.delete(target.caption)
    label.delete(target.eqTag)
    eraseProjections(target)
    true

// == STATE ===================================================================

//@variable The five opens, each carrying its own settings and its own history
var array<OpenSeries> opens = array.from(
     OpenSeries.new(OpenSpec.new(moShow, moHr, moMn, TZ, moName, moRayCol, moRayStyle, moRayWidth, moVert, moVertCol, moVertStyle, moVertWidth, moTag), array.new<OpenMark>(0)),
     OpenSeries.new(OpenSpec.new(l3Show, l3Hr, l3Mn, TZ, l3Name, l3RayCol, l3RayStyle, l3RayWidth, l3Vert, l3VertCol, l3VertStyle, l3VertWidth, l3Tag), array.new<OpenMark>(0)),
     OpenSeries.new(OpenSpec.new(n8Show, n8Hr, n8Mn, TZ, n8Name, n8RayCol, n8RayStyle, n8RayWidth, n8Vert, n8VertCol, n8VertStyle, n8VertWidth, n8Tag), array.new<OpenMark>(0)),
     OpenSeries.new(OpenSpec.new(n9Show, n9Hr, n9Mn, TZ, n9Name, n9RayCol, n9RayStyle, n9RayWidth, n9Vert, n9VertCol, n9VertStyle, n9VertWidth, n9Tag), array.new<OpenMark>(0)),
     OpenSeries.new(OpenSpec.new(x5Show, x5Hr, x5Mn, x5Zone == "UTC" ? "UTC" : TZ, x5Name, x5RayCol, x5RayStyle, x5RayWidth, x5Vert, x5VertCol, x5VertStyle, x5VertWidth, x5Tag), array.new<OpenMark>(0)))

//@variable Every opening range still inside the kept window, oldest first
var array<RangeMark> ranges = array.new<RangeMark>(0)

//@variable Today's vertical time tags, held so they can ride the day's extreme
var array<label> liveTags = array.new<label>(0)

//@variable Highest high and lowest low of the New York day in progress
var float dayHigh = na
var float dayLow  = na

//@variable Opening range in progress
var float orHigh    = na
var float orLow     = na
var int   orStart   = 0
var int   orEnd     = 0
var int   orDayId   = 0
var bool  orRunning = false

// == CLOCK ===================================================================

//@variable New York calendar day of the current bar, as a sortable integer
int dayId = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
//@variable True on the first bar of a New York day, which begins at midnight
bool newDay = na(time[1]) or dayId != (year(time[1], TZ) * 10000 + month(time[1], TZ) * 100 + dayofmonth(time[1], TZ))
//@variable Minute of the New York day the current bar opened on
int barOpenMinute = hour(time, TZ) * 60 + minute(time, TZ)

//@variable Minute of the day the opening range begins, taken from the Midnight Open
int orStartMinute = moHr * 60 + moMn
//@variable Minute of the day the opening range ends
int orEndMinute = orStartMinute + orMinutes
// Division yields a float, so the hour is floored back to a whole number and the
// minute taken as the remainder rather than read off a second division.
//@variable Clock hour the opening range ends on
int orEndHr = int(math.floor(orEndMinute / 60))
//@variable Clock minute the opening range ends on
int orEndMn = orEndMinute - orEndHr * 60

// The range is only measurable when its window divides evenly into the bar
// length and does not run past midnight into the following day.
//@variable True when this timeframe and window can measure the opening range
bool orMeasurable = orShow and canPlace(moHr, moMn) and orMinutes % barMinutes == 0 and orEndMinute <= 1440

// == DAY EXTREMES ============================================================
// The vertical time tags all hang off the same value, so the whole row of them
// sits at one height instead of stepping up and down across the day.

if newDay
    dayHigh := high
    dayLow  := low
    liveTags.clear()
else
    dayHigh := math.max(nz(dayHigh, high), high)
    dayLow  := math.min(nz(dayLow, low), low)

// == DETECTION - OPENS (confirmed bars only) =================================

if barstate.isconfirmed
    for i = 0 to opens.size() - 1
        OpenSeries oneOpen = opens.get(i)

        if oneOpen.spec.show and canPlace(oneOpen.spec.hh, oneOpen.spec.mm) and opensAt(oneOpen.spec.hh, oneOpen.spec.mm, oneOpen.spec.zone)
            // The ray starts at this candle and carries this candle's open, so
            // no level is ever drawn back across bars that closed before the
            // price it marks existed.
            // The day before this one is frozen here, where this day's level takes
            // over. Its ray had been running a runway past the live candle for its
            // name; that runway is pulled back to this bar so no old level reaches
            // into the new day, and the name stays at the ray's actual end.
            if oneOpen.marks.size() > 0
                OpenMark closing = oneOpen.marks.get(oneOpen.marks.size() - 1)
                if not rayToEdge
                    line.set_x2(closing.ray, bar_index)
                if not na(closing.rayTag)
                    label.set_x(closing.rayTag, bar_index)

            OpenMark fresh = makeMark(oneOpen.spec, bar_index, open, tradingDayOf(time), showRayTags)
            oneOpen.marks.push(fresh)

            if not na(fresh.vertTag)
                liveTags.push(fresh.vertTag)

            // Naming only the newest day keeps the right edge readable when
            // several days of levels sit within a few points of each other.
            if labelDays == "Newest day only" and oneOpen.marks.size() > 1
                OpenMark previous = oneOpen.marks.get(oneOpen.marks.size() - 2)
                label.delete(previous.rayTag)
                previous.rayTag := na

            while oneOpen.marks.size() > openDays
                eraseMark(oneOpen.marks.shift())

        // The newest level is ticked off the first time a later candle trades
        // through it. The candle that opened on the time is excluded - it trades
        // its own open by definition.
        if oneOpen.marks.size() > 0
            OpenMark latest = oneOpen.marks.get(oneOpen.marks.size() - 1)
            if not latest.taken and bar_index > latest.originBar and high >= latest.price and low <= latest.price
                latest.taken  := true
                latest.takenT := time

// == DETECTION - OPENING RANGE (confirmed bars only) =========================

if barstate.isconfirmed and orMeasurable
    // A range left open by a data hole is abandoned at the day boundary rather
    // than allowed to run on and swallow the following session.
    if orRunning and (newDay or barOpenMinute >= orEndMinute)
        float eqLevel = (orHigh + orLow) / 2.0
        int   rightX  = orExtend == "The range only" ? orEnd : bar_index
        string boxExt = orExtend == "To the right edge" ? extend.right : extend.none

        RangeMark built = RangeMark.new(top = orHigh, bot = orLow, startBar = orStart, endBar = orEnd, dayId = orDayId)

        // Border and fill carry the same colour and the same transparency, so
        // the zone reads as one soft block with no outline drawn around it.
        built.zone := box.new(orStart, orHigh, rightX, orLow, border_color = orCol, border_width = 1, border_style = line.style_solid, extend = boxExt, xloc = xloc.bar_index, bgcolor = orCol)

        if eqShow
            built.eq := line.new(orStart, eqLevel, rightX, eqLevel, xloc = xloc.bar_index, extend = boxExt, color = eqCol, style = eqStyleCode, width = 1)

        if orEdges
            // The edges begin where the zone ends and run on regardless of what the
            // zone is set to do, since extension is what the option is for. They are
            // retired with their own range like every other drawing it owns.
            built.topRay := line.new(orEnd, orHigh, orEnd + 1, orHigh, xloc = xloc.bar_index, extend = extend.right, color = orEdgeCol, style = orEdgeCode, width = 1)
            built.botRay := line.new(orEnd, orLow, orEnd + 1, orLow, xloc = xloc.bar_index, extend = extend.right, color = orEdgeCol, style = orEdgeCode, width = 1)

        if orCaptOn
            // Both ends of a window that stays inside one half of the day share a
            // meridiem, so it is carried once at the far end - "12 - 12:30am".
            bool   sameHalf = (moHr < 12) == (orEndHr < 12)
            string caption  = orCaption != "" ? orCaption : fmtClock(moHr, moMn, not sameHalf) + " - " + fmtClock(orEndHr, orEndMn, true)
            // Top centre, offset upward in pixels by the callout rather than by
            // a price gap, so the caption clears the zone at every zoom level.
            int midBar = orStart + int((orEnd - orStart) / 2)
            built.caption := label.new(midBar, orHigh, caption, style = label.style_label_down, color = INVISIBLE, textcolor = orTextCol, size = labelSize, textalign = text.align_center, xloc = xloc.bar_index)
            label.set_text_font_family(built.caption, font.family_monospace)

        if eqShow and eqLabel
            // Level text stays inline on its own line - centred exactly on the
            // equilibrium price, at the right of the zone where the eye leaves it.
            built.eqTag := label.new(rightX, eqLevel, "EQ", style = label.style_label_left, color = INVISIBLE, textcolor = eqCol, size = size.tiny, textalign = text.align_left, xloc = xloc.bar_index)
            label.set_text_font_family(built.eqTag, font.family_monospace)

        if sdShow
            // The range's own height, wick to wick, laid out above the high and
            // below the low. A projection is a reference, so it is drawn dotted
            // and named by its count alone. Up levels are named at the right end
            // and down levels at the left, so the two sets never share a column.
            float span = orHigh - orLow
            built.sdLines  := array.new<line>(0)
            built.sdUpTags := array.new<label>(0)
            built.sdDnTags := array.new<label>(0)
            for n = 1 to sdCount
                float upLevel = orHigh + n * span
                float dnLevel = orLow - n * span
                string tag = "-" + str.tostring(n)
                built.sdLines.push(line.new(orStart, upLevel, rightX, upLevel, xloc = xloc.bar_index, extend = boxExt, color = sdCol, style = sdStyleCode, width = 1))
                built.sdLines.push(line.new(orStart, dnLevel, rightX, dnLevel, xloc = xloc.bar_index, extend = boxExt, color = sdCol, style = sdStyleCode, width = 1))
                if sdLabel
                    label upTag = label.new(rightX, upLevel, tag, style = label.style_label_left, color = INVISIBLE, textcolor = sdCol, size = labelSize, textalign = text.align_left, xloc = xloc.bar_index)
                    label.set_text_font_family(upTag, font.family_monospace)
                    built.sdUpTags.push(upTag)
                    label dnTag = label.new(orStart, dnLevel, tag, style = label.style_label_right, color = INVISIBLE, textcolor = sdCol, size = labelSize, textalign = text.align_right, xloc = xloc.bar_index)
                    label.set_text_font_family(dnTag, font.family_monospace)
                    built.sdDnTags.push(dnTag)

        ranges.push(built)
        orRunning := false

        while ranges.size() > daysKept
            eraseRange(ranges.shift())

        // The ladder is retired on its own clock, ahead of the range it belongs
        // to, so yesterday's projections leave when today's arrive while the
        // range and its equilibrium stay as reference.
        if ranges.size() > sdDays
            for i = 0 to ranges.size() - sdDays - 1
                eraseProjections(ranges.get(i))

    // A window that opens on the same bar it would have closed on is started
    // after the close above, never before it.
    if opensAt(moHr, moMn, TZ)
        orHigh    := high
        orLow     := low
        orStart   := bar_index
        orEnd     := bar_index
        orDayId   := dayId
        orRunning := true
    else if orRunning and barOpenMinute >= orStartMinute and barOpenMinute < orEndMinute
        orHigh := math.max(orHigh, high)
        orLow  := math.min(orLow, low)
        orEnd  := bar_index

// The equilibrium of the newest range is ticked off the same way, once a candle
// after the range has closed trades through it.
if barstate.isconfirmed and ranges.size() > 0
    RangeMark latestRange = ranges.get(ranges.size() - 1)
    float latestEq = (latestRange.top + latestRange.bot) / 2.0
    if not latestRange.taken and bar_index > latestRange.endBar and high >= latestEq and low <= latestEq
        latestRange.taken  := true
        latestRange.takenT := time
    // Its high and low the same way: a candle after the range trading at or through them.
    if not latestRange.topTaken and bar_index > latestRange.endBar and high >= latestRange.top
        latestRange.topTaken := true
        latestRange.topT     := time
    if not latestRange.botTaken and bar_index > latestRange.endBar and low <= latestRange.bot
        latestRange.botTaken := true
        latestRange.botT     := time

// == LIVE EDGE ===============================================================
// Only the newest level of each open is still growing. The kept days behind it
// are frozen where the following day's level began, so they are left alone.

for i = 0 to opens.size() - 1
    OpenSeries oneOpen = opens.get(i)
    if oneOpen.marks.size() > 0
        OpenMark newest = oneOpen.marks.get(oneOpen.marks.size() - 1)
        // The ray's end and the name's anchor are the same number, used twice, so
        // the name can never sit where the ray is not. Right of the line carries a
        // runway past the live candle for the text; above the line rides the
        // candle itself.
        int rayEnd = bar_index + rayRunway
        if not rayToEdge
            line.set_x2(newest.ray, rayEnd)
        if not na(newest.rayTag)
            label.set_x(newest.rayTag, rayEnd)

if ranges.size() > 0 and orExtend != "The range only"
    RangeMark newestRange = ranges.get(ranges.size() - 1)

    // Only the zone set to stop at the day boundary is grown by hand. The one set
    // to run to the right edge already carries extend.right and needs no help.
    if orExtend == "Until the next day" and newestRange.dayId == dayId
        box.set_right(newestRange.zone, bar_index)
        if not na(newestRange.eq)
            line.set_x2(newestRange.eq, bar_index)
        if not na(newestRange.sdLines) and newestRange.sdLines.size() > 0
            for i = 0 to newestRange.sdLines.size() - 1
                line.set_x2(newestRange.sdLines.get(i), bar_index)

    // The zone's name is re-centred on the span it currently covers rather than on
    // the half hour that built it, so it tracks across with the zone instead of
    // trailing back at its left edge. Once the day ends the zone stops growing, so
    // the last centring it takes is the middle of its own finished span.
    if not na(newestRange.caption) and newestRange.dayId == dayId
        label.set_x(newestRange.caption, newestRange.startBar + int((bar_index - newestRange.startBar) / 2))

    // The equilibrium's name rides the live edge either way, so it is never left
    // stranded back at the half hour that formed it. Only the newest one is moved
    // - carrying every kept day's name to the same edge would pile them up.
    if not na(newestRange.eqTag) and (orExtend == "To the right edge" or newestRange.dayId == dayId)
        label.set_x(newestRange.eqTag, bar_index)
    // The upward projections' names ride the live edge with the equilibrium's;
    // the downward names stay at the range's start, where they were placed.
    if not na(newestRange.sdUpTags) and newestRange.sdUpTags.size() > 0 and (orExtend == "To the right edge" or newestRange.dayId == dayId)
        for i = 0 to newestRange.sdUpTags.size() - 1
            label.set_x(newestRange.sdUpTags.get(i), bar_index)

// Today's time tags ride the day's own extreme, so they stay above the price
// action instead of being buried by it as the session expands.
if liveTags.size() > 0
    float anchor = tagPos == "Top" ? dayHigh : dayLow
    for i = 0 to liveTags.size() - 1
        label.set_y(liveTags.get(i), anchor)

// == DASHBOARD ===============================================================

//@variable The Midnight Open currently in force, which the day's bias is read from
float midnightPrice = opens.get(0).marks.size() > 0 ? opens.get(0).marks.get(opens.get(0).marks.size() - 1).price : na
//@variable Top of the opening range currently in force
float liveOrTop = ranges.size() > 0 ? ranges.get(ranges.size() - 1).top : na
//@variable Bottom of the opening range currently in force
float liveOrBot = ranges.size() > 0 ? ranges.get(ranges.size() - 1).bot : na
//@variable The 50% of that range
float liveOrEq = na(liveOrTop) ? na : (liveOrTop + liveOrBot) / 2.0

//@variable The table, rebuilt whenever its row count changes
var table dash = na
//@variable Rows the table was built with
var int dashRowsDrawn = na

//@type One row of the table: a drawn level, its state, and the words behind it
type DashRow
    string name    = ""
    float  price   = na
    bool   taken   = false
    bool   offTf   = false
    string nameTip = ""
    string state   = ""

//@function Writes one row of the table: name, reading and mark
//@param rowIdx  (int)    Row
//@param name    (string) Name, left
//@param val     (string) Reading
//@param mark    (string) ✓, × or empty
//@param nameTip (string) Tooltip on the name
//@param valTip  (string) Tooltip on the reading
//@returns (bool) Always true
dashRow(int rowIdx, string name, string val, string mark, string nameTip, string valTip) =>
    table.cell(dash, 0, rowIdx, str.upper(name), text_color = dashText, text_size = cellSize, text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = nameTip)
    table.cell(dash, 1, rowIdx, val, text_color = dashText, text_size = cellSize, text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = valTip)
    table.cell(dash, 2, rowIdx, mark, text_color = dashText, text_size = cellSize, text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = valTip)
    true

//@function Distance from the close to a level, signed: + above price, - below, in the chosen units
//@param level (float) The level
//@returns (string) Formatted distance
fmtGap(float level) =>
    float gap = level - close
    string sign = gap > 0 ? "+" : gap < 0 ? "-" : ""
    sign + (distUnits == "Ticks" ? str.tostring(math.abs(gap) / syminfo.mintick, "0") : str.tostring(math.abs(gap), format.mintick))

//@function The chart timeframe as a short tag: 1m, 5m, 1H
//@returns (string) The tag
tfTag() =>
    int sec = timeframe.in_seconds()
    sec < 60 ? str.tostring(sec) + "s" : sec < 3600 ? str.tostring(int(sec / 60)) + "m" : sec < 86400 ? str.tostring(int(sec / 3600)) + "H" : timeframe.period

if barstate.islast and dashShow
    string unitTx = distUnits == "Ticks" ? " ticks" : " pts"

    // The drawn levels, highest first. Price gets its own row where it sits, so which
    // side of price a level is on - and so the day's premium or discount to the
    // Midnight Open - is read from the order rather than written out.
    array<DashRow> rows    = array.new<DashRow>()
    array<DashRow> offRows = array.new<DashRow>()
    for i = 0 to opens.size() - 1
        OpenSeries oneOpen = opens.get(i)
        if oneOpen.spec.show
            string clockTx = openClock(oneOpen.spec)
            if not canPlace(oneOpen.spec.hh, oneOpen.spec.mm)
                offRows.push(DashRow.new(name = clockTx, offTf = true, nameTip = oneOpen.spec.name, state = "A " + str.tostring(barMinutes) + "m bar cannot open on this minute, so the level is withheld rather than placed a few points out."))
            else if oneOpen.marks.size() > 0
                OpenMark newest = oneOpen.marks.get(oneOpen.marks.size() - 1)
                // A level carried in from a previous trading day is still the one drawn,
                // so it is listed - but named as carried over, because reading it as
                // today's is how a stale level gets traded.
                bool   carried = newest.dayId != tradingDayOf(time)
                string state   = newest.taken ? "Traded through " + str.format_time(newest.takenT, "dd MMM HH:mm", TZ) + " New York" : "Not traded back to since it printed"
                rows.push(DashRow.new(name = clockTx + (carried ? " prev" : ""), price = newest.price, taken = newest.taken, nameTip = oneOpen.spec.name + (carried ? " - from the previous trading day" : ""), state = state))
    if orShow and eqShow and not na(liveOrEq)
        RangeMark live = ranges.get(ranges.size() - 1)
        string eqState = live.taken ? "Traded through " + str.format_time(live.takenT, "dd MMM HH:mm", TZ) + " New York" : "Not traded back to since the range closed"
        rows.push(DashRow.new(name = "EQ", price = liveOrEq, taken = live.taken, nameTip = "Equilibrium - the 50% of the opening range " + str.tostring(liveOrBot, format.mintick) + " to " + str.tostring(liveOrTop, format.mintick), state = eqState))
    if orShow and not na(liveOrTop)
        RangeMark edges = ranges.get(ranges.size() - 1)
        string hiState = edges.topTaken ? "Traded through " + str.format_time(edges.topT, "dd MMM HH:mm", TZ) + " New York" : "Not traded back to since the range closed"
        string loState = edges.botTaken ? "Traded through " + str.format_time(edges.botT, "dd MMM HH:mm", TZ) + " New York" : "Not traded back to since the range closed"
        rows.push(DashRow.new(name = "OR High", price = liveOrTop, taken = edges.topTaken, nameTip = "High of the opening range", state = hiState))
        rows.push(DashRow.new(name = "OR Low", price = liveOrBot, taken = edges.botTaken, nameTip = "Low of the opening range", state = loState))
    if orShow and not orMeasurable
        offRows.push(DashRow.new(name = "Range", offTf = true, nameTip = "The opening range", state = "No bar on this timeframe opens and closes on the range's own minutes, so the range is withheld."))

    array<DashRow> sorted = array.new<DashRow>()
    for oneRow in rows
        int at = sorted.size()
        if sorted.size() > 0
            for k = 0 to sorted.size() - 1
                if oneRow.price > sorted.get(k).price
                    at := k
                    break
        sorted.insert(at, oneRow)

    // The name row, instrument, timeframe, one row per level, one for price, and one per withheld level.
    int wantRows = sorted.size() + offRows.size() + 4
    if na(dash) or dashRowsDrawn != wantRows
        if not na(dash)
            table.delete(dash)
        dash := table.new(resolvePosition(dashPos), 3, wantRows, frame_color = dashText, frame_width = 1, border_width = 0)
        dashRowsDrawn := wantRows
    dashRow(0, "Midnight Open Suite+", "", "", "", "")
    dashRow(1, "Instrument", syminfo.ticker, "", "", "")
    dashRow(2, "Timeframe", tfTag(), "", "", "")

    string closeTx   = str.tostring(close, format.mintick)
    int    row       = 3
    bool   priceDone = false
    for oneRow in sorted
        if not priceDone and oneRow.price < close
            dashRow(row, "Price", closeTx, "", "Last close", "Last close")
            row += 1
            priceDone := true
        string calc = str.tostring(oneRow.price, format.mintick) + " - " + closeTx + " = " + str.tostring(oneRow.price - close, format.mintick) + unitTx
        dashRow(row, oneRow.name, str.tostring(oneRow.price, format.mintick) + "  " + fmtGap(oneRow.price), oneRow.taken ? "✓" : "×", oneRow.nameTip, calc + "\n" + oneRow.state)
        row += 1
    if not priceDone
        dashRow(row, "Price", closeTx, "", "Last close", "Last close")
        row += 1
    for oneRow in offRows
        dashRow(row, oneRow.name, "off TF", "", oneRow.nameTip, oneRow.state)
        row += 1
else if not na(dash)
    table.delete(dash)
    dash := na
    dashRowsDrawn := na

// == ALERTS (script scope) ===================================================

// Both crosses are evaluated unconditionally. ta.* functions carry bar-to-bar
// state and v6 short-circuits 'and', so guarding the call itself would skip it
// on the bars where no level exists and corrupt its own history.
bool midnightCrossRaw = ta.cross(close, midnightPrice)
bool eqCrossRaw       = ta.cross(close, liveOrEq)
bool orHighBreakRaw   = ta.crossover(close, liveOrTop)
bool orLowBreakRaw    = ta.crossunder(close, liveOrBot)

bool crossedMidnight = not na(midnightPrice) and midnightCrossRaw
bool crossedOrEq     = not na(liveOrEq) and eqCrossRaw
bool brokeOrHigh     = not na(liveOrTop) and orHighBreakRaw
bool brokeOrLow      = not na(liveOrBot) and orLowBreakRaw

alertcondition(crossedMidnight, "Midnight Open traded", "M1D: price crossed the Midnight Open on {{ticker}} @ {{close}}")
alertcondition(crossedOrEq,     "Opening range equilibrium traded", "M1D: price crossed the opening range equilibrium on {{ticker}} @ {{close}}")
alertcondition(brokeOrHigh,     "Opening range high broken", "M1D: price closed above the opening range high on {{ticker}} @ {{close}}")
alertcondition(brokeOrLow,      "Opening range low broken", "M1D: price closed below the opening range low on {{ticker}} @ {{close}}")
````
