# Smart Trader, Episode 07, ICS Geometric Buyers/Sellers Pressure

- url: https://www.tradingview.com/script/uEmD99bf-Smart-Trader-Episode-07-ICS-Geometric-Buyers-Sellers-Pressure/
- type: indicator
- pine_id: PUB;629eb3417dca470fbd0b4403e1e6d970
- version: 1.0

## Description

🔶 Overview

ICS Geometric Buyer/Seller Pressure measures the real-time balance between buying and selling forces through a geometric framework built on triangle areas. Rather than relying on volume, oscillators, or moving-average crossovers, this indicator constructs two right triangles on every bar — one representing seller pressure above the current price, one representing buyer pressure below it — and computes their areas inside a normalized coordinate system called the Isotropic Coordinate System (ICS).

The ICS transforms raw price and time into a dimensionless plane using Yang-Zhang composite volatility as the scaling factor. Because both axes are divided by the same volatility estimate, the resulting triangle areas carry no unit — they are pure geometric ratios. This makes the pressure reading comparable across any instrument, any timeframe, and any price scale, without the trader needing to adjust parameters when switching charts.

From these two normalized areas, the indicator derives a single metric called B, which condenses the entire buyer-versus-seller balance into a value between −1 and +1. B is then converted into intuitive percentage readings (Red % for seller dominance, Blue % for buyer dominance) and visualized through a gradient barometer column, a triangle fan overlay, and data-window plots ready for alerts.

🔶 Conceptual framework

To measure the real-time balance between buying and selling forces, this indicator takes a geometric approach rather than relying on volume analysis, oscillator divergences, or moving-average crossovers. Two right triangles are constructed on every bar — one above the current price toward the range ceiling, one below toward the range floor — and their areas are compared to determine which side of the market currently dominates.

Computing triangle areas in raw price-versus-time coordinates, however, introduces a structural problem: the same price movement produces a different geometric shape depending on the chart's zoom level, time compression, or display resolution. A 30-point rally on a compressed weekly chart creates a steep, narrow triangle; the identical rally on a stretched intraday chart creates a flat, wide one. The areas differ even though the underlying market event is the same.

To eliminate this distortion, the indicator applies a normalization layer referred to here as the Isotropic Coordinate System (ICS). The principle behind it is dimensional analysis — a well-established technique in physics and engineering for removing unit-dependent artifacts from measurements. The horizontal axis (time) is rescaled by dividing bar offsets by sigma, and the vertical axis (price) is rescaled by dividing the natural logarithm of price by the same sigma. Because both axes share the same divisor, the resulting coordinate plane is isotropic: triangle areas reflect only the structural relationship between price and range boundaries, not how the chart happens to be displayed.

The sigma used for this normalization is the Yang-Zhang (2000) composite volatility estimator, a published academic method (Journal of Business, Vol. 73, No. 3). It combines three independent variance components — overnight (close-to-open), intraday (open-to-close), and the Rogers-Satchell high-low-close estimator — into a single unbiased measure with minimum-variance weighting. This makes sigma robust across instruments with overnight gaps (equities, futures) and those that trade continuously (forex, crypto).

The practical result: the normalization layer adapts to the volatility regime of each instrument, making triangle areas structurally comparable across different charts and timeframes and reducing the need for manual recalibration when switching instruments.

🔶 The B metric: from triangle geometry to a single number

The core output of this indicator is a single value called B, which captures the instantaneous buyer-versus-seller balance in one dimensionless number.

Picture any bar on your chart. The indicator draws two right triangles around it. The upper triangle sits between the bar's high and the range ceiling: its three vertices are (1) the current bar's high, (2) the range ceiling at the current bar, and (3) the range ceiling at the prime-offset bar, 101 bars back. This triangle represents seller territory — the geometric "room" that sellers occupy above the current price. The lower triangle mirrors this below: its vertices are the current bar's low, the range floor at the current bar, and the range floor at that same prime-offset bar. This is buyer territory — the room below the current price. The larger the seller triangle relative to the buyer triangle, the more the market is tilted toward selling pressure, and vice versa.

Why prime-numbered offsets?

The indicator uses the first 25 prime numbers (3, 5, 7, 11, ... 97, 101) as its sampling offsets. Prime numbers share no common factors with each other or with any periodic cycle in the data. When a signal is sampled at evenly spaced intervals (e.g. every 10, 20, 30 bars), there is a risk that the sampling grid locks onto a periodic pattern in the price — a weekly cycle, an options expiration rhythm, or any recurring structure — and either amplifies or masks it. This is a form of harmonic aliasing. Prime offsets avoid this: because no prime is a multiple of any other, the sampling set {3, 5, 7, ... 101} is maximally non-periodic, ensuring that each offset captures a structurally independent slice of the price range.

https://www.tradingview.com/x/cIxc9V81/

Two roles: measurement and visualization

For the B calculation itself, only the widest triangle is used — the one anchored at prime offset 101. This single pair of triangles (upper and lower) captures the broadest structural pressure across the entire lookback window. The remaining 24 primes serve a visual role: they generate the triangle fan overlay you see on the chart. But this visual layer is not merely decorative. Each triangle in the fan maps a pressure boundary at a different time horizon. 

https://www.tradingview.com/x/jpsySbp8/

As the screenshot above illustrates, candles that approach the red triangle edges tend to encounter resistance and reverse — the fan effectively draws a multi-scale map of where selling pressure intensifies. The blue fan does the same for buyer pressure below. Taken together, the fan gives the trader a spatial reading of how pressure distributes across shorter and longer horizons.

A notable property observed during testing across multiple instruments and timeframes: regardless of triangle size or lookback period, B consistently produces values within the bounded range of -1 to +1. This is not a coincidence — it is a mathematical consequence of the symmetric ratio formula that derives B from the two triangle areas.

The formula

Both triangle areas are first computed using the Shoelace formula — a standard computational geometry method that yields the exact area of any polygon from its vertex coordinates. Then B is derived through a symmetric ratio:

r1 = A_hi / A_lo     r2 = A_lo / A_hi     B = (r1 - r2) / (r1 + r2)

When the seller triangle is much larger than the buyer triangle (A_hi >> A_lo), r1 grows large while r2 shrinks, and B approaches +1. When buyer pressure dominates, B approaches -1. When both areas are equal, B = 0 — balanced pressure. The formula is symmetric by construction, meaning it treats buyer and seller sides with identical mathematical weight.

Percentage conversion

To make B immediately readable on the chart, the indicator converts it into two percentage values:

Red % = (B + 1) x 50     seller dominance, scale 0 to 100

Blue % = (1 - B) x 50     buyer dominance, scale 0 to 100

Red % and Blue % always sum to 100. They are available in the Data Window for any bar and are exposed as alert-ready plots, allowing traders to set threshold-based alerts (e.g. "Red % crosses above 80") directly from TradingView's alert builder, without writing any code.

https://www.tradingview.com/x/GLjA0gqn/

🔶 Features at a glance

🔸 Gradient barometer — A vertical column rendered to the right of the last bar. It splits the effective range into a red (seller) zone and a blue (buyer) zone, with the dividing line set by B. The gradient fades from full opacity at the split point to near-transparent at each range boundary, giving an immediate visual sense of which side is dominant and by how much.

🔸 Prime triangle fan — 25 filled triangles (one per prime offset from 3 to 101) overlaid on the chart. Upper triangles are colored red (seller pressure), lower triangles blue (buyer pressure). Together they form a fan that maps pressure intensity across multiple time horizons simultaneously. Optional dashed outlines can be enabled for each side independently.

