# Supply & Demand Zones - Retest Record [FEELS]

- url: https://www.tradingview.com/script/T33xvDu7-Supply-Demand-Zones-Retest-Record-FEELS/
- type: indicator
- pine_id: PUB;91db2faa11ac4834b0b058dda2fb3c9f
- version: 2.0

## Description

Draws supply and demand zones, then keeps score of what each one actually did when price came back to it.

Most zone scripts print a "held %" and stop there, with nothing to compare it against. Here every zone on your chart is split by how fast price returned to it, and the two groups are shown side by side.

On Bitcoin daily, zones that were retested within three bars held 69% of the time. Zones that were revisited later held 49%. That second number is the useful one: a stale zone breaks more often than it holds, and it is the one most people are still trading.

[b]WHAT A ZONE IS, IF THE TERM IS NEW[/b]

A zone is a spot price shot away from. Not drifted away from, shot away from.

The reasoning behind the idea is that somebody large was buying or selling there and did not finish. A demand zone below price is where buyers stepped in hard; a supply zone above price is where sellers did. If price comes back, whoever was unfinished is supposed to still be there, and price is supposed to turn again. So a zone is read as support or resistance, not as a target.

That is the theory. The measurement in this script says it is true for a while and then stops being true. When price comes straight back the move that made the zone is still running and it holds two times in three. Weeks later it holds less than half the time, which is worse than a coin. Whoever was buying there has finished, or changed their mind, and all that is left is a rectangle on a chart.

[b]WHAT IT DRAWS[/b]

- Supply and demand zones from quiet bases that price left with an impulse
- A dot on every retest: held or broke through
- A running record on each zone once it has enough tests to mean anything
- Broken zones stay on the chart as a dashed outline, cut off at the bar that broke them
- A panel with the fast-versus-late split measured on the symbol you are looking at
- Three alerts: zone formed, zone held a retest, zone broken

[b]HOW IT WORKS[/b]

A zone starts as a run of quiet candles. If price then leaves that base by more than a set multiple of ATR within a few bars, the base becomes a zone. The box is drawn over the candles it was built from, not from the impulse onward.

From then on the zone is followed bar by bar. When price re-enters it a test opens, and that test resolves one of two ways: price moves back away from the zone by one ATR, which counts as held, or it cuts through the far edge, which breaks the zone permanently.

Every first test is filed into one of two buckets by how many bars passed between the zone forming and price coming back. That is the only split. Both buckets contain real zones on the same symbol, so the two rates are directly comparable.

https://www.tradingview.com/x/atgbgXhj/

[b]HOW TO READ IT[/b]

1. Green is demand, red is supply. Solid means the zone has never been broken, dashed means it has.
2. A dot marks each retest, green for held and red for broken through. A bigger dot means that retest was a fast one.
3. The label on a zone is its own record. Below a few tests it shows the raw count, because three out of three is not a hundred per cent, it is three out of three.
4. The panel is measured on your symbol and timeframe, not copied from anywhere. Switch symbols and the numbers change.

https://www.tradingview.com/x/3oE8US45/

[b]WHERE IT WORKS AND WHERE IT DOES NOT[/b]

The gap between fast and late retests is much wider on crypto than elsewhere. Measured while building this, on four symbols with hourly data:

Bitcoin 67.9 against 55.9 · Ethereum 71.0 against 54.5 · EURUSD 67.8 against 56.3 · Gold 73.6 against 56.6

On the S&P and on EURUSD daily the same split comes out closer to ten per cent rather than thirty. The effect is real on every symbol tested, but it is not the same size everywhere, and the panel will tell you what it is on yours instead of repeating a number from this description.

[b]ORIGINALITY[/b]

Zone drawing is a commodity and this script does not claim to draw better boxes. What it adds is the scorekeeping, and one specific finding inside it.

Two control groups were built during development. Both are reported here, including the one that does not favour the script.

The first compared zones against lookalike bases that no impulse ever came out of. It was dropped: a base like that only exists while price is still sitting on top of it, so it always got measured in chop and it flattered the zones by roughly double.

