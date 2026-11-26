# Trendline Bounce [EXCAVO]

- url: https://www.tradingview.com/script/Z78OA1Ku-Trendline-Bounce-EXCAVO/
- type: indicator
- pine_id: PUB;8011939fd7bd4c7e8659403785cb7b74
- version: 1.0

## Description

Automatic Trendline Detection with Multi-Stage Bounce Detection and Quality Filters

The [i]Trendline Bounce[/i] automatically identifies support and resistance trendlines
validated by three or more confirmed pivot touches. When price returns to an established
line, the indicator places a directional bounce arrow and triggers the alert. A dual-
lookback architecture fires earlier than traditional pivot-confirmation methods, while
span, regime, and trend filters eliminate structurally weak or contextually invalid setups.

This is not a simple two-point line connector. The slope is derived from a best-fit
search across all qualifying pivots, every candidate line is rejected if any candle
between touch points crosses the boundary, and three parallel detection channels reduce
the confirmation delay without sacrificing structural validity.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. Trendlines appear immediately - solid line
              is the most recent valid line per direction, dashed lines are
              the previous ones (up to Max Lines per Side).
[b]Step 2[/b]  →  Watch for the bounce arrow. A triangle (▲ or ▼) marks the bar
              where the third or later touch is detected. Check the dashboard
              for the quality grade (A / B / C).
[b]Step 3[/b]  →  Use the Trend Filter and ATR Regime Filter inputs to narrow the
              context. Enable Trend Filter to gate bounces by 200 EMA direction.
              Enable ATR Regime Filter to suppress detections during extreme
              volatility spikes.
[b]Step 4[/b]  →  Adjust Early Detection Lookback to trade off timing vs. accuracy.
              Lower values fire earlier but may produce more noise. The Detection
              Lookback controls the quality trendline anchor; Early Detection
              Lookback controls how quickly subsequent touches are confirmed.
[b]Step 5[/b]  →  Use dashed historical lines for context. They show where price
              previously respected trendlines and may act as reference levels.
[b]Step 6[/b]  →  Set alerts to monitor conditions in real time. Use "Any Bounce"
              for general monitoring or direction-specific alerts for automated
              setups via webhook.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Pivot Detection (Quality Layer)[/b]
Swing highs and lows are confirmed using ta.pivothigh() / ta.pivotlow() with
Detection Lookback bars required on each side (default 14). A pivot high at bar B
requires bar B's high to be the maximum of the surrounding 14 bars on both sides.
Up to 60 pivots per direction are stored in a rolling buffer. These quality pivots
form the structural anchor for trendline fitting.

[b]◆  Best-Slope Trendline Fitting[/b]
For each anchor pivot A, the algorithm scans all other pivots B to compute slope:
sl = (price_B - price_A) / (bar_B - bar_A). Slopes steeper than 0.5 x ATR per bar
are rejected. For each valid slope, the algorithm counts how many pivots fall within
ATR x Tolerance of the projected line. The slope maximizing confirmed touch count
(minimum 3) is selected. This approach finds the line that fits the most pivots
rather than simply connecting two points.

[b]◆  Breakout Rejection Sampling[/b]
Once a candidate line passes the touch count test, 60 evenly spaced bars between the
first and last touch are sampled. If any sampled bar's high (for resistance) or low
(for support) exceeds the projected price plus tolerance, the line is rejected. This
catches wick or body violations between pivot points that pure pivot-based validation
would miss.

[b]◆  Minimum Span Filter[/b]
A trendline whose first and last touch are fewer than Min Trendline Span bars apart
is discarded. Three pivots clustered within a few bars share no structural significance.
This filter ensures every displayed line represents a meaningful price reaction period,
not a short-term oscillation.

[b]◆  Three-Channel Bounce Detection[/b]
After the structural line set is built, three parallel detection channels produce the
bounce arrow:

1. Quality path: when the most recent quality pivot (i_len delay) falls on an
   established line within the tolerance band, a detection fires.
2. Early path: when the most recent fast pivot (Early Detection Lookback, default 5)
   touches an already-established quality trendline, a detection fires earlier than
   waiting for full quality confirmation.
3. Real-time path: every tick, each stored trendline is projected to the current bar.
   If the current bar's high (resistance) or low (support) enters the tolerance band,
   a detection fires immediately without waiting for pivot confirmation.

