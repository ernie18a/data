<!-- tradingview-pine-id: PUB;8e3a274614be4f1eb434bb71b966f380 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh — EMA Signature v2

Source: https://www.tradingview.com/script/Eg1J5JUh-Equalhigh-EMA-Signature/

## Description

Equalhigh — EMA Signature v2

### User Manual

**Equalhigh — EMA Signature v2** is an adaptive statistical support indicator designed to identify the EMA that a specific asset historically respects the most.

Instead of assuming that EMA 20, 50, 100, or 200 is automatically relevant, the indicator scans a configurable range of EMA periods and determines which one has historically produced the most reliable price rebounds.

The objective is to identify the asset's own **EMA Signature**.

---

## Concept

Different securities often react to different moving-average periods.

One stock may repeatedly rebound from EMA 21, another from EMA 34, another from EMA 57.

This indicator attempts to quantify that behavior by testing many EMA candidates and ranking them according to their historical effectiveness as dynamic support.

The strongest EMA is plotted directly on the chart.

The second-best EMA can also be displayed.

---

## How It Works

For every EMA candidate, the indicator looks for historical support tests.

A valid support test requires price to approach the EMA from above and enter a tolerance zone around the EMA.

Once the EMA is touched, the indicator observes the following candles and evaluates whether price produces a meaningful rebound.

Each EMA is evaluated using several statistics:

* Number of historical tests
* Number of successful rebounds
* Hit rate
* Average rebound magnitude
* Frequency of support breakdowns
* Statistical confidence
* Sample size

The highest-ranked EMA becomes the current **EMA Signature**.

---

# EMA Signature Score

The indicator does not simply choose the EMA with the highest raw win rate.

A result such as:

**EMA 137: 2 successful rebounds out of 2 = 100%**

should not automatically beat:

**EMA 34: 23 successful rebounds out of 30 = 76.7%**

The first result has too little statistical evidence.

For this reason, Equalhigh — EMA Signature uses a composite score.

### Score structure

* **65% — Statistical reliability**
* **15% — Rebound strength**
* **10% — Sample depth**
* **10% — Support integrity**

Statistical reliability uses a **Wilson lower confidence bound**, which penalizes very small samples.

This makes the ranking significantly more robust than a simple hit-rate comparison.

---

# Main Chart Elements

## Best EMA Signature

The strongest historical EMA is plotted as the main highlighted line.

The label displays:

**EMA period**

and

**Signature Score**

Example:

> ★ EMA 34
> Score 76.8

This means EMA 34 currently has the strongest statistical support profile among all EMA periods tested.

---

## Second-Best EMA

The second-highest-ranked EMA can optionally be displayed.

This is useful because some securities do not have one unique support EMA, but rather a cluster of closely related EMA periods.

For example:

* EMA 32
* EMA 34
* EMA 38

may all rank highly.

This can indicate a broader **dynamic support zone** rather than one exact mathematical line.

---

# Top 5 Dashboard

The dashboard ranks the five strongest EMA candidates.

### EMA

EMA period being evaluated.

Example:

**34**

means EMA 34.

---

### SCORE

The Equalhigh EMA Signature Score.

Higher values indicate stronger historical evidence that the EMA acts as dynamic support.

A practical interpretation:

|    Score | Interpretation        |
| -------: | --------------------- |
|      75+ | Very strong signature |
|    65–75 | Strong                |
|    55–65 | Moderate              |
|    45–55 | Weak                  |
| Below 45 | Low confidence        |

These levels should be interpreted comparatively rather than as absolute probabilities.

---

### TESTS

Number of historical support interactions detected for the EMA.

A larger sample generally increases confidence.

An EMA with 25–40 tests is statistically much more meaningful than one with only 3–5 tests.

---

### HIT

Percentage of historical EMA tests that produced the required rebound.

Example:

**78.6%**

means that approximately 79% of detected support tests met the selected rebound criteria.

---

### AVG

Average maximum rebound after successful EMA tests.

Example:

**+6.3%**

means successful historical tests produced an average maximum rebound of approximately 6.3% during the selected evaluation window.

---

### BREAK

Percentage of support tests where price clearly lost the EMA.

Lower is generally better.

Example:

**10.7%**

indicates relatively strong support integrity.

---

### BULL

Historical success rate when the support test occurred during the indicator's bullish market regime.

This allows the user to compare general EMA behavior with behavior during favorable market conditions.

---

# Rebound Detection

A support interaction is not counted simply because the candle touches the EMA.

The indicator checks several conditions.

### 1. Approach from above

Price must approach the EMA from above.

This is important because the indicator is specifically searching for **dynamic support**, not resistance.

---

### 2. EMA touch zone

Price does not need to touch the EMA perfectly.

A tolerance based on ATR is used.

This is more realistic than requiring exact contact because markets rarely reverse at mathematically perfect levels.

---

### 3. Support must remain valid

Price is allowed to temporarily move slightly below the EMA.

However, a sufficiently large close below the EMA is treated as a support failure.

---

### 4. Rebound confirmation

After the EMA interaction, price must rise by the selected minimum percentage within the selected evaluation window.

Example:

**Minimum rebound = 3%**

**Evaluation window = 10 bars**

