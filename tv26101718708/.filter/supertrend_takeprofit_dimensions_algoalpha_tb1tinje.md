# SuperTrend Take-Profit Dimensions [AlgoAlpha]

- url: https://www.tradingview.com/script/tb1TiNJe-SuperTrend-Take-Profit-Dimensions-AlgoAlpha/
- type: indicator
- pine_id: PUB;30650809cb1e4c61bab014dd1e5323f5
- version: 2.0

## Description

🟠 OVERVIEW

A [b]multi-dimensional take-profit aid[/b] that scores how typical the current bar looks compared to past SuperTrend pivots, so you can tell when a trend has reached favorable exit conditions.

The indicator runs a standard [b]SuperTrend[/b] and records every confirmed zigzag pivot that occurs during a matching-direction run. Tops go into a [b]bull pool[/b], bottoms into a [b]bear pool[/b]. Each pivot is stored as a set of readings across several independent axes, such as [i]relative volume[/i], [i]time of day[/i], and [i]price position inside the recent range[/i].

On every bar, the current reading on each axis is compared to that historical pool. A [b]blended score from 0 to 100[/b] tells you how closely the current conditions resemble where past pivots in the same direction have clustered. The idea is to give trend followers a data-backed sense of when to start tightening up, rather than guessing an exit or using a fixed R-multiple.

The three built-in axes were chosen deliberately to be [b]as uncorrelated as possible[/b], each describing a different dimension of market context: [b]volume[/b] (relative volume percentile), [b]time[/b] (time of day), and [b]price[/b] (position in recent range). Correlated inputs would double-count the same information and distort the blended score; picking axes that describe genuinely different aspects of the market means each one contributes independent evidence, and the score reflects how many distinct dimensions are currently in agreement.

🟠 CONCEPTS

[list]
[*] [b]SuperTrend[/b] — An ATR-based trailing stop that flips between bullish and bearish states. Controls which pool of historical pivots the script reads from.
[*] [b]Pivot pool[/b] — A rolling store of confirmed zigzag pivots, split by direction. [i]Bull pool[/i] holds pivot highs that printed during bullish SuperTrend runs; [i]bear pool[/i] holds pivot lows from bearish runs. Capped at [b]2000 entries per side[/b].
[*] [b]Context axis[/b] — A [b]0–100[/b] value measured at the pivot bar. The script ships with three built-ins ([i]relative volume percentile[/i], [i]time of day[/i], [i]position in recent range[/i]) and one optional user-plugged signal.
[*] [b]Axis independence[/b] — The three built-in axes cover [b]volume[/b], [b]time[/b], and [b]price[/b] respectively, chosen so each describes a structurally different part of the market. Low correlation between axes keeps the blended score from being dominated by any single factor.
[*] [b]Conditional histogram[/b] — For each active axis, the script walks its pool and keeps only pivots whose bins on [i]every other[/i] active axis match the current bar. The survivors are binned to form a histogram.
[*] [b]Axis score[/b] — For one axis, the count of pivots in the current bar's bin divided by the count in the histogram's tallest bin, scaled to [b]0–100[/b]. [b]100[/b] means the current context sits in the densest part of past pivots.
[*] [b]Blended favourability score[/b] — Arithmetic mean of the active per-axis scores. This is what the gauge and table display.
[*] [b]Density-match scoring[/b] — The score measures how common the current context is among past pivots. It is [b]not[/b] a forward probability and makes no claim about what happens next.
[/list]

🟠 FEATURES

[list]
[*] [b]Right-side context profiles[/b] — Stacked mini histograms render to the right of price, one per active axis.
  • Bar heights show how pivots in each axis's conditional pool distribute across bins.
  • A [i]dashed vertical line[/i] marks the current bar's bin on that axis, so you can see at a glance where today sits against history.
  • Bar hue tracks the active SuperTrend direction.
[image]https://www.tradingview.com/x/Q0vYAvJd/[/image]

[*] [b]Favourability gauge[/b] — A vertical gradient table in the bottom-right showing the blended score, with a chevron marking the current level. [i]Green at the top, red at the bottom.[/i]
[image]https://www.tradingview.com/x/o4JDSuCE/[/image]

[*] [b]Favourability breakdown table[/b] — A two-column readout of each active axis's individual score out of 100, plus a final row that classifies the blended score as [b]Good[/b], [b]Neutral[/b], or [b]Bad[/b]. Position and text size are configurable.
[image]https://www.tradingview.com/x/1kBRw3iJ/[/image]

[*] [b]Bar coloring[/b] — Bars fade from neutral grey toward the opposing trend colour as the blended score rises toward 100, so the chart itself signals when the context is stretched.
[image]https://www.tradingview.com/x/MqO0WHg7/[/image]

[*] [b]Take-profit markers[/b] — Small orange markers print above or below the bar when the blended score hits [b]100[/b] for the active SuperTrend direction.
[image]https://www.tradingview.com/x/iwMee8oo/[/image]

[*] [b]Timeframe guard[/b] — The time-of-day axis disables automatically on daily and higher timeframes, where the reading has no meaning, and a banner explains this so the blended score stays honest.
[*] [b]Multi-dimensional scoring engine[/b] — Four independent axes feed into a single score, each conditioned on all the others.
  • Three built-in axes can be toggled on or off individually.
  • A fourth axis accepts any plot via [i]source input[/i], provided the series stays within [b]0–100[/b] on all loaded bars.
  • An on-chart warning prints if the custom signal leaves that range, and the axis is ignored until it is corrected.
[*] [b]Deliberately uncorrelated built-in axes[/b] — Volume ([i]relative volume percentile[/i]), time ([i]time of day[/i]), and price ([i]position in recent range[/i]) cover three structurally different facets of market context. Keeping the axes independent means each one adds new information to the blend rather than reinforcing the others.
[*] [b]Alert conditions[/b] — Six alerts are included: SuperTrend bullish flip, SuperTrend bearish flip, score peak match, and crossovers into the [i]Good[/i], [i]Neutral[/i], and [i]Bad[/i] bands.
[/list]

🟠 HOW TO USE

