# Effort vs Result by Volume

- url: https://www.tradingview.com/script/qBTCcrsW-Effort-vs-Result-by-Volume/
- type: indicator
- pine_id: PUB;ad6839bc7949420d9d7f26313748bee0
- version: 1.0

## Description

[image]https://www.tradingview.com/x/zebCvFOH/[/image]

Effort vs Result by Volume

How much net price displacement (result) did each unit of volume (effort) buy?

Classifies every bar (or pooled window of bars) by ranking its volume and its NET displacement against the instrument's own recent history, giving four states:

- Yellow = Vacuum / one-sided: big net move on disproportionately low volume. Price moved easily with little opposition; these moves are often revisited.
- Orange = Climax (effort with result): big net move on high volume. A strong push that may also be exhausting itself.
- Aqua = Absorption (effort, no result): small net move on disproportionately high volume. Heavy trading went nowhere, suggesting large orders soaking up the flow. Watch for a reversal or breakout.
- Grey = Quiet balance*: small net move on low volume. A flat, resting market.
- Faded teal / red = Normal: no state. Teal if the candle closed at or above its open, red if below.

"Net move" is |close - open of the window|, not the high-low range: a wide bar that round-trips back to its open scores as a SMALL net move.

* Quiet balance is reserved for genuinely flat trade: small range as well as small net move, and no slow directional drift over recent bars.

Vacuum and Absorption are judged on the GAP between the two ranks, so a big move on merely average volume still counts as disproportionate.

Percentile ranking (not fixed multiples) makes this portable across stocks, futures and timeframes. On intraday charts each bar is first divided by its typical value at the same time of day, so the open and the lunch lull are not flagged just for being the open and the lunch lull.

Volume columns are coloured on every bar in a state. The faint vertical highlight (and alerts) mark only the first bar of each distinct event. All colours can be changed in the Display settings.

## Source Code

````pine
//@version=6
//
//       █                               █
//       █                               █
//    ████   ███    ████   ███   ████   ████
//   █   █  █   █  █      █   █  █   █   █
//   █   █  █████  █      █████  █   █   █
//   █   █  █      █      █      █   █   █
//    ████   ████   ████   ████  █   █    ██   █████
//
//   █████          █     █                     █
//   █              █     █
//   █      ████   ████   ████   █   █   ████  ██    ███    ████  ██ █
//   ████   █   █   █     █   █  █   █  █       █       █  █      █ █ █
//   █      █   █   █     █   █  █   █   ███    █    ████   ███   █ █ █
//   █      █   █   █     █   █  █   █      █   █   █   █      █  █ █ █
//   █████  █   █    ██   █   █   ████  ████   ███   ████  ████   █ █ █
//
// Effort vs Result by Volume
// How much net price displacement (result) did each unit of volume (effort) buy?
//
// Classifies every bar (or pooled window of bars) by ranking its volume and its
// NET displacement against the instrument's own recent history:
//
//                    LOW VOLUME (effort)        HIGH VOLUME (effort)
//   BIG NET MOVE     Vacuum / one-sided         Climax (effort with result)
//   SMALL NET MOVE   Quiet balance*             Absorption (effort, no result)
//
// "Net move" is |close - open of the window|, not high-low range: a wide bar
// that round-trips back to its open scores as a SMALL net move.
// * Quiet balance is reserved for genuinely flat trade: small range as well as
//   small net move, and no slow directional drift over recent bars.
//
// Vacuum and Absorption are judged on the GAP between the two ranks, so a big
// move on merely average volume still counts as disproportionate.
//
// Percentile ranking (not fixed multiples) makes this portable across stocks,
// futures and timeframes. On intraday charts each bar is first divided by its
// typical value at the same time of day, so the open and the lunch lull are
// not flagged just for being the open and the lunch lull.
indicator("Effort vs Result by Volume", shorttitle = "EvR Vol", overlay = false, format = format.volume, precision = 0)

// ---------------- Types ----------------
enum State
    none
    vacuum
    absorb
    climax
    quiet

// Wrapper so per-slot histories can live in a map (Pine forbids nesting
// collections directly).
type SlotHist
    array<float> vals

// ---------------- Inputs: Measurement ----------------
string GRP_M = "Measurement"
int W = input.int(2, "Window (bars)", minval = 1, maxval = 50, group = GRP_M, tooltip = "1 = judge each candle on its own. Higher pools the candle with its neighbours, which smooths out single-bar noise.")
int lookback = input.int(250, "Normalisation lookback", minval = 20, maxval = 2000, group = GRP_M, tooltip = "How many bars define 'normal' for this instrument. Larger = more stable, slower to adapt to regime change.")
bool useTodIn = input.bool(true, "Time-of-day normalisation", group = GRP_M, tooltip = "Intraday charts (1 min and above) only. Each bar's volume, net move and range are divided by their median at the same clock time over prior sessions before ranking, removing open/close/lunch seasonality. Needs 5 sessions of history before signals start.")
int todSessions = input.int(20, "Sessions in time-of-day baseline", minval = 5, maxval = 100, group = GRP_M, tooltip = "How many prior sessions form the same-time-of-day baseline.")
bool confirmedOnly = input.bool(false, "Display confirmed bars only", group = GRP_M, tooltip = "Display only: the forming bar has partial volume, so its colour flickers until close. This does NOT affect alerts - to alert on closed bars only, choose 'Once Per Bar Close' when creating the alert.")

