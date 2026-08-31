<!-- tradingview-pine-id: PUB;a66bb021f2584b43bb957a29e4c029c1 -->
<!-- tradingviewscripts-format: 1 -->
# CTZ Cycle Trader + 

Source: https://www.tradingview.com/script/OM1qOcm1-CTZ-Cycle-Trader/

## Description

Here's a description positioning this as the upgrade to Cycle Trader v1.6 — it leads with what's new (the Tidewave signal engine and cycle-gating) while covering the cycle framework that carried over.

---

**CTZ Cycle Trader + Tidewave** — *the v1.6 cycle engine, now with entry timing built in.*

Cycle Trader v1.6 told you **where** you were in the cycle. This upgrade adds **when to act** — a WaveTrend + RSI reversal engine ("Tidewave") layered directly on top of the cycle framework, so momentum triggers and cycle position work as one tool instead of two.

**What's carried over from v1.6**

The full four-tier cycle model is intact: Daily (DCL), Weekly (WCL), Yearly (YCL) and 4-Year (4YCL) cycle lows, each with its own confirmation logic, cycle counts, and asset-tuned timing windows. The auto-detect presets, the Future Cycle Low Range projection boxes, the due-date forecasting, and the live dashboard all remain — nothing was stripped to make room.

**What's new in this build**

*Tidewave signal engine.* A WaveTrend oscillator confirmed by RSI now prints bull and bear reversal arrows on the chart, with the same timeframe auto-adjustment philosophy as the cycle counts — tighter and more reactive on lower timeframes, more selective on the higher ones. Four marker styles, an adjustable overlay EMA, and independent alerts.

*Cycle-turn gating — the headline feature.* This is what makes the two halves talk to each other. Instead of firing on every momentum cross, Tidewave signals can be filtered to only appear within a set window of a projected cycle turn: **buy signals near cycle lows, sell signals near cycle highs.** The gate reads directly from the live DCL/WCL cycle position, measuring how far through each cycle price sits and only releasing a signal when it lines up with an expected turn. The tolerance is adjustable (default ~1 week on a daily chart), and the whole gate is a single toggle — turn it off for raw signals, on to strip out the mid-cycle noise.

*Cleaner charts by default.* State labels and arcs stay off unless you want them; the signal layer has its own master toggle, so you can run pure cycle analysis, pure signals, or the full combined view.

**Why it matters**

A momentum signal at the wrong point in the cycle is a trap; a cycle low with no trigger is a guess. Gating one with the other is the confluence this build is built around — the cycle tells you the pitch is coming, Tidewave tells you to swing.

*For educational purposes. Not financial advice — always test on your own instruments and timeframes before trading live.*

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CTZ / HumanPay — CTZ Cycle Trader v1.6 + Tidewave (combined, cycle-gated)

//@version=6
indicator("CTZ Cycle Trader + ", shorttitle="CTZ CT+", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=100,
     max_polylines_count=10, max_bars_back=1000)

// ══════════════════════════════════════════════════════════════
//  ░░ TIDEWAVE SIGNAL INPUTS ░░
// ══════════════════════════════════════════════════════════════
grpTW = "🌊 Tidewave Signals"
showTidewave = input.bool(true, "Show Tidewave Signals", group=grpTW)
triggerStyle = input.string("Label Arrow", "Trigger Style",
     options=["Label Arrow", "Circle Dot", "Triangle", "Square"], group=grpTW)
tw_alerts    = input.bool(true, "Enable Tidewave Alerts", group=grpTW)
rsiOB        = input.int(70, "RSI Overbought Level", group=grpTW)
rsiOS        = input.int(30, "RSI Oversold Level",   group=grpTW)
emaLen       = input.int(10, "Tidewave EMA Length",  group=grpTW)
cycleGate = input.bool(true, "Only signal near cycle turns", group=grpTW)
cycleTol  = input.int(7, "Cycle turn tolerance (bars)", minval=1, group=grpTW, tooltip="How close (in bars) a signal must sit to a projected cycle high or low. 7 ≈ one week on a daily chart.")

// ── ASSET PRESETS ──────────────────────────────────────────────
grpA = "⚙️ Asset Cycle Counts"
count_mode = input.string("Auto-Detect", "Count Mode", options=["Auto-Detect", "Asset Class", "Manual"], group=grpA,
     tooltip="Auto-Detect: matches the chart ticker to a preset. Asset Class: uses the class selected below regardless of ticker. Manual: uses the manual inputs.")
asset_class = input.string("Bitcoin / Crypto", "Asset Class", options=["Stocks / Indices", "Metals", "Bitcoin / Crypto", "Forex / DXY", "Oil / Energy"], group=grpA,
     tooltip="Only used when Count Mode is set to Asset Class.")
in_dmin = input.int(36, "Manual: Daily Cycle Min (days)",    group=grpA)
in_dmax = input.int(44, "Manual: Daily Cycle Max (days)",    group=grpA)
in_wmin = input.int(22, "Manual: Weekly Cycle Min (weeks)",  group=grpA)
in_wmax = input.int(31, "Manual: Weekly Cycle Max (weeks)",  group=grpA)
in_yrs  = input.int(1,  "Manual: Yearly Cycle (years)",      group=grpA)
in_4yrs = input.int(4,  "Manual: Long Cycle (years)",        group=grpA)

