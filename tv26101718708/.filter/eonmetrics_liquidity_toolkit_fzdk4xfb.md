# EonMetrics Liquidity Toolkit

- url: https://www.tradingview.com/script/Fzdk4xFb-EonMetrics-Liquidity-Toolkit/
- type: indicator
- pine_id: PUB;5663066981094cf6bcc0ab25bad93629
- version: 1.0

## Description

Liquidity Toolkit by EonMetrics

[b]WHAT IT DOES[/b]

Whenever price makes a swing high or a swing low, a cluster of pending stop orders tends to sit just beyond it — buy-stop orders resting just above a swing high, and sell-stop orders resting just below a swing low. This is what traders call "liquidity." Large market participants often push price briefly through one of these levels to trigger those resting orders (grabbing the liquidity) before reversing back the other way — which is why these levels frequently mark turning points, not just breakout points.

This indicator finds and tracks these levels automatically:
- Buyside Liquidity (BSL) — the resting buy-stop cluster above a swing high, drawn as a line until price reaches it.
- Sellside Liquidity (SSL) — the resting sell-stop cluster below a swing low, drawn the same way.
- Equal Highs / Equal Lows (EQH / EQL) — when two or more swing highs (or lows) line up at almost the same price, that's a bigger, more obvious pool of resting orders (a double or triple top/bottom) — a stronger magnet for price than a single level.
- Liquidity Sweep — the actual moment a level gets taken: a wick pierces through it and price closes back on the original side. This can optionally require above-average volume on that candle, so you only see genuine, forceful grabs instead of every minor wick poke.
- Previous Day/Week High & Low (PDH / PDL / PWH / PWL) — the same tracking and sweep logic applied to yesterday's and last week's high/low, which tend to be some of the largest, most-watched liquidity targets of all.

https://www.tradingview.com/x/rL1csyRC/
https://www.tradingview.com/x/qVuyNaN1/
https://www.tradingview.com/x/sK46N8bP/

Every level also shows a strength tag — the actual volume traded when it formed, plus how many times average that is (e.g. "340k (2.3x)") — so you can tell a level that formed with real conviction from one that formed on a quiet, unremarkable candle.

https://www.tradingview.com/x/0Yf24rCZ/

[b]HOW TO ACTUALLY USE IT (STEP BY STEP)[/b]

1. Decide which side you're watching, then wait for the actual sweep — don't trade a level just because it's sitting there on the chart.
   - Looking to go short? Find a Buyside Liquidity (BSL) level (or an Equal High) sitting above the current price, and wait for the sweep marker to appear — a wick punches through it, then price closes back below it.
   - Looking to go long? Find a Sellside Liquidity (SSL) level (or an Equal Low) sitting below the current price, and wait for the sweep marker there — a wick punches through it, then price closes back above it.
2. Give extra weight to Equal Highs/Lows (marked EQH/EQL, especially ones with a "x2" or "x3" touch count) and to the Previous Day/Week High/Low lines — these are the bigger, more heavily-defended levels, so a sweep there tends to matter more than a sweep of a single minor swing.
3. Check the strength label on the swept level before acting — a sweep that happened on 2x average volume or higher is a far more convincing signal of a genuine reversal than one on below-average volume.
4. Treat the sweep as your trigger, not the resting level itself: a Buyside sweep points you toward looking for shorts, a Sellside sweep points you toward looking for longs.
5. Levels that get swept turn gray and dotted automatically — that tells you at a glance which levels have already been taken and are no longer valid targets, versus which ones are still resting and still ahead of price.

[b]EVERY SETTING EXPLAINED[/b]

General group
- Swing Length (bars) — how many candles on each side must be lower/higher for a point to count as a real swing. A bigger number only catches major, more significant levels; a smaller number catches minor ones (more levels, more frequently).
- Max Levels Tracked — the maximum number of levels kept on the chart at once. Once you go over this, the oldest one is dropped. Lower this for a cleaner chart and better performance.