All three channels require the line to have been built from quality pivots. The early
and real-time channels only fire against pre-validated structural lines - they do not
create new lines themselves.

[b]◆  Trend and Regime Gates[/b]
Two optional gates filter the output of all three detection channels. The Trend Filter
(200 EMA) passes bullish detections only when close is above the EMA and bearish
detections only when close is below. The ATR Regime Filter computes
ta.percentrank(ATR, 200) / 100 and suppresses all detections when the result exceeds
0.90 - this blocks entries during the top 10% of volatility events where trendline
breaks are more likely than bounces.

[b]◆  Bounce Grade (A / B / C)[/b]
Each detected bounce is evaluated at the detection bar: volume ratio = volume /
SMA(volume, 20); wick position = (close - low) / (high - low) for bullish or
(high - close) / (high - low) for bearish. Grade A requires volume ratio >= 2.0
AND wick position >= 0.60. Grade B requires ratio >= 1.5 OR position >= 0.50.
Grade C is assigned otherwise.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Best-Slope Fitting Across All Pivots[/b]
Rather than connecting only two pivots, the algorithm finds the slope that maximizes
the number of confirmed touches. A line with three near-misses is ranked higher than
a line connecting two pivots perfectly, because more touches represent stronger
structural significance.

[b]◆  Breakout Rejection via Bar Sampling[/b]
Most trendline tools draw a line between any two pivots regardless of what happens in
between. This indicator samples 60 bars between the first and last touch and rejects
any line where a candle crosses the boundary. Only lines price has genuinely respected
are shown.

[b]◆  Minimum Span Filter[/b]
Trendlines that form in fewer bars than the span threshold are discarded. This removes
short-term pivot clusters that look like trendlines but carry no structural weight.
The result is fewer, higher-quality lines.

[b]◆  Three-Channel Detection for Earlier Timing[/b]
Traditional trendline indicators confirm a bounce only after the full pivot lookback
elapses - on a 4H chart with lookback 14, that is 56 hours after the actual low. The
early detection channel reduces this to 5 bars (20 hours on 4H). The real-time channel
fires on the current bar. Both channels require the line to already be structurally
validated - they reduce timing delay without introducing unvalidated lines.

[b]◆  Trend and Regime Filters[/b]
The 200 EMA gate removes counter-trend detections. The ATR regime gate suppresses
detections during the highest-volatility periods where trendline structure tends to
break rather than hold. Both filters are optional and off by default.

[b]◆  Exact Touch Markers[/b]
Circles are placed at actual candle prices (high for resistance, low for support), not
at the theoretical projected price on the line. This makes it immediately visible
whether the wick tapped the line or the body closed through it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right corner) showing current state:
[list]
[*][b]Last Bounce[/b] - direction (▲ bullish / ▼ bearish) and quality grade (A/B/C) of the most recent bounce
[*][b]Trend (200 EMA)[/b] - current price position relative to 200 EMA (▲ Bull / ▼ Bear)
[*][b]Lines  R / S[/b] - count of currently active resistance and support trendlines
[/list]

Legend table (bottom left) explains every visual element. Both panels can be
toggled independently in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Trendlines[/b]
[list]
[*][b]Detection Lookback[/b] - 14 bars (bars on each side to confirm a quality swing pivot; higher = fewer but stronger lines)
[*][b]Max Lines per Side[/b] - 5 (maximum number of trendlines shown per direction)
[*][b]Tolerance (xATR)[/b] - 0.5 (ATR multiple defining how close a pivot must be to the line to count as a touch)
[*][b]Min Trendline Span[/b] - 30 bars (minimum bars between first and last touch; filters structurally insignificant lines)
[/list]

[b]Bounce Detection[/b]
[list]
[*][b]Min Touches[/b] - 3 (minimum confirmed touches before a bounce arrow appears)
[*][b]Show Grade (A/B/C)[/b] - ON (display quality grade in the dashboard)
[*][b]Early Detection Lookback[/b] - 5 bars (shorter lookback for faster bounce detection on established lines)
[*][b]Trend Filter (200 EMA)[/b] - OFF (when ON: bullish bounces above EMA only, bearish below only)
[*][b]ATR Regime Filter[/b] - OFF (when ON: suppresses detections when ATR is above 90th percentile of last 200 bars)
[/list]

