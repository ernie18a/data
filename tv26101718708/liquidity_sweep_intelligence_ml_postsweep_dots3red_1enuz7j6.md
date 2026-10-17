# Liquidity Sweep Intelligence - ML Post-Sweep [Dots3Red]

- url: https://www.tradingview.com/script/1Enuz7J6-Liquidity-Sweep-Intelligence-ML-Post-Sweep-Dots3Red/
- type: indicator
- pine_id: PUB;e971dcc53026457995008bde5002a7f0
- version: 1.0

## Description

█ [b]LIQUIDITY SWEEP INTELLIGENCE — KNN POST-SWEEP [Dots3Red][/b]
Usually, a liquidity indicator shows where the price is likely to go to take liquidity. This one tells you what tends to happen after it gets there.

When price sweeps a swing high or low — triggering the stop orders sitting there — we face the immediate question: does it reverse (a stop hunt, fade the move) or does it continue (a genuine breakout)? The answer depends on context. This script tracks every historical sweep on your chart, records the contextual features at the moment it happened, and uses a [i]KNN (K-Nearest Neighbors) [/i]model to find the most similar past sweeps and return their actual measured outcomes.

The probability shown is not derived from a formula. It is counted from real historical sweeps on your chart.

█ HOW IT WORKS
[b]1. Pool Detection[/b]
Swing highs and swing lows are detected using two pivot lengths — a primary (default 10 bars each side) and a secondary (default 8 bars each side) — to capture both major and minor liquidity levels. Same-side pivots that form within the Equal-Level Tolerance % of each other are merged into a single stronger pool, marked with the ⊜ symbol. These are equal highs (EQH) or equal lows (EQL) — two peaks or two troughs at nearly the same price — which represent a higher concentration of stop orders than a single pivot.

Unswept pools are shown as lines on the chart: dashed for single pivots, solid for equal-level pools. Pools expire after the configured maximum age (default 50 bars) without generating a sweep record.

[b]2. Sweep Detection[/b]
A sweep is registered when the close price exceeds a pool level by more than the Sweep Buffer (default 1.4 × ATR). This buffer filters out minor wicks that barely touch a level and requires a genuine close beyond it.

At the moment of the sweep, the script records:
• The direction (high swept or low swept)
• Whether the pool was an equal-level cluster (EQH/EQL)
• How old the pool was in bars
• The current ATR ratio (current volatility relative to the 50-bar baseline)
• Whether the sweep occurred inside an ICT killzone window

[b]3. Outcome Measurement[/b]
After the Outcome Window (default 10 bars), the script measures what price actually did. For a swept high, it calculates how far price retraced downward and how far it continued upward, both expressed in ATR units. For a swept low, the directions are reversed. If the retracement exceeded the Reversal Threshold (default 3.5 × ATR), the sweep is classified as a reversal. Otherwise it is classified as a continuation. The result is stored in the KNN training data.

[b]4. KNN Inference[/b]
The K-Nearest Neighbors model uses a 5-feature vector for each sweep:

• sweep_dir — was a high swept (1) or a low swept (0)?
• age_norm — how old was the pool when swept, normalized 0–1
• is_equal — was it an EQH/EQL cluster (1) or single pivot (0)?
• atr_ratio_norm — current ATR divided by 50-bar ATR baseline, capped at 3×
• in_kz — did the sweep occur inside a killzone window (1) or not (0)?

For each active sweep, the model computes the Euclidean distance to every recorded historical sweep in the training window, finds the K nearest matches (default 15), and returns three values averaged across those neighbors:

• Reversal probability — what percentage of matched sweeps reversed
• Average reversal distance — how far the reversal moved in ATR units
• Average continuation distance — how far the continuation moved in ATR units

The KNN runs every third bar per event for performance. Output is displayed only after the minimum training threshold (default 20 samples) has been reached.

[b]5. Killzone Context[/b]
Four ICT killzone windows are tracked in New York time and used as a contextual feature in the KNN vector:

