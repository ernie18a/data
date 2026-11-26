# DJIA Top-7 vs YM

- url: https://www.tradingview.com/script/fm6jifse/
- type: indicator
- pine_id: PUB;cd876bafdb5a47b7918621a0c040bf0b
- version: 1.0

## Description

DJIA Top-7 vs YM (v5.2)
Co robi
Pokazuje ile ruchu YM (Dow futures) pochodzi z 7 najcięższych komponentów Dow Jones w ujęciu price-weighted (nie cap-weighted jak NQ — Dow to jeden z nielicznych indeksów które wciąż używają price-weighting przez Dow divisor ≈ 0.16242563904928).
Top-7 spółek: GS, MSFT, HD, CAT, SHW, V, AXP — razem stanowią największą część 30-spółkowego indeksu w ujęciu udziału w ruchu.
Dwie linie w osobnym panelu pod YM:

Niebieska — suma punktów YM pochodzących z top-7 (price delta × Dow divisor)
Biała — faktyczny ruch YM w punktach

Jak interpretować — różnica vs NQ
DJIA jest price-weighted, więc akcje z najwyższą ceną mają największy wpływ niezależnie od kapitalizacji rynkowej. GS (~$580) porusza indeks bardziej niż MSFT mimo że MSFT ma ~10x większą market cap.
To oznacza że mały ruch w GS = duży ruch w YM, a duży ruch w KO (tania akcja) = mały ruch w YM. Sygnały divergence reading:
Niebieska nad białą → top-7 high-price stocks ciągną, reszta Dow neutral
Niebieska pod białą → ruch w Dow driven przez mid/low-price stocks (szerszy rally)
Duży divergence → jedna konkretna akcja dominuje ruch (GS earnings beat, MSFT news itd.) — mean-reversion kandydat
Tabela (prawy górny róg)
Te same wiersze i kolumny co NQ:

Header, Top-7/YM, Divergence, Breadth, VWAP Bal, Gaps, Pull/Drag, per-symbol breakdown
Wt% = share udziału w ruchu price-weighted (nie market-cap weighted)
pts_i = (price_change_i) / Dow_divisor × 5 (x5 bo YM tick = $5)

Użycie intraday
Identycznie jak NQ — ale pamiętaj że w DJIA:

Ceny akcji (nie kapitalizacja) decydują o impakt
GS, MSFT, HD, CAT najczęściej dominują ruch
Spikes w jednej akcji (earnings, news) mocniej się przekładają niż w NQ gdzie impact jest rozcieńczony przez cap-weighting
Divergence + Top Pull → nazwisko pojedynczej akcji ciągnącej ruch daje natychmiastowy sygnał „co dziś driving market"

Limitations

7 spółek to ograniczony sample z 30 Dow components — pozostałe 23 też wpływają, ale mniej
Price-weighting znaczy że zmiana ceny $10 w $600 akcji (1.7%) ma taki sam impact jak $10 w $100 akcji (10%) — różne risk-reward implications
Skład Dow zmienia się rzadko (ostatnie rekonstrukcje: 2024 AMZN zamiast WBA, 2020 SHW/HON/AMGN) — update inputów rzadziej niż NQ
Dow divisor zmienia się przy splitach i rekonstrukcjach — sprawdź dowdivisor.com lub spindices.com jeśli ruch wygląda off
VWAP warm-up jak w NQ (15-30 min)

