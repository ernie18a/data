# Smart Ichimoku | GainzAlgo

- url: https://www.tradingview.com/script/F7vanoEc-Smart-Ichimoku-GainzAlgo/
- type: indicator
- pine_id: PUB;4e5c42ebe9794af9b2cbdfbcad8c3c09
- version: 1.0

## Description

[b]Overview[/b]

Most Ichimoku indicators give you the same signal everyone else gets,  a raw cloud cross with no filter, no context, and no target. This indicator rethinks the system from the ground up by combining a smoothed Ichimoku cloud with an inline logistic regression classifier that scores every cloud break in real time, then projects statistically-derived price targets the moment a confirmed signal fires.

The result is a cleaner, higher conviction version of one of the most respected trend frameworks in technical analysis.


[b]The Foundation: Why Smooth the Ichimoku?[/b]

Traditional Ichimoku uses simple high-low midpoints (Donchian midlines) for its Tenkan, Kijun, and Senkou components. This makes the cloud visually choppy and prone to false crosses on noisy, volatile instruments like crypto or high-beta equities.

This indicator replaces all three components with Hull Moving Averages (HMA), which are designed to be simultaneously smooth and responsive, reducing lag without the whipsaw of standard smoothing. The cloud body itself becomes cleaner, the baseline is less noisy, and the cross events that trigger signals are more structurally meaningful.

All default periods match classic Ichimoku settings (9 / 26 / 52 / 26 displacement) so the logic stays true to the original system, it's just rendered with better math underneath.

[b]The Signal: Logistic Regression Cloud Break Classifier[/b]

Here's where this indicator separates itself. A cloud cross alone is not a signal, it's a candidate. What actually matters is whether the market conditions at the moment of the cross are consistent with a real, sustained breakout or breakdown.

The classifier answers that question with a probability score.

[b]How it works[/b]

At the exact bar where price exits the cloud body, four normalized features are computed and fed into a logistic regression model:

[*]1. RSI (centered at 50, scaled by 25)[/i]
Measures momentum. On a bearish break, is RSI already extended to the downside? On a bullish break, is it pointing up? RSI near 50 adds little conviction; RSI at 30 on a bear break adds a lot.

[*]2. Stochastic Oscillator (centered at 50, scaled by 25)[/i]
Short-term overbought/oversold confirmation. Works similarly to RSI but captures faster-cycle momentum, giving the model a second read on the same question.

[*]3. Z-Score (price vs 20-bar mean, normalized by standard deviation)[/i]
Measures how statistically extended price is relative to recent history. A cloud break accompanied by a Z-Score of -2 is much more meaningful than one at Z = -0.2. This feature effectively asks: "Is this break happening from an already-stretched position?"

[*]4. Cloud Break Depth (normalized by ATR)[/i]
How far did price close through the cloud boundary, relative to recent volatility? A close that barely clips the edge is very different from one that punches through by a full ATR. This is the most direct measure of breakout conviction.

[b]The Math[/b]

Each feature is multiplied by a weight and summed into a single score (z). That score is passed through the sigmoid function:

[quote]P = 1 / (1 + e^(-z)) [/quote]


This compresses the output to a probability between 0 and 1. If the probability clears the threshold (default 0.60), the break is confirmed and a signal fires. Below threshold, the cross is rejected — instead of being ignored, it's labeled with a risk tier so you can see exactly how close (or far) it came to confirming.

The probability score is displayed as a small percentage label directly on the signal bar so you always know how strong the classifier rated that particular break.

[b]Self-Calibrating Weights — No Manual Tuning[/b]

Unlike a typical multi-feature model, none of the four weights are set by hand. Each one is derived automatically from that feature's own rolling correlation with next-bar returns, recalculated continuously over a user-set lookback window (the "Self-Calibration Window," default 100 bars).

