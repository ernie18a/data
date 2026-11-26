# Auction & Liquidity Command Center  Volume Profile, Measured

- url: https://www.tradingview.com/script/043tDS3g-Auction-Liquidity-Command-Center-Volume-Profile-Measured/
- type: indicator
- pine_id: PUB;d69c6ac3461d451185295e5c8e4a1fff
- version: 2.0

## Description

Auction & Liquidity Command Center — Volume Profile, Measured

The levels traders already use — prior POC, value area, naked POCs, prior day high/low, session AVWAP, HVN/LVN — each scored by its measured reaction on this chart: how often price rejects vs breaks, and what the fade has been worth in R. Levels with evidence, not levels with vibes. Never a buy or sell.

What it does

Every structure tool draws levels. None of them measures what happens when price gets there. This tool builds the session-anchored auction map with profile-grade accuracy, detects qualified touches of every level, resolves each touch through a triple-barrier outcome, and pools the results by level TYPE into a live scoreboard: pPOC  +0.01R · rej 50% · n156. You see not just where the levels are, but which kinds of levels have actually meant something on this chart — and which are coin flips.

The components, and why they are combined

This is a deliberate synthesis of four parts, each covering the previous one's weakness:


A profile-grade level engine (Market Profile — J. P. Steidlmayer). Nine level types from the session volume-at-price profile and session extremes: prior POC, prior VAH/VAL (classical two-row 70% expansion), naked POCs (prior POCs never revisited), prior day high/low, the session's anchored VWAP, and HVN/LVN volume nodes (prominence-filtered local extremes). Accuracy choices: each bar's volume is distributed range-proportionally across the rows it overlaps (not binned at one point); POC ties break toward the session center. Weakness left open: a drawn level says nothing about whether it matters.
A qualified-touch detector. A level must be ARMED — price fully away from it by at least k×ATR — before a touch of it can count, and it disarms after every touch. Chop sitting on a line cannot enter the record. Approach direction is stored with every event. Weakness left open: a touch is not an outcome.
Triple-barrier outcome resolution (outcome labelling — M. López de Prado). From each touch: REJECT if price moves m×ATR back the way it came first, BREAK if it moves m×ATR through first, TIMEOUT after T bars. Purity rules: barriers are fixed at the ATR of the touch moment; evaluation starts the bar after the touch; a bar hitting both barriers is a timeout, never a guess. Weakness left open: one level's history is n = 1.
Per-TYPE pooling with honesty gates. Statistics pool by level type, never by individual line — a type is a real sample. A type shows no score until a minimum number of its touches have resolved (default 20); until then it reads BUILDING with its count. Timeouts are reported in n but excluded from the reject/break ratio. Fade expectancy = (rejects − breaks) / (rejects + breaks), in R.


How to read it


Rails are colored and styled by type (solid profile levels, dashed day levels, dotted volume nodes, violet naked POCs); each label carries its type's live score or its BUILDING count.
Evidence on the chart: a gray • at every qualified touch, then ○ (teal) where the touch rejected and ✕ (amber) where it broke. Every number on the scoreboard can be audited against the chart.
Dashboard: nearest level and its score, with a plain-language verdict (tends to hold / coin flip / tends to break) so the read needs no statistics background; per-type scoreboard (fade R · reject % · n) for all nine types; touch counts; the exact engine settings in the NOTE row.
Honest expectations: most types on most charts score near zero — that is the truthful baseline, and seeing it protects you from folklore. The value is in the exceptions this chart's own history reveals (for example, day extremes often carry a modest positive fade expectancy while POC retests are a coin flip), and in knowing the difference.


How to use it

Use the scoreboard to weight your own playbook: give more respect to touches of types that have measured well here, less to types that grade as noise — and size accordingly. The "Touch of a MEASURED level" alert fires only when price reaches a type with a real sample behind it. This is context about where price reactions have had structure — never a direction, never an entry signal.

Non-repaint & universality

Profiles, POC/VA/nodes and day levels commit only at session close on confirmed bars; touches and outcomes resolve on confirmed bars; the AVWAP is cumulative within its session. Nothing repaints. The script requests no external data of any kind — no lower timeframes, no security calls — so it runs identically on every plan and every symbol with volume.

Use on any market

Volume source, profile rows, value-area %, node thresholds, arm distance, barriers and sample gates are all inputs. Defaults suit liquid intraday index futures; intraday timeframes give the engine the most touches to learn from.

Originality & credits

The synthesis — a range-proportional session profile, qualified-touch detection, touch-time-ATR triple-barrier outcomes, and per-type pooled reaction statistics displayed as a live scoreboard — is original work for this publication. Concept credits: Market Profile / point of control / value area — J. Peter Steidlmayer; naked (virgin) POC — market-profile literature; anchored VWAP — as popularised in modern trading literature; triple-barrier outcome labelling — M. López de Prado. Implementation and charting design are the author's own.

Disclaimer

Research and education only. NOT financial advice, NOT a signal service, NOT a guarantee of future results. Reaction statistics are empirical frequencies from this chart's limited history, pooled per level type; they change with regime and sample, and a positive expectancy is not a promise. Validate independently and manage your own risk.