Różnice DJIA vs NQ w skrócie
AspektNQ (top-10)DJIA (top-7)WeightingMarket capPrice (Dow divisor)Dominant stocksNVDA, AAPL, MSFTGS, MSFT, HDRebalanceKwartalnyRzadki (lata)Impact per stock~3-8%Zmienny po cenieDivergence meaningCap-based broad/narrowSingle-name driver

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// DJIA TOP-7 vs YM — Real Points Scale  [v5]
// Pine Script v6
// ══════════════════════════════════════════════════════════════════════════════
//
// BOTH LINES ON THE SAME SCALE — actual Dow/YM points:
//
//   BLUE LINE  = how many YM points the top 7 stocks generated
//   WHITE LINE = how many points YM actually moved
//
//   Each $1 stock price change = 1/divisor = ~6.16 Dow points.
//   GS rising $5 = +30.8 Dow points.
//   If all top 7 combined generate +120 pts but YM only moved +80 pts
//   → the other 23 stocks are DRAGGING by 40 pts.
//
// ──────────────────────────────────────────────────────────────────────────────
// CHANGELOG v5.2 (parity with NQ v4.3):
//
// NEW IN v5.2 — PD VWAP + configurable table:
//   • Added PD VWAP column (↑/↓ vs previous day's closing VWAP).
//     PD VWAP = ta.vwap(hlc3)[1] on daily timeframe = yesterday's
//     final VWAP = institutional closing reference.
//     STABLE from first tick of session — complements intraday VWAP
//     which needs 15-30 min warm-up.
//   • Table now configurable: toggle Divergence / Breadth / VWAP Bal /
//     Gaps / Pull-Drag rows. Toggle VWAP / PD VWAP / Behav columns.
//   • Removed "VWAP session mode" toggle — PD VWAP solves the early-
//     session problem better than forcing RTH on intraday VWAP.
//   • Request budget: 1 YM daily + 7 × (close+vwap | daily[open,pClose,pdVwap])
//     = 15 unique calls per bar. Under Pine's 40-call limit.
//
// NEW IN v5 — Per-stock BEHAVIOR column:
//   TREND↑ / TREND↓ / BOUNCE / FADE / FLAT
//   Uses (session open, prev close) as two reference points.
//   Tells you if a heavy name is continuing its direction or reversing.
//   Configurable threshold (default 0.2%).
//
// VISUAL & SPEED:
//   • Smoothing selector: Off / HMA / EMA / SMA (default HMA — smooth + low lag).
//   • Line width configurable (default 3).
//   • Reference hlines at ±refLevel1/±refLevel2/±refLevel3 — stretches Y-axis.
//   • explicit_plot_zorder for clean layer order (hlines behind lines).
//
// TICK DATA INTRABAR:
//   • request.security() updates on EVERY tick of each symbol in realtime.
//     This is Pine v6 DEFAULT for indicators — no flag needed.
//   • Historical bars show confirmed values; realtime bar shows live tick price.
//
// v4 FIXES (preserved):
//   • Table shows RAW values (Σ per-symbol == Top-7 row exactly).
//   • Top Pull/Drag sign-guarded — "—" when no valid pull/drag exists.
//   • fmtPts() helper — no "+-3.5pt" formatting bug.
//   • Divergence labels handle BEAR scenarios (DIVERGENT for opposite signs).
//   • VWAP ↑/↓ shows "—" for na data.
//   • Breadth row (up/down count).
//   • YM Gap has its own row.
//   • Per-symbol "—" for na data.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("DJIA Top-7 vs YM (pts) v5.2",
     overlay              = false,
     max_bars_back        = 500,
     explicit_plot_zorder = true)

// ─── Inputs: Top 7 DJIA components (price-weighted) ────────────────────────
// Weights shown are cosmetic labels. Matematyka używa request.security() cen.
// DJIA is PRICE-weighted, so highest-priced stocks = highest weight.
// Check composition quarterly; major changes need component list update.
string sym1 = input.symbol("NYSE:GS",     title = "1. GS  ~11%",  group = "Dow Top 7")
string sym2 = input.symbol("NYSE:CAT",    title = "2. CAT  ~9%",  group = "Dow Top 7")
string sym3 = input.symbol("NASDAQ:MSFT", title = "3. MSFT ~5%",  group = "Dow Top 7")
string sym4 = input.symbol("NASDAQ:AMGN", title = "4. AMGN ~4.5%", group = "Dow Top 7")
string sym5 = input.symbol("NYSE:HD",     title = "5. HD  ~4.5%", group = "Dow Top 7")
string sym6 = input.symbol("NYSE:SHW",    title = "6. SHW ~4.6%", group = "Dow Top 7")
string sym7 = input.symbol("NYSE:MCD",    title = "7. MCD  ~4%",  group = "Dow Top 7")

// Dow Divisor — converts $1 stock move to Dow points.
float divisor = input.float(0.16242563904928, title = "Dow Divisor",
     tooltip  = "Current: 0.16242563904928 (Oct 2025).\nEach $1 move = 1/divisor = ~6.16 Dow points.\nUpdate after Dow composition changes or stock splits.",
     group    = "Dow")

string modeInput = input.string("From Previous Close", title = "Reference",
     options  = ["From Session Open", "From Previous Close"],
     tooltip  = "From Previous Close: includes overnight gap (recommended).\nFrom Session Open: starts at 0, no gap.",
     group    = "Display")

// ─── Smoothing (plots only — table always shows RAW) ────────────────────────
string smoothType = input.string("HMA", title = "Smoothing type",
     options = ["Off", "HMA", "EMA", "SMA"],
     tooltip = "HMA = Hull MA, smooth with less lag than EMA (recommended).\nOff = no smoothing, raw tick values.\nTable always shows RAW regardless of this setting.",
     group   = "Display")
int smoothLen = input.int(5, title = "Smoothing length", minval = 2, maxval = 50,
     tooltip = "HMA(5) ≈ EMA(3) smoothness but with ~60% less lag.",
     group   = "Display")

int lineWidth = input.int(3, title = "Line width", minval = 1, maxval = 5,
     group = "Display")

// ─── Reference levels (stretches Y-axis visibility) ────────────────────────
bool showRefLines = input.bool(true, title = "Show reference levels",
     tooltip = "Horizontal bands at ±levels to force Y-axis minimum range.\nKeeps proportions visible even on quiet sessions.",
     group   = "Display")
