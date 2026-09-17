<!-- tradingview-pine-id: PUB;4939fa32e0134959ad37483eab697f14 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Composite Index-L (Momentum Lifecycle)

Source: https://www.tradingview.com/script/vEKl7VJy-Composite-Index-L-Momentum-Lifecycle/

## Description

Composite Index-L (Momentum Lifecycle)

█ OVERVIEW

Composite Index-L plots Constance Brown's Composite Index in a separate pane, zero-centered, and restates it inside the momentum lifecycle framework that Alex Spiroglou developed for the MACD-V. The thesis in one sentence: because the Composite Index is built entirely from RSI values it is already normalized across symbols and across time, so it can carry objective momentum bands and a color-coded lifecycle state machine without any volatility division.

The script draws the centered Composite Index with lifecycle state colors, a 13-period signal average, a 33-period slow average, adjustable neutral and risk bands, automatic pivot-based divergence lines against price, and an optional second divergence engine based on regression slope disagreement between the Composite Index and the 14-period RSI.

█ HISTORY / BACKGROUND

The Composite Index was created by Constance Brown and is documented in "Technical Analysis for the Trading Professional" and "The Composite Index". It adds the 9-bar momentum of the 14-period RSI to a 3-bar average of the 3-period RSI. The momentum term lets the indicator register thrust that the bounded RSI compresses, which is why Brown used it primarily to expose divergences that the RSI itself fails to show. A widely used public Pine implementation of the Composite Index was published on TradingView by LazyBear, and that implementation is the ancestor of the base calculation used here. Credit for the original Composite Index concept and formula belongs to Constance Brown, and credit for the original public Pine version belongs to LazyBear.

The lifecycle framework comes from the MACD-V work of Alex Spiroglou (TradingView user AlexSpiroglou), who normalized the MACD by average true range and then defined objective ranges, range rules, and a momentum lifecycle map on the normalized values. This script does not copy the MACD-V calculation. It ports the framework: fitted bands, named momentum states, a ranging detector, and state persistence.

The design decision that joins the two: the MACD needs ATR division because it is denominated in price. The Composite Index is denominated in RSI points, which are dimensionless, so the normalization step is unnecessary and would be dimensionally wrong. What the Composite Index lacked was the framework layer, and that is what this script adds.

█ HOW IT WORKS

Step 1. Compute RSI(source, 14). Take its 9-bar momentum. Compute RSI(source, 3) and smooth it with a 3-bar simple moving average.

Step 2. Add the two terms and subtract 50. The momentum term is naturally centered at zero and the smoothed fast RSI is centered near 50, so the subtraction centers the whole indicator on a zero equilibrium line. Shapes and crossings are identical to the classic Composite Index; only the axis shifts.

Step 3. Compute the signal line as a 13-bar simple moving average of the centered value, and a slow context line as a 33-bar simple moving average. These are Brown's original averages.

Step 4. Classify every bar into a lifecycle state using the band inputs and the signal line. Above the risk band with a minimum number of consecutive bars beyond it: Risk, colored blue. Between the neutral band and the risk band while above the signal line: Rallying, dark teal. Below the neutral band while above the signal line: Rebounding, green. The mirror states below the signal line are Retracing (orange) and Rundown (red), with a confirmed oversold Risk state in blue. When the value stays inside the neutral band for a set number of consecutive bars the line turns gray to mark a Ranging market. When the value equals the signal line exactly the previous state is held.

Step 5. Detect pivot divergences. An oscillator pivot requires 9 bars of dominance on the left and 5 confirmation bars on the right. Two consecutive pivots must be at least 9 and at most 50 bars apart. A bullish divergence is a lower low in price with a higher low in the oscillator; a bearish divergence is a higher high in price with a lower high in the oscillator. Price is measured on closes by default, per Brown, with an option to use highs and lows instead. Confirmed divergences are drawn as lines connecting the two oscillator pivots. A line is solid when its starting pivot sits beyond the risk band and dotted when the starting pivot sits inside it.

