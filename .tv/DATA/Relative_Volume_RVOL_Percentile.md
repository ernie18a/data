<!-- tradingview-pine-id: PUB;0fa488bab49e478b805ea6814bb0a8a6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Volume (RVOL) Percentile

Source: https://www.tradingview.com/script/R97HS5Uk-Relative-Volume-RVOL-Percentile/

## Description

Relative Volume (RVOL) Percentile

What it does
Relative Volume (RVOL) Percentile shows when participation on the current chart bar is unusual versus its own recent history. The pane displays a relative-volume histogram colored as Dry-up, Normal, High, or Extreme, with an optional norm line at 1.0x. It describes observed volume conditions only and does not generate directional trade signals.

How it works
The script compares each bar with a rolling sample of completed bars from the same chart timeframe. The current bar is excluded from both the baseline and percentile sample.

[*] The baseline is either the median or simple moving average of the previous Lookback bars.
[*] RVOL is current volume divided by that baseline. A value of 1.0 means current volume equals the selected norm.
[*] Percentile rank is the percentage of the previous Lookback volume values that are less than or equal to current volume.
[*] Dry-up is below the Dry-up threshold, Normal is below High, High is below Extreme, and Extreme is at or above the Extreme threshold.

How to use it

[*] Add the script to a chart and choose a Lookback that represents the recent activity you want to compare.
[*] Read bars near 1.0x as close to the selected volume norm, then use the stage color to judge how unusual that bar is within the recent sample.
[*] Use High or Extreme transitions to identify unusually active bars and Dry-up transitions to identify unusually quiet bars.
[*] Enable price-bar coloring or the last-bar RVOL label only when that extra context is useful.

Inputs

[*] Lookback (Bars) - Number of prior completed chart bars used for both the baseline and percentile sample. Range 2-1000, default 20.
[*] Baseline Method - Median reduces the influence of isolated spikes; SMA uses the arithmetic mean. Default Median.
[*] Dry-up Below (%) - Percentile below which volume is classified as Dry-up. Range 0-100, default 15.
[*] High From (%) - Percentile from which volume is classified as High. Range 0-100, default 80.
[*] Extreme From (%) - Percentile from which volume is classified as Extreme. Range 0-100, default 95. Thresholds must remain in ascending order.
[*] Show Histogram - Shows or hides the RVOL histogram. Default on.
[*] Show Reference Line (Norm) - Shows or hides the 1.0x norm line. Default on.
[*] Color Price Bars - Applies the same stage color to price bars on the main chart. Default off.
[*] Show Value Label - Shows the current RVOL value on the last bar only. Default off.
[*] Text Size - Numeric size for the optional last-bar label. Range 10-24, default 12.
[*] Opacity (%) - Controls visual opacity. Range 0-100, default 70.
[*] Dry-up / Normal / High / Extreme colors - Sets the four stage colors used by the histogram and optional price-bar coloring.

Signals and alerts

[*] Relative Volume - Extreme - fires on a confirmed bar when the stage newly becomes Extreme.
[*] Relative Volume - High - fires on a confirmed bar when the stage crosses from below High into High or Extreme.
[*] Relative Volume - Dry-up - fires on a confirmed bar when the stage newly becomes Dry-up.

Repainting
The baseline and percentile sample use only prior chart bars. Alert transitions require the current chart bar to be confirmed, so an alert state is not finalized from an unfinished bar. The histogram can move with live volume while the current bar is open because it describes that still-forming bar; closed historical bars are not rewritten afterward.

Limitations

[*] The script uses total chart-bar volume only. It does not estimate buy/sell delta, footprint data, or intrabar order flow.
[*] Percentile rank is relative to the chosen Lookback, so different sample lengths can classify the same bar differently.
[*] Markets or symbols with missing, sparse, or non-comparable volume data can produce incomplete or less useful readings.
[*] The script measures volume anomaly only. It does not predict direction, continuation, reversal, or future price movement.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

// max_bars_back matches LOOKBACK_MAX because percentileRank() uses an input-driven
// history offset that Pine cannot infer automatically.
//@version=6
indicator("Relative Volume (RVOL) Percentile", shorttitle = "Relative Volume (RVOL) (kronos)", overlay = false, max_bars_back = 1000, max_labels_count = 10)

//#region TYPES ================================================================

enum BaselineMethod
    sma    = "SMA"
    median = "Median"

//#endregion

//#region CONSTANTS ============================================================

