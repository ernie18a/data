<!-- tradingview-pine-id: PUB;51eaba29d45e4faa849a1ed05a129bff -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Level Watch & Touch Ledger [MQLSoftware]

Source: https://www.tradingview.com/script/rVdYpjbC-Level-Watch-Touch-Ledger-MQLSoftware/

## Description

OVERVIEW

Level Watch & Touch Ledger keeps an audit trail of what price actually did at the levels you draw yourself. You type in up to eight prices and the script records every time price came to each one, what happened next, and how far past the line it ran before turning. It discovers nothing on its own: it never scans, clusters or ranks levels, and it produces no entries, stops, targets or position sizing. It answers one question about levels you already care about — has this one actually been respected on this chart, or does it only look important?

CONCEPTS

A plain touch counter is close to useless, because price grinding sideways on a level logs a touch every bar and the count becomes noise. The engine here is a re-arm gate: after an event resolves, a level goes quiet until price has closed a configurable ATR distance away and a cooldown has passed. Only then can it register another touch. That turns an ordinary consolidation into a small number of events instead of forty.

Each event resolves exactly once, on a closed bar, and is frozen. REJECTED means price closed back on the side it approached from by the outcome margin; BROKEN means it closed through by that margin; CHOP means neither happened inside the outcome window. A latched outcome is never rewritten, so the table cannot quietly improve as new bars arrive.

Overshoot is measured on rejections only. A break is declared once price closes beyond the level by the outcome margin, so a broken event's overshoot is floored by your own setting and would describe the input rather than the market. A bar that gaps clean over a level never touches the zone, so gaps are detected separately and recorded as breaks — otherwise a level's failures go uncounted and gap-prone symbols look more reliable than they are.

FEATURES

Eight independent level slots, each with its own ledger. A state readout per level, from OUT OF RANGE and WARMING UP through ARMED, PENDING and COOLDOWN. Touch count and bars since the last one. The rejected / broken / chop split. A rejection rate whose denominator includes chop. Median and 75th-percentile rejection overshoot in ATR. Shaded touch zones, level lines, and a marker on every recorded touch. Alerts on touch and outcome, plus a proximity ladder that fires only as price closes in, never as it walks away.

HOW TO USE

Type a price into Level 1 and read the row. Zone half-width sets how close counts as a touch; re-arm distance is the main lever on how many events you get; outcome window and margin decide how decisively price must move. Rates and overshoot both stay behind one minimum-sample input and read "collecting" until the level has enough resolved events — four touches give you an audit trail, not a statistic. A median overshoot of zero is a real answer, not a missing one: half the rejections turned before price reached your line.

Counts, rates, outcomes and markers are closed-bar figures and are never revised. The DIST column, the shaded zone width and the proximity alerts are live and update inside the forming bar; they are visual context, not signals.

CONCLUSION

