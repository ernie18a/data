# Strong Session SD Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/SNvyeA6H-Strong-Session-SD-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;3cb90322ccaa4cbd9e13c925a6c5ec3d
- version: 1.0

## Description

[b]Strong Session SD Zones[/b]

Strong Session SD Zones automatically maps and power-ranks the session-based supply & demand zones that price keeps reacting to. It tracks each zone through its full life — formation, tests, breakout, and invalidation — scores it 0–10 from real interaction, and retains every session's zones for the last N sessions, so you can see exactly which levels each Asia / London / New York session left behind.

🎯 Power-Ranking System (0–10) — every zone earns a live score from four things: the impulse of the move that created it, the volume traded while it formed, the depth of the rejection wicks off it, and its freshness (how unmitigated it still is). An idle-decay lets ignored zones fade while respected ones stay strong, so the score always reflects current relevance.
🕐 Session-Aware Zones — instead of one undifferentiated cluster of levels, zones are batched by trading session and each one is tagged with where it was born (Asia, London, NY, Late). Pick Daily, Asian, London, New York, or a custom session as the boundary that starts each new batch.
🔁 Hold vs Broken States — each zone is shaded by type (supply = red, demand = green) and re-shaded the moment price invalidates it, with a ✗ marker on broken zones. You see at a glance whether a level is still defending or has flipped.
🎨 Strength-Sharpened Fill — strong zones render sharp and opaque while weak ones stay faint, so the chart visually shows which levels carry weight before you even read the score.
🏷️ In-Zone Strength Labels — every zone carries its grade inside it: stars, the X.X/10 score, a tier (FORMING → WEAK → MODERATE → STRONG → ELITE), the live retest count (R:), and its session — quality reads instantly without a separate panel.

🧹 Overlap Suppression — when a new zone would stack on an existing same-session zone, the two are merged into one clean band instead of cluttering the area, so each price region shows a single level.
⭐ Strong-Only Filter — hide everything below a score threshold; weak zones that never earn the score are discarded rather than kept, so the chart only carries proven levels.
🔔 Comprehensive Native Alerts — proximity alerts for supply and demand zones, a dedicated STRONG-zone proximity alert (configurable, e.g. 7/10+), plus new-supply and new-demand formation events, so you never miss a key level interaction.
⚙️ Uniform Zone Height — normalize every zone to one ATR-based thickness for a clean, consistent look, with a minimum-swing filter that ignores insignificant pivots.
🚦 Performance Guards — a sessions-to-display window and a max-zones-kept cap keep load times fast on long histories; retired zones are fully removed, not just hidden.
🔧 Fully Customizable — color palette, transparency, borders, label size, scoring weights, pivot sensitivity, max zones per session, decay settings, and invalidation method (close vs wick) — all adjustable.

🎯 Why this algo is unique — standard pivot tools flood the chart with equal-weight lines. Strong Session SD Zones filters, merges, and ranks them by session, then keeps only the zones that have proven they matter. It doesn't just show where a level was — it quantifies how strong it is from real interaction (impulse, volume, rejection, freshness), giving you a clear read on which zones are holding and which are likely to break.
🚀 Apply to Gold (XAUUSD), Forex, Crypto, and Indices on any timeframe. Pivot sensitivity, zone height, sessions shown, and the strong threshold adapt it from scalping to swing trading.
🎯 How to use this? Focus on zones rated 7/10 or higher — these have the highest probability of producing a significant reaction. Watch the hold-vs-broken state to judge whether a level is defending or has flipped, and use the proximity and strong-zone alerts to prepare entries or exits.

⚠️ IMPORTANT NOTICE: This indicator identifies high-probability supply & demand zones. It should NOT be used as a standalone signal for entering trades. Always use it alongside your own trading strategy, price action analysis, and other technical indicators to confirm setups and manage risk.

## Source Code

````pine
//@version=6
indicator("Strong Session SD Zones", overlay = true, max_boxes_count = 500, max_labels_count = 500)


// ─────────────────────────── INPUTS ───────────────────────────
gSess        = "═══ Session ═══"
sessionMode  = input.string("Daily", "New-Zone Session", options = ["Daily", "Asian", "London", "New York", "Custom"], group = gSess, tooltip = "Boundary that starts a new batch of zones.")
customSess   = input.session("0000-2359", "Custom Session", group = gSess)
sessTZ       = input.string("", "Timezone (blank = exchange)", group = gSess)
sessionsBack = input.int(10, "Sessions To Display", minval = 1, maxval = 60, group = gSess, tooltip = "Show zones from this many of the most recent sessions.")
maxPerSession= input.int(3, "Max Zones Per Side / Session", minval = 1, maxval = 10, group = gSess)
fadeOld      = input.bool(true, "Fade Older Sessions (same colour)", group = gSess)

