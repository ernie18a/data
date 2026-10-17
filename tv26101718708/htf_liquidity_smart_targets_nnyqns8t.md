# HTF Liquidity + Smart Targets

- url: https://www.tradingview.com/script/NnYQnS8t-HTF-Liquidity-Smart-Targets/
- type: indicator
- pine_id: PUB;f00f311e3544481f825c680aa1115001
- version: 1.0

## Description

HTF Liquidity + Smart Targets has all targets for liquidity plus what could be next so this is big

## Source Code

````pine
//@version=6
indicator("HTF Liquidity + Smart Targets", overlay=true, max_lines_count=500, max_labels_count=300)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

grp1 = "HTF Liquidity"
show1H = input.bool(true, "Show 1H Levels", group=grp1)
show4H = input.bool(true, "Show 4H Levels", group=grp1)
showHTFLabels = input.bool(true, "Show HTF Labels", group=grp1)
num1H = input.int(4, "1H Levels Each Side", minval=1, maxval=10, group=grp1)
num4H = input.int(3, "4H Levels Each Side", minval=1, maxval=8, group=grp1)
piv1H = input.int(3, "1H Pivot Lookback", minval=2, maxval=10, group=grp1)
piv4H = input.int(2, "4H Pivot Lookback", minval=2, maxval=10, group=grp1)

grp2 = "HTF Ranking"
eqTol = input.float(4.0, "Equal High Low Tolerance", minval=0.5, step=0.5, group=grp2)
eqTouches = input.int(3, "Equal High Low Touches", minval=2, maxval=6, group=grp2)
clusterTol = input.float(8.0, "Cluster Proximity", minval=1.0, step=0.5, group=grp2)

grp3 = "Smart Targets"
showSmartTargets = input.bool(true, "Show Smart Targets", group=grp3)
showSmartLabels = input.bool(true, "Show Smart Target Labels", group=grp3)
targetMode = input.string("Always", "Target Mode", options=["Always", "Only When No HTF Level Above Below"], group=grp3)
minScoreToShow = input.int(4, "Minimum Score To Show", minval=1, maxval=20, group=grp3)
mergeTolerance = input.float(15.0, "Merge Nearby Targets", minval=1.0, step=1.0, group=grp3)
maxTargetsEachSide = input.int(4, "Max Targets Each Side", minval=1, maxval=10, group=grp3)
hideTargetsNearHTF = input.bool(true, "Hide Smart Targets Near HTF Levels", group=grp3)
hideNearHTFTolerance = input.float(25.0, "Hide Near HTF Tolerance", minval=1.0, step=1.0, group=grp3)
showFallbackBadge = input.bool(true, "Show FALLBACK MODE Badge", group=grp3)

grp4 = "Trading Sessions"
useAsiaSession = input.bool(true, "Use Asia Session High Low", group=grp4)
asiaSession = input.session("1800-0000", "Asia Session", group=grp4)

useLondonSession = input.bool(true, "Use London Session High Low", group=grp4)
londonSession = input.session("0300-0830", "London Session", group=grp4)

useNYAMSession = input.bool(true, "Use New York AM Session High Low", group=grp4)
nyAMSession = input.session("0930-1130", "New York AM Session", group=grp4)

useLunchSession = input.bool(false, "Use Lunch Session High Low", group=grp4)
lunchSession = input.session("1200-1330", "Lunch Session", group=grp4)

useNYPMSession = input.bool(true, "Use New York PM Session High Low", group=grp4)
nyPMSession = input.session("1400-1530", "New York PM Session", group=grp4)

useFullNYSession = input.bool(true, "Use Full New York Session High Low", group=grp4)
fullNYSession = input.session("0930-1600", "Full New York Session", group=grp4)

useGlobexSession = input.bool(true, "Use Globex High Low", group=grp4)
globexSession = input.session("1800-0929", "Globex Session", group=grp4)

useOpeningRange = input.bool(true, "Use Opening Range High Low", group=grp4)
openingRangeSession = input.session("0930-1000", "Opening Range Session", group=grp4)

grp5 = "Other Target Sources"
usePrevDay = input.bool(true, "Use Previous Day High Low", group=grp5)
usePrevWeek = input.bool(true, "Use Previous Week High Low", group=grp5)
usePrevMonth = input.bool(true, "Use Previous Month High Low", group=grp5)
useCurrentDay = input.bool(true, "Use Current Day High Low", group=grp5)

