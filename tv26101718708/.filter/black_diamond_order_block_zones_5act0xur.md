# Black Diamond - Order Block Zones

- url: https://www.tradingview.com/script/5act0XUr-Black-Diamond-Order-Block-Zones/
- type: indicator
- pine_id: PUB;282aecc1082b413b99443f5e3663f13a
- version: 1.0

## Description

OVERVIEW

Black Diamond Order Block Elite V5 is an advanced institutional order block indicator designed to identify high-probability bullish and bearish order blocks using genuine market structure breaks (BOS), order flow, and smart order block detection.

Unlike many order block indicators that simply mark random bullish and bearish candles, Black Diamond Order Block Elite V5 identifies the final opposing candle before a confirmed Break of Structure, helping traders focus on areas where institutions are most likely to have entered the market.

The indicator automatically grades order blocks based on quality, filters out lower-priority zones, and highlights the strongest nearby areas for potential reactions.

Suitable for Gold, Forex, Indices and Cryptocurrency markets.

KEY FEATURES
True Institutional Order Block Detection

Identifies the final opposing candle before a confirmed Break of Structure (BOS).

Bullish Order Blocks

Last bearish candle before bullish BOS

Bearish Order Blocks

Last bullish candle before bearish BOS
Strength Classification

Each order block is automatically classified as:

Strong
Medium
Weak

Based on:

Candle body size
Volume participation
Break strength
Momentum
Smart Quality Grading

Every zone receives a quality grade:

A+ Grade

Exceptional quality
Highest probability

A Grade

High quality

B Grade

Good quality

C Grade

Average quality

D Grade

Low quality

This allows traders to quickly identify the strongest institutional zones.

Consequent Encroachment (CE)

Displays the 50% level of every order block.

Many institutional traders use the CE level as a preferred entry area.

Zone Merging

Overlapping order blocks are automatically merged into cleaner institutional zones.

Benefits:

Less chart clutter
Easier decision making
Stronger areas of confluence
Nearest Zone Filtering

Only the most relevant nearby zones are displayed.

This helps keep charts clean and focused on actionable trading opportunities.

Mitigation Tracking

The indicator can identify when a zone has already been revisited and mitigated.

Useful for determining whether liquidity may already have been consumed.

Broken Zone Removal

Optional feature that automatically removes invalidated zones once price decisively breaks through them.

Chart Locked Zones

All order block zones remain attached to the chart and move naturally with price action.

HOW TO USE
Bullish Order Blocks

Look for:

Strong Bull OB
Grade A+ or Grade A

When price retraces into the zone:

Watch for rejection candles
Watch for bullish CHOCH
Watch for bullish BOS
Watch for liquidity sweeps
Watch for Fair Value Gaps

These can provide high-probability buying opportunities.

Bearish Order Blocks

Look for:

Strong Bear OB
Grade A+ or Grade A

When price retraces into the zone:

Watch for rejection candles
Watch for bearish CHOCH
Watch for bearish BOS
Watch for liquidity sweeps
Watch for Fair Value Gaps

These can provide high-probability selling opportunities.

UNDERSTANDING THE GRADES
A+ Grade

Highest quality institutional zone.

Often provides the strongest reactions.

Best used for:

Primary setups
Highest conviction trades
A Grade

Very strong zone.

Excellent probability.

Suitable for:

Scalping
Day trading
Swing trading
B Grade

Good quality zone.

Additional confirmation recommended.

C Grade

Average quality zone.

Use alongside additional confluence.

D Grade

Low quality zone.

Generally best avoided unless supported by strong additional confirmations.

HIGH PROBABILITY CONFLUENCE

The strongest setups occur when:

✓ Strong Order Block

✓ Grade A+ or Grade A

✓ Liquidity Sweep

✓ CHOCH

✓ BOS

✓ Fair Value Gap

✓ Session High or Session Low

✓ Rejection Candle

The more confirmations present, the higher the probability of a successful reaction.

RECOMMENDED MARKETS

Designed for:

XAUUSD (Gold)
XAGUSD (Silver)
EURUSD
GBPUSD
USDJPY
NAS100
US30
SPX500
Major Cryptocurrencies
RECOMMENDED TIMEFRAMES
Scalping
1 Minute
3 Minute
5 Minute
Day Trading
15 Minute
30 Minute
Swing Trading
1 Hour
4 Hour
SETTINGS GUIDE
Maximum Zones

