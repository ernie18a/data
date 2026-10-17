# Runs Test Z-Score

- url: https://www.tradingview.com/script/3Q14pPb3-Runs-Test-Z-Score/
- type: indicator
- pine_id: PUB;930198f64a3d49048ed95063fa1f8b32
- version: 1.0

## Description

# Runs Test Z-Score

## What It Is

The Runs Test Z-Score is a statistical time-series indicator that applies the Wald-Wolfowitz Runs Test to directional price change sequences to measure departures from randomness.

Advantages: The Runs Test is non-parametric, simple to compute, and does not require assumptions about the distribution of returns.

Limitations: It considers only the direction of price changes, ignoring their magnitude, and may have limited power to detect more complex forms of dependence.

Runs are uninterrupted sequences of the same directional state. For example, the sequence (+, +, +, −, −, +, +) forms three runs: (+++), (--), and (++). The Runs Test compares the observed number of runs to the number expected under pure randomness to determine whether price changes exhibit persistence, anti-persistence (alternation), or random sequencing.

The indicator evaluates the **sequential randomness of price changes** to determine whether directional movements occur in a manner consistent with a random walk, or whether they exhibit persistent or alternating structural behavior.

The indicator produces a standardized Z-score:
**Negative values** indicate persistence (fewer directional state changes than expected under randomness).
**Values near zero** indicate random-like sequencing.
**Positive values** indicate anti-persistence (more directional state changes than expected under randomness).

Three independent price sequences can be analyzed:

### 1. Close-to-Close
Measures the sequential pattern of where price closed on the current bar relative to the previous bar's close. It captures the net directional outcome between consecutive intervals, incorporating all activity—including overnight or weekend gaps—while ignoring the path taken within the bar itself. This is typically the broadest, most aggregated mode.

### 2. Open-to-Close
Measures the sequential pattern of directional movement strictly *within* each bar by comparing the close to the open. Positive states indicate an upward drive during the session; negative states indicate a downward drive. This sequence reveals whether intraday or intra-bar directional drive tends to persist or alternate through time.

### 3. Midpoint Position
Measures where price closes relative to the high-low midpoint of each bar. A close above the midpoint indicates that buyers controlled the final portion of the bar's range, while a close below indicates seller control. This pattern captures whether range-control dominance tends to persist or alternate across consecutive bars, regardless of the net change between closes.

---

## What Divergence Means in Practice

Divergence is not a failure of the indicator. It is the indicator revealing something more precise than any single sequence could.

The three sequences measure distinct aspects of price behavior. When they diverge, they reveal structural differences in how directional progression, intra-bar drive, and range control are expressed through sequential price changes.

**All Three Agree:** Sequential structure is highly coherent across inter-bar direction, intra-bar drive, and range control. Price changes are expressing a consistent behavioral pattern across all three dimensions of price action.

**Close-to-Close Persists | Open-to-Close is Random:** The broader trend is being carried primarily by net bar-to-bar advances — including gap contributions — rather than persistent intra-bar directional drive.

**Open-to-Close Persists | Close-to-Close is Random:** Bars exhibit consistent internal directional drive, but that drive does not translate into sequential progress across bars. Strong movement occurs within sessions, but net inter-session direction remains inconsistent.

**Midpoint Position Diverges From Both:** Intra-bar auction control is decoupled from directional movement. Buyers or sellers may be consistently dominating the close of the bar's range even while net trend progression and intra-bar drive remain mixed or random.

**Close-to-Close & Open-to-Close Agree | Midpoint Disagrees:** Directional movement is consistent both within and between bars, but closing location within the range suggests underlying auction dynamics are less consistent with the prevailing directional movement. Trend progression and range control are actively diverging.

**Open-to-Close & Midpoint Agree | Close-to-Close Disagrees:** Intra-bar directional drive and range control are aligned, but that internal behavior fails to translate into persistent directional progression across consecutive bars.

**Close-to-Close & Midpoint Agree | Open-to-Close Disagrees:** Directional progression and range control are aligned, but movement occurring within individual bars lacks persistence. Price changes are making net progress despite inconsistent intra-bar drive.

**All Three Disagree:** Structural signals are mixed across all three dimensions, indicating low agreement regarding the prevailing sequential regime.

---

## Why It Was Built

Most technical indicators focus on trend strength, momentum, volatility, or price efficiency. Far fewer attempt to quantify the underlying sequencing structure of consecutive price changes. 

Sequential price changes can produce identical net price movements while exhibiting entirely different internal structures:

