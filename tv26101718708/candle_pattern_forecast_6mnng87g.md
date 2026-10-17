# Candle Pattern Forecast

- url: https://www.tradingview.com/script/6MNNg87G-Candle-Pattern-Forecast/
- type: indicator
- pine_id: PUB;bb6ca475867c457a914bd239360cbccf
- version: 2.0

## Description

# Candle Pattern Forecast — Complete Guide

---

## What This Indicator Does

The Candle Pattern Forecast engine looks at the most recent candles on your chart and asks a simple question: **has the market made this same sequence of candles before, and if so, what happened next?**

Every candle tells a story beyond just where price closed. It reveals how decisive the move was (the body), whether buyers or sellers got rejected at the extremes (the wicks), and which side was in control (direction). This indicator reads those four characteristics on each of the last N candles, builds a structural fingerprint of that sequence, then scans back through history looking for every other time the market made a similar sequence.

Once it finds enough matching sequences, it looks at what price actually did in the bars that followed each match. It then plots the median of all those outcomes as a forecast midline, and draws confidence bands showing the range where the bulk of those historical outcomes actually landed.

In plain terms: **the last time the market made candles that looked like this, here is what typically happened next.**

---

## What It Is Not

This is not a crystal ball. It is not predicting the future with certainty. It is showing you a probability-weighted summary of historical behavior following similar candle patterns. The quality of that summary depends entirely on how many good matches exist in history and how consistently those matches behaved afterward. The info box tells you both of those things in real time.

---

## The Display

**Pattern Line** — a purple line tracing the closes of the Candle Lookback window. This shows you exactly which candles the engine read to build its fingerprint, ending at the anchor point where the forecast begins. When Historical Rewind is active, the pattern line shifts back with the rest of the indicator so you always see the sequence that generated the projection.

**Forecast Midline** — the median (or average, if you switch modes) of all the forward price paths observed after matched candle sequences. This is your central tendency line — where the market most commonly ended up after patterns like this.

**Confidence Bands** — the range between the 25th and 75th percentile of historical outcomes by default. The middle 50% of your matched sequences ended up inside these bands. Tight bands mean the matches behaved consistently. Wide bands mean outcomes were scattered and the pattern had no reliable follow-through.

The bands naturally widen as they extend further forward in time. This is correct behavior — the further out you project, the more historical paths diverge from each other.

---

## Inputs — Model Group

**Non-Repaint Mode** — when on, the indicator anchors itself to the last fully closed candle and never changes its projection mid-bar. This is the honest setting for real trading decisions. When off, it updates live on the current bar, which means the projection shifts as price moves.

**Candle Lookback** — how many candles back the engine reads to build its fingerprint. At 5, it reads the last 5 candles and uses their combined anatomy as the pattern it is trying to match in history. Shorter lookbacks find more matches because the fingerprint is simpler. Longer lookbacks find fewer but potentially more specific matches. For short-term intraday work, 3–7 is a practical range. Going much above 10–15 starts to starve the engine of good matches.

**Search Depth** — how far back in history the engine scans looking for matches, measured in bars. At 2000, it looks back 2000 bars. More depth gives more candidates to match against, which is generally better. The limit is how much data your chart actually has.

**Forecast Horizon** — how many bars forward the projection extends after the anchor point. At 10, you get a 10-bar forecast. Keep this in a sensible relationship to your Candle Lookback — projecting 50 bars forward on a 5-candle pattern will produce a technically valid but practically meaningless result as the historical outcomes diverge too much to average meaningfully.

**Pattern Matches** — the target number of historical matches the engine tries to collect. It starts with a very strict similarity requirement and automatically loosens it until it has found this many matches, stopping at the Similarity Floor. More matches produce a smoother, more stable midline but dilute the directional signal. Fewer matches are noisier but more specific. 15–30 is a practical range.

**Similarity Floor** — the absolute minimum similarity score the engine will accept for a match, expressed as a percentage. If it cannot find enough matches above this floor, it takes whatever it found and shows a warning in the info box. This prevents the engine from building a projection on essentially unrelated historical patterns. Raising this makes the engine more selective. Lowering it makes it more permissive.

---

## Inputs — Historical Rewind Group

**Enable Rewind** — when toggled on, the entire indicator shifts backward in time by the number of bars you specify. The fingerprint is read from that past point, the scan searches only history that existed at that time, and the projection extends forward from there — into what is now known history. This lets you visually compare what the indicator would have projected against what price actually did. The pattern line also shifts back to show the candle sequence that was read at that point in time. When off, the indicator runs live as normal.

**Bars Back** — how many bars back to anchor the rewind. At 50, the engine reads the candle sequence from 50 bars ago, finds matches from history prior to that point, and draws the projection forward from there. You can then see how closely the actual subsequent price action followed the forecast. Set to 0 when rewind is enabled but you want to temporarily pause without toggling it off.

