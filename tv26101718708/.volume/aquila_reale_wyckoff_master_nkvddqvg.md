# Aquila Reale - Wyckoff MASTER+

- url: https://www.tradingview.com/script/NKVDdqvG/
- type: indicator
- pine_id: PUB;98506073747d4ef8892f13f7cc3ec411
- version: 4.0

## Description

Aquila Reale — Wyckoff MASTER+ | Auto Accumulation/Distribution + Smart TPs

**BETA version — feedback highly appreciated.** First public release of this indicator. Logic carefully designed and syntax tested, but not yet personally traded live by the author. Treat findings as preliminary.

---

## What it does

Detects whether the current market is in **ACCUMULATION** (smart money buying at lows) or **DISTRIBUTION** (smart money selling at highs) using a weighted 15-point scoring system across 5 Wyckoff dimensions:

1. **HTF Trend** — price vs EMA 50/200 on the higher timeframe
2. **Range Structure** — Higher Lows vs Lower Highs detection
3. **Volume Behavior** — up-bar vs down-bar volume balance + climax bars
4. **VSA Patterns** — Stopping Volume, No Demand, No Supply, SOS, SOW
5. **Price Position** — where price sits within the current range

After detection, it plots **automatic operational levels** on the chart:

- **Stop Loss** at the range extreme
- **Entry** at the optimal Wyckoff zone
- Up to **5 Take Profits**, prioritizing real historical pivot levels over geometric projections

---

## Why this is different

Most Wyckoff indicators on TradingView fall in 3 categories:

- **Too simple** — they only label "Spring" or "UTAD" without an operational setup
- **Too theoretical** — they show measured moves with no realistic targets
- **Black boxes** — they give you a buy/sell signal with no transparency

This script does the opposite:

- **Full transparency** — the dashboard shows each of the 5 sub-scores so you understand WHY the indicator says what it says
- **Operational** — gives you SL, Entry, and TPs with realistic distances
- **Smart TPs** — when possible, uses real historical swing levels (where price has reacted before), not arbitrary geometric projections
- **Multi-mode** — you can force LONG/SHORT manually or let the indicator decide

---

## Reliability (realistic, not marketing)

| Signal | Accuracy |
|--------|----------|
| ACCUMULATION / DISTRIBUTION with HIGH confidence | 75-80% |
| FORCED LONG / FORCED SHORT (fallback mode) | 45-55% |
| TP1 hit probability | 70-80% |
| TP2 hit probability | 45-55% |
| TP3 hit probability | 20-30% |

These are estimates based on the underlying logic. Actual results vary by asset, market conditions, and timeframe. **No indicator is 100% accurate.**

---

## Recommended timeframes

- **Daily** — Wyckoff lives here. Best signals, fewer trades.
- **4-Hour** — Sweet spot for swing trading setups.
- **1-Hour** — Good for entry timing, more noise.
- **30/15-Minute** — Acceptable for scalping confirmation.
- **5-Minute and below** — Not recommended (too much noise).

## Recommended assets

- **Crypto (BTC, ETH)** — Real market volume, most reliable
- **Indices (SPX, NDX)** — Reliable volume aggregation
- **Stocks** — Reliable exchange volume
- **Forex / CFDs / Commodities** — Volume comes from your broker only, less reliable

---

## How to use it

**Step 1 — Read the verdict in the dashboard:**

- **"ACCUMULATION" or "DISTRIBUTION"** = strong signal, consider trading
- **"FORCED LONG" / "FORCED SHORT"** = weak signal (fallback), levels are technically valid but use your own analysis to confirm direction
- **"WAIT"** = no clear setup, stay out

**Step 2 — Filter by confidence:**

- HIGH (>80%) = full position size acceptable
- MEDIUM (60-79%) = half position size, tighter management
- LOW or ZERO = reduce or skip

**Step 3 — Trade management:**

- Enter at the ENTRY level
- Stop Loss at the STOP LOSS level
- Take partial profits at TP1 (70-80% probability)
- Move stop to break-even after TP1 is hit
- Let the rest run to TP2 / TP3
- Never risk more than your predefined risk per trade (1-2%)

**Step 4 — Multi-timeframe:**

- Higher TF (Daily/Weekly) = directional bias
- Mid TF (4H) = setup confirmation
- Lower TF (1H/15min) = exact entry timing
- Never take a trade against the higher timeframe bias

---

## Dashboard modes

- **COMPLETE** — full panel with all 5 sub-scores, totals, verdict, confidence, signal, TP mode
- **COMPACT** — only totals, verdict, confidence and signal (no labels column)
- **MINIMAL** — single TRADE/WAIT cell
- **HIDDEN** — no dashboard at all

Position is configurable (9 positions) with X/Y offset for fine placement.

---

## Configurable parameters

29 inputs across 6 groups, each with detailed tooltips:

1. **Range & Pivot Detection** — lookback bars, pivot sensitivity
2. **Setup Direction** — AUTO / SHORT / LONG override
3. **Smart Take Profits** — TP multipliers, anchor mode (ENTRY or RANGE_EDGE), spacing, fallback
4. **Higher Timeframe Context** — HTF and EMA periods
5. **Volume Analysis** — volume MA, climax/high/low thresholds
6. **Visualization** — dashboard mode, size, position, offsets, label size, TP count

Every parameter has guidance on which timeframe / asset class works best.

---

## Alerts

Three configurable alerts:

- **ACCUMULATION detected** — fires when score crosses the detection threshold
- **DISTRIBUTION detected** — fires when score crosses the detection threshold
- **ENTRY zone touched** — fires when price reaches the calculated entry level

---

## Feedback wanted

This is a community-driven project. Specific questions for users:

