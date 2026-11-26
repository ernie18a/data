# TE Feature Screen

- url: https://www.tradingview.com/script/Ful9L9MX-TE-Feature-Screen/
- type: indicator
- pine_id: PUB;a074db86ed79410297f1847017ab4083
- version: 1.0

## Description

Stop Trading on Lagging Indicators. Start Measuring True Predictive Power.
​Are your indicators actually predicting the next move, or are they just taking credit for a trend that’s already happening?
​Introducing the Transfer Entropy Feature Screen. Built for quantitative researchers and serious algorithmic traders, this script leverages Information Theory to mathematically separate predictive signals from random market noise.
​Instead of relying on standard correlation, this engine uses Conditioned Transfer Entropy (TE). It deliberately strips out the stock's past momentum, forcing every indicator to prove it is bringing new, independent information to the table about where the price will be h bars from now.
​Tailored Specifically for the Stock Market
This Equities Edition focuses strictly on institutional footprints and structural market mechanics:
​Order Flow & Volume Kinetics: Track Limit Order Absorption (churn), Close Location Value (CLV), and Unusual Volume (RVOL) Z-scores to spot institutional accumulation before the breakout.
​Structural Edges: Measure Overnight Gap extent and Standard Deviation Distance from the daily VWAP.
​Index Relative Strength: Dynamically compare the stock's acceleration against a benchmark index (like the SPY or QQQ) to find true market leaders.
​Built for Rigorous Quant Research
To prevent curve-fitting, the script features a strict Walk-Forward backtesting engine.
​Input your exact calendar dates for In-Sample (Training) and Out-of-Sample (Testing) windows.
​The engine benchmarks every feature against randomized "null shuffle" data to generate a definitive Z-score, proving whether an indicator's edge is mathematically significant or just a lucky streak.
​Seamless Data Export: Bypassing TradingView's execution limits, the engine processes massive historical windows in the background and delivers a cleanly formatted CSV spreadsheet of the Z-scores directly to your email via alerts—perfect for building your own regime classification models.
​Stop guessing which features matter. Let the math tell you what actually moves the market.
​Setup Note for Users: To extract the data, set your IS/OOS calendar dates, toggle your desired features, and create a TradingView alert with "Send Email" checked. The script will automatically crunch the historical data and email you the CSV results upon the next bar close

## Source Code

````pine
//@version=6
// ============================================================================
// TRANSFER ENTROPY FEATURE SCREEN v4 — EQUITIES EDITION + EMAIL ALERT
// ----------------------------------------------------------------------------
// Adapted for traditional equities. Removes all crypto-derivatives and focuses
// on Volume mechanics, Relative Strength, VWAP, Overnight Gaps, and PA.
//
// HOW IT WORKS
//  1) As the chart loads, every in-window bar's feature vector (observed at the
//     decision bar T-h) is stored into a growing matrix<float>.
//  2) On the LAST bar only, for each ENABLED feature we compute two z-scores:
//        IS_Z  = TE-null z using only samples in [IS start, IS end]
//        OOS_Z = TE-null z using only samples in [OOS start, OOS end]
//  3) The per-feature results are assembled into a CSV string
//        Feature,IS_Z,OOS_Z
//     and emitted via alert(masterCSV, alert.freq_once_per_bar_close).
// ============================================================================
indicator("TE Feature Screen v4 — Equities Edition", overlay = true, max_bars_back = 1000)

// ============================================================================
//                                   INPUTS
// ============================================================================
g_te   = "═ TRANSFER ENTROPY ═"
h      = input.int(6,   "Forward horizon h (bars)",        minval = 1, maxval = 48, group = g_te)
condWin= input.int(6,   "Momentum conditioning window",    minval = 1, maxval = 48, group = g_te)
bins   = input.int(4,   "Bins per dimension",              minval = 3, maxval = 6,  group = g_te)
K      = input.int(15,  "Null shuffle iterations (K)",     minval = 5, maxval = 40, group = g_te)
zThr   = input.float(2.5,"z threshold for a check",        minval = 1.0, step = 0.1, group = g_te)
minN   = input.int(120, "Min samples for a confident verdict", minval = 40, group = g_te)

