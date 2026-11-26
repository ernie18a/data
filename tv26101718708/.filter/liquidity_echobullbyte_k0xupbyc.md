# Liquidity Echo[BullByte]

- url: https://www.tradingview.com/script/K0XUPByC-Liquidity-Echo-BullByte/
- type: indicator
- pine_id: PUB;811549df25a046679191382f6333daa3
- version: 1.0

## Description

[b]LIQUIDITY ECHO [BullByte][/b]

Liquidity Echo is an original indicator built on a purpose-written [b]four-layer detection architecture [/b]where no layer produces a standalone signal and the detection logic is arranged as one unified model. It was built around one core idea: institutional money does not enter markets randomly. It enters at specific price levels where liquidity has been engineered, collected, and then abandoned. This indicator detects those exact moments, measures the market response, and presents a structured reversal entry with full visual trade management directly on the chart.

Each of the four detection layers was built to be structurally dependent on the others. The HTF compression zone does not produce a signal. The volume vacuum does not produce a signal. The sweep classification does not produce a signal. The pressure gradient does not produce a signal. None of these elements has any standalone output. A signal exists only when all four agree simultaneously, and the quality score that grades each signal is a composite function of how strongly each layer fired. Remove any single layer and the remaining three produce nothing. This structure is intended as one unified detection system rather than a collection of separate tools with unrelated outputs.

---

[b]WHAT PROBLEM THIS SOLVES[/b]

Most retail traders face two specific problems. The first is identifying where a move is likely to begin before it has already happened. The second is knowing whether a sharp price spike at a key level is a genuine smart money reversal or a continuation trap.

Standard tools like RSI, MACD, or Bollinger Bands measure price behavior in isolation. They tell you what price has done but not why, and they do not account for where price sits relative to higher timeframe institutional order flow and supply and demand. Liquidity Echo reads the higher timeframe environment first, identifies where price is coiling inside a compression zone, and then waits for a specific sequence of events at that level before generating any signal.

---

[b]THE ORIGIN AND OBSERVATION BEHIND THIS INDICATOR[/b]

Markets frequently spike through obvious support and resistance levels, trigger stop losses clustered just beyond those levels, and then reverse sharply in the opposite direction. This behavior is often repeatable. A large institutional buy order requires sellers. Those sellers are often concentrated just below visible support, where stop loss orders from long positions accumulate. A liquidity sweep through that level can absorb resting liquidity and is often followed by a reversal. This is the stop hunt mechanism that Liquidity Echo is built to identify.

What separates this indicator from any generic spike detector is the requirement that the sweep occur at a level where the higher timeframe is actively compressing. Compression at a level indicates institutional interest, because large participants cause range contraction when they absorb one side of order flow without allowing free price movement. A sweep through a compressed zone is treated as a stronger reversal context than a sweep through an ordinary pivot.

---

[b]WHY THESE FOUR SPECIFIC LAYERS AND WHY THEY ARE ORIGINAL[/b]

[b]Layer one[/b] is the HTF compression zone. The indicator measures the current higher timeframe bar range against the average of the three preceding bars. When the current bar is significantly narrower than recent history, the market is coiling and a zone is registered. Compression zones are color-coded by touch count. A fresh untested zone appears in soft purple. A zone tested once appears slightly lighter. A zone tested twice or more appears in orange, indicating stronger significance because repeated testing without a break can show that the level is being defended.

[b]Layer two[/b] is the volume vacuum. Institutional stop hunts are frequently preceded by a quiet period where market participation drops. The vacuum condition requires that volume fall below a calibrated threshold for a minimum number of consecutive bars before the sweep fires. This helps filter out sweeps that occur on already active volume, which may behave more like continuation moves than reversals.

[b]Layer three[/b] is the sweep classification. A spike sweep occurs when a candle wicks sharply through the zone boundary and closes back inside. A grind sweep occurs when price pushes slowly through the zone over several bars and then closes back across the boundary without any sharp wick. The spike path is further subdivided. A minor sweep is a small wick extension above the calibrated minimum. A major sweep extends beyond a configurable ATR multiple, indicating a more aggressive stop hunt. A flush sweep represents the most violent classification where a large cluster of stops was cleared in a single candle. Each level contributes differently to the signal quality score.

[b]Layer four[/b] is the pressure gradient. This is a separate momentum-shift measurement rather than a standard oscillator. It measures the rate of change of a within-bar close location across three bars, derived from the delta concept used in options market microstructure analysis and adapted here as a momentum shift detector timed specifically to the sweep event. Each bar's delta is computed as the ratio of where the close falls within the high-low range, normalized between negative one and positive one. The gradient is the rate of change in this delta from two bars ago to the current bar. A positive gradient on a potential long signal means buying pressure was already accelerating across three bars even while price was spiking down through the zone. This supports the reversal context before the entry candle closes.

The sweep classification is not a wick ratio filter applied to any candle. It measures wick extension in ATR units specifically relative to a compressed higher timeframe zone boundary, which is a combined spatial and volatility measurement that requires both the zone and the ATR context simultaneously to compute. The volume vacuum is not a simple volume moving average crossover. It uses a coefficient of variation derived threshold that adapts to whether the instrument has session-structured volume or continuous volume flow, a behavioral classification the indicator measures itself in real time.

---

[b]AUTO-CALIBRATION ENGINE[/b]

The auto-calibration engine is the original technical contribution that makes the four-layer system viable across all asset classes without manual configuration. Many tools that use ATR thresholds, volume ratios, wick filters, or compression logic rely on manual settings or presets, either through a fixed number or an asset class preset. This indicator reduces that requirement by adapting its thresholds to the chart's own behavior.

The engine measures three behavioral properties of the current chart at runtime.

The [b]wick-body ratio[/b] is the average total wick length divided by the average body size over the calibration window. Different instruments can behave very differently. Some show sharp wick-driven sweeps, while others tend to grind through levels more slowly. The engine uses this measurement to set the minimum wick requirement for spike detection and to decide whether grind mode should activate automatically.

The [b]volume coefficient of variation[/b] is the standard deviation of volume divided by its mean. A high coefficient means volume is session-structured with clear spikes and quiet periods. A low coefficient means volume flows continuously. This calibrates the vacuum threshold and the volume averaging window specific to the instrument's own behavior pattern.

The [b]ATR mean percentile[/b] measures where current volatility sits within its recent historical range. This calibrates the compression sensitivity so the narrowing threshold adapts to instruments that are normally tight versus instruments that are normally wide.

The [b]Sensitivity Bias[/b] input is the only manual judgment required. Conservative tightens all thresholds uniformly for fewer, higher-conviction signals. Neutral applies thresholds exactly as measured. Aggressive loosens thresholds for conditions where more signals are preferred. The bias scales every derived threshold by a fixed multiplier so the relationship between all layers remains internally consistent regardless of the setting chosen.

---

[b]SIGNAL QUALITY SCORING[/b]

Every signal that passes all four confirmation layers receives a quality score from zero to ten built from four components.

[b]Zone compression strength[/b] contributes up to three points. A ratio below 0.55 between the current HTF range and its three-bar average scores three points. Below 0.68 scores two. Below the effective narrowing threshold scores one.

[b]Sweep severity[/b] contributes up to three points. A flush sweep scores three. A major sweep scores two. A minor or grind sweep scores one.

[b]Pressure gradient magnitude[/b] contributes up to two points. A gradient above 0.55 in absolute value scores two. Above 0.25 scores one.

[b]Zone touch count[/b] contributes up to two points. A zone tested twice or more scores two. Tested once scores one. An untested zone scores zero on this dimension.

Scores from eight to ten produce a PRIME grade. Six to seven is HIGH. Four to five is MED. Below four is LOW. A gold diamond marks PRIME signals on the chart. A green circle marks HIGH. A yellow square marks MED. A gray cross marks LOW. Traders who want fewer signals can focus on the higher-grade markers.

---

[b]HOW TO READ WHAT APPEARS ON THE CHART[/b]

The EMA line renders as two overlapping plots. A wide semi-transparent outer glow and a solid thinner inner line. Both turn green when price is above the EMA and red when below. Long signals only fire above the EMA. Short signals only fire below it. The EMA is a directional filter, not a signal source.

Compression zones appear as filled rectangular boxes spanning the full higher timeframe bar range at the moment of detection. Fresh zones are soft purple. Zones tested once are a slightly lighter purple. Zones tested twice or more shift to orange.

Volume vacuum bars carry a very faint yellow background tint on candles where the low-volume precondition is active. The tint is intentionally near-invisible at 96 percent transparency so it provides context without competing with price action. It marks where the trap was being set, not where it fired.

Grind sweep markers appear as small orange triangles. An upward triangle below the bar marks a bullish grind sweep detected in progress. A downward triangle above marks a bearish grind sweep. These appear before the commitment candle confirms the signal. They are early warning markers only.

When a signal fires, a label appears below the bar for a long entry and above the bar for a short entry. MINIMAL mode shows direction, grade, and score. DETAIL mode adds sweep type, zone price, and all trade levels.

The trade forecast visualization draws immediately on signal confirmation. A blue line marks entry. A red line marks the stop loss. Two dashed green lines mark Target 1 and Target 2. A light green box fills the entry to Target 1 zone. A lighter green box fills the Target 1 to Target 2 zone. A light red box fills the stop to entry zone. The first green box deepens in shade when Target 1 is hit. The second deepens when Target 2 is hit. The stop line updates in real time when trailing stop or breakeven is active.

The trailing stop renders as a dual-layer line matching the EMA visual style. Green for a long trail, red for a short trail. It ratchets in the direction of the trade and never moves against the position.

[b]TRADE ANALYSIS - CHART OVERVIEW[/b]

[b]BTC Perpetual Futures Contract
BINANCE:BTCUSD.P
Time Frame 5 mins[/b]

[image]https://www.tradingview.com/x/x69x4vVW/[/image]

[b]WHAT THE SIGNALS TELL US:[/b]
This chart demonstrates both long and short reversal opportunities in the same trading session. The first signal was a [b]LONG [/b]entry triggered by a minor spike sweep below zone 76079.9, graded MED 5/10 quality, which reached both targets in the example shown. The second signal was a [b]SHORT [/b]entry triggered by a grind sweep above zone 76577.6, graded MED 4/10 quality, after price failed to sustain the rally and began reversing. Multiple orange triangle markers throughout the chart show where the grind sweep detection algorithm identified slow institutional accumulation or distribution patterns that preceded directional moves. The yellow square quality symbols indicate both signals were medium-grade setups-not the highest conviction (which would show gold diamonds), but sufficient quality to warrant entries with proper risk management.

