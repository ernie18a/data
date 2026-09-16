<!-- tradingview-pine-id: PUB;338c79c6b3424c8291a4e6b8e221d8fe -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CISD Order Block+ (M1D)

Source: https://www.tradingview.com/script/fKX9evIH-CISD-Order-Block-M1D/

## Description

CISD Order Block+ finds the candle that changed the state of delivery and turns it into the order block you deal from. A run of down candles delivers lower; price then closes back above the highest body edge of that run. That reclaim is the change in the state of delivery, and the candle it reclaimed is a bullish order block — its body is the array, its midpoint is the entry, and the range it delivered through projects the targets. Bearish mirrors it exactly. Nothing engages until liquidity has been swept, and one raid produces one setup. It maps structure. It does not fire trades.

The sequence it looks for

Bullish below; bearish mirrors.

Liquidity is taken. Price wicks through a swing low and closes back above it — sellside raided and rejected. With no sweep there is no setup, and the swing that was taken is consumed, so the same low cannot be raided twice.

Delivery runs down. Two or more consecutive down candles print. This is the leg that did the raiding.

The run is reclaimed. Within a set window of bars, a candle CLOSES back above the run's highest body edge. That close is the change in the state of delivery.

The origin candle becomes the order block. The highest-bodied candle of the run, the one price just closed back over, which is usually but not always the run's first candle. Its body high is the level, its body midpoint is the entry, and its own body low is the distal edge.

The targets project. The run's body-to-body range, cast forward past the level in standard deviations.

The anchor is the point of the whole thing. Most implementations mark the last down candle before the up move, or measure the midpoint across the entire displacement leg. This one anchors on the run's extreme body — the level whose reclaim actually reverses the delivery — and takes its 0.5 from that single candle's own body, not from the leg. Those produce different prices, and the difference is where you get filled.

These are established Inner Circle Trader concepts — the change in the state of delivery, the order block, the liquidity raid, consequent encroachment and standard deviation projections. This script is an original implementation of them.

One raid, one setup

A down leg is rarely a single run. It is more often three down, a pause, two down, a pause, two more — each with its own body high sitting at a different price. A rally back through that leg closes above each of those levels in turn, on different bars, which is how a CISD tool ends up printing four or five setups off one raid.

This script treats that as one event. When a setup confirms, every other pending run in that leg is discarded and the sweep that produced it is marked as used; the next setup on that side requires a new sweep. The one that survives is the FIRST close that reverses the delivery, not the highest level, because the run nearest the low is the one that actually delivered into the raid. The higher runs further back up the leg are old delivery, and a close through those comes after the move has already gone.

What it draws

The CISD level. A solid line at the origin candle's body high, anchored at the candle that formed it and tagged CISD at its right end. This is the trigger — the price whose reclaim made the setup, and the price whose loss ends it.

The 0.5. A dotted line at the consequent encroachment of that candle's body, tagged 0.5. The entry level: the discount half of the block on a bullish setup, the premium half on a bearish one. Both the line and its tag can be turned off independently.

The swept level. A dotted line at the raided level, running from the swing that formed it to the candle that took it, with a small x centred on the line. It shows the liquidity the whole setup was built on, and it belongs to the setup — when the block fails, the mark goes with it.

The distal edge. The far side of the origin candle's body, dotted, off by default. Turn it on for the full three-level block.

Standard deviations. The unit is the run's body-to-body range — the highest body edge to the lowest body edge across every candle in the run, so a three-candle run measures all three — projected past the CISD level at 1, 2, 2.5 and 4 by default, the multiples editable as a list. They draw as short stubs numbered on their left rather than as extended levels, and they are carried by the latest setup only: four multiples on four live setups is thirty-two objects and reads as a grid, and targets only matter for the setup you are in. Off by default, since projections sit far from price and stretch the price scale.

The block as a zone. Available behind an input, off by default. The levels are the thing; the box is optional.

Why the chart stays clean

Five things retire drawings, so nothing accumulates.

Failure erases. A set is deleted the moment price closes back through its CISD level. Delivery has reverted, the block is spent, and it leaves — lines, tags, sweep mark and all.