g_win  = "═ IS / OOS CALENDAR WINDOWS ═"
isStart  = input.time(timestamp("2025-01-01T00:00:00"), "IS  Start Date", group = g_win)
isEnd    = input.time(timestamp("2025-04-30T23:59:59"), "IS  End Date",   group = g_win)
oosStart = input.time(timestamp("2025-05-01T00:00:00"), "OOS Start Date", group = g_win)
oosEnd   = input.time(timestamp("2025-06-30T23:59:59"), "OOS End Date",   group = g_win)

g_f1 = "═ FEATURES · Volume & Order Flow ═"
e_rvol = input.bool(true,  "RVOL_Z · Unusual Volume Z-Score", group = g_f1)
e_clv  = input.bool(true,  "CLV · Close Location Value",      group = g_f1)
e_lpa  = input.bool(true,  "LPA · Limit-Order Absorption",    group = g_f1)
e_vbrk = input.bool(true,  "VOL_BRK · Volume Breakout",       group = g_f1)
e_vexh = input.bool(false, "VOL_EXH · Volume Exhaustion",     group = g_f1)
e_cvda = input.bool(false, "CVD_A · Proxy CVD Acceleration",  group = g_f1)

g_f2 = "═ FEATURES · Equity Structural ═"
symBench=input.symbol("AMEX:SPY", "Benchmark Index for RS",   group = g_f2)
e_idx  = input.bool(true,  "IDX_RS · Index Relative Strength",group = g_f2)
e_gap  = input.bool(true,  "GAP_SZ · Overnight Gap Extent",   group = g_f2)
e_vwap = input.bool(true,  "VWAP_D · Distance from VWAP",     group = g_f2)
e_stl  = input.bool(false, "TOD · Time of Day Oscillator",    group = g_f2)

g_f3 = "═ FEATURES · Momentum & PA ═"
e_sfi  = input.bool(true,  "SFI · Swing-Failure Intensity",   group = g_f3)
e_rocv = input.bool(true,  "ROC_V · ROC Velocity",            group = g_f3)
e_macd = input.bool(false, "MACD_Z · Normalized MACD",        group = g_f3)
e_d50  = input.bool(false, "DIST_50 · Distance from SMA50",   group = g_f3)
e_bbw  = input.bool(false, "BBW_Z · Band-Width Compression",  group = g_f3)
e_atr  = input.bool(false, "ATR_EXT · ATR-norm ext EMA20",    group = g_f3)

g_ui   = "═ UI ═"
posT   = input.string("Top Right", "Panel position", options = ["Top Left","Top Right","Bottom Left","Bottom Right"], group = g_ui)
txt    = input.string("small", "Text size", options = ["tiny","small","normal"], group = g_ui)
showCSV= input.bool(true, "Drop CSV label on last bar", group = g_ui)

