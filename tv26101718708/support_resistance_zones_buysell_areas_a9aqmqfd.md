# Support & Resistance Zones [Buy/Sell Areas]

- url: https://www.tradingview.com/script/a9AQMqfD-Support-Resistance-Zones-Buy-Sell-Areas/
- type: indicator
- pine_id: PUB;a91b85bfa1724e8aa1035c450882c333
- version: 1.0

## Description

█ [b]Overview[/b]

Support & Resistance Zones [Buy/Sell Areas] turns recent swing highs and swing lows into clean, ATR-sized zones, then keeps a running record of what happens to each one.

Instead of a thin line that price rarely respects to the tick, you get a band. Each zone carries a label with a relative activity tier, and a permanent Broken status once price has closed through it, so failed levels stay visible without being confused with active ones.

[image]https://www.tradingview.com/x/u6FeYNDt/[/image]

▌ [b]Zones from swing pivots[/b]
Resistance zones (red) come from swing highs. Support zones (green) come from swing lows. Only the latest zones per side are shown (default 3), so the chart stays readable.

▌ [b]Touch count and tier[/b]
Each zone tracks how many bars have traded inside it. A relative tier (Strong, Medium, Weak) ranks the zones against each other. Hover a label to see its exact count and rank.

▌ [b]Permanent Broken status[/b]
When a bar closes beyond a zone's far edge, the zone turns gray and is marked Broken. It stays that way even if price returns.

[image]https://www.tradingview.com/x/LTP8GrNa/[/image]


█ [b]How It Works[/b]

[b]1. Pivot detection[/b]
A pivot is a candle whose high (or low) stands out against N bars on each side (default N = 10). A pivot is confirmed N bars after the candle, so zones appear with that delay.

[b]2. Zone construction[/b]
Zone = pivot price +/- (ATR x Zone Width). With the defaults (ATR length 14, multiplier 0.5), a zone is about one ATR thick. All zones share the same thickness, based on the current ATR, and it updates as ATR changes.

[b]3. Touch tracking[/b]
The count starts at 1 for the pivot candle. After that, every bar whose range overlaps the zone adds 1. Several consecutive bars inside a zone each count, so this measures bars spent in the zone, not separate reactions.

[b]4. Tier ranking[/b]
Zones are ranked by touch count among the zones currently shown on that side. The top third is Strong, the bottom third is Weak, and the rest are Medium. This is a relative ranking: with two zones, one is always Strong and the other Weak, even if their counts are close. It does not estimate how likely a zone is to hold.

[b]5. Break logic[/b]
Resistance is broken when a bar closes above the top of the zone. Support is broken when a bar closes below the bottom. Support and resistance are tracked independently, and a broken zone does not turn into the opposite type.

[b]6. Zone lifecycle[/b]
When a new pivot is confirmed and the Max Zones limit is exceeded, the oldest zone on that side drops off.


█ [b]How to Use[/b]

▌ [b]Reading the chart[/b]
Color shows age only: brighter zones are newer, darker zones are older. Use labels and tooltips for touch count and rank.

▌ [b]Resistance and support zones[/b]
Treat zones as areas to watch for a price reaction, such as a pause, rejection or bounce on a retest. Price may or may not react, and a zone can fail at any time.

▌ [b]Broken zones[/b]
Gray zones show where price has already closed through a level. They are kept for reference.

▌ [b]Choosing the pivot length[/b]
A higher Pivot Lookback Length gives fewer, more significant zones, confirmed later. A lower one gives more recent structure, confirmed sooner. The indicator uses only the chart's own data, with no higher-timeframe requests, and works on any market and timeframe.


█ [b]Settings[/b]

[b]Zone settings[/b]
[list]
[*]Pivot Lookback Length (default 10): bars checked on each side of a pivot.
[*]ATR Length (default 14) and Zone Width x ATR (default 0.5): zone thickness.
[*]Max Zones per Side (default 3): how many zones are kept.
[/list]
[b]Display[/b]
[list]
[*]Zone Extension (default 30 bars): how far boxes project to the right.
[*]Show Zone Labels: S/R label with tier. Tooltips give exact counts.
[/list]
[b]Zone colors[/b]
Bright and dark endpoints for support, resistance and broken zones.


█ [b]Alerts[/b]

Two alert conditions: Resistance Zone Broken and Support Zone Broken. They follow only the newest pivot on each side and trigger when the close crosses that pivot's price level (the center of the zone, not its outer edge). Because the tracked level changes when a new pivot is confirmed, an alert can also fire when a new pivot replaces the tracked level, not only when price moves through it. Use Once Per Bar Close when creating the alert.


█ [b]Limitations[/b]

