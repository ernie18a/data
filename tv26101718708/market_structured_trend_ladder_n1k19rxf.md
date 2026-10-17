# Market Structured Trend Ladder

- url: https://www.tradingview.com/script/n1k19Rxf-Market-Structured-Trend-Ladder/
- type: indicator
- pine_id: PUB;e72ff08b1d134ae6b57bbb8e4328b4d0
- version: 1.0

## Description

[b]Market Structured Trend Ladder | NeuraAlgo[/b]

[b]Overview[/b]
[image]https://www.tradingview.com/x/NK4CAfNK/[/image]

Market Structured Trend Ladder is a price-action-based market structure indicator designed to identify Breaks of Structure (BOS), highlight potential Changes of Character (CHoCH), and visualize directional trend bias through a dynamic step-based trend ladder.

The indicator uses confirmed swing highs and swing lows to identify important structural price levels. When price breaks an active swing level, the indicator marks the event, updates its directional bias, and adjusts the trend ladder according to subsequent confirmed swing points.

By combining market structure analysis, configurable breakout confirmation, trend-based candle coloring, and a dynamic ladder with optional chart shading, Market Structured Trend Ladder provides a clear framework for analyzing market direction and structural developments.

[b]Main Features[/b]

[list]
[*][b]Swing High and Low Detection[/b] — Identifies confirmed market swing points using a configurable swing length.
[*][b]Break of Structure (BOS)[/b] — Marks price breaks above active swing highs or below active swing lows.
[*][b]Change of Character (CHoCH)[/b] — Optionally labels a structural break in the direction opposite to the previous recorded breakout direction.
[*][b]Flexible Breakout Confirmation[/b] — Choose between candle-close confirmation and wick-based confirmation.
[*][b]Dynamic Trend Ladder[/b] — Displays a step-based reference level that updates according to the current trend bias and newly confirmed swing points.
[*][b]Trend-Based Candle Coloring[/b] — Colors candles according to the latest bullish or bearish structural breakout.
[*][b]Customizable Structure Lines[/b] — Adjust line style, thickness, and bullish or bearish colors.
[*][b]Adjustable Ladder Display[/b] — Enable or disable the trend ladder and customize its width and fill transparency.
[*][b]Market Structure Visualization[/b] — Combines breakout levels, event labels, candle colors, and ladder shading in a unified chart display.
[/list]

[b]How It Works[/b]

[b]1. Market Structure Detection[/b]

The indicator identifies swing highs and swing lows using the selected Swing Length. A pivot is confirmed only after the required number of bars has formed on both sides of the potential swing point.

Confirmed swing levels become active structural references until price breaks through them.

[b]2. Break of Structure (BOS)[/b]

A bullish or bearish structural break occurs when the selected price source crosses an active swing level.

[list]
[*][b]Bullish BOS:[/b] Price moves above the previous active swing high.
[*][b]Bearish BOS:[/b] Price moves below the previous active swing low.
[/list]

The indicator draws a horizontal line at the broken level and adds a corresponding structure label. Each active swing level is marked only once before being deactivated.

[b]3. Change of Character (CHoCH)[/b]

When enabled, the indicator labels a breakout as CHoCH when its direction is opposite to the previously recorded breakout direction. Other qualifying structural breaks are labeled BOS.

This distinction helps traders observe potential changes in directional market behavior. CHoCH is based on the indicator's recorded breakout sequence and should not be interpreted as confirmation of a complete trend reversal.

[b]4. Trend Bias and Candle Coloring[/b]

The current trend bias updates when a bullish or bearish structural break occurs.

[list]
[*][b]Bullish Bias:[/b] A bullish breakout establishes bullish trend coloring.
[*][b]Bearish Bias:[/b] A bearish breakout establishes bearish trend coloring.
[*][b]Initial State:[/b] Before the first qualifying breakout, candles retain their chart-default colors.
[/list]

The bias remains active until an opposing structural breakout changes it.

[b]5. Dynamic Trend Ladder[/b]

The trend ladder provides a step-based reference that follows the current structural bias.

[list]
[*][b]Bullish Ladder:[/b] Begins at the most recently stored swing low when bullish bias is established. It can step upward as new confirmed swing lows form.
[*][b]Bearish Ladder:[/b] Begins at the most recently stored swing high when bearish bias is established. It can step downward as new confirmed swing highs form.
[/list]

