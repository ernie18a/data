# Mean Reversion Pro 

- url: https://www.tradingview.com/script/tF22td3U-Mean-Reversion-Pro/
- type: indicator
- pine_id: PUB;68d0aabaf04e4bd0a580776e402d5868
- version: 1.0

## Description

📊 Mean Reversion Pro — Data-Driven Edge on Any Market, Any Timeframe

Most mean reversion indicators tell you the price is "too far" from the moving average. This one tells you exactly how far is statistically worth trading — using your own chart's historical data as proof.

Works on all instruments and timeframes: futures (NQ, ES, CL, GC…), crypto (BTC, ETH, SOL…), forex (EUR/USD, GBP/USD…), indices (SPX, DAX, NASDAQ…), stocks, commodities — anything with a price and volume.

─────────────────────────────────────────
🔍 WHAT THIS INDICATOR DOES
─────────────────────────────────────────

Mean Reversion Pro silently analyses every historical instance where price deviated from a moving average by a given distance. For each of 15 tested threshold levels it computes:

• Win rate        — % of times price returned to the MA within the timeout
• Expectancy      — (win-rate × avg MFE) − (loss-rate × avg MAE)
• Profit Factor   — gross gain / gross loss ratio
• Avg MAE         — average adverse excursion (how far against you before reverting)
• Avg MFE         — average favourable excursion (how far in your favour)
• Avg return time — average bars needed to reach the MA

It then automatically selects the threshold with the highest expectancy that also satisfies your minimum win-rate and minimum occurrences filters — and only then shows a signal. No manual optimisation. No curve-fitting.

─────────────────────────────────────────
⚙️ KEY FEATURES
─────────────────────────────────────────

✅ Universal — works on futures, crypto, forex, indices, stocks, commodities
✅ 3 threshold modes: fixed Points, ATR multiples, Z-Score (adapts to any volatility regime)
✅ 5 MA types: EMA, SMA, WMA, VWMA, Hull MA
✅ Auto-optimised threshold — the indicator finds the best level by itself
✅ Real-time dashboard: win-rate, expectancy, profit factor, MAE, MFE, return time (Long & Short)
✅ Dynamic bands: 1× and 1.5× optimal threshold zones drawn on the chart
✅ Non-repainting signals — only fires on confirmed, closed bars
✅ Optional filters: trend (EMA 50), volume, US session, minimum ATR
✅ Minimum history guard — signals are held until enough bars have been analysed
✅ All parameters fully exposed and documented with tooltips

─────────────────────────────────────────
📈 WHO IS THIS FOR
─────────────────────────────────────────

• Futures traders — NQ, MNQ, ES, MES, CL, GC, SI, ZB…
• Crypto traders — BTC, ETH, SOL and all altcoins on any exchange
• Forex traders — all major, minor and exotic pairs
• Index traders — SPX, NDX, DAX, FTSE, CAC, Nikkei…
• Stock traders and swing traders looking for mean reversion pullbacks
• Prop firm traders who need a systematic, rules-based edge
• Any trader tired of arbitrary support/resistance levels with no statistical backing

─────────────────────────────────────────
🧠 HOW TO USE IT
─────────────────────────────────────────

1. Apply to any chart on any timeframe
2. Let at least 500 bars load (recommended: 1000–2000 for robust statistics)
3. Choose Threshold Mode:
   — Points  → best for futures and indices (fixed price distances)
   — ATR     → best for crypto and forex (volatility-adjusted)
   — Z-Score → best for statistical/quant approaches
4. Set your minimum Win Rate (default 65%) and minimum Occurrences (default 15)
5. A signal appears only when all statistical conditions are met AND your filters pass
6. Read the dashboard to assess setup quality before entering a trade

─────────────────────────────────────────
💡 WHY EXPECTANCY MATTERS MORE THAN WIN RATE
─────────────────────────────────────────

A strategy with 80% win rate can still lose money if the average loss is 5× the average win. Mean Reversion Pro uses expectancy — the only metric that combines win rate, average gain and average loss into a single number — as its selection criterion. A signal only appears when the math is in your favour.

─────────────────────────────────────────
⚠️ DISCLAIMER
─────────────────────────────────────────

