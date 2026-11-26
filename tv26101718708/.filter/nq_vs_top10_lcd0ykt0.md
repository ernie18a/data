# NQ vs Top10

- url: https://www.tradingview.com/script/lCd0YKt0/
- type: indicator
- pine_id: PUB;a3231805bd47402fa23c859ef6b85046
- version: 1.0

## Description

NQ Top-10 vs NQ (v4.3)
Co robi
Pokazuje ile rzeczywistego ruchu Nasdaq-100 futures pochodzi z 10 największych spółek (razem ~46% całego indeksu): NVDA, AAPL, MSFT, AMZN, TSLA, WMT, GOOGL, META, GOOG, AVGO. Wskaźnik rysuje dwie linie w osobnym panelu pod chartem NQ:

Niebieska — suma punktów NQ pochodzących z top-10 (cap-weighted × zwrot × poziom NQ)
Biała — faktyczny ruch NQ w punktach

Różnica (divergence) mówi czy NQ jest napędzany przez ciężkie akcje czy przez coś innego (reszta indeksu, futures spread, makro).
Jak interpretować sygnały
Linie blisko siebie → NQ porusza się zgodnie z top-10, normalny rynek
Niebieska wyraźnie nad białą → top-10 ciągnie mocniej niż NQ, reszta indeksu się nie łapie, wąski rally (podejrzany)
Niebieska wyraźnie pod białą → NQ rośnie mimo słabości top-10, broad-based rally, szeroka siła (mocny sygnał)
Divergence >30 pts → rozjazd, w tabeli pojawi się etykieta DIVERGENT/FALSE MOVE, kandydat pod fade
Tabela (prawy górny róg)
Wiersze (wszystkie opcjonalne w settings):

Top-10 / NQ — absolutne punkty
Divergence — różnica + etykieta magnitude-aware
Breadth — ilu z 10 jest up/down/neutral
VWAP Balance — % ważony akcji nad/pod swoim intraday VWAP
Gap rows — gap top-10 vs gap NQ (divergence otwarcia)
Top Pull / Top Drag — który symbol ciągnie najmocniej up/down (sign-guarded)

Per-symbol (dla każdej z 10 akcji):

pts — kontrybucja w punktach NQ
Wt% — aktualna waga w indeksie (live, price × shares)
VWAP ↑/↓ — kolor vs intraday VWAP (uwaga: niewiarygodne w pierwszych 15-30 min)
PD VW ↑/↓ — vs wczorajsze końcowe VWAP (stabilne od pierwszego ticka)
Behav — TREND↑/TREND↓/BOUNCE/FADE/FLAT (story sesji od otwarcia)

Użycie intraday
Poranne otwarcie (pierwsze 15-30 min):

Opieraj się na PD VWAP (stabilny institutional reference z wczoraj)
Ignoruj kolumnę VWAP (niewiarygodna, warm-up)
Gap rows → jeśli top-10 gap ≠ NQ gap → setup pod arbitraż

Środek dnia (po 10:00 ET):

VWAP ↑ + PD VWAP ↑ → siła potwierdzona na obu referencjach
VWAP ↓ + PD VWAP ↑ → gap up z distribution dziś, ale cena wciąż nad wczorajszym basisem
Divergence + Breadth → wąski/szeroki ruch

Pod close:

Linie powinny konwergować (EOD flow)
VWAP Balance > 50% → day bullish institutional
Top Pull / Top Drag → kogo kupowano/wyprzedawano

Limitations

Skład top-10 wpisany na sztywno w inputach — update kwartalnie ze slickcharts.com/nasdaq100
Wagi cap-weighted live (price × shares), ale shares outstanding fetched raz przy ładowaniu chartu — refresh F5 dla aktualnych
VWAP niewiarygodny w pierwszych 15-30 min sesji
Działa tylko na intraday timeframes (5m, 15m, itd.)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gnorek

