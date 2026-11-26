# Fulcrum: volume-weighted average of a two-market ratio

- url: https://www.tradingview.com/script/UTijJdxG-Fulcrum-volume-weighted-average-of-a-two-market-ratio/
- type: indicator
- pine_id: PUB;ff7e7d1352a44176b13e7eba6c600885
- version: 2.0

## Description

A volume-weighted average price computed on the relationship between two markets rather than on a single price, with dispersion bands built from the same weighted pass.

[b]What it does[/b]

Most relative-value work is done by eye: put two markets on one chart, watch the spread, decide when it looks stretched. This computes that judgement. It takes the ratio between two instruments, defaults to the Nasdaq and S&P futures contracts, and runs a volume-weighted average through it with standard deviation bands around that average. It lives in its own pane on its own scale, so the symbol you happen to have loaded is irrelevant to the reading.

[b]What is different here[/b]

Volume-weighted average price, standard deviation bands and ratio charting are all public methodology and I claim none of them. The reason this is one script rather than three is the problem in the middle, which is that a ratio has no volume of its own.

If you divide one market by another, the resulting series has a price and no trade behind it. Every implementation has to decide what to weight by, and most sidestep it by using a simple moving average, which throws away the participation information entirely.

Three specific choices follow from taking that problem seriously.

First, the weight is the geometric mean of both legs' volume rather than either leg alone or their sum. A bar where both markets traded heavily is genuine two-sided participation in the relationship. A bar where one leg was busy and the other was dead is not, and the geometric mean punishes that asymmetry in a way an average does not.

Second, the variance is accumulated in the same volume-weighted pass as the mean, using running sums of weighted value and weighted squared value. The bands therefore describe the dispersion of the ratio as it was actually traded, not the standard deviation of the drawn line. Those two are not the same number and the difference matters most exactly when participation is uneven.

Third, the ratio can be normalised by a volatility and rates term, and that term is frozen at each anchor reset rather than updated daily. This matters more than it sounds. The volatility and rates inputs move once a day, so on any anchor longer than a session the divisor would step in the middle of the window being averaged, and you cannot take a volume-weighted average of a quantity whose units change halfway through: the mean chases the step and the variance ends up describing the divisor instead of the two markets. Freezing it means the unit is constant across the window and the level shift lands exactly where the average restarts anyway. Both inputs are read from the prior session's confirmed close, so the value is identical live and on reload, and when either feed is unavailable the table reports the fallback rather than changing every number on screen silently.

[b]How it works[/b]

The ratio is computed from both legs bar by bar, including a high and low estimate taken from the most and least favourable combination of the two legs' extremes, so the typical price is a real range rather than just the close.

Volume for the weighting is the geometric mean of the two legs. The average, and the variance around it, accumulate from the anchor point using running weighted sums.

The anchor resets on a schedule, and by default that schedule is chosen from your chart: session on intraday timeframes up to twenty minutes, weekly up to four hours, monthly above that. The point is that an anchor should outlive more than a handful of bars, and a session anchor on a four hour chart does not. You can override it if you disagree.

Bands are hidden for the first few bars after each reset, and the distance reading is suppressed along with them. Cumulative dispersion on two or three samples is tiny but not zero, and dividing by it turns a two-basis-point wiggle into a double-digit sigma reading. Until the window has enough behind it to have measured anything, the readout says it is warming up rather than inventing an extension, and the band alerts stay silent.

The ratio line is coloured by which side of the average it sits on, with a small dead zone so that a ratio hugging its average does not strobe the line bar by bar.

[b]How to use it[/b]

Load it on any chart. The pane draws the relationship, not your symbol.

Read the distance in standard deviations rather than the absolute level, which is reported in the table. The absolute number depends on the multiplier and the divisor and means nothing on its own.

The table reports whether both feeds are live, the current average, the current ratio, the distance from the average in percent and in standard deviations, which zone the ratio occupies, and the divisor with a fallback flag if either input is missing. Check the feed status first if the numbers look wrong.

Change the two symbols to compare any pair you like. The scaling multiplier exists to bring the ratio into a readable range and has no effect on the shape.

[b]What it cannot do[/b]

It describes a relationship and not a direction. A stretched ratio tells you the two markets have diverged from how they have recently traded together. It does not tell you which leg corrects, or whether either does, or when. Relationships can stay stretched for as long as the reason for the stretch persists.