[b]WHAT THE DASHBOARD ELEMENTS MEAN:[/b]
The dashboard provides real-time market context that helps evaluate signal quality and trade conditions. The [b]STATE [/b]indicator shows whether the system is scanning for new setups or managing an active position. [b]HTF ZONE[/b] tracking displays how many compression zones are currently being monitored-these are the price levels where institutional liquidity is likely to accumulate. [b]COMPRESS [/b]indicates whether price range is narrowing (coiling energy) or expanded (post-move). [b]ATR%[/b] measures current volatility relative to recent history: [b]HOT [/b]means explosive conditions favorable for hitting targets, [b]FLAT [/b]means low volatility where moves stall. [b]VACUUM [/b]detects when volume drops below normal before a sweep, signaling institutional preparation. [b]VOL RATIO[/b] compares current bar volume to the rolling average-spikes confirm that stops were actually hunted. [b]SWEEP [/b]classification [b](MINOR, MAJOR, FLUSH, GRIND)[/b] tells you how aggressively the level was cleared. [b]GRADIENT [/b]measures momentum direction-positive favors longs, negative favors shorts. [b]TREND [/b]with [b]EMA [/b]shows the macro directional filter-price above EMA enables longs, below enables shorts. [b]CALIBRATION LIVE [/b]means thresholds auto-adjust to the current instrument's behavior, while [b]GRIND [/b]mode activates when the system detects slow-push sweep patterns. Quality scoring combines all these factors to produce the 0-10 grade that appears on each signal label.


---

[b]THE DASHBOARD PANEL[/b]

The dashboard sits in the top right corner of the chart and displays the complete state of the indicator at the current bar in real time. It is organized into thirteen rows.

[list]
[*]The header row shows the indicator name, the author name, the current sensitivity bias setting, and whether calibration is live or locked.

[*]The state row shows whether the indicator is scanning for a setup or has an active trade. When active it shows [b]LONG ACTIVE[/b] or [b]SHORT ACTIVE[/b]. The right side of this row shows the stop loss distance in price units and ATR multiples.

[*]The HTF zone row shows whether the zone system is active and how many zones are currently tracked.

[*]The compression row shows the current compression strength as [b]NONE, LIGHT, MEDIUM, or STRONG[/b]. The right side shows the current ATR percentile with a [b]HOT, NORM, or FLAT[/b] label indicating whether volatility is elevated, normal, or suppressed.

[*]The vacuum row shows whether the volume vacuum condition is currently active and displays the current volume ratio as a multiple of the rolling average.

[*]The sweep row shows the current sweep classification if a sweep is pending or the classification of the most recent signal if a trade is active. The gradient value is displayed on the right with green coloring for positive, red for negative, and white for near-zero.

[*]The quality row shows the visual quality bar and the grade with score when a trade is active. The quality bar uses simple characters to show the score at a glance.

[*]The TP1 and TP2 row shows exact target prices when a trade is active and updates to show HIT when each level is reached.

[*]The stop row shows the current stop loss price and whether it is initial, trailing, or moved to breakeven.

[*]The position row shows what percentage of the position remains open after any partial close at Target 1.

[*]The trend row shows whether the macro bias is [b]BULL or BEAR[/b] based on the EMA and displays the current EMA value.

[*]The sweep expiry row shows how many bars remain in the commitment window if a sweep is pending but not yet confirmed.

[*]The calibration row shows whether the auto-calibration engine is [b]LIVE or LOCKED[/b], and shows the grind mode status and the configured stop loss ATR multiplier.
[/list]

---

[b]A WALK-THROUGH OF A COMPLETE SIGNAL[/b]

Consider a bullish example. The higher timeframe has been compressing for several bars. The compression zone is registered and appears as a purple box on the chart between two price levels, for example 42200 and 42350 on a Bitcoin five-minute chart. Price approaches from above and enters the zone. Volume begins to drop across two or three bars, triggering the vacuum condition and tinting those bars with a faint yellow background.

On the next bar price spikes sharply below the bottom of the zone to 42080, creating a wick of approximately 120 points below 42200. The wick extends 0.9 ATR below the zone boundary, qualifying as a [b]MAJOR [/b]sweep. The candle body closes back at 42210, inside the zone. The pressure gradient at this point reads positive 0.38, meaning buying pressure has been accelerating across the last three bars despite the downward spike.

All four conditions are now satisfied: compression zone present, volume vacuum active, MAJOR sweep detected, gradient positive and above threshold. The sweep state is recorded. The dashboard updates to show [b]SWEEP[/b]: [b]MAJOR [/b]and the remaining bars in the commitment window begin counting down.

On the following bar a bullish candle forms. It has a body of 85 points, which exceeds the minimum body size requirement relative to ATR. Volume on this candle is 1.2 times the rolling average, above the 0.65 minimum. The candle closes at 42310, above the zone low of 42200. All commitment candle conditions pass. The signal fires.

A label appears below that bar reading LONG HIGH 7/10. A green circle shape appears above the bar marking a HIGH grade signal. The trade forecast boxes appear: a green box from 42310 to 42510 for Target 1 region, a lighter green box from 42510 to 42660 for Target 2 region, and a red box from 42310 down to 41910 for the stop zone. The entry line is drawn at 42310. The stop line is drawn at 41910. Target 1 is drawn at 42510. Target 2 is drawn at 42660.

The dashboard updates to show LONG ACTIVE, the exact stop and target prices, the quality grade of HIGH at 7 out of 10, and POS REMAIN at 100 percent.

When price reaches 42510 the TP1 box deepens in shade. The dashboard shows HIT on the TP1 row. POS REMAIN drops to 50 percent. If breakeven is enabled the stop line on the chart moves up to 42310 and the dashboard stop type changes to [b]BREAKEVEN[/b].

When price reaches 42660 the TP2 box deepens. The dashboard shows HIT on the TP2 row. The trade closes. The lines and boxes move into history if the historical display option is enabled, fading slightly to distinguish them from any new active trade.


[b]Chart Example of a Long "High" Grade Signal full lifecycle[/b]

[b]BTC Perpetual Futures Contract
BINANCE:BTCUSD.P
Time Frame 5 mins[/b]

[b]IMAGE 1: SIGNAL GENERATION & PRE-CONDITIONS[/b]

[image]https://www.tradingview.com/x/4DLkytR9/[/image]

[b]What Triggered the Signal:[/b] A grind sweep was detected at zone 77699.7. Price slowly pushed below the compression level over several bars (orange triangle marker visible on left side), then reversed with a commitment candle. Dashboard shows SWEEP: GRIND with GRADIENT: 0.54 confirming positive momentum shift. VACUUM: NO indicates volume was not in vacuum state during this particular signal. The sweep window counter shows 7/8 bars remaining, meaning the indicator is waiting for final commitment candle confirmation before entering the trade.

[b]Pre-Condition Dashboard Readings:[/b]

[b]COMPRESS:[/b] NONE - No active compression detected at this moment
[b]ATR%:[/b] 42.9% NORM - Volatility in normal range
[b]VACUUM:[/b] NO - Volume condition not active
[b]VOL RATIO:[/b] 1.51x - Volume 1.51 times the average
[b]GRADIENT:[/b] 0.54 - Strong positive momentum
[b]TREND:[/b] BEAR - EMA at 77762.5, price below (note: this signal appears to have fired despite bearish EMA, possibly EMA filter was disabled or price was transitioning)

[b]IMAGE 2: TRADE SETUP & ACTIVE MANAGEMENT[/b]

[image]https://www.tradingview.com/x/8vbIgn14/[/image]

[b]Trade Entry Confirmation:[/b] The commitment candle confirmed, and the trade entered. Dashboard now shows STATE: LONG ACTIVE, indicating the position is open. Signal label displays "[L] LONG HIGH 6/10 Sweep: GRIND Zone: 77723.0" with green circle quality marker (HIGH grade).

[b]Stop Loss & Target Calculation:[/b]

[b]Entry Zone:[/b] 77838.0
[b]Stop Loss:[/b] 77511.2 (placed 2 ATR below entry)
[b]SL Distance:[/b] 327.5 points (2 ATR) shown in dashboard as "SL DIST: 327.5 (2 ATR)"
[b]Target 1: [/b]78166.2 (327.5 points profit, 1 R) - 50% position close
[b]Target 2:[/b] 78411.8 (573 points profit, 1.5R) - remaining 50%

[b]Active Trade Dashboard:[/b]

[b]STATE: [/b]LONG ACTIVE
[b]QUALITY:[/b] ||||||||.... (8 bars filled) GRADE: HIGH 6/10
[b]TP1 (50%):[/b] 78166.2 | [b]TP2 (50%): [/b]78411.8
[b]STOP: [/b]77511.2 | [b]TYPE:[/b] INITIAL
[b]POS REMAIN:[/b] 100% (full position still open)
[b]TREND:[/b] BULL (EMA 21: 77774.8) - price has crossed above EMA confirming bullish bias
[b]VACUUM:[/b] ACTIVE (yellow highlight visible on some bars)
[b]VOL RATIO:[/b] 0.09x - Low volume, waiting for high volume to confirm institutional participation
[b]GRADIENT:[/b] 0.66 (Strong positive momentum)
[b]SWEEP EXP:[/b] In Trade (window closed, position active)

[b]IMAGE 3: TRADE PROGRESS & ACHIEVEMENT[/b]

[image]https://www.tradingview.com/x/shYY2Nfq/[/image]

[b]Target Achievement:[/b] Price rallied from the entry at 77838 and reached 78,411.0 (shown in the top right), representing a 573-point profit. The green profit boxes are fully filled showing price traveled through both reward zones. Purple horizontal line visible near 78,390 level marking current price or a new resistance zone.

[b]Post-Trade Dashboard:[/b]

[b]STATE:[/b] SCANNING (trade closed, position exited)
[b]HTF ZONE:[/b] ACTIVE with COUNT: 1 zones being tracked
[b]COMPRESS:[/b] NONE
[b]ATR%:[/b] 9.1% FLAT - volatility compressed significantly after the move
[b]VACUUM: [/b]ACTIVE - volume vacuum condition now present (post-move exhaustion)
[b]VOL RATIO:[/b] 0.53x - volume dropped to 53% of average confirming the move is complete
[b]TREND:[/b] BULL (EMA 21: 78227.4) - price well above EMA
[b]Quality/Grade/TP fields:[/b] - (cleared because no active trade)

In the example shown, both level 1 (78166.2) and level 2 (78411.8) were touched. The trade reached approximately 1.0R at TP1 and 1.5R at TP2, with 50% of the position closed at each level. The grind sweep at 77723.0 identified the liquidity absorption area that preceded the rally. The current price of 78,390.0 represents approximately 573 points of illustrative move from the entry.

---

[b]RECOMMENDED SETTINGS BY MARKET[/b]

[b]For cryptocurrency[/b] on a 5-minute chart, the recommended HTF reference is 15 minutes. The EMA can be set to 21 for fast trend alignment. The sensitivity bias can start at NEUTRAL and be adjusted to AGGRESSIVE on high-liquidity pairs during active sessions.

[b]For equity index[/b] futures on a 5-minute chart, the recommended HTF reference is 30 minutes or 1 hour. The EMA can be set to 50. The sensitivity bias works best at CONSERVATIVE or NEUTRAL because index instruments tend to grind slowly and produce more noise with aggressive settings.

[b]For forex major pairs[/b] on a 15-minute chart, the recommended HTF reference is 1 hour. The grind sweep path is particularly effective on forex due to the low wick-body ratio of most major pairs. The EMA at 50 provides clean directional filtering.

