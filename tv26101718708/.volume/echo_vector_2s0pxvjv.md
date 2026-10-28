# Echo Vector

- url: https://www.tradingview.com/script/2s0PxvJv-Echo-Vector/
- type: indicator
- pine_id: PUB;dd9602201f2145c5b449e21c83244cdd
- version: 5.0

## Description

## Echo Vector

### Overview

Echo Vector is an open-source chart-analysis overlay that combines relative-volume candle classification, moving-average context, confirmed price structure, liquidity references, imbalance zones, trading sessions and higher-timeframe reference levels.

The purpose of the script is to organize several related areas of chart analysis within one configurable workflow:

- relative volume and candle behaviour;
- trend and volatility context;
- confirmed swing structure;
- liquidity references and mitigated zones;
- Fair Value Gaps and Balanced Price Ranges;
- daily, weekly and session-based reference levels;
- optional analytical condition markers;
- simplified historical condition-outcome statistics.

Echo Vector does not predict future price movement. Its colours, zones, lines and markers show when the configured analytical conditions have been detected. They should not be treated as automatic instructions to enter or exit a position.

### Open-source attribution

Echo Vector is an independent derivative that retains and adapts portions of the open-source Traders Reality MT4 Sessions framework and functionality associated with the Traders_Reality_Lib.

The original source credits:

- TradersReality;
- plasmapug;
- infernix;
- peshocore;
- xtech5192.

Retained or adapted areas include selected relative-volume vector-candle concepts, EMA references, market-session timing, daylight-saving handling, daily pivot calculations, M-level calculations, Psy-level concepts and selected daily and weekly reference levels.

This publication is not affiliated with, endorsed by or presented as an official TradersReality or Pattern Watchers publication.

The source is published under the Mozilla Public License 2.0.

This implementation expands the framework with additional liquidity-level management, volume-confirmed pivot zones, market-structure states, Fair Value Gap and Balanced Price Range processing, configurable condition markers, mitigation handling, Fibonacci references, timeframe presets and historical condition-outcome tables.

### What the script measures

Echo Vector examines how candle direction, candle range, candle body size and reported volume relate to their recent historical averages.

The script also examines:

- price position relative to several moving averages;
- confirmed pivot highs and lows;
- breaks of confirmed internal and external structure;
- price interaction with previously identified levels and zones;
- three-candle price imbalances;
- overlap between opposing imbalance zones;
- distance from statistical and moving-average references;
- session location and daily or weekly reference levels.

The individual modules measure different characteristics. A high-volume candle describes participation, while a structure break describes price progression. A liquidity level describes a previous pivot reference, while an FVG describes an imbalance between three candles.

No single component confirms the meaning of another component automatically.

### Relative-volume candle classification

The vector-candle engine compares current volume with a recent volume average.

It also calculates a volume-spread value by multiplying candle range by volume and comparing that value with recent bars.

The principal candle states are:

- Echo Pulse: volume exceeds the configured moderate relative-volume threshold.
- Echo Surge: volume exceeds the stronger threshold or the volume-spread value reaches the recent comparison extreme.
- Echo Peak: volume reaches the configured extreme relative-volume threshold.
- Blow-off condition: a bullish candle combines unusually high volume, an unusually large body and extension above an EMA-based deviation reference.
- Exhaustion condition: a bearish candle combines unusually high volume, an unusually large body and extension below the corresponding deviation reference.

These classifications describe unusual candle and volume relationships. They do not prove accumulation, distribution, institutional activity or an imminent reversal.

An Echo Cascade marker can appear when qualifying volume states occur for the selected number of consecutive bars.

### Moving averages and cloud

The script displays five configurable moving-average references representing fast, medium, baseline, long-term and very-long-term context.

The baseline average is also used as the centre of a volatility cloud. Cloud width is calculated from price standard deviation and can be adjusted with the multiplier and divisor settings.

When dynamic colouring is enabled, selected moving averages change colour according to price position relative to the baseline average.

Moving averages are delayed calculations based on historical prices. They do not identify exact support or resistance and can react slowly after abrupt market changes.

### Liquidity reference levels

The LQ module converts confirmed pivot highs and lows into horizontal reference levels.

- A level above a confirmed pivot high represents a possible high-side liquidity reference.
- A level below a confirmed pivot low represents a possible low-side liquidity reference.

The lines remain active until they are touched, hidden under the selected mitigation rule or removed because the maximum number of retained levels has been reached.

These levels are inferred from historical price structure. They do not display real resting orders or order-book liquidity.

### Volume-confirmed pivot zones

The zone module combines confirmed pivots with relative volume.

A zone is created when:

- a pivot high or pivot low has been confirmed;
- volume at the pivot meets the selected relative-volume threshold;
- the zone satisfies the configured display and storage rules.

Zone height can be based on a fixed tick value and may also be scaled by relative volume or ATR.

Mitigation can be evaluated using candle wicks or candle bodies. Mitigated zones may be removed or retained with a faded appearance.

The zones represent areas of prior price and volume interaction. They do not prove the presence of institutional orders.

### Market structure

Echo Vector maintains separate external and internal structure states.

External structure uses the major pivot lookback. Internal structure uses a shorter pivot lookback to detect smaller structural movements.

Depending on the previous stored direction, confirmed breaks may be labelled as:

- BOS;
- CHoCH;
- internal BOS;
- internal CHoCH;
- MSS.

The user can choose whether a break is evaluated using the candle close or the candle wick.

Structure labels are descriptive classifications based on confirmed pivots. Different pivot settings can produce different structure interpretations.

### Fair Value Gaps and Balanced Price Ranges

A bullish Fair Value Gap is detected when the current candle low remains above the high from two candles earlier.

A bearish Fair Value Gap is detected when the current candle high remains below the low from two candles earlier.

The gap must satisfy the configured minimum tick size.

When an active bullish and bearish FVG overlap, the overlapping section is displayed as a Balanced Price Range.

FVG and BPR zones are managed until their invalidation or fill condition is met.

These zones identify historical price imbalances. Price is not required to revisit, fill or react to them.

### Analytical condition markers

Echo Vector includes optional markers based on combinations of volume, candle body, wick structure, moving-average distance, RSI thresholds and recent price extremes.

Available modules include:

- swing-sweep conditions;
- stopping-volume-style conditions;
- high-volume displacement conditions;
- large-volume candle conditions;
- wick-rejection conditions;
- RSI extreme-threshold conditions;
- blow-off and exhaustion conditions.

These names describe the intended analytical category. The conditions are OHLCV-based heuristics and do not directly identify actual stop orders, passive absorption or order-book events.

Bullish and bearish markers indicate the directional interpretation assigned by the selected calculation. They are not buy or sell recommendations.

### Sessions and reference levels

The script can display selected market-session boxes and labels, including:

- London;
- New York;
- Tokyo;
- Hong Kong;
- Sydney;
- a combined Asia window;
- EU and US break windows.

Internal daylight-saving calculations adjust selected session times.

The script can also display:

- previous-day high and low;
- previous-week high and low;
- daily open;
- daily pivot levels;
- M0 through M5 midpoint levels;
- average-range references;
- Psy High and Psy Low references;
- dynamic Fibonacci retracement levels.

Session alignment can vary because of symbol trading hours, exchange calendars, chart timeframes, holidays and daylight-saving transitions.

### Fibonacci references

The Fibonacci module uses confirmed swing points maintained by the script.

When a new structural extreme is confirmed or the stored range is broken, the active swing range may be updated and the Fibonacci levels recalculated.

The user can control:

- pivot sensitivity;
- displayed ratios;
- line colours;
- line style;
- label visibility;
- standard or extended ratio sets.

Because the anchors depend on confirmed and changing swing structure, the displayed range can change as new information becomes available.

### Timeframe presets

Echo Vector provides Auto, Intraday, Daily, Weekly and Manual modes.

The presets adjust selected moving-average, RSI and volume parameters.

- Auto selects a parameter group according to the chart timeframe.
- Intraday, Daily and Weekly force a selected preset.
- Manual uses the user-defined values.

Preset values are starting configurations. They are not automatically optimized for the current symbol and do not guarantee suitable behaviour across all markets.

### How to use Echo Vector

Begin with the broader moving-average and market-structure context.

Next, examine where price is trading relative to:

- confirmed LQ levels;
- volume-confirmed pivot zones;
- FVG and BPR zones;
- session highs and lows;
- daily and weekly reference levels;
- the active Fibonacci range.

Then review the candle classification.

A Pulse, Surge or Peak candle shows that the selected volume criteria were met. It does not determine whether price will continue or reverse.

Finally, examine optional condition markers only after considering their location. A marker occurring near a relevant level or structural area may provide more context than the same marker appearing in the middle of an undefined range.

Users remain responsible for independently determining risk, position size, entry and exit rules.

### Minimal Mode

Minimal Mode reduces chart congestion by hiding selected condition markers and simplifying parts of the visual display.

It is intended for users who want to focus primarily on moving averages, the cloud, levels, sessions and broader structure.

Because individual modules also have separate visibility controls, users should confirm which elements remain active after enabling Minimal Mode.

### Historical condition-outcome table

The optional table applies fixed percentage target and stop distances to historical condition markers.

For each tracked condition, it counts whether the selected target or stop boundary was reached first.

The table is a simplified observational tool and is not equivalent to TradingView Strategy Tester.

It does not model:

- commission;
- spread;
- slippage;
- order type;
- execution delay;
- liquidity;
- position sizing;
- portfolio equity;
- all intrabar sequencing ambiguities.

Only one active observation is maintained for each tracked condition and direction. Historical results depend on the symbol, timeframe, available history, target distance, stop distance and selected settings.

Historical table values do not imply future performance.

### Settings

The main settings control:

- timeframe presets;
- moving-average periods and colours;
- volatility-cloud width;
- relative-volume thresholds;
- candle-state visibility;
- pivot sensitivity;
- liquidity-level retention;
- zone volume requirements;
- ATR and volume zone scaling;
- mitigation rules;
- internal and external structure sensitivity;
- close- or wick-based break evaluation;
- FVG minimum size;
- session visibility;
- daily and weekly reference levels;
- Fibonacci anchors and ratios;
- RSI thresholds;
- wick, volume and body filters;
- marker colours;
- alert conditions;
- table target and stop distances.

Lower thresholds and shorter lookbacks generally increase sensitivity and noise.

Higher thresholds and longer lookbacks generally produce fewer conditions and later confirmation.

### Alerts

Alerts are available for selected vector-candle states, FVG conditions, sweep-style conditions, stopping-volume-style conditions, wick conditions and Psy-level crosses.

Many conditions use values from the active candle. They can therefore appear, change or disappear before the candle closes.

For confirmed alerts, select Once Per Bar Close when creating the TradingView alert.

Pivot-based conditions are available only after the required right-side pivot bars have completed.

### Repainting and confirmation behaviour

FVG and BPR objects are created only after the relevant chart candle is confirmed.

Other current-bar conditions may change while the candle remains open.

Pivot highs and lows require bars on both sides of the pivot. A pivot is therefore confirmed only after the selected number of right-side bars has completed.

Once confirmed, a pivot marker, liquidity line, structure line, zone or Fibonacci anchor may be drawn at the earlier pivot location. The object was not available in real time on that earlier candle.

Current daily-open and session values can change as their active periods develop.

Users should evaluate signals according to the time at which they became confirmed rather than only by their final historical chart position.

### Limitations

- Volume quality differs between exchanges, brokers and symbols.
- Forex and CFD symbols may provide tick volume rather than centralized exchange volume.
- Relative-volume classifications do not show true bid-and-ask delta.
- Pivot confirmation introduces delay.
- Current-bar markers can change before candle close.
- High volume can accompany continuation, reversal or temporary volatility.
- Extreme conditions can persist.
- Liquidity levels do not show actual resting orders.
- Volume-confirmed zones do not prove institutional activity.
- FVG and BPR zones may remain unfilled or fail to produce a reaction.
- Structure classifications depend on the selected pivot settings.
- Moving averages lag price.
- Session timing can vary across exchanges and instruments.
- Lower timeframes generally generate more noise.
- Historical outcome tables do not reproduce realistic execution.
- Platform limits can restrict the number of retained boxes, labels and lines.
- The script should not be used as the sole basis for a trading decision.


------------


## HOW-TO: Use Echo Vector to Read Volume, Liquidity and Structure

Echo Vector combines relative-volume candles, moving-average context, confirmed market structure, liquidity references, imbalance zones, sessions and higher-timeframe levels.

This guide explains a structured way to read the indicator without treating any single marker as an automatic trade signal.

## Step 1: Choose the operating mode

Open the indicator settings and select an Optimization Mode.

- Auto applies a parameter group according to the chart timeframe.
- Intraday forces the intraday settings.
- Daily forces the daily settings.
- Weekly forces the weekly settings.
- Manual uses the values entered by the user.

The presets are starting configurations rather than symbol-specific optimizations.

When changing symbols or timeframes, review whether the pivot sensitivity, volume thresholds and moving-average lengths remain appropriate.

## Step 2: Establish the broader context

Begin with the moving averages and the baseline cloud.

Ask:

- Is price above or below the baseline average?
- Are the fast and medium averages moving in the same direction?
- Is price compressed inside the cloud or extended away from it?
- Is price above or below the long-term averages?

Moving averages provide context, not precise entries.

A strong move can remain extended for longer than expected, while sideways markets can cause repeated crossings.

## Step 3: Read the vector-candle states

Echo Vector classifies candles according to relative volume and candle behaviour.

- Echo Pulse marks moderately elevated volume.
- Echo Surge marks stronger relative volume or an elevated volume-spread relationship.
- Echo Peak marks an extreme relative-volume condition.
- Echo Cascade marks consecutive qualifying vector states.
- Blow-off and exhaustion conditions add body-size and statistical-extension requirements.

A coloured candle answers the question:

Did this candle meet the selected relative-volume criteria?

It does not answer:

Will the next candle move higher or lower?

Always compare a vector candle with its location and surrounding structure.

## Step 4: Identify confirmed liquidity references

LQ lines are created from confirmed pivot highs and lows.

A high-side line marks a previous confirmed high. A low-side line marks a previous confirmed low.

Use these lines to examine whether price is:

- approaching an earlier swing;
- trading through the level;
- closing back across it;
- accepting beyond it;
- reacting without reaching it.

The lines are historical price references. They do not show actual stop orders or order-book liquidity.

## Step 5: Examine volume-confirmed pivot zones

The shaded pivot zones require both a confirmed pivot and the selected relative-volume condition.

Zone height can be adjusted with:

- the base tick value;
- relative-volume scaling;
- ATR scaling.

A larger zone does not automatically mean stronger support or resistance. It means that the configured sizing calculation produced a wider reference area.

Watch how price interacts with the zone:

- wick interaction;
- body interaction;
- partial mitigation;
- complete mitigation;
- movement through the zone without reaction.

## Step 6: Read market structure

Echo Vector separates external and internal structure.

External structure describes larger confirmed pivots. Internal structure describes smaller movements inside the broader structure.

Labels can include BOS, CHoCH, internal BOS, internal CHoCH and MSS.

Use them in sequence rather than isolation.

For example:

- an internal bullish change inside an external bearish structure is not automatically a complete trend reversal;
- an external break can be more significant but will normally confirm later;
- wick-based confirmation reacts sooner but can produce more false breaks;
- close-based confirmation reacts later but requires the candle to finish beyond the level.

## Step 7: Use FVG and BPR zones

A bullish FVG appears when the current candle low remains above the high from two candles earlier.

A bearish FVG uses the inverse relationship.

A Balanced Price Range appears where active opposing FVG zones overlap.

Use these zones to study areas of historical imbalance.

Possible observations include:

- price returning into an FVG;
- partial filling;
- complete invalidation;
- reaction near a BPR;
- an imbalance aligning with a structural or liquidity reference.

Price is not required to fill every FVG.

## Step 8: Add session and higher-timeframe context

Enable only the sessions relevant to the market being studied.

Echo Vector can display London, New York, Tokyo, Hong Kong, Sydney, Asia and selected break windows.

The reference-level section can also display:

- previous-day high and low;
- previous-week high and low;
- daily open;
- pivot and M levels;
- average-range levels;
- Psy High and Psy Low;
- Fibonacci retracements.

These levels provide location context.

A condition occurring near a previous-day extreme may have a different context from the same condition occurring in the centre of the daily range.

## Step 9: Interpret condition markers carefully

The script contains optional markers based on combinations of:

- recent highs and lows;
- volume;
- candle bodies;
- wick ratios;
- moving-average distance;
- RSI thresholds;
- price extension.

Treat the markers as analytical filters.

Do not assume that names such as Stop Hunt, Stopping Volume or Liquidity Grab prove the presence of actual stop orders or institutional absorption.

They are OHLCV-based approximations.

Before using a marker, check:

- broader trend;
- external structure;
- internal structure;
- nearby LQ levels;
- active zones;
- session location;
- FVG or BPR location;
- candle-close confirmation.

## Step 10: Understand pivot delay

A confirmed pivot requires later candles.

When Pivot Strength is set to three, three bars to the right must complete before the earlier candle can be confirmed as a pivot.

The script may then place the marker or line on the original pivot candle.

This makes the historical chart easier to read, but the information was not available on the original pivot candle in real time.

The same principle applies to:

- liquidity lines;
- volume-confirmed pivot zones;
- structure pivots;
- dynamic Fibonacci anchors.

## Step 11: Use the outcome table as an observation tool

The table applies fixed target and stop distances to selected historical conditions.

It is useful for comparing how a condition behaved under one set of assumptions.

It is not a strategy backtest.

The table does not include commission, spread, slippage, realistic order fills, position sizing or portfolio equity.

Changing the symbol, timeframe, target, stop or signal filters can materially change the displayed results.

Do not interpret the historical percentage as a probability of future success.

## Step 12: Configure alerts

Select the condition in TradingView’s alert menu.

For conditions based on the active candle, use Once Per Bar Close when confirmed alerts are required.

Without bar-close confirmation, a condition may trigger while the candle is developing and disappear before the candle closes.

Pivot-based divergence or structure conditions naturally occur later because they require right-side confirmation bars.

## Example reading sequence

A structured analysis could follow this order:

- Determine whether price is above or below the baseline and long-term averages.
- Identify the latest external and internal structure direction.
- Mark nearby LQ levels and volume-confirmed pivot zones.
- Check whether price is inside or near an FVG or BPR.
- Identify the active trading session and daily or weekly location.
- Observe whether a Pulse, Surge, Peak or exhaustion condition appears.
- Review any optional marker only after checking its location.
- Wait for candle-close confirmation where required.
- Apply independent risk and execution rules.

The indicator is most useful as a context framework. It should not replace independent analysis or risk management.

## Open-source attribution

Echo Vector is an independent derivative of open-source work associated with TradersReality and the Traders_Reality_Lib.

The supplied original source credits TradersReality, plasmapug, infernix, peshocore and xtech5192.

This publication is not affiliated with or endorsed by TradersReality or Pattern Watchers and is published under the Mozilla Public License 2.0.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// SPDX-License-Identifier: MPL-2.0
//
// Original code and framework:
// © TradersReality
//
// Original pattern formation by plasmapug.
// Rise-retrace-continuation contributions by infernix, peshocore and xtech5192.
// DST automation, Psy-level refactoring and session-count contributions by xtech5192.
// Daily and weekly range research contributions by xtech5192.
// Session-countdown and library-conversion contributions by xtech5192 and peshocore.
//
// Modified and expanded by © 2026 BeatingSmartMoney.
//
// This is an independent derivative work. It is not affiliated with,
// endorsed by, or presented as an official TradersReality publication.
//
// The "Traders Reality" and "Pattern Watchers" names are not used as
// branding for this derivative publication.
indicator("Echo Vector", shorttitle="Echo Vector", overlay=true, behind_chart=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, explicit_plot_zorder=true) 

// --- Volume-Confirmed Pivot Zone Types ----
type LiquidityZone
    box   visual
    float level_top
    float level_bottom
    bool  is_bullish
    float volume_score
    bool  mitigated
    int   created_bar

// --- FVG/BPR Types ---
type FVG
    box b
    float top
    float bottom
    bool active = true