## Source Code

````pine
//@version=6
// =============================================================================
//  AUCTION & LIQUIDITY COMMAND CENTER — v1.1 (BOUNDED SCORING)
//  The levels traders already use, built with profile-grade accuracy — and a
//  qualified-touch engine that will feed the reaction-scoring layer (Phase 2).
// -----------------------------------------------------------------------------
//  THE IDEA
//    Every structure tool draws levels. None of them measures what happens when
//    price gets there. This tool draws the session-anchored levels traders
//    already use — prior POC, value-area high/low, naked POCs, prior day
//    high/low, session AVWAP — and detects QUALIFIED touches of each: price
//    must have been genuinely away from a level before a touch counts, so chop
//    sitting on a line cannot pollute the record. The scoring layer (next
//    update) turns those touches into measured reaction statistics per level
//    TYPE: how often price rejects vs breaks, and what the fade has been worth.
//    Levels with evidence, not levels with vibes. Never a buy or sell.
//
//  ACCURACY CHOICES (why this construction)
//    • RANGE-PROPORTIONAL PROFILE — each bar's volume is distributed across
//      every profile row its high–low range overlaps, in proportion to overlap,
//      rather than binned at a single point price. This is the accurate
//      volume-at-price construction.
//    • CLASSICAL VALUE AREA — VAH/VAL grow outward from the POC by comparing
//      TWO-ROW blocks above vs below and adding the larger, until the value
//      fraction (default 70%) is covered — the Market Profile convention.
//      POC ties break toward the session's center (convention).
//    • QUALIFIED TOUCHES — a level is ARMED only when price is at least
//      k × ATR away from it; only an armed level can be touched, and each new
//      level is born unarmed so it cannot self-touch at creation.
//
//  THE LEVEL TYPES (v1)
//    pPOC — prior session's point of control (ages into a naked POC if the
//    following session never touches it) · pVAH / pVAL — prior session's value
//    area · NPOC — older naked POCs, removed when filled · PDH / PDL — prior
//    day high/low · AVWAP — current session's anchored VWAP (the one
//    developing level).
//
//  SCORES ARE BOUNDED, NOT ASSERTED  (v1.1)
//    The outcome test is a SYMMETRIC triple barrier: from a qualified touch,
//    price must travel the same distance either way. If a level type carried no
//    information, rejections and breaks would land 50/50. That makes 50% the
//    honest null - and it makes a raw rejection percentage misleading on its
//    own, because 60% on 20 touches has a 95% interval of roughly 38-78%, which
//    straddles the null completely.
//    Every level type now carries a WILSON 95% interval on its rejection rate.
//    The verbal call is decided by the BOUND: "tends to hold" only when the
//    lower bound clears 50%, "tends to break" only when the upper bound falls
//    below it, and "coin flip" for everything in between - which, on realistic
//    sample sizes, is most of the time. That is the honest answer, not a
//    failure of the tool.
//
//  EXPECTANCY IS NET OF COST  (v1.1)
//    With symmetric barriers a rejection pays +1R and a break costs -1R, so
//    gross expectancy is simply (rejections - breaks) / n. But the round trip is
//    paid on winners and losers alike, so cost subtracts directly from
//    expectancy. The reported figure is now NET: a level type showing +0.10R
//    gross is a LOSING one once a 0.15R round trip is charged. Set the cost to
//    your own execution reality - tighter barriers make it a larger share of R.
//
//  NON-REPAINT
//    Session profiles, POC/VA/PDH/PDL commit only at session close on a
//    confirmed bar; touches resolve on confirmed bars; the AVWAP is cumulative
//    within the session. Nothing repaints. No external data of any kind is
//    requested — the tool runs identically on every plan and symbol.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Market Profile / point of control / value area — J. Peter Steidlmayer.
//    • Naked (virgin) POC — market-profile trading literature.
//    • Anchored VWAP — B. Steenbarger / A. Shellhorn popularisations.
//    • Triple-barrier outcome labelling (Phase 2 scoring) — M. López de Prado.
//    Implementation and charting design are the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. Levels are descriptive structures from
//    this chart's own history; touch records are counts, not predictions.
//    Validate independently and manage your own risk.
// =============================================================================
indicator("Auction & Liquidity Command Center — Volume Profile, Measured", "CmdCenter",
     overlay = true, max_lines_count = 100, max_labels_count = 500, max_bars_back = 5000)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
volSrc = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume used for the session volume-at-price profile and the AVWAP.")

// ═════════════════════════ 01 · PROFILE & LEVELS ════════════════════════════
g1 = "01 · Profile & levels"
rows = input.int(30, "Profile rows per session", minval = 10, maxval = 60, group = g1,
     tooltip = "Price rows the session's volume is distributed into (range-proportional). More rows = finer POC/VA, needs liquid volume.")
valuePct = input.float(70.0, "Value-area volume %", minval = 50.0, maxval = 90.0, step = 5.0, group = g1,
     tooltip = "Fraction of session volume the value area must cover. 70% is the Market Profile convention.")
