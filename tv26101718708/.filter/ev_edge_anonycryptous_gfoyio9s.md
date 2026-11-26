# EV Edge | Anonycryptous

- url: https://www.tradingview.com/script/GFoYiO9S-EV-Edge-Anonycryptous/
- type: indicator
- pine_id: PUB;43f1ddaaab714df98b68da527a5360c8
- version: 1.0

## Description

EV Edge | Anonycryptous
Description & user manual

Why this indicator is different;
Most breakout indicators stop at the entry. A box compresses, price breaks out, an arrow appears, and the indicator's job is considered done. What happens next - whether that breakout actually develops into a sustained move or stalls and reverses within a few bars - is left entirely to the trader to monitor manually.

EV Edge treats the moment of entry as the beginning of the analysis, not the end of it.
At its core is a consolidation detection engine that identifies tight, compressed ranges using an ATR-based threshold. When price breaks out of one of these ranges in the direction of the move that led into it - a continuation pattern sometimes described as the right side of a V - a signal fires. This part is familiar territory for breakout-based tools.

What happens afterward is not. Every signal starts with an EV score, a value between 0 and 100 that represents the expected value of the trade as it currently stands. The rule is simple: higher is better, lower is worse - for both long and short trades. A score climbing toward 100 means the trade is developing in your favor. A score falling toward 0 means price is moving against you. This holds regardless of direction. A short trade with an EV score of 85 is developing well. A long trade with an EV score of 12 is going the wrong way.

This score is not fixed at entry. It evolves on every subsequent bar based on how price actually behaves - how far it has moved in the trade's favor relative to ATR, and whether it has retraced back into the consolidation zone it broke from. A trade that continues cleanly in its intended direction sees its EV score climb toward 100. A trade that stalls or reverses back into the consolidation sees its score fall toward 0, with the penalty scaling proportionally to how deep the retracement goes.

The trade is then managed automatically by its own EV score. If the score reaches a configurable extreme - high or low - the trade closes out and the indicator becomes ready for the next signal. If neither extreme is reached within a maximum bar count, the trade times out. Every closed trade is recorded with its entry score, exit score, exit reason, and duration in an optional trade log table, turning the chart into a running record of how setups actually played out rather than a static history of where arrows appeared.

This is the central idea behind EV Edge: a signal is not a single judgment made once. It is a starting hypothesis that is continuously re-evaluated against what price does next.


A note on the colors
EV Edge uses two independent color systems that represent different things, and reading them correctly is essential.
The entry label color - the small triangle marker and its background - reflects trade direction. A long entry uses the bull color. A short entry uses the bear color. This is fixed at the moment of entry and never changes.

The trade zone box uses a separate, monochrome system that reflects how strongly the trade is currently developing, independent of direction. The box is a single configurable color throughout - by default a neutral steel grey - and only its intensity changes. Near the middle of the EV range the box is barely visible. As the EV score moves toward either extreme, the box becomes more opaque. The box answers one question only: how strong is the current reading, regardless of which way it points.

The EV score itself - shown as a number, a ten-segment meter, and a zone label in the dashboard - uses a four-zone color system based purely on score value, with no reference to trade direction:

  90 to 100 : amber - the score is approaching the high exit threshold
  60 to 90  : green (bull color) - the trade is developing favorably
  40 to 60  : gold - neutral territory, no strong reading in either direction
  10 to 40  : red (bear color) - the trade is developing poorly
  0 to 10   : amber - the score is approaching the low exit threshold

This color system is direction-independent. A short trade with EV 85 shows green because the short is working well. A long trade with EV 14 shows red because the long is working against you. The amber zones at both extremes serve as a visual warning that an automatic exit is approaching, regardless of whether the trade is succeeding or failing. When no trade is active, the EV display is grey.

The text inside entry labels and EV shift labels is rendered in the measurement/brand color, against a background in the bull or bear color matching the trade direction. This keeps the label readable against either background while keeping the directional color as the dominant visual cue.

Important notice
EV Edge generates signals based on price action, volume behavior, and momentum confirmation.
These signals are not financial advice.
They do not predict future price movement.
They do not guarantee profitability.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
EV Edge is a consolidation breakout indicator with a self-updating expected value score that tracks every trade from entry to close. It combines breakout detection, dynamic trade evaluation, optional momentum confirmation, multi-timeframe trend context, and a trade outcome log in a single lightweight indicator.

What it includes:
- Consolidation detection using ATR-based range compression
- Breakout signal with optional right-side-of-V continuation filter
- EV score from 0 to 100 that evolves bar by bar based on price drift and retracement depth
- Optional volume component blended into the EV score
- Four-zone color system on the EV score display: amber at the extremes, green in the favorable zone, gold at neutral, red in the unfavorable zone
- Automatic early exit when EV reaches a configurable extreme, with a hard bar-count cap as fallback
- Trade zone box that grows with the active trade and increases in opacity as EV moves away from neutral
- Extreme EV shift labels that appear only on significant single-bar changes or zone crossovers
- Optional VW RSI and MFI confirmation filter for entries, with an independent mini panel showing live values regardless of filter state
- Configurable divergence sensitivity for VW RSI divergence detection (High / Medium / Low)
- Multi-timeframe trend bar across six timeframes with a bull count
- Four independently toggleable EMA lines for visual confluence, with no effect on signals
- Trade log table recording direction, entry EV, exit EV, exit reason, and duration for recent trades
- Fully configurable bull, bear, and measurement colors applied consistently across labels, dashboards, and the trend bar

2. Core calculation
2.1 Consolidation detection

A consolidation range is measured over a configurable lookback period using the highest high and lowest low in that window. This range is compared against an ATR-based average range. When the actual range falls below the average range multiplied by a compression factor, the range is considered compressed. A consolidation is only confirmed once a minimum number of consecutive compressed bars has occurred - this is the V forming.

Lower compression factors demand tighter ranges before a consolidation is recognized. Higher minimum bar counts demand more mature consolidations. Both settings directly affect how often signals occur.

2.2 Breakout signal and the right side of the V
A breakout fires when price closes beyond the consolidation high or low by a configurable buffer, expressed as a multiple of ATR. With the right-side-of-V filter enabled, the breakout must also continue in the same direction as the move that occurred before the consolidation began. A consolidation that formed after an upward move and then breaks upward is a continuation. A consolidation that formed after an upward move and then breaks downward is not, and is ignored with this filter on.

Only one trade is tracked at a time. While a trade is active, new breakout signals are not evaluated. This keeps the chart from filling with overlapping signals and trade zone boxes during volatile, choppy conditions.

2.3 The EV score
Every new signal starts with an EV score of 60. From that point, the score updates on every bar based on two components.

The price component measures drift - how far price has moved in the trade's favor since entry, normalized by ATR - and retracement - whether price has moved back into or past the consolidation zone it broke from. Favorable drift increases the score. A retracement decreases it, and the size of the decrease scales with how deep the retracement goes. A shallow retracement back to the edge of the consolidation costs less than a retracement that pushes well past the original zone.

The optional volume component compares current volume to its moving average. Volume expanding in the direction of the trade supports the price component. Volume that is elevated while price is not moving - an effort without result condition - works against the score even if price has not yet retraced.

Both components are combined using configurable weights, and the result is applied to the running score each bar, clamped between 0 and 100.

2.4 Exits
A trade closes in one of two ways. If the EV score reaches a configurable extreme - high or low - after a minimum number of bars have passed, the trade closes immediately and the result is logged as an EV High or EV Low exit. The minimum bar requirement prevents the first bar or two after entry from closing the trade before it has had a chance to develop.

If neither extreme is reached within a maximum bar count, the trade closes as a Timeout. Either way, the indicator becomes ready to evaluate the next consolidation and breakout immediately.

3. Optional VW RSI and MFI confirmation
EV Edge includes an inline volume weighted RSI and Money Flow Index, calculated independently of any other indicator. The volume weighted RSI multiplies each bar's price change by its relative volume before the RSI calculation, so high-volume bars carry more weight than low-volume bars. The MFI is calculated from typical price multiplied by volume.

The master toggle enables or disables the confirmation filter entirely. When the master is on, the sub-toggles beneath it determine which meters are used: VW RSI, MFI, or both together with AND logic. When the master is off, signals fire without any momentum requirement regardless of the sub-toggle states.

When the confirmation filter is enabled, a long signal requires the selected meter or meters to be above their respective midlines, and a short signal requires them to be below. The filter is disabled by default so that signal frequency with and without confirmation can be compared directly.

VW RSI and MFI will sometimes point in different directions. This is not a fault - they measure related but distinct things. VW RSI weights price change by relative volume and responds quickly to momentum shifts. MFI incorporates the full money flow through typical price and volume and tends to reflect sustained buying or selling pressure. When they agree, the confirmation is stronger. When they disagree, the dashboard shows exactly where each stands so the trader can weigh them independently.