A successful test requires price to produce at least a 3% rebound during the following 10 candles.

---

# Settings

## Minimum EMA

Defines the shortest EMA included in the scan.

Default:

**10**

---

## Maximum EMA

Defines the longest EMA included in the scan.

Default:

**250**

---

## EMA Step

Controls the distance between tested EMA periods.

Example:

Minimum EMA = 10
Maximum EMA = 250
Step = 5

The indicator tests:

10, 15, 20, 25, 30...250

### Recommended

Use:

**5** for fast exploration

**2** for normal use

**1** for maximum precision

A Step of 1 allows unusual signatures such as:

EMA 37
EMA 43
EMA 61

to be discovered.

---

# Statistical Lookback

Defines how much historical data is used to evaluate each EMA.

Default:

**750 bars**

On a Daily chart, this represents roughly three years of trading history.

A longer lookback provides more observations but may include outdated market behavior.

A shorter lookback adapts faster to structural changes but reduces sample size.

---

# EMA Touch Tolerance — ATR

Defines how close price must come to the EMA to qualify as a support test.

Default:

**0.20 ATR**

ATR-based tolerance automatically adapts to the volatility of the security.

This makes the indicator more transferable between low-volatility stocks and highly volatile assets.

---

# Maximum Break Tolerance — ATR

Determines how far price may close below the EMA before the support is considered broken.

Default:

**0.35 ATR**

Increasing this value allows more temporary undercuts.

Decreasing it makes support validation stricter.

---

# Rebound Evaluation Window

Number of bars available for price to confirm a rebound.

Default:

**10 bars**

On a Daily chart:

10 bars ≈ two trading weeks.

---

# Minimum Rebound %

Defines the minimum move required for an EMA interaction to be classified as successful.

Default:

**3%**

For volatile securities, a larger requirement may be appropriate.

For defensive or low-volatility securities, a smaller value may be preferable.

---

# Minimum Number of Tests

Defines the minimum historical sample required before an EMA can qualify for the ranking.

Default:

**5**

Increasing this value makes the model more selective.

For long historical datasets, values between **7 and 10** may provide stronger statistical confidence.

---

# Touch Cooldown

Prevents several consecutive candles around the same EMA from being counted as separate independent support events.

Default:

**5 bars**

Without a cooldown, one prolonged consolidation around an EMA could artificially create many support tests.

---

# Suggested Daily Settings

For most liquid equities:

| Setting              | Suggested value |
| -------------------- | --------------: |
| Minimum EMA          |              10 |
| Maximum EMA          |             250 |
| EMA Step             |               2 |
| Statistical Lookback |             750 |
| Touch Tolerance      |        0.20 ATR |
| Break Tolerance      |        0.35 ATR |
| Rebound Window       |         10 bars |
| Minimum Rebound      |              3% |
| Minimum Tests        |               5 |
| Cooldown             |          5 bars |

---

# Practical Workflow

A useful workflow is to start with:

**EMA 10 → 250**

**Step = 5**

This quickly identifies the broad area where the strongest EMA may exist.

For example, the results may show:

EMA 30
EMA 35
EMA 40

as the strongest group.

The user can then change:

**Step = 1**

to perform a finer scan.

The final result may reveal something such as:

> EMA 34 — Score 77

This becomes the asset's current **EMA Signature**.

---

# How to Use the Indicator

EMA Signature should generally be treated as a **support context tool**, not as a standalone buy signal.

The setup becomes more interesting when price approaches the Best EMA while other factors confirm the level.

Examples include:

* Rising volume on the rebound
* Bullish candle structure
* Relative strength improvement
* Previous horizontal support
* Gap support
* Fair Value zone
* Oversold momentum
* Positive market regime
* Higher-timeframe trend alignment

The strongest opportunities generally occur when several independent forms of support converge around the same price level.

---

# Example

Suppose the indicator identifies:

**EMA 36**

with:

* Score: 78
* Tests: 27
* Hit rate: 81%
* Average rebound: +6.4%
* Break rate: 11%

Price then falls back toward EMA 36.

This does **not** mean the stock has an 81% probability of rising.

It means that, according to the historical rules selected in the indicator, EMA 36 has produced successful rebounds in approximately 81% of comparable historical interactions.

The current market context still matters.

---

# Why the Best EMA Can Change

EMA Signature is adaptive.

The best EMA may change because:

* volatility changes,
* market regime changes,
* the stock enters a stronger trend,
* institutional behavior changes,
* historical observations are added,
* old observations leave the lookback window.

For example:

EMA 50 may dominate during a slow long-term trend.

Later, EMA 21 may become dominant during a strong momentum phase.

This is intentional.

---

# Important Statistical Considerations

Historical interactions are not fully independent events.

EMA periods are also highly correlated.

For example:

EMA 34 and EMA 35 will naturally produce similar values.

Therefore, the indicator should not be interpreted as discovering a mathematically unique "perfect EMA".

A group such as:

EMA 32
EMA 34
EMA 36

should often be interpreted as a **support family or support zone**.

---

# Limitations

The indicator is based on historical price behavior.

It cannot anticipate:

* earnings surprises,
* profit warnings,
* regulatory decisions,
* macroeconomic shocks,
* geopolitical events,
* takeover announcements,
* major fundamental changes.