In practice this means: if RSI has been a genuinely useful predictor of direction on this instrument and timeframe recently, its weight rises on its own. If Z-Score has been mostly noise in the current regime, its weight shrinks toward zero — automatically, without anyone touching a slider.

This was a deliberate design choice. Letting people hand-tune regression weights invites a lot of well-intentioned guesswork that usually overfits to a handful of recent candles. By having the model score its own features based on demonstrated, rolling predictive power, the classifier adapts to changing market conditions instead of running on opinions baked in at setup time.

[b]Rejected Crosses: Risk-Tiered Labels[/b]

Not every cloud cross clears the threshold, and that's the point. Rather than silently discarding rejected crosses, this indicator labels every one of them with a risk tier so you know exactly what the model saw and how close it came to confirming:

[list]
[*]Low Risk: Probability fell just short of the threshold (within 10 points below). A near-miss — the break had real conviction behind it, it simply didn't clear the bar.
[*]Moderate Risk: Probability landed meaningfully below threshold (10–25 points). A weaker break with mixed signals underneath it.
[*]High Risk: Probability came in far below threshold (25+ points). A break with little to no underlying conviction — most consistent with chop or noise.
[/list]

Each label shows its tier and the actual probability (e.g. "Low Risk ▼ 54%"), so nothing is a black box. A cluster of Low/Moderate Risk labels in one zone often signals a contested area that's likely to resolve into a real breakout once it's worked through — useful context even though no trade signal fired. These labels can be toggled off entirely in settings if you'd rather only see confirmed signals.


[b]The Targets: Mean, Median, Mode[/b]

Once a confirmed break fires, three dashed horizontal target lines project from the signal bar. These are not arbitrary multiples, they are derived from the actual statistical distribution of bar-to-bar price moves over the lookback window.

[list]
[*]Mean (Yellow):  The average absolute bar move over the lookback period, scaled by the target multiplier. This is the "expected" target under normal conditions.
[*]Median (Cyan): The 50th percentile of historical moves. Because move distributions are right-skewed (a few large moves pull the mean up), the median is typically more conservative than the mean and often a more realistic first target.
[*]Mode (Hot Pink): The most frequently occurring move size, derived by bucketing historical moves into ATR-width bins and finding the most populated bin. This represents what the market most commonly does — not what it averages, not the middle value, but the single most likely outcome based on observed frequency.
[/list]

Together, the three targets give you a realistic range rather than a single arbitrary level — grounded in what this instrument has actually done over the recent past. Bull and bear target sets are tracked independently, so a new bearish break won't erase an active bullish target set still in play, and vice versa.

The Target Multiplier (default 3×) scales all three targets proportionally. Lower it for tighter, shorter-term targets; raise it for swing trades or higher-volatility instruments.

[b]Reading the Chart[/b]

[list=1]
[*] Green triangle (▲) below bar: Confirmed bullish cloud break. Price has exited the top of the cloud with sufficient classifier probability. Three upward target lines appear.
[*] Pink triangle (▼) above bar: Confirmed bearish cloud break. Price has exited the bottom of the cloud with sufficient classifier probability. Three downward target lines appear.
[*] Percentage label: The LR probability score for that break (e.g. "73%"). Higher is stronger.
[*] Risk-tiered label (amber/orange/red): A cloud cross that was rejected, with its tier and probability shown.
[*] Yellow dashed line: Mean target
[*] Cyan dashed line: Median target
[*] Hot pink dashed line: Mode target (thicker, as it represents the highest-frequency outcome)
[/list]

[b]Settings Guide[/b]

[i]Smooth Ichimoku[/i]

Tenkan / Kijun / Senkou Period: Standard Ichimoku periods. Default 9/26/52 follows the classic system. Shorter periods = more sensitive, more signals. Longer = slower, fewer but stronger signals.

Displacement: How far forward the cloud is projected. Default 26.

[i]Break Classifier[/i]

Self-Calibration Window: How many past bars the model uses to learn each feature's weight from its recent correlation with price moves. Shorter windows adapt faster to regime changes but can be noisier; longer windows are more stable but slower to react. Default 100.

