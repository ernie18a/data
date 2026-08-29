<!-- tradingview-pine-id: PUB;dca8752ffc6945a9b2909e9c31fa963a -->
<!-- tradingviewscripts-format: 1 -->
# MACD-X Overlay, More Than MACD by DGT

Source: https://www.tradingview.com/script/qtkFi42t-MACD-X-Overlay-More-Than-MACD-by-DGT/

## Description

Moving Average Convergence Divergence – MACD

The most popular indicator used in technical analysis , the moving average convergence divergence ( MACD ), created by Gerald Appel. MACD is a trend-following momentum indicator , designed to reveal changes in the strength, direction, momentum, and duration of a trend in a financial instrument’s price

Historical evolution of MACD ,

- Gerald Appel created the MACD line,
- Thomas Aspray added the histogram feature to MACD
- Giorgos E. Siligardos created a leader of MACD

MACD employs two Moving Averages of varying lengths (which are lagging indicators) to identify trend direction and duration. Then, MACD takes the difference in values between those two Moving Averages (MACD Line) and an EMA of those Moving Averages (Signal Line) and plots that difference between the two lines as a histogram which oscillates above and below a center Zero Line. The histogram is used as a good indication of a security's momentum.

The MACD indicator is typically good for identifying three types of basic signals;

Signal Line Crossovers
A Signal Line Crossover is the most common signal produced by the MACD . On the occasions where the MACD Line crosses above or below the Signal Line, that can signify a potentially strong move. The standard interpretation of such an event is a recommendation to buy if the MACD line crosses up through the Signal Line (a "bullish" crossover), or to sell if it crosses down through the Signal Line (a "bearish" crossover). These events are taken as indications that the trend in the financial instrument is about to accelerate in the direction of the crossover.

Zero Line Crossovers
Zero Line Crossovers occur when the MACD Line crossed the Zero Line and either becomes positive (above 0) or negative (below 0). A change from positive to negative MACD is interpreted as "bearish", and from negative to positive as "bullish". Zero crossovers provide evidence of a change in the direction of a trend but less confirmation of its momentum than a signal line crossover

Divergence
Divergence is another signal created by the MACD . Simply, divergence occurs when the MACD and actual price are not in agreement. A "positive divergence" or "bullish divergence" occurs when the price makes a new low but the MACD does not confirm with a new low of its own. A "negative divergence" or "bearish divergence" occurs when the price makes a new high but the MACD does not confirm with a new high of its own. A divergence with respect to price may occur on the MACD line and/or the MACD Histogram

Moving Average Crossovers, another hidden signal that MACD Indicator identifies
Many traders will watch for a short-term moving average to cross above a longer-term moving average and use this to signal increasing upward momentum. This bullish crossover suggests that the price has recently been rising at a faster rate than it has in the past, so it is a common technical buy sign. Conversely, a short-term moving average crossing below a longer-term average is used to illustrate that the asset's price has been moving downward at a faster rate and that it may be a good time to sell.
Moving Average Crossovers in reality is Zero Line Crossovers, the value of the MACD indicator is equal to zero each time the two moving averages cross over each other. For easy interpretation by trades, Zero Line Crossovers are simply described as positive or negative MACD

False signals
Like any forecasting algorithm, the MACD can generate false signals. A false positive, for example, would be a bullish crossover followed by a sudden decline in a financial instrument. A false negative would be a situation where there is bearish crossover, yet the financial instrument accelerated suddenly upwards

What is “MACD-X” and Why it is “More Than MACD”

In its simples form, MACD-X implements variety of different calculation techniques applied to obtain MACD Line. Different calculation techniques lead to different values for MACD Line, as will further discuss below, and as a consequence the signal line and the histogram values will differentiate accordingly. 

Main features of MACD-X ;

1- Plotting of the Oscillator presented on top of the price chart (main chart) and applicable on both log and linear scale. Maximum plotting length is limited to 250 bars 

2-  Introduces different proven techniques applied on MACD calculation, such as MACD-AS (Histogram), MACD-Leader and MACD-Source, besides the traditional MACD (MACD-TRADITIONAL)

• MACD-Traditional, by Gerald Appel
It is the MACD that we know, stated as traditional just to avoid confusion with other techniques used with this study

• MACD-Histogram, by Thomas Aspray

The MACD-Histogram measures the distance between MACD and its signal line (the 9-day EMA of MACD ). Aspray developed the MACD-Histogram to anticipate signal line crossovers in MACD . Because MACD uses moving averages and moving averages lag price, signal line crossovers can come late and affect the reward-to-risk ratio of a trade. Bullish or bearish divergences in the MACD-Histogram can alert chartists to an imminent signal line crossover in MACD