The second is harder to pass. Take each real zone, copy its width and its distance from price, and plant that same shape at a random bar somewhere else in history. Everything is identical except the reason the zone exists. Across all retests, seeded run: Bitcoin 62.5 against 60.0, Ethereum 63.4 against 58.0, EURUSD 62.0 against 55.4, Gold 64.4 against 59.0. Sample sizes 478 to 1015 per cell.

So the location of a zone is worth a few points and no more, and on Bitcoin it is worth almost nothing. What separates a useful zone from a useless one is not where it is. It is how soon price comes back, which is the split the panel measures.

Also measured and discarded: impulse strength, which several ranking scripts use as their main quality factor, came out slightly negative. Zone width mattered more than impulse size, and neither mattered as much as how quickly price returned.

[b]HONESTY[/b]

- Everything is counted on closed bars. A zone that has already been drawn never moves, and a broken one is frozen at the bar that broke it.
- The numbers depend on how much history your chart has loaded, and TradingView loads different depths on different timeframes. The same symbol can honestly report a different count on 1h than on 1D. The sample sizes are in the panel for that reason.
- Until twenty-five retests have resolved in each of the two groups, the panel says it is still measuring rather than showing a number built on nothing.
- A zone is a description of what already happened. It is not a forecast, and a fast retest is not a reason to expect a bounce.
- Only the most recent zones per side are drawn, to stay inside TradingView's drawing budget. The panel keeps counting every retest that resolved, including on zones no longer on screen.
- The impulse test uses ATR at the base, so what counts as a zone changes with volatility. A fixed percentage would find nothing in quiet markets and everything in violent ones.

[b]SETTINGS[/b]

The main ones: how hard price must leave a base for it to count as a zone, how long the base may be, and how far price must move away from a retest before it counts as held. "Straight back means within this many bars" sets the line between fast and late, and three is what came out of testing twelve variants across four symbols, chosen on two and confirmed on two the search never saw. The rest is appearance: colours, transparency, how many zones per side, text sizes, and whether the panel and its legend are shown.

This is a descriptive tool for reading zone behaviour. It is not financial advice and it does not predict price.

## Source Code

````pine
//@version=6
// Retest Record v1.2.1 - display polish, September 2026.
// Descriptive past counts only: surviving zones necessarily have no failed completed retests.
// State and alerts commit on closed bars. Zones are recognized AFTER the impulse;
// boxes are backdated to the base. Live right edges and record labels advance.
// Panel selection/distances use the current close (the live price on an open bar).
// Retest markers stay at their original touch time; colour/shape show later outcomes.
// Episodes end held, failed or unresolved. The horizon includes the entry bar.
// Full clearance arms a distinct revisit even while the earlier episode is pending.
// At most 300 zones are tracked. Oldest broken zones are evicted first; if all are
// live, new candidates are skipped and a capacity warning/count is shown, even with panel off.
// Live history is never evicted; independent later bases may overlap older price zones.
// Each zone retains its latest 10 retests. Live and broken zones have separate drawing
// budgets; a candidate mostly inside a zone already drawn is tracked but not drawn again.
// Retest markers are drawn on live zones only. At most 60 boxes + 460 labels are drawn.
indicator("Supply & Demand Zones - Retest Record [FEELS]", "S&D Zone Record [FEELS]",
     overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 500)

// ─────────────────────────────────────────────────────────────── inputs ────
grpZ = "Zones"
grpS = "Record"
grpL = "Look"

kImp    = input.float(1.5, "Impulse needed to leave the base, in ATR", minval = 0.5, maxval = 5.0, step = 0.1, group = grpZ,
     tooltip = "How hard price has to leave a quiet base for that base to count as a zone. Lower finds more zones; this is not a quality score.")
lookAft = input.int(3, "Bars allowed for that impulse", minval = 1, maxval = 10, group = grpZ)
maxBase = input.int(6, "Longest base, bars", minval = 1, maxval = 20, group = grpZ,
     tooltip = "The zone is the quiet run of candles before the impulse, up to this many bars.")
nDraw   = input.int(5, "Zones drawn per side", minval = 1, maxval = 20, group = grpZ)
brkMode = input.string("Close", "A zone breaks when price goes through its far edge by", options = ["Close", "Wick"], group = grpZ,
     tooltip = "Close: a bar has to close beyond the far edge. A wick through that closes back inside is a sweep, and the zone stays. Wick: any trade beyond the far edge breaks it.")
