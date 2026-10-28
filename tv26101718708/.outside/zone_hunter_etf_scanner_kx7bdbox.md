# Zone Hunter  ETF Scanner

- url: https://www.tradingview.com/script/kX7BdBOx-Zone-Hunter-ETF-Scanner/
- type: indicator
- pine_id: PUB;d3f3a32238ba444c81d4e916b88a01ff
- version: 1.0

## Description

find etf trade ideas without flipping from screen to screen.

## Source Code

````pine
//@version=6
indicator("Zone Hunter – ETF Scanner", overlay=true, max_bars_back=200)

//================ SETTINGS =================
impulseLen      = input.int(20, "Impulse Lookback", minval=10)
flagLen         = input.int(12, "Flag Length", minval=8)
minImpulsePct   = input.float(3.5, "Min Impulse %", step=0.25)
maxRetracePct   = input.float(50.0, "Max Retrace %", step=1)
maxRangePct     = input.float(1.8, "Max Flag Range %", step=0.1)

atrLen          = input.int(14, "ATR Length")
zoneAtrMult     = input.float(0.8, "Zone Thickness ATR", step=0.05)
rejectLookback  = input.int(8, "Zone Freshness Bars", minval=2)
tpAtrMult       = input.float(2.0, "TP ATR Multiple", step=0.25)

requireCloseOut = input.bool(true, "Require Close Outside Zone")
showInvalidated = input.bool(true, "Show Invalidated Plays")
grayInvalidated = input.bool(true, "Gray Out Invalidated")
fontColor       = input.color(color.white, "Table Font Color")

//================ TIMEFRAMES =================
useTf1 = input.bool(true, "Use Timeframe 1")
tf1    = input.timeframe("60", "Timeframe 1")

useTf2 = input.bool(true, "Use Timeframe 2")
tf2    = input.timeframe("240", "Timeframe 2")

//================ OPTIONS =================
optMode         = input.string("AUTO", "Options Mode", options=["AUTO","CALL","PUT"])
strikeStyle     = input.string("ATM", "Strike Style", options=["ATM","REALISTIC OTM"])
otmStepsMax     = input.int(1, "OTM Max Steps", minval=1, maxval=5)
dteDays         = input.int(14, "Suggested DTE (Days)", minval=1)

//================ SCAN CONTROL =================
maxSymbolsToScan = input.int(12, "Max Symbols To Scan", minval=4, maxval=19)
secBars          = input.int(90, "Security Bars Loaded", minval=50, maxval=200)

//================ SYMBOLS =================
symbolsCore = array.from(
    
    "AMEX:SPY","SP:SPX","NASDAQ:QQQ","AMEX:IWM","AMEX:GLD","TVC:VIX"
)

var array<string> symbols = array.new_string()

if barstate.isfirst
    for i = 0 to array.size(symbolsCore) - 1
        array.push(symbols, array.get(symbolsCore, i))

//================ HELPERS =================
clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

score100(x) =>
    int(math.round(clamp01(x) * 100.0))

displayTicker(sym) =>
    string out = sym
    parts = str.split(sym, ":")
    if array.size(parts) > 1
        out := array.get(parts, 1)
    out

fmtPrice(x) =>
    str.tostring(x, format.mintick)

sigName(sig) =>
    string result = ""
    if sig == 1
        result := "DEMAND"
    else if sig == 2
        result := "SUPPLY"
    else if sig == 3
        result := "BULL FLAG"
    else if sig == 4
        result := "BEAR FLAG"
    result

sigColor(sig, isActive) =>
    color result = color.new(color.gray, 80)
    if sig == 1
        result := isActive ? color.teal : color.new(color.teal, 75)
    else if sig == 2
        result := isActive ? color.orange : color.new(color.orange, 75)
    else if sig == 3
        result := isActive ? color.green : color.new(color.green, 75)
    else if sig == 4
        result := isActive ? color.red : color.new(color.red, 75)
    result

confBg(conf, isActive) =>
    color result = color.new(color.gray, 85)
    if conf >= 75
        result := isActive ? color.new(color.green, 65) : color.new(color.green, 88)
    else if conf >= 60
        result := isActive ? color.new(color.teal, 70) : color.new(color.teal, 88)
    else if conf >= 45
        result := isActive ? color.new(color.orange, 72) : color.new(color.orange, 88)
    else
        result := isActive ? color.new(color.red, 78) : color.new(color.red, 90)
    result

stateText(isActive, wasFound) =>
    string out = ""
    if wasFound
        out := isActive ? "ACTIVE" : "INVALID"
    out

stepByPrice(p) =>
    float step = 1.0
    if p < 25
        step := 0.5
    else if p < 200
        step := 1.0
    else if p < 500
        step := 2.5
    else if p < 1000
        step := 5.0
    else
        step := 10.0
    step