Break Probability Threshold: The minimum probability required to confirm a signal. Default 0.60. Raise toward 0.75+ for fewer, higher-conviction signals. Lower toward 0.50 to see more cloud breaks confirmed (effectively turns the filter off at 0.50).


[i]Targets[/i]

Lookback (bars):  How many bars of historical move data to use for the distribution calculation. Default 60. Longer lookback = more stable targets based on longer-term behavior. Shorter = more reactive to recent volatility.

Target Multiplier: Scales all three target lines proportionally from the signal close. Default 3×. Adjust based on your timeframe and typical holding period.

[i]Risk Labels[/i]

Show Risk Labels on Rejected Crosses: Toggles the Low/Moderate/High Risk labels on rejected cloud crosses. Off by default for a cleaner chart; turn on to see every cross the model evaluated, not just the confirmed ones.

[b]How to Use It[/b]

[list=1]
[*] As a trend confirmation tool: Use the cloud direction (cyan dominant = bullish structure, pink dominant = bearish) as your bias filter, and only trade signals that align with the cloud color. Bull signals below a cyan cloud, bear signals above a pink cloud.
[*] As a breakout entry trigger: Wait for price to consolidate inside or near the cloud, then take the confirmed break as an entry signal. The probability label tells you how much conviction the model has at that moment.
[*] Using rejected crosses as context: A string of Low Risk labels in a zone suggests the cloud is being tested seriously without quite breaking — often a precursor to a real move once the level finally gives.
[*] For target setting: Use the median as a conservative first target, the mean as a mid-range objective, and the mode as a guide to where the most "normal" move tends to land. The hot pink mode line is often the most useful for setting realistic profit expectations.
[*] For alerts — Four alert conditions are built in: "Confirmed Bull Break," "Confirmed Bear Break," "Rejected Bull Cross," and "Rejected Bear Cross." Set them on your preferred timeframe and let the classifier notify you rather than watching the chart.
[/list]

Timeframe Notes

This indicator works across all timeframes but behaves differently depending on context:

[list]
[*] 1H–4H: Good balance of signal frequency and reliability. Recommended starting point.
[*] Daily: Fewer signals, higher structural significance. Best for swing traders.
[*] 15m and below: More signals, more noise. Consider raising the threshold to 0.65–0.70 and reducing the lookback to 30. Watch the risk-tiered labels here in particular — they're most useful for filtering chop on fast timeframes.
[/list]

Example on the Daily with SPY ETF: 
https://www.tradingview.com/x/RsucrT3b/

Example on the 4 Hour with BTCUSD; 
https://www.tradingview.com/x/s21KgDHh/

Example on the 15 Minute with QQQ:
https://www.tradingview.com/x/1lhnaxlL/


[b]A Note on the Model[/b]

The logistic regression here is not trained on historical data in the machine learning sense, and it no longer relies on manually-set weights either. Each feature's weight is derived from its own rolling correlation with subsequent price action, recalculated continuously. Think of it less as a black-box ML model and more as a structured, self-adjusting way to combine four momentum and positioning indicators into a single probability score, similar to our [url=https://www.tradingview.com/script/fDfndNzN-Directional-Logistic-Oscillator-GainzAlgo/]Directional Logistic Oscillator.[/url]

The advantage over a traditional multi-condition filter (RSI < 40 AND stoch < 30 AND...) is that the sigmoid function produces a continuous probability rather than a binary pass/fail, which means the model degrades gracefully, a break with three strong features and one neutral one still scores well, rather than getting blocked by an arbitrary threshold on the weak feature. And because every rejected cross is shown with its tier and score rather than discarded silently, nothing the model does is hidden from you.