Aspray's contribution served as a way to anticipate (and therefore cut down on lag) possible MACD crossovers which are a fundamental part of the indicator.

• MACD-Leader, by Giorgos E. Siligardos, PhD

MACD Leader has the ability to lead MACD at critical situations. Almost all smoothing methods encounter in technical analysis are based on a relative-weighted sum of past prices, and the Leader is no exception. The concealed weights of MACD Leader are such that more relative weight is used in the more recent prices than the respective weights used by the components of MACD . In effect, the Leader expresses more changes in average price dynamics for the recent price movement than MACD , thus eventually leading MACD , especially when significant trend changes are about to take place.

• MACD-Source, a custom experimental interpretation of mine,

MACD Source, presents an application of MACD that evaluates Source/MA Ratio, relatively with less lag, as a basis for MACD Line, also can be expressed as source convergence/divergence to its moving average. Among the various techniques for removing the lag between price and moving average (MA) of the price, one in particular stands out: the addition to the moving average of a portion of the difference between the price and MA. MACD Source, is based on signal length mean of the difference between Source and average value of shot length and long length moving average of the source (Source/MA Ratio), where the source is actual value and hence no lag and relatively less lag with the average value of moving average of the source . 
MACD Source provides relatively early crossovers comparing to MACD and better momentum direction indications, assuming the lengths are set to same values

3- Alerts presented for MACD and Signal Line Crosses both for Early Warning and Confirmed Crossovers