int refLevel1 = input.int(25, title = "Reference level 1 (pts)", minval = 5, maxval = 500,
     group = "Display")
int refLevel2 = input.int(50, title = "Reference level 2 (pts)", minval = 10, maxval = 1000,
     group = "Display")
int refLevel3 = input.int(100, title = "Reference level 3 (pts)", minval = 20, maxval = 2000,
     group = "Display")

float divThresh   = input.float(5.0, title = "Divergence threshold (pts)",
     minval = 0.1, maxval = 50.0, step = 0.5, group = "Display",
     tooltip = "Absolute gap below which Top-7 and YM are considered Aligned.")

float behavThresh = input.float(0.2, title = "Behavior threshold (%)",
     minval = 0.05, maxval = 2.0, step = 0.05,
     tooltip = "Min % move from session open to classify TREND/BOUNCE/FADE.\nBelow this → FLAT.\n\nBEHAVIOR LOGIC (per stock, session-story since open):\n• TREND↑  : up from open, gap was not down → trending up\n• TREND↓  : down from open, gap was not up → trending down\n• BOUNCE  : gap DOWN but now UP from open → reversal up (buying dip)\n• FADE    : gap UP but now DOWN from open → reversal down (selling rally)\n• FLAT    : move from open below threshold",
     group   = "Display")

string sessionFlt = input.string("0930-1600", title = "Plot session", group = "Display")
string sessionTZ  = input.string("America/New_York", title = "Timezone", group = "Display")
bool showTable    = input.bool(true, title = "Show table", group = "Display")

// ─── Table rows configuration ──────────────────────────────────────────────
// Toggle which rows to display in the table. Helps declutter on small screens.
bool showRowDiv      = input.bool(true, title = "Show Divergence row", group = "Table rows")
bool showRowBreadth  = input.bool(true, title = "Show Breadth row",    group = "Table rows")
bool showRowVwapBal  = input.bool(true, title = "Show VWAP Balance row",group = "Table rows")
bool showRowGaps     = input.bool(true, title = "Show Gap rows (3 rows)",group = "Table rows",
     tooltip = "Top-N Gap, Index Gap, Gap Div — all three shown together")
bool showRowPullDrag = input.bool(true, title = "Show Top Pull/Drag rows",group = "Table rows")
bool showSymbols     = input.bool(true, title = "Show per-symbol breakdown",group = "Table rows")

// ─── Per-symbol columns configuration ──────────────────────────────────────
bool colVwap     = input.bool(true, title = "Column: VWAP arrow",    group = "Symbol columns",
     tooltip = "↑/↓ vs today's session VWAP (intraday benchmark).\nNote: unreliable in first 15-30 min of session.")
bool colPdVwap   = input.bool(true, title = "Column: PD VWAP arrow", group = "Symbol columns",
     tooltip = "↑/↓ vs Previous Day's closing VWAP.\nStable institutional reference from first tick of session.\nEspecially useful in early-session when today's VWAP is noisy.")
bool colBehav    = input.bool(true, title = "Column: Behavior",      group = "Symbol columns",
     tooltip = "TREND↑/TREND↓/BOUNCE/FADE/FLAT — session story since open.")

var array<string> syms = array.from(sym1, sym2, sym3, sym4, sym5, sym6, sym7)
int N = 7

// Points per $1 of stock price change
float ptsPerDollar = 1.0 / divisor   // ~6.16


// ─── Helpers ────────────────────────────────────────────────────────────────
shortName(string s) =>
    int c = str.pos(s, ":")
    c >= 0 ? str.substring(s, c + 1) : s

// Format signed points with conditional "+" prefix
// Returns "—" for na to avoid misleading "+0.0" on missing data
fmtPts(float v) =>
    na(v) ? "—" : ((v >= 0 ? "+" : "") + str.tostring(v, "#.0"))

// Unified smoother: HMA recommended (smooth + low lag)
smooth(float src, int len, string t) =>
    float result = na
    if t == "Off" or len < 2
        result := src
    else if t == "EMA"
        result := ta.ema(src, len)
    else if t == "SMA"
        result := ta.sma(src, len)
    else  // HMA default
        int halfLen = math.max(1, math.round(len / 2.0))
        int sqrtLen = math.max(1, math.round(math.sqrt(len)))
        result := ta.wma(2 * ta.wma(src, halfLen) - ta.wma(src, len), sqrtLen)
    result


// ─── YM data ────────────────────────────────────────────────────────────────
[ymDailyOpen, ymPrevClose] = request.security(syminfo.tickerid, "D", [open, close[1]],
     lookahead = barmerge.lookahead_on)

