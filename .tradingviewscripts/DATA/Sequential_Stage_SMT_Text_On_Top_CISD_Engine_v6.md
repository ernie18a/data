<!-- tradingview-pine-id: PUB;8d4e59fe2e9b4637bfe1baaf293e9a55 -->
<!-- tradingviewscripts-format: 1 -->
# Sequential Stage SMT (Text On Top) & CISD Engine [v6]

Source: https://www.tradingview.com/script/wWw393EI-SMT-AND-CISD-BY-RIZ-FX/

## Description

SMT compares two correlated markets (like NQ vs. ES or EUR/USD vs. GBP/USD) to see if they are out of sync. If one asset makes a new high/low but the other fails to follow, it signals a potential trend reversal or institutional manipulation.

How it marks your chart:
S1 (Stage 1 SMT): Marks the first SMT divergence detected in a price move.

S2 (Stage 2 SMT): Marks a second back-to-back SMT divergence in the same direction.

SSMT: An option in settings to label major Higher-Timeframe SMTs.

Visual Style: Draws a solid orange line connecting the two price swings, with black text sitting cleanly ON TOP of the line.

2. CISD Engine (The Red Lines)
What it does:
CISD (Change in State of Delivery) highlights exact price levels where market momentum flips. It triggers when price breaks and closes beyond the open price of an opposing candle, signaling that market makers are shifting price direction.

How it marks your chart:
Bullish CISD: Placed when price pushes up through a previous down-candle's open price.

Bearish CISD: Placed when price pushes down through a previous up-candle's open price.

Visual Style: Draws a horizontal solid red line with black text on the far RIGHT side showing the timeframe (e.g., 5M Bull CISD).

---

## Source Code

