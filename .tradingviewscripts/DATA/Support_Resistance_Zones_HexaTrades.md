<!-- tradingview-pine-id: PUB;2fe7481b608e498abaffbf5ce1fa3b31 -->
<!-- tradingviewscripts-format: 1 -->
# Support & Resistance Zones [HexaTrades]

Source: https://www.tradingview.com/script/qW9Iiijn-Support-Resistance-Zones-HexaTrades/

## Description

This indicator automatically finds the price levels where the market has turned around before the places where buyers stepped in (support) and where sellers took over (resistance)  and draws them as clean rectangular zones on your chart.

Instead of a thin line, each level is drawn as a zone with real thickness, because support and resistance are never one exact price; they are areas where price reacts. The zones update live, extend forward as long as they are valid, and turn into light "ghost" boxes once price finally breaks through them, so you always keep the full picture of the market's history.

https://www.tradingview.com/x/geEL8RNw/
Bitcoin 4h: the indicator marking support and resistance zones

How it works

- Finds swing points. A swing high is a candle whose high is higher than the 10 candles on each side of it (the "Swing Length" setting). A swing low is the same idea upside down. These are the exact spots where the market turned.

- Builds a zone from the candle. The zone covers the candle's wick from the extreme tip to the candle body. That wick is where orders actually pushed price back, so it becomes the zone.

