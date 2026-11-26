# Value Area Acceptance Engine [PhenLabs]

- url: https://www.tradingview.com/script/JWZj0b8O-Value-Area-Acceptance-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;8d03d076af474613b27ecf1188d8d572
- version: 1.0

## Description

📊 Value Area Acceptance Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
Value Area Acceptance Engine answers one question at the open of every session: is price being accepted outside yesterday’s value, or is the move a failed auction that will rotate back through it? It builds a time-at-price value area (VAL, VAH and POC) for each session, then watches how price behaves against the PRIOR session’s value using closed bars only.

Because the profile is built from time (how many bars traded at each price row) and not from volume, it works the same way on forex, indices, crypto, futures and stocks, and it works on every TradingView plan. No footprint data, no intrabar requests, no paid data feed.

When a setup appears the script marks it once, draws one clean trade plan (entry, stop, T1, T2) and tells you in the dashboard whether the setup is a TAKE or a SKIP based on how much room is left to the first target.

🚀 Points of Innovation
[list]
[*]Acceptance is measured in TIME, not volume: price must keep closing outside the prior value area for a set number of minutes, automatically converted to bars on any chart timeframe
[*]Failed-auction detection: a short excursion outside prior value that closes back inside before acceptance is marked as a rotation setup back toward the POC and the opposite edge
[*]Value-migration gate: acceptance only fires when the developing POC has moved past the prior POC in the breakout direction
[*]TAKE / SKIP verdict on every setup, using distance to T1 measured in R, so late breakouts are flagged instead of chased
[*]Volume-free by design: works on symbols where volume is synthetic or missing, and on free plans
[*]Zero drawing objects for the levels: prior VAH, VAL and POC are plotted lines, so history stays light and always attached to price
[/list]

🔧 Core Components
[list]
[*]Time-at-price profile: every confirmed bar adds one unit of time to each price row it touched. Rows are sliced from the previous session’s range, so the grid adapts to the instrument
[*]Value area engine: starting at the POC row, the area expands toward the heavier side until the chosen percentage of total time is covered
[*]Auction state machine: tracks probing, accepted and failed excursions above and below the prior value area, once per direction per session
[*]Trade plan builder: acceptance setups use the prior value edge and its width for stop and targets; failed-auction setups use the excursion extreme for the stop and the prior POC and opposite edge as targets
[*]Dashboard: one compact panel with mode, prior value, POC, open location, auction state, value migration, live setup and since-load T1 hit counts
[/list]

🔥 Key Features
[list]
[*]Prior-session VAH, VAL and POC drawn as clean lines with a soft value-area fill, broken at each new session
[*]Two signal families: Acceptance (A) and Failed Auction (F), with bull and bear versions of each
[*]One live trade plan at a time, drawn with short lines so price stays readable
[*]SKIP setups are shown as small muted circles instead of full markers
[*]Six alert conditions: bullish, bearish, acceptance above, acceptance below, failed auction below, failed auction above
[*]Pine Screener compatible through three data-window plots
[*]Automatic period step-up (Day to Week to Month) when the chart timeframe is too coarse, with the active period shown in the dashboard
[/list]

🎨 Visualization
[list]
[*]Grey-blue lines and fill: the prior value area. The dotted heavier line is the prior POC
[*]Teal triangle marked A below a bar: bullish acceptance. Pink triangle marked A above a bar: bearish acceptance
[*]Teal diamond marked F below a bar: bullish failed auction (rotation up). Pink diamond marked F above a bar: bearish failed auction (rotation down)
[*]Small muted circle: a signal that qualifies as SKIP because the reward to T1 is below your minimum R
[*]Dashed pink line: stop. Dashed teal line: T1. Dotted teal line: T2. Solid grey line: entry
[*]Optional histogram at the right edge: the developing time-at-price profile, with the value area and POC row shaded
[/list]