For more, You are kindly invited to have a look to other MACD or similar  studies presented on separate pane
[MACD-X, More Than MACD by DGT](https://www.tradingview.com/script/Gq9I627Q-MACD-X-More-Than-MACD-by-DGT/), [P-MACD by DGT](https://www.tradingview.com/script/ZG82h6Wi-P-MACD-by-DGT/) and [Price Distance to its MA by DGT](https://www.tradingview.com/script/QzjN5jCL-Price-Distance-to-its-MA-by-DGT/)

Disclaimer: Trading success is all about following your trading strategy and the indicators should fit within your trading strategy, and not to be traded upon solely

The script is for informational and educational purposes only. Use of the script does not constitutes professional and/or financial advice. You alone the sole responsibility of evaluating the script output and risks associated with the use of the script. In exchange for using the script, you agree not to hold dgtrd TradingView user liable for any possible claim for damages arising from any decision you make based on use of the script

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : MACD-X Overlay, More Than MACD
//# * Author      : © dgtrd
//# *
//# * Revision History
//# *  Release    : Mar 10, 2022 : Initial Release
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator('MACD-X Overlay, More Than MACD by DGT', 'MACD-Xᴼ ☼☾', true, max_lines_count = 500, max_boxes_count = 250, max_bars_back = 500)

display = display.all - display.status_line

macdType = input.string('MACD-SOURCE', 'MACD Calculation Method', options = ['MACD-TRADITIONAL', 'MACD-AS (HISTOGRAM)', 'MACD-LEADER', 'MACD-SOURCE'], display = display,
     tooltip = 'Select the internal MACD engine:\n\n' +
               '• MACD-TRADITIONAL → Classic fast MA - slow MA\n' +
               '• MACD-AS → Histogram-driven variation (momentum emphasis)\n' +
               '• MACD-LEADER → Reduced lag version\n' +
               '• MACD-SOURCE → Source-adaptive smoothing model')

fast_length = input.int(12, 'Fast Length', minval = 1, display = display)
slow_length = input.int(26, 'Slow Length', minval = 1, display = display)
source = input(close, 'Source', display = display)
signal_length = input.int(9, 'Signal Smoothing', minval = 1, maxval = 50, display = display)
sma_source = input.string('EMA', 'Oscillator MA Type', options = ['SMA', 'EMA'], display = display)
sma_signal = input.string('EMA', 'Signal Line MA Type', options = ['SMA', 'EMA'], display = display)
macdSigCross = input.bool(false, 'Display MACD/Signal Corsses',
     tooltip = 'Displays on-chart labels when MACD crosses Signal.\nUsed for visual confirmation of alerts.')

highlight = input.bool(false, 'Highlight MACD/Signal Area',
tooltip = 'Fills the area between MACD and Signal.\nColor reflects bullish or bearish momentum dominance.')

lookbackLength = input.int(200, 'Overlay Indicator Display Length', minval = 10, maxval = 250, display = display)
oscPlacement = input.string('Bottom', 'Placement', options = ['Top', 'Bottom'], inline = 'VOL', display = display)
oscHight = 12 - input.int(7, 'Hight', minval = 1, maxval = 10, inline = 'VOL', display = display)
verticalAdj = input.int(3, 'Vertical Indicator Position', minval = 0, maxval = 10, display = display) / 10

ma(s, l, m) =>
    m == 'EMA' ? ta.ema(s, l) : ta.sma(s, l)

fast_ma = ma(source, fast_length, sma_source)
slow_ma = ma(source, slow_length, sma_source)
macd = fast_ma - slow_ma

macd := if macdType == 'MACD-TRADITIONAL'
    macd
else if macdType == 'MACD-AS (HISTOGRAM)'
    macd - ma(macd, signal_length, sma_source)
else if macdType == 'MACD-LEADER'
    macd + ma(source - fast_ma, fast_length, sma_source) - ma(source - slow_ma, slow_length, sma_source)
else
    ma(source - math.avg(fast_ma, slow_ma), signal_length, sma_source)

signal = ma(macd, signal_length, sma_signal)
hist = macd - signal

longAlertCondition = ta.crossover(macd, signal)
alertcondition(longAlertCondition, 'Long : Early Warning', 'MACD-X - Not Confirmed Probable Long Trade Opportunity\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')
alertcondition(longAlertCondition[1], 'Long : Trading Opportunity', 'MACD-X - Probable Long Trade Opportunity\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')
plotshape(macdSigCross ? longAlertCondition : false, 'Long', shape.labelup, location.belowbar, color.new(color.green, 0), size = size.tiny, show_last = lookbackLength, display = display, editable = false)

shortAlertCondition = ta.crossunder(macd, signal)
alertcondition(shortAlertCondition, 'Short : Early Warning', 'MACD-X - Not Confirmed Probable Short Trade Opportunity\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')
alertcondition(shortAlertCondition[1], 'Short : Trading Opportunity', 'MACD-X - Probable Short Trade Opportunity\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')
plotshape(macdSigCross ? shortAlertCondition : false, 'Short', shape.labeldown, location.abovebar, color.new(color.red, 0), size = size.tiny, show_last = lookbackLength, display = display, editable = false)

var a_lines = array.new_line()
var a_hist = array.new_box()
var a_fill = array.new_linefill()

priceHighest = ta.highest(high, lookbackLength)
priceLowest = ta.lowest(low, lookbackLength)
priceChangeRate = (priceHighest - priceLowest) / priceHighest
priceLowest := priceLowest * (1 - priceChangeRate * verticalAdj)
priceHighest := priceHighest * (1 + priceChangeRate * verticalAdj)
oscHighest = ta.highest(math.abs(macd), lookbackLength)
oscHighest := oscHighest == 0 ? 1 : oscHighest

histColor = hist >= 0 ? hist[1] < hist ? #006400 : color.green : hist[1] < hist ? color.red : #910000

if barstate.islast
    if array.size(a_lines) > 0
        for i = 1 to array.size(a_lines) by 1
            line.delete(array.shift(a_lines))

    if array.size(a_hist) > 0
        for i = 1 to array.size(a_hist) by 1
            box.delete(array.shift(a_hist))

    if array.size(a_fill) > 0
        for i = 1 to array.size(a_fill) by 1
            linefill.delete(array.shift(a_fill))

    hightAdj = priceChangeRate / oscHight

    for barIndex = 0 to lookbackLength - 1 by 1
        if array.size(a_lines) < 501
            array.push(a_hist, box.new(bar_index[barIndex], oscPlacement == 'Top' ? priceHighest : priceLowest, bar_index[barIndex], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + hist[barIndex] / oscHighest * hightAdj), histColor[barIndex], 2))
            array.push(a_lines, line.new(bar_index[barIndex], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + macd[barIndex] / oscHighest * hightAdj), bar_index[barIndex + 1], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + macd[barIndex + 1] / oscHighest * hightAdj), xloc.bar_index, extend.none, #2962FF, line.style_solid, 1))
            array.push(a_lines, line.new(bar_index[barIndex], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + signal[barIndex] / oscHighest * hightAdj), bar_index[barIndex + 1], (oscPlacement == 'Top' ? priceHighest : priceLowest) * (1 + signal[barIndex + 1] / oscHighest * hightAdj), xloc.bar_index, extend.none, #FF6D00, line.style_solid, 1))
            if highlight
                array.push(a_fill, linefill.new(array.get(a_lines, 2 * barIndex), array.get(a_lines, 2 * barIndex + 1), macd[barIndex] > signal[barIndex] ? color.new(#2962FF, 50) : color.new(#FF6D00, 50)))

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(logo, 0, 0, '☼☾  ', text_size = size.normal, text_color = color.teal, tooltip = 'SoleMare Analytics')
````
