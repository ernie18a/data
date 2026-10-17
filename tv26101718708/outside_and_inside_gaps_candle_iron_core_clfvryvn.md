# Outside and Inside Gaps - Candle Iron Core

- url: https://www.tradingview.com/script/clFvRYVN-Outside-and-Inside-Gaps-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;0db64fd3241741a39a7c2c4e3e40edf3
- version: 1.0

## Description

[b]OVERVIEW[/b]

Outside and Inside Gaps [CIC] is an open-source indicator that identifies visible price gaps between consecutive candles on the active chart timeframe.

The script compares each candle with the immediately preceding candle. Therefore, it automatically adapts to the timeframe selected by the user:

[list]
[*]On a 15-minute chart, it compares consecutive 15-minute candles.
[*]On a 1-hour chart, it compares consecutive 1-hour candles.
[*]On a 4-hour chart, it compares consecutive 4-hour candles.
[*]On a daily chart, it compares consecutive daily candles.
[/list]

The indicator distinguishes between [b]Outside Gaps (OG)[/b] and [b]Inside Gaps (IG)[/b]. A box is drawn only when a visible price space remains between the relevant levels of both candles.

[b]GAP CLASSIFICATION[/b]

[b]OUTSIDE GAP (OG)[/b]

An Outside Gap occurs when the current candle opens completely outside the previous candle’s high-low range and its complete price range leaves visible space beyond the previous candle.

[b]Bullish Outside Gap:[/b]

[list]
[*]The current open is above the previous candle’s high.
[*]The current low remains above the previous candle’s high.
[*]The gap zone is located between the previous high and the current low.
[/list]

[b]Bearish Outside Gap:[/b]

[list]
[*]The current open is below the previous candle’s low.
[*]The current high remains below the previous candle’s low.
[*]The gap zone is located between the current high and the previous low.
[/list]

[i]If the current candle trades back into the previous candle’s range, no Outside Gap box is displayed.[/i]

[b]INSIDE GAP (IG)[/b]

An Inside Gap occurs when the current candle opens inside the previous candle’s high-low range but away from the previous close.

A visible space must remain between the previous close and the current candle’s price range.

[b]Bullish Inside Gap:[/b]

[list]
[*]The current open is inside the previous candle’s range.
[*]The current open is above the previous close.
[*]The current low remains above the previous close.
[*]The gap zone is located between the previous close and the current low.
[/list]

[b]Bearish Inside Gap:[/b]

[list]
[*]The current open is inside the previous candle’s range.
[*]The current open is below the previous close.
[*]The current high remains below the previous close.
[*]The gap zone is located between the current high and the previous close.
[/list]

[i]If the current candle trades through the previous close, no Inside Gap box is displayed.[/i]

[b]OUTSIDE GAP PERCENTAGE FILTER[/b]

The [b]Minimum Outside Gap Size (%)[/b] setting allows users to exclude small Outside Gaps.

The percentage is calculated using the height of the visible OG zone. It does not use the complete distance between the previous close and the current open.

[b]Bullish Outside Gap calculation:[/b]

[quote](Current Low - Previous High) / Previous High x 100[/quote]

[b]Bearish Outside Gap calculation:[/b]

[quote](Previous Low - Current High) / Previous Low x 100[/quote]

An Outside Gap is displayed only when its calculated percentage is equal to or greater than the user-defined minimum.

The default minimum is [b]0.50%[/b].

For example:

[list]
[*]A value of 1.00 displays only Outside Gaps measuring at least 1%.
[*]A value of 0.25 displays Outside Gaps measuring at least 0.25%.
[*]A value of 0 displays every qualifying Outside Gap.
[/list]

[i]This percentage filter applies exclusively to Outside Gaps. Inside Gaps are not filtered by percentage.[/i]

[b]VISUAL DESIGN[/b]

The indicator uses separate visual elements to communicate gap classification and direction.

[b]Gap classification:[/b]