//@version=6
indicator("Mój skrypt")
plot(close)
// ══════════════════════════════════════════════════════════════════════════════
// NQ TOP-10 vs NQ — Cap-Weighted False Move Detector  [v4]
// Pine Script v6
// ══════════════════════════════════════════════════════════════════════════════
//
// NQ-100 IS MARKET-CAP WEIGHTED (not price-weighted like the Dow).
// A company's impact = its market cap / total NQ cap.
// NVDA at ~$3T cap has ~3× the impact of COST at ~$400B.
//
// BOTH LINES IN REAL NQ POINTS:
//   BLUE  = estimated NQ points contributed by top 10 stocks
//   WHITE = actual NQ points moved
//
// The top 10 represent ~46% of NQ-100 total cap.
// Their contribution in NQ points =
//   NQ_ref × Σ(w_i_full × return_i)
// where w_i_full = cap_i / total_NQ_cap ≈ (cap_i / top10_cap) × 0.46
//
// ──────────────────────────────────────────────────────────────────────────────
// CHANGELOG v4 (vs v3):
//
// COMPOSITION (2026-04-20 reality check vs QQQ holdings):
//   • WMT added as #6 (joined NQ-100 on 2026-01-20, replacing AZN).
//   • COST removed from top 10 (now #11 at 2.53%).
//   • Re-ordered: TSLA #5, META #8, AVGO #10 (matches current weights).
//   • Labels updated to 2026-03-27 QQQ weight snapshot.
//   Note: labels are cosmetic — math uses live request.financial() for caps.
//
// ARCHITECTURAL (same fixes as DJIA v4):
//   • Table shows RAW values (not smoothed) — Σ per-symbol == Top-10 row.
//   • Top Pull/Drag sign-guarded — "—" when no valid pull/drag exists.
//   • fmtPts() helper — no more "+-3.5pt" formatting bug.
//   • Divergence labels handle BEAR scenarios (magnitude-based, DIVERGENT state).
//   • VWAP ↑/↓ shows "—" for na data (was false arrows).
//   • Breadth row added (upCount/downCount was computed but never displayed).
//   • NQ Gap split into own row (was packed into col 2 of Top-10 Gap).
//   • Per-symbol shows "—" for na data (was misleading "+0.0").
//
// VISUAL & SPEED:
//   • Smoothing selector: Off / EMA / HMA / SMA (default HMA — smooth + less lag).
//   • Line width configurable (default 3, was 2).
//   • Reference hlines at ±refLevel1/±refLevel2/±refLevel3 — stretches Y-axis.
//   • explicit_plot_zorder for clean layer order (hlines behind lines).
//
// NEW IN v4.3 — PD VWAP + configurable table + static weights:
//   • Added PD VWAP column (↑/↓ vs previous day's closing VWAP).
//     PD VWAP = ta.vwap(hlc3)[1] on daily timeframe = yesterday's
//     final VWAP = institutional closing reference.
//     STABLE from first tick of session — complements intraday VWAP
//     which needs 15-30 min warm-up.
//   • Table now configurable: toggle Divergence / Breadth / VWAP Bal /
//     Gaps / Pull-Drag rows. Toggle VWAP / PD VWAP / Behav columns.
//   • Removed "VWAP session mode" toggle — PD VWAP solves the early-
//     session problem better than forcing RTH on intraday VWAP.
//   • Cap weights now from static user inputs (per-symbol Weight %)
//     instead of live request.financial(). Removes 10 calls, brings
//     budget to 21 unique calls under Pine's 40-limit on non-Pro plans.
//     Update weights quarterly from QQQ holdings.
//   • Request budget:
//       1 NQ daily + 10 × (close+vwap | daily[open,pClose,pdVwap])
//       = 21 unique calls per bar.
//
// NEW IN v4.1:
//   • 4th table column: per-stock BEHAVIOR classifier.
//     TREND↑ / TREND↓ / BOUNCE / FADE / FLAT — tells you if a heavy name
//     is continuing its direction or reversing intraday.
//     Uses (session open, prev close) as reference points.
//     Configurable threshold (default 0.2%).
//
// TICK DATA INTRABAR:
//   • request.security(sym, timeframe.period, close) updates on EVERY tick of
//     that symbol in realtime. This is Pine v6 DEFAULT for indicators.
//   • Historical bars show confirmed values; realtime bar shows live tick price.
//   • NO flag needed — tick-level intrabar is the default behavior for indicators.
//     (calc_on_every_tick is a strategy() param, irrelevant for indicators.)
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
//indicator("NQ Top-10 vs NQ (pts) v4.3",
//    overlay              = false,
//     max_bars_back        = 500,
//     explicit_plot_zorder = true)

