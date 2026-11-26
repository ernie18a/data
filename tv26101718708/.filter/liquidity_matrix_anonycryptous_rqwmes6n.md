# Liquidity Matrix | Anonycryptous

- url: https://www.tradingview.com/script/RqwMES6n-Liquidity-Matrix-Anonycryptous/
- type: indicator
- pine_id: PUB;b87521afc0024c02ac1837cccf1d032e
- version: 1.0

## Description

Liquidity Matrix | Anonycryptous
Description & user manual

**Credits**
The sweep detection engine in Liquidity Matrix draws conceptual inspiration from the Liquidity Sweep Filter by AlgoAlpha. The approach to identifying swing-based stop hunts, classifying sweeps by volume significance, and filtering by trend direction is based on ideas first demonstrated in their open-source script, author: AlgoAlpha (tradingview.com/u/AlgoAlpha)

---

Why this indicator is different;
Most liquidity indicators show you one thing. A zone. A sweep marker. A supply box. A trendline. Each tool tries to solve one problem, and if you want to understand the full picture, you stack five or six indicators on the same chart until it becomes unreadable.

Liquidity Matrix works differently.
It is not a signal indicator. It does not tell you when to buy or sell. It does not score your trades or track your win rate. What it does is something more fundamental: it maps the full landscape of liquidity around price, across ten independent engines, all configurable, all in one overlay.
The core idea is that liquidity drives price. Retail traders place stops at predictable locations — below swing lows, above swing highs, at equal highs and lows, at structural pivots, inside fair value gaps. Institutional participants know this. They move price to those locations, collect that liquidity, and then move in the direction they were always going. If you understand where the liquidity is, where it has already been taken, and what levels are still sitting unmitigated, you understand the context before you place a trade.

Liquidity Matrix gives you that map.
What makes it different from other multi-engine indicators is that every engine is genuinely independent. You can run just the liquidity zones. Or just the voids and HTF levels. Or every engine at once and build your own confluence system. There is no forced reading. There is no house view on what the market is doing. You bring your methodology. The indicator gives you the context to apply it.
It also does something no single-purpose tool does: it shows you the volume behind every level. Not just where the stop clusters are — but how much liquidity was there when they formed. A zone created on 2.4M volume is not the same as a zone created on 58K. The indicator makes that difference visible.

Important notice
Liquidity Matrix does not generate trading signals.
It does not tell you when to buy or sell.
It does not predict market direction.
It does not guarantee any outcome.
All trading decisions remain entirely with the user.
Always apply your own judgment and manage your own risk.

1. Overview
Liquidity Matrix is a multi-engine liquidity context indicator built around one idea: before you place a trade, understand where the liquidity is.
What it includes:
- Liquidity zones: probability-scored pivot clusters with volume intensity rendering
- Equal highs and equal lows: zones where retail stops stack at matching price levels
- Trend engine: directional band with accumulated sweep volume tracking
- Sweep detection: swing-level stop hunt identification with safe stop placement
- HTF liquidity levels: higher timeframe high/low levels as horizontal reference lines
- Dynamic trendlines: automatically detected diagonal support and resistance with touch volume
- Supply and demand zones: SMC-based structural zones with BOS conversion
- Weekend gap: Friday close reference with gap fill tracking
- Liquidity voids: fair value gaps with gradient layer fill tracking
- RSI divergence: price chart divergence detection with candle coloring and optional trailing stop
- Dashboard: live market context across all active engines

2. Liquidity zones
2.1 How they form
Liquidity zones are identified at confirmed pivot highs and lows. A pivot forms when a price extreme holds for a configurable number of bars on both sides. Each zone is scored using a probability model that weighs four factors: distance from current price, age of the zone, whether it is still fresh (untested), and the volume present at formation.
The result is a probability score from 0 to 100 displayed on the chart. A score above 70 appears in green. Between 40 and 70 it appears in gold. Below 40 it appears in red.
The fill intensity of each zone box scales automatically with the normalized volume at formation. Higher volume at creation means a fuller, more opaque box. This makes the visual weight of each zone reflect its actual significance without requiring manual evaluation.
Zones above price are BSL — buy side liquidity. These are where long stops and breakout orders sit. Zones below price are SSL — sell side liquidity. These are where short stops and breakdown orders sit.

2.2 Sweep markers
When price breaks through the bottom of a demand zone or the top of a supply zone, a circle marker appears on the chart — above the candle for a supply zone break (bearish), below the candle for a demand zone break (bullish). The zone fades to indicate the liquidity has been consumed. This is distinct from the swing sweep detection engine, which operates independently.

2.3 Settings
Pivot left and right bars control detection sensitivity. Fewer bars on the right produces faster confirmation but reduces accuracy. The volume filter removes zones that formed on below-average activity. Fresh zones only hides tested zones to keep the chart clean. Max zones controls how many active zones are held at once. The swept zone transparency and show swept toggle control what remains visible after a zone is consumed.

2.4 In practice
Look for price approaching an unmitigated zone with a high probability score on high-volume context. The higher the score and the more opaque the box, the more likely institutional interest was present at formation. When multiple zones stack closely — visible as a cluster — that price area has concentrated stop density. When a zone is swept and the circle marker appears, the liquidity at that level has been cleared. Stops are gone. The level loses its significance as a target.
Volume note: all volume values in Liquidity Matrix are expressed in the base currency of the trading pair. On BTC/USDT, the value shown is in BTC. On SOL/USDT, it is in SOL. To convert to USD equivalent, multiply by the current price. This applies to every volume label across all engines.

3. Equal highs and equal lows
3.1 How they form
Equal highs and equal lows (EQH/EQL) are zones where price has tested the same level on two or more separate occasions without closing through it. These represent areas where retail stop orders have accumulated in a predictable way. Matching swing highs create a resistance cluster with long stops resting above. Matching swing lows create a support cluster with short stops resting below.
The zones are rendered as filled boxes using a linefill between two lines. The box spans from the lower of the two matching pivots to the higher, creating a clearly visible area of concentrated liquidity.

3.2 Settings
Tolerance (ATR×) controls how precisely two pivots must match to qualify as equal. A lower tolerance requires a near-exact match. A higher tolerance allows approximate levels to be grouped. The minimum age prevents recent, unconfirmed pivots from forming zones too early. The removal mode determines whether a zone is removed when price touches the wick, the body, or the body at twice ATR distance.

3.3 In practice
An EQH/EQL zone directly above or below price is a high-probability target for a liquidity sweep. When price approaches such a level, consider whether the move has the characteristics of a stop hunt: a spike through the level, a strong close back inside, and a reversal. The volume label on each zone shows the total volume from both matching pivots combined — giving you a sense of how much liquidity is sitting there.

4. Trend engine
4.1 How it works
The trend engine calculates a rolling volatility band using ATR. When price is above the upper band, the trend direction is bullish. When price is below the lower band, it is bearish. The band tracks the dominant directional bias and changes color accordingly.
As the trend unfolds, peak and valley levels form at local turning points within the band. The engine accumulates the volume from sweep events at each of these turning points and displays it as a label on the band. The label shows the total volume cleared at that inflection point — a direct measure of how much liquidity was consumed as the trend moved through that level.

4.2 In practice
The trend direction is shown in the dashboard as bull or bear. Use this as your macro bias filter. Look for setups in the direction of the trend. The volume labels along the band show where the significant sweeps occurred — these points represent former liquidity levels that have already been consumed and are unlikely to act as targets again. The current edge of the band is where the next sweep may occur.

5. Sweep detection
5.1 How it works
The sweep detection engine monitors rolling swing highs and lows using a configurable lookback. When price spikes through a swing level on the wick and closes back inside, a sweep event is recorded. The wick must penetrate the level by at least a minimum ATR multiple. The close must reject with a minimum strength relative to the candle range. An optional EMA filter and cooldown period reduce false triggers.
Sweeps are classified as major or minor based on normalized volume. A sweep on above-average volume is marked with a solid triangle. A below-average sweep is marked with a hollow triangle.
When a sweep fires, a safe stop line is drawn at the sweep extreme — the wick tip. This is the correct location for a stop loss after a sweep, because the liquidity that was resting there has already been consumed. Placing a stop beyond a consumed sweep is placing it where no further stop hunt is likely to occur.

5.2 Settings
The wick minimum ATR multiple and minimum rejection percentage filter out weak sweeps. The EMA filter aligns sweeps with the broader trend. The cooldown prevents repeated triggers from the same level. Major sweep threshold (normalized volume) separates significant events from minor ones.

5.3 In practice
A major sweep on a significant EQH or liquidity zone is one of the cleanest setups in the indicator. Price took the liquidity, volume confirms the institutional event, and the safe stop line gives you a clear invalidation level. The smaller the distance between current price and the safe stop line, the more attractive the risk structure.

6. HTF liquidity levels
6.1 How they form
Higher timeframe high and low levels represent the largest clusters of resting liquidity on the chart. Monthly, weekly, daily, previous day, 4-hour, and 1-hour levels are supported. Each level is drawn as a horizontal line starting at the bar time of the HTF candle that created it and extending a configurable number of bars to the right.
The volume of the HTF candle is shown as a label at the right edge of the line. Higher volume on the HTF candle means more institutional activity was present when that level formed. Monthly levels have the highest opacity. Opacity decreases progressively as timeframe decreases, so the relative significance is immediately visible.

6.2 Settings
Each timeframe is individually toggleable. Line style (solid, dashed, dotted), width, and color are configurable. Extend bars controls how far the line projects to the right. The liquidity label can be hidden if a cleaner chart is preferred.

6.3 In practice
HTF levels are major liquidity magnets. Price tends to move toward unmitigated monthly and weekly highs and lows before reversing. When a HTF level aligns with a liquidity zone or EQH/EQL cluster, the confluence strengthens the case for a sweep at that level. The dashboard shows the nearest HTF level above and below current price so you can read the closest target without examining every line on the chart.

7. Dynamic trendlines
7.1 How they form
The trendline engine scans historical pivot highs and lows and finds the best-fit diagonal line across multiple touch points. A valid trendline requires at least two confirmed touches with minimal deviation, a score that weighs touch count, recency, tightness of touches, and span. The highest-scoring line for both support and resistance is drawn automatically every bar.
Volume accumulates at each confirmed touch point. The label at the end of the line shows the total accumulated volume across all touches — the more volume that has interacted with the trendline, the more significant it is as a structural level.
A channel fill renders between the support and resistance lines and changes color based on whether price is in the upper or lower half of the channel.

7.2 Settings
Pivot length controls detection sensitivity. Lookback bars limits how far back the engine searches. ATR length controls the volatility smoothing used for touch tolerance. Max violations allows lines to remain valid after a small number of wick pierces. Touch tolerance and max distance filter noise. Extend bars projects the lines forward.

7.3 In practice
A trendline with high accumulated volume and multiple tight touches is a strong structural level. When price approaches it from inside the channel, it is approaching a level where multiple institutional interactions have occurred. The volume label tells you how much. A break and retest of such a line — particularly with a sweep marker — is a high-quality location for a trade idea.

8. Supply and demand zones
8.1 How they form
Supply and demand zones are identified using structural pivot points. When a new swing high forms, a supply zone is created at that level. When a new swing low forms, a demand zone is created. Zones are sized using an ATR-based width multiplier. An overlap filter prevents duplicate zones from stacking in the same price area.
When price breaks through a zone boundary, the zone converts to a BOS line — a thin horizontal marker showing where market structure was broken. This mirrors the SMC (smart money concepts) approach where a broken supply zone confirms bullish structure, and a broken demand zone confirms bearish structure.

8.2 Settings
Swing length controls how many bars are required on each side of a pivot for zone formation. Zone width scales the height of each box relative to ATR. The midline (POI) can be toggled to show the point of interest at the center of each zone. History to keep limits the total number of visible zones. HH/LH/HL/LL labels mark each swing point with its structural context. BOS color is configurable separately from zone colors.

8.3 In practice
Supply and demand zones show you where price left an imbalance after a structural break. When a demand zone holds and price bounces from it, the zone remains valid. When price breaks through it, the BOS line marks where that structure was invalidated. These zones work best in combination with the liquidity zone engine — when both a liquidity zone and a demand zone overlap in the same price area, the confluence raises the probability of a significant reaction.
Note on terminology: liquidity zones and supply/demand zones are different concepts. Liquidity zones mark where stop orders are likely to be resting based on pivot volume and probability scoring. Supply and demand zones mark structural imbalances where price left quickly. Both can occur at the same level, but they represent different phenomena.

9. Weekend gap
9.1 How it works
The weekend gap engine records the last confirmed Friday close price and tracks whether price returns to fill that level during the following weekend and early week. On assets that trade continuously (crypto, 24/7 markets), the gap fill tracks whether price has revisited the Friday close since the weekend began.
The Friday close is drawn as a horizontal reference line extending forward into the week. The gap fill zone renders between the Friday close and price during the relevant window. A bullish gap (price above Friday close) renders in green. A bearish gap (price below Friday close) renders in red. When the gap is filled, it clears automatically.

9.2 Settings
Line style, width, and color are configurable. Extend days controls how far the Friday close line remains visible. Bull and bear gap colors are independently adjustable.

9.3 In practice
The Friday close acts as a liquidity magnet for early week price action. Markets frequently return to fill the weekend gap before continuing in the dominant direction. The dashboard shows the gap status (open, percentage, or filled) so you can monitor it without keeping the line visible on all timeframes. On CME futures charts, the gap window is literal — the market was closed and the gap in data is visible. On crypto charts, the market was open but institutional behavior around the weekly close creates the same magnetic effect.

10. Liquidity voids
10.1 How they form
A liquidity void (also called a fair value gap or imbalance) forms when price moves quickly in one direction across three consecutive candles, leaving a gap between the wick of the first candle and the wick of the third candle. No trading occurred in that gap area. Price tends to return to fill these zones as the market seeks balance.
The void is rendered as a gradient of 13 layers. Each layer fills individually as price touches it, changing to the filled color. This gives a precise view of how much of the void has been mitigated and how much remains unvisited. A volume label shows the total volume from the bars that created the void.

10.2 Settings
Mode controls whether all historical voids are shown or only the most recent N bars. Threshold (ATR×) sets the minimum gap size relative to ATR(144) — smaller values detect more voids, larger values filter to only significant imbalances. Bullish and bearish colors are independently configurable. The filled void color can be adjusted or filled voids can be removed entirely by toggling the show filled setting.

10.3 In practice
Unfilled voids below price are areas where no transactions occurred during an upward move. They act as potential support and pullback targets. Unfilled voids above price are areas where no transactions occurred during a downward move. They act as potential resistance and rally targets. When a void aligns with a liquidity zone or HTF level, the overlap represents an area with both structural significance and a gap to fill. The volume label on each void gives you a sense of how much liquidity was consumed when the void was created — larger voids on higher volume represent more significant imbalances.

11. RSI divergence
11.1 How it works
RSI divergence occurs when price and RSI move in opposite directions at swing points. A bullish divergence forms when price makes a lower low while RSI makes a higher low — momentum is increasing even though price is still falling, which often precedes a reversal upward. A bearish divergence forms when price makes a higher high while RSI makes a lower high — momentum is weakening even though price is still rising, which often precedes a reversal downward.
The engine detects these events mechanically using pivot-based RSI analysis. When a divergence is confirmed, a box is drawn directly on the price chart spanning all candles between the two pivot points. Circle markers appear at each pivot on the price candle. This keeps the divergence signal on the chart where the price action is, rather than requiring a separate RSI pane below.
Candle coloring reflects RSI momentum continuously. When RSI is above 50 and below the overbought level, candles are colored green — the gradient becomes more intense as RSI approaches the overbought threshold. The closer RSI is to overbought, the stronger the green. When RSI crosses the overbought level, coloring stops entirely — momentum is at an extreme and the gradient no longer adds information.
The same logic applies in reverse below 50. Candles are colored red with increasing intensity as RSI approaches the oversold level. When RSI crosses below the oversold threshold, coloring stops.
This means the gradient is always telling you how much room is left in the current momentum move — fully colored means RSI is just above 50 with a long runway ahead, faded means RSI is approaching an extreme. When the color disappears, the move is at full extension.
An optional trailing stop activates after a divergence is confirmed by an RSI 50 crossover. For a bullish divergence, the stop activates when RSI crosses back above 50 and trails below price using ATR distance. It closes when price breaks the stop level or RSI reaches the overbought threshold. For a bearish divergence, the stop activates on an RSI cross below 50 and trails above price until price breaks through or RSI reaches oversold.

