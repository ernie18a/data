# Echo Vector PVSRA Volume

- url: https://www.tradingview.com/script/9S8KYpJP-Echo-Vector-PVSRA-Volume/
- type: indicator
- pine_id: PUB;ab5cfd019d9d4bcab03d5f3f57cdb01c
- version: 6.0

## Description

### Credits and licence

The starting point for the relative-volume and volume-spread classification framework was the open-source “Traders Reality PVSRA Volume Suite,” originally created by infernix with library integration by peshocore, under the Mozilla Public License 2.0.

This derivative is independently named and does not use the Traders Reality or Pattern Watchers names as its branding.

The imported library calculation has been replaced with script-level calculations. This implementation adds configurable volume tiers, price-extension filters, volume divergence, optional divergence lines, extreme-volume event detection, body-recovery measurements, expanded alerts, and simplified historical outcome tables.

### Overview

Echo Volume Structure is a volume-analysis indicator that classifies candles according to:

* reported volume;
* candle direction;
* candle range;
* volume multiplied by candle range;
* body size;
* price extension from a configurable EMA.

The classifications are displayed as colour-coded volume columns in a separate pane.

Users can optionally apply the same classification colours to the candles on the main price chart.

The script also includes:

* regular bullish and bearish volume divergence;
* divergence markers and configurable lines;
* extreme-volume event diamonds;
* body-recovery tracking;
* simplified divergence target/stop outcomes;
* recovery statistics;
* configurable alerts.

The indicator identifies when its mathematical conditions are present. It does not establish why the activity occurred and does not predict what price will do afterward.

### Data source

By default, the indicator uses OHLC and volume data from the active chart symbol and timeframe.

The requested values include:

* open;
* high;
* low;
* close;
* volume.

The data is requested with lookahead disabled.

### Symbol override

Users can optionally analyze data from a different symbol instead of the active chart symbol.

The override can also contain a combination of compatible feeds, such as multiple exchange symbols added together.

Adding several data feeds can increase processing requirements.

When symbol override is enabled, users should confirm that the selected source is meaningfully related to the active chart.

Differences in exchange activity, trading hours, price scale, market structure, and volume reporting can cause the classifications to differ from those produced by the chart symbol.

### Volume-spread calculation

The script calculates a volume-spread value by multiplying candle volume by the candle’s high-to-low range.

This allows the classification process to consider both:

* the amount of reported volume;
* the price range produced during that volume.

A candle may qualify for an elevated classification because its volume is unusually high, its volume-spread value is unusually large, or it meets a combination of volume, body-size, and price-extension conditions.

### Candle-classification hierarchy

The script applies a fixed priority hierarchy.

When a candle qualifies for more than one classification, the highest active tier determines its colour.

The hierarchy from highest to lowest is:

1. Echo Peak Up or Echo Valley Down;
2. Ultra Up or Ultra Down;
3. Echo Surge Up or Echo Surge Down;
4. Echo Pulse Up or Echo Pulse Down;
5. Normal Up or Normal Down.

The classifications are internal analytical categories. They are not measurements of trade quality and do not guarantee reversal or continuation.

### Default colour key

The default candle classifications and colours are:

* Echo Peak Up — bright green;
* Echo Valley Down — bright red;
* Ultra Up — dark green;
* Ultra Down — dark red;
* Echo Surge Up — lime green;
* Echo Surge Down — light red;
* Echo Pulse Up — blue;
* Echo Pulse Down — fuchsia;
* Normal Up — light grey;
* Normal Down — dark grey;
* Extreme Volume Event — yellow diamond;
* Bullish Volume Divergence — turquoise upward triangle;
* Bearish Volume Divergence — coral-red downward triangle.

All classification, divergence, and line colours can be adjusted in the indicator settings.

### Echo Peak Up — bright green

An Echo Peak Up candle is bright green by default.

It requires:

* an up candle;
* volume at or above the selected multiple of the longer-term average volume;
* a candle body above the selected multiple of its average body size;
* price above the selected EMA by more than the configured standard-deviation distance.

The longer-term volume, body, EMA, and deviation settings are independently configurable.

Echo Peak Up identifies an unusually large bullish candle occurring while price is extended above its recent mean.

It may be examined as possible climactic or blow-off activity, but it does not prove that a market top has formed.

Price may continue rising after an Echo Peak Up candle.

### Echo Valley Down — bright red

An Echo Valley Down candle is bright red by default.

It requires:

* a down candle;
* volume at or above the selected multiple of the longer-term average volume;
* a candle body above the selected multiple of its average body size;
* price below the selected EMA by more than the configured standard-deviation distance.

Echo Valley Down identifies an unusually large bearish candle occurring while price is extended below its recent mean.

It may be examined as possible climactic or exhaustion activity, but it does not prove that a market bottom has formed.

Price may continue falling after an Echo Valley Down candle.

### Ultra Up — dark green

An Ultra Up candle is dark green by default.

It occurs when:

* the candle closes above its open;
* volume reaches the selected Ultra multiple of the longer-term average;
* the candle does not meet all the additional body-size and price-extension requirements of Echo Peak Up.

Ultra Up identifies exceptionally high reported volume on an up candle relative to the selected baseline.

It does not determine whether the activity represents accumulation, distribution, continuation, short covering, or reversal.

### Ultra Down — dark red

An Ultra Down candle is dark red by default.

It occurs when:

* the candle closes at or below its open;
* volume reaches the selected Ultra multiple of the longer-term average;
* the candle does not meet all the additional body-size and price-extension requirements of Echo Valley Down.

Ultra Down identifies exceptionally high reported volume on a down candle relative to the selected baseline.

It does not determine whether the activity represents accumulation, distribution, liquidation, continuation, or reversal.

### Echo Surge Up — lime green

An Echo Surge Up candle is lime green by default.

It is an up candle that meets at least one of the following conditions:

* volume reaches the selected Surge multiple of the recent average volume;
* the candle’s volume-spread value reaches or exceeds the highest previous volume-spread value within the selected lookback.

The candle must not already qualify for Echo Peak Up or Ultra Up.

Echo Surge Up identifies elevated volume or volume-spread activity on an up candle.

It is not an automatic bullish entry signal and does not guarantee that price will continue rising.

### Echo Surge Down — light red

An Echo Surge Down candle is light red by default.

It is a down candle that meets at least one of the following conditions:

* volume reaches the selected Surge multiple of the recent average volume;
* the candle’s volume-spread value reaches or exceeds the highest previous volume-spread value within the selected lookback.

The candle must not already qualify for Echo Valley Down or Ultra Down.

Echo Surge Down identifies elevated volume or volume-spread activity on a down candle.

It is not an automatic bearish entry signal and does not guarantee that price will continue falling.

### Echo Pulse Up — blue

An Echo Pulse Up candle is blue by default.

It occurs when:

* the candle closes above its open;
* volume reaches the selected Pulse multiple of the recent average;
* the candle does not qualify for Echo Peak Up, Ultra Up, or Echo Surge Up.

Echo Pulse Up represents moderately elevated volume on an up candle relative to the selected lookback.

