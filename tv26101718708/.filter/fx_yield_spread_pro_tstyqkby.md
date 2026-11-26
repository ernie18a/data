# FX Yield Spread Pro

- url: https://www.tradingview.com/script/TstyqKby-FX-Yield-Spread-Pro/
- type: indicator
- pine_id: PUB;93a142ca5ca44e7782bf6ac923c824f0
- version: 1.0

## Description

FX Yield Spread Pro allows traders to clearly see the relationship between government bond yield spreads and FX rates. For whichever currency pair is on the chart, it finds the two countries' government bond yields and draws their spread (base-currency yield minus quote-currency yield) over the price, on its own scale, with a trend line showing whether the spread is rising or falling. The spread is dated exactly, bar for bar. Two further readings can be switched on: colouring the spread by which country's yield is doing the moving, and an implied price drawn among the candles that shows where the spread says the pair should be.

[b]WHAT IT SHOWS[/b]
1. The yield spread, over the price chart on a separate left-hand scale. EURUSD shows EU10Y minus US10Y, USDJPY shows US10Y minus JP10Y, GBPCAD shows GB10Y minus CA10Y, and so on. The pair is detected from the chart symbol, so nothing needs changing when you move to another pair. Maturities of 2, 5, 10, 20 and 30 years are available.
[image]https://www.tradingview.com/x/Btf7zQiA/[/image]

2. The spread's trend. A fast and a slow average of the spread (exponential, 5 and 10 bars by default) are shown as a single line: green while the fast average is above the slow one, red while it is below. The spread line itself can be coloured by the trend instead, or switched off to leave the trend line on its own.
[image]https://www.tradingview.com/x/u1QASpk7/[/image]

3. Which yield is driving (optional). The spread line can take one colour while the base currency's yield has moved more over a lookback and another while the quote currency's yield has moved more. A fall in the spread drawn in the quote colour, for example, is the quote country's yields rising rather than the base country's falling.
[image]https://www.tradingview.com/x/j37MvTKr/[/image]

4. Implied price (optional). A line among the candles showing the price the pair would have if it sat exactly on its recent relationship with the spread, so the gap between price and the yield spread can be read on the price axis.
[image]https://www.tradingview.com/x/ZuFbs0pY/[/image]

5. A caption (optional): the spread in use and its current value; how far each of the two yields has moved over the lookback, in basis points, with the larger move highlighted; the implied price, when that is switched on, with the distance of price from it (in pips on forex symbols); and the spread's trend. Hovering over the caption gives the detail.
[image]https://www.tradingview.com/x/Qbvp9lde/[/image]

[b]HOW IT WORKS[/b]
Pair detection: the chart's base and quote currencies are mapped to TradingView's government bond yield symbols (TVC:US10Y, TVC:EU10Y, TVC:GB10Y, TVC:JP10Y and so on) at the selected maturity. The plotted spread is requested as a single spread symbol, so it matches what you get by adding, for example, TVC:EU10Y-TVC:US10Y to a chart by hand.

Dating of values: yield markets do not all close at the same time as the chart symbol. US yields close 30 minutes after the forex daily bar, and a script only receives another symbol's daily bar once that bar has closed. If the two yields are simply requested and subtracted, every past bar of a US dollar pair therefore pairs one country's close for that day with the US close from the day before. This script avoids that. On daily, weekly and monthly charts it requests each value together with the trading day it belongs to and places it on the chart bar with the same date, so each bar is same-day minus same-day. You can check this by adding the spread symbol itself (for example TVC:US10Y-TVC:CA10Y on USDCAD) to the chart: the indicator's line sits on it.

Spread trend: two moving averages of the spread, exponential by default. The trend is rising while the fast one is above the slow one, and the line drawn is the slow average.

Driver colouring: the two yields are also requested individually. For each bar the script compares the absolute change in the base yield with the absolute change in the quote yield over the lookback, and colours the line according to the larger.

Implied price: a rolling least-squares regression of the pair's closing price on the spread, over the last N completed bars (60 by default, about three months of daily bars). The implied price for a bar is the regression's intercept plus its slope times that bar's spread. The regression for a bar is estimated on earlier bars only, so a bar never contributes to its own fit. The fit is measured by the correlation between price and the spread over the window. When it is below a threshold you choose (0.5 by default), the line is drawn faded and the caption marks the fit as weak. A negative correlation means the pair has been moving against the spread, so the implied price is never treated as a fit then, however strong the correlation: the line stays faded, and the caption marks it as inverse once the correlation is at least as strong as the threshold. The caption's tooltip gives the correlation itself.