Controls the maximum number of order blocks displayed.

Recommended:

20–40 for clean charts
50–80 for detailed analysis
Extend Zones Right

Controls how far zones project into future price action.

Recommended:

120–250 bars
Delete Broken Zones

Recommended:

ON

Removes zones once they become invalid.

Mark Mitigated Zones

Recommended:

ON

Allows traders to identify previously tested zones.

RISK DISCLAIMER

This indicator is provided for educational and informational purposes only.

Nothing contained within this indicator, accompanying documentation, training material, videos, social media content or community discussions should be considered financial advice, investment advice or a recommendation to buy or sell any financial instrument.

Trading Forex, Commodities, Indices, Stocks and Cryptocurrencies involves significant risk and may not be suitable for all investors.

Past performance is not indicative of future results.

The creator of this indicator accepts no responsibility for any losses, damages or financial decisions made through the use of this indicator.

Always conduct your own analysis and use proper risk management before entering any trade.

Never risk money you cannot afford to lose.

By using this indicator, you acknowledge and accept full responsibility for your own trading decisions.

## Source Code

````pine
//@version=6
indicator("Black Diamond - Order Block Zones", overlay=true, max_boxes_count=300, max_lines_count=300)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
maxZones   = input.int(60, "Max Zones", minval=5, maxval=150)
extendBars = input.int(120, "Extend Zones Right", minval=20, maxval=500)

showStrong = input.bool(true, "Show Strong Order Blocks")
showMedium = input.bool(true, "Show Medium Order Blocks")
showWeak   = input.bool(false, "Show Weak Order Blocks")

showBull = input.bool(true, "Show Bullish Zones")
showBear = input.bool(true, "Show Bearish Zones")

lookbackHighLow = input.int(10, "BOS Lookback", minval=3)
obSearchBars    = input.int(8, "Search For Last Opposite Candle", minval=1, maxval=20)
minGapBars      = input.int(4, "Minimum Bars Between Zones", minval=1)

deleteBrokenZones = input.bool(true, "Delete Broken Zones")
markMitigated     = input.bool(false, "Mark Mitigated Zones")

showCELine = input.bool(true, "Show CE Line")
mergeZones = input.bool(true, "Merge Nearby Zones")
minimumZoneSeparationATR = input.float(0.30, "Merge Distance ATR", minval=0.1, step=0.1)

showNearestOnly = input.bool(true, "Show Nearest Zones Only")
nearestBullZones = input.int(2, "Nearest Bullish Zones Below Price", minval=1, maxval=20)
nearestBearZones = input.int(3, "Nearest Bearish Zones Above Price", minval=1, maxval=20)

showScores = input.bool(false, "Show Quality Scores")
showTouches = input.bool(false, "Show Touch Count")
showRanks = input.bool(false, "Show Zone Ranking")
highlightBestZone = input.bool(true, "Highlight Best Visible Zone")

showCEInLabel = input.bool(false, "Show CE Price In Label")
smallZoneATR  = input.float(0.35, "Small Zone Auto Compact ATR", minval=0.05, step=0.05)

//━━━━━━━━━━━━━━━━━━━
// STRENGTH SETTINGS
//━━━━━━━━━━━━━━━━━━━
strongBodyMult = input.float(1.8, "Strong Body Multiplier", minval=1.0, step=0.1)
mediumBodyMult = input.float(1.3, "Medium Body Multiplier", minval=1.0, step=0.1)
weakBodyMult   = input.float(0.8, "Weak Body Multiplier", minval=0.1, step=0.1)

strongVolMult = input.float(1.3, "Strong Volume Multiplier", minval=1.0, step=0.1)
mediumVolMult = input.float(1.1, "Medium Volume Multiplier", minval=1.0, step=0.1)

//━━━━━━━━━━━━━━━━━━━
// COLOURS
//━━━━━━━━━━━━━━━━━━━
strongBullCol = input.color(color.new(color.green, 78), "Strong Bullish Colour")
strongBearCol = input.color(color.new(color.red, 78), "Strong Bearish Colour")

mediumBullCol = input.color(color.new(color.teal, 82), "Medium Bullish Colour")
mediumBearCol = input.color(color.new(color.orange, 82), "Medium Bearish Colour")

