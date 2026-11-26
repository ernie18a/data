# Supertrend Extensions [BOSWaves]

- url: https://www.tradingview.com/script/eRDuDQdy-Supertrend-Extensions-BOSWaves/
- type: indicator
- pine_id: PUB;526571dbf41c4c1ca4c10fbf9b7f39f5
- version: 1.0

## Description

[b]Supertrend Extensions [BOSWaves] - Trend Flip Extension Mapping with Volume-Captured Deviation Level Progression[/b]

[b]Overview[/b]

Supertrend Extensions [BOSWaves] is a trend extension mapping system that projects a structured set of deviation levels from each trend flip, where level spacing, crossing detection, and volume capture behavior are driven by the instrument's average range rather than fixed price distances, creating a dynamic extension framework that scales to any instrument or timeframe and records participation data at each milestone as price progresses through the projected levels.

[image]https://www.tradingview.com/x/9qZHDJBl/[/image]

Instead of treating a trend flip as simply a directional signal, each flip generates an immediate sequence of extension levels projected from the flip price in the new trend direction. These levels serve as structured targets and monitoring points throughout the developing move. When price crosses each level, it converts from a numbered solid line to a dashed reference displaying the crossing bar's volume, building a running record of participation quality at each stage of the trend's extension.

This creates a framework that transforms every trend flip into the origin point of a fully mapped extension sequence. The Supertrend band provides the directional anchor that triggers and validates each new projection set, while the deviation levels and their volume capture layer provide the structural and participatory intelligence needed to monitor how the trend is developing from flip through to full extension.

Price is therefore tracked not just for direction but for progression through a volatility-calibrated extension map where participation at each crossing reveals whether the move is being driven by conviction or fading with each successive level.

[b]Conceptual Framework[/b]

Supertrend Extensions is founded on the principle that the most valuable information in a trending market is not just the direction of the trend but how price is progressing through extension space from the structural origin, and whether participation at each extension milestone is confirming or undermining the case for further progression.

Standard trend indicators identify direction and provide a trailing band but offer no framework for understanding extension behavior or monitoring participation quality as price moves away from the flip. This framework addresses that gap by treating each trend flip as the start of a measurable extension sequence, projecting levels at range-calibrated distances and capturing volume data as each level is crossed to build a continuously updating picture of trend health from origin to target.

Three core principles guide the design:
[list=1]
[*]Each trend flip should immediately generate a structured extension map anchored to the flip price, providing a pre-calculated sequence of levels that serve as targets and monitoring points without requiring manual analysis.
[*]Deviation level spacing should adapt to the instrument's actual average range, ensuring levels are meaningfully spaced relative to how the instrument typically moves rather than applying identical distances across all markets and timeframes.
[*]Volume participation at each level crossing should be captured and permanently displayed, providing an objective record of whether price is moving through each extension milestone on strong or deteriorating participation.
[/list]
This shifts trend analysis from directional signal monitoring into active extension progression tracking with volume evidence accumulated at every structural milestone.

[b]Theoretical Foundation[/b]

The indicator combines a Supertrend band as the directional trigger, SMA-averaged range-derived deviation spacing for extension level placement, an array-managed line and label object system for level lifecycle management, and volume standard deviation normalization for candle color intensity.

Deviation level distances are derived from the 100-bar SMA of the high-low range multiplied by the configured deviation size, producing spacing that reflects the instrument's typical bar-level price movement and scales automatically as volatility expands or contracts between trend cycles. The array-managed line and label system clears all existing levels on each flip and projects a fresh numbered set, extending each line rightward until price crosses it or the next flip resets the map. Volume normalization divides raw volume by its rolling standard deviation to produce a score that drives candle color intensity relative to recent participation history rather than absolute values.