[list]
[*]Zones are drawn from the pivot candle, but were not known until N bars later.
[*]Only the current state is drawn. Scrolling back does not show earlier zones.
[*]The latest pivots are shown regardless of how far they are from current price.
[*]On a live bar, touch counts and break status can change until the bar closes.
[/list]

█ [b]Disclaimer[/b]

This indicator is an analytical tool, not financial advice or a guarantee of future results. You are responsible for your own trading decisions.

## Source Code

````pine
//@version=6
indicator(title="Support & Resistance Zones [Buy/Sell Areas]", overlay=true, max_bars_back=5000)

// ============================================================
// INPUTS
// ============================================================
pivotLen      = input.int(10, title="Pivot Lookback Length", minval=2, maxval=50,
     tooltip="Number of bars checked on each side of a candle to confirm it as a swing high/low. Higher = fewer, more significant pivots.")
atrLen        = input.int(14, title="ATR Length (zone width)", minval=1,
     tooltip="Lookback period for the ATR calculation used to size zone thickness.")
zoneWidthMult = input.float(0.5, title="Zone Width (x ATR)", minval=0.1, step=0.1,
     tooltip="Multiplier applied to ATR to set how thick each support/resistance zone is drawn.")
maxZones      = input.int(3, title="Max Zones per Side", minval=1, maxval=10,
     tooltip="How many support and resistance zones to keep and draw simultaneously on each side. Oldest zones roll off once this limit is exceeded.")
extendBars    = input.int(30, title="Zone Extension (bars)", minval=5, maxval=200,
     tooltip="How far to the right (in bars) each zone box extends beyond the current price.")
showLabels    = input.bool(true, title="Show Zone Labels",
     tooltip="Displays a label at each zone showing whether it's a Support (S) or Resistance (R) level, plus a relative strength tag:\n\n" +
             "• Strong = among the most-touched zones on that side (price has revisited it the most)\n" +
             "• Medium = average touch count relative to other current zones\n" +
             "• Weak = among the least-touched zones on that side\n\n" +
             "Strength is ranked only against the other zones currently on screen (on the same side), not against a fixed scale. A zone price has closed through turns gray and is marked (Broken) — this is independent per zone and per side, so breaking a resistance never affects support zones, and vice versa. Hover over an individual label for that zone's exact touch count and rank.")

// ============================================================
// COLOR INPUTS (user-customizable gradient endpoints)
// ============================================================
brightGreen = input.color(color.rgb(0, 230, 0), title="Support – Bright (newest)", group="Zone Colors",
     tooltip="Color used for the most recently formed, still-active support zone. Older active support zones fade toward the dark support color below.")
darkGreen   = input.color(color.rgb(0, 55, 0), title="Support – Dark (oldest)", group="Zone Colors",
     tooltip="Color used for the longest-standing, still-active support zone. Newer active support zones fade from the bright support color toward this one.")
brightRed   = input.color(color.rgb(255, 60, 60), title="Resistance – Bright (newest)", group="Zone Colors",
     tooltip="Color used for the most recently formed, still-active resistance zone. Older active resistance zones fade toward the dark resistance color below.")
darkRed     = input.color(color.rgb(110, 0, 0), title="Resistance – Dark (oldest)", group="Zone Colors",
     tooltip="Color used for the longest-standing, still-active resistance zone. Newer active resistance zones fade from the bright resistance color toward this one.")
brightGray  = input.color(color.rgb(170, 170, 170), title="Broken Zone – Bright (newest)", group="Zone Colors",
     tooltip="Color used for a recently formed zone that price has closed through (broken), whether it was support or resistance. Once a zone is marked broken it stays gray permanently, even if price later trades back inside its range.")
darkGray    = input.color(color.rgb(60, 60, 60), title="Broken Zone – Dark (oldest)", group="Zone Colors",
     tooltip="Color used for a long-standing zone that price has closed through (broken), whether it was support or resistance.")

// ============================================================
// PIVOT DETECTION
// ============================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

atrVal        = ta.atr(atrLen)
zoneHalfWidth = atrVal * zoneWidthMult

// Safety cap: never ask box.new for more history than the declared
// max_bars_back can supply, no matter how old a stagnant zone gets.
// Leaves headroom below the 5000 declared above.
maxLookbackBars = 4900

// ============================================================
// STORAGE (rolling list of the most recent pivots + touch counts + broken flag)
// ============================================================
var float[] resLevels  = array.new_float(0)
var int[]   resBars    = array.new_int(0)
var float[] resTouches = array.new_float(0)   // "strength" counter
var bool[]  resBroken  = array.new_bool(0)    // persistent broken flag, independent of support

var float[] supLevels  = array.new_float(0)
var int[]   supBars    = array.new_int(0)
var float[] supTouches = array.new_float(0)
var bool[]  supBroken  = array.new_bool(0)    // persistent broken flag, independent of resistance

