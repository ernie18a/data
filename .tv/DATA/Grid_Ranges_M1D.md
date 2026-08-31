<!-- tradingview-pine-id: PUB;ae250da2023b479dad80866e89c5c5cd -->
<!-- tradingviewscripts-format: 1 -->
# Grid Ranges+ (M1D)

Source: https://www.tradingview.com/script/KQWHpbUu-Grid-Ranges-M1D/

## Description

Grid Ranges+ (M1D)

A grid-range framework for the New York trading day. It draws the higher-timeframe levels that frame the current range, divides any range you choose into quadrants, octants or sixteenths, boxes the three trading sessions, and reads the 12AM–2AM algorithmic range for aid in a directional bias.

Every session window is evaluated in America/New York regardless of the time zone the chart is viewed from, and every window is an input.

HOW IT IS BUILT

Levels are anchored to the candle that formed them. A higher-timeframe data request returns the value of a period's high but not the bar that made it. This script tracks each period's extremes on the chart instead, along with the bar time of each, so a previous-day high begins at the candle that set it rather than at the moment the number changed. The trade-off is that a period only reports once its opening bar is inside loaded history; where it is not, the level stays hidden rather than anchoring to a bar that did not set it.

Week and month boundaries derive from the New York day stamp, not from a weekly timeframe change, which is unreliable on futures instruments.

The swing pair is kept alternating. Pivot-high and pivot-low detection are independent of each other, so a chart can print several highs with no qualifying low between them. A pivot on the same side as the stored one replaces it only when it is more extreme, while a pivot on the opposite side begins the next leg. Without that rule, a recent high pairs with a low from a different move and the two do not describe one leg.

WHAT IT DRAWS

Levels. 
Previous month, previous week, previous day and three-day highs and lows, the previous day's equilibrium, and the midnight open. Each line runs from its origin candle to a fixed right-hand edge and carries its name at that end, on the same eye-line as the price it names. Names that would otherwise print on top of each other move right into a second column rather than off their own line.

The grid. 
A range bounded by any two of those levels, selected from two dropdowns and oriented automatically, divided into quadrants, octants or sixteenths. It begins at the earlier of the two origin candles. The midline is labelled EQ, and quarter fractions are reduced to lowest terms. A fraction is suppressed wherever a level already names that price, so no price carries two names.

Sessions. 
Asia, London and New York as boxes that grow with each session's own high and low and freeze when the window closes. The caption sits below the box at the session open. Each session carries its own day mask.

The bias. 
The 12AM–2AM algorithmic range as a box, and a console reading BULLISH, BEARISH, INVALIDATED or UNSET. A sweep clearing both the range boundary and the midnight open inside the sweep window, followed by a confirmed close back inside the range, arms a directional read. A confirmed close back through the swept extreme invalidates it, after which the opposite side may arm. Three alert conditions cover those transitions.

SETTINGS

Grouped as- 
Time windows, Sessions, Bias engine, Grid range, Levels shown, Level styling and Labels.

Every level carries its own colour, line style, line width and label offset. The grid carries its own colour, style, width, interior transparency and equilibrium colour. Every session window is an input with a New York default and its own day mask, and session boxes carry their own colours and fill transparency.

NOTES

Nothing extends to the right edge of the chart. Every line stops a set number of bars past the live candle, and its label sits at that end.

Current-day and swing anchors move as the session develops, so a grid anchored to them redraws live. A grid anchored to completed periods does not.

Display toggles gate drawing only. Hiding an element never stops it being tracked, so the bias read is unaffected by what is on screen.

Grid boundaries are not drawn by the grid by default. A boundary is the anchor level itself, which already draws its own line from its own origin candle.

Disclaimer-
This script is a charting tool. It is not financial advice, and it makes no claim about where price will go.

---

## Source Code

