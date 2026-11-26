# PulseRank NomadaScalper

- url: https://www.tradingview.com/script/y6N1bzde-PulseRank-NomadaScalper/
- type: indicator
- pine_id: PUB;2027cdf1e8c845b78caa8f8e24cc22a8
- version: 1.0

## Description

PulseRank NomadaScalper

PulseRank is a market leadership dashboard that compares seven stocks using momentum, volatility and trend positioning. Its purpose is to help traders distinguish broad participation from strength concentrated in a few names.

The default basket contains NVIDIA, Microsoft, Apple, Amazon, Meta, Alphabet and Tesla. QQQ provides benchmark context, while VIX adds a separate view of volatility conditions. The basket symbols, benchmark and volatility source are configurable.

Each stock is evaluated using three components:

• Recent price movement, measured relative to its own Average True Range.
• Price positioning relative to session VWAP.
• Price positioning relative to its 200-period EMA.

These components are normalized and combined into a bounded score. This allows stocks with different prices and volatility profiles to be compared within the same framework. Daily percentage change is displayed separately and does not determine the ranking.

Scores range from −3 to +3. Values above +0.30 are classified as bullish, values below −0.30 as bearish, and readings between those thresholds as neutral. These classifications describe the model’s current reading. They are not probabilities or measures of trade accuracy.

The dashboard brings together:

• A ranked list of the selected stocks.
• The aggregate basket score and directional state.
• Bullish, neutral and bearish basket composition.
• Participation above the previous close, VWAP and EMA.
• Relative volume and individual price performance.
• Benchmark comparison and volatility context.
• Source timestamps, data coverage and the active weighting method.

Directional breadth counts how many eligible stocks fall into each category. Basket composition uses their assigned weights. These readings can differ because a small number of heavily weighted stocks can influence the aggregate score more than the remaining members.

The default Auto cap mode estimates weights using price and reported quarterly shares outstanding. It uses those estimates only when every eligible member has valid information in the same currency. Otherwise, the entire eligible basket switches to equal weighting. Equal weighting can also be selected manually. These estimates are not official Nasdaq or QQQ index weights.

Performance lines appear in a separate pane and show each instrument’s percentage change from its own previous daily close. Compact labels identify the individual series. The dashboard offers multiple sizes and positions, with an optional research view for additional detail.

An optional SMA cloud appears on the main price chart. Unlike the stock basket calculations, this cloud uses the chart instrument itself.

Optional BUY and SELL markers identify transitions in which the volatility index’s daily percentage change moves below or above all seven basket members. A chart trend filter can require price to be above or below both cloud averages. Optional pullback dots identify cloud reclaims or rejections while the volatility condition remains at a configured extreme.

Signal events require a confirmed chart close, complete basket coverage and matching source closing times. Comparing VIX percentage changes with stock percentage changes is a heuristic; it does not imply that their movements have equivalent statistical meaning.

For interpretation, start with the basket state, then check participation and individual rankings. A positive basket with limited bullish participation describes a different condition from one supported by most members. Benchmark comparison helps identify whether the basket’s normalized score is leading or lagging QQQ. The highest-ranked stock can still have a negative score when the entire basket is weak.

The source timeframe defaults to five minutes and is independent of the chart timeframe. Developing source readings can change before their bars close. Higher chart timeframes sample available source observations and do not reconstruct every intermediate crossing, so signal histories may differ across chart timeframes.

The default configuration is designed around US equity market context. Displaying it on another asset does not change the underlying basket or establish predictive validity for that asset. Signal markers require standard intraday charts.

Missing or stale data are identified rather than counted as directional agreement. Outside regular trading hours, a retained reading represents the last available snapshot. Data availability and delays depend on the selected feeds and subscriptions.

PulseRank combines normalized leadership ranking, weighted composition, participation and source validation in one workflow. It is an analytical indicator, not an automated trading strategy. Its scores and markers do not establish a win rate or guarantee future performance.

## Source Code

````pine
//@version=6
indicator("PulseRank NomadaScalper", "PulseRank · NS", overlay = false, max_labels_count = 220, max_lines_count = 80, max_boxes_count = 80, max_bars_back = 1000)
// PulseRank · NomadaScalper · v3.4.0 · Leadership Terminal
// Based on the owner's v2.4.0 engine / Pleiades V3 source.
// SCORE PRESERVED: 0.50 impulse + 0.30 VWAP posture + 0.20 EMA200 posture;
// each input in its own ATR14, each clipped to [-3,+3]. Not a probability.
// AUDIT CHANGES: explicit source sessions, timestamp validity, per-metric
// breadth denominators, uniform cap/equal weighting, confirmed basket alerts,
// prior-completed-bar volume baseline, separated sign/intensity, retained feeds.
// Cap estimates use reported FQ shares, not official QQQ index weights.
// Financial dates and adjusted histories are NOT a point-in-time backtest.
// Live dashboard is provisional; source TF > chart TF can change after reload.
// Basket alerts use completed source snapshots on confirmed standard chart bars.
// On coarser charts, only the last source observation per chart bar is sampled.
// v3.4.0 removes BUY/SELL crosses, pullback dots and their inputs/alerts.
// Adds chart-close WMA 200 and WMA 365 overlays, independent of the ranking.
// Source metrics, basket weighting, dashboard layout and SMA cloud are retained.
// v3.4.0 adds Nasdaq zones from the owner's 250NQ v3.2 reference.
// Fixed 250-point grid / 500-point majors. Exact-price levels remain visible.
// Latest-price grid, not a historical reaction detector or measured liquidity.
// 25 unique requests; 108 tuple elements. Maximum objects including both panes:
// 90 labels / 39 lines / 63 boxes. One dashboard; no entry signals.

string G_SYM = "1 - SYMBOLS"
string G_CAL = "2 - CALCULATION"
string G_PAN = "3 - PANEL"

string inS0 = input.symbol("NASDAQ:NVDA",  "Symbol 1", group = G_SYM)
string inS1 = input.symbol("NASDAQ:MSFT",  "Symbol 2", group = G_SYM)
string inS2 = input.symbol("NASDAQ:AAPL",  "Symbol 3", group = G_SYM)
string inS3 = input.symbol("NASDAQ:AMZN",  "Symbol 4", group = G_SYM)
string inS4 = input.symbol("NASDAQ:META",  "Symbol 5", group = G_SYM)
string inS5 = input.symbol("NASDAQ:GOOGL", "Symbol 6", group = G_SYM)
string inS6 = input.symbol("NASDAQ:TSLA",  "Symbol 7", group = G_SYM)
string inBm = input.symbol("NASDAQ:QQQ",   "Benchmark", group = G_SYM)
string inVx = input.symbol("CBOE:VIX",     "Volatility index", group = G_SYM)

string inCalcTf = input.timeframe("5", "Source timeframe", group = G_CAL, tooltip = "Fixed timeframe in each source symbol. Live readings can change until the source bar closes. Higher chart timeframes sample the latest available source bar; intermediate crossings are not reconstructed.")
int    inImpBars = input.int(6, "Impulse window (calc bars)", minval = 1, maxval = 200, group = G_CAL, tooltip = "The moment's impulse = move over this many calc bars, in the symbol's own ATR14. Default 6 x 5m = 30 trading minutes; the window can span an overnight gap.")
int    inSlope   = input.int(5, "E200 slope lookback (calc bars)", minval = 1, maxval = 200, group = G_CAL, tooltip = "Bars used to read whether each symbol's EMA200 is rising or falling (the arrows in the E200 column).")

string inPanPos  = input.string("Bottom Left", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group = G_PAN)
string inPanSize = input.string("Small", "Size", options = ["Micro", "Small", "Normal", "Large"], group = G_PAN)

string G_LIN = "4 - PERFORMANCE LINES"
string G_TRD = "5 - SMA CLOUD"
string G_WMA = "6 - CHART WMA"
bool   inShowLines = input.bool(true, "Show performance lines", group = G_LIN, tooltip = "Each symbol's day % vs ITS OWN previous daily close - from explicit regular-session source feeds.")
bool   inShowVix   = input.bool(true, "Show VIX line", group = G_LIN)
bool   inShowBench = input.bool(true, "Show benchmark line", group = G_LIN)
int    inLw        = input.int(2, "Line width", minval = 1, maxval = 4, group = G_LIN)
bool   inGlow      = input.bool(true, "Soft line halo", group = G_LIN)
bool   inEdgeLbl   = input.bool(true, "Right-edge labels", group = G_LIN)
bool   inRthOnly   = input.bool(true, "Only during regular hours", group = G_LIN, tooltip = "Hide the lines outside 09:30-16:00 New York. Display only - the data itself never depends on the chart.")
string inRthSess   = input.session("0930-1600", "Regular hours (NY)", group = G_LIN)

