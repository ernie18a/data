# FVG Channel

- url: https://www.tradingview.com/script/HzRq7l6i-FVG-Channel/
- type: indicator
- pine_id: PUB;ab981ea81c6f425b930b8e9767391837
- version: 1.0

## Description

This script is a modified and expanded derivative of “FVG Channel [LuxAlgo]” by LuxAlgo. The original FVG detection, active-level aggregation, close-based mitigation, smoothed channel concept, and internal channel-level framework were adapted from that work. This version adds confirmed-bar processing, capped FVG storage, normalized and double-smoothed boundaries, recovery-based signal logic, configurable overextension requirements, signal cooldowns, optional volume confirmation, separate standard and Super classifications, alerts, and simplified historical target/stop measurements. The original work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence, and this modified version is distributed under the same licence. It is intended for noncommercial use, and changes from the original implementation have been clearly identified.

### Overview

FVG Channel converts active Fair Value Gap reference levels into a smoothed adaptive price channel.

The script identifies confirmed bullish and bearish FVG structures, stores one reference level from each active gap, removes levels after close-based mitigation, and averages the remaining bullish and bearish references.

These averages are smoothed twice to create the channel boundaries. The channel also includes three configurable internal levels, confirmed recovery signals, optional volume confirmation, standard and Super signal classifications, alerts, target and stop reference lines, and simplified historical outcome tables.

The indicator is designed to help users examine:

* areas where multiple unmitigated FVG references are concentrated;
* price overextension beyond the adaptive channel;
* confirmed recovery back inside the channel;
* stronger wick-extension conditions;
* historical target and stop outcomes under user-selected settings.

The script is intended for standard candlestick or bar charts. It does not predict future prices and does not provide automatic trade instructions.

## Fair Value Gap detection

A bullish FVG is identified when:

* the current low is above the high from two bars earlier;
* the middle candle closes above that earlier high;
* the current chart bar is confirmed.

For each bullish FVG, the script stores the high from two bars earlier as its reference level.

A bearish FVG is identified when:

* the current high is below the low from two bars earlier;
* the middle candle closes below that earlier low;
* the current chart bar is confirmed.

For each bearish FVG, the script stores the low from two bars earlier as its reference level.

The script stores one reference level from each detected FVG. It does not draw or store the complete upper and lower boundaries of every gap zone.

## FVG mitigation

Bullish and bearish FVG references remain active until they are mitigated by a confirmed close.

A bullish FVG reference is removed when price closes below its stored level.

A bearish FVG reference is removed when price closes above its stored level.

Wick contact alone does not remove an FVG reference.

This close-based method is intended to reduce the effect of temporary wick penetration, but it can also keep a level active after price has partially traded through the original gap area.

## Maximum stored FVG levels

The Maximum Stored FVG Levels setting limits the number of bullish and bearish references stored by the script.

When the selected limit is exceeded, the oldest stored reference is removed.

This prevents the arrays from expanding indefinitely on long chart histories.

A larger limit allows more historical FVG references to contribute to the channel but may increase processing requirements.

## Adaptive channel calculation

The active bullish FVG references are averaged.

The active bearish FVG references are averaged separately.

Each average then passes through two consecutive simple moving-average smoothing calculations.

The final channel boundaries are normalized so that:

* the higher smoothed reference becomes the upper boundary;
* the lower smoothed reference becomes the lower boundary.

This prevents the channel boundaries from becoming visually reversed.

When no active bullish or bearish FVG reference is available, the script temporarily substitutes a simple moving average of price for that side of the calculation.

The resulting channel is therefore influenced by active FVG structure when available and by smoothed price when no active reference exists.

## Smoothing Length

The Smoothing Length controls both smoothing passes applied to the FVG reference averages.

A shorter length:

* reacts more quickly to changes in the active FVG structure;
* produces a more responsive channel;
* may create more frequent recovery conditions;
* can be more sensitive to short-term movement.

A longer length:

* creates smoother boundaries;
* reacts more slowly;
* emphasizes broader FVG concentration;
* may produce fewer signals.

The same length is used for both smoothing passes.

## Upper and lower boundaries

The red upper boundary represents the higher of the two smoothed FVG reference calculations.

The green lower boundary represents the lower of the two smoothed calculations.

The boundaries are not traditional support and resistance lines and should not be treated as guaranteed reversal levels.

They represent smoothed averages derived from active FVG references and the price-SMA fallback logic.

## Internal channel levels

The script calculates three configurable levels between the lower and upper boundaries.

The default values are:

* Internal Level 1: 0.236;
* Internal Level 2: 0.500;
* Internal Level 3: 0.786.

Each value represents a proportional position within the current channel range.

For example, Internal Level 2 at 0.500 represents the midpoint between the lower and upper boundaries.

The levels must satisfy:

* Level 1 is below Level 2;
* Level 2 is below Level 3.

All internal-level settings are limited to values between 0 and 1.

The script produces an error when the levels are entered in an invalid order.

## Confirmed recovery signals

The signal system looks for price to remain outside the channel and then recover back inside it.

Signals are confirmed only after the chart bar closes.

### Bullish recovery

A bullish recovery condition requires:

* price to close below the lower boundary for the selected minimum number of consecutive bars;
* price to subsequently cross and close back above the lower boundary;
* the bullish signal cooldown to have expired;
* the optional volume condition to pass.