[list]
[*] [b]Add the script to an intraday chart[/b] on a liquid instrument and let it run long enough to populate the pools. More history means more stable conditional histograms.
[*] [b]Let SuperTrend define the active regime.[/b] The script only scores in the direction of the current trend; bar coloring and take-profit markers respect that regime.
[*] [b]Read the gauge and breakdown table together.[/b] The gauge shows the blended level; the table shows which individual axes are pulling it up or down.
[*] [b]Use the right-side profiles as a sanity check.[/b] If the dashed current-bin marker is sitting on or near the tallest bar across most axes, the current context closely resembles past pivot contexts in that direction.
[*] [b]Treat high scores as a cue to tighten management, not as reversal signals.[/b] A reading of [b]100[/b] means conditions match where pivots have historically clustered, not that the trend is guaranteed to end.
[*] [b]Adjust the zigzag pivot length[/b] to control how strict the pool is. Lower values admit more pivots ([i]bigger, noisier sample[/i]); higher values keep only firmer pivots ([i]smaller, cleaner sample[/i]).
[*] [b]Plug your own signal into the custom axis[/b] to test whether an existing 0–100 oscillator adds useful conditioning, such as an RSI or a normalised momentum reading. For best results, pick a signal that is [i]not strongly correlated[/i] with the three built-ins, so the custom axis adds a new dimension rather than re-stating an existing one.
[image]https://www.tradingview.com/x/pO1HCqP2/[/image]

[*] [b]Enable only the alerts that fit your workflow.[/b] The band-crossover alerts fire [i]once per transition[/i], not on every bar inside a band.
[/list]

🟠 LIMITATIONS

[list]
[*] The pool holds [b]every[/b] confirmed pivot during a matching-direction run, [b]not only[/b] pivots that ended the trend. Intermediate pullbacks sit alongside genuine terminal pivots. Raising the zigzag pivot length filters the pool further if you want a cleaner sample.
[*] On [i]strongly trending symbols[/i] the pool is dominated by pullback pivots rather than true terminal exits, because strong trends have many small pullbacks and only one final top or bottom. On [i]choppy symbols[/i] the ratio is more balanced. Read the score with this in mind.
[*] The blended score is a [b]density-match[/b] measure, [b]not a forward probability[/b]. A high reading means today's context is common among past pivots of this direction. It does not predict that the trend is about to end.
[*] The [b]time-of-day axis[/b] has no meaning on daily and higher timeframes and is disabled automatically on those timeframes. A warning banner confirms when this is active.
[*] The [b]custom axis[/b] requires a source already scaled to 0–100 on every loaded bar. Values outside that range disable the axis and surface a warning. Toggling the custom axis on a live chart starts the range check from the current bar; [i]reload the chart to validate against full loaded history[/i].
[*] Pools are capped at [b]2000 entries per direction[/b], with the oldest entries dropped first. On very long intraday histories the effective lookback is symbol- and timeframe-dependent.
[*] All scoring uses data up to and including the confirmation bar of each pivot; pivots themselves are detected with the standard zigzag confirmation lag, meaning the scoring population on any given bar reflects pivots confirmed at least [b]zzLen[/b] bars earlier.
[/list]

🟠 CONCLUSION

[b]SuperTrend Take-Profit Dimensions[/b] combines a standard SuperTrend with a rolling pool of historical pivot contexts and scores the current bar against that pool across up to [b]four independent axes[/b] spanning volume, time, and price. The output is a blended [b]0–100 favourability reading[/b], a per-axis breakdown, and a set of context profiles that show where past pivots have clustered. It gives trend followers a structured, data-backed way to judge when the current context matches where trends have historically given back profit, without pretending to predict the next bar.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlgoAlpha

//@version=6
indicator("SuperTrend Take-Profit Dimensions [AlgoAlpha]", "AlgoAlpha - SuperTrend TP Dimensions", true, max_boxes_count = 500, explicit_plot_zorder = true, max_bars_back = 5000)

// === INPUTS ===
atrPeriod = input.int(10, "SuperTrend ATR period", minval = 1, group = "Signal Settings", tooltip = "ATR length used inside SuperTrend. Higher values smooth the stop; lower values react faster to volatility changes.")
stFactor = input.float(3.0, "SuperTrend factor", minval = 0.1, step = 0.1, group = "Signal Settings", tooltip = "Multiplier applied to ATR for stop distance. Larger values widen the band (fewer trend flips); smaller values tighten the band.")

zzLen = input.int(3, "Zig Zag pivot length", minval = 2, maxval = 50, group = "Signal Settings", tooltip = "Bars on each side required to confirm a pivot. Lower values will record more TP points, potentially subject to more noise. Exit samples are taken from the pivot bar, not from the bar where the pivot first prints.")

component_1 = input.bool(true, "Relative volume percentile", group = "Context Axes", tooltip = "When on, 50-bar volume percentile (0–100) buckets past zigzag exits and feeds the conditional histogram, profiles, and blended favourability score.")
component_2 = input.bool(true, "Time of day", group = "Context Axes", tooltip = "When on, a session time-of-day score (0–100) buckets exits and feeds conditioning, profiles, and the favourability blend. Intraday timeframes only — automatically disabled on daily and higher timeframes where time-of-day has no meaning.")
component_3 = input.bool(true, "Position in recent range", group = "Context Axes", tooltip = "When on, price position within the recent high–low window (0–100) buckets exits and feeds conditioning, profiles, and the favourability blend.")

component_custom = input.bool(false, "", inline = "cust", group = "Context Axes")
c_custom = input.source(close, "Custom signal", inline = "cust", group = "Context Axes", tooltip = "Checkbox + source: adds a fourth axis from this plot. Values must stay within 0–100 on every loaded bar and on the current bar (checked with ta.max/ta.min and the live value); otherwise the custom leg is ignored and a bottom-centre warning is shown. Use a series already scaled to 0–100, or rescale your indicator. Note: toggling this setting on a live chart starts the all-time range check from the current bar — reload the chart to validate against the full loaded history.")

binCount = input.int(5, "Profile bin count", minval = 2, maxval = 100, group = "Appearance", tooltip = "Number of equal-width bins spanning 0–100 for each axis. More bins give finer resolution; fewer bins aggregate more mass per bar.")
contextGaugeRows = input.int(15, "Favourability gauge rows", minval = 3, maxval = 40, group = "Appearance", tooltip = "Vertical row count for the exit favourability gauge. More rows give a finer vertical marker step; fewer rows compress the display.")

