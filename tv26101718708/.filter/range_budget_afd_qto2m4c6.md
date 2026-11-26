# Range Budget [AFD]

- url: https://www.tradingview.com/script/qtO2M4C6-Range-Budget-AFD/
- type: indicator
- pine_id: PUB;84106cafc6864139bac99f25576b2568
- version: 1.0

## Description

[image]https://www.tradingview.com/x/EbIOZylT/[/image]

[b]Range Budget [AFD][/b] answers one question at a glance: **how much of a
typical session's range has today already used?**

A day that has spent 40% of its typical range and a day that has spent 130% are different trading environments. This indicator measures which one you are in, from this chart's own price history, and says so in one number, onecolour, and one word.

[b]###What it does###[/b]
- **Headline percentage** — today's realized range so far, divided by thetypical completed-session range. Never clamped: a wide day reads 130%, not100%.

- **State word and meter** — ROOM → PAST HALF (50%) → NEAR FULL (80%) → OVER
  TYPICAL (100%). The word, the meter and every state colour come from the same thresholds, so they cannot disagree.

- **Envelope levels** — session low + typical range, and session high − typicalrange, drawn as glowing lines with a gradient band between them. Aconditional identity, not a projection: IF the session finishes at itstypical size AND the low holds, the high lands exactly on the upper level. Once the day crosses its typical range, the levels take the state colour.

- **Percentile ladder** (optional) — where a finished day of each size (p25 /p50 / p75 / p90 of the lookback window) would top out, measured up fromtoday's low. Nearest-rank percentiles: every rung is a session range thatactually occurred, never an interpolation.

- **Dashboard** — distance left to (or past) typical in both price points andpercent, how many of the last N sessions ran wider than typical, and optional detail rows (range so far, typical range, percentile standing,widest/narrowest, envelope and ladder values). Compact by default; everycryptic cell explains itself on hover; the whole panel can be switched off.

[image]https://www.tradingview.com/x/F5KEwnej/[/image]

[b]###How it works###[/b]
- **Typical range is user-selectable**, and the chart always names the activestatistic:

  - **ADR** — the average of the last N completed session ranges (high − low).

  - **ATR RMA** — the average true range, so overnight gaps count. Seeded withthe first true range rather than an initial SMA, which is why it is labelled "ATR RMA" and will not match `ta.atr()` to the last digit. Under ATR the numerator is the live session's true range too, so the percentageis never a ratio of two different measures.

  - **Median** — the middle completed session range, which is also theladder's p50 rung.

  - The three are identical on a symbol that never gaps and diverge as gaps grow — on heavily gapping symbols ATR can run near 2.5× ADR. That is why the choice exists and why the active one is named on the chart.

- **Completed sessions only.** The live day never feeds its own denominator —a partial day would drag the typical range down as the day progressed and bias the percentage upward with no symptom. Statistics update when a session completes; the live day contributes only its running range.

- **One session rule for everything.** Regular hours or regular + extended:history and the live day follow the same rule, and if the filter cannot change anything on your chart (no extended-hours bars loaded), the dashboard says so instead of staying silent.

- **The sample is what your chart holds.** n is capped by the sessions actually loaded — roughly 64 completed regular-hours sessions on a 5-minute chart from 5,000 bars on a Basic plan, more on higher plans and higher timeframes. The dashboard shows the n actually in use, plus a spread figure ((p90 − p25) ÷ p50) that says whether recent sessions were similar in size
or mixed.

- Eleven plotted values sit in the Data Window (percentage, ranges, envelope percentiles, sample size and more), so every number on the panel can be read, checked and exported.

[b]###How to use it###[/b]
1. Add it to a liquid intraday chart. The defaults are the intended reading: compact dashboard, ADR(20), regular hours.

2. Read the headline first. ROOM means the day is still small next to its recent finished sessions; OVER TYPICAL means it has already run further than a typical one.

3. Use the envelope as context for the day's remaining room under the stated conditions — the tooltip on every input spells those conditions out.

4. Turn on the ladder to see today against the whole recent distribution instead of one average: price between p50 and p75 means today has already matched a mid-sized finished day.

5. Hover the bottom row of the dashboard whenever a figure is unclear — the statistic, the sample and any active caveat (gap counted, filter inert, no completed session yet) are explained there.

[image]https://www.tradingview.com/x/R7Acl2No/[/image]

[b]###What it deliberately does not do###[/b]
**Realized range from OHLCV — not an implied or expected move.** Every number is measured from this chart's own price history. Nothing comes from options pricing, and the typical range describes completed sessions — a description of what happened, not a statement about what happens next.

- No alerts, no signals, no entries or exits.

- Counts stay counts — "Sessions over typical: 4 of last 20" describes this chart's history, and the indicator never converts a count into odds.

- The percentage is never capped at 100%, because a day past its typical range is the most informative reading the tool produces.

[b]###Why it is original###[/b]
Range tools usually hand you one number (an ADR level pair) or one overlay (an ATR band). Range Budget treats the session range as a budget and reports its consumption: one percentage against a user-chosen, chart-named statistic, computed from completed sessions only, with its sample size, its spread and every degeneracy disclosed on the panel itself. The three statistics are not interchangeable and the tool is built around that fact rather than hiding it: the active one is named on the chart, the ATR path measures true range on both sides of the ratio, and the ladder shows the whole recent distribution so one average never has to stand in for it.

Open source under the Mozilla Public License 2.0. All calculations are native
Pine v6 — no security() calls, no external data.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry LLC

//@version=6
indicator("Range Budget [AFD]", shorttitle = "RBUD [AFD]", overlay = true)

// =============================================================================
// Constants
// =============================================================================

// The three candidate meanings of "typical range". All three ship because they
// are not interchangeable: identical on a gapless symbol and 2.47x apart where
// gaps run a full typical range every session.
const string STAT_ADR    = "Average daily range (ADR)"
const string STAT_ATR    = "Average true range (ATR)"
const string STAT_MEDIAN = "Median daily range"

// One switch, two consequences: which bars the accumulator includes AND what
// counts as the start of a session.
const string SESSION_RTH = "Regular hours only"
const string SESSION_ALL = "Regular + extended hours"

const string LINE_SOLID  = "Solid"
const string LINE_DASHED = "Dashed"
const string LINE_DOTTED = "Dotted"

// Gradient presets for the envelope band. Every preset except Custom keeps the
// state colour as its near end and chooses only the far rail; Custom hands
// both ends to the two pickers. The full colour rules live on
// gradientColorsOf() below.
const string GRAD_SIGNAL = "Signal fade"
const string GRAD_OCEAN  = "Ocean"
const string GRAD_EMBER  = "Ember"
const string GRAD_MONO   = "Mono ink"
const string GRAD_FLAT   = "Flat"
const string GRAD_CUSTOM = "Custom"

const color COLOR_GRAD_OCEAN = #1565C0
const color COLOR_GRAD_EMBER = #BF360C
const color COLOR_GRAD_MONO  = #263238

