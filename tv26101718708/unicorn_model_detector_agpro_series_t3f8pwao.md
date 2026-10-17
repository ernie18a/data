# Unicorn Model Detector [AGPro Series]

- url: https://www.tradingview.com/script/T3f8pwaO-Unicorn-Model-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;a220ddbba48c4729b80102190106dbc3
- version: 4.0

## Description

Unicorn Model Detector [AGPro Series]

Overview
The Unicorn Model Detector identifies one of the most discussed setups in Inner Circle Trader (ICT) and Smart Money Concepts literature: the Unicorn Model. A Unicorn forms when a Breaker Block and a Fair Value Gap (FVG) overlap inside the same price zone — a pocket where prior swing liquidity has been swept and an unfilled imbalance still exists at the retest. The detector scans for these overlaps, tracks every occurrence through its full lifecycle, and reports aggregate statistics in a compact on-chart panel. It is a detection and bookkeeping tool, not a trading strategy.

Unique Edge
Most breaker and FVG scripts publish either zones in isolation or require the user to eyeball the overlap. This detector does the overlap match automatically and only draws a zone when both conditions are present on the same chart area with the same directional bias. A strict causality rule is enforced — the Breaker must form first (after liquidity sweep) and the FVG must appear during or after the retest, which matches the true ICT Unicorn definition. A pairing that consumes a given breaker and FVG is removed from future candidate pools, so the chart never stacks redundant zones from the same source structure. A Loose overlap mode is also provided for users who prefer an ATR-based proximity interpretation instead of strict geometric intersection.

Methodology
1. Swing pivots are detected with a configurable left/right length using ta.pivothigh and ta.pivotlow.
2. When a confirmed pivot forms, the body range of the pivot bar is stored as the potential Breaker source zone.
3. A Breaker Block is registered when price closes through the previous-bar swing level in the opposite direction.
4. A Fair Value Gap is registered when a 3-bar formation produces an unfilled imbalance (low > high[2] for bullish, high < low[2] for bearish) and the gap exceeds a user-defined ATR multiple.
5. A Unicorn is spawned when a same-direction Breaker zone and FVG zone overlap vertically AND the FVG formed at or after the Breaker (causality check).
6. A configurable cooldown prevents consecutive spawns from clustering, improving signal hygiene.
7. The overlap rectangle becomes the tracked zone. Zone mid is the reference entry, the stop is placed 0.4 times the zone height beyond the structure boundary, and the target is projected at the user-defined R-multiple.

Signals & Alerts
Four independent alert conditions are exposed:
- New Unicorn Detected — a fresh bullish or bearish Unicorn has just formed.
- Unicorn Triggered — price has entered the overlap zone of a pending Unicorn.
- Target Hit — a triggered Unicorn has reached its R-multiple target.
- Stop Hit — a triggered Unicorn has been invalidated at its stop level.

All alerts fire once per bar close and include the ticker and timeframe in the payload.

Key Inputs
- Swing Pivot Length (default 7) — left/right length used for pivot confirmation.
- Breaker Lookback (default 80 bars) — maximum age for a broken swing to remain a valid Breaker.
- FVG Minimum Size (default 0.25 x ATR) — noise filter for 3-bar imbalances.
- Overlap Mode (Strict / Loose) — geometric intersection vs ATR-tolerance match.
- Reward-to-Risk Target (default 2.0) — multiple used to project the target level.
- Max Active Pending Unicorns (default 3) — chart-cleanliness cap.
- Cooldown After Signal (default 30 bars) — minimum spacing between consecutive spawns.
- Invalidate on Close Through Zone (default off) — optional tighter invalidation rule.
- Visual controls — show/hide per lifecycle state, label size, zone opacity, max recent labels.
- Panel controls — show/hide, location (6 positions), theme (Dark/Light), text size.

How to Use
1. Add the indicator to any timeframe; higher timeframes (1H, 4H, 1D) tend to produce structurally more meaningful Unicorns.
2. Watch for a new Unicorn zone to appear. Pending zones are drawn in the directional state color with a bold border; triggered ones switch to the indigo accent color; TP / SL / Expired zones fade to their respective colors with a thinner border.
3. Each zone carries a tethered flag label outside the price axis — Bullish labels below, Bearish labels above — so they never overlap candles.
4. The panel reports running counts of pending and active Unicorns, historical win rate, average R per setup, and total completed.
5. Use the displayed entry / target / stop reference lines as a structural map for your own analysis. The tool does not place orders and does not recommend position sizing.
6. Combine with higher-timeframe bias (trend, session context, HTF structure) before acting on any zone.

