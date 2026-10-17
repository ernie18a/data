# VortexT

- url: https://www.tradingview.com/script/Ol3XceHl/
- type: indicator
- pine_id: PUB;2a2ce9b46f1b43b4a3c6ee9eaf601edb
- version: 1.0

## Description

VortexT is an oscillator based on the Vortex Indicator. It measures the strength of upward and downward price movement with two lines, VI+ and VI-, and compares them to show which side dominates the market. On top of that it adds a trend background, a difference histogram and automatic divergence detection.

How It Works

Calculation

VI+ = sum of |high - previous low| over N bars, divided by the sum of the True Range over N bars.
VI- = sum of |low - previous high| over N bars, divided by the sum of the True Range over N bars.

VI+ measures how strongly price pushes up, VI- how strongly it pushes down. Both oscillate around 1.

Chart elements

Green line (VI+) and red line (VI-). With "Dynamic Trend View" enabled, only the dominant line is shown. When the line changes color, a crossover has occurred.
Background. Green when VI+ > VI-, red otherwise.
Histogram. Shows VI+ minus VI-. Above zero (lime) the trend is bullish, below zero (maroon) it is bearish. The height of the columns shows trend strength.
Bull Div / Bear Div. Divergences drawn with a dotted line and a label:
Bear Div: price makes a higher high, but VI+ makes a lower high. The uptrend is losing strength.
Bull Div: price makes a lower low, but VI- makes a lower high. The downtrend is losing strength.

Parameters

Length (14). Lower values give more signals and more noise. Higher values (e.g. 21) give fewer, slower signals.
Pivot Lookback (7). Number of bars on each side used to confirm a pivot.
Max Bars Between Pivots (60). Maximum distance between the two pivots of a divergence.
Show Divergences. Turns divergence lines and labels on or off.

How to Trade It

Long entry

A VI+ crossover above VI- is the base signal: the line turns green, the background turns green and the histogram moves above zero.
Enter only after the candle closes. During the candle the crossover can appear and disappear.
Confirm with the histogram: the columns should grow over the following bars. If it stays flat near zero, the signal is weak.
Confirm with price: it is better to enter when price breaks the high of the crossover candle.
Strongest setup: a Bull Div followed by a bullish crossover. The divergence warns that the downtrend is running out of steam, and the crossover confirms the restart.

Short entry. The mirror image: VI- crossing above VI+, red line, red background, histogram below zero and expanding. The strongest setup is a Bear Div followed by a bearish crossover, entering on a break of the low of the crossover candle.

Exit

Stop loss. For a long, below the low of the crossover candle or below the last swing low. For a short, above the corresponding high. Alternatively use an ATR multiple, especially on very volatile altcoins.
Take profit. A fixed target at R:R 1.5 or 2, or a partial close at 1R with a trailing stop on the rest.
Signal-based exit. Exit or reduce when:
the histogram columns shrink toward zero for several bars, because momentum is fading;
a divergence opposite to your position appears (Bear Div if you are long);
the opposite crossover occurs, which is the definitive exit.
When to Avoid It
Sideways markets. The lines cross constantly, the histogram stays tiny and the indicator produces a chain of false signals. If you see three or four close crossovers with low columns, stay out.
Against the higher-timeframe trend. Use a higher timeframe as a filter, for example trade only longs on the 1H if the 4H is green.

                                                               Dislaimer
Not financial advice. This indicator and its description are provided for educational and informational purposes only. Nothing here constitutes investment advice, a recommendation, or an offer to buy or sell any financial instrument. The author is not a licensed financial advisor.

## Source Code

````pine
//@version=6
indicator(title="VortexT", shorttitle="Vt", format=format.price, precision=4, overlay=false, max_lines_count=500, max_labels_count=500)