float ymRef = modeInput == "From Session Open" ? ymDailyOpen : ymPrevClose
float ymPoints = not na(ymRef) ? close - ymRef : 0.0
float ymGapPts = not na(ymDailyOpen) and not na(ymPrevClose)
     ? ymDailyOpen - ymPrevClose : 0.0


// ─── Fetch top-7 stock data (minimal-calls approach) ──────────────────────
// Budget: 7 × 1 + 1 = 8 unique calls. Far under Pine's 40 limit.
//
// Strategy: ONE request.security per symbol returning a tuple with 5 fields:
//   [close, vwap_today, dailyOpen, prevDailyClose, prevDayVwap]
//
// All computed inside the requested chart-TF context using:
//   - close              → current price
//   - ta.vwap(hlc3)      → today's intraday VWAP (session-anchored)
//   - dailyOpen tracked via session-start detection
//   - prevDailyClose tracked via session-end snapshot
//   - prevDayVwap = final VWAP value of previous session

// Helper: compute session-start / session-end anchored fields.
// Runs INSIDE request.security context for each symbol.
symDataExpr() =>
    bool newSession = ta.change(time("D")) != 0
    var float dOpenCur = na
    if newSession
        dOpenCur := open
    var float pCloseCur = na
    if newSession
        pCloseCur := close[1]
    float vwapNow = ta.vwap(hlc3)
    var float pdVwapCur = na
    var float pdVwapPrev = na
    if newSession
        pdVwapPrev := pdVwapCur
        pdVwapCur := vwapNow
    else
        pdVwapCur := vwapNow
    [close, vwapNow, dOpenCur, pCloseCur, pdVwapPrev]

array<float> prices   = array.new<float>(N, na)
array<float> vwaps    = array.new<float>(N, na)
array<float> dOpens   = array.new<float>(N, na)
array<float> pCloses  = array.new<float>(N, na)
array<float> pdVwaps  = array.new<float>(N, na)

for i = 0 to N - 1
    string sym = syms.get(i)

    // ONE request per symbol — tuple of 5 fields all computed in chart-TF context.
    [symClose, symVwap, symDOpen, symPrevClose, symPdVwap] =
         request.security(sym, timeframe.period, symDataExpr(),
              ignore_invalid_symbol = true)

    prices.set(i, symClose)
    vwaps.set(i, symVwap)
    dOpens.set(i, symDOpen)
    pCloses.set(i, symPrevClose)
    pdVwaps.set(i, symPdVwap)


// ─── Compute top-7 contribution in DOW POINTS ──────────────────────────────
// Dow = Σ(stockPrices) / divisor   →   ΔDow = Σ(ΔstockPrices) / divisor
// So top-7 contribution = Σ(ΔPrice_i / divisor) for i∈top7
float top7Points   = 0.0
float top7GapPts   = 0.0
int   activeN      = 0
int   upCount      = 0
int   downCount    = 0

// VWAP balance (price-weighted, needs weights)
// First compute weights for VWAP balance
float priceSum = 0.0
for i = 0 to N - 1
    float base = modeInput == "From Session Open" ? dOpens.get(i) : pCloses.get(i)
    if not na(base) and base > 0
        priceSum := priceSum + base

// Per-symbol data — init to na so missing symbols render "—" not "+0.0"
array<float> symPts    = array.new<float>(N, na)
array<float> symGapPts = array.new<float>(N, na)
array<float> symWts    = array.new<float>(N, 0.0)

float vwapWtAbove = 0.0
float vwapWtBelow = 0.0
int   vwapAboveN  = 0
int   vwapBelowN  = 0

for i = 0 to N - 1
    float p  = prices.get(i)
    float dO = dOpens.get(i)
    float pC = pCloses.get(i)
    float v  = vwaps.get(i)
    float ref = modeInput == "From Session Open" ? dO : pC

    // Price-weight for VWAP balance
    float w = 0.0
    if not na(ref) and ref > 0 and priceSum > 0
        w := ref / priceSum
    symWts.set(i, w)

    if not na(p) and not na(ref) and ref > 0
        float dollarChg = p - ref
        float pts = dollarChg * ptsPerDollar
        symPts.set(i, pts)
        top7Points := top7Points + pts
        activeN    := activeN + 1

        if dollarChg > 0.01
            upCount := upCount + 1
        else if dollarChg < -0.01
            downCount := downCount + 1

        if not na(v) and w > 0
            if p > v
                vwapWtAbove := vwapWtAbove + w
                vwapAboveN  := vwapAboveN + 1
            else if p < v
                vwapWtBelow := vwapWtBelow + w
                vwapBelowN  := vwapBelowN + 1

    // Gap in points
    if not na(dO) and not na(pC)
        float gapDollar = dO - pC
        float gPts = gapDollar * ptsPerDollar
        symGapPts.set(i, gPts)
        top7GapPts := top7GapPts + gPts