The info box Rewind row shows **Live** when rewind is off and **⏪ N bars back** in orange when active, so it is always clear whether you are looking at a live projection or a historical replay.

---

## Inputs — Match Strictness Group

**Match Strictness** — a single dropdown from 1 (Weak) to 5 (Exact) that controls how the engine weighs the four candle anatomy dimensions against each other when measuring similarity.

- **1 — Weak** — all four dimensions (body, upper wick, lower wick, direction) matter equally. The engine is looking for a general structural resemblance. Finds the most matches.
- **2 — Relaxed** — slight emphasis on body conviction. Still broadly permissive.
- **3 — Balanced** — the default. Body size is the dominant signal but wicks and direction still contribute meaningfully.
- **4 — Strict** — strong body emphasis. The engine is primarily matching on how decisive each candle was. Fewer but structurally closer matches.
- **5 — Exact** — body conviction is the overwhelming signal. Only candle sequences with very similar body profiles will qualify. Hardest to match, fewest results.

Think of this as tuning what kind of candle similarity matters most to you. If you care primarily about whether candles were indecisive or committed, lean toward Strict or Exact. If you want a broader match that respects the full candle structure equally, use Weak or Relaxed.

---

## Inputs — Pattern Line Group

**Show Pattern Line** — toggles the pattern line on or off. Default is on.

**Color** — color of the pattern line. Default is purple.

**Width** — thickness of the pattern line. Default is 2.

---

## Inputs — Forecast Group

**Midline Mode** — controls how the central forecast line is calculated from the matched outcomes.

- **Median** (default) — takes the middle value when all outcomes are sorted. More robust to outliers. If one matched sequence had a massive move that was atypical, it gets pushed to the edge rather than pulling the midline toward it.
- **Average** — takes the arithmetic mean of all outcomes. More sensitive to outliers and extreme moves in either direction.

For most use cases Median is the more honest representation of what typically happened.

**Midline Color / Width / Style** — visual styling for the forecast midline.

**Show Confidence Bands** — toggles the upper and lower bands on or off.

**Confidence Band Mode** — controls how the bands are calculated.

- **Percentile** (default) — sorts all historical outcomes at each forecast step and draws the bands at the exact percentile you specify. No assumptions about the shape of the distribution. The bands directly show you where real historical outcomes clustered.
- **Std Deviation** — draws the bands at mean ± N standard deviations. Assumes outcomes are roughly bell-shaped. Can be distorted by outliers inflating the standard deviation even when most matches behaved similarly.

**Lower Percentile / Upper Percentile** — only active in Percentile mode. Default is 25 and 75, meaning the bands show where the middle 50% of historical outcomes landed. Moving to 10/90 widens the bands to capture 80% of outcomes. Moving to 5/95 captures 90%. The right setting depends on whether you want to see the typical range or the full plausible range.

**Band Std Deviation** — only active in Std Deviation mode. At 1.0, the bands cover approximately 68% of outcomes. At 2.0, approximately 95%.

**Upper / Lower Band Color, Width, Style** — visual styling for the confidence bands.

---

## Inputs — Info Box Group

The info box displays the engine's live diagnostic state so you always know what is actually running.

**Show Info Box** — toggles the info box on or off.

**Position** — where on the chart the info box appears.

**Text Size** — size of the info box text.

**Background / Border / Header colors** — visual styling.

---

## Reading the Info Box

**Candle Lookback** — confirms how many candles the fingerprint is built from.

**Forecast Horizon** — confirms how many bars forward the projection extends.

**Matches Used** — how many historical sequences qualified. If this is orange, no matches were found — the engine has nothing to project from. Try lowering the Similarity Floor, reducing the Candle Lookback, or increasing the Search Depth.

**Sim Floor / Fit** — two numbers. The left is the similarity threshold the engine actually settled on to reach your target match count. The right is the average similarity score of all the matches it found. Higher is better. A warning symbol next to the left number means the engine hit the Similarity Floor and could not find enough matches above it.

**Match Quality** — a composite score from Low to High that combines the average similarity of your matches, how close you got to your target match count, and whether the floor was hit. High means the engine found well-matched patterns. Low means the projection is built on weaker material and should be treated with more skepticism.

**Search Depth** — confirms the search depth setting currently active.

**Strictness** — confirms which Match Strictness level is active.

**Midline** — confirms whether you are running Median or Average.

**Bands** — confirms the active band mode and parameters. Shows either "Pctl 25/75" style or "StdDev ×1.0" style depending on your selection.

**Rewind** — shows Live when the indicator is running on the current bar, or ⏪ N bars back in orange when Historical Rewind is active.

---

## Practical Usage Tips

The forecast midline being relatively flat is not a failure — it often means the candle pattern genuinely did not predict a strong directional move historically. In that case the bands are the more useful signal, showing you the range of outcomes rather than pretending to know direction.