Step 6. Optionally run the second divergence engine. It fits a 6-bar linear regression to the centered Composite Index and another to the 14-period RSI and compares their slopes. Composite slope up while RSI slope is down is a positive divergence; the inverse is a negative divergence. The condition persists while the slopes continue to disagree. An optional dead band suppresses the condition while the indicator is near zero. A percent-swing tracker (9 percent retracement with a 3-bar minimum reversal) timestamps price swings; a divergence that begins within 2 bars of the latest confirmed swing pivot is marked with a solid triangle, later onsets with a faded triangle.

█ HOW TO USE

The band defaults were fitted on daily data, so the daily timeframe is the reference resolution. The script runs on any timeframe, but distributions differ across resolutions, and the band inputs exist so you can refit them to your own market and timeframe.

Reading the main line. The line color is the current momentum state. Green family colors mean the indicator is above its signal line: dark teal (Rallying) means momentum is strong and rising, plain green (Rebounding) means momentum is recovering from below the neutral band. Warm colors mean the indicator is below its signal line: orange (Retracing) means a pullback from strength, red (Rundown) means downside momentum between the neutral and risk bands. Blue means Risk: the indicator has spent several consecutive bars beyond the risk band, the zone where moves have historically been overstretched. Gray means the market has been stuck inside the neutral band for many bars and is ranging; treat directional signals with less weight there.

Reading the bands. The inner lines are the neutral band. Inside them, directional conviction is low. The outer lines are the risk band. Beyond them, momentum is stretched relative to its fitted distribution. Because the Risk state requires persistence, a single one-bar spike beyond the band keeps its trend color and only a sustained excursion turns blue.

Reading the averages. The blue signal line is the crossover reference for the state machine. The lavender slow average shows the larger momentum backdrop; the indicator holding above a rising slow average is a stronger backdrop than the same reading below a falling one.

Reading the pivot divergence lines. A white line connecting two oscillator pivots means the oscillator disagreed with price across those two swings. Solid lines start from beyond the risk band and mark divergences that originate at an extreme. Dotted lines start inside the bands and mark Brown's mid-range class. The line appears 5 bars after the second pivot because pivots need right-side confirmation; the line is drawn back to the true pivot positions. Optional Bull and Bear labels can be enabled at the confirming pivot.

Reading the thesis engine, when enabled. Green background shading means the Composite Index is rising while the RSI is falling over the regression window, a positive divergence; red shading is the negative case. A triangle marks the first bar of each episode. A solid triangle means the episode began close to a fresh confirmed price swing, which is the timely case; a faded triangle means the onset came later.

Alerts. Seven alert conditions are available: confirmed overbought Risk, confirmed oversold Risk, signal line cross, bullish pivot divergence, bearish pivot divergence, thesis buy onset, and thesis sell onset. All fire on confirmed conditions.

█ SETTINGS

Composite Index group
• Source: input series, default close.
• RSI Length: main RSI period, default 14.
• RSI Momentum Length: momentum lookback on the main RSI, default 9.
• Fast RSI Length: short RSI period, default 3.
• Fast RSI Smoothing (SMA): average applied to the short RSI, default 3.
• Signal / Fast Average Length: signal line period, default 13.
• Slow Average Length: slow context line period, default 33.

Lifecycle group
• Neutral Band (+/-): inner band level, default 25. Roughly half of daily readings fell inside this band in the fitting sample.
• Risk Band (+/-): outer band level, default 55. The fitted 95 percent coverage level was 60; the default of 55 trades a wider tail for earlier warning.
• Ranging Bars: consecutive bars inside the neutral band before the gray Ranging state, default 20.
• Risk Persistence (bars): consecutive bars beyond the risk band required to confirm the Risk state, default 3. A value of 1 restores classic single-bar behavior.

Style group
• Lifecycle Colors: on by default. Off plots the indicator as a plain yellow line while the bands, states, and alerts keep working.

