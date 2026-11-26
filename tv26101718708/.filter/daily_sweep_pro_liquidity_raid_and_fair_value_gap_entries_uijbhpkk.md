# Daily Sweep Pro: liquidity raid and fair value gap entries

- url: https://www.tradingview.com/script/UIjbHPKk-Daily-Sweep-Pro-liquidity-raid-and-fair-value-gap-entries/
- type: indicator
- pine_id: PUB;2f55421538644837babcc4e94c549d86
- version: 2.0

## Description

A liquidity-sweep model that refuses to print an entry unless four things happen in the right order, and abandons the setup when any of them breaks.

[b]What it does[/b]

It reads daily market structure to decide which direction it is allowed to trade, then waits inside the New York session for price to run a pool of resting orders in the wrong direction, then requires a fair value gap back in the direction of structure, and only then arms an entry on the pullback into that gap. The target is the opposite prior-day level. The stop is the extreme of the sweep.

If any step is missing, nothing prints. If a step happens out of order, nothing prints.

[b]What is original here[/b]

The individual ideas are public and widely taught, and I will not pretend otherwise: daily structure, the accumulation and manipulation and distribution session model, sweeps of prior highs and lows, fair value gaps, opening gaps. You can find every one of them explained openly in a hundred places. Nothing here claims to have invented them.

What is not standard is the wiring.

The usual way these ideas get implemented is as separate indicators drawing separate levels, leaving the trader to spot the sequence by eye. This is one state machine with four states, and it enforces causal order. A gap that forms before the sweep is not a signal. A sweep with no gap after it is not a signal. A gap that appears once the session has ended, or once the daily bias has flipped, is not a signal, and the machine drops the setup rather than carrying it forward.

Three specific consequences of that design:

1. The manipulation filter is a directional test against the weekly open, not a location test. In a bearish read the sweep only counts if price is above the weekly open when it happens, and in a bullish read only if price is below it. The trap has to occur on the side of the week's opening price where trapped traders would be, which is the part of the session model that usually gets drawn as a line and then ignored.

2. Every setup is priced before it is allowed to arm. Stop at the sweep extreme, target at the opposite prior-day level, and the reward-to-risk computed from those two. Below your floor, the setup is discarded silently rather than printed with a warning. That means the absence of a mark is information: it can mean there was no sequence, or that the sequence had nowhere to go.

3. There is a hard daily circuit breaker on entries. After the limit, the machine stops arming for the rest of the day regardless of how good the next sequence looks. A model built around trapped liquidity will find a sequence on almost any day if you let it, and the constraint exists to stop that.

[b]How it works[/b]

Daily bias comes from pivot structure on the daily timeframe, comparing the last two confirmed pivot highs and the last two confirmed pivot lows. Higher highs with higher lows permits longs only. Lower highs with lower lows permits shorts only. Anything else is neutral and the model stands down entirely.

Liquidity pools are the levels where stop orders cluster: the most recent confirmed intraday swing, the overnight range high and low, the premarket range high and low, and the opposing prior-day level. A raid is the first breach of one of those pools in the direction against the daily bias, detected as a level that was intact on the previous bar and is not intact on this one.

A fair value gap is a three-bar displacement, measured as the distance between the current bar and the bar two back, and filtered by a minimum size expressed in units of recent average range so a one-tick gap on a quiet instrument does not qualify.

Entry is the pullback into that gap, at either the near edge or the midpoint, and it must occur on a bar after the gap formed rather than the same bar.

The session ranges, the weekly open, the prior-day levels and the new-week opening gap are all drawn so you can see the context the machine is reading, and a status table reports which state it is currently in and why it is not trading if it is not.

[b]How to use it[/b]

Built for the 1H chart and any lower intraday timeframe. Sessions are New York time; change them if you trade another region's hours.

The status table is the point of the tool as much as the marks are. It tells you the current daily bias, which state the machine is in, and when it is standing down it tells you which precondition is missing. Reading that for a week teaches you the sequence faster than reading the marks does.

Start with the defaults. The two settings actually worth moving are the minimum reward-to-risk, which controls how much of the day gets filtered out, and the weekly-open filter, which is the difference between a strict textbook read and a looser one.

[b]What it cannot do[/b]

The daily bias is deliberately slow and it will be late at turns. A daily pivot needs its confirmation days on both sides before it exists, and the read is taken from the last completed daily bar, so at the default the structure being used is up to about three days old. That is a structural filter, not a timing tool, and treating it as a timing tool is the main way to misuse this.

A bar that trades through both the stop and the target is recorded as a stop. The bar alone cannot prove which came first, so the pessimistic reading is used rather than the flattering one.

Session ranges persist until the next session of the same type begins, so on a symbol without overnight data, or after a holiday, an overnight or premarket level may be older than the current day.