We hope you enjoy!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GainzAlgo
 //    │    │     │     │   ██████╗  █████╗ ██╗███╗   ██╗███████╗
 //   ┌┴┐   │    ┌┴┐    │  ██╔════╝ ██╔══██╗██║████╗  ██║╚══███╔╝
 //   │ │   │    │ │    │  ██║  ███╗███████║██║██╔██╗ ██║  ███╔╝ 
 //   └┬┘  ┌┴┐   └┬┘   ┌┴┐ ██║   ██║██╔══██║██║██║╚██╗██║ ███╔╝  
 //    │   │ │    │    │ | ██████╔╝██║  ██║██║██║ ╚████║███████╗
 //    │   └┬┘         └┬┘  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝
 //         │           │  
 //                            █████╗ ██╗      ██████╗  ██████╗         
 //                           ██╔══██╗██║     ██╔════╝ ██╔═══██╗        
 //                           ███████║██║     ██║  ███╗██║   ██║        
 //                           ██╔══██║██║     ██║   ██║██║   ██║        
 //                           ██║  ██║███████╗╚██████╔╝╚██████╔╝        
 //                           ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝    
//@version=6
indicator("Smart Ichimoku | GainzAlgo", overlay=true, max_lines_count=500, max_labels_count=500)

// UI
grp_ichi   = "Smooth Ichimoku"
len_tenkan = input.int(9,  "Tenkan Period", group=grp_ichi)
len_kijun  = input.int(26, "Kijun Period",  group=grp_ichi)
len_senkou = input.int(52, "Senkou Period", group=grp_ichi)
disp       = input.int(26, "Displacement",  group=grp_ichi)

grp_ml    = "Break Classifier"
calib_len = input.int(100, "Self-Calibration Window (bars)", group=grp_ml, minval=20, maxval=300, tooltip="Weights are learned from each feature's recent predictive power instead of being set by hand.")
threshold = input.float(0.60, "Break Probability Threshold", group=grp_ml, minval=0.5, maxval=1.0)

grp_tp      = "Targets"
tp_lookback = input.int(60,    "Lookback (bars)",   group=grp_tp, minval=10, maxval=200)
tp_scale    = input.float(3.0, "Target Multiplier", group=grp_tp, minval=0.5, maxval=10.0)

grp_disp  = "Display"
show_tbl  = input.bool(true, "Show Stats Table",       group=grp_disp)
bt_window = input.int(100,   "Backtest Window (bars)", group=grp_disp, minval=20, maxval=500)

// Cloud logic
tenkan  = ta.hma(hl2, len_tenkan)
kijun   = ta.hma(hl2, len_kijun)
senkouA = ta.hma((tenkan + kijun) / 2, len_kijun)
senkouB = ta.hma(hl2, len_senkou)

cloud_top = math.max(senkouA[disp], senkouB[disp])
cloud_bot = math.min(senkouA[disp], senkouB[disp])

cross_below = close < cloud_bot and close[1] >= cloud_bot[1]
cross_above = close > cloud_top and close[1] <= cloud_top[1]
any_cross   = cross_below or cross_above

// Features for the log reg
atr         = ta.atr(14)
f_rsi       = (ta.rsi(close, 14) - 50.0) / 25.0
f_stoch     = (ta.stoch(close, high, low, 14) - 50.0) / 25.0
f_zscore    = ta.stdev(close, 20) == 0 ? 0.0 : (close - ta.sma(close, 20)) / ta.stdev(close, 20)
f_dist_bear = atr == 0 ? 0.0 : (cloud_bot - close) / atr
f_dist_bull = atr == 0 ? 0.0 : (close - cloud_top) / atr

// Self-calibrating weights
fwd_ret        = ta.change(close)
corr_rsi       = ta.correlation(f_rsi[1],       fwd_ret, calib_len)
corr_stoch     = ta.correlation(f_stoch[1],     fwd_ret, calib_len)
corr_zscore    = ta.correlation(f_zscore[1],    fwd_ret, calib_len)
corr_dist_bull = ta.correlation(f_dist_bull[1], fwd_ret, calib_len)
corr_dist_bear = ta.correlation(f_dist_bear[1], fwd_ret, calib_len)

