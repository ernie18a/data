# QSL - MTF Momentum Trend Validator

- url: https://www.tradingview.com/script/bpEeWADV-QSL-MTF-Momentum-Trend-Validator/
- type: indicator
- pine_id: PUB;c70391c71f1b42bda24854d43daed0ff
- version: 1.0

## Description

[b]What this indicator does[/b]

This indicator shows [b]the trend on seven timeframes at the same time[/b], in one table. It helps you check whether a momentum move is supported by the bigger picture.

In one view you see:

[list]
[*]the order of four moving averages on every timeframe (up trend, down trend or mixed)
[*]how steep the fast averages are pointing
[*]how fresh or old each trend is
[*]the latest momentum candle with its volume
[*]the 24 hour liquidity
[*]what Bitcoin is doing right now
[/list]

Move your mouse over any cell to see the real numbers behind it.

The indicator gives [b]information only[/b]. It does not give buy or sell signals and it does not open or close trades.


[b]The idea behind it[/b]

A big candle on a small timeframe often attracts attention. Before you act on it, you want to know the context:

[list=1]
[*]Is the higher timeframe trend in the same direction?
[*]Is the trend also visible on the timeframe you trade?
[*]Are the fast averages pointing steeply, or are they flat?
[*]Did the trend just start, or is it already old?
[*]Is there enough volume?
[*]Is Bitcoin supporting the move, or pulling the market the other way?
[/list]

Normally you open many charts to answer these questions. This script puts all the answers in one table.


[b]What makes it different[/b]

Most moving average scripts show the order of the averages on one chart, or one value per timeframe in a table. This script adds measurements that make the trend easier to judge:

[list]
[*][b]Separation-weighted Stack Score[/b] – a stacked timeframe only counts fully when the averages are clearly apart, measured in ATR units. Tight, flat stacks count less.
[*][b]Joint slope in ATR per bar[/b] – both fast averages must point in the same direction. Because it is measured in ATR, the same setting works on every coin and every price level.
[*][b]Alignment age[/b] – shows per timeframe how many bars ago the trend started, so you see the difference between a fresh trend and a late one.
[*][b]Momentum candle with relative volume[/b] – a single-candle momentum check where the volume is compared with the average candle of the last 24 hours.
[*][b]Bitcoin context[/b] – the market leader is checked live.
[*][b]Bias column[/b] – compares each average with itself on the next longer timeframe, so you see whether the shorter timeframes are leading.
[/list]


[b]What you see on the chart[/b]

[list]
[*]Four moving averages (default EMA 13, 21, 55 and 144) with a coloured band between the two fastest lines.
[*]Dotted lines to the right of the last candle with a length label, so you always know which line is which.
[*]A table with one column per timeframe (default 1m, 3m, 5m, 15m, 1h, 4h, 1D), sorted from short to long.
[/list]


[b]How to read the table[/b]

[i]Example: Bitcoin on the daily chart – 5 of 7 timeframes stacked bullish, 15m and 1h still mixed, Stack Score +77[/i]
https://www.tradingview.com/x/7X5CWylT/

[i]Arrows (rows 13, 21, 55)[/i]
Each arrow compares one average with the next slower average [b]on the same timeframe[/b]. A green up arrow means it is above, a red down arrow means it is below.

[i]Aligned[/i]
BULL means 13 > 21 > 55 > 144 on that timeframe. BEAR means the opposite. A score such as 2:1 means mixed.

[i]Slope[/i]
The direction of the two fastest averages, measured in ATR per bar.
[list]
[*]↑ steep up
[*]↗ rising
[*]→ flat
[*]↘ falling
[*]↓ steep down
[/list]
The cell is solid only when [b]both[/b] fast averages are steep.

[i]Age[/i]
How many bars ago that timeframe became fully stacked. A small number means a fresh trend. A large number means an older trend.

[i]Bias column[/i]
Compares one average with itself on the next longer timeframe. BULL means the shorter timeframes are leading the longer ones upward.

[i]Stack Score[/i]
One number from -100 to +100. Each timeframe adds its stack order, scaled by how far the fastest and slowest averages are apart in ATR units. Longer timeframes count more.

[i]Example: a full bullish alignment – all 7 timeframes BULL, Stack Score +98[/i]
https://www.tradingview.com/x/sXUYKc7R/

[i]24h volume[/i]
Rolling 24 hour turnover in the quote currency, built from 1-minute candles. Green when above your minimum.

[i]Momentum candle[/i]
One candle (default 3 minutes) that moved at least the chosen percentage from open to close, with enough candle volume and relative volume. Relative volume compares the candle with the average candle of the last 24 hours: 0% is normal, +100% is twice normal.
[list]
[*][b]Solid green / red[/b] – a momentum candle up / down in the last 20 candles
[*][b]Light green / red[/b] – no momentum candle; the light colour only shows the direction of the last candle
[/list]

The main image of this publication shows a solid green momentum row in a coin that is stacked bullish on most timeframes.

[i]BTC[/i]
Bitcoin change over the last hour (default 4 × 15m), live:
[list]
[*]GREEN – Bitcoin is rising
[*]CONSOLIDATING – Bitcoin is moving sideways
[*]DROPPING – Bitcoin is falling
[/list]


[b]How to use it[/b]

The indicator does not decide for you. A common way to read it:

[list=1]
[*]Are the higher timeframes (for example 1h, 4h, 1D) BULL in the Aligned row?
[*]On the timeframe you trade, is the Slope ↑ or ↗?
[*]Is the Age on that timeframe a small number?
[*]Is there a solid green momentum candle?
[*]Is the 24h volume row green?
[*]Is Bitcoin green or consolidating?
[/list]

Then look at the chart itself and make your own decision.

[i]Example: a sharp green candle while 1m to 1h are still stacked bearish – the table shows the conflict at a glance[/i]
https://www.tradingview.com/x/ZWH4qP3j/


[b]Alerts[/b]

[list]
[*]All timeframes aligned bullish / bearish
[*]Chart timeframe aligned bullish / bearish
[*]Momentum candle up / down
[/list]


[b]Repainting[/b]

[list]
[*]The moving average grid, slope, age, score and momentum candle use [b]closed bars[/b] of every timeframe by default ("Use confirmed higher timeframe values"). They do not change after the bar closes.
[*]The BTC row and the 24h volume row are [b]live on purpose[/b]. You want to know what Bitcoin is doing right now, not one candle ago.
[/list]


[b]Settings overview[/b]