// ─── Derived values ─────────────────────────────────────────────────────────
float divergencePts = top7Points - ymPoints
float gapDivPts     = top7GapPts - ymGapPts
float vwapBalance   = (vwapWtAbove - vwapWtBelow) * 100.0

// Magnitude-based divergence classification (works bull & bear)
float absT7    = math.abs(top7Points)
float absYM    = math.abs(ymPoints)
float magGap   = absT7 - absYM
bool  opposite = top7Points * ymPoints < 0


// ─── Smoothing (plots only — table uses raw) ────────────────────────────────
float smoothTop7 = smooth(top7Points, smoothLen, smoothType)
float smoothYM   = smooth(ymPoints,   smoothLen, smoothType)


// ─── Plots ──────────────────────────────────────────────────────────────────
bool inSession = str.length(sessionFlt) == 0 or not na(time(timeframe.period, sessionFlt, sessionTZ))
bool canPlot   = inSession and activeN >= 2

// Reference levels — stretch Y-axis to force visible range.
// Toggle via color transparency (hline price must be input-const, not series).
color refL1ColU = showRefLines ? color.new(color.green, 75) : color.new(color.green, 100)
color refL1ColD = showRefLines ? color.new(color.red,   75) : color.new(color.red,   100)
color refL2ColU = showRefLines ? color.new(color.green, 60) : color.new(color.green, 100)
color refL2ColD = showRefLines ? color.new(color.red,   60) : color.new(color.red,   100)
color refL3ColU = showRefLines ? color.new(color.green, 40) : color.new(color.green, 100)
color refL3ColD = showRefLines ? color.new(color.red,   40) : color.new(color.red,   100)

hline(0, title = "Zero", color = color.new(color.gray, 30), linestyle = hline.style_dotted)
hline( refLevel1, title = "+L1", color = refL1ColU, linestyle = hline.style_dashed)
hline(-refLevel1, title = "-L1", color = refL1ColD, linestyle = hline.style_dashed)
hline( refLevel2, title = "+L2", color = refL2ColU, linestyle = hline.style_dashed)
hline(-refLevel2, title = "-L2", color = refL2ColD, linestyle = hline.style_dashed)
hline( refLevel3, title = "+L3", color = refL3ColU, linestyle = hline.style_solid)
hline(-refLevel3, title = "-L3", color = refL3ColD, linestyle = hline.style_solid)

// BLUE: top-7 contribution in Dow points
float pTop7 = canPlot ? smoothTop7 : na
p_t7 = plot(pTop7, title = "Top-7 (pts)",
     color = color.rgb(33, 150, 243), linewidth = lineWidth)

// WHITE: actual YM points change
float pYM = canPlot ? smoothYM : na
p_ym = plot(pYM, title = "YM Actual (pts)",
     color = color.new(color.white, 20), linewidth = math.max(1, lineWidth - 1))

// Fill: blue when top-7 leads (by signed diff), red otherwise.
// Note: table labels use magnitude-aware logic for bear-correct interpretation.
fill(p_t7, p_ym,
     color = smoothTop7 >= smoothYM
         ? color.new(color.rgb(33, 150, 243), 85)
         : color.new(color.rgb(255, 82, 82), 85),
     title = "Divergence")

// Background
bool bullBg = canPlot and smoothTop7 > 0 and vwapBalance > 0
bool bearBg = canPlot and smoothTop7 < 0 and vwapBalance < 0
bgcolor(bullBg ? color.new(color.green, 93) : bearBg ? color.new(color.red, 93) : na)


// ─── Find top contributor / detractor ───────────────────────────────────────
// ARCH: sign-guarded when displayed — here we just find extremes.
int topPosIdx = -1
float topPosVal = -999999.0
int topNegIdx = -1
float topNegVal = 999999.0

for i = 0 to N - 1
    float pts = symPts.get(i)
    if not na(pts)
        if pts > topPosVal
            topPosVal := pts
            topPosIdx := i
        if pts < topNegVal
            topNegVal := pts
            topNegIdx := i


// ─── Table ──────────────────────────────────────────────────────────────────
// Dynamic column layout (max 6 cols × 21 rows):
//   Col 0 = Symbol / Row label
//   Col 1 = Primary value (pts / balance / etc)
//   Col 2 = Secondary info (label / text / etc)
//   Col 3..5 = VWAP ↑/↓, PD VWAP ↑/↓, Behav — toggled by user inputs
// Row visibility toggled by showRow* inputs. Empty slots get transparent bg.

// Compute actual column indices based on toggles
int colVwapIdx   = colVwap   ? 3 : -1
int colPdVwapIdx = colPdVwap ? (colVwap ? 4 : 3) : -1
int colBehavIdx  = colBehav  ? (3 + (colVwap ? 1 : 0) + (colPdVwap ? 1 : 0)) : -1
int lastCol = 2 + (colVwap ? 1 : 0) + (colPdVwap ? 1 : 0) + (colBehav ? 1 : 0)