📖 Usage Guidelines
Value Profile
[list]
[*][b]Profile period[/b] — Default: Day — Options: Day, Week, Month — Session used to build each value area. Steps up automatically if the chart timeframe is too coarse
[*][b]Value area %[/b] — Default: 70 — Range: 50-90 — Share of the session’s time-at-price that defines the value area
[*][b]Rows per prior range[/b] — Default: 40 — Range: 20-80 — Number of rows used to slice the previous session’s range. Higher gives a finer profile
[/list]
Signals
[list]
[*][b]Acceptance time (minutes)[/b] — Default: 60 — Range: 10-480 — Time price must keep closing outside prior value to count as accepted. Converted to bars, minimum 2 bars
[*][b]Require value migration[/b] — Default: On — Acceptance fires only if the developing POC has passed the prior POC in the breakout direction. Turn off for earlier, more frequent acceptance signals
[/list]
Trade Plan
[list]
[*][b]Show live trade plan[/b] — Default: On — Draws entry, stop, T1 and T2 for the active TAKE setup
[*][b]Min R to T1 for TAKE[/b] — Default: 1.0 — Range: 0.25-5.0 — Setups with less than this reward to T1 are marked SKIP. Only active while the trade plan is on
[/list]
Display
[list]
[*][b]Prior value area and POC[/b] — Default: On — Shows the prior VAH, VAL, POC and fill
[*][b]Live time-at-price profile[/b] — Default: Off — Shows the developing profile histogram at the right edge
[*][b]Profile width (bars)[/b] — Default: 20 — Range: 8-60 — Width of the histogram. Only active while the profile is on
[*][b]Dashboard[/b] — Default: On — Shows the panel at top right
[*][b]Table size[/b] — Default: Small — Options: Tiny, Small, Normal — Dashboard text size
[/list]
Colors
[list]
[*][b]Bull / Bear[/b] — Default: teal / pink — Signal, plan and dashboard colors
[/list]

✅ Best Use Cases
[list]
[*]Deciding at the open whether a break of yesterday’s value is worth following or fading
[*]Filtering late breakouts with the TAKE / SKIP verdict
[*]Finding rotation trades back to the POC after a failed probe outside value
[*]Scanning a watchlist for symbols that are probing or accepted outside value with Pine Screener
[*]Instruments where volume is unreliable: forex, cash indices, some crypto pairs
[/list]

⚠️ Limitations
[list]
[*]Built for intraday charts. If the chart timeframe is too coarse for the chosen period, the script steps up to a longer period. On weekly and higher charts it shows a notice instead of signals
[*]The first loaded session is partial, so no prior value area exists until the second session begins. Loaded history depth also limits the since-load counts
[*]A session with fewer than 8 bars produces no value area, so no signals follow it
[*]Time-at-price treats every bar equally. It does not know how much volume traded, only how long price spent at each level
[*]Price moving more than roughly 15 times the previous session’s range from the open compresses into edge rows
[*]The since-load T1 hit counts are descriptive and depend on how much history is loaded. They are not a backtest and not evidence of future results
[/list]

💡 What Makes This Unique
[list]
[*]Time-based acceptance: most auction tools count volume or use a fixed opening window. This one asks how long price has actually been accepted outside value
[*]Acceptance and failure in one state machine: continuation and rotation setups come from the same prior value area, so you see both sides of the decision
[*]A verdict, not just a marker: every setup is graded TAKE or SKIP by its distance to T1 in R
[*]No plan gating: identical output on Basic, Essential, Plus, Premium and Ultimate
[/list]

⚙️ Under the Hood
[list]
[*][b]Integer time-at-price array[/b]: a preallocated int array indexed by price row holds the developing profile. Each confirmed bar increments every row between its low and high, and the POC is updated incrementally with a nearest-to-close tie-break, so no per-bar full scan is needed
[*][b]Bounded value-area expansion[/b]: a pure function grows the area from the POC toward the heavier two-row side, with a hard loop bound and an early break once the target share is covered. It runs once per session, and once more on the last bar only when the optional histogram is on
[*][b]Time-to-bars conversion[/b]: timeframe.in_seconds() turns the acceptance minutes into a bar count on any chart timeframe, and timeframe.change() drives session boundaries for the selected period, so one setting behaves the same on 1 minute and 1 hour charts
[*][b]input.enum with active parameters[/b]: enum selectors for period and table size, and dependent inputs that gray out until their parent toggle is on, keep the panel to 14 inputs
[*][b]Confirmed-bar state machine[/b]: all state changes are gated with barstate.isconfirmed. There are no request.* calls, so there is no lookahead and no repaint. The prior levels are plotted as line-break plots, which keeps them attached to price and avoids drawing-object limits
[*][b]Data mode / plan note[/b]: nothing here is plan-gated. The only fallback is the automatic period step-up, and the dashboard Mode row shows the active period
[*][b]Screener and alerts[/b]: data-window plots Signal (1 acceptance up, -1 acceptance down, 2 failed auction below value, -2 failed auction above value), Auction state (2 or -2 accepted, 1 or -1 probing) and Distance to prior POC % can be used as Pine Screener columns. Six alertconditions cover bullish, bearish, acceptance and failed-auction events
[/list]