npocKeep = input.int(10, "Naked POCs kept", minval = 2, maxval = 20, group = g1,
     tooltip = "Oldest naked POCs beyond this cap are dropped from the map.")
hvnFrac = input.float(0.6, "HVN threshold (× POC volume)", minval = 0.3, maxval = 0.95, step = 0.05, group = g1,
     tooltip = "A local volume peak becomes an HVN level only if it holds at least this fraction of the POC's volume (prominence filter; POC-adjacent bins excluded). Max 2 per session.")
lvnFrac = input.float(0.4, "LVN threshold (× mean row volume)", minval = 0.1, maxval = 0.8, step = 0.05, group = g1,
     tooltip = "A local volume trough becomes an LVN level only if it holds at most this fraction of the mean row volume (interior of the profile only). Max 2 per session.")

// ═════════════════════════ 02 · TOUCH ENGINE ════════════════════════════════
g2 = "02 · Touch engine"
atrLen = input.int(14, "ATR length", minval = 5, maxval = 100, group = g2)
armK = input.float(0.5, "Arm distance (× ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = g2,
     tooltip = "A level must be at least this many ATRs away from price before a touch of it can count (and again between touches). This keeps chop-sitting out of the record — the purity gate of the whole engine.")

// ═════════════════════════ 03 · REACTION SCORING ════════════════════════════
gS = "03 · Reaction scoring"
barrierM = input.float(1.0, "Outcome barrier (× ATR)", minval = 0.3, maxval = 3.0, step = 0.1, group = gS,
     tooltip = "From a qualified touch, REJECT = price moves this many ATRs back the way it came before moving the same distance through the level (BREAK). Barriers are fixed at the ATR that existed AT THE TOUCH — outcomes are judged by the volatility of their own moment.")
timeBar = input.int(20, "Time barrier (bars)", minval = 5, maxval = 100, group = gS,
     tooltip = "Unresolved after this many bars = TIMEOUT. Timeouts are reported but excluded from the reject/break ratio.")
useTouchCost = input.bool(true, "Charge round-trip cost to expectancy", group = gS, tooltip = "ON: the expected-R figure is reported NET of round-trip cost. Costs are paid on winners and losers alike, so they subtract directly from expectancy - a +0.10R level type is a losing one once a 0.15R round trip is charged.")
touchCostR = input.float(0.10, "Round-trip cost (in R)", minval = 0.0, maxval = 1.0, step = 0.01, group = gS, tooltip = "Spread plus brokerage plus slippage, expressed as a fraction of the barrier distance (1R = barrier x ATR). With a 1.0 ATR barrier on a liquid index future, 0.05-0.15R is typical; tighter barriers make cost a larger share of R.")
minSample = input.int(20, "Minimum resolved touches per type", minval = 5, maxval = 200, group = gS,
     tooltip = "Honesty gate: a level TYPE shows no score until this many of its touches have resolved (reject or break). Until then it reads BUILDING with its count.")

// ═════════════════════════ 04 · OUTPUT ══════════════════════════════════════
g3 = "04 · Output"
showRails   = input.bool(true, "Draw level rails", group = g3)
showLvLabels= input.bool(true, "Label levels", group = g3)
showAvwap   = input.bool(true, "Plot session AVWAP", group = g3)
showTouches = input.bool(true, "Mark qualified touches", group = g3,
     tooltip = "A small marker prints at every qualified touch — the raw observations the reaction statistics are measured from.")
showOutcomes = input.bool(true, "Mark touch outcomes", group = g3,
     tooltip = "Where each touch resolved: ○ = rejected (level held, teal), ✕ = broke (level gave way, amber). The evidence behind every score, visible on the chart.")

// ═════════════════════════ 05 · DASHBOARD ═══════════════════════════════════
g4 = "05 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g4)
compactTbl= input.bool(false, "Compact dashboard", group = g4)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g4)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g4)