// ---------------- Inputs: Thresholds ----------------
string GRP_T = "Thresholds"
int hiPct = input.int(70, "High percentile", minval = 50, maxval = 100, group = GRP_T, tooltip = "At or above this percentile counts as 'high'. Raise for fewer, stronger signals.")
int loPct = input.int(25, "Low percentile", minval = 0, maxval = 50, group = GRP_T, tooltip = "At or below this percentile counts as 'low' (used by Quiet balance).")
int minGap = input.int(45, "Min rank gap (vacuum / absorption)", minval = 10, maxval = 100, group = GRP_T, tooltip = "Vacuum: net-move rank must be high AND exceed volume rank by at least this much. Absorption: the reverse. 45 reproduces the classic 70/25 corners, but also catches e.g. a 95th-pct move on 50th-pct volume.")
float erMin = input.float(0.5, "Min directionality (vacuum only)", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_T, tooltip = "Net displacement divided by the window's high-low range. 1.0 = clean one-way move, 0.0 = round trip back to start. Keeps choppy wide-range bars out of the vacuum bucket.")
int driftLen = input.int(10, "Drift lookback (quiet filter)", minval = 3, maxval = 100, group = GRP_T, tooltip = "Bars used to detect a slow, steady grind (e.g. overnight drift) that should not be called Quiet balance.")
float driftMax = input.float(0.5, "Max drift directionality (quiet)", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_T, tooltip = "Net close-to-close change over the drift lookback divided by the total bar-to-bar path. At or above this, low-volume bars are drifting directionally and are not classed as Quiet balance.")

// ---------------- Inputs: Signals ----------------
string GRP_S = "Signals"
int extraCooldown = input.int(0, "Extra cooldown bars", minval = 0, maxval = 50, group = GRP_S, tooltip = "A state is only treated as a new event (highlight + alert) once its window no longer overlaps the previous event of the same state, i.e. after Window - 1 bars. Add more bars here to space events further apart.")

// ---------------- Inputs: Display ----------------
string GRP_D = "Display"
bool showVacuum = input.bool(true, "Vacuum / one-sided (low vol, big net move)", group = GRP_D, inline = "v")
color colVacuum = input.color(color.yellow, "", group = GRP_D, inline = "v")
bool showAbsorb = input.bool(true, "Absorption (high vol, small net move)", group = GRP_D, inline = "a")
color colAbsorb = input.color(color.aqua, "", group = GRP_D, inline = "a")
bool showClimax = input.bool(true, "Climax (high vol, big net move)", group = GRP_D, inline = "c")
color colClimax = input.color(#FF6D00, "", group = GRP_D, inline = "c")
bool showQuiet = input.bool(true, "Quiet balance (flat, low vol)", group = GRP_D, inline = "q")
color colQuiet = input.color(color.gray, "", group = GRP_D, inline = "q")
color upCol = input.color(color.new(color.teal, 60), "Normal up candle", group = GRP_D)
color dnCol = input.color(color.new(color.red, 60), "Normal down candle", group = GRP_D)
bool showBg = input.bool(true, "Vertical highlight (events only)", group = GRP_D, tooltip = "Volume columns show every bar's state. The vertical highlight marks only distinct events - see Signals > cooldown.")
int bgTrans = input.int(85, "Highlight transparency", minval = 0, maxval = 100, group = GRP_D)

// ---------------- Helpers ----------------
// Ratio of src to its typical value in the same time-of-day slot over prior
// sessions. Median resists one-off news spikes; mean is the fallback when the
// median is zero (thin instruments with many unchanged bars).
todRatio(float src, int slot, int sessions) =>
    var map<int, SlotHist> hist = map.new<int, SlotHist>()
    if not hist.contains(slot)
        hist.put(slot, SlotHist.new(array.new<float>()))
    array<float> h = hist.get(slot).vals
    float base = na
    if h.size() >= 5
        float med = h.median()
        base := med > 0 ? med : h.avg()
    float ratio = base > 0 ? src / base : na
    if not na(src)
        h.push(src)
        if h.size() > sessions
            h.shift()
    ratio

stateColor(State s) =>
    switch s
        State.vacuum => showVacuum ? colVacuum : na
        State.absorb => showAbsorb ? colAbsorb : na
        State.climax => showClimax ? colClimax : na
        State.quiet  => showQuiet  ? colQuiet  : na
        => color(na)

// ---------------- Volume availability guard ----------------
// Some symbols (spot FX, some CFDs, indices) carry no volume at all. Judge
// this from the data itself: at least half of the recent bars must have
// non-zero volume. (syminfo.volumetype is not used - it returns "n/a" for
// most stocks and futures, whose volume type is simply unspecified.)
float volCoverage = math.sum(nz(volume) > 0 ? 1.0 : 0.0, lookback) / lookback
bool hasVolume = volCoverage >= 0.5

// ---------------- Measurements ----------------
float volW = math.sum(volume, W)                            // effort: pooled volume
float rangeW = ta.highest(high, W) - ta.lowest(low, W)      // ground covered
float netMove = math.abs(close - open[W - 1])               // result: net displacement
bool candleUp = close >= open                               // colour follows this bar's own candle

// Directionality of this window (W = 1: body / range).
float er = rangeW > 0 ? netMove / rangeW : 0.0

// Slow-drift detector for the quiet filter (Kaufman efficiency ratio).
float path = math.sum(math.abs(close - close[1]), driftLen)
float driftEr = path > 0 ? math.abs(close - close[driftLen]) / path : 0.0

// Time-of-day normalisation. Slot 0 everywhere when disabled keeps the
// helper's history tiny (and avoids huge maps on seconds charts).
bool useTod = useTodIn and timeframe.isintraday and timeframe.in_seconds() >= 60
int slot = useTod ? hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone) : 0
float volTod = todRatio(volW, slot, todSessions)
float moveTod = todRatio(netMove, slot, todSessions)
float rangeTod = todRatio(rangeW, slot, todSessions)