// ─── Inputs: Top 10 NQ components (snapshot 2026-03-27) ────────────────────
// Each symbol has its own weight input — previously fetched via
// request.financial() but that counted toward Pine's 40-call limit.
// Weights stable over days; update quarterly from QQQ holdings data.
// Verify at stockanalysis.com/etf/qqq/holdings/ or slickcharts.
string sym1  = input.symbol("NASDAQ:NVDA",  title = "1. Symbol",  group = "NQ Top 10 — NVDA (1)")
float  wgt1  = input.float(8.55, title = "1. Weight %",           group = "NQ Top 10 — NVDA (1)", minval=0.01, step=0.01)
string sym2  = input.symbol("NASDAQ:AAPL",  title = "2. Symbol",  group = "NQ Top 10 — AAPL (2)")
float  wgt2  = input.float(7.67, title = "2. Weight %",           group = "NQ Top 10 — AAPL (2)", minval=0.01, step=0.01)
string sym3  = input.symbol("NASDAQ:MSFT",  title = "3. Symbol",  group = "NQ Top 10 — MSFT (3)")
float  wgt3  = input.float(5.56, title = "3. Weight %",           group = "NQ Top 10 — MSFT (3)", minval=0.01, step=0.01)
string sym4  = input.symbol("NASDAQ:AMZN",  title = "4. Symbol",  group = "NQ Top 10 — AMZN (4)")
float  wgt4  = input.float(4.49, title = "4. Weight %",           group = "NQ Top 10 — AMZN (4)", minval=0.01, step=0.01)
string sym5  = input.symbol("NASDAQ:TSLA",  title = "5. Symbol",  group = "NQ Top 10 — TSLA (5)")
float  wgt5  = input.float(3.79, title = "5. Weight %",           group = "NQ Top 10 — TSLA (5)", minval=0.01, step=0.01)
string sym6  = input.symbol("NASDAQ:WMT",   title = "6. Symbol",  group = "NQ Top 10 — WMT (6)")
float  wgt6  = input.float(3.48, title = "6. Weight %",           group = "NQ Top 10 — WMT (6)", minval=0.01, step=0.01)
string sym7  = input.symbol("NASDAQ:GOOGL", title = "7. Symbol",  group = "NQ Top 10 — GOOGL (7)")
float  wgt7  = input.float(3.35, title = "7. Weight %",           group = "NQ Top 10 — GOOGL (7)", minval=0.01, step=0.01)
string sym8  = input.symbol("NASDAQ:META",  title = "8. Symbol",  group = "NQ Top 10 — META (8)")
float  wgt8  = input.float(3.26, title = "8. Weight %",           group = "NQ Top 10 — META (8)", minval=0.01, step=0.01)
string sym9  = input.symbol("NASDAQ:GOOG",  title = "9. Symbol",  group = "NQ Top 10 — GOOG (9)")
float  wgt9  = input.float(3.13, title = "9. Weight %",           group = "NQ Top 10 — GOOG (9)", minval=0.01, step=0.01)
string sym10 = input.symbol("NASDAQ:AVGO",  title = "10. Symbol", group = "NQ Top 10 — AVGO (10)")
float  wgt10 = input.float(2.99, title = "10. Weight %",          group = "NQ Top 10 — AVGO (10)", minval=0.01, step=0.01)

// Top-10 share of full NQ-100 cap (cosmetic display only in table title)
float top10Share = input.float(0.46, title = "Top-10 share of NQ (display only)",
     minval = 0.1, maxval = 0.9, step = 0.01,
     tooltip = "Cosmetic label shown in table header.\nWeight math now uses per-symbol Weight % inputs above.\n2026-03-27 approximate: ~0.46 (46%). Update quarterly.",
     group   = "NQ")

string modeInput = input.string("From Previous Close", title = "Reference",
     options  = ["From Session Open", "From Previous Close"],
     tooltip  = "From Previous Close: includes overnight gap (recommended).\nFrom Session Open: starts at 0.",
     group    = "Display")

