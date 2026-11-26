# CISD Pro+ | Cross-Symbol Correlation]

- url: https://www.tradingview.com/script/80rILNaR/
- type: indicator
- pine_id: PUB;60709af2622b40a7a1c5447ba8dd864c
- version: 1.0

## Description

📘 CISD Pro+ | Cross-Symbol Correlation

"CISD Pro+ | Cross-Symbol Correlation" finds CISD signals on the chart; draws the CISDs of a second product you select (e.g., ETH, DXY) as hook shapes next to them, and measures the momentum alignment of the two products, weighting the signal's probability and quality accordingly.

Short name: CISD Pro+
What it does: Finds CISD signals on the chart, measures their correlation with another symbol you select, and scores the signals based on this alignment. In short: it answers the question "Is this signal moving in the same direction as the other product I'm watching?"

────────────────────────────────────────

🎯 1. What Does This Indicator Do?

- Automatically finds CISD (Change In State of Delivery) points.
  In other words, it marks the bars where the market changes direction and the buyer/seller balance is broken.
- With MTF (Multi-Timeframe), it also searches for CISD on higher timeframes simultaneously.
- With Symbol CISD, it pulls data from another instrument (e.g., on an ETHUSDT chart, BTCUSDT, DXY, SPX, etc.).
- Measures Correlation & Momentum Alignment: Is the symbol on the chart moving in the same direction as the other symbol you selected?
- With Bayesian & GARCH, it assigns a probability (P) and quality (Q) score to the signal.
- Draws Fibonacci extensions for target levels.

────────────────────────────────────────

⚙️ 3. What Do the Settings Mean?

1. ⚙️ General

- CISD Directional Bias: Should we catch only bullish, only bearish, or both? "Auto" = both.
- Debug Mode: Something wrong? Turn it on, it writes what happened in the log panel. Keep it off normally.

2. 🔥 CISD Detection

- Show CISD: Main on/off switch.
- CISD Sensitivity: "Standard" = waits 10 bars, "Max" = waits 20 bars. Choose "Max" in slow markets.
- CISD Size Filter: Filters out very small, insignificant signals. If you choose "Juicy", it only shows large moves.
- Show All Historical CISD?: If on, invalidated signals remain as dashed lines.
- Filter by Purge: Shows only signals with a liquidity purge.
- 🔒 One Label Per Level: Deletes the old one so labels don't pile up at the same price level.

2.2 🧪 Fibonacci (Targets)

You can turn Fibonacci extensions like -0.5, -2, -2.5, -4, -4.5 on and off here.
Calculate From → "Body" or "Wick" selection. Generally "Body" works cleaner.

3. 🕐 MTF CISD (Higher Timeframe)

- Enable MTF CISD: Also searches for signals on higher timeframes.
- MTF Timeframe: Which timeframe? e.g., 60 = 1 hour, 240 = 4 hours, D = daily.
- Max MTF CISDs: How many signals to keep in the same direction.
- MTF Pending Timeout: How many higher-TF bars a signal should wait for confirmation.

4. 🧠 Advanced Analytics

- Enable Advanced Analytics: Turns on quality (Q) and probability (P) scores.
- GARCH Dynamic Sizing: Automatically adjusts the threshold when the market is calm/volatile.
- Chart CISD Filter (Quality): Minimum quality score. 40 = medium, 60 = strict, 20 = loose.
- Bayesian Weighting: Turns on probability calculation (purge, MTF, volume, killzone effect).
- Killzone Session: Busy hours bonus. e.g., 0700-1000,1300-1600.

5. 📊 Symbol CISD (⭐ Most Important Part)

This section is where correlation with another product is measured.

- Enable Symbol CISD: Turns it on.
- Symbol: The instrument you want to compare. e.g., BINANCE:ETHUSDT, TVC:DXY, SP:SPX.
- Timeframe: Leave empty = same as chart. Or select like 60, D.
- U Bull / U Bear: Colors of the correlation mark (hook-shaped drawing).
- 🏷️ Label Mode: Should text appear below? Options like "TF Only" (timeframe only), "Ticker + TF" (symbol + timeframe).

────────────────────────────────────────

🔗 4. How Does the Correlation Feature Work?

The indicator measures correlation/alignment in two places:

1. Momentum alignment:
   Is the direction of the last 10 bars on the chart the same as the direction of the last 10 bars of the symbol you selected?
   - Same direction → strong alignment
   - Different direction → weak alignment

2. Probability model bonus:
   If the two products are moving in the same direction, an extra confidence score is added to the signal. So a "correlated signal" gets a higher probability.

3. Symbol CISD engine:
   When a CISD forms on the symbol you selected, a U (hook) shape is drawn on the chart. This means "there was also a reversal on the other side."

So in practice:

- You're on a BTC chart, you selected ETH → If a CISD appeared on ETH and a CISD also appeared on BTC, it means there is two-sided correlation confirmation.
- This means the signal is more reliable.

────────────────────────────────────────

📖 5. What Will You See on the Screen?

- Solid line (green/red)  →  Confirmed CISD
- Dotted line  →  CISD still waiting for confirmation
- Dashed line  →  Invalidated CISD (in exhaustive mode)
- 🔵 Small circle  →  CISD confirmation mark
- Q45 · P62%  →  Quality 45, probability 62%
- U (hook) shape  →  CISD on the selected symbol (correlation signal)
- Fibonacci lines  →  Target levels (-0.5, -2, -2.5, -4, -4.5)
- MTF label  →  Like 60 · Q72 · P78% – higher timeframe CISD

────────────────────────────────────────

🚀 6. Quick Start (5 Minutes)

1. To see only chart CISD:
   Show CISD ✅ on, Enable MTF ❌ off, Enable Symbol CISD ❌ off.

2. To use MTF + Correlation together:
   Enable MTF ✅, Enable Symbol CISD ✅, Symbol = BINANCE:ETHUSDT (or whatever you want to compare).

3. To see only high-quality signals:
   Quality Threshold = 60, Size Filter = Juicy, MTF + Symbol CISD = ✅.

4. To see Fib targets:
   Show Fibonacci Projections = ✅, tick the levels you want.

────────────────────────────────────────

💡 7. Practical Tips

- Choose a correlated asset: BTC ↔ ETH, SPX ↔ NDX, XAU ↔ DXY, etc. Don't pick a random symbol.
- Use the same timeframe: If the chart is 15m, set Symbol TF to 15m or 60. If you choose D, it works with a delay.
- If you don't want a crowded chart: Reduce Max MTF CISDs and Max Symbol CISDs to 5–8.
- When Debug is on: You'll see lines like "PIVOT-H", "PEND-BEAR", "SUMMARY" in the log panel. Useful for understanding issues.
- Red warning: If the market is very calm, CISD may not appear. Try Sensitivity = Max and Size Filter = Small.

────────────────────────────────────────

❓ 8. Frequently Asked Questions

Q: Why am I not getting any signals?
A: Show CISD might be off, the Bias filter might be one-directional, or the Size Filter might be too strict.

Q: Symbol CISD lines are not visible?
A: Enable Symbol CISD is off or the symbol name entered is incorrect. Use the full format like BINANCE:BTCUSDT.

Q: Why are MTF lines delayed?
A: MTF signals wait for the higher TF close. If you chose 60, it updates once an hour.

Q: What are Q and P?
A: Q = Quality (0–100): How solid the signal is. P = Probability (%): Chance of confirmation.

Q: Where is the correlation written?
A: It is not written as a direct number. Its effect appears in two places:
   1. The P (probability) score increases if there is alignment.
   2. When a CISD occurs on the selected symbol, a U-shaped hook appears on the chart.

────────────────────────────────────────

📌 9. One-Sentence Summary

"CISD Pro+ | Cross-Symbol Correlation" finds CISD signals on the chart; draws the CISDs of a second product you select (e.g., ETH, DXY) as hook shapes next to them, and measures the momentum alignment of the two products, weighting the signal's probability and quality accordingly.

────────────────────────────────────────

This indicator is adapted from the CISD code written by @cephxs.

## Source Code

````pine
//@version=6

indicator("CISD Pro+ | Cross-Symbol Correlation]",
         shorttitle       = "CISD Pro+",
         overlay          = true,
         max_lines_count  = 500,
         max_labels_count = 500,
         max_boxes_count  = 500,
         max_bars_back    = 500,
         calc_bars_count  = 3000)

// =============================================================================
// GROUP STRINGS
// =============================================================================

string g_general  = "1. ⚙️ General"
string g_cisd     = "2. 🔥 CISD Detection"
string g_cisd_fib = "2.2. 🧪 CISD Fibonacci Projections"
string g_mtf      = "3. 🕐 MTF CISD"
string g_adv      = "4. 🧠 Advanced Analytics"
string g_sym      = "5. 📊 Symbol CISD"

// =============================================================================
// CONSTANTS
// =============================================================================

color primBullCol   = #00a2c7
color primBearCol   = #db5755
color C_TRANSPARENT = color.new(color.white, 100)

const int LW_MTF         = 4
const int LW_CHART       = 2
const int LW_WEAK        = 1
const int LW_INVALIDATED = 1

const int SCAN_MAX_BARS           = 300
const int HTF_CACHE_MAX           = 1500
const int PURGE_TRACKER_MAX       = 100
const int CISD_FIB_MIN_SPACING_MS = 2 * 60 * 60 * 1000
const bool CISD_FIB_ENGINE        = true
const int DEFAULT_PIVOT_LEN       = 1
const int SYM_RANGE_MAX_BARS      = 1000   // safe upper bound for t1/t2 coverage scan

int  pivot_len                = DEFAULT_PIVOT_LEN
bool pivot_delete_on_cross    = true
bool cisd_invalidate_on_cross = true

// =============================================================================
// TYPES
// =============================================================================

type CISDStretch
    bool  bullish
    int   origin_bar
    float level
    int   end_bar
    float end_close
    float origin_high
    float origin_low
    int   run_ext_bar
    float run_ext_price

type PendingCISD
    CISDStretch stretch
    int   pivot_bar
    int   start_bar
    line  pending_line

type ConfirmedCISD
    CISDStretch stretch
    int   pivot_bar
    float pivot_price
    int   confirmation_bar
    line  confirmed_line
    label confirm_shape
    label tf_label        = na
    label analytics_label = na
    bool  is_invalidated  = false

type PivotData
    int   bar_idx
    float price
    bool  is_high
    bool  has_purge

type PurgeTracker
    int   pivot_bar
    bool  is_high
    int   purge_bar

type CISDFibProjection
    int   cisd_pivot_bar
    bool  is_bullish
    array<line>  fib_lines
    array<label> fib_labels
    int   confirmation_bar  = 0
    int   confirmation_time = 0

type MTFPending
    CISDStretch stretch
    int   pivot_chart_bar
    float pivot_price
    int   start_htf_count
    line  pending_line