A historically strong EMA can fail abruptly when market conditions change.

The model also does not prove causality.

Price may appear to react to an EMA because the EMA overlaps with another important technical or fundamental price level.

---

# Best Use

Equalhigh — EMA Signature v2 is particularly useful for:

* Pullback trading
* Trend continuation setups
* Swing trading
* Dynamic support analysis
* Finding non-standard EMA periods
* Comparing support quality between securities
* Identifying repeated institutional price behavior
* Locating potential re-entry zones after a trend pullback

---

## Final Principle

Traditional technical analysis asks:

> **Does this stock respect EMA 20, EMA 50 or EMA 200?**

Equalhigh — EMA Signature asks a different question:

> **Which EMA has this stock actually respected the most?**

The indicator then lets the historical data provide the answer.

---

**Equalhigh — EMA Signature v2**

*Adaptive EMA discovery through statistical rebound analysis.*

**Disclaimer:** This indicator is provided for research and educational purposes only. Historical statistical behavior does not guarantee future performance and should not be considered financial advice.

---

## Source Code

````pine
//@version=6
indicator(
     "Equalhigh — EMA Signature v2",
     shorttitle = "EMA Signature",
     overlay = true,
     max_bars_back = 5000,
     max_polylines_count = 10,
     max_labels_count = 50
)

// ╔════════════════════════════════════════════════════════════════════════════╗
// ║                     EQUALHIGH — EMA SIGNATURE v2                         ║
// ║                                                                            ║
// ║  Finds the EMA that historically acts as the most reliable dynamic        ║
// ║  support for the current security and timeframe.                           ║
// ╚════════════════════════════════════════════════════════════════════════════╝


// ═════════════════════════════════════════════════════════════════════════════
// 1. SCAN SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

groupScan = "1. EMA Scan"

minLen = input.int(
     10,
     "Minimum EMA",
     minval = 2,
     maxval = 500,
     group = groupScan
)

maxLen = input.int(
     250,
     "Maximum EMA",
     minval = 5,
     maxval = 500,
     group = groupScan
)

stepLen = input.int(
     2,
     "EMA Step",
     minval = 1,
     maxval = 25,
     group = groupScan,
     tooltip = "1 = maximum precision. 2 or 5 = faster."
)

lookbackBars = input.int(
     750,
     "Statistical lookback",
     minval = 100,
     maxval = 2500,
     group = groupScan
)


// ═════════════════════════════════════════════════════════════════════════════
// 2. SUPPORT / REBOUND DEFINITION
// ═════════════════════════════════════════════════════════════════════════════

groupDetection = "2. Rebound Definition"

atrLength = input.int(
     14,
     "ATR Length",
     minval = 5,
     maxval = 100,
     group = groupDetection
)

touchATR = input.float(
     0.20,
     "Touch tolerance — ATR",
     minval = 0.01,
     maxval = 2.0,
     step = 0.05,
     group = groupDetection
)

breakATR = input.float(
     0.35,
     "Support break tolerance — ATR",
     minval = 0.05,
     maxval = 3.0,
     step = 0.05,
     group = groupDetection
)

confirmBars = input.int(
     10,
     "Rebound evaluation window",
     minval = 2,
     maxval = 50,
     group = groupDetection
)

minBouncePct = input.float(
     3.0,
     "Minimum rebound %",
     minval = 0.25,
     maxval = 30,
     step = 0.25,
     group = groupDetection
)

minTests = input.int(
     5,
     "Minimum tests required",
     minval = 2,
     maxval = 50,
     group = groupDetection
)

cooldownBars = input.int(
     5,
     "Touch cooldown",
     minval = 0,
     maxval = 50,
     group = groupDetection
)


// ═════════════════════════════════════════════════════════════════════════════
// 3. DISPLAY SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

groupDisplay = "3. Display"

displayBars = input.int(
     500,
     "EMA history displayed",
     minval = 50,
     maxval = 1500,
     group = groupDisplay
)

showSecond = input.bool(
     true,
     "Show second-best EMA",
     group = groupDisplay
)

showTouchMarker = input.bool(
     true,
     "Mark current Best EMA tests",
     group = groupDisplay
)

showTable = input.bool(
     true,
     "Show Top 5 dashboard",
     group = groupDisplay
)

bestColor = input.color(
     color.aqua,
     "Best EMA",
     group = groupDisplay
)

secondColor = input.color(
     color.orange,
     "Second-best EMA",
     group = groupDisplay
)


// ═════════════════════════════════════════════════════════════════════════════
// 4. FUNCTIONS
// ═════════════════════════════════════════════════════════════════════════════

f_clamp01(float x) =>
    math.max(
         0.0,
         math.min(
              1.0,
              x
         )
    )


// Wilson lower confidence bound.
// Avoids stupid results such as:
//
// EMA 137 = 2/2 = 100%
// beating
// EMA 34 = 23/30 = 76.7%
//
// Statistical confidence is rewarded.