bool   inShowCld  = input.bool(true, "Show SMA cloud on price", group = G_TRD)
int    inSmaF     = input.int(30, "SMA fast", minval = 2, maxval = 500, group = G_TRD)
int    inSmaS     = input.int(50, "SMA slow", minval = 3, maxval = 500, group = G_TRD)

bool  inShowWma200 = input.bool(true, "Show WMA 200", group = G_WMA, inline = "w200", tooltip = "Weighted moving average of the last 200 chart closes. Uses the chart symbol, timeframe and candle type. Visual context only; it does not alter the basket ranking.")
color inWma200Color = input.color(#C9A85A, "Color", group = G_WMA, inline = "w200")
bool  inShowWma365 = input.bool(true, "Show WMA 365", group = G_WMA, inline = "w365", tooltip = "Weighted moving average of the last 365 chart closes. Uses the chart symbol, timeframe and candle type. Visual context only; it does not alter the basket ranking.")
color inWma365Color = input.color(#8ECAE6, "Color", group = G_WMA, inline = "w365")

string inWeights = input.string("Auto cap", "Basket weighting", options = ["Auto cap", "Equal"], group = G_CAL, tooltip = "Auto cap uses reported quarterly shares x price only when every eligible member has a positive estimate in the same currency. Otherwise the whole eligible basket switches to equal weights. Never mixes caps with arbitrary slot weights. Financial history is not a point-in-time backtest dataset.")
bool inShowPanel = input.bool(true, "Show dashboard", group = G_PAN)
bool inResearch = input.bool(false, "Research detail", group = G_PAN, tooltip = "Adds gap / intraday performance, weight and source status to every row. Compact view retains the key columns.")

// Nasdaq grid parameters are independent of all basket/source calculations.
string G_NQ = "7 - NASDAQ ZONES"
string inNqMode = input.string("Auto · Nasdaq", "Show zones", options = ["Auto · Nasdaq", "On", "Off"], group = G_NQ, tooltip = "Auto recognizes NQ/MNQ futures and common Nasdaq-100 index/CFD symbols. Choose On if your broker uses another name. Levels use this chart's prices; no futures-to-CFD conversion is applied. QQQ is not automatically included.")
int inNqAbove = input.int(5, "Above", minval = 1, maxval = 10, group = G_NQ, inline = "nqCount")
int inNqBelow = input.int(5, "Below", minval = 1, maxval = 10, group = G_NQ, inline = "nqCount")
float inNqHalf = input.float(25.0, "Band half-width (points)", minval = 0.5, maxval = 60.0, step = 0.5, group = G_NQ, tooltip = "25 gives a 50-point band centered on each 250-point grid level. These are price points, not contract profit or loss. An exact-price grid level is kept in addition to the levels strictly above and below.")
bool inNqLabels = input.bool(true, "Compact price labels", group = G_NQ)
bool inNqCenter = input.bool(true, "Centerline", group = G_NQ, inline = "nqDetails")
bool inNqMajors = input.bool(true, "Highlight majors", group = G_NQ, inline = "nqDetails", tooltip = "Gold labels identify multiples of 500 points. This is a round-number classification, not measured liquidity or trade confidence.")
color inNqUpper = input.color(#CE6A62, "Above price", group = G_NQ, inline = "nqColors")
color inNqLower = input.color(#5DAE83, "Below price", group = G_NQ, inline = "nqColors")

color C_SHELL = color.new(#080C14, 4)
color C_ROW   = color.new(#0F1623, 0)
color C_ROWB  = color.new(#0B111C, 0)
color C_BAND  = color.new(#000000, 0)
color C_LINE  = color.new(#1C2637, 0)
color C_EDGE  = color.new(#C9A85A, 50)
color C_HI    = color.new(#EEF2F7, 0)
color C_MID   = color.new(#B8C5D3, 0)
color C_LOW   = color.new(#9EABBA, 0)
color C_GOLD  = color.new(#C9A85A, 0)
color C_UP    = color.new(#34D399, 0)
color C_DN    = color.new(#F87171, 0)
color C_ON    = color.new(#0E9B7B, 0)
color C_OFF   = color.new(#B02722, 0)
color C_WUP   = color.new(#7FB7A8, 0)
color C_WDN   = color.new(#C9A05A, 0)

// v1 dashboard palette, verbatim
color C_PANEL = color.new(#0E141D, 0)
color C_HEAD  = color.new(#11161E, 0)
color C_SEC   = color.new(#151C28, 0)
color C_CELL  = color.new(#0E141D, 0)
color C_CELL2 = color.new(#121A24, 0)
color C_DIV   = color.new(#212B39, 0)
color C_FRAME = color.new(#354554, 0)
color C_TXT   = color.new(#D9DEE6, 0)
color C_MUT   = color.new(#9AA3AF, 0)
color C_DIM   = color.new(#9EABBA, 0)
color C_SB    = color.new(#5DAE83, 0)
color C_WB    = color.new(#7FB7A8, 0)
color C_WBE   = color.new(#C9A05A, 0)
color C_SBE   = color.new(#CE6A62, 0)
color C_AMBER = color.new(#C9A05A, 0)

// edge-label backgrounds (hoisted: no raw hex at the paint site)
color C_EDGEBG  = color.new(#101923, 0)
color C_EDGEHID = color.new(#080C14, 100)

// per-slot line colors (v1 palette) + VIX red + benchmark white
color LC0 = #94D6A0
color LC1 = #7FA8E0
color LC2 = #8ECAE6
color LC3 = #F1C28A
color LC4 = #BFA9E8
color LC5 = #EAD879
color LC6 = #E6A9C8
color LCV = #FF3B30
color LCB = #FFFFFF

color C_FACE = #101923
color C_STEEL = #6C879D
color C_WHITE = #FFFFFF
color C_LEADER = #17332D
color C_LAGGARD = #35232B
color C_BADGE = #1C2B3A
color C_BULLPANEL = #132C28
color C_BEARPANEL = #30212A
color C_NEUPANEL = #29271F
color C_BULLSTRIP = #122621
color C_BEARSTRIP = #281D25
color C_NEUSTRIP = #24241F
color C_RULEBAND = #1A2634
color C_GOLDBADGE = #322E20

// ───────────────────────── METRICS & CONTRACTS ──────────────────────────────
PANEL_POS = switch inPanPos
    "Top Left" => position.top_left
    "Top Right" => position.top_right
    "Bottom Right" => position.bottom_right
    "Middle Left" => position.middle_left
    "Middle Right" => position.middle_right
    => position.bottom_left
int TXT_L = inPanSize == "Micro" ? 10 : inPanSize == "Small" ? 12 : inPanSize == "Normal" ? 14 : 16
int TXT_S = math.max(9, TXT_L - 2)
int TXT_H = TXT_L + 2
string NY = "America/New_York"
float calcSec = timeframe.in_seconds(inCalcTf)
float chartSec = timeframe.in_seconds()
if barstate.isfirst and (na(calcSec) or calcSec < 60 or calcSec >= 86400)
    runtime.error("Choose an intraday source timeframe from 1 minute to less than 1 day.")

f_symName(string s) =>
    int cpos = str.pos(s, ":")
    na(cpos) ? s : str.substring(s, cpos + 1)
f_source(simple string s) => ticker.modify(ticker.standard(s), session = session.regular)
f_cap(float x) => na(x) ? na : math.max(-3.0, math.min(3.0, x))
f_score(float imp, float vwz, float ez) =>
    na(imp) or na(vwz) or na(ez) ? na : 0.50 * f_cap(imp) + 0.30 * f_cap(vwz) + 0.20 * f_cap(ez)
f_dayP(float px, float pd) => not na(px) and not na(pd) and pd > 0 ? (px / pd - 1) * 100 : na
f_dateKey(int t) => na(t) ? na : year(t, NY) * 10000 + month(t, NY) * 100 + dayofmonth(t, NY)
f_anchor(int observed, int dailyStamp) => not na(observed) and not na(dailyStamp) and dailyStamp <= observed and f_dateKey(observed) == f_dateKey(dailyStamp)
f_fresh(int stamp, int clock, float seconds) => not na(stamp) and not na(clock) and stamp >= clock - seconds * 2000 and stamp <= clock + seconds * 1000
f_m() =>
    float a14 = ta.atr(14)
    float e2 = ta.ema(close, 200)
    float vw = ta.vwap(hlc3)
    // Compare the developing bar with prior COMPLETED bars; still provisional.
    float baseVol = ta.sma(volume, 20)[1]
    float imp = not na(a14) and a14 > 0 ? (close - close[inImpBars]) / a14 : na
    float vwz = not na(a14) and a14 > 0 and not na(vw) ? (close - vw) / a14 : na
    float ez = not na(a14) and a14 > 0 and not na(e2) ? (close - e2) / a14 : na
    float rv = not na(baseVol) and baseVol > 0 ? volume / baseVol : na
    float sl = not na(e2[inSlope]) ? e2 - e2[inSlope] : na
    [close, vw, imp, vwz, ez, sl, rv, time, time_close, syminfo.currency]

// All data feeds use standard prices / regular sessions, independent of the
// chart's extended-session setting. Gaps-off holds prices; timestamps reveal it.
[px0, vw0, im0, vz0, ez0, sl0, rv0, ts0, tc0, cu0] = request.security(f_source(inS0), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px1, vw1, im1, vz1, ez1, sl1, rv1, ts1, tc1, cu1] = request.security(f_source(inS1), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px2, vw2, im2, vz2, ez2, sl2, rv2, ts2, tc2, cu2] = request.security(f_source(inS2), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px3, vw3, im3, vz3, ez3, sl3, rv3, ts3, tc3, cu3] = request.security(f_source(inS3), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px4, vw4, im4, vz4, ez4, sl4, rv4, ts4, tc4, cu4] = request.security(f_source(inS4), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px5, vw5, im5, vz5, ez5, sl5, rv5, ts5, tc5, cu5] = request.security(f_source(inS5), inCalcTf, f_m(), ignore_invalid_symbol = true)
[px6, vw6, im6, vz6, ez6, sl6, rv6, ts6, tc6, cu6] = request.security(f_source(inS6), inCalcTf, f_m(), ignore_invalid_symbol = true)
[pxB, vwB, imB, vzB, ezB, slB, rvB, tsB, tcB, cuB] = request.security(f_source(inBm), inCalcTf, f_m(), ignore_invalid_symbol = true)
// open/time are known at the start of the daily bar. No daily high/low/close[0].
[pd0, do0, dt0] = request.security(f_source(inS0), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd1, do1, dt1] = request.security(f_source(inS1), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd2, do2, dt2] = request.security(f_source(inS2), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd3, do3, dt3] = request.security(f_source(inS3), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd4, do4, dt4] = request.security(f_source(inS4), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd5, do5, dt5] = request.security(f_source(inS5), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pd6, do6, dt6] = request.security(f_source(inS6), "D", [close[1], open, time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[pdB, dtB] = request.security(f_source(inBm), "D", [close[1], time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
[vxPx, tsV, tcV] = request.security(f_source(inVx), inCalcTf, [close, time, time_close], ignore_invalid_symbol = true)
[vxPd, dtV] = request.security(f_source(inVx), "D", [close[1], time], lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
// Historical FQ series instead of applying a current syminfo share count to
// the whole past. Financial publication dates still limit backtest interpretation.
float sh0 = request.financial(inS0, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh1 = request.financial(inS1, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh2 = request.financial(inS2, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh3 = request.financial(inS3, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh4 = request.financial(inS4, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh5 = request.financial(inS5, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sh6 = request.financial(inS6, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)

array<string> symbols = array.from(inS0, inS1, inS2, inS3, inS4, inS5, inS6)
array<float> pxs = array.from(px0, px1, px2, px3, px4, px5, px6)
array<float> vws = array.from(vw0, vw1, vw2, vw3, vw4, vw5, vw6)
array<float> ims = array.from(im0, im1, im2, im3, im4, im5, im6)
array<float> vzs = array.from(vz0, vz1, vz2, vz3, vz4, vz5, vz6)
array<float> ezs = array.from(ez0, ez1, ez2, ez3, ez4, ez5, ez6)
array<float> sls = array.from(sl0, sl1, sl2, sl3, sl4, sl5, sl6)
array<float> rvs = array.from(rv0, rv1, rv2, rv3, rv4, rv5, rv6)
array<float> pds = array.from(pd0, pd1, pd2, pd3, pd4, pd5, pd6)
array<float> dos = array.from(do0, do1, do2, do3, do4, do5, do6)
array<float> mcs = array.from(sh0 * px0, sh1 * px1, sh2 * px2, sh3 * px3, sh4 * px4, sh5 * px5, sh6 * px6)
array<int> times = array.from(ts0, ts1, ts2, ts3, ts4, ts5, ts6)
array<int> ends = array.from(tc0, tc1, tc2, tc3, tc4, tc5, tc6)
array<int> dates = array.from(dt0, dt1, dt2, dt3, dt4, dt5, dt6)
array<string> currencies = array.from(cu0, cu1, cu2, cu3, cu4, cu5, cu6)
array<color> lcs = array.from(LC0, LC1, LC2, LC3, LC4, LC5, LC6)
array<float> scs = array.new_float(7, na)
array<float> dps = array.new_float(7, na)
array<float> vps = array.new_float(7, na)
array<bool> eligible = array.new_bool(7, false)
array<bool> duplicates = array.new_bool(7, false)
array<float> weights = array.new_float(7, na)

int clock = barstate.isrealtime ? timenow : time_close
int nyMinute = hour(clock, NY) * 60 + minute(clock, NY)
bool weekday = dayofweek(clock, NY) >= dayofweek.monday and dayofweek(clock, NY) <= dayofweek.friday
bool scheduledRth = weekday and nyMinute >= 570 and nyMinute < 960
int newest = array.max(ends)
// Outside scheduled RTH, compare the held basket internally and print its date.
// No exchange calendar is assumed: holidays/early closes show source age.
int freshnessClock = scheduledRth ? clock : newest
int liveN = 0
int freshN = 0
int dupN = 0
int nDay = 0
int nVw = 0
int nEma = 0
int cntUp = 0
int cntVw = 0
int cntE = 0
int posN = 0
int negN = 0
int nRv = 0
int activeRv = 0
float capTotal = 0.0
bool capReady = true
string capCurrency = ""
int oldest = na
int newestEligible = na
for i = 0 to 6
    bool duplicate = false
    if i > 0
        for j = 0 to i - 1
            if ticker.standard(array.get(symbols, i)) == ticker.standard(array.get(symbols, j))
                duplicate := true
    array.set(duplicates, i, duplicate)
    dupN += duplicate ? 1 : 0
    int t = array.get(times, i)
    int e = array.get(ends, i)
    bool aligned = f_anchor(t, array.get(dates, i))
    bool fresh = f_fresh(e, freshnessClock, calcSec) and f_dateKey(t) == f_dateKey(newest - 1)
    float score = f_score(array.get(ims, i), array.get(vzs, i), array.get(ezs, i))
    float dayP = aligned ? f_dayP(array.get(pxs, i), array.get(pds, i)) : na
    float vwP = f_dayP(array.get(pxs, i), array.get(vws, i))
    bool dataOk = fresh and not duplicate
    bool valid = dataOk and not na(score) and aligned
    array.set(eligible, i, valid)
    array.set(scs, i, valid ? score : na)
    array.set(dps, i, dayP)
    array.set(vps, i, vwP)
    freshN += dataOk and not na(array.get(pxs, i)) ? 1 : 0
    if dataOk and not na(dayP)
        nDay += 1
        cntUp += dayP > 0 ? 1 : 0
    if dataOk and not na(vwP)
        nVw += 1
        cntVw += vwP > 0 ? 1 : 0
    if dataOk and not na(array.get(ezs, i))
        nEma += 1
        cntE += array.get(ezs, i) > 0 ? 1 : 0
    if valid
        liveN += 1
        posN += score > 0.30 ? 1 : 0
        negN += score < -0.30 ? 1 : 0
        oldest := na(oldest) ? e : math.min(oldest, e)
        newestEligible := na(newestEligible) ? e : math.max(newestEligible, e)
        float mc = array.get(mcs, i)
        string cu = array.get(currencies, i)
        if liveN == 1
            capCurrency := cu
        capReady := capReady and not na(mc) and mc > 0 and cu != "" and cu == capCurrency
        capTotal += not na(mc) and mc > 0 ? mc : 0
        float rv = array.get(rvs, i)
        if not na(rv)
            nRv += 1
            activeRv += rv >= 1.5 ? 1 : 0
bool useCap = inWeights == "Auto cap" and capReady and liveN > 0 and capTotal > 0
float wAvg = na
float bullWeight = 0.0
float bearWeight = 0.0
float weightedDay = 0.0
float dayWeight = 0.0
if liveN > 0
    wAvg := 0.0
    for i = 0 to 6
        if array.get(eligible, i)
            float wt = useCap ? array.get(mcs, i) / capTotal : 1.0 / liveN
            float score = array.get(scs, i)
            array.set(weights, i, wt)
            wAvg += wt * score
            bullWeight += score > 0.30 ? wt : 0
            bearWeight += score < -0.30 ? wt : 0
            if not na(array.get(dps, i))
                weightedDay += wt * array.get(dps, i)
                dayWeight += wt
float basketDay = dayWeight > 0 ? weightedDay / dayWeight : na
bool benchmarkOk = f_anchor(tsB, dtB) and f_fresh(tcB, freshnessClock, calcSec) and f_dateKey(tsB) == f_dateKey(newest - 1)
bool vixOk = f_anchor(tsV, dtV) and f_fresh(tcV, freshnessClock, calcSec) and f_dateKey(tsV) == f_dateKey(newest - 1)
float bmSc = benchmarkOk ? f_score(imB, vzB, ezB) : na
float pB = benchmarkOk ? f_dayP(pxB, pdB) : na
float pV = vixOk ? f_dayP(vxPx, vxPd) : na
float lead = not na(wAvg) and not na(bmSc) ? wAvg - bmSc : na
float relativeDay = not na(basketDay) and not na(pB) ? basketDay - pB : na
// One source of truth for plots, edge labels and the ranked table.
float dP0 = array.get(eligible, 0) ? array.get(dps, 0) : na
float dP1 = array.get(eligible, 1) ? array.get(dps, 1) : na
float dP2 = array.get(eligible, 2) ? array.get(dps, 2) : na
float dP3 = array.get(eligible, 3) ? array.get(dps, 3) : na
float dP4 = array.get(eligible, 4) ? array.get(dps, 4) : na
float dP5 = array.get(eligible, 5) ? array.get(dps, 5) : na
float dP6 = array.get(eligible, 6) ? array.get(dps, 6) : na

// ───────────────────────── CHART AVERAGES ──────────────────────────────────
// The basket still uses its own source EMA200. These use the chart's close.
float smaF = ta.sma(close, inSmaF)
float smaS = ta.sma(close, inSmaS)
float chartWma200 = ta.wma(close, 200)
float chartWma365 = ta.wma(close, 365)

// ───────────────────────── CONFIRMED BASKET ALERTS ──────────────────────────
// Preserve the existing full-coverage and source-close gates for basket alerts.
// Non-aligned chart/source boundaries wait for their next common close.
bool completed = liveN == 7 and nDay == 7 and vixOk and chart.is_standard and timeframe.isintraday and not na(tcV) and tcV == time_close and newestEligible == time_close and oldest == time_close
bool eventReady = barstate.isconfirmed and completed
var float previousBasket = na
var int previousDay = na
var int previousClock = na
bool riskOnEvent = false
bool riskOffEvent = false
if eventReady
    int sourceDay = f_dateKey(newestEligible - 1)
    bool sameDay = not na(previousDay) and previousDay == sourceDay and not na(previousClock) and time_close - previousClock <= int(math.max(calcSec, chartSec) * 1000)
    riskOnEvent := sameDay and not na(previousBasket) and previousBasket <= 0.30 and wAvg > 0.30
    riskOffEvent := sameDay and not na(previousBasket) and previousBasket >= -0.30 and wAvg < -0.30
    previousBasket := wAvg
    previousDay := sourceDay
    previousClock := time_close
// No state updates from invalid/provisional observations.
alertcondition(riskOnEvent, "PR · Risk-ON (weighted)", "PulseRank confirmed basket crossed above +0.30. Full source coverage.")
alertcondition(riskOffEvent, "PR · Risk-OFF (weighted)", "PulseRank confirmed basket crossed below -0.30. Full source coverage.")

// ───────────────────────── TERMINAL PRESENTATION ────────────────────────────
f_sgn(float v, string fmt) => na(v) ? "—" : (v > 0 ? "+" : v < 0 ? "−" : "") + str.tostring(math.abs(v), fmt)
f_pct(float v) => na(v) ? "—" : f_sgn(v, "0.0") + "%"
f_px(float v) => na(v) ? "—" : str.tostring(v, "#,##0.00")
f_dcol(float v) => na(v) ? C_DIM : v > 0 ? C_UP : v < 0 ? C_DN : C_MUT
f_breadth(int count, int valid) => valid == 0 ? "—" : str.tostring(count) + "/" + str.tostring(valid) + " · " + str.tostring(100.0 * count / valid, "0") + "%"
f_intensity(float score) =>
    int n = na(score) ? 0 : int(math.round(math.abs(score) / 3.0 * 4))
    string bars = ""
    for i = 1 to 4
        bars += i <= n ? "■" : "·"
    bars
f_moment(float score) => na(score) ? "—" : f_sgn(score, "0.00") + " " + f_intensity(score)
f_age(int stamp, int nowAt) =>
    float age = not na(stamp) and not na(nowAt) ? math.max(0, (nowAt - stamp) / 60000.0) : na
    na(age) ? "No time" : age < 1 ? "<1m" : age < 60 ? str.tostring(math.floor(age)) + "m" : age < 1440 ? str.tostring(age / 60, "0.0") + "h" : str.tostring(age / 1440, "0.0") + "d"
f_gapName(float gap, float intra) =>
    na(gap) or na(intra) ? "Unavailable" : math.abs(gap) < 0.01 ? "Flat open" : gap > 0 ? (intra > 0 ? "Gap + follow" : "Gap + fade") : intra > 0 ? "Gap − rebound" : "Gap − follow"
f_rowTip(int i) =>
    int st = array.get(times, i)
    int en = array.get(ends, i)
    bool anchor = f_anchor(st, array.get(dates, i))
    float gap = anchor ? f_dayP(array.get(dos, i), array.get(pds, i)) : na
    float intraday = anchor ? f_dayP(array.get(pxs, i), array.get(dos, i)) : na
    float wt = array.get(weights, i)
    string info = array.get(symbols, i) + " · " + array.get(currencies, i)
    info += "\nDay " + f_pct(array.get(dps, i)) + " · Gap " + f_pct(gap) + " · Since open " + f_pct(intraday)
    info += "\n" + f_gapName(gap, intraday) + ". Day = (1+gap/100)*(1+intra/100)-1, in %."
    info += "\nMoment " + f_sgn(array.get(scs, i), "0.00") + " score; directional intensity, not a probability."
    info += "\nImpulse " + f_sgn(array.get(ims, i), "0.00") + " ATR · VWAP " + f_sgn(array.get(vzs, i), "0.00") + " ATR · EMA200 " + f_sgn(array.get(ezs, i), "0.00") + " ATR."
    info += "\nWeights 50/30/20 with each component capped at ±3. The impulse can include an overnight gap."
    info += "\nBasket weight " + (na(wt) ? "excluded" : str.tostring(wt * 100, "0.0") + "%") + " · " + (useCap ? "reported-cap estimate" : "equal eligible weights")
    info += "\nRVol " + (na(array.get(rvs, i)) ? "unavailable" : str.tostring(array.get(rvs, i), "0.00") + "x") + " versus previous 20 complete source bars, not same-time-of-day volume."
    info += "\nSource " + (na(st) ? "unavailable" : str.format_time(st, "dd MMM HH:mm", NY)) + "–" + (na(en) ? "—" : str.format_time(en, "HH:mm", NY)) + " NY · age " + f_age(en, clock)
    info += array.get(duplicates, i) ? "\nDUPLICATE slot: excluded." : not array.get(eligible, i) ? "\nExcluded: missing, insufficient, misaligned or stale source data." : "\nLive source bars are provisional. Closed session values are retained, not live trades."
    info

bool inRth = not inRthOnly or not na(time(timeframe.period, inRthSess + ":23456", NY))
// Break lines across hidden sessions instead of visually joining overnight gaps.
plot(inShowLines and inGlow and inRth ? dP0 : na, "S1 halo", color = color.new(LC0, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP1 : na, "S2 halo", color = color.new(LC1, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP2 : na, "S3 halo", color = color.new(LC2, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP3 : na, "S4 halo", color = color.new(LC3, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP4 : na, "S5 halo", color = color.new(LC4, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP5 : na, "S6 halo", color = color.new(LC5, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inGlow and inRth ? dP6 : na, "S7 halo", color = color.new(LC6, 88), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inShowVix and inGlow and inRth ? pV : na, "Volatility halo", color = color.new(LCV, 90), linewidth = inLw + 3, style = plot.style_linebr, editable = false, display = display.pane)
plot(inShowLines and inRth ? dP0 : na, "S1 day %", color = LC0, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP1 : na, "S2 day %", color = LC1, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP2 : na, "S3 day %", color = LC2, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP3 : na, "S4 day %", color = LC3, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP4 : na, "S5 day %", color = LC4, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP5 : na, "S6 day %", color = LC5, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inRth ? dP6 : na, "S7 day %", color = LC6, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inShowVix and inRth ? pV : na, "Volatility day %", color = LCV, linewidth = inLw, style = plot.style_linebr)
plot(inShowLines and inShowBench and inRth ? pB : na, "Benchmark day %", color = LCB, linewidth = 1, style = plot.style_linebr)
hline(0, "Previous close · 0%", color = C_STEEL, linestyle = hline.style_dotted)

// Layered SMA ribbon. Same two averages and appearance as the baseline.
color cloudColor = smaF >= smaS ? C_ON : C_OFF
float cloudHi = math.max(smaF, smaS)
float cloudLo = math.min(smaF, smaS)
float cloudLip = cloudLo + (cloudHi - cloudLo) * 0.18
pFast = plot(inShowCld ? smaF : na, "SMA fast", color = color.new(cloudColor, 12), linewidth = 2, force_overlay = true, editable = false)
pSlow = plot(inShowCld ? smaS : na, "SMA slow", color = color.new(cloudColor, 28), linewidth = 1, force_overlay = true, editable = false)
pHi = plot(inShowCld ? cloudHi : na, "Cloud upper", display = display.none, force_overlay = true, editable = false)
pLo = plot(inShowCld ? cloudLo : na, "Cloud lower", display = display.none, force_overlay = true, editable = false)
pLip = plot(inShowCld ? cloudLip : na, "Cloud relief", display = display.none, force_overlay = true, editable = false)
fill(pFast, pSlow, color = color.new(cloudColor, 91), title = "SMA cloud body")
fill(pLo, pLip, color = color.new(cloudColor, 83), title = "SMA cloud inner lip")

// Chart WMAs: restrained halo plus a crisp center; no extra chart labels.
// Both layers stay on the main price chart, outside the performance pane.
plot(inShowWma200 ? chartWma200 : na, "WMA 200 halo", color = color.new(inWma200Color, 88), linewidth = 5, style = plot.style_linebr, display = display.pane, force_overlay = true, editable = false)
plot(inShowWma365 ? chartWma365 : na, "WMA 365 halo", color = color.new(inWma365Color, 88), linewidth = 5, style = plot.style_linebr, display = display.pane, force_overlay = true, editable = false)
plot(inShowWma200 ? chartWma200 : na, "WMA 200", color = inWma200Color, linewidth = 2, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true, editable = false, format = format.price)
plot(inShowWma365 ? chartWma365 : na, "WMA 365", color = inWma365Color, linewidth = 2, style = plot.style_linebr, display = display.pane + display.data_window, force_overlay = true, editable = false, format = format.price)

// ───────────────────────── NASDAQ PRICE ZONES ──────────────────────────────
// Adapted from © NomadaScalper / 250NQ v3.2, supplied by the owner.
// All drawings force the MAIN PRICE pane. Never scale the percentage pane.
// Reusable pools prevent accumulating objects as the last bar changes.
const float NQ_STEP = 250.0
const float NQ_MAJOR = 500.0
const float NQ_EPS = 0.000001
string nqTicker = str.upper(syminfo.ticker)
bool nqFuture = syminfo.type == "futures" and (syminfo.root == "NQ" or syminfo.root == "MNQ")
bool nqAlias = nqTicker == "NDX" or str.contains(nqTicker, "NAS100") or str.contains(nqTicker, "NASDAQ100") or str.contains(nqTicker, "US100") or str.contains(nqTicker, "USTEC")
bool nqCash = (syminfo.type == "cfd" or syminfo.type == "index") and nqAlias
bool nqEnabled = inNqMode == "On" or (inNqMode == "Auto · Nasdaq" and (nqFuture or nqCash))
int nqSlots = inNqAbove + inNqBelow + 1

f_nqAbove(float px, int k) => math.floor(px / NQ_STEP) * NQ_STEP + k * NQ_STEP
f_nqBelow(float px, int k) => math.ceil(px / NQ_STEP) * NQ_STEP - k * NQ_STEP
f_nqMajor(float level) => math.abs(level - math.round(level / NQ_MAJOR) * NQ_MAJOR) <= NQ_EPS

var array<box> nqBodies = array.new<box>()
var array<box> nqLips = array.new<box>()
var array<box> nqShades = array.new<box>()
var array<line> nqCenters = array.new<line>()
var array<label> nqShadows = array.new<label>()
var array<label> nqRims = array.new<label>()
var array<label> nqFaces = array.new<label>()

if barstate.isfirst and nqEnabled
    for slot = 0 to nqSlots - 1
        array.push(nqBodies, box.new(left = bar_index, top = na, right = bar_index + 1, bottom = na, border_color = na, bgcolor = na, extend = extend.both, force_overlay = true))
        array.push(nqLips, box.new(left = bar_index, top = na, right = bar_index + 1, bottom = na, border_color = na, bgcolor = na, extend = extend.both, force_overlay = true))
        array.push(nqShades, box.new(left = bar_index, top = na, right = bar_index + 1, bottom = na, border_color = na, bgcolor = na, extend = extend.both, force_overlay = true))
        array.push(nqCenters, line.new(x1 = bar_index, y1 = na, x2 = bar_index + 1, y2 = na, color = na, extend = extend.both, force_overlay = true))
        array.push(nqShadows, label.new(x = bar_index, y = na, text = "", style = label.style_label_left, color = color.new(C_SHELL, 38), textcolor = color.new(C_WHITE, 100), size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold, force_overlay = true))
        array.push(nqRims, label.new(x = bar_index, y = na, text = "", style = label.style_label_left, color = C_GOLD, textcolor = color.new(C_WHITE, 100), size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold, force_overlay = true))
        array.push(nqFaces, label.new(x = bar_index, y = na, text = "", style = label.style_label_left, color = C_FACE, textcolor = C_TXT, size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold, force_overlay = true))

f_nqPaint(int slot, float level, bool above, int rank, bool atPrice) =>
    bool major = inNqMajors and f_nqMajor(level)
    color tone = atPrice ? C_GOLD : above ? inNqUpper : inNqLower
    color ink = major or atPrice ? C_GOLD : above ? C_DN : C_UP
    int borderOpacity = math.min(55, 6 + rank * 11)
    int fillOpacity = math.min(95, 84 + rank * 3)
    float top = level + inNqHalf
    float bottom = level - inNqHalf
    int left = math.max(0, bar_index - 1)
    int right = bar_index + 1
    box body = array.get(nqBodies, slot)
    box lip = array.get(nqLips, slot)
    box shade = array.get(nqShades, slot)
    box.set_lefttop(body, left, top)
    box.set_rightbottom(body, right, bottom)
    box.set_border_color(body, color.new(tone, borderOpacity))
    box.set_bgcolor(body, color.new(tone, fillOpacity))
    // Decorative layers stay entirely inside the true band.
    box.set_lefttop(lip, left, top)
    box.set_rightbottom(lip, right, top - inNqHalf * 0.16)
    box.set_bgcolor(lip, color.new(C_WHITE, math.min(98, 91 + rank)))
    box.set_lefttop(shade, left, bottom + inNqHalf * 0.16)
    box.set_rightbottom(shade, right, bottom)
    box.set_bgcolor(shade, color.new(C_SHELL, math.min(98, 92 + rank)))
    line center = array.get(nqCenters, slot)
    line.set_xy1(center, left, inNqCenter ? level : na)
    line.set_xy2(center, right, inNqCenter ? level : na)
    line.set_color(center, color.new(tone, math.min(65, 15 + rank * 12)))

    float relief = inNqHalf * 0.045
    string caption = " " + (major ? "★ " : "") + str.tostring(level, "#,##0") + " "
    for layer = 0 to 2
        label plate = layer == 0 ? array.get(nqShadows, slot) : layer == 1 ? array.get(nqRims, slot) : array.get(nqFaces, slot)
        float yy = level + (layer == 0 ? -relief : layer == 1 ? relief * 0.35 : 0)
        label.set_xy(plate, bar_index + 7, inNqLabels ? yy : na)
        label.set_text(plate, inNqLabels ? caption : "")
        label.set_color(plate, layer == 0 ? color.new(C_SHELL, 38) : layer == 1 ? color.new(ink, 25) : C_FACE)
        label.set_textcolor(plate, layer == 2 ? ink : color.new(C_WHITE, 100))
    string context = atPrice ? "At current price" : above ? "Above current price" : "Below current price"
    string tip = "PulseRank · Nasdaq grid · " + syminfo.ticker + "\n" + context + " · " + (major ? "500-point major" : "250-point grid")
    tip += "\nBand " + str.tostring(bottom, format.mintick) + " to " + str.tostring(top, format.mintick) + " · ±" + str.tostring(inNqHalf, "0.#") + " points."
    tip += "\nFixed round-number reference on this chart's price scale. No futures/CFD conversion, order-flow measurement or entry signal. Displayed levels follow the latest chart close."
    label.set_tooltip(array.get(nqFaces, slot), tip)

if barstate.islast and array.size(nqBodies) > 0
    // Reset every layer first, including the optional exact-price slot.
    // This also prevents a stale zone after the chart leaves an exact multiple.
    for slot = 0 to array.size(nqBodies) - 1
        for bx in array.from(array.get(nqBodies, slot), array.get(nqLips, slot), array.get(nqShades, slot))
            box.set_top(bx, na)
            box.set_bottom(bx, na)
        line center = array.get(nqCenters, slot)
        line.set_xy1(center, bar_index, na)
        line.set_xy2(center, bar_index + 1, na)
        for plate in array.from(array.get(nqShadows, slot), array.get(nqRims, slot), array.get(nqFaces, slot))
            label.set_y(plate, na)
            label.set_text(plate, "")
    if nqEnabled and not na(close)
        float nearest = math.round(close / NQ_STEP) * NQ_STEP
        bool atGrid = math.abs(close - nearest) <= NQ_EPS
        float reference = atGrid ? nearest : close
        for k = 1 to inNqBelow
            f_nqPaint(k - 1, f_nqBelow(reference, k), false, k - 1, false)
        for k = 1 to inNqAbove
            f_nqPaint(inNqBelow + k - 1, f_nqAbove(reference, k), true, k - 1, false)
        if atGrid
            f_nqPaint(inNqAbove + inNqBelow, nearest, false, 0, true)

// Data ranking is independent of the presentation. Stable ties keep slot order.
// Stable valid-first sort; rank IDs cannot collide with the order namespace.
array<int> rankOrder = array.from(0, 1, 2, 3, 4, 5, 6)
for i = 1 to 6
    int key = array.get(rankOrder, i)
    float val = array.get(scs, key)
    int j = i - 1
    while j >= 0
        float prior = array.get(scs, array.get(rankOrder, j))
        bool move = not na(val) and (na(prior) or val > prior)
        if not move
            break
        array.set(rankOrder, j + 1, array.get(rankOrder, j))
        j -= 1
    array.set(rankOrder, j + 1, key)

// Edge labels: 9 native plaques + fine leaders. Prices/plot values never move.
// Resolve label positions only, grouping collisions around their mean.
f_pack(array<float> values, float gap) =>
    array<float> positions = array.copy(values)
    int count = array.size(values)
    if count > 1
        int k = 0
        while k < count
            int last = k
            float total = array.get(values, k)
            bool expanding = true
            while expanding and last < count - 1
                int n = last - k + 1
                float top = total / n + (n - 1) * gap * 0.5
                if array.get(values, last + 1) - top < gap
                    last += 1
                    total += array.get(values, last)
                else
                    expanding := false
            float center = total / (last - k + 1)
            for q = k to last
                array.set(positions, q, center + (q - k - (last - k) * 0.5) * gap)
            k := last + 1
        // A shifted cluster can collide with its predecessor. Monotone repair.
        for q = 1 to count - 1
            array.set(positions, q, math.max(array.get(positions, q), array.get(positions, q - 1) + gap))
        float drift = (array.sum(positions) - array.sum(values)) / count
        for q = 0 to count - 1
            array.set(positions, q, array.get(positions, q) - drift)
    positions

var array<label> edgeFaces = array.new<label>()
var array<label> edgeRims = array.new<label>()
var array<label> edgeShadows = array.new<label>()
var array<line> edgeLeads = array.new<line>()
if barstate.isfirst
    for i = 0 to 8
        array.push(edgeShadows, label.new(bar_index, na, "", style = label.style_label_left, color = color.new(C_SHELL, 35), textcolor = color.new(C_WHITE, 100), size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold))
        array.push(edgeRims, label.new(bar_index, na, "", style = label.style_label_left, color = C_STEEL, textcolor = color.new(C_WHITE, 100), size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold))
        array.push(edgeFaces, label.new(bar_index, na, "", style = label.style_label_left, color = C_FACE, textcolor = C_WHITE, size = 10, text_font_family = font.family_monospace, text_formatting = text.format_bold))
        array.push(edgeLeads, line.new(bar_index, na, bar_index, na, color = C_STEEL))
        array.push(edgeLeads, line.new(bar_index, na, bar_index, na, color = C_STEEL))

// PulseRank terminal: immutable layout, one table / zero new chart objects.
int COLS = inResearch ? 10 : 8
var table panel = table.new(PANEL_POS, COLS, 19, bgcolor = C_PANEL, frame_color = C_FRAME, frame_width = 2, border_color = C_DIV, border_width = 0, force_overlay = true)
if barstate.isfirst
    table.merge_cells(panel, 0, 0, 4, 0)
    table.merge_cells(panel, 5, 0, COLS - 1, 0)
    for row = 1 to 4
        table.merge_cells(panel, 0, row, 2, row)
        table.merge_cells(panel, 3, row, 4, row)
        table.merge_cells(panel, 5, row, COLS - 1, row)
    table.merge_cells(panel, 0, 5, 3, 5)
    table.merge_cells(panel, 4, 5, COLS - 1, 5)
    for row in array.from(14, 15)
        table.merge_cells(panel, 0, row, 1, row)
        table.merge_cells(panel, 4, row, COLS - 1, row)
    for row = 16 to 18
        table.merge_cells(panel, 0, row, COLS - 1, row)
f_cell(int col, int row, string caption, color bg, color ink, int sz, bool bold, string align, string tip) =>
    table.cell(panel, col, row, " " + caption + " ", bgcolor = bg, text_color = ink, text_size = sz, text_halign = align, text_font_family = font.family_monospace, text_formatting = bold ? text.format_bold : text.format_none, tooltip = tip)
// Display helpers only: no consumers in the source, weight or basket-alert engines.
f_scoreInk(float score) => na(score) ? C_DIM : score > 0.30 ? C_UP : score < -0.30 ? C_DN : C_GOLD
f_weightPct(float weight) => na(weight) ? "—" : weight > 0 and weight < 0.005 ? "<1%" : weight < 1 and weight >= 0.995 ? ">99%" : str.tostring(weight * 100, "0") + "%"
f_sourceStamp(int t) => na(t) ? "NO TIME" : str.format_time(t, "dd MMM HH:mm", NY) + " NY"

if barstate.islast
    array<float> edgeValues = array.from(dP0, dP1, dP2, dP3, dP4, dP5, dP6, pV, pB)
    array<string> edgeNames = array.from(f_symName(inS0), f_symName(inS1), f_symName(inS2), f_symName(inS3), f_symName(inS4), f_symName(inS5), f_symName(inS6), f_symName(inVx), f_symName(inBm))
    array<color> edgeColors = array.from(LC0, LC1, LC2, LC3, LC4, LC5, LC6, LCV, LCB)
    array<float> raw = array.new_float()
    array<int> ids = array.new_int()
    for i = 0 to 8
        bool show = inEdgeLbl and inShowLines and inRth and not na(array.get(edgeValues, i)) and (i < 7 or (i == 7 and inShowVix) or (i == 8 and inShowBench))
        if show
            array.push(raw, array.get(edgeValues, i))
            array.push(ids, i)
        for layer = 0 to 2
            label ref = layer == 0 ? array.get(edgeShadows, i) : layer == 1 ? array.get(edgeRims, i) : array.get(edgeFaces, i)
            label.set_xy(ref, bar_index + 5, na)
            label.set_text(ref, "")
        line.set_xy1(array.get(edgeLeads, i * 2), bar_index, na)
        line.set_xy2(array.get(edgeLeads, i * 2), bar_index, na)
        line.set_xy1(array.get(edgeLeads, i * 2 + 1), bar_index, na)
        line.set_xy2(array.get(edgeLeads, i * 2 + 1), bar_index, na)
    int n = array.size(raw)
    if n > 0
        array<int> permutation = array.sort_indices(raw, order.ascending)
        array<float> sorted = array.new_float()
        for k = 0 to n - 1
            array.push(sorted, array.get(raw, array.get(permutation, k)))
        float span = math.max(1.0, array.max(sorted) - array.min(sorted))
        float gap = math.max(0.12, span * 0.06)
        array<float> packed = f_pack(sorted, gap)
        for k = 0 to n - 1
            int i = array.get(ids, array.get(permutation, k))
            float yy = array.get(packed, k)
            float actual = array.get(edgeValues, i)
            color ink = array.get(edgeColors, i)
            string caption = " " + array.get(edgeNames, i) + "  " + f_pct(actual) + " "
            for layer = 0 to 2
                label ref = layer == 0 ? array.get(edgeShadows, i) : layer == 1 ? array.get(edgeRims, i) : array.get(edgeFaces, i)
                label.set_xy(ref, bar_index + 5, yy + (layer == 0 ? -gap * 0.09 : layer == 1 ? gap * 0.035 : 0))
                label.set_text(ref, caption)
                label.set_color(ref, layer == 0 ? color.new(C_SHELL, 35) : layer == 1 ? color.new(ink, 25) : C_FACE)
                label.set_textcolor(ref, layer == 2 ? ink : color.new(C_WHITE, 100))
            label.set_tooltip(array.get(edgeFaces, i), "Actual source day change: " + f_pct(actual) + ". Only label placement is displaced. Leader line starts at the true value.")
            line a = array.get(edgeLeads, i * 2)
            line b = array.get(edgeLeads, i * 2 + 1)
            line.set_xy1(a, bar_index, actual)
            line.set_xy2(a, bar_index + 3, actual)
            line.set_xy1(b, bar_index + 3, actual)
            line.set_xy2(b, bar_index + 5, yy)
            line.set_color(a, color.new(ink, 45))
            line.set_color(b, color.new(ink, 45))

    if not inShowPanel
        table.clear(panel, 0, 0, COLS - 1, 18)
    else
        bool full = liveN == 7 and dupN == 0
        bool staleAll = not na(newest) and scheduledRth and not f_fresh(newest, clock, calcSec)
        bool retained = not scheduledRth and liveN > 0
        string freshness = staleAll ? "STALE DATA" : liveN == 0 ? "NO DATA" : retained ? "LAST SNAPSHOT" : not full ? "PARTIAL DATA" : "LIVE · UPDATING"
        string weightsTag = useCap ? "CAP WEIGHTED" : "EQUAL WEIGHT"
        string bias = na(wAvg) ? "WAITING" : wAvg > 0.30 ? "RISK ON" : wAvg < -0.30 ? "RISK OFF" : "BALANCED"
        color biasColor = f_scoreInk(wAvg)
        color heroBg = na(wAvg) ? C_BADGE : wAvg > 0.30 ? C_BULLPANEL : wAvg < -0.30 ? C_BEARPANEL : C_NEUPANEL
        int neutralN = liveN - posN - negN
        // Exact empty/full groups avoid exposing a floating-point residual.
        float displayBullWeight = posN == 0 ? 0.0 : posN == liveN ? 1.0 : bullWeight
        float displayBearWeight = negN == 0 ? 0.0 : negN == liveN ? 1.0 : bearWeight
        float neutralWeight = liveN == 0 ? na : neutralN == 0 ? 0.0 : neutralN == liveN ? 1.0 : math.max(0.0, math.min(1.0, 1.0 - bullWeight - bearWeight))
        string alignment = liveN == 0 ? "—" : wAvg > 0.30 ? str.tostring(posN) + " / " + str.tostring(liveN) + " BULLISH" : wAvg < -0.30 ? str.tostring(negN) + " / " + str.tostring(liveN) + " BEARISH" : str.tostring(neutralN) + " / " + str.tostring(liveN) + " NEUTRAL"
        string modeTip = "Basket score in normalized units, from −3 to +3. Risk on >+0.30; risk off <−0.30; balanced otherwise. This is a directional reading, not confidence, win rate or probability.\n" + (full ? "Seven distinct eligible symbols." : "Partial basket. Missing or duplicate members do not count as agreement.")
        string weightTip = "Composition uses normalized CURRENT basket weights. BULL: score >+0.30. NEUTRAL: −0.30 through +0.30. BEAR: score <−0.30.\n" + weightsTag + ": reported quarterly shares x source price when all eligible estimates have the same currency; equal weights for the whole eligible basket otherwise. Rounded percentages can total 99% or 101%."
        string clockTip = "Times are source-bar end times, not tick-arrival times. Source feeds use regular sessions. Values outside US scheduled RTH are retained snapshots. Holiday/early-close calendars are not inferred. The chart must receive updates for this dashboard to refresh."
        string breadthTip = "Directional breadth counts eligible members: " + str.tostring(posN) + " bullish, " + str.tostring(neutralN) + " neutral, " + str.tostring(negN) + " bearish. It is an unweighted count; the composition strip below uses basket weights."

        // Identity band, then three separate information blocks.
        f_cell(0, 0, "PULSERANK  /  NomadaScalper", C_HEAD, C_GOLD, TXT_L + 1, true, text.align_left, "PulseRank NomadaScalper · v3.4.0\nRanked market strength, breadth and relative leadership.")
        f_cell(5, 0, freshness, C_HEAD, retained ? C_GOLD : full and not staleAll ? C_UP : C_WDN, TXT_S, true, text.align_right, clockTip)
        f_cell(0, 1, "BASKET DIRECTION", heroBg, C_MUT, TXT_S, false, text.align_left, modeTip)
        f_cell(3, 1, "MOMENT SCORE", C_BADGE, C_MUT, TXT_S, false, text.align_center, modeTip)
        f_cell(5, 1, "DIRECTIONAL BREADTH", C_BADGE, C_MUT, TXT_S, false, text.align_right, breadthTip)
        f_cell(0, 2, bias, heroBg, biasColor, TXT_H + 1, true, text.align_left, modeTip)
        f_cell(3, 2, f_sgn(wAvg, "0.00"), C_BADGE, C_WHITE, TXT_H + 2, true, text.align_center, modeTip)
        f_cell(5, 2, alignment, C_BADGE, biasColor, TXT_L + 1, true, text.align_right, breadthTip)

        // Keep bullish / neutral / bearish weights visible together.
        f_cell(0, 3, "BULL  " + f_weightPct(liveN > 0 ? displayBullWeight : na), C_BULLSTRIP, liveN > 0 ? C_UP : C_DIM, TXT_S, true, text.align_left, weightTip)
        f_cell(3, 3, "NEUTRAL  " + f_weightPct(neutralWeight), C_NEUSTRIP, liveN > 0 ? C_GOLD : C_DIM, TXT_S, true, text.align_center, weightTip)
        f_cell(5, 3, "BEAR  " + f_weightPct(liveN > 0 ? displayBearWeight : na), C_BEARSTRIP, liveN > 0 ? C_DN : C_DIM, TXT_S, true, text.align_right, weightTip)
        f_cell(0, 4, "DAY UP  " + f_breadth(cntUp, nDay), C_PANEL, C_TXT, TXT_S, false, text.align_left, "Members above their own previous daily close / valid unique daily-change observations. This is not moment-score breadth.")
        f_cell(3, 4, "VWAP  " + f_breadth(cntVw, nVw), C_PANEL, C_TXT, TXT_S, false, text.align_center, "Above own session VWAP / valid unique VWAP observations. Missing feeds are excluded from this denominator.")
        f_cell(5, 4, "EMA200  " + f_breadth(cntE, nEma), C_PANEL, C_TXT, TXT_S, false, text.align_right, "Above own source-timeframe EMA200 / valid unique EMA observations. Equal prices are neutral.")

        int leaderId = array.get(rankOrder, 0)
        int weakestId = array.get(rankOrder, math.max(0, liveN - 1))
        float leaderScore = liveN > 0 ? array.get(scs, leaderId) : na
        float weakestScore = liveN > 1 ? array.get(scs, weakestId) : na
        string topName = liveN > 0 ? f_symName(array.get(symbols, leaderId)) : "—"
        string bottomName = liveN > 1 ? f_symName(array.get(symbols, weakestId)) : "—"
        f_cell(0, 5, "TOP  " + topName + "  " + f_sgn(leaderScore, "0.00"), C_SEC, f_scoreInk(leaderScore), TXT_S, true, text.align_left, "Highest eligible signed score. Top-ranked can still be negative.\n" + (liveN > 0 ? f_rowTip(leaderId) : "No eligible member."))
        f_cell(4, 5, "BOTTOM  " + bottomName + "  " + f_sgn(weakestScore, "0.00"), C_SEC, f_scoreInk(weakestScore), TXT_S, true, text.align_right, "Lowest eligible signed score, shown only with at least two eligible members. Bottom-ranked can still be positive.\n" + (liveN > 1 ? f_rowTip(weakestId) : "Not enough eligible members."))
        array<string> heads = array.from("#", "ASSET", "LAST", "DAY %", "VWAP %", "E200 / ATR", "MOMENT", "RVOL", "GAP / INTRA", "WEIGHT")
        for c = 0 to COLS - 1
            f_cell(c, 6, array.get(heads, c), C_RULEBAND, C_MUT, TXT_S, true, c <= 1 ? text.align_left : text.align_right, c == 6 ? "Signed score and absolute intensity. Both positive and negative extremes fill all four segments. Gold = neutral band ±0.30." : c == 7 ? "Current source-bar volume / the previous 20 completed bars. Not normalized by time of day. Closing auctions can produce large values; developing bars start with partial volume." : c == 5 ? "Distance from EMA200 in own ATR14. Arrow describes EMA slope, not a buy/sell instruction." : "Ranked by signed moment score. Hover each row for its full breakdown and source timestamp.")

        for r = 0 to 6
            int i = array.get(rankOrder, r)
            int row = r + 7
            bool ok = array.get(eligible, i)
            float score = array.get(scs, i)
            bool leader = ok and r == 0
            color tone = ok ? f_scoreInk(score) : C_DIM
            color bg = r % 2 == 0 ? C_CELL : C_CELL2
            color scoreBg = not ok ? bg : score > 0.30 ? C_BULLPANEL : score < -0.30 ? C_BEARPANEL : C_NEUPANEL
            string tip = f_rowTip(i)
            string rankText = ok ? str.tostring(r + 1, "00") : "—"
            float ez = array.get(ezs, i)
            float slope = array.get(sls, i)
            string emaState = na(ez) or na(slope) ? "—" : (slope > 0 ? "↑ " : slope < 0 ? "↓ " : "= ") + f_sgn(ez, "0.0")
            float rv = array.get(rvs, i)
            string rvol = na(rv) ? "—" : str.tostring(rv, "0.0") + "x"
            color rvColor = not ok or na(rv) ? C_DIM : rv >= 1.5 ? C_WHITE : C_MUT
            f_cell(0, row, rankText, leader ? C_GOLDBADGE : bg, leader ? C_GOLD : C_MUT, TXT_S, true, text.align_center, tip)
            f_cell(1, row, f_symName(array.get(symbols, i)), bg, ok ? array.get(lcs, i) : C_DIM, TXT_L, true, text.align_left, tip)
            f_cell(2, row, f_px(array.get(pxs, i)), bg, ok ? C_TXT : C_DIM, TXT_L, false, text.align_right, tip)
            f_cell(3, row, f_pct(array.get(dps, i)), bg, ok ? f_dcol(array.get(dps, i)) : C_DIM, TXT_L, true, text.align_right, tip)
            f_cell(4, row, f_pct(array.get(vps, i)), bg, ok ? f_dcol(array.get(vps, i)) : C_DIM, TXT_L, false, text.align_right, tip)
            f_cell(5, row, emaState, bg, ok ? f_dcol(ez) : C_DIM, TXT_L, false, text.align_right, tip)
            f_cell(6, row, f_moment(score), scoreBg, tone, TXT_L, true, text.align_right, tip)
            f_cell(7, row, rvol, bg, rvColor, TXT_L, rv >= 1.5 and ok, text.align_right, tip)
            if inResearch
                bool validAnchor = f_anchor(array.get(times, i), array.get(dates, i))
                float gp = validAnchor ? f_dayP(array.get(dos, i), array.get(pds, i)) : na
                float ip = validAnchor ? f_dayP(array.get(pxs, i), array.get(dos, i)) : na
                string wt = ok ? str.tostring(array.get(weights, i) * 100, "0.0") + "%" : array.get(duplicates, i) ? "DUP" : "N/A"
                f_cell(8, row, f_pct(gp) + " / " + f_pct(ip), bg, ok ? C_TXT : C_DIM, TXT_S, false, text.align_right, tip)
                f_cell(9, row, wt, bg, ok ? C_GOLD : C_DIM, TXT_L, false, text.align_right, tip)

        // Independent context feeds can close at a different time from equities.
        // Show their own valid reading, but NEVER relax benchmarkOk / vixOk or
        // write these display-only numbers into pB / pV / basket alerts / pane plots.
        bool benchmarkDisplayOk = f_anchor(tsB, dtB) and not na(pxB)
        float benchmarkDisplayDay = benchmarkDisplayOk ? f_dayP(pxB, pdB) : na
        string relation = na(lead) ? "NO COMPARISON" : math.abs(lead) < 0.15 ? "IN STEP" : lead > 0 ? "LEADING" : "LAGGING"
        string benchTip = "Basket score minus benchmark score, in normalized score units. This is not return or direct ATR distance.\nBenchmark source: " + f_sourceStamp(tcB) + " · age " + f_age(tcB, clock) + ".\nDay-relative return: " + f_sgn(relativeDay, "0.00") + " percentage points, using current basket weights. An independent held benchmark price can be displayed even when the synchronized comparison is unavailable."
        f_cell(0, 14, f_symName(inBm) + " BENCH", C_RULEBAND, C_WHITE, TXT_S, true, text.align_left, benchTip)
        f_cell(2, 14, f_px(pxB), C_RULEBAND, benchmarkDisplayOk ? C_TXT : C_DIM, TXT_L, false, text.align_right, benchTip)
        f_cell(3, 14, f_pct(benchmarkDisplayDay), C_RULEBAND, f_dcol(benchmarkDisplayDay), TXT_L, true, text.align_right, benchTip)
        f_cell(4, 14, relation + "  " + f_sgn(lead, "0.00"), C_RULEBAND, na(lead) ? C_DIM : math.abs(lead) < 0.15 ? C_MUT : f_dcol(lead), TXT_L, true, text.align_right, benchTip)

        bool vixDisplayOk = f_anchor(tsV, dtV) and not na(vxPx)
        float vixDisplayDay = vixDisplayOk ? f_dayP(vxPx, vxPd) : na
        bool isVix = ticker.standard(inVx) == "CBOE:VIX"
        string volRegime = not vixDisplayOk ? "NO DATA" : not isVix ? "CUSTOM VOL" : vxPx < 14 ? "LOW" : vxPx < 20 ? "CALM" : vxPx < 28 ? "ELEVATED" : "HIGH"
        color volInk = not vixDisplayOk ? C_DIM : not isVix ? C_MUT : vxPx < 20 ? C_GOLD : vxPx < 28 ? C_WDN : C_DN
        string volClock = not vixDisplayOk ? "" : not vixOk ? " · OWN " + str.format_time(tcV, "HH:mm", NY) : not scheduledRth ? " · HELD" : ""
        string volTip = "Independent volatility feed: " + f_sourceStamp(tcV) + " · age " + f_age(tcV, clock) + ".\n" + (vixOk ? "Aligned with the basket freshness checks." : "Not aligned with the basket freshness checks: excluded from basket comparisons and basket-alert eligibility. The own-source reading remains visible when its own daily anchor is valid.") + "\nCBOE:VIX bands only: <14 LOW, 14–20 CALM, 20–28 ELEVATED, ≥28 HIGH. VIX readings provide volatility context, not trade probabilities."
        f_cell(0, 15, f_symName(inVx) + " VOL", C_HEAD, LCV, TXT_S, true, text.align_left, volTip)
        f_cell(2, 15, f_px(vxPx), C_HEAD, vixDisplayOk ? C_TXT : C_DIM, TXT_L, false, text.align_right, volTip)
        f_cell(3, 15, f_pct(vixDisplayDay), C_HEAD, na(vixDisplayDay) ? C_DIM : vixDisplayDay > 0 ? C_DN : vixDisplayDay < 0 ? C_UP : C_MUT, TXT_L, true, text.align_right, volTip)
        f_cell(4, 15, volRegime + volClock, C_HEAD, volInk, TXT_S, true, text.align_right, volTip)

        string readout = na(wAvg) ? "Waiting for aligned source data" : not full ? "Partial basket · " + str.tostring(liveN) + "/7 eligible · basket alerts paused" : wAvg > 0.30 ? (posN >= 5 ? "Broad positive momentum" : "Positive momentum · concentrated leadership") : wAvg < -0.30 ? (negN >= 5 ? "Broad negative momentum" : "Negative momentum · concentrated pressure") : "Mixed momentum · no clear basket direction"
        if full and not na(lead) and wAvg > 0.30 and lead < -0.15
            readout := "Positive basket · lagging " + f_symName(inBm)
        else if full and not na(lead) and wAvg < -0.30 and lead > 0.15
            readout := "Negative basket · holding better than " + f_symName(inBm)
        f_cell(0, 16, readout, heroBg, biasColor, TXT_L, true, text.align_left, modeTip + "\n" + benchTip)
        string stamp = na(oldest) ? (na(newest) ? "Source time unavailable" : "LAST OBSERVED " + f_sourceStamp(newest)) : "SOURCE " + str.format_time(oldest, "dd MMM yy HH:mm", NY) + (oldest != newestEligible ? "–" + str.format_time(newestEligible, "HH:mm", NY) : "") + " NY"
        stamp += "  ·  AGE " + f_age(na(oldest) ? newest : oldest, clock)
        f_cell(0, 17, stamp, C_HEAD, C_MUT, TXT_S, false, text.align_left, clockTip)
        string footer = str.tostring(liveN) + "/7 COVERED  ·  " + weightsTag + "  ·  TF " + inCalcTf
        footer += dupN > 0 ? "  ·  DUPLICATE" : not chart.is_standard ? "  ·  EVENTS OFF" : ""
        f_cell(0, 18, footer, C_PANEL, full ? C_MUT : C_GOLD, TXT_S, false, text.align_left, "PulseRank NomadaScalper · v3.4.0\n" + weightTip + "\nChart/source timing: " + (chartSec > calcSec ? "sampled source bars" : chartSec < calcSec ? "live higher-timeframe source" : "matching timeframe") + ". Basket alerts require every source close to match the confirmed standard chart close. BUY/SELL and pullback alerts have been removed. Delete any previously created entry alerts in TradingView. Chart WMAs use the current symbol and timeframe. Relative volume activity: " + str.tostring(activeRv) + "/" + str.tostring(nRv) + " eligible members ≥1.5x; developing and closing-auction bars need context.")
````