One price, one level. A new set whose level lands within half a body of a live one replaces it, on either side. They are one level re-detected as price chops around it, and two tags at one price is two names for one thing.

Age retires. A level price never closed back through would otherwise stay live forever. Sets older than a configurable age are dropped.

Live sets are capped. Oldest first, past a set limit.

Bodyless origins never qualify. An origin candle with almost no body is rejected outright. It is not an array, and its level and its 0.5 would print on top of each other.

A setting keeps failed sets on the chart, redrawn dotted and stripped of their projections, for anyone who wants the record instead of the read.

Everything is drawn black by default so the chart reads as one system rather than a colour code. State is carried by line style instead: solid means the level is live, dotted means it is reference. Every colour is an input if you want direction back in the hues.

Reversals

When a block fails it is not merely deleted, it arms the other side. The level that just failed IS the liquidity that was taken, so the opposite setup can confirm on the bar the failure happens rather than waiting for a fresh swing to form and confirm. Pivot confirmation is inherently late — a swing is only known once the bars either side of it exist — and on a sharp turn that lateness is the difference between marking the reversal and missing it. The behaviour is a setting, and turning it off restores strict pivot-only raids.

Reading it in practice

The CISD line is the trigger, not the entry. The setup is confirmed the moment price closes back through it; what you want next is the retrace into the 0.5, which is the half of the block delivering at a discount on a long. Stop beyond the distal edge — the far side of the origin candle's body — and let the standard deviation stubs frame where the leg is projecting toward. The sweep mark tells you which pool funded the move, which is usually the first thing to check when deciding whether the setup has a story behind it.

The setup ends when price closes back through the CISD level. That is the same line that confirmed it, and the script treats it as the invalidation, which is why a failed set erases itself.

Method and repainting

All detection evaluates on closed bars. The run, the reclaiming close, the sweep and the invalidation are confirmed on candle close, never intrabar — an in-progress candle, wick included, never creates or removes a set. Swing points come from a standard pivot and confirm the configured number of bars after they print, which is inherent to pivot detection: a swing is only known once the bars either side of it exist. Levels anchor to the candle that formed them and are drawn a fixed number of bars past the reclaim.

Alerts fire once per bar close on a confirmed setup.

Settings

Sweep gate: whether a sweep is required at all, pivot length, whether a sweep means a wick through with a close back inside or a close through, how far a raid may precede the run, whether the swept level is marked, one setup per sweep, whether a failed setup counts as a raid, and a minimum bar gap between setups on a side that applies only when the sweep gate is off.

Detection: minimum and maximum candles in the run, the earliest and latest bar of the reclaim window, a minimum origin body as a multiple of ATR, and which side to detect — both, bullish only or bearish only.

Drawing: the 0.5 line and its label, the distal edge, zone mode, bars drawn past the reclaim, the cap on live sets, whether failed sets are kept, merging sets at the same price, and the age at which a set retires.

Standard deviations: on or off, latest set only, the multiples list, whether the unit measures the whole run or the origin candle alone, stub length and stub offset.

Style: a colour per element and one label size for everything.

Analytics only

This is a decision-support tool for discretionary ICT study. It maps a structural sequence — a raid, a delivery leg, and the close that reverses it — and marks the levels that sequence produces. It contains no buy or sell signals and it does not tell you when to enter or exit. Its alerts announce that the pattern completed; they are notifications, not trade instructions.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
//@version=6
// CISD Order Block+ (M1D)
// Sweep -> delivery run -> a close back through the run's extreme body. That origin candle is the
// order block: its body edge is the CISD level, its body midpoint the 0.5, its far edge the distal.
indicator("CISD Order Block+ (M1D)", "CISD OB+ (M1D)", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     calc_bars_count = 5000)

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


// == INPUTS ==
const string G_SWEEP  = "Sweep gate"
const string G_DETECT = "Detection"
const string G_DRAW   = "Drawing"
const string G_STDV   = "Standard deviations"
const string G_STYLE  = "Style"

bool requireSweep = input.bool(true, "Only engage after a confirmed sweep", group = G_SWEEP,
     tooltip = "A bullish CISD needs a swing LOW taken first, a bearish one a swing HIGH.")