Note: if the RSI divergence engine is disabled while a trailing stop is active, the stop line will disappear immediately without triggering a close. Do not disable the engine mid-trade while relying on the trailing stop as an active risk tool.

11.2 Settings
RSI length — period for the RSI calculation. Default 14.
Sensitivity — controls the pivot detection window. High detects more divergences using smaller pivots. Medium is the default. Low requires larger structural pivots and produces fewer but stronger signals.
Show bullish / show bearish — each direction can be toggled independently so you only see what is relevant to your current bias.
Bullish color / bearish color — the color used for the divergence box, circle markers, candle gradient, and trailing stop line.
RSI candle coloring — toggle the gradient candle coloring on or off without affecting divergence detection.
Overbought level — RSI level at which candle coloring stops on the upside. Default 70. Raise this to 80 for assets that tend to stay overbought for extended periods.
Oversold level — RSI level at which candle coloring stops on the downside. Default 30. Raise this to 20 for assets that tend to stay oversold for extended periods.
Trailing stop — toggle the trailing stop line on or off independently.
ATR length / ATR multiplier — control the sensitivity of the trailing stop. A higher multiplier gives the stop more room and reduces premature exits on volatile assets.

11.3 In practice
Use the divergence engine as a momentum context layer on top of the liquidity engines. A bullish divergence forming at an unmitigated liquidity zone or demand zone adds significant weight to the expectation of a reversal. A bearish divergence forming just below a major HTF level or supply zone suggests the move upward may be losing momentum before reaching that target.
The dashboard row shows the current divergence state — none, bullish, or bearish — so you can monitor it without inspecting the chart.
The candle gradient is the most immediately useful visual element. Watch for candles that are deeply colored — RSI has momentum but has not yet reached an extreme. When the gradient begins fading, RSI is extending. When it disappears entirely, RSI has crossed the overbought or oversold threshold and the move is at full extension. This is often where divergence begins to form on the next cycle.
For overbought and oversold levels: on assets like BTC or ETH that can sustain strong trends, consider raising the overbought level to 75 or 80 and lowering the oversold level to 20 or 25. This prevents the coloring from stopping too early during genuine momentum moves. On more volatile altcoins where RSI whipsaws frequently around the extremes, the default 70/30 setting works well.

12. Dashboard
The dashboard displays a live summary of all active engine data in one panel. It updates every bar.
Rows shown:

Header — indicator name and timeframe label.
Trend — current direction from the trend engine: bull, bear, or ranging.
Liq zones — count of active BSL and SSL zones in view.
Nearest BSL — closest buy side liquidity level above current price.
Nearest SSL — closest sell side liquidity level below current price.
Top zone — highest probability unmitigated zone and its score.
Safe SL — current safe stop level from the sweep detection engine.
ATR (14) — current ATR value for context.
HTF — section divider for higher timeframe levels.
HTF above — nearest higher timeframe level above price.
HTF below — nearest higher timeframe level below price.
Market — section divider for market context rows.
Gap — weekend gap status: off, open (direction and percentage), or filled.
TL dist — distance from the nearest active trendline in ATR multiples.
BOS/CHoCH — whether the supply/demand structure engine is active.
EQH/EQL — count of active equal high and equal low zones.
Engines — total number of active engines.
Divergence — current RSI divergence state: none, bullish, or bearish.
Anonycryptous — version reference.

Dashboard position and text size are configurable.

13. Settings overview
Liquidity zones
- Enable/disable master toggle
- Pivot left and right bars
- Volume filter threshold
- Dynamic zone width
- Show fresh only
- Show swept zones
- Swept zone transparency
- Max zones
- Bull and bear zone colors
- Midline toggle and color
- Swept zone circle marker toggle, colors, and size

Equal highs and equal lows
- Enable/disable master toggle
- Pivot lookback length
- Tolerance (ATR×)
- Minimum age
- Removal mode (wick, body, body×2)
- EQH and EQL zone colors
- Show volume label
- Show accumulated sweep volume

Trend engine
- Enable/disable master toggle
- Trend band length
- Bull and bear band colors
- Show major/minor sweep volume labels
- Major sweep normalized volume threshold

Sweep detection
- Enable/disable master toggle
- Swing lookback
- Minimum wick ATR multiple
- Minimum rejection percentage
- EMA filter toggle, length, and timeframe
- Cooldown bars
- Major sweep normalized volume threshold
- Volume filter toggle
- Bull and bear colors
- Marker size

Safe stop line
- Line style, color, and extension bars
- Glow toggle
- Auto-remove after N bars

HTF liquidity levels
- Enable/disable master toggle
- Individual toggles for monthly, weekly, daily, previous day, 4H, P4H, 1H, P1H
- Line style, width, and color
- Extend bars
- Show liquidity label

Dynamic trendlines
- Enable/disable master toggle
- Pivot length
- Lookback bars
- ATR length
- Max violations
- Touch tolerance (ATR×)
- Max slope (degrees)
- Max distance (ATR×)
- Extend bars
- Show channel fill
- Show volume on touch
- Support and resistance colors
- Line width and style

Supply and demand zones
- Enable/disable (controls zones and BOS simultaneously)
- Swing length
- Zone width (ATR×0.1)
- History to keep
- Supply and demand colors and outlines independently
- Show midline (POI)
- Midline color
- Show HH/LH/HL/LL labels
- BOS color and line width

Weekend gap
- Enable/disable master toggle
- Show gap fill and show Friday close line independently
- Extend line (days)
- Bull and bear gap colors
- Friday close line color, width, and style

Liquidity voids
- Enable/disable master toggle
- Mode (present / historical)
- Lookback bars (for present mode)
- Void threshold (ATR×)
- Bullish and bearish void colors
- Show filled voids
- Filled void color
- Show volume label

RSI divergence
- Enable/disable master toggle
- RSI length
- Sensitivity (high, medium, low)
- Show bullish and bearish independently
- Bullish and bearish colors
- RSI candle coloring toggle
- Overbought level (default 70)
- Oversold level (default 30)
- Trailing stop toggle
- ATR length and multiplier for trailing stop

Dashboard
- Enable/disable
- Position
- Size


14. How to use
The indicator does not prescribe a method. It provides context. How you use that context depends on your own approach. The following describes the logic behind combining the engines effectively.

Start with bias. The dashboard trend row shows the current directional bias. The nearest HTF levels above and below give you the macro targets. If the weekly high is the nearest HTF above price, the market may be running toward that level before reversing.
Identify the nearest liquidity. The nearest BSL and SSL rows in the dashboard show the closest unmitigated zones. These are the most likely near-term targets for price. A high-probability zone score adds weight to the expectation that price will visit that level.

Look for confluence. When a liquidity zone, an EQH/EQL cluster, an HTF level, and a void all align at the same price area, the confluence is significant. Price has multiple reasons to move to that location. Once it arrives, multiple forms of liquidity can be consumed in one move.

Read the sweep markers. When a sweep triangle fires, liquidity was taken. The safe stop line shows the consumed level. If the sweep occurred at a high-probability zone with volume confirmation, the conditions for a reversal are in place. The triangle type (solid for major, hollow for minor) tells you how significant the volume event was.

Use the gap. In the early part of the week, the weekend gap status is visible on the dashboard. If the gap is open and price is below the Friday close, price has a tendency to return to that level. This can serve as a short-term directional bias early in the week.

Check the voids. Unfilled voids represent areas the market has not yet returned to. If price is approaching an unfilled void from outside, it is approaching a zone of imbalance that the market may seek to fill. A void aligned with a swept zone or an EQH/EQL cluster adds structural weight to the expected reaction.

15. Notes
- Liquidity Matrix is a context indicator. It maps where liquidity is, where it has been taken, and what levels remain unmitigated. It does not generate entry signals.
- All volume values are in the base currency of the trading pair. BTC/USDT shows volume in BTC. SOL/USDT shows volume in SOL. Multiply by price to approximate USD value.
- The sweep detection engine uses swing-based pivots. The supply/demand BOS engine uses a separate pivot. These are independent systems with independent lookback settings.
- On lower timeframes, more engines running simultaneously increases computation. If the indicator is slow to load, reduce the number of active engines or lower lookback values.
- HTF levels require the chart timeframe to be lower than the HTF being referenced. A daily chart will not show daily HTF levels accurately.
- The dynamic trendline engine runs every bar. On very long chart histories with tight tolerances, this may produce slightly longer load times.
- The liquidity void threshold is relative to ATR(144). On assets with low average volatility, the default threshold may produce very few voids. Reduce the threshold to increase sensitivity.
- Weekend gap tracking works on all assets. On CME futures, the gap is a literal data gap. On crypto and 24/7 assets, the gap reflects the Friday close level as an institutional reference.

16. Disclaimer
This indicator by Anonycryptous is provided for educational and informational purposes only.
All outputs are based on historical price and volume data.
Past behavior does not guarantee future results.
Trading involves substantial risk of loss.
Use at your own discretion.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Anonycryptous

//@version=6

// ============================================================================
// LIQUIDITY MATRIX | Anonycryptous
// Liquidity Zones · EQH/EQL · Sweep Detection · Trend Engine · Safe Stop
// HTF Levels · Dynamic Trendlines · Supply/Demand · BOS · Weekend Gap · Voids
// ============================================================================

