# Fair Value Gap Fill Probability [PickMyTrade]

- url: https://www.tradingview.com/script/cP0fYaeZ-Fair-Value-Gap-Fill-Probability-PickMyTrade/
- type: indicator
- pine_id: PUB;fcfd94e7240a4b30b86c3826245d11a0
- version: 1.0

## Description

[b]Fair Value Gap Fill Probability[/b] applies a Gaussian Naive Bayes classifier — trained entirely within Pine Script® v6 — to every Fair Value Gap it detects, in order to estimate the posterior probability that each gap will be filled before it expires. Instead of treating all FVGs as equal, it asks a different question: [i]given this gap's order-flow signature, geometry, and the time price has already spent nearby, how likely is it to actually fill?[/i]

――――――――――――――――――――――――――――――――――――――

🔷 [b]WHAT IT MEASURES[/b]

🔸 [b]Fair Value Gaps[/b]

A Fair Value Gap is the three-candle imbalance where an impulsive move leaves a price range untraded. A [b]bullish FVG[/b] forms when the high of two bars ago sits below the current low; a [b]bearish FVG[/b] forms when the low of two bars ago sits above the current high. Each gap is detected only on confirmed bar closes and is filtered by a minimum size relative to ATR, so noise gaps are ignored.

🔸 [b]Three classifier features[/b]

When a gap forms, the classifier records three z-score normalised features that describe its context:

[b]F1 — CVD Momentum[/b]: the rate of change of Cumulative Volume Delta at the moment the gap is created, normalised by its rolling mean and standard deviation. This encodes whether aggressive order flow was accelerating or fading as the imbalance formed.

[b]F2 — Gap Geometry[/b]: the size of the gap expressed as a multiple of ATR. Larger relative gaps behave differently from small ones, and this feature lets the model separate the two.

[b]F3 — Time-at-Price[/b]: the fraction of recent bars whose close fell inside the gap's price band. A zone the market has already revisited carries different fill odds than fresh, untested space.

🔸 [b]Fill vs no-fill outcomes[/b]

Every gap is followed until one of two things happens: price trades to the gap's midpoint (a [b]fill[/b]), or the gap survives past the expiry window untouched (a [b]no-fill[/b]). Each resolved gap becomes a labelled training example, so the model learns continuously from the chart's own history.

――――――――――――――――――――――――――――――――――――――

🔷 [b]THE CLASSIFIER[/b]

🔸 [b]Welford online learning[/b]

Rather than storing arrays of past gaps, the classifier keeps running sufficient statistics — count, mean and variance — for each (feature × outcome) pair using Welford's numerically stable online update. Parameters shift gradually as market conditions change, with no fixed lookback buffer.

🔸 [b]Gaussian likelihood + Bayesian posterior[/b]

Each feature is modelled as a Gaussian distribution under both the fill and no-fill classes. The three per-feature likelihoods are multiplied under the Naive Bayes independence assumption, combined with an empirically updated class prior, and normalised via Bayes' theorem to produce [b]P(fill | F1, F2, F3)[/b] for the live gap. A warmup gate suppresses probabilities until enough fill and no-fill samples have accumulated, at which point the info table switches to LIVE.

――――――――――――――――――――――――――――――――――――――

🔷 [b]SIGNALS AND DISPLAY[/b]

🔸 [b]Probability-shaded zones[/b]

Each active FVG is drawn as a translucent zone with a crisp coloured border — blue for bullish, orange for bearish. The fill intensity scales with the posterior across three tiers, so a high-conviction gap reads instantly against a faint, low-probability one. Filled gaps turn grey so mitigation is obvious.

🔸 [b]Live probability labels[/b]

Every open gap carries a running "[b]X% fill[/b]" label that updates each bar as the classifier re-evaluates it. When a gap clears the high-probability threshold, a bold callout ("[b]Bullish FVG · 81% fill prob[/b]") marks it directly on the chart.

🔸 [b]Info table[/b]

The corner table reports the live state — fill samples, no-fill samples, active gaps, CVD flow direction, and a LIVE / WARMUP status flag so you always know whether the model has enough data to be trusted.

――――――――――――――――――――――――――――――――――――――

🔷 [b]INPUTS[/b]

