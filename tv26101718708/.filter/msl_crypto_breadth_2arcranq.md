# MSL Crypto Breadth

- url: https://www.tradingview.com/script/2ARcraNQ-MSL-Crypto-Breadth/
- type: indicator
- pine_id: PUB;00caa04f7c8047e7b29cf66d428ce05e
- version: 1.0

## Description

WHAT IT DOES

Your chart shows one coin at a time. This indicator watches a basket of 20 coins at once and answers the question a single chart cannot: out of those 20, how many are actually taking part in the move you are looking at right now.

That answer changes what the same candle means. If Bitcoin gains five percent and 17 of the 20 coins gain with it, the whole market is moving and the move has something under it. If Bitcoin gains the same five percent while only 3 coins follow, one name is carrying everything and the rest of the market has already turned away. On a price chart those two days look identical. Here they do not, and that difference is the entire product.

Two lines do the work. The first is participation: how many coins of the basket are trading above their own moving average, drawn as a percentage from 0 to 100. Fifty means half the market is holding up, ten means almost nothing is. The second is pressure: on every bar it counts how many coins closed up against how many closed down and adds that difference up over time, so it reacts far sooner than the first line, often weeks sooner.

The indicator then watches Bitcoin and participation together. While they move the same way, nothing is drawn. When they split and go opposite ways, the stretch of time between them is shaded red or green and stays shaded until they come back together. Red means price is being pulled up while fewer and fewer coins follow it. Green means price is falling while more and more coins are quietly recovering underneath it.

One example from the daily chart of Bitcoin: the reference gained 2.5 percent across the comparison window while participation fell 15 points, which is two coins out of twenty losing their average. Both numbers are printed in the table on the chart, so every shaded stretch states its own reason instead of leaving you to guess it.

None of this tells you where to buy. It tells you whether the trade your own system just found deserves full size, half size, or nothing at all.

HOW TO USE IT

[list=1]
[*]Participation above 50 and rising
Means: the market is broad, most of the basket holds its average.
Do: take your signals at full size. The only state where adding makes sense.

[*]Participation between 30 and 50
Means: the move is carried by a few names.
Do: half size, closer targets.

[*]Participation below 30
Means: breakouts in the basket mostly fail.
Do: stand aside, or trade the reference symbol alone.

[*]Participation above 80
Means: everybody is already in, advances are crowded.
Do: not a place to open. Reduce and tighten the stop.

[*]A red band opens
Means: the reference is being carried while participation leaks away.
Do: stop adding, protect what is open. A warning, not an exit, and it can run for weeks.

[*]A green band opens while participation is below 20
Means: the reference is falling while more members repair underneath it.
Do: prepare, do not enter yet. This stage can last weeks.

[*]Participation then crosses 50 upward
Means: the repair is confirmed by the state, not only by pressure.
Do: the entry window of the reversal sequence. Late by design, verified by design.

[*]A band closes
Means: the pair moved the same way again, the disagreement is resolved.
Do: the warning is lifted.

[*]Participation crosses 50 downward
Means: most of the basket has lost its average.
Do: the last and bluntest exit reason.
[/list]

Five alerts cover this without watching the screen: participation crossing above and below half, the two divergence conditions, and the bar an open disagreement closes.

A WORKED EXAMPLE, THE DAY THIS WAS PUBLISHED

https://www.tradingview.com/x/WYRriv3I/

In the middle of May a green stretch opened on the daily chart of Bitcoin. The reference had lost 4.4 percent across the comparison window while participation rose 10 points against it, which is two coins out of twenty regaining their average while price was falling. Both numbers sit in the Event Gap row of the table.

Price then kept sliding into June and spent the next two months going sideways near its lows. The shading stayed on the entire time, because the two measurements never pointed the same way again. That is the length doing its job: this was not a three bar flicker, it was a repair that took a quarter to play out underneath a price chart that looked dead.

On the day of this publication the stretch ended. Bitcoin closed 4.7 percent higher and participation rose with it, so the pair agreed again, the band closed on that bar and the table switched to closed.

Now read the states above against this exact picture. Participation is 45 percent, nine coins of twenty above their average. That is the half size row, not the full size one. The reversal sequence has completed two of its three steps, the washed out low and the repair, and the third one, participation crossing 50 from below, has not happened yet.

That is the entire use of the tool in one screen. It does not say what the next bar does. It says the move that just printed a large green candle is still not broad, and it says so with a count anyone can check.

https://www.tradingview.com/x/AaHVjy5F/
A bearish disagreement on the daily chart of Bitcoin, October 2025. Price makes its high while the share of the basket above its own average falls away underneath it.

THE TWO LINES

Participation is a state. It moves only when a member crosses its average, which is a large event, so the line is slow and honest.

Pressure reacts on every bar and needs no threshold, so it turns while participation is still standing still. It counts members, not money: a coin up a tenth of a percent and a coin up twelve percent cast one vote each. There is no volume in it and no order flow. That is a limitation worth stating plainly, and it is also why one large member cannot distort it.

The gap between them is the point. Participation on the floor while pressure climbs is a market being bought before it looks bought. Participation high while pressure rolls over is a rally already finished. Neither statement can be made from one line.

THE DIVERGENCE

One window, two measurements, no pivots. The reference symbol, Bitcoin by default, must travel at least the configured percentage across the window while participation moves the other way by at least the configured number of points.

The event is measured on participation alone. The pressure line takes no part in it: hide it and not one band, glyph or alert changes. Participation sits on a fixed scale where ten points has a stated meaning, two members out of twenty changing sides, while pressure is normalised against its own recent range, where ten points would mean nothing statable. Thresholds that cannot be explained in plain language have no business triggering anything. Read together, a band with pressure agreeing is a warning confirmed twice, a band against it is the narrow kind that more often dissolves.

A disagreement is a stretch, not a moment. A vertical line marks the bar it opened and a band runs until the pair comes back together, which happens when both measurements point the same way again. The length is the part worth reading: one that closes after three bars was noise, one that holds for two months is the story of that market.