f_wilson(int wins, int tests) =>

    float result = 0.0

    if tests > 0

        float z = 1.645

        float n =
             float(tests)

        float p =
             float(wins) / n

        float denominator =
             1.0 +
             z * z / n

        float centre =
             p +
             z * z / (2.0 * n)

        float margin =
             z *
             math.sqrt(
                  (
                       p * (1.0 - p) +
                       z * z / (4.0 * n)
                  ) / n
             )

        result :=
             math.max(
                  0.0,
                  (centre - margin) /
                  denominator
             )

    result


// Composite EMA Signature score.
//
// 65% statistical reliability
// 15% rebound magnitude
// 10% sample depth
// 10% resistance to breakdowns

f_signature_score(
     int tests,
     int wins,
     int breaks,
     float avgSuccessMove,
     float minimumBounce,
     int minimumTests
 ) =>

    float result = 0.0

    if tests >= minimumTests

        float wilson =
             f_wilson(
                  wins,
                  tests
             )

        float bounceQuality =
             f_clamp01(
                  avgSuccessMove /
                  math.max(
                       minimumBounce * 2.0,
                       0.01
                  )
             )

        float sampleQuality =
             f_clamp01(
                  float(tests) /
                  math.max(
                       float(minimumTests * 3),
                       1.0
                  )
             )

        float breakRate =
             float(breaks) /
             float(tests)

        result :=
             100.0 *
             (
                  0.65 * wilson +
                  0.15 * bounceQuality +
                  0.10 * sampleQuality +
                  0.10 * (1.0 - breakRate)
             )

    result


// ═════════════════════════════════════════════════════════════════════════════
// 5. VALIDATION
// ═════════════════════════════════════════════════════════════════════════════

int candidateCount =
     int(
          math.floor(
               (maxLen - minLen) /
               stepLen
          )
     ) + 1


if barstate.isfirst

    if maxLen <= minLen
        runtime.error(
             "Maximum EMA must be greater than Minimum EMA."
        )

    if candidateCount > 250
        runtime.error(
             "Too many EMA candidates. Increase EMA Step."
        )


// ═════════════════════════════════════════════════════════════════════════════
// 6. ATR + MARKET REGIME
// ═════════════════════════════════════════════════════════════════════════════

float atr =
     ta.atr(
          atrLength
     )

float regimeEMA =
     ta.ema(
          close,
          200
     )

bool bullRegime =
     close > regimeEMA and
     regimeEMA > regimeEMA[10]


// ═════════════════════════════════════════════════════════════════════════════
// 7. CREATE EVERY EMA
// ═════════════════════════════════════════════════════════════════════════════
//
// Dynamic EMA lengths cannot simply be passed to ta.ema().
//
// We therefore calculate all candidate EMAs manually.
//
// Crucially, a NEW ARRAY is produced on every bar.
// Pine can then access historical array instances.
//
// ═════════════════════════════════════════════════════════════════════════════

array<float> emaNow =
     array.new_float(
          candidateCount,
          na
     )

array<float> emaPrevious =
     emaNow[1]


for i = 0 to candidateCount - 1

    int length =
         minLen +
         i * stepLen

    float alpha =
         2.0 /
         (
              float(length) +
              1.0
         )

    float previousEMA =
         na(emaPrevious) ?
         na :
         array.get(
              emaPrevious,
              i
         )

    float currentEMA =
         na(previousEMA) ?
         close :
         alpha * close +
         (1.0 - alpha) *
         previousEMA

    array.set(
         emaNow,
         i,
         currentEMA
    )


// ═════════════════════════════════════════════════════════════════════════════
// 8. STATISTICAL STORAGE
// ═════════════════════════════════════════════════════════════════════════════

var array<int> tests =
     array.new_int(
          candidateCount,
          0
     )

var array<int> wins =
     array.new_int(
          candidateCount,
          0
     )

var array<int> breaks =
     array.new_int(
          candidateCount,
          0
     )

var array<float> totalSuccessMove =
     array.new_float(
          candidateCount,
          0.0
     )

var array<float> totalTimeToTarget =
     array.new_float(
          candidateCount,
          0.0
     )


// Bull regime statistics

var array<int> bullTests =
     array.new_int(
          candidateCount,
          0
     )

var array<int> bullWins =
     array.new_int(
          candidateCount,
          0
     )


// Non-bull statistics

var array<int> bearTests =
     array.new_int(
          candidateCount,
          0
     )

var array<int> bearWins =
     array.new_int(
          candidateCount,
          0
     )


// ═════════════════════════════════════════════════════════════════════════════
// 9. ACTIVE SUPPORT TEST STORAGE
// ═════════════════════════════════════════════════════════════════════════════

var array<int> pendingAge =
     array.new_int(
          candidateCount,
          -1
     )

var array<float> pendingEntry =
     array.new_float(
          candidateCount,
          na
     )

var array<float> pendingMaxMove =
     array.new_float(
          candidateCount,
          0.0
     )

var array<bool> pendingSuccess =
     array.new_bool(
          candidateCount,
          false
     )

var array<int> pendingHitAge =
     array.new_int(
          candidateCount,
          -1
     )

var array<bool> pendingBull =
     array.new_bool(
          candidateCount,
          false
     )

var array<int> cooldown =
     array.new_int(
          candidateCount,
          0
     )


// ═════════════════════════════════════════════════════════════════════════════
// 10. STATISTICAL WINDOW
// ═════════════════════════════════════════════════════════════════════════════