w_rsi       = na(corr_rsi)       ? 1.0 : math.abs(corr_rsi)       * 4.0
w_stoch     = na(corr_stoch)     ? 1.0 : math.abs(corr_stoch)     * 4.0
w_zscore    = na(corr_zscore)    ? 1.0 : math.abs(corr_zscore)    * 4.0
w_dist_bull = na(corr_dist_bull) ? 1.0 : math.abs(corr_dist_bull) * 4.0
w_dist_bear = na(corr_dist_bear) ? 1.0 : math.abs(corr_dist_bear) * 4.0

z_sell = (w_rsi * f_rsi) + (w_stoch * f_stoch) + (w_zscore * f_zscore) + (w_dist_bear * f_dist_bear)
z_buy  = (-w_rsi * f_rsi) + (-w_stoch * f_stoch) + (-w_zscore * f_zscore) + (w_dist_bull * f_dist_bull)

prob_sell = 1.0 / (1.0 + math.exp(-z_sell))
prob_buy  = 1.0 / (1.0 + math.exp(-z_buy))

confirmed_bear = cross_below and prob_sell >= threshold
confirmed_bull = cross_above and prob_buy  >= threshold

// signal quality — fix: if/else chain avoids multi-line ternary CE10156
sig_quality(is_bull) =>
    prob = is_bull ? prob_buy : prob_sell
    gap  = threshold - prob
    tier = "Weak Setup"
    if prob >= threshold
        tier := is_bull ? "Bullish Breakout" : "Bearish Breakout"
    else if gap <= 0.10
        tier := "Nearly Confirmed"
    else if gap <= 0.25
        tier := "Watch Setup"
    tier

// fix: if/else avoids chained ternary
qual_to_col(qual, is_bull) =>
    col = #FF1744
    if qual == "Bullish Breakout" or qual == "Bearish Breakout"
        col := is_bull ? #39FF14 : #FF007F
    else if qual == "Nearly Confirmed"
        col := #00B0FF
    else if qual == "Watch Setup"
        col := #FF6D00
    else if qual == "Weak Setup"
        col := #FFC107
    col

// fix: pct() must be top-level, not inside an if block
pct(hits, total) =>
    total > 0 ? str.tostring(math.round(hits / total * 100)) + "%" : "—"

// DistStats
bar_move  = math.abs(close - close[1])
mean_move = ta.sma(bar_move, tp_lookback)

cnt_25  = 0
cnt_50  = 0
cnt_75  = 0
cnt_100 = 0
cnt_150 = 0
for i = 0 to tp_lookback - 1
    m = math.abs(close[i] - close[i + 1])
    if m < mean_move * 0.25
        cnt_25  += 1
    if m < mean_move * 0.50
        cnt_50  += 1
    if m < mean_move * 0.75
        cnt_75  += 1
    if m < mean_move * 1.00
        cnt_100 += 1
    if m < mean_move * 1.50
        cnt_150 += 1

half = float(tp_lookback) / 2.0
median_mult = 1.75
if cnt_150 >= half
    median_mult := 1.25
if cnt_100 >= half
    median_mult := 0.875
if cnt_75  >= half
    median_mult := 0.625
if cnt_50  >= half
    median_mult := 0.375
if cnt_25  >= half
    median_mult := 0.25
median_move = mean_move * median_mult

bin_w = atr * 0.25
b0 = 0
b1 = 0
b2 = 0
b3 = 0
b4 = 0
b5 = 0
for i = 0 to tp_lookback - 1
    m   = math.abs(close[i] - close[i + 1])
    idx = int(m / bin_w)
    if idx == 0
        b0 += 1
    else if idx == 1
        b1 += 1
    else if idx == 2
        b2 += 1
    else if idx == 3
        b3 += 1
    else if idx == 4
        b4 += 1
    else
        b5 += 1