**Persistent sequences** contain fewer directional state changes than expected under a random process.
**Random sequences** exhibit no detectable departure from random ordering.
**Alternating sequences** contain more directional state changes than expected under a random process.

Understanding which structural environment currently dominates provides objective, statistical context for trend-following systems, mean-reversion approaches, pattern analysis, and price structure assessment.

---

## Core Concepts

### Persistence
Persistence occurs when directional moves tend to continue. In a persistent environment, state changes occur less frequently than expected under randomness. This produces fewer overall runs and yields a negative Z-score.

### Randomness
Randomness refers to the *ordering* of directional outcomes, not the overall trend vector. Prices can trend strongly while still exhibiting random directional sequencing. Trend direction and sequential randomness are separate price properties. Price may trend upward while directional changes remain statistically random. Z-scores near zero indicate no detectable departure from random sequencing.

### Anti-Persistence
Anti-persistence occurs when directional states alternate more frequently than expected under randomness. This produces more runs than predicted by a random process and results in a positive Z-score.

### Partition Methods

The indicator offers two distinct classification models:

**Zero-Split:** Partitions observations around zero. This mode preserves directional bias and trend influence, measuring randomness while retaining directional drift. Useful when directional bias is core to the analysis.

**Median-Split:** Partitions observations around the rolling median. This removes directional imbalance from the classification process, isolating sequencing behavior from the overarching trend direction. 

Comparing both modes helps distinguish persistence arising from directional drift from persistence arising from the sequencing structure itself.

---

## Z-Score Interpretation

| Zone | Z-Score | Structural Interpretation |

🟦 **Strong Persistence** | Z ≤ −1.96 | Sequential changes tend to persist (+/+ or −/−) rather than alternate. 

🔵 **Mild Persistence** | −1.96 < Z ≤ −1.0 | Increasing evidence of continuations in sequential price changes. 

⬜ **Random-Like** | −1.0 < Z ≤ 1.0 | No detectable sequential structure; outcomes occur with similar frequency. 

🟨 **Mild Anti-Persistence** | 1.0 < Z < 1.96 | Increasing evidence of alternations (+/− or −/+) in price changes. 

🟧 **Strong Anti-Persistence** | Z ≥ 1.96 | Sequential changes alternate (+/− or −/+) rather than persist. 

Color Legend: Dark Blue = Strong Persistence, Light Blue = Mild Persistence, Gray = Random-Like, Light Orange = Mild Anti-Persistence, Dark Orange = Strong Anti-Persistence.

**Statistical Note:** The ±1.96 thresholds correspond to the conventional 5% two-tailed significance level. Values beyond these thresholds indicate statistically significant departures from randomness under the assumptions of the Runs Test. Intermediate zones represent varying degrees of structural evidence but should be interpreted as descriptive rather than formally significant.

---

## Empirical Validation

Validation was conducted using approximately 150,000 daily observations across 50 liquid U.S. equities, ETFs, and sector funds spanning roughly ten years of market history. Lookback periods of 20, 30, and 40 bars were evaluated. Results confirmed that runs-based measurements reliably isolate structural shifts in sequential price behavior.

The study demonstrated:
* Correct regime ordering across all 50 tested securities.
* Stable structural readings that persist beyond short-term noise.
* Consistent behavior across multiple lookback settings.
* Strong correspondence with serial dependence metrics.
*Essentially no correlation with Efficiency Ratio (Kaufman) measurements.**

This final finding strongly suggests that sequential randomness and trend efficiency measure distinct price sequence properties. Price changes can exhibit highly efficient directional travel while still displaying random sequencing, or vice versa. This makes the Runs Test Z-Score a valuable complementary tool rather than a duplicate of existing efficiency or momentum indicators.

---

## How To Use It

**Contextualizing Chart Patterns:** Continuation patterns (flags, channels) implicitly assume a persistent environment. Reversal patterns (double tops and exhaustion structures) are often associated with a breakdown in persistent directional movement, making alternating price changes more likely than continued runs in the same direction. Use the Z-score to determine if the price sequence  structure statistically supports the pattern type forming on your chart. When the Runs Test indicates randomness, apparent technical patterns should be interpreted with caution, since their formation may be attributable to chance rather than persistent price behavior.

**Selecting Lookback Periods:** Shorter lookbacks increase responsiveness to structural change but are more sensitive to sampling variability. Longer lookbacks improve stability by filtering short-term noise and highlighting broader regime behavior.

