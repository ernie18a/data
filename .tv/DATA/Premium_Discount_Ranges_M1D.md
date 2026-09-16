<!-- tradingview-pine-id: PUB;c7f1f9f79cb24e408576d9cf59b030fe -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Premium + Discount Ranges (M1D)

Source: https://www.tradingview.com/script/0jee3HkL-Premium-Discount-Ranges-M1D/

## Description

Premium + Discount Ranges 
Measures the range you are trading inside, the way it is read by eye from the newest swing point on a chosen timeframe across to the swing of the opposite kind, split into premium and discount either side of an equilibrium. Three ranges can run at once, each on its own timeframe, so an execution range can be read inside the higher one that frames it.

Two ways to bound a range

Period takes the timeframe's own high and low so far: one month is one range, it starts empty at the open and is gone at the rollover. It answers where price sits in the month.

Swing takes the newest confirmed swing high across to the newest swing low on that same timeframe, which owes nothing to the calendar and can run across many periods. It answers which structural range price is inside right now.

Each range picks its own mode, and the chart says which: "1M High" is this month's high, "1M Swing High" is the monthly swing high.

What counts as a swing

A swing is a level price actually turned at, not merely a high that sits above its neighbours while price kept running the same way. The candle has to hold the extreme against a chosen number of candles either side of it, and by default it also has to mark the change of direction — a swing high on the turn from an up candle to a down one, a swing low on the turn from down to up. That second condition can be switched off to accept any candle holding the extreme, regardless of what it turned into.

Every swing is read from candles already closed on its own timeframe, one bar clear of the newest bar, so nothing on a forming higher-timeframe candle can confirm or unconfirm it.

The raided edge

A confirmed swing is the last level price turned at, which is not always the edge of the range being traded right now — the moment a boundary is taken, the real range is already wider than the swings describe. Each boundary is carried out to the extreme price has actually reached since its swing confirmed, and draws dotted while it is out there: a level price has not yet turned at is a raid in progress, not structure. It settles back to solid the moment a new swing confirms behind it. This can be switched off to pin both boundaries to confirmed swings only, with price free to trade outside the range.

Direction and shading

The range is read from whichever swing formed most recently. A new swing low means price has already turned up away from it, so the leg is bullish and discount is the side being worked from; a new swing high reads the other way. The first range is shaded premium and discount by default; the shading can optionally lean toward the side being worked from, fading the other side back. Ranges two and three draw as bare levels by default so a bias range never muddies the range being traded.

Anchoring and labels

Every boundary starts at the candle that set it, never drawn back across bars that closed before that price existed. The equilibrium and the shading begin at the later of the two swings, because a range has no midpoint until both ends exist.

Each range's names can follow the global label settings or override them: centred over the range's own span, to the left, to the right, at the swing that set the level, or off. Two names landing on the same price are merged into one label rather than left stacked; two that land close together without being the same level are separated by a blank line rather than overlapping.

The readout

One panel, two blocks. The first names each active range's timeframe, whether it fits under the chart's own timeframe, which way it is working, which half of it price is trading in, and how far through it price has travelled. The second is a calendar statistic rather than a swing one: the average daily, weekly and monthly range over a chosen number of completed periods, how much of that average the current period has already used, and a countdown to the period's close.

Alerts

Six. Price crossing into premium, price crossing into discount, price trading the equilibrium, the range high taken, the range low taken, and a new swing redrawing the range. All six read the range being traded — range one.

Method and repainting

Swings on ranges two and three are read on their own timeframe via a higher-timeframe request; range one's swing test is likewise timeframe-bound to whichever timeframe is chosen for it. Every swing reads only candles already closed, one bar back, so nothing about it depends on lookahead revealing an unclosed bar.

A confirmed boundary moves only when a genuinely new swing prints. The one part of the drawing that is live by design is a boundary carried out to a raid in progress, and it draws dotted so that is visible rather than implied.

What it will not do

It places no entries, exits, stops or targets, and it does not size a position. It draws no trend line, no bias score and no target projection beyond the range itself. It does not identify order blocks, fair value gaps or liquidity pools — only the swing highs and lows that bound the range and the equilibrium between them.

Settings

