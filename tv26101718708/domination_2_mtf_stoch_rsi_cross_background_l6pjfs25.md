# Domination 2 ... MTF Stoch RSI Cross Background

- url: https://www.tradingview.com/script/l6PJfs25-Domination-2-MTF-Stoch-RSI-Cross-Background/
- type: indicator
- pine_id: PUB;73932ea1e44e445d8989bbf89a888453
- version: 1.0

## Description

**Domination 2 — MTF Stoch RSI Background**

Domination 2 is a clean multi-timeframe Stoch RSI background indicator designed to show bullish and bearish momentum directly on the price chart.

The indicator uses the selected Stoch RSI timeframe and colours the chart background based on the relationship between the Stoch RSI K and D lines.

**Core Background Rules**

* **Green background** = Stoch RSI K is above D
* **Red background** = Stoch RSI K is below D

This allows traders to quickly see whether the selected timeframe Stoch RSI momentum is bullish or bearish without needing to constantly check the oscillator panel.

**Main Features**

* Multi-timeframe Stoch RSI background
* Selectable Stoch RSI timeframe
* Green background when K is above D
* Red background when K is below D
* Adjustable background transparency
* Optional K/D cross markers
* Optional Stoch RSI table
* Optional ATR trend system
* ATR system is turned off by default
* Clean default setup with only the background colours enabled

**How It Works**

Domination 2 calculates the Stoch RSI K and D values from the selected timeframe. The chart background then follows the current K/D relationship:

* If K is above D, the background turns green.
* If K is below D, the background turns red.

This creates a simple visual momentum map directly behind price action.

**Suggested Use**

This indicator can be used to monitor higher-timeframe or selected-timeframe Stoch RSI momentum while trading on any chart timeframe.

For example, traders may use a 1D Stoch RSI background on a lower timeframe chart to stay aware of the broader momentum condition.

**Optional Tools**

The indicator also includes optional features that can be enabled manually:

* K/D cross labels
* Stoch RSI information table
* ATR trend line system
* ATR trend flip markers
* ATR bar colouring and highlighting

These are turned off by default so the indicator starts as a clean background-only tool.

**Disclaimer**

This indicator is designed as a visual momentum aid only. It is not financial advice and should not be used by itself for trade entries or exits. Always combine it with your own analysis, risk management, market structure, and trading plan.

## Source Code

