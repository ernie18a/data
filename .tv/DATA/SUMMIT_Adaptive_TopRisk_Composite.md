<!-- tradingview-pine-id: PUB;dd434076ef564f2b9f384ca404207d66 -->
<!-- tradingviewscripts-format: 1 -->
# SUMMIT - Adaptive Top-Risk Composite

Source: https://www.tradingview.com/script/ct91dxtl-SUMMIT-Adaptive-Top-Risk-Composite/

## Description

This is an extremely comprehensive market top risk indicator that uses 35+ different metrics and does a whole swath of statistical analysis to gauge risk.

---

## Source Code

````pine
//@version=6
// SUMMIT v2 - adaptive top-risk composite + confirmed top marker
//
// Timeframe-adaptive: every window below is specified in trading days and converted to chart
// bars at runtime, so D / W / M charts all calibrate correctly (v1 froze on W/M because 378
// bars meant 7 or 31 years there).
//
// Two signal tiers:
//   WARN (triangles) - predictive. Composite crosses its own rolling 90th percentile while
//                      price sits near 52w highs.
//   TOP  (labels)    - confirmation. Price that ran near 52w highs draws down trigDrop% off the
//                      armed high (default = the true-top threshold itself, so a mark IS a
//                      completed truth condition). Label lands on the peak candle. Graded tier.
//
// Scoreboard: ground truth = pivot high within proxPct of the rolling 252d high, followed by
// a decline of at least topDecl% within declDays. Recall = share of true tops carrying a TOP
// label inside the match window. FP = share of resolved labels not attached to a true top.
// With trigger = topDecl, FP and misses reduce to episode bookkeeping; lower the trigger below
// topDecl for earlier marks at the price of stall-band false positives. Skill weights use an
// anchored expanding window (all history to date, in-sample by choice).
//
// Data notes: DSPX starts late 2023, COR1M/3M 2021+, most breadth feeds early 1990s+; missing
// feeds return na and carry zero weight. NAAIM/AAII/CNN F&G aren't on TradingView; COT asset
// managers, put/call and the VIX complex stand in. BPSPX rides a community seed feed.

indicator("SUMMIT - Adaptive Top-Risk Composite", "SUMMIT", overlay = false, dynamic_requests = true, max_labels_count = 500)

import TradingView/LibraryCOT/3 as cot

// ---------------------------------------------------------------- inputs (trading days)
grpE = "Engine"
grpT = "Top marker"
grpS = "Scoreboard"
grpD = "Data"
grpV = "Visual"
hD       = input.int(21, "Forecast horizon (days)", minval = 5, maxval = 63, group = grpE)
calD     = input.int(252, "Calibration window (days)", minval = 120, maxval = 756, group = grpE)
trmD     = input.int(252, "Skill window med (days)", minval = 63, maxval = 1250, group = grpE)
trlD     = input.int(504, "Skill window long (days)", minval = 126, maxval = 1250, group = grpE)
metaD    = input.int(252, "Stacking window (days)", minval = 63, maxval = 1250, group = grpE)
warnPct  = input.float(90.0, "Warn percentile", minval = 70.0, maxval = 99.0, group = grpE)
prModeS  = input.string("auto", "Percentile mode", options = ["auto", "exact", "fast"], group = grpE, tooltip = "fast = incremental z-score CDF approximation, required to stay inside runtime limits on daily and intraday charts. auto = exact on weekly and above, fast below.")
proxPct  = input.float(6.0, "Max % below 252d high", minval = 1.0, maxval = 25.0, group = grpE)
awD      = input.int(21, "Analog window (days)", minval = 10, maxval = 63, group = grpE)
astrD    = input.int(8, "Analog stride (days)", minval = 1, maxval = 21, group = grpE)
abackD   = input.int(900, "Analog lookback (days)", minval = 200, maxval = 1300, group = grpE)
ACOR     = input.float(0.5, "Analog min correlation", minval = 0.2, maxval = 0.9, group = grpE)
scanEv   = input.int(2, "Analog scan every N bars", minval = 1, maxval = 10, group = grpE)
trigDrop = input.float(8.0, "Trigger drawdown off armed high % (= true-top % locks marks to truth; lower = earlier marks, more FP)", minval = 2.0, maxval = 25.0, group = grpT)
gatePct  = input.float(0.0, "Composite gate percentile (0 = off)", minval = 0.0, maxval = 90.0, group = grpT)
cdD      = input.int(42, "Re-arm cooldown (days)", minval = 10, maxval = 252, group = grpT)
topDecl  = input.float(8.0, "True top = decline of at least %", minval = 3.0, maxval = 25.0, group = grpS)
declD    = input.int(189, "...within (days)", minval = 21, maxval = 504, group = grpS)
topWinD  = input.int(15, "Truth pivot width (days)", minval = 5, maxval = 42, group = grpS)
matchD   = input.int(84, "Label match window (days)", minval = 10, maxval = 189, group = grpS)
bpSym    = input.symbol("SEED_DANWAGNERCO_INDICATORS:BPSPX", "Bullish percent feed", group = grpD)
showTbl  = input.bool(true, "Show dashboard", group = grpV)
NSHOW    = input.int(28, "Top components shown", minval = 4, maxval = 60, group = grpV)
tblSizeS = input.string("small", "Table text size", options = ["tiny", "small", "normal", "large"], group = grpV)
tblPosS  = input.string("top right", "Table position", options = ["top right", "top left", "top center", "middle right", "middle left", "bottom right", "bottom left", "bottom center"], group = grpV)
riskFloor = input.float(70.0, "Risk strip above percentile", minval = 50.0, maxval = 95.0, group = grpV)
streakW  = input.float(0.75, "Risk streak deepening", minval = 0.0, maxval = 3.0, group = grpV)