[b]HOW TO USE IT[/b]
Start on a daily or weekly chart of a major pair. Read the spread line as you would any yield-spread overlay, and use the trend line to see whether the yield spread is currently moving for or against the pair. Switch on driver colouring to see which country is behind each move. Switch on the implied price to compare where the pair is with where the spread says it should be: when the fit is good and price is far from the line, either the pair has run ahead of the yield spread or something other than yields is driving it. When the line is faded, the recent relationship is too loose, or inverted, to read anything from it. Alert conditions are provided for the spread trend turning up or down.

[b]SETTINGS[/b]
Yields: maturity, and the EUR yield source (euro-area benchmark or German Bund). Spread line: on or off; one colour, coloured by driving yield, or coloured by spread trend, with the driver lookback and colours. Spread trend: trend line on or off, average type, fast and slow lengths, and colours. Implied price: on or off, fit window, the correlation below which the fit is treated as weak, how many bars to draw, and colour. Caption: on or off, its position, and whether to show a short note on charts where there is nothing to draw.

[b]WHAT IS ORIGINAL[/b]
Other yield-spread scripts plot the spread on its own scale, sometimes with averages, or compare spread and price as normalised oscillators. This script does three things differently. The spread is date-exact: on every pair, including US dollar pairs where the US yield's later close would otherwise put one leg a bar behind the other, each bar matches TradingView's own spread symbol. It attributes each move in the spread to one of its two legs and can show that directly in the colour of the line. And it can express the spread in the pair's own price units, with a measure of fit, so the divergence can be read on the price axis in pips. All of this is computed for the chart's pair automatically.

[b]LIMITATIONS AND IMPORTANT NOTES[/b]
Plots offset into the past: the plots whose names end in "(confirmed close)" are offset one bar to the left. This is deliberate. A yield's daily bar can close after the chart's bar of the same date, in which case its value only becomes available on the following chart bar, and the offset puts it back on the bar of the date it belongs to. The colours of each point are likewise decided once the closes for that date are known. On daily, weekly and monthly charts these confirmed plots are the lines you see, joined to the live value on the current bar. Only the script's name is shown in the status line; the plotted values are in the Data Window. No lookahead is used anywhere in the script.

Implied price line: the implied price is drawn with a line object rather than a plot, because it is in price units and the spread is not. It covers the most recent bars only (500 by default), does not appear in the Data Window, and is redrawn as the current bar updates. The current implied price is shown in the caption when the caption is switched on.

Live values: on the current bar the spread, its colour, the trend, the implied price and the caption update as yields move, and are final only once the bar's official yield closes have arrived. The trend alerts use confirmed closes, so they fire one bar after the change. While the market is closed, a yield whose official close has not yet arrived for the last bar is represented by its last hourly reading inside that bar until the official value replaces it.

The implied price is descriptive, not a forecast, and price being far from it is not a reversal signal. It is a regression on a rolling window of two trending series. The relationship between yield spreads and exchange rates strengthens, weakens and sometimes reverses, which is why the fit is reported and should be read first. The spread trend likewise describes the direction of the yield spread; it does not predict price.

A yield spread is not an interest rate differential, and this script does not measure one. An interest rate differential compares two currencies' short-term interest rates, which follow central-bank policy rates. A yield spread compares what the market pays on two governments' bonds of the same maturity, so it also reflects where policy rates are expected to go, inflation expectations and the extra return investors ask for holding longer bonds. The two can move quite differently.

Date matching applies to daily, weekly and monthly charts. On intraday charts values are used as they arrive. Yield data is not available for every currency at every maturity; where it is missing, or on symbols that are not currency pairs, the script shows a short note and nothing else. This script is an analytical and educational tool and does not give trading advice.

## Source Code

````pine
//@version=6
indicator("FX Yield Spread Pro", overlay = true, scale = scale.left, format = format.percent, precision = 3, explicit_plot_zorder = true)

