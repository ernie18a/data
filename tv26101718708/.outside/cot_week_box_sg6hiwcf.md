# COT Week Box

- url: https://www.tradingview.com/script/Sg6hIwCF-COT-Week-Box/
- type: indicator
- pine_id: PUB;c162d43414e942088e0a5a24abe6196f
- version: 1.0

## Description

COT Week Box — visualize weekly positioning shifts from the CFTC Commitments of Traders report directly on your price chart.
═══════════════════════════════════════
WHAT IT DOES
═══════════════════════════════════════
Every week on Friday, the CFTC publishes updated positioning data reflecting what traders did between the previous Wednesday and Tuesday. This indicator takes that weekly change in net positioning and draws a colored rectangle spanning exactly that Wed→Tue price window on your chart.
The result: you can instantly see which weeks had unusually large positioning shifts, what the price did during those weeks, and which side of the market was driving the flow.
═══════════════════════════════════════
HOW TO READ THE COLORS
═══════════════════════════════════════
GREEN — Net positioning increased. Traders added more longs than shorts on balance.
RED — Net positioning decreased. Traders added more shorts than longs on balance.
YELLOW — Net positioning increased, but the move was driven mostly by shorts covering (closing losing positions) rather than fresh buying. Often a sign of short squeeze dynamics.
BLUE — Net positioning decreased, but the move was driven mostly by longs liquidating (closing winning or losing positions) rather than fresh shorting. Often a sign of profit-taking or capitulation.
The opacity of each box scales with how extreme the week was: faint boxes are borderline, bold boxes are true outliers.
═══════════════════════════════════════
INPUTS
═══════════════════════════════════════

Group — choose which participant group to analyze: Commercials (hedgers), Non-Commercials (large speculators / funds), Non-Reportables (small traders), or All (sum of all groups).
Weekly move threshold (%) — only draw boxes for weeks where the absolute change in net positioning ranks above this percentile. Default 85 shows the top 15% of weeks. Increase to 95 or 99 to isolate only the most extreme weeks.
Reduction dominance threshold (%) — controls when BLUE/YELLOW colors trigger instead of RED/GREEN. Higher values require cleaner one-sided flow to flag a reduction-dominated week.
Lookback (weeks) — historical window for percentile calculation. Default 156 weeks (≈ 3 years).