Divergence (Pivot) group
• Show Pivot Divergences: master toggle for detection display, default on.
• Show Extreme-Origin Lines (Solid): visibility of divergence lines starting beyond the risk band, default on.
• Show Mid-Range Lines (Dotted): visibility of divergence lines starting inside the risk band, default on.
• Use Close for Price Pivots (Brown): price basis on closes, default on. Off compares bar highs and lows.
• Pivot Lookback Left: left dominance bars for an oscillator pivot, default 9.
• Pivot Lookback Right: right confirmation bars, default 5.
• Max Bars Between Pivots: upper spacing limit for a valid pair, default 50.
• Min Bars Between Pivots: lower spacing limit, default 9.
• Divergence Labels: Bull and Bear markers at the confirming pivot, default off.
• Divergence Line Color: default white.

Divergence (Thesis) group
• Show Thesis Divergences: master toggle, default off.
• Regression Bars: linear regression window, default 6.
• Dead-Band Reset: suppresses the signal while the indicator is near zero, default off.
• Dead-Band (+/-): the suppression band level, default 10.
• Swing Retracement %: reversal threshold of the percent-swing tracker, default 9.0. Reduce on lower-volatility instruments so the swing degree matches.
• Swing Reversal Bars (min): minimum bars from the swing extreme before a reversal can confirm, default 3.
• Timely Proximity (bars): maximum distance from the latest confirmed swing pivot for a solid onset marker, default 2.

█ WHAT MAKES IT ORIGINAL

The script is not a restyled Composite Index and not a MACD-V clone. The original contribution is the transfer of a normalized-momentum framework onto an indicator that is normalized by construction rather than by division. Specifically: the Composite Index is zero-centered so that symmetric bands are meaningful; band levels are treated as distribution statistics with stated coverage targets rather than arbitrary lines; a six-state lifecycle machine with an explicit ranging detector and a persistence requirement classifies every bar; the persistence requirement addresses a structural property of the Composite Index, which reverts from extremes within a few bars and would otherwise flood a threshold with one-bar events; pivot divergences follow Brown's own doctrine (close basis, spacing tied to the momentum window) and are classified by the location of their origin pivot relative to the risk band; and a second, independent divergence definition from Brown's later research, slope disagreement against the RSI rather than against price, is implemented alongside the classic pivot method with a swing-proximity quality flag.

█ NOTES / LIMITATIONS

• The indicator plots in a separate pane, not on the chart.
• Values are na until the longest lookback is filled. Symbols with very short history will show a late-starting or empty plot.
• A pivot divergence cannot exist before its confirming pivot. With the default right lookback of 5, the line appears 5 bars after the oscillator pivot and is drawn back to it. Once drawn, lines do not repaint.
• The thesis-mode timeliness flag depends on a swing pivot that only confirms after the reversal completes, so a faded onset marker can upgrade to solid on the live bar. The divergence condition itself does not look ahead.
• On the live bar all states and conditions follow the current price and settle at bar close, standard Pine behavior.
• Divergence lines are capped at 500 objects; on very long histories the oldest lines are dropped.
• The band defaults were fitted on daily data from a broad equity sample and a volatility index. Other timeframes and asset classes work, but their distributions differ, and the bands are exposed as inputs so they can be refitted.
• The script uses no higher-timeframe requests and no lookahead.

---

## Source Code