Buyside / Sellside Liquidity group
- Show BSL / SSL Levels — master on/off switch for these lines.
- Buyside (BSL) Color / Sellside (SSL) Color — line colors for each type.
- Line Width — thickness of the level lines.
- Line Style — solid, dashed, or dotted.

Equal Highs / Equal Lows group
- Highlight Equal Highs / Lows — turns on the automatic merging of two nearby swing highs (or lows) into one highlighted EQH/EQL pool.
- Equality Tolerance (x ATR) — how close two levels need to be in price (relative to recent volatility) to count as "equal." A larger value merges more loosely (more pairs count as equal); a smaller value requires them to be nearly identical.
- Equal High (EQH) Color / Equal Low (EQL) Color.
- Extend EQH/EQL Right — when off (default), an equal pool is just drawn as a short connector between the two matching swings. When on, it's also projected forward to the right as a live target, the same way single BSL/SSL levels are.

Level Strength group
- Show Level Strength — adds the volume text tag to every level (raw volume plus the multiple vs. the recent average, e.g. "340k (2.3x)"). Equal pools also show how many times that price has been touched (e.g. "EQH x3"). Turn this off for a cleaner look with just the lines and BSL/SSL/EQH/EQL tags.

Liquidity Sweep group
- Show Sweep Markers — turns on the small marker that appears the moment a level is swept.
- Enable Volume Filter — when on, a sweep is only confirmed if the candle that caused it traded on unusually high volume, filtering out weak/low-conviction wicks.
- Volume Multiplier vs. Average — how many times above the average volume that candle must trade to confirm a sweep. Only used when the Volume Filter above is on.
- Volume Lookback (bars) — how many past candles are averaged together to calculate that "average volume" baseline.
- Swept Level Color — the color a level turns once it has been taken, so already-used levels are still visible but clearly distinguished from live ones.

Higher-Timeframe Liquidity (PDH / PDL / PWH / PWL) group
- Show Previous Day High / Low — turns on tracking of yesterday's high and low as full liquidity levels (works on intraday charts only).
- Show Previous Week High / Low — turns on tracking of last week's high and low the same way (works on intraday and daily charts).
- Prev Day (PDH / PDL) Color / Prev Week (PWH / PWL) Color.
- HTF Line Width — thickness of these lines. Thicker by default than regular swing levels, since they're generally the more important reference points.

Labels group
- Show Level Labels — master switch for all the small text tags (BSL / SSL / EQH / EQL) shown on each level.
- Label Size — Tiny, Small, or Normal text size for those tags.

## Source Code

````pine
//@version=6