[b]For equities on daily charts[/b], the recommended HTF reference is 4 hours. The calibration window can be increased to 200 bars for more stable threshold measurement on slower instruments.

The indicator works on any timeframe and any asset class without requiring manual configuration because the auto-calibration engine reads the instrument's behavior directly. The recommended settings above are starting points for users who prefer guidance. The behavior metrics displayed in the dashboard can help users understand whether their current settings are appropriate for the instrument they are trading.

---

[b]TRADE MANAGEMENT DEFAULTS AND HOW TO ADJUST THEM[/b]

The default stop loss distance is two ATR. This is intentionally wider than typical scalping tools to accommodate the nature of liquidity sweep entries, where price frequently makes one final push against the position before reversing. A stop placed too tightly below or above a sweep zone will be taken out by the very move the signal is identifying.

Target 1 defaults to two ATR from entry, producing a one-to-one risk-to-reward on the first half of the position. Target 2 defaults to 3.5 ATR, producing a one-to-1.75 risk-to-reward on the remaining position. By default fifty percent of the position is closed at Target 1 and fifty percent runs to Target 2. This split can be adjusted between ten and ninety percent in the settings.

The breakeven option moves the stop to the entry price once Target 1 is hit. This eliminates all risk on the remaining position after the first target is reached.

The trailing stop option activates a ratcheting stop that follows the lowest low of the last four bars for long trades and the highest high for short trades, minus or plus the configured ATR offset. The trail can start immediately at entry or only after Target 1 is hit, depending on the Trailing Starts After setting.

The timeout setting closes the trade if Target 1 is not reached within the configured number of bars. This prevents capital from being tied up in stalled setups indefinitely.

The minimum bars between signals setting prevents back-to-back entries on the same directional impulse. At the default of eight bars on a five-minute chart, this means a new signal in the same direction cannot fire within forty minutes of the previous one.

---

[b]HOW TO USE THE TWO-BAR CONFIRMATION OPTION[/b]

The two-bar confirmation setting requires that both the commitment candle and the candle immediately before it close in the signal direction and on the correct side of the zone. This setting is intended for instruments that produce many false commitment candles on the first bar of a potential reversal. On indices and slower-moving instruments enabling this option reduces entries by approximately thirty to forty percent but eliminates most of the premature entries where the reversal fails on the first bar.

The cost of this setting is one bar of lag. On a five-minute chart this means the entry is delayed by five minutes from the initial sweep detection. On a one-minute chart this delay is acceptable for intraday scalping. On a fifteen-minute chart the delay may cause significant slippage relative to the optimal entry zone. Users should test this option on their specific instrument and timeframe before relying on it.

---

[b]WHAT THE GRIND PATH DETECTS AND WHY IT EXISTS[/b]

The grind sweep path exists because not all instruments produce sharp spike wicks through key levels. Equity indices in particular tend to slowly close beyond a level across multiple bars before reversing. A traditional wick-based detection system would miss these sweeps entirely because no individual candle has a wick large enough to qualify.

The grind path looks back a configurable number of bars to check whether price was outside the zone boundary during any of those bars. If price was beyond the zone and the current bar closes back inside with a body in the reversal direction and the gradient confirms the momentum shift, the condition qualifies as a grind sweep. It receives the same treatment as a spike sweep from the commitment candle onward.

The [b]orange triangle[/b] markers on the chart show where grind conditions were detected, which is useful for understanding how often this path fires on your specific instrument versus the spike path.

---

[b]ALERTS[/b]

[b]Eight alert conditions are available[/b]. The Long Signal and Short Signal alerts fire when a full confirmed entry is generated. The Bull Sweep and Bear Sweep alerts fire when a sweep is detected but before the commitment candle has confirmed. These earlier alerts allow traders to watch for the setup manually and decide whether to act. The Target 1 Hit and Target 2 Hit alerts notify when each level is reached. The Breakeven alert fires when the stop is moved to entry. The Trailing On alert fires when the trailing stop activates.

All alerts use TradingView's standard alert condition system. To set an alert, add the indicator to your chart, click the alert creation button, and select any of the eight named conditions from the dropdown. Alerts can be set to once per bar close on the signal conditions to ensure only confirmed bars trigger notifications.

---

[b]IMPORTANT NOTES ON TIMEFRAME ALIGNMENT[/b]

The HTF reference should always be set to a timeframe higher than the chart you are viewing the indicator on. Setting the HTF reference to the same timeframe as the chart produces redundant zone detection that does not add higher timeframe context. Setting it to a lower timeframe is not valid and should be avoided.

The indicator requires a minimum number of bars equal to the calibration window before any signals are generated. At the default calibration window of 100 bars, the first 100 candles on any chart will show no signals while the engine builds its behavioral measurements. This is indicated in the code by the ready condition and is by design.

On very low timeframes such as one-minute charts, the calibration window represents only about 100 minutes of data. Users on one-minute charts may want to increase the calibration window to 200 bars for more stable threshold measurement across a full session.

---

[b]DISCLAIMER[/b]

This indicator is published for educational and informational purposes only. Nothing in this publication or in the indicator's output constitutes financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All trading involves substantial risk of loss. Past signal performance visible on historical charts does not guarantee or predict future results. The visual trade management levels shown on the chart are illustrative and do not represent guaranteed exit points. Slippage, spread, and market conditions will affect actual trade outcomes. Always apply your own analysis and risk management before entering any trade. Never risk more than you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BullByte


//@version=6
// ============================================================
// Liquidity Echo[BullByte]
// Version: 1.0
//
// Detects institutional liquidity sweeps at higher-timeframe
// compression zones, measures market response via volume
// vacuum and pressure gradient, then generates high-probability
// reversal entries with full automated trade management.
//
// Four confirmation layers work together on every signal:
//   1. HTF Compression Zones  - locates where price is coiling
//   2. Volume Vacuum          - low activity preceding the move
//   3. Sweep Classification   - spike or grind through the zone
//   4. Pressure Gradient      - momentum already reversing
//
// Auto-calibration reads the current chart's own behavior to
// set all thresholds automatically. No asset class selection
// is required. Works on crypto, forex, indices, futures,
// commodities, and equities without any manual configuration.
//
// DISCLAIMER:
//   This indicator is for educational purposes only and does
//   not constitute financial advice. Trading carries
//   substantial risk of loss. Past signals do not guarantee
//   future results. Always apply your own judgment and
//   risk management before entering any trade.
// ============================================================

indicator(title = 'Liquidity Echo[BullByte]', shorttitle = 'LiqEcho[BullByte]', overlay = true, max_labels_count = 300, max_lines_count = 300, max_boxes_count = 200)

// ============================================================
// SECTION 1 - INTERNAL CONSTANTS
// ============================================================

var int STATE_IDLE = 0
var int STATE_ACTIVE = 1

var int DIR_NONE = 0
var int DIR_LONG = 1
var int DIR_SHORT = -1

var int SWEEP_NONE = 0
var int SWEEP_MINOR = 1
var int SWEEP_MAJOR = 2
var int SWEEP_FLUSH = 3
var int SWEEP_GRIND = 4

// ============================================================
// SECTION 2 - AUTO-CALIBRATION ENGINE
//
// Measures three behavioral properties of the current chart
// and derives all signal thresholds automatically.
//
// Wick-Body Ratio  - determines spike vs grind character.
//                    High ratio means price sweeps via sharp
//                    wicks. Low ratio means price grinds
//                    slowly through levels then closes back.
//
// Volume CV        - coefficient of variation in volume.
//                    High CV means volume is session-structured
//                    with clear spikes and quiet periods.
//                    Low CV means volume flows continuously.
//
// ATR Mean Pct     - average volatility rank over the window.
//                    Used to calibrate compression sensitivity
//                    relative to the instrument's own range.
//
// The Sensitivity Bias is the only user decision needed.
// It scales all auto-derived thresholds uniformly based on
// personal risk preference rather than asset class.
// ============================================================

string GRP_CAL = '── Auto-Calibration ──────────────────'

bool i_auto_cal = input.bool(defval = true, title = 'Auto-Calibration', group = GRP_CAL, tooltip = 'When ON the indicator measures the current chart ' + 'behavior and sets all thresholds automatically.\n\n' + 'Works on any asset without manual configuration. ' + 'Turn OFF only to lock thresholds to a specific ' + 'calibration snapshot.')

int i_cal_window = input.int(defval = 100, title = 'Calibration Window (bars)', minval = 50, maxval = 300, group = GRP_CAL, tooltip = 'Number of bars used to measure chart behavior.\n\n' + '100 - balanced, adapts within one session.\n' + '200 - stable, slower to adapt to regime changes.\n' + '50  - reactive, best avoided on thin history.')

string i_bias = input.string(defval = 'NEUTRAL', title = 'Sensitivity Bias', options = ['CONSERVATIVE', 'NEUTRAL', 'AGGRESSIVE'], group = GRP_CAL, tooltip = 'Scales all calibrated thresholds uniformly.\n\n' + 'CONSERVATIVE - fewer signals, stricter confirmation.\n' + 'NEUTRAL      - thresholds applied as measured.\n' + 'AGGRESSIVE   - more signals, looser confirmation.')

float BIAS_TIGHT = i_bias == 'CONSERVATIVE' ? 0.80 : i_bias == 'AGGRESSIVE' ? 1.20 : 1.00
float BIAS_LOOSE = i_bias == 'CONSERVATIVE' ? 1.20 : i_bias == 'AGGRESSIVE' ? 0.80 : 1.00

// Metric 1 - Wick-Body Ratio
// Captures whether this instrument sweeps via sharp wicks
// or via slow grinding closes through key levels.
float cal_avg_wick = ta.sma(high - math.max(open, close) + math.min(open, close) - low, i_cal_window)
float cal_avg_body = ta.sma(math.abs(close - open), i_cal_window)
float cal_wick_body_ratio = cal_avg_body > 0 ? cal_avg_wick / cal_avg_body : 1.0

// Metric 2 - Volume Coefficient of Variation
// Distinguishes session-structured volume from continuous flow.
float cal_vol_mean = ta.sma(volume, i_cal_window)
float cal_vol_std = ta.stdev(volume, i_cal_window)
float cal_volume_cv = cal_vol_mean > 0 ? cal_vol_std / cal_vol_mean : 0.5

// Metric 3 - ATR Mean Percentile
// Measures average volatility rank for compression calibration.
float cal_atr_now = ta.atr(14)
float cal_atr_hi = ta.highest(cal_atr_now, i_cal_window)
float cal_atr_lo = ta.lowest(cal_atr_now, i_cal_window)
float cal_atr_pct = cal_atr_hi - cal_atr_lo > 0 ? (cal_atr_now - cal_atr_lo) / (cal_atr_hi - cal_atr_lo) : 0.5
float cal_atr_mean = ta.sma(cal_atr_pct, i_cal_window)

// Raw threshold derivations from measured metrics
float RAW_NARROWING = math.max(math.min(0.95 - cal_atr_mean * 0.25, 0.92), 0.68)
float RAW_VACUUM = math.max(math.min(0.60 + cal_volume_cv * 0.28, 0.92), 0.55)
float RAW_WICK_MIN = math.max(math.min(cal_wick_body_ratio * 0.22, 0.55), 0.08)
float RAW_GRADIENT = math.max(math.min(0.08 + (1.0 - cal_wick_body_ratio / 3.0) * 0.18, 0.35), 0.06)