The ladder is designed to visualize evolving structural reference levels rather than generate independent entry or exit signals.

[b]6. Ladder Fill[/b]

Optional chart shading highlights the area between the closing price and the trend ladder. The fill color follows the current trend bias, while the transparency setting controls its visual intensity.

[b]Settings Guide[/b]

[list]
[*][b]Swing Length:[/b] Determines the number of bars required on both sides to confirm a swing point. Higher values generally produce fewer, more widely spaced structural levels.
[*][b]BOS Confirmation:[/b] Select Candle Close to require a closing-price break, or Wicks to use the high or low crossing the active swing level.
[*][b]Show CHoCH:[/b] Enables labels for breakouts opposite to the previously recorded breakout direction.
[*][b]Line Style:[/b] Select Solid, Dashed, or Dotted structure lines.
[*][b]Line Width:[/b] Controls the thickness of BOS and CHoCH level lines.
[*][b]Bullish Color:[/b] Sets the color for bullish structure breaks, bullish trend candles, and the bullish ladder.
[*][b]Bearish Color:[/b] Sets the color for bearish structure breaks, bearish trend candles, and the bearish ladder.
[*][b]Show Trend Ladder:[/b] Toggles the ladder display and its associated fill.
[*][b]Ladder Width:[/b] Adjusts the thickness of the step-based trend line.
[*][b]Fill Transparency:[/b] Controls the transparency of the area between price and the ladder.
[/list]

[b]Suggested Usage[/b]

Market Structured Trend Ladder can be used to study structural breakouts, follow changes in directional bias, and observe how confirmed swing levels evolve over time.

Traders may combine BOS and CHoCH labels with the trend ladder, support and resistance zones, liquidity analysis, volume, or higher-timeframe market structure when evaluating potential trading opportunities.

The indicator can be applied across different markets and timeframes, but its behavior will vary according to the selected Swing Length and breakout confirmation method.

[b]Important Considerations[/b]

Swing points require subsequent bars for confirmation, so structural levels are identified with a delay. Once confirmed, the indicator uses those levels as active breakout references.

Candle-close confirmation is generally more restrictive than wick-based confirmation. Wick-based confirmation can identify breaks earlier but may also register price movements that do not persist through the candle close.

The CHoCH label reflects the direction of the previous recorded breakout, not a complete independent assessment of market structure. The trend ladder is a structural visualization tool and does not guarantee that its levels will hold as support or resistance.

[b]Disclaimer:[/b] Market Structured Trend Ladder is intended for educational and informational purposes only. It does not provide guaranteed trading signals or constitute financial or investment advice. Always apply appropriate risk management and evaluate trading decisions within the broader market context.

[b]© NeuraAlgo | Licensed under the Mozilla Public License 2.0 (MPL-2.0).[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeuraAlgo

//@version=6
indicator("Market Structured Trend Ladder", overlay=true, max_labels_count=500, max_lines_count=500)

string GROUP_STRUCTURE = "01. Market Structure"

int swingLength = input.int(20, "Swing Length", minval=1, group=GROUP_STRUCTURE, tooltip="Number of bars required on both sides to confirm a swing point.")
string breakoutConfirmation = input.string("Candle Close", "BOS Confirmation", options=["Candle Close", "Wicks"], group=GROUP_STRUCTURE, tooltip="Choose whether candle close or wick confirms a structure break.")


string GROUP_BREAKS = "02. BOS / CHoCH"

bool showChangeOfCharacter = input.bool(false, "Show CHoCH", group=GROUP_BREAKS, tooltip="Label the first breakout against the previous breakout direction as CHoCH.")
string structureLineStyle = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=GROUP_BREAKS)
int structureLineWidth = input.int(1, "Line Width", minval=1, maxval=5, group=GROUP_BREAKS)

string GROUP_COLORS = "03. Trend Colors"

color bullishColor = input.color(color.teal, "Bullish Color", group=GROUP_COLORS)
color bearishColor = input.color(color.red, "Bearish Color", group=GROUP_COLORS)

string GROUP_LADDER = "04. Trend Ladder"

