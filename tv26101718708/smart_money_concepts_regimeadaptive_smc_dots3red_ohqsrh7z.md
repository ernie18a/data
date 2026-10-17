# Smart Money Concepts - Regime-Adaptive SMC [Dots3Red]

- url: https://www.tradingview.com/script/OHQsRH7Z-Smart-Money-Concepts-Regime-Adaptive-SMC-Dots3Red/
- type: indicator
- pine_id: PUB;d80151ad250b4f5eac238a0541bed9bc
- version: 1.0

## Description

█ [b]SMART MONEY CONCEPTS — REGIME-ADAPTIVE SMC[/b]
This indicator attempts to bridge a gap that most SMC traders encounter in practice: the same pattern — an Order Block, a Fair Value Gap, a structure break — behaves differently depending on whether the market is trending or ranging. A bullish Order Block in a trending market is a continuation entry zone. The same pattern near the top of a range is a reversal signal. This script uses a [b]built-in regime classifier[/b] to determine the current market character on every bar, then filters and interprets each SMC concept accordingly.

█ [b]HOW THE REGIME CLASSIFIER WORKS[/b]
Three measurements are combined into a single trend score on every bar:
[b]ADX (Average Directional Index)[/b] measures how strongly price is committed to a direction. It is normalized from its natural 0–60 range to a 0–1 scale by dividing by 60.
[b]Choppiness Index[/b] measures directional efficiency — how much of price movement was "wasted" going sideways versus producing net progress. It is inverted so that high choppiness produces a low score. Near 38 (the Fibonacci trend boundary) the normalized value approaches 1.0. Near 100 (pure chop) it approaches 0.0.

The two values are averaged:
[i]trend_score = (adx_normalized + choppiness_inverted_normalized) / 2[/i]
A score above 0.6 identifies a trending market. A score below 0.6 identifies a ranging market.
[b]Volatility override:[/b] a separate check compares current ATR against its 50-bar SMA. If the ratio exceeds 1.5× the baseline, the regime switches to VOLATILE regardless of the trend score — because during genuine volatility expansion, both trend and reversal signals become unreliable.

Finally, a mode filter examines the last 6 raw regime values and returns the most frequent one. This prevents the regime from flickering on borderline readings.


█ [b]WHAT EACH REGIME SHOWS[/b]
[b]TRENDING (cyan bars):[/b] Market is moving directionally. Shows BOS labels confirming continuation, Order Blocks created at displacement-qualified BOS bars as continuation entry zones, and Fair Value Gaps as pullback targets in the trend direction. CHoCH signals are hidden — in a trend, CHoCH is usually a deep pullback, not a reversal.
[b]RANGING (magenta bars):[/b] Market is oscillating between levels. Shows CHoCH labels flagging potential reversals at range extremes, Order Blocks at CHoCH bars as reversal entry zones, and Fair Value Gaps near range boundaries. BOS signals are hidden — a structure break in a ranging market is usually a liquidity sweep, not a genuine breakout.
[b]VOLATILE (amber bars):[/b] ATR has expanded significantly above its baseline — earnings, macro events, sudden liquidations. Order Blocks and FVGs are suppressed because zones created during volatility spikes are historically unreliable. Structure labels (BOS) remain visible for position tracking only.
[b]UNCERTAIN (slate bars):[/b] The classifier cannot confidently assign a regime. All signals are displayed so the trader has maximum information. This state occurs during the warmup period and at genuine transition boundaries.


█ [b]ORDER BLOCK DETECTION[/b]
Order Blocks require an additional displacement filter before they are created. The body of the candle immediately before the BOS or CHoCH must exceed 0.8× ATR in absolute size. This ensures only candles with institutional-grade momentum qualify — eliminating the low-quality OBs that make most SMC scripts visually cluttered.

Mitigation uses standard ICT methodology: a bullish OB is consumed when price's low touches the top of the zone. A bearish OB is consumed when price's high touches the bottom of the zone. Consumed zones fade visually and stop extending.


█ [b]FAIR VALUE GAP DETECTION[/b]
A bullish FVG exists when the high of candle[2] is below the low of candle[0] — a genuine three-candle imbalance where price moved too fast to fill. A minimum size filter of 0.15× ATR removes noise gaps. FVGs extend forward until price enters the gap, at which point they fade and stop tracking.


