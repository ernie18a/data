<!-- tradingview-pine-id: PUB;deb6bea1ef8548889d82eb918d35624a -->
<!-- tradingviewscripts-format: 1 -->
# 🛡️ Forex Signals (Dynamic VWAP)

Source: https://www.tradingview.com/script/3fj87M1J-Forex-Signals-Dynamic-VWAP/

## Description

🛡️ Venom A1 — Forex Signals (Dynamic VWAP) is a Trading View indicator designed to provide clear BUY and SELL signals with integrated trade management for Forex markets.

The indicator combines directional signals with optional Higher Timeframe confirmation and automatically manages the displayed trade setup using predefined Entry, TP1, TP2, TP3 and Stop Loss levels.

🧠 How It Works

The signal engine analyzes Swing Points and uses a Dynamic Swing-Anchored VWAP based on volume-weighted price to determine the current market direction. BUY and SELL signals are generated when the swing direction changes, with an optional Higher Timeframe (HTF) filter for additional confirmation. The VWAP tracking can also adapt to market volatility using an ATR-based adjustment when enabled.

🚀 Key Features

🟢 BUY / SELL Signals
Clear directional signals generated when the indicator's direction changes, with an optional HTF filter for additional confirmation.

📊 Higher Timeframe Filter
Choose a higher timeframe such as 15m, 30m, 1H, 2H, 4H or Daily to help align signals with the broader market direction.

🎯 Three Take-Profit Levels
The indicator displays TP1, TP2 and TP3, allowing traders to manage multiple target levels within the same setup.

🛡️ Stop Loss
A predefined SL level is displayed together with the trade setup, with customizable pip distances.

⚙️ Automatic Symbol Profiles
The indicator can automatically load predefined settings based on the current chart symbol, with individual SL/TP configurations.

🔔 Real-Time Alerts
Alerts can be generated for new FX signals as well as when targets or Stop Loss levels are reached.
📈 Trade Tracking
The indicator tracks active trades and records TP/SL outcomes, including win rate, winning/losing streaks and trade history.

📌 Trade Management

Each new signal creates a complete setup containing:
Entry → TP1 → TP2 → TP3 → SL
The levels are automatically projected on the chart and remain visible while the trade is active.
When TP levels are reached, the indicator marks the corresponding target. If Stop Loss is reached before TP1, the trade is recorded as a loss.

⚙️ Customization

You can customize:
Stop Loss distance
TP1 / TP2 / TP3 distances
Target visibility
Label size
Label position
Automatic symbol profiles
Higher Timeframe confirmation
Alert functionality

The default target distances are configurable in pips, while symbol-specific profiles can override the default values automatically.

⚠️ Important
This indicator is a technical analysis and trade-management tool, not financial advice.
No indicator can guarantee profitable trades. Always combine signals with proper risk management and evaluate the indicator on your preferred market, timeframe and trading conditions.
Trade smart. Manage risk. Stay disciplined.
Venom A1 ⚔️

---

## Source Code

````pine
//@version=6
indicator('🛡️ Forex Signals (Dynamic VWAP)', overlay = true, max_bars_back = 5000, max_labels_count = 500, max_polylines_count = 100, max_lines_count = 500, max_boxes_count = 10, explicit_plot_zorder = true)

// ============================================================================
// ORIGINAL INPUTS (Signal engine)
// ============================================================================
prd     = input.int(50, title='Swing Period', minval=2, group='Swing Points')
baseAPT = input.float(20, 'Adaptive Price Tracking', minval=1, step=1, group='Swing Points')
useAdapt = input.bool(false, 'Adapt APT by ATR ratio', group='Swing Points')
volBias = input.float(10.0, 'Volatility Bias', minval=0.1, step=0.1, group='Swing Points')

highS   = input.color(color.rgb(0, 0, 255), title="Swing Labels High", group="Style", inline="Swing")
lowS    = input.color(color.rgb(255, 215, 0),  title="Swing Labels Low",  group="Style", inline="Swing")
xx      = input.int(2, minval=1, title="Line Width", group="Style", inline="VWAP")

// ============================================================================
// HTF Trend Filter
// ============================================================================
useHtfFilter = input.bool(false, "Enable HTF Trend Filter", group="HTF Trend Filter")
htfTfOption  = input.string("1H", "Higher Timeframe", options=["15m","30m","1H","2H","4H","1D"], group="HTF Trend Filter")

htf_tf = htfTfOption == "15m" ? "15" :
     htfTfOption == "30m" ? "30" :
     htfTfOption == "1H"  ? "60" :
     htfTfOption == "2H"  ? "120" :
     htfTfOption == "4H"  ? "240" : "D"

// ============================================================================
// RETEST + CONFIRMATION CANDLE INPUTS (Default Fallback)
// ============================================================================
useRetestMaxBars_def     = input.bool(false, "Enable Retest Max Bars", group="Retest & Confirmation (Default)", tooltip="When ON, the trade will be cancelled if price does not retest the swing level within the specified max bars.")
retestMaxBars_def        = input.int(30,     "Retest Max Bars", minval=1, group="Retest & Confirmation (Default)", tooltip="Maximum number of bars to wait for price to retest the swing reversal level after a candidate signal appears. If exceeded without a retest, the candidate signal is cancelled.")
useConfirmationCandle_def = input.bool(false, "Use Confirmation Candle", group="Retest & Confirmation (Default)", tooltip="If enabled, requires a confirmation candle (closing in the trade direction, back beyond the retest level) after the retest before the trade is opened. If disabled, the trade opens on the close of the bar that completes the retest.")
retestTolerancePips_def  = input.float(10,   "Retest Tolerance (Pips)", minval=0.1, step=0.5, group="Retest & Confirmation (Default)", tooltip="Distance (in pips) around the swing reversal level that still counts as a valid retest of that zone.")