Nothing here is a backtest and no performance is claimed. The marks show what the rules produced on the bars loaded on your chart. Entries are assumed to fill at the level, and no spread, slippage or commission is modelled, so any reward-to-risk shown on screen is the geometry of the setup and not a result.

It does not predict anything. It describes a sequence that has already completed and prices what that sequence implies.

[b]On authorship[/b]

The methodology is public and I have said so plainly above. The implementation is not borrowed. Every line is written from scratch, no code in it is copied or adapted from another author's script on this platform or anywhere else, and it does not reproduce any specific published indicator. Where the vocabulary looks familiar, that is because the vocabulary is public.

[b]Settings[/b]

Daily pivot strength and the weekly-open manipulation filter; the three session windows and whether to flatten at session end; which liquidity pools are eligible and the swing strength that defines one; the patience window from raid to gap, the minimum gap size and whether entry sits at the gap edge or its midpoint; the minimum reward-to-risk and the daily entry cap; and display toggles for each drawn element.

## Source Code

````pine
//@version=6
// =============================================================================
//  DAILY SWEEP PRO ELITE  [Liquidity Raid + AMD + FVG]
//
//  ORIGINALITY AND ATTRIBUTION
//  The concepts below are widely taught public trading methodology: daily market
//  structure, the accumulation / manipulation / distribution session model,
//  liquidity sweeps of prior highs and lows, fair value gaps, and opening gaps.
//  None of them are mine and I make no claim on them. What is mine is this
//  implementation. Every line here is written from scratch. No code in this
//  script is copied or adapted from another author's script, on this platform
//  or anywhere else, and no part of it reproduces a specific published
//  indicator. Where the reading below looks familiar it is because the
//  vocabulary is public, not because the code is borrowed.
//
//  WHAT THIS SCRIPT ADDS over a set of separate indicators drawing the same
//  levels: the four ideas are wired into one state machine that will not print
//  an entry unless they occur in the correct causal ORDER, and that abandons
//  the setup if any precondition breaks while it waits. See the state model
//  section below.
//
//  Concept map:
//   - Daily structure = control ......... HH+HL longs only / LH+LL shorts only
//   - Target ............................ previous day's high (longs) / low (shorts)
//   - Power of Three (AMD) ............. weekly open line; manipulation filter
//     requires the trap to occur on the WRONG side of the weekly open
//     (above it in bear bias, below it in bull bias) - the Judas swing
//   - Liquidity pools that get raided ... intraday swing (3-candle), Asian range
//     high/low, premarket high/low, opposing previous-day level
//   - Fakeout / trap .................... first breach of a pool AGAINST daily bias
//   - Confirmation ...................... FVG in trend direction right after raid
//   - Entry ............................. pullback into the FVG (edge or midpoint)
//   - Stop .............................. sweep extreme (clear invalidation)
//   - NWOG .............................. Friday close -> Monday open gap, drawn
//     as reaction/target context for the week
//
//  NON-REPAINTING. Every higher-timeframe request is paired with either a [1]
//  offset or a value that is fixed when its bar opens, so lookahead cannot
//  return information the chart bar did not have. Details at each call site.
//  All signal state advances only on barstate.isconfirmed.
//
//  KNOWN LIMITATIONS, stated plainly:
//   - The daily bias is deliberately slow. A daily pivot needs "pivot strength"
//     days either side to confirm, and the read is then taken from the last
//     completed daily bar, so at the default the bias reflects structure up to
//     roughly three days old. That is a design choice, not an oversight: it is
//     a structural filter, not a timing tool. It will be late at turns.
//   - A bar that trades through both the stop and the target is recorded as a
//     stop. The bar alone cannot prove which came first, so the pessimistic
//     reading is used rather than the flattering one.
//   - The session ranges persist until the next session of the same type
//     begins. On a symbol with no overnight data, or after a holiday, an Asian
//     or premarket level may be older than the current day.
//   - Nothing here is a backtest. Marks are what the rules produced on the
//     bars loaded on your chart, entries are assumed to fill at the level, and
//     no slippage, spread or commission is modelled.
//
//  Intended TF: 1H, and any intraday timeframe works. Sessions are New York.
// =============================================================================
indicator("Daily Sweep Pro Elite: liquidity raid and fair value gap entries", "DSP Elite", overlay = true,
     max_boxes_count = 150, max_lines_count = 150, max_labels_count = 300)

tzNY = "America/New_York"

//---------------------------- Inputs ----------------------------
gB = "Bias Engine"
dLen    = input.int(2, "Daily pivot strength (days each side)", minval = 1, maxval = 5, group = gB)
pdSource = input.string("Exchange daily", "Previous-day level source",
     options = ["Exchange daily", "Prior NY session"], group = gB,
     tooltip = "Exchange daily uses the symbol's completed daily candle. Prior NY session uses the completed custom NY execution window tracked on this chart.")