🔬 How It Works
[list=1]
[*]Profile: at each session start the previous session is finalized into a value area (VAL, VAH) and POC, and a fresh time-at-price array is seeded using rows sized from the previous range
[*]Reference: the prior VAL, VAH and POC become the reference levels for the whole new session
[*]Track: each confirmed close counts as inside, above or below the prior value area. Consecutive closes outside build an excursion, and the highest or lowest point of the excursion is stored
[*]Accept: when an excursion reaches the acceptance time and value has migrated the same way, an Acceptance signal fires once for that direction
[*]Fail: when an excursion ends with a close back inside value before acceptance was reached, a Failed Auction signal fires once for the opposite direction
[*]Plan: the script builds entry, stop, T1 and T2, grades the setup TAKE or SKIP by distance to T1 in R, then follows it until stop, T2 or session end. If a bar touches both stop and target, the stop is assumed to hit first
[/list]

[quote]💡 Note:
Signals appear on the bar that closes the condition and never move afterward. The dashboard reads from the last closed bar. Start with the defaults, then adjust acceptance time for your market: shorter for fast intraday charts, longer for slower ones. This tool is an analytical aid and is not financial advice. Always use your own risk management.
[/quote]

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Value Area Acceptance Engine [PhenLabs]
// Volume-free time-at-price (TPO-style) value area, acceptance / failed-auction
// state machine and a single live trade plan. Works on any symbol and any plan.
// Non-repainting: every state change happens on a confirmed bar close only.
// Analytical aid, not financial advice.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Value Area Acceptance Engine [PhenLabs]", shorttitle = "PhenLabs VAAE", overlay = true, max_lines_count = 50, max_labels_count = 50, max_boxes_count = 100)

// ── Enums ────────────────────────────────────────────────────────────────────
enum PeriodMode
    day   = "Day"
    week  = "Week"
    month = "Month"

enum TableSz
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"

// ── Inputs (14) ──────────────────────────────────────────────────────────────
GRP_V = "Value Profile"
periodMode = input.enum(PeriodMode.day, "Profile period", group = GRP_V, tooltip = "Session that builds each value area. If the chart timeframe is too coarse for it, the script steps up to Week, then Month, and the dashboard shows the active period.")
vaPct      = input.int(70, "Value area %", minval = 50, maxval = 90, group = GRP_V, tooltip = "Share of the session's time-at-price that defines the value area (70 is the classic setting).")
rowsTarget = input.int(40, "Rows per prior range", minval = 20, maxval = 80, group = GRP_V, tooltip = "Price rows used to slice the previous session's range. Higher = finer profile.")

GRP_S = "Signals"
accMinutes    = input.int(60, "Acceptance time (minutes)", minval = 10, maxval = 480, group = GRP_S, tooltip = "How long price must keep CLOSING outside the prior value area before it counts as accepted. Converted to bars for any timeframe (minimum 2 bars).")
needMigration = input.bool(true, "Require value migration", group = GRP_S, tooltip = "Acceptance signals only fire when today's developing POC has moved past the prior POC in the breakout direction.")

GRP_P = "Trade Plan"
showPlan = input.bool(true, "Show live trade plan", group = GRP_P, tooltip = "Draws entry / stop / T1 / T2 for the one active TAKE setup.")
minR     = input.float(1.0, "Min R to T1 for TAKE", minval = 0.25, maxval = 5.0, step = 0.25, group = GRP_P, active = showPlan, tooltip = "Setups whose distance to T1 is smaller than this many R are marked SKIP (late or poor reward).")