Four internal systems operate in tandem:
[list]
[*][i]Deviation Level Projection System[/i]: On each trend flip, clears all existing deviation lines and labels and projects a fresh numbered sequence at average range-scaled intervals from the flip price in the new trend direction.
[*][i]Level Extension and Crossing Engine[/i]: Extends each active deviation line rightward on every bar and monitors for price crossings in the trend direction, converting crossed levels to dashed references and replacing the level number label with the crossing bar's formatted volume.
[*][i]Supertrend Band Engine[/i]: Provides the directional anchor that triggers each new projection set, maintaining trailing upper and lower bands that define current trend state and flip conditions.
[*][i]Volume Intensity Candle System[/i]: Normalizes volume against its rolling standard deviation and maps the resulting score to a color gradient between a muted and fully saturated version of the trend color, communicating participation strength on every bar.
[/list]
This design ensures that every trend flip immediately produces a complete extension framework, level crossings accumulate a volume evidence trail, and candle coloring provides continuous participation context throughout the trend's development.

[b]How It Works[/b]

Supertrend Extensions evaluates price through a sequence of extension-aware and participation-monitoring processes:
[list=1]
[*][i]Trend Flip Detection[/i]: The Supertrend band registers a flip when price closes through the opposing trailing band, triggering both the signal label and the deviation level projection sequence.
[*][i]Deviation Distance Calculation[/i]: The 100-bar SMA of the high-low range is multiplied by the configured deviation size to produce the spacing distance between consecutive deviation levels for the new trend cycle.
[*][i]Level Projection on Flip[/i]: All existing deviation lines and labels are deleted and a fresh numbered set is projected from the flip bar's close, with each level placed at a sequential multiple of the deviation distance in the new trend direction.
[*][i]Level Extension[/i]: On each bar following the flip, all active deviation lines extend their right endpoint to the current bar, maintaining continuous horizontal reference lines across the developing trend.
[*][i]Crossing Detection[/i]: Each active level is tested for price crossing on every bar, with bar highs tested against bullish levels and bar lows tested against bearish levels to identify genuine price contact with each extension milestone.
[*][i]Volume Capture on Crossing[/i]: When a level is crossed, its line converts to dashed style with a dimmed color and the label text replaces the sequential number with the crossing bar's volume formatted for readability, permanently recording participation at that extension point.
[*][i]Volume Intensity Candle Coloring[/i]: Each bar's volume is divided by its 200-bar rolling standard deviation to produce a normalized score capped at four, which maps to a color gradient from muted transparency at low participation to full trend color saturation at peak volume.
[*][i]Signal Label Placement[/i]: Bullish flips produce a triangle-up label with the flip price below the Supertrend line and bearish flips produce a triangle-down label with the flip price above, anchoring each new extension map to its precise origin price.
[/list]
Together, these elements form a continuously updating extension monitoring system where flip events generate structured projection maps, level crossings accumulate volume evidence, and candle intensity communicates participation strength throughout every stage of the trend.

[b]Interpretation[/b]

Supertrend Extensions should be interpreted as a trend extension progression system with volume participation captured at each structural milestone:
[list]
[*][i]Bullish Trend State (Green)[/i]: Active when price has closed above the trailing upper band, with deviation levels projected upward from the flip price as sequential bullish extension targets.
[*][i]Bearish Trend State (Red)[/i]: Active when price has closed below the trailing lower band, with deviation levels projected downward from the flip price as sequential bearish extension targets.
[*][i]Deviation Levels (Solid, Numbered)[/i]: Uncrossed extension levels projected from the most recent flip price, numbered sequentially from one outward in the trend direction, representing the structured target sequence for the current trend cycle.
[*][i]Deviation Levels (Dashed, Volume Labeled)[/i]: Levels that have been crossed by price, converted to dashed style and displaying the crossing bar's volume rather than the level number. These form a permanent record of participation quality at each extension milestone already reached.
[*][i]Volume Labels on Crossed Levels[/i]: Volume readings at crossed levels reveal whether price moved through each extension point on meaningful participation or on thin activity, providing an accumulated evidence trail for assessing trend conviction across the full extension sequence.
[*][i]Supertrend Line[/i]: The solid colored band line provides the active trailing support or resistance reference for the current trend, serving as the invalidation boundary for the current directional state and the trigger for each new deviation level projection cycle.
[*][i]Trend Fill[/i]: Gradient fill between the Supertrend line and the bar midpoint provides a continuous visual representation of the gap between price and the structural boundary.
[*][i]▲ / ▼ Flip Signals[/i]: Triangle labels displaying the flip price mark each trend change origin, providing a clean visual anchor that corresponds to the starting point of the current deviation level projection set.
[*][i]Volume Intensity Candles[/i]: Optional candle coloring brightens with above-average participation and fades toward a muted version of the trend color on low-volume bars, providing bar-level conviction readings without leaving the price chart.
[/list]
Deviation level progression, volume at crossed levels, and candle intensity collectively provide more information than trend direction alone.