int    STATE_DRY_UP  = 0
int    STATE_NORMAL  = 1
int    STATE_HIGH    = 2
int    STATE_EXTREME = 3

float  PERCENT_SCALE = 100.0
float  RVOL_NORM     = 1.0
int    LOOKBACK_MAX  = 1000
int    OPACITY_MAX   = 100

string GRP_CALCULATION    = "Calculation"
string GRP_CLASSIFICATION = "Classification"
string GRP_DISPLAY        = "Display"
string GRP_COLORS         = "Colors"
string INLINE_THRESHOLDS  = "thresholds"
string INLINE_COLORS_A    = "colorsA"
string INLINE_COLORS_B    = "colorsB"

color  DRY_DEFAULT      = #787b86ff
color  NORMAL_DEFAULT   = #4f7f8fff
color  HIGH_DEFAULT     = #d69e45ff
color  EXTREME_DEFAULT  = #d94f4fff
color  REFERENCE_COLOR  = #b2b5beff
color  LABEL_TEXT_COLOR = #ffffffff

string TIP_LOOKBACK = """Number of completed chart bars used for the baseline and percentile rank.
The current bar is excluded from both calculations."""
string TIP_BASELINE = """SMA uses the arithmetic mean of prior volume. Median is more resistant
to isolated volume spikes and is the default."""
string TIP_THRESHOLDS = """Percentile thresholds must increase from Dry-up to High to Extreme.
Classification uses percentile rank, not the relative-volume ratio."""
string TIP_OPACITY = """Opacity applied to histogram bars, optional price-bar coloring, and the
last-bar value label. Higher values are more opaque."""

//#endregion

//#region INPUTS ===============================================================

int             lookbackInput          = input.int(20, "Lookback (Bars)", minval = 2, maxval = LOOKBACK_MAX, group = GRP_CALCULATION, tooltip = TIP_LOOKBACK)
BaselineMethod  baselineMethodInput     = input.enum(BaselineMethod.median, "Baseline Method", group = GRP_CALCULATION, tooltip = TIP_BASELINE)

float           lowThresholdInput       = input.float(15.0, "Dry-up Below (%)", minval = 0.0, maxval = PERCENT_SCALE, group = GRP_CLASSIFICATION, inline = INLINE_THRESHOLDS, tooltip = TIP_THRESHOLDS)
float           highThresholdInput      = input.float(80.0, "High From (%)", minval = 0.0, maxval = PERCENT_SCALE, group = GRP_CLASSIFICATION, inline = INLINE_THRESHOLDS, tooltip = TIP_THRESHOLDS)
float           extremeThresholdInput   = input.float(95.0, "Extreme From (%)", minval = 0.0, maxval = PERCENT_SCALE, group = GRP_CLASSIFICATION, inline = INLINE_THRESHOLDS, tooltip = TIP_THRESHOLDS)

bool            showHistogramInput      = input.bool(true, "Show Histogram", group = GRP_DISPLAY)
bool            showReferenceInput      = input.bool(true, "Show Reference Line (Norm)", group = GRP_DISPLAY)
bool            colorPriceBarsInput     = input.bool(false, "Color Price Bars", group = GRP_DISPLAY)
bool            showValueLabelInput     = input.bool(false, "Show Value Label", group = GRP_DISPLAY)
int             textSizeInput           = input.int(12, "Text Size", minval = 10, maxval = 24, group = GRP_DISPLAY, active = showValueLabelInput)
int             opacityInput            = input.int(70, "Opacity (%)", minval = 0, maxval = OPACITY_MAX, group = GRP_DISPLAY, active = showHistogramInput or colorPriceBarsInput or showValueLabelInput, tooltip = TIP_OPACITY)

color           dryColorInput           = input.color(DRY_DEFAULT, "Dry-up", group = GRP_COLORS, inline = INLINE_COLORS_A, active = showHistogramInput or colorPriceBarsInput or showValueLabelInput)
color           normalColorInput        = input.color(NORMAL_DEFAULT, "Normal", group = GRP_COLORS, inline = INLINE_COLORS_A, active = showHistogramInput or colorPriceBarsInput or showValueLabelInput)
color           highColorInput          = input.color(HIGH_DEFAULT, "High", group = GRP_COLORS, inline = INLINE_COLORS_B, active = showHistogramInput or colorPriceBarsInput or showValueLabelInput)
color           extremeColorInput       = input.color(EXTREME_DEFAULT, "Extreme", group = GRP_COLORS, inline = INLINE_COLORS_B, active = showHistogramInput or colorPriceBarsInput or showValueLabelInput)