It does not guarantee that upward movement will continue.

### Echo Pulse Down — fuchsia

An Echo Pulse Down candle is fuchsia by default.

It occurs when:

* the candle closes at or below its open;
* volume reaches the selected Pulse multiple of the recent average;
* the candle does not qualify for Echo Valley Down, Ultra Down, or Echo Surge Down.

Echo Pulse Down represents moderately elevated volume on a down candle relative to the selected lookback.

It does not guarantee that downward movement will continue.

### Normal Up — light grey

A Normal Up candle is light grey by default.

It closes above its open but does not meet any enabled elevated-volume classification.

A normal classification does not mean that the candle is unimportant. It means only that the selected relative-volume and volume-spread thresholds were not reached.

### Normal Down — dark grey

A Normal Down candle is dark grey by default.

It closes at or below its open but does not meet any enabled elevated-volume classification.

A normal classification does not mean that the candle is unimportant. It means only that the selected relative-volume and volume-spread thresholds were not reached.

### How to interpret the colours

The colour describes the candle’s direction and the relative-volume tier detected by the script.

For example:

* bright green identifies Echo Peak Up;
* bright red identifies Echo Valley Down;
* dark green identifies Ultra Up;
* dark red identifies Ultra Down;
* lime green identifies Echo Surge Up;
* light red identifies Echo Surge Down;
* blue identifies Echo Pulse Up;
* fuchsia identifies Echo Pulse Down;
* light grey identifies Normal Up;
* dark grey identifies Normal Down.

The colour should be interpreted together with price location and market structure.

An elevated-volume up candle near resistance may have a different context from the same classification during a breakout.

An elevated-volume down candle near support may have a different context from the same classification during an established decline.

The colour identifies the configured mathematical condition. It does not identify the intent of market participants and is not an instruction to buy or sell.

### How to use the indicator

Apply the indicator to a liquid symbol with usable volume data.

A practical workflow is:

1. Review the broader price trend and market structure.
2. Observe the normal volume behaviour of the selected symbol and timeframe.
3. Identify where elevated-volume colours appear relative to support, resistance, breakouts, failed breakouts, and extended price movement.
4. Compare the direction of each classified candle with subsequent price behaviour.
5. Note whether the event is isolated or part of a sequence of elevated-volume candles.
6. Review any bullish or bearish divergence marker while accounting for its pivot-confirmation delay.
7. Inspect yellow extreme-volume diamonds and whether price later crosses their recovery level.
8. Use the historical tables only as simplified chart-based measurements.
9. Test alerts on the intended symbol and timeframe.
10. Combine the indicator with independent price, volatility, liquidity, and risk analysis.

Do not treat an individual colour, triangle, diamond, ratio, or alert as an automatic trade instruction.

### Example use of an Echo Peak Up candle

When a bright-green Echo Peak Up candle appears, consider:

* whether price is already extended above its recent mean;
* whether the candle appears near established resistance;
* whether the candle closes strongly or leaves a large wick;
* whether subsequent candles continue higher or fail to maintain progress;
* whether similar high-volume activity appeared earlier;
* whether a bearish divergence is also present.

The condition identifies unusual volume, body size, and price extension. It does not prove a reversal.

### Example use of an Echo Valley Down candle

When a bright-red Echo Valley Down candle appears, consider:

* whether price is already extended below its recent mean;
* whether the candle appears near established support;
* whether the candle closes strongly or leaves a large wick;
* whether subsequent candles continue lower or recover;
* whether similar high-volume activity appeared earlier;
* whether a bullish divergence is also present.

The condition identifies unusual volume, body size, and price extension. It does not prove a reversal.

### Example use of Surge and Pulse candles

Echo Surge and Echo Pulse candles identify lower relative-volume tiers than Echo Peak, Echo Valley, and Ultra candles.

A sequence of lime-green or blue up candles during a breakout can show repeated elevated activity.

A sequence of light-red or fuchsia down candles during a decline can show repeated elevated activity.

The same colours near failed breakouts or important support and resistance may have a different context.

The classifications describe relative volume and direction, not future price outcomes.

### Main-chart candle colouring

When main-chart candle colouring is enabled, the script applies the classification colour to the corresponding candles on the price chart.

When disabled, the original price-chart colours remain unchanged while the classified volume columns continue to appear in the indicator pane.

### Background preset

The Dark Background and Light Background options adjust the table text colour for visibility.

The preset does not change the candle-classification colour palette.

Individual candle and line colours can be changed separately.

### Volume moving average

An optional simple moving average can be displayed over the volume columns.

The moving-average period is configurable.

The visible moving average provides an additional reference for current volume, but it is separate from some of the internal classification averages.

Changing the visible moving-average period does not automatically change the internal Peak, Valley, Ultra, Surge, or Pulse thresholds.

### Regular volume divergence

The divergence module compares confirmed pivots in price with confirmed pivots in volume.

It identifies two regular divergence conditions:

* bullish volume divergence;
* bearish volume divergence.

The conditions show structural disagreement between price pivots and volume pivots.

They do not guarantee that price will reverse.

### Bullish volume divergence — turquoise upward triangle

A turquoise upward triangle marks a confirmed bullish volume divergence.

The condition requires:

* price to form a lower confirmed low;
* volume to form a higher confirmed low.

This means price reached a lower pivot while the volume pivot did not form a corresponding lower low.

Users may examine the condition together with:

* nearby support;
* reduced downward progress;
* candle structure;
* broader trend;
* subsequent volume classifications.

Price can continue lower after bullish volume divergence is confirmed.

### Bearish volume divergence — coral-red downward triangle

A coral-red downward triangle marks a confirmed bearish volume divergence.

The condition requires:

* price to form a higher confirmed high;
* volume to form a lower confirmed high.

This means price reached a higher pivot while the volume pivot did not form a corresponding higher high.

Users may examine the condition together with:

* nearby resistance;
* reduced upward progress;
* candle structure;
* broader trend;
* subsequent volume classifications.

Price can continue higher after bearish volume divergence is confirmed.

### Divergence pivot strength

The Divergence Pivot Strength setting is applied to both the left and right sides of each pivot.

Higher values generally produce:

* fewer pivots;
* broader pivot structures;
* later confirmation;
* fewer divergence markers.

Lower values generally produce:

* more pivots;
* narrower structures;
* earlier confirmation;
* greater sensitivity to short-term noise.

There is no universal pivot value that is suitable for every symbol and timeframe.

### Divergence confirmation delay

A divergence is not known on the exact historical pivot bar.

The script must wait for the selected number of right-side bars before the pivot can be confirmed.

Once confirmed, the triangle is displayed on the earlier pivot bar.

For example, a pivot strength of 5 requires five later bars before confirmation.

The marker therefore appears earlier on the historical chart than the time at which the condition became available.

### Divergence lines in the indicator pane

Optional panel lines connect the previous and current volume pivots associated with the divergence structure.

Users can configure:

* bullish line colour;
* bearish line colour;
* line width;
* solid, dashed, or dotted style.