mode_bin = 5
if b4 >= b5
    mode_bin := 4
if b3 >= b4 and b3 >= b5
    mode_bin := 3
if b2 >= b3 and b2 >= b4 and b2 >= b5
    mode_bin := 2
if b1 >= b2 and b1 >= b3 and b1 >= b4 and b1 >= b5
    mode_bin := 1
if b0 >= b1 and b0 >= b2 and b0 >= b3 and b0 >= b4 and b0 >= b5
    mode_bin := 0
mode_move = (float(mode_bin) + 0.5) * bin_w

// Target lines — single set, replaced on every cross
// fix: reassign array vars directly instead of array.clear() inside function,
//      which avoids the global-var-mutation-from-local-scope issue in Pine 6
var array<line>  all_lines  = array.new<line>()
var array<label> all_labels = array.new<label>()

if any_cross
    // delete every object then reinitialise the arrays
    for ln in all_lines
        line.delete(ln)
    for lb in all_labels
        label.delete(lb)
    all_lines  := array.new<line>()
    all_labels := array.new<label>()

    is_bull  = cross_above
    dir      = is_bull ? 1.0 : -1.0
    qual     = sig_quality(is_bull)
    qcol     = qual_to_col(qual, is_bull)
    prob     = is_bull ? prob_buy : prob_sell

    t_cons   = close + dir * mean_move   * tp_scale
    t_std    = close + dir * median_move * tp_scale
    t_aggr   = close + dir * mode_move   * tp_scale

    lvl_top  = math.max(t_cons, math.max(t_std, t_aggr))
    lvl_mid  = t_cons + t_std + t_aggr - math.max(t_cons, math.max(t_std, t_aggr)) - math.min(t_cons, math.min(t_std, t_aggr))
    lvl_bot  = math.min(t_cons, math.min(t_std, t_aggr))

    // label prefixes mimic the line style visually
    pfx_solid  = "────────────── "
    pfx_dashed = "- - - - - - -  "
    pfx_dotted = "··············  "

    lbl_cons = pfx_solid  + "Conservative"
    lbl_std  = pfx_dashed + "Standard"
    lbl_aggr = pfx_dotted + "Aggressive"

    lbl_top  = is_bull ? lbl_aggr : lbl_cons
    lbl_mid  = lbl_std
    lbl_bot  = is_bull ? lbl_cons : lbl_aggr
    col_top  = is_bull ? #FF007F : #FFEA00
    col_mid  = #00E5FF
    col_bot  = is_bull ? #FFEA00 : #FF007F

    x1 = bar_index
    x2 = bar_index + 60

    sty_top  = is_bull ? line.style_dotted : line.style_solid
    sty_mid  = line.style_dashed
    sty_bot  = is_bull ? line.style_solid  : line.style_dotted

    array.push(all_lines, line.new(x1, lvl_top, x2, lvl_top, color=color.new(col_top, 10), style=sty_top, width=2))
    array.push(all_lines, line.new(x1, lvl_mid, x2, lvl_mid, color=color.new(col_mid, 10), style=sty_mid, width=1))
    array.push(all_lines, line.new(x1, lvl_bot, x2, lvl_bot, color=color.new(col_bot, 10), style=sty_bot, width=1))

    array.push(all_labels, label.new(x1, lvl_top, lbl_top, color=color.new(col_top, 85), textcolor=col_top, style=label.style_label_right, size=size.tiny))
    array.push(all_labels, label.new(x1, lvl_mid, lbl_mid, color=color.new(col_mid, 85), textcolor=col_mid, style=label.style_label_right, size=size.tiny))
    array.push(all_labels, label.new(x1, lvl_bot, lbl_bot, color=color.new(col_bot, 85), textcolor=col_bot, style=label.style_label_right, size=size.tiny))

    // vertical dot connector — 7 ticks between top and bottom
    step = (lvl_top - lvl_bot) / 8.0
    for k = 1 to 7
        dot_y = lvl_bot + step * float(k)
        array.push(all_lines, line.new(x1, dot_y, x1 + 1, dot_y, color=color.new(color.white, 70), style=line.style_dotted, width=1))

    // signal quality badge
    badge_y  = is_bull ? low - atr * 0.8 : high + atr * 0.8
    badge_st = is_bull ? label.style_label_up : label.style_label_down
    array.push(all_labels, label.new(x1, badge_y,
         qual + "  " + str.tostring(math.round(prob * 100)) + "%",
         color=color.new(qcol, 70), textcolor=qcol, style=badge_st, size=size.small))

