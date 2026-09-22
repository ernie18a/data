<!-- tradingview-pine-id: PUB;086c342586454ea7aad455119ef3d62a -->
<!-- tradingview-pine-version: 6.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily Futures Wick Levels — Monthly Span V8

Source: https://www.tradingview.com/script/YXjQETci-Daily-Key-Reversal-Levels-ThreeKay/

## Description

# Higher-Timeframe Major Reversal Levels

## Release 1.0

Higher-Timeframe Major Reversal Levels is a TradingView indicator designed to identify prices where the market showed aggressive rejection on an important timeframe. Instead of plotting every pivot, high, or low, it looks for a pronounced wick, a close away from the wick's extreme, and meaningful follow-through in the opposite direction.

The result is a cleaner map of historically important supply, demand, and support/resistance flip levels.

## What the indicator detects

The indicator uses Daily candles by default. Optional 1-hour, 4-hour, weekly, and monthly sources can be enabled in Settings.

A price becomes a candidate level only when a higher-timeframe candle meets all of these conditions:

1. The rejection wick is large compared with the candle body.
2. The wick occupies a meaningful percentage of the candle's total range.
3. The candle closes away from the rejected extreme.
4. Price follows through in the opposite direction by the required ATR distance.

The tip of an upper rejection wick contributes to a supply zone, while the tip of a lower rejection wick contributes to a demand zone. Touches do not need to occur at the exact same tick: nearby wick rejections inside the ATR-sized price range are grouped, and the displayed line uses their average rejected price.

## Main advantages

- **Filters ordinary swing points:** A pivot alone is not enough. The market must demonstrate forceful rejection and follow-through.
- **Uses higher-timeframe structure:** Important 1H through monthly reactions can be viewed while trading on lower chart timeframes.
- **Adapts to volatility:** ATR-based thresholds scale automatically between different markets and price ranges.
- **Tracks repeated respect:** Each separate reaction strengthens the level and increases its line thickness.
- **Identifies role flips:** A level respected from both sides is colored purple, showing that former support became resistance or vice versa.
- **Shows confluence:** Labels identify the source timeframes, such as `[4H D W]`.
- **Reduces chart clutter:** Nearby reactions are consolidated using an ATR-based merge tolerance.
- **Supports alerts:** TradingView can notify you when price approaches a qualified level.

## Reading the chart

- **Green — Demand:** Price aggressively rejected lower prices and reversed upward.
- **Red — Supply:** Price aggressively rejected higher prices and reversed downward.
- **Purple — Flip:** The same area has acted as both support and resistance.
- **`x2`, `x3`, etc.:** Number of separate qualifying reactions recorded near the level.
- **`[1H 4H D]`:** Higher timeframes that confirmed the area.
- **`best 2.40 ATR`:** Largest confirmed move away from the level.

Thicker lines represent levels with more qualifying reactions.

## Recommended setup

1. Open TradingView's Pine Editor.
2. Paste the contents of `Major_Reversal_Levels.pine` into a new indicator.
3. Save the script and select **Add to chart**.
4. Open the indicator's Settings menu.
5. Daily is enabled by default. Enable another source only if you also want its levels displayed universally.
6. Start with the default qualification settings, then adjust strictness for the market being traded.

## Suggested presets

### Balanced — recommended starting point

- Minimum confirming timeframes: `1`
- HTF bars allowed for reversal: `3`
- Minimum reversal move: `1.0 ATR`
- Separate reactions required: `1`
- Level merge tolerance: `0.60 ATR`
- Minimum wick/body ratio: `1.5`

This displays important single-event wick rejections while making repeatedly respected levels visually stronger.

### Strict confluence

- Minimum confirming timeframes: `2`
- Minimum reversal move: `1.5–2.0 ATR`
- Separate reactions required: `2`
- Minimum wick/body ratio: `2.0`
- Wick portion of candle: `0.40–0.50`