roundNearest(x, step) =>
    math.round(x / step) * step

roundUp(x, step) =>
    math.ceil(x / step) * step

roundDown(x, step) =>
    math.floor(x / step) * step

isBullish(sig) =>
    sig == 1 or sig == 3

//================ CORE LOGIC =================
// Return map:
// 0 sig
// 1 conf
// 2 close
// 3 atr
// 4 foundSetup
// 5 activeSetup
detectPacked() =>
    float atr = ta.atr(atrLen)
    float atrSafe = math.max(atr, syminfo.mintick)

    // FLAG STRUCTURE
    float hh = ta.highest(high, impulseLen)
    float ll = ta.lowest(low, impulseLen)
    float denom = math.max(hh - ll, syminfo.mintick)
    float impulsePct = (hh - ll) / math.max(ll, syminfo.mintick) * 100.0

    float retraceBull = (hh - close) / denom * 100.0
    float retraceBear = (close - ll) / denom * 100.0

    float flagHi = ta.highest(high, flagLen)
    float flagLo = ta.lowest(low, flagLen)
    float flagRangePct = (flagHi - flagLo) / math.max(close, syminfo.mintick) * 100.0

    float lr0 = ta.linreg(close, flagLen, 0)
    float lr1 = ta.linreg(close, flagLen, 1)
    float slopeDeg = math.atan(lr0 - lr1) * 180.0 / math.pi

    bool bullFlagFound = impulsePct >= minImpulsePct and retraceBull <= maxRetracePct and flagRangePct <= maxRangePct and slopeDeg <= 5
    bool bearFlagFound = impulsePct >= minImpulsePct and retraceBear <= maxRetracePct and flagRangePct <= maxRangePct and slopeDeg >= -5

    bool bullFlagActive = bullFlagFound and close > flagLo
    bool bearFlagActive = bearFlagFound and close < flagHi

    // ZONES
    int win = 5
    float demandLow = ta.lowest(low, win)
    float supplyHigh = ta.highest(high, win)

    int demandBars = ta.lowestbars(low, win)
    int supplyBars = ta.highestbars(high, win)

    float demandHigh = demandLow + atrSafe * zoneAtrMult
    float supplyLow = supplyHigh - atrSafe * zoneAtrMult

    bool demandFound = demandBars <= rejectLookback
    bool supplyFound = supplyBars <= rejectLookback

    bool demandActive = false
    bool supplyActive = false

    if requireCloseOut
        demandActive := demandFound and close > demandHigh and close > demandLow
        supplyActive := supplyFound and close < supplyLow and close < supplyHigh
    else
        demandActive := demandFound and close > demandLow
        supplyActive := supplyFound and close < supplyHigh

    // CONFIDENCE REWORK
    float impulseScore = clamp01((impulsePct - minImpulsePct) / (minImpulsePct * 3.0))
    float bullRetraceScore = clamp01(1.0 - retraceBull / (maxRetracePct * 1.10))
    float bearRetraceScore = clamp01(1.0 - retraceBear / (maxRetracePct * 1.10))
    float rangeScore = clamp01(1.0 - flagRangePct / (maxRangePct * 1.15))

    float slopePenaltyBull = clamp01(math.abs(math.max(slopeDeg, 0)) / 25.0)
    float slopePenaltyBear = clamp01(math.abs(math.min(slopeDeg, 0)) / 25.0)

    float demandFreshness = clamp01(1.0 - demandBars / (rejectLookback * 1.25))
    float supplyFreshness = clamp01(1.0 - supplyBars / (rejectLookback * 1.25))
    float demandDistance = clamp01((close - demandHigh) / (atrSafe * 2.5))
    float supplyDistance = clamp01((supplyLow - close) / (atrSafe * 2.5))

    float bullRaw = 0.34 * impulseScore + 0.26 * bullRetraceScore + 0.20 * rangeScore + 0.20 * (1.0 - slopePenaltyBull)
    float bearRaw = 0.34 * impulseScore + 0.26 * bearRetraceScore + 0.20 * rangeScore + 0.20 * (1.0 - slopePenaltyBear)

    float demandRaw = 0.58 * demandFreshness + 0.22 * demandDistance + 0.20 * clamp01((close - demandLow) / math.max(atrSafe * 3.0, syminfo.mintick))
    float supplyRaw = 0.58 * supplyFreshness + 0.22 * supplyDistance + 0.20 * clamp01((supplyHigh - close) / math.max(atrSafe * 3.0, syminfo.mintick))

    // Compress scores so 80+ is rarer
    float bullScore = math.pow(clamp01(bullRaw), 1.55)
    float bearScore = math.pow(clamp01(bearRaw), 1.55)
    float demandScore = math.pow(clamp01(demandRaw), 1.75)
    float supplyScore = math.pow(clamp01(supplyRaw), 1.75)

    int bestSig = 0
    float bestConf = -1.0
    bool bestFound = false
    bool bestActive = false

    if demandFound and demandScore > bestConf
        bestSig := 1
        bestConf := demandScore
        bestFound := true
        bestActive := demandActive

    if supplyFound and supplyScore > bestConf
        bestSig := 2
        bestConf := supplyScore
        bestFound := true
        bestActive := supplyActive

    if bullFlagFound and bullScore > bestConf
        bestSig := 3
        bestConf := bullScore
        bestFound := true
        bestActive := bullFlagActive

    if bearFlagFound and bearScore > bestConf
        bestSig := 4
        bestConf := bearScore
        bestFound := true
        bestActive := bearFlagActive

    // Penalize invalidated setups so they do not dominate sorted list
    if bestFound and not bestActive
        bestConf := bestConf * 0.55

    [bestSig, bestConf, close, atrSafe, bestFound ? 1.0 : 0.0, bestActive ? 1.0 : 0.0]

