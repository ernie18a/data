# OTA Core Strategy Supply Demand Zones 8 out of 10 score minimum

- url: https://www.tradingview.com/script/aEvJVmL2-OTA-Core-Strategy-Supply-Demand-Zones-8-out-of-10-score-minimum/
- type: indicator
- pine_id: PUB;dfba1b5263b7469f864cf56569c2ad62
- version: 3.0

## Description

this is based on Online Trading Academy Core Strategy.

## Source Code

````pine
//@version=6
indicator(title="OTA Supply & Demand + Options Trigger", shorttitle="OTA S&D", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ===================================================================
//  OTA CORE STRATEGY -- SUPPLY & DEMAND ZONES + OPTIONS TRIGGER v8 (Pine v6)
//  -----------------------------------------------------------------
//  Add to ANY chart. Set one alert per ticker manually in TV.
//  Alert fires with full options strategy in the message.
//
//  ZONE DRAWING (OTA method):
//    Proximal = body edge only  (no wick)  -- entry line
//    Distal   = wick extreme               -- stop protection
//    DEMAND:  top=body high (proximal), bottom=wick low (distal)
//    SUPPLY:  bottom=body low (proximal),top=wick high (distal)
//
//  OPTIONS STRATEGY (IV/HV driven):
//    IV/HV > 1.20  RICH    -> Credit Spread
//    IV/HV 0.80-1.20 NEUTRAL -> Outright Option
//    IV/HV < 0.80  CHEAP   -> Debit Spread
//
//    DEMAND + RICH    -> Bull Put Spread
//    DEMAND + NEUTRAL -> Long Call (ITM)
//    DEMAND + CHEAP   -> Bull Call Spread
//    SUPPLY + RICH    -> Bear Call Spread
//    SUPPLY + NEUTRAL -> Long Put (ITM)
//    SUPPLY + CHEAP   -> Bear Put Spread
// ===================================================================


// -------------------------------------------------------------------
// 1. ZONE DETECTION
// -------------------------------------------------------------------
g1 = "1. Zone Detection"
lookback     = input.int(90,    "Lookback Bars",          minval=30,  maxval=500, group=g1)
baseMaxBars  = input.int(5,     "Base Max Candles",       minval=1,   maxval=10,  group=g1)
legMinBars   = input.int(2,     "Leg Min Candles",        minval=1,   maxval=5,   group=g1)
legBodyRatio = input.float(2.0, "Leg/Base Body Ratio",    minval=1.1, maxval=6.0, step=0.1, group=g1)
legMovePct   = input.float(0.4, "Min Leg Move %",         minval=0.1, maxval=3.0, step=0.1, group=g1)
minScore     = input.int(8,     "Min Zone Score (0-10)",  minval=0,   maxval=10,  group=g1)
freshOnly    = input.bool(false, "Fresh Zones Only",      group=g1)
showMitig    = input.bool(true,  "Keep Zone Until SL Hit (Mitigated)", group=g1, tooltip="ON = zone stays visible (grayed) after proximal touch until price closes through distal (SL). OFF = zone disappears on first touch.")


// -------------------------------------------------------------------
// 2. APPEARANCE
// -------------------------------------------------------------------
g2 = "2. Appearance"
demandFill   = input.color(color.new(#00e676, 80), "Demand Fill",   group=g2)
demandBord   = input.color(color.new(#00e676, 20), "Demand Border", group=g2)
supplyFill   = input.color(color.new(#ff1744, 80), "Supply Fill",   group=g2)
supplyBord   = input.color(color.new(#ff1744, 20), "Supply Border", group=g2)
testedFill   = input.color(color.new(#ffd600, 85), "Tested Fill",   group=g2)
mitigFill    = input.color(color.new(#546e7a, 75), "SL Hit (Mitigated) Fill", group=g2, tooltip="Color shown when price closed through distal line (stop loss hit). Zone stays visible so you can see history.")
extBars      = input.int(40,    "Extend Zones (bars)",   minval=0, maxval=300, group=g2)
showLbl      = input.bool(true,  "Show Zone Labels",     group=g2)
lblSize      = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=g2)


// -------------------------------------------------------------------
// 3. OPTIONS ENGINE
// -------------------------------------------------------------------
g3 = "3. Options Engine"
ivRichThr    = input.float(1.20, "IV/HV Rich  -> Credit Spread", minval=0.8, maxval=3.0, step=0.05, group=g3)
ivCheapThr   = input.float(0.80, "IV/HV Cheap -> Debit Spread",  minval=0.3, maxval=1.2, step=0.05, group=g3)
minDTE       = input.int(60,    "Min DTE",  minval=7,  maxval=180, group=g3)
maxDTE       = input.int(90,    "Max DTE",  minval=14, maxval=365, group=g3)
spreadPct    = input.float(3.0, "Spread Width % of Price", minval=1.0, maxval=10.0, step=0.5, group=g3)
slBufPct     = input.float(0.5, "SL Buffer %", minval=0.0, maxval=5.0, step=0.1, group=g3)
showOptDash  = input.bool(true,  "Show Options Dashboard", group=g3)
showStrikes  = input.bool(true,  "Show Strike Lines",      group=g3)


// -------------------------------------------------------------------
// 4. ALERTS
// -------------------------------------------------------------------
g4 = "4. Alerts"
alertEntry   = input.bool(true, "Alert: Price Enters Zone",      group=g4)
alertApproach= input.bool(true, "Alert: Price Approaching (0.3%)", group=g4)


// ===================================================================
//  IV / HV ENGINE
// ===================================================================

logRet    = math.log(close / close[1])
hv20      = ta.stdev(logRet, 20) * math.sqrt(252) * 100
atr14     = ta.atr(14)
ivProxy   = close > 0 ? (atr14 / close) * math.sqrt(252) * 100 : hv20
ivHvRatio = hv20 > 0 ? ivProxy / hv20 : 1.0

ivRich    = ivHvRatio >= ivRichThr
ivCheap   = ivHvRatio <= ivCheapThr
ivNeutral = not ivRich and not ivCheap

ivEnvStr  = ivRich ? "RICH" : ivCheap ? "CHEAP" : "NEUTRAL"
ivColor   = ivRich ? color.new(#ff9800,0) : ivCheap ? color.new(#00e676,0) : color.new(#8888ff,0)
dteStr    = str.tostring(minDTE) + "-" + str.tostring(maxDTE) + "DTE"


// ===================================================================
//  STRIKE HELPERS
// ===================================================================

f_roundStrike(p) =>
    p >= 200 ? math.round(p / 5) * 5.0 : p >= 100 ? math.round(p / 2.5) * 2.5 : math.round(p * 2) / 2.0

f_labelSize() =>
    lblSize == "tiny" ? size.tiny : lblSize == "small" ? size.small : lblSize == "normal" ? size.normal : size.large


// ===================================================================
//  DELTA-BASED STRIKE CALCULATOR
//  -----------------------------------------------------------------
//  Credit spreads target combined delta ~ 0.25
//    Short leg delta ~ 0.30  (1 SD OTM -- collects bulk of premium)
//    Long  leg delta ~ 0.05  (2 SD OTM -- cheap protection)
//    Net combined delta ~ 0.25
//
//  Approximation using Black-Scholes N(d1) inversion:
//    Strike for delta D ~ S x exp(-N_inv(D) x sigma x sqrtT + (r + sigma2/2) x T)
//    where sigma = IV proxy, T = DTE/365, r = risk-free rate
//
//  N_inv approximation (Beasley-Springer-Moro):
//    For delta=0.30 -> z ~ -0.524  -> strike below price
//    For delta=0.70 -> z ~ +0.524  -> strike above price
//    For delta=0.05 -> z ~ -1.645
//    For delta=0.95 -> z ~ +1.645
//
//  Debit spreads target long leg ITM at SL level (max protection)
//    Long  leg: strike at stop loss level
//    Short leg: strike at long + spread width (OTM, reduces cost)
// ===================================================================

// Normal CDF approximation (Hart 1968)
f_normCDF(x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989423 * math.exp(-x * x / 2.0)
    float p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.7814779 + t * (-1.8212560 + t * 1.3302744))))
    x >= 0 ? 1.0 - p : p

// Black-Scholes delta for call: N(d1)
// d1 = (ln(S/K) + (r + sigma2/2)xT) / (sigmaxsqrtT)
f_callDelta(S, K, T, sigma, r) =>
    float d1 = T > 0 and sigma > 0 ? (math.log(S / K) + (r + sigma * sigma / 2.0) * T) / (sigma * math.sqrt(T)) : 0.0
    f_normCDF(d1)

// Put delta = call delta - 1
f_putDelta(S, K, T, sigma, r) =>
    f_callDelta(S, K, T, sigma, r) - 1.0

// Find strike price for target delta using bisection search
// isDemand=true  + isShort=true  -> PUT short leg (target delta ~ -0.30)
// isDemand=true  + isShort=false -> PUT long  leg (target delta ~ -0.05)
// isDemand=false + isShort=true  -> CALL short leg (target delta ~ +0.30)
// isDemand=false + isShort=false -> CALL long  leg (target delta ~ +0.05)
f_strikeForDelta(S, targetDelta, T, sigma, r, isCall) =>
    // Bisection: search for K where delta(K) = targetDelta
    float lo = S * 0.50
    float hi = S * 1.50
    float K  = S
    for _i = 0 to 30
        K := (lo + hi) / 2.0
        float d = isCall ? f_callDelta(S, K, T, sigma, r) : f_putDelta(S, K, T, sigma, r)
        if isCall
            // Call delta decreases as K increases
            if d > targetDelta
                lo := K
            else
                hi := K
        else
            // Put delta increases (less negative) as K increases
            if d < targetDelta
                hi := K
            else
                lo := K
    f_roundStrike(K)

// Spread width for debit spreads (% of price)
f_spreadWidth(p) =>
    raw = p * spreadPct / 100.0
    p >= 200 ? math.round(raw / 5) * 5.0 : p >= 100 ? math.round(raw / 2.5) * 2.5 : math.max(math.round(raw), 1.0)


// ===================================================================
//  OPTIONS STRATEGY SELECTOR
//  Returns string: "StratName|L1Action|L1Type|L1Strike|L2Action|L2Type|L2Strike"
//  -----------------------------------------------------------------
//  CREDIT SPREADS (IV Rich > 1.20):
//    Short leg: delta ~ 0.30 (combined net delta target = 0.25)
//    Long  leg: delta ~ 0.05 (cheap OTM protection)
//    Net combined delta ~ 0.25
//
//  OUTRIGHT (IV Neutral 0.80-1.20):
//    Single leg ITM at stop loss level
//    Delta ~ 0.60-0.80 (deep enough to move with stock)
//
//  DEBIT SPREADS (IV Cheap < 0.80):
//    Long  leg: at stop loss level (ITM, high delta)
//    Short leg: OTM by spread width (reduces cost)
// ===================================================================

f_strategy(isDemand, proximal, sl, price) =>
    // DTE midpoint in years
    float T     = (minDTE + maxDTE) / 2.0 / 365.0
    float sigma = ivProxy / 100.0
    float r     = 0.05  // risk-free rate
    string out  = ""

    if isDemand
        if ivRich
            // Bull Put Spread -- combined delta ~ 0.25
            // Short PUT at delta -0.30 (below current price)
            // Long  PUT at delta -0.05 (further below, cheap hedge)
            float k1 = f_strikeForDelta(price, -0.30, T, sigma, r, false)
            float k2 = f_strikeForDelta(price, -0.05, T, sigma, r, false)
            out := "Bull Put Spread|SELL|PUT|" + str.tostring(k1, "#.##") + "|BUY|PUT|" + str.tostring(k2, "#.##")
        else if ivNeutral
            // Long Call ITM -- strike at stop loss level for high delta
            float k1 = f_roundStrike(sl)
            out := "Long Call|BUY|CALL|" + str.tostring(k1, "#.##") + "|||"
        else
            // Bull Call Spread -- long leg at SL, short leg OTM
            float k1 = f_roundStrike(sl)
            float k2 = f_roundStrike(sl + f_spreadWidth(price))
            out := "Bull Call Spread|BUY|CALL|" + str.tostring(k1, "#.##") + "|SELL|CALL|" + str.tostring(k2, "#.##")
    else
        if ivRich
            // Bear Call Spread -- combined delta ~ -0.25
            // Short CALL at delta +0.30 (above current price)
            // Long  CALL at delta +0.05 (further above, cheap hedge)
            float k1 = f_strikeForDelta(price, 0.30, T, sigma, r, true)
            float k2 = f_strikeForDelta(price, 0.05, T, sigma, r, true)
            out := "Bear Call Spread|SELL|CALL|" + str.tostring(k1, "#.##") + "|BUY|CALL|" + str.tostring(k2, "#.##")
        else if ivNeutral
            // Long Put ITM -- strike at stop loss level for high delta
            float k1 = f_roundStrike(sl)
            out := "Long Put|BUY|PUT|" + str.tostring(k1, "#.##") + "|||"
        else
            // Bear Put Spread -- long leg at SL, short leg OTM
            float k1 = f_roundStrike(sl)
            float k2 = f_roundStrike(sl - f_spreadWidth(price))
            out := "Bear Put Spread|BUY|PUT|" + str.tostring(k1, "#.##") + "|SELL|PUT|" + str.tostring(k2, "#.##")
    out

// Parse strategy string parts
f_sName(s)    => array.get(str.split(s, "|"), 0)
f_l1Act(s)    => array.get(str.split(s, "|"), 1)
f_l1Typ(s)    => array.get(str.split(s, "|"), 2)
f_l1Str(s)    => array.get(str.split(s, "|"), 3)
f_l2Act(s)    => array.get(str.split(s, "|"), 4)
f_l2Typ(s)    => array.get(str.split(s, "|"), 5)
f_l2Str(s)    => array.get(str.split(s, "|"), 6)
f_isOutright(s) => str.length(array.get(str.split(s, "|"), 4)) == 0
f_isCredit(s)   =>
    string nm = array.get(str.split(s, "|"), 0)
    nm == "Bull Put Spread" or nm == "Bear Call Spread"


// ===================================================================
//  ZONE DETECTION HELPERS
// ===================================================================

f_body(i)    => math.abs(close[i] - open[i])
f_range(i)   => high[i] - low[i]
f_movePct(i) => close[i] > 0 ? f_body(i) / close[i] * 100 : 0.0
f_isBull(i)  => close[i] > open[i] and f_movePct(i) >= legMovePct
f_isBear(i)  => close[i] < open[i] and f_movePct(i) >= legMovePct

f_avgBody(offset, n) =>
    float total = 0.0
    for k = 0 to n - 1
        total += f_body(offset + k)
    total / math.max(n, 1)

f_avgVol(offset, n) =>
    float total = 0.0
    for k = 0 to n - 1
        total += volume[offset + k]
    total / math.max(n, 1)

f_bullLeg(offset, n) =>
    bool  ok  = true
    float avg = 0.0
    for k = 0 to n - 1
        if not f_isBull(offset + k)
            ok := false
        avg += f_body(offset + k)
    [ok, avg / math.max(n, 1)]

f_bearLeg(offset, n) =>
    bool  ok  = true
    float avg = 0.0
    for k = 0 to n - 1
        if not f_isBear(offset + k)
            ok := false
        avg += f_body(offset + k)
    [ok, avg / math.max(n, 1)]

f_baseValid(baseOff, baseN, legAvg) =>
    bool  ok      = true
    float baseAvg = f_avgBody(baseOff, baseN)
    if baseAvg >= legAvg / legBodyRatio
        ok := false
    for k = 0 to baseN - 1
        if f_body(baseOff + k) >= legAvg * 0.65
            ok := false
    ok

// OTA proximal/distal -- body only on proximal, wick on distal
f_zoneEdges(baseOff, baseN, isDemand) =>
    float bodyHigh = 0.0
    float bodyLow  = 999999.0
    float wickHigh = 0.0
    float wickLow  = 999999.0
    for k = 0 to baseN - 1
        int   idx     = baseOff + k
        float bTop    = math.max(close[idx], open[idx])
        float bBot    = math.min(close[idx], open[idx])
        bodyHigh     := math.max(bodyHigh, bTop)
        bodyLow      := math.min(bodyLow,  bBot)
        wickHigh     := math.max(wickHigh, high[idx])
        wickLow      := math.min(wickLow,  low[idx])
    // DEMAND: Proximal=bodyHigh (top, no wick), Distal=wickLow (bottom, full wick)
    // SUPPLY: Proximal=bodyLow  (bottom, no wick), Distal=wickHigh (top, full wick)
    float proximal = isDemand ? bodyHigh : bodyLow
    float distal   = isDemand ? wickLow  : wickHigh
    [proximal, distal]

f_countTests(zProx, zDist, isDemand, formedBar) =>
    int tests = 0
    float zTop = isDemand ? zProx : zDist
    float zBot = isDemand ? zDist : zProx
    for j = 0 to formedBar - 1
        if low[j] <= zTop and high[j] >= zBot
            tests += 1
    tests

f_mitigated(zProx, zDist, isDemand, formedBar) =>
    // Zone is mitigated ONLY when a candle CLOSES beyond the distal line
    // Distal = wick extreme (stop loss level)
    // Touching proximal does NOT remove the zone
    // Zone stays visible until close breaks through distal
    bool mit = false
    for j = 0 to formedBar - 1
        if isDemand and close[j] < zDist
            mit := true
        if not isDemand and close[j] > zDist
            mit := true
    mit

f_score(baseOff, baseN, legOff, legN, tests, isDemand) =>
    int sc = 0
    // Tight base
    sc += baseN <= 2 ? 2 : baseN <= 4 ? 1 : 0
    // Explosive leg
    float la = f_avgBody(legOff, legN)
    float ba = f_avgBody(baseOff, baseN)
    float r  = ba > 0 ? la / ba : 0.0
    sc += r >= 4.0 ? 2 : r >= 2.0 ? 1 : 0
    // Freshness
    sc += tests == 0 ? 2 : tests == 1 ? 1 : 0
    // Strong close on leg candle
    float rng = f_range(legOff)
    if rng > 0
        float cp = (close[legOff] - low[legOff]) / rng
        if isDemand and cp >= 0.70
            sc += 1
        if not isDemand and cp <= 0.30
            sc += 1
    // Volume spike on leg
    float avgV = f_avgVol(legOff + legN, 20)
    if avgV > 0 and volume[legOff] > avgV * 1.5
        sc += 1
    // ATR expansion on leg
    float legRange = 0.0
    for k = 0 to legN - 1
        legRange += f_range(legOff + k)
    if atr14 > 0 and legRange > atr14 * legN * 1.5
        sc += 1
    math.min(sc, 10)


// ===================================================================
//  ZONE DRAWING
// ===================================================================

f_drawZone(proximal, distal, isDemand, isFresh, isMit, score, pattern, leftBar, strat) =>
    // Colors
    // Zone colors -- active, tested, or mitigated (SL hit)
    color fillC  = isMit ? mitigFill : isFresh ? (isDemand ? demandFill : supplyFill) : testedFill
    color bordC  = isMit ? color.new(#546e7a, 60) : isFresh ? (isDemand ? demandBord : supplyBord) : color.new(#ffd600, 40)
    // Proximal line color -- dim when mitigated
    color proxC  = isMit ? color.new(#546e7a, 60) : color.new(#ffffff, 40)
    // Distal line color -- red tint to show SL level clearly
    color distC  = isMit ? color.new(#ff1744, 80) : color.new(#ff6060, 55)

    // Zone box: demand = bottom(distal/wick) to top(proximal/body)
    //           supply = bottom(proximal/body) to top(distal/wick)
    float boxTop = isDemand ? proximal : distal
    float boxBot = isDemand ? distal   : proximal

    box.new(left=leftBar, right=bar_index + extBars, top=boxTop, bottom=boxBot, bgcolor=fillC, border_color=bordC, border_width=1, extend=extend.right)

    // Proximal dashed line (entry trigger -- body edge, no wick)
    line.new(x1=leftBar, y1=proximal, x2=bar_index + extBars, y2=proximal, color=proxC, width=1, style=line.style_dashed, extend=extend.right)

    // Distal dotted line (STOP LOSS level -- wick extreme -- zone removed if close breaks this)
    line.new(x1=leftBar, y1=distal, x2=bar_index + extBars, y2=distal, color=distC, width=2, style=line.style_dotted, extend=extend.right)

    // Strike lines
    if showStrikes and str.length(strat) > 0
        float k1val = str.tonumber(f_l1Str(strat))
        if not na(k1val)
            color skColor = f_isCredit(strat) ? color.new(#00d4ff, 40) : color.new(#ff9800, 40)
            line.new(x1=leftBar, y1=k1val, x2=bar_index + extBars, y2=k1val, color=skColor, width=1, style=line.style_dotted, extend=extend.right)
            label.new(x=bar_index + extBars, y=k1val, text=f_l1Act(strat) + " " + f_l1Typ(strat) + " $" + f_l1Str(strat), color=color.new(#000000, 100), textcolor=skColor, style=label.style_label_left, size=size.tiny)
        if not f_isOutright(strat)
            float k2val = str.tonumber(f_l2Str(strat))
            if not na(k2val)
                color sk2Color = color.new(f_isCredit(strat) ? #00d4ff : #ff9800, 65)
                line.new(x1=leftBar, y1=k2val, x2=bar_index + extBars, y2=k2val, color=sk2Color, width=1, style=line.style_dotted, extend=extend.right)
                label.new(x=bar_index + extBars, y=k2val, text=f_l2Act(strat) + " " + f_l2Typ(strat) + " $" + f_l2Str(strat), color=color.new(#000000, 100), textcolor=sk2Color, style=label.style_label_left, size=size.tiny)

    // Zone label
    if showLbl
        string zType  = isDemand ? "DEMAND" : "SUPPLY"
        string fresh  = isFresh ? "FRESH" : "TESTED"
        string sName  = str.length(strat) > 0 ? f_sName(strat) : ""
        string l1     = str.length(strat) > 0 ? f_l1Act(strat) + " " + f_l1Typ(strat) + " $" + f_l1Str(strat) : ""
        string l2     = str.length(strat) > 0 and not f_isOutright(strat) ? " / " + f_l2Act(strat) + " " + f_l2Typ(strat) + " $" + f_l2Str(strat) : ""
        string ivLine = "IV/HV " + str.tostring(ivHvRatio, "#.##") + " [" + ivEnvStr + "]"
        string mitTag  = isMit ? " ! SL HIT" : ""
        string lblTxt = zType + " [" + pattern + "] " + fresh + " " + str.tostring(score) + "/10" + mitTag + "\nP: $" + str.tostring(proximal, "#.##") + "  D: $" + str.tostring(distal, "#.##") + "\n" + sName + "\n" + l1 + l2 + "\n" + dteStr + " " + ivLine
        color  lblClr = isDemand ? #00e676 : #ff5252
        float  lblY   = isDemand ? distal - (boxTop - boxBot) * 0.3 : distal + (boxTop - boxBot) * 0.3
        label.new(x=bar_index + extBars, y=lblY, text=lblTxt, color=color.new(isDemand ? #001a08 : #1a0008, 5), textcolor=lblClr, style=isDemand ? label.style_label_up : label.style_label_down, size=f_labelSize())


// ===================================================================
//  MAIN SCAN LOOP
// ===================================================================

var int  dCount  = 0
var int  sCount  = 0
var int  dFresh  = 0
var int  sFresh  = 0
var int  dTopSc  = 0
var int  sTopSc  = 0

// Best zone trackers for dashboard + alerts
var float dProx  = na
var float dDist  = na
var string dStrat= ""
var string dPat  = ""
var int    dSc   = 0

var float sProx  = na
var float sDist  = na
var string sStrat= ""
var string sPat  = ""
var int    sSc   = 0

if barstate.islast
    dCount := 0
    sCount := 0
    dFresh := 0
    sFresh := 0
    dTopSc := 0
    sTopSc := 0
    dProx  := na
    dDist  := na
    dStrat := ""
    dSc    := 0
    sProx  := na
    sDist  := na
    sStrat := ""
    sSc    := 0

    for i = legMinBars to lookback - baseMaxBars - legMinBars - 2
        for bn = 1 to baseMaxBars
            for ln = 1 to legMinBars
                int legOff  = i
                int baseOff = i + ln
                if baseOff + bn >= lookback
                    continue

                // -- DEMAND (bull leg out of base) -----------------
                [bullOk, bullAvg] = f_bullLeg(legOff, ln)
                if bullOk and f_baseValid(baseOff, bn, bullAvg)
                    [prox, dist] = f_zoneEdges(baseOff, bn, true)
                    int   tests  = f_countTests(prox, dist, true, legOff)
                    bool  mit    = f_mitigated(prox, dist, true, legOff)
                    int   sc     = f_score(baseOff, bn, legOff, ln, tests, true)
                    string pat   = close[baseOff + bn] > open[baseOff + bn] ? "RBR" : "DBR"
                    if sc >= minScore and (not mit or showMitig) and (not freshOnly or tests == 0)
                        if dCount < 5
                            dCount += 1
                            if tests == 0
                                dFresh += 1
                            if sc > dTopSc
                                dTopSc := sc
                            float slLevel = dist - (prox - dist) * (slBufPct / 100.0)
                            string st     = f_strategy(true, prox, slLevel, close)
                            if sc > dSc
                                dSc    := sc
                                dProx  := prox
                                dDist  := dist
                                dStrat := st
                                dPat   := pat
                            int lb = bar_index - baseOff - bn + 1
                            f_drawZone(prox, dist, true, tests == 0, mit, sc, pat, lb, st)

                // -- SUPPLY (bear leg out of base) -----------------
                [bearOk, bearAvg] = f_bearLeg(legOff, ln)
                if bearOk and f_baseValid(baseOff, bn, bearAvg)
                    [prox, dist] = f_zoneEdges(baseOff, bn, false)
                    int   tests  = f_countTests(prox, dist, false, legOff)
                    bool  mit    = f_mitigated(prox, dist, false, legOff)
                    int   sc     = f_score(baseOff, bn, legOff, ln, tests, false)
                    string pat   = close[baseOff + bn] < open[baseOff + bn] ? "DBD" : "RBD"
                    if sc >= minScore and (not mit or showMitig) and (not freshOnly or tests == 0)
                        if sCount < 5
                            sCount += 1
                            if tests == 0
                                sFresh += 1
                            if sc > sTopSc
                                sTopSc := sc
                            float slLevel = dist + (dist - prox) * (slBufPct / 100.0)
                            string st     = f_strategy(false, prox, slLevel, close)
                            if sc > sSc
                                sSc    := sc
                                sProx  := prox
                                sDist  := dist
                                sStrat := st
                                sPat   := pat
                            int lb = bar_index - baseOff - bn + 1
                            f_drawZone(prox, dist, false, tests == 0, mit, sc, pat, lb, st)


// ===================================================================
//  DASHBOARD
// ===================================================================

var table dash = table.new(position.top_right, 2, 18, bgcolor=color.new(#07070f, 5), border_color=color.new(#2a2a5a, 50), border_width=1, frame_color=color.new(#4040aa, 60), frame_width=1)

if showOptDash and barstate.islast

    // Header
    table.cell(dash, 0, 0, "OTA S&D + OPTIONS",      text_color=#ffffff,   text_size=size.small, bgcolor=color.new(#12082a, 10), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.tickerid + " " + timeframe.period, text_color=#aa88ff, text_size=size.small, bgcolor=color.new(#12082a, 10), text_halign=text.align_center)

    // Zone counts
    table.cell(dash, 0, 1, "DEMAND ZONES",  text_color=#00e676, text_size=size.small, bgcolor=color.new(#001a0a, 20))
    table.cell(dash, 1, 1, str.tostring(dCount) + "  (" + str.tostring(dFresh) + " fresh)", text_color=#00e676, text_size=size.small, bgcolor=color.new(#001a0a, 20))
    table.cell(dash, 0, 2, "SUPPLY ZONES",  text_color=#ff5252, text_size=size.small, bgcolor=color.new(#1a0000, 20))
    table.cell(dash, 1, 2, str.tostring(sCount) + "  (" + str.tostring(sFresh) + " fresh)", text_color=#ff5252, text_size=size.small, bgcolor=color.new(#1a0000, 20))

    // IV/HV
    table.cell(dash, 0, 3, "IV / HV",       text_color=#5050a0, text_size=size.tiny,  bgcolor=color.new(#050510, 30))
    table.cell(dash, 1, 3, str.tostring(ivHvRatio, "#.##") + " [" + ivEnvStr + "]", text_color=ivColor, text_size=size.small, bgcolor=color.new(#050510, 30))
    table.cell(dash, 0, 4, "HV20",          text_color=#5050a0, text_size=size.tiny,  bgcolor=color.new(#050510, 40))
    table.cell(dash, 1, 4, str.tostring(hv20, "#.1") + "%", text_color=#9090c0, text_size=size.tiny, bgcolor=color.new(#050510, 40))
    table.cell(dash, 0, 5, "IV Proxy",      text_color=#5050a0, text_size=size.tiny,  bgcolor=color.new(#050510, 40))
    table.cell(dash, 1, 5, str.tostring(ivProxy, "#.1") + "%", text_color=#9090c0, text_size=size.tiny, bgcolor=color.new(#050510, 40))

    // Demand setup
    table.cell(dash, 0, 6, "CALL SETUP",    text_color=#00e676, text_size=size.small, bgcolor=color.new(#001a0a, 15))
    table.cell(dash, 1, 6, na(dProx) ? "no zone" : dPat + " " + str.tostring(dSc) + "/10", text_color=#00e676, text_size=size.tiny, bgcolor=color.new(#001a0a, 15))
    table.cell(dash, 0, 7, "  Strategy",    text_color=#50a070, text_size=size.tiny,  bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 1, 7, na(dProx) ? "--" : f_sName(dStrat), text_color=#00ff88, text_size=size.tiny, bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 0, 8, "  Proximal",    text_color=#50a070, text_size=size.tiny,  bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 1, 8, na(dProx) ? "--" : "$" + str.tostring(dProx, "#.##"), text_color=#00e676, text_size=size.tiny, bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 0, 9, "  Distal (SL)", text_color=#50a070, text_size=size.tiny,  bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 1, 9, na(dDist) ? "--" : "$" + str.tostring(dDist, "#.##"), text_color=#ff8888, text_size=size.tiny, bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 0, 10, "  Leg 1",      text_color=#50a070, text_size=size.tiny,  bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 1, 10, na(dProx) ? "--" : f_l1Act(dStrat) + " " + f_l1Typ(dStrat) + " $" + f_l1Str(dStrat) + (f_isCredit(dStrat) ? " d~-0.30" : ""), text_color=#00ff44, text_size=size.small, bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 0, 11, "  Leg 2",      text_color=#50a070, text_size=size.tiny,  bgcolor=color.new(#001a0a, 40))
    table.cell(dash, 1, 11, na(dProx) ? "--" : f_isOutright(dStrat) ? "single leg" : f_l2Act(dStrat) + " " + f_l2Typ(dStrat) + " $" + f_l2Str(dStrat) + (f_isCredit(dStrat) ? " d~-0.05" : ""), text_color=#00cc44, text_size=size.tiny, bgcolor=color.new(#001a0a, 40))

    // Supply setup
    table.cell(dash, 0, 12, "PUT SETUP",    text_color=#ff5252, text_size=size.small, bgcolor=color.new(#1a0000, 15))
    table.cell(dash, 1, 12, na(sProx) ? "no zone" : sPat + " " + str.tostring(sSc) + "/10", text_color=#ff5252, text_size=size.tiny, bgcolor=color.new(#1a0000, 15))
    table.cell(dash, 0, 13, "  Strategy",   text_color=#a05060, text_size=size.tiny,  bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 1, 13, na(sProx) ? "--" : f_sName(sStrat), text_color=#ff8888, text_size=size.tiny, bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 0, 14, "  Proximal",   text_color=#a05060, text_size=size.tiny,  bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 1, 14, na(sProx) ? "--" : "$" + str.tostring(sProx, "#.##"), text_color=#ff5252, text_size=size.tiny, bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 0, 15, "  Distal (SL)",text_color=#a05060, text_size=size.tiny,  bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 1, 15, na(sDist) ? "--" : "$" + str.tostring(sDist, "#.##"), text_color=#ff8888, text_size=size.tiny, bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 0, 16, "  Leg 1",      text_color=#a05060, text_size=size.tiny,  bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 1, 16, na(sProx) ? "--" : f_l1Act(sStrat) + " " + f_l1Typ(sStrat) + " $" + f_l1Str(sStrat) + (f_isCredit(sStrat) ? " d~+0.30" : ""), text_color=#ff2244, text_size=size.small, bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 0, 17, "  Leg 2",      text_color=#a05060, text_size=size.tiny,  bgcolor=color.new(#1a0000, 40))
    table.cell(dash, 1, 17, na(sProx) ? "--" : f_isOutright(sStrat) ? "single leg" : f_l2Act(sStrat) + " " + f_l2Typ(sStrat) + " $" + f_l2Str(sStrat) + (f_isCredit(sStrat) ? " d~+0.05" : ""), text_color=#cc2244, text_size=size.tiny, bgcolor=color.new(#1a0000, 40))


// ===================================================================
//  ALERTS
// ===================================================================
// Strategy and zone levels are computed fresh each bar using
// the best zone found on barstate.islast -- stored in var variables
// so they persist and are available when alerts fire on every bar.
//
// DISCORD WEBHOOK FORMAT:
//   In TradingView Alert settings set Message to:
//   {{ticker}} -- leave the rest to the alert() call below.
//   The alert() message IS the Discord message body.

// -- Real-time zone boundary (recalculated every bar) -------------
// Use body-based proximal and wick-based distal on rolling window
float rtBodyHigh = math.max(ta.highest(close, 20), ta.highest(open, 20))
float rtBodyLow  = math.min(ta.lowest(close,  20), ta.lowest(open,  20))
float rtWickHigh = ta.highest(high, 20)
float rtWickLow  = ta.lowest(low,  20)

// Demand zone: Proximal=bodyHigh, Distal=wickLow
float rtDemProx  = rtBodyHigh
float rtDemDist  = rtWickLow
// Supply zone: Proximal=bodyLow, Distal=wickHigh
float rtSupProx  = rtBodyLow
float rtSupDist  = rtWickHigh

// Zone width for approach threshold
float demWidth   = rtDemProx - rtDemDist
float supWidth   = rtSupDist - rtSupProx
float apprPct    = 0.003  // 0.3% approach distance

// -- Zone conditions -----------------------------------------------
// IN zone  = price between distal and proximal
// APPROACH = price within 0.3% of proximal, outside zone
bool inDemandZone  = close <= rtDemProx and close >= rtDemDist
bool inSupplyZone  = close >= rtSupProx and close <= rtSupDist
bool approachDem   = not inDemandZone and close <= rtDemProx * (1 + apprPct) and close >= rtDemDist
bool approachSup   = not inSupplyZone and close >= rtSupProx * (1 - apprPct) and close <= rtSupDist

// Detect transitions (first bar entering zone or approaching)
bool enteredDemand = inDemandZone  and not inDemandZone[1]
bool enteredSupply = inSupplyZone  and not inSupplyZone[1]
bool approachingD  = approachDem   and not approachDem[1]
bool approachingS  = approachSup   and not approachSup[1]

// -- Compute live strategy string for current bar ------------------
// Recalculate on every bar so alert always has correct values
float liveDemSL    = rtDemDist - demWidth * (slBufPct / 100.0)
float liveSupSL    = rtSupDist + supWidth * (slBufPct / 100.0)
string liveDemStrat = f_strategy(true,  rtDemProx, liveDemSL, close)
string liveSupStrat = f_strategy(false, rtSupProx, liveSupSL, close)

// -- Alert message builder -----------------------------------------
// Formatted for Discord -- clear sections, all data in one message
f_msg(signal, zType, action, prox, dist, strat) =>
    string isDem   = zType == "DEMAND" ? "^" : "v"
    string ivTag   = ivRich ? "RICH" : ivCheap ? "CHEAP" : "NEUTRAL"
    string sname   = f_sName(strat)
    string leg1    = f_l1Act(strat) + " " + f_l1Typ(strat) + " $" + f_l1Str(strat)
    string leg2    = f_isOutright(strat) ? "" : "\nLeg 2: " + f_l2Act(strat) + " " + f_l2Typ(strat) + " $" + f_l2Str(strat)
    string line1   = isDem + " " + signal + " | " + syminfo.tickerid + " | " + zType
    string line2   = "Price:    $" + str.tostring(close, "#.##")
    string line3   = "Proximal: $" + str.tostring(prox, "#.##") + " (entry)"
    string line4   = "Distal:   $" + str.tostring(dist, "#.##") + " (SL ref)"
    string line5   = "Strategy: " + sname
    string line6   = "Leg 1: " + leg1 + leg2
    string line7   = "IV/HV: " + str.tostring(ivHvRatio, "#.##") + " [" + ivTag + "]  " + dteStr
    string line8   = "Action: " + action
    line1 + "\n" + line2 + "\n" + line3 + "\n" + line4 + "\n" + line5 + "\n" + line6 + "\n" + line7 + "\n" + line8

// -- Fire alerts ---------------------------------------------------
if alertEntry
    if enteredDemand
        alert(f_msg("ZONE ENTRY", "DEMAND", "Prepare LONG / CALL entry at proximal", rtDemProx, rtDemDist, liveDemStrat), alert.freq_once_per_bar)
    if enteredSupply
        alert(f_msg("ZONE ENTRY", "SUPPLY", "Prepare SHORT / PUT entry at proximal", rtSupProx, rtSupDist, liveSupStrat), alert.freq_once_per_bar)

if alertApproach
    if approachingD
        alert(f_msg("APPROACHING", "DEMAND", "Price nearing demand -- watch for reversal candle", rtDemProx, rtDemDist, liveDemStrat), alert.freq_once_per_bar)
    if approachingS
        alert(f_msg("APPROACHING", "SUPPLY", "Price nearing supply -- watch for reversal candle", rtSupProx, rtSupDist, liveSupStrat), alert.freq_once_per_bar)

// -- Background highlight ------------------------------------------
bgcolor(inDemandZone ? color.new(#00e676, 95) : na, title="In Demand Zone")
bgcolor(inSupplyZone ? color.new(#ff1744, 95) : na, title="In Supply Zone")

// -----------------------------------------------------------------
//  SETUP:
//    1. Add this indicator to any chart
//    2. It auto-draws zones for that ticker
//    3. Right-click chart -> Add Alert
//       Condition: "OTA S&D" -> "Any alert() function call"
//       Notification: Webhook URL (your Discord/Python endpoint)
//    4. Repeat for each ticker in your watchlist
//    5. Zones redraw automatically when you switch charts
//
//  ALERT MESSAGE FORMAT:
//    ZONE ENTRY: NVDA [DEMAND] | $847.20 | P:$852.00 D:$835.00
//    | Bull Put Spread | SELL PUT $852.00 / BUY PUT $832.00
//    | IV/HV 1.31 [RICH] | 60-90DTE
//
//  ZONE LEGEND:
//    Solid box   = zone (distal to proximal)
//    Dashed line = proximal (entry -- body edge, no wick)
//    Dotted line = distal   (stop loss -- wick extreme)
//    Green zones = demand . Red zones = supply
//    Bright = fresh (0 tests) . Faded yellow = tested
//
//  ! Educational only. Not financial advice.
//    Options involve substantial risk of loss.
//    Always verify strikes on your broker chain.
// -----------------------------------------------------------------
````