var box[]   resBoxes  = array.new_box(0)
var box[]   supBoxes  = array.new_box(0)
var label[] resLabels = array.new_label(0)
var label[] supLabels = array.new_label(0)

// ---- accumulate touches + evaluate break status for EXISTING levels (every bar) ----
// Each side only ever looks at its own level's price — a resistance zone
// can never be marked broken by support price action, and vice versa.
if array.size(resLevels) > 0
    for i = 0 to array.size(resLevels) - 1
        lvl = array.get(resLevels, i)
        if high >= lvl - zoneHalfWidth and low <= lvl + zoneHalfWidth
            array.set(resTouches, i, array.get(resTouches, i) + 1)
        // Resistance breaks once price CLOSES above the top of that specific zone.
        // Once true, it stays true (persistent) — it won't un-break on a pullback.
        if not array.get(resBroken, i) and close > lvl + zoneHalfWidth
            array.set(resBroken, i, true)

if array.size(supLevels) > 0
    for i = 0 to array.size(supLevels) - 1
        lvl = array.get(supLevels, i)
        if high >= lvl - zoneHalfWidth and low <= lvl + zoneHalfWidth
            array.set(supTouches, i, array.get(supTouches, i) + 1)
        // Support breaks once price CLOSES below the bottom of that specific zone.
        if not array.get(supBroken, i) and close < lvl - zoneHalfWidth
            array.set(supBroken, i, true)

// ---- then register any brand-new pivot on this bar ----
if not na(ph)
    array.push(resLevels, ph)
    array.push(resBars, bar_index - pivotLen)
    array.push(resTouches, 1.0)
    array.push(resBroken, false)
    if array.size(resLevels) > maxZones
        array.shift(resLevels)
        array.shift(resBars)
        array.shift(resTouches)
        array.shift(resBroken)

if not na(pl)
    array.push(supLevels, pl)
    array.push(supBars, bar_index - pivotLen)
    array.push(supTouches, 1.0)
    array.push(supBroken, false)
    if array.size(supLevels) > maxZones
        array.shift(supLevels)
        array.shift(supBars)
        array.shift(supTouches)
        array.shift(supBroken)

// ============================================================
// STRENGTH TIER HELPER
// rank 0 = most touches (strongest) ... rank n-1 = fewest (weakest)
// ============================================================
tierLabel(rankPos, n) =>
    string tier = "Medium"
    if n <= 1
        tier := ""
    else
        frac = rankPos / (n - 1.0)
        if frac <= 0.34
            tier := "Strong"
        else if frac >= 0.66
            tier := "Weak"
    tier

// ============================================================
// TIER TOOLTIP HELPER
// ============================================================
tierTooltip(sideName, tier, touches, rankPos, n, isBroken) =>
    string tierExplain = ""
    if tier == "Strong"
        tierExplain := "This is one of the most-touched " + sideName + " zones currently tracked — price has repeatedly reacted to it, suggesting it carries more weight."
    else if tier == "Weak"
        tierExplain := "This is one of the least-touched " + sideName + " zones currently tracked — it has been revisited less often, suggesting it may be less significant or more likely to break."
    else if tier == "Medium"
        tierExplain := "This " + sideName + " zone has an average touch count relative to the other " + sideName + " zones currently tracked."
    else
        tierExplain := "Only one " + sideName + " zone is currently tracked, so no relative comparison is available."

    string brokenExplain = isBroken ?
         "\n\nBROKEN: price has closed through this zone, so it's no longer acting as active " + sideName + ". This status is locked in permanently for this zone and shown in gray for reference only — it does not affect zones on the opposite side." :
         ""

    "Touch count: " + str.tostring(touches, "#") + " (times price has revisited this zone)\n" +
     "Rank: " + str.tostring(rankPos + 1) + " of " + str.tostring(n) + " " + sideName + " zones (1 = most touched)\n\n" +
     tierExplain + brokenExplain

// ============================================================
// AGE-BASED MIN/MAX HELPERS (for gradient normalization)
// ============================================================
minMaxAge(barsArr) =>
    n = array.size(barsArr)
    float mn = na
    float mx = na
    if n > 0
        for i = 0 to n - 1
            age = bar_index - array.get(barsArr, i)
            mn := na(mn) ? age : math.min(mn, age)
            mx := na(mx) ? age : math.max(mx, age)
    [mn, mx]