Use this when you want fewer levels with stronger historical evidence.

### More sensitive

- Minimum confirming timeframes: `1`
- Minimum reversal move: `0.75 ATR`
- Separate reactions required: `1`
- Minimum wick/body ratio: `1.0`
- Wick portion of candle: `0.30`

This can be useful for markets with smaller candles, but it will produce more levels.

## Settings explained

### Universal timeframe-level visibility

Each toggle controls whether levels detected from that source timeframe are displayed on the chart. For example, enabling Daily and Weekly allows those levels to remain visible while analyzing intraday charts.

**Minimum confirming timeframes** controls timeframe confluence. A value of `1` accepts a level from any enabled source. A value of `2` requires the same price area to be recognized by at least two enabled timeframes.

### Major-level qualification

**HTF bars allowed for reversal** is the number of completed source-timeframe candles used to confirm follow-through after the rejection wick. Increasing it allows slower reversals to qualify but increases confirmation delay.

**Minimum reversal move (ATR)** controls how far price must travel away from the wick before the level is accepted.

**Separate reactions required** determines how many distinct wick-rejection events must occur near the price. Use `1` for major single-event swings or `2–3` for repeatedly defended levels only.

**Level merge tolerance (ATR)** determines how close two rejected prices must be to count as the same area.

**Minimum wick/body ratio** measures the wick relative to the real candle body.

**Wick portion of candle** requires the wick to occupy a minimum percentage of the complete high-to-low range.

**Close away from wick extreme** ensures the candle did not finish near the rejected price.

**Minimum rejection-candle range (ATR)** filters out small candles whose wick may look large only because the body is unusually tiny.

## Alert setup

1. Select **Create Alert** in TradingView.
2. Choose this indicator under Condition.
3. Select **Approaching respected HTF reversal level**.
4. Choose the desired alert frequency and delivery method.

The alert distance is volatility-adjusted using the chart timeframe's ATR. Increase **Alert distance** for earlier warnings or decrease it for tighter notifications.

## Confirmation and repainting behavior

Levels are not accepted immediately when the wick forms. The indicator waits for the selected number of completed higher-timeframe candles to confirm that price genuinely moved away. After confirmation, the line is anchored to the original wick price and time.

This means a newly forming wick will not appear instantly. The delay is intentional and helps prevent weak, unfinished rejections from being labeled as major levels.

## Practical use

Treat the levels as areas of interest rather than automatic entry signals. When price returns to a level, look for confirmation from market structure, volume, momentum, or your normal execution model. Higher reaction counts and multi-timeframe labels indicate stronger historical evidence, but no level is guaranteed to hold.

This indicator is an analytical tool and does not provide financial advice or guarantee trading results.

---

## Source Code

````pine
//@version=6
indicator("Daily Futures Wick Levels — Monthly Span V8", shorttitle="Daily Wicks V8", overlay=true, max_lines_count=20, max_labels_count=20)

groupSource = "Futures source and history"
sourceFutures = input.symbol("", "Continuous futures symbol (blank = chart symbol)", group=groupSource, tooltip="For identical history across users, select the matching continuous contract, such as CME_MINI:NQ1! or CME_MINI:ES1!.")
historyMonths = input.int(60, "Daily wick history span (months)", minval=12, maxval=240, group=groupSource, tooltip="Daily wick touches are analyzed across approximately this many months. Keep this setting identical for every user.")

groupLogic = "Daily wick-level logic"
requiredTouches = input.int(4, "Touches required", minval=2, maxval=12, group=groupLogic)
zoneATR = input.float(0.40, "Touch clustering range (Daily ATR)", minval=0.05, maxval=1.0, step=0.05, group=groupLogic, tooltip="Touches only need to be within the same nearby price area; they do not need to hit the exact price.")
minimumWickRange = input.float(0.15, "Minimum rejection wick portion", minval=0.05, maxval=0.60, step=0.01, group=groupLogic)
minimumReactionATR = input.float(0.25, "Minimum close-away move (Daily ATR)", minval=0.10, maxval=2.0, step=0.05, group=groupLogic, tooltip="The Daily candle must close this far away from its rejected wick tip.")

