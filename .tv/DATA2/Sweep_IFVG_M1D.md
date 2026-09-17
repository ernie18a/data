<!-- tradingview-pine-id: PUB;df302027bd7a4435a6c2ccc3e9a11142 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sweep IFVG (M1D)

Source: https://www.tradingview.com/script/XXWVc6m3-Sweep-IFVG-M1D/

## Description

Sweep IFVG 
Marks one sequence and refuses to mark anything else.
Liquidity is taken, a fair value gap opens away from it, and that gap then fails and inverts. 
Each stage has to happen in order and inside a window you set, or the zone is never drawn. 

Most gap indicators draw every imbalance on the chart and let you sort out which ones matter. This one starts from the liquidity event and works forward, so a gap that opened without a raid in front of it is not a candidate and never appears. What survives to the chart is a small number of zones with a reason behind each one.

The sweep

A swing is the three-candle structure; one candle each side of the middle one, the middle holding the high or the low. That is the default, and it can be widened when you want only larger structure tracked. A sweep is that level being wicked through and rejected on the same candle: price trades beyond the swing extreme and the candle closes back inside it. A raided high is a buyside sweep, a raided low is a sellside sweep.

Each sweep is marked with a small arrow set clear of the bar — above a swept high, below a swept low — and the level that was taken is drawn as a solid line back to the candle that formed it, so the origin of the raid stays visible rather than being implied.

Sweeps are capped at a number you choose. Past it, the oldest arrow and its level line are removed together, so a sweep never half-disappears.

The candidate gap

A sweep stays live for a set number of bars afterwards. Only inside that window can a fair value gap be adopted as its displacement, which is what stops an unrelated gap forty bars later being attributed to a raid it had nothing to do with.

The displacement itself is read over three candles and has to clear a minimum size in ticks to count. It must also run the same way as the reaction the sweep implies: a raided low can only qualify a bullish leg, a raided high only a bearish one. Two things qualify — a fair value gap, and a suspension block — and the section below covers how they differ.

A qualifying gap is drawn as a dashed box named BISI or SIBI. That is a candidate — a gap on watch, nothing more.

Volume imbalance and suspension blocks

A fair value gap is measured wick to wick, and on a fast leg that understates the region. Where the candle bodies also gap but the wicks still bridge the space, there is a volume imbalance sitting on the seam, and it is part of the same imbalance rather than a separate object. The zone absorbs it: the edge extends from the wick out to the body it should have reached. Each gap has two seams, one either side of the displacement candle, and each is tested on its own.

A suspension block is what happens when both joins gap at once. Three candles run the same way and each one opens beyond the previous one's close, so the bodies never trade back through the leg at any point in it. The zone is then the whole suspended span, from the first candle's close to the last candle's open, and it is named SB+ or SB- rather than BISI or SIBI.

It qualifies on its own terms and does not need a fair value gap to be present. A leg can be stacked tightly enough that every wick overlaps the one before it — no wick gap anywhere — while the bodies still never trade back. That is the case a wick-measured gap cannot see at all. Where a wick gap is present as well, the block's span is drawn instead, and it always contains the gap it replaces: the first candle's close sits at or below that gap's high, and the last candle's open at or above its low.

A block goes on to fail and invert on exactly the same terms as any other candidate. The resolved edges — absorbed or suspended — are what the midpoint line, the overlap rule and the failure test are all measured against.

One exclusion is built in. A body gap across a session or weekend break is a calendar artefact rather than displacement, so a join spanning more than one bar's worth of time is rejected. Without it a daily session break would manufacture a block every day. The rule applies to blocks, which is where that would happen.

Absorption and block detection each have their own switch. With both off, every zone is the plain wick-to-wick gap.

The inversion

A candidate has a limited number of bars to fail. Failure means a candle body closing clean through the gap, not a wick into it: a wick is a probe, and probes are not delivery.