█ [b]PREMIUM / DISCOUNT ZONES[/b]
Two horizontal lines divide the current 25-bar swing range:
•  [b]75% level (red):[/b] price is in the upper quartile of the recent range — statistically expensive. In ranging markets this is a sell consideration zone.
•  [b]25% level (green):[/b] price is in the lower quartile — statistically cheap. In ranging markets this is a buy consideration zone.

The HUD displays the current percentage position within the range in real time.


█ [b]SMC BIAS MATRIX[/b]
The HUD includes a composite directional score built from three components:
•  [b]Structural trend (35 points):[/b] which direction is the structural_trend state machine currently pointing
•  [b]Premium / Discount position (30 points):[/b] which side of the range is price on
•  [b]Regime alignment (35 points):[/b] does the regime confirm the directional bias

In VOLATILE and UNCERTAIN regimes the bias is forced to 50% and displays "STAND ASIDE" or "WAIT FOR REGIME" — because the script suppresses OB and FVG signals in those states, showing a directional bias would contradict its own logic.

█ [b]WHAT YOU SEE ON THE CHART[/b]
•  [b]Bar colors:[/b] every bar is tinted by the current regime — cyan (trending), magenta (ranging), amber (volatile), slate (uncertain). No labels or background fills — just the candles themselves change color, keeping the chart clean.
•  [b]BOS / CHoCH labels:[/b] small labels appear above swing highs (bullish breaks) or below swing lows (bearish breaks), offset by 1.5× ATR so they never overlap candle bodies.
•  [b]Order Block boxes:[/b] semi-transparent boxes that extend bar by bar until mitigated, then fade. Maximum 4 per direction.
•  [b]FVG boxes:[/b] thin semi-transparent boxes extending until filled, then fading. Minimum size filtered.
•  [b]Premium/Discount lines:[/b] two step-lines showing the 75% and 25% boundaries of the current swing range.
•  [b]HUD:[/b] regime state, confidence bar, bias matrix, P/D zone, ADX, Choppiness Index, ATR ratio, and live counts of active OBs and FVGs.


█ [b]ALERTS[/b]
Seven alert conditions are available: Bull BOS, Bear BOS, Bull CHoCH, Bear CHoCH, Regime → Trending, Regime → Ranging, Regime → Volatile.


█ [b]NOTES ON SETTINGS[/b]
•  [i]Regime Smoothing Filter:[/i] 5–7 for intraday charts, 8–12 for daily/weekly. Lower values react faster but produce more regime transitions.
•  [i]Volatile ATR Mult:[/i] 1.8–2.0 for stock indices (earnings create genuine 2× spikes), 1.4–1.6 for crypto and forex.
•  [i]OB Displacement Mult:[/i] 0.5–0.8 for daily charts where candles are naturally larger, 1.0–1.5 for intraday.
•  [i]Swing Pivot Length:[/i] 5–7 for intraday, 7–10 for daily/weekly.


█ [b]DISCLAIMER[/b]
This indicator is a technical analysis tool. It does not constitute financial advice and does not guarantee future results. Past patterns do not predict future price behavior. Use appropriate risk management on all trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Smart Money Concepts - Regime-Adaptive SMC [Dots3Red]",
          overlay=true, max_bars_back=500,
          max_labels_count=100, max_lines_count=100, max_boxes_count=100)