This indicator is a decision-support tool only. It does not provide financial advice and does not guarantee future results. Past statistical performance is not indicative of future performance. Always use proper risk management.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════
//  MEAN REVERSION PRO 
//  Pine Script v6  –  Decision-support indicator (non-automated)
//
//  Logic: tracks how often price reverts to the MA after a given
//  distance, computes win-rate / MAE / MFE / expectancy per level,
//  then auto-selects the threshold with the highest expectancy.
// ════════════════════════════════════════════════════════════════════
//@version=6
indicator("Mean Reversion Pro ", shorttitle="MR Pro", overlay=true, max_bars_back=5000)

// ── 1. INPUTS ────────────────────────────────────────────────────────
string GMA   = "── Moving Average ───────────────────────────"
string GANA  = "── Analysis & Statistics ────────────────────"
string GSIG  = "── Thresholds & Signals ─────────────────────"
string GFILT = "── Filters ──────────────────────────────────"
string GDISP = "── Display ──────────────────────────────────"

// Type of moving average used as the mean-reversion reference line
i_matype  = input.string("EMA", "MA Type", options=["EMA","SMA","WMA","VWMA","HMA"], group=GMA, tooltip="Moving average type used as the reference line. EMA reacts faster; SMA is smoother; HMA minimises lag.")

// Number of bars used to compute the moving average
i_maper   = input.int(20, "MA Period", minval=2, maxval=500, group=GMA, tooltip="Lookback period for the MA. Shorter = more signals, more noise. Longer = fewer signals, cleaner levels. Default 20 suits 1-5 min charts.")

// How distance is expressed: fixed points, ATR multiples, or standard deviations
i_mode    = input.string("Points", "Threshold Mode", options=["Points","ATR","Z-Score"], group=GANA, tooltip="How distance from MA is measured.\n• Points  : fixed  price points (best for absolute levels).\n• ATR     : multiples of ATR (adapts to volatility).\n• Z-Score : standard deviations (statistical approach).")

// ATR period used when Threshold Mode = ATR
i_atrper  = input.int(14, "ATR Period", minval=2, maxval=200, group=GANA, tooltip="Lookback for ATR calculation. Only used when Threshold Mode is set to ATR. Default 14 is standard.")

// Maximum bars allowed for price to return to MA before the event is discarded
i_maxhold = input.int(100, "Event Timeout (bars)", minval=5, maxval=1000, group=GANA, tooltip="If price does not return to the MA within this many bars, the event is counted as a failed return (not tracked as a success). Lower values = stricter. Recommended: 60-150 on 1-5 min.")

// Minimum number of confirmed bars before any signal is displayed
i_minbars = input.int(500, "Min. History Before Signals (bars)", minval=100, group=GANA, tooltip="Prevents signals from appearing until the indicator has analysed enough history. More history = more reliable statistics. Recommended minimum: 500 bars.")

// Minimum historical win-rate required for the optimal threshold to generate a signal
i_minprob = input.float(0.65, "Minimum Win-Rate", minval=0.3, maxval=1.0, step=0.05, group=GSIG, tooltip="The historical probability of price returning to the MA must be at or above this value before a signal is shown. 0.65 = 65% win-rate required.")

// Minimum number of historical occurrences required at a given threshold before it is considered valid
i_minocc  = input.int(15, "Minimum Occurrences", minval=2, maxval=500, group=GSIG, tooltip="A threshold level must have been triggered at least this many times in history before it can become the optimal level. Avoids over-fitting on rare events.")

// Minimum expectancy (in price points) for the optimal threshold
i_minexp  = input.float(0.0, "Minimum Expectancy (pts)", group=GSIG, tooltip="Expectancy = (win-rate × avg MFE) − (loss-rate × avg MAE). A level must have a positive expectancy above this value to generate a signal. 0 = any positive expectancy is accepted.")

// Filter: only allow Long signals when EMA50 slope is upward, only Short when downward
i_ftend   = input.bool(false, "Trend Filter (EMA 50)", group=GFILT, tooltip="When enabled: Long signals are suppressed if the EMA 50 is sloping downward; Short signals are suppressed if it is sloping upward. Reduces counter-trend trades.")

// Filter: only trigger when current volume exceeds its 20-bar average
i_fvol    = input.bool(false, "Volume Filter (> 20-bar SMA)", group=GFILT, tooltip="Requires volume to be above its 20-bar simple moving average before a signal is valid. Avoids low-liquidity setups.")