````pine
//@version=6
// =============================================================================
//  Grid Ranges+ (M1D)
//
//  A grid-range framework for the New York trading day. Four parts:
//
//    Levels        Previous month, week, day and 3-day extremes, each drawn
//                  from the candle that actually formed it.
//    Grid          Divides a range bounded by any two of those levels, in
//                  quadrants, octants or sixteenths.
//    Sessions      Asia, London and New York as developing range boxes.
//    Bias          The 12AM–2AM algorithmic range, a sweep of it, and the
//                  return that arms a directional read.
//
//  Every session window is evaluated in America/New_York regardless of the
//  timezone the chart is being viewed from.
// =============================================================================
indicator("Grid Ranges+ (M1D)", "Grids+", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == CONSTANTS ================================================================

//@variable Session windows resolve against this timezone, never the chart's.
const string TZ = "America/New_York"

//@variable Directional colours. Reserved for the bias verdict.
const color C_BULL = #7246CE
const color C_BEAR = #DB1D9C

//@variable Fully transparent, for callout bodies that must show no background.
const color INVISIBLE = color.new(color.white, 100)

// == INPUTS ===================================================================

const string G_TIME = "Time windows (New York)"
const string G_SESS = "Sessions"
const string G_BIAS = "Bias engine"
const string G_GRID = "Grid range"
const string G_LVLS = "Levels shown"
const string G_LIQ  = "Liquidity (REH / REL)"
const string G_LVL  = "Level styling"
const string G_STYLE= "Labels"

string sessAlgoRange = input.session("0000-0200", "12AM–2AM algorithmic range",
     group = G_TIME, tooltip = "The manipulation window the Judas read is measured in.")
string sessJudas = input.session("0200-0500", "Judas sweep window", group = G_TIME,
     tooltip = "Where the sweep of the range must occur. The return inside it may complete later.")
string sessLunch = input.session("1200-1300:23456", "NY Lunch", group = G_TIME,
     tooltip = "Low-participation drift. The range built here is frequently taken in the afternoon.")

bool showSessions = input.bool(false, "Show session boxes", group = G_SESS,
     tooltip = "Off by default. When on, boxes are drawn only from the grid's anchor candle forward — the span the active grid range covers.")
// Day masks are part of the session string, and Sunday is day 1. Asia runs on
// Sunday-to-Thursday EVENINGS New York time, which is :12345. London and New
// York run Monday to Friday, which is :23456 — :12345 there would silently drop
// every Friday.
//
// New York is the full cash session, open to close, so the box spans lunch
// rather than stopping before it. Asia and London stay as their kill-zone
// windows; a session box and a kill zone are different spans and only New York
// is set to the wider one here.
string sessAsia = input.session("1800-2200:12345", "Asia", inline = "sa", group = G_SESS)
color  colAsia  = input.color(#2962FF, "", inline = "sa", group = G_SESS)
string sessLon  = input.session("0200-0500:23456", "London", inline = "sl", group = G_SESS)
color  colLon   = input.color(#F23645, "", inline = "sl", group = G_SESS)
string sessNy   = input.session("0930-1600:23456", "New York", inline = "sn", group = G_SESS)
color  colNy    = input.color(#26A69A, "", inline = "sn", group = G_SESS)
int sessTransp = input.int(85, "Session fill transparency", minval = 50, maxval = 97, step = 1,
     group = G_SESS, tooltip = "Lower is more solid. A session box is wide, so it turns opaque fast.")
int sessKeep = input.int(20, "Sessions kept", minval = 1, maxval = 100, group = G_SESS,
     tooltip = "Roughly how many of each session survive before the oldest boxes are deleted. The three share one store, so the split between them is not exact.")

bool showRange   = input.bool(true, "12AM–2AM range box", group = G_BIAS)
bool showConsole = input.bool(true, "Bias console", group = G_BIAS)
int  swingLen    = input.int(5, "Swing strength (bars)", minval = 1, maxval = 50, group = G_BIAS,
     tooltip = "Pivot lookback and lookforward behind the Swing High and Swing Low anchors. A pivot confirms this many bars after it prints.")

bool showGrid  = input.bool(true, "Show grid", group = G_GRID)
bool gridEdges = input.bool(false, "Draw range boundaries", group = G_GRID,
     tooltip = "Off by default. The two boundaries ARE the anchor levels, which already draw their own lines from their own origin candles. Drawing them again here puts a second line on one price, starting at a bar that has nothing to do with it. Turn this on only when anchoring the grid to levels that are hidden.")
string gridTopSel = input.string("PDH", "Grid top", options = [
     "PDH","PDL","CDH","CDL","3DH","3DL","PWH","PWL","PMH","PML","Swing High","Swing Low","Midnight Open"],
     group = G_GRID, tooltip = "The two levels bounding the range the grid divides. Picked the wrong way round, they are swapped automatically.")
string gridBotSel = input.string("PDL", "Grid bottom", options = [
     "PDH","PDL","CDH","CDL","3DH","3DL","PWH","PWL","PMH","PML","Swing High","Swing Low","Midnight Open"],
     group = G_GRID)
string gridDiv = input.string("Quadrants (1/4)", "Subdivision",
     options = ["Quadrants (1/4)", "Octants (1/8)", "Sixteenths (1/16)"], group = G_GRID)
string gridLabelMode = input.string("Quarters + EQ", "Label levels",
     options = ["Quarters + EQ", "Every level", "None"], group = G_GRID,
     tooltip = "Sixteenths puts seventeen lines on the chart, and naming every one is rarely readable. The two boundaries are never named here — they already carry their own level names, and one price never takes two labels.")
color  gridCol      = input.color(color.black, "Grid colour", inline = "gs", group = G_GRID)
string gridStyleSel = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "gs", group = G_GRID)
int    gridWidth    = input.int(1, "", minval = 1, maxval = 4, inline = "gs", group = G_GRID)
color gridEqCol = input.color(color.gray, "Equilibrium colour", group = G_GRID,
     tooltip = "The midline of the range. Equilibrium is the midpoint of a RANGE — consequent encroachment is the midpoint of a PD array, and the two are not interchangeable.")
int gridTransp = input.int(45, "Interior line transparency", minval = 0, maxval = 95, step = 5,
     group = G_GRID, tooltip = "Applied to the subdivision lines only.")
int gridLabelOff = input.int(11, "Grid label offset (bars)", minval = 0, maxval = 120, group = G_GRID,
     tooltip = "How far right of the line ends the fractions sit, so they clear the level names.")

bool showMidnightOpen = input.bool(true,  "Midnight Open", group = G_LVLS)
bool show3Day     = input.bool(true,  "3-Day high / low  (3DH · 3DL)", group = G_LVLS,
     tooltip = "The range the current session is working inside.")
bool showPrevDay  = input.bool(true,  "Previous day high / low  (PDH · PDL)", group = G_LVLS)
bool showPdEq     = input.bool(true,  "Previous day equilibrium  (PD.EQ)", group = G_LVLS)
bool showPrevWeek = input.bool(false, "Previous week high / low  (PWH · PWL)", group = G_LVLS)
bool showPrevMonth= input.bool(false, "Previous month high / low  (PMH · PML)", group = G_LVLS)
bool showLunch    = input.bool(false, "NY Lunch high / low", group = G_LVLS,
     tooltip = "The 12:00–13:00 range, frozen when the window closes.")

// Liquidity is the one line in this script that is not width 1. A pool is a
// destination, and it should read heavier than the reference lines around it.
// It is also never coloured by direction: a pool is neither bullish nor
// bearish, and tinting it either way implies a bias the level does not carry.
bool showLiq = input.bool(true, "Show REH / REL", group = G_LIQ)
int liqTolTicks = input.int(4, "Equal-price tolerance (ticks)", minval = 1, maxval = 200, group = G_LIQ,
     tooltip = "How far apart two pivots may sit and still count as equal. Measured in ticks, so it scales with the instrument.")
string liqNotation = input.string("$$", "Notation", options = ["$$", "BSL / SSL"], group = G_LIQ)
string liqOnRaid = input.string("Dotted, ends at the sweep", "Once raided",
     options = ["Dotted, ends at the sweep", "Delete"], group = G_LIQ,
     tooltip = "A raided pool turns dotted and stops at the candle that took it, leaving a record of where the liquidity went. Delete removes it outright.")
color liqCol   = input.color(color.black, "Colour", inline = "lq", group = G_LIQ)
int   liqWidth = input.int(2, "", minval = 1, maxval = 4, inline = "lq", group = G_LIQ)
int   liqKeep  = input.int(12, "Live pools kept", minval = 1, maxval = 50, group = G_LIQ)
int   liqKeepRaided = input.int(2, "Raided pools kept", minval = 0, maxval = 10, group = G_LIQ,
     tooltip = "How many spent pools stay on the chart as a record of where liquidity went. Older ones are removed. Zero clears them the moment they are taken.")

// One row per level: colour · line style · line width · label offset in bars.
const string LVL_TIP = "Each row reads: colour · line style · line width · label offset in bars. The offset shifts this one name left or right of the shared right edge, on top of any automatic staggering."

color  cMo  = input.color(color.black, "Midnight Open", inline = "mo", group = G_LVL, tooltip = LVL_TIP)
string yMo  = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "mo", group = G_LVL)
int    wMo  = input.int(1, "", minval = 1, maxval = 4, inline = "mo", group = G_LVL)
int    oMo  = input.int(0, "", minval = -200, maxval = 200, inline = "mo", group = G_LVL)

color  cPdh = input.color(#2962FF, "PDH", inline = "pdh", group = G_LVL)
string yPdh = input.string("Solid", "", options = ["Solid","Dotted","Dashed"], inline = "pdh", group = G_LVL)
int    wPdh = input.int(2, "", minval = 1, maxval = 4, inline = "pdh", group = G_LVL)
int    oPdh = input.int(0, "", minval = -200, maxval = 200, inline = "pdh", group = G_LVL)

color  cPdl = input.color(#F23645, "PDL", inline = "pdl", group = G_LVL)
string yPdl = input.string("Solid", "", options = ["Solid","Dotted","Dashed"], inline = "pdl", group = G_LVL)
int    wPdl = input.int(2, "", minval = 1, maxval = 4, inline = "pdl", group = G_LVL)
int    oPdl = input.int(0, "", minval = -200, maxval = 200, inline = "pdl", group = G_LVL)

color  cPdEq = input.color(color.gray, "PD.EQ", inline = "pdeq", group = G_LVL)
string yPdEq = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "pdeq", group = G_LVL)
int    wPdEq = input.int(1, "", minval = 1, maxval = 4, inline = "pdeq", group = G_LVL)
int    oPdEq = input.int(0, "", minval = -200, maxval = 200, inline = "pdeq", group = G_LVL)

color  c3dh = input.color(#2962FF, "3DH", inline = "d3h", group = G_LVL)
string y3dh = input.string("Solid", "", options = ["Solid","Dotted","Dashed"], inline = "d3h", group = G_LVL)
int    w3dh = input.int(1, "", minval = 1, maxval = 4, inline = "d3h", group = G_LVL)
int    o3dh = input.int(0, "", minval = -200, maxval = 200, inline = "d3h", group = G_LVL)

color  c3dl = input.color(#F23645, "3DL", inline = "d3l", group = G_LVL)
string y3dl = input.string("Solid", "", options = ["Solid","Dotted","Dashed"], inline = "d3l", group = G_LVL)
int    w3dl = input.int(1, "", minval = 1, maxval = 4, inline = "d3l", group = G_LVL)
int    o3dl = input.int(0, "", minval = -200, maxval = 200, inline = "d3l", group = G_LVL)

color  cPwh = input.color(#2962FF, "PWH", inline = "pwh", group = G_LVL)
string yPwh = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "pwh", group = G_LVL)
int    wPwh = input.int(1, "", minval = 1, maxval = 4, inline = "pwh", group = G_LVL)
int    oPwh = input.int(0, "", minval = -200, maxval = 200, inline = "pwh", group = G_LVL)

color  cPwl = input.color(#F23645, "PWL", inline = "pwl", group = G_LVL)
string yPwl = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "pwl", group = G_LVL)
int    wPwl = input.int(1, "", minval = 1, maxval = 4, inline = "pwl", group = G_LVL)
int    oPwl = input.int(0, "", minval = -200, maxval = 200, inline = "pwl", group = G_LVL)

color  cPmh = input.color(#2962FF, "PMH", inline = "pmh", group = G_LVL)
string yPmh = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "pmh", group = G_LVL)
int    wPmh = input.int(1, "", minval = 1, maxval = 4, inline = "pmh", group = G_LVL)
int    oPmh = input.int(0, "", minval = -200, maxval = 200, inline = "pmh", group = G_LVL)

color  cPml = input.color(#F23645, "PML", inline = "pml", group = G_LVL)
string yPml = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "pml", group = G_LVL)
int    wPml = input.int(1, "", minval = 1, maxval = 4, inline = "pml", group = G_LVL)
int    oPml = input.int(0, "", minval = -200, maxval = 200, inline = "pml", group = G_LVL)

color  cLnH = input.color(#2962FF, "Lunch H", inline = "lnh", group = G_LVL)
string yLnH = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "lnh", group = G_LVL)
int    wLnH = input.int(1, "", minval = 1, maxval = 4, inline = "lnh", group = G_LVL)
int    oLnH = input.int(0, "", minval = -200, maxval = 200, inline = "lnh", group = G_LVL)

color  cLnL = input.color(#F23645, "Lunch L", inline = "lnl", group = G_LVL)
string yLnL = input.string("Dotted", "", options = ["Solid","Dotted","Dashed"], inline = "lnl", group = G_LVL)
int    wLnL = input.int(1, "", minval = 1, maxval = 4, inline = "lnl", group = G_LVL)
int    oLnL = input.int(0, "", minval = -200, maxval = 200, inline = "lnl", group = G_LVL)

int runwayBars = input.int(10, "Right offset (bars)", minval = 0, maxval = 100, group = G_STYLE,
     tooltip = "Every line stops this many bars past the live candle, and its name sits at that end. Nothing runs to the right edge of the chart.")
string labelSize = input.string("small", "Label text size",
     options = ["tiny", "small", "normal", "large"], group = G_STYLE)
float cushionMult = input.float(0.4, "Collision cushion (× ATR14)",
     minval = 0.0, maxval = 1.5, step = 0.1, group = G_STYLE,
     tooltip = "How close two names must be before they count as colliding. A collision moves the upper name right into the next column — never off its own price. Set to zero to disable staggering.")
int labelColStep = input.int(6, "Collision column spacing (bars)", minval = 4, maxval = 60, group = G_STYLE,
     tooltip = "How far right a colliding name is moved. Widen it if long names still overlap at your zoom level.")

// == STYLE RESOLUTION =========================================================

//@function Resolves the label size input to a Pine size constant.
//@param s (simple string) The raw input value.
//@returns (simple string) A size.* constant.
f_lblSize(simple string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

//@function Resolves a line style input to a Pine line style constant.
//@param s (simple string) The raw input value.
//@returns (simple string) A line.style_* constant.
f_lineStyle(simple string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>         line.style_dotted

string LBL_SZ = f_lblSize(labelSize)

//@variable Milliseconds spanned by one chart bar.
int msPerBar = timeframe.in_seconds(timeframe.period) * 1000

//@variable Right-hand edge every line stops at, and where its name sits.
int runwayTime = time + runwayBars * msPerBar

//@variable Vertical distance below which two names count as colliding.
float labelCushion = ta.atr(14) * cushionMult

//@variable Grid subdivision count resolved from the input.
int gridN = switch gridDiv
    "Octants (1/8)"      => 8
    "Sixteenths (1/16)"  => 16
    =>                      4

// == OBJECT STORES ============================================================

var array<line>  gridStore    = array.new<line>(0)
var array<label> gridLabels   = array.new<label>(0)
var array<box>   sessBoxStore = array.new<box>(0)
var array<label> sessLblStore = array.new<label>(0)

//@function Deletes every line in a store and empties it.
//@param store (array<line>) The store to clear.
//@returns (bool) Always true.
clearLines(array<line> store) =>
    while store.size() > 0
        line.delete(store.shift())
    true

//@function Deletes every label in a store and empties it.
//@param store (array<label>) The store to clear.
//@returns (bool) Always true.
clearLabels(array<label> store) =>
    while store.size() > 0
        label.delete(store.shift())
    true

//@function Deletes every box in a store and empties it.
//@param store (array<box>) The store to clear.
//@returns (bool) Always true.
clearBoxes(array<box> store) =>
    while store.size() > 0
        box.delete(store.shift())
    true

//@function Deletes the oldest boxes until the store is within its cap.
//@param store (array<box>) The store to prune.
//@param maxCount (int) Maximum retained boxes.
//@returns (bool) Always true.
pruneBoxes(array<box> store, int maxCount) =>
    while store.size() > maxCount
        box.delete(store.shift())
    true

//@function Deletes the oldest labels until the store is within its cap.
//@param store (array<label>) The store to prune.
//@param maxCount (int) Maximum retained labels.
//@returns (bool) Always true.
pruneLabels(array<label> store, int maxCount) =>
    while store.size() > maxCount
        label.delete(store.shift())
    true

// == PERIOD EXTREMES ==========================================================
// Extremes are tracked on the chart rather than pulled from request.security,
// because a security call returns the VALUE of a period's high but not the
// candle that made it, and the anchor is information: it says WHEN the level
// was set. The cost is that a period only reports once its opening bar is in
// loaded history, which sawStart records.

//@type A period's extremes together with the bar times that formed them.
//@field hi Highest high seen in the period.
//@field lo Lowest low seen in the period.
//@field hiTime Bar time of the candle that made the high.
//@field loTime Bar time of the candle that made the low.
//@field sawStart True only when the period's first bar was in loaded history.
type Extreme
    float hi       = na
    float lo       = na
    int   hiTime   = 0
    int   loTime   = 0
    bool  sawStart = false

//@function Folds one bar into a running period extreme.
//@param this (Extreme) The running extreme.
//@param h (float) Bar high.
//@param l (float) Bar low.
//@param t (int) Bar time.
//@returns (bool) Always true.
method feed(Extreme this, float h, float l, int t) =>
    if na(this.hi) or h > this.hi
        this.hi     := h
        this.hiTime := t
    if na(this.lo) or l < this.lo
        this.lo     := l
        this.loTime := t
    true

//@function Copies an extreme, so a completed period can be stored by value.
//@param this (Extreme) The extreme to copy.
//@returns (Extreme) An independent copy.
method snapshot(Extreme this) =>
    Extreme.new(this.hi, this.lo, this.hiTime, this.loTime, this.sawStart)

// == LEVEL PRIMITIVE ==========================================================
// One drawing set per level for the life of the script. A level whose value
// changes is moved, never redrawn beside its predecessor — "previous day high"
// names exactly one price, so exactly one line carries it.
//
// The line spans from its origin candle to a fixed right-hand edge, and its
// name sits at that end. A left-pointing callout centres its body on the
// anchor, so the text reads on the same eye-line as the price it names. That
// depends on the line stopping: a line running to the chart edge would draw
// straight through its own text.

//@type A horizontal reference level owning exactly one line and one label.
//@field name Short label text, e.g. "PDH".
//@field col Line and text colour.
//@field lnStyle Resolved line.style_* constant.
//@field lineWidth Line width.
//@field labelOff Bars this level's name is shifted from the shared right edge.
//@field price The level's current price.
//@field anchor Bar time of the candle that formed the level.
//@field ln The level's line.
//@field lb The level's label.
type Level
    string name
    color  col
    string lnStyle
    int    lineWidth = 1
    int    labelOff  = 0
    float  price     = na
    int    anchor    = 0
    line   ln        = na
    label  lb        = na

//@function Moves a level to its price and origin, and parks its name at the edge.
//@param this (Level) The level to sync.
//@param newPrice (float) Resolved price, or na when unavailable.
//@param originTime (int) Bar time of the candle that formed it.
//@param show (bool) Whether the level may draw. Gates drawing only.
//@returns (bool) Always true.
method sync(Level this, float newPrice, int originTime, bool show) =>
    bool wanted = show and not na(newPrice) and originTime > 0

    // Guarded blocks rather than if/else: one branch ends on an assignment and
    // another on a void call, and Pine types an if/else as one expression.
    if not wanted and not na(this.ln)
        line.delete(this.ln)
        label.delete(this.lb)
        this.ln    := na
        this.lb    := na
        this.price := na

    if wanted and na(this.ln)
        this.ln := line.new(originTime, newPrice, runwayTime, newPrice,
             xloc  = xloc.bar_time,
             color = this.col,
             width = this.lineWidth,
             style = this.lnStyle)
        this.lb := label.new(runwayTime, newPrice, this.name,
             xloc      = xloc.bar_time,
             style     = label.style_label_left,
             color     = INVISIBLE,
             textcolor = this.col,
             size      = LBL_SZ,
             textalign = text.align_left)
        label.set_text_font_family(this.lb, font.family_monospace)

    if wanted and (na(this.price) or newPrice != this.price or originTime != this.anchor)
        this.price  := newPrice
        this.anchor := originTime
        line.set_xy1(this.ln, originTime, newPrice)

    // The right edge tracks the live candle; the origin never moves.
    if wanted
        line.set_xy2(this.ln, runwayTime, this.price)

    true

//@function Keeps every name on its own price, moving colliding names right.
//@param levels (array<Level>) Every level sharing the right edge.
//@returns (bool) Always true.
f_decollide(array<Level> levels) =>
    array<float> prices = array.new<float>(0)
    array<int>   slots  = array.new<int>(0)

    if levels.size() > 0
        for i = 0 to levels.size() - 1
            Level lv = levels.get(i)
            if not na(lv.lb) and not na(lv.price)
                prices.push(lv.price)
                slots.push(i)

    if prices.size() > 0
        array<int> rank  = prices.sort_indices(order.ascending)
        float      lastY = na
        int        col   = 0
        for k = 0 to rank.size() - 1
            Level lv = levels.get(slots.get(rank.get(k)))
            col := not na(lastY) and labelCushion > 0 and lv.price - lastY < labelCushion ? col + 1 : 0
            // A name always sits ON the price it names — that is the whole point
            // of the left-pointing callout. Resolving a collision by lifting the
            // label off its own line would undo it, so crowding moves the name
            // right instead.
            label.set_y(lv.lb, lv.price)
            label.set_x(lv.lb, runwayTime + (lv.labelOff + col * labelColStep) * msPerBar)
            lastY := lv.price
    true

// == SESSION BOXES ============================================================
// A box per session, growing with the session's own high and low and frozen
// when the window closes. The caption sits BELOW the box at the session open,
// outside it — a session box is wide and short, so a caption inside it lands on
// price action.

//@type One trading session's developing range.
//@field name Caption text.
//@field col Box and caption colour.
//@field wasIn Whether the previous bar was inside this session.
//@field hi Session high so far.
//@field lo Session low so far.
//@field startT Bar time the session opened, for centring the caption.
//@field bx The session's box.
//@field lb The session's caption.
type SessBox
    string name
    color  col
    bool   wasIn  = false
    float  hi     = na
    float  lo     = na
    int    startT = 0
    box    bx     = na
    label  lb     = na

//@function Opens, grows and freezes one session's box.
//@param this (SessBox) The session to run.
//@param inSess (bool) Whether this bar falls inside the session window.
//@param show (bool) Whether the box may draw. Gates drawing only.
//@param transp (int) Fill and border transparency.
//@param keep (int) Sessions retained before the oldest is deleted.
//@returns (bool) Always true.
method run(SessBox this, bool inSess, bool show, int transp, int keep) =>
    bool starting = inSess and not this.wasIn

    if starting
        this.hi     := high
        this.lo     := low
        this.startT := time
        if show
            this.bx := box.new(time, high, time + msPerBar, low,
                 xloc         = xloc.bar_time,
                 border_color = color.new(this.col, transp),
                 border_width = 1,
                 border_style = line.style_dotted,
                 bgcolor      = color.new(this.col, transp))
            sessBoxStore.push(this.bx)
            pruneBoxes(sessBoxStore, keep * 3)

            this.lb := label.new(time, low, this.name,
                 xloc      = xloc.bar_time,
                 style     = label.style_label_up,
                 color     = INVISIBLE,
                 textcolor = this.col,
                 size      = LBL_SZ,
                 textalign = text.align_center)
            label.set_text_font_family(this.lb, font.family_monospace)
            sessLblStore.push(this.lb)
            pruneLabels(sessLblStore, keep * 3)

    if inSess and not starting
        this.hi := math.max(nz(this.hi, high), high)
        this.lo := math.min(nz(this.lo, low), low)

    if inSess and not na(this.bx)
        box.set_top(this.bx, this.hi)
        box.set_bottom(this.bx, this.lo)
        box.set_right(this.bx, time + msPerBar)
        // Centred under the box, re-centring as the window grows. A caption
        // pinned at the session open ends up at the far left of a wide box.
        // The halving is written as a difference because "/" between two ints
        // is float division in Pine.
        label.set_x(this.lb, this.startT + int((time - this.startT) / 2))
        label.set_y(this.lb, this.lo)

    this.wasIn := inSess
    true

// == LIQUIDITY POOLS ==========================================================
// Relative equal highs and lows. Two swing pivots resting within a tick
// tolerance of one another are ONE pool: the orders beyond them are the same
// orders, and price treats the pair as a single destination.
//
// The line is anchored at the EARLIER pivot, because that is when the level was
// set, and it carries the EXTREME of the pair, because that is the price that
// has to trade for the pool to be taken. A pool is a horizontal level with
// liquidity metadata, so it reuses the level primitive and inherits its origin
// anchoring, right-edge naming and collision handling for free.

//@type A relative-equal-price liquidity pool.
//@field lv The drawn level.
//@field price The extreme of the cluster — what must trade to raid it.
//@field startT Bar time of the earliest pivot in the cluster.
//@field isHigh True for buyside (equal highs), false for sellside.
//@field raided True once price has traded through it.
//@field raidT Bar time of the candle that took it. The line ends here.
type Pool
    Level lv
    float price
    int   startT
    bool  isHigh
    bool  raided = false
    int   raidT  = 0

var array<float> phPrice = array.new<float>(0)
var array<int>   phTime  = array.new<int>(0)
//@variable True once price has traded through this stored pivot's price. A
//          pivot whose level is already spent can never form a live pool.
var array<bool>  phSwept = array.new<bool>(0)
var array<float> plPrice = array.new<float>(0)
var array<int>   plTime  = array.new<int>(0)
var array<bool>  plSwept = array.new<bool>(0)
var array<Pool>  pools   = array.new<Pool>(0)

//@variable Equal-price tolerance in price terms, scaled by the instrument.
float liqTol = syminfo.mintick * liqTolTicks

//@variable How many recent pivots per side are held for pairing.
const int PIVOT_MEMORY = 10

//@function Names a pool in the chosen notation.
//@param isHigh (bool) True for buyside.
//@returns (string) The label text.
f_poolName(bool isHigh) =>
    liqNotation == "$$" ? "$$" : isHigh ? "BSL" : "SSL"

//@function Adds a pool unless one already sits at this price on this side.
//@param px (float) The pool's price.
//@param t (int) Bar time of the earliest pivot forming it.
//@param isHigh (bool) True for buyside.
//@returns (bool) Always true.
f_addPool(float px, int t, bool isHigh) =>
    bool exists = false
    if pools.size() > 0
        for i = 0 to pools.size() - 1
            Pool p = pools.get(i)
            if p.isHigh == isHigh and math.abs(p.price - px) <= liqTol
                exists := true
    if not exists
        pools.push(Pool.new(
             Level.new(f_poolName(isHigh), liqCol, line.style_solid, liqWidth, 0),
             px, t, isHigh))
        while pools.size() > liqKeep + liqKeepRaided
            Pool old = pools.shift()
            line.delete(old.lv.ln)
            label.delete(old.lv.lb)
    true

//@function Trims spent pools to the retained count, oldest removed first.
//@param keep (int) How many raided pools may stay on the chart.
//@returns (bool) Always true.
f_pruneRaided(int keep) =>
    int excess = 0
    if pools.size() > 0
        for i = 0 to pools.size() - 1
            if pools.get(i).raided
                excess += 1
    excess := excess - keep

    // The store is oldest-first, so the first raided entry found is the oldest.
    // Removing by search rather than by index walk keeps this correct while the
    // array shrinks underneath it.
    while excess > 0
        int at = -1
        if pools.size() > 0
            for i = 0 to pools.size() - 1
                if at < 0 and pools.get(i).raided
                    at := i
        if at < 0
            excess := 0
        else
            Pool old = pools.get(at)
            line.delete(old.lv.ln)
            label.delete(old.lv.lb)
            pools.remove(at)
            excess := excess - 1
    true

//@function True when a drawn level already names this price.
//@param levels (array<Level>) The level store.
//@param price (float) The price to test.
//@param tol (float) Tolerance, in price.
//@returns (bool) True if a level with a visible name sits within tolerance.
f_alreadyNamed(array<Level> levels, float price, float tol) =>
    bool hit = false
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            Level lv = levels.get(i)
            if not na(lv.price) and not na(lv.lb) and math.abs(lv.price - price) <= tol
                hit := true
    hit

// == TIME ENGINE ==============================================================

//@function True when the current bar falls inside a New York session window.
//@param sess (simple string) Session specification, e.g. "0200-0500".
//@returns (bool) True if the bar sits inside the window.
f_inSess(simple string sess) =>
    not na(time(timeframe.period, sess, TZ))

//@variable Opening timestamp of the current New York trading day (00:00 NY).
int nyDayStart = time("D", "0000-0000", TZ)

//@variable True on the first chart bar of a new New York day.
bool isNewNyDay = not na(nyDayStart) and nyDayStart != nz(nyDayStart[1], 0)

// Week and month identity derive from the New York day stamp. No
// timeframe.change("W"), which is unsafe on futures, and no day-of-week
// arithmetic that could silently drop a session.
int nyDow = dayofweek(nyDayStart, TZ)
// int(...) rather than a bare divide: "/" between two ints is float division in
// Pine, and a float will not assign to an int declaration.
int dayNum  = int(nz(nyDayStart, 0) / 86400000)
int weekId  = dayNum - (nyDow - 1)
int monthId = year(nyDayStart, TZ) * 12 + month(nyDayStart, TZ)

bool isNewNyWeek  = isNewNyDay and weekId  != nz(weekId[1], weekId)
bool isNewNyMonth = isNewNyDay and monthId != nz(monthId[1], monthId)

bool inAlgoRange = f_inSess(sessAlgoRange)
bool inJudas     = f_inSess(sessJudas)
bool inLunch     = f_inSess(sessLunch)

// Session windows are resolved here; the boxes themselves are drawn further
// down, once the grid's anchor candle is known and can bound them.
bool inAsia = f_inSess(sessAsia)
bool inLon  = f_inSess(sessLon)
bool inNy   = f_inSess(sessNy)

// == MIDNIGHT OPEN ============================================================
// Captured unconditionally: the display toggle gates drawing only, because the
// Judas read measures against this level.

//@variable Opening price of the current New York day.
var float midnightOpen = na
//@variable Bar time of the 00:00 NY candle that set the open.
var int midnightTime = 0

if isNewNyDay
    midnightOpen := open
    midnightTime := time

// == PERIOD TRACKING ==========================================================

var Extreme dayRun    = Extreme.new()
var Extreme weekRun   = Extreme.new()
var Extreme monthRun  = Extreme.new()
var Extreme prevWeek  = Extreme.new()
var Extreme prevMonth = Extreme.new()

//@variable Completed New York days, newest first.
var array<Extreme> days = array.new<Extreme>(0)

if isNewNyMonth
    if not na(monthRun.hi)
        prevMonth := monthRun.snapshot()
    monthRun := Extreme.new(sawStart = true)

if isNewNyWeek
    if not na(weekRun.hi)
        prevWeek := weekRun.snapshot()
    weekRun := Extreme.new(sawStart = true)

if isNewNyDay
    if not na(dayRun.hi)
        days.unshift(dayRun.snapshot())
        while days.size() > 4
            days.pop()
    dayRun := Extreme.new(sawStart = true)

dayRun.feed(high, low, time)
weekRun.feed(high, low, time)
monthRun.feed(high, low, time)

//@function Highest high across the newest n completed days, with its origin.
//@param store (array<Extreme>) Completed days, newest first.
//@param n (int) How many days to span.
//@returns ([float, int]) The high and the bar time that formed it.
f_spanHigh(array<Extreme> store, int n) =>
    float best = na
    int   at   = 0
    int   lim  = math.min(n, store.size())
    if lim > 0
        for i = 0 to lim - 1
            Extreme e = store.get(i)
            if not na(e.hi) and (na(best) or e.hi > best)
                best := e.hi
                at   := e.hiTime
    [best, at]

//@function Lowest low across the newest n completed days, with its origin.
//@param store (array<Extreme>) Completed days, newest first.
//@param n (int) How many days to span.
//@returns ([float, int]) The low and the bar time that formed it.
f_spanLow(array<Extreme> store, int n) =>
    float best = na
    int   at   = 0
    int   lim  = math.min(n, store.size())
    if lim > 0
        for i = 0 to lim - 1
            Extreme e = store.get(i)
            if not na(e.lo) and (na(best) or e.lo < best)
                best := e.lo
                at   := e.loTime
    [best, at]

[pdh, pdhAt] = f_spanHigh(days, 1)
[pdl, pdlAt] = f_spanLow(days, 1)
[hh3, hh3At] = f_spanHigh(days, 3)
[ll3, ll3At] = f_spanLow(days, 3)

//@variable Equilibrium of the previous day's range.
float pdEq = na(pdh) or na(pdl) ? na : (pdh + pdl) / 2.0
// The midpoint has no candle of its own, so it takes the later of the two
// extremes defining it — the bar from which the range was fully known.
int pdEqAt = math.max(pdhAt, pdlAt)

// == SWING PAIR ===============================================================
// The two swings are kept alternating. ta.pivothigh and ta.pivotlow are
// independent detectors, so a chart can print several highs with no qualifying
// low between them; taking the latest of each would pair a recent high with a
// low from a different move and call the result one leg. A same-side pivot
// therefore replaces the stored one only when it is more extreme, while an
// opposite-side pivot always begins the next leg.

var float swingHi   = na
var float swingLo   = na
var int   swingHiAt = 0
var int   swingLoAt = 0
//@variable Side of the most recently accepted pivot: 1 high, -1 low, 0 none.
var int   legSide   = 0

float pivotHi = ta.pivothigh(high, swingLen, swingLen)
float pivotLo = ta.pivotlow(low, swingLen, swingLen)

if barstate.isconfirmed
    if not na(pivotHi) and (legSide != 1 or na(swingHi) or pivotHi >= swingHi)
        swingHi   := pivotHi
        swingHiAt := time[swingLen]
        legSide   := 1
    if not na(pivotLo) and (legSide != -1 or na(swingLo) or pivotLo <= swingLo)
        swingLo   := pivotLo
        swingLoAt := time[swingLen]
        legSide   := -1

// == NY LUNCH RANGE ===========================================================
// Tracked live and frozen when the window closes, so the level that carries
// into the afternoon is the completed range rather than a moving one.

var Extreme lunchRun  = Extreme.new()
var Extreme lunchDone = Extreme.new()

if isNewNyDay
    // Yesterday's lunch retires with yesterday. Between midnight and 13:00 there
    // is no completed lunch range, and showing the previous day's in its place
    // would be a level with the wrong date attached to it.
    lunchRun  := Extreme.new(sawStart = true)
    lunchDone := Extreme.new()

if inLunch
    lunchRun.feed(high, low, time)

if not inLunch and inLunch[1] and not na(lunchRun.hi)
    lunchDone := lunchRun.snapshot()

// == REH / REL DETECTION ======================================================
// Both ta.* calls sit at global scope. They carry bar-to-bar state, and Pine
// short-circuits "and", so putting them behind a condition would skip them on
// the bars the condition is false and corrupt their own history.

//@variable Extremes across the pivot's confirmation lag, to catch a pool that
//          price already swept while the pivot was still confirming.
float sinceHi = ta.highest(high, swingLen + 1)
float sinceLo = ta.lowest(low, swingLen + 1)

// Detection is never gated on the display toggle: hiding the pools must not
// stop them being found, or turning them back on would show an empty chart.
if barstate.isconfirmed
    // Retire any stored pivot whose price has since been traded through. This
    // runs BEFORE pairing and is the whole reason a pool can be trusted: two
    // pivots at one price are only a live pool if that price was never taken
    // BETWEEN them, and the gap between two pivots can be hours.
    if phPrice.size() > 0
        for i = 0 to phPrice.size() - 1
            if high > phPrice.get(i)
                phSwept.set(i, true)
    if plPrice.size() > 0
        for i = 0 to plPrice.size() - 1
            if low < plPrice.get(i)
                plSwept.set(i, true)

    if not na(pivotHi)
        bool paired = false
        if phPrice.size() > 0
            for i = 0 to phPrice.size() - 1
                if not paired and not phSwept.get(i) and math.abs(phPrice.get(i) - pivotHi) <= liqTol
                    paired := true
                    // The pool sits at the higher of the pair: that is the price
                    // that has to trade for the resting orders to be reached.
                    // It therefore anchors at the candle that MADE that high,
                    // whichever of the two that is — a line starting at the
                    // lower pivot would begin at a bar that never set it. Ties
                    // go to the earlier candle.
                    float lvl = math.max(phPrice.get(i), pivotHi)
                    int originT = phPrice.get(i) >= pivotHi ? phTime.get(i) : time[swingLen]
                    // sinceHi covers the new pivot's own confirmation lag.
                    if sinceHi <= lvl
                        f_addPool(lvl, originT, true)
        phPrice.unshift(pivotHi)
        phTime.unshift(time[swingLen])
        phSwept.unshift(false)
        while phPrice.size() > PIVOT_MEMORY
            phPrice.pop()
            phTime.pop()
            phSwept.pop()

    if not na(pivotLo)
        bool pairedLo = false
        if plPrice.size() > 0
            for i = 0 to plPrice.size() - 1
                if not pairedLo and not plSwept.get(i) and math.abs(plPrice.get(i) - pivotLo) <= liqTol
                    pairedLo := true
                    float lvl = math.min(plPrice.get(i), pivotLo)
                    int originT = plPrice.get(i) <= pivotLo ? plTime.get(i) : time[swingLen]
                    if sinceLo >= lvl
                        f_addPool(lvl, originT, false)
        plPrice.unshift(pivotLo)
        plTime.unshift(time[swingLen])
        plSwept.unshift(false)
        while plPrice.size() > PIVOT_MEMORY
            plPrice.pop()
            plTime.pop()
            plSwept.pop()

// Raids. A wick is a sweep — liquidity is taken the moment price trades to it,
// and it does not need a close through. So this compares against the bar's HIGH
// and LOW, and unlike every other detection in this script it is NOT gated on
// barstate.isconfirmed: waiting for the close would leave a pool drawn for the
// rest of a forming bar after price had already taken it. That cannot repaint,
// because a bar's high only ever rises and its low only ever falls — a sweep
// once printed is never un-printed.
// Iterated backwards so removing an entry cannot shift the ones still to check.
if pools.size() > 0
    for i = pools.size() - 1 to 0
        Pool p = pools.get(i)
        if not p.raided and (p.isHigh ? high > p.price : low < p.price)
            p.raided := true
            p.raidT  := time
            if liqOnRaid == "Delete"
                line.delete(p.lv.ln)
                label.delete(p.lv.lb)
                pools.remove(i)

f_pruneRaided(liqOnRaid == "Delete" ? 0 : liqKeepRaided)

// == LEVELS ===================================================================

var Level lvMo   = Level.new("Midnight Open", cMo,   f_lineStyle(yMo),   wMo,   oMo)
var Level lvPmh  = Level.new("PMH",   cPmh,  f_lineStyle(yPmh),  wPmh,  oPmh)
var Level lvPml  = Level.new("PML",   cPml,  f_lineStyle(yPml),  wPml,  oPml)
var Level lvPwh  = Level.new("PWH",   cPwh,  f_lineStyle(yPwh),  wPwh,  oPwh)
var Level lvPwl  = Level.new("PWL",   cPwl,  f_lineStyle(yPwl),  wPwl,  oPwl)
var Level lv3dh  = Level.new("3DH",   c3dh,  f_lineStyle(y3dh),  w3dh,  o3dh)
var Level lv3dl  = Level.new("3DL",   c3dl,  f_lineStyle(y3dl),  w3dl,  o3dl)
var Level lvPdh  = Level.new("PDH",   cPdh,  f_lineStyle(yPdh),  wPdh,  oPdh)
var Level lvPdl  = Level.new("PDL",   cPdl,  f_lineStyle(yPdl),  wPdl,  oPdl)
var Level lvPdEq = Level.new("PD.EQ", cPdEq, f_lineStyle(yPdEq), wPdEq, oPdEq)
var Level lvLnH  = Level.new("Lunch H", cLnH, f_lineStyle(yLnH), wLnH, oLnH)
var Level lvLnL  = Level.new("Lunch L", cLnL, f_lineStyle(yLnL), wLnL, oLnL)

//@variable Every fixed level. Liquidity pools join them for the collision pass.
var array<Level> allLevels = array.from(
     lvMo, lvPmh, lvPml, lvPwh, lvPwl, lv3dh, lv3dl, lvPdh, lvPdl, lvPdEq,
     lvLnH, lvLnL)

// The week and month levels draw only once their opening bar has been seen. A
// partial period would report an extreme that is merely the earliest loaded
// bar, anchored to a candle that did not set it.
lvMo.sync(midnightOpen, midnightTime, showMidnightOpen)
lvPmh.sync(prevMonth.hi, prevMonth.hiTime, showPrevMonth and prevMonth.sawStart)
lvPml.sync(prevMonth.lo, prevMonth.loTime, showPrevMonth and prevMonth.sawStart)
lvPwh.sync(prevWeek.hi,  prevWeek.hiTime,  showPrevWeek and prevWeek.sawStart)
lvPwl.sync(prevWeek.lo,  prevWeek.loTime,  showPrevWeek and prevWeek.sawStart)
lv3dh.sync(hh3, hh3At, show3Day)
lv3dl.sync(ll3, ll3At, show3Day)
lvPdh.sync(pdh, pdhAt, showPrevDay)
lvPdl.sync(pdl, pdlAt, showPrevDay)
lvPdEq.sync(pdEq, pdEqAt, showPrevDay and showPdEq)
lvLnH.sync(lunchDone.hi, lunchDone.hiTime, showLunch)
lvLnL.sync(lunchDone.lo, lunchDone.loTime, showLunch)

// Pools share the right edge with the fixed levels, so they de-collide in the
// same pass — a "$$" landing on PDH would otherwise print two names on one price.
array<Level> shownLevels = array.copy(allLevels)
if pools.size() > 0
    for i = 0 to pools.size() - 1
        Pool p = pools.get(i)
        p.lv.sync(p.price, p.startT, showLiq)
        // Where a named level already sits on the pool's price, the pool keeps
        // its LINE and drops its NAME. Staggering the two apart cannot be
        // relied on: the stagger is measured in bars, and on a 1-minute chart
        // six bars is a few pixels — far too little to clear "Midnight Open".
        // One price, one name, and the level's own name is the better one.
        // The name-suppression test only applies to LIVE pools, which park at
        // the right edge alongside the level names. A raided pool's name sits
        // back at the sweep and cannot collide with them.
        bool named = p.raided or not f_alreadyNamed(allLevels, p.price, labelCushion)
        if not na(p.lv.lb)
            label.set_text(p.lv.lb, named ? f_poolName(p.isHigh) : "")
        if named and not p.raided
            shownLevels.push(p.lv)

f_decollide(shownLevels)

// A raided pool ends at the candle that took it. Applied after the collision
// pass, which parks the live names at the right edge and must not touch these.
if pools.size() > 0
    for i = 0 to pools.size() - 1
        Pool p = pools.get(i)
        if p.raided and p.raidT > 0 and not na(p.lv.ln)
            line.set_xy2(p.lv.ln, p.raidT, p.price)
            line.set_style(p.lv.ln, line.style_dotted)
            if not na(p.lv.lb)
                label.set_xy(p.lv.lb, p.raidT, p.price)

// == GRID RANGE ===============================================================
// The grid divides a range bounded by two named levels, so it originates from
// real structure rather than a fixed clock window. Both ends carry their own
// origin candle, and the grid starts at the earlier of the two.

//@function Resolves a named anchor to its price and the bar time that formed it.
//@param sel (simple string) The anchor name from the input list.
//@returns ([float, int]) Price and origin bar time. Price is na when unavailable.
f_anchor(simple string sel) =>
    float p = na
    int   t = 0
    if sel == "PDH"
        p := pdh
        t := pdhAt
    else if sel == "PDL"
        p := pdl
        t := pdlAt
    else if sel == "CDH"
        p := dayRun.hi
        t := dayRun.hiTime
    else if sel == "CDL"
        p := dayRun.lo
        t := dayRun.loTime
    else if sel == "3DH"
        p := hh3
        t := hh3At
    else if sel == "3DL"
        p := ll3
        t := ll3At
    else if sel == "PWH"
        p := prevWeek.hi
        t := prevWeek.hiTime
    else if sel == "PWL"
        p := prevWeek.lo
        t := prevWeek.loTime
    else if sel == "PMH"
        p := prevMonth.hi
        t := prevMonth.hiTime
    else if sel == "PML"
        p := prevMonth.lo
        t := prevMonth.loTime
    else if sel == "Swing High"
        p := swingHi
        t := swingHiAt
    else if sel == "Swing Low"
        p := swingLo
        t := swingLoAt
    else if sel == "Midnight Open"
        p := midnightOpen
        t := midnightTime
    [p, t]

//@function Greatest common divisor, for reducing a grid fraction to lowest terms.
//@param a (int) First value.
//@param b (int) Second value.
//@returns (int) The greatest common divisor.
f_gcd(int a, int b) =>
    int x = a
    int y = b
    while y != 0
        int carry = y
        y := x % y
        x := carry
    x

//@function Names a grid level: its equilibrium, or a fraction in lowest terms.
//@param i (int) Step index from the bottom boundary.
//@param n (int) Total subdivisions.
//@returns (string) The label text. Empty at the boundaries, which carry their
//         own level names.
f_gridText(int i, int n) =>
    string outText = ""
    if i == 0 or i == n
        outText := ""
    else if i * 2 == n
        outText := "EQ"
    else
        int g = f_gcd(i, n)
        outText := str.tostring(int(i / g)) + "/" + str.tostring(int(n / g))
    outText

[gridTopPrice, gridTopAt] = f_anchor(gridTopSel)
[gridBotPrice, gridBotAt] = f_anchor(gridBotSel)

float gridHi = na(gridTopPrice) or na(gridBotPrice) ? na : math.max(gridTopPrice, gridBotPrice)
float gridLo = na(gridTopPrice) or na(gridBotPrice) ? na : math.min(gridTopPrice, gridBotPrice)
int   gridAt = math.min(gridTopAt <= 0 ? gridBotAt : gridTopAt, gridBotAt <= 0 ? gridTopAt : gridBotAt)

string GRID_STYLE = f_lineStyle(gridStyleSel)

// == SESSION BOXES — DRAWN =====================================================
// Bounded to the span the active grid range covers: a box opens only on or
// after the grid's anchor candle, so the sessions describe the range being
// worked rather than running back across the whole chart. With no range
// resolved there is nothing to bound them to, and they draw normally.

var SessBox sbAsia = SessBox.new("A",  colAsia)
var SessBox sbLon  = SessBox.new("L",  colLon)
var SessBox sbNy   = SessBox.new("NY", colNy)

bool inGridSpan = gridAt <= 0 or time >= gridAt

sbAsia.run(inAsia and inGridSpan, showSessions, sessTransp, sessKeep)
sbLon.run(inLon and inGridSpan,   showSessions, sessTransp, sessKeep)
sbNy.run(inNy and inGridSpan,     showSessions, sessTransp, sessKeep)

if not showSessions and sessBoxStore.size() > 0
    clearBoxes(sessBoxStore)
    clearLabels(sessLblStore)

// Delete-then-redraw on the live bar: CDH and the swing anchors move as the day
// develops, so the grid follows them rather than being anchored once.
if barstate.islast
    clearLines(gridStore)
    clearLabels(gridLabels)

    bool gridOk = showGrid and not na(gridHi) and not na(gridLo) and gridHi > gridLo and gridAt > 0
    if gridOk
        float step = (gridHi - gridLo) / gridN
        for i = 0 to gridN
            float lvl   = gridLo + i * step
            bool  isEdge = i == 0 or i == gridN
            bool  isEq   = i * 2 == gridN
            color col   = isEq ? gridEqCol : isEdge ? gridCol : color.new(gridCol, gridTransp)

            // A boundary is the anchor level itself, which draws its own line
            // from its own origin candle. Drawing it here as well puts a second
            // line on one price, beginning at a bar that did not form it.
            if gridEdges or not isEdge
                line gl = line.new(gridAt, lvl, runwayTime, lvl,
                     xloc  = xloc.bar_time,
                     color = col,
                     width = gridWidth,
                     style = isEdge ? line.style_solid : GRID_STYLE)
                gridStore.push(gl)

            // A grid fraction never re-names a price a level already names. On a
            // PDL to PDH grid the midpoint IS PD.EQ, so both would tag one line.
            bool wantText = gridLabelMode == "Every level" or
                 (gridLabelMode == "Quarters + EQ" and (isEq or i * 4 == gridN or i * 4 == gridN * 3))
            string txt = f_gridText(i, gridN)
            if wantText and txt != "" and not f_alreadyNamed(allLevels, lvl, syminfo.mintick * 2)
                label gt = label.new(runwayTime + gridLabelOff * msPerBar, lvl, txt,
                     xloc      = xloc.bar_time,
                     style     = label.style_label_left,
                     color     = INVISIBLE,
                     textcolor = col,
                     size      = LBL_SZ,
                     textalign = text.align_left)
                label.set_text_font_family(gt, font.family_monospace)
                gridLabels.push(gt)

// == 12AM–2AM ALGORITHMIC RANGE ===============================================

var float rangeHigh  = na
var float rangeLow   = na
var int   rangeStart = 0
var int   rangeEnd   = 0
var bool  rangeReady = false
var box   rangeBox   = na

if isNewNyDay
    // A new day retires the previous range and every state hanging off it.
    rangeHigh  := na
    rangeLow   := na
    rangeStart := 0
    rangeEnd   := 0
    rangeReady := false
    box.delete(rangeBox)
    rangeBox   := na

if inAlgoRange
    if rangeStart == 0
        rangeStart := time
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow,  low)
    rangeEnd  := time

// The range freezes on the first bar after the window closes.
if not inAlgoRange and inAlgoRange[1] and not na(rangeHigh)
    rangeReady := true

if rangeReady and showRange and na(rangeBox) and rangeEnd > rangeStart
    rangeBox := box.new(rangeStart, rangeHigh, rangeEnd, rangeLow,
         xloc         = xloc.bar_time,
         border_color = color.new(color.black, 80),
         border_width = 1,
         border_style = line.style_dotted,
         bgcolor      = color.new(color.black, 88))

// == JUDAS STATE MACHINE ======================================================
// Bearish read: during the Judas window price trades up through the range high
// and the Midnight Open, then a confirmed close returns inside the range. The
// mirror applies for the bullish case. Once armed, a confirmed close back
// through the swept extreme invalidates the read — the manipulation failed —
// and an opposite sweep may then arm the other way.

var bool   sweptAbove = false
var bool   sweptBelow = false
var string biasState  = "UNSET"

if isNewNyDay
    sweptAbove := false
    sweptBelow := false
    biasState  := "UNSET"

if rangeReady and barstate.isconfirmed and not na(midnightOpen)
    // A sweep must clear both the range boundary and the Midnight Open, so that
    // "returning inside" always describes price that genuinely left the range.
    if inJudas and high > rangeHigh and high > midnightOpen
        sweptAbove := true
    if inJudas and low < rangeLow and low < midnightOpen
        sweptBelow := true

    // Arming — the return inside may complete after the Judas window closes.
    if sweptAbove and close < rangeHigh and biasState != "BEARISH"
        biasState := "BEARISH"
    if sweptBelow and close > rangeLow and biasState != "BULLISH"
        biasState := "BULLISH"

    // Invalidation — the swept extreme is reclaimed on a close.
    if biasState == "BEARISH" and close > rangeHigh
        biasState  := "INVALIDATED"
        sweptAbove := false
    if biasState == "BULLISH" and close < rangeLow
        biasState  := "INVALIDATED"
        sweptBelow := false

// == CONSOLE ==================================================================
// Verdict first, silent rows dropped.

var table console = table.new(position.top_right, 2, 4, border_width = 0,
     frame_color = color.black, frame_width = 1)

if barstate.islast and showConsole
    table.clear(console, 0, 0, 1, 3)
    color verdictCol = biasState == "BULLISH" ? C_BULL :
         biasState == "BEARISH" ? C_BEAR : color.black

    table.cell(console, 0, 0, "BIAS", text_color = color.black, bgcolor = color.white,
         text_size = LBL_SZ, text_font_family = font.family_monospace)
    table.cell(console, 1, 0, biasState, text_color = verdictCol, bgcolor = color.white,
         text_size = LBL_SZ, text_font_family = font.family_monospace,
         text_formatting = text.format_bold)

    int row = 1
    if rangeReady and not na(rangeHigh)
        table.cell(console, 0, row, "12–2AM", text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)
        table.cell(console, 1, row, str.tostring(rangeLow, format.mintick) + " – " +
             str.tostring(rangeHigh, format.mintick),
             text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)
        row += 1

    if sweptAbove or sweptBelow
        table.cell(console, 0, row, "Judas", text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)
        table.cell(console, 1, row, sweptAbove ? "swept high" : "swept low",
             text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)
        row += 1

    if showGrid and not na(gridHi)
        table.cell(console, 0, row, "Grid", text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)
        table.cell(console, 1, row, gridBotSel + " → " + gridTopSel + "  " + gridDiv,
             text_color = color.black, bgcolor = color.white,
             text_size = LBL_SZ, text_font_family = font.family_monospace)

// == ALERTS ===================================================================

alertcondition(biasState == "BULLISH" and biasState[1] != "BULLISH",
     "Bias armed bullish", "Grid Ranges+: bullish sweep and return confirmed on {{ticker}}")
alertcondition(biasState == "BEARISH" and biasState[1] != "BEARISH",
     "Bias armed bearish", "Grid Ranges+: bearish sweep and return confirmed on {{ticker}}")
alertcondition(biasState == "INVALIDATED" and biasState[1] != "INVALIDATED",
     "Bias invalidated", "Grid Ranges+: swept extreme reclaimed on {{ticker}}")
````