````pine
//@version=6
// Constance Brown Composite Index, restated in the MACD-V Momentum Lifecycle framework.
// The composite is zero-centered (rsisma is centered at 50; rsidelta is already 0-centered)
// so the symmetric band / state logic from MACD-V maps directly. No ATR division: the
// composite lives in RSI space (dimensionless), so Spiroglou's Limitations 1 & 2 do not
// apply. What this ports is Limitation 3's remedy: objective bands + the lifecycle
// state machine (Risk / Rallying / Ranging / Retracing / Rundown / Rebounding),
// including the three fixes from macd-v_corrected_3 (no floor on Rebounding, exact
// val == sign fallthrough only, ranging grayout after N consecutive bars).
//
// Pivot divergence per Brown doctrine (TATP 2e Ch.8, 32nd Jewel Ch.5):
//  - Price basis CLOSE, not high/low. Min separation 9 (RSIMO9 window). Max 50
//    (~1.5x the 33 slow average). Lookbacks L9/R5.
//  - Line style encodes the starting pivot's location: SOLID when the divergence
//    starts beyond the Risk band (bear start >= +Risk, bull start <= -Risk),
//    DOTTED when it starts inside the band (Brown's mid-range signal class).
//    Each line class has its own visibility toggle; detection and alerts are
//    unaffected by the toggles.
//
// Thesis mode per Brown, "The Composite Index: A Divergence Analysis Study" (MFTA, Oct
// 2015, aeroinvest.com/COMPOSITE_INDEX.pdf):
//  - Divergence = 6-bar linear regression slope disagreement between the Composite and
//    the 14-period RSI (NOT oscillator vs price). Buy = Composite slope up, RSI slope
//    down. Sell = inverse. The regression window is her stated minimum; the signal
//    persists while slopes continue to disagree.
//  - Optional dead-band reset (her DJIA-only filter): raw composite 40-60 = +/-10
//    zero-centered; values inside the band suppress the signal, capping divergence age.
//  - Timeliness flag: her spec requires the signal within 2 bars of a new price swing
//    (Percent Swing Overlay: 9% retracement + 3-bar minimum reversal). Ported as a
//    quality flag, not a hard filter: solid marker = timely, faded = late. The swing
//    pivot only confirms after the reversal completes, so real-time flags can upgrade.
indicator("Composite Index-L (Momentum Lifecycle)", "CB Comp-L", overlay = false, max_lines_count = 500)

// SETTINGS: Composite Index (per Brown) {
src            = input.source(close, "Source")
rsi_length     = input.int(14, "RSI Length", minval = 1)
rsi_mom_length = input.int(9, "RSI Momentum Length", minval = 1)
rsi_ma_length  = input.int(3, "Fast RSI Length", minval = 1)
ma_length      = input.int(3, "Fast RSI Smoothing (SMA)", minval = 1)
fastLength     = input.int(13, "Signal / Fast Average Length", minval = 1)
slowLength     = input.int(33, "Slow Average Length", minval = 1)
// }

// SETTINGS: Lifecycle bands {
i_neutral = input.float(25, "Neutral Band (+/-)", minval = 1, group = "Lifecycle",
     tooltip = "Equivalent of MACD-V's +/-50. Fitted: ~52% of daily bars fall inside +/-25 (same sample).")
i_risk    = input.float(55, "Risk Band (+/-)", minval = 1, group = "Lifecycle",
     tooltip = "Equivalent of MACD-V's +/-150. Fitted 95% coverage sits at +/-60 (498 US equities 2013-2018, VIX 1990-); +/-55 trades to ~8% outside for earlier warning.")
i_range_n = input.int(20, "Ranging Bars", minval = 1, group = "Lifecycle")
i_persist = input.int(3, "Risk Persistence (bars)", minval = 1, group = "Lifecycle",
     tooltip = "Consecutive bars beyond the risk band required to confirm the Risk state. Filters the composite's 1-2 bar spikes; 1 = classic behavior.")
// }

// SETTINGS: Style {
i_use_colors = input.bool(true, "Lifecycle Colors", group = "Style",
     tooltip = "Off = plain yellow line. Bands and state logic unaffected.")
// }

// SETTINGS: Divergence (pivot mode) {
i_div   = input.bool(true, "Show Pivot Divergences", group = "Divergence (Pivot)")
i_div_solid  = input.bool(true, "Show Extreme-Origin Lines (Solid)", group = "Divergence (Pivot)",
     tooltip = "Divergence lines whose starting composite pivot is beyond the Risk band. Visibility only; detection, labels, and alerts unaffected.")
i_div_dotted = input.bool(true, "Show Mid-Range Lines (Dotted)", group = "Divergence (Pivot)",
     tooltip = "Divergence lines whose starting composite pivot is inside the Risk band (Brown's preferred mid-range class). Visibility only; detection, labels, and alerts unaffected.")