useADR = input.bool(true, "Use ADR Projection", group=grp5)
adrLen = input.int(14, "ADR Length", minval=3, maxval=50, group=grp5)
adrMult = input.float(1.0, "ADR Multiplier", minval=0.25, maxval=3.0, step=0.25, group=grp5)

useMeasuredMove = input.bool(true, "Use Measured Move Projection", group=grp5)
mmLookback = input.int(48, "Measured Move Lookback", minval=10, maxval=300, group=grp5)
mmMult1 = input.float(1.0, "Measured Move 1", minval=0.25, maxval=5.0, step=0.25, group=grp5)
mmMult2 = input.float(1.5, "Measured Move 2", minval=0.25, maxval=5.0, step=0.25, group=grp5)

useFibExt = input.bool(true, "Use Fib Extension Projection", group=grp5)
fibExt1 = input.float(1.272, "Fib Extension 1", minval=1.0, maxval=3.0, step=0.001, group=grp5)
fibExt2 = input.float(1.618, "Fib Extension 2", minval=1.0, maxval=3.0, step=0.001, group=grp5)

useRoundConfluence = input.bool(true, "Use Round Number Confluence", group=grp5)
showStandaloneRounds = input.bool(false, "Show Standalone Round Numbers", group=grp5)
roundStep = input.float(100.0, "Round Number Step", minval=1.0, step=25.0, group=grp5)
roundConfluenceTol = input.float(20.0, "Round Confluence Tolerance", minval=1.0, step=1.0, group=grp5)

useHTFConfluence = input.bool(true, "Use HTF Confluence Bonus", group=grp5)
htfConfluenceTol = input.float(25.0, "HTF Confluence Tolerance", minval=1.0, step=1.0, group=grp5)

grp6 = "Display"
lineBack = input.int(80, "Smart Target Line Back Bars", minval=10, maxval=300, group=grp6)
lineForward = input.int(70, "Smart Target Line Forward Bars", minval=10, maxval=300, group=grp6)
htfLineBack = input.int(150, "HTF Line Back Bars", minval=10, maxval=500, group=grp6)
htfLineForward = input.int(50, "HTF Line Forward Bars", minval=10, maxval=500, group=grp6)
htfLabelOffset = input.int(52, "HTF Label Offset", minval=10, maxval=500, group=grp6)
smartLabelOffset = input.int(72, "Smart Target Label Offset", minval=10, maxval=500, group=grp6)