// Grind mode activates automatically on instruments that
// tend to push through levels with body closes rather than wicks.
bool ENG_GRIND = cal_wick_body_ratio < 0.85
int ENG_VOL_WINDOW = cal_volume_cv > 0.80 ? 78 : 20

// Effective thresholds with bias applied and hard range clamps
float EFF_NARROWING = i_auto_cal ? math.min(RAW_NARROWING * BIAS_LOOSE, 0.95) : 0.82
float EFF_VACUUM = i_auto_cal ? math.min(RAW_VACUUM * BIAS_LOOSE, 1.10) : 0.80
float EFF_WICK_MIN = i_auto_cal ? math.max(RAW_WICK_MIN * BIAS_TIGHT, 0.08) : 0.28
float EFF_GRADIENT = i_auto_cal ? math.max(RAW_GRADIENT * BIAS_TIGHT, 0.06) : 0.18

// ============================================================
// SECTION 3 - HTF COMPRESSION ZONES
// ============================================================

string GRP_HTF = '── HTF Compression Zones ─────────────'

string i_htf_mode = input.string(defval = '15m', title = 'HTF Reference', options = ['OFF', '5m', '10m', '15m', '30m', '45m', '1H', '2H', '4H'], group = GRP_HTF, tooltip = 'Timeframe used to detect compression zones.\n\n' + 'Crypto  5m chart -> 15m\n' + 'Futures 5m chart -> 15m or 30m\n' + 'Index   5m chart -> 30m or 1H\n\n' + 'OFF uses local pivot structure instead.')

int i_max_zones = input.int(defval = 3, title = 'Max Active Zones', minval = 1, maxval = 5, group = GRP_HTF, tooltip = 'Maximum compression zones tracked simultaneously.')

int i_zone_lifetime = input.int(defval = 40, title = 'Zone Lifetime (bars)', minval = 10, maxval = 120, group = GRP_HTF, tooltip = 'Bars before an untriggered zone expires and is removed.')

int i_min_touches = input.int(defval = 0, title = 'Min Zone Touches Before Signal', minval = 0, maxval = 3, group = GRP_HTF, tooltip = 'Zone must be tested this many times before a sweep ' + 'against it can generate a signal.\n\n' + '0 - any zone qualifies immediately.\n' + '1 - zone must have been visited once first.\n' + '2 - high-conviction tested zones only.')

bool i_show_zones = input.bool(defval = true, title = 'Show Zone Boxes', group = GRP_HTF, tooltip = 'Fresh zones appear purple. Zones tested once appear ' + 'lighter. Zones tested twice or more appear orange, ' + 'indicating the highest institutional significance.')

// ============================================================
// SECTION 4 - SWEEP DETECTION
// ============================================================

string GRP_SWEEP = '── Sweep Detection ───────────────────'

float i_wick_major = input.float(defval = 0.80, title = 'Major Sweep Wick (ATR)', minval = 0.40, maxval = 2.50, step = 0.10, group = GRP_SWEEP, tooltip = 'Wick extension beyond zone in ATR units that ' + 'qualifies as a MAJOR sweep. Anything below this ' + 'threshold is classified as MINOR.')

float i_wick_flush = input.float(defval = 1.50, title = 'Flush Sweep Wick (ATR)', minval = 1.00, maxval = 4.00, step = 0.10, group = GRP_SWEEP, tooltip = 'Wick extension that qualifies as a FLUSH sweep, ' + 'the most aggressive stop-hunt classification.')

float i_body_back = input.float(defval = 1.80, title = 'Max Body Distance From Zone (ATR)', minval = 0.50, maxval = 4.00, step = 0.10, group = GRP_SWEEP, tooltip = 'For spike sweeps the candle body must be within ' + 'this many ATR of the zone boundary. Prevents ' + 'classifying full breakout candles as sweeps.')

int i_sweep_expiry = input.int(defval = 8, title = 'Sweep Window (bars)', minval = 2, maxval = 20, group = GRP_SWEEP, tooltip = 'Bars after a sweep during which a commitment ' + 'candle can confirm the signal.')

bool i_grind_enabled = input.bool(defval = true, title = 'Enable Grind Sweep Path', group = GRP_SWEEP, tooltip = 'Detects sweeps where price slowly pushes through ' + 'a zone over several bars then closes back inside. ' + 'No spike wick required. Auto-activates on instruments ' + 'with low wick-body ratios.')

float i_grind_max_close = input.float(defval = 0.30, title = 'Grind Max Close Beyond Zone (ATR)', minval = 0.05, maxval = 1.50, step = 0.05, group = GRP_SWEEP, tooltip = 'The returning close must be within this distance ' + 'of the zone boundary. Prevents labeling a sustained ' + 'breakout run as a grind sweep.')

int i_grind_lookback = input.int(defval = 3, title = 'Grind Lookback (bars)', minval = 1, maxval = 8, group = GRP_SWEEP, tooltip = 'How many bars back to look for the grind excursion ' + 'outside the zone. 3 bars equals 15 minutes on a 5m chart.')

int i_vac_bars = input.int(defval = 1, title = 'Min Consecutive Low-Volume Bars', minval = 1, maxval = 4, group = GRP_SWEEP, tooltip = 'Volume must stay below the vacuum threshold for ' + 'this many consecutive bars before the condition activates.')

// ============================================================
// SECTION 5 - COMMITMENT CANDLE
// ============================================================

string GRP_COMMIT = '── Commitment Candle ─────────────────'

float i_commit_body = input.float(defval = 0.10, title = 'Min Body Size (ATR ratio)', minval = 0.05, maxval = 0.60, step = 0.05, group = GRP_COMMIT, tooltip = 'The confirmation candle body must be at least this ' + 'fraction of ATR. Filters doji and indecision bars.')

float i_commit_vol = input.float(defval = 0.65, title = 'Min Volume vs Average', minval = 0.30, maxval = 1.50, step = 0.05, group = GRP_COMMIT, tooltip = 'Confirmation candle volume must be at least this ' + 'ratio of the rolling average. 0.65 means 65% of average.')

bool i_close_beyond = input.bool(defval = true, title = 'Close Must Cross Zone Boundary', group = GRP_COMMIT, tooltip = 'Commitment candle must close on the signal side ' + 'of the zone. Reduces premature entries.')

bool i_two_bar_confirm = input.bool(defval = false, title = 'Two-Bar Confirmation', group = GRP_COMMIT, tooltip = 'Both the current and prior candle must close in ' + 'the signal direction. Reduces false entries on ' + 'slow-moving instruments at the cost of one bar lag.')

// ============================================================
// SECTION 6 - TRADE MANAGEMENT
// ============================================================

string GRP_TM = '── Trade Management ──────────────────'

int i_atr_len = input.int(defval = 14, title = 'ATR Length', minval = 5, maxval = 50, group = GRP_TM)

float i_sl_atr = input.float(defval = 2.00, title = 'Stop Loss Distance (ATR)', minval = 0.50, maxval = 5.00, step = 0.25, group = GRP_TM, tooltip = 'Stop loss is placed exactly this many ATR from ' + 'the entry price on every trade.\n\n' + '1.0 - tight, suits high-frequency scalping.\n' + '1.5 - standard, recommended starting point.\n' + '2.0 - wider, suits slower moving instruments.\n' + '2.5+ - wide, use on higher timeframes only.')

float i_tp1_atr = input.float(defval = 2.00, title = 'Target 1 Distance (ATR)', minval = 0.50, maxval = 6.00, step = 0.25, group = GRP_TM)

float i_tp2_atr = input.float(defval = 3.50, title = 'Target 2 Distance (ATR)', minval = 1.00, maxval = 10.0, step = 0.25, group = GRP_TM)

float i_tp1_pct = input.float(defval = 50.0, title = 'Position Closed at Target 1 (%)', minval = 10.0, maxval = 90.0, step = 5.0, group = GRP_TM, tooltip = 'Percentage of the position closed at Target 1. ' + 'The remainder runs toward Target 2.')

bool i_breakeven = input.bool(defval = false, title = 'Move Stop to Breakeven After Target 1', group = GRP_TM)

bool i_trail_on = input.bool(defval = false, title = 'Enable Trailing Stop', group = GRP_TM)

float i_trail_atr = input.float(defval = 0.80, title = 'Trailing Stop Offset (ATR)', minval = 0.20, maxval = 3.00, step = 0.10, group = GRP_TM, tooltip = 'Distance the trailing stop maintains behind the ' + 'lowest low (long) or highest high (short) of the last 4 bars.')

string i_trail_start = input.string(defval = 'TP1', title = 'Trailing Starts After', options = ['ENTRY', 'TP1'], group = GRP_TM, tooltip = 'ENTRY - trailing begins immediately on signal.\n' + 'TP1   - trailing activates only after Target 1 is hit.')

int i_timeout = input.int(defval = 40, title = 'Target 1 Timeout (bars)', minval = 5, maxval = 200, group = GRP_TM, tooltip = 'If Target 1 is not reached within this many bars ' + 'the trade closes. Prevents capital being tied up ' + 'in stalled moves.')

int i_spacing = input.int(defval = 8, title = 'Min Bars Between Signals', minval = 0, maxval = 100, group = GRP_TM, tooltip = 'Prevents consecutive signals on the same directional ' + 'impulse. 8 bars equals 40 minutes on a 5m chart. ' + 'Set to 0 to disable.')

bool i_ema_filter = input.bool(defval = true, title = 'EMA Trend Filter', group = GRP_TM, tooltip = 'Long signals only fire above the EMA. ' + 'Short signals only fire below. Aligns entries with macro bias.')

int i_ema_len = input.int(defval = 21, title = 'EMA Length', minval = 8, maxval = 200, group = GRP_TM, tooltip = '21  - fast trend reference, suits crypto.\n' + '50  - medium, suits futures.\n' + '200 - slow macro bias, suits indices.')

// ============================================================
// SECTION 7 - VISUAL SETTINGS
// ============================================================

string GRP_VIS = '── Visual Settings ───────────────────'

string i_label_mode = input.string(defval = 'MINIMAL', title = 'Signal Label Detail', options = ['OFF', 'MINIMAL', 'DETAIL'], group = GRP_VIS, tooltip = 'OFF     - no labels, use dashboard only.\n' + 'MINIMAL - direction, grade, quality score.\n' + 'DETAIL  - adds sweep type, zone price, all levels.')