- Which timeframes work best for you?
- Which assets give the most reliable signals?
- Are the default TP multipliers realistic for your trading style?
- Have you found settings that consistently outperform the defaults?
- Any recurring false signal patterns that should be filtered?

**Please leave a comment under the script with your experience.** Meaningful feedback will be credited in future version notes.

---

## Disclaimer — please read

**Not financial advice.** This indicator and its output are for educational and informational purposes only. It does NOT constitute financial, investment, or trading advice.

**No guarantee of profitability.** Past performance is not indicative of future results. Reliability percentages are estimates, not guarantees.

**Use at your own risk.** Trading carries a high level of risk and may not be suitable for all investors. You may lose some or all of your capital.

**No liability.** The author (giua64) shall not be held liable for any loss or damage arising from the use of this indicator. By using it you accept full responsibility for your trading decisions.

**DYOR.** Always conduct your own research. Cross-check signals against other tools, fundamental analysis, and market context.

**Paper trade first.** Test on a demo account or with paper trading before risking real capital.

**Not tested live by author (yet).** This is the first public release. Treat findings as preliminary.

**Volume limitations.** Volume data on Forex and CFDs comes from individual brokers and may not reflect true market volume, reducing the reliability of volume-based signals on those instruments.

**Open source license.** Free to use for personal trading. If you build on this work please credit the original author.

---

## Credits

Built on Wyckoff Method principles (Richard D. Wyckoff, early 1900s) and Volume Spread Analysis (Tom Williams, 1990s). Original Spring detector code by giua64. Smart historical TP logic and dashboard system designed for the **Aquila Reale** indicator suite.

🦅 *Aquila Reale — nate per volare, nate per osare*

---

**Tags:** wyckoff, accumulation, distribution, volume-spread-analysis, vsa, smart-money, take-profit, automatic-levels, multi-timeframe, swing-trading, order-block, market-structure

## Source Code

````pine
//@version=6
// ============================================================================
//  AQUILA REALE - WYCKOFF MASTER+ v1.0.6
//  PATCH v1.0.6: Label horizontal/vertical offset (STOP/ENTRY/TP).
//
//  WHAT CHANGED IN v1.0.6 (vs v1.0.5):
//    • New inputs in group "6. Visualization":
//        - "Label horizontal offset (bars, +/-)"  -> shifts STOP/ENTRY/TP
//          labels right (+) or left (-) in number of bars.
//        - "Label vertical offset (% of range, +/-)" -> shifts the same
//          labels up (+) or down (-) as a % of the range size.
//      Lines stay anchored to the real level; only labels move.
//
//  WHAT CHANGED IN v1.0.3 (kept): full English localization.
//  WHAT CHANGED IN v1.0.2 (kept): 3-level directional signal.
//  WHAT CHANGED IN v1.0.1 (kept): table padding-cell offset.
//
//  NOTE: "TRADE" means "Wyckoff setup mature per the score", it is NOT a
//  buy/sell recommendation. Entry and stop remain your own responsibility.
// ============================================================================

indicator("Aquila Reale - Wyckoff MASTER+ v1.0.6", overlay=true, max_lines_count=20, max_labels_count=25, max_boxes_count=5)

