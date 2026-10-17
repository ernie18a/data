# Nwog - Ndog Tracker (M1D)

- url: https://www.tradingview.com/script/ptV4M332-Nwog-Ndog-Tracker-M1D/
- type: indicator
- pine_id: PUB;6a6aad9260154333b72eb8d1e311a926
- version: 3.0

## Description

[b]NWOG - NDOG Tracker (M1D) [/b]
Maps the two electronic-session opening gaps on index futures and tracks how much of each one price has traded back through.

A New Day Opening Gap is the distance between the prior session's 17:00 close and the 18:00 Globex reopen — the CME maintenance halt. A New Week Opening Gap is the distance between Friday's 16:59 close and the Sunday 18:00 reopen. These are electronic-session boundaries and are deliberately not the 09:30 cash open or the 16:14 regular-hours close, which belong to a different gap entirely.

[b]How It Is Built-[/b]

No bar prints inside either window, so the bar immediately preceding a reopen always carries the true prior close. Both gaps read their origin from that bar rather than from a bar found by its clock time, which is what keeps them correct through a holiday or an early close — on those days the scheduled closing bar never prints at all, and a tool that waits for it builds the gap off a stale price.

A gap is read from the side its reopen landed on. Opening above the prior close leaves the unfilled area below price, where it stands as support. Opening below leaves it overhead as resistance.

Every boundary is detected on the bar that contains its target time rather than by comparing bar-open times, so each one resolves correctly on any intraday timeframe. All detection runs on confirmed bars only.

[b]What It Draws-[/b]

Each gap is a box spanning from its origin to its right edge, captioned with its direction, type and date. The caption sits level with the consequent encroachment just past the right edge, and holds the same visual distance from the box at any zoom.

Direction and type are carried separately so neither has to be inferred from the other. The box fill stays keyed to the type, daily and weekly each keeping their own wash, while the border and the caption arrow carry the polarity.

Levels inside a gap are optional. Quadrants draw 0.25, the consequent encroachment and 0.75. Octants draw eighths. Each level's value is printed beside the right end of its own line, level with it at any zoom, and the consequent encroachment is named CE and carries its own colour. The gap high and low are the box itself and are not redrawn as levels.

A table lists the tracked gaps newest first, each with its direction and the percentage of it that price has covered, and a count of how many remain unfilled. The callout arrow in the example chart points from a gap to this table so the two can be matched up at a glance.

https://www.tradingview.com/x/D4giS99V/ 

[b]Settings-[/b]

Gap times, session close, and the reopen times are each adjustable and independent of one another.

Extend controls how far a box runs. Until next gap keeps only the newest box tracking price, clipping the previous one as a new gap forms. Extend to price runs every kept box to the current bar. End of day stops each at the session close. The weekly gap adds End of week, which stops it at Friday's close and keeps it visible for a set number of weeks afterwards.

Direction colouring can be switched off, in which case every border and caption falls back to the single border colour. The two direction colours themselves are adjustable.

Keep-last counts, fill and border colours, label size, and the table position and length are all adjustable.

[b]Notes-[/b]

Fill percentage is the share of a gap's own range that price has covered, measured between the deepest and shallowest points reached inside it. It only increases, and reaches 100 percent once price has covered the gap end to end. It is deliberately direction-agnostic: it records how much of the gap has been consumed, not which side consumed it.

Being traded through does not remove a gap. A filled gap stays on the chart, and only the keep-last count clears it.