Standard deviation bands assume a distribution that ratio spreads do not reliably follow. Two sigma here is a description of the recent sample, not a probability of anything.

Requesting two symbols means depending on two data feeds. If either is unavailable on your plan or a symbol is wrong, the reading is incomplete, which is why the table reports feed status rather than drawing a confident line over missing data.

The volatility and rates divisor falls back to fixed placeholder values when its feeds are missing. Those numbers are arbitrary and they change the scale of everything on screen. The table flags it.

There are no entries, exits or trade marks anywhere in this script, and no performance of any kind is claimed or implied.

[b]On authorship[/b]

The methodology is public and I have said so plainly. The implementation is not borrowed. Every line is written from scratch, and no code in it is copied or adapted from another author's script on this platform or anywhere else.

[b]Settings[/b]

The two ratio symbols and a scaling multiplier; the volatility and rates divisor with its two symbols and an on-off switch; anchor period with an automatic default, band multipliers, band visibility and the post-reset warm-up length; and visual settings for colours, line width, fill, labels, the info table and the extension tint.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
// Fulcrum Elite
//
// A volume-weighted mean of the synchronous relationship between two markets.
// By default it measures 2500 * NQ / ES, optionally normalized by the prior
// confirmed daily closes of VXN and US10Y.
//
// Integrity notes
// - Security requests use gaps_on and lookahead_off. A missing leg is skipped;
//   stale carried-forward bars never enter the ledger.
// - The default sample is the synchronous close ratio. The legacy synthetic
//   HLC sample is optional because NQ high / ES low can combine extremes that
//   did not occur at the same instant.
// - The weighted variance uses an online Welford update, avoiding cancellation
//   error from E[x^2] - E[x]^2.
// - The risk divisor is frozen for the full anchor. If a risk feed is missing,
//   the script either bypasses the adjustment transparently or hides output.
// - Bands require both a minimum observation count and a minimum effective
//   sample size. Effective N exposes domination by a few high-volume bars.
// - Both legs must report volume; the weight is their geometric mean. A leg
//   without volume, such as a cash index, produces no observations.
// - Closed historical values do not repaint. Alerts confirm at bar close.
// =============================================================================

indicator("Fulcrum Elite: two-market ratio VWAP", "Fulcrum", overlay = false,
     format = format.price, precision = 2, max_labels_count = 10)

// =============================================================================
// INPUTS
// =============================================================================
string GRP_RATIO = "Ratio Components"
string numer_symbol = input.symbol("CME_MINI:NQ1!", "Numerator", group = GRP_RATIO)
string denom_symbol = input.symbol("CME_MINI:ES1!", "Denominator", group = GRP_RATIO)
float ratio_multiplier = input.float(2500.0, "Ratio Multiplier", minval = 0.000001,
     group = GRP_RATIO, tooltip = "Default: 2500 * NQ / ES.")
string SAMPLE_CLOSE = "Synchronous Close (Recommended)"
string SAMPLE_HLC = "Synthetic HLC (Legacy)"
string sample_method = input.string(SAMPLE_CLOSE, "Ratio Sample", options = [SAMPLE_CLOSE, SAMPLE_HLC],
     group = GRP_RATIO,
     tooltip = "Synchronous Close never combines non-simultaneous leg extremes. Synthetic HLC is retained only for legacy continuity.")

string GRP_RISK = "Risk Adjustment"
bool use_risk_adjust = input.bool(true, "Apply VXN * US10Y Divisor", group = GRP_RISK)
string vxn_symbol = input.symbol("CBOE_DLY:VXN", "VXN Symbol", group = GRP_RISK)
string us10y_symbol = input.symbol("TVC:US10Y", "US10Y Symbol", group = GRP_RISK)
string MISS_BYPASS = "Use Unadjusted Ratio"
string MISS_HIDE = "Hide Until Next Anchor"
string missing_risk_mode = input.string(MISS_BYPASS, "If Risk Feed Is Missing",
     options = [MISS_BYPASS, MISS_HIDE], group = GRP_RISK,
     tooltip = "No arbitrary placeholder is used. The selected decision is frozen until the next anchor reset.")

string GRP_ENGINE = "Weighted Engine"
string anchor_period = input.string("Auto", "Anchor", options = ["Auto", "Session", "Week", "Month"],
     group = GRP_ENGINE,
     tooltip = "Auto: Session through 20m, Week through 4h, Month above 4h.")
