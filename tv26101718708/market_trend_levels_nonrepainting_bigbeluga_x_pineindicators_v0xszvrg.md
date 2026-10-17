# Market Trend Levels Non-Repainting [BigBeluga X PineIndicators]

- url: https://www.tradingview.com/script/v0XszvRG-Market-Trend-Levels-Non-Repainting-BigBeluga-X-PineIndicators/
- type: strategy
- pine_id: PUB;460c6559887e4112b22a0726aa704dee
- version: 1.0

## Description

This strategy is based on the Market Trend Levels Detector developed by BigBeluga. Full credit for the concept and original indicator goes to BigBeluga.

The Market Trend Levels Detector Strategy is a [b]non-repainting trend-following strategy[/b] that identifies [b]market trend shifts[/b] using two Exponential Moving Averages (EMA). It also detects [b]key price levels[/b] and allows traders to apply [b]multiple filters[/b] to refine trade entries and exits.

This strategy is designed for [b]trend trading[/b] and enables traders to:
[list]
[*] Identify [b]trend direction[/b] based on EMA crossovers.
[*] Detect [b]significant market levels[/b] using labeled trend lines.
[*] Use [b]multiple filter conditions[/b] to improve trade accuracy.
[*] Avoid [b]false signals[/b] through non-repainting calculations.
[/list]

[b]How the Market Trend Levels Detector Strategy Works[/b]
[b]1. Core Trend Detection Using EMA Crossovers[/b]
The strategy detects trend shifts using two EMAs:
[list]
[*] [b]Fast EMA (default: 12 periods)[/b] – Reacts quickly to price movements.
[*] [b]Slow EMA (default: 25 periods)[/b] – Provides a smoother trend confirmation.
[/list]
A [b]bullish crossover[/b] (Fast EMA crosses above Slow EMA) signals an [b]uptrend[/b], while a [b]bearish crossover[/b] (Fast EMA crosses below Slow EMA) signals a [b]downtrend[/b].

[b]2. Market Level Detection & Visualization[/b]
Each time an EMA crossover occurs, a trend level line is drawn:
[list]
[*] [b]Bullish crossover[/b] → A green line is drawn at the low of the crossover candle.
[*] [b]Bearish crossover[/b] → A purple line is drawn at the high of the crossover candle.
[*] Lines can be extended to act as [b]support and resistance zones[/b] for future price action.
[/list]

Additionally, a [b]small label (●)[/b] appears at each crossover to mark the event on the chart.

[b]3. Trade Entry & Exit Conditions[/b]
The strategy allows users to choose between three trading modes:
[list]
[*] [b]Long Only[/b] – Only enters long trades.
[*] [b]Short Only[/b] – Only enters short trades.
[*] [b]Long & Short[/b] – Trades in both directions.
[/list]

[b]Entry Conditions[/b]
[list]
[*] [b]Long Entry:[/b]

A bullish EMA crossover occurs.
The trade direction setting allows long trades.
Filter conditions (if enabled) confirm a valid long signal.
[*] [b]Short Entry:[/b]

A bearish EMA crossover occurs.
The trade direction setting allows short trades.
Filter conditions (if enabled) confirm a valid short signal.
[/list]
[b]Exit Conditions[/b]
[list]
[*] [b]Long Exit:[/b]

A bearish EMA crossover occurs.
Exit filters (if enabled) indicate an invalid long position.
[*] [b]Short Exit:[/b]

A bullish EMA crossover occurs.
Exit filters (if enabled) indicate an invalid short position.
[/list]
[b]Additional Trade Filters[/b]
To improve trade accuracy, the strategy allows traders to apply up to 7 additional filters:
[list]
[*] [b]RSI Filter:[/b] Only trades when RSI confirms a valid trend.
[*] [b]MACD Filter:[/b] Ensures MACD histogram supports the trade direction.
[*] [b]Stochastic Filter:[/b] Requires %K line to be above/below threshold values.
[*] [b]Bollinger Bands Filter:[/b] Confirms price position relative to the middle BB line.
[*] [b]ADX Filter:[/b] Ensures the trend strength is above a set threshold.
[*] [b]CCI Filter:[/b] Requires CCI to indicate momentum in the right direction.
[*] [b]Williams %R Filter:[/b] Ensures price momentum supports the trade.
[/list]