Per range: on/off, timeframe, Period or Swing, label placement override, swing strength, premium/discount shading, boundary width. Swing definition: whether a direction turn is required, whether a raided boundary is carried out to price. Shading: premium and discount colours, transparency, whether the shading leans with direction and by how much. Lines: boundary and equilibrium colour and width, how far boundaries extend past the last bar. Labels: side and nudge for the high, low and equilibrium of each range, whether premium/discount get their own names, the collision distance that separates two close labels, whether price is shown in the label, label size and colour. Readout: show/hide, position, size. Average ranges: show/hide, lookback length for each of daily, weekly and monthly, and whether the close countdown is shown.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
//@version=6
indicator("Premium + Discount Ranges (M1D)", "Prem+Disc (M1D)", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

const string BUILD = "b2"
if barstate.isfirst
    log.info("Premium + Discount Ranges (M1D) BUILD " + BUILD)

// == INPUTS - RANGES =========================================================
// Each range is independent: its own timeframe, its own swing strength, its own
// boundary weight. Range 1 is the one being traded and carries the shading;
// ranges 2 and 3 are context and default to bare levels.

const string G1 = "Range 1 - traded"
const string G2 = "Range 2 - context"
const string G3 = "Range 3 - context"

const string TF_TIP = "Which timeframe the range is built from. The range itself draws on every chart timeframe below it - a 4H range read on a 5m chart is the point of the tool."
const string LEN_TIP = "Swing source only. How many candles either side of the swing candle must fail to exceed it. 1 is the short-term swing of that timeframe and is the usual read. Raise it to hold a wider, slower range."

// Two ways to bound a range, and they answer different questions.
//
//   Period - THIS period's own high and low. One month is one range. It starts empty at
//            the open and fills out as the period trades, and it is gone at the rollover.
//            The plain "where are we in the month" read.
//   Swing  - the newest confirmed swing high across to the newest swing low, on that same
//            timeframe. It ignores period boundaries entirely, so a monthly swing range
//            can span half a year. The wider structural read.
//
// The same word means different things under each, which is why the names on the chart say
// so: "1M High" is this month's high, "1M Swing High" is the monthly swing high.
const string SRC_TIP = "Period: this period's own high and low - one month is one range, one week is one range, and it resets at the rollover. Swing: the newest confirmed swing high across to the newest swing low on that timeframe, which ignores period boundaries and can span many of them. Period answers where price sits in the month; Swing answers which structural range price is inside."

// Every range naming itself down the same right-hand edge is what crowds that edge. A wide
// range has the whole width of its own span to be named across instead, so it can step out
// of the column and leave it to the ranges that have nowhere else to go.
const string LBL_TIP = "Where this range's own names sit, overriding the per-level sides under Labels. Centred puts the high above its line and the low below it, both centred across the range's own span - which takes a wide range out of the right-hand column and leaves that column to the tighter ones. Global follows the Labels group as before."

bool   on1    = input.bool(true, "Show", group = G1, inline = "a")
string tfPick1 = input.string("4H", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G1, inline = "a", tooltip = TF_TIP)
string srcPick1 = input.string("Swing", "Range from", options = ["Period", "Swing"], group = G1, tooltip = SRC_TIP)
string lblMode1 = input.string("Global", "Label placement", options = ["Global", "Centred", "Right", "Left", "Off"], group = G1, tooltip = LBL_TIP)
int    len1   = input.int(1, "Swing strength", minval = 1, maxval = 20, group = G1, tooltip = LEN_TIP)
bool   shade1 = input.bool(true, "Shade premium / discount", group = G1)
int    wid1   = input.int(2, "Boundary width", minval = 1, maxval = 4, group = G1, tooltip = "The two boundaries are the range's buyside and sellside liquidity, so they carry the liquidity weight of 2 by default. The equilibrium stays at 1.")

bool   on2    = input.bool(true, "Show", group = G2, inline = "b")
string tfPick2 = input.string("Daily", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G2, inline = "b", tooltip = TF_TIP)
string srcPick2 = input.string("Period", "Range from", options = ["Period", "Swing"], group = G2, tooltip = SRC_TIP)
string lblMode2 = input.string("Global", "Label placement", options = ["Global", "Centred", "Right", "Left", "Off"], group = G2, tooltip = LBL_TIP)
int    len2   = input.int(1, "Swing strength", minval = 1, maxval = 20, group = G2, tooltip = LEN_TIP)
bool   shade2 = input.bool(false, "Shade premium / discount", group = G2)
int    wid2   = input.int(1, "Boundary width", minval = 1, maxval = 4, group = G2)

bool   on3    = input.bool(false, "Show", group = G3, inline = "c")
string tfPick3 = input.string("Weekly", "", options = ["1H", "4H", "12H", "Daily", "Weekly", "Monthly"], group = G3, inline = "c", tooltip = TF_TIP)
string srcPick3 = input.string("Period", "Range from", options = ["Period", "Swing"], group = G3, tooltip = SRC_TIP)
string lblMode3 = input.string("Centred", "Label placement", options = ["Global", "Centred", "Right", "Left", "Off"], group = G3, tooltip = LBL_TIP)
int    len3   = input.int(1, "Swing strength", minval = 1, maxval = 20, group = G3, tooltip = LEN_TIP)
bool   shade3 = input.bool(false, "Shade premium / discount", group = G3)
int    wid3   = input.int(1, "Boundary width", minval = 1, maxval = 4, group = G3)

// == INPUTS - SWING DEFINITION ===============================================

const string G_SW = "Swing definition"

bool requireTurn = input.bool(true, "Require a direction turn", group = G_SW, tooltip = "On: the swing candle must also mark the change of direction - up to down for a high, down to up for a low. Two candles running the same way can bracket an extreme price never actually turned at, and that is not structure. Off: any candle holding the extreme against its neighbours counts.")
bool trackRunning = input.bool(true, "Carry a raided boundary out to price", group = G_SW, tooltip = "On: once price trades beyond a boundary, that boundary follows the extreme price has actually reached, and draws dotted while it is out there. The range stays the one being traded rather than the one the last confirmed swings describe, and it settles back to solid when a new swing confirms behind it. Off: both boundaries sit only at confirmed swings, and price is free to trade outside the range.")

// == INPUTS - SHADING ========================================================

const string G_SH = "Shading"

color premCol = input.color(#E04A6D, "Premium", group = G_SH, inline = "s1")
color discCol = input.color(#3A7BD5, "Discount", group = G_SH, inline = "s1")
int   shadeT  = input.int(90, "Transparency", minval = 70, maxval = 98, group = G_SH, tooltip = "Higher is fainter. The fills are sized to stay readable over candles on a white chart - drop toward 80 for a stronger wash, lift toward 96 for a hint.")
bool  emphOn  = input.bool(false, "Lean the shading with the direction", group = G_SH, tooltip = "On: the side the range is working away from fades back, leaving the side being worked from at full strength - discount on a bullish leg, premium on a bearish one. Off: both halves carry the same weight, which is the plain premium / discount read.")
int   emphAmt = input.int(5, "Lean amount", minval = 1, maxval = 20, group = G_SH)

// == INPUTS - LINES ==========================================================

const string G_LN = "Lines"

color bndCol = input.color(color.new(#000000, 0), "Range high / low", group = G_LN)
color eqCol  = input.color(color.new(#000000, 0), "Equilibrium", group = G_LN, inline = "eq")
int   eqWid  = input.int(1, "width", minval = 1, maxval = 4, group = G_LN, inline = "eq")
int   rightPad = input.int(12, "Extend past the last bar (bars)", minval = 0, maxval = 200, group = G_LN)

// == INPUTS - LABELS =========================================================
// Side places the text; nudge moves it in whole chart bars.
//   Right  = live edge, text sitting out to the right of price - the reference look
//   Left   = the range's own start        Origin = the swing candle that set the level
//   Above  = centred over the span        Below  = centred under it
//   Off    = the level draws bare

const string G_LB = "Labels"
const string SIDE_TIP = "Right and Left place the text beside the line and level with it. Above and Below centre it over the range's span and lift or drop it clear of the line by one text height."

string sideHi = input.string("Right", "High", options = ["Right", "Left", "Origin", "Above", "Below", "Off"], group = G_LB, inline = "h", tooltip = SIDE_TIP)
int    nudgeHi = input.int(0, "nudge", minval = -200, maxval = 200, group = G_LB, inline = "h")
string sideLo = input.string("Right", "Low", options = ["Right", "Left", "Origin", "Above", "Below", "Off"], group = G_LB, inline = "l")
int    nudgeLo = input.int(0, "nudge", minval = -200, maxval = 200, group = G_LB, inline = "l")
string sideEq = input.string("Right", "Equilibrium", options = ["Right", "Left", "Origin", "Above", "Below", "Off"], group = G_LB, inline = "e")
int    nudgeEq = input.int(0, "nudge", minval = -200, maxval = 200, group = G_LB, inline = "e")
// Off by default. The colours already say which half is which, so the words only take up
// room in the one column every other name is competing for.
string sideZn = input.string("Off", "Premium / Discount", options = ["Right", "Left", "Above", "Below", "Off"], group = G_LB, inline = "z", tooltip = "The two names inside the shading. Off by default - the pink and the blue already name themselves, and the words cost space in the right-hand column. Set a side to bring them back.")
int    nudgeZn = input.int(0, "nudge", minval = -200, maxval = 200, group = G_LB, inline = "z")

// Small on purpose. The clearance from price is the LINE extension's job - it carries the
// level out past the last candles and the name rides its end. This only trims the last of
// the distance, because a name floating in space away from the line it belongs to reads as
// unattached rather than as tidy.
int    labelGap = input.int(2, "Gap from the lines (bars)", minval = 0, maxval = 100, group = G_LB, tooltip = "Extra space between the end of a right-side line and its name. Keep it small: the clearance from price comes from the line extension under Lines, and a name set too far past its own line stops reading as belonging to it.")
float  collideAtr = input.float(0.35, "Separate names closer than (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = G_LB, tooltip = "Two names landing within this much of each other are pushed apart by one text height rather than left overlapping. Measured against ATR because that is the only zoom-independent read of 'close together' available. Set to 0 to leave every name exactly on its level. Names on the SAME price are merged into one instead, and that always happens regardless of this setting.")
bool   zoneNamesOnTraded = input.bool(true, "Name premium / discount on range 1 only", group = G_LB, tooltip = "Three sets of Premium / Discount names stacked over each other read as noise. Off: every shaded range is named.")
bool   showPrice = input.bool(true, "Show the price in the label", group = G_LB)
string lblSizeIn = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = G_LB)
color  lblCol   = input.color(color.new(#000000, 0), "Label colour", group = G_LB)

// == INPUTS - READOUT ========================================================

const string G_RD = "Readout"

bool   showRead = input.bool(true, "Show the readout", group = G_RD, tooltip = "One line per range: its timeframe, which way the range is working, where price sits inside it, and how far through it price has travelled.")
string readPos  = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_RD)
string readSize = input.string("small", "Size", options = ["small", "normal", "large"], group = G_RD)

// == INPUTS - AVERAGE RANGES =================================================
// A calendar statistic, not a swing one: how much this instrument typically travels in a
// day, a week and a month, and how much of that has already been spent. It answers a
// different question from the dealing range above it - not WHERE price is, but whether
// there is room left to go there - which is why it shares the panel rather than the levels.

const string G_AV = "Average ranges (ADR / AWR / AMR)"

bool showAvg  = input.bool(true, "Show average ranges", group = G_AV, tooltip = "Adds ADR / AWR / AMR to the readout: the average of the last N completed daily, weekly and monthly ranges, how much of each the current period has already used, and how long it has left to run.")
int  adrLen   = input.int(5, "ADR length", minval = 1, maxval = 60, group = G_AV, tooltip = "Number of completed daily ranges averaged. Five is one trading week.")
int  awrLen   = input.int(4, "AWR length", minval = 1, maxval = 52, group = G_AV)
int  amrLen   = input.int(3, "AMR length", minval = 1, maxval = 24, group = G_AV)
bool showTimers = input.bool(true, "Show the close countdown", group = G_AV)

// == TYPES ===================================================================

//@type Every drawing one range owns, held together so they are erased together. Names are
//      not among them: they are settled across all three ranges at once and so are owned
//      by the name store rather than by any single range.
type DrDraw
    box   premBox = na
    box   discBox = na
    line  hiLine  = na
    line  loLine  = na
    line  eqLine  = na

//@type One range reduced to its two prices, its two origin times and its direction.
//      A boundary is provisional while price has carried it past the swing that set it,
//      which is why the origin of a LINE and the start of the RANGE are held apart: the
//      line begins at the candle currently holding its price, the range began when its
//      two swings first both existed, and a raid moves the first without moving the second.
type DrState
    float hiPrice  = na
    int   hiTime   = 0
    float loPrice  = na
    int   loTime   = 0
    int   swHiTime = 0
    int   swLoTime = 0
    int   dir      = 0
    bool  valid    = false
    bool  hiProv   = false
    bool  loProv   = false

// == HELPERS =================================================================

//@function Maps the timeframe choice to its Pine period string
//@param pick (simple string) One of the six range timeframes
//@returns (simple string) Period string for request.security
f_tfCode(simple string pick) => switch pick
    "1H"      => "60"
    "4H"      => "240"
    "12H"     => "720"
    "Daily"   => "D"
    "Weekly"  => "W"
    =>           "M"

//@function Short tag used in every label and readout row
//@param pick (string) One of the six range timeframes
//@returns (string) Tag text
f_tfTag(string pick) => switch pick
    "Daily"   => "1D"
    "Weekly"  => "1W"
    "Monthly" => "1M"
    =>           pick

//@function Resolves a size input string to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal", "large"
//@returns (string) Matching size.* constant
f_size(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    "large"  => size.large
    =>          size.small

//@function Resolves the readout position input to a table position constant
//@param posName (string) Chosen corner
//@returns (string) Matching position.* constant
f_tblPos(string posName) => switch posName
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

//@function Callout style for a label side. A left-pointing callout centres its body
//          vertically on the anchor and extends it right; a right-pointing one extends
//          it left. A downward callout carries its body above the anchor, an upward one
//          below. Text naming a price level is never style_none, which would float it
//          off its own line.
//@param side (string) "Right" | "Left" | "Origin" | "Above" | "Below"
//@returns (string) Matching label.style_* constant
f_lblStyle(string side) => switch side
    "Left"   => label.style_label_right
    "Origin" => label.style_label_right
    "Above"  => label.style_label_down
    "Below"  => label.style_label_up
    =>          label.style_label_left

//@function Resolves one level's label side, letting a range's own placement override the
//          per-level sides set globally.
//
//          Centred moves the two EDGES only - the high centred above its line, the low
//          centred below its own. Everything inside the range stays where it was, because
//          a range's edges have empty chart above and below them to be named into and its
//          middle does not: a centred equilibrium on a range spanning the screen lands its
//          text in the middle of the candles it is meant to be read against.
//@param mode       (string) The range's placement: Global, Centred, Right, Left or Off
//@param globalSide (string) The side this level would take under Global
//@param isEdge     (bool)   True for the two boundaries, false for anything inside them
//@param isLow      (bool)   True for the level that sits at the bottom of the range
//@returns (string) Side to place this label on
f_side(string mode, string globalSide, bool isEdge, bool isLow) =>
    string outSide = switch mode
        "Global"  => globalSide
        "Centred" => isEdge ? (isLow ? "Below" : "Above") : globalSide
        =>           mode
    outSide

//@function Anchor time for a label, from its side choice plus a nudge in chart bars
//@param side    (string) Side choice
//@param nudge   (int)    Horizontal nudge, positive moves right
//@param originT (int)    Time of the swing candle that set this level
//@param leftT   (int)    Time the range starts
//@param rightT  (int)    Time of the live edge
//@returns (int) Anchor time in milliseconds
f_lblTime(string side, int nudge, int originT, int leftT, int rightT) =>
    int step = timeframe.in_seconds() * 1000
    switch side
        "Left"   => leftT + nudge * step
        "Origin" => originT + nudge * step
        "Above"  => int(math.avg(leftT, rightT)) + nudge * step
        "Below"  => int(math.avg(leftT, rightT)) + nudge * step
        // The right-side gap is added here rather than to the line's own end, so the names
        // stand clear of price without dragging the levels further across the chart with them.
        =>          rightT + (nudge + labelGap) * step

// == NAME QUEUE ==============================================================
// Every name is queued here before any of it is drawn. Three ranges can put eleven names
// on one right edge, and two of them being the SAME level - or merely close enough to sit
// on top of each other - is a fact about the whole set, not about either name on its own.
// Drawing as we go would settle each one before the set was known.

var array<float>  qPrice  = array.new<float>(0)
var array<string> qName   = array.new<string>(0)
var array<string> qSide   = array.new<string>(0)
var array<int>    qAnchor = array.new<int>(0)
var array<bool>   qPriced = array.new<bool>(0)
var array<label>  nameStore = array.new<label>(0)

//@function Queues one name to be settled and drawn later
//@param anchorT (int)    Anchor time
//@param price   (float)  Exact price the text names
//@param name    (string) Level name, without its price
//@param side    (string) Side choice, driving the callout style
//@param priced  (bool)   Whether this name carries a price at all - a zone caption does not
//@returns (bool) Always true
f_queue(int anchorT, float price, string name, string side, bool priced) =>
    qPrice.push(price)
    qName.push(name)
    qSide.push(side)
    qAnchor.push(anchorT)
    qPriced.push(priced)
    true

//@function Settles the queued names and draws them.
//
//          Two passes. First, names sitting on the SAME price at the same anchor are one
//          level wearing two hats - a 4H swing high that is also the daily swing high - so
//          they combine into a single name and the price is stated once. Second, names that
//          survive but still land close enough to collide are separated by a blank line in
//          their own TEXT: one text height of clearance at every zoom, where a price offset
//          would overshoot when zoomed in and vanish when zoomed out.
//@param sz   (string) Resolved size.* constant
//@param band (float)  Price distance under which two names are treated as colliding.
//                     Passed in rather than measured here: it is built from ta.atr, which
//                     carries bar-to-bar state, and this function only runs on the last bar.
//@returns (bool) Always true
f_flushNames(string sz, float band) =>
    while nameStore.size() > 0
        label.delete(nameStore.shift())

    int total = qName.size()
    if total > 0
        // A tick of tolerance, not zero: two swings on the same level can differ by the
        // float noise of a midpoint without being two different prices.
        float sameTol = syminfo.mintick * 0.5

        array<bool>   live  = array.new<bool>(total, true)
        array<string> shown = array.new<string>(total, "")

        for i = 0 to total - 1
            if live.get(i)
                string joined = qName.get(i)
                bool   priced = qPriced.get(i)
                // Guarded, not merely bounded. A Pine for loop whose start exceeds its end
                // counts DOWNWARD rather than skipping, so on the last name this inner scan
                // would run backwards from one past the end of the array.
                if i < total - 1
                    for j = i + 1 to total - 1
                        if live.get(j) and qSide.get(j) == qSide.get(i) and qAnchor.get(j) == qAnchor.get(i) and math.abs(qPrice.get(j) - qPrice.get(i)) <= sameTol
                            joined := joined + " + " + qName.get(j)
                            priced := priced or qPriced.get(j)
                            live.set(j, false)
                shown.set(i, priced and showPrice ? joined + "  " + str.tostring(qPrice.get(i), format.mintick) : joined)

        // Separation is measured against the surviving names only. Testing against a name
        // that has already been folded into another would push a label clear of something
        // no longer on the chart.
        for i = 0 to total - 1
            if live.get(i) and band > 0
                float nearest = na
                int   nearIdx = -1
                for j = 0 to total - 1
                    if j != i and live.get(j) and qSide.get(j) == qSide.get(i) and qAnchor.get(j) == qAnchor.get(i)
                        float gap = math.abs(qPrice.get(j) - qPrice.get(i))
                        if gap <= band and (na(nearest) or gap < nearest)
                            nearest := gap
                            nearIdx := j
                if nearIdx >= 0
                    // The lower of the pair drops, the higher lifts. The trailing spacer
                    // carries a space: a wholly empty last line is trimmed off by the
                    // renderer and the clearance silently disappears.
                    shown.set(i, qPrice.get(i) < qPrice.get(nearIdx) ? "\n" + shown.get(i) : shown.get(i) + "\n ")

        for i = 0 to total - 1
            if live.get(i)
                label made = label.new(qAnchor.get(i), qPrice.get(i), shown.get(i), xloc = xloc.bar_time, style = f_lblStyle(qSide.get(i)), color = color.new(color.white, 100), textcolor = lblCol, size = sz, textalign = text.align_left)
                label.set_text_font_family(made, font.family_monospace)
                nameStore.push(made)

    qPrice.clear()
    qName.clear()
    qSide.clear()
    qAnchor.clear()
    qPriced.clear()
    true

//@function Newest confirmed swing high and swing low, evaluated inside the requested
//          timeframe's own context. The candidate sits len + 1 bars back, so every
//          candle the test reads has already closed and a forming higher-timeframe
//          candle can neither confirm nor unconfirm a swing.
//@param len      (simple int)  Candles either side that must fail to exceed the swing
//@param needTurn (simple bool) Also require the change of direction
//@returns (tuple) Swing high, its time, swing low, its time, and which formed last
f_swings(simple int len, simple bool needTurn) =>
    var float sHi  = na
    var int   sHiT = 0
    var float sLo  = na
    var int   sLoT = 0
    var int   last = 0

    int p = len + 1

    // The neighbours are read as running extremes rather than walked one at a time, so
    // every history offset stays a fixed number and the series needs no extra buffer.
    float olderHi = ta.highest(high, len)[p + 1]
    float newerHi = ta.highest(high, len)[1]
    float olderLo = ta.lowest(low, len)[p + 1]
    float newerLo = ta.lowest(low, len)[1]

    bool geoHi = high[p] > olderHi and high[p] > newerHi
    bool geoLo = low[p] < olderLo and low[p] < newerLo

    bool up    = close[p] > open[p]
    bool dn    = close[p] < open[p]
    bool upOld = close[p + 1] > open[p + 1]
    bool dnOld = close[p + 1] < open[p + 1]
    bool upNew = close[p - 1] > open[p - 1]
    bool dnNew = close[p - 1] < open[p - 1]

    // The turn may straddle the swing either way round: the swing candle is whichever of
    // the pair holds the extreme, so a high qualifies as the down candle following an up
    // one, or as the up candle preceding a down one.
    bool okHi = geoHi and (not needTurn or ((dn and upOld) or (up and dnNew)))
    bool okLo = geoLo and (not needTurn or ((up and dnOld) or (dn and upNew)))

    if okHi
        sHi  := high[p]
        sHiT := time[p]
    if okLo
        sLo  := low[p]
        sLoT := time[p]

    // An outside candle holds both extremes at once. The end it closed toward is the end
    // it reached last, so its own close decides which side of the range is the newer one.
    if okHi and okLo
        last := close[p] > open[p] ? -1 : 1
    else if okHi
        last := -1
    else if okLo
        last := 1

    [sHi, sHiT, sLo, sLoT, last]

//@function Follows one boundary out to the extreme price has reached since its swing
//          confirmed. Called once per boundary at script scope and never inside a
//          condition - it carries state between bars, and a skipped bar is a missed
//          extreme. Each call site keeps its own state.
//@param swingPrice (float) The confirmed swing price
//@param swingTime  (int)   Time of the swing candle
//@param isHigh     (bool)  True for the upper boundary
//@param enabled    (bool)  False pins the boundary to its swing
//@returns (tuple) Boundary price, the time of the candle holding it, and whether it has
//         been carried past its swing
f_running(float swingPrice, int swingTime, bool isHigh, bool enabled) =>
    var float lvl   = na
    var int   lvlT  = 0
    var int   seenT = 0

    // A new swing resets the boundary onto it. The reset is keyed to the swing's TIME,
    // not its price: two swings at the same price are still two different swings, and a
    // boundary left carried out from the older one would be a level nothing set.
    if swingTime != seenT
        seenT := swingTime
        lvl   := swingPrice
        lvlT  := swingTime

    if enabled and not na(lvl)
        if isHigh and high > lvl
            lvl  := high
            lvlT := time
        if not isHigh and low < lvl
            lvl  := low
            lvlT := time

    [lvl, lvlT, not na(lvl) and not na(swingPrice) and lvl != swingPrice]

//@function Deletes every drawing a range owns
//@param d (DrDraw) Drawing set to erase
//@returns (bool) Always true
f_erase(DrDraw d) =>
    box.delete(d.premBox)
    box.delete(d.discBox)
    line.delete(d.hiLine)
    line.delete(d.loLine)
    line.delete(d.eqLine)
    true

//@function Draws one dealing range - its shading first so the levels sit over it, then
//          the two boundaries, the equilibrium and their names.
//@param d          (DrDraw)  Drawing set to fill
//@param s          (DrState) The range's prices, origins and direction
//@param tag        (string)  Timeframe tag for the label text
//@param wantShade  (bool)    Fill premium and discount
//@param wantNames  (bool)    Name the premium and discount halves
//@param lnWidth    (int)     Boundary line width
//@param rightT     (int)     Time of the live edge
//@param sz         (string)  Resolved size.* constant
//@param mode       (string)  This range's label placement override
//@returns (bool) Always true
f_draw(DrDraw d, DrState s, string tag, bool wantShade, bool wantNames, int lnWidth, int rightT, string sz, string mode) =>
    f_erase(d)
    if s.valid
        float eqPrice = math.avg(s.hiPrice, s.loPrice)
        // The range has no midpoint until both of its ends exist, so the equilibrium and
        // the shading begin at the later of the two SWINGS - the moment the range came
        // into being. A boundary carried out by a raid widens the range without restarting
        // it, so it must not drag that start date forward with it.
        int   bothT = s.swHiTime > s.swLoTime ? s.swHiTime : s.swLoTime
        int   leftT = s.swHiTime > s.swLoTime ? s.swLoTime : s.swHiTime

        if wantShade
            // The side the range is working away from can be faded back, leaving the side
            // being worked from at full strength.
            int premFade = emphOn and s.dir > 0 ? emphAmt : 0
            int discFade = emphOn and s.dir < 0 ? emphAmt : 0
            color premFill = color.new(premCol, math.min(99, shadeT + premFade))
            color discFill = color.new(discCol, math.min(99, shadeT + discFade))
            d.premBox := box.new(bothT, s.hiPrice, rightT, eqPrice, xloc = xloc.bar_time, border_color = premFill, border_width = 1, border_style = line.style_solid, bgcolor = premFill)
            d.discBox := box.new(bothT, eqPrice, rightT, s.loPrice, xloc = xloc.bar_time, border_color = discFill, border_width = 1, border_style = line.style_solid, bgcolor = discFill)

        // Each boundary starts at the candle that set it. The two are the range's buyside
        // and sellside liquidity, so they draw solid at the liquidity weight - but dotted
        // while price has carried one past its swing, because a level price has not turned
        // at yet is a raid in progress, not a confirmed edge.
        d.hiLine := line.new(s.hiTime, s.hiPrice, rightT, s.hiPrice, xloc = xloc.bar_time, color = bndCol, width = lnWidth, style = s.hiProv ? line.style_dotted : line.style_solid)
        d.loLine := line.new(s.loTime, s.loPrice, rightT, s.loPrice, xloc = xloc.bar_time, color = bndCol, width = lnWidth, style = s.loProv ? line.style_dotted : line.style_solid)
        d.eqLine := line.new(bothT, eqPrice, rightT, eqPrice, xloc = xloc.bar_time, color = eqCol, width = eqWid, style = line.style_solid)

        // Names are queued rather than drawn. Three ranges put up to eleven of them on one
        // right edge, and whether two of those are the same level - or merely close enough
        // to collide - cannot be known until every range has had its say. f_flushNames
        // settles that once, for all of them together.
        string useHi = f_side(mode, sideHi, true, false)
        string useLo = f_side(mode, sideLo, true, true)
        string useEq = f_side(mode, sideEq, false, false)
        string useZn = f_side(mode, sideZn, false, false)

        if useHi != "Off"
            f_queue(f_lblTime(useHi, nudgeHi, s.hiTime, leftT, rightT), s.hiPrice, tag + " High", useHi, true)
        if useLo != "Off"
            f_queue(f_lblTime(useLo, nudgeLo, s.loTime, leftT, rightT), s.loPrice, tag + " Low", useLo, true)
        if useEq != "Off"
            f_queue(f_lblTime(useEq, nudgeEq, bothT, leftT, rightT), eqPrice, tag + " EQ", useEq, true)

        if wantShade and wantNames and useZn != "Off"
            // Each name sits at the middle of its own half, which keeps it clear of the
            // boundary and equilibrium names above and below it.
            float premMid = math.avg(s.hiPrice, eqPrice)
            float discMid = math.avg(eqPrice, s.loPrice)
            f_queue(f_lblTime(useZn, nudgeZn, bothT, bothT, rightT), premMid, "Premium", useZn, false)
            f_queue(f_lblTime(useZn, nudgeZn, bothT, bothT, rightT), discMid, "Discount", useZn, false)
    true

//@function Where price sits relative to a range, as a percentage of the range travelled
//@param s (DrState) The range
//@returns (float) 0 at the low, 100 at the high, outside that when price has left the range
f_position(DrState s) =>
    float span = s.valid ? s.hiPrice - s.loPrice : na
    span > 0 ? (close - s.loPrice) / span * 100.0 : na

//@function Names the half of the range price is trading in
//@param pct (float) Position from f_position
//@returns (string) Zone name
f_zone(float pct) =>
    string zoneName = switch
        na(pct)    => "-"
        pct > 100  => "Above range"
        pct < 0    => "Below range"
        pct > 50   => "Premium"
        pct < 50   => "Discount"
        =>            "At EQ"
    zoneName

//@function Names the direction a range is working, from the swing that formed last
//@param dirValue (int) 1 when the low is newer, -1 when the high is
//@returns (string) Direction name
f_dirName(int dirValue) =>
    string dirText = switch
        dirValue > 0 => "Bullish"
        dirValue < 0 => "Bearish"
        =>              "-"
    dirText

//@function Zero-pads a clock component to two digits
//@param value (int) Hours, minutes or seconds
//@returns (string) Two-character string
f_pad2(int value) => (value < 10 ? "0" : "") + str.tostring(value)

//@function Time left until a period closes, as a clock
//@param closeMs (int) Timestamp the period closes at
//@returns (string) Countdown, or a dash when the close is unknown or already past
f_countdown(int closeMs) =>
    string out = "-"
    if not na(closeMs)
        int rem = closeMs - timenow
        if rem > 0
            int totSec = int(rem / 1000)
            int days   = int(totSec / 86400)
            int hrs    = int((totSec % 86400) / 3600)
            int mins   = int((totSec % 3600) / 60)
            int secs   = totSec % 60
            out := days > 0 ? str.tostring(days) + "d " + f_pad2(hrs) + "h" : f_pad2(hrs) + ":" + f_pad2(mins) + ":" + f_pad2(secs)
    out

// == RESOLVED SETTINGS =======================================================

simple string tfCode1 = f_tfCode(tfPick1)
simple string tfCode2 = f_tfCode(tfPick2)
simple string tfCode3 = f_tfCode(tfPick3)

string tag1 = f_tfTag(tfPick1)
string tag2 = f_tfTag(tfPick2)
string tag3 = f_tfTag(tfPick3)

// "1M High" is this month's high; "1M Swing High" is the monthly swing high. Two different
// levels that would otherwise wear the same name on the same chart.
string lblTag1 = tag1 + (srcPick1 == "Swing" ? " Swing" : "")
string lblTag2 = tag2 + (srcPick2 == "Swing" ? " Swing" : "")
string lblTag3 = tag3 + (srcPick3 == "Swing" ? " Swing" : "")

string lblSize  = f_size(lblSizeIn)
string readCell = f_size(readSize)

// Measured here, unconditionally, and handed to the name pass. ta.atr carries bar-to-bar
// state, and the name pass only runs on the last bar - calling it from in there would ask
// for an average built from a history that was never accumulated.
float nameBand = nz(ta.atr(14)) * collideAtr

// A range measured on a timeframe at or below the chart's own is the chart redrawn, so
// it is withheld and said so rather than drawn as something it is not.
bool fits1 = timeframe.in_seconds(tfCode1) > timeframe.in_seconds()
bool fits2 = timeframe.in_seconds(tfCode2) > timeframe.in_seconds()
bool fits3 = timeframe.in_seconds(tfCode3) > timeframe.in_seconds()

// == HIGHER TIMEFRAME SWINGS =================================================
// One call per range, always evaluated. A request is never reduced by a toggle, so
// gating these would cost nothing and only make the load harder to read.
//
// Lookahead is ON, and it reveals nothing. The swing test reads no candle newer than
// one bar back, so every value it returns for a higher-timeframe bar was already
// settled before that bar opened. Lookahead therefore only stops the result being held
// back until the bar it was known in has closed - it hands over a fact on the bar it
// became a fact, rather than a bar late. Off would cost a full higher-timeframe candle
// of delay and buy nothing.

[hi1, hiT1, lo1, loT1, dir1] = request.security(syminfo.tickerid, tfCode1, f_swings(len1, requireTurn), lookahead = barmerge.lookahead_on)
[hi2, hiT2, lo2, loT2, dir2] = request.security(syminfo.tickerid, tfCode2, f_swings(len2, requireTurn), lookahead = barmerge.lookahead_on)
[hi3, hiT3, lo3, loT3, dir3] = request.security(syminfo.tickerid, tfCode3, f_swings(len3, requireTurn), lookahead = barmerge.lookahead_on)

// == PERIOD EXTREMES =========================================================
// Deliberately a SEPARATE request with lookahead OFF, and it cannot ride along on the
// swing call above. The swing call reads no candle newer than one bar back, which is what
// makes lookahead harmless there. These read the FORMING candle at offset zero, where
// lookahead is the whole problem: it would hand back the period's finished high on the
// first bar of that period, so every historical month would open already knowing where it
// was going to top out - and the running-extreme pass, finding nothing left to exceed,
// would anchor the level to the period's open instead of the candle that made it.
// Off returns the period's high SO FAR, which is what a forming range actually is.

[pHi1, pLo1, pT1] = request.security(syminfo.tickerid, tfCode1, [high, low, time], lookahead = barmerge.lookahead_off)
[pHi2, pLo2, pT2] = request.security(syminfo.tickerid, tfCode2, [high, low, time], lookahead = barmerge.lookahead_off)
[pHi3, pLo3, pT3] = request.security(syminfo.tickerid, tfCode3, [high, low, time], lookahead = barmerge.lookahead_off)

// == RANGE SOURCE ============================================================
// Period or Swing, per range. Under Period both ends seed from the period's own start, so
// the range begins at the open, is bounded by nothing but this period's own trade, and is
// gone at the rollover - one month is one range. Under Swing they seed from their two
// confirmed swings, which owe nothing to the calendar.

bool per1 = srcPick1 == "Period"
bool per2 = srcPick2 == "Period"
bool per3 = srcPick3 == "Period"

float rawHi1 = per1 ? pHi1 : hi1
float rawLo1 = per1 ? pLo1 : lo1
int   rawHiT1 = per1 ? pT1 : hiT1
int   rawLoT1 = per1 ? pT1 : loT1

float rawHi2 = per2 ? pHi2 : hi2
float rawLo2 = per2 ? pLo2 : lo2
int   rawHiT2 = per2 ? pT2 : hiT2
int   rawLoT2 = per2 ? pT2 : loT2

float rawHi3 = per3 ? pHi3 : hi3
float rawLo3 = per3 ? pLo3 : lo3
int   rawHiT3 = per3 ? pT3 : hiT3
int   rawLoT3 = per3 ? pT3 : loT3

// == RUNNING BOUNDARIES ======================================================
// A confirmed swing is the last level price TURNED at, which is not always the edge of
// the range price is in right now - the moment a boundary is raided, the range being
// traded is already wider than the one the swings describe. Each boundary is therefore
// carried out to the extreme price has actually reached since its swing confirmed, and
// draws dotted while it is out there, because a level price has not yet turned at is a
// raid in progress and not structure. It settles back to solid the moment a new swing
// confirms behind it.
//
// These run on every bar, never inside a condition: they carry state between bars, and
// a skipped bar is an extreme that is silently missed.

// Period ranges always track, whatever the toggle says. There the tracking is not carrying
// a boundary past a swing - the period's high IS its running high - it is only there to
// find the exact candle that set it, so the level starts where the price began.

[liveHi1, liveHiT1, provHi1] = f_running(rawHi1, rawHiT1, true, per1 or trackRunning)
[liveLo1, liveLoT1, provLo1] = f_running(rawLo1, rawLoT1, false, per1 or trackRunning)
[liveHi2, liveHiT2, provHi2] = f_running(rawHi2, rawHiT2, true, per2 or trackRunning)
[liveLo2, liveLoT2, provLo2] = f_running(rawLo2, rawLoT2, false, per2 or trackRunning)
[liveHi3, liveHiT3, provHi3] = f_running(rawHi3, rawHiT3, true, per3 or trackRunning)
[liveLo3, liveLoT3, provLo3] = f_running(rawLo3, rawLoT3, false, per3 or trackRunning)

//@function Which end of a period range formed most recently, read from the two origin
//          candles. A period has no confirmed swings to order, but it still has a shape:
//          the end price reached last is the one it is working away from.
//@param hiWhen (int) Time of the candle holding the high
//@param loWhen (int) Time of the candle holding the low
//@returns (int) 1 when the low came last, -1 when the high did, 0 when neither has
f_periodDir(int hiWhen, int loWhen) =>
    int outDir = hiWhen > loWhen ? -1 : hiWhen < loWhen ? 1 : 0
    outDir

int dirUse1 = per1 ? f_periodDir(liveHiT1, liveLoT1) : dir1
int dirUse2 = per2 ? f_periodDir(liveHiT2, liveLoT2) : dir2
int dirUse3 = per3 ? f_periodDir(liveHiT3, liveLoT3) : dir3

// Under Period the range began at the period's open, so both "swing" times are that open.
DrState state1 = DrState.new(liveHi1, liveHiT1, liveLo1, liveLoT1, rawHiT1, rawLoT1, dirUse1, on1 and fits1 and not na(liveHi1) and not na(liveLo1) and liveHi1 > liveLo1, provHi1, provLo1)
DrState state2 = DrState.new(liveHi2, liveHiT2, liveLo2, liveLoT2, rawHiT2, rawLoT2, dirUse2, on2 and fits2 and not na(liveHi2) and not na(liveLo2) and liveHi2 > liveLo2, provHi2, provLo2)
DrState state3 = DrState.new(liveHi3, liveHiT3, liveLo3, liveLoT3, rawHiT3, rawLoT3, dirUse3, on3 and fits3 and not na(liveHi3) and not na(liveLo3) and liveHi3 > liveLo3, provHi3, provLo3)

// == DRAWING =================================================================
// Only the range price is in right now carries meaning, so one set of drawings is
// kept and rebuilt on the live edge rather than a trail of retired ranges.

var DrDraw draw1 = DrDraw.new()
var DrDraw draw2 = DrDraw.new()
var DrDraw draw3 = DrDraw.new()

if barstate.islast
    int rightT = time + rightPad * timeframe.in_seconds() * 1000
    f_draw(draw1, state1, lblTag1, shade1, true, wid1, rightT, lblSize, lblMode1)
    f_draw(draw2, state2, lblTag2, shade2, not zoneNamesOnTraded, wid2, rightT, lblSize, lblMode2)
    f_draw(draw3, state3, lblTag3, shade3, not zoneNamesOnTraded, wid3, rightT, lblSize, lblMode3)
    // Every range has now had its say, so the names can be settled against each other.
    f_flushNames(lblSize, nameBand)

// == AVERAGE RANGES ==========================================================
// The average is taken from COMPLETED periods only ([1]), so today's half-finished range
// is never averaged into the yardstick it is about to be measured against. The current
// period's own high and low are pulled separately and without lookahead, because there
// the developing value IS the answer - how far price has travelled so far.

[adrVal, dayHi, dayLo, dayCloseMs] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, adrLen)[1], high, low, time_close], lookahead = barmerge.lookahead_off)
[awrVal, wkHi, wkLo, wkCloseMs]    = request.security(syminfo.tickerid, "W", [ta.sma(high - low, awrLen)[1], high, low, time_close], lookahead = barmerge.lookahead_off)
[amrVal, moHi, moLo, moCloseMs]    = request.security(syminfo.tickerid, "M", [ta.sma(high - low, amrLen)[1], high, low, time_close], lookahead = barmerge.lookahead_off)

// == READOUT =================================================================
// One panel, two questions. The upper block answers WHERE price is - which dealing range,
// which half of it. The lower block answers whether there is room left to get anywhere -
// how much of a normal day, week or month has already been spent. They are read together
// before a session and belong in the same place.

var table readTbl = table.new(f_tblPos(readPos), 4, 9, border_width = 0)

//@function Writes one range's line into the readout
//@param rowIdx  (int)     Table row
//@param enabled (bool)    Whether the range is switched on
//@param fits    (bool)    Whether its timeframe is above the chart's
//@param s       (DrState) The range
//@param tag     (string)  Timeframe tag
//@returns (bool) Always true
f_readRow(int rowIdx, bool enabled, bool fits, DrState s, string tag) =>
    if enabled
        float pct = f_position(s)
        // A range with a boundary still running is a range that has not settled, and the
        // equilibrium under it is moving with it. Saying so is the difference between
        // reading a level and reading a level that is about to be somewhere else.
        string dirTxt = f_dirName(s.dir) + (s.hiProv or s.loProv ? " - extending" : "")
        string note = not fits ? "below chart TF" : s.valid ? dirTxt : "no range yet"
        table.cell(readTbl, 0, rowIdx, tag, text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 1, rowIdx, note, text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 2, rowIdx, f_zone(pct), text_color = na(pct) ? lblCol : pct > 50 ? premCol : discCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 3, rowIdx, na(pct) ? "" : str.tostring(math.round(pct)) + "%", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_right)
    true

//@function Writes one average-range line into the readout
//@param rowIdx  (int)    Table row
//@param tag     (string) Period tag
//@param avgName (string) Average's name - ADR, AWR or AMR
//@param avgVal  (float)  Average range of the last N completed periods
//@param prdHi   (float)  Current period's high so far
//@param prdLo   (float)  Current period's low so far
//@param closeMs (int)    Timestamp the period closes at
//@returns (bool) Always true
f_avgRow(int rowIdx, string tag, string avgName, float avgVal, float prdHi, float prdLo, int closeMs) =>
    float used = not na(prdHi) and not na(avgVal) and avgVal > 0 ? (prdHi - prdLo) / avgVal * 100.0 : na
    // A period past its own average has nothing left to give in that direction on a normal
    // day, which is worth reading at a glance rather than off the number.
    color usedCol = not na(used) and used >= 100 ? premCol : lblCol
    table.cell(readTbl, 0, rowIdx, tag, text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(readTbl, 1, rowIdx, na(used) ? "-" : str.tostring(math.round(used)) + "%", text_color = usedCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(readTbl, 2, rowIdx, na(avgVal) ? avgName + " -" : avgName + " " + str.tostring(avgVal, format.mintick), text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(readTbl, 3, rowIdx, showTimers ? f_countdown(closeMs) : "", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_right)
    true

if barstate.islast
    table.clear(readTbl, 0, 0, 3, 8)
    if showRead
        table.cell(readTbl, 0, 0, "Range", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 1, 0, "Working", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 2, 0, "Price in", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 3, 0, "Through", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_right)
        f_readRow(1, on1, fits1, state1, lblTag1)
        f_readRow(2, on2, fits2, state2, lblTag2)
        f_readRow(3, on3, fits3, state3, lblTag3)

    if showAvg
        // Row 4 is left empty on purpose. The two blocks answer different questions under
        // headers that read alike, and a blank line is what stops them being read as one.
        table.cell(readTbl, 0, 5, "Period", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 1, 5, "Used", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 2, 5, "Avg range", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_left)
        table.cell(readTbl, 3, 5, showTimers ? "Closes" : "", text_color = lblCol, text_size = readCell, text_font_family = font.family_monospace, text_halign = text.align_right)
        f_avgRow(6, "1D", "ADR", adrVal, dayHi, dayLo, dayCloseMs)
        f_avgRow(7, "1W", "AWR", awrVal, wkHi, wkLo, wkCloseMs)
        f_avgRow(8, "1M", "AMR", amrVal, moHi, moLo, moCloseMs)

// == ALERTS (script scope) ===================================================
// Every alert reads the traded range. Crosses are evaluated unconditionally: ta.*
// functions carry bar-to-bar state and v6 short-circuits 'and', so guarding the call
// itself would skip it on the bars where no range exists and corrupt its own history.

// The equilibrium alert reads the equilibrium actually drawn, so it fires on the line on
// the chart rather than on a shadow of it. The two raid alerts read the confirmed SWINGS
// instead: a boundary carried out to price can never be crossed by price, so an alert
// hung on one would be an alert that can never fire.
float eq1 = state1.valid ? math.avg(state1.hiPrice, state1.loPrice) : na

bool eqCrossRaw = ta.cross(close, eq1)
bool eqUpRaw    = ta.crossover(close, eq1)
bool eqDownRaw  = ta.crossunder(close, eq1)
bool hiTakeRaw  = ta.crossover(high, hi1)
bool loTakeRaw  = ta.crossunder(low, lo1)

bool live1         = state1.valid and not na(eq1)
bool intoPremium   = live1 and eqUpRaw
bool intoDiscount  = live1 and eqDownRaw
bool eqTraded      = live1 and eqCrossRaw
bool buysideTaken  = live1 and hiTakeRaw
bool sellsideTaken = live1 and loTakeRaw
bool rangeChanged  = live1 and (hiT1 != hiT1[1] or loT1 != loT1[1])

alertcondition(intoPremium,   "Price into premium",   "M1D: price crossed above the dealing range equilibrium into premium on {{ticker}} @ {{close}}")
alertcondition(intoDiscount,  "Price into discount",  "M1D: price crossed below the dealing range equilibrium into discount on {{ticker}} @ {{close}}")
alertcondition(eqTraded,      "Equilibrium traded",   "M1D: price traded the dealing range equilibrium on {{ticker}} @ {{close}}")
alertcondition(buysideTaken,  "Range high taken",     "M1D: the dealing range high was taken on {{ticker}} @ {{close}}")
alertcondition(sellsideTaken, "Range low taken",      "M1D: the dealing range low was taken on {{ticker}} @ {{close}}")
alertcondition(rangeChanged,  "New dealing range",    "M1D: a new swing has redrawn the dealing range on {{ticker}}")
````