type SymbolCISDMark
    bool   bullish
    int    bar1
    int    bar2
    line   left_tick
    line   right_tick
    line   base_line
    label  confirm_mark
    label  ticker_lbl
    float  pivot_price
    int    confirmation_bar
    int    t1
    int    t2
    int    tier

type SymbolPending
    CISDStretch stretch
    int   pivot_chart_bar
    float pivot_price
    int   start_sym_count

// =============================================================================
// STATE
// =============================================================================

var array<PendingCISD>       pending_cisd         = array.new<PendingCISD>()
var array<ConfirmedCISD>     confirmed_cisd       = array.new<ConfirmedCISD>()
var array<CISDFibProjection> cisd_fib_projections = array.new<CISDFibProjection>()
var array<PivotData>         pivot_highs          = array.new<PivotData>()
var array<PivotData>         pivot_lows           = array.new<PivotData>()
var array<PurgeTracker>      purge_tracker        = array.new<PurgeTracker>()

var array<float> htf_o  = array.new<float>()
var array<float> htf_h  = array.new<float>()
var array<float> htf_l  = array.new<float>()
var array<float> htf_c  = array.new<float>()
var array<int>   htf_bi = array.new<int>()
var array<float> htf_av = array.new<float>()

var array<MTFPending>    mtf_pending   = array.new<MTFPending>()
var array<ConfirmedCISD> mtf_confirmed = array.new<ConfirmedCISD>()
var int htf_bar_count = 0

var array<float> sym_o  = array.new<float>()
var array<float> sym_h  = array.new<float>()
var array<float> sym_l  = array.new<float>()
var array<float> sym_c  = array.new<float>()
var array<int>   sym_bi = array.new<int>()
var array<float> sym_av = array.new<float>()
var array<int>   sym_t  = array.new<int>()

var array<SymbolPending>   sym_pending      = array.new<SymbolPending>()
var array<SymbolCISDMark>  sym_marks        = array.new<SymbolCISDMark>()

var array<PivotData>       sym_pivot_highs  = array.new<PivotData>()
var array<PivotData>       sym_pivot_lows   = array.new<PivotData>()
var array<PurgeTracker>    sym_purge_tracker = array.new<PurgeTracker>()

var int sym_bar_count = 0

var float symVolVarFast = 0.0
var float symVolVarSlow = 0.0
var float symVolMultiplier = 1.0
var float prevSymClose = 0.0

var int dbg_pivH_cnt      = 0
var int dbg_pivL_cnt      = 0
var int dbg_pend_created  = 0
var int dbg_conf_created  = 0
var int dbg_confirm_wait  = 0
var int dbg_duplike_cnt   = 0
var int dbg_pend_timeout  = 0
var int dbg_dup_removed   = 0

// =============================================================================
// INPUTS — GENERAL / CISD
// =============================================================================

string cisd_bias = input.string('Auto', '🔥 CISD Directional Bias',
     options = ['Auto', 'Bullish', 'Bearish'], group = g_general,
     tooltip = "Directional bias filter for CISD detection.\n" +
               "• Auto → both bullish and bearish CISDs are detected\n" +
               "• Bullish → only bullish CISDs are detected\n" +
               "• Bearish → only bearish CISDs are detected")

bool debug_mode = input.bool(true, '🐞 Debug Mode', group = g_general,
     tooltip = "Enables detailed debug logging in the Pine Logs panel.\n" +
               "Logs pivot creation, pending/confirmed CISD events, and a summary\n" +
               "of active structures on the last bar.")

bool  inp_cisd_show = input.bool(true, '🔥 Show CISD', inline = 'cisd_main', group = g_cisd,
     tooltip = "Master switch for the chart CISD engine.\n" +
               "When disabled, no chart CISD lines, labels, or fibs are drawn.")
color cisd_color_bull = input.color(color.new(primBullCol, 0), '', inline = 'cisd_main', group = g_cisd, active = inp_cisd_show,
     tooltip = "Color used for bullish CISD lines and labels.")
color cisd_color_bear = input.color(color.new(primBearCol, 0), '', inline = 'cisd_main', group = g_cisd, active = inp_cisd_show,
     tooltip = "Color used for bearish CISD lines and labels.")
int   cisd_offset = input.int(2, '', minval = 0, maxval = 20, inline = 'cisd_main', group = g_cisd, active = inp_cisd_show,
     tooltip = "How many bars to the right the confirmed CISD line extends\n" +
               "past the confirmation bar.")

string cisd_sensitivity = input.string('Standard', 'CISD Sensitivity',
     options = ['Standard', 'Max'], group = g_cisd, active = inp_cisd_show,
     tooltip = "Controls how long a pending CISD is allowed to wait for confirmation.\n" +
               "• Standard → 10 bars timeout\n" +
               "• Max → 20 bars timeout (more lenient, catches slower confirmations)")
int cisd_pending_timeout = cisd_sensitivity == 'Standard' ? 10 : 20

bool   cisd_size_filter = input.bool(true, 'CISD Size Filter', inline = 'cisd_size', group = g_cisd, active = inp_cisd_show,
     tooltip = "Filters out CISDs whose stretch body size is below the minimum ATR multiple.\n" +
               "Useful to remove tiny, low-quality signals.")
string cisd_size_preset = input.string('Regular', '', options = ['Really small', 'Small', 'Regular', 'Sizeable', 'Juicy'],
     inline = 'cisd_size', group = g_cisd, active = inp_cisd_show and cisd_size_filter,
     tooltip = "Minimum stretch size threshold, expressed as an ATR multiple.\n" +
               "• Really small = 0.10 ATR\n" +
               "• Small = 0.25 ATR\n" +
               "• Regular = 0.50 ATR\n" +
               "• Sizeable = 0.66 ATR\n" +
               "• Juicy = 1.00 ATR")
bool   cisd_exhaustive  = input.bool(false, 'Show All Historical CISD?', group = g_cisd, active = inp_cisd_show,
     tooltip = "When enabled, invalidated CISDs are kept on the chart as dashed lines\n" +
               "instead of being removed, so you can review full history.")

bool cisd_purge_filter    = input.bool(false, 'Filter by Purge', inline = 'cisd_purge', group = g_cisd, active = inp_cisd_show,
     tooltip = "Requires that a liquidity purge (opposite-side pivot sweep) occurred\n" +
               "near the CISD pivot within the configured tolerance window.")
int  cisd_purge_tolerance = input.int(5, '', minval = 1, maxval = 50, inline = 'cisd_purge',
     group = g_cisd, active = inp_cisd_show and cisd_purge_filter,
     tooltip = "Maximum bar distance between the CISD pivot and the purge event\n" +
               "for the purge filter to accept the signal.")

bool dedupe_same_level = input.bool(true, '🔒 One Label Per Level',
     group = g_cisd, active = inp_cisd_show,
     tooltip = "If a new CISD is confirmed at the same direction and the same price level,\n" +
               "the previous line/label/fib is automatically deleted.")

float label_offset_mult = input.float(0.0, '🏷️ Label Offset (ATR ×)',
     minval = -2.0, maxval = 2.0, step = 0.05, group = g_cisd, active = inp_cisd_show,
     tooltip = "Vertical offset for analytics labels, expressed as an ATR multiple.\n" +
               "0 = label sits on the line. Positive values shift it up,\n" +
               "negative values shift it down.")

// =============================================================================
// INPUTS — FIB
// =============================================================================

bool   cisd_fib_show_raw = input.bool(false, '🧪 Show Fibonacci Projections', group = g_cisd_fib, active = inp_cisd_show,
     tooltip = "Draws Fibonacci extension projections from each confirmed CISD.")
string cisd_fib_mode     = input.string('Body', 'Calculate From', options = ['Body', 'Wick'],
     group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Source used to compute the fib projection range.\n" +
               "• Body → uses the CISD origin open and end close\n" +
               "• Wick → uses the origin wick and the run-extreme wick")
int    cisd_fib_max      = input.int(5, 'Max Fibs Per Direction', minval = 1, maxval = 10,
     group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Maximum number of simultaneous fib projections kept per direction.\n" +
               "Oldest projections are removed when the limit is exceeded.")