[b]Visualization[/b]
[list]
[*][b]Support Color[/b] - blue (color for support trendlines and bullish bounce arrows)
[*][b]Resistance Color[/b] - red (color for resistance trendlines and bearish bounce arrows)
[*][b]Bounce Color[/b] - orange (color for bounce arrows)
[*][b]Bar Coloring[/b] - OFF (color bars on bounce detection using direction color)
[*][b]Show 200 EMA[/b] - OFF (plot 200-bar EMA on the chart)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Dashboard Position[/b] - Top Right (Top Right / Top Left / Bottom Right / Bottom Left)
[*][b]Show Legend[/b] - ON
[/list]

[b]Alert Settings[/b]
[list]
[*][b]Allow Repainting[/b] - OFF (when off, detection confirms at bar close; enable only if monitoring open bars)
[*][b]JSON Alerts[/b] - OFF (structured JSON payload for webhook automation)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Bullish Bounce[/b] - price touches a confirmed support trendline for the 3rd+ time
[*][b]Bearish Bounce[/b] - price touches a confirmed resistance trendline for the 3rd+ time
[*][b]Any Bounce[/b] - bounce detected in either direction
[/list]

All alerts respect the Allow Repainting setting. When off, bounces are confirmed
at bar close only. JSON Alerts option sends a structured payload with ticker,
price, timeframe, direction, and grade fields.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Trendline Bounce [EXCAVO]
// -----------------------------------------------------------------------------
// Quality trendlines (i_len pivots) + fast signals (i_sig_len pivots) +
// real-time projection. Trend filter, ATR regime filter, min span filter.
// All drawing unified in barstate.islast.
//
//@version=6
indicator("Trendline Bounce [EXCAVO]", "EXCAVO Trendline Bounce",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500,
     max_bars_back    = 5000)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_TL     = "Trendlines"
string GRP_BOUNCE = "Bounce Detection"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALERTS = "Alert Settings"

int    i_len      = input.int  (14,   "Detection Lookback",     minval = 5,   maxval = 50,  group = GRP_TL,
     tooltip = "Bars on each side to confirm a quality swing pivot for trendline building. Higher = fewer but stronger lines.")
int    i_max_tl   = input.int  (5,    "Max Lines per Side",     minval = 1,   maxval = 10,  group = GRP_TL,
     tooltip = "Most recent valid lines shown per direction.")
float  i_tol      = input.float(0.5,  "Tolerance (xATR)",       minval = 0.1, maxval = 3.0, step = 0.1, group = GRP_TL,
     tooltip = "ATR multiple for how close a pivot must be to the line to count as a touch.")
int    i_min_span = input.int  (30,   "Min Trendline Span",     minval = 5,   maxval = 300, group = GRP_TL,
     tooltip = "Minimum bars between first and last touch. Filters trendlines that formed too quickly to be structurally significant.")

int    i_min_tch  = input.int  (3,    "Min Touches",            minval = 2,   maxval = 10,  group = GRP_BOUNCE,
     tooltip = "Minimum confirmed touches before a bounce arrow appears.")
bool   i_grade    = input.bool (true, "Show Grade (A/B/C)",      group = GRP_BOUNCE,
     tooltip = "Grade A = high volume + strong close. B = partial. C = weak.")
int    i_sig_len  = input.int  (5,    "Early Detection Lookback", minval = 2, maxval = 20,  group = GRP_BOUNCE,
     tooltip = "Shorter pivot lookback for earlier bounce detection. Fires when a fast pivot touches an established trendline - reduces delay vs Detection Lookback.")
bool   i_trend_filter = input.bool(false, "Trend Filter (200 EMA)", group = GRP_BOUNCE,
     tooltip = "When ON: bullish bounces only above 200 EMA, bearish bounces only below. Cuts counter-trend detections.")
bool   i_atr_filter   = input.bool(false, "ATR Regime Filter",      group = GRP_BOUNCE,
     tooltip = "When ON: suppress bounce arrows during extreme volatility (ATR above 90th percentile of last 200 bars). Avoids liquidation cascade entries.")

color  C_BULL     = input.color(color.rgb(0, 60, 180),  "Support Color",    group = GRP_VIZ,
     tooltip = "Color for support trendlines and bullish bounce arrows.")
