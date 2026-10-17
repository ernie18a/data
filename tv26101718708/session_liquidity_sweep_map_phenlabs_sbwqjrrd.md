# Session Liquidity Sweep Map [PhenLabs]

- url: https://www.tradingview.com/script/SbwqjRrd-Session-Liquidity-Sweep-Map-PhenLabs/
- type: indicator
- pine_id: PUB;6310557bbdf7427ab485691b3dc516e3
- version: 1.0

## Description

[b]📊 Session Liquidity Sweep Map [PhenLabs][/b]
Version: PineScript™ v6

[b]📌 Description[/b]
The Session Liquidity Sweep Map (SLSM) is a session-anchored liquidity engine that maps where resting orders accumulate around the Asia, London, and New York session extremes, then tracks the full life cycle of those pools from formation, to sweep, to structural confirmation. Rather than plotting static swing lines, SLSM treats each finalized session high and low as buy-side or sell-side liquidity and watches for the precise moment price raids that liquidity and rejects.

The indicator solves a core problem for intraday traders: distinguishing a genuine stop-run that leads to a reversal from a clean breakout that continues. By requiring a wick-rejection sweep to be followed by a market structure shift within a defined window, SLSM filters out unconfirmed pokes and only elevates sweeps that are validated by a CHoCH in the opposite direction.

Once a sweep is confirmed, SLSM projects the most logical opposing draw on liquidity and lays out structure-based R-multiple targets, giving you a complete read on where price came from and where it is likely being pulled next.

[b]🚀 Points of Innovation[/b]
[list]
[*]Full pool life-cycle state machine: Building → Complete → Swept → Awaiting MSS → Confirmed / no-MSS
[*]Two-stage validation that pairs a wick-rejection sweep with a mandatory structure-shift confirmation
[*]Dual sweep triggers: classic close-back-inside rejection or an ATR-scaled displacement break
[*]Equal-high/low clustering that merges stacked liquidity into a single weighted pool
[*]Confidence score blending rejection-wick quality, MSS speed, and displacement magnitude
[*]Live dashboard surfacing the nearest untaken BSL above and SSL below current price
[/list]

[b]🔧 Core Components[/b]
[list]
[*]Session Tracker: Builds developing highs/lows per session in a user-selected timezone and finalizes them into resting pools at session close
[*]Pool Manager: Creates, clusters, caps, ages out, and visually fades liquidity pools to respect drawing-object limits
[*]Sweep Engine: Flags a pool as swept when a confirmed bar penetrates it by the tick tolerance and rejects, or breaks it with displacement
[*]MSS Validator: Watches the protected swing point and confirms the sweep on an opposite-direction close within the lookahead window
[*]Projection Module: Plots the opposing draw and R-multiple targets measured from the sweep extreme
[/list]

[b]🔥 Key Features[/b]
[list]
[*]Non-repainting logic: pools finalize at close, sweep/MSS evaluate only on confirmed bars, swings use right-anchored pivots
[*]Configurable kill-zone shading that tints the background while each session is active
[*]Equal-level clustering with an adjustable tick tolerance to keep the chart clean
[*]Per-side pool cap that automatically removes the oldest untaken pool when limits are reached
[*]Three discrete alerts: liquidity swept, sweep + MSS confirmed, and new opposing draw projected
[/list]

[b]🎨 Visualization[/b]
[list]
[*]Liquidity Lines: Solid session-colored levels for live pools that fade and dash once swept
[*]Sweep & MSS Labels: Directional sweep tags and a “MSS ✓” confirmation label with optional confidence score
[*]Draw & Targets: A dotted opposing-draw line plus dashed R-multiple target lines from the sweep extreme
[*]Dashboard: Per-session phase and high/low, with the nearest untaken BSL/SSL relative to price
[/list]

[b]📖 Usage Guidelines[/b]
[b]Sessions[/b]
[list]
[*]Session Windows (Asia/London/NY) — Default: 2000-0000 / 0200-0500 / 0930-1100 — Description: Defines each kill-zone in the chosen timezone; adjust to your instrument’s active hours
[*]Kill-zone transparency — Default: 90 — Range: 50-99 — Description: Controls background tint intensity for active sessions
[/list]
[b]Sweep Detection[/b]
[list]
[*]Penetration tolerance (ticks) — Default: 2 — Description: Minimum overshoot beyond a pool required to register a sweep
[*]Require close back inside — Default: true — Description: Demands a wick-rejection close; the robust default
[*]Displacement body x ATR — Default: 1.0 — Range: 0.2+ — Description: Body size relative to ATR for the alternative displacement trigger
[/list]
[b]MSS / Structure[/b]
[list]
[*]Swing pivot length — Default: 5 — Range: 2+ — Description: Left/right strength for non-repainting swing detection
[*]MSS lookahead (bars) — Default: 20 — Range: 3+ — Description: Bars allowed after a sweep for the structure break to confirm
[/list]