// Filter: only show signals during the regular US equity session (09:30–16:00 ET)
i_fsess   = input.bool(false, "US Session Filter (09:30-16:00 ET)", group=GFILT, tooltip="Restricts signals to the regular US equity session. Useful  to avoid pre/post-market low-liquidity periods.")

// Filter: only show signals when ATR is above a user-defined minimum
i_fatrmin = input.bool(false, "Minimum ATR Filter", group=GFILT, tooltip="Enables a minimum ATR requirement. Useful to avoid trading in very low-volatility environments where mean reversion may not provide enough range.")

// Minimum ATR value required when the ATR filter is enabled
i_atrmin  = input.float(5.0, "Minimum ATR Value (pts)", step=0.5, group=GFILT, tooltip="Minimum ATR (in price points) required for a signal to be valid. Only active when the Minimum ATR Filter is enabled above.")

// Show or hide the statistics dashboard table
i_dash    = input.bool(true, "Show Dashboard", group=GDISP, tooltip="Displays the full statistics table on the chart (thresholds, win-rates, MAE, MFE, expectancy, profit factor and current signal).")

// Show or hide the statistical bands around the MA
i_bands   = input.bool(true, "Show Statistical Bands", group=GDISP, tooltip="Draws two bands around the MA based on the optimal threshold: 1× (primary zone) and 1.5× (extreme zone). Green = Long zone, Red = Short zone.")

// Show or hide the triangle signal markers on the chart
i_sigs    = input.bool(true, "Show Signal Markers", group=GDISP, tooltip="Displays a triangle on the chart when a new Long or Short signal is triggered. Does not repaint: markers appear only on confirmed closed bars.")

// Corner of the chart where the dashboard is placed
i_dashpos = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GDISP, tooltip="Choose which corner of the chart to place the statistics dashboard.")

// ── 2. CONSTANT NT ───────────────────────────────────────────────────
int NT = 15

// ── 3. THRESHOLD FUNCTIONS ───────────────────────────────────────────
f_pts(int i) =>
    i < 10 ? 5 + i * 5 : 50 + (i - 9) * 10

f_mult(int i) =>
    float v = 0.0
    if i <= 7
        v := 0.5 + float(i) * 0.5
    else if i == 8
        v := 4.5
    else if i == 9
        v := 5.0
    else if i == 10
        v := 5.5
    else if i == 11
        v := 6.0
    else if i == 12
        v := 7.0
    else if i == 13
        v := 8.0
    else
        v := 10.0
    v

f_thr(int i, float _atr, float _std) =>
    i_mode == "ATR" ? f_mult(i) * _atr : i_mode == "Z-Score" ? f_mult(i) * _std : float(f_pts(i))

f_lbl(int i) =>
    i_mode == "ATR" ? str.tostring(f_mult(i), "#.#") + "xATR" : i_mode == "Z-Score" ? str.tostring(f_mult(i), "#.#") + "sd" : str.tostring(f_pts(i)) + " pts"

// ── 4. FORMAT HELPERS ────────────────────────────────────────────────
fmtpct(float v)    => str.tostring(math.round(v * 1000.0) / 10.0, "#.#") + "%"
fmtpts(float v)    => str.tostring(math.round(v * 10.0) / 10.0, "#.#") + " pts"
fmtsigned(float v) => (v >= 0.0 ? "+" : "") + str.tostring(math.round(v * 10.0) / 10.0, "#.#") + " pts"
fmtpf(float v)     => str.tostring(math.round(v * 100.0) / 100.0, "#.##")
fmtbar(float v)    => str.tostring(math.round(v * 10.0) / 10.0, "#.#") + "b"

// ── 5. MA & INDICATOR CALCULATIONS ──────────────────────────────────
f_hma(float src, int len) =>
    int h  = math.max(2, len / 2)
    int sq = math.max(2, math.floor(math.sqrt(float(len))))
    ta.wma(2.0 * ta.wma(src, h) - ta.wma(src, len), sq)

float ma    = i_matype == "SMA" ? ta.sma(close, i_maper) : i_matype == "WMA" ? ta.wma(close, i_maper) : i_matype == "VWMA" ? ta.vwma(close, i_maper) : i_matype == "HMA" ? f_hma(close, i_maper) : ta.ema(close, i_maper)
float atr   = ta.atr(i_atrper)
float stdev = ta.stdev(close, math.max(i_maper, 5))
float ema50 = ta.ema(close, 50)
float vsma  = ta.sma(volume, 20)

