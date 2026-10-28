# Multi-TF Overlapping FVG

- url: https://www.tradingview.com/script/phbiF7nM-Multi-TF-Overlapping-FVG/
- type: indicator
- pine_id: PUB;31c30fcab458416bb7ac6bde74e317e9
- version: 1.0

## Description

This indicator automatically detects Fair Value Gaps (FVGs) across multiple timeframes and identifies high‑confluence overlap zones known as clusters. These clusters highlight areas of institutional imbalance where price often reacts with precision. The tool continuously tracks FVGs from 1m, 5m, 10m, 15m, 30m, and 60m charts, dynamically forming and updating clusters as new gaps appear or become mitigated.

Key Features
Multi‑Timeframe FVG Detection  
Scans up to six timeframes for bullish and bearish FVGs in real time.

Cluster Formation Logic  
Builds a cluster when a 1‑minute FVG aligns with enough higher‑timeframe gaps, creating a strong confluence zone.

Dynamic Filtering System  
Allows filtering clusters by time decay, price proximity, ATR‑based distance, or edge‑proximity wake‑up logic.

Mitigation Tracking  
Monitors each FVG for partial or full mitigation using wick or close logic. Clusters update or expire automatically.

Exclusivity and Consumption Options  
Controls whether higher‑timeframe FVGs can be reused by multiple 1m seeds or permanently consumed.

Adaptive Rendering  
Boxes extend dynamically, labels update automatically, and clusters remain visible briefly after mitigation for clarity.

Debug Panel  
Displays real‑time counts of FVGs per timeframe and active clusters for verification and troubleshooting.

How to Use This Indicator
Identify High‑Probability Zones  
Clusters represent areas where multiple timeframes agree on imbalance, often acting as strong support, resistance, or liquidity targets.

Monitor Mitigation Behavior  
Observe how price interacts with cluster edges. Partial fills, full fills, and rejections can signal continuation or reversal.

Integrate With Your Strategy  
Use clusters as entry zones, take‑profit targets, stop‑loss buffers, or directional confirmation.

Adjust Filters to Match Your Style  
Scalpers may prefer tighter ATR filters and shorter time windows, while swing traders may widen the range to capture larger structures.

Who This Indicator Is For
Traders seeking automated multi‑timeframe FVG detection

Those who want high‑confluence imbalance zones without manual charting

Traders using institutional concepts such as imbalance, mitigation, and liquidity

Anyone wanting a clean, dynamic, and customizable FVG clustering tool

## Source Code