i_close = input.bool(true, "Use Close for Price Pivots (Brown)", group = "Divergence (Pivot)",
     tooltip = "Brown defines divergence on closing price, not the bar high/low. Off = classic high/low comparison.")
i_lbL   = input.int(9, "Pivot Lookback Left", minval = 1, group = "Divergence (Pivot)",
     tooltip = "9 = the RSI momentum window. The oscillator pivot must dominate a full momentum cycle on the left side.")
i_lbR   = input.int(5, "Pivot Lookback Right", minval = 1, group = "Divergence (Pivot)",
     tooltip = "Confirmation bars. Lag is acceptable: per Brown the divergence leads the final price extreme by a swing.")
i_rng_u = input.int(50, "Max Bars Between Pivots", minval = 2, group = "Divergence (Pivot)",
     tooltip = "~1.5x the 33-period slow average. Pivots further apart belong to different wave degrees.")
i_rng_l = input.int(9, "Min Bars Between Pivots", minval = 1, group = "Divergence (Pivot)",
     tooltip = "= RSI Momentum Length. Pivots closer than the momentum window are the same momentum event sampled twice.")
i_div_lbl = input.bool(false, "Divergence Labels", group = "Divergence (Pivot)")
i_div_col = input.color(color.white, "Divergence Line Color", group = "Divergence (Pivot)")
// }

// SETTINGS: Divergence (thesis mode) {
i_th      = input.bool(false, "Show Thesis Divergences", group = "Divergence (Thesis)",
     tooltip = "Brown's MFTA computer test: 6-bar linear regression slope disagreement between the Composite and the 14-period RSI. Independent of the pivot detector.")
i_th_len  = input.int(6, "Regression Bars", minval = 3, group = "Divergence (Thesis)",
     tooltip = "Her stated minimum. The signal elongates while the slope disagreement continues.")
i_th_band_on = input.bool(false, "Dead-Band Reset", group = "Divergence (Thesis)",
     tooltip = "Her DJIA-only filter: composite values inside the band suppress the signal, capping exceptionally long divergences. Raw 40-60 = +/-10 zero-centered.")
i_th_band = input.float(10, "Dead-Band (+/-)", minval = 1, group = "Divergence (Thesis)")
i_th_pct  = input.float(9.0, "Swing Retracement %", minval = 0.5, step = 0.5, group = "Divergence (Thesis)",
     tooltip = "Percent Swing Overlay reversal threshold. 9.0 is her 2-month equity setting; for daily CL1! consider 4-6 to match swing degree.")
i_th_bars = input.int(3, "Swing Reversal Bars (min)", minval = 1, group = "Divergence (Thesis)",
     tooltip = "Minimum bars since the swing extreme before a reversal can confirm. Her equity setting = 3; bonds = 1.")
i_th_prox = input.int(2, "Timely Proximity (bars)", minval = 0, group = "Divergence (Thesis)",
     tooltip = "Signal onset within this many bars of the last confirmed swing pivot = timely (solid marker). Later = faded marker. Her spec marks later signals failed.")
// }

// COMPOSITE {
rsi14    = ta.rsi(src, rsi_length)
rsidelta = ta.mom(rsi14, rsi_mom_length)
rsisma   = ta.sma(ta.rsi(src, rsi_ma_length), ma_length)

val  = rsidelta + rsisma - 50        // zero-centered composite
sign = ta.sma(val, fastLength)       // Brown's 13 SMA doubles as the signal line
slow = ta.sma(val, slowLength)
// }

// LIFECYCLE STATE MACHINE (mirrors macd-v_corrected_3) {
in_range    = i_neutral > val and val > -i_neutral
in_range_bs = ta.barssince(in_range and not in_range[1])

// Consecutive-bar run lengths beyond each risk band
ob_run = ta.barssince(val < i_risk)
os_run = ta.barssince(val > -i_risk)
ob_conf = val >= i_risk and ob_run >= i_persist
os_conf = val <= -i_risk and os_run >= i_persist