bool i_show_history = input.bool(true, 'Show Historical Trade Levels', group = GRP_VIS, tooltip = 'Keeps past trade entry, stop, and target lines on ' + 'chart for reviewing signal quality historically.')
int i_max_history = input.int(30, 'Max Historical Trades Shown', minval = 10, maxval = 100, group = GRP_VIS)
bool i_show_shapes = input.bool(true, 'Quality Symbols on Signals', group = GRP_VIS, tooltip = 'PRIME = Gold Diamond   HIGH = Green Circle\n' + 'MED   = Yellow Square  LOW  = Gray X')
bool i_show_labels = input.bool(true, 'Signal Labels', group = GRP_VIS)
bool i_show_boxes = input.bool(true, 'Trade Forecast Boxes', group = GRP_VIS)
bool i_show_ema = input.bool(true, 'Show EMA Line', group = GRP_VIS)
bool i_show_trail = input.bool(true, 'Show Trailing Stop Line', group = GRP_VIS)
bool i_show_dash = input.bool(true, 'Show Dashboard Panel', group = GRP_VIS)
bool i_show_vacuum = input.bool(true, 'Highlight Vacuum Bars', group = GRP_VIS, tooltip = 'Subtle yellow tint on bars where volume vacuum is active.')
bool i_show_grind_dot = input.bool(true, 'Show Grind Sweep Markers', group = GRP_VIS, tooltip = 'Small orange triangles marking grind-path sweep bars.')