**Applying Partitions:** Monitor the gap between Zero-Split and Median-Split. If Zero-Split shows strong persistence but Median-Split looks random, the non-randomness is entirely driven by directional drift (the trend), not the underlying sequencing mechanics.

**EMA Smoothing:** The optional EMA smoothing layer serves as a visual aid, improving interpretability and helping users track the indicator's underlying trend. Statistical interpretation should always remain anchored to the raw Z-score levels.

---

## Disclaimers & Limitations

This indicator is a descriptive statistical measurement tool, not a predictive trading system. The Runs Test Z-Score evaluates historical directional sequencing and does not forecast future price behavior. Persistent, random, or alternating conditions observed in the past do not guarantee the continuation of those regimes. It should be utilized as contextual analysis alongside proper risk management protocols.

## Source Code

````pine
//@version=6
indicator("Runs Test Z-Score", overlay = false, max_bars_back = 500)

//© TrendAdvantage
// ═══════════════════════════════════════════════════
// Runs Test Z-Score
// ═══════════════════════════════════════════════════
// Description:
// Applies the Wald-Wolfowitz Runs Test to price
// sequences to measure departures from randomness.
// A statistically significant negative Z indicates
// persistence (fewer state changes than expected);
// a significant positive Z indicates anti-persistence
// (more state changes than expected).
//
// Three sequences evaluated:
//   Close-to-Close  — directional price changes
//   Open-to-Close   — intraday directional drive
//   Midpoint        — close relative to the
//                     High-Low midpoint
//
// Two partition modes:
//   Zero-Split      — partitions on zero,
//                     preserving directional drift
//   Median-Split    — partitions on the rolling
//                     median, removing directional
//                     drift
// ═══════════════════════════════════════════════════
// License: Mozilla Public License 2.0 (MPL-2.0)
// https://mozilla.org/MPL/2.0/
//
// This source code is subject to the terms of the MPL 2.0.
// Any derivative work must retain this copyright notice.
// ═══════════════════════════════════════════════════
// TradingView: tradingview.com/u/TrendAdvantage
// ============================================================
// HOUSE RULES COMPLIANCE & RISK DISCLAIMER
// ============================================================
// This indicator is an econometric measurement tool.
// Past sequence characteristics do not guarantee
// future market behavior. All outputs are descriptive
// statistical evidence and do not guarantee future results.
//=====================================================

//=====================================================
// INPUTS
//=====================================================

lookback = input.int(
     60,
     "Lookback Length",
     minval = 20,
     tooltip = "Rolling window for randomness evaluation (min. 20). Shorter windows react faster but produce noisier readings; longer windows are more stable but slower to reflect changing conditions.")

partitionMode = input.string(
     "Zero-Split",
     "Partition Mode",
     options = ["Zero-Split", "Median-Split"],
     tooltip = "Zero-Split: Measures randomness in a sequence while preserving directional drift-use to include directional bias in the randomness measurement (movement dependent on trend direction). Median-Split: Measures randomness in a sequence regardless of trend direction by removing directional drift— use to isolate randomness from directional bias (movement independent of trend direction).")
     
//=====================================================
// CONTINUOUS SERIES
//=====================================================

CloseToCloseValue = close - close[1]

OpenToCloseValue = close - open

barMidpoint = (high + low) / 2.0
midpointValue = close - barMidpoint

//=====================================================
// ROLLING MEDIANS
//=====================================================

CloseToCloseMedian =
     partitionMode == "Median-Split" ?
     ta.percentile_nearest_rank(CloseToCloseValue, lookback, 50) :
     na

OpenToCloseMedian =
     partitionMode == "Median-Split" ?
     ta.percentile_nearest_rank(OpenToCloseValue, lookback, 50) :
     na

midpointMedian =
     partitionMode == "Median-Split" ?
     ta.percentile_nearest_rank(midpointValue, lookback, 50) :
     na

//=====================================================
// STATE ASSIGNMENT
//
// Returns:
//   1  = Positive State
//   0  = Negative State
//  na  = Tie (excluded)
//=====================================================

f_state(src, med, mode) =>

    float threshold = mode == "Zero-Split" ? 0.0 : med

    int state = na

    if src > threshold
        state := 1
    else if src < threshold
        state := 0
    else
        state := na

    state

CloseToCloseState = f_state(CloseToCloseValue, CloseToCloseMedian, partitionMode)
OpenToCloseState = f_state(OpenToCloseValue, OpenToCloseMedian, partitionMode)
midpointState = f_state(midpointValue, midpointMedian, partitionMode)