When that close happens the box turns solid, changes colour, and is renamed IFVG+ or IFVG-. The names describe how the gap was built and which way it now trades — a bullish gap that gets closed through becomes a bearish inversion. Both directions share one confirmed colour, because at that point the useful distinction is confirmed against candidate, and direction is already stated in the name.

A candidate that never fails inside its window is deleted rather than left on the chart. Nothing that did not complete the sequence stays drawn.

Consequent encroachment

Each zone can carry its midpoint — the consequent encroachment of that gap, which is a different object from the equilibrium of a range. It is off by default and has its own colour, width and line style.

Zone names sit beside the box, on its centre line, just past the right edge. The midpoint line stops at that edge and the text starts there, so neither ever crosses the other, and a name stays readable when the zone it belongs to is only a few pixels tall.

Keeping the chart readable

Four limits, all yours to set. Candidates are capped per side and confirmed inversions are capped per side, oldest dropped first. A new zone can optionally be refused when it overlaps one already on the chart, which is what stops a run of gaps stacking into a single unreadable block on a fast leg.

The fourth is distance. A zone left hanging far from the candles forces the price scale to keep reaching for it, so the candles end up squashed into part of the pane and the whole thing rescales every time you touch the chart. Confirmed zones past a set distance are dropped, measured from the nearer edge of the zone to the current close and expressed in chart-timeframe ATR so it carries across instruments and timeframes. A zone price is trading inside reads as near zero and can never be dropped from under the candles.

Candidates are never dropped this way — one has to stay in play to be able to invert at all — and they expire on their own grace window regardless.

Colours, border width, label text, label size and every name string are settings, including the words BISI, SIBI, SB+, SB-, IFVG+ and IFVG- themselves.

Alerts

Four. Buyside sweep, sellside sweep, bullish IFVG confirmed, bearish IFVG confirmed. The two sweep alerts fire on the raid itself; the two inversion alerts fire on the close that completes the failure.

Method & repainting

Everything is read from the chart timeframe. There are no higher-timeframe requests anywhere in the script, so there is no lookahead to get wrong and no future data to leak.

Every detection is gated to a confirmed bar close. A sweep, a gap and an inversion are all judged on closed candles, so nothing appears mid-bar and then withdraws.

One characteristic is worth stating plainly, because it is inherent to pivots rather than a fault: a swing is only confirmed once the bars to its right have printed. On the three-candle default that is one bar, and a sweep can only be measured against a swing that has been confirmed. Widening the swing setting widens that delay by the same amount. It is lag, not repainting — the marks do not move once drawn.

Zones and midpoint lines extend rightward to the current bar while they are live. That is the boxes tracking the present, not their history changing.

What it will not do

It places no entries, exits, stops or targets, and it does not size a position. It draws no trend, no bias and no target projection.

It does not read structure beyond the pivots it uses to find swings, and it does not label market phases. Whether a completed inversion is worth trading is a judgement about context this script does not have — session, higher-timeframe draw, and what the day has already done.

A sweep alone draws nothing but its arrow and its level. Displacement alone, with no raid in front of it, draws nothing at all. Only the finished sequence produces a zone, so an empty chart in a range is the tool working, not failing.

Settings

Swing lookback, sweep validity window, sweep markers and their size, the swept-level line and its width, and the cap on sweeps shown; minimum gap size, volume imbalance absorption, suspension block detection, inversion grace window, the per-side caps on candidates and confirmed inversions, the overlap rule and the distance gate with its ATR multiple; candidate and confirmed colours, sweep colour and zone border width; the midpoint line with its colour, width and style; and zone labels with their six name strings, size and text colour.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results. It draws where a level failed, a candidate imbalance and leaves the decision to you.

---

## Source Code