bool insideWindow =
     bar_index >=
     last_bar_index -
     lookbackBars


// ═════════════════════════════════════════════════════════════════════════════
// 11. TEST EVERY EMA
// ═════════════════════════════════════════════════════════════════════════════

for i = 0 to candidateCount - 1

    float ema =
         array.get(
              emaNow,
              i
         )

    float previousEMA =
         na(emaPrevious) ?
         na :
         array.get(
              emaPrevious,
              i
         )


    // ─────────────────────────────────────────────────────────────────────
    // COOLDOWN
    // ─────────────────────────────────────────────────────────────────────

    int cd =
         array.get(
              cooldown,
              i
         )

    if cd > 0
        cd -= 1

    array.set(
         cooldown,
         i,
         cd
    )


    // ─────────────────────────────────────────────────────────────────────
    // EXISTING SUPPORT TEST
    // ─────────────────────────────────────────────────────────────────────

    int age =
         array.get(
              pendingAge,
              i
         )

    if age >= 0

        age += 1

        float entry =
             array.get(
                  pendingEntry,
                  i
             )

        float maxMove =
             array.get(
                  pendingMaxMove,
                  i
             )

        bool succeeded =
             array.get(
                  pendingSuccess,
                  i
             )

        int hitAge =
             array.get(
                  pendingHitAge,
                  i
             )

        bool wasBull =
             array.get(
                  pendingBull,
                  i
             )


        // Maximum upside excursion from support.

        float currentMove =
             entry > 0 ?
             (
                  high / entry -
                  1.0
             ) * 100.0 :
             0.0

        maxMove :=
             math.max(
                  maxMove,
                  currentMove
             )


        bool targetReached =
             maxMove >=
             minBouncePct

        bool supportBroken =
             close <
             ema -
             atr * breakATR


        bool finishFailure =
             false

        bool finishSuccess =
             false


        // Conservative assumption:
        //
        // If target AND breakdown occur on the same candle,
        // intrabar order is unknown.
        //
        // We count it as a failed support test.

        if not succeeded

            if supportBroken

                finishFailure := true

            else if targetReached

                succeeded := true
                hitAge := age


        // Once the target has been reached we continue
        // measuring the rebound until the end of the window.

        if succeeded and
           age >= confirmBars

            finishSuccess := true


        // No sufficient rebound before expiration.

        if not succeeded and
           age >= confirmBars

            finishFailure := true


        // ─────────────────────────────────────────────────────────────────
        // SUCCESS
        // ─────────────────────────────────────────────────────────────────

        if finishSuccess

            array.set(
                 tests,
                 i,
                 array.get(
                      tests,
                      i
                 ) + 1
            )

            array.set(
                 wins,
                 i,
                 array.get(
                      wins,
                      i
                 ) + 1
            )

            array.set(
                 totalSuccessMove,
                 i,
                 array.get(
                      totalSuccessMove,
                      i
                 ) +
                 maxMove
            )

            array.set(
                 totalTimeToTarget,
                 i,
                 array.get(
                      totalTimeToTarget,
                      i
                 ) +
                 float(hitAge)
            )


            if wasBull

                array.set(
                     bullTests,
                     i,
                     array.get(
                          bullTests,
                          i
                     ) + 1
                )

                array.set(
                     bullWins,
                     i,
                     array.get(
                          bullWins,
                          i
                     ) + 1
                )

            else

                array.set(
                     bearTests,
                     i,
                     array.get(
                          bearTests,
                          i
                     ) + 1
                )

                array.set(
                     bearWins,
                     i,
                     array.get(
                          bearWins,
                          i
                     ) + 1
                )


            array.set(
                 pendingAge,
                 i,
                 -1
            )

            array.set(
                 pendingEntry,
                 i,
                 na
            )

            array.set(
                 pendingMaxMove,
                 i,
                 0.0
            )

            array.set(
                 pendingSuccess,
                 i,
                 false
            )

            array.set(
                 pendingHitAge,
                 i,
                 -1
            )

            array.set(
                 cooldown,
                 i,
                 cooldownBars
            )


        // ─────────────────────────────────────────────────────────────────
        // FAILURE
        // ─────────────────────────────────────────────────────────────────

        else if finishFailure

            array.set(
                 tests,
                 i,
                 array.get(
                      tests,
                      i
                 ) + 1
            )


            // Actual confirmed break.

            if supportBroken

                array.set(
                     breaks,
                     i,
                     array.get(
                          breaks,
                          i
                     ) + 1
                )


            if wasBull

                array.set(
                     bullTests,
                     i,
                     array.get(
                          bullTests,
                          i
                     ) + 1
                )

            else

                array.set(
                     bearTests,
                     i,
                     array.get(
                          bearTests,
                          i
                     ) + 1
                )


            array.set(
                 pendingAge,
                 i,
                 -1
            )

            array.set(
                 pendingEntry,
                 i,
                 na
            )

            array.set(
                 pendingMaxMove,
                 i,
                 0.0
            )

            array.set(
                 pendingSuccess,
                 i,
                 false
            )

            array.set(
                 pendingHitAge,
                 i,
                 -1
            )

            array.set(
                 cooldown,
                 i,
                 cooldownBars
            )


        // ─────────────────────────────────────────────────────────────────
        // CONTINUE TEST
        // ─────────────────────────────────────────────────────────────────

        else

            array.set(
                 pendingAge,
                 i,
                 age
            )

            array.set(
                 pendingMaxMove,
                 i,
                 maxMove
            )

            array.set(
                 pendingSuccess,
                 i,
                 succeeded
            )

            array.set(
                 pendingHitAge,
                 i,
                 hitAge
            )


    // ═════════════════════════════════════════════════════════════════════
    // 12. DETECT NEW SUPPORT TOUCH
    // ═════════════════════════════════════════════════════════════════════

    age :=
         array.get(
              pendingAge,
              i
         )

    cd :=
         array.get(
              cooldown,
              i
         )

    float touchBand =
         atr *
         touchATR

    float breakBand =
         atr *
         breakATR


    // Price must approach the EMA from above.

    bool approachFromAbove =
         not na(previousEMA) and
         close[1] >
         previousEMA


    // Candle reaches EMA tolerance zone.

    bool touchesZone =
         low <=
         ema + touchBand and
         high >=
         ema - touchBand


    // Candle must not already be a confirmed breakdown.

    bool stillHolding =
         close >=
         ema - breakBand


    bool enoughHistory =
         bar_index >
         maxLen


    bool newTouch =
         insideWindow and
         enoughHistory and
         age == -1 and
         cd == 0 and
         approachFromAbove and
         touchesZone and
         stillHolding


    if newTouch

        array.set(
             pendingAge,
             i,
             0
        )

        // Rebound is measured from the EMA itself,
        // not from candle close.

        array.set(
             pendingEntry,
             i,
             ema
        )

        float firstMove =
             math.max(
                  0.0,
                  (
                       high / ema -
                       1.0
                  ) * 100.0
             )

        array.set(
             pendingMaxMove,
             i,
             firstMove
        )

        array.set(
             pendingSuccess,
             i,
             false
        )

        array.set(
             pendingHitAge,
             i,
             -1
        )

        array.set(
             pendingBull,
             i,
             bullRegime
        )


