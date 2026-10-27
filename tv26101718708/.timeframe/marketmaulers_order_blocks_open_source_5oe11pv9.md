# MarketMaulers Order Blocks (Open Source)

- url: https://www.tradingview.com/script/5oE11Pv9-MarketMaulers-Order-Blocks-Open-Source/
- type: indicator
- pine_id: PUB;cf88deb7ad724b6c8d7a41e09a780546
- version: 1.0

## Description

MarketMaulers Order Blocks automatically marks institutional Order Blocks: the last opposing candle before a displacement leg that BREAKS MARKET STRUCTURE (BOS). That candle is where the move was loaded, and price returns to it to fill unfinished business, which is why order blocks act as high-probability support and resistance.

WHY THE BOS REQUIREMENT
An order block is only meaningful if it sits at the origin of a real structure break. The engine ignores random candles and only marks the opposing candle at the origin of a leg that breaks a swing point, so what you see is a genuine order block and not any pullback candle.

WHAT IT MARKS
• Bullish OB · a down candle before an up-move that breaks a swing high, which becomes a demand / support zone
• Bearish OB · an up candle before a down-move that breaks a swing low, which becomes a supply / resistance zone

HOW THE ZONE IS DRAWN
Zones use the full range of the origin candle (wick low to body high for bullish, wick high to body low for bearish), not only the body, because that whole span is the range price defends on the return. When a single displacement candle takes out a run of opposing candles in one shot, the zone spans the WHOLE cluster it engulfed, so the order block reflects all of the supply or demand the move absorbed.

REAL-TIME LIFECYCLE
Every block is tracked live: Fresh (untouched), then Mitigated (tapped once), then Broken (a close through it, the zone is spent). You always know what is still valid.

REFINEMENTS
• OB Origin · choose the Cluster, the Nearest or the Extreme opposing candle
• Optional FVG-confluence filter · require an imbalance after the block
• Kill-zone and displacement filters to cut noise
• Automatic higher-timeframe order blocks · up to 2 HTF slots, each with its own colors, never evicted by lower-timeframe crowding. A higher-timeframe block is judged on its own timeframe's close, so it holds on a lower-timeframe chart exactly as long as it holds on its own

ALERTS
New Bullish OB · New Bearish OB · OB Mitigated · OB Broken

Works on any market and any timeframe.

Display only. This marks zones, it does not fire buy/sell signals. Educational tool, not financial advice.

Published open-source. This is the same indicator as MarketMaulers Order Blocks, published here with the source readable. The swing and break of structure engine, the cluster origin rule, the higher-timeframe slots and the mitigation and break tracking are all in the code. Everything above explains what it marks and how it decides what to mark; the code is there so you can check that the description is accurate rather than take it on faith. Read it, fork it, argue with the constants.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  MarketMaulers Order Blocks  ·  v1.8
//  ─────────────────────
//  v1.8 (2026-08-23): TWO HTF BUGS FIXED. THIS IS A CORRECTNESS RELEASE.
//  Both were found in a sibling zone tool on 2026-08-23, on a live chart: a live 4H
//  zone visible on the 4H chart and absent on 15m. One symptom, two independent causes,
//  and this file shares that chassis, so it carried both. No inputs changed. Anyone
//  running it on an LTF chart with an HTF slot on has been seeing fewer order blocks than the
//  engine actually found, and losing the survivors early.
//
//  1. BIRTH: the rising edge dropped back-to-back HTF zones.
//     Each slot gated f_add() behind `hXgB and not hXgB[1]`. On history a lookahead_off
//     read returns the last CLOSED HTF bar, so the flag stays TRUE across every LTF bar
//     of the FOLLOWING HTF bar. A rising edge needs the flag to go false in between, and
//     when two consecutive HTF bars each produce a zone in the SAME direction it never
//     does. The second one, the newer one, the one nearest price, silently never drew.
//     On the HTF chart itself there is no security read and no stepped flag, so it drew
//     there. Fixed with the suite's token idiom: a per-slot, per-direction `var int`
//     holding the HTF bar's own open time, consumed at detection, declared outside the
//     `if useHX` gate so a slot toggled off cannot bank a fire and release it later.
//     The same fix runs in the sibling gap and zone tools in this suite.
//
//  2. DEATH: the break test read the CHART bar's close for every zone.
//     A break here is ALWAYS a close, by design, so this one had no Wick setting to hide
//     behind: a 4H zone viewed on 15m died the moment any 15m candle closed past its far
//     edge, while on the 4H chart it needed a 4H close. With Remove Broken on (the
//     default) that DELETED it, so the symptom was a missing zone rather than a faded
//     one. Mitigation had the same defect in Close mode.
//     The rule now: a WICK test stays chart-based, because a wick through a level is a
//     wick through it on every timeframe and the LTF chart only sees it sooner. A CLOSE
//     test belongs to the timeframe that OWNS the zone, because a 15m close is not a 4H
//     close. Each zone stores its slot (oTfi: 0 = chart TF, 1-2 = HTF slot) and the
//     engine returns its context's `close` so the kill price and the detection come from
//     the same stepped read.
//
//  Expect MORE HTF zones on LTF charts after this, and expect them to persist longer.
//  Both are the fix working. The HTF chart is the authority on an HTF zone.
//  ─────────────────────