indicator("EonMetrics Liquidity Toolkit", "Liquidity Toolkit by EonMetrics", overlay=true, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════════
//                                  S E T T I N G S
// ════════════════════════════════════════════════════════════════════════════════
grp_gen = "General"
pivotLen  = input.int(5, "Swing Length (bars)", minval=2, maxval=50, group=grp_gen, tooltip="Number of bars to the left and right of a pivot required to confirm a Swing High or Swing Low. Higher = fewer, more significant levels.")
maxLevels = input.int(30, "Max Levels Tracked", minval=4, maxval=100, group=grp_gen, tooltip="Maximum number of liquidity levels kept on the chart at once. When exceeded, the oldest level is removed. Lower values keep the chart clean and improve performance.")

grp_liq = "Buyside / Sellside Liquidity"
showLiq   = input.bool(true, "Show BSL / SSL Levels", group=grp_liq, tooltip="Draws horizontal lines at unmitigated swing highs (Buyside Liquidity) and swing lows (Sellside Liquidity), extended right until price reaches them.")
bslColor  = input.color(color.new(#f23645, 0), "Buyside (BSL) Color", group=grp_liq, tooltip="Color for Buyside Liquidity — resting liquidity above swing highs (buy stops).")
sslColor  = input.color(color.new(#089981, 0), "Sellside (SSL) Color", group=grp_liq, tooltip="Color for Sellside Liquidity — resting liquidity below swing lows (sell stops).")
lineWidth = input.int(1, "Line Width", minval=1, maxval=4, group=grp_liq, tooltip="Thickness of the liquidity level lines.")
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_liq, tooltip="Style of the resting liquidity level lines.")

grp_eq = "Equal Highs / Equal Lows"
showEq   = input.bool(true, "Highlight Equal Highs / Lows", group=grp_eq, tooltip="When two levels of the same type form within the tolerance below, both are recolored and tagged EQH/EQL. Equal levels mark stronger liquidity pools and are high-probability targets.")
eqMult   = input.float(0.15, "Equality Tolerance (× ATR)", minval=0.01, maxval=2.0, step=0.01, group=grp_eq, tooltip="How close two levels must be to count as 'equal', measured as a multiple of ATR(14). Example: 0.15 = within 15% of the current ATR. Larger = more (looser) equal pairs.")
eqhColor = input.color(color.new(#ff9800, 0), "Equal High (EQH) Color", group=grp_eq, tooltip="Color used to highlight levels identified as Equal Highs.")
eqlColor = input.color(color.new(#ffeb3b, 0), "Equal Low (EQL) Color", group=grp_eq, tooltip="Color used to highlight levels identified as Equal Lows.")
extendEqual = input.bool(false, "Extend EQH/EQL Right", group=grp_eq, tooltip="OFF (default): Equal Highs/Lows are drawn as a connector segment between the two equal pivots. ON: the level is also projected to the right as a liquidity target.")

grp_str = "Level Strength"
showStrength = input.bool(true, "Show Level Strength", group=grp_str, tooltip="Adds a tag to each level showing the volume traded on the bar that formed it, in k/M, plus a multiple vs average volume (e.g. '340k (2.3×)' = 340k volume, 230% of average). Equal pools also show their touch count (e.g. 'EQH ×3'). Higher volume / more touches = more significant liquidity.")

grp_sweep = "Liquidity Sweep"
showSweep    = input.bool(true, "Show Sweep Markers", group=grp_sweep, tooltip="Marks the bar where price wicks through a level and closes back inside (a liquidity grab). Buyside sweep = bearish marker above bar; Sellside sweep = bullish marker below bar.")
useVolFilter = input.bool(true, "Enable Volume Filter", group=grp_sweep, tooltip="If enabled, a sweep is only confirmed when the sweeping candle's volume is significantly above average — filtering for genuine smart-money activity.")
volMult      = input.float(1.5, "Volume Multiplier vs. Average", minval=1.0, step=0.1, group=grp_sweep, tooltip="The sweep candle's volume must exceed (average volume × this multiplier) to confirm. Only active when the Volume Filter is enabled.")
volLen       = input.int(20, "Volume Lookback (bars)", minval=5, group=grp_sweep, tooltip="Lookback length for the average-volume (SMA) used by the volume filter.")
sweptColor   = input.color(color.new(color.gray, 30), "Swept Level Color", group=grp_sweep, tooltip="Color a level is recolored to once it has been swept or broken, so taken liquidity stays visible as historical reference.")

grp_htf = "Higher-Timeframe Liquidity (PDH / PDL / PWH / PWL)"
showPDH_PDL = input.bool(true, "Show Previous Day High / Low (PDH / PDL)", group=grp_htf, tooltip="Draws the previous day's High and Low as full liquidity levels, tracked by the SAME sweep engine as swing liquidity (extend until taken, sweep = wick through + close back inside + volume). The classic 'sweep the previous day high, then reverse' setup. Intraday charts only.")
showPWH_PWL = input.bool(true, "Show Previous Week High / Low (PWH / PWL)", group=grp_htf, tooltip="Draws the previous week's High and Low as full liquidity levels, tracked by the same sweep engine. Major weekly draw-on-liquidity targets. Intraday and daily charts only.")
htfDayColor = input.color(color.new(#2196f3, 0), "Prev Day (PDH / PDL) Color", group=grp_htf, tooltip="Color for the previous-day High and Low levels.")
htfWeekColor= input.color(color.new(#ff9800, 0), "Prev Week (PWH / PWL) Color", group=grp_htf, tooltip="Color for the previous-week High and Low levels.")
htfWidth    = input.int(2, "HTF Line Width", minval=1, maxval=5, group=grp_htf, tooltip="Thickness of the previous day / week levels. Heavier than swing levels by default so these major reference points stand out.")

grp_lbl = "Labels"
showLabels = input.bool(true, "Show Level Labels", group=grp_lbl, tooltip="Shows a small text tag on each level (BSL / SSL / EQH / EQL). Turn off for a cleaner chart.")
labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=grp_lbl, tooltip="Font size of the level text tags.")

// Map string inputs to Pine constants
lineStyleMap = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted
labelSize    = labelSizeInput == "Tiny" ? size.tiny : labelSizeInput == "Normal" ? size.normal : size.small

// ════════════════════════════════════════════════════════════════════════════════
//                                     T Y P E
// ════════════════════════════════════════════════════════════════════════════════
type Liq
    float price
    int   startBar
    bool  isBuyside   // true  = swing high (Buyside Liquidity)
                      // false = swing low  (Sellside Liquidity)
    bool  isEqual     // part of an EQH/EQL cluster
    bool  swept       // already taken (swept or broken) -> stop extending
    line  ln
    label lbl
    float volRaw      // volume on the formation bar (raw, shown in k/M)
    float strength    // formation volume relative to average (e.g. 2.3 = 230%)
    int   touches     // number of equal pivots in the pool (1 = single level)

// ════════════════════════════════════════════════════════════════════════════════
//                                     S T A T E
// ════════════════════════════════════════════════════════════════════════════════
var array<Liq> levels = array.new<Liq>()

// Higher-timeframe reference levels — kept as standalone refs (NOT in levels[]) so they
// never interact with swing merge/EQ logic or the maxLevels cull; redrawn each period.
var Liq curPDH = na
var Liq curPDL = na
var Liq curPWH = na
var Liq curPWL = na

// Per-bar event flags (for alerts / sweep markers)
bool newBSL       = false
bool newSSL       = false
bool newEQH       = false
bool newEQL       = false
bool buysideSweep = false
bool sellsideSweep= false
bool pdhSwept     = false
bool pdlSwept     = false
bool pwhSwept     = false
bool pwlSwept     = false

// ════════════════════════════════════════════════════════════════════════════════
//   GLOBAL CALCULATIONS — must run every bar for consistent history (execution model)
// ════════════════════════════════════════════════════════════════════════════════
ph     = ta.pivothigh(high, pivotLen, pivotLen)
pl     = ta.pivotlow(low,  pivotLen, pivotLen)
atr14  = ta.atr(14)
avgVol = ta.sma(volume, volLen)
eqTol  = atr14 * eqMult
volOk  = not useVolFilter or (volume > avgVol * volMult)

// Higher-timeframe reference levels — previous COMPLETED period High/Low.
// [1] on the HTF series + lookahead_on is the standard NON-repainting pattern for
// higher-timeframe PREVIOUS values (references a closed bar, never leaks the future).
[pdHigh, pdLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwHigh, pwLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
newDayBar  = ta.change(time("D")) != 0   // first bar of a new day  -> redraw PDH/PDL
newWeekBar = ta.change(time("W")) != 0   // first bar of a new week -> redraw PWH/PWL

// ════════════════════════════════════════════════════════════════════════════════
//                                   H E L P E R S
// ════════════════════════════════════════════════════════════════════════════════
// Format a volume value compactly (e.g. 340000 -> "340k", 1250000 -> "1.3M")
fmtVol(float v) =>
    av = math.abs(v)
    av >= 1e9 ? str.tostring(v / 1e9, "0.0") + "B" : av >= 1e6 ? str.tostring(v / 1e6, "0.0") + "M" : av >= 1e3 ? str.tostring(v / 1e3, "0.0") + "k" : str.tostring(v, "0")

// Build the full label text: type [+ touch count] [+ volume (multiple)]
lvText(Liq lv) =>
    typ = lv.isEqual ? (lv.isBuyside ? "EQH" : "EQL") : (lv.isBuyside ? "BSL" : "SSL")
    res = typ
    if lv.isEqual and lv.touches > 1
        res := res + " ×" + str.tostring(lv.touches)
    if showStrength
        res := res + " " + fmtVol(lv.volRaw) + " (" + str.tostring(lv.strength, "0.0") + "×)"
    res

// Apply EQH/EQL styling to a level (recolor line + refresh label)
markEqual(Liq lv) =>
    eqCol = lv.isBuyside ? eqhColor : eqlColor
    line.set_color(lv.ln, eqCol)
    if not na(lv.lbl)
        label.set_text(lv.lbl, lvText(lv))
        label.set_textcolor(lv.lbl, eqCol)

// Create a new resting liquidity level and draw it
createLevel(float price, int startBar, bool isBuyside, float volRaw, float strength) =>
    lv  = Liq.new(price, startBar, isBuyside, false, false, na, na, volRaw, strength, 1)
    col = isBuyside ? bslColor : sslColor
    lv.ln := line.new(startBar, price, bar_index, price, xloc=xloc.bar_index, color=col, style=lineStyleMap, width=lineWidth)
    if showLabels
        lv.lbl := label.new(startBar, price + atr14 * 0.15, lvText(lv), xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=labelSize)
    lv

// Extend a resting level one bar and detect whether it is taken this bar. Returns
// [buysideSweepEvent, sellsideSweepEvent]. Single source of truth for the sweep engine,
// shared by both swing liquidity (levels[]) and the HTF reference levels below.
updateLevel(Liq lv) =>
    bool bSwp = false
    bool sSwp = false
    if not lv.swept
        // Resting single levels extend right (projected liquidity). Equal-pivot pools
        // stay as a connector between pivots unless "Extend EQH/EQL" is on.
        if not lv.isEqual or extendEqual
            line.set_x2(lv.ln, bar_index)
        // A level is consumed the moment price trades into it (liquidity taken), regardless
        // of volume. The SWEEP SIGNAL is stricter: a wick that pierces the level and closes
        // back inside, confirmed by the volume filter.
        if lv.isBuyside and high >= lv.price
            lv.swept := true
            line.set_color(lv.ln, sweptColor)
            line.set_style(lv.ln, line.style_dotted)
            if not na(lv.lbl)
                label.set_textcolor(lv.lbl, sweptColor)
            if close < lv.price and volOk        // rejection (close back below) + volume
                bSwp := true
        else if not lv.isBuyside and low <= lv.price
            lv.swept := true
            line.set_color(lv.ln, sweptColor)
            line.set_style(lv.ln, line.style_dotted)
            if not na(lv.lbl)
                label.set_textcolor(lv.lbl, sweptColor)
            if close > lv.price and volOk        // rejection (close back above) + volume
                sSwp := true
    [bSwp, sSwp]

// Create a higher-timeframe reference level (PDH/PDL/PWH/PWL). Reuses the Liq type so it
// flows through updateLevel exactly like swing liquidity; solid + heavier line so major
// levels stand out. No formation-volume semantics (volRaw/strength unused for HTF).
createHTFLevel(float price, int startBar, bool isBuyside, string nm, color col) =>
    lv = Liq.new(price, startBar, isBuyside, false, false, na, na, 0.0, 1.0, 1)
    lv.ln := line.new(startBar, price, bar_index, price, xloc=xloc.bar_index, color=col, style=line.style_solid, width=htfWidth)
    if showLabels
        lv.lbl := label.new(startBar, price + atr14 * 0.15, nm, xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=col, style=label.style_label_left, size=labelSize)
    lv

// ════════════════════════════════════════════════════════════════════════════════
//   NEW LEVEL DETECTION
//   A pivot confirms pivotLen bars after it forms -> the level is already historical
//   and non-repainting when registered here.
// ════════════════════════════════════════════════════════════════════════════════
if not na(ph)
    pPrice = ph
    pBar   = bar_index - pivotLen
    pVol   = volume[pivotLen]                                          // volume on the pivot bar
    pStr   = nz(avgVol[pivotLen]) > 0 ? pVol / avgVol[pivotLen] : 1.0  // relative to average
    // If the new high matches an existing resting buyside level within tolerance,
    // MERGE into it — reinforcing the single pool line that already extends through
    // both highs — instead of drawing a second parallel line.
    merged = false
    if showEq and array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            lv = array.get(levels, i)
            if not merged and not lv.swept and lv.isBuyside and math.abs(lv.price - pPrice) <= eqTol
                lv.touches  := lv.touches + 1
                lv.strength := math.max(lv.strength, pStr)
                lv.volRaw   := math.max(lv.volRaw, pVol)
                lv.isEqual  := true
                markEqual(lv)
                line.set_x2(lv.ln, pBar)   // pull the line into a connector: pivot1 -> pivot2
                newEQH := true
                merged := true
    if not merged
        array.push(levels, createLevel(pPrice, pBar, true, pVol, pStr))
        newBSL := true

if not na(pl)
    pPrice = pl
    pBar   = bar_index - pivotLen
    pVol   = volume[pivotLen]
    pStr   = nz(avgVol[pivotLen]) > 0 ? pVol / avgVol[pivotLen] : 1.0
    merged = false
    if showEq and array.size(levels) > 0
        for i = array.size(levels) - 1 to 0
            lv = array.get(levels, i)
            if not merged and not lv.swept and not lv.isBuyside and math.abs(lv.price - pPrice) <= eqTol
                lv.touches  := lv.touches + 1
                lv.strength := math.max(lv.strength, pStr)
                lv.volRaw   := math.max(lv.volRaw, pVol)
                lv.isEqual  := true
                markEqual(lv)
                line.set_x2(lv.ln, pBar)   // pull the line into a connector: pivot1 -> pivot2
                newEQL := true
                merged := true
    if not merged
        array.push(levels, createLevel(pPrice, pBar, false, pVol, pStr))
        newSSL := true

// ════════════════════════════════════════════════════════════════════════════════
//   UPDATE LOOP — extend resting levels, detect sweep (rejection) vs break (acceptance)
// ════════════════════════════════════════════════════════════════════════════════
if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        lv = array.get(levels, i)
        [b, s] = updateLevel(lv)
        if b
            buysideSweep := true
        if s
            sellsideSweep := true

// ════════════════════════════════════════════════════════════════════════════════
//   HIGHER-TIMEFRAME LIQUIDITY — PDH/PDL/PWH/PWL through the SAME sweep engine
//   Redrawn on each new period; the prior period's levels are deleted so only the
//   current previous-day / previous-week references are shown, then tracked until swept.
// ════════════════════════════════════════════════════════════════════════════════
// ── Previous DAY (intraday charts only) ──
if showPDH_PDL and timeframe.isintraday and not na(pdHigh) and (newDayBar or na(curPDH))
    if not na(curPDH)
        line.delete(curPDH.ln)
        if not na(curPDH.lbl)
            label.delete(curPDH.lbl)
    if not na(curPDL)
        line.delete(curPDL.ln)
        if not na(curPDL.lbl)
            label.delete(curPDL.lbl)
    curPDH := createHTFLevel(pdHigh, bar_index, true,  "PDH", htfDayColor)
    curPDL := createHTFLevel(pdLow,  bar_index, false, "PDL", htfDayColor)
if not na(curPDH)
    [pdhEv, _] = updateLevel(curPDH)
    if pdhEv
        buysideSweep := true
        pdhSwept     := true
if not na(curPDL)
    [_, pdlEv] = updateLevel(curPDL)
    if pdlEv
        sellsideSweep := true
        pdlSwept      := true

// ── Previous WEEK (intraday + daily charts) ──
if showPWH_PWL and (timeframe.isintraday or timeframe.isdaily) and not na(pwHigh) and (newWeekBar or na(curPWH))
    if not na(curPWH)
        line.delete(curPWH.ln)
        if not na(curPWH.lbl)
            label.delete(curPWH.lbl)
    if not na(curPWL)
        line.delete(curPWL.ln)
        if not na(curPWL.lbl)
            label.delete(curPWL.lbl)
    curPWH := createHTFLevel(pwHigh, bar_index, true,  "PWH", htfWeekColor)
    curPWL := createHTFLevel(pwLow,  bar_index, false, "PWL", htfWeekColor)
if not na(curPWH)
    [pwhEv, _] = updateLevel(curPWH)
    if pwhEv
        buysideSweep := true
        pwhSwept     := true
if not na(curPWL)
    [_, pwlEv] = updateLevel(curPWL)
    if pwlEv
        sellsideSweep := true
        pwlSwept      := true

// ════════════════════════════════════════════════════════════════════════════════
//   CLEANUP — cap the number of tracked levels (remove oldest)
// ════════════════════════════════════════════════════════════════════════════════
while array.size(levels) > maxLevels
    old = array.shift(levels)
    line.delete(old.ln)
    if not na(old.lbl)
        label.delete(old.lbl)

// ════════════════════════════════════════════════════════════════════════════════
//   SWEEP MARKERS  (plotshape — cheap, fires on the sweep bar)
//   Buyside sweep  -> bearish (price likely to fall) -> marker above bar
//   Sellside sweep -> bullish (price likely to rise) -> marker below bar
// ════════════════════════════════════════════════════════════════════════════════
plotshape(showSweep and buysideSweep,  title="Buyside Sweep",  style=shape.labeldown, location=location.abovebar, color=bslColor, text="Liq", textcolor=color.white, size=size.tiny)
plotshape(showSweep and sellsideSweep, title="Sellside Sweep", style=shape.labelup,   location=location.belowbar, color=sslColor, text="Liq", textcolor=color.white, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════════
//                                    A L E R T S
// ════════════════════════════════════════════════════════════════════════════════
alertcondition(newBSL,        title="1. New Buyside Liquidity (BSL)",  message="New Buyside Liquidity level formed above a swing high.")
alertcondition(newSSL,        title="2. New Sellside Liquidity (SSL)", message="New Sellside Liquidity level formed below a swing low.")
alertcondition(newEQH,        title="3. Equal Highs (EQH)",            message="Equal Highs detected — liquidity pool forming above.")
alertcondition(newEQL,        title="4. Equal Lows (EQL)",             message="Equal Lows detected — liquidity pool forming below.")
alertcondition(buysideSweep,  title="5. Buyside Sweep",                message="Buyside liquidity swept — potential bearish reversal.")
alertcondition(sellsideSweep, title="6. Sellside Sweep",              message="Sellside liquidity swept — potential bullish reversal.")
alertcondition(buysideSweep or sellsideSweep, title="7. Any Liquidity Sweep", message="A liquidity sweep has occurred.")
alertcondition(pdhSwept, title="8. Previous Day High Swept",  message="Previous Day High (PDH) swept — potential bearish reversal.")
alertcondition(pdlSwept, title="9. Previous Day Low Swept",   message="Previous Day Low (PDL) swept — potential bullish reversal.")
alertcondition(pwhSwept, title="10. Previous Week High Swept", message="Previous Week High (PWH) swept — potential bearish reversal.")
alertcondition(pwlSwept, title="11. Previous Week Low Swept",  message="Previous Week Low (PWL) swept — potential bullish reversal.")
````