//=====================================================
// RUNS TEST FUNCTION
//=====================================================
f_runs_z(stateSeries, length) =>

    int n1 = 0
    int n0 = 0
    int runs = 0

    int prevState = na

    bool firstValid = true

    for i = 0 to length - 1

        currentState = stateSeries[i]

        if not na(currentState)

            if currentState == 1
                n1 += 1
            else
                n0 += 1

            if firstValid
                runs += 1
                prevState := currentState
                firstValid := false
            else
                if currentState != prevState
                    runs += 1
                    prevState := currentState

    int n = n1 + n0

    float z = na

    if n1 > 0 and n0 > 0 and n > 1

        expectedRuns =
             1.0 +
             (2.0 * n1 * n0) / n

        varianceRuns =
             (2.0 * n1 * n0 *
             (2.0 * n1 * n0 - n1 - n0)) /
             (math.pow(n, 2) * (n - 1))

        if varianceRuns > 0

            z :=
                 (runs - expectedRuns) /
                 math.sqrt(varianceRuns)

    z



//=====================================================
// Z-SCORES
//=====================================================

CloseToCloseZ = f_runs_z(CloseToCloseState, lookback)

OpenToCloseZ = f_runs_z(OpenToCloseState, lookback)

midpointZ = f_runs_z(midpointState, lookback)


//=====================================================
// PART 2
// DISPLAY / COLOR / SMOOTHING LAYER
//=====================================================
isLightTheme = color.r(chart.bg_color) > 128
paneColor    = isLightTheme ? color.rgb(250, 248, 240) : color.rgb(10, 10, 18)
bgcolor(paneColor, title = "Pane Background")
//-----------------------------------------------------
// DISPLAY INPUTS
//-----------------------------------------------------

showCloseToClose = input.bool(
     true,
     "Show Close to Close",
     tooltip = "Close compared to prior Close. Measures the sequential randomness of directional price changes.")

showOpenToClose = input.bool(
     false,
     "Show Open to Close",
     tooltip = "Close compared to Open. Measures the sequential randomness of intraday directional movement.")

showmidpoint = input.bool(
     false,
     "Show Midpoint Position",
     tooltip = "Close compared to the High-Low midpoint. Measures the sequential randomness of closing position within each bar.")

enableSmooth = input.bool(
     false,
     "Enable EMA Smoothing",
     tooltip = "Smoothing applied to the displayed Z-score for visual clarity. The underlying Runs Test calculation is unaffected. ")

emaLength = input.int(
     5,
     "EMA Length",
     minval = 3,
     maxval = 10,
     tooltip = "Length of the EMA applied to the displayed Runs Test Z-score. 3 to 5: light smoothing, preserves responsiveness,7 to10: moderate smoothing, useful if you want cleaner visual signal lines.")

//-----------------------------------------------------
// DISPLAY SERIES
//
// Raw Z remains the statistical measurement.
// EMA is optional visualization only.
//-----------------------------------------------------
f_display(src) =>
    enableSmooth ? ta.ema(src, emaLength) : src

CloseToClosePlot = f_display(CloseToCloseZ)

OpenToClosePlot = f_display(OpenToCloseZ)

midpointPlot = f_display(midpointZ)

//-----------------------------------------------------
// COLOR CLASSIFICATION
//
// IMPORTANT:
//
// Colors are classified using RAW Z values,
// not smoothed values.
//
// Reference levels remain tied to raw
// Runs Test interpretation.
//-----------------------------------------------------

f_stateColor(z) =>
    color c = color.gray

    if z <= -1.96
        c := color.rgb(0, 70, 180)          // Strong Persistence

    else if z <= -1.0
        c := color.rgb(100, 170, 255)       // Mild Persistence

    else if z <= 1.0
        c := color.gray                     // Random-Like

    else if z < 1.96
        c := color.rgb(255, 190, 100)       // Mild Anti-Persistence

    else
        c := color.rgb(220, 120, 0)         // Strong Anti-Persistence

    c

//-----------------------------------------------------
// COLORS
//-----------------------------------------------------

CloseToCloseColor  = f_stateColor(CloseToCloseZ)

OpenToCloseColor  = f_stateColor(OpenToCloseZ)

midpointColor = f_stateColor(midpointZ)

//-----------------------------------------------------
// PLOTS
//-----------------------------------------------------

plot(
     showCloseToClose ? CloseToClosePlot : na,
     title = "Close to Close",
     color = CloseToCloseColor,
     linewidth = 3)