[b]✅ Best Use Cases[/b]
[list]
[*]Intraday reversal trading off Asia/London/NY session stop-runs
[*]ICT and Smart Money workflows centered on liquidity raids and CHoCH confirmation
[*]Bias-building by reading the nearest untaken liquidity as the directional draw
[*]Scalping and futures/index/crypto sessions with defined kill-zone windows
[/list]

[b]⚠️ Limitations[/b]
[list]
[*]Performance depends on correct timezone and session-window configuration per instrument
[*]The MSS lookahead window can expire on slow markets, leaving valid sweeps marked no-MSS
[*]Designed for intraday timeframes; session anchoring is less meaningful on HTF charts
[*]Confirmation introduces a deliberate lag versus the raw sweep, by design
[/list]

[b]💡 What Makes This Unique[/b]
[list]
[*]Session-anchored pools rather than generic swing liquidity, tying liquidity to behavioral kill-zones
[*]Mandatory two-stage sweep + MSS confirmation that suppresses unvalidated breakouts
[*]An integrated draw-and-target projection that completes the from/to liquidity narrative
[/list]

[b]🔬 How It Works[/b]
[b]1. Pool Formation[/b]
[list]
[*]Each session tracks a developing high and low while active, then finalizes both as resting liquidity at close
[*]Highs become buy-side liquidity (BSL) above; lows become sell-side liquidity (SSL) below
[/list]
[b]2. Sweep & Structure Shift[/b]
[list]
[*]A confirmed bar must trade beyond a pool by the tolerance and close back inside, flipping it to “awaiting MSS”
[*]An opposite-direction close through the protected swing within the lookahead confirms the sweep as tradable
[/list]
[b]3. Projection & Scoring[/b]
[list]
[*]On confirmation, the nearest opposing pool is projected as the draw and R-targets are measured from the sweep extreme
[*]A 0-100 confidence score weights rejection-wick quality, MSS speed, and displacement
[/list]

[b]💡 Note:[/b] SLSM is a non-repainting decision-support tool, not a signal-only system. Wait for the “MSS ✓” confirmation before acting on a sweep, and use the projected draw plus R-targets for trade management rather than entry timing alone.

## Source Code

````pine
//@version=6
// ============================================================================
//  SESSION LIQUIDITY SWEEP MAP  (SLSM)
// ----------------------------------------------------------------------------
//  WORKFLOW  (sweep -> MSS):
//    1. Each session (Asia / London / New York) builds a developing high & low.
//    2. At session close those extremes are finalized into resting liquidity
//       pools: highs = buy-side liquidity (BSL, above), lows = sell-side
//       liquidity (SSL, below). Pools stay on the chart until swept or aged out.
//    3. A SWEEP is registered when a *confirmed* bar trades beyond a pool by
//       the tolerance, then closes back inside (wick-rejection). The pool flips
//       to "awaiting MSS".
//    4. An MSS / CHoCH confirms the sweep when price closes through the
//       protected swing point in the opposite direction within the lookahead.
//       -> "Confirmed" = the tradable signal.  No break in time -> "no MSS".
//    5. On confirmation the opposing pool is projected as the logical draw,
//       with optional R-multiple targets measured from the sweep extreme.
//
//  READING THE DASHBOARD:
//    Each session row shows its phase (Building / Complete / Awaiting MSS /
//    Confirmed / no-MSS) plus its high & low. The bottom two rows show the
//    nearest *untaken* liquidity sitting above and below current price — i.e.
//    where price is likely being drawn next.
//
//  Non-repainting: session pools finalize at close; sweep & MSS logic only
//  evaluates on confirmed bars; swing points use right-anchored pivots.
// ============================================================================