//  v1.7: CLUSTER origin (new default): when the displacement engulfs a RUN of
//        consecutive opposing candles in one shot, the OB now spans the WHOLE
//        cluster, not just the last opposing candle. The standing rule in this suite (see f_obRun).
//        Nearest / Extreme single-candle modes kept as options.
//  v1.6: HTF OBs are now EXEMPT from the Max-OBs cull, so LTF crowding never
//        evicts a higher-timeframe level (matches the Breaker fix).
//  v1.5: HTF OBs get their OWN per-slot Bull/Bear color inputs (same pattern as
//        the HTF overlays elsewhere in this suite); each OB stores its base color
//        so chart + HTF keep their colors through the lifecycle. Chart OBs now
//        also carry their TF in the label ("MM 5m Bull OB").
//  v1.4: AUTO HTF OBs. The manual hand-typed HTF slots are replaced by an
//        automatic engine: the OB detection runs inside request.security on up
//        to 2 higher timeframes (f_obHTF), HTF OBs found + tracked like chart OBs.
//        Mirrors the Rejection Block's auto-HTF pattern.
//  v1.3: zone labels now brand-prefixed "MM Bull OB / MM Bear OB" (suite-wide
//        branding: every screenshot carries the mark). No logic change.
//  ───────────────────────────
//  Auto-detects institutional Order Blocks: the opposing candle at the
//  origin of a displacement leg that BREAKS STRUCTURE (BOS).
//    • Bullish OB = down candle before an up-move that breaks a swing high
//    • Bearish OB = up candle   before a down-move that breaks a swing low
//  Zones are drawn the Mauler way (the full trap range, not just the body):
//    • Bullish OB: wick low  → body high
//    • Bearish OB: wick high → body low
//  Real-time mitigation tracking: Fresh → Mitigated (tapped) → Broken.
//  Optional killzone filter, displacement filter, and automatic HTF OB slots.
//
//  v1.2: OB Origin picker (Nearest vs Extreme opposing candle) + optional
//        FVG-confluence filter (an OB must be followed by an imbalance):
//        both standard ICT refinements, implemented in-house.
//
//  Display-only: marks zones, no buy/sell signals.
//  Works on: NQ, ES, MNQ, MES, forex, crypto: anything with a chart.
//  Built by Market Maulers · Free forever
// ═══════════════════════════════════════════════════════════════════════
indicator("MarketMaulers Order Blocks", shorttitle="MM OB", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500)


// ═══════════════════════════════════════════════════════════════════════
//  LOCKED CALIBRATION (v1.0): constants, deliberately NOT inputs
// ═══════════════════════════════════════════════════════════════════════
//  These are tuned defaults that a "reset settings" must never wipe.
int   OB_MAXSCAN = 12       // how far back (bars) to hunt for the origin candle
                            //   before a BOS. 12 caps a displacement leg length:
                            //   longer legs usually mean the OB already mitigated.
int   OB_HARDCAP = 300      // total tracked OBs, drawing-limit safety net
int   OB_ATRLEN  = 14       // ATR length for the displacement filter


// ═══════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════