// --- FVG/BPR Storage ---
var bullFVGs = array.new<FVG>()
var bearFVGs = array.new<FVG>()
var bprZones = array.new<box>()

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
// --- Condition Outcome Study Inputs ---
group_auto = "Timeframe Presets"
opt_mode = input.string("Manual", "Preset Mode", options=["Auto", "Intraday", "Daily", "Weekly", "Manual"], group=group_auto, tooltip="Select a fixed starting parameter bundle or use manual values.\n- Auto: Selects a bundle from the chart timeframe.\n- Intraday/Daily/Weekly: Forces that fixed bundle.\n- Manual: Uses the custom values below.\n\nPreset values:\n- EMAs: Intraday (5/13/50/200/800) | Daily (8/21/55/200/600) | Weekly (10/34/89/200/400)\n- RSI Length: Intraday 14 | Daily/Weekly 7\n- RSI OB/OS: Intraday 85/15 | Daily/Weekly 80/20\n- Volume Lookback: Intraday 10 | Daily/Weekly 20\n\nThese presets are not automatically fitted or optimized for the active symbol.")

// Preset selection logic
use_intra  = opt_mode == "Intraday" or (opt_mode == "Auto" and timeframe.isintraday)
use_daily  = opt_mode == "Daily"    or (opt_mode == "Auto" and timeframe.isdaily)
use_weekly = opt_mode == "Weekly"   or (opt_mode == "Auto" and (timeframe.isweekly or timeframe.ismonthly))
is_manual  = opt_mode == "Manual"

group_general = "General Settings"
minimal_mode = input.bool(true, "Minimal Mode", group=group_general, tooltip="When enabled, hides analytical markers, structure labels, pivot markers, and outcome tables while retaining moving averages, cloud, sessions, liquidity references, zones, and chart levels.")
confirm_signals_on_close = input.bool(true, "Confirm Markers on Candle Close", group=group_general, tooltip="When enabled, analytical markers, tracked outcomes, and most signal alerts require the chart candle to close. Candle coloring and developing session/reference values can still change while the bar is open.")
auto_htf_cleanup = input.bool(true, "Higher-Timeframe Auto Cleanup", group=group_general, tooltip="Automatically reduces selected intraday-only visuals from the chosen chart timeframe upward. It does not change Minimal Mode or any of its behavior.")
htf_cleanup_from_tf = input.timeframe("240", "Auto Cleanup From Timeframe", group=group_general, tooltip="Automatic cleanup starts on this timeframe and above. Default: 4H.")

// Independent HTF cleanup state. This does not modify Minimal Mode.
htf_cleanup_active = auto_htf_cleanup and timeframe.in_seconds() >= timeframe.in_seconds(htf_cleanup_from_tf)
daily_plus_cleanup_active = auto_htf_cleanup and timeframe.in_seconds() >= 86400

// Minimal mode: disable analytical markers and outcome tables.
show_signals = not minimal_mode
signal_ready = not confirm_signals_on_close or barstate.isconfirmed

group_perf = "Condition Outcome Study"
tp_pct = input.float(1.0, "Target Distance (%)", minval=0.1, step=0.1, group=group_perf, tooltip="Fixed percentage target distance used by the simplified historical condition-outcome study.")
sl_pct = input.float(1.0, "Stop Distance (%)", minval=0.1, step=0.1, group=group_perf, tooltip="Fixed percentage stop distance used by the simplified historical condition-outcome study.")