// ═════════════════════════ 06 · STYLE ═══════════════════════════════════════
g5 = "06 · Style"
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g5)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0
var color COL_REV  = #a06cf0

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cWarn  = isDark ? #ffa94d : #b56a00
color cMute  = isDark ? #6b7480 : #98a0ab
color zebraA = isDark ? color.new(#141a26, 0) : color.new(#eef1f6, 0)
color zebraB = isDark ? color.new(#0e131d, 0) : color.new(#f8fafc, 0)
color frameCl = tBord

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// level types: 0 pPOC · 1 pVAH · 2 pVAL · 3 NPOC · 4 PDH · 5 PDL · 6 AVWAP
// (7/8 reserved for HVN/LVN in v1.1)
f_typeName(int t) =>
    t == 0 ? "pPOC" : t == 1 ? "pVAH" : t == 2 ? "pVAL" : t == 3 ? "NPOC" : t == 4 ? "PDH" : t == 5 ? "PDL" : t == 6 ? "AVWAP" : t == 7 ? "HVN" : t == 8 ? "LVN" : "?"
f_typeColor(int t) =>
    t == 0 ? color.new(COL_MID, 0) : t == 1 or t == 2 ? color.new(COL_MID, 45) : t == 3 ? color.new(COL_REV, 25) : t == 7 ? color.new(COL_MID, 60) : t == 8 ? color.new(cMute, 30) : color.new(COL_INFO, 35)

// ───────────────────────── SESSION MACHINERY ────────────────────────────────
int dayTime = time("D")
bool newSess = ta.change(dayTime) != 0
var int sessIdx = 0
float atr = ta.atr(atrLen)

// per-session bar storage for the range-proportional profile (cleared each session)
var float[] sesH = array.new_float(0)
var float[] sesL = array.new_float(0)
var float[] sesV = array.new_float(0)

// ───────────────────────── LEVEL REGISTRY (parallel arrays) ─────────────────
var int[]   lvType  = array.new_int(0)
var float[] lvPrice = array.new_float(0)
var line[]  lvLine  = array.new<line>()
var label[] lvLab   = array.new<label>()
var bool[]  lvArmed = array.new_bool(0)
var bool ppocTouched = false

f_addLevel(int t, float p) =>
    array.push(lvType, t)
    array.push(lvPrice, p)
    array.push(lvArmed, false)   // born unarmed: cannot self-touch at creation
    line ln = na
    label lb = na
    if showRails
        ln := line.new(bar_index, p, bar_index + 1, p, xloc.bar_index, extend = extend.right,
             color = f_typeColor(t), width = t == 0 ? 2 : 1,
             style = t == 4 or t == 5 ? line.style_dashed : t >= 7 ? line.style_dotted : line.style_solid)
    if showLvLabels
        lb := label.new(bar_index, p, f_typeName(t) + " " + str.tostring(p, format.mintick),
             style = label.style_label_left, color = color.new(isDark ? #0e131d : #f8fafc, 25),
             textcolor = f_typeColor(t), size = size.small)
    array.push(lvLine, ln)
    array.push(lvLab, lb)

f_removeLevel(int i) =>
    line ln = array.get(lvLine, i)
    label lb = array.get(lvLab, i)
    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)
    array.remove(lvLine, i)
    array.remove(lvLab, i)
    array.remove(lvType, i)
    array.remove(lvPrice, i)
    array.remove(lvArmed, i)

// count levels of a type (for NPOC cap / dashboard)
f_countType(int t) =>
    int c = 0
    if array.size(lvType) > 0
        for i = 0 to array.size(lvType) - 1
            if array.get(lvType, i) == t
                c += 1
    c

// index of the OLDEST level of a type (lowest registry index)
f_firstOfType(int t) =>
    int idx = -1
    if array.size(lvType) > 0
        for i = 0 to array.size(lvType) - 1
            if idx < 0 and array.get(lvType, i) == t
                idx := i
    idx

// ───────────────────────── PROFILE → POC & VALUE AREA ───────────────────────
// Range-proportional volume-at-price: each bar's volume is spread across the
// rows its high–low range overlaps, proportional to overlap. POC = peak row
// (ties break toward the session center). Value area grows from the POC by the
// classical two-row comparison until valuePct of volume is covered.
f_profile() =>
    float poc = na
    float vah = na
    float val = na
    float h1 = na
    float h2 = na
    float l1 = na
    float l2 = na
    float h1v = -1.0
    float h2v = -1.0
    float l1v = 1.0e18
    float l2v = 1.0e18
    int n = array.size(sesH)
    if n > 5
        float lo = array.min(sesL)
        float hi = array.max(sesH)
        if hi > lo
            float binW = (hi - lo) / rows
            float[] binV = array.new_float(rows, 0.0)
            for i = 0 to n - 1
                float bl = math.max(lo, array.get(sesL, i))
                float bh = math.min(hi, array.get(sesH, i))
                float v = array.get(sesV, i)
                if bh <= bl
                    int b1 = int((bl - lo) / binW)
                    b1 := math.max(0, math.min(rows - 1, b1))
                    array.set(binV, b1, array.get(binV, b1) + v)
                else
                    float dens = v / (bh - bl)
                    int b0 = int((bl - lo) / binW)
                    int b2 = int((bh - lo) / binW)
                    b0 := math.max(0, math.min(rows - 1, b0))
                    b2 := math.max(0, math.min(rows - 1, b2))
                    for b = b0 to b2
                        float top = lo + (b + 1) * binW
                        float bot = lo + b * binW
                        float ov = math.min(bh, top) - math.max(bl, bot)
                        if ov > 0
                            array.set(binV, b, array.get(binV, b) + dens * ov)
            // POC: peak volume; ties break toward session center (convention)
            int bBest = 0
            float vBest = -1.0
            float ctr = (rows - 1) / 2.0
            for b = 0 to rows - 1
                float vb = array.get(binV, b)
                bool better = vb > vBest + 1e-9
                bool tie = math.abs(vb - vBest) <= 1e-9 and math.abs(b - ctr) < math.abs(bBest - ctr)
                if better or tie
                    vBest := vb
                    bBest := b
            poc := lo + (bBest + 0.5) * binW
            // value area: classical two-row expansion from the POC
            float total = array.sum(binV)
            float target = total * valuePct / 100.0
            float covered = array.get(binV, bBest)
            int up = bBest + 1
            int dn = bBest - 1
            int vaTop = bBest
            int vaBot = bBest
            while covered < target and (up <= rows - 1 or dn >= 0)
                float upVol = (up <= rows - 1 ? array.get(binV, up) : 0.0) + (up + 1 <= rows - 1 ? array.get(binV, up + 1) : 0.0)
                float dnVol = (dn >= 0 ? array.get(binV, dn) : 0.0) + (dn - 1 >= 0 ? array.get(binV, dn - 1) : 0.0)
                if up > rows - 1
                    covered += dnVol
                    vaBot := math.max(0, dn - 1)
                    dn -= 2
                else if dn < 0
                    covered += upVol
                    vaTop := math.min(rows - 1, up + 1)
                    up += 2
                else if upVol >= dnVol
                    covered += upVol
                    vaTop := math.min(rows - 1, up + 1)
                    up += 2
                else
                    covered += dnVol
                    vaBot := math.max(0, dn - 1)
                    dn -= 2
            vah := lo + (vaTop + 1) * binW
            val := lo + vaBot * binW
            // HVN/LVN: prominence-filtered local volume extremes, interior of
            // the profile only, POC and its neighbours excluded; strongest two
            // of each kept
            float meanV = total / rows
            for b = 2 to rows - 3
                if math.abs(b - bBest) > 1
                    float vb = array.get(binV, b)
                    bool pk = vb > array.get(binV, b - 1) and vb > array.get(binV, b + 1) and vb >= array.get(binV, b - 2) and vb >= array.get(binV, b + 2)
                    bool tr = vb < array.get(binV, b - 1) and vb < array.get(binV, b + 1) and vb <= array.get(binV, b - 2) and vb <= array.get(binV, b + 2)
                    float px = lo + (b + 0.5) * binW
                    if pk and vb >= hvnFrac * vBest
                        if vb > h1v
                            h2 := h1
                            h2v := h1v
                            h1 := px
                            h1v := vb
                        else if vb > h2v
                            h2 := px
                            h2v := vb
                    if tr and vb > 0 and vb <= lvnFrac * meanV
                        if vb < l1v
                            l2 := l1
                            l2v := l1v
                            l1 := px
                            l1v := vb
                        else if vb < l2v
                            l2 := px
                            l2v := vb
    [poc, vah, val, h1, h2, l1, l2]

// ───────────────────────── SESSION CLOSE → COMMIT LEVELS ────────────────────
var float pdhVal = na
var float pdlVal = na
if newSess and barstate.isconfirmed
    [poc, vah, val, hvn1, hvn2, lvn1, lvn2] = f_profile()
    float sHi = array.size(sesH) > 0 ? array.max(sesH) : na
    float sLo = array.size(sesL) > 0 ? array.min(sesL) : na
    // 1) age the old pPOC: untouched → becomes a naked POC; touched → retire
    int iPoc = f_firstOfType(0)
    if iPoc >= 0
        if not ppocTouched
            array.set(lvType, iPoc, 3)
            line lnP = array.get(lvLine, iPoc)
            label lbP = array.get(lvLab, iPoc)
            if not na(lnP)
                line.set_color(lnP, f_typeColor(3))
                line.set_width(lnP, 1)
            if not na(lbP)
                label.set_text(lbP, f_typeName(3) + " " + str.tostring(array.get(lvPrice, iPoc), format.mintick))
                label.set_textcolor(lbP, f_typeColor(3))
        else
            f_removeLevel(iPoc)
    // NPOC cap
    while f_countType(3) > npocKeep
        int iOld = f_firstOfType(3)
        f_removeLevel(iOld)
    // 2) retire yesterday's singletons (VAH/VAL/PDH/PDL)
    int j = array.size(lvType) - 1
    while j >= 0
        int t = array.get(lvType, j)
        if t == 1 or t == 2 or t == 4 or t == 5 or t == 7 or t == 8
            f_removeLevel(j)
        j -= 1
    // 3) commit the new set
    if not na(poc)
        f_addLevel(0, poc)
        f_addLevel(1, vah)
        f_addLevel(2, val)
        if not na(hvn1)
            f_addLevel(7, hvn1)
        if not na(hvn2)
            f_addLevel(7, hvn2)
        if not na(lvn1)
            f_addLevel(8, lvn1)
        if not na(lvn2)
            f_addLevel(8, lvn2)
    if not na(sHi)
        f_addLevel(4, sHi)
        f_addLevel(5, sLo)
        pdhVal := sHi
        pdlVal := sLo
    ppocTouched := false
    sessIdx += 1
    array.clear(sesH)
    array.clear(sesL)
    array.clear(sesV)

if barstate.isconfirmed
    array.push(sesH, high)
    array.push(sesL, low)
    array.push(sesV, nz(volSrc, 0.0))

// ───────────────────────── SESSION AVWAP (developing level) ─────────────────
var float cumPV = 0.0
var float cumV  = 0.0
if newSess
    cumPV := 0.0
    cumV  := 0.0
if barstate.isconfirmed
    cumPV += hlc3 * nz(volSrc, 0.0)
    cumV  += nz(volSrc, 0.0)
float avwap = cumV > 0 ? cumPV / cumV : na
plot(showAvwap ? avwap : na, "Session AVWAP", color = color.new(COL_INFO, 15), linewidth = 1, style = plot.style_linebr)
var bool avArmed = false

// ───────────────────────── REACTION STATISTICS (per level type) ─────────────
// pooled by TYPE, never by individual line: one line is n=1 forever; a type is
// a real sample. Timeouts reported, excluded from the reject/break ratio.
var int[] rejN = array.new_int(9, 0)
var int[] brkN = array.new_int(9, 0)
var int[] toN  = array.new_int(9, 0)
var int resolvedTotal = 0

// WILSON 95% INTERVAL on the rejection rate. The outcome test is a SYMMETRIC
// triple barrier - price is equally likely to hit either side if the level is
// meaningless - so the honest null is a 50% rejection rate. A point estimate of
// 60% on n=20 has an interval roughly [38%, 78%], which straddles 50% and is
// therefore no evidence at all. A level TYPE only "tends to hold" when the
// LOWER bound clears 50%, and only "tends to break" when the UPPER bound falls
// below it. Everything else is honestly reported as undecided.
f_wilson(int hits, int n, bool wantLo) =>
    float outv = na
    if n > 0
        float ph  = hits / float(n)
        float z   = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := (wantLo ? ctr - hlf : ctr + hlf) / (1.0 + z * z / n) * 100.0
    outv

f_rejLo(int t) =>
    int nn = array.get(rejN, t) + array.get(brkN, t)
    nn >= minSample ? f_wilson(array.get(rejN, t), nn, true) : na

f_rejHi(int t) =>
    int nn = array.get(rejN, t) + array.get(brkN, t)
    nn >= minSample ? f_wilson(array.get(rejN, t), nn, false) : na

// verdict: +1 holds, -1 breaks, 0 undecided - decided by the BOUND, not the mean
f_verdict(int t) =>
    float lo = f_rejLo(t)
    float hi = f_rejHi(t)
    na(lo) or na(hi) ? 0 : lo > 50.0 ? 1 : hi < 50.0 ? -1 : 0

f_typeMeasured(int t) =>
    array.get(rejN, t) + array.get(brkN, t) >= minSample

// Expected R per resolved touch. With symmetric +/- barrierM*ATR barriers a
// rejection pays +1R and a break costs -1R, so gross E[R] = (rej - brk)/n.
// Costs hit BOTH outcomes - you pay the round trip whether you win or lose -
// so they subtract directly from the expectancy, expressed in R.
f_costR() => useTouchCost ? touchCostR : 0.0

f_fadeR(int t) =>
    int rj = array.get(rejN, t)
    int bk = array.get(brkN, t)
    int nn = rj + bk
    nn >= minSample ? (rj - bk) / float(nn) - f_costR() : na

f_scoreTxt(int t) =>
    int rj = array.get(rejN, t)
    int bk = array.get(brkN, t)
    int tmo = array.get(toN, t)
    int nn = rj + bk
    string s = ""
    if nn >= minSample
        float fr = (rj - bk) / float(nn) - f_costR()
        float lo = f_wilson(rj, nn, true)
        s := (fr >= 0 ? "+" : "") + str.tostring(fr, "0.00") + "R net · rej " + str.tostring(math.round(100.0 * rj / nn)) + "% (LB " + str.tostring(lo, "0") + "%) · n" + str.tostring(nn + tmo)
    else
        s := "building (" + str.tostring(nn + tmo) + ")"
    s

// ───────────────────────── QUALIFIED-TOUCH ENGINE ───────────────────────────
// Event queue for the Phase-2 scoring layer: type · approach direction ·
// touch price · age. Direction: +1 = approached from above (prior close above
// the level), -1 = from below.
var int[]   evType = array.new_int(0)
var int[]   evDir  = array.new_int(0)
var float[] evPx   = array.new_float(0)
var int[]   evAge  = array.new_int(0)
var float[] evAtr  = array.new_float(0)   // ATR at the touch: barriers are fixed at their own moment
var label[] touchMarks = array.new<label>()
var label[] outcomeMarks = array.new<label>()
var int touchesTotal = 0
var int touchesToday = 0
if newSess
    touchesToday := 0

bool touchOccurred = false
bool measuredTouch = false
if barstate.isconfirmed and not na(atr)
    // registry levels
    int i = array.size(lvPrice) - 1
    while i >= 0
        float p = array.get(lvPrice, i)
        int t = array.get(lvType, i)
        bool armed = array.get(lvArmed, i)
        if armed and low <= p and p <= high
            int dir = nz(close[1], close) >= p ? 1 : -1
            array.push(evType, t)
            array.push(evDir, dir)
            array.push(evPx, p)
            array.push(evAge, 0)
            array.push(evAtr, atr)
            touchesTotal += 1
            touchesToday += 1
            touchOccurred := true
            if array.get(rejN, t) + array.get(brkN, t) >= minSample
                measuredTouch := true
            if t == 0
                ppocTouched := true
            if showTouches
                lm = label.new(bar_index, p, "•", style = label.style_none, textcolor = color.new(cMute, 10), size = size.small, tooltip = f_typeName(t) + " qualified touch — one observation for the reaction statistics.")
                array.push(touchMarks, lm)
                if array.size(touchMarks) > 200
                    label.delete(array.shift(touchMarks))
            if t == 3
                f_removeLevel(i)      // naked POC filled → off the map
            else
                array.set(lvArmed, i, false)
        else if not armed
            bool away = high < p or low > p
            if away and math.abs(close - p) >= armK * atr
                array.set(lvArmed, i, true)
        i -= 1
    // AVWAP (developing level, same qualification)
    if not na(avwap)
        if avArmed and low <= avwap and avwap <= high
            int dirA = nz(close[1], close) >= avwap ? 1 : -1
            array.push(evType, 6)
            array.push(evDir, dirA)
            array.push(evPx, avwap)
            array.push(evAge, 0)
            array.push(evAtr, atr)
            touchesTotal += 1
            if array.get(rejN, 6) + array.get(brkN, 6) >= minSample
                measuredTouch := true
            touchesToday += 1
            touchOccurred := true
            avArmed := false
            if showTouches
                lmA = label.new(bar_index, avwap, "•", style = label.style_none, textcolor = color.new(cMute, 10), size = size.small, tooltip = "AVWAP qualified touch — one observation for the reaction statistics.")
                array.push(touchMarks, lmA)
                if array.size(touchMarks) > 200
                    label.delete(array.shift(touchMarks))
        else if not avArmed
            bool awayA = high < avwap or low > avwap
            if awayA and math.abs(close - avwap) >= armK * atr
                avArmed := true
    // triple-barrier resolution: evaluation starts the BAR AFTER the touch
    // (the touch bar's range includes pre-touch movement). A bar hitting both
    // barriers at once is ambiguous → counted as a timeout, never guessed.
    int e = array.size(evType) - 1
    while e >= 0
        int ag = array.get(evAge, e)
        if ag == 0
            array.set(evAge, e, 1)
        else
            int ty = array.get(evType, e)
            int dr = array.get(evDir, e)
            float px = array.get(evPx, e)
            float at = array.get(evAtr, e)
            float upB = px + barrierM * at
            float dnB = px - barrierM * at
            bool hitUp = high >= upB
            bool hitDn = low <= dnB
            bool rej = dr == 1 ? hitUp : hitDn
            bool brk = dr == 1 ? hitDn : hitUp
            int res = -1
            if rej and brk
                res := 0
            else if rej
                res := 1
            else if brk
                res := 2
            else if ag >= timeBar
                res := 0
            if res >= 0
                if res == 1
                    array.set(rejN, ty, array.get(rejN, ty) + 1)
                if res == 2
                    array.set(brkN, ty, array.get(brkN, ty) + 1)
                if res == 0
                    array.set(toN, ty, array.get(toN, ty) + 1)
                resolvedTotal += 1
                if showOutcomes and res != 0
                    string oTxt = res == 1 ? "○" : "✕"
                    color oCl = res == 1 ? color.new(cBull, 10) : color.new(cWarn, 10)
                    om = label.new(bar_index, px, oTxt, style = label.style_none, textcolor = oCl, size = size.small, tooltip = f_typeName(ty) + (res == 1 ? " touch REJECTED (level held) at ±" : " touch BROKE through at ±") + str.tostring(barrierM, "0.0") + "×ATR")
                    array.push(outcomeMarks, om)
                    if array.size(outcomeMarks) > 200
                        label.delete(array.shift(outcomeMarks))
                array.remove(evType, e)
                array.remove(evDir, e)
                array.remove(evPx, e)
                array.remove(evAge, e)
                array.remove(evAtr, e)
            else
                array.set(evAge, e, ag + 1)
        e -= 1
    while array.size(evAge) > 200
        array.shift(evType)
        array.shift(evDir)
        array.shift(evPx)
        array.shift(evAge)
        array.shift(evAtr)

// keep level labels beside the live edge, carrying their type's score
if barstate.islast and showLvLabels and array.size(lvLab) > 0
    for i = 0 to array.size(lvLab) - 1
        label lb = array.get(lvLab, i)
        if not na(lb)
            int t = array.get(lvType, i)
            string sc = f_scoreTxt(t)
            label.set_text(lb, f_typeName(t) + " " + str.tostring(array.get(lvPrice, i), format.mintick) + " · " + sc)
            label.set_x(lb, bar_index + 3)

// nearest level (for dashboard / exports)
float nearPx = na
int nearType = -1
if barstate.islast
    float bestD = na
    if array.size(lvPrice) > 0
        for i = 0 to array.size(lvPrice) - 1
            float d = math.abs(close - array.get(lvPrice, i))
            if na(bestD) or d < bestD
                bestD := d
                nearPx := array.get(lvPrice, i)
                nearType := array.get(lvType, i)
    if not na(avwap)
        float dA = math.abs(close - avwap)
        if na(bestD) or dA < bestD
            bestD := dA
            nearPx := avwap
            nearType := 6

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

var table dash = na
if showDash and barstate.islast
    int nMeas = 0
    for t = 0 to 8
        if array.get(rejN, t) + array.get(brkN, t) >= minSample
            nMeas += 1
    color stBg = nMeas > 0 ? color.new(COL_INFO, 0) : color.new(cMute, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : 14, border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " COMMAND CENTER", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Session-anchored auction levels, each TYPE scored by its measured reaction on this chart: reject vs break within ±ATR barriers, fade expectancy in R. Empirical, per-type, this chart only — never a direction.")
    table.cell(dash, 1, 0, (nMeas == 0 ? "BUILDING" : str.tostring(nMeas) + "/9 MEASURED") + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    string nearTxt = na(nearPx) ? "-" : f_typeName(nearType) + " " + str.tostring(nearPx, format.mintick)
    f_setRow(dash, 1, "NEAREST LEVEL", nearTxt, tVal, tLbl, zebraA)
    string nearScore = "-"
    if nearType >= 0
        nearScore := f_scoreTxt(nearType)
        if f_typeMeasured(nearType)
            float nfr = f_fadeR(nearType)
            int nvd = f_verdict(nearType)
            nearScore := nearScore + (nvd == 1 ? " · tends to hold" : nvd == -1 ? " · tends to break" : " · coin flip")
    f_setRow(dash, 2, "NEAREST SCORE", nearScore, nearType >= 0 and f_typeMeasured(nearType) ? tVal : cMute, tLbl, zebraB)
    f_setRow(dash, 3, "TOUCHES", str.tostring(touchesToday) + " today · " + str.tostring(resolvedTotal) + " resolved", tVal, tLbl, zebraA)
    if not compactTbl
        f_setRow(dash, 4, "pPOC",  f_scoreTxt(0), f_typeMeasured(0) ? tVal : cMute, tLbl, zebraB)
        f_setRow(dash, 5, "pVAH",  f_scoreTxt(1), f_typeMeasured(1) ? tVal : cMute, tLbl, zebraA)
        f_setRow(dash, 6, "pVAL",  f_scoreTxt(2), f_typeMeasured(2) ? tVal : cMute, tLbl, zebraB)
        f_setRow(dash, 7, "NPOC (" + str.tostring(f_countType(3)) + " live)", f_scoreTxt(3), f_typeMeasured(3) ? tVal : cMute, tLbl, zebraA)
        f_setRow(dash, 8, "PDH",   f_scoreTxt(4), f_typeMeasured(4) ? tVal : cMute, tLbl, zebraB)
        f_setRow(dash, 9, "PDL",   f_scoreTxt(5), f_typeMeasured(5) ? tVal : cMute, tLbl, zebraA)
        f_setRow(dash, 10, "AVWAP", f_scoreTxt(6), f_typeMeasured(6) ? tVal : cMute, tLbl, zebraB)
        f_setRow(dash, 11, "HVN",   f_scoreTxt(7), f_typeMeasured(7) ? tVal : cMute, tLbl, zebraA)
        f_setRow(dash, 12, "LVN",   f_scoreTxt(8), f_typeMeasured(8) ? tVal : cMute, tLbl, zebraB)
        f_setRow(dash, 13, "NOTE", "arm " + str.tostring(armK, "0.0") + " · barrier " + str.tostring(barrierM, "0.0") + "×ATR · t" + str.tostring(timeBar) + " · per-type, this chart only", cMute, tLbl, zebraA)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Command Center  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(nearPx, "Nearest Level Price", display = display.data_window)
plot(nearType, "Nearest Level Type", display = display.data_window)
plot(touchesTotal, "Touches Total", display = display.data_window)
plot(array.size(evType), "Open Events", display = display.data_window)
plot(f_countType(3), "Naked Count", display = display.data_window)
plot(pdhVal, "Prior Day High", display = display.data_window)
plot(pdlVal, "Prior Day Low", display = display.data_window)
plot(resolvedTotal, "Resolved Total", display = display.data_window)
plot(f_fadeR(0), "pPOC Fade R",  display = display.data_window)
plot(f_fadeR(1), "VAH Fade R",   display = display.data_window)
plot(f_fadeR(2), "VAL Fade R",   display = display.data_window)
plot(f_fadeR(3), "NPOC Fade R",  display = display.data_window)
plot(f_fadeR(4), "PDH Fade R",   display = display.data_window)
plot(f_fadeR(5), "PDL Fade R",   display = display.data_window)
plot(f_fadeR(6), "AVWAP Fade R", display = display.data_window)
plot(f_fadeR(7), "HVN Fade R",   display = display.data_window)
plot(f_fadeR(8), "LVN Fade R",   display = display.data_window)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(touchOccurred, "Qualified level touch", "Command Center: a level was touched after a qualified approach")
alertcondition(measuredTouch, "Touch of a MEASURED level", "Command Center: price touched a level type with a measured reaction score — check the scoreboard")
alertcondition(newSess, "New session", "Command Center: session rolled — levels re-committed")
````