A green BULL label marks a standard bullish recovery.

This condition indicates that price remained below the adaptive channel and then recovered above its lower boundary.

It does not guarantee that price will continue higher.

### Bearish recovery

A bearish recovery condition requires:

* price to close above the upper boundary for the selected minimum number of consecutive bars;
* price to subsequently cross and close back below the upper boundary;
* the bearish signal cooldown to have expired;
* the optional volume condition to pass.

A red BEAR label marks a standard bearish recovery.

This condition indicates that price remained above the adaptive channel and then recovered below its upper boundary.

It does not guarantee that price will continue lower.

## Minimum Closes Outside Channel

This setting controls how many consecutive confirmed closes must occur beyond a channel boundary before a recovery signal becomes eligible.

For a bullish condition, the required closes must occur below the lower boundary.

For a bearish condition, the required closes must occur above the upper boundary.

A smaller value:

* allows faster recovery signals;
* produces more frequent conditions;
* may include shallower overextensions.

A larger value:

* requires price to remain outside the channel longer;
* produces fewer conditions;
* focuses on more persistent overextensions.

## Standard and Super signals

Each recovery is classified as either a standard signal or a Super signal.

The classifications are mutually exclusive. A Super signal does not also produce a standard label or standard alert.

### Super Bull recovery

A bullish recovery becomes a Super Bull condition when the signal candle’s lower wick extends beyond the lower boundary by at least the configured Super Signal Wick Extension percentage.

A lime SBULL label identifies this condition.

### Super Bear recovery

A bearish recovery becomes a Super Bear condition when the signal candle’s upper wick extends beyond the upper boundary by at least the configured Super Signal Wick Extension percentage.

An orange SBEAR label identifies this condition.

The Super classification measures wick distance beyond the relevant boundary.

It does not independently measure trend strength, probability, expected return, or future reversal quality.

A higher Super threshold creates fewer Super classifications.

A lower threshold creates more frequent Super classifications.

## Signal cooldown

The Signal Cooldown setting controls the minimum number of chart bars required between signals of the same direction.

Bullish and bearish cooldowns are tracked independently.

For example, a bullish signal does not reset the bearish cooldown.

A value of zero allows another same-direction signal as soon as all other requirements are satisfied.

The cooldown reduces repeated signals but does not change the underlying FVG channel.

## Volume confirmation

Volume confirmation is optional.

When enabled, a recovery signal requires current reported volume to be greater than:

* average volume over the selected Volume Lookback;
* multiplied by the Volume Confirmation Multiplier.

A multiplier of 1.0 requires volume to exceed its average.

A multiplier above 1.0 requires comparatively higher volume.

A multiplier below 1.0 creates a less restrictive condition.

Volume information differs between markets and data providers. Some symbols provide centralized transaction volume, while others may provide exchange-specific or tick-volume data.

The volume condition should therefore be interpreted according to the selected market.

## Signal-bar background

Optional background highlighting can be enabled for confirmed signal bars.

Separate colours are available for:

* Bull signals;
* Super Bull signals;
* Bear signals;
* Super Bear signals.

The background highlight is visual only and does not change the signal calculations.

## Signal labels

The indicator displays four possible labels:

* BULL: standard bullish recovery;
* SBULL: Super bullish recovery;
* BEAR: standard bearish recovery;
* SBEAR: Super bearish recovery.

The Signal Offset setting controls the vertical distance between each label and the signal candle.

Labels are plotted for every confirmed signal, even when another historical outcome measurement is already active.

## Alerts

Separate alerts are available for:

* Bull Recovery;
* Super Bull Recovery;
* Bear Recovery;
* Super Bear Recovery.

Standard and Super alerts are exclusive.

Alerts are based on confirmed chart bars, so a signal is not finalized until the bar closes.

When creating a TradingView alert, using Once Per Bar Close is recommended for consistency with the script’s confirmed-bar logic.

## Historical target and stop measurements

The Historical Outcome Settings provide simplified target and stop measurements for confirmed signals.

This system is not a full TradingView strategy backtest.

Only one unresolved outcome can be tracked at a time across all four signal types.

Signals can still appear while another outcome is active, but those later signals will not begin additional outcome measurements.

## Target Mode

The available Target Modes are:

* Disabled;
* Percentage;
* Internal Level 1;
* Internal Level 2;
* Internal Level 3.

### Disabled

Historical outcome tracking is turned off.

Signal labels and alerts continue to operate.

### Percentage

The target is calculated as a percentage of the signal bar’s closing price.

Separate target settings are available for standard and Super signals.

### Internal Level targets

The selected internal channel level is used as the target only when it lies beyond the signal close in the expected direction.

For a bullish signal, the internal target must be above the signal close.

For a bearish signal, the internal target must be below the signal close.

When the selected internal level is not positioned in the required direction, no historical outcome is started for that signal.

This prevents the script from creating an invalid target behind the recorded entry price.

## Standard and Super target settings

When Percentage mode is selected:

* Standard Target is used for BULL and BEAR signals;
* Super Target is used for SBULL and SBEAR signals;
* Standard Stop is used for BULL and BEAR signals;
* Super Stop is used for SBULL and SBEAR signals.

Targets and stops are measured from the confirmed signal bar’s closing price.

They are research references only and are not automatically submitted as orders.

## Outcome evaluation