// ---------------------------------------------------------------- day -> bar conversion
float dPerBar = timeframe.isintraday ? timeframe.in_seconds(timeframe.period) / 23400.0 : timeframe.isdaily ? 1.0 * timeframe.multiplier : timeframe.isweekly ? 5.0 * timeframe.multiplier : 21.0 * timeframe.multiplier
// inline (no helper function): UDF returns are series-qualified, ta.* lengths need simple int
int bH    = math.max(math.round(hD / dPerBar), 2)
int bCal  = math.min(math.max(math.round(calD / dPerBar), 60), 1250)
int bTrM  = math.max(math.round(trmD / dPerBar), 50)
int bTrL  = math.max(math.round(trlD / dPerBar), 100)
int bMeta = math.max(math.round(metaD / dPerBar), 50)
int bAW   = math.max(math.round(awD / dPerBar), 8)
int bStr  = math.max(math.round(astrD / dPerBar), 1)
int bBack = math.min(math.max(math.round(abackD / dPerBar), 60), 1300)
int bCd   = math.max(math.round(cdD / dPerBar), 6)
int bTW   = math.max(math.round(topWinD / dPerBar), 2)
int bDecl = math.max(math.round(declD / dPerBar), 10)
int bMatch = math.max(math.round(matchD / dPerBar), 4)
int b5   = math.max(math.round(5 / dPerBar), 2)
int b9   = math.max(math.round(9 / dPerBar), 2)
int b10  = math.max(math.round(10 / dPerBar), 2)
int b12  = math.max(math.round(12 / dPerBar), 3)
int b14  = math.max(math.round(14 / dPerBar), 2)
int b20  = math.max(math.round(20 / dPerBar), 3)
int b21  = math.max(math.round(21 / dPerBar), 3)
int b22  = math.max(math.round(22 / dPerBar), 3)
int b25  = math.max(math.round(25 / dPerBar), 3)
int b26  = math.max(math.round(26 / dPerBar), 5)
int b40  = math.max(math.round(40 / dPerBar), 4)
int b42  = math.max(math.round(42 / dPerBar), 4)
int b50  = math.max(math.round(50 / dPerBar), 5)
int b63  = math.max(math.round(63 / dPerBar), 5)
int b126 = math.max(math.round(126 / dPerBar), 8)
int b200 = math.max(math.round(200 / dPerBar), 10)
int b252 = math.max(math.round(252 / dPerBar), 12)
int bCyc = math.max(math.round(1260 / dPerBar), 60)
float annF = math.sqrt(252.0 / dPerBar)
bool fastPr = prModeS == "fast" or (prModeS == "auto" and dPerBar < 5.0)

color COL_BG  = #14161a
color COL_TXT = #d8dbe0
color COL_ACC = #8fa3b8
color COL_TAN = #d0c19b
color COL_YEL = #e8b93c
color COL_DIM = #5a6068

string tSz = tblSizeS == "tiny" ? size.tiny : tblSizeS == "small" ? size.small : tblSizeS == "normal" ? size.normal : size.large
string tPos = tblPosS == "top left" ? position.top_left : tblPosS == "top center" ? position.top_center : tblPosS == "middle right" ? position.middle_right : tblPosS == "middle left" ? position.middle_left : tblPosS == "bottom right" ? position.bottom_right : tblPosS == "bottom left" ? position.bottom_left : tblPosS == "bottom center" ? position.bottom_center : position.top_right

// ---------------------------------------------------------------- helpers
f_pr(float x) =>
    float out = na
    if fastPr
        float m = ta.sma(x, bCal)
        float s = ta.stdev(x, bCal)
        out := 100.0 / (1.0 + math.exp(-1.702 * (x - m) / math.max(s, 1e-10)))
    else
        out := ta.percentrank(x, bCal)
    out

f_z(float x, int len) =>
    (x - ta.sma(x, len)) / math.max(ta.stdev(x, len), 1e-10)

f_sec(string s) =>
    request.security(s, timeframe.period, close, ignore_invalid_symbol = true)

f_secW(string s) =>
    request.security(s, "1W", close, ignore_invalid_symbol = true)

f_yoy(string s) =>
    request.security(s, "1M", close / close[12] - 1.0, ignore_invalid_symbol = true)

// ---------------------------------------------------------------- external feeds
float spxC   = f_sec("SP:SPX")
float ndxC   = f_sec("NASDAQ:NDX")
float vix    = f_sec("CBOE:VIX")
float vix3m  = f_sec("CBOE:VIX3M")
float vix9d  = f_sec("CBOE:VIX9D")
float vvix   = f_sec("CBOE:VVIX")
float vxn    = f_sec("CBOE:VXN")
float skewV  = f_sec("CBOE:SKEW")
float cor1m  = f_sec("CBOE:COR1M")
float cor3m  = f_sec("CBOE:COR3M")
float dspx   = f_sec("CBOE:DSPX")
float pcc    = f_sec("USI:PCC")
float pcce   = f_sec("USI:PCCE")
float s5fi   = f_sec("INDEX:S5FI")
float s5th   = f_sec("INDEX:S5TH")
float ndfi   = f_sec("INDEX:NDFI")
float ndth   = f_sec("INDEX:NDTH")
float bp     = f_sec(bpSym)
float addD   = f_sec("USI:ADD")
float hy     = f_sec("FRED:BAMLH0A0HYM2")
float ig     = f_sec("FRED:BAMLC0A0CM")
float moveV  = f_sec("TVC:MOVE")
float us10   = f_sec("TVC:US10Y")
float t10y2y = f_sec("FRED:T10Y2Y")
float dxy    = f_sec("TVC:DXY")
float oil    = f_sec("TVC:USOIL")
float gold   = f_sec("TVC:GOLD")
float hyg    = f_sec("AMEX:HYG")
float cpiY   = f_yoy("FRED:CPIAUCSL")
float ppiY   = f_yoy("FRED:PPIACO")
float pceY   = f_yoy("FRED:PCEPILFE")