- Keeps zone size sensible. Very small wicks get padded to a minimum height, and no zone can grow taller than a maximum height (both measured in ATR, so they adapt automatically to each market's volatility).

- Merges duplicate levels. If a new swing forms at a level that already has a zone, the two are combined into one box instead of stacking clutter on your chart.

- Watches for breaks. When a candle closes beyond a zone, the zone is "broken."  what happens next is up to you (see below).

What happens after a zone breaks?

The indicator provides three different zone-management options.

Keep As Past Zone: The broken zone stops extending and remains visible as a faded historical zone. This makes it easier to review how price behaved around previous levels.

Flip Support/Resistance: A broken resistance zone becomes support, while a broken support zone becomes resistance.
This is useful for studying the common market concept of role reversal, where old resistance may act as new support and old support may act as new resistance.

Delete Zone: The zone is completely removed after it breaks. This option is useful for traders who prefer a cleaner chart showing only active zones.

Optional volume filter:
Volume-Confirmed Zones Only can be enabled to filter out lower-volume swing points.
When enabled, the volume of the swing candle must be higher than: Average Volume × Volume Multiplier

For example, with a Volume Multiplier of 1.2, the swing candle’s volume must be greater than 120% of its average volume.
The volume filter is automatically ignored when volume data is unavailable. Volume quality can vary between markets, exchanges and brokers.

Indicator settings

- Swing Length: Controls how significant a swing must be. Lower values create more zones, while higher values create fewer but potentially more significant zones.

- Maximum Zones: Limits the number of active zones displayed. When the limit is exceeded, the oldest active zone is removed.

- ATR Length: Sets the calculation period used to measure volatility.

- Minimum Zone Height: Sets the minimum zone thickness as a multiple of ATR.

- Maximum Zone Height: Prevents zones from becoming excessively wide.

- Merge Overlapping Zones: Combines overlapping or nearby active zones.

- Merge Distance: Controls the ATR-based distance used when deciding whether zones should be merged.

- Maximum Past Zones: Limits how many broken historical zones remain on the chart.

- Past Zone Transparency: Controls how clearly broken zones are displayed.

Alerts

- Built-in alerts
- Zone Touched — price entered a support or resistance zone.
- Resistance Broken — a candle broke above a resistance zone.
- Support Broken — a candle broke a support zone below.
- Set them up from TradingView's alert dialog: Create Alert → Condition → S/R Zones.

How to use it in trading

🔶Bounce trades: when price falls into a support zone and prints a rejection candle, that's a long setup with a stop just below the zone.

A blue support zone represents an area where buyers previously entered the market.

When price returns to support:
- Wait for price to enter or test the zone.
- Look for evidence that buyers are responding.
- Consider an entry only after confirmation.
- Place the stop beyond the opposite side of the zone, with an appropriate buffer.
- Use the next resistance zone as a possible target.

Possible bullish confirmation includes:
- A candle rejecting the lower part of the zone.
- A long lower wick followed by a bullish close.
- A bullish engulfing candle.
- Price closing back above the support zone.
- Increasing volume during the reaction.
- A higher low forming near the zone.

A support touch by itself is not a long signal. Price can move directly through the zone, especially during a strong downtrend.
Example image below:
https://www.tradingview.com/x/sQSN12qm/

🔶Rejection from resistance

A pink resistance zone represents an area where sellers previously entered the market.

When price reaches resistance:
- Wait for price to test the zone.
- Look for signs of selling pressure.
- Consider an entry only after bearish confirmation.
- Place the stop beyond the upper edge of the zone, with a suitable buffer.
- Use the next support zone below as a possible target.

Possible bearish confirmation includes:
- A long upper wick inside the resistance zone.
- A bearish engulfing candle.
- Price entering the zone and closing back below it.
- A lower high forming near resistance.
- Increasing selling volume during the rejection.

A resistance touch alone is not a short signal. Strong bullish momentum can break through resistance without producing a meaningful reversal.

Example image:
https://www.tradingview.com/x/qCs1Ytw4/

🔶Trading a breakout

A breakout occurs when price moves beyond an active zone.

- A break above resistance may indicate increasing bullish strength.
- A break below support may indicate increasing bearish strength.

For more conservative confirmation, select Close under Break Confirmation. In this mode, a resistance zone breaks only after a candle closes above it, while a support zone breaks only after a candle closes below it.

The Wick option reacts as soon as price trades beyond the zone. It responds faster but is more sensitive to temporary spikes and false breakouts.

Before considering a breakout trade, traders may look for:
- A strong candle closing beyond the zone.
- A candle body that closes clearly outside the zone.
- Higher-than-average volume.
- Momentum in the breakout direction.
- Alignment with the broader market trend.
- A successful retest of the broken zone.

https://www.tradingview.com/x/i9o7YZbF/

🔶Trading a role reversal

Support and resistance can sometimes exchange roles after a breakout.

-Broken resistance may later act as support.
- Broken support may later act as resistance.

Select Flip Support/Resistance under the When Broken setting to display this behaviour automatically.

For example, after price closes above a pink resistance zone, the indicator converts that area into a blue support zone. If price later returns to it, traders can watch for a bullish reaction.

Similarly, when price breaks below blue support, the indicator converts the zone into pink resistance. A later retest may provide an area to watch for bearish confirmation.

Role reversal is a commonly observed price-action concept, but it does not occur successfully after every breakout. Wait for confirmation instead of entering only because price has returned to a flipped zone.

🔶Using zones for targets and stops

Zones can also help organise trade management.

For a long setup:
- A stop may be placed below the support zone.
- The next resistance zone may be used as an initial target.
- A higher resistance zone may be considered as a secondary target if momentum remains strong.

For a short setup:
- A stop may be placed above the resistance zone.
- The next support zone may be used as an initial target.
- A lower support zone may be considered as a secondary target.

Avoid placing the stop exactly on the edge of a zone. Price may briefly move beyond the boundary before reacting. The appropriate buffer depends on the symbol, timeframe, volatility and the trader’s risk plan.

Always calculate the potential risk and reward before entering a trade. A visible zone does not automatically make a setup worth taking.

🔶 Using multiple timeframes

Higher-timeframe zones can provide broader market context, while lower timeframes can help refine entries.

A simple process is:
- Identify important support and resistance on a higher timeframe.
- Determine whether the broader structure is bullish, bearish or ranging.
- Move to the preferred trading timeframe.
- Wait for price to reach a relevant zone.
- Use candle structure, volume or momentum for confirmation.

Higher timeframes generally produce fewer but more widely watched zones. Lower timeframes produce more zones and may contain more market noise.

Support and Resistance Zones help traders identify and manage important price areas with less chart clutter. Its volatility-based sizing, zone merging, break confirmation, role reversal, and alerts make it suitable for different markets and timeframes. Use the zones as areas to watch—not automatic trade signals and always combine them with price confirmation, broader market structure and proper risk management.

We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.

Wedge pattern detector indicator is for educational and analytical purposes only. It is not financial advice. Trading involves risk. Always use proper risk management and combine this indicator with your own analysis before taking any trade.

---

## Source Code

````pine
//@version=6
indicator("Support & Resistance Zones [HexaTrades]", "HexaTrades Support & Resistance Zones", overlay = true, max_boxes_count = 500)

// ─────────────────────────── Inputs ───────────────────────────
grpDet = "Detection"
pivLen      = input.int(10, "Swing Length", minval = 2, group = grpDet, tooltip = "Bars to the left and right that must be lower (for a swing high) or higher (for a swing low). Larger = fewer, more significant zones.")
maxZones    = input.int(10, "Maximum Zones", minval = 1, maxval = 100, group = grpDet, tooltip = "Oldest active zones are removed once this limit is exceeded.")
atrLen      = input.int(14, "ATR Length", minval = 1, group = grpDet)
minHeightAtr = input.float(0.30, "Minimum Zone Height (× ATR)", minval = 0.05, step = 0.05, group = grpDet, tooltip = "If the pivot candle's wick is very small, the zone is padded to this fraction of ATR so it stays visible.")
maxHeightAtr = input.float(1.0, "Maximum Zone Height (× ATR)", minval = 0.2, step = 0.1, group = grpDet, tooltip = "Zones are never taller than this many ATRs. Merged zones are clamped to this height, anchored at the wick side of the level.")
mergeZones  = input.bool(true, "Merge Overlapping Zones", group = grpDet)
proxAtr     = input.float(1.0, "Merge Distance (× ATR)", minval = 0.0, step = 0.05, group = grpDet, tooltip = "Zones closer together than this are treated as the same level and merged, even if they don't strictly overlap. Prevents stacks of near-duplicate boxes.")

grpBrk = "Zone Break"
brkMode    = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = grpBrk, tooltip = "Close: a candle must close beyond the zone. Wick: any poke beyond the zone counts.")
onBreak    = input.string("Keep As Past Zone", "When Broken", options = ["Keep As Past Zone", "Flip Support/Resistance", "Delete Zone"], group = grpBrk, tooltip = "Keep As Past Zone: the zone stops extending and turns into a light box, staying on the chart as history. Flip Support/Resistance: a broken resistance becomes an active support zone (and vice versa) and keeps extending. Delete Zone: broken zones are removed.")
maxPast    = input.int(100, "Maximum Past Zones", minval = 0, maxval = 380, group = grpBrk, tooltip = "How many broken (past) zones to keep on the chart before the oldest are removed. Keep this high so past zones don't silently disappear after volatile moves.")
pastTransp = input.int(85, "Past Zone Transparency", minval = 0, maxval = 100, group = grpBrk, tooltip = "Fill transparency of broken zones — they turn into light borderless boxes. Lower = more solid, 100 = invisible.")