````pine
//@version=6
indicator("Sequential Stage SMT (Text On Top) & CISD Engine [v6]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
grp_smt        = "SMT Divergence Settings"
smtTf          = input.timeframe("60", "SMT Timeframe (HTF)", group = grp_smt, tooltip = "Select HTF for SMT (e.g. 15, 60, 240, 1D). Projects cleanly down to 1M/5M charts.")
secSymbol      = input.symbol("CME_MINI:ES1!", "Secondary Symbol", group = grp_smt)
pivotLen       = input.int(5, "Pivot Strength (Left/Right Bars)", minval = 2, maxval = 30, group = grp_smt)
isHtfSsmt      = input.bool(false, "Mark All Divergences as SSMT", group = grp_smt)

grp_cisd       = "CISD Settings"
onlyRecentCisd = input.bool(true, "Keep Only Most Recent CISD", group = grp_cisd)
cisdLength     = input.int(20, "CISD Line Extension (Bars)", minval = 5, maxval = 100, group = grp_cisd)

grp_vis        = "Visual Customization"
smtLineColor   = input.color(#f57f17, "SMT Line Color", group = grp_vis)
smtTextColor   = input.color(color.black, "SMT Text Color", group = grp_vis)

cisdLineColor  = input.color(color.red, "CISD Line Color", group = grp_vis)
cisdTextColor  = input.color(color.black, "CISD Text Color", group = grp_vis)

textSize       = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grp_vis)

f_size(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal


// ==========================================
// 2. DATA RETRIEVAL & HELPER FUNCTIONS
// ==========================================
f_getHtfPivotLow(int pLen) =>
    pL = ta.pivotlow(low, pLen, pLen)
    tL = not na(pL) ? time[pLen] : int(na)
    [pL, tL]

f_getHtfPivotHigh(int pLen) =>
    pH = ta.pivothigh(high, pLen, pLen)
    tH = not na(pH) ? time[pLen] : int(na)
    [pH, tH]

f_getSecPrice(int pLen) =>
    [low[pLen], high[pLen]]

// Request Primary Symbol Pivots & Timestamps
[pLow1, tLow1]   = request.security(syminfo.tickerid, smtTf, f_getHtfPivotLow(pivotLen), barmerge.gaps_off, barmerge.lookahead_off)
[pHigh1, tHigh1] = request.security(syminfo.tickerid, smtTf, f_getHtfPivotHigh(pivotLen), barmerge.gaps_off, barmerge.lookahead_off)

// Request Secondary Symbol Low/High at Pivot Bar
[secLow, secHigh] = request.security(secSymbol, smtTf, f_getSecPrice(pivotLen), barmerge.gaps_off, barmerge.lookahead_off)

// Persistent State Variables
var float main_prevPL = na, var int main_prevTL = na, var float sec_prevPL = na
var float main_prevPH = na, var int main_prevTH = na, var float sec_prevPH = na

// Sequential Counters
var int bullSmtSeq = 0
var int bearSmtSeq = 0

// Helper: Draws Continuous Line + Places Text ON TOP of the SMT line
f_drawSmtLineOnTop(int t1, float p1, int t2, float p2, string tag) =>
    if t2 > t1
        int midTime    = math.round((t1 + t2) / 2)
        float midPrice = (p1 + p2) / 2
        
        // Continuous SMT Line (Color: #f57f17, Width: 1, Solid)
        line.new(x1 = t1, y1 = p1, x2 = t2, y2 = p2, xloc = xloc.bar_time, color = smtLineColor, width = 1, style = line.style_solid)
        
        // label.style_label_down places text box cleanly ABOVE the line
        label.new(x = midTime, y = midPrice, text = tag, xloc = xloc.bar_time, color = color.new(color.white, 100), style = label.style_label_down, textcolor = smtTextColor, size = f_size(textSize))


// ==========================================
// 3. BULLISH SMT ENGINE (SEQUENTIAL S1 -> S2)
// ==========================================
bool isNewPivotLow = not na(tLow1) and (na(main_prevTL) or tLow1 != main_prevTL)

if isNewPivotLow
    if not na(main_prevPL) and not na(sec_prevPL)
        float mainDiff = pLow1 - main_prevPL
        float secDiff  = secLow - sec_prevPL

        // Divergence Check
        bool isBullSmt = (mainDiff < 0 and secDiff >= 0) or (mainDiff >= 0 and secDiff < 0)

        if isBullSmt
            bearSmtSeq := 0 // Reset opposite sequence counter
            bullSmtSeq := bullSmtSeq + 1

            string smtTag = ""
            if isHtfSsmt
                smtTag := "SSMT"
            else
                if bullSmtSeq == 1
                    smtTag := "S1"
                else if bullSmtSeq == 2
                    smtTag := "S2"
                else
                    bullSmtSeq := 1
                    smtTag := "S1"

            f_drawSmtLineOnTop(main_prevTL, main_prevPL, tLow1, pLow1, smtTag)

    main_prevPL := pLow1
    main_prevTL := tLow1
    sec_prevPL  := secLow


// ==========================================
// 4. BEARISH SMT ENGINE (SEQUENTIAL S1 -> S2)
// ==========================================
bool isNewPivotHigh = not na(tHigh1) and (na(main_prevTH) or tHigh1 != main_prevTH)

if isNewPivotHigh
    if not na(main_prevPH) and not na(sec_prevPH)
        float mainDiff = pHigh1 - main_prevPH
        float secDiff  = secHigh - sec_prevPH

        // Divergence Check
        bool isBearSmt = (mainDiff > 0 and secDiff <= 0) or (mainDiff <= 0 and secDiff > 0)

        if isBearSmt
            bullSmtSeq := 0 // Reset opposite sequence counter
            bearSmtSeq := bearSmtSeq + 1

            string smtTag = ""
            if isHtfSsmt
                smtTag := "SSMT"
            else
                if bearSmtSeq == 1
                    smtTag := "S1"
                else if bearSmtSeq == 2
                    smtTag := "S2"
                else
                    bearSmtSeq := 1
                    smtTag := "S1"

            f_drawSmtLineOnTop(main_prevTH, main_prevPH, tHigh1, pHigh1, smtTag)

    main_prevPH := pHigh1
    main_prevTH := tHigh1
    sec_prevPH  := secHigh


// ==========================================
// 5. ACTIVE CHART CISD ENGINE (RED SOLID, SIZE 1, BLACK TEXT RIGHT)
// ==========================================
var line  lastBullCisdLine  = na
var label lastBullCisdLabel = na
var line  lastBearCisdLine  = na
var label lastBearCisdLabel = na

var float originBearOpen = na
var int   originBearBar  = na
var float originBullOpen = na
var int   originBullBar  = na

bool isRed   = close < open
bool isGreen = close > open

if isRed and not isRed[1]
    originBearOpen := open
    originBearBar  := bar_index

if isGreen and not isGreen[1]
    originBullOpen := open
    originBullBar  := bar_index

bool bullCISD = not na(originBearOpen) and ta.crossover(close, originBearOpen)
bool bearCISD = not na(originBullOpen) and ta.crossunder(close, originBullOpen)

tfLabel = timeframe.isintraday ? str.tostring(timeframe.multiplier) + "M" : timeframe.period

// Bullish CISD
if bullCISD
    if onlyRecentCisd
        line.delete(lastBullCisdLine)
        label.delete(lastBullCisdLabel)
    
    int endBar = bar_index + cisdLength
    lastBullCisdLine  := line.new(x1 = originBearBar, y1 = originBearOpen, x2 = endBar, y2 = originBearOpen, xloc = xloc.bar_index, color = cisdLineColor, style = line.style_solid, width = 1)
    lastBullCisdLabel := label.new(x = endBar, y = originBearOpen, text = tfLabel + " Bull CISD", xloc = xloc.bar_index, color = color.new(color.white, 100), style = label.style_none, textcolor = cisdTextColor, size = f_size(textSize), textalign = text.align_left)
    originBearOpen := na

// Bearish CISD
if bearCISD
    if onlyRecentCisd
        line.delete(lastBearCisdLine)
        label.delete(lastBearCisdLabel)
    
    int endBar = bar_index + cisdLength
    lastBearCisdLine  := line.new(x1 = originBullBar, y1 = originBullOpen, x2 = endBar, y2 = originBullOpen, xloc = xloc.bar_index, color = cisdLineColor, style = line.style_solid, width = 1)
    lastBearCisdLabel := label.new(x = endBar, y = originBullOpen, text = tfLabel + " Bear CISD", xloc = xloc.bar_index, color = color.new(color.white, 100), style = label.style_none, textcolor = cisdTextColor, size = f_size(textSize), textalign = text.align_left)
    originBullOpen := na
````