````pine
// Created by SphinxTrading © 2026
//@version=6
indicator("Multi-TF Overlapping FVG", "MTF iFVG Overlap", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

// ============================================================
// INPUTS
// ============================================================
grpGen = "General"
useWick = input.string("Wick", "Mitigation Type", options = ["Wick","Close"], group = grpGen,
     tooltip = "Wick uses high/low; Close uses close.") == "Wick"
mitPer  = input.int(50, "Mitigation %", minval = 1, maxval = 100, step = 10, group = grpGen,
     tooltip = "How much of an individual FVG must be filled to mark it mitigated.")
extBars = input.int(20, "Extend Right (bars)", minval = 0, group = grpGen)

grpCluster = "Cluster Filter"
minOverlap   = input.int(2, "Min FVGs to Form Cluster", minval = 2, maxval = 6, group = grpCluster,
     tooltip = "How many timeframes must align before a cluster is drawn. Once formed, cluster persists until only 1 active FVG remains.")
maxClusters  = input.int(50, "Max Clusters in Memory", minval = 10, maxval = 200, group = grpCluster)
maxPoolSize  = input.int(60, "Max FVGs in Pool", minval = 20, maxval = 300, group = grpCluster,
     tooltip = "Pool holds FVGs eligible to join NEW clusters. Cluster members are tracked separately.")
exclusiveHTF = input.bool(true, "First-Born Owns HTF (exclusive)", group = grpCluster,
     tooltip = "ON: the earliest 1m seed to use an HTF gap claims it; later 1m seeds cannot reuse that same HTF (original behavior). OFF: HTFs are shared across all overlapping 1m seeds.")
permanentConsume = input.bool(false, "Permanently Consume HTF", group = grpCluster,
     tooltip = "Only applies when exclusivity is ON. ON: once an HTF is used it is consumed for the rest of the session, even after its cluster dies. OFF: the HTF frees up again when its owning cluster is removed.")

grpFilter = "Dynamic Display Filter"
filterMode = input.string("Time + Price", "Filter Mode",
     options = ["None","Time only","Price only","Time + Price"], group = grpFilter,
     tooltip = "Controls which clusters render. Hidden clusters stay in memory and reappear when price approaches their edge.")
lookbackHours    = input.float(5.0, "Time Window (hours)", minval = 0.5, step = 0.5, group = grpFilter,
     tooltip = "Show clusters whose most recent member formed within this many hours.")
priceRangeATR    = input.float(5.0, "Price Range (ATR multiple)", minval = 0.5, step = 0.5, group = grpFilter,
     tooltip = "Show clusters within this many ATRs of current price.")
edgeProximityATR = input.float(1.5, "Edge Wake-up Distance (ATR)", minval = 0.0, step = 0.25, group = grpFilter,
     tooltip = "When price comes within this ATR distance of a hidden cluster's edge, force-show it. Set to 0 to disable.")
atrLen           = input.int(200, "ATR Length", minval = 14, group = grpFilter)

grpTF = "Watched Timeframes"
useTF01 = input.bool(true, "Watch 1 min",  group = grpTF)
useTF05 = input.bool(true, "Watch 5 min",  group = grpTF)
useTF10 = input.bool(true, "Watch 10 min", group = grpTF)
useTF15 = input.bool(true, "Watch 15 min", group = grpTF)
useTF30 = input.bool(true, "Watch 30 min", group = grpTF)
useTF60 = input.bool(true, "Watch 60 min", group = grpTF)

grpStyle = "Style"
bullClr        = input.color(#26a69a, "Bullish Color", group = grpStyle)
bearClr        = input.color(#ef5350, "Bearish Color", group = grpStyle)
fillAlpha      = input.int(80, "Box Fill Transparency", minval = 0, maxval = 100, group = grpStyle)
borderStyleStr = input.string("Solid", "Border Style", options = ["Solid","Dotted","Dashed"], group = grpStyle)
showLabel      = input.bool(true, "Show Cluster Label", group = grpStyle)
labelSizeStr   = input.string("Small", "Label Size", options = ["Tiny","Small","Normal","Large"], group = grpStyle)

styleVar = borderStyleStr == "Solid"  ? line.style_solid  :
           borderStyleStr == "Dotted" ? line.style_dotted : line.style_dashed
sizeVar  = labelSizeStr == "Tiny"   ? size.tiny   :
           labelSizeStr == "Small"  ? size.small  :
           labelSizeStr == "Normal" ? size.normal : size.large

useTime  = filterMode == "Time only"  or filterMode == "Time + Price"
usePrice = filterMode == "Price only" or filterMode == "Time + Price"

// ============================================================
// TYPES
// ============================================================
type FVG
    string tf
    bool   bull
    float  top
    float  btm
    int    leftTime
    bool   mitigated = false
    bool   consumed  = false

type Cluster
    array<FVG> members
    float top
    float btm
    bool  bull
    int   leftTime
    int   lastUpdateTime
    box   bx  = na
    label lbl = na
    int   graceBars = -1   // -1 = alive; >=0 = bars remaining before deletion

// ============================================================
// HTF FVG DETECTOR
// ============================================================
detect_fvg() =>
    bull = low  > high[2] and close[1] > high[2]
    bear = high < low[2]  and close[1] < low[2]
    float ftop = na
    float fbtm = na
    int   fleft = na
    bool  fbull = false
    if bull
        ftop  := low
        fbtm  := high[2]
        fleft := time[2]
        fbull := true
    if bear
        ftop  := low[2]
        fbtm  := high
        fleft := time[2]
        fbull := false
    [bull or bear, fbull, ftop, fbtm, fleft]

[n01, b01, t01, m01, l01] = request.security(syminfo.tickerid, "1",  detect_fvg(), lookahead = barmerge.lookahead_off)
[n05, b05, t05, m05, l05] = request.security(syminfo.tickerid, "5",  detect_fvg(), lookahead = barmerge.lookahead_off)
[n10, b10, t10, m10, l10] = request.security(syminfo.tickerid, "10", detect_fvg(), lookahead = barmerge.lookahead_off)
[n15, b15, t15, m15, l15] = request.security(syminfo.tickerid, "15", detect_fvg(), lookahead = barmerge.lookahead_off)
[n30, b30, t30, m30, l30] = request.security(syminfo.tickerid, "30", detect_fvg(), lookahead = barmerge.lookahead_off)
[n60, b60, t60, m60, l60] = request.security(syminfo.tickerid, "60", detect_fvg(), lookahead = barmerge.lookahead_off)

// ============================================================
// STATE
// ============================================================
var array<FVG>     pool     = array.new<FVG>()
var array<Cluster> clusters = array.new<Cluster>()
var int last01 = 0
var int last05 = 0
var int last10 = 0
var int last15 = 0
var int last30 = 0
var int last60 = 0

atr = ta.atr(atrLen)

// ============================================================
// HELPERS
// ============================================================
overlap(float aTop, float aBtm, float bTop, float bBtm) =>
    aTop >= bBtm and bTop >= aBtm

count_active(Cluster c) =>
    int cnt = 0
    for i = 0 to c.members.size() - 1
        if not c.members.get(i).mitigated
            cnt += 1
    cnt

recompute_range(Cluster c) =>
    float t = na
    float b = na
    int   l = na
    int   newest = na
    for i = 0 to c.members.size() - 1
        m = c.members.get(i)
        if not m.mitigated
            t      := na(t) ? m.top      : math.min(t, m.top)
            b      := na(b) ? m.btm      : math.max(b, m.btm)
            l      := na(l) ? m.leftTime : math.min(l, m.leftTime)
            newest := na(newest) ? m.leftTime : math.max(newest, m.leftTime)
    [t, b, l, newest]

fvg_in_cluster(FVG f) =>
    bool inCl = false
    if clusters.size() > 0
        for ci = 0 to clusters.size() - 1
            if inCl
                break
            cl = clusters.get(ci)
            for mi = 0 to cl.members.size() - 1
                m = cl.members.get(mi)
                if m.tf == f.tf and m.leftTime == f.leftTime and m.bull == f.bull
                    inCl := true
                    break
    inCl

active_tf_text(Cluster c) =>
    string s = ""
    for i = 0 to c.members.size() - 1
        m = c.members.get(i)
        if not m.mitigated
            s := s == "" ? m.tf + "m" : s + "+" + m.tf + "m"
    s

bar_ms() => timeframe.in_seconds(timeframe.period) * 1000

// ============================================================
// FILTER LOGIC
// ============================================================
should_render(Cluster c, float curPrice, float curAtr, int now_ms) =>
    bool timeOK  = true
    bool priceOK = true

    if useTime and lookbackHours > 0
        ageMs = now_ms - c.lastUpdateTime
        timeOK := ageMs <= lookbackHours * 3600000

    if usePrice and not na(curAtr) and curAtr > 0
        rng = priceRangeATR * curAtr
        priceOK := overlap(c.top, c.btm, curPrice + rng, curPrice - rng)

    baseShow = (filterMode == "None") or (timeOK and priceOK)

    bool nearEdge = false
    if not baseShow and edgeProximityATR > 0 and not na(curAtr) and curAtr > 0
        float dist = 0.0
        if curPrice > c.top
            dist := curPrice - c.top
        else if curPrice < c.btm
            dist := c.btm - curPrice
        nearEdge := dist <= edgeProximityATR * curAtr

    baseShow or nearEdge

// ============================================================
// RENDER / UNRENDER
// ============================================================
render_cluster(Cluster c) =>
    clr = c.bull ? bullClr : bearClr
    bgC = color.new(clr, fillAlpha)
    rt  = time + extBars * bar_ms()
    c.bx := box.new(c.leftTime, c.top, rt, c.btm,
        border_color = clr, bgcolor = bgC,
        border_style = styleVar, xloc = xloc.bar_time)
    if showLabel
        c.lbl := label.new(rt, (c.top + c.btm) / 2,
            text = active_tf_text(c),
            xloc = xloc.bar_time, style = label.style_label_left,
            color = color.new(color.gray, 100), textcolor = clr, size = sizeVar)

unrender_cluster(Cluster c) =>
    if not na(c.bx)
        box.delete(c.bx)
        c.bx := na
    if not na(c.lbl)
        label.delete(c.lbl)
        c.lbl := na

// ============================================================
// CORE: add FVG, attempt to attach to or form cluster
// ============================================================
// Add any FVG (any TF) into the pool so it is available for 1m seeds to find.
// Returns the newly created FVG (or na if it was a duplicate).
add_to_pool(string tf, bool bull, float top, float btm, int leftTime) =>
    FVG result = na
    if not na(top) and not na(btm) and not na(leftTime)
        bool dup = false
        if pool.size() > 0
            for i = 0 to pool.size() - 1
                f = pool.get(i)
                if f.tf == tf and f.leftTime == leftTime and f.bull == bull
                    dup := true
                    break
        if not dup
            newF = FVG.new(tf, bull, top, btm, leftTime)
            pool.unshift(newF)
            while pool.size() > maxPoolSize
                pool.pop()
            result := newF
    result

// Determine whether a 1m seed has already produced a cluster.
seed_already_clustered(FVG seed) =>
    bool found = false
    if clusters.size() > 0
        for ci = 0 to clusters.size() - 1
            if found
                break
            cl = clusters.get(ci)
            // member[0] is always the 1m seed for clusters built this way
            s = cl.members.get(0)
            if s.tf == "1" and s.leftTime == seed.leftTime and s.bull == seed.bull
                found := true
    found

// BOTTOM-UP BUILD: when a 1m FVG confirms, scan the pool for overlapping
// higher-timeframe FVGs (one best per TF) and, if enough align, plot.
// Exclusivity (user toggle):
//   exclusiveHTF ON  -> an HTF already in a live cluster is skipped, so the
//                       first-born 1m seed owns it (original behavior).
//   exclusiveHTF OFF -> HTFs are shared across all overlapping 1m seeds.
// permanentConsume (only when exclusive) keeps an HTF claimed even after
// its owning cluster dies.
build_from_seed(FVG seed) =>
    if not seed_already_clustered(seed)
        array<FVG> members = array.new<FVG>()
        members.push(seed)
        float curTop    = seed.top
        float curBtm    = seed.btm
        int   curLeft   = seed.leftTime
        int   curNewest = seed.leftTime

        // For each HTF, pick the single best (most recent) overlapping gap.
        // Iterate HTFs explicitly so we keep at most one per timeframe.
        if pool.size() > 0
            for i = 0 to pool.size() - 1
                o = pool.get(i)
                if o.tf != "1" and o.bull == seed.bull and not o.mitigated
                   and overlap(seed.top, seed.btm, o.top, o.btm)
                    // exclusivity gate
                    bool claimed = false
                    if exclusiveHTF
                        if permanentConsume and o.consumed
                            claimed := true
                        else if fvg_in_cluster(o)
                            claimed := true
                    if not claimed
                        // skip if this TF already represented in members
                        bool tfExists = false
                        for mi = 0 to members.size() - 1
                            if members.get(mi).tf == o.tf
                                tfExists := true
                                break
                        if not tfExists
                            members.push(o)
                            curTop    := math.min(curTop, o.top)
                            curBtm    := math.max(curBtm, o.btm)
                            curLeft   := math.min(curLeft, o.leftTime)
                            curNewest := math.max(curNewest, o.leftTime)

        // 1m seed counts as 1; need minOverlap total timeframes aligned.
        if members.size() >= minOverlap
            nc = Cluster.new(members, curTop, curBtm, seed.bull, curLeft, curNewest, na, na, -1)
            clusters.unshift(nc)
            // mark HTF members consumed if permanent consumption is on
            if exclusiveHTF and permanentConsume
                for mi = 0 to members.size() - 1
                    mm = members.get(mi)
                    if mm.tf != "1"
                        mm.consumed := true
            while clusters.size() > maxClusters
                old = clusters.pop()
                unrender_cluster(old)

// ============================================================
// INGEST NEW FVGs FROM EACH WATCHED TF
// HTFs (5/10/15/30/60) are pooled FIRST so they are available when the
// 1m seed scans. The 1m FVG is the anchor: when it confirms, it pools
// itself and then triggers a bottom-up cluster build.
// ============================================================
if useTF05 and n05 and not na(l05) and l05 != last05
    add_to_pool("5",  b05, t05, m05, l05)
    last05 := l05
if useTF10 and n10 and not na(l10) and l10 != last10
    add_to_pool("10", b10, t10, m10, l10)
    last10 := l10
if useTF15 and n15 and not na(l15) and l15 != last15
    add_to_pool("15", b15, t15, m15, l15)
    last15 := l15
if useTF30 and n30 and not na(l30) and l30 != last30
    add_to_pool("30", b30, t30, m30, l30)
    last30 := l30
if useTF60 and n60 and not na(l60) and l60 != last60
    add_to_pool("60", b60, t60, m60, l60)
    last60 := l60

// 1m anchor LAST: just pool it. Cluster building is handled by the
// per-bar seed sweep below, so a 1m seed will be picked up as soon as
// its confluence HTFs exist in the pool (not only on the bar it forms).
if useTF01 and n01 and not na(l01) and l01 != last01
    add_to_pool("1", b01, t01, m01, l01)
    last01 := l01

// ============================================================
// BUILD SWEEP — every bar, try to build a cluster from each active,
// not-yet-clustered 1m seed in the pool. This lets a 1m FVG form a
// cluster the moment enough HTFs overlap it, regardless of arrival order.
// Sweep OLDEST-first (pool is newest-at-0) so that under exclusivity the
// genuine first-born 1m seed claims a shared HTF before later seeds.
// ============================================================
if pool.size() > 0
    for i = pool.size() - 1 to 0
        s = pool.get(i)
        if s.tf == "1" and not s.mitigated
            build_from_seed(s)

// ============================================================
// MITIGATION — iterate ALL FVGs across clusters and pool
// ============================================================
bullMit = useWick ? low  : close
bearMit = useWick ? high : close

check_mitigation(FVG f) =>
    if not f.mitigated
        rng = f.top - f.btm
        lvl = f.bull ? f.top - rng * mitPer / 100 : f.btm + rng * mitPer / 100
        mit = f.bull ? bullMit < lvl : bearMit > lvl
        if mit
            f.mitigated := true

if clusters.size() > 0
    for ci = 0 to clusters.size() - 1
        cl = clusters.get(ci)
        for mi = 0 to cl.members.size() - 1
            check_mitigation(cl.members.get(mi))

if pool.size() > 0
    for i = 0 to pool.size() - 1
        check_mitigation(pool.get(i))

// ============================================================
// CLUSTER MAINTENANCE + FILTER-DRIVEN RENDER
// ============================================================
if clusters.size() > 0
    int i = clusters.size() - 1
    while i >= 0
        cl = clusters.get(i)
        active = count_active(cl)
        if active < 2
            // Grace period: keep the cluster visible for 1 extra bar after
            // it drops below 2 active FVGs, so the mitigation is visible.
            if cl.graceBars < 0
                cl.graceBars := 1          // arm the countdown this bar
            else
                cl.graceBars -= 1          // tick down on each subsequent bar

            if cl.graceBars < 0
                // grace expired -> delete now
                unrender_cluster(cl)
                clusters.remove(i)
            else
                // still in grace -> keep drawn, freeze its range
                wantShow = should_render(cl, close, atr, time)
                hasBox   = not na(cl.bx)
                if wantShow and not hasBox
                    render_cluster(cl)
                else if not wantShow and hasBox
                    unrender_cluster(cl)
                else if wantShow and hasBox
                    rt = time + extBars * bar_ms()
                    box.set_right(cl.bx, rt)
                    if not na(cl.lbl)
                        label.set_x(cl.lbl, rt)
        else
            cl.graceBars := -1             // re-arm: cluster is healthy again
            [nt, nb, nl, newest] = recompute_range(cl)
            if not na(nt) and not na(nb)
                cl.top := nt
                cl.btm := nb
                cl.leftTime := nl
                if not na(newest)
                    cl.lastUpdateTime := math.max(cl.lastUpdateTime, newest)

            wantShow = should_render(cl, close, atr, time)
            hasBox   = not na(cl.bx)

            if wantShow and not hasBox
                render_cluster(cl)
            else if not wantShow and hasBox
                unrender_cluster(cl)
            else if wantShow and hasBox
                rt = time + extBars * bar_ms()
                box.set_top(cl.bx, cl.top)
                box.set_bottom(cl.bx, cl.btm)
                box.set_left(cl.bx, cl.leftTime)
                box.set_right(cl.bx, rt)
                if not na(cl.lbl)
                    label.set_x(cl.lbl, rt)
                    label.set_y(cl.lbl, (cl.top + cl.btm) / 2)
                    label.set_text(cl.lbl, active_tf_text(cl))
        i -= 1

// ============================================================
// DEBUG PANEL (toggle off once confirmed working)
// Shows how many FVGs are pooled per TF and how many clusters exist.
// If pool counts stay 0, the HTF FVG detection isn't returning data on
// this chart's timeframe. If pool>0 but clusters=0, overlap/minOverlap
// is the constraint.
// ============================================================
showDebug = input.bool(true, "Show Debug Panel", group = "General")

if barstate.islast and showDebug
    int c1 = 0, c5 = 0, c15 = 0, c30 = 0, c60 = 0, c10 = 0
    if pool.size() > 0
        for i = 0 to pool.size() - 1
            f = pool.get(i)
            if not f.mitigated
                if f.tf == "1"
                    c1  += 1
                else if f.tf == "5"
                    c5  += 1
                else if f.tf == "10"
                    c10 += 1
                else if f.tf == "15"
                    c15 += 1
                else if f.tf == "30"
                    c30 += 1
                else if f.tf == "60"
                    c60 += 1
    var table dbg = table.new(position.top_right, 2, 8, border_width = 1)
    table.cell(dbg, 0, 0, "Pool by TF", bgcolor = color.new(color.gray, 70), text_color = color.white)
    table.cell(dbg, 1, 0, "", bgcolor = color.new(color.gray, 70))
    table.cell(dbg, 0, 1, "1m",  text_color = color.white), table.cell(dbg, 1, 1, str.tostring(c1),  text_color = color.white)
    table.cell(dbg, 0, 2, "5m",  text_color = color.white), table.cell(dbg, 1, 2, str.tostring(c5),  text_color = color.white)
    table.cell(dbg, 0, 3, "10m", text_color = color.white), table.cell(dbg, 1, 3, str.tostring(c10), text_color = color.white)
    table.cell(dbg, 0, 4, "15m", text_color = color.white), table.cell(dbg, 1, 4, str.tostring(c15), text_color = color.white)
    table.cell(dbg, 0, 5, "30m", text_color = color.white), table.cell(dbg, 1, 5, str.tostring(c30), text_color = color.white)
    table.cell(dbg, 0, 6, "60m", text_color = color.white), table.cell(dbg, 1, 6, str.tostring(c60), text_color = color.white)
    table.cell(dbg, 0, 7, "Clusters", bgcolor = color.new(color.blue, 50), text_color = color.white)
    table.cell(dbg, 1, 7, str.tostring(clusters.size()), bgcolor = color.new(color.blue, 50), text_color = color.white)
````