keepDead = input.bool(false, "Keep broken zones on the chart", group = grpZ,
     tooltip = "Broken zones are drawn as faded dashed outlines ending at the bar that broke them. They never switch roles, and they get their own drawing budget below rather than competing with live zones. Retest markers are drawn on live zones only.")
nDead = input.int(3, "Broken zones drawn per side", minval = 0, maxval = 10, group = grpZ,
     tooltip = "Counted separately from live zones, so switching broken zones on always shows something. Set to 0 to hide them even when the checkbox above is on.")

awayAtr = input.float(1.0, "A retest counts as held once price closes this far away, in ATR", minval = 0.2, maxval = 5.0, step = 0.1, group = grpS,
     tooltip = "Target uses ATR at entry, measured from the near edge. A close must reach it within the evaluation window and before break or a distinct new revisit. Held is a past outcome, not an entry signal.")
evalBars = input.int(20, "Retest evaluation window, bars including entry", minval = 1, maxval = 500, group = grpS,
     tooltip = "Entry is bar 1. On the final eligible bar, break is checked before hold, then an unfinished test becomes unresolved. A new return after full clearance also ends an unfinished prior test as unresolved. 20 is an observation window, not an optimized setting.")
recMin  = input.int(2, "Finished retests needed before zone counts appear", minval = 1, maxval = 20, group = grpS)
showPnl  = input.bool(true, "Show panel", group = grpS,
     tooltip = "Nearest live zones and past counts. Capacity warnings remain visible even when this panel is off.")
pnlPos  = input.string("Bottom right", "Panel position", options = ["Top right", "Bottom right", "Bottom left", "Top left"], group = grpS)
pnlSize = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpS)