useWOK  = input.bool(true, "Weekly-open manipulation filter (AMD)", group = gB,
     tooltip = "The raid extreme—not its close—must trade above the weekly open for shorts or below it for longs. This preserves valid wick reclaims. Turn off for more, lower-quality setups.")

gS = "Sessions (ET)"
nySess  = input.session("0930-1600", "NY execution window", group = gS)
// Pine session hours are 00–23. "2400" is invalid; "2000-0000" correctly
// means 20:00 through midnight.
asSess  = input.session("2000-0000", "Asian range", group = gS)
pmSess  = input.session("0400-0930", "Premarket range", group = gS)
closeEOD = input.bool(true, "Flatten open trade at session end", group = gS)

gL = "Liquidity pools eligible for the raid"
useSwing = input.bool(true, "Intraday swing (3-candle)", group = gL)
useAsia  = input.bool(true, "Asian range high/low", group = gL)
usePM    = input.bool(true, "Premarket high/low", group = gL)
usePD    = input.bool(true, "Opposing previous-day level", group = gL,
     tooltip = "Bear bias: raid above PDH before shorting to PDL. Bull bias: raid below PDL before buying to PDH.")
swLen    = input.int(1, "Swing strength", minval = 1, maxval = 10, group = gL,
     tooltip = "1 uses the classic three-candle swing point: a bar whose high is above the bar either side of it. Higher values require a wider, more significant swing.")
raidMode = input.string("Close reclaim", "Raid confirmation",
     options = ["Close reclaim", "Wick breach"], group = gL,
     tooltip = "Close reclaim requires the raid bar to close back through the pool. Wick breach preserves the looser legacy behavior.")
raidTicks = input.int(1, "Minimum raid penetration (ticks)", minval = 1, maxval = 100, group = gL,
     tooltip = "Rejects equal highs/lows and sub-tick floating-point noise.")

gT = "Trap -> FVG"
// Default lowered from 12 to 5. The New York window is 6.5 hours, which is
// about 6 bars on the intended 1H timeframe, so a 12-bar patience window could
// never be reached there: the end-of-session reset always fired first and the
// input did nothing at the documented timeframe. 5 makes it live on 1H and it
// still behaves as a patience limit on lower timeframes.
maxWait = input.int(5, "Max bars from raid to FVG", minval = 1, maxval = 100, group = gT,
     tooltip = "How long the raid stays valid while waiting for a fair value gap. The setup is also abandoned if the session ends or the daily bias flips, whichever comes first.")
minGapK = input.float(0.10, "Min FVG size (x ATR14)", minval = 0.0, step = 0.05, group = gT)
entryOpt = input.string("Gap edge", "Entry level", options = ["Gap edge", "Gap midpoint"], group = gT)
useDisplacement = input.bool(true, "Require directional displacement candle", group = gT,
     tooltip = "The middle candle of the three-candle FVG must close in the setup direction with sufficient body efficiency.")
minDispBody = input.float(0.55, "Minimum displacement body / range", minval = 0.10, maxval = 1.0,
     step = 0.05, group = gT)

gR = "Risk"
minRR   = input.float(1.0, "Min reward:risk to arm setup", minval = 0.0, step = 0.25, group = gR)
stopBufferTicks = input.int(1, "Stop buffer beyond sweep (ticks)", minval = 0, maxval = 100, group = gR)
maxDay  = input.int(2, "Max entries per day", minval = 1, maxval = 10, group = gR,
     tooltip = "Hard circuit breaker. After this many entries in one day the indicator stops arming setups until the next day.")

gU = "Display"
showTbl  = input.bool(true, "Status table", group = gU)
showPD   = input.bool(true, "PDH / PDL", group = gU)
showWOK  = input.bool(true, "Weekly open", group = gU)
showPools = input.bool(true, "Asian / premarket levels during NY", group = gU)
showNWOG = input.bool(true, "New Week Opening Gap", group = gU)
shadeAMD = input.bool(true, "Tint manipulation zone", group = gU)
tblSize = input.string(size.small, "Table text size", options = [size.tiny, size.small, size.normal], group = gU)
tblPos = input.string(position.top_right, "Table position",
     options = [position.top_right, position.top_left, position.middle_right, position.middle_left,
                 position.bottom_right, position.bottom_left], group = gU)