Limitations & Transparency
- The detector is a structural scanner, not a forecasting engine. It reports what has formed, not what will happen.
- Swing detection depends on pivot length; shorter lengths generate more noise, longer lengths miss smaller structures.
- Statistics are calculated on-chart from historical bars loaded by TradingView and will vary with timeframe, symbol and data range.
- Realtime behaviour: zones are drawn on confirmed events (bar close for breaks, 3-bar-complete for FVGs). Some invalidations are evaluated intrabar on wick touches of the stop level.
- The script is open-source under Mozilla Public License 2.0. Users are encouraged to inspect and adapt the methodology.

Risk Disclosure
This indicator is provided for educational and analytical purposes only. It is not financial advice, a trading signal service, or a strategy. Past structural patterns do not guarantee future outcomes. Trading involves substantial risk of loss; readers are solely responsible for their own decisions and risk management.

## Source Code

````pine
// -----------------------------------------------------
// Unicorn Model Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// ICT Unicorn Model decision engine that detects where a Breaker Block and a
// Fair Value Gap overlap inside the same price pocket, then scores every
// confluence as a 0-100 readiness setup with a clear next-action state, an
// entry / stop / target projection, explicit Breaker + FVG confluence evidence
// and a persistent win-rate proof layer. Completed pockets use a bounded,
// faded archive so the current Unicorn decision remains visually dominant.
// -----------------------------------------------------

//@version=6
indicator("Unicorn Model Detector [AGPro Series]",
     shorttitle = "AG Pro Unicorn",
     overlay    = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpStruct = "Structure Detection"
pivotLen = input.int(7, "Swing Pivot Length", minval = 2, maxval = 20, group = grpStruct,
     tooltip = "Number of bars to the left and right used to confirm a swing pivot. Higher values filter minor noise; lower values react faster.")
bbLookback = input.int(80, "Breaker Lookback (bars)", minval = 10, maxval = 300, group = grpStruct,
     tooltip = "Maximum age in bars for a broken swing to still qualify as a valid Breaker Block.")
fvgMinAtr = input.float(0.25, "FVG Minimum Size (ATR)", minval = 0.0, step = 0.05, group = grpStruct,
     tooltip = "Minimum vertical height of a 3-bar Fair Value Gap, expressed as a multiple of ATR(14).")

grpUnicorn = "Unicorn Logic"
overlapMode = input.string("Strict", "Overlap Mode", options = ["Strict", "Loose"], group = grpUnicorn,
     tooltip = "Strict requires a non-zero overlap between Breaker Block and FVG. Loose allows a small ATR-based adjacency tolerance.")
looseTolAtr = input.float(0.10, "Loose Tolerance (ATR)", minval = 0.0, step = 0.05, group = grpUnicorn,
     tooltip = "Only used when Overlap Mode is Loose. Defines the maximum ATR-based distance still treated as confluence.")
rrTarget = input.float(2.0, "Reward-to-Risk Target", minval = 0.5, step = 0.1, group = grpUnicorn,
     tooltip = "Reward-to-risk ratio used to project each unicorn target level.")
maxPending = input.int(3, "Max Active Pending Unicorns", minval = 1, maxval = 10, group = grpUnicorn,
     tooltip = "Maximum simultaneous pending unicorn zones displayed on the chart.")
cooldownBars = input.int(30, "Cooldown After Signal (bars)", minval = 0, maxval = 200, group = grpUnicorn,
     tooltip = "Minimum number of bars between consecutive unicorn spawns.")
invalidateOnClose = input.bool(false, "Invalidate on Close Through Zone", group = grpUnicorn,
     tooltip = "When enabled, a pending unicorn is invalidated as soon as price closes through the stop side of the zone.")

grpProof = "Confirmation / Proof"
proofWindow = input.int(200, "Confirm Window (bars)", minval = 10, maxval = 1000, group = grpProof,
     tooltip = "A triggered pocket must resolve into its target or stop within this many bars to count toward the Win Rate proof layer. Pockets that take longer are marked expired and excluded, which prevents inflated statistics from the assumption that price eventually reaches everything.")

grpVisual = "Visual Appearance"
showPending = input.bool(true, "Show Pending Unicorns", group = grpVisual)
showTriggered = input.bool(true, "Show Triggered Unicorns", group = grpVisual)
showCompleted = input.bool(true, "Show Completed Unicorns", group = grpVisual)
showTargets = input.bool(true, "Show Entry / TP / SL Lines", group = grpVisual,
     tooltip = "Draws the entry, target and stop projection lines for the primary active setup only, keeping the chart focused on the most relevant pocket.")
showPlanTags = input.bool(true, "Show Plan Price Tags", group = grpVisual,
     tooltip = "Shows target and stop price tags on the primary active setup for quick trade planning.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = grpVisual,
     tooltip = "Places a centered ownership badge inside each visible Unicorn pocket. This uses separate label objects on solid color fills and does not rely on embedded box text.")
showBadgeState = input.bool(true, "Show Badge State", group = grpVisual,
     tooltip = "Adds the pocket state and live readiness score to the centered zone badge.")
maxCompletedShown = input.int(2, "Recent Completed Pockets", minval = 1, maxval = 40, group = grpVisual,
     tooltip = "Maximum number of completed Unicorn pockets retained on the chart. Live pending and triggered pockets remain visible, while older completed geometry is removed to keep the active decision map clear.")
labelSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVisual,
     tooltip = "Size of on-chart Unicorn badges and plan tags.")