string tkAmL = cot.COTTickerid("Financial", "13874A", false, "Asset Manager Positions", "Long", "All")
string tkAmS = cot.COTTickerid("Financial", "13874A", false, "Asset Manager Positions", "Short", "All")
string tkLvL = cot.COTTickerid("Financial", "13874A", false, "Leveraged Funds Positions", "Long", "All")
string tkLvS = cot.COTTickerid("Financial", "13874A", false, "Leveraged Funds Positions", "Short", "All")
string tkDxL = cot.COTTickerid("Legacy", "098662", false, "Noncommercial Positions", "Long", "All")
string tkDxS = cot.COTTickerid("Legacy", "098662", false, "Noncommercial Positions", "Short", "All")
float esAmL = f_secW(tkAmL)
float esAmS = f_secW(tkAmS)
float esLvL = f_secW(tkLvL)
float esLvS = f_secW(tkLvS)
float dxL   = f_secW(tkDxL)
float dxS   = f_secW(tkDxS)
float esAmNet = esAmL - esAmS
float esLvNet = esLvL - esLvS
float dxNet   = dxL - dxS

string secSym = switch syminfo.sector
    "Electronic Technology" => "AMEX:XLK"
    "Technology Services"   => "AMEX:XLK"
    "Finance"               => "AMEX:XLF"
    "Health Technology"     => "AMEX:XLV"
    "Health Services"       => "AMEX:XLV"
    "Consumer Non-Durables" => "AMEX:XLP"
    "Consumer Services"     => "AMEX:XLY"
    "Consumer Durables"     => "AMEX:XLY"
    "Retail Trade"          => "AMEX:XLY"
    "Energy Minerals"       => "AMEX:XLE"
    "Industrial Services"   => "AMEX:XLE"
    "Producer Manufacturing" => "AMEX:XLI"
    "Transportation"        => "AMEX:XLI"
    "Commercial Services"   => "AMEX:XLI"
    "Distribution Services" => "AMEX:XLI"
    "Process Industries"    => "AMEX:XLB"
    "Non-Energy Minerals"   => "AMEX:XLB"
    "Utilities"             => "AMEX:XLU"
    "Communications"        => "AMEX:XLC"
    => "SP:SPX"
float secC = f_sec(secSym)

// ---------------------------------------------------------------- base series
bool  isIdx   = syminfo.type == "index"
bool  haveVol = not na(volume)
float lr      = na(close[1]) ? 0.0 : math.log(close / math.max(close[1], 1e-12))
float spxLr   = na(spxC[1]) ? na : math.log(spxC / math.max(spxC[1], 1e-12))
float spxProx = spxC / math.max(ta.highest(spxC, b126), 1e-10)
float ndxProx = ndxC / math.max(ta.highest(ndxC, b126), 1e-10)
float adl     = ta.cum(nz(addD, 0.0))
float goldRs  = gold / spxC
float inflSum = cpiY + ppiY + pceY
float rsi14   = ta.rsi(close, b14)
[macdL, macdS, macdH] = ta.macd(close, b12, b26, b9)
float bbBasis = ta.sma(close, b20)
float bbDev   = 2.0 * ta.stdev(close, b20)
float bbB     = (close - (bbBasis - bbDev)) / math.max(2.0 * bbDev, 1e-10)
float dtz     = (close - ta.sma(close, b50)) / math.max(ta.stdev(close, b50), 1e-10)
float ext200  = close / math.max(ta.sma(close, b200), 1e-10) - 1.0
float wvf     = (ta.highest(close, b22) - low) / math.max(ta.highest(close, b22), 1e-10) * 100.0
float rv20    = ta.stdev(lr, b21) * annF
float rvRel   = rv20 / math.max(ta.sma(rv20, b252), 1e-10)
float shp     = (close / math.max(close[b252], 1e-10) - 1.0) / math.max(ta.stdev(lr, b252) * annF, 1e-10)
bool  ddFlag  = close / math.max(ta.highest(close, b252), 1e-10) - 1.0 < -0.15
float cycAge  = math.min(nz(ta.barssince(ddFlag), bCyc), bCyc)
float distRaw = math.sum(close < close[1] and nz(volume) > nz(volume[1]) ? 1.0 : 0.0, b25)
float obvCorr = ta.correlation(close, ta.obv, b40)
float bpHi42  = ta.highest(bp, b42)
float bpRoll  = (bpHi42 - bp) * (bpHi42 > 65.0 ? 1.0 : 0.5)
float credTurn = (hy - hy[b21]) * (spxProx > 0.97 ? 1.0 : 0.3)
float curveVal = (t10y2y - t10y2y[b42]) * (nz(t10y2y[b252], 1.0) < 0 ? 1.0 : 0.4)
float rsSpx   = close / spxC
float rsStr   = rsSpx / math.max(ta.sma(rsSpx, b126), 1e-10) - 1.0
float rsSec   = close / secC
float secStr  = rsSec / math.max(ta.sma(rsSec, b126), 1e-10) - 1.0
float beta    = ta.correlation(lr, spxLr, b252) * ta.stdev(lr, b252) / math.max(ta.stdev(spxLr, b252), 1e-10)
float betaGap = (close / math.max(close[b63], 1e-10) - 1.0) - beta * (spxC / math.max(spxC[b63], 1e-10) - 1.0)

// ---------------------------------------------------------------- bearish RSI divergence
float ph = ta.pivothigh(high, b5, b5)
var float prevPH  = na
var float prevPHr = na
var float divScore = 0.0
divScore := divScore * 0.94
if not na(ph)
    if not na(prevPH) and ph > prevPH and rsi14[b5] < prevPHr and prevPHr >= 55.0
        divScore := 100.0
    prevPH  := ph
    prevPHr := rsi14[b5]