These lines help users inspect the change in volume pivots.

They do not project future movement.

### Divergence lines on the price chart

Optional price-chart lines provide a visual reference between price points associated with the volume-pivot locations.

Users can configure their colour, width, and style independently from the panel lines.

These lines are visual aids and should not be interpreted as projected support, resistance, or a forecast of future price movement.

### Extreme Volume Event — yellow diamond

A yellow diamond identifies an Extreme Volume Event.

The condition requires a combination of:

* an already elevated-volume classification;
* volume at least four times the rolling average of recent qualifying elevated-volume candles;
* the highest volume within the recent 50-bar period;
* a candle range above the recent average range.

The rolling event-volume average becomes available only after the script has collected 30 qualifying elevated-volume observations.

The diamond identifies an unusually large volume-and-range event under the selected rules.

It does not prove:

* manipulation;
* institutional activity;
* accumulation;
* distribution;
* liquidation;
* an imminent reversal.

### Extreme-event recovery level

When an Extreme Volume Event occurs, the script calculates a configurable level inside the candle’s body.

At the default 50% setting, the recovery level is the midpoint between the candle’s open and close.

It is not the midpoint of the full high-to-low candle range.

A recovery is counted when closing price crosses the body-based level within the selected recovery lookback.

A wick touching the level without a qualifying close-to-close crossing does not count as a recovery.

A recorded recovery does not guarantee continued movement beyond the level.

### Recovery lookback

The Recovery Lookback setting controls how many bars are allowed for price to cross the active recovery level.

If the level is not crossed within the selected number of bars, that event is no longer tracked as unresolved.

The script tracks only one unresolved recovery event at a time.

If a new yellow-diamond event appears before the earlier event is resolved, the active recovery level is replaced by the newer event.

### Historical divergence outcome table

The left table displays:

* Wins;
* Losses;
* Ratio.

When no earlier hypothetical outcome is active, a confirmed bullish or bearish divergence creates a new measurement.

The script records the confirmation-bar closing price and calculates:

* a fixed percentage target;
* a fixed percentage stop.

For a bullish divergence:

* the target is above the recorded close;
* the stop is below the recorded close.

For a bearish divergence:

* the target is below the recorded close;
* the stop is above the recorded close.

The script records which threshold is detected first.

Only one hypothetical divergence outcome is tracked at a time.

A new divergence is ignored while an earlier outcome remains unresolved.

### Same-bar target and stop behaviour

The target is checked before the stop.

If both the target and stop are reached during the same chart bar, the script records the case as a win.

The script does not reconstruct the lower-timeframe path within that candle, so it cannot determine which level was actually reached first.

This is a material limitation of the table.

### Meaning of the win ratio

The displayed ratio is the number of recorded wins divided by the total number of recorded wins and losses.

It is a simplified historical chart measurement.

It is not equivalent to TradingView Strategy Tester results and does not model:

* commissions;
* slippage;
* spread;
* realistic order execution;
* position sizing;
* portfolio equity;
* liquidity;
* overlapping trades;
* all intrabar sequencing possibilities.

The ratio depends on:

* the symbol;
* timeframe;
* available chart history;
* divergence pivot strength;
* target percentage;
* stop percentage.

The displayed results do not imply future performance.

### Extreme-event recovery table

The right table displays:

* Recovered;
* Ratio.

Recovered is the number of yellow-diamond events for which closing price crossed the configured body-recovery level within the selected lookback.

The ratio is the number of recovered events divided by the total number of detected yellow-diamond events.

This is a simplified event measurement.

It is not:

* a reversal probability;
* an accuracy score;
* a trading win rate;
* evidence that future events will behave similarly.

### Alerts

Alerts are available for:

* any elevated-volume candle;
* Echo Peak Up;
* Echo Valley Down;
* Ultra Up or Ultra Down;
* Echo Surge Up or Echo Surge Down;
* Echo Pulse Up or Echo Pulse Down;
* bullish volume divergence;
* bearish volume divergence.

The general elevated-volume alert activates when any non-normal classification is detected.

### Current-bar behaviour

Volume, high, low, and close can continue changing while the current chart candle remains open.

As a result, candle classifications may appear, change tier, change colour, or disappear before the candle closes.

Extreme Volume Event conditions may also change while the current candle remains open.

Pivot divergence requires right-side confirmation, but the confirmation bar itself may still be open when the condition first becomes true.

Users seeking stable alerts should generally configure TradingView alerts for bar-close execution.

### Suggested starting settings

A practical starting process is:

1. Begin with the default settings on a liquid symbol.
2. Observe how frequently each colour appears.
3. Review the relationship between elevated-volume candles and nearby price structure.
4. Keep the default volume multiples until several historical examples have been inspected.
5. Enable chart-candle colouring only if it improves readability.
6. Enable the volume moving average for additional context.
7. Review divergence triangles while accounting for their confirmation delay.
8. Treat yellow diamonds as extreme-volume markers rather than proof of manipulation.
9. Treat both tables as simplified research measurements.
10. Test alerts before relying on them.

### Adjusting the volume tiers

Increase a tier’s volume multiple to make that classification less frequent.

Decrease the multiple to make it more frequent.

Changing the Echo Peak and Echo Valley body, EMA, or deviation settings affects how strictly the script defines price extension and candle size.

More restrictive values generally produce fewer classifications.

Less restrictive values generally produce more classifications.

Settings should be reviewed separately for each market and timeframe.

### What this implementation adds

Compared with the referenced open-source starting framework, this implementation adds or replaces:

* script-level volume calculations;
* script-level volume-spread calculations;
* configurable multi-tier candle classifications;
* longer-term extreme-volume thresholds;
* candle-body filters;
* EMA-extension filters;
* standard-deviation extension measurements;
* independently configurable classification colours;
* dark- and light-background table presets;
* optional main-chart candle colouring;
* regular price-versus-volume divergence;
* configurable divergence markers and lines;
* optional price-chart divergence references;
* Extreme Volume Event diamonds;
* body-based recovery measurements;
* recovery statistics;
* simplified divergence target/stop outcomes;
* expanded alert conditions.

These modules are combined to study relative volume, price response, divergence, and subsequent recovery within one indicator.

### Limitations

* Reported volume differs between exchanges, brokers, markets, and symbols.
* Some markets provide tick volume rather than centralized transaction volume.
* Combined or overridden data feeds can produce different results from the active chart.
* The classification tiers depend on configurable averages, lookbacks, and thresholds.
* An elevated-volume candle does not reveal the identity or intent of market participants.
* Echo Peak Up does not confirm a market top.
* Echo Valley Down does not confirm a market bottom.
* Ultra, Surge, and Pulse classifications are relative-volume categories, not trade-quality grades.
* Candle classifications may change before the current candle closes.
* Pivot divergence is delayed by the selected right-side confirmation length.
* Confirmed divergence markers are displayed on earlier pivot bars.
* Price-chart divergence lines are visual references and not projections.
* Extreme volume does not prove manipulation.
* Extreme-event detection requires sufficient qualifying historical samples.
* The recovery calculation uses body-based levels and closing-price crossings.
* Only one unresolved recovery event is tracked at a time.
* The historical tables are simplified measurements and not full strategy backtests.
* Only one unresolved divergence outcome is tracked at a time.
* Same-bar target and stop sequencing is not reconstructed.
* The outcome tracker checks the target before the stop.
* The indicator does not account for commissions, slippage, spread, liquidity, position sizing, or realistic execution.
* The indicator should not be used as the sole basis for a trading decision.