f_class() =>
    int dMin = 36
    int dMax = 44
    int wMin = 22
    int wMax = 31
    int yrs  = 1
    int lyrs = 4
    if asset_class == "Stocks / Indices"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        yrs  := 1
        lyrs := 4
    if asset_class == "Metals"
        dMin := 22
        dMax := 28
        wMin := 20
        wMax := 26
        yrs  := 1
        lyrs := 8
    if asset_class == "Bitcoin / Crypto"
        dMin := 54
        dMax := 66
        wMin := 24
        wMax := 34
        yrs  := 1
        lyrs := 4
    if asset_class == "Forex / DXY"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        yrs  := 1
        lyrs := 15
    if asset_class == "Oil / Energy"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        yrs  := 1
        lyrs := 3
    [dMin, dMax, wMin, wMax, yrs, lyrs]

f_preset() =>
    string t  = syminfo.ticker
    int dMin  = 36
    int dMax  = 44
    int wMin  = 22
    int wMax  = 31
    bool tuned = false
    if t == "SPX" or t == "SPY" or t == "ES1!" or t == "US500" or t == "NDX" or t == "QQQ" or t == "NQ1!" or t == "DJI" or t == "YM1!"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        tuned := true
    if t == "BTCUSD" or t == "BTCUSDT" or t == "XBTUSD" or t == "BTCUSDT.P"
        dMin := 54
        dMax := 66
        wMin := 24
        wMax := 34
        tuned := true
    if t == "ETHUSD" or t == "ETHUSDT" or t == "ETHUSDT.P"
        dMin := 54
        dMax := 66
        wMin := 24
        wMax := 34
        tuned := true
    if t == "GOLD" or t == "XAUUSD" or t == "GC1!" or t == "GLD"
        dMin := 22
        dMax := 28
        wMin := 20
        wMax := 26
        tuned := true
    if t == "SILVER" or t == "XAGUSD" or t == "SI1!"
        dMin := 22
        dMax := 28
        wMin := 20
        wMax := 26
        tuned := true
    if t == "DXY" or t == "DX1!"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        tuned := true
    if t == "USOIL" or t == "CL1!" or t == "UKOIL"
        dMin := 36
        dMax := 44
        wMin := 22
        wMax := 31
        tuned := true
    [dMin, dMax, wMin, wMax, tuned]

[pDmin, pDmax, pWmin, pWmax, asset_tuned] = f_preset()
[cDmin, cDmax, cWmin, cWmax, cYrs, cLyrs] = f_class()

int dMin = count_mode == "Manual" ? in_dmin : count_mode == "Asset Class" ? cDmin : pDmin
int dMax = count_mode == "Manual" ? in_dmax : count_mode == "Asset Class" ? cDmax : pDmax
int wMin = count_mode == "Manual" ? in_wmin : count_mode == "Asset Class" ? cWmin : pWmin
int wMax = count_mode == "Manual" ? in_wmax : count_mode == "Asset Class" ? cWmax : pWmax
int yYrs  = count_mode == "Asset Class" ? cYrs  : in_yrs
int y4Yrs = count_mode == "Asset Class" ? cLyrs : in_4yrs

int dpw = syminfo.type == "crypto" ? 7 : 5
int dpy = syminfo.type == "crypto" ? 365 : 252