// ---------------------------------------------------------------- seasonality (per-ticker, past-only)
var array<float> mRet = array.new_float(12, 0.0)
var array<float> mCnt = array.new_float(12, 0.0)
var float monOpen = na
if na(monOpen)
    monOpen := open
bool newMon = not na(month[1]) and month != month[1]
if newMon
    if not na(monOpen) and monOpen > 0
        int mi = month[1] - 1
        array.set(mRet, mi, array.get(mRet, mi) + (close[1] / monOpen - 1.0))
        array.set(mCnt, mi, array.get(mCnt, mi) + 1.0)
    monOpen := open
float seasScore = na
float curCnt = array.get(mCnt, month - 1)
if curCnt >= 3
    float curMean = array.get(mRet, month - 1) / curCnt
    int worseEq = 0
    int totM = 0
    for k = 0 to 11
        float ck = array.get(mCnt, k)
        if ck >= 3
            totM += 1
            if array.get(mRet, k) / ck >= curMean
                worseEq += 1
    if totM >= 6
        seasScore := 100.0 * worseEq / totM

// ---------------------------------------------------------------- historical analog engine
// prefix sums make candidate mean/variance O(1); only the cross-product loop remains.
var array<float> ra  = array.new_float()
var array<float> cs  = array.new_float()
var array<float> cs2 = array.new_float()
if barstate.isconfirmed
    float pC  = array.size(cs) > 0 ? array.get(cs, array.size(cs) - 1) : 0.0
    float pC2 = array.size(cs2) > 0 ? array.get(cs2, array.size(cs2) - 1) : 0.0
    array.push(ra, lr)
    array.push(cs, pC + lr)
    array.push(cs2, pC2 + lr * lr)
    if array.size(ra) > 1400
        array.shift(ra)
        array.shift(cs)
        array.shift(cs2)
var float analogExp = na
if barstate.isconfirmed and (bar_index % scanEv == 0 or barstate.islast)
    int sz = array.size(ra)
    if sz > bAW + bH + 60
        float mu   = (array.get(cs, sz - 1) - array.get(cs, sz - 1 - bAW)) / bAW
        float varC = (array.get(cs2, sz - 1) - array.get(cs2, sz - 1 - bAW)) / bAW - mu * mu
        if varC > 1e-12
            float sdC = math.sqrt(varC)
            array<float> cw = array.new_float()
            for k = 0 to bAW - 1
                array.push(cw, array.get(ra, sz - bAW + k) - mu)
            int maxO = math.min(bBack, sz - 2 - bAW)
            float accW = 0.0
            float accF = 0.0
            for o = bH + 1 to maxO by bStr
                int e = sz - 1 - o
                float m2 = (array.get(cs, e) - array.get(cs, e - bAW)) / bAW
                float v2 = (array.get(cs2, e) - array.get(cs2, e - bAW)) / bAW - m2 * m2
                if v2 > 1e-12
                    float cv = 0.0
                    for k = 0 to bAW - 1
                        cv += array.get(cw, k) * (array.get(ra, e - bAW + 1 + k) - m2)
                    float r = cv / bAW / (sdC * math.sqrt(v2))
                    if r > ACOR
                        float wgt = r - ACOR
                        accW += wgt
                        accF += wgt * (array.get(cs, e + bH) - array.get(cs, e))
            analogExp := accW > 0 ? accF / accW : na

// ---------------------------------------------------------------- component registry
float yTgt = -(close / math.max(close[bH], 1e-10) - 1.0) * 100.0

var array<string> g_name = array.new_string()
var array<float>  g_pr   = array.new_float()
var array<float>  g_s1   = array.new_float()
var array<float>  g_s2   = array.new_float()
var array<float>  g_s3   = array.new_float()

// expanding-window skill accumulators, one slot per component in registration order.
// k1 is the anchored correlation over ALL history to date: in-sample by design, so each bar
// weighs a component by its record across every prior peak. k2/k3 stay trailing for regime feel.
var array<float> aN   = array.new_float()
var array<float> aSx  = array.new_float()
var array<float> aSy  = array.new_float()
var array<float> aSxy = array.new_float()
var array<float> aSxx = array.new_float()
var array<float> aSyy = array.new_float()

f_reg(string nm, float pr) =>
    int idx = array.size(g_pr)
    if array.size(aN) <= idx
        array.push(aN, 0.0)
        array.push(aSx, 0.0)
        array.push(aSy, 0.0)
        array.push(aSxy, 0.0)
        array.push(aSxx, 0.0)
        array.push(aSyy, 0.0)
    float x = pr[bH]
    if barstate.isconfirmed and not na(x) and not na(yTgt)
        array.set(aN, idx, array.get(aN, idx) + 1.0)
        array.set(aSx, idx, array.get(aSx, idx) + x)
        array.set(aSy, idx, array.get(aSy, idx) + yTgt)
        array.set(aSxy, idx, array.get(aSxy, idx) + x * yTgt)
        array.set(aSxx, idx, array.get(aSxx, idx) + x * x)
        array.set(aSyy, idx, array.get(aSyy, idx) + yTgt * yTgt)
    float n = array.get(aN, idx)
    float k1 = na
    if n >= 60
        float dvx = n * array.get(aSxx, idx) - array.get(aSx, idx) * array.get(aSx, idx)
        float dvy = n * array.get(aSyy, idx) - array.get(aSy, idx) * array.get(aSy, idx)
        if dvx > 1e-9 and dvy > 1e-9
            k1 := (n * array.get(aSxy, idx) - array.get(aSx, idx) * array.get(aSy, idx)) / math.sqrt(dvx * dvy)
    float k2 = ta.correlation(pr[bH], yTgt, bTrM)
    float k3 = ta.correlation(pr[bH], yTgt, bTrL)
    array.push(g_name, nm)
    array.push(g_pr, pr)
    array.push(g_s1, k1)
    array.push(g_s2, k2)
    array.push(g_s3, k3)