This indicator is an analytical tool and does not provide financial advice or guaranteed trading outcomes.

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/
//
// Portions of the relative-volume and volume-spread classification framework
// are adapted from “Traders Reality PVSRA Volume Suite” by infernix,
// with library integration by peshocore.
//
// This derivative is independently named and is not affiliated with,
// endorsed by, or published under the Traders Reality or Pattern Watchers brands.
//
// Modifications and additional systems include custom candle tiers,
// price-extension filters, volume divergence, extreme-volume events,
// recovery tracking, historical outcome measurements, and expanded alerts.
//
// Modifications by: BeatingSmartMoney.
// Year: 2026.

//@version=6
indicator(title="Echo Vector PVSRA Volume", shorttitle="Echo Vector PVSRA", format=format.volume, max_lines_count=500)

//──────────────────────────────────────────────────────────────────────────────
// Target / Stop
//──────────────────────────────────────────────────────────────────────────────

group_target_stop = "Target / Stop"

phoneModeTables = input.bool(
     false,
     "Phone Mode for Tables",
     group=group_target_stop,
     tooltip="Shortens the table labels for smaller screens. Target becomes T:, Stop becomes S:, and Ratio becomes R:. In the recovery table the diamond is kept, the Recovered label is removed, and Ratio becomes R:."
)

targetPerc = input.float(
     1.0,
     "Target %",
     minval=0.1,
     step=0.1,
     group=group_target_stop,
     tooltip="Percentage move from the divergence entry price used as the Target. For bullish signals the Target is above entry; for bearish signals it is below entry. The statistics table counts a Target when this level is reached before the Stop."
)

stopPerc = input.float(
     1.0,
     "Stop %",
     minval=0.1,
     step=0.1,
     group=group_target_stop,
     tooltip="Percentage move from the divergence entry price used as the Stop. For bullish signals the Stop is below entry; for bearish signals it is above entry. The statistics table counts a Stop when this level is reached before the Target."
)

//──────────────────────────────────────────────────────────────────────────────
// Indicator Info
//──────────────────────────────────────────────────────────────────────────────

group_info = "Indicator Info"

_ = input.bool(
     true,
     "Tables Info",
     group=group_info,
     tooltip="Left table (Target / Stop / Ratio): Tracks hypothetical trades triggered by the divergence triangles. A Target is counted when price reaches the selected Target % before the Stop %. A Stop is counted when price reaches the selected Stop % before the Target %. Ratio shows the percentage of completed tracked trades that reached Target first. Right table (Recovered / Ratio): Shows how many high-volume Extreme Manipulation (diamond) events reached the selected recovery level."
)

candleGuide = input.bool(
     true,
     "Candle Colour Guide",
     group=group_info,
     tooltip="CANDLE COLOUR GUIDE\n\nThe colours show candle direction plus the strength and context of volume activity. Green shades are bullish candles and red shades are bearish candles. In general, darker green or red means stronger raw volume activity, but the tiers are not ranked by raw volume alone because some also use Volume × Spread, EMA extension and candle-body size.\n\nDEFAULT COLOURS\nBlow-off Top — dark green (RGB 0, 122, 63)\nExhaustion Bottom — dark red (#A2000C)\nEcho Peak Up — green (RGB 2, 185, 96)\nEcho Valley Down — red (#FA0012)\nEcho Surge Up — lime\nEcho Surge Down — light red (#FF5252)\nEcho Pulse Up — blue\nEcho Pulse Down — fuchsia\nNormal Up Candle — grey (#999999)\nNormal Down Candle — dark grey (#575961)\n\nNORMAL UP / NORMAL DOWN\nNormal activity that does not meet any elevated-volume condition.\n\nECHO PULSE UP / ECHO PULSE DOWN\nElevated volume. By default, volume must be at least 1.5× the average volume of the previous 10 candles.\n\nECHO SURGE UP / ECHO SURGE DOWN\nStrong volume. By default, volume must be at least 2× the average volume of the previous 10 candles, OR the candle must produce a Volume × Spread reading at least as large as the highest reading from those previous 10 candles.\n\nBLOW-OFF TOP / EXHAUSTION BOTTOM\nExceptional raw volume. By default, volume must be at least 6× the average volume of the previous 60 candles. These use the darkest default green/red colours because they identify exceptionally large raw volume.\n\nECHO PEAK UP / ECHO VALLEY DOWN\nA more selective extreme condition. By default, volume must be at least 6× the average volume of the previous 60 candles, the candle body must be more than 2× the average body size of the previous 50 candles, and price must be extended beyond the 50 EMA by 2 standard deviations.\n\nIMPORTANT\nEcho Peak / Valley can use a lighter default colour than Blow-off / Exhaustion even though it is a higher-priority special condition. Peak / Valley is not defined by raw volume alone: it also requires extreme price extension and an unusually large candle body. Therefore darker generally means more raw volume, but it does not guarantee that every darker candle has more volume than every lighter candle.\n\nSIMPLIFY COLOURS\nWhen enabled under PVSRA Colours, the special Echo Peak / Valley and Blow-off / Exhaustion colours are switched off. Their detection still works, but bullish candles use the Echo Surge Up colour and bearish candles use the Echo Surge Down colour.\n\nAll colours, lookbacks and multipliers above are the defaults and can be changed in the inputs."
)

//──────────────────────────────────────────────────────────────────────────────
// Color Preset
//──────────────────────────────────────────────────────────────────────────────

group_preset = "Color Preset"

preset = input.string(
     "Dark Background",
     "Background",
     options=["Dark Background", "Light Background"],
     group=group_preset
)

tableTextColor = preset == "Light Background" ? color.black : color.white

//──────────────────────────────────────────────────────────────────────────────
// Symbol Override
//──────────────────────────────────────────────────────────────────────────────

group_override = "PVSRA Override"

overrideSym = input.bool(
     group=group_override,
     title="Override chart symbol?",
     defval=false,
     inline="pvsra",
     tooltip="Enable to fetch volume and OHLC data from the custom symbol below instead of the current chart symbol."
)

pvsraSym = input.string(
     group=group_override,
     title="",
     defval="INDEX:BTCUSD",
     inline="pvsra",
     tooltip="You can use INDEX:BTCUSD or combine multiple feeds like BINANCE:BTCUSDT+COINBASE:BTCUSD. Too many feeds can slow down the script."
)

// Data fetch
p_src(symOverride, sym, ticker, expr) =>
    request.security(
         symOverride ? sym : ticker,
         timeframe.period,
         expr,
         barmerge.gaps_off,
         barmerge.lookahead_off
    )