gDet         = "═══ Zone Detection ═══"
swingLen     = input.int(12, "Swing Length (sensitivity)", minval = 3, maxval = 50, tooltip = "Higher = fewer, more significant zones", group = gDet)
minZoneDist  = input.int(15, "Min Distance Between Zones (bars)", minval = 1, maxval = 200, group = gDet)
mergeOverlap = input.bool(true, "Merge Overlapping Zones", group = gDet)

gH           = "═══ Zone Height (ATR) ═══"
atrLen       = input.int(20, "ATR Length", minval = 1, maxval = 500, group = gH)
uniHeight    = input.float(0.5, "Universal Zone Height (ATR x)", minval = 0.1, maxval = 5.0, step = 0.05, tooltip = "Every zone is this exact thickness, centred on the level. Uniform, slick bands.", group = gH)
minSwingATR  = input.float(0.3, "Ignore Pivots Smaller Than (ATR x)", minval = 0.0, maxval = 3.0, step = 0.1, tooltip = "Reject insignificant swings whose raw range is below this.", group = gH)

gBeh         = "═══ Behaviour ═══"
invMethod    = input.string("Close", "Invalidation", options = ["Close", "Wick"], group = gBeh)
labelOffset  = input.int(0, "Label Nudge (bars; positive = further into the band)", minval = -100, maxval = 100, group = gBeh)