groupDisplay = "Display"
flipColor = input.color(color.rgb(170, 90, 255), "Flip key-zone color", group=groupDisplay)
supplyColor = input.color(color.rgb(255, 45, 70), "Supply-zone color", group=groupDisplay)
demandColor = input.color(color.rgb(45, 105, 255), "Demand-zone color", group=groupDisplay)
showLabels = input.bool(true, "Show key-level tags", group=groupDisplay)

// This complete database runs in the Daily request context—not on the chart's
// timeframe. A 1-minute chart therefore receives the same results as a 4H chart.
f_dailyDatabase() =>
    var array<float> centers = array.new_float()
    var array<float> radii = array.new_float()
    var array<int> hits = array.new_int()
    var array<int> supplyHits = array.new_int()
    var array<int> demandHits = array.new_int()
    var array<int> lastHit = array.new_int()
    var array<int> firstHit = array.new_int()

    float atr = ta.atr(14)
    float candleRange = math.max(high - low, syminfo.mintick)
    float upperWick = high - math.max(open, close)
    float lowerWick = math.min(open, close) - low

    // request.security() with lookahead_off controls Daily confirmation. Do not
    // use barstate.isconfirmed here; it is not reliable inside requested contexts.
    if not na(atr)
        int existing = array.size(centers)
        if existing > 0
            for i = 0 to existing - 1
                float center = array.get(centers, i)
                float radius = array.get(radii, i)
                bool upperTipNear = math.abs(high - center) <= radius
                bool lowerTipNear = math.abs(low - center) <= radius
                bool rejectDown = upperTipNear and close < center and upperWick >= candleRange * minimumWickRange and high - close >= atr * minimumReactionATR
                bool rejectUp = lowerTipNear and close > center and lowerWick >= candleRange * minimumWickRange and close - low >= atr * minimumReactionATR
                if (rejectDown or rejectUp) and array.get(lastHit, i) != time
                    int oldHits = array.get(hits, i)
                    // Only a wick tip may update the marked price. If both sides
                    // reject on one Daily candle, use the more dominant wick.
                    float tip = rejectDown and rejectUp ? (upperWick >= lowerWick ? high : low) : rejectDown ? high : low
                    array.set(centers, i, (center * oldHits + tip) / (oldHits + 1))
                    array.set(hits, i, oldHits + 1)
                    array.set(supplyHits, i, array.get(supplyHits, i) + (rejectDown ? 1 : 0))
                    array.set(demandHits, i, array.get(demandHits, i) + (rejectUp ? 1 : 0))
                    array.set(lastHit, i, time)

        // Every clear Daily rejection can seed a candidate. Significance comes
        // from four separate touches, not from requiring a rare first candle.
        bool seedSupply = upperWick >= candleRange * minimumWickRange and high - close >= atr * minimumReactionATR
        bool seedDemand = lowerWick >= candleRange * minimumWickRange and close - low >= atr * minimumReactionATR

        if seedSupply or seedDemand
            // The candidate anchor is always the actual Daily high or low.
            float seedPrice = seedSupply and seedDemand ? (upperWick >= lowerWick ? high : low) : seedSupply ? high : low
            bool chosenSupply = seedSupply and (not seedDemand or upperWick >= lowerWick)
            bool chosenDemand = seedDemand and not chosenSupply
            float seedRadius = atr * zoneATR
            int match = -1
            float nearest = 1e20
            int count = array.size(centers)
            if count > 0
                for i = 0 to count - 1
                    float distance = math.abs(array.get(centers, i) - seedPrice)
                    if distance <= math.max(array.get(radii, i), seedRadius) and distance < nearest
                        match := i
                        nearest := distance
            if match >= 0
                if array.get(lastHit, match) != time
                    int oldHits = array.get(hits, match)
                    array.set(centers, match, (array.get(centers, match) * oldHits + seedPrice) / (oldHits + 1))
                    // Keep the cluster tolerance anchored to its original scale.
                    // Letting it expand forever merges unrelated price regions.
                    array.set(radii, match, math.min(array.get(radii, match), seedRadius))
                    array.set(hits, match, oldHits + 1)
                    array.set(supplyHits, match, array.get(supplyHits, match) + (chosenSupply ? 1 : 0))
                    array.set(demandHits, match, array.get(demandHits, match) + (chosenDemand ? 1 : 0))
                    array.set(lastHit, match, time)
            else
                if array.size(centers) >= 500
                    array.shift(centers)
                    array.shift(radii)
                    array.shift(hits)
                    array.shift(supplyHits)
                    array.shift(demandHits)
                    array.shift(lastHit)
                    array.shift(firstHit)
                array.push(centers, seedPrice)
                array.push(radii, seedRadius)
                array.push(hits, 1)
                array.push(supplyHits, chosenSupply ? 1 : 0)
                array.push(demandHits, chosenDemand ? 1 : 0)
                array.push(lastHit, time)
                array.push(firstHit, time)

    // Select six relevant qualifying zones. Proximity to current price wins;
    // additional touches provide a small strength bonus.
    array<int> chosen = array.new_int()
    array<float> outLevel = array.new_float(6, na)
    array<float> outRadius = array.new_float(6, na)
    array<int> outType = array.new_int(6, 0)
    array<int> outHits = array.new_int(6, 0)
    array<int> outFirst = array.new_int(6, 0)
    for slot = 0 to 5
        int bestIndex = -1
        float bestScore = -1e20
        int count = array.size(centers)
        if count > 0
            for i = 0 to count - 1
                int touchCount = array.get(hits, i)
                if touchCount >= requiredTouches and not array.includes(chosen, i)
                    float distanceATR = math.abs(close - array.get(centers, i)) / math.max(atr, syminfo.mintick)
                    float score = math.min(touchCount, 12) * 0.25 - distanceATR
                    if score > bestScore
                        bestScore := score
                        bestIndex := i
        if bestIndex >= 0
            array.push(chosen, bestIndex)
            int supplies = array.get(supplyHits, bestIndex)
            int demands = array.get(demandHits, bestIndex)
            int levelType = supplies > 0 and demands > 0 ? 0 : supplies > 0 ? 1 : -1
            array.set(outLevel, slot, array.get(centers, bestIndex))
            array.set(outRadius, slot, array.get(radii, bestIndex))
            array.set(outType, slot, levelType)
            array.set(outHits, slot, array.get(hits, bestIndex))
            array.set(outFirst, slot, array.get(firstHit, bestIndex))

    int qualifiedCount = 0
    int totalCandidates = array.size(centers)
    if totalCandidates > 0
        for i = 0 to totalCandidates - 1
            qualifiedCount += array.get(hits, i) >= requiredTouches ? 1 : 0

    [array.get(outLevel, 0), array.get(outRadius, 0), array.get(outType, 0), array.get(outHits, 0), array.get(outFirst, 0),
     array.get(outLevel, 1), array.get(outRadius, 1), array.get(outType, 1), array.get(outHits, 1), array.get(outFirst, 1),
     array.get(outLevel, 2), array.get(outRadius, 2), array.get(outType, 2), array.get(outHits, 2), array.get(outFirst, 2),
     array.get(outLevel, 3), array.get(outRadius, 3), array.get(outType, 3), array.get(outHits, 3), array.get(outFirst, 3),
     array.get(outLevel, 4), array.get(outRadius, 4), array.get(outType, 4), array.get(outHits, 4), array.get(outFirst, 4),
     array.get(outLevel, 5), array.get(outRadius, 5), array.get(outType, 5), array.get(outHits, 5), array.get(outFirst, 5),
     totalCandidates, qualifiedCount]