Agreement produces nothing at all. Both sides moving up together, or both down, is what a healthy market looks like, and it is exactly what closes an open band. A move too small to clear either threshold does nothing either, so an open band is never cancelled by noise.

Nothing is drawn against a candle and nothing sits at a price level. A shape placed on a bar is read as an entry whatever the description says, and this indicator produces no entries.

READING THE PANE

Horizontal is a level and is drawn in neutral grey: dotted lines at 80 and 20, dashed at the halfway mark, soft shading in the two extreme regions. Vertical is an event in time and owns the colour, so a coloured column always means the same thing.

HOW IT IS BUILT

Each member is requested on the selected timeframe with lookahead disabled, and its moving average is computed inside its own context, on its own data. Both readings a member contributes come back as one tuple, so the basket costs one request per symbol rather than two.

Three details decide whether a breadth reading is honest or decorative. A member that has not returned data contributes nothing: it leaves both sides of the division rather than being counted as a coin below its average, because counting silence as weakness is the usual way these readings drift toward zero for reasons unrelated to the market. No share is published at all until a minimum number of members have answered, since a percentage built on three coins is noise wearing the clothes of a statistic. And the cumulative count is detrended before it is drawn, because stretching a raw cumulative line between the extremes of a window pins it against one edge and flattens the recent swing into a thread.

THE SETTINGS

Core. Basket Timeframe, empty follows the chart and higher keeps a slow reading on a fast chart. MA Length, 200 for a long term reading and 50 for a swing one. MA Type across SMA, EMA, WMA and RMA. Coins Counted, how many of the twenty slots take part. Minimum Live Feeds, the smallest sample that may be published at all.

Basket. Twenty symbol slots. Any symbol your plan can open works and the basket does not have to be crypto, so the same engine measures a sector, an index or a watchlist.

Divergence. Reference Symbol, Comparison Window, Reference Move percent and Breadth Gap Points, the two thresholds that define an event.

Visuals. The second line and its swing window; how events are drawn, as line and band, band only, line only or glyph only; the arrow on the edge; on chart explanations and how many are kept; whether events show in the pane, on the chart or both; four colours.

Dashboard. Table on or off, its corner out of eight, and the text size.

THE TABLE, ROW BY ROW

Above MA. The share, with the regime named: broad, healthy, narrow or washed out. Reads warming up while the sample is too small.
Coins. How many members are above their average out of how many actually answered.
Advancing. Up against down on the last bar, the input to the cumulative line.
Cum A/D. The untouched cumulative count, since the plotted line is normalised and says nothing about level.
Reference. What the reference symbol did on the last bar.
Divergence. Direction of the last event, how many bars ago, and whether it is still open.
Event Gap. The two measurements that produced it, for example ref plus 2.5 percent against breadth minus 15 points.
Feeds. How many slots answered and on what timeframe. Turns red when a slot is silent.

https://www.tradingview.com/x/AlDr8y98/
The same engine on Ethereum, four hours. The basket does not change with the chart, so the reading is about the market rather than the instrument in front of you.

TIMEFRAMES AND LIMITS

H1 and above. On H1 the lines work but divergences almost never fire, because a genuine disagreement between a whole basket and Bitcoin inside a day is rare. Divergence is a 4h and daily tool.

Members are read through the chart, so their history begins where the chart history begins. A 200 length average needs 200 chart bars before the first reading exists; scroll left to load more or shorten the length.

TradingView allows 40 unique data requests per script and 127 tuple elements. This script spends 21 requests and 42 elements. All 20 slots are requested whatever the counted number is, because requests are fixed at compile time, so lowering it changes the statistic and not the load.

[b]WHAT IT IS NOT[/b]

Breadth describes the crowd, not the next bar. A thin market can stay thin for weeks while price grinds higher on two names, and a disagreement can run far longer than a position survives. Low participation is not a reason to short on its own.

Advance decline counting and participation measures are classic market internals from the stock market and belong to nobody. The implementation here is original: the per member context calculation, the exclusion rules, the minimum sample gate, the detrended cumulative and the paired open and close events are what the code actually is. Nothing was reused from another script.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab

// Crypto Breadth — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.

//@version=6
indicator('MSL Crypto Breadth', 'MSL Breadth', overlay=false, precision=1, max_lines_count=500, max_labels_count=500)

//====================================================================
// INPUTS
//====================================================================
groupCalc = 'Core'
groupBasket = 'Basket'
groupSignal = 'Divergence'
groupVisual = 'Visuals'
groupTable = 'Dashboard'

basketTf = input.timeframe(defval='', title='Basket Timeframe', group=groupCalc, tooltip='Timeframe every basket member is read on. Leave empty to follow the chart. Set it higher than the chart to keep a slow participation reading while you work on a fast chart. A timeframe below the chart is not useful here, because only the last inner bar of each chart bar would arrive.')
maLength = input.int(defval=200, title='MA Length', minval=2, maxval=1000, group=groupCalc, tooltip='Period of the moving average each coin is compared against, measured on the basket timeframe. 200 is the classic participation reading and answers whether a coin is in a long term uptrend. 50 reacts far sooner and turns the line into a swing tool. Coins with less history than this length return no value and are excluded rather than counted as weak.')
maMode = input.string(defval='SMA', title='MA Type', options=['SMA', 'EMA', 'WMA', 'RMA'], group=groupCalc, tooltip='Smoothing used for each coin average. SMA is the standard for breadth work and is what most published participation readings assume. EMA and WMA react faster and lift the line earlier off a bottom. RMA is the slowest of the four.')
basketSize = input.int(defval=20, title='Coins Counted', minval=1, maxval=20, group=groupCalc, tooltip='How many of the 20 slots below take part in the calculation, counted from the top. Lowering it changes the statistic but not the load: all 20 data feeds are requested at compile time whatever this value is, so leaving unused slots on a valid symbol costs nothing extra.')