The signal bar’s closing price becomes the recorded reference price.

Target and stop evaluation begins on the following chart bar.

The signal candle’s earlier high and low are therefore not used to determine the outcome after the entry has been recorded at its close.

For bullish measurements:

* the target is reached when a later high touches or exceeds the target;
* the stop is reached when a later low touches or falls below the stop.

For bearish measurements:

* the target is reached when a later low touches or falls below the target;
* the stop is reached when a later high touches or exceeds the stop.

## Target and stop on the same bar

When both the target and stop are touched during the same evaluation bar, the script records a stop outcome.

This conservative rule is used because the script cannot determine the exact intrabar order from standard chart-bar data.

A lower-timeframe price path is not reconstructed.

## Target and stop reference lines

The most recently created target and stop levels can be displayed temporarily on the chart.

The Target/Stop Line Length controls how many bars these references remain visible after they are created.

The display duration does not control how long the historical outcome remains active.

An outcome continues to be evaluated until its target or stop is reached, even after the visual lines disappear.

## Standard outcome table

The standard table reports completed BULL and BEAR measurements.

The format is:

* T: target outcomes;
* S: stop outcomes;
* percentage: target outcomes divided by completed target and stop outcomes.

For example:

BULL T/S: 12/8 (60%)

This means that 12 completed bullish measurements reached their targets and 8 reached their stops.

## Super outcome table

The Super table reports the same measurements separately for SBULL and SBEAR signals.

Super results are not combined with standard signal results.

This allows users to compare the script’s wick-extension classification with the standard recovery classification.

## Meaning of the table percentages

The percentages are simplified historical target-outcome ratios.

They are not:

* guaranteed win rates;
* expected future returns;
* probability forecasts;
* full strategy results;
* proof of profitability.

The calculations do not account for:

* commissions;
* slippage;
* spread;
* liquidity;
* position sizing;
* portfolio equity;
* order rejection;
* realistic execution;
* overlapping positions;
* complete intrabar sequencing.

Only one unresolved measurement is tracked at a time, so not every displayed signal is represented in the tables.

Results depend on the selected:

* symbol;
* timeframe;
* available chart history;
* FVG structure;
* smoothing length;
* minimum outside-bar requirement;
* cooldown;
* volume settings;
* Super threshold;
* target mode;
* target settings;
* stop settings.

Historical results do not imply future performance.

# How to Use

## 1. Use a standard chart

Apply FVG Channel to a standard candlestick or bar chart.

Avoid evaluating signal performance on synthetic chart types such as:

* Heikin Ashi;
* Renko;
* Kagi;
* Point and Figure;
* Range charts.

Synthetic chart prices may not represent directly tradable market prices.

## 2. Begin with the default channel settings

The default Smoothing Length is 20.

This gives the active bullish and bearish FVG reference averages two smoothing passes of 20 bars each.

Observe how the channel behaves on the selected symbol before reducing or increasing the setting.

Use a shorter length when a faster channel is preferred.

Use a longer length when a slower and smoother structure is preferred.

## 3. Read the channel position

Use the upper and lower boundaries to understand where price is trading relative to the smoothed active FVG structure.

Price inside the channel indicates that it is between the two adaptive boundaries.

Price below the lower boundary indicates a lower-channel overextension.

Price above the upper boundary indicates an upper-channel overextension.

An overextension is not a signal by itself.

The script waits for a confirmed recovery back inside the channel.

## 4. Wait for the required outside closes

The default Minimum Closes Outside Channel setting is 5.

For a bullish setup, price must close below the lower boundary for at least five consecutive confirmed bars.

For a bearish setup, price must close above the upper boundary for at least five consecutive confirmed bars.

Changing this value adjusts how persistent the overextension must be.

## 5. Wait for the confirmed recovery

After the required outside closes:

* a bullish condition requires price to cross and close back above the lower boundary;
* a bearish condition requires price to cross and close back below the upper boundary.

The signal is confirmed only when the candle closes.

A temporary intrabar move through the boundary does not create a finalized signal unless the close satisfies the condition.

## 6. Distinguish standard and Super signals

Use the signal labels to identify the classification.

* BULL is a standard bullish recovery.
* SBULL is a bullish recovery with sufficient lower-wick extension.
* BEAR is a standard bearish recovery.
* SBEAR is a bearish recovery with sufficient upper-wick extension.

A Super signal is not automatically better than a standard signal.

It only means that the wick-extension threshold was reached.

## 7. Adjust the Super threshold carefully

The default Super Signal Wick Extension is 15%.

This percentage is measured relative to the relevant channel-boundary price.

A higher value makes Super signals rarer.

A lower value makes them more common.

Review the scale and volatility characteristics of the selected market before changing this setting significantly.

## 8. Use volume confirmation when appropriate

Enable Volume Confirmation when signals should require reported volume above a selected threshold.

A practical starting point is:

* Volume Lookback: 20;
* Volume Confirmation Multiplier: 1.0.

This requires current volume to be above its 20-bar average.

Increase the multiplier for a stricter requirement.

Volume confirmation may be more useful on instruments with reliable volume data.

## 9. Review the internal levels

The internal channel levels can be used as visual reference points within the adaptive range.

The default levels represent approximately:

* 23.6%;
* 50%;
* 78.6%.

They can help show where price is positioned inside the current channel.

They are not guaranteed support, resistance, or profit targets.