🔸 Range lines with price labels — Horizontal lines marking the effective high and low of the lookback window. Each line carries a price label placed to the left of the range start. When the channel is frozen (see Freeze/Revival below), a snowflake icon (❄) appears on the labels.

🔸 Diamond markers and prime labels — At each prime-offset bar, a diamond marker is placed at both the range ceiling and the range floor. The corresponding prime number is displayed above the ceiling diamond, providing a visual ruler of the sampling structure.

🔸 Freeze / Revival system — When a confirmed close breaches the range boundary, the mother channel freezes and a child channel is born on the breach side. The child computes its own pressure metric (B'), and when the opposing force inside the child reaches a user-defined threshold, the mother channel revives. This mechanism tracks regime transitions without discarding the prior range context. A dedicated label at the breach candle shows the child's B' value in real time.

🔸 Live and Closed display modes — "Live" updates tick by tick using the current bar's data. "Closed" anchors all calculations on the last confirmed bar, eliminating intra-bar noise for traders who prefer signal stability.

🔸 Data Window and alert-ready plots — Three invisible plots (Red %, Blue %, raw B) are exposed in the Data Window and available for TradingView's alert condition builder. Traders can create threshold, crossover, or crossing alerts on any of these values without writing Pine Script.

🔸 Full visual customisation — Every visual element (triangle fill colors, line colors, diamond size, text size, barometer width, barometer offset, gradient steps) is independently configurable through the indicator's settings panel.

🔶 Deep dive: the barometer

The barometer is a vertical gradient column displayed to the right of the last bar on the chart. Its purpose is to translate the abstract B value into a shape that the eye can read instantly: a column split into a red zone (seller pressure) on top and a blue zone (buyer pressure) on the bottom.

The column spans the full effective range — from rangeLow at the bottom to rangeHigh at the top. The split point between red and blue is not placed at the midpoint of the range. Instead, it is calculated directly from B:

yMid = rangeHigh − (B + 1) × range / 2

When B = 0 (balanced), yMid sits at the exact center of the range. When B approaches +1 (full seller dominance), yMid drops toward the range floor, making the red zone fill nearly the entire column. When B approaches −1 (full buyer dominance), yMid rises toward the range ceiling, and the blue zone dominates.

The gradient is rendered using a configurable number of boxes (default: 50). In the red zone, opacity is strongest near yMid and fades to near-transparent at rangeHigh. In the blue zone, opacity is strongest near yMid and fades toward rangeLow. This creates a natural "heat" effect: the most intense color always concentrates at the boundary where the two forces meet.

At the top and bottom of the column, percentage labels display the Red % and Blue % values. These are the same percentages available in the Data Window, presented here as a quick visual reference.

The barometer responds to the selected display mode. In "Live" mode, it updates on every tick using the current bar's B value. In "Closed" mode, it uses the B computed from the last confirmed bar, providing a stable reading that does not flicker with intra-bar price movement.

Barometer settings

🔸 Show barometer — Toggle the entire barometer on or off. Default: on.

🔸 Offset (bars right) — How far to the right of the last bar the column is placed. Default: 11. Increase this if the barometer overlaps with other right-margin elements.

🔸 Width (bars) — The horizontal thickness of the column, measured in bars. Default: 5.

🔸 Gradient steps — The number of boxes used to render the gradient. Higher values produce a smoother fade. Default: 50.

https://www.tradingview.com/x/Exn3B2Tx/


🔶 Deep dive: the prime triangle fan

The triangle fan is the indicator's signature visual element. It renders 25 filled triangles on the chart — one for each prime offset from 3 to 101 — fanning out from the current bar toward the left side of the lookback window. Upper triangles are shaded red (seller pressure) and lower triangles are shaded blue (buyer pressure), each with high transparency so the underlying candlesticks remain clearly visible.

Every triangle in the fan shares two of its three vertices with the current bar: the bar's high (for upper triangles) or the bar's low (for lower triangles), and the corresponding range boundary at that bar. The third vertex sits at the range boundary at the prime-offset bar. Because each prime offset is a different distance back in time, the triangles vary in width — the smallest is narrow and captures very short-term pressure, while the largest stretches across the full lookback and captures the broadest structural picture.

Reading the fan as a pressure map

The fan functions as a multi-scale pressure map. Each triangle edge represents a boundary where one side's territory begins. When price approaches a cluster of red triangle edges from below, it is entering a zone where seller pressure intensifies across multiple time horizons simultaneously. The denser the overlap of red edges at a given price level, the stronger the structural resistance at that level. The same logic applies in reverse for blue edges and buyer support.

This is visible in practice: candles that push into the red fan often stall or reverse at the triangle boundaries, while candles that drop into the blue fan tend to find support. The fan gives the trader a spatial sense of how much room each side has — a wide blue zone with thin red edges suggests buyers have structural space to move, and vice versa.

Color flipping during freeze

When the Freeze/Revival system is active and price moves beyond the frozen range boundary, the triangle colors on the breached side flip to reflect the new structural reality.

Consider a downward breach: price closes below the frozen rangeLow and continues falling. The lower triangles — which normally appear blue to represent buyer territory — switch to red. This signals that what was once the buyer's domain has been structurally penetrated; the geometry now measures selling pressure extending below the old floor. At the same time, the upper triangles remain red as they always are, and because the distance between the current price and the frozen rangeHigh has grown dramatically, the seller area expands. The visual result: the entire fan turns uniformly red, reflecting overwhelming seller dominance across every time horizon in the fan.

https://www.tradingview.com/x/MOAi1y0C/

The mirror case works identically. During an upward breach, price closes above the frozen rangeHigh and continues rising. The upper triangles flip from red to blue, signaling that seller space has been penetrated from below. The lower triangles remain blue, and because the gap between the current price and the frozen rangeLow is now vast, buyer area dominates. The entire fan turns uniformly blue, reflecting overwhelming buyer dominance.

https://www.tradingview.com/x/wYuDJSnD/

The color flip is automatic and requires no user intervention. It is driven entirely by the relationship between the current price and the frozen boundaries — when price returns inside the frozen range, colors revert to their normal assignment.

Diamond markers and prime labels

At each prime-offset bar, the indicator places diamond-shaped markers at both the range ceiling and the range floor. Above the ceiling diamond, the prime number itself is displayed as a label. These markers serve as a visual ruler: they show the trader exactly where each sampling point falls in time and make the non-periodic spacing of the primes immediately visible on the chart.

Fan settings

🔸 Show lower triangle lines / Show upper triangle lines — Toggle dashed outlines for each side. Default: off. When enabled, the outlines make individual triangle edges more distinct, which can be helpful when reading overlapping edges at specific price levels.

🔸 Lower / Upper line color — Stroke color for the dashed outlines.

🔸 Lower / Upper fill color — Fill color and transparency for the triangle bodies. Default: high transparency so candles remain readable.

🔸 Show vertical lines — Draws a vertical line at each prime-offset bar. Default: off.

🔸 Show prime labels — Displays the prime number and diamond at each offset. Default: on.

🔸 Diamond color / Diamond size — Visual styling for the diamond markers.

🔸 Label text size — Font size for the prime number labels.

🔸 Deep dive: Freeze / Revival

Markets do not stay inside ranges forever. When price breaks out, most range-based indicators simply reset and start a new range from scratch, discarding whatever structural context existed before the breakout. The Freeze/Revival system takes a different approach: it preserves the prior range as a frozen reference while simultaneously tracking the new regime that emerges beyond it.

How a freeze is triggered

A freeze occurs when a confirmed close — not a wick, not an intra-bar spike — breaches the effective range boundary. The indicator compares the previous bar's close against the range that existed one bar before it, so the breach signal is fully confirmed and cannot repaint. Once a breach is detected:

🔸 The mother channel freezes — its high and low are locked at the values they held just before the breach.

🔸 A child channel is born on the breach side. For an upward breach, the child's floor is the frozen rangeHigh and its ceiling expands with each new high. For a downward breach, the child's ceiling is the frozen rangeLow and its floor drops with each new low.

🔸 A snowflake icon (❄) appears on the range price labels, and the triangle colors flip as described in the section above.

The child channel and B'

While the mother channel is frozen, the child channel computes its own independent pressure metric called B'. B' uses the same ICS triangle formula as the mother's B, but measured against the child's own boundaries. This means B' tracks the buyer/seller balance exclusively inside the new regime — the territory beyond the old range.

A dedicated label appears at the breach candle showing the current B' value, converted to the percentage of the opposing force. For a downward breach, the label displays the buyer percentage inside the child; for an upward breach, it displays the seller percentage. This tells the trader how much counter-pressure is building inside the breakout zone.

B' as a structural overbought / oversold reading

When B' shows a very low opposing-force percentage shortly after a breach, the breakout side is structurally dominant — price has moved aggressively beyond the old range with minimal resistance. This condition is analogous to what traders call an overbought or oversold state, but derived from geometry rather than from momentum oscillators. The reading reflects the spatial imbalance between the two forces inside the child channel: one side occupies nearly all the geometric territory.

As time passes, if the opposing force gradually builds — the B' percentage climbs — it signals that the breakout is losing its structural one-sidedness. The market is beginning to rebalance inside the new territory. Watching B' evolve over successive bars gives the trader a real-time gauge of whether the breakout retains its structural conviction or is approaching exhaustion.

Revival: when does the freeze end?

The freeze lifts when the opposing force inside the child channel reaches a user-defined threshold (default: 50%). At that point, the indicator interprets this as the exhaustion of the breakout: the force that drove the breach is being met by equal or greater counter-pressure. The freeze is lifted, all freeze state is reset, and the mother channel resumes normal range tracking. The snowflake icons, B' label, and color flips are removed.

The revival threshold is configurable. A lower value makes the system more sensitive — it revives sooner, treating even moderate counter-pressure as a regime reset. A higher value makes it more patient — it waits for stronger opposition before releasing the freeze. The default represents balanced equilibrium: the freeze ends when the opposing side has matched the breach side.

Why this matters

The Freeze/Revival cycle gives the trader a structured way to observe regime transitions. Rather than watching a range silently reset after a breakout, the trader sees the old range preserved as context (frozen lines with ❄), the new regime measured in real time (B' at the breach candle with its overbought/oversold implication), and a clear signal when the transition is complete (revival). This makes it possible to distinguish between a genuine regime change and a brief spike that reverts — without relying on arbitrary time delays or fixed-bar re-entry rules.

🔸 Reading the indicator

This indicator does not generate buy or sell signals. It is a measurement tool that quantifies the geometric balance between buyer and seller pressure. How that measurement is incorporated into a trading decision is entirely up to the trader. The following observations describe what the indicator shows, not what the trader should do.

The barometer as a quick-glance gauge

The barometer provides the fastest reading. A column dominated by red indicates that seller pressure is structurally larger than buyer pressure across the lookback window. A column dominated by blue indicates the reverse. When the split point sits near the center, pressure is approximately balanced. Watching how the split point migrates over successive bars reveals whether the pressure balance is shifting gradually or remaining stable.

The fan as a spatial context layer

The triangle fan adds spatial depth to the barometer's single-number reading. While the barometer tells you the current balance, the fan shows you where that balance is concentrated in price space. Areas where multiple triangle edges converge represent zones of intensified pressure — structural resistance above (red edges) or structural support below (blue edges). When price trades inside a region with sparse triangle coverage, it has more structural room to move before encountering the next pressure boundary.

Freeze events as regime markers

When a freeze occurs, it marks a structural event: price has left the established range. The frozen lines (marked with ❄) preserve the old context, and B' at the breach candle provides a real-time measure of how one-sided the new regime is. A very low opposing-force reading in B' indicates a structurally extended condition — the breakout side has occupied nearly all geometric territory. As B' climbs toward the revival threshold, it indicates increasing counter-pressure. The moment of revival itself marks the point where the new regime's one-sidedness has been structurally neutralized.

Combining readings

The three visual layers — barometer, fan, and freeze state — work together. For example, a barometer showing strong seller dominance combined with a fan whose red edges are densely clustered near the current price suggests concentrated structural resistance. If a freeze is also active with a low B', the structural picture is one of strong directional conviction on the breach side. Conversely, a barometer near balance with widely spaced fan edges and no active freeze suggests a structurally neutral environment.

Data Window and alerts

The Red %, Blue %, and raw B values are available in TradingView's Data Window for any bar by hovering over it. These same values are exposed as alert-ready plots, meaning traders can set alerts directly from TradingView's alert builder — for example, triggering when Red % crosses above or below a chosen level, or when B crosses zero. No Pine Script knowledge is required to create these alerts.

🔸 Open-source structure and reusability

This script is published open-source under the Mozilla Public License 2.0. The full computation pipeline — the Yang-Zhang volatility estimator, the ICS coordinate transformation, the Shoelace area calculation, and the symmetric ratio that produces B — is readable, auditable, and reusable.

B is a bounded output: it always falls between −1 and +1, carries no unit, and is computed from normalized geometry. These properties make it suitable as an input for other scripts. Examples of how B can serve as input to further analysis include:

🔸 Plotting B as a standalone oscillator with its own zero line and structural extremes.

🔸 Applying moving averages of different periods to B and studying their crossovers as indicators of shifting pressure regimes.

🔸 Using B as a weighting coefficient to scale other measurements by the current geometric pressure balance.

🔸 Comparing B across timeframes, since the ICS normalization makes the metric structurally comparable regardless of the chart resolution.

🔸 Testing for divergences between B and price action.

🔸 Using B as a filter condition for entry or exit logic in other strategies.

The code is available for study and extension under MPL 2.0. Traders and developers who wish to build on this metric have full access to its derivation.

🔸 Settings reference

Range Lines

🔸 Lookback length — Number of historical bars used to compute the high/low range. Default: 101.

🔸 Line width — Pixel width of the horizontal range lines. Default: 1.

🔸 Display mode — "Live" updates tick by tick using the current bar. "Closed" anchors on the last confirmed bar, eliminating intra-bar noise. Default: Live.

ICS

🔸 ICS Window — Number of bars fed into the Yang-Zhang volatility estimator. Controls how much historical data shapes the normalization sigma. Default: 101.

Prime Verticals and Labels

🔸 Show vertical lines — Draws a vertical line at each prime-offset bar. Default: off.

🔸 Show prime labels — Displays the prime number and diamond marker at each offset. Default: on.

🔸 Vertical line color — Color for vertical lines at prime offsets.

🔸 Diamond color — Color of diamond markers and their labels.

🔸 Label text size — Font size for prime number labels, in points.

🔸 Diamond size — Size of the diamond-shaped markers, in points.

Prime Triangles

🔸 Show lower triangle lines — Toggle dashed outlines for lower (buyer) triangles. Default: off.

🔸 Show upper triangle lines — Toggle dashed outlines for upper (seller) triangles. Default: off.

🔸 Lower line color — Stroke color for lower triangle dashed outlines.

🔸 Upper line color — Stroke color for upper triangle dashed outlines.

🔸 Lower fill color — Fill color and transparency for lower (buyer) triangle bodies.

🔸 Upper fill color — Fill color and transparency for upper (seller) triangle bodies.

Barometer

🔸 Show barometer — Toggle the barometer column on or off. Default: on.

🔸 Offset (bars right) — Horizontal distance from the last bar to the barometer column. Default: 11.

🔸 Width (bars) — Horizontal thickness of the barometer column. Default: 5.

🔸 Gradient steps — Number of boxes used to render the gradient. Higher values produce a smoother fade. Default: 50.

Freeze and Revival

🔸 Revival threshold (B') — When the opposing force inside the child channel reaches this percentage, the freeze ends and the mother channel resumes. A lower value revives sooner; a higher value waits for stronger counter-pressure. Default: 50.

🔸 Disclaimer

This indicator is a technical analysis tool designed for educational and informational purposes. It measures the geometric balance between buyer and seller pressure using the methodology described above. It does not predict future price movements, does not guarantee any outcome, and does not constitute financial, investment, or trading advice.

The B metric, the barometer, the triangle fan, and the Freeze/Revival system are structural measurements derived from historical price data. Like all technical indicators, they reflect past and present conditions and carry inherent limitations. Market conditions can change rapidly, and no single measurement tool can account for all factors that influence price.

Traders should use this indicator as one component within a broader analytical framework, always in combination with their own research, risk management practices, and judgment. Past performance of any reading or pattern observed through this indicator is not indicative of future results.

Use this tool at your own risk. The author assumes no liability for any trading decisions made based on the information provided by this indicator.

## Source Code

````pine
// This Pine Script® source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © SmartTrader

//@version=6
indicator("Smart Trader, Episode 07, ICS Geometric Buyers/Sellers Pressure", shorttitle = "ST-EP07", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 500, max_polylines_count = 100)

// ═══════════════════════════════════════════════════════════
// CONSTANTS
// Prime offsets, ICS thresholds, group keys, visual defaults.
// ═══════════════════════════════════════════════════════════

// First 25 primes (3..101): each prime defines a triangle fan
// vertex offset from the current bar.
var array<int> primesArray = array.from(
     3,  5,  7, 11, 13, 17, 19, 23, 29, 31,
     37, 41, 43, 47, 53, 59, 61, 67, 71, 73,
     79, 83, 89, 97, 101)

color TRANSPARENT             = color.new(color.black, 100)
const float ICS_MIN_SIGMA     = 1e-10
const float YZ_K_NUM          = 0.34
const float YZ_K_DEN          = 1.34
const int   CLOSED_BAR_OFFSET = 1
const int   MAX_PRIME          = 101

const string GROUP_RANGE  = "Range Lines"
const string GROUP_ICS    = "ICS — Isotropic Coordinate System"
const string GROUP_PRIME  = "Prime Verticals & Labels"
const string GROUP_TRI    = "Prime Triangles"
const string GROUP_BARO   = "Barometer"
const string GROUP_FREEZE = "Freeze & Revival"

// ═══════════════════════════════════════════════════════════
// INPUTS
// User-facing controls grouped by feature: range, ICS,
// prime visuals, triangles, barometer, freeze/revival.
// ═══════════════════════════════════════════════════════════

int    lengthInput      = input.int(101, title = "Lookback length", minval = 2, group = GROUP_RANGE, tooltip = "Number of historical bars used to compute the high/low range.")
int    lineWidthInput   = input.int(1, title = "Line width", minval = 1, maxval = 5, group = GROUP_RANGE, tooltip = "Pixel width of the horizontal range lines.")
string displayModeInput = input.string("Live", title = "Display mode", options = ["Live", "Closed"], group = GROUP_RANGE, tooltip = "Live: tick-by-tick updates. Closed: anchors on last confirmed bar.")

int   icsWindowInput    = input.int(101, "ICS Window", minval = 10, maxval = 500, group = GROUP_ICS, tooltip = "Bars fed into the Yang-Zhang volatility estimator.")

bool  showVertInput     = input.bool(false, title = "Show vertical lines",   group = GROUP_PRIME, tooltip = "Vertical line at each prime offset.")
bool  showLabelsInput   = input.bool(true,  title = "Show prime labels",     group = GROUP_PRIME, tooltip = "Prime number and diamond at each offset.")
color primeColorInput   = input.color(color.new(#c8b4ff, 60), title = "Vertical line color", group = GROUP_PRIME, tooltip = "Color for vertical lines at prime offsets.")
color diamondColorInput = input.color(color.new(#c8b4ff, 0),  title = "Diamond color",       group = GROUP_PRIME, tooltip = "Color of diamond markers and labels.")
int   textSizeInput     = input.int(10, title = "Label text size (pt)", minval = 1, maxval = 100, group = GROUP_PRIME, tooltip = "Font size for prime labels.")
int   diamondSizeInput  = input.int(1,  title = "Diamond size (pt)",    minval = 1, maxval = 100, group = GROUP_PRIME, tooltip = "Size of diamond markers.")

bool  showTriLoInput    = input.bool(false, title = "Show lower triangle lines", group = GROUP_TRI, tooltip = "Dashed outlines for lower (buyer) triangles.")
bool  showTriHiInput    = input.bool(false, title = "Show upper triangle lines", group = GROUP_TRI, tooltip = "Dashed outlines for upper (seller) triangles.")
color triLoColorInput   = input.color(color.new(#00d4ff, 0),  title = "Lower line color",  group = GROUP_TRI, tooltip = "Stroke color for lower triangle outlines.")
color triHiColorInput   = input.color(color.new(#ff2060, 0),  title = "Upper line color",  group = GROUP_TRI, tooltip = "Stroke color for upper triangle outlines.")
color triFillLoInput    = input.color(color.new(#00d4ff, 98), title = "Lower fill color",  group = GROUP_TRI, tooltip = "Fill color for lower (buyer) triangles.")
color triFillHiInput    = input.color(color.new(#ff2060, 98), title = "Upper fill color",  group = GROUP_TRI, tooltip = "Fill color for upper (seller) triangles.")

bool  showBarometerInput = input.bool(true, title = "Show barometer", group = GROUP_BARO, tooltip = "Vertical gradient column showing buyer/seller pressure.")
int   baroOffsetInput    = input.int(11, title = "Offset (bars right)", minval = 1, maxval = 50, group = GROUP_BARO, tooltip = "Horizontal distance from last bar to barometer.")
int   baroWidthInput     = input.int(5, title = "Width (bars)", minval = 1, maxval = 20, group = GROUP_BARO, tooltip = "Barometer column width in bars.")
int   baroStepsInput     = input.int(50, title = "Gradient steps", minval = 5, maxval = 100, group = GROUP_BARO, tooltip = "Boxes used for gradient rendering.")

int   revivalThresholdInput = input.int(50, title = "Revival threshold (B')", minval = 1, maxval = 100, group = GROUP_FREEZE, tooltip = "When the opposing force in the child channel reaches this percentage, the freeze ends and the mother channel revives. Default 50 = balanced.")

// ═══════════════════════════════════════════════════════════
// ICS — Isotropic Coordinate System (Yang-Zhang)
// Normalises price and time into a dimensionless plane so
// that triangle areas are comparable across instruments and
// timeframes. The normalisation divisor is Yang-Zhang sigma.
// ═══════════════════════════════════════════════════════════

// @description  Computes Yang-Zhang (2000) composite volatility
//               estimator over `length` closed bars starting at
//               `anchor` offset. Combines overnight, open-close,
//               and Rogers-Satchell components with bias factor k.
// @param length  Window size (number of bars in the sample).
// @param anchor  Nearest bar offset; the window extends backward
//                from anchor to anchor + length - 1 (0 = current bar).
// @returns       sqrt(YZ variance), floored at ICS_MIN_SIGMA to
//                prevent division-by-zero in ICS normalisation.
f_yzSigma(simple int length, simple int anchor) =>
    float k = YZ_K_NUM / (YZ_K_DEN + (length + 1.0) / (length - 1.0))
    float sumOC2    = 0.0
    float sumRS     = 0.0
    float sumLogCO2 = 0.0
    for i = 0 to length - 1
        int   ki     = anchor + i
        float o_     = open[ki]
        float h_     = high[ki]
        float l_     = low[ki]
        float c_     = close[ki]
        float cPrev  = close[ki + 1]
        float u      = math.log(h_ / o_)
        float d      = math.log(l_ / o_)
        float cO     = math.log(c_ / o_)
        float oCprev = math.log(o_ / cPrev)
        sumOC2    += oCprev * oCprev
        sumLogCO2 += cO * cO
        sumRS     += u * (u - cO) + d * (d - cO)
    float vOpen  = sumOC2    / (length - 1)
    float vClose = sumLogCO2 / (length - 1)
    float vRS    = sumRS     / length
    float varYZ  = vOpen + k * vClose + (1 - k) * vRS
    math.max(math.sqrt(varYZ), ICS_MIN_SIGMA)

// @description  Computes the area of a triangle in ICS space
//               using the Shoelace formula. Each raw point
//               (bar_index, price) is first transformed:
//                 x_ics = (bar_index - anchor) / sigma
//                 y_ics = ln(price) / sigma
//               The resulting area is dimensionless and scale-
//               invariant, making buyer/seller triangles
//               comparable regardless of price magnitude.
// @param x1raw  bar_index of vertex 1 (current bar).
// @param y1raw  price of vertex 1 (high or low of current bar).
// @param x2raw  bar_index of vertex 2 (current bar, range edge).
// @param y2raw  price of vertex 2 (range high or range low).
// @param x3raw  bar_index of vertex 3 (prime offset bar).
// @param y3raw  price of vertex 3 (same range edge as vertex 2).
// @param sig    Yang-Zhang sigma for ICS normalisation.
//               Internally re-floored at ICS_MIN_SIGMA as a
//               defensive guard (f_yzSigma already floors it).
// @param aIdx   anchor bar_index (origin of the ICS x-axis).
// @returns      absolute ICS area (>= 0, dimensionless).
f_triAreaICS(int x1raw, float y1raw, int x2raw, float y2raw, int x3raw, float y3raw, float sig, int aIdx) =>
    float s  = math.max(sig, ICS_MIN_SIGMA)
    float x1 = float(x1raw - aIdx) / s
    float y1 = math.log(y1raw) / s
    float x2 = float(x2raw - aIdx) / s
    float y2 = math.log(y2raw) / s
    float x3 = float(x3raw - aIdx) / s
    float y3 = math.log(y3raw) / s
    0.5 * math.abs(x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2))

// ═══════════════════════════════════════════════════════════
// SERIES — Range boundaries & reference prices
// Evaluated on every bar so Pine maintains the history buffer
// needed by ta.highest / ta.lowest look-backs.
// "Closed" variants lag by CLOSED_BAR_OFFSET (confirmed bars);
// "Live" variants include the still-forming bar.
// ═══════════════════════════════════════════════════════════

float rangeHigh     = ta.highest(high[CLOSED_BAR_OFFSET], lengthInput)
float rangeLow      = ta.lowest(low[CLOSED_BAR_OFFSET],   lengthInput)
float rangeHighLive = ta.highest(high, lengthInput)
float rangeLowLive  = ta.lowest(low,  lengthInput)

float refHigh     = high[CLOSED_BAR_OFFSET]
float refLow      = low[CLOSED_BAR_OFFSET]
float refHighLive = high
float refLowLive  = low

// ═══════════════════════════════════════════════════════════
// ICS STATE — readiness gates & sigma computation
// `icsReady`   : true once enough history exists for YZ.
// `inIcsRange` : true only on the recent `lengthInput` window
//                so sigma is not computed on distant history.
// `icsAnchor`  : bar_index origin for all ICS x-transforms.
// ═══════════════════════════════════════════════════════════

bool  icsReady   = bar_index >= icsWindowInput + CLOSED_BAR_OFFSET
bool  inIcsRange = bar_index >= last_bar_index - lengthInput
float sigma      = inIcsRange and icsReady ? f_yzSigma(icsWindowInput, CLOSED_BAR_OFFSET) : na
int   icsAnchor  = bar_index - CLOSED_BAR_OFFSET

// ═══════════════════════════════════════════════════════════
// FREEZE STATE — Mother/Child channel lifecycle
// ═══════════════════════════════════════════════════════════
// When a confirmed close breaches the mother channel's range:
//   1. The mother channel FREEZES — its high/low are locked.
//   2. A CHILD channel is born on the breach side, tracking
//      new extremes beyond the frozen boundary.
//   3. The child computes its own B' (buyer/seller balance).
//   4. REVIVAL: when the opposing force inside the child
//      reaches `revivalThresholdInput` %, the freeze lifts
//      and the mother channel resumes normal range updates.
// `breachDirection` = +1 (upward breach) or -1 (downward).

var bool  isFrozen        = false
var int   frozenBarIndex  = na
var float frozenHigh      = na
var float frozenLow       = na
var int   breachDirection = 0      // 0=none, 1=up, -1=down
var float childHigh          = na
var float childLow           = na
var float breachCandlePrice  = na

// Breach detection: compare the PREVIOUS bar's close against the
// range that existed one bar before it (prevRange*), so the
// breach signal is confirmed and cannot repaint.
float prevRangeHigh    = ta.highest(high[CLOSED_BAR_OFFSET + 1], lengthInput)
float prevRangeLow     = ta.lowest(low[CLOSED_BAR_OFFSET + 1],   lengthInput)
bool  closedBreachHigh = not na(prevRangeHigh) and (close[CLOSED_BAR_OFFSET] > prevRangeHigh)
bool  closedBreachLow  = not na(prevRangeLow)  and (close[CLOSED_BAR_OFFSET] < prevRangeLow)

// Freeze trigger: only fires within the recent lookback window
// and only when no freeze is already active. Locks the mother
// range and initialises the child channel on the breach side.
if bar_index >= last_bar_index - lengthInput and not isFrozen and (closedBreachHigh or closedBreachLow)
    isFrozen       := true
    frozenBarIndex := bar_index - CLOSED_BAR_OFFSET
    frozenHigh     := prevRangeHigh
    frozenLow      := prevRangeLow
    if closedBreachHigh
        breachDirection   := 1
        childLow          := frozenHigh
        childHigh         := high[CLOSED_BAR_OFFSET]
        breachCandlePrice := high[CLOSED_BAR_OFFSET]
    else
        breachDirection   := -1
        childHigh         := frozenLow
        childLow          := low[CLOSED_BAR_OFFSET]
        breachCandlePrice := low[CLOSED_BAR_OFFSET]

// Child boundary: expands the child channel on every bar while
// frozen. Downward breach → track new lows; upward → new highs.
if isFrozen
    if breachDirection == -1
        childLow := math.min(nz(childLow, low), low)
    else if breachDirection == 1
        childHigh := math.max(nz(childHigh, high), high)

// Child B' — buyer/seller balance inside the child channel.
// Uses the same ICS triangle formula as the mother B, but
// measured against the child's own high/low boundaries.
// Edge cases: when one triangle collapses to zero area, B'
// saturates to the extreme (1.0 or -1.0) instead of na,
// so the revival logic always has a usable value.
float childB = na
if isFrozen and inIcsRange and not na(sigma) and not na(childHigh) and not na(childLow) and childHigh > childLow
    int   cPrimeBar = bar_index - MAX_PRIME + 1
    float cAreaHi   = f_triAreaICS(bar_index, high, bar_index, childHigh, cPrimeBar, childHigh, sigma, bar_index)
    float cAreaLo   = f_triAreaICS(bar_index, low,  bar_index, childLow,  cPrimeBar, childLow,  sigma, bar_index)
    if cAreaHi <= 0 and cAreaLo <= 0
        childB := 0.0
    else if cAreaLo <= 0
        childB := 1.0
    else if cAreaHi <= 0
        childB := -1.0
    else
        float cr1  = cAreaHi / cAreaLo
        float cr2  = cAreaLo / cAreaHi
        float cDen = cr1 + cr2
        childB := cDen > 0 ? (cr1 - cr2) / cDen : 0.0

// Revival: converts child B' into a percentage for each side.
// If the OPPOSING force (blue after an up-breach, red after a
// down-breach) reaches `revivalThresholdInput` %, the freeze
// is lifted and all freeze state is reset to default.
if isFrozen and bar_index >= last_bar_index - lengthInput and not na(childB)
    float cRedAdv  = (childB + 1.0) * 50.0
    float cBlueAdv = (1.0 - childB) * 50.0
    bool  reviveFromDown = breachDirection == -1 and cBlueAdv >= revivalThresholdInput
    bool  reviveFromUp   = breachDirection == 1  and cRedAdv  >= revivalThresholdInput
    if reviveFromDown or reviveFromUp
        isFrozen          := false
        frozenBarIndex    := na
        frozenHigh        := na
        frozenLow         := na
        breachDirection   := 0
        childHigh         := na
        childLow          := na
        breachCandlePrice := na

// Effective range: the single source of truth for all downstream
// drawing and calculation. During freeze, returns locked values;
// otherwise, returns the rolling lookback high/low.
float effRangeHigh     = isFrozen ? frozenHigh : rangeHigh
float effRangeLow      = isFrozen ? frozenLow  : rangeLow
float effRangeHighLive = isFrozen ? frozenHigh : rangeHighLive
float effRangeLowLive  = isFrozen ? frozenLow  : rangeLowLive

// Mother B (live) — the core buyer/seller pressure metric.
// B = (r1 - r2) / (r1 + r2), where r1 = areaHi/areaLo and
// r2 = areaLo/areaHi. Result in [-1, +1]: positive = seller
// (red) dominant, negative = buyer (blue) dominant.
// Computed at series level so barometer, plots, and drawing
// blocks can all reference the same value.
float aHiLive = na
float aLoLive = na
float bLive   = na
if not na(sigma) and effRangeHighLive > effRangeLowLive
    int primeBarLive = bar_index - MAX_PRIME + 1
    aHiLive := f_triAreaICS(bar_index, refHighLive, bar_index, effRangeHighLive, primeBarLive, effRangeHighLive, sigma, bar_index)
    aLoLive := f_triAreaICS(bar_index, refLowLive,  bar_index, effRangeLowLive,  primeBarLive, effRangeLowLive,  sigma, bar_index)
    if aHiLive <= 0 and aLoLive <= 0
        bLive := 0.0
    else if aLoLive <= 0
        bLive := 1.0
    else if aHiLive <= 0
        bLive := -1.0
    else
        float r1Lm = aHiLive / aLoLive
        float r2Lm = aLoLive / aHiLive
        bLive := (r1Lm - r2Lm) / (r1Lm + r2Lm)

// ═══════════════════════════════════════════════════════════
// DRAWING — Visual overlay (barstate.islast only)
// Renders: range lines, prime vertical lines, diamond labels,
// buyer/seller triangle fans (filled polylines), and optional
// dashed outlines. Drawing objects managed here (lines, labels,
// polylines, vertical lines) are deleted and rebuilt on each
// tick. Barometer boxes and B' labels have their own separate
// cleanup blocks below.
// When frozen, triangle colors FLIP if price has moved beyond
// the locked range boundary (loFlipped / hiFlipped logic).
// ═══════════════════════════════════════════════════════════

var line hiLine = na
var line loLine = na
var array<label>    prevLabels    = array.new<label>()
var array<polyline> prevPolylines = array.new<polyline>()
var array<line>     prevVertLines = array.new<line>()
var label           childBLabel    = na
var label           childBDiamond  = na
var label           rangeHighLabel = na
var label           rangeLowLabel  = na

if barstate.islast
    line.delete(hiLine)
    line.delete(loLine)
    label.delete(rangeHighLabel)
    label.delete(rangeLowLabel)
    rangeHighLabel := na
    rangeLowLabel  := na
    for lbl in prevLabels
        label.delete(lbl)
    prevLabels.clear()
    for pl in prevPolylines
        polyline.delete(pl)
    prevPolylines.clear()
    for vl in prevVertLines
        line.delete(vl)
    prevVertLines.clear()


    bool  useLive = displayModeInput == "Live"
    int   curBar  = useLive ? bar_index : bar_index - CLOSED_BAR_OFFSET
    int   leftBar = curBar - lengthInput + 1
    float hVal    = useLive ? effRangeHighLive : effRangeHigh
    float lVal    = useLive ? effRangeLowLive  : effRangeLow
    float curHigh = useLive ? refHighLive      : refHigh
    float curLow  = useLive ? refLowLive       : refLow

    // Color flip: during freeze, if price has moved beyond the
    // locked boundary, swap buyer/seller colors so the visual
    // correctly reflects that the triangle now measures
    // pressure from the opposite side of the channel.
    bool  loFlipped = isFrozen and curLow < lVal
    bool  hiFlipped = isFrozen and curHigh > hVal

    // Range line colors: follow the same flip logic as triangles
    // so the boundary lines always match the fill colours beside them.
    color hiLineClr = color.new(hiFlipped ? triLoColorInput : triHiColorInput, 90)
    color loLineClr = color.new(loFlipped ? triHiColorInput : triLoColorInput, 90)
    hiLine := line.new(x1 = leftBar, y1 = hVal, x2 = curBar, y2 = hVal, color = hiLineClr, width = lineWidthInput, style = line.style_solid)
    loLine := line.new(x1 = leftBar, y1 = lVal, x2 = curBar, y2 = lVal, color = loLineClr, width = lineWidthInput, style = line.style_solid)

    // Range price labels: placed 7 bars left of the range start,
    // arrow pointing right. Show the numeric price and a snowflake
    // icon when the channel is frozen. Coloured to match the
    // flip-aware triangle scheme.
    string freezeIcon  = isFrozen ? " ❄" : ""
    color  hiLabelClr  = hiFlipped ? triLoColorInput : triHiColorInput
    color  loLabelClr  = loFlipped ? triHiColorInput : triLoColorInput
    int rangeLabelX = leftBar - 7
    rangeHighLabel := label.new(
         x         = rangeLabelX,
         y         = hVal,
         text      = str.tostring(hVal, format.mintick) + freezeIcon,
         style     = label.style_label_right,
         color     = color.new(hiLabelClr, 30),
         textcolor = chart.fg_color,
         size      = textSizeInput,
         xloc      = xloc.bar_index,
         yloc      = yloc.price)
    rangeLowLabel := label.new(
         x         = rangeLabelX,
         y         = lVal,
         text      = str.tostring(lVal, format.mintick) + freezeIcon,
         style     = label.style_label_right,
         color     = color.new(loLabelClr, 30),
         textcolor = chart.fg_color,
         size      = textSizeInput,
         xloc      = xloc.bar_index,
         yloc      = yloc.price)

    // Resolved fill and stroke colours for lower (buyer) and
    // upper (seller) triangles, incorporating the flip state.
    color actLoFill = loFlipped ? triFillHiInput : triFillLoInput
    color actHiFill = hiFlipped ? triFillLoInput : triFillHiInput
    color actLoLine = loFlipped ? triHiColorInput : triLoColorInput
    color actHiLine = hiFlipped ? triLoColorInput : triHiColorInput

    bool needVert      = showVertInput
    bool needLabels    = showLabelsInput
    bool needTriLoLine = showTriLoInput
    bool needTriHiLine = showTriHiInput

    for idx = 0 to primesArray.size() - 1
        int offset = array.get(primesArray, idx)
        if offset > lengthInput
            continue

        int primeBar = curBar - offset + 1

        if needVert
            prevVertLines.push(line.new(x1 = primeBar, y1 = hVal, x2 = primeBar, y2 = lVal, color = primeColorInput, width = 1, style = line.style_solid))

        if needLabels
            prevLabels.push(label.new(x = primeBar, y = hVal, text = str.tostring(offset), style = label.style_none, color = TRANSPARENT, size = textSizeInput, textcolor = diamondColorInput))
            prevLabels.push(label.new(x = primeBar, y = hVal, text = "", style = label.style_diamond, color = diamondColorInput, size = diamondSizeInput))
            prevLabels.push(label.new(x = primeBar, y = lVal, text = "", style = label.style_diamond, color = diamondColorInput, size = diamondSizeInput))

        // Lower (buyer) triangle: curBar low → curBar rangeLow → primeBar rangeLow
        array<chart.point> loFill = array.from(
             chart.point.from_index(curBar,   curLow),
             chart.point.from_index(curBar,   lVal),
             chart.point.from_index(primeBar, lVal))
        prevPolylines.push(polyline.new(points = loFill, closed = true, line_color = TRANSPARENT, fill_color = actLoFill, line_width = 0))

        if needTriLoLine
            array<chart.point> loEdge = array.from(
                 chart.point.from_index(curBar,   curLow),
                 chart.point.from_index(curBar,   lVal),
                 chart.point.from_index(primeBar, lVal))
            prevPolylines.push(polyline.new(points = loEdge, closed = true, line_color = actLoLine, fill_color = TRANSPARENT, line_width = 1, line_style = line.style_dashed))

        // Upper (seller) triangle: curBar high → curBar rangeHigh → primeBar rangeHigh
        array<chart.point> hiFill = array.from(
             chart.point.from_index(curBar,   curHigh),
             chart.point.from_index(curBar,   hVal),
             chart.point.from_index(primeBar, hVal))
        prevPolylines.push(polyline.new(points = hiFill, closed = true, line_color = TRANSPARENT, fill_color = actHiFill, line_width = 0))

        if needTriHiLine
            array<chart.point> hiEdge = array.from(
                 chart.point.from_index(curBar,   curHigh),
                 chart.point.from_index(curBar,   hVal),
                 chart.point.from_index(primeBar, hVal))
            prevPolylines.push(polyline.new(points = hiEdge, closed = true, line_color = actHiLine, fill_color = TRANSPARENT, line_width = 1, line_style = line.style_dashed))

// ═══════════════════════════════════════════════════════════
// BAROMETER — Vertical gradient pressure gauge
// A column of `baroStepsInput` boxes rendered to the right
// of the last bar. The column spans the effective range and
// is split at the midpoint derived from B:
//   yMid = rangeHigh - (B + 1) * range / 2
// Red boxes (seller pressure) fill above yMid with a gradient
// from full opacity at yMid to near-transparent at rangeHigh.
// Blue boxes (buyer pressure) mirror below yMid.
// Labels at top and bottom show each side's percentage.
// Supports both Live (tick-by-tick B) and Closed (confirmed B).
// ═══════════════════════════════════════════════════════════

var array<box> baroBoxes   = array.new<box>()
var label      baroLblRed  = na
var label      baroLblBlue = na

if barstate.islast
    for bx in baroBoxes
        box.delete(bx)
    baroBoxes.clear()
    label.delete(baroLblRed)
    label.delete(baroLblBlue)
    baroLblRed  := na
    baroLblBlue := na

    bool  baroUseLive = displayModeInput == "Live"

    // bClosed uses icsAnchor (bar_index - 1) as its ICS origin,
    // unlike bLive which uses bar_index. This anchors the closed
    // ICS space to the last confirmed bar so that both the
    // reference prices and the coordinate system are consistent.
    bool  closedReady = bar_index >= MAX_PRIME + CLOSED_BAR_OFFSET and not na(sigma)
    float bClosed     = na
    if closedReady and effRangeHigh > effRangeLow
        int   refBarIdx101  = bar_index - CLOSED_BAR_OFFSET
        int   primeBar101   = refBarIdx101 - MAX_PRIME + 1
        float aHiClosed     = f_triAreaICS(refBarIdx101, refHigh, refBarIdx101, effRangeHigh, primeBar101, effRangeHigh, sigma, icsAnchor)
        float aLoClosed     = f_triAreaICS(refBarIdx101, refLow,  refBarIdx101, effRangeLow,  primeBar101, effRangeLow,  sigma, icsAnchor)
        if aHiClosed <= 0 and aLoClosed <= 0
            bClosed := 0.0
        else if aLoClosed <= 0
            bClosed := 1.0
        else if aHiClosed <= 0
            bClosed := -1.0
        else
            float r1cm = aHiClosed / aLoClosed
            float r2cm = aLoClosed / aHiClosed
            bClosed := (r1cm - r2cm) / (r1cm + r2cm)

    float dispB       = baroUseLive ? bLive             : bClosed
    float dispRangeHi = baroUseLive ? effRangeHighLive  : effRangeHigh
    float dispRangeLo = baroUseLive ? effRangeLowLive   : effRangeLow
    int   dispBarIdx  = baroUseLive ? bar_index         : bar_index - CLOSED_BAR_OFFSET

    bool baroDataOk = showBarometerInput and not na(dispB)
                          and not na(dispRangeHi) and not na(dispRangeLo)
                          and dispRangeHi > dispRangeLo

    if baroDataOk
        int   leftEdge  = dispBarIdx + baroOffsetInput
        int   rightEdge = leftEdge + baroWidthInput
        float yTop      = dispRangeHi
        float yBot      = dispRangeLo
        float yRange    = yTop - yBot
        float curB      = dispB

        float yMid    = yTop - (curB + 1.0) * yRange / 2.0
        float redLen  = yTop - yMid
        float blueLen = yMid - yBot

        color redFull   = color.new(triHiColorInput, 0)
        color redFaint  = color.new(triHiColorInput, 92)
        color blueFull  = color.new(triLoColorInput, 0)
        color blueFaint = color.new(triLoColorInput, 92)

        if redLen > 0
            for k = 0 to baroStepsInput - 1
                float boxTop = yTop - redLen *  k      / baroStepsInput
                float boxBot = yTop - redLen * (k + 1) / baroStepsInput
                float frac   = (k + 0.5) / baroStepsInput
                color bg     = color.from_gradient(frac, 0.0, 1.0, redFull, redFaint)
                box bx = box.new(left = leftEdge, top = boxTop,
                                  right = rightEdge, bottom = boxBot,
                                  border_color = TRANSPARENT,
                                  border_width = 0,
                                  bgcolor = bg,
                                  xloc = xloc.bar_index)
                baroBoxes.push(bx)

        if blueLen > 0
            for k = 0 to baroStepsInput - 1
                float boxTop = yMid - blueLen *  k      / baroStepsInput
                float boxBot = yMid - blueLen * (k + 1) / baroStepsInput
                float frac   = (k + 0.5) / baroStepsInput
                color bg     = color.from_gradient(frac, 0.0, 1.0, blueFaint, blueFull)
                box bx = box.new(left = leftEdge, top = boxTop,
                                  right = rightEdge, bottom = boxBot,
                                  border_color = TRANSPARENT,
                                  border_width = 0,
                                  bgcolor = bg,
                                  xloc = xloc.bar_index)
                baroBoxes.push(bx)

        int   lblX    = leftEdge + baroWidthInput / 2
        float redAdv  = (curB + 1.0) * 50.0
        float blueAdv = (1.0 - curB) * 50.0
        baroLblRed := label.new(x = lblX, y = yTop,
                                 text      = str.tostring(redAdv, "#"),
                                 style     = label.style_label_down,
                                 color     = color.new(triHiColorInput, 75),
                                 textcolor = chart.fg_color,
                                 size      = textSizeInput,
                                 xloc      = xloc.bar_index,
                                 yloc      = yloc.price)
        baroLblBlue := label.new(x = lblX, y = yBot,
                                  text      = str.tostring(blueAdv, "#"),
                                  style     = label.style_label_up,
                                  color     = color.new(triLoColorInput, 75),
                                  textcolor = chart.fg_color,
                                  size      = textSizeInput,
                                  xloc      = xloc.bar_index,
                                  yloc      = yloc.price)


// ═══════════════════════════════════════════════════════════
// CHILD B' LABEL — freeze-point annotation
// Shows a diamond marker and a "B' xx.x" label at the exact
// candle where the breach occurred (frozenBarIndex). The
// percentage displayed is the OPPOSING force in the child
// channel: for a downward breach it shows buyer (blue) %;
// for an upward breach it shows seller (red) %.
// Labels are always deleted first (even when not frozen) to
// prevent stale artefacts after a revival clears the freeze,
// and to handle edge cases where a freeze triggers and revives
// within the same tick.
// ═══════════════════════════════════════════════════════════

// Delete previous tick's labels unconditionally
if barstate.islast
    label.delete(childBLabel)
    label.delete(childBDiamond)
    childBLabel   := na
    childBDiamond := na

// Recreate labels only while a freeze is active
if barstate.islast and isFrozen and breachDirection != 0
    string bPrimeText = "B' na"
    if not na(childB)
        float oppAdv = 0.0
        if breachDirection == -1
            oppAdv := (1.0 - childB) * 50.0
        else
            oppAdv := (childB + 1.0) * 50.0
        bPrimeText := "B' " + str.tostring(oppAdv, "#.#")

    color  badgeClr = breachDirection == -1 ? triLoColorInput : triHiColorInput
    float  lblY     = nz(breachCandlePrice, breachDirection == -1 ? effRangeLow : effRangeHigh)

    childBDiamond := label.new(
         x         = frozenBarIndex,
         y         = lblY,
         text      = "",
         style     = label.style_diamond,
         color     = badgeClr,
         size      = diamondSizeInput + 4,
         xloc      = xloc.bar_index,
         yloc      = yloc.price)

    childBLabel := label.new(
         x         = frozenBarIndex,
         y         = lblY,
         text      = bPrimeText,
         style     = breachDirection == -1 ? label.style_label_up : label.style_label_down,
         color     = color.new(badgeClr, 30),
         textcolor = chart.fg_color,
         size      = textSizeInput + 4,
         xloc      = xloc.bar_index,
         yloc      = yloc.price)

// ═══════════════════════════════════════════════════════════
// PLOTS — Data Window & Alert infrastructure
// ═══════════════════════════════════════════════════════════
// Three invisible plots (100% transparent) that serve two
// purposes:
//   1. Data Window: the user can hover any bar and read
//      Red %, Blue %, and raw B in the Data Window panel.
//   2. Alerts: TradingView's alert condition builder exposes
//      these plots, so the user can create alerts like
//      "Red % crosses above 80" without writing Pine code.
// Red % = (B + 1) * 50   → 0..100 scale, 100 = full seller.
// Blue% = (1 - B) * 50   → 0..100 scale, 100 = full buyer.

float redPctPlot  = not na(bLive) ? (bLive + 1.0) * 50.0 : na
float bluePctPlot = not na(bLive) ? (1.0 - bLive) * 50.0 : na

plot(redPctPlot,  title = "Red %",  display = display.data_window, color = color.new(color.white, 100))
plot(bluePctPlot, title = "Blue %", display = display.data_window, color = color.new(color.white, 100))
plot(bLive,       title = "B",      display = display.data_window, color = color.new(color.white, 100))

// ═══════════════════════════════════════════════════════════
// END OF SCRIPT
// ═══════════════════════════════════════════════════════════
//
// Indicator : ICS Geometric Buyer/Seller Pressure
// Short name: ST-EP07
// Version   : Pine Script v6
// Author    : SmartTrader
// License   : Mozilla Public License 2.0
//
// OVERVIEW
// Measures real-time buyer vs seller pressure using a geometric
// triangle-fan algorithm normalised through an Isotropic
// Coordinate System (ICS). The ICS uses Yang-Zhang composite
// volatility to make triangle areas dimensionless and
// comparable across any instrument or timeframe.
//
// ALGORITHM
// 1. Compute Yang-Zhang sigma over a configurable lookback
//    window of confirmed bars.
// 2. For the pressure metric B, construct two right triangles
//    using the largest prime offset (MAX_PRIME = 101):
//      Upper triangle: current high → range high → prime bar.
//      Lower triangle: current low  → range low  → prime bar.
//    The remaining 24 primes (3..97) are used only for the
//    visual triangle fan overlay, not for the B calculation.
// 3. Transform all vertices into ICS space:
//      x_ics = (bar_index - anchor) / sigma
//      y_ics = ln(price) / sigma
//    and compute the Shoelace area of each triangle.
// 4. Derive the pressure metric B from the area ratio:
//      B = (r1 - r2) / (r1 + r2)
//    where r1 = areaHi / areaLo, r2 = areaLo / areaHi.
//    B in [-1, +1]: positive = seller dominant (red),
//    negative = buyer dominant (blue).
//
// FREEZE / REVIVAL
// When a confirmed close breaches the range, the mother
// channel freezes and a child channel tracks the new
// extremes. The child computes its own B'. When the
// opposing force in the child reaches the revival
// threshold, the mother channel resumes.
//
// VISUAL OUTPUTS
//   Range lines with price labels (snowflake icon when frozen).
//   Triangle fan fills and optional dashed outlines.
//   Diamond markers and prime labels at each vertex.
//   Gradient barometer column showing buyer/seller split.
//   B' annotation at the breach candle during freeze.
//   Data Window and alert-ready plots: Red %, Blue %, B.
//
// ═══════════════════════════════════════════════════════════
````