// ============================================================
// DRAW ZONES (redraw fresh on the last bar only)
// ============================================================
if barstate.islast
    // Pop-until-empty is safe even when the array is already empty,
    // unlike "for i = 0 to array.size(x) - 1", which misfires once
    // on an empty array (size-1 = -1, and Pine runs a descending
    // loop from 0 to -1 instead of skipping it).
    while array.size(resBoxes) > 0
        box.delete(array.pop(resBoxes))
    while array.size(supBoxes) > 0
        box.delete(array.pop(supBoxes))
    while array.size(resLabels) > 0
        label.delete(array.pop(resLabels))
    while array.size(supLabels) > 0
        label.delete(array.pop(supLabels))

    // rank levels by touch count (descending = strongest first)
    resRanked = array.size(resTouches) > 0 ? array.sort_indices(resTouches, order.descending) : array.new_int(0)
    supRanked = array.size(supTouches) > 0 ? array.sort_indices(supTouches, order.descending) : array.new_int(0)

    [resMinAge, resMaxAge] = minMaxAge(resBars)
    [supMinAge, supMaxAge] = minMaxAge(supBars)

    if array.size(resLevels) > 0
        n = array.size(resLevels)
        for i = 0 to n - 1
            lvl      = array.get(resLevels, i)
            startBar = array.get(resBars, i)
            touches  = array.get(resTouches, i)
            rankPos  = array.indexof(resRanked, i)
            tier     = tierLabel(rankPos, n)
            age      = bar_index - startBar
            isBroken = array.get(resBroken, i)   // this zone's own persistent flag only

            // Never draw further back than the historical buffer allows,
            // even if this zone's pivot bar is older than that.
            drawLeft = math.max(startBar, bar_index - maxLookbackBars)

            gradColor = isBroken ?
                 color.from_gradient(age, resMinAge, resMaxAge, brightGray, darkGray) :
                 color.from_gradient(age, resMinAge, resMaxAge, brightRed, darkRed)

            newBox = box.new(
                 left=drawLeft,
                 top=lvl + zoneHalfWidth,
                 right=bar_index + extendBars,
                 bottom=lvl - zoneHalfWidth,
                 border_color=gradColor,
                 bgcolor=color.new(gradColor, isBroken ? 90 : 85),
                 extend=extend.none
                 )
            array.push(resBoxes, newBox)

            if showLabels
                txt = "R" + (tier != "" ? " (" + tier + ")" : "") + (isBroken ? " Broken" : "")
                newLabel = label.new(
                     x=bar_index + extendBars,
                     y=lvl,
                     text=txt,
                     color=color.new(color.white, 100),
                     textcolor=gradColor,
                     style=label.style_label_left,
                     size=size.small,
                     tooltip=tierTooltip("resistance", tier, touches, rankPos, n, isBroken)
                     )
                array.push(resLabels, newLabel)

    if array.size(supLevels) > 0
        n = array.size(supLevels)
        for i = 0 to n - 1
            lvl      = array.get(supLevels, i)
            startBar = array.get(supBars, i)
            touches  = array.get(supTouches, i)
            rankPos  = array.indexof(supRanked, i)
            tier     = tierLabel(rankPos, n)
            age      = bar_index - startBar
            isBroken = array.get(supBroken, i)   // this zone's own persistent flag only

            drawLeft = math.max(startBar, bar_index - maxLookbackBars)

            gradColor = isBroken ?
                 color.from_gradient(age, supMinAge, supMaxAge, brightGray, darkGray) :
                 color.from_gradient(age, supMinAge, supMaxAge, brightGreen, darkGreen)

            newBox = box.new(
                 left=drawLeft,
                 top=lvl + zoneHalfWidth,
                 right=bar_index + extendBars,
                 bottom=lvl - zoneHalfWidth,
                 border_color=gradColor,
                 bgcolor=color.new(gradColor, isBroken ? 90 : 85),
                 extend=extend.none
                 )
            array.push(supBoxes, newBox)

            if showLabels
                txt = "S" + (tier != "" ? " (" + tier + ")" : "") + (isBroken ? " Broken" : "")
                newLabel = label.new(
                     x=bar_index + extendBars,
                     y=lvl,
                     text=txt,
                     color=color.new(color.white, 100),
                     textcolor=gradColor,
                     style=label.style_label_left,
                     size=size.small,
                     tooltip=tierTooltip("support", tier, touches, rankPos, n, isBroken)
                     )
                array.push(supLabels, newLabel)

// ============================================================
// OPTIONAL BREAK ALERTS
// ============================================================
lastResistance = array.size(resLevels) > 0 ? array.get(resLevels, array.size(resLevels) - 1) : na
lastSupport    = array.size(supLevels) > 0 ? array.get(supLevels, array.size(supLevels) - 1) : na

brokeResistance = not na(lastResistance) and ta.crossover(close, lastResistance)
brokeSupport    = not na(lastSupport) and ta.crossunder(close, lastSupport)

alertcondition(brokeResistance, title="Resistance Zone Broken", message="Price closed above the most recent resistance zone")
alertcondition(brokeSupport, title="Support Zone Broken", message="Price closed below the most recent support zone")
````