````pine
//@version=6
indicator("Sweep IFVG (M1D)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

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


// ============================== INPUTS ==========================================
grp_swing = "Swing & Sweep"
swingLen        = input.int(3, "Swing Lookback (Bars Each Side of the Middle Candle)", minval = 1, maxval = 20, group = grp_swing, tooltip = "1 is the ICT swing: three candles, one each side of the middle one. Raise it to ignore small swings and only track larger structure.")
liqLook         = input.int(50, "Swing Must Be the Extreme of (Bars)", minval = 0, maxval = 500, group = grp_swing, tooltip = "A swing only counts as liquidity when it is the highest high (lowest low) of this many bars ending at the swing - the extreme of a leg, not a turn inside one. Stops rest behind the leg extreme, not behind every three-candle pullback. 0 accepts every swing.")
sweepValidBars  = input.int(50, "Sweep Validity Window (Bars)", minval = 1, maxval = 50, group = grp_swing, tooltip = "How many bars after a sweep the displacement FVG may still form and qualify as a candidate.")
showSweepMarks     = input.bool(true, "Show Sweep Markers (arrow)", group = grp_swing)
sweepMarkSizeInput = input.string("Tiny", "Sweep Marker Size", options = ["Tiny", "Small", "Normal", "Large"], group = grp_swing)
showSweepLine      = input.bool(true, "Show Sweep Line (the level that got swept)", group = grp_swing)
sweepLineWidth     = input.int(1, "Sweep Line Width", minval = 1, maxval = 4, group = grp_swing)
maxSweepsShown     = input.int(10, "Max Sweeps Shown", minval = 1, maxval = 100, group = grp_swing, tooltip = "How many of the most recent sweeps stay on the chart — arrow and swept-level line together. Older ones are dropped.")

grp_fvg = "FVG & Inversion"
minGapTicks   = input.int(30, "Minimum Gap Size (Ticks)", minval = 0, group = grp_fvg)
graceBars     = input.int(7, "Inversion Grace Window (Bars)", minval = 2, maxval = 30, group = grp_fvg, tooltip = "How many bars a candidate FVG has to be closed clean through (candle body) before it's dropped as no longer part of the swing.")
mergeVi       = input.bool(true, "Absorb Volume Imbalances Into Gaps", group = grp_fvg, tooltip = "A volume imbalance — a BODY gap the wicks still bridge — on either seam of the displacement candle extends the zone to that body edge. The imbalance is one region and the wick gap alone understates it.")
showSb        = input.bool(true, "Detect Suspension Blocks", group = grp_fvg, tooltip = "Three same-direction candles, each opening beyond the previous one's close, so the bodies never trade back through the leg at either join. Qualifies on its own — a suspension block does not need a fair value gap to be present, and when there is one the block's wider span is drawn instead.")
maxCandidates = input.int(3, "Max Active Candidates (per side)", minval = 1, maxval = 10, group = grp_fvg)
maxInverted   = input.int(2, "Max Confirmed IFVGs (per side)", minval = 1, maxval = 10, group = grp_fvg)
useDistGate   = input.bool(false, "Drop Confirmed Zones Far From Price", group = grp_fvg, tooltip = "A zone left hanging far from the candles forces the price scale to keep reaching for it, so the candles get squashed into part of the pane and it rescales every time you touch the chart. Confirmed zones past the distance below are dropped. Candidates are never dropped this way — one has to stay in play to be able to invert at all.")
distGateAtr   = input.float(4.0, "Drop Beyond (x ATR)", minval = 1.0, maxval = 50.0, step = 0.5, group = grp_fvg, tooltip = "Measured from the nearer edge of the zone to the current close, in chart-timeframe ATR so it travels across instruments and timeframes. Raise it to keep more of the record on the chart.")
skipOverlap   = input.bool(false, "Skip New Zone If It Overlaps An Existing One", group = grp_fvg, tooltip = "Stops candidates stacking on top of each other (and on top of confirmed IFVGs) into an unreadable block.")

grp_zone = "Zone Appearance"
bullColor     = input.color(color.new(#7246CE, 65), "Bullish Candidate Color", group = grp_zone)
bearColor     = input.color(color.new(#DB1D9C, 65), "Bearish Candidate Color", group = grp_zone)
invertedColor = input.color(color.new(#FF7503, 50), "Confirmed IFVG Color (both directions)", group = grp_zone, tooltip = "One colour for every confirmed inversion regardless of direction; direction is read from the +/- text instead.")
sweepColor    = input.color(#000000, "Sweep Color (marker + line)", group = grp_zone)
zoneBorderWidth = input.int(1, "Zone Border Width", minval = 1, maxval = 4, group = grp_zone)

grp_ce = "Consequent Encroachment (CE)"
showCE   = input.bool(true, "Show CE (50%) Line", group = grp_ce)
ceColor  = input.color(#000000, "CE Color", group = grp_ce)
ceWidth  = input.int(1, "CE Width", minval = 1, maxval = 4, group = grp_ce)
ceStyleInput = input.string("Dotted", "CE Style", options = ["Solid", "Dashed", "Dotted"], group = grp_ce)

grp_label = "Labels"
showLabels     = input.bool(true, "Show Zone Labels", group = grp_label)
bullCandText   = input.string("BISI", "Bullish Candidate Text", group = grp_label)
bearCandText   = input.string("SIBI", "Bearish Candidate Text", group = grp_label)
bullSbText     = input.string("SB+", "Bullish Suspension Block Text", group = grp_label)
bearSbText     = input.string("SB-", "Bearish Suspension Block Text", group = grp_label)
bullInvText    = input.string("IFVG+", "Bullish Inversion Text", group = grp_label)
bearInvText    = input.string("IFVG-", "Bearish Inversion Text", group = grp_label)
labelSizeInput = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grp_label)
labelTextColor = input.color(#000000, "Label Text Color", group = grp_label)

// ============================== STYLE RESOLUTION =================================
//@function Maps a size dropdown string to its label/plotshape size constant.
f_lblSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

//@function Maps a style dropdown string to its line style constant.
f_lineStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_dotted

string LBL_SZ       = f_lblSize(labelSizeInput)
string SWEEP_SZ     = f_lblSize(sweepMarkSizeInput)
string resolvedCeStyle = f_lineStyle(ceStyleInput)

//@function Draws a zone's caption BESIDE the box, on its centre line, past the right edge.
//          Nothing inside the box can clip it: the CE line stops at that edge and the text
//          starts there, so the two never contest the same pixels, and unlike box text a
//          label is never clipped when the zone gets small on screen.
//          Centre-line placement is also what makes caption collision a non-problem rather
//          than something to engineer around. Two captions can only touch when the zones'
//          middles are within a line of text of each other, and by then the two boxes are a
//          hair apart and already read as one band — the cluster is the information. The
//          corner placement this replaced was worse for the same reason: it measured from
//          the zones' touching EDGES rather than their centres.
//          This is the standard's level-label treatment — style_label_left puts the text to
//          the RIGHT of the anchor, beside the level instead of across it.
//@param x   (int)    Bar index of the box's right edge.
//@param top (float)  Zone top price.
//@param bot (float)  Zone bottom price.
//@param txt (string) Caption text.
//@returns (label) The caption, or na when captions are switched off.
f_zoneCap(int x, float top, float bot, string txt) =>
    label lb = na
    if showLabels
        lb := label.new(x, math.avg(top, bot), txt, style = label.style_label_left, color = color.new(color.white, 100), textcolor = labelTextColor, size = LBL_SZ, textalign = text.align_left)
        label.set_text_font_family(lb, font.family_monospace)
    lb

//@function Resolves the zone a qualifying displacement leg should draw.
//          A SUSPENSION BLOCK is the whole suspended span — the first candle's close to the
//          last candle's open — because the bodies never traded back through the leg at
//          either join. It is two volume imbalances joined through the middle body, so one
//          zone across the run is the honest shape rather than two seams drawn separately.
//          Anything else is the wick gap, widened at either seam carrying a volume imbalance:
//          a BODY gap the wicks still bridge is part of the same region, and the wick gap on
//          its own understates it.
//          The block's span always contains the wick gap's — its close is at or below that
//          gap's high, its open at or above that gap's low — so preferring it loses nothing.
//@param bull (bool) True for a bullish leg.
//@param isSb (bool) True when the leg qualified as a suspension block.
//@returns [float, float] The zone's top and bottom.
f_zoneFor(bool bull, bool isSb) =>
    float t = bull ? low     : low[2]
    float b = bull ? high[2] : high
    if isSb
        t := bull ? open     : close[2]
        b := bull ? close[2] : open
    else if mergeVi
        float bNewT = math.max(open,    close)
        float bNewB = math.min(open,    close)
        float bMidT = math.max(open[1], close[1])
        float bMidB = math.min(open[1], close[1])
        float bOldT = math.max(open[2], close[2])
        float bOldB = math.min(open[2], close[2])
        if bull
            if bMidB > bOldT and low[1] <= high[2]
                b := math.min(b, bOldT)
            if bNewB > bMidT and low <= high[1]
                t := math.max(t, bNewB)
        else
            if bMidT < bOldB and high[1] >= low[2]
                t := math.max(t, bOldB)
            if bNewT < bMidB and high >= low[1]
                b := math.min(b, bNewT)
    [t, b]

// Called unconditionally at global scope so the series is continuous — a ta.* call made
// inside a branch skips bars and returns a different number from the same input.
float gateAtr = ta.atr(14)


// ============================== SWING & SWEEP DETECTION ==========================
// A swing is the three-candle ICT structure — one candle each side of the middle one,
// which is why swingLen defaults to 1 rather than to a wider pivot. Widening it is a
// filter for larger structure, not a correction.
// Liquidity sweep = price wicks beyond the last confirmed swing extreme, then the
// same candle's body closes back inside it. A buyside sweep (swing high raided)
// implies a bearish reaction; a sellside sweep (swing low raided) implies bullish.
float phRaw = ta.pivothigh(swingLen, swingLen)
float plRaw = ta.pivotlow(swingLen, swingLen)
// The three-candle swing is the SHAPE; the leg-extreme test is which of them is liquidity.
float legHigh = ta.highest(high, math.max(liqLook, 1))
float legLow  = ta.lowest(low, math.max(liqLook, 1))
float ph = na(phRaw) ? na : (liqLook == 0 or phRaw >= legHigh[swingLen]) ? phRaw : na
float pl = na(plRaw) ? na : (liqLook == 0 or plRaw <= legLow[swingLen])  ? plRaw : na

var float lastSwingHigh    = na
var float lastSwingLow     = na
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
if not na(ph)
    lastSwingHigh    := ph
    lastSwingHighBar := bar_index - swingLen
if not na(pl)
    lastSwingLow    := pl
    lastSwingLowBar := bar_index - swingLen

bool sweptHigh = barstate.isconfirmed and not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh
bool sweptLow  = barstate.isconfirmed and not na(lastSwingLow)  and low  < lastSwingLow  and close > lastSwingLow

var int sweptHighBar = na
var int sweptLowBar  = na
if sweptHigh
    sweptHighBar := bar_index
if sweptLow
    sweptLowBar := bar_index

// A sweep stays "active" — able to qualify the next FVG as its displacement leg —
// only for a short window after it fires, so a stale sweep can't adopt an unrelated gap.
bool highSweepActive = not na(sweptHighBar) and (bar_index - sweptHighBar) <= sweepValidBars
bool lowSweepActive  = not na(sweptLowBar)  and (bar_index - sweptLowBar)  <= sweepValidBars

// One marker per sweep event — the arrow — not an arrow plus a text label competing
// for the same spot. The actual swept level is drawn as its own line, below.
// Drawn as label objects, not plotshape: plotshape's size only takes a compile-time
// constant, so an input-driven size is impossible there. Label markers accept it.
// Arrow styles, not triangles: an arrow glyph sits OFF the bar it names — above a swept
// high, below a swept low — where a triangle is drawn centred on the price and lands on
// the candle itself. It is also a far lighter mark at the same size setting.
var array<label> sweepMarks = array.new<label>()
var array<line>  sweepLines = array.new<line>()

if showSweepMarks and sweptHigh
    label mk = label.new(bar_index, high, "", style = label.style_arrowdown, color = sweepColor, size = SWEEP_SZ)
    array.push(sweepMarks, mk)
    while array.size(sweepMarks) > maxSweepsShown
        label.delete(array.shift(sweepMarks))

if showSweepMarks and sweptLow
    label mk = label.new(bar_index, low, "", style = label.style_arrowup, color = sweepColor, size = SWEEP_SZ)
    array.push(sweepMarks, mk)
    while array.size(sweepMarks) > maxSweepsShown
        label.delete(array.shift(sweepMarks))

if showSweepLine and sweptHigh
    line swLn = line.new(math.max(lastSwingHighBar, bar_index - ORIGIN_MAX), lastSwingHigh, bar_index, lastSwingHigh, color = sweepColor, width = sweepLineWidth, style = line.style_solid)
    array.push(sweepLines, swLn)
    while array.size(sweepLines) > maxSweepsShown
        line.delete(array.shift(sweepLines))

if showSweepLine and sweptLow
    line swLn = line.new(math.max(lastSwingLowBar, bar_index - ORIGIN_MAX), lastSwingLow, bar_index, lastSwingLow, color = sweepColor, width = sweepLineWidth, style = line.style_solid)
    array.push(sweepLines, swLn)
    while array.size(sweepLines) > maxSweepsShown
        line.delete(array.shift(sweepLines))

// ============================== FVG DETECTION =====================================
bool is_bull_fvg = low > high[2] and barstate.isconfirmed and (low - high[2]) >= minGapTicks * syminfo.mintick
bool is_bear_fvg = high < low[2] and barstate.isconfirmed and (low[2] - high) >= minGapTicks * syminfo.mintick

// ============================== SUSPENSION BLOCK DETECTION ========================
// Three same-direction candles, each opening beyond the previous one's close: the bodies
// never trade back through the leg at either join. That is a volume imbalance on both
// seams at once, joined through the middle body, and it qualifies WITHOUT a wick gap —
// a leg can be stacked enough that every wick overlaps and still never let its bodies
// trade back. Where a wick gap is present too the block's wider span is drawn instead.
//
// A body gap across a session or weekend break is a calendar artefact, not displacement,
// so any join spanning more than one bar's worth of time is rejected. This guard is on the
// block only — it is where a daily session break would otherwise manufacture one every day.
float barMs         = timeframe.in_seconds(timeframe.period) * 1000.0
bool  contiguousLeg = (time - time[1]) <= barMs * 1.5 and (time[1] - time[2]) <= barMs * 1.5

bool sbUpRaw = close[2] > open[2] and close[1] > open[1] and close > open and open[1] > close[2] and open > close[1]
bool sbDnRaw = close[2] < open[2] and close[1] < open[1] and close < open and open[1] < close[2] and open < close[1]

bool is_bull_sb = showSb and barstate.isconfirmed and contiguousLeg and sbUpRaw and (open - close[2]) >= minGapTicks * syminfo.mintick
bool is_bear_sb = showSb and barstate.isconfirmed and contiguousLeg and sbDnRaw and (close[2] - open) >= minGapTicks * syminfo.mintick

// A leg only becomes a tracked candidate when a same-direction sweep is still active —
// liquidity taken, THEN displacement, THEN the gap: the classic ICT sequencing.
bool bullCandidateQualifies = (is_bull_fvg or is_bull_sb) and lowSweepActive
bool bearCandidateQualifies = (is_bear_fvg or is_bear_sb) and highSweepActive

// ============================== DATA STRUCTURES ===================================
// Captions are their own label objects rather than box text: box text can only be aligned
// to the box's centre band, which is exactly where the CE line runs, so the 50% line cut
// straight through the name. A corner label keeps both readable.
var array<box>   candBoxes      = array.new<box>()
var array<bool>  candBull       = array.new<bool>()
var array<int>   candCreatedBar = array.new<int>()
var array<line>  candCE         = array.new<line>()
var array<label> candLabs       = array.new<label>()

var array<box>   invBoxes = array.new<box>()
var array<bool>  invBull  = array.new<bool>()
var array<line>  invCE    = array.new<line>()
var array<label> invLabs  = array.new<label>()

//@function True if [newTop, newBot] intersects any existing box's price range in the array.
f_overlaps(array<box> boxes, float newTop, float newBot) =>
    bool found = false
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box bx = array.get(boxes, i)
            float t = box.get_top(bx)
            float b = box.get_bottom(bx)
            if newTop > b and t > newBot
                found := true
    found

// ============================== CANDIDATE CREATION ================================
if bullCandidateQualifies
    // Resolve the zone first: the overlap test, the CE and the caption anchor all have to
    // see the zone's real edges, not the raw wick gap they started from.
    [top, bot] = f_zoneFor(true, is_bull_sb)
    bool  blocked = skipOverlap and (f_overlaps(candBoxes, top, bot) or f_overlaps(invBoxes, top, bot))
    if not blocked
        box b = box.new(bar_index[2], top, bar_index, bot, border_color = color.new(bullColor, 15), border_width = zoneBorderWidth, border_style = line.style_dashed, bgcolor = bullColor)
        label lb = f_zoneCap(bar_index, top, bot, is_bull_sb ? bullSbText : bullCandText)
        line ce = na
        if showCE
            float mid = (top + bot) / 2
            ce := line.new(bar_index[2], mid, bar_index, mid, color = ceColor, width = ceWidth, style = resolvedCeStyle)
        array.push(candBoxes, b)
        array.push(candBull, true)
        array.push(candCreatedBar, bar_index)
        array.push(candCE, ce)
        array.push(candLabs, lb)

if bearCandidateQualifies
    [top, bot] = f_zoneFor(false, is_bear_sb)
    bool  blocked = skipOverlap and (f_overlaps(candBoxes, top, bot) or f_overlaps(invBoxes, top, bot))
    if not blocked
        box b = box.new(bar_index[2], top, bar_index, bot, border_color = color.new(bearColor, 15), border_width = zoneBorderWidth, border_style = line.style_dashed, bgcolor = bearColor)
        label lb = f_zoneCap(bar_index, top, bot, is_bear_sb ? bearSbText : bearCandText)
        line ce = na
        if showCE
            float mid = (top + bot) / 2
            ce := line.new(bar_index[2], mid, bar_index, mid, color = ceColor, width = ceWidth, style = resolvedCeStyle)
        array.push(candBoxes, b)
        array.push(candBull, false)
        array.push(candCreatedBar, bar_index)
        array.push(candCE, ce)
        array.push(candLabs, lb)

// ============================== CANDIDATES: INVERT / EXPIRE / PRUNE ===============
bool bullInvertedNow = false
bool bearInvertedNow = false

if array.size(candBoxes) > 0
    for i = array.size(candBoxes) - 1 to 0
        box   b       = array.get(candBoxes, i)
        bool  bull    = array.get(candBull, i)
        int   created = array.get(candCreatedBar, i)
        line  ce      = array.get(candCE, i)
        label lb      = array.get(candLabs, i)

        float top = box.get_top(b)
        float bot = box.get_bottom(b)
        // A candle BODY close through the gap is a failed delivery — the FVG inverts.
        // A wick alone is just a probe and does not count (Rule per ICT IFVG model).
        bool closedThrough = bull ? (close < bot) : (close > top)

        int sameSideCount = 0
        for j = array.size(candBoxes) - 1 to i
            if array.get(candBull, j) == bull
                sameSideCount += 1

        if barstate.isconfirmed and closedThrough
            bool newBull = not bull
            box.set_bgcolor(b, invertedColor)
            box.set_border_color(b, invertedColor)
            box.set_border_style(b, line.style_solid)
            // Only the TEXT flips. The caption already sits on the zone's centre line, which
            // does not depend on direction, so nothing about its placement has to move.
            if not na(lb)
                label.set_text(lb, newBull ? bullInvText : bearInvText)
            if not na(ce)
                line.set_color(ce, ceColor)
            array.remove(candBoxes, i)
            array.remove(candBull, i)
            array.remove(candCreatedBar, i)
            array.remove(candCE, i)
            array.remove(candLabs, i)
            array.push(invBoxes, b)
            array.push(invBull, newBull)
            array.push(invCE, ce)
            array.push(invLabs, lb)
            if newBull
                bullInvertedNow := true
            else
                bearInvertedNow := true
            continue

        if bar_index - created > graceBars or sameSideCount > maxCandidates
            box.delete(b)
            if not na(ce)
                line.delete(ce)
            if not na(lb)
                label.delete(lb)
            array.remove(candBoxes, i)
            array.remove(candBull, i)
            array.remove(candCreatedBar, i)
            array.remove(candCE, i)
            array.remove(candLabs, i)
            continue

        box.set_right(b, bar_index)
        if not na(ce)
            line.set_x2(ce, bar_index)
        if not na(lb)
            label.set_x(lb, bar_index)

// ============================== CONFIRMED IFVGs: EXTEND / PRUNE ===================
if array.size(invBoxes) > 0
    for i = array.size(invBoxes) - 1 to 0
        box   b    = array.get(invBoxes, i)
        bool  bull = array.get(invBull, i)
        line  ce   = array.get(invCE, i)
        label lb   = array.get(invLabs, i)

        int sameSideCount = 0
        for j = array.size(invBoxes) - 1 to i
            if array.get(invBull, j) == bull
                sameSideCount += 1

        // Distance is measured to the NEARER edge, so a zone price is sitting inside reads
        // as near-zero and can never be gated out from under the candles. The zone is
        // dropped rather than hidden: a confirmed inversion has already fired its alert and
        // nothing downstream selects it, so there is no model left to keep. That is the same
        // treatment the per-side cap already gives the oldest zone.
        float zTop   = box.get_top(b)
        float zBot   = box.get_bottom(b)
        float dist   = math.min(math.abs(close - zTop), math.abs(close - zBot))
        bool  tooFar = useDistGate and not na(gateAtr) and gateAtr > 0 and dist > gateAtr * distGateAtr

        if sameSideCount > maxInverted or tooFar
            box.delete(b)
            if not na(ce)
                line.delete(ce)
            if not na(lb)
                label.delete(lb)
            array.remove(invBoxes, i)
            array.remove(invBull, i)
            array.remove(invCE, i)
            array.remove(invLabs, i)
            continue

        box.set_right(b, bar_index)
        if not na(ce)
            line.set_x2(ce, bar_index)
        if not na(lb)
            label.set_x(lb, bar_index)

// ============================== ALERTS =============================================
alertcondition(sweptHigh,        "Buyside Sweep",         "Buyside liquidity swept on {{ticker}}")
alertcondition(sweptLow,         "Sellside Sweep",         "Sellside liquidity swept on {{ticker}}")
alertcondition(bullInvertedNow,  "Bullish IFVG Confirmed", "Bullish IFVG confirmed on {{ticker}}")
alertcondition(bearInvertedNow,  "Bearish IFVG Confirmed", "Bearish IFVG confirmed on {{ticker}}")
````