// ============================================================================
// NEW INPUTS — TRADE MANAGEMENT (Default Targets)
// ============================================================================
shw_TP1      = input.bool(true, "Show Targets / Trade Setup", group="Targets (Pips)")

// Default Targets
sl_pips  = input.float(25,  "SL  (Pips)",  group="Targets (Pips)", minval=0.1, step=1)
tp1_pips = input.float(20,  "TP1 (Pips)", group="Targets (Pips)", minval=0.1, step=1)
tp2_pips = input.float(25,  "TP2 (Pips)", group="Targets (Pips)", minval=0.1, step=1)
tp3_pips = input.float(30,  "TP3 (Pips)", group="Targets (Pips)", minval=0.1, step=1)

label_offset      = input.int(30, "Label Offset (candles ahead)", group="Targets (Pips)", minval=1, maxval=50, tooltip="Number of candles the labels are shifted ahead, to the right of the current bar")
label_size_input  = input.string("Small", "Label Size", group="Targets (Pips)", options=["Tiny","Small","Normal","Large","Huge"])

// ============================================================================
// AUTO SYMBOL PROFILES (3 Profiles - A, B, C)
// ============================================================================
enable_auto_profiles = input.bool(true, "Enable Auto Profiles (Symbol Matching)", group="Auto Symbol Profiles", tooltip="When ON, the indicator loads the matching profile's settings based on the current chart symbol.")

// --- Profile A ---
pA_symbol = input.string("EURUSD", "Symbol", group="Profile A", inline="pA1")
pA_sl     = input.float(25,  "SL (Pips)", group="Profile A", minval=0.1, step=1, inline="pA2")
pA_tp1    = input.float(20,  "TP1 (Pips)", group="Profile A", minval=0.1, step=1, inline="pA2")
pA_tp2    = input.float(35,  "TP2 (Pips)", group="Profile A", minval=0.1, step=1, inline="pA3")
pA_tp3    = input.float(45,  "TP3 (Pips)", group="Profile A", minval=0.1, step=1, inline="pA3")

pA_useRetest  = input.bool(false, "Enable Retest Max Bars", group="Profile A", inline="pA4")
pA_maxBars    = input.int(30,     "Retest Max Bars", group="Profile A", minval=1, inline="pA4")
pA_confirm    = input.bool(false, "Use Confirmation Candle", group="Profile A", inline="pA5")
pA_tolerance  = input.float(15,   "Retest Tolerance (Pips)", group="Profile A", minval=0.1, step=0.5, inline="pA5")

// --- Profile B ---
pB_symbol = input.string("GBPUSD", "Symbol", group="Profile B", inline="pB1")
pB_sl     = input.float(25,  "SL (Pips)", group="Profile B", minval=0.1, step=1, inline="pB2")
pB_tp1    = input.float(20,  "TP1 (Pips)", group="Profile B", minval=0.1, step=1, inline="pB2")
pB_tp2    = input.float(30,  "TP2 (Pips)", group="Profile B", minval=0.1, step=1, inline="pB3")
pB_tp3    = input.float(35,  "TP3 (Pips)", group="Profile B", minval=0.1, step=1, inline="pB3")

pB_useRetest  = input.bool(false, "Enable Retest Max Bars", group="Profile B", inline="pB4")
pB_maxBars    = input.int(25,     "Retest Max Bars", group="Profile B", minval=1, inline="pB4")
pB_confirm    = input.bool(false, "Use Confirmation Candle", group="Profile B", inline="pB5")
pB_tolerance  = input.float(20,   "Retest Tolerance (Pips)", group="Profile B", minval=0.1, step=0.5, inline="pB5")

// --- Profile C ---
pC_symbol = input.string("USDJPY", "Symbol", group="Profile C", inline="pC1")
pC_sl     = input.float(25,  "SL (Pips)", group="Profile C", minval=0.1, step=1, inline="pC2")
pC_tp1    = input.float(20,  "TP1 (Pips)", group="Profile C", minval=0.1, step=1, inline="pC2")
pC_tp2    = input.float(25,  "TP2 (Pips)", group="Profile C", minval=0.1, step=1, inline="pC3")
pC_tp3    = input.float(35,  "TP3 (Pips)", group="Profile C", minval=0.1, step=1, inline="pC3")

pC_useRetest  = input.bool(false, "Enable Retest Max Bars", group="Profile C", inline="pC4")
pC_maxBars    = input.int(30,     "Retest Max Bars", group="Profile C", minval=1, inline="pC4")
pC_confirm    = input.bool(false, "Use Confirmation Candle", group="Profile C", inline="pC5")
pC_tolerance  = input.float(10,   "Retest Tolerance (Pips)", group="Profile C", minval=0.1, step=0.5, inline="pC5")