var table tbl = table.new(position.top_right, 6, 21,
     bgcolor = color.new(color.gray, 88), border_width = 1)

// Helper: fill empty extra columns with matching bg
fillExtras(int r, int startCol, color bg) =>
    for c = startCol to lastCol
        table.cell(tbl, c, r, "", bgcolor = bg)

if barstate.islast and showTable
    color hBg = color.new(color.gray, 72)
    color vBg = color.new(color.gray, 92)
    color tc  = color.white
    int   r   = 0

    // ── Title ──
    table.cell(tbl, 0, r, "DJIA TOP-7 vs YM", text_color = tc,
         bgcolor = color.new(color.blue, 60), text_size = size.small)
    table.cell(tbl, 1, r, "~43% of Dow", text_color = tc,
         bgcolor = color.new(color.blue, 60), text_size = size.small)
    table.cell(tbl, 2, r, modeInput, text_color = tc,
         bgcolor = color.new(color.blue, 60), text_size = size.tiny)
    fillExtras(r, 3, color.new(color.blue, 60))
    r := r + 1

    // ── Top-7 points (RAW — matches Σ per-symbol rows) ──
    color t7Col = top7Points > 0 ? color.lime : top7Points < 0 ? color.rgb(255, 100, 100) : tc
    table.cell(tbl, 0, r, "Top-7", text_color = tc, bgcolor = hBg, text_size = size.normal)
    table.cell(tbl, 1, r, fmtPts(top7Points) + " pts",
         text_color = t7Col, bgcolor = vBg, text_size = size.normal)
    table.cell(tbl, 2, r, "", bgcolor = vBg)
    fillExtras(r, 3, vBg)
    r := r + 1

    // ── YM points (RAW) ──
    color ymCol = ymPoints > 0 ? color.lime : ymPoints < 0 ? color.rgb(255, 100, 100) : tc
    table.cell(tbl, 0, r, "YM", text_color = tc, bgcolor = hBg, text_size = size.normal)
    table.cell(tbl, 1, r, fmtPts(ymPoints) + " pts",
         text_color = ymCol, bgcolor = vBg, text_size = size.normal)
    table.cell(tbl, 2, r, "", bgcolor = vBg)
    fillExtras(r, 3, vBg)
    r := r + 1

    // ── Divergence ──
    if showRowDiv
        string divLabel = opposite ? "DIVERGENT"
             : magGap >  divThresh ? "Top-7 leads"
             : magGap < -divThresh ? "FALSE MOVE"
             : "Aligned"
        color divCol = opposite ? color.yellow
             : magGap >  divThresh ? color.lime
             : magGap < -divThresh ? color.rgb(255, 100, 100)
             : tc
        table.cell(tbl, 0, r, "Divergence", text_color = tc, bgcolor = hBg, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(divergencePts) + " pts",
             text_color = divCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, divLabel, text_color = divCol, bgcolor = vBg, text_size = size.small)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── Breadth ──
    if showRowBreadth
        int neutralN = activeN - upCount - downCount
        color brCol = upCount > downCount ? color.lime
             : downCount > upCount ? color.rgb(255, 100, 100)
             : tc
        table.cell(tbl, 0, r, "Breadth", text_color = tc, bgcolor = hBg, text_size = size.small)
        table.cell(tbl, 1, r, str.tostring(upCount) + "↑ " + str.tostring(downCount) + "↓"
             + (neutralN > 0 ? " " + str.tostring(neutralN) + "=" : ""),
             text_color = brCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, str.tostring(activeN) + "/" + str.tostring(N) + " active",
             text_color = tc, bgcolor = vBg, text_size = size.small)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── VWAP Balance ──
    if showRowVwapBal
        color vwapHdr = color.new(color.rgb(33, 150, 243), 70)
        color vwapCol = vwapBalance > 0 ? color.lime : vwapBalance < 0 ? color.rgb(255, 100, 100) : tc
        table.cell(tbl, 0, r, "VWAP Balance", text_color = tc, bgcolor = vwapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(vwapBalance) + "%",
             text_color = vwapCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, str.tostring(vwapAboveN) + "↑ " + str.tostring(vwapBelowN) + "↓",
             text_color = tc, bgcolor = vBg, text_size = size.small)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── Gap section (3 rows: Top-7 Gap, YM Gap, Gap Div) ──
    if showRowGaps
        color gapHdr = color.new(color.yellow, 80)

        color t7gCol = top7GapPts > 0 ? color.lime : top7GapPts < 0 ? color.rgb(255, 100, 100) : tc
        table.cell(tbl, 0, r, "Top-7 Gap", text_color = tc, bgcolor = gapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(top7GapPts) + " pts",
             text_color = t7gCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

        color ymgCol = ymGapPts > 0 ? color.lime : ymGapPts < 0 ? color.rgb(255, 100, 100) : tc
        table.cell(tbl, 0, r, "YM Gap", text_color = tc, bgcolor = gapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(ymGapPts) + " pts",
             text_color = ymgCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

        float magGapG   = math.abs(top7GapPts) - math.abs(ymGapPts)
        bool  oppositeG = top7GapPts * ymGapPts < 0
        string gdLabel  = oppositeG ? "DIVERGENT"
             : magGapG >  divThresh ? "Top-7 gapped more"
             : magGapG < -divThresh ? "YM gapped more"
             : "Aligned"
        color gdCol = oppositeG ? color.yellow
             : magGapG >  divThresh ? color.lime
             : magGapG < -divThresh ? color.rgb(255, 100, 100)
             : tc
        table.cell(tbl, 0, r, "Gap Div", text_color = tc, bgcolor = gapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(gapDivPts) + " pts",
             text_color = gdCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, gdLabel, text_color = gdCol, bgcolor = vBg, text_size = size.small)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── Top Pull / Top Drag ──
    if showRowPullDrag
        bool hasPull = topPosIdx >= 0 and topPosVal > 0
        bool hasDrag = topNegIdx >= 0 and topNegVal < 0

        table.cell(tbl, 0, r, "Top Pull", text_color = tc, bgcolor = hBg, text_size = size.small)
        table.cell(tbl, 1, r, hasPull
             ? shortName(syms.get(topPosIdx)) + " " + fmtPts(topPosVal) + "pt"
             : "—",
             text_color = hasPull ? color.lime : tc, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

        table.cell(tbl, 0, r, "Top Drag", text_color = tc, bgcolor = hBg, text_size = size.small)
        table.cell(tbl, 1, r, hasDrag
             ? shortName(syms.get(topNegIdx)) + " " + fmtPts(topNegVal) + "pt"
             : "—",
             text_color = hasDrag ? color.rgb(255, 100, 100) : tc, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── Per-symbol breakdown ──
    if showSymbols
        color sHdr = color.new(color.gray, 65)
        table.cell(tbl, 0, r, "Symbol",  text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        table.cell(tbl, 1, r, "Dow pts", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        table.cell(tbl, 2, r, "",        bgcolor = sHdr)
        if colVwapIdx >= 0
            table.cell(tbl, colVwapIdx,   r, "VWAP",  text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        if colPdVwapIdx >= 0
            table.cell(tbl, colPdVwapIdx, r, "PD VW", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        if colBehavIdx >= 0
            table.cell(tbl, colBehavIdx,  r, "Behav", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        r := r + 1

        for i = 0 to N - 1
            if r < 20
                float pts = symPts.get(i)
                float sP   = prices.get(i)
                float sV   = vwaps.get(i)
                float sPdV = pdVwaps.get(i)
                float sdO  = dOpens.get(i)
                float spC  = pCloses.get(i)
                bool  hasVwap   = not na(sP) and not na(sV)
                bool  hasPdVwap = not na(sP) and not na(sPdV)
                bool  hasPts    = not na(pts)

                color pCol = not hasPts ? tc
                     : pts > 0 ? color.lime
                     : pts < 0 ? color.rgb(255, 100, 100)
                     : tc
                string vArrow = hasVwap ? (sP > sV ? "↑" : "↓") : "—"
                color vCol = not hasVwap ? tc
                     : sP > sV ? color.lime
                     : color.rgb(255, 100, 100)
                string pdvArrow = hasPdVwap ? (sP > sPdV ? "↑" : "↓") : "—"
                color pdvCol = not hasPdVwap ? tc
                     : sP > sPdV ? color.lime
                     : color.rgb(255, 100, 100)

                // Behavior classifier
                string behavior = "—"
                color  behavCol = tc
                if not na(sP) and not na(sdO) and sdO > 0 and not na(spC) and spC > 0
                    float openMovePct = (sP - sdO) / sdO * 100.0
                    float gapPct      = (sdO - spC) / spC * 100.0
                    if math.abs(openMovePct) < behavThresh
                        behavior := "FLAT"
                        behavCol := color.new(color.gray, 20)
                    else if openMovePct > 0 and gapPct < -behavThresh
                        behavior := "BOUNCE"
                        behavCol := color.rgb(0, 200, 255)
                    else if openMovePct < 0 and gapPct > behavThresh
                        behavior := "FADE"
                        behavCol := color.rgb(255, 150, 50)
                    else if openMovePct > 0
                        behavior := "TREND↑"
                        behavCol := color.lime
                    else
                        behavior := "TREND↓"
                        behavCol := color.rgb(255, 100, 100)

                table.cell(tbl, 0, r, shortName(syms.get(i)), text_color = tc, bgcolor = vBg, text_size = size.tiny)
                table.cell(tbl, 1, r, fmtPts(pts), text_color = pCol, bgcolor = vBg, text_size = size.tiny)
                table.cell(tbl, 2, r, "", bgcolor = vBg)
                if colVwapIdx >= 0
                    table.cell(tbl, colVwapIdx,   r, vArrow,   text_color = vCol,     bgcolor = vBg, text_size = size.tiny)
                if colPdVwapIdx >= 0
                    table.cell(tbl, colPdVwapIdx, r, pdvArrow, text_color = pdvCol,   bgcolor = vBg, text_size = size.tiny)
                if colBehavIdx >= 0
                    table.cell(tbl, colBehavIdx,  r, behavior, text_color = behavCol, bgcolor = vBg, text_size = size.tiny)
                r := r + 1


// ══════════════════════════════════════════════════════════════════════════════
// HOW TO READ
// ══════════════════════════════════════════════════════════════════════════════
//
// BOTH LINES ARE IN REAL DOW/YM POINTS:
//   Blue = +80 means "the top 7 stocks generated +80 Dow points today"
//   White = +120 means "YM actually moved +120 points"
//   Gap = +40 points came from the other 23 stocks
//
// SAME SCALE, DIRECTLY COMPARABLE:
//   Blue above white → top 7 are stronger than the index shows
//   White above blue (RED FILL) → index diverges from top-7 support
//
// DIVERGENCE LABELS (magnitude-aware — works bull & bear):
//   "Top-7 leads":  |Top-7| > |YM| + threshold  (top-7 driving the move)
//   "FALSE MOVE":   |YM| > |Top-7| + threshold  (other 23 stocks driving)
//   "DIVERGENT":    opposite signs (strongest warning)
//   "Aligned":      within threshold
//
// BEHAVIOR COLUMN (per-stock, session-story since open):
//   Uses TWO reference points:
//     • gapPct      = (dailyOpen - prevClose) / prevClose   → where session started
//     • openMovePct = (price - dailyOpen) / dailyOpen        → intraday direction
//
//   States:
//     TREND↑  (lime)   : up from open, gap not down  → trending up
//     TREND↓  (red)    : down from open, gap not up  → trending down
//     BOUNCE  (cyan)   : gap DOWN + now UP from open → reversal up (buying dip)
//     FADE    (orange) : gap UP + now DOWN from open → reversal down (selling rally)
//     FLAT    (gray)   : |move from open| < threshold
//
//   Trading application:
//     • TREND = continuation — heavy name confirming direction, follow it
//     • FADE on Top Pull = warning — heavy name opened strong but losing it → Top-7 support weakening
//     • BOUNCE on Top Drag = warning — heavy name recovering → Top-7 pressure easing
//     • Many FADEs while YM rises = FALSE MOVE incoming (reversal brewing)
//     • Many BOUNCEs while YM falls = capitulation low forming
//
// FORMULA (how Dow math works):
//   Each $1 stock price change = 1/divisor = ~6.16 Dow points
//   GS +$5 = +30.8 Dow points.  CAT −$3 = −18.5 Dow points.
//   Top-7 total = sum of all 7 stocks' point contributions.
//
// EXAMPLE:
//   GS   $910→$915  = +$5  = +30.8 pts
//   CAT  $740→$745  = +$5  = +30.8 pts
//   MSFT $415→$413  = −$2  = −12.3 pts
//   ... other 4 stocks = +20 pts combined
//   Top-7 total = +69.3 pts
//   YM actually = +45 pts
//   → Top 7 generated MORE than YM moved → other 23 are dragging −24 pts
//
// GAP:
//   Top-7 Gap = how many Dow points the top 7 gapped overnight
//   YM Gap = how many points YM gapped
//   If Top-7 Gap > YM Gap → heavy names opened strong, YM likely follows
//   If YM Gap > Top-7 Gap → index front-ran, potential fade
//
// DOW DIVISOR:
//   Current: 0.16242563904928 (since Oct 30, 2025)
//   Changes after stock splits or Dow composition changes.
//   Check: en.wikipedia.org/wiki/Dow_Jones_Industrial_Average
//
// COMPOSITION NOTES:
//   DJIA is PRICE-weighted (not cap-weighted like NQ-100).
//   Highest-priced stocks dominate regardless of company size.
//   NVDA is in Dow but has ~$150-200 price post-split (Nov 2024) → outside top 7.
//   The top 7 here are the HIGHEST-PRICED stocks, not the biggest companies.
//
// SMOOTHING CHOICE:
//   HMA (Hull MA): smooth with ~60% less lag than EMA. DEFAULT, recommended.
//   EMA: classic exponential, known behavior.
//   SMA: simple, most lag.
//   Off: raw values, noisiest but zero lag.
//   Table ALWAYS shows raw values regardless.
//
// ══════════════════════════════════════════════════════════════════════════════
````