## 10. Review wider market context

Before interpreting a recovery label, examine:

* the broader trend;
* nearby support and resistance;
* volatility;
* channel direction;
* channel width;
* recent price structure;
* active session conditions;
* available volume quality;
* major news or event risk.

A recovery signal against a strong directional trend can fail.

The indicator should not be used as the only reason for a market decision.

## 11. Configure the signal cooldown

The default cooldown is 50 bars for signals of the same direction.

Reduce the setting when more frequent same-direction signals are desired.

Increase it when repeated signals should be restricted.

Bullish and bearish cooldowns operate independently.

## 12. Configure historical measurements

Select Percentage mode for simple percentage-based target and stop research.

A practical starting configuration is:

* Standard Target: 1%;
* Standard Stop: 1%;
* Super Target: 2%;
* Super Stop: 2%.

These are examples only and are not recommended settings for every market or timeframe.

Select an Internal Level target when the channel’s own internal structure should be used.

Remember that a measurement is skipped when the chosen level is not beyond the signal close in the correct direction.

## 13. Read the target and stop lines

When a valid outcome starts:

* the green line represents the target;
* the red line represents the stop.

The lines remain visible for the selected number of bars.

Their disappearance does not necessarily mean the outcome has been resolved.

## 14. Read the tables correctly

The standard table separates BULL and BEAR results.

The Super table separates SBULL and SBEAR results.

T means completed target outcomes.

S means completed stop outcomes.

The percentage represents targets divided by completed targets and stops.

Do not interpret the percentage as a guaranteed win rate.

## 15. Understand one-active-outcome tracking

The script tracks only one unresolved outcome at a time.

A new signal may be displayed while an older measurement remains active.

However, the newer signal will not be added to the historical table until the previous measurement has ended and another eligible signal occurs.

This prevents overlapping measurements but means the table does not measure every displayed signal.

## 16. Create alerts

Create separate TradingView alerts for the conditions you want to receive:

* Bull Recovery;
* Super Bull Recovery;
* Bear Recovery;
* Super Bear Recovery.

Use Once Per Bar Close to match the script’s confirmed-signal behaviour.

Test alerts on the intended symbol and timeframe before relying on them operationally.

## Suggested starting process

1. Apply the indicator to a liquid symbol on a standard candlestick chart.
2. Keep the default Smoothing Length of 20.
3. Keep Minimum Closes Outside Channel at 5.
4. Leave volume confirmation disabled initially.
5. Observe several BULL and BEAR recovery examples.
6. Compare standard and Super signals.
7. Review whether signals occur with or against the broader trend.
8. Enable volume confirmation and compare the difference.
9. Use the historical tables only as simplified research measurements.
10. Test multiple symbols and timeframes before drawing conclusions.

## Important limitations

* The script stores one reference level from each FVG, not the entire FVG zone.
* FVGs are confirmed only after the relevant chart bar closes.
* FVG mitigation requires a confirmed close through the stored reference.
* Wick contact alone does not remove an FVG reference.
* Active bullish and bearish references are equally weighted.
* The channel uses a price-SMA fallback when no active FVG reference is available.
* Double smoothing introduces delay.
* Recovery signals do not guarantee reversals.
* Super classifications measure wick extension only.
* Volume quality varies across markets and data providers.
* Only one historical outcome is tracked at a time.
* Not every displayed signal is included in the tables.
* Same-bar target and stop contact is recorded as a stop outcome.
* Historical measurements do not include realistic execution costs.
* Internal target modes may skip signals when the selected level is not positioned beyond the signal close.
* Historical table results do not guarantee future performance.

FVG Channel is an analytical and research tool. It does not provide financial advice, guaranteed signals, or guaranteed results.

## Source Code

````pine
// FVG Channel
// Created by BeatingSmartMoney
// Copyright © 2026 BeatingSmartMoney
// All rights reserved.