This is a measurement tool for levels you supply, not a level finder and not a signal generator. Samples on a hand-drawn level are small by nature, and nothing here is a probability, an expectancy or a forecast — the figures describe what this chart's loaded bars did at your lines, shown with the sample size that produced them.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/
// © MQLSoftware
//@version=6
//
// Level Watch & Touch Ledger [MQLSoftware]
//
// Free/open-source analytical overlay for levels the trader supplies himself.
// The script never discovers, harvests, clusters or ranks levels of its own. It
// takes up to eight prices typed or dragged in by the user and keeps an audit
// trail of what price actually did at each of them on the current chart. It does
// not create entries, stops, targets, position sizing or execution instructions.
//
// ORIGINAL CONTRIBUTION
//   1. Re-arm gate. A level is eligible for a new touch only after price has first
//      travelled a configurable ATR distance away from it and any cooldown has
//      expired. A plain touch counter logs dozens of "touches" while price grinds
//      sideways on the level; that count is noise. Every number in this ledger is
//      produced behind this gate, which collapses an ordinary consolidation into a
//      small number of events instead of one per bar. It is a strong reduction, not
//      a guarantee of exactly one: a range that is wide relative to a contracting
//      ATR can legitimately re-arm inside itself.
//   2. Rejection overshoot ledger. For each REJECTED event the script records how
//      far past the level price travelled before it turned back, in ATR, and reports
//      the median and 75th percentile per level. Broken events are deliberately
//      excluded: a break is only declared once price closes beyond the level by the
//      outcome margin, so its overshoot is arithmetically floored by that input and
//      would describe the setting rather than the market. This is a descriptive
//      measure of how far a rejection has historically over-run - not a stop suggestion.
//   3. Latched three-way outcome. Each event resolves exactly once, on a confirmed
//      bar, into REJECTED, BROKEN or CHOP, and is then frozen. Outcomes are never
//      revised, so the table cannot improve retroactively. A bar that gaps clean over
//      an armed level never intersects the touch zone, so a naive counter simply loses
//      that break and reports a level as more reliable than it was; here the gap is
//      detected explicitly and recorded as a break on the bar it happens.
//   4. Ledger before estimator. Every derived statistic - the rejection rate and the
//      overshoot median and 75th percentile alike - is gated behind one and the same
//      minimum-sample input; below it the raw event counts are still shown and the
//      derived cell reads "collecting". A level with four touches yields a useful
//      audit trail and no false precision, and no cell ever quotes a quartile while
//      the cell beside it is still disclaiming its sample size.
//
// DATA LIMITATION
// Every statistic is computed from the loaded history of the current chart and
// current timeframe only. Sample sizes on a user-drawn level are small by nature.
// Nothing here is a probability, an expectancy or a forecast; the counts describe
// what this chart's loaded bars did, and a different chart, feed or timeframe will
// produce different numbers.
//
// REALTIME BEHAVIOUR - WHAT IS FROZEN AND WHAT IS LIVE
// This script is not "non-repainting" as a blanket statement, and saying so would be
// misleading. Two parts behave differently, deliberately:
//
//   FROZEN (confirmed bars only, never revised). The ledger: touch detection and its
//   count, the arm/cooldown state transitions, overshoot accumulation, the three-way
//   outcome, the per-level arrays, every count and percentage derived from them, the
//   touch markers drawn on the chart, and the touch/outcome alerts. All of it is
//   written inside barstate.isconfirmed, and a latched outcome is never rewritten, so
//   a historical row cannot improve retroactively.
//
//   LIVE (updates inside the forming bar). The panel is re-rendered under
//   barstate.islast, so on the realtime bar it re-draws on every tick. Three things in
//   it are genuinely live: the DIST column, which is a distance readout by design; the
//   width of the shaded zone and therefore its drawn geometry, because the zone is
//   scaled by ATR and ATR moves while the bar forms; and the STATE cell's range check,
//   which reads the running chart extremes and can therefore drop OUT OF RANGE mid-bar
//   the first time price reaches far enough. The proximity alerts (APPROACHING /
//   ARRIVING) are intrabar for the same reason - they are only useful before the close.
//   None of these write to the ledger. They are visual context, not signals.
//
// The practical consequence: the numbers you audit are stable, the distance readout
// and the zone edge you watch are live. No request.security() path exists in v1.