//COLORS
// Regime States
C_TREND    = color.new(#00f0ff, 0)
C_RANGE    = color.new(#ff00aa, 0)
C_VOLATILE = color.new(#ffb700, 0)
C_NEUTRAL  = color.new(#64748b, 0)

// Structural Markers
C_BOS_BULL   = color.new(#00f0ff, 0)
C_BOS_BEAR   = color.new(#ff4466, 0)
C_CHOCH_BULL = color.new(#00c896, 0)
C_CHOCH_BEAR = color.new(#ff00aa, 0)

// Institutional Order Blocks
C_OB_BULL   = color.new(#00c896, 82)
C_OB_BEAR   = color.new(#ff4466, 82)
C_OB_BULL_B = color.new(#00c896, 40)
C_OB_BEAR_B = color.new(#ff4466, 40)

// Fair Value Gaps (FIX 5: orange for bear FVG to avoid amber regime clash)
C_FVG_BULL   = color.new(#00f0ff, 85)
C_FVG_BEAR   = color.new(#f97316, 85)
C_FVG_BULL_B = color.new(#00f0ff, 60)
C_FVG_BEAR_B = color.new(#f97316, 60)

// Terminal UI Components
C_BG   = color.new(#131722, 5)
C_TXT  = color.new(#f8fafc, 0)
C_DIM  = color.new(#94a3b8, 0)
C_BORD = color.new(#334155, 0)

// ───────────────────────────────────────────────────────────────────────
// ⚙️ INPUT CONFIGURATION
// ───────────────────────────────────────────────────────────────────────
GRP_REG = "🧠 Regime Classifier"
GRP_STR = "📐 Market Structure"
GRP_OB  = "🧱 Order Blocks (Displacement Gated)"
GRP_FVG = "📊 Fair Value Gaps"
GRP_PD  = "⚖️ Premium / Discount"
GRP_VIS = "🎨 3DOTS Terminal UI"

// Regime Parameters
adx_len      = input.int   (14,   "ADX Length",              minval=5,   group=GRP_REG, display=display.none)
atr_len      = input.int   (14,   "ATR Length",              minval=5,   group=GRP_REG, display=display.none)
atr_base_len = input.int   (50,   "ATR Baseline Period",     minval=10,  group=GRP_REG, tooltip="Used to calculate historical expansion spikes.", display=display.none)
chop_len     = input.int   (14,   "Choppiness Length",       minval=5,   group=GRP_REG, display=display.none)
trend_thresh = input.float (0.6, "Trending Threshold",      minval=0.3, maxval=0.9, step=0.05, group=GRP_REG, display=display.none)
range_thresh = input.float (0.6, "Ranging Threshold",       minval=0.2, maxval=0.8, step=0.05, group=GRP_REG, display=display.none)
vol_thresh   = input.float (1.5,  "Volatile ATR Mult",       minval=1.0, maxval=4.0, step=0.1,  group=GRP_REG,
                            tooltip="ATR ratio threshold that triggers VOLATILE regime. 1.8–2.0 recommended for stock indices, 1.5–1.7 for crypto/forex. Lower = more sensitive to volatility expansions.", display=display.none)
smooth_len   = input.int   (6,   "Regime Smoothing Filter", minval=1,   maxval=20,  group=GRP_REG,
                            tooltip="Mode filter window. 5–7 for intraday, 10–15 for daily/weekly. Higher = fewer regime flips.", display=display.none)

// Structure Parameters
pivot_len  = input.int   (7,       "Swing Pivot Length",      minval=2,  maxval=20, group=GRP_STR, display=display.none)
conf_mode  = input.string("Close", "BOS/CHoCH Target Type",   options=["Close","Wick"], group=GRP_STR, display=display.none)
show_bos   = input.bool  (true,    "Display BOS Signals",     group=GRP_STR, display=display.none)
show_choch = input.bool  (true,    "Display CHoCH Signals",   group=GRP_STR, display=display.none)
show_swing = input.bool  (false,   "Label Macro Swing Points",group=GRP_STR, display=display.none)

// Order Block Execution Filter
show_ob    = input.bool (true, "Display Institutional OBs", group=GRP_OB, display=display.none)
ob_max     = input.int  (4,    "Max Dynamic OBs Per Side",   minval=1, maxval=8, group=GRP_OB, display=display.none)
ob_extend  = input.bool (true, "Trace Dynamic Tracking Zones",group=GRP_OB, display=display.none)
ob_mult    = input.float(0.8,  "OB Displacement Mult (ATR)", minval=0.3, maxval=3.0, step=0.1, group=GRP_OB, tooltip="Requires expansion momentum to register an Order Block. 0.5–1.0 for daily, 1.0–1.5 for intraday.", display=display.none)

// Fair Value Gaps
show_fvg    = input.bool (true, "Display Fair Value Gaps",   group=GRP_FVG, display=display.none)
fvg_max     = input.int  (4,    "Max Dynamic FVGs Per Side",  minval=1, maxval=8, group=GRP_FVG, display=display.none)
fvg_min_atr = input.float(0.15, "Min FVG Cutoff Threshold (ATR)", minval=0.0, maxval=2.0, step=0.05, group=GRP_FVG, display=display.none)
fvg_extend  = input.bool (true, "Trace Unfilled Gaps",        group=GRP_FVG, display=display.none)

// Premium / Discount
show_pd      = input.bool(true, "Display Premium/Discount Matrix", group=GRP_PD, display=display.none)
pd_swing_len = input.int (25,   "Lookback Optimization Horizon",   minval=5, maxval=100, group=GRP_PD, display=display.none)

// Visual Elements
show_dash   = input.bool  (true,        "Display DOT3RED Terminal HUD",group=GRP_VIS, display=display.none)
dash_pos    = input.string("Top Right", "HUD Placement Position",     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_VIS, display=display.none)

// REGIME CLASSIFIER ENGINE
atr_raw     = ta.atr(atr_len)
atr_base_ma = ta.sma(atr_raw, atr_base_len)
atr_ratio   = atr_raw / math.max(atr_base_ma, 1e-9)

[_dp, _dm, adx_val] = ta.dmi(adx_len, adx_len)
tr_sum   = math.sum(ta.tr(true), chop_len)
hi_max   = ta.highest(high, chop_len)
lo_min   = ta.lowest(low,   chop_len)
chop_raw = 100.0 * math.log10(tr_sum / math.max(hi_max - lo_min, 1e-9)) / math.log10(chop_len)

adx_norm  = math.min(adx_val / 60.0, 1.0)
chop_norm = 1.0 - math.min((chop_raw - 38.0) / 62.0, 1.0)
trend_score = (adx_norm + chop_norm) / 2.0

f_mode(src, len) =>
    int c0 = 0, int c1 = 0, int c2 = 0, int c3 = 0
    for k = 0 to len - 1
        v = src[k]
        if v == 0
            c0 += 1
        else if v == 1
            c1 += 1
        else if v == 2
            c2 += 1
        else
            c3 += 1
    mx = math.max(c0, c1, c2, c3)
    mx == c3 ? 3 : mx == c1 ? 1 : mx == c2 ? 2 : 0

raw_regime = atr_ratio > vol_thresh   ? 3 :
             trend_score > trend_thresh ? 1 :
             trend_score < range_thresh ? 2 : 0

regime       = f_mode(raw_regime, smooth_len)
reg_col      = regime == 1 ? C_TREND : regime == 2 ? C_RANGE : regime == 3 ? C_VOLATILE : C_NEUTRAL
reg_label    = regime == 1 ? "TRENDING" : regime == 2 ? "RANGING" : regime == 3 ? "VOLATILE" : "UNCERTAIN"

is_trending  = regime == 1
is_ranging   = regime == 2
is_volatile  = regime == 3
is_uncertain = regime == 0
show_all     = is_uncertain

// 📐 STRUCTURAL TRACKING ENGINE
ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow (low,  pivot_len, pivot_len)

var float last_sh   = na, var int last_sh_i = na
var float last_sl   = na, var int last_sl_i = na
var float prev_sh   = na, var float prev_sl = na

var int structural_trend = na

if not na(ph)
    prev_sh   := last_sh
    last_sh   := ph
    last_sh_i := bar_index - pivot_len
if not na(pl)
    prev_sl   := last_sl
    last_sl   := pl
    last_sl_i := bar_index - pivot_len

bull_conf = conf_mode == "Close" ? close : high
bear_conf = conf_mode == "Close" ? close : low

// Optimized Struct Arrays for Self-Pruning / Garbage Collection
var line[]  active_lines  = array.new<line>()
var label[] active_labels = array.new<label>()

f_prune_objects() =>
    if array.size(active_lines) > 60
        line.delete(array.pop(active_lines))
    if array.size(active_labels) > 60
        label.delete(array.pop(active_labels))


// BOS  = break in same direction as current structural trend (continuation)
//        OR the very first structural break of the chart (na trend = first move)
// CHoCH= break opposite to confirmed prior trend (reversal)
//        Requires structural_trend to be set (not na)
bull_bos        = not na(last_sh) and bull_conf > last_sh and bull_conf[1] <= last_sh and
                  (na(structural_trend) or structural_trend > 0)
bull_bos_show   = bull_bos and (show_all or is_trending or is_volatile)

bear_bos        = not na(last_sl) and bear_conf < last_sl and bear_conf[1] >= last_sl and
                  (na(structural_trend) or structural_trend < 0)
bear_bos_show   = bear_bos and (show_all or is_trending or is_volatile)

bull_choch      = not na(last_sh) and bull_conf > last_sh and bull_conf[1] <= last_sh and
                  not na(structural_trend) and structural_trend < 0
bull_choch_show = bull_choch and (show_all or is_ranging)

bear_choch      = not na(last_sl) and bear_conf < last_sl and bear_conf[1] >= last_sl and
                  not na(structural_trend) and structural_trend > 0
bear_choch_show = bear_choch and (show_all or is_ranging)

if bull_bos_show
    structural_trend := 1
    if show_bos
        array.unshift(active_labels, label.new(bar_index, last_sh + atr_raw * 1.5, "BOS", style=label.style_label_down, color=color.new(C_BOS_BULL, 90), textcolor=C_BOS_BULL, size=11, force_overlay=true))
        array.unshift(active_lines, line.new(last_sh_i, last_sh, bar_index, last_sh, color=color.new(C_BOS_BULL, 40), style=line.style_dashed, width=1, force_overlay=true))

if bear_bos_show
    structural_trend := -1
    if show_bos
        array.unshift(active_labels, label.new(bar_index, last_sl - atr_raw * 1.5, "BOS", style=label.style_label_up, color=color.new(C_BOS_BEAR, 90), textcolor=C_BOS_BEAR, size=11, force_overlay=true))
        array.unshift(active_lines, line.new(last_sl_i, last_sl, bar_index, last_sl, color=color.new(C_BOS_BEAR, 40), style=line.style_dashed, width=1, force_overlay=true))

if bull_choch_show
    structural_trend := 1
    if show_choch
        array.unshift(active_labels, label.new(bar_index, last_sh + atr_raw * 1.5, "CHoCH", style=label.style_label_down, color=color.new(C_CHOCH_BULL, 95), textcolor=C_CHOCH_BULL, size=11, force_overlay=true))
        array.unshift(active_lines, line.new(last_sh_i, last_sh, bar_index, last_sh, color=color.new(C_CHOCH_BULL, 20), style=line.style_dotted, width=2, force_overlay=true))

if bear_choch_show
    structural_trend := -1
    if show_choch
        array.unshift(active_labels, label.new(bar_index, last_sl - atr_raw * 1.5, "CHoCH", style=label.style_label_up, color=color.new(C_CHOCH_BEAR, 95), textcolor=C_CHOCH_BEAR, size=11, force_overlay=true))
        array.unshift(active_lines, line.new(last_sl_i, last_sl, bar_index, last_sl, color=color.new(C_CHOCH_BEAR, 20), style=line.style_dotted, width=2, force_overlay=true))

f_prune_objects()

// ───────────────────────────────────────────────────────────────────────
// 🧱 REGIME-ADAPTIVE ORDER BLOCKS (DISPLACEMENT GATED)
// ───────────────────────────────────────────────────────────────────────
type OBData
    box   box_id
    float top
    float bot
    int   start
    bool  bull
    bool  active

var OBData[] bull_obs = array.new<OBData>()
var OBData[] bear_obs = array.new<OBData>()

// Institutional Displacement Qualification
displacement_impulse = math.abs(close - open) > (atr_raw * ob_mult)

if show_ob and displacement_impulse
    // Trending Regime Execution: Continuation Order Blocks via Structure Breaks
    if is_trending or show_all
        if bull_bos
            ob_top = open[1] > close[1] ? open[1] : close[1]
            ob_bot = low[1]
            b = box.new(bar_index - 1, ob_top, bar_index, ob_bot, border_color=C_OB_BULL_B, bgcolor=C_OB_BULL, border_width=1, force_overlay=true)
            array.unshift(bull_obs, OBData.new(b, ob_top, ob_bot, bar_index - 1, true, true))
        if bear_bos
            ob_top = high[1]
            ob_bot = open[1] > close[1] ? close[1] : open[1]
            b = box.new(bar_index - 1, ob_top, bar_index, ob_bot, border_color=C_OB_BEAR_B, bgcolor=C_OB_BEAR, border_width=1, force_overlay=true)
            array.unshift(bear_obs, OBData.new(b, ob_top, ob_bot, bar_index - 1, false, true))

    // Ranging Regime Execution: Mean Reversion Reversal Blocks via CHoCH Changes
    if is_ranging or show_all
        if bull_choch
            ob_top = open[1] > close[1] ? open[1] : close[1]
            ob_bot = low[1]
            b = box.new(bar_index - 1, ob_top, bar_index, ob_bot, border_color=C_OB_BULL_B, bgcolor=C_OB_BULL, border_width=1, force_overlay=true)
            array.unshift(bull_obs, OBData.new(b, ob_top, ob_bot, bar_index - 1, true, true))
        if bear_choch
            ob_top = high[1]
            ob_bot = open[1] > close[1] ? close[1] : open[1]
            b = box.new(bar_index - 1, ob_top, bar_index, ob_bot, border_color=C_OB_BEAR_B, bgcolor=C_OB_BEAR, border_width=1, force_overlay=true)
            array.unshift(bear_obs, OBData.new(b, ob_top, ob_bot, bar_index - 1, false, true))

    // Array Pruning Management Engine
    if array.size(bull_obs) > ob_max
        box.delete(array.pop(bull_obs).box_id)
    if array.size(bear_obs) > ob_max
        box.delete(array.pop(bear_obs).box_id)


//   Bullish OB mitigated when low <= ob.top   (price entered from above into the zone)
//   Bearish OB mitigated when high >= ob.bot  (price entered from below into the zone)
if show_ob
    if array.size(bull_obs) > 0
        for i = 0 to array.size(bull_obs) - 1
            ob = array.get(bull_obs, i)
            if ob.active
                if low <= ob.top
                    ob.active := false
                    box.set_border_color(ob.box_id, color.new(C_OB_BULL_B, 85))
                    box.set_bgcolor(ob.box_id, color.new(C_OB_BULL, 96))
                else if ob_extend
                    box.set_right(ob.box_id, bar_index)
                array.set(bull_obs, i, ob)

    if array.size(bear_obs) > 0
        for i = 0 to array.size(bear_obs) - 1
            ob = array.get(bear_obs, i)
            if ob.active
                if high >= ob.bot
                    ob.active := false
                    box.set_border_color(ob.box_id, color.new(C_OB_BEAR_B, 85))
                    box.set_bgcolor(ob.box_id, color.new(C_OB_BEAR, 96))
                else if ob_extend
                    box.set_right(ob.box_id, bar_index)
                array.set(bear_obs, i, ob)

// ───────────────────────────────────────────────────────────────────────
// 📊 FAIR VALUE GAPS ENGINE
// ───────────────────────────────────────────────────────────────────────
type FVGData
    box   box_id
    float top
    float bot
    int   start
    bool  bull
    bool  active

var FVGData[] bull_fvgs = array.new<FVGData>()
var FVGData[] bear_fvgs = array.new<FVGData>()

if show_fvg and (is_trending or is_ranging or show_all)
    min_fvg = fvg_min_atr * atr_raw

    // Bullish Expansion Gap Calculation
    if high[2] < low[0] and (low[0] - high[2]) >= min_fvg
        b = box.new(bar_index - 2, low[0], bar_index, high[2], border_color=C_FVG_BULL_B, bgcolor=C_FVG_BULL, border_width=1, force_overlay=true)
        array.unshift(bull_fvgs, FVGData.new(b, low[0], high[2], bar_index - 2, true, true))
        if array.size(bull_fvgs) > fvg_max
            box.delete(array.pop(bull_fvgs).box_id)

    // Bearish Expansion Gap Calculation
    if low[2] > high[0] and (low[2] - high[0]) >= min_fvg
        b = box.new(bar_index 
        
    - 2, low[2], bar_index, high[0], border_color=C_FVG_BEAR_B, bgcolor=C_FVG_BEAR, border_width=1, force_overlay=true)
        array.unshift(bear_fvgs, FVGData.new(b, low[2], high[0], bar_index - 2, false, true))
        if array.size(bear_fvgs) > fvg_max
            box.delete(array.pop(bear_fvgs).box_id)

//   Bullish FVG filled when low <= fvg.top   (price entered the gap from above)
//   Bearish FVG filled when high >= fvg.bot  (price entered the gap from below)
if show_fvg
    if array.size(bull_fvgs) > 0
        for i = 0 to array.size(bull_fvgs) - 1
            fvg = array.get(bull_fvgs, i)
            if fvg.active
                if low <= fvg.top
                    fvg.active := false
                    box.set_border_color(fvg.box_id, color.new(C_FVG_BULL_B, 90))
                    box.set_bgcolor(fvg.box_id, color.new(C_FVG_BULL, 97))
                else if fvg_extend
                    box.set_right(fvg.box_id, bar_index)
                array.set(bull_fvgs, i, fvg)

    if array.size(bear_fvgs) > 0
        for i = 0 to array.size(bear_fvgs) - 1
            fvg = array.get(bear_fvgs, i)
            if fvg.active
                if high >= fvg.bot
                    fvg.active := false
                    box.set_border_color(fvg.box_id, color.new(C_FVG_BEAR_B, 90))
                    box.set_bgcolor(fvg.box_id, color.new(C_FVG_BEAR, 97))
                else if fvg_extend
                    box.set_right(fvg.box_id, bar_index)
                array.set(bear_fvgs, i, fvg)


swing_high = ta.highest(high, pd_swing_len)
swing_low  = ta.lowest (low,  pd_swing_len)
swing_mid  = (swing_high + swing_low) / 2.0
swing_75   = swing_low + (swing_high - swing_low) * 0.75
swing_25   = swing_low + (swing_high - swing_low) * 0.25

pd_pct = swing_high != swing_low ? (close - swing_low) / (swing_high - swing_low) * 100.0 : 50.0
pd_zone = pd_pct >= 75 ? "PREMIUM" : pd_pct <= 25 ? "DISCOUNT" : "EQUILIBRIUM"

//plot(show_pd ? swing_mid : na, "Equilibrium (50%)", color=color.new(C_NEUTRAL, 22), linewidth=1, style=plot.style_circles)
plot(show_pd ? swing_75 : na,  "Premium (75%)",      color=color.new(C_BOS_BEAR, 22), linewidth=1, style=plot.style_stepline)
plot(show_pd ? swing_25 : na,  "Discount (25%)",     color=color.new(C_OB_BULL, 22),  linewidth=1, style=plot.style_stepline)

// Quantifying Algorithmic Flow
int bull_score = 0
int bear_score = 0

// Component 1: Market Structural Trend Flow Orientation
int st_safe = na(structural_trend) ? 0 : structural_trend
if st_safe == 1
    bull_score += 35
if st_safe == -1
    bear_score += 35

// Component 2: Supply & Demand Boundaries Matrix Locations
if pd_pct <= 25
    bull_score += 30
if pd_pct >= 75
    bear_score += 30
if pd_pct > 25 and pd_pct < 75
    if st_safe == 1
        bull_score += 15
    if st_safe == -1
        bear_score += 15

// Component 3: Regime Momentum Matching Conditions
if is_trending
    if st_safe == 1
        bull_score += 35
    if st_safe == -1
        bear_score += 35
if is_ranging
    if pd_pct <= 35
        bull_score += 25
    if pd_pct >= 65
        bear_score += 25

total_score = bull_score + bear_score
float bias_pct = total_score > 0 ? (bull_score / float(total_score)) * 100.0 : 50.0

// Volatile / Uncertain overrides — OB/FVG signals are suppressed in these regimes
if is_volatile
    bias_pct := 50.0
if is_uncertain
    bias_pct := 50.0

string bias_txt = is_volatile  ? "⚡ STAND ASIDE" :
                  is_uncertain ? "— WAIT FOR REGIME" :
                  bias_pct >= 60 ? "▲ AGGRESSIVE BUY" :
                  bias_pct <= 40 ? "▼ AGGRESSIVE SELL" : "● NEUTRAL BIAS"
color bias_col  = is_volatile  ? C_VOLATILE :
                  is_uncertain ? C_NEUTRAL :
                  bias_pct >= 60 ? C_OB_BULL :
                  bias_pct <= 40 ? C_BOS_BEAR : C_DIM


barcolor(is_trending  ? color.new(C_TREND,    35) :
         is_ranging   ? color.new(C_RANGE,    35) :
         is_volatile  ? color.new(C_VOLATILE, 35) :
                        color.new(C_NEUTRAL,  35))

reg_changed = regime != regime[1]

// (ENGINE VISUALS)
if show_dash and barstate.islast
    tp = switch dash_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

    var table hud = table.new(tp, 2, 11, bgcolor=C_BG, border_color=C_BORD, border_width=2, frame_color=C_BORD, frame_width=2)

    table.cell(hud, 0, 0, "DOTS3RED SMC TERMINAL", text_color=C_TXT, bgcolor=color.new(#1e293b, 0), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    // Current Structural Market Mode
    table.cell(hud, 0, 1, "Regime state", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 1, reg_label, text_color=reg_col, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    // Algorithmic Structural Confidence Matrix Visualization Component
    int fill_blocks = math.round(trend_score * 10)
    string progress_bar = ""
    for i = 1 to 10
        progress_bar := progress_bar + (i <= fill_blocks ? "■" : "□")

    table.cell(hud, 0, 2, "Regime Confidence", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 2, progress_bar + " " + str.tostring(math.round(trend_score * 100, 1)) + "%", text_color=reg_col, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    // Algorithmic Trade Direction Matrix Evaluator Dashboard Display Row
    table.cell(hud, 0, 3, "SMC Bias Matrix", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 3, bias_txt + " (" + str.tostring(math.round(bias_pct, 1)) + "%)", text_color=bias_col, bgcolor=color.new(#1e293b, 40), text_size=12, text_halign=text.align_center)

    // Visual Features Boundary Dividers Split
    table.cell(hud, 0, 4, "─── Core Analytics Engine ───", text_color=C_DIM, bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 4, 1, 4)

    // Premium / Discount Positioning Engine Metrics
    table.cell(hud, 0, 5, "P/D Location Matrix", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 5, pd_zone + " (" + str.tostring(math.round(pd_pct, 1)) + "%)", text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    // ADX System Metric Tracking Components
    table.cell(hud, 0, 6, "ADX Velocity Threshold", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 6, str.tostring(math.round(adx_val, 1)), text_color=adx_val > 25 ? C_TREND : C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    // Choppiness Boundaries Logic Array Variables Values
    table.cell(hud, 0, 7, "Choppiness Wave Index", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 7, str.tostring(math.round(chop_raw, 1)), text_color=chop_raw > 61.8 ? C_RANGE : C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    // Dynamic Historical Expansion Metrics
    table.cell(hud, 0, 8, "ATR Volatility Ratio", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 8, str.tostring(math.round(atr_ratio, 2)) + "×", text_color=atr_ratio > vol_thresh ? C_VOLATILE : C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    // Quantifying Live Dynamic Active Structure Blocks Tracking Counters
    int bull_ob_active = 0, int bear_ob_active = 0
    if array.size(bull_obs) > 0
        for i = 0 to array.size(bull_obs) - 1
            if array.get(bull_obs, i).active
                bull_ob_active += 1
    if array.size(bear_obs) > 0
        for i = 0 to array.size(bear_obs) - 1
            if array.get(bear_obs, i).active
                bear_ob_active += 1

    table.cell(hud, 0, 9, "Active Displaced OBs", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 9, "▲ " + str.tostring(bull_ob_active) + "   ▼ " + str.tostring(bear_ob_active), text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    // Quantifying Active Unfilled Dynamic Tracking Fair Value Gaps Boundaries Counters
    int bull_fvg_active = 0, int bear_fvg_active = 0
    if array.size(bull_fvgs) > 0
        for i = 0 to array.size(bull_fvgs) - 1
            if array.get(bull_fvgs, i).active
                bull_fvg_active += 1
    if array.size(bear_fvgs) > 0
        for i = 0 to array.size(bear_fvgs) - 1
            if array.get(bear_fvgs, i).active
                bear_fvg_active += 1

    table.cell(hud, 0, 10, "Unfilled Mitigated FVGs", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_left)
    table.cell(hud, 1, 10, "▲ " + str.tostring(bull_fvg_active) + "   ▼ " + str.tostring(bear_fvg_active), text_color=C_TXT, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

// 🚨 SYSTEM ALERTS ENGINE INTERFACE CONTEXTS
alertcondition(bull_bos_show,   "SMC — Bull BOS",         "Bullish Break of Structure detected")
alertcondition(bear_bos_show,   "SMC — Bear BOS",         "Bearish Break of Structure detected")
alertcondition(bull_choch_show, "SMC — Bull CHoCH",       "Bullish Change of Character detected")
alertcondition(bear_choch_show, "SMC — Bear CHoCH",       "Bearish Change of Character detected")
alertcondition(reg_changed and is_trending,  "Regime → Trending", "Regime shifted to TRENDING — Structural Break Strategy Active")
alertcondition(reg_changed and is_ranging,   "Regime → Ranging",  "Regime shifted to RANGING — Reversal Mean Reversion Active")
alertcondition(reg_changed and is_volatile,  "Regime → Volatile", "Regime shifted to VOLATILE — Momentum Safeguards Triggered")
````