minFeeds = input.int(defval=10, title='Minimum Live Feeds', minval=1, maxval=20, group=groupCalc, tooltip='How many basket members must return data before a reading is published at all. Members warm up at different speeds, so on the oldest bars of a chart two or three coins can answer while the rest are still silent, and a share built on three coins is noise pretending to be breadth. Below this threshold the line is left empty and the table says so. Raise it for a stricter sample, lower it if you deliberately run a small basket.')

symbol01 = input.symbol(defval='BINANCE:BTCUSDT', title='01', group=groupBasket, tooltip='Basket member. Any symbol your plan can open works, the basket does not have to be crypto. Keep every slot on a symbol that exists: a slot pointing at nothing is simply skipped and shrinks the sample. Replace this first slot if you want a pure altcoin participation reading with no BTC inside.')
symbol02 = input.symbol(defval='BINANCE:ETHUSDT', title='02', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol03 = input.symbol(defval='BINANCE:BNBUSDT', title='03', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol04 = input.symbol(defval='BINANCE:SOLUSDT', title='04', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol05 = input.symbol(defval='BINANCE:XRPUSDT', title='05', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol06 = input.symbol(defval='BINANCE:ADAUSDT', title='06', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol07 = input.symbol(defval='BINANCE:DOGEUSDT', title='07', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol08 = input.symbol(defval='BINANCE:AVAXUSDT', title='08', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol09 = input.symbol(defval='BINANCE:LINKUSDT', title='09', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol10 = input.symbol(defval='BINANCE:DOTUSDT', title='10', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol11 = input.symbol(defval='BINANCE:LTCUSDT', title='11', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol12 = input.symbol(defval='BINANCE:TRXUSDT', title='12', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol13 = input.symbol(defval='BINANCE:ATOMUSDT', title='13', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol14 = input.symbol(defval='BINANCE:UNIUSDT', title='14', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol15 = input.symbol(defval='BINANCE:XLMUSDT', title='15', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol16 = input.symbol(defval='BINANCE:ETCUSDT', title='16', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol17 = input.symbol(defval='BINANCE:NEARUSDT', title='17', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol18 = input.symbol(defval='BINANCE:FILUSDT', title='18', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol19 = input.symbol(defval='BINANCE:APTUSDT', title='19', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')
symbol20 = input.symbol(defval='BINANCE:ICPUSDT', title='20', group=groupBasket, tooltip='Basket member. Leave on a valid symbol or the slot is skipped.')

referenceSymbol = input.symbol(defval='BINANCE:BTCUSDT', title='Reference Symbol', group=groupSignal, tooltip='Instrument the breadth line is compared against. BTC is the usual choice because the rest of the market trades around it. Divergence is measured between this symbol and the participation line, so pointing it at a broad index instead turns the signal into an index versus components reading.')
divLength = input.int(defval=20, title='Comparison Window', minval=2, maxval=500, group=groupSignal, tooltip='How many bars back the comparison reaches. Both the move of the reference symbol and the change in breadth are measured across this window. Shorter reacts to every swing, longer only speaks about the larger move.')
refMinMove = input.float(defval=2.0, title='Reference Move %', minval=0.0, step=0.1, group=groupSignal, tooltip='How far the reference symbol must travel across the window before a divergence is considered at all. Raise it on volatile instruments so ordinary noise stops qualifying as a move.')
divMinGap = input.float(defval=10.0, title='Breadth Gap Points', minval=0.0, step=1.0, group=groupSignal, tooltip='How many percentage points the breadth line must move the opposite way across the same window. The line runs from 0 to 100, so 10 means one tenth of the whole range. Raise it to keep only the wide disagreements.')

showAdLine = input.bool(defval=true, title='Show Cumulative A/D', group=groupVisual, tooltip='Draws the cumulative advance decline line of the basket as a swing oscillator. The raw cumulative count lives on its own scale and would be a flat thread next to a 0 to 100 line, so what is drawn is its distance from its own average inside the window below, stretched across the pane. Direction and shape carry the meaning, the level does not. The untouched number is in the table.')
adWindow = input.int(defval=200, title='A/D Swing Window', minval=20, maxval=5000, group=groupVisual, active=showAdLine, tooltip='Number of bars used both for the average the cumulative line is measured against and for the stretch that follows. Shorter turns the plot into a fast swing reading that crosses the middle often. Longer keeps only the large accumulation and distribution phases. The plot needs this many bars before it appears.')
markerStyle = input.string(defval='Line and band', title='Event Marks', options=['Line and band', 'Band only', 'Line only', 'Glyph only'], group=groupVisual, tooltip='How a disagreement is drawn. The line is a vertical stroke on the bar it opened, running the full height of the pane and of the chart so it survives zooming out. The band tints every bar from that opening until the disagreement closes, so the width of the colour is the length of the warning rather than a single moment. Line and band uses both, which is the clearest at a glance. Glyph only leaves nothing but the small arrow on the edge.')

showPaneMarkers = input.bool(defval=true, title='Divergence Marks In Pane', group=groupVisual, tooltip='Prints the event glyph on the top edge of the indicator pane on the bar a disagreement opens. Both directions sit on the same edge: the colour of the line and of the band already says which way it went, so the height of the glyph carries no extra meaning and only invites reading it as a level.')
showLineTags = input.bool(defval=true, title='Name The Lines', group=groupVisual, tooltip='Prints a two row legend in the corner of the pane naming what each line is, coloured to match them. Switch it off once the pair is familiar.')
showEventLabels = input.bool(defval=true, title='Explain Events On Chart', group=groupVisual, tooltip='Writes the reason for each disagreement next to the bar that opened it, so the chart says what happened instead of leaving a coloured column to be decoded. The label carries the two measurements behind the event and hovering it opens the full sentence. Switch it off for a bare chart or for screenshots.')
labelKeep = input.int(defval=6, title='Labels Kept', minval=1, maxval=100, group=groupVisual, active=showEventLabels, tooltip='How many of the most recent explanations stay on the chart. Older ones are removed as new events arrive, which keeps a long history readable. Raise it to study past events, lower it to keep only what is current.')

markerGlyphs = input.bool(defval=true, title='Arrow On Edge', group=groupVisual, tooltip='Keeps the small glyph on the top edge next to the line. The two arrows in it are the two sides of the disagreement read left to right: the reference symbol first, participation second. Up then down is the reference climbing while participation leaks away, down then up is the reference falling while participation repairs. Switch it off if the lines and bands alone are enough.')

showChartMarkers = input.bool(defval=true, title='Divergence Marks On Chart', group=groupVisual, tooltip='Prints the same glyph on the top edge of the price chart, so an event is visible without looking down at the pane. It is pinned to the edge and never placed on a bar, because a mark sitting on a candle reads as an entry and this indicator has no entries. Switch it off to keep the price chart to the band alone.')
bullColor = input.color(defval=color.rgb(64, 217, 143), title='Broad', inline='breadthColors', group=groupVisual, tooltip='Colour used while participation is wide.')
bearColor = input.color(defval=color.rgb(246, 113, 113), title='Narrow', inline='breadthColors', group=groupVisual, tooltip='Colour used while participation is thin.')
adColor = input.color(defval=color.rgb(126, 160, 255), title='Cumulative A/D', group=groupVisual, tooltip='Colour of the rescaled cumulative advance decline line.')
textColor = input.color(defval=color.white, title='Table Text', group=groupVisual, tooltip='Colour of the text inside the table. Switch it to a dark colour when you work on a light chart theme.')

showTable = input.bool(defval=true, title='Show Table', group=groupTable, tooltip='Shows the readout on the price chart. The table is forced onto the chart pane so the indicator pane is left to the lines.')
tablePos = input.string(defval='Top Right', title='Position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=groupTable, active=showTable, tooltip='Corner of the chart the table is anchored to.')
textSize = input.string(defval='Small', title='Text Size', options=['Tiny', 'Small', 'Normal', 'Large'], group=groupTable, active=showTable, tooltip='Font size inside the table. Normal and Large are meant for screenshots.')

//====================================================================
// COLORS
//====================================================================
headerBg = color.new(color.rgb(20, 24, 34), 0)
leftColBg = color.new(color.rgb(38, 43, 56), 15)
rightNeutralBg = color.new(color.rgb(28, 32, 43), 10)
borderColor = color.new(color.rgb(90, 98, 118), 40)
mutedColor = color.new(color.rgb(150, 156, 170), 40)
zoneFill = color.new(color.rgb(150, 156, 170), 85)
bearMark = color.new(bearColor, 78)
bullMark = color.new(bullColor, 78)

//====================================================================
// HELPERS
//====================================================================
safeDiv(float num, float den, float fallback) =>
    (na(num) or na(den) or den == 0.0) ? fallback : (num / den)

maByMode(float priceSeries, simple int lengthValue, simple string modeValue) =>
    switch modeValue
        'SMA' => ta.sma(priceSeries, lengthValue)
        'EMA' => ta.ema(priceSeries, lengthValue)
        'WMA' => ta.wma(priceSeries, lengthValue)
        => ta.rma(priceSeries, lengthValue)

// One request per basket member. Both readings are produced inside the requested
// context and handed back as a single tuple, which keeps the cost at one unique
// request.security() call and two tuple elements per coin. Requesting the price
// and the average separately would double the call count for no gain.
// A member with too little history yields na and is skipped downstream, never
// silently counted as a coin below its average.
basketRead(simple string symbolName, simple string timeframeName, simple int lengthValue, simple string modeValue) =>
    averageValue = maByMode(close, lengthValue, modeValue)
    aboveFlag = na(close) or na(averageValue) ? na : (close > averageValue ? 1.0 : 0.0)
    moveFlag = na(close) or na(close[1]) ? na : (close > close[1] ? 1.0 : (close < close[1] ? -1.0 : 0.0))
    request.security(symbolName, timeframeName, [aboveFlag, moveFlag], lookahead=barmerge.lookahead_off)

// Pine hands back intraday timeframes as a plain minute count, so 240 arrives where
// a reader expects 4h. Anything that is not a number is already a readable code.
timeframeLabel(string tfString) =>
    minutesValue = str.tonumber(tfString)
    na(minutesValue) ? tfString : minutesValue >= 1440.0 ? str.tostring(minutesValue / 1440.0, '#.#') + 'D' : minutesValue >= 60.0 ? str.tostring(minutesValue / 60.0, '#.#') + 'h' : str.tostring(minutesValue, '#') + 'm'

tablePosition(string posName) =>
    switch posName
        'Top Left' => position.top_left
        'Top Center' => position.top_center
        'Top Right' => position.top_right
        'Middle Left' => position.middle_left
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        'Bottom Center' => position.bottom_center
        => position.bottom_right

tableTextSize(string sizeName) =>
    switch sizeName
        'Tiny' => size.tiny
        'Small' => size.small
        'Normal' => size.normal
        => size.large

//====================================================================
// CALCULATIONS
//====================================================================
basketPeriod = basketTf == '' ? timeframe.period : basketTf

[above01, move01] = basketRead(symbol01, basketPeriod, maLength, maMode)
[above02, move02] = basketRead(symbol02, basketPeriod, maLength, maMode)
[above03, move03] = basketRead(symbol03, basketPeriod, maLength, maMode)
[above04, move04] = basketRead(symbol04, basketPeriod, maLength, maMode)
[above05, move05] = basketRead(symbol05, basketPeriod, maLength, maMode)
[above06, move06] = basketRead(symbol06, basketPeriod, maLength, maMode)
[above07, move07] = basketRead(symbol07, basketPeriod, maLength, maMode)
[above08, move08] = basketRead(symbol08, basketPeriod, maLength, maMode)
[above09, move09] = basketRead(symbol09, basketPeriod, maLength, maMode)
[above10, move10] = basketRead(symbol10, basketPeriod, maLength, maMode)
[above11, move11] = basketRead(symbol11, basketPeriod, maLength, maMode)
[above12, move12] = basketRead(symbol12, basketPeriod, maLength, maMode)
[above13, move13] = basketRead(symbol13, basketPeriod, maLength, maMode)
[above14, move14] = basketRead(symbol14, basketPeriod, maLength, maMode)
[above15, move15] = basketRead(symbol15, basketPeriod, maLength, maMode)
[above16, move16] = basketRead(symbol16, basketPeriod, maLength, maMode)
[above17, move17] = basketRead(symbol17, basketPeriod, maLength, maMode)
[above18, move18] = basketRead(symbol18, basketPeriod, maLength, maMode)
[above19, move19] = basketRead(symbol19, basketPeriod, maLength, maMode)
[above20, move20] = basketRead(symbol20, basketPeriod, maLength, maMode)

aboveFlags = array.from(above01, above02, above03, above04, above05, above06, above07, above08, above09, above10, above11, above12, above13, above14, above15, above16, above17, above18, above19, above20)
moveFlags = array.from(move01, move02, move03, move04, move05, move06, move07, move08, move09, move10, move11, move12, move13, move14, move15, move16, move17, move18, move19, move20)

referenceChange = safeDiv(close - close[1], close[1], na) * 100.0
[refClose, refChangePct] = request.security(referenceSymbol, basketPeriod, [close, referenceChange], lookahead=barmerge.lookahead_off)

//====================================================================
// BREADTH ENGINE
//====================================================================
float aboveCount = 0.0
float liveCount = 0.0
float advancing = 0.0
float declining = 0.0

for i = 0 to basketSize - 1
    aboveValue = array.get(aboveFlags, i)
    moveValue = array.get(moveFlags, i)
    if not na(aboveValue)
        liveCount := liveCount + 1.0
        aboveCount := aboveCount + aboveValue
    if not na(moveValue)
        advancing := moveValue > 0.0 ? advancing + 1.0 : advancing
        declining := moveValue < 0.0 ? declining + 1.0 : declining

// A share is only published once enough members answered. Below the threshold the
// sample is too small to describe a market and the line is left empty instead.
feedsEnough = liveCount >= math.min(minFeeds, basketSize)
breadthPct = feedsEnough ? safeDiv(aboveCount * 100.0, liveCount, na) : na
netAdvances = advancing - declining

var float adLine = 0.0
adLine := adLine + netAdvances

// The cumulative count is detrended before it is drawn. A raw cumulative line
// spends most of its life far from the extremes of any long window, so stretching
// it directly between those extremes pins it against one edge of the pane and the
// recent swing, which is the part that carries information, disappears into a flat
// thread. Measuring it against its own average first removes that offset, and the
// stretch then works on the swing itself.
adBaseline = ta.sma(adLine, adWindow)
adDeviation = adLine - adBaseline
devHighest = ta.highest(adDeviation, adWindow)
devLowest = ta.lowest(adDeviation, adWindow)
adRescaled = safeDiv((adDeviation - devLowest) * 100.0, devHighest - devLowest, na)

//====================================================================
// SIGNAL ENGINE
//====================================================================
// A divergence here is a plain disagreement over one window: the reference symbol
// travelled far in one direction while participation moved the other way by at
// least the configured number of points. No pivots are used, so nothing is
// confirmed late and nothing is repainted after the fact.
// ta.roc and ta.change keep their own history buffer, so the window length can be
// an input without the script having to reserve a fixed lookback for every series.
refWindowMove = ta.roc(refClose, divLength)
breadthWindowMove = ta.change(breadthPct, divLength)

bearishRaw = not na(refWindowMove) and not na(breadthWindowMove) and refWindowMove >= refMinMove and breadthWindowMove <= -divMinGap
bullishRaw = not na(refWindowMove) and not na(breadthWindowMove) and refWindowMove <= -refMinMove and breadthWindowMove >= divMinGap

var int lastBearBar = na
var int lastBullBar = na

bearishReady = na(lastBearBar) or bar_index - lastBearBar >= divLength
bullishReady = na(lastBullBar) or bar_index - lastBullBar >= divLength

bearishDivergence = bearishRaw and not bearishRaw[1] and bearishReady
bullishDivergence = bullishRaw and not bullishRaw[1] and bullishReady

if bearishDivergence
    lastBearBar := bar_index
if bullishDivergence
    lastBullBar := bar_index

// The mirror of the divergence. Same window, same two thresholds, but both
// measurements now point the same way, so the reference symbol and participation
// agree again. It is only reported while a disagreement is actually open, because
// agreement is the normal state of a market and marking every bar of it would say
// nothing. The open flag is what turns a stream of conditions into two events:
// one when the pair comes apart, one when it comes back together.
agreementUp = not na(refWindowMove) and not na(breadthWindowMove) and refWindowMove >= refMinMove and breadthWindowMove >= divMinGap
agreementDown = not na(refWindowMove) and not na(breadthWindowMove) and refWindowMove <= -refMinMove and breadthWindowMove <= -divMinGap

var int openDisagreement = 0

convergence = openDisagreement != 0 and (agreementUp or agreementDown)

if convergence
    openDisagreement := 0

// Only the bar that opens a stretch is marked. Once a disagreement is open it can
// meet the same condition again a window later, and drawing every one of those put
// two or three identical arrows inside a single band for no added meaning: the band
// already carries the duration. A divergence in the opposite direction still marks,
// because that is a different stretch and the colour changes with it.
bearishOpening = bearishDivergence and openDisagreement != -1
bullishOpening = bullishDivergence and openDisagreement != 1

if bearishDivergence
    openDisagreement := -1
if bullishDivergence
    openDisagreement := 1

crossedUpMid = ta.crossover(breadthPct, 50.0)
crossedDownMid = ta.crossunder(breadthPct, 50.0)

//====================================================================
// SIGNAL STATS
//====================================================================
var int lastSignalBar = na
var int lastSignalDir = 0
var float lastRefMove = na
var float lastBreadthMove = na

// The two measurements behind the event are kept, not just the fact of it. The event
// lives in the relation between the price pane and this one, so printing the pair is
// what saves the reader from eyeballing two panes and a window at once.
if bearishOpening
    lastSignalBar := bar_index
    lastSignalDir := -1
    lastRefMove := refWindowMove
    lastBreadthMove := breadthWindowMove
if bullishOpening
    lastSignalBar := bar_index
    lastSignalDir := 1
    lastRefMove := refWindowMove
    lastBreadthMove := breadthWindowMove

//====================================================================
// VISUAL STATE
//====================================================================
breadthColor = na(breadthPct) ? mutedColor : color.from_gradient(breadthPct, 20.0, 80.0, bearColor, bullColor)
breadthState = na(breadthPct) ? (feedsEnough ? 'no data' : 'warming up') : breadthPct >= 80.0 ? 'broad' : breadthPct >= 50.0 ? 'healthy' : breadthPct >= 20.0 ? 'narrow' : 'washed out'

//====================================================================
// PLOTS
//====================================================================
plot(breadthPct, title='Breadth %', color=breadthColor, linewidth=2)
plot(showAdLine ? adRescaled : na, title='Cumulative A/D (swing)', color=adColor, linewidth=1)

// Horizontal is a level and is drawn in neutral grey, vertical is an event in time
// and owns the colour, so a shaded area is never ambiguous. Only the two extremes are
// shaded: above 80 the basket moves together and advances are crowded, below 20 almost
// nothing holds its average. The stretch between is ordinary and needs no paint.
ceilingBand = hline(100.0, title='Ceiling', color=color.new(color.white, 100), linestyle=hline.style_solid, display=display.none)
upperBand = hline(80.0, title='Crowded Above', color=borderColor, linestyle=hline.style_dotted)
hline(50.0, title='Half', color=borderColor, linestyle=hline.style_dashed)
lowerBand = hline(20.0, title='Washed Out Below', color=borderColor, linestyle=hline.style_dotted)
floorBand = hline(0.0, title='Floor', color=color.new(color.white, 100), linestyle=hline.style_solid, display=display.none)
fill(ceilingBand, upperBand, color=zoneFill, title='Crowded Zone')
fill(lowerBand, floorBand, color=zoneFill, title='Washed Out Zone')

// Rare events deserve a mark that survives zooming out. TradingView shrinks and
// eventually hides small shapes once bars get dense, which is exactly when a year of
// history is on screen and the event matters most. A line drawn with extend on both
// sides stays a full height stroke at any scale. It also marks a moment in time and
// never a level, which is the honest shape for an event that says nothing about price.
// The two ends of each line are values already inside the scale it lives in, the
// full height of the pane and the low and high of its own bar on the chart, because
// a drawing counts toward the automatic scaling of the pane it sits in. Anchoring an
// end at zero drags the price axis down to zero and flattens the candles into a
// strip, and giving both ends the same value leaves no direction to extend along, so
// the stroke comes out horizontal instead of vertical.
useEventLine = markerStyle == 'Line and band' or markerStyle == 'Line only'
useEventBand = markerStyle == 'Line and band' or markerStyle == 'Band only'

if useEventLine and showPaneMarkers and bearishOpening
    line.new(bar_index, 0.0, bar_index, 100.0, xloc=xloc.bar_index, extend=extend.both, color=bearColor, width=2)
if useEventLine and showPaneMarkers and bullishOpening
    line.new(bar_index, 0.0, bar_index, 100.0, xloc=xloc.bar_index, extend=extend.both, color=bullColor, width=2)
if useEventLine and showChartMarkers and bearishOpening
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=bearColor, width=2, force_overlay=true)
if useEventLine and showChartMarkers and bullishOpening
    line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=bullColor, width=2, force_overlay=true)

// The band is painted while the disagreement is open, not on the single bar it was
// detected. Its left edge is the bar the pair came apart and its right edge is the
// bar they came back together, so the width of the colour is the length of the
// warning. A one bar mark cannot say that, and the length is the part a reader needs:
// a disagreement that closed after three bars was noise, one that held for two months
// was the story of that market.
bandColor = openDisagreement < 0 ? bearMark : openDisagreement > 0 ? bullMark : na
// The explanation is written where the event is. The label names which side did what
// and by how much; the full sentence sits in the tooltip so the chart stays readable.
var label[] eventLabels = array.new<label>()

drawEventLabel(bool isBearish) =>
    headline = isBearish ? 'reference up, participation down' : 'reference down, participation up'
    numbers = (refWindowMove >= 0.0 ? '+' : '') + str.tostring(refWindowMove, '#.#') + '% vs ' + (breadthWindowMove >= 0.0 ? '+' : '') + str.tostring(breadthWindowMove, '#') + ' pts'
    detail = isBearish ? 'The reference symbol gained ' + str.tostring(refWindowMove, '#.#') + '% across the comparison window while the share of the basket above its own average fell by ' + str.tostring(math.abs(breadthWindowMove), '#') + ' points. The move has narrowed into fewer names. The band stays open until both measurements point the same way again.' : 'The reference symbol lost ' + str.tostring(math.abs(refWindowMove), '#.#') + '% across the comparison window while the share of the basket above its own average rose by ' + str.tostring(breadthWindowMove, '#') + ' points. More members are repairing than the price of the reference suggests. The band stays open until both measurements point the same way again.'
    newLabel = label.new(bar_index, 100.0, text=headline + '\n' + numbers, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=isBearish ? color.new(bearColor, 80) : color.new(bullColor, 80), textcolor=isBearish ? bearColor : bullColor, size=size.small, textalign=text.align_left, tooltip=detail)
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > labelKeep
        label.delete(array.shift(eventLabels))

if showEventLabels and showPaneMarkers and bearishOpening
    drawEventLabel(true)
if showEventLabels and showPaneMarkers and bullishOpening
    drawEventLabel(false)

bgcolor(useEventBand and showPaneMarkers ? bandColor : na, title='Open Disagreement Band')
bgcolor(useEventBand and showChartMarkers ? bandColor : na, title='Open Disagreement Band Chart', force_overlay=true)

plotchar(markerGlyphs and showPaneMarkers and bearishOpening, title='Bearish Divergence Pane', char='⇅', location=location.top, color=bearColor, size=size.small, display=display.pane + display.data_window)
plotchar(markerGlyphs and showPaneMarkers and bullishOpening, title='Bullish Divergence Pane', char='⇵', location=location.top, color=bullColor, size=size.small, display=display.pane + display.data_window)
plotchar(markerGlyphs and showChartMarkers and bearishOpening, title='Bearish Divergence Chart', char='⇅', location=location.top, color=bearColor, size=size.small, force_overlay=true, display=display.pane + display.data_window)
plotchar(markerGlyphs and showChartMarkers and bullishOpening, title='Bullish Divergence Chart', char='⇵', location=location.top, color=bullColor, size=size.small, force_overlay=true, display=display.pane + display.data_window)
// A pane with two unrelated series in it has to say which is which, and a status line
// that only appears on hover does not count. A two row legend sits in the bottom right
// of the pane, each row carrying the live colour of the line it names, so the label and
// the line can never drift apart. Bottom left is taken by the TradingView logo and a tag
// riding the right end of each line is clipped on layouts without a right margin, which
// leaves this corner as the only one that survives every window size.
var table lineLegend = table.new(position.bottom_right, 1, 2, bgcolor=color.new(color.black, 100), border_width=0)

if showLineTags and barstate.islast
    table.cell(lineLegend, 0, 0, 'Participation: coins above their average', text_color=breadthColor, text_size=size.tiny, bgcolor=color.new(color.black, 100))
    table.cell(lineLegend, 0, 1, showAdLine ? 'Pressure: advances minus declines' : '', text_color=adColor, text_size=size.tiny, bgcolor=color.new(color.black, 100))

//====================================================================
// ALERTS
//====================================================================
alertcondition(bearishDivergence, 'Crypto Breadth - Bearish Divergence', 'MarketStructureLab Crypto Breadth: the reference symbol advanced while basket participation fell.')
alertcondition(bullishDivergence, 'Crypto Breadth - Bullish Divergence', 'MarketStructureLab Crypto Breadth: the reference symbol declined while basket participation rose.')
alertcondition(convergence, 'Crypto Breadth - Disagreement Closed', 'MarketStructureLab Crypto Breadth: the reference symbol and basket participation are moving the same way again, the open disagreement is closed.')
alertcondition(crossedUpMid, 'Crypto Breadth - Above Half', 'MarketStructureLab Crypto Breadth: more than half of the basket is now above its moving average.')
alertcondition(crossedDownMid, 'Crypto Breadth - Below Half', 'MarketStructureLab Crypto Breadth: fewer than half of the basket are now above their moving average.')

//====================================================================
// TABLE
//====================================================================
var table breadthTable = table.new(tablePosition(tablePos), 2, 9, bgcolor=headerBg, border_color=borderColor, border_width=1, frame_color=borderColor, frame_width=1, force_overlay=true)

if showTable and barstate.islast
    cellSize = tableTextSize(textSize)
    feedsMissing = basketSize - int(liveCount)
    signalAge = na(lastSignalBar) ? na : bar_index - lastSignalBar
    signalState = openDisagreement != 0 ? ', open' : ', closed'
    signalText = na(lastSignalBar) ? 'none yet' : (lastSignalDir > 0 ? 'bullish, ' : 'bearish, ') + str.tostring(signalAge) + ' bars ago' + signalState
    signalColor = na(lastSignalBar) ? mutedColor : lastSignalDir > 0 ? bullColor : bearColor
    feedsColor = feedsMissing > 0 ? bearColor : mutedColor

    table.cell(breadthTable, 0, 0, 'Crypto', text_color=textColor, text_size=cellSize, bgcolor=headerBg)
    table.cell(breadthTable, 1, 0, 'Breadth', text_color=textColor, text_size=cellSize, bgcolor=headerBg)

    table.cell(breadthTable, 0, 1, 'Above MA', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 1, na(breadthPct) ? breadthState : str.tostring(breadthPct, '#.#') + '%, ' + breadthState, text_color=color.white, text_size=cellSize, bgcolor=color.new(breadthColor, 60))

    table.cell(breadthTable, 0, 2, 'Coins', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 2, str.tostring(int(aboveCount)) + ' of ' + str.tostring(int(liveCount)), text_color=textColor, text_size=cellSize, bgcolor=rightNeutralBg)

    table.cell(breadthTable, 0, 3, 'Advancing', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 3, str.tostring(int(advancing)) + ' up, ' + str.tostring(int(declining)) + ' down', text_color=netAdvances >= 0.0 ? bullColor : bearColor, text_size=cellSize, bgcolor=rightNeutralBg)

    table.cell(breadthTable, 0, 4, 'Cum A/D', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 4, str.tostring(adLine, '#'), text_color=adLine >= 0.0 ? bullColor : bearColor, text_size=cellSize, bgcolor=rightNeutralBg)

    table.cell(breadthTable, 0, 5, 'Reference', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 5, na(refChangePct) ? 'no data' : str.tostring(refChangePct, '#.##') + '% last bar', text_color=na(refChangePct) ? mutedColor : refChangePct >= 0.0 ? bullColor : bearColor, text_size=cellSize, bgcolor=rightNeutralBg)

    table.cell(breadthTable, 0, 6, 'Divergence', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 6, signalText, text_color=signalColor, text_size=cellSize, bgcolor=rightNeutralBg)

    gapText = na(lastRefMove) or na(lastBreadthMove) ? 'no event yet' : (lastRefMove >= 0.0 ? 'ref +' : 'ref ') + str.tostring(lastRefMove, '#.#') + '%, breadth ' + (lastBreadthMove >= 0.0 ? '+' : '') + str.tostring(lastBreadthMove, '#') + ' pts'
    table.cell(breadthTable, 0, 7, 'Event Gap', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 7, gapText, text_color=na(lastRefMove) ? mutedColor : textColor, text_size=size.tiny, bgcolor=rightNeutralBg)

    table.cell(breadthTable, 0, 8, 'Feeds', text_color=textColor, text_size=cellSize, bgcolor=leftColBg)
    table.cell(breadthTable, 1, 8, str.tostring(int(liveCount)) + ' of ' + str.tostring(basketSize) + ' live, ' + timeframeLabel(basketPeriod), text_color=feedsColor, text_size=size.tiny, bgcolor=rightNeutralBg)

//====================================================================
// USAGE GUIDE
//====================================================================
// WHAT IT DOES
// Reads a basket of up to 20 symbols and answers one question on every bar: how
// much of the market is actually taking part. The main line is the share of the
// basket trading above its own moving average, from 0 to 100. The second line is
// the cumulative advance decline count of the same basket. A divergence between
// the basket and a reference symbol, BTC by default, is marked and can be alerted.
//
// HOW THE LINES ARE BUILT
// 1. Each basket member is requested on the basket timeframe with lookahead off,
//    and its own moving average is computed on its own data, not on the chart.
// 2. Members above their average are counted, and the count is divided by the
//    number of members that actually returned data. A coin younger than the MA
//    length returns nothing and is dropped from both sides of that division
//    instead of being counted as weak. If fewer members answered than Minimum
//    Live Feeds, no share is published at all: three coins cannot describe a
//    market, and an honest gap is better than a confident wrong number.
// 3. Advancing minus declining members is accumulated bar by bar into the
//    cumulative advance decline line.
//
// WHERE THE LINE STARTS
// Basket members are read through the chart, so their history begins where the
// chart history begins and not where the coin was listed. A 200 length average
// therefore needs 200 chart bars before the first reading exists, and the pane is
// empty until then whatever the age of the coins. The swing plot needs its own
// window on top of that. If the line starts late, scroll the chart left to force
// more bars to load, or shorten the lengths.
//
// WHY THE CUMULATIVE LINE IS DRAWN AS A SWING
// Breadth lives between 0 and 100 and the cumulative count does not, so drawing
// them on one scale would flatten one of them. Stretching the raw cumulative line
// between its own extremes does not solve it either: a cumulative count sits far
// from those extremes most of the time and ends up pinned against one edge of the
// pane, with the recent swing squashed into a flat thread. So the line is measured
// against its own average over the swing window first, and that distance is what
// gets stretched across the pane. Above the middle the basket is accumulating
// advances faster than its own recent norm, below it the opposite. Its shape and
// its direction are the information, its height is not. The untouched cumulative
// number is in the table, and the table is the place to read its real level.
//
// WHAT THE SECOND LINE IS, AND IS NOT
// The cumulative line counts members, not money. A coin up a tenth of a percent and a
// coin up twelve percent cast one vote each. There is no volume in it and no order
// flow. It takes no part in the divergence either: hide it and not one band, glyph or
// alert changes. Participation carries a fixed scale where ten points means two
// members out of twenty changing sides, while this line is normalised against its own
// recent range, so the same ten points would mean nothing statable. It is a second
// opinion on an event, never the trigger of one. A band with the cumulative line
// moving the same way is a warning confirmed twice; a band against it is the narrow
// kind that more often dissolves.
//
//
// READING PARTICIPATION
// Above 80 the whole basket is moving together, which is strength and also the
// place where advances get crowded. Between 50 and 80 the market is healthy and
// broad. Between 20 and 50 the move is being carried by a few names. Below 20
// almost nothing is holding its average, which is where washed out lows form.
// The level matters less than the direction: participation falling while price
// holds is the classic warning, and participation rising off a low while price is
// still flat is the classic repair.
//
// THE DIVERGENCE
// One window, two measurements. The reference symbol must have travelled at least
// the Reference Move percent across the window, and breadth must have moved the
// other way by at least the Breadth Gap in points. A bearish mark means the
// reference climbed while fewer and fewer coins followed. A bullish mark means the
// reference fell while more coins were already repairing. Nothing here uses pivots,
// so a mark appears on the bar it is true and is never moved afterwards. After a
// mark the same direction stays quiet for one window length so a single
// disagreement is reported once rather than on every bar it lasts.
//
// A DISAGREEMENT HAS A LENGTH
// The glyph on the edge holds both sides of the disagreement, read left to right: the
// reference symbol first, participation second. Up then down is the reference climbing
// while participation leaks away. Down then up is the reference falling while
// participation repairs underneath it. The two are mirror images of each other, so the
// direction is readable without relying on the colour alone.
//
// The mark is not a moment, it is a stretch. A vertical line is drawn on the bar the
// pair came apart, and from there a coloured band runs until they come back together,
// which happens when both measurements point the same way again by the same two
// thresholds. Red means the reference is being carried while participation leaks away,
// green means participation is repairing under a falling reference, and the band ends
// the moment that stops being true.
//
// The length is the part worth reading. A disagreement that closes after three bars
// was noise. One that holds for two months is the story of that market. A single mark
// on a single bar cannot tell those apart, which is why the band exists at all. The
// table names the last event and says whether the warning is still open.
//
// Nothing is drawn against a candle and nothing sits at a price level. That is
// deliberate: this indicator produces no entries, and a mark placed on a bar is read
// as one whatever the description says. The band is a statement about the crowd over
// that stretch of time, nothing more.
//
// COST AND LIMITS
// TradingView allows 40 unique data requests per script, 64 on the Ultimate plan,
// and 127 tuple elements across all of them. This script spends 21 requests and 42
// elements: one per basket slot plus one for the reference symbol. All 20 slots are
// requested whatever Coins Counted is set to, because the requests are fixed when
// the script compiles, so lowering that number changes the statistic and not the
// load. The Feeds row shows how many slots answered, and it turns red when a slot
// is silent because the symbol does not exist on your plan or has no history yet.
//
// TIMEFRAMES
// H1 and above. Below H1 most basket members change their advance decline state on
// noise and the cumulative line stops describing anything. The 200 length default
// is a long term participation reading; drop it to 50 if you want the line to
// follow swings instead.
//
// WHAT THIS IS NOT
// Breadth describes the crowd, not the next bar. A thin market can stay thin for
// weeks while price grinds higher on two names, and a divergence can run far longer
// than a position can survive. Use it to size confidence in a move you already have
// a reason to take, not as an entry on its own.
````