weakBullCol = input.color(color.new(color.lime, 88), "Weak Bullish Colour")
weakBearCol = input.color(color.new(color.maroon, 88), "Weak Bearish Colour")

mitigatedCol = input.color(color.new(color.gray, 88), "Mitigated Zone Colour")

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
var box[] zones = array.new_box()
var line[] ceLines = array.new_line()

var int[] zoneDir = array.new_int()
var int[] zoneStrength = array.new_int()
var bool[] zoneMitigated = array.new_bool()
var int[] zoneCreated = array.new_int()

var float[] zoneScores = array.new_float()
var int[] zoneTouches = array.new_int()
var int[] zoneLastTouch = array.new_int()
var float[] zoneBosBodyPower = array.new_float()
var float[] zoneBosVolPower = array.new_float()

//━━━━━━━━━━━━━━━━━━━
// DATA
//━━━━━━━━━━━━━━━━━━━
body = math.abs(close - open)
avgBody = ta.sma(math.abs(close - open), 20)
avgVol = ta.sma(volume, 20)
atr = ta.atr(14)

safeAvgBody = math.max(avgBody, syminfo.mintick)
safeAvgVol  = math.max(avgVol, 1)

//━━━━━━━━━━━━━━━━━━━
// TRUE BOS LOGIC
//━━━━━━━━━━━━━━━━━━━
recentHigh = ta.highest(high[1], lookbackHighLow)
recentLow  = ta.lowest(low[1], lookbackHighLow)

bullBOS = close > recentHigh
bearBOS = close < recentLow

//━━━━━━━━━━━━━━━━━━━
// FIND LAST OPPOSITE CANDLE BEFORE BOS
//━━━━━━━━━━━━━━━━━━━
f_find_bull_ob() =>
    int found = na
    for i = 1 to obSearchBars
        if close[i] < open[i]
            found := i
            break
    found

f_find_bear_ob() =>
    int found = na
    for i = 1 to obSearchBars
        if close[i] > open[i]
            found := i
            break
    found

bullOBIndex = bullBOS ? f_find_bull_ob() : na
bearOBIndex = bearBOS ? f_find_bear_ob() : na

validBullOB = bullBOS and not na(bullOBIndex)
validBearOB = bearBOS and not na(bearOBIndex)

//━━━━━━━━━━━━━━━━━━━
// STRENGTH CLASSIFICATION
//━━━━━━━━━━━━━━━━━━━
bosBodyStrong = body > safeAvgBody * strongBodyMult and volume > safeAvgVol * strongVolMult
bosBodyMedium = body > safeAvgBody * mediumBodyMult and volume > safeAvgVol * mediumVolMult
bosBodyWeak   = body > safeAvgBody * weakBodyMult

bullStrength = bosBodyStrong ? 3 : bosBodyMedium ? 2 : bosBodyWeak ? 1 : 0
bearStrength = bosBodyStrong ? 3 : bosBodyMedium ? 2 : bosBodyWeak ? 1 : 0

allowBullStrength = bullStrength == 3 and showStrong or bullStrength == 2 and showMedium or bullStrength == 1 and showWeak
allowBearStrength = bearStrength == 3 and showStrong or bearStrength == 2 and showMedium or bearStrength == 1 and showWeak

currentBosBodyPower = math.min(body / safeAvgBody, 4.0)
currentBosVolPower  = math.min(volume / safeAvgVol, 3.0)

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
f_grade(_score) =>
    _score >= 95 ? "A+" :
     _score >= 85 ? "A" :
     _score >= 70 ? "B" :
     _score >= 50 ? "C" : "D"

f_colour(_dir, _strength) =>
    _dir == 1 and _strength == 3 ? strongBullCol :
     _dir == 1 and _strength == 2 ? mediumBullCol :
     _dir == 1 and _strength == 1 ? weakBullCol :
     _dir == -1 and _strength == 3 ? strongBearCol :
     _dir == -1 and _strength == 2 ? mediumBearCol :
     weakBearCol

f_border(_dir, _strength) =>
    _dir == 1 and _strength == 3 ? color.green :
     _dir == 1 and _strength == 2 ? color.teal :
     _dir == 1 and _strength == 1 ? color.lime :
     _dir == -1 and _strength == 3 ? color.red :
     _dir == -1 and _strength == 2 ? color.orange :
     color.maroon