float volN = useTod ? volTod : volW
float moveN = useTod ? moveTod : netMove
float rangeN = useTod ? rangeTod : rangeW

// Rank against this instrument's own history.
float volRank = ta.percentrank(volN, lookback)
float moveRank = ta.percentrank(moveN, lookback)
float rangeRank = ta.percentrank(rangeN, lookback)

// Require a full lookback of valid normalised values so ranks aren't skewed
// by the warm-up period.
var int validBars = 0
if not na(volN) and not na(moveN) and not na(rangeN)
    validBars += 1
bool ready = hasVolume and validBars > lookback

// ---------------- Detection (independent of display settings) ----------------
State raw = switch
    not ready => State.none
    volRank >= hiPct and moveRank >= hiPct => State.climax
    moveRank >= hiPct and moveRank - volRank >= minGap and er >= erMin => State.vacuum
    volRank >= hiPct and volRank - moveRank >= minGap => State.absorb
    volRank <= loPct and moveRank <= loPct and rangeRank <= loPct and driftEr < driftMax => State.quiet
    => State.none

// De-duplication: windows of bars i and j overlap when j - i <= W - 1, so a
// state only counts as a new event once that gap has passed since the last
// event of the same state. Flagged events therefore never share bars.
int cooldown = W - 1 + extraCooldown
var map<State, int> lastEvent = map.new<State, int>()
bool isEvent = raw != State.none and (not lastEvent.contains(raw) or bar_index - lastEvent.get(raw) > cooldown)
if isEvent
    lastEvent.put(raw, bar_index)

// ---------------- Presentation ----------------
bool displayable = not confirmedOnly or barstate.isconfirmed
color sCol = displayable ? stateColor(raw) : na
color colCol = na(sCol) ? (candleUp ? upCol : dnCol) : sCol

plot(volume, "Volume", color = colCol, style = plot.style_columns, display = display.pane)
bgcolor(showBg and isEvent and not na(sCol) ? color.new(sCol, bgTrans) : na, title = "Event highlight")

// Status / warning box.
var table status = table.new(position.top_right, 1, 1)
if barstate.islast
    string msg = ""
    color msgCol = na
    if not na(volCoverage) and not hasVolume
        msg := "No usable volume data on this symbol - classification disabled."
        msgCol := color.red
    else if not ready
        msg := "Warming up: needs " + str.tostring(lookback) + " bars" + (useTod ? " after 5 sessions of history." : ".")
        msgCol := color.gray
    if msg != ""
        table.cell(status, 0, 0, msg, text_color = color.white, bgcolor = color.new(msgCol, 20), text_size = size.small)
    else
        table.clear(status, 0, 0)

// ---------------- Alerts (detection only; not affected by display toggles) ----------------
alertcondition(isEvent and raw == State.vacuum, "Vacuum / one-sided", "Big net move on disproportionately low volume - one-sided auction")
alertcondition(isEvent and raw == State.absorb, "Absorption", "High volume, disproportionately small net move - absorption")
alertcondition(isEvent and raw == State.climax, "Climax", "High volume with big net move - effort with result")
alertcondition(isEvent and raw == State.quiet, "Quiet balance", "Flat, low-volume trade with no directional drift")
````
