# Complete Volume Toolkit [NotLazyBear]

- url: https://www.tradingview.com/script/OxkureI2-Complete-Volume-Toolkit-NotLazyBear/
- type: indicator
- pine_id: PUB;c213f7c5cec34d1480341b39962f387a
- version: 1.0

## Description

[b]Complete Volume Toolkit — [NotLazyBear][/b]
[i]A comprehensive volume analysis system that goes far beyond basic volume bars. It estimates buying versus selling pressure inside each candle using either true lower-timeframe data or chart-timeframe approximation, detects unusual volume spikes using 7 different statistical methods, identifies volume clustering patterns, and tracks cumulative flow over time. Think of it as a full forensic lab for volume data — not just showing how much traded, but revealing who was in control, whether the activity was abnormal, and when volume patterns are breaking out of their normal ranges.[/i]
[b]What This Actually Does (In Plain English)[/b]
Most charts just show volume as green or red bars. This toolkit breaks volume down into multiple dimensions:
[list]
[*][b]How much traded?[/b] — Standard volume bars plus moving average and relative comparison.
[*][b]Who was in control?[/b] — Estimated buy versus sell volume within each candle, calculated from true intrabar data when available or approximated from the chart bar's close position when not.
[*][b]Was this normal or weird?[/b] — 7 different statistical tests for abnormal volume spikes.
[*][b]Where does volume normally cluster?[/b] — Density analysis finding the "usual" volume levels.
[*][b]Is volume breaking out of its pattern?[/b] — Cluster breakout detection when volume leaves its typical range.
[*][b]What regime are we in?[/b] — Subtle background tints flag when volume sits in the top or bottom 10 percent of its recent distribution.
[/list]
[b]The Core Components Explained[/b]
[list]
[*][b]Optional Intrabar Analysis:[/b] The indicator can pull true lower-timeframe data to calculate exact buy and sell volume across every sub-bar inside the current candle. When enabled, you select a lower timeframe (e.g., 1-minute on a 5-minute chart) and the script aggregates every tick of volume with directional bias. When disabled, the indicator falls back to a chart-timeframe estimation: if price closed near the high of the candle, most volume was likely buying; if near the low, mostly selling. Both modes are useful — intrabar is more precise but requires a valid lower timeframe; chart mode works on any chart with zero dependencies.
[*][b]Cumulative Tracking:[/b] Adds up volume or delta over a rolling window. Shows whether buying or selling pressure is building over time, not just per bar.
[*][b]7 Outlier Detection Methods:[/b] From simple Z-scores to advanced wavelet analysis. Each method has different strengths — some catch Gaussian extremes, others catch non-normal distributions, others catch sudden transients. Using them together creates a robust "unusual activity" alarm.
[*][b]Clustering Analysis:[/b] Volume tends to cluster around certain levels (like water finding its level). When volume suddenly leaves this cluster, it often signals a regime change — either a breakout or a collapse in participation.
[*][b]Volume Regime Filter:[/b] Background tints mark the 90th and 10th percentiles of recent volume. This gives instant context: is participation confirming the move, or is the market asleep?
[/list]
[b]All The Settings Explained[/b]
[i]Intrabar Resolution[/i]
[list]
[*][b]Enable Intrabar Analysis:[/b] Master toggle. When ON, the script pulls lower-timeframe data for precise delta calculation. When OFF, all volume metrics use chart-timeframe data only and no lower timeframe is required.
[*][b]Lower Timeframe:[/b] Only active when Intrabar Analysis is enabled. Must be strictly lower than the chart timeframe (e.g., 1-minute on a 5-minute chart). The script validates this automatically and throws a runtime error if the condition is violated.
[/list]
[i]Volume Display[/i]
[list]
[*][b]Show Volume Per Bar:[/b] The basic histogram. Green when close ≥ open, red when close < open.
[*][b]Show Volume Moving Average:[/b] A simple SMA of volume. Helps see if today's volume is above or below average.
[*][b]Show Relative Volume:[/b] Volume divided by its moving average. A reading of 2.0 means twice normal volume. Useful for quick comparison.
[*][b]Volume MA Length:[/b] Default 20. The lookback for the average and relative calculations.
[*][b]Colors:[/b] Customizable for bullish volume, bearish volume, MA line, and relative volume line.
[/list]
[i]Cumulative Volume[/i]
[list]
[*][b]Show Cumulative Volume:[/b] Rolling sum of volume over the lookback period. Warning: this can be huge and may collide with regular volume on the same scale.
[*][b]Cumulative Lookback:[/b] Default 50. How many bars to sum.
[*][b]Normalize Cumulative:[/b] When ON, divides the sum by the lookback length, showing "average volume over the window" instead of raw sum. This keeps the scale reasonable and comparable to per-bar volume.
[*][b]Color:[/b] Blue by default.
[/list]
[i]Volume Delta[/i]
[list]
[*][b]Show Volume Delta Per Bar:[/b] Estimated buy volume minus sell volume for each bar. Green = more buying estimated. Red = more selling estimated.
[*][b]Show Cumulative Volume Delta:[/b] Running sum of the delta over the lookback. Shows sustained buying or selling pressure building over time.
[*][b]Delta Cumulative Lookback:[/b] Default 50. The window for summing delta.
[*][b]Colors:[/b] Green for positive (buying), red for negative (selling), purple for cumulative line.
[/list]
[i]Volume Outlier Detection[/i]
[list]
[*][b]Show Outlier Signals:[/b] Master toggle for the statistical anomaly detection.
[*][b]Detection Method:[/b] Choose which method(s) to use:
[list]
[*][b]Z-Score:[/b] Classic "how many standard deviations from the mean?" Good for normally distributed data.
[*][b]Modified Z-Score:[/b] Uses median and MAD instead of mean and standard deviation. More robust — won't be fooled by existing outliers.
[*][b]IQR:[/b] Interquartile Range. Non-parametric — makes no assumptions about distribution shape. Good for skewed data.
[*][b]Chauvenet's Criterion:[/b] Probabilistic — asks "how likely is this value in a sample of this size?" Adapts to window length.
[*][b]Grubbs-Inspired:[/b] Extreme Studentized Deviate. Good for detecting single extreme values in otherwise normal data.
[*][b]Entropy Anomaly:[/b] Information-theoretic. Flags when volume is both extreme AND the overall distribution is unusually dispersed.
[*][b]Wavelet Anomaly:[/b] Haar wavelet detail coefficients. Catches sudden transients and sharp changes that other methods miss.
[*][b]All Combined:[/b] Uses all 7 methods and requires at least 2 to agree. Recommended for most users — most robust.
[/list]
[*][b]Detection Window:[/b] Default 50. The lookback for all statistical calculations. Longer = more stable baselines, slower reaction. Shorter = faster reaction, more noise.
[*][b]Z-Score Threshold:[/b] Default 2.5. How many standard deviations to count as "extreme." Higher = stricter, fewer signals. Lower = more sensitive.
[*][b]Modified Z-Score Threshold:[/b] Default 3.5. Same logic but for the robust version.
[*][b]IQR Multiplier:[/b] Default 1.5. The "fences" multiplier for Tukey's method. 1.5 is standard. 3.0 = very conservative.
[*][b]Chauvenet Criterion:[/b] Default 0.5. Expected occurrence threshold. Lower = stricter rejection.
[*][b]Entropy Dispersion Threshold:[/b] Default 0.7. When entropy exceeds this AND volume is extreme, flag it.
[*][b]Wavelet Threshold:[/b] Default 2.5. Z-score equivalent for wavelet detail coefficients.
[/list]
[i]Volume Clustering[/i]
[list]
[*][b]Show Cluster Detection:[/b] Toggle for identifying when volume sits in its "normal" density zone.
[*][b]Show Modal Volume:[/b] Shows the most common volume level (the "peak" of the distribution).
[*][b]Cluster Method:[/b]
[list]
[*][b]KDE Density:[/b] Kernel Density Estimate — smooth probability distribution. Elegant but computationally heavier.
[*][b]Histogram Binning:[/b] Simple bucket counting. Faster, less smooth.
[*][b]KDE + Histogram:[/b] Average of both. Recommended balance.
[/list]
[*][b]Cluster Window:[/b] Default 100. How much history to use for density estimation.
[*][b]KDE Bandwidth:[/b] Default 0.08 (8% of range). How "wide" the smoothing kernel is. Higher = smoother, more inclusive. Lower = tighter, more selective.
[*][b]Cluster Density Threshold:[/b] Default 0.6. Score above this = "in cluster." Higher = stricter cluster membership.
[*][b]Histogram Bins:[/b] Default 20. How many buckets for histogram methods.
[*][b]Highlight Cluster Regions:[/b] Toggle background tinting during sustained clusters.
[/list]
[i]Visual Settings[/i]
[list]
[*][b]Enable Glow Effects:[/b] Adds a halo around key lines for visibility.
[*][b]Show Event Labels:[/b] Text labels for outliers and breakouts.
[*][b]Label Min Bars Apart:[/b] Default 5. Prevents label spam.
[*][b]Background Transparency:[/b] Default 85. How see-through the background tints are.
[/list]
[b]How To Read The Chart[/b]
[list]
[*][b]Volume Histogram (Green/Red Bars):[/b] Standard volume. Taller = more activity. Green = bullish close. Red = bearish close.
[*][b]Volume MA Line (Yellow):[/b] The average volume. When histogram spikes well above this line, pay attention.
[*][b]Relative Volume Line (Orange):[/b] How many "multiples" of average volume today represents. 1.5 = 50% above average. 3.0 = triple average. Spikes here often precede major moves.
[*][b]Cumulative Volume (Blue):[/b] The rolling sum or average. Shows whether participation is building over the lookback period.
[*][b]Volume Delta (Green/Red Histogram):[/b] Estimated buy minus sell pressure per bar. Tall green = aggressive buying. Tall red = aggressive selling. This is the "who's winning" indicator.
[*][b]Cumulative Delta (Purple/Green Line):[/b] The running sum of delta. Rising = sustained buying pressure. Falling = sustained selling pressure. Divergences between cumulative delta and price often signal hidden accumulation or distribution.
[*][b]Modal Volume (Magenta Line):[/b] The "normal" volume level. When volume is near this line, activity is typical. When it diverges significantly, something unusual is happening.
[*][b]Light Red Background Tint:[/b] Volume is in the top 10% of its recent range — high participation regime.
[*][b]Light Blue Background Tint:[/b] Volume is in the bottom 10% of its recent range — low participation, market likely asleep.
[*][b]Red Background Flash:[/b] Outlier detected — volume is statistically abnormal. At least 2 of 7 methods agreed (if using All Combined). This is your "wake up" signal.
[*][b]Green Background Tint:[/b] Sustained cluster — volume is sitting in its typical density zone. The market is behaving "normally" by volume standards.
[*][b]Circle Marker (Top):[/b] Outlier event. Exact bar where abnormal volume occurred.
[*][b]Triangle Marker (Bottom):[/b] Cluster breakout — volume just left its typical range. Often precedes directional moves.
[/list]
[b]Practical Trading Strategies[/b]
[i]The "Volume Confirms Price" Play (Beginner-Friendly)[/i]
[list]
[*]When price breaks out of a range or pattern
[*]Check that volume is [b]above average[/b] (relative volume > 1.5) AND [b]not an outlier[/b] (no red background)
[*]Check that volume delta is [b]green[/b] (buying estimated)
[*]This confirms the breakout has genuine participation behind it
[*]Enter in breakout direction with stop-loss behind the breakout point
[/list]
[i]The "Outlier Fade" Play[/i]
[list]
[*]When a [b]red outlier background[/b] appears with [b]no significant price move[/b]
[*]This means huge volume traded but price went nowhere — a battle between buyers and sellers
[*]Often called "churn" or "absorption" — smart money is exchanging positions with dumb money
[*]Wait for the next bar's direction. If price breaks the high of the outlier bar, buyers won. If it breaks the low, sellers won.
[*]Enter in the direction of the resolution
[/list]
[i]The "Delta Divergence" Play[/i]
[list]
[*]When [b]price makes a new low[/b] but [b]cumulative delta makes a higher low[/b]
[*]This means selling pressure is weakening even as price falls — hidden accumulation
[*]Wait for confirmation (bullish candle, support hold, or outlier buying volume)
[*]Enter long with stop below the recent low
[*]Same logic in reverse for bearish divergence (price high, delta lower)
[/list]
[i]The "Cluster Breakout" Play[/i]
[list]
[*]When the [b]green cluster background[/b] has persisted for several bars (market quiet, volume normal)
[*]Then a [b]triangle marker[/b] appears (cluster breakout) with volume spiking above modal
[*]This means the market is "waking up" from its typical volume pattern
[*]Enter in the direction of the volume spike (green delta = long, red delta = short)
[*]The first move out of a cluster is often the strongest
[/list]
[i]The "Volume Regime Filter"[/i]
[list]
[*]Use the [b]subtle background tints[/b] (light red/blue from high/low percentiles) as a trade filter
[*]Only take trend-following trades when volume is in the [b]high percentile[/b] (light red background) — this means participation confirms the move
[*]Avoid new entries when volume is in the [b]low percentile[/b] (light blue background) — the market is asleep, moves are likely false
[/list]
[b]Important Things To Know[/b]
[list]
[*][b]Intrabar Mode Is Optional:[/b] You do not need a lower timeframe to use this indicator. Disable "Enable Intrabar Analysis" and the script runs entirely on chart-timeframe data with estimated delta. Enable it when you want higher precision and have access to a valid lower timeframe.
[*][b]Lower Timeframe Must Be Strictly Lower:[/b] If you enable intrabar analysis, the selected timeframe must be lower than the chart timeframe. The script enforces this automatically. Attempting to use the same timeframe or a higher one will trigger a runtime error.
[*][b]Delta Is An Estimate:[/b] Whether using intrabar aggregation or chart-timeframe approximation, the buy/sell split is directional, not exact. A bar that wicks down then closes at the high had buying, even if the estimate says 100% buying. Use delta as a [b]directional hint[/b], not exact accounting.
[*][b]Outlier Methods Have Different Strengths:[/b] Z-Score assumes normal distribution — works poorly if volume is naturally skewed. Modified Z-Score is robust to outliers already present. IQR makes no distribution assumptions. Wavelet catches sharp spikes that smooth methods miss. "All Combined" with 2+ agreement is the safest default.
[*][b]Clustering Is Slow to Update:[/b] The density estimation uses 100 bars of history. A sudden regime change (like a news event) won't immediately reflect in the cluster boundaries. The cluster breakout signal helps bridge this gap.
[*][b]Scale Collision Is Real:[/b] Cumulative volume (especially unnormalized) can be 50× larger than per-bar volume. If you enable both on the same pane, the histogram becomes invisible. Either normalize cumulative or put them on separate panes.
[*][b]The Glow Effects Are Purely Visual:[/b] They add no analytical value but make lines easier to see against busy backgrounds. Turn off if you prefer clean charts or need performance.
[*][b]Label Frequency Prevents Spam:[/b] The minimum bars-between-labels setting prevents outlier clusters from creating 10 labels in 5 bars. Default 5 is reasonable. Lower if you want more annotation. Higher for cleaner charts.
[*][b]No Repainting:[/b] All calculations use confirmed bar data. The intrabar estimate uses the confirmed close position. Outlier detection uses closed bars in its window. Clustering uses historical data only.
[*][b]Data Window Shows Hidden Values:[/b] Many calculated values (Z-scores, entropy, wavelet scores, cluster densities, intrabar count, buy/sell estimates) are computed but not plotted. They're available in the Data Window for debugging and custom analysis.
[/list]
[b]Common Mistakes To Avoid[/b]
[list]
[*][b]Forgetting to Toggle Intrabar Mode:[/b] If you load the indicator and see no delta data, check whether "Enable Intrabar Analysis" is on but no valid lower timeframe is selected. Either pick a proper lower timeframe or disable intrabar mode entirely.
[*][b]Trading Every Outlier:[/b] An outlier just means volume was unusual, not that price must move. Sometimes huge volume is just two market makers rebalancing. Wait for price confirmation (break of a level, next bar direction).
[*][b]Ignoring the Delta Sign:[/b] A volume outlier with [b]red delta[/b] (selling estimated) is very different from one with [b]green delta[/b]. Always check who was in control during the abnormal volume.
[*][b]Forgetting Cumulative Context:[/b] A single green delta bar means little. But 10 green delta bars in a row with rising cumulative delta means sustained accumulation. The cumulative line tells the story the per-bar histogram cannot.
[*][b]Using Too Many Overlays:[/b] Volume histogram + cumulative volume + delta + cumulative delta + modal + outlier marks = visual chaos. Start with volume + delta only. Add features gradually as you learn their value.
[*][b]Mistaking Cluster Breakout for Outlier:[/b] A cluster breakout (triangle) means volume left its normal range. An outlier (circle + red background) means volume is statistically extreme. They often coincide but mean slightly different things — breakout is about pattern change, outlier is about statistical rarity.
[*][b]Setting Thresholds Too Low:[/b] A Z-score threshold of 1.0 will flag half your bars as outliers. A threshold of 4.0 will almost never fire. The defaults (2.5–3.5) are calibrated for typical market data. Adjust only if you consistently see too many or too few signals.
[/list]
[b]Quick Setup Checklist[/b]
[list]
[*]Load the indicator on a separate pane below price (recommended)
[*]Decide on [b]Intrabar Analysis[/b]: enable it with a valid lower timeframe for precision, or leave it disabled for simplicity
[*]Start with only [b]Volume Per Bar[/b] and [b]Volume Delta Per Bar[/b] enabled
[*]Watch for 20–30 bars to see how delta correlates with price direction
[*]Enable [b]Volume MA[/b] and [b]Relative Volume[/b] to establish "normal" baselines
[*]Enable [b]Outlier Detection (All Combined)[/b] and note which outliers precede real moves versus which fizzle
[*]Add [b]Cumulative Delta[/b] and watch for divergences with price
[*]Enable [b]Clustering[/b] last — it's the most advanced feature
[*]Adjust detection thresholds based on your market's volatility (crypto needs higher thresholds than forex)
[*]Use outlier signals as [b]alerts[/b] to check your charts, not as automatic entry signals
[*]Always confirm volume signals with price action — volume is the fuel, price is the steering
[/list]