[list]
[*]Moving averages – type (EMA, DEMA, SMA), four lengths, colours, bands and labels.
[*]Dashboard timeframes – seven timeframes, each with an on/off switch.
[*]Dashboard style – show or hide rows and columns, position, size, colours.
[*]Score, slope & age – slope length, when a slope counts as steep, when a trend counts as fresh, score weighting.
[*]24h volume – minimum turnover in millions.
[*]Momentum candle – % move, timeframe, minimum candle volume, minimum relative volume, look back.
[*]Bitcoin – symbol, timeframe and number of candles, consolidation band.
[/list]


[b]Good to know[/b]

[list]
[*]Use the same market you trade: spot and perpetual contracts are different symbols on TradingView.
[*]Moving averages look back at older prices. They react after price moves, not before.
[*]An aligned trend does not mean the next trade will win. It only means the trend is confirmed on several timeframes.
[/list]


[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. It is not financial advice and it is not a recommendation to buy or sell anything. Past behaviour of any market does not guarantee future results. Trading crypto, especially with leverage, carries a high risk and you can lose your money. Always do your own research and use proper risk management.

## Source Code

````pine
//   ___  ____  _
//  / _ \/ ___|| |
// | | | \___ \| |
// | |_| |___) | |___
//  \__\_\____/|_____|   QuantSignalLabs
//
//@version=6
// ---------------------------------------------------------------------------------------------------------------------------------
//  QSL - MTF Momentum Trend Validator v3.0
//  Grid:    per timeframe, is each average above the next slower one?  13 > 21 > 55 > 144 = bullish alignment.
//  Bias:    per average, is it above its own value on every next (longer) timeframe?
//  Score:   weighted -100..+100 stack strength over all timeframes, scaled by MA separation in ATR units.
//  Slope:   are the two fastest averages pointing up or down, and how steep (the "12 o'clock" check)?
//  Age:     how many bars ago each timeframe became fully stacked (fresh vs. late trend).
//  Signal:  single-candle momentum check (open to close %, candle volume, relative volume).
//  BTC:     is Bitcoin rising, consolidating or dropping?
//  Information only: the indicator does not tell you to take or skip a trade.
//
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © QuantSignalLabs
//
// ---------------------------------------------------------------------------------------------------------------------------------
indicator('QSL - MTF Momentum Trend Validator', shorttitle = 'QSL - MTF Momentum Trend Validator', overlay = true, max_lines_count = 500)

// ---------------------------------------------------------------------------------------------------------------------------------
// --- Inputs :: Moving averages ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
string GRP_MA = 'Moving averages'

float  i_src    = input.source(close, '    Source', group = GRP_MA, inline='R1')
string i_maType = input.string('EMA', '  Type', options = ['EMA', 'DEMA', 'SMA'], group = GRP_MA, inline='R1', tooltip = 'EMA  - exponential moving average\nDEMA - double exponential moving average (faster, less lag)\nSMA  - simple moving average (for comparison / testing)')

bool  i_show1 = input.bool(true, '', inline = 'ma1', group = GRP_MA)
int   i_len1  = input.int(13, 'Length 1', minval = 1, inline = 'ma1', group = GRP_MA)
color i_col1  = input.color(#FFEB3A, '', inline = 'ma1', group = GRP_MA)
int   i_wid1  = input.int(1, '', minval = 1, maxval = 4, inline = 'ma1', group = GRP_MA)

bool  i_show2 = input.bool(true, '', inline = 'ma2', group = GRP_MA)
int   i_len2  = input.int(21, 'Length 2', minval = 1, inline = 'ma2', group = GRP_MA)
color i_col2  = input.color(#E91E63, '', inline = 'ma2', group = GRP_MA)
int   i_wid2  = input.int(1, '', minval = 1, maxval = 4, inline = 'ma2', group = GRP_MA)

bool  i_show3 = input.bool(true, '', inline = 'ma3', group = GRP_MA)
int   i_len3  = input.int(55, 'Length 3', minval = 1, inline = 'ma3', group = GRP_MA)
color i_col3  = input.color(#2862FF, '', inline = 'ma3', group = GRP_MA)
int   i_wid3  = input.int(1, '', minval = 1, maxval = 4, inline = 'ma3', group = GRP_MA)

bool  i_show4 = input.bool(true, '', inline = 'ma4', group = GRP_MA)
int   i_len4  = input.int(144, 'Length 4', minval = 1, inline = 'ma4', group = GRP_MA)
color i_col4  = input.color(#ff9800, '', inline = 'ma4', group = GRP_MA)
int   i_wid4  = input.int(1, '', minval = 1, maxval = 4, inline = 'ma4', group = GRP_MA)

bool i_fillFast = input.bool(true,  'Fill fast ribbon (MA1 / MA2)',    group = GRP_MA)
bool i_fillEnv  = input.bool(false, 'Fill trend envelope (MA1 / MA4)', group = GRP_MA)

bool   i_extend   = input.bool(true, 'Extend lines to the right', group = GRP_MA, inline='R2')
string i_rayStyle = input.string('Dotted', '    Style', options = ['Solid', 'Dashed', 'Dotted'], group = GRP_MA, inline='R2')
string i_labSize  = input.string('Large', 'Label size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = GRP_MA, inline='R3')
int    i_labOff   = input.int(3, '  Label offset', minval = 0, maxval = 50, group = GRP_MA, inline='R3', tooltip = 'How many bars to the right of the last candle the length label sits.')


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Inputs :: Dashboard ---------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
string GRP_TF   = 'Dashboard timeframes'
string GRP_DASH = 'Dashboard style'
string GRP_SCR  = 'Score, slope & age'
string GRP_VOL  = '24h volume'
string GRP_PCT  = 'Momentum candle'
string GRP_BTC  = 'Bitcoin'

bool   i_use1 = input.bool(true, '', inline = 'tf1', group = GRP_TF)
string i_tf1  = input.timeframe('1',   'TF 1', inline = 'tf1', group = GRP_TF)
bool   i_use2 = input.bool(true, '', inline = 'tf2', group = GRP_TF)
string i_tf2  = input.timeframe('3',   'TF 2', inline = 'tf2', group = GRP_TF)
bool   i_use3 = input.bool(true, '', inline = 'tf3', group = GRP_TF)
string i_tf3  = input.timeframe('5',   'TF 3', inline = 'tf3', group = GRP_TF)
bool   i_use4 = input.bool(true, '', inline = 'tf4', group = GRP_TF)
string i_tf4  = input.timeframe('15',  'TF 4', inline = 'tf4', group = GRP_TF)
bool   i_use5 = input.bool(true, '', inline = 'tf5', group = GRP_TF)
string i_tf5  = input.timeframe('60',  'TF 5', inline = 'tf5', group = GRP_TF)
bool   i_use6 = input.bool(true, '', inline = 'tf6', group = GRP_TF)
string i_tf6  = input.timeframe('240', 'TF 6', inline = 'tf6', group = GRP_TF)
bool   i_use7 = input.bool(true, '', inline = 'tf7', group = GRP_TF)
string i_tf7  = input.timeframe('1D',  'TF 7', inline = 'tf7', group = GRP_TF)

bool i_closedTf = input.bool(true, 'Use confirmed higher timeframe values', group = GRP_TF, tooltip = 'On  - reads the last closed bar of every timeframe, so the table never repaints.\nOff - reads the live bar, which updates faster but can change until the bar closes.\n\nColumns are always shown from the shortest to the longest timeframe, whatever order they are entered in.')

bool   i_showDash  = input.bool(true, 'Show dashboard', group = GRP_DASH)
bool   i_showBias  = input.bool(true, 'Show Bias column', group = GRP_DASH, tooltip = 'The Bias column checks one average against its own value on every next timeframe.')
bool   i_showSlope = input.bool(true, 'Show Slope row', group = GRP_DASH, tooltip = 'Direction of the two fastest averages on each timeframe.\n↑ steep up (12 o\'clock)   ↗ rising   → flat   ↘ falling   ↓ steep down')
bool   i_showAge   = input.bool(true, 'Show Age row', group = GRP_DASH, tooltip = 'Bars (of that timeframe) since all four averages became stacked in the current direction.')
string i_dashPos   = input.string('Top right', 'Position ', options = ['Top right', 'Middle right', 'Bottom right', 'Top left', 'Middle left', 'Bottom left', 'Bottom center'], group = GRP_DASH, inline = "R1")
string i_dashSize  = input.string('Small', 'Text size ', options = ['Tiny', 'Small', 'Normal', 'Large'], group = GRP_DASH, inline = "R2")
string i_dashStyle = input.string('Minimal', 'Cell style', options = ['Minimal', 'Filled'], group = GRP_DASH, inline = "R3")
color  i_colBull   = input.color(#26a69a, 'Bullish', inline = 'dc', group = GRP_DASH)
color  i_colBear   = input.color(#ef5350, 'Bearish', inline = 'dc', group = GRP_DASH)
color  i_colPanel  = input.color(#131722, 'Panel',   inline = 'dc', group = GRP_DASH)

int    i_slopeLen  = input.int(3, 'Slope over (bars)', minval = 1, maxval = 50, group = GRP_SCR, inline = 'slp')
float  i_slopeMin  = input.float(0.15, '  Steep at (ATR/bar)', minval = 0.01, step = 0.05, group = GRP_SCR, inline = 'slp', tooltip = 'When the Slope row shows a steep arrow (↑ or ↓) and a solid cell.\nMeasured as the change per bar in ATR units: 1 ATR per bar is a 45° angle.\n0.15 is a clear push, 0.3 or more is close to 12 o\'clock.')
int    i_maxAge    = input.int(20, 'Fresh trend within (bars)', minval = 0, group = GRP_SCR, tooltip = 'The Age row shows a solid cell when a timeframe stacked within this many of its own bars. 0 = always solid.')
bool   i_weightHtf = input.bool(true, 'Weight longer timeframes more', group = GRP_SCR, tooltip = 'Stack Score: on  - the shortest timeframe counts 1x, the next 2x, and so on.\nOff - every timeframe counts the same.')
int    i_atrLen    = input.int(14, 'ATR length', minval = 1, group = GRP_SCR, inline = 'atr')
float  i_sepFull   = input.float(1.5, '  Full strength at (ATR)', minval = 0.1, step = 0.1, group = GRP_SCR, inline = 'atr', tooltip = 'Distance between the fastest and slowest average, in ATR units, at which a stacked timeframe counts at full strength in the Stack Score.\nTightly packed averages count for less because the trend has not separated yet.')

bool  i_showVol = input.bool(true, 'Show 24h volume row', group = GRP_VOL)
float i_minVol  = input.float(5, 'Minimum 24h volume (millions)', minval = 0, step = 5, group = GRP_VOL, tooltip = 'Entered in millions: 5 means 5 million, 50 means 50 million, 1000 means 1 billion.\n\nCounted in the quote currency of the symbol, for example USDT on BTCUSDT.\nThe row turns green when the rolling 24 hour volume is at or above this number, and red when it is below.')

bool   i_showPct = input.bool(true, 'Show momentum candle row', group = GRP_PCT)
float  i_pctMin  = input.float(2.0, '% change ≥', minval = 0, step = 0.1, inline = 'pct', group = GRP_PCT)
string i_pctTf   = input.timeframe('3', '  on', inline = 'pct', group = GRP_PCT, tooltip = 'One candle, open to close, at or beyond this percentage, up or down.')
float  i_minCVol = input.float(0.5, 'Candle vol ≥ (millions)', minval = 0, step = 0.1, inline = 'cv', group = GRP_PCT)
float  i_minRVol = input.float(100, '  Rel vol ≥ (%)', step = 10, inline = 'cv', group = GRP_PCT, tooltip = 'Candle vol - quote turnover of the momentum candle. 0 = off.\nRel vol - candle volume against the average candle implied by the 24h total. 0% is average, +100% is twice average. 0 = off.')
int    i_pctLook = input.int(20, 'Look back (candles)', minval = 1, maxval = 100, group = GRP_PCT, tooltip = 'How many candles back a momentum candle is still shown.\nDefault 20 x 3m = 1 hour.\n\nUses closed candles when "Use confirmed higher timeframe values" is on.')

bool   i_btcOn   = input.bool(true, 'Show Bitcoin row', group = GRP_BTC, tooltip = 'Shows whether Bitcoin is rising, moving sideways or dropping. Most coins follow Bitcoin.')
string i_btcSym  = input.symbol('BINANCE:BTCUSDT', 'Symbol', group = GRP_BTC)
string i_btcTf   = input.timeframe('15', 'Change over', inline = 'btc', group = GRP_BTC)
int    i_btcLook = input.int(4, '  x', minval = 1, maxval = 100, inline = 'btc', group = GRP_BTC, tooltip = 'Bitcoin change from the open of the oldest candle to the live price.\nDefault 15m x 4 = the last hour.')
float  i_btcBand = input.float(0.3, 'Consolidating within ± (%)', minval = 0, step = 0.05, group = GRP_BTC, tooltip = 'Inside this band Bitcoin counts as consolidating. Above is green, below is dropping.')

// ---------------------------------------------------------------------------------------------------------------------------------
// --- Functions -------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
maCalc(simple string maType, float src, simple int len) =>
    float e1 = ta.ema(src, len)
    switch maType
        'SMA'  => ta.sma(src, len)
        'DEMA' => 2 * e1 - ta.ema(e1, len)
        => e1

tfLabel(simple string tf) =>
    float s = timeframe.in_seconds(tf)
    s < 60 ? str.tostring(s, '#') + 's' : s < 3600 ? str.tostring(s / 60, '#') + 'm' : s < 86400 ? str.tostring(s / 3600, '#') + 'h' : s < 604800 ? str.tostring(s / 86400, '#') + 'D' : s < 2419200 ? str.tostring(s / 604800, '#') + 'W' : str.tostring(math.round(s / 2628003), '#') + 'M'

cmpDir(float a, float b) =>
    na(a) or na(b) ? 0 : a > b ? 1 : a < b ? -1 : 0

fmtVol(float v) =>
    float a = math.abs(v)
    a >= 1e12 ? str.tostring(v / 1e12, '#.##') + 'T' : a >= 1e9 ? str.tostring(v / 1e9, '#.##') + 'B' : a >= 1e6 ? str.tostring(v / 1e6, '#.##') + 'M' : a >= 1e3 ? str.tostring(v / 1e3, '#.##') + 'K' : str.tostring(v, '#.##')

fmtSigned(float v, string fmt) =>
    (v >= 0 ? '+' : '') + str.tostring(v, fmt)

// Each call site keeps its own line and label thanks to var, so one call per average is enough.
maRay(bool show, float v, color c, int w, int lenTxt, int offset, string sty, string txtSize) =>
    var line  ln = na
    var label lb = na
    if barstate.islast
        line.delete(ln)
        label.delete(lb)
        if show and not na(v)
            ln := line.new(bar_index, v, bar_index + 1, v, extend = extend.right, color = c, width = w, style = sty)
            lb := label.new(bar_index + offset, v, str.tostring(lenTxt), style = label.style_label_left, color = color.new(c, 88), textcolor = c, size = txtSize)


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Chart timeframe averages ----------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
float ma1 = maCalc(i_maType, i_src, i_len1)
float ma2 = maCalc(i_maType, i_src, i_len2)
float ma3 = maCalc(i_maType, i_src, i_len3)
float ma4 = maCalc(i_maType, i_src, i_len4)
float atrV = ta.atr(i_atrLen)

bool chartBull = ma1 > ma2 and ma2 > ma3 and ma3 > ma4
bool chartBear = ma1 < ma2 and ma2 < ma3 and ma3 < ma4
int  stackDir  = chartBull ? 1 : chartBear ? -1 : 0
int  stackChg  = ta.barssince(stackDir != stackDir[1])
int  stackAge  = stackDir == 0 ? na : stackChg
float slope1   = atrV > 0 ? (ma1 - ma1[i_slopeLen]) / i_slopeLen / atrV : na
float slope2   = atrV > 0 ? (ma2 - ma2[i_slopeLen]) / i_slopeLen / atrV : na

plot_1 = plot(i_show1 ? ma1 : na, 'MA 1', color = i_col1, linewidth = i_wid1)
plot_2 = plot(i_show2 ? ma2 : na, 'MA 2', color = i_col2, linewidth = i_wid2)
plot_3 = plot(i_show3 ? ma3 : na, 'MA 3', color = i_col3, linewidth = i_wid3)
plot_4 = plot(i_show4 ? ma4 : na, 'MA 4', color = i_col4, linewidth = i_wid4)

fill(plot_1, plot_2, color = i_fillFast and i_show1 and i_show2 ? color.new(ma1 >= ma2 ? i_colBull : i_colBear, 85) : na, title = 'Fast ribbon')
fill(plot_1, plot_4, color = i_fillEnv  and i_show1 and i_show4 ? color.new(ma1 >= ma4 ? i_colBull : i_colBear, 93) : na, title = 'Trend envelope')

simple string rayStyle = switch i_rayStyle
    'Solid'  => line.style_solid
    'Dashed' => line.style_dashed
    => line.style_dotted

simple string labSize = switch i_labSize
    'Tiny'   => size.tiny
    'Normal' => size.normal
    'Large'  => size.large
    => size.small

maRay(i_extend and i_show1, ma1, i_col1, i_wid1, i_len1, i_labOff, rayStyle, labSize)
maRay(i_extend and i_show2, ma2, i_col2, i_wid2, i_len2, i_labOff, rayStyle, labSize)
maRay(i_extend and i_show3, ma3, i_col3, i_wid3, i_len3, i_labOff, rayStyle, labSize)
maRay(i_extend and i_show4, ma4, i_col4, i_wid4, i_len4, i_labOff, rayStyle, labSize)


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Multi timeframe request -----------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
simple int hOff = i_closedTf ? 1 : 0

htfMAs(simple string tf, simple int off) =>
    request.security(syminfo.tickerid, tf, [ma1[off], ma2[off], ma3[off], ma4[off], atrV[off], stackAge[off], slope1[off], slope2[off]], lookahead = barmerge.lookahead_off)

[t1a, t1b, t1c, t1d, t1r, t1g, t1s, t1u] = htfMAs(i_tf1, hOff)
[t2a, t2b, t2c, t2d, t2r, t2g, t2s, t2u] = htfMAs(i_tf2, hOff)
[t3a, t3b, t3c, t3d, t3r, t3g, t3s, t3u] = htfMAs(i_tf3, hOff)
[t4a, t4b, t4c, t4d, t4r, t4g, t4s, t4u] = htfMAs(i_tf4, hOff)
[t5a, t5b, t5c, t5d, t5r, t5g, t5s, t5u] = htfMAs(i_tf5, hOff)
[t6a, t6b, t6c, t6d, t6r, t6g, t6s, t6u] = htfMAs(i_tf6, hOff)
[t7a, t7b, t7c, t7d, t7r, t7g, t7s, t7u] = htfMAs(i_tf7, hOff)


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Matrices --------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
// vals is stored MA-major: index = maIndex * 7 + tfIndex
array<float> vals   = array.from(t1a, t2a, t3a, t4a, t5a, t6a, t7a, t1b, t2b, t3b, t4b, t5b, t6b, t7b, t1c, t2c, t3c, t4c, t5c, t6c, t7c, t1d, t2d, t3d, t4d, t5d, t6d, t7d)
array<float> atrs   = array.from(t1r, t2r, t3r, t4r, t5r, t6r, t7r)
array<int>   ages   = array.from(t1g, t2g, t3g, t4g, t5g, t6g, t7g)
array<float> slp1   = array.from(t1s, t2s, t3s, t4s, t5s, t6s, t7s)
array<float> slp2   = array.from(t1u, t2u, t3u, t4u, t5u, t6u, t7u)
array<bool>  tfOn   = array.from(i_use1, i_use2, i_use3, i_use4, i_use5, i_use6, i_use7)
array<int>   tfSecs = array.from(timeframe.in_seconds(i_tf1), timeframe.in_seconds(i_tf2), timeframe.in_seconds(i_tf3), timeframe.in_seconds(i_tf4), timeframe.in_seconds(i_tf5), timeframe.in_seconds(i_tf6), timeframe.in_seconds(i_tf7))

// Active timeframes, sorted shortest to longest so Bias and weighting never depend on input order.
array<int>   onIdx = array.new<int>()
array<int>   onSec = array.new<int>()
for i = 0 to 6
    if tfOn.get(i)
        onIdx.push(i)
        onSec.push(tfSecs.get(i))
if onIdx.size() > 1
    array<int> ord = onSec.sort_indices(order.ascending)
    array<int> tmp = onIdx.copy()
    for k = 0 to ord.size() - 1
        onIdx.set(k, tmp.get(ord.get(k)))
int tfCount   = onIdx.size()
int pairCount = math.max(tfCount - 1, 0)

// GRID: one average against the next slower average, inside the same timeframe. 3 pairs per timeframe.
array<int> gridDir = array.new<int>(21, 0)
for m = 0 to 2
    for i = 0 to 6
        gridDir.set(m * 7 + i, cmpDir(vals.get(m * 7 + i), vals.get((m + 1) * 7 + i)))

// BIAS: one average against its own value on the next longer timeframe.
array<int> tfDir = array.new<int>(28, 0)
if pairCount > 0
    for m = 0 to 3
        for k = 0 to pairCount - 1
            int lo = onIdx.get(k)
            int hi = onIdx.get(k + 1)
            tfDir.set(m * 7 + lo, cmpDir(vals.get(m * 7 + lo), vals.get(m * 7 + hi)))

// Per timeframe: full stack direction and strength contribution to the Stack Score.
array<int>   tfStack = array.new<int>(7, 0)
array<float> tfScore = array.new<float>(7, 0.0)
array<float> tfW     = array.new<float>(7, 0.0)
int   alignedBull = 0
int   alignedBear = 0
float wSum        = 0.0
float sSum        = 0.0
if tfCount > 0
    for k = 0 to tfCount - 1
        int i = onIdx.get(k)
        int b = 0
        int s = 0
        for m = 0 to 2
            int d = gridDir.get(m * 7 + i)
            b := b + (d > 0 ? 1 : 0)
            s := s + (d < 0 ? 1 : 0)
        tfStack.set(i, b == 3 ? 1 : s == 3 ? -1 : 0)
        alignedBull := alignedBull + (b == 3 ? 1 : 0)
        alignedBear := alignedBear + (s == 3 ? 1 : 0)

        float a        = atrs.get(i)
        float sep      = na(a) or a <= 0 ? 0.0 : math.abs(vals.get(i) - vals.get(21 + i)) / a
        float strength = math.min(nz(sep) / i_sepFull, 1.0)
        float sc       = (b - s) / 3.0 * (0.6 + 0.4 * strength)
        float w        = i_weightHtf ? k + 1.0 : 1.0
        tfScore.set(i, sc)
        tfW.set(i, w)
        wSum := wSum + w
        sSum := sSum + w * sc

bool  allTfBull = tfCount > 0 and alignedBull == tfCount
bool  allTfBear = tfCount > 0 and alignedBear == tfCount
float score     = wSum > 0 ? 100 * sSum / wSum : na

plot(score, 'Stack Score', display = display.data_window)


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Rolling 24 hour volume ------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
// Always measured on 1-minute candles so the number lines up with what the exchange reports.
// Turnover in the quote currency: every minute adds volume x close, unless the feed already reports quote volume.
float turnover = syminfo.volumetype == 'quote' ? volume : volume * close
float vol1m    = request.security(syminfo.tickerid, '1', math.sum(turnover, 1440), lookahead = barmerge.lookahead_off)

// Fallback for symbols without 1-minute history: add up the bars of the current chart instead.
simple int volBars  = math.min(math.max(int(86400 / timeframe.in_seconds()), 1), 5000)
float      volChart = math.sum(turnover, volBars)

float vol24  = na(vol1m) ? volChart : vol1m
bool  volAlt = na(vol1m) and not na(volChart)
float minVol = i_minVol * 1000000
bool  volOk  = not na(vol24) and vol24 >= minVol


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Momentum candle -------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
// One candle, open to close, at or beyond the threshold, with candle vol and rel vol filters.
simple int dayBars = math.min(math.max(int(86400 / timeframe.in_seconds(i_pctTf)), 1), 5000)

sigSet(simple int sh, simple int nDay) =>
    float o      = open[sh]
    float chg    = o > 0 ? (close[sh] - o) / o * 100 : na
    float cv     = turnover[sh]
    float v24all = math.sum(turnover, nDay)
    float v24    = v24all[sh]
    float rv     = na(v24) or v24 <= 0 ? na : (cv / (v24 / nDay) - 1) * 100
    bool  vPass  = (i_minCVol == 0 or cv >= i_minCVol * 1e6) and (i_minRVol == 0 or (not na(rv) and rv >= i_minRVol))
    bool  up     = chg >= i_pctMin and vPass
    bool  dn     = chg <= -i_pctMin and vPass
    [chg, ta.barssince(up), ta.barssince(dn), ta.valuewhen(up, chg, 0), ta.valuewhen(up, cv, 0), ta.valuewhen(up, rv, 0), ta.valuewhen(dn, chg, 0), ta.valuewhen(dn, cv, 0), ta.valuewhen(dn, rv, 0)]

[sigLast, upAgo, dnAgo, upChg, upCv, upRv, dnChg, dnCv, dnRv] = request.security(syminfo.tickerid, i_pctTf, sigSet(hOff, dayBars), lookahead = barmerge.lookahead_off)

bool sigUp  = not na(upAgo) and upAgo < i_pctLook
bool sigDn  = not na(dnAgo) and dnAgo < i_pctLook
int  sigDir = sigUp and sigDn ? (upAgo <= dnAgo ? 1 : -1) : sigUp ? 1 : sigDn ? -1 : 0
bool pctOk  = sigDir != 0

float sigChg  = sigDir > 0 ? upChg : sigDir < 0 ? dnChg : na
float sigCv   = sigDir > 0 ? upCv  : sigDir < 0 ? dnCv  : na
float sigRv   = sigDir > 0 ? upRv  : sigDir < 0 ? dnRv  : na
int   sigCndl = sigDir > 0 ? upAgo + 1 : sigDir < 0 ? dnAgo + 1 : na


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Bitcoin ---------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
// Live value on purpose: the question is whether Bitcoin is dropping right now.
float btcChg   = request.security(i_btcSym, i_btcTf, open[i_btcLook - 1] > 0 ? (close - open[i_btcLook - 1]) / open[i_btcLook - 1] * 100 : na, lookahead = barmerge.lookahead_off)
int   btcState = na(btcChg) ? 0 : btcChg >= i_btcBand ? 1 : btcChg <= -i_btcBand ? -1 : 0
string btcTxt  = na(btcChg) ? 'NO DATA' : btcState > 0 ? 'GREEN' : btcState < 0 ? 'DROPPING' : 'CONSOLIDATING'


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Dashboard -------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
bool dashFilled = i_dashStyle == 'Filled'

color cChip       = color.new(#1e222d, 15)
color cChipDim    = color.new(#1e222d, 45)
color cHead       = color.new(#0b0e14, 25)
color cTextDim    = color.new(#787b86, 15)
color cTextBright = #d1d4dc

simple string dashPos = switch i_dashPos
    'Top right'    => position.top_right
    'Middle right' => position.middle_right
    'Bottom right' => position.bottom_right
    'Top left'     => position.top_left
    'Middle left'  => position.middle_left
    'Bottom left'  => position.bottom_left
    => position.bottom_center

simple string dashTxt = switch i_dashSize
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    => size.large

dirCol(int d) =>
    d > 0 ? i_colBull : d < 0 ? i_colBear : cTextDim

chipBg(color c, bool strong) =>
    strong or dashFilled ? color.new(c, 0) : cChip

chipTx(color c, bool strong) =>
    strong or dashFilled ? color.white : c

// Both fast averages must agree; the weaker one sets the angle.
jointSlope(float s1, float s2) =>
    na(s1) or na(s2) ? na : s1 > 0 and s2 > 0 ? math.min(s1, s2) : s1 < 0 and s2 < 0 ? math.max(s1, s2) : 0.0

slopeGlyph(float j) =>
    float steep = i_slopeMin
    na(j) ? '–' : j >= steep ? '↑' : j > steep / 4 ? '↗' : j <= -steep ? '↓' : j < -steep / 4 ? '↘' : '→'

angleTxt(float s) =>
    na(s) ? '–' : fmtSigned(s, '#.##') + ' ATR/bar  (' + fmtSigned(math.atan(s) * 180 / math.pi, '#') + '°)'

var table dash = table.new(position = dashPos, columns = 9, rows = 12, bgcolor = color.new(i_colPanel, 12), frame_color = color.new(#2a2e39, 0), frame_width = 1, border_color = color.new(#2a2e39, 30), border_width = 1)

cell(int col, int row, string txt, color txtCol, color bg, string halign, string tip) =>
    table.cell(dash, col, row, txt, text_color = txtCol, bgcolor = bg, text_halign = halign, text_size = dashTxt, tooltip = tip)

wideRow(int row, int lastCol, string txt, color txtCol, color bg, string tip) =>
    for c = 0 to lastCol
        cell(c, row, c == 0 ? txt : '', txtCol, bg, text.align_center, tip)
    table.merge_cells(dash, 0, row, lastCol, row)

verdict(int b, int s, int total) =>
    total == 0 ? '–' : b == total ? 'BULL' : s == total ? 'BEAR' : str.tostring(b) + ':' + str.tostring(s)

if barstate.islast
    table.clear(dash, 0, 0, 8, 11)
    if i_showDash and tfCount > 0
        array<string> tfTxt  = array.from(tfLabel(i_tf1), tfLabel(i_tf2), tfLabel(i_tf3), tfLabel(i_tf4), tfLabel(i_tf5), tfLabel(i_tf6), tfLabel(i_tf7))
        array<int>    lens   = array.from(i_len1, i_len2, i_len3, i_len4)
        array<color>  maCols = array.from(i_col1, i_col2, i_col3, i_col4)

        cell(0, 0, i_maType, cTextBright, cHead, text.align_left, 'Every arrow compares two averages inside the same timeframe.\n' + str.tostring(i_len1) + ' > ' + str.tostring(i_len2) + ' > ' + str.tostring(i_len3) + ' > ' + str.tostring(i_len4) + '  =  bullish alignment.')
        for m = 0 to 3
            string rowTip = m < 3 ? i_maType + ' ' + str.tostring(lens.get(m)) + ' compared with ' + i_maType + ' ' + str.tostring(lens.get(m + 1)) + ' on the same timeframe' : i_maType + ' ' + str.tostring(lens.get(m)) + ' is the slowest average, so there is nothing below it to compare with'
            cell(0, m + 1, str.tostring(lens.get(m)), maCols.get(m), cHead, text.align_right, rowTip)
        cell(0, 5, 'Aligned', cTextDim, cHead, text.align_right, 'Are all four averages stacked in order on that timeframe?')

        if i_showBias
            cell(8, 0, 'Bias', cTextDim, cHead, text.align_center, 'Is this average above its own value on every next timeframe?')

        for k = 0 to tfCount - 1
            int  i         = onIdx.get(k)
            bool isChartTf = tfSecs.get(i) == timeframe.in_seconds()
            cell(k + 1, 0, tfTxt.get(i), isChartTf ? color.white : cTextBright, cHead, text.align_center, isChartTf ? 'Chart timeframe' : 'Read through request.security()')

        // Grid: alignment inside each timeframe
        for m = 0 to 3
            bool lastMa = m == 3
            for k = 0 to tfCount - 1
                int i = onIdx.get(k)
                int d = lastMa ? 0 : gridDir.get(m * 7 + i)
                string glyph = lastMa ? '•' : d > 0 ? '▲' : d < 0 ? '▼' : '='
                string tip = lastMa ? 'Slowest average – nothing below it to compare with.\n' + i_maType + ' ' + str.tostring(lens.get(m)) + ' on ' + tfTxt.get(i) + ' = ' + str.tostring(vals.get(m * 7 + i), format.mintick) : 'On ' + tfTxt.get(i) + '\n' + i_maType + ' ' + str.tostring(lens.get(m)) + ' = ' + str.tostring(vals.get(m * 7 + i), format.mintick) + '\n' + i_maType + ' ' + str.tostring(lens.get(m + 1)) + ' = ' + str.tostring(vals.get((m + 1) * 7 + i), format.mintick) + '\n' + (d > 0 ? str.tostring(lens.get(m)) + ' is above ' + str.tostring(lens.get(m + 1)) : d < 0 ? str.tostring(lens.get(m)) + ' is below ' + str.tostring(lens.get(m + 1)) : 'Both averages are equal')
                cell(k + 1, m + 1, glyph, lastMa ? cTextDim : chipTx(dirCol(d), false), lastMa ? cChipDim : chipBg(dirCol(d), false), text.align_center, tip)

            // Bias: same average across the timeframes
            if i_showBias
                int biasBull = 0
                int biasBear = 0
                if pairCount > 0
                    for k = 0 to pairCount - 1
                        int d = tfDir.get(m * 7 + onIdx.get(k))
                        biasBull := biasBull + (d > 0 ? 1 : 0)
                        biasBear := biasBear + (d < 0 ? 1 : 0)
                int  biasDir   = biasBull == pairCount and pairCount > 0 ? 1 : biasBear == pairCount and pairCount > 0 ? -1 : biasBull > biasBear ? 1 : biasBear > biasBull ? -1 : 0
                bool biasSolid = pairCount > 0 and (biasBull == pairCount or biasBear == pairCount)
                cell(8, m + 1, verdict(biasBull, biasBear, pairCount), chipTx(dirCol(biasDir), biasSolid), chipBg(dirCol(biasDir), biasSolid), text.align_center, i_maType + ' ' + str.tostring(lens.get(m)) + ' is above its own value on ' + str.tostring(biasBull) + ' of ' + str.tostring(pairCount) + ' timeframe steps')

        // Aligned row: full stack check per timeframe
        for k = 0 to tfCount - 1
            int i = onIdx.get(k)
            int b = 0
            int s = 0
            string tip = 'Order on ' + tfTxt.get(i) + ':'
            for m = 0 to 2
                int d = gridDir.get(m * 7 + i)
                b := b + (d > 0 ? 1 : 0)
                s := s + (d < 0 ? 1 : 0)
                tip := tip + '\n' + str.tostring(lens.get(m)) + (d > 0 ? '  above  ' : d < 0 ? '  below  ' : '  equals  ') + str.tostring(lens.get(m + 1))
            tip := tip + '\n\nScore contribution: ' + fmtSigned(100 * tfScore.get(i), '#') + '  (weight ' + str.tostring(tfW.get(i), '#') + ')'
            int  d2    = b == 3 ? 1 : s == 3 ? -1 : b > s ? 1 : s > b ? -1 : 0
            bool solid = b == 3 or s == 3
            cell(k + 1, 5, verdict(b, s, 3), chipTx(dirCol(d2), solid), chipBg(dirCol(d2), solid), text.align_center, tip)

        if i_showBias
            int  allDir   = allTfBull ? 1 : allTfBear ? -1 : alignedBull > alignedBear ? 1 : alignedBear > alignedBull ? -1 : 0
            bool allSolid = allTfBull or allTfBear
            string allTxt = allTfBull ? 'FULL BULL' : allTfBear ? 'FULL BEAR' : str.tostring(alignedBull) + '/' + str.tostring(tfCount)
            cell(8, 5, allTxt, chipTx(dirCol(allDir), allSolid), chipBg(dirCol(allDir), allSolid), text.align_center, str.tostring(alignedBull) + ' of ' + str.tostring(tfCount) + ' timeframes are fully stacked bullish, ' + str.tostring(alignedBear) + ' fully bearish')

        int lastCol = i_showBias ? 8 : tfCount
        int statRow = 6

        // Slope row: direction of the two fastest averages
        if i_showSlope
            cell(0, statRow, 'Slope', cTextDim, cHead, text.align_right, 'Direction of ' + str.tostring(i_len1) + ' and ' + str.tostring(i_len2) + ' over the last ' + str.tostring(i_slopeLen) + ' bars, in ATR per bar.\n↑ steep up (12 o\'clock)   ↗ rising   → flat   ↘ falling   ↓ steep down\nSolid when both are steep.')
            for k = 0 to tfCount - 1
                int   i     = onIdx.get(k)
                float j     = jointSlope(slp1.get(i), slp2.get(i))
                int   d     = na(j) or j == 0 ? 0 : j > 0 ? 1 : -1
                bool  steep = not na(j) and math.abs(j) >= i_slopeMin
                string sTip = tfTxt.get(i) + '\n' + str.tostring(i_len1) + ':  ' + angleTxt(slp1.get(i)) + '\n' + str.tostring(i_len2) + ':  ' + angleTxt(slp2.get(i))
                cell(k + 1, statRow, slopeGlyph(j), chipTx(dirCol(d), steep), chipBg(dirCol(d), steep), text.align_center, sTip)
            if i_showBias
                cell(8, statRow, '≥ ' + str.tostring(i_slopeMin, '#.##'), cTextDim, cHead, text.align_center, 'Steep from this many ATR per bar')
            statRow := statRow + 1

        // Age row: bars since each timeframe stacked in its current direction
        if i_showAge
            cell(0, statRow, 'Age', cTextDim, cHead, text.align_right, 'Bars of that timeframe since all four averages stacked in the current direction.\nFresh (within the max age) is solid, late is outlined.')
            for k = 0 to tfCount - 1
                int  i     = onIdx.get(k)
                int  d     = tfStack.get(i)
                int  g     = ages.get(i)
                bool fresh = d != 0 and not na(g) and (i_maxAge == 0 or g <= i_maxAge)
                string aTxt = d == 0 or na(g) ? '–' : str.tostring(g)
                string aTip = d == 0 ? tfTxt.get(i) + ' is not fully stacked' : tfTxt.get(i) + ' stacked ' + (d > 0 ? 'bullish ' : 'bearish ') + str.tostring(g) + ' bar' + (g == 1 ? '' : 's') + ' ago' + (fresh ? '' : '  (late)')
                cell(k + 1, statRow, aTxt, d == 0 ? cTextDim : chipTx(dirCol(d), fresh), d == 0 ? cChipDim : chipBg(dirCol(d), fresh), text.align_center, aTip)
            if i_showBias
                cell(8, statRow, i_maxAge == 0 ? '–' : '≤ ' + str.tostring(i_maxAge), cTextDim, cHead, text.align_center, 'Fresh trend: stacked within this many bars')
            statRow := statRow + 1

        // Stack Score row
        int    scDir = nz(score) > 0 ? 1 : nz(score) < 0 ? -1 : 0
        bool   scSol = math.abs(nz(score)) >= 60
        string scTip = 'Weighted stack strength over all timeframes, -100 (fully bearish) to +100 (fully bullish).\nEach timeframe: stack order x separation of ' + str.tostring(i_len1) + ' and ' + str.tostring(i_len4) + ' in ATR units.\n'
        for k = 0 to tfCount - 1
            int i = onIdx.get(k)
            scTip := scTip + '\n' + tfTxt.get(i) + '  ' + fmtSigned(100 * tfScore.get(i), '#') + '  x' + str.tostring(tfW.get(i), '#')
        wideRow(statRow, lastCol, 'Stack Score   ' + fmtSigned(nz(score), '#') + ' / 100', chipTx(dirCol(scDir), scSol), chipBg(dirCol(scDir), scSol), scTip)
        statRow := statRow + 1

        if i_showVol
            string volTxt  = na(vol24) ? '24h volume   no data for this symbol' : '24h volume   ' + fmtVol(vol24) + '  ' + (volOk ? '≥' : '<') + '  ' + fmtVol(minVol) + '   ' + syminfo.currency
            color  volBg   = na(vol24) ? cChipDim : color.new(volOk ? i_colBull : i_colBear, 0)
            color  volTx   = na(vol24) ? cTextDim : color.white
            string volTip  = na(vol24) ? 'This symbol does not provide volume data.' : 'Rolling 24 hour turnover: ' + str.tostring(vol24, '#') + ' ' + syminfo.currency + '\nMinimum from the settings: ' + str.tostring(minVol, '#') + ' ' + syminfo.currency + '\n\n' + (volAlt ? 'Added up from the last ' + str.tostring(volBars) + ' bars of this chart, because 1 minute data is not available for this symbol.' : 'Added up from the last 1440 one-minute candles.')
            wideRow(statRow, lastCol, volTxt, volTx, volBg, volTip)
            statRow := statRow + 1

        if i_showPct
            string tfS     = tfLabel(i_pctTf)
            string ruleTxt = '≥ ±' + str.tostring(i_pctMin, '#.##') + '%'
            string pctTxt  = pctOk ? tfS + ' momentum   ' + fmtSigned(sigChg, '#.##') + '%   vol ' + fmtVol(sigCv) + '   rel ' + (na(sigRv) ? '–' : fmtSigned(sigRv, '#') + '%') + '   candle ' + str.tostring(sigCndl) : tfS + ' momentum   none ' + ruleTxt + ' in last ' + str.tostring(i_pctLook) + (na(sigLast) ? '' : '   last ' + fmtSigned(sigLast, '#.##') + '%')
            // Without a momentum candle the row is tinted by the direction of the last closed candle.
            color  pctBg   = pctOk ? color.new(sigDir > 0 ? i_colBull : i_colBear, 0) : na(sigLast) ? cChipDim : color.new(sigLast >= 0 ? i_colBull : i_colBear, 70)
            color  pctTx   = pctOk ? color.white : cTextBright
            string pctTip  = (pctOk ? '' : 'No candle met all momentum rules in the last ' + str.tostring(i_pctLook) + ' candles.\nThe light colour shows the direction of the last closed candle.\n\n') + 'Rule: one ' + tfS + ' candle, open to close, ' + ruleTxt + '\nCandle vol ≥ ' + (i_minCVol == 0 ? 'off' : fmtVol(i_minCVol * 1e6)) + '    Rel vol ≥ ' + (i_minRVol == 0 ? 'off' : fmtSigned(i_minRVol, '#') + '%') + '\nSearched over the last ' + str.tostring(i_pctLook) + (i_closedTf ? ' closed' : '') + ' candles. Candle 1 is the newest.\n\nRel vol compares the candle volume with the average candle implied by the 24h total.\n0% is average, +100% is twice average. A dash means the 24h volume was not available.'
            wideRow(statRow, lastCol, pctTxt, pctTx, pctBg, pctTip)
            statRow := statRow + 1

        if i_btcOn
            string bTxt = 'BTC ' + tfLabel(i_btcTf) + ' x' + str.tostring(i_btcLook) + '   ' + (na(btcChg) ? '' : fmtSigned(btcChg, '#.##') + '%   ') + btcTxt
            color  bBg  = na(btcChg) ? cChipDim : btcState > 0 ? i_colBull : btcState < 0 ? i_colBear : color.new(#5d606b, 0)
            string bTip = i_btcSym + ' change over the last ' + str.tostring(i_btcLook) + ' x ' + tfLabel(i_btcTf) + ' candles, live.\nGreen above +' + str.tostring(i_btcBand, '#.##') + '%, dropping below -' + str.tostring(i_btcBand, '#.##') + '%, consolidating in between.\n\nMost coins follow Bitcoin.'
            wideRow(statRow, lastCol, bTxt, na(btcChg) ? cTextDim : color.white, bBg, bTip)


// ---------------------------------------------------------------------------------------------------------------------------------
// --- Alerts ----------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------
alertcondition(allTfBull and not allTfBull[1], 'All timeframes aligned bullish', 'Every selected timeframe has its averages stacked bullish on {{ticker}}')
alertcondition(allTfBear and not allTfBear[1], 'All timeframes aligned bearish', 'Every selected timeframe has its averages stacked bearish on {{ticker}}')
alertcondition(chartBull and not chartBull[1], 'Chart timeframe aligned bullish', 'The averages just stacked bullish on {{ticker}} {{interval}}')
alertcondition(chartBear and not chartBear[1], 'Chart timeframe aligned bearish', 'The averages just stacked bearish on {{ticker}} {{interval}}')
alertcondition(upAgo == 0 and upAgo[1] != 0, 'Momentum candle up',   'Momentum candle up on {{ticker}}: one candle moved at least the set % with enough volume')
alertcondition(dnAgo == 0 and dnAgo[1] != 0, 'Momentum candle down', 'Momentum candle down on {{ticker}}: one candle moved at least the set % with enough volume')
````
