# Pymander's EZ Key Levels

- url: https://www.tradingview.com/script/1etVlBw6-Pymander-s-EZ-Key-Levels/
- type: indicator
- pine_id: PUB;26e115fd029645e69aa656aa8ebc0f7b
- version: 1.0

## Description

Hey everyone! Pymander here. I’m excited to share EZ Key Levels, a tool I built to solve one of the biggest problems we face as intraday traders: chart clutter.

We all know that "levels are king," but when your screen is a spiderweb of Daily, Weekly, and Session lines, it’s easy to get lost in the noise. This indicator is designed to give you total clarity so you can focus on execution.

What is EZ Key Levels?
At its core, this is a hybrid indicator. It combines High Timeframe (HTF) logic with Machine Learning (K-Means Clustering) to map out the most important psychological and volume-based zones on your chart.

How It Works & Why It’s Different:
Solid Until Mitigated: This is the real game-changer. Every level starts as a solid line (meaning it's fresh and untested). The moment price "mitigates" it—either by a wick touch or a candle close—the line automatically turns dotted. You’ll never have to guess if a level is still "fresh" again.
Volume-Weighted Clustering: Instead of just looking at where price sat, our dynamic clusters use VWAP logic to find where the most volume actually traded. It identifies the true "Value Areas" of the last few days.
Premium Proximity & Focus Mode: Most indicators show you everything at once. EZ Key Levels identifies the 4 levels closest to price and highlights them in Rose (Above) and Emerald (Below). Turn on Focus Mode, and every other line disappears, leaving you with a clean, "pro-style" chart that only shows what matters right now.
All-In-One Session Logic: It automatically tracks Asia, London, and NY session highs/lows and projects them infinitely so you can see how those ranges act as support or resistance days later.
How This Helps You:
This tool is built for the 3-5 minute trader who needs to make split-second decisions. By identifying high-confluence zones (where a V-Cluster lines up with a PDH or Session Low) and highlighting them automatically, it removes the "analysis paralysis" that kills so many trades.

I’d love to hear your thoughts! If you have any feedback or ideas on how to make this even better for your workflow, please let me know.

Wishing you all the best of luck and many, many green days!

-Pymander

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pymander

//@version=6
indicator("Pymander's EZ Key Levels", "EZ Key Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Constants & Styling ---
color C_GREEN = #089981
color C_RED   = #f23645
color C_BLUE  = #5b9cf6
color C_GOLD  = #ff9800
color C_CYAN  = #00bcd4
color C_VIO   = #9c27b0
color C_WHITE = #ffffff
color C_NONE  = #00000000

// --- Groups ---
string G_DYNAMIC = "Dynamic Volume-Weighted Clustering"
string G_MIT     = "Mitigation Settings"
string G_HTF     = "High Timeframe Levels"
string G_PIVOTS  = "Pivot Points"
string G_SESS    = "Session Levels"
string G_PROX    = "Premium Proximity Highlighting"
string G_STYLE   = "Global Aesthetics"

// --- Inputs: Dynamic Clustering (Optimized for 3-5m) ---
int   lookback  = input.int(300, "Intraday Lookback Period", minval = 10, group = G_DYNAMIC, tooltip = "Optimized for 3-5m charts to capture ~2 trading days of micro-structure.")
int   kInput    = input.int(7, "Number of Micro-Clusters", minval = 2, maxval = 10, group = G_DYNAMIC, tooltip = "Higher cluster count helps identify precise intraday pivot zones.")
int   iters     = input.int(50, "Clustering Iterations", minval = 5, maxval = 50, group = G_DYNAMIC)
color dynColor  = input.color(color.new(C_BLUE, 50), "Dynamic Level Base Color", group = G_STYLE)

// --- Inputs: Mitigation ---
string mitType = input.string("Wick", "Mitigation Type", options = ["Wick", "Close"], group = G_MIT)
int    mitLook = input.int(50, "Mitigation Search Depth", minval = 1, group = G_MIT, tooltip = "Checking more bars for mitigation ensures the 'dotted' lines accurately reflect tested structure.")

// --- Inputs: HTF & Session Extension ---
bool  extendHTF  = input.bool(true, "Extend HTF Levels Infinitely", group = G_HTF)
bool  extendSess = input.bool(true, "Extend Session Levels Infinitely", group = G_SESS)

// --- Inputs: HTF Levels ---
bool  showDaily   = input.bool(true, "Previous Daily H/L", inline = "d", group = G_HTF)
color dailyColor  = input.color(C_GREEN, "", inline = "d", group = G_HTF)
bool  showWeekly  = input.bool(true, "Previous Weekly H/L", inline = "w", group = G_HTF)
color weeklyColor = input.color(C_RED, "", inline = "w", group = G_HTF)
bool  showMonthly = input.bool(true, "Previous Monthly H/L", inline = "m", group = G_HTF)
color monthlyColor= input.color(C_GOLD, "", inline = "m", group = G_HTF)
bool  showYearly  = input.bool(false, "Previous Yearly H/L", inline = "y", group = G_HTF)
color yearlyColor = input.color(C_WHITE, "", inline = "y", group = G_HTF)

// --- Inputs: Session Levels ---
bool   showAsia   = input.bool(true, "Asia Open/Close Range", inline = "s1", group = G_SESS)
string asiaSpec   = input.session("1900-0400", "", inline = "s1", group = G_SESS)
color  asiaColor  = input.color(C_CYAN, "", inline = "s1", group = G_SESS)

bool   showLondon = input.bool(true, "London Session High/Low", inline = "s2", group = G_SESS)
string lonSpec    = input.session("0300-1100", "", inline = "s2", group = G_SESS)
color  lonColor   = input.color(C_GREEN, "", inline = "s2", group = G_SESS)

bool   showNY     = input.bool(true, "NY Session High/Low", inline = "s3", group = G_SESS)
string nySpec     = input.session("0800-1700", "", inline = "s3", group = G_SESS)
color  nyColor    = input.color(C_GOLD, "", inline = "s3", group = G_SESS)

// --- Inputs: Pivot Points ---
bool   showPivots = input.bool(false, "Traditional Pivots", inline = "p1", group = G_PIVOTS)
string pivMethod  = input.string("Floor", "Method", options = ["Floor", "Woodie", "Camarilla", "Fibonacci"], inline = "p1", group = G_PIVOTS)
color  pivColor   = input.color(C_VIO, "Pivot Aesthetics", group = G_STYLE)

// --- Inputs: Proximity & Focus Mode (Pure Premium) ---
bool  showFocusMode     = input.bool(false, "Enable Focus Mode", group = G_PROX, tooltip = "Hides all levels except for the currently highlighted proximity levels.")
bool  showProxHighlight = input.bool(true, "Enable Proximity Focus", group = G_PROX)
int   proxCount         = input.int(4, "Focus Level Count", minval = 1, maxval = 10, group = G_PROX)
color proxColorAbove    = input.color(C_RED, "Closest Above Price", inline = "pc", group = G_PROX)
color proxColorBelow    = input.color(C_GREEN, "Closest Below Price", inline = "pc", group = G_PROX)

// --- UDTs ---
type LevelInfo
    float price
    string name
    color clr
    int lb
    bool isPivot
    bool isDynamic
    bool isSess
    bool isHTF

// --- Globals ---
var line[] dynamicLines = array.new_line()
var line[] keyLines     = array.new_line()
var label[] keyLabels   = array.new_label()

// --- Functions ---
f_kmeans_vw(int n, int k, int iterations) =>
    float[] prices = array.new_float(0), float[] volumes = array.new_float(0)
    float minP = 1e10, maxP = -1e10
    for i = 0 to n - 1
        float p = hl2[i], float v = nz(volume[i])
        prices.push(p), volumes.push(v), minP := math.min(minP, p), maxP := math.max(maxP, p)
    float[] centroids = array.new_float(k)
    float step = (maxP - minP) / (k + 1)
    for i = 0 to k - 1
        centroids.set(i, minP + (i + 1) * step)
    for iter = 1 to iterations
        int[] assignments = array.new_int(n)
        for i = 0 to n - 1
            float p = prices.get(i)
            int best_k = 0, float min_dist = 1e10
            for j = 0 to k - 1
                float dist = math.abs(p - centroids.get(j))
                if dist < min_dist
                    min_dist := dist, best_k := j
            assignments.set(i, best_k)
        float[] sum_pv = array.new_float(k, 0.0), float[] sum_v = array.new_float(k, 0.0)
        for i = 0 to n - 1
            int cluster = assignments.get(i)
            sum_pv.set(cluster, sum_pv.get(cluster) + prices.get(i) * volumes.get(i)), sum_v.set(cluster, sum_v.get(cluster) + volumes.get(i))
        for j = 0 to k - 1
            if sum_v.get(j) > 0
                centroids.set(j, sum_pv.get(j) / sum_v.get(j))
    centroids

f_isMitigated(float level, int n, string mitMode) =>
    bool mitigated = false
    if not na(level)
        for i = 0 to n - 1
            bool touch = mitMode == "Wick" ? (high[i] >= level and low[i] <= level) : (math.max(open[i], close[i]) >= level and math.min(open[i], close[i]) <= level)
            if touch
                mitigated := true
                break
    mitigated

f_draw(LevelInfo info, bool isClosest) =>
    if not na(info.price)
        bool mitigated = f_isMitigated(info.price, info.isPivot ? 1 : mitLook, mitType)
        string style = mitigated ? line.style_dotted : line.style_solid
        
        // Premium Proximity Coloring (Alternating)
        color highlightClr = info.price > close ? proxColorAbove : proxColorBelow
        color useColor     = isClosest and showProxHighlight ? highlightClr : info.clr
        int width          = isClosest ? 3 : (info.isPivot ? 1 : 1)
        string prefix      = isClosest ? "✦ " : ""
        
        line ln = line.new(bar_index - info.lb, info.price, bar_index + 12, info.price, color = useColor, style = style, width = width)
        
        if info.isDynamic or (info.isHTF and extendHTF) or (info.isSess and extendSess)
            line.set_extend(ln, extend.right)
            
        if info.isDynamic
            dynamicLines.push(ln)
        else
            keyLines.push(ln)
            
        // Move labels below the line using label.style_label_upper_left
        keyLabels.push(label.new(bar_index + 12, info.price, prefix + info.name, color = C_NONE, textcolor = useColor, style = label.style_label_upper_left, size = size.small))

// --- Data Gathering ---
[pdh, pdl, pdc] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl]      = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml]      = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pyh, pyl]      = request.security(syminfo.tickerid, "12M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

f_getSessionHL(string spec) =>
    inSess = not na(time(timeframe.period, spec))
    var float h = na, var float l = na
    if inSess
        h := not inSess[1] ? high : math.max(h, high)
        l := not inSess[1] ? low : math.min(l, low)
    [h, l]

[ash, asl] = f_getSessionHL(asiaSpec)
[lnh, lnl] = f_getSessionHL(lonSpec)
[nyh, nyl] = f_getSessionHL(nySpec)

// --- Logic: Pivots ---
float pRange = pdh - pdl
float pp = 0.0, float r1 = na, float s1 = na, float r2 = na, float s2 = na, float r3 = na, float s3 = na, float r4 = na, float s4 = na
if showPivots
    switch pivMethod
        "Floor" =>
            pp := (pdh + pdl + pdc) / 3
            r1 := 2 * pp - pdl, s1 := 2 * pp - pdh
            r2 := pp + pRange, s2 := pp - pRange
        "Woodie" =>
            pp := (pdh + pdl + 2 * pdc) / 4
            r1 := 2 * pp - pdl, s1 := 2 * pp - pdh
            r2 := pp + pRange, s2 := pp - pRange
        "Camarilla" =>
            pp := pdc
            r1 := pdc + pRange * 1.1 / 12, s1 := pdc - pRange * 1.1 / 12
            r2 := pdc + pRange * 1.1 / 6,  s2 := pdc - pRange * 1.1 / 6
            r3 := pdc + pRange * 1.1 / 4,  s3 := pdc - pRange * 1.1 / 4
            r4 := pdc + pRange * 1.1 / 2,  s4 := pdc - pRange * 1.1 / 2
        "Fibonacci" =>
            pp := (pdh + pdl + pdc) / 3
            r1 := pp + pRange * 0.382, s1 := pp - pRange * 0.382
            r2 := pp + pRange * 0.618, s2 := pp - pRange * 0.618
            r3 := pp + pRange * 1.000, s3 := pp - pRange * 1.000

// --- Rendering Loop ---
if barstate.islast
    for l in dynamicLines
        l.delete()
    for l in keyLines
        l.delete()
    for l in keyLabels
        l.delete()
    dynamicLines.clear(), keyLines.clear(), keyLabels.clear()

    LevelInfo[] allLevels = array.new<LevelInfo>(0)
    
    // Collect Levels
    float[] centroids = f_kmeans_vw(lookback, kInput, iters)
    for c in centroids
        allLevels.push(LevelInfo.new(c, "V-Cluster", dynColor, lookback, false, true, false, false))

    if showDaily
        allLevels.push(LevelInfo.new(pdh, "PDH", dailyColor, 50, false, false, false, true))
        allLevels.push(LevelInfo.new(pdl, "PDL", dailyColor, 50, false, false, false, true))
    if showWeekly
        allLevels.push(LevelInfo.new(pwh, "PWH", weeklyColor, 50, false, false, false, true))
        allLevels.push(LevelInfo.new(pwl, "PWL", weeklyColor, 50, false, false, false, true))
    if showMonthly
        allLevels.push(LevelInfo.new(pmh, "PMH", monthlyColor, 50, false, false, false, true))
        allLevels.push(LevelInfo.new(pml, "PML", monthlyColor, 50, false, false, false, true))
    if showYearly
        allLevels.push(LevelInfo.new(pyh, "PYH", yearlyColor, 50, false, false, false, true))
        allLevels.push(LevelInfo.new(pyl, "PYL", yearlyColor, 50, false, false, false, true))

    if showAsia and not na(ash)
        allLevels.push(LevelInfo.new(ash, "Asia High", asiaColor, 30, false, false, true, false))
        allLevels.push(LevelInfo.new(asl, "Asia Low", asiaColor, 30, false, false, true, false))
    if showLondon and not na(lnh)
        allLevels.push(LevelInfo.new(lnh, "London High", lonColor, 30, false, false, true, false))
        allLevels.push(LevelInfo.new(lnl, "London Low", lonColor, 30, false, false, true, false))
    if showNY and not na(nyh)
        allLevels.push(LevelInfo.new(nyh, "NY High", nyColor, 30, false, false, true, false))
        allLevels.push(LevelInfo.new(nyl, "NY Low", nyColor, 30, false, false, true, false))

    if showPivots
        allLevels.push(LevelInfo.new(pp, "Pivot Point", pivColor, 40, true, false, false, false))
        if not na(r1)
            allLevels.push(LevelInfo.new(r1, "R1", pivColor, 40, true, false, false, false))
            allLevels.push(LevelInfo.new(s1, "S1", pivColor, 40, true, false, false, false))

    // Rank all levels by absolute distance from current close
    float[] distances = array.new_float(0)
    for level in allLevels
        distances.push(math.abs(level.price - close))
    distances.sort()
    
    // Determine the distance threshold for the N-th closest level
    float threshold = distances.size() > 0 ? distances.get(math.min(proxCount - 1, distances.size() - 1)) : 1e10

    // Final Draw with Focus Mode logic
    for level in allLevels
        isClosest = math.abs(level.price - close) <= threshold
        if not showFocusMode or isClosest
            f_draw(level, isClosest)
````