var color mcol = na
mcol := switch
    in_range and in_range_bs >= i_range_n - 1 => color.gray   // Ranging
    ob_conf and val > sign                    => color.blue   // Risk (overbought, confirmed)
    val >= i_neutral and val > sign           => #0d6b57      // Rallying (incl. unconfirmed OB)
    val > sign                                => color.green  // Rebounding (no floor, per Fix 1)
    os_conf and val < sign                    => color.blue   // Risk (oversold, confirmed)
    val <= -i_neutral and val < sign          => color.red    // Rundown (incl. unconfirmed OS)
    val < sign                                => color.orange // Retracing
    =>                                           mcol         // val == sign only: hold state (Fix 2)
// }

// DIVERGENCE, PIVOT MODE (regular, oscillator vs price; price basis per Brown = close) {
p_lo = i_close ? close : low
p_hi = i_close ? close : high

plFound = not na(ta.pivotlow(val, i_lbL, i_lbR))
phFound = not na(ta.pivothigh(val, i_lbL, i_lbR))

_inRange(cond) =>
    bars = ta.barssince(cond)
    i_rng_l <= bars and bars <= i_rng_u

// Prior pivot coordinates (occurrence 1 = the divergence line's starting pivot)
prevPlBar = ta.valuewhen(plFound, bar_index - i_lbR, 1)
prevPlVal = ta.valuewhen(plFound, val[i_lbR], 1)
prevPhBar = ta.valuewhen(phFound, bar_index - i_lbR, 1)
prevPhVal = ta.valuewhen(phFound, val[i_lbR], 1)

// Bullish: price lower low (on close), composite higher low
oscHL    = val[i_lbR] > prevPlVal and _inRange(plFound[1])
priceLL  = p_lo[i_lbR] < ta.valuewhen(plFound, p_lo[i_lbR], 1)
bullCond = i_div and priceLL and oscHL and plFound

// Bearish: price higher high (on close), composite lower high
oscLH    = val[i_lbR] < prevPhVal and _inRange(phFound[1])
priceHH  = p_hi[i_lbR] > ta.valuewhen(phFound, p_hi[i_lbR], 1)
bearCond = i_div and priceHH and oscLH and phFound

// Divergence lines: pivot-to-pivot on the composite. SOLID = starting pivot beyond
// the Risk band (extreme-origin divergence); DOTTED = starting pivot inside it.
// Per-class visibility toggles gate drawing only.
if bullCond
    bool bullExtreme = prevPlVal <= -i_risk
    if bullExtreme ? i_div_solid : i_div_dotted
        line.new(prevPlBar, prevPlVal, bar_index - i_lbR, val[i_lbR],
             color = i_div_col, width = 2,
             style = bullExtreme ? line.style_solid : line.style_dotted)
if bearCond
    bool bearExtreme = prevPhVal >= i_risk
    if bearExtreme ? i_div_solid : i_div_dotted
        line.new(prevPhBar, prevPhVal, bar_index - i_lbR, val[i_lbR],
             color = i_div_col, width = 2,
             style = bearExtreme ? line.style_solid : line.style_dotted)
// }

// DIVERGENCE, THESIS MODE (6-bar linreg slope, Composite vs 14-RSI) {
// Percent Swing Overlay (PCSC port): tracks the running extreme; a reversal confirms
// when price retraces i_th_pct% from the extreme AND at least i_th_bars have passed
// since the extreme. The confirmed extreme becomes the swing pivot.
var int   sw_dir  = 0
var float sw_ext  = na
var int   sw_extb = 0
var int   sw_pivb = -1

if sw_dir == 0
    sw_dir  := 1
    sw_ext  := high
    sw_extb := bar_index
else if sw_dir == 1
    if high >= sw_ext
        sw_ext  := high
        sw_extb := bar_index
    else if low <= sw_ext * (1 - i_th_pct / 100) and bar_index - sw_extb >= i_th_bars
        sw_dir  := -1
        sw_pivb := sw_extb
        sw_ext  := low
        sw_extb := bar_index