pVol = p_src(overrideSym, pvsraSym, syminfo.tickerid, volume)
pHi  = p_src(overrideSym, pvsraSym, syminfo.tickerid, high)
pLo  = p_src(overrideSym, pvsraSym, syminfo.tickerid, low)
pCl  = p_src(overrideSym, pvsraSym, syminfo.tickerid, close)
pOp  = p_src(overrideSym, pvsraSym, syminfo.tickerid, open)

//──────────────────────────────────────────────────────────────────────────────
// PVSRA Candle Logic
// Priority: Echo Peak/Valley → Blow-off/Exhaustion → Echo Surge → Echo Pulse → Normal
//──────────────────────────────────────────────────────────────────────────────

group_logic = "PVSRA Candle Logic"

vol_lookback = input.int(
     10,
     "Volume Avg Lookback (Vector)",
     minval=1,
     group=group_logic,
     tooltip="Lookback used for the average volume and highest Volume × Spread comparison used by Echo Surge and Echo Pulse candles."
)

extreme_vol_len = input.int(
     60,
     "Extreme Volume Lookback",
     minval=1,
     group=group_logic,
     tooltip="Lookback used to calculate the baseline average volume for Blow-off / Exhaustion and Echo Peak / Valley candles."
)

peak_valley_vol_mult = input.float(
     6.0,
     "Echo Peak / Valley Volume Mult",
     minval=1.0,
     step=0.1,
     group=group_logic,
     tooltip="Minimum volume multiple versus the Extreme Volume Lookback average required for Echo Peak Up / Echo Valley Down."
)

peak_valley_body_len = input.int(
     50,
     "Echo Peak / Valley Body Lookback",
     minval=1,
     group=group_logic,
     tooltip="Lookback used to calculate average candle-body size for Echo Peak / Valley confirmation."
)

peak_valley_body_mult = input.float(
     2.0,
     "Echo Peak / Valley Body Mult",
     minval=1.0,
     step=0.1,
     group=group_logic,
     tooltip="Required candle-body multiple versus the average body size to confirm Echo Peak / Valley."
)

peak_valley_ema_len = input.int(
     50,
     "Echo Peak / Valley EMA Length",
     minval=1,
     group=group_logic,
     tooltip="EMA length used to measure price extension for Echo Peak / Valley."
)

peak_valley_dev_mult = input.float(
     2.0,
     "Echo Peak / Valley Deviation Mult",
     minval=0.1,
     step=0.1,
     group=group_logic,
     tooltip="Standard-deviation multiplier used to determine whether price is sufficiently extended from the EMA for Echo Peak / Valley."
)

blowoff_vol_mult = input.float(
     6.0,
     "Blow-off / Exhaustion Volume Mult",
     minval=1.0,
     step=0.1,
     group=group_logic,
     tooltip="Minimum volume multiple versus the Extreme Volume Lookback average required for Blow-off Top / Exhaustion Bottom."
)

surge_vol_mult = input.float(
     2.0,
     "Echo Surge Volume Mult (vs Vector Avg)",
     minval=1.0,
     step=0.1,
     group=group_logic,
     tooltip="Volume threshold multiple versus the Vector average used to classify Echo Surge candles. Echo Surge can also trigger from the highest recent Volume × Spread reading."
)

pulse_vol_mult = input.float(
     1.5,
     "Echo Pulse Volume Mult (vs Vector Avg)",
     minval=1.0,
     step=0.1,
     group=group_logic,
     tooltip="Volume threshold multiple versus the Vector average used to classify Echo Pulse candles."
)

show_peak_valley = input.bool(
     true,
     "Enable Echo Peak / Valley",
     group=group_logic,
     tooltip="Turns Echo Peak Up and Echo Valley Down detection on or off."
)

show_blowoff_exhaustion = input.bool(
     true,
     "Enable Blow-off / Exhaustion",
     group=group_logic,
     tooltip="Turns Blow-off Top and Exhaustion Bottom detection on or off."
)

// Core calculations

is_bull = pCl > pOp
is_bear = pCl <= pOp

avg_vol_vec = ta.sma(pVol, math.max(vol_lookback, 1))[1]
avg_vol_extreme = ta.sma(pVol, extreme_vol_len)[1]

vs = pVol * (pHi - pLo)
highest_vs = ta.highest(vs[1], math.max(vol_lookback, 1))

avg_body_peak = ta.sma(math.abs(pCl - pOp), peak_valley_body_len)[1]
ema_peak = ta.ema(pCl, peak_valley_ema_len)[1]
std_peak = ta.stdev(pCl, peak_valley_ema_len)[1]

is_extended_up = pCl > (ema_peak + (std_peak * peak_valley_dev_mult))
is_extended_dn = pCl < (ema_peak - (std_peak * peak_valley_dev_mult))

is_huge_body = math.abs(pCl - pOp) > (avg_body_peak * peak_valley_body_mult)

// Tier 1 — Echo Peak Up / Echo Valley Down

is_echo_peak_up =
     show_peak_valley and
     is_bull and
     (pVol >= avg_vol_extreme * peak_valley_vol_mult) and
     is_extended_up and
     is_huge_body

is_echo_valley_down =
     show_peak_valley and
     is_bear and
     (pVol >= avg_vol_extreme * peak_valley_vol_mult) and
     is_extended_dn and
     is_huge_body

// Tier 2 — Blow-off Top / Exhaustion Bottom

is_blowoff_top =
     show_blowoff_exhaustion and
     is_bull and
     (pVol >= avg_vol_extreme * blowoff_vol_mult) and
     not is_echo_peak_up

is_exhaustion_bottom =
     show_blowoff_exhaustion and
     is_bear and
     (pVol >= avg_vol_extreme * blowoff_vol_mult) and
     not is_echo_valley_down

// Tier 3 — Echo Surge Up / Echo Surge Down

is_echo_surge_up =
     is_bull and
     ((pVol >= avg_vol_vec * surge_vol_mult) or (vs >= highest_vs)) and
     not is_blowoff_top and
     not is_echo_peak_up

is_echo_surge_down =
     is_bear and
     ((pVol >= avg_vol_vec * surge_vol_mult) or (vs >= highest_vs)) and
     not is_exhaustion_bottom and
     not is_echo_valley_down

// Tier 4 — Echo Pulse Up / Echo Pulse Down

is_echo_pulse_up =
     is_bull and
     (pVol >= avg_vol_vec * pulse_vol_mult) and
     not is_echo_surge_up and
     not is_blowoff_top and
     not is_echo_peak_up

is_echo_pulse_down =
     is_bear and
     (pVol >= avg_vol_vec * pulse_vol_mult) and
     not is_echo_surge_down and
     not is_exhaustion_bottom and
     not is_echo_valley_down

//──────────────────────────────────────────────────────────────────────────────
// Colours
//──────────────────────────────────────────────────────────────────────────────

group_colors = "PVSRA Colours"