array.clear(g_name)
array.clear(g_pr)
array.clear(g_s1)
array.clear(g_s2)
array.clear(g_s3)

// chart-symbol technicals
f_reg("RSI", f_pr(rsi14))
f_reg("MACD impulse", f_pr(macdH / math.max(ta.stdev(close, b50), 1e-10)))
f_reg("Williams %R", f_pr(ta.wpr(b14)))
f_reg("CCI", f_pr(ta.cci(close, b20)))
f_reg("Bollinger %B", f_pr(bbB))
f_reg("Detrend stretch", f_pr(dtz))
f_reg("200d extension", f_pr(ext200))
f_reg("WVF complacency", f_pr(-wvf))
f_reg("RSI bear divergence", divScore)
f_reg("Seasonal window", seasScore)
f_reg("Analog forecast", f_pr(-analogExp * 100.0))
f_reg("Cycle maturity", f_pr(cycAge))
f_reg("RV awakening", f_pr(rvRel))
float prDist = f_pr(distRaw)
float prObv  = f_pr(-obvCorr)
f_reg("Distribution days", haveVol ? prDist : na)
f_reg("OBV divergence", haveVol ? prObv : na)
f_reg("Sharpe stretch", f_pr(shp))
f_reg("Blowoff velocity", f_pr(close / math.max(close[b21], 1e-10) - 1.0))
// index internals and breadth
f_reg("SPX 200d extension", f_pr(spxC / math.max(ta.sma(spxC, b200), 1e-10) - 1.0))
f_reg("Breadth gap 50d", f_pr(spxProx * 100.0 - s5fi))
f_reg("Breadth gap 200d", f_pr(spxProx * 100.0 - s5th))
f_reg("NDX breadth gap", f_pr(ndxProx * 100.0 - (ndfi + ndth) / 2.0))
f_reg("Bullish pct rolloff", f_pr(bpRoll))
f_reg("A/D divergence", f_pr(-ta.correlation(adl, spxC, b63)))
f_reg("Megacap crowding", f_pr(f_z(ndxC / spxC, b252)))
// volatility and options complex
f_reg("VIX complacency", f_pr(-vix))
f_reg("Vol awakening corr", f_pr(ta.correlation(vix, spxC, b10)))
f_reg("Contango calm", f_pr(vix3m / vix))
f_reg("Front-vol crush", f_pr(vix / vix9d))
f_reg("VVIX hedge demand", f_pr(vvix))
f_reg("SKEW tail bid", f_pr(skewV))
f_reg("Correlation crush", f_pr(-cor1m))
f_reg("Corr term slope", f_pr(cor3m - cor1m))
f_reg("Dispersion regime", f_pr(dspx))
f_reg("Tech vol premium", f_pr(vxn / vix))
f_reg("PC complacency", f_pr(-ta.sma(pcc, b5)))
f_reg("Equity PC froth", f_pr(-ta.sma(pcce, b5)))
// cross-asset and macro
f_reg("HY spread crush", f_pr(-hy))
f_reg("IG spread crush", f_pr(-ig))
f_reg("Credit stress turn", f_pr(credTurn))
f_reg("MOVE complacency", f_pr(-moveV))
f_reg("Rate pressure", f_pr(us10 - us10[b63]))
f_reg("Curve resteepening", f_pr(curveVal))
f_reg("Dollar squeeze", f_pr(dxy / math.max(dxy[b63], 1e-10) - 1.0))
f_reg("Oil shock", f_pr(oil / math.max(oil[b63], 1e-10) - 1.0))
f_reg("Gold defensive bid", f_pr(goldRs / math.max(goldRs[b63], 1e-10) - 1.0))
f_reg("Junk divergence", f_pr(-ta.correlation(hyg, spxC, b42)))
f_reg("Inflation level", f_pr(inflSum))
f_reg("Inflation reaccel", f_pr(inflSum - inflSum[b126]))
// positioning
f_reg("Inst crowding COT", f_pr(esAmNet))
f_reg("Basis-short crowd", f_pr(-esLvNet))
f_reg("DXY spec net", f_pr(dxNet))
// stock-only overlays, self-disable on indices
float prRs   = f_pr(rsStr)
float prSec  = f_pr(secStr)
float prBeta = f_pr(betaGap)
f_reg("RS stretch vs SPX", isIdx ? na : prRs)
f_reg("Sector RS stretch", isIdx ? na : prSec)
f_reg("Beta excess run", isIdx ? na : prBeta)

// ---------------------------------------------------------------- walk-forward aggregation
int nComp = array.size(g_pr)
float cSs = 0.0
float wSs = 0.0
float cMs = 0.0
float wMs = 0.0
float cLs = 0.0
float wLs = 0.0
float eqSum = 0.0
int nAct = 0
if nComp > 0
    for i = 0 to nComp - 1
        float pv = array.get(g_pr, i)
        if not na(pv)
            float a = math.max(nz(array.get(g_s1, i)), 0.0)
            float b = math.max(nz(array.get(g_s2, i)), 0.0)
            float c = math.max(nz(array.get(g_s3, i)), 0.0)
            cSs += a * pv
            wSs += a
            cMs += b * pv
            wMs += b
            cLs += c * pv
            wLs += c
            eqSum += pv
            nAct += 1
float eqComp = nAct > 0 ? eqSum / nAct : na
float compS = wSs > 0.05 ? cSs / wSs : eqComp
float compM = wMs > 0.05 ? cMs / wMs : eqComp
float compL = wLs > 0.05 ? cLs / wLs : eqComp