//================ SECURITY =================
eval(sym, tf) =>
    request.security(
        sym,
        tf,
        detectPacked(),
        barmerge.gaps_off,
        barmerge.lookahead_off,
        calc_bars_count = secBars
    )

//================ TABLE DATA ARRAYS =================
var array<string> rowSym    = array.new_string()
var array<string> rowSig    = array.new_string()
var array<string> rowState  = array.new_string()
var array<string> rowOpt    = array.new_string()
var array<string> rowStrike = array.new_string()
var array<string> rowTp     = array.new_string()

var array<float> rowConf    = array.new_float()
var array<float> rowOrder   = array.new_float()
var array<bool> rowActive   = array.new_bool()
var array<color> rowBg      = array.new_color()

//================ TABLE =================
rowsNeeded = 1 + maxSymbolsToScan
var table t = table.new(position.top_right, 7, rowsNeeded, frame_color=color.new(color.gray, 75), border_width=1)

if barstate.islast
    array.clear(rowSym)
    array.clear(rowSig)
    array.clear(rowState)
    array.clear(rowOpt)
    array.clear(rowStrike)
    array.clear(rowTp)
    array.clear(rowConf)
    array.clear(rowOrder)
    array.clear(rowActive)
    array.clear(rowBg)

    int scanCount = math.min(array.size(symbols), maxSymbolsToScan)

    for i = 0 to scanCount - 1
        string sym = array.get(symbols, i)

        int sigA = 0
        float confA = -1.0
        float cA = na
        float aA = na
        bool foundA = false
        bool activeA = false

        int sigB = 0
        float confB = -1.0
        float cB = na
        float aB = na
        bool foundB = false
        bool activeB = false

        if useTf1
            [sig1, conf1, c1, a1, found1, active1] = eval(sym, tf1)
            sigA := sig1
            confA := conf1
            cA := c1
            aA := a1
            foundA := found1 > 0
            activeA := active1 > 0

        if useTf2
            [sig2, conf2, c2, a2, found2, active2] = eval(sym, tf2)
            sigB := sig2
            confB := conf2
            cB := c2
            aB := a2
            foundB := found2 > 0
            activeB := active2 > 0

        bool anyFound = foundA or foundB
        bool anyActive = activeA or activeB

        if anyFound
            int finalSig = 0
            float finalConf = -1.0
            float cOpt = na
            float aOpt = na
            bool finalActive = false

            if confA >= confB
                finalSig := sigA
                finalConf := confA
                cOpt := cA
                aOpt := aA
                finalActive := activeA
            else
                finalSig := sigB
                finalConf := confB
                cOpt := cB
                aOpt := aB
                finalActive := activeB

            bool sameSignal = useTf1 and useTf2 and foundA and foundB and sigA == sigB and sigA != 0
            if sameSignal
                finalConf := math.max(confA, confB) + (anyActive ? 0.05 : 0.02)
                finalConf := clamp01(finalConf)

            if anyActive or showInvalidated
                float step = stepByPrice(cOpt)
                float strike = roundNearest(cOpt, step)

                bool bullish = isBullish(finalSig)

                if strikeStyle == "REALISTIC OTM"
                    if bullish
                        strike := roundUp(cOpt, step) + step * (otmStepsMax - 1)
                    else
                        strike := roundDown(cOpt, step) - step * (otmStepsMax - 1)

                string autoSide = bullish ? "CALL" : "PUT"
                string optSide = optMode == "AUTO" ? autoSide : optMode
                string optTxt = optSide + " " + str.tostring(dteDays) + "D"

                float tp = bullish ? cOpt + aOpt * tpAtrMult : cOpt - aOpt * tpAtrMult
                int confScore = score100(finalConf)

                float orderScore = finalActive ? (1000 + confScore) : confScore

                array.push(rowSym, displayTicker(sym))
                array.push(rowSig, sigName(finalSig))
                array.push(rowState, stateText(finalActive, true))
                array.push(rowOpt, optTxt)
                array.push(rowStrike, str.tostring(strike))
                array.push(rowTp, fmtPrice(tp))
                array.push(rowConf, confScore)
                array.push(rowOrder, orderScore)
                array.push(rowActive, finalActive)
                array.push(rowBg, sigColor(finalSig, finalActive))

    // Sort by active first, then confidence descending
    int n = array.size(rowSym)
    if n > 1
        for i = 0 to n - 2
            int bestIdx = i
            float bestVal = array.get(rowOrder, i)
            for j = i + 1 to n - 1
                float curVal = array.get(rowOrder, j)
                if curVal > bestVal
                    bestVal := curVal
                    bestIdx := j
            if bestIdx != i
                string tmpSym = array.get(rowSym, i)
                string tmpSig = array.get(rowSig, i)
                string tmpState = array.get(rowState, i)
                string tmpOpt = array.get(rowOpt, i)
                string tmpStrike = array.get(rowStrike, i)
                string tmpTp = array.get(rowTp, i)

                float tmpConf = array.get(rowConf, i)
                float tmpOrder = array.get(rowOrder, i)
                bool tmpActive = array.get(rowActive, i)
                color tmpBg = array.get(rowBg, i)

                array.set(rowSym, i, array.get(rowSym, bestIdx))
                array.set(rowSig, i, array.get(rowSig, bestIdx))
                array.set(rowState, i, array.get(rowState, bestIdx))
                array.set(rowOpt, i, array.get(rowOpt, bestIdx))
                array.set(rowStrike, i, array.get(rowStrike, bestIdx))
                array.set(rowTp, i, array.get(rowTp, bestIdx))
                array.set(rowConf, i, array.get(rowConf, bestIdx))
                array.set(rowOrder, i, array.get(rowOrder, bestIdx))
                array.set(rowActive, i, array.get(rowActive, bestIdx))
                array.set(rowBg, i, array.get(rowBg, bestIdx))

                array.set(rowSym, bestIdx, tmpSym)
                array.set(rowSig, bestIdx, tmpSig)
                array.set(rowState, bestIdx, tmpState)
                array.set(rowOpt, bestIdx, tmpOpt)
                array.set(rowStrike, bestIdx, tmpStrike)
                array.set(rowTp, bestIdx, tmpTp)
                array.set(rowConf, bestIdx, tmpConf)
                array.set(rowOrder, bestIdx, tmpOrder)
                array.set(rowActive, bestIdx, tmpActive)
                array.set(rowBg, bestIdx, tmpBg)

    table.clear(t, 0, 0, 6, rowsNeeded - 1)

    table.cell(t, 0, 0, "SYMBOL", text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 1, 0, "SIGNAL", text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 2, 0, "STATE",  text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 3, 0, "CONF",   text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 4, 0, "OPT",    text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 5, 0, "STRIKE", text_color=fontColor, bgcolor=color.new(color.gray, 85))
    table.cell(t, 6, 0, "TP",     text_color=fontColor, bgcolor=color.new(color.gray, 85))

    int rowsToPrint = math.min(array.size(rowSym), maxSymbolsToScan)

    for r = 0 to rowsToPrint - 1
        int row = r + 1
        bool isActiveRow = array.get(rowActive, r)

        color rowTextColor = fontColor
        if grayInvalidated and not isActiveRow
            rowTextColor := color.new(color.white, 55)

        table.cell(t, 0, row, array.get(rowSym, r), text_color=rowTextColor)
        table.cell(t, 1, row, array.get(rowSig, r), text_color=color.white, bgcolor=array.get(rowBg, r))
        table.cell(t, 2, row, array.get(rowState, r), text_color=rowTextColor, bgcolor=isActiveRow ? color.new(color.green, 82) : color.new(color.gray, 80))
        table.cell(t, 3, row, str.tostring(int(array.get(rowConf, r))), text_color=color.white, bgcolor=confBg(int(array.get(rowConf, r)), isActiveRow))
        table.cell(t, 4, row, array.get(rowOpt, r), text_color=rowTextColor)
        table.cell(t, 5, row, array.get(rowStrike, r), text_color=rowTextColor)
        table.cell(t, 6, row, array.get(rowTp, r), text_color=rowTextColor)
````