group_table_signals = "Outcome Table Settings"
show_table = input.bool(true, "Show Condition Outcome Table", group=group_table_signals, tooltip="Show the simplified historical condition-outcome table. Results are displayed as Target/Stop counts followed by the Target rate. This is not a strategy backtest.")
outcome_table_position_input = input.string("Top Left", "Condition Outcome Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=group_table_signals, tooltip="Choose where the Condition Outcome table is placed on the chart.")
show_fvg_table = input.bool(true, "Show FVG Table", group=group_table_signals, tooltip="Toggle visibility of the Fair Value Gap stats table.")
fvg_table_position_input = input.string("Top Right", "FVG Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=group_table_signals, tooltip="Choose where the FVG table is placed on the chart.")

f_table_position(string pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.top_right
show_row_stop_hunt = input.bool(true, "Show Stop Hunt Row", group=group_table_signals, tooltip="Display the Stop Hunt historical outcome row in the table.")
show_row_stop_hunt2 = input.bool(true, "Show Volume Displacement Row", group=group_table_signals, tooltip="Display the Volume Displacement historical outcome row in the table.")
show_row_stopping_vol = input.bool(true, "Show Stopping Volume-Style Row", group=group_table_signals, tooltip="Display the Stopping Volume-Style historical outcome row in the table.")
show_row_liq_grab = input.bool(true, "Show Liq Grab Row", group=group_table_signals, tooltip="Display the Liquidity Grab historical outcome row in the table.")
show_row_wick = input.bool(true, "Show Wick Det. Row", group=group_table_signals, tooltip="Display the Wick Detection historical outcome row in the table.")
show_row_short_gnd = input.bool(true, "Show Exhaustion Row", group=group_table_signals, tooltip="Display the exhaustion-condition historical outcome row in the table.")
show_row_breaker = input.bool(true, "Show RSI Recovery Row", group=group_table_signals, tooltip="Display the RSI recovery historical outcome row in the table.")
show_table_header = input.bool(true, "Show Table Header", group=group_table_signals, tooltip="Toggle visibility of the historical condition-outcome table header row.")

// Quick Disable - controls analytical conditions and visual modules 
group_quick_disable = "Quick Disable"
show_all_levels_chart     = input.bool(true, "All Levels",     group=group_quick_disable, tooltip="Toggle all reference levels: Last Week High/Low, Yesterday High/Low, Daily Open, ADR High/Low, Pivot Point, Psy Hi/Lo." )
show_stop_hunt_chart      = input.bool(true, "Stop Hunt",      group=group_quick_disable, tooltip="Liquidity sweep beyond recent swing high/low + strong reversal candle (fakeout hunt)." )
show_stop_hunt_2_chart    = input.bool(true, "Volume Displacement", group=group_quick_disable, tooltip="High-volume price displacement away from a configurable EMA, with an optional recent-extreme context filter." )
show_stopping_vol_chart   = input.bool(true, "Stopping Volume-Style",   group=group_quick_disable, tooltip="OHLCV-based high-volume wick condition at the selected location. It does not prove order absorption." )
show_liq_grab_chart       = input.bool(true, "Liq Grab",       group=group_quick_disable, tooltip="High-volume sweep beyond a prior lookback high or low followed by a close back through the level." )
show_wick_detection_chart = input.bool(true, "Wick Det.",       group=group_quick_disable, tooltip="Large wick rejection: upper wick = bearish rejection, lower wick = bullish rejection." )
show_short_gnd_chart      = input.bool(true, "Exhaustion",       group=group_quick_disable, tooltip="Extreme-volume and large-body conditions occurring beyond an EMA-based statistical extension reference." )
show_breaker_chart        = input.bool(true, "RSI Recovery", group=group_quick_disable, tooltip="Bearish condition when RSI exits overbought; bullish condition when RSI exits oversold." )
show_echo_cascade_chart   = input.bool(true, "Echo Cascade",    group=group_quick_disable, tooltip="Icon when a new run first reaches 5 consecutive vector candles, or 3 when Use 3-Candle Cascade is enabled." )
show_vector_echo_chart    = input.bool(true, "Vector Echo Highlights", group=group_quick_disable, tooltip="Toggle background highlighting for Vector Echo candle types (Peak/Surge/Pulse/Blow-off).")
show_fvg_chart            = input.bool(true, "FVG / BPR", group=group_quick_disable, tooltip="Fair Value Gaps and overlapping opposing gaps displayed as Balanced Price Ranges. These zones may remain unfilled." )
show_dynamic_ema_chart    = input.bool(true, "Dynamic EMA Colouring", group=group_quick_disable, tooltip="Toggle dynamic coloring of EMAs based on price action and trend.")
show_fib_levels_chart     = input.bool(true, "Fibonacci Levels", group=group_quick_disable, tooltip="Toggle visibility of Fibonacci retracement levels.")
show_m_levels_chart       = input.bool(true, "M Levels",       group=group_quick_disable, tooltip="Mid pivot levels (M0-M5) drawn from the Reference Levels section.")
show_liquidity_chart      = input.bool(true, "Liquidity References (LQ)", group=group_quick_disable, tooltip="Confirmed pivot-high and pivot-low reference levels with optional removal after price interaction.")
show_ilz_chart            = input.bool(true, "Volume-Confirmed Pivot Zones", group=group_quick_disable, tooltip="Confirmed pivot zones that also require relative volume, with configurable sizing and mitigation tracking.")
show_session_labels_chart = input.bool(true, "Session Labels", group=group_quick_disable, tooltip="Toggle all session labels on/off.")
show_sessions_chart       = input.bool(true, "Sessions",       group=group_quick_disable, tooltip="Toggle all trading session backgrounds and labels on/off.")

group_sl_lines = "Stop Lines"  
show_sl_lines = input.bool(true, "Show Stop Lines", group=group_sl_lines, tooltip="Draw fixed-percentage analytical stop references above or below confirmed condition candles. These are not orders.")
sl_line_color_match = input.bool(false, "Match Condition Color", group=group_sl_lines, tooltip="When enabled, the stop line matches the color of the analytical condition that created it.")
sl_line_color = input.color(color.red, "Default Line Color", group=group_sl_lines, tooltip="Default color for stop lines when Match Condition Color is disabled.")
sl_line_style = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=group_sl_lines, tooltip="Visual style of the analytical stop lines.")
sl_line_width = input.int(1, "Line Width", minval=1, group=group_sl_lines, tooltip="Thickness of the analytical stop lines.")
sl_line_len   = input.int(10, "Line Length (Bars)", minval=1, group=group_sl_lines, tooltip="Extend stop lines this many bars to the right from the condition bar.")

f_get_line_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

group_ema = "Exponential Moving Averages"
show_ema  = input.bool(true, "Display EMAs", group=group_ema, tooltip="Show/hide the entire EMA suite including cloud and trend lines.")
dynamic_ema_color = input.bool(true, "Dynamic EMA Coloring", group=group_ema, tooltip="When enabled, EMAs change color based on price action and trend direction. When disabled, static colors are used.") and show_dynamic_ema_chart
ema_len1_in  = input.int(5, "Fast EMA", minval=1, group=group_ema, tooltip="Period for the fastest EMA, most sensitive to recent price action.")
ema_len2_in  = input.int(13, "Medium EMA", minval=1, group=group_ema, tooltip="Period for medium-speed EMA, balances short-term sensitivity with trend smoothing.")
ema_len3_in  = input.int(50, "Baseline EMA", minval=1, group=group_ema, tooltip="Period for baseline EMA, central reference for cloud bands and medium-term trend.")
cloud_mult = input.float(2.0, "Cloud StdDev Multiplier", minval=0.1, step=0.1, group=group_ema, tooltip="Multiplies standard deviation to expand cloud width around baseline EMA (higher = thicker cloud).")
cloud_div  = input.float(4.0, "Cloud Divisor", minval=0.1, step=0.1, group=group_ema, tooltip="Divides cloud size calculation for fine-tuning (higher values make cloud narrower).")
ema_len4_in  = input.int(200, "Trend EMA", minval=1, group=group_ema, tooltip="Longer EMA for overall trend direction, thicker line for visibility.")
ema_len5_in  = input.int(800, "Long-Term EMA", minval=1, group=group_ema, tooltip="Very long EMA used as a slow trend and distance reference. It does not identify institutional orders.")

// Preset parameter logic
ema_len1 = is_manual ? ema_len1_in : (use_intra ? 5 : use_daily ? 8 : 10)
ema_len2 = is_manual ? ema_len2_in : (use_intra ? 13 : use_daily ? 21 : 34)
ema_len3 = is_manual ? ema_len3_in : (use_intra ? 50 : use_daily ? 55 : 89)
ema_len4 = is_manual ? ema_len4_in : (use_intra ? 200 : use_daily ? 200 : 200)
ema_len5 = is_manual ? ema_len5_in : (use_intra ? 800 : use_daily ? 600 : 400)

// Static EMA colors (used when dynamic flow is OFF)
ema1_static_color = input.color(color.red, "Fast EMA Static Color", group=group_ema, tooltip="Fixed color for the Fast EMA when dynamic coloring is disabled.")
ema2_static_color = input.color(color.yellow, "Medium EMA Static Color", group=group_ema, tooltip="Fixed color for the Medium EMA when dynamic coloring is disabled.")
ema3_static_color = input.color(#4db6ac, "Baseline EMA Static Color", group=group_ema, tooltip="Fixed color for the Baseline EMA when dynamic coloring is disabled.")
ema4_color = input.color(#b2b5be, "Trend EMA Color", group=group_ema, tooltip="Static color for the Trend EMA, unaffected by dynamic coloring.")
ema5_color = input.color(#4a21ff, "Long-Term EMA Color", group=group_ema, tooltip="Static color for the Long-Term EMA, unaffected by dynamic coloring.")

group_dynamic_ema = "Dynamic EMA Colour"

// Dynamic EMA colors (used when dynamic coloring is ON)
ema1_bull_color = input.color(#00ffcc, "Fast EMA Bull Color", group=group_dynamic_ema, tooltip="Bullish color for the Fast EMA when dynamic coloring is enabled.")
ema1_bear_color = input.color(#ff1744, "Fast EMA Bear Color", group=group_dynamic_ema, tooltip="Bearish color for the Fast EMA when dynamic coloring is enabled.")
ema2_bull_color = input.color(#00e5ff, "Medium EMA Bull Color", group=group_dynamic_ema, tooltip="Bullish color for the Medium EMA when dynamic coloring is enabled.")
ema2_bear_color = input.color(#f44336, "Medium EMA Bear Color", group=group_dynamic_ema, tooltip="Bearish color for the Medium EMA when dynamic coloring is enabled.")
ema3_bull_color = input.color(#1de9b6, "Baseline EMA Bull Color", group=group_dynamic_ema, tooltip="Bullish color for the Baseline EMA when dynamic coloring is enabled.")
ema3_bear_color = input.color(#ff5252, "Baseline EMA Bear Color", group=group_dynamic_ema, tooltip="Bearish color for the Baseline EMA when dynamic coloring is enabled.")


group_echo_surge = "Echo Surge Settings"
show_super  = input.bool(true, "Enable Echo Surge Conditions", group=group_echo_surge, tooltip="Toggle the bullish and bearish Echo Surge analytical conditions used by alerts and the outcome study.")

show_cascade = input.bool(true, "Show Echo Cascade Icons", group=group_echo_surge, tooltip="Display one icon when a new run first reaches the selected consecutive-vector threshold.")
use_3_candle_cascade = input.bool(false, "Use 3-Candle Cascade", group=group_echo_surge, tooltip="OFF (default) = 5 consecutive vector candles. ON = 3 consecutive vector candles.")
cascade_cooldown_enabled = input.bool(false, "Enable Cascade Cooldown", group=group_echo_surge, tooltip="When enabled, suppress additional Echo Cascade X markers until the configured cooldown has passed.")
cascade_cooldown_bars = input.int(10, "Cascade Cooldown Bars", minval=1, group=group_echo_surge, tooltip="Number of full bars that must pass after an Echo Cascade X before another Cascade X can appear.")



group_echo_break = "RSI Extreme Recovery"
show_breaker = input.bool(true, "Enable RSI Recovery Conditions", group=group_echo_break, tooltip="Toggle conditions that occur when RSI exits the configured overbought or oversold zone.")
rsi_len_in = input.int(14, "RSI Length", minval=1, group=group_echo_break, tooltip="Lookback period for the RSI recovery calculation.")
rsi_ob_in  = input.int(85, "Overbought Threshold", minval=50, group=group_echo_break, tooltip="A bearish RSI recovery condition occurs when RSI crosses back below this level.")
rsi_os_in  = input.int(15, "Oversold Threshold", maxval=50, group=group_echo_break, tooltip="A bullish RSI recovery condition occurs when RSI crosses back above this level.")

rsi_len = is_manual ? rsi_len_in : (use_intra ? 14 : 7)
rsi_ob  = is_manual ? rsi_ob_in  : (use_intra ? 85 : 80)
rsi_os  = is_manual ? rsi_os_in  : (use_intra ? 15 : 20)

group_vol    = "Relative Volume Analysis"
vol_lookback_in = input.int(10, "Volume Average Lookback", minval=1, group=group_vol, tooltip="Number of completed bars used to calculate the relative-volume reference.")
vol_lookback = is_manual ? vol_lookback_in : (use_intra ? 10 : 20)

group_visual = "Visual Guides"
candle_guide = input.string("", "Candle Coloring Guide", group=group_visual, tooltip="Echo candle states:\n\n- Echo Peak: extreme relative volume.\n- Echo Surge: strong relative volume or a recent volume-spread extreme.\n- Echo Pulse: moderately elevated relative volume.\n- Echo Cascade: the configured number of consecutive qualifying echo candles.\n- Blow-off / Exhaustion: extreme volume combined with a large body and statistical price extension.\n\nThese classifications describe candle and volume relationships. They do not predict continuation or reversal.")

signal_guide = input.string("", "Condition Guide", group=group_visual, tooltip="Analytical conditions:\n\n- Stop Hunt: sweep of a prior range extreme followed by a close back through the level, with wick and volume filters.\n- Volume Displacement: high-volume movement away from a configurable EMA, optionally at a recent extreme.\n- Stopping Volume-Style: high-volume wick condition at a selected location.\n- Liquidity Grab: high-volume sweep and reclaim of a prior high or low.\n- Wick Detection: high-volume upper- or lower-wick rejection away from an EMA.\n- RSI Recovery: RSI crosses back out of an overbought or oversold zone.\n- FVG / BPR: three-candle imbalance and overlap between opposing imbalances.")

signal_guide2 = input.string("", "Outcome Study Guide", group=group_visual, tooltip="The table applies fixed Target and Stop distances to historical conditions. Results are shown as Target/Stop counts followed by the Target rate. It is a simplified chart study, not a TradingView strategy backtest. It does not model commission, spread, slippage, position sizing, execution, or all intrabar ambiguities. When both boundaries are reached in one bar, the result is counted conservatively as a Stop.")

group_ultra = "Echo Peak Candle Settings"
show_ultra        = input.bool(true, "Enable Echo Peak Candles", group=group_ultra, tooltip="Toggle the detection and coloring of Echo Peak candles.")
ultra_vol_mult    = input.float(6.0, "Volume Multiplier", minval=1.0, step=0.1, group=group_ultra, tooltip="Volume must be at least this many times the average.")
ultra_vol_lookback = input.int(10, "Volume Lookback", minval=1, group=group_ultra, tooltip="Lookback period for average volume.")

super_vol_mult   = input.float(2.0, "Super Volume Mult (vs Vector Avg)",   minval=1.0, step=0.1, group=group_ultra, tooltip="Volume must exceed this multiple of the vector average to qualify as Echo Surge candle.")
pulse_vol_mult = input.float(1.5, "Pulse Volume Mult (vs Vector Avg)", minval=1.0, step=0.1, group=group_ultra, tooltip="Volume must exceed this multiple of the vector average to qualify as Echo Pulse candle.")
group_colors       = "Candle Visual Styles"
simplify_candle_styles = input.bool(false, "Simplify Candle Visual Styles", group=group_colors, tooltip="When enabled, Blow-off and bullish Echo Peak candles use the Echo Surge Up color, while Exhaustion and bearish Echo Peak candles use the Echo Surge Down color.") or minimal_mode
// When Minimal Mode is active, Simplify Candle Visual Styles is forced ON for cleaner visuals.

color_ultra_bull  = input.color(color.rgb(0, 122, 63), "Echo Peak Up", group=group_colors, tooltip="Color for bullish Echo Peak candles with extreme relative volume.")
color_ultra_bear  = input.color(#a2000c, "Echo Peak Down", group=group_colors, tooltip="Color for bearish Echo Peak candles with extreme relative volume.")
color_blowoff_top = input.color(color.rgb(2, 185, 96), "Blow-off Condition", group=group_colors, tooltip="Color for bullish candles with extreme volume, a large body, and statistical extension above the selected EMA reference.")
color_exhaustion_bot = input.color(#fa0012, "Exhaustion Condition", group=group_colors, tooltip="Color for bearish candles with extreme volume, a large body, and statistical extension below the selected EMA reference.")
color_super_bull   = input.color(color.lime, "Echo Surge Up", group=group_colors, tooltip="Color for bullish Echo Surge candles when the configured strong relative-volume or volume-spread condition is met.")
color_super_bear   = input.color(#ff5252, "Echo Surge Down", group=group_colors, tooltip="Color for bearish Echo Surge candles when the configured strong relative-volume or volume-spread condition is met.")
color_bull_pulse = input.color(color.blue, "Echo Pulse Up", group=group_colors, tooltip="Color for bullish Echo Pulse candles when the configured moderate relative-volume condition is met.")
color_bear_pulse = input.color(color.fuchsia, "Echo Pulse Down", group=group_colors, tooltip="Color for bearish Echo Pulse candles when the configured moderate relative-volume condition is met.")
color_normal_bull  = input.color(#999999, "Normal Up Candle", group=group_colors, tooltip="Color for normal bullish candles (close > open, normal volume).")
color_normal_bear  = input.color(color.new(#575961, 0), "Normal Down Candle", group=group_colors, tooltip="Color for regular bearish or neutral candles when no higher relative-volume state is active.")


const string G_CORE = "Core Configuration"
const string G_VIS  = "Liquidity Visual Styles"

pivotLookback = input.int(3, "Pivot Strength", minval=1, group=G_CORE, tooltip="Number of bars on each side required to identify a pivot high or low.")
hideMitigated = input.bool(true, "Auto-Hide Mitigated", group=G_CORE, tooltip="Automatically hide liquidity levels once they have been touched by price.")

maxLiquidityVisuals = input.int(5, "Liquidity Visuals Per Side", minval=1, maxval=50, group=G_VIS, tooltip="Set how many LQ liquidity lines/labels to keep visible per side. Higher values show more liquidity visuals; lower values keep the chart cleaner.")

colorHigh = input.color(color.new(#4aa8f6, 30), "Buy-Side Color", group=G_VIS, tooltip="Color for buy-side liquidity levels (equal highs).")
colorLow  = input.color(color.new(color.orange, 30), "Sell-Side Color", group=G_VIS, tooltip="Color for sell-side liquidity levels (equal lows).")
lineStyle = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_VIS, tooltip="Style for liquidity level lines.")

group_hi = "Vector Echo Highlights"
show_hi  = input.bool(true, "Show Vector Echo Highlights", group=group_hi, tooltip="Enable background highlighting for specific echo/blow-off candle types.")
hi_alpha = input.int(82, "Highlight transparency (0-100)", minval=0, maxval=100, group=group_hi, tooltip="Transparency level for the highlight boxes (0 is opaque, 100 is invisible).")
hi_keep  = input.int(250, "Keep last N highlight boxes", minval=0, maxval=500, group=group_hi, tooltip="Maximum number of highlight boxes to keep on the chart to maintain performance.")
hi_color = input.color(color.yellow, "Highlight box color", group=group_hi, tooltip="Default color for the highlight boxes.")
hi_min_ticks = input.int(5, "Minimum highlight size (ticks)", minval=0, maxval=500, group=group_hi, tooltip="Minimum vertical size in ticks for a highlight box to be drawn.")

// --- Volume-Confirmed Pivot Zone Inputs ---
group_detection = "Pivot Zone Detection"
i_sensitivity  = input.int(2, "Pivot Sensitivity", minval=1, maxval=10, group=group_detection, tooltip="Lookback for pivot high/low detection")
i_vol_mult     = input.float(1.5, "Volume Threshold", minval=1.0, step=0.1, group=group_detection, tooltip="Volume must be X times the average")
i_vol_len      = input.int(20, "Volume Average Length", minval=5, group=group_detection, tooltip="Length for averaging volume in ILZ detection.")
// ILZ shows on all high-volume pivots (including retraces). No retrace filter is used.

group_mitigation = "Pivot Zone Mitigation"
i_remove_mitigated = input.bool(true, "Remove Mitigated Zones", group=group_mitigation, tooltip="Automatically remove a pivot zone after the selected mitigation condition is met.")
i_show_mitigated   = input.bool(false, "Show Mitigated (Faded)", group=group_mitigation, tooltip="If Remove is off, this fades the style instead")
i_mitigation_mode  = input.string("Wick", "Mitigation Mode", options=["Wick", "Body"], group=group_mitigation, tooltip="How price interacts with zone to consider it mitigated: wick or body touch.")

group_visuals_ilz = "Pivot Zone Visuals"
i_max_zones    = input.int(4, "Active Zones per Direction", minval=1, maxval=20, group=group_visuals_ilz, tooltip="Maximum number of active pivot zones retained per direction.")
i_bull_color   = input.color(color.new(#00ffbb, 85), "Bullish Zone", group=group_visuals_ilz, tooltip="Color for bullish volume-confirmed pivot zones.")
i_bear_color   = input.color(color.new(#ff1100, 85), "Bearish Zone", group=group_visuals_ilz, tooltip="Color for bearish volume-confirmed pivot zones.")
i_show_labels  = input.bool(true, "Show Volume Labels", group=group_visuals_ilz, tooltip="Display relative-volume information on pivot-zone labels.")
i_zone_height = input.int(50, "Base Zone Height (Ticks)", minval=1, group=group_visuals_ilz, tooltip="The base height of the zone in ticks. If 'Scale Height by Volume' is enabled, this value is multiplied by the relative volume intensity.")
i_vol_scaling = input.bool(false, "Scale Height by Volume", group=group_visuals_ilz, tooltip="When enabled, the zone height expands based on how much the volume exceeds the average, visually representing the relative-volume intensity.")
i_atr_scaling = input.bool(true, "Scale Height by ATR (Volatility)", group=group_visuals_ilz, tooltip="When enabled, the zone height also scales with market volatility (ATR), ensuring zones are proportional to recent price action.")


// --- Market Structure Inputs ---
const string G_MS_SENS = "MS: Sensitivity & Logic"
const string G_MS_VIS  = "MS: Visual Styling"

ms_pivotLookback    = input.int(5, "Major Pivot Lookback", minval = 2, group = G_MS_SENS, tooltip="Lookback period for major pivot highs/lows in market structure.")
ms_internalLookback = input.int(3, "Internal Pivot Lookback", minval = 1, group = G_MS_SENS, tooltip="Lookback for internal (smaller) pivots in market structure.")
ms_breakType        = input.string("Close", "Break Confirmation", options = ["Close", "Wick"], group = G_MS_SENS, tooltip="Require close or wick to confirm structure break.")
ms_showInternal     = input.bool(true, "Show Internal Structure", group = G_MS_VIS, tooltip="Display internal market structure breaks.")
ms_showExternal     = input.bool(true, "Show External Structure", group = G_MS_VIS, tooltip="Display external (major) market structure breaks (BOS/CHoCH).")
ms_internal_render_enabled = ms_showInternal and not daily_plus_cleanup_active
ms_showPivots       = input.bool(false, "Show MS Pivot Points", group = G_MS_VIS, tooltip="Mark pivot highs/lows used in market structure.")
ms_bullColor        = input.color(color.new(#00ffbb, 0), "MS Bullish Color", group = G_MS_VIS, tooltip="Color for bullish market structure elements.")
ms_bearColor        = input.color(color.new(#ff3355, 0), "MS Bearish Color", group = G_MS_VIS, tooltip="Color for bearish market structure elements.")

// --- Session Settings ---
group_sessions = "Sessions"
auto_hide_session_labels_tf = input.bool(true, "Auto-Hide Labels on Higher Timeframes", group=group_sessions, tooltip="Hide session text labels from the selected timeframe upward while leaving session boxes/backgrounds unchanged.")
session_labels_hide_from_tf = input.timeframe("240", "Hide Labels From Timeframe", group=group_sessions, tooltip="Session labels are hidden on this timeframe and above when enabled. Default: 4H.")
show_london = input.bool(false, "Show London", group=group_sessions, tooltip="Display London session background.")
london_label = input.bool(true, "Show London Label", group=group_sessions, tooltip="Show label for London session.")
london_color = input.color(color.new(color.blue, 85), "London Color", group=group_sessions, tooltip="Background color for London session.")
show_ny = input.bool(false, "Show New York", group=group_sessions, tooltip="Display New York session background.")
ny_label = input.bool(true, "Show NY Label", group=group_sessions, tooltip="Show label for New York session.")
ny_color = input.color(color.new(color.orange, 85), "New York Color", group=group_sessions, tooltip="Background color for New York session.")
show_tokyo = input.bool(false, "Show Tokyo", group=group_sessions, tooltip="Display Tokyo session background.")
tokyo_label = input.bool(true, "Show Tokyo Label", group=group_sessions, tooltip="Show label for Tokyo session.")
tokyo_color = input.color(color.new(color.gray, 85), "Tokyo Color", group=group_sessions, tooltip="Background color for Tokyo session.")
show_hk = input.bool(false, "Show Hong Kong", group=group_sessions, tooltip="Display Hong Kong session background.")
hk_label = input.bool(true, "Show HK Label", group=group_sessions, tooltip="Show label for Hong Kong session.")
hk_color = input.color(color.new(#27b062, 85), "Hong Kong Color", group=group_sessions, tooltip="Background color for Hong Kong session.")
show_sydney = input.bool(true, "Show Sydney", group=group_sessions, tooltip="Display Sydney session background.")
sydney_label = input.bool(true, "Show Sydney Label", group=group_sessions, tooltip="Show label for Sydney session.")
sydney_color = input.color(color.new(#51bc55, 85), "Sydney Color", group=group_sessions, tooltip="Background color for Sydney session.")
show_simplify_asia = input.bool(false, "Simplify Asia Sessions", group=group_sessions, tooltip="Joins Sydney, Tokyo & Hong Kong into a single Asia session (22:00-08:00).") or minimal_mode
asia_label = input.bool(true, "Show Asia Label", group=group_sessions, tooltip="Show label for simplified Asia session.")
asia_color = input.color(color.new(#51bc55, 85), "Asia Color", group=group_sessions, tooltip="Background color for simplified Asia session.")
show_eu_brinx = input.bool(false, "Show EU Brinx", group=group_sessions, tooltip="Display EU Brinx (break) session background.")
eu_brinx_label = input.bool(true, "Show EU Brinx Label", group=group_sessions, tooltip="Show label for EU Brinx session.")
eu_brinx_color = input.color(color.new(#00bcd4, 85), "EU Brinx Color", group=group_sessions, tooltip="Background color for EU Brinx session.")
show_us_brinx = input.bool(true, "Show US Brinx", group=group_sessions, tooltip="Display US Brinx (break) session background.")

// --- Stop Hunt & Stopping Volume-Style Inputs ---
const string G_SH = "Stop Hunt Signals"
sh_enabled = input.bool(true, "Enable Stop Hunt Signals", group=G_SH, tooltip="Toggle the detection and display of Stop Hunt bullish/bearish signals.")
sh_wick_ratio = input.float(2.0, "Min Wick-to-Body Ratio", minval=0.1, step=0.1, group=G_SH, tooltip="Minimum wick-to-body ratio required for a valid stop hunt (wick must be this many times the body).")
sh_vol_mult = input.float(2.0, "Volume Spike Multiplier", minval=1.0, step=0.1, group=G_SH, tooltip="Volume must exceed this multiple of the completed-bar volume average.")
sh_vol_len = input.int(20, "Volume Average Length", minval=1, group=G_SH, tooltip="Number of completed bars used for the Stop Hunt volume average.")
sh_lookback = input.int(20, "Equal High/Low Lookback", minval=5, group=G_SH, tooltip="Number of bars to look back for equal highs/lows when detecting liquidity sweeps.")
sh_atr_filter = input.bool(true, "ATR Displacement Filter", group=G_SH, tooltip="Require price displacement greater than ATR to filter weak stop hunts.")
sh_choch_filter = input.bool(true, "Structure Alignment Filter", group=G_SH, tooltip="Require the stored major or internal structure direction to align with the bullish or bearish Stop Hunt condition.")
sh_location = input.string("Range Extremes", "Sweep Reference", options=["Range Extremes", "Structure"], group=G_SH, tooltip="Choose whether the sweep and reclaim are measured against the rolling range extreme or the latest confirmed major structure pivot.")
sh_bull_col = input.color(color.green, "Bullish Stop Hunt Color", group=G_SH, tooltip="Color used for bullish Stop Hunt signal markers.")
sh_bear_col = input.color(color.red, "Bearish Stop Hunt Color", group=G_SH, tooltip="Color used for bearish Stop Hunt signal markers.")
sh_show_bg = input.bool(false, "Show Background Highlight", group=G_SH, tooltip="Highlight the background when a Stop Hunt signal occurs.")
sh_bg_col = input.color(color.new(color.yellow, 80), "Background Highlight Color", group=G_SH, tooltip="Background color for Stop Hunt highlights when enabled.")

const string G_SV = "Stopping Volume-Style Conditions"
sv_enabled = input.bool(true, "Enable Stopping Volume-Style Conditions", group=G_SV, tooltip="Toggle the OHLCV-based bullish and bearish Stopping Volume-Style conditions.")
sv_vol_method = input.string("SMA", "Volume Comparison Method", options=["SMA", "Highest X Bars"], group=G_SV, tooltip="Method used to calculate reference volume: SMA or Highest X Bars.")
sv_vol_lookback = input.int(20, "Volume Lookback", minval=5, group=G_SV, tooltip="Number of bars used to calculate the reference volume for Stopping Volume-Style detection.")
sv_vol_mult     = input.float(2.0, "Volume Threshold Multiplier", minval=1.0, step=0.1, group=G_SV, tooltip="Volume must be X times the reference volume")
sv_atr_body = input.float(2.0, "Max Body (ATR Multiplier)", minval=0.1, step=0.1, group=G_SV, tooltip="Maximum body size (in ATR) allowed for a valid Stopping Volume-Style condition.")
sv_min_wick = input.float(3.0, "Min Wick-to-Body Ratio", minval=0.1, step=0.1, group=G_SV, tooltip="Minimum wick-to-body ratio required for Stopping Volume-Style confirmation.")
sv_location = input.string("VWAP", "Location Filter", options=["Range Extremes", "VWAP", "After Sweep", "Premium-Discount", "Anywhere"], group=G_SV, tooltip="Choose the location context required for a Stopping Volume-Style condition. Anywhere disables only the location filter.")
sv_bull_col = input.color(color.lime, "Bullish Stopping Volume-Style Color", group=G_SV, tooltip="Color used for bullish Stopping Volume-Style markers.")
sv_bear_col = input.color(color.orange, "Bearish Stopping Volume-Style Color", group=G_SV, tooltip="Color used for bearish Stopping Volume-Style markers.")
sv_show_bg = input.bool(false, "Show Background Highlight", group=G_SV, tooltip="Highlight the background when a Stopping Volume-Style condition occurs.")
sv_bg_col = input.color(color.new(color.blue, 80), "Background Highlight Color", group=G_SV, tooltip="Background color for Stopping Volume-Style highlights when enabled.")
sv_cooldown = input.int(5, "Cooldown Bars", minval=0, group=G_SV, tooltip="Minimum bars between consecutive Stopping Volume-Style conditions to reduce noise.")

group_sh2 = "Volume Displacement"
sh2_enabled = input.bool(true, "Enable Volume Displacement Conditions", group=group_sh2, tooltip="Toggle high-volume bullish and bearish displacement conditions relative to the selected EMA.")
auto_hide_vd_signals_tf = input.bool(true, "Auto-Hide VD Signals on Higher Timeframes", group=group_sh2, tooltip="Hide both bullish and bearish Volume Displacement signals from the selected timeframe upward.")
vd_signals_hide_from_tf = input.timeframe("240", "Hide VD Signals From Timeframe", group=group_sh2, tooltip="VD signals are hidden on this timeframe and above when enabled. Default: 4H.")
sh2_vol_mult = input.float(3.0, "Volume Multiplier", minval=1.0, group=group_sh2, tooltip="Volume must exceed this multiple of the selected volume average.")
sh2_ema_len = input.int(50, "EMA Length", minval=1, group=group_sh2, tooltip="EMA used as the displacement reference.")
sh2_vol_lookback = input.int(10, "Volume Average Length", minval=1, group=group_sh2, tooltip="Number of bars used to calculate the Volume Displacement volume reference.")
sh2_price_threshold_pct = input.float(1.0, "Minimum EMA Distance (%)", minval=0.0, group=group_sh2, tooltip="Minimum closing-price distance above or below the EMA required for a displacement condition.")
sh2_structure_lookback = input.int(20, "Recent Extreme Lookback", minval=1, group=group_sh2, tooltip="Lookback used by the optional recent-high or recent-low context filter.")
sh2_enable_structure_bull = input.bool(false, "Require Recent High Context", group=group_sh2, tooltip="When enabled, bullish Volume Displacement must occur at or above the prior lookback high.")
sh2_enable_structure_bear = input.bool(false, "Require Recent Low Context", group=group_sh2, tooltip="When enabled, bearish Volume Displacement must occur at or below the prior lookback low.")
sh2_bull_col = input.color(color.lime, "Bullish Signal Color", group=group_sh2, tooltip="Color used for bullish Volume Displacement markers.")

sh2_bear_col = input.color(color.orange, "Bearish Signal Color", group=group_sh2, tooltip="Color used for bearish Volume Displacement markers.")

group_liq = "Liquidity Grab"
liq_enabled = input.bool(true, "Enable Liquidity Grab", group=group_liq, tooltip="Detect high-volume sweeps beyond a prior lookback high or low that close back through the swept level.")
liq_lookback = input.int(30, "Lookback Period", minval=1, group=group_liq, tooltip="Number of bars used to calculate average body size and volume for Liquidity Grab detection.")
liq_body_mult = input.float(1.5, "Body Size Multiplier", minval=0.1, group=group_liq, tooltip="Candle body must exceed this multiple of its recent average.")
liq_vol_mult = input.float(2.0, "Volume Multiplier", minval=1.0, group=group_liq, tooltip="Volume must exceed this multiple of its recent average.")
liq_col = input.color(color.red, "Signal Color", group=group_liq, tooltip="Color used for Liquidity Grab signal markers on the chart.")

group_wick = "Wick Detector"
wick_enabled = input.bool(true, "Enable Wick Detector Signals", group=group_wick, tooltip="Toggle the detection and display of Wick bullish/bearish signals.")
wickRatio = input.float(2.0, title="Wick-to-Body Ratio", minval=1.0, group=group_wick, tooltip="Minimum wick-to-body ratio required for a valid Wick Detector signal (wick must be this many times the body).")
volumeMultiplier = input.float(1.5, title="Volume Multiplier", minval=1.0, group=group_wick, tooltip="Volume must exceed this multiple of average volume to confirm a high-volume wick rejection.")
lookbackPeriod = input.int(10, title="Volume Lookback Period", minval=1, group=group_wick, tooltip="Number of bars used to calculate average volume for Wick Detector signals.")
emaLength = input.int(50, title="EMA Length", minval=1, group=group_wick, tooltip="EMA length used to ensure the wick rejection occurs sufficiently far from the EMA.")
emaDistancePercent = input.float(1.0, title="Min % Away from EMA", minval=0.0, group=group_wick, tooltip="Minimum percentage distance from the EMA required for a valid Wick Detector signal.")

group_blowoff = "Blow-off / Exhaustion Settings"
show_blowoff  = input.bool(true, "Enable Blow-off / Exhaustion", group=group_blowoff, tooltip="Toggle the detection and coloring of Blow-off Top and Exhaustion Bottom candles.")
bo_vol_mult   = input.float(6.0, "Volume Multiplier", minval=1.0, step=0.1, group=group_blowoff, tooltip="Multiplier applied to average volume to detect blow-off/exhaustion candles.")
bo_vol_len    = input.int(60, "Volume Lookback", minval=1, group=group_blowoff, tooltip="Lookback period for the volume average used in blow-off detection.")
bo_body_mult  = input.float(2.0, "Body Multiplier", minval=1.0, step=0.1, group=group_blowoff, tooltip="Multiplier for candle body size relative to its average.")
bo_body_len   = input.int(50, "Body Lookback", minval=1, group=group_blowoff, tooltip="Lookback period for calculating average candle body size.")
bo_ema_len    = input.int(50, "EMA Length", minval=1, group=group_blowoff, tooltip="EMA length used to determine trend direction for blow-off signals.")
bo_std_mult   = input.float(2.0, "Deviation Multiplier", minval=0.1, step=0.1, group=group_blowoff, tooltip="Standard deviation multiplier for price distance from EMA.")


us_brinx_label = input.bool(true, "Show US Brinx Label", group=group_sessions, tooltip="Toggle visibility of the US Brinx (break) session label on the chart.")
us_brinx_color = input.color(color.new(#ff5252, 65), "US Brinx Color", group=group_sessions, tooltip="Color used for the US Brinx session background and label.")
show_weekends = input.bool(false, "Show on Weekends", group=group_sessions, tooltip="Include weekend sessions when drawing session backgrounds and labels.")
session_line_style = input.string("Solid", "Session Line Style", options=["Solid", "Dashed", "Dotted", "None"], group=group_sessions, tooltip="Line style for the top and bottom borders of each session box.")
session_line_width = input.int(1, "Session Line Thickness", minval=1, group=group_sessions, tooltip="Thickness of the session box border lines.")
session_label_offset = input.float(200.0, "Label Offset (Ticks)", minval=0, group=group_sessions, tooltip="Vertical offset (in ticks) for session labels above the session box.")

// Session label visibility is independent of Minimal Mode.
session_labels_tf_allowed = (not auto_hide_session_labels_tf or timeframe.in_seconds() < timeframe.in_seconds(session_labels_hide_from_tf)) and not htf_cleanup_active
session_labels_enabled = show_session_labels_chart and session_labels_tf_allowed

// --- DST Logic & Session Drawing ---
f_days_in_month(y, m) =>
    m == 2 ? ((y % 4 == 0 and y % 100 != 0) or y % 400 == 0 ? 29 : 28) :
     (m == 4 or m == 6 or m == 9 or m == 11 ? 30 : 31)

f_first_sunday(y, m) =>
    int res = na
    for d = 1 to 7
        if na(res) and dayofweek(timestamp("GMT", y, m, d, 0, 0)) == dayofweek.sunday
            res := d
    res

f_second_sunday(y, m) =>
    f_first_sunday(y, m) + 7

f_last_sunday(y, m) =>
    int res = na
    dim = f_days_in_month(y, m)
    for i = 0 to 6
        d = dim - i
        if na(res) and dayofweek(timestamp("GMT", y, m, d, 0, 0)) == dayofweek.sunday
            res := d
    res

f_uk_dst() =>
    y = year(time, "GMT")
    start = timestamp("GMT", y, 3, f_last_sunday(y, 3), 1, 0)
    finish = timestamp("GMT", y, 10, f_last_sunday(y, 10), 1, 0)
    time >= start and time < finish

f_ny_dst() =>
    y = year(time, "GMT")
    start = timestamp("GMT", y, 3, f_second_sunday(y, 3), 7, 0)
    finish = timestamp("GMT", y, 11, f_first_sunday(y, 11), 6, 0)
    time >= start and time < finish

f_syd_dst() =>
    y = year(time, "GMT")
    start = timestamp("GMT", y, 10, f_first_sunday(y, 10), 0, 0)
    finish = timestamp("GMT", y, 4, f_first_sunday(y, 4), 0, 0)
    time < finish or time >= start

ukDST  = f_uk_dst()
nyDST  = f_ny_dst()
sydDST = f_syd_dst()

draw_session_tr(sess_name, sess_time, sess_tz, col, active, show_lab) =>
    var float sHi = na
    var float sLo = na
    var int sStart = na
    var line sHiLine = na
    var line sLoLine = na
    var linefill sFill = na
    var label sLabel = na

    sessRightTime = nz(time_close, time)

    sess_days = show_weekends ? ":1234567" : ":23456"
    in_sess = active and not na(time(timeframe.period, sess_time + sess_days, sess_tz))
    is_new = in_sess and not in_sess[1]

    sessLs = switch session_line_style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

    // Session range fill is built from two lines + linefill instead of box.new().
    // This removes the large hoverable box surface that was causing TradingView
    // to temporarily focus the whole indicator and visually lift the EMA cloud.
    sessBorderColor = session_line_style == "None" ? color.new(col, 100) : col

    if is_new
        sHi := high
        sLo := low
        sStart := time

        // Always create the two boundary lines because linefill requires them.
        // If borders are disabled, the lines are fully transparent.
        sHiLine := line.new(sStart, sHi, sessRightTime, sHi, xloc=xloc.bar_time, color=sessBorderColor, width=session_line_width, style=sessLs)
        sLoLine := line.new(sStart, sLo, sessRightTime, sLo, xloc=xloc.bar_time, color=sessBorderColor, width=session_line_width, style=sessLs)
        sFill := linefill.new(sHiLine, sLoLine, col)

        if show_lab
            sLabel := label.new(sStart, sHi + session_label_offset * syminfo.mintick, sess_name, xloc=xloc.bar_time, style=label.style_label_down, color=color.new(col, 0), textcolor=color.white, size=size.tiny)

    if in_sess and not na(sHiLine) and not na(sLoLine)
        sHi := math.max(nz(sHi, high), high)
        sLo := math.min(nz(sLo, low), low)

        line.set_xy1(sHiLine, sStart, sHi)
        line.set_xy2(sHiLine, sessRightTime, sHi)
        line.set_xy1(sLoLine, sStart, sLo)
        line.set_xy2(sLoLine, sessRightTime, sLo)

        // Keep the chosen border visibility/style current.
        line.set_color(sHiLine, sessBorderColor)
        line.set_color(sLoLine, sessBorderColor)
        line.set_style(sHiLine, sessLs)
        line.set_style(sLoLine, sessLs)
        line.set_width(sHiLine, session_line_width)
        line.set_width(sLoLine, session_line_width)

        if not na(sFill)
            linefill.set_color(sFill, col)

        if show_lab and not na(sLabel)
            label.set_y(sLabel, sHi + session_label_offset * syminfo.mintick)

    if in_sess[1] and not in_sess
        sHiLine := na
        sLoLine := na
        sFill := na
        sLabel := na
        sHi := na
        sLo := na
        sStart := na

if timeframe.isintraday
    draw_session_tr("UK", "0800-1630", ukDST ? "GMT+1" : "GMT+0", london_color, show_london and show_sessions_chart, london_label and session_labels_enabled)
    draw_session_tr("NY", "1430-2100", nyDST ? "GMT+1" : "GMT+0", ny_color, show_ny and show_sessions_chart, ny_label and session_labels_enabled)

    draw_session_tr("Tok", "0000-0600", "GMT+0", tokyo_color, show_tokyo and show_sessions_chart, tokyo_label and session_labels_enabled)

    if show_simplify_asia
        draw_session_tr("Asia", "2200-0800", sydDST ? "GMT+1" : "GMT+0", asia_color, show_sessions_chart, asia_label and session_labels_enabled)
    else
        draw_session_tr("HK", "0130-0800", "GMT+0", hk_color, show_hk and show_sessions_chart, hk_label and session_labels_enabled)
        draw_session_tr("Syd", "2200-0600", sydDST ? "GMT+1" : "GMT+0", sydney_color, show_sydney and show_sessions_chart, sydney_label and session_labels_enabled)

    draw_session_tr("EU Bx", "0800-0900", ukDST ? "GMT+1" : "GMT+0", eu_brinx_color, show_eu_brinx and show_sessions_chart, eu_brinx_label and session_labels_enabled)
    draw_session_tr("US Bx", "1400-1500", nyDST ? "GMT+1" : "GMT+0", us_brinx_color, show_us_brinx and show_sessions_chart, us_brinx_label and session_labels_enabled) 

ms_intBullColor     = input.color(color.new(#00ffbb, 50), "Internal Bullish Color", group = G_MS_VIS, tooltip="Color for internal bullish market structure lines (i-BOS / i-CHoCH).")
ms_intBearColor     = input.color(color.new(#ff3355, 50), "Internal Bearish Color", group = G_MS_VIS, tooltip="Color for internal bearish market structure lines (i-BOS / i-CHoCH).")
ms_lineStyle        = input.string("Dashed", "MS Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_MS_VIS, tooltip="Line style used for all market structure (BOS/CHoCH) lines.")

// --- FVG/BPR Inputs ---
grp_fvg_colors = "FVG & BPR Color Settings"
bullColor = input.color(color.new(color.blue, 70), "Bullish FVG", group=grp_fvg_colors, tooltip="Color for bullish Fair Value Gap zones.")
bearColor = input.color(color.new(color.red, 70), "Bearish FVG", group=grp_fvg_colors, tooltip="Color for bearish Fair Value Gap zones.")
bprColor  = input.color(color.new(color.purple, 50), "Balanced Price Range (BPR)", group=grp_fvg_colors, tooltip="Color for Balanced Price Range (BPR) zones.")
fvg_text_color = input.color(color.new(color.white, 50), "FVG/BPR Text Color", group=grp_fvg_colors, tooltip="Color for text labels inside FVG and BPR zones.")
grp_fvg_settings = "FVG & BPR General Settings"
maxZones = input.int(50, "Max Active Zones per Type", minval=1, maxval=100, group=grp_fvg_settings, tooltip="Maximum number of active FVG or BPR zones of each type (bullish/bearish) to keep on the chart.")
fvg_min_ticks = input.int(5, "Minimum FVG/BPR size (ticks)", minval=0, maxval=1000, group=grp_fvg_settings, tooltip="Minimum vertical size (in ticks) required for an FVG or BPR zone to be drawn.")



// --- Types & Objects ---
type StructurePoint
    float price
    int   index
    bool  isHigh
    string labelType // "BOS" or "CHoCH"

// --- State Variables ---
var StructurePoint lastHigh    = StructurePoint.new(na, na, true, na)
var StructurePoint lastLow     = StructurePoint.new(na, na, false, na)
var StructurePoint lastIntHigh = StructurePoint.new(na, na, true, na)
var StructurePoint lastIntLow  = StructurePoint.new(na, na, false, na)
var int trendDir    = 0 // 1 for Bull, -1 for Bear
var int intTrendDir = 0

// --- Helper Functions ---
get_line_style(style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

render_structure(p1, p2, col, txt) =>
    line.new(p1.index, p1.price, p2.index, p1.price, xloc.bar_index, extend.none, col, get_line_style(ms_lineStyle), 1)
    lbl_style = p1.isHigh ? label.style_label_down : label.style_label_up
    label.new(math.round(math.avg(p1.index, p2.index)), p1.price, txt, color = color.new(color.black, 100), textcolor = col, style = lbl_style, size = size.tiny)

f_clean_oldest(array<FVG> arr, int max_count) =>
    if array.size(arr) > max_count
        fvg = array.shift(arr)
        box.delete(fvg.b)

f_check_bpr(float new_top, float new_bottom, bool is_bull) =>
    bool bpr_found = false
    if is_bull
        if array.size(bearFVGs) > 0
            for i = array.size(bearFVGs) - 1 to 0
                other = array.get(bearFVGs, i)
                overlap_top = math.min(new_top, other.top)
                overlap_bottom = math.max(new_bottom, other.bottom)
                if overlap_top > overlap_bottom and (overlap_top - overlap_bottom) >= (fvg_min_ticks * syminfo.mintick)
                    bpr_box = box.new(bar_index + 1, overlap_top, bar_index + 20, overlap_bottom,
                      bgcolor=bprColor, border_color=na, text="BPR", text_color=fvg_text_color,
                      text_halign=text.align_center, text_valign=text.align_top, text_size=size.tiny)
                    array.push(bprZones, bpr_box)
                    if array.size(bprZones) > maxZones
                        box.delete(array.shift(bprZones))
                    box.delete(other.b)
                    array.remove(bearFVGs, i)
                    bpr_found := true
    else
        if array.size(bullFVGs) > 0
            for i = array.size(bullFVGs) - 1 to 0
                other = array.get(bullFVGs, i)
                overlap_top = math.min(new_top, other.top)
                overlap_bottom = math.max(new_bottom, other.bottom)
                if overlap_top > overlap_bottom and (overlap_top - overlap_bottom) >= (fvg_min_ticks * syminfo.mintick)
                    bpr_box = box.new(bar_index + 1, overlap_top, bar_index + 20, overlap_bottom,
                      bgcolor=bprColor, border_color=na, text="BPR", text_color=fvg_text_color,
                      text_halign=text.align_center, text_valign=text.align_top, text_size=size.tiny)
                    array.push(bprZones, bpr_box)
                    if array.size(bprZones) > maxZones
                        box.delete(array.shift(bprZones))
                    box.delete(other.b)
                    array.remove(bullFVGs, i)
                    bpr_found := true
    bpr_found

//------------------------------------------------------------------------------
// Types & Storage
//------------------------------------------------------------------------------
type LiquidityLevel
    float price
    line  visual
    label info

var buySidePool  = array.new<LiquidityLevel>(0)
var sellSidePool = array.new<LiquidityLevel>(0)
type HighlightBox
    box visual
    float top
    float bottom
    int bornTime

var HighlightBox[] hi_boxes = array.new<HighlightBox>()

//------------------------------------------------------------------------------
// Core calcs
//------------------------------------------------------------------------------
ema1 = ta.ema(close, ema_len1)
ema2 = ta.ema(close, ema_len2)
ema3 = ta.ema(close, ema_len3)
ema4 = ta.ema(close, ema_len4)
ema5 = ta.ema(close, ema_len5)

ema_bull = close > ema3
ema_col1 = dynamic_ema_color ? (ema_bull ? ema1_bull_color : ema1_bear_color) : ema1_static_color
ema_col2 = dynamic_ema_color ? (ema_bull ? ema2_bull_color : ema2_bear_color) : ema2_static_color
ema_col3 = dynamic_ema_color ? (ema_bull ? ema3_bull_color : ema3_bear_color) : ema3_static_color

avg_vol_100     = ta.sma(volume, math.max(vol_lookback, 1))[1]
avg_vol_60      = ta.sma(volume, bo_vol_len)[1]
avg_vol_ultra   = ta.sma(volume, ultra_vol_lookback)[1]
vs              = volume * (high - low)
highest_vs      = ta.highest(vs[1], math.max(vol_lookback, 1))

is_bull         = close > open
is_bear         = close <= open

// Blow-off Logic
avg_body_50     = ta.sma(math.abs(close - open), bo_body_len)
ema_50          = ta.ema(close, bo_ema_len)
std_50          = ta.stdev(close, bo_ema_len)
is_extended_up  = close > (ema_50 + (std_50 * bo_std_mult))
is_extended_dn  = close < (ema_50 - (std_50 * bo_std_mult))
is_huge_body    = math.abs(close - open) > (avg_body_50 * bo_body_mult)

is_blowoff_top  = show_short_gnd_chart and show_blowoff and is_bull and volume >= avg_vol_60 * bo_vol_mult and is_extended_up and is_huge_body
is_exhaustion_bot = show_short_gnd_chart and show_blowoff and is_bear and volume >= avg_vol_60 * bo_vol_mult and is_extended_dn and is_huge_body

is_ultra_bull_raw   = show_ultra and is_bull and volume >= avg_vol_ultra * ultra_vol_mult and not is_blowoff_top
is_ultra_bear_raw   = show_ultra and is_bear and volume >= avg_vol_ultra * ultra_vol_mult and not is_exhaustion_bot

is_super_bull_raw   = is_bull and (volume >= avg_vol_100 * super_vol_mult or vs >= highest_vs) and not is_ultra_bull_raw and not is_blowoff_top
is_super_bear_raw   = is_bear and (volume >= avg_vol_100 * super_vol_mult or vs >= highest_vs) and not is_ultra_bear_raw and not is_exhaustion_bot

// Display versions (respect toggle for alerts/icons only)
is_ultra_bull   = show_ultra and is_ultra_bull_raw and signal_ready
is_ultra_bear   = show_ultra and is_ultra_bear_raw and signal_ready
is_super_bull   = show_super and is_super_bull_raw and signal_ready
is_super_bear   = show_super and is_super_bear_raw and signal_ready

is_bull_pulse_raw = is_bull and volume >= avg_vol_100 * pulse_vol_mult and not is_super_bull_raw and not is_ultra_bull_raw and not is_blowoff_top
is_bear_pulse_raw = is_bear and volume >= avg_vol_100 * pulse_vol_mult and not is_super_bear_raw and not is_ultra_bear_raw and not is_exhaustion_bot

is_bull_pulse = show_signals and signal_ready and is_bull_pulse_raw
is_bear_pulse = show_signals and signal_ready and is_bear_pulse_raw

// Echo Cascade detection: consecutive vector candles.
// This definition matches every special candle-color state used by candle_color below.
is_vector_candle = is_blowoff_top or is_exhaustion_bot or is_ultra_bull_raw or is_ultra_bear_raw or is_super_bull_raw or is_super_bear_raw or is_bull_pulse_raw or is_bear_pulse_raw

cascade_3_complete = is_vector_candle and is_vector_candle[1] and is_vector_candle[2]
cascade_5_complete = is_vector_candle and is_vector_candle[1] and is_vector_candle[2] and is_vector_candle[3] and is_vector_candle[4]

// Trigger only on the bar where the selected run length is first completed.
cascade_3_trigger = use_3_candle_cascade and cascade_3_complete and not cascade_3_complete[1]
cascade_5_trigger = not use_3_candle_cascade and cascade_5_complete and not cascade_5_complete[1]

var int last_cascade_bar = na
cascade_cooldown_ok = not cascade_cooldown_enabled or na(last_cascade_bar) or (bar_index - last_cascade_bar > cascade_cooldown_bars)
is_cascade = show_cascade and signal_ready and (cascade_3_trigger or cascade_5_trigger) and cascade_cooldown_ok

if is_cascade
    last_cascade_bar := bar_index

// RSI extreme recovery conditions
rsi_val = ta.rsi(close, rsi_len)
rsi_recovery_bear = ta.crossunder(rsi_val, rsi_ob)
rsi_recovery_bull = ta.crossover(rsi_val, rsi_os)
is_breaker_high = show_breaker_chart and show_breaker and show_signals and signal_ready and rsi_recovery_bear
is_breaker_low  = show_breaker_chart and show_breaker and show_signals and signal_ready and rsi_recovery_bull

candle_color =
  is_blowoff_top      ? (simplify_candle_styles ? color_super_bull : color_blowoff_top)    :
  is_exhaustion_bot   ? (simplify_candle_styles ? color_super_bear : color_exhaustion_bot) :
  is_ultra_bull_raw   ? (simplify_candle_styles ? color_super_bull : color_ultra_bull)     :
  is_ultra_bear_raw   ? (simplify_candle_styles ? color_super_bear : color_ultra_bear)     :
  is_super_bull_raw   ? color_super_bull     :
  is_super_bear_raw   ? color_super_bear     :
  is_bull_pulse_raw ? color_bull_pulse   :
  is_bear_pulse_raw ? color_bear_pulse   :
  is_bull             ? color_normal_bull    :
  is_bear             ? color_normal_bear    :
  color.new(color.gray, 60)


bull_fvg = show_fvg_chart and high[2] < low[0]
bear_fvg = show_fvg_chart and low[2] > high[0]

//------------------------------------------------------------------------------
// Anchoring fix:
// - Use xloc.bar_time for every drawable
// - Use pivot bar time for level creation
// - Keep right edge synced to the current bar close time
//------------------------------------------------------------------------------
barRightTime = nz(time_close, time)
is_any_echo_hi = is_vector_candle

if show_vector_echo_chart and show_hi and is_any_echo_hi
    top_ = math.max(open, close)
    bot_ = math.min(open, close)
    min_hi_size = hi_min_ticks * syminfo.mintick
    if top_ > bot_ and (top_ - bot_) >= min_hi_size
        bx = box.new(
          left=time,
          top=top_,
          right=barRightTime,
          bottom=bot_,
          xloc=xloc.bar_time,
          extend=extend.right,
          border_color=na,
          border_width=0,
          bgcolor=color.new(hi_color, hi_alpha)
          )
        array.push(hi_boxes, HighlightBox.new(bx, top_, bot_, time))
        if hi_keep > 0 and array.size(hi_boxes) > hi_keep
            oldHx = array.shift(hi_boxes)
            box.delete(oldHx.visual)


if array.size(hi_boxes) > 0
    for i = array.size(hi_boxes) - 1 to 0
        hx = array.get(hi_boxes, i)

        if time > hx.bornTime
            overlapTop = math.min(high, hx.top)
            overlapBot = math.max(low, hx.bottom)
            hasOverlap = overlapTop > overlapBot

            if hasOverlap
                upperRemain = hx.top - overlapTop
                lowerRemain = overlapBot - hx.bottom

                if upperRemain <= 0 and lowerRemain <= 0
                    box.delete(hx.visual)
                    array.remove(hi_boxes, i)
                else if upperRemain >= lowerRemain
                    hx.bottom := overlapTop
                    box.set_bottom(hx.visual, hx.bottom)
                    array.set(hi_boxes, i, hx)
                else
                    hx.top := overlapBot
                    box.set_top(hx.visual, hx.top)
                    array.set(hi_boxes, i, hx)

barcolor(candle_color) 

//------------------------------------------------------------------------------
// Liquidity Engine (bar_time anchored)
//------------------------------------------------------------------------------
ls = lineStyle == "Solid" ? line.style_solid : lineStyle == "Dashed" ? line.style_dashed : line.style_dotted

processPool(array<LiquidityLevel> pool, bool isHigh) =>
    bool updated = false

    if array.size(pool) > 0
        for i = array.size(pool) - 1 to 0
            LiquidityLevel lvl = array.get(pool, i)
            bool mitigated = isHigh ? high >= lvl.price : low <= lvl.price

            if mitigated and hideMitigated
                line.delete(lvl.visual)
                label.delete(lvl.info)
                LiquidityLevel removedLvl = array.remove(pool, i)
                updated := true
            else
                line.set_x2(lvl.visual, barRightTime)
                label.set_x(lvl.info, barRightTime)

                if mitigated
                    line.set_color(lvl.visual, color.new(color.gray, 80))
                    label.set_textcolor(lvl.info, color.new(color.gray, 80))

    updated

topPivot = ta.pivothigh(high, pivotLookback, pivotLookback)
botPivot = ta.pivotlow(low, pivotLookback, pivotLookback)
pivotTime = time[pivotLookback]

// IMPORTANT:
// LQ should not depend on show_signals, because Minimal Mode disables show_signals.
// This keeps LQ controlled only by the Liquidity toggle.
if show_liquidity_chart
    if not na(topPivot)
        line l = line.new(
          pivotTime,
          topPivot,
          barRightTime,
          topPivot,
          xloc=xloc.bar_time,
          extend=extend.none,
          color=colorHigh,
          style=ls
          )

        label lb = label.new(
          pivotTime,
          topPivot,
          "LQ",
          xloc=xloc.bar_time,
          color=color.new(colorHigh, 100),
          textcolor=colorHigh,
          style=label.style_label_left,
          size=size.small
          )

        array.push(buySidePool, LiquidityLevel.new(topPivot, l, lb))

        if array.size(buySidePool) > maxLiquidityVisuals
            LiquidityLevel oldBuy = array.get(buySidePool, 0)
            line.delete(oldBuy.visual)
            label.delete(oldBuy.info)
            LiquidityLevel removedBuy = array.remove(buySidePool, 0)

    if not na(botPivot)
        line l = line.new(
          pivotTime,
          botPivot,
          barRightTime,
          botPivot,
          xloc=xloc.bar_time,
          extend=extend.none,
          color=colorLow,
          style=ls
          )

        label lb = label.new(
          pivotTime,
          botPivot,
          "LQ",
          xloc=xloc.bar_time,
          color=color.new(colorLow, 100),
          textcolor=colorLow,
          style=label.style_label_left,
          size=size.small
          )

        array.push(sellSidePool, LiquidityLevel.new(botPivot, l, lb))

        if array.size(sellSidePool) > maxLiquidityVisuals
            LiquidityLevel oldSell = array.get(sellSidePool, 0)
            line.delete(oldSell.visual)
            label.delete(oldSell.info)
            LiquidityLevel removedSell = array.remove(sellSidePool, 0)

    processPool(buySidePool, true)
    processPool(sellSidePool, false)

else
    if array.size(buySidePool) > 0
        for i = array.size(buySidePool) - 1 to 0
            LiquidityLevel oldBuyClear = array.get(buySidePool, i)
            line.delete(oldBuyClear.visual)
            label.delete(oldBuyClear.info)
        array.clear(buySidePool)

    if array.size(sellSidePool) > 0
        for i = array.size(sellSidePool) - 1 to 0
            LiquidityLevel oldSellClear = array.get(sellSidePool, i)
            line.delete(oldSellClear.visual)
            label.delete(oldSellClear.info)
        array.clear(sellSidePool)

//------------------------------------------------------------------------------
// EMAs + Cloud
//------------------------------------------------------------------------------
// Keep the EMA cloud at the bottom of this script's plot/fill stack.
// With explicit_plot_zorder=true, earlier plot/fill calls stay behind later ones.
cloud_size = ta.stdev(close, ema_len3 * 2) * cloud_mult / cloud_div
cloud_top = ema3 + cloud_size
cloud_btm = ema3 - cloud_size
p1 = plot(show_ema ? cloud_top : na, "Cloud Top", color=color.new(#471c4f, 0), editable=false)
p2 = plot(show_ema ? cloud_btm : na, "Cloud Bottom", color=color.new(#471c4f, 0), editable=false)
fill(p1, p2, color=color.new(#471c4f, 30), title="EMA Cloud Fill", editable=false)

plot(show_ema ? ema1 : na, "Fast EMA", color=color.new(ema_col1, 0))
plot(show_ema ? ema2 : na, "Medium EMA", color=color.new(ema_col2, 0))
plot(show_ema ? ema3 : na, "Baseline EMA", color=color.new(ema_col3, 0))
plot(show_ema ? ema4 : na, "Trend EMA", color=color.new(ema4_color, 0), linewidth=2)
plot(show_ema ? ema5 : na, "Long-Term EMA", color=color.new(ema5_color, 0), linewidth=3)

// Echo Cascade Icons
// Labels are used here instead of plotshape() so we can reserve plot-count
// capacity for the candle protection layer at the end of the plot stack.
if show_echo_cascade_chart and show_signals and is_cascade
    label.new(bar_index, high, "", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_xcross, color=color.yellow, size=size.tiny)

// RSI recovery markers
if show_signals and is_breaker_high
    label.new(bar_index, high, "RSI", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.red, 20), textcolor=color.white, size=size.tiny)

if show_signals and is_breaker_low
    label.new(bar_index, low, "RSI", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.green, 20), textcolor=color.white, size=size.tiny)
alertcondition(is_breaker_high, "RSI Recovery Bearish", "RSI crossed back below the configured overbought threshold")
alertcondition(is_breaker_low, "RSI Recovery Bullish", "RSI crossed back above the configured oversold threshold") 

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertcondition(is_super_bull, "Echo Surge Bullish", "Bullish Echo Surge condition met on {{ticker}}")
alertcondition(is_super_bear, "Echo Surge Bearish", "Bearish Echo Surge condition met on {{ticker}}")
alertcondition(is_bull_pulse, "Echo Pulse Bullish", "Bullish Echo Pulse condition met on {{ticker}}")
alertcondition(is_bear_pulse, "Echo Pulse Bearish", "Bearish Echo Pulse condition met on {{ticker}}")
alertcondition(barstate.isconfirmed and bull_fvg, "New Bullish FVG", "Confirmed bullish FVG detected")
alertcondition(barstate.isconfirmed and bear_fvg, "New Bearish FVG", "Confirmed bearish FVG detected")

// --- Volume-Confirmed Pivot Zone Logic ---

// These MUST stay global, not inside `if show_ilz_chart`, otherwise later code/functions cannot see them.
avg_vol_ilz   = ta.ema(volume, i_vol_len)
pivot_hi_ilz  = ta.pivothigh(high, i_sensitivity, i_sensitivity)
pivot_lo_ilz  = ta.pivotlow(low, i_sensitivity, i_sensitivity)

var active_bull_zones = array.new<LiquidityZone>()
var active_bear_zones = array.new<LiquidityZone>()

manage_zones(array<LiquidityZone> zone_array, float top, float bottom, bool is_bull, float vol_val, bool condition) =>
    if condition and not na(top) and not na(bottom)
        color color_base = is_bull ? i_bull_color : i_bear_color
        string txt = i_show_labels and avg_vol_ilz != 0 ? "Vol: " + str.tostring(vol_val / avg_vol_ilz, "#.#") + "x" : ""

        box new_box = box.new(
          left=bar_index[i_sensitivity],
          top=top,
          right=bar_index,
          bottom=bottom,
          border_color=color.new(color_base, 40),
          bgcolor=color_base,
          text=txt,
          text_size=size.tiny,
          text_color=color.new(color_base, 20),
          extend=extend.right
          )

        LiquidityZone new_zone = LiquidityZone.new(new_box, top, bottom, is_bull, vol_val, false, bar_index)
        array.push(zone_array, new_zone)

        if array.size(zone_array) > i_max_zones
            LiquidityZone old_zone = array.remove(zone_array, 0)
            box.delete(old_zone.visual)

process_mitigation(array<LiquidityZone> zone_array) =>
    if array.size(zone_array) > 0
        for i = array.size(zone_array) - 1 to 0
            LiquidityZone zone = array.get(zone_array, i)

            if not zone.mitigated
                float high_val = i_mitigation_mode == "Wick" ? high : math.max(open, close)
                float low_val  = i_mitigation_mode == "Wick" ? low  : math.min(open, close)

                bool mitigated = zone.is_bullish ? low_val < zone.level_bottom : high_val > zone.level_top

                if mitigated
                    zone.mitigated := true

                    if i_remove_mitigated
                        box.delete(zone.visual)
                        array.remove(zone_array, i)
                    else
                        if i_show_mitigated
                            box.set_bgcolor(zone.visual, color.new(zone.is_bullish ? i_bull_color : i_bear_color, 95))
                            box.set_border_color(zone.visual, color.new(zone.is_bullish ? i_bull_color : i_bear_color, 90))
                        box.set_extend(zone.visual, extend.none)
                        box.set_right(zone.visual, bar_index)
                        array.set(zone_array, i, zone)

            if i < array.size(zone_array)
                LiquidityZone live_zone = array.get(zone_array, i)
                if not live_zone.mitigated
                    box.set_right(live_zone.visual, bar_index)

// Main pivot-zone execution
vol_condition_ilz = volume > avg_vol_ilz * i_vol_mult
vol_mult_val      = avg_vol_ilz != 0 ? volume / avg_vol_ilz : 1.0
atr_ilz           = ta.atr(14)
atr_base_ilz      = ta.sma(atr_ilz, 100)
atr_mult          = i_atr_scaling and atr_base_ilz != 0 ? (atr_ilz / atr_base_ilz) * 2.0 : 1.0
dynamic_height    = i_zone_height * (i_vol_scaling ? vol_mult_val : 1.0) * atr_mult

if show_ilz_chart
    manage_zones(
      active_bull_zones,
      low[i_sensitivity],
      low[i_sensitivity] - (dynamic_height[i_sensitivity] * syminfo.mintick),
      true,
      volume[i_sensitivity],
      not na(pivot_lo_ilz) and vol_condition_ilz[i_sensitivity]
      )

    manage_zones(
      active_bear_zones,
      high[i_sensitivity] + (dynamic_height[i_sensitivity] * syminfo.mintick),
      high[i_sensitivity],
      false,
      volume[i_sensitivity],
      not na(pivot_hi_ilz) and vol_condition_ilz[i_sensitivity]
      )

    process_mitigation(active_bull_zones)
    process_mitigation(active_bear_zones)
else
    if array.size(active_bull_zones) > 0
        for i = array.size(active_bull_zones) - 1 to 0
            LiquidityZone z = array.get(active_bull_zones, i)
            box.delete(z.visual)
        array.clear(active_bull_zones)

    if array.size(active_bear_zones) > 0
        for i = array.size(active_bear_zones) - 1 to 0
            LiquidityZone z = array.get(active_bear_zones, i)
            box.delete(z.visual)
        array.clear(active_bear_zones)

// --- Market Structure Core Logic ---
float ms_ph  = ta.pivothigh(ms_pivotLookback, ms_pivotLookback)
float ms_pl  = ta.pivotlow(ms_pivotLookback, ms_pivotLookback)
float ms_iph = ta.pivothigh(ms_internalLookback, ms_internalLookback)
float ms_ipl = ta.pivotlow(ms_internalLookback, ms_internalLookback)

// Update confirmed pivots
if not na(ms_ph)
    lastHigh := StructurePoint.new(ms_ph, bar_index - ms_pivotLookback, true, "")
if not na(ms_pl)
    lastLow := StructurePoint.new(ms_pl, bar_index - ms_pivotLookback, false, "")
if not na(ms_iph)
    lastIntHigh := StructurePoint.new(ms_iph, bar_index - ms_internalLookback, true, "")
if not na(ms_ipl)
    lastIntLow := StructurePoint.new(ms_ipl, bar_index - ms_internalLookback, false, "")

// Detection Logic
float ms_checkPriceHigh = ms_breakType == "Close" ? close : high
float ms_checkPriceLow  = ms_breakType == "Close" ? close : low

// --- Major Structure ---
bool ms_majorBreak = false
// Bullish Breakout
if not na(lastHigh.price) and ms_checkPriceHigh > lastHigh.price and bar_index > lastHigh.index
    if ms_showExternal and show_signals
        string lType = trendDir == -1 ? "CHoCH+" : "BOS"
        render_structure(lastHigh, StructurePoint.new(ms_checkPriceHigh, bar_index, true, lType), ms_bullColor, lType)
    trendDir := 1
    lastHigh.price := na
    ms_majorBreak := true
    lastIntHigh.price := na // Reset internal high on major break to prevent overlap
    lastIntLow.price := na  // Reset internal low on major break to prevent overlap

// Bearish Breakout
if not na(lastLow.price) and ms_checkPriceLow < lastLow.price and bar_index > lastLow.index
    if ms_showExternal and show_signals
        string lType = trendDir == 1 ? "CHoCH+" : "BOS"
        render_structure(lastLow, StructurePoint.new(ms_checkPriceLow, bar_index, false, lType), ms_bearColor, lType)
    trendDir := -1
    lastLow.price := na
    ms_majorBreak := true
    lastIntHigh.price := na // Reset internal high on major break to prevent overlap
    lastIntLow.price := na  // Reset internal low on major break to prevent overlap

// --- Internal Structure ---
if ms_showInternal and not ms_majorBreak and show_signals
    // Internal Bullish Breakout
    if not na(lastIntHigh.price) and ms_checkPriceHigh > lastIntHigh.price and bar_index > lastIntHigh.index
        string lType = intTrendDir == -1 ? "MSS" : "i-BOS"
        if intTrendDir == -1 and trendDir == -1
            lType := "i-CHoCH"
        if ms_internal_render_enabled
            render_structure(lastIntHigh, StructurePoint.new(ms_checkPriceHigh, bar_index, true, lType), ms_intBullColor, lType)
        intTrendDir := 1
        lastIntHigh.price := na

    // Internal Bearish Breakout
    if not na(lastIntLow.price) and ms_checkPriceLow < lastIntLow.price and bar_index > lastIntLow.index
        string lType = intTrendDir == 1 ? "MSS" : "i-BOS"
        if intTrendDir == 1 and trendDir == 1
            lType := "i-CHoCH"
        if ms_internal_render_enabled
            render_structure(lastIntLow, StructurePoint.new(ms_checkPriceLow, bar_index, false, lType), ms_intBearColor, lType)
        intTrendDir := -1
        lastIntLow.price := na

// --- FVG + BPR Execution ---
if barstate.isconfirmed
    if bull_fvg
        top = low[0]
        bottom = high[2]
        if (top - bottom) >= (fvg_min_ticks * syminfo.mintick)
            has_bpr = f_check_bpr(top, bottom, true)
            if not has_bpr
                bx = box.new(bar_index + 1, top, bar_index + 20, bottom, bgcolor=bullColor, border_color=na,
                  text="Bull FVG", text_color=fvg_text_color, text_halign=text.align_center, text_valign=text.align_top, text_size=size.tiny)
                array.push(bullFVGs, FVG.new(bx, top, bottom, true))
                f_clean_oldest(bullFVGs, maxZones)

    if bear_fvg
        top = low[2]
        bottom = high[0]
        if (top - bottom) >= (fvg_min_ticks * syminfo.mintick)
            has_bpr = f_check_bpr(top, bottom, false)
            if not has_bpr
                bx = box.new(bar_index + 1, top, bar_index + 20, bottom, bgcolor=bearColor, border_color=na,
                  text="Bear FVG", text_color=fvg_text_color, text_halign=text.align_center, text_valign=text.align_top, text_size=size.tiny)
                array.push(bearFVGs, FVG.new(bx, top, bottom, false))
                f_clean_oldest(bearFVGs, maxZones)

    if array.size(bullFVGs) > 0
        for i = array.size(bullFVGs) - 1 to 0
            fvg = array.get(bullFVGs, i)
            if low < fvg.bottom
                box.delete(fvg.b)
                array.remove(bullFVGs, i)

    if array.size(bearFVGs) > 0
        for i = array.size(bearFVGs) - 1 to 0
            fvg = array.get(bearFVGs, i)
            if high > fvg.top
                box.delete(fvg.b)
                array.remove(bearFVGs, i)

    if array.size(bprZones) > 0
        for i = array.size(bprZones) - 1 to 0
            b = array.get(bprZones, i)
            b_top = box.get_top(b)
            b_bottom = box.get_bottom(b)
            if low < b_bottom and high > b_top
                box.delete(b)
                array.remove(bprZones, i)

// --- Statistics Table ---
var table statsTable = table.new(position.top_right, 2, 2, border_width=0, frame_width=0, frame_color=color.gray)
if barstate.islast
    table.set_position(statsTable, f_table_position(fvg_table_position_input))
    if show_fvg_table and show_signals
        table.cell(statsTable, 0, 0, "Active Bull FVG", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 1, 0, str.tostring(array.size(bullFVGs)), bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 0, 1, "Active Bear FVG", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=size.small)
        table.cell(statsTable, 1, 1, str.tostring(array.size(bearFVGs)), bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=size.small)
    else
        table.clear(statsTable, 0, 0, 1, 1)


// --- Visuals: High/Low Markers ---
if show_signals and ms_showPivots and not na(ms_ph)
    label.new(bar_index - ms_pivotLookback, ms_ph, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_triangledown, color=color.new(ms_bearColor, 50), size=size.tiny)

if show_signals and ms_showPivots and not na(ms_pl)
    label.new(bar_index - ms_pivotLookback, ms_pl, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_triangleup, color=color.new(ms_bullColor, 50), size=size.tiny)

// --- Stop Hunt & Stopping Volume-Style Logic ---
atr_val_sh = ta.atr(14)
vol_sma_sh = ta.sma(volume, sh_vol_len)[1]
vwap_val_sh = ta.vwap(close)

// Stop Hunt Detection
sh_swing_hi = ta.highest(high, sh_lookback)[1]
sh_swing_lo = ta.lowest(low, sh_lookback)[1]
sh_body = math.max(math.abs(close - open), syminfo.mintick)
sh_upper_wick = high - math.max(open, close)
sh_lower_wick = math.min(open, close) - low

// Sweep reference
last_struct_low = ta.valuewhen(not na(ms_pl), ms_pl, 0)
last_struct_high = ta.valuewhen(not na(ms_ph), ms_ph, 0)
sh_ref_low = sh_location == "Structure" ? last_struct_low : sh_swing_lo
sh_ref_high = sh_location == "Structure" ? last_struct_high : sh_swing_hi
sh_ref_valid_bull = not na(sh_ref_low)
sh_ref_valid_bear = not na(sh_ref_high)

sh_atr_valid = not sh_atr_filter or (high - low) >= atr_val_sh
sh_structure_valid_bull = not sh_choch_filter or trendDir == 1 or intTrendDir == 1
sh_structure_valid_bear = not sh_choch_filter or trendDir == -1 or intTrendDir == -1

sh_bullish = show_stop_hunt_chart and sh_enabled and show_signals and signal_ready and sh_ref_valid_bull and sh_atr_valid and sh_structure_valid_bull and low < sh_ref_low and close > sh_ref_low and sh_lower_wick / sh_body >= sh_wick_ratio and volume > vol_sma_sh * sh_vol_mult
sh_bearish = show_stop_hunt_chart and sh_enabled and show_signals and signal_ready and sh_ref_valid_bear and sh_atr_valid and sh_structure_valid_bear and high > sh_ref_high and close < sh_ref_high and sh_upper_wick / sh_body >= sh_wick_ratio and volume > vol_sma_sh * sh_vol_mult

// Stopping Volume-Style Detection
sv_vol_ref = sv_vol_method == "SMA" ? ta.sma(volume, sv_vol_lookback)[1] : ta.highest(volume, sv_vol_lookback)[1]
sv_body_size = math.max(math.abs(open - close), syminfo.mintick)
sv_upper_wick = high - math.max(open, close)
sv_lower_wick = math.min(open, close) - low
sv_is_high_vol = volume > sv_vol_ref * sv_vol_mult

// Location Filters for Stopping Volume-Style
sv_loc_valid_bull = true
sv_loc_valid_bear = true

if sv_location == "Range Extremes"
    sv_loc_valid_bull := low < sh_swing_lo
    sv_loc_valid_bear := high > sh_swing_hi
else if sv_location == "VWAP"
    sv_loc_valid_bull := low < vwap_val_sh
    sv_loc_valid_bear := high > vwap_val_sh
else if sv_location == "After Sweep"
    sv_loc_valid_bull := nz(ta.barssince(sh_bullish), 100000) < 5
    sv_loc_valid_bear := nz(ta.barssince(sh_bearish), 100000) < 5
else if sv_location == "Premium-Discount"
    sv_range_high = ta.highest(high, 50)
    sv_range_low = ta.lowest(low, 50)
    sv_range_size = sv_range_high - sv_range_low
    sv_loc_valid_bull := low < sv_range_low + (sv_range_size * 0.25)
    sv_loc_valid_bear := high > sv_range_high - (sv_range_size * 0.25)

sv_bull_raw = show_stopping_vol_chart and sv_enabled and show_signals and signal_ready and sv_loc_valid_bull and close < open and sv_is_high_vol and sv_lower_wick / sv_body_size >= sv_min_wick and sv_body_size < atr_val_sh * sv_atr_body and low[1] > low
sv_bear_raw = show_stopping_vol_chart and sv_enabled and show_signals and signal_ready and sv_loc_valid_bear and close > open and sv_is_high_vol and sv_upper_wick / sv_body_size >= sv_min_wick and sv_body_size < atr_val_sh * sv_atr_body and high[1] < high

var int sv_last_bull_bar = na
var int sv_last_bear_bar = na
sv_bullish = sv_bull_raw and (na(sv_last_bull_bar) or bar_index - sv_last_bull_bar > sv_cooldown)
sv_bearish = sv_bear_raw and (na(sv_last_bear_bar) or bar_index - sv_last_bear_bar > sv_cooldown)

if sv_bullish
    sv_last_bull_bar := bar_index
if sv_bearish
    sv_last_bear_bar := bar_index

plotshape(show_signals and sh_bullish, "Stop Hunt Bullish", shape.triangleup, location.belowbar, color.new(sh_bull_col, 0), size=size.small)
plotshape(show_signals and sh_bearish, "Stop Hunt Bearish", shape.triangledown, location.abovebar, color.new(sh_bear_col, 0), size=size.small)
plotshape(show_signals and sv_bullish, "Stopping Volume-Style Bullish", shape.circle, location.belowbar, color.new(sv_bull_col, 0), size=size.tiny)
plotshape(show_signals and sv_bearish, "Stopping Volume-Style Bearish", shape.circle, location.abovebar, color.new(sv_bear_col, 0), size=size.tiny)

bgcolor(sh_show_bg and (sh_bullish or sh_bearish) ? sh_bg_col : na)
bgcolor(sv_show_bg and (sv_bullish or sv_bearish) ? sv_bg_col : na)

alertcondition(sh_bullish, "Stop Hunt Bullish", "Bullish Stop Hunt condition met")
alertcondition(sh_bearish, "Stop Hunt Bearish", "Bearish Stop Hunt condition met")
alertcondition(sv_bullish, "Stopping Volume-Style Bullish", "Bullish Stopping Volume-Style condition detected")
alertcondition(sv_bearish, "Stopping Volume-Style Bearish", "Bearish Stopping Volume-Style condition detected")

// Volume Displacement
sh2_ema = ta.ema(close, sh2_ema_len)
sh2_avg_vol = ta.sma(volume, sh2_vol_lookback)[1]
sh2_price_threshold_mult = 1 + (sh2_price_threshold_pct / 100)

isAtStructureTop = high >= ta.highest(high, sh2_structure_lookback)[1]
isAtStructureBottom = low <= ta.lowest(low, sh2_structure_lookback)[1]

sh2_bull_raw = volume >= sh2_vol_mult * sh2_avg_vol and close >= sh2_price_threshold_mult * sh2_ema
sh2_bear_raw = volume >= sh2_vol_mult * sh2_avg_vol and close <= sh2_ema * (1 - sh2_price_threshold_pct / 100)

// VD timeframe gate is independent of Minimal Mode.
vd_signals_tf_allowed = (not auto_hide_vd_signals_tf or timeframe.in_seconds() < timeframe.in_seconds(vd_signals_hide_from_tf)) and not htf_cleanup_active

sh2_bullish = show_stop_hunt_2_chart and sh2_enabled and vd_signals_tf_allowed and show_signals and signal_ready and sh2_bull_raw and (not sh2_enable_structure_bull or isAtStructureTop)
sh2_bearish = show_stop_hunt_2_chart and sh2_enabled and vd_signals_tf_allowed and show_signals and signal_ready and sh2_bear_raw and (not sh2_enable_structure_bear or isAtStructureBottom)

// Compact VD markers: tiny triangles instead of label boxes.
plotshape(sh2_bullish, "Volume Displacement Bullish", shape.triangleup, location.belowbar, sh2_bull_col, size=size.tiny)
plotshape(sh2_bearish, "Volume Displacement Bearish", shape.triangledown, location.abovebar, sh2_bear_col, size=size.tiny)
alertcondition(sh2_bullish, "Volume Displacement Bullish", "Bullish Volume Displacement condition detected")
alertcondition(sh2_bearish, "Volume Displacement Bearish", "Bearish Volume Displacement condition detected")

// Liquidity Grab: high-volume sweep and reclaim of a prior range extreme
liq_avgBodySize = ta.sma(math.abs(close - open), liq_lookback)[1]
liq_avgVolume = ta.sma(volume, liq_lookback)[1]
liq_bodySize = math.abs(close - open)
liq_fastCandle = liq_bodySize > liq_avgBodySize * liq_body_mult
liq_highVolume = volume > liq_avgVolume * liq_vol_mult
liq_priorHigh = ta.highest(high, liq_lookback)[1]
liq_priorLow = ta.lowest(low, liq_lookback)[1]

isLiquidityGrabBull = show_liq_grab_chart and liq_enabled and show_signals and signal_ready and liq_fastCandle and liq_highVolume and low < liq_priorLow and close > liq_priorLow and close > open
isLiquidityGrabBear = show_liq_grab_chart and liq_enabled and show_signals and signal_ready and liq_fastCandle and liq_highVolume and high > liq_priorHigh and close < liq_priorHigh and close < open

plotshape(isLiquidityGrabBear, "Liquidity Grab Bearish", shape.labeldown, location.abovebar, liq_col, size=size.tiny, text="LQ")
plotshape(isLiquidityGrabBull, "Liquidity Grab Bullish", shape.labelup, location.belowbar, liq_col, size=size.tiny, text="LQ")
alertcondition(isLiquidityGrabBull, "Liquidity Grab Bullish", "Bullish Liquidity Grab condition detected")
alertcondition(isLiquidityGrabBear, "Liquidity Grab Bearish", "Bearish Liquidity Grab condition detected")

// Wick Detector Logic
wick_ema50 = ta.ema(close, emaLength)
wick_candleBody = math.max(math.abs(close - open), syminfo.mintick)
wick_upperWick = high - math.max(open, close)
wick_lowerWick = math.min(open, close) - low

isUpperWickCandle = (wick_lowerWick <= wick_candleBody * 0.2) and (wick_upperWick >= wickRatio * wick_candleBody)
isLowerWickCandle = (wick_upperWick <= wick_candleBody * 0.2) and (wick_lowerWick >= wickRatio * wick_candleBody)

wick_avgVolume = ta.sma(volume, lookbackPeriod)[1]
wick_isHighVolume = volume >= (volumeMultiplier * wick_avgVolume)
wick_isFarFromEMA = (math.abs(close - wick_ema50) >= (emaDistancePercent / 100) * wick_ema50)

isValidUpperWick = show_wick_detection_chart and wick_enabled and show_signals and signal_ready and isUpperWickCandle and wick_isHighVolume and wick_isFarFromEMA
isValidLowerWick = show_wick_detection_chart and wick_enabled and show_signals and signal_ready and isLowerWickCandle and wick_isHighVolume and wick_isFarFromEMA

plotshape(series=isValidUpperWick, title="Upper-Wick Rejection", location=location.abovebar, color=color.rgb(255, 133, 133, 50), style=shape.triangledown, size=size.small, text="W", textcolor=color.white)
plotshape(series=isValidLowerWick, title="Lower-Wick Rejection", location=location.belowbar, color=color.rgb(110, 251, 115, 50), style=shape.triangleup, size=size.small, text="W", textcolor=color.white)

alertcondition(isValidUpperWick, title="Upper-Wick Rejection", message="Upper-wick rejection condition detected")
alertcondition(isValidLowerWick, title="Lower-Wick Rejection", message="Lower-wick rejection condition detected")

// --- Analytical Invalidation Line Drawing Logic ---
if show_sl_lines and show_signals
    float sl_price = na
    color sl_col = sl_line_color
    
    bool is_long = is_exhaustion_bot or is_ultra_bull or is_super_bull or is_bull_pulse or is_breaker_low or sh_bullish or sv_bullish or isLiquidityGrabBull or isValidLowerWick or sh2_bullish
    bool is_short = is_blowoff_top or is_ultra_bear or is_super_bear or is_bear_pulse or is_breaker_high or sh_bearish or sv_bearish or isLiquidityGrabBear or isValidUpperWick or sh2_bearish
    
    if is_long
        sl_price := low * (1 - sl_pct / 100)
        if sl_line_color_match
            sl_col := is_exhaustion_bot ? color_exhaustion_bot : is_ultra_bull ? color_ultra_bull : is_super_bull ? color_super_bull : is_bull_pulse ? color_bull_pulse : is_breaker_low ? color.green : sh_bullish ? sh_bull_col : sv_bullish ? sv_bull_col : isLiquidityGrabBull ? liq_col : isValidLowerWick ? color.rgb(110, 251, 115) : sh2_bullish ? sh2_bull_col : sl_line_color
    
    if is_short
        sl_price := high * (1 + sl_pct / 100)
        if sl_line_color_match
            sl_col := is_blowoff_top ? color_blowoff_top : is_ultra_bear ? color_ultra_bear : is_super_bear ? color_super_bear : is_bear_pulse ? color_bear_pulse : is_breaker_high ? color.red : sh_bearish ? sh_bear_col : sv_bearish ? sv_bear_col : isLiquidityGrabBear ? liq_col : isValidUpperWick ? color.rgb(255, 133, 133) : sh2_bearish ? sh2_bear_col : sl_line_color
        
    if not na(sl_price)
        line.new(bar_index, sl_price, bar_index + sl_line_len, sl_price, color=sl_col, style=f_get_line_style(sl_line_style), width=sl_line_width)


// --- Fib Retracement Logic (Mement integration) ---
int fib_lookback = input.int(20, "Swing Point Lookback", minval=1, group="Fib: Core Parameters", tooltip="Number of bars on each side used to detect swing highs/lows for Fibonacci retracement calculations.")

bool fib_show = input.bool(true, "Show Fib Levels", group="Fib: Settings", tooltip="Toggle visibility of all Fibonacci retracement levels on the chart.") and show_fib_levels_chart
string fib_line_style_input = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group="Fib: Settings", tooltip="Line style used when drawing Fibonacci retracement levels.")
int fib_line_width = input.int(1, "Line Width", minval=1, group="Fib: Settings", tooltip="Thickness of the Fibonacci retracement lines.")
bool fib_show_labels = input.bool(true, "Show Labels", group="Fib: Settings", tooltip="Toggle visibility of price labels on the Fibonacci retracement levels.") and show_fib_levels_chart

bool fib_show0 = input.bool(true, "Show 0.0", group="Fib: Levels", tooltip="Toggle visibility of the 0.0 Fibonacci retracement level.")
bool fib_show236 = input.bool(true, "Show 0.236", group="Fib: Levels", tooltip="Toggle visibility of the 0.236 Fibonacci retracement level.")
bool fib_show382 = input.bool(true, "Show 0.382", group="Fib: Levels", tooltip="Toggle visibility of the 0.382 Fibonacci retracement level.")
bool fib_show441 = input.bool(false, "Show 0.441", group="Fib: Levels", tooltip="Toggle visibility of the 0.441 Fibonacci retracement level.")
bool fib_show5 = input.bool(true, "Show 0.5", group="Fib: Levels", tooltip="Toggle visibility of the 0.5 Fibonacci retracement level.")
bool fib_show5457 = input.bool(false, "Show 0.56", group="Fib: Levels", tooltip="Toggle visibility of the 0.56 Fibonacci retracement level.")
bool fib_show62 = input.bool(true, "Show 0.62", group="Fib: Levels", tooltip="Toggle visibility of the 0.62 Fibonacci retracement level.")
bool fib_show71 = input.bool(true, "Show 0.71", group="Fib: Levels", tooltip="Toggle visibility of the 0.71 Fibonacci retracement level.")
bool fib_show79 = input.bool(true, "Show 0.79", group="Fib: Levels", tooltip="Toggle visibility of the 0.79 Fibonacci retracement level.")
bool fib_show1 = input.bool(true, "Show 1.0", group="Fib: Levels", tooltip="Toggle visibility of the 1.0 Fibonacci retracement level.")

bool fib_use_generic = input.bool(false, "Use Generic Fib Levels", group="Fib: Levels", tooltip="Use simplified/generic Fibonacci levels instead of custom ratios.")

color fib_color0 = input.color(color.purple, "0.0 Color", group="Fib: Colors", tooltip="Color for the 0.0 Fibonacci retracement level.")
color fib_color236 = input.color(color.purple, "0.236 Color", group="Fib: Colors", tooltip="Color for the 0.236 Fibonacci retracement level.")
color fib_color382 = input.color(color.purple, "0.382 Color", group="Fib: Colors", tooltip="Color for the 0.382 Fibonacci retracement level.")
color fib_color441 = input.color(color.orange, "0.441 Color", group="Fib: Colors", tooltip="Color for the 0.441 Fibonacci retracement level.")
color fib_color5 = input.color(color.lime, "0.5 Color", group="Fib: Colors", tooltip="Color for the 0.5 Fibonacci retracement level.")
color fib_color5457 = input.color(color.orange, "0.56 Color", group="Fib: Colors", tooltip="Color for the 0.56 Fibonacci retracement level.")
color fib_color62 = input.color(color.fuchsia, "0.62 Color", group="Fib: Colors", tooltip="Color for the 0.62 Fibonacci retracement level.")
color fib_color71 = input.color(color.fuchsia, "0.71 Color", group="Fib: Colors", tooltip="Color for the 0.71 Fibonacci retracement level.")
color fib_color79 = input.color(color.fuchsia, "0.79 Color", group="Fib: Colors", tooltip="Color for the 0.79 Fibonacci retracement level.")
color fib_color1 = input.color(color.purple, "1.0 Color", group="Fib: Colors", tooltip="Color for the 1.0 Fibonacci retracement level.")

color fib_bull_color = input.color(#00916E, "Bullish Structure Color", group="Fib: Visual Settings", tooltip="Color used for bullish structure lines and labels in Fib mode.")
color fib_bear_color = input.color(#FF2E00, "Bearish Structure Color", group="Fib: Visual Settings", tooltip="Color used for bearish structure lines and labels in Fib mode.")

fib_get_line_style(style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

float fib_ph = ta.pivothigh(high, fib_lookback, fib_lookback)
float fib_pl = ta.pivotlow(low, fib_lookback, fib_lookback)

var float fib_lastPh = na
var int fib_lastPhBar = na
var float fib_lastPl = na
var int fib_lastPlBar = na

var float fib_strongHigh = na
var int fib_strongHighBar = na
var float fib_strongLow = na
var int fib_strongLowBar = na

if not na(fib_ph)
    if na(fib_strongHigh) or fib_ph > fib_strongHigh
        fib_strongHigh := fib_ph
        fib_strongHighBar := bar_index - fib_lookback
    fib_lastPh := fib_ph
    fib_lastPhBar := bar_index - fib_lookback

if not na(fib_pl)
    if na(fib_strongLow) or fib_pl < fib_strongLow
        fib_strongLow := fib_pl
        fib_strongLowBar := bar_index - fib_lookback
    fib_lastPl := fib_pl
    fib_lastPlBar := bar_index - fib_lookback

if not na(fib_strongHigh) and close > fib_strongHigh
    fib_strongLow := fib_lastPl
    fib_strongLowBar := fib_lastPlBar
    fib_strongHigh := high
    fib_strongHighBar := bar_index

if not na(fib_strongLow) and close < fib_strongLow
    fib_strongHigh := fib_lastPh
    fib_strongHighBar := fib_lastPhBar
    fib_strongLow := low
    fib_strongLowBar := bar_index

var line[] fib_lines = array.new_line()
var label[] fib_labels = array.new_label()
var label fib_lastPhLabel = na
var label fib_lastPlLabel = na

fib_clear() =>
    if array.size(fib_lines) > 0
        for i = 0 to array.size(fib_lines) - 1
            line.delete(array.get(fib_lines, i))
        array.clear(fib_lines)
    if array.size(fib_labels) > 0
        for i = 0 to array.size(fib_labels) - 1
            label.delete(array.get(fib_labels, i))
        array.clear(fib_labels)

fib_draw_level(float price, string txt, color col, int startBar) =>
    if not na(price)
        l = line.new(startBar, price, bar_index, price, color=col, style=fib_get_line_style(fib_line_style_input), width=fib_line_width)
        array.push(fib_lines, l)
        if fib_show_labels
            lbl = label.new(bar_index, price, txt, style=label.style_label_left, color=color.new(color.black, 100), textcolor=col, size=size.small)
            array.push(fib_labels, lbl)

if not na(fib_ph) and fib_show_labels
    if not na(fib_lastPhLabel)
        label.delete(fib_lastPhLabel)
    fib_lastPhLabel := label.new(fib_strongHighBar, fib_strongHigh, "Strong Swing High", style=label.style_label_down, color=color.new(fib_bear_color, 80), textcolor=fib_bear_color, size=size.small)

if not na(fib_pl) and fib_show_labels
    if not na(fib_lastPlLabel)
        label.delete(fib_lastPlLabel)
    fib_lastPlLabel := label.new(fib_strongLowBar, fib_strongLow, "Strong Swing Low", style=label.style_label_up, color=color.new(fib_bull_color, 80), textcolor=fib_bull_color, size=size.small)

if fib_show and barstate.islast and not na(fib_strongHigh) and not na(fib_strongLow)
    fib_clear()

    float fib_startPrice = fib_strongLow
    float fib_endPrice = fib_strongHigh
    int fib_startBar = fib_strongLowBar
    float fib_diff = fib_endPrice - fib_startPrice

    if fib_show0
        fib_draw_level(fib_startPrice + fib_diff * 0.0, "0.0 (" + str.tostring(fib_startPrice + fib_diff * 0.0, format.mintick) + ")", fib_color0, fib_startBar)
    if fib_show236
        fib_draw_level(fib_startPrice + fib_diff * 0.236, "0.236 (" + str.tostring(fib_startPrice + fib_diff * 0.236, format.mintick) + ")", fib_color236, fib_startBar)
    if fib_show382
        fib_draw_level(fib_startPrice + fib_diff * 0.382, "0.382 (" + str.tostring(fib_startPrice + fib_diff * 0.382, format.mintick) + ")", fib_color382, fib_startBar)
    if fib_show441 and not fib_use_generic
        fib_draw_level(fib_startPrice + fib_diff * 0.441, "0.441 (" + str.tostring(fib_startPrice + fib_diff * 0.441, format.mintick) + ")", fib_color441, fib_startBar)
    if fib_show5
        fib_draw_level(fib_startPrice + fib_diff * 0.5, "0.5 (" + str.tostring(fib_startPrice + fib_diff * 0.5, format.mintick) + ")", fib_color5, fib_startBar)
    if fib_show5457 and not fib_use_generic
        fib_draw_level(fib_startPrice + fib_diff * 0.56, "0.56 (" + str.tostring(fib_startPrice + fib_diff * 0.56, format.mintick) + ")", fib_color5457, fib_startBar)
    if fib_show62
        float val62 = fib_use_generic ? 0.618 : 0.62
        fib_draw_level(fib_startPrice + fib_diff * val62, str.tostring(val62) + " (" + str.tostring(fib_startPrice + fib_diff * val62, format.mintick) + ")", fib_color62, fib_startBar)
    if fib_show71 and not fib_use_generic
        fib_draw_level(fib_startPrice + fib_diff * 0.71, "0.71 (" + str.tostring(fib_startPrice + fib_diff * 0.71, format.mintick) + ")", fib_color71, fib_startBar)
    if fib_show79
        float val79 = fib_use_generic ? 0.786 : 0.79
        fib_draw_level(fib_startPrice + fib_diff * val79, str.tostring(val79) + " (" + str.tostring(fib_startPrice + fib_diff * val79, format.mintick) + ")", fib_color79, fib_startBar)
    if fib_show1
        fib_draw_level(fib_startPrice + fib_diff * 1.0, "1.0 (" + str.tostring(fib_startPrice + fib_diff * 1.0, format.mintick) + ")", fib_color1, fib_startBar)

if array.size(fib_lines) > 0
    for i = 0 to array.size(fib_lines) - 1
        line.set_x2(array.get(fib_lines, i), bar_index)

if array.size(fib_labels) > 0
    for i = 0 to array.size(fib_labels) - 1
        label.set_x(array.get(fib_labels, i), bar_index)

// -----------------------------------------------------------------------------
// MERGED ADDITION: Yesterday/Last Week/ADR/Pivot reference lines + labels
// -----------------------------------------------------------------------------
const string G_REF = "Reference Levels"

show_ref_levels = input.bool(true, "Show Reference Levels", group=G_REF, tooltip="Toggle visibility of all Reference Levels (Yesterday High/Low, Last Week High/Low, ADR High/Low, Daily Open, Pivot Point, and Mid Pivots).")
adr_len_days    = input.int(14, "ADR Length (days)", minval=1, group=G_REF, tooltip="Number of days used to calculate Average Daily Range (ADR) for high/low levels.")
ref_label_offset_bars = input.int(20, "Reference Label Offset (bars)", minval=0, maxval=500, group=G_REF, tooltip="Number of bars to offset reference level labels to the right for better visibility.")

ref_yh_color   = input.color(color.new(color.lime, 0), "Yesterday High Color", group=G_REF, tooltip="Color for the Yesterday High reference line and label.")
ref_yl_color   = input.color(color.new(color.red, 0), "Yesterday Low Color", group=G_REF, tooltip="Color for the Yesterday Low reference line and label.")
ref_wh_color   = input.color(color.new(color.teal, 0), "Last Week High Color", group=G_REF, tooltip="Color for the Last Week High reference line and label.")
ref_wl_color   = input.color(color.new(color.orange, 0), "Last Week Low Color", group=G_REF, tooltip="Color for the Last Week Low reference line and label.")
ref_adrh_color = input.color(color.new(#43a5f6, 0), "ADR High Color", group=G_REF, tooltip="Color for the ADR High reference line and label.")
ref_adrl_color = input.color(color.new(#43a5f6, 0), "ADR Low Color", group=G_REF, tooltip="Color for the ADR Low reference line and label.")
ref_do_color   = input.color(color.new(#a7a7a7, 0), "Daily Open Color", group=G_REF, tooltip="Color for the Daily Open reference line and label.")
ref_pp_color   = input.color(color.new(color.yellow, 0), "Pivot Point Color", group=G_REF, tooltip="Color for the Pivot Point reference line and label.")

ref_yh_style   = input.string("Dotted", "Yesterday High Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Yesterday High reference line.")
ref_yl_style   = input.string("Dotted", "Yesterday Low Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Yesterday Low reference line.")
ref_wh_style   = input.string("Dotted", "Last Week High Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Last Week High reference line.")
ref_wl_style   = input.string("Dotted", "Last Week Low Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Last Week Low reference line.")
ref_adrh_style = input.string("Dotted", "ADR High Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the ADR High reference line.")
ref_adrl_style = input.string("Dotted", "ADR Low Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the ADR Low reference line.")
ref_do_style   = input.string("Dotted", "Daily Open Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Daily Open reference line.")
ref_pp_style   = input.string("Dotted", "Pivot Point Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Pivot Point reference line.")

// --- Mid Pivot Levels (M0-M5) ---
show_m_levels   = input.bool(true, "Show M Levels (M0-M5)", group=G_REF, tooltip="Toggle visibility of Mid Pivot Levels (M0-M5) derived from the daily range.") and not minimal_mode
ref_m_color     = input.color(color.new(#fbc354, 0), "Mid Pivot Color", group=G_REF, tooltip="Color used for all Mid Pivot (M0-M5) lines and labels.")
ref_m_style     = input.string("Dotted", "Mid Pivot Style", options=["Solid", "Dashed", "Dotted"], group=G_REF, tooltip="Line style for the Mid Pivot (M0-M5) reference lines.")
show_m_labels   = input.bool(true, "Show Mid Pivot Labels", group=G_REF, tooltip="Toggle visibility of text labels on Mid Pivot levels.") and not minimal_mode


// --- Psy Highs and Lows ---
// --- Psy Highs and Lows ---
const string G_PSY = "Psy Levels"

show_psy_levels = input.bool(true, "Show Psy Levels", group=G_PSY, tooltip="Enable Preliminary Supply (Psy) high and low levels. These are key intraday reference zones calculated from the session open using either crypto or forex methodology. When enabled, both the levels and their labels are displayed.")
psy_show_hist   = input.bool(false, "Show Historical Psy Levels", group=G_PSY, tooltip="Keep all previous Psy levels visible on the chart instead of only displaying the most recent session's levels.")
psy_hi_color    = input.color(color.new(#ffffff, 0), "Psy Hi Color", group=G_PSY, tooltip="Color used for the Psy High line and its label text.")
psy_lo_color    = input.color(color.new(#ffffff, 0), "Psy Lo Color", group=G_PSY, tooltip="Color used for the Psy Low line and its label text.")
psy_line_style  = input.string("Dotted", "Psy Line Style", options=["Solid", "Dashed", "Dotted"], group=G_PSY, tooltip="Line style for drawing the Psy High and Psy Low levels (Solid, Dashed, or Dotted).")
psy_label_offset_bars = input.int(10, "Psy Label Offset Bars", minval=0, maxval=100, group=G_PSY, tooltip="Number of bars to offset Psy labels to the right when they are not aligned with Reference Level labels.")
psy_align_with_ref_labels = input.bool(true, "Align Psy Labels With Ref Labels", group=G_PSY, tooltip="When enabled, Psy Hi and Psy Lo labels align horizontally with other reference labels (M levels, Yesterday High/Low, Daily Open, Pivot Points, ADR).")
overridePsyType = input.bool(false, "Override Psy Type", group=G_PSY, tooltip="Force a specific Psy calculation method instead of auto-detecting based on the symbol type.")
psyTypeX        = input.string("crypto", "Psy Type Override", options=["crypto", "forex"], group=G_PSY, tooltip="Manually select the Psy calculation type (crypto or forex) when Override Psy Type is enabled.")

showPsy = timeframe.isminutes and (
     timeframe.multiplier == 60 or
     timeframe.multiplier == 30 or
     timeframe.multiplier == 15 or
     timeframe.multiplier == 5  or
     timeframe.multiplier == 3  or
     timeframe.multiplier == 1)

psyType = overridePsyType ? psyTypeX : (syminfo.type == "forex" ? "forex" : "crypto")

ref_line_style(style) =>
    switch style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dotted

calcPsyLevels(_enabled, _psyType, _sydDST) =>
    oneDayMillis  = 24 * 60 * 60 * 1000
    oneWeekMillis = 7 * oneDayMillis

    sydHour = _sydDST ? 21 : 22

    y = year(time, "GMT")
    m = month(time, "GMT")
    d = dayofmonth(time, "GMT")

    sydOpenToday   = timestamp("GMT", y, m, d, sydHour, 0)
    tokyoOpenToday = timestamp("GMT", y, m, d, 0, 0)
    asiaEndToday   = timestamp("GMT", y, m, d, 8, 0)

    var int   psyStart  = na
    var int   psyEnd    = na
    var int   psyExpiry = na
    var float psyHi     = na
    var float psyLo     = na
    var bool  locked    = false

    cryptoStart = _psyType == "crypto" and dayofweek(time, "GMT") == dayofweek.saturday and time >= sydOpenToday and nz(time[1], time - 1) < sydOpenToday
    forexStart  = _psyType == "forex"  and dayofweek(time, "GMT") == dayofweek.monday   and time >= tokyoOpenToday and nz(time[1], time - 1) < tokyoOpenToday

    if _enabled and (cryptoStart or forexStart)
        psyStart  := cryptoStart ? sydOpenToday : tokyoOpenToday
        psyEnd    := cryptoStart ? asiaEndToday + oneDayMillis : asiaEndToday
        psyExpiry := psyStart + oneWeekMillis
        psyHi     := high
        psyLo     := low
        locked    := false

    inPsyBuild = _enabled and not na(psyStart) and not na(psyEnd) and time >= psyStart and time < psyEnd

    if inPsyBuild and not locked
        psyHi := na(psyHi) ? high : math.max(psyHi, high)
        psyLo := na(psyLo) ? low  : math.min(psyLo, low)

    if not na(psyEnd) and time >= psyEnd
        locked := true

    if not na(psyExpiry) and time >= psyExpiry
        psyHi := na
        psyLo := na
        psyStart := na
        psyEnd := na
        psyExpiry := na
        locked := false

    [psyHi, psyLo, "Psy Hi", "Psy Lo", psyStart]

[psyHi, psyLo, psyHiLabel, psyLoLabel, psySessionStartTime] = calcPsyLevels(showPsy and show_psy_levels, psyType, sydDST)

plot(show_psy_levels and showPsy and psy_show_hist ? psyHi : na, "Psy Hi Historical", color=psy_hi_color, style=plot.style_stepline, linewidth=1)
plot(show_psy_levels and showPsy and psy_show_hist ? psyLo : na, "Psy Lo Historical", color=psy_lo_color, style=plot.style_stepline, linewidth=1)

//------------------------------------------------------------------------------
// Candle protection layer
//------------------------------------------------------------------------------
// TradingView temporarily brings the whole indicator forward when the pointer
// focuses one of its objects (Session, FVG, box, line, etc.). Pine has no
// pointer-events / non-focusable setting for those objects.
//
// The EMA cloud is a fill/plot visual. Re-plotting the chart candles here, as
// the LAST plot-type visual, guarantees that the cloud remains underneath the
// candles inside Echo Vector's own z-order whenever TradingView focuses it.
//
// Native candles are still colored by barcolor() above. Because the indicator
// remains behind_chart=true, these protection candles normally sit behind the
// native chart candles and are only visually important during indicator focus.
plotcandle(
     open,
     high,
     low,
     close,
     title="Candle Protection Layer",
     color=candle_color,
     wickcolor=candle_color,
     bordercolor=color.new(color.black, 100),
     editable=false,
     display=display.all - display.status_line - display.data_window - display.price_scale
     )


var line ln_psyHi = na
var line ln_psyLo = na
var label lbl_psyHi = na
var label lbl_psyLo = na

psyBarMs = nz(time_close - time, nz(time - time[1], 60000))
psyLabelTime = barRightTime + psyBarMs * psy_label_offset_bars
psy_ref_label_time = barRightTime + psyBarMs * (psy_align_with_ref_labels ? ref_label_offset_bars : psy_label_offset_bars)

showCurrentPsy = barstate.islast and show_psy_levels and showPsy and show_all_levels_chart and not na(psyHi) and not na(psyLo) and not na(psySessionStartTime) 

if showCurrentPsy and not psy_show_hist
    if na(ln_psyHi)
        ln_psyHi := line.new(psySessionStartTime, psyHi, barRightTime, psyHi, xloc=xloc.bar_time, extend=extend.right, color=psy_hi_color, style=ref_line_style(psy_line_style), width=1)
    else
        line.set_x2(ln_psyHi, barRightTime)
        line.set_y1(ln_psyHi, psyHi)
        line.set_y2(ln_psyHi, psyHi)
        line.set_color(ln_psyHi, psy_hi_color)
        line.set_style(ln_psyHi, ref_line_style(psy_line_style))

    if na(ln_psyLo)
        ln_psyLo := line.new(psySessionStartTime, psyLo, barRightTime, psyLo, xloc=xloc.bar_time, extend=extend.right, color=psy_lo_color, style=ref_line_style(psy_line_style), width=1)
    else
        line.set_x2(ln_psyLo, barRightTime)
        line.set_y1(ln_psyLo, psyLo)
        line.set_y2(ln_psyLo, psyLo)
        line.set_color(ln_psyLo, psy_lo_color)
        line.set_style(ln_psyLo, ref_line_style(psy_line_style))
else
    if not na(ln_psyHi)
        line.delete(ln_psyHi), ln_psyHi := na
    if not na(ln_psyLo)
        line.delete(ln_psyLo), ln_psyLo := na

if showCurrentPsy and show_psy_levels and show_all_levels_chart
    if na(lbl_psyHi)
        lbl_psyHi := label.new(psy_ref_label_time, psyHi, psyHiLabel, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=psy_hi_color, style=label.style_label_left, size=size.small)
    else
        label.set_x(lbl_psyHi, psy_ref_label_time)
        label.set_y(lbl_psyHi, psyHi)
        label.set_text(lbl_psyHi, psyHiLabel)
        label.set_textcolor(lbl_psyHi, psy_hi_color)

    if na(lbl_psyLo)
        lbl_psyLo := label.new(psy_ref_label_time, psyLo, psyLoLabel, xloc=xloc.bar_time, color=color.new(color.black, 100), textcolor=psy_lo_color, style=label.style_label_left, size=size.small)
    else
        label.set_x(lbl_psyLo, psy_ref_label_time)
        label.set_y(lbl_psyLo, psyLo)
        label.set_text(lbl_psyLo, psyLoLabel)
        label.set_textcolor(lbl_psyLo, psy_lo_color) 
else
    if not na(lbl_psyHi)
        label.delete(lbl_psyHi), lbl_psyHi := na
    if not na(lbl_psyLo)
        label.delete(lbl_psyLo), lbl_psyLo := na

alertcondition(signal_ready and ta.cross(close, psyHi) and showPsy and not na(psyHi), "Price Cross Psy Hi", "Price crossed Psy Hi")
alertcondition(signal_ready and ta.cross(close, psyLo) and showPsy and not na(psyLo), "Price Cross Psy Lo", "Price crossed Psy Lo")

yh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
yl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
wh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
wl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
daily_open     = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
adr_val        = request.security(syminfo.tickerid, "D", ta.sma(high - low, adr_len_days)[1], lookahead=barmerge.lookahead_on)
adr_high_level = daily_open + adr_val / 2
adr_low_level  = daily_open - adr_val / 2
// The ADR value uses completed daily ranges. The current day's open is known from the start of the daily period,
// so the two static ADR references remain symmetric around that open.
pivot_point    = request.security(syminfo.tickerid, "D", (high[1] + low[1] + close[1]) / 3.0, lookahead=barmerge.lookahead_on)

prevH = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
prevL = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
prevC = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

pivR1 = 2 * pivot_point - prevL
pivS1 = 2 * pivot_point - prevH
pivR2 = pivot_point + (pivR1 - pivS1)
pivS2 = pivot_point - (pivR1 - pivS1)
pivR3 = prevH + 2 * (pivot_point - prevL)
pivS3 = prevL - 2 * (prevH - pivot_point)

m0C = (pivS2 + pivS3) / 2
m1C = (pivS1 + pivS2) / 2
m2C = (pivot_point + pivS1) / 2
m3C = (pivot_point + pivR1) / 2
m4C = (pivR1 + pivR2) / 2
m5C = (pivR2 + pivR3) / 2

ref_bar_ms = nz(time_close - time, nz(time - time[1], 60000))
ref_label_time = barRightTime + ref_bar_ms * ref_label_offset_bars

var line  yh_line = na
var line  yl_line = na
var line  wh_line = na
var line  wl_line = na
var line  adrh_line = na
var line  adrl_line = na
var line  pp_line = na
var line  do_line = na

var line  m0_line = na

var line  m1_line = na

var line  m2_line = na

var line  m3_line = na

var line  m4_line = na

var line  m5_line = na

var label yh_lbl = na

var label yl_lbl = na

var label wh_lbl = na

var label wl_lbl = na

var label adrh_lbl = na

var label adrl_lbl = na

var label pp_lbl = na

var label do_lbl = na

var label m0_lbl = na

var label m1_lbl = na

var label m2_lbl = na

var label m3_lbl = na

var label m4_lbl = na

var label m5_lbl = na

if show_ref_levels and show_all_levels_chart
    if not na(daily_open)
        if na(do_line)
            do_line := line.new(time, daily_open, barRightTime, daily_open, xloc=xloc.bar_time, extend=extend.right, color=ref_do_color, width=1, style=ref_line_style(ref_do_style))
        else
            line.set_x2(do_line, barRightTime)
            line.set_y1(do_line, daily_open)
            line.set_y2(do_line, daily_open)
            line.set_color(do_line, ref_do_color)
            line.set_style(do_line, ref_line_style(ref_do_style))
        if na(do_lbl)
            do_lbl := label.new(ref_label_time, daily_open, "Daily Open", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_do_color, size=size.small)
        else
            label.set_x(do_lbl, ref_label_time)
            label.set_y(do_lbl, daily_open)
            label.set_text(do_lbl, "Daily Open")
            label.set_textcolor(do_lbl, ref_do_color)

    if not na(yh)
        if na(yh_line)
            yh_line := line.new(time, yh, barRightTime, yh, xloc=xloc.bar_time, extend=extend.right, color=ref_yh_color, width=1, style=ref_line_style(ref_yh_style))
        else
            line.set_x2(yh_line, barRightTime)
            line.set_y1(yh_line, yh)
            line.set_y2(yh_line, yh)
            line.set_color(yh_line, ref_yh_color)
            line.set_style(yh_line, ref_line_style(ref_yh_style))
        if na(yh_lbl)
            yh_lbl := label.new(ref_label_time, yh, "Yesterday High", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_yh_color, size=size.small)
        else
            label.set_x(yh_lbl, ref_label_time)
            label.set_y(yh_lbl, yh)
            label.set_text(yh_lbl, "Yesterday High")
            label.set_textcolor(yh_lbl, ref_yh_color)

    if not na(yl)
        if na(yl_line)
            yl_line := line.new(time, yl, barRightTime, yl, xloc=xloc.bar_time, extend=extend.right, color=ref_yl_color, width=1, style=ref_line_style(ref_yl_style))
        else
            line.set_x2(yl_line, barRightTime)
            line.set_y1(yl_line, yl)
            line.set_y2(yl_line, yl)
            line.set_color(yl_line, ref_yl_color)
            line.set_style(yl_line, ref_line_style(ref_yl_style))
        if na(yl_lbl)
            yl_lbl := label.new(ref_label_time, yl, "Yesterday Low", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_yl_color, size=size.small)
        else
            label.set_x(yl_lbl, ref_label_time)
            label.set_y(yl_lbl, yl)
            label.set_text(yl_lbl, "Yesterday Low")
            label.set_textcolor(yl_lbl, ref_yl_color)

    if not na(wh)
        if na(wh_line)
            wh_line := line.new(time, wh, barRightTime, wh, xloc=xloc.bar_time, extend=extend.right, color=ref_wh_color, width=1, style=ref_line_style(ref_wh_style))
        else
            line.set_x2(wh_line, barRightTime)
            line.set_y1(wh_line, wh)
            line.set_y2(wh_line, wh)
            line.set_color(wh_line, ref_wh_color)
            line.set_style(wh_line, ref_line_style(ref_wh_style))
        if na(wh_lbl)
            wh_lbl := label.new(ref_label_time, wh, "Last Week High", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_wh_color, size=size.small)
        else
            label.set_x(wh_lbl, ref_label_time)
            label.set_y(wh_lbl, wh)
            label.set_text(wh_lbl, "Last Week High")
            label.set_textcolor(wh_lbl, ref_wh_color)

    if not na(wl)
        if na(wl_line)
            wl_line := line.new(time, wl, barRightTime, wl, xloc=xloc.bar_time, extend=extend.right, color=ref_wl_color, width=1, style=ref_line_style(ref_wl_style))
        else
            line.set_x2(wl_line, barRightTime)
            line.set_y1(wl_line, wl)
            line.set_y2(wl_line, wl)
            line.set_color(wl_line, ref_wl_color)
            line.set_style(wl_line, ref_line_style(ref_wl_style))
        if na(wl_lbl)
            wl_lbl := label.new(ref_label_time, wl, "Last Week Low", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_wl_color, size=size.small)
        else
            label.set_x(wl_lbl, ref_label_time)
            label.set_y(wl_lbl, wl)
            label.set_text(wl_lbl, "Last Week Low")
            label.set_textcolor(wl_lbl, ref_wl_color)

    if not na(adr_high_level)
        if na(adrh_line)
            adrh_line := line.new(time, adr_high_level, barRightTime, adr_high_level, xloc=xloc.bar_time, extend=extend.right, color=ref_adrh_color, width=1, style=ref_line_style(ref_adrh_style))
        else
            line.set_x2(adrh_line, barRightTime)
            line.set_y1(adrh_line, adr_high_level)
            line.set_y2(adrh_line, adr_high_level)
            line.set_color(adrh_line, ref_adrh_color)
            line.set_style(adrh_line, ref_line_style(ref_adrh_style))
        if na(adrh_lbl)
            adrh_lbl := label.new(ref_label_time, adr_high_level, "ADR High", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_adrh_color, size=size.small)
        else
            label.set_x(adrh_lbl, ref_label_time)
            label.set_y(adrh_lbl, adr_high_level)
            label.set_text(adrh_lbl, "ADR High")
            label.set_textcolor(adrh_lbl, ref_adrh_color)

    if not na(adr_low_level)
        if na(adrl_line)
            adrl_line := line.new(time, adr_low_level, barRightTime, adr_low_level, xloc=xloc.bar_time, extend=extend.right, color=ref_adrl_color, width=1, style=ref_line_style(ref_adrl_style))
        else
            line.set_x2(adrl_line, barRightTime)
            line.set_y1(adrl_line, adr_low_level)
            line.set_y2(adrl_line, adr_low_level)
            line.set_color(adrl_line, ref_adrl_color)
            line.set_style(adrl_line, ref_line_style(ref_adrl_style))
        if na(adrl_lbl)
            adrl_lbl := label.new(ref_label_time, adr_low_level, "ADR Low", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_adrl_color, size=size.small)
        else
            label.set_x(adrl_lbl, ref_label_time)
            label.set_y(adrl_lbl, adr_low_level)
            label.set_text(adrl_lbl, "ADR Low")
            label.set_textcolor(adrl_lbl, ref_adrl_color)

    if not na(pivot_point)
        if na(pp_line)
            pp_line := line.new(time, pivot_point, barRightTime, pivot_point, xloc=xloc.bar_time, extend=extend.right, color=ref_pp_color, width=1, style=ref_line_style(ref_pp_style))
        else
            line.set_x2(pp_line, barRightTime)
            line.set_y1(pp_line, pivot_point)
            line.set_y2(pp_line, pivot_point)
            line.set_color(pp_line, ref_pp_color)
            line.set_style(pp_line, ref_line_style(ref_pp_style))
        if na(pp_lbl)
            pp_lbl := label.new(ref_label_time, pivot_point, "Pivot Point", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_pp_color, size=size.small)
        else
            label.set_x(pp_lbl, ref_label_time)
            label.set_y(pp_lbl, pivot_point)
            label.set_text(pp_lbl, "Pivot Point")
            label.set_textcolor(pp_lbl, ref_pp_color)

    if show_m_levels and show_m_levels_chart and show_all_levels_chart
        if not na(m0C)
            if na(m0_line)
                m0_line := line.new(time, m0C, barRightTime, m0C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m0_line, barRightTime)
                line.set_y1(m0_line, m0C)
                line.set_y2(m0_line, m0C)
                line.set_color(m0_line, ref_m_color)
                line.set_style(m0_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m0_lbl)
                    m0_lbl := label.new(ref_label_time, m0C, "M0", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m0_lbl, ref_label_time)
                    label.set_y(m0_lbl, m0C)
                    label.set_text(m0_lbl, "M0")
                    label.set_textcolor(m0_lbl, ref_m_color)

        if not na(m1C)
            if na(m1_line)
                m1_line := line.new(time, m1C, barRightTime, m1C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m1_line, barRightTime)
                line.set_y1(m1_line, m1C)
                line.set_y2(m1_line, m1C)
                line.set_color(m1_line, ref_m_color)
                line.set_style(m1_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m1_lbl)
                    m1_lbl := label.new(ref_label_time, m1C, "M1", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m1_lbl, ref_label_time)
                    label.set_y(m1_lbl, m1C)
                    label.set_text(m1_lbl, "M1")
                    label.set_textcolor(m1_lbl, ref_m_color)

        if not na(m2C)
            if na(m2_line)
                m2_line := line.new(time, m2C, barRightTime, m2C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m2_line, barRightTime)
                line.set_y1(m2_line, m2C)
                line.set_y2(m2_line, m2C)
                line.set_color(m2_line, ref_m_color)
                line.set_style(m2_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m2_lbl)
                    m2_lbl := label.new(ref_label_time, m2C, "M2", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m2_lbl, ref_label_time)
                    label.set_y(m2_lbl, m2C)
                    label.set_text(m2_lbl, "M2")
                    label.set_textcolor(m2_lbl, ref_m_color)

        if not na(m3C)
            if na(m3_line)
                m3_line := line.new(time, m3C, barRightTime, m3C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m3_line, barRightTime)
                line.set_y1(m3_line, m3C)
                line.set_y2(m3_line, m3C)
                line.set_color(m3_line, ref_m_color)
                line.set_style(m3_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m3_lbl)
                    m3_lbl := label.new(ref_label_time, m3C, "M3", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m3_lbl, ref_label_time)
                    label.set_y(m3_lbl, m3C)
                    label.set_text(m3_lbl, "M3")
                    label.set_textcolor(m3_lbl, ref_m_color)

        if not na(m4C)
            if na(m4_line)
                m4_line := line.new(time, m4C, barRightTime, m4C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m4_line, barRightTime)
                line.set_y1(m4_line, m4C)
                line.set_y2(m4_line, m4C)
                line.set_color(m4_line, ref_m_color)
                line.set_style(m4_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m4_lbl)
                    m4_lbl := label.new(ref_label_time, m4C, "M4", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m4_lbl, ref_label_time)
                    label.set_y(m4_lbl, m4C)
                    label.set_text(m4_lbl, "M4")
                    label.set_textcolor(m4_lbl, ref_m_color)

        if not na(m5C)
            if na(m5_line)
                m5_line := line.new(time, m5C, barRightTime, m5C, xloc=xloc.bar_time, extend=extend.right, color=ref_m_color, width=1, style=ref_line_style(ref_m_style))
            else
                line.set_x2(m5_line, barRightTime)
                line.set_y1(m5_line, m5C)
                line.set_y2(m5_line, m5C)
                line.set_color(m5_line, ref_m_color)
                line.set_style(m5_line, ref_line_style(ref_m_style))
            if show_m_labels
                if na(m5_lbl)
                    m5_lbl := label.new(ref_label_time, m5C, "M5", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=ref_m_color, size=size.small)
                else
                    label.set_x(m5_lbl, ref_label_time)
                    label.set_y(m5_lbl, m5C)
                    label.set_text(m5_lbl, "M5")
                    label.set_textcolor(m5_lbl, ref_m_color)

else
    if not na(yh_line)
        line.delete(yh_line), yh_line := na
    if not na(yl_line)
        line.delete(yl_line), yl_line := na
    if not na(wh_line)
        line.delete(wh_line), wh_line := na
    if not na(wl_line)
        line.delete(wl_line), wl_line := na
    if not na(adrh_line)
        line.delete(adrh_line), adrh_line := na
    if not na(adrl_line)
        line.delete(adrl_line), adrl_line := na
    if not na(pp_line)
        line.delete(pp_line), pp_line := na
    if not na(m0_line)
        line.delete(m0_line), m0_line := na
    if not na(m1_line)
        line.delete(m1_line), m1_line := na
    if not na(m2_line)
        line.delete(m2_line), m2_line := na
    if not na(m3_line)
        line.delete(m3_line), m3_line := na
    if not na(m4_line)
        line.delete(m4_line), m4_line := na
    if not na(m5_line)
        line.delete(m5_line), m5_line := na

    if not na(yh_lbl)
        label.delete(yh_lbl), yh_lbl := na
    if not na(yl_lbl)
        label.delete(yl_lbl), yl_lbl := na
    if not na(wh_lbl)
        label.delete(wh_lbl), wh_lbl := na
    if not na(wl_lbl)
        label.delete(wl_lbl), wl_lbl := na
    if not na(adrh_lbl)
        label.delete(adrh_lbl), adrh_lbl := na
    if not na(adrl_lbl)
        label.delete(adrl_lbl), adrl_lbl := na
    if not na(m0_lbl)
        label.delete(m0_lbl), m0_lbl := na
    if not na(m1_lbl)
        label.delete(m1_lbl), m1_lbl := na
    if not na(m2_lbl)
        label.delete(m2_lbl), m2_lbl := na
    if not na(m3_lbl)
        label.delete(m3_lbl), m3_lbl := na
    if not na(m4_lbl)
        label.delete(m4_lbl), m4_lbl := na
    if not na(m5_lbl)
        label.delete(m5_lbl), m5_lbl := na
    if not na(pp_lbl)
        label.delete(pp_lbl), pp_lbl := na

// --- Historical Condition-Outcome Tracking ---
type ConditionStats
    int targets = 0
    int invalidations = 0
    float active_tp = na
    float active_sl = na

var stats_sh_bull  = ConditionStats.new()
var stats_sh_bear  = ConditionStats.new()
var stats_sh2_bear = ConditionStats.new()
var stats_sh2_bull = ConditionStats.new()
var stats_sv_bull  = ConditionStats.new()
var stats_sv_bear  = ConditionStats.new()
var stats_liq_bull = ConditionStats.new()
var stats_liq_bear = ConditionStats.new()
var stats_wick_bull = ConditionStats.new()
var stats_wick_bear = ConditionStats.new()
var stats_blowoff_top = ConditionStats.new()
var stats_exhaustion_bot = ConditionStats.new()
var stats_pulse_bull = ConditionStats.new()
var stats_pulse_bear = ConditionStats.new()
var stats_breaker_high = ConditionStats.new()
var stats_breaker_low = ConditionStats.new()

update_stats(bool signal, bool is_bull, ConditionStats stats, float tp, float sl) =>
    // Check an existing historical observation.
    if not na(stats.active_tp)
        bool target_hit = is_bull ? high >= stats.active_tp : low <= stats.active_tp
        bool invalidation_hit = is_bull ? low <= stats.active_sl : high >= stats.active_sl

        // OHLC data cannot determine intrabar order when both boundaries are reached.
        // Count the ambiguous case conservatively as a Stop.
        if invalidation_hit
            stats.invalidations += 1
            stats.active_tp := na
            stats.active_sl := na
        else if target_hit
            stats.targets += 1
            stats.active_tp := na
            stats.active_sl := na

    // Open one new observation per category when no observation is active.
    if na(stats.active_tp) and signal
        stats.active_tp := is_bull ? close * (1 + tp / 100) : close * (1 - tp / 100)
        stats.active_sl := is_bull ? close * (1 - sl / 100) : close * (1 + sl / 100)

update_stats(sh_bullish, true, stats_sh_bull, tp_pct, sl_pct)
update_stats(sh_bearish, false, stats_sh_bear, tp_pct, sl_pct)
update_stats(sh2_bullish, true, stats_sh2_bull, tp_pct, sl_pct)
update_stats(sh2_bearish, false, stats_sh2_bear, tp_pct, sl_pct)
update_stats(sv_bullish, true, stats_sv_bull, tp_pct, sl_pct)
update_stats(sv_bearish, false, stats_sv_bear, tp_pct, sl_pct)
update_stats(isLiquidityGrabBull, true, stats_liq_bull, tp_pct, sl_pct)
update_stats(isLiquidityGrabBear, false, stats_liq_bear, tp_pct, sl_pct)
update_stats(isValidLowerWick, true, stats_wick_bull, tp_pct, sl_pct)
update_stats(isValidUpperWick, false, stats_wick_bear, tp_pct, sl_pct)
update_stats(signal_ready and is_blowoff_top, false, stats_blowoff_top, tp_pct, sl_pct)
update_stats(signal_ready and is_exhaustion_bot, true, stats_exhaustion_bot, tp_pct, sl_pct)
update_stats(is_bull_pulse, true, stats_pulse_bull, tp_pct, sl_pct)
update_stats(is_bear_pulse, false, stats_pulse_bear, tp_pct, sl_pct)
update_stats(is_breaker_low, true, stats_breaker_low, tp_pct, sl_pct)
update_stats(is_breaker_high, false, stats_breaker_high, tp_pct, sl_pct)

// --- Display Outcome Table ---
var perf_table = table.new(position.top_left, 5, 9, border_width=0, frame_width=0, frame_color=color.gray)
f_outcome_rate(t, s) =>
    total = t + s
    total > 0 ? " (" + str.tostring(t / total * 100, "#.##") + "%)" : " (0.00%)"

f_add_row(int row, string name, color bull_col, string bull_txt, color bear_col, string bear_txt) =>

    table.cell(perf_table, 0, row, name, text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
    // Signal-colour swatches: no B/S letters. The cell itself uses the configured signal colour.
    table.cell(perf_table, 1, row, " ", text_color=bull_col, bgcolor=bull_col, text_size=size.small)
    table.cell(perf_table, 2, row, bull_txt, text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
    table.cell(perf_table, 3, row, " ", text_color=bear_col, bgcolor=bear_col, text_size=size.small)
    table.cell(perf_table, 4, row, bear_txt, text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)

if barstate.islast
    table.set_position(perf_table, f_table_position(outcome_table_position_input))

if barstate.islast and show_signals and show_table
    // Clear old row contents first so hidden rows disappear after unticking.
    for r = 0 to 8
        for c = 0 to 4
            table.cell(perf_table, c, r, "", text_color=color.white, bgcolor=color.new(color.gray, 100), text_size=size.small)

    // Header
    if show_table_header
        table.cell(perf_table, 0, 0, "Condition", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        table.cell(perf_table, 1, 0, "", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        table.cell(perf_table, 2, 0, "Bull Target / Stop", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        table.cell(perf_table, 3, 0, "", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
        table.cell(perf_table, 4, 0, "Bear Target / Stop", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)

    row = 1

    if show_row_stop_hunt and show_signals
        f_add_row(
          row,
          "Stop Hunt",
          sh_bull_col,
          str.format("T:{0} S:{1}", stats_sh_bull.targets, stats_sh_bull.invalidations) + f_outcome_rate(stats_sh_bull.targets, stats_sh_bull.invalidations),
          sh_bear_col,
          str.format("T:{0} S:{1}", stats_sh_bear.targets, stats_sh_bear.invalidations) + f_outcome_rate(stats_sh_bear.targets, stats_sh_bear.invalidations)
          )
        row += 1

    if show_row_stop_hunt2 and show_signals
        f_add_row(
          row,
          "Volume Displacement",
          sh2_bull_col,
          str.format("T:{0} S:{1}", stats_sh2_bull.targets, stats_sh2_bull.invalidations) + f_outcome_rate(stats_sh2_bull.targets, stats_sh2_bull.invalidations),
          sh2_bear_col,
          str.format("T:{0} S:{1}", stats_sh2_bear.targets, stats_sh2_bear.invalidations) + f_outcome_rate(stats_sh2_bear.targets, stats_sh2_bear.invalidations)
          )
        row += 1

    if show_row_stopping_vol and show_signals
        f_add_row(
          row,
          "Stopping Volume-Style",
          sv_bull_col,
          str.format("T:{0} S:{1}", stats_sv_bull.targets, stats_sv_bull.invalidations) + f_outcome_rate(stats_sv_bull.targets, stats_sv_bull.invalidations),
          sv_bear_col,
          str.format("T:{0} S:{1}", stats_sv_bear.targets, stats_sv_bear.invalidations) + f_outcome_rate(stats_sv_bear.targets, stats_sv_bear.invalidations)
          )
        row += 1

    if show_row_liq_grab and show_signals
        f_add_row(
          row,
          "Liq Grab",
          liq_col,
          str.format("T:{0} S:{1}", stats_liq_bull.targets, stats_liq_bull.invalidations) + f_outcome_rate(stats_liq_bull.targets, stats_liq_bull.invalidations),
          liq_col,
          str.format("T:{0} S:{1}", stats_liq_bear.targets, stats_liq_bear.invalidations) + f_outcome_rate(stats_liq_bear.targets, stats_liq_bear.invalidations)
          )
        row += 1

    if show_row_wick and show_signals
        f_add_row(
          row,
          "Wick Det.",
          color.rgb(110, 251, 115),
          str.format("T:{0} S:{1}", stats_wick_bull.targets, stats_wick_bull.invalidations) + f_outcome_rate(stats_wick_bull.targets, stats_wick_bull.invalidations),
          color.rgb(255, 133, 133),
          str.format("T:{0} S:{1}", stats_wick_bear.targets, stats_wick_bear.invalidations) + f_outcome_rate(stats_wick_bear.targets, stats_wick_bear.invalidations)
          )
        row += 1

    if show_row_short_gnd and show_signals
        f_add_row(
          row,
          "Exhaustion",
          color_exhaustion_bot,
          str.format("T:{0} S:{1}", stats_exhaustion_bot.targets, stats_exhaustion_bot.invalidations) + f_outcome_rate(stats_exhaustion_bot.targets, stats_exhaustion_bot.invalidations),
          color_blowoff_top,
          str.format("T:{0} S:{1}", stats_blowoff_top.targets, stats_blowoff_top.invalidations) + f_outcome_rate(stats_blowoff_top.targets, stats_blowoff_top.invalidations)
          )
        row += 1

    if show_row_breaker and show_signals
        f_add_row(
          row,
          "RSI Recovery",
          color.green,
          str.format("T:{0} S:{1}", stats_breaker_low.targets, stats_breaker_low.invalidations) + f_outcome_rate(stats_breaker_low.targets, stats_breaker_low.invalidations),
          color.red,
          str.format("T:{0} S:{1}", stats_breaker_high.targets, stats_breaker_high.invalidations) + f_outcome_rate(stats_breaker_high.targets, stats_breaker_high.invalidations)
          )
````