Tight bands with a flat midline means the pattern historically resolved with small moves in both directions — a low-conviction setup. Wide bands means the pattern was followed by large moves but in inconsistent directions. A midline with meaningful slope and tight bands is the highest-quality signal the engine can produce.

Treat Match Quality as your confidence filter. When it reads Low or Weak, reduce the weight you place on the projection. When it reads High, the engine found genuinely similar historical sequences and the projection has more structural basis behind it.

Use Historical Rewind to build intuition for the indicator before trusting it live. Step back 50 or 100 bars, observe how the projection compared to what actually happened, experiment with different Candle Lookback and Match Strictness settings, and develop a feel for when the indicator tends to be more or less reliable on your instrument and timeframe. The pattern line makes this especially useful — you can see exactly which candle sequence triggered the projection and compare it visually to where price went next.

## Source Code

````pine
//@version=6
indicator("Candle Pattern Forecast", shorttitle="Candle Forecast", overlay=true, max_lines_count=500, max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════
// CANDLE PATTERN FORECAST ENGINE
// Reads the last N candles as an anatomy fingerprint (body ratio,
// upper wick, lower wick, direction) and finds the most similar
// historical sequences. Projects forward based on what price did
// after those matches, drawn as a median midline + confidence bands.
// Includes Historical Rewind to anchor the projection to any past
// point in time and compare the forecast against known history.
// Bull Prob / Bear Prob = % of matched sequences where price closed
// above / below the anchor close at the terminal horizon bar.
// Lock to Candle: pins the anchor to a specific UTC time each session.
// ═══════════════════════════════════════════════════════════════

// ─── MODEL ──────────────────────────────────────────────────────

grpMain        = "Model"
nonRepaint     = input.bool(true,  "Non-Repaint Mode",    group=grpMain, tooltip="Anchors the calculation to the previous confirmed bar so the projection never repaints on the current live candle.")
candleLookback = input.int(5,     "Candle Lookback",     group=grpMain, minval=2, maxval=200, tooltip="How many candles back the engine reads to build the anatomy fingerprint. Each candle encodes its body ratio, upper wick, lower wick, and direction — and their relationship to one another across the sequence.")
searchBars     = input.int(2000,  "Search Depth",        group=grpMain, minval=500, maxval=4000, tooltip="How far back in history to search for matching candle sequences.")
horizon        = input.int(10,    "Forecast Horizon",    group=grpMain, minval=1, maxval=200, tooltip="How many bars forward to project after a match is found.")
patternMatches = input.int(20,    "Pattern Matches",     group=grpMain, minval=5, maxval=200, tooltip="Target number of historical matches to build the projection from. The engine auto-finds the similarity threshold that yields this many matches, loosening from 100% down to the Similarity Floor.")
simFloor       = input.int(60,    "Similarity Floor %",  group=grpMain, minval=10, maxval=95, tooltip="Lowest similarity % the auto-search will accept. Prevents projections from being built on structurally unrelated candle sequences.")

// ─── LOCK TO CANDLE ──────────────────────────────────────────────

grpLock         = "Lock to Candle"
lockCandle      = input.bool(false, "Lock to Candle",        group=grpLock, tooltip="When enabled, anchors the projection to the candle that prints at the UTC time specified below each session, instead of the live or rewind bar.")
daysBack        = input.int(0,     "Days Back",              group=grpLock, minval=0, maxval=30,  tooltip="Number of sessions to look back from the most recent matching candle. 0 = most recent. 1 = one session further back.")
lockHour        = input.int(13,    "Hour (UTC)",             group=grpLock, minval=0, maxval=23,  tooltip="The hour of the candle you want to anchor to, in 24-hour UTC time.")
lockMinute      = input.int(30,    "Minute (UTC)",           group=grpLock, minval=0, maxval=59,  tooltip="The minute of the candle you want to anchor to in UTC.")
autoPrevSession = input.bool(true,  "Auto Previous Session", group=grpLock, tooltip="When ON: if today's target candle has not yet printed, the lock automatically falls back to the most recent previous session match.")

// ─── HISTORICAL REWIND ───────────────────────────────────────────

grpRewind   = "Historical Rewind"
useRewind   = input.bool(false, "Enable Rewind",  group=grpRewind, tooltip="When enabled, and Lock to Candle is OFF, shifts the entire indicator backward by the number of bars below.")
rewindBars  = input.int(0,     "Bars Back",       group=grpRewind, minval=0, maxval=2000, tooltip="How many bars back to anchor the projection. 0 has no effect. Increase to step back in time.")

grpWeights      = "Match Strictness"
matchStrictness = input.string("3 — Balanced", "Match Strictness", group=grpWeights,
     options=["1 — Weak", "2 — Relaxed", "3 — Balanced", "4 — Strict", "5 — Exact"],
     tooltip="Controls how strictly the engine matches candle shape.\n\n1 — Weak: all four candle dimensions weighted equally. Finds the most matches.\n2 — Relaxed: slight emphasis on body conviction.\n3 — Balanced: body-dominant but wicks and direction still matter.\n4 — Strict: strong body emphasis, fewer but closer matches.\n5 — Exact: body conviction is the primary signal. Hardest to match.")

// ─── FORECAST ────────────────────────────────────────────────────

grpForecast  = "Forecast"
midlineMode  = input.string("Median",  "Midline Mode",          group=grpForecast, options=["Median", "Average"], tooltip="Median: the middle outcome of all matches — more robust to outliers.\nAverage: the mean of all outcomes — pulled by extreme moves.")
midColor     = input.color(color.aqua,                "Midline Color",         group=grpForecast)
midWidth     = input.int(2,                           "Midline Width",         group=grpForecast, minval=1, maxval=5)
midTypeIn    = input.string("Solid",                  "Midline Style",         group=grpForecast, options=["Solid", "Dashed", "Dotted"])
showBands    = input.bool(true,                       "Show Confidence Bands", group=grpForecast)
bandMode     = input.string("Percentile", "Confidence Band Mode", group=grpForecast, options=["Percentile", "Std Deviation"], tooltip="Percentile: bands show where the actual historical outcomes clustered — no distribution assumptions.\nStd Deviation: bands are mean ± N std devs, assumes roughly normal distribution.")
lowerPct     = input.float(10.0, "Lower Percentile", group=grpForecast, minval=1.0,  maxval=49.0, step=1.0, tooltip="Bottom percentile of historical outcomes for the lower band. Default 10 = 10th percentile.")
upperPct     = input.float(90.0, "Upper Percentile", group=grpForecast, minval=51.0, maxval=99.0, step=1.0, tooltip="Top percentile of historical outcomes for the upper band. Default 90 = 90th percentile.")
bandMult     = input.float(1.0,  "Band Std Deviation", group=grpForecast, minval=0.5, maxval=5.0, step=0.5, tooltip="Number of standard deviations to plot. 1.0 = ~68% of outcomes. 2.0 = ~95%. Only active when Confidence Band Mode is Std Deviation.")
upperColor   = input.color(color.new(color.lime, 20), "Upper Band Color",      group=grpForecast)
lowerColor   = input.color(color.new(color.red,  20), "Lower Band Color",      group=grpForecast)
bandWidth    = input.int(1,                           "Band Width",            group=grpForecast, minval=1, maxval=5)
bandTypeIn   = input.string("Dashed",                 "Band Style",            group=grpForecast, options=["Solid", "Dashed", "Dotted"])

// ─── PATTERN LINE ────────────────────────────────────────────────

grpPattern   = "Pattern Line"
showPattern  = input.bool(true,           "Show Pattern Line",  group=grpPattern, tooltip="Draws a line along the closes of the Candle Lookback window, showing the exact sequence the engine used to find matches.")
patternColor = input.color(color.purple,  "Color",              group=grpPattern)
patternWidth = input.int(2,               "Width",              group=grpPattern, minval=1, maxval=5)

grpInfo           = "Info Box"
showInfoBox       = input.bool(true,                        "Show Info Box", group=grpInfo)
infoBoxPosition   = input.string("Bottom Right",            "Position",      group=grpInfo, options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"])
infoTextSizeIn    = input.string("Tiny",                    "Text Size",     group=grpInfo, options=["Tiny", "Small", "Normal", "Large"])
infoBgColor       = input.color(color.new(color.black, 10), "Background",    group=grpInfo)
infoBorderColor   = input.color(color.new(color.gray,  20), "Border",        group=grpInfo)
infoHeaderColor   = input.color(color.white,                "Header Text",   group=grpInfo)
infoHeaderBgColor = input.color(color.new(color.blue,  20), "Header BG",     group=grpInfo)

// ─── UTILITY ─────────────────────────────────────────────────────

f_line_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_table_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.bottom_right

f_text_size(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        =>         size.normal

f_clear_lines(line[] arr) =>
    int n = array.size(arr)
    if n > 0
        for i = 0 to n - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

f_array_mean(array<float> arr) =>
    int n = array.size(arr)
    if n == 0
        na
    else
        float s = 0.0
        for i = 0 to n - 1
            s += array.get(arr, i)
        s / n

f_weighted_mean(array<float> vals, array<float> weights) =>
    int n = array.size(vals)
    if n == 0 or array.size(weights) != n
        na
    else
        float ws = 0.0
        float wt = 0.0
        for i = 0 to n - 1
            ws += array.get(vals, i) * array.get(weights, i)
            wt += array.get(weights, i)
        wt == 0.0 ? na : ws / wt

f_weighted_std(array<float> vals, array<float> weights, float meanVal) =>
    int n = array.size(vals)
    if n <= 1 or na(meanVal) or array.size(weights) != n
        0.0
    else
        float wsq = 0.0
        float wt  = 0.0
        for i = 0 to n - 1
            float d = array.get(vals, i) - meanVal
            wsq += array.get(weights, i) * d * d
            wt  += array.get(weights, i)
        wt == 0.0 ? 0.0 : math.sqrt(wsq / wt)

f_array_median(array<float> arr) =>
    int n = array.size(arr)
    if n == 0
        na
    else
        sorted = array.copy(arr)
        array.sort(sorted)
        int mid = int(math.floor(n / 2))
        n % 2 == 1 ? array.get(sorted, mid) : (array.get(sorted, mid - 1) + array.get(sorted, mid)) / 2.0

f_array_percentile(array<float> arr, float pct) =>
    int n = array.size(arr)
    if n == 0
        na
    else
        sorted = array.copy(arr)
        array.sort(sorted)
        float idx = pct / 100.0 * (n - 1)
        int   lo  = int(math.floor(idx))
        int   hi  = math.min(lo + 1, n - 1)
        float frac = idx - lo
        array.get(sorted, lo) * (1.0 - frac) + array.get(sorted, hi) * frac

// ─── CANDLE ANATOMY ──────────────────────────────────────────────

f_candle_anatomy(int off) =>
    float o   = open[off]
    float h   = high[off]
    float l   = low[off]
    float c   = close[off]
    float rng = h - l
    float bodyRatio = rng > 0.0 ? math.abs(c - o) / rng : 0.0
    float upperWick = rng > 0.0 ? (h - math.max(o, c)) / rng : 0.0
    float lowerWick = rng > 0.0 ? (math.min(o, c) - l) / rng : 0.0
    float dir       = c >= o ? 1.0 : 0.0
    [bodyRatio, upperWick, lowerWick, dir]

f_build_vector(int startOff, int len) =>
    vec = array.new<float>()
    for j = 0 to len - 1
        [b, u, lo, d] = f_candle_anatomy(startOff + j)
        array.push(vec, b)
        array.push(vec, u)
        array.push(vec, lo)
        array.push(vec, d)
    vec

f_anatomy_distance(array<float> a, array<float> b) =>
    float wBody      = matchStrictness == "1 — Weak" ? 0.25 : matchStrictness == "2 — Relaxed" ? 0.35 : matchStrictness == "3 — Balanced" ? 0.40 : matchStrictness == "4 — Strict" ? 0.50 : 0.60
    float wUpperWick = matchStrictness == "1 — Weak" ? 0.25 : matchStrictness == "2 — Relaxed" ? 0.20 : matchStrictness == "3 — Balanced" ? 0.20 : matchStrictness == "4 — Strict" ? 0.20 : 0.18
    float wLowerWick = matchStrictness == "1 — Weak" ? 0.25 : matchStrictness == "2 — Relaxed" ? 0.20 : matchStrictness == "3 — Balanced" ? 0.20 : matchStrictness == "4 — Strict" ? 0.15 : 0.12
    float wDirection = matchStrictness == "1 — Weak" ? 0.25 : matchStrictness == "2 — Relaxed" ? 0.25 : matchStrictness == "3 — Balanced" ? 0.20 : matchStrictness == "4 — Strict" ? 0.15 : 0.10
    int   n          = array.size(a)
    float dist       = 0.0
    float totalW     = wBody + wUpperWick + wLowerWick + wDirection
    float safe       = totalW == 0.0 ? 1.0 : totalW
    for i = 0 to n - 1
        int   dim = i % 4
        float w   = dim == 0 ? wBody : dim == 1 ? wUpperWick : dim == 2 ? wLowerWick : wDirection
        dist += (w / safe) * math.abs(array.get(a, i) - array.get(b, i))
    dist

f_similarity_pct(float dist, float minDist, float maxDist) =>
    float denom = maxDist - minDist
    denom <= 0.0 ? 100.0 : math.max(0.0, math.min(100.0, 100.0 * (1.0 - (dist - minDist) / denom)))

f_forward_factor(int off, int steps, int anchorTotal) =>
    float factor = 1.0
    for s = 1 to steps
        int   idx  = off - s + anchorTotal
        float prev = close[idx + 1]
        float curr = close[idx]
        if not na(prev) and prev != 0.0
            factor *= curr / prev
    factor

// ─── LOCK TO CANDLE STATE ────────────────────────────────────────
// Tracks every bar that matches the target UTC hour:minute so we
// can look back N sessions via daysBack.

var int[] matchedBars       = array.new<int>()
var int[] matchedTimestamps = array.new<int>()
var int   targetBarIndex    = na

if lockCandle
    if hour(time, "UTC") == lockHour and minute(time, "UTC") == lockMinute
        array.push(matchedBars,       bar_index)
        array.push(matchedTimestamps, time)
else
    array.clear(matchedBars)
    array.clear(matchedTimestamps)
    targetBarIndex := na

// ─── ANCHOR RESOLUTION ───────────────────────────────────────────
// Priority: Lock to Candle → Historical Rewind → Live

anchor = nonRepaint ? 1 : 0

int    anchorOffset = 0
string lockStatus   = ""

if lockCandle
    int totalMatches = array.size(matchedBars)
    int pickIndex    = totalMatches - 1 - daysBack
    if pickIndex >= 0
        int candidateBar  = array.get(matchedBars,       pickIndex)
        int candidateTime = array.get(matchedTimestamps, pickIndex)

        bool isToday = year(candidateTime,  "UTC") == year(timenow,  "UTC") and
                       month(candidateTime, "UTC") == month(timenow, "UTC") and
                       dayofmonth(candidateTime, "UTC") == dayofmonth(timenow, "UTC")

        if not autoPrevSession and not isToday and daysBack == 0
            targetBarIndex := na
            anchorOffset   := useRewind ? rewindBars : 0
            lockStatus     := "No Anchor Lock"
        else
            targetBarIndex := candidateBar
            anchorOffset   := bar_index - targetBarIndex
            lockStatus     := "Locked"
    else
        targetBarIndex := na
        anchorOffset   := useRewind ? rewindBars : 0
        lockStatus     := "No Anchor Lock"
else
    anchorOffset := useRewind ? rewindBars : 0
    lockStatus   := ""

int anchorTotal = anchor + anchorOffset

// ─── STATE ───────────────────────────────────────────────────────

var line[] midLines     = array.new<line>()
var line[] upperLines   = array.new<line>()
var line[] lowerLines   = array.new<line>()
var line[] patternLines = array.new<line>()

enoughBars = bar_index > (candleLookback + horizon + patternMatches + anchorTotal + 20)

// ─── MAIN ────────────────────────────────────────────────────────

if barstate.islast and enoughBars
    f_clear_lines(midLines)
    f_clear_lines(upperLines)
    f_clear_lines(lowerLines)
    f_clear_lines(patternLines)

    var table  infoTbl      = na
    var string _lastInfoPos = ""
    if showInfoBox and (infoBoxPosition != _lastInfoPos or na(infoTbl))
        if not na(infoTbl)
            table.delete(infoTbl)
        infoTbl      := table.new(f_table_pos(infoBoxPosition), 2, 14, border_width=1)
        _lastInfoPos := infoBoxPosition

    // Build reference fingerprint from current candles
    ref = f_build_vector(anchorTotal, candleLookback)

    int maxOffset = math.min(searchBars, bar_index - horizon - candleLookback - anchorTotal - 2)

    // Scan all historical candidates
    allMetric = array.new<float>()
    allOff    = array.new<int>()

    float minMetric = 1e10
    float maxMetric = -1.0

    for off = horizon to maxOffset
        cand   = f_build_vector(off + anchorTotal, candleLookback)
        metric = f_anatomy_distance(ref, cand)
        array.push(allMetric, metric)
        array.push(allOff,    off)
        minMetric := math.min(minMetric, metric)
        maxMetric := math.max(maxMetric, metric)

    // Convert distances to similarity scores
    candSimArr = array.new<float>()
    candOffArr = array.new<int>()

    int totalCandidates = array.size(allMetric)
    if totalCandidates > 0
        for i = 0 to totalCandidates - 1
            float sim = f_similarity_pct(array.get(allMetric, i), minMetric, maxMetric)
            array.push(candSimArr, sim)
            array.push(candOffArr, array.get(allOff, i))

    int filterPassCount = array.size(candSimArr)

    // Auto-threshold: find the tightest similarity floor that yields enough matches
    int  effectiveSimInt = simFloor
    bool floorHit        = false

    for testSim = 100 to simFloor
        int cnt = 0
        if filterPassCount > 0
            for i = 0 to filterPassCount - 1
                if array.get(candSimArr, i) >= testSim
                    cnt += 1
        if cnt >= patternMatches
            effectiveSimInt := testSim
            break
        if testSim == simFloor
            floorHit := true

    float effectiveSim = float(effectiveSimInt)

    selectedOff = array.new<int>()
    selectedSim = array.new<float>()
    selectedWgt = array.new<float>()

    if filterPassCount > 0
        for i = 0 to filterPassCount - 1
            float sim = array.get(candSimArr, i)
            if sim >= effectiveSim
                array.push(selectedOff, array.get(candOffArr, i))
                array.push(selectedSim, sim)

    int selectedCount = array.size(selectedOff)

    // Equal weight — every match contributes equally
    if selectedCount > 0
        for k = 0 to selectedCount - 1
            array.push(selectedWgt, 1.0)

    // Build projection step by step
    float avgSimScore = selectedCount > 0 ? f_array_mean(selectedSim) : na
    float base        = close[anchorTotal]

    avgPrices = array.new<float>()
    upPrices  = array.new<float>()
    dnPrices  = array.new<float>()

    var float terminalBullProb = na
    var float terminalBearProb = na

    for step = 1 to horizon
        factors = array.new<float>()
        weights = array.new<float>()

        if selectedCount > 0
            for k = 0 to selectedCount - 1
                array.push(factors, f_forward_factor(array.get(selectedOff, k), step, anchorTotal))
                array.push(weights, array.get(selectedWgt, k))

        float m  = f_weighted_mean(factors, weights)
        float sd = f_weighted_std(factors, weights, m)

        float midFactor = midlineMode == "Median" ? f_array_median(factors) : m

        float upFactor = na
        float dnFactor = na
        if bandMode == "Percentile"
            upFactor := f_array_percentile(factors, upperPct)
            dnFactor := f_array_percentile(factors, lowerPct)
        else
            upFactor := na(m) ? na : m + sd * bandMult
            dnFactor := na(m) ? na : m - sd * bandMult

        array.push(avgPrices, na(midFactor) ? na : base * midFactor)
        array.push(upPrices,  na(upFactor)  ? na : base * upFactor)
        array.push(dnPrices,  na(dnFactor)  ? na : base * dnFactor)

        // Capture at terminal step only
        if step == horizon and selectedCount > 0
            int bullCnt = 0
            int bearCnt = 0
            int fSize   = array.size(factors)
            if fSize > 0
                for fi = 0 to fSize - 1
                    float f = array.get(factors, fi)
                    if f > 1.0
                        bullCnt += 1
                    else
                        bearCnt += 1
            terminalBullProb := 100.0 * bullCnt / selectedCount
            terminalBearProb := 100.0 * bearCnt / selectedCount

    // Draw forecast lines
    midSt  = f_line_style(midTypeIn)
    bandSt = f_line_style(bandTypeIn)

    int linesPerStep = 1 + (showBands ? 2 : 0)
    int drawSteps    = math.min(horizon, int(math.floor(490 / linesPerStep)))

    if selectedCount > 0 and drawSteps > 0
        for i = 0 to drawSteps - 1
            int   x1      = bar_index - anchorTotal + i
            int   x2      = x1 + 1
            float prevMid = i == 0 ? base : array.get(avgPrices, i - 1)
            float prevUp  = i == 0 ? base : array.get(upPrices,  i - 1)
            float prevDn  = i == 0 ? base : array.get(dnPrices,  i - 1)
            float thisMid = array.get(avgPrices, i)
            float thisUp  = array.get(upPrices,  i)
            float thisDn  = array.get(dnPrices,  i)

            if not na(prevMid) and not na(thisMid)
                array.push(midLines, line.new(x1, prevMid, x2, thisMid, color=midColor, width=midWidth, style=midSt))
            if showBands
                if not na(prevUp) and not na(thisUp)
                    array.push(upperLines, line.new(x1, prevUp, x2, thisUp, color=upperColor, width=bandWidth, style=bandSt))
                if not na(prevDn) and not na(thisDn)
                    array.push(lowerLines, line.new(x1, prevDn, x2, thisDn, color=lowerColor, width=bandWidth, style=bandSt))

    // Draw pattern line along closes of the lookback window
    if showPattern and candleLookback > 1
        for j = 0 to candleLookback - 2
            int   x1 = bar_index - anchorTotal - candleLookback + 1 + j
            int   x2 = x1 + 1
            float y1 = close[anchorTotal + candleLookback - 1 - j]
            float y2 = close[anchorTotal + candleLookback - 2 - j]
            if not na(y1) and not na(y2)
                array.push(patternLines, line.new(x1, y1, x2, y2, color=patternColor, width=patternWidth, style=line.style_solid))

    // ─── INFO BOX ────────────────────────────────────────────────
    if showInfoBox and not na(infoTbl)
        float countScore      = selectedCount == 0 ? 0.0 : math.min(100.0, 100.0 * selectedCount / math.max(1, patternMatches))
        float floorScore      = floorHit ? 50.0 : 100.0
        float projReliability = selectedCount == 0 ? 0.0 : (na(avgSimScore) ? 0.0 : avgSimScore) * 0.50 + countScore * 0.35 + floorScore * 0.15
        string relLabel = selectedCount == 0 ? "No Data" : projReliability >= 80.0 ? "High  ▲" : projReliability >= 60.0 ? "Moderate ●" : projReliability >= 40.0 ? "Weak  ▼" : "Low  ✕"
        color  relColor = selectedCount == 0 ? color.gray : projReliability >= 80.0 ? color.lime : projReliability >= 60.0 ? color.yellow : projReliability >= 40.0 ? color.orange : color.red
        color  simColor = effectiveSim >= 75.0 ? color.lime : effectiveSim >= 60.0 ? color.yellow : color.red

        // row 0 — header
        table.cell(infoTbl, 0, 0, "CANDLE FORECAST",   text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.merge_cells(infoTbl, 0, 0, 1, 0)
        // row 1 — column headers
        table.cell(infoTbl, 0, 1, "Metric",            text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 1, "Value",             text_color=infoHeaderColor, bgcolor=infoHeaderBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 2 — Candle Lookback
        table.cell(infoTbl, 0, 2, "Candle Lookback",   text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 2, str.tostring(candleLookback) + " candles", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 3 — Forecast Horizon
        table.cell(infoTbl, 0, 3, "Forecast Horizon",  text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 3, str.tostring(horizon) + " bars", text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 4 — Matches Used
        table.cell(infoTbl, 0, 4, "Matches Used",      text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 4, str.tostring(selectedCount), text_color=selectedCount > 0 ? color.white : color.orange, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 5 — Sim Floor / Avg Fit
        table.cell(infoTbl, 0, 5, "Sim Floor / Fit",   text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 5, str.tostring(effectiveSim, "#.0") + "%" + (floorHit ? " ⚠" : "") + " / " + (na(avgSimScore) ? "n/a" : str.tostring(avgSimScore, "#.0") + "%"), text_color=simColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 6 — Match Quality
        table.cell(infoTbl, 0, 6, "Match Quality",     text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 6, relLabel + " (" + str.tostring(projReliability, "#") + ")", text_color=relColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 7 — Search Depth
        table.cell(infoTbl, 0, 7, "Search Depth",      text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 7, str.tostring(searchBars), text_color=color.gray, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 8 — Match Strictness
        table.cell(infoTbl, 0, 8, "Strictness",        text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 8, matchStrictness,     text_color=color.gray,  bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 9 — Midline Mode
        table.cell(infoTbl, 0, 9,  "Midline",          text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 9,  midlineMode,        text_color=color.gray,  bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 10 — Band Mode
        string bandModeLabel = bandMode == "Percentile" ? "Pctl " + str.tostring(lowerPct, "#") + "/" + str.tostring(upperPct, "#") : "StdDev ×" + str.tostring(bandMult, "#.0")
        table.cell(infoTbl, 0, 10, "Bands",            text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 10, bandModeLabel,      text_color=color.gray,  bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 11 — Anchor / Lookback (replaces old Rewind row)
        string anchorLabel = ""
        string anchorValue = ""
        color  anchorColor = color.gray
        if lockCandle
            if lockStatus == "Locked"
                int   lockedTime = array.get(matchedTimestamps, array.size(matchedTimestamps) - 1 - daysBack)
                string lockedStr = str.format("{0,date,MM/dd/yyyy}  {1,time,HH:mm}", lockedTime, lockedTime)
                anchorLabel := "Anchor"
                anchorValue := lockedStr
                anchorColor := color.lime
            else
                anchorLabel := "Anchor"
                anchorValue := "No Anchor Lock"
                anchorColor := color.orange
        else
            anchorLabel := useRewind ? "Rewind" : "Mode"
            anchorValue := useRewind ? "⏪ " + str.tostring(rewindBars) + " bars back" : "Live"
            anchorColor := useRewind ? color.orange : color.gray
        table.cell(infoTbl, 0, 11, anchorLabel,        text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 11, anchorValue,        text_color=anchorColor, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 12 — Bull Prob
        string bullLabel = na(terminalBullProb) or selectedCount < 10 ? "n/a" : str.tostring(terminalBullProb, "#.0") + "%"
        color  bullColor = na(terminalBullProb) or selectedCount < 10 ? color.gray : terminalBullProb >= 60.0 ? color.lime : terminalBullProb >= 50.0 ? color.yellow : color.gray
        table.cell(infoTbl, 0, 12, "Bull Prob",        text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 12, bullLabel,          text_color=bullColor,   bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        // row 13 — Bear Prob
        string bearLabel = na(terminalBearProb) or selectedCount < 10 ? "n/a" : str.tostring(terminalBearProb, "#.0") + "%"
        color  bearColor = na(terminalBearProb) or selectedCount < 10 ? color.gray : terminalBearProb >= 60.0 ? color.red : terminalBearProb >= 50.0 ? color.orange : color.gray
        table.cell(infoTbl, 0, 13, "Bear Prob",        text_color=color.white, bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))
        table.cell(infoTbl, 1, 13, bearLabel,          text_color=bearColor,   bgcolor=infoBgColor, text_size=f_text_size(infoTextSizeIn))

        table.set_border_color(infoTbl, infoBorderColor)
        table.set_frame_color(infoTbl, infoBorderColor)
        table.set_frame_width(infoTbl, 1)

// ─── ALERTS ─────────────────────────────────────────────────────
alertcondition(barstate.islast, "Candle Forecast Updated", "Candle Pattern Forecast has recalculated.")
````