color cisd_fib_n05_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n05       = input.bool(false, '-0.5', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -0.5 Fibonacci extension level.")
color cisd_fib_n10_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n10       = input.bool(false, '-1   ', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -1 Fibonacci extension level.")
color cisd_fib_n15_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n15       = input.bool(false, '-1.5', inline = 'fib_n05', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -1.5 Fibonacci extension level.")

color cisd_fib_n20_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n20       = input.bool(true, '-2 ', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -2 Fibonacci extension level.")
color cisd_fib_n25_color = input.color(color.new(primBearCol, 0), '', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n25       = input.bool(true, '-2.5  ', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -2.5 Fibonacci extension level.")
color cisd_fib_n30_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n30       = input.bool(false, '-3  ', inline = 'fib_n20', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -3 Fibonacci extension level.")

color cisd_fib_n35_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n35       = input.bool(false, '-3.5', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -3.5 Fibonacci extension level.")
color cisd_fib_n40_color = input.color(color.new(primBearCol, 0), '', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n40       = input.bool(true, '-4   ', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -4 Fibonacci extension level.")
color cisd_fib_n45_color = input.color(color.new(#4a4a4a, 0), '', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw)
bool  cisd_fib_n45       = input.bool(true, '-4.5 ', inline = 'fib_n35', group = g_cisd_fib, active = inp_cisd_show and cisd_fib_show_raw,
     tooltip = "Draw the -4.5 Fibonacci extension level.")

bool cisd_fib_show = CISD_FIB_ENGINE and cisd_fib_show_raw

// =============================================================================
// INPUTS — MTF
// =============================================================================

bool mtf_enable = input.bool(true, '🕐 Enable MTF CISD', group = g_mtf,
     tooltip = "Enables the multi-timeframe CISD engine.\n" +
               "MTF CISDs are drawn separately from chart CISDs using the chosen timeframe.")
string mtf_tf = input.timeframe('60', 'MTF Timeframe', group = g_mtf, active = mtf_enable,
     tooltip = "Higher timeframe used for MTF CISD detection.")
color mtf_color_bull = input.color(color.new(primBullCol, 0), 'Bull', inline = 'mtf_col', group = g_mtf, active = mtf_enable,
     tooltip = "Color used for bullish MTF CISD lines.")
color mtf_color_bear = input.color(color.new(primBearCol, 0), 'Bear', inline = 'mtf_col', group = g_mtf, active = mtf_enable,
     tooltip = "Color used for bearish MTF CISD lines.")
int mtf_max_cisd = input.int(15, 'Max MTF CISDs (per direction)', minval = 1, maxval = 50, group = g_mtf, active = mtf_enable,
     tooltip = "Maximum number of active MTF CISDs kept per direction.\n" +
               "Older ones are removed FIFO when the limit is exceeded.")
bool mtf_size_filter = input.bool(true, 'MTF Size Filter', group = g_mtf, active = mtf_enable,
     tooltip = "Applies the same ATR-based stretch size filter to MTF CISDs.")
int mtf_pending_to = input.int(3, 'MTF Pending Timeout (HTF bars)', minval = 1, maxval = 30, group = g_mtf, active = mtf_enable,
     tooltip = "Number of HTF bars a pending MTF CISD is allowed to wait for confirmation.")
int mtf_offset = input.int(2, 'MTF Line Offset (bars)', minval = 0, maxval = 20, group = g_mtf, active = mtf_enable,
     tooltip = "How many bars to the right confirmed MTF CISD lines extend.")
bool mtf_show_tf_label = input.bool(true, 'Show TF Label on Lines', group = g_mtf, active = mtf_enable,
     tooltip = "Prefixes the MTF analytics label with the timeframe string.")
color mtf_label_bg = input.color(color.new(color.black, 80), 'Label BG', inline = 'mtf_lbl', group = g_mtf, active = mtf_enable and mtf_show_tf_label,
     tooltip = "Background color of the MTF analytics label.")

// =============================================================================
// INPUTS — ADVANCED ANALYTICS
// =============================================================================

bool adv_enabled = input.bool(true, '🧠 Enable Advanced Analytics', group = g_adv,
     tooltip = "Enables the Bayesian probability model, quality score,\n" +
               "and GARCH-style dynamic volatility sizing.")
bool adv_use_garch = input.bool(true, 'GARCH Dynamic Sizing', group = g_adv, active = adv_enabled,
     tooltip = "Scales the ATR-based stretch size filter dynamically using an\n" +
               "EWMA volatility ratio (fast vs slow).")
bool adv_show_analytics = input.bool(true, 'Show Quality/Probability on Labels', group = g_adv, active = adv_enabled,
     tooltip = "Shows the Q (quality) and P (probability) values on CISD labels.")
int adv_min_quality = input.int(40, 'Chart CISD Filter (Quality Threshold)', minval = 0, maxval = 100, group = g_adv, active = adv_enabled,
     tooltip = "Minimum quality score required for a chart CISD to be considered valid\n" +
               "for filtering/labeling purposes. Does not delete confirmed signals.")
bool adv_use_bayes = input.bool(true, 'Bayesian Weighting', group = g_adv, active = adv_enabled,
     tooltip = "Uses a Bayesian posterior model to estimate confirmation probability,\n" +
               "weighted by stretch size, purge, MTF alignment, killzone, and volume.")
string adv_killzone_session = input.session("0700-1000,1300-1600", 'Killzone Session', group = g_adv, active = adv_enabled,
     tooltip = "Session ranges used as the killzone bonus in the analytics model.\n" +
               "Empty disables the killzone term.")

// =============================================================================
// INPUTS — SYMBOL CISD
// =============================================================================

bool   sym_enable   = input.bool(false, '📊 Enable Symbol CISD', group = g_sym,
     tooltip = "Enables the Symbol CISD engine.\n" +
               "Fetches data from the selected symbol/timeframe and draws\n" +
               "CISD marks as U-shaped brackets on the chart.")
string sym_ticker   = input.symbol('BINANCE:BTCUSDT', 'Symbol', group = g_sym, active = sym_enable,
     tooltip = "Symbol to pull data from for Symbol CISD detection.")
string sym_tf_inp   = input.timeframe('', 'Timeframe (empty = chart TF)', group = g_sym, active = sym_enable,
     tooltip = "Timeframe used for the Symbol CISD engine.\n" +
               "Leave empty to use the chart timeframe.")
color  sym_col_bull = input.color(color.new(primBullCol, 0), 'Bull', inline = 'sym_col', group = g_sym, active = sym_enable,
     tooltip = "Color used for bullish Symbol CISD marks.")
color  sym_col_bear = input.color(color.new(primBearCol, 0), 'Bear', inline = 'sym_col', group = g_sym, active = sym_enable,
     tooltip = "Color used for bearish Symbol CISD marks.")
int    sym_max_cisd = input.int(15, 'Max Symbol CISDs (per direction)', minval = 1, maxval = 50, group = g_sym, active = sym_enable,
     tooltip = "Maximum number of active Symbol CISD marks kept per direction.\n" +
               "Oldest marks are removed FIFO when the limit is exceeded.")

// 🎨 U-line (bracket) colors — bright green / bright red
color  sym_u_col_bull = input.color(color.rgb(4, 250, 0, 20), 'U Bull', inline = 'sym_ucol', group = g_sym, active = sym_enable,
     tooltip = "Color of the bullish U-shaped bracket.")
//color  sym_u_col_bear = input.color(color.rgb(250, 4, 0, 20), 'U Bear', inline = 'sym_ucol', group = g_sym, active = sym_enable)
color  sym_u_col_bear = input.color(color.new(color.aqua, 20), 'U Bear', inline = 'sym_ucol', group = g_sym, active = sym_enable,
     tooltip = "Color of the bearish U-shaped bracket.")

// 🏷️ Label mode — single dropdown (default: TF Only)
string sym_lbl_mode = input.string('TF Only', '🏷️ Label Mode',
     options = ['Off', 'Ticker Only', 'TF Only', 'Ticker + TF'],
     group = g_sym, active = sym_enable,
     tooltip = "What to display under the U bracket:\n" +
               "• Off → no label is drawn\n" +
               "• Ticker Only → symbol only\n" +
               "• TF Only → timeframe only (default)\n" +
               "• Ticker + TF → symbol + timeframe (stacked)")

bool sym_show_lbl = sym_lbl_mode != 'Off'
color  sym_lbl_bg = input.color(color.new(color.black, 80), 'Ticker Label BG', inline = 'sym_lbl', group = g_sym, active = sym_enable and sym_show_lbl,
     tooltip = "Background color used for the Symbol label.")

// =============================================================================
// RESOLVED BIAS
// =============================================================================

simple bool BIAS_BEAR = cisd_bias == 'Auto' or cisd_bias == 'Bearish'
simple bool BIAS_BULL = cisd_bias == 'Auto' or cisd_bias == 'Bullish'

// =============================================================================
// HTF DATA
// =============================================================================

[htf_o_v, htf_h_v, htf_l_v, htf_c_v, htf_t_v, htf_atr_v] =
     request.security(syminfo.tickerid, mtf_tf,
     [open, high, low, close, time, ta.atr(14)],
     lookahead = barmerge.lookahead_off)

bool new_htf_bar = mtf_enable and not na(htf_t_v) and not na(htf_t_v[1]) and htf_t_v != htf_t_v[1]

// =============================================================================
// SYMBOL DATA
// =============================================================================

string sym_tf_resolved = sym_tf_inp == '' ? timeframe.period : sym_tf_inp

[sym_o_v, sym_h_v, sym_l_v, sym_c_v, sym_t_v, sym_atr_v] =
     request.security(sym_ticker, sym_tf_resolved,
     [open, high, low, close, time, ta.atr(14)],
     lookahead = barmerge.lookahead_off)

bool new_sym_bar = sym_enable and not na(sym_t_v) and not na(sym_t_v[1]) and sym_t_v != sym_t_v[1]

// =============================================================================
// GARCH / EWMA VOLATILITY (Chart)
// =============================================================================

var float volVarFast = 0.0
var float volVarSlow = 0.0

float retForVol = nz(math.log(close / close[1]), 0.0)
volVarFast := 0.90 * volVarFast + 0.10 * retForVol * retForVol
volVarSlow := 0.98 * volVarSlow + 0.02 * retForVol * retForVol

float volFast   = math.sqrt(volVarFast)
float volSlow   = math.sqrt(volVarSlow)
float volRegime = volSlow > 0 ? volFast / volSlow : 1.0
float volMultiplier = volRegime > 1.3 ? 1.5 : volRegime < 0.7 ? 0.7 : 1.0

float htfMom10   = mtf_enable ? nz(htf_c_v - htf_c_v[10], 0.0) : 0.0
float chartMom10 = nz(close - close[10], 0.0)
float htfCorr    = mtf_enable ? ((htfMom10 * chartMom10) > 0 ? 0.8 : 0.3) : 0.5

float relVolume = ta.sma(volume, 20) > 0 ? volume / ta.sma(volume, 20) : 1.0

bool useKillzone = adv_killzone_session != ""
bool inKillzone  = useKillzone ? not na(time(timeframe.period, adv_killzone_session)) : true

// =============================================================================
// GARCH / EWMA VOLATILITY (Symbol)
// =============================================================================

if new_sym_bar
    float symRet = prevSymClose > 0 ? nz(math.log(sym_c_v[1] / prevSymClose), 0.0) : 0.0
    symVolVarFast := 0.90 * symVolVarFast + 0.10 * symRet * symRet
    symVolVarSlow := 0.98 * symVolVarSlow + 0.02 * symRet * symRet
    prevSymClose := sym_c_v[1]
    float symVolFast = math.sqrt(symVolVarFast)
    float symVolSlow = math.sqrt(symVolVarSlow)
    float symVolRegime = symVolSlow > 0 ? symVolFast / symVolSlow : 1.0
    symVolMultiplier := symVolRegime > 1.3 ? 1.5 : symVolRegime < 0.7 ? 0.7 : 1.0

// =============================================================================
// ANALYTICS HELPERS
// =============================================================================

bayesianScore(float stretchATR, bool hasPurge, bool mtfAligned, bool inKZ, float relVol) =>
    float prior_logit = math.log(0.55 / 0.45)
    float w_size      = math.log(math.max(stretchATR, 0.1)) * 0.8
    float w_purge     = hasPurge   ? 0.6  : -0.3
    float w_mtf       = mtfAligned ? 0.5  : -0.2
    float w_kz        = inKZ       ? 0.4  : -0.1
    float w_vol       = (relVol - 1.0) * 0.3
    float posterior   = prior_logit + w_size + w_purge + w_mtf + w_kz + w_vol
    float clipped     = math.max(-10.0, math.min(10.0, posterior))
    1.0 / (1.0 + math.exp(-clipped))

signalQuality(float stretchATR, int confirmSpeed, bool hasPurge, bool mtfAligned, float htfCorrV) =>
    float s_size  = math.min(1.0, stretchATR / 3.0)
    float s_speed = math.max(0.0, 1.0 - confirmSpeed / 15.0)
    float s_purge = hasPurge   ? 1.0 : 0.0
    float s_mtf   = mtfAligned ? 1.0 : 0.2
    float s_corr  = math.max(0.0, math.min(1.0, htfCorrV))
    int((s_size * 0.25 + s_speed * 0.15 + s_purge * 0.20 + s_mtf * 0.20 + s_corr * 0.20) * 100)

// =============================================================================
// HELPERS — FIB
// =============================================================================

deleteFibProjection(CISDFibProjection fp) =>
    if array.size(fp.fib_lines) > 0
        for i = 0 to array.size(fp.fib_lines) - 1
            line.delete(array.get(fp.fib_lines, i))
    if array.size(fp.fib_labels) > 0
        for i = 0 to array.size(fp.fib_labels) - 1
            label.delete(array.get(fp.fib_labels, i))

removeFibProjectionByPivotBar(int pivotBar, bool bullish) =>
    if array.size(cisd_fib_projections) > 0
        for i = array.size(cisd_fib_projections) - 1 to 0
            fp = array.get(cisd_fib_projections, i)
            if fp.cisd_pivot_bar == pivotBar and fp.is_bullish == bullish
                deleteFibProjection(fp)
                array.remove(cisd_fib_projections, i)

removeCISDByPivotBar(int pivotBar, bool bullish) =>
    if array.size(pending_cisd) > 0
        for i = array.size(pending_cisd) - 1 to 0
            item = array.get(pending_cisd, i)
            if item.pivot_bar == pivotBar and item.stretch.bullish == bullish
                line.delete(item.pending_line)
                array.remove(pending_cisd, i)
    if array.size(confirmed_cisd) > 0
        for i = array.size(confirmed_cisd) - 1 to 0
            ci = array.get(confirmed_cisd, i)
            if ci.pivot_bar == pivotBar and ci.stretch.bullish == bullish
                line.delete(ci.confirmed_line)
                label.delete(ci.confirm_shape)
                if not na(ci.tf_label)
                    label.delete(ci.tf_label)
                if not na(ci.analytics_label)
                    label.delete(ci.analytics_label)
                array.remove(confirmed_cisd, i)
    removeFibProjectionByPivotBar(pivotBar, bullish)

removeConfirmedCISDsAtLevel(float level, bool bullish, float tolerance) =>
    int removedCount = 0
    if array.size(confirmed_cisd) > 0
        for i = array.size(confirmed_cisd) - 1 to 0
            ci = array.get(confirmed_cisd, i)
            if ci.stretch.bullish == bullish and not ci.is_invalidated
                float priceDist = math.abs(ci.stretch.level - level)
                if priceDist <= tolerance
                    line.delete(ci.confirmed_line)
                    label.delete(ci.confirm_shape)
                    if not na(ci.tf_label)
                        label.delete(ci.tf_label)
                    if not na(ci.analytics_label)
                        label.delete(ci.analytics_label)
                    removeFibProjectionByPivotBar(ci.pivot_bar, ci.stretch.bullish)
                    array.remove(confirmed_cisd, i)
                    removedCount += 1
    removedCount

hasPurgeForCISD(int pivotBar, bool bullishCISD, int tolerance) =>
    bool hasPurge = false
    if array.size(purge_tracker) > 0
        for i = 0 to array.size(purge_tracker) - 1
            pt = array.get(purge_tracker, i)
            int dist = pt.purge_bar - pivotBar
            if dist >= 0 and dist <= tolerance
                if bullishCISD and not pt.is_high
                    hasPurge := true
                else if not bullishCISD and pt.is_high
                    hasPurge := true
    hasPurge

hasSymPurgeForCISD(int pivotBar, bool bullishCISD, int tolerance) =>
    bool hasPurge = false
    if array.size(sym_purge_tracker) > 0
        for i = 0 to array.size(sym_purge_tracker) - 1
            pt = array.get(sym_purge_tracker, i)
            int dist = pt.purge_bar - pivotBar
            if dist >= 0 and dist <= tolerance
                if bullishCISD and not pt.is_high
                    hasPurge := true
                else if not bullishCISD and pt.is_high
                    hasPurge := true
    hasPurge

isPropulsionBlock(bool bullish, float extreme, int extremeBar, int maxAge) =>
    bool prop = false
    if array.size(confirmed_cisd) > 0
        for i = 0 to array.size(confirmed_cisd) - 1
            ci = array.get(confirmed_cisd, i)
            int age = extremeBar - ci.confirmation_bar
            if ci.stretch.bullish == bullish and age >= 0 and age <= maxAge
                float zTop = math.max(ci.stretch.level, ci.pivot_price)
                float zBot = math.min(ci.stretch.level, ci.pivot_price)
                if extreme >= zBot and extreme <= zTop
                    prop := true
                    break
    prop

countFibProjections(bool isBullish) =>
    int count = 0
    if array.size(cisd_fib_projections) > 0
        for i = 0 to array.size(cisd_fib_projections) - 1
            fp = array.get(cisd_fib_projections, i)
            if fp.is_bullish == isBullish
                count += 1
    count

mostRecentFibTime(bool isBullish) =>
    int t = 0
    if array.size(cisd_fib_projections) > 0
        for i = 0 to array.size(cisd_fib_projections) - 1
            fp = array.get(cisd_fib_projections, i)
            if fp.is_bullish == isBullish and fp.confirmation_time > t
                t := fp.confirmation_time
    t

removeOldestFibForDir(bool isBull) =>
    int idx = -1
    if array.size(cisd_fib_projections) > 0
        for i = 0 to array.size(cisd_fib_projections) - 1
            fp = array.get(cisd_fib_projections, i)
            if fp.is_bullish == isBull
                idx := i
                break
    if idx >= 0
        deleteFibProjection(array.get(cisd_fib_projections, idx))
        array.remove(cisd_fib_projections, idx)
        true
    else
        false

enforceFibMax(int maxPerDirection) =>
    while countFibProjections(true) > maxPerDirection
        if not removeOldestFibForDir(true)
            break
    while countFibProjections(false) > maxPerDirection
        if not removeOldestFibForDir(false)
            break

// =============================================================================
// CISD CORE HELPERS
// =============================================================================

isBullBody(int i) => close[i] > open[i]
isBearBody(int i) => close[i] < open[i]

float cisd_atr = ta.atr(14)

getCISDMinATRMult(string preset) =>
    preset == 'Really small' ? 0.1 : preset == 'Small' ? 0.25 : preset == 'Sizeable' ? 0.66 : preset == 'Juicy' ? 1.0 : 0.5

float cisd_atr_mult_base = getCISDMinATRMult(cisd_size_preset)
float cisd_atr_mult      = adv_enabled and adv_use_garch ? cisd_atr_mult_base * volMultiplier : cisd_atr_mult_base

float sym_atr_mult = adv_enabled and adv_use_garch ? cisd_atr_mult_base * symVolMultiplier : cisd_atr_mult_base

_scanEndOffset(int pivotOffset, bool bullishPivot, int maxScan) =>
    int endOffset = -1
    for k = pivotOffset to pivotOffset + maxScan
        if bullishPivot and isBearBody(k)
            endOffset := k
            break
        else if not bullishPivot and isBullBody(k)
            endOffset := k
            break
    endOffset

_scanOriginOffset(int endOffset, bool bullishPivot, int maxScan) =>
    int originOffset = endOffset
    for k = endOffset + 1 to endOffset + maxScan
        if bullishPivot and isBearBody(k)
            originOffset := k
        else if not bullishPivot and isBullBody(k)
            originOffset := k
        else
            break
    originOffset

_scanRunExtreme(int pivotOffset, int originOffset, bool bullishPivot) =>
    int   runExtOff = pivotOffset
    float runExtPx  = bullishPivot ? low[pivotOffset] : high[pivotOffset]
    for k = pivotOffset to originOffset
        if bullishPivot
            if low[k] < runExtPx
                runExtPx  := low[k]
                runExtOff := k
        else
            if high[k] > runExtPx
                runExtPx  := high[k]
                runExtOff := k
    [runExtOff, runExtPx]

computeInitialStretch(bool bullishPivot, int pivotOffset, bool sizeFilter, float atrMult) =>
    int endOffset = _scanEndOffset(pivotOffset, bullishPivot, SCAN_MAX_BARS)
    if endOffset == -1
        [0, 0.0, 0, 0.0, false, 0.0, 0.0, 0, 0.0]
    else
        int originOffset = _scanOriginOffset(endOffset, bullishPivot, SCAN_MAX_BARS)
        [runExtOff, runExtPx] = _scanRunExtreme(pivotOffset, originOffset, bullishPivot)
        float stretchBodySize = math.abs(open[originOffset] - close[endOffset])
        float minStretchSize  = cisd_atr * atrMult
        bool  passesFilter    = sizeFilter ? stretchBodySize >= minStretchSize : true
        [originOffset, open[originOffset], endOffset, close[endOffset], passesFilter,
         high[originOffset], low[originOffset], runExtOff, runExtPx]

recomputeStretchIfExtended(PendingCISD p) =>
    _bull = p.stretch.bullish
    if _bull and isBearBody(0) and close < p.stretch.end_close
        float newExtPx  = math.min(p.stretch.run_ext_price, low)
        int   newExtBar = low < p.stretch.run_ext_price ? bar_index : p.stretch.run_ext_bar
        [true, p.stretch.origin_bar, p.stretch.level, bar_index, close, newExtBar, newExtPx]
    else if (not _bull) and isBullBody(0) and close > p.stretch.end_close
        float newExtPx  = math.max(p.stretch.run_ext_price, high)
        int   newExtBar = high > p.stretch.run_ext_price ? bar_index : p.stretch.run_ext_bar
        [false, p.stretch.origin_bar, p.stretch.level, bar_index, close, newExtBar, newExtPx]
    else
        [false, p.stretch.origin_bar, p.stretch.level, p.stretch.end_bar,
         p.stretch.end_close, p.stretch.run_ext_bar, p.stretch.run_ext_price]

// =============================================================================
// FIB RENDER
// =============================================================================

var array<float>  FIB_MULTS = array.from(0.0, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5)
var array<string> FIB_TEXTS = array.from('', '', '-0.5', '-1', '-1.5', '-2', '-2.5', '-3', '-3.5', '-4', '-4.5')
var array<bool>   FIB_ON    = array.from(true, true,
     cisd_fib_n05, cisd_fib_n10, cisd_fib_n15, cisd_fib_n20,
     cisd_fib_n25, cisd_fib_n30, cisd_fib_n35, cisd_fib_n40, cisd_fib_n45)
var array<color>  FIB_COL   = array.from(
     color.new(#4a4a4a, 50), color.new(#4a4a4a, 50),
     cisd_fib_n05_color, cisd_fib_n10_color, cisd_fib_n15_color, cisd_fib_n20_color,
     cisd_fib_n25_color, cisd_fib_n30_color, cisd_fib_n35_color, cisd_fib_n40_color, cisd_fib_n45_color)

renderCISDFibs(ConfirmedCISD ci, bool useWick) =>
    CISDFibProjection result = na
    bool isBullishCISD = ci.stretch.bullish
    float originPrice = na
    float endPrice    = na
    if useWick
        originPrice := isBullishCISD ? ci.stretch.origin_high : ci.stretch.origin_low
        endPrice    := ci.stretch.run_ext_price
    else
        originPrice := ci.stretch.level
        endPrice    := ci.stretch.end_close
    float stretchRange = endPrice - originPrice
    float fibDirection = -stretchRange
    int startBar = ci.stretch.origin_bar
    int endBar   = ci.confirmation_bar
    array<line>  fibLines  = array.new<line>()
    array<label> fibLabels = array.new<label>()
    color transpColor = color.new(#ffffff, 100)
    int n = array.size(FIB_MULTS)
    for i = 0 to n - 1
        if array.get(FIB_ON, i)
            float mult   = array.get(FIB_MULTS, i)
            string txt   = array.get(FIB_TEXTS, i)
            color  col   = array.get(FIB_COL, i)
            float  price = endPrice + fibDirection * mult
            line ln = line.new(startBar, price, endBar, price, color = col, style = line.style_solid, width = 1)
            array.push(fibLines, ln)
            if txt != ''
                label lbl = label.new(startBar, price, txt, color = transpColor,
                     style = label.style_label_right, textcolor = col,
                     size = size.tiny, textalign = text.align_center)
                array.push(fibLabels, lbl)
    result := CISDFibProjection.new(ci.pivot_bar, isBullishCISD, fibLines, fibLabels,
                                    confirmation_bar = ci.confirmation_bar, confirmation_time = time)
    result

// =============================================================================
// DEBUG HELPERS
// =============================================================================

dbgTag(string tag, string msg) =>
    if debug_mode
        log.info("[" + tag + "] bar=" + str.tostring(bar_index) + " :: " + msg)

dbgMsg(string msg) =>
    if debug_mode
        log.info(msg)

// =============================================================================
// CISD MAIN
// =============================================================================

float pivotHigh = ta.pivothigh(pivot_len, pivot_len)
float pivotLow  = ta.pivotlow(pivot_len, pivot_len)

addPivot(float level, float price, bool isHigh, array<PivotData> arr) =>
    if bool(level)
        array.push(arr, PivotData.new(bar_index - pivot_len, price, isHigh, false))

addPivot(pivotHigh, high[pivot_len], true,  pivot_highs)
addPivot(pivotLow,  low[pivot_len],  false, pivot_lows)

if debug_mode and bool(pivotHigh)
    dbg_pivH_cnt += 1
    dbgTag("PIVOT-H", "H#" + str.tostring(dbg_pivH_cnt) +
           " price=" + str.tostring(high[pivot_len], "#.#####") +
           " pivotBar=" + str.tostring(bar_index - pivot_len))

if debug_mode and bool(pivotLow)
    dbg_pivL_cnt += 1
    dbgTag("PIVOT-L", "L#" + str.tostring(dbg_pivL_cnt) +
           " price=" + str.tostring(low[pivot_len], "#.#####") +
           " pivotBar=" + str.tostring(bar_index - pivot_len))

// Pivot purge — high crossed (chart)
if pivot_delete_on_cross and array.size(pivot_highs) > 0
    for i = array.size(pivot_highs) - 1 to 0
        pd = array.get(pivot_highs, i)
        if high > pd.price
            array.push(purge_tracker, PurgeTracker.new(pd.bar_idx, true, bar_index))
            pd.has_purge := true
            array.remove(pivot_highs, i)
            if inp_cisd_show
                if cisd_exhaustive
                    if array.size(confirmed_cisd) > 0
                        for j = array.size(confirmed_cisd) - 1 to 0
                            ci = array.get(confirmed_cisd, j)
                            if ci.pivot_bar == pd.bar_idx and not ci.stretch.bullish and not ci.is_invalidated
                                ci.is_invalidated := true
                                line.set_style(ci.confirmed_line, line.style_dashed)
                                line.set_width(ci.confirmed_line, LW_INVALIDATED)
                    if array.size(pending_cisd) > 0
                        for j = array.size(pending_cisd) - 1 to 0
                            item = array.get(pending_cisd, j)
                            if item.pivot_bar == pd.bar_idx and not item.stretch.bullish
                                line.delete(item.pending_line)
                                array.remove(pending_cisd, j)
                else
                    removeCISDByPivotBar(pd.bar_idx, false)

// Pivot purge — low crossed (chart)
if pivot_delete_on_cross and array.size(pivot_lows) > 0
    for i = array.size(pivot_lows) - 1 to 0
        pd = array.get(pivot_lows, i)
        if low < pd.price
            array.push(purge_tracker, PurgeTracker.new(pd.bar_idx, false, bar_index))
            pd.has_purge := true
            array.remove(pivot_lows, i)
            if inp_cisd_show
                if cisd_exhaustive
                    if array.size(confirmed_cisd) > 0
                        for j = array.size(confirmed_cisd) - 1 to 0
                            ci = array.get(confirmed_cisd, j)
                            if ci.pivot_bar == pd.bar_idx and ci.stretch.bullish and not ci.is_invalidated
                                ci.is_invalidated := true
                                line.set_style(ci.confirmed_line, line.style_dashed)
                                line.set_width(ci.confirmed_line, LW_INVALIDATED)
                    if array.size(pending_cisd) > 0
                        for j = array.size(pending_cisd) - 1 to 0
                            item = array.get(pending_cisd, j)
                            if item.pivot_bar == pd.bar_idx and item.stretch.bullish
                                line.delete(item.pending_line)
                                array.remove(pending_cisd, j)
                else
                    removeCISDByPivotBar(pd.bar_idx, true)

// Confirmed invalidation (chart)
if inp_cisd_show and cisd_invalidate_on_cross and array.size(confirmed_cisd) > 0
    for i = array.size(confirmed_cisd) - 1 to 0
        ci = array.get(confirmed_cisd, i)
        if ci.is_invalidated
            continue
        bool shouldRemove = false
        if ci.stretch.bullish and low < ci.pivot_price
            shouldRemove := true
        else if not ci.stretch.bullish and high > ci.pivot_price
            shouldRemove := true
        if shouldRemove
            if cisd_exhaustive
                ci.is_invalidated := true
                line.set_style(ci.confirmed_line, line.style_dashed)
                line.set_width(ci.confirmed_line, LW_INVALIDATED)
                removeFibProjectionByPivotBar(ci.pivot_bar, ci.stretch.bullish)
            else
                line.delete(ci.confirmed_line)
                label.delete(ci.confirm_shape)
                if not na(ci.tf_label)
                    label.delete(ci.tf_label)
                if not na(ci.analytics_label)
                    label.delete(ci.analytics_label)
                array.remove(confirmed_cisd, i)
                removeFibProjectionByPivotBar(ci.pivot_bar, ci.stretch.bullish)

// New bearish CISD (chart)
if inp_cisd_show and bool(pivotHigh) and BIAS_BEAR
    [originOff, lvl, endOff, endCls, passesFilter, origH, origL, runExtOff, runExtPx] =
         computeInitialStretch(false, pivot_len, cisd_size_filter, cisd_atr_mult)
    origin_bar  = bar_index - originOff
    end_bar     = bar_index - endOff
    run_ext_bar = bar_index - runExtOff
    pivot_bar   = bar_index - pivot_len
    purge_ok    = not cisd_purge_filter or hasPurgeForCISD(pivot_bar, false, cisd_purge_tolerance)
    if passesFilter and purge_ok
        if array.size(pending_cisd) > 0
            for ii = array.size(pending_cisd) - 1 to 0
                it = array.get(pending_cisd, ii)
                if not it.stretch.bullish
                    line.delete(it.pending_line)
                    array.remove(pending_cisd, ii)
        ln = line.new(origin_bar, lvl, bar_index, lvl, color = cisd_color_bear,
                      style = line.style_dotted, width = LW_CHART)
        st = CISDStretch.new(false, origin_bar, lvl, end_bar, endCls, origH, origL, run_ext_bar, runExtPx)
        array.push(pending_cisd, PendingCISD.new(st, pivot_bar, bar_index, ln))
        if debug_mode
            dbg_pend_created += 1
            dbgTag("PEND-BEAR", "P#" + str.tostring(dbg_pend_created))

// New bullish CISD (chart)
if inp_cisd_show and bool(pivotLow) and BIAS_BULL
    [originOffB, lvlB, endOffB, endClsB, passesFilterB, origHB, origLB, runExtOffB, runExtPxB] =
         computeInitialStretch(true, pivot_len, cisd_size_filter, cisd_atr_mult)
    origin_bar_b  = bar_index - originOffB
    end_bar_b     = bar_index - endOffB
    run_ext_bar_b = bar_index - runExtOffB
    pivot_bar_b   = bar_index - pivot_len
    purge_ok_b    = not cisd_purge_filter or hasPurgeForCISD(pivot_bar_b, true, cisd_purge_tolerance)
    if passesFilterB and purge_ok_b
        if array.size(pending_cisd) > 0
            for ii = array.size(pending_cisd) - 1 to 0
                it = array.get(pending_cisd, ii)
                if it.stretch.bullish
                    line.delete(it.pending_line)
                    array.remove(pending_cisd, ii)
        lnB = line.new(origin_bar_b, lvlB, bar_index, lvlB, color = cisd_color_bull,
                       style = line.style_dotted, width = LW_CHART)
        stB = CISDStretch.new(true, origin_bar_b, lvlB, end_bar_b, endClsB, origHB, origLB, run_ext_bar_b, runExtPxB)
        array.push(pending_cisd, PendingCISD.new(stB, pivot_bar_b, bar_index, lnB))
        if debug_mode
            dbg_pend_created += 1
            dbgTag("PEND-BULL", "P#" + str.tostring(dbg_pend_created))

// Pending CISD — timeout + extend + confirm (chart)
if inp_cisd_show and array.size(pending_cisd) > 0
    for i = array.size(pending_cisd) - 1 to 0
        p = array.get(pending_cisd, i)

        if bar_index - p.start_bar >= cisd_pending_timeout
            line.delete(p.pending_line)
            array.remove(pending_cisd, i)
            continue

        [updated, new_origin_bar, new_level, new_end_bar, new_end_close, new_run_ext_bar, new_run_ext_price] =
             recomputeStretchIfExtended(p)
        if updated
            line.set_x1(p.pending_line, new_origin_bar)
            line.set_y1(p.pending_line, new_level)
            line.set_y2(p.pending_line, new_level)
            p.stretch.origin_bar    := new_origin_bar
            p.stretch.level         := new_level
            p.stretch.end_bar       := new_end_bar
            p.stretch.end_close     := new_end_close
            p.stretch.run_ext_bar   := new_run_ext_bar
            p.stretch.run_ext_price := new_run_ext_price
            array.set(pending_cisd, i, p)
        line.set_x2(p.pending_line, bar_index)

        bool confirm_ok = p.stretch.bullish ? close > p.stretch.level : close < p.stretch.level
        if not confirm_ok
            continue

        float stretchATR = math.abs(p.stretch.level - p.stretch.end_close) /
                           math.max(cisd_atr, syminfo.mintick)
        int   confirmSpeed = bar_index - p.start_bar
        bool  hasPurgeActual = hasPurgeForCISD(p.pivot_bar, p.stretch.bullish, cisd_purge_tolerance)
        bool  mtfAligned = htfCorr > 0.5
        float prob = adv_enabled and adv_use_bayes ?
             bayesianScore(stretchATR, hasPurgeActual, mtfAligned, inKillzone, relVolume) : 0.5
        int   quality = adv_enabled ?
             signalQuality(stretchATR, confirmSpeed, hasPurgeActual, mtfAligned, htfCorr) : 100
        bool passes_filter = not adv_enabled or quality >= adv_min_quality

        if dedupe_same_level
            float levelTol = syminfo.mintick * 2
            int removedCnt = removeConfirmedCISDsAtLevel(p.stretch.level, p.stretch.bullish, levelTol)
            if debug_mode and removedCnt > 0
                dbg_dup_removed += removedCnt

        x1_c = p.stretch.origin_bar
        x2_c = bar_index + cisd_offset
        y_c  = p.stretch.level
        bool isProp = isPropulsionBlock(p.stretch.bullish, p.stretch.run_ext_price,
                                         p.stretch.run_ext_bar, cisd_pending_timeout)
        cisdColor = p.stretch.bullish ? cisd_color_bull : cisd_color_bear
        int confirmWidth = isProp ? LW_WEAK : LW_CHART

        ln_c = line.new(x1_c, y_c, x2_c, y_c, color = cisdColor,
                        style = line.style_solid, width = confirmWidth)
        yloc_ = p.stretch.bullish ? yloc.belowbar : yloc.abovebar
        shp = label.new(bar_index, close, style = label.style_circle, text = '',
                        size = size.auto, color = C_TRANSPARENT, textcolor = cisdColor, yloc = yloc_)

        label analyticsLbl = na
        if adv_enabled and adv_show_analytics
            string infoTxt = passes_filter ?
                 "Q" + str.tostring(quality) + " · P" + str.tostring(math.round(prob * 100)) + "%" :
                 "P" + str.tostring(math.round(prob * 100)) + "%"
            float labelOffset = cisd_atr * label_offset_mult
            analyticsLbl := label.new(x2_c + 1, y_c + labelOffset, infoTxt,
                                      style     = label.style_label_left,
                                      color     = color.new(color.black, 75),
                                      textcolor = cisdColor,
                                      size      = size.tiny,
                                      textalign = text.align_left)

        float pivotPriceForCISD = p.stretch.bullish ?
             low[bar_index - p.pivot_bar] : high[bar_index - p.pivot_bar]
        ci = ConfirmedCISD.new(p.stretch, p.pivot_bar, pivotPriceForCISD, bar_index,
                                ln_c, shp, analytics_label = analyticsLbl)
        array.push(confirmed_cisd, ci)

        if cisd_fib_show and not isProp
            bool fib_spacing_ok = true
            if timeframe.in_seconds() < 3600
                int lastFibTime = mostRecentFibTime(p.stretch.bullish)
                if lastFibTime > 0 and time - lastFibTime < CISD_FIB_MIN_SPACING_MS
                    fib_spacing_ok := false
            if fib_spacing_ok
                useWick = cisd_fib_mode == 'Wick'
                fibProj = renderCISDFibs(ci, useWick)
                if not na(fibProj)
                    array.push(cisd_fib_projections, fibProj)
                    enforceFibMax(cisd_fib_max)

        line.delete(p.pending_line)
        array.remove(pending_cisd, i)

while array.size(purge_tracker) > PURGE_TRACKER_MAX
    array.shift(purge_tracker)

// =============================================================================
// MTF CISD ENGINE
// =============================================================================

mtfComputeStretch(bool bullishPivot, int pivIdx, bool sizeFilter, float atrMult) =>
    int maxScan = math.min(SCAN_MAX_BARS, pivIdx)
    int endIdx    = -1
    int originIdx = -1
    if bullishPivot
        for off = 1 to maxScan
            int k = pivIdx - off
            if k < 0
                break
            if array.get(htf_c, k) < array.get(htf_o, k)
                endIdx := k
                break
        if endIdx >= 0
            originIdx := endIdx
            for off = 1 to maxScan
                int k = endIdx - off
                if k < 0
                    break
                if array.get(htf_c, k) < array.get(htf_o, k)
                    originIdx := k
                else
                    break
    else
        for off = 1 to maxScan
            int k = pivIdx - off
            if k < 0
                break
            if array.get(htf_c, k) > array.get(htf_o, k)
                endIdx := k
                break
        if endIdx >= 0
            originIdx := endIdx
            for off = 1 to maxScan
                int k = endIdx - off
                if k < 0
                    break
                if array.get(htf_c, k) > array.get(htf_o, k)
                    originIdx := k
                else
                    break
    int   runExtIdx = pivIdx
    float runExtPx  = bullishPivot ? array.get(htf_l, pivIdx) : array.get(htf_h, pivIdx)
    if endIdx >= 0 and originIdx >= 0
        for k = originIdx to pivIdx
            float v = bullishPivot ? array.get(htf_l, k) : array.get(htf_h, k)
            bool better = bullishPivot ? v < runExtPx : v > runExtPx
            if better
                runExtPx  := v
                runExtIdx := k
    float stretchBody = (endIdx >= 0 and originIdx >= 0) ?
         math.abs(array.get(htf_o, originIdx) - array.get(htf_c, endIdx)) : 0.0
    float atrNow = array.get(htf_av, pivIdx)
    bool  passes = endIdx >= 0 and originIdx >= 0 and (sizeFilter ? stretchBody >= atrNow * atrMult : true)
    [originIdx, endIdx, passes, runExtIdx, runExtPx]

if new_htf_bar
    array.push(htf_o,  htf_o_v[1])
    array.push(htf_h,  htf_h_v[1])
    array.push(htf_l,  htf_l_v[1])
    array.push(htf_c,  htf_c_v[1])
    array.push(htf_bi, bar_index[1])
    array.push(htf_av, htf_atr_v[1])
    htf_bar_count += 1
    if array.size(htf_o) > HTF_CACHE_MAX
        array.shift(htf_o)
        array.shift(htf_h)
        array.shift(htf_l)
        array.shift(htf_c)
        array.shift(htf_bi)
        array.shift(htf_av)
    int nH = array.size(htf_h)
    int nMin = nH
    if nMin >= pivot_len * 2 + 1
        int pivIdx = nMin - 1 - pivot_len
        if pivIdx + pivot_len <= nMin - 1 and pivIdx - pivot_len >= 0
            float pivH  = array.get(htf_h, pivIdx)
            float pivL  = array.get(htf_l, pivIdx)
            bool isPivH = true
            bool isPivL = true
            for k = 1 to pivot_len
                int idxUp = pivIdx + k
                int idxDn = pivIdx - k
                if idxUp > nMin - 1 or idxDn < 0
                    break
                if array.get(htf_h, idxDn) >= pivH or array.get(htf_h, idxUp) >= pivH
                    isPivH := false
                if array.get(htf_l, idxDn) <= pivL or array.get(htf_l, idxUp) <= pivL
                    isPivL := false
            if isPivH and BIAS_BEAR
                [oIdx, eIdx, passes, reIdx, rePx] = mtfComputeStretch(false, pivIdx, mtf_size_filter, cisd_atr_mult)
                if passes and oIdx >= 0 and eIdx >= 0 and reIdx >= 0
                    int   lineStart = array.get(htf_bi, oIdx)
                    float lvl       = array.get(htf_o, oIdx)
                    if array.size(mtf_pending) > 0
                        for ii = array.size(mtf_pending) - 1 to 0
                            it = array.get(mtf_pending, ii)
                            if not it.stretch.bullish
                                line.delete(it.pending_line)
                                array.remove(mtf_pending, ii)
                    ln = line.new(lineStart, lvl, bar_index, lvl, color = mtf_color_bear,
                                  style = line.style_dotted, width = LW_MTF)
                    st = CISDStretch.new(false, lineStart, lvl,
                                         array.get(htf_bi, eIdx), array.get(htf_c, eIdx),
                                         array.get(htf_h, oIdx), array.get(htf_l, oIdx),
                                         array.get(htf_bi, reIdx), rePx)
                    array.push(mtf_pending, MTFPending.new(st, array.get(htf_bi, pivIdx), pivH, htf_bar_count, ln))
            if isPivL and BIAS_BULL
                [oIdxB, eIdxB, passesB, reIdxB, rePxB] = mtfComputeStretch(true, pivIdx, mtf_size_filter, cisd_atr_mult)
                if passesB and oIdxB >= 0 and eIdxB >= 0 and reIdxB >= 0
                    int   lineStartB = array.get(htf_bi, oIdxB)
                    float lvlB       = array.get(htf_o, oIdxB)
                    if array.size(mtf_pending) > 0
                        for ii = array.size(mtf_pending) - 1 to 0
                            it = array.get(mtf_pending, ii)
                            if it.stretch.bullish
                                line.delete(it.pending_line)
                                array.remove(mtf_pending, ii)
                    lnB = line.new(lineStartB, lvlB, bar_index, lvlB, color = mtf_color_bull,
                                   style = line.style_dotted, width = LW_MTF)
                    stB = CISDStretch.new(true, lineStartB, lvlB,
                                          array.get(htf_bi, eIdxB), array.get(htf_c, eIdxB),
                                          array.get(htf_h, oIdxB), array.get(htf_l, oIdxB),
                                          array.get(htf_bi, reIdxB), rePxB)
                    array.push(mtf_pending, MTFPending.new(stB, array.get(htf_bi, pivIdx), pivL, htf_bar_count, lnB))

if mtf_enable and new_htf_bar and array.size(mtf_pending) > 0
    for i = array.size(mtf_pending) - 1 to 0
        p = array.get(mtf_pending, i)
        if htf_bar_count - p.start_htf_count >= mtf_pending_to
            line.delete(p.pending_line)
            array.remove(mtf_pending, i)
            continue
        if array.size(htf_c) > 0
            float lastClose = array.get(htf_c, array.size(htf_c) - 1)
            bool confirm_ok = p.stretch.bullish ? lastClose > p.stretch.level : lastClose < p.stretch.level
            if confirm_ok
                int   x1_c = p.stretch.origin_bar
                int   x2_c = bar_index + mtf_offset
                float y_c  = p.stretch.level
                color cCol = p.stretch.bullish ? mtf_color_bull : mtf_color_bear
                ln_c = line.new(x1_c, y_c, x2_c, y_c, color = cCol, style = line.style_solid, width = LW_MTF)
                yloc_ = p.stretch.bullish ? yloc.belowbar : yloc.abovebar
                shp = label.new(bar_index, lastClose, style = label.style_circle, text = '',
                                size = size.auto, color = C_TRANSPARENT, textcolor = cCol, yloc = yloc_)
                label tf_lbl = na
                // ✅ TF label is no longer drawn separately; TF info is embedded into the score label.
                label mtfAnalyticsLbl = na
                if adv_enabled and adv_show_analytics
                    float stretchATR_mtf = math.abs(p.stretch.level - p.stretch.end_close) /
                                           math.max(cisd_atr, syminfo.mintick)
                    bool  hasPurge_mtf   = hasPurgeForCISD(p.pivot_chart_bar, p.stretch.bullish, cisd_purge_tolerance)
                    float prob_mtf       = adv_use_bayes ?
                         bayesianScore(stretchATR_mtf, hasPurge_mtf, true, inKillzone, relVolume) : 0.5
                    int   quality_mtf    = signalQuality(stretchATR_mtf, 5, hasPurge_mtf, true, 0.8)
                    string infoTxt_mtf = "Q" + str.tostring(quality_mtf) + " · P" + str.tostring(math.round(prob_mtf * 100)) + "%"
                    // ✅ When Show TF Label is enabled, the TF string is prefixed to the score label
                    if mtf_show_tf_label
                        infoTxt_mtf := mtf_tf + " · " + infoTxt_mtf
                    float baseOffset = cisd_atr * label_offset_mult
                    float mtfOffset  = baseOffset
                    mtfAnalyticsLbl := label.new(x2_c + 1, y_c + mtfOffset, infoTxt_mtf,
                                                 style     = label.style_label_left,
                                                 color     = color.new(color.black, 75),
                                                 textcolor = cCol,
                                                 size      = size.tiny,
                                                 textalign = text.align_left)
                ci = ConfirmedCISD.new(p.stretch, p.pivot_chart_bar, p.pivot_price, bar_index,
                                        ln_c, shp, tf_lbl, mtfAnalyticsLbl)
                array.push(mtf_confirmed, ci)
                line.delete(p.pending_line)
                array.remove(mtf_pending, i)

fifoTrimMTF(bool isBull, int maxPerDir) =>
    int cnt = 0
    int oldestIdx = -1
    int oldestBar = 2147483647
    for i = 0 to array.size(mtf_confirmed) - 1
        ci = array.get(mtf_confirmed, i)
        if ci.stretch.bullish == isBull
            cnt += 1
            if ci.confirmation_bar < oldestBar
                oldestBar := ci.confirmation_bar
                oldestIdx := i
    if cnt > maxPerDir and oldestIdx >= 0
        ci = array.get(mtf_confirmed, oldestIdx)
        line.delete(ci.confirmed_line)
        label.delete(ci.confirm_shape)
        if not na(ci.tf_label)
            label.delete(ci.tf_label)
        if not na(ci.analytics_label)
            label.delete(ci.analytics_label)
        array.remove(mtf_confirmed, oldestIdx)

if mtf_enable and array.size(mtf_confirmed) > 0
    int safety = 0
    while mtf_enable and array.size(mtf_confirmed) > 0 and safety < 200
        int cntBull = 0
        int cntBear = 0
        for i = 0 to array.size(mtf_confirmed) - 1
            ci = array.get(mtf_confirmed, i)
            if ci.stretch.bullish
                cntBull += 1
            else
                cntBear += 1
        bool trimmed = false
        if cntBull > mtf_max_cisd
            fifoTrimMTF(true, mtf_max_cisd)
            trimmed := true
        if cntBear > mtf_max_cisd
            fifoTrimMTF(false, mtf_max_cisd)
            trimmed := true
        if not trimmed
            break
        safety += 1

if mtf_enable and array.size(mtf_confirmed) > 0
    for i = array.size(mtf_confirmed) - 1 to 0
        ci = array.get(mtf_confirmed, i)
        bool removeIt = false
        if ci.stretch.bullish and low < ci.pivot_price
            removeIt := true
        else if not ci.stretch.bullish and high > ci.pivot_price
            removeIt := true
        if removeIt
            line.delete(ci.confirmed_line)
            label.delete(ci.confirm_shape)
            if not na(ci.tf_label)
                label.delete(ci.tf_label)
            if not na(ci.analytics_label)
                label.delete(ci.analytics_label)
            array.remove(mtf_confirmed, i)

// =============================================================================
// SYMBOL CISD ENGINE
// =============================================================================

symComputeStretch(bool bullishPivot, int pivIdx, bool sizeFilter, float atrMult) =>
    int maxScan = math.min(SCAN_MAX_BARS, pivIdx)
    int endIdx    = -1
    int originIdx = -1
    if bullishPivot
        for off = 1 to maxScan
            int k = pivIdx - off
            if k < 0
                break
            if array.get(sym_c, k) < array.get(sym_o, k)
                endIdx := k
                break
        if endIdx >= 0
            originIdx := endIdx
            for off = 1 to maxScan
                int k = endIdx - off
                if k < 0
                    break
                if array.get(sym_c, k) < array.get(sym_o, k)
                    originIdx := k
                else
                    break
    else
        for off = 1 to maxScan
            int k = pivIdx - off
            if k < 0
                break
            if array.get(sym_c, k) > array.get(sym_o, k)
                endIdx := k
                break
        if endIdx >= 0
            originIdx := endIdx
            for off = 1 to maxScan
                int k = endIdx - off
                if k < 0
                    break
                if array.get(sym_c, k) > array.get(sym_o, k)
                    originIdx := k
                else
                    break
    int   runExtIdx = pivIdx
    float runExtPx  = bullishPivot ? array.get(sym_l, pivIdx) : array.get(sym_h, pivIdx)
    if endIdx >= 0 and originIdx >= 0
        for k = originIdx to pivIdx
            float v = bullishPivot ? array.get(sym_l, k) : array.get(sym_h, k)
            bool better = bullishPivot ? v < runExtPx : v > runExtPx
            if better
                runExtPx  := v
                runExtIdx := k
    float stretchBody = (endIdx >= 0 and originIdx >= 0) ?
         math.abs(array.get(sym_o, originIdx) - array.get(sym_c, endIdx)) : 0.0
    float atrNow = array.get(sym_av, pivIdx)
    bool  passes = endIdx >= 0 and originIdx >= 0 and (sizeFilter ? stretchBody >= atrNow * atrMult : true)
    [originIdx, endIdx, passes, runExtIdx, runExtPx]

deleteSymMark(SymbolCISDMark m) =>
    if not na(m.left_tick)
        line.delete(m.left_tick)
    if not na(m.right_tick)
        line.delete(m.right_tick)
    if not na(m.base_line)
        line.delete(m.base_line)
    if not na(m.confirm_mark)
        label.delete(m.confirm_mark)
    if not na(m.ticker_lbl)
        label.delete(m.ticker_lbl)
    true

countActiveMarks(bool isBull) =>
    int c = 0
    if array.size(sym_marks) > 0
        for i = 0 to array.size(sym_marks) - 1
            m = array.get(sym_marks, i)
            if m.bullish == isBull
                c += 1
    c

if new_sym_bar
    array.push(sym_o,  sym_o_v[1])
    array.push(sym_h,  sym_h_v[1])
    array.push(sym_l,  sym_l_v[1])
    array.push(sym_c,  sym_c_v[1])
    array.push(sym_bi, bar_index[1])
    array.push(sym_av, sym_atr_v[1])
    array.push(sym_t,  sym_t_v[1])
    sym_bar_count += 1

    if array.size(sym_o) > HTF_CACHE_MAX
        array.shift(sym_o)
        array.shift(sym_h)
        array.shift(sym_l)
        array.shift(sym_c)
        array.shift(sym_bi)
        array.shift(sym_av)
        array.shift(sym_t)

    int snH = array.size(sym_h)
    int snL = array.size(sym_l)
    int snC = array.size(sym_c)
    int snO = array.size(sym_o)
    int snB = array.size(sym_bi)
    int snA = array.size(sym_av)
    int snT = array.size(sym_t)
    int snMin = math.min(math.min(math.min(snH, snL), math.min(snC, snO)), math.min(math.min(snB, snA), snT))

    if snMin >= pivot_len * 2 + 1
        int spivIdx = snMin - 1 - pivot_len
        if spivIdx + pivot_len <= snMin - 1 and spivIdx - pivot_len >= 0
            float spivH  = array.get(sym_h, spivIdx)
            float spivL  = array.get(sym_l, spivIdx)
            bool isSPivH = true
            bool isSPivL = true
            for k = 1 to pivot_len
                int idxUp = spivIdx + k
                int idxDn = spivIdx - k
                if idxUp > snMin - 1 or idxDn < 0
                    break
                if array.get(sym_h, idxDn) >= spivH or array.get(sym_h, idxUp) >= spivH
                    isSPivH := false
                if array.get(sym_l, idxDn) <= spivL or array.get(sym_l, idxUp) <= spivL
                    isSPivL := false

            if isSPivH
                array.push(sym_pivot_highs, PivotData.new(array.get(sym_bi, spivIdx), spivH, true, false))
            if isSPivL
                array.push(sym_pivot_lows, PivotData.new(array.get(sym_bi, spivIdx), spivL, false, false))

            if isSPivH and BIAS_BEAR
                [soIdx, seIdx, sPasses, sreIdx, srePx] = symComputeStretch(false, spivIdx, cisd_size_filter, sym_atr_mult)
                if sPasses and soIdx >= 0 and seIdx >= 0 and sreIdx >= 0
                    int   sLineStart = array.get(sym_bi, soIdx)
                    float sLvl       = array.get(sym_o, soIdx)
                    int   sPivBar    = array.get(sym_bi, spivIdx)
                    bool  sPurgeOk   = not cisd_purge_filter or hasSymPurgeForCISD(sPivBar, false, cisd_purge_tolerance)
                    if sPurgeOk
                        if array.size(sym_pending) > 0
                            for ii = array.size(sym_pending) - 1 to 0
                                it = array.get(sym_pending, ii)
                                if not it.stretch.bullish
                                    array.remove(sym_pending, ii)
                        sSt = CISDStretch.new(false, sLineStart, sLvl,
                                              array.get(sym_bi, seIdx), array.get(sym_c, seIdx),
                                              array.get(sym_h, soIdx), array.get(sym_l, soIdx),
                                              array.get(sym_bi, sreIdx), srePx)
                        array.push(sym_pending, SymbolPending.new(sSt, sPivBar, spivH, sym_bar_count))

            if isSPivL and BIAS_BULL
                [soIdxB, seIdxB, sPassesB, sreIdxB, srePxB] = symComputeStretch(true, spivIdx, cisd_size_filter, sym_atr_mult)
                if sPassesB and soIdxB >= 0 and seIdxB >= 0 and sreIdxB >= 0
                    int   sLineStartB = array.get(sym_bi, soIdxB)
                    float sLvlB       = array.get(sym_o, soIdxB)
                    int   sPivBarB    = array.get(sym_bi, spivIdx)
                    bool  sPurgeOkB   = not cisd_purge_filter or hasSymPurgeForCISD(sPivBarB, true, cisd_purge_tolerance)
                    if sPurgeOkB
                        if array.size(sym_pending) > 0
                            for ii = array.size(sym_pending) - 1 to 0
                                it = array.get(sym_pending, ii)
                                if it.stretch.bullish
                                    array.remove(sym_pending, ii)
                        sStB = CISDStretch.new(true, sLineStartB, sLvlB,
                                               array.get(sym_bi, seIdxB), array.get(sym_c, seIdxB),
                                               array.get(sym_h, soIdxB), array.get(sym_l, soIdxB),
                                               array.get(sym_bi, sreIdxB), srePxB)
                        array.push(sym_pending, SymbolPending.new(sStB, sPivBarB, spivL, sym_bar_count))

    if array.size(sym_h) > 0 and array.size(sym_l) > 0
        int lastIdxS = array.size(sym_h) - 1
        float lastHS = array.get(sym_h, lastIdxS)
        float lastLS = array.get(sym_l, lastIdxS)
        int lastBS = array.get(sym_bi, lastIdxS)

        if pivot_delete_on_cross and array.size(sym_pivot_highs) > 0
            for j = array.size(sym_pivot_highs) - 1 to 0
                pd = array.get(sym_pivot_highs, j)
                if lastHS > pd.price
                    array.push(sym_purge_tracker, PurgeTracker.new(pd.bar_idx, true, lastBS))
                    pd.has_purge := true
                    array.remove(sym_pivot_highs, j)

        if pivot_delete_on_cross and array.size(sym_pivot_lows) > 0
            for j = array.size(sym_pivot_lows) - 1 to 0
                pd = array.get(sym_pivot_lows, j)
                if lastLS < pd.price
                    array.push(sym_purge_tracker, PurgeTracker.new(pd.bar_idx, false, lastBS))
                    pd.has_purge := true
                    array.remove(sym_pivot_lows, j)

// =============================================================================
// SYMBOL PENDING CONFIRMATION (U/bracket)
// ✅ Overlap avoidance is always ON:
//    - U line is 3 ticks thick
//    - U legs are pushed 2 ticks away from the bars
//    - U baseline is pushed further away from the bars (baseLineExtra)
//    - Circle marker (endpoint) uses size.auto
// ✅ Label mode dropdown:
//    Off / Ticker Only / TF Only (default) / Ticker + TF
// ✅ U-line colors are separate inputs:
//    Bull = color.rgb(4, 250, 0, 20)  /  Bear = color.rgb(250, 4, 0, 20)
// ✅ Ticker label color matches the U line (uCol); the text color is fixed to
//    BLACK (color.black) for readability.
// =============================================================================
if new_sym_bar and array.size(sym_pending) > 0
    for i = array.size(sym_pending) - 1 to 0
        p = array.get(sym_pending, i)
        if sym_bar_count - p.start_sym_count >= cisd_pending_timeout
            array.remove(sym_pending, i)
            continue
        if array.size(sym_c) > 0
            float sLastClose = array.get(sym_c, array.size(sym_c) - 1)
            bool sConfirmOk = p.stretch.bullish ? sLastClose > p.stretch.level : sLastClose < p.stretch.level
            if sConfirmOk
                // ✅ U-line (bracket) colors — bright green / bright red
                color uCol = p.stretch.bullish ? sym_u_col_bull : sym_u_col_bear
                // ✅ Ticker label text color — fixed to black for readability
                color sCol = color.black

                int t1 = time[1]
                int t2 = time
                if array.size(sym_t) >= 1
                    t1 := array.get(sym_t, array.size(sym_t) - 1)
                t2 := sym_t_v

                // ✅ Find chart bars covering t1 and t2
                int  maxK   = math.min(SYM_RANGE_MAX_BARS, bar_index)
                int  kLeft  = maxK
                int  kRight = maxK
                int  tLeft  = t1
                int  tRight = t2
                bool foundL = false
                bool foundR = false

                for kk = 0 to maxK
                    if not foundR and time[kk] <= t2
                        kRight := kk
                        tRight := time[kk]
                        foundR := true
                    if time[kk] <= t1
                        kLeft := kk
                        tLeft := time[kk]
                        foundL := true
                        break

                if kLeft < kRight
                    kLeft := kRight
                    tLeft := tRight

                float leftBarLow   = low[kLeft]
                float leftBarHigh  = high[kLeft]
                float rightBarLow  = low[kRight]
                float rightBarHigh = high[kRight]

                float rangeLow  = low[kRight]
                float rangeHigh = high[kRight]
                for kk = kRight to kLeft
                    rangeLow  := math.min(rangeLow,  low[kk])
                    rangeHigh := math.max(rangeHigh, high[kk])

                float boundaryLow  = rangeLow
                float boundaryHigh = rangeHigh

                float uRange   = math.max(boundaryHigh - boundaryLow, syminfo.mintick)
                float outerPad = math.max(uRange * 0.15, syminfo.mintick * 10)

                float baseLineExtra = math.max(uRange * 0.20, syminfo.mintick * 12)

                int tier = 0
                if array.size(sym_marks) > 0
                    for q = 0 to array.size(sym_marks) - 1
                        mm = array.get(sym_marks, q)
                        if mm.bullish == p.stretch.bullish and t1 < mm.t2 and t2 > mm.t1
                            tier := math.max(tier, mm.tier + 1)

                float tierOff = tier * outerPad

                float yOuter = p.stretch.bullish ?
                     boundaryLow - outerPad - baseLineExtra - tierOff :
                     boundaryHigh + outerPad + baseLineExtra + tierOff

                float yBaseL = p.stretch.bullish ? leftBarLow  : leftBarHigh
                float yBaseR = p.stretch.bullish ? rightBarLow : rightBarHigh

                int   uWidth     = 3
                float tickGap    = 2 * syminfo.mintick
                float yLegStartL = p.stretch.bullish ? yBaseL - tickGap : yBaseL + tickGap
                float yLegStartR = p.stretch.bullish ? yBaseR - tickGap : yBaseR + tickGap

                // ✅ U line (uCol) — bright green / bright red
                line leftTick = line.new(tLeft, yLegStartL, tLeft, yOuter,
                                          xloc  = xloc.bar_time,
                                          color = uCol, width = uWidth)
                line rightTick = line.new(tRight, yLegStartR, tRight, yOuter,
                                           xloc  = xloc.bar_time,
                                           color = uCol, width = uWidth)
                line baseLine = line.new(tLeft, yOuter, tRight, yOuter,
                                          xloc  = xloc.bar_time,
                                          color = uCol, width = uWidth)

                // ✅ Circle marker — same color as U line
                label confMark = label.new(tRight, yOuter, "",
                                            xloc  = xloc.bar_time,
                                            style = label.style_circle,
                                            color = uCol,
                                            size  = size.auto)

                label tickLbl = na
                if sym_show_lbl
                    float lblY = p.stretch.bullish ? yOuter - outerPad * 0.5 : yOuter + outerPad * 0.5
                    string tickerText = ""
                    if sym_lbl_mode == 'Ticker Only'
                        tickerText := sym_ticker
                    else if sym_lbl_mode == 'TF Only'
                        tickerText := sym_tf_resolved
                    else if sym_lbl_mode == 'Ticker + TF'
                        tickerText := sym_ticker + "\n" + sym_tf_resolved
                    // ✅ Background = U-line color (uCol), text = black (readable)
                    tickLbl := label.new(math.round((tLeft + tRight) / 2), lblY, tickerText,
                                         xloc      = xloc.bar_time,
                                         style     = label.style_label_center,
                                         color     = uCol,
                                         textcolor = sCol,
                                         size      = size.small,
                                         textalign = text.align_center)

                mark = SymbolCISDMark.new(p.stretch.bullish, bar_index - 1, bar_index,
                                          leftTick, rightTick, baseLine,
                                          confMark, tickLbl,
                                          p.pivot_price, bar_index,
                                          t1, t2, tier)
                array.push(sym_marks, mark)
                array.remove(sym_pending, i)

fifoTrimSym(bool isBull, int maxPerDir) =>
    int cnt = 0
    int oldestIdx = -1
    int oldestBar = 2147483647
    for i = 0 to array.size(sym_marks) - 1
        m = array.get(sym_marks, i)
        if m.bullish == isBull
            cnt += 1
            if m.confirmation_bar < oldestBar
                oldestBar := m.confirmation_bar
                oldestIdx := i
    if cnt > maxPerDir and oldestIdx >= 0
        m = array.get(sym_marks, oldestIdx)
        deleteSymMark(m)
        array.remove(sym_marks, oldestIdx)

if array.size(sym_marks) > 0
    int safety2 = 0
    while array.size(sym_marks) > 0 and safety2 < 200
        int cB = 0
        int cS = 0
        for i = 0 to array.size(sym_marks) - 1
            m = array.get(sym_marks, i)
            if m.bullish
                cB += 1
            else
                cS += 1
        bool trimmed2 = false
        if cB > sym_max_cisd
            fifoTrimSym(true, sym_max_cisd)
            trimmed2 := true
        if cS > sym_max_cisd
            fifoTrimSym(false, sym_max_cisd)
            trimmed2 := true
        if not trimmed2
            break
        safety2 += 1

if array.size(sym_marks) > 0 and array.size(sym_h) > 0 and array.size(sym_l) > 0
    float symLastH = array.get(sym_h, array.size(sym_h) - 1)
    float symLastL = array.get(sym_l, array.size(sym_l) - 1)
    for i = array.size(sym_marks) - 1 to 0
        m = array.get(sym_marks, i)
        bool removeIt = false
        if m.bullish and symLastL < m.pivot_price
            removeIt := true
        else if not m.bullish and symLastH > m.pivot_price
            removeIt := true
        if removeIt
            deleteSymMark(m)
            array.remove(sym_marks, i)

while array.size(sym_purge_tracker) > PURGE_TRACKER_MAX
    array.shift(sym_purge_tracker)

// =============================================================================
// DEBUG
// =============================================================================

if debug_mode and barstate.islast
    dbgMsg("=== SUMMARY ===")
    dbgMsg("Chart: ActivePend=" + str.tostring(array.size(pending_cisd)) +
           " ActiveConf=" + str.tostring(array.size(confirmed_cisd)) +
           " PurgeTrack=" + str.tostring(array.size(purge_tracker)))
    dbgMsg("Symbol: ActivePend=" + str.tostring(array.size(sym_pending)) +
           " ActiveMarks=" + str.tostring(array.size(sym_marks)) +
           " PurgeTrack=" + str.tostring(array.size(sym_purge_tracker)) +
           " PivH=" + str.tostring(array.size(sym_pivot_highs)) +
           " PivL=" + str.tostring(array.size(sym_pivot_lows)))
    dbgMsg("Engine: SizeFilter=" + str.tostring(cisd_size_filter) +
           " Preset=" + cisd_size_preset +
           " Sensitivity=" + cisd_sensitivity +
           " Timeout=" + str.tostring(cisd_pending_timeout) +
           " PurgeFilter=" + str.tostring(cisd_purge_filter))
    dbgMsg("Vol: chart=" + str.tostring(volMultiplier, "#.###") +
           " sym=" + str.tostring(symVolMultiplier, "#.###") +
           " symAtrMult=" + str.tostring(sym_atr_mult, "#.#####"))
````