// Readout modes. Compact is the three-row core -- headline, meter, distance to
// typical. Expanded adds the context and detail rows. The disclosure row is in
// NEITHER list because it renders in both: a disclosure may never acquire an
// off switch, and a mode dropdown is an off switch with a nicer name.
const string MODE_EXPANDED = "Expanded"
const string MODE_COMPACT  = "Compact"

// One text size applies to every readout row.
const string SIZE_TINY   = "Tiny"
const string SIZE_SMALL  = "Small"
const string SIZE_NORMAL = "Normal"
const string SIZE_LARGE  = "Large"

const string GROUP_STAT   = "Statistic"
const string GROUP_VISUAL = "Display"

// The budget meter. Sixteen cells drawn from two block characters, as table
// text, so it costs no plot count.
const int    METER_CELLS = 16
const string METER_FULL  = "█"
const string METER_EMPTY = "░"

// State palette. The headline row's background IS the state colour, which is
// the whole of the read-at-a-glance design.
const color COLOR_ROOM    = #00E5FF
const color COLOR_MID     = #FFD54F
const color COLOR_NEAR    = #FF6D00
const color COLOR_SPENT   = #FF1744
const color COLOR_HUD_BG  = #0B1220
const color COLOR_HUD_TXT = #ECEFF1
const color COLOR_HUD_DIM = #90A4AE
const color COLOR_INK     = #0B1220

// The bands the state colour changes at, in percent of the typical range. The
// percentage itself is never clamped at any of them.
const float BUDGET_MID  = 50.0
const float BUDGET_NEAR = 80.0
const float BUDGET_FULL = 100.0

// Percentile ladder rungs.
const float LADDER_P25 = 25.0
const float LADDER_P50 = 50.0
const float LADDER_P75 = 75.0
const float LADDER_P90 = 90.0

// How far to the right of the last bar the level lines and their labels run.
// Well inside the platform's 500-bar forward drawing offset.
const int EXTEND_BARS = 14

// The envelope band is a STACK of fills rather than one flat fill, because
// linefill.new(line1, line2, color) takes exactly one colour -- so a gradient
// is N fills between N + 1 lines and there is no cheaper form of it. Eight
// slices: seven interior boundaries at 100 percent transparency plus the two
// envelope rails.
//
// THE DIRECTION OF THE GRADIENT IS DECORATIVE AND CARRIES NO INFORMATION. The
// band spans basisHigh - typicalRange to basisLow + typicalRange, it is centred
// on the live session, and neither rail is the one the day has "used" -- a day
// can extend from either end. Density is legibility, not a reading.
const int GRADIENT_SLICES     = 8
const int GRADIENT_ALPHA_NEAR = 62
const int GRADIENT_ALPHA_FAR  = 92
const int GRADIENT_ALPHA_FLAT = 84

// The envelope glow: halo widths in pixels and their transparencies. The halo
// is decoration only -- both halo lines sit at the same price as the core, so
// nothing about the level moves.
const int GLOW_WIDTH_WIDE = 10
const int GLOW_WIDTH_SOFT = 5
const int GLOW_ALPHA_WIDE = 84
const int GLOW_ALPHA_SOFT = 62

// The meter row's state word, one per band of budgetColor(). Words, not
// adjectives with a forecast in them: each names where the day stands against
// its typical range and infers nothing about what happens next.
const string STATE_ROOM  = "ROOM"
const string STATE_MID   = "PAST HALF"
const string STATE_NEAR  = "NEAR FULL"
const string STATE_OVER  = "OVER TYPICAL"
const string STATE_NONE  = "NO DATA"

// =============================================================================
// Inputs
// =============================================================================

// The three value inputs pass display = display.none so the chart legend shows
// only the short title, not the argument string. The value stays editable in
// the Inputs tab; bool and color inputs already default to display.none.
string statisticInput     = input.string(STAT_ADR, "Typical range statistic", options = [STAT_ADR, STAT_ATR, STAT_MEDIAN], group = GROUP_STAT, display = display.none, tooltip = "Which statistic stands for a typical session range.\n• ADR — average of completed session ranges\n• ATR RMA — average true range, seeded with the FIRST true range; not the same number as ta.atr()\n• Median — the middle completed session range\n• Identical on a symbol that never gaps; they diverge as gaps grow, so the active one is named on the chart")
int    lookbackInput      = input.int(20, "Lookback sessions", minval = 1, maxval = 500, group = GROUP_STAT, display = display.none, tooltip = "How many completed sessions feed the statistics.\n• Covers the average, the median and the ladder\n• Fewer sessions react faster but are noisier\n• If the chart holds fewer than requested, the readout shows the n actually loaded\n• Default 20: the average needs about 13 sessions to settle on a mid-dispersion symbol")
string sessionInput       = input.string(SESSION_RTH, "Session", options = [SESSION_RTH, SESSION_ALL], group = GROUP_STAT, display = display.none, tooltip = "Which bars count, and when a session starts.\n• Regular hours only — extended-hours bars are excluded\n• Regular + extended — every bar counts\n• History and the live day follow one rule, so the percentage is never a ratio of two different things")