## Source Code

````pine
//@version=5
indicator("Complete Volume Toolkit-[NotLazyBear]", shorttitle="CVT-[NotLazyBear]", overlay=false, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ============================================================================
// CONSTANTS
// ============================================================================
MAX_LB     = 500
MAX_BINS   = 30
PI         = math.pi
SQRT2      = 1.4142135623730951

// ============================================================================
// INPUTS
// ============================================================================
grp_ltf  = "① Intrabar Resolution"
use_intrabar= input.bool(true,  "Enable Intrabar Analysis", group=grp_ltf, tooltip="When disabled, all volume metrics use chart timeframe data only. No lower timeframe is required.")
ltf_input = input.timeframe("1", "Lower Timeframe", group=grp_ltf, tooltip="Only used when Intrabar Analysis is enabled. Must be strictly lower than chart timeframe.")

grp_disp = "② Volume Display"
show_vol      = input.bool(true,  "Show Volume Per Bar", group=grp_disp)
show_vol_ma   = input.bool(false, "Show Volume Moving Average", group=grp_disp)
show_rel_vol  = input.bool(false, "Show Relative Volume", group=grp_disp)
vol_ma_len    = input.int(20,     "Volume MA Length", minval=2, maxval=200, group=grp_disp)
vol_col_up    = input.color(color.new(#00e676, 10), "Bullish Volume Color", group=grp_disp)
vol_col_dn    = input.color(color.new(#ff1744, 10), "Bearish Volume Color", group=grp_disp)
vol_ma_col    = input.color(color.new(#ffd600, 0),  "Volume MA Color", group=grp_disp)
rel_vol_col   = input.color(color.new(#ff9100, 0),  "Relative Volume Color", group=grp_disp)

grp_cum = "③ Cumulative Volume"
show_cum_vol  = input.bool(false, "Show Cumulative Volume", group=grp_cum)
cum_lookback  = input.int(50,    "Cumulative Lookback (Bars)", minval=5, maxval=MAX_LB, group=grp_cum)
cum_col       = input.color(color.new(#2196f3, 0), "Cumulative Volume Color", group=grp_cum)
norm_cum      = input.bool(false, "Normalize Cumulative (÷ Lookback)", group=grp_cum)

grp_delta = "④ Volume Delta"
show_delta      = input.bool(false,  "Show Volume Delta Per Bar", group=grp_delta)
show_cum_delta  = input.bool(false, "Show Cumulative Volume Delta", group=grp_delta)
delta_lb        = input.int(50,     "Delta Cumulative Lookback (Bars)", minval=5, maxval=MAX_LB, group=grp_delta)
delta_col_buy   = input.color(color.new(#00e676, 20), "Positive Delta Color", group=grp_delta)
delta_col_sell  = input.color(color.new(#ff1744, 20), "Negative Delta Color", group=grp_delta)
cum_delta_col   = input.color(color.new(#e040fb, 0),  "Cumulative Delta Color", group=grp_delta)

grp_out = "⑤ Volume Outlier Detection"
show_outliers = input.bool(false,  "Show Outlier Signals", group=grp_out)
outlier_method= input.string("All Combined", "Detection Method", options=["Z-Score","Modified Z-Score","IQR","Chauvenet Criterion","Grubbs-Inspired","Entropy Anomaly","Wavelet Anomaly","All Combined"], group=grp_out)
outlier_win   = input.int(50,     "Detection Window", minval=10, maxval=MAX_LB, group=grp_out)
z_thresh      = input.float(2.5,  "Z-Score Threshold", minval=0.5, maxval=5.0, step=0.1, group=grp_out)
mod_z_thresh  = input.float(3.5,  "Modified Z-Score Threshold", minval=1.0, maxval=10.0, step=0.1, group=grp_out)
iqr_mult      = input.float(1.5,  "IQR Multiplier", minval=0.5, maxval=3.0, step=0.1, group=grp_out)
chauv_crit    = input.float(0.5,  "Chauvenet Criterion", minval=0.1, maxval=1.0, step=0.1, group=grp_out)
ent_thresh    = input.float(0.7,  "Entropy Dispersion Threshold", minval=0.1, maxval=1.0, step=0.05, group=grp_out)
wav_thresh    = input.float(2.5,  "Wavelet Threshold", minval=0.5, maxval=5.0, step=0.1, group=grp_out)

grp_clust = "⑥ Volume Clustering"
show_clusters = input.bool(false,  "Show Cluster Detection", group=grp_clust)
show_modal    = input.bool(false,  "Show Modal Volume (Cluster Center)", group=grp_clust)
clust_method  = input.string("KDE + Histogram", "Cluster Method", options=["KDE Density","Histogram Binning","KDE + Histogram"], group=grp_clust)
clust_win     = input.int(100,    "Cluster Window", minval=20, maxval=MAX_LB, group=grp_clust)
clust_bw      = input.float(0.08, "KDE Bandwidth (% of r1)", minval=0.01, maxval=0.5, step=0.01, group=grp_clust)
clust_thresh  = input.float(0.6,  "Cluster Density Threshold", minval=0.1, maxval=1.0, step=0.05, group=grp_clust)
hist_bins     = input.int(20,     "Histogram Bins", minval=5, maxval=MAX_BINS, group=grp_clust)
show_clust_bg = input.bool(true,  "Highlight Cluster Regions", group=grp_clust)

grp_vis = "⑦ Visual Settings"
show_glow     = input.bool(true,  "Enable Glow Effects", group=grp_vis)
show_labels   = input.bool(false, "Show Event Labels", group=grp_vis)
label_freq    = input.int(5,      "Label Min Bars Apart", minval=1, maxval=50, group=grp_vis)
bg_transp     = input.int(85,     "Background Transparency", minval=0, maxval=95, group=grp_vis)

// ============================================================================
// VALIDATION
// ============================================================================
if use_intrabar and timeframe.in_seconds() <= timeframe.in_seconds(ltf_input)
    runtime.error("Lower timeframe must be strictly lower than chart timeframe when Intrabar Analysis is enabled.")

// ============================================================================
// PHD-GRADE MATHEMATICAL PRIMITIVES
// ============================================================================

// Abramowitz & Stegun (1964) Formula 7.1.26 — Error Function
erf_as(x) =>
    ax = math.abs(x)
    t  = 1.0 / (1.0 + 0.3275911 * ax)
    poly = ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t
    res  = 1.0 - poly * math.exp(-ax * ax)
    x < 0 ? -res : res

erfc_as(x) =>
    1.0 - erf_as(x)

// Population Mean
mean_pop(src, len) =>
    sum = 0.0
    for i = 0 to len - 1
        sum += src[i]
    sum / float(len)

// Population Standard Deviation
stdev_pop(src, mean_val, len) =>
    sum_sq = 0.0
    for i = 0 to len - 1
        diff = src[i] - mean_val
        sum_sq += diff * diff
    math.sqrt(sum_sq / float(len))

// Median
median_series(src, len) =>
    arr = array.new_float(0)
    for i = 0 to len - 1
        array.push(arr, src[i])
    array.sort(arr)
    sz  = array.size(arr)
    mid = int(sz / 2)
    sz % 2 == 0 and sz > 0 ? (array.get(arr, mid - 1) + array.get(arr, mid)) / 2.0 : array.get(arr, mid)

// Median Absolute Deviation (MAD)
mad_series(src, median_val, len) =>
    arr = array.new_float(0)
    for i = 0 to len - 1
        array.push(arr, math.abs(src[i] - median_val))
    array.sort(arr)
    sz  = array.size(arr)
    mid = int(sz / 2)
    sz % 2 == 0 and sz > 0 ? (array.get(arr, mid - 1) + array.get(arr, mid)) / 2.0 : array.get(arr, mid)

// Percentile
percentile_series(src, len, pct) =>
    arr = array.new_float(0)
    for i = 0 to len - 1
        array.push(arr, src[i])
    array.sort(arr)
    sz = array.size(arr)
    sz == 0 ? 0.0 : array.get(arr, int(math.round(pct * float(sz - 1))))

// Shannon Entropy (normalized 0–1)
entropy_series(src, len, bins) =>
    min_val = src[0]
    max_val = src[0]
    for i = 1 to len - 1
        min_val := math.min(min_val, src[i])
        max_val := math.max(max_val, src[i])
    r1 = max_val - min_val
    if r1 == 0 or len <= 1
        0.0
    else
        bin_counts = array.new_int(bins, 0)
        for i = 0 to len - 1
            bidx = int(math.min(bins - 1, ((src[i] - min_val) / r1) * bins))
            curr = array.get(bin_counts, bidx)
            array.set(bin_counts, bidx, curr + 1)
        h = 0.0
        for i = 0 to bins - 1
            cnt = array.get(bin_counts, i)
            if cnt > 0
                p = float(cnt) / float(len)
                h += -p * math.log(p) / math.log(2)
        max_h = math.log(bins) / math.log(2)
        max_h > 0 ? h / max_h : 0.0

// Haar Wavelet Anomaly Score
wavelet_score(src, len) =>
    if len < 3
        0.0
    else
        arr = array.new_float(0)
        for i = 0 to len - 2
            detail = math.abs(src[i] - src[i+1]) / 2.0
            array.push(arr, detail)
        sz = array.size(arr)
        mean_d = 0.0
        for i = 0 to sz - 1
            mean_d += array.get(arr, i)
        mean_d := mean_d / math.max(1, sz)
        std_d = 0.0
        for i = 0 to sz - 1
            diff = array.get(arr, i) - mean_d
            std_d += diff * diff
        std_d := math.sqrt(std_d / math.max(1, sz))
        curr_d = math.abs(src[0] - src[1]) / 2.0
        std_d > 0 ? (curr_d - mean_d) / std_d : 0.0

// Kernel Density Estimate (Gaussian kernel, normalized to [0,1])
kde_density(src, len, bandwidth_pct) =>
    if len < 2
        1.0
    else
        min_val = src[0]
        max_val = src[0]
        for i = 1 to len - 1
            min_val := math.min(min_val, src[i])
            max_val := math.max(max_val, src[i])
        r1 = max_val - min_val
        if r1 == 0
            1.0
        else
            h = bandwidth_pct * r1
            if h == 0
                1.0
            else
                sum_k = 0.0
                for i = 0 to len - 1
                    u = (src[0] - src[i]) / h
                    sum_k += math.exp(-0.5 * u * u)
                sum_k / float(len)

// Histogram Binning Cluster Frequency
histogram_cluster(src, len, bins) =>
    if len < 2
        1.0
    else
        min_val = src[0]
        max_val = src[0]
        for i = 1 to len - 1
            min_val := math.min(min_val, src[i])
            max_val := math.max(max_val, src[i])
        r1 = max_val - min_val
        if r1 == 0
            1.0
        else
            bin_counts = array.new_int(bins, 0)
            for i = 0 to len - 1
                bidx = int(math.min(bins - 1, ((src[i] - min_val) / r1) * bins))
                curr = array.get(bin_counts, bidx)
                array.set(bin_counts, bidx, curr + 1)
            curr_bidx = int(math.min(bins - 1, ((src[0] - min_val) / r1) * bins))
            curr_cnt  = array.get(bin_counts, curr_bidx)
            float(curr_cnt) / float(len)

// ============================================================================
// INTRABAR DATA ACQUISITION (request.security_lower_tf)
// ============================================================================
// Always called at global scope, but only consumed when use_intrabar is true.
[o_arr, h_arr, l_arr, c_arr, v_arr] = request.security_lower_tf(syminfo.tickerid, ltf_input, [open, high, low, close, volume])

// Array integrity check — gated by the intrabar toggle
has_intrabars = use_intrabar and array.size(o_arr) > 0 and array.size(h_arr) > 0 and array.size(l_arr) > 0 and array.size(c_arr) > 0 and array.size(v_arr) > 0

// ============================================================================
// VOLUME METRICS CALCULATION
// ============================================================================
// Intrabar mode:  aggregates true lower-timeframe delta from all sub-bars.
// Chart mode:    estimates delta from the chart bar's OHLC position.
var float bar_delta        = 0.0
var float bar_buy_vol      = 0.0
var float bar_sell_vol     = 0.0
var float total_bar_vol    = 0.0
var int   bar_subcount     = 0

if has_intrabars
    bar_subcount := array.size(v_arr)
    total_bar_vol := 0.0
    bar_buy_vol := 0.0
    bar_sell_vol := 0.0
    bar_delta := 0.0
    
    for i = 0 to bar_subcount - 1
        o = array.get(o_arr, i)
        h = array.get(h_arr, i)
        l = array.get(l_arr, i)
        c = array.get(c_arr, i)
        v = array.get(v_arr, i)
        
        r1_bar   = h - l
        buy_pct  = r1_bar > 0 ? (c - l) / r1_bar : 0.5
        sell_pct = r1_bar > 0 ? (h - c) / r1_bar : 0.5
        
        buy_v  = v * buy_pct
        sell_v = v * sell_pct
        
        bar_buy_vol  += buy_v
        bar_sell_vol += sell_v
        bar_delta    += (buy_v - sell_v)
        total_bar_vol += v
else
    // Chart timeframe estimation (used when intrabar is disabled OR no intrabar data returned)
    r1_bar   = high - low
    buy_pct  = r1_bar > 0 ? (close - low) / r1_bar : 0.5
    sell_pct = r1_bar > 0 ? (high - close) / r1_bar : 0.5
    bar_buy_vol  := volume * buy_pct
    bar_sell_vol := volume * sell_pct
    bar_delta    := bar_buy_vol - bar_sell_vol
    total_bar_vol:= volume
    bar_subcount := 1

// ============================================================================
// PRIMARY METRICS
// ============================================================================
valid_cum      = bar_index >= cum_lookback
valid_delta    = bar_index >= delta_lb
valid_outlier  = bar_index >= outlier_win
valid_clust    = bar_index >= clust_win

// Canonical volume works in both modes
canonical_vol = total_bar_vol

cum_volume     = math.sum(canonical_vol, cum_lookback)
cum_delta_vol  = math.sum(bar_delta, delta_lb)
display_cum_vol= norm_cum and valid_cum ? cum_volume / float(cum_lookback) : cum_volume

vol_ma         = ta.sma(canonical_vol, vol_ma_len)
rel_volume     = valid_outlier and vol_ma > 0 ? canonical_vol / vol_ma : na

// ============================================================================
// STATISTICAL OUTLIER DETECTION
// ============================================================================

// 1. Z-Score
vol_mean_z = valid_outlier ? mean_pop(canonical_vol, outlier_win) : na
vol_std_z  = valid_outlier and vol_mean_z ? stdev_pop(canonical_vol, vol_mean_z, outlier_win) : na
z_score    = valid_outlier and vol_std_z > 0 ? (canonical_vol - vol_mean_z) / vol_std_z : na
is_z_outlier = valid_outlier and math.abs(z_score) > z_thresh

// 2. Modified Z-Score (MAD-based)
vol_med_mz = valid_outlier ? median_series(canonical_vol, outlier_win) : na
vol_mad    = valid_outlier and vol_med_mz ? mad_series(canonical_vol, vol_med_mz, outlier_win) : na
mod_z      = valid_outlier and vol_mad > 0 ? 0.6745 * (canonical_vol - vol_med_mz) / vol_mad : na
is_mz_outlier = valid_outlier and math.abs(mod_z) > mod_z_thresh

// 3. Interquartile r1
vol_q1 = valid_outlier ? percentile_series(canonical_vol, outlier_win, 0.25) : na
vol_q3 = valid_outlier ? percentile_series(canonical_vol, outlier_win, 0.75) : na
vol_iqr= valid_outlier ? vol_q3 - vol_q1 : na
iqr_low= valid_outlier ? vol_q1 - iqr_mult * vol_iqr : na
iqr_high=valid_outlier ? vol_q3 + iqr_mult * vol_iqr : na
is_iqr_outlier = valid_outlier and (canonical_vol < iqr_low or canonical_vol > iqr_high)

// 4. Chauvenet's Criterion
chauv_z = valid_outlier and vol_std_z > 0 ? math.abs(canonical_vol - vol_mean_z) / vol_std_z : na
chauv_p = valid_outlier ? erfc_as(chauv_z / SQRT2) : na
is_chauv_outlier = valid_outlier and chauv_p * outlier_win < chauv_crit

// 5. Grubbs-Inspired ESD
grubbs_crit = 2.2 + 0.6 * math.log10(outlier_win)
grubbs_g    = valid_outlier and vol_std_z > 0 ? math.abs(canonical_vol - vol_mean_z) / vol_std_z : na
is_grubbs_outlier = valid_outlier and grubbs_g > grubbs_crit

// 6. Entropy Anomaly
vol_entropy = valid_outlier ? entropy_series(canonical_vol, outlier_win, 10) : na
is_entropy_outlier = valid_outlier and vol_entropy > ent_thresh and vol_std_z > 0 and (canonical_vol - vol_mean_z) / vol_std_z > z_thresh * 0.8

// 7. Wavelet Anomaly
wav_score = valid_outlier ? wavelet_score(canonical_vol, outlier_win) : na
is_wavelet_outlier = valid_outlier and math.abs(wav_score) > wav_thresh

// Confluence scoring
outlier_score = (is_z_outlier ? 1 : 0) + (is_mz_outlier ? 1 : 0) + (is_iqr_outlier ? 1 : 0) + (is_chauv_outlier ? 1 : 0) + (is_grubbs_outlier ? 1 : 0) + (is_entropy_outlier ? 1 : 0) + (is_wavelet_outlier ? 1 : 0)

is_outlier = switch outlier_method
    "Z-Score"            => is_z_outlier
    "Modified Z-Score"   => is_mz_outlier
    "IQR"                => is_iqr_outlier
    "Chauvenet Criterion"=> is_chauv_outlier
    "Grubbs-Inspired"    => is_grubbs_outlier
    "Entropy Anomaly"    => is_entropy_outlier
    "Wavelet Anomaly"    => is_wavelet_outlier
    "All Combined"       => outlier_score >= 2
    => false

// Volume Regime Classification
vol_p90 = valid_outlier ? percentile_series(canonical_vol, outlier_win, 0.90) : na
vol_p10 = valid_outlier ? percentile_series(canonical_vol, outlier_win, 0.10) : na
vol_p50 = valid_outlier ? percentile_series(canonical_vol, outlier_win, 0.50) : na

// ============================================================================
// VOLUME CLUSTERING & DENSITY ANALYSIS
// ============================================================================
kde_dens  = valid_clust ? kde_density(canonical_vol, clust_win, clust_bw) : na
hist_dens = valid_clust ? histogram_cluster(canonical_vol, clust_win, hist_bins) : na

cluster_score = switch clust_method
    "KDE Density"       => kde_dens
    "Histogram Binning" => hist_dens
    "KDE + Histogram"   => valid_clust ? (nz(kde_dens) + nz(hist_dens)) / 2.0 : na
    => na

is_cluster = valid_clust and cluster_score > clust_thresh

// Cluster persistence
var int cluster_bars = 0
cluster_bars := is_cluster ? cluster_bars + 1 : 0
is_sustained_cluster = cluster_bars >= 3

// Breakout: volume leaving a dense cluster
was_cluster  = cluster_score[1] > clust_thresh
is_breakout  = valid_clust and was_cluster and not is_cluster and vol_mean_z > 0 and canonical_vol > vol_mean_z * 1.3

// Modal Volume (histogram mode)
modal_vol = 0.0
if valid_clust
    min_val = canonical_vol[0]
    max_val = canonical_vol[0]
    for i = 1 to clust_win - 1
        min_val := math.min(min_val, canonical_vol[i])
        max_val := math.max(max_val, canonical_vol[i])
    r1 = max_val - min_val
    if r1 > 0
        bin_counts = array.new_int(hist_bins, 0)
        for i = 0 to clust_win - 1
            bidx = int(math.min(hist_bins - 1, ((canonical_vol[i] - min_val) / r1) * hist_bins))
            curr = array.get(bin_counts, bidx)
            array.set(bin_counts, bidx, curr + 1)
        max_cnt = 0
        max_idx = 0
        for i = 0 to hist_bins - 1
            cnt = array.get(bin_counts, i)
            if cnt > max_cnt
                max_cnt := cnt
                max_idx := i
        modal_vol := min_val + (float(max_idx) + 0.5) * r1 / float(hist_bins)
    else
        modal_vol := canonical_vol
else
    modal_vol := na

// ============================================================================
// VISUALIZATION
// ============================================================================

// --- Volume Histogram ---
plot(show_vol ? canonical_vol : na, "Volume Per Bar", close >= open ? vol_col_up : vol_col_dn, style=plot.style_histogram)

// --- Volume MA with Glow ---
plot(show_vol_ma ? vol_ma : na, "Volume MA", vol_ma_col, linewidth=2)
plot(show_glow and show_vol_ma ? vol_ma : na, "Volume MA Glow", color.new(vol_ma_col, 75), linewidth=4)

// --- Relative Volume ---
plot(show_rel_vol ? rel_volume : na, "Relative Volume", rel_vol_col, linewidth=2)

// --- Cumulative Volume ---
plot(show_cum_vol and valid_cum ? display_cum_vol : na, "Cumulative Volume", cum_col, linewidth=2)
plot(show_glow and show_cum_vol and valid_cum ? display_cum_vol : na, "Cumulative Vol Glow", color.new(cum_col, 75), linewidth=4)

// --- Volume Delta Histogram ---
plot(show_delta ? bar_delta : na, "Volume Delta", bar_delta >= 0 ? delta_col_buy : delta_col_sell, style=plot.style_histogram)

// --- Cumulative Volume Delta ---
plot(show_cum_delta and valid_delta ? cum_delta_vol : na, "Cumulative Volume Delta", cum_delta_vol >= 0 ? delta_col_buy : delta_col_sell, linewidth=2)
plot(show_glow and show_cum_delta and valid_delta ? cum_delta_vol : na, "Cum Delta Glow", color.new(cum_delta_vol >= 0 ? delta_col_buy : delta_col_sell, 75), linewidth=4)

// --- Modal Volume ---
plot(show_modal and valid_clust ? modal_vol : na, "Modal Volume (Cluster Center)", color.new(#e040fb, 0), linewidth=2)
plot(show_glow and show_modal and valid_clust ? modal_vol : na, "Modal Glow", color.new(#e040fb, 80), linewidth=4)

// --- Regime Backgrounds ---
regime_bg = valid_outlier and show_outliers ? (canonical_vol > vol_p90 ? color.new(#ff8a80, bg_transp) : canonical_vol < vol_p10 ? color.new(#82b1ff, bg_transp) : na) : na
bgcolor(regime_bg, title="Volume Regime (High/Low)")

// --- Outlier Background ---
outlier_bg = is_outlier ? color.new(#d50000, 60) : na
bgcolor(show_outliers ? outlier_bg : na, title="Outlier Alert")

// --- Cluster Background ---
cluster_bg = is_sustained_cluster ? color.new(#69f0ae, bg_transp) : na
bgcolor(show_clusters and show_clust_bg ? cluster_bg : na, title="Sustained Cluster Zone")

// --- Shape Marks ---
plotshape(show_outliers and is_outlier, "Outlier Mark", shape.circle, location.top, color.new(#ff1744, 0), size=size.tiny)
plotshape(show_clusters and is_breakout, "Cluster Breakout", shape.triangleup, location.bottom, color.new(#00e676, 0), size=size.small)

// --- Label Management ---
var int last_label_bar = -9999
label_allowed = bar_index - last_label_bar >= label_freq

if show_labels and show_outliers and is_outlier and label_allowed
    label.new(bar_index, na, "OUTLIER\n" + str.tostring(outlier_score) + "/7", yloc=yloc.abovebar, color=color.new(#ff1744, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
    last_label_bar := bar_index

if show_labels and show_clusters and is_breakout and label_allowed and not is_outlier
    label.new(bar_index, na, "CLUSTER BREAK", yloc=yloc.belowbar, color=color.new(#00e676, 0), textcolor=color.white, style=label.style_label_up, size=size.small)
    last_label_bar := bar_index

// ============================================================================
// DATA WINDOW DEBUG (display=display.none)
// ============================================================================
plot(bar_buy_vol,      "Buy Volume Estimate",   display=display.none)
plot(bar_sell_vol,     "Sell Volume Estimate",  display=display.none)
plot(bar_delta,        "Volume Delta",          display=display.none)
plot(float(bar_subcount), "Intrabar Count",     display=display.none)
plot(z_score,          "Z-Score",               display=display.none)
plot(mod_z,            "Modified Z-Score",      display=display.none)
plot(vol_entropy,      "Volume Entropy",        display=display.none)
plot(wav_score,        "Wavelet Score",         display=display.none)
plot(cluster_score,    "Cluster Density",       display=display.none)
plot(outlier_score,    "Outlier Confluence",    display=display.none)
plot(vol_p50,          "Volume Median",         display=display.none)
````