colD    = input.color(color.new(#2E8B60, 0), "Demand", inline = "c", group = grpL)
colS    = input.color(color.new(#B4503B, 0), "Supply", inline = "c", group = grpL)
fillOp  = input.int(80, "Zone fill transparency", minval = 50, maxval = 98, group = grpL)
txtCol  = input.color(color.new(#20242A, 0), "Text", group = grpL)
showDots = input.bool(true, "Mark retests on the zones", group = grpL,
     tooltip = "Latest 10 retests per zone at original touch time: grey circle testing, green held, red failed, grey cross unresolved. Hover for outcome. Confirmation may be later; counts include older events.")
dotSize = input.string("Tiny", "Retest dot size", options = ["Tiny", "Small", "Normal"], group = grpL)
fadeAge = input.bool(true, "Fade zones as they age", group = grpL,
     tooltip = "Older zones are drawn lighter so the fresh ones stand out.")
fadeOver = input.int(60, "Fully faded after this many bars", minval = 5, maxval = 500, group = grpL)
showRec = input.bool(true, "Write the record on zones that have one", group = grpL)
recordMode = input.string("One record", "Zone record labels", options = ["One record", "All records"], group = grpL,
     tooltip = "One record prevents chart record labels from overlapping: testing first, then a nearest zone with a record, then the newest eligible record. Other events remain marked; nearest counts remain in the panel. All records can overlap on nearby zones. Untested zones have no chart label.")
recSize = input.string("Small", "Zone record text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpL)

i_size(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small :
     s == "Normal" ? size.normal : size.large

// A candle that pokes one tick past the edge is not a departure. Clearance has to be
// worth something, or a single wobble above a zone splits one bounce into two episodes.
CLEAR_ATR = 0.3
// A later base at nearly the same prices is still tracked and counted; drawing both just
// stacks the boxes. A candidate this far inside a zone already on the chart is not drawn.
COVER_FRAC = 0.7

// ─────────────────────────────────────────────────────────── zone objects ────
type Retest
    int at
    int result // 0 pending, 1 held, -1 failed, 2 unresolved
    string reason

type Zone
    int side
    float lo
    float hi
    int born
    int leftAt // timestamp, not bar index
    int baseEnd // origin candle timestamp; dedup uses shared base candles
    int tests
    int held
    int unresolved
    int failed
    int tStart // episode start bar index for elapsed bars and evaluation deadline
    bool outside
    bool pending
    float tgt
    bool dead
    int diedAt // timestamp
    Retest[] events
    box bx
    label lb
    label[] dts

var Zone[] zs = array.new<Zone>()
var int capacitySkips = 0
atr14 = ta.atr(14)
bool aNew = false
bool aTouch = false
bool aHeld = false
bool aBrk = false

f_clear(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)
        z.bx := na
    if not na(z.lb)
        label.delete(z.lb)
        z.lb := na
    while array.size(z.dts) > 0
        label.delete(array.pop(z.dts))

f_new(int side, float lo, float hi, int lft, int baseEnd) =>
    Zone.new(side = side, lo = lo, hi = hi, born = bar_index, leftAt = lft, baseEnd = baseEnd,
         tests = 0, held = 0, unresolved = 0, failed = 0, tStart = na,
         outside = false, pending = false, tgt = na,
         dead = false, diedAt = na, events = array.new<Retest>(),
         bx = na, lb = na, dts = array.new<label>())

f_finish(Zone z, int result, string reason) =>
    ev = array.last(z.events)
    ev.result := result
    ev.reason := reason
    z.pending := false
    if result == 1
        z.held += 1
    else if result == -1
        z.failed += 1
    else
        z.unresolved += 1

// OHLC ordering convention: a distinct return closes the old episode unresolved
// BEFORE opening the new one. This candle can resolve only the new episode.
// Then break wins over hold; on the last eligible bar, either wins over timeout.
// Full clearance alone does NOT cancel pending: 0.9 ATR then 1 ATR can still hold.
f_step(Zone z, float unit) =>
    bool entered = false
    bool heldNow = false
    bool broken = false
    if not z.dead
        touch = high >= z.lo and low <= z.hi
        clrPad = na(unit) or unit <= 0 ? 0.0 : unit * CLEAR_ATR
        clear = z.side == 1 ? low > z.hi + clrPad : high < z.lo - clrPad
        through = brkMode == "Wick" ? (z.side == 1 ? low < z.lo : high > z.hi) :
             (z.side == 1 ? close < z.lo : close > z.hi)
        if bar_index > z.born and z.outside and touch and not na(unit) and unit > 0
            if z.pending
                f_finish(z, 2, "Unresolved: a distinct return began after full clearance")
            z.tests += 1
            z.pending := true
            z.outside := false
            z.tStart := bar_index
            z.tgt := z.side == 1 ? z.hi + unit * awayAtr : z.lo - unit * awayAtr
            array.push(z.events, Retest.new(time, 0, "Testing: waiting for target, break or evaluation limit"))
            if array.size(z.events) > 10
                array.shift(z.events)
            entered := true
        if through
            if z.pending
                f_finish(z, -1, "Failed: zone broke during this retest")
            z.outside := false
            z.dead := true
            z.diedAt := time
            broken := true
        else
            if z.pending
                away = z.side == 1 ? close >= z.tgt : close <= z.tgt
                if away
                    f_finish(z, 1, "Held: close reached the ATR target fixed at entry")
                    heldNow := true
                else if bar_index - z.tStart >= evalBars - 1
                    f_finish(z, 2, "Unresolved: evaluation window ended without target or break")
            // Observe clearance during pending AND on the successful/timeout bar.
            // A candle overlapping the zone cannot arm a subsequent entry.
            if clear
                z.outside := true
    [entered, heldNow, broken]

// Step existing zones before detection; broken storage is then eligible for eviction.
if barstate.isconfirmed and array.size(zs) > 0
    for z in zs
        [entered, heldNow, broken] = f_step(z, atr14)
        aTouch := aTouch or entered
        aHeld := aHeld or heldNow
        aBrk := aBrk or broken

// ──────────────────────────────────────────────────────── detect a new base ────
atrO = atr14[lookAft]
oHigh = high[lookAft]
oLow = low[lookAft]
quiet = not na(atrO) and atrO > 0 and not na(oHigh) and not na(oLow) and (oHigh - oLow) <= 0.9 * atrO
hiAft = ta.highest(high, lookAft)
loAft = ta.lowest(low, lookAft)
impUp = quiet and (hiAft - oHigh) > kImp * atrO
impDn = quiet and (oLow - loAft) > kImp * atrO
baseLo = oLow
baseHi = oHigh
int leftEdge = time[lookAft]
// The origin counts as the first base candle. Guard maxBase=1 explicitly.
if quiet and maxBase > 1
    for b = 1 to maxBase - 1
        idx = lookAft + b
        if na(high[idx]) or na(low[idx]) or na(time[idx])
            break
        if (high[idx] - low[idx]) > 0.9 * atrO
            break
        baseLo := math.min(baseLo, low[idx])
        baseHi := math.max(baseHi, high[idx])
        leftEdge := time[idx]

if barstate.isconfirmed and quiet
    if (impUp or impDn) and not (impUp and impDn)
        sd = impUp ? 1 : -1
        birthBroken = brkMode == "Wick" and (sd == 1 ? low < baseLo : high > baseHi)
        if not birthBroken and ((sd == 1 and close > baseHi) or (sd == -1 and close < baseLo))
            bool dup = false
            for zj in zs
                // Dedup the formation, not a permanent price region. Shared base candles
                // plus overlapping price suppress sliding-window copies, even if broken.
                sameBase = leftEdge <= zj.baseEnd and time[lookAft] >= zj.leftAt
                if sameBase and baseLo < zj.hi and baseHi > zj.lo
                    dup := true
            if not dup
                if array.size(zs) >= 300
                    int evict = na
                    for j = 0 to array.size(zs) - 1
                        candidate = array.get(zs, j)
                        if candidate.dead
                            evict := j
                            break
                    if not na(evict)
                        old = array.remove(zs, evict)
                        f_clear(old)
                if array.size(zs) < 300
                    z = f_new(sd, baseLo, baseHi, leftEdge, time[lookAft])
                    // Birth only observes clearance; already-invalid candidates were rejected.
                    // Same clearance rule as f_step, so birth cannot arm on a wobble.
                    bPad = atrO * CLEAR_ATR
                    z.outside := sd == 1 ? low > baseHi + bPad : high < baseLo - bPad
                    array.push(zs, z)
                    aNew := true
                else
                    capacitySkips += 1

// ────────────────────────────────────────────────────────────────── drawing ────
f_record(Zone z) =>
    string rec = z.held > 0 ? "Held " + str.tostring(z.held) : ""
    if z.unresolved > 0
        rec += (rec == "" ? "" : " · ") + "Unresolved " + str.tostring(z.unresolved)
    if z.failed > 0
        rec += (rec == "" ? "" : " · ") + "Failed " + str.tostring(z.failed)
    rec

f_state(Zone z) =>
    z.dead ? "Broken" : z.pending ? "Testing" : z.tests == 0 ? "Untested" : "Live"

f_label(Zone z) =>
    count = z.tests - (z.pending ? 1 : 0)
    rec = count >= recMin ? f_record(z) : ""
    state = z.pending ? "Testing" : z.dead and rec != "" ? "Broken" : ""
    rec == "" ? state : state == "" ? rec : rec + "\n" + state

f_dot(Retest ev, float y) =>
    c = ev.result == 1 ? colD : ev.result == -1 ? colS : color.new(txtCol, 35)
    style = ev.result == 2 ? label.style_xcross : label.style_circle
    label.new(ev.at, y, "", xloc.bar_time, yloc.price, c, style,
         color.new(color.white, 100), i_size(dotSize), tooltip = ev.reason + "\nMarker stays at the original touch; outcome may be confirmed later.")

// True when this candidate is mostly inside a same-side zone already on the chart.
// Checked against the visible set only, which stays small, so this costs little.
f_covered(Zone z, int[] vis) =>
    bool cov = false
    hz = z.hi - z.lo
    if hz > 0 and array.size(vis) > 0
        for k = 0 to array.size(vis) - 1
            w = array.get(zs, array.get(vis, k))
            if w.side == z.side
                ov = math.min(z.hi, w.hi) - math.max(z.lo, w.lo)
                if ov > 0 and ov / hz >= COVER_FRAC
                    cov := true
    cov

// Select containing or approach-side zones using current price. A live zone beyond
// its far edge intrabar is excluded until price returns or a confirmed break kills it.
int nearD = na
int nearS = na
float distD = na
float distS = na
int liveCount = 0
if barstate.islast
    if array.size(zs) > 0
        for i = 0 to array.size(zs) - 1
            z = array.get(zs, i)
            if not z.dead
                liveCount += 1
                if z.side == 1 and close >= z.lo
                    d = math.max(0.0, close - z.hi)
                    if na(distD) or d <= distD
                        nearD := i
                        distD := d
                if z.side == -1 and close <= z.hi
                    d = math.max(0.0, z.lo - close)
                    if na(distS) or d <= distS
                        nearS := i
                        distS := d
    // Reserve nearest slots even with panel off; distance ties above choose newest.
    // Fill remaining slots newest live first, then optional broken history.
    visible = array.new<bool>(array.size(zs), false)
    visIdx = array.new<int>()
    int nDl = 0
    int nSl = 0
    int nDd = 0
    int nSd = 0
    if not na(nearD)
        array.set(visible, nearD, true)
        array.push(visIdx, nearD)
        nDl := 1
    if not na(nearS)
        array.set(visible, nearS, true)
        array.push(visIdx, nearS)
        nSl := 1
    if array.size(zs) > 0
        // Pass 0 fills the live budget, pass 1 the separate broken one, both newest first.
        for pass = 0 to 1
            for i = array.size(zs) - 1 to 0
                z = array.get(zs, i)
                eligible = pass == 0 ? not z.dead : keepDead and z.dead
                lim = pass == 0 ? nDraw : nDead
                used = z.side == 1 ? (pass == 0 ? nDl : nDd) : (pass == 0 ? nSl : nSd)
                if not array.get(visible, i) and eligible and used < lim and not f_covered(z, visIdx)
                    array.set(visible, i, true)
                    array.push(visIdx, i)
                    if z.side == 1
                        if pass == 0
                            nDl += 1
                        else
                            nDd += 1
                    else
                        if pass == 0
                            nSl += 1
                        else
                            nSd += 1
        // One chart record by default: deterministic selection, no price displacement.
        // Ignore untested zones so an empty nearest zone cannot hide useful history.
        int recordIndex = na
        int recordPriority = 0
        for i = 0 to array.size(zs) - 1
            z = array.get(zs, i)
            if array.get(visible, i) and f_label(z) != ""
                isNearest = (not na(nearD) and i == nearD) or (not na(nearS) and i == nearS)
                priority = z.pending ? 3 : isNearest ? 2 : 1
                if priority >= recordPriority
                    recordIndex := i
                    recordPriority := priority
        // Delete BEFORE creating: no transient label-budget overflow on selection changes.
        for i = 0 to array.size(zs) - 1
            z = array.get(zs, i)
            if not array.get(visible, i)
                f_clear(z)
            else
                while array.size(z.dts) > 0
                    label.delete(array.pop(z.dts))
        for i = 0 to array.size(zs) - 1
            z = array.get(zs, i)
            if array.get(visible, i)
                col = z.side == 1 ? colD : colS
                rgt = z.dead ? z.diedAt : time
                age = bar_index - z.born
                aged = fadeAge ? math.min(1.0, age / math.max(1.0, fadeOver)) : 0.0
                dimB = math.round(aged * 55)
                dimF = math.round(aged * 15)
                if na(z.bx)
                    z.bx := box.new(z.leftAt, z.hi, rgt, z.lo, xloc = xloc.bar_time,
                         border_width = 2)
                box.set_lefttop(z.bx, z.leftAt, z.hi)
                box.set_rightbottom(z.bx, rgt, z.lo)
                box.set_border_color(z.bx, color.new(col, z.dead ? 70 : dimB))
                box.set_border_style(z.bx, z.dead ? line.style_dashed : line.style_solid)
                box.set_bgcolor(z.bx, color.new(col, z.dead ? 96 : math.min(97, fillOp + dimF)))
                txt = showRec and (recordMode == "All records" or (not na(recordIndex) and i == recordIndex)) ? f_label(z) : ""
                if txt != ""
                    if na(z.lb)
                        z.lb := label.new(rgt, (z.hi + z.lo) / 2, txt, xloc.bar_time, yloc.price,
                             color.new(color.white, 100), label.style_label_left,
                             color.new(col, z.dead ? 45 : 0), i_size(recSize))
                    label.set_xy(z.lb, rgt, (z.hi + z.lo) / 2)
                    label.set_text(z.lb, txt)
                    label.set_textcolor(z.lb, color.new(col, z.dead ? 45 : 0))
                else if not na(z.lb)
                    label.delete(z.lb)
                    z.lb := na
                // Markers on live zones only: broken ones are history, and the extra
                // slots they now get must not push the drawing budget over its limit.
                if showDots and not z.dead
                    for ev in z.events
                        array.push(z.dts, f_dot(ev, z.side == 1 ? z.hi : z.lo))

f_pos(string p) => p == "Top right" ? position.top_right : p == "Bottom right" ? position.bottom_right :
     p == "Bottom left" ? position.bottom_left : position.top_left

f_px(float x) => x >= 1000 ? str.tostring(math.round(x)) : str.tostring(x, format.mintick)

f_note(Zone z, bool isD) =>
    inside = close >= z.lo and close <= z.hi
    distance = isD ? math.max(0.0, close - z.hi) : math.max(0.0, z.lo - close)
    d = close != 0 ? distance / math.abs(close) * 100 : na
    string where = inside ? "price is in zone" : na(d) ? "distance n/a" :
         str.tostring(d, "#.#") + (isD ? "% below" : "% above")
    rec = f_record(z)
    where + " · " + f_state(z) + (rec == "" ? "" : "\n" + rec)

var table pnl = table.new(f_pos(pnlPos), 3, 3,
     bgcolor = color.new(color.gray, 84), frame_color = color.new(#20242A, 60),
     frame_width = 1, border_width = 0)

f_row(int r, Zone z, bool isD, color col) =>
    table.cell(pnl, 0, r, "■", text_color = color.new(col, 0), text_size = i_size(pnlSize), text_halign = text.align_right)
    if na(z)
        table.cell(pnl, 1, r, isD ? "no live demand at/below price" : "no live supply at/above price",
             text_color = color.new(txtCol, 40), text_size = i_size(pnlSize), text_halign = text.align_left)
        table.cell(pnl, 2, r, "", text_size = i_size(pnlSize))
    else
        table.cell(pnl, 1, r, (isD ? "Demand  " : "Supply  ") + f_px(z.lo) + " – " + f_px(z.hi),
             text_color = txtCol, text_size = i_size(pnlSize), text_halign = text.align_left)
        table.cell(pnl, 2, r, f_note(z, isD),
             text_color = color.new(txtCol, 25), text_size = i_size(pnlSize), text_halign = text.align_left)

if barstate.islast
    if showPnl
        Zone panelD = na
        Zone panelS = na
        if not na(nearD)
            panelD := array.get(zs, nearD)
        if not na(nearS)
            panelS := array.get(zs, nearS)
        f_row(0, panelS, false, colS)
        f_row(1, panelD, true, colD)
    else
        table.clear(pnl, 0, 0, 2, 1)
    // Never hide loss of coverage, even when the user hides the usual panel.
    if liveCount >= 300 or capacitySkips > 0
        table.cell(pnl, 0, 2, "!", text_color = txtCol, bgcolor = color.new(color.orange, 35), text_size = i_size(pnlSize))
        table.cell(pnl, 1, 2, liveCount >= 300 ? "Capacity full: 300 live" : "Past capacity limit", text_color = txtCol,
             bgcolor = color.new(color.orange, 35), text_size = i_size(pnlSize))
        table.cell(pnl, 2, 2, "Candidates skipped: " + str.tostring(capacitySkips), text_color = txtCol,
             bgcolor = color.new(color.orange, 35), text_size = i_size(pnlSize))
    else
        table.clear(pnl, 0, 2, 2, 2)

// Events commit at close; multiple conditions can fire on the same bar.
alertcondition(aNew, "New zone formed", "A quiet base was left by an impulse and became a zone.")
alertcondition(aTouch, "Price entered a zone", "Price returned into a zone after prior clearance. A retest began on this bar.")
alertcondition(aHeld, "Zone held a retest", "A retest met the configured ATR close-away threshold before the zone broke.")
alertcondition(aBrk, "Zone broken", "A zone broke under the configured close or wick rule.")
````