f_score(_strength, _touches, _createdBar, _bodyPower, _volPower, _mitigated) =>
    strengthScore = _strength == 3 ? 25.0 : _strength == 2 ? 17.0 : 8.0
    bodyScore = math.min(_bodyPower / 4.0 * 25.0, 25.0)
    volumeScore = math.min(_volPower / 3.0 * 20.0, 20.0)
    touchScore = math.min(_touches * 5.0, 15.0)
    ageBars = bar_index - _createdBar
    freshnessScore = math.max(15.0 - ageBars * 0.03, 0.0)
    mitigationPenalty = _mitigated ? 8.0 : 0.0
    math.max(math.min(strengthScore + bodyScore + volumeScore + touchScore + freshnessScore - mitigationPenalty, 100.0), 0.0)

f_label(_idx, _strength, _dir, _mitigated, _ce, _rank, _height) =>
    score = array.get(zoneScores, _idx)
    grade = f_grade(score)

    strengthText = _strength == 3 ? "STRONG" : _strength == 2 ? "MEDIUM" : "WEAK"
    dirText = _dir == 1 ? "BULL OB" : "BEAR OB"
    mitText = _mitigated ? "\nMITIGATED" : ""

    strengthText + " " + dirText + "\nGRADE " + grade + mitText

f_delete_zone(_idx) =>
    b = array.get(zones, _idx)
    l = array.get(ceLines, _idx)

    box.delete(b)
    line.delete(l)

    array.remove(zones, _idx)
    array.remove(ceLines, _idx)
    array.remove(zoneDir, _idx)
    array.remove(zoneStrength, _idx)
    array.remove(zoneMitigated, _idx)
    array.remove(zoneCreated, _idx)
    array.remove(zoneScores, _idx)
    array.remove(zoneTouches, _idx)
    array.remove(zoneLastTouch, _idx)
    array.remove(zoneBosBodyPower, _idx)
    array.remove(zoneBosVolPower, _idx)

f_merge_index(_top, _bot, _dir) =>
    int found = na
    newMid = (_top + _bot) / 2.0

    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            oldDir = array.get(zoneDir, i)

            if oldDir == _dir
                b = array.get(zones, i)
                oldTop = box.get_top(b)
                oldBot = box.get_bottom(b)
                oldMid = (oldTop + oldBot) / 2.0

                distance = math.abs(newMid - oldMid)
                overlaps = _top >= oldBot and _bot <= oldTop
                nearby = distance <= atr * minimumZoneSeparationATR

                if overlaps or nearby
                    found := i
                    break

    found

f_is_nearest_visible(_idx) =>
    if not showNearestOnly
        true
    else
        b = array.get(zones, _idx)
        dir = array.get(zoneDir, _idx)

        top = box.get_top(b)
        bot = box.get_bottom(b)
        mid = (top + bot) / 2.0

        isBullCandidate = dir == 1 and top <= close
        isBearCandidate = dir == -1 and bot >= close

        if not isBullCandidate and not isBearCandidate
            false
        else
            dist = math.abs(close - mid)
            closerCount = 0

            if array.size(zones) > 0
                for j = 0 to array.size(zones) - 1
                    if j != _idx
                        otherDir = array.get(zoneDir, j)

                        if otherDir == dir
                            ob = array.get(zones, j)
                            otherTop = box.get_top(ob)
                            otherBot = box.get_bottom(ob)
                            otherMid = (otherTop + otherBot) / 2.0

                            otherBullCandidate = otherDir == 1 and otherTop <= close
                            otherBearCandidate = otherDir == -1 and otherBot >= close

                            if otherBullCandidate or otherBearCandidate
                                otherDist = math.abs(close - otherMid)

                                if otherDist < dist
                                    closerCount += 1

            dir == 1 ? closerCount < nearestBullZones : closerCount < nearestBearZones

f_visible_rank(_idx) =>
    if not f_is_nearest_visible(_idx)
        0
    else
        score = array.get(zoneScores, _idx)
        betterCount = 0

        if array.size(zones) > 0
            for j = 0 to array.size(zones) - 1
                if j != _idx and f_is_nearest_visible(j)
                    otherScore = array.get(zoneScores, j)
                    if otherScore > score
                        betterCount += 1

        betterCount + 1