color  C_BEAR     = input.color(color.rgb(200, 40, 40), "Resistance Color", group = GRP_VIZ,
     tooltip = "Color for resistance trendlines and bearish bounce arrows.")
color  C_SIGNAL   = input.color(color.rgb(255, 140, 0), "Bounce Color",     group = GRP_VIZ,
     tooltip = "Color for bounce arrows.")
bool   i_bar_clr  = input.bool (false, "Bar Coloring",            group = GRP_VIZ,
     tooltip = "Color bars on bounce detection using direction color.")
bool   i_show_ema = input.bool (false, "Show 200 EMA",            group = GRP_VIZ,
     tooltip = "Plot 200-bar EMA on the chart.")

bool   showDash   = input.bool  (true,       "Show Dashboard",    group = GRP_DASH)
string i_dash_pos = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)
bool   showLgnd   = input.bool  (true, "Show Legend",             group = GRP_DASH)

bool   i_repaint  = input.bool (false, "Allow Repainting",        group = GRP_ALERTS,
     tooltip = "When off, detection confirms at bar close. Enable only if monitoring open bars.")
bool   i_json     = input.bool (false, "JSON Alerts",             group = GRP_ALERTS,
     tooltip = "Fire structured JSON alerts for webhook automation.")

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80, 80, 100)
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)

//-----------------------------------------------------------------------------}
// Core
//-----------------------------------------------------------------------------{
bool  confirmed    = i_repaint or barstate.isconfirmed
float atr_val      = ta.atr(14)
float tol          = atr_val * i_tol
float vol_sma      = ta.sma(volume, 20)
float ema200       = ta.ema(close, 200)

// Trend filter gates (pass-through when filter is off)
bool  trend_bull   = not i_trend_filter or close > ema200
bool  trend_bear   = not i_trend_filter or close < ema200

// ATR regime filter (pass-through when filter is off)
float atr_pctrank  = ta.percentrank(atr_val, 200) / 100
bool  regime_ok    = not i_atr_filter or atr_pctrank < 0.90

// -- Quality pivots (trendline detection, i_len lookback) --------------------
float ph = ta.pivothigh(i_len, i_len)
float pl = ta.pivotlow (i_len, i_len)

var array<float> hi_p = array.new<float>()
var array<int>   hi_b = array.new<int>()
var array<float> lo_p = array.new<float>()
var array<int>   lo_b = array.new<int>()

if not na(ph) and confirmed
    hi_p.push(ph)
    hi_b.push(bar_index - i_len)
    if hi_p.size() > 60
        hi_p.shift()
        hi_b.shift()

if not na(pl) and confirmed
    lo_p.push(pl)
    lo_b.push(bar_index - i_len)
    if lo_p.size() > 60
        lo_p.shift()
        lo_b.shift()

// -- Fast pivots (early detection, i_sig_len lookback) -----------------------
float ph_sig = ta.pivothigh(i_sig_len, i_sig_len)
float pl_sig = ta.pivotlow (i_sig_len, i_sig_len)

var array<float> sig_hi_p = array.new<float>()
var array<int>   sig_hi_b = array.new<int>()
var array<float> sig_lo_p = array.new<float>()
var array<int>   sig_lo_b = array.new<int>()

if not na(ph_sig) and confirmed
    sig_hi_p.push(ph_sig)
    sig_hi_b.push(bar_index - i_sig_len)
    if sig_hi_p.size() > 30
        sig_hi_p.shift()
        sig_hi_b.shift()

if not na(pl_sig) and confirmed
    sig_lo_p.push(pl_sig)
    sig_lo_b.push(bar_index - i_sig_len)
    if sig_lo_p.size() > 30
        sig_lo_p.shift()
        sig_lo_b.shift()

//-----------------------------------------------------------------------------}
// Helpers
//-----------------------------------------------------------------------------{
f_grade(bool isBull) =>
    float vr = vol_sma > 0 ? volume / vol_sma : 1.0
    float wp = (high - low) > 0 ? (isBull ? (close - low) / (high - low) : (high - close) / (high - low)) : 0.5
    string g = vr >= 2.0 and wp >= 0.6 ? "A" : vr >= 1.5 or wp >= 0.5 ? "B" : "C"
    g

//-----------------------------------------------------------------------------}
// Signal State
//-----------------------------------------------------------------------------{
var string lastGrade = ""
var string lastDir   = ""