gStr         = "═══ Strength Scoring (0-10) ═══"
onlyStrong   = input.bool(false, "Show Only Strong Zones", group = gStr)
strongThr    = input.float(4.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
touchNorm    = input.float(3.0, "Touches Until Fully Consumed", minval = 1, step = 0.5, group = gStr)
impulseNorm  = input.float(3.0, "Impulse For Full Score (ATR x)", minval = 0.5, step = 0.5, group = gStr)
volLen       = input.int(20, "Volume Baseline Length", minval = 1, group = gStr)
wImp         = input.float(0.35, "Weight: Departure Impulse", minval = 0, maxval = 1, step = 0.05, group = gStr)
wVol         = input.float(0.20, "Weight: Volume", minval = 0, maxval = 1, step = 0.05, group = gStr)
wWick        = input.float(0.20, "Weight: Rejection Wick", minval = 0, maxval = 1, step = 0.05, group = gStr)
wFresh       = input.float(0.25, "Weight: Freshness (unmitigated)", minval = 0, maxval = 1, step = 0.05, group = gStr)
useDecay     = input.bool(true, "Decay Strength While Idle", group = gStr)
decayBars    = input.int(600, "Full Decay Over (idle bars)", minval = 20, maxval = 20000, group = gStr)
decayFloor   = input.float(0.6, "Decay Floor", minval = 0.1, maxval = 1.0, step = 0.05, group = gStr)

gDisp        = "═══ Display ═══"
showLabels   = input.bool(true, "Show Zone Stats", group = gDisp)
labelSize    = input.string("Large", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gDisp)

gCol         = "═══ Colors / Shading ═══"
supCol       = input.color(#e54b5e, "Supply", group = gCol)
demCol       = input.color(#27c07a, "Demand", group = gCol)
sharpenByStr = input.bool(true, "Sharpen Fill By Strength", group = gCol, tooltip = "Strong zones render sharp/opaque, weak ones faint — like the reference strength bar.")
trStrong     = input.int(58, "Strongest Fill Transparency", minval = 30, maxval = 90, group = gCol)
trWeak       = input.int(82, "Weakest Fill Transparency", minval = 40, maxval = 96, group = gCol)
trBroken     = input.int(88, "Invalidated Fill Transparency", minval = 50, maxval = 96, group = gCol)
borderTransp = input.int(20, "Border Transparency", minval = 0, maxval = 100, group = gCol)
borderWidth  = input.int(1, "Border Width", minval = 0, maxval = 4, group = gCol)
bestSupTxt   = input.color(#ff9d3c, "Best Supply Text", group = gCol)
bestDemTxt   = input.color(#7bf7b0, "Best Demand Text", group = gCol)
normTxt      = input.color(#e8eaed, "Normal Text", group = gCol)

gAl          = "═══ Alerts ═══"
alertsOn     = input.bool(true, "Enable Alerts", group = gAl)
alertProx    = input.float(0.10, "Proximity (% of price)", minval = 0.0, step = 0.01, group = gAl)
instThr      = input.float(7.0, "Strong-Zone Score", minval = 0, maxval = 10, step = 0.5, group = gAl)

// ─────────────────────────── HELPERS ───────────────────────────
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_stars(sc) => sc >= 8 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5 ? "★★" : sc >= 3 ? "★" : "·"
f_tier(sc)  => sc >= 8 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5 ? "MODERATE" : sc >= 3 ? "WEAK" : "FORMING"
f_ageF(idle) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(idle / math.max(decayBars, 1), 1.0), decayFloor)

f_sessName(tz) =>
    h = hour(time, tz)
    h >= 0 and h < 8 ? "Asia" : h >= 8 and h < 13 ? "London" : h >= 13 and h < 22 ? "NY" : "Late"

f_score(float impF, float volF, float wickF, int touches, int idle) =>
    freshF = math.max(0.0, 1.0 - touches / math.max(touchNorm, 1.0))
    wSum   = wImp + wVol + wWick + wFresh
    raw    = wSum > 0 ? (impF * wImp + volF * wVol + wickF * wWick + freshF * wFresh) / wSum : 0.0
    math.min(math.max(raw * 10.0 * f_ageF(idle), 0.0), 10.0)

f_overlap(float t1, float b1, float t2, float b2) => t1 >= b2 and b1 <= t2

// ─────────────────────────── STATE ───────────────────────────
atr     = ta.atr(atrLen)
volBase = ta.sma(volume, volLen)
loSwing = ta.lowest(low, swingLen)
hiSwing = ta.highest(high, swingLen)
n       = bar_index
tzUse   = sessTZ == "" ? syminfo.timezone : sessTZ
offMs   = labelOffset * timeframe.in_seconds(timeframe.period) * 1000

type Zone
    box    bx
    label  lab
    float  top
    float  bot
    float  mid
    int    leftTime
    int    rightTime
    int    bornBar
    int    lastTouch
    int    sessId
    string sess
    string kind
    int    touches
    bool   inPrev
    bool   broken
    float  impF
    float  volF
    float  wickF
    float  score

var array<Zone> zones = array.new<Zone>()
var int  sessId       = 0
var int  lastSupBar   = 0
var int  lastDemBar   = 0

f_makeZone(string kind, float pivTop, float pivBot, int startBar, float impF, float volF, float wickF) =>
    level = kind == "Supply" ? pivTop : pivBot
    h     = atr * uniHeight
    t     = level + h / 2.0
    b     = level - h / 2.0
    Zone.new(na, na, t, b, level, time[swingLen], time, startBar, n, sessId, f_sessName(tzUse), kind, 0, false, false, impF, volF, wickF, 0.0)

f_sortDesc(array<int> idx) =>
    sz = array.size(idx)
    if sz > 1
        for a = 0 to sz - 2
            bIdx = a
            for b = a + 1 to sz - 1
                if array.get(zones, array.get(idx, b)).score > array.get(zones, array.get(idx, bIdx)).score
                    bIdx := b
            if bIdx != a
                tmp = array.get(idx, a)
                array.set(idx, a, array.get(idx, bIdx))
                array.set(idx, bIdx, tmp)

f_visible(Zone z, int minSess) =>
    z.sessId >= minSess and (not onlyStrong or z.score >= strongThr)

// Draw a shown zone: type-coloured fill + single-line label centred INSIDE the band at the right edge.
f_drawZone(int zi, int rank, bool isBest) =>
    z = array.get(zones, zi)
    baseCol = z.kind == "Supply" ? supCol : demCol
    // sharper = more opaque for stronger zones (reference strength-bar style)
    int tr = z.broken ? trBroken : (sharpenByStr ? int(math.round(trWeak - (trWeak - trStrong) * (z.score / 10.0))) : trStrong)
    tr := fadeOld and z.sessId != sessId and not z.broken ? math.min(tr + 6, 96) : tr
    box.set_bgcolor(z.bx, color.new(baseCol, tr))
    box.set_border_color(z.bx, isBest ? color.new(baseCol, 0) : color.new(baseCol, borderTransp))
    box.set_border_width(z.bx, isBest ? math.max(borderWidth, 2) : borderWidth)
    if showLabels
        tag   = (z.kind == "Supply" ? "S" : "D") + str.tostring(rank) + (isBest ? "«BEST" : "") + (z.broken ? " ✗" : "")
        pr    = str.tostring(z.bot, format.mintick) + ".." + str.tostring(z.top, format.mintick)
        txt   = tag + "  " + pr + "  " + f_stars(z.score) + str.tostring(math.round(z.score * 10) / 10) + "/10 " + f_tier(z.score) + "  R:" + str.tostring(z.touches) + "  " + z.sess
        tcol  = isBest ? (z.kind == "Supply" ? bestSupTxt : bestDemTxt) : (z.broken ? color.new(baseCol, 15) : normTxt)
        if na(z.lab)
            z.lab := label.new(z.leftTime + offMs, z.mid, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = tcol, size = f_size(labelSize), textalign = text.align_left)
        label.set_text(z.lab, txt)
        label.set_xy(z.lab, z.leftTime + offMs, z.mid)
        label.set_textcolor(z.lab, tcol)
        label.set_size(z.lab, f_size(labelSize))

f_hideZone(int zi) =>
    z = array.get(zones, zi)
    box.set_bgcolor(z.bx, color.new(color.black, 100))
    box.set_border_width(z.bx, 0)
    if not na(z.lab)
        label.set_text(z.lab, "")

// Render one side: per session (newest first), top-N by strength; overall strongest = «BEST.
f_renderSide(string kind) =>
    minSess = math.max(0, sessId - sessionsBack + 1)
    gBestIdx = -1
    gBest = -1.0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if z.kind == kind and not z.broken and f_visible(z, minSess) and z.score > gBest
                gBest := z.score
                gBestIdx := i
    for s = sessId to minSess
        idx = array.new<int>()
        if array.size(zones) > 0
            for i = 0 to array.size(zones) - 1
                z = array.get(zones, i)
                if z.kind == kind and z.sessId == s and f_visible(z, minSess)
                    array.push(idx, i)
        f_sortDesc(idx)
        shown = 0
        if array.size(idx) > 0
            for k = 0 to array.size(idx) - 1
                zi = array.get(idx, k)
                if shown < maxPerSession
                    shown += 1
                    f_drawZone(zi, shown, zi == gBestIdx)
                else
                    f_hideZone(zi)

// ─────────────────────────── SESSION CLOCK ───────────────────────────
bool newSession = false
if sessionMode == "Daily"
    newSession := nz(ta.change(time("D")), 0) != 0
else
    sStr = sessionMode == "Asian" ? "0000-0800" : sessionMode == "London" ? "0800-1300" : sessionMode == "New York" ? "1300-2200" : customSess
    inS  = not na(time(timeframe.period, sStr, tzUse))
    newSession := inS and not inS[1]
if newSession
    sessId += 1

// ─────────────────────────── ZONE DETECTION ───────────────────────────
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

bool evNewSup = not na(ph) and barstate.isconfirmed
bool evNewDem = not na(pl) and barstate.isconfirmed

if evNewSup and n - lastSupBar >= minZoneDist and (high[swingLen] - low[swingLen]) >= atr * minSwingATR
    dep  = high[swingLen] - loSwing
    impF = math.min(math.max(dep, 0.0) / math.max(atr * impulseNorm, 1e-9), 1.0)
    volF = nz(volBase) > 0 ? math.min(nz(volume[swingLen]) / volBase, 1.0) : 0.0
    rng  = math.max(high[swingLen] - low[swingLen], 1e-9)
    wF   = math.min(math.max(high[swingLen] - math.max(open[swingLen], close[swingLen]), 0.0) / rng, 1.0)
    z = f_makeZone("Supply", high[swingLen], low[swingLen], n - swingLen, impF, volF, wF)
    merged = false
    if mergeOverlap and array.size(zones) > 0
        for i = array.size(zones) - 1 to math.max(0, array.size(zones) - 12)
            e = array.get(zones, i)
            if e.kind == "Supply" and not e.broken and e.sessId == sessId and f_overlap(z.top, z.bot, e.top, e.bot)
                e.top := math.max(z.top, e.top)
                e.bot := math.min(z.bot, e.bot)
                e.mid := (e.top + e.bot) / 2.0
                box.set_top(e.bx, e.top)
                box.set_bottom(e.bx, e.bot)
                merged := true
                break
    if not merged
        z.bx := box.new(z.leftTime, z.top, z.rightTime, z.bot, xloc = xloc.bar_time, bgcolor = color.new(supCol, trStrong), border_color = color.new(supCol, borderTransp), border_width = borderWidth)
        array.push(zones, z)
        lastSupBar := n

if evNewDem and n - lastDemBar >= minZoneDist and (high[swingLen] - low[swingLen]) >= atr * minSwingATR
    dep  = hiSwing - low[swingLen]
    impF = math.min(math.max(dep, 0.0) / math.max(atr * impulseNorm, 1e-9), 1.0)
    volF = nz(volBase) > 0 ? math.min(nz(volume[swingLen]) / volBase, 1.0) : 0.0
    rng  = math.max(high[swingLen] - low[swingLen], 1e-9)
    wF   = math.min(math.max(math.min(open[swingLen], close[swingLen]) - low[swingLen], 0.0) / rng, 1.0)
    z = f_makeZone("Demand", high[swingLen], low[swingLen], n - swingLen, impF, volF, wF)
    merged = false
    if mergeOverlap and array.size(zones) > 0
        for i = array.size(zones) - 1 to math.max(0, array.size(zones) - 12)
            e = array.get(zones, i)
            if e.kind == "Demand" and not e.broken and e.sessId == sessId and f_overlap(z.top, z.bot, e.top, e.bot)
                e.top := math.max(z.top, e.top)
                e.bot := math.min(z.bot, e.bot)
                e.mid := (e.top + e.bot) / 2.0
                box.set_top(e.bx, e.top)
                box.set_bottom(e.bx, e.bot)
                merged := true
                break
    if not merged
        z.bx := box.new(z.leftTime, z.top, z.rightTime, z.bot, xloc = xloc.bar_time, bgcolor = color.new(demCol, trStrong), border_color = color.new(demCol, borderTransp), border_width = borderWidth)
        array.push(zones, z)
        lastDemBar := n

// prune zones older than the display window (front = oldest; sessId non-decreasing)
minKeep = math.max(0, sessId - sessionsBack - 1)
nPrune = 0
keepHit = false
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        isOld = array.get(zones, i).sessId < minKeep
        keepHit := keepHit or not isOld
        if isOld and not keepHit
            nPrune += 1
nPrune := math.max(nPrune, array.size(zones) - 480)
if nPrune > 0
    for i = 0 to nPrune - 1
        old = array.shift(zones)
        box.delete(old.bx)
        if not na(old.lab)
            label.delete(old.lab)

// ─────────────────────────── PER-BAR STATE UPDATE ───────────────────────────
bool evTouch = false
bool evBreak = false
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if z.sessId == sessId
            z.rightTime := time
            box.set_right(z.bx, time)
        if not z.broken
            inZone = high >= z.bot and low <= z.top
            if inZone and not z.inPrev
                z.touches   += 1
                z.lastTouch := n
                evTouch     := true
                wk  = z.kind == "Supply" ? math.max(high - math.max(open, close), 0.0) : math.max(math.min(open, close) - low, 0.0)
                rng = math.max(high - low, 1e-9)
                z.wickF := math.min(z.wickF + wk / rng, 1.0)
            z.inPrev := inZone
            brk = z.kind == "Supply" ? (invMethod == "Close" ? close : high) > z.top : (invMethod == "Close" ? close : low) < z.bot
            if brk
                z.broken := true
                evBreak  := true

// ─────────────────────────── RANK + DRAW (live edge) ───────────────────────────
if barstate.islast and array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        z.score := f_score(z.impF, z.volF, z.wickF, z.touches, n - z.lastTouch)
    f_renderSide("Supply")
    f_renderSide("Demand")

// ─────────────────────────── ALERTS ───────────────────────────
bool nearSup = false
bool nearDem = false
bool nearStrong = false
prox = close * alertProx / 100.0
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if not z.broken and math.abs(close - z.mid) <= prox
            if z.kind == "Supply"
                nearSup := true
            else
                nearDem := true
            if z.score >= instThr
                nearStrong := true

alertcondition(evNewSup and alertsOn,   "New Supply Zone",  "{{ticker}} new supply zone")
alertcondition(evNewDem and alertsOn,   "New Demand Zone",  "{{ticker}} new demand zone")
alertcondition(nearSup and alertsOn,    "Near Supply",      "{{ticker}} price approaching supply")
alertcondition(nearDem and alertsOn,    "Near Demand",      "{{ticker}} price approaching demand")
alertcondition(nearStrong and alertsOn, "Near STRONG Zone", "{{ticker}} price approaching a strong zone")
````