// ---- Colors ----
green_c   = input.color(#00ffbb, "Bullish Colour", group="Colors")
red_c     = input.color(#ff1100, "Bearish Colour", group="Colors")
tp1_color = input.color(color.new(#04df79, 0), "TP1 Color", group="Colors")
tp2_color = input.color(color.new(#ee14ee, 0), "TP2 Color", group="Colors")
tp3_color = input.color(color.new(#fbc02d, 0), "TP3 Color", group="Colors")
sl_color  = input.color(color.new(#b71c1c, 0), "SL Color",  group="Colors")

// ---- Dashboard Colors (Amber / Gold Theme) ----
color_main   = #ffb703
color_bg     = #1c1c1c
color_win    = #06d6a0
color_loss   = #d90429
color_border = color.new(#ffb703, 50)

// ---- Dashboard ----
show_dashboard = input.bool(true,          "Show Statistics Dashboard", group="Dashboard")
dash_position  = input.string("Top Right", "Dashboard Position",        group="Dashboard", options=["Top Right","Top Left","Bottom Right","Bottom Left"])
trades_limit   = input.int(40,             "Last X Trades to Count",    group="Dashboard", minval=1, maxval=500)

show_pts_dashboard = input.bool(true,           "Show Targets-Hit Dashboard", group="Targets Dashboard")
pts_position       = input.string("Bottom Right", "Targets Dashboard Position", group="Targets Dashboard", options=["Top Right","Top Left","Bottom Right","Bottom Left"])
pts_size_input      = input.string("Small", "Targets Dashboard Size", group="Targets Dashboard", options=["Tiny","Small","Normal","Large"])

// ============================================================================
// TradingView Alert Messages
// ============================================================================
send_telegram = input.bool(true, "Enable Alert Messages", group="Alerts")

lbl_size = label_size_input == "Tiny"  ? size.tiny  :
     label_size_input == "Small"  ? size.small  :
     label_size_input == "Normal" ? size.normal :
     label_size_input == "Large"  ? size.large  : size.huge

// ============================================================================
// AUTO PROFILE MATCHING LOGIC
// ============================================================================
var array<string> profile_symbols  = array.new<string>()
var array<float>  profile_sls      = array.new<float>()
var array<float>  profile_tp1s     = array.new<float>()
var array<float>  profile_tp2s     = array.new<float>()
var array<float>  profile_tp3s     = array.new<float>()
var array<bool>   profile_useRetest = array.new<bool>()
var array<int>    profile_maxBars   = array.new<int>()
var array<bool>   profile_confirm   = array.new<bool>()
var array<float>  profile_tolerance = array.new<float>()

if barstate.isfirst
    // Profile A
    array.push(profile_symbols, pA_symbol)
    array.push(profile_sls, pA_sl)
    array.push(profile_tp1s, pA_tp1)
    array.push(profile_tp2s, pA_tp2)
    array.push(profile_tp3s, pA_tp3)
    array.push(profile_useRetest, pA_useRetest)
    array.push(profile_maxBars, pA_maxBars)
    array.push(profile_confirm, pA_confirm)
    array.push(profile_tolerance, pA_tolerance)
    // Profile B
    array.push(profile_symbols, pB_symbol)
    array.push(profile_sls, pB_sl)
    array.push(profile_tp1s, pB_tp1)
    array.push(profile_tp2s, pB_tp2)
    array.push(profile_tp3s, pB_tp3)
    array.push(profile_useRetest, pB_useRetest)
    array.push(profile_maxBars, pB_maxBars)
    array.push(profile_confirm, pB_confirm)
    array.push(profile_tolerance, pB_tolerance)
    // Profile C
    array.push(profile_symbols, pC_symbol)
    array.push(profile_sls, pC_sl)
    array.push(profile_tp1s, pC_tp1)
    array.push(profile_tp2s, pC_tp2)
    array.push(profile_tp3s, pC_tp3)
    array.push(profile_useRetest, pC_useRetest)
    array.push(profile_maxBars, pC_maxBars)
    array.push(profile_confirm, pC_confirm)
    array.push(profile_tolerance, pC_tolerance)

f_find_profile_index() =>
    int found = -1
    if enable_auto_profiles
        for i = 0 to array.size(profile_symbols) - 1
            sym_check = array.get(profile_symbols, i)
            if sym_check == syminfo.ticker and sym_check != ""
                found := i
                break
    found

active_profile_idx   = f_find_profile_index()
active_profile_label = active_profile_idx >= 0 ? "Profile " + array.get(array.from("A", "B", "C"), active_profile_idx) + " (" + syminfo.ticker + ")" : "Default"

// Effective Targets based on matched profile
eff_sl_pips  = active_profile_idx >= 0 ? array.get(profile_sls,  active_profile_idx) : sl_pips
eff_tp1_pips = active_profile_idx >= 0 ? array.get(profile_tp1s, active_profile_idx) : tp1_pips
eff_tp2_pips = active_profile_idx >= 0 ? array.get(profile_tp2s, active_profile_idx) : tp2_pips
eff_tp3_pips = active_profile_idx >= 0 ? array.get(profile_tp3s, active_profile_idx) : tp3_pips

// Effective Retest Settings based on matched profile
eff_useRetest = active_profile_idx >= 0 ? array.get(profile_useRetest, active_profile_idx) : useRetestMaxBars_def
eff_maxBars   = active_profile_idx >= 0 ? array.get(profile_maxBars,    active_profile_idx) : retestMaxBars_def
eff_confirm   = active_profile_idx >= 0 ? array.get(profile_confirm,    active_profile_idx) : useConfirmationCandle_def
eff_tol       = active_profile_idx >= 0 ? array.get(profile_tolerance,  active_profile_idx) : retestTolerancePips_def

// ============================================================================
// STATE — TRADE MANAGEMENT
// ============================================================================
var line  entry_line  = na, var line  sl_line   = na
var line  tp1_line    = na, var line  tp2_line  = na, var line  tp3_line = na
var label entry_label = na, var label sl_label  = na
var label tp1_label   = na, var label tp2_label = na, var label tp3_label = na
var linefill lf1      = na, var linefill lf2    = na

var int   trade_dir     = 0
var bool  trade_open    = false
var bool  tp3_done      = false
var bool  tp1_hit       = false
var bool  tp2_hit       = false
var bool  trade_counted = false
var float entry_price   = na

var string current_trade_id = ""

var array<bool>  trades_history = array.new<bool>()

var float cur_tp1_pct = 0.0
var float cur_tp2_pct = 0.0
var float cur_tp3_pct = 0.0
var float cur_sl_pct  = 0.0

var array<float> hist_tp1 = array.new<float>()
var array<float> hist_tp2 = array.new<float>()
var array<float> hist_tp3 = array.new<float>()
var array<float> hist_sl  = array.new<float>()

// ---- NEW — Retest + Confirmation candidate state ----
var int   candidate_dir       = 0     // 0 = none, 1 = long candidate, -1 = short candidate
var float candidate_level     = na    // swing level (pl for long / ph for short) to retest
var int   candidate_start_bar = na    // bar the candidate signal appeared on
var bool  candidate_retest_ok = false // true once price has retested candidate_level

f_close_trade(float t1, float t2, float t3, float sl) =>
    array.push(hist_tp1, t1)
    array.push(hist_tp2, t2)
    array.push(hist_tp3, t3)
    array.push(hist_sl,  sl)
    if array.size(hist_tp1) > trades_limit
        array.shift(hist_tp1)
        array.shift(hist_tp2)
        array.shift(hist_tp3)
        array.shift(hist_sl)

// ============================================================================
// Pip Size Detection (Forex) - smart method supporting JPY and standard FX pairs
// ============================================================================
f_pip_size() =>
    float _mt = syminfo.mintick
    float _pip = _mt >= 0.01 ? 0.01 : (_mt >= 0.001 ? 0.01 : 0.0001)
    _pip

calc_distances() =>
    float pip   = f_pip_size()
    float sl_d  = eff_sl_pips  * pip
    float tp1_d = eff_tp1_pips * pip
    float tp2_d = eff_tp2_pips * pip
    float tp3_d = eff_tp3_pips * pip
    [sl_d, tp1_d, tp2_d, tp3_d]

// ============================================================================
// Swing Points / Pivots
// ============================================================================
b = bar_index

var ph   = float(na)
var pl   = float(na)
var phL  = b
var plL  = b
var prev = float(na)

ph  := ta.highestbars(high, prd) == 0 ? high : ph
pl  := ta.lowestbars(low,  prd) == 0 ? low  : pl
phL := ta.highestbars(high, prd) == 0 ? b   : phL
plL := ta.lowestbars(low,  prd) == 0 ? b    : plL
dir = phL > plL ? 1 : -1

atrLen = 50
atr    = ta.atr(atrLen)
atrAvg = ta.rma(atr, atrLen)
ratio  = atrAvg > 0 ? atr / atrAvg : 1.0

aptRaw     = useAdapt ? baseAPT / math.pow(ratio, volBias) : baseAPT
aptClamped = math.max(5.0, math.min(300.0, aptRaw))
aptSeries  = math.round(aptClamped)

alphaFromAPT(apt) =>
    decay = math.exp(-math.log(2.0) / math.max(1.0, apt))
    1.0 - decay

type dataPoints
    array<chart.point> points
    polyline poly = na

var vwapGreen = dataPoints.new(array.new<chart.point>())
var vwapRed   = dataPoints.new(array.new<chart.point>())

var float p   = hlc3 * volume
var float vol = volume

if dir != dir[1]
    x   = dir > 0 ? plL : phL
    y   = dir > 0 ? pl  : ph
    loc = dir > 0 ? label.style_label_up : label.style_label_down
    col = dir > 0 ?  highS : lowS
    txt = dir > 0 and pl < prev ? 'LL' : dir > 0 and pl > prev ? 'HL' : dir < 0 and ph < prev ? 'LH' : dir < 0 and ph > prev ? 'HH' : ''
    label.new(x, y, text=txt, style=loc, color=color.new(col, 20), textcolor=color.white)
    prev := dir > 0 ? ph[1] : pl[1]

    barsback = b - x
    p   := y * volume[barsback]
    vol := volume[barsback]
    vap = p / vol

    if dir > 0
        vwapGreen.poly.delete()
        vwapGreen.points.clear()
        for i = barsback to 0 by 1
            apt_i = aptSeries[i]
            alpha = alphaFromAPT(apt_i)
            pxv   = hlc3[i] * volume[i]
            v_i   = volume[i]
            p     := (1.0 - alpha) * p + alpha * pxv
            vol   := (1.0 - alpha) * vol + alpha * v_i
            vappe = vol > 0 ? p / vol : na
            vwapGreen.points.push(chart.point.from_index(b - i, vappe))
        vwapGreen.poly := polyline.new(vwapGreen.points, false, false, line_color=color.green, line_width=xx)

    else
        vwapRed.poly.delete()
        vwapRed.points.clear()
        for i = barsback to 0 by 1
            apt_i = aptSeries[i]
            alpha = alphaFromAPT(apt_i)
            pxv   = hlc3[i] * volume[i]
            v_i   = volume[i]
            p     := (1.0 - alpha) * p + alpha * pxv
            vol   := (1.0 - alpha) * vol + alpha * v_i
            vappe = vol > 0 ? p / vol : na
            vwapRed.points.push(chart.point.from_index(b - i, vappe))
        vwapRed.poly := polyline.new(vwapRed.points, false, false, line_color=color.red, line_width=xx)

else
    apt_0 = aptSeries
    alpha = alphaFromAPT(apt_0)
    pxv = hlc3 * volume
    v0  = volume
    p   := (1.0 - alpha) * p + alpha * pxv
    vol := (1.0 - alpha) * vol + alpha * v0
    vap = vol > 0 ? p / vol : na

    if dir > 0
        vwapGreen.poly.delete()
        vwapGreen.points.push(chart.point.from_index(b, vap))
        vwapGreen.poly := polyline.new(vwapGreen.points, false, false, line_color=color.rgb(19, 226, 71), line_width=xx)
    else
        vwapRed.poly.delete()
        vwapRed.points.push(chart.point.from_index(b, vap))
        vwapRed.poly := polyline.new(vwapRed.points, false, false, line_color=color.red, line_width=xx)

// ============================================================================
// HTF Trend Filter
// ============================================================================
htfDir = useHtfFilter ? request.security(syminfo.tickerid, htf_tf, dir, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : na

// ============================================================================
// Entry Signal Detection — Swing Reversal → Candidate Signal
// ============================================================================
longSignal  = (dir > 0 and dir[1] < 0) and (not useHtfFilter or htfDir == 1)
shortSignal = (dir < 0 and dir[1] > 0) and (not useHtfFilter or htfDir == -1)

// New trade condition: do not open a new trade unless there is no active trade, or the current trade has hit at least TP1.
can_open_new = not trade_open or tp1_hit or tp3_done

// ---- Step 1: Swing reversal creates a CANDIDATE signal (not an entry) ----
if (longSignal or shortSignal) and can_open_new
    candidate_dir       := longSignal ? 1 : -1
    candidate_level     := longSignal ? pl : ph
    candidate_start_bar := bar_index
    candidate_retest_ok := not eff_useRetest // If retest is disabled, entry triggers immediately

    if eff_useRetest
        candY     = longSignal ? low - 2*syminfo.mintick : high + 2*syminfo.mintick
        candStyle = longSignal ? label.style_label_up : label.style_label_down
        candColor = longSignal ? color.green : color.rgb(243, 11, 146)
        label.new(bar_index, candY, text=longSignal ? "🕒 Long Candidate" : "🕒 Short Candidate", style=candStyle, color=color.new(candColor, 60), textcolor=color.white, size=size.tiny)

// Cancel candidate if we can no longer open a new trade (prevents deferred entries from triggering incorrectly)
if not can_open_new and candidate_dir != 0
    candidate_dir       := 0
    candidate_level     := na
    candidate_retest_ok := false

// ---- Step 2: cancel candidate if Retest Max Bars is exceeded before a retest occurs ----
if candidate_dir != 0 and not candidate_retest_ok and not na(candidate_start_bar) and eff_useRetest and (bar_index - candidate_start_bar) > eff_maxBars
    candidate_dir   := 0
    candidate_level := na

// ---- Step 3: Retest detection — price must return to the swing reversal level (on a subsequent bar) ----
retestTolDist = eff_tol * f_pip_size()
if candidate_dir != 0 and not candidate_retest_ok and not na(candidate_level) and bar_index > candidate_start_bar
    touchedZone = candidate_dir == 1 ? (low <= candidate_level + retestTolDist) : (high >= candidate_level - retestTolDist)
    if touchedZone
        candidate_retest_ok := true

// ---- Step 4: Confirmation Candle — logical confirmation of the bounce from the retest zone ----
confirmLong  = candidate_dir == 1  and close > open and close > candidate_level
confirmShort = candidate_dir == -1 and close < open and close < candidate_level

entry_trigger = barstate.isconfirmed and can_open_new and candidate_dir != 0 and candidate_retest_ok and (not eff_confirm or (candidate_dir == 1 ? confirmLong : confirmShort))

entryDirection = entry_trigger ? candidate_dir : 0

// ---- Step 5: BUY/SELL fires only after Signal → Retest → Confirmation Candle Close ----
if entry_trigger
    entryY   = entryDirection == 1 ? low - 2*syminfo.mintick : high + 2*syminfo.mintick
    lblStyle = entryDirection == 1 ? label.style_label_up : label.style_label_down
    lblColor = entryDirection == 1 ? color.green : color.rgb(243, 11, 146)

    label.new(bar_index, entryY, text=entryDirection == 1 ? "🚀BUY" : "📉SELL", style=lblStyle, color=color.new(lblColor,0), textcolor=color.white)

    // Consume the candidate now that it has produced an entry
    candidate_dir       := 0
    candidate_level     := na
    candidate_retest_ok := false

// ============================================================================
// NEW — TRADE MANAGEMENT 
// ============================================================================
new_signal_tm = entry_trigger

if shw_TP1 and new_signal_tm
    // If there is an open trade that hit TP1 but wasn't counted, close it and log as a win before opening the new one
    if trade_open and tp1_hit and not trade_counted
        f_close_trade(cur_tp1_pct, cur_tp2_pct, 0.0, 0.0)
        array.push(trades_history, true)
        if array.size(trades_history) > trades_limit
            array.shift(trades_history)
        trade_counted := true

    trade_dir     := entryDirection
    tp3_done      := false
    tp1_hit       := false
    tp2_hit       := false
    trade_counted := false
    trade_open    := true
    entry_price   := close
    cur_tp1_pct   := 0.0
    cur_tp2_pct   := 0.0
    cur_tp3_pct   := 0.0
    cur_sl_pct    := 0.0

    current_trade_id := syminfo.ticker + "_" + str.tostring(time)

    [sl_d, tp1_d, tp2_d, tp3_d] = calc_distances()

    float SL      = trade_dir == 1 ? close - sl_d  : close + sl_d
    float TP1_lvl = trade_dir == 1 ? close + tp1_d : close - tp1_d
    float TP2_lvl = trade_dir == 1 ? close + tp2_d : close - tp2_d
    float TP3_lvl = trade_dir == 1 ? close + tp3_d : close - tp3_d

    string sl_str  = str.tostring(eff_sl_pips,  "#.#") + " pips"
    string tp1_str = str.tostring(eff_tp1_pips, "#.#") + " pips"
    string tp2_str = str.tostring(eff_tp2_pips, "#.#") + " pips"
    string tp3_str = str.tostring(eff_tp3_pips, "#.#") + " pips"

    int lx = bar_index + label_offset
    dirColor = trade_dir == 1 ? green_c : red_c

    line.delete(entry_line),  label.delete(entry_label)
    line.delete(sl_line),     label.delete(sl_label)
    line.delete(tp1_line),    label.delete(tp1_label)
    line.delete(tp2_line),    label.delete(tp2_label)
    line.delete(tp3_line),    label.delete(tp3_label)
    linefill.delete(lf1),     linefill.delete(lf2)

    entry_line  := line.new(bar_index, close, lx, close, color=dirColor, width=3)
    entry_label := label.new(lx, close, "ENTRY ▸ " + str.tostring(close, format.mintick), style=label.style_label_left, color=dirColor, textcolor=color.rgb(0,0,0), size=lbl_size)

    sl_line  := line.new(bar_index, SL, lx, SL, color=sl_color, width=2)
    sl_label := label.new(lx, SL,
         "✘ SL ▸ " + str.tostring(SL, format.mintick) + "  -" + sl_str,
         style=label.style_label_left, color=sl_color, textcolor=color.white, size=lbl_size)

    tp1_line  := line.new(bar_index, TP1_lvl, lx, TP1_lvl, color=tp1_color, width=2)
    tp1_label := label.new(lx, TP1_lvl,
         "✔ TP1 ▸ " + str.tostring(TP1_lvl, format.mintick) + "  +" + tp1_str,
         style=label.style_label_left, color=tp1_color, textcolor=color.white, size=lbl_size)

    tp2_line  := line.new(bar_index, TP2_lvl, lx, TP2_lvl, color=tp2_color, width=2)
    tp2_label := label.new(lx, TP2_lvl,
         "✔ TP2 ▸ " + str.tostring(TP2_lvl, format.mintick) + "  +" + tp2_str,
         style=label.style_label_left, color=tp2_color, textcolor=color.white, size=lbl_size)

    tp3_line  := line.new(bar_index, TP3_lvl, lx, TP3_lvl, color=tp3_color, width=2)
    tp3_label := label.new(lx, TP3_lvl,
         "✔ TP3 ▸ " + str.tostring(TP3_lvl, format.mintick) + "  +" + tp3_str,
         style=label.style_label_left, color=tp3_color, textcolor=color.white, size=lbl_size)

    lf1 := linefill.new(entry_line, sl_line,  color.new(red_c,   95))
    lf2 := linefill.new(entry_line, tp3_line, color.new(green_c, 95))

    if send_telegram
        string dir_msg = trade_dir == 1 ? "🟢 BUY SIGNAL | BUY" : "🔴 SELL SIGNAL | SELL"
        telegram_entry_msg = "🔵🔵 [ FX SIGNAL ] 🔵🔵\n═════════════════\n" + dir_msg + "\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n🔵 Entry: " + str.tostring(close, format.mintick) + "\n🎯 TP1: " + str.tostring(TP1_lvl, format.mintick) + " (" + tp1_str + ")\n🎯 TP2: " + str.tostring(TP2_lvl, format.mintick) + " (" + tp2_str + ")\n🎯 TP3: " + str.tostring(TP3_lvl, format.mintick) + " (" + tp3_str + ")\n🛡 SL: " + str.tostring(SL, format.mintick) + " (" + sl_str + ")\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id
        alert(telegram_entry_msg, alert.freq_once_per_bar_close)

// ---- Monitor active trade every bar ----
if shw_TP1 and not new_signal_tm and trade_open and not tp3_done
    int lx = bar_index + label_offset
    line.set_x2(entry_line,  lx), label.set_x(entry_label, lx)
    line.set_x2(sl_line,     lx), label.set_x(sl_label,    lx)
    line.set_x2(tp1_line,    lx), label.set_x(tp1_label,   lx)
    line.set_x2(tp2_line,    lx), label.set_x(tp2_label,    lx)
    line.set_x2(tp3_line,    lx), label.set_x(tp3_label,    lx)

    float tp1_val = line.get_y1(tp1_line)
    float tp2_val = line.get_y1(tp2_line)
    float tp3_val = line.get_y1(tp3_line)
    float sl_val  = line.get_y1(sl_line)
    float _pip    = f_pip_size()

    if trade_dir == 1
        if high >= tp1_val and not tp1_hit
            float tp1_amt = tp1_val - entry_price
            label.new(bar_index, tp1_val, "✔ TP1 ✅  +" + str.tostring(tp1_amt / _pip, "#.#") + " pips", style=label.style_label_up, color=tp1_color, textcolor=color.black, size=lbl_size)
            tp1_hit       := true
            cur_tp1_pct   := math.abs(tp1_amt)
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp1_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)

        if high >= tp2_val and not tp2_hit
            float tp2_amt = tp2_val - entry_price
            label.new(bar_index, tp2_val, "✔ TP2 ✅  +" + str.tostring(tp2_amt / _pip, "#.#") + " pips", style=label.style_label_up, color=tp2_color, textcolor=color.black, size=lbl_size)
            tp2_hit       := true
            cur_tp2_pct   := math.abs(tp2_amt)
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp2_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)

        if high >= tp3_val
            float tp3_amt = tp3_val - entry_price
            label.new(bar_index, tp3_val, "✔ TP3 HIT ✅  +" + str.tostring(tp3_amt / _pip, "#.#") + " pips", style=label.style_label_down, color=tp3_color, textcolor=color.black, size=lbl_size)
            cur_tp3_pct   := math.abs(tp3_amt)
            f_close_trade(cur_tp1_pct, cur_tp2_pct, cur_tp3_pct, 0.0)
            if not trade_counted
                array.push(trades_history, true)
                if array.size(trades_history) > trades_limit
                    array.shift(trades_history)
                trade_counted := true
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp3_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)
            line.delete(entry_line),  label.delete(entry_label)
            line.delete(sl_line),     label.delete(sl_label)
            line.delete(tp1_line),    label.delete(tp1_label)
            line.delete(tp2_line),    label.delete(tp2_label)
            line.delete(tp3_line),    label.delete(tp3_label)
            linefill.delete(lf1),     linefill.delete(lf2)
            tp3_done   := true
            trade_open := false

        else if low <= sl_val
            float sl_amt = entry_price - sl_val
            cur_sl_pct := math.abs(sl_amt)
            
            // If TP1 is not hit, it's a loss. If TP1 is hit, it's a win (since we achieved at least the first target)
            if not tp1_hit
                label.new(bar_index, sl_val, "SL HIT ❌  -" + str.tostring(sl_amt / _pip, "#.#") + " pips", style=label.style_label_up, color=sl_color, textcolor=color.white, size=lbl_size)
                if not trade_counted
                    array.push(trades_history, false)
                    if array.size(trades_history) > trades_limit
                        array.shift(trades_history)
                    trade_counted := true
                    f_close_trade(cur_tp1_pct, cur_tp2_pct, 0.0, cur_sl_pct)
            else
                if not trade_counted
                    array.push(trades_history, true)
                    if array.size(trades_history) > trades_limit
                        array.shift(trades_history)
                    trade_counted := true
                    f_close_trade(cur_tp1_pct, cur_tp2_pct, 0.0, cur_sl_pct)

            if send_telegram
                alert("🔵❌ [ FX RESULT ] ❌🔵\n═════════════════\n❌ STOP LOSS HIT 🛑\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 SL Price: " + str.tostring(sl_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)
            line.delete(entry_line),  label.delete(entry_label)
            line.delete(sl_line),     label.delete(sl_label)
            line.delete(tp1_line),    label.delete(tp1_label)
            line.delete(tp2_line),    label.delete(tp2_label)
            line.delete(tp3_line),    label.delete(tp3_label)
            linefill.delete(lf1),     linefill.delete(lf2)
            tp3_done   := true
            trade_open := false

    else if trade_dir == -1
        if low <= tp1_val and not tp1_hit
            float tp1_amt = entry_price - tp1_val
            label.new(bar_index, tp1_val, "✔ TP1 ✅  +" + str.tostring(tp1_amt / _pip, "#.#") + " pips", style=label.style_label_down, color=tp1_color, textcolor=color.black, size=lbl_size)
            tp1_hit       := true
            cur_tp1_pct   := math.abs(tp1_amt)
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp1_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)

        if low <= tp2_val and not tp2_hit
            float tp2_amt = entry_price - tp2_val
            label.new(bar_index, tp2_val, "✔ TP2 ✅  +" + str.tostring(tp2_amt / _pip, "#.#") + " pips", style=label.style_label_down, color=tp2_color, textcolor=color.black, size=lbl_size)
            tp2_hit       := true
            cur_tp2_pct   := math.abs(tp2_amt)
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp2_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)

        if low <= tp3_val
            float tp3_amt = entry_price - tp3_val
            label.new(bar_index, tp3_val, "✔ TP3 HIT ✅  +" + str.tostring(tp3_amt / _pip, "#.#") + " pips", style=label.style_label_up, color=tp3_color, textcolor=color.black, size=lbl_size)
            cur_tp3_pct   := math.abs(tp3_amt)
            f_close_trade(cur_tp1_pct, cur_tp2_pct, cur_tp3_pct, 0.0)
            if not trade_counted
                array.push(trades_history, true)
                if array.size(trades_history) > trades_limit
                    array.shift(trades_history)
                trade_counted := true
            if send_telegram
                alert("🔵✅ [ FX RESULT ] ✅🔵\n═════════════════\n✅ TARGET HIT 🎯\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 Target Price: " + str.tostring(tp3_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)
            line.delete(entry_line),  label.delete(entry_label)
            line.delete(sl_line),     label.delete(sl_label)
            line.delete(tp1_line),    label.delete(tp1_label)
            line.delete(tp2_line),    label.delete(tp2_label)
            line.delete(tp3_line),    label.delete(tp3_label)
            linefill.delete(lf1),     linefill.delete(lf2)
            tp3_done   := true
            trade_open := false

        else if high >= sl_val
            float sl_amt = sl_val - entry_price
            cur_sl_pct := math.abs(sl_amt)
            
            // If TP1 is not hit, it's a loss. If TP1 is hit, it's a win (since we achieved at least the first target)
            if not tp1_hit
                label.new(bar_index, sl_val, "SL HIT ❌  -" + str.tostring(sl_amt / _pip, "#.#") + " pips", style=label.style_label_down, color=sl_color, textcolor=color.white, size=lbl_size)
                if not trade_counted
                    array.push(trades_history, false)
                    if array.size(trades_history) > trades_limit
                        array.shift(trades_history)
                    trade_counted := true
                    f_close_trade(cur_tp1_pct, cur_tp2_pct, 0.0, cur_sl_pct)
            else
                if not trade_counted
                    array.push(trades_history, true)
                    if array.size(trades_history) > trades_limit
                        array.shift(trades_history)
                    trade_counted := true
                    f_close_trade(cur_tp1_pct, cur_tp2_pct, 0.0, cur_sl_pct)

            if send_telegram
                alert("🔵❌ [ FX RESULT ] ❌🔵\n═════════════════\n❌ STOP LOSS HIT 🛑\n📊 Symbol: " + syminfo.ticker + " | ⏱ " + timeframe.period + "\n💰 SL Price: " + str.tostring(sl_val, format.mintick) + "\n═════════════════\n✨ Premium FX Signals\n🆔 Trade ID: " + current_trade_id, alert.freq_once_per_bar_close)
            line.delete(entry_line),  label.delete(entry_label)
            line.delete(sl_line),     label.delete(sl_label)
            line.delete(tp1_line),    label.delete(tp1_label)
            line.delete(tp2_line),    label.delete(tp2_label)
            line.delete(tp3_line),    label.delete(tp3_label)
            linefill.delete(lf1),     linefill.delete(lf2)
            tp3_done   := true
            trade_open := false

// ============================================================================
// STATISTICS DASHBOARD 
// ============================================================================
if show_dashboard
    win_count  = 0
    lose_count = 0
    if array.size(trades_history) > 0
        for i = 0 to array.size(trades_history) - 1
            if array.get(trades_history, i)
                win_count += 1
            else
                lose_count += 1

    total_trades = win_count + lose_count
    win_rate     = total_trades > 0 ? (win_count / total_trades) * 100 : 0.0

    best_win_streak   = 0
    worst_lose_streak = 0
    if array.size(trades_history) > 0
        int _cw = 0
        int _cl = 0
        for i = 0 to array.size(trades_history) - 1
            if array.get(trades_history, i)
                _cw += 1
                _cl := 0
            else
                _cl += 1
                _cw := 0
            best_win_streak   := math.max(best_win_streak, _cw)
            worst_lose_streak := math.max(worst_lose_streak, _cl)

    tpos = dash_position == "Top Right"    ? position.top_right    :
           dash_position == "Top Left"     ? position.top_left     :
           dash_position == "Bottom Right" ? position.bottom_right : position.bottom_left

    var table t = table.new(tpos, 2, 10, bgcolor=color.new(color_bg, 10), border_width=1, border_color=color_border)

    if barstate.islast
        table.cell(t,0,0,"📊 Last "+str.tostring(trades_limit), text_color=color_bg, text_size=size.small, bgcolor=color_main, text_halign=text.align_center)
        table.cell(t,1,0,"Trades", text_color=color_bg, text_size=size.small, bgcolor=color_main, text_halign=text.align_center)
        
        table.cell(t,0,1,"Counted", text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,1,str.tostring(total_trades)+"/"+str.tostring(trades_limit), text_color=color_main, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,2,"✅ Win", text_color=color_win, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,2,str.tostring(win_count), text_color=color_win, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,3,"❌ Lose", text_color=color_loss, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,3,str.tostring(lose_count), text_color=color_loss, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,4,"📈 Win Rate", text_color=color_main, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        wrc = win_rate >= 60 ? color_win : win_rate >= 40 ? color_main : color_loss
        table.cell(t,1,4,str.tostring(win_rate,"#.##")+"%", text_color=wrc, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,5,"🔥 Best Streak", text_color=color_win, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,5,str.tostring(best_win_streak)+"W", text_color=color_win, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,6,"❄️ Worst Streak", text_color=color_loss, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,6,str.tostring(worst_lose_streak)+"L", text_color=color_loss, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,7,"Status", text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        bool is_active = trade_open and not tp3_done
        table.cell(t,1,7, is_active ? "🟢 ACTIVE" : "⚪ WAIT", text_color=is_active ? color_win : color.white, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))
        
        table.cell(t,0,8,"🧭 Direction", text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        dirTxt = is_active ? (trade_dir == 1 ? "BUY" : "SELL") : "-"
        table.cell(t,1,8, dirTxt, text_color=color_main, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))

        table.cell(t,0,9,"⚙️ Profile", text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color_bg, 20))
        table.cell(t,1,9, active_profile_label, text_color=color_main, text_size=size.small, text_halign=text.align_center, bgcolor=color.new(color_bg, 20))

// ============================================================================
// TARGETS-HIT DASHBOARD
// ============================================================================
if show_pts_dashboard
    ppos = pts_position == "Top Right"    ? position.top_right    :
           pts_position == "Top Left"     ? position.top_left     :
           pts_position == "Bottom Right" ? position.bottom_right : position.bottom_left

    pts_text_size = pts_size_input == "Tiny"   ? size.tiny   :
                     pts_size_input == "Small"  ? size.small  :
                     pts_size_input == "Normal" ? size.normal : size.large

    var table pt = table.new(ppos, 5, 2,
         bgcolor      = color.new(color_bg, 10),
         border_width = 1,
         border_color = color_border)

    if barstate.islast
        int cnt_tp1 = 0
        int cnt_tp2 = 0
        int cnt_tp3 = 0
        int cnt_sl  = 0
        int n = array.size(hist_tp1)
        if n > 0
            for i = 0 to n - 1
                if array.get(hist_tp1, i) > 0
                    cnt_tp1 += 1
                if array.get(hist_tp2, i) > 0
                    cnt_tp2 += 1
                if array.get(hist_tp3, i) > 0
                    cnt_tp3 += 1
                if array.get(hist_sl, i) > 0
                    cnt_sl += 1

        table.cell(pt, 0, 0, "⚡ Last " + str.tostring(trades_limit),
             text_color=color_bg, text_size=pts_text_size, bgcolor=color_main, text_halign=text.align_center)
        table.cell(pt, 1, 0, "🎯 TP1",
             text_color=tp1_color, text_size=pts_text_size, bgcolor=color_main, text_halign=text.align_center)
        table.cell(pt, 2, 0, "🚀 TP2",
             text_color=tp2_color, text_size=pts_text_size, bgcolor=color_main, text_halign=text.align_center)
        table.cell(pt, 3, 0, "🏆 TP3",
             text_color=tp3_color, text_size=pts_text_size, bgcolor=color_main, text_halign=text.align_center)
        table.cell(pt, 4, 0, "✘ SL",
             text_color=color_loss, text_size=pts_text_size, bgcolor=color_main, text_halign=text.align_center)

        table.cell(pt, 0, 1, "Count (" + str.tostring(n) + ")",
             text_color=color.white, text_size=pts_text_size, bgcolor=color.new(color_bg, 20), text_halign=text.align_left)
        table.cell(pt, 1, 1, str.tostring(cnt_tp1) + "x",
             text_color=tp1_color, text_size=pts_text_size, bgcolor=color.new(color_bg, 20), text_halign=text.align_center)
        table.cell(pt, 2, 1, str.tostring(cnt_tp2) + "x",
             text_color=tp2_color, text_size=pts_text_size, bgcolor=color.new(color_bg, 20), text_halign=text.align_center)
        table.cell(pt, 3, 1, str.tostring(cnt_tp3) + "x",
             text_color=tp3_color, text_size=pts_text_size, bgcolor=color.new(color_bg, 20), text_halign=text.align_center)
        table.cell(pt, 4, 1, str.tostring(cnt_sl) + "x",
             text_color=color_loss, text_size=pts_text_size, bgcolor=color.new(color_bg, 20), text_halign=text.align_center)
````