// ─── Smoothing (plots only — table always shows RAW) ────────────────────────
string smoothType = input.string("HMA", title = "Smoothing type",
     options = ["Off", "HMA", "EMA", "SMA"],
     tooltip = "HMA = Hull MA, smooth with less lag than EMA (recommended).\nOff = no smoothing, tick-by-tick raw values.\nTable always shows RAW regardless of this setting.",
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
     minval = 0.1, maxval = 100.0, step = 0.5,
     tooltip = "Absolute gap below which Top-10 and NQ are considered Aligned.",
     group   = "Display")

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

var array<string> syms = array.from(sym1, sym2, sym3, sym4, sym5, sym6, sym7, sym8, sym9, sym10)
var array<float>  inpWeights = array.from(wgt1, wgt2, wgt3, wgt4, wgt5, wgt6, wgt7, wgt8, wgt9, wgt10)
int N = 10


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

// ─── NQ (chart symbol) data ────────────────────────────────────────────────
// request.security on daily timeframe with lookahead — values stable at session open
[nqDailyOpen, nqPrevClose] = request.security(syminfo.tickerid, "D", [open, close[1]],
     lookahead = barmerge.lookahead_on)

float nqRef = modeInput == "From Session Open" ? nqDailyOpen : nqPrevClose
float nqPoints = not na(nqRef) ? close - nqRef : 0.0
float nqGapPts = not na(nqDailyOpen) and not na(nqPrevClose)
     ? nqDailyOpen - nqPrevClose : 0.0


// ─── Fetch top-10 stock data (minimal-calls approach) ──────────────────────
// Budget: 10 × 1 + 1 = 11 unique calls. Far under Pine's 40 limit.
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
//
// This avoids extra request.security("D", ...) calls — everything comes
// from one chart-TF request per symbol.
//
// Cap weights come from user input (static snapshot, update quarterly).
// Weights stable within a quarter so static inputs are fine.

// Helper: compute session-start / session-end anchored fields.
// Runs INSIDE request.security context for each symbol.
symDataExpr() =>
    bool newSession = ta.change(time("D")) != 0
    // Today's session open: locked at first bar of session
    var float dOpenCur = na
    if newSession
        dOpenCur := open
    // Previous day's close: value of close just before session change
    var float pCloseCur = na
    if newSession
        pCloseCur := close[1]
    // VWAP for today
    float vwapNow = ta.vwap(hlc3)
    // Previous day's final VWAP: snapshot on last bar of prev session
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


// ─── Compute cap-weights from user inputs ──────────────────────────────────
// ARCH: weights are static user inputs, updated quarterly by user from
// QQQ holdings data. Previously computed dynamically via request.financial()
// but that pushed request count over Pine's 40-limit.
//
// capWeights sum to 1 (normalized among top 10).
// fullWeights reflect share of FULL NQ-100 cap (approximately top10Share × capWeight).
array<float> capWeights  = array.new<float>(N, 0.0)
array<float> fullWeights = array.new<float>(N, 0.0)
float wSum = 0.0
int   activeN = 0

for i = 0 to N - 1
    float base = modeInput == "From Session Open" ? dOpens.get(i) : pCloses.get(i)
    float w    = inpWeights.get(i)
    if not na(base) and base > 0 and w > 0
        wSum := wSum + w
        activeN := activeN + 1

if wSum > 0
    for i = 0 to N - 1
        float base = modeInput == "From Session Open" ? dOpens.get(i) : pCloses.get(i)
        float w    = inpWeights.get(i)
        if not na(base) and base > 0 and w > 0
            float wTop10 = w / wSum
            capWeights.set(i, wTop10)
            // fullWeight is the absolute weight in NQ-100 (not renormalized)
            // User inputs are already in % of NQ-100, so fullWeight = w / 100
            fullWeights.set(i, w / 100.0)


// ─── Compute contributions in NQ POINTS ────────────────────────────────────
// pts_i = fullWeight_i × return_i × NQ_ref_level
float top10Points  = 0.0
float top10GapPts  = 0.0
int   upCount      = 0
int   downCount    = 0

float vwapWtAbove = 0.0
float vwapWtBelow = 0.0
int   vwapAboveN  = 0
int   vwapBelowN  = 0

// Per-symbol: init na so missing symbols render "—" instead of "+0.0"
array<float> symPts    = array.new<float>(N, na)
array<float> symGapPts = array.new<float>(N, na)
array<float> symRets   = array.new<float>(N, na)