═══════════════════════════════════════
SUPPORTED INSTRUMENTS
═══════════════════════════════════════
The indicator automatically maps the chart symbol to the correct CFTC report code. Supported markets include:
Metals: Gold, Silver, Copper, Platinum, Palladium
Energy: WTI Crude, Brent, Natural Gas, RBOB Gasoline, Heating Oil
FX: DXY, EUR, GBP, JPY, CAD, AUD, NZD, CHF, MXN
Indices: S&P 500, Nasdaq 100, Dow, Russell 2000, VIX
Softs: Coffee, Cocoa, Sugar, Cotton, Orange Juice
Grains: Corn, Wheat, Soybeans, Soybean Meal, Soybean Oil, Oats, Rough Rice
Meats: Live Cattle, Feeder Cattle, Lean Hogs
Works on the daily (D1) timeframe only.
═══════════════════════════════════════
USAGE TIPS
═══════════════════════════════════════
Settings -> pin to scale -> pin to right scale (may be needed if rectangles aren't bind to candles)

Start with Group = "Commercial" on commodity charts — commercial hedgers often signal turning points when their positioning reaches extremes.
On index futures and FX, try Group = "Non-Commercial" to follow large speculator flow.
A cluster of BLUE boxes near a price high, or YELLOW boxes near a price low, can indicate exhaustion of the dominant side.
Combine with your existing technical analysis — COT data works best as a confirmation tool, not a standalone signal.

═══════════════════════════════════════
NOTES
═══════════════════════════════════════

Data source: CFTC Legacy report, futures-only.
Boxes are drawn after the Friday release, covering the prior Wed→Tue reporting week.
The indicator requires a full week of bars (Wed through Tue) to draw a box.
If your instrument isn't in the supported list, the indicator will display "Instrument not mapped" — a premium version with manual CFTC code override is available separately.

## Source Code

````pine
//@version=6
import TradingView/LibraryCOT/2

indicator("COT Week Box", overlay=true, max_boxes_count=300)

//==================== INPUTS (minimalne) ====================
groupMode  = input.string("All", "Group", options=["Commercial", "Non-Commercial", "Non-Reportable", "All"],
     tooltip="Which COT participant group to analyze. Commercial = hedgers (producers, end-users). Non-Commercial = large speculators (funds). Non-Reportable = small traders. 'All' sums all three groups.")

moveThrPct = input.int(85, "Weekly move threshold (%)", minval=50, maxval=99,
     tooltip="Only draw boxes for weeks where the absolute change in net positioning ranks above this percentile. Higher = stricter filter, fewer boxes. 85 shows the top 15% of weeks by move size. 95 shows the top 5%. 99 shows only the most extreme outliers.")

thetaPct   = input.int(74, "Reduction dominance threshold (%)", minval=50, maxval=99,
     tooltip="Controls when a box is colored BLUE or YELLOW instead of RED/GREEN. BLUE = net decrease was driven mostly by longs closing out (≥ threshold of gross flow). YELLOW = net increase was driven mostly by shorts covering. Higher values require cleaner one-sided flow.")

lookback   = input.int(156, "Lookback (weeks)", minval=26, maxval=260,
     tooltip="Historical window used to calculate the percentile rank. 156 weeks = 3 years. Longer lookbacks give more stable thresholds but respond slower to regime changes.")

//==================== BASIC GUARDS ====================
isDaily = timeframe.isdaily

//==================== HELPERS ====================
f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_rank(src, len) =>
    cnt = 0.0
    valid = 0.0
    for i = 0 to len - 1
        if not na(src[i]) and not na(src)
            valid += 1
            cnt += src[i] < src ? 1 : 0
    valid == 0 ? na : 100.0 * cnt / valid

f_transp(intensity01) =>
    int(90 - 75 * f_clamp(intensity01, 0.0, 1.0))

//==================== AUTO CFTC MAP ====================
f_guessCftcCode() =>
    t = str.upper(syminfo.ticker)
    r = str.upper(syminfo.root)
    d = str.upper(syminfo.description)
    txt = t + " | " + r + " | " + d

    if str.contains(txt, "GC") or str.contains(txt, "XAU") or str.contains(txt, "GOLD")
        "088691"
    else if str.contains(txt, "SI") or str.contains(txt, "XAG") or str.contains(txt, "SILVER")
        "084691"
    else if str.contains(txt, "HG") or str.contains(txt, "COPPER")
        "085692"
    else if str.contains(txt, "PL") or str.contains(txt, "PLATINUM")
        "076651"
    else if str.contains(txt, "PA") or str.contains(txt, "PALLADIUM")
        "075651"
    else if str.contains(txt, "CL") or str.contains(txt, "USOIL") or str.contains(txt, "WTI")
        "06765A"
    else if str.contains(txt, "BRN") or str.contains(txt, "BRENT") or str.contains(txt, "UKOIL")
        "067411"
    else if str.contains(txt, "NG") or str.contains(txt, "NATGAS") or str.contains(txt, "NATURAL GAS")
        "023391"
    else if str.contains(txt, "RB") or str.contains(txt, "RBOB") or str.contains(txt, "GASOLINE")
        "002603"
    else if str.contains(txt, "HO") or str.contains(txt, "HEATING OIL")
        "002606"
    else if str.contains(txt, "DX1") or str.contains(txt, "DXY") or str.contains(txt, "USDINDEX")
        "098662"
    else if str.contains(txt, "6E") or str.contains(txt, "EURUSD") or str.contains(txt, "EURO FX")
        "099741"
    else if str.contains(txt, "6B") or str.contains(txt, "GBPUSD") or str.contains(txt, "BRITISH POUND")
        "096742"
    else if str.contains(txt, "6J") or str.contains(txt, "USDJPY") or str.contains(txt, "JAPANESE YEN")
        "097741"
    else if str.contains(txt, "6C") or str.contains(txt, "USDCAD") or str.contains(txt, "CANADIAN DOLLAR")
        "090741"
    else if str.contains(txt, "6A") or str.contains(txt, "AUDUSD") or str.contains(txt, "AUSTRALIAN DOLLAR")
        "232741"
    else if str.contains(txt, "6N") or str.contains(txt, "NZDUSD") or str.contains(txt, "NEW ZEALAND DOLLAR")
        "112741"
    else if str.contains(txt, "6S") or str.contains(txt, "USDCHF") or str.contains(txt, "SWISS FRANC")
        "092741"
    else if str.contains(txt, "MXN") or str.contains(txt, "USDMXN") or str.contains(txt, "MEXICAN PESO")
        "095741"
    else if str.contains(txt, "ES") or str.contains(txt, "SPX") or str.contains(txt, "S&P 500") or str.contains(txt, "SP500")
        "13874+"
    else if str.contains(txt, "NQ") or str.contains(txt, "NASDAQ") or str.contains(txt, "US100")
        "20974+"
    else if str.contains(txt, "YM") or str.contains(txt, "DOW") or str.contains(txt, "US30")
        "12460+"
    else if str.contains(txt, "RTY") or str.contains(txt, "RUSSELL") or str.contains(txt, "RUT")
        "239742"
    else if str.contains(txt, "VX") or str.contains(txt, "VIX")
        "1170E1"
    else if str.contains(txt, "COFFEE") or str.contains(txt, "KC") or str.contains(txt, "IC")
        "083731"
    else if str.contains(txt, "COCOA") or str.contains(txt, "CC")
        "073732"
    else if str.contains(txt, "SUGAR") or str.contains(txt, "SB")
        "080732"
    else if str.contains(txt, "COTTON") or str.contains(txt, "CT")
        "033661"
    else if str.contains(txt, "ORANGE JUICE") or str.contains(txt, "OJ")
        "040701"
    else if str.contains(txt, "CORN") or str.contains(txt, "ZC")
        "002602"
    else if str.contains(txt, "WHEAT") or str.contains(txt, "ZW")
        "001612"
    else if str.contains(txt, "SOYBEAN") or str.contains(txt, "ZS")
        "005602"
    else if str.contains(txt, "SOYMEAL") or str.contains(txt, "ZM")
        "005603"
    else if str.contains(txt, "SOYBEAN OIL") or str.contains(txt, "SOYOIL") or str.contains(txt, "ZL")
        "007601"
    else if str.contains(txt, "OATS") or str.contains(txt, "ZO")
        "004603"
    else if str.contains(txt, "ROUGH RICE") or str.contains(txt, "ZR")
        "011601"
    else if str.contains(txt, "LIVE CATTLE") or str.contains(txt, "LE")
        "057642"
    else if str.contains(txt, "FEEDER CATTLE") or str.contains(txt, "GF")
        "061641"
    else if str.contains(txt, "LEAN HOGS") or str.contains(txt, "HE")
        "054642"
    else
        ""

cftcCode = f_guessCftcCode()
hasCode = str.length(cftcCode) > 0

//==================== COT TICKER HELPER ====================
getT(_name, _dir) =>
    LibraryCOT.COTTickerid(
         COTType="Legacy",
         CFTCCode=cftcCode,
         includeOptions=false,
         metricName=_name,
         metricDirection=_dir,
         metricType="All")

//==================== TOP-LEVEL request.security ====================
comL  = hasCode ? request.security(getT("Commercial Positions", "Long"),     "W", close,            ignore_invalid_symbol=true) : na
comS  = hasCode ? request.security(getT("Commercial Positions", "Short"),    "W", close,            ignore_invalid_symbol=true) : na
nonL  = hasCode ? request.security(getT("Noncommercial Positions", "Long"),  "W", close,            ignore_invalid_symbol=true) : na
nonS  = hasCode ? request.security(getT("Noncommercial Positions", "Short"), "W", close,            ignore_invalid_symbol=true) : na
retL  = hasCode ? request.security(getT("Nonreportable Positions", "Long"),  "W", close,            ignore_invalid_symbol=true) : na
retS  = hasCode ? request.security(getT("Nonreportable Positions", "Short"), "W", close,            ignore_invalid_symbol=true) : na

dComL = hasCode ? request.security(getT("Commercial Positions", "Long"),     "W", close - close[1], ignore_invalid_symbol=true) : na
dComS = hasCode ? request.security(getT("Commercial Positions", "Short"),    "W", close - close[1], ignore_invalid_symbol=true) : na
dNonL = hasCode ? request.security(getT("Noncommercial Positions", "Long"),  "W", close - close[1], ignore_invalid_symbol=true) : na
dNonS = hasCode ? request.security(getT("Noncommercial Positions", "Short"), "W", close - close[1], ignore_invalid_symbol=true) : na
dRetL = hasCode ? request.security(getT("Nonreportable Positions", "Long"),  "W", close - close[1], ignore_invalid_symbol=true) : na
dRetS = hasCode ? request.security(getT("Nonreportable Positions", "Short"), "W", close - close[1], ignore_invalid_symbol=true) : na

useCom = groupMode == "Commercial"     or groupMode == "All"
useNon = groupMode == "Non-Commercial" or groupMode == "All"
useRet = groupMode == "Non-Reportable" or groupMode == "All"

longW  = (useCom ? nz(comL) : 0.0) + (useNon ? nz(nonL) : 0.0) + (useRet ? nz(retL) : 0.0)
shortW = (useCom ? nz(comS) : 0.0) + (useNon ? nz(nonS) : 0.0) + (useRet ? nz(retS) : 0.0)

dLongW  = (useCom ? nz(dComL) : 0.0) + (useNon ? nz(dNonL) : 0.0) + (useRet ? nz(dRetL) : 0.0)
dShortW = (useCom ? nz(dComS) : 0.0) + (useNon ? nz(dNonS) : 0.0) + (useRet ? nz(dRetS) : 0.0)

anyLongNA = (useCom and na(comL)) or (useNon and na(nonL)) or (useRet and na(retL))
hasData   = hasCode and not anyLongNA

cotW   = hasData ? longW  - shortW  : na
deltaW = hasData ? dLongW - dShortW : na

//==================== STATYSTYKA: percentyl |dNet| ====================
absDeltaW = na(deltaW) ? na : math.abs(deltaW)
moveRankW = f_rank(absDeltaW, lookback)

passFilter = not na(moveRankW) and moveRankW >= moveThrPct

//==================== INTENSYWNOSC KOLORU (magnitude) ====================
intensity = nz(moveRankW) / 100.0
transpNow = f_transp(intensity)

//==================== BLUE/YELLOW: dominacja redukcji ====================
R_L = na(deltaW) ? na : math.max(0.0, -dLongW)
A_S = na(deltaW) ? na : math.max(0.0,  dShortW)
denNeg = na(R_L) or na(A_S) ? na : (R_L + A_S)
pRedLong = na(denNeg) or denNeg == 0 ? na : R_L / denNeg

A_L = na(deltaW) ? na : math.max(0.0,  dLongW)
R_S = na(deltaW) ? na : math.max(0.0, -dShortW)
denPos = na(A_L) or na(R_S) ? na : (A_L + R_S)
pRedShort = na(denPos) or denPos == 0 ? na : R_S / denPos

isBlue   = not na(deltaW) and deltaW < 0 and not na(pRedLong)  and pRedLong  * 100.0 >= thetaPct
isYellow = not na(deltaW) and deltaW > 0 and not na(pRedShort) and pRedShort * 100.0 >= thetaPct

colUp     = color.new(color.lime,   transpNow)
colDown   = color.new(color.red,    transpNow)
colBlue   = color.new(color.blue,   transpNow)
colYellow = color.new(color.yellow, transpNow)

colBg =
     isBlue   ? colBlue :
     isYellow ? colYellow :
     not na(deltaW) and deltaW >= 0 ? colUp : colDown

colBorder = color.new(color.black, math.min(transpNow + 15, 100))

//==================== BOX STORAGE ====================
var boxes = array.new_box()

f_gc() =>
    while array.size(boxes) > 300
        b = array.shift(boxes)
        if not na(b)
            box.delete(b)

//==================== WEEK WINDOW TRACKING ====================
var int   curStart = na
var float curLow   = na
var float curHigh  = na

var int   pendingStart  = na
var int   pendingEnd    = na
var float pendingLow    = na
var float pendingHigh   = na
var int   pendingWeekId = -1
var bool  pendingPass   = false

var int   lastDrawnWeekId = -1

tradeDow = dayofweek(time)
isWed = tradeDow == dayofweek.wednesday
isTue = tradeDow == dayofweek.tuesday
releaseReady =
     tradeDow == dayofweek.friday or
     tradeDow == dayofweek.saturday or
     tradeDow == dayofweek.sunday or
     tradeDow == dayofweek.monday

if isDaily
    if isWed and na(curStart)
        curStart := bar_index
        curLow := low
        curHigh := high

    if not na(curStart)
        curLow := math.min(nz(curLow, low), low)
        curHigh := math.max(nz(curHigh, high), high)

    if not na(curStart) and isTue
        pendingStart := curStart
        pendingEnd := bar_index
        pendingLow := curLow
        pendingHigh := curHigh
        pendingWeekId := year(time) * 1000 + weekofyear(time)
        pendingPass := passFilter

        curStart := na
        curLow := na
        curHigh := na

    canDraw =
         releaseReady and
         not na(pendingStart) and
         not na(pendingEnd) and
         not na(pendingLow) and
         not na(pendingHigh) and
         pendingWeekId > 0 and
         pendingWeekId != lastDrawnWeekId and
         not na(deltaW) and
         pendingPass

    if canDraw
        topY = pendingHigh
        botY = pendingLow

        if topY == botY
            topY += syminfo.mintick * 10
            botY -= syminfo.mintick * 10

        b = box.new(
             left=pendingStart,
             top=topY,
             right=pendingEnd + 1,
             bottom=botY,
             xloc=xloc.bar_index,
             extend=extend.none,
             bgcolor=colBg,
             border_color=colBorder,
             border_width=1)

        array.push(boxes, b)
        f_gc()
        lastDrawnWeekId := pendingWeekId

//==================== STATUS TABLE (minimalna) ====================
var table statusTbl = table.new(position.top_right, 1, 3, border_width=1)

statusText =
     not isDaily ? "Use D1 timeframe" :
     not hasCode ? "Instrument not mapped" :
     not hasData ? "No COT data" :
     "OK"

statusColor =
     statusText == "OK" ? color.new(color.green, 0) : color.new(color.orange, 0)

if barstate.islast
    table.cell(statusTbl, 0, 0, "COT Week Box", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(statusTbl, 0, 1, statusText, text_color=color.white, bgcolor=statusColor, text_size=size.small)
    table.cell(statusTbl, 0, 2, "Last week rank: " + (na(moveRankW) ? "n/a" : str.tostring(moveRankW, "#.0") + "%"), text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
````