green = input.color(#00ffbb, title = "Bullish Colour", group = "Appearance", tooltip = "Accent for bullish regime: SuperTrend up line and fill, bullish-side profile bars, and positive histogram styling where applicable.")
red = input.color(#ff1100, title = "Bearish Colour", group = "Appearance", tooltip = "Accent for bearish regime: SuperTrend down line and fill, bearish-side profile bars, and negative histogram styling where applicable.")

show_take_profit_signals = input.bool(true, "Take profit signals", group = "Appearance", tooltip = "When on, small orange markers print when the blended favourability score is at or near 100 — i.e., the current bar's context matches the historical peak-density exit context for the active SuperTrend direction.")
show_bar_coloring = input.bool(true, "Bar coloring", group = "Appearance", tooltip = "When on, bars shade from neutral gray toward the opposing trend colour as the blended favourability score rises toward 100.")
show_context_profiles = input.bool(true, "Context profiles", group = "Appearance", tooltip = "When on, draws the stacked mini histograms to the right of price — one slot per enabled axis — showing conditional exit counts per bin. Dashed vertical line marks the current bar's bin on each axis.")
show_supertrend = input.bool(true, "SuperTrend line & fill", group = "Appearance", tooltip = "When on, shows the SuperTrend stop line, bull/bear fill between mid-price and the stop, and flip markers at trend changes.")
show_exit_favourability_gauge = input.bool(true, "Exit favourability gauge", group = "Appearance", tooltip = "When on, shows the bottom-right table gauge: blended favourability score (0–100) with a colour gradient and a chevron marker row. The score measures how closely the current bar's context matches the peak historical exit context, not a forward probability.")
show_favourability_breakdown_table = input.bool(true, "Favourability breakdown table", group = "Appearance", tooltip = "When on, shows a two-column table: each enabled axis lists its conditional score out of 100; the last row classifies the blended score used by the gauge.")
contextTablePosition = input.string("top right", "Breakdown table position", options = ["bottom center", "bottom left", "bottom right", "middle center", "middle left", "middle right", "top center", "top left", "top right"], group = "Appearance", tooltip = "Chart corner where the breakdown table is anchored (independent from the favourability gauge position).")
contextTableSize = input.string("Small", "Breakdown table text size", options = ["Tiny", "Small", "Medium", "Large"], group = "Appearance", tooltip = "Text size for breakdown table headers and body cells.")

const int PROFILE_OFFSET_BARS = 70
const int PROFILE_BIN_SPACING = 12

// Profile mini-chart titles (match Context Axes names)
const string PROFILE_TITLE_1 = "Relative volume percentile"
const string PROFILE_TITLE_2 = "Time of day"
const string PROFILE_TITLE_3 = "Position in recent range"
const string PROFILE_TITLE_4 = "Custom signal"
const string PROFILE_V_AXIS_TITLE = "Count"
// Profile mini-chart layout (all four slots use the same fractions)
const float PROFILE_FRAC_USABLE_HEIGHT = 0.7
const float PROFILE_FRAC_DASH_HEIGHT = 0.8
const float PROFILE_FRAC_TITLE_BELOW = 0.2
const float PROFILE_FRAC_TIP_INSET = 0.18
const float PROFILE_FRAC_V_LBL_LEFT = 0.35

const int MAX_HISTORY = 2000

// Profile histogram horizontal extent (bins × spacing); axis line and ▶ use the same math as resolution changes.
profileHistXRight(int leftX, int bins) =>
    leftX + bins * PROFILE_BIN_SPACING - 1

profileHistArrowRx(int leftX, int bins) =>
    int xr = profileHistXRight(leftX, bins)
    int(math.round(xr - (xr - leftX) * PROFILE_FRAC_TIP_INSET))

// --- Per-slot drawing state (one record per axis, managed centrally) ---
// @type  ProfileSlot  Holds the persistent drawing handles for one histogram slot.
type ProfileSlot
    array<box> bars
    line       axisV
    line       axisH
    line       currentMarker
    label      titleLbl
    label      vAxisLbl
    label      topTipLbl
    label      rightTipLbl

newProfileSlot() =>
    ProfileSlot.new(array.new_box(), na, na, na, na, na, na, na)

clearProfileSlot(ProfileSlot s) =>
    if not na(s.bars)
        for b in s.bars
            box.delete(b)
        array.clear(s.bars)
    if not na(s.axisV)
        line.delete(s.axisV)
    if not na(s.axisH)
        line.delete(s.axisH)
    if not na(s.currentMarker)
        line.delete(s.currentMarker)
    if not na(s.titleLbl)
        label.delete(s.titleLbl)
    if not na(s.vAxisLbl)
        label.delete(s.vAxisLbl)
    if not na(s.topTipLbl)
        label.delete(s.topTipLbl)
    if not na(s.rightTipLbl)
        label.delete(s.rightTipLbl)

// @function drawProfileSlot  Renders one conditional-distribution histogram slot.
// @param slot             Persistent drawing state (cleared each bar before redraw).
// @param aggregate        Conditional sample values (0–100) for this axis.
// @param title            Axis title.
// @param bins             Number of bins across 0–100.
// @param currentBin       Current bar's bin index on this axis.
// @param barColorBase     Histogram fill base colour (regime-tinted).
// @param markerColor      Dashed current-bin marker colour (inverted accent).
// @param slotIndex        0..3, top-to-bottom slot position.
// @param slotHeight       Vertical room per slot (price units).
// @param topAnchor        Top of slot 0 (price units).
// @param baseX            Left X (bar index) of the histogram.
drawProfileSlot(ProfileSlot slot, array<float> aggregate, string title, int bins, int currentBin, color barColorBase, color markerColor, int slotIndex, float slotHeight, float topAnchor, int baseX) =>
    if array.size(aggregate) > 0
        array<int> binCounts = array.new<int>(bins, 0)
        float bw = 100.0 / bins
        for val in aggregate
            int bi = math.max(0, math.min(bins - 1, math.floor(val / bw)))
            array.set(binCounts, bi, array.get(binCounts, bi) + 1)
        int maxCount = array.max(binCounts)
        if maxCount > 0
            float usableHeight = slotHeight * PROFILE_FRAC_USABLE_HEIGHT
            float slotTop      = topAnchor - slotHeight * slotIndex
            float slotBottom   = slotTop - slotHeight
            for i = 0 to bins - 1
                int cnt = array.get(binCounts, i)
                float barHeight = (cnt * 1.0 / maxCount) * usableHeight
                float normHeight = cnt * 1.0 / maxCount
                int transparency = 50 + math.round(40 * (1 - normHeight))
                color barColor = color.new(barColorBase, transparency)
                int xLeft  = baseX + i * PROFILE_BIN_SPACING
                int xRight = xLeft + PROFILE_BIN_SPACING - 1
                box b = box.new(left = xLeft, top = slotBottom + barHeight, right = xRight, bottom = slotBottom,
                                bgcolor = barColor, border_color = color.new(#ffffff, 70), border_width = 1, border_style = line.style_solid)
                array.push(slot.bars, b)
            float yHistTop = slotBottom + usableHeight
            int xAxisRight = profileHistXRight(baseX, bins)
            slot.axisV := line.new(baseX, slotBottom, baseX, yHistTop, color = chart.fg_color, style = line.style_solid, width = 4)
            slot.axisH := line.new(baseX, slotBottom, xAxisRight, slotBottom, color = chart.fg_color, style = line.style_solid, width = 4)
            int currentX = baseX + currentBin * PROFILE_BIN_SPACING + math.round(PROFILE_BIN_SPACING / 2)
            slot.currentMarker := line.new(currentX, slotBottom, currentX, slotBottom + slotHeight * PROFILE_FRAC_DASH_HEIGHT, color = color.new(markerColor, 0), style = line.style_dashed, width = 3)
            float midX  = baseX + (bins * PROFILE_BIN_SPACING - 1) / 2.0
            float yHTit = slotBottom - slotHeight * PROFILE_FRAC_TITLE_BELOW
            slot.titleLbl   := label.new(int(math.round(midX)), yHTit, title, style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.normal)
            int xTipR = profileHistArrowRx(baseX, bins)
            slot.topTipLbl   := label.new(baseX, yHistTop - usableHeight * PROFILE_FRAC_TIP_INSET, "▲", style = label.style_label_down, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.large)
            slot.rightTipLbl := label.new(xTipR, slotBottom, "▶", style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.large)
            slot.vAxisLbl    := label.new(int(math.round(baseX - PROFILE_BIN_SPACING * PROFILE_FRAC_V_LBL_LEFT)), slotBottom + usableHeight / 2.0, PROFILE_V_AXIS_TITLE, style = label.style_label_right, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.normal)

// @function scoreAggregate  Builds binCounts for one axis and returns the score 0..100 (or na when undefined).
scoreAggregate(array<float> aggregate, int currentBin, int bins) =>
    float bw = 100.0 / bins
    float score = na
    if array.size(aggregate) > 0
        array<int> bc = array.new<int>(bins, 0)
        for v in aggregate
            int bi = math.max(0, math.min(bins - 1, math.floor(v / bw)))
            array.set(bc, bi, array.get(bc, bi) + 1)
        int cur = array.get(bc, currentBin)
        int peak = array.max(bc)
        if peak > 0
            score := 100.0 * cur / peak
    score

// Favourability breakdown table (same table styling idea as reference pattern volume table)
contextTableTextSize(string sz) =>
    switch sz
        "Tiny" => size.tiny
        "Small" => size.small
        "Medium" => size.normal
        "Large" => size.large

contextTablePosFromString(string pos_key) =>
    switch pos_key
        "bottom center" => position.bottom_center
        "bottom left" => position.bottom_left
        "bottom right" => position.bottom_right
        "middle center" => position.middle_center
        "middle left" => position.middle_left
        "middle right" => position.middle_right
        "top center" => position.top_center
        "top left" => position.top_left
        "top right" => position.top_right

contextCellAlpha(float v, float vmax) =>
    vmax <= 0 ? 85 : math.max(50, math.round(85 - math.min(1.0, v / vmax) * 70))

contextBreakdownScoreText(float s) =>
    na(s) ? "— / 100" : str.tostring(s, "#.#") + " / 100"

// === TREND ENGINE & DATA POINTS (CALCULATIONS) ===
[supertrend, direction] = ta.supertrend(stFactor, atrPeriod) //direction < 0 is bullish

relVolPercentile = ta.percentrank(volume, 50)
bool component_2_valid = timeframe.isintraday
timeOfDay = component_2_valid ? ((time % 86400000) / 800000.0) * (100.0 / 108.0) : na

rangeLen = 20
hh = ta.highest(high, rangeLen)
ll = ta.lowest(low, rangeLen)
rangePos = (close - ll) / math.max(hh - ll, syminfo.mintick) * 100.0

// Custom signal: all-time high/low must stay in [0,100] (ta.max / ta.min); current bar must also be valid for live bins.
// ta.* is only evaluated when the custom axis is enabled, to avoid running a running all-time reduction unnecessarily.
float customHistMax = component_custom ? ta.max(c_custom) : na
float customHistMin = component_custom ? ta.min(c_custom) : na
bool customAtlInBounds = not na(customHistMax) and not na(customHistMin) and customHistMax <= 100.0 and customHistMin >= 0.0
bool customInRange = not na(c_custom) and c_custom >= 0.0 and c_custom <= 100.0
bool customActive = component_custom and customAtlInBounds and customInRange

// === HISTORICAL DATA COLLECTION (zigzag pivot exits, direction at pivot bar) ===
// Bull pool: confirmed pivot highs only when trend at the pivot bar was uptrend (direction < 0).
// Bear pool: confirmed pivot lows only when trend at the pivot bar was downtrend (direction > 0).
// Values are taken from the pivot bar (zzLen bars back), not the confirmation bar.
//
// INTENDED INTERPRETATION: the pools are *observed exit contexts* — the set of chart
// conditions at pivots that occurred while a matching-direction SuperTrend run was in
// effect. Not every pivot in the pool corresponds to the trend's actual terminal exit;
// some are intermediate pivots that did not cause a regime flip. The score therefore
// measures "how typical is the current context, among historical pivot contexts of this
// direction," not "probability this pivot ends the trend." The zzLen confirmation guards
// against micro-noise pivots; raise it to filter the pool further.
var bullPoolC1 = array.new_float()
var bullPoolC2 = array.new_float()
var bullPoolC3 = array.new_float()
var bullPoolC4 = array.new_float()
var bearPoolC1 = array.new_float()
var bearPoolC2 = array.new_float()
var bearPoolC3 = array.new_float()
var bearPoolC4 = array.new_float()

ph = ta.pivothigh(zzLen, zzLen)
pl = ta.pivotlow(zzLen, zzLen)
int zz = zzLen

// Top pivot = uptrend exit: only if Supertrend was bullish (direction < 0) at the pivot bar, not at confirmation bar
bool recordBullExit = not na(ph) and not na(direction[zz]) and direction[zz] < 0
// Bottom pivot = downtrend exit: only if bearish at the pivot bar
bool recordBearExit = not na(pl) and not na(direction[zz]) and direction[zz] > 0

if recordBullExit
    array.unshift(bullPoolC1, component_1 ? relVolPercentile[zz] : na)
    array.unshift(bullPoolC2, (component_2 and component_2_valid) ? timeOfDay[zz] : na)
    array.unshift(bullPoolC3, component_3 ? rangePos[zz] : na)
    float c4b = c_custom[zz]
    array.unshift(bullPoolC4, component_custom and customAtlInBounds and not na(c4b) and c4b >= 0.0 and c4b <= 100.0 ? c4b : na)

if recordBearExit
    array.unshift(bearPoolC1, component_1 ? relVolPercentile[zz] : na)
    array.unshift(bearPoolC2, (component_2 and component_2_valid) ? timeOfDay[zz] : na)
    array.unshift(bearPoolC3, component_3 ? rangePos[zz] : na)
    float c4e = c_custom[zz]
    array.unshift(bearPoolC4, component_custom and customAtlInBounds and not na(c4e) and c4e >= 0.0 and c4e <= 100.0 ? c4e : na)

while array.size(bullPoolC1) > MAX_HISTORY
    array.pop(bullPoolC1)
while array.size(bullPoolC2) > MAX_HISTORY
    array.pop(bullPoolC2)
while array.size(bullPoolC3) > MAX_HISTORY
    array.pop(bullPoolC3)
while array.size(bullPoolC4) > MAX_HISTORY
    array.pop(bullPoolC4)
while array.size(bearPoolC1) > MAX_HISTORY
    array.pop(bearPoolC1)
while array.size(bearPoolC2) > MAX_HISTORY
    array.pop(bearPoolC2)
while array.size(bearPoolC3) > MAX_HISTORY
    array.pop(bearPoolC3)
while array.size(bearPoolC4) > MAX_HISTORY
    array.pop(bearPoolC4)

// === CONDITIONAL DISTRIBUTION CALCULATIONS (per component) ===
float binWidth = 100.0 / binCount

int c1Bindex = math.floor(relVolPercentile / binWidth)
c1Bindex := math.max(0, math.min(binCount - 1, c1Bindex))

int c2Bindex = 0
if component_2_valid and not na(timeOfDay)
    c2Bindex := math.floor(timeOfDay / binWidth)
    c2Bindex := math.max(0, math.min(binCount - 1, c2Bindex))

int c3Bindex = math.floor(rangePos / binWidth)
c3Bindex := math.max(0, math.min(binCount - 1, c3Bindex))

int customBindex = 0
if customActive
    customBindex := math.floor(c_custom / binWidth)
    customBindex := math.max(0, math.min(binCount - 1, customBindex))

// Uptrend (bull Supertrend): use bull-exit pool (top pivots in uptrend). Downtrend: bear-exit pool (bottom pivots in downtrend).
bool useBullHist = not na(direction) and direction < 0
bool useBearHist = not na(direction) and direction > 0
int histN = useBullHist ? array.size(bullPoolC1) : useBearHist ? array.size(bearPoolC1) : 0

// Component 1 aggregate: c1 conditioned on other active components (incl. custom signal). Disabled toggles ignored.
array<float> aggC1 = array.new_float()
if component_1 and histN > 0
    for i = 0 to histN - 1
        float h_c1 = useBullHist ? array.get(bullPoolC1, i) : array.get(bearPoolC1, i)
        if na(h_c1)
            continue
        bool cond_ok = true
        if component_2 and component_2_valid
            float h_c2 = useBullHist ? array.get(bullPoolC2, i) : array.get(bearPoolC2, i)
            if na(h_c2)
                cond_ok := false
            else
                int b2 = math.max(0, math.min(binCount - 1, math.floor(h_c2 / binWidth)))
                cond_ok := cond_ok and b2 == c2Bindex
        if cond_ok and component_3
            float h_c3 = useBullHist ? array.get(bullPoolC3, i) : array.get(bearPoolC3, i)
            if na(h_c3)
                cond_ok := false
            else
                int b3 = math.max(0, math.min(binCount - 1, math.floor(h_c3 / binWidth)))
                cond_ok := cond_ok and b3 == c3Bindex
        if cond_ok and customActive
            float h_c4 = useBullHist ? array.get(bullPoolC4, i) : array.get(bearPoolC4, i)
            if na(h_c4)
                cond_ok := false
            else
                int b4 = math.max(0, math.min(binCount - 1, math.floor(h_c4 / binWidth)))
                cond_ok := cond_ok and b4 == customBindex
        if cond_ok
            array.push(aggC1, h_c1)

// Component 2 aggregate: c2 conditioned only on active components other than 2
array<float> aggC2 = array.new_float()
if component_2 and component_2_valid and histN > 0
    for i = 0 to histN - 1
        float h_c2 = useBullHist ? array.get(bullPoolC2, i) : array.get(bearPoolC2, i)
        if na(h_c2)
            continue
        bool cond_ok = true
        if component_1
            float h_c1 = useBullHist ? array.get(bullPoolC1, i) : array.get(bearPoolC1, i)
            if na(h_c1)
                cond_ok := false
            else
                int b1 = math.max(0, math.min(binCount - 1, math.floor(h_c1 / binWidth)))
                cond_ok := cond_ok and b1 == c1Bindex
        if cond_ok and component_3
            float h_c3 = useBullHist ? array.get(bullPoolC3, i) : array.get(bearPoolC3, i)
            if na(h_c3)
                cond_ok := false
            else
                int b3 = math.max(0, math.min(binCount - 1, math.floor(h_c3 / binWidth)))
                cond_ok := cond_ok and b3 == c3Bindex
        if cond_ok and customActive
            float h_c4 = useBullHist ? array.get(bullPoolC4, i) : array.get(bearPoolC4, i)
            if na(h_c4)
                cond_ok := false
            else
                int b4 = math.max(0, math.min(binCount - 1, math.floor(h_c4 / binWidth)))
                cond_ok := cond_ok and b4 == customBindex
        if cond_ok
            array.push(aggC2, h_c2)

// Component 3 aggregate: c3 conditioned only on active components other than 3
array<float> aggC3 = array.new_float()
if component_3 and histN > 0
    for i = 0 to histN - 1
        float h_c3 = useBullHist ? array.get(bullPoolC3, i) : array.get(bearPoolC3, i)
        if na(h_c3)
            continue
        bool cond_ok = true
        if component_1
            float h_c1 = useBullHist ? array.get(bullPoolC1, i) : array.get(bearPoolC1, i)
            if na(h_c1)
                cond_ok := false
            else
                int b1 = math.max(0, math.min(binCount - 1, math.floor(h_c1 / binWidth)))
                cond_ok := cond_ok and b1 == c1Bindex
        if cond_ok and component_2 and component_2_valid
            float h_c2 = useBullHist ? array.get(bullPoolC2, i) : array.get(bearPoolC2, i)
            if na(h_c2)
                cond_ok := false
            else
                int b2 = math.max(0, math.min(binCount - 1, math.floor(h_c2 / binWidth)))
                cond_ok := cond_ok and b2 == c2Bindex
        if cond_ok and customActive
            float h_c4 = useBullHist ? array.get(bullPoolC4, i) : array.get(bearPoolC4, i)
            if na(h_c4)
                cond_ok := false
            else
                int b4 = math.max(0, math.min(binCount - 1, math.floor(h_c4 / binWidth)))
                cond_ok := cond_ok and b4 == customBindex
        if cond_ok
            array.push(aggC3, h_c3)

// Component 4 aggregate (custom signal): conditioned on other active components
array<float> aggC4 = array.new_float()
if customActive and histN > 0
    for i = 0 to histN - 1
        float h_c4 = useBullHist ? array.get(bullPoolC4, i) : array.get(bearPoolC4, i)
        if na(h_c4)
            continue
        bool cond_ok = true
        if component_1
            float h_c1 = useBullHist ? array.get(bullPoolC1, i) : array.get(bearPoolC1, i)
            if na(h_c1)
                cond_ok := false
            else
                int b1 = math.max(0, math.min(binCount - 1, math.floor(h_c1 / binWidth)))
                cond_ok := cond_ok and b1 == c1Bindex
        if cond_ok and component_2 and component_2_valid
            float h_c2 = useBullHist ? array.get(bullPoolC2, i) : array.get(bearPoolC2, i)
            if na(h_c2)
                cond_ok := false
            else
                int b2 = math.max(0, math.min(binCount - 1, math.floor(h_c2 / binWidth)))
                cond_ok := cond_ok and b2 == c2Bindex
        if cond_ok and component_3
            float h_c3 = useBullHist ? array.get(bullPoolC3, i) : array.get(bearPoolC3, i)
            if na(h_c3)
                cond_ok := false
            else
                int b3 = math.max(0, math.min(binCount - 1, math.floor(h_c3 / binWidth)))
                cond_ok := cond_ok and b3 == c3Bindex
        if cond_ok
            array.push(aggC4, h_c4)

// === CONTEXT SCORE (0–100 peak-density match, blended across active axes) ===
// Per-axis score: 100 × (count in current bin) / (count in peak bin) of the axis's
// conditional histogram. Blended score: arithmetic mean over active axes.
// NOTE: This is a density-match score, not a forward probability.
float contextScore    = na
float contextScore_c1 = na
float contextScore_c2 = na
float contextScore_c3 = na
float contextScore_c4 = na

if histN > 0
    float sumRelative = 0.0
    int   activeCount = 0

    if component_1
        contextScore_c1 := scoreAggregate(aggC1, c1Bindex, binCount)
        if not na(contextScore_c1)
            sumRelative += contextScore_c1 / 100.0
            activeCount += 1

    if component_2 and component_2_valid
        contextScore_c2 := scoreAggregate(aggC2, c2Bindex, binCount)
        if not na(contextScore_c2)
            sumRelative += contextScore_c2 / 100.0
            activeCount += 1

    if component_3
        contextScore_c3 := scoreAggregate(aggC3, c3Bindex, binCount)
        if not na(contextScore_c3)
            sumRelative += contextScore_c3 / 100.0
            activeCount += 1

    if customActive
        contextScore_c4 := scoreAggregate(aggC4, customBindex, binCount)
        if not na(contextScore_c4)
            sumRelative += contextScore_c4 / 100.0
            activeCount += 1

    if activeCount > 0
        contextScore := 100.0 * sumRelative / activeCount

// --- Bar color: gray base → opposing trend color as contextScore rises (bull → red tint, bear → green tint) ---
color barBaseGray = color.rgb(130, 130, 130)
color opposingTrend = not na(direction) and direction < 0 ? red : not na(direction) and direction > 0 ? green : barBaseGray
float scoreBar = math.min(100.0, math.max(0.0, nz(contextScore, 0.0)))
barcolor(show_bar_coloring ? color.from_gradient(scoreBar, 50, 100, barBaseGray, opposingTrend) : na)

// --- SuperTrend direction change: plotshape Y = supertrend with location.absolute (same idea as reference l/h) ---
bool stBullFlip = show_supertrend and not na(direction) and not na(direction[1]) and direction[1] > 0 and direction < 0
bool stBearFlip = show_supertrend and not na(direction) and not na(direction[1]) and direction[1] < 0 and direction > 0
plotshape(stBullFlip ? supertrend : na, "SuperTrend bull flip", shape.labelup, location.absolute, color = green, size = size.small)
plotshape(stBearFlip ? supertrend : na, "SuperTrend bear flip", shape.labeldown, location.absolute, color = red, size = size.small)

// --- TP signals: orange small diamond when contextScore is full ---
bool tpFullContext = show_take_profit_signals and not na(contextScore) and contextScore >= 99.999 and not na(direction)
plotchar(tpFullContext and direction < 0, "TP take-profit (bull trend)", "🔸", location.abovebar, color.orange, size = size.tiny)
plotchar(tpFullContext and direction > 0, "TP take-profit (bear trend)", "🔸", location.belowbar, color.orange, size = size.tiny)

// === VISUALS: PROFILE DRAWING (boxes, dashed lines, labels) ===
// DYNAMIC RANGE CALCULATION (centered around close) ===
v1 = ta.highest(100)
v2 = ta.lowest(100)
raw = ta.highest(v1 - v2, 50) * 2
dynamic_range = ta.sma(raw, 50)

// Profile bar hue matches SuperTrend regime (direction < 0 = bull / green)
color profile_hist_base = not na(direction) and direction > 0 ? red : green
// Dashed current-bin marker: inverted accent (green in bear, red in bull)
color profile_dash_color = not na(direction) and direction > 0 ? green : red

// === PROFILE SLOT RENDERING (unified via helper) ===
var ProfileSlot slot1 = newProfileSlot()
var ProfileSlot slot2 = newProfileSlot()
var ProfileSlot slot3 = newProfileSlot()
var ProfileSlot slot4 = newProfileSlot()

// Clear previous bar's drawings for every slot (cheap; idempotent when empty)
clearProfileSlot(slot1)
clearProfileSlot(slot2)
clearProfileSlot(slot3)
clearProfileSlot(slot4)

if show_context_profiles
    int baseX = bar_index + PROFILE_OFFSET_BARS
    float slotHeight = dynamic_range / 4.0
    float topAnchor  = close + dynamic_range / 2.0
    drawProfileSlot(slot1, aggC1, PROFILE_TITLE_1, binCount, c1Bindex,     profile_hist_base, profile_dash_color, 0, slotHeight, topAnchor, baseX)
    drawProfileSlot(slot2, aggC2, PROFILE_TITLE_2, binCount, c2Bindex,     profile_hist_base, profile_dash_color, 1, slotHeight, topAnchor, baseX)
    drawProfileSlot(slot3, aggC3, PROFILE_TITLE_3, binCount, c3Bindex,     profile_hist_base, profile_dash_color, 2, slotHeight, topAnchor, baseX)
    drawProfileSlot(slot4, aggC4, PROFILE_TITLE_4, binCount, customBindex, profile_hist_base, profile_dash_color, 3, slotHeight, topAnchor, baseX)

// --- SuperTrend: hidden body middle + two linebr plots + fills (same structure as TradingView examples) ---
bodyMiddle = plot(barstate.isfirst ? na : (open + close) / 2.0, "Body Middle", display = display.none, editable = false)
upTrend = plot(show_supertrend and not na(direction) and direction < 0 ? supertrend : na, "Up Trend", color = green, style = plot.style_linebr, linewidth = 2)
downTrend = plot(show_supertrend and not na(direction) and direction > 0 ? supertrend : na, "Down Trend", color = red, style = plot.style_linebr, linewidth = 2)
fill(bodyMiddle, upTrend, color = color.new(green, 90), title = "SuperTrend fill (up)")
fill(bodyMiddle, downTrend, color = color.new(red, 90), title = "SuperTrend fill (down)")

// --- Exit favourability gauge (gradient column + ">" marker row) ---
var table contextGaugeTbl = na
var string contextGaugeCfgLast = na
var table contextBreakdownTbl = na
var int contextBrkColsLast = na
var int contextBrkRowsLast = na
var int contextBrkMaskLast = na
var string contextBrkPosLast = na
var string contextBrkSizeLast = na

if barstate.islast
    // Custom signal range warning
    var table custom_warn_tbl = table.new(position.bottom_center, 1, 1, bgcolor = color.new(color.red, 100), border_width = 0, border_color = color.new(color.red, 100), frame_color = color.new(color.red, 100), frame_width = 1)
    bool show_custom_range_warning = component_custom and not customActive
    if show_custom_range_warning
        table.cell(custom_warn_tbl, 0, 0, "Warning: Custom signal must stay within 0–100 on every bar of loaded history and on this bar.\nOtherwise it is not used in calculations or visuals.", text_color = color.white, bgcolor = color.red, text_halign = text.align_center, text_size = size.small)
    else
        table.clear(custom_warn_tbl, 0, 0, 0, 0)

    // Time-of-day axis disabled warning
    var table tod_warn_tbl = table.new(position.bottom_left, 1, 1, bgcolor = color.new(color.orange, 100), border_width = 0, border_color = color.new(color.orange, 100), frame_color = color.new(color.orange, 100), frame_width = 1)
    bool show_tod_warning = component_2 and not component_2_valid
    if show_tod_warning
        table.cell(tod_warn_tbl, 0, 0, "Note: Time of day axis is disabled on daily+ timeframes (no time-of-day meaning). Score blends the remaining active axes.", text_color = color.white, bgcolor = color.orange, text_halign = text.align_center, text_size = size.small)
    else
        table.clear(tod_warn_tbl, 0, 0, 0, 0)

    if show_favourability_breakdown_table
        int colsB = 2
        int brk_mask = (component_1 ? 1 : 0) + ((component_2 and component_2_valid) ? 2 : 0) + (component_3 ? 4 : 0) + (customActive ? 8 : 0)
        int metric_rows = (component_1 ? 1 : 0) + ((component_2 and component_2_valid) ? 1 : 0) + (component_3 ? 1 : 0) + (customActive ? 1 : 0)
        int rowsB = 1 + metric_rows + 1
        bool needRecreateB = na(contextBreakdownTbl) or na(contextBrkColsLast) or na(contextBrkRowsLast) or na(contextBrkMaskLast) or contextBrkColsLast != colsB or contextBrkRowsLast != rowsB or contextBrkMaskLast != brk_mask or contextBrkPosLast != contextTablePosition or contextBrkSizeLast != contextTableSize
        if needRecreateB
            if not na(contextBreakdownTbl)
                table.delete(contextBreakdownTbl)
            contextBreakdownTbl := table.new(position = contextTablePosFromString(contextTablePosition), columns = colsB, rows = rowsB, bgcolor = chart.bg_color, border_width = 1, border_color = chart.fg_color, frame_color = chart.fg_color, frame_width = 1)
            contextBrkColsLast := colsB
            contextBrkRowsLast := rowsB
            contextBrkMaskLast := brk_mask
            contextBrkPosLast := contextTablePosition
            contextBrkSizeLast := contextTableSize
        table.clear(contextBreakdownTbl, 0, 0, colsB - 1, rowsB - 1)
        szB = contextTableTextSize(contextTableSize)
        table.cell(contextBreakdownTbl, 0, 0, "Metric", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
        table.cell(contextBreakdownTbl, 1, 0, "Match vs peak (0–100)", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
        row = 1
        if component_1
            table.cell(contextBreakdownTbl, 0, row, "Relative Volume Percentile", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
            table.cell(contextBreakdownTbl, 1, row, contextBreakdownScoreText(contextScore_c1), text_color = chart.fg_color, text_halign = text.align_center, text_size = szB, bgcolor = na(contextScore_c1) ? chart.bg_color : color.new(green, contextCellAlpha(contextScore_c1, 100.0)))
            row := row + 1
        if component_2 and component_2_valid
            table.cell(contextBreakdownTbl, 0, row, "Time of Day", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
            table.cell(contextBreakdownTbl, 1, row, contextBreakdownScoreText(contextScore_c2), text_color = chart.fg_color, text_halign = text.align_center, text_size = szB, bgcolor = na(contextScore_c2) ? chart.bg_color : color.new(green, contextCellAlpha(contextScore_c2, 100.0)))
            row := row + 1
        if component_3
            table.cell(contextBreakdownTbl, 0, row, "Position in Recent Range", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
            table.cell(contextBreakdownTbl, 1, row, contextBreakdownScoreText(contextScore_c3), text_color = chart.fg_color, text_halign = text.align_center, text_size = szB, bgcolor = na(contextScore_c3) ? chart.bg_color : color.new(green, contextCellAlpha(contextScore_c3, 100.0)))
            row := row + 1
        if customActive
            table.cell(contextBreakdownTbl, 0, row, PROFILE_TITLE_4, text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
            table.cell(contextBreakdownTbl, 1, row, contextBreakdownScoreText(contextScore_c4), text_color = chart.fg_color, text_halign = text.align_center, text_size = szB, bgcolor = na(contextScore_c4) ? chart.bg_color : color.new(green, contextCellAlpha(contextScore_c4, 100.0)))
            row := row + 1
        string tp_cond = na(contextScore) ? "—" : contextScore > 80.0 ? "Good (>80)" : contextScore > 50.0 ? "Neutral (>50)" : "Bad (<50)"
        color tp_bg = na(contextScore) ? chart.bg_color : contextScore > 80.0 ? color.new(green, 55) : contextScore > 50.0 ? color.new(chart.fg_color, 88) : color.new(red, 55)
        table.cell(contextBreakdownTbl, 0, row, "Exit Conditions", text_color = chart.fg_color, text_halign = text.align_center, text_size = szB)
        table.cell(contextBreakdownTbl, 1, row, tp_cond, text_color = chart.fg_color, text_halign = text.align_center, text_size = szB, bgcolor = tp_bg)
    else
        if not na(contextBreakdownTbl)
            table.delete(contextBreakdownTbl)
            contextBreakdownTbl := na
            contextBrkColsLast := na
            contextBrkRowsLast := na
            contextBrkMaskLast := na
            contextBrkPosLast := na
            contextBrkSizeLast := na

    if show_exit_favourability_gauge
        int tc = contextGaugeRows
        string gauge_cfg = str.tostring(tc) + "_br"
        if na(contextGaugeTbl) or contextGaugeCfgLast != gauge_cfg
            if not na(contextGaugeTbl)
                table.delete(contextGaugeTbl)
            contextGaugeTbl := table.new(position.bottom_right, 3, tc + 1, frame_color = color.new(chart.fg_color, 50), border_width = 1, bgcolor = color.new(chart.bg_color, 85))
            contextGaugeCfgLast := gauge_cfg
        for i = 1 to tc
            // Row 1 = top of gauge: green (strong); row tc = bottom: red (weak)
            color grad_c = color.from_gradient(i, 1, tc, green, red)
            table.cell(contextGaugeTbl, 1, i, "", bgcolor = grad_c, text_color = grad_c)
        float scorePct = math.min(100.0, math.max(0.0, nz(contextScore, 0.0)))
        // Map 100 → row 1 (top), 0 → row tc (bottom); table row 0 is header
        int mark_row = int(math.round(tc - scorePct * (tc - 1) / 100.0))
        mark_row := math.max(1, math.min(tc, mark_row))
        table.cell(contextGaugeTbl, 1, mark_row, ">", bgcolor = color.new(#ffffff, 100), text_color = chart.fg_color, text_size = size.normal)
        table.cell(contextGaugeTbl, 0, 0, "Exit Favourability", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 80))
        table.cell(contextGaugeTbl, 1, 0, na(contextScore) ? "—" : str.tostring(contextScore, "#.#"), text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 80))
    else
        if not na(contextGaugeTbl)
            table.delete(contextGaugeTbl)
            contextGaugeTbl := na
            contextGaugeCfgLast := na

// === ALERTS (pick conditions in TradingView: Create Alert -> Condition -> this indicator) ===
// TP full edge: same maths as plotchar TP markers, independent of "Take profit signals" visibility.
bool tpFullContextRaw = not na(contextScore) and contextScore >= 99.999 and not na(direction)
bool prevTpFullRaw = bar_index > 0 ? tpFullContextRaw[1] : false
bool alertTpFullEdge = tpFullContextRaw and not prevTpFullRaw

// SuperTrend flips: raw direction change (independent of "SuperTrend line & fill" visibility).
bool alertBullFlip = not na(direction) and not na(direction[1]) and direction[1] > 0 and direction < 0
bool alertBearFlip = not na(direction) and not na(direction[1]) and direction[1] < 0 and direction > 0

// TP condition bands (same thresholds as breakdown table). Crosses only: one shot per transition, not every bar inside a band.
bool alertTpEnterGood = ta.crossover(contextScore, 80.0)
bool alertTpEnterBad = ta.crossunder(contextScore, 50.0)
bool alertTpEnterNeutral = ta.crossunder(contextScore, 80.0) or (ta.crossover(contextScore, 50.0) and contextScore <= 80.0)

// === ALERTS ===
alertcondition(alertTpFullEdge, "Exit favourability: peak match (score at 100)")
alertcondition(alertBullFlip, "SuperTrend: turned bullish")
alertcondition(alertBearFlip, "SuperTrend: turned bearish")
alertcondition(alertTpEnterGood, "Exit favourability: Good (>80)")
alertcondition(alertTpEnterNeutral, "Exit favourability: Neutral (50–80]")
alertcondition(alertTpEnterBad, "Exit favourability: Bad (≤50)")
````