string standardSymbol = sourceFutures == "" ? ticker.standard(syminfo.tickerid) : sourceFutures
int dailyBarsInSpan = math.min(5000, historyMonths * 23 + 50)
[l1,r1,t1,n1,f1,l2,r2,t2,n2,f2,l3,r3,t3,n3,f3,l4,r4,t4,n4,f4,l5,r5,t5,n5,f5,l6,r6,t6,n6,f6,candidateCount,qualifiedCount] = request.security(standardSymbol, "D", f_dailyDatabase(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=dailyBarsInSpan)

f_levelColor(int levelType) =>
    levelType == 0 ? flipColor : levelType == 1 ? supplyColor : demandColor

f_levelText(int levelType, int hitCount, float level) =>
    string role = levelType == 0 ? "FLIP KEY ZONE" : levelType == 1 ? "SUPPLY ZONE" : "DEMAND ZONE"
    role + "  #" + str.tostring(hitCount) + "  " + str.tostring(level, format.mintick)

f_updateLine(line currentLine, float level, int firstTime, int hitCount, int levelType) =>
    line result = currentLine
    if barstate.islast
        if na(level)
            if not na(result)
                line.delete(result)
                result := na
        else
            if na(result)
                result := line.new(firstTime, level, time, level, xloc=xloc.bar_time, extend=extend.right, color=f_levelColor(levelType), width=2)
            line.set_xy1(result, firstTime, level)
            line.set_xy2(result, time, level)
            line.set_color(result, f_levelColor(levelType))
            line.set_width(result, levelType == 0 ? 3 : 2)
    result

f_updateLabel(label currentLabel, float level, int hitCount, int levelType) =>
    label result = currentLabel
    if barstate.islast
        if na(level) or not showLabels
            if not na(result)
                label.delete(result)
                result := na
        else
            string tag = f_levelText(levelType, hitCount, level)
            if na(result)
                result := label.new(time, level, tag, xloc=xloc.bar_time, style=label.style_label_left, color=f_levelColor(levelType), textcolor=color.white, size=size.tiny)
            label.set_xy(result, time, level)
            label.set_text(result, tag)
            label.set_color(result, f_levelColor(levelType))
    result

var line line1 = na
var line line2 = na
var line line3 = na
var line line4 = na
var line line5 = na
var line line6 = na
var label label1 = na
var label label2 = na
var label label3 = na
var label label4 = na
var label label5 = na
var label label6 = na
line1 := f_updateLine(line1,l1,f1,n1,t1)
line2 := f_updateLine(line2,l2,f2,n2,t2)
line3 := f_updateLine(line3,l3,f3,n3,t3)
line4 := f_updateLine(line4,l4,f4,n4,t4)
line5 := f_updateLine(line5,l5,f5,n5,t5)
line6 := f_updateLine(line6,l6,f6,n6,t6)
label1 := f_updateLabel(label1,l1,n1,t1)
label2 := f_updateLabel(label2,l2,n2,t2)
label3 := f_updateLabel(label3,l3,n3,t3)
label4 := f_updateLabel(label4,l4,n4,t4)
label5 := f_updateLabel(label5,l5,n5,t5)
label6 := f_updateLabel(label6,l6,n6,t6)

bool nearLevel = (not na(l1) and math.abs(close-l1)<=r1) or (not na(l2) and math.abs(close-l2)<=r2) or (not na(l3) and math.abs(close-l3)<=r3) or (not na(l4) and math.abs(close-l4)<=r4) or (not na(l5) and math.abs(close-l5)<=r5) or (not na(l6) and math.abs(close-l6)<=r6)
alertcondition(nearLevel and not nearLevel[1], "Price entered a Daily key zone", "{{ticker}} entered a confirmed four-touch Daily key reversal zone near {{close}}.")
````