cBull    = input.color(color.new(#26a69a, 0), "Bull", inline = "c", group = gU)
cBear    = input.color(color.new(#ef5350, 0), "Bear", inline = "c", group = gU)

if barstate.isfirst
    if not timeframe.isintraday or timeframe.in_seconds(timeframe.period) > 3600
        runtime.error("Daily Sweep Pro Elite requires an intraday chart timeframe of 1 hour or lower.")

//-------------------- Daily structure bias (non-repainting) --------------------
f_daily() =>
    ph = ta.pivothigh(high, dLen, dLen)
    pl = ta.pivotlow(low,  dLen, dLen)
    var float ph1 = na
    var float ph2 = na
    var float pl1 = na
    var float pl2 = na
    if not na(ph)
        ph2 := ph1
        ph1 := ph
    if not na(pl)
        pl2 := pl1
        pl1 := pl
    [ph1[1], ph2[1], pl1[1], pl2[1], high[1], low[1]]

// Lookahead is paired with a [1] offset in each case below, which is the
// documented non-repainting idiom: it returns the last COMPLETED higher
// timeframe bar rather than the one still forming. Without the offset this
// would be look-ahead bias. With it, it is the fix for look-ahead bias.
[dPH1, dPH2, dPL1, dPL2, exchangePDH, exchangePDL] = request.security(
     syminfo.tickerid, "D", f_daily(), lookahead = barmerge.lookahead_on)
// The weekly open is the one exception and it needs no offset: an open is fixed
// the instant its bar begins, so it cannot be revised later in the week and
// lookahead has nothing to reveal.
wOpen = request.security(syminfo.tickerid, "W", open,    lookahead = barmerge.lookahead_on)

int bias = 0
if not na(dPH2) and not na(dPL2)
    bias := dPH1 > dPH2 and dPL1 > dPL2 ? 1 : dPH1 < dPH2 and dPL1 < dPL2 ? -1 : 0

//-------------------- Sessions & liquidity pools --------------------
f_sessRange(s) =>
    bool inS = not na(time(timeframe.period, s, tzNY))
    var float hi = na
    var float lo = na
    var int completedAt = na
    if inS and not inS[1]
        hi := high
        lo := low
    else if inS
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    if not inS and inS[1]
        completedAt := time
    [hi, lo, completedAt]

inNY    = not na(time(timeframe.period, nySess, tzNY))
sessEnd = not inNY and inNY[1]
newNY   = inNY and not inNY[1]
inAsia  = not na(time(timeframe.period, asSess, tzNY))
inPM    = not na(time(timeframe.period, pmSess, tzNY))
newAsia = inAsia and not inAsia[1]
newPM   = inPM and not inPM[1]
[asiaHi, asiaLo, asiaCompletedAt] = f_sessRange(asSess)
[pmHi,   pmLo,   pmCompletedAt]   = f_sessRange(pmSess)

int DAY_MS = 24 * 60 * 60 * 1000
bool asiaFresh = not na(asiaCompletedAt) and time - asiaCompletedAt <= DAY_MS
bool pmFresh = not na(pmCompletedAt) and time - pmCompletedAt <= DAY_MS

// Optional RTH-style previous session levels. They freeze at the first bar of
// the next NY execution window and therefore cannot change during that window.
var float runningNYHi = na
var float runningNYLo = na
var float priorNYHi = na
var float priorNYLo = na
if newNY
    priorNYHi := runningNYHi
    priorNYLo := runningNYLo
    runningNYHi := high
    runningNYLo := low
else if inNY
    runningNYHi := na(runningNYHi) ? high : math.max(runningNYHi, high)
    runningNYLo := na(runningNYLo) ? low : math.min(runningNYLo, low)

float pdh = pdSource == "Prior NY session" ? priorNYHi : exchangePDH
float pdl = pdSource == "Prior NY session" ? priorNYLo : exchangePDL

atr14 = ta.atr(14)

iph = ta.pivothigh(high, swLen, swLen)
ipl = ta.pivotlow(low,  swLen, swLen)
var float lastSwHi = na
var float lastSwLo = na
var bool swHiConsumed = false
var bool swLoConsumed = false
if not na(iph)
    lastSwHi := iph
    swHiConsumed := false
if not na(ipl)
    lastSwLo := ipl
    swLoConsumed := false

float raidTolerance = raidTicks * syminfo.mintick
f_raidLo(pool) =>
    bool breached = not na(pool) and low <= pool - raidTolerance and low[1] > pool - raidTolerance
    breached and (raidMode == "Wick breach" or close >= pool)
f_raidHi(pool) =>
    bool breached = not na(pool) and high >= pool + raidTolerance and high[1] < pool + raidTolerance
    breached and (raidMode == "Wick breach" or close <= pool)

var bool asiaHiConsumed = false
var bool asiaLoConsumed = false
var bool pmHiConsumed = false
var bool pmLoConsumed = false
var bool pdhConsumed = false
var bool pdlConsumed = false
if newAsia
    asiaHiConsumed := false
    asiaLoConsumed := false
if newPM
    pmHiConsumed := false
    pmLoConsumed := false
if timeframe.change("D")
    pdhConsumed := false
    pdlConsumed := false

//-------------------- New Week Opening Gap --------------------
int LABEL_BUDGET = 240
int LINE_BUDGET = 120
int FVG_BOX_BUDGET = 100
int NWOG_BOX_BUDGET = 20
var array<label> eventLabels = array.new<label>()
var array<line> eventLines = array.new<line>()
var array<box> fvgBoxes = array.new<box>()
var array<box> nwogBoxes = array.new<box>()

f_keepLabel(label id) =>
    if not na(id)
        array.push(eventLabels, id)
        if array.size(eventLabels) > LABEL_BUDGET
            label.delete(array.shift(eventLabels))

f_keepLine(line id) =>
    if not na(id)
        array.push(eventLines, id)
        if array.size(eventLines) > LINE_BUDGET
            line.delete(array.shift(eventLines))

f_keepFvgBox(box id) =>
    if not na(id)
        array.push(fvgBoxes, id)
        if array.size(fvgBoxes) > FVG_BOX_BUDGET
            box.delete(array.shift(fvgBoxes))

f_keepNwogBox(box id) =>
    if not na(id)
        array.push(nwogBoxes, id)
        if array.size(nwogBoxes) > NWOG_BOX_BUDGET
            box.delete(array.shift(nwogBoxes))

var box nwog = na
if timeframe.change("W")
    // Do not continue extending a prior week's box when the new week has no gap.
    nwog := na
    if showNWOG and not na(close[1])
        float gTop = math.max(close[1], open)
        float gBot = math.min(close[1], open)
        if gTop - gBot > syminfo.mintick
            nwog := box.new(bar_index, gTop, bar_index, gBot,
                 border_color = color.new(color.silver, 40), bgcolor = color.new(color.silver, 88),
                 text = "NWOG", text_color = color.new(color.silver, 30), text_size = size.tiny)
            f_keepNwogBox(nwog)
if not na(nwog)
    box.set_right(nwog, bar_index)

//-------------------- State machine --------------------
var int    state    = 0
var int    dir      = 0
var float  sweepExt = na
var int    sweepBar = na
var string poolName = na
var int    poolCount = 0
var int    fvgBar   = na
var float  fvgTop   = na
var float  fvgBot   = na
var box    fvgBox   = na
var float  entryPx  = na
var float  stopPx   = na
var float  tgtPx    = na
var float  plannedRR = na
var line   lnStop   = na
var line   lnTgt    = na
var line   lnEnt    = na

var int tradesToday = 0
if timeframe.change("D")
    tradesToday := 0

// Descriptive loaded-history ledger. These are idealized rule outcomes, not a
// broker-executable backtest; unresolved setups are excluded.
var int ledgerEntries = 0
var int ledgerTargets = 0
var int ledgerStops = 0
var int ledgerFlats = 0
var float ledgerR = 0.0

bool evtSweep = false
bool evtFvg   = false
bool evtEntry = false
bool evtStop  = false
bool evtTgt   = false
bool evtFlat  = false
bool doReset  = false
string exitTxt = na
float exitPxNow = na
int exitBarNow = bar_index

f_addPool(string current, string nextPool) =>
    current == "" ? nextPool : current + " + " + nextPool

if barstate.isconfirmed
    if state == 3
        // Flatten at the prior in-session close before inspecting the first
        // outside-session bar. This prevents an after-hours wick from being
        // misclassified as an in-session stop or target.
        if sessEnd and closeEOD
            evtFlat := true
            exitTxt := "Flat at session end"
            exitPxNow := close[1]
            exitBarNow := bar_index - 1
            doReset := true
        else
            if dir == 1
                if low <= stopPx
                    evtStop := true
                    exitTxt := "Stop"
                    exitPxNow := stopPx
                else if high >= tgtPx
                    evtTgt := true
                    exitTxt := "Target, prior day high"
                    exitPxNow := tgtPx
            else
                if high >= stopPx
                    evtStop := true
                    exitTxt := "Stop"
                    exitPxNow := stopPx
                else if low <= tgtPx
                    evtTgt := true
                    exitTxt := "Target, prior day low"
                    exitPxNow := tgtPx
            if not na(exitTxt)
                doReset := true

    else if state == 2
        bool missed = dir == 1 ? high >= tgtPx : low <= tgtPx
        if bias != dir or sessEnd or missed
            doReset := true
        else if bar_index > fvgBar
            bool trig = dir == 1 ? low <= entryPx : high >= entryPx
            if trig
                state := 3
                evtEntry := true
                tradesToday += 1
                // Entry and invalidation on the same bar: recorded as a stop,
                // because the bar cannot prove the entry filled before the level
                // was traded through.
                if dir == 1 and low <= stopPx
                    evtStop := true
                    exitTxt := "Stop"
                    exitPxNow := stopPx
                    doReset := true
                if dir == -1 and high >= stopPx
                    evtStop := true
                    exitTxt := "Stop"
                    exitPxNow := stopPx
                    doReset := true
                // Symmetric same-bar target. A bar that touches only the target
                // records the target; a bar that touches both still records the
                // stop, because the bar cannot prove the order of events.
                if not evtStop and dir == 1 and high >= tgtPx
                    evtTgt := true
                    exitTxt := "Target, prior day high"
                    exitPxNow := tgtPx
                    doReset := true
                if not evtStop and dir == -1 and low <= tgtPx
                    evtTgt := true
                    exitTxt := "Target, prior day low"
                    exitPxNow := tgtPx
                    doReset := true

    else if state == 1
        sweepExt := dir == 1 ? math.min(sweepExt, low) : math.max(sweepExt, high)
        if bias != dir or not inNY or bar_index - sweepBar > maxWait
            doReset := true
        else
            float dispRange = high[1] - low[1]
            float dispEfficiency = dispRange > 0 ? math.abs(close[1] - open[1]) / dispRange : 0.0
            bool bullDisplacement = close[1] > open[1] and dispEfficiency >= minDispBody
            bool bearDisplacement = close[1] < open[1] and dispEfficiency >= minDispBody
            bool fvgUp = dir == 1 and low > high[2] and (low - high[2]) >= minGapK * atr14 and
                 (not useDisplacement or bullDisplacement)
            bool fvgDn = dir == -1 and high < low[2] and (low[2] - high) >= minGapK * atr14 and
                 (not useDisplacement or bearDisplacement)
            if fvgUp or fvgDn
                float top = fvgUp ? low : low[2]
                float bot = fvgUp ? high[2] : high
                float entRaw = entryOpt == "Gap midpoint" ? (top + bot) / 2 : (fvgUp ? top : bot)
                float ent = math.round_to_mintick(entRaw)
                float stopBuffer = stopBufferTicks * syminfo.mintick
                float stp = dir == 1 ? sweepExt - stopBuffer : sweepExt + stopBuffer
                float tgt = dir == 1 ? pdh : pdl
                float risk = math.abs(ent - stp)
                float rew  = dir == 1 ? tgt - ent : ent - tgt
                if risk > 0 and rew > 0 and rew / risk >= minRR
                    state   := 2
                    evtFvg  := true
                    fvgBar  := bar_index
                    fvgTop  := top
                    fvgBot  := bot
                    entryPx := ent
                    stopPx  := stp
                    tgtPx   := tgt
                    plannedRR := rew / risk
                    fvgBox  := box.new(bar_index - 2, top, bar_index, bot,
                         border_color = dir == 1 ? cBull : cBear,
                         bgcolor = color.new(dir == 1 ? cBull : cBear, 85))
                    f_keepFvgBox(fvgBox)

    else
        bool wokOK = not useWOK or (not na(wOpen) and (bias == 1 ? low < wOpen : high > wOpen))
        if inNY and bias != 0 and wokOK and tradesToday < maxDay
            bool hitSwing = false
            bool hitAsia = false
            bool hitPM = false
            bool hitPD = false
            if bias == 1
                hitSwing := useSwing and not swLoConsumed and f_raidLo(lastSwLo)
                hitAsia := useAsia and asiaFresh and not asiaLoConsumed and f_raidLo(asiaLo)
                hitPM := usePM and pmFresh and not pmLoConsumed and f_raidLo(pmLo)
                hitPD := usePD and not pdlConsumed and f_raidLo(pdl)
            else
                hitSwing := useSwing and not swHiConsumed and f_raidHi(lastSwHi)
                hitAsia := useAsia and asiaFresh and not asiaHiConsumed and f_raidHi(asiaHi)
                hitPM := usePM and pmFresh and not pmHiConsumed and f_raidHi(pmHi)
                hitPD := usePD and not pdhConsumed and f_raidHi(pdh)

            string hitPools = ""
            int hits = 0
            if hitSwing
                hitPools := f_addPool(hitPools, bias == 1 ? "swing low" : "swing high")
                hits += 1
            if hitAsia
                hitPools := f_addPool(hitPools, bias == 1 ? "Asian low" : "Asian high")
                hits += 1
            if hitPM
                hitPools := f_addPool(hitPools, bias == 1 ? "premarket low" : "premarket high")
                hits += 1
            if hitPD
                hitPools := f_addPool(hitPools, bias == 1 ? "PDL" : "PDH")
                hits += 1

            if hits > 0
                if hitSwing
                    if bias == 1
                        swLoConsumed := true
                    else
                        swHiConsumed := true
                if hitAsia
                    if bias == 1
                        asiaLoConsumed := true
                    else
                        asiaHiConsumed := true
                if hitPM
                    if bias == 1
                        pmLoConsumed := true
                    else
                        pmHiConsumed := true
                if hitPD
                    if bias == 1
                        pdlConsumed := true
                    else
                        pdhConsumed := true
                state    := 1
                dir      := bias
                sweepExt := bias == 1 ? low : high
                sweepBar := bar_index
                poolName := hitPools
                poolCount := hits
                evtSweep := true

    if evtEntry
        ledgerEntries += 1
    if evtStop
        ledgerStops += 1
        ledgerR -= 1.0
    else if evtTgt
        ledgerTargets += 1
        ledgerR += plannedRR
    else if evtFlat
        ledgerFlats += 1
        float flatRisk = math.abs(entryPx - stopPx)
        float flatR = flatRisk > 0 ? dir * (exitPxNow - entryPx) / flatRisk : 0.0
        ledgerR += flatR

//-------------------- Drawing --------------------
if barstate.isconfirmed
    if evtSweep
        label raidLabel = label.new(bar_index, dir == 1 ? low : high,
             "Raid ×" + str.tostring(poolCount) + ": " + poolName,
             style = dir == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(color.orange, 20), textcolor = color.white, size = size.small)
        f_keepLabel(raidLabel)
    if evtFvg
        label gapLabel = label.new(bar_index, dir == 1 ? fvgTop : fvgBot,
             "FVG armed · " + str.tostring(plannedRR, "0.00") + "R" +
             "\nE " + str.tostring(entryPx, format.mintick) + "  S " + str.tostring(stopPx, format.mintick) +
             "  T " + str.tostring(tgtPx, format.mintick),
             style = dir == 1 ? label.style_label_down : label.style_label_up,
             color = color.new(dir == 1 ? cBull : cBear, 30), textcolor = color.white, size = size.small)
        f_keepLabel(gapLabel)
    if evtEntry
        label entryLabel = label.new(bar_index, entryPx, dir == 1 ? "Long" : "Short",
             style = dir == 1 ? label.style_label_up : label.style_label_down,
             color = dir == 1 ? cBull : cBear, textcolor = color.white, size = size.small)
        f_keepLabel(entryLabel)
        lnEnt  := line.new(bar_index, entryPx, bar_index + 1, entryPx, color = color.gray,  width = 1)
        lnStop := line.new(bar_index, stopPx,  bar_index + 1, stopPx,  color = cBear, width = 1, style = line.style_dashed)
        lnTgt  := line.new(bar_index, tgtPx,   bar_index + 1, tgtPx,   color = cBull, width = 1, style = line.style_dashed)
        f_keepLine(lnEnt)
        f_keepLine(lnStop)
        f_keepLine(lnTgt)
    int drawingRightEdge = doReset ? exitBarNow : bar_index
    if state == 3 or (evtEntry and doReset)
        if not na(lnEnt)
            line.set_x2(lnEnt, drawingRightEdge)
            line.set_x2(lnStop, drawingRightEdge)
            line.set_x2(lnTgt, drawingRightEdge)
    if not na(fvgBox) and (state == 2 or state == 3)
        box.set_right(fvgBox, drawingRightEdge)
    if not na(exitTxt)
        label exitLabel = label.new(exitBarNow, exitPxNow, exitTxt,
             style = label.style_label_left, color = evtTgt ? cBull : evtStop ? cBear : color.gray,
             textcolor = color.white, size = size.small)
        f_keepLabel(exitLabel)
    if doReset
        state := 0
        dir := 0
        sweepExt := na
        sweepBar := na
        poolName := na
        poolCount := 0
        fvgBar := na
        fvgTop := na
        fvgBot := na
        entryPx := na
        stopPx := na
        tgtPx := na
        plannedRR := na
        fvgBox := na
        lnEnt := na
        lnStop := na
        lnTgt := na

plot(showPD ? pdh : na, "PDH", color = color.new(#26a69a, 30), style = plot.style_linebr)
plot(showPD ? pdl : na, "PDL", color = color.new(#ef5350, 30), style = plot.style_linebr)
plot(showWOK ? wOpen : na, "Weekly open", color = color.new(color.yellow, 20), style = plot.style_linebr, linewidth = 1)
plot(showPools and inNY and asiaFresh ? asiaHi : na, "Asian high", color = color.new(color.aqua, 40), style = plot.style_linebr)
plot(showPools and inNY and asiaFresh ? asiaLo : na, "Asian low",  color = color.new(color.aqua, 40), style = plot.style_linebr)
plot(showPools and inNY and pmFresh ? pmHi : na, "Premarket high", color = color.new(color.purple, 40), style = plot.style_linebr)
plot(showPools and inNY and pmFresh ? pmLo : na, "Premarket low",  color = color.new(color.purple, 40), style = plot.style_linebr)

bool manipZone = bias == -1 and close > wOpen or bias == 1 and close < wOpen
bgcolor(shadeAMD and inNY and bias != 0 and manipZone ? color.new(color.orange, 94) : na, title = "Manipulation zone")

//-------------------- Status table --------------------
// Created inside the guard rather than at top level, so switching the table off
// does not leave an empty table object allocated on every chart.
if showTbl and barstate.islast
    var table tbl = table.new(tblPos, 2, 11, border_width = 1)
    string biasTxt = bias == 1 ? "Bullish, higher highs and lows" : bias == -1 ? "Bearish, lower highs and lows" : "Neutral, no daily control"
    color  biasCol = bias == 1 ? cBull : bias == -1 ? cBear : color.gray
    string stateTxt = state == 0 ? (bias == 0 ? "No trade: no daily control" : inNY ? "Scanning for raid" : "Waiting for NY session") : state == 1 ? "Raid on " + poolName + " - waiting FVG" : state == 2 ? "Armed, waiting for pullback" : "In trade"
    string wokSide = close > wOpen ? "above" : close < wOpen ? "below" : "at"
    string wokTxt = na(wOpen) ? "-" : str.tostring(wOpen, format.mintick) + "  (" + wokSide + ")"
    string pdTxt = (na(pdh) ? "-" : str.tostring(pdh, format.mintick)) + " / " +
         (na(pdl) ? "-" : str.tostring(pdl, format.mintick))
    string poolTxt = "Asia " + (asiaFresh ? "ready" : "stale") + " · PM " + (pmFresh ? "ready" : "stale")
    string raidTxt = state >= 1 ? "×" + str.tostring(poolCount) + " · " + poolName : "-"
    string entTxt = state >= 2 ? str.tostring(entryPx, format.mintick) : "-"
    string stpTxt = state >= 2 ? str.tostring(stopPx, format.mintick) : "-"
    string tgtTxt = state >= 2 ? str.tostring(tgtPx, format.mintick) : "-"
    string rrTxt = state >= 2 and not na(plannedRR) ? str.tostring(plannedRR, "0.00") + "R" : "-"
    int decisiveOutcomes = ledgerTargets + ledgerStops
    string hitRateTxt = decisiveOutcomes > 0 ? str.tostring(math.round(100.0 * ledgerTargets / decisiveOutcomes)) + "%" : "-"
    string ledgerTxt = "T " + str.tostring(ledgerTargets) + " · S " + str.tostring(ledgerStops) +
         " · F " + str.tostring(ledgerFlats) + " · " + hitRateTxt + " · " + str.tostring(ledgerR, "0.00") + "R"
    string tfTxt = timeframe.period + " · entries " + str.tostring(tradesToday) + "/" + str.tostring(maxDay)

    table.cell(tbl, 0, 0, "Daily bias", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 0, biasTxt, text_color = color.white, bgcolor = color.new(biasCol, 20), text_size = tblSize)
    table.cell(tbl, 0, 1, "State", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 1, stateTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 2, "Weekly open", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 2, wokTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 3, "PDH / PDL", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 3, pdTxt + " · " + pdSource, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 4, "Pool health", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 4, poolTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 5, "Raid confluence", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 5, raidTxt, text_color = color.orange, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 6, "Entry", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 6, entTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 7, "Stop / Target", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 7, stpTxt + " / " + tgtTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 8, "Planned R:R", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 8, rrTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 9, "Loaded outcomes", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize,
         tooltip = "Idealized rule outcomes on loaded bars. T=target, S=stop, F=session flat. No spread, slippage, commission, or intrabar path reconstruction.")
    table.cell(tbl, 1, 9, ledgerTxt, text_color = ledgerR >= 0 ? cBull : cBear, bgcolor = color.new(color.black, 40), text_size = tblSize)
    table.cell(tbl, 0, 10, "Execution", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = tblSize)
    table.cell(tbl, 1, 10, tfTxt, text_color = color.white, bgcolor = color.new(color.black, 40), text_size = tblSize)

//-------------------- Alerts --------------------
alertcondition(evtSweep, "1. Liquidity raid", "Liquidity pool raided against the daily bias")
alertcondition(evtFvg,   "2. FVG confirmed",  "Fair value gap confirmed, setup armed")
alertcondition(evtEntry, "3. Entry triggered","Pullback into the fair value gap, entry triggered")
alertcondition(evtTgt,   "4. Target hit",     "Prior-day level reached")
alertcondition(evtStop,  "5. Stop hit",       "Invalidation traded through")
alertcondition(barstate.isconfirmed and ta.change(bias) != 0, "Daily bias changed", "Daily structure bias changed")
// The end-of-session flat produced a chart label but no alert, so a webhook user
// would see the entry and never see this exit. Added for parity.
alertcondition(evtFlat, "6. Flat at session end", "Open setup closed out at the end of the session")
````