float m1v = math.max(nz(ta.correlation(compS[bH], yTgt, bMeta)), 0.0)
float m2v = math.max(nz(ta.correlation(compM[bH], yTgt, bMeta)), 0.0)
float m3v = math.max(nz(ta.correlation(compL[bH], yTgt, bMeta)), 0.0)
float mden = m1v + m2v + m3v
float rawComp = mden > 0.05 ? (m1v * compS + m2v * compM + m3v * compL) / mden : eqComp
float comp = ta.sma(rawComp, 3)

// ---------------------------------------------------------------- WARN tier (predictive)
float thr = ta.percentile_nearest_rank(nz(comp, 50.0), bCal, warnPct)
float compPct = ta.percentrank(comp, bCal)
float roll252 = ta.highest(high, b252)
bool nearHi = high >= roll252 * (1.0 - proxPct / 100.0)
bool riskOn = not na(comp) and not na(thr) and comp > thr and nearHi
bool warnEvt = ta.crossover(nz(comp, 0.0), nz(thr, 101.0)) and nearHi and bar_index > bCal

var int wN = 0
var int wHit = 0
var float wSum = 0.0
if barstate.isconfirmed and bar_index > bH and warnEvt[bH] and not na(close[bH])
    float fr = close / close[bH] - 1.0
    wN += 1
    if fr < 0
        wHit += 1
    wSum += fr