• Asia KZ — 20:00 to 00:00
• London Open KZ — 02:00 to 05:00
• NY Open KZ — 07:00 to 10:00
• London Close KZ — 10:00 to 12:00

Sweeps that occur inside a killzone are marked with ⚡ in the label. The active killzone is also shown in the dashboard.

█ READING THE LABEL
Each active sweep displays a label at the right edge of the chart:

[b]▲ HIGH SWEPT  ⊜  ⚡[/b]
Rev 68%  |  +1.4 ATR  |  N=47

▲ HIGH SWEPT — a swing high was swept (sell-side stops triggered)
⊜ — the pool was an equal-high cluster (stronger stop concentration)
⚡ — the sweep occurred inside a killzone window
Rev 68% — 68% of the 47 matched historical sweeps reversed
+1.4 ATR — the average reversal distance among those that reversed
N=47 — 47 historical sweeps matched this context

Label color follows sweep direction: orange-red for a swept high (bearish sweep), cyan for a swept low (bullish sweep).

While training data is still being collected, the label shows: Training… (8/20 needed)


█ LIQUIDITY VOID ZONE
When a sweep candle has a long wick, there is a gap between the wick extreme and where price actually closed. This zone — where price moved through too fast for normal order flow — is drawn as a semi-transparent dashed box. It represents an imbalance that price frequently returns to fill. The void is colored by sweep direction.


█ DASHBOARD
The top-right table shows:
• Session KZ — which killzone is currently active, if any
• ATR Ratio — current ATR relative to the 50-bar baseline (amber above 1.5×)
• KNN Training — progress bar showing recorded sweep outcomes vs maximum
• Overall Rev % — total reversal rate across all recorded sweeps on this chart
• Avg Rev Dist — average reversal move in ATR across all reversals
• Avg Cont Dist — average continuation move in ATR across all continuations
• Active Pools — number of unswept pools tracked, with EQH/EQL count
• Pending Sweeps — sweeps waiting for their outcome window to complete
• Resolved — count of confirmed reversals and continuations
• KNN Features — reminder of the five features used in the model


█ SETTINGS
[b]Pool Detection[/b]
• Primary Pivot Length (10) — bars each side to confirm a major swing
• Secondary Pivot Length (8) — bars each side for minor swings; 0 disables
• Max Tracked Pools (60) — cap on active pools; oldest removed when exceeded
• Max Pool Age (50 bars) — pools older than this are expired without recording
• Equal-Level Tolerance % (3.0) — proximity threshold for EQH/EQL merging

[b]Sweep Settings[/b]
• Sweep Buffer (1.4 × ATR) — minimum close beyond pool to register a sweep
• Outcome Window (10 bars) — measurement window after each sweep
• Reversal Threshold (3.5 × ATR) — minimum retracement to classify as reversal
• Show Liquidity Void Zones — toggle the wick imbalance boxes
• Max Historical Sweeps Shown — cap on how many past events are displayed

[b]KNN Engine[/b]
• K Neighbors (15) — historical sweeps to average; higher = smoother, slower to adapt
• Max Training Samples (400) — rolling window; oldest samples dropped when exceeded
• Min Samples Before Display (20) — KNN output hidden until this threshold is reached
• ATR Baseline Period (50) — period for the baseline ATR used in the volatility feature


█ TIMEFRAME
Works on any intraday timeframe. Most useful at 5-minute through 1-hour where enough sweeps accumulate to build meaningful training data within a single session. On daily charts, the training window fills slowly but the signals tend to be higher quality.

The KNN model relearns continuously as new sweeps are recorded and old ones fall outside the rolling window. It adapts to the instrument and timeframe it is applied to.

█ NOTES
The reversal probability reflects historical behavior on this chart and timeframe. It is not a forward guarantee. A sweep with Rev 70% still continues 30% of the time. Use the N count as a confidence indicator — higher N means more matched examples and a more reliable estimate.