GRP_D = "Display"
showLevels  = input.bool(true, "Prior value area and POC", group = GRP_D)
showProfile = input.bool(false, "Live time-at-price profile", group = GRP_D, tooltip = "Histogram of the developing session at the right edge. Off by default to keep price clean.")
profWidth   = input.int(20, "Profile width (bars)", minval = 8, maxval = 60, group = GRP_D, active = showProfile)
showDash    = input.bool(true, "Dashboard", group = GRP_D)
tblSize     = input.enum(TableSz.small, "Table size", group = GRP_D, active = showDash)

GRP_C = "Colors"
bullCol = input.color(#12B5A0, "Bull", group = GRP_C)
bearCol = input.color(#F0517D, "Bear", group = GRP_C)
neuCol  = #8A94A6

// ── Constants ────────────────────────────────────────────────────────────────
NROWS  = 1200
OFF    = 600
MINBARS = 8

// ── Pure helpers ─────────────────────────────────────────────────────────────
f_row(float price, float base, float step, int off, int maxIdx) =>
    int raw = int(math.floor((price - base) / step)) + off
    math.max(0, math.min(maxIdx, raw))

// Value area by expanding from the POC row toward the heavier side until vaPct of total time is covered
f_va(array<int> arr, int pocIdx, int loIdx, int hiIdx, float pct) =>
    int total = 0
    for i = loIdx to hiIdx
        total += array.get(arr, i)
    float target = total * pct / 100.0
    int a = pocIdx
    int b = pocIdx
    int acc = array.get(arr, pocIdx)
    for k = 1 to hiIdx - loIdx + 1
        if acc >= target
            break
        if b >= hiIdx and a <= loIdx
            break
        int up1 = b + 1 <= hiIdx ? array.get(arr, b + 1) : 0
        int up2 = b + 2 <= hiIdx ? array.get(arr, b + 2) : 0
        int dn1 = a - 1 >= loIdx ? array.get(arr, a - 1) : 0
        int dn2 = a - 2 >= loIdx ? array.get(arr, a - 2) : 0
        if (up1 + up2 >= dn1 + dn2 and b < hiIdx) or a <= loIdx
            b += 1
            acc += up1
        else
            a -= 1
            acc += dn1
    [a, b]

f_px(float x) =>
    na(x) ? "-" : str.tostring(x, format.mintick)

f_rate(int w, int l, int x) =>
    (w + l) > 0 ? str.tostring(w) + "/" + str.tostring(w + l) + " T1 hit" + (x > 0 ? " (" + str.tostring(x) + " exp)" : "") : "n/a"

// ── Period selection (with graceful step-up) ─────────────────────────────────
int chartSec = timeframe.in_seconds()
int selP = periodMode == PeriodMode.day ? 0 : periodMode == PeriodMode.week ? 1 : 2
int effP = (selP <= 0 and chartSec * 8 <= 86400) ? 0 : (selP <= 1 and chartSec * 8 <= 604800) ? 1 : 2
bool tfUnsupported = chartSec * 8 > 2592000
bool nD = timeframe.change("D")
bool nW = timeframe.change("W")
bool nM = timeframe.change("M")
bool newPeriod = effP == 0 ? nD : effP == 1 ? nW : nM
int accBars = math.max(2, math.ceil(accMinutes * 60.0 / chartSec))

// ── State ────────────────────────────────────────────────────────────────────
var array<int> tpoCnt = array.new_int(NROWS, 0)
var float rs = na
var float baseP = na
var int loI = -1
var int hiI = -1
var int pocI = -1
var int maxC = 0
var int sessBars = 0
var bool sessFull = false
var float sessHi = na
var float sessLo = na

var float pVAH = na
var float pVAL = na
var float pPOC = na

var int aboveRun = 0
var int belowRun = 0
var float runHi = na
var float runLo = na
var bool acceptedUp = false
var bool acceptedDn = false
var bool accUpDone = false
var bool accDnDone = false
var bool failUpDone = false
var bool failDnDone = false
var string lastEvt = "-"

var int stDir = 0
var int stType = 0
var float stEntry = na
var float stStop = na
var float stT1 = na
var float stT2 = na
var int stBar = 0
var bool stTake = false
var bool stT1Hit = false
var float stR1 = na

var int accW = 0
var int accL = 0
var int accX = 0
var int failW = 0
var int failL = 0
var int failX = 0

bool bullAccS = false
bool bearAccS = false
bool bullFailS = false
bool bearFailS = false
bool takeNow = false

// ── Core: confirmed bars only ────────────────────────────────────────────────
if barstate.isconfirmed and not tfUnsupported
    // 1) session boundary: finalize previous session, reset, seed the new one
    if newPeriod or barstate.isfirst
        if sessFull and sessBars >= MINBARS and loI >= 0 and pocI >= 0 and not na(rs)
            [vLo, vHi] = f_va(tpoCnt, pocI, loI, hiI, vaPct)
            pVAL := baseP + (vLo - OFF) * rs
            pVAH := baseP + (vHi - OFF + 1) * rs
            pPOC := baseP + (pocI - OFF + 0.5) * rs
        else
            pVAL := na
            pVAH := na
            pPOC := na
        if stDir != 0 and stTake and not stT1Hit
            if stType == 1
                accX += 1
            else
                failX += 1
        stDir := 0
        float priorRange = sessHi - sessLo
        float newRs = not na(priorRange) and priorRange > 0 ? priorRange / rowsTarget : (high - low) * 3
        rs := math.max(syminfo.mintick, newRs)
        if loI >= 0
            for i = loI to hiI
                array.set(tpoCnt, i, 0)
        baseP := open
        loI := -1
        hiI := -1
        pocI := -1
        maxC := 0
        sessBars := 0
        sessHi := na
        sessLo := na
        sessFull := not barstate.isfirst
        aboveRun := 0
        belowRun := 0
        acceptedUp := false
        acceptedDn := false
        accUpDone := false
        accDnDone := false
        failUpDone := false
        failDnDone := false
        lastEvt := "-"

    // 2) accumulate this bar's time-at-price (each row touched gets +1)
    int rLo = f_row(low, baseP, rs, OFF, NROWS - 1)
    int rHi = f_row(high, baseP, rs, OFF, NROWS - 1)
    for i = rLo to rHi
        int v = array.get(tpoCnt, i) + 1
        array.set(tpoCnt, i, v)
        float mid = baseP + (i - OFF + 0.5) * rs
        if pocI < 0 or v > maxC or (v == maxC and math.abs(mid - close) < math.abs(baseP + (pocI - OFF + 0.5) * rs - close))
            maxC := v
            pocI := i
    loI := loI < 0 ? rLo : math.min(loI, rLo)
    hiI := hiI < 0 ? rHi : math.max(hiI, rHi)
    sessBars += 1
    sessHi := na(sessHi) ? high : math.max(sessHi, high)
    sessLo := na(sessLo) ? low : math.min(sessLo, low)

    // 3) progress the active setup (stop is checked first: conservative)
    if stDir != 0 and bar_index > stBar
        bool hitStop = stDir == 1 ? low <= stStop : high >= stStop
        bool hitT1 = stDir == 1 ? high >= stT1 : low <= stT1
        bool hitT2 = stDir == 1 ? high >= stT2 : low <= stT2
        if hitStop
            if stTake and not stT1Hit
                if stType == 1
                    accL += 1
                else
                    failL += 1
            stDir := 0
        else
            if hitT1 and not stT1Hit
                stT1Hit := true
                if stTake
                    if stType == 1
                        accW += 1
                    else
                        failW += 1
            if hitT2
                stDir := 0

    // 4) acceptance / failed-auction state machine against the PRIOR value area
    bool hasPrior = not na(pVAH) and not na(pVAL) and pVAH > pVAL and not na(pPOC)
    if hasPrior
        float w = pVAH - pVAL
        bool aboveNow = close > pVAH
        bool belowNow = close < pVAL
        bool insideNow = not aboveNow and not belowNow
        int prevAbove = aboveRun
        int prevBelow = belowRun
        aboveRun := aboveNow ? aboveRun + 1 : 0
        belowRun := belowNow ? belowRun + 1 : 0
        if aboveNow
            runHi := aboveRun == 1 ? high : math.max(runHi, high)
        if belowNow
            runLo := belowRun == 1 ? low : math.min(runLo, low)
        if aboveRun >= accBars
            acceptedUp := true
        if belowRun >= accBars
            acceptedDn := true
        float dPoc = pocI >= 0 ? baseP + (pocI - OFF + 0.5) * rs : na
        bool migUp = not needMigration or (not na(dPoc) and dPoc > pPOC)
        bool migDn = not needMigration or (not na(dPoc) and dPoc < pPOC)

        // acceptance: enough time spent closing outside, value moving with it
        if aboveRun >= accBars and not accUpDone and migUp
            accUpDone := true
            bullAccS := true
        if belowRun >= accBars and not accDnDone and migDn
            accDnDone := true
            bearAccS := true
        // failed auction: short excursion outside, close back inside, acceptance never reached
        if insideNow and prevAbove > 0 and prevAbove < accBars and not acceptedUp and not failUpDone
            failUpDone := true
            bearFailS := true
        if insideNow and prevBelow > 0 and prevBelow < accBars and not acceptedDn and not failDnDone
            failDnDone := true
            bullFailS := true

        // 5) build the plan for the new signal (at most one signal per bar by construction)
        if bullAccS or bearAccS or bullFailS or bearFailS
            int d = (bullAccS or bullFailS) ? 1 : -1
            int ty = (bullAccS or bearAccS) ? 1 : 2
            float ent = close
            float stp = na
            float t1 = na
            float t2 = na
            if ty == 1
                stp := d == 1 ? pVAH - 0.25 * w : pVAL + 0.25 * w
                t1 := d == 1 ? pVAH + 0.5 * w : pVAL - 0.5 * w
                t2 := d == 1 ? pVAH + w : pVAL - w
            else
                stp := d == 1 ? math.min(runLo, low) - rs : math.max(runHi, high) + rs
                t1 := pPOC
                t2 := d == 1 ? pVAH : pVAL
            float risk = math.abs(ent - stp)
            float r1 = risk > 0 ? (d == 1 ? t1 - ent : ent - t1) / risk : na
            bool take = not na(r1) and r1 >= minR
            takeNow := take
            if stDir != 0 and stTake and not stT1Hit
                if stType == 1
                    accX += 1
                else
                    failX += 1
            stDir := d
            stType := ty
            stEntry := ent
            stStop := stp
            stT1 := t1
            stT2 := t2
            stBar := bar_index
            stTake := take
            stT1Hit := false
            stR1 := r1
            lastEvt := (ty == 1 ? "Acceptance " : "Failed auction ") + (d == 1 ? "(bull)" : "(bear)")

// ── Plots (levels break at each new session; zero drawing objects) ───────────
plotVAH = plot(showLevels and not newPeriod ? pVAH : na, "Prior VAH", color = color.new(neuCol, 25), linewidth = 1, style = plot.style_linebr)
plotVAL = plot(showLevels and not newPeriod ? pVAL : na, "Prior VAL", color = color.new(neuCol, 25), linewidth = 1, style = plot.style_linebr)
plot(showLevels and not newPeriod ? pPOC : na, "Prior POC", color = color.new(neuCol, 0), linewidth = 2, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
fill(plotVAH, plotVAL, color = color.new(neuCol, 90), title = "Prior value area")

// Signal markers sit outside the candles (below for bull, above for bear)
plotshape(bullAccS and takeNow, "Bull acceptance", shape.triangleup, location.belowbar, bullCol, size = size.tiny, text = "A", textcolor = bullCol)
plotshape(bearAccS and takeNow, "Bear acceptance", shape.triangledown, location.abovebar, bearCol, size = size.tiny, text = "A", textcolor = bearCol)
plotshape(bullFailS and takeNow, "Bull failed auction", shape.diamond, location.belowbar, bullCol, size = size.tiny, text = "F", textcolor = bullCol)
plotshape(bearFailS and takeNow, "Bear failed auction", shape.diamond, location.abovebar, bearCol, size = size.tiny, text = "F", textcolor = bearCol)
plotshape((bullAccS or bullFailS) and not takeNow, "Bull SKIP", shape.circle, location.belowbar, color.new(neuCol, 30), size = size.tiny)
plotshape((bearAccS or bearFailS) and not takeNow, "Bear SKIP", shape.circle, location.abovebar, color.new(neuCol, 30), size = size.tiny)

// Pine Screener / Data Window columns
int sigCode = bullAccS ? 1 : bearAccS ? -1 : bullFailS ? 2 : bearFailS ? -2 : 0
int stateCode = aboveRun > 0 ? (acceptedUp ? 2 : 1) : belowRun > 0 ? (acceptedDn ? -2 : -1) : 0
plot(sigCode, "Signal (1 acc up, -1 acc dn, 2 failed dn, -2 failed up)", display = display.data_window)
plot(stateCode, "Auction state (2/-2 accepted, 1/-1 probing)", display = display.data_window)
plot(not na(pPOC) ? (close - pPOC) / pPOC * 100.0 : na, "Distance to prior POC %", display = display.data_window)

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(bullAccS or bullFailS, "VAAE: Bullish signal", "PhenLabs VAAE: bullish acceptance or failed auction on {{ticker}} ({{interval}}). Check the dashboard for TAKE / SKIP.")
alertcondition(bearAccS or bearFailS, "VAAE: Bearish signal", "PhenLabs VAAE: bearish acceptance or failed auction on {{ticker}} ({{interval}}). Check the dashboard for TAKE / SKIP.")
alertcondition(bullAccS, "VAAE: Acceptance above value", "PhenLabs VAAE: price accepted above the prior value area on {{ticker}} ({{interval}}).")
alertcondition(bearAccS, "VAAE: Acceptance below value", "PhenLabs VAAE: price accepted below the prior value area on {{ticker}} ({{interval}}).")
alertcondition(bullFailS, "VAAE: Failed auction below value", "PhenLabs VAAE: failed auction below prior value, back inside on {{ticker}} ({{interval}}).")
alertcondition(bearFailS, "VAAE: Failed auction above value", "PhenLabs VAAE: failed auction above prior value, back inside on {{ticker}} ({{interval}}).")

// ── Live visuals (last bar only, capped objects) ─────────────────────────────
string tblSz = tblSize == TableSz.tiny ? size.tiny : tblSize == TableSz.small ? size.small : size.normal
var table dash = table.new(position.top_right, 2, 9, bgcolor = color.new(#0F1420, 12), frame_color = color.new(neuCol, 60), frame_width = 1, border_width = 0)
var array<box> profBoxes = array.new<box>()
var line lnE = na
var line lnS = na
var line lnT1 = na
var line lnT2 = na
var label lbS = na
var label lbT1 = na
var label lbT2 = na

if barstate.islast
    // trade plan: one focal setup, short rays
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT1)
    line.delete(lnT2)
    label.delete(lbS)
    label.delete(lbT1)
    label.delete(lbT2)
    if showPlan and stDir != 0 and stTake
        int x2 = bar_index + 6
        int x1 = math.max(stBar, bar_index - 40)
        lnE := line.new(x1, stEntry, x2, stEntry, xloc.bar_index, extend.none, color.new(neuCol, 10), line.style_solid, 1)
        lnS := line.new(x1, stStop, x2, stStop, xloc.bar_index, extend.none, bearCol, line.style_dashed, 1)
        lnT1 := line.new(x1, stT1, x2, stT1, xloc.bar_index, extend.none, bullCol, line.style_dashed, 1)
        lnT2 := line.new(x1, stT2, x2, stT2, xloc.bar_index, extend.none, bullCol, line.style_dotted, 1)
        lbS := label.new(x2, stStop, "Stop", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, bearCol, size.tiny)
        lbT1 := label.new(x2, stT1, "T1", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, bullCol, size.tiny)
        lbT2 := label.new(x2, stT2, "T2", xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, bullCol, size.tiny)

    // optional developing time-at-price histogram (<= 40 boxes)
    for bx in profBoxes
        box.delete(bx)
    array.clear(profBoxes)
    if showProfile and loI >= 0 and pocI >= 0 and not na(rs) and not tfUnsupported
        int span = hiI - loI + 1
        int binN = math.max(1, math.ceil(span / 40.0))
        [dLo, dHi] = f_va(tpoCnt, pocI, loI, hiI, vaPct)
        int maxSum = 1
        for i = loI to hiI by binN
            int s = 0
            for j = i to math.min(i + binN - 1, hiI)
                s += array.get(tpoCnt, j)
            maxSum := math.max(maxSum, s)
        for i = loI to hiI by binN
            int iEnd = math.min(i + binN - 1, hiI)
            int s = 0
            for j = i to iEnd
                s += array.get(tpoCnt, j)
            bool inVA = iEnd >= dLo and i <= dHi
            bool hasPoc = pocI >= i and pocI <= iEnd
            color fillC = hasPoc ? color.new(neuCol, 20) : inVA ? color.new(neuCol, 55) : color.new(neuCol, 82)
            int left = bar_index + 3
            int right = left + math.max(1, math.round(profWidth * s / maxSum))
            float topP = baseP + (iEnd - OFF + 1) * rs
            float botP = baseP + (i - OFF) * rs
            array.push(profBoxes, box.new(left, topP, right, botP, color(na), 0, line.style_solid, extend.none, xloc.bar_index, fillC))

    // dashboard
    if showDash
        bool hasP = not na(pVAH) and not na(pVAL) and not na(pPOC)
        string perName = effP == 0 ? "Day" : effP == 1 ? "Week" : "Month"
        string modeTxt = tfUnsupported ? "Chart timeframe too high" : perName + (effP != selP ? " (stepped up)" : "") + " | " + str.tostring(accBars) + " bars = accept"
        string openLoc = not hasP ? "-" : baseP > pVAH ? "Above value" : baseP < pVAL ? "Below value" : "Inside value"
        string auction = not hasP ? "Building first profile" : aboveRun > 0 ? (acceptedUp ? "Accepted above" : "Probing above " + str.tostring(aboveRun) + "/" + str.tostring(accBars)) : belowRun > 0 ? (acceptedDn ? "Accepted below" : "Probing below " + str.tostring(belowRun) + "/" + str.tostring(accBars)) : "Rotational, inside value"
        color auctionCol = aboveRun > 0 ? bullCol : belowRun > 0 ? bearCol : neuCol
        float dPocD = pocI >= 0 ? baseP + (pocI - OFF + 0.5) * rs : na
        string migTxt = not hasP or na(dPocD) ? "-" : dPocD > pVAH ? "Up, POC above prior value" : dPocD < pVAL ? "Down, POC below prior value" : dPocD > pPOC ? "Up, POC above prior POC" : dPocD < pPOC ? "Down, POC below prior POC" : "Flat"
        color migCol = na(dPocD) or not hasP ? neuCol : dPocD > pPOC ? bullCol : dPocD < pPOC ? bearCol : neuCol
        string planTxt = stDir == 0 ? "None" : (stDir == 1 ? "Long " : "Short ") + (stType == 1 ? "acceptance" : "failed auction") + " | " + (stTake ? "TAKE " : "SKIP ") + (na(stR1) ? "" : str.tostring(stR1, "#.0") + "R to T1")
        color planCol = stDir == 0 ? neuCol : stDir == 1 ? bullCol : bearCol
        color txtC = #E6EAF2
        table.cell(dash, 0, 0, "Value Area Acceptance", text_color = txtC, text_halign = text.align_left, text_size = tblSz, text_formatting = text.format_bold)
        table.cell(dash, 1, 0, "PhenLabs", text_color = neuCol, text_halign = text.align_right, text_size = tblSz)
        table.cell(dash, 0, 1, "Mode", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 1, modeTxt, text_color = txtC, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 0, 2, "Prior value", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 2, f_px(pVAL) + " - " + f_px(pVAH), text_color = txtC, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 0, 3, "Prior POC", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 3, f_px(pPOC), text_color = txtC, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 0, 4, "Open vs value", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 4, openLoc, text_color = txtC, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 0, 5, "Auction", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 5, auction, text_color = auctionCol, text_halign = text.align_left, text_size = tblSz, text_formatting = text.format_bold)
        table.cell(dash, 0, 6, "Value migration", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 6, migTxt, text_color = migCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 0, 7, "Live setup", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 7, planTxt + (lastEvt != "-" ? "  [" + lastEvt + "]" : ""), text_color = planCol, text_halign = text.align_left, text_size = tblSz, text_formatting = text.format_bold)
        table.cell(dash, 0, 8, "Since load", text_color = neuCol, text_halign = text.align_left, text_size = tblSz)
        table.cell(dash, 1, 8, "Acc " + f_rate(accW, accL, accX) + " | Fail " + f_rate(failW, failL, failX), text_color = txtC, text_halign = text.align_left, text_size = tblSz)
````