float dist     = close - ma
float dist_abs = math.abs(dist)
float dist_atr = atr   > 1e-10 ? dist_abs / atr   : 0.0
float dist_z   = stdev > 1e-10 ? dist     / stdev : 0.0

// ── 6. FILTERS ───────────────────────────────────────────────────────
bool is_us = not na(time("1", "0930-1600", "America/New_York"))
bool filt  = true
if i_fvol
    filt := volume > vsma ? filt : false
if i_fsess
    filt := is_us ? filt : false
if i_fatrmin
    filt := atr >= i_atrmin ? filt : false

bool enough = bar_index + 1 >= i_minbars

// ── 7. LONG ARRAYS ──────────────────────────────────────────────────
var array<int>   L_occ  = array.new<int>(NT, 0)
var array<int>   L_ret  = array.new<int>(NT, 0)
var array<float> L_sumt = array.new<float>(NT, 0.0)
var array<float> L_smae = array.new<float>(NT, 0.0)
var array<float> L_smfe = array.new<float>(NT, 0.0)
var array<bool>  La_on  = array.new<bool>(NT, false)
var array<int>   La_bar = array.new<int>(NT, 0)
var array<float> La_ep  = array.new<float>(NT, 0.0)
var array<float> La_mae = array.new<float>(NT, 0.0)
var array<float> La_mfe = array.new<float>(NT, 0.0)

// ── 8. SHORT ARRAYS ─────────────────────────────────────────────────
var array<int>   S_occ  = array.new<int>(NT, 0)
var array<int>   S_ret  = array.new<int>(NT, 0)
var array<float> S_sumt = array.new<float>(NT, 0.0)
var array<float> S_smae = array.new<float>(NT, 0.0)
var array<float> S_smfe = array.new<float>(NT, 0.0)
var array<bool>  Sa_on  = array.new<bool>(NT, false)
var array<int>   Sa_bar = array.new<int>(NT, 0)
var array<float> Sa_ep  = array.new<float>(NT, 0.0)
var array<float> Sa_mae = array.new<float>(NT, 0.0)
var array<float> Sa_mfe = array.new<float>(NT, 0.0)

// ── 9. STATE MACHINE ────────────────────────────────────────────────
if barstate.isconfirmed
    for i = 0 to NT - 1
        float thr = f_thr(i, atr, stdev)
        if not na(thr) and thr > 0.0
            float blw = ma - close
            if array.get(La_on, i)
                int elapsed   = bar_index - array.get(La_bar, i)
                float ep      = array.get(La_ep, i)
                float new_mae = math.max(array.get(La_mae, i), ep - close)
                float new_mfe = math.max(array.get(La_mfe, i), close - ep)
                array.set(La_mae, i, new_mae)
                array.set(La_mfe, i, new_mfe)
                if close >= ma
                    array.set(L_ret,  i, array.get(L_ret,  i) + 1)
                    array.set(L_sumt, i, array.get(L_sumt, i) + float(elapsed))
                    array.set(L_smae, i, array.get(L_smae, i) + math.max(0.0, new_mae))
                    array.set(L_smfe, i, array.get(L_smfe, i) + math.max(0.0, new_mfe))
                    array.set(La_on, i, false)
                else if elapsed >= i_maxhold
                    array.set(La_on, i, false)
            else if blw >= thr
                array.set(La_on,  i, true)
                array.set(La_bar, i, bar_index)
                array.set(La_ep,  i, close)
                array.set(La_mae, i, 0.0)
                array.set(La_mfe, i, 0.0)
                array.set(L_occ,  i, array.get(L_occ, i) + 1)

            float abv = close - ma
            if array.get(Sa_on, i)
                int elapsed   = bar_index - array.get(Sa_bar, i)
                float ep      = array.get(Sa_ep, i)
                float new_mae = math.max(array.get(Sa_mae, i), close - ep)
                float new_mfe = math.max(array.get(Sa_mfe, i), ep - close)
                array.set(Sa_mae, i, new_mae)
                array.set(Sa_mfe, i, new_mfe)
                if close <= ma
                    array.set(S_ret,  i, array.get(S_ret,  i) + 1)
                    array.set(S_sumt, i, array.get(S_sumt, i) + float(elapsed))
                    array.set(S_smae, i, array.get(S_smae, i) + math.max(0.0, new_mae))
                    array.set(S_smfe, i, array.get(S_smfe, i) + math.max(0.0, new_mfe))
                    array.set(Sa_on, i, false)
                else if elapsed >= i_maxhold
                    array.set(Sa_on, i, false)
            else if abv >= thr
                array.set(Sa_on,  i, true)
                array.set(Sa_bar, i, bar_index)
                array.set(Sa_ep,  i, close)
                array.set(Sa_mae, i, 0.0)
                array.set(Sa_mfe, i, 0.0)
                array.set(S_occ,  i, array.get(S_occ, i) + 1)