for i = 0 to N - 1
    float p   = prices.get(i)
    float dO  = dOpens.get(i)
    float pC  = pCloses.get(i)
    float v   = vwaps.get(i)
    float wF  = fullWeights.get(i)
    float wT  = capWeights.get(i)
    float ref = modeInput == "From Session Open" ? dO : pC

    if not na(p) and not na(ref) and ref > 0 and wF > 0 and not na(nqRef) and nqRef > 0
        float ret = (p - ref) / ref
        symRets.set(i, ret)

        float pts = wF * ret * nqRef
        symPts.set(i, pts)
        top10Points := top10Points + pts

        if ret > 0.0001
            upCount := upCount + 1
        else if ret < -0.0001
            downCount := downCount + 1

        if not na(v) and wT > 0
            if p > v
                vwapWtAbove := vwapWtAbove + wT
                vwapAboveN  := vwapAboveN + 1
            else if p < v
                vwapWtBelow := vwapWtBelow + wT
                vwapBelowN  := vwapBelowN + 1

    // Gap in NQ points
    if not na(dO) and not na(pC) and pC > 0 and wF > 0 and not na(nqRef) and nqRef > 0
        float gapRet = (dO - pC) / pC
        float gPts = wF * gapRet * nqRef
        symGapPts.set(i, gPts)
        top10GapPts := top10GapPts + gPts


// ─── Derived values ─────────────────────────────────────────────────────────
float divergencePts = top10Points - nqPoints
float gapDivPts     = top10GapPts - nqGapPts
float vwapBalance   = (vwapWtAbove - vwapWtBelow) * 100.0

// Magnitude-based divergence classification (works bull & bear)
float absT10   = math.abs(top10Points)
float absNQ    = math.abs(nqPoints)
float magGap   = absT10 - absNQ
bool  opposite = top10Points * nqPoints < 0


// ─── Smoothing (plots only — table uses raw) ────────────────────────────────
float smoothTop10 = smooth(top10Points, smoothLen, smoothType)
float smoothNQ    = smooth(nqPoints,    smoothLen, smoothType)


// ─── Plots ──────────────────────────────────────────────────────────────────
bool inSession = str.length(sessionFlt) == 0 or not na(time(timeframe.period, sessionFlt, sessionTZ))
bool canPlot   = inSession and activeN >= 3

// Reference levels — stretch Y-axis to force visible range.
// Toggle via color transparency (hline price must be input-const, not series).
// Plotted first so they render behind main lines (explicit_plot_zorder).
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

// BLUE: top-10 contribution in NQ points
float pTop10 = canPlot ? smoothTop10 : na
p_t10 = plot(pTop10, title = "Top-10 (pts)",
     color = color.rgb(33, 150, 243), linewidth = lineWidth)

// WHITE: actual NQ points change
float pNQ = canPlot ? smoothNQ : na
p_nq = plot(pNQ, title = "NQ Actual (pts)",
     color = color.new(color.white, 20), linewidth = math.max(1, lineWidth - 1))

// Fill: blue when top-10 leads (by signed diff), red otherwise.
// Note: table labels use magnitude-aware logic for bear-correct interpretation.
fill(p_t10, p_nq,
     color = smoothTop10 >= smoothNQ
         ? color.new(color.rgb(33, 150, 243), 85)
         : color.new(color.rgb(255, 82, 82), 85),
     title = "Divergence")

bool bullBg = canPlot and smoothTop10 > 0 and vwapBalance > 0
bool bearBg = canPlot and smoothTop10 < 0 and vwapBalance < 0
bgcolor(bullBg ? color.new(color.green, 93) : bearBg ? color.new(color.red, 93) : na)


// ─── Find top contributor / detractor ───────────────────────────────────────
int topPosIdx = -1
float topPosVal = -999999.0
int topNegIdx = -1
float topNegVal = 999999.0

for i = 0 to N - 1
    float pts = symPts.get(i)
    if not na(pts) and fullWeights.get(i) > 0
        if pts > topPosVal
            topPosVal := pts
            topPosIdx := i
        if pts < topNegVal
            topNegVal := pts
            topNegIdx := i