// On a currency pair's chart this script draws the government bond yield spread (base-currency yield minus
// quote-currency yield) over the price, on its own scale, and adds three readings to it:
//   1. The spread's trend: a fast and a slow average of the spread, shown as one line that is green while
//      the fast average is above the slow one and red while it is below.
//   2. Which country is driving (optional): the spread line can be coloured by which yield has moved more
//      over a short lookback.
//   3. The price the spread implies (optional), from a rolling regression of price on the spread, drawn
//      among the candles so the gap between price and the spread can be read on the price axis.
// The pair is re-read whenever the chart symbol changes.

// Inputs are kept out of the status line (display.none), so only the script's name shows beside the chart.
string GRP_YIELDS    = "Yields"
string maturityInput = input.string("10Y", "Maturity", options = ["02Y", "05Y", "10Y", "20Y", "30Y"], group = GRP_YIELDS, display = display.none)
string eurInput      = input.string("EU", "EUR yield", options = ["EU", "DE"], tooltip = "EU = euro-area benchmark (TVC:EU10Y)\nDE = German Bund (TVC:DE10Y)", group = GRP_YIELDS, display = display.none)

string GRP_LINE         = "Spread line"
bool   showSpreadInput  = input.bool(true, "Show spread line", group = GRP_LINE)
string colourByInput    = input.string("One colour", "Colour by", options = ["One colour", "Driving yield", "Spread trend"], group = GRP_LINE, display = display.none)
color  spreadColorInput = input.color(color.new(color.orange, 75), "One colour", group = GRP_LINE)
int    lookbackInput    = input.int(5, "Driving yield: lookback (bars)", minval = 1, maxval = 250, group = GRP_LINE, display = display.none)
color  baseColorInput   = input.color(#1e88e5, "Driving yield: base currency", group = GRP_LINE)
color  quoteColorInput  = input.color(#fb8c00, "Driving yield: quote currency", group = GRP_LINE)

string GRP_TREND      = "Spread trend"
bool   showTrendInput = input.bool(true, "Show trend line", group = GRP_TREND)
string trendTypeInput = input.string("Exponential", "Average type", options = ["Exponential", "Simple"], group = GRP_TREND, display = display.none)
int    fastInput      = input.int(5, "Fast average (bars)", minval = 2, maxval = 100, group = GRP_TREND, display = display.none)
int    slowInput      = input.int(10, "Slow average (bars)", minval = 3, maxval = 300, group = GRP_TREND, display = display.none)
color  risingInput    = input.color(#26a69a, "Spread rising", group = GRP_TREND)
color  fallingInput   = input.color(#ef5350, "Spread falling", group = GRP_TREND)

string GRP_FIT       = "Implied price"
bool   showFitInput  = input.bool(false, "Draw the implied price on the price axis", group = GRP_FIT)
int    windowInput   = input.int(60, "Fit window (bars)", minval = 10, maxval = 500, group = GRP_FIT, display = display.none)
float  weakInput     = input.float(0.5, "Treat the fit as weak below (correlation)", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "The correlation between price and the spread over the fit window, from 0 (no relationship) to 1 (perfect). Below this level the implied price is drawn faded and the caption marks the fit as weak. A negative correlation means the pair has been moving against the spread: the line stays faded, and the caption marks it as inverse once the correlation is at least this strong.", group = GRP_FIT, display = display.none)
int    drawInput     = input.int(500, "Bars to draw", minval = 50, maxval = 5000, group = GRP_FIT, display = display.none)
color  fitColorInput = input.color(#8e24aa, "Colour", group = GRP_FIT)

string GRP_CAPTION      = "Caption"
bool   showCaptionInput = input.bool(false, "Show caption", group = GRP_CAPTION)
bool   showNoteInput    = input.bool(true, "Show a note when there is nothing to draw", group = GRP_CAPTION)
string captionPosInput  = input.string("Top right", "Position", options = ["Top right", "Top center", "Bottom right", "Bottom left"], group = GRP_CAPTION, display = display.none)

// Currency code -> country prefix of the TVC yield symbol, e.g. "USD" -> "US" -> TVC:US10Y.
yieldPrefix(string ccy) =>
    switch ccy
        "USD" => "US"
        "EUR" => eurInput
        "GBP" => "GB"
        "JPY" => "JP"
        "AUD" => "AU"
        "NZD" => "NZ"
        "CAD" => "CA"
        "CHF" => "CH"
        "SEK" => "SE"
        "NOK" => "NO"
        "DKK" => "DK"
        "PLN" => "PL"
        "HUF" => "HU"
        "CZK" => "CZ"
        "TRY" => "TR"
        "ZAR" => "ZA"
        "MXN" => "MX"
        "SGD" => "SG"
        "HKD" => "HK"
        "CNH" => "CN"
        "CNY" => "CN"
        => ""

string basePrefix  = yieldPrefix(syminfo.basecurrency)
string quotePrefix = yieldPrefix(syminfo.currency)
bool   isMapped    = basePrefix != "" and quotePrefix != ""
string baseName    = basePrefix + maturityInput
string quoteName   = quotePrefix + maturityInput
// Charts that are not a mapped currency pair request their own symbol as a harmless placeholder and show nothing.
string baseTicker  = isMapped ? "TVC:" + baseName : syminfo.tickerid
string quoteTicker = isMapped ? "TVC:" + quoteName : syminfo.tickerid
// The spread symbol is the series a manually added "EU10Y-US10Y" uses, so the plotted line matches it.
string spreadTicker = isMapped ? "TVC:" + baseName + "-TVC:" + quoteName : syminfo.tickerid

// A yield bar can close after the chart bar of the same date (US yields close at 17:30 New York, FX at
// 17:00), and request.security() then delivers it one chart bar late. Each value is therefore requested
// with the trading day it belongs to. On daily, weekly and monthly charts dated() returns the value for
// this bar if it has arrived, and the value that belongs to the previous bar, which always has. Intraday
// bars are taken as they come.
bool   byDate  = timeframe.isdwm
float  halfBar = timeframe.in_seconds() * 500.0
string snapTf  = byDate ? "60" : timeframe.period
sameBar(int valueDay, int barDay) => math.abs(valueDay - barDay) < halfBar

dated(string symbolId) =>
    [cur, prev, curDay, prevDay] = request.security(symbolId, timeframe.period, [close, close[1], time_tradingday, time_tradingday[1]], ignore_invalid_symbol = true)
    // While the market is closed, a late value for the last bar has no later bar to arrive on. Its last
    // hourly reading inside that bar stands in until the official close arrives. No lookahead is used.
    [snap, snapDay] = request.security(symbolId, snapTf, [close, time_tradingday], calc_bars_count = 500, ignore_invalid_symbol = true)
    int   thisBarDay = time_tradingday
    int   prevBarDay = time_tradingday[1]
    bool  closedLast = barstate.islast and not barstate.isrealtime
    float onBar      = (not byDate or barstate.isrealtime or sameBar(curDay, thisBarDay)) ? cur : (closedLast and snapDay == thisBarDay) ? snap : na
    // If the chart skipped a day the yield traded, neither requested value is dated to the previous chart
    // bar; what arrived on that bar itself is then the right value.
    float prevBar    = not byDate ? cur[1] : sameBar(curDay, prevBarDay) ? cur : sameBar(prevDay, prevBarDay) ? prev : onBar[1]
    [isMapped ? onBar : na, isMapped ? prevBar : na]

[spreadOn, spreadPrev] = dated(spreadTicker)
[baseOn, basePrev]     = dated(baseTicker)
[quoteOn, quotePrev]   = dated(quoteTicker)
float spreadKept = fixnan(spreadPrev)

// Spread trend: a fast and a slow average of the spread. The "Prev" values use the spread as dated to
// the previous bar, which has always arrived; the "On" values add this bar's spread to those.
bool  useEma      = trendTypeInput == "Exponential"
float fastWeight  = 2.0 / (fastInput + 1)
float slowWeight  = 2.0 / (slowInput + 1)
float fastEma     = ta.ema(spreadKept, fastInput)
float slowEma     = ta.ema(spreadKept, slowInput)
float fastSma     = ta.sma(spreadKept, fastInput)
float slowSma     = ta.sma(spreadKept, slowInput)
float fastSmaRest = ta.sma(spreadKept, fastInput - 1)
float slowSmaRest = ta.sma(spreadKept, slowInput - 1)
float fastPrev    = useEma ? fastEma : fastSma
float slowPrev    = useEma ? slowEma : slowSma
float fastOn      = useEma ? fastWeight * spreadOn + (1 - fastWeight) * fastEma : (spreadOn + fastSmaRest * (fastInput - 1)) / fastInput
float slowOn      = useEma ? slowWeight * spreadOn + (1 - slowWeight) * slowEma : (spreadOn + slowSmaRest * (slowInput - 1)) / slowInput
bool  knownPrev   = not na(fastPrev) and not na(slowPrev)
bool  knownOn     = not na(fastOn) and not na(slowOn)
bool  risingPrev  = fastPrev > slowPrev
bool  risingOn    = fastOn > slowOn
bool  turnedPrev  = knownPrev and knownPrev[1] and risingPrev != risingPrev[1]
color trendPrevColor = not knownPrev ? spreadColorInput : risingPrev ? risingInput : fallingInput
color trendOnColor   = not knownOn ? trendPrevColor : risingOn ? risingInput : fallingInput

// Which yield is driving: the one that has moved more over the lookback. Moves dated to the previous bar
// colour the confirmed line; moves measured from this bar colour the live end of it.
float baseKept      = fixnan(basePrev)
float quoteKept     = fixnan(quotePrev)
bool  yieldsLive    = not na(baseOn) and not na(quoteOn)
float baseMovePrev  = baseKept - baseKept[lookbackInput]
float quoteMovePrev = quoteKept - quoteKept[lookbackInput]
float baseMoveOn    = yieldsLive ? baseOn - baseKept[lookbackInput - 1] : na
float quoteMoveOn   = yieldsLive ? quoteOn - quoteKept[lookbackInput - 1] : na
float baseMoveNow   = yieldsLive ? baseMoveOn : baseMovePrev
float quoteMoveNow  = yieldsLive ? quoteMoveOn : quoteMovePrev

bool  colourByDriver = colourByInput == "Driving yield"
bool  colourByTrend  = colourByInput == "Spread trend"
driverColor(float baseMove, float quoteMove) => na(baseMove) or na(quoteMove) ? spreadColorInput : math.abs(baseMove) >= math.abs(quoteMove) ? baseColorInput : quoteColorInput
color driverPrevColor = driverColor(baseMovePrev, quoteMovePrev)
color driverOnColor   = driverColor(baseMoveNow, quoteMoveNow)
color prevColor       = colourByTrend ? trendPrevColor : colourByDriver ? driverPrevColor : spreadColorInput
color onColor         = colourByTrend ? trendOnColor : colourByDriver ? driverOnColor : spreadColorInput

// How the lines are drawn. On daily, weekly and monthly charts each line in the pane is the confirmed
// plot, shifted one bar left onto its own date and joined to the live value by a line object. The live
// plots draw only on intraday charts, where nothing arrives late. Drawn everywhere, they would lie over
// the confirmed plots and double the opacity of a translucent line wherever both exist. On other charts
// they keep one invisible point on the last bar, so the scale still makes room for the live value.
// The trend line is declared first, so it lies under the spread.
color unseen     = color.new(color.gray, 100)
float trendLive  = showTrendInput and (not byDate or barstate.islast) ? slowOn : na
float trendLate  = showTrendInput and byDate ? slowPrev : na
float spreadLive = showSpreadInput and (not byDate or barstate.islast) ? spreadOn : na
float spreadLate = showSpreadInput and byDate ? spreadPrev : na
solid(color shade) => color.rgb(color.r(shade), color.g(shade), color.b(shade))
plot(trendLive, "Spread trend (live)", color = byDate ? unseen : trendOnColor, linewidth = 2, style = plot.style_linebr, display = display.pane + display.data_window)
plot(trendLate, "Spread trend (confirmed close)", color = trendPrevColor, linewidth = 2, offset = -1, display = display.pane + display.data_window)
plot(spreadLive, "Yield spread (live)", color = byDate ? unseen : onColor, linewidth = 2, style = plot.style_linebr, display = display.pane)
plot(spreadLate, "Yield spread (confirmed close)", color = prevColor, linewidth = 2, offset = -1, display = display.pane + display.data_window)
// The spread's value for the scale label and the Data Window. It is not drawn, and is given a solid
// colour so the number stays readable when the line itself is translucent. No plot shows a value beside
// the script's name.
plot(showSpreadInput ? spreadOn : na, "Yield spread", color = solid(onColor), display = display.price_scale + display.data_window)

var line spreadJoin = na
var line trendJoin  = na
if barstate.islast
    line.delete(spreadJoin)
    line.delete(trendJoin)
    spreadJoin := na
    trendJoin  := na
    if not na(spreadOn) and not na(spreadLate)
        spreadJoin := line.new(bar_index - 1, spreadLate, bar_index, spreadOn, color = onColor, width = 2)
    if not na(slowOn) and not na(trendLate)
        trendJoin := line.new(bar_index - 1, trendLate, bar_index, slowOn, color = trendOnColor, width = 2)

alertcondition(turnedPrev and risingPrev, "Spread trend turned up", "The fast average of the yield spread has closed above the slow one.")
alertcondition(turnedPrev and not risingPrev, "Spread trend turned down", "The fast average of the yield spread has closed below the slow one.")

// Implied price. The fit uses completed bars only: price and spread as dated to the previous bar, with
// gaps carried forward. This bar's implied price applies that fit to this bar's spread, so a bar never
// fits itself.
float pricePrev   = close[1]
float corr        = ta.correlation(pricePrev, spreadKept, windowInput)
float priceSd     = ta.stdev(pricePrev, windowInput)
float spreadSd    = ta.stdev(spreadKept, windowInput)
float slope       = spreadSd > 0 ? corr * priceSd / spreadSd : na
float intercept   = ta.sma(pricePrev, windowInput) - slope * ta.sma(spreadKept, windowInput)
float impliedOn   = intercept + slope * spreadOn
float impliedPrev = intercept[1] + slope[1] * spreadPrev
bool  fitLive     = not na(impliedOn)
float impliedNow  = fitLive ? impliedOn : impliedPrev
float priceRef    = fitLive ? close : close[1]
// The fit is judged by the correlation behind the implied price in use. It counts as a fit only when
// price has moved with the spread. A negative correlation means the pair has been moving against the
// spread, and the implied price then works upside-down, so it is never a fit: it is marked as inverse
// when the correlation is at least as strong as the chosen level, and as weak otherwise.
float corrNow     = fitLive ? corr : corr[1]
bool  fitKnown    = not na(corrNow)
bool  fitGood     = fitKnown and corrNow >= weakInput
bool  fitInverse  = fitKnown and not fitGood and corrNow <= -weakInput
string fitTag     = fitGood or not fitKnown ? "" : fitInverse ? " (inverse)" : " (weak fit)"

// It is in price units, which this script's own scale cannot show, so it is drawn with a polyline forced
// onto the chart's price scale. Each bar stores the level dated to the previous bar.
var array<chart.point> fitPts = array.new<chart.point>()
if showFitInput and not na(impliedPrev)
    chart.point newPt   = chart.point.from_index(bar_index - 1, impliedPrev)
    bool        replace = false
    if fitPts.size() > 0
        chart.point lastPt = fitPts.last()
        replace := lastPt.index == bar_index - 1
    if replace
        fitPts.set(fitPts.size() - 1, newPt)
    else
        fitPts.push(newPt)
    if fitPts.size() > drawInput
        fitPts.shift()

var polyline fitLine = na
if barstate.islast
    polyline.delete(fitLine)
    fitLine := na
    array<chart.point> drawn = fitPts.copy()
    if showFitInput and not na(impliedOn)
        drawn.push(chart.point.from_index(bar_index, impliedOn))
    if drawn.size() > 1
        color fitFaded = color.from_gradient(35, 0, 100, chart.bg_color, fitColorInput)
        fitLine := polyline.new(drawn, line_color = fitGood ? fitColorInput : fitFaded, line_width = 2, force_overlay = true)

// Caption: the spread in use, each yield's move over the lookback, the implied price and the spread trend.
bool   isFx         = syminfo.type == "forex"
float  pip          = syminfo.currency == "JPY" ? 0.01 : 0.0001
string barUnit      = timeframe.multiplier != 1 ? " bars" : timeframe.isdaily ? "d" : timeframe.isweekly ? "w" : timeframe.ismonthly ? "m" : " bars"
float  spreadNow    = na(spreadOn) ? spreadKept : spreadOn
bool   showTrendRow = showTrendInput or colourByTrend
int    trendRow     = showFitInput ? 3 : 2
int    captionRows  = 2 + (showFitInput ? 1 : 0) + (showTrendRow ? 1 : 0)

signed(float value, string fmt) => (value > 0 ? "+" : "") + str.tostring(value, fmt)
points(float move) => na(move) ? "-" : signed(move * 100, "0.0")

string captionPos = switch captionPosInput
    "Top right"    => position.top_right
    "Top center"   => position.top_center
    "Bottom right" => position.bottom_right
    => position.bottom_left

if barstate.islast and showCaptionInput and isMapped
    var table caption = table.new(captionPos, 2, captionRows, bgcolor = color.new(chart.bg_color, 10), frame_color = color.new(chart.fg_color, 75), frame_width = 1)
    color  ink       = chart.fg_color
    bool   baseLeads = math.abs(baseMoveNow) >= math.abs(quoteMoveNow)
    bool   bothKnown = not na(baseMoveNow) and not na(quoteMoveNow)
    string span      = " bp (" + str.tostring(lookbackInput) + barUnit + ")"
    string moveTip   = "How far each yield has moved over the lookback. The larger move is highlighted; it sets the colour of the spread line when the line is coloured by driving yield."
    table.cell(caption, 0, 0, baseName + " - " + quoteName, text_color = ink, text_halign = text.align_left, text_size = size.small)
    table.cell(caption, 1, 0, na(spreadNow) ? "no data" : str.tostring(spreadNow, "0.000") + "%", text_color = ink, text_halign = text.align_left, text_size = size.small)
    table.cell(caption, 0, 1, syminfo.basecurrency + " yield " + points(baseMoveNow) + span, text_color = colourByDriver ? baseColorInput : ink, bgcolor = bothKnown and baseLeads ? color.new(baseColorInput, 80) : na, text_halign = text.align_left, text_size = size.small, tooltip = moveTip)
    table.cell(caption, 1, 1, syminfo.currency + " yield " + points(quoteMoveNow) + span, text_color = colourByDriver ? quoteColorInput : ink, bgcolor = bothKnown and not baseLeads ? color.new(quoteColorInput, 80) : na, text_halign = text.align_left, text_size = size.small, tooltip = moveTip)
    if showFitInput
        float  gap     = priceRef - impliedNow
        string gapText = na(gap) ? "-" : isFx ? signed(gap / pip, "0") + " pips" : signed(gap / priceRef * 100, "0.00") + "%"
        string fitTip  = "The price this spread implies, from a regression of price on the spread over the last " + str.tostring(windowInput) + " completed bars. The correlation between price and the spread over that window is " + (fitKnown ? str.tostring(corrNow, "0.00") : "-") + "." + (fitInverse ? " It is negative: the pair has been moving against the spread, so this level is not a guide." : "")
        table.cell(caption, 0, 2, "Spread implies " +(na(impliedNow) ? "-" : str.tostring(impliedNow, format.mintick)) + fitTag, text_color = fitColorInput, text_halign = text.align_left, text_size = size.small, tooltip = fitTip)
        table.cell(caption, 1, 2, "price " + gapText, text_color = fitColorInput, text_halign = text.align_left, text_size = size.small, tooltip = fitTip)
    if showTrendRow
        bool   trendKnown = knownOn or knownPrev
        bool   rising     = knownOn ? risingOn : risingPrev
        string trendTip   = "Rising while the fast average of the spread is above the slow one, falling while it is below."
        table.cell(caption, 0, trendRow, "Spread trend (" + str.tostring(fastInput) + "/" + str.tostring(slowInput) + ")", text_color = ink, text_halign = text.align_left, text_size = size.small, tooltip = trendTip)
        table.cell(caption, 1, trendRow, not trendKnown ? "-" : rising ? "rising" : "falling", text_color = not trendKnown ? ink : rising ? risingInput : fallingInput, text_halign = text.align_left, text_size = size.small, tooltip = trendTip)

// With the caption off, a chart the script cannot draw on would otherwise be left blank without explanation.
string noteText = not isMapped ? "Yield spread: currency pairs only" : na(spreadNow) ? "No data for " + baseName + " - " + quoteName : ""
if barstate.islast and showNoteInput and noteText != "" and not (showCaptionInput and isMapped)
    var table notice = table.new(captionPos, 1, 1)
    table.cell(notice, 0, 0, noteText, text_color = color.new(chart.fg_color, 50), text_size = size.small)
````