int  pivLen       = input.int(5, "Swing pivot length", minval = 1, maxval = 50, group = G_SWEEP,
     tooltip = "Bars either side of the pivot. A swing confirms this many bars after it prints.")
int  liqLook      = input.int(20, "Swing must be the extreme of (bars)", minval = 0, maxval = 500, group = G_SWEEP,
     tooltip = "A pivot only counts as liquidity when it is the lowest low (highest high) of this many " +
               "bars ending at the pivot - the extreme of a leg, not a pullback inside one. A 3-bar " +
               "wobble inside a run is not a pool; nobody's stop sits under it. 0 accepts every pivot.")
string sweepMode  = input.string("Wick through, close back inside", "What counts as a sweep",
     options = ["Wick through, close back inside", "Close through"], group = G_SWEEP,
     tooltip = "Wick through is the raid — liquidity taken and rejected. Close through is a break " +
               "of structure.")
int  sweepSlack   = input.int(2, "Sweep may precede the run by (bars)", minval = 0, maxval = 50,
     group = G_SWEEP)
bool oncePerSweep = input.bool(true, "One setup per sweep", group = G_SWEEP,
     tooltip = "A leg holds several runs and a reclaim closes through each in turn. On: one raid " +
               "produces one setup — the first close that reverses delivery. The next setup on " +
               "that side needs a new sweep.")
bool reversalRaid = input.bool(false, "A failed setup counts as a raid", group = G_SWEEP,
     tooltip = "When a block fails, its level becomes the liquidity that was taken, arming the " +
               "opposite side immediately instead of waiting for a pivot to confirm. This is what " +
               "lets a sharp reversal be caught on the bar it happens.")
int  minGap       = input.int(10, "Minimum bars between setups on a side", minval = 0, maxval = 500,
     group = G_SWEEP, tooltip = "Applies only when the sweep gate is OFF. With the gate on, a new " +
               "sweep is what separates setups and this would only suppress valid ones.")
bool showSweep    = input.bool(true, "Mark the swept level", group = G_SWEEP)

int  minRunIn  = input.int(2, "Minimum candles in the run", minval = 1, maxval = 10, group = G_DETECT)
int  maxRunIn  = input.int(6, "Maximum candles in the run", minval = 1, maxval = 20, group = G_DETECT,
     tooltip = "Longer runs are ignored — by then it is a trend, not a delivery leg.")
int  minWinIn  = input.int(1, "Reclaim window — earliest bar", minval = 1, maxval = 50, group = G_DETECT,
     tooltip = "Bars from the last candle of the run. 1 means an immediate reclaim counts.")
int  maxWinIn  = input.int(15, "Reclaim window — latest bar", minval = 1, maxval = 100, group = G_DETECT)
float minBody  = input.float(0.10, "Minimum origin body (x ATR)", minval = 0.0, maxval = 5.0,
     step = 0.05, group = G_DETECT,
     tooltip = "Rejects blocks whose origin candle has almost no body. Those are not arrays, and " +
               "their CISD and 0.5 print on top of each other. 0 disables the filter.")
string sideMode = input.string("Both", "Which side", options = ["Both", "Bullish only", "Bearish only"],
     group = G_DETECT)

bool showEq     = input.bool(true,  "Draw the 0.5 (body midpoint)",     group = G_DRAW)
bool showEqLbl  = input.bool(true,  "Label the 0.5",                    group = G_DRAW)
bool showDist   = input.bool(false, "Draw the distal edge",             group = G_DRAW)
bool showZone   = input.bool(false, "Draw the block as a zone as well", group = G_DRAW)
int  extendBars = input.int(6, "Bars drawn past the reclaim", minval = 1, maxval = 300, group = G_DRAW)
int  maxSets    = input.int(4, "Maximum live sets on chart", minval = 1, maxval = 40, group = G_DRAW)
bool keepFailed = input.bool(false, "Keep failed sets on the chart", group = G_DRAW,
     tooltip = "Off: a set is deleted when price closes back through its CISD level. On: it is " +
               "kept and redrawn dotted.")