// ═════════════════════════════════════════════════════════════════════════════
// 13. FIND CURRENT BEST + SECOND BEST
// ═════════════════════════════════════════════════════════════════════════════

int bestIndex =
     -1

int secondIndex =
     -1

float bestScore =
     -1.0

float secondScore =
     -1.0


for i = 0 to candidateCount - 1

    int t =
         array.get(
              tests,
              i
         )

    int w =
         array.get(
              wins,
              i
         )

    int b =
         array.get(
              breaks,
              i
         )

    float avgMove =
         w > 0 ?
         array.get(
              totalSuccessMove,
              i
         ) /
         float(w) :
         0.0

    float score =
         f_signature_score(
              t,
              w,
              b,
              avgMove,
              minBouncePct,
              minTests
         )


    if t >= minTests

        if score > bestScore

            secondScore :=
                 bestScore

            secondIndex :=
                 bestIndex

            bestScore :=
                 score

            bestIndex :=
                 i

        else if score > secondScore

            secondScore :=
                 score

            secondIndex :=
                 i


// ═════════════════════════════════════════════════════════════════════════════
// 14. CURRENT BEST EMA VALUES
// ═════════════════════════════════════════════════════════════════════════════

float bestEMA =
     bestIndex >= 0 ?
     array.get(
          emaNow,
          bestIndex
     ) :
     na

float secondEMA =
     secondIndex >= 0 ?
     array.get(
          emaNow,
          secondIndex
     ) :
     na


// ═════════════════════════════════════════════════════════════════════════════
// 15. CURRENT TEST MARKER
// ═════════════════════════════════════════════════════════════════════════════

bool testingBest =
     bestIndex >= 0 and
     low <=
     bestEMA +
     atr * touchATR and
     high >=
     bestEMA -
     atr * touchATR


plotshape(
     showTouchMarker and
     testingBest,
     title = "Testing Best EMA",
     style = shape.diamond,
     location = location.belowbar,
     size = size.tiny,
     color = bestColor
)


// ═════════════════════════════════════════════════════════════════════════════
// 16. ALERT
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(
     testingBest,
     title = "Equalhigh — Best EMA Test",
     message = "Price is testing the Equalhigh EMA Signature support."
)


// ═════════════════════════════════════════════════════════════════════════════
// 17. DRAW FINAL EMA SIGNATURES
// ═════════════════════════════════════════════════════════════════════════════

var polyline bestGlow =
     na

var polyline bestLine =
     na

var polyline secondLine =
     na

var label bestLabel =
     na

var label secondLabel =
     na