// === Parameters ===
period_ = input.int(14, title="Length", minval=2, tooltip="Period for Vortex calculation. 14 is standard")
showHistogram = input.bool(true, title="Show Difference Histogram", tooltip="Display VI+ minus VI- as colored columns")
showBackground = input.bool(true, title="Show Trend Background", tooltip="Color background based on dominant Vortex line")
dynamicView = input.bool(true, title="Dynamic Trend View", tooltip="Show only the dominant Vortex line (VI+ when above VI-, VI- when above VI+)")
showDiv = input.bool(true, title="Show Divergences", tooltip="Show or hide divergence lines and labels")
lb = input.int(7, title="Pivot Lookback", minval=2, tooltip="Bars lookback for pivot detection. Higher values = fewer but stronger signals")
maxDist = input.int(60, title="Max Bars Between Pivots", minval=5, tooltip="Divergences are drawn only if the two pivots are at most this many bars apart")

// === Vortex Calculation ===
VMP = math.sum(math.abs(high - low[1]), period_)
VMM = math.sum(math.abs(low - high[1]), period_)
STR = math.sum(ta.tr, period_)
VIP = STR > 0 ? VMP / STR : na
VIM = STR > 0 ? VMM / STR : na
delta = VIP - VIM

// === Logic for Dynamic Display ===
plotVIP = dynamicView ? (VIP >= VIM ? VIP : na) : VIP
plotVIM = dynamicView ? (VIM > VIP ? VIM : na) : VIM

// === Plotting Vortex Lines ===
plot(plotVIP, title="VI + (Bullish Momentum)", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)
plot(plotVIM, title="VI - (Bearish Momentum)", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)

// === Bearish Divergence ===
// Price makes higher high, but VI+ makes lower high
phVIP = ta.pivothigh(VIP, lb, lb)
var float lastPricePH = na
var float lastVIPPH   = na
var int   lastBarPH   = na

if not na(phVIP)
    pivotBar = bar_index - lb
    if showDiv and not na(lastVIPPH) and high[lb] > lastPricePH and phVIP < lastVIPPH and pivotBar - lastBarPH <= maxDist
        line.new(lastBarPH, lastVIPPH, pivotBar, phVIP, xloc=xloc.bar_index, color=color.new(color.red, 30), width=2, style=line.style_dotted)
        label.new(pivotBar, phVIP, "Bear Div", color=color.new(color.red, 20), style=label.style_label_down, textcolor=color.white, size=size.small)
    lastPricePH := high[lb]
    lastVIPPH   := phVIP
    lastBarPH   := pivotBar

// === Bullish Divergence ===
// Price makes lower low, but VI- makes lower high
phVIM = ta.pivothigh(VIM, lb, lb)
var float lastPricePL = na
var float lastVIMPH   = na
var int   lastBarPL   = na

if not na(phVIM)
    pivotBar = bar_index - lb
    if showDiv and not na(lastVIMPH) and low[lb] < lastPricePL and phVIM < lastVIMPH and pivotBar - lastBarPL <= maxDist
        line.new(lastBarPL, lastVIMPH, pivotBar, phVIM, xloc=xloc.bar_index, color=color.new(color.green, 30), width=2, style=line.style_dotted)
        label.new(pivotBar, phVIM, "Bull Div", color=color.new(color.green, 20), style=label.style_label_up, textcolor=color.white, size=size.small)
    lastPricePL := low[lb]
    lastVIMPH   := phVIM
    lastBarPL   := pivotBar

// === Zero Line ===
hline(0.0, title="Zero Line", color=color.new(color.gray, 70), linestyle=hline.style_dashed)

// === Trend Background ===
bgcolor(showBackground ? (VIP > VIM ? color.new(color.green, 92) : color.new(color.red, 92)) : na)

// === Difference Histogram ===
plot(showHistogram ? delta : na, title="VI+ minus VI- Difference", style=plot.style_columns,
     color=delta >= 0 ? color.new(color.lime, 60) : color.new(color.maroon, 60))

// === Data Window ===
plot(VIP, title="VI+ (full)", display=display.data_window)
plot(VIM, title="VI- (full)", display=display.data_window)
````