[list]
[*]Outside Gaps use a yellow fill by default.
[*]Inside Gaps use a purple fill by default.
[*]“OG” identifies an Outside Gap.
[*]“IG” identifies an Inside Gap.
[*]The text uses the same color as its corresponding gap category.
[/list]

[b]Gap direction:[/b]

[list]
[*]A green border identifies a bullish gap.
[*]A red border identifies a bearish gap.
[/list]

[b]Default colors:[/b]

[list]
[*]Outside Gap fill and text: yellow (#FFD700).
[*]Inside Gap fill and text: purple (#8A2BE2).
[*]Bullish border: green (#00A651).
[*]Bearish border: red (#E53935).
[*]Default box transparency: 82%.
[/list]

All category colors, border colors and box transparency can be customized from the indicator settings.

[b]BOX POSITIONING[/b]

Each gap box begins at the previous candle. This allows the drawing to visually cover the transition from the previous candle to the candle where the gap forms.

The [b]Length of Boxes[/b] setting determines how many bars the box covers horizontally.

The selected length is measured in bars of the active chart timeframe. For example, a length of 20 represents:

[list]
[*]Twenty 15-minute bars on a 15-minute chart.
[*]Twenty 1-hour bars on a 1-hour chart.
[*]Twenty daily bars on a daily chart.
[/list]

[i]Changing the box length affects only the horizontal display. It does not modify the detection or classification of a gap.[/i]

[b]SETTINGS[/b]

[b]Length of Boxes[/b]

Controls the horizontal length of every gap box. The value is measured in bars of the active chart timeframe.

[b]Max Bars Back to Find Gaps[/b]

Limits the historical search to the selected number of chart bars.

For example, a value of 500 instructs the indicator to search for qualifying gaps only within the most recent 500 candles of the active timeframe.

[b]Minimum Outside Gap Size (%)[/b]

Defines the minimum visible percentage required for an Outside Gap to be displayed.

[i]This input affects Outside Gaps only.[/i]

[b]Show Outside Gaps (OG)[/b]

Enables or disables all qualifying Outside Gap boxes.

[b]Show Inside Gaps (IG)[/b]

Enables or disables all qualifying Inside Gap boxes.

[b]Outside Gap Color[/b]

Controls the fill and text color used for Outside Gaps.

[b]Inside Gap Color[/b]

Controls the fill and text color used for Inside Gaps.

[b]Bullish Border Color[/b]

Controls the border color used for bullish Outside and Inside Gaps.

[b]Bearish Border Color[/b]

Controls the border color used for bearish Outside and Inside Gaps.

[b]Box Transparency[/b]

Controls the transparency of the box fills. It does not change the opacity of the text or borders.

[b]ALERTS[/b]

The indicator includes alert conditions for:

[list]
[*]New Outside Gap.
[*]New Inside Gap.
[/list]

Outside Gap alerts respect the [b]Minimum Outside Gap Size (%)[/b] filter. An Outside Gap that does not meet the selected minimum will not create a box or trigger the corresponding alert.

Inside Gap alerts follow the Inside Gap detection conditions and are not affected by the Outside Gap percentage filter.

[b]HOW TO USE[/b]

[list=1]
[*]Apply the indicator to a standard candlestick chart.
[*]Select the timeframe you want to analyze.
[*]Configure the minimum Outside Gap percentage.
[*]Adjust the box length and historical search range.
[*]Use the box fill to identify the gap category.
[*]Use the border color to identify the gap direction.
[*]Enable alerts if notifications for newly detected gaps are required.
[/list]

The indicator adapts its calculations to the active timeframe. It does not import gaps from a different timeframe.

For example, when the chart is set to 1 hour, the indicator detects gaps between consecutive 1-hour candles. It does not display daily gaps unless the chart itself is changed to the daily timeframe.

[b]PRACTICAL PURPOSE[/b]

Many basic gap indicators mark every difference between one closing price and the next opening price without considering whether a visible price space remains.

This implementation adds a more selective structure by combining:

[list]
[*]Separate Outside and Inside Gap classifications.
[*]Confirmation that a visible gap remains between the candles.
[*]A configurable Outside Gap percentage filter.
[*]Independent colors for gap classification and directional bias.
[*]Adjustable box length.
[*]Adjustable historical search depth.
[*]Detection based on the active chart timeframe.
[*]Alerts that follow the same detection and filtering rules.
[/list]

The script is intended to organize visible price discontinuities without generating trading signals or making assumptions about how price must react to them.

[b]REAL-TIME BEHAVIOR[/b]

Historical gaps are calculated using completed candles.

On the active candle, the high and low can continue changing until the candle closes. As a result:

[list]
[*]A developing gap can become smaller.
[*]A developing gap can disappear if price trades into the relevant reference level.
[*]The final historical result is determined when the candle closes.
[/list]

This behavior is necessary because the script requires visible price space to remain before confirming the gap.

The script does not use future data or request information from a higher timeframe.

[b]LIMITATIONS[/b]

[list]
[*]The indicator evaluates the active chart timeframe only.
[*]Gap frequency can vary significantly between assets and timeframes.
[*]Intraday gaps may be uncommon in highly liquid markets with continuous trading.
[*]More gaps may appear around session openings, trading halts or periods of low liquidity.
[*]The indicator should be used with standard candlesticks.
[*]Heikin Ashi, Renko, Kagi, Line Break, Point and Figure and other non-standard charts use synthetic or transformed OHLC values. Gaps detected on those charts may not represent actual traded price discontinuities.
[*]Session settings, extended-hours data and differences between data providers can affect which gaps appear.
[*]Corporate actions such as dividends and stock splits can create gaps that are not caused by ordinary price discovery.
[*]TradingView allows a maximum of 500 box objects per script. If this limit is reached, the indicator retains the most recent qualifying gap boxes.
[*]The indicator does not track whether a previously drawn gap is filled after its formation.
[*]A detected gap does not predict whether price will continue, reverse or return to the gap.
[*]The script does not provide entries, exits, stop-loss levels, take-profit levels or performance statistics.
[/list]

[quote]This indicator is a visual analysis tool. Its drawings should not be interpreted as financial advice or as a guarantee of future market behavior.[/quote]

[b]OPEN-SOURCE PUBLICATION[/b]

The complete Pine Script source code is publicly available so users can inspect the calculations, understand the detection rules and modify the implementation for their own research.

## Source Code

````pine
//@version=6
indicator("Outside and Inside Gaps - Candle Iron Core", overlay = true, max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_DETECTION = "Gap Detection"
string GROUP_STYLE     = "Style"

int boxLength = input.int(
     2,
     "Length of boxes",
     minval = 1,
     maxval = 500,
     tooltip = "Number of chart bars covered by each gap box.",
     group = GROUP_DETECTION)

int maxBarsBack = input.int(
     2000,
     "Max bars back to find gaps",
     minval = 1,
     maxval = 10000,
     tooltip = "Only searches for gaps inside this number of chart bars.",
     group = GROUP_DETECTION)

float minimumOutsideGapPercent = input.float(
     0.50,
     "Minimum Outside Gap size (%)",
     minval = 0.0,
     step = 0.05,
     tooltip = "Minimum visible OG box height as a percentage of the previous high or low. Set to 0 to show every Outside Gap.",
     group = GROUP_DETECTION)

bool showOutsideGaps = input.bool(true, "Show Outside Gaps (OG)", group = GROUP_DETECTION)
bool showInsideGaps  = input.bool(true, "Show Inside Gaps (IG)", group = GROUP_DETECTION)

color outsideColor = input.color(#FFD700, "Outside Gap color", group = GROUP_STYLE)
color insideColor  = input.color(#8A2BE2, "Inside Gap color", group = GROUP_STYLE)
color bullishBorderColor = input.color(#00A651, "Bullish border color", group = GROUP_STYLE)
color bearishBorderColor = input.color(#E53935, "Bearish border color", group = GROUP_STYLE)
int fillTransparency = input.int(82, "Box transparency", minval = 0, maxval = 100, group = GROUP_STYLE)

// ─────────────────────────────────────────────────────────────────────────────
// Gap detection
// The script uses the chart's own OHLC values. It therefore compares each bar
// with the immediately preceding bar of the active chart timeframe.
// ─────────────────────────────────────────────────────────────────────────────
bool validData = bar_index > 0 and not na(high[1]) and not na(low[1]) and not na(close[1])
bool inSearchWindow = bar_index >= math.max(0, last_bar_index - maxBarsBack)

// OUTSIDE GAP
// The open must begin outside the previous bar's range, and the current bar's
// complete range must leave visible space beyond the previous high or low.
bool outsideGapUp   = open > high[1] and low > high[1]
bool outsideGapDown = open < low[1] and high < low[1]
bool outsideGap     = outsideGapUp or outsideGapDown

float outsideGapPercent = outsideGapUp ? ((low - high[1]) / high[1]) * 100.0 : outsideGapDown ? ((low[1] - high) / low[1]) * 100.0 : 0.0
bool outsideGapPassesFilter = outsideGap and outsideGapPercent >= minimumOutsideGapPercent

// INSIDE GAP
// The open must begin inside the previous bar's range. The current bar's range
// must also leave visible space between itself and the previous close.
bool openInsidePreviousRange = open > low[1] and open < high[1]
bool insideGapUp   = openInsidePreviousRange and open > close[1] and low > close[1]
bool insideGapDown = openInsidePreviousRange and open < close[1] and high < close[1]
bool insideGap     = insideGapUp or insideGapDown

// ─────────────────────────────────────────────────────────────────────────────
// Drawing management
// ─────────────────────────────────────────────────────────────────────────────
var array<box> gapBoxes = array.new<box>()
var array<int> gapStartBars = array.new<int>()

drawGap(float topPrice, float bottomPrice, color gapColor, color borderColor, string gapText) =>
    box.new(
         left = bar_index - 1,
         top = topPrice,
         right = bar_index - 1 + boxLength,
         bottom = bottomPrice,
         xloc = xloc.bar_index,
         border_color = borderColor,
         border_width = 2,
         border_style = line.style_solid,
         bgcolor = color.new(gapColor, fillTransparency),
         text = gapText,
         text_color = gapColor,
         text_size = size.small,
         text_halign = text.align_center,
         text_valign = text.align_center,
         text_wrap = text.wrap_none)

// Remove gaps that have moved beyond the selected historical window.
while array.size(gapBoxes) > 0 and bar_index - array.get(gapStartBars, 0) > maxBarsBack
    box.delete(array.shift(gapBoxes))
    array.shift(gapStartBars)

if validData and inSearchWindow
    // TradingView allows a maximum of 500 boxes per script.
    while array.size(gapBoxes) >= 500
        box.delete(array.shift(gapBoxes))
        array.shift(gapStartBars)

    if showOutsideGaps and outsideGapPassesFilter
        float ogTop = outsideGapUp ? low : low[1]
        float ogBottom = outsideGapUp ? high[1] : high
        color ogBorderColor = outsideGapUp ? bullishBorderColor : bearishBorderColor
        box ogBox = drawGap(ogTop, ogBottom, outsideColor, ogBorderColor, "OG")
        array.push(gapBoxes, ogBox)
        array.push(gapStartBars, bar_index)

    else if showInsideGaps and insideGap
        float igTop = insideGapUp ? low : close[1]
        float igBottom = insideGapUp ? close[1] : high
        color igBorderColor = insideGapUp ? bullishBorderColor : bearishBorderColor
        box igBox = drawGap(igTop, igBottom, insideColor, igBorderColor, "IG")
        array.push(gapBoxes, igBox)
        array.push(gapStartBars, bar_index)

// Optional alert conditions.
alertcondition(showOutsideGaps and validData and outsideGapPassesFilter, "New Outside Gap", "New Outside Gap (OG) on {{ticker}}")
alertcondition(showInsideGaps and validData and insideGap, "New Inside Gap", "New Inside Gap (IG) on {{ticker}}")
````