simplifyColours = input.bool(
     false,
     "Simplify Colours",
     group=group_colors,
     tooltip="When enabled, the special colours for Enable Echo Peak / Valley and Enable Blow-off / Exhaustion are switched off. Their detection and alerts still work, but bullish Echo Peak / Blow-off candles use the Echo Surge Up colour and bearish Echo Valley / Exhaustion candles use the Echo Surge Down colour."
)

color_blowoff_top = input.color(
     color.rgb(0, 122, 63),
     "Blow-off Top",
     group=group_colors,
     tooltip="Colour used for Blow-off Top candles: exceptional bullish raw volume."
)

color_exhaustion_bottom = input.color(
     #a2000c,
     "Exhaustion Bottom",
     group=group_colors,
     tooltip="Colour used for Exhaustion Bottom candles: exceptional bearish raw volume."
)

color_echo_peak_up = input.color(
     color.rgb(2, 185, 96),
     "Echo Peak Up",
     group=group_colors,
     tooltip="Colour used for Echo Peak Up candles: extreme bullish volume with price-extension and large-body confirmation."
)

color_echo_valley_down = input.color(
     #fa0012,
     "Echo Valley Down",
     group=group_colors,
     tooltip="Colour used for Echo Valley Down candles: extreme bearish volume with price-extension and large-body confirmation."
)

color_echo_surge_up = input.color(
     color.lime,
     "Echo Surge Up",
     group=group_colors,
     tooltip="Colour used for Echo Surge Up candles: strong bullish volume or exceptional Volume × Spread."
)

color_echo_surge_down = input.color(
     #ff5252,
     "Echo Surge Down",
     group=group_colors,
     tooltip="Colour used for Echo Surge Down candles: strong bearish volume or exceptional Volume × Spread."
)

color_echo_pulse_up = input.color(
     color.blue,
     "Echo Pulse Up",
     group=group_colors,
     tooltip="Colour used for Echo Pulse Up candles: elevated bullish volume."
)

color_echo_pulse_down = input.color(
     color.fuchsia,
     "Echo Pulse Down",
     group=group_colors,
     tooltip="Colour used for Echo Pulse Down candles: elevated bearish volume."
)

color_normal_bull = input.color(
     #999999,
     "Normal Up Candle",
     group=group_colors,
     tooltip="Default colour for a bullish candle that does not meet an elevated-volume condition."
)