[b]ATR Period[/b] — basis for the minimum gap-size filter.
[b]Min Gap Size (ATR ×)[/b] — gaps smaller than this multiple of ATR are ignored.
[b]Max Active FVGs[/b] — cap on simultaneously tracked gaps.
[b]Expire after N bars[/b] — unfilled gaps retire as no-fill samples after this many bars.
[b]CVD Momentum Period[/b] — lookback for feature F1.
[b]Z-Score Window[/b] — normalisation window for all three features.
[b]Warmup Samples Per Class[/b] — minimum fill and no-fill samples before probabilities display.
[b]High-Prob Threshold[/b] — posterior level that marks a gap as high-conviction.

――――――――――――――――――――――――――――――――――――――

🔷 [b]REQUIREMENTS AND LIMITATIONS[/b]

The classifier requires a warmup period before probabilities are valid; on instruments with little history the table will read WARMUP until enough gaps have resolved. The CVD estimator is synthetic — derived from intrabar price position, not true bid/ask data — and is noisier on illiquid symbols. Because all three features are CVD- and geometry-derived, the Naive Bayes independence assumption is only approximately satisfied, so the posteriors are best read as relative confidence scores rather than calibrated frequentist probabilities. Fill rates are also regime- and timeframe-dependent and are historically associated with, not predictive of, future behaviour.

――――――――――――――――――――――――――――――――――――――

[i]Built natively in Pine Script® v6. No external libraries, no data feeds, no fixed lookback arrays. The Gaussian Naive Bayes classifier trains continuously from the chart's own gap history using Welford's online algorithm. Open source — Mozilla Public License 2.0.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © PickMyTrade — Fair Value Gap Fill Probability [PickMyTrade]
// Novel question: Not all FVGs fill — which ones are statistically most likely to,
// based on CVD order flow signature + gap geometry + time-at-price density?
// Gaussian Naive Bayes with Welford online learning. Non-repainting.

//@version=6
indicator("Fair Value Gap Fill Probability [PickMyTrade]", "FVG FP [PMT]",
         overlay=true, max_boxes_count=200, max_labels_count=200)

// ── Input Groups ──────────────────────────────────────────────────────────────
var string G_FVG  = "FVG Detection"
var string G_CVD  = "CVD Settings"
var string G_PROB = "Probability Engine"
var string G_VIS  = "Visual"
var string G_ZEN  = "Display"

// FVG Detection
i_atr_len = input.int  (14,   "ATR Period",              group=G_FVG, minval=5,
    tooltip="ATR period used for the minimum gap size filter.")
i_min_gap = input.float(0.2,  "Min Gap Size (ATR x)",    group=G_FVG, minval=0.0, step=0.05,
    tooltip="Gaps smaller than this multiple of ATR are ignored. 0 = show all.")
i_max_fvg = input.int  (30,   "Max Active FVGs",         group=G_FVG, minval=5, maxval=100,
    tooltip="Oldest unmitigated FVG is removed when this limit is reached.")
i_expire  = input.int  (60,   "Expire after N bars",     group=G_FVG, minval=10, maxval=500,
    tooltip="Unfilled FVGs are retired after this many bars and used as no-fill training samples.")

// CVD Settings
i_cvd_roc = input.int(10, "CVD Momentum Period", group=G_CVD, minval=3, maxval=100,
    tooltip="Lookback for CVD rate-of-change — feature F1: order flow momentum at gap creation.")
i_zsc_len = input.int(50, "Z-Score Window",      group=G_CVD, minval=20, maxval=300,
    tooltip="Rolling window for normalising all three features to zero mean and unit variance.")

// Probability Engine
i_warmup = input.int  (80,   "Warmup Samples Per Class", group=G_PROB, minval=20, maxval=500,
    tooltip="Minimum fill AND no-fill samples before posterior probabilities are shown. Labels read 'warmup' until ready.")
i_thresh = input.float(0.65, "High-Prob Threshold",      group=G_PROB, minval=0.50, maxval=0.99, step=0.01,
    tooltip="Posterior at or above this level marks the FVG as a high-conviction fill candidate.")