An optional mini panel on the dashboard shows the current VW RSI and MFI values with their percentage meters, zone state, and a Confirms row showing which direction - or directions - they currently support, regardless of whether the filter itself is active. This makes it possible to observe what the filter would do before committing to it.

Divergence detection is built into the VW RSI engine. When a bullish divergence is detected - price making a lower low while VW RSI makes a higher low - a line is drawn on the chart connecting the two pivot points in the bull color. The same applies in reverse for bearish divergences. The pivot window used for detection is configurable through the Divergence Sensitivity setting: High uses a 3-bar window for more frequent signals, Medium uses 5 bars as the default, and Low uses 10 bars for major pivots only. Divergence lines are purely visual and have no effect on signals or the EV score.

An important distinction: the Confirms row and the EV score answer different questions. Confirms reflects what VW RSI and MFI are doing right now - whether the current momentum supports the trade direction. The EV score reflects what price actually did after the signal fired - whether the breakout followed through. These two readings can point in opposite directions and both be correct. A short trade can show Confirms: Short because momentum is currently bearish, while the EV score sits at 15 because price bounced sharply after entry and never moved in the intended direction. The Confirms row describes the current environment. The EV score describes the trade's history since entry.

4. Multi-timeframe trend bar
A separate small panel shows trend direction across six timeframes - 1 minute, 5 minutes, 15 minutes, 1 hour, 4 hours, and daily - based on whether the 9-period EMA is above or below the 21-period EMA on each timeframe. A bull count from 0 to 6 summarizes how many of those timeframes currently agree on an upward trend.

This panel is independent of the signal logic. It provides context for whether a breakout on the current chart is aligned with or against the broader trend structure, without enforcing that alignment as a requirement.

5. EMA visual confluence
Four EMAs - 9, 21, 50, and 200 - can each be toggled on independently, with their own color and line width settings. These are plotted purely for visual reference. They do not feed into the consolidation detection, the EV score, the confirmation filter, or any other calculation. They exist so that price action can be viewed against common moving average levels without affecting how the indicator behaves.

6. Trade log
When enabled, a table records the most recently closed trades - direction, entry EV score, exit EV score, exit reason, and number of bars held. The table holds a configurable number of recent trades, with the newest entry at the top and older entries pushed out once the limit is reached.

Because entry EV is fixed at 60 for every trade, the exit EV and exit reason are what differentiate one trade from another in the log. A trade that exits at EV High after a small number of bars represents a fast, clean continuation. A trade that exits at EV Low after a small number of bars represents a fast failure. A trade that times out without reaching either extreme represents a setup that drifted without committing strongly in either direction.

The trade log does not persist across chart reloads. It reflects the trades that occurred since the indicator was applied to the current chart session.

7. Dashboard
The main dashboard shows the current trade status - long active, short active, or no signal - the live EV score as both a number and a ten-segment meter, the current EV zone, and the number of bars tracked relative to the maximum. The EV score number, meter, and zone text all use the four-zone color system described in the colors section above. When the VW RSI and MFI mini panel is enabled, it appears as additional rows in the same table.

A small blinking indicator - alternating between a filled and hollow dot - appears next to the Status row whenever a trade is active, and disappears when no trade is active. The indicator updates on a bar-by-bar basis, including the live, currently forming bar, so on lower timeframes it provides a continuously refreshing visual cue that the EV engine is actively tracking a trade.

Dashboard position and text size are independently configurable, with tiny, small, and normal size options to suit different chart layouts.

8. Settings reference
8.1 Consolidation detection
- Consolidation lookback: bars used to measure the consolidation range. Default 12.
- Compression factor: how tight the range must be relative to the ATR-based average to qualify as consolidation. Default 0.65.
- ATR length: lookback for the Average True Range used throughout the indicator. Default 14.
- Min bars in consolidation: minimum consecutive compressed bars required. Default 4.

8.2 Breakout signal
- Breakout buffer: extra distance beyond the consolidation edge, as a multiple of ATR, required to confirm a breakout. Default 0.1.
- Require right-side-of-V alignment: breakout must continue in the direction of the pre-consolidation move. Default on.
- Impulse lookback: bars before the consolidation compared to determine the prior move direction. Default 8.

8.3 EV score engine
- Include volume component: blend volume behavior into the EV score. Default on.
- Price action weight and volume weight: relative weighting of the two components. Defaults 0.7 / 0.3.
- Volume MA length: lookback for the volume moving average used in the volume ratio. Default 20.
- EV improving threshold: score at or above this value is classified as Improving. Default 70.
- EV decaying threshold: score at or below this value is classified as Decaying. Default 30.
- Max bars to track: hard cap on how long a trade is tracked before timing out. Default 30.
- Early exit EV high: score at or above this value triggers an immediate EV High close. Default 90.
- Early exit EV low: score at or below this value triggers an immediate EV Low close. Default 5.
- Min bars before early exit: bars that must pass before an extreme score can close the trade. Default 3.

8.4 VW RSI / MFI confirmation filter
- Require confirmation for entries: master toggle for the entire filter. Default off.
- VW RSI length and volume smoothing: lookback periods for the volume weighted RSI calculation. Default 14 each.
- VW RSI confirmation midline: threshold for long versus short confirmation. Default 50.
- Use VW RSI for confirmation: sub-toggle. Default on.
- MFI length: lookback for the Money Flow Index. Default 14.
- MFI confirmation midline: threshold for long versus short confirmation. Default 50.
- Use MFI for confirmation: sub-toggle. Default on.
- Show VW RSI / MFI mini panel: adds informational rows to the dashboard regardless of filter state. Default on.
- VW RSI overbought / oversold levels: visual zone thresholds shown in the dashboard. Defaults 75 / 25.
- Show divergence lines: draws diagonal lines on the chart where VW RSI divergences are detected. Default on.
- Show bullish / bearish divergence: independent toggles per divergence direction. Default on.
- Divergence line width: stroke width for divergence lines. Default 1.
- Divergence sensitivity: pivot window for divergence detection. High = 3 bars, Medium = 5 bars (default), Low = 10 bars.

8.5 Multi-timeframe dashboard
- Show multi-timeframe trend bar: toggle. Default on.
- MTF panel location: corner placement on the chart. Default bottom left.

8.6 EMA visual confluence
- Show EMA 9, 21, 50, 200: independent toggles, all default on.
- Color and width: configurable per EMA.

8.7 Bull / bear colors
- Bull color and bear color: applied to entry label backgrounds, plotted signal markers, dashboard status, VW RSI/MFI confirmations, and the multi-timeframe trend bar.
- Measurement / brand color: applied to the EV score meter when no trade is active, the brand row in both dashboards, and the text inside entry and EV shift labels.
- Signal label transparency: background transparency for entry and EV shift labels. Default 50.

8.8 EV quality colors
- Trade zone box color: single monochrome color for the trade zone box. Default steel grey.
- Scale box intensity with EV extremity: when on, the box becomes more opaque as EV approaches 0 or 100, and more transparent near 50. Default on.
- EV improving / decaying / neutral text colors: used for the Exit EV value in the trade log. Separate from the four-zone dashboard colors.

8.9 Trade log
- Show trade log table: toggle. Default on.
- Number of trades to show: how many recent trades are displayed. Default 5.
- Trade log location: corner placement on the chart.

8.10 Visuals
- Show dashboard, dashboard location, and dashboard size.
- Show consolidation box.
- Show signal labels.
- Show trade zone box.
- Extreme EV shift threshold: minimum single-bar EV change, or a zone crossover, required to display a shift label. Default 15.

9. How to use
9.1 Reading the EV score
The EV score has one rule: higher is better, lower is worse - for both long and short trades. When a long signal fires and the score climbs, the long is working. When a short signal fires and the score drops, the short is not working - price is moving up against the position. The score is direction-independent. It measures how well the trade is developing relative to what was expected at the moment of the breakout, nothing more.

The score is most informative as a trajectory, not a single value. A score climbing steadily from 60 toward 70 and beyond suggests a clean continuation. A score that drops sharply within the first few bars after entry, particularly if it crosses below the decaying threshold, suggests the breakout lacked follow-through. The minimum bars before early exit setting exists so that this initial period can be observed rather than immediately closing the trade on the first adverse tick.

9.2 Reading the four-zone color system
The EV score number, the ten-segment meter, and the EV Zone text all use the same four-zone color logic. When a trade is active, the colors read as follows: green means the trade is progressing well, gold means the score is sitting in neutral territory without a strong signal in either direction, red means the trade is going poorly and the breakout likely lacked follow-through, and amber at either extreme means an automatic exit is approaching. No active trade is grey.