//@version=6
indicator("FVG Channel", shorttitle="FVG Channel", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const string GROUP_CHANNEL  = "FVG Channel"
const string GROUP_SIGNALS  = "Signal Settings"
const string GROUP_VOLUME   = "Volume Confirmation"
const string GROUP_OUTCOMES = "Historical Outcome Settings"
const string GROUP_VISUALS  = "Visual Settings"
const string GROUP_TABLES   = "Table Settings"
const string GROUP_COLORS   = "Table Appearance"
const string GROUP_PRESET   = "Color Preset"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Color preset
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string colorPreset = input.string(
     "Dark Background",
     "Color Preset",
     options=["Dark Background", "Light Background"],
     group=GROUP_PRESET,
     tooltip="Choose Dark Background for light table text, or Light Background for black table text."
)
bool isLightPreset = colorPreset == "Light Background"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG channel settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int smoothLen = input.int(
     20,
     "Smoothing Length",
     minval=1,
     group=GROUP_CHANNEL,
     tooltip="The lookback used for each of the two smoothing passes applied to the active FVG reference averages."
)

int maxStoredFVGs = input.int(
     300,
     "Maximum Stored FVG Levels",
     minval=10,
     maxval=5000,
     group=GROUP_CHANNEL,
     tooltip="Caps the number of active bullish and bearish FVG reference levels stored by the script. The oldest level is removed when the limit is exceeded."
)

float fib1 = input.float(
     0.236,
     "Internal Level 1",
     minval=0.0,
     maxval=1.0,
     step=0.001,
     group=GROUP_CHANNEL,
     tooltip="First internal channel level. It must be lower than Internal Level 2."
)

float fib2 = input.float(
     0.500,
     "Internal Level 2",
     minval=0.0,
     maxval=1.0,
     step=0.001,
     group=GROUP_CHANNEL,
     tooltip="Middle internal channel level. It must be between Internal Level 1 and Internal Level 3."
)

float fib3 = input.float(
     0.786,
     "Internal Level 3",
     minval=0.0,
     maxval=1.0,
     step=0.001,
     group=GROUP_CHANNEL,
     tooltip="Third internal channel level. It must be higher than Internal Level 2."
)

if barstate.isfirst and not (fib1 < fib2 and fib2 < fib3)
    runtime.error("Internal levels must satisfy: Level 1 < Level 2 < Level 3.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int minOutsideBars = input.int(
     5,
     "Minimum Closes Outside Channel",
     minval=1,
     group=GROUP_SIGNALS,
     tooltip="Number of consecutive confirmed closes required outside a boundary before a recovery signal can occur."
)

int signalCooldown = input.int(
     50,
     "Signal Cooldown (bars)",
     minval=0,
     group=GROUP_SIGNALS,
     tooltip="Minimum number of chart bars between signals of the same direction."
)

float superThreshold = input.float(
     15.0,
     "Super Signal Wick Extension (%)",
     minval=0.1,
     step=0.1,
     group=GROUP_SIGNALS,
     tooltip="The signal candle's wick must extend this percentage beyond the relevant boundary to qualify as a Super signal."
) / 100.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume confirmation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool useVolFilter = input.bool(
     false,
     "Use Volume Confirmation",
     group=GROUP_VOLUME,
     tooltip="When enabled, a signal requires current reported volume to exceed its moving-average threshold."
)

int volLookback = input.int(
     20,
     "Volume Lookback",
     minval=1,
     group=GROUP_VOLUME,
     tooltip="Lookback used to calculate average reported volume."
)

float volMultiplier = input.float(
     1.0,
     "Volume Confirmation Multiplier",
     minval=0.1,
     step=0.1,
     group=GROUP_VOLUME,
     tooltip="Signals require volume above average volume multiplied by this value."
)

float volAvg = ta.sma(volume, volLookback)
bool volCondition = not useVolFilter or (not na(volAvg) and volume > volAvg * volMultiplier)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Historical outcome settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string targetMode = input.string(
     "Percentage",
     "Target Mode",
     options=["Disabled", "Percentage", "Internal Level 1", "Internal Level 2", "Internal Level 3"],
     group=GROUP_OUTCOMES,
     tooltip="Disabled turns off historical target/stop measurement. Percentage uses a fixed target. Internal Level modes use the selected channel level only when it lies beyond the signal close in the required direction."
)

float targetPerc = input.float(
     1.0,
     "Standard Target (%)",
     minval=0.1,
     step=0.1,
     group=GROUP_OUTCOMES,
     tooltip="Percentage target used for standard signals when Target Mode is Percentage."
) / 100.0

float stopPerc = input.float(
     1.0,
     "Standard Stop (%)",
     minval=0.1,
     step=0.1,
     group=GROUP_OUTCOMES,
     tooltip="Percentage stop distance used for standard signals."
) / 100.0

float superTargetPerc = input.float(
     2.0,
     "Super Target (%)",
     minval=0.1,
     step=0.1,
     group=GROUP_OUTCOMES,
     tooltip="Percentage target used for Super signals when Target Mode is Percentage."
) / 100.0

float superStopPerc = input.float(
     2.0,
     "Super Stop (%)",
     minval=0.1,
     step=0.1,
     group=GROUP_OUTCOMES,
     tooltip="Percentage stop distance used for Super signals."
) / 100.0

int lineLen = input.int(
     10,
     "Target/Stop Line Length",
     minval=1,
     group=GROUP_OUTCOMES,
     tooltip="Number of bars the most recently created target and stop reference lines remain visible."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int glowThickness = input.int(
     10,
     "Boundary Glow Thickness",
     minval=1,
     group=GROUP_VISUALS,
     tooltip="Thickness of the transparent glow around channel boundaries and target/stop references."
)

int internalGlowThickness = input.int(
     5,
     "Internal Level Glow Thickness",
     minval=1,
     group=GROUP_VISUALS,
     tooltip="Thickness of the glow around Internal Levels 1 and 3."
)

int lineThickness = input.int(
     2,
     "Main Line Thickness",
     minval=1,
     group=GROUP_VISUALS,
     tooltip="Width of the main channel and target/stop lines."
)

float signalOffset = input.float(
     0.5,
     "Signal Offset (%)",
     minval=0.0,
     step=0.1,
     group=GROUP_VISUALS,
     tooltip="Vertical distance between signal labels and candle highs or lows."
) / 100.0

bool showBgHighlight = input.bool(
     false,
     "Show Signal-Bar Background",
     group=GROUP_VISUALS,
     tooltip="Highlights confirmed standard and Super signal bars."
)

color bullSignalBgColor = input.color(color.new(color.green, 90), "Bull Background", group=GROUP_VISUALS)
color superBullSignalBgColor = input.color(color.new(color.lime, 80), "Super Bull Background", group=GROUP_VISUALS)
color bearSignalBgColor = input.color(color.new(color.red, 90), "Bear Background", group=GROUP_VISUALS)
color superBearSignalBgColor = input.color(color.new(color.orange, 80), "Super Bear Background", group=GROUP_VISUALS)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG storage and confirmed-bar mitigation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float[] bullFVGs = array.new_float(0)
var float[] bearFVGs = array.new_float(0)

bool newBullFVG = low > high[2] and close[1] > high[2]
bool newBearFVG = high < low[2] and close[1] < low[2]

if barstate.isconfirmed
    if newBullFVG
        array.push(bullFVGs, high[2])
        if array.size(bullFVGs) > maxStoredFVGs
            array.shift(bullFVGs)

    if newBearFVG
        array.push(bearFVGs, low[2])
        if array.size(bearFVGs) > maxStoredFVGs
            array.shift(bearFVGs)

    if array.size(bullFVGs) > 0
        for i = array.size(bullFVGs) - 1 to 0
            if close < array.get(bullFVGs, i)
                array.remove(bullFVGs, i)

    if array.size(bearFVGs) > 0
        for i = array.size(bearFVGs) - 1 to 0
            if close > array.get(bearFVGs, i)
                array.remove(bearFVGs, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive channel calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float avgBullFVG = array.size(bullFVGs) > 0 ? array.avg(bullFVGs) : na
float avgBearFVG = array.size(bearFVGs) > 0 ? array.avg(bearFVGs) : na
float priceSma = ta.sma(close, smoothLen)

float bullReferenceRaw = not na(avgBullFVG) ? avgBullFVG : priceSma
float bearReferenceRaw = not na(avgBearFVG) ? avgBearFVG : priceSma

float smoothedBullReference = ta.sma(ta.sma(bullReferenceRaw, smoothLen), smoothLen)
float smoothedBearReference = ta.sma(ta.sma(bearReferenceRaw, smoothLen), smoothLen)

float upperBoundary = math.max(smoothedBullReference, smoothedBearReference)
float lowerBoundary = math.min(smoothedBullReference, smoothedBearReference)
bool channelReady = not na(upperBoundary) and not na(lowerBoundary)

float channelRange = channelReady ? upperBoundary - lowerBoundary : na
float internalLevel1 = channelReady ? lowerBoundary + channelRange * fib1 : na
float internalLevel2 = channelReady ? lowerBoundary + channelRange * fib2 : na
float internalLevel3 = channelReady ? lowerBoundary + channelRange * fib3 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Channel plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     upperBoundary,
     "Upper Boundary Glow",
     color=color.new(color.red, 80),
     linewidth=glowThickness,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
plot(upperBoundary, "Upper Boundary", color=color.red, linewidth=lineThickness)

plot(
     lowerBoundary,
     "Lower Boundary Glow",
     color=color.new(color.green, 80),
     linewidth=glowThickness,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
plot(lowerBoundary, "Lower Boundary", color=color.green, linewidth=lineThickness)

plot(
     internalLevel1,
     "Internal Level 1 Glow",
     color=color.new(color.gray, 80),
     linewidth=internalGlowThickness,
     style=plot.style_linebr,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
p1 = plot(internalLevel1, "Internal Level 1", color=color.new(color.gray, 50), style=plot.style_linebr)
p2 = plot(internalLevel2, "Internal Level 2", color=color.new(color.gray, 30), style=plot.style_linebr)
plot(
     internalLevel3,
     "Internal Level 3 Glow",
     color=color.new(color.gray, 80),
     linewidth=internalGlowThickness,
     style=plot.style_linebr,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
p3 = plot(internalLevel3, "Internal Level 3", color=color.new(color.gray, 50), style=plot.style_linebr)
fill(p1, p3, color=color.new(color.blue, 95), title="Channel Fill")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confirmed recovery signal logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int closesBelowLower = 0
var int closesAboveUpper = 0

closesBelowLower := channelReady and close < lowerBoundary ? closesBelowLower + 1 : 0
closesAboveUpper := channelReady and close > upperBoundary ? closesAboveUpper + 1 : 0

bool bullRecovery = channelReady and ta.crossover(close, lowerBoundary) and closesBelowLower[1] >= minOutsideBars
bool bearRecovery = channelReady and ta.crossunder(close, upperBoundary) and closesAboveUpper[1] >= minOutsideBars

var int lastBullSignalBar = na
var int lastBearSignalBar = na

bool bullCooldownOk = na(lastBullSignalBar) or bar_index - lastBullSignalBar >= signalCooldown
bool bearCooldownOk = na(lastBearSignalBar) or bar_index - lastBearSignalBar >= signalCooldown

bool bullBaseSignal = barstate.isconfirmed and bullRecovery and bullCooldownOk and volCondition
bool bearBaseSignal = barstate.isconfirmed and bearRecovery and bearCooldownOk and volCondition

float bullWickExtension = bullBaseSignal and lowerBoundary != 0.0 ? math.max((lowerBoundary - low) / math.abs(lowerBoundary), 0.0) : 0.0
float bearWickExtension = bearBaseSignal and upperBoundary != 0.0 ? math.max((high - upperBoundary) / math.abs(upperBoundary), 0.0) : 0.0

bool superBullSignal = bullBaseSignal and bullWickExtension >= superThreshold
bool superBearSignal = bearBaseSignal and bearWickExtension >= superThreshold
bool bullSignal = bullBaseSignal and not superBullSignal
bool bearSignal = bearBaseSignal and not superBearSignal

if bullBaseSignal
    lastBullSignalBar := bar_index
if bearBaseSignal
    lastBearSignalBar := bar_index

color signalBackground =
     superBullSignal ? superBullSignalBgColor :
     bullSignal ? bullSignalBgColor :
     superBearSignal ? superBearSignalBgColor :
     bearSignal ? bearSignalBgColor : na

bgcolor(showBgHighlight ? signalBackground : na, title="Signal Background")

plotshape(
     bullSignal ? low * (1.0 - signalOffset) : na,
     title="Bull Recovery",
     style=shape.labelup,
     location=location.absolute,
     color=color.green,
     text="BULL",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     superBullSignal ? low * (1.0 - signalOffset) : na,
     title="Super Bull Recovery",
     style=shape.labelup,
     location=location.absolute,
     color=color.lime,
     text="SBULL",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     bearSignal ? high * (1.0 + signalOffset) : na,
     title="Bear Recovery",
     style=shape.labeldown,
     location=location.absolute,
     color=color.red,
     text="BEAR",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     superBearSignal ? high * (1.0 + signalOffset) : na,
     title="Super Bear Recovery",
     style=shape.labeldown,
     location=location.absolute,
     color=color.orange,
     text="SBEAR",
     textcolor=color.white,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Exclusive alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullSignal, "Bull Recovery", "Confirmed bullish FVG-channel recovery on {{ticker}}")
alertcondition(bearSignal, "Bear Recovery", "Confirmed bearish FVG-channel recovery on {{ticker}}")
alertcondition(superBullSignal, "Super Bull Recovery", "Confirmed Super bullish FVG-channel recovery on {{ticker}}")
alertcondition(superBearSignal, "Super Bear Recovery", "Confirmed Super bearish FVG-channel recovery on {{ticker}}")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Simplified historical target/stop outcome tracking
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int activeOutcome = 0       // 1 = bullish, -1 = bearish, 0 = none
var bool activeIsSuper = false
var float entryPrice = na
var float targetPrice = na
var float stopPrice = na
var int outcomeStartBar = na

var int bullTargets = 0
var int bullStops = 0
var int bearTargets = 0
var int bearStops = 0
var int superBullTargets = 0
var int superBullStops = 0
var int superBearTargets = 0
var int superBearStops = 0

var float plottedTarget = na
var float plottedStop = na
var int plottedStartBar = na

bool outcomeTrackingEnabled = targetMode != "Disabled"

float selectedInternalTarget =
     targetMode == "Internal Level 1" ? internalLevel1 :
     targetMode == "Internal Level 2" ? internalLevel2 :
     targetMode == "Internal Level 3" ? internalLevel3 : na

// Evaluate only after the signal bar. If target and stop are both touched on the
// same bar, the result is conservatively recorded as a stop outcome.
if activeOutcome != 0 and not na(outcomeStartBar) and bar_index > outcomeStartBar
    bool targetTouched = activeOutcome == 1 ? high >= targetPrice : low <= targetPrice
    bool stopTouched = activeOutcome == 1 ? low <= stopPrice : high >= stopPrice

    if targetTouched and stopTouched
        if activeOutcome == 1
            if activeIsSuper
                superBullStops += 1
            else
                bullStops += 1
        else
            if activeIsSuper
                superBearStops += 1
            else
                bearStops += 1

        activeOutcome := 0
        activeIsSuper := false
        entryPrice := na
        targetPrice := na
        stopPrice := na
        outcomeStartBar := na

    else if targetTouched
        if activeOutcome == 1
            if activeIsSuper
                superBullTargets += 1
            else
                bullTargets += 1
        else
            if activeIsSuper
                superBearTargets += 1
            else
                bearTargets += 1

        activeOutcome := 0
        activeIsSuper := false
        entryPrice := na
        targetPrice := na
        stopPrice := na
        outcomeStartBar := na

    else if stopTouched
        if activeOutcome == 1
            if activeIsSuper
                superBullStops += 1
            else
                bullStops += 1
        else
            if activeIsSuper
                superBearStops += 1
            else
                bearStops += 1

        activeOutcome := 0
        activeIsSuper := false
        entryPrice := na
        targetPrice := na
        stopPrice := na
        outcomeStartBar := na

bool anyBullSignal = bullSignal or superBullSignal
bool anyBearSignal = bearSignal or superBearSignal

if outcomeTrackingEnabled and activeOutcome == 0
    if anyBullSignal
        bool signalIsSuper = superBullSignal
        float candidateTarget = targetMode == "Percentage" ? close * (1.0 + (signalIsSuper ? superTargetPerc : targetPerc)) : selectedInternalTarget
        float candidateStop = close * (1.0 - (signalIsSuper ? superStopPerc : stopPerc))
        bool validTarget = not na(candidateTarget) and candidateTarget > close

        if validTarget
            activeOutcome := 1
            activeIsSuper := signalIsSuper
            entryPrice := close
            targetPrice := candidateTarget
            stopPrice := candidateStop
            outcomeStartBar := bar_index
            plottedTarget := candidateTarget
            plottedStop := candidateStop
            plottedStartBar := bar_index

    else if anyBearSignal
        bool signalIsSuper = superBearSignal
        float candidateTarget = targetMode == "Percentage" ? close * (1.0 - (signalIsSuper ? superTargetPerc : targetPerc)) : selectedInternalTarget
        float candidateStop = close * (1.0 + (signalIsSuper ? superStopPerc : stopPerc))
        bool validTarget = not na(candidateTarget) and candidateTarget < close

        if validTarget
            activeOutcome := -1
            activeIsSuper := signalIsSuper
            entryPrice := close
            targetPrice := candidateTarget
            stopPrice := candidateStop
            outcomeStartBar := bar_index
            plottedTarget := candidateTarget
            plottedStop := candidateStop
            plottedStartBar := bar_index

bool showOutcomeLines = outcomeTrackingEnabled and not na(plottedStartBar) and bar_index - plottedStartBar <= lineLen

plot(
     showOutcomeLines ? plottedTarget : na,
     "Target Glow",
     color=color.new(color.lime, 80),
     linewidth=glowThickness,
     style=plot.style_linebr,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
plot(showOutcomeLines ? plottedTarget : na, "Target", color=color.lime, linewidth=lineThickness, style=plot.style_linebr)

plot(
     showOutcomeLines ? plottedStop : na,
     "Stop Glow",
     color=color.new(color.red, 80),
     linewidth=glowThickness,
     style=plot.style_linebr,
     display=display.all - display.price_scale - display.status_line - display.data_window
)
plot(showOutcomeLines ? plottedStop : na, "Stop", color=color.red, linewidth=lineThickness, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Tables
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showStandardTable = input.bool(true, "Show Standard Outcome Table", group=GROUP_TABLES)
bool showSuperTable = input.bool(true, "Show Super Outcome Table", group=GROUP_TABLES)

string standardTablePos = input.string(
     "Top Left",
     "Standard Table Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"],
     group=GROUP_TABLES
)

string superTablePos = input.string(
     "Top Right",
     "Super Table Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"],
     group=GROUP_TABLES
)

color bullBgColor = input.color(color.new(color.green, 80), "Bull Row Background", group=GROUP_COLORS)
color bearBgColor = input.color(color.new(color.red, 80), "Bear Row Background", group=GROUP_COLORS)
color tableFrameColor = input.color(color.gray, "Table Frame/Border", group=GROUP_COLORS)
color customTableTextColor = input.color(color.white, "Table Text", group=GROUP_COLORS)
color tableTextColor = isLightPreset ? color.black : customTableTextColor

getTablePosition(string selectedPosition) =>
    switch selectedPosition
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        => position.top_left

var table standardStatsTable = table.new(
     getTablePosition(standardTablePos),
     2,
     1,
     frame_width=1,
     frame_color=tableFrameColor,
     border_width=1,
     border_color=tableFrameColor
)

var table superStatsTable = table.new(
     getTablePosition(superTablePos),
     2,
     1,
     frame_width=1,
     frame_color=tableFrameColor,
     border_width=1,
     border_color=tableFrameColor
)

if barstate.islast
    table.set_position(standardStatsTable, getTablePosition(standardTablePos))
    table.set_position(superStatsTable, getTablePosition(superTablePos))

    float bullTargetRatio = bullTargets + bullStops > 0 ? bullTargets / (bullTargets + bullStops) * 100.0 : 0.0
    float bearTargetRatio = bearTargets + bearStops > 0 ? bearTargets / (bearTargets + bearStops) * 100.0 : 0.0
    float superBullTargetRatio = superBullTargets + superBullStops > 0 ? superBullTargets / (superBullTargets + superBullStops) * 100.0 : 0.0
    float superBearTargetRatio = superBearTargets + superBearStops > 0 ? superBearTargets / (superBearTargets + superBearStops) * 100.0 : 0.0

    if showStandardTable
        table.cell(
             standardStatsTable,
             0,
             0,
             "BULL T/S: " + str.tostring(bullTargets) + "/" + str.tostring(bullStops) + " (" + str.tostring(bullTargetRatio, "#.##") + "%)",
             text_color=tableTextColor,
             text_size=size.small,
             bgcolor=bullBgColor
        )
        table.cell(
             standardStatsTable,
             1,
             0,
             "BEAR T/S: " + str.tostring(bearTargets) + "/" + str.tostring(bearStops) + " (" + str.tostring(bearTargetRatio, "#.##") + "%)",
             text_color=tableTextColor,
             text_size=size.small,
             bgcolor=bearBgColor
        )
    else
        table.clear(standardStatsTable, 0, 0, 1, 0)

    if showSuperTable
        table.cell(
             superStatsTable,
             0,
             0,
             "S-BULL T/S: " + str.tostring(superBullTargets) + "/" + str.tostring(superBullStops) + " (" + str.tostring(superBullTargetRatio, "#.##") + "%)",
             text_color=tableTextColor,
             text_size=size.small,
             bgcolor=bullBgColor
        )
        table.cell(
             superStatsTable,
             1,
             0,
             "S-BEAR T/S: " + str.tostring(superBearTargets) + "/" + str.tostring(superBearStops) + " (" + str.tostring(superBearTargetRatio, "#.##") + "%)",
             text_color=tableTextColor,
             text_size=size.small,
             bgcolor=bearBgColor
        )
    else
        table.clear(superStatsTable, 0, 0, 1, 0)
````