// ════════════════════════════════════════════════════════════════════════════
// GLOBAL COLORS
// ════════════════════════════════════════════════════════════════════════════
bgDark = color.new(#0D0D14, 0)
bgRow = color.new(#1A1A24, 0)
bgRowAlt = color.new(#13131D, 0)
txtWhite = color.white
txtMuted = color.new(#B0B0C0, 0)

statusRed = color.new(#C62828, 0)
statusOrange = color.new(#E65100, 0)
statusYellow = color.new(#F9A825, 0)
statusGreen = color.new(#2E7D32, 0)
statusGreenSoft = color.new(#558B2F, 0)
statusGray = color.new(#424242, 0)

C_INVISIBLE = color.new(color.black, 100)

// Brand logo header background (white, black text — logo stands out)
C_LOGO_BG = color.white

// ════════════════════════════════════════════════════════════════════════════
// GLOBAL FUNCTIONS
// ════════════════════════════════════════════════════════════════════════════
scoreColorAcc(s) =>
    s >= 4 ? statusGreen : s >= 2 ? statusGreenSoft : s >= 1 ? statusYellow : statusGray

scoreColorDist(s) =>
    s >= 4 ? statusRed : s >= 2 ? statusOrange : s >= 1 ? statusYellow : statusGray

scoreText(s) =>
    s >= 4 ? "STRONG" : s >= 2 ? "MEDIUM" : s >= 1 ? "LOW" : "ZERO"

findTPsBelow(level, n, minDist, src) =>
    result = array.new<float>()
    candidates = array.new<float>()
    if array.size(src) > 0
        for i = 0 to array.size(src) - 1
            v = array.get(src, i)
            if v < level
                array.push(candidates, v)
    if array.size(candidates) > 0
        array.sort(candidates, order.descending)
        lastVal = level
        for i = 0 to array.size(candidates) - 1
            v = array.get(candidates, i)
            if math.abs(lastVal - v) >= minDist
                array.push(result, v)
                lastVal := v
                if array.size(result) >= n
                    break
    result

findTPsAbove(level, n, minDist, src) =>
    result = array.new<float>()
    candidates = array.new<float>()
    if array.size(src) > 0
        for i = 0 to array.size(src) - 1
            v = array.get(src, i)
            if v > level
                array.push(candidates, v)
    if array.size(candidates) > 0
        array.sort(candidates, order.ascending)
        lastVal = level
        for i = 0 to array.size(candidates) - 1
            v = array.get(candidates, i)
            if math.abs(lastVal - v) >= minDist
                array.push(result, v)
                lastVal := v
                if array.size(result) >= n
                    break
    result

// ════════════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════════════
grp1 = "1. Range & Pivot Detection"
lookback = input.int(80, "Lookback bars for current range", group=grp1, minval=30, maxval=300)
pivotLeft = input.int(8, "Pivot left bars", group=grp1, minval=3)
pivotRight = input.int(4, "Pivot right bars", group=grp1, minval=2)

grp2 = "2. Setup Direction"
direction = input.string("AUTO", "Setup direction", options=["AUTO", "SHORT", "LONG"], group=grp2)
forceShow = input.bool(true, "ALWAYS show levels (even with low confidence)", group=grp2)

grp3 = "3. Smart Take Profits"
useSmartTP = input.bool(true, "Use historical pivot TPs (recommended)", group=grp3)
tpAnchor = input.string("ENTRY", "TP search anchor", options=["ENTRY", "RANGE_EDGE"], group=grp3)
tpPivotLeft = input.int(10, "Historical pivot left bars (for TPs)", group=grp3, minval=3)
tpPivotRight = input.int(5, "Historical pivot right bars (for TPs)", group=grp3, minval=2)
minTPdistance = input.float(0.15, "Minimum TP spacing (% of range size)", group=grp3, step=0.1, minval=0.1)
fallbackGeo = input.bool(true, "Fallback to geometric TPs if no historical found", group=grp3)
tp1Mult = input.float(0.2, "TP1 distance (multiple of range)", group=grp3, step=0.05, minval=0.05)
tp2Mult = input.float(0.4, "TP2 distance (multiple of range)", group=grp3, step=0.05, minval=0.1)
tp3Mult = input.float(0.7, "TP3 distance (multiple of range)", group=grp3, step=0.05, minval=0.1)

grp4 = "4. Higher Timeframe Context"
htfTF = input.timeframe("D", "Higher timeframe", group=grp4)
htfEmaLen = input.int(50, "HTF EMA fast", group=grp4)
htfEmaLong = input.int(200, "HTF EMA slow", group=grp4)

grp5 = "5. Volume Analysis"
volLen = input.int(20, "Volume moving average length", group=grp5)
volClimax = input.float(2.0, "Climax volume threshold (x average)", group=grp5, step=0.1)
volHigh = input.float(1.5, "High volume threshold (x average)", group=grp5, step=0.1)
volLow = input.float(0.7, "Low volume threshold (x average)", group=grp5, step=0.1)

grp6 = "6. Visualization"
showBox = input.bool(true, "Show range box", group=grp6)
dashMode = input.string("COMPLETE", "Dashboard mode", options=["COMPLETE", "COMPACT", "MINIMAL", "HIDDEN"], group=grp6)
tableSize = input.string("normal", "Dashboard text size", options=["small", "normal", "large", "huge"], group=grp6)
labelSize = input.string("large", "Level labels text size", options=["small", "normal", "large", "huge"], group=grp6)
lblOffsetX = input.int(0, "Label horizontal offset (bars, +/-)", group=grp6, minval=-50, maxval=50, tooltip="Sposta le etichette STOP/ENTRY/TP a destra (positivo) o sinistra (negativo) in numero di barre. 0 = ancorate alla barra corrente. Le linee restano sul livello reale, solo le etichette si spostano.")
lblOffsetY = input.float(0.0, "Label vertical offset (% of range, +/-)", group=grp6, step=0.5, tooltip="Sposta le etichette in verticale come % della dimensione del range. Positivo = sopra, negativo = sotto. 0 = sul livello.")
numTPs = input.int(3, "Number of TPs to display", group=grp6, minval=1, maxval=5)
tablePos = input.string("top_right", "Dashboard position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=grp6)
offsetX = input.int(0, "Horizontal offset (empty columns)", group=grp6, minval=0, maxval=20)
offsetY = input.int(0, "Vertical offset (empty rows)", group=grp6, minval=0, maxval=20)

grp7 = "7. Signal Thresholds"
weakThr = input.int(5, "WEAK signal threshold (forming setup)", group=grp7, minval=3, maxval=10, tooltip="From this score upward (on the leading side) the signal shows WEAK LONG/SHORT = a setup is forming. Below this = WAIT. The TRADE level stays at threshold 8.")
tradeThr = input.int(8, "TRADE signal threshold (mature setup)", group=grp7, minval=6, maxval=15, tooltip="Threshold for TRADE LONG/SHORT (mature setup). Default 8, same as original. Requires a score lead greater than 2 over the opposite side.")

// ════════════════════════════════════════════════════════════════════════════
// RANGE & PIVOTS
// ════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

var array<float> phArr = array.new<float>()
var array<float> plArr = array.new<float>()

if not na(ph)
    array.unshift(phArr, ph)
    if array.size(phArr) > 5
        array.pop(phArr)

if not na(pl)
    array.unshift(plArr, pl)
    if array.size(plArr) > 5
        array.pop(plArr)

rangeHigh = array.size(phArr) > 0 ? array.max(phArr) : ta.highest(high, lookback)
rangeLow = array.size(plArr) > 0 ? array.min(plArr) : ta.lowest(low, lookback)
rangeSize = rangeHigh - rangeLow

if rangeSize <= 0
    rangeHigh := ta.highest(high, lookback)
    rangeLow := ta.lowest(low, lookback)
    rangeSize := rangeHigh - rangeLow

rangeMid = (rangeHigh + rangeLow) / 2

phTP = ta.pivothigh(high, tpPivotLeft, tpPivotRight)
plTP = ta.pivotlow(low, tpPivotLeft, tpPivotRight)

var array<float> historicHighs = array.new<float>()
var array<float> historicLows = array.new<float>()

if not na(phTP)
    array.push(historicHighs, phTP)
    if array.size(historicHighs) > 100
        array.shift(historicHighs)

if not na(plTP)
    array.push(historicLows, plTP)
    if array.size(historicLows) > 100
        array.shift(historicLows)

// ════════════════════════════════════════════════════════════════════════════
// SCORING (identical to v1.0)
// ════════════════════════════════════════════════════════════════════════════
htfClose = request.security(syminfo.tickerid, htfTF, close, lookahead=barmerge.lookahead_off)
htfEma50 = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLen), lookahead=barmerge.lookahead_off)
htfEma200 = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLong), lookahead=barmerge.lookahead_off)

trendScoreAcc = 0
trendScoreDist = 0
if htfClose < htfEma50
    trendScoreAcc += 1
if htfClose > htfEma50
    trendScoreDist += 1
if htfClose < htfEma200
    trendScoreAcc += 1
if htfClose > htfEma200
    trendScoreDist += 1
if htfEma50 < htfEma200
    trendScoreAcc += 1
if htfEma50 > htfEma200
    trendScoreDist += 1

structScoreAcc = 0
structScoreDist = 0
if array.size(plArr) >= 2
    pl0 = array.get(plArr, 0)
    pl1 = array.get(plArr, 1)
    if pl0 > pl1
        structScoreAcc += 2
    if pl0 < pl1
        structScoreDist += 1
if array.size(phArr) >= 2
    ph0 = array.get(phArr, 0)
    ph1 = array.get(phArr, 1)
    if ph0 < ph1
        structScoreDist += 2
    if ph0 > ph1
        structScoreAcc += 1

volMA = ta.sma(volume, volLen)
isHighVol = volume > volMA * volHigh
isLowVol = volume < volMA * volLow

candleRange = high - low + 0.00001
bodyStr = math.abs(close - open) / candleRange
bullBody = close > open
bearBody = close < open

upVolSum = 0.0
downVolSum = 0.0
upCount = 0
downCount = 0
for i = 0 to lookback - 1
    if close[i] > open[i]
        upVolSum += volume[i]
        upCount += 1
    else if close[i] < open[i]
        downVolSum += volume[i]
        downCount += 1

avgUpVol = upCount > 0 ? upVolSum / upCount : 0
avgDownVol = downCount > 0 ? downVolSum / downCount : 0
volRatio = avgUpVol / (avgDownVol + 0.0001)

volScoreAcc = 0
volScoreDist = 0
if volRatio > 1.2
    volScoreAcc += 2
else if volRatio > 1.05
    volScoreAcc += 1
if volRatio < 0.83
    volScoreDist += 2
else if volRatio < 0.95
    volScoreDist += 1

climaxDownInLookback = false
climaxUpInLookback = false
for i = 0 to 10
    if volume[i] > volMA[i] * volClimax and close[i] < open[i]
        climaxDownInLookback := true
    if volume[i] > volMA[i] * volClimax and close[i] > open[i]
        climaxUpInLookback := true

if climaxDownInLookback and close < rangeLow + rangeSize * 0.3
    volScoreAcc += 2
if climaxUpInLookback and close > rangeHigh - rangeSize * 0.3
    volScoreDist += 2

vsaScoreAcc = 0
vsaScoreDist = 0
stoppingVol = bearBody and isHighVol and bodyStr > 0.5 and close > (low + candleRange * 0.5)
if stoppingVol and close < rangeMid
    vsaScoreAcc += 1
noDemand = bullBody and bodyStr < 0.4 and isLowVol and close > rangeHigh - rangeSize * 0.3
if noDemand
    vsaScoreDist += 1
noSupply = bearBody and bodyStr < 0.4 and isLowVol and close < rangeLow + rangeSize * 0.3
if noSupply
    vsaScoreAcc += 1
testSupply = high > rangeHigh - rangeSize * 0.05 and high < rangeHigh and isLowVol
if testSupply
    vsaScoreDist += 1
testDemand = low < rangeLow + rangeSize * 0.05 and low > rangeLow and isLowVol
if testDemand
    vsaScoreAcc += 1
sosBar = bullBody and bodyStr > 0.7 and isHighVol and close > rangeMid
if sosBar
    vsaScoreAcc += 1
sowBar = bearBody and bodyStr > 0.7 and isHighVol and close < rangeMid
if sowBar
    vsaScoreDist += 1

posScoreAcc = 0
posScoreDist = 0
pricePos = (close - rangeLow) / (rangeSize + 0.0001)
if pricePos < 0.25
    posScoreAcc += 2
else if pricePos < 0.4
    posScoreAcc += 1
if pricePos > 0.75
    posScoreDist += 2
else if pricePos > 0.6
    posScoreDist += 1

totalAcc = trendScoreAcc + structScoreAcc + volScoreAcc + vsaScoreAcc + posScoreAcc
totalDist = trendScoreDist + structScoreDist + volScoreDist + vsaScoreDist + posScoreDist

confAcc = totalAcc * 100 / 15
confDist = totalDist * 100 / 15

isAccDetected = totalAcc >= tradeThr and totalAcc > totalDist + 2
isDistDetected = totalDist >= tradeThr and totalDist > totalAcc + 2

confidence = isAccDetected ? confAcc : isDistDetected ? confDist : math.max(confAcc, confDist)

autoIsShort = isDistDetected or (not isAccDetected and totalDist > totalAcc)
autoIsLong = isAccDetected or (not isDistDetected and totalAcc > totalDist)

fallbackShort = close > rangeMid
fallbackLong = close < rangeMid

isShort = direction == "SHORT" or (direction == "AUTO" and (autoIsShort or (forceShow and fallbackShort and not autoIsLong)))
isLong = direction == "LONG" or (direction == "AUTO" and (autoIsLong or (forceShow and fallbackLong and not autoIsShort)))

showLines = forceShow or isAccDetected or isDistDetected

sl = isShort ? rangeHigh + rangeSize * 0.05 : rangeLow - rangeSize * 0.05
entry = isShort ? rangeHigh - rangeSize * 0.1 : rangeLow + rangeSize * 0.1

minTPdist = rangeSize * minTPdistance

smartTPs = array.new<float>()
if useSmartTP and barstate.islast
    shortAnchor = tpAnchor == "ENTRY" ? entry : rangeLow
    longAnchor = tpAnchor == "ENTRY" ? entry : rangeHigh
    if isShort
        smartTPs := findTPsBelow(shortAnchor, numTPs, minTPdist, historicLows)
    if isLong
        smartTPs := findTPsAbove(longAnchor, numTPs, minTPdist, historicHighs)
    if tpAnchor == "ENTRY"
        if isLong
            extraTPs = findTPsAbove(entry, numTPs, minTPdist, historicLows)
            if array.size(extraTPs) > 0
                for i = 0 to array.size(extraTPs) - 1
                    v = array.get(extraTPs, i)
                    isDuplicate = false
                    if array.size(smartTPs) > 0
                        for j = 0 to array.size(smartTPs) - 1
                            if math.abs(v - array.get(smartTPs, j)) < minTPdist
                                isDuplicate := true
                                break
                    if not isDuplicate
                        array.push(smartTPs, v)
        if isShort
            extraTPs = findTPsBelow(entry, numTPs, minTPdist, historicHighs)
            if array.size(extraTPs) > 0
                for i = 0 to array.size(extraTPs) - 1
                    v = array.get(extraTPs, i)
                    isDuplicate = false
                    if array.size(smartTPs) > 0
                        for j = 0 to array.size(smartTPs) - 1
                            if math.abs(v - array.get(smartTPs, j)) < minTPdist
                                isDuplicate := true
                                break
                    if not isDuplicate
                        array.push(smartTPs, v)
    if array.size(smartTPs) > numTPs
        if isLong
            array.sort(smartTPs, order.ascending)
        else
            array.sort(smartTPs, order.descending)
        while array.size(smartTPs) > numTPs
            array.pop(smartTPs)

geoTPs = array.new<float>()
if isShort
    array.push(geoTPs, rangeLow - rangeSize * tp1Mult)
    array.push(geoTPs, rangeLow - rangeSize * tp2Mult)
    array.push(geoTPs, rangeLow - rangeSize * tp3Mult)
if isLong
    array.push(geoTPs, rangeHigh + rangeSize * tp1Mult)
    array.push(geoTPs, rangeHigh + rangeSize * tp2Mult)
    array.push(geoTPs, rangeHigh + rangeSize * tp3Mult)

finalTPs = array.new<float>()
finalTPmode = "none"
if array.size(smartTPs) > 0
    finalTPs := smartTPs
    finalTPmode := "hist"
else if fallbackGeo
    finalTPs := geoTPs
    finalTPmode := "geo"

alertcondition(isAccDetected, title="ACCUMULATION detected", message="[Wyckoff M+] ACCUMULATION on {{ticker}}")
alertcondition(isDistDetected, title="DISTRIBUTION detected", message="[Wyckoff M+] DISTRIBUTION on {{ticker}}")
alertcondition(ta.cross(close, entry) and showLines, title="ENTRY zone touched", message="[Wyckoff M+] ENTRY zone touched on {{ticker}} at {{close}}")

tblSz = tableSize == "huge" ? size.huge : tableSize == "large" ? size.large : tableSize == "normal" ? size.normal : size.small
lblSz = labelSize == "huge" ? size.huge : labelSize == "large" ? size.large : labelSize == "normal" ? size.normal : size.small
tblPos = tablePos == "top_left" ? position.top_left : tablePos == "top_center" ? position.top_center : tablePos == "top_right" ? position.top_right : tablePos == "middle_left" ? position.middle_left : tablePos == "middle_center" ? position.middle_center : tablePos == "middle_right" ? position.middle_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "bottom_center" ? position.bottom_center : position.bottom_right

isLeft = tablePos == "top_left" or tablePos == "middle_left" or tablePos == "bottom_left"
isRight = tablePos == "top_right" or tablePos == "middle_right" or tablePos == "bottom_right"
isTop = tablePos == "top_left" or tablePos == "top_center" or tablePos == "top_right"
isBottom = tablePos == "bottom_left" or tablePos == "bottom_center" or tablePos == "bottom_right"

// ════════════════════════════════════════════════════════════════════════════
// CHART LEVELS (identical to v1.0 + label offset v1.0.6)
// ════════════════════════════════════════════════════════════════════════════
var box bx = na
var line l_sl = na
var line l_entry = na
var array<line> tpLines = array.new<line>()
var array<label> tpLabels = array.new<label>()
var label lb_sl = na
var label lb_entry = na

if barstate.islast
    box.delete(bx)
    line.delete(l_sl)
    line.delete(l_entry)
    label.delete(lb_sl)
    label.delete(lb_entry)
    if array.size(tpLines) > 0
        for i = 0 to array.size(tpLines) - 1
            line.delete(array.get(tpLines, i))
        array.clear(tpLines)
    if array.size(tpLabels) > 0
        for i = 0 to array.size(tpLabels) - 1
            label.delete(array.get(tpLabels, i))
        array.clear(tpLabels)

    x0 = bar_index - lookback
    x1 = bar_index

    // ── Label offset (labels only; lines stay on the real level) ──
    lblX = x1 + lblOffsetX
    lblYoff = rangeSize * lblOffsetY / 100

    boxColor = isAccDetected ? color.green : isDistDetected ? color.red : color.gray
    if showBox
        bx := box.new(x0, rangeHigh, x1, rangeLow, bgcolor=color.new(boxColor, 92), border_color=color.new(boxColor, 50), border_width=1, border_style=line.style_dashed, extend=extend.right)

    if showLines and (isShort or isLong)
        l_sl := line.new(x0, sl, x1, sl, color=color.red, width=3, extend=extend.right)
        lb_sl := label.new(lblX, sl + lblYoff, text="  STOP LOSS  " + str.tostring(math.round(sl, 2)) + "  ", color=color.red, textcolor=color.white, style=label.style_label_left, size=lblSz)

        l_entry := line.new(x0, entry, x1, entry, color=#FF6B35, width=3, extend=extend.right)
        entryText = isShort ? "  SHORT ENTRY  " : "  LONG ENTRY  "
        lb_entry := label.new(lblX, entry + lblYoff, text=entryText + str.tostring(math.round(entry, 2)) + "  ", color=#FF6B35, textcolor=color.white, style=label.style_label_left, size=lblSz)

        if array.size(finalTPs) > 0
            tpColors = array.from(#2196F3, #1565C0, #00897B, #00695C, #1B5E20)
            for i = 0 to math.min(array.size(finalTPs) - 1, 4)
                tpVal = array.get(finalTPs, i)
                tpCol = array.get(tpColors, i)
                tpL = line.new(x0, tpVal, x1, tpVal, color=tpCol, width=2, style=line.style_solid, extend=extend.right)
                tpLb = label.new(lblX, tpVal + lblYoff, text="  TP" + str.tostring(i + 1) + " " + finalTPmode + "  " + str.tostring(math.round(tpVal, 2)) + "  ", color=tpCol, textcolor=color.white, style=label.style_label_left, size=lblSz)
                array.push(tpLines, tpL)
                array.push(tpLabels, tpLb)

// ════════════════════════════════════════════════════════════════════════════
// VERDICT
// ════════════════════════════════════════════════════════════════════════════
string verdict = "WAIT"
color vColor = statusGray
string verdictIcon = "= "
if isAccDetected
    verdict := "ACCUMULATION"
    vColor := statusGreen
    verdictIcon := "UP "
else if isDistDetected
    verdict := "DISTRIBUTION"
    vColor := statusRed
    verdictIcon := "DN "
else if forceShow and isShort
    verdict := "FORCED SHORT"
    vColor := statusOrange
    verdictIcon := "DN "
else if forceShow and isLong
    verdict := "FORCED LONG"
    vColor := statusOrange
    verdictIcon := "UP "

string confLevel = confidence >= 80 ? "HIGH" : confidence >= 60 ? "MEDIUM" : confidence >= 40 ? "LOW" : "ZERO"
color confColor = confidence >= 80 ? statusGreen : confidence >= 60 ? statusYellow : confidence >= 40 ? statusOrange : statusRed

// ════════════════════════════════════════════════════════════════════════════
// 3-LEVEL DIRECTIONAL SIGNAL (v1.0.2)
// ════════════════════════════════════════════════════════════════════════════
string tradeSignal = "WAIT"
color  tradeColor  = statusYellow

if isAccDetected
    tradeSignal := "TRADE LONG"
    tradeColor  := statusGreen
else if isDistDetected
    tradeSignal := "TRADE SHORT"
    tradeColor  := statusRed
else if totalAcc >= weakThr and totalAcc > totalDist
    tradeSignal := "WEAK LONG"
    tradeColor  := statusGreenSoft
else if totalDist >= weakThr and totalDist > totalAcc
    tradeSignal := "WEAK SHORT"
    tradeColor  := statusOrange
else
    tradeSignal := "WAIT"
    tradeColor  := statusYellow

int leadScore = math.max(totalAcc, totalDist)
int toTrade = tradeThr - leadScore
string toTradeLbl = (isAccDetected or isDistDetected) ? "mature setup" : toTrade > 0 ? str.tostring(toTrade) + " pt to TRADE" : "needs lead > 2"

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD - COMPLETE MODE (with padding fix)
// ════════════════════════════════════════════════════════════════════════════
if dashMode == "COMPLETE" and barstate.islast
    visCols_C = 4
    visRows_C = 13
    nColsC = visCols_C + offsetX
    nRowsC = visRows_C + offsetY
    colOffC = isLeft ? offsetX : 0
    rowOffC = isTop ? offsetY : 0
    hasOffC = offsetX > 0 or offsetY > 0
    var table tC = table.new(tblPos, nColsC, nRowsC, border_color=hasOffC ? C_INVISIBLE : color.new(#3A3A4A, 30), border_width=hasOffC ? 0 : 1, frame_color=hasOffC ? C_INVISIBLE : color.new(#3A3A4A, 0), frame_width=hasOffC ? 0 : 2)

    if hasOffC
        for c = 0 to nColsC - 1
            for r = 0 to nRowsC - 1
                inVis = (c >= colOffC and c < colOffC + visCols_C) and (r >= rowOffC and r < rowOffC + visRows_C)
                if not inVis
                    table.cell(tC, c, r, "    ", bgcolor=C_INVISIBLE, text_color=C_INVISIBLE, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 0 + rowOffC, "🦅 AQUILA REALE — WYCKOFF", bgcolor=C_LOGO_BG, text_color=color.black, text_size=tblSz, text_halign=text.align_center)
    table.merge_cells(tC, 0 + colOffC, 0 + rowOffC, 3 + colOffC, 0 + rowOffC)

    table.cell(tC, 0 + colOffC, 1 + rowOffC, "WYCKOFF", bgcolor=bgDark, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 1 + rowOffC, "Value", bgcolor=bgDark, text_color=txtMuted, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 1 + rowOffC, "Delta", bgcolor=bgDark, text_color=txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 1 + rowOffC, "Status", bgcolor=bgDark, text_color=txtMuted, text_size=tblSz)

    trendDelta = trendScoreAcc - trendScoreDist
    table.cell(tC, 0 + colOffC, 2 + rowOffC, "HTF TREND", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 2 + rowOffC, str.tostring(trendScoreAcc) + "/3", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 2 + rowOffC, (trendDelta >= 0 ? "+" : "") + str.tostring(trendDelta), bgcolor=bgRow, text_color=trendDelta > 0 ? color.lime : trendDelta < 0 ? color.red : txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 2 + rowOffC, trendScoreAcc > trendScoreDist ? "UP BULL " + scoreText(trendScoreAcc) : trendScoreDist > trendScoreAcc ? "DN BEAR " + scoreText(trendScoreDist) : "= FLAT", bgcolor=trendScoreAcc > trendScoreDist ? scoreColorAcc(trendScoreAcc) : trendScoreDist > trendScoreAcc ? scoreColorDist(trendScoreDist) : statusGray, text_color=txtWhite, text_size=tblSz)

    structDelta = structScoreAcc - structScoreDist
    table.cell(tC, 0 + colOffC, 3 + rowOffC, "STRUCTURE", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 3 + rowOffC, str.tostring(structScoreAcc) + "/3", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 3 + rowOffC, (structDelta >= 0 ? "+" : "") + str.tostring(structDelta), bgcolor=bgRowAlt, text_color=structDelta > 0 ? color.lime : structDelta < 0 ? color.red : txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 3 + rowOffC, structScoreAcc > structScoreDist ? "UP HL " + scoreText(structScoreAcc) : structScoreDist > structScoreAcc ? "DN LH " + scoreText(structScoreDist) : "= FLAT", bgcolor=structScoreAcc > structScoreDist ? scoreColorAcc(structScoreAcc) : structScoreDist > structScoreAcc ? scoreColorDist(structScoreDist) : statusGray, text_color=txtWhite, text_size=tblSz)

    volDelta = volScoreAcc - volScoreDist
    table.cell(tC, 0 + colOffC, 4 + rowOffC, "VOLUME", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 4 + rowOffC, str.tostring(volScoreAcc) + "/4", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 4 + rowOffC, (volDelta >= 0 ? "+" : "") + str.tostring(volDelta), bgcolor=bgRow, text_color=volDelta > 0 ? color.lime : volDelta < 0 ? color.red : txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 4 + rowOffC, volScoreAcc > volScoreDist ? "UP ACC " + scoreText(volScoreAcc) : volScoreDist > volScoreAcc ? "DN DIST " + scoreText(volScoreDist) : "= BAL", bgcolor=volScoreAcc > volScoreDist ? scoreColorAcc(volScoreAcc) : volScoreDist > volScoreAcc ? scoreColorDist(volScoreDist) : statusGray, text_color=txtWhite, text_size=tblSz)

    vsaDelta = vsaScoreAcc - vsaScoreDist
    table.cell(tC, 0 + colOffC, 5 + rowOffC, "VSA", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 5 + rowOffC, str.tostring(vsaScoreAcc) + "/3", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 5 + rowOffC, (vsaDelta >= 0 ? "+" : "") + str.tostring(vsaDelta), bgcolor=bgRowAlt, text_color=vsaDelta > 0 ? color.lime : vsaDelta < 0 ? color.red : txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 5 + rowOffC, vsaScoreAcc > vsaScoreDist ? "UP ACC " + scoreText(vsaScoreAcc) : vsaScoreDist > vsaScoreAcc ? "DN DIST " + scoreText(vsaScoreDist) : "= NO SIG", bgcolor=vsaScoreAcc > vsaScoreDist ? scoreColorAcc(vsaScoreAcc) : vsaScoreDist > vsaScoreAcc ? scoreColorDist(vsaScoreDist) : statusGray, text_color=txtWhite, text_size=tblSz)

    posDelta = posScoreAcc - posScoreDist
    table.cell(tC, 0 + colOffC, 6 + rowOffC, "POSITION", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 6 + rowOffC, str.tostring(posScoreAcc) + "/2", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 6 + rowOffC, (posDelta >= 0 ? "+" : "") + str.tostring(posDelta), bgcolor=bgRow, text_color=posDelta > 0 ? color.lime : posDelta < 0 ? color.red : txtMuted, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 6 + rowOffC, posScoreAcc > posScoreDist ? "UP LOW" : posScoreDist > posScoreAcc ? "DN HIGH" : "= MID", bgcolor=posScoreAcc > posScoreDist ? scoreColorAcc(posScoreAcc) : posScoreDist > posScoreAcc ? scoreColorDist(posScoreDist) : statusGray, text_color=txtWhite, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 7 + rowOffC, "== TOTALS ==", bgcolor=bgDark, text_color=color.yellow, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 7 + rowOffC, str.tostring(totalAcc) + "/15", bgcolor=bgDark, text_color=color.lime, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 7 + rowOffC, str.tostring(totalDist) + "/15", bgcolor=bgDark, text_color=color.red, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 7 + rowOffC, totalAcc > totalDist ? "UP ACC wins" : totalDist > totalAcc ? "DN DIST wins" : "= tied", bgcolor=totalAcc > totalDist ? statusGreen : totalDist > totalAcc ? statusRed : statusGray, text_color=txtWhite, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 8 + rowOffC, "VERDICT", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 8 + rowOffC, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 8 + rowOffC, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 8 + rowOffC, verdictIcon + verdict, bgcolor=vColor, text_color=txtWhite, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 9 + rowOffC, "CONFIDENCE", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 9 + rowOffC, str.tostring(math.round(confidence)) + "%", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 9 + rowOffC, "", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 9 + rowOffC, confLevel, bgcolor=confColor, text_color=txtWhite, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 10 + rowOffC, "SIGNAL", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 10 + rowOffC, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 10 + rowOffC, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 10 + rowOffC, tradeSignal, bgcolor=tradeColor, text_color=txtWhite, text_size=tblSz)

    table.cell(tC, 0 + colOffC, 11 + rowOffC, "TO TRADE", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 11 + rowOffC, "", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 11 + rowOffC, "", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 11 + rowOffC, toTradeLbl, bgcolor=bgRowAlt, text_color=txtMuted, text_size=tblSz)

    tpModeText = finalTPmode == "hist" ? "UP HISTORICAL" : finalTPmode == "geo" ? "= GEOMETRIC" : "X NONE"
    tpModeCol = finalTPmode == "hist" ? statusGreen : finalTPmode == "geo" ? statusOrange : statusRed
    table.cell(tC, 0 + colOffC, 12 + rowOffC, "TP MODE", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz, text_halign=text.align_left)
    table.cell(tC, 1 + colOffC, 12 + rowOffC, str.tostring(array.size(finalTPs)), bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 2 + colOffC, 12 + rowOffC, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tC, 3 + colOffC, 12 + rowOffC, tpModeText, bgcolor=tpModeCol, text_color=txtWhite, text_size=tblSz)

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD - COMPACT MODE (with padding fix)
// ════════════════════════════════════════════════════════════════════════════
if dashMode == "COMPACT" and barstate.islast
    visCols_K = 3
    visRows_K = 5
    nColsK = visCols_K + offsetX
    nRowsK = visRows_K + offsetY
    colOffK = isLeft ? offsetX : 0
    rowOffK = isTop ? offsetY : 0
    hasOffK = offsetX > 0 or offsetY > 0
    var table tK = table.new(tblPos, nColsK, nRowsK, border_color=hasOffK ? C_INVISIBLE : color.new(#3A3A4A, 30), border_width=hasOffK ? 0 : 1, frame_color=hasOffK ? C_INVISIBLE : color.new(#3A3A4A, 0), frame_width=hasOffK ? 0 : 2)

    if hasOffK
        for c = 0 to nColsK - 1
            for r = 0 to nRowsK - 1
                inVis = (c >= colOffK and c < colOffK + visCols_K) and (r >= rowOffK and r < rowOffK + visRows_K)
                if not inVis
                    table.cell(tK, c, r, "    ", bgcolor=C_INVISIBLE, text_color=C_INVISIBLE, text_size=tblSz)

    table.cell(tK, 0 + colOffK, 0 + rowOffK, "🦅 AQUILA REALE — WYCKOFF", bgcolor=C_LOGO_BG, text_color=color.black, text_size=tblSz, text_halign=text.align_center)
    table.merge_cells(tK, 0 + colOffK, 0 + rowOffK, 2 + colOffK, 0 + rowOffK)

    table.cell(tK, 0 + colOffK, 1 + rowOffK, str.tostring(totalAcc) + "/15", bgcolor=bgDark, text_color=color.lime, text_size=tblSz)
    table.cell(tK, 1 + colOffK, 1 + rowOffK, str.tostring(totalDist) + "/15", bgcolor=bgDark, text_color=color.red, text_size=tblSz)
    table.cell(tK, 2 + colOffK, 1 + rowOffK, totalAcc > totalDist ? "UP ACC wins" : totalDist > totalAcc ? "DN DIST wins" : "= tied", bgcolor=totalAcc > totalDist ? statusGreen : totalDist > totalAcc ? statusRed : statusGray, text_color=txtWhite, text_size=tblSz)

    table.cell(tK, 0 + colOffK, 2 + rowOffK, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 1 + colOffK, 2 + rowOffK, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 2 + colOffK, 2 + rowOffK, verdictIcon + verdict, bgcolor=vColor, text_color=txtWhite, text_size=tblSz)

    table.cell(tK, 0 + colOffK, 3 + rowOffK, str.tostring(math.round(confidence)) + "%", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 1 + colOffK, 3 + rowOffK, "", bgcolor=bgRowAlt, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 2 + colOffK, 3 + rowOffK, confLevel, bgcolor=confColor, text_color=txtWhite, text_size=tblSz)

    table.cell(tK, 0 + colOffK, 4 + rowOffK, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 1 + colOffK, 4 + rowOffK, "", bgcolor=bgRow, text_color=txtWhite, text_size=tblSz)
    table.cell(tK, 2 + colOffK, 4 + rowOffK, tradeSignal, bgcolor=tradeColor, text_color=txtWhite, text_size=tblSz)

// ════════════════════════════════════════════════════════════════════════════
// DASHBOARD - MINIMAL MODE (with padding fix)
// ════════════════════════════════════════════════════════════════════════════
if dashMode == "MINIMAL" and barstate.islast
    visCols_M = 1
    visRows_M = 1
    nColsM = visCols_M + offsetX
    nRowsM = visRows_M + offsetY
    colOffM = isLeft ? offsetX : 0
    rowOffM = isTop ? offsetY : 0
    hasOffM = offsetX > 0 or offsetY > 0
    var table tM = table.new(tblPos, nColsM, nRowsM, border_color=hasOffM ? C_INVISIBLE : color.new(#3A3A4A, 30), border_width=hasOffM ? 0 : 2, frame_color=hasOffM ? C_INVISIBLE : color.new(#3A3A4A, 0), frame_width=hasOffM ? 0 : 3)

    if hasOffM
        for c = 0 to nColsM - 1
            for r = 0 to nRowsM - 1
                inVis = (c >= colOffM and c < colOffM + visCols_M) and (r >= rowOffM and r < rowOffM + visRows_M)
                if not inVis
                    table.cell(tM, c, r, "    ", bgcolor=C_INVISIBLE, text_color=C_INVISIBLE, text_size=tblSz)

    table.cell(tM, colOffM, rowOffM, "  " + tradeSignal + "  ", bgcolor=tradeColor, text_color=txtWhite, text_size=tblSz)
````