// Trendline params - populated each barstate.islast for real-time projection
var array<float> tl_pa     = array.new<float>()
var array<int>   tl_ba     = array.new<int>()
var array<float> tl_sl     = array.new<float>()
var array<bool>  tl_res    = array.new<bool>()
var array<int>   tl_last_b = array.new<int>()

// Declared before barstate.islast so the drawing block can set them directly
bool sigBull = false
bool sigBear = false

//-----------------------------------------------------------------------------}
// Visual Redraw (barstate.islast - lines + circles + arrows always together)
//-----------------------------------------------------------------------------{
var array<line>  v_lines = array.new<line>()
var array<label> v_dots  = array.new<label>()

if barstate.islast
    for l in v_lines
        line.delete(l)
    for l in v_dots
        label.delete(l)
    v_lines.clear()
    v_dots.clear()
    tl_pa.clear()
    tl_ba.clear()
    tl_sl.clear()
    tl_res.clear()
    tl_last_b.clear()

    // -- Resistance lines (swing highs) --------------------------------------
    int n_hi = hi_p.size()
    if n_hi >= i_min_tch
        int drawn_res = 0
        array<int> used_res = array.new<int>()

        for a = n_hi - 1 to 0
            if drawn_res >= i_max_tl
                break
            bool skip = false
            if used_res.size() > 0
                for u = 0 to used_res.size() - 1
                    if used_res.get(u) == a
                        skip := true
                        break
            if skip
                continue

            int   ba = hi_b.get(a)
            float pa = hi_p.get(a)
            int   best_b   = -1
            int   best_tch = 0
            float best_sl  = 0.0

            for b = 0 to n_hi - 1
                if b == a
                    continue
                int   bb = hi_b.get(b)
                float pb = hi_p.get(b)
                if bb == ba
                    continue
                float sl = (pb - pa) / (bb - ba)
                if math.abs(sl) > atr_val * 0.5
                    continue
                int n = 0
                for j = 0 to n_hi - 1
                    float pj = pa + sl * (hi_b.get(j) - ba)
                    if math.abs(hi_p.get(j) - pj) <= tol
                        n += 1
                if n >= i_min_tch and n > best_tch
                    bool ok = true
                    for j = 0 to n_hi - 1
                        float pj = pa + sl * (hi_b.get(j) - ba)
                        if hi_p.get(j) > pj + tol
                            ok := false
                            break
                    if ok
                        best_tch := n
                        best_b   := b
                        best_sl  := sl

            if best_b < 0
                continue

            float sl = best_sl

            array<int>   t_bars = array.new<int>()
            array<float> t_ys   = array.new<float>()
            array<int>   t_idxs = array.new<int>()
            for j = 0 to n_hi - 1
                float pj = pa + sl * (hi_b.get(j) - ba)
                if math.abs(hi_p.get(j) - pj) <= tol
                    t_bars.push(hi_b.get(j))
                    t_ys.push(hi_p.get(j))
                    t_idxs.push(j)
            int tsz = t_bars.size()
            for i1 = 0 to tsz - 2
                for i2 = i1 + 1 to tsz - 1
                    if t_bars.get(i2) < t_bars.get(i1)
                        int   tmp_b = t_bars.get(i1)
                        float tmp_y = t_ys.get(i1)
                        int   tmp_i = t_idxs.get(i1)
                        t_bars.set(i1, t_bars.get(i2))
                        t_ys.set(i1, t_ys.get(i2))
                        t_idxs.set(i1, t_idxs.get(i2))
                        t_bars.set(i2, tmp_b)
                        t_ys.set(i2, tmp_y)
                        t_idxs.set(i2, tmp_i)

            // Min span filter: trendline must cover at least i_min_span bars
            if t_bars.get(tsz - 1) - t_bars.get(0) < i_min_span
                continue

            if math.abs(t_ys.get(tsz - 1) - close) > atr_val * 20
                continue

            // Reject if any bar between touches has a high above the line (breakout)
            bool r_clear = true
            int  r_s     = t_bars.get(0)
            int  r_e     = t_bars.get(tsz - 1)
            int  r_step  = math.max(1, (r_e - r_s) / 60)
            int  r_cb    = r_s
            for ri = 0 to 60
                if r_cb > r_e
                    break
                if high[bar_index - r_cb] > pa + sl * (r_cb - ba) + tol
                    r_clear := false
                    break
                r_cb += r_step
            if not r_clear
                continue

            // Accept
            drawn_res += 1
            for k = 0 to tsz - 1
                used_res.push(t_idxs.get(k))
            tl_pa.push(pa)
            tl_ba.push(ba)
            tl_sl.push(sl)
            tl_res.push(true)
            tl_last_b.push(t_bars.get(tsz - 1))

            // Quality pivot confirmed as touch (i_len delay, standard path)
            if t_bars.get(tsz - 1) >= bar_index - i_len and confirmed and trend_bear and regime_ok
                sigBear := true

            float y1_proj = pa + sl * (t_bars.get(0) - ba)
            float y2_proj = pa + sl * (t_bars.get(tsz - 1) - ba)
            bool  is_active = (drawn_res == 1)
            color ln_clr    = is_active ? C_BEAR : color.new(C_BEAR, 55)
            int   ln_w      = is_active ? 2 : 1
            v_lines.push(line.new(t_bars.get(0), y1_proj,
                 t_bars.get(tsz - 1), y2_proj,
                 color = ln_clr, width = ln_w,
                 style = is_active ? line.style_solid : line.style_dashed))

            for j = 0 to tsz - 1
                v_dots.push(label.new(t_bars.get(j), t_ys.get(j), "●",
                     style     = label.style_none,
                     textcolor = color.new(C_BEAR, 20),
                     size      = size.small))
            if tsz >= i_min_tch
                int   bj = t_bars.get(tsz - 1)
                float yj = t_ys.get(tsz - 1)
                v_dots.push(label.new(bj, yj, "▼",
                     style     = label.style_label_down,
                     color     = color.new(C_SIGNAL, 20),
                     textcolor = color.white,
                     size      = size.small))

    // -- Support lines (swing lows) ------------------------------------------
    int n_lo = lo_p.size()
    if n_lo >= i_min_tch
        int drawn_sup = 0
        array<int> used_sup = array.new<int>()

        for a = n_lo - 1 to 0
            if drawn_sup >= i_max_tl
                break
            bool skip = false
            if used_sup.size() > 0
                for u = 0 to used_sup.size() - 1
                    if used_sup.get(u) == a
                        skip := true
                        break
            if skip
                continue

            int   ba = lo_b.get(a)
            float pa = lo_p.get(a)
            int   best_b   = -1
            int   best_tch = 0
            float best_sl  = 0.0

            for b = 0 to n_lo - 1
                if b == a
                    continue
                int   bb = lo_b.get(b)
                float pb = lo_p.get(b)
                if bb == ba
                    continue
                float sl = (pb - pa) / (bb - ba)
                if math.abs(sl) > atr_val * 0.5
                    continue
                int n = 0
                for j = 0 to n_lo - 1
                    float pj = pa + sl * (lo_b.get(j) - ba)
                    if math.abs(lo_p.get(j) - pj) <= tol
                        n += 1
                if n >= i_min_tch and n > best_tch
                    bool ok = true
                    for j = 0 to n_lo - 1
                        float pj = pa + sl * (lo_b.get(j) - ba)
                        if lo_p.get(j) < pj - tol
                            ok := false
                            break
                    if ok
                        best_tch := n
                        best_b   := b
                        best_sl  := sl

            if best_b < 0
                continue

            float sl = best_sl

            array<int>   t_bars = array.new<int>()
            array<float> t_ys   = array.new<float>()
            array<int>   t_idxs = array.new<int>()
            for j = 0 to n_lo - 1
                float pj = pa + sl * (lo_b.get(j) - ba)
                if math.abs(lo_p.get(j) - pj) <= tol
                    t_bars.push(lo_b.get(j))
                    t_ys.push(lo_p.get(j))
                    t_idxs.push(j)
            int tsz = t_bars.size()
            for i1 = 0 to tsz - 2
                for i2 = i1 + 1 to tsz - 1
                    if t_bars.get(i2) < t_bars.get(i1)
                        int   tmp_b = t_bars.get(i1)
                        float tmp_y = t_ys.get(i1)
                        int   tmp_i = t_idxs.get(i1)
                        t_bars.set(i1, t_bars.get(i2))
                        t_ys.set(i1, t_ys.get(i2))
                        t_idxs.set(i1, t_idxs.get(i2))
                        t_bars.set(i2, tmp_b)
                        t_ys.set(i2, tmp_y)
                        t_idxs.set(i2, tmp_i)

            // Min span filter
            if t_bars.get(tsz - 1) - t_bars.get(0) < i_min_span
                continue

            if math.abs(t_ys.get(tsz - 1) - close) > atr_val * 20
                continue

            // Reject if any bar between touches has a low below the line (breakout)
            bool s_clear = true
            int  s_s     = t_bars.get(0)
            int  s_e     = t_bars.get(tsz - 1)
            int  s_step  = math.max(1, (s_e - s_s) / 60)
            int  s_cb    = s_s
            for si = 0 to 60
                if s_cb > s_e
                    break
                if low[bar_index - s_cb] < pa + sl * (s_cb - ba) - tol
                    s_clear := false
                    break
                s_cb += s_step
            if not s_clear
                continue

            // Accept
            drawn_sup += 1
            for k = 0 to tsz - 1
                used_sup.push(t_idxs.get(k))
            tl_pa.push(pa)
            tl_ba.push(ba)
            tl_sl.push(sl)
            tl_res.push(false)
            tl_last_b.push(t_bars.get(tsz - 1))

            // Quality pivot confirmed as touch
            if t_bars.get(tsz - 1) >= bar_index - i_len and confirmed and trend_bull and regime_ok
                sigBull := true

            float y1_proj = pa + sl * (t_bars.get(0) - ba)
            float y2_proj = pa + sl * (t_bars.get(tsz - 1) - ba)
            bool  is_active = (drawn_sup == 1)
            color ln_clr    = is_active ? C_BULL : color.new(C_BULL, 55)
            int   ln_w      = is_active ? 2 : 1
            v_lines.push(line.new(t_bars.get(0), y1_proj,
                 t_bars.get(tsz - 1), y2_proj,
                 color = ln_clr, width = ln_w,
                 style = is_active ? line.style_solid : line.style_dashed))

            for j = 0 to tsz - 1
                v_dots.push(label.new(t_bars.get(j), t_ys.get(j), "●",
                     style     = label.style_none,
                     textcolor = color.new(C_BULL, 20),
                     size      = size.small))
            if tsz >= i_min_tch
                int   bj = t_bars.get(tsz - 1)
                float yj = t_ys.get(tsz - 1)
                v_dots.push(label.new(bj, yj, "▲",
                     style     = label.style_label_up,
                     color     = color.new(C_SIGNAL, 20),
                     textcolor = color.white,
                     size      = size.small))

    // -- Fast pivot check (i_sig_len delay - early detection path) -----------
    // Fires when a fast pivot touches an already-established quality trendline.
    if tl_pa.size() > 0 and regime_ok and confirmed
        int sg_n = sig_hi_b.size()
        if sg_n > 0 and sig_hi_b.get(sg_n - 1) >= bar_index - i_sig_len and trend_bear
            for i = 0 to tl_pa.size() - 1
                if tl_res.get(i) and not sigBear
                    float proj = tl_pa.get(i) + tl_sl.get(i) * (sig_hi_b.get(sg_n - 1) - tl_ba.get(i))
                    if math.abs(sig_hi_p.get(sg_n - 1) - proj) <= tol
                        sigBear := true

        int sl_n = sig_lo_b.size()
        if sl_n > 0 and sig_lo_b.get(sl_n - 1) >= bar_index - i_sig_len and trend_bull
            for i = 0 to tl_pa.size() - 1
                if not tl_res.get(i) and not sigBull
                    float proj = tl_pa.get(i) + tl_sl.get(i) * (sig_lo_b.get(sl_n - 1) - tl_ba.get(i))
                    if math.abs(sig_lo_p.get(sl_n - 1) - proj) <= tol
                        sigBull := true