These colors are consistent across both long and short trades. A short showing green is performing correctly. A long showing red is not.

9.3 Reading the trade zone box
The trade zone box appears once a signal fires and grows with the trade's price range on every subsequent bar. Its intensity reflects how far the EV score currently sits from the neutral midpoint - faint near 50, increasingly opaque as the score approaches either 0 or 100. A box that has become noticeably more opaque indicates the EV score has moved decisively toward one of its extremes. The EV Zone text in the dashboard and the four-zone color together tell you which extreme and whether that is favorable or not.

9.4 Using the trade log to evaluate settings
Because every closed trade is recorded with its exit reason and duration, the trade log can be used to assess whether the current settings are producing the expected distribution of outcomes. A log dominated by EV Low exits at short durations may indicate that the breakout filter is too permissive, allowing weak setups through. A log with many Timeout entries may indicate that the early exit thresholds are too extreme to be reached under current market conditions, or that the EV score's sensitivity needs adjustment. Reviewing the log periodically - particularly when testing on a single instrument and timeframe over a consistent period - is the intended way to calibrate the EV score engine to a specific market.

9.5 Using the VW RSI / MFI mini panel before enabling the filter
Because the mini panel shows what the confirmation filter would do without requiring it to be active, it can be left on while running the indicator without the filter enabled. This allows direct observation of how often VW RSI and MFI would have confirmed or rejected the signals that fired, before committing to the filter and reducing signal frequency.

9.6 Using the multi-timeframe bar as context, not as a gate
The multi-timeframe trend bar does not block or filter signals. A breakout signal can fire even when the bull count is low or when the immediate timeframe disagrees with higher timeframes. The intended use is to provide situational awareness - a breakout that aligns with a high bull count carries different context than one that fires while higher timeframes are pointing the other way, even though both will generate the same signal and the same starting EV score.

9.7 Illustrative bull scenario
Educational example only. Not a trading recommendation.
Price consolidates in a tight range for several bars after an upward move. The range compresses below the ATR-based threshold and the minimum bar count is reached. Price closes above the consolidation high by more than the breakout buffer, and the move continues in the same direction as the prior upward impulse - the right side of the V. A long signal fires with an EV score of 60, shown with a bull-colored label. The dashboard switches to LONG ACTIVE with a blinking dot. Over the following bars, price continues higher without returning to the consolidation zone. The EV score climbs past 70, the dashboard color shifts to green, and the trade zone box becomes noticeably more opaque as the score moves away from neutral. The EV Zone text switches to Improving. Within several bars the score reaches 90, the amber warning zone, and the trade closes as an EV High exit, recorded in the trade log.

9.8 Illustrative bear scenario
Educational example only. Not a trading recommendation.
A consolidation forms after a downward move and breaks lower, aligned with the prior impulse. A short signal fires with an EV score of 60, shown with a bear-colored label. On the next bar, price reverses and closes back above the lower boundary of the consolidation it broke from. The retracement penalty is applied, scaled by how far price has moved back into the zone. The EV score drops sharply. The dashboard color shifts to red and the EV Zone text switches to Decaying. The Confirms row in the VW RSI panel may still show Short if momentum meters remain bearish - this is not a contradiction. Confirms reflects current momentum; the EV score reflects what price did since entry. After the minimum bar count has passed, the score drops below 10, entering the lower amber zone, and the trade closes as an EV Low exit, recorded in the trade log as a fast failure.

10. Tested instruments and timeframes
EV Edge has been tested across a range of futures and spot crypto markets, including MNQ, MES, MGC, MCL, MBT, M2K, and SIL futures, as well as BTCUSDT, SOLUSDT, and ETHUSDT on Binance, across the 1 minute, 5 minute, 15 minute, 1 hour, and 4 hour timeframes.

Results by timeframe:
- 1m and 5m: recommended primary timeframes. EV High and EV Low exits fire frequently and the score evolves quickly enough to be actionable for scalping.
- 15m: works well. Max bars setting of 15 to 20 recommended.
- 1H: functional, but overnight and weekend gaps on futures affect the score behavior. Max bars of 10 to 15 recommended. Best used for directional context rather than as the primary trading timeframe.
- 4H: not recommended. The bar count required for meaningful EV evolution exceeds practical limits and most trades time out before the score develops.

EV Edge is designed primarily as a 1m to 15m scalp and intraday tool, with 1H usable for higher-timeframe bias.

11. Tips
The default EV score formula has not been calibrated to any specific instrument or timeframe. The early exit thresholds, the retracement penalty, and the volume weighting are starting points. The trade log exists so that these can be evaluated against real outcomes on the instrument and timeframe actually being traded, rather than assumed to be correct.

Testing on a single instrument and a single timeframe for a sustained period produces a more useful trade log than switching between instruments or timeframes during the test. Mixing conditions makes it difficult to separate the effect of the EV score formula from the effect of changing market behavior.

The right-side-of-V filter and the VW RSI/MFI confirmation filter both attempt to address the same underlying concern - whether a breakout has genuine momentum behind it. Running both at maximum strictness simultaneously may reduce signal frequency more than either filter alone would suggest. Testing each independently before combining them clarifies which filter is contributing more to signal quality.

On futures markets, overnight and weekend gaps can cause single-bar EV score jumps that do not reflect genuine price movement during the session. On the 1H timeframe in particular, a gap open can spike or collapse the drift component in ways that would not occur on a continuous chart. This is expected behavior, not a fault. Keeping the max bars setting lower on higher timeframes reduces the window during which a gap can distort the score history.

The Confirms row and the EV score are not the same measure and should not be read as one. Confirms reflects whether VW RSI and MFI currently support the trade direction. The EV score reflects how price actually moved since the signal fired. They can disagree and both be correct. A trade showing Confirms: Short alongside EV 12 is not contradictory: it means momentum currently supports the short direction, but the price movement since entry has not followed through. Understanding the difference between these two readings is one of the most useful things you can take from the dashboard.

12. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document or in the indicator output constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
//@version=6
indicator("EV Edge | Anonycryptous", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// EV EDGE - Working Title
// Core: Right-Side-of-V consolidation breakout signal + dynamic EV score
// that evolves bar-by-bar after entry based on price action (and optional volume)
// Asset-agnostic: NQ, BTC, Gold, Oil, etc.
// ============================================================================

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
grpConsol = "Consolidation Detection"
consolLookback = input.int(12, "Consolidation Lookback (bars)", minval=5, maxval=50, group=grpConsol, tooltip="Number of recent bars used to measure the consolidation range (high/low). Higher = looks for larger, slower consolidations. Lower = reacts to tighter, more recent ranges.")
compressionFactor = input.float(0.65, "Compression Factor (range vs avg range)", minval=0.2, maxval=1.0, step=0.05, group=grpConsol, tooltip="A bar's range must be below (ATR-based average range * this factor) to count as 'compressed'. Lower = stricter, only very tight ranges qualify as consolidation. Higher = looser, more ranges qualify.")
atrLen = input.int(14, "ATR Length", minval=5, maxval=50, group=grpConsol, tooltip="Lookback period for the Average True Range, used throughout the script to normalize price moves, set buffers, and size boxes/labels. Standard default is 14.")
minConsolBars = input.int(4, "Min Bars in Consolidation", minval=2, maxval=20, group=grpConsol, tooltip="Minimum number of consecutive compressed bars required before a range is considered a valid consolidation ('the V'). Higher = fewer but more mature consolidations.")

grpBreak = "Breakout Signal"
breakoutBufferATR = input.float(0.1, "Breakout Buffer (x ATR)", minval=0.0, maxval=1.0, step=0.05, group=grpBreak, tooltip="Extra distance beyond the consolidation high/low (as a multiple of ATR) that price must close beyond to confirm a breakout. Higher = fewer, more decisive breakouts. 0 = breakout triggers right at the consolidation edge.")
requireImpulseAlign = input.bool(true, "Require breakout aligns with pre-consolidation impulse direction (Right Side of V)", group=grpBreak, tooltip="When ON, a breakout only counts if it continues in the same direction as the move that led into the consolidation ('Right Side of V' continuation pattern). When OFF, breakouts in either direction are allowed regardless of prior momentum.")
impulseLookback = input.int(8, "Impulse Lookback (bars before consolidation)", minval=3, maxval=30, group=grpBreak, tooltip="How many bars before the consolidation started are compared to determine the prior impulse direction. Only used when 'Require breakout aligns with impulse' is ON.")

grpEV = "EV Score Engine"
useVolumeComponent = input.bool(true, "Include Volume Component in EV Score", group=grpEV, tooltip="When ON, the EV score blends a price-action component with a volume component (see weights below). When OFF, EV evolves purely from price drift and retracement depth.")
priceWeight = input.float(0.7, "Price Action Weight", minval=0.0, maxval=1.0, step=0.05, group=grpEV, tooltip="Relative weight given to price-based EV changes (drift in trade direction, retracement depth). Combined with Volume Weight to form a blended weighted average.")
volumeWeight = input.float(0.3, "Volume Weight (used if enabled)", minval=0.0, maxval=1.0, step=0.05, group=grpEV, tooltip="Relative weight given to volume-based EV changes (volume expansion in trade direction, 'effort vs result' penalty). Only used when 'Include Volume Component' is ON.")
evLookbackVol = input.int(20, "Volume MA Length", minval=5, maxval=50, group=grpEV, tooltip="Lookback for the volume moving average used to compute the volume ratio (current volume vs average). Higher = smoother, less reactive volume baseline.")
evImproveZone = input.int(70, "EV Improving Threshold (>=)", minval=50, maxval=100, group=grpEV, tooltip="EV score at or above this value is classified as 'Improving' (green). Used for the trade zone box color, shift labels, and dashboard zone display.")
evDecayZone = input.int(30, "EV Decaying Threshold (<=)", minval=0, maxval=50, group=grpEV, tooltip="EV score at or below this value is classified as 'Decaying' (red). Used for the trade zone box color, shift labels, and dashboard zone display.")
maxEvTrackBars = input.int(30, "Max Bars to Track After Signal (hard cap)", minval=5, maxval=100, group=grpEV, tooltip="Absolute maximum number of bars a trade is tracked after entry, even if EV never reaches an extreme value. After this many bars the trade closes out and the script becomes ready for a new signal.")
evExitHigh = input.int(90, "Early Exit: EV reaches this (extreme high)", minval=70, maxval=100, group=grpEV, tooltip="If EV climbs to this level or above (after the minimum bars below), the trade is considered to have played out favorably and closes early, freeing up the script for a new signal.")
evExitLow = input.int(5, "Early Exit: EV reaches this (extreme low)", minval=0, maxval=30, group=grpEV, tooltip="If EV drops to this level or below (after the minimum bars below), the trade is considered to have failed and closes early, freeing up the script for a new signal.")
minBarsBeforeExit = input.int(3, "Min Bars Before Early Exit Allowed", minval=1, maxval=10, group=grpEV, tooltip="Prevents the very first bar(s) after entry from immediately closing the trade via the early-exit thresholds. Gives the trade a minimum number of bars to develop before extreme-EV exits can fire.")

grpVwRsi = "VW RSI / MFI Confirmation Filter"
useVwRsiFilter = input.bool(false, "Require VW RSI / MFI Confirmation for Entries", group=grpVwRsi, tooltip="When ON, a breakout signal only fires if the VW RSI and/or MFI confirm the direction (see options below). This filters out breakouts that lack momentum/volume backing, at the cost of fewer signals. Default OFF so you can compare with/without.")
rsiLen = input.int(14, "VW RSI Length", minval=1, maxval=50, group=grpVwRsi, tooltip="Number of bars used to calculate the Volume Weighted RSI. Same architecture as VW RSI Pro: price changes are weighted by relative volume (volume vs its moving average) before the RSI calculation, so high-volume bars have more influence.")
rsiVolLen = input.int(14, "VW RSI Volume Smoothing", minval=1, maxval=50, group=grpVwRsi, tooltip="Lookback for the volume moving average used to compute the volume ratio that weights each bar's price change in the VW RSI calculation.")
rsiMidline = input.float(50.0, "VW RSI Confirmation Midline", minval=30.0, maxval=70.0, step=1.0, group=grpVwRsi, tooltip="Longs require VW RSI above this level, shorts require VW RSI below this level, when VW RSI confirmation is enabled below.")
useRsiConfirm = input.bool(true, "Use VW RSI for Confirmation", group=grpVwRsi, tooltip="When ON (and the master filter above is ON), VW RSI must be on the correct side of the midline for the signal direction (above midline for longs, below for shorts).")
mfiLen = input.int(14, "MFI Length", minval=1, maxval=50, group=grpVwRsi, tooltip="Lookback period for the Money Flow Index, calculated from typical price (HLC/3) multiplied by volume. A second, independent momentum/volume confirmation alongside VW RSI.")
mfiMidline = input.float(50.0, "MFI Confirmation Midline", minval=30.0, maxval=70.0, step=1.0, group=grpVwRsi, tooltip="Longs require MFI above this level, shorts require MFI below this level, when MFI confirmation is enabled below.")
useMfiConfirm = input.bool(true, "Use MFI for Confirmation", group=grpVwRsi, tooltip="When ON (and the master filter above is ON), MFI must also be on the correct side of its midline for the signal direction. Can be combined with VW RSI confirmation for a stricter (AND logic) filter.")
showVwRsiPanel = input.bool(true, "Show VW RSI / MFI Mini Panel on Dashboard", group=grpVwRsi, tooltip="Adds extra rows to the dashboard showing the current VW RSI and MFI values and whether they currently confirm long/short, regardless of whether the filter itself is active.")
vwRsiOB = input.int(75, "VW RSI Overbought Level", minval=60, maxval=95, group=grpVwRsi, tooltip="When VW RSI is at or above this level, the dashboard zone text shows 'Overbought' in the bear color. Purely visual — does not affect signals or EV score. Default 75.")
vwRsiOS = input.int(25, "VW RSI Oversold Level", minval=5, maxval=40, group=grpVwRsi, tooltip="When VW RSI is at or below this level, the dashboard zone text shows 'Oversold' in the bull color. Purely visual — does not affect signals or EV score. Default 25.")
showDivergence = input.bool(true, "Show Divergence Lines on Chart", group=grpVwRsi, tooltip="Draws diagonal lines on the chart connecting the two pivot points where a VW RSI divergence is detected. Bull divergence: price lower low, VW RSI higher low. Bear divergence: price higher high, VW RSI lower high. No box, no signal impact — purely visual confluence.")
showBullDiv = input.bool(true, "Show Bullish Divergence", group=grpVwRsi, tooltip="Show bull divergence lines (price lower low, VW RSI higher low) in the bull color.")
showBearDiv = input.bool(true, "Show Bearish Divergence", group=grpVwRsi, tooltip="Show bear divergence lines (price higher high, VW RSI lower high) in the bear color.")
divLineWidth = input.int(1, "Divergence Line Width", minval=1, maxval=4, group=grpVwRsi, tooltip="Stroke width of the divergence lines on the chart.")
divSensitivity = input.string("Medium", "Divergence Sensitivity", options=["High", "Medium", "Low"], group=grpVwRsi, tooltip="Controls how many bars are used as the pivot window for divergence detection. High = 3 bars (more signals, shorter pivots). Medium = 5 bars (default, balanced). Low = 10 bars (fewer signals, only major pivots).")

grpEma = "EMA Visual Confluence (no signal impact)"
showEma9 = input.bool(true, "Show EMA 9", group=grpEma, tooltip="Plot a 9-period EMA on the chart. Purely visual reference, does not affect signals, EV score, or filters in any way.")
ema9Color = input.color(#ffbc03, "EMA 9 Color", group=grpEma, tooltip="Line color for the EMA 9 plot.")
ema9Width = input.int(1, "EMA 9 Width", minval=1, maxval=4, group=grpEma, tooltip="Line thickness for the EMA 9 plot.")
showEma21 = input.bool(true, "Show EMA 21", group=grpEma, tooltip="Plot a 21-period EMA on the chart. Purely visual reference, does not affect signals, EV score, or filters in any way.")
ema21Color = input.color(#0478fc, "EMA 21 Color", group=grpEma, tooltip="Line color for the EMA 21 plot.")
ema21Width = input.int(1, "EMA 21 Width", minval=1, maxval=4, group=grpEma, tooltip="Line thickness for the EMA 21 plot.")
showEma50 = input.bool(true, "Show EMA 50", group=grpEma, tooltip="Plot a 50-period EMA on the chart. Purely visual reference, does not affect signals, EV score, or filters in any way.")
ema50Color = input.color(#04f925, "EMA 50 Color", group=grpEma, tooltip="Line color for the EMA 50 plot.")
ema50Width = input.int(1, "EMA 50 Width", minval=1, maxval=4, group=grpEma, tooltip="Line thickness for the EMA 50 plot.")
showEma200 = input.bool(true, "Show EMA 200", group=grpEma, tooltip="Plot a 200-period EMA on the chart. Purely visual reference, does not affect signals, EV score, or filters in any way.")
ema200Color = input.color(#ff0000, "EMA 200 Color", group=grpEma, tooltip="Line color for the EMA 200 plot.")
ema200Width = input.int(2, "EMA 200 Width", minval=1, maxval=4, group=grpEma, tooltip="Line thickness for the EMA 200 plot.")

grpColors = "Bull / Bear Colors"
fluorBullColor = input.color(#00ff00, "Bull Color", group=grpColors, tooltip="Used for all bullish/long elements: entry labels, dashboard status, VW RSI/MFI confirmations, and MTF trend arrows. Does not affect the trade zone box or EV zone display, which use the separate EV Quality colors below.")
fluorBearColor = input.color(#ff0000, "Bear Color", group=grpColors, tooltip="Used for all bearish/short elements: entry labels, dashboard status, VW RSI/MFI confirmations, and MTF trend arrows. Does not affect the trade zone box or EV zone display, which use the separate EV Quality colors below.")
goldColor = input.color(#f5c518, "Measurement / Brand Color", group=grpColors, tooltip="Used for the percentage meter bars and the brand row in the dashboard.")
labelTransparency = input.int(50, "Signal Label Transparency", minval=0, maxval=90, step=5, group=grpColors, tooltip="Background transparency for entry signal labels and extreme EV shift labels (0 = solid, 90 = nearly invisible). Does not affect the small triangle markers plotted on the chart.")

grpEvQuality = "EV Quality Colors"
evBoxColor = input.color(#30363d, "Trade Zone Box Color", group=grpEvQuality, tooltip="Single monochrome color for the trade zone box on the chart. Only its intensity (transparency) changes with the EV score; the color itself stays the same regardless of whether EV is improving or decaying.")
evBoxIntensityScale = input.bool(true, "Scale Box Intensity with EV Extremity", group=grpEvQuality, tooltip="When ON, the trade zone box fill becomes more opaque as EV moves closer to 0 or 100, and more transparent near the neutral midpoint. When OFF, the box uses a fixed transparency regardless of EV level.")
evImproveColor = input.color(#00ff00, "EV Improving Text Color", group=grpEvQuality, tooltip="Used for the EV Zone text in the dashboard and the Exit EV value in the trade log when EV is at or above the improving threshold. Deliberately separate from the bull/bear colors: this represents trade quality, not trade direction.")
evDecayColor = input.color(#ff0000, "EV Decaying Text Color", group=grpEvQuality, tooltip="Used for the EV Zone text in the dashboard and the Exit EV value in the trade log when EV is at or below the decaying threshold. Deliberately separate from the bull/bear colors: this represents trade quality, not trade direction.")
evNeutralColor = input.color(#8b949e, "EV Neutral Text Color", group=grpEvQuality, tooltip="Used for the EV Zone text in the dashboard and the Exit EV value in the trade log when EV is between the decaying and improving thresholds.")

grpVisual = "Visuals"
showDashboard = input.bool(true, "Show Dashboard", group=grpVisual, tooltip="Show the EV Edge status panel on the chart.")
dashLocation = input.string("Bottom Right", "Dashboard Location", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=grpVisual, tooltip="Corner of the chart where the dashboard panel is placed.")
dashSize = input.string("Tiny", "Dashboard Size", options=["Tiny", "Small", "Normal"], group=grpVisual, tooltip="Text size for the dashboard panel. Tiny is the most compact and recommended for smaller chart panes; Normal is easiest to read on large monitors.")

showConsolBox = input.bool(true, "Show Consolidation Box", group=grpVisual, tooltip="Draw a box around detected consolidation ranges ('the V') before a breakout occurs.")
showSignalLabels = input.bool(true, "Show Signal Labels", group=grpVisual, tooltip="Show a triangle label with the starting EV score at the bar where a long or short breakout signal fires.")
showTradeZoneBox = input.bool(true, "Show Trade Zone Box (colors with EV)", group=grpVisual, tooltip="Draw a box that grows with the active trade's price range and changes color (green/yellow/red) to reflect the current EV zone (Improving/Neutral/Decaying).")
extremeShiftThreshold = input.float(15.0, "Extreme EV Shift Threshold (points/bar)", minval=5.0, maxval=50.0, step=1.0, group=grpVisual, tooltip="Show a small label only when EV score changes by at least this many points in a single bar, or when EV crosses between Improving/Neutral/Decaying zones. Keeps the chart clean by suppressing minor fluctuations.")


grpMtf = "Multi-Timeframe Dashboard"
useMtf = input.bool(true, "Show Multi-Timeframe Trend Bar", group=grpMtf, tooltip="Shows a separate small panel with EMA9/EMA21 trend direction across 6 timeframes (1m, 5m, 15m, 1H, 4H, Daily), plus a bull-count. Helps you check whether higher timeframes agree with your current chart's direction before taking a signal.")
mtfPos = input.string("Bottom Left", "MTF Panel Location", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpMtf, tooltip="Corner of the chart where the multi-timeframe trend panel is placed.")

grpLog = "Trade Log"
showTradeLog = input.bool(true, "Show Trade Log Table", group=grpLog, tooltip="Shows a table with the most recent closed trades: direction, entry EV, exit EV, exit reason, and bars held. Useful for reviewing how the EV score behaved across multiple trades. Take a screenshot to share/analyze the history, since the table only keeps the most recent entries.")
tradeLogCount = input.int(5, "Number of Trades to Show", minval=5, maxval=20, group=grpLog, tooltip="How many of the most recently closed trades to display in the trade log table (most recent first).")
tradeLogPos = input.string("Top Right", "Trade Log Location", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpLog, tooltip="Corner of the chart where the trade log table is placed.")

// ---------------------------------------------------------------------------
// CORE CALCULATIONS
// ---------------------------------------------------------------------------
atrVal = ta.atr(atrLen)

// ---------------------------------------------------------------------------
// EMA VISUAL CONFLUENCE (no signal impact, purely for visual reference)
// ---------------------------------------------------------------------------
ema9Val = ta.ema(close, 9)
ema21Val = ta.ema(close, 21)
ema50Val = ta.ema(close, 50)
ema200Val = ta.ema(close, 200)

// Consolidation range over lookback
consolHigh = ta.highest(high, consolLookback)
consolLow = ta.lowest(low, consolLookback)
consolRange = consolHigh - consolLow

// Average range for comparison (use ATR-based proxy)
avgRange = atrVal * consolLookback

// Compression check: is the consolidation range tight relative to "normal" range expansion
isCompressed = consolRange < (avgRange * compressionFactor)

// Count bars where price stayed within a tight band (for minConsolBars check)
var int tightBarCount = 0
withinBand = high <= consolHigh and low >= consolLow
tightBarCount := withinBand and isCompressed ? tightBarCount + 1 : 0

inConsolidation = isCompressed and tightBarCount >= minConsolBars

// Pre-consolidation impulse direction (Right Side of V context)
impulseStart = low[consolLookback + impulseLookback]
impulseEnd = close[consolLookback]
impulseUp = impulseEnd > impulseStart
impulseDown = impulseEnd < impulseStart

// ---------------------------------------------------------------------------
// VW RSI / MFI CONFIRMATION FILTER
// ---------------------------------------------------------------------------
// Volume Weighted RSI (same architecture as VW RSI Pro)
rsiPriceChange = ta.change(close)
rsiVolSma = ta.sma(volume, rsiVolLen)
rsiVolRatio = rsiVolSma > 0 ? volume / rsiVolSma : 1.0

rsiWtGain = math.max(rsiPriceChange, 0) * rsiVolRatio
rsiWtLoss = math.max(-rsiPriceChange, 0) * rsiVolRatio

rsiAvgGain = ta.rma(rsiWtGain, rsiLen)
rsiAvgLoss = ta.rma(rsiWtLoss, rsiLen)
rsiRs = rsiAvgLoss == 0 ? 100.0 : rsiAvgGain / rsiAvgLoss
vwRsiValue = 100.0 - 100.0 / (1.0 + rsiRs)

// Money Flow Index
mfiTypPrice = (high + low + close) / 3.0
mfiRawMF = mfiTypPrice * volume
mfiPosMF = mfiTypPrice > mfiTypPrice[1] ? mfiRawMF : 0.0
mfiNegMF = mfiTypPrice < mfiTypPrice[1] ? mfiRawMF : 0.0
mfiRatio = ta.sma(mfiPosMF, mfiLen) / math.max(ta.sma(mfiNegMF, mfiLen), 1.0)
mfiValue = 100.0 - 100.0 / (1.0 + mfiRatio)

// Confirmation conditions per direction
rsiConfirmLong = vwRsiValue > rsiMidline
rsiConfirmShort = vwRsiValue < rsiMidline
mfiConfirmLong = mfiValue > mfiMidline
mfiConfirmShort = mfiValue < mfiMidline

// OB/OS zone state (purely visual, no signal impact)
rsiIsOB = vwRsiValue >= vwRsiOB
rsiIsOS = vwRsiValue <= vwRsiOS
rsiZoneTxt = rsiIsOB ? "Overbought" : rsiIsOS ? "Oversold" : "Neutral"
rsiZoneCol = rsiIsOB ? fluorBearColor : rsiIsOS ? fluorBullColor : color.new(#8b949e, 0)

// Divergence pivot window from sensitivity setting
divPivWin = divSensitivity == "High" ? 3 : divSensitivity == "Low" ? 10 : 5
float divPivH = ta.pivothigh(vwRsiValue, divPivWin, divPivWin)
float divPivL = ta.pivotlow(vwRsiValue, divPivWin, divPivWin)
float divPivHPrice = ta.pivothigh(high, divPivWin, divPivWin)
float divPivLPrice = ta.pivotlow(low, divPivWin, divPivWin)

var float lastDivPivHRsi = na
var float lastDivPivLRsi = na
var float lastDivPivHPrice = na
var float lastDivPivLPrice = na
var int lastDivPivHBar = na
var int lastDivPivLBar = na

bool isBearDiv = false
if not na(divPivH)
    if not na(lastDivPivHRsi) and vwRsiValue[divPivWin] < lastDivPivHRsi and high[divPivWin] > lastDivPivHPrice
        isBearDiv := true
    lastDivPivHRsi := vwRsiValue[divPivWin]
    lastDivPivHPrice := high[divPivWin]
    lastDivPivHBar := bar_index - divPivWin

bool isBullDiv = false
if not na(divPivL)
    if not na(lastDivPivLRsi) and vwRsiValue[divPivWin] > lastDivPivLRsi and low[divPivWin] < lastDivPivLPrice
        isBullDiv := true
    lastDivPivLRsi := vwRsiValue[divPivWin]
    lastDivPivLPrice := low[divPivWin]
    lastDivPivLBar := bar_index - divPivWin

// Combined filter result (AND logic across enabled checks)
longConfirmed = (not useVwRsiFilter) or ((not useRsiConfirm or rsiConfirmLong) and (not useMfiConfirm or mfiConfirmLong))
shortConfirmed = (not useVwRsiFilter) or ((not useRsiConfirm or rsiConfirmShort) and (not useMfiConfirm or mfiConfirmShort))

// ---------------------------------------------------------------------------
// MULTI-TIMEFRAME TREND
// ---------------------------------------------------------------------------
f_mtf_bull(tf) =>
    result = request.security(syminfo.tickerid, tf, ta.ema(close, 9) > ta.ema(close, 21), lookahead=barmerge.lookahead_off)
    result == true

mtf1m = ema9Val > ema21Val
mtf5m = f_mtf_bull("5")
mtf15m = f_mtf_bull("15")
mtf1h = f_mtf_bull("60")
mtf4h = f_mtf_bull("240")
mtfD = f_mtf_bull("D")
mtfBullCount = (mtf1m ? 1 : 0) + (mtf5m ? 1 : 0) + (mtf15m ? 1 : 0) + (mtf1h ? 1 : 0) + (mtf4h ? 1 : 0) + (mtfD ? 1 : 0)

// ---------------------------------------------------------------------------
// TRADE LOG HELPER (defined early so it can be called during EV processing)
// ---------------------------------------------------------------------------
f_log_trade(dirArr, entryArr, exitArr, reasonArr, barsArr, dir, entryEv, exitEv, reason, bars, maxCount) =>
    array.unshift(dirArr, dir)
    array.unshift(entryArr, entryEv)
    array.unshift(exitArr, exitEv)
    array.unshift(reasonArr, reason)
    array.unshift(barsArr, bars)
    if array.size(dirArr) > maxCount
        array.pop(dirArr)
        array.pop(entryArr)
        array.pop(exitArr)
        array.pop(reasonArr)
        array.pop(barsArr)

// ---------------------------------------------------------------------------
// EV SCORE ENGINE - STATE (declared early, referenced in breakout gating)
// ---------------------------------------------------------------------------
var float anchorPrice = na
var float anchorConsolHigh = na
var float anchorConsolLow = na
var int signalDir = 0   // 1 = long, -1 = short, 0 = none
var int barsSinceSignal = 0
var float evScore = 50.0
var float prevEvScore = 50.0
var string prevEvZone = "Neutral"

// Snapshot vars for this-bar visuals (captured before any reset happens)
var int barDir = 0
var int barBarsSince = 0
var float barEvScore = 50.0

// Entry EV reference, captured at trigger
var float entryEvScore = 60.0

// Trade log storage (most recent trades, newest first)
var array<int> logDir = array.new<int>()
var array<float> logEntryEv = array.new<float>()
var array<float> logExitEv = array.new<float>()
var array<string> logReason = array.new<string>()
var array<int> logBars = array.new<int>()

// ---------------------------------------------------------------------------
// BREAKOUT SIGNAL
// ---------------------------------------------------------------------------
breakoutBuffer = atrVal * breakoutBufferATR

longBreakout = signalDir == 0 and inConsolidation[1] and close > (consolHigh[1] + breakoutBuffer) and (not requireImpulseAlign or impulseUp[1]) and longConfirmed
shortBreakout = signalDir == 0 and inConsolidation[1] and close < (consolLow[1] - breakoutBuffer) and (not requireImpulseAlign or impulseDown[1]) and shortConfirmed

// ---------------------------------------------------------------------------
// EV SCORE ENGINE - PROCESSING
// ---------------------------------------------------------------------------
volMA = ta.sma(volume, evLookbackVol)
volRatio = volMA > 0 ? volume / volMA : 1.0

// Trigger new signal: reset state
if longBreakout
    anchorPrice := close
    anchorConsolHigh := consolHigh[1]
    anchorConsolLow := consolLow[1]
    signalDir := 1
    barsSinceSignal := 0
    evScore := 60.0
    entryEvScore := 60.0

if shortBreakout
    anchorPrice := close
    anchorConsolHigh := consolHigh[1]
    anchorConsolLow := consolLow[1]
    signalDir := -1
    barsSinceSignal := 0
    evScore := 60.0
    entryEvScore := 60.0

// Evolve EV score while tracking active signal
if signalDir != 0 and barsSinceSignal < maxEvTrackBars
    barsSinceSignal += 1

    // --- Price component ---
    // Favorable drift: distance traveled in signal direction since anchor, normalized by ATR
    drift = signalDir == 1 ? (close - anchorPrice) : (anchorPrice - close)
    driftNorm = atrVal > 0 ? drift / atrVal : 0.0

    // Retracement check: has price come back into/past the consolidation zone (unfavorable)
    retracedIntoConsol = signalDir == 1 ? close < anchorConsolHigh : close > anchorConsolLow

    // Depth of retracement, normalized by ATR (how far back into/past the consolidation zone)
    retraceDepth = signalDir == 1 ? (anchorConsolHigh - close) / atrVal : (close - anchorConsolLow) / atrVal
    retraceDepthClamped = math.max(0.0, retraceDepth)

    // Price score delta: positive drift improves score, retracement decays proportionally to depth
    priceDelta = driftNorm * 8.0
    if retracedIntoConsol
        priceDelta -= (15.0 + retraceDepthClamped * 10.0)

    // --- Volume component ---
    // Favorable: volume expanding in direction of move (volRatio > 1 supports continuation)
    volDelta = 0.0
    if useVolumeComponent
        volDelta := (volRatio - 1.0) * 10.0
        // if price stalling (low driftNorm) but volume high, that's less favorable (effort vs result)
        if math.abs(driftNorm) < 0.1 and volRatio > 1.2
            volDelta -= 5.0

    // --- Combine ---
    totalWeight = useVolumeComponent ? (priceWeight + volumeWeight) : priceWeight
    blendedDelta = useVolumeComponent ? ((priceDelta * priceWeight) + (volDelta * volumeWeight)) / totalWeight : priceDelta

    evScore := math.max(0.0, math.min(100.0, evScore + blendedDelta * 0.3))

    // Snapshot this bar's active state for visuals (before potential reset below)
    barDir := signalDir
    barBarsSince := barsSinceSignal
    barEvScore := evScore

    // Early exit: trade reached an extreme EV outcome, close it out (resets to neutral for next signal)
    if barsSinceSignal >= minBarsBeforeExit and (evScore >= evExitHigh or evScore <= evExitLow)
        exitReason = evScore >= evExitHigh ? "EV High" : "EV Low"
        f_log_trade(logDir, logEntryEv, logExitEv, logReason, logBars, signalDir, entryEvScore, evScore, exitReason, barsSinceSignal, tradeLogCount)
        signalDir := 0
        evScore := 50.0
else if signalDir != 0 and barsSinceSignal >= maxEvTrackBars
    // hard cap reached without extreme outcome, reset
    barDir := signalDir
    barBarsSince := barsSinceSignal
    barEvScore := evScore
    f_log_trade(logDir, logEntryEv, logExitEv, logReason, logBars, signalDir, entryEvScore, evScore, "Timeout", barsSinceSignal, tradeLogCount)
    signalDir := 0
    evScore := 50.0
else
    // no active trade this bar
    barDir := 0
    barBarsSince := 0
    barEvScore := 50.0

// EV zone classification (based on this-bar snapshot, used for visuals)
evZone = barEvScore >= evImproveZone ? "Improving" : barEvScore <= evDecayZone ? "Decaying" : "Neutral"

// Four-zone EV color system (used for EV Score number, meter, and EV Zone text in dashboard)
// Direction-independent: EV score reflects trade quality regardless of long or short
//   90-100 = amber warning (approaching exit threshold)
//   60-90  = fluorBullColor (trade developing favorably)
//   40-60  = goldColor (neutral)
//   10-40  = fluorBearColor (trade developing poorly)
//   0-10   = amber warning (approaching exit threshold)
//   No active trade = gray
evAmberColor = color.new(#ff8c00, 0)
evFourZoneColor = barDir == 0 ? color.new(color.gray, 0) : barEvScore >= 90 ? evAmberColor : barEvScore >= 60 ? color.new(fluorBullColor, 0) : barEvScore >= 40 ? color.new(goldColor, 0) : barEvScore >= 10 ? color.new(fluorBearColor, 0) : evAmberColor

// Legacy evColor kept for trade log exit EV coloring (uses improve/decay/neutral palette, not direction-aware)
evColor = barEvScore >= evImproveZone ? color.new(evImproveColor, 0) : barEvScore <= evDecayZone ? color.new(evDecayColor, 0) : color.new(evNeutralColor, 0)

// Box fill transparency: more opaque as EV moves toward 0 or 100, more transparent near 50
evExtremity = math.abs(barEvScore - 50.0) / 50.0
boxFillTransparency = evBoxIntensityScale ? int(math.round(92 - evExtremity * 22)) : 88

// ---------------------------------------------------------------------------
// VISUALS - Consolidation Box
// ---------------------------------------------------------------------------
var box consolBox = na
if showConsolBox
    if inConsolidation and not inConsolidation[1]
        consolBox := box.new(bar_index - tightBarCount + 1, consolHigh, bar_index, consolLow, border_color=color.new(color.gray, 40), bgcolor=color.new(color.gray, 90), border_width=1)
    else if inConsolidation
        box.set_right(consolBox, bar_index)
        box.set_top(consolBox, math.max(box.get_top(consolBox), consolHigh))
        box.set_bottom(consolBox, math.min(box.get_bottom(consolBox), consolLow))

// ---------------------------------------------------------------------------
// VISUALS - Signal Labels
// ---------------------------------------------------------------------------
if showSignalLabels and longBreakout
    label.new(bar_index, low - atrVal * 0.5, "▲ EV " + str.tostring(math.round(barEvScore)), style=label.style_label_up, color=color.new(fluorBullColor, labelTransparency), textcolor=goldColor, size=size.tiny)

if showSignalLabels and shortBreakout
    label.new(bar_index, high + atrVal * 0.5, "▼ EV " + str.tostring(math.round(barEvScore)), style=label.style_label_down, color=color.new(fluorBearColor, labelTransparency), textcolor=goldColor, size=size.tiny)

// ---------------------------------------------------------------------------
// VISUALS - Trade Zone Box (colors with EV evolution)
// ---------------------------------------------------------------------------
var box tradeZoneBox = na

if barDir != 0 and barBarsSince == 1
    boxTop = barDir == 1 ? math.max(anchorPrice, high) : anchorConsolHigh
    boxBottom = barDir == 1 ? anchorConsolLow : math.min(anchorPrice, low)
    tradeZoneBox := showTradeZoneBox ? box.new(bar_index - 1, boxTop, bar_index, boxBottom, border_color=color.new(evBoxColor, 0), bgcolor=color.new(evBoxColor, boxFillTransparency), border_width=1) : na

if barDir != 0 and barBarsSince > 1 and showTradeZoneBox and not na(tradeZoneBox)
    box.set_right(tradeZoneBox, bar_index)
    box.set_bgcolor(tradeZoneBox, color.new(evBoxColor, boxFillTransparency))
    newTop = barDir == 1 ? math.max(box.get_top(tradeZoneBox), high) : box.get_top(tradeZoneBox)
    newBottom = barDir == 1 ? box.get_bottom(tradeZoneBox) : math.min(box.get_bottom(tradeZoneBox), low)
    box.set_top(tradeZoneBox, newTop)
    box.set_bottom(tradeZoneBox, newBottom)

// ---------------------------------------------------------------------------
// VISUALS - Extreme EV Shift Labels (only on big jumps or zone crossovers)
// ---------------------------------------------------------------------------
evShiftAmount = math.abs(barEvScore - prevEvScore)
zoneCrossover = evZone != prevEvZone
extremeShift = (evShiftAmount >= extremeShiftThreshold or zoneCrossover) and barDir != 0 and barBarsSince > 1

if extremeShift
    shiftY = barDir == 1 ? high + atrVal * 0.3 : low - atrVal * 0.3
    shiftStyle = barDir == 1 ? label.style_label_down : label.style_label_up
    shiftBgColor = barDir == 1 ? fluorBullColor : fluorBearColor
    label.new(bar_index, shiftY, "EV " + str.tostring(math.round(barEvScore)), style=shiftStyle, color=color.new(shiftBgColor, labelTransparency), textcolor=goldColor, size=size.tiny)

// Update prev-bar snapshots for next bar's shift detection
prevEvZone := evZone
prevEvScore := barEvScore

// ---------------------------------------------------------------------------
// VISUALS - Divergence Lines (overlay on chart, purely visual)
// ---------------------------------------------------------------------------
if showDivergence and showBearDiv and isBearDiv and not na(lastDivPivHBar[1])
    line.new(lastDivPivHBar[1], lastDivPivHPrice[1], bar_index - divPivWin, high[divPivWin], color=color.new(fluorBearColor, 0), width=divLineWidth, style=line.style_solid)

if showDivergence and showBullDiv and isBullDiv and not na(lastDivPivLBar[1])
    line.new(lastDivPivLBar[1], lastDivPivLPrice[1], bar_index - divPivWin, low[divPivWin], color=color.new(fluorBullColor, 0), width=divLineWidth, style=line.style_solid)

// ---------------------------------------------------------------------------
// HELPER FUNCTIONS
// ---------------------------------------------------------------------------
f_pct_bar(pct, len) =>
    int filled = math.round(pct / 100.0 * len)
    string bar = ""
    for i = 0 to len - 1
        bar += i < filled ? "▰" : "▱"
    bar

// ---------------------------------------------------------------------------
// DASHBOARD
// ---------------------------------------------------------------------------
dSize = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
posMap = dashLocation == "Top Right" ? position.top_right : dashLocation == "Bottom Right" ? position.bottom_right : dashLocation == "Bottom Left" ? position.bottom_left : position.top_left

var table dash = na
if showDashboard
    if barstate.isfirst
        dash := table.new(posMap, 2, 12, bgcolor=color.new(#0d1117, 0), border_color=color.new(#161b22, 0), border_width=1)

    if barstate.islast
        table.cell(dash, 0, 0, "EV EDGE", text_color=goldColor, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(dash, 1, 0, "v1.0", text_color=goldColor, bgcolor=color.new(#161b22, 0), text_size=dSize)

        table.cell(dash, 0, 1, "Status", text_color=color.gray, text_size=dSize)
        statusTxt = signalDir == 1 ? "LONG ACTIVE" : signalDir == -1 ? "SHORT ACTIVE" : "No Signal"
        statusColor = signalDir == 1 ? fluorBullColor : signalDir == -1 ? fluorBearColor : color.gray
        blinkOn = bar_index % 2 == 0
        statusDot = signalDir != 0 ? (blinkOn ? "● " : "○ ") : ""
        table.cell(dash, 1, 1, statusDot + statusTxt, text_color=statusColor, text_size=dSize)

        table.cell(dash, 0, 2, "EV Score", text_color=color.gray, text_size=dSize)
        table.cell(dash, 1, 2, str.tostring(math.round(barEvScore)) + " / 100", text_color=evFourZoneColor, text_size=dSize)

        table.cell(dash, 0, 3, "", text_color=color.gray, text_size=dSize)
        table.cell(dash, 1, 3, f_pct_bar(barEvScore, 10), text_color=evFourZoneColor, text_size=dSize)

        table.cell(dash, 0, 4, "EV Zone", text_color=color.gray, text_size=dSize)
        table.cell(dash, 1, 4, evZone, text_color=evFourZoneColor, text_size=dSize)

        table.cell(dash, 0, 5, "Bars Tracked", text_color=color.gray, text_size=dSize)
        table.cell(dash, 1, 5, signalDir != 0 ? str.tostring(barsSinceSignal) + " / " + str.tostring(maxEvTrackBars) : "-", text_color=goldColor, text_size=dSize)

        if showVwRsiPanel
            table.cell(dash, 0, 6, "VW RSI", text_color=color.gray, text_size=dSize)
            rsiCol = vwRsiValue > rsiMidline ? fluorBullColor : fluorBearColor
            table.cell(dash, 1, 6, str.tostring(math.round(vwRsiValue, 1)) + "  " + f_pct_bar(vwRsiValue, 10), text_color=rsiCol, text_size=dSize)

            table.cell(dash, 0, 7, "Zone", text_color=color.gray, text_size=dSize)
            table.cell(dash, 1, 7, rsiZoneTxt, text_color=rsiZoneCol, text_size=dSize)

            table.cell(dash, 0, 8, "MFI", text_color=color.gray, text_size=dSize)
            mfiCol = mfiValue > mfiMidline ? fluorBullColor : fluorBearColor
            table.cell(dash, 1, 8, str.tostring(math.round(mfiValue, 1)) + "  " + f_pct_bar(mfiValue, 10), text_color=mfiCol, text_size=dSize)

            table.cell(dash, 0, 9, "Confirms", text_color=color.gray, text_size=dSize)
            rawLongConfirm = (not useRsiConfirm or rsiConfirmLong) and (not useMfiConfirm or mfiConfirmLong)
            rawShortConfirm = (not useRsiConfirm or rsiConfirmShort) and (not useMfiConfirm or mfiConfirmShort)
            confirmTxt = rawLongConfirm and rawShortConfirm ? "Both" : rawLongConfirm ? "Long" : rawShortConfirm ? "Short" : "Neither"
            confirmCol = rawLongConfirm and rawShortConfirm ? color.gray : rawLongConfirm ? fluorBullColor : rawShortConfirm ? fluorBearColor : color.orange
            table.cell(dash, 1, 9, confirmTxt, text_color=confirmCol, text_size=dSize)

            table.cell(dash, 0, 10, "Divergence", text_color=color.gray, text_size=dSize)
            divTxt = isBullDiv ? "▲ Bull Div" : isBearDiv ? "▼ Bear Div" : "—"
            divCol = isBullDiv ? fluorBullColor : isBearDiv ? fluorBearColor : color.gray
            table.cell(dash, 1, 10, divTxt, text_color=divCol, text_size=dSize)

        table.cell(dash, 0, 11, "Anonycryptous", text_color=goldColor, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(dash, 1, 11, "", text_color=goldColor, bgcolor=color.new(#161b22, 0), text_size=dSize)

// ---------------------------------------------------------------------------
// MULTI-TIMEFRAME TREND BAR
// ---------------------------------------------------------------------------
mtfPosMap = mtfPos == "Top Left" ? position.top_left : mtfPos == "Top Right" ? position.top_right : mtfPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table mtfTable = na
if useMtf
    if barstate.isfirst
        mtfTable := table.new(mtfPosMap, 7, 3, bgcolor=color.new(#0d1117, 10), border_color=color.new(#161b22, 0), border_width=1)

    if barstate.islast
        table.cell(mtfTable, 0, 0, "MTF", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 1, 0, "1m", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 2, 0, "5m", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 3, 0, "15m", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 4, 0, "1H", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 5, 0, "4H", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(mtfTable, 6, 0, "D", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)

        countColor = mtfBullCount >= 4 ? fluorBullColor : mtfBullCount <= 2 ? fluorBearColor : goldColor
        table.cell(mtfTable, 0, 1, str.tostring(mtfBullCount) + "/6", text_color=countColor, text_size=dSize)
        table.cell(mtfTable, 1, 1, mtf1m ? "▲" : "▼", text_color=mtf1m ? fluorBullColor : fluorBearColor, bgcolor=mtf1m ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)
        table.cell(mtfTable, 2, 1, mtf5m ? "▲" : "▼", text_color=mtf5m ? fluorBullColor : fluorBearColor, bgcolor=mtf5m ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)
        table.cell(mtfTable, 3, 1, mtf15m ? "▲" : "▼", text_color=mtf15m ? fluorBullColor : fluorBearColor, bgcolor=mtf15m ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)
        table.cell(mtfTable, 4, 1, mtf1h ? "▲" : "▼", text_color=mtf1h ? fluorBullColor : fluorBearColor, bgcolor=mtf1h ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)
        table.cell(mtfTable, 5, 1, mtf4h ? "▲" : "▼", text_color=mtf4h ? fluorBullColor : fluorBearColor, bgcolor=mtf4h ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)
        table.cell(mtfTable, 6, 1, mtfD ? "▲" : "▼", text_color=mtfD ? fluorBullColor : fluorBearColor, bgcolor=mtfD ? color.new(fluorBullColor, 90) : color.new(fluorBearColor, 90), text_size=dSize)

        table.cell(mtfTable, 0, 2, "Anonycryptous", text_color=goldColor, bgcolor=color.new(#161b22, 0), text_size=dSize)

// ---------------------------------------------------------------------------
// TRADE LOG TABLE
// ---------------------------------------------------------------------------
tradeLogPosMap = tradeLogPos == "Top Left" ? position.top_left : tradeLogPos == "Top Right" ? position.top_right : tradeLogPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table logTable = na
if showTradeLog
    if barstate.isfirst
        logTable := table.new(tradeLogPosMap, 5, tradeLogCount + 1, bgcolor=color.new(#0d1117, 10), border_color=color.new(#161b22, 0), border_width=1)

    if barstate.islast
        table.cell(logTable, 0, 0, "Dir", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(logTable, 1, 0, "Entry EV", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(logTable, 2, 0, "Exit EV", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(logTable, 3, 0, "Reason", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)
        table.cell(logTable, 4, 0, "Bars", text_color=color.gray, bgcolor=color.new(#161b22, 0), text_size=dSize)

        logCount = array.size(logDir)
        for i = 0 to tradeLogCount - 1
            if i < logCount
                rowDir = array.get(logDir, i)
                rowEntryEv = array.get(logEntryEv, i)
                rowExitEv = array.get(logExitEv, i)
                rowReason = array.get(logReason, i)
                rowBars = array.get(logBars, i)

                dirColor = rowDir == 1 ? fluorBullColor : fluorBearColor
                exitColor = rowExitEv >= evImproveZone ? color.new(fluorBullColor, 0) : rowExitEv <= evDecayZone ? color.new(fluorBearColor, 0) : color.new(evNeutralColor, 0)

                table.cell(logTable, 0, i + 1, rowDir == 1 ? "Long" : "Short", text_color=dirColor, text_size=dSize)
                table.cell(logTable, 1, i + 1, str.tostring(math.round(rowEntryEv)), text_color=color.gray, text_size=dSize)
                table.cell(logTable, 2, i + 1, str.tostring(math.round(rowExitEv)), text_color=exitColor, text_size=dSize)
                table.cell(logTable, 3, i + 1, rowReason, text_color=color.gray, text_size=dSize)
                table.cell(logTable, 4, i + 1, str.tostring(rowBars), text_color=color.gray, text_size=dSize)

// ---------------------------------------------------------------------------
// PLOTS (for reference / alerts)
// ---------------------------------------------------------------------------
plot(showEma9 ? ema9Val : na, title="EMA 9", color=ema9Color, linewidth=ema9Width)
plot(showEma21 ? ema21Val : na, title="EMA 21", color=ema21Color, linewidth=ema21Width)
plot(showEma50 ? ema50Val : na, title="EMA 50", color=ema50Color, linewidth=ema50Width)
plot(showEma200 ? ema200Val : na, title="EMA 200", color=ema200Color, linewidth=ema200Width)

plotshape(longBreakout, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=fluorBullColor, size=size.tiny)
plotshape(shortBreakout, title="Short Signal", style=shape.triangledown, location=location.abovebar, color=fluorBearColor, size=size.tiny)

alertcondition(longBreakout, title="EV Edge Long Signal", message="EV Edge: Long breakout signal")
alertcondition(shortBreakout, title="EV Edge Short Signal", message="EV Edge: Short breakout signal")
````