// Visual
bull_col    = input.color(color.new(#2962FF, 0), "Bull Colour",   group=G_VIS)
bear_col    = input.color(color.new(#FF6D00, 0), "Bear Colour",   group=G_VIS)
i_fill_col  = input.color(color.new(color.gray, 80), "Filled FVG", group=G_VIS,
    tooltip="Color applied when an FVG is mitigated (price re-entered the zone).")

// Display
i_show_lbl  = input.bool(true,  "Show Probability Labels", group=G_ZEN,
    tooltip="Display P=X% on each active FVG box.")
i_show_sig  = input.bool(true,  "Show High-Prob Signals",  group=G_ZEN,
    tooltip="Show a signal label at high-conviction FVGs once the classifier is live.")
show_table  = input.bool(true,  "Show Info Table",         group=G_ZEN)

// ── User-Defined Type ─────────────────────────────────────────────────────────
type FvgZone
    int   formed
    float top
    float bot
    bool  is_bull
    float prob
    float f1
    float f2
    float f3
    box   bx
    label lbl
    label sig

// ── Naive Bayes Accumulators ──────────────────────────────────────────────────
// Layout: index = (class * 3) + feature   class 0 = FILL   class 1 = NO-FILL
var float[] nb_n   = array.new_float(6, 1.0)
var float[] nb_sum = array.new_float(6, 0.0)
var float[] nb_ss  = array.new_float(6, 1.0)
var int[]   nb_cls = array.new_int(2, 0)

nb_upd(int cls, int fi, float v) =>
    int i = cls * 3 + fi
    array.set(nb_n,   i, array.get(nb_n,   i) + 1.0)
    array.set(nb_sum, i, array.get(nb_sum, i) + v)
    array.set(nb_ss,  i, array.get(nb_ss,  i) + v * v)

nb_train(int cls, float f1, float f2, float f3) =>
    nb_upd(cls, 0, f1)
    nb_upd(cls, 1, f2)
    nb_upd(cls, 2, f3)
    array.set(nb_cls, cls, array.get(nb_cls, cls) + 1)

gauss_pdf(float x, float mu, float sig) =>
    float s = math.max(sig, 1e-9)
    float d = (x - mu) / s
    math.exp(-0.5 * d * d) / (s * 2.5066283)

nb_posterior(float f1, float f2, float f3) =>
    int nc0 = array.get(nb_cls, 0)
    int nc1 = array.get(nb_cls, 1)
    float result = float(na)
    if nc0 >= i_warmup and nc1 >= i_warmup
        float ntot   = float(nc0 + nc1)
        float prior0 = float(nc0) / ntot
        float prior1 = float(nc1) / ntot
        float like0  = 1.0
        float like1  = 1.0
        for fi = 0 to 2
            float v  = fi == 0 ? f1 : fi == 1 ? f2 : f3
            int   i0 = fi
            int   i1 = 3 + fi
            float n0 = array.get(nb_n, i0)
            float n1 = array.get(nb_n, i1)
            float m0 = n0 > 0.0 ? array.get(nb_sum, i0) / n0 : 0.0
            float m1 = n1 > 0.0 ? array.get(nb_sum, i1) / n1 : 0.0
            float ss0 = array.get(nb_ss, i0)
            float ss1 = array.get(nb_ss, i1)
            float v0 = n0 > 1.0 ? math.max((ss0 - n0 * m0 * m0) / (n0 - 1.0), 1e-9) : 1.0
            float v1 = n1 > 1.0 ? math.max((ss1 - n1 * m1 * m1) / (n1 - 1.0), 1e-9) : 1.0
            like0 *= gauss_pdf(v, m0, math.sqrt(v0))
            like1 *= gauss_pdf(v, m1, math.sqrt(v1))
        float j0  = like0 * prior0
        float j1  = like1 * prior1
        float den = j0 + j1
        result    := den > 1e-20 ? j0 / den : 0.5
    result

// ── CVD and Features ──────────────────────────────────────────────────────────
float bvol  = high != low ? volume * (close - low) / (high - low) : volume * 0.5
float delta = 2.0 * bvol - volume
var float cvd = 0.0
cvd += delta

float cvd_roc = ta.change(cvd, i_cvd_roc)
float roc_mu  = ta.sma  (cvd_roc, i_zsc_len)
float roc_sd  = ta.stdev(cvd_roc, i_zsc_len)
float F1_cur  = roc_sd > 1e-9 ? (cvd_roc - roc_mu) / roc_sd : 0.0
float atr_v   = ta.atr(i_atr_len)

f_tap(float top_p, float bot_p) =>
    int cnt = 0
    int lk  = math.min(bar_index, 30)
    if lk > 0
        for j = 1 to lk
            if close[j] >= bot_p and close[j] <= top_p
                cnt += 1
    lk > 0 ? float(cnt) / float(lk) : 0.0

// ── Colour helpers (IOF-style translucent fill + crisp border) ────────────────
// Fill is intentionally translucent (like the IOF posterior band) so candles show
// through. Border stays crisp so the zone edge is always clear.
fvg_fill(bool is_bull, float p) =>
    color base = is_bull ? bull_col : bear_col
    p >= i_thresh + 0.10 ? color.new(base, 72) : p >= i_thresh ? color.new(base, 83) : color.new(base, 90)

fvg_border(bool is_bull, float p) =>
    color base = is_bull ? bull_col : bear_col
    p >= i_thresh + 0.10 ? color.new(base, 0) : p >= i_thresh ? color.new(base, 30) : color.new(base, 62)

fvg_lbl_col(bool is_bull, float p) =>
    color base = is_bull ? bull_col : bear_col
    p >= i_thresh ? color.new(base, 0) : color.new(color.gray, 30)

// Human-readable fill-probability text for labels
fvg_txt(bool is_bull, float p, bool warm) =>
    string dir = is_bull ? "Bullish FVG" : "Bearish FVG"
    warm ? "FVG · warming up" : dir + " · " + str.tostring(math.round(p * 100)) + "% fill prob"

// ── Active FVG Array ──────────────────────────────────────────────────────────
var FvgZone[] zones = array.new<FvgZone>()

// ── STEP 1 — Update zones every bar ──────────────────────────────────────────
int sz = array.size(zones)
if sz > 0
    for idx = sz - 1 to 0
        FvgZone z    = array.get(zones, idx)
        int  age     = bar_index - z.formed
        bool touched = age >= 1 and low <= z.top and high >= z.bot

        if touched
            nb_train(0, z.f1, z.f2, z.f3)
            box.set_bgcolor      (z.bx, i_fill_col)
            box.set_border_color (z.bx, color.new(color.gray, 55))
            box.set_right        (z.bx, bar_index)
            label.delete(z.lbl)
            label.delete(z.sig)
            array.remove(zones, idx)

        else if age >= i_expire
            nb_train(1, z.f1, z.f2, z.f3)
            box.set_right(z.bx, bar_index)
            label.delete (z.lbl)
            label.delete (z.sig)
            array.remove (zones, idx)

        else
            float p_live = nb_posterior(z.f1, z.f2, z.f3)
            if not na(p_live)
                z.prob := p_live
                box.set_bgcolor      (z.bx, fvg_fill  (z.is_bull, p_live))
                box.set_border_color (z.bx, fvg_border(z.is_bull, p_live))
                if i_show_lbl and not na(z.lbl)
                    label.set_x        (z.lbl, bar_index)
                    label.set_text     (z.lbl, str.tostring(math.round(p_live * 100)) + "% fill")
                    label.set_textcolor(z.lbl, fvg_lbl_col(z.is_bull, p_live))
            int rem = i_expire - age
            box.set_right(z.bx, bar_index + math.max(1, rem))

// ── STEP 2 — Detect new FVGs on confirmed close ───────────────────────────────
if barstate.isconfirmed and atr_v > 0

    // Bullish FVG — gap between high[2] and low[0]
    if high[2] < low and (low - high[2]) >= i_min_gap * atr_v
        float t_val = low
        float b_val = high[2]
        float F2    = (t_val - b_val) / atr_v
        float F3    = f_tap(t_val, b_val)
        float p_ini = nb_posterior(F1_cur, F2, F3)
        float p_use = na(p_ini) ? 0.5 : p_ini
        bool  hi_p  = not na(p_ini) and p_use >= i_thresh
        string lstr = na(p_ini) ? "warming up" : str.tostring(math.round(p_use * 100)) + "% fill"
        box   bx_n  = box.new(bar_index - 2, t_val, bar_index + i_expire, b_val,
                              border_color=fvg_border(true, p_use), border_width=1,
                              bgcolor=fvg_fill(true, p_use))
        label lb_n  = i_show_lbl ? label.new(bar_index, t_val, lstr,
                              color=color.new(color.black, 70),
                              textcolor=fvg_lbl_col(true, p_use),
                              style=label.style_label_lower_right, size=size.small) : label(na)
        label sg_n  = i_show_sig and hi_p ? label.new(bar_index - 1, b_val,
                              fvg_txt(true, p_use, false),
                              color=color.new(bull_col, 15),
                              textcolor=color.new(color.white, 0),
                              style=label.style_label_up, size=size.normal) : label(na)
        array.push(zones, FvgZone.new(bar_index - 2, t_val, b_val, true,  p_use, F1_cur, F2, F3, bx_n, lb_n, sg_n))

    // Bearish FVG — gap between high[0] and low[2]
    if low[2] > high and (low[2] - high) >= i_min_gap * atr_v
        float t_val = low[2]
        float b_val = high
        float F2    = (t_val - b_val) / atr_v
        float F3    = f_tap(t_val, b_val)
        float p_ini = nb_posterior(F1_cur, F2, F3)
        float p_use = na(p_ini) ? 0.5 : p_ini
        bool  hi_p  = not na(p_ini) and p_use >= i_thresh
        string lstr = na(p_ini) ? "warming up" : str.tostring(math.round(p_use * 100)) + "% fill"
        box   bx_n  = box.new(bar_index - 2, t_val, bar_index + i_expire, b_val,
                              border_color=fvg_border(false, p_use), border_width=1,
                              bgcolor=fvg_fill(false, p_use))
        label lb_n  = i_show_lbl ? label.new(bar_index, t_val, lstr,
                              color=color.new(color.black, 70),
                              textcolor=fvg_lbl_col(false, p_use),
                              style=label.style_label_lower_right, size=size.small) : label(na)
        label sg_n  = i_show_sig and hi_p ? label.new(bar_index - 1, t_val,
                              fvg_txt(false, p_use, false),
                              color=color.new(bear_col, 15),
                              textcolor=color.new(color.white, 0),
                              style=label.style_label_down, size=size.normal) : label(na)
        array.push(zones, FvgZone.new(bar_index - 2, t_val, b_val, false, p_use, F1_cur, F2, F3, bx_n, lb_n, sg_n))

    while array.size(zones) > i_max_fvg
        FvgZone old = array.shift(zones)
        box.delete  (old.bx)
        label.delete(old.lbl)
        label.delete(old.sig)

// ── Info Table (IOF style) ────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 6,
    bgcolor      = color.new(color.black, 75),
    border_color = color.new(color.gray,  60),
    border_width = 1,
    frame_color  = color.new(color.gray,  50),
    frame_width  = 1)

if barstate.islast and show_table
    int  fc  = array.get(nb_cls, 0)
    int  nfc = array.get(nb_cls, 1)
    bool rdy = fc >= i_warmup and nfc >= i_warmup
    int  act = array.size(zones)
    color txt_hdr = color.new(color.gray,  0)
    color txt_wht = color.new(color.white, 0)

    table.cell(tbl, 0, 0, "FVG Fill Prob",
        text_color=txt_hdr, text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, rdy ? "● LIVE" : "● WARMUP",
        text_color=rdy ? color.new(color.lime, 0) : color.new(color.yellow, 0),
        text_size=size.small, bgcolor=color.new(color.black, 60))

    table.cell(tbl, 0, 1, "Fill samples",   text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(fc),
        text_color=color.new(bull_col, 0), text_size=size.small)

    table.cell(tbl, 0, 2, "No-fill samples", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(nfc),
        text_color=color.new(bear_col, 0), text_size=size.small)

    table.cell(tbl, 0, 3, "Active FVGs",    text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(act),
        text_color=color.new(color.white, 0), text_size=size.small)

    table.cell(tbl, 0, 4, "CVD Flow",       text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 4, F1_cur >= 0 ? "▲ Buy" : "▼ Sell",
        text_color=F1_cur >= 0 ? color.new(color.lime, 0) : color.new(bear_col, 0),
        text_size=size.small)

    table.cell(tbl, 0, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(tbl, 1, 5, "─────", text_color=color.new(color.gray, 60), text_size=size.tiny)

// ── Alerts ────────────────────────────────────────────────────────────────────
bool alert_bull = false
bool alert_bear = false

if barstate.isconfirmed and atr_v > 0
    if high[2] < low and (low - high[2]) >= i_min_gap * atr_v
        float pa = nb_posterior(F1_cur, (low - high[2]) / atr_v, f_tap(low, high[2]))
        alert_bull := not na(pa) and pa >= i_thresh
    if low[2] > high and (low[2] - high) >= i_min_gap * atr_v
        float pb = nb_posterior(F1_cur, (low[2] - high) / atr_v, f_tap(low[2], high))
        alert_bear := not na(pb) and pb >= i_thresh

alertcondition(alert_bull, "High-Prob Bullish FVG",
               "Bullish Fair Value Gap with posterior fill probability at or above threshold.")
alertcondition(alert_bear, "High-Prob Bearish FVG",
               "Bearish Fair Value Gap with posterior fill probability at or above threshold.")
````