if barstate.islast

    // Delete previous drawings.

    if not na(bestGlow)
        polyline.delete(
             bestGlow
        )

    if not na(bestLine)
        polyline.delete(
             bestLine
        )

    if not na(secondLine)
        polyline.delete(
             secondLine
        )

    if not na(bestLabel)
        label.delete(
             bestLabel
        )

    if not na(secondLabel)
        label.delete(
             secondLabel
        )


    // ─────────────────────────────────────────────────────────────────────
    // BEST EMA
    // ─────────────────────────────────────────────────────────────────────

    if bestIndex >= 0

        array<chart.point> bestPoints =
             array.new<chart.point>()

        int barsToDraw =
             math.min(
                  displayBars,
                  bar_index + 1
             )


        for offset = barsToDraw - 1 to 0

            array<float> historicalArray =
                 emaNow[offset]

            if not na(historicalArray)

                float historicalEMA =
                     array.get(
                          historicalArray,
                          bestIndex
                     )

                if not na(historicalEMA)

                    array.push(
                         bestPoints,
                         chart.point.from_index(
                              bar_index - offset,
                              historicalEMA
                         )
                    )


        if array.size(bestPoints) >= 2

            // Glow

            bestGlow :=
                 polyline.new(
                      bestPoints,
                      curved = false,
                      closed = false,
                      xloc = xloc.bar_index,
                      line_color = color.new(
                           bestColor,
                           82
                      ),
                      line_width = 8,
                      force_overlay = true
                 )

            // Main line

            bestLine :=
                 polyline.new(
                      bestPoints,
                      curved = false,
                      closed = false,
                      xloc = xloc.bar_index,
                      line_color = bestColor,
                      line_width = 3,
                      force_overlay = true
                 )


        int bestLength =
             minLen +
             bestIndex *
             stepLen


        bestLabel :=
             label.new(
                  bar_index + 3,
                  bestEMA,
                  "★ EMA " +
                  str.tostring(
                       bestLength
                  ) +
                  "\nScore " +
                  str.tostring(
                       bestScore,
                       "#.0"
                  ),
                  xloc = xloc.bar_index,
                  style = label.style_label_left,
                  color = color.new(
                       bestColor,
                       10
                  ),
                  textcolor = color.black,
                  size = size.small
             )


    // ─────────────────────────────────────────────────────────────────────
    // SECOND-BEST EMA
    // ─────────────────────────────────────────────────────────────────────

    if showSecond and
       secondIndex >= 0

        array<chart.point> secondPoints =
             array.new<chart.point>()

        int barsToDraw2 =
             math.min(
                  displayBars,
                  bar_index + 1
             )


        for offset = barsToDraw2 - 1 to 0

            array<float> historicalArray2 =
                 emaNow[offset]

            if not na(historicalArray2)

                float historicalEMA2 =
                     array.get(
                          historicalArray2,
                          secondIndex
                     )

                if not na(historicalEMA2)

                    array.push(
                         secondPoints,
                         chart.point.from_index(
                              bar_index - offset,
                              historicalEMA2
                         )
                    )


        if array.size(secondPoints) >= 2

            secondLine :=
                 polyline.new(
                      secondPoints,
                      curved = false,
                      closed = false,
                      xloc = xloc.bar_index,
                      line_color = color.new(
                           secondColor,
                           15
                      ),
                      line_width = 2,
                      force_overlay = true
                 )


        int secondLength =
             minLen +
             secondIndex *
             stepLen


        secondLabel :=
             label.new(
                  bar_index + 3,
                  secondEMA,
                  "#2 EMA " +
                  str.tostring(
                       secondLength
                  ),
                  xloc = xloc.bar_index,
                  style = label.style_label_left,
                  color = color.new(
                       secondColor,
                       20
                  ),
                  textcolor = color.black,
                  size = size.tiny
             )


// ═════════════════════════════════════════════════════════════════════════════
// 18. TOP 5 RANKING
// ═════════════════════════════════════════════════════════════════════════════

var table dashboard =
     table.new(
          position.top_right,
          8,
          7,
          border_width = 1
     )