// ─── Table ──────────────────────────────────────────────────────────────────
// Dynamic column layout (max 6 cols × 24 rows):
//   Col 0 = Symbol / Row label
//   Col 1 = Primary value (pts / balance / etc)
//   Col 2 = Secondary info (weight % / label / etc)
//   Col 3..5 = VWAP ↑/↓, PD VWAP ↑/↓, Behav — toggled by user inputs
// Row visibility toggled by showRow* inputs. Empty slots get transparent bg.

// Compute actual column indices based on toggles
int colVwapIdx   = colVwap   ? 3 : -1
int colPdVwapIdx = colPdVwap ? (colVwap ? 4 : 3) : -1
int colBehavIdx  = colBehav  ? (3 + (colVwap ? 1 : 0) + (colPdVwap ? 1 : 0)) : -1
int lastCol = 2 + (colVwap ? 1 : 0) + (colPdVwap ? 1 : 0) + (colBehav ? 1 : 0)

var table tbl = table.new(position.top_right, 6, 24,
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
    table.cell(tbl, 0, r, "NQ TOP-10 vs NQ", text_color = tc,
         bgcolor = color.new(color.purple, 50), text_size = size.small)
    table.cell(tbl, 1, r, "~" + str.tostring(wSum, "#.#") + "% of NQ",
         text_color = tc, bgcolor = color.new(color.purple, 50), text_size = size.small)
    table.cell(tbl, 2, r, "Cap-Weighted", text_color = tc,
         bgcolor = color.new(color.purple, 50), text_size = size.tiny)
    fillExtras(r, 3, color.new(color.purple, 50))
    r := r + 1

    // ── Top-10 (RAW — matches Σ per-symbol rows) ──
    color t10Col = top10Points > 0 ? color.lime : top10Points < 0 ? color.rgb(255, 100, 100) : tc
    table.cell(tbl, 0, r, "Top-10", text_color = tc, bgcolor = hBg, text_size = size.normal)
    table.cell(tbl, 1, r, fmtPts(top10Points) + " pts",
         text_color = t10Col, bgcolor = vBg, text_size = size.normal)
    table.cell(tbl, 2, r, "", bgcolor = vBg)
    fillExtras(r, 3, vBg)
    r := r + 1

    // ── NQ (RAW) ──
    color nqCol = nqPoints > 0 ? color.lime : nqPoints < 0 ? color.rgb(255, 100, 100) : tc
    table.cell(tbl, 0, r, "NQ", text_color = tc, bgcolor = hBg, text_size = size.normal)
    table.cell(tbl, 1, r, fmtPts(nqPoints) + " pts",
         text_color = nqCol, bgcolor = vBg, text_size = size.normal)
    table.cell(tbl, 2, r, "", bgcolor = vBg)
    fillExtras(r, 3, vBg)
    r := r + 1

    // ── Divergence ──
    if showRowDiv
        string divLabel = opposite ? "DIVERGENT"
             : magGap >  divThresh ? "Top-10 leads"
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

    // ── Gap section (3 rows: Top-10 Gap, NQ Gap, Gap Div) ──
    if showRowGaps
        color gapHdr = color.new(color.yellow, 80)

        color t10gCol = top10GapPts > 0 ? color.lime : top10GapPts < 0 ? color.rgb(255, 100, 100) : tc
        table.cell(tbl, 0, r, "Top-10 Gap", text_color = tc, bgcolor = gapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(top10GapPts) + " pts",
             text_color = t10gCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

        color nqgCol = nqGapPts > 0 ? color.lime : nqGapPts < 0 ? color.rgb(255, 100, 100) : tc
        table.cell(tbl, 0, r, "NQ Gap", text_color = tc, bgcolor = gapHdr, text_size = size.small)
        table.cell(tbl, 1, r, fmtPts(nqGapPts) + " pts",
             text_color = nqgCol, bgcolor = vBg, text_size = size.small)
        table.cell(tbl, 2, r, "", bgcolor = vBg)
        fillExtras(r, 3, vBg)
        r := r + 1

        float magGapG   = math.abs(top10GapPts) - math.abs(nqGapPts)
        bool  oppositeG = top10GapPts * nqGapPts < 0
        string gdLabel  = oppositeG ? "DIVERGENT"
             : magGapG >  divThresh ? "Top-10 gapped more"
             : magGapG < -divThresh ? "NQ gapped more"
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
        float topPosWt = hasPull ? fullWeights.get(topPosIdx) * 100 : 0
        table.cell(tbl, 2, r, hasPull ? str.tostring(topPosWt, "#.0") + "% NQ" : "",
             text_color = tc, bgcolor = vBg, text_size = size.tiny)
        fillExtras(r, 3, vBg)
        r := r + 1

        table.cell(tbl, 0, r, "Top Drag", text_color = tc, bgcolor = hBg, text_size = size.small)
        table.cell(tbl, 1, r, hasDrag
             ? shortName(syms.get(topNegIdx)) + " " + fmtPts(topNegVal) + "pt"
             : "—",
             text_color = hasDrag ? color.rgb(255, 100, 100) : tc, bgcolor = vBg, text_size = size.small)
        float topNegWt = hasDrag ? fullWeights.get(topNegIdx) * 100 : 0
        table.cell(tbl, 2, r, hasDrag ? str.tostring(topNegWt, "#.0") + "% NQ" : "",
             text_color = tc, bgcolor = vBg, text_size = size.tiny)
        fillExtras(r, 3, vBg)
        r := r + 1

    // ── Per-symbol breakdown ──
    if showSymbols
        color sHdr = color.new(color.gray, 65)
        table.cell(tbl, 0, r, "Symbol", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        table.cell(tbl, 1, r, "NQ pts", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        table.cell(tbl, 2, r, "Wt %",   text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        if colVwapIdx >= 0
            table.cell(tbl, colVwapIdx,   r, "VWAP",  text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        if colPdVwapIdx >= 0
            table.cell(tbl, colPdVwapIdx, r, "PD VW", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        if colBehavIdx >= 0
            table.cell(tbl, colBehavIdx,  r, "Behav", text_color = tc, bgcolor = sHdr, text_size = size.tiny)
        r := r + 1

        for i = 0 to N - 1
            if r < 23
                float pts = symPts.get(i)
                float wPct = fullWeights.get(i) * 100
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
                table.cell(tbl, 2, r, wPct > 0 ? str.tostring(wPct, "#.0") + "%" : "—",
                     text_color = tc, bgcolor = vBg, text_size = size.tiny)
                if colVwapIdx >= 0
                    table.cell(tbl, colVwapIdx,   r, vArrow,   text_color = vCol,     bgcolor = vBg, text_size = size.tiny)
                if colPdVwapIdx >= 0
                    table.cell(tbl, colPdVwapIdx, r, pdvArrow, text_color = pdvCol,   bgcolor = vBg, text_size = size.tiny)
                if colBehavIdx >= 0
                    table.cell(tbl, colBehavIdx,  r, behavior, text_color = behavCol, bgcolor = vBg, text_size = size.tiny)
                r := r + 1

    // Warnings
    string warn = ""
    if activeN < 3
        warn := warn + "Need 3+ symbols. "
    if str.length(warn) > 0 and r < 24
        table.cell(tbl, 0, r, "⚠", text_color = color.yellow,
             bgcolor = color.new(color.orange, 70), text_size = size.small)
        table.cell(tbl, 1, r, warn, text_color = color.yellow,
             bgcolor = color.new(color.orange, 85), text_size = size.tiny)
        table.cell(tbl, 2, r, "", bgcolor = color.new(color.orange, 85))
        fillExtras(r, 3, color.new(color.orange, 85))


// ══════════════════════════════════════════════════════════════════════════════
// KEY DIFFERENCES FROM DJIA VERSION
// ══════════════════════════════════════════════════════════════════════════════
//
// DJIA = PRICE-weighted:  weight = stockPrice / Σ(prices)
//   → $600 stock has 2× impact of $300 stock regardless of company size
//   → Divisor converts $1 → fixed Dow points
//
// NQ-100 = MARKET-CAP-weighted:  weight = marketCap / totalCap
//   → $3T company (NVDA) has ~9% weight, $400B company (COST) has ~2.5%
//   → No simple divisor. Contribution = weight × return × NQ_level.
//   → Uses request.financial() for shares outstanding to compute caps
//
// BOTH indicators show the same thing:
//   "How much of the index move is driven by the heaviest names?"
//
// ══════════════════════════════════════════════════════════════════════════════
// HOW TO READ
// ══════════════════════════════════════════════════════════════════════════════
//
// EXAMPLE:
//   NVDA ($130, ~8.5% of NQ) rises +2%
//   NQ is at 25,000
//   NVDA contribution = 0.085 × 0.02 × 25,000 = +42.5 NQ points
//
//   If all top 10 combined = +80 pts but NQ moved +120 pts:
//   → Other 90 stocks contributed +40 pts → broad-based move
//
//   If top 10 = +80 pts but NQ moved +30 pts:
//   → Other 90 stocks DRAGGED by −50 pts
//   → Heavy names strong, rest of market weak
//   → Blue above white = top 10 leading
//
//   If top 10 = +20 pts but NQ moved +100 pts:
//   → Other 90 stocks contributed +80 pts
//   → FALSE MOVE — NQ rose without mega-cap support
//   → White above blue (RED FILL) = weakest type of NQ rally
//
// DIVERGENCE LABELS (magnitude-aware):
//   "Top-10 leads":  |Top-10| > |NQ| + threshold
//   "FALSE MOVE":    |NQ| > |Top-10| + threshold
//   "DIVERGENT":     opposite signs (strongest warning)
//   "Aligned":       within threshold
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
//     • FADE on Top Pull = warning — heavy name opened strong but losing it → Top-10 support weakening
//     • BOUNCE on Top Drag = warning — heavy name recovering → Top-10 pressure easing
//     • Many FADEs while NQ rises = FALSE MOVE incoming (reversal brewing)
//     • Many BOUNCEs while NQ falls = capitulation low forming
//
//   Example (from 2026-04-20 screen):
//     AAPL +17.4 pts (green), but Behav = FADE (orange)
//     → AAPL opened with strong gap up but has been sold intraday below session open
//     → Still green on day, but momentum turning bearish
//     → If AAPL breaks prev close going down, Top-10 loses its only pillar
//
// TICK-LEVEL UPDATES:
//   request.security() on chart timeframe updates every tick in realtime.
//   No flag needed — it's Pine v6 default for indicators.
//   Historical bars: confirmed values. Realtime bar: live tick value.
//
// COMPOSITION MAINTENANCE:
//   Check quarterly at: stockanalysis.com/etf/qqq/holdings/
//   Nasdaq-100 annual reconstitution: December (effective 3rd Friday).
//   Quarterly rebalancing: March, June, September, December.
//   Ad-hoc changes (like WMT/AZN swap Jan 2026) can happen anytime.
//
// TWO VWAP REFERENCES PER STOCK:
//   VWAP (intraday, today's session):
//     • Cumulative volume-weighted average from today's session start.
//     • Starts from first bar of chart session — UNRELIABLE in first
//       15-30 min (low cumulative volume = noisy).
//     • After warm-up: standard institutional intraday benchmark.
//
//   PD VWAP (previous day's closing VWAP):
//     • Yesterday's final VWAP from RTH session (9:30-16:00 ET).
//     • Fetched from RTH-forced ticker — reflects where yesterday's
//       institutional flow settled, regardless of chart session.
//     • STABLE from first tick of today's session.
//     • Use as PRIMARY reference in first 15-30 min.
//     • Professional traders treat this as "yesterday's institutional
//       cost basis" — level where big money finished their books.
//
// HOW TO READ STOCK ROW WITH BOTH COLUMNS:
//   VWAP ↑ + PD VWAP ↑ → bullish on both timeframes. Strong.
//   VWAP ↓ + PD VWAP ↑ → today weakness but above yesterday's basis.
//                        Gap-up + distribution, but gap may hold.
//   VWAP ↑ + PD VWAP ↓ → today strength but below yesterday's basis.
//                        Bounce off oversold, may fade at PD VWAP.
//   VWAP ↓ + PD VWAP ↓ → bearish on both. Weakness confirmed.
//
// TABLE CONFIGURABILITY (v4.3):
//   All row toggles under "Table rows" group — hide what you don't need.
//   All per-symbol column toggles under "Symbol columns" group.
//   Table auto-resizes to show only enabled columns without blank space.
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