indicator("Session Liquidity Sweep Map", "SLSM", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
//  INPUTS
// ============================================================================

// ---- General / Theme -------------------------------------------------------
gGen      = "General"
theme     = input.string("Dark", "Theme", options = ["Dark", "Light"], group = gGen,
     tooltip = "Switches label/line text contrast for dark or light chart backgrounds.")
tz        = input.string("America/New_York", "Session Timezone", group = gGen,
     options = ["America/New_York", "America/Chicago", "Europe/London",
                "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney", "UTC"],
     tooltip = "All session windows below are interpreted in this timezone.")

// ---- Sessions --------------------------------------------------------------
gSes      = "Sessions"
showAsia  = input.bool(true,  "Asia",    inline = "A", group = gSes)
asiaSpec  = input.session("2000-0000", "", inline = "A", group = gSes)
asiaCol   = input.color(#f0a30a, "", inline = "A", group = gSes)

showLon   = input.bool(true,  "London",  inline = "L", group = gSes)
lonSpec   = input.session("0200-0500", "", inline = "L", group = gSes)
lonCol    = input.color(#2962ff, "", inline = "L", group = gSes)

showNY    = input.bool(true,  "New York",inline = "N", group = gSes)
nySpec    = input.session("0930-1100", "", inline = "N", group = gSes)
nyCol     = input.color(#26a69a, "", inline = "N", group = gSes)

showKZ    = input.bool(true, "Shade kill-zones", group = gSes,
     tooltip = "Tint the background while each enabled session is active.")
kzTransp  = input.int(90, "Kill-zone transparency", minval = 50, maxval = 99, group = gSes)

// ---- Liquidity Pools -------------------------------------------------------
gPool     = "Liquidity Pools"
keepBars  = input.int(600, "Keep pools alive (bars)", minval = 50, group = gPool,
     tooltip = "Untouched pools older than this are removed to respect object limits.")
clusterEq = input.bool(true, "Cluster equal highs/lows", group = gPool,
     tooltip = "Merge a new pool into an existing same-side pool when within tolerance.")
clusterTk = input.float(8, "Cluster tolerance (ticks)", minval = 0, group = gPool)
maxPerSide= input.int(12, "Max active pools / side", minval = 2, maxval = 40, group = gPool)
showSwept = input.bool(true, "Keep swept pools visible", group = gPool,
     tooltip = "Show taken pools as faded/dashed instead of deleting them immediately.")

// ---- Sweep Detection -------------------------------------------------------
gSwp      = "Sweep Detection"
sweepTk   = input.float(2, "Penetration tolerance (ticks)", minval = 0, group = gSwp,
     tooltip = "Price must exceed the level by at least this many ticks to count as a sweep.")
needClose = input.bool(true, "Require close back inside", group = gSwp,
     tooltip = "Demand a wick-rejection (close back through the level). The robust default.")
useDisp   = input.bool(true, "Also accept displacement break", group = gSwp,
     tooltip = "Alternative trigger: a strong-bodied bar (vs ATR) reclaiming the level.")
dispMult  = input.float(1.0, "Displacement body x ATR", minval = 0.2, step = 0.1, group = gSwp)

// ---- MSS / Structure -------------------------------------------------------
gMss      = "MSS / Structure"
pivotLen  = input.int(5, "Swing pivot length", minval = 2, group = gMss,
     tooltip = "Left/right strength for swing-high/low detection (right-anchored, non-repainting).")
mssLook   = input.int(20, "MSS lookahead (bars)", minval = 3, group = gMss,
     tooltip = "Bars after a sweep to wait for the opposite-direction structure break.")
showScore = input.bool(true, "Show confidence score", group = gMss)

// ---- Targets / Projection --------------------------------------------------
gTgt      = "Targets / Projection"
showDraw  = input.bool(true, "Project opposing draw", group = gTgt,
     tooltip = "On confirmation, project the nearest opposite-side pool as the target draw.")
showR     = input.bool(true, "Plot R-multiple targets", group = gTgt)
rCount    = input.int(3, "R targets", minval = 1, maxval = 5, group = gTgt)

// ---- Dashboard -------------------------------------------------------------
gDash     = "Dashboard"
showDash  = input.bool(true, "Show dashboard", group = gDash)
dashPos   = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSize  = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal"], group = gDash)

// ---- Alerts ----------------------------------------------------------------
gAlt      = "Alerts"
alSweep   = input.bool(true, "Alert: liquidity swept", group = gAlt)
alConf    = input.bool(true, "Alert: sweep + MSS confirmed", group = gAlt)
alDraw    = input.bool(true, "Alert: new opposing draw", group = gAlt)

// ============================================================================
//  THEME HELPERS
// ============================================================================
isDark   = theme == "Dark"
txtCol   = isDark ? color.new(color.white, 0)  : color.new(color.black, 0)
dimTxt   = isDark ? color.new(color.gray, 20)  : color.new(color.gray, 0)
panelBg  = isDark ? color.new(#1b1f2a, 5)      : color.new(#f4f6fb, 5)
headBg   = isDark ? color.new(#2a2f3d, 0)      : color.new(#dfe4ee, 0)
okCol    = color.new(#26a69a, 0)
badCol   = color.new(#ef5350, 0)
warnCol  = color.new(#f0a30a, 0)

dSize    = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal

tablePos = switch dashPos
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    => position.top_right

tick     = syminfo.mintick
atr      = ta.atr(14)

// ============================================================================
//  TYPES
// ============================================================================

// A tracked trading session and its developing range.
type Sess
    string name
    bool   show
    string spec
    color  col
    bool   inNow   = false
    bool   started = false
    float  hi      = na
    float  lo      = na
    int    hiBar   = na
    int    loBar   = na

// A resting liquidity pool created from a finalized session extreme.
type Pool
    string sess
    bool   isBuy           // true = buy-side (high, above) ; false = sell-side (low)
    float  price
    int    bornBar
    bool   swept     = false
    int    sweptBar  = na
    float  sweepExt  = na   // the wick extreme that took the pool
    float  wickRatio = 0.0  // rejection quality at sweep
    bool   awaiting  = false
    bool   confirmed = false
    bool   failed    = false
    float  mssRef    = na   // protected swing level whose break confirms the MSS
    int    score     = 0
    int    eqCount   = 1    // how many equal levels clustered here
    line   ln        = na
    label  lb        = na

// ============================================================================
//  STATE
// ============================================================================
var array<Sess> sessions = array.new<Sess>()
var array<Pool> pools    = array.new<Pool>()

// Initialize the three sessions once.
if barstate.isfirst
    array.push(sessions, Sess.new("Asia",   showAsia, asiaSpec, asiaCol))
    array.push(sessions, Sess.new("London", showLon,  lonSpec,  lonCol))
    array.push(sessions, Sess.new("NY",     showNY,   nySpec,   nyCol))

// Per-bar alert flags (reset every bar -> safe for alertcondition()).
sweptThisBar = false
confThisBar  = false
drawThisBar  = false

// ============================================================================
//  STRUCTURE (swing points)  — right-anchored pivots are non-repainting.
// ============================================================================
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)
var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(ph)
    lastSwingHigh := ph
if not na(pl)
    lastSwingLow := pl

// ============================================================================
//  POOL DRAWING HELPERS
// ============================================================================
poolColor(Pool p) =>
    base = p.sess == "Asia" ? asiaCol : p.sess == "London" ? lonCol : nyCol
    p.swept ? color.new(base, 70) : color.new(base, 10)

poolText(Pool p) =>
    side = p.isBuy ? "BSL" : "SSL"
    tag  = p.eqCount > 1 ? "= " : ""
    state = p.confirmed ? " ✓MSS" : p.failed ? " ·no-MSS" : p.awaiting ? " ⏳" : p.swept ? " ✗" : ""
    tag + str.upper(p.sess) + " " + side + state

drawPool(Pool p) =>
    p.ln := line.new(p.bornBar, p.price, bar_index, p.price,
         xloc = xloc.bar_index, extend = extend.right,
         color = poolColor(p), width = 1,
         style = p.isBuy ? line.style_solid : line.style_solid)
    p.lb := label.new(bar_index, p.price, poolText(p),
         xloc = xloc.bar_index, style = label.style_label_left,
         textcolor = txtCol, color = color.new(color.gray, 100), size = size.small)

refreshPool(Pool p) =>
    if not na(p.ln)
        line.set_color(p.ln, poolColor(p))
        if p.swept
            line.set_extend(p.ln, extend.none)
            line.set_x2(p.ln, p.sweptBar)
            line.set_style(p.ln, line.style_dashed)
    if not na(p.lb)
        label.set_text(p.lb, poolText(p))
        label.set_textcolor(p.lb, p.swept ? dimTxt : txtCol)

deletePool(Pool p) =>
    if not na(p.ln)
        line.delete(p.ln)
    if not na(p.lb)
        label.delete(p.lb)

// Count active (unswept) pools on one side for the cap.
countSide(bool buy) =>
    int c = 0
    for q in pools
        if q.isBuy == buy and not q.swept
            c += 1
    c

// Create a pool for one session extreme, with optional equal-level clustering.
addPool(string sname, bool buy, float price, int bornBar) =>
    bool merged = false
    if clusterEq
        tol = clusterTk * tick
        for q in pools
            if not q.swept and q.isBuy == buy and math.abs(q.price - price) <= tol
                q.eqCount += 1
                refreshPool(q)
                merged := true
                break
    if not merged
        // Enforce per-side cap by removing the oldest unswept pool on that side.
        if countSide(buy) >= maxPerSide
            int oldestIdx = -1
            int oldestBar = na
            for [i, q] in pools
                if q.isBuy == buy and not q.swept and (na(oldestBar) or q.bornBar < oldestBar)
                    oldestBar := q.bornBar
                    oldestIdx := i
            if oldestIdx >= 0
                deletePool(array.get(pools, oldestIdx))
                array.remove(pools, oldestIdx)
        p = Pool.new(sess = sname, isBuy = buy, price = price, bornBar = bornBar)
        drawPool(p)
        array.push(pools, p)

// ============================================================================
//  SESSION TRACKING  +  POOL FINALIZATION
// ============================================================================
for s in sessions
    nowIn = s.show and not na(time(timeframe.period, s.spec, tz))

    if nowIn and not s.inNow
        // Session open -> reset developing extremes.
        s.hi := high
        s.lo := low
        s.hiBar := bar_index
        s.loBar := bar_index
        s.started := true
    else if nowIn
        if high > s.hi
            s.hi := high
            s.hiBar := bar_index
        if low < s.lo
            s.lo := low
            s.loBar := bar_index

    // Session close -> finalize extremes into resting pools.
    if (not nowIn) and s.inNow and s.started and not na(s.hi) and not na(s.lo)
        addPool(s.name, true,  s.hi, s.hiBar)   // buy-side (high)
        addPool(s.name, false, s.lo, s.loBar)   // sell-side (low)
        s.started := false

    s.inNow := nowIn

asiaActive = array.size(sessions) > 0 ? array.get(sessions, 0).inNow : false
lonActive  = array.size(sessions) > 1 ? array.get(sessions, 1).inNow : false
nyActive   = array.size(sessions) > 2 ? array.get(sessions, 2).inNow : false

// ============================================================================
//  SWEEP  +  MSS  (confirmed-bar only -> non-repainting)
// ============================================================================
confirmed = barstate.isconfirmed
sweepTol  = sweepTk * tick

// Displacement helper: strong directional body vs ATR.
bodyUp   = (close - open) >= dispMult * atr
bodyDn   = (open - close) >= dispMult * atr
rngBar   = high - low

if confirmed
    for p in pools

        // ---- 1) SWEEP DETECTION ----
        if not p.swept
            took = false
            if p.isBuy
                wickReject = high > p.price + sweepTol and (not needClose or close < p.price)
                dispBreak  = useDisp and high > p.price + sweepTol and bodyDn and close < p.price
                if wickReject or dispBreak
                    took := true
                    p.sweepExt  := high
                    p.wickRatio := rngBar > 0 ? (high - math.max(open, close)) / rngBar : 0.0
                    p.mssRef    := na(lastSwingLow) ? low : lastSwingLow
            else
                wickReject = low < p.price - sweepTol and (not needClose or close > p.price)
                dispBreak  = useDisp and low < p.price - sweepTol and bodyUp and close > p.price
                if wickReject or dispBreak
                    took := true
                    p.sweepExt  := low
                    p.wickRatio := rngBar > 0 ? (math.min(open, close) - low) / rngBar : 0.0
                    p.mssRef    := na(lastSwingHigh) ? high : lastSwingHigh
            if took
                p.swept    := true
                p.sweptBar := bar_index
                p.awaiting := true
                refreshPool(p)
                label.new(bar_index, p.isBuy ? high : low,
                     (p.isBuy ? "Sweep ↑ " : "Sweep ↓ ") + str.upper(p.sess),
                     style = p.isBuy ? label.style_label_down : label.style_label_up,
                     color = color.new(p.isBuy ? badCol : okCol, 15),
                     textcolor = color.white, size = size.small)
                sweptThisBar := true

        // ---- 2) MSS / CHoCH CONFIRMATION ----
        else if p.awaiting
            barsSince = bar_index - p.sweptBar
            hit = p.isBuy ? (not na(p.mssRef) and close < p.mssRef) : (not na(p.mssRef) and close > p.mssRef)
            if hit
                p.awaiting  := false
                p.confirmed := true
                // Confidence score: rejection wick + MSS speed + displacement.
                spd  = math.max(0.0, 1.0 - barsSince / math.max(1, mssLook))
                disp = math.min(1.0, math.abs(close - p.mssRef) / (atr * 2))
                p.score := int(math.round(100 * (0.4 * p.wickRatio + 0.3 * spd + 0.3 * disp)))
                refreshPool(p)
                label.new(bar_index, close,
                     "MSS ✓ " + str.upper(p.sess) + (showScore ? "  " + str.tostring(p.score) : ""),
                     style = p.isBuy ? label.style_label_down : label.style_label_up,
                     color = color.new(okCol, 0), textcolor = color.white, size = size.normal)
                confThisBar := true

                // ---- 3) TARGETS / PROJECTION ----
                if showDraw
                    // Nearest opposite-side unswept pool = logical draw.
                    float drawPx = na
                    for q in pools
                        if not q.swept and q.isBuy != p.isBuy
                            cand = q.price
                            ok = p.isBuy ? (cand < close) : (cand > close)
                            better = na(drawPx) or (p.isBuy ? cand > drawPx : cand < drawPx)
                            if ok and better
                                drawPx := cand
                    if not na(drawPx)
                        line.new(bar_index, drawPx, bar_index + mssLook, drawPx,
                             xloc = xloc.bar_index, color = color.new(warnCol, 20),
                             style = line.style_dotted, width = 2)
                        label.new(bar_index + mssLook, drawPx, "Draw",
                             style = label.style_label_left, color = color.new(warnCol, 20),
                             textcolor = color.white, size = size.small)
                        drawThisBar := true

                if showR
                    // R measured from the sweep extreme (structure-based stop).
                    stop = p.sweepExt
                    entry = close
                    risk = math.abs(stop - entry)
                    if risk > 0
                        for r = 1 to rCount
                            tp = p.isBuy ? entry - r * risk : entry + r * risk
                            line.new(bar_index, tp, bar_index + mssLook, tp,
                                 xloc = xloc.bar_index, color = color.new(okCol, 40),
                                 style = line.style_dashed, width = 1)
                            label.new(bar_index + mssLook, tp, str.tostring(r) + "R",
                                 style = label.style_label_left, color = color.new(color.gray, 100),
                                 textcolor = okCol, size = size.tiny)
            else if barsSince > mssLook
                // No structure break in time -> sweep without confirmation.
                p.awaiting := false
                p.failed   := true
                refreshPool(p)

// ============================================================================
//  CLEANUP  (respect drawing-object limits)
// ============================================================================
if barstate.isconfirmed
    int k = array.size(pools) - 1
    while k >= 0
        Pool p = array.get(pools, k)
        expired = (not p.swept) and (bar_index - p.bornBar > keepBars)
        resolvedOld = (p.confirmed or p.failed) and (bar_index - p.sweptBar > keepBars)
        drop = expired or resolvedOld or (p.swept and not showSwept and not p.awaiting)
        if drop
            deletePool(p)
            array.remove(pools, k)
        k -= 1

// ============================================================================
//  KILL-ZONE SHADING
// ============================================================================
bgcolor(showKZ and asiaActive ? color.new(asiaCol, kzTransp) : na, title = "Asia KZ")
bgcolor(showKZ and lonActive  ? color.new(lonCol,  kzTransp) : na, title = "London KZ")
bgcolor(showKZ and nyActive   ? color.new(nyCol,   kzTransp) : na, title = "NY KZ")

// ============================================================================
//  DASHBOARD
// ============================================================================
var table dash = na
if barstate.isfirst and showDash
    dash := table.new(tablePos, 4, 6, border_width = 1, frame_color = headBg, frame_width = 1)

// Derive a per-session phase string from its pools.
sessPhase(string sname) =>
    string phase = "—"
    color  col   = dimTxt
    bool anyConf  = false
    bool anyAwait = false
    bool anyFail  = false
    bool anySwept = false
    bool anyLive  = false
    for p in pools
        if p.sess == sname
            anyLive := true
            anyConf  := anyConf  or p.confirmed
            anyAwait := anyAwait or p.awaiting
            anyFail  := anyFail  or p.failed
            anySwept := anySwept or p.swept
    if anyConf
        phase := "Confirmed ✓"
        col := okCol
    else if anyAwait
        phase := "Awaiting MSS"
        col := warnCol
    else if anyFail
        phase := "Swept · no-MSS"
        col := badCol
    else if anySwept
        phase := "Swept"
        col := dimTxt
    else if anyLive
        phase := "Complete"
        col := txtCol
    [phase, col]

if barstate.islast and showDash and not na(dash)
    table.clear(dash, 0, 0, 3, 5)
    table.cell(dash, 0, 0, "SESSION", text_color = txtCol, bgcolor = headBg, text_size = dSize)
    table.cell(dash, 1, 0, "PHASE",   text_color = txtCol, bgcolor = headBg, text_size = dSize)
    table.cell(dash, 2, 0, "HIGH",    text_color = txtCol, bgcolor = headBg, text_size = dSize)
    table.cell(dash, 3, 0, "LOW",     text_color = txtCol, bgcolor = headBg, text_size = dSize)

    for [i, s] in sessions
        [ph2, pc] = sessPhase(s.name)
        liveTag = s.inNow ? " ●" : ""
        table.cell(dash, 0, i + 1, s.name + liveTag, text_color = s.col, bgcolor = panelBg, text_size = dSize)
        table.cell(dash, 1, i + 1, ph2, text_color = pc, bgcolor = panelBg, text_size = dSize)
        table.cell(dash, 2, i + 1, na(s.hi) ? "—" : str.tostring(s.hi, format.mintick), text_color = txtCol, bgcolor = panelBg, text_size = dSize)
        table.cell(dash, 3, i + 1, na(s.lo) ? "—" : str.tostring(s.lo, format.mintick), text_color = txtCol, bgcolor = panelBg, text_size = dSize)

    // Nearest untaken liquidity above & below price.
    float nearUp = na
    float nearDn = na
    string upSess = ""
    string dnSess = ""
    for p in pools
        if not p.swept
            if p.price > close and (na(nearUp) or p.price < nearUp)
                nearUp := p.price
                upSess := p.sess
            if p.price < close and (na(nearDn) or p.price > nearDn)
                nearDn := p.price
                dnSess := p.sess
    table.cell(dash, 0, 4, "BSL ↑", text_color = okCol, bgcolor = headBg, text_size = dSize)
    table.cell(dash, 1, 4, na(nearUp) ? "—" : upSess, text_color = txtCol, bgcolor = panelBg, text_size = dSize)
    table.cell(dash, 2, 4, na(nearUp) ? "—" : str.tostring(nearUp, format.mintick), text_color = txtCol, bgcolor = panelBg, text_size = dSize)
    table.cell(dash, 3, 4, "", bgcolor = panelBg)
    table.cell(dash, 0, 5, "SSL ↓", text_color = badCol, bgcolor = headBg, text_size = dSize)
    table.cell(dash, 1, 5, na(nearDn) ? "—" : dnSess, text_color = txtCol, bgcolor = panelBg, text_size = dSize)
    table.cell(dash, 2, 5, na(nearDn) ? "—" : str.tostring(nearDn, format.mintick), text_color = txtCol, bgcolor = panelBg, text_size = dSize)
    table.cell(dash, 3, 5, "", bgcolor = panelBg)

// ============================================================================
//  ALERTS
// ============================================================================
if alSweep and sweptThisBar
    alert("SLSM: Session liquidity swept on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alConf and confThisBar
    alert("SLSM: Sweep + MSS CONFIRMED on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alDraw and drawThisBar
    alert("SLSM: New opposing-liquidity draw projected on " + syminfo.ticker, alert.freq_once_per_bar_close)

// Static alertcondition() hooks for users who prefer the alert dialog.
alertcondition(sweptThisBar, "Liquidity Swept", "Session liquidity swept")
alertcondition(confThisBar,  "Sweep + MSS Confirmed", "Sweep confirmed by market structure shift")
alertcondition(drawThisBar,  "New Opposing Draw", "New opposing-liquidity draw projected")
````