[b]Disclaimer-[/b]
This script reports where these gaps sit and how much of each has been consumed. It does not generate signals and it is not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
// M1D — NDOG / NWOG
// ----------------------------------------------------------------------------
// Opening-gap mapper. Draws the New Day and New Week Opening Gaps, subdivides
// each into quadrant or octant levels when enabled, and tracks how much of every
// gap price has traded back through.
//
// GAP BOUNDARIES (New York time, each on its own inputs):
//   NDOG — prior session 17:00 ETH close -> 18:00 Globex reopen, same day.
//          CME halts 17:00-18:00, so no bar prints inside the gap and the bar
//          immediately before the reopen carries the closing price.
//   NWOG — Friday 16:59 close -> Sunday 18:00 Globex reopen. 16:59 is the final
//          minute of the Friday session, so its close is the last traded price
//          before the weekend. That price is held over the weekend and the gap
//          is built on the Sunday reopen.
//
// The 09:30 cash open opens neither gap; a 16:14 RTH close belongs to the RTH
// opening gap, which is a separate instrument and not drawn here.
//
// POLARITY. A gap is read from the side the reopen landed on. Opening ABOVE the
// prior close leaves the unfilled area BELOW price, where it stands as support —
// a bullish gap. Opening below leaves it overhead as resistance — a bearish one.
// The fill colour stays keyed to the gap type so daily and weekly are never
// confused; polarity is carried on the border, the caption arrow and the table.
//
// FILL PERCENTAGE. A gap's fill is the share of its own range that price has
// traded through, measured as the span between the deepest and shallowest points
// reached inside the gap. It only ever increases, and reaches 100% once price has
// covered the gap end to end. Fill is deliberately direction-agnostic: it records
// how much of the gap has been consumed, not which side consumed it.
//
// The caption can be parked anywhere around the box — left of the zone at the
// gap's origin (the default), riding the trailing right edge, or above/below
// the start. Internal levels default to dotted, so a stack of octants inside a
// narrow gap reads as a grid at any zoom, never as a solid block - a Level
// style input offers solid and dashed for anyone who accepts that trade. A
// "CE only" levels mode draws just the consequent encroachment.
//
// EVENT HORIZON. The equilibrium of the untraded space BETWEEN two consecutive
// gaps of the same family - not a level inside either one, which is the CE above.
// Take the two FACING edges (the lower edge of the upper gap, the upper edge of
// the lower gap) and halve the distance. It exists only while BOTH gaps are on
// the chart and is erased the moment either is retired: an Event Horizon with no
// pair of gaps behind it is a line with nothing to say. Two gaps that OVERLAP
// enclose no space and get none at all. Drawn from the newer gap's origin, the
// first bar on which it could be known, and named at its LEFT end so it never
// contests the right edge the captions and level labels already share.
//
// Pairs are taken WITHIN a family - NDOG to NDOG, NWOG to NWOG - which is the
// arrangement the concept is described in and keeps the count bounded by each
// family's own retention. Cross-family horizons are a deliberate omission, not
// an oversight; see the research note beside this script.
//
// Every boundary is detected on the bar that contains its target time, so it lands
// correctly on any intraday timeframe. Detection runs on confirmed bars only.
// ============================================================================
indicator("NWOG - NDOG Tracker (M1D)", "M1D Gaps", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == CONSTANTS ===============================================================

//@variable Build stamp - bump on every edit (internal record only)
const string BUILD = "b5"
//@variable Exchange-independent New York clock used by every time function
const string TZ = "America/New_York"
//@variable Milliseconds in one calendar day
const int MS_PER_DAY = 86400000
//@variable Leading spaces that hold a right-edge caption clear of the CE value beside it. Monospace,
//          so this spacing is measured in characters and stays constant on every timeframe and zoom.
//          Only applied when the caption rides the right edge - other placements have nothing beside them.
const string CAPTION_INDENT = "     "

// == INPUTS — GAP TIMES ======================================================

int ndogOpenHr    = input.int(18, "NDOG reopen — hour",        minval = 0, maxval = 23, group = "Gap Times", inline = "ndO", tooltip = "Globex reopen that closes the daily gap. The prior session's close is read from the bar before it.")
int ndogOpenMn    = input.int(0,  "min",                       minval = 0, maxval = 59, group = "Gap Times", inline = "ndO")
int nwogOpenHr    = input.int(18, "NWOG Sunday reopen — hour", minval = 0, maxval = 23, group = "Gap Times", inline = "nwO")
int nwogOpenMn    = input.int(0,  "min",                       minval = 0, maxval = 59, group = "Gap Times", inline = "nwO")
int sessCloseHr   = input.int(16, "Session close — hour",      minval = 0, maxval = 23, group = "Gap Times", inline = "sC", tooltip = "The final minute of the trading session, 16:59 by default. Three jobs: it opens the weekly gap on a Friday, it is the end-of-day stop for daily gaps, and it is the end-of-week stop for weekly ones.")
int sessCloseMn   = input.int(59, "min",                       minval = 0, maxval = 59, group = "Gap Times", inline = "sC")

// == INPUTS — NDOG ===========================================================

bool   showNdog    = input.bool(true, "Show NDOG", group = "NDOG")
int    ndogKeep    = input.int(5, "Keep last", minval = 1, maxval = 20, group = "NDOG")
string ndogExtend  = input.string("Until next gap", "Extend", options = ["Until next gap", "Extend to price", "End of day"], group = "NDOG", tooltip = "Until next gap: only the newest box tracks live price — the one before it is clipped the moment a new gap forms, so they never stack. Extend to price: every kept box tracks live price at once. End of day: each stops at the session close of the day it opened into. Being traded through never removes a gap; only the keep-last count clears it.")
int    ndogMaxDays = input.int(5, "Stop extending after (days)", minval = 1, maxval = 30, group = "NDOG", tooltip = "Applies to Extend to price only — a cap so a box cannot run forever. The gap stays visible after it stops.")
color  ndogColor   = input.color(color.new(#1E90FF, 90), "Fill", group = "NDOG")

// == INPUTS — NWOG ===========================================================

bool   showNwog      = input.bool(true, "Show NWOG", group = "NWOG")
int    nwogKeep      = input.int(3, "Keep last", minval = 1, maxval = 20, group = "NWOG")
string nwogExtend    = input.string("End of week", "Extend", options = ["End of week", "Until next gap", "Extend to price", "End of day"], group = "NWOG", tooltip = "End of week: the box stops at Friday's session close. Until next gap: it runs until the following week's gap forms. Extend to price: it keeps tracking live price and never stops. End of day: it stops at the first session close after it opened.")
int    nwogKeepWeeks = input.int(2, "Weeks kept after it stops", minval = 1, maxval = 12, group = "NWOG", tooltip = "How long a stopped weekly gap stays visible. Ignored while it is still extending.")
color  nwogColor     = input.color(color.new(#CC0000, 90), "Fill", group = "NWOG")

// == INPUTS — GAP LEVELS =====================================================

string fibMode    = input.string("Off", "Levels", options = ["Off", "CE only", "Quadrants", "Octants"], group = "Gap Levels", tooltip = "CE only: just the consequent encroachment, the 50% of the gap. Quadrants: 0.25 / CE / 0.75. Octants: eighths, CE included. The gap high and low are the box itself, so they are not redrawn as levels.")
bool   showFibLbl = input.bool(true, "Level labels", group = "Gap Levels", tooltip = "Prints each level's value beside the right end of its line. The consequent encroachment is named CE.")
string fibStyleIn = input.string("Dotted", "Level style", options = ["Dotted", "Solid", "Dashed"], group = "Gap Levels", tooltip = "Style of the quadrant/octant lines. Dotted is the default because it cannot produce the dark-block artifact: solid internal lines stacked inside a narrow gap merge into one dark slab once the zoom compresses that gap to a few pixels of screen. Pick Solid for the old look if you accept that.")
string ceStyleIn  = input.string("Solid", "CE style", options = ["Solid", "Dotted", "Dashed"], group = "Gap Levels", tooltip = "The consequent encroachment gets its own style so the 50% reads senior to the levels around it. One solid line cannot stack into a dark block, so solid is safe here even when the outer levels stay dotted.")
color  fibColor   = input.color(color.new(#000000, 55), "Level colour", group = "Gap Levels")
color  ceColor    = input.color(color.new(#000000, 0),  "CE colour", group = "Gap Levels", tooltip = "Consequent encroachment — the 50% of the gap.")

// == INPUTS — EVENT HORIZON ==================================================

bool   showEh    = input.bool(true, "Show Event Horizon", group = "Event Horizon", tooltip = "The 50% of the space BETWEEN two consecutive gaps of the same family, measured from the lower edge of the upper gap to the upper edge of the lower one. Needs two gaps of that family on the chart, so raise the retention inputs above if nothing draws. Gaps that overlap enclose no space and get no Event Horizon.")
string ehStyleIn = input.string("Dotted", "Line style", options = ["Dotted", "Dashed"], group = "Event Horizon", inline = "ehLine")
int    ehWidth   = input.int(1, "width", minval = 1, maxval = 3, group = "Event Horizon", inline = "ehLine")
color  ehBullCol = input.color(color.new(#1a16ff, 0), "Stepping up", group = "Event Horizon", inline = "ehCol", tooltip = "Follows the same direction scheme as the gap borders: the NEWER gap sitting ABOVE the older one reads as delivery stepping up. Below is stepping down.")
color  ehBearCol = input.color(color.new(#ee0000, 0), "Stepping down", group = "Event Horizon", inline = "ehCol")
bool   showEhLbl = input.bool(true, "Label the Event Horizon", group = "Event Horizon", tooltip = "A short E.H tag at the LEFT end of the line, with the family it belongs to. Left, because the right edge already carries the trailing captions and the level values.")

// == INPUTS — VISUALS ========================================================

color  borderColor = input.color(color.new(#000000, 0), "Border colour", group = "Visuals", tooltip = "Used for every box border and caption when direction colouring below is off.")
bool   tintByDir   = input.bool(true, "Colour by direction", group = "Visuals", tooltip = "On: a gap that opened up is outlined and captioned in the bullish colour, one that opened down in the bearish colour. The fill is left keyed to the gap type — daily and weekly keep their own wash — so polarity and type read independently of each other. Off: both use the single border colour above.")
color  bullColor   = input.color(color.new(#1a16ff, 40), "Gapped up", group = "Visuals", inline = "dir")
color  bearColor   = input.color(color.new(#ee0000, 40), "Gapped down", group = "Visuals", inline = "dir")
string labelSizeIn = input.string("small", "Label size", options = ["tiny", "small", "normal"], group = "Visuals")
string capPosIn    = input.string("Left — middle", "Caption placement", options = ["Left — top", "Left — middle", "Left — bottom", "Right — top", "Right — middle", "Right — bottom", "Above — start", "Below — start"], group = "Visuals", tooltip = "Where the gap's name sits around its box. Left placements anchor at the START of the gap, where it formed, with the text just left of the zone. Right placements ride the box's moving right edge. Above and Below sit clear of the box over/under its start. Top, middle and bottom are the box top, the CE height and the box bottom.")
int    labelPad    = input.int(0, "Extra label gap (bars)", minval = 0, maxval = 50, group = "Visuals", tooltip = "Leave at 0. Labels already clear the box by a fixed pixel distance that holds on every timeframe. This adds further separation measured in bars, which is half a day on a 4H chart and a few minutes on a 1M one, so raising it will throw the spacing out on higher timeframes.")
bool   showSize    = input.bool(false, "Append gap size in points", group = "Visuals", tooltip = "Off: the caption is just the gap name and its date.")

// == INPUTS — TABLE ==========================================================

bool   showTable    = input.bool(true, "Show table", group = "Table")
string tablePosIn   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = "Table")
int    tableMaxRows = input.int(6, "Gaps listed", minval = 1, maxval = 20, group = "Table", tooltip = "Newest first, weekly gaps before daily ones.")
color  headerFill   = input.color(color.rgb(178, 63, 255), "Header fill", group = "Table")
color  headerText   = input.color(color.white, "Header text", group = "Table")
color  bodyFillA    = input.color(color.white, "Body fill A", group = "Table")
color  bodyFillB    = input.color(#F2F2F2, "Body fill B", group = "Table")
color  bodyText     = input.color(color.rgb(0, 0, 0), "Body text", group = "Table")
color  filledColor  = input.color(color.new(#00723f, 0), "Fully filled text", group = "Table")

//@variable True when the caption rides the box's trailing right edge and must move with it
bool capTrails = str.startswith(capPosIn, "Right")
//@variable Resolved line style for the quadrant/octant levels
string fibStyle = fibStyleIn == "Solid" ? line.style_solid : fibStyleIn == "Dashed" ? line.style_dashed : line.style_dotted
//@variable Resolved line style for the consequent encroachment
string ceStyle = ceStyleIn == "Dotted" ? line.style_dotted : ceStyleIn == "Dashed" ? line.style_dashed : line.style_solid

// == TYPES ===================================================================

//@type One opening gap with every drawing it owns, so they are retired together
type Gap
    string       name       = ""
    string       dateTxt    = ""
    bool         bullish    = false
    float        top        = na
    float        bottom     = na
    int          originBar  = 0
    int          builtTime  = 0
    float        touchedHi  = na
    float        touchedLo  = na
    bool         frozen     = false
    int          freezeTime = 0
    box          zone       = na
    label        tag        = na
    array<line>  levelLines = na
    array<label> levelTags  = na

//@type The result of measuring between two gaps. A UDT rather than a tuple on
//      purpose: this is read inside a for loop and inside an if, and a tuple
//      destructured in a local scope is a compile risk the linter cannot see.
type EhReading
    float price = na
    bool  up    = false
    bool  valid = false

//@type One Event Horizon and the two drawings it owns, retired together
type EventHorizon
    line  ray = na
    label tag = na

// == HELPER FUNCTIONS ========================================================

//@function Resolves the label-size input string to a Pine size constant
//@param sizeName (string) One of "tiny", "small", "normal"
//@returns (string) Matching size.* constant
resolveSize(string sizeName) => switch sizeName
    "tiny"   => size.tiny
    "normal" => size.normal
    =>          size.small

//@function Resolves the table-position input string to a Pine position constant
//@param posName (string) Human-readable corner name
//@returns (string) Matching position.* constant
resolvePosition(string posName) => switch posName
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    "Middle Left"   => position.middle_left
    =>                 position.top_right

//@function Zero-pads a date component to two digits
//@param value (int) Day or month
//@returns (string) Two-character string
pad2(int value) => (value < 10 ? "0" : "") + str.tostring(value)

//@function Resolves the colour a gap's polarity is drawn in
//@param isBull (bool) True when the reopen landed above the prior close
//@returns (color) Direction colour, or the plain border colour when direction colouring is off
dirInk(bool isBull) => tintByDir ? (isBull ? bullColor : bearColor) : borderColor

//@function Tests whether a New York wall-clock time falls INSIDE the current bar's span
//@param hourValue   (int) Target hour, 0-23
//@param minuteValue (int) Target minute, 0-59
//@returns (bool) True on the single bar containing the target time; false on daily and above
isTimeInBar(int hourValue, int minuteValue) =>
    int barMinutes = math.max(math.round(timeframe.in_seconds() / 60), 1)
    bool hit = false
    if barMinutes < 1440
        int target  = hourValue * 60 + minuteValue
        int barOpen = hour(time, TZ) * 60 + minute(time, TZ)
        hit := barOpen <= target and (barOpen + barMinutes) > target
    hit

//@function Returns the fractional levels drawn inside a gap for the selected mode
//@param mode (string) "Off", "Quadrants" or "Octants"
//@returns (array<float>) Fractions between 0 and 1, empty when levels are off
levelSet(string mode) =>
    array<float> levels = switch mode
        "CE only"   => array.from(0.5)
        "Quadrants" => array.from(0.25, 0.5, 0.75)
        "Octants"   => array.from(0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875)
        =>             array.new<float>(0)
    levels

//@function Share of a gap's range that price has traded through
//@param target (Gap) Gap to measure
//@returns (float) 0 to 100
gapFillPct(Gap target) =>
    float span = target.top - target.bottom
    float pct = na(target.touchedHi) or na(target.touchedLo) or span <= 0 ? 0.0 : (target.touchedHi - target.touchedLo) / span * 100.0
    math.min(pct, 100.0)

//@function Widens a gap's traded-through span using the current bar's range
//@param target (Gap) Gap to update
//@returns (bool) Always true
markFill(Gap target) =>
    float lowIn  = math.max(low, target.bottom)
    float highIn = math.min(high, target.top)
    if highIn >= lowIn
        target.touchedLo := na(target.touchedLo) ? lowIn : math.min(target.touchedLo, lowIn)
        target.touchedHi := na(target.touchedHi) ? highIn : math.max(target.touchedHi, highIn)
    true

//@function Deletes every drawing a gap owns
//@param target (Gap) Gap to erase
//@returns (bool) Always true
eraseGap(Gap target) =>
    box.delete(target.zone)
    label.delete(target.tag)
    if not na(target.levelLines)
        while target.levelLines.size() > 0
            line.delete(target.levelLines.shift())
    if not na(target.levelTags)
        while target.levelTags.size() > 0
            label.delete(target.levelTags.shift())
    true

//@function Stops every gap already in a store from extending, so only the incoming one stays live
//@param store   (array<Gap>) Store to freeze
//@param nowTime (int)        Current bar timestamp
//@returns (bool) Always true
freezeStore(array<Gap> store, int nowTime) =>
    if store.size() > 0
        for i = 0 to store.size() - 1
            Gap current = store.get(i)
            if not current.frozen
                current.frozen := true
                current.freezeTime := nowTime
    true

//@function The Event Horizon between two consecutive gaps, if they leave a space at all.
//          Measured between the two FACING edges, so it is the equilibrium of the untraded
//          ground between the pair and never a level inside either gap.
//@param older (Gap) The earlier gap of the pair
//@param newer (Gap) The later gap of the pair
//@returns (EhReading) price, whether the newer gap sits above the older, and whether one exists
ehBetween(Gap older, Gap newer) =>
    EhReading out = EhReading.new()
    if newer.bottom > older.top
        out.price := (older.top + newer.bottom) / 2.0
        out.up    := true
        out.valid := true
    else if older.bottom > newer.top
        out.price := (newer.top + older.bottom) / 2.0
        out.up    := false
        out.valid := true
    // Anything else means the gaps overlap. Overlapping gaps enclose no space,
    // so there is no equilibrium between them to draw.
    out

//@function Deletes every Event Horizon drawing and empties the store
//@param store (array<EventHorizon>) Store to clear
//@returns (bool) Always true
eraseHorizons(array<EventHorizon> store) =>
    if store.size() > 0
        for i = 0 to store.size() - 1
            EventHorizon eh = store.get(i)
            line.delete(eh.ray)
            label.delete(eh.tag)
        store.clear()
    true

//@function Rebuilds one family's Event Horizons from its gap store.
//          Rebuilt wholesale rather than patched, because retiring a gap changes which
//          pairs are consecutive - and a store never holds more than a handful of gaps, so
//          the cheap correct thing beats the clever one. This is also what guarantees an
//          Event Horizon cannot outlive either gap that defines it.
//@param gaps     (array<Gap>)          One family's gap store, oldest first
//@param store    (array<EventHorizon>) That family's Event Horizon store
//@param famName  (string)              "NDOG" or "NWOG", printed in the tag
//@param style    (string)              Resolved line.style_* constant
//@param textSize (string)              Resolved size.* constant
//@returns (bool) Always true
rebuildHorizons(array<Gap> gaps, array<EventHorizon> store, string famName, string style, string textSize) =>
    eraseHorizons(store)
    if showEh and gaps.size() > 1
        for i = 0 to gaps.size() - 2
            Gap older = gaps.get(i)
            Gap newer = gaps.get(i + 1)
            EhReading reading = ehBetween(older, newer)
            if reading.valid
                float ehPrice = reading.price
                color ehCol   = reading.up ? ehBullCol : ehBearCol
                EventHorizon made = EventHorizon.new()
                // Begins at the newer gap's origin - the first bar on which both gaps
                // existed and the level could therefore be known. bar_index, matching
                // every other drawing in this script.
                made.ray := line.new(newer.originBar, ehPrice, bar_index, ehPrice, color = ehCol, width = ehWidth, style = style, xloc = xloc.bar_index)
                if showEhLbl
                    // style_label_right puts the pointer on the RIGHT of the text, so the
                    // tag sits to the LEFT of its anchor - clear of the right edge, which
                    // the trailing captions and the level values already share.
                    made.tag := label.new(newer.originBar, ehPrice, "E.H " + famName, style = label.style_label_right, color = color.new(color.white, 100), textcolor = ehCol, size = textSize, textalign = text.align_right, xloc = xloc.bar_index)
                    label.set_text_font_family(made.tag, font.family_monospace)
                store.push(made)
    true

//@function Trims a gap store from the oldest end
//@param store    (array<Gap>) Store to prune
//@param maxCount (int)        Maximum retained gaps
//@returns (bool) Always true
pruneGaps(array<Gap> store, int maxCount) =>
    while store.size() > maxCount
        eraseGap(store.shift())
    true

//@function Advances a gap's right edge and carries its caption along with it
//@param target (Gap) Gap to extend
//@param rightX (int) Bar index to extend to
//@param pad    (int) Bars past the edge the caption sits
//@returns (bool) Always true
extendGap(Gap target, int rightX, int pad) =>
    box.set_right(target.zone, rightX)
    if not na(target.levelLines) and target.levelLines.size() > 0
        for i = 0 to target.levelLines.size() - 1
            line.set_x2(target.levelLines.get(i), rightX)
    if not na(target.levelTags) and target.levelTags.size() > 0
        for i = 0 to target.levelTags.size() - 1
            label.set_x(target.levelTags.get(i), rightX + pad)
    // Only a right-edge caption rides the box; every other placement stays parked
    // at the gap's origin, which is the whole point of anchoring it there.
    if capTrails
        label.set_x(target.tag, rightX + pad)
    true

//@function Builds a gap, its box, its caption and its internal levels
//@param topPrice  (float)  Upper gap price
//@param botPrice  (float)  Lower gap price
//@param originBar (int)    Bar index of the close that opened the gap
//@param fillColor (color)  Box fill, keyed to the gap TYPE so daily and weekly stay distinguishable
//@param gapName   (string) ICT label text, "NDOG" or "NWOG"
//@param textSize  (string) Resolved size.* constant
//@param isBull    (bool)   True when the reopen landed above the prior close
//@returns (Gap) The constructed gap
buildGap(float topPrice, float botPrice, int originBar, color fillColor, string gapName, string textSize, bool isBull) =>
    string stamp = pad2(dayofmonth(time, TZ)) + "/" + pad2(month(time, TZ))
    Gap created = Gap.new(name = gapName, dateTxt = stamp, bullish = isBull, top = topPrice, bottom = botPrice, originBar = originBar, builtTime = time)
    created.levelLines := array.new<line>(0)
    created.levelTags := array.new<label>(0)

    // Polarity rides the border and the caption; the fill is left to carry the gap type.
    color inkColor = dirInk(isBull)
    created.zone := box.new(originBar, topPrice, bar_index, botPrice, border_color = inkColor, border_width = 1, border_style = line.style_solid, bgcolor = fillColor, xloc = xloc.bar_index)

    // The caption sits where the placement input says. LEFT placements anchor at
    // the START of the gap with the text just left of the zone - the default, so
    // the name marks where the gap formed and never crowds the live edge. RIGHT
    // placements ride the trailing edge as the box extends. Above and Below sit
    // clear of the box at its start. Callout styles keep the whole text body OFF
    // the box, and the transparent background means only the text prints.
    // The indent exists only to clear the CE value labels that share the right
    // edge - so it applies only when the caption rides that edge AND level labels
    // are actually printed there. Everywhere else the name sits tight to its box.
    string caption  = (capTrails and showFibLbl and fibMode != "Off" ? CAPTION_INDENT : "") + (isBull ? "▲ " : "▼ ") + gapName + "  " + stamp + (showSize ? "  " + str.tostring(topPrice - botPrice, "#.##") + " pts" : "")
    string capStyle = capTrails ? label.style_label_left : str.startswith(capPosIn, "Left") ? label.style_label_right : capPosIn == "Above — start" ? label.style_label_down : label.style_label_up
    float  capY     = str.endswith(capPosIn, "top") or capPosIn == "Above — start" ? topPrice : str.endswith(capPosIn, "bottom") or capPosIn == "Below — start" ? botPrice : (topPrice + botPrice) / 2.0
    int    capX     = capTrails ? bar_index + labelPad : originBar - (str.startswith(capPosIn, "Left") ? labelPad : 0)
    created.tag := label.new(capX, capY, caption, style = capStyle, color = color.new(color.white, 100), textcolor = inkColor, size = textSize, textalign = text.align_left, xloc = xloc.bar_index)
    label.set_text_font_family(created.tag, font.family_monospace)

    array<float> levels = levelSet(fibMode)
    if levels.size() > 0
        float span = topPrice - botPrice
        for i = 0 to levels.size() - 1
            float fraction = levels.get(i)
            bool  isCe     = fraction == 0.5
            float price    = botPrice + span * fraction
            // The CE carries its own style so the 50% reads senior - solid by
            // default. The outer levels default to dotted: solid lines stacked
            // inside a narrow gap merge into one dark block once the zoom
            // compresses the gap to a few pixels; dotted reads as a grid anywhere.
            line levelLine = line.new(originBar, price, bar_index, price, color = isCe ? ceColor : fibColor, width = 1, style = isCe ? ceStyle : fibStyle, xloc = xloc.bar_index)
            created.levelLines.push(levelLine)
            if showFibLbl
                // A left-pointing callout centres its body vertically on the anchor,
                // so the text sits perfectly level with its own line, and places that
                // body to the right of the line's end. Its background is transparent.
                label levelTag = label.new(bar_index + labelPad, price, isCe ? "CE" : str.tostring(fraction), style = label.style_label_left, color = color.new(color.white, 100), textcolor = isCe ? ceColor : fibColor, size = size.tiny, textalign = text.align_left, xloc = xloc.bar_index)
                label.set_text_font_family(levelTag, font.family_monospace)
                created.levelTags.push(levelTag)
    created

//@function Extends daily gaps and tracks their fill. A box stops on the selected extend mode or the
//          age cap, and is removed only by the keep-last count; fill state affects neither.
//@param store   (array<Gap>) Daily gap store
//@param maxDays (int)        Maximum extension in calendar days
//@param nowTime (int)        Current bar timestamp
//@param pad     (int)        Caption offset past the right edge
//@param stopNow (bool)       True on the bar the selected extend mode cuts the box off
//@returns (bool) Always true
updateDayGaps(array<Gap> store, int maxDays, int nowTime, int pad, bool stopNow) =>
    if store.size() > 0
        for i = store.size() - 1 to 0
            Gap current = store.get(i)
            markFill(current)
            if not current.frozen
                extendGap(current, bar_index, pad)
                if stopNow or nowTime - current.builtTime > maxDays * MS_PER_DAY
                    current.frozen := true
                    current.freezeTime := nowTime
    true

//@function Extends weekly gaps to live price, stops them when the selected mode says so and retires them after the retention window
//@param store     (array<Gap>) Weekly gap store
//@param stopNow   (bool)       True on the bar the selected extend mode cuts the box off
//@param keepWeeks (int)        Weeks a stopped gap stays visible
//@param nowTime   (int)        Current bar timestamp
//@param pad       (int)        Caption offset past the right edge
//@returns (bool) Always true
updateWeekGaps(array<Gap> store, bool stopNow, int keepWeeks, int nowTime, int pad) =>
    if store.size() > 0
        for i = store.size() - 1 to 0
            Gap current = store.get(i)
            markFill(current)
            if not current.frozen
                extendGap(current, bar_index, pad)
                if stopNow
                    current.frozen := true
                    current.freezeTime := nowTime
            else if nowTime - current.freezeTime > keepWeeks * 7 * MS_PER_DAY
                eraseGap(current)
                store.remove(i)
    true

// == CLOCK ===================================================================

string labelSize = resolveSize(labelSizeIn)

//@variable New York day-of-week for the current bar
int nyDow = dayofweek(time, TZ)
//@variable True on the bar containing the daily Globex reopen
bool atNdogOpen = isTimeInBar(ndogOpenHr, ndogOpenMn)
//@variable True on the bar containing the Sunday Globex reopen
bool atNwogOpen = isTimeInBar(nwogOpenHr, nwogOpenMn)
//@variable True on the bar containing the daily session close
bool atSessionClose = isTimeInBar(sessCloseHr, sessCloseMn)
//@variable True on the bar containing the Friday close that opens the weekly gap
bool atWeekClose = atSessionClose and nyDow == dayofweek.friday
//@variable True on the bar the daily gaps' selected extend mode cuts them off
bool ndogStop = ndogExtend == "End of day" and atSessionClose
//@variable True on the bar the weekly gaps' selected extend mode cuts them off
bool nwogStop = nwogExtend == "End of week" ? atWeekClose : nwogExtend == "End of day" ? atSessionClose : false

// == STATE ===================================================================

var array<Gap> ndogStore = array.new<Gap>(0)
var array<Gap> nwogStore = array.new<Gap>(0)

var array<EventHorizon> ndogEh = array.new<EventHorizon>(0)
var array<EventHorizon> nwogEh = array.new<EventHorizon>(0)

//@variable Resolved line style for every Event Horizon
string ehStyle = ehStyleIn == "Dashed" ? line.style_dashed : line.style_dotted

//@variable Last seen size and newest-gap stamp per family, so the horizons rebuild on a real change only
var int ndogSeen = -1
var int nwogSeen = -1
var int ndogNewest = 0
var int nwogNewest = 0

// == DETECTION (confirmed bars only) =========================================

if barstate.isconfirmed

    // NWOG — the last traded price before the weekend to Sunday's reopen. The bar
    // immediately preceding the reopen always carries that price, whatever time
    // the Friday session actually ended, so a holiday or shortened session cannot
    // leave a stale close behind.
    if showNwog and atNwogOpen and nyDow == dayofweek.sunday and not na(close[1]) and close[1] != open
        if nwogExtend == "Until next gap"
            freezeStore(nwogStore, time)
        nwogStore.push(buildGap(math.max(close[1], open), math.min(close[1], open), bar_index - 1, nwogColor, "NWOG", labelSize, open > close[1]))
        pruneGaps(nwogStore, nwogKeep)

    // NDOG — the prior session's close to the same day's reopen. Nothing prints
    // through the maintenance halt, so the preceding bar holds that close.
    if showNdog and atNdogOpen and nyDow != dayofweek.sunday and not na(close[1]) and close[1] != open
        if ndogExtend == "Until next gap"
            freezeStore(ndogStore, time)
        ndogStore.push(buildGap(math.max(close[1], open), math.min(close[1], open), bar_index - 1, ndogColor, "NDOG", labelSize, open > close[1]))
        pruneGaps(ndogStore, ndogKeep)

    updateDayGaps(ndogStore, ndogMaxDays, time, labelPad, ndogStop)
    updateWeekGaps(nwogStore, nwogStop, nwogKeepWeeks, time, labelPad)

    // Rebuilt only when a store's CONTENTS changed - a gap arriving, or a retention
    // window retiring one without a new one arriving. Rebuilding unconditionally
    // here would delete and recreate every drawing on every confirmed bar, which is
    // pure churn against the 500-object ceiling. Watching the size catches both
    // causes, because every push and every retirement moves it.
    //
    // The identity of the NEWEST gap is watched too: at a steady retention ceiling
    // a push and a prune land on the same bar and the size never moves, so size
    // alone would miss exactly the case a new gap creates a new pair.
    if ndogStore.size() != ndogSeen or (ndogStore.size() > 0 and ndogStore.get(ndogStore.size() - 1).builtTime != ndogNewest)
        ndogSeen := ndogStore.size()
        ndogNewest := ndogStore.size() > 0 ? ndogStore.get(ndogStore.size() - 1).builtTime : 0
        rebuildHorizons(ndogStore, ndogEh, "NDOG", ehStyle, labelSize)
    if nwogStore.size() != nwogSeen or (nwogStore.size() > 0 and nwogStore.get(nwogStore.size() - 1).builtTime != nwogNewest)
        nwogSeen := nwogStore.size()
        nwogNewest := nwogStore.size() > 0 ? nwogStore.get(nwogStore.size() - 1).builtTime : 0
        rebuildHorizons(nwogStore, nwogEh, "NWOG", ehStyle, labelSize)

// The Event Horizon lines follow the live edge. Their tags do NOT move - each is
// anchored at the newer gap's origin bar, which is fixed, so there is nothing to
// re-park.
if barstate.islast
    if ndogEh.size() > 0
        for i = 0 to ndogEh.size() - 1
            line.set_x2(ndogEh.get(i).ray, bar_index)
    if nwogEh.size() > 0
        for i = 0 to nwogEh.size() - 1
            line.set_x2(nwogEh.get(i).ray, bar_index)

// == TABLE ===================================================================
// Weekly gaps first, then daily, each newest first. "Open" counts every gap that
// is not yet fully filled.

var table gapTable = table.new(resolvePosition(tablePosIn), 2, tableMaxRows + 2, border_width = 1, border_color = color.new(#000000, 0), frame_width = 1, frame_color = color.new(#000000, 0))

if showTable and barstate.islast
    int totalGaps = nwogStore.size() + ndogStore.size()
    int openGaps = 0
    if nwogStore.size() > 0
        for i = 0 to nwogStore.size() - 1
            if gapFillPct(nwogStore.get(i)) < 100.0
                openGaps := openGaps + 1
    if ndogStore.size() > 0
        for i = 0 to ndogStore.size() - 1
            if gapFillPct(ndogStore.get(i)) < 100.0
                openGaps := openGaps + 1

    table.clear(gapTable, 0, 0, 1, tableMaxRows + 1)

    table.cell(gapTable, 0, 0, "M1D — Gaps", text_color = headerText, bgcolor = headerFill, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(gapTable, 1, 0, "", text_color = headerText, bgcolor = headerFill, text_size = size.small, text_font_family = font.family_monospace)

    table.cell(gapTable, 0, 1, "Open", text_color = bodyText, bgcolor = bodyFillA, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(gapTable, 1, 1, str.tostring(openGaps) + " of " + str.tostring(totalGaps), text_color = openGaps == 0 and totalGaps > 0 ? filledColor : bodyText, bgcolor = bodyFillA, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace)

    int row = 2
    if nwogStore.size() > 0
        for i = nwogStore.size() - 1 to 0
            if row < tableMaxRows + 2
                Gap g = nwogStore.get(i)
                float pct = gapFillPct(g)
                color fillTint = row % 2 == 0 ? bodyFillB : bodyFillA
                table.cell(gapTable, 0, row, (g.bullish ? "▲ " : "▼ ") + g.name + " " + g.dateTxt, text_color = tintByDir ? dirInk(g.bullish) : bodyText, bgcolor = fillTint, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
                table.cell(gapTable, 1, row, str.tostring(pct, "0") + "% filled", text_color = pct >= 100.0 ? filledColor : bodyText, bgcolor = fillTint, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace)
                row := row + 1
    if ndogStore.size() > 0
        for i = ndogStore.size() - 1 to 0
            if row < tableMaxRows + 2
                Gap g = ndogStore.get(i)
                float pct = gapFillPct(g)
                color fillTint = row % 2 == 0 ? bodyFillB : bodyFillA
                table.cell(gapTable, 0, row, (g.bullish ? "▲ " : "▼ ") + g.name + " " + g.dateTxt, text_color = tintByDir ? dirInk(g.bullish) : bodyText, bgcolor = fillTint, text_size = size.small, text_halign = text.align_left, text_font_family = font.family_monospace)
                table.cell(gapTable, 1, row, str.tostring(pct, "0") + "% filled", text_color = pct >= 100.0 ? filledColor : bodyText, bgcolor = fillTint, text_size = size.small, text_halign = text.align_right, text_font_family = font.family_monospace)
                row := row + 1

// == ALERTS (script scope) ===================================================

//@variable Consequent encroachment of the newest NDOG, na when none is drawn
float ndogCe = ndogStore.size() > 0 ? (ndogStore.get(ndogStore.size() - 1).top + ndogStore.get(ndogStore.size() - 1).bottom) / 2.0 : na
//@variable Consequent encroachment of the newest NWOG
float nwogCe = nwogStore.size() > 0 ? (nwogStore.get(nwogStore.size() - 1).top + nwogStore.get(nwogStore.size() - 1).bottom) / 2.0 : na

bool crossedNdogCe = ta.cross(close, ndogCe)
bool crossedNwogCe = ta.cross(close, nwogCe)

bool alertNdogBuilt = showNdog and atNdogOpen and barstate.isconfirmed and nyDow != dayofweek.sunday
bool alertNwogBuilt = showNwog and atNwogOpen and barstate.isconfirmed and nyDow == dayofweek.sunday
bool alertNdogCe    = not na(ndogCe) and crossedNdogCe
bool alertNwogCe    = not na(nwogCe) and crossedNwogCe

//@variable Event Horizon between each family's two newest gaps, na when there is no pair or they overlap
float ndogEhPrice = na
float nwogEhPrice = na
if ndogStore.size() > 1
    EhReading r = ehBetween(ndogStore.get(ndogStore.size() - 2), ndogStore.get(ndogStore.size() - 1))
    ndogEhPrice := r.valid ? r.price : na
if nwogStore.size() > 1
    EhReading r2 = ehBetween(nwogStore.get(nwogStore.size() - 2), nwogStore.get(nwogStore.size() - 1))
    nwogEhPrice := r2.valid ? r2.price : na

// Evaluated unconditionally, like the CE crosses above: ta.* carries bar-to-bar
// state, so skipping the call on bars with no Event Horizon would corrupt its history.
bool ndogEhCross = ta.cross(close, ndogEhPrice)
bool nwogEhCross = ta.cross(close, nwogEhPrice)
bool alertNdogEh = not na(ndogEhPrice) and ndogEhCross
bool alertNwogEh = not na(nwogEhPrice) and nwogEhCross

alertcondition(alertNdogBuilt, "NDOG formed",    "M1D: New Day Opening Gap formed on {{ticker}}")
alertcondition(alertNwogBuilt, "NWOG formed",    "M1D: New Week Opening Gap formed on {{ticker}}")
alertcondition(alertNdogCe,    "NDOG CE traded", "M1D: price crossed the NDOG consequent encroachment on {{ticker}} @ {{close}}")
alertcondition(alertNwogCe,    "NWOG CE traded", "M1D: price crossed the NWOG consequent encroachment on {{ticker}} @ {{close}}")
alertcondition(alertNdogEh,    "NDOG Event Horizon traded", "M1D: price traded the Event Horizon between the two newest NDOGs on {{ticker}} @ {{close}}")
alertcondition(alertNwogEh,    "NWOG Event Horizon traded", "M1D: price traded the Event Horizon between the two newest NWOGs on {{ticker}} @ {{close}}")
````