bool   showEnvelopeInput  = input.bool(true, "Show envelope", group = GROUP_VISUAL, tooltip = "Session low + typical range, and session high − typical range.\n• A conditional identity, not a forecast: IF the session finishes at the typical size AND the low holds, the high is exactly the upper level\n• Under ATR the levels are built between the true-range extremes, which include the prior session close")
bool   showLadderInput    = input.bool(false, "Show percentile ladder", group = GROUP_VISUAL, tooltip = "Where a finished day of each size would top out, measured up from today's low.\n• Each rung is the size of a completed session — p25 a narrow day, p50 the middle, p90 a wide day — NOT a fraction of today's range\n• p25 sits a full narrow-day's height above the low, so price below it means today is still smaller than even a narrow day\n• Price reaching a rung means today has matched a finished day of that size — IF the low holds\n• Nearest rank over the lookback window: every rung is a range that actually occurred")
bool   showHudInput       = input.bool(true, "Show dashboard", group = GROUP_VISUAL, tooltip = "The readout panel, all or nothing.\n• Off hides every row, the disclosure line included — the rows cannot be hidden selectively\n• The envelope, ladder and chart colours stay\n• Every value stays in the Data Window under its own plot title")
bool   showDetailInput    = input.bool(false, "Show detail rows", group = GROUP_VISUAL, active = showHudInput, tooltip = "Adds the numeric rows to the readout.\n• Range so far, typical range, percentile, widest/narrowest, envelope, ladder\n• Every value is also in the Data Window under its own plot title\n• The headline, meter, delta and disclosure rows are always drawn")
color  envelopeColorInput = input.color(#26C6DA, "Envelope colour", group = GROUP_VISUAL, tooltip = "The envelope lines and the far rail of the Signal fade gradient.\n• The lines take the state colour once the day is past its typical range — that event is always shown")
color  ladderColorInput   = input.color(#7E57C2, "Ladder colour", group = GROUP_VISUAL, tooltip = "The four dotted ladder lines.")
string lineStyleInput     = input.string(LINE_SOLID, "Line style", options = [LINE_SOLID, LINE_DASHED, LINE_DOTTED], group = GROUP_VISUAL, display = display.none)
string gradientPresetInput = input.string(GRAD_SIGNAL, "Band gradient", options = [GRAD_SIGNAL, GRAD_OCEAN, GRAD_EMBER, GRAD_MONO, GRAD_FLAT, GRAD_CUSTOM], group = GROUP_VISUAL, display = display.none, tooltip = "Colour ramp of the envelope band.\n• Every preset keeps the state colour at the near rail\n• Flat — one colour, no ramp\n• Custom — both rails come from the two pickers below")
color  gradientNearInput  = input.color(#00E5FF, "Custom gradient — near rail", group = GROUP_VISUAL, active = gradientPresetInput == GRAD_CUSTOM, tooltip = "Used only when Band gradient is Custom.\n• Set the opacity in the picker — the band uses the colour exactly as picked")
color  gradientFarInput   = input.color(#26C6DA, "Custom gradient — far rail", group = GROUP_VISUAL, active = gradientPresetInput == GRAD_CUSTOM, tooltip = "Used only when Band gradient is Custom.\n• Set the opacity in the picker — the band uses the colour exactly as picked")
color  labelTextColorInput = input.color(#ECEFF1, "Level label text", group = GROUP_VISUAL, tooltip = "Text colour of the envelope and ladder tags.")
string hudModeInput       = input.string(MODE_COMPACT, "Readout mode", options = [MODE_EXPANDED, MODE_COMPACT], group = GROUP_VISUAL, display = display.none, active = showHudInput, tooltip = "How much the readout shows.\n• Compact — headline, meter and distance to typical only\n• Expanded — adds the context row and, with 'Show detail rows', the numeric detail\n• The bottom disclosure row renders in both — what the numbers are measured from is not optional")
string hudSizeInput       = input.string(SIZE_SMALL, "Readout text size", options = [SIZE_TINY, SIZE_SMALL, SIZE_NORMAL, SIZE_LARGE], group = GROUP_VISUAL, display = display.none, active = showHudInput, tooltip = "One size for every readout row.")

// =============================================================================
// Functions
// =============================================================================

// Nearest-rank percentile over an ASCENDING-SORTED array, 1-indexed on the sort:
// the smallest rank r with r >= percentage / 100 * n, floored at 1.
//
// The rank is computed rather than delegated to array.percentile_nearest_rank()
// so the tie convention -- at-or-below -- is this script's own, not an
// assumption about the built-in's.
percentileNearestRank(array<float> sorted, float percentage) =>
    int   n      = array.size(sorted)
    float result = na
    if n > 0
        int chosen = n - 1
        for i = 0 to n - 1
            if (i + 1) * 100.0 >= percentage * n
                chosen := i
                break
        result := array.get(sorted, chosen)
    result

// True range with the first-session rule: the first completed session has no
// prior close and falls back to the plain range.
trueRange(float sessionHigh, float sessionLow, float priorSessionClose) =>
    float plain = sessionHigh - sessionLow
    float upGap = na(priorSessionClose) ? plain : math.abs(sessionHigh - priorSessionClose)
    float dnGap = na(priorSessionClose) ? plain : math.abs(sessionLow - priorSessionClose)
    math.max(plain, math.max(upGap, dnGap))

// The budget meter, as table text. Each cell lights once the percentage reaches
// its share of 100. Only the BAR saturates -- the number beside it never does,
// because a day past its typical range is the most informative reading this
// script produces and a gauge that tops out lies exactly when it matters most.
budgetMeter(float pct) =>
    string bar = ""
    for i = 1 to METER_CELLS
        bar := bar + (pct >= i * 100.0 / METER_CELLS ? METER_FULL : METER_EMPTY)
    bar

// Four bands, and the fourth is the point of the product rather than an alarm:
// it reports that the budget is spent, it does not infer what happens next.
budgetColor(float pct) =>
    color result = COLOR_HUD_DIM
    if not na(pct)
        if pct >= BUDGET_FULL
            result := COLOR_SPENT
        else if pct >= BUDGET_NEAR
            result := COLOR_NEAR
        else if pct >= BUDGET_MID
            result := COLOR_MID
        else
            result := COLOR_ROOM
    result

lineStyleOf(string name) =>
    string result = line.style_solid
    if name == LINE_DASHED
        result := line.style_dashed
    else if name == LINE_DOTTED
        result := line.style_dotted
    result

// The two rails of the gradient band under the selected preset, plus the
// colour the envelope LINES take so they stay in the band's family. Every
// preset except Custom keeps the state colour at the near rail -- that tint is
// where the budget state reads at a glance, and it is not the preset's to
// remove. Custom uses both picked colours exactly as picked, alpha included:
// wrapping a picked colour in color.new() would silently discard the
// transparency chosen in the dialog. The ONE exception is the Custom rail
// line, which is forced opaque deliberately: a rail inheriting the fill's
// transparency can vanish, and an invisible boundary line is worse than an
// alpha the user has to re-pick. The state colour still overrides every rail
// the moment the budget is spent, and no input reaches that.
gradientColorsOf(string preset, color stateColor, color envelopeColor, color customNear, color customFar) =>
    color nearResult = color.new(stateColor, GRADIENT_ALPHA_NEAR)
    color farResult  = color.new(envelopeColor, GRADIENT_ALPHA_FAR)
    color railResult = envelopeColor
    if preset == GRAD_OCEAN
        farResult  := color.new(COLOR_GRAD_OCEAN, GRADIENT_ALPHA_FAR)
        railResult := COLOR_GRAD_OCEAN
    else if preset == GRAD_EMBER
        farResult  := color.new(COLOR_GRAD_EMBER, GRADIENT_ALPHA_FAR)
        railResult := COLOR_GRAD_EMBER
    else if preset == GRAD_MONO
        farResult  := color.new(COLOR_GRAD_MONO, GRADIENT_ALPHA_FAR)
        railResult := COLOR_GRAD_MONO
    else if preset == GRAD_FLAT
        nearResult := color.new(stateColor, GRADIENT_ALPHA_FLAT)
        farResult  := color.new(stateColor, GRADIENT_ALPHA_FLAT)
        railResult := stateColor
    else if preset == GRAD_CUSTOM
        nearResult := customNear
        farResult  := customFar
        railResult := color.new(customFar, 0)
    [nearResult, farResult, railResult]

sizeOf(string name) =>
    string result = size.normal
    if name == SIZE_TINY
        result := size.tiny
    else if name == SIZE_SMALL
        result := size.small
    else if name == SIZE_LARGE
        result := size.large
    result

// The meter row's word for budgetColor()'s band. Same thresholds, same
// constants, so the word and the colour cannot disagree.
stateWordOf(float pct) =>
    string result = STATE_NONE
    if not na(pct)
        if pct >= BUDGET_FULL
            result := STATE_OVER
        else if pct >= BUDGET_NEAR
            result := STATE_NEAR
        else if pct >= BUDGET_MID
            result := STATE_MID
        else
            result := STATE_ROOM
    result

// Create a horizontal level on first use, then move it. Line and label built-ins
// hold no per-call time series, so calling them from inside a conditional is
// safe: nothing here reads history and no result of these calls is read as a
// series, which is what makes conditional built-in calls hazardous elsewhere.
placeLevel(line id, int x1, int x2, float y, color levelColor, string levelStyle, int levelWidth) =>
    line result = id
    if na(result)
        result := line.new(x1, y, x2, y, xloc = xloc.bar_index, color = levelColor, style = levelStyle, width = levelWidth)
    else
        line.set_xy1(result, x1, y)
        line.set_xy2(result, x2, y)
        line.set_color(result, levelColor)
        line.set_style(result, levelStyle)
        line.set_width(result, levelWidth)
    result

placeTag(label id, int x, float y, string tagText, color tagColor, string tagSize) =>
    label result = id
    if na(result)
        result := label.new(x, y, tagText, xloc = xloc.bar_index, color = color.new(color.black, 100), style = label.style_label_left, textcolor = tagColor, size = tagSize)
    else
        label.set_xy(result, x, y)
        label.set_text(result, tagText)
        label.set_textcolor(result, tagColor)
    result

// One slice of the gradient band. A linefill's colour is fixed at construction,
// a pair of lines may hold only ONE linefill, and a repeat call with the same
// pair REPLACES the previous object -- so rebuilding the band every bar is a
// slower way to do exactly what linefill.set_color() does, and it churns
// drawing IDs to do it.
paintSlice(linefill id, line lowerEdge, line upperEdge, color sliceColor) =>
    linefill result = id
    if na(result)
        result := linefill.new(lowerEdge, upperEdge, sliceColor)
    else
        linefill.set_color(result, sliceColor)
    result

// The colour of the slot-th slice, where slot is the slice's MIDPOINT on 0 to
// GRADIENT_SLICES. color.from_gradient() interpolates every RGBA component, so
// handing it two colours that differ in transparency as well as in hue makes one
// call do both halves of the ramp.
sliceColorAt(float slot, color nearColor, color farColor) =>
    color.from_gradient(slot, 0.0, GRADIENT_SLICES, nearColor, farColor)

// =============================================================================
// Calculations
// =============================================================================

// --- the one switch, and both of its consequences ----------------------------
// Not intraday: there is no intraday session at all, so every bar is its own
// session and every bar is included. Disclosed on the chart rather than drawn
// through.
bool isIntraday    = timeframe.isintraday
bool barIncluded   = not isIntraday or sessionInput == SESSION_ALL or session.ismarket
bool sessionOpens  = not isIntraday or (sessionInput == SESSION_RTH ? session.isfirstbar_regular : session.isfirstbar)
bool sessionRolls  = sessionOpens and barIncluded

// Whether this chart has any extended-hours bars at all. When it has none the
// session filter cannot change anything, and that is disclosed rather than
// silently absorbed: it covers a futures symbol whose electronic session IS the
// exchange's regular session, a chart with extended hours switched off, and a
// symbol that has no extended session.
var bool sawExtendedBar = false
sawExtendedBar := sawExtendedBar or (isIntraday and (session.ispremarket or session.ispostmarket))

// --- accumulator state -------------------------------------------------------
var float liveHigh       = na
var float liveLow        = na
var float liveClose      = na
var bool  liveOpen       = false
var int   liveStartIndex = na
var int   completedCount = 0
var float atrValue       = na
var float priorClose     = na
var float adrValue       = na
var float p25Value       = na
var float p50Value       = na
var float p75Value       = na
var float p90Value       = na
var float spreadValue    = na

var array<float> ranges       = array.new<float>()
var array<float> rangesSorted = array.new<float>()

// --- the session roll --------------------------------------------------------
// The completed session is pushed BEFORE the accumulators are reset, so the old
// values are still live and no history read is needed anywhere in this engine.
// That removes the conditional-history hazard rather than working around it,
// and it also removes the form of the bug that carries no compiler warning at
// all: a [1] taken inside a session-roll branch reads the previous SESSION,
// not the previous bar.
if sessionRolls
    if liveOpen
        float closedRange = liveHigh - liveLow
        float closedTr    = trueRange(liveHigh, liveLow, priorClose)
        // Seeded with the FIRST true range, not with an SMA of the first
        // `period` values the way ta.rma() seeds. The two converge but never
        // coincide, and they differ most on a short history -- which is exactly
        // where the disclosure row is already warning the reader. The chart
        // names this "ATR RMA" and never bare "ATR".
        atrValue       := completedCount == 0 ? closedTr : (atrValue * (lookbackInput - 1) + closedTr) / lookbackInput
        priorClose     := liveClose
        completedCount := completedCount + 1
        array.push(ranges, closedRange)
        if array.size(ranges) > lookbackInput
            array.shift(ranges)
        // The sort and the four percentile scans run here, on the roll, and not
        // on every bar.
        rangesSorted := array.copy(ranges)
        array.sort(rangesSorted, order.ascending)
        int closedCount = array.size(ranges)
        if closedCount > 0
            // Summed over `ranges` in arrival order rather than over the sorted
            // copy. The two differ only in floating-point association, but the
            // oracle sums in arrival order and a parity check that has to carry
            // a tolerance is a parity check that can hide a real drift later.
            float total = 0.0
            for i = 0 to closedCount - 1
                total := total + array.get(ranges, i)
            adrValue := total / closedCount
            p25Value := percentileNearestRank(rangesSorted, LADDER_P25)
            p50Value := percentileNearestRank(rangesSorted, LADDER_P50)
            p75Value := percentileNearestRank(rangesSorted, LADDER_P75)
            p90Value := percentileNearestRank(rangesSorted, LADDER_P90)
            // Deliberately not a coefficient of variation. A CV needs a standard
            // deviation, which drags in catastrophic cancellation and a square
            // root; this is three values the ladder already has and it inherits
            // neither hazard.
            spreadValue := p50Value > 0.0 ? (p90Value - p25Value) / p50Value : na
    liveHigh       := high
    liveLow        := low
    liveClose      := close
    liveStartIndex := bar_index
    liveOpen       := true
else if barIncluded and liveOpen
    liveHigh  := math.max(liveHigh, high)
    liveLow   := math.min(liveLow, low)
    liveClose := close

// --- the statistics ----------------------------------------------------------
// Every one of them is computed over COMPLETED sessions only. Excluding the live
// session is load-bearing rather than tidy: a partial day's range is smaller
// than a whole one, so including it would drag the denominator down as the day
// progressed and the percentage would become partly a percentage of itself --
// biased upward, smoothly, with no symptom.
int rangeCount = array.size(ranges)

float typicalRange = na
if statisticInput == STAT_ATR
    typicalRange := atrValue
else if statisticInput == STAT_ADR
    typicalRange := adrValue
else
    // The median of the window and the ladder's 50th rung are the same
    // nearest-rank percentile over the same array.
    typicalRange := p50Value

float sessionRange = liveOpen ? liveHigh - liveLow : na

// Descriptive counts over the disclosed window: how many completed sessions
// ran wider than the typical range, and the window's own extremes. Counts of
// what happened on this chart, never an inference about what happens next.
// Recomputed each bar rather than on the roll because typicalRange follows the
// statistic input while the window itself only moves on the roll.
int   overTypicalCount = 0
float windowMaxRange   = na
float windowMinRange   = na
if rangeCount > 0
    windowMinRange := array.get(rangesSorted, 0)
    windowMaxRange := array.get(rangesSorted, rangeCount - 1)
    if not na(typicalRange)
        for i = 0 to rangeCount - 1
            if array.get(ranges, i) > typicalRange
                overTypicalCount := overTypicalCount + 1

// Under ATR the denominator is an average TRUE range, so a plain high-minus-low
// numerator would make the percentage a ratio of two different things -- the
// same rule the session filter enforces across the regular/extended dimension,
// failing instead in the gap dimension. On a gapping symbol the budget would
// read systematically low: ATR can run 2.47x ADR where gaps are the norm.
//
// The fix is one PAIR OF NUMBERS rather than one formula, because true range has
// a closed form the plain range shares:
//     TR = max(high - low, |high - Cp|, |low - Cp|) = max(high, Cp) - min(low, Cp)
// Raising the live extremes to that pair makes basisRange the live true range,
// and the envelope -- which inherited the same defect -- is corrected by the same
// two numbers. Under ADR and the median the pair IS the session's own extremes,
// so the default statistic is unchanged to the last bit.
bool  usesTrueRange = statisticInput == STAT_ATR and not na(priorClose)
float basisHigh     = usesTrueRange ? math.max(liveHigh, priorClose) : liveHigh
float basisLow      = usesTrueRange ? math.min(liveLow, priorClose) : liveLow
float basisRange    = liveOpen ? basisHigh - basisLow : na

float pctRangeUsed = na
float envUpper     = na
float envLower     = na
float rangePct     = na
bool  envInside    = false
bool  envCrossed   = false

// The same fact in two units, so the reader never has to multiply. Both are
// SIGNED and both are derived from the two numbers the headline already divides:
//
//     pctToTypical = 100 - 100 * basisRange / typicalRange
//                  = 100 * (typicalRange - basisRange) / typicalRange
//                  = 100 * rangeToTypical / typicalRange
//
// so the points figure and the percent figure cannot disagree about which side of
// the typical range the day is on. That identity is the whole reason the row is
// two derived values rather than two independent computations.
float rangeToTypical = na
float pctToTypical   = na

if liveOpen
    if not na(typicalRange)
        // Two events at two thresholds. The obvious single test, upper < lower,
        // does not fire until TWICE the typical range, so a disclosure wired to
        // it alone would stay silent across the entire region this product
        // exists to describe.
        envUpper   := basisLow + typicalRange
        envLower   := basisHigh - typicalRange
        envInside  := envUpper < basisHigh
        envCrossed := envUpper < envLower
        if typicalRange > 0.0
            pctRangeUsed   := 100.0 * basisRange / typicalRange
            rangeToTypical := typicalRange - basisRange
            pctToTypical   := BUDGET_FULL - pctRangeUsed
    if rangeCount > 0
        // Percent of completed sessions whose range was at or below the live
        // range SO FAR. The live session is incomplete, so this figure can only
        // rise for the rest of the day, and the chart says "so far" rather than
        // reporting a finished fact. The scan walks the ascending sort and stops
        // at the first element above the live range.
        int atOrBelow = 0
        for i = 0 to rangeCount - 1
            if array.get(rangesSorted, i) <= sessionRange
                atOrBelow := atOrBelow + 1
            else
                break
        rangePct := 100.0 * atOrBelow / rangeCount

// n means something different for the RMA, which has infinite memory: every
// completed session contributes with a decaying weight, so a windowed count
// would understate it. The disclosure row words it differently for that reason.
int sampleN = statisticInput == STAT_ATR ? completedCount : math.min(completedCount, lookbackInput)
int statId  = statisticInput == STAT_ADR ? 1 : statisticInput == STAT_ATR ? 2 : 3

// =============================================================================
// Visuals
// =============================================================================

// The first ten plots are a frozen Screener contract and an output surface, not
// a formatting choice: the Pine Screener exposes the first 10 plots as filter
// columns. Every colour below is a compile-time constant, so each call costs ONE
// plot count and not two -- a colour handed in from the settings dialog is
// "input"-qualified and doubles the charge. Ten of the 64-plot ceiling.
//
// `display` is narrowed deliberately. A plot's uses outside the script,
// including the Pine Screener, function regardless of its display state on the
// chart. Keeping a percentage out of the price pane is not tidiness: on an
// overlay it would stretch the price scale around a value of 87 on a symbol
// trading at 600.
plot(pctRangeUsed, "1 Range budget %", color = #00E5FF, display = display.data_window + display.status_line)
plot(sessionRange, "2 Session range", color = #26C6DA, display = display.data_window)
plot(typicalRange, "3 Typical range", color = #FFD54F, display = display.data_window)
plot(rangePct, "4 Range percentile", color = #FF6D00, display = display.data_window)
plot(envUpper, "5 Envelope upper", color = #7E57C2, display = display.data_window)
plot(envLower, "6 Envelope lower", color = #7E57C2, display = display.data_window)
plot(sampleN, "7 Sample n", color = #90A4AE, display = display.data_window)
plot(statId, "8 Statistic id", color = #90A4AE, display = display.data_window)
plot(p50Value, "9 p50 range", color = #B0BEC5, display = display.data_window)
plot(p90Value, "10 p90 range", color = #B0BEC5, display = display.data_window)

// Plot 11 is OUTSIDE the frozen ten and exists so that plot 1 is reproducible
// from the Data Window alone under every statistic. It is the actual numerator of
// plot 1: equal to plot 2 under ADR and the median, and the live session's TRUE
// range under ATR, where plot 1 divided by plot 2 would not reproduce it. Adding
// it here rather than renaming plot 2 keeps every saved Screener filter pointing
// at the column it was built against. Eleven of the 64-plot ceiling.
plot(basisRange, "11 Basis range", color = #26C6DA, display = display.data_window)

var line     envUpperLine = na
var line     envLowerLine = na
var label    envUpperTag  = na
var label    envLowerTag  = na

// The glow. Pine has no blur, so a glowing line is three stacked lines at one
// price: a wide, mostly-transparent halo, a narrower mid halo, and the crisp
// core drawn last so it sits on top. Same colour family as the core, so every
// preset and the state override glow in their own hue.
var line     envUpperGlowWide = na
var line     envUpperGlowSoft = na
var line     envLowerGlowWide = na
var line     envLowerGlowSoft = na

// The gradient's whole cost, spelled out as fifteen `var` handles rather than
// held in two arrays. That is deliberate and it is not style: drawing IDs are
// budgeted by their `var` handles, which is what actually persists, and an
// array<line> would hide these IDs from any handle count -- and a drawing
// overage, like a plot overage, is a runtime failure no compile catches.
//
// Nine line IDs here, four glow halos and two envelope cores above, four in
// the ladder and one session marker below, against the default 50 that binds
// because max_lines_count is not passed.
var line     gradLine1 = na
var line     gradLine2 = na
var line     gradLine3 = na
var line     gradLine4 = na
var line     gradLine5 = na
var line     gradLine6 = na
var line     gradLine7 = na
var linefill gradFill1 = na
var linefill gradFill2 = na
var linefill gradFill3 = na
var linefill gradFill4 = na
var linefill gradFill5 = na
var linefill gradFill6 = na
var linefill gradFill7 = na
var linefill gradFill8 = na
var line     p25Line      = na
var line     p50Line      = na
var line     p75Line      = na
var line     p90Line      = na
var label    p25Tag       = na
var label    p50Tag       = na
var label    p75Tag       = na
var label    p90Tag       = na

// Two presentation objects, each its own `var` handle for the same
// budget-counting reason as the gradient's fifteen. Totals with them:
// 18 line IDs and 6 label IDs against the default 50 each, one box against the
// default 500. The shade is hidden by a full-transparency colour rather than
// deleted, so no drawing ID churns.
var box      sessionShade  = na
var line     sessionMarker = na

// One table, of the nine a script may anchor. Rows that are never populated
// collapse, so the row index is advanced explicitly rather than assumed.
//
// Twelve rows and twelve used, at the widest the readout ever gets: headline,
// meter, the delta row, the sessions-over-typical row, seven detail rows
// including the ATR-only "True range so far", and the disclosure row. The
// platform documents no cap on table rows -- only on tables (9) and on total
// cells, with no figure -- so the row count is unquantified rather than
// asserted safe.
var table hud = table.new(position = position.top_right, columns = 2, rows = 12,
     bgcolor = color.new(COLOR_HUD_BG, 10), frame_color = color.new(COLOR_HUD_TXT, 78),
     frame_width = 1, border_color = color.new(COLOR_HUD_BG, 60), border_width = 1)

if barstate.islast
    // Everything below builds strings and moves drawings. None of it reads a
    // time series, so none of it is exposed to the conditional-history class.
    color  stateColor = budgetColor(pctRangeUsed)
    string lineStyle  = lineStyleOf(lineStyleInput)
    int    rightEdge  = bar_index + EXTEND_BARS
    int    leftEdge   = na(liveStartIndex) ? bar_index : liveStartIndex

    // --- the envelope ---------------------------------------------------------
    // The level lines carry the state colour once the budget is spent. The day
    // crossing its typical range is the meaningful event made visible, not a
    // preference, which is why it is not behind an input.
    if showEnvelopeInput and liveOpen and not na(envUpper)
        [nearColor, farColor, railColor] = gradientColorsOf(gradientPresetInput, stateColor, envelopeColorInput, gradientNearInput, gradientFarInput)
        color envColor    = envInside ? stateColor : railColor
        color hiddenColor = color.new(color.black, 100)
        // Signed on purpose. Past twice the typical range the envelope turns
        // inside out -- envUpper drops below envLower, which is the second of the
        // two events -- and the step goes negative with it, so the slices march
        // downward and the band keeps rendering instead of collapsing.
        float sliceStep = (envUpper - envLower) / GRADIENT_SLICES
        // Halos first, cores after: drawings stack in creation order, and the
        // first bar this branch runs is the bar that fixes it.
        color glowWide = color.new(envColor, GLOW_ALPHA_WIDE)
        color glowSoft = color.new(envColor, GLOW_ALPHA_SOFT)
        envUpperGlowWide := placeLevel(envUpperGlowWide, leftEdge, rightEdge, envUpper, glowWide, lineStyle, GLOW_WIDTH_WIDE)
        envLowerGlowWide := placeLevel(envLowerGlowWide, leftEdge, rightEdge, envLower, glowWide, lineStyle, GLOW_WIDTH_WIDE)
        envUpperGlowSoft := placeLevel(envUpperGlowSoft, leftEdge, rightEdge, envUpper, glowSoft, lineStyle, GLOW_WIDTH_SOFT)
        envLowerGlowSoft := placeLevel(envLowerGlowSoft, leftEdge, rightEdge, envLower, glowSoft, lineStyle, GLOW_WIDTH_SOFT)
        envUpperLine := placeLevel(envUpperLine, leftEdge, rightEdge, envUpper, envColor, lineStyle, 2)
        envLowerLine := placeLevel(envLowerLine, leftEdge, rightEdge, envLower, envColor, lineStyle, 2)
        gradLine1 := placeLevel(gradLine1, leftEdge, rightEdge, envLower + sliceStep, hiddenColor, line.style_solid, 1)
        gradLine2 := placeLevel(gradLine2, leftEdge, rightEdge, envLower + 2 * sliceStep, hiddenColor, line.style_solid, 1)
        gradLine3 := placeLevel(gradLine3, leftEdge, rightEdge, envLower + 3 * sliceStep, hiddenColor, line.style_solid, 1)
        gradLine4 := placeLevel(gradLine4, leftEdge, rightEdge, envLower + 4 * sliceStep, hiddenColor, line.style_solid, 1)
        gradLine5 := placeLevel(gradLine5, leftEdge, rightEdge, envLower + 5 * sliceStep, hiddenColor, line.style_solid, 1)
        gradLine6 := placeLevel(gradLine6, leftEdge, rightEdge, envLower + 6 * sliceStep, hiddenColor, line.style_solid, 1)
        gradLine7 := placeLevel(gradLine7, leftEdge, rightEdge, envLower + 7 * sliceStep, hiddenColor, line.style_solid, 1)
        gradFill1 := paintSlice(gradFill1, envLowerLine, gradLine1, sliceColorAt(0.5, nearColor, farColor))
        gradFill2 := paintSlice(gradFill2, gradLine1, gradLine2, sliceColorAt(1.5, nearColor, farColor))
        gradFill3 := paintSlice(gradFill3, gradLine2, gradLine3, sliceColorAt(2.5, nearColor, farColor))
        gradFill4 := paintSlice(gradFill4, gradLine3, gradLine4, sliceColorAt(3.5, nearColor, farColor))
        gradFill5 := paintSlice(gradFill5, gradLine4, gradLine5, sliceColorAt(4.5, nearColor, farColor))
        gradFill6 := paintSlice(gradFill6, gradLine5, gradLine6, sliceColorAt(5.5, nearColor, farColor))
        gradFill7 := paintSlice(gradFill7, gradLine6, gradLine7, sliceColorAt(6.5, nearColor, farColor))
        gradFill8 := paintSlice(gradFill8, gradLine7, envUpperLine, sliceColorAt(7.5, nearColor, farColor))
        envUpperTag := placeTag(envUpperTag, rightEdge, envUpper, "▲ " + str.tostring(envUpper, format.mintick), labelTextColorInput, size.small)
        envLowerTag := placeTag(envLowerTag, rightEdge, envLower, "▼ " + str.tostring(envLower, format.mintick), labelTextColorInput, size.small)

    // --- the percentile ladder ------------------------------------------------
    // Drawn up from the live session low, under the same stated condition as the
    // envelope: IF the low holds, this is where a 75th-percentile day tops out.
    // Nearest rank, so every rung is a range that actually occurred.
    //
    // liveLow, NOT basisLow, and under ATR that is deliberate rather than an
    // oversight: the ladder compares realized plain ranges against a
    // distribution of realized plain ranges, so both sides already agree.
    // Raising only the live side to the true-range basis would reintroduce the
    // ratio-of-two-different-things defect the basis fixed, in the other
    // direction. So on a gap day under ATR the ladder and the envelope stand on
    // different lows, and that is correct.
    if showLadderInput and liveOpen and rangeCount > 0 and not na(p25Value)
        p25Line := placeLevel(p25Line, leftEdge, rightEdge, liveLow + p25Value, color.new(ladderColorInput, 55), line.style_dotted, 1)
        p50Line := placeLevel(p50Line, leftEdge, rightEdge, liveLow + p50Value, color.new(ladderColorInput, 25), line.style_dotted, 1)
        p75Line := placeLevel(p75Line, leftEdge, rightEdge, liveLow + p75Value, color.new(ladderColorInput, 40), line.style_dotted, 1)
        p90Line := placeLevel(p90Line, leftEdge, rightEdge, liveLow + p90Value, color.new(ladderColorInput, 25), line.style_dotted, 1)
        p25Tag  := placeTag(p25Tag, rightEdge, liveLow + p25Value, "p25", labelTextColorInput, size.tiny)
        p50Tag  := placeTag(p50Tag, rightEdge, liveLow + p50Value, "p50", labelTextColorInput, size.tiny)
        p75Tag  := placeTag(p75Tag, rightEdge, liveLow + p75Value, "p75", labelTextColorInput, size.tiny)
        p90Tag  := placeTag(p90Tag, rightEdge, liveLow + p90Value, "p90", labelTextColorInput, size.tiny)

    // --- the session presentation objects -------------------------------------
    // A marker at the bar the budget started counting from and a faint shade
    // over the bars the range was measured on. The shade is hidden by a
    // full-transparency colour rather than deleted, so no drawing ID is
    // churned bar to bar.
    color hiddenObject = color.new(color.black, 100)
    bool  markVisible  = liveOpen and not na(liveHigh)
    color markerColor  = markVisible ? color.new(envelopeColorInput, 40) : hiddenObject
    color shadeColor   = markVisible ? color.new(stateColor, 94) : hiddenObject
    float markTop      = markVisible ? liveHigh : 0.0
    float markBottom   = markVisible ? liveLow : 0.0
    if na(sessionMarker)
        sessionMarker := line.new(leftEdge, markBottom, leftEdge, markTop, xloc = xloc.bar_index, extend = extend.both, color = markerColor, style = line.style_dotted, width = 1)
    else
        line.set_xy1(sessionMarker, leftEdge, markBottom)
        line.set_xy2(sessionMarker, leftEdge, markTop)
        line.set_color(sessionMarker, markerColor)
    if na(sessionShade)
        sessionShade := box.new(leftEdge, markTop, bar_index, markBottom, xloc = xloc.bar_index, bgcolor = shadeColor, border_color = hiddenObject)
    else
        box.set_lefttop(sessionShade, leftEdge, markTop)
        box.set_rightbottom(sessionShade, bar_index, markBottom)
        box.set_bgcolor(sessionShade, shadeColor)

// --- the readout -------------------------------------------------------------
// One text size for every row, and two depths. Compact keeps the three-row
// core; Expanded adds the context row and, behind its own toggle, the detail
// rows. The disclosure row below sits OUTSIDE both conditionals and renders in
// every mode -- a disclosure may never acquire an off switch of its own. The
// dashboard switch that governs this whole block is deliberately ALL OR
// NOTHING: it hides the headline and the disclosure together, and it may never
// learn to hide rows selectively, because a switch that hid the disclosure
// while other rows stayed visible would be the off switch the rule forbids.
if barstate.islast and showHudInput
    color  stateColor = budgetColor(pctRangeUsed)
    string statShort  = statisticInput == STAT_ADR ? "ADR" : statisticInput == STAT_ATR ? "ATR RMA" : "MEDIAN"
    string statTitle  = statShort + "(" + str.tostring(lookbackInput) + ")"
    string hudTextSize  = sizeOf(hudSizeInput)
    bool   expandedMode = hudModeInput == MODE_EXPANDED
    int row = 0

    table.cell(hud, 0, row, "RANGE BUDGET", text_color = COLOR_INK, text_size = hudTextSize, text_halign = text.align_left, text_formatting = text.format_bold, bgcolor = stateColor)
    table.cell(hud, 1, row, na(pctRangeUsed) ? "--" : str.tostring(pctRangeUsed, "#.#") + "%", text_color = COLOR_INK, text_size = hudTextSize, text_halign = text.align_right, text_formatting = text.format_bold, bgcolor = stateColor)
    row := row + 1

    // The state word, not the statistic name: the statistic already renders on
    // the disclosure row below, and the word is the same four-band read as the
    // colour, from the same constants, so the two cannot disagree.
    table.cell(hud, 0, row, budgetMeter(pctRangeUsed), text_color = stateColor, text_size = hudTextSize, text_halign = text.align_left)
    table.cell(hud, 1, row, stateWordOf(pctRangeUsed), text_color = stateColor, text_size = hudTextSize, text_halign = text.align_right, text_formatting = text.format_bold)
    row := row + 1

    // The delta row, drawn unconditionally: the same signed pair rendered in
    // chart units and in headline units, so the row cannot contradict the
    // headline. The word is "typical", never "expected" -- an expected move is
    // options-derived and Pine has no options data.
    //
    // The boundary is BUDGET_FULL rather than a bare 100.0 because it is the
    // same constant budgetColor() turns COLOR_SPENT at: at exactly 100 percent
    // the label and the headline colour must agree, even though the row then
    // reads "Over typical  0.00 (0.0%)".
    bool   overTypical = not na(pctRangeUsed) and pctRangeUsed >= BUDGET_FULL
    string deltaLabel  = overTypical ? "Over typical" : "Left to typical"
    string deltaPoints = na(rangeToTypical) ? "--" : str.tostring(math.abs(rangeToTypical), format.mintick)
    string deltaPct    = na(pctToTypical) ? "" : "  (" + str.tostring(math.abs(pctToTypical), "#.#") + "%)"

    table.cell(hud, 0, row, deltaLabel, text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
    table.cell(hud, 1, row, deltaPoints + deltaPct, text_color = stateColor, text_size = hudTextSize, text_halign = text.align_right, text_formatting = text.format_bold)
    row := row + 1

    // Everything from here to the disclosure block is Expanded-only. The
    // sessions-over-typical row is the context the headline is read against; a
    // count over a disclosed sample, never a rate offered as odds.
    if expandedMode
        string overCountText = rangeCount == 0 ? "--" : str.tostring(overTypicalCount) + " of last " + str.tostring(rangeCount)
        string overCountTip  = "Of the last " + str.tostring(rangeCount) + " completed sessions, how many ran wider than the typical range. Context for the headline percentage — a count of what happened on this chart, not odds."
        table.cell(hud, 0, row, "Sessions over typical", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
        table.cell(hud, 1, row, overCountText, text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right, tooltip = overCountTip)
        row := row + 1

        if showDetailInput
            table.cell(hud, 0, row, "Range so far", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(sessionRange) ? "--" : str.tostring(sessionRange, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

            // Only under ATR, and only because under ATR it is a DIFFERENT
            // number from the row above: this is the figure the headline
            // percentage actually divides, so the reader can reproduce it.
            // Under ADR and the median the two rows would be identical and the
            // row is not drawn.
            if usesTrueRange
                table.cell(hud, 0, row, "True range so far", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
                table.cell(hud, 1, row, na(basisRange) ? "--" : str.tostring(basisRange, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
                row := row + 1

            table.cell(hud, 0, row, "Typical range", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(typicalRange) ? "--" : str.tostring(typicalRange, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

            table.cell(hud, 0, row, "Wider so far than", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(rangePct) ? "--" : str.tostring(rangePct, "#.#") + "% of " + str.tostring(rangeCount) + " completed", text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

            table.cell(hud, 0, row, "Widest / narrowest", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(windowMaxRange) ? "--" : str.tostring(windowMaxRange, format.mintick) + " / " + str.tostring(windowMinRange, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

            table.cell(hud, 0, row, "Envelope hi / lo", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(envUpper) ? "--" : str.tostring(envUpper, format.mintick) + " / " + str.tostring(envLower, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

            table.cell(hud, 0, row, "Ladder 25/50/75/90", text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left)
            table.cell(hud, 1, row, na(p25Value) ? "--" : str.tostring(p25Value, format.mintick) + " / " + str.tostring(p50Value, format.mintick) + " / " + str.tostring(p75Value, format.mintick) + " / " + str.tostring(p90Value, format.mintick), text_color = COLOR_HUD_TXT, text_size = hudTextSize, text_halign = text.align_right)
            row := row + 1

    // --- the disclosure -------------------------------------------------------
    // Always rendered, as ONE compact row: the full disclosure sentence and the
    // degeneracy notes live in this row's hover tooltips so the readout stays
    // narrow, but the row itself has no off switch and never collapses. The
    // toggle above is deliberately named "Show detail rows" rather than
    // "Show table" so no future edit can hand this row an off switch by
    // relocating it.
    string sessionLabel = not isIntraday ? "each bar is one session" : sessionInput == SESSION_RTH ? "regular hours" : "regular + extended"
    string sampleText   = "n = " + str.tostring(sampleN)
    if statisticInput == STAT_ATR
        sampleText := "n = " + str.tostring(sampleN) + " sessions seeded"
    else if sampleN < lookbackInput
        sampleText := "n = " + str.tostring(sampleN) + " of " + str.tostring(lookbackInput) + " requested"
    string spreadText = na(spreadValue) ? "spread n/a" : "spread " + str.tostring(spreadValue, "#.##")

    // The degeneracies, each disclosed rather than drawn through. The
    // subsession case: session.isfirstbar_regular is always false when the
    // ticker uses a subsession, so under a regular-hours filter no session
    // would ever start and the script would render nothing with no other
    // explanation.
    string notes = ""
    if completedCount == 0
        notes := notes + "No completed session yet. "
    if not isIntraday
        notes := notes + "Not intraday: every bar is one session. "
    if isIntraday and not sawExtendedBar
        notes := notes + "Session filter inert: no extended-hours bars on this chart. "
    if isIntraday and sessionInput == SESSION_RTH and not liveOpen
        notes := notes + "No regular-session start seen; this ticker may use a subsession — try Regular + extended hours. "
    if not na(p50Value) and p50Value <= 0.0
        notes := notes + "p50 range is zero: spread ratio unavailable. "
    // The noun changes with the basis: under ATR the envelope is built between
    // the TRUE-range extremes, so on a gap day the upper level can sit above
    // the session high while still being "inside" the pair it was built from.
    // Saying "the day's extremes" there would describe a line the reader can
    // see is somewhere else.
    string extremesWord = usesTrueRange ? "the true-range extremes" : "the day's extremes"
    if usesTrueRange and (priorClose > liveHigh or priorClose < liveLow)
        notes := notes + "Overnight gap counted: the true range is measured from the prior session close, so it exceeds high minus low. "
    if envCrossed
        notes := notes + "Past 2x typical: the envelope has turned inside out. "
    else if envInside
        notes := notes + "Past typical: the envelope sits inside " + extremesWord + ". "

    // The left tooltip carries the standing disclosure sentence. That sentence
    // is frozen word for word -- it is the one permitted use of the word
    // "expected", naming the thing the product is not -- so it is concatenated
    // as its own literal and never reworded.
    string statExplain = statisticInput == STAT_ADR ? "ADR(" + str.tostring(lookbackInput) + ") = average daily range: the average of the last " + str.tostring(lookbackInput) + " completed session ranges (high minus low)." : statisticInput == STAT_ATR ? "ATR RMA(" + str.tostring(lookbackInput) + ") = average true range: the session range including any overnight gap, averaged with recent sessions weighted more." : "MEDIAN(" + str.tostring(lookbackInput) + ") = the middle of the last " + str.tostring(lookbackInput) + " completed session ranges."
    string statTip     = statExplain + " This is the typical range the headline percentage divides by.\n\n" + "Realized range from OHLCV — not an implied or expected move" + ": every number here is measured from this chart's own price history. Nothing comes from options pricing, and the typical range describes completed sessions."
    string sampleTip   = "n = completed sessions actually loaded on this chart. Spread = (p90 − p25) ÷ p50 of those session ranges: near 0 means recent sessions were similar in size, higher means they were mixed."
    string notesTip    = notes == "" ? sampleTip : sampleTip + "\n\n⚠ " + notes
    color  noteColor   = notes == "" ? COLOR_HUD_DIM : COLOR_MID

    table.cell(hud, 0, row, statTitle + " · " + sessionLabel, text_color = COLOR_HUD_DIM, text_size = hudTextSize, text_halign = text.align_left, tooltip = statTip)
    table.cell(hud, 1, row, sampleText + " · " + spreadText + (notes == "" ? "" : "  ⚠"), text_color = noteColor, text_size = hudTextSize, text_halign = text.align_right, tooltip = notesTip)
````