plot(
     showOpenToClose ? OpenToClosePlot : na,
     title = "Open to Close Drive",
     color = OpenToCloseColor,
     linewidth = 2)

plot(
     showmidpoint ? midpointPlot : na,
     title = "Midpoint Position",
     color = midpointColor,
     linewidth = 1)

//-----------------------------------------------------
// REFERENCE LEVELS
//
// These levels apply to the RAW Runs Test
// interpretation regardless of smoothing.
//-----------------------------------------------------

hline(
     1.96,
     "Strong Anti-Persistence",
     color = color.new(color.gray, 70))

hline(
     1.00,
     "Mild Anti-Persistence",
     color = color.new(color.gray, 80))

hline(
     0.00,
     "Random-Like",
     color = color.new(color.gray, 50))

hline(
     -1.00,
     "Mild Persistence",
     color = color.new(color.gray, 80))

hline(
     -1.96,
     "Strong Persistence",
     color = color.new(color.gray, 70))
     //=====================================================
// PART 3
// TOGGLEABLE LEGEND
//=====================================================

showLegend = input.bool(
     true,
     "Show Legend",
     tooltip = "Displays a legend describing the Z-score color classification scheme.")

// ─────────────────────────────────────────────────
// LEGEND TABLE
// ─────────────────────────────────────────────────
var table legendTbl = table.new(
  position.middle_right, 2, 7,
  bgcolor      = color.rgb(20, 20, 20),
  frame_color  = color.rgb(60, 60, 60),
  frame_width  = 1,
  border_color = color.rgb(60, 60, 60),
  border_width = 1)

// ─────────────────────────────────────────────────
// DRAW LEGEND
// ────────────────────────────────────────────────

if barstate.islast

    table.clear(legendTbl, 0, 0, 1, 6)

    if showLegend

        // ── Header ────────────────────────────────

        table.cell(
             legendTbl, 0, 0,
             "ZONE",
             bgcolor    = color.rgb(30, 30, 30),
             text_color = color.white,
             text_size  = size.small)

        table.cell(
             legendTbl, 1, 0,
             "Z-SCORE INTERPRETATION ",
             bgcolor    = color.rgb(30, 30, 30),
             text_color = color.white,
             text_size  = size.small)

        // ── Strong Persistence ────────────────────

        table.cell(
             legendTbl, 0, 1,
             "",
             width   = 0,
             text_size = size.small,
             bgcolor = color.rgb(0, 45, 110))

        table.cell(
             legendTbl, 1, 1,
             "Z ≤ −1.96  Strong Persistence",
             bgcolor    = color.rgb(20, 20, 20),
             text_color = color.white,
             text_size  = size.small)

        // ── Mild Persistence ──────────────────────

        table.cell(
             legendTbl, 0, 2,
             "",
             width   = 0,
             text_size = size.small,
             bgcolor = color.rgb(120, 165, 225))

        table.cell(
             legendTbl, 1, 2,
             "−1.96 < Z ≤ −1.0  Mild Persistence",
             bgcolor    = color.rgb(20, 20, 20),
             text_color = color.white,
             text_size  = size.small)

        // ── Random-Like ───────────────────────────

        table.cell(
             legendTbl, 0, 3,
             "",
             width   = 0,
             text_size = size.small,
             bgcolor = color.rgb(80, 80, 80))

        table.cell(
             legendTbl, 1, 3,
             "−1.0 < Z ≤ 1.0  Random-Like",
             bgcolor    = color.rgb(20, 20, 20),
             text_color = color.white,
             text_size  = size.small)

        // ── Mild Anti-Persistence ─────────────────

        table.cell(
             legendTbl, 0, 4,
             "",
             width   = 0,
             text_size = size.small,
             bgcolor = color.rgb(235, 185, 120))

        table.cell(
             legendTbl, 1, 4,
             "1.0 < Z < 1.96  Mild Anti-Persistence",
             bgcolor    = color.rgb(20, 20, 20),
             text_color = color.white,
             text_size  = size.small)

        // ── Strong Anti-Persistence ───────────────

        table.cell(
             legendTbl, 0, 5,
             "",
             width   = 0,
             text_size = size.small,
             bgcolor = color.rgb(150, 75, 0))

        table.cell(
             legendTbl, 1, 5,
             "Z ≥ 1.96  Strong Anti-Persistence",
             bgcolor    = color.rgb(20, 20, 20),
             text_color = color.white,
             text_size  = size.small)
````