// ── Detection ──
grpD      = "OB Detection"
showBull  = input.bool(true,  "Bullish OBs",        group=grpD, inline="b")
bullCol   = input.color(color.new(#00bcd4, 80), "", group=grpD, inline="b")
showBear  = input.bool(true,  "Bearish OBs",        group=grpD, inline="s")
bearCol   = input.color(color.new(#ff5252, 80), "", group=grpD, inline="s")
pivLen    = input.int(5, "Structure Sensitivity",   minval=2, maxval=50, group=grpD,
     tooltip="Swing pivot strength used to define market structure. A BOS is a close beyond the most recent swing. Higher = only major swings count (fewer, cleaner OBs); lower = more sensitive (more OBs, more noise). 5 is a good default for NQ intraday.")
useDisp   = input.bool(true, "Displacement Filter",  group=grpD,
     tooltip="When ON, the leg that breaks structure must travel at least the multiple below (in ATR) from the OB — proof of an institutional move, not a drift. Turn OFF on very low timeframes if valid OBs are missed.")
dispMult  = input.float(1.5, "  Displacement × ATR", minval=0.1, maxval=10, step=0.1, group=grpD,
     active=useDisp,
     tooltip="Minimum leg travel from the OB to the break, in ATRs. 1.5 keeps only decisive breaks. Raise to be pickier.")
maxShow   = input.int(12, "Max OBs on Chart",       minval=1, maxval=100, group=grpD,
     tooltip="Oldest OBs are culled once this many are on screen. Broken OBs don't count if 'Remove Broken' is on.")
originMode = input.string("Cluster", "OB Origin", options=["Cluster","Nearest","Extreme"], group=grpD,
     tooltip="How the OB zone is sized when the break leg contains several opposing candles.\n\nCluster (default, the Maulers way) — when the up-move takes out a RUN of consecutive down candles in one shot, the zone spans the FULL cluster (the whole selling range), not just the last candle. This is the honest read: the displacement absorbed all of that supply, so the whole range is the order block.\n\nNearest — only the LAST opposing candle before the break (classic single-candle 'last down candle before the up-move').\n\nExtreme — only the single deepest opposing candle in the leg.\n\nSingle-candle breaks look identical in all three modes; Cluster only differs when a displacement engulfs multiple candles at once.")
useFvg    = input.bool(false, "Require FVG Confluence", group=grpD,
     tooltip="When ON, an OB only qualifies if a Fair Value Gap (imbalance) forms right after it — ICT's proof that the move was a real displacement, not a drift. Stricter than the ATR filter; use both for A+ only.")
fvgDist   = input.int(3, "  Max OB→FVG distance (bars)", minval=1, maxval=8, group=grpD,
     active=useFvg,
     tooltip="How many bars after the OB the imbalance is allowed to form. 3 is a good default — a genuine displacement leaves the gap almost immediately.")

// ── Lifecycle ──
grpL      = "Lifecycle"
mitigMode = input.string("Wick", "Mitigation Trigger", options=["Wick","Close"], group=grpL,
     tooltip="Wick = a wick tapping the zone counts as mitigated. Close = only a candle CLOSE into the zone counts. Close is stricter — OBs stay 'Fresh' longer.")
removeBroken = input.bool(true, "Remove Broken OBs", group=grpL,
     tooltip="A break = a candle CLOSE through the far side of the zone (invalidation). On = broken OBs are deleted. Off = they stay as faded zones for reference.")
keepMitig = input.bool(true, "Keep Mitigated OBs",  group=grpL,
     tooltip="On = a tapped (mitigated) OB stays on the chart, faded, until it's broken. Off = it's removed on first tap.")

// ── Kill Zone Filter ──
grpK      = "Kill Zone Filter"
useKZ     = input.bool(false, "Only Detect in Kill Zones", group=grpK,
     tooltip="When enabled, an OB only qualifies if its origin candle formed during an active kill zone. Filters out OBs built outside institutional hours.")
kzNY      = input.bool(true,  "NY AM (9:30–11:00 EST)",   group=grpK)
kzLon     = input.bool(true,  "London (2:00–5:00 EST)",   group=grpK)
kzLC      = input.bool(true,  "London Close (10:00–12:00 EST)", group=grpK)
kzAsian   = input.bool(false, "Asian (20:00–0:00 EST)",   group=grpK)

// ── Display ──
grpV      = "Display"
showCE    = input.bool(true,  "Show CE Line (50%)", group=grpV,
     tooltip="Consequent Encroachment — the 50% midpoint of the OB. ICT traders watch for reactions at this level.")
ceStyle   = input.string("Dotted", "CE Style",      options=["Solid","Dashed","Dotted"], group=grpV)
ceCol     = input.color(color.new(color.white, 30), "CE Color", group=grpV)
showLbl   = input.bool(true,  "Show Labels",        group=grpV, inline="lbl")
lblCol    = input.color(color.new(color.white, 15), "", group=grpV, inline="lbl")
extendR   = input.int(3, "Right Extend (bars)",     minval=0, maxval=50, group=grpV,
     tooltip="Extra bars to project active OB zones to the right of the current bar, so live zones aren't hidden behind price.")

// ── Higher-Timeframe OBs (AUTO-detected, not manual) ──
// The full OB engine (swing → BOS → origin candle → displacement) runs INSIDE
// request.security on each higher TF, so HTF order blocks are found automatically
// and tracked through the SAME Fresh→Mitigated→Broken lifecycle as chart OBs.
// No hand-typing. Same pattern as the Rejection Block's auto-HTF slots.
grpH      = "Higher-Timeframe OBs"
htfInfo   = input.bool(false, "ⓘ  How HTF OBs work", group=grpH,
     tooltip="Each slot re-runs the whole Order Block engine on a higher timeframe via request.security and draws that TF's OBs on your chart, tagged (e.g. 'MM 4H Bull OB') and tracked like any other OB. It's fully automatic — no price entry. A slot only draws when its timeframe is ABOVE the chart TF. HTF OBs use the same Structure Sensitivity and Displacement Filter as the chart, minus the killzone/FVG filters.")
useH1     = input.bool(false, "HTF 1", group=grpH, inline="h1")
h1TF      = input.timeframe("60",  "", group=grpH, inline="h1")
h1Bull    = input.color(color.new(#00bcd4, 80), "", group=grpH, inline="h1")
h1Bear    = input.color(color.new(#ff5252, 80), "", group=grpH, inline="h1")
useH2     = input.bool(false, "HTF 2", group=grpH, inline="h2")
h2TF      = input.timeframe("240", "", group=grpH, inline="h2")
h2Bull    = input.color(color.new(#00bcd4, 80), "", group=grpH, inline="h2")
h2Bear    = input.color(color.new(#ff5252, 80), "", group=grpH, inline="h2",
     tooltip="Two higher-timeframe slots (default 1H + 4H). Enable a slot, pick its TF, and set its Bull / Bear zone colors — the engine auto-detects and draws that TF's order blocks in those colors.")


// ═══════════════════════════════════════════════════════════════════════
//  DATA ARRAYS  (parallel-array data model: one row per OB)
// ═══════════════════════════════════════════════════════════════════════
//  Delete discipline: f_del() MUST array.remove() every column at index i or
//  the rows desync. Every loop is size-guarded: Pine runs `for 0 to -1` ONCE.

var array<float>  oTop = array.new<float>()   // zone top price
var array<float>  oBot = array.new<float>()   // zone bottom price
var array<int>    oDir = array.new<int>()     // 1 = bullish, -1 = bearish
var array<int>    oSt  = array.new<int>()     // 0 = fresh, 1 = mitigated, 2 = broken
var array<int>    oBI  = array.new<int>()     // origin bar_index
var array<color>  oCol = array.new<color>()   // per-OB base color (chart or HTF bull/bear)
var array<bool>   oHtf = array.new<bool>()    // true = HTF OB (exempt from the Max-OBs cull)
var array<box>    oBx  = array.new<box>()     // zone box
var array<line>   oLn  = array.new<line>()    // CE midpoint line
// v1.8: which timeframe OWNS this zone: 0 = chart TF, 1-2 = the HTF slot that made
// it. Read only by the close-based tests, which must ask that timeframe's close and
// not the chart's. An int rather than a string compare because the loop runs over
// every zone on every bar.
var array<int>    oTfi = array.new<int>()    // owning timeframe slot


// ═══════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════

var int cePad = 4   // CE line stops short of the right edge so it clears the label

f_ceLS() =>
    ceStyle == "Solid" ? line.style_solid : ceStyle == "Dashed" ? line.style_dashed : line.style_dotted

// State → box color: fade the OB's OWN stored base color as it matures (the fill
// IS the state). Base is stored per-OB (oCol) so chart OBs and HTF OBs each keep
// their own bull/bear color through the lifecycle. fresh = base · mitigated/broken = faded.
f_colFade(color base, int st) =>
    st == 2 ? color.new(base, 92) : st == 1 ? color.new(base, 88) : base

// Kill Zone check: is a given bar time inside any enabled kill zone? (all times EST)
f_inKZ(int barTime) =>
    if not useKZ
        true
    else
        h    = hour(barTime, "America/New_York")
        m    = minute(barTime, "America/New_York")
        mins = h * 60 + m
        inNY    = kzNY    and mins >= 570  and mins < 660    // 9:30 – 11:00
        inLon   = kzLon   and mins >= 120  and mins < 300    // 2:00 – 5:00
        inLC    = kzLC    and mins >= 600  and mins < 720    // 10:00 – 12:00
        inAsian = kzAsian and (mins >= 1200 or mins < 60)    // 20:00 – 1:00
        inNY or inLon or inLC or inAsian

// (f_ext removed in v1.4: the manual price-band zones it served are gone.)

// TF code → readable tag, and a chart-vs-slot comparison (for HTF OB slots)
f_tfName(simple string tf) =>
    tf == "1" ? "1m" : tf == "3" ? "3m" : tf == "5" ? "5m" : tf == "15" ? "15m" :
     tf == "30" ? "30m" : tf == "60" ? "1H" : tf == "120" ? "2H" : tf == "240" ? "4H" :
     (tf == "D" or tf == "1D") ? "D" : (tf == "W" or tf == "1W") ? "W" : (tf == "M" or tf == "1M") ? "M" : tf
f_higher(simple string tf) => timeframe.in_seconds(tf) > timeframe.in_seconds(timeframe.period)
// Left bar_index for an HTF OB whose origin sits k HTF-bars back (ratio-mapped to
// chart bars, clamped to the drawing-reference limit). int(): v6 int/int is float.
f_htfLeft(simple string tf, int k) =>
    int bpH = math.max(1, int(timeframe.in_seconds(tf) / timeframe.in_seconds(timeframe.period)))
    math.max(math.max(0, bar_index - 9500), bar_index - k * bpH)
string chartTag = f_tfName(timeframe.period)   // the chart's own TF tag, for chart-OB labels


// ═══════════════════════════════════════════════════════════════════════
//  ADD / REMOVE OB
// ═══════════════════════════════════════════════════════════════════════

f_add(float tp, float bt, int dir, int leftBI, string tf, color col, int tfi) =>
    // leftBI is a bar_index anchor (chart OBs: bounded look-back; HTF OBs: ratio-
    // mapped + clamped in f_htfLeft), so it never exceeds the ~10k-back draw limit.
    // tf = the TF tag baked into the label ("MM 5m/4H Bull OB"); col = the fill color
    // resolved by the CALLER (chart bull/bear or the HTF slot's bull/bear).
    txt = showLbl ? ("MM " + (tf != "" ? tf + " " : "") + (dir == 1 ? "Bull OB" : "Bear OB")) : ""
    bx  = box.new(leftBI, tp, bar_index + extendR, bt,
         border_color=color.new(col, 100), bgcolor=col, border_width=0,
         text=txt, text_size=size.small, text_color=lblCol,
         text_halign=text.align_right, text_valign=text.align_center)
    mid = (tp + bt) / 2
    // clamp CE right x so it never runs backwards when extendR < cePad
    ln  = showCE ? line.new(leftBI, mid, math.max(leftBI, bar_index + extendR - cePad), mid,
         color=ceCol, style=f_ceLS(), width=1) : line(na)
    array.push(oTop, tp)
    array.push(oBot, bt)
    array.push(oDir, dir)
    array.push(oSt,  0)
    array.push(oBI,  leftBI)
    array.push(oCol, col)
    array.push(oHtf, tf != chartTag)   // HTF OBs (tag != chart's own) are exempt from the Max-OBs cull
    array.push(oBx,  bx)
    array.push(oTfi, tfi)
    array.push(oLn,  ln)
    0

f_del(int i) =>
    box.delete(array.get(oBx, i))
    line.delete(array.get(oLn, i))
    array.remove(oTop, i)
    array.remove(oBot, i)
    array.remove(oDir, i)
    array.remove(oSt,  i)
    array.remove(oBI,  i)
    array.remove(oCol, i)
    array.remove(oHtf, i)
    array.remove(oBx,  i)
    array.remove(oTfi, i)
    array.remove(oLn,  i)
    0


// ═══════════════════════════════════════════════════════════════════════
//  STRUCTURE: swing pivots + Break of Structure (BOS)
// ═══════════════════════════════════════════════════════════════════════
//  Non-repaint: ta.pivothigh/low(pivLen, pivLen) only confirm pivLen bars AFTER
//  the pivot, so a stored swing is always a settled, historical price: it can't
//  repaint. We detect the OB on `barstate.isconfirmed` bars only.
//
//  Each swing is "consumed" (set to na) the moment it's broken, so one swing
//  triggers at most one BOS: no duplicate OBs off the same level.

var float swH = na   // most recent confirmed, unbroken swing high
var float swL = na   // most recent confirmed, unbroken swing low

float ph = ta.pivothigh(pivLen, pivLen)
float pl = ta.pivotlow(pivLen, pivLen)
if not na(ph)
    swH := ph
if not na(pl)
    swL := pl

float atr = ta.atr(OB_ATRLEN)

// Scan back from the current (breakout) bar for the origin candle.
//   wantDown = true  → hunt the DOWN candle (bullish OB origin)
//   wantDown = false → hunt the UP   candle (bearish OB origin)
// Nearest  = first opposing candle back from the break (classic last-OB).
// Extreme  = opposing candle with the deepest wick in the whole leg (the true
//            impulse origin): more robust when an internal pullback candle sits
//            between the OB and the break.
// Guarded, bounded loop. Returns the offset k, or -1 if none within OB_MAXSCAN.
f_findOB(bool wantDown) =>
    int   found = -1
    float ext   = na
    for k = 0 to OB_MAXSCAN
        bool opp = wantDown ? close[k] < open[k] : close[k] > open[k]
        if opp
            if originMode == "Nearest"
                found := k
                break
            else
                // Extreme: keep the deepest low (bull OB) / highest high (bear OB)
                float px = wantDown ? low[k] : high[k]
                if na(ext) or (wantDown ? px < ext : px > ext)
                    ext   := px
                    found := k
    found

// Cluster origin: when the displacement swallows a RUN of consecutive opposing
// candles in one shot, the OB is the FULL range of that run, not just the last
// candle. Walk back from the nearest opposing candle through every CONTIGUOUS
// opposing candle and aggregate the Mauler zone across all of them (a non-opposing
// candle ends the cluster: that candle is part of the displacement leg, not the OB).
//   Bullish: top = highest body high (max open) · bot = lowest wick low
//   Bearish: top = highest wick high           · bot = lowest body low (min open)
// The standing rule in this suite: when a displacement candle takes out multiple opposing
// candles at once, mark the WHOLE cluster as the order block: not only the last one.
// Returns [kNear, kFar, top, bot]; kNear = -1 if no opposing candle within scan.
f_obRun(bool wantDown) =>
    int   kNear = -1
    for k = 0 to OB_MAXSCAN
        if (wantDown ? close[k] < open[k] : close[k] > open[k])
            kNear := k
            break
    int   kFar = kNear
    float top  = na
    float bot  = na
    if kNear >= 0
        top := wantDown ? math.max(open[kNear], close[kNear]) : high[kNear]
        bot := wantDown ? low[kNear]                          : math.min(open[kNear], close[kNear])
        // extend backward through contiguous opposing candles (guarded ascending range)
        bool broke = false
        if kNear < OB_MAXSCAN
            for k = kNear + 1 to OB_MAXSCAN
                if not broke
                    if (wantDown ? close[k] < open[k] : close[k] > open[k])
                        kFar := k
                        top  := wantDown ? math.max(top, math.max(open[k], close[k])) : math.max(top, high[k])
                        bot  := wantDown ? math.min(bot, low[k])                       : math.min(bot, math.min(open[k], close[k]))
                    else
                        broke := true
    [kNear, kFar, top, bot]

// FVG-confluence check: does an imbalance form within fvgDist bars AFTER the OB?
//   Bullish OB → a bullish FVG (BISI): low[j] > high[j+2]
//   Bearish OB → a bearish FVG (SIBI): high[j] < low[j+2]
// The displacement that leaves the gap fires just after the OB, i.e. at offsets
// below obK (more recent). Bounded scan; na-guarded for early bars.
f_hasFvg(int obK, bool wantBull) =>
    bool has = false
    int  lo  = math.max(0, obK - fvgDist)
    for j = lo to obK
        bool fvg = wantBull ? (not na(high[j + 2]) and low[j] > high[j + 2]) : (not na(low[j + 2]) and high[j] < low[j + 2])
        if fvg
            has := true
            break
    has

// ── HTF OB engine: the chart detection, packaged to run INSIDE request.security ──
// Keeps its OWN swing state in the HTF context and returns the newly-formed
// bull/bear OB (edges + origin offset k, in HTF bars) on the BOS bar. Called with
// lookahead_off so it fires on the last chart bar of each confirmed HTF bar (zero
// repaint); the chart side dedups with a rising edge. Killzone/FVG are chart-only:
// HTF keeps the structure + displacement core (reuses f_findOB in the HTF context).
f_obHTF(simple int pL, simple bool useD, simple float dM) =>
    var float sH = na
    var float sL = na
    float pvh = ta.pivothigh(pL, pL)
    float pvl = ta.pivotlow(pL, pL)
    if not na(pvh)
        sH := pvh
    if not na(pvl)
        sL := pvl
    float a  = ta.atr(OB_ATRLEN)
    float bT = na
    float bB = na
    int   bK = 0
    float sT = na
    float sB = na
    int   sK = 0
    bool  gotB = false
    bool  gotS = false
    if barstate.isconfirmed and not na(sH) and close > sH
        int   kbN = -1
        int   kbF = -1
        float tp  = na
        float bt  = na
        if originMode == "Cluster"
            [cn, cf, ct, cb] = f_obRun(true)
            kbN := cn
            kbF := cf
            tp  := ct
            bt  := cb
        else
            kbN := f_findOB(true)
            kbF := kbN
            if kbN >= 0
                tp := math.max(open[kbN], close[kbN])
                bt := low[kbN]
        if kbN >= 0
            float leg = math.abs(close - open[kbN])
            if (not useD or leg >= dM * a) and bt < tp
                bT := tp
                bB := bt
                bK := kbF
                gotB := true
        sH := na
    if barstate.isconfirmed and not na(sL) and close < sL
        int   ksN = -1
        int   ksF = -1
        float tp  = na
        float bt  = na
        if originMode == "Cluster"
            [cn, cf, ct, cb] = f_obRun(false)
            ksN := cn
            ksF := cf
            tp  := ct
            bt  := cb
        else
            ksN := f_findOB(false)
            ksF := ksN
            if ksN >= 0
                tp := high[ksN]
                bt := math.min(open[ksN], close[ksN])
        if ksN >= 0
            float leg = math.abs(close - open[ksN])
            if (not useD or leg >= dM * a) and bt < tp
                sT := tp
                sB := bt
                sK := ksF
                gotS := true
        sL := na
    [gotB, bT, bB, bK, gotS, sT, sB, sK, time, close]

// ── Bullish BOS: confirmed close above the last swing high ──
bool bosUp = barstate.isconfirmed and not na(swH) and close > swH
if bosUp
    // Consume the level whenever it breaks, even if Bullish OBs are hidden:
    // so bosUp fires ONCE (no per-bar alert spam) and the level isn't re-broken.
    if showBull
        // kN = nearest opposing candle (drives displacement/KZ/FVG + label time);
        // kF = far edge of the cluster (box left anchor). Cluster spans the run;
        // Nearest/Extreme collapse to a single candle (kF == kN).
        int   kN = -1
        int   kF = -1
        float tp = na
        float bt = na
        if originMode == "Cluster"
            [cn, cf, ct, cb] = f_obRun(true)
            kN := cn
            kF := cf
            tp := ct
            bt := cb
        else
            kN := f_findOB(true)
            kF := kN
            if kN >= 0
                tp := math.max(open[kN], close[kN])   // body high
                bt := low[kN]                          // wick low
        if kN >= 0
            float leg    = math.abs(close - open[kN])  // OB→break travel, for displacement
            bool  dispOk = not useDisp or leg >= dispMult * atr
            bool  fvgOk  = not useFvg or f_hasFvg(kN, true)
            if dispOk and fvgOk and f_inKZ(time[kN]) and bt < tp
                f_add(tp, bt, 1, bar_index - kF, chartTag, bullCol, 0)
    swH := na

// ── Bearish BOS: confirmed close below the last swing low ──
bool bosDn = barstate.isconfirmed and not na(swL) and close < swL
if bosDn
    if showBear
        int   kN = -1
        int   kF = -1
        float tp = na
        float bt = na
        if originMode == "Cluster"
            [cn, cf, ct, cb] = f_obRun(false)
            kN := cn
            kF := cf
            tp := ct
            bt := cb
        else
            kN := f_findOB(false)
            kF := kN
            if kN >= 0
                tp := high[kN]                         // wick high
                bt := math.min(open[kN], close[kN])    // body low
        if kN >= 0
            float leg    = math.abs(close - open[kN])
            bool  dispOk = not useDisp or leg >= dispMult * atr
            bool  fvgOk  = not useFvg or f_hasFvg(kN, false)
            if dispOk and fvgOk and f_inKZ(time[kN]) and bt < tp
                f_add(tp, bt, -1, bar_index - kF, chartTag, bearCol, 0)
    swL := na


// ═══════════════════════════════════════════════════════════════════════
//  HIGHER-TIMEFRAME OBs: auto-detect on each slot, feed into the shared arrays
// ═══════════════════════════════════════════════════════════════════════
//  f_obHTF runs the OB engine in the HTF context; the chart-side rising edge
//  (gotB and not gotB[1]) adds it ONCE, then it lives through the same lifecycle,
//  cleanup and rendering as a chart OB. Left anchor is ratio-mapped from the HTF
//  origin offset k. Slots ignored unless their TF is above the chart TF.
[h1gB, h1bT, h1bB, h1bK, h1gS, h1sT, h1sB, h1sK, h1T, h1Cl] = request.security(syminfo.tickerid, h1TF, f_obHTF(pivLen, useDisp, dispMult), lookahead=barmerge.lookahead_off)
[h2gB, h2bT, h2bB, h2bK, h2gS, h2sT, h2sB, h2sK, h2T, h2Cl] = request.security(syminfo.tickerid, h2TF, f_obHTF(pivLen, useDisp, dispMult), lookahead=barmerge.lookahead_off)

// v1.8: THE RISING-EDGE DEDUP DROPPED BACK-TO-BACK HTF ZONES.
// `hXgB and not hXgB[1]` fires AT MOST once per HTF zone, and sometimes zero. On
// history a lookahead_off read returns the last CLOSED HTF bar, so the flag holds
// TRUE across every LTF bar of the following HTF bar; two consecutive HTF bars
// producing same-side zones never let it fall, and the second never drew.
// The token is the HTF bar's OWN open time, returned by the engine from inside the
// security context. One fire per HTF bar per direction, guaranteed.
// CONSUMED AT DETECTION and deliberately OUTSIDE the `if useHX` gate: a slot
// toggled off must not bank a fire and release it later. An input change
// recalculates from bar 1 anyway. Shared with the sibling gap tool in this suite.
var int h1LastB = na
var int h1LastS = na
var int h2LastB = na
var int h2LastS = na

bool newH1Bull = h1gB and not na(h1T) and h1T != nz(h1LastB, -1)
bool newH1Bear = h1gS and not na(h1T) and h1T != nz(h1LastS, -1)
bool newH2Bull = h2gB and not na(h2T) and h2T != nz(h2LastB, -1)
bool newH2Bear = h2gS and not na(h2T) and h2T != nz(h2LastS, -1)

if newH1Bull
    h1LastB := h1T
if newH1Bear
    h1LastS := h1T
if newH2Bull
    h2LastB := h2T
if newH2Bear
    h2LastS := h2T

if useH1 and f_higher(h1TF)
    if newH1Bull and showBull
        f_add(h1bT, h1bB, 1, f_htfLeft(h1TF, h1bK), f_tfName(h1TF), h1Bull, 1)
    if newH1Bear and showBear
        f_add(h1sT, h1sB, -1, f_htfLeft(h1TF, h1sK), f_tfName(h1TF), h1Bear, 1)
if useH2 and f_higher(h2TF)
    if newH2Bull and showBull
        f_add(h2bT, h2bB, 1, f_htfLeft(h2TF, h2bK), f_tfName(h2TF), h2Bull, 2)
    if newH2Bear and showBear
        f_add(h2sT, h2sB, -1, f_htfLeft(h2TF, h2sK), f_tfName(h2TF), h2Bear, 2)


// ═══════════════════════════════════════════════════════════════════════
//  MITIGATION / BREAK TRACKING
// ═══════════════════════════════════════════════════════════════════════
//  Runs every bar on every active OB:
//    Bullish OB (support below price):
//      Mitigated = price wick/close taps the top   (mLo <= top)
//      Broken    = candle CLOSES below the bottom   (close < bottom, invalidation)
//    Bearish OB (resistance above price):
//      Mitigated = price wick/close taps the bottom (mHi >= bottom)
//      Broken    = candle CLOSES above the top       (close > top)
//  Mitigation uses the chosen trigger (wick/close); a BREAK is always a close.
//  v1.8: every CLOSE in those two sentences means the close of the timeframe that
//  OWNS the zone, not the chart's. Chart zones are unaffected; HTF zones on an LTF
//  chart now live and die exactly as they do on their own timeframe.

bool didMitig = false
bool didBreak = false

bool useClose = mitigMode == "Close"
// v1.8: fLo/fHi are GONE. They were the chart bar's tap prices applied to every
// zone including HTF ones, which is half of the bug this version fixes. The
// per-zone equivalents (mLo/mHi) are computed inside the loop off the zone's own
// timeframe. Nothing outside that loop ever needed them.

int szM = array.size(oTop)
if szM > 0
    for i = szM - 1 to 0
        int   d = array.get(oDir, i)
        int   s = array.get(oSt,  i)
        float t = array.get(oTop, i)
        float b = array.get(oBot, i)
        if s < 2
            // ═══ v1.8: CLOSE TESTS BELONG TO THE ZONE'S OWN TIMEFRAME ═══
            // A wick is a wick on every timeframe, so mLo/mHi fall back to the chart's
            // high/low in Wick mode. A close does not travel: a 15m close is not a 4H
            // close, and reading the chart's close for an HTF zone is what deleted live
            // HTF zones off LTF charts. na from a cold slot fails safe, since every
            // comparison against na is false and an unknown close never kills a zone.
            int   ti   = array.get(oTfi, i)
            float ownC = ti == 0 ? close : ti == 1 ? h1Cl : h2Cl
            float mLo  = useClose ? ownC : low
            float mHi  = useClose ? ownC : high
            int ns = s
            if d == 1
                if ownC < b                        // broken (invalidation)
                    ns := 2
                else if s == 0 and mLo <= t         // first tap = mitigated
                    ns := 1
            else
                if ownC > t                        // broken
                    ns := 2
                else if s == 0 and mHi >= b         // first tap = mitigated
                    ns := 1
            if ns != s
                array.set(oSt, i, ns)
                box.set_bgcolor(array.get(oBx, i), f_colFade(array.get(oCol, i), ns))
                if ns == 1
                    didMitig := true
                    if not keepMitig
                        f_del(i)
                        continue
                if ns == 2
                    didBreak := true
                    // Freeze the right edge at the break bar; trim the CE line too.
                    box.set_right(array.get(oBx, i), bar_index)
                    if not na(array.get(oLn, i))
                        line.set_x2(array.get(oLn, i), math.max(array.get(oBI, i), bar_index - cePad))
                    if removeBroken
                        f_del(i)
                        continue


// ═══════════════════════════════════════════════════════════════════════
//  CLEANUP: enforce Max OBs on chart + hard cap
// ═══════════════════════════════════════════════════════════════════════
//  Cap A: at most maxShow zones that are NOT broken (oldest culled first).
//  Cap B: hard total cap (drawing-limit safety). Size guards on every loop.

bool _trimA = true
while _trimA
    int _cnt   = 0
    int _first = -1
    int _szA   = array.size(oTop)
    if _szA > 0
        for _j = 0 to _szA - 1
            // Count / cull only CHART OBs: HTF OBs are exempt so LTF crowding
            // never evicts a higher-timeframe level.
            if array.get(oSt, _j) < 2 and not array.get(oHtf, _j)
                _cnt += 1
                if _first == -1
                    _first := _j
    if _cnt > maxShow and _first >= 0
        f_del(_first)
    else
        _trimA := false

if array.size(oTop) > OB_HARDCAP
    f_del(0)   // drop the single oldest; runs once per bar, bounded growth


// ═══════════════════════════════════════════════════════════════════════
//  LIVE UPDATE: extend active OBs to the current bar
// ═══════════════════════════════════════════════════════════════════════

if array.size(oTop) > 0
    for i = 0 to array.size(oTop) - 1
        if array.get(oSt, i) < 2
            box.set_right(array.get(oBx, i), bar_index + extendR)
            if not na(array.get(oLn, i))
                line.set_x2(array.get(oLn, i), math.max(array.get(oBI, i), bar_index + extendR - cePad))


// ═══════════════════════════════════════════════════════════════════════
//  ALERTS  (double-gated: event AND its relevance is implied by detection)
// ═══════════════════════════════════════════════════════════════════════

alertcondition(bosUp and showBull, "New Bullish OB", "Bullish Order Block formed on {{ticker}} {{interval}} — structure broken up, demand zone marked")
alertcondition(bosDn and showBear, "New Bearish OB", "Bearish Order Block formed on {{ticker}} {{interval}} — structure broken down, supply zone marked")
alertcondition(didMitig,           "OB Mitigated",   "Price tapped an Order Block on {{ticker}} {{interval}}")
alertcondition(didBreak,           "OB Broken",      "An Order Block was invalidated (closed through) on {{ticker}} {{interval}}")
````