indicator("Liquidity Matrix | Anonycryptous",
     shorttitle       = "LIQ MATRIX | Anonycryptous",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// ============================================================================
// CONSTANTS
// ============================================================================
const color C_BULL  = #00ff00
const color C_BEAR  = #ff0000
const color C_GOLD  = #f5c518
const color C_MUTED = #8b949e
const color C_PURP  = #bb86fc
const color C_PANEL = #161b22
const color C_BG    = #0d1117
const color C_TRANS = color.rgb(0, 0, 0, 100)

// ============================================================================
// HELPER FUNCTIONS — defined here so available throughout entire script
// ============================================================================
f_lstyle(string s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

f_fmtVol(float v) =>
    v >= 1000000 ? str.format("{0,number,#.#}M", v / 1000000) :
     v >= 1000    ? str.format("{0,number,#.#}K", v / 1000)    :
     str.tostring(v, "#")

f_tlY(int x1, float y1, int x2, float y2, int x) =>
    float dx = x2 - x1
    dx == 0 ? y2 : y1 + (y2 - y1) * (x - x1) / dx

// ============================================================================
// INPUT GROUPS
// ============================================================================
const string G_ZONE  = "Liquidity Zones"
const string G_EQL   = "Equal Highs / Equal Lows"
const string G_TREND = "Trend Engine"
const string G_SWEEP = "Sweep Detection"
const string G_SL    = "Safe Stop Line"
const string G_ACC   = "Accuracy Tracker"
const string G_FILT  = "Filters"
const string G_HTF   = "HTF Liquidity Levels"
const string G_TL    = "Dynamic Trendlines"
const string G_CME   = "Weekend Gap (CME)"
const string G_SD    = "Supply / Demand + Structure"
const string G_VOID  = "Liquidity Voids"
const string G_DIV   = "RSI Divergence"
const string G_DASH  = "Dashboard"

// ============================================================================
// INPUTS — LIQUIDITY ZONES
// ============================================================================
i_zonesOn    = input.bool  (true,  "Enable Liquidity Zones",
     group=G_ZONE,
     tooltip="Master toggle for the entire Liquidity Zones engine. Turn OFF to hide all zone boxes and labels.")
i_pivLeft    = input.int   (10,    "Pivot Left Bars",
     minval=1, maxval=100, group=G_ZONE,
     tooltip="Bars to the left of a pivot required for confirmation. Higher = fewer, stronger zones.")
i_pivRight   = input.int   (2,     "Pivot Right Bars",
     minval=1, maxval=50,  group=G_ZONE,
     tooltip="Bars to the right of a pivot required for confirmation. Lower = faster signal with less lag.")
i_maxZones   = input.int   (20,    "Max Active Zones",
     minval=1, maxval=100, group=G_ZONE,
     tooltip="Maximum simultaneous active zones. Oldest removed when limit is exceeded.")
i_volFilter  = input.string("Mid", "Volume Strength Filter",
     options=["Off","Low","Mid","High"], group=G_ZONE,
     tooltip="Filter zones by volume at pivot creation. Off = all pivots shown. Low/Mid/High = only above that volume threshold.")
i_dynamic    = input.bool  (false, "Dynamic Zone Width",
     group=G_ZONE,
     tooltip="When ON, zone width scales with normalized volume strength. When OFF, uses fixed ATR-based width.")
i_zoneATR    = input.float (0.5,   "Zone Width (ATR×)",
     minval=0.05, step=0.05, group=G_ZONE,
     tooltip="Zone height as ATR multiple. Only used when Dynamic Zone Width is OFF.")
i_showMid    = input.bool  (false, "Show Midline",
     group=G_ZONE,
     tooltip="Draws a dashed midline through each zone at the midpoint between top and bottom.")
i_showVol    = input.bool  (true,  "Show Volume on Zones",
     group=G_ZONE,
     tooltip="Displays the formatted volume at zone creation as a label.")
i_freshOnly  = input.bool  (false, "Fresh Zones Only",
     group=G_ZONE,
     tooltip="When ON, only zones that price has never touched are visible. Tested and swept zones become fully invisible (still tracked internally).")
i_showSwept  = input.bool  (true,  "Show Swept Zones (faded)",
     group=G_ZONE,
     tooltip="Keep swept zones visible as faded boxes. Ignored when Fresh Zones Only is ON.")
i_sweptAlpha = input.int   (90,    "Swept Zone Transparency",
     minval=50, maxval=99, group=G_ZONE,
     tooltip="Transparency of swept zones. Higher = more faded.")
i_bullCol    = input.color (color.new(#00ff00, 90), "Demand Zone Color",
     group=G_ZONE, inline="zc")
i_bearCol    = input.color (color.new(#ff0000, 90), "Supply Zone Color",
     group=G_ZONE, inline="zc")
i_midCol     = input.color (#f8f8fa, "Midline Color",
     group=G_ZONE,
     tooltip="Color of the optional midline drawn through each zone.")
i_sweptDot   = input.bool  (true,  "Show Swept Zone Marker",
     group=G_ZONE,
     tooltip="Draws a circle dot on the bar that sweeps a zone. Supply sweep = above candle (bear color). Demand sweep = below candle (bull color).")
i_sweptDotBC = input.color (color.new(#ff0000, 0), "Supply Swept Color",
     group=G_ZONE, inline="sdc")
i_sweptDotGC = input.color (color.new(#00ff00, 0), "Demand Swept Color",
     group=G_ZONE, inline="sdc")
i_sweptDotSz = input.string("Tiny", "Marker Size",
     options=["Tiny","Small","Normal"], group=G_ZONE,
     tooltip="Size of the circle marker on swept zone bars.")

// ============================================================================
// INPUTS — EQUAL HIGHS / LOWS
// ============================================================================
i_eqlOn      = input.bool  (false,   "Show Equal Highs/Lows",
     group=G_EQL,
     tooltip="Detects equal highs and lows — the most predictable retail stop clusters. Drawn as filled zones between matching pivot prices.")
i_eqlThresh  = input.float (0.03,   "Equality Threshold (%)",
     minval=0.001, step=0.001, group=G_EQL,
     tooltip="Maximum % difference between two pivots to be considered equal. Lower = stricter. 0.03 works well for most assets.")
i_eqlAge     = input.int   (500,    "Max Zone Age (bars)",
     minval=10, group=G_EQL,
     tooltip="Number of bars after which an EQH/EQL zone is automatically removed regardless of price action.")
i_eqlRemove  = input.string("Wick", "Remove On",
     options=["Wick","Body","Body×2"], group=G_EQL,
     tooltip="Wick: removed when price wick touches the level. Body: removed when a close crosses it. Body×2: requires two consecutive closes beyond the level.")
i_eqlShowVol = input.bool  (true,   "Show Volume on EQL/EQH",
     group=G_EQL,
     tooltip="Shows the total volume from both matching pivots on the EQH/EQL zone label.")
i_eqlShowLiq = input.bool  (true,   "Show Accumulated Sweep Volume",
     group=G_EQL,
     tooltip="When a zone is swept, shows the total liquidity volume that was cleared at that level.")
i_eqlHCol    = input.color (color.new(#f23645, 70), "EQH Color",
     group=G_EQL, inline="eqc")
i_eqlLCol    = input.color (color.new(#089981, 70), "EQL Color",
     group=G_EQL, inline="eqc")

// ============================================================================
// INPUTS — TREND ENGINE
// ============================================================================
i_trendOn    = input.bool  (true, "Enable Trend Engine",
     group=G_TREND,
     tooltip="Master toggle for the Trend Engine. Controls trend band, sweep volume accumulation labels, and major/minor sweep classification.")
i_trendLen   = input.int   (12,   "Trend Length",
     minval=1, group=G_TREND,
     tooltip="Number of periods for the trend band calculation. Higher = smoother, longer-term trend signal.")
i_trendMult  = input.float (2.0,  "Trend Multiplier",
     minval=0.1, step=0.1, group=G_TREND,
     tooltip="Multiplier for the deviation band. Higher = wider band, more resistant to noise and fewer trend changes.")
i_showTrend  = input.bool  (true, "Show Trend Line",
     group=G_TREND,
     tooltip="Draws the upper band in downtrend and lower band in uptrend as a colored line on the chart.")
i_mjrThresh  = input.float (50.0, "Major Sweep Threshold",
     minval=0, maxval=100, group=G_TREND,
     tooltip="Normalized volume threshold (0-100) that separates major from minor sweep events. Higher = only the largest volume sweeps count as major.")
i_showMjr    = input.bool  (true, "Show Major Sweep Labels",
     group=G_TREND,
     tooltip="Shows volume labels for major sweeps (normalized volume above the Major Sweep Threshold).")
i_showMnr    = input.bool  (true, "Show Minor Sweep Labels",
     group=G_TREND,
     tooltip="Shows volume labels for minor sweeps (normalized volume below the Major Sweep Threshold).")
i_bullTrC    = input.color (color.new(#00ff00, 30), "Bull Trend Color",
     group=G_TREND, inline="tc")
i_bearTrC    = input.color (color.new(#ff0000, 30), "Bear Trend Color",
     group=G_TREND, inline="tc")

// ============================================================================
// INPUTS — SWEEP DETECTION
// ============================================================================
i_sweepOn    = input.bool  (true,         "Enable Sweep Detection",
     group=G_SWEEP,
     tooltip="Master toggle for swing-level sweep detection. Controls triangle markers, safe stop line, and accuracy tracker.")
i_swingLen   = input.int   (5,            "Swing Lookback",
     minval=1, maxval=50, group=G_SWEEP,
     tooltip="Number of bars used to identify swing reference levels for sweep detection. Higher = fewer but stronger sweep reference points.")
i_sweepMode  = input.string("Only Wicks", "Sweep Mode",
     options=["Only Wicks","Wicks + Breakouts"], group=G_SWEEP,
     tooltip="Only Wicks: sweep triggers on wick-and-close-back only. Wicks + Breakouts: also detects confirmed breakout retests.")
i_minWick    = input.float (0.1,          "Min Wick Penetration (ATR×)",
     minval=0.01, step=0.05, group=G_SWEEP,
     tooltip="Minimum distance price must wick beyond the swing level in ATR units. Filters insignificant pokes.")
i_minRej     = input.float (5.0,          "Min Wick Rejection %",
     minval=1.0, maxval=95.0, step=1.0, group=G_SWEEP,
     tooltip="Minimum % of the candle's total range that must be wick (not body) for a sweep to qualify.")
i_cooldown   = input.int   (3,            "Cooldown (bars)",
     minval=0, maxval=50, group=G_SWEEP,
     tooltip="Minimum bars between two sweep signals in the same direction. Prevents repeated signals on choppy price.")
i_bullSwpC   = input.color (color.new(#00ff00, 0), "Bull Sweep Color",
     group=G_SWEEP, inline="swc")
i_bearSwpC   = input.color (color.new(#ff0000, 0), "Bear Sweep Color",
     group=G_SWEEP, inline="swc")

// ============================================================================
// INPUTS — SAFE STOP LINE
// ============================================================================
i_slOn       = input.bool  (true,          "Show Safe Stop Line",
     group=G_SL,
     tooltip="After a confirmed sweep, draws a safe stop loss level beyond the swept wick. Retail stops at that cluster have already been cleared — your stop here avoids the next pool.")
i_slExpire   = input.string("Until Price", "Line Expires",
     options=["Until Price","X Bars","New Sweep"], group=G_SL,
     tooltip="Until Price: line stays until price reaches it. X Bars: disappears after N bars. New Sweep: removed when a new sweep in the same direction is detected.")
i_slBars     = input.int   (50,            "Expire After N Bars",
     minval=1, maxval=1000, group=G_SL,
     tooltip="Only used when 'Line Expires' is set to X Bars.")
i_slBuf      = input.float (0.5,           "ATR Buffer Beyond Wick",
     minval=0.0, step=0.05, group=G_SL,
     tooltip="Extra ATR distance added beyond the wick tip. Gives breathing room past the already-cleared liquidity cluster.")
i_slStyle    = input.string("Solid",       "Line Style",
     options=["Solid","Dashed","Dotted"], group=G_SL, inline="sls",
     tooltip="Visual style of the safe stop line.")
i_slWidth    = input.int   (1,             "Width",
     minval=1, maxval=4, group=G_SL, inline="sls",
     tooltip="Line width of the safe stop line.")
i_slBullC    = input.color (color.new(#fcfdfc, 0), "Bull SL Color",
     group=G_SL, inline="slc")
i_slBearC    = input.color (color.new(#fcfdfc, 0), "Bear SL Color",
     group=G_SL, inline="slc")
i_slGlow     = input.bool  (true,          "Glow Effect",
     group=G_SL,
     tooltip="Adds a wider semi-transparent line behind the SL line for visual emphasis.")

// ============================================================================
// INPUTS — ACCURACY TRACKER
// ============================================================================
i_accOn      = input.bool  (true, "Enable Accuracy Tracking",
     group=G_ACC,
     tooltip="Tracks whether each sweep was followed by a reversal (correct) or continuation (incorrect). Builds a live win rate in the dashboard.")
i_accWindow  = input.int   (10,   "Outcome Window (bars)",
     minval=3, maxval=100, group=G_ACC,
     tooltip="How many bars after a sweep before the outcome is judged.")
i_accMove    = input.float (1.0,  "Min Reversal Move (ATR×)",
     minval=0.1, step=0.1, group=G_ACC,
     tooltip="Minimum ATR move in the expected reversal direction to count the sweep as a correct call.")

// ============================================================================
// INPUTS — FILTERS
// ============================================================================
i_volFilt    = input.bool  (true,  "Volume Filter on Sweeps",
     group=G_FILT,
     tooltip="Only register sweeps where the sweep bar volume exceeds the moving average by the multiplier below.")
i_volMult    = input.float (1.2,   "Volume Multiplier",
     minval=1.0, step=0.1, group=G_FILT,
     tooltip="Sweep bar volume must be at least this multiple of the volume moving average.")
i_volLen     = input.int   (20,    "Volume MA Length",
     minval=5, group=G_FILT,
     tooltip="Lookback period for the volume moving average used in zone and sweep filters.")
i_emaFilt    = input.bool  (false, "EMA Trend Filter",
     group=G_FILT,
     tooltip="When ON, only shows bull sweeps below the EMA and bear sweeps above it. Keeps signals aligned with dominant trend.")
i_emaLen     = input.int   (200,   "EMA Length",
     minval=10, group=G_FILT,
     tooltip="Length of the EMA used for trend direction filtering.")
i_emaTF      = input.timeframe("", "EMA Timeframe",
     group=G_FILT,
     tooltip="Timeframe for the EMA. Leave blank to use the current chart timeframe.")

// ============================================================================
// INPUTS — HTF LIQUIDITY LEVELS
// ============================================================================
i_htfOn      = input.bool  (true,   "Enable HTF Levels",
     group=G_HTF,
     tooltip="Draws key higher timeframe high/low levels as horizontal lines. Each represents a major liquidity pool where stops are concentrated.")
i_htfStyle   = input.string("Solid", "Line Style",
     options=["Solid","Dashed","Dotted"], group=G_HTF, inline="htfs",
     tooltip="Visual style of all HTF level lines.")
i_htfWidth   = input.int   (1,       "Width",
     minval=1, maxval=4, group=G_HTF, inline="htfs",
     tooltip="Line width of HTF level lines.")
i_htfCol     = input.color (color.new(#ff6d00, 15), "Line Color",
     group=G_HTF,
     tooltip="Color for HTF lines. Each timeframe uses this at varying transparency — higher TF = more opaque.")
i_htfShowVol = input.bool  (true,    "Show Liquidity Label",
     group=G_HTF,
     tooltip="Shows the volume of the HTF candle next to the level. Higher volume = more stops accumulated there.")
i_htfM       = input.bool  (false, "Monthly H/L",   group=G_HTF, inline="htf1",
     tooltip="Previous monthly high and low — strongest major liquidity levels.")
i_htfW       = input.bool  (false, "Weekly H/L",    group=G_HTF, inline="htf1",
     tooltip="Previous weekly high and low — major institutional reference levels.")
i_htfD       = input.bool  (false, "Daily H/L",     group=G_HTF, inline="htf2",
     tooltip="Previous daily high and low — most commonly targeted intraday liquidity pools.")
i_htfPD      = input.bool  (true, "Prev Day H/L",  group=G_HTF, inline="htf2",
     tooltip="Yesterday's confirmed high and low — primary targets for early session sweeps.")
i_htf4H      = input.bool  (false, "4H H/L",        group=G_HTF, inline="htf3",
     tooltip="Previous 4-hour high and low — intermediate swing liquidity.")
i_htfP4H     = input.bool  (true, "P4H H/L",       group=G_HTF, inline="htf3",
     tooltip="The 4-hour candle before the previous one — useful for spotting stacked liquidity levels.")
i_htf1H      = input.bool  (false, "1H H/L",        group=G_HTF, inline="htf4",
     tooltip="Previous 1-hour high and low — short-term liquidity clusters.")
i_htfP1H     = input.bool  (false, "P1H H/L",       group=G_HTF, inline="htf4",
     tooltip="The 1-hour candle before the previous one — useful for spotting stacked short-term liquidity.")
i_htfExtend  = input.int   (10,   "Extend Bars Right",
     minval=1, maxval=500, group=G_HTF,
     tooltip="How many bars to the right of the current bar the HTF lines extend. Labels appear at the end of the line.")

// ============================================================================
// INPUTS — DYNAMIC TRENDLINES
// ============================================================================
i_tlOn          = input.bool  (true,  "Enable Trendlines",
     group=G_TL,
     tooltip="Automatically detects the strongest diagonal support and resistance trendlines based on pivot scoring. Lines where retail stops cluster along the diagonal.")
i_tlPivLen      = input.int   (10,    "Pivot Length",
     minval=2, group=G_TL,
     tooltip="Sensitivity for pivot anchor detection. Lower = more pivots found, shorter-term lines. Higher = fewer, stronger structural lines.")
i_tlLookback    = input.int   (500,   "Lookback Bars",
     minval=50, group=G_TL,
     tooltip="How many historical bars the engine scans for trendline anchors.")
i_tlATRLen      = input.int   (100,   "ATR Length",
     minval=10, group=G_TL,
     tooltip="Smoothing period for volatility used in trendline scoring and tolerance.")
i_tlMaxViol     = input.int   (2,     "Max Violations",
     minval=0, maxval=10, group=G_TL,
     tooltip="How many times price can pierce the trendline before it is invalidated and removed.")
i_tlTouchTol    = input.float (0.30,  "Touch Tolerance (ATR×)",
     step=0.05, group=G_TL,
     tooltip="How precisely a pivot must touch the trendline to count as a valid confirmation touch.")
i_tlMaxSlope    = input.float (6.0,   "Max Angle (°)",
     step=1.0, group=G_TL,
     tooltip="Maximum allowed slope in degrees. Prevents unrealistically steep trendlines.")
i_tlMaxDist     = input.float (8.0,   "Max Distance (ATR×)",
     step=0.5, group=G_TL,
     tooltip="Only shows trendlines within this ATR distance from current price. Keeps chart clean.")
i_tlExtend      = input.int   (60,    "Extend Bars",
     minval=10, group=G_TL,
     tooltip="How many bars the trendline projects into the future.")
i_tlShowFill    = input.bool  (true,  "Show Channel Fill",
     group=G_TL,
     tooltip="Fills the area between support and resistance trendlines with a subtle color.")
i_tlShowVol     = input.bool  (true,  "Show Volume on Touch",
     group=G_TL,
     tooltip="Shows accumulated volume at each confirmed trendline touch — indicates how much liquidity is sitting on the line.")
i_tlSupCol      = input.color (color.new(#2323FF, 15), "Support Color",
     group=G_TL, inline="tlc",
     tooltip="Color for the diagonal support trendline.")
i_tlResCol      = input.color (color.new(#2323FF, 15), "Resistance Color",
     group=G_TL, inline="tlc",
     tooltip="Color for the diagonal resistance trendline.")
i_tlWidth       = input.int   (1,     "Width",
     minval=1, maxval=4, group=G_TL, inline="tlc",
     tooltip="Line width of the trendlines.")
i_tlStyle       = input.string("Solid","Style",
     options=["Solid","Dashed","Dotted"], group=G_TL,
     tooltip="Visual style of the trendlines.")

// ============================================================================
// INPUTS — WEEKEND GAP (CME)
// ============================================================================
i_cmeOn      = input.bool  (false, "Enable Weekend Gap",
     group=G_CME,
     tooltip="Shows the gap between the Friday close and the current price during the weekend and early Monday. Works on all assets — not just CME futures. Every asset has a Friday close and potential weekend manipulation.")
i_cmeFillOn  = input.bool  (true,  "Show Gap Fill",
     group=G_CME,
     tooltip="Fills the area between the Friday close level and current price with a gradient color.")
i_cmeLineOn  = input.bool  (true,  "Show Friday Close Line",
     group=G_CME,
     tooltip="Draws the Friday close as a horizontal level that acts as a liquidity magnet for the following week.")
i_cmeExtend  = input.int   (5,     "Extend Line (Days)",
     minval=1, maxval=30, group=G_CME,
     tooltip="How many days into the week the Friday close line extends as a reference level.")
i_cmeBullC   = input.color (color.new(#089981, 70), "Bull Gap Color",
     group=G_CME, inline="cmec",
     tooltip="Color when price is above Friday close (gap up).")
i_cmeBearC   = input.color (color.new(#f23645, 70), "Bear Gap Color",
     group=G_CME, inline="cmec",
     tooltip="Color when price is below Friday close (gap down).")
i_cmeLineC   = input.color (color.new(#f5c518, 30), "Line Color",
     group=G_CME,
     tooltip="Color of the Friday close reference line.")
i_cmeWidth   = input.int   (1,     "Line Width",
     minval=1, maxval=4, group=G_CME,
     tooltip="Width of the Friday close line.")
i_cmeStyle   = input.string("Dashed", "Line Style",
     options=["Solid","Dashed","Dotted"], group=G_CME,
     tooltip="Style of the Friday close line.")

// ============================================================================
// INPUTS — SUPPLY / DEMAND ZONES
// ============================================================================
i_sdOn       = input.bool  (false, "Enable Supply/Demand + BOS",
     group=G_SD,
     tooltip="Draws supply zones at swing highs and demand zones at swing lows. When price breaks a zone it converts to a BOS line.")
i_sdHistory  = input.int   (5,   "History To Keep",
     minval=5, maxval=50, group=G_SD)
i_sdWidth    = input.float (5.0,  "Zone Width (ATR×0.1)",
     minval=0.5, maxval=10.0, step=0.5, group=G_SD)
i_sdSupplyCol = input.color(color.new(#f23645, 80), "Supply Color",
     group=G_SD, inline="sdc")
i_sdSupplyOut = input.color(color.new(#f23645, 20), "Outline",
     group=G_SD, inline="sdc")
i_sdDemandCol = input.color(color.new(#089981, 80), "Demand Color",
     group=G_SD, inline="sdd")
i_sdDemandOut = input.color(color.new(#089981, 20), "Outline",
     group=G_SD, inline="sdd")
i_sdMidline  = input.bool  (true, "Show Midline",
     group=G_SD)
i_sdMidCol   = input.color (color.new(#ffffff, 90), "Midline Color",
     group=G_SD)
i_smcLen     = input.int   (10,   "Swing Length",
     minval=1, maxval=50, group=G_SD)
i_smcLabels  = input.bool  (false, "Show HH/LH/HL/LL Labels",
     group=G_SD)
i_bosCol     = input.color (color.new(#f5c518, 0), "BOS Color",
     group=G_SD)
i_smcWidth   = input.int   (1,    "BOS Line Width",
     minval=1, maxval=3, group=G_SD)

// convenience aliases so engine code compiles
i_smcOn   = i_sdOn
i_chochCol = i_bosCol

// ============================================================================
// INPUTS — LIQUIDITY VOIDS
// ============================================================================
i_voidOn   = input.bool  (false,  "Enable Liquidity Voids",
     group=G_VOID,
     tooltip="Detects Fair Value Gaps — areas where price moved rapidly without retest. Divided into 13 gradient layers that fill individually as price returns.")
i_voidMode = input.string("Historical", "Mode",
     options=["Present","Historical"], group=G_VOID, inline="vmod",
     tooltip="Present: only shows voids from last N bars. Historical: shows all detected voids.")
i_voidBack = input.int   (360,  " # Bars",
     minval=100, maxval=5000, step=10, group=G_VOID, inline="vmod")
i_voidTH   = input.float (0.5,  "Void Threshold (ATR×)",
     minval=0.0, step=0.1, group=G_VOID,
     tooltip="Minimum gap size as a multiple of ATR(144). Higher = only large imbalances shown.")
i_voidBC   = input.color (color.new(#089981, 73), "Bullish",
     group=G_VOID, inline="vdc",
     tooltip="Color for bullish voids (gap up — price left a vacuum below).")
i_voidSC   = input.color (color.new(#f23645, 73), "Bearish",
     group=G_VOID, inline="vdc",
     tooltip="Color for bearish voids (gap down — price left a vacuum above).")
i_voidVF   = input.bool  (true,  "Show Filled Voids",
     group=G_VOID, inline="vfl",
     tooltip="When a void layer is touched by price, change its color instead of deleting it.")
i_voidFC   = input.color (color.new(#787b86, 73), "",
     group=G_VOID, inline="vfl",
     tooltip="Color of void layers that have been filled by price.")
i_voidVol  = input.bool  (true,  "Show Volume Label",
     group=G_VOID,
     tooltip="Shows the total volume accumulated within the void area as a liquidity indicator.")

// ============================================================================
// INPUTS — RSI DIVERGENCE
// ============================================================================
i_divOn      = input.bool  (false, "Enable RSI Divergence",
     group=G_DIV,
     tooltip="Detects RSI divergence and marks it directly on the price chart. Bullish divergence: price makes lower low, RSI makes higher low. Bearish divergence: price makes higher high, RSI makes lower high.")
i_divRsiLen  = input.int   (14,   "RSI Length",
     minval=1, group=G_DIV)
i_divSens    = input.string("Medium", "Sensitivity",
     options=["High","Medium","Low"], group=G_DIV,
     tooltip="Controls pivot detection window. High = more signals, lower accuracy. Low = fewer signals, higher accuracy.")
i_divBull    = input.bool  (true, "Show Bullish",  group=G_DIV, inline="divs")
i_divBear    = input.bool  (true, "Show Bearish",  group=G_DIV, inline="divs")
i_divBullC   = input.color (color.new(#089981, 0), "Bullish Color", group=G_DIV, inline="divc")
i_divBearC   = input.color (color.new(#f23645, 0), "Bearish Color", group=G_DIV, inline="divc")
i_divCandles = input.bool  (true, "RSI Candle Coloring",
     group=G_DIV,
     tooltip="Colors candles based on RSI position. Gradient green when RSI is above 50, gradient red when below 50. Stops coloring when RSI reaches overbought (70) or oversold (30).")
i_divTrail   = input.bool  (false, "Show Trailing Stop",
     group=G_DIV,
     tooltip="Activates a trailing ATR stop after divergence + RSI 50 crossover confirmation. Toggleable.")
i_divATRLen  = input.int   (14,   "ATR Length",   minval=1, group=G_DIV, inline="divt")
i_divATRMult = input.float (2.0,  "ATR Multiplier", minval=0.1, step=0.1, group=G_DIV, inline="divt")
i_divOB      = input.int   (70,   "Overbought Level",
     minval=60, maxval=90, group=G_DIV,
     tooltip="RSI level considered overbought. Candle coloring stops here. Default 70, lower for more sensitive assets.")
i_divOS      = input.int   (30,   "Oversold Level",
     minval=10, maxval=40, group=G_DIV,
     tooltip="RSI level considered oversold. Candle coloring stops here. Default 30, higher for more sensitive assets.")

// ============================================================================
// INPUTS — DASHBOARD
// ============================================================================
i_dash       = input.bool  (true,          "Show Dashboard",  group=G_DASH)
i_dashPos    = input.string("Bottom Right","Position",        group=G_DASH,
     options=["Top Right","Top Left","Bottom Right","Bottom Left"])
i_dashSize   = input.string("Tiny",        "Size",            group=G_DASH,
     options=["Tiny","Small","Normal"])


// ============================================================================
// CORE CALCULATIONS
// ============================================================================
atr14    = ta.atr(14)
atr200   = ta.atr(200)
volMA    = ta.sma(volume, i_volLen)
emaVal   = request.security(syminfo.tickerid, i_emaTF, ta.ema(close, i_emaLen))

// Normalized volume 0-100 within rolling window
volLen2  = int(i_trendLen * i_trendMult)
nvol     = (volume - ta.lowest(volume, math.max(2, volLen2))) /
           math.max(syminfo.mintick, ta.highest(volume, math.max(2, volLen2)) -
           ta.lowest(volume, math.max(2, volLen2))) * 100

// Trend engine — SMA of EMA + deviation band
trendSrc  = close
trendBasis = ta.sma(ta.ema(trendSrc, i_trendLen), i_trendLen)
trendDev   = ta.ema(math.abs(close - trendBasis), i_trendLen * 3) * i_trendMult
trendUpper = trendBasis + trendDev
trendLower = trendBasis - trendDev

var float trendDir = 0.0
if close > trendUpper
    trendDir := 1.0
if close < trendLower
    trendDir := -1.0

// Volume threshold for zones
volThresh = switch i_volFilter
    "Off"  => 0.0
    "Low"  => 1.0
    "Mid"  => 1.5
    "High" => 2.5
    => 0.0

// ============================================================================
// HTF DATA — price + time of the HTF candle (Key Levels approach)
// ============================================================================

// Monthly — previous month high/low + time
[mTime,  mHigh, mLow, mVol]  = request.security(syminfo.tickerid, "M",
     [time[1], high[1], low[1], volume[1]], lookahead=barmerge.lookahead_on)

// Weekly
[wTime,  wHigh, wLow, wVol]  = request.security(syminfo.tickerid, "W",
     [time[1], high[1], low[1], volume[1]], lookahead=barmerge.lookahead_on)

// Daily
[dTime,  dHigh, dLow, dVol]  = request.security(syminfo.tickerid, "D",
     [time[1], high[1], low[1], volume[1]], lookahead=barmerge.lookahead_on)

// Previous Day
[pdTime, pdHigh, pdLow, pdVol] = request.security(syminfo.tickerid, "D",
     [time[2], high[2], low[2], volume[2]], lookahead=barmerge.lookahead_on)

// 4H
[h4Time, h4High, h4Low, h4Vol] = request.security(syminfo.tickerid, "240",
     [time[1], high[1], low[1], volume[1]], lookahead=barmerge.lookahead_on)

// Previous 4H
[p4hTime, p4hHigh, p4hLow, p4hVol] = request.security(syminfo.tickerid, "240",
     [time[2], high[2], low[2], volume[2]], lookahead=barmerge.lookahead_on)

// 1H
[h1Time, h1High, h1Low, h1Vol] = request.security(syminfo.tickerid, "60",
     [time[1], high[1], low[1], volume[1]], lookahead=barmerge.lookahead_on)

// Previous 1H
[p1hTime, p1hHigh, p1hLow, p1hVol] = request.security(syminfo.tickerid, "60",
     [time[2], high[2], low[2], volume[2]], lookahead=barmerge.lookahead_on)

// ============================================================================
// HTF LINES — persistent, updated on last bar
// ============================================================================
var line htfMH = na, var line htfML = na
var line htfWH = na, var line htfWL = na
var line htfDH = na, var line htfDL = na
var line htfPDH = na, var line htfPDL = na
var line htf4HH = na, var line htf4HL = na
var line htf1HH = na, var line htf1HL = na
var line htfP4HH = na, var line htfP4HL = na
var line htfP1HH = na, var line htfP1HL = na

var label htfMHL = na, var label htfMLL = na
var label htfWHL = na, var label htfWLL = na
var label htfDHL = na, var label htfDLL = na
var label htfPDHL = na, var label htfPDLL = na
var label htf4HHL = na, var label htf4HLL = na
var label htf1HHL = na, var label htf1HLL = na
var label htfP4HHL = na, var label htfP4HLL = na
var label htfP1HHL = na, var label htfP1HLL = na

// ============================================================================
// TREND LINE PLOT
// ============================================================================
plot(i_showTrend and trendDir < 0 ? trendUpper : na,
     "Downtrend Band", color=i_bearTrC, style=plot.style_linebr, linewidth=1)
plot(i_showTrend and trendDir > 0 ? trendLower : na,
     "Uptrend Band",   color=i_bullTrC, style=plot.style_linebr, linewidth=1)

// ============================================================================
// DYNAMIC TRENDLINES ENGINE — Metrify logic + volume accumulation
// ============================================================================
int   TL_FAST_BUF  = 100
int   TL_SCAN_WIN  = 250
int   TL_SCAN_STEP = 5
int   TL_MIN_SPAN  = 10
int   TL_PIV_MEM   = 200
float TL_BREAK_TOL = 0.6

var array<int>   tlLIdxArr = array.new<int>()
var array<float> tlLPrArr  = array.new<float>()
var array<float> tlLVolArr = array.new<float>()
var array<int>   tlHIdxArr = array.new<int>()
var array<float> tlHPrArr  = array.new<float>()
var array<float> tlHVolArr = array.new<float>()

var line     tlSup    = line.new(na, na, na, na, xloc=xloc.bar_index)
var line     tlRes    = line.new(na, na, na, na, xloc=xloc.bar_index)
var linefill tlFill   = linefill.new(tlSup, tlRes, color.new(#2323FF, 95))
var label    tlSupLbl = na
var label    tlResLbl = na

f_tlStorePivot(array<int> idxArr, array<float> prArr, array<float> volArr, int idx, float price, float vol, bool isLow) =>
    sz = idxArr.size()
    if sz == 0
        idxArr.unshift(idx)
        prArr.unshift(price)
        volArr.unshift(vol)
    else
        latestIdx   = idxArr.get(0)
        latestPrice = prArr.get(0)
        if idx > latestIdx
            if idx - latestIdx <= i_tlPivLen
                replace = isLow ? price < latestPrice : price > latestPrice
                if replace
                    idxArr.set(0, idx)
                    prArr.set(0, price)
                    volArr.set(0, vol)
            else
                idxArr.unshift(idx)
                prArr.unshift(price)
                volArr.unshift(vol)
    while idxArr.size() > TL_PIV_MEM
        idxArr.pop()
        prArr.pop()
        volArr.pop()

f_tlTrim(array<int> idxArr, array<float> prArr, array<float> volArr) =>
    while idxArr.size() > 0
        if bar_index - idxArr.get(idxArr.size() - 1) > i_tlLookback
            idxArr.pop()
            prArr.pop()
            volArr.pop()
        else
            break
    0

f_tlFindBest(array<int> idxArr, array<float> prArr, array<float> volArr, bool isSupport) =>
    bool  found  = false
    int   bx1    = na, int   bx2    = na
    float by1    = na, float by2    = na
    float bScore = -1e10
    float bVol   = 0.0
    float aV     = ta.atr(i_tlATRLen)
    float safeAV = math.max(aV, syminfo.mintick)
    float tTol   = safeAV * i_tlTouchTol
    float bTol   = safeAV * TL_BREAK_TOL
    float mSlope = math.tan(i_tlMaxSlope * math.pi / 180.0)
    float mDist  = safeAV * i_tlMaxDist
    int   n      = idxArr.size()
    if n >= 2
        for newer = 0 to n - 2
            p2i = idxArr.get(newer)
            p2p = prArr.get(newer)
            if bar_index - p2i > i_tlLookback
                break
            for older = newer + 1 to n - 1
                p1i  = idxArr.get(older)
                p1p  = prArr.get(older)
                if bar_index - p1i > i_tlLookback
                    break
                span = p2i - p1i
                if span >= TL_MIN_SPAN
                    slope  = (p2p - p1p) / span
                    slopeN = safeAV > 0 ? math.abs(slope) / safeAV : 0.0
                    if slopeN <= mSlope
                        yNow = p1p + slope * (bar_index - p1i)
                        if math.abs(close - yNow) <= mDist
                            int   tc   = 0
                            int   vi   = 0
                            float vAcc = 0.0
                            float eSum = 0.0
                            elig = older + 1
                            for k = 0 to elig - 1
                                ki  = idxArr.get(k)
                                kp  = prArr.get(k)
                                kv  = volArr.get(k)
                                y   = p1p + slope * (ki - p1i)
                                dev = kp - y
                                if math.abs(dev) <= tTol
                                    tc   += 1
                                    vAcc += kv
                                    eSum += math.abs(dev)
                                isViol = isSupport ? dev < -bTol : dev > bTol
                                if isViol
                                    vi += 1
                                if tc + (elig - 1 - k) < 2 or vi > i_tlMaxViol
                                    break
                            brokenNow = isSupport ? close < yNow - bTol : close > yNow + bTol
                            if brokenNow
                                vi += 2
                            if tc >= 2 and vi <= i_tlMaxViol
                                avgErr  = tc > 0 ? eSum / tc : tTol
                                recency = 1.0 - math.min((bar_index - p2i) / (i_tlLookback * 1.0), 1.0)
                                spanSc  = math.min(span / (i_tlLookback * 1.0), 1.0)
                                tight   = 1.0 - math.min(avgErr / tTol, 1.0)
                                slopeP  = mSlope > 0 ? slopeN / mSlope : 0.0
                                score   = tc * 2.8 + recency * 1.2 + spanSc + tight * 1.3 - vi * 2.2 - slopeP * 0.5
                                if score > bScore
                                    bScore := score
                                    found  := true
                                    bx1    := p1i, by1 := p1p
                                    bx2    := p2i, by2 := p2p
                                    bVol   := vAcc
    [found, bx1, by1, bx2, by2, bVol]

// Pivot accumulation every bar
tlReqBars  = i_tlLookback + TL_SCAN_WIN + i_tlPivLen * 3 + TL_FAST_BUF
tlStartBar = math.max(0, last_bar_index - tlReqBars)
tlProcess  = bar_index >= tlStartBar

float tlPH = ta.pivothigh(high, i_tlPivLen, i_tlPivLen)
float tlPL = ta.pivotlow (low,  i_tlPivLen, i_tlPivLen)

if tlProcess and not na(tlPL)
    f_tlStorePivot(tlLIdxArr, tlLPrArr, tlLVolArr, bar_index - i_tlPivLen, tlPL, volume[i_tlPivLen], true)
if tlProcess and not na(tlPH)
    f_tlStorePivot(tlHIdxArr, tlHPrArr, tlHVolArr, bar_index - i_tlPivLen, tlPH, volume[i_tlPivLen], false)
if tlProcess
    f_tlTrim(tlLIdxArr, tlLPrArr, tlLVolArr)
    f_tlTrim(tlHIdxArr, tlHPrArr, tlHVolArr)

// Search and draw every bar
if i_tlOn
    [sFound, sx1, sy1, sx2, sy2, sVol] = f_tlFindBest(tlLIdxArr, tlLPrArr, tlLVolArr, true)
    [rFound, rx1, ry1, rx2, ry2, rVol] = f_tlFindBest(tlHIdxArr, tlHPrArr, tlHVolArr, false)
    tlSty = f_lstyle(i_tlStyle)

    if sFound
        sEnd = f_tlY(sx1, sy1, sx2, sy2, bar_index + i_tlExtend)
        line.set_xy1(tlSup, sx1, sy1)
        line.set_xy2(tlSup, bar_index + i_tlExtend, sEnd)
        line.set_color(tlSup, i_tlSupCol)
        line.set_width(tlSup, i_tlWidth)
        line.set_style(tlSup, tlSty)
        if i_tlShowVol and barstate.islast
            if not na(tlSupLbl)
                label.delete(tlSupLbl)
            tlSupLbl := label.new(bar_index + i_tlExtend, sEnd, "S  " + f_fmtVol(sVol), color=C_TRANS, textcolor=i_tlSupCol, style=label.style_label_left, size=size.tiny)
    else
        line.set_color(tlSup, C_TRANS)

    if rFound
        rEnd = f_tlY(rx1, ry1, rx2, ry2, bar_index + i_tlExtend)
        line.set_xy1(tlRes, rx1, ry1)
        line.set_xy2(tlRes, bar_index + i_tlExtend, rEnd)
        line.set_color(tlRes, i_tlResCol)
        line.set_width(tlRes, i_tlWidth)
        line.set_style(tlRes, tlSty)
        if i_tlShowVol and barstate.islast
            if not na(tlResLbl)
                label.delete(tlResLbl)
            tlResLbl := label.new(bar_index + i_tlExtend, rEnd, "R  " + f_fmtVol(rVol), color=C_TRANS, textcolor=i_tlResCol, style=label.style_label_left, size=size.tiny)
    else
        line.set_color(tlRes, C_TRANS)

    if i_tlShowFill and sFound and rFound
        sNow = f_tlY(sx1, sy1, sx2, sy2, bar_index)
        rNow = f_tlY(rx1, ry1, rx2, ry2, bar_index)
        linefill.set_color(tlFill, close >= (sNow + rNow) * 0.5 ? color.new(i_tlSupCol, 92) : color.new(i_tlResCol, 92))
    else
        linefill.set_color(tlFill, C_TRANS)

// ============================================================================
// USER DEFINED TYPES
// ============================================================================
type VoidLayer
    box   boxObj
    float topPrice
    float bottomPrice
    bool  isFilled

type VoidBox
    array<VoidLayer> layers
    int   createdBar
    float volAcc

type LZone
    float  price
    float  top
    float  bot
    bool   isBull
    bool   swept
    bool   fresh
    int    barCreated
    float  volWeight   // volume / avgVol at creation
    float  nvolWeight  // normalized volume 0-100 at creation
    bool   trendAligned
    box    bx
    line   ml
    label  lbl
    label  volLbl

type EQZone
    float  top
    float  bot
    bool   isHigh
    int    barCreated
    float  totalVol
    float  nvolAvg
    line   topLine
    line   botLine

type SweepEv
    float  level
    float  wick
    bool   isBull
    bool   isMajor
    float  liqVol
    int    barIdx
    int    judgeBar
    bool   resolved
    bool   correct
    float  slPrice
    line   slLine
    line   slGlow

type PivStore
    float  price
    int    barIdx
    float  vol
    float  nvol

// ============================================================================
// ARRAYS
// ============================================================================
var lzone_arr  = array.new<LZone>()
var eqzone_arr = array.new<EQZone>()
var sweep_arr  = array.new<SweepEv>()
var pivH_arr   = array.new<PivStore>()
var pivL_arr   = array.new<PivStore>()

// Sweep volume accumulators (from Sweep Filter logic)
var peakLines  = array.new_line()
var valleyLines= array.new_line()
var peakVols   = array.new_float()
var valleyVols = array.new_float()
var peakNVols  = array.new_float()
var valleyNVols= array.new_float()

// Counters
var int totalSweeps = 0
var int bullSweeps  = 0
var int bearSweeps  = 0
var int majorSweeps = 0
var int correct_cnt = 0
var int wrong_cnt   = 0
var int lastBullBar = -999
var int lastBearBar = -999

// ============================================================================
// HTF helper functions — line starts at HTF candle timestamp
// ============================================================================
f_htfLStyle() =>
    i_htfStyle == "Dotted" ? line.style_dotted :
     i_htfStyle == "Dashed" ? line.style_dashed : line.style_solid

f_htfDraw(line ln, label lb, int t1, float lvl, float vol, color col, string tf) =>
    msPerBar = time - time[1]
    x2       = time + msPerBar * i_htfExtend
    txt      = i_htfShowVol ? tf + "  " + f_fmtVol(vol) : tf
    outLn    = na(ln) ? line.new(t1, lvl, x2, lvl,
                 color=col, style=f_htfLStyle(), width=i_htfWidth,
                 xloc=xloc.bar_time) : ln
    outLb    = na(lb) ? label.new(x2, lvl, txt,
                 color=C_TRANS, textcolor=col,
                 style=label.style_label_left, size=size.tiny,
                 xloc=xloc.bar_time) : lb
    if not na(outLn)
        line.set_x1(outLn, t1)
        line.set_x2(outLn, x2)
        line.set_y1(outLn, lvl)
        line.set_y2(outLn, lvl)
    if not na(outLb)
        label.set_x(outLb, x2)
        label.set_y(outLb, lvl)
        label.set_text(outLb, txt)
        label.set_textcolor(outLb, col)
    [outLn, outLb]

f_probColor(float p) =>
    p > 70 ? C_BULL : p > 40 ? C_GOLD : C_BEAR

f_prob(float nodePrice, float vWeight, float nvolW, bool trendAlign) =>
    volF    = math.min(vWeight * 6.0, 35.0)
    atrF    = math.min(20.0, atr14 / math.max(nodePrice, 0.0001) * 1000.0)
    distF   = math.max(0.0, 15.0 - math.abs(close - nodePrice) / math.max(atr14, 0.0001) * 3.0)
    nvolF   = math.min(nvolW * 0.2, 20.0)
    trendF  = trendAlign ? 10.0 : -5.0
    result  = 40.0 + volF - atrF + distF + nvolF + trendF
    math.max(5.0, math.min(98.0, result))

// ============================================================================
// HTF LINES EXECUTION — runs on last bar, starts at HTF candle time
// ============================================================================
if i_htfOn and barstate.islast
    if i_htfM
        mCol          = color.new(i_htfCol, 15)
        [lnMH, lbMH] = f_htfDraw(htfMH, htfMHL, mTime,  mHigh, mVol, mCol, "M")
        [lnML, lbML] = f_htfDraw(htfML, htfMLL,  mTime,  mLow,  mVol, mCol, "M")
        htfMH  := lnMH
        htfMHL := lbMH
        htfML  := lnML
        htfMLL := lbML

    if i_htfW
        wCol          = color.new(i_htfCol, 15)
        [lnWH, lbWH] = f_htfDraw(htfWH, htfWHL, wTime,  wHigh, wVol, wCol, "W")
        [lnWL, lbWL] = f_htfDraw(htfWL, htfWLL,  wTime,  wLow,  wVol, wCol, "W")
        htfWH  := lnWH
        htfWHL := lbWH
        htfWL  := lnWL
        htfWLL := lbWL

    if i_htfD
        dCol          = color.new(i_htfCol, 15)
        [lnDH, lbDH] = f_htfDraw(htfDH, htfDHL, dTime,  dHigh, dVol, dCol, "D")
        [lnDL, lbDL] = f_htfDraw(htfDL, htfDLL,  dTime,  dLow,  dVol, dCol, "D")
        htfDH  := lnDH
        htfDHL := lbDH
        htfDL  := lnDL
        htfDLL := lbDL

    if i_htfPD
        pdCol           = color.new(i_htfCol, 15)
        [lnPDH, lbPDH] = f_htfDraw(htfPDH, htfPDHL, pdTime, pdHigh, pdVol, pdCol, "PD")
        [lnPDL, lbPDL] = f_htfDraw(htfPDL, htfPDLL,  pdTime, pdLow,  pdVol, pdCol, "PD")
        htfPDH  := lnPDH
        htfPDHL := lbPDH
        htfPDL  := lnPDL
        htfPDLL := lbPDL

    if i_htf4H
        h4Col           = color.new(i_htfCol, 15)
        [ln4HH, lb4HH] = f_htfDraw(htf4HH, htf4HHL, h4Time, h4High, h4Vol, h4Col, "4H")
        [ln4HL, lb4HL] = f_htfDraw(htf4HL, htf4HLL,  h4Time, h4Low,  h4Vol, h4Col, "4H")
        htf4HH  := ln4HH
        htf4HHL := lb4HH
        htf4HL  := ln4HL
        htf4HLL := lb4HL

    if i_htfP4H
        p4Col            = color.new(i_htfCol, 15)
        [lnP4HH, lbP4HH] = f_htfDraw(htfP4HH, htfP4HHL, p4hTime, p4hHigh, p4hVol, p4Col, "P4H")
        [lnP4HL, lbP4HL] = f_htfDraw(htfP4HL, htfP4HLL,  p4hTime, p4hLow,  p4hVol, p4Col, "P4H")
        htfP4HH  := lnP4HH
        htfP4HHL := lbP4HH
        htfP4HL  := lnP4HL
        htfP4HLL := lbP4HL

    if i_htf1H
        h1Col           = color.new(i_htfCol, 15)
        [ln1HH, lb1HH] = f_htfDraw(htf1HH, htf1HHL, h1Time, h1High, h1Vol, h1Col, "1H")
        [ln1HL, lb1HL] = f_htfDraw(htf1HL, htf1HLL,  h1Time, h1Low,  h1Vol, h1Col, "1H")
        htf1HH  := ln1HH
        htf1HHL := lb1HH
        htf1HL  := ln1HL
        htf1HLL := lb1HL

    if i_htfP1H
        p1Col            = color.new(i_htfCol, 15)
        [lnP1HH, lbP1HH] = f_htfDraw(htfP1HH, htfP1HHL, p1hTime, p1hHigh, p1hVol, p1Col, "P1H")
        [lnP1HL, lbP1HL] = f_htfDraw(htfP1HL, htfP1HLL,  p1hTime, p1hLow,  p1hVol, p1Col, "P1H")
        htfP1HH  := lnP1HH
        htfP1HHL := lbP1HH
        htfP1HL  := lnP1HL
        htfP1HLL := lbP1HL

// ============================================================================
// PIVOTS — actual pivot calculations
// ============================================================================
pH = ta.pivothigh(high, i_pivLeft, i_pivRight)
pL = ta.pivotlow (low,  i_pivLeft, i_pivRight)

pivBarH   = bar_index - i_pivRight
pivBarL   = bar_index - i_pivRight
volAtH    = volume[i_pivRight]
volAtL    = volume[i_pivRight]
nvolAtH   = nvol[i_pivRight]
nvolAtL   = nvol[i_pivRight]
volPassH  = volAtH > volMA * volThresh
volPassL  = volAtL > volMA * volThresh

// Trend alignment — demand zone below price in uptrend, supply zone above in downtrend
trendAlignH = trendDir < 0   // supply in downtrend
trendAlignL = trendDir > 0   // demand in uptrend

// ============================================================================
// LIQUIDITY ZONES — creation
// ============================================================================
if i_zonesOn and not na(pH) and volPassH
    vW     = volMA > 0 ? volAtH / volMA : 1.0
    zW     = i_dynamic ? math.max(atr14 * 0.1, (nvolAtH / 100.0) * atr200 * 0.5) : atr14 * i_zoneATR
    zTop   = pH
    zBot   = pH - zW
    prob   = f_prob(pH, vW, nvolAtH, trendAlignH)
    pColor = f_probColor(prob)
    bc     = i_bearCol

    newBx  = box.new(pivBarH, zTop, bar_index, zBot,
         border_color=color.new(bc, 0), border_width=1,
         bgcolor=color.new(#ff0000, int(math.max(55.0, 90.0 - nvolAtH * 0.68))))
    newMl  = i_showMid ? line.new(pivBarH, (zTop+zBot)/2, bar_index, (zTop+zBot)/2,
         color=color.new(i_midCol,0), style=line.style_dotted) : na
    newLbl = label.new(bar_index + 1, (zTop+zBot)/2,
         str.tostring(math.round(prob)) + "%",
         color=C_TRANS, textcolor=pColor,
         style=label.style_label_left, size=size.tiny)
    newVol = i_showVol ? label.new(pivBarH, zTop,
         f_fmtVol(volAtH),
         color=C_TRANS, textcolor=color.new(bc, 20),
         style=label.style_label_down, size=size.tiny) : na

    lzone_arr.push(LZone.new(pH, zTop, zBot, false, false, true,
         bar_index, vW, nvolAtH, trendAlignH, newBx, newMl, newLbl, newVol))

if i_zonesOn and not na(pL) and volPassL
    vW     = volMA > 0 ? volAtL / volMA : 1.0
    zW     = i_dynamic ? math.max(atr14 * 0.1, (nvolAtL / 100.0) * atr200 * 0.5) : atr14 * i_zoneATR
    zTop   = pL + zW
    zBot   = pL
    prob   = f_prob(pL, vW, nvolAtL, trendAlignL)
    pColor = f_probColor(prob)
    bc     = i_bullCol

    newBx  = box.new(pivBarL, zTop, bar_index, zBot,
         border_color=color.new(bc, 0), border_width=1,
         bgcolor=color.new(#00ff00, int(math.max(55.0, 90.0 - nvolAtL * 0.68))))
    newMl  = i_showMid ? line.new(pivBarL, (zTop+zBot)/2, bar_index, (zTop+zBot)/2,
         color=color.new(i_midCol, 0), style=line.style_dotted) : na
    newLbl = label.new(bar_index + 1, (zTop+zBot)/2,
         str.tostring(math.round(prob)) + "%",
         color=C_TRANS, textcolor=pColor,
         style=label.style_label_left, size=size.tiny)
    newVol = i_showVol ? label.new(pivBarL, zBot,
         f_fmtVol(volAtL),
         color=C_TRANS, textcolor=color.new(bc, 20),
         style=label.style_label_up, size=size.tiny) : na

    lzone_arr.push(LZone.new(pL, zTop, zBot, true, false, true,
         bar_index, vW, nvolAtL, trendAlignL, newBx, newMl, newLbl, newVol))

// ============================================================================
// LIQUIDITY ZONES — management
// ============================================================================
var bool sweptSupplyBar  = false
var bool sweptDemandBar  = false
sweptSupplyBar  := false
sweptDemandBar  := false

if lzone_arr.size() > 0
    for i = lzone_arr.size() - 1 to 0
        z = lzone_arr.get(i)

        if z.swept
            continue

        // Extend
        box.set_right(z.bx, bar_index)
        if not na(z.ml)
            line.set_x2(z.ml, bar_index)
        label.set_x(z.lbl, bar_index + 1)

        // Test count
        inZone = z.isBull ? (low <= z.top and close >= z.bot) : (high >= z.bot and close <= z.top)
        if inZone and z.fresh and barstate.isconfirmed
            z.fresh := false

        // Sweep
        isSwept = z.isBull ? (low < z.bot and barstate.isconfirmed) :
                              (high > z.top and barstate.isconfirmed)
        if isSwept
            z.swept := true
            if z.isBull
                sweptDemandBar := true   // circle below candle
            else
                sweptSupplyBar := true   // circle above candle

        // Visibility
        if z.swept
            if i_freshOnly or not i_showSwept
                box.set_bgcolor(z.bx, C_TRANS)
                box.set_border_color(z.bx, C_TRANS)
                if not na(z.ml)
                    line.set_color(z.ml, C_TRANS)
                label.set_text(z.lbl, "")
                if not na(z.volLbl)
                    label.set_text(z.volLbl, "")
            else
                sCol = z.isBull ? color.new(i_bullCol, i_sweptAlpha) : color.new(i_bearCol, i_sweptAlpha)
                box.set_bgcolor(z.bx, sCol)
                box.set_border_color(z.bx, C_TRANS)
                if not na(z.ml)
                    line.set_color(z.ml, C_TRANS)
                label.set_text(z.lbl, "")
        else if i_freshOnly and not z.fresh
            box.set_bgcolor(z.bx, C_TRANS)
            box.set_border_color(z.bx, C_TRANS)
            if not na(z.ml)
                line.set_color(z.ml, C_TRANS)
            label.set_text(z.lbl, "")
            if not na(z.volLbl)
                label.set_text(z.volLbl, "")
        else
            // Live probability update
            prob   = f_prob(z.price, z.volWeight, z.nvolWeight, z.trendAligned)
            pColor = f_probColor(prob)
            label.set_text(z.lbl, str.tostring(math.round(prob)) + "%")
            label.set_textcolor(z.lbl, pColor)

    // Trim oldest
    while lzone_arr.size() > i_maxZones
        old = lzone_arr.shift()
        box.delete(old.bx)
        if not na(old.ml)
            line.delete(old.ml)
        label.delete(old.lbl)
        if not na(old.volLbl)
            label.delete(old.volLbl)

// Swept zone circle markers
plotshape(i_sweptDot and sweptSupplyBar  and i_sweptDotSz == "Tiny"   ? high : na, "Supply Swept T", shape.circle, location.abovebar, i_sweptDotBC, size=size.tiny)
plotshape(i_sweptDot and sweptSupplyBar  and i_sweptDotSz == "Small"  ? high : na, "Supply Swept S", shape.circle, location.abovebar, i_sweptDotBC, size=size.small)
plotshape(i_sweptDot and sweptSupplyBar  and i_sweptDotSz == "Normal" ? high : na, "Supply Swept N", shape.circle, location.abovebar, i_sweptDotBC, size=size.normal)

plotshape(i_sweptDot and sweptDemandBar and i_sweptDotSz == "Tiny"   ? low : na, "Demand Swept T", shape.circle, location.belowbar, i_sweptDotGC, size=size.tiny)
plotshape(i_sweptDot and sweptDemandBar and i_sweptDotSz == "Small"  ? low : na, "Demand Swept S", shape.circle, location.belowbar, i_sweptDotGC, size=size.small)
plotshape(i_sweptDot and sweptDemandBar and i_sweptDotSz == "Normal" ? low : na, "Demand Swept N", shape.circle, location.belowbar, i_sweptDotGC, size=size.normal)

// ============================================================================
// EQUAL HIGHS / EQUAL LOWS — with volume info + sweep volume accumulation
// ============================================================================
if not na(pH)
    pivH_arr.unshift(PivStore.new(pH, pivBarH, volAtH, nvolAtH))
    if pivH_arr.size() > 50
        pivH_arr.pop()

if not na(pL)
    pivL_arr.unshift(PivStore.new(pL, pivBarL, volAtL, nvolAtL))
    if pivL_arr.size() > 50
        pivL_arr.pop()

// EQH creation
if i_eqlOn and not na(pH) and pivH_arr.size() >= 2
    cur = pivH_arr.get(0)
    for j = 1 to pivH_arr.size() - 1
        prev = pivH_arr.get(j)
        diff = math.abs(cur.price - prev.price) / math.max(prev.price, 0.0001) * 100.0
        if diff <= i_eqlThresh
            zTop    = math.max(cur.price, prev.price)
            zBot    = math.min(cur.price, prev.price)
            if zTop - zBot < syminfo.mintick * 2
                zTop += syminfo.mintick
            totVol  = cur.vol + prev.vol
            nvolAvg = (cur.nvol + prev.nvol) / 2
            tl = line.new(prev.barIdx, zTop, bar_index, zTop, color=i_eqlHCol, width=1)
            bl = line.new(prev.barIdx, zBot, bar_index, zBot, color=color.new(i_eqlHCol, 70), width=1)
            linefill.new(tl, bl, color.new(i_eqlHCol, 80))
            eqzone_arr.push(EQZone.new(zTop, zBot, true, bar_index, totVol, nvolAvg, tl, bl))
            break

// EQL creation
if i_eqlOn and not na(pL) and pivL_arr.size() >= 2
    cur = pivL_arr.get(0)
    for j = 1 to pivL_arr.size() - 1
        prev = pivL_arr.get(j)
        diff = math.abs(cur.price - prev.price) / math.max(prev.price, 0.0001) * 100.0
        if diff <= i_eqlThresh
            zTop    = math.max(cur.price, prev.price)
            zBot    = math.min(cur.price, prev.price)
            if zTop - zBot < syminfo.mintick * 2
                zBot -= syminfo.mintick
            totVol  = cur.vol + prev.vol
            nvolAvg = (cur.nvol + prev.nvol) / 2
            tl = line.new(prev.barIdx, zTop, bar_index, zTop, color=i_eqlLCol, width=1)
            bl = line.new(prev.barIdx, zBot, bar_index, zBot, color=color.new(i_eqlLCol, 70), width=1)
            linefill.new(tl, bl, color.new(i_eqlLCol, 80))
            eqzone_arr.push(EQZone.new(zTop, zBot, false, bar_index, totVol, nvolAvg, tl, bl))
            break

// EQ zone management
if i_eqlOn and eqzone_arr.size() > 0
    for i = eqzone_arr.size() - 1 to 0
        eq = eqzone_arr.get(i)
        age = bar_index - eq.barCreated

        remove = age > i_eqlAge
        if not remove
            if i_eqlRemove == "Wick"
                remove := eq.isHigh ? high >= eq.top : low <= eq.bot
            else if i_eqlRemove == "Body"
                remove := eq.isHigh ? close > eq.top : close < eq.bot
            else
                remove := eq.isHigh ? (close > eq.top and close[1] > eq.top) :
                                      (close < eq.bot  and close[1] < eq.bot)

        if remove
            line.delete(eq.topLine)
            line.delete(eq.botLine)
            eqzone_arr.remove(i)
        else
            line.set_x2(eq.topLine, bar_index + 1)
            line.set_x2(eq.botLine, bar_index + 1)

    while eqzone_arr.size() > 60
        old = eqzone_arr.shift()
        line.delete(old.topLine)
        line.delete(old.botLine)

// ============================================================================
// SWEEP VOLUME ACCUMULATION — Trend Engine
// ============================================================================
peakform   = high[1] > high and high[2] < high[1]
valleyform = low[1]  < low  and low[2]  > low[1]

if i_trendOn and trendDir < 0 and peakform and high[1] < trendUpper
    pl = line.new(bar_index - 1, high[1], bar_index, high[1],
         color=color.new(i_bearSwpC, int(100 - nvol[1])), width=2)
    peakLines.push(pl)
    peakVols.push(volume[1])
    peakNVols.push(nvol[1])

if i_trendOn and trendDir > 0 and valleyform and low[1] > trendLower
    vl = line.new(bar_index - 1, low[1], bar_index, low[1],
         color=color.new(i_bullSwpC, int(100 - nvol[1])), width=2)
    valleyLines.push(vl)
    valleyVols.push(volume[1])
    valleyNVols.push(nvol[1])

// Process peak lines — extend or remove on break
var float bearliqVol  = 0.0
var float bearliqNVol = 0.0
bearliqVol  := 0.0
bearliqNVol := 0.0

if peakLines.size() > 0
    for i = peakLines.size() - 1 to 0
        ln  = peakLines.get(i)
        lvl = line.get_y1(ln)
        if high > lvl or trendUpper < lvl
            if high > lvl
                bearliqVol  += peakVols.get(i)
                bearliqNVol += peakNVols.get(i)
            line.delete(ln)
            peakLines.remove(i)
            peakVols.remove(i)
            peakNVols.remove(i)
        else
            line.set_x2(ln, bar_index)
    while peakLines.size() > 200
        line.delete(peakLines.shift())
        peakVols.shift()
        peakNVols.shift()

// Process valley lines
var float bullliqVol  = 0.0
var float bullliqNVol = 0.0
bullliqVol  := 0.0
bullliqNVol := 0.0

if valleyLines.size() > 0
    for i = valleyLines.size() - 1 to 0
        ln  = valleyLines.get(i)
        lvl = line.get_y1(ln)
        if low < lvl or trendLower > lvl
            if low < lvl
                bullliqVol  += valleyVols.get(i)
                bullliqNVol += valleyNVols.get(i)
            line.delete(ln)
            valleyLines.remove(i)
            valleyVols.remove(i)
            valleyNVols.remove(i)
        else
            line.set_x2(ln, bar_index)
    while valleyLines.size() > 200
        line.delete(valleyLines.shift())
        valleyVols.shift()
        valleyNVols.shift()

// Sweep volume labels — major vs minor
volatility = atr14 / 2

if bullliqVol > 0
    isMajorBull = bullliqNVol >= i_mjrThresh
    if isMajorBull and i_showMjr
        label.new(bar_index, trendLower,
             "▲ " + f_fmtVol(bullliqVol),
             color=color.new(C_TRANS, 70), textcolor=i_bullTrC,
             style=label.style_label_up, size=size.tiny)
    else if not isMajorBull and i_showMnr
        label.new(bar_index, trendLower,
             "△ " + f_fmtVol(bullliqVol),
             color=color.new(C_TRANS, 80), textcolor=i_bullTrC,
             style=label.style_label_up, size=size.tiny)

if bearliqVol > 0
    isMajorBear = bearliqNVol >= i_mjrThresh
    if isMajorBear and i_showMjr
        label.new(bar_index, trendUpper,
             "▼ " + f_fmtVol(bearliqVol),
             color=color.new(C_TRANS, 70), textcolor=i_bearSwpC,
             style=label.style_label_down, size=size.tiny)
    else if not isMajorBear and i_showMnr
        label.new(bar_index, trendUpper,
             "▽ " + f_fmtVol(bearliqVol),
             color=color.new(C_TRANS, 80), textcolor=i_bearSwpC,
             style=label.style_label_down, size=size.tiny)

// ============================================================================
// SWEEP DETECTION — wick + breakout modes
// ============================================================================
swH = ta.highest(high, i_swingLen * 2)[1]
swL = ta.lowest (low,  i_swingLen * 2)[1]

swPH = ta.pivothigh(high, i_swingLen, i_swingLen)
swPL = ta.pivotlow (low,  i_swingLen, i_swingLen)

cRange  = math.max(syminfo.mintick, high - low)
wickU   = high - math.max(open, close)
wickD   = math.min(open, close) - low
rejU    = cRange > 0 ? wickU / cRange * 100.0 : 0.0
rejD    = cRange > 0 ? wickD / cRange * 100.0 : 0.0

volOk   = not i_volFilt or volume > volMA * i_volMult
emaOkB  = not i_emaFilt or close < emaVal
emaOkS  = not i_emaFilt or close > emaVal
coolB   = bar_index - lastBullBar >= i_cooldown
coolS   = bar_index - lastBearBar >= i_cooldown
slSty   = f_lstyle(i_slStyle)

bullWick = i_sweepOn and low    < swL
          and close > swL
          and (swL - low) >= atr14 * i_minWick
          and rejD >= i_minRej
          and volOk and coolB and emaOkB
          and barstate.isconfirmed

bearWick = i_sweepOn and high   > swH
          and close < swH
          and (high - swH) >= atr14 * i_minWick
          and rejU >= i_minRej
          and volOk and coolS and emaOkS
          and barstate.isconfirmed

// Breakout retest mode
var bool  brkH      = false
var bool  brkL      = false
var float brkHPrice = na
var float brkLPrice = na

if i_sweepMode == "Wicks + Breakouts"
    if not na(swPH)
        if close > swPH
            brkH      := true
            brkHPrice := swPH
        if brkH and close < brkHPrice and high > brkHPrice
            bearWick := true
            brkH     := false
    if not na(swPL)
        if close < swPL
            brkL      := true
            brkLPrice := swPL
        if brkL and close > brkLPrice and low < brkLPrice
            bullWick := true
            brkL     := false

// Major vs minor based on normalized volume
isMajorSweep = nvol >= i_mjrThresh

// Register bull sweep
if bullWick
    lastBullBar := bar_index
    totalSweeps += 1
    bullSweeps  += 1
    if isMajorSweep
        majorSweeps += 1
    slP  = low - atr14 * i_slBuf
    sl1  = i_slOn ? line.new(bar_index, slP, bar_index + 2, slP,
         color=i_slBullC, style=slSty, width=i_slWidth) : na
    sl2  = i_slOn and i_slGlow ? line.new(bar_index, slP, bar_index + 2, slP,
         color=color.new(i_slBullC, 72), style=slSty, width=i_slWidth + 2) : na
    sweep_arr.push(SweepEv.new(swL, low, true, isMajorSweep, bullliqVol,
         bar_index, bar_index + i_accWindow, false, false, slP, sl1, sl2))

// Register bear sweep
if bearWick
    lastBearBar := bar_index
    totalSweeps += 1
    bearSweeps  += 1
    if isMajorSweep
        majorSweeps += 1
    slP  = high + atr14 * i_slBuf
    sl1  = i_slOn ? line.new(bar_index, slP, bar_index + 2, slP,
         color=i_slBearC, style=slSty, width=i_slWidth) : na
    sl2  = i_slOn and i_slGlow ? line.new(bar_index, slP, bar_index + 2, slP,
         color=color.new(i_slBearC, 72), style=slSty, width=i_slWidth + 2) : na
    sweep_arr.push(SweepEv.new(swH, high, false, isMajorSweep, bearliqVol,
         bar_index, bar_index + i_accWindow, false, false, slP, sl1, sl2))

// Sweep markers — filled = major, outline = minor
plotshape(bar_index == lastBullBar and isMajorSweep  ? low  - atr14 * 0.4 : na,
     "Bull Sweep Major", shape.triangleup, location.absolute, i_bullSwpC, size=size.tiny)
plotshape(bar_index == lastBullBar and not isMajorSweep ? low  - atr14 * 0.4 : na,
     "Bull Sweep Minor", shape.triangleup, location.absolute, color.new(i_bullSwpC, 50), size=size.tiny)
plotshape(bar_index == lastBearBar and isMajorSweep  ? high + atr14 * 0.4 : na,
     "Bear Sweep Major", shape.triangledown, location.absolute, i_bearSwpC, size=size.tiny)
plotshape(bar_index == lastBearBar and not isMajorSweep ? high + atr14 * 0.4 : na,
     "Bear Sweep Minor", shape.triangledown, location.absolute, color.new(i_bearSwpC, 50), size=size.tiny)

// ============================================================================
// SAFE STOP LINE MANAGEMENT
// ============================================================================
var float dashSL     = na
var bool  dashSLBull = false

if sweep_arr.size() > 0
    for i = sweep_arr.size() - 1 to 0
        sw = sweep_arr.get(i)

        if na(sw.slLine)
            continue

        expired = false
        if i_slExpire == "X Bars"
            expired := bar_index - sw.barIdx >= i_slBars
        else if i_slExpire == "Until Price"
            expired := sw.isBull ? low <= sw.slPrice : high >= sw.slPrice
        else if i_slExpire == "New Sweep"
            expired := sw.isBull ? (bar_index == lastBullBar and sw.barIdx != lastBullBar) :
                                   (bar_index == lastBearBar and sw.barIdx != lastBearBar)

        if bar_index - sw.barIdx > 1000
            expired := true
        if sw.resolved
            expired := true

        if expired
            line.delete(sw.slLine)
            if not na(sw.slGlow)
                line.delete(sw.slGlow)
            sw.slLine := na
            sw.slGlow := na
        else
            line.set_x2(sw.slLine, bar_index + 3)
            if not na(sw.slGlow)
                line.set_x2(sw.slGlow, bar_index + 3)
            dashSL     := sw.slPrice
            dashSLBull := sw.isBull

// ============================================================================
// ACCURACY TRACKER
// ============================================================================
if i_accOn and sweep_arr.size() > 0
    for i = sweep_arr.size() - 1 to 0
        sw = sweep_arr.get(i)
        if not sw.resolved and bar_index >= sw.judgeBar
            if sw.isBull
                if high >= sw.level + atr14 * i_accMove
                    sw.resolved := true
                    sw.correct  := true
                    correct_cnt += 1
                else
                    sw.resolved := true
                    sw.correct  := false
                    wrong_cnt   += 1
            else
                if low <= sw.level - atr14 * i_accMove
                    sw.resolved := true
                    sw.correct  := true
                    correct_cnt += 1
                else
                    sw.resolved := true
                    sw.correct  := false
                    wrong_cnt   += 1

while sweep_arr.size() > 300
    old = sweep_arr.shift()
    if not na(old.slLine)
        line.delete(old.slLine)
    if not na(old.slGlow)
        line.delete(old.slGlow)

// ============================================================================
// NEAREST ZONE / COUNTS
// ============================================================================
var float nearBSL = na
var float nearSSL = na
var int   aBSL    = 0
var int   aSSL    = 0

if barstate.islast and lzone_arr.size() > 0
    nearBSL := na
    nearSSL := na
    aBSL    := 0
    aSSL    := 0
    float dB = 999999.0
    float dS = 999999.0
    for i = 0 to lzone_arr.size() - 1
        z = lzone_arr.get(i)
        if not z.swept
            d = math.abs(close - z.price)
            if not z.isBull
                aBSL += 1
                if d < dB
                    dB := d
                    nearBSL := z.price
            else
                aSSL += 1
                if d < dS
                    dS := d
                    nearSSL := z.price

// ============================================================================
// WEEKEND GAP ENGINE — original CME logic
// ============================================================================
cme_dailyClose     = request.security(syminfo.tickerid, "D", close)
cme_isFriday       = dayofweek == dayofweek.friday
cme_fridayClose    = ta.valuewhen(cme_isFriday, cme_dailyClose, 0)
cme_shouldPlot = cme_isFriday and hour >= 24 or dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday

cme_fridayClose2   = ta.valuewhen(dayofweek.friday == dayofweek, cme_dailyClose, 0)
cme_shouldPlot2 = (cme_isFriday and hour >= 24 or dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday)

// Gap fill detection
gapFilled = not na(cme_fridayClose) and ((close > cme_fridayClose and low <= cme_fridayClose) or (close < cme_fridayClose and high >= cme_fridayClose))

var bool gapWasFilled = false
if gapFilled
    gapWasFilled := true
if cme_isFriday
    gapWasFilled := false

// Friday close line — extends into the week
var line cmeL    = na
var label cmeLbl = na

if i_cmeOn and i_cmeLineOn and barstate.islast
    cmeStyle     = f_lstyle(i_cmeStyle)
    msPerBar     = time - time[1]
    lastFriTime  = ta.valuewhen(cme_isFriday, time, 0)
    x2           = lastFriTime + int(msPerBar * i_cmeExtend * 24)
    if not na(cme_fridayClose2) and not na(lastFriTime)
        if na(cmeL)
            cmeL   := line.new(lastFriTime, cme_fridayClose2, x2, cme_fridayClose2,
                 color=i_cmeLineC, style=cmeStyle, width=i_cmeWidth, xloc=xloc.bar_time)
            cmeLbl := label.new(x2, cme_fridayClose2,
                 "Fri  " + str.tostring(cme_fridayClose2, format.mintick),
                 color=C_TRANS, textcolor=i_cmeLineC,
                 style=label.style_label_left, size=size.tiny, xloc=xloc.bar_time)
        else
            line.set_x1(cmeL, lastFriTime)
            line.set_x2(cmeL, x2)
            line.set_y1(cmeL, cme_fridayClose2)
            line.set_y2(cmeL, cme_fridayClose2)
            label.set_x(cmeLbl, x2)
            label.set_y(cmeLbl, cme_fridayClose2)
            label.set_text(cmeLbl, "Fri  " + str.tostring(cme_fridayClose2, format.mintick))

// Gap fill — exact same approach as original CME script
cmeP1 = plot(i_cmeOn and i_cmeFillOn and cme_shouldPlot2 ?
             (close > cme_fridayClose2 ?
              (close < open ? open : close) :
              (close > open ? open : close)) : na,
             "CME Gap", color=color.new(color.white, 100),
             style=plot.style_linebr, display=display.pane)
cmeP2 = plot(i_cmeOn and i_cmeFillOn and cme_shouldPlot2 ?
             cme_fridayClose2 : na,
             "CME Close", color=color.new(color.white, 100),
             style=plot.style_linebr, display=display.pane)

cmeGradCol = close > cme_fridayClose2 ? i_cmeBullC : i_cmeBearC
fill(cmeP1, cmeP2, cmeGradCol)

// ============================================================================
// DASHBOARD PRE-CALCULATIONS — placed here so all CME/TL vars are in scope
// ============================================================================

// Highest probability zone
var float dashBestProb  = 0.0
var float dashBestPrice = na
var bool  dashBestBull  = true

if barstate.islast and lzone_arr.size() > 0
    dashBestProb  := 0.0
    dashBestPrice := na
    for i = 0 to lzone_arr.size() - 1
        z = lzone_arr.get(i)
        if not z.swept
            zProb = f_prob(z.price, z.volWeight, z.nvolWeight, z.trendAligned)
            if zProb > dashBestProb
                dashBestProb  := zProb
                dashBestPrice := z.price
                dashBestBull  := z.isBull

// Nearest HTF level above and below price
var float dashHTFAbove = na
var float dashHTFBelow = na

if i_htfOn and barstate.islast
    float bestAbove = 999999999.0
    float bestBelow = -999999999.0
    htfLevels = array.new<float>()
    if i_htfM  and not na(mHigh)
        htfLevels.push(mHigh)
        htfLevels.push(mLow)
    if i_htfW  and not na(wHigh)
        htfLevels.push(wHigh)
        htfLevels.push(wLow)
    if i_htfD  and not na(dHigh)
        htfLevels.push(dHigh)
        htfLevels.push(dLow)
    if i_htfPD and not na(pdHigh)
        htfLevels.push(pdHigh)
        htfLevels.push(pdLow)
    if i_htf4H and not na(h4High)
        htfLevels.push(h4High)
        htfLevels.push(h4Low)
    if i_htf1H and not na(h1High)
        htfLevels.push(h1High)
        htfLevels.push(h1Low)
    for i = 0 to htfLevels.size() - 1
        lvl = htfLevels.get(i)
        if lvl > close and lvl < bestAbove
            bestAbove    := lvl
            dashHTFAbove := lvl
        if lvl < close and lvl > bestBelow
            bestBelow    := lvl
            dashHTFBelow := lvl

// Weekend gap info
bool  dashGapOpen = i_cmeOn and not na(cme_fridayClose2) and not gapWasFilled and cme_shouldPlot2
float dashGapPct  = not na(cme_fridayClose2) and cme_fridayClose2 > 0 ? math.round(math.abs(close - cme_fridayClose2) / cme_fridayClose2 * 100.0, 2) : 0.0
bool  dashGapBull = not na(cme_fridayClose2) and close > cme_fridayClose2

// Divergence state — declared here so dashboard can access before the engine runs
var bool divBullish = false
var bool divBearish = false

// Active engine count
int   dashEngines = (i_zonesOn ? 1 : 0) + (i_eqlOn ? 1 : 0) + (i_trendOn ? 1 : 0) + (i_sweepOn ? 1 : 0) + (i_htfOn ? 1 : 0) + (i_tlOn ? 1 : 0) + (i_cmeOn ? 1 : 0) + (i_sdOn ? 1 : 0) + (i_voidOn ? 1 : 0) + (i_divOn ? 1 : 0)

// Trendline distance — calculated inline in dashboard using line objects
float dashTLDist = na
if i_tlOn and not na(tlSup) and not na(tlRes)
    sY = line.get_y2(tlSup)
    rY = line.get_y2(tlRes)
    nearTL = math.abs(close - sY) < math.abs(close - rY) ? sY : rY
    dashTLDist := math.round(math.abs(close - nearTL) / math.max(atr14, 0.0001), 1)

alertcondition(i_cmeOn and gapFilled, "Liquidity Matrix — Weekend Gap Filled",
     "Liquidity Matrix: Weekend gap has been filled.")

// ============================================================================
// DASHBOARD
// ============================================================================
var table dash = table.new(position.bottom_right, 2, 20,
     bgcolor      = color.new(C_BG, 10),
     border_color = color.new(#30363d, 20), border_width=1,
     frame_color  = color.new(#30363d, 40), frame_width=1)

if i_dash and barstate.islast
    ds  = i_dashSize == "Tiny" ? size.tiny : i_dashSize == "Small" ? size.small : size.normal
    pos = switch i_dashPos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        =>               position.bottom_right
    table.set_position(dash, pos)

    cW   = color.new(#ffffff, 0)
    cM   = color.new(C_MUTED, 0)
    cP   = color.new(C_PANEL, 0)
    cBSL = color.new(C_BEAR,  0)
    cSSL = color.new(C_BULL,  0)
    cGLD = color.new(C_GOLD,  0)

    tStr = trendDir > 0 ? "▲ BULL" : trendDir < 0 ? "▼ BEAR" : "● RANGING"
    tCol = trendDir > 0 ? cSSL : trendDir < 0 ? cBSL : cM
    hCol = color.new(trendDir > 0 ? C_BULL : trendDir < 0 ? C_BEAR : C_MUTED, 75)

    // ── Row 0 — Header ──
    table.cell(dash, 0, 0, "LIQ MATRIX",   bgcolor=hCol,            text_color=cW, text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0",           bgcolor=hCol,            text_color=cW, text_size=ds, text_halign=text.align_right)

    // ── Row 1 — Trend ──
    table.cell(dash, 0, 1, "Trend",          bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 1, tStr,             bgcolor=cP, text_color=tCol, text_size=ds, text_halign=text.align_right)

    // ── Row 2 — Liquidity zone counts ──
    zoneStr = str.tostring(aBSL) + " BSL  " + str.tostring(aSSL) + " SSL"
    table.cell(dash, 0, 2, "Liq Zones",      bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 2, zoneStr,          bgcolor=cP, text_color=cW,  text_size=ds, text_halign=text.align_right)

    // ── Row 3 — Nearest BSL ──
    table.cell(dash, 0, 3, "Nearest BSL",    bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(nearBSL) ? "—" : str.tostring(nearBSL, format.mintick), bgcolor=cP, text_color=cBSL, text_size=ds, text_halign=text.align_right)

    // ── Row 4 — Nearest SSL ──
    table.cell(dash, 0, 4, "Nearest SSL",    bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 4, na(nearSSL) ? "—" : str.tostring(nearSSL, format.mintick), bgcolor=cP, text_color=cSSL, text_size=ds, text_halign=text.align_right)

    // ── Row 5 — Highest probability zone ──
    probStr = na(dashBestPrice) ? "—" : str.tostring(math.round(dashBestProb)) + "%  " + str.tostring(dashBestPrice, format.mintick)
    probCol = na(dashBestPrice) ? cM : dashBestBull ? cSSL : cBSL
    table.cell(dash, 0, 5, "Top Zone",       bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 5, probStr,          bgcolor=cP, text_color=probCol, text_size=ds, text_halign=text.align_right)

    // ── Row 6 — Safe SL ──
    slStr = na(dashSL) ? "—" : str.tostring(dashSL, format.mintick)
    slCol = na(dashSL) ? cM : dashSLBull ? cSSL : cBSL
    table.cell(dash, 0, 6, "Safe SL",        bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 6, slStr,            bgcolor=cP, text_color=slCol, text_size=ds, text_halign=text.align_right)

    // ── Row 7 — ATR ──
    table.cell(dash, 0, 7, "ATR (14)",       bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(atr14, format.mintick), bgcolor=cP, text_color=cW, text_size=ds, text_halign=text.align_right)

    // ── Row 8 — Divider: HTF ──
    table.cell(dash, 0, 8, "── HTF ──",      bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 8, i_htfOn ? "ON" : "OFF", bgcolor=cP, text_color=i_htfOn ? cGLD : cM, text_size=ds, text_halign=text.align_right)

    // ── Row 9 — Nearest HTF above ──
    table.cell(dash, 0, 9, "HTF Above",      bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 9, na(dashHTFAbove) ? "—" : str.tostring(dashHTFAbove, format.mintick), bgcolor=cP, text_color=cBSL, text_size=ds, text_halign=text.align_right)

    // ── Row 10 — Nearest HTF below ──
    table.cell(dash, 0, 10, "HTF Below",     bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 10, na(dashHTFBelow) ? "—" : str.tostring(dashHTFBelow, format.mintick), bgcolor=cP, text_color=cSSL, text_size=ds, text_halign=text.align_right)

    // ── Row 11 — Divider: Liquidity engines ──
    table.cell(dash, 0, 11, "── Market ──",  bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 11, "",              bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_right)

    // ── Row 12 — Weekend gap status ──
    gapStr = not i_cmeOn ? "OFF" : na(cme_fridayClose2) ? "—" : gapWasFilled ? "✓ Filled" : dashGapOpen ? (dashGapBull ? "▲ " : "▼ ") + str.tostring(dashGapPct, "#.##") + "%" : "—"
    gapCol = not i_cmeOn ? cM : gapWasFilled ? cSSL : dashGapBull ? cSSL : cBSL
    table.cell(dash, 0, 12, "Gap",           bgcolor=cP, text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 12, gapStr,          bgcolor=cP, text_color=gapCol, text_size=ds, text_halign=text.align_right)

    // ── Row 13 — Trendline distance ──
    tlStr = not i_tlOn ? "OFF" : na(dashTLDist) ? "—" : str.tostring(dashTLDist) + "× ATR"
    table.cell(dash, 0, 13, "TL Dist",       bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 13, tlStr,           bgcolor=cP, text_color=cW,  text_size=ds, text_halign=text.align_right)

    // ── Row 14 — BOS structure ──
    smcStr = not i_smcOn ? "OFF" : "Active"
    table.cell(dash, 0, 14, "BOS/CHoCH",     bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 14, smcStr,          bgcolor=cP, text_color=i_smcOn ? cGLD : cM, text_size=ds, text_halign=text.align_right)

    // ── Row 15 — EQH/EQL count ──
    eqlStr = not i_eqlOn ? "OFF" : str.tostring(pivH_arr.size()) + " H  " + str.tostring(pivL_arr.size()) + " L"
    table.cell(dash, 0, 15, "EQH/EQL",       bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 15, eqlStr,          bgcolor=cP, text_color=cW,  text_size=ds, text_halign=text.align_right)

    // ── Row 16 — Active engines ──
    table.cell(dash, 0, 16, "Engines",       bgcolor=cP, text_color=cM,  text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 16, str.tostring(dashEngines) + " active", bgcolor=cP, text_color=cGLD, text_size=ds, text_halign=text.align_right)

    // ── Row 17 — Divergence ──
    divStr = not i_divOn ? "OFF" : divBullish ? "▲ Bullish" : divBearish ? "▼ Bearish" : "None"
    divCol = not i_divOn ? cM : divBullish ? cSSL : divBearish ? cBSL : cM
    table.cell(dash, 0, 17, "Divergence",    bgcolor=color.new(C_BG, 0), text_color=cM,   text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 17, divStr,          bgcolor=color.new(C_BG, 0), text_color=divCol, text_size=ds, text_halign=text.align_right)

    // ── Row 18 — Brand ──
    table.cell(dash, 0, 18, "ANONYCRYPTOUS", bgcolor=color.new(C_BG, 0), text_color=color.new(C_PURP, 0), text_size=ds, text_halign=text.align_left)
    table.cell(dash, 1, 18, "v1.0",          bgcolor=color.new(C_BG, 0), text_color=cM,                   text_size=ds, text_halign=text.align_right)

// ============================================================================
// SUPPLY / DEMAND + BOS ENGINE — direct port from SMC Lite v6
// All in one group: i_sdOn controls zones, BOS always fires when zone broken
// ============================================================================

f_sd_array_add_pop(arr, val) =>
    array.unshift(arr, val)
    array.pop(arr)

f_sd_sh_sl_labels(arr, swing_type) =>
    var string lbl = na
    if swing_type == 1
        lbl := array.get(arr, 0) >= array.get(arr, 1) ? "HH" : "LH"
        lCol = lbl == "HH" ? color.new(C_BEAR, 0) : color.new(C_MUTED, 30)
        label.new(bar_index - i_smcLen, array.get(arr, 0), text=lbl, style=label.style_label_down, textcolor=lCol, color=C_TRANS, size=size.tiny)
    else if swing_type == -1
        lbl := array.get(arr, 0) >= array.get(arr, 1) ? "HL" : "LL"
        lCol = lbl == "HL" ? color.new(C_BULL, 0) : color.new(C_MUTED, 30)
        label.new(bar_index - i_smcLen, array.get(arr, 0), text=lbl, style=label.style_label_up, textcolor=lCol, color=C_TRANS, size=size.tiny)

f_sd_check_overlap(new_poi, box_array, atrV) =>
    atr_thresh = atrV * 2
    ok = true
    for i = 0 to array.size(box_array) - 1 by 1
        bx = array.get(box_array, i)
        if not na(bx)
            t = box.get_top(bx)
            b = box.get_bottom(bx)
            p = (t + b) / 2
            if new_poi >= p - atr_thresh and new_poi <= p + atr_thresh
                ok := false
                break
            else
                ok := true
    ok

f_sd_draw(val_arr, bn_arr, box_arr, lbl_arr, box_type, atrV) =>
    atr_buf  = atrV * (i_sdWidth / 10)
    box_left = array.get(bn_arr, 0)
    var float box_top    = 0.0
    var float box_bottom = 0.0
    var float poi        = 0.0
    if box_type == 1
        box_top    := array.get(val_arr, 0)
        box_bottom := box_top - atr_buf
        poi        := (box_top + box_bottom) / 2
    else if box_type == -1
        box_bottom := array.get(val_arr, 0)
        box_top    := box_bottom + atr_buf
        poi        := (box_top + box_bottom) / 2
    if f_sd_check_overlap(poi, box_arr, atrV)
        if box_type == 1
            box.delete(array.get(box_arr, array.size(box_arr) - 1))
            f_sd_array_add_pop(box_arr, box.new(left=box_left, top=box_top, right=bar_index, bottom=box_bottom, border_color=i_sdSupplyOut, bgcolor=i_sdSupplyCol, extend=extend.right))
            box.delete(array.get(lbl_arr, array.size(lbl_arr) - 1))
            if i_sdMidline
                f_sd_array_add_pop(lbl_arr, box.new(left=box_left, top=poi, right=bar_index, bottom=poi, border_color=i_sdMidCol, bgcolor=i_sdMidCol, extend=extend.right))
            else
                f_sd_array_add_pop(lbl_arr, box.new(left=bar_index, top=poi, right=bar_index, bottom=poi, border_color=C_TRANS, bgcolor=C_TRANS))
        else if box_type == -1
            box.delete(array.get(box_arr, array.size(box_arr) - 1))
            f_sd_array_add_pop(box_arr, box.new(left=box_left, top=box_top, right=bar_index, bottom=box_bottom, border_color=i_sdDemandOut, bgcolor=i_sdDemandCol, extend=extend.right))
            box.delete(array.get(lbl_arr, array.size(lbl_arr) - 1))
            if i_sdMidline
                f_sd_array_add_pop(lbl_arr, box.new(left=box_left, top=poi, right=bar_index, bottom=poi, border_color=i_sdMidCol, bgcolor=i_sdMidCol, extend=extend.right))
            else
                f_sd_array_add_pop(lbl_arr, box.new(left=bar_index, top=poi, right=bar_index, bottom=poi, border_color=C_TRANS, bgcolor=C_TRANS))

f_sd_to_bos(box_arr, bos_arr, lbl_arr, zone_type) =>
    if zone_type == 1
        for i = 0 to array.size(box_arr) - 1 by 1
            bx = array.get(box_arr, i)
            if not na(bx)
                lvl = box.get_top(bx)
                if close >= lvl
                    copied = box.copy(bx)
                    f_sd_array_add_pop(bos_arr, copied)
                    mid = (box.get_top(bx) + box.get_bottom(bx)) / 2
                    box.set_top(array.get(bos_arr, 0), mid)
                    box.set_bottom(array.get(bos_arr, 0), mid)
                    box.set_extend(array.get(bos_arr, 0), extend.none)
                    box.set_right(array.get(bos_arr, 0), bar_index)
                    box.set_bgcolor(array.get(bos_arr, 0), color.new(i_bosCol, 85))
                    box.set_border_color(array.get(bos_arr, 0), i_bosCol)
                    box.set_border_width(array.get(bos_arr, 0), i_smcWidth)
                    box.set_text(array.get(bos_arr, 0), "BOS")
                    box.set_text_color(array.get(bos_arr, 0), i_bosCol)
                    box.set_text_size(array.get(bos_arr, 0), size.small)
                    box.set_text_halign(array.get(bos_arr, 0), text.align_center)
                    box.set_text_valign(array.get(bos_arr, 0), text.align_center)
                    box.delete(array.get(box_arr, i))
                    box.delete(array.get(lbl_arr, i))
    if zone_type == -1
        for i = 0 to array.size(box_arr) - 1 by 1
            bx = array.get(box_arr, i)
            if not na(bx)
                lvl = box.get_bottom(bx)
                if close <= lvl
                    copied = box.copy(bx)
                    f_sd_array_add_pop(bos_arr, copied)
                    mid = (box.get_top(bx) + box.get_bottom(bx)) / 2
                    box.set_top(array.get(bos_arr, 0), mid)
                    box.set_bottom(array.get(bos_arr, 0), mid)
                    box.set_extend(array.get(bos_arr, 0), extend.none)
                    box.set_right(array.get(bos_arr, 0), bar_index)
                    box.set_bgcolor(array.get(bos_arr, 0), color.new(i_bosCol, 85))
                    box.set_border_color(array.get(bos_arr, 0), i_bosCol)
                    box.set_border_width(array.get(bos_arr, 0), i_smcWidth)
                    box.set_text(array.get(bos_arr, 0), "BOS")
                    box.set_text_color(array.get(bos_arr, 0), i_bosCol)
                    box.set_text_size(array.get(bos_arr, 0), size.small)
                    box.set_text_halign(array.get(bos_arr, 0), text.align_center)
                    box.set_text_valign(array.get(bos_arr, 0), text.align_center)
                    box.delete(array.get(box_arr, i))
                    box.delete(array.get(lbl_arr, i))

f_sd_extend(box_arr) =>
    for i = 0 to array.size(box_arr) - 1 by 1
        bx = array.get(box_arr, i)
        if not na(bx)
            box.set_right(bx, bar_index + 100)

// State arrays
sd_atr = ta.atr(50)
sd_PH  = ta.pivothigh(high, i_smcLen, i_smcLen)
sd_PL  = ta.pivotlow (low,  i_smcLen, i_smcLen)

var sd_highVals      = array.new_float(5, 0.0)
var sd_lowVals       = array.new_float(5, 0.0)
var sd_highBNs       = array.new_int(5, 0)
var sd_lowBNs        = array.new_int(5, 0)
var sd_supplyBox     = array.new_box(i_sdHistory, na)
var sd_demandBox     = array.new_box(i_sdHistory, na)
var sd_supplyPOI     = array.new_box(i_sdHistory, na)
var sd_demandPOI     = array.new_box(i_sdHistory, na)
var sd_supplyBOS     = array.new_box(5, na)
var sd_demandBOS     = array.new_box(5, na)

// New swing high
if not na(sd_PH)
    f_sd_array_add_pop(sd_highVals, sd_PH)
    f_sd_array_add_pop(sd_highBNs, bar_index[i_smcLen])
    if i_smcLabels
        f_sd_sh_sl_labels(sd_highVals, 1)
    if i_sdOn
        f_sd_draw(sd_highVals, sd_highBNs, sd_supplyBox, sd_supplyPOI, 1, sd_atr)

// New swing low
else if not na(sd_PL)
    f_sd_array_add_pop(sd_lowVals, sd_PL)
    f_sd_array_add_pop(sd_lowBNs, bar_index[i_smcLen])
    if i_smcLabels
        f_sd_sh_sl_labels(sd_lowVals, -1)
    if i_sdOn
        f_sd_draw(sd_lowVals, sd_lowBNs, sd_demandBox, sd_demandPOI, -1, sd_atr)

// BOS conversion — only when SD zones exist and BOS enabled
if i_sdOn and i_smcOn
    f_sd_to_bos(sd_supplyBox, sd_supplyBOS, sd_supplyPOI, 1)
    f_sd_to_bos(sd_demandBox, sd_demandBOS, sd_demandPOI, -1)

// Extend active zones
if i_sdOn
    f_sd_extend(sd_supplyBox)
    f_sd_extend(sd_demandBox)


// ============================================================================
// LIQUIDITY VOIDS ENGINE — ported from Liquidity Voids v6
// ============================================================================
var array<VoidBox> lq_voids  = array.new<VoidBox>()
var array<label>   lq_labels = array.new<label>()

f_createVoid(bool isBullish, float topP, float bottomP, float volIn) =>
    int   l  = 13
    float st = math.abs(topP - bottomP) / l
    layerArr = array.new<VoidLayer>()
    vCol     = isBullish ? i_voidBC : i_voidSC
    for i = 0 to l - 1
        lTop = bottomP + (i + 1) * st
        lBot = bottomP + i * st
        nb   = box.new(bar_index, lTop, bar_index, lBot,
                 bgcolor=vCol, border_color=na)
        array.push(layerArr, VoidLayer.new(nb, lTop, lBot, false))
    array.push(lq_voids, VoidBox.new(layerArr, bar_index, volIn))
    vLbl = i_voidVol ? label.new(bar_index, topP, f_fmtVol(volIn),
             color=C_TRANS, textcolor=color.new(C_MUTED, 0),
             style=label.style_label_left, size=size.tiny) : na
    array.push(lq_labels, vLbl)

if i_voidOn
    voidPer = i_voidMode == "Present" ? last_bar_index - bar_index <= i_voidBack : true
    voidATR = ta.atr(144) * i_voidTH

    if voidPer
        voidVol = math.sum(volume, 3)
        bull = (low - high[2]) > voidATR and low > high[2] and close[1] > high[2]
        bear = (low[2] - high) > voidATR and high < low[2] and close[1] < low[2]

        if bull
            if bull[1]
                f_createVoid(true, low[1], high[2], voidVol)
            else
                f_createVoid(true, low, high[2], voidVol)

        if bear
            if bear[1]
                f_createVoid(false, low[2], high[1], voidVol)
            else
                f_createVoid(false, low[2], high, voidVol)

    // Update voids
    if array.size(lq_voids) > 0
        vIdx = array.size(lq_voids) - 1
        while vIdx >= 0
            if vIdx < array.size(lq_voids)
                v = array.get(lq_voids, vIdx)
                lIdx = 0
                while lIdx < array.size(v.layers)
                    layer = array.get(v.layers, lIdx)
                    if high > layer.bottomPrice and low < layer.topPrice and not layer.isFilled
                        if i_voidVF
                            box.set_bgcolor(layer.boxObj, i_voidFC)
                            layer.isFilled := true
                        else
                            box.delete(layer.boxObj)
                            array.remove(v.layers, lIdx)
                            lIdx -= 1
                    if not layer.isFilled
                        box.set_right(layer.boxObj, bar_index)
                    lIdx += 1
                // Update label x only if void still has unfilled layers
                if vIdx < array.size(lq_labels)
                    lbl = array.get(lq_labels, vIdx)
                    if not na(lbl)
                        hasUnfilled = false
                        for li = 0 to array.size(v.layers) - 1
                            if not array.get(v.layers, li).isFilled
                                hasUnfilled := true
                                break
                        if hasUnfilled
                            label.set_x(lbl, bar_index)
            vIdx -= 1

        // Remove empty voids
        cIdx = array.size(lq_voids) - 1
        while cIdx >= 0
            v = array.get(lq_voids, cIdx)
            if array.size(v.layers) == 0
                array.remove(lq_voids, cIdx)
            cIdx -= 1

        // Cap at 500
        while array.size(lq_voids) > 500
            array.shift(lq_voids)


// ============================================================================
// RSI DIVERGENCE ENGINE
// ============================================================================

// — Always-on calculations (ta.* must always execute, not inside if blocks) —
float divRSI    = ta.rsi(close, i_divRsiLen)
float divATR    = ta.atr(i_divATRLen)
int   divWindow = i_divSens == "High" ? 3 : i_divSens == "Low" ? 10 : 5

float divPivHRsi = ta.pivothigh(divRSI, divWindow, divWindow)
float divPivLRsi = ta.pivotlow (divRSI, divWindow, divWindow)

// — Persistent state (top-level var declarations) —
var float divLastHRsi   = na
var float divLastLRsi   = na
var float divLastHPrice = na
var float divLastLPrice = na
var int   divLastHBar   = na
var int   divLastLBar   = na

var bool  divPendBull   = false
var bool  divPendBear   = false
var float divTStop      = na
var bool  divTActive    = false
var float divPrevStop   = na

// — Reset divergence signals each bar —
divBullish := false
divBearish := false

// — Engine (only runs visual/logic when enabled) —
if i_divOn
    // Bearish divergence: price higher high, RSI lower high
    if not na(divPivHRsi)
        if not na(divLastHRsi) and divRSI[divWindow] < divLastHRsi and high[divWindow] > divLastHPrice
            divBearish := true
            if i_divBear
                bTop = high[divWindow]
                bBot = low[divWindow]
                rangeLen = bar_index - divWindow - divLastHBar
                if rangeLen > 0
                    for k = 0 to rangeLen - 1
                        bTop := math.max(bTop, high[k + divWindow])
                        bBot := math.min(bBot, low[k + divWindow])
                box.new(divLastHBar, bTop, bar_index - divWindow, bBot,
                     border_color=i_divBearC, border_style=line.style_solid,
                     bgcolor=color.new(i_divBearC, 88), force_overlay=true)
                label.new(divLastHBar, high[bar_index - divLastHBar], "",
                     style=label.style_circle, color=color.new(i_divBearC, 75), size=size.tiny)
                label.new(bar_index - divWindow, high[divWindow], "",
                     style=label.style_circle, color=color.new(i_divBearC, 75), size=size.tiny)
        divLastHRsi   := divRSI[divWindow]
        divLastHPrice := high[divWindow]
        divLastHBar   := bar_index - divWindow

    // Bullish divergence: price lower low, RSI higher low
    if not na(divPivLRsi)
        if not na(divLastLRsi) and divRSI[divWindow] > divLastLRsi and low[divWindow] < divLastLPrice
            divBullish := true
            if i_divBull
                bTop = high[divWindow]
                bBot = low[divWindow]
                rangeLen = bar_index - divWindow - divLastLBar
                if rangeLen > 0
                    for k = 0 to rangeLen - 1
                        bTop := math.max(bTop, high[k + divWindow])
                        bBot := math.min(bBot, low[k + divWindow])
                box.new(divLastLBar, bTop, bar_index - divWindow, bBot,
                     border_color=i_divBullC, border_style=line.style_solid,
                     bgcolor=color.new(i_divBullC, 88), force_overlay=true)
                label.new(divLastLBar, low[bar_index - divLastLBar], "",
                     style=label.style_circle, color=color.new(i_divBullC, 75), size=size.tiny)
                label.new(bar_index - divWindow, low[divWindow], "",
                     style=label.style_circle, color=color.new(i_divBullC, 75), size=size.tiny)
        divLastLRsi   := divRSI[divWindow]
        divLastLPrice := low[divWindow]
        divLastLBar   := bar_index - divWindow

    // Trailing stop — pending state set on divergence signal
    if divBullish
        divPendBull := true
        divPendBear := false
    if divBearish
        divPendBear := true
        divPendBull := false

    // Activate stop on RSI 50 cross after divergence
    if divPendBull and ta.crossover(divRSI, 50) and not divTActive
        divTStop    := low - divATR * i_divATRMult
        divTActive  := true
        divPendBull := false
    if divPendBear and ta.crossunder(divRSI, 50) and not divTActive
        divTStop    := high + divATR * i_divATRMult
        divTActive  := true
        divPendBear := false

    // Trail and invalidate stop
    divPrevStop := divTStop
    if divTActive
        if divRSI >= 50 and divRSI < i_divOB
            divTStop := math.max(nz(divTStop), low - divATR * i_divATRMult)
            if close < divTStop or divRSI >= i_divOB
                divTActive := false
                divTStop   := na
        else if divRSI > i_divOS and divRSI < 50
            divTStop := math.min(nz(divTStop), high + divATR * i_divATRMult)
            if close > divTStop or divRSI <= i_divOS
                divTActive := false
                divTStop   := na
        else
            divTActive := false
            divTStop   := na

    if i_divTrail and divTActive and not na(divPrevStop) and not na(divTStop)
        line.new(bar_index - 1, divPrevStop, bar_index, divTStop,
             color=divRSI >= 50 ? i_divBullC : i_divBearC,
             width=2, force_overlay=true)

// — Candle coloring — top-level required (barcolor cannot be in local scope) —
color divCanCol = na
if i_divOn and i_divCandles
    if divRSI >= 50 and divRSI < i_divOB
        divCanCol := color.from_gradient(divRSI, 50, i_divOB, color.new(i_divBullC, 85), color.new(i_divBullC, 10))
    else if divRSI > i_divOS and divRSI < 50
        divCanCol := color.from_gradient(divRSI, i_divOS, 50, color.new(i_divBearC, 10), color.new(i_divBearC, 85))
barcolor(divCanCol)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(bar_index == lastBullBar and isMajorSweep,
     "Liquidity Matrix — Major Bull Sweep",
     "Liquidity Matrix: MAJOR bullish sweep detected. High volume SSL cleared.")
alertcondition(bar_index == lastBullBar and not isMajorSweep,
     "Liquidity Matrix — Bull Sweep",
     "Liquidity Matrix: Bullish sweep detected. SSL cleared — potential long setup.")
alertcondition(bar_index == lastBearBar and isMajorSweep,
     "Liquidity Matrix — Major Bear Sweep",
     "Liquidity Matrix: MAJOR bearish sweep detected. High volume BSL cleared.")
alertcondition(bar_index == lastBearBar and not isMajorSweep,
     "Liquidity Matrix — Bear Sweep",
     "Liquidity Matrix: Bearish sweep detected. BSL cleared — potential short setup.")
alertcondition(ta.crossover(trendDir, 0),
     "Liquidity Matrix — Bullish Trend",
     "Liquidity Matrix: Trend shifted bullish.")
alertcondition(ta.crossunder(trendDir, 0),
     "Liquidity Matrix — Bearish Trend",
     "Liquidity Matrix: Trend shifted bearish.")
````