Filters can be enabled or disabled individually based on trader preference.

[b]Dynamic Level Extension Feature[/b]
The strategy provides an [b]optional feature[/b] to extend trend lines until price interacts with them again:
[list]
[*] [b]Bullish support lines[/b] extend until price revisits them.
[*] [b]Bearish resistance lines[/b] extend until price revisits them.
[*] If price breaks a line, the line turns into a [b]dotted style[/b], indicating it has been breached.
[/list]

This helps traders identify key levels where trend shifts previously occurred, providing useful support and resistance insights.

[b]Customization Options[/b]
The strategy includes several [b]adjustable settings[/b]:
[list]
[*] [b]Trade Direction:[/b] Choose between Long Only, Short Only, or Long & Short.
[*] [b]Trend Lengths:[/b] Adjust the Fast & Slow EMA lengths.
[*] [b]Market Level Extension:[/b] Decide whether to extend support/resistance lines.
[*] [b]Filters for Trade Confirmation:[/b] Enable/disable individual filters.
[*] [b]Color Settings:[/b] Customize line colors for bullish and bearish trend shifts.
[*] [b]Maximum Displayed Lines:[/b] Limit the number of drawn support/resistance lines.
[/list]

[b]Considerations & Limitations[/b]
[list]
[*] [b]Trend Lag:[/b] As with any EMA-based strategy, signals may be slightly delayed compared to price action.
[*] [b]Sideways Markets:[/b] This strategy works best in trending conditions; frequent crossovers in sideways markets can produce false signals.
[*] [b]Filter Usage:[/b] Enabling multiple filters may reduce trade frequency, but can also improve trade quality.
[*] [b]Line Overlap:[/b] If many crossovers occur in a short period, the chart may become cluttered with multiple trend levels. Adjusting the "Display Last" setting can help.
[/list]

[b]Conclusion[/b]
The Market Trend Levels Detector Strategy is a [b]non-repainting trend-following system[/b] that combines EMA crossovers, market level detection, and customizable filters to improve trade accuracy.

By identifying trend shifts and key price levels, this strategy can be used for:
[list]
[*] [b]Trend Confirmation[/b] – Using EMA crossovers and filters to confirm trend direction.
[*] [b]Support & Resistance Trading[/b] – Identifying dynamic levels where price reacts.
[*] [b]Momentum-Based Trading[/b] – Combining EMA crossovers with additional momentum filters.
[/list]

This strategy is fully customizable and can be adapted to different trading styles, timeframes, and market conditions.

[b]Full credit for the original concept and indicator goes to BigBeluga.[/b]

## Source Code

````pine
//@version=6
strategy("Market Trend Levels Non-Repainting [BigBeluga X PineIndicators]", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, max_boxes_count=500, max_labels_count=500, max_lines_count=500, commission_value=0.05, process_orders_on_close=true, margin_long=20, margin_short=20)

// Arrays for lines
var lines_up = array.new<line>()
var lines_dn = array.new<line>()