if barstate.islast and
   showTable

    table.clear(
         dashboard,
         0,
         0,
         7,
         6
    )


    array<int> rankIndex =
         array.new_int()

    array<float> rankScore =
         array.new_float()


    // Build sorted Top 5.

    for i = 0 to candidateCount - 1

        int t =
             array.get(
                  tests,
                  i
             )

        int w =
             array.get(
                  wins,
                  i
             )

        int b =
             array.get(
                  breaks,
                  i
             )

        float avgMove =
             w > 0 ?
             array.get(
                  totalSuccessMove,
                  i
             ) /
             float(w) :
             0.0

        float candidateScore =
             f_signature_score(
                  t,
                  w,
                  b,
                  avgMove,
                  minBouncePct,
                  minTests
             )


        if t >= minTests

            int insertAt =
                 array.size(
                      rankScore
                 )

            if array.size(rankScore) > 0

                for j = 0 to array.size(rankScore) - 1

                    if candidateScore >
                       array.get(
                            rankScore,
                            j
                       )

                        insertAt := j
                        break


            array.insert(
                 rankScore,
                 insertAt,
                 candidateScore
            )

            array.insert(
                 rankIndex,
                 insertAt,
                 i
            )


            if array.size(rankScore) > 5

                array.pop(
                     rankScore
                )

                array.pop(
                     rankIndex
                )


    // ─────────────────────────────────────────────────────────────────────
    // HEADER
    // ─────────────────────────────────────────────────────────────────────

    color headerColor =
         color.new(
              bestColor,
              70
         )

    table.cell(
         dashboard,
         0,
         0,
         "#",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         1,
         0,
         "EMA",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         2,
         0,
         "SCORE",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         3,
         0,
         "TESTS",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         4,
         0,
         "HIT",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         5,
         0,
         "AVG",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         6,
         0,
         "BREAK",
         bgcolor = headerColor,
         text_color = color.white
    )

    table.cell(
         dashboard,
         7,
         0,
         "BULL",
         bgcolor = headerColor,
         text_color = color.white
    )


    // ─────────────────────────────────────────────────────────────────────
    // TOP 5 ROWS
    // ─────────────────────────────────────────────────────────────────────

    if array.size(rankIndex) > 0

        for rank = 0 to array.size(rankIndex) - 1

            int idx =
                 array.get(
                      rankIndex,
                      rank
                 )

            float score =
                 array.get(
                      rankScore,
                      rank
                 )

            int len =
                 minLen +
                 idx *
                 stepLen

            int t =
                 array.get(
                      tests,
                      idx
                 )

            int w =
                 array.get(
                      wins,
                      idx
                 )

            int b =
                 array.get(
                      breaks,
                      idx
                 )

            int bt =
                 array.get(
                      bullTests,
                      idx
                 )

            int bw =
                 array.get(
                      bullWins,
                      idx
                 )

            float hitRate =
                 t > 0 ?
                 100.0 *
                 float(w) /
                 float(t) :
                 0.0

            float avgMove =
                 w > 0 ?
                 array.get(
                      totalSuccessMove,
                      idx
                 ) /
                 float(w) :
                 0.0

            float breakRate =
                 t > 0 ?
                 100.0 *
                 float(b) /
                 float(t) :
                 0.0

            float bullHit =
                 bt > 0 ?
                 100.0 *
                 float(bw) /
                 float(bt) :
                 na


            int row =
                 rank + 1


            color rowColor =
                 rank == 0 ?
                 color.new(
                      bestColor,
                      80
                 ) :
                 rank == 1 ?
                 color.new(
                      secondColor,
                      85
                 ) :
                 color.new(
                      color.gray,
                      92
                 )


            table.cell(
                 dashboard,
                 0,
                 row,
                 rank == 0 ?
                 "★" :
                 str.tostring(
                      rank + 1
                 ),
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 1,
                 row,
                 str.tostring(
                      len
                 ),
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 2,
                 row,
                 str.tostring(
                      score,
                      "#.0"
                 ),
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 3,
                 row,
                 str.tostring(
                      t
                 ),
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 4,
                 row,
                 str.tostring(
                      hitRate,
                      "#.0"
                 ) + "%",
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 5,
                 row,
                 str.tostring(
                      avgMove,
                      "#.1"
                 ) + "%",
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 6,
                 row,
                 str.tostring(
                      breakRate,
                      "#.0"
                 ) + "%",
                 bgcolor = rowColor
            )

            table.cell(
                 dashboard,
                 7,
                 row,
                 na(bullHit) ?
                 "—" :
                 str.tostring(
                      bullHit,
                      "#.0"
                 ) + "%",
                 bgcolor = rowColor
            )


    // ─────────────────────────────────────────────────────────────────────
    // BEST EMA EXTRA INFORMATION
    // ─────────────────────────────────────────────────────────────────────

    if bestIndex >= 0

        int bestWins =
             array.get(
                  wins,
                  bestIndex
             )

        int bestBullTests =
             array.get(
                  bullTests,
                  bestIndex
             )

        int bestBullWins =
             array.get(
                  bullWins,
                  bestIndex
             )

        int bestBearTests =
             array.get(
                  bearTests,
                  bestIndex
             )

        int bestBearWins =
             array.get(
                  bearWins,
                  bestIndex
             )

        float avgTargetTime =
             bestWins > 0 ?
             array.get(
                  totalTimeToTarget,
                  bestIndex
             ) /
             float(bestWins) :
             na

        float bullHit =
             bestBullTests > 0 ?
             100 *
             float(bestBullWins) /
             float(bestBullTests) :
             na

        float bearHit =
             bestBearTests > 0 ?
             100 *
             float(bestBearWins) /
             float(bestBearTests) :
             na


        table.cell(
             dashboard,
             0,
             6,
             "BEST",
             bgcolor = color.new(
                  bestColor,
                  70
             ),
             text_color = color.white
        )

        table.cell(
             dashboard,
             1,
             6,
             "Target",
             text_color = color.gray
        )

        table.cell(
             dashboard,
             2,
             6,
             na(avgTargetTime) ?
             "—" :
             str.tostring(
                  avgTargetTime,
                  "#.1"
             ) + " bars"
        )

        table.cell(
             dashboard,
             3,
             6,
             "Bull",
             text_color = color.gray
        )

        table.cell(
             dashboard,
             4,
             6,
             na(bullHit) ?
             "—" :
             str.tostring(
                  bullHit,
                  "#.0"
             ) + "%"
        )

        table.cell(
             dashboard,
             5,
             6,
             "Weak",
             text_color = color.gray
        )

        table.cell(
             dashboard,
             6,
             6,
             na(bearHit) ?
             "—" :
             str.tostring(
                  bearHit,
                  "#.0"
             ) + "%"
        )

        table.cell(
             dashboard,
             7,
             6,
             syminfo.ticker,
             text_color = bestColor
        )
````