bool dedupe     = input.bool(true, "Merge sets at the same price", group = G_DRAW,
     tooltip = "A new set landing within half a body of a live one replaces it, either side. " +
               "Two tags at one price is two names for one level.")
int  maxAge     = input.int(150, "Delete sets older than (bars, 0 = never)", minval = 0, maxval = 5000,
     group = G_DRAW)

bool   showStdv    = input.bool(false, "Draw standard deviation projections", group = G_STDV)
bool   stdvLatest  = input.bool(true, "Latest set only", group = G_STDV)
string stdvList    = input.string("1, 2, 2.5, 4", "Multiples", group = G_STDV,
     tooltip = "Comma separated. 1 is one full body-to-body range projected past the CISD level.")
bool   stdvBodyRun = input.bool(true, "Measure across the whole run", group = G_STDV,
     tooltip = "On: the run's full body range. Off: the origin candle's body only.")
int    stdvLen     = input.int(6, "Stub length (bars)", minval = 1, maxval = 60, group = G_STDV)
int    stdvOffset  = input.int(-8, "Stub offset from the reclaim (bars)", minval = -200, maxval = 100,
     group = G_STDV, tooltip = "Negative pulls the stubs left of the reclaim, clear of the right edge.")

color colBull = input.color(#000000, "Bullish", inline = "dir", group = G_STYLE)
color colBear = input.color(#000000, "Bearish", inline = "dir", group = G_STYLE)
color colEq   = input.color(#000000, "0.5 midline", group = G_STYLE)
color colSwp  = input.color(#000000, "Swept level", group = G_STYLE)
string labelSize = input.string("small", "Label text size",
     options = ["tiny", "small", "normal", "large"], group = G_STYLE)

//@function Resolves the label size input to a size constant.
//@param s (string) The raw input string.
//@returns (string) A size.* constant.
f_lblSize(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

string LBL_SZ = f_lblSize(labelSize)
const color INK = #000000
int  msPerBar  = timeframe.in_seconds(timeframe.period) * 1000
bool showBull  = sideMode != "Bearish only"
bool showBear  = sideMode != "Bullish only"
bool wickSweep = sweepMode == "Wick through, close back inside"
float atr14    = ta.atr(14)

// Inputs are clamped so an inverted pair cannot silently disable detection.
int minRun = math.min(minRunIn, maxRunIn)
int maxRun = math.max(minRunIn, maxRunIn)
int minWin = math.min(minWinIn, maxWinIn)
int maxWin = math.max(minWinIn, maxWinIn)

//@variable The parsed standard deviation multiples, resolved once on the first bar.
var array<float> stdvMults = array.new<float>(0)
if barstate.isfirst
    array<string> parts = str.split(stdvList, ",")
    if parts.size() > 0
        for i = 0 to parts.size() - 1
            float m = str.tonumber(str.replace_all(parts.get(i), " ", ""))
            if not na(m) and m > 0
                stdvMults.push(m)

// == TYPES ==

//@type A pending change in the state of delivery, waiting on a reclaiming close.
//@field level      Body high (bull) or body low (bear) of the origin candle — the CISD trigger.
//@field eq         Midpoint of the origin candle's own body.
//@field distal     Far edge of the origin candle's body.
//@field runFar     Far edge of the whole run's body range — the standard deviation unit.
//@field originTime Bar time of the origin candle.
//@field originBar  bar_index of the origin candle.
//@field runEndBar  bar_index of the last candle in the run.
type Cisd
    float level      = na
    float eq         = na
    float distal     = na
    float runFar     = na
    int   originTime = 0
    int   originBar  = 0
    int   runEndBar  = 0

//@type A confirmed CISD currently drawn, held so it can be retired when it fails.
//@field level      The CISD trigger level — a close back through this ends the set.
//@field bull       True for a bullish set.
//@field distal     Far edge of the origin body, sizing the merge tolerance.
//@field originTime Bar time of the origin candle.
//@field bornBar    bar_index the set was confirmed on.
//@field spent      True once the set has failed, so failure is handled exactly once.
//@field lines      Structural line objects.
//@field labels     Structural label objects.
//@field sdLines    Standard deviation stubs, held apart so they can be cleared alone.
//@field sdLabels   Standard deviation callouts.
//@field zone       The optional block box.
type Drawn
    float        level      = na
    bool         bull       = true
    float        distal     = na
    int          originTime = 0
    int          bornBar    = 0
    bool         spent      = false
    array<line>  lines      = na
    array<label> labels     = na
    array<line>  sdLines    = na
    array<label> sdLabels   = na
    box          zone       = na

// == STATE ==

//@variable Candidates awaiting a reclaiming close.
var array<Cisd>  bullPend = array.new<Cisd>(0)
var array<Cisd>  bearPend = array.new<Cisd>(0)
//@variable Sets currently drawn, oldest first.
var array<Drawn> liveSets = array.new<Drawn>(0)

//@variable Down run in progress: length, the extreme body's edges and origin, the run's far edge.
var int   downRun = 0
var float downTop = na
var float downBot = na
var float downFar = na
var int   downTime = 0
var int   downBar = 0
//@variable Up run in progress.
var int   upRun = 0
var float upBot = na
var float upTop = na
var float upFar = na
var int   upTime = 0
var int   upBar = 0

//@variable The most recent unswept swing high and low.
var float swingHigh = na
var int   swingHighTime = 0
var float swingLow = na
var int   swingLowTime = 0

//@variable The last confirmed sellside raid — level, the swept level's origin, the raid bar.
var float sslLevel = na
var int   sslFromTime = 0
var int   sslToTime = 0
var int   sslBar = -1
//@variable The last confirmed buyside raid.
var float bslLevel = na
var int   bslFromTime = 0
var int   bslToTime = 0
var int   bslBar = -1

//@variable The raid that already produced a setup on each side, and the bar it fired on.
var int bullSweepUsed = -1
var int bearSweepUsed = -1
var int lastBullBar = -1
var int lastBearBar = -1

bool bullCisd = false
bool bearCisd = false
float bullLevel = na
float bearLevel = na
float bullEq = na
float bearEq = na

// ta.* must run on every bar to keep its history consistent, so pivots live at global scope.
float pvtHighRaw = ta.pivothigh(high, pivLen, pivLen)
float pvtLowRaw  = ta.pivotlow(low, pivLen, pivLen)
// A pivot is liquidity only when it is the extreme of the leg it sits in: the highest high (lowest
// low) of liqLook bars ending at the pivot bar. That is what separates the swing stops rest behind
// from a small pullback inside a run, which a bare pivot length cannot tell apart.
float legHigh = ta.highest(high, math.max(liqLook, 1))
float legLow  = ta.lowest(low, math.max(liqLook, 1))
float pvtHigh = na(pvtHighRaw) ? na : (liqLook == 0 or pvtHighRaw >= legHigh[pivLen]) ? pvtHighRaw : na
float pvtLow  = na(pvtLowRaw)  ? na : (liqLook == 0 or pvtLowRaw  <= legLow[pivLen])  ? pvtLowRaw  : na

// == DRAWING ==

//@function Deletes only the standard deviation stubs of a set.
//@param d (Drawn) The set to strip.
//@returns (void)
f_clearStdv(Drawn d) =>
    if d.sdLines.size() > 0
        for i = 0 to d.sdLines.size() - 1
            line.delete(d.sdLines.get(i))
        d.sdLines.clear()
    if d.sdLabels.size() > 0
        for i = 0 to d.sdLabels.size() - 1
            label.delete(d.sdLabels.get(i))
        d.sdLabels.clear()

//@function Deletes every object belonging to a set.
//@param d (Drawn) The set to erase.
//@returns (void)
f_kill(Drawn d) =>
    if d.lines.size() > 0
        for i = 0 to d.lines.size() - 1
            line.delete(d.lines.get(i))
    if d.labels.size() > 0
        for i = 0 to d.labels.size() - 1
            label.delete(d.labels.get(i))
    f_clearStdv(d)
    box.delete(d.zone)

//@function Redraws a kept set as spent — every line dotted, projections dropped.
//@param d (Drawn) The set to fade.
//@returns (void)
f_fade(Drawn d) =>
    if d.lines.size() > 0
        for i = 0 to d.lines.size() - 1
            line.set_style(d.lines.get(i), line.style_dotted)
    f_clearStdv(d)

//@function Draws a level line plus its callout into a set.
//@param d (Drawn) The owning set.
//@param x1 (int) Bar time the line starts at.
//@param x2 (int) Bar time the line stops at.
//@param price (float) The level.
//@param txt (string) The callout text.
//@param col (color) Line colour.
//@param dotted (bool) True for a reference level, false for a live one.
//@param withLabel (bool) False draws the line only.
//@param leftLbl (bool) True anchors the callout at the left end, text running left.
//@param isStdv (bool) True banks the objects in the set's stdv arrays.
//@returns (void)
f_level(Drawn d, int x1, int x2, float price, string txt, color col, bool dotted, bool withLabel,
     bool leftLbl, bool isStdv) =>
    line ln = line.new(f_xClamp(x1), price, x2, price,
         xloc  = xloc.bar_time,
         color = col,
         width = 1,
         style = dotted ? line.style_dotted : line.style_solid)
    if isStdv
        d.sdLines.push(ln)
    else
        d.lines.push(ln)
    if withLabel
        label lb = label.new(leftLbl ? x1 : x2, price, txt,
             xloc      = xloc.bar_time,
             style     = leftLbl ? label.style_label_right : label.style_label_left,
             color     = color.new(#FFFFFF, 100),
             textcolor = INK,
             size      = LBL_SZ,
             textalign = leftLbl ? text.align_right : text.align_left)
        label.set_text_font_family(lb, font.family_monospace)
        if isStdv
            d.sdLabels.push(lb)
        else
            d.labels.push(lb)

//@function Draws a confirmed CISD and banks it as a live set.
//@param c (Cisd) The confirmed candidate.
//@param bull (bool) True for a bullish CISD.
//@param confirmTime (int) Bar time of the reclaiming close.
//@param swpLevel (float) The raided level, na when the gate is off.
//@param swpFrom (int) Bar time the raided level originated on.
//@param swpTo (int) Bar time of the raid.
//@returns (void)
f_draw(Cisd c, bool bull, int confirmTime, float swpLevel, int swpFrom, int swpTo) =>
    color dirCol = bull ? colBull : colBear
    int rightTime = confirmTime + extendBars * msPerBar
    Drawn d = Drawn.new(c.level, bull, c.distal, c.originTime, bar_index, false,
         array.new<line>(0), array.new<label>(0), array.new<line>(0), array.new<label>(0), na)

    // A set landing on a live one is the same level re-detected, either side. Replace it.
    if dedupe and liveSets.size() > 0
        float tol = math.abs(c.level - c.distal) * 0.5
        for i = liveSets.size() - 1 to 0
            Drawn old = liveSets.get(i)
            if math.abs(old.level - c.level) <= tol
                f_kill(old)
                liveSets.remove(i)

    if showStdv and stdvLatest and liveSets.size() > 0
        for i = 0 to liveSets.size() - 1
            f_clearStdv(liveSets.get(i))

    if showSweep and not na(swpLevel) and swpFrom > 0 and swpTo > swpFrom
        d.lines.push(line.new(f_xClamp(swpFrom), swpLevel, swpTo, swpLevel,
             xloc = xloc.bar_time, color = colSwp, width = 1, style = line.style_dotted))
        label xm = label.new(int(math.avg(swpFrom, swpTo)), swpLevel, "x",
             xloc      = xloc.bar_time,
             style     = label.style_none,
             color     = color.new(#FFFFFF, 100),
             textcolor = colSwp,
             size      = size.tiny,
             textalign = text.align_center)
        label.set_text_font_family(xm, font.family_monospace)
        d.labels.push(xm)

    if showZone
        d.zone := box.new(f_xClamp(c.originTime), math.max(c.level, c.distal),
             rightTime, math.min(c.level, c.distal),
             xloc         = xloc.bar_time,
             border_color = color.new(dirCol, 0),
             border_width = 1,
             border_style = line.style_solid,
             bgcolor      = color.new(dirCol, 88))

    f_level(d, c.originTime, rightTime, c.level, "CISD", dirCol, false, true, false, false)

    if showEq
        f_level(d, c.originTime, rightTime, c.eq, "0.5", colEq, true, showEqLbl, false, false)

    if showDist
        f_level(d, c.originTime, rightTime, c.distal, "", dirCol, true, false, false, false)

    if showStdv and stdvMults.size() > 0
        float unit = math.abs(c.level - (stdvBodyRun ? c.runFar : c.distal))
        if unit > 0
            int stubLeft  = confirmTime + stdvOffset * msPerBar
            int stubRight = stubLeft + stdvLen * msPerBar
            for i = 0 to stdvMults.size() - 1
                float mult = stdvMults.get(i)
                float lvl  = bull ? c.level + unit * mult : c.level - unit * mult
                f_level(d, stubLeft, stubRight, lvl,
                     str.tostring(mult) + " STDV", dirCol, true, true, true, true)

    liveSets.push(d)
    while liveSets.size() > maxSets
        f_kill(liveSets.shift())

// == DETECTION ==

if barstate.isconfirmed

    // -- Raids. Tested against the swing as it stood before this bar's pivot update; a swept
    //    swing is consumed so it cannot be raided twice. --
    if not na(swingLow) and low < swingLow and (wickSweep ? close > swingLow : close < swingLow)
        sslLevel    := swingLow
        sslFromTime := swingLowTime
        sslToTime   := time
        sslBar      := bar_index
        swingLow    := na

    if not na(swingHigh) and high > swingHigh and (wickSweep ? close < swingHigh : close > swingHigh)
        bslLevel    := swingHigh
        bslFromTime := swingHighTime
        bslToTime   := time
        bslBar      := bar_index
        swingHigh   := na

    if not na(pvtLow)
        swingLow     := pvtLow
        swingLowTime := time[pivLen]
    if not na(pvtHigh)
        swingHigh     := pvtHigh
        swingHighTime := time[pivLen]

    bool isDown = close < open
    bool isUp   = close > open

    // -- Runs. The origin is the run's EXTREME body, not simply its first candle: on a gap or an
    //    outside bar a later candle can carry the higher body top, and that is the level whose
    //    reclaim reverses the delivery. --
    if isDown
        if downRun == 0
            downTop  := open
            downBot  := close
            downTime := time
            downBar  := bar_index
            downFar  := close
        else if open > downTop
            downTop  := open
            downBot  := close
            downTime := time
            downBar  := bar_index
        downFar := math.min(downFar, close)
        downRun += 1
    else
        bool bigEnough = na(atr14) or minBody <= 0 or math.abs(downTop - downBot) >= minBody * atr14
        if showBull and downRun >= minRun and downRun <= maxRun and bigEnough
            bullPend.push(Cisd.new(downTop, math.avg(downTop, downBot), downBot,
                 downFar, downTime, downBar, bar_index - 1))
        downRun := 0

    if isUp
        if upRun == 0
            upBot  := open
            upTop  := close
            upTime := time
            upBar  := bar_index
            upFar  := close
        else if open < upBot
            upBot  := open
            upTop  := close
            upTime := time
            upBar  := bar_index
        upFar := math.max(upFar, close)
        upRun += 1
    else
        bool bigEnough = na(atr14) or minBody <= 0 or math.abs(upTop - upBot) >= minBody * atr14
        if showBear and upRun >= minRun and upRun <= maxRun and bigEnough
            bearPend.push(Cisd.new(upBot, math.avg(upBot, upTop), upTop,
                 upFar, upTime, upBar, bar_index - 1))
        upRun := 0

    // -- Bullish reclaim. The gap throttle applies only when the sweep gate is off; with the gate
    //    on, a new raid is what separates one setup from the next. --
    bool bullGapOk  = requireSweep or lastBullBar < 0 or bar_index - lastBullBar >= minGap
    bool bullAllowed = (not oncePerSweep or not requireSweep or sslBar != bullSweepUsed) and bullGapOk
    Cisd bestBull = na
    if bullPend.size() > 0
        for i = bullPend.size() - 1 to 0
            Cisd c = bullPend.get(i)
            int age = bar_index - c.runEndBar
            if age > maxWin
                bullPend.remove(i)
            else if bullAllowed and age >= minWin and close > c.level
                if not requireSweep or (sslBar >= 0 and sslBar >= c.originBar - sweepSlack)
                    if na(bestBull) or c.level > bestBull.level
                        bestBull := c
                    bullPend.remove(i)

    if not na(bestBull)
        bullCisd      := true
        bullLevel     := bestBull.level
        bullEq        := bestBull.eq
        bullSweepUsed := sslBar
        lastBullBar   := bar_index
        bullPend.clear()
        f_draw(bestBull, true, time, requireSweep ? sslLevel : na, sslFromTime, sslToTime)

    // -- Bearish reclaim. --
    bool bearGapOk   = requireSweep or lastBearBar < 0 or bar_index - lastBearBar >= minGap
    bool bearAllowed = (not oncePerSweep or not requireSweep or bslBar != bearSweepUsed) and bearGapOk
    Cisd bestBear = na
    if bearPend.size() > 0
        for i = bearPend.size() - 1 to 0
            Cisd c = bearPend.get(i)
            int age = bar_index - c.runEndBar
            if age > maxWin
                bearPend.remove(i)
            else if bearAllowed and age >= minWin and close < c.level
                if not requireSweep or (bslBar >= 0 and bslBar >= c.originBar - sweepSlack)
                    if na(bestBear) or c.level < bestBear.level
                        bestBear := c
                    bearPend.remove(i)

    if not na(bestBear)
        bearCisd      := true
        bearLevel     := bestBear.level
        bearEq        := bestBear.eq
        bearSweepUsed := bslBar
        lastBearBar   := bar_index
        bearPend.clear()
        f_draw(bestBear, false, time, requireSweep ? bslLevel : na, bslFromTime, bslToTime)

    // -- Retirement. A close back through the CISD level ends the set. Failure is handled once,
    //    and it arms the opposite side: the block's own level is the liquidity that was taken, so
    //    a reversal does not have to wait for a fresh pivot to confirm. --
    if liveSets.size() > 0
        for i = liveSets.size() - 1 to 0
            Drawn d = liveSets.get(i)
            bool failed = not d.spent and (d.bull ? close < d.level : close > d.level)
            bool stale  = maxAge > 0 and bar_index - d.bornBar > maxAge

            if failed
                d.spent := true
                if reversalRaid
                    if d.bull
                        bslLevel      := d.level
                        bslFromTime   := d.originTime
                        bslToTime     := time
                        bslBar        := bar_index
                        bearSweepUsed := -1
                        lastBearBar   := -1
                    else
                        sslLevel      := d.level
                        sslFromTime   := d.originTime
                        sslToTime     := time
                        sslBar        := bar_index
                        bullSweepUsed := -1
                        lastBullBar   := -1
                if keepFailed
                    f_fade(d)

            if (d.spent and not keepFailed) or stale
                f_kill(d)
                liveSets.remove(i)

    while bullPend.size() > 20
        bullPend.shift()
    while bearPend.size() > 20
        bearPend.shift()

// == ALERTS ==
alertcondition(bullCisd, "Bullish CISD", "Bullish CISD on {{ticker}} — sellside swept, bull OB set")
alertcondition(bearCisd, "Bearish CISD", "Bearish CISD on {{ticker}} — buyside swept, bear OB set")

if bullCisd
    alert("Bullish CISD " + syminfo.ticker + " " + timeframe.period +
         " | level " + str.tostring(bullLevel, format.mintick) +
         " | 0.5 " + str.tostring(bullEq, format.mintick),
         alert.freq_once_per_bar_close)
if bearCisd
    alert("Bearish CISD " + syminfo.ticker + " " + timeframe.period +
         " | level " + str.tostring(bearLevel, format.mintick) +
         " | 0.5 " + str.tostring(bearEq, format.mintick),
         alert.freq_once_per_bar_close)
````