zoneOpacity = input.int(58, "Zone Fill Opacity", minval = 0, maxval = 95, group = grpVisual,
     tooltip = "Transparency of the active overlap zone fill. Completed pockets are automatically faded further to recede into the background.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel)
panelLoc = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = grpPanel)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel)
panelTextSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel,
     tooltip = "Size of the text inside the panel.")

grpAlerts = "Alerts"
alertNewUnicorn = input.bool(true, "Alert on New Unicorn Detected", group = grpAlerts)
alertTriggered = input.bool(true, "Alert on Unicorn Triggered", group = grpAlerts)
alertTargetHit = input.bool(true, "Alert on Target Hit", group = grpAlerts)
alertStopHit = input.bool(true, "Alert on Stop Hit", group = grpAlerts)

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
// Muted / archived tones for completed pockets
mutedTp = color.rgb(40, 96, 84)
mutedSl = color.rgb(120, 64, 92)
mutedGrey = color.rgb(84, 94, 108)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_toSize(s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Large" ? size.large :
     s == "Huge" ? size.huge : size.normal

f_panelPos(loc) =>
    loc == "Top Left" ? position.top_left :
     loc == "Top Center" ? position.top_center :
     loc == "Middle Left" ? position.middle_left :
     loc == "Middle Center" ? position.middle_center :
     loc == "Middle Right" ? position.middle_right :
     loc == "Bottom Left" ? position.bottom_left :
     loc == "Bottom Center" ? position.bottom_center :
     loc == "Bottom Right" ? position.bottom_right : position.top_right

f_panelBg() =>
    panelTheme == "Clean Light" ? color.rgb(248, 250, 252) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panelBorder() =>
    panelTheme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panelLabel() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panelValue() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_stateText(st) =>
    st == "pending" ? "Pending" :
     st == "triggered" ? "Active" :
     st == "tp" ? "TP" :
     st == "sl" ? "SL" :
     st == "invalid" ? "Invalid" :
     st == "expired" ? "Expired" : st

atr = ta.atr(14)

// -----------------------------------------------------
// Structure: swing pivots and breaker blocks
// -----------------------------------------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingHighBodyTop = na
var float lastSwingHighBodyBot = na
var float lastSwingLow = na
var float lastSwingLowBodyTop = na
var float lastSwingLowBodyBot = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighBodyTop := math.max(open[pivotLen], close[pivotLen])
    lastSwingHighBodyBot := math.min(open[pivotLen], close[pivotLen])
if not na(pl)
    lastSwingLow := pl
    lastSwingLowBodyTop := math.max(open[pivotLen], close[pivotLen])
    lastSwingLowBodyBot := math.min(open[pivotLen], close[pivotLen])

type Breaker
    string dir
    float top
    float bot
    int bornBar
    int bornTime
    int ageBarLimit
    bool active

var array<Breaker> breakers = array.new<Breaker>()

prevSwingLow = lastSwingLow[1]
prevSwingHigh = lastSwingHigh[1]
brokeLow = not na(prevSwingLow) and close < prevSwingLow and close[1] >= prevSwingLow
brokeHigh = not na(prevSwingHigh) and close > prevSwingHigh and close[1] <= prevSwingHigh

prevSwingLowBodyTop = lastSwingLowBodyTop[1]
prevSwingLowBodyBot = lastSwingLowBodyBot[1]
prevSwingHighBodyTop = lastSwingHighBodyTop[1]
prevSwingHighBodyBot = lastSwingHighBodyBot[1]

// Breaker creation is gated on confirmed bars to keep detection non-repainting.
if barstate.isconfirmed
    if brokeLow and not na(prevSwingLowBodyTop) and not na(prevSwingLowBodyBot)
        b = Breaker.new("bull_pending", prevSwingLowBodyTop, prevSwingLowBodyBot, bar_index, time, bar_index + bbLookback, true)
        array.push(breakers, b)
    if brokeHigh and not na(prevSwingHighBodyTop) and not na(prevSwingHighBodyBot)
        b = Breaker.new("bear_pending", prevSwingHighBodyTop, prevSwingHighBodyBot, bar_index, time, bar_index + bbLookback, true)
        array.push(breakers, b)

if array.size(breakers) > 0
    for bi = 0 to array.size(breakers) - 1
        br = array.get(breakers, bi)
        if br.active and bar_index > br.ageBarLimit
            br.active := false
            array.set(breakers, bi, br)

// Bound inactive structure history so long chart sessions do not grow the
// internal search arrays indefinitely.
while array.size(breakers) > 240
    array.shift(breakers)

// -----------------------------------------------------
// Fair Value Gaps
// -----------------------------------------------------
type Fvg
    string dir
    float top
    float bot
    int bornBar
    int bornTime
    bool filled

var array<Fvg> fvgs = array.new<Fvg>()

bullFvgRaw = low > high[2]
bearFvgRaw = high < low[2]

if barstate.isconfirmed
    if bullFvgRaw and (low - high[2] >= fvgMinAtr * atr)
        f = Fvg.new("bull", low, high[2], bar_index - 1, time[1], false)
        array.push(fvgs, f)
    if bearFvgRaw and (low[2] - high >= fvgMinAtr * atr)
        f = Fvg.new("bear", low[2], high, bar_index - 1, time[1], false)
        array.push(fvgs, f)

if array.size(fvgs) > 0
    for fi = 0 to array.size(fvgs) - 1
        fv = array.get(fvgs, fi)
        if not fv.filled
            if fv.dir == "bull" and low <= fv.bot
                fv.filled := true
            if fv.dir == "bear" and high >= fv.top
                fv.filled := true
            array.set(fvgs, fi, fv)

while array.size(fvgs) > 240
    array.shift(fvgs)

// -----------------------------------------------------
// Unicorn model
// -----------------------------------------------------
type Unicorn
    string dir
    float zoneTop
    float zoneBot
    float entry
    float stop
    float target
    float qOverlap
    float qFvg
    int bornBar
    int bornTime
    int expireBar
    int triggerBar
    int endBar
    int endTime
    string state
    box zoneBox
    line entryLine
    line tpLine
    line slLine
    label badge
    label tpTag
    label slTag

var array<Unicorn> unicorns = array.new<Unicorn>()

f_deleteVisuals(Unicorn u) =>
    if not na(u.zoneBox)
        box.delete(u.zoneBox)
    if not na(u.entryLine)
        line.delete(u.entryLine)
    if not na(u.tpLine)
        line.delete(u.tpLine)
    if not na(u.slLine)
        line.delete(u.slLine)
    if not na(u.badge)
        label.delete(u.badge)
    if not na(u.tpTag)
        label.delete(u.tpTag)
    if not na(u.slTag)
        label.delete(u.slTag)

// Persistent proof-layer counters (proof* prefix to avoid collisions).
var int proofTotal = 0
var int proofTp = 0
var int proofSl = 0
var float proofRSum = 0.0
var int lastSpawnBar = -10000

// Static confluence quality of a pairing (0-30 overlap depth, 0-20 FVG strength).
f_quality(Breaker br, Fvg fv) =>
    unionTop = math.max(br.top, fv.top)
    unionBot = math.min(br.bot, fv.bot)
    unionSpan = unionTop - unionBot
    rawOv = math.max(0.0, math.min(br.top, fv.top) - math.max(br.bot, fv.bot))
    ovRatio = unionSpan > 0 ? rawOv / unionSpan : 0.0
    qOv = math.min(30.0, ovRatio * 30.0)
    fvgH = fv.top - fv.bot
    fvgAtr = atr > 0 ? fvgH / atr : 0.0
    qFv = math.min(20.0, (fvgAtr / 1.5) * 20.0)
    [qOv, qFv]

// Live 0-100 readiness: static quality + freshness + price proximity + state.
f_readiness(Unicorn u) =>
    freshFrac = math.max(0.0, math.min(1.0, 1.0 - (bar_index - u.bornBar) / math.max(1, bbLookback)))
    qFresh = freshFrac * 10.0
    inside = close <= u.zoneTop and close >= u.zoneBot
    dist = inside ? 0.0 : (close > u.zoneTop ? close - u.zoneTop : u.zoneBot - close)
    proxFrac = math.max(0.0, math.min(1.0, 1.0 - dist / (atr * 3.0)))
    qProx = inside ? 30.0 : proxFrac * 30.0
    qState = u.state == "triggered" ? 10.0 : 0.0
    int(math.round(math.max(0.0, math.min(100.0, u.qOverlap + u.qFvg + qFresh + qProx + qState))))

f_overlap(a_top, a_bot, b_top, b_bot) =>
    top = math.min(a_top, b_top)
    bot = math.max(a_bot, b_bot)
    overlapped = top >= bot
    tol = looseTolAtr * atr
    looseOk = overlapMode == "Loose" and not overlapped and math.min(math.abs(a_top - b_bot), math.abs(b_top - a_bot)) <= tol
    if looseOk
        [math.max(a_top, b_top), math.min(a_bot, b_bot), true]
    else
        [top, bot, overlapped]

f_tryPair(string dir) =>
    pairedTop = 0.0
    pairedBot = 0.0
    pairedOk = false
    brMatch = -1
    fvMatch = -1
    bestBorn = -1
    if array.size(breakers) > 0 and array.size(fvgs) > 0
        for bi = 0 to array.size(breakers) - 1
            br = array.get(breakers, bi)
            if br.active and br.dir == dir + "_pending"
                for fi = 0 to array.size(fvgs) - 1
                    fv = array.get(fvgs, fi)
                    if not fv.filled and fv.dir == dir and fv.bornBar >= br.bornBar - 2
                        [oTop, oBot, ok] = f_overlap(br.top, br.bot, fv.top, fv.bot)
                        if ok
                            combinedBorn = math.max(br.bornBar, fv.bornBar)
                            if combinedBorn > bestBorn
                                pairedTop := oTop
                                pairedBot := oBot
                                pairedOk := true
                                brMatch := bi
                                fvMatch := fi
                                bestBorn := combinedBorn
    [pairedOk, pairedTop, pairedBot, brMatch, fvMatch]

f_pendingCount() =>
    pendingCount = 0
    if array.size(unicorns) > 0
        for ui = 0 to array.size(unicorns) - 1
            u = array.get(unicorns, ui)
            if u.state == "pending"
                pendingCount += 1
    pendingCount

freshEvent = brokeLow or brokeHigh or bullFvgRaw or bearFvgRaw

if barstate.isconfirmed and freshEvent
    cooldownOk = bar_index - lastSpawnBar >= cooldownBars

    [okB, tB, bB, brB, fvB] = f_tryPair("bull")
    if okB and cooldownOk and f_pendingCount() < maxPending
        brQ = array.get(breakers, brB)
        fvQ = array.get(fvgs, fvB)
        [qOv, qFv] = f_quality(brQ, fvQ)
        minH = atr * 0.50
        zTop = tB
        zBot = bB
        if zTop - zBot < minH
            mid = (zTop + zBot) / 2.0
            zTop := mid + minH / 2.0
            zBot := mid - minH / 2.0
        entry = (zTop + zBot) / 2.0
        stop = zBot - (zTop - zBot) * 0.40
        risk = entry - stop
        target = entry + risk * rrTarget
        newU = Unicorn.new("bull", zTop, zBot, entry, stop, target, qOv, qFv, bar_index, time, bar_index + bbLookback, na, na, na, "pending", na, na, na, na, na, na)
        array.push(unicorns, newU)
        lastSpawnBar := bar_index
        br = array.get(breakers, brB)
        br.active := false
        array.set(breakers, brB, br)
        fv = array.get(fvgs, fvB)
        fv.filled := true
        array.set(fvgs, fvB, fv)
        if alertNewUnicorn
            alert("Unicorn Model: new BULLISH unicorn detected on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

    [okS, tS, bS, brS, fvS] = f_tryPair("bear")
    if okS and bar_index - lastSpawnBar >= cooldownBars and f_pendingCount() < maxPending
        brQ = array.get(breakers, brS)
        fvQ = array.get(fvgs, fvS)
        [qOv, qFv] = f_quality(brQ, fvQ)
        minH = atr * 0.50
        zTop = tS
        zBot = bS
        if zTop - zBot < minH
            mid = (zTop + zBot) / 2.0
            zTop := mid + minH / 2.0
            zBot := mid - minH / 2.0
        entry = (zTop + zBot) / 2.0
        stop = zTop + (zTop - zBot) * 0.40
        risk = stop - entry
        target = entry - risk * rrTarget
        newU = Unicorn.new("bear", zTop, zBot, entry, stop, target, qOv, qFv, bar_index, time, bar_index + bbLookback, na, na, na, "pending", na, na, na, na, na, na)
        array.push(unicorns, newU)
        lastSpawnBar := bar_index
        br = array.get(breakers, brS)
        br.active := false
        array.set(breakers, brS, br)
        fv = array.get(fvgs, fvS)
        fv.filled := true
        array.set(fvgs, fvS, fv)
        if alertNewUnicorn
            alert("Unicorn Model: new BEARISH unicorn detected on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)

// -----------------------------------------------------
// Lifecycle management (confirmed-bar gated for proof integrity)
// -----------------------------------------------------
if barstate.isconfirmed and array.size(unicorns) > 0
    for i = 0 to array.size(unicorns) - 1
        u = array.get(unicorns, i)
        if u.state == "pending"
            hitZone = high >= u.zoneBot and low <= u.zoneTop
            if hitZone
                u.state := "triggered"
                u.triggerBar := bar_index
                if alertTriggered
                    alert("Unicorn Model: " + (u.dir == "bull" ? "BULLISH" : "BEARISH") + " unicorn TRIGGERED on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
            else if bar_index >= u.expireBar
                u.state := "expired"
                u.endBar := bar_index
                u.endTime := time
            else if invalidateOnClose
                if (u.dir == "bull" and close < u.stop) or (u.dir == "bear" and close > u.stop)
                    u.state := "invalid"
                    u.endBar := bar_index
                    u.endTime := time
        else if u.state == "triggered"
            if bar_index - u.triggerBar > proofWindow
                u.state := "expired"
                u.endBar := bar_index
                u.endTime := time
            else
                hitTarget = u.dir == "bull" ? high >= u.target : low <= u.target
                hitStop = u.dir == "bull" ? low <= u.stop : high >= u.stop
                if hitTarget and hitStop
                    // Same-bar ambiguity resolves conservatively as a loss.
                    u.state := "sl"
                    u.endBar := bar_index
                    u.endTime := time
                    proofTotal += 1
                    proofSl += 1
                    proofRSum += -1.0
                    if alertStopHit
                        alert("Unicorn Model: stop HIT on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
                else if hitTarget
                    u.state := "tp"
                    u.endBar := bar_index
                    u.endTime := time
                    proofTotal += 1
                    proofTp += 1
                    proofRSum += rrTarget
                    if alertTargetHit
                        alert("Unicorn Model: target HIT on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
                else if hitStop
                    u.state := "sl"
                    u.endBar := bar_index
                    u.endTime := time
                    proofTotal += 1
                    proofSl += 1
                    proofRSum += -1.0
                    if alertStopHit
                        alert("Unicorn Model: stop HIT on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
        array.set(unicorns, i, u)

// Proof totals remain persistent, while fully archived pocket records are
// bounded for predictable rendering and lifecycle cost.
while array.size(unicorns) > 120
    archived = array.shift(unicorns)
    f_deleteVisuals(archived)

// -----------------------------------------------------
// Primary setup selection (drives chart focus + panel)
// -----------------------------------------------------
var int gPrimaryIdx = -1
var int gPrimaryReady = 0
var string gAction = "Stand Aside"
var string gSetup = "No Active Pocket"

if barstate.islast
    gPrimaryIdx := -1
    gPrimaryReady := -1
    bool foundTrig = false
    if array.size(unicorns) > 0
        for i = 0 to array.size(unicorns) - 1
            u = array.get(unicorns, i)
            if u.state == "triggered"
                r = f_readiness(u)
                if (not foundTrig) or r > gPrimaryReady
                    foundTrig := true
                    gPrimaryReady := r
                    gPrimaryIdx := i
            else if u.state == "pending" and not foundTrig
                r = f_readiness(u)
                if r > gPrimaryReady
                    gPrimaryReady := r
                    gPrimaryIdx := i
    if gPrimaryIdx < 0
        gPrimaryReady := 0
        gAction := "Stand Aside"
        gSetup := "No Active Pocket"
    else
        pu = array.get(unicorns, gPrimaryIdx)
        dirWord = pu.dir == "bull" ? "Bull Pocket" : "Bear Pocket"
        stWord = pu.state == "triggered" ? "Active" : "Pending"
        gSetup := dirWord + " - " + stWord
        gAction := pu.state == "triggered" ? "Manage Active" :
             gPrimaryReady >= 70 ? "Arm Entry" :
             gPrimaryReady >= 45 ? "Track Retest" : "Wait For Trigger"

// -----------------------------------------------------
// Rendering
// -----------------------------------------------------
if barstate.islast and array.size(unicorns) > 0
    n = array.size(unicorns)
    int completedTotal = 0
    for i = 0 to n - 1
        countU = array.get(unicorns, i)
        if countU.state == "tp" or countU.state == "sl" or countU.state == "invalid" or countU.state == "expired"
            completedTotal += 1

    int completedOrdinal = 0

    for i = 0 to n - 1
        u = array.get(unicorns, i)
        isLive = u.state == "pending" or u.state == "triggered"
        isCompleted = u.state == "tp" or u.state == "sl" or u.state == "invalid" or u.state == "expired"
        if isCompleted
            completedOrdinal += 1
        recentCompleted = isCompleted and completedOrdinal > math.max(0, completedTotal - maxCompletedShown)
        drawIt = (u.state == "pending" and showPending) or (u.state == "triggered" and showTriggered) or (recentCompleted and showCompleted)

        if not na(u.zoneBox)
            box.delete(u.zoneBox)
        if not na(u.entryLine)
            line.delete(u.entryLine)
        if not na(u.tpLine)
            line.delete(u.tpLine)
        if not na(u.slLine)
            line.delete(u.slLine)
        if not na(u.badge)
            label.delete(u.badge)
        if not na(u.tpTag)
            label.delete(u.tpTag)
        if not na(u.slTag)
            label.delete(u.slTag)

        // Clear deleted handles before conditionally rebuilding the visible
        // pocket so hidden archive records cannot retain stale object IDs.
        u.zoneBox := na
        u.entryLine := na
        u.tpLine := na
        u.slLine := na
        u.badge := na
        u.tpTag := na
        u.slTag := na

        if drawIt
            drawCol = u.state == "pending" ? (u.dir == "bull" ? bullColor : bearColor) :
                 u.state == "triggered" ? accentColor :
                 u.state == "tp" ? mutedTp :
                 u.state == "sl" ? mutedSl : mutedGrey
            fillOp = isLive ? zoneOpacity : math.min(94, zoneOpacity + 30)
            fillCol = color.new(drawCol, fillOp)
            bpms = timeframe.in_seconds() * 1000
            minRight = u.bornTime + bpms * 12
            rawRight = isLive ? time + bpms * 10 : (na(u.endTime) ? time : u.endTime)
            rightTime = math.max(rawRight, minRight)
            bw = isLive ? 2 : 1
            isPrimaryLive = isLive and (i == gPrimaryIdx)

            u.zoneBox := box.new(u.bornTime, u.zoneTop, rightTime, u.zoneBot, xloc = xloc.bar_time, border_color = drawCol, border_width = bw, bgcolor = fillCol)

            // Full plan (lines + tags) only on the single primary active pocket.
            if isPrimaryLive
                lineRight = time + bpms * 10
                if showTargets
                    u.entryLine := line.new(u.bornTime, u.entry, lineRight, u.entry, xloc = xloc.bar_time, color = accentColor, style = line.style_dashed, width = 1)
                    u.tpLine := line.new(u.bornTime, u.target, lineRight, u.target, xloc = xloc.bar_time, color = bullColor, style = line.style_dotted, width = 1)
                    u.slLine := line.new(u.bornTime, u.stop, lineRight, u.stop, xloc = xloc.bar_time, color = bearColor, style = line.style_dotted, width = 1)
                if showPlanTags
                    u.tpTag := label.new(lineRight, u.target, "TP  " + str.tostring(u.target, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = bullColor, textcolor = headerText, size = f_toSize(labelSize))
                    u.slTag := label.new(lineRight, u.stop, "SL  " + str.tostring(u.stop, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_left, color = bearColor, textcolor = headerText, size = f_toSize(labelSize))

            // Centered ownership badge: always for live pockets, bounded for the archive.
            badgeOk = showZoneBadges and (isLive or recentCompleted)
            if badgeOk
                rdy = f_readiness(u)
                side = u.dir == "bull" ? "BULL POCKET" : "BEAR POCKET"
                liveState = u.state == "triggered" ? "ACTIVE" : "PENDING"
                sub = isLive ? (liveState + " | Q" + str.tostring(rdy)) : f_stateText(u.state)
                badgeTxt = showBadgeState ? side + "\n" + sub : side
                badgeTime = u.bornTime + int(math.round((rightTime - u.bornTime) * 0.5))
                badgeY = (u.zoneTop + u.zoneBot) / 2.0
                u.badge := label.new(badgeTime, badgeY, badgeTxt, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_center, color = drawCol, textcolor = headerText, size = f_toSize(labelSize))

        array.set(unicorns, i, u)

// -----------------------------------------------------
// Panel
// -----------------------------------------------------
var table pnl = na

if showPanel and barstate.islast
    if na(pnl)
        pnl := table.new(f_panelPos(panelLoc), 2, 11, border_color = f_panelBorder(), border_width = 1, frame_color = f_panelBorder(), frame_width = 1, bgcolor = f_panelBg())
    table.set_position(pnl, f_panelPos(panelLoc))
    ts = f_toSize(panelTextSize)
    table.clear(pnl, 0, 0, 1, 10)

    // Header (single merged blue row)
    table.merge_cells(pnl, 0, 0, 1, 0)
    table.cell(pnl, 0, 0, "AG Pro Unicorn Model Detector", text_color = headerText, bgcolor = headerBg, text_size = ts, text_halign = text.align_center)

    // Primary setup readout
    string entryTxt = "-"
    string stopTxt = "-"
    string tgtTxt = "-"
    string confluenceTxt = "-"
    color setupCol = f_panelValue()
    if gPrimaryIdx >= 0
        pu = array.get(unicorns, gPrimaryIdx)
        entryTxt := str.tostring(pu.entry, format.mintick)
        stopTxt := str.tostring(pu.stop, format.mintick)
        tgtTxt := str.tostring(pu.target, format.mintick)
        confluenceTxt := "OV " + str.tostring(math.round(pu.qOverlap)) + "/30 | FVG " + str.tostring(math.round(pu.qFvg)) + "/20"
        setupCol := pu.dir == "bull" ? bullColor : bearColor

    // Readiness
    readyTxt = gPrimaryIdx >= 0 ? str.tostring(gPrimaryReady) + " / 100" : "-"
    readyCol = gPrimaryIdx < 0 ? f_panelValue() : gPrimaryReady >= 70 ? bullColor : gPrimaryReady >= 45 ? neutralColor : f_panelLabel()
    table.cell(pnl, 0, 1, "Readiness", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 1, readyTxt, text_color = readyCol, bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Action
    actCol = gAction == "Manage Active" ? accentColor : gAction == "Arm Entry" ? bullColor : gAction == "Track Retest" ? neutralColor : gAction == "Wait For Trigger" ? f_panelLabel() : f_panelValue()
    table.cell(pnl, 0, 2, "Action", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 2, gAction, text_color = actCol, bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Setup
    table.cell(pnl, 0, 3, "Setup", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 3, gSetup, text_color = setupCol, bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Entry / Stop / Target
    table.cell(pnl, 0, 4, "Entry", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 4, entryTxt, text_color = f_panelValue(), bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)
    table.cell(pnl, 0, 5, "Stop", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 5, stopTxt, text_color = gPrimaryIdx >= 0 ? bearColor : f_panelValue(), bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)
    table.cell(pnl, 0, 6, "Target", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 6, tgtTxt, text_color = gPrimaryIdx >= 0 ? bullColor : f_panelValue(), bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Breaker + FVG confluence evidence
    table.cell(pnl, 0, 7, "Confluence", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 7, confluenceTxt, text_color = gPrimaryIdx >= 0 ? accentColor : f_panelValue(), bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // R : R
    table.cell(pnl, 0, 8, "R : R", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 8, "1 : " + str.tostring(rrTarget, "#.0"), text_color = f_panelValue(), bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Win Rate (proof layer) + sample size
    winRate = proofTotal > 0 ? proofTp * 100.0 / proofTotal : na
    winTxt = proofTotal > 0 ? str.tostring(winRate, "#.0") + "%  -  " + str.tostring(proofTotal) : "-"
    winCol = proofTotal > 0 ? (winRate >= 50 ? bullColor : bearColor) : f_panelValue()
    table.cell(pnl, 0, 9, "Win Rate", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 9, winTxt, text_color = winCol, bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

    // Avg R
    avgR = proofTotal > 0 ? proofRSum / proofTotal : na
    avgTxt = proofTotal > 0 ? str.tostring(avgR, "#.00") + " R" : "-"
    avgCol = proofTotal > 0 ? (avgR > 0 ? bullColor : bearColor) : f_panelValue()
    table.cell(pnl, 0, 10, "Avg R", text_color = f_panelLabel(), bgcolor = f_panelBg(), text_size = ts)
    table.cell(pnl, 1, 10, avgTxt, text_color = avgCol, bgcolor = f_panelBg(), text_size = ts, text_halign = text.align_right)

if not showPanel and not na(pnl)
    table.delete(pnl)
    pnl := na
````