grp7 = "Colors"
c1H = input.color(color.new(#FF9800, 0), "1H Color", group=grp7)
c4H = input.color(color.new(#E040FB, 0), "4H Color", group=grp7)
cStrong = input.color(color.new(#00E676, 0), "Strong Smart Target Color", group=grp7)
cMedium = input.color(color.new(#00BCD4, 0), "Medium Smart Target Color", group=grp7)
cWeak = input.color(color.new(#FFC107, 0), "Weak Smart Target Color", group=grp7)

// ═══════════════════════════════════════════════════════════════
// HTF PIVOTS
// ═══════════════════════════════════════════════════════════════

h1High = request.security(syminfo.tickerid, "60", ta.pivothigh(high, piv1H, piv1H), lookahead=barmerge.lookahead_off)
h1Low = request.security(syminfo.tickerid, "60", ta.pivotlow(low, piv1H, piv1H), lookahead=barmerge.lookahead_off)

h4High = request.security(syminfo.tickerid, "240", ta.pivothigh(high, piv4H, piv4H), lookahead=barmerge.lookahead_off)
h4Low = request.security(syminfo.tickerid, "240", ta.pivotlow(low, piv4H, piv4H), lookahead=barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════
// RECENT SWINGS
// ═══════════════════════════════════════════════════════════════

var array<float> recentHighs = array.new_float()
var array<float> recentLows = array.new_float()
int maxRecent = 40

if not na(h1High)
    array.push(recentHighs, h1High)
    if array.size(recentHighs) > maxRecent
        array.shift(recentHighs)

if not na(h4High)
    array.push(recentHighs, h4High)
    if array.size(recentHighs) > maxRecent
        array.shift(recentHighs)

if not na(h1Low)
    array.push(recentLows, h1Low)
    if array.size(recentLows) > maxRecent
        array.shift(recentLows)

if not na(h4Low)
    array.push(recentLows, h4Low)
    if array.size(recentLows) > maxRecent
        array.shift(recentLows)

countTouches(array<float> arr, float price, float tolerance) =>
    int touches = 0
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            float val = array.get(arr, i)
            if math.abs(val - price) <= tolerance
                touches += 1
    touches

// ═══════════════════════════════════════════════════════════════
// LEVEL TYPE
// ═══════════════════════════════════════════════════════════════

type Level
    float price
    int tf
    int dir
    bool swept
    int rank
    bool isEQ
    bool isCluster
    line ln
    label lb

var array<Level> levels = array.new<Level>()

addLevel(float price, int tf, int dir) =>
    bool duplicate = false
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Level oldLevel = array.get(levels, i)
            if oldLevel.tf == tf and oldLevel.dir == dir and math.abs(oldLevel.price - price) <= 0.5
                duplicate := true
                break
    if not duplicate
        Level newLevel = Level.new(price, tf, dir, false, 3, false, false, na, na)
        array.push(levels, newLevel)
        int maxAllowed = tf == 1 ? num1H : num4H
        int countSame = 0
        if array.size(levels) > 0
            for i = array.size(levels) - 1 to 0
                Level checkLevel = array.get(levels, i)
                if checkLevel.tf == tf and checkLevel.dir == dir
                    countSame += 1
                    if countSame > maxAllowed
                        line.delete(checkLevel.ln)
                        label.delete(checkLevel.lb)
                        array.remove(levels, i)

if not na(h1High)
    addLevel(h1High, 1, 1)
if not na(h1Low)
    addLevel(h1Low, 1, -1)
if not na(h4High)
    addLevel(h4High, 4, 1)
if not na(h4Low)
    addLevel(h4Low, 4, -1)

// ═══════════════════════════════════════════════════════════════
// UPDATE SWEPT STATUS — uses CLOSE not wick
// ═══════════════════════════════════════════════════════════════

if array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        Level l = array.get(levels, i)
        bool sweptHigh = l.dir == 1 and close > l.price
        bool sweptLow = l.dir == -1 and close < l.price
        if not l.swept and (sweptHigh or sweptLow)
            l.swept := true
        array.set(levels, i, l)

// ═══════════════════════════════════════════════════════════════
// RANK LEVELS
// ═══════════════════════════════════════════════════════════════

if array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        Level l = array.get(levels, i)
        int baseRank = l.tf == 4 ? 2 : 3
        int touches = l.dir == 1 ? countTouches(recentHighs, l.price, eqTol) : countTouches(recentLows, l.price, eqTol)
        bool hasEQ = touches >= eqTouches
        bool hasCluster = false
        if array.size(levels) > 0
            for j = 0 to array.size(levels) - 1
                if i != j
                    Level other = array.get(levels, j)
                    if other.tf != l.tf and other.dir == l.dir and math.abs(other.price - l.price) <= clusterTol
                        hasCluster := true
                        break
        int boosts = (hasEQ ? 1 : 0) + (hasCluster ? 1 : 0)
        l.rank := math.max(1, baseRank - boosts)
        l.isEQ := hasEQ
        l.isCluster := hasCluster
        array.set(levels, i, l)

// ═══════════════════════════════════════════════════════════════
// DRAW HTF LEVELS
// ═══════════════════════════════════════════════════════════════

bool hasUnsweptHighAbove = false
bool hasUnsweptLowBelow = false

if array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        Level l = array.get(levels, i)
        line.delete(l.ln)
        label.delete(l.lb)
        bool shouldShowTF = (l.tf == 1 and show1H) or (l.tf == 4 and show4H)
        bool showLevel = not l.swept and shouldShowTF
        if showLevel
            if l.dir == 1 and l.price > close
                hasUnsweptHighAbove := true
            if l.dir == -1 and l.price < close
                hasUnsweptLowBelow := true

            color levelColor = l.tf == 4 ? c4H : c1H
            int lineWidth = l.rank == 1 ? 3 : l.rank == 2 ? 2 : 1
            levelStyle = l.rank <= 2 ? line.style_solid : line.style_dashed
            string tfTxt = l.tf == 4 ? "4H" : "1H"
            string sideTxt = l.dir == 1 ? "HIGH" : "LOW"
            string tierTxt = l.rank == 1 ? "S" : l.rank == 2 ? "A" : "B"
            string tagTxt = ""
            if l.isEQ and l.isCluster
                tagTxt := " EQ CLU"
            else if l.isEQ
                tagTxt := " EQ"
            else if l.isCluster
                tagTxt := " CLU"
            string labelTxt = tfTxt + " " + sideTxt + " " + tierTxt + tagTxt

            l.ln := line.new(bar_index - htfLineBack, l.price, bar_index + htfLineForward, l.price, color=levelColor, style=levelStyle, width=lineWidth)
            if showHTFLabels
                l.lb := label.new(bar_index + htfLabelOffset, l.price, labelTxt, color=color.new(#000000, 100), textcolor=levelColor, style=label.style_label_left, size=size.tiny)
        array.set(levels, i, l)

// ═══════════════════════════════════════════════════════════════
// SESSION HIGH LOW TRACKING
// ═══════════════════════════════════════════════════════════════

bool inAsia = not na(time(timeframe.period, asiaSession))
bool newAsia = inAsia and not inAsia[1]
var float asiaHigh = na
var float asiaLow = na
if newAsia
    asiaHigh := high
    asiaLow := low
else if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow := na(asiaLow) ? low : math.min(asiaLow, low)

bool inLondon = not na(time(timeframe.period, londonSession))
bool newLondon = inLondon and not inLondon[1]
var float londonHigh = na
var float londonLow = na
if newLondon
    londonHigh := high
    londonLow := low
else if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow := na(londonLow) ? low : math.min(londonLow, low)

bool inNYAM = not na(time(timeframe.period, nyAMSession))
bool newNYAM = inNYAM and not inNYAM[1]
var float nyAMHigh = na
var float nyAMLow = na
if newNYAM
    nyAMHigh := high
    nyAMLow := low
else if inNYAM
    nyAMHigh := na(nyAMHigh) ? high : math.max(nyAMHigh, high)
    nyAMLow := na(nyAMLow) ? low : math.min(nyAMLow, low)

bool inLunch = not na(time(timeframe.period, lunchSession))
bool newLunch = inLunch and not inLunch[1]
var float lunchHigh = na
var float lunchLow = na
if newLunch
    lunchHigh := high
    lunchLow := low
else if inLunch
    lunchHigh := na(lunchHigh) ? high : math.max(lunchHigh, high)
    lunchLow := na(lunchLow) ? low : math.min(lunchLow, low)

bool inNYPM = not na(time(timeframe.period, nyPMSession))
bool newNYPM = inNYPM and not inNYPM[1]
var float nyPMHigh = na
var float nyPMLow = na
if newNYPM
    nyPMHigh := high
    nyPMLow := low
else if inNYPM
    nyPMHigh := na(nyPMHigh) ? high : math.max(nyPMHigh, high)
    nyPMLow := na(nyPMLow) ? low : math.min(nyPMLow, low)

bool inFullNY = not na(time(timeframe.period, fullNYSession))
bool newFullNY = inFullNY and not inFullNY[1]
var float fullNYHigh = na
var float fullNYLow = na
if newFullNY
    fullNYHigh := high
    fullNYLow := low
else if inFullNY
    fullNYHigh := na(fullNYHigh) ? high : math.max(fullNYHigh, high)
    fullNYLow := na(fullNYLow) ? low : math.min(fullNYLow, low)

bool inGlobex = not na(time(timeframe.period, globexSession))
bool newGlobex = inGlobex and not inGlobex[1]
var float globexHigh = na
var float globexLow = na
if newGlobex
    globexHigh := high
    globexLow := low
else if inGlobex
    globexHigh := na(globexHigh) ? high : math.max(globexHigh, high)
    globexLow := na(globexLow) ? low : math.min(globexLow, low)

bool inOpeningRange = not na(time(timeframe.period, openingRangeSession))
bool newOpeningRange = inOpeningRange and not inOpeningRange[1]
var float openingRangeHigh = na
var float openingRangeLow = na
if newOpeningRange
    openingRangeHigh := high
    openingRangeLow := low
else if inOpeningRange
    openingRangeHigh := na(openingRangeHigh) ? high : math.max(openingRangeHigh, high)
    openingRangeLow := na(openingRangeLow) ? low : math.min(openingRangeLow, low)

// ═══════════════════════════════════════════════════════════════
// SMART TARGET CANDIDATES
// ═══════════════════════════════════════════════════════════════

var array<float> targetPrices = array.new_float()
var array<int> targetDirs = array.new_int()
var array<int> targetScores = array.new_int()
var array<string> targetNames = array.new_string()

clearCandidateTargets() =>
    array.clear(targetPrices)
    array.clear(targetDirs)
    array.clear(targetScores)
    array.clear(targetNames)

isNearActiveHTF(float price, int dir, float tolerance) =>
    bool nearHTF = false
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            Level l = array.get(levels, i)
            if not l.swept and l.dir == dir and math.abs(l.price - price) <= tolerance
                nearHTF := true
                break
    nearHTF

addCandidate(float price, int dir, int score, string name) =>
    if not na(price)
        bool validSide = (dir == 1 and price > close) or (dir == -1 and price < close)
        bool blockedByHTF = hideTargetsNearHTF and isNearActiveHTF(price, dir, hideNearHTFTolerance)
        if validSide and not blockedByHTF
            bool merged = false
            if array.size(targetPrices) > 0
                for i = 0 to array.size(targetPrices) - 1
                    float oldPrice = array.get(targetPrices, i)
                    int oldDir = array.get(targetDirs, i)
                    if oldDir == dir and math.abs(oldPrice - price) <= mergeTolerance
                        int oldScore = array.get(targetScores, i)
                        string oldName = array.get(targetNames, i)
                        float newPrice = oldScore >= score ? oldPrice : price
                        string newName = oldName + "+" + name
                        array.set(targetPrices, i, newPrice)
                        array.set(targetScores, i, oldScore + score)
                        array.set(targetNames, i, newName)
                        merged := true
                        break
            if not merged
                array.push(targetPrices, price)
                array.push(targetDirs, dir)
                array.push(targetScores, score)
                array.push(targetNames, name)

clearCandidateTargets()

bool onlyWhenNoLevel = targetMode == "Only When No HTF Level Above Below"
bool allowUpsideTargets = showSmartTargets and (not onlyWhenNoLevel or not hasUnsweptHighAbove)
bool allowDownsideTargets = showSmartTargets and (not onlyWhenNoLevel or not hasUnsweptLowBelow)

// ═══════════════════════════════════════════════════════════════
// OTHER TARGET DATA
// ═══════════════════════════════════════════════════════════════

float prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
float prevDayLow = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
float prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
float prevWeekLow = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)
float prevMonthHigh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_off)
float prevMonthLow = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_off)
float currentDayHigh = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_off)
float currentDayLow = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_off)
float dailyOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
float dailyADR = request.security(syminfo.tickerid, "D", ta.sma(high - low, adrLen), lookahead=barmerge.lookahead_off)

float adrHigh = dailyOpen + dailyADR * adrMult
float adrLow = dailyOpen - dailyADR * adrMult
float rangeHigh = ta.highest(high, mmLookback)
float rangeLow = ta.lowest(low, mmLookback)
float rangeSize = rangeHigh - rangeLow
float mmUp1 = rangeHigh + rangeSize * mmMult1
float mmUp2 = rangeHigh + rangeSize * mmMult2
float mmDown1 = rangeLow - rangeSize * mmMult1
float mmDown2 = rangeLow - rangeSize * mmMult2
float fibUp1 = rangeHigh + rangeSize * (fibExt1 - 1.0)
float fibUp2 = rangeHigh + rangeSize * (fibExt2 - 1.0)
float fibDown1 = rangeLow - rangeSize * (fibExt1 - 1.0)
float fibDown2 = rangeLow - rangeSize * (fibExt2 - 1.0)

// ═══════════════════════════════════════════════════════════════
// ADD CANDIDATES
// ═══════════════════════════════════════════════════════════════

if allowUpsideTargets
    if useAsiaSession
        addCandidate(asiaHigh, 1, 3, "ASIA H")
    if useLondonSession
        addCandidate(londonHigh, 1, 3, "LON H")
    if useNYAMSession
        addCandidate(nyAMHigh, 1, 3, "NYAM H")
    if useLunchSession
        addCandidate(lunchHigh, 1, 1, "LUNCH H")
    if useNYPMSession
        addCandidate(nyPMHigh, 1, 2, "NYPM H")
    if useFullNYSession
        addCandidate(fullNYHigh, 1, 3, "NY H")
    if useGlobexSession
        addCandidate(globexHigh, 1, 3, "GLOBEX H")
    if useOpeningRange
        addCandidate(openingRangeHigh, 1, 3, "OR H")

if allowDownsideTargets
    if useAsiaSession
        addCandidate(asiaLow, -1, 3, "ASIA L")
    if useLondonSession
        addCandidate(londonLow, -1, 3, "LON L")
    if useNYAMSession
        addCandidate(nyAMLow, -1, 3, "NYAM L")
    if useLunchSession
        addCandidate(lunchLow, -1, 1, "LUNCH L")
    if useNYPMSession
        addCandidate(nyPMLow, -1, 2, "NYPM L")
    if useFullNYSession
        addCandidate(fullNYLow, -1, 3, "NY L")
    if useGlobexSession
        addCandidate(globexLow, -1, 3, "GLOBEX L")
    if useOpeningRange
        addCandidate(openingRangeLow, -1, 3, "OR L")

if allowUpsideTargets
    if usePrevDay
        addCandidate(prevDayHigh, 1, 4, "PDH")
    if usePrevWeek
        addCandidate(prevWeekHigh, 1, 5, "PWH")
    if usePrevMonth
        addCandidate(prevMonthHigh, 1, 6, "PMH")
    if useCurrentDay
        addCandidate(currentDayHigh, 1, 2, "DH")
    if useADR
        addCandidate(adrHigh, 1, 3, "ADR H")
    if useMeasuredMove
        addCandidate(mmUp1, 1, 2, "MM1")
        addCandidate(mmUp2, 1, 2, "MM2")
    if useFibExt
        addCandidate(fibUp1, 1, 2, "FIB1")
        addCandidate(fibUp2, 1, 2, "FIB2")

if allowDownsideTargets
    if usePrevDay
        addCandidate(prevDayLow, -1, 4, "PDL")
    if usePrevWeek
        addCandidate(prevWeekLow, -1, 5, "PWL")
    if usePrevMonth
        addCandidate(prevMonthLow, -1, 6, "PML")
    if useCurrentDay
        addCandidate(currentDayLow, -1, 2, "DL")
    if useADR
        addCandidate(adrLow, -1, 3, "ADR L")
    if useMeasuredMove
        addCandidate(mmDown1, -1, 2, "MM1")
        addCandidate(mmDown2, -1, 2, "MM2")
    if useFibExt
        addCandidate(fibDown1, -1, 2, "FIB1")
        addCandidate(fibDown2, -1, 2, "FIB2")

// ═══════════════════════════════════════════════════════════════
// ROUND NUMBERS
// ═══════════════════════════════════════════════════════════════

if useRoundConfluence and roundStep > 0 and array.size(targetPrices) > 0
    for i = 0 to array.size(targetPrices) - 1
        float p = array.get(targetPrices, i)
        float nearestRound = math.round(p / roundStep) * roundStep
        if math.abs(p - nearestRound) <= roundConfluenceTol
            int oldScore = array.get(targetScores, i)
            string oldName = array.get(targetNames, i)
            array.set(targetScores, i, oldScore + 1)
            array.set(targetNames, i, oldName + "+RN")

if showStandaloneRounds and roundStep > 0
    float nextRoundAbove = math.ceil(close / roundStep) * roundStep
    float nextRoundBelow = math.floor(close / roundStep) * roundStep
    if nextRoundAbove <= close
        nextRoundAbove += roundStep
    if nextRoundBelow >= close
        nextRoundBelow -= roundStep
    if allowUpsideTargets
        addCandidate(nextRoundAbove, 1, 1, "RN")
    if allowDownsideTargets
        addCandidate(nextRoundBelow, -1, 1, "RN")

// ═══════════════════════════════════════════════════════════════
// HTF CONFLUENCE BONUS
// ═══════════════════════════════════════════════════════════════

if useHTFConfluence and not hideTargetsNearHTF and array.size(targetPrices) > 0 and array.size(levels) > 0
    for i = 0 to array.size(targetPrices) - 1
        float targetPrice = array.get(targetPrices, i)
        int targetDir = array.get(targetDirs, i)
        bool gotBonus = false
        for j = 0 to array.size(levels) - 1
            Level l = array.get(levels, j)
            if not l.swept and l.dir == targetDir and math.abs(l.price - targetPrice) <= htfConfluenceTol
                gotBonus := true
                break
        if gotBonus
            int oldScore = array.get(targetScores, i)
            string oldName = array.get(targetNames, i)
            array.set(targetScores, i, oldScore + 3)
            array.set(targetNames, i, oldName + "+HTF")

// ═══════════════════════════════════════════════════════════════
// DRAW SMART TARGETS WITH LABELS
// ═══════════════════════════════════════════════════════════════

var array<line> drawnTargetLines = array.new_line()
var array<label> drawnTargetLabels = array.new_label()

clearDrawnTargets() =>
    if array.size(drawnTargetLines) > 0
        for i = 0 to array.size(drawnTargetLines) - 1
            line.delete(array.get(drawnTargetLines, i))
    array.clear(drawnTargetLines)
    if array.size(drawnTargetLabels) > 0
        for i = 0 to array.size(drawnTargetLabels) - 1
            label.delete(array.get(drawnTargetLabels, i))
    array.clear(drawnTargetLabels)

drawSmartTarget(float price, int score, string name) =>
    if not na(price)
        color targetColor = score >= 8 ? cStrong : score >= 5 ? cMedium : cWeak
        int widthVal = score >= 8 ? 3 : score >= 5 ? 2 : 1
        styleVal = score >= 5 ? line.style_solid : line.style_dashed

        line ln = line.new(bar_index - lineBack, price, bar_index + lineForward, price, color=targetColor, style=styleVal, width=widthVal)
        array.push(drawnTargetLines, ln)

        if showSmartLabels
            string lblTxt = name + "  " + str.tostring(score)
            label lb = label.new(bar_index + smartLabelOffset, price, lblTxt, color=color.new(#000000, 100), textcolor=targetColor, style=label.style_label_left, size=size.tiny)
            array.push(drawnTargetLabels, lb)

clearDrawnTargets()

int targetCount = array.size(targetPrices)
var array<bool> usedTargets = array.new_bool()
array.clear(usedTargets)
if targetCount > 0
    for i = 0 to targetCount - 1
        array.push(usedTargets, false)

drawBestForSide(int sideDir) =>
    int drawn = 0
    for slot = 0 to maxTargetsEachSide - 1
        int bestIndex = na
        int bestScore = -1
        float bestDistance = na
        if targetCount > 0
            for i = 0 to targetCount - 1
                bool alreadyUsed = array.get(usedTargets, i)
                int d = array.get(targetDirs, i)
                int s = array.get(targetScores, i)
                float p = array.get(targetPrices, i)
                float dist = math.abs(p - close)
                bool validCandidate = not alreadyUsed and d == sideDir and s >= minScoreToShow
                bool betterScore = s > bestScore
                bool sameScoreCloser = s == bestScore and (na(bestDistance) or dist < bestDistance)
                if validCandidate and (betterScore or sameScoreCloser)
                    bestIndex := i
                    bestScore := s
                    bestDistance := dist
        if not na(bestIndex)
            float p = array.get(targetPrices, bestIndex)
            int s = array.get(targetScores, bestIndex)
            string n = array.get(targetNames, bestIndex)
            drawSmartTarget(p, s, n)
            array.set(usedTargets, bestIndex, true)
            drawn += 1
    drawn

if showSmartTargets and targetCount > 0
    drawBestForSide(1)
    drawBestForSide(-1)

// ═══════════════════════════════════════════════════════════════
// FALLBACK MODE BADGE
// ═══════════════════════════════════════════════════════════════

var label fallbackLabel = na
label.delete(fallbackLabel)

if showFallbackBadge and barstate.islast and showSmartTargets
    bool fallbackActive = (not hasUnsweptHighAbove) or (not hasUnsweptLowBelow)
    if fallbackActive
        string badgeTxt = ""
        if not hasUnsweptHighAbove and not hasUnsweptLowBelow
            badgeTxt := "FALLBACK MODE  no HTF either side"
        else if not hasUnsweptHighAbove
            badgeTxt := "FALLBACK MODE  no HTF above  ATH conditions"
        else
            badgeTxt := "FALLBACK MODE  no HTF below"
        fallbackLabel := label.new(bar_index + 5, close, badgeTxt, color=color.new(cWeak, 70), textcolor=cWeak, style=label.style_label_left, size=size.small)
````