int hide_observations = input.int(3, "Hide Bands For First N Observations", minval = 0, maxval = 100,
     group = GRP_ENGINE)
float min_effective_n = input.float(3.0, "Minimum Effective N For Bands", minval = 2.0,
     maxval = 100.0, step = 0.5, group = GRP_ENGINE,
     tooltip = "Effective N = sum(w)^2 / sum(w^2). It falls when a few bars dominate the volume weighting.")
float sigma_floor_bps = input.float(2.0, "Minimum Dispersion (Basis Points)", minval = 0.0,
     maxval = 100.0, step = 0.5, group = GRP_ENGINE,
     tooltip = "Prevents tiny post-reset dispersion from producing enormous sigma readings.")

string GRP_BANDS = "Bands"
bool show_bands = input.bool(true, "Show Standard Deviation Bands", group = GRP_BANDS)
float band_1_mult = input.float(1.0, "Band 1", minval = 0.25, maxval = 5.0, step = 0.25,
     group = GRP_BANDS)
float band_2_mult = input.float(2.0, "Band 2", minval = 0.5, maxval = 8.0, step = 0.25,
     group = GRP_BANDS)
bool show_fill = input.bool(true, "Fill Inner Band", group = GRP_BANDS)
bool show_ext_bg = input.bool(true, "Tint Beyond Outer Band", group = GRP_BANDS)