````pine
//@version=6
indicator('Domination 2 — Precise MTF Stoch RSI Cross Background', overlay = true, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. STOCH RSI BACKGROUND SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupStoch = '1. Precise MTF Stoch RSI Cross Background'

stochRsiTfInput = input.timeframe('', 'Stoch RSI Timeframe — Blank = Chart Timeframe', group = groupStoch)
stochSource = input.source(close, 'Stoch RSI Source', group = groupStoch)

rsiLength = input.int(8, 'RSI Length', minval = 1, group = groupStoch)
stochLength = input.int(5, 'Stoch Length', minval = 1, group = groupStoch)
kSmooth = input.int(3, 'K Smoothing', minval = 1, group = groupStoch)
dSmooth = input.int(3, 'D Smoothing', minval = 1, group = groupStoch)

// DEFAULT ON
showStochBackground = input.bool(true, 'Show Stoch RSI Background', group = groupStoch)

// DEFAULT OFF
showCrossMarkers = input.bool(false, 'Show K/D Cross Markers', group = groupStoch)
showDebugTable = input.bool(false, 'Show Stoch RSI Table', group = groupStoch)

greenTransparency = input.int(86, 'Green Background Transparency', minval = 0, maxval = 100, group = groupStoch)
redTransparency = input.int(86, 'Red Background Transparency', minval = 0, maxval = 100, group = groupStoch)

stochRsiTf = stochRsiTfInput == '' ? timeframe.period : stochRsiTfInput


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. STOCH RSI FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_stoch_rsi_k(_src, _rsiLength, _stochLength, _kSmooth) =>
    _rsi = ta.rsi(_src, _rsiLength)
    _rawStoch = ta.stoch(_rsi, _rsi, _rsi, _stochLength)
    _k = ta.sma(_rawStoch, _kSmooth)
    _k

f_stoch_rsi_d(_src, _rsiLength, _stochLength, _kSmooth, _dSmooth) =>
    _rsi = ta.rsi(_src, _rsiLength)
    _rawStoch = ta.stoch(_rsi, _rsi, _rsi, _stochLength)
    _k = ta.sma(_rawStoch, _kSmooth)
    _d = ta.sma(_k, _dSmooth)
    _d


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. MTF STOCH RSI VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

stochK = request.security(
     syminfo.tickerid,
     stochRsiTf,
     f_stoch_rsi_k(stochSource, rsiLength, stochLength, kSmooth),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

stochD = request.security(
     syminfo.tickerid,
     stochRsiTf,
     f_stoch_rsi_d(stochSource, rsiLength, stochLength, kSmooth, dSmooth),
     barmerge.gaps_off,
     barmerge.lookahead_off
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. PRECISE STOCH RSI CROSS RULES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Exact rule:
//
// K above D = green background.
// K below D = red background.
//
// The background is based directly on the same MTF K/D values shown in the data window.

bullCross = ta.crossover(stochK, stochD)
bearCross = ta.crossunder(stochK, stochD)

greenPhase = stochK > stochD
redPhase = stochK < stochD

var int lastValidPhase = 0

lastValidPhase := greenPhase ? 1 :
     redPhase ? -1 :
     nz(lastValidPhase[1], 0)

finalGreen = lastValidPhase == 1
finalRed = lastValidPhase == -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. BACKGROUND COLOURS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

greenBgColor = color.new(color.rgb(40, 220, 40), greenTransparency)
redBgColor = color.new(color.rgb(230, 50, 50), redTransparency)

stochBackgroundColor =
     finalGreen ? greenBgColor :
     finalRed ? redBgColor :
     na

bgcolor(showStochBackground ? stochBackgroundColor : na)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. STOCH RSI CROSS MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showCrossMarkers and bullCross,
     title = 'Stoch RSI Bullish Cross — K Above D',
     text = 'BULLISH',
     location = location.bottom,
     style = shape.labelup,
     size = size.tiny,
     color = color.new(color.green, 0),
     textcolor = color.white
)

plotshape(
     showCrossMarkers and bearCross,
     title = 'Stoch RSI Bearish Cross — K Below D',
     text = 'BEARISH',
     location = location.top,
     style = shape.labeldown,
     size = size.tiny,
     color = color.new(color.red, 0),
     textcolor = color.white
)

// Data Window values for checking against your Stoch RSI panel.
plot(stochK, title = 'MTF Stoch RSI K — Data Window', display = display.data_window)
plot(stochD, title = 'MTF Stoch RSI D — Data Window', display = display.data_window)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. STOCH RSI TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTable = '2. Stoch RSI Table'

tablePosition = input.string(
     'Top Right',
     'Table Position',
     options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'],
     group = groupTable
)

tableSize = input.string(
     'Small',
     'Table Size',
     options = ['Tiny', 'Small', 'Normal'],
     group = groupTable
)

f_table_position(_pos) =>
    _pos == 'Top Right' ? position.top_right :
     _pos == 'Top Left' ? position.top_left :
     _pos == 'Bottom Right' ? position.bottom_right :
     position.bottom_left

f_table_size(_size) =>
    _size == 'Tiny' ? size.tiny :
     _size == 'Small' ? size.small :
     size.normal

selectedTfText = stochRsiTfInput == '' ? 'Chart TF: ' + timeframe.period : stochRsiTfInput

phaseText =
     finalGreen ? 'Green — K Above D' :
     finalRed ? 'Red — K Below D' :
     'Neutral'

phaseStatus =
     bullCross ? 'Bullish Cross Now' :
     bearCross ? 'Bearish Cross Now' :
     finalGreen ? 'Bullish Phase Active' :
     finalRed ? 'Bearish Phase Active' :
     'No Phase Yet'

phaseColor =
     finalGreen ? greenBgColor :
     finalRed ? redBgColor :
     color.new(color.gray, 80)

var table stochTable = table.new(f_table_position(tablePosition), 2, 6, border_width = 1)

if barstate.islast
    txtSize = f_table_size(tableSize)

    if showDebugTable
        table.cell(stochTable, 0, 0, 'Stoch RSI', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = txtSize)
        table.cell(stochTable, 1, 0, 'Value', text_color = color.white, bgcolor = color.new(color.black, 0), text_size = txtSize)

        table.cell(stochTable, 0, 1, 'Selected TF', text_color = color.white, bgcolor = color.new(color.black, 60), text_size = txtSize)
        table.cell(stochTable, 1, 1, selectedTfText, text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)

        table.cell(stochTable, 0, 2, 'Phase', text_color = color.white, bgcolor = color.new(color.black, 60), text_size = txtSize)
        table.cell(stochTable, 1, 2, phaseText, text_color = color.white, bgcolor = phaseColor, text_size = txtSize)

        table.cell(stochTable, 0, 3, 'K', text_color = color.white, bgcolor = color.new(color.black, 60), text_size = txtSize)
        table.cell(stochTable, 1, 3, str.tostring(stochK, '#.##'), text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)

        table.cell(stochTable, 0, 4, 'D', text_color = color.white, bgcolor = color.new(color.black, 60), text_size = txtSize)
        table.cell(stochTable, 1, 4, str.tostring(stochD, '#.##'), text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)

        table.cell(stochTable, 0, 5, 'Status', text_color = color.white, bgcolor = color.new(color.black, 60), text_size = txtSize)
        table.cell(stochTable, 1, 5, phaseStatus, text_color = color.white, bgcolor = color.new(color.black, 75), text_size = txtSize)
    else
        table.clear(stochTable, 0, 0, 1, 5)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. ATR TREND SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupAtr = '3. ATR Trend Signals'

// DEFAULT OFF
showAtrSystem = input.bool(false, 'Show ATR Trend System', group = groupAtr)

Periods = input.int(title = 'ATR Period', defval = 2, minval = 1, group = groupAtr)
src = input.source(open, title = 'ATR Source', group = groupAtr)
Multiplier = input.float(title = 'ATR Multiplier', step = 0.1, defval = 2.3, group = groupAtr)

// DEFAULT OFF
showsignals = input.bool(title = 'Show Buy/Sell Labels?', defval = false, group = groupAtr)
highlighting = input.bool(title = 'ATR Highlighter On/Off?', defval = false, group = groupAtr)
barcoloring = input.bool(title = 'Bar Coloring On/Off?', defval = false, group = groupAtr)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. ATR TREND CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(Periods)

up = src - Multiplier * atr
up1 = nz(up[1], up)
up := open[1] > up1 ? math.max(up, up1) : up

dn = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := open[1] < dn1 ? math.min(dn, dn1) : dn

trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and open > dn1 ? 1 : trend == 1 and open < up1 ? -1 : trend

upPlot = plot(
     showAtrSystem and trend == 1 ? up : na,
     title = 'Up Trend',
     style = plot.style_linebr,
     linewidth = 2,
     color = color.new(color.green, 0)
)

buySignal = trend == 1 and trend[1] == -1

plotshape(
     showAtrSystem and buySignal ? up : na,
     title = 'UpTrend Begins',
     location = location.absolute,
     style = shape.arrowup,
     size = size.huge,
     color = color.rgb(242, 255, 4)
)

plotshape(
     showAtrSystem and buySignal and showsignals ? up : na,
     title = 'Buy',
     text = 'Bullish',
     location = location.absolute,
     style = shape.labelup,
     size = size.tiny,
     color = color.new(color.green, 0),
     textcolor = color.white
)

dnPlot = plot(
     showAtrSystem and trend == -1 ? dn : na,
     title = 'Down Trend',
     style = plot.style_linebr,
     linewidth = 2,
     color = color.new(color.red, 0)
)

sellSignal = trend == -1 and trend[1] == 1

plotshape(
     showAtrSystem and sellSignal ? dn : na,
     title = 'DownTrend Begins',
     location = location.absolute,
     style = shape.arrowdown,
     size = size.huge,
     color = color.rgb(242, 255, 4)
)

plotshape(
     showAtrSystem and sellSignal and showsignals ? dn : na,
     title = 'Sell',
     text = 'Bearish',
     location = location.absolute,
     style = shape.labeldown,
     size = size.tiny,
     color = color.new(color.red, 0),
     textcolor = color.white
)

mPlot = plot(
     showAtrSystem ? ohlc4 : na,
     title = '',
     style = plot.style_circles,
     linewidth = 1
)

longFillColor = showAtrSystem and highlighting and trend == 1 ? #4caf4f58 : na
shortFillColor = showAtrSystem and highlighting and trend == -1 ? #ff52525e : na

fill(mPlot, upPlot, title = 'UpTrend Highlighter', color = longFillColor)
fill(mPlot, dnPlot, title = 'DownTrend Highlighter', color = shortFillColor)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10. BAR COLOURING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barColor =
     showAtrSystem and barcoloring ?
         trend == 1 ? color.new(color.green, 0) :
         trend == -1 ? color.new(color.red, 0) :
         na :
     na

barcolor(barColor)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11. ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(bullCross, title = 'Stoch RSI Bullish Cross', message = 'Selected-timeframe Stoch RSI K crossed above D. Background turned green.')
alertcondition(bearCross, title = 'Stoch RSI Bearish Cross', message = 'Selected-timeframe Stoch RSI K crossed below D. Background turned red.')

alertcondition(showAtrSystem and buySignal, title = 'ATR Bullish Trend Flip', message = 'ATR trend flipped bullish.')
alertcondition(showAtrSystem and sellSignal, title = 'ATR Bearish Trend Flip', message = 'ATR trend flipped bearish.')
````