[b]Signal Logic & Visual Cues[/b]

Supertrend Extensions presents two primary trend transition signals alongside continuous extension level monitoring:
[list=1]
[*][i]Bullish Flip (▲)[/i]: Triggered when price closes above the trailing upper band, displaying the flip price below the bar and projecting a fresh set of upward deviation levels from the flip price.
[*][i]Bearish Flip (▼)[/i]: Triggered when price closes below the trailing lower band, displaying the flip price above the bar and projecting a fresh set of downward deviation levels from the flip price.
[/list]
Deviation level crossings provide continuous secondary context throughout each trend cycle, converting each extension milestone into a volume-stamped reference that builds a participation evidence log from flip to target.

Alert generation covers bullish and bearish trend flips for systematic trend monitoring and notification workflows.

[b]Strategy Integration[/b]

Supertrend Extensions fits within structured extension target and trend progression monitoring approaches:
[list]
[*][i]Deviation Level Target Sequencing[/i]: Use the projected deviation levels as a staged exit framework, planning partial position reductions at each sequential level rather than targeting a single fixed price, allowing structured progression management calibrated to each trend's specific origin and volatility context.
[*][i]Volume Confirmation at Levels[/i]: Monitor the volume displayed when deviation levels are crossed to assess participation quality at each extension stage. Sustained or increasing volume at successive crossings supports further progression, while declining volume at each level warns of weakening extension commitment.
[*][i]Flip-Based Trend Entries[/i]: Use Supertrend flip signals as primary trend initiation triggers, with the immediately projected deviation levels providing an instant target framework from the moment of entry.
[*][i]Supertrend Band Pullback Reference[/i]: Use the Supertrend line as a dynamic pullback reference within established trends, monitoring candle volume intensity on band retests for participation evidence supporting continuation rather than breakdown.
[*][i]Deviation Size Calibration by Timeframe[/i]: Adjust the deviation size multiplier to match the instrument's typical trend range at the target timeframe, ensuring the extension map spans a realistic distance relative to expected directional movement.
[*][i]Multi-Timeframe Extension Alignment[/i]: Apply higher-timeframe Supertrend state as a directional bias filter, engaging with lower-timeframe extension level sequences only when they align with the established higher-timeframe trend direction.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Deviation System[/i]: 100-bar SMA of high-low range scaled by configurable deviation size multiplier with configurable level count
[*][i]Level Lifecycle[/i]: Array-managed line and label objects cleared on each flip, extended rightward each bar, and converted to dashed references with volume labels on crossing
[*][i]Supertrend Engine[/i]: ATR-scaled trailing band with configurable multiplier and length as directional anchor and flip trigger
[*][i]Volume Normalization[/i]: 200-bar standard deviation-based scoring mapped to candle color gradient intensity
[*][i]Visualization[/i]: Solid and dashed deviation levels with volume labels, Supertrend line with trend fill, flip signal labels, and volume-intensity candle coloring
[*][i]Signal Logic[/i]: Band crossover state-switch detection with independent bullish and bearish flip conditions
[*][i]Performance Profile[/i]: Optimized for real-time execution with array-based object management and max_bars_back configuration supporting deep historical calculation
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday extension mapping for scalping with tighter deviation spacing and lower level count for fast-moving target sequences
[*][i]15 - 60 min[/i]: Session-level extension progression with balanced deviation size and moderate level count for structured intraday target management
[*][i]4H - Daily[/i]: Swing-level extension mapping with wider deviation spacing and higher level count reflecting larger price swings between flip events
[/list]
Suggested Baseline Configuration:
[list]
[*][i]ATR Multiplier[/i]: 5.0
[*][i]ATR Length[/i]: 14
[*][i]Deviation Size[/i]: 2.7
[*][i]Deviation Count[/i]: 4
[*][i]Show Signals[/i]: Enabled
[*][i]Color Candles[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's typical extension range, average bar size, and preferred level density, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Deviation levels too close together[/i]: Increase Deviation Size to spread levels further apart relative to the average bar range, producing a wider extension map that better reflects the instrument's typical trend range at the target timeframe.
[*][i]Deviation levels too far apart[/i]: Decrease Deviation Size toward 1.0 to tighten level spacing, producing more granular extension targets suited to lower timeframes or lower-volatility instruments.
[*][i]Too many levels cluttering the chart[/i]: Reduce Deviation Count to limit projected levels to the nearest and most actionable targets, focusing the extension map on realistic near-term progression milestones.
[*][i]Too few levels to cover the typical trend range[/i]: Increase Deviation Count up to the maximum of six to extend the projection sequence further, covering a wider range of potential extension targets for instruments with larger typical trending moves.
[*][i]Too many trend flips resetting the extension map[/i]: Increase the ATR Multiplier to widen the Supertrend band and require more significant price displacement before a flip resets the deviation level sequence.
[*][i]Trend flips too slow to capture structural changes[/i]: Decrease the ATR Multiplier toward 2.0 for a more responsive band that generates fresh extension maps closer to actual structural shifts in price direction.
[*][i]Candle coloring too uniform[/i]: The volume intensity gradient operates on a standard deviation basis. On instruments with very consistent volume distribution the gradient range may appear compressed, which is expected and reflects genuinely low variation in participation levels.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with sustained directional moves where deviation levels are reached sequentially and volume at each crossing provides meaningful progression confirmation
[*]Instruments with consistent average range behavior where deviation spacing calibrates reliably to the instrument's typical bar-level price movement across different trend cycles
[*]Structured target-based approaches where the deviation level sequence provides a systematic exit framework calibrated to each trend's specific origin and volatility context
[*]Multi-timeframe workflows where higher-timeframe trend direction filters lower-timeframe flip signals for directional alignment with the broader trend
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, range-bound markets where frequent trend flips reset the extension map before price reaches the first deviation level, preventing a useful progression sequence from developing
[*]Extremely volatile instruments where large individual bars cause the average range to spike, producing deviation spacing that overstates typical extension potential for subsequent trend cycles
[*]Low-volume instruments where the standard deviation-based candle coloring loses discriminative power due to irregular or thin volume distribution
[*]News-driven or gap-heavy markets where trend flips occur on discontinuous price action that distorts the average range calculation and misaligns deviation level placement relative to actual structural extension potential
[*]Consolidation environments where price oscillates near the Supertrend band without establishing the sustained directional movement required for sequential deviation level progression
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves momentum tools, order flow analysis, or market structure indicators to validate trend flip signals and assess the broader analytical context before committing to deviation level target sequences
[*][i]Volume Label Monitoring[/i]: Review volume labels on crossed deviation levels as a running confirmation log for the trend. Declining volume at successive levels suggests weakening extension commitment and warrants caution about remaining target progression.
[*][i]Deviation Level Respect[/i]: Treat uncrossed deviation levels as active areas of potential price reaction rather than guaranteed targets. Monitoring candle behavior and volume intensity as price approaches each level provides early indication of whether the level will be crossed or act as a reversal point.
[*][i]Extension Map Freshness[/i]: Recognize that deviation levels are anchored to the most recent flip price and reflect the volatility conditions at that specific origin point. As time passes within a trend cycle, reassess whether the projected levels remain relevant to current market conditions.
[*][i]State Discipline[/i]: Maintain directional bias aligned with the current Supertrend state until a confirmed flip occurs. Temporary pullbacks toward the active band that do not close through it do not constitute trend changes and should not trigger premature exits from active extension target sequences.
[/list]
[b]Disclaimer[/b]

Supertrend Extensions [BOSWaves] is a professional-grade trend extension mapping and volume participation tracking tool. It uses range-calibrated deviation level projection with volume capture at each crossing but does not predict future price movements. Results depend on market conditions, instrument volatility characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates momentum context, order flow analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Supertrend Extensions [BOSWaves]",overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gST   = "Supertrend"
const string gDev  = "Deviation Levels"
const string gProf = "Distribution Profile"
const string gVis  = "Display"

float i_mult   = input.float(5.0, "ATR Multiplier", minval = 0.5, maxval = 10.0, step = 0.5, group = gST,
     tooltip = "Controls how wide the Supertrend band is relative to volatility (ATR). Higher values produce fewer trend flips and a wider band — better for catching larger moves but slower to react. Lower values flip more frequently and track price closer — better for active markets.")
int   i_atrLen = input.int(14, "ATR Length", minval = 1, maxval = 50, group = gST,
     tooltip = "Number of bars used to calculate Average True Range (ATR). Shorter lengths react faster to recent volatility but produce noisier readings. Longer lengths smooth out the ATR and create a more stable band. 14 is the widely-used default.")

float i_devMult = input.float(2.7, "Deviation Size", minval = 0.5, maxval = 5.0, step = 0.1, group = gDev,
     tooltip = "Scales the spacing between deviation levels. Each level is placed at a multiple of the average candle range (SMA of high-low over 100 bars) from the flip price. Higher values spread levels further apart — useful on higher timeframes or more volatile instruments.")
int   i_devCnt  = input.int(4, "Deviation Count", minval = 1, maxval = 6, group = gDev,
     tooltip = "Number of price extension levels projected from each trend flip. Levels act as potential targets or areas of interest as price extends from the flip. When a level is crossed, it converts to a dashed line and displays the crossing candle's volume.")

bool  i_showSig  = input.bool(true, "Show Signals", group = gVis,
     tooltip = "Displays a label at each trend flip with the flip price. Bullish flips show a ▲ below the bar; bearish flips show a ▼ above the bar.")
bool  i_paintBar = input.bool(true, "Color Candles", group = gVis,
     tooltip = "Colors each candle based on the current trend direction. Intensity scales with relative volume — brighter candles indicate above-average volume for the current move.")
color i_bullCol  = input.color(#00ff88, "Bullish", inline = "c", group = gVis,
     tooltip = "Color applied to bullish trend candles, the Supertrend line, and flip signals when price is above the band.")
color i_bearCol  = input.color(#ff3366, "Bearish", inline = "c", group = gVis,
     tooltip = "Color applied to bearish trend candles, the Supertrend line, and flip signals when price is below the band.")

// ┌────────────────────────────── BOSWaves ─ Supertrend ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float atr      = ta.atr(i_atrLen)
float rawUpper = hl2 + atr * i_mult
float rawLower = hl2 - atr * i_mult

var float trailUpper = na
var float trailLower = na

trailLower := not na(trailLower[1]) and close[1] > trailLower[1] ? math.max(rawLower, trailLower[1]) : rawLower
trailUpper := not na(trailUpper[1]) and close[1] < trailUpper[1] ? math.min(rawUpper, trailUpper[1]) : rawUpper

var int trend = 0
if close > trailUpper
    trend := 1
if close < trailLower
    trend := -1

float stLine    = trend == 1 ? trailLower : trailUpper
bool  trendFlip = trend != trend[1] and trend[1] != 0
bool  bullFlip  = trend == 1 and trend[1] == -1
bool  bearFlip  = trend == -1 and trend[1] == 1

color trendCol = trend == 1 ? i_bullCol : i_bearCol

// Track trend start
var int trendStart = na
if trendFlip
    trendStart := bar_index

int lookback = bar_index - nz(trendStart, bar_index)

// ┌────────────────────────────── BOSWaves ─ Deviation Levels ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float devDist = ta.sma(high - low, 100) * i_devMult

var devLines  = array.new<line>()
var devLabels = array.new<label>()

if trendFlip
    // Cleanup old levels
    for ln in devLines
        ln.delete()
    devLines.clear()
    for lb in devLabels
        lb.delete()
    devLabels.clear()

    // Draw new levels
    for i = 1 to i_devCnt
        float y = trend == 1 ? close + devDist * i : close - devDist * i

        devLines.push(line.new(bar_index, y, bar_index, y,
             color = color.new(chart.fg_color, 50), width = 2))
        devLabels.push(label.new(bar_index, y, str.tostring(i),
             style = label.style_label_right,
             color = color.new(color.black, 100),
             textcolor = chart.fg_color,
             size = size.normal))

// Extend and check if crossed
if devLines.size() > 0
    for i = devLines.size() - 1 to 0
        line ln  = devLines.get(i)
        label lb = devLabels.get(i)
        float lvl = ln.get_y1()

        ln.set_x2(bar_index)

        // Crossed — show volume and dash
        if trend == 1 and high > lvl and high[1] <= lvl
            lb.set_text(str.tostring(volume, format.volume))
            ln.set_x2(bar_index)
            ln.set_style(line.style_dashed)
            ln.set_color(color.new(chart.fg_color, 70))
            devLines.remove(i)
            devLabels.remove(i)

        if trend == -1 and low < lvl and low[1] >= lvl
            lb.set_text(str.tostring(volume, format.volume))
            ln.set_x2(bar_index)
            ln.set_style(line.style_dashed)
            ln.set_color(color.new(chart.fg_color, 70))
            devLines.remove(i)
            devLabels.remove(i)

// ┌────────────────────────────── BOSWaves ─ Plot Supertrend ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
pST    = plot(not trendFlip ? stLine : na, "Supertrend", color.new(trendCol, 15), 2, plot.style_linebr)
pPrice = plot(hl2, display = display.none, editable = false)
fill(pST, pPrice, hl2, stLine, color(na), color.new(trendCol, 80))

// Candle coloring with volume intensity
float volNorm = ta.stdev(volume, 200)
float nVol    = volNorm > 0 ? math.min(4., volume / volNorm) : 1.
color candleCol = color.from_gradient(nVol, 0, 4, color.new(trendCol, 70), trendCol)
barcolor(i_paintBar ? candleCol : na)

// Signals
if i_showSig and bullFlip
    label.new(bar_index, stLine, "▲\n" + str.tostring(close, format.mintick),
         style = label.style_label_up, textcolor = i_bullCol,
         color = color.new(color.black, 100), size = size.normal)

if i_showSig and bearFlip
    label.new(bar_index, stLine, str.tostring(close, format.mintick) + "\n▼",
         style = label.style_label_down, textcolor = i_bearCol,
         color = color.new(color.black, 100), size = size.normal)

// ┌────────────────────────────── BOSWaves ─ Alerts ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
alertcondition(bullFlip, "Bullish Flip", "Supertrend flipped bullish on {{ticker}}")
alertcondition(bearFlip, "Bearish Flip", "Supertrend flipped bearish on {{ticker}}")
````