//-----------------------------------------------------------------------------}
// Real-time Detection
//-----------------------------------------------------------------------------{
// Projects each trendline to current bar - fires when price enters tolerance band.
if tl_pa.size() > 0 and regime_ok
    for i = 0 to tl_pa.size() - 1
        float proj = tl_pa.get(i) + tl_sl.get(i) * (bar_index - tl_ba.get(i))
        if tl_res.get(i)
            if high >= proj - tol and high <= proj + tol and trend_bear
                sigBear := true
        else
            if low >= proj - tol and low <= proj + tol and trend_bull
                sigBull := true

if (sigBull or sigBear) and confirmed
    lastDir   := sigBull ? "Bull" : "Bear"
    lastGrade := i_grade ? f_grade(sigBull) : ""

//-----------------------------------------------------------------------------}
// Visuals
//-----------------------------------------------------------------------------{
barcolor(i_bar_clr and sigBull ? C_BULL : i_bar_clr and sigBear ? C_BEAR : na)
// EMA is a price-level moving average - does not create a separate scale in overlay mode
plot(i_show_ema ? ema200 : na, "200 EMA", color = color.new(C_NEUTRAL, 30), linewidth = 1)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
if barstate.islast and showDash
    string dash_p = switch i_dash_pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right
    var table dash = table.new(dash_p, 2, 4,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 2,
         frame_color  = C_DASH_BORDER,
         frame_width  = 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Trendline Bounce",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    string gTxt = lastGrade == "" ? "---" : (lastDir == "Bull" ? "▲ " : "▼ ") + lastGrade
    color  gClr = lastDir == "Bull" ? C_DASH_BULL : lastDir == "Bear" ? C_DASH_BEAR : C_NEUTRAL
    table.cell(dash, 0, 1, "Last Bounce",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, gTxt,
         text_color = gClr, text_size = size.small, text_halign = text.align_right)

    bool   ema_bull  = close > ema200
    string trendTxt  = ema_bull ? "▲ Bull" : "▼ Bear"
    color  trendClr  = ema_bull ? C_DASH_BULL : C_DASH_BEAR
    table.cell(dash, 0, 2, "Trend (200 EMA)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, trendTxt,
         text_color = trendClr, text_size = size.small, text_halign = text.align_right)

    int n_res = 0
    int n_sup = 0
    if tl_res.size() > 0
        for k = 0 to tl_res.size() - 1
            if tl_res.get(k)
                n_res += 1
            else
                n_sup += 1
    table.cell(dash, 0, 3, "Lines  R / S",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(n_res) + " / " + str.tostring(n_sup),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and showLgnd
    var table leg = table.new(position.bottom_left, 2, 7,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 1,
         frame_color  = C_DASH_BORDER,
         frame_width  = 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "━",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 1, "Support trendline",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 0, 2, "━",
         text_color = C_DASH_BEAR, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 2, "Resistance trendline",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 0, 3, "━",
         text_color = color.new(C_NEUTRAL, 30), text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 3, "200 EMA (trend)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 0, 4, "●",
         text_color = color.rgb(180, 180, 200), text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 4, "Touch point on trendline",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 0, 5, "▲▼",
         text_color = C_DASH_SIGNAL, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 1, 5, "Bounce at 3rd+ touch",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(leg, 0, 6, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(sigBull and confirmed, title = "Bullish Bounce",
     message = "Trendline Bounce [EXCAVO]: Bullish bounce on {{ticker}} ({{interval}})")
alertcondition(sigBear and confirmed, title = "Bearish Bounce",
     message = "Trendline Bounce [EXCAVO]: Bearish bounce on {{ticker}} ({{interval}})")
alertcondition((sigBull or sigBear) and confirmed, title = "Any Bounce",
     message = "Trendline Bounce [EXCAVO]: Trendline bounce on {{ticker}} ({{interval}})")

if i_json and barstate.isconfirmed
    string _t  = syminfo.ticker
    string _p  = str.tostring(close, format.mintick)
    string _tf = timeframe.period
    if sigBull
        string _j = '{"action":"bounce","direction":"bullish","grade":"' + lastGrade + '",'
        _j := _j + '"ticker":"' + _t + '","price":' + _p + ','
        _j := _j + '"timeframe":"' + _tf + '",'
        _j := _j + '"indicator":"EXCAVO_Trendline_Bounce"}'
        alert(_j, alert.freq_once_per_bar)
    if sigBear
        string _j = '{"action":"bounce","direction":"bearish","grade":"' + lastGrade + '",'
        _j := _j + '"ticker":"' + _t + '","price":' + _p + ','
        _j := _j + '"timeframe":"' + _tf + '",'
        _j := _j + '"indicator":"EXCAVO_Trendline_Bounce"}'
        alert(_j, alert.freq_once_per_bar)
````