// ── 10. DERIVED STATISTICS ───────────────────────────────────────────
f_stat(int occ, int ret, float sumt, float smae, float smfe) =>
    float p   = occ > 0 ? float(ret)  / float(occ) : 0.0
    float avt = ret > 0 ? sumt        / float(ret)  : 0.0
    float mae = occ > 0 ? smae        / float(occ)  : 0.0
    float mfe = ret > 0 ? smfe        / float(ret)  : 0.0
    float ex  = p * mfe - (1.0 - p) * mae
    float den = (1.0 - p) * mae
    float pf  = den > 1e-9 ? p * mfe / den : p * mfe > 0.0 ? 9999.0 : 0.0
    [p, avt, mae, mfe, ex, pf]

// ── 11. OPTIMAL THRESHOLD SEARCH ─────────────────────────────────────
int   opt_li  = 0
int   opt_si  = 0
bool  opt_lf  = false
bool  opt_sf  = false
float best_le = -1e9
float best_se = -1e9
int   ol_occ  = 0
float ol_p    = 0.0
float ol_t    = 0.0
float ol_mae  = 0.0
float ol_mfe  = 0.0
float ol_e    = 0.0
float ol_pf   = 0.0
int   os_occ  = 0
float os_p    = 0.0
float os_t    = 0.0
float os_mae  = 0.0
float os_mfe  = 0.0
float os_e    = 0.0
float os_pf   = 0.0

for i = 0 to NT - 1
    int lo = array.get(L_occ, i)
    int lr = array.get(L_ret, i)
    [lp, lt, lmae, lmfe, le, lpf] = f_stat(lo, lr, array.get(L_sumt, i), array.get(L_smae, i), array.get(L_smfe, i))
    if lo >= i_minocc and lp >= i_minprob and le > i_minexp and le > best_le
        best_le := le
        opt_li  := i
        opt_lf  := true
        ol_occ  := lo
        ol_p    := lp
        ol_t    := lt
        ol_mae  := lmae
        ol_mfe  := lmfe
        ol_e    := le
        ol_pf   := lpf

    int so = array.get(S_occ, i)
    int sr = array.get(S_ret, i)
    [sp, st, smae2, smfe2, se, spf] = f_stat(so, sr, array.get(S_sumt, i), array.get(S_smae, i), array.get(S_smfe, i))
    if so >= i_minocc and sp >= i_minprob and se > i_minexp and se > best_se
        best_se := se
        opt_si  := i
        opt_sf  := true
        os_occ  := so
        os_p    := sp
        os_t    := st
        os_mae  := smae2
        os_mfe  := smfe2
        os_e    := se
        os_pf   := spf

float opt_l_thr = f_thr(opt_li, atr, stdev)
float opt_s_thr = f_thr(opt_si, atr, stdev)

// ── 12. SIGNALS ──────────────────────────────────────────────────────
bool filt_long  = filt
bool filt_short = filt

if i_ftend
    float slope50 = ema50 - ema50[20]
    if slope50 < -ema50 * 0.002
        filt_long  := false
    if slope50 > ema50 * 0.002
        filt_short := false

bool sig_long  = enough and opt_lf and filt_long  and (ma - close) >= opt_l_thr
bool sig_short = enough and opt_sf and filt_short and (close - ma) >= opt_s_thr
bool trig_l    = sig_long  and not sig_long[1]
bool trig_s    = sig_short and not sig_short[1]

float slope_ma = ma - ma[10]
string regime  = slope_ma > 3.0 ? "Bullish" : slope_ma < -3.0 ? "Bearish" : "Neutral"
color  regcol  = slope_ma > 3.0 ? #26A69A   : slope_ma < -3.0 ? #EF5350  : color.gray