grpVol = "Volume Filter"
useVol  = input.bool(false, "Volume-Confirmed Zones Only", group = grpVol, tooltip = "Only create a zone when the pivot candle's volume is above average. Filters out weak levels. Ignored on symbols without volume data.")
volLen  = input.int(20, "Volume Average Length", minval = 1, group = grpVol)
volMult = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1, group = grpVol, tooltip = "Pivot volume must exceed the volume average × this multiplier.")

grpSty = "Style"
resFill    = input.color(color.new(#e91e63, 78), "Resistance Fill", group = grpSty)
resBorder  = input.color(color.new(#e91e63, 25), "Resistance Border", group = grpSty)
supFill    = input.color(color.new(#2962ff, 78), "Support Fill", group = grpSty)
supBorder  = input.color(color.new(#2962ff, 25), "Support Border", group = grpSty)
extendLast = input.bool(true, "Extend Active Zones To Current Bar", group = grpSty)
showNames  = input.bool(true, "Show Zone Names", group = grpSty)
nameSize   = input.string("Small", "Name Size", options = ["Tiny", "Small", "Normal"], group = grpSty)

// ─────────────────────────── Types ────────────────────────────
type Zone
    box   bx
    float top
    float bot
    bool  isRes
    bool  broken = false

var array<Zone> zones = array.new<Zone>()

atr    = ta.atr(atrLen)
volSma = ta.sma(volume, volLen)

// ─────────────────────── Helpers ──────────────────────────────
txtSize = nameSize == "Tiny" ? size.tiny : nameSize == "Small" ? size.small : size.normal

zoneText(bool isRes) =>
    showNames ? (isRes ? "Resistance" : "Support") : ""

// Fill/border pair for a zone given its role and whether it is a past (broken) zone
zoneColors(bool isRes, bool broken) =>
    fill = isRes ? resFill : supFill
    bord = isRes ? resBorder : supBorder
    if broken
        // Light past-zone look: faint borderless fill
        [color.new(fill, pastTransp), color.new(fill, 100)]
    else
        [fill, bord]

// Remove the oldest zones in the given state (active or past) until at most maxCount remain
pruneZones(bool brokenState, int maxCount) =>
    int count = 0
    for z in zones
        if z.broken == brokenState
            count += 1
    while count > maxCount and array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if z.broken == brokenState
                box.delete(z.bx)
                array.remove(zones, i)
                break
        count -= 1

// ─────────────────────── Zone creation ────────────────────────
addZone(float zTop, float zBot, bool isRes, int leftBar, float refAtr) =>
    // Clamp zone height to the maximum, anchored at the wick extreme
    float t = zTop
    float b = zBot
    maxH   = maxHeightAtr * refAtr
    margin = proxAtr * refAtr
    if t - b > maxH
        if isRes
            b := t - maxH
        else
            t := b + maxH
    merged = false
    if mergeZones and array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            if not z.broken and b <= z.top + margin and t >= z.bot - margin
                // Overlapping or near-touching active zone → merge into one box,
                // clamped at the union's extreme wick (resistance hugs the highest
                // high, support the lowest low) so the level keeps its true edge
                uTop = math.max(z.top, t)
                uBot = math.min(z.bot, b)
                if uTop - uBot > maxH
                    if isRes
                        uBot := uTop - maxH
                    else
                        uTop := uBot + maxH
                // Float guard: accept the merge only if the clamped zone still
                // contains the new swing's wick — otherwise this is a distant
                // level, and merging would leave a box detached from price
                if isRes ? t >= uBot : b <= uTop
                    z.top := uTop
                    z.bot := uBot
                    box.set_top(z.bx, z.top)
                    box.set_bottom(z.bx, z.bot)
                    z.isRes := isRes
                    [fl, bd] = zoneColors(isRes, false)
                    box.set_border_color(z.bx, bd)
                    box.set_bgcolor(z.bx, fl)
                    box.set_text(z.bx, zoneText(isRes))
                    box.set_text_color(z.bx, bd)
                    merged := true
                    break
    if not merged
        [fl, bd] = zoneColors(isRes, false)
        bx = box.new(leftBar, t, bar_index, b, border_color = bd, border_width = 1, bgcolor = fl, text = zoneText(isRes), text_size = txtSize, text_color = bd, text_halign = text.align_right, text_valign = text.align_center)
        array.push(zones, Zone.new(bx, t, b, isRes))
        pruneZones(false, maxZones)
    // Explicit uniform return: the if/else branches above end in different types,
    // which Pine only allows when the if/else is not the function's return value
    true

// ── Pivot detection ──
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

// Volume confirmation for the pivot candle (passes automatically if volume is unavailable)
volOk = not useVol or na(volSma[pivLen]) or volume[pivLen] > volSma[pivLen] * volMult

// ATR as of the swing candle itself, so zone sizing reflects volatility at the pivot
pivAtr = atr[pivLen]

if not na(ph) and volOk and not na(pivAtr)
    zTop = high[pivLen]
    zBot = math.max(open[pivLen], close[pivLen])
    if zTop - zBot < minHeightAtr * pivAtr
        zBot := zTop - minHeightAtr * pivAtr
    addZone(zTop, zBot, true, bar_index - pivLen, pivAtr)

if not na(pl) and volOk and not na(pivAtr)
    zBot = low[pivLen]
    zTop = math.min(open[pivLen], close[pivLen])
    if zTop - zBot < minHeightAtr * pivAtr
        zTop := zBot + minHeightAtr * pivAtr
    addZone(zTop, zBot, false, bar_index - pivLen, pivAtr)

// ─────────────────── Update, extend, break ────────────────────
bool resBrokenNow = false
bool supBrokenNow = false
bool zoneTouchNow = false

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        if i < array.size(zones)
            z = array.get(zones, i)
            if not z.broken
                // "Close" mode only confirms a break once the bar has actually closed,
                // so live bars can't flicker a break/flip that later un-happens
                brkUp = brkMode == "Close" ? (barstate.isconfirmed and close > z.top) : high > z.top
                brkDn = brkMode == "Close" ? (barstate.isconfirmed and close < z.bot) : low < z.bot
                if z.isRes ? brkUp : brkDn
                    resBrokenNow := resBrokenNow or z.isRes
                    supBrokenNow := supBrokenNow or not z.isRes
                    if onBreak == "Delete Zone"
                        box.delete(z.bx)
                        array.remove(zones, i)
                    else if onBreak == "Flip Support/Resistance"
                        // Past resistance becomes support (and vice versa); zone stays active
                        z.isRes := not z.isRes
                        [fl, bd] = zoneColors(z.isRes, false)
                        box.set_bgcolor(z.bx, fl)
                        box.set_border_color(z.bx, bd)
                        box.set_text(z.bx, zoneText(z.isRes))
                        box.set_text_color(z.bx, bd)
                        box.set_right(z.bx, bar_index)
                    else
                        // Keep as light past zone; it stops extending here
                        z.broken := true
                        [fl, bd] = zoneColors(z.isRes, true)
                        box.set_bgcolor(z.bx, fl)
                        box.set_border_color(z.bx, bd)
                        box.set_text_color(z.bx, color.new(z.isRes ? resBorder : supBorder, pastTransp))
                        box.set_right(z.bx, bar_index)
                        pruneZones(true, maxPast)
                else
                    // Touch = price entering the zone from outside, not every bar spent inside it
                    insideNow  = high >= z.bot and low <= z.top
                    insidePrev = high[1] >= z.bot and low[1] <= z.top
                    if insideNow and not insidePrev
                        zoneTouchNow := true
                    if extendLast
                        box.set_right(z.bx, bar_index)

// ─────────────────── Scale anchor ─────────────────────────────
// Invisible plot that ties this script to the symbol's price scale.
// Without any plotted series, TradingView can attach a boxes-only script
// to "No scale", which makes the zones drift away from the candles.
plot(close, "Scale Anchor", color.new(color.gray, 100), editable = false)

// ─────────────────────────── Alerts ───────────────────────────
alertcondition(zoneTouchNow, "Zone Touched", "Price entered a support/resistance zone")
alertcondition(resBrokenNow, "Resistance Broken", "Price broke above a resistance zone")
alertcondition(supBrokenNow, "Support Broken", "Price broke below a support zone")
````