f_recalculate_score(_idx) =>
    strength = array.get(zoneStrength, _idx)
    touches = array.get(zoneTouches, _idx)
    created = array.get(zoneCreated, _idx)
    bodyPower = array.get(zoneBosBodyPower, _idx)
    volPower = array.get(zoneBosVolPower, _idx)
    mitigated = array.get(zoneMitigated, _idx)

    score = f_score(strength, touches, created, bodyPower, volPower, mitigated)
    array.set(zoneScores, _idx, score)

f_apply_visibility(_idx, _visible) =>
    b = array.get(zones, _idx)
    l = array.get(ceLines, _idx)

    dir = array.get(zoneDir, _idx)
    strength = array.get(zoneStrength, _idx)
    mitigated = array.get(zoneMitigated, _idx)

    top = box.get_top(b)
    bot = box.get_bottom(b)
    ce = (top + bot) / 2.0
    height = math.abs(top - bot)

    rank = f_visible_rank(_idx)
    isBest = highlightBestZone and _visible and rank == 1

    if _visible
        zoneBorder = mitigated ? color.gray : f_border(dir, strength)

        box.set_bgcolor(b, mitigated ? mitigatedCol : f_colour(dir, strength))
        box.set_border_color(b, zoneBorder)
        box.set_border_width(b, isBest ? 4 : 2)
        box.set_text_color(b, color.white)
        box.set_text_size(b, size.tiny)
        box.set_text_halign(b, text.align_right)
        box.set_text_valign(b, text.align_center)
        box.set_text(b, f_label(_idx, strength, dir, mitigated, ce, rank, height))

        line.set_color(l, showCELine ? (mitigated ? color.gray : f_border(dir, strength)) : color.new(color.white, 100))
        line.set_width(l, isBest ? 2 : 1)
    else
        box.set_bgcolor(b, color.new(color.white, 100))
        box.set_border_color(b, color.new(color.white, 100))
        box.set_border_width(b, 1)
        box.set_text_color(b, color.new(color.white, 100))
        box.set_text(b, "")
        line.set_color(l, color.new(color.white, 100))
        line.set_width(l, 1)

f_update_zone(_idx, _top, _bot, _dir, _strength, _mitigated) =>
    b = array.get(zones, _idx)
    l = array.get(ceLines, _idx)
    ce = (_top + _bot) / 2.0

    box.set_top(b, _top)
    box.set_bottom(b, _bot)
    box.set_right(b, bar_index + extendBars)

    line.set_y1(l, ce)
    line.set_y2(l, ce)
    line.set_x2(l, bar_index + extendBars)

    oldStrength = array.get(zoneStrength, _idx)
    array.set(zoneStrength, _idx, math.max(oldStrength, _strength))
    array.set(zoneMitigated, _idx, _mitigated)

    oldBodyPower = array.get(zoneBosBodyPower, _idx)
    oldVolPower = array.get(zoneBosVolPower, _idx)

    array.set(zoneBosBodyPower, _idx, math.max(oldBodyPower, currentBosBodyPower))
    array.set(zoneBosVolPower, _idx, math.max(oldVolPower, currentBosVolPower))

    f_recalculate_score(_idx)
    f_apply_visibility(_idx, f_is_nearest_visible(_idx))

f_draw(_left, _top, _bot, _dir, _strength) =>
    ce = (_top + _bot) / 2.0

    b = box.new(
         left=_left,
         right=bar_index + extendBars,
         top=_top,
         bottom=_bot,
         xloc=xloc.bar_index,
         bgcolor=f_colour(_dir, _strength),
         border_color=f_border(_dir, _strength),
         border_width=2,
         text="",
         text_color=color.white,
         text_size=size.tiny,
         text_halign=text.align_right,
         text_valign=text.align_center)

    l = line.new(
         x1=_left,
         y1=ce,
         x2=bar_index + extendBars,
         y2=ce,
         xloc=xloc.bar_index,
         color=showCELine ? f_border(_dir, _strength) : color.new(color.white, 100),
         width=1,
         style=line.style_dashed)

    array.push(zones, b)
    array.push(ceLines, l)
    array.push(zoneDir, _dir)
    array.push(zoneStrength, _strength)
    array.push(zoneMitigated, false)
    array.push(zoneCreated, bar_index)
    array.push(zoneScores, 0.0)
    array.push(zoneTouches, 0)
    array.push(zoneLastTouch, na)
    array.push(zoneBosBodyPower, currentBosBodyPower)
    array.push(zoneBosVolPower, currentBosVolPower)

    newIdx = array.size(zones) - 1
    f_recalculate_score(newIdx)
    f_apply_visibility(newIdx, f_is_nearest_visible(newIdx))