color i_c_bull = input.color(color.new(#00E676, 0), 'Bull Color', inline = 'ca', group = GRP_VIS)
color i_c_bear = input.color(color.new(#FF1744, 0), 'Bear Color', inline = 'ca', group = GRP_VIS)
color i_c_entry = input.color(color.new(#2196F3, 0), 'Entry Color', inline = 'cb', group = GRP_VIS)
color i_c_stop = input.color(color.new(#FF5252, 0), 'Stop Color', inline = 'cb', group = GRP_VIS)
color i_c_zone = input.color(color.new(#7C4DFF, 0), 'Zone Color', inline = 'cc', group = GRP_VIS)

// ============================================================
// SECTION 8 - BASE CALCULATIONS
// ============================================================

float atr_val = ta.atr(i_atr_len)
float ema_val = ta.ema(close, i_ema_len)
float vol_avg = ta.sma(volume, ENG_VOL_WINDOW)
float vol_ratio = vol_avg > 0 ? volume / vol_avg : 1.0
bool vol_ok = not na(volume) and volume > 0 and not na(vol_avg)

float body_size = math.abs(close - open)
float body_atr_r = atr_val > 0 ? body_size / atr_val : 0.0
float wick_up = high - math.max(open, close)
float wick_dn = math.min(open, close) - low

bool bull_bar = close > open
bool bear_bar = close < open

float atr_hi = ta.highest(atr_val, 100)
float atr_lo = ta.lowest(atr_val, 100)
float atr_pct = atr_hi - atr_lo > 0 ? (atr_val - atr_lo) / (atr_hi - atr_lo) : 0.5

bool trend_long = not i_ema_filter or close > ema_val
bool trend_short = not i_ema_filter or close < ema_val
bool htf_on = i_htf_mode != 'OFF'
bool confirmed = barstate.isconfirmed
bool ready = bar_index > i_cal_window and not na(atr_val) and not na(ema_val)

string htf_tf = i_htf_mode == '5m' ? '5' : i_htf_mode == '10m' ? '10' : i_htf_mode == '15m' ? '15' : i_htf_mode == '30m' ? '30' : i_htf_mode == '45m' ? '45' : i_htf_mode == '1H' ? '60' : i_htf_mode == '2H' ? '120' : i_htf_mode == '4H' ? '240' : '15'

// ============================================================
// SECTION 9 - PRESSURE GRADIENT
//
// Measures momentum shift via a 3-bar delta proxy.
// Delta per bar = (2*close - high - low) / range, normalized
// to the range -1 to +1. The gradient is the rate of change
// in delta from 2 bars ago to now, divided by 2.
// A positive gradient means buying pressure is accelerating.
// A negative gradient means selling pressure is accelerating.
// ============================================================

float delta_0 = (2 * close - high - low) / math.max(high - low, syminfo.mintick)
float delta_2 = (2 * close[2] - high[2] - low[2]) / math.max(high[2] - low[2], syminfo.mintick)
float grad = (delta_0 - delta_2) / 2.0

bool grad_long = grad > EFF_GRADIENT
bool grad_short = grad < -EFF_GRADIENT

// ============================================================
// SECTION 10 - HTF COMPRESSION ZONE DETECTION
//
// Requests higher timeframe OHLC via a single tuple call so
// all five values share the same HTF bar context. Uses
// lookahead_off on confirmed chart bars only to prevent
// intra-bar zone registration from unconfirmed HTF data.
//
// Zone colors reflect touch count:
//   Purple dim  - fresh zone, zero touches
//   Purple mid  - touched once
//   Orange      - touched twice or more, highest significance
// ============================================================

[htf_h, htf_l, htf_r, htf_r1, htf_r2] = request.security(syminfo.tickerid, htf_tf, [high, low, high - low, high[1] - low[1], high[2] - low[2]], lookahead = barmerge.lookahead_off)

float eff_htf_h = htf_on ? htf_h : na
float eff_htf_l = htf_on ? htf_l : na
float eff_htf_r = htf_on ? htf_r : na
float eff_htf_r1 = htf_on ? htf_r1 : na
float eff_htf_r2 = htf_on ? htf_r2 : na

float htf_avg_r = (eff_htf_r + eff_htf_r1 + eff_htf_r2) / 3
bool is_compress = htf_on and not na(htf_avg_r) and htf_avg_r > 0 and eff_htf_r < htf_avg_r * EFF_NARROWING

float compress_str = 0.0
if is_compress and htf_avg_r > 0
    float ratio = eff_htf_r / htf_avg_r
    compress_str := ratio < 0.55 ? 3.0 : ratio < 0.68 ? 2.0 : 1.0
    compress_str

var array<float> z_highs = array.new_float()
var array<float> z_lows = array.new_float()
var array<int> z_bars = array.new_int()
var array<float> z_str = array.new_float()
var array<int> z_touches = array.new_int()
var array<box> z_boxes = array.new_box()

// Zone registration gated on confirmed bars only to prevent
// phantom zones from unconfirmed intra-bar HTF readings.
if confirmed and is_compress
    bool new_zone = true
    if array.size(z_highs) > 0
        for i = 0 to array.size(z_highs) - 1 by 1
            if not(eff_htf_h < array.get(z_lows, i) or eff_htf_l > array.get(z_highs, i))
                new_zone := false
                break
    if new_zone
        array.unshift(z_highs, eff_htf_h)
        array.unshift(z_lows, eff_htf_l)
        array.unshift(z_bars, bar_index)
        array.unshift(z_str, compress_str)
        array.unshift(z_touches, 0)
        if i_show_zones
            box b = box.new(bar_index, eff_htf_h, bar_index + i_zone_lifetime, eff_htf_l, border_color = color.new(i_c_zone, 50), bgcolor = color.new(i_c_zone, 91))
            array.unshift(z_boxes, b)

// Touch counter gated on confirmed bars to prevent intra-bar
// price excursions from inflating zone touch counts.
if confirmed and array.size(z_highs) > 0
    for i = 0 to array.size(z_highs) - 1 by 1
        bool hit_top = high >= array.get(z_highs, i) - atr_val * 0.25 and low < array.get(z_highs, i)
        bool hit_bot = low <= array.get(z_lows, i) + atr_val * 0.25 and high > array.get(z_lows, i)
        if hit_top or hit_bot
            array.set(z_touches, i, array.get(z_touches, i) + 1)

// Expire zones that have exceeded their lifetime
if array.size(z_highs) > 0
    for i = array.size(z_highs) - 1 to 0 by 1
        if bar_index - array.get(z_bars, i) > i_zone_lifetime
            array.remove(z_highs, i)
            array.remove(z_lows, i)
            array.remove(z_bars, i)
            array.remove(z_str, i)
            array.remove(z_touches, i)
            if i_show_zones and i < array.size(z_boxes)
                box.delete(array.get(z_boxes, i))
                array.remove(z_boxes, i)

// Trim to maximum allowed zones
while array.size(z_highs) > i_max_zones
    array.pop(z_highs)
    array.pop(z_lows)
    array.pop(z_bars)
    array.pop(z_str)
    array.pop(z_touches)
    if i_show_zones and array.size(z_boxes) > 0
        box.delete(array.pop(z_boxes))

// Refresh zone box colors and extend right edge to current bar
if i_show_zones and array.size(z_boxes) > 0
    for i = 0 to array.size(z_boxes) - 1 by 1
        int t = array.get(z_touches, i)
        color zc = t >= 2 ? color.new(#FF6D00, 82) : t == 1 ? color.new(i_c_zone, 87) : color.new(i_c_zone, 91)
        box.set_bgcolor(array.get(z_boxes, i), zc)
        box.set_right(array.get(z_boxes, i), bar_index + 10)

// ============================================================
// SECTION 11 - VOLUME VACUUM
// ============================================================

var int vac_count = 0
vac_count := vol_ok and vol_ratio < EFF_VACUUM ? vac_count + 1 : 0
bool vac_active = vol_ok and vac_count >= i_vac_bars

bgcolor(i_show_vacuum and vac_active ? color.new(#FFF176, 96) : na, title = 'Volume Vacuum')

// ============================================================
// SECTION 12 - NEAREST ZONE LOOKUP
//
// Scans active zones to find the closest qualifying zone
// above and below the current price. Zones must meet the
// minimum touch requirement set by the user.
// Falls back to local pivot structure when HTF is OFF.
// ============================================================

float piv_high = ta.pivothigh(high, 7, 2)
float piv_low = ta.pivotlow(low, 7, 2)

var float fb_res = na
var float fb_sup = na

if not na(piv_high)
    fb_res := piv_high
    fb_res
if not na(piv_low)
    fb_sup := piv_low
    fb_sup

float nz_bull = na
float nz_bear = na
float nz_bull_str = 0.0
float nz_bear_str = 0.0
int nz_bull_age = 0
int nz_bear_age = 0
int nz_bull_t = 0
int nz_bear_t = 0

if htf_on and array.size(z_highs) > 0
    float bd = 1e10
    float bd2 = 1e10
    for i = 0 to array.size(z_highs) - 1 by 1
        if array.get(z_touches, i) < i_min_touches
            continue
        float zh = array.get(z_highs, i)
        float zl = array.get(z_lows, i)
        int za = bar_index - array.get(z_bars, i)
        float zs = array.get(z_str, i)
        int zt = array.get(z_touches, i)
        if zl < close and close - zl < bd
            bd := close - zl
            nz_bull := zl
            nz_bull_str := zs
            nz_bull_age := za
            nz_bull_t := zt
            nz_bull_t
        if zh > close and zh - close < bd2
            bd2 := zh - close
            nz_bear := zh
            nz_bear_str := zs
            nz_bear_age := za
            nz_bear_t := zt
            nz_bear_t
else if not htf_on
    nz_bull := fb_sup
    nz_bear := fb_res
    nz_bear

// ============================================================
// SECTION 13 - SWEEP DETECTION
//
// PATH A - SPIKE SWEEP:
//   A candle wicks through the zone boundary with a minimum
//   wick size and the body closes back near the zone.
//   This is the classic institutional stop-hunt pattern.
//
// PATH B - GRIND SWEEP:
//   Price slowly pushes through a zone over several bars
//   then a candle closes back inside the zone boundary.
//   No spike wick is required. Common on instruments with
//   low wick-body ratios such as indices and forex pairs.
// ============================================================

// Path A - Spike bull sweep
bool spike_bull = not na(nz_bull) and vac_active and low < nz_bull and close >= nz_bull - atr_val * i_body_back and wick_dn >= atr_val * EFF_WICK_MIN and grad_long

// Path A - Spike bear sweep
bool spike_bear = not na(nz_bear) and vac_active and high > nz_bear and close <= nz_bear + atr_val * i_body_back and wick_up >= atr_val * EFF_WICK_MIN and grad_short

// Path B - Grind bull sweep
bool grind_ok = i_grind_enabled or ENG_GRIND

bool grind_bull = false
if grind_ok and not na(nz_bull)
    bool was_below = false
    for k = 1 to i_grind_lookback by 1
        if low[k] < nz_bull - atr_val * 0.10
            was_below := true
            break
    grind_bull := was_below and close > nz_bull and close < nz_bull + atr_val * i_grind_max_close and bull_bar and grad_long
    grind_bull

// Path B - Grind bear sweep
bool grind_bear = false
if grind_ok and not na(nz_bear)
    bool was_above = false
    for k = 1 to i_grind_lookback by 1
        if high[k] > nz_bear + atr_val * 0.10
            was_above := true
            break
    grind_bear := was_above and close < nz_bear and close > nz_bear - atr_val * i_grind_max_close and bear_bar and grad_short
    grind_bear

// Classify spike sweep severity by wick extension in ATR units
f_classify(float wick_ext) =>
    wick_ext >= i_wick_flush ? SWEEP_FLUSH : wick_ext >= i_wick_major ? SWEEP_MAJOR : wick_ext >= EFF_WICK_MIN ? SWEEP_MINOR : SWEEP_NONE

float bull_ext = spike_bull and atr_val > 0 ? (nz_bull - low) / atr_val : 0.0
float bear_ext = spike_bear and atr_val > 0 ? (high - nz_bear) / atr_val : 0.0

int bull_class = grind_bull ? SWEEP_GRIND : spike_bull ? f_classify(bull_ext) : SWEEP_NONE
int bear_class = grind_bear ? SWEEP_GRIND : spike_bear ? f_classify(bear_ext) : SWEEP_NONE

bool bull_sweep_fired = bull_class != SWEEP_NONE
bool bear_sweep_fired = bear_class != SWEEP_NONE

f_sweep_str(int t) =>
    t == SWEEP_FLUSH ? 'FLUSH' : t == SWEEP_MAJOR ? 'MAJOR' : t == SWEEP_MINOR ? 'MINOR' : t == SWEEP_GRIND ? 'GRIND' : 'NONE'

plotshape(i_show_grind_dot and confirmed and grind_bull, 'Grind Bull', shape.triangleup, location.belowbar, color.new(#FFA726, 40), size = size.tiny)
plotshape(i_show_grind_dot and confirmed and grind_bear, 'Grind Bear', shape.triangledown, location.abovebar, color.new(#FFA726, 40), size = size.tiny)

// ============================================================
// SECTION 14 - SWEEP STATE TRACKER
//
// Stores the details of the most recent sweep detection and
// holds them open for the duration of the commitment window.
// All state writes are gated on confirmed bars to prevent
// intra-bar flicker from corrupting the sweep record.
// Once a trade enters the sweep state is cleared.
// ============================================================

var int trade_state = STATE_IDLE

var int sw_dir = DIR_NONE
var int sw_type = SWEEP_NONE
var int sw_bar = 0
var float sw_zone = na
var float sw_str = 0.0
var int sw_touch = 0
var bool sw_grind = false

if confirmed and bull_sweep_fired and trade_state == STATE_IDLE
    sw_dir := DIR_LONG
    sw_type := bull_class
    sw_bar := bar_index
    sw_zone := nz_bull
    sw_str := nz_bull_str
    sw_touch := nz_bull_t
    sw_grind := grind_bull
    sw_grind

if confirmed and bear_sweep_fired and trade_state == STATE_IDLE
    sw_dir := DIR_SHORT
    sw_type := bear_class
    sw_bar := bar_index
    sw_zone := nz_bear
    sw_str := nz_bear_str
    sw_touch := nz_bear_t
    sw_grind := grind_bear
    sw_grind

bool sw_window = sw_dir != DIR_NONE and bar_index - sw_bar <= i_sweep_expiry and trade_state == STATE_IDLE

if not sw_window and trade_state == STATE_IDLE
    sw_dir := DIR_NONE
    sw_dir

// ============================================================
// SECTION 15 - SIGNAL QUALITY SCORER
//
// Grades each signal from 0 to 10 across four dimensions.
// Scores map to grades: PRIME 8-10, HIGH 6-7, MED 4-5, LOW 0-3.
//
// Zone compression strength  0-3 points
// Sweep severity             0-3 points
// Gradient momentum          0-2 points
// Zone touch count           0-2 points
// ============================================================

f_quality_score(int sweep_t, float zone_s, float g, int touches) =>
    int s = 0
    s := s + (zone_s >= 3.0 ? 3 : zone_s >= 2.0 ? 2 : zone_s >= 1.0 ? 1 : 0)
    s := s + (sweep_t == SWEEP_FLUSH ? 3 : sweep_t == SWEEP_MAJOR ? 2 : sweep_t == SWEEP_MINOR or sweep_t == SWEEP_GRIND ? 1 : 0)
    s := s + (math.abs(g) >= 0.55 ? 2 : math.abs(g) >= 0.25 ? 1 : 0)
    s := s + (touches >= 2 ? 2 : touches >= 1 ? 1 : 0)
    math.min(s, 10)

f_quality_grade(int s) =>
    s >= 8 ? 'PRIME' : s >= 6 ? 'HIGH' : s >= 4 ? 'MED' : 'LOW'

f_quality_bar(int s) =>
    string b = ''
    for i = 1 to 10 by 1
        b := b + (i <= s ? '|' : '.')
        b
    b

// ============================================================
// SECTION 16 - COMMITMENT CANDLE VALIDATION
//
// The final gate before a signal is issued. The commitment
// candle must demonstrate directional conviction via body
// size, volume, and closing position relative to the zone.
// ============================================================

bool prior_bull_ok = not i_two_bar_confirm or close[1] > open[1] and close[1] > sw_zone
bool prior_bear_ok = not i_two_bar_confirm or close[1] < open[1] and close[1] < sw_zone

bool long_commit = confirmed and ready and sw_window and sw_dir == DIR_LONG and bull_bar and body_atr_r >= i_commit_body and vol_ok and vol_ratio >= i_commit_vol and (not i_close_beyond or close > sw_zone) and trend_long and prior_bull_ok

bool short_commit = confirmed and ready and sw_window and sw_dir == DIR_SHORT and bear_bar and body_atr_r >= i_commit_body and vol_ok and vol_ratio >= i_commit_vol and (not i_close_beyond or close < sw_zone) and trend_short and prior_bear_ok

// ============================================================
// SECTION 17 - TRADE STATE MACHINE
//
// Stop loss is placed exactly i_sl_atr units of ATR from the
// entry price in both directions. This is a single consistent
// value with no anchor or cap complexity.
// ============================================================

var int t_dir = DIR_NONE
var float t_entry = na
var float t_sl = na
var float t_tp1 = na
var float t_tp2 = na
var int t_ebar = 0
var bool t_tp1_hit = false
var bool t_tp2_hit = false
var bool t_be = false
var float t_pos = 1.0
var int t_last_sig = -999

var int sig_sweep = SWEEP_NONE
var float sig_grad = 0.0
var float sig_zone = na
var int sig_score = 0
var string sig_grade = '---'
var bool sig_grind = false

var line ln_entry = na
var line ln_sl = na
var line ln_tp1 = na
var line ln_tp2 = na
var box bx_prof1 = na
var box bx_prof2 = na
var box bx_loss = na

var array<line> hist_lines = array.new_line()
var array<box> hist_boxes = array.new_box()

var float trail_val = na
var bool trail_active = false
var color trail_col = color.gray

bool spacing_ok = i_spacing == 0 or bar_index - t_last_sig >= i_spacing

f_archive(bool keep) =>
    if not na(ln_entry)
        if keep
            array.push(hist_lines, ln_entry)
        else
            line.delete(ln_entry)
    if not na(ln_sl)
        if keep
            array.push(hist_lines, ln_sl)
        else
            line.delete(ln_sl)
    if not na(ln_tp1)
        if keep
            array.push(hist_lines, ln_tp1)
        else
            line.delete(ln_tp1)
    if not na(ln_tp2)
        if keep
            array.push(hist_lines, ln_tp2)
        else
            line.delete(ln_tp2)
    if not na(bx_prof1)
        if keep
            array.push(hist_boxes, bx_prof1)
        else
            box.delete(bx_prof1)
    if not na(bx_prof2)
        if keep
            array.push(hist_boxes, bx_prof2)
        else
            box.delete(bx_prof2)
    if not na(bx_loss)
        if keep
            array.push(hist_boxes, bx_loss)
        else
            box.delete(bx_loss)

// Long entry
if trade_state == STATE_IDLE and spacing_ok and long_commit
    f_archive(i_show_history)
    ln_entry := na
    ln_sl := na
    ln_tp1 := na
    ln_tp2 := na
    bx_prof1 := na
    bx_prof2 := na
    bx_loss := na

    trade_state := STATE_ACTIVE
    t_dir := DIR_LONG
    t_entry := close
    t_ebar := bar_index
    t_last_sig := bar_index
    sig_sweep := sw_type
    sig_grad := grad
    sig_zone := sw_zone
    sig_grind := sw_grind
    sig_score := f_quality_score(sw_type, sw_str, grad, sw_touch)
    sig_grade := f_quality_grade(sig_score)
    t_tp1_hit := false
    t_tp2_hit := false
    t_be := false
    t_pos := 1.0
    trail_val := na
    trail_active := false
    t_sl := t_entry - atr_val * i_sl_atr
    t_tp1 := t_entry + atr_val * i_tp1_atr
    t_tp2 := t_entry + atr_val * i_tp2_atr
    sw_dir := DIR_NONE
    sw_dir

// Short entry
if trade_state == STATE_IDLE and spacing_ok and short_commit
    f_archive(i_show_history)
    ln_entry := na
    ln_sl := na
    ln_tp1 := na
    ln_tp2 := na
    bx_prof1 := na
    bx_prof2 := na
    bx_loss := na

    trade_state := STATE_ACTIVE
    t_dir := DIR_SHORT
    t_entry := close
    t_ebar := bar_index
    t_last_sig := bar_index
    sig_sweep := sw_type
    sig_grad := grad
    sig_zone := sw_zone
    sig_grind := sw_grind
    sig_score := f_quality_score(sw_type, sw_str, grad, sw_touch)
    sig_grade := f_quality_grade(sig_score)
    t_tp1_hit := false
    t_tp2_hit := false
    t_be := false
    t_pos := 1.0
    trail_val := na
    trail_active := false
    t_sl := t_entry + atr_val * i_sl_atr
    t_tp1 := t_entry - atr_val * i_tp1_atr
    t_tp2 := t_entry - atr_val * i_tp2_atr
    sw_dir := DIR_NONE
    sw_dir

// ============================================================
// SECTION 18 - ACTIVE TRADE MANAGEMENT
// ============================================================

if trade_state == STATE_ACTIVE

    if not t_tp1_hit
        if t_dir == DIR_LONG and high >= t_tp1
            t_tp1_hit := true
            t_pos := 1.0 - i_tp1_pct / 100.0
            t_pos
        if t_dir == DIR_SHORT and low <= t_tp1
            t_tp1_hit := true
            t_pos := 1.0 - i_tp1_pct / 100.0
            t_pos

    if t_tp1_hit and i_breakeven and not t_be
        t_sl := t_entry
        t_be := true
        t_be

    if not t_tp2_hit
        if t_dir == DIR_LONG and high >= t_tp2
            t_tp2_hit := true
            t_tp2_hit
        if t_dir == DIR_SHORT and low <= t_tp2
            t_tp2_hit := true
            t_tp2_hit

    if i_trail_on
        bool do_trail = i_trail_start == 'ENTRY' ? true : t_tp1_hit
        if do_trail
            trail_val := t_dir == DIR_LONG ? math.max(na(trail_val) ? t_sl : trail_val, ta.lowest(low, 4) - atr_val * i_trail_atr) : math.min(na(trail_val) ? t_sl : trail_val, ta.highest(high, 4) + atr_val * i_trail_atr)
            if not na(trail_val)
                t_sl := trail_val
                trail_active := true
                trail_col := t_dir == DIR_LONG ? i_c_bull : i_c_bear
                trail_col
        else
            trail_val := na
            trail_active := false
            trail_active

    bool sl_hit = t_dir == DIR_LONG and low <= t_sl or t_dir == DIR_SHORT and high >= t_sl
    bool timed_out = not t_tp1_hit and bar_index - t_ebar > i_timeout

    if t_tp2_hit or sl_hit or timed_out

        if not na(ln_entry)
            line.set_x2(ln_entry, bar_index)
        if not na(ln_sl)
            line.set_x2(ln_sl, bar_index)
        if not na(ln_tp1)
            line.set_x2(ln_tp1, bar_index)
        if not na(ln_tp2)
            line.set_x2(ln_tp2, bar_index)
        if not na(bx_prof1)
            box.set_right(bx_prof1, bar_index)
        if not na(bx_prof2)
            box.set_right(bx_prof2, bar_index)
        if not na(bx_loss)
            box.set_right(bx_loss, bar_index)

        if i_show_history
            if not na(ln_entry)
                array.push(hist_lines, ln_entry)
            if not na(ln_sl)
                array.push(hist_lines, ln_sl)
            if not na(ln_tp1)
                array.push(hist_lines, ln_tp1)
            if not na(ln_tp2)
                array.push(hist_lines, ln_tp2)
            if not na(bx_prof1)
                array.push(hist_boxes, bx_prof1)
            if not na(bx_prof2)
                array.push(hist_boxes, bx_prof2)
            if not na(bx_loss)
                array.push(hist_boxes, bx_loss)

            while array.size(hist_lines) > i_max_history * 4
                if array.size(hist_lines) > 0
                    line.delete(array.shift(hist_lines))
            while array.size(hist_boxes) > i_max_history * 3
                if array.size(hist_boxes) > 0
                    box.delete(array.shift(hist_boxes))
        else
            if not na(ln_entry)
                line.delete(ln_entry)
            if not na(ln_sl)
                line.delete(ln_sl)
            if not na(ln_tp1)
                line.delete(ln_tp1)
            if not na(ln_tp2)
                line.delete(ln_tp2)
            if not na(bx_prof1)
                box.delete(bx_prof1)
            if not na(bx_prof2)
                box.delete(bx_prof2)
            if not na(bx_loss)
                box.delete(bx_loss)

        ln_entry := na
        ln_sl := na
        ln_tp1 := na
        ln_tp2 := na
        bx_prof1 := na
        bx_prof2 := na
        bx_loss := na

        trade_state := STATE_IDLE
        t_dir := DIR_NONE
        trail_val := na
        trail_active := false
        trail_active

// ============================================================
// SECTION 19 - SIGNAL FLAGS
// ============================================================

bool new_long = trade_state == STATE_ACTIVE and t_dir == DIR_LONG and bar_index == t_ebar
bool new_short = trade_state == STATE_ACTIVE and t_dir == DIR_SHORT and bar_index == t_ebar

// ============================================================
// SECTION 20 - SIGNAL LABELS
// ============================================================

float lbl_offset = math.max(atr_val * 2.5, 50 * syminfo.mintick)

if i_show_labels and new_long and i_label_mode != 'OFF'
    string sweep_tag = sig_grind ? 'GRIND' : f_sweep_str(sig_sweep)
    string txt_min = 'LONG  ' + sig_grade + '  ' + str.tostring(sig_score) + '/10'
    string txt_full = '[L] LONG  ' + sig_grade + '  ' + str.tostring(sig_score) + '/10\n' + 'Sweep: ' + sweep_tag + '  Zone: ' + str.tostring(sig_zone, format.mintick) + '\n' + 'TP1: ' + str.tostring(t_tp1, format.mintick) + '  TP2: ' + str.tostring(t_tp2, format.mintick) + '\n' + 'SL: ' + str.tostring(t_sl, format.mintick)
    color lc = sig_grade == 'PRIME' ? color.new(i_c_bull, 5) : sig_grade == 'HIGH' ? color.new(i_c_bull, 20) : sig_grade == 'MED' ? color.new(i_c_bull, 40) : color.new(i_c_bull, 60)
    label.new(bar_index, low - lbl_offset, i_label_mode == 'MINIMAL' ? txt_min : txt_full, xloc.bar_index, yloc.price, lc, label.style_label_up, color.white, i_label_mode == 'MINIMAL' ? size.small : size.normal)

if i_show_labels and new_short and i_label_mode != 'OFF'
    string sweep_tag = sig_grind ? 'GRIND' : f_sweep_str(sig_sweep)
    string txt_min = 'SHORT  ' + sig_grade + '  ' + str.tostring(sig_score) + '/10'
    string txt_full = '[S] SHORT  ' + sig_grade + '  ' + str.tostring(sig_score) + '/10\n' + 'Sweep: ' + sweep_tag + '  Zone: ' + str.tostring(sig_zone, format.mintick) + '\n' + 'TP1: ' + str.tostring(t_tp1, format.mintick) + '  TP2: ' + str.tostring(t_tp2, format.mintick) + '\n' + 'SL: ' + str.tostring(t_sl, format.mintick)
    color lc = sig_grade == 'PRIME' ? color.new(i_c_bear, 5) : sig_grade == 'HIGH' ? color.new(i_c_bear, 20) : sig_grade == 'MED' ? color.new(i_c_bear, 40) : color.new(i_c_bear, 60)
    label.new(bar_index, high + lbl_offset, i_label_mode == 'MINIMAL' ? txt_min : txt_full, xloc.bar_index, yloc.price, lc, label.style_label_down, color.white, i_label_mode == 'MINIMAL' ? size.small : size.normal)

// ============================================================
// SECTION 21 - TRADE FORECAST BOXES AND LINES
// ============================================================

int ext = 55

if i_show_boxes and new_long
    bx_prof1 := box.new(bar_index, t_tp1, bar_index + ext, t_entry, border_color = na, bgcolor = color.new(#00E676, 85))
    bx_prof2 := box.new(bar_index, t_tp2, bar_index + ext, t_tp1, border_color = na, bgcolor = color.new(#00E676, 90))
    bx_loss := box.new(bar_index, t_entry, bar_index + ext, t_sl, border_color = na, bgcolor = color.new(#FF1744, 85))
    ln_entry := line.new(bar_index, t_entry, bar_index + ext, t_entry, color = i_c_entry, width = 2)
    ln_sl := line.new(bar_index, t_sl, bar_index + ext, t_sl, color = i_c_stop, width = 2)
    ln_tp1 := line.new(bar_index, t_tp1, bar_index + ext, t_tp1, color = #00E676, width = 2, style = line.style_dashed)
    ln_tp2 := line.new(bar_index, t_tp2, bar_index + ext, t_tp2, color = #00E676, width = 3, style = line.style_dashed)
    ln_tp2

if i_show_boxes and new_short
    bx_prof1 := box.new(bar_index, t_entry, bar_index + ext, t_tp1, border_color = na, bgcolor = color.new(#00E676, 85))
    bx_prof2 := box.new(bar_index, t_tp1, bar_index + ext, t_tp2, border_color = na, bgcolor = color.new(#00E676, 90))
    bx_loss := box.new(bar_index, t_sl, bar_index + ext, t_entry, border_color = na, bgcolor = color.new(#FF1744, 85))
    ln_entry := line.new(bar_index, t_entry, bar_index + ext, t_entry, color = i_c_entry, width = 2)
    ln_sl := line.new(bar_index, t_sl, bar_index + ext, t_sl, color = i_c_stop, width = 2)
    ln_tp1 := line.new(bar_index, t_tp1, bar_index + ext, t_tp1, color = #00E676, width = 2, style = line.style_dashed)
    ln_tp2 := line.new(bar_index, t_tp2, bar_index + ext, t_tp2, color = #00E676, width = 3, style = line.style_dashed)
    ln_tp2

if trade_state == STATE_ACTIVE and not na(ln_entry)
    int rx = bar_index + ext
    line.set_x2(ln_entry, rx)
    line.set_x2(ln_sl, rx)
    line.set_y1(ln_sl, t_sl)
    line.set_y2(ln_sl, t_sl)
    line.set_x2(ln_tp1, rx)
    line.set_x2(ln_tp2, rx)
    if not na(bx_prof1)
        box.set_right(bx_prof1, rx)
        if t_tp1_hit
            box.set_bgcolor(bx_prof1, color.new(#00E676, 72))
    if not na(bx_prof2)
        box.set_right(bx_prof2, rx)
        if t_tp2_hit
            box.set_bgcolor(bx_prof2, color.new(#00E676, 60))
    if not na(bx_loss)
        box.set_right(bx_loss, rx)
        box.set_top(bx_loss, t_dir == DIR_LONG ? t_entry : t_sl)
        box.set_bottom(bx_loss, t_dir == DIR_LONG ? t_sl : t_entry)

// ============================================================
// SECTION 22 - QUALITY SHAPES
// ============================================================

plotshape(i_show_shapes and new_long and sig_score >= 8, 'Prime Long', shape.diamond, location.abovebar, color.new(#FFD700, 0), size = size.tiny)
plotshape(i_show_shapes and new_long and sig_score >= 6 and sig_score < 8, 'High Long', shape.circle, location.abovebar, color.new(#00E676, 0), size = size.tiny)
plotshape(i_show_shapes and new_long and sig_score >= 4 and sig_score < 6, 'Med Long', shape.square, location.abovebar, color.new(#FFD600, 0), size = size.tiny)
plotshape(i_show_shapes and new_long and sig_score < 4, 'Low Long', shape.xcross, location.abovebar, color.new(#787878, 0), size = size.tiny)
plotshape(i_show_shapes and new_short and sig_score >= 8, 'Prime Short', shape.diamond, location.belowbar, color.new(#FFD700, 0), size = size.tiny)
plotshape(i_show_shapes and new_short and sig_score >= 6 and sig_score < 8, 'High Short', shape.circle, location.belowbar, color.new(#00E676, 0), size = size.tiny)
plotshape(i_show_shapes and new_short and sig_score >= 4 and sig_score < 6, 'Med Short', shape.square, location.belowbar, color.new(#FFD600, 0), size = size.tiny)
plotshape(i_show_shapes and new_short and sig_score < 4, 'Low Short', shape.xcross, location.belowbar, color.new(#787878, 0), size = size.tiny)

// ============================================================
// SECTION 23 - EMA LINE
// ============================================================

plot(i_show_ema ? ema_val : na, 'EMA Glow', color.new(close > ema_val ? #00E676 : #FF1744, 70), linewidth = 5)
plot(i_show_ema ? ema_val : na, 'EMA', close > ema_val ? #00E676 : #FF1744, linewidth = 2)

// ============================================================
// SECTION 24 - TRAILING STOP LINE
// ============================================================

float trail_plot = trail_active ? trail_val : na
plot(i_show_trail ? trail_plot : na, 'Trail Glow', color.new(trail_col, 60), linewidth = 7, style = plot.style_linebr)
plot(i_show_trail ? trail_plot : na, 'Trail', trail_col, linewidth = 2, style = plot.style_linebr)

// ============================================================
// SECTION 25 - DASHBOARD
// ============================================================

var table dash = table.new(position.top_right, 4, 13, bgcolor = color.new(#0D0D0D, 5), border_color = color.new(#2A2A2A, 0), border_width = 1, frame_color = color.new(#3A3A3A, 0), frame_width = 2)

color DL = color.new(#787878, 0)
color DV = color.new(#E0E0E0, 0)
color DH = color.new(#FFFFFF, 0)
color DA = color.new(#1A1A2E, 0)
color DC = color.new(#141414, 0)
color DG = color.new(#00E676, 0)
color DR = color.new(#FF1744, 0)
color DY = color.new(#FFD600, 0)
color DO = color.new(#FFA726, 0)

if i_show_dash and barstate.islast

    table.cell(dash, 0, 0, 'Liquidity Echo', text_color = DH, text_size = size.small, bgcolor = DA, text_halign = text.align_left)
    table.cell(dash, 1, 0, 'BullByte', text_color = color.new(#5C6BC0, 0), text_size = size.small, bgcolor = DA)
    table.cell(dash, 2, 0, 'BIAS', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 3, 0, i_bias + (i_auto_cal ? ' AUTO' : ' LOCK'), text_color = DY, text_size = size.small, bgcolor = DA, text_halign = text.align_right)

    string st_txt = trade_state == STATE_IDLE ? 'SCANNING' : t_dir == DIR_LONG ? 'LONG ACTIVE' : 'SHORT ACTIVE'
    color st_col = trade_state == STATE_IDLE ? DY : t_dir == DIR_LONG ? DG : DR
    float risk_d = trade_state == STATE_ACTIVE ? math.abs(t_entry - t_sl) : na

    table.cell(dash, 0, 1, 'STATE', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 1, st_txt, text_color = st_col, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 1, 'SL DIST', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 1, trade_state == STATE_ACTIVE ? str.tostring(risk_d, format.mintick) + ' (' + str.tostring(i_sl_atr, '#.##') + ' ATR)' : '---', text_color = DV, text_size = size.tiny, bgcolor = DC, text_halign = text.align_right)

    table.cell(dash, 0, 2, 'HTF ZONE', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 2, htf_on ? array.size(z_highs) > 0 ? 'ACTIVE' : 'NONE' : 'OFF', text_color = htf_on and array.size(z_highs) > 0 ? color.new(i_c_zone, 0) : DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 2, 'COUNT', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 2, str.tostring(array.size(z_highs)), text_color = DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    string cp_txt = compress_str >= 3 ? 'STRONG' : compress_str >= 2 ? 'MEDIUM' : compress_str >= 1 ? 'LIGHT' : 'NONE'
    color cp_col = compress_str >= 3 ? DG : compress_str >= 2 ? DY : DL

    table.cell(dash, 0, 3, 'COMPRESS', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 1, 3, cp_txt, text_color = cp_col, text_size = size.small, bgcolor = DA)
    table.cell(dash, 2, 3, 'ATR%', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 3, 3, str.tostring(atr_pct * 100, '#.#') + '%' + (atr_pct > 0.70 ? ' HOT' : atr_pct < 0.15 ? ' FLAT' : ' NORM'), text_color = atr_pct > 0.70 ? DG : atr_pct < 0.15 ? DR : DY, text_size = size.small, bgcolor = DA, text_halign = text.align_right)

    table.cell(dash, 0, 4, 'VACUUM', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 4, vac_active ? 'ACTIVE' : 'NO', text_color = vac_active ? color.orange : DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 4, 'VOL RATIO', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 4, str.tostring(vol_ratio, '#.##') + 'x', text_color = vol_ratio >= 1.5 ? DG : vol_ratio < 0.7 ? DR : DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    string sw_d = sw_window ? f_sweep_str(sw_type) : trade_state == STATE_ACTIVE ? f_sweep_str(sig_sweep) : 'NONE'
    color sw_c = sw_d == 'FLUSH' ? DG : sw_d == 'MAJOR' ? DY : sw_d == 'GRIND' ? DO : sw_d == 'MINOR' ? DV : DL

    table.cell(dash, 0, 5, 'SWEEP', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 5, sw_d, text_color = sw_c, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 5, 'GRADIENT', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 5, str.tostring(grad, '#.##'), text_color = grad > 0.25 ? DG : grad < -0.25 ? DR : DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    string qb = trade_state == STATE_ACTIVE ? f_quality_bar(sig_score) : '----------'
    table.cell(dash, 0, 6, 'QUALITY', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 1, 6, qb, text_color = sig_score >= 8 ? DG : sig_score >= 6 ? DY : DV, text_size = size.tiny, bgcolor = DA)
    table.cell(dash, 2, 6, 'GRADE', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 3, 6, trade_state == STATE_ACTIVE ? sig_grade + '  ' + str.tostring(sig_score) + '/10' : '---', text_color = sig_grade == 'PRIME' ? DG : sig_grade == 'HIGH' ? DY : DV, text_size = size.small, bgcolor = DA, text_halign = text.align_right)

    table.cell(dash, 0, 7, 'TP1 (' + str.tostring(int(i_tp1_pct)) + '%)', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 7, trade_state == STATE_ACTIVE ? t_tp1_hit ? 'HIT' : str.tostring(t_tp1, format.mintick) : '---', text_color = t_tp1_hit ? DG : DV, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 7, 'TP2 (' + str.tostring(int(100 - i_tp1_pct)) + '%)', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 7, trade_state == STATE_ACTIVE ? t_tp2_hit ? 'HIT' : str.tostring(t_tp2, format.mintick) : '---', text_color = t_tp2_hit ? DG : DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    string sl_type = t_be ? 'BREAKEVEN' : trail_active ? 'TRAILING' : 'INITIAL'
    color sl_col = t_be ? DG : trail_active ? DY : DR

    table.cell(dash, 0, 8, 'STOP', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 8, trade_state == STATE_ACTIVE ? str.tostring(t_sl, format.mintick) : '---', text_color = DV, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 8, 'TYPE', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 8, trade_state == STATE_ACTIVE ? sl_type : '---', text_color = sl_col, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    table.cell(dash, 0, 9, 'POS REMAIN', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 1, 9, trade_state == STATE_ACTIVE ? str.tostring(t_pos * 100, '#.#') + '%' : '---', text_color = DV, text_size = size.small, bgcolor = DA)
    table.cell(dash, 2, 9, 'TRAIL', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 3, 9, i_trail_on ? i_trail_start : 'OFF', text_color = i_trail_on ? DG : DL, text_size = size.small, bgcolor = DA, text_halign = text.align_right)

    table.cell(dash, 0, 10, 'TREND', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 10, i_ema_filter ? close > ema_val ? 'BULL' : 'BEAR' : 'OFF', text_color = i_ema_filter ? close > ema_val ? DG : DR : DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 10, 'EMA ' + str.tostring(i_ema_len), text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 10, str.tostring(ema_val, format.mintick), text_color = DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

    int sw_rem = sw_window ? i_sweep_expiry - (bar_index - sw_bar) : 0
    string sw_exp = sw_window ? str.tostring(sw_rem) + ' / ' + str.tostring(i_sweep_expiry) : trade_state == STATE_ACTIVE ? 'In Trade' : '---'
    color sw_ec = sw_window ? sw_rem <= 2 ? DR : DY : DL

    table.cell(dash, 0, 11, 'SWEEP EXP', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 1, 11, sw_exp, text_color = sw_ec, text_size = size.small, bgcolor = DA)
    table.cell(dash, 2, 11, 'HTF TF', text_color = DL, text_size = size.small, bgcolor = DA)
    table.cell(dash, 3, 11, htf_on ? i_htf_mode : 'OFF', text_color = htf_on ? color.new(i_c_zone, 0) : DL, text_size = size.small, bgcolor = DA, text_halign = text.align_right)

    bool grind_on = ENG_GRIND
    string cal_status = i_auto_cal ? 'LIVE' : 'LOCKED'
    color cal_col = i_auto_cal ? DG : DY

    table.cell(dash, 0, 12, 'CALIBRATION', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 1, 12, cal_status, text_color = cal_col, text_size = size.small, bgcolor = DC)
    table.cell(dash, 2, 12, 'GRIND / SL', text_color = DL, text_size = size.small, bgcolor = DC)
    table.cell(dash, 3, 12, (grind_on ? 'G+ ' : 'G- ') + str.tostring(i_sl_atr, '#.#') + ' ATR', text_color = grind_on ? DO : DV, text_size = size.small, bgcolor = DC, text_halign = text.align_right)

// ============================================================
// SECTION 26 - ALERTS
// ============================================================

alertcondition(confirmed and new_long, 'Long Signal', 'Liquidity Echo: LONG signal')
alertcondition(confirmed and new_short, 'Short Signal', 'Liquidity Echo: SHORT signal')
alertcondition(confirmed and bull_sweep_fired, 'Bull Sweep', 'Liquidity Echo: Bullish sweep detected')
alertcondition(confirmed and bear_sweep_fired, 'Bear Sweep', 'Liquidity Echo: Bearish sweep detected')
alertcondition(confirmed and t_tp1_hit and not t_tp1_hit[1], 'Target 1 Hit', 'Liquidity Echo: TP1 reached')
alertcondition(confirmed and t_tp2_hit and not t_tp2_hit[1], 'Target 2 Hit', 'Liquidity Echo: TP2 reached')
alertcondition(confirmed and t_be and not t_be[1], 'Breakeven', 'Liquidity Echo: Breakeven active')
alertcondition(confirmed and trail_active and not trail_active[1], 'Trailing On', 'Liquidity Echo: Trailing stop active')
// ============================================================
````