bool showTrendLadder = input.bool(true, "Show Trend Ladder", group=GROUP_LADDER)
int ladderLineWidth = input.int(1, "Ladder Width", minval=1, maxval=5, group=GROUP_LADDER)
int ladderFillTransparency = input.int(80, "Fill Transparency", minval=0, maxval=100, group=GROUP_LADDER)

getLineStyle(string selectedStyle) => switch selectedStyle
    "Solid" => line.style_solid
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted

getBreakLabel(int previousDirection, int newDirection, bool enableChoch) => enableChoch and previousDirection == -newDirection ? "CHoCH" : "BOS"


float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float previousSwingHigh = na
var float previousSwingLow = na
var int previousSwingHighBar = na
var int previousSwingLowBar = na

var bool swingHighIsActive = false
var bool swingLowIsActive = false

if not na(pivotHigh)
    previousSwingHigh := pivotHigh
    previousSwingHighBar := bar_index - swingLength
    swingHighIsActive := true

if not na(pivotLow)
    previousSwingLow := pivotLow
    previousSwingLowBar := bar_index - swingLength
    swingLowIsActive := true

float bullishBreakSource = breakoutConfirmation == "Candle Close" ? close : high
float bearishBreakSource = breakoutConfirmation == "Candle Close" ? close : low

bool bullishBreak = false
bool bearishBreak = false

if swingHighIsActive and not na(previousSwingHigh) and bullishBreakSource > previousSwingHigh
    bullishBreak := true
    swingHighIsActive := false

if swingLowIsActive and not na(previousSwingLow) and bearishBreakSource < previousSwingLow
    bearishBreak := true
    swingLowIsActive := false

var int previousBreakDirection = 0

color transparentColor = color.new(color.black, 100)

if bullishBreak
    line.new(previousSwingHighBar, previousSwingHigh, bar_index, previousSwingHigh, color=bullishColor, style=getLineStyle(structureLineStyle), width=structureLineWidth)
    string bullishLabel = getBreakLabel(previousBreakDirection, 1, showChangeOfCharacter)
    label.new(math.floor((bar_index + previousSwingHighBar) / 2), previousSwingHigh, bullishLabel, color=transparentColor, textcolor=bullishColor, size=size.tiny)
    previousBreakDirection := 1

if bearishBreak
    line.new(previousSwingLowBar, previousSwingLow, bar_index, previousSwingLow, color=bearishColor, style=getLineStyle(structureLineStyle), width=structureLineWidth)
    string bearishLabel = getBreakLabel(previousBreakDirection, -1, showChangeOfCharacter)
    label.new(math.floor((bar_index + previousSwingLowBar) / 2), previousSwingLow, bearishLabel, color=transparentColor, textcolor=bearishColor, style=label.style_label_up, size=size.tiny)
    previousBreakDirection := -1

var int currentTrendBias = 0

if bullishBreak
    currentTrendBias := 1

if bearishBreak
    currentTrendBias := -1

barcolor(currentTrendBias == 1 ? bullishColor : currentTrendBias == -1 ? bearishColor : na)

var float trendLadderLevel = na
var int previousLadderBias = 0

if currentTrendBias != previousLadderBias
    trendLadderLevel := currentTrendBias == 1 ? previousSwingLow : currentTrendBias == -1 ? previousSwingHigh : na
    previousLadderBias := currentTrendBias
else if currentTrendBias == 1 and not na(pivotLow)
    trendLadderLevel := math.max(nz(trendLadderLevel, pivotLow), pivotLow)
else if currentTrendBias == -1 and not na(pivotHigh)
    trendLadderLevel := math.min(nz(trendLadderLevel, pivotHigh), pivotHigh)

color ladderColor = currentTrendBias == 1 ? bullishColor : currentTrendBias == -1 ? bearishColor : na
float displayedLadderLevel = showTrendLadder ? trendLadderLevel : na

displayedLadder = plot(displayedLadderLevel, title="Trend Ladder", color=ladderColor, linewidth=ladderLineWidth, style=plot.style_stepline)
closeFillReference = plot(close, title="Fill Reference", display=display.none)

color ladderFillColor = currentTrendBias == 1 ? color.new(bullishColor, ladderFillTransparency) : currentTrendBias == -1 ? color.new(bearishColor, ladderFillTransparency) : na

fill(closeFillReference, displayedLadder, close, displayedLadderLevel, chart.bg_color, ladderFillColor, title="Trend Ladder Fill", editable=false)
````