// Release contract: keep the full shorttitle and require a clean 0-error/0-warning compile.
indicator("Level Watch & Touch Ledger [MQLSoftware]", shorttitle="MQLSoftware - Level Watch & Touch Ledger", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── DESIGN TOKENS ────────────────────────────────────────────────────────────
color NS_WHITE = color.rgb(225, 230, 240)
color NS_LBL   = color.rgb(170, 178, 195)
color NS_SEC   = color.rgb( 90,  98, 115)
// The panel is deliberately OPAQUE, unlike the near-opaque token the rest of the
// free line uses: this script draws level lines that extend across the whole chart,
// and at 4% transparency a line running behind the panel struck through the footer
// text. A data panel has to stay legible over any chart content.
color NS_BG    = color.rgb(  8, 11, 18)
color NS_ROW   = color.rgb( 16, 20, 30)

color LWT_REJ_DEF  = #00E5A8
color LWT_BRK_DEF  = #FF3D71
color LWT_CHOP_DEF = #FFB020
color LWT_LVL_DEF  = #5B8CFF
color LWT_ACC_DEF  = #00E5FF

// State machine codes, named so the logic below reads as prose.
int ST_DISARMED = 0
int ST_ARMED    = 1
int ST_EVENT    = 2
int ST_COOLDOWN = 3

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string GRP_LVL = "◆ My Levels"
var string GRP_ENG = "◆ Zone & Timing"
var string GRP_ALR = "◆ Alerts"
var string GRP_VIS = "◆ Visual"

// Levels are plain numeric price inputs so the script always loads on a fresh
// chart. Zero means the slot is off.
float lvl1 = input.price(0.0, "Level 1", group=GRP_LVL, tooltip="Type a price, or drag the line on the chart. 0 = slot off.")
float lvl2 = input.price(0.0, "Level 2", group=GRP_LVL)
float lvl3 = input.price(0.0, "Level 3", group=GRP_LVL)
float lvl4 = input.price(0.0, "Level 4", group=GRP_LVL)
float lvl5 = input.price(0.0, "Level 5", group=GRP_LVL)
float lvl6 = input.price(0.0, "Level 6", group=GRP_LVL)
float lvl7 = input.price(0.0, "Level 7", group=GRP_LVL)
float lvl8 = input.price(0.0, "Level 8", group=GRP_LVL)
bool  hideOff = input.bool(true, "Hide empty slots in the panel", group=GRP_LVL)

int   atrLen = input.int(14, "ATR length", minval=2, maxval=200, group=GRP_ENG)
float zMult  = input.float(0.25, "Zone half-width × ATR", minval=0.02, maxval=2.0, step=0.05, group=GRP_ENG, tooltip="A touch is registered when the bar's range enters this band around the level.")
float qArm   = input.float(1.0, "Re-arm distance × ATR", minval=0.1, maxval=10.0, step=0.1, group=GRP_ENG, tooltip="Price must close this far from the level before a new touch can be registered. This is what stops one consolidation logging dozens of touches.")
int   outW   = input.int(10, "Outcome window (bars)", minval=2, maxval=200, group=GRP_ENG)
// 1.0 ATR, not 0.5: a half-ATR close is smaller than a typical single bar's range,
// so the outcome was being decided by the noise of the very next bar and CHOP could
// never occur. A full-ATR close is a reaction rather than a wobble, which also makes
// the rejected/broken split describe something real.
float rMult  = input.float(1.0, "Outcome margin × ATR", minval=0.1, maxval=5.0, step=0.1, group=GRP_ENG, tooltip="How decisively price must close away from the level to call the event rejected or broken. Below roughly 1 ATR the result is decided by ordinary bar noise.")
int   cdBars = input.int(10, "Cooldown after an outcome (bars)", minval=0, maxval=200, group=GRP_ENG)
// 5, not the 8 used elsewhere in the line. This gate now governs the overshoot
// statistics as well as the rate, and overshoot counts REJECTIONS only - eight
// rejections of a single hand-drawn level is rare enough that the product's most
// distinctive column would have read "collecting" on almost every real chart.
// Five is still a defensible floor for a quoted percentage, and it is a user input.
int   minN   = input.int(5, "Minimum sample before showing rates", minval=2, maxval=100, group=GRP_ENG)

bool  alrProx  = input.bool(true, "Proximity alerts (intrabar)", group=GRP_ALR, tooltip="APPROACHING and ARRIVING evaluate on the live bar so they arrive in time to be useful. They never write to the ledger.")
float tFar     = input.float(2.0, "Approach distance × ATR", minval=0.2, maxval=20.0, step=0.1, group=GRP_ALR)
float tNear    = input.float(0.5, "Arrival distance × ATR", minval=0.1, maxval=10.0, step=0.1, group=GRP_ALR)
bool  alrTouch = input.bool(true, "Touch alerts (confirmed bars)", group=GRP_ALR)
bool  alrOut   = input.bool(true, "Outcome alerts (confirmed bars)", group=GRP_ALR)

bool   showPanel = input.bool(true, "Show ledger panel", group=GRP_VIS)
string panelPos  = input.string(position.top_right, "Panel position", options=[position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group=GRP_VIS)
string panelSize = input.string(size.small, "Panel text size", options=[size.tiny, size.small, size.normal, size.large], group=GRP_VIS)
bool   showLines = input.bool(true, "Draw level lines", group=GRP_VIS)
bool   showZones = input.bool(true, "Shade touch zones", group=GRP_VIS)
bool   showMarks = input.bool(true, "Mark touches on the chart", group=GRP_VIS)
int    lineWid   = input.int(1, "Level line width", minval=1, maxval=4, group=GRP_VIS)
color  cRej      = input.color(LWT_REJ_DEF, "Rejected", inline="oc", group=GRP_VIS)
color  cBrk      = input.color(LWT_BRK_DEF, "Broken", inline="oc", group=GRP_VIS)
color  cChop     = input.color(LWT_CHOP_DEF, "Chop", inline="oc", group=GRP_VIS)
color  cLvl      = input.color(LWT_LVL_DEF, "Level line", group=GRP_VIS)

// ─── SHARED HELPERS ───────────────────────────────────────────────────────────
// Below minN the sample is too small to quote a percentage — say so instead of
// printing statistical noise. House idiom, matching Session Liquidity
// Architecture and Structure Participation Matrix.
f_rate(int c, int n, int gate) =>
    n >= gate ? str.tostring(100.0 * c / n, "#") + "%" : "collecting"

// Spelled " ATR", never "R". In this product line "R" already means risk multiple -
// Price Reaction Levels renders live trade R-multiples that way - and reusing it for
// an ATR multiple here would read as a risk figure to our own users.
f_atrTxt(float v) =>
    na(v) ? "—" : str.tostring(v, "#.##") + " ATR"

f_price(float v) =>
    na(v) or v == 0 ? "—" : str.tostring(v, format.mintick)

// ─── PER-LEVEL LEDGER ─────────────────────────────────────────────────────────
type SlotInfo
    bool   on
    bool   valid
    float  lvl
    int    n
    int    nRej
    int    nBrk
    int    nChop
    float  medOver
    float  p75Over
    int    barsSince
    int    nAbove
    int    nBelow
    string state
    float  dist
    string lastOut

// One call site per slot, so `var` state inside is instantiated per slot. This is
// the same pattern Session Liquidity Architecture uses for its sessions.
f_slot(bool on, float lvl, float atr, float runLo, float runHi, bool drawLine, bool drawZone, bool drawMark, string tag) =>
    var array<float> overs   = array.new<float>()
    var int   n        = 0
    var int   nRej     = 0
    var int   nBrk     = 0
    var int   nChop    = 0
    var int   nAbove   = 0
    var int   nBelow   = 0
    var int   state    = ST_DISARMED
    var int   cdLeft   = 0
    var int   t0       = na
    var bool  fromAbove= false
    var float over     = 0.0
    var int   lastTouchBar = int(na)
    var string lastOut = "—"
    var int   lastProx = -1
    var line  ln       = line(na)
    var box   zn       = box(na)
    var bool  hasLn    = false
    var bool  hasZn    = false

    // Three separate reasons a slot may not be counting, kept apart so the panel can
    // say which one it is. Collapsing them into one flag made the script report
    // "OUT OF RANGE" for a perfectly good level during the first few bars, when the
    // only thing missing was ATR.
    bool typed   = on and lvl != 0                                              // user put something in the slot
    bool inBand  = lvl > 0 and lvl >= 0.5 * runLo and lvl <= 2.0 * runHi         // a sane price for this chart
    bool ready   = not na(atr) and atr > 0                                       // enough bars for ATR
    bool valid   = typed and inBand and ready
    float h = math.max(zMult * atr, 2 * syminfo.mintick)
    float dist = valid ? math.abs(close - lvl) / atr : na

    if valid and barstate.isconfirmed
        // Cooldown is served BEFORE anything else can happen on the bar, and the bar
        // that brings cdLeft to zero is itself still part of the cooldown - otherwise
        // a cooldown of 1 bar would behave identically to no cooldown at all.
        if cdLeft > 0
            cdLeft -= 1
            if cdLeft == 0 and state == ST_COOLDOWN
                state := ST_DISARMED

        // else-if, not a second if: arming and touching must not both happen on one
        // bar. If they did, fromAbove would be read from a close[1] that is by
        // construction sitting within the re-arm distance of the level, so the
        // direction label - and with it the overshoot side and the rejected/broken
        // polarity - would be decided by noise rather than by a real approach.
        else if state == ST_DISARMED and math.abs(close - lvl) >= qArm * atr
            state := ST_ARMED

        // A gap straight through the level. The bar never intersects the zone, so the
        // ordinary touch test below cannot see it, and the level would be silently
        // skipped - which biases the whole ledger toward holds on any gap-prone
        // instrument, because only the level's survivals ever get counted. A confirmed
        // bar that opens and closes wholly on the far side of a level price was
        // previously above is a break, and is recorded as one immediately.
        else if state == ST_ARMED and ((close[1] > lvl and high < lvl - h) or (close[1] < lvl and low > lvl + h))
            n += 1
            nBrk += 1
            lastOut := "BROKEN"
            lastTouchBar := bar_index
            if close[1] > lvl
                nAbove += 1
            else
                nBelow += 1
            state := ST_COOLDOWN
            cdLeft := cdBars
            if cdBars == 0
                state := ST_DISARMED
            if drawMark
                label.new(bar_index, close[1] > lvl ? lvl - h : lvl + h, tag + " gap", style=close[1] > lvl ? label.style_label_up : label.style_label_down, color=color.new(cBrk, 20), textcolor=NS_WHITE, size=size.tiny)
            if alrOut
                alert(tag + " gapped through " + f_price(lvl), alert.freq_once_per_bar_close)

        else if state == ST_ARMED and low <= lvl + h and high >= lvl - h
            state := ST_EVENT
            t0 := bar_index
            fromAbove := close[1] > lvl
            // Overshoot starts on the touch bar itself, not the bar after it.
            over := math.max(0.0, (close[1] > lvl ? (lvl - low) : (high - lvl)) / atr)
            lastTouchBar := bar_index
            n += 1
            if fromAbove
                nAbove += 1
            else
                nBelow += 1
            if drawMark
                label.new(bar_index, fromAbove ? lvl + h : lvl - h, tag, style=fromAbove ? label.style_label_down : label.style_label_up, color=color.new(cLvl, 20), textcolor=NS_WHITE, size=size.tiny)
            if alrTouch
                alert(tag + " touched at " + f_price(lvl) + " from " + (fromAbove ? "above" : "below"), alert.freq_once_per_bar_close)

        else if state == ST_EVENT
            // Accumulate how far past the level price actually travelled.
            over := math.max(over, fromAbove ? (lvl - low) / atr : (high - lvl) / atr)
            over := math.max(over, 0.0)

            bool broke = fromAbove ? close < lvl - rMult * atr : close > lvl + rMult * atr
            bool rej   = fromAbove ? close > lvl + rMult * atr : close < lvl - rMult * atr
            string outcome = broke ? "BROKEN" : rej ? "REJECTED" : bar_index - t0 >= outW ? "CHOP" : na

            if not na(outcome)
                // Latch once, then freeze. Nothing below is ever rewritten.
                // Only REJECTED events feed the overshoot sample. A break is declared
                // only once price closes beyond the level by rMult * atr, and low <= close,
                // so a broken event's overshoot is always greater than rMult by
                // construction - pooling it would report the user's own margin setting
                // back to him dressed up as a measurement of the market.
                if outcome == "BROKEN"
                    nBrk += 1
                else if outcome == "REJECTED"
                    array.push(overs, over)
                    nRej += 1
                else
                    nChop += 1
                lastOut := outcome
                state := ST_COOLDOWN
                cdLeft := cdBars
                if cdBars == 0
                    state := ST_DISARMED
                if alrOut
                    alert(tag + " " + outcome + " at " + f_price(lvl) + " · overshoot " + f_atrTxt(over), alert.freq_once_per_bar_close)

    // Proximity is the one intrabar path. It fires only when price moves to a CLOSER
    // rung than it has already been announced at, so a slow drift cannot page every
    // bar - and, just as importantly, walking away from the level pages nothing. A
    // direction-blind test would fire "arriving" and then "approaching" on the way
    // out, which is exactly backwards for an advance-warning alert. The rung is
    // released again once price leaves the outer band, so the level can re-announce
    // on a genuine second approach.
    if valid and alrProx and barstate.isrealtime
        int prox = dist <= zMult ? 3 : dist <= tNear ? 2 : dist <= tFar ? 1 : 0
        if prox > lastProx and prox > 0
            lastProx := prox
            string word = prox == 3 ? "in zone at" : prox == 2 ? "arriving at" : "approaching"
            alert(tag + " " + word + " " + f_price(lvl), alert.freq_once_per_bar)
        else if prox == 0
            lastProx := 0

    // Rendering. Objects are created once per slot and moved, never re-created.
    if barstate.islast
        if valid and drawLine
            if not hasLn
                ln := line.new(bar_index - 1, lvl, bar_index, lvl, extend=extend.both, color=cLvl, width=lineWid)
                hasLn := true
            else
                line.set_xy1(ln, bar_index - 1, lvl)
                line.set_xy2(ln, bar_index, lvl)
                line.set_color(ln, cLvl)
                line.set_width(ln, lineWid)
        else if hasLn
            line.delete(ln)
            hasLn := false

        if valid and drawZone
            if not hasZn
                zn := box.new(bar_index - 100, lvl + h, bar_index + 20, lvl - h, border_color=color.new(cLvl, 70), bgcolor=color.new(cLvl, 90))
                hasZn := true
            else
                box.set_lefttop(zn, bar_index - 100, lvl + h)
                box.set_rightbottom(zn, bar_index + 20, lvl - h)
        else if hasZn
            box.delete(zn)
            hasZn := false

    // Gated by the SAME minN as the rate cell. Hard-coded thresholds of 3 and 4 used
    // to print a confident median and a 75th percentile on the same row where the
    // rate cell still read "collecting" - one statistic disclaiming its sample while
    // its neighbour quoted a quartile off four points.
    float medOver = array.size(overs) >= minN ? array.median(overs) : na
    float p75Over = array.size(overs) >= minN ? array.percentile_linear_interpolation(overs, 75) : na
    // A slot that is not counting must say WHY. "INVALID" and "WARMING UP" used to
    // both render as "OUT OF RANGE", which sent the user hunting for a typo in a
    // level that was fine.
    string stTxt = not typed ? "OFF" : lvl < 0 ? "INVALID" : not inBand ? "OUT OF RANGE" : not ready ? "WARMING UP" : state == ST_EVENT ? "PENDING" : state == ST_ARMED ? "ARMED" : state == ST_COOLDOWN ? "COOLDOWN" : "DISARMED"

    int sinceTouch = na(lastTouchBar) ? int(na) : bar_index - lastTouchBar
    // `typed`, not `lvl > 0`: a negative or otherwise unusable level must still occupy
    // a visible row saying INVALID. Hiding it made the panel announce "No levels set"
    // to a user who had just typed one in.
    SlotInfo.new(typed, valid, lvl, n, nRej, nBrk, nChop, medOver, p75Over, sinceTouch, nAbove, nBelow, stTxt, dist, lastOut)

// ─── ENGINE ───────────────────────────────────────────────────────────────────
float atr = ta.atr(atrLen)

// Running extremes of the loaded history, used only for the sanity band.
var float runLo = na
var float runHi = na
runLo := na(runLo) ? low : math.min(runLo, low)
runHi := na(runHi) ? high : math.max(runHi, high)

SlotInfo s1 = f_slot(true, lvl1, atr, runLo, runHi, showLines, showZones, showMarks, "L1")
SlotInfo s2 = f_slot(true, lvl2, atr, runLo, runHi, showLines, showZones, showMarks, "L2")
SlotInfo s3 = f_slot(true, lvl3, atr, runLo, runHi, showLines, showZones, showMarks, "L3")
SlotInfo s4 = f_slot(true, lvl4, atr, runLo, runHi, showLines, showZones, showMarks, "L4")
SlotInfo s5 = f_slot(true, lvl5, atr, runLo, runHi, showLines, showZones, showMarks, "L5")
SlotInfo s6 = f_slot(true, lvl6, atr, runLo, runHi, showLines, showZones, showMarks, "L6")
SlotInfo s7 = f_slot(true, lvl7, atr, runLo, runHi, showLines, showZones, showMarks, "L7")
SlotInfo s8 = f_slot(true, lvl8, atr, runLo, runHi, showLines, showZones, showMarks, "L8")

array<SlotInfo> slots = array.from(s1, s2, s3, s4, s5, s6, s7, s8)

// ─── PANEL ────────────────────────────────────────────────────────────────────
var table led = table.new(panelPos, 7, 11, bgcolor=NS_BG, frame_color=color.new(LWT_ACC_DEF, 38), frame_width=2, border_color=color.new(NS_SEC, 72), border_width=1)

if barstate.isfirst
    table.merge_cells(led, 0, 0, 6, 0)
    table.merge_cells(led, 0, 10, 6, 10)

if barstate.islast
    table.clear(led, 0, 0, 6, 10)
    if showPanel
        table.cell(led, 0, 0, "LEVEL WATCH · TOUCH LEDGER · CURRENT CHART", text_color=NS_WHITE, text_size=panelSize, bgcolor=NS_BG)
        table.cell(led, 0, 1, "LEVEL",  text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 1, 1, "STATE",  text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 2, 1, "DIST",   text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 3, 1, "TOUCHES",text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 4, 1, "R / B / C", text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 5, 1, "REJECTED / ALL", text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)
        table.cell(led, 6, 1, "REJ. OVERSHOOT", text_color=NS_SEC, text_size=panelSize, bgcolor=NS_ROW)

        int row = 2
        for i = 0 to array.size(slots) - 1
            SlotInfo s = array.get(slots, i)
            if (s.on or not hideOff) and row <= 9
                int resolved = s.nRej + s.nBrk + s.nChop
                color stCol = s.state == "PENDING" ? LWT_ACC_DEF : s.state == "ARMED" ? cRej : s.state == "OUT OF RANGE" ? cBrk : NS_SEC
                table.cell(led, 0, row, "L" + str.tostring(i + 1) + "  " + f_price(s.lvl), text_color=s.on ? NS_WHITE : NS_SEC, text_size=panelSize, bgcolor=NS_BG)
                table.cell(led, 1, row, s.state, text_color=stCol, text_size=panelSize, bgcolor=NS_BG)
                table.cell(led, 2, row, na(s.dist) ? "—" : f_atrTxt(s.dist), text_color=NS_LBL, text_size=panelSize, bgcolor=NS_BG)
                table.cell(led, 3, row, str.tostring(s.n) + (na(s.barsSince) ? "" : "  ·  " + str.tostring(s.barsSince) + "b ago"), text_color=NS_LBL, text_size=panelSize, bgcolor=NS_BG)
                table.cell(led, 4, row, str.tostring(s.nRej) + " / " + str.tostring(s.nBrk) + " / " + str.tostring(s.nChop), text_color=NS_LBL, text_size=panelSize, bgcolor=NS_BG)
                // "—" means nothing has happened here yet; "collecting" means events
                // exist but the sample is still too small to quote a percentage. Same
                // two-state vocabulary as the overshoot column, so the row reads consistently.
                table.cell(led, 5, row, s.n == 0 ? "—" : f_rate(s.nRej, resolved, minN), text_color=resolved >= minN ? NS_WHITE : NS_SEC, text_size=panelSize, bgcolor=NS_BG)
                table.cell(led, 6, row, na(s.medOver) ? "collecting" : f_atrTxt(s.medOver) + (na(s.p75Over) ? "" : "  p75 " + f_atrTxt(s.p75Over)), text_color=na(s.medOver) ? NS_SEC : NS_LBL, text_size=panelSize, bgcolor=NS_BG)
                row += 1

        if row == 2
            table.cell(led, 0, 2, "No levels set. Open settings and type a price into Level 1.", text_color=NS_SEC, text_size=panelSize, bgcolor=NS_BG)

        // Kept short on purpose: this cell is merged across the full width, so every
        // extra character stretches column 0 and the whole panel with it. The full
        // definitions (what the rate denominator includes, why overshoot is measured
        // on rejections only) live in the publication description, not on the chart.
        table.cell(led, 0, 10, "R rejected · B broken · C chop · frozen on close; DIST live", text_color=NS_SEC, text_size=panelSize, bgcolor=NS_BG)
````