// ---------------------------------------------------------------- risk strip
// bars stack daily while the composite percentile holds above the floor; persistence deepens
// the color and grows the bar, yellow-green at first breach through amber to deep red.
var int rStreak = 0
float riskLvl = nz(compPct, 0.0)
rStreak := riskLvl > riskFloor and bar_index > bCal ? rStreak + 1 : 0
float effR = math.min(100.0, riskLvl + streakW * rStreak)
float rFrac = rStreak > 0 ? math.max((effR - riskFloor) / math.max(100.0 - riskFloor, 1.0), 0.06) : na
color rCol = na(rFrac) ? na : rFrac < 0.5 ? color.from_gradient(rFrac, 0.0, 0.5, #ccd97a, #e8b93c) : color.from_gradient(rFrac, 0.5, 1.0, #e8b93c, #99120f)

// ---------------------------------------------------------------- forward-risk precedent
// empirical P(drop >= topDecl% within declD days | composite decile), accumulated over the
// full loaded history. Feeds the plain-language risk line in the table.
var array<float> fdCnt = array.new_float(10, 0.0)
var array<float> fdHit = array.new_float(10, 0.0)
float fwdLo = ta.lowest(low, bDecl)
if barstate.isconfirmed and bar_index > bDecl and not na(comp[bDecl]) and not na(close[bDecl])
    int fb = math.min(math.max(math.floor(comp[bDecl] / 10.0), 0), 9)
    array.set(fdCnt, fb, array.get(fdCnt, fb) + 1.0)
    if fwdLo <= close[bDecl] * (1.0 - topDecl / 100.0)
        array.set(fdHit, fb, array.get(fdHit, fb) + 1.0)

// ---------------------------------------------------------------- TOP tier (confirmation, graded)
// trigger sits just under the truth threshold: every decline that reaches topDecl must pass
// through effDrop first, so recall is bounded only by arming and match-window mechanics, and
// false positives shrink to declines that stall inside [effDrop, topDecl).
var bool armed = false
var float armHi = na
var int armHiBar = 0
var int lastTop = -100000
var float prevMarkHi = na
if not armed and nearHi and (bar_index - lastTop > bCd or (not na(prevMarkHi) and high > prevMarkHi))
    armed := true
    armHi := high
    armHiBar := bar_index
if armed and high >= armHi
    armHi := high
    armHiBar := bar_index
float effDrop = math.min(trigDrop, topDecl)
bool dropBrk = armed and not na(armHi) and low <= armHi * (1.0 - effDrop / 100.0)
bool topEvt = dropBrk and (gatePct <= 0.0 or nz(compPct, 100.0) > gatePct) and bar_index > bCal

var array<int> mB = array.new_int()
if topEvt
    label.new(armHiBar, 96.0, "TOP", style = label.style_label_down, color = color.new(COL_YEL, 10), textcolor = COL_BG, size = size.small)
    if barstate.isconfirmed
        array.push(mB, bar_index)
    prevMarkHi := armHi
    armed := false
    armHi := na
    lastTop := bar_index

// ---------------------------------------------------------------- scoreboard (recall / FP on TOP labels)
var array<int>   tB = array.new_int()
var array<float> tP = array.new_float()
var array<int>   tS = array.new_int()
var int nTop = 0
var int nHit = 0
var int nTp = 0
var int nFp = 0

f_rmT(int i) =>
    array.remove(tB, i)
    array.remove(tP, i)
    array.remove(tS, i)

float tph = ta.pivothigh(high, bTW, bTW)
float hiT = ta.highest(high, b252)
if barstate.isconfirmed
    // truth universe matches the marker's: pivot near the rolling 252d high. Clustered pivots
    // inside the match window collapse into one episode, keeping the higher print while unresolved.
    bool pushT = not na(tph) and tph >= hiT[bTW] * (1.0 - proxPct / 100.0)
    if pushT
        int nT = array.size(tB)
        if nT > 0 and bar_index - bTW - array.get(tB, nT - 1) <= bMatch
            if array.get(tS, nT - 1) == 0 and tph > array.get(tP, nT - 1)
                array.set(tB, nT - 1, bar_index - bTW)
                array.set(tP, nT - 1, tph)
            pushT := false
    if pushT
        array.push(tB, bar_index - bTW)
        array.push(tP, tph)
        array.push(tS, 0)
    int ti = 0
    while ti < array.size(tB)
        int pb = array.get(tB, ti)
        int st = array.get(tS, ti)
        bool rm = false
        if st == 0
            if low <= array.get(tP, ti) * (1.0 - topDecl / 100.0)
                array.set(tS, ti, 1)
                nTop += 1
            else if bar_index - pb > bDecl
                rm := true
        else if bar_index - pb > bDecl + bMatch
            rm := true
        if rm
            f_rmT(ti)
        else
            ti += 1
    int mj = 0
    while mj < array.size(mB)
        int mb = array.get(mB, mj)
        bool matched = false
        int ti2 = 0
        while ti2 < array.size(tB)
            if array.get(tS, ti2) == 1 and mb >= array.get(tB, ti2) - bTW and mb <= array.get(tB, ti2) + bMatch
                matched := true
                break
            ti2 += 1
        if matched
            nHit += 1
            nTp += 1
            f_rmT(ti2)
            array.remove(mB, mj)
        else if bar_index - mb > bDecl + bMatch
            nFp += 1
            array.remove(mB, mj)
        else
            mj += 1

// ---------------------------------------------------------------- plots
// discretized gradient area: twenty 5-pt rows on the same temperature spectrum as the risk
// bars (spectrum completes by level 80), each row rendered only where it sits fully under
// the composite so the fill stair-steps inside the curve
pl0  = plot(0.0, "L0", color = color.new(COL_BG, 100))
pl1  = plot(5.0, "L5", color = color.new(COL_BG, 100))
pl2  = plot(10.0, "L10", color = color.new(COL_BG, 100))
pl3  = plot(15.0, "L15", color = color.new(COL_BG, 100))
pl4  = plot(20.0, "L20", color = color.new(COL_BG, 100))
pl5  = plot(25.0, "L25", color = color.new(COL_BG, 100))
pl6  = plot(30.0, "L30", color = color.new(COL_BG, 100))
pl7  = plot(35.0, "L35", color = color.new(COL_BG, 100))
pl8  = plot(40.0, "L40", color = color.new(COL_BG, 100))
pl9  = plot(45.0, "L45", color = color.new(COL_BG, 100))
pl10  = plot(50.0, "L50", color = color.new(COL_BG, 100))
pl11  = plot(55.0, "L55", color = color.new(COL_BG, 100))
pl12  = plot(60.0, "L60", color = color.new(COL_BG, 100))
pl13  = plot(65.0, "L65", color = color.new(COL_BG, 100))
pl14  = plot(70.0, "L70", color = color.new(COL_BG, 100))
pl15  = plot(75.0, "L75", color = color.new(COL_BG, 100))
pl16  = plot(80.0, "L80", color = color.new(COL_BG, 100))
pl17  = plot(85.0, "L85", color = color.new(COL_BG, 100))
pl18  = plot(90.0, "L90", color = color.new(COL_BG, 100))
pl19  = plot(95.0, "L95", color = color.new(COL_BG, 100))
pl20  = plot(100.0, "L100", color = color.new(COL_BG, 100))
fill(pl0, pl1, color = nz(comp, 0.0) >= 5.0 ? color.new(#d0d572, 45) : na)
fill(pl1, pl2, color = nz(comp, 0.0) >= 10.0 ? color.new(#d3d16a, 45) : na)
fill(pl2, pl3, color = nz(comp, 0.0) >= 15.0 ? color.new(#d6cd63, 45) : na)
fill(pl3, pl4, color = nz(comp, 0.0) >= 20.0 ? color.new(#dac95b, 45) : na)
fill(pl4, pl5, color = nz(comp, 0.0) >= 25.0 ? color.new(#dec553, 45) : na)
fill(pl5, pl6, color = nz(comp, 0.0) >= 30.0 ? color.new(#e1c14c, 45) : na)
fill(pl6, pl7, color = nz(comp, 0.0) >= 35.0 ? color.new(#e4bd44, 45) : na)
fill(pl7, pl8, color = nz(comp, 0.0) >= 40.0 ? color.new(#e8b93c, 45) : na)
fill(pl8, pl9, color = nz(comp, 0.0) >= 45.0 ? color.new(#dea436, 45) : na)
fill(pl9, pl10, color = nz(comp, 0.0) >= 50.0 ? color.new(#d48f31, 45) : na)
fill(pl10, pl11, color = nz(comp, 0.0) >= 55.0 ? color.new(#ca7a2b, 45) : na)
fill(pl11, pl12, color = nz(comp, 0.0) >= 60.0 ? color.new(#c06626, 45) : na)
fill(pl12, pl13, color = nz(comp, 0.0) >= 65.0 ? color.new(#b75120, 45) : na)
fill(pl13, pl14, color = nz(comp, 0.0) >= 70.0 ? color.new(#ad3c1a, 45) : na)
fill(pl14, pl15, color = nz(comp, 0.0) >= 75.0 ? color.new(#a32715, 45) : na)
fill(pl15, pl16, color = nz(comp, 0.0) >= 80.0 ? color.new(#99120f, 45) : na)
fill(pl16, pl17, color = nz(comp, 0.0) >= 85.0 ? color.new(#99120f, 45) : na)
fill(pl17, pl18, color = nz(comp, 0.0) >= 90.0 ? color.new(#99120f, 45) : na)
fill(pl18, pl19, color = nz(comp, 0.0) >= 95.0 ? color.new(#99120f, 45) : na)
fill(pl19, pl20, color = nz(comp, 0.0) >= 100.0 ? color.new(#99120f, 45) : na)
pComp = plot(comp, "Composite", color = color.new(COL_ACC, 0), linewidth = 2)
pThr  = plot(thr, "Warn threshold", color = color.new(COL_TAN, 40), linewidth = 1)
plotshape(warnEvt, "Warn", style = shape.triangledown, location = location.top, color = color.new(COL_ACC, 0), size = size.tiny)
// risk bars ride the main chart above price as discrete rectangles with natural per-bar gaps;
// height is a % of price so it scales across history
float rBase = ta.highest(high, b63) * 1.02
float rTopY = rBase * (1.0 + 0.05 * nz(rFrac, 0.0))
plotcandle(na(rFrac) ? na : rBase, na(rFrac) ? na : rTopY, na(rFrac) ? na : rBase, na(rFrac) ? na : rTopY, "Risk bars", color = rCol, wickcolor = color.new(COL_BG, 100), bordercolor = rCol, force_overlay = true)

// ---------------------------------------------------------------- dashboard
f_wblend(int i) =>
    m1v * math.max(nz(array.get(g_s1, i)), 0.0) + m2v * math.max(nz(array.get(g_s2, i)), 0.0) + m3v * math.max(nz(array.get(g_s3, i)), 0.0)

var table t = table.new(tPos, 2, 68, bgcolor = color.new(COL_BG, 6), frame_color = color.new(COL_ACC, 55), frame_width = 1, border_color = color.new(COL_BG, 40), border_width = 1)
if barstate.islast and showTbl
    float rcl = nTop > 0 ? 100.0 * nHit / nTop : na
    int mRes = nTp + nFp
    float fpr = mRes > 0 ? 100.0 * nFp / mRes : na
    int cb = math.min(math.max(math.floor(nz(comp, 50.0) / 10.0), 0), 9)
    float cN = array.get(fdCnt, cb)
    float cH = array.get(fdHit, cb)
    float pHere = cN >= 30.0 ? 100.0 * cH / cN : na
    float tCn = array.sum(fdCnt)
    float tHt = array.sum(fdHit)
    float pBase = tCn > 0.0 ? 100.0 * tHt / tCn : na
    color rTc = na(pHere) or na(pBase) ? COL_DIM : pHere > pBase * 1.2 ? COL_YEL : pHere < pBase * 0.8 ? COL_ACC : COL_TXT
    table.cell(t, 0, 0, "SUMMIT " + syminfo.ticker + " " + timeframe.period, text_color = color.new(COL_YEL, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 0, na(comp) ? "-" : str.tostring(comp, "#.#") + " / thr " + str.tostring(thr, "#.#"), text_color = color.new(COL_ACC, 0), text_size = tSz)
    table.cell(t, 0, 1, "regime", text_color = color.new(COL_TXT, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 1, (riskOn ? "ELEVATED" : "NORMAL") + " - " + (nearHi ? "near highs" : "off highs"), text_color = riskOn ? color.new(COL_YEL, 0) : color.new(COL_DIM, 0), text_size = tSz)
    table.cell(t, 0, 2, "top recall", text_color = color.new(COL_TXT, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 2, na(rcl) ? "-" : str.tostring(nHit) + "/" + str.tostring(nTop) + " = " + str.tostring(rcl, "#.#") + "%", text_color = color.new(COL_TXT, 0), text_size = tSz)
    table.cell(t, 0, 3, "false marks", text_color = color.new(COL_TXT, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 3, na(fpr) ? "-" : str.tostring(nFp) + "/" + str.tostring(mRes) + " = " + str.tostring(fpr, "#.#") + "%", text_color = color.new(COL_TXT, 0), text_size = tSz)
    table.cell(t, 0, 4, "warn " + str.tostring(bH) + "b fwd", text_color = color.new(COL_TXT, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 4, wN > 0 ? str.tostring(wN) + ", hit " + str.tostring(100.0 * wHit / wN, "#.#") + "%" : "-", text_color = color.new(COL_TXT, 0), text_size = tSz)
    table.cell(t, 0, 5, "fwd " + str.tostring(topDecl, "#.#") + "%+ / " + str.tostring(declD) + "d", text_color = color.new(COL_TXT, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 5, na(pHere) ? "n < 30" : str.tostring(pHere, "#.#") + "% vs " + str.tostring(pBase, "#.#") + "% base", text_color = color.new(rTc, 0), text_size = tSz)
    table.cell(t, 0, 6, "COMPONENT", text_color = color.new(COL_DIM, 0), text_halign = text.align_left, text_size = tSz)
    table.cell(t, 1, 6, "HEAT - WT", text_color = color.new(COL_DIM, 0), text_size = tSz)
    float wTot = 0.0
    if nComp > 0
        for i = 0 to nComp - 1
            if not na(array.get(g_pr, i))
                wTot += f_wblend(i)
    if nComp > 0
        array<bool> used = array.new_bool(nComp, false)
        for r = 0 to NSHOW - 1
            int bi = -1
            float bv = -1.0
            for i = 0 to nComp - 1
                if not array.get(used, i)
                    float pv2 = array.get(g_pr, i)
                    if not na(pv2) and pv2 > bv
                        bv := pv2
                        bi := i
            if bi >= 0
                array.set(used, bi, true)
                float pShow = array.get(g_pr, bi)
                float wPct = wTot > 1e-9 ? 100.0 * f_wblend(bi) / wTot : 0.0
                color hc = pShow < 50.0 ? color.new(COL_DIM, 20) : pShow < 75.0 ? color.from_gradient(pShow, 50.0, 75.0, #ccd97a, #e8b93c) : color.from_gradient(pShow, 75.0, 100.0, #e8b93c, #99120f)
                table.cell(t, 0, 7 + r, array.get(g_name, bi), text_color = hc, text_halign = text.align_left, text_size = tSz)
                table.cell(t, 1, 7 + r, str.tostring(pShow, "#") + " - " + str.tostring(wPct, "#.#") + "%", text_color = hc, text_size = tSz)

// ---------------------------------------------------------------- alerts
alertcondition(topEvt, "SUMMIT top confirmed", "Top marked: support break after near-high run")
alertcondition(warnEvt, "SUMMIT warn", "Top-risk composite crossed its adaptive threshold near highs")
alertcondition(riskOn and not riskOn[1], "SUMMIT regime elevated", "Top-risk regime turned elevated")
alertcondition(not riskOn and riskOn[1], "SUMMIT regime normal", "Top-risk regime back to normal")
````