else
    if low <= sw_ext
        sw_ext  := low
        sw_extb := bar_index
    else if high >= sw_ext * (1 + i_th_pct / 100) and bar_index - sw_extb >= i_th_bars
        sw_dir  := 1
        sw_pivb := sw_extb
        sw_ext  := high
        sw_extb := bar_index

// Regression slopes (last-point slope of the fitted line over i_th_len bars)
cSlope = ta.linreg(val, i_th_len, 0) - ta.linreg(val, i_th_len, 1)
rSlope = ta.linreg(rsi14, i_th_len, 0) - ta.linreg(rsi14, i_th_len, 1)

band_ok = not i_th_band_on or math.abs(val) >= i_th_band

th_buy  = i_th and cSlope > 0 and rSlope < 0 and band_ok   // Composite positive divergence to RSI
th_sell = i_th and cSlope < 0 and rSlope > 0 and band_ok   // Composite negative divergence to RSI

th_buy_on  = th_buy and not th_buy[1]
th_sell_on = th_sell and not th_sell[1]

th_timely = sw_pivb >= 0 and bar_index - sw_pivb <= i_th_prox
// }

// OUTPUTS {
plot(val, "Composite-L", i_use_colors ? mcol : color.yellow, 3)
plot(sign, "Signal (13 SMA)", color.new(color.rgb(70, 121, 231), 1), 2)
plot(slow, "Slow (33 SMA)", #E1BEE7, 2)

hline(0, "0", color.new(chart.fg_color, 50), hline.style_dotted)
plot(i_neutral, "Neutral +", color.new(color.rgb(12, 240, 42), 60), 1)
plot(-i_neutral, "Neutral -", color.new(color.red, 60), 1)
plot(i_risk, "Risk +", color.new(color.red, 30), 2)
plot(-i_risk, "Risk -", color.new(color.rgb(12, 240, 42), 30), 2)

// Pivot divergence labels (lines are drawn via line.new above)
plotshape(i_div_lbl and bullCond ? val[i_lbR] : na, "Bull Label", shape.labelup, location.absolute, color.green, -i_lbR, "Bull", color.white, size = size.tiny)
plotshape(i_div_lbl and bearCond ? val[i_lbR] : na, "Bear Label", shape.labeldown, location.absolute, #ED4C67, -i_lbR, "Bear", color.white, size = size.tiny)

// Thesis divergence: shading while the slope disagreement persists, marker at onset.
// Solid marker = onset within i_th_prox bars of the last confirmed swing pivot.
bgcolor(th_buy ? color.new(color.green, 92) : th_sell ? color.new(color.red, 92) : na, title = "Thesis Divergence Shading")
plotshape(th_buy_on, "Thesis Buy", shape.triangleup, location.bottom, th_timely ? color.lime : color.new(color.lime, 65), size = size.tiny)
plotshape(th_sell_on, "Thesis Sell", shape.triangledown, location.top, th_timely ? #ED4C67 : color.new(#ED4C67, 65), size = size.tiny)
// }

// ALERTS {
alertcondition(ob_conf and not ob_conf[1], "Risk Confirmed (OB)", "Composite-L overbought risk confirmed")
alertcondition(os_conf and not os_conf[1], "Risk Confirmed (OS)", "Composite-L oversold risk confirmed")
alertcondition(ta.cross(val, sign), "Signal Cross", "Composite-L crossed its signal line")
alertcondition(bullCond, "Bullish Divergence (Pivot)", "Composite-L bullish pivot divergence vs price")
alertcondition(bearCond, "Bearish Divergence (Pivot)", "Composite-L bearish pivot divergence vs price")
alertcondition(th_buy_on, "Thesis Buy Onset", "Composite-L positive divergence to RSI (thesis mode)")
alertcondition(th_sell_on, "Thesis Sell Onset", "Composite-L negative divergence to RSI (thesis mode)")
// }
````