The model requires at least 20 sweep outcomes before displaying predictions. On timeframes with infrequent sweeps, this may take time to accumulate.

█ DISCLAIMER
This script is a visualization and analytical tool. It does not generate trade signals and does not constitute financial advice. Past sweep behavior does not guarantee future outcomes.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Liquidity Sweep Intelligence — KNN Post-Sweep [Dots3Red]",
          shorttitle    = "Liquidity Sweep [D3R]",
          overlay       = true,
          max_bars_back = 5000,
          max_boxes_count  = 500,
          max_lines_count  = 500,
          max_labels_count = 500)

// COLORS
C_BULL    = color.new(#00f0ff, 0)
C_BEAR    = color.new(#ff5500, 0)
C_GREEN   = color.new(#00c896, 0)
C_RED     = color.new(#ff4466, 0)
C_AMBER   = color.new(#ffb700, 0)
C_ORANGE  = color.new(#f97316, 0)
C_NEUTRAL = color.new(#64748b, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)

// INPUTS
GRP_DET = "🎯 Pool Detection"
GRP_SWP = "🌊 Sweep Settings"
GRP_KNN = "📊 KNN Engine"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"

pivot_len     = input.int  (10,  "Primary Pivot Length",        minval=2, maxval=50,  group=GRP_DET)
pivot_len2    = input.int  (8,   "Secondary Pivot Length",      minval=0, maxval=30,  group=GRP_DET, tooltip="0 disables.")
max_pools     = input.int  (60,  "Max Tracked Pools",           minval=10, maxval=200, group=GRP_DET)
max_age       = input.int  (50, "Max Pool Age (bars)",         minval=20, maxval=2000, group=GRP_DET)
eq_tol_pct    = input.float(3.0, "Equal-Level Tolerance %",     minval=0.05, maxval=5.0, step=0.05, group=GRP_DET, tooltip="Same-side pivots within this % merge into one EQH/EQL pool.")

sweep_buf_atr = input.float(1.4,  "Sweep Buffer (×ATR)",        minval=0.0, maxval=2.0, step=0.05, group=GRP_SWP, tooltip="Close must exceed pool level by this ATR multiple to register as a sweep.")
outcome_bars  = input.int  (10,   "Outcome Window (bars)",      minval=3, maxval=100, group=GRP_SWP, tooltip="Bars after a sweep to measure what price did.")
rev_thresh_atr= input.float(3.5,  "Reversal Threshold (×ATR)",  minval=0.1, maxval=5.0, step=0.1, group=GRP_SWP, tooltip="Price must retrace at least this many ATR units to count as a reversal.")
show_void     = input.bool (true,  "Show Liquidity Void Zones",  group=GRP_SWP, tooltip="Orange zone showing the wick imbalance left by the sweep — the gap price often returns to fill.")
max_hist_show = input.int  (40,   "Max Historical Sweeps Shown", minval=5, maxval=200, group=GRP_SWP)

knn_k         = input.int  (15,  "K Neighbors",                 minval=3, maxval=50, group=GRP_KNN, tooltip="Most similar historical sweeps to average.")
knn_max_train = input.int  (400, "Max Training Samples",        minval=30, maxval=1000, group=GRP_KNN)
knn_min_train = input.int  (20,  "Min Samples Before Display",  minval=5, maxval=100, group=GRP_KNN)
atr_base_len  = input.int  (50,  "ATR Baseline Period",         minval=10, group=GRP_KNN, tooltip="Used to compute ATR ratio as a volatility context feature for KNN.")

show_zones      = input.bool (false, "Show Post-Sweep Zones",      group=GRP_VIS)
show_labels     = input.bool (true, "Show KNN Outcome Labels",    group=GRP_VIS)
show_pool_lines = input.bool (true, "Show Unswept Pool Lines",    group=GRP_VIS)
zone_ext        = input.int  (30,  "Zone Extension (bars)",       minval=5, maxval=200, group=GRP_VIS)
zone_height     = input.float(1.2, "Zone Height (×ATR)",          minval=0.1, maxval=5.0, step=0.1, group=GRP_VIS)



show_hud = input.bool (true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)

// ATR + KILLZONE CONTEXT
atr_raw     = ta.atr(14)
atr_base_ma = ta.sma(atr_raw, atr_base_len)
atr_ratio   = atr_raw / math.max(atr_base_ma, 1e-9)

in_kz_as = not na(time(timeframe.period, "2000-0000", "America/New_York"))
in_kz_ln = not na(time(timeframe.period, "0200-0500", "America/New_York"))
in_kz_ny = not na(time(timeframe.period, "0700-1000", "America/New_York"))
in_kz_lc = not na(time(timeframe.period, "1000-1200", "America/New_York"))
in_any_kz = in_kz_as or in_kz_ln or in_kz_ny or in_kz_lc
kz_name   = in_kz_ln ? "London KZ" : in_kz_ny ? "NY Open KZ" : in_kz_as ? "Asia KZ" : in_kz_lc ? "LN Close KZ" : "—"

// TYPES
type Pool
    float price
    int   bar_idx
    bool  is_high
    bool  is_equal
    bool  swept

type SweepEvent
    float level
    bool  swept_high
    bool  is_equal
    int   pool_age
    int   sweep_bar
    float sweep_close
    float sweep_wh
    float sweep_wl
    float atr_at
    float atr_ratio_at
    bool  in_kz
    int   outcome_state
    float rev_atr_val
    float cont_atr_val
    float knn_rev_pct
    float knn_rev_atr
    float knn_cont_atr
    int   knn_n
    box   zone_bx
    box   void_bx
    label evt_lbl

// KNN — 5 features: [sweep_dir, age_norm, is_equal, atr_ratio_norm, in_kz]
int KNN_STRIDE = 5
var float[] kf       = array.new<float>()
var float[] ko_rev   = array.new<float>()
var float[] ko_rdist = array.new<float>()
var float[] ko_cdist = array.new<float>()

f_feat(SweepEvent s) =>
    float d  = s.swept_high ? 1.0 : 0.0
    float a  = math.min(1.0, float(s.pool_age) / float(max_age))
    float e  = s.is_equal   ? 1.0 : 0.0
    float at = math.min(1.0, s.atr_ratio_at / 3.0)
    float kz = s.in_kz      ? 1.0 : 0.0
    [d, a, e, at, kz]

f_knn_push(float d, float a, float e, float at, float kz, float o_r, float o_rd, float o_cd) =>
    array.push(kf, d), array.push(kf, a), array.push(kf, e), array.push(kf, at), array.push(kf, kz)
    array.push(ko_rev, o_r), array.push(ko_rdist, o_rd), array.push(ko_cdist, o_cd)
    if array.size(ko_rev) > knn_max_train
        for _i = 0 to KNN_STRIDE - 1
            array.shift(kf)
        array.shift(ko_rev), array.shift(ko_rdist), array.shift(ko_cdist)

f_knn_query(float d, float a, float e, float at, float kz) =>
    int   n     = array.size(ko_rev)
    int   ku    = math.min(knn_k, n)
    float rp    = 50.0
    float rd    = 0.0
    float cd    = 0.0
    if n >= knn_min_train
        float[] ds = array.new<float>(n, 0.0)
        for i = 0 to n - 1
            int b = i * KNN_STRIDE
            float dist = 0.0
            dist += math.pow(array.get(kf, b)   - d,  2.0)
            dist += math.pow(array.get(kf, b+1) - a,  2.0)
            dist += math.pow(array.get(kf, b+2) - e,  2.0)
            dist += math.pow(array.get(kf, b+3) - at, 2.0)
            dist += math.pow(array.get(kf, b+4) - kz, 2.0)
            array.set(ds, i, math.sqrt(dist))
        float[] dc = array.copy(ds)
        int[]   ix = array.new<int>(n, 0)
        for i = 0 to n - 1
            array.set(ix, i, i)
        float sr=0.0, float srd=0.0, float scd=0.0
        for k = 0 to ku - 1
            int mp=k, float mv=array.get(dc, k)
            if k+1 <= n-1
                for j = k+1 to n-1
                    v = array.get(dc, j)
                    if v < mv
                        mv := v, mp := j
            float td=array.get(dc,k), int ti=array.get(ix,k)
            array.set(dc,k,array.get(dc,mp)), array.set(dc,mp,td)
            array.set(ix,k,array.get(ix,mp)), array.set(ix,mp,ti)
            ni = array.get(ix, k)
            sr += array.get(ko_rev, ni), srd += array.get(ko_rdist, ni), scd += array.get(ko_cdist, ni)
        float kf_ = float(ku)
        rp := (sr/kf_)*100.0, rd := srd/kf_, cd := scd/kf_
    [rp, rd, cd, n]

// POOL TRACKING
var Pool[] pools = array.new<Pool>()

f_find_equal(float price, bool is_high) =>
    int idx=-1, float md=1e10
    sz = array.size(pools)
    if sz > 0
        for i = 0 to sz - 1
            p = array.get(pools, i)
            if p.is_high == is_high and not p.swept and price > 0
                diff = math.abs(p.price - price) / price
                if diff <= (eq_tol_pct/100.0) and diff < md
                    md := diff, idx := i
    idx

f_add_pool(float price, bool is_high, int origin_bar) =>
    mi = f_find_equal(price, is_high)
    if mi >= 0
        p = array.get(pools, mi)
        p.is_equal := true
        p.price    := is_high ? math.max(p.price, price) : math.min(p.price, price)
        array.set(pools, mi, p)
    else
        array.push(pools, Pool.new(price, origin_bar, is_high, false, false))

ph  = ta.pivothigh(high, pivot_len,  pivot_len)
pl  = ta.pivotlow (low,  pivot_len,  pivot_len)
ph2 = pivot_len2 > 0 ? ta.pivothigh(high, pivot_len2, pivot_len2) : na
pl2 = pivot_len2 > 0 ? ta.pivotlow (low,  pivot_len2, pivot_len2) : na

if not na(ph)
    f_add_pool(ph,  true,  bar_index - pivot_len)
if not na(pl)
    f_add_pool(pl,  false, bar_index - pivot_len)
if not na(ph2)
    f_add_pool(ph2, true,  bar_index - pivot_len2)
if not na(pl2)
    f_add_pool(pl2, false, bar_index - pivot_len2)

// SWEEP EVENTS
var SweepEvent[] sweeps = array.new<SweepEvent>()

if barstate.isconfirmed
    float sbuf = atr_raw * sweep_buf_atr

    // Detect sweeps
    if array.size(pools) > 0
        int ii = array.size(pools) - 1
        while ii >= 0
            if ii >= array.size(pools)
                ii -= 1
                continue
            p   = array.get(pools, ii)
            age = bar_index - p.bar_idx
            swept_now = p.is_high ? close > p.price + sbuf : close < p.price - sbuf
            if swept_now and not p.swept 
                p.swept := true
                array.set(pools, ii, p)
                array.push(sweeps, SweepEvent.new(
                    p.price, p.is_high, p.is_equal,
                    age, bar_index, close, high, low,
                    atr_raw, atr_ratio, in_any_kz,
                    0, na, na, 50.0, 0.0, 0.0, 0, na, na, na))
            else if age > max_age and not p.swept
                array.remove(pools, ii)
            ii -= 1
    while array.size(pools) > max_pools
        array.shift(pools)

    // Evaluate outcomes + KNN inference
    if array.size(sweeps) > 0
        for i = 0 to array.size(sweeps) - 1
            se = array.get(sweeps, i)
            if se.outcome_state == 0 and (bar_index - se.sweep_bar) >= outcome_bars
                float hi_a = ta.highest(high, outcome_bars)
                float lo_a = ta.lowest(low,   outcome_bars)
                float rd=0.0, float cd=0.0
                bool  rev=false
                if se.swept_high
                    rd  := (se.sweep_close - lo_a) / math.max(se.atr_at, 1e-9)
                    cd  := (hi_a - se.sweep_close) / math.max(se.atr_at, 1e-9)
                    rev := rd >= rev_thresh_atr
                else
                    rd  := (hi_a - se.sweep_close) / math.max(se.atr_at, 1e-9)
                    cd  := (se.sweep_close - lo_a)  / math.max(se.atr_at, 1e-9)
                    rev := rd >= rev_thresh_atr
                se.outcome_state := rev ? 1 : 2
                se.rev_atr_val   := rd
                se.cont_atr_val  := cd
                [d,a,e,at,kz] = f_feat(se)
                f_knn_push(d,a,e,at,kz, rev?1.0:0.0, rd, cd)
                array.set(sweeps, i, se)

            if se.outcome_state == 0 and (bar_index % 3 == 0 or se.knn_n < knn_min_train)
                [d,a,e,at,kz] = f_feat(se)
                [rp,rd2,cd2,n] = f_knn_query(d,a,e,at,kz)
                se.knn_rev_pct  := rp
                se.knn_rev_atr  := rd2
                se.knn_cont_atr := cd2
                se.knn_n        := n
                array.set(sweeps, i, se)



// VISUALIZATION
int bar_gap = nz(time - time[1], 0)
int n_train = array.size(ko_rev)

if array.size(sweeps) > 0
    for i = 0 to array.size(sweeps) - 1
        se = array.get(sweeps, i)
        color pred_c = se.knn_rev_pct >= 60 ? C_GREEN : se.knn_rev_pct <= 40 ? C_RED : C_NEUTRAL
        int   opac   = se.knn_n >= knn_min_train ? 72 : 85

        if se.outcome_state == 0
            // Projection zone
            if show_zones
                if not na(se.zone_bx)
                    box.delete(se.zone_bx)
                float rh = math.max(se.knn_rev_atr * se.atr_at * zone_height, se.atr_at * 0.3)
                if se.swept_high
                    se.zone_bx := box.new(se.sweep_bar, se.sweep_close,
                                          bar_index + zone_ext, se.sweep_close - rh,
                                          border_color=color.new(pred_c,40),
                                          bgcolor=color.new(pred_c,opac), border_width=1)
                else
                    se.zone_bx := box.new(se.sweep_bar, se.sweep_close + rh,
                                          bar_index + zone_ext, se.sweep_close,
                                          border_color=color.new(pred_c,40),
                                          bgcolor=color.new(pred_c,opac), border_width=1)

            // Void zone
            if show_void
                if not na(se.void_bx)
                    box.delete(se.void_bx)
                if se.swept_high and se.sweep_wh > se.sweep_close
                    se.void_bx := box.new(se.sweep_bar, se.sweep_wh,
                                          bar_index + zone_ext, se.sweep_close,
                                          border_color=color.new(C_ORANGE,50),
                                          bgcolor=color.new(C_BEAR,60),
                                          border_style=line.style_dashed, border_width=1)
                else if not se.swept_high and se.sweep_close > se.sweep_wl
                    se.void_bx := box.new(se.sweep_bar, se.sweep_close,
                                          bar_index + zone_ext, se.sweep_wl,
                                          border_color=color.new(C_ORANGE,60),
                                          bgcolor=color.new(C_BULL,60),
                                          border_style=line.style_dashed, border_width=1)

            // KNN label
            if show_labels
                if not na(se.evt_lbl)
                    label.delete(se.evt_lbl)
                string dir_s = se.swept_high ? "▲ HIGH SWEPT" : "▼ LOW SWEPT"
                string eq_m  = se.is_equal ? " ⊜" : ""
                string kz_m  = se.in_kz    ? " ⚡" : ""
                string knn_s = se.knn_n >= knn_min_train
                     ? "Rev " + str.tostring(math.round(se.knn_rev_pct),"#") + "%" +
                       "  |  +" + str.tostring(se.knn_rev_atr,"#.##") + " ATR" +
                       "  |  N=" + str.tostring(se.knn_n)
                     : "Training…  (" + str.tostring(se.knn_n) + "/" + str.tostring(knn_min_train) + ")"
                color dir_c  = se.swept_high ? C_BEAR : C_BULL
                se.evt_lbl := label.new(bar_index + zone_ext + 1, se.sweep_close,
                    dir_s + eq_m + kz_m + "\n" + knn_s,
                    style=label.style_label_left, textcolor=dir_c,
                    color=color.new(color.white, 100), size=10, textalign=text.align_left)


        array.set(sweeps, i, se)

while array.size(sweeps) > max_hist_show + 20
    old = array.shift(sweeps)
    if not na(old.zone_bx)
        box.delete(old.zone_bx)
    if not na(old.void_bx)
        box.delete(old.void_bx)
    if not na(old.evt_lbl)
        label.delete(old.evt_lbl)


// UNSWEPT POOL LINES
var line[] pool_lines = array.new<line>()
if barstate.islast and array.size(pool_lines)>0 and array.size(pools) > 0
    for li = 0 to array.size(pool_lines) - 1
        line.delete(array.get(pool_lines, li))
    array.clear(pool_lines)
    if show_pool_lines and array.size(pools) > 0
        for i = 0 to array.size(pools) - 1
            p = array.get(pools, i)
            if not p.swept
                color lc = p.is_high ? color.new(C_BEAR,60) : color.new(C_BULL,60)
                ln = line.new(p.bar_idx, p.price, bar_index + zone_ext, p.price,
                              color=lc, width=1,
                              style=p.is_equal ? line.style_solid : line.style_dashed)
                array.push(pool_lines, ln)


// Table
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 13,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud,0,0,"SWEEP INTEL [D3R]",text_color=color.rgb(222, 219, 20),bgcolor=color.new(#1e293b,0),text_size=size.small,text_halign=text.align_center)
    table.merge_cells(hud,0,0,1,0)

    color kz_c = in_any_kz ? C_AMBER : C_DIM
    table.cell(hud,0,1,"Session KZ",text_color=C_DIM,bgcolor=color.new(#1e293b,40),text_size=size.small)
    table.cell(hud,1,1,in_any_kz ? "⚡ "+kz_name : "—",text_color=kz_c,bgcolor=color.new(#1e293b,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,2,"ATR Ratio",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11)
    table.cell(hud,1,2,str.tostring(math.round(atr_ratio,2))+"×",text_color=atr_ratio>1.5?C_AMBER:C_DIM,bgcolor=color.new(#0f172a,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,3,"─── KNN Training ───",text_color=C_DIM,bgcolor=color.new(#0f172a,0),text_size=11,text_halign=text.align_center)
    table.merge_cells(hud,0,3,1,3)

    float kpct=math.min(100.0,float(n_train)/float(knn_max_train)*100.0)
    string kbar=""
    for _i = 1 to 10
        kbar += _i <= math.round(kpct/10.0) ? "■" : "□"
    table.cell(hud,0,4,"Sweep Outcomes",text_color=C_DIM,bgcolor=color.new(#1e293b,40),text_size=11)
    table.cell(hud,1,4,kbar+" "+str.tostring(n_train)+"/"+str.tostring(knn_max_train),text_color=n_train>=knn_min_train?C_GREEN:C_AMBER,bgcolor=color.new(#1e293b,40),text_size=11,text_halign=text.align_center)

    float tot_r=0.0,float sum_rd=0.0,float sum_cd=0.0
    if n_train > 0
        for _i = 0 to n_train-1
            tot_r  += array.get(ko_rev,_i)
            sum_rd += array.get(ko_rdist,_i)
            sum_cd += array.get(ko_cdist,_i)
    float ovr = n_train>0 ? (tot_r/float(n_train))*100.0 : na
    float ard = n_train>0 ? sum_rd/float(n_train) : na
    float acd = n_train>0 ? sum_cd/float(n_train) : na

    table.cell(hud,0,5,"Overall Rev %",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11)
    table.cell(hud,1,5,n_train>=knn_min_train?str.tostring(math.round(ovr),"#")+"%":"Training…",text_color=not na(ovr)?(ovr>=50?C_GREEN:C_RED):C_DIM,bgcolor=color.new(#0f172a,40),text_size=size.small,text_halign=text.align_center)

    table.cell(hud,0,6,"Avg Rev Dist",text_color=C_DIM,bgcolor=color.new(#1e293b,40),text_size=11)
    table.cell(hud,1,6,not na(ard) and n_train>=knn_min_train?str.tostring(ard,"#.##")+" ATR":"—",text_color=C_TXT,bgcolor=color.new(#1e293b,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,7,"Avg Cont Dist",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11)
    table.cell(hud,1,7,not na(acd) and n_train>=knn_min_train?str.tostring(acd,"#.##")+" ATR":"—",text_color=C_TXT,bgcolor=color.new(#0f172a,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,8,"─── Live State ───",text_color=C_DIM,bgcolor=color.new(#0f172a,0),text_size=11,text_halign=text.align_center)
    table.merge_cells(hud,0,8,1,8)

    int np=0,int nq=0,int nr=0,int nc=0
    if array.size(pools)>0
        for _i=0 to array.size(pools)-1
            _p=array.get(pools,_i)
            if not _p.swept
                np+=1
                if _p.is_equal
                    nq+=1
    if array.size(sweeps)>0
        for _i=0 to array.size(sweeps)-1
            _s=array.get(sweeps,_i)
            if      _s.outcome_state==0
                nr+=1
            else if _s.outcome_state==1
                nc+=1

    table.cell(hud,0,9,"Active Pools",text_color=C_DIM,bgcolor=color.new(#1e293b,40),text_size=11)
    table.cell(hud,1,9,str.tostring(np)+"  (⊜ "+str.tostring(nq)+")",text_color=C_TXT,bgcolor=color.new(#1e293b,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,10,"Pending Sweeps",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11)
    table.cell(hud,1,10,str.tostring(nr),text_color=nr>0?C_AMBER:C_DIM,bgcolor=color.new(#0f172a,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,11,"Resolved",text_color=C_DIM,bgcolor=color.new(#1e293b,40),text_size=11)
    table.cell(hud,1,11,"↩ "+str.tostring(nc)+"   → "+str.tostring(array.size(sweeps)-nr-nc),text_color=C_TXT,bgcolor=color.new(#1e293b,40),text_size=11,text_halign=text.align_center)

    table.cell(hud,0,12,"KNN Features",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11)
    table.cell(hud,1,12,"dir · age · EQH/L · vol · KZ",text_color=C_DIM,bgcolor=color.new(#0f172a,40),text_size=11,text_halign=text.align_center)

// ALERTS
bool new_hi = false, bool new_lo = false
if array.size(sweeps) > 0
    _l = array.get(sweeps, array.size(sweeps)-1)
    new_hi := _l.sweep_bar == bar_index and _l.swept_high
    new_lo := _l.sweep_bar == bar_index and not _l.swept_high

alertcondition(new_hi, "High Swept", "D3R Sweep Intel: swing HIGH swept — KNN analysis active")
alertcondition(new_lo, "Low Swept",  "D3R Sweep Intel: swing LOW swept — KNN analysis active")
alertcondition(in_kz_ln and not in_kz_ln[1], "London KZ", "D3R: London killzone started")
alertcondition(in_kz_ny and not in_kz_ny[1], "NY KZ",     "D3R: NY Open killzone started")
````