// ── CYCLE TIER SETTINGS ────────────────────────────────────────
grpD = "🟢 Daily Cycle Lows (DCL)"
show_dcl  = input.bool(true, "Show DCLs",                         group=grpD)
dcl_lb    = input.int(4,  "DCL Pivot Lookback (bars)", minval=2,  group=grpD)
conf_len  = input.int(10, "Confirmation SMA Length",   minval=2,  group=grpD)
dcl_col   = input.color(color.new(#22c55e, 0), "DCL Colour",      group=grpD)
show_dcnt = input.bool(true, "Show Cycle Count (##D)",            group=grpD)

grpW = "🔵 Weekly Cycle Lows (WCL)"
show_wcl  = input.bool(true, "Show WCLs",                         group=grpW)
wcl_lb    = input.int(21, "WCL Pivot Lookback (bars)", minval=5,  group=grpW)
wcl_col   = input.color(color.new(#3b82f6, 0), "WCL Colour",      group=grpW)
show_wcnt = input.bool(true, "Show Cycle Count (##W)",            group=grpW)
wcl_icon  = input.string("🚀", "WCL Icon", options=["🚀", "⚡", "Ⓧ", "💠", "🤝", "🐫", "Ⓦ", "▲", "●", "None"], group=grpW,
     tooltip="🚀 default. Ⓧ = Xetro. Or type anything in the Custom Icon box below to override this dropdown.")
wcl_icon_custom = input.string("", "Custom WCL Icon (overrides dropdown)", group=grpW)

grpY = "🟡 Yearly Cycle Lows (YCL)"
show_ycl = input.bool(true, "Show YCLs",                          group=grpY)
ycl_lb   = input.int(60, "YCL Pivot Lookback (bars)", minval=20,  group=grpY)
ycl_gap  = input.float(0.75, "YCL Min Spacing (× cycle length)", step=0.05, minval=0.3, maxval=1.0, group=grpY,
     tooltip="How far through the nominal yearly cycle before a NEW (higher) low can be accepted. Lower lows within the window always supersede regardless.")
ycl_col  = input.color(color.new(#f59e0b, 0), "YCL Colour",       group=grpY)

grp4 = "🟣 4-Year Cycle Lows (4YCL)"
show_4ycl = input.bool(true, "Show 4YCLs",                        group=grp4)
_4ycl_lb  = input.int(100, "4YCL Pivot Lookback (bars)", minval=40, group=grp4)
_4ycl_gap = input.float(0.95, "4YCL Min Spacing (× cycle length)", step=0.01, minval=0.5, maxval=1.0, group=grp4,
     tooltip="0.95 × 4 years ≈ 1,387 days. BTC's last two cycles ran 1,431 and 1,437 days low-to-low, so the gate stays shut until the true window. Lower lows within the window always supersede regardless.")
_4ycl_col = input.color(color.new(#c084fc, 0), "4YCL Colour",     group=grp4)

// ── EXTRAS (all optional, clean defaults) ──────────────────────
grpF = "📦 Future Cycle Low Range (FCLR)"
show_fclr_d  = input.bool(true, "Show Daily FCLR",                group=grpF)
show_fclr_w  = input.bool(true, "Show Weekly FCLR",               group=grpF)
show_fclr_lc = input.bool(true, "Show Long Cycle FCLR",           group=grpF)
fclr_d_col   = input.color(color.new(#3b82f6, 78), "Daily FCLR Colour",  group=grpF)
fclr_w_col   = input.color(color.new(#f59e0b, 80), "Weekly FCLR Colour", group=grpF)
fclr_lc_col  = input.color(color.new(#c084fc, 82), "Long Cycle FCLR Colour", group=grpF)
lc_win_max   = input.float(1.02, "Long Cycle Window Max (× cycle length)", step=0.01, minval=0.9, maxval=1.3, group=grpF,
     tooltip="Long cycle window spans from the Min Spacing gate (4YCL settings) to this multiple. For BTC 0.95–1.02 × 4y ≈ 1,387–1,489 days, bracketing the 1,431–1,437 day historical lows.")

grpE = "🧩 Optional Extras"
show_states = input.bool(false, "Show State Labels (🕓 pending / ❌ cancelled)", group=grpE)
show_arcs   = input.bool(false, "Show Cycle Arcs",                              group=grpE)
arc_updown  = input.float(0.0,  "Arc Vertical Offset (% of price)", step=0.5,   group=grpE)
arc_height  = input.float(2.0,  "Arc Height (% of price)", step=0.25, minval=0.1, group=grpE)
arc_back    = input.int(12, "Arc Cycles Back",    minval=1, maxval=30, group=grpE)
arc_fwd     = input.int(2,  "Arc Cycles Forward", minval=0, maxval=6,  group=grpE)
arc_col     = input.color(color.new(#eab308, 15), "Arc Colour",        group=grpE)
show_sma    = input.bool(true, "Show SMA",                             group=grpE)
sma_len     = input.int(10, "SMA Length",                              group=grpE)
sma_col     = input.color(color.new(color.orange, 20), "SMA Colour",   group=grpE)

grpX = "🖥 Dashboard / Alerts"
show_dash = input.bool(true, "Show Dashboard",                    group=grpX)
al_dcl    = input.bool(true, "Alert: DCL events",                 group=grpX)
al_wcl    = input.bool(true, "Alert: WCL events",                 group=grpX)
al_zone   = input.bool(true, "Alert: Price enters FCLR window",   group=grpX)

// ── CORE SERIES ────────────────────────────────────────────────
smaV  = ta.sma(close, sma_len)
adr   = ta.sma(high - low, 14)
sma40 = ta.sma(close, 40)
hi60  = ta.highest(high, 60)
lo60  = ta.lowest(low, 60)
plot(show_sma ? smaV : na, "SMA", color=sma_col, linewidth=2)

// ── PIVOTS ─────────────────────────────────────────────────────
dcl_piv   = ta.pivotlow(low, dcl_lb, dcl_lb)
wcl_piv   = ta.pivotlow(low, wcl_lb, wcl_lb)
ycl_piv   = ta.pivotlow(low, ycl_lb, ycl_lb)
_4ycl_piv = ta.pivotlow(low, _4ycl_lb, _4ycl_lb)

// ── LABEL QUEUES ───────────────────────────────────────────────
var array<label> dcl_q   = array.new<label>()
var array<label> wcl_q   = array.new<label>()
var array<label> ycl_q   = array.new<label>()
var array<label> _4ycl_q = array.new<label>()

f_cap(q, n) =>
    if array.size(q) > n
        label.delete(array.shift(q))

// ══════════════════════════════════════════════════════════════
//  DCL STATE MACHINE (0 none · 1 pending · 2 confirmed · 3 cancelled)
// ══════════════════════════════════════════════════════════════
var int   dcl_state     = 0
var float dcl_px        = na
var int   dcl_bar       = na
var int   dcl_conf_bar  = na
var int   dcl_prev_conf = na
var label dcl_lab       = na
var bool  dcl_was_upd   = false

int dcl_min_gap = math.max(5, math.round(dMin * 0.6))

bool new_dcl = not na(dcl_piv) and show_dcl and
     (na(dcl_bar) or (bar_index - dcl_lb) - dcl_bar >= dcl_min_gap or dcl_state == 3)

bool dcl_pending_now = false
bool dcl_conf_now    = false
bool dcl_cancel_now  = false
bool dcl_update_now  = false

if new_dcl
    bool was_cancelled = dcl_state == 3
    dcl_px      := low[dcl_lb]
    dcl_bar     := bar_index - dcl_lb
    dcl_state   := 1
    dcl_was_upd := was_cancelled
    dcl_pending_now := true
    dcl_update_now  := was_cancelled
    label.delete(dcl_lab)
    if show_states
        string ptxt = was_cancelled ? "🔄 DCL?" : "🕓 DCL?"
        dcl_lab := label.new(dcl_bar, dcl_px - adr * 1.0, ptxt,
             style=label.style_label_up, color=color.new(color.gray, 30),
             textcolor=color.white, size=size.small)

if dcl_state == 1 and close > smaV and bar_index > dcl_bar
    dcl_state := 2
    dcl_conf_now := true
    dcl_prev_conf := dcl_conf_bar
    dcl_conf_bar  := dcl_bar
    int len_d = na(dcl_prev_conf) ? na : dcl_bar - dcl_prev_conf
    string cnt = show_dcnt and not na(len_d) ? " " + str.tostring(len_d) + "D" : " DCL"
    label.delete(dcl_lab)
    dcl_lab := label.new(dcl_bar, dcl_px - adr * 1.0, "✅" + cnt,
         style=label.style_label_up, color=color.new(dcl_col, 10),
         textcolor=color.white, size=size.small)
    array.push(dcl_q, dcl_lab)
    dcl_lab := na
    f_cap(dcl_q, 40)

if dcl_state == 2 and close < dcl_px
    dcl_state := 3
    dcl_cancel_now := true
    if show_states
        label xl = label.new(bar_index, low - adr * 1.0, "❌ DCL",
             style=label.style_label_up, color=color.new(#ef4444, 10),
             textcolor=color.white, size=size.small)
        array.push(dcl_q, xl)
        f_cap(dcl_q, 40)

// ══════════════════════════════════════════════════════════════
//  WCL STATE MACHINE
// ══════════════════════════════════════════════════════════════
var int   wcl_state     = 0
var float wcl_px        = na
var int   wcl_bar       = na
var int   wcl_conf_bar  = na
var int   wcl_prev_conf = na
var label wcl_lab       = na

int wcl_min_gap = math.max(20, math.round(wMin * dpw * 0.6))

bool new_wcl = not na(wcl_piv) and show_wcl and
     (na(wcl_bar) or (bar_index - wcl_lb) - wcl_bar >= wcl_min_gap or wcl_state == 3)

bool wcl_pending_now = false
bool wcl_conf_now    = false
bool wcl_cancel_now  = false

if new_wcl
    bool was_cancelled = wcl_state == 3
    wcl_px    := low[wcl_lb]
    wcl_bar   := bar_index - wcl_lb
    wcl_state := 1
    wcl_pending_now := true
    label.delete(wcl_lab)
    if show_states
        string ptxt = was_cancelled ? "🔄 WCL?" : "🕓 WCL?"
        wcl_lab := label.new(wcl_bar, wcl_px - adr * 3.0, ptxt,
             style=label.style_label_up, color=color.new(color.gray, 30),
             textcolor=color.white, size=size.normal)

if wcl_state == 1 and close > sma40 and bar_index > wcl_bar
    wcl_state := 2
    wcl_conf_now := true
    wcl_prev_conf := wcl_conf_bar
    wcl_conf_bar  := wcl_bar
    int len_w = na(wcl_prev_conf) ? na : math.round((wcl_bar - wcl_prev_conf) / float(dpw))
    string cnt  = show_wcnt and not na(len_w) ? " " + str.tostring(len_w) + "W" : " WCL"
    string icon = wcl_icon_custom != "" ? wcl_icon_custom : wcl_icon == "None" ? "✅" : wcl_icon
    label.delete(wcl_lab)
    wcl_lab := label.new(wcl_bar, wcl_px - adr * 3.0, icon + cnt,
         style=label.style_label_up, color=color.new(wcl_col, 10),
         textcolor=color.white, size=size.normal)
    array.push(wcl_q, wcl_lab)
    wcl_lab := na
    f_cap(wcl_q, 20)

if wcl_state == 2 and close < wcl_px
    wcl_state := 3
    wcl_cancel_now := true
    if show_states
        label xl = label.new(bar_index, low - adr * 3.0, "❌ WCL",
             style=label.style_label_up, color=color.new(#b91c1c, 10),
             textcolor=color.white, size=size.normal)
        array.push(wcl_q, xl)
        f_cap(wcl_q, 20)

// ══════════════════════════════════════════════════════════════
//  YCL — pivots with ~1 year spacing, lower low SUPERSEDES within window
// ══════════════════════════════════════════════════════════════
var int   ycl_conf_bar = na
var float ycl_px       = na
int ycl_min_gap = math.round(yYrs * dpy * ycl_gap)

bool new_ycl = false

if not na(ycl_piv) and show_ycl
    int   pbar = bar_index - ycl_lb
    float ppx  = low[ycl_lb]
    bool  new_window = na(ycl_conf_bar) or pbar - ycl_conf_bar >= ycl_min_gap
    bool  lower_low  = not new_window and not na(ycl_px) and ppx < ycl_px
    if new_window or lower_low
        if lower_low and array.size(ycl_q) > 0
            label.delete(array.pop(ycl_q))
        ycl_conf_bar := pbar
        ycl_px       := ppx
        new_ycl      := true
        label yl = label.new(ycl_conf_bar, ycl_px - adr * 6.0, "★ YCL",
             style=label.style_label_up, color=color.new(ycl_col, 5),
             textcolor=color.black, size=size.large)
        array.push(ycl_q, yl)
        f_cap(ycl_q, 8)

// ══════════════════════════════════════════════════════════════
//  4YCL — pivots with ~4 year spacing, lower low SUPERSEDES within window
// ══════════════════════════════════════════════════════════════
var int   _4ycl_conf_bar = na
var float _4ycl_px       = na
int _4ycl_min_gap = math.round(y4Yrs * dpy * _4ycl_gap)

bool new_4ycl = false

if not na(_4ycl_piv) and show_4ycl
    int   pbar = bar_index - _4ycl_lb
    float ppx  = low[_4ycl_lb]
    bool  new_window = na(_4ycl_conf_bar) or pbar - _4ycl_conf_bar >= _4ycl_min_gap
    bool  lower_low  = not new_window and not na(_4ycl_px) and ppx < _4ycl_px
    if new_window or lower_low
        if lower_low and array.size(_4ycl_q) > 0
            label.delete(array.pop(_4ycl_q))
        _4ycl_conf_bar := pbar
        _4ycl_px       := ppx
        new_4ycl       := true
        label fl = label.new(_4ycl_conf_bar, _4ycl_px - adr * 10.0, "◆ " + str.tostring(y4Yrs) + "YCL",
             style=label.style_label_up, color=color.new(_4ycl_col, 0),
             textcolor=color.white, size=size.huge)
        array.push(_4ycl_q, fl)
        f_cap(_4ycl_q, 4)

// ══════════════════════════════════════════════════════════════
//  FUTURE CYCLE LOW RANGES
// ══════════════════════════════════════════════════════════════
var box   fclr_d_box  = na
var box   fclr_w_box  = na
var box   fclr_lc_box = na
var label fclr_d_lab  = na
var label fclr_w_lab  = na
var label fclr_lc_lab = na

int lc_from = na(_4ycl_conf_bar) ? na : _4ycl_conf_bar + math.round(y4Yrs * dpy * _4ycl_gap)
int lc_to   = na(_4ycl_conf_bar) ? na : _4ycl_conf_bar + math.round(y4Yrs * dpy * lc_win_max)

bool d_in_zone  = not na(dcl_conf_bar) and bar_index >= dcl_conf_bar + dMin and bar_index <= dcl_conf_bar + dMax
bool w_in_zone  = not na(wcl_conf_bar) and bar_index >= wcl_conf_bar + wMin * dpw and bar_index <= wcl_conf_bar + wMax * dpw
bool lc_in_zone = not na(lc_from) and bar_index >= lc_from and bar_index <= lc_to

f_futdate(bars_ahead) =>
    float cal_days = bars_ahead * (dpw == 7 ? 1.0 : 7.0 / 5.0)
    str.format_time(time + math.round(cal_days) * 86400000, "dd MMM ''yy", syminfo.timezone)

if barstate.islast
    box.delete(fclr_d_box)
    box.delete(fclr_w_box)
    label.delete(fclr_d_lab)
    label.delete(fclr_w_lab)
    float top = hi60 * 1.02
    float bot = lo60 * 0.98
    if show_fclr_d and not na(dcl_conf_bar)
        int f1 = math.min(dcl_conf_bar + dMin, bar_index + 490)
        int f2 = math.min(dcl_conf_bar + dMax, bar_index + 495)
        if f2 > bar_index - 10
            fclr_d_box := box.new(f1, top, f2, bot, border_color=color.new(fclr_d_col, 30),
                 bgcolor=fclr_d_col, border_width=1, xloc=xloc.bar_index)
            fclr_d_lab := label.new(math.round((f1 + f2) / 2), bot, "DCL WINDOW\n" +
                 str.tostring(dMin) + "–" + str.tostring(dMax) + "D",
                 style=label.style_label_up, color=color.new(fclr_d_col, 20),
                 textcolor=color.white, size=size.small, xloc=xloc.bar_index)
    if show_fclr_w and not na(wcl_conf_bar)
        int f1 = math.min(wcl_conf_bar + wMin * dpw, bar_index + 490)
        int f2 = math.min(wcl_conf_bar + wMax * dpw, bar_index + 495)
        if f2 > bar_index - 10
            fclr_w_box := box.new(f1, top, f2, bot, border_color=color.new(fclr_w_col, 30),
                 bgcolor=fclr_w_col, border_width=1, xloc=xloc.bar_index)
            fclr_w_lab := label.new(math.round((f1 + f2) / 2), top, "WCL WINDOW\n" +
                 str.tostring(wMin) + "–" + str.tostring(wMax) + "W",
                 style=label.style_label_down, color=color.new(fclr_w_col, 20),
                 textcolor=color.white, size=size.small, xloc=xloc.bar_index)
    label.delete(fclr_lc_lab)
    box.delete(fclr_lc_box)
    if show_fclr_lc and not na(lc_from)
        int f1 = math.min(lc_from, bar_index + 490)
        int f2 = math.min(lc_to,   bar_index + 495)
        if f2 > bar_index - 10
            fclr_lc_box := box.new(f1, top, f2, bot, border_color=color.new(fclr_lc_col, 30),
                 bgcolor=fclr_lc_col, border_width=1, xloc=xloc.bar_index)
            fclr_lc_lab := label.new(math.round((f1 + f2) / 2), top, str.tostring(y4Yrs) + "YCL WINDOW",
                 style=label.style_label_down, color=color.new(fclr_lc_col, 10),
                 textcolor=color.white, size=size.small, xloc=xloc.bar_index)

// ══════════════════════════════════════════════════════════════
//  CYCLE ARCS (optional, off by default)
// ══════════════════════════════════════════════════════════════
var polyline arc_pl = na

if barstate.islast
    polyline.delete(arc_pl)
    if show_arcs and not na(dcl_conf_bar)
        int   period = math.max(4, math.round((dMin + dMax) / 2.0))
        float center = close * (1 + arc_updown / 100)
        float amp    = close * (arc_height / 100)
        int   x0 = math.max(0, dcl_conf_bar - arc_back * period)
        int   x1 = math.min(dcl_conf_bar + arc_fwd * period, bar_index + 480)
        int   stp = math.max(1, math.round(period / 12.0))
        array<chart.point> pts = array.new<chart.point>()
        int x = x0
        while x <= x1 and array.size(pts) < 480
            float y = center - amp * math.cos(2 * math.pi * (x - dcl_conf_bar) / period)
            array.push(pts, chart.point.from_index(x, y))
            x += stp
        if array.size(pts) > 2
            arc_pl := polyline.new(pts, curved=true, closed=false,
                 xloc=xloc.bar_index, line_color=arc_col, line_width=2)

// ══════════════════════════════════════════════════════════════
//  DASHBOARD
// ══════════════════════════════════════════════════════════════
var table d = na

if show_dash and barstate.islast
    if na(d)
        d := table.new(position.bottom_right, 2, 17,
             bgcolor=color.new(#0a0f1e, 10), border_width=1,
             border_color=color.new(color.white, 75))

    string hdr = count_mode == "Asset Class" ? "🏷 " + asset_class :
         asset_tuned and count_mode == "Auto-Detect" ? "✅ Finetuned Asset Detected ✅" :
         count_mode == "Manual" ? "Manual Count Selected" : "Default Count Selected"
    table.cell(d, 0, 0, hdr, bgcolor=color.new(#14532d, 0), text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 0, syminfo.ticker, bgcolor=color.new(#14532d, 0), text_color=color.white, text_size=size.small)

    table.cell(d, 0, 1, "CTZ CYCLE COUNT", bgcolor=color.new(#1e293b, 0), text_color=color.new(#86efac, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 1, "", bgcolor=color.new(#1e293b, 0))
    table.cell(d, 0, 2, "Daily Cycle Range",  text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 2, str.tostring(dMin) + "–" + str.tostring(dMax) + " days",  text_color=color.white, text_size=size.small)
    table.cell(d, 0, 3, "Weekly Cycle Range", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 3, str.tostring(wMin) + "–" + str.tostring(wMax) + " weeks", text_color=color.white, text_size=size.small)
    table.cell(d, 0, 4, "Yearly Cycle Range", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 4, str.tostring(yYrs) + " year", text_color=color.white, text_size=size.small)
    table.cell(d, 0, 5, "Long Cycle Range", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 5, str.tostring(y4Yrs) + " years", text_color=color.white, text_size=size.small)

    table.cell(d, 0, 6, "CYCLE LOW WINDOWS", bgcolor=color.new(#1e293b, 0), text_color=color.new(#86efac, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 6, "", bgcolor=color.new(#1e293b, 0))

    table.cell(d, 0, 7, "✅ Confirmed", text_color=color.new(#22c55e, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 7, "", text_size=size.small)
    int conf_d  = na(dcl_conf_bar)   ? na : bar_index - dcl_conf_bar
    int conf_w  = na(wcl_conf_bar)   ? na : math.round((bar_index - wcl_conf_bar) / float(dpw))
    int conf_y  = na(ycl_conf_bar)   ? na : math.round((bar_index - ycl_conf_bar) / float(dpw))
    int conf_4y = na(_4ycl_conf_bar) ? na : math.round((bar_index - _4ycl_conf_bar) / float(dpw))
    table.cell(d, 0, 8, "Days since Last DCL",   text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 8, na(conf_d) ? "–" : str.tostring(conf_d), text_color=d_in_zone ? color.yellow : color.white, text_size=size.small)
    table.cell(d, 0, 9, "Weeks since Last WCL",  text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 9, na(conf_w) ? "–" : str.tostring(conf_w), text_color=w_in_zone ? color.yellow : color.white, text_size=size.small)
    table.cell(d, 0, 10, "Weeks since Last YCL",  text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 10, na(conf_y) ? "–" : str.tostring(conf_y), text_color=color.white, text_size=size.small)
    table.cell(d, 0, 11, "Weeks since Last 4YCL", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 11, na(conf_4y) ? "–" : str.tostring(conf_4y), text_color=color.white, text_size=size.small)

    table.cell(d, 0, 12, "🕓 Unconfirmed", text_color=color.new(color.white, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 12, "", text_size=size.small)
    int pend_d = dcl_state == 1 and not na(dcl_bar) ? bar_index - dcl_bar : na
    int pend_w = wcl_state == 1 and not na(wcl_bar) ? math.round((bar_index - wcl_bar) / float(dpw)) : na
    table.cell(d, 0, 13, "DCL / WCL pending", text_color=color.new(color.white, 40), text_size=size.small)
    table.cell(d, 1, 13, (na(pend_d) ? "–" : str.tostring(pend_d) + "D") + " / " + (na(pend_w) ? "–" : str.tostring(pend_w) + "W"),
         text_color=color.new(color.white, 20), text_size=size.small)

    string zone_str = d_in_zone ? "⚡ IN DCL WINDOW" : w_in_zone ? "⚡ IN WCL WINDOW" : lc_in_zone ? "⚡ IN " + str.tostring(y4Yrs) + "YCL WINDOW" : "Outside windows"
    table.cell(d, 0, 14, "Status", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 14, zone_str, text_color=d_in_zone or w_in_zone or lc_in_zone ? color.yellow : color.new(color.white, 50), text_size=size.small)

    string wcl_due = "–"
    if not na(wcl_conf_bar)
        int w_open  = wcl_conf_bar + wMin * dpw - bar_index
        int w_close = wcl_conf_bar + wMax * dpw - bar_index
        wcl_due := w_close < 0 ? "⚠ OVERDUE" : w_open <= 0 ? "⚡ NOW – " + f_futdate(w_close) : f_futdate(w_open) + " – " + f_futdate(w_close)
    table.cell(d, 0, 15, "Next WCL due", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 15, wcl_due, text_color=w_in_zone ? color.yellow : wcl_col, text_size=size.small)

    string lc_due = "–"
    if not na(lc_from)
        int l_open  = lc_from - bar_index
        int l_close = lc_to - bar_index
        lc_due := l_close < 0 ? "⚠ OVERDUE" : l_open <= 0 ? "⚡ NOW – " + f_futdate(l_close) : f_futdate(l_open) + " – " + f_futdate(l_close)
    table.cell(d, 0, 16, "Next " + str.tostring(y4Yrs) + "YCL due", text_color=color.new(color.white, 30), text_size=size.small)
    table.cell(d, 1, 16, lc_due, text_color=lc_in_zone ? color.yellow : _4ycl_col, text_size=size.small)

// ══════════════════════════════════════════════════════════════
//  CYCLE ALERTS
// ══════════════════════════════════════════════════════════════
bool d_zone_entry  = d_in_zone and not d_in_zone[1]
bool w_zone_entry  = w_in_zone and not w_in_zone[1]
bool lc_zone_entry = lc_in_zone and not lc_in_zone[1]

if al_dcl and dcl_conf_now
    alert("CTZ Cycle: ✅ DCL CONFIRMED — " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar_close)
if al_dcl and dcl_cancel_now
    alert("CTZ Cycle: ❌ DCL CANCELLED — " + syminfo.ticker, alert.freq_once_per_bar_close)
if al_wcl and wcl_conf_now
    alert("CTZ Cycle: ✅ WCL CONFIRMED — " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar_close)
if al_wcl and wcl_cancel_now
    alert("CTZ Cycle: ❌ WCL CANCELLED — " + syminfo.ticker, alert.freq_once_per_bar_close)
if al_zone and d_zone_entry
    alert("CTZ Cycle: ⚡ Price entered DAILY cycle low window — " + syminfo.ticker, alert.freq_once_per_bar_close)
if al_zone and w_zone_entry
    alert("CTZ Cycle: ⚡ Price entered WEEKLY cycle low window — " + syminfo.ticker, alert.freq_once_per_bar_close)
if al_zone and lc_zone_entry
    alert("CTZ Cycle: ⚡ Price entered " + str.tostring(y4Yrs) + "-YEAR cycle low window — " + syminfo.ticker, alert.freq_once_per_bar_close)

alertcondition(dcl_conf_now,   "DCL Confirmed",    "CTZ Cycle ✅ DCL — {{ticker}} @ {{close}}")
alertcondition(dcl_cancel_now, "DCL Cancelled",    "CTZ Cycle ❌ DCL cancelled — {{ticker}}")
alertcondition(wcl_conf_now,   "WCL Confirmed",    "CTZ Cycle ✅ WCL — {{ticker}} @ {{close}}")
alertcondition(new_ycl,        "YCL Detected",     "CTZ Cycle ★ YCL — {{ticker}}")
alertcondition(new_4ycl,       "4YCL Detected",    "CTZ Cycle ◆ 4YCL — {{ticker}}")
alertcondition(d_zone_entry,   "In Daily Window",  "CTZ Cycle ⚡ DCL window — {{ticker}}")
alertcondition(w_zone_entry,   "In Weekly Window", "CTZ Cycle ⚡ WCL window — {{ticker}}")
alertcondition(lc_zone_entry,  "In Long Cycle Window", "CTZ Cycle ⚡ Long cycle window — {{ticker}}")

// ── DATA WINDOW ────────────────────────────────────────────────
plot(na(dcl_conf_bar) ? na : bar_index - dcl_conf_bar, "Days since DCL",  display=display.data_window)
plot(na(wcl_conf_bar) ? na : (bar_index - wcl_conf_bar) / dpw, "Weeks since WCL", display=display.data_window)
plot(d_in_zone ? 1 : 0, "In DCL Window", display=display.data_window)
plot(w_in_zone ? 1 : 0, "In WCL Window", display=display.data_window)

// ══════════════════════════════════════════════════════════════
//  ░░ TIDEWAVE ENGINE (WaveTrend + RSI reversal signals) ░░
// ══════════════════════════════════════════════════════════════
tw_tf = timeframe.period
n1 = 10
n2 = 21
tw_rsiLen = 14
wtOB = 60.0
wtOS = -60.0

if tw_tf == "1" or tw_tf == "3" or tw_tf == "5"
    n1 := 7
    n2 := 14
    tw_rsiLen := 9
    wtOB := 75.0
    wtOS := -75.0
else if tw_tf == "15" or tw_tf == "30"
    n1 := 9
    n2 := 18
    tw_rsiLen := 12
    wtOB := 70.0
    wtOS := -70.0
else if tw_tf == "60" or tw_tf == "120"
    n1 := 10
    n2 := 21
    tw_rsiLen := 14
    wtOB := 60.0
    wtOS := -60.0
else if tw_tf == "240" or tw_tf == "1D"
    n1 := 12
    n2 := 24
    tw_rsiLen := 14
    wtOB := 55.0
    wtOS := -55.0
else
    n1 := 14
    n2 := 28
    tw_rsiLen := 21
    wtOB := 50.0
    wtOS := -50.0

ap  = hlc3
esa = ta.ema(ap, n1)
wtD = ta.ema(math.abs(ap - esa), n1)
ci  = (ap - esa) / (0.015 * wtD)
wt1 = ta.ema(ci, n2)
wt2 = ta.sma(wt1, 4)
tw_rsi = ta.rsi(close, tw_rsiLen)
tw_ema = ta.ema(close, emaLen)

plot(showTidewave ? tw_ema : na, "Tidewave EMA", color=color.aqua, linewidth=2)

wtCrossUp   = ta.crossover(wt1, wt2)
wtCrossDown = ta.crossunder(wt1, wt2)

bullSignal = barstate.isconfirmed and wtCrossUp and
             ((wt1[1] < wtOS and tw_rsi[1] < 50) or tw_rsi[1] <= rsiOS)
bearSignal = barstate.isconfirmed and wtCrossDown and
             ((wt1[1] > wtOB and tw_rsi[1] > 50) or tw_rsi[1] >= rsiOB)

// === CYCLE-TURN GATE (only fire within a week of a projected cycle high/low) ===
int dLenBars = math.max(1, math.round((dMin + dMax) / 2.0))
int wLenBars = math.max(1, math.round((wMin + wMax) / 2.0) * dpw)

int dPh = na(dcl_conf_bar) ? na : (bar_index - dcl_conf_bar) % dLenBars
int wPh = na(wcl_conf_bar) ? na : (bar_index - wcl_conf_bar) % wLenBars

bool dNearLow  = not na(dPh) and (dPh <= cycleTol or dLenBars - dPh <= cycleTol)
bool wNearLow  = not na(wPh) and (wPh <= cycleTol or wLenBars - wPh <= cycleTol)
bool dNearHigh = not na(dPh) and math.abs(dPh - dLenBars / 2) <= cycleTol
bool wNearHigh = not na(wPh) and math.abs(wPh - wLenBars / 2) <= cycleTol

bool nearLow  = dNearLow  or wNearLow
bool nearHigh = dNearHigh or wNearHigh

bullSignal := bullSignal and (not cycleGate or nearLow)
bearSignal := bearSignal and (not cycleGate or nearHigh)

offsetDist = ta.tr * 0.8

if showTidewave and triggerStyle == "Label Arrow"
    if bullSignal
        label.new(bar_index, low - offsetDist, "↑",
             color=color.new(color.green, 0), textcolor=color.white,
             style=label.style_label_up, size=size.normal, yloc=yloc.price)
    if bearSignal
        label.new(bar_index, high + offsetDist, "↓",
             color=color.new(color.red, 0), textcolor=color.white,
             style=label.style_label_down, size=size.normal, yloc=yloc.price)

plotshape(showTidewave and triggerStyle != "Label Arrow" and bullSignal,
     title="TW Bull Signal", location=location.belowbar, color=color.green,
     style = triggerStyle == "Triangle" ? shape.triangleup :
             triggerStyle == "Square"   ? shape.square      : shape.circle,
     size=size.normal)

plotshape(showTidewave and triggerStyle != "Label Arrow" and bearSignal,
     title="TW Bear Signal", location=location.abovebar, color=color.red,
     style = triggerStyle == "Triangle" ? shape.triangledown :
             triggerStyle == "Square"   ? shape.square        : shape.circle,
     size=size.normal)

if tw_alerts
    if bullSignal
        alert("Tidewave Bull Signal ↑ " + syminfo.ticker, alert.freq_once_per_bar_close)
    if bearSignal
        alert("Tidewave Bear Signal ↓ " + syminfo.ticker, alert.freq_once_per_bar_close)

alertcondition(bullSignal, "Tidewave Bull", "Tidewave ↑ {{ticker}} {{interval}}")
alertcondition(bearSignal, "Tidewave Bear", "Tidewave ↓ {{ticker}} {{interval}}")
````