//#endregion

//#region FUNCTIONS ============================================================

// @function        Calculates the current value's percentile rank against prior bars only.
// @param source    (series float) Series whose current value is ranked.
// @param lookback  (simple int) Number of prior completed values in the comparison sample.
// @returns         (series float) Rank from 0 to 100, or na until the full sample is available.
percentileRank(series float source, simple int lookback) =>
    int lessOrEqualCount = 0
    int validCount = 0
    for offset = 1 to lookback
        float historicalValue = source[offset]
        if not na(historicalValue)
            validCount += 1
            if historicalValue <= source
                lessOrEqualCount += 1
    validCount == lookback and not na(source)
      ? PERCENT_SCALE * float(lessOrEqualCount) / float(lookback)
      : na

//#endregion

//#region CALCULATIONS =========================================================

bool thresholdsValid = lowThresholdInput < highThresholdInput
  and highThresholdInput < extremeThresholdInput
if barstate.isfirst and not thresholdsValid
    runtime.error("Classification thresholds must satisfy Dry-up < High < Extreme.")

float smaBaseline = ta.sma(volume[1], lookbackInput)
float medianBaseline = ta.median(volume[1], lookbackInput)
float baseline = baselineMethodInput == BaselineMethod.sma ? smaBaseline : medianBaseline
float rvol = not na(baseline) and baseline != 0.0 ? volume / baseline : 0.0
float percentile = bar_index >= lookbackInput ? percentileRank(volume, lookbackInput) : na
bool warmedUp = thresholdsValid and bar_index >= lookbackInput and not na(percentile)

int volumeState = not warmedUp ? STATE_NORMAL
  : percentile < lowThresholdInput ? STATE_DRY_UP
  : percentile < highThresholdInput ? STATE_NORMAL
  : percentile < extremeThresholdInput ? STATE_HIGH
  : STATE_EXTREME

int transparency = OPACITY_MAX - opacityInput
color dryColor = color.new(dryColorInput, transparency)
color normalColor = color.new(normalColorInput, transparency)
color highColor = color.new(highColorInput, transparency)
color extremeColor = color.new(extremeColorInput, transparency)
color stateColor = volumeState == STATE_DRY_UP ? dryColor
  : volumeState == STATE_HIGH ? highColor
  : volumeState == STATE_EXTREME ? extremeColor
  : normalColor

bool previousReady = bar_index > lookbackInput and not na(percentile[1])
bool extremeAlert = barstate.isconfirmed and previousReady
  and volumeState == STATE_EXTREME and volumeState[1] != STATE_EXTREME
bool highAlert = barstate.isconfirmed and previousReady
  and volumeState >= STATE_HIGH and volumeState[1] < STATE_HIGH
bool dryUpAlert = barstate.isconfirmed and previousReady
  and volumeState == STATE_DRY_UP and volumeState[1] != STATE_DRY_UP

//#endregion

//#region VISUALS ==============================================================

plot(
  showHistogramInput and warmedUp ? rvol : na,
  title = "Relative Volume",
  color = stateColor,
  style = plot.style_histogram,
  histbase = 0.0,
  linewidth = 3)
plot(
  showReferenceInput ? RVOL_NORM : na,
  title = "Norm",
  color = color.new(REFERENCE_COLOR, 45),
  linewidth = 1)

barcolor(colorPriceBarsInput and warmedUp ? stateColor : na)

var label rvolLabel = na
if barstate.islast
    if showValueLabelInput and warmedUp
        if na(rvolLabel)
            rvolLabel := label.new(bar_index, rvol, "", size = textSizeInput)
        label.set_xy(rvolLabel, bar_index, rvol)
        label.set_text(rvolLabel, str.tostring(rvol, "#.##") + "x")
        label.set_style(rvolLabel, label.style_label_left)
        label.set_color(rvolLabel, stateColor)
        label.set_textcolor(rvolLabel, LABEL_TEXT_COLOR)
    else if not na(rvolLabel)
        label.delete(rvolLabel)
        rvolLabel := na

//#endregion

//#region ALERTS ===============================================================

alertcondition(
  extremeAlert, "Relative Volume - Extreme",
  "Relative Volume entered Extreme on a confirmed bar.")
alertcondition(
  highAlert, "Relative Volume - High",
  "Relative Volume entered High or higher on a confirmed bar.")
alertcondition(
  dryUpAlert, "Relative Volume - Dry-up",
  "Relative Volume entered Dry-up on a confirmed bar.")

//#endregion
````