// plotting logic
p1 = plot(senkouA, offset=disp, color=color.new(#00E5FF, 65), title="Cloud A")
p2 = plot(senkouB, offset=disp, color=color.new(#FF007F, 65), title="Cloud B")
fill(p1, p2, color=senkouA > senkouB ? color.new(#00E5FF, 92) : color.new(#FF007F, 92))
plot(kijun, color=color.new(color.white, 60), linewidth=1, title="Kijun")

// alert signals — confirmed only
plotshape(confirmed_bull, title="Bull Break", location=location.belowbar,
     style=shape.triangleup, size=size.normal, color=#39FF14, textcolor=#39FF14)
plotshape(confirmed_bear, title="Bear Break", location=location.abovebar,
     style=shape.triangledown, size=size.normal, color=#FF007F, textcolor=#FF007F)

// backtest hit rates — runs once on bar close only, not on every realtime tick
// storing results in var so they persist across ticks without recomputing
var bt_bull_cons  = 0
var bt_bull_std   = 0
var bt_bull_aggr  = 0
var bt_bull_total = 0
var bt_bear_cons  = 0
var bt_bear_std   = 0
var bt_bear_aggr  = 0
var bt_bear_total = 0
var bool bt_done  = false

if barstate.islast and not barstate.isrealtime and not bt_done
    bt_done := true
    for i = bt_window to 1
        c_top_i = math.max(senkouA[i + disp], senkouB[i + disp])
        c_bot_i = math.min(senkouA[i + disp], senkouB[i + disp])
        c_top_p = math.max(senkouA[i + 1 + disp], senkouB[i + 1 + disp])
        c_bot_p = math.min(senkouA[i + 1 + disp], senkouB[i + 1 + disp])

        was_bull = close[i] > c_top_i and close[i + 1] <= c_top_p
        was_bear = close[i] < c_bot_i and close[i + 1] >= c_bot_p

        if was_bull or was_bear
            mm_i  = ta.sma(bar_move, tp_lookback)[i]
            at_i  = atr[i]
            bw_i  = at_i * 0.25
            mdn_i = mm_i * median_mult
            mod_i = (float(mode_bin) + 0.5) * bw_i

            if was_bull
                t1 = close[i] + mm_i  * tp_scale
                t2 = close[i] + mdn_i * tp_scale
                t3 = close[i] + mod_i * tp_scale
                bt_bull_total += 1
                h1 = false
                h2 = false
                h3 = false
                // fix: constant upper bound 50, guard with if i > j
                for j = 1 to 50
                    if j < i
                        if high[i - j] >= t1
                            h1 := true
                        if high[i - j] >= t2
                            h2 := true
                        if high[i - j] >= t3
                            h3 := true
                if h1
                    bt_bull_cons += 1
                if h2
                    bt_bull_std  += 1
                if h3
                    bt_bull_aggr += 1

            if was_bear
                t1 = close[i] - mm_i  * tp_scale
                t2 = close[i] - mdn_i * tp_scale
                t3 = close[i] - mod_i * tp_scale
                bt_bear_total += 1
                h1 = false
                h2 = false
                h3 = false
                for j = 1 to 50
                    if j < i
                        if low[i - j] <= t1
                            h1 := true
                        if low[i - j] <= t2
                            h2 := true
                        if low[i - j] <= t3
                            h3 := true
                if h1
                    bt_bear_cons += 1
                if h2
                    bt_bear_std  += 1
                if h3
                    bt_bear_aggr += 1

// dashboard
var table dash = table.new(position.bottom_right, 3, 9,
     bgcolor=color.new(#0D0D0D, 20),
     border_color=color.new(color.white, 80), border_width=1,
     frame_color=color.new(color.white, 70), frame_width=1)

if barstate.islast and show_tbl
    is_bull   = prob_buy > prob_sell
    // fix: if/else chain instead of chained ternary
    sig_label = "BIAS: SHORT"
    if confirmed_bull
        sig_label := "BUY"
    else if confirmed_bear
        sig_label := "SELL"
    else if is_bull
        sig_label := "BIAS: LONG"
    sig_col   = is_bull ? #39FF14 : #FF007F

    conf_val  = math.max(prob_buy, prob_sell)
    conf_str  = str.tostring(math.round(conf_val * 100)) + "%"
    // fix: if/else instead of chained ternary
    conf_col  = #FF4444
    if conf_val >= 0.75
        conf_col := #39FF14
    else if conf_val >= 0.60
        conf_col := #FFC107

    bull_cloud = senkouA > senkouB
    trend_str  = bull_cloud ? "Bullish" : "Bearish"
    trend_col  = bull_cloud ? #00E5FF : #FF007F

    // fix: if/else instead of chained ternary
    target_str = "Aggressive"
    if tp_scale <= 1.5
        target_str := "Conservative"
    else if tp_scale <= 3.0
        target_str := "Standard"

    lbl_col = color.new(color.white, 40)
    hdr_col = color.new(color.white, 15)

    table.cell(dash, 0, 0, "SMART ICHIMOKU", text_color=hdr_col, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "",               text_size=size.small)
    table.cell(dash, 2, 0, "GainzAlgo",      text_color=color.new(color.white, 50), text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Signal",     text_color=lbl_col, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, "",           text_size=size.small)
    table.cell(dash, 2, 1, sig_label,    text_color=sig_col, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Confidence", text_color=lbl_col,  text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, "",           text_size=size.small)
    table.cell(dash, 2, 2, conf_str,     text_color=conf_col, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Trend",      text_color=lbl_col,   text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, "",           text_size=size.small)
    table.cell(dash, 2, 3, trend_str,    text_color=trend_col, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Target Mode", text_color=lbl_col,                   text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, "",            text_size=size.small)
    table.cell(dash, 2, 4, target_str,    text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Target Hit Rates", text_color=hdr_col, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, "▲ Bull",           text_color=#39FF14, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 5, "▼ Bear",           text_color=#FF007F, text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 6, "Conservative", text_color=lbl_col, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 6, pct(bt_bull_cons, bt_bull_total), text_color=#39FF14, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 6, pct(bt_bear_cons, bt_bear_total), text_color=#FF007F, text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 7, "Standard",    text_color=lbl_col, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 7, pct(bt_bull_std, bt_bull_total),  text_color=#39FF14, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 7, pct(bt_bear_std, bt_bear_total),  text_color=#FF007F, text_size=size.tiny, text_halign=text.align_center)

    table.cell(dash, 0, 8, "Aggressive",  text_color=lbl_col, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 8, pct(bt_bull_aggr, bt_bull_total), text_color=#39FF14, text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 8, pct(bt_bear_aggr, bt_bear_total), text_color=#FF007F, text_size=size.tiny, text_halign=text.align_center)

// user alerts
alertcondition(confirmed_bull, "Confirmed Bull Break", "LR-confirmed bullish cloud break")
alertcondition(confirmed_bear, "Confirmed Bear Break", "LR-confirmed bearish cloud break")
alertcondition(any_cross and not confirmed_bull and not confirmed_bear, "Rejected Cross", "Cloud cross rejected by classifier")
````