// INPUTS
string tradeDir = input.string("Long Only", "Trade Direction", options=["Long Only", "Short Only", "Long & Short"], group="Trade")
int length1 = input.int(12, "Fast", group="Trend")
int length2 = input.int(25, "Slow", group="Trend")
bool extend = input.bool(false, "Extend Lines", group="Levels")
int qty = input.int(50, "Display Last", group="Levels")
color col1 = input.color(#26ba9f, "", inline="col", group="Color")
color col2 = input.color(#6626ba, "", inline="col", group="Color")

// CALCULATIONS
float ema1 = ta.ema(close, length1)
float ema2 = ta.ema(close, length2)
float diff = ema1 - ema2

bool cross_up = ta.crossover(ema1, ema2) and barstate.isconfirmed
bool cross_dn = ta.crossunder(ema1, ema2) and barstate.isconfirmed

//─────────────────────────────────────────────────────────────
// FILTER INDICATORS (7 popular filters) & Settings
// Master switch for exit filters
bool applyExitFilters = input.bool(false, "Apply Filters for Exit", group="Filters")

// 1. RSI Filter
bool useRSI = input.bool(false, "RSI Filter", group="Filters")
int rsiLength = input.int(14, "RSI Length", group="Filters")
float rsiLongThreshold = input.float(50, "RSI Long Threshold", group="Filters")
float rsiShortThreshold = input.float(50, "RSI Short Threshold", group="Filters")
float rsiValue = ta.rsi(close, rsiLength)

// 2. MACD Filter
bool useMACD = input.bool(false, "MACD Filter", group="Filters")
int macdFast = input.int(12, "MACD Fast", group="Filters")
int macdSlow = input.int(26, "MACD Slow", group="Filters")
int macdSignal = input.int(9, "MACD Signal", group="Filters")
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSignal)

// 3. Stochastic Filter
bool useStoch = input.bool(false, "Stochastic Filter", group="Filters")
int stochKLength = input.int(14, "Stoch %K Length", group="Filters")
int stochDLength = input.int(3, "Stoch %D Length", group="Filters")
int stochSmooth = input.int(3, "Stoch Smooth", group="Filters")
float stochLongThreshold = input.float(50, "Stoch Long Threshold", group="Filters")
float stochShortThreshold = input.float(50, "Stoch Short Threshold", group="Filters")
float k = ta.sma(ta.stoch(close, high, low, stochKLength), stochSmooth)
float d = ta.sma(k, stochDLength)

// 4. Bollinger Bands Filter
bool useBB = input.bool(false, "Bollinger Bands Filter", group="Filters")
int bbLength = input.int(20, "BB Length", group="Filters")
float bbMult = input.float(2.0, "BB Multiplier", group="Filters")
float basis = ta.sma(close, bbLength)
float dev = bbMult * ta.stdev(close, bbLength)
float upper = basis + dev
float lower = basis - dev

// 5. ADX Filter – Manual Calculation
bool useADX = input.bool(false, "ADX Filter", group="Filters")
int adxLength = input.int(14, "ADX Length", group="Filters")
float adxThreshold = input.float(25, "ADX Threshold", group="Filters")
// Calculate True Range
float prevClose = nz(close[1], close)
float tr = math.max(high - low, math.max(math.abs(high - prevClose), math.abs(low - prevClose)))
// Calculate Directional Movement
float upMove = high - nz(high[1])
float downMove = nz(low[1]) - low
float plusDM = (upMove > downMove and upMove > 0) ? upMove : 0.0
float minusDM = (downMove > upMove and downMove > 0) ? downMove : 0.0
// Smoothing using Wilder's method
float atr = ta.rma(tr, adxLength)
float smPlusDM = ta.rma(plusDM, adxLength)
float smMinusDM = ta.rma(minusDM, adxLength)
float plusDI = atr != 0 ? 100 * (smPlusDM / atr) : 0.0
float minusDI = atr != 0 ? 100 * (smMinusDM / atr) : 0.0
float sumDI = plusDI + minusDI
float dx = sumDI != 0 ? 100 * math.abs(plusDI - minusDI) / sumDI : 0.0
float adxValue = ta.rma(dx, adxLength)

// 6. CCI Filter
bool useCCI = input.bool(false, "CCI Filter", group="Filters")
int cciLength = input.int(20, "CCI Length", group="Filters")
float cciValue = ta.cci(close, cciLength)

// 7. Williams %R Filter
bool useWilliams = input.bool(false, "Williams %R Filter", group="Filters")
int williamsLength = input.int(14, "Williams %R Length", group="Filters")
float williamsLongThreshold = input.float(-50, "Williams %R Long Threshold", group="Filters")
float williamsShortThreshold = input.float(-50, "Williams %R Short Threshold", group="Filters")
float williamsValue = ta.wpr(williamsLength)

// Filter conditions for Long and Short trades
bool filterLong = true
if useRSI
    filterLong := filterLong and (rsiValue > rsiLongThreshold)
if useMACD
    filterLong := filterLong and (histLine > 0)
if useStoch
    filterLong := filterLong and (k > stochLongThreshold)
if useBB
    filterLong := filterLong and (close > basis)
if useADX
    filterLong := filterLong and (adxValue > adxThreshold)
if useCCI
    filterLong := filterLong and (cciValue > 0)
if useWilliams
    filterLong := filterLong and (williamsValue > williamsLongThreshold)

bool filterShort = true
if useRSI
    filterShort := filterShort and (rsiValue < rsiShortThreshold)
if useMACD
    filterShort := filterShort and (histLine < 0)
if useStoch
    filterShort := filterShort and (k < stochShortThreshold)
if useBB
    filterShort := filterShort and (close < basis)
if useADX
    filterShort := filterShort and (adxValue > adxThreshold)
if useCCI
    filterShort := filterShort and (cciValue < 0)
if useWilliams
    filterShort := filterShort and (williamsValue < williamsShortThreshold)
//─────────────────────────────────────────────────────────────

// DRAW ALL SIGNALS – Labels and lines are always drawn
if cross_up
    longLine = line.new(bar_index, low, bar_index+25, low, color=col1)
    array.push(lines_dn, longLine)
    label.new(bar_index, low, "●", color=col1, style=label.style_label_up, textcolor=color.white, size=size.tiny)
if cross_dn
    shortLine = line.new(bar_index, high, bar_index+25, high, color=col2)
    array.push(lines_up, shortLine)
    label.new(bar_index, high, "●", color=col2, style=label.style_label_down, textcolor=color.white, size=size.tiny)

// TRADING LOGIC WITH FILTERS
if tradeDir == "Long & Short"
    // Long Entry
    if cross_up and strategy.position_size <= 0 and filterLong
        strategy.entry("Long", strategy.long)
    // Short Entry
    if cross_dn and strategy.position_size >= 0 and filterShort
        strategy.entry("Short", strategy.short)
    // Optional: Exit if filter conditions are no longer met
    if applyExitFilters
        if strategy.position_size > 0 and not filterLong
            strategy.close("Long")
        if strategy.position_size < 0 and not filterShort
            strategy.close("Short")
else if tradeDir == "Long Only"
    if cross_up and strategy.position_size <= 0 and filterLong
        strategy.entry("Long", strategy.long)
    if (cross_dn or (applyExitFilters and not filterLong)) and strategy.position_size > 0
        strategy.close("Long")
else if tradeDir == "Short Only"
    if cross_dn and strategy.position_size >= 0 and filterShort
        strategy.entry("Short", strategy.short)
    if (cross_up or (applyExitFilters and not filterShort)) and strategy.position_size < 0
        strategy.close("Short")

// LINE EXTENSION (optional)
if extend
    // Extend Short Lines
    if array.size(lines_up) > 0
        for i = array.size(lines_up)-1 to 0
            line_id = array.get(lines_up, i)
            line.set_x2(line_id, bar_index)
            if high > line.get_y2(line_id)
                line.set_style(line_id, line.style_dotted)
    // Extend Long Lines
    if array.size(lines_dn) > 0
        for i = array.size(lines_dn)-1 to 0
            line_id = array.get(lines_dn, i)
            line.set_x2(line_id, bar_index)
            if low < line.get_y2(line_id)
                line.set_style(line_id, line.style_dotted)

// PLOTS & FILLS
p1 = plot(ema1, "Fast EMA", display=display.none, color=col1)
p2 = plot(ema2, "Slow EMA", display=display.none, color=col2)
color color1 = color.from_gradient(diff, 0, ta.highest(diff, 100), color.new(col1, 70), col1)
color color2 = color.from_gradient(diff, ta.lowest(diff, 100), 0, col2, color.new(col2, 70))
fill(p1, p2, ema1 > ema2 ? color1 : color2)
plotshape(cross_up or cross_dn ? ema1[1] : na, "Signal", shape.xcross, location=location.absolute, offset=-1, color=chart.fg_color)

// LIMIT THE NUMBER OF LINES DRAWN
a_allLines = line.all
if array.size(a_allLines) > qty
    line.delete(array.shift(a_allLines))
````