// ── 13. CHART PLOTS ──────────────────────────────────────────────────
plot(ma, "MA Reference", color=color.new(#2196F3, 0), linewidth=2)
p_ma_ref = plot(ma, "MA Fill Ref", display=display.none)

float band_l1 = i_bands and opt_lf ? ma - opt_l_thr       : na
float band_l2 = i_bands and opt_lf ? ma - opt_l_thr * 1.5 : na
float band_s1 = i_bands and opt_sf ? ma + opt_s_thr       : na
float band_s2 = i_bands and opt_sf ? ma + opt_s_thr * 1.5 : na

p_bl1 = plot(band_l1, "Long Zone",       color=color.new(#26A69A, 10), linewidth=1)
p_bl2 = plot(band_l2, "Long Extreme",    color=color.new(#26A69A, 45), linewidth=1, style=plot.style_circles)
p_bs1 = plot(band_s1, "Short Zone",      color=color.new(#EF5350, 10), linewidth=1)
p_bs2 = plot(band_s2, "Short Extreme",   color=color.new(#EF5350, 45), linewidth=1, style=plot.style_circles)

fill(p_ma_ref, p_bl1, color=color.new(#26A69A, 91))
fill(p_ma_ref, p_bs1, color=color.new(#EF5350, 91))

plotshape(i_sigs and trig_l, "Long Signal",  shape.triangleup,   location.belowbar, color.new(#26A69A, 0), size=size.normal, text="MR LONG",  textcolor=#26A69A)
plotshape(i_sigs and trig_s, "Short Signal", shape.triangledown, location.abovebar, color.new(#EF5350, 0), size=size.normal, text="MR SHORT", textcolor=#EF5350)

// ── 14. DASHBOARD ────────────────────────────────────────────────────
dash_pos = switch i_dashpos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>               position.top_right

var table T = table.new(dash_pos, 2, 25, bgcolor=color.new(#0D1117, 5), border_color=color.new(#21262D, 0), border_width=1, frame_color=#1565C0, frame_width=2)

color CLbl  = color.new(#90CAF9, 0)
color CVal  = color.white
color CGrn  = #26A69A
color CRed  = #EF5350
color COra  = color.orange
color CGry  = color.new(#546E7A, 0)
color BHdr  = #1565C0
color BLng  = color.new(#0D2818, 0)
color BShrt = color.new(#2D0B0B, 0)
color BRow  = color.new(#0D1117, 0)
color BCell = color.new(#0A1628, 0)
color BCelS = color.new(#1A0A0A, 0)
color BBot  = color.new(#1C2833, 0)

tc(int c, int r, string txt, color tc_col, color bg_col) =>
    table.cell(T, c, r, txt, text_color=tc_col, bgcolor=bg_col, text_size=size.small, text_halign=text.align_center)

if i_dash
    // Header
    tc(0, 0, "MEAN REVERSION PRO", CVal, BHdr)
    tc(1, 0, i_matype + " " + str.tostring(i_maper), color.new(#64B5F6, 0), BHdr)

    // Current distance & market regime
    string d_now = i_mode == "ATR" ? str.tostring(math.round(dist_atr * 100.0) / 100.0, "#.##") + "xATR" : i_mode == "Z-Score" ? str.tostring(math.round(math.abs(dist_z) * 100.0) / 100.0, "#.##") + "sd" : fmtpts(dist_abs)
    tc(0, 1, "Distance from MA", CLbl, BRow)
    tc(1, 1, d_now, dist < 0.0 ? CGrn : CRed, BRow)
    tc(0, 2, "Market Regime", CLbl, BRow)
    tc(1, 2, regime, regcol, BRow)

    // Long section
    tc(0, 3, "LONG  (price below MA)", CGrn, BLng)
    tc(1, 3, opt_lf ? "Active" : "Insufficient data", opt_lf ? CGrn : CGry, BLng)

    string ltlbl = opt_lf ? f_lbl(opt_li) : "---"
    tc(0,  4, "Optimal Threshold",  CLbl, BCell)
    tc(1,  4, ltlbl,                CVal, BCell)
    tc(0,  5, "Occurrences",        CLbl, BCell)
    tc(1,  5, str.tostring(ol_occ), ol_occ >= i_minocc ? CVal : CRed, BCell)
    tc(0,  6, "Win Rate",           CLbl, BCell)
    tc(1,  6, opt_lf ? fmtpct(ol_p) : "---", ol_p >= i_minprob ? CGrn : CRed, BCell)
    tc(0,  7, "Expectancy",         CLbl, BCell)
    tc(1,  7, opt_lf ? fmtsigned(ol_e) : "---", ol_e > 0.0 ? CGrn : CRed, BCell)
    tc(0,  8, "Profit Factor",      CLbl, BCell)
    tc(1,  8, opt_lf ? fmtpf(ol_pf) : "---", ol_pf > 1.5 ? CGrn : COra, BCell)
    tc(0,  9, "Avg Return Time",    CLbl, BCell)
    tc(1,  9, opt_lf ? fmtbar(ol_t) : "---", CVal, BCell)
    tc(0, 10, "Avg MAE",            CLbl, BCell)
    tc(1, 10, opt_lf ? fmtpts(ol_mae) : "---", COra, BCell)
    tc(0, 11, "Avg MFE",            CLbl, BCell)
    tc(1, 11, opt_lf ? fmtpts(ol_mfe) : "---", CGrn, BCell)

    // Short section
    tc(0, 12, "SHORT  (price above MA)", CRed, BShrt)
    tc(1, 12, opt_sf ? "Active" : "Insufficient data", opt_sf ? CRed : CGry, BShrt)

    string stlbl = opt_sf ? f_lbl(opt_si) : "---"
    tc(0, 13, "Optimal Threshold",  CLbl, BCelS)
    tc(1, 13, stlbl,                CVal, BCelS)
    tc(0, 14, "Occurrences",        CLbl, BCelS)
    tc(1, 14, str.tostring(os_occ), os_occ >= i_minocc ? CVal : CRed, BCelS)
    tc(0, 15, "Win Rate",           CLbl, BCelS)
    tc(1, 15, opt_sf ? fmtpct(os_p) : "---", os_p >= i_minprob ? CGrn : CRed, BCelS)
    tc(0, 16, "Expectancy",         CLbl, BCelS)
    tc(1, 16, opt_sf ? fmtsigned(os_e) : "---", os_e > 0.0 ? CGrn : CRed, BCelS)
    tc(0, 17, "Profit Factor",      CLbl, BCelS)
    tc(1, 17, opt_sf ? fmtpf(os_pf) : "---", os_pf > 1.5 ? CGrn : COra, BCelS)
    tc(0, 18, "Avg Return Time",    CLbl, BCelS)
    tc(1, 18, opt_sf ? fmtbar(os_t) : "---", CVal, BCelS)
    tc(0, 19, "Avg MAE",            CLbl, BCelS)
    tc(1, 19, opt_sf ? fmtpts(os_mae) : "---", COra, BCelS)
    tc(0, 20, "Avg MFE",            CLbl, BCelS)
    tc(1, 20, opt_sf ? fmtpts(os_mfe) : "---", CGrn, BCelS)

    // Current signal
    string sigtxt = sig_long ? "LONG (" + ltlbl + ")" : sig_short ? "SHORT (" + stlbl + ")" : "NO SIGNAL"
    color  sigcol = sig_long ? CGrn : sig_short ? CRed : CGry
    tc(0, 21, "CURRENT SIGNAL", CVal,   BBot)
    tc(1, 21, sigtxt,           sigcol, BBot)

    // Active filters
    string fltxt = (i_ftend ? "trend " : "") + (i_fvol ? "vol " : "") + (i_fsess ? "sess " : "") + (i_fatrmin ? "atr" : "")
    tc(0, 22, "Active Filters",   CLbl, BRow)
    tc(1, 22, str.length(fltxt) > 0 ? fltxt : "none", CGry, BRow)

    // Mode & bars analysed
    tc(0, 23, "Mode / Bars",      CLbl, BRow)
    tc(1, 23, i_mode + " / " + str.tostring(bar_index + 1), CGry, BRow)

    // Data status
    tc(0, 24, enough ? "Data OK" : "Insufficient history", enough ? CGrn : COra, BRow)
    tc(1, 24, enough ? "" : "< " + str.tostring(i_minbars) + " bars", COra, BRow)
````