color_normal_bear = input.color(
     color.new(#575961, 0),
     "Normal Down Candle",
     group=group_colors,
     tooltip="Default colour for a bearish candle that does not meet an elevated-volume condition."
)

//──────────────────────────────────────────────────────────────────────────────
// Outputs
//──────────────────────────────────────────────────────────────────────────────

group_out = "Outputs"

setCandleColors = input.bool(
     false,
     "Set candle colors?",
     group=group_out,
     inline="set",
     tooltip="When enabled, recolors chart candles using the current PVSRA classification color."
)

showMarkers = input.bool(
     true,
     "Show markers",
     group=group_out,
     inline="set",
     tooltip="Reserved marker toggle for optional marker displays."
)

markerSize = input.string(
     "Tiny",
     "Marker Size",
     options=["Tiny", "Small", "Normal"],
     group=group_out,
     tooltip="Reserved marker size selector for optional marker displays."
)

// Colour mapping

pvsraColor =
     is_echo_peak_up       ? (simplifyColours ? color_echo_surge_up   : color_echo_peak_up) :
     is_echo_valley_down   ? (simplifyColours ? color_echo_surge_down : color_echo_valley_down) :
     is_blowoff_top        ? (simplifyColours ? color_echo_surge_up   : color_blowoff_top) :
     is_exhaustion_bottom  ? (simplifyColours ? color_echo_surge_down : color_exhaustion_bottom) :
     is_echo_surge_up      ? color_echo_surge_up :
     is_echo_surge_down    ? color_echo_surge_down :
     is_echo_pulse_up      ? color_echo_pulse_up :
     is_echo_pulse_down    ? color_echo_pulse_down :
     is_bull               ? color_normal_bull :
     is_bear               ? color_normal_bear :
     color.new(color.gray, 60)

// Alert flag

alertFlag =
     is_echo_peak_up or
     is_echo_valley_down or
     is_blowoff_top or
     is_exhaustion_bottom or
     is_echo_surge_up or
     is_echo_surge_down or
     is_echo_pulse_up or
     is_echo_pulse_down

// Volume columns

plot(
     pVol,
     style=plot.style_columns,
     color=pvsraColor,
     title="Echo Vector PVSRA Volume"
)

// Optional chart candle colouring

barcolor(
     setCandleColors ? pvsraColor : na,
     title="PVSRA Candle Colours"
)

//──────────────────────────────────────────────────────────────────────────────
// Volume MA
//──────────────────────────────────────────────────────────────────────────────

displayMa = input.bool(
     false,
     "Volume MA",
     group="Volume MA",
     inline="vma",
     tooltip="Show or hide a moving average over the plotted volume."
)

maColor = input.color(
     color.blue,
     "MA Color",
     group="Volume MA",
     inline="vma",
     tooltip="Color of the volume moving average line."
)

maPeriod = input.int(
     20,
     "MA Period",
     minval=1,
     maxval=2000,
     step=1,
     group="Volume MA",
     inline="vma",
     tooltip="Length of the volume moving average."
)

plot(
     displayMa ? ta.sma(pVol, maPeriod) : na,
     title="Volume MA",
     color=maColor
)

//──────────────────────────────────────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────────────────────────────────────

alertcondition(
     alertFlag,
     title="PVSRA Candle Alert",
     message="A non-normal Echo Vector PVSRA candle was detected."
)

alertcondition(
     is_echo_peak_up,
     title="Echo Peak Up",
     message="Echo Peak Up candle detected."
)

alertcondition(
     is_echo_valley_down,
     title="Echo Valley Down",
     message="Echo Valley Down candle detected."
)

alertcondition(
     is_blowoff_top,
     title="Blow-off Top",
     message="Blow-off Top candle detected."
)

alertcondition(
     is_exhaustion_bottom,
     title="Exhaustion Bottom",
     message="Exhaustion Bottom candle detected."
)

alertcondition(
     is_echo_surge_up or is_echo_surge_down,
     title="Echo Surge Candle",
     message="Echo Surge candle detected."
)

alertcondition(
     is_echo_pulse_up or is_echo_pulse_down,
     title="Echo Pulse Candle",
     message="Echo Pulse candle detected."
)

//──────────────────────────────────────────────────────────────────────────────
// Divergence & Recovery
//──────────────────────────────────────────────────────────────────────────────

group_div_rec = "Divergence & Recovery"

div_lookback = input.int(
     5,
     "Divergence Pivot Strength",
     minval=1,
     group=group_div_rec,
     tooltip="Pivot strength used for both left and right bars when finding divergence pivots."
)

recoveryLookback = input.int(
     24,
     "Recovery Lookback (Bars)",
     minval=1,
     group=group_div_rec,
     tooltip="Maximum bars allowed for a diamond event to count as recovered."
)

recoveryPerc = input.float(
     50.0,
     "Recovery Percent (%)",
     minval=0.0,
     maxval=100.0,
     step=1.0,
     group=group_div_rec,
     tooltip="Midpoint recovery threshold inside the candle body used to evaluate diamond recovery."
) / 100.0

color_bull_div = input.color(
     #68FDD4,
     "Bullish Divergence",
     group=group_div_rec,
     tooltip="Color used for bullish divergence markers and default bullish divergence lines."
)

color_bear_div = input.color(
     #FF786E,
     "Bearish Divergence",
     group=group_div_rec,
     tooltip="Color used for bearish divergence markers and default bearish divergence lines."
)

// Original indicator-panel divergence line settings

show_div_lines = input.bool(
     true,
     "Show Divergence Lines on Indicator Panel",
     group=group_div_rec,
     tooltip="Shows the original divergence lines inside the volume indicator panel between volume pivot points."
)

div_line_color_bull = input.color(
     #68FDD4,
     "Bullish Panel Div Line Color",
     group=group_div_rec,
     tooltip="Color used for bullish divergence lines inside the indicator panel."
)

div_line_color_bear = input.color(
     #FF786E,
     "Bearish Panel Div Line Color",
     group=group_div_rec,
     tooltip="Color used for bearish divergence lines inside the indicator panel."
)

div_line_width = input.int(
     2,
     "Panel Divergence Line Width",
     minval=1,
     maxval=5,
     group=group_div_rec,
     tooltip="Line width used for divergence lines inside the indicator panel."
)

div_line_style = input.string(
     "Solid",
     "Panel Divergence Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=group_div_rec,
     tooltip="Line style used for divergence lines inside the indicator panel."
)

// Separate price-chart divergence line settings

show_chart_div_lines = input.bool(
     false,
     "Show Divergence Lines on Price Chart",
     group=group_div_rec,
     tooltip="Shows an additional set of divergence lines directly on the main price chart between price pivot points."
)

chart_div_line_color_bull = input.color(
     #68FDD4,
     "Bullish Chart Div Line Color",
     group=group_div_rec,
     tooltip="Color used for bullish divergence lines on the main price chart."
)

chart_div_line_color_bear = input.color(
     #FF786E,
     "Bearish Chart Div Line Color",
     group=group_div_rec,
     tooltip="Color used for bearish divergence lines on the main price chart."
)

chart_div_line_width = input.int(
     2,
     "Chart Divergence Line Width",
     minval=1,
     maxval=5,
     group=group_div_rec,
     tooltip="Line width used for divergence lines on the main price chart."
)

chart_div_line_style = input.string(
     "Solid",
     "Chart Divergence Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=group_div_rec,
     tooltip="Line style used for divergence lines on the main price chart."
)

// Line style helper

f_divLineStyle(_style) =>
    _style == "Solid" ? line.style_solid :
     _style == "Dashed" ? line.style_dashed :
     line.style_dotted

// Relative volume for diamonds

price_range = high - low
avgSpread20 = ta.sma(price_range, 20)

bool is_climax_vol =
     pVol >= avg_vol_vec * 2.0 or
     vs >= highest_vs

bool is_high_vol =
     not is_climax_vol and
     pVol >= avg_vol_vec * 1.5

// Rolling 30-bar average of vector/high-vol bars only

var float[] vectorArray = array.new_float()

if is_climax_vol or is_high_vol
    array.push(vectorArray, pVol)

    if array.size(vectorArray) > 30
        array.shift(vectorArray)

float avgVectorVol30 = na

if array.size(vectorArray) == 30
    float sum = 0.0

    for i = 0 to 29
        sum += array.get(vectorArray, i)

    avgVectorVol30 := sum / 30

// Diamond conditions

isHugeVsHistory =
     not na(avgVectorVol30) and
     pVol >= avgVectorVol30 * 4

isLargestRecent =
     pVol == ta.highest(pVol, 50)

isWideSpread =
     price_range > avgSpread20 * 1.5

bool isExtremeVol =
     (is_climax_vol or is_high_vol) and
     isHugeVsHistory and
     isLargestRecent and
     isWideSpread

var float diamondMid = na
var bool diamondRecovered = true
var int recoveryCount = 0
var int totalDiamonds = 0
var int diamondBarIndex = 0

if isExtremeVol
    diamondMid :=
         pOp < pCl
         ? pOp + (pCl - pOp) * recoveryPerc
         : pCl + (pOp - pCl) * recoveryPerc

    diamondRecovered := false
    totalDiamonds += 1
    diamondBarIndex := bar_index

if not diamondRecovered and not na(diamondMid) and bar_index > diamondBarIndex

    if bar_index - diamondBarIndex <= recoveryLookback

        if (close[1] < diamondMid and close > diamondMid) or
           (close[1] > diamondMid and close < diamondMid)

            recoveryCount += 1
            diamondRecovered := true

    else
        diamondRecovered := true

plotshape(
     isExtremeVol,
     "Extreme Manipulation",
     shape.diamond,
     location.top,
     color=color.yellow,
     size=size.small
)

//──────────────────────────────────────────────────────────────────────────────
// Divergence Logic
//──────────────────────────────────────────────────────────────────────────────

lbL = div_lookback
lbR = div_lookback

volLowVal = ta.pivotlow(pVol, lbL, lbR)
volHighVal = ta.pivothigh(pVol, lbL, lbR)

priceLowVal = ta.pivotlow(low, lbL, lbR)
priceHighVal = ta.pivothigh(high, lbL, lbR)

volLowCond = not na(volLowVal)
volHighCond = not na(volHighVal)

priceLowCond = not na(priceLowVal)
priceHighCond = not na(priceHighVal)

prevVolLow = ta.valuewhen(volLowCond, volLowVal, 1)
prevPriceLow = ta.valuewhen(priceLowCond, priceLowVal, 1)

prevVolHigh = ta.valuewhen(volHighCond, volHighVal, 1)
prevPriceHigh = ta.valuewhen(priceHighCond, priceHighVal, 1)

prevVolLowBar = ta.valuewhen(volLowCond, bar_index[lbR], 1)
prevVolHighBar = ta.valuewhen(volHighCond, bar_index[lbR], 1)

prevPriceLowBar = ta.valuewhen(priceLowCond, bar_index[lbR], 1)
prevPriceHighBar = ta.valuewhen(priceHighCond, bar_index[lbR], 1)

prevVolLowPrice = ta.valuewhen(volLowCond, low[lbR], 1)
prevVolHighPrice = ta.valuewhen(volHighCond, high[lbR], 1)

bullCond =
     volLowCond and
     priceLowCond and
     priceLowVal < prevPriceLow and
     volLowVal > prevVolLow

bearCond =
     volHighCond and
     priceHighCond and
     priceHighVal > prevPriceHigh and
     volHighVal < prevVolHigh

plotshape(
     bullCond,
     "Bullish Divergence",
     shape.triangleup,
     location.bottom,
     color=color_bull_div,
     size=size.small,
     offset=-lbR
)

plotshape(
     bearCond,
     "Bearish Divergence",
     shape.triangledown,
     location.top,
     color=color_bear_div,
     size=size.small,
     offset=-lbR
)

// Divergence lines

var line[] bullLines = array.new_line()
var line[] bearLines = array.new_line()
var line[] bullChartLines = array.new_line()
var line[] bearChartLines = array.new_line()

// Original bullish divergence lines on indicator panel

if show_div_lines and bullCond and not na(prevVolLowBar) and not na(prevVolLow) and not na(volLowVal)

    array.push(
         bullLines,
         line.new(
              x1=prevVolLowBar,
              y1=prevVolLow,
              x2=bar_index[lbR],
              y2=volLowVal,
              xloc=xloc.bar_index,
              extend=extend.none,
              color=div_line_color_bull,
              width=div_line_width,
              style=f_divLineStyle(div_line_style)
         )
    )

    if array.size(bullLines) > 50
        line.delete(array.shift(bullLines))

// Original bearish divergence lines on indicator panel

if show_div_lines and bearCond and not na(prevVolHighBar) and not na(prevVolHigh) and not na(volHighVal)

    array.push(
         bearLines,
         line.new(
              x1=prevVolHighBar,
              y1=prevVolHigh,
              x2=bar_index[lbR],
              y2=volHighVal,
              xloc=xloc.bar_index,
              extend=extend.none,
              color=div_line_color_bear,
              width=div_line_width,
              style=f_divLineStyle(div_line_style)
         )
    )

    if array.size(bearLines) > 50
        line.delete(array.shift(bearLines))

// Bullish divergence lines on price chart

if show_chart_div_lines and bullCond and not na(prevVolLowBar) and not na(prevVolLowPrice) and not na(priceLowVal)

    array.push(
         bullChartLines,
         line.new(
              x1=prevVolLowBar,
              y1=prevVolLowPrice,
              x2=bar_index[lbR],
              y2=priceLowVal,
              xloc=xloc.bar_index,
              extend=extend.none,
              color=chart_div_line_color_bull,
              width=chart_div_line_width,
              style=f_divLineStyle(chart_div_line_style),
              force_overlay=true
         )
    )

    if array.size(bullChartLines) > 50
        line.delete(array.shift(bullChartLines))

// Bearish divergence lines on price chart

if show_chart_div_lines and bearCond and not na(prevVolHighBar) and not na(prevVolHighPrice) and not na(priceHighVal)

    array.push(
         bearChartLines,
         line.new(
              x1=prevVolHighBar,
              y1=prevVolHighPrice,
              x2=bar_index[lbR],
              y2=priceHighVal,
              xloc=xloc.bar_index,
              extend=extend.none,
              color=chart_div_line_color_bear,
              width=chart_div_line_width,
              style=f_divLineStyle(chart_div_line_style),
              force_overlay=true
         )
    )

    if array.size(bearChartLines) > 50
        line.delete(array.shift(bearChartLines))

//──────────────────────────────────────────────────────────────────────────────
// Target / Stop Tracker
//──────────────────────────────────────────────────────────────────────────────

var int targetCount = 0
var int stopCount = 0

var float entryPrice = na
var int tradeDir = 0

if bullCond and na(entryPrice)
    entryPrice := close
    tradeDir := 1

if bearCond and na(entryPrice)
    entryPrice := close
    tradeDir := -1

if not na(entryPrice)

    float targetPrice =
         tradeDir == 1
         ? entryPrice * (1 + targetPerc / 100)
         : entryPrice * (1 - targetPerc / 100)

    float stopPrice =
         tradeDir == 1
         ? entryPrice * (1 - stopPerc / 100)
         : entryPrice * (1 + stopPerc / 100)

    bool hitTarget =
         tradeDir == 1
         ? high >= targetPrice
         : low <= targetPrice

    bool hitStop =
         tradeDir == 1
         ? low <= stopPrice
         : high >= stopPrice

    if hitTarget
        targetCount += 1
        entryPrice := na
        tradeDir := 0

    else if hitStop
        stopCount += 1
        entryPrice := na
        tradeDir := 0

//──────────────────────────────────────────────────────────────────────────────
// Tables
//──────────────────────────────────────────────────────────────────────────────

var table statsTable = table.new(
     position.top_left,
     3,
     1,
     border_width=1,
     frame_color=color.gray,
     frame_width=1
)

var table recoveryTable = table.new(
     position.top_right,
     3,
     1,
     border_width=1,
     frame_color=color.gray,
     frame_width=1
)

float targetRatio =
     (targetCount + stopCount) > 0
     ? (targetCount / (targetCount + stopCount)) * 100
     : 0

float recoveryRatio =
     totalDiamonds > 0
     ? (recoveryCount / totalDiamonds) * 100
     : 0

string targetTableText =
     phoneModeTables
     ? "T: " + str.tostring(targetCount)
     : "Target: " + str.tostring(targetCount)

string stopTableText =
     phoneModeTables
     ? "S: " + str.tostring(stopCount)
     : "Stop: " + str.tostring(stopCount)

string targetRatioTableText =
     phoneModeTables
     ? "R: " + str.tostring(targetRatio, "#.##") + "%"
     : "Ratio: " + str.tostring(targetRatio, "#.##") + "%"

string recoveryCountTableText =
     phoneModeTables
     ? str.tostring(recoveryCount)
     : "Recovered: " + str.tostring(recoveryCount)

string recoveryRatioTableText =
     phoneModeTables
     ? "R: " + str.tostring(recoveryRatio, "#.##") + "%"
     : "Ratio: " + str.tostring(recoveryRatio, "#.##") + "%"

if barstate.islast

    table.cell(
         statsTable,
         0,
         0,
         targetTableText,
         bgcolor=color.new(color.green, 80),
         text_color=tableTextColor,
         text_size=size.small
    )

    table.cell(
         statsTable,
         1,
         0,
         stopTableText,
         bgcolor=color.new(color.red, 80),
         text_color=tableTextColor,
         text_size=size.small
    )

    table.cell(
         statsTable,
         2,
         0,
         targetRatioTableText,
         bgcolor=color.new(color.gray, 80),
         text_color=tableTextColor,
         text_size=size.small
    )

    table.cell(
         recoveryTable,
         0,
         0,
         "◆",
         bgcolor=color.new(color.gray, 80),
         text_color=color.yellow,
         text_size=size.small
    )

    table.cell(
         recoveryTable,
         1,
         0,
         recoveryCountTableText,
         bgcolor=color.new(color.gray, 80),
         text_color=tableTextColor,
         text_size=size.small
    )

    table.cell(
         recoveryTable,
         2,
         0,
         recoveryRatioTableText,
         bgcolor=color.new(color.gray, 80),
         text_color=tableTextColor,
         text_size=size.small
    )

//──────────────────────────────────────────────────────────────────────────────
// Divergence Alerts
//──────────────────────────────────────────────────────────────────────────────

alertcondition(
     bullCond,
     "Bullish Divergence",
     "Price/Volume bullish divergence identified"
)

alertcondition(
     bearCond,
     "Bearish Divergence",
     "Price/Volume bearish divergence identified"
)
````