string GRP_VIS = "Display"
color vwap_color = input.color(#e3b34c, "VWAP", group = GRP_VIS)
color band_color = input.color(color.new(#7d8793, 45), "Bands", group = GRP_VIS)
color ratio_up_color = input.color(#2fd39a, "Ratio Above VWAP", group = GRP_VIS)
color ratio_dn_color = input.color(#e5484d, "Ratio Below VWAP", group = GRP_VIS)
int line_width = input.int(2, "VWAP Width", minval = 1, maxval = 5, group = GRP_VIS)
bool show_labels = input.bool(true, "Show Last-Value Labels", group = GRP_VIS)
bool show_table = input.bool(true, "Show Dashboard", group = GRP_VIS)
string table_position = input.string(position.top_right, "Dashboard Position",
     options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left], group = GRP_VIS)
string table_size = input.string(size.small, "Dashboard Size",
     options = [size.tiny, size.small, size.normal], group = GRP_VIS)

// =============================================================================
// ANCHOR AND DATA
// =============================================================================
int tf_seconds = nz(timeframe.in_seconds(timeframe.period), 86400)
string auto_anchor = tf_seconds <= 1200 ? "D" : tf_seconds <= 14400 ? "W" : "M"
string anchor_tf = anchor_period == "Session" ? "D" : anchor_period == "Week" ? "W" :
     anchor_period == "Month" ? "M" : auto_anchor

// Anchor detection is evaluated in the numerator's exchange context so the
// chart symbol does not silently determine when this ratio resets.
// The anchor flag is requested as a FLOAT, not a bool. Booleans cannot be na
// in Pine v6, so a bool through gaps_on comes back false on a missing bar and
// a bare `if` would silently skip the reset for the whole period. A float
// comes back na on the gap, and the chart clock stands in for that bar only.
[n_high, n_low, n_close, n_volume, numer_anchor_flag] = request.security(numer_symbol, timeframe.period,
     [high, low, close, volume, timeframe.change(anchor_tf) ? 1.0 : 0.0], gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool new_anchor = na(numer_anchor_flag) ? timeframe.change(anchor_tf) : numer_anchor_flag > 0.5
[d_high, d_low, d_close, d_volume] = request.security(denom_symbol, timeframe.period,
     [high, low, close, volume], gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// Prior confirmed daily values: [1] plus lookahead_on is the documented
// non-repainting higher-timeframe pattern.
float vxn_prior = request.security(vxn_symbol, "D", close[1], gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
float us10y_prior = request.security(us10y_symbol, "D", close[1], gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

bool price_data_ok = not na(n_close) and not na(d_close) and d_close != 0
bool volume_data_ok = not na(n_volume) and not na(d_volume) and n_volume > 0 and d_volume > 0
bool risk_feed_ok = not na(vxn_prior) and not na(us10y_prior) and vxn_prior > 0 and us10y_prior > 0

float risk_divisor_live = not use_risk_adjust ? 1.0 : risk_feed_ok ? vxn_prior * us10y_prior :
     missing_risk_mode == MISS_BYPASS ? 1.0 : na
bool risk_bypassed_live = use_risk_adjust and not risk_feed_ok and missing_risk_mode == MISS_BYPASS

// Freeze the scale for the complete anchor. A separate initialized flag is
// required because na is a valid frozen state under MISS_HIDE.
var bool divisor_initialized = false
var float risk_divisor = na
var bool risk_bypassed = false
if not divisor_initialized or new_anchor
    risk_divisor := risk_divisor_live
    risk_bypassed := risk_bypassed_live
    divisor_initialized := true

f_ratio(float numerator, float denominator, float multiplier, float divisor) =>
    not na(numerator) and not na(denominator) and not na(divisor) and denominator != 0 and divisor > 0 ?
         multiplier * numerator / denominator / divisor : na

float current_ratio = f_ratio(n_close, d_close, ratio_multiplier, risk_divisor)
float synthetic_high = f_ratio(n_high, d_low, ratio_multiplier, risk_divisor)
float synthetic_low = f_ratio(n_low, d_high, ratio_multiplier, risk_divisor)
float ratio_sample = sample_method == SAMPLE_CLOSE ? current_ratio :
     not na(synthetic_high) and not na(synthetic_low) and not na(current_ratio) ?
         (math.max(synthetic_high, synthetic_low) + math.min(synthetic_high, synthetic_low) + current_ratio) / 3.0 : na

float combined_volume = volume_data_ok ? math.sqrt(n_volume * d_volume) : na
bool observation_ok = not na(ratio_sample) and not na(combined_volume) and combined_volume > 0

// =============================================================================
// STABLE WEIGHTED ONLINE MEAN AND VARIANCE
// =============================================================================
var float weight_sum = 0.0
var float weight_sq_sum = 0.0
var float weighted_mean = na
var float weighted_m2 = 0.0
var int observation_count = 0

if new_anchor
    weight_sum := 0.0
    weight_sq_sum := 0.0
    weighted_mean := na
    weighted_m2 := 0.0
    observation_count := 0

if observation_ok
    float weight = combined_volume
    if weight_sum <= 0 or na(weighted_mean)
        weight_sum := weight
        weight_sq_sum := weight * weight
        weighted_mean := ratio_sample
        weighted_m2 := 0.0
        observation_count := 1
    else
        float next_weight_sum = weight_sum + weight
        float delta = ratio_sample - weighted_mean
        weighted_mean += weight / next_weight_sum * delta
        weighted_m2 += weight * delta * (ratio_sample - weighted_mean)
        weight_sum := next_weight_sum
        weight_sq_sum += weight * weight
        observation_count += 1

float final_vwap = weighted_mean
float variance = weight_sum > 0 ? math.max(weighted_m2 / weight_sum, 0.0) : na
float final_stdev = not na(variance) ? math.sqrt(variance) : na
float effective_n = weight_sq_sum > 0 ? weight_sum * weight_sum / weight_sq_sum : 0.0

bool warmup_ok = observation_count > hide_observations and effective_n >= min_effective_n
float stdev_floor = math.abs(nz(final_vwap)) * sigma_floor_bps * 0.0001
bool sigma_usable = warmup_ok and not na(final_stdev) and final_stdev > stdev_floor and final_stdev > 0

float band_1_upper = sigma_usable ? final_vwap + final_stdev * band_1_mult : na
float band_1_lower = sigma_usable ? final_vwap - final_stdev * band_1_mult : na
float band_2_upper = sigma_usable ? final_vwap + final_stdev * band_2_mult : na
float band_2_lower = sigma_usable ? final_vwap - final_stdev * band_2_mult : na

float distance = not na(current_ratio) and not na(final_vwap) ? current_ratio - final_vwap : na
float pct_from_vwap = not na(distance) and final_vwap != 0 ? distance / final_vwap * 100.0 : na
float sigma_distance = sigma_usable ? distance / final_stdev : na

string current_zone = "No sample"
color zone_color = color.gray
if not price_data_ok
    current_zone := "Missing price feed"
    zone_color := color.red
else if not volume_data_ok
    current_zone := "Missing volume"
    zone_color := color.orange
else if use_risk_adjust and na(risk_divisor)
    current_zone := "Risk feed unavailable"
    zone_color := color.red
else if not sigma_usable
    current_zone := "Warming up"
    zone_color := color.gray
else if sigma_distance > band_2_mult
    current_zone := "Beyond +" + str.tostring(band_2_mult, "#.#") + " sigma"
    zone_color := color.red
else if sigma_distance > band_1_mult
    current_zone := "+" + str.tostring(band_1_mult, "#.#") + " to +" + str.tostring(band_2_mult, "#.#") + " sigma"
    zone_color := color.orange
else if sigma_distance >= 0
    current_zone := "Above VWAP"
    zone_color := color.teal
else if sigma_distance > -band_1_mult
    current_zone := "Below VWAP"
    zone_color := color.teal
else if sigma_distance > -band_2_mult
    current_zone := "-" + str.tostring(band_2_mult, "#.#") + " to -" + str.tostring(band_1_mult, "#.#") + " sigma"
    zone_color := color.orange
else
    current_zone := "Beyond -" + str.tostring(band_2_mult, "#.#") + " sigma"
    zone_color := color.red

// =============================================================================
// PLOTS
// =============================================================================
color ratio_color = na(final_vwap) or na(current_ratio) ? color.gray :
     current_ratio >= final_vwap ? ratio_up_color : ratio_dn_color

plot(new_anchor ? na : final_vwap, "Weighted Mean", color = vwap_color, linewidth = line_width,
     style = plot.style_linebr)
plot(current_ratio, "Synchronous Ratio", color = ratio_color, linewidth = 2)

p_b1u = plot(show_bands and sigma_usable ? band_1_upper : na, "Upper Band 1", color = band_color)
p_b1l = plot(show_bands and sigma_usable ? band_1_lower : na, "Lower Band 1", color = band_color)
plot(show_bands and sigma_usable ? band_2_upper : na, "Upper Band 2",
     color = color.new(band_color, 35), style = plot.style_circles)
plot(show_bands and sigma_usable ? band_2_lower : na, "Lower Band 2",
     color = color.new(band_color, 35), style = plot.style_circles)
fill(p_b1u, p_b1l, color = show_fill and show_bands and sigma_usable ? color.new(vwap_color, 90) : na,
     title = "Inner Band Fill")
bgcolor(show_ext_bg and sigma_usable and math.abs(sigma_distance) > band_2_mult ?
     color.new(sigma_distance > 0 ? #ef5350 : #26a69a, 90) : na, title = "Extension Tint")

// Persistent last-value labels: update in place, never allocate per tick.
var label vwap_label = na
var label upper_label = na
var label lower_label = na

if barstate.islast
    bool can_label = show_labels and not na(final_vwap)
    if can_label
        if na(vwap_label)
            vwap_label := label.new(bar_index + 3, final_vwap, "", style = label.style_label_left,
                 color = color.new(vwap_color, 30), textcolor = color.white, size = size.small)
        label.set_xy(vwap_label, bar_index + 3, final_vwap)
        label.set_text(vwap_label, "VWAP " + str.tostring(final_vwap, "#.00"))
        label.set_color(vwap_label, color.new(vwap_color, 30))
    else if not na(vwap_label)
        label.delete(vwap_label)
        vwap_label := na

    bool can_band_label = can_label and show_bands and sigma_usable
    if can_band_label
        if na(upper_label)
            upper_label := label.new(bar_index + 3, band_1_upper, "", style = label.style_label_left,
                 color = color.new(band_color, 45), textcolor = color.white, size = size.tiny)
        if na(lower_label)
            lower_label := label.new(bar_index + 3, band_1_lower, "", style = label.style_label_left,
                 color = color.new(band_color, 45), textcolor = color.white, size = size.tiny)
        label.set_xy(upper_label, bar_index + 3, band_1_upper)
        label.set_text(upper_label, "+1 sigma " + str.tostring(band_1_upper, "#.00"))
        label.set_xy(lower_label, bar_index + 3, band_1_lower)
        label.set_text(lower_label, "-1 sigma " + str.tostring(band_1_lower, "#.00"))
    else
        if not na(upper_label)
            label.delete(upper_label)
            upper_label := na
        if not na(lower_label)
            label.delete(lower_label)
            lower_label := na

// =============================================================================
// DASHBOARD
// =============================================================================
var table dashboard = table.new(table_position, 2, 9, bgcolor = color.new(#0d1117, 8),
     border_color = color.new(#6e7681, 65), border_width = 1)

f_number(float value, string pattern) =>
    na(value) ? "-" : str.tostring(value, pattern)

f_signed(float value, string pattern) =>
    na(value) ? "-" : (value >= 0 ? "+" : "") + str.tostring(value, pattern)

if barstate.islast and show_table
    string feed_state = not price_data_ok ? "price missing" : not volume_data_ok ? "volume missing" :
         use_risk_adjust and na(risk_divisor) ? "risk missing" : risk_bypassed ? "risk bypassed" : "ready"
    color feed_color = feed_state == "ready" ? color.lime : feed_state == "risk bypassed" ? color.orange : color.red
    color distance_color = na(distance) ? color.gray : distance >= 0 ? ratio_up_color : ratio_dn_color
    string divisor_state = not use_risk_adjust ? "off" : na(risk_divisor) ? "hidden" :
         f_number(risk_divisor, "#.00") + (risk_bypassed ? " (bypass)" : "")

    table.cell(dashboard, 0, 0, "Ratio engine", text_color = color.white, bgcolor = #161b22, text_size = table_size)
    table.cell(dashboard, 1, 0, feed_state, text_color = feed_color, bgcolor = #161b22, text_size = table_size)
    table.cell(dashboard, 0, 1, "Ratio", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 1, f_number(current_ratio, "#.00"), text_color = color.white, text_size = table_size)
    table.cell(dashboard, 0, 2, "Weighted mean", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 2, f_number(final_vwap, "#.00"), text_color = vwap_color, text_size = table_size)
    table.cell(dashboard, 0, 3, "From mean", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 3, f_signed(pct_from_vwap, "#.00") + (na(pct_from_vwap) ? "" : "%"),
         text_color = distance_color, text_size = table_size)
    table.cell(dashboard, 0, 4, "Sigma", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 4, f_signed(sigma_distance, "#.00"), text_color = distance_color, text_size = table_size)
    table.cell(dashboard, 0, 5, "Zone", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 5, current_zone, text_color = zone_color, text_size = table_size)
    table.cell(dashboard, 0, 6, "Sample", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 6, str.tostring(observation_count) + " obs / " + f_number(effective_n, "#.0") + " eff",
         text_color = warmup_ok ? color.white : color.gray, text_size = table_size,
         tooltip = "Effective N discounts concentration from unusually large weights.")
    table.cell(dashboard, 0, 7, "Method", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 7, sample_method == SAMPLE_CLOSE ? "sync close" : "synthetic HLC",
         text_color = sample_method == SAMPLE_CLOSE ? color.lime : color.orange, text_size = table_size)
    table.cell(dashboard, 0, 8, "Divisor", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 8, divisor_state, text_color = risk_bypassed ? color.orange : color.gray, text_size = table_size)

// =============================================================================
// CONFIRMED-BAR ALERTS
// =============================================================================
bool confirmed = barstate.isconfirmed
bool cross_above_mean = ta.crossover(current_ratio, final_vwap)
bool cross_below_mean = ta.crossunder(current_ratio, final_vwap)
bool cross_above_band_1 = ta.crossover(current_ratio, band_1_upper)
bool cross_below_band_1 = ta.crossunder(current_ratio, band_1_lower)
bool cross_above_band_2 = ta.crossover(current_ratio, band_2_upper)
bool cross_below_band_2 = ta.crossunder(current_ratio, band_2_lower)
alertcondition(confirmed and cross_above_mean, "Ratio Cross Above VWAP", "Ratio crossed above its weighted mean")
alertcondition(confirmed and cross_below_mean, "Ratio Cross Below VWAP", "Ratio crossed below its weighted mean")
alertcondition(confirmed and sigma_usable and cross_above_band_1, "Ratio Cross Above +1 Sigma", "Ratio crossed above the inner upper band")
alertcondition(confirmed and sigma_usable and cross_below_band_1, "Ratio Cross Below -1 Sigma", "Ratio crossed below the inner lower band")
alertcondition(confirmed and sigma_usable and cross_above_band_2, "Ratio Cross Above +2 Sigma", "Ratio crossed above the outer upper band")
alertcondition(confirmed and sigma_usable and cross_below_band_2, "Ratio Cross Below -2 Sigma", "Ratio crossed below the outer lower band")
````