// ---- UI Helpers ----
f_pos(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : position.bottom_right
f_txt(string s) => s == "tiny" ? size.tiny : s == "normal" ? size.normal : size.small

// ============================================================================
//                          MATH / TE CORE
// ============================================================================
f_hash(float x) =>
    float v = math.sin(x * 12.9898) * 43758.5453
    v - math.floor(v)

f_zscore(float src, int len) =>
    float m = ta.sma(src, len)
    float s = ta.stdev(src, len)
    nz(s) > 0.0 ? (src - m) / s : 0.0

f_bin_idx(array<float> a, int n, int b) =>
    float mn = array.get(a, 0)
    float mx = mn
    for s = 1 to n - 1
        float v = array.get(a, s)
        mn := math.min(mn, v)
        mx := math.max(mx, v)
    float rng = (mx - mn) == 0.0 ? 1.0 : (mx - mn)
    array<int> idx = array.new_int(n, 0)
    for s = 0 to n - 1
        int bi = math.max(0, math.min(b - 1, int(math.floor((array.get(a, s) - mn) / rng * b))))
        array.set(idx, s, bi)
    idx

f_te_bins(array<int> byf, array<int> byp, array<int> bx, int n, int b, int shift) =>
    int b2 = b * b
    array<float> joint  = array.new_float(b * b * b, 0.0)
    array<float> mYp    = array.new_float(b, 0.0)
    array<float> mYpX   = array.new_float(b2, 0.0)
    array<float> mYfYp  = array.new_float(b2, 0.0)
    for s = 0 to n - 1
        int xi = array.get(bx, (s + shift) % n)
        int jf = array.get(byf, s)
        int jp = array.get(byp, s)
        int ij = jf * b2 + jp * b + xi
        array.set(joint,  ij, array.get(joint, ij) + 1.0)
        array.set(mYp,    jp, array.get(mYp, jp) + 1.0)
        array.set(mYpX,   jp * b + xi, array.get(mYpX, jp * b + xi) + 1.0)
        array.set(mYfYp,  jf * b + jp, array.get(mYfYp, jf * b + jp) + 1.0)
    float te = 0.0
    float fn = float(n)
    for jf = 0 to b - 1
        for jp = 0 to b - 1
            for xi = 0 to b - 1
                float J = array.get(joint, jf * b2 + jp * b + xi)
                if J > 0.0
                    float num = J * array.get(mYp, jp)
                    float den = array.get(mYpX, jp * b + xi) * array.get(mYfYp, jf * b + jp)
                    if den > 0.0
                        te += (J / fn) * math.log(num / den)
    math.max(0.0, te)

f_te_full(array<float> xa, array<float> ypa, array<float> yfa, int n, int b, int k, float seed) =>
    float real = na
    float mean = na
    float sd   = na
    if n >= 50
        array<int> bx  = f_bin_idx(xa,  n, b)
        array<int> byp = f_bin_idx(ypa, n, b)
        array<int> byf = f_bin_idx(yfa, n, b)
        real := f_te_bins(byf, byp, bx, n, b, 0)
        float sm  = 0.0
        float sm2 = 0.0
        for kk = 0 to k - 1
            int sh = 1 + int(math.floor(f_hash(seed + kk * 7.31 + bar_index * 0.013) * (n - 1)))
            float tk = f_te_bins(byf, byp, bx, n, b, sh)
            sm  += tk
            sm2 += tk * tk
        mean := sm / k
        sd   := math.sqrt(math.max(0.0, sm2 / k - mean * mean))
    [real, mean, sd]

f_z(float real, float mean, float sd) =>
    (not na(real) and sd > 1e-9) ? (real - mean) / sd : na

// ============================================================================
//                      FEATURE SERIES  (native, every bar)
// ============================================================================
float atr    = math.max(ta.atr(14), syminfo.mintick)
float bVol   = nz(volume, 0.0)
float rng0   = (high - low) == 0.0 ? syminfo.mintick : (high - low)
float mid    = (high + low) / 2.0

// -- Fetch Benchmark for Equities Relative Strength
float benchClose = request.security(symBench, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// -- Controls
float ret1   = math.log(close / nz(close[1], close))                         // [0] CONTROL price own past
float randf  = f_hash(bar_index) * 2.0 - 1.0                                 // [1] CONTROL pure noise

// -- Volume & Order Flow
float rvolZ  = f_zscore(bVol, 50)                                            // Unusual Volume Z-Score
float clv    = (2.0 * close - high - low) / rng0                             // Close-location value
float body   = math.abs(close - open)
float lpa    = bVol * (1.0 - body / rng0)                                    // Limit-order absorption (churn)
float volSma = ta.sma(bVol, 20)
float rvol   = volSma > 0.0 ? bVol / volSma : 0.0
float vbrk   = rvol * (close > nz(close[1], close) ? 1.0 : -1.0)             // Volume breakout (signed)
float vexh   = rvol * (((high - close) - (close - low)) / rng0)              // Volume climax/exhaustion
float cvd    = ta.cum(bVol * (close >= open ? 1.0 : -1.0))
float cvdA   = cvd - 2.0 * nz(cvd[1], cvd) + nz(cvd[2], cvd)                 // Proxy CVD acceleration

// -- Equity Structural
float idxRS  = ta.roc(close, 5) - ta.roc(benchClose, 5)                      // Index Relative Strength
float gapSz  = (open - nz(close[1], open)) / atr                             // Overnight gap extent (normalized)
float vwapD  = (close - ta.vwap) / ta.stdev(close - ta.vwap, 50)             // Distance from VWAP (z-score)
float tod    = (hour + minute / 60.0) / 24.0
float stl    = math.sin(2.0 * math.pi * tod)                                 // Cyclical time-of-day

// -- Momentum & PA
float hh10   = ta.highest(high, 10)[1]
float ll10   = ta.lowest(low, 10)[1]
float sfi    = (high > hh10 and close < hh10 ? (high - hh10) / atr : 0.0) - (low < ll10 and close > ll10 ? (ll10 - low) / atr : 0.0)
float roc    = ta.roc(close, 10)
float rocv   = roc - nz(roc[1], roc)                                         // ROC velocity
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
float macdZ  = f_zscore(macdL, 50)                                           // Normalized MACD
float dist50 = (close - ta.sma(close, 50)) / atr                             // Distance from SMA50
float bbBasis= ta.sma(close, 20)
float bbw    = bbBasis != 0.0 ? (2.0 * 2.0 * ta.stdev(close, 20)) / bbBasis : 0.0
float bbwZ   = f_zscore(bbw, 50)                                             // Band-width compression
float atrExt = (close - ta.ema(close, 20)) / atr                             // ATR-normalized ext EMA20

// ============================================================================
//                        FEATURE REGISTRY (built once)
// ============================================================================
int MAXF = 18
var array<string> allName = array.new_string(0)
var array<bool>   allEn   = array.new_bool(0)
var array<bool>   allCtrl = array.new_bool(0)
var array<float>  allSeed = array.new_float(0)
var int Ftot = 0
if barstate.isfirst
    array<string> bN = array.from("RET1 (ctrl)","RAND (ctrl)","RVOL_Z","CLV press","LPA absorb","VOL_BRK","VOL_EXH","CVD accel (pxy)","IDX_RS","GAP_SZ","VWAP_D","TOD osc","SFI failure","ROC_V","MACD_Z","DIST_50","BBW_Z","ATR_EXT")
    array<bool>   bE = array.from(true, true, e_rvol, e_clv, e_lpa, e_vbrk, e_vexh, e_cvda, e_idx, e_gap, e_vwap, e_stl, e_sfi, e_rocv, e_macd, e_d50, e_bbw, e_atr)
    array<bool>   bC = array.from(true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false)
    for i = 0 to 17
        array.push(allName, array.get(bN, i))
        array.push(allEn,   array.get(bE, i))
        array.push(allCtrl, array.get(bC, i))
        array.push(allSeed, i * 10.0 + 10.0)
    Ftot := array.size(allName)

// ============================================================================
//          DATA COLLECTION — Split IS/OOS & Reservoir Subsampling
// ============================================================================
var matrix<float> BUF_IS  = na
var matrix<float> BUF_OOS = na
var array<int>    enIdx   = array.new_int(0)
var int count_IS  = 0
var int count_OOS = 0
var int max_rows  = 0
var int cols      = 0
var int nEn       = 0

if barstate.isfirst
    for i = 0 to Ftot - 1
        if array.get(allEn, i)
            array.push(enIdx, i)
    nEn  := array.size(enIdx)
    cols := nEn + 2 // [yp, yf, feat1, feat2, ...]
    max_rows := math.floor(95000 / math.max(1, cols))
    BUF_IS  := matrix.new<float>(0, cols)
    BUF_OOS := matrix.new<float>(0, cols)

bool warmed = bar_index > (h + condWin + 60)
int  tdec   = int(nz(time[h], 0))
bool inIS   = tdec >= isStart  and tdec <= isEnd
bool inOOS  = tdec >= oosStart and tdec <= oosEnd

if barstate.isconfirmed and warmed and (inIS or inOOS)
    float cprev = nz(close[h], close)
    float yp = math.log(cprev / nz(close[h + condWin], cprev))
    float yf = math.log(close / cprev)

    // Build the master vector for easy indexing
    array<float> full_rv = array.new_float(Ftot, na)
    array.set(full_rv, 0,  nz(ret1[h]))
    array.set(full_rv, 1,  nz(randf[h]))
    array.set(full_rv, 2,  nz(rvolZ[h]))
    array.set(full_rv, 3,  nz(clv[h]))
    array.set(full_rv, 4,  nz(lpa[h]))
    array.set(full_rv, 5,  nz(vbrk[h]))
    array.set(full_rv, 6,  nz(vexh[h]))
    array.set(full_rv, 7,  nz(cvdA[h]))
    array.set(full_rv, 8,  nz(idxRS[h]))
    array.set(full_rv, 9,  nz(gapSz[h]))
    array.set(full_rv, 10, nz(vwapD[h]))
    array.set(full_rv, 11, nz(stl[h]))
    array.set(full_rv, 12, nz(sfi[h]))
    array.set(full_rv, 13, nz(rocv[h]))
    array.set(full_rv, 14, nz(macdZ[h]))
    array.set(full_rv, 15, nz(dist50[h]))
    array.set(full_rv, 16, nz(bbwZ[h]))
    array.set(full_rv, 17, nz(atrExt[h]))

    // Pack ONLY enabled features + target returns into `rv`
    array<float> rv = array.new_float(cols, na)
    array.set(rv, 0, yp)
    array.set(rv, 1, yf)
    for c = 0 to nEn - 1
        array.set(rv, c + 2, array.get(full_rv, array.get(enIdx, c)))

    // Route to the correct matrix with reservoir cap
    if inIS
        count_IS += 1
        if count_IS <= max_rows
            matrix.add_row(BUF_IS, matrix.rows(BUF_IS), rv)
        else
            int idx = int(math.floor(f_hash(bar_index + count_IS * 1.37) * count_IS))
            if idx < max_rows
                for c = 0 to cols - 1
                    matrix.set(BUF_IS, idx, c, array.get(rv, c))

    if inOOS
        count_OOS += 1
        if count_OOS <= max_rows
            matrix.add_row(BUF_OOS, matrix.rows(BUF_OOS), rv)
        else
            int idx = int(math.floor(f_hash(bar_index + count_OOS * 1.37) * count_OOS))
            if idx < max_rows
                for c = 0 to cols - 1
                    matrix.set(BUF_OOS, idx, c, array.get(rv, c))

// ============================================================================
//     LAST-BAR: per-feature IS_Z / OOS_Z  ->  table + CSV string + ALERT
// ============================================================================
color c_bg = color.rgb(30, 30, 30)
color c_hd = color.black
var table tb   = table.new(f_pos(posT), 4, MAXF + 2, border_width = 1, border_color = color.gray, bgcolor = c_bg)
var label csvL = na

if barstate.islast
    // header
    table.cell(tb, 0, 0, "FEATURE", bgcolor = c_hd, text_color = color.white, text_size = f_txt(txt))
    table.cell(tb, 1, 0, "IS z",    bgcolor = c_hd, text_color = color.white, text_size = f_txt(txt))
    table.cell(tb, 2, 0, "OOS z",   bgcolor = c_hd, text_color = color.white, text_size = f_txt(txt))
    table.cell(tb, 3, 0, "nIS|nOOS",bgcolor = c_hd, text_color = color.white, text_size = f_txt(txt))

    string masterCSV = "Feature,IS_Z,OOS_Z\n"
    int row = 0

    // Extract conditioning arrays directly from matrices
    array<float> ypi = matrix.rows(BUF_IS) > 0 ? matrix.col(BUF_IS, 0) : array.new_float(0)
    array<float> yfi = matrix.rows(BUF_IS) > 0 ? matrix.col(BUF_IS, 1) : array.new_float(0)
    array<float> ypo = matrix.rows(BUF_OOS) > 0 ? matrix.col(BUF_OOS, 0) : array.new_float(0)
    array<float> yfo = matrix.rows(BUF_OOS) > 0 ? matrix.col(BUF_OOS, 1) : array.new_float(0)

    int niS = array.size(ypi)
    int noS = array.size(ypo)

    for c = 0 to nEn - 1
        int i = array.get(enIdx, c)
        row += 1
        float seed   = array.get(allSeed, i)
        bool  isCtrl = array.get(allCtrl, i)
        string nm    = array.get(allName, i)

        // ---- In-Sample z ----
        array<float> xi = matrix.rows(BUF_IS) > 0 ? matrix.col(BUF_IS, c + 2) : array.new_float(0)
        [ri, mi, si] = f_te_full(xi, ypi, yfi, niS, bins, K, seed)
        float isz = f_z(ri, mi, si)

        // ---- Out-of-Sample z ----
        array<float> xo = matrix.rows(BUF_OOS) > 0 ? matrix.col(BUF_OOS, c + 2) : array.new_float(0)
        [ro, mo, so] = f_te_full(xo, ypo, yfo, noS, bins, K, seed + 1000.0)
        float oosz = f_z(ro, mo, so)

        string isS  = na(isz)  ? "NA" : str.tostring(isz,  "#.##")
        string oosS = na(oosz) ? "NA" : str.tostring(oosz, "#.##")
        masterCSV := masterCSV + nm + "," + isS + "," + oosS + "\n"

        // ---- table row ----
        color nameCol = isCtrl ? color.new(color.orange, 0) : color.silver
        color isCol  = na(isz)  ? color.gray : (isz  >= zThr ? color.lime : (isz  >= 1.0 ? color.orange : color.gray))
        color oosCol = na(oosz) ? color.gray : (oosz >= zThr ? color.lime : (oosz >= 1.0 ? color.orange : color.gray))
        
        isCol  := (not na(isz)  and niS < minN) ? color.new(isCol, 45)  : isCol
        oosCol := (not na(oosz) and noS < minN) ? color.new(oosCol, 45) : oosCol
        
        table.cell(tb, 0, row, nm,   bgcolor = c_bg, text_color = nameCol, text_size = f_txt(txt))
        table.cell(tb, 1, row, isS,  bgcolor = c_bg, text_color = isCol,   text_size = f_txt(txt))
        table.cell(tb, 2, row, oosS, bgcolor = c_bg, text_color = oosCol,  text_size = f_txt(txt))
        table.cell(tb, 3, row, str.tostring(niS) + "|" + str.tostring(noS), bgcolor = c_bg, text_color = color.silver, text_size = f_txt(txt))

    // footer
    row += 1
    table.cell(tb, 0, row, "h=" + str.tostring(h) + " cond=" + str.tostring(condWin) + " | cap=" + str.tostring(max_rows), bgcolor = c_hd, text_color = color.silver, text_size = f_txt(txt))
    table.merge_cells(tb, 0, row, 3, row)

    if showCSV
        label.delete(csvL)
        csvL := label.new(bar_index, ta.highest(high, 20), "▦ CSV (hover)", style = label.style_label_left, color = color.new(color.black, 20), textcolor = color.aqua, size = size.small, tooltip = masterCSV)

    // ---- EMAIL ALERT ----
    alert(masterCSV, alert.freq_once_per_bar_close)
````