//━━━━━━━━━━━━━━━━━━━
// IMPORTANT LOCKING FIX
// Zones now start from the actual order block candle using bar_index - bullOBIndex / bearOBIndex.
// This keeps the zone locked to the candle that created it instead of floating from the BOS candle.
//━━━━━━━━━━━━━━━━━━━
// DRAW OR MERGE NEW ZONES
//━━━━━━━━━━━━━━━━━━━
var int lastZoneBar = na
canDraw = na(lastZoneBar) or bar_index - lastZoneBar >= minGapBars

if canDraw
    if showBull and validBullOB and allowBullStrength
        newTop = high[bullOBIndex]
        newBot = low[bullOBIndex]

        mergeIdx = mergeZones ? f_merge_index(newTop, newBot, 1) : na

        if na(mergeIdx)
            f_draw(bar_index - bullOBIndex, newTop, newBot, 1, bullStrength)
            lastZoneBar := bar_index
        else
            b = array.get(zones, mergeIdx)
            oldTop = box.get_top(b)
            oldBot = box.get_bottom(b)

            mergedTop = math.max(oldTop, newTop)
            mergedBot = math.min(oldBot, newBot)

            f_update_zone(mergeIdx, mergedTop, mergedBot, 1, bullStrength, false)
            lastZoneBar := bar_index

    else if showBear and validBearOB and allowBearStrength
        newTop = high[bearOBIndex]
        newBot = low[bearOBIndex]

        mergeIdx = mergeZones ? f_merge_index(newTop, newBot, -1) : na

        if na(mergeIdx)
            f_draw(bar_index - bearOBIndex, newTop, newBot, -1, bearStrength)
            lastZoneBar := bar_index
        else
            b = array.get(zones, mergeIdx)
            oldTop = box.get_top(b)
            oldBot = box.get_bottom(b)

            mergedTop = math.max(oldTop, newTop)
            mergedBot = math.min(oldBot, newBot)

            f_update_zone(mergeIdx, mergedTop, mergedBot, -1, bearStrength, false)
            lastZoneBar := bar_index

//━━━━━━━━━━━━━━━━━━━
// MANAGE ZONES
//━━━━━━━━━━━━━━━━━━━
if array.size(zones) > 0
    for n = 0 to array.size(zones) - 1
        i = array.size(zones) - 1 - n

        b = array.get(zones, i)
        l = array.get(ceLines, i)
        dir = array.get(zoneDir, i)
        mitigated = array.get(zoneMitigated, i)
        created = array.get(zoneCreated, i)

        top = box.get_top(b)
        bot = box.get_bottom(b)
        ce = (top + bot) / 2.0

        brokenBull = dir == 1 and close < bot - atr * 0.2
        brokenBear = dir == -1 and close > top + atr * 0.2
        broken = brokenBull or brokenBear

        touched = high >= bot and low <= top and bar_index > created + 1
        lastTouchedBar = array.get(zoneLastTouch, i)

        if deleteBrokenZones and broken
            f_delete_zone(i)
        else
            box.set_right(b, bar_index + extendBars)
            line.set_x2(l, bar_index + extendBars)
            line.set_y1(l, ce)
            line.set_y2(l, ce)

            if touched and (na(lastTouchedBar) or bar_index - lastTouchedBar > 3)
                currentTouches = array.get(zoneTouches, i)
                array.set(zoneTouches, i, currentTouches + 1)
                array.set(zoneLastTouch, i, bar_index)

            if markMitigated and touched and not mitigated
                array.set(zoneMitigated, i, true)

            f_recalculate_score(i)
            f_apply_visibility(i, f_is_nearest_visible(i))

//━━━━━━━━━━━━━━━━━━━
// LIMIT OLD ZONES
//━━━━━━━━━━━━━━━━━━━
while array.size(zones) > maxZones
    f_delete_zone(0)
````
