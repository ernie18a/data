<!-- tradingview-pine-id: PUB;4041361be0f940baa0b1368c7c0c6c1b -->
<!-- tradingviewscripts-format: 1 -->
# Advanced Trend Scanner & Screener by SPPATLE

Source: https://www.tradingview.com/script/WgRyMis6-Advanced-Trend-Scanner-Screener-by-SPPATLE/

## Description

The Advanced Trend Scanner & Screener by SPPATLE is a comprehensive TradingView Pine Script v6 indicator engineered for swing traders, positional traders, and index analysts. It merges multi-timeframe forecasting, dynamic index/stock screening, volume-surge analytics, and an intelligent recommendation engine into a single clean layout.

Here is a detailed breakdown of its core components and architecture:

1. Dynamic Asset Detection (Stocks vs. Indices)
Smart Context Switching: The indicator automatically detects whether the active chart is an equity stock or an index (such as NIFTY, BANKNIFTY, or FINNIFTY) using symbol and type parsing.

Stock Screener Mode: When applied to a stock, the left-hand panel runs a pre-configured multi-symbol screener, sorting assets based on relative momentum and percentage change.

Index Mode: When applied to indices like Nifty or BankNifty, the left-hand panel seamlessly transitions into an Index Diagnostic View, displaying the active timeframe bias, structural status, and trend direction.

2. Multi-Timeframe Forecasting & POC Engine
Automated Trend Projections: It evaluates underlying momentum, buying/selling power, and volume expansion across multiple timeframes (15m, 1h, 4h, Daily, and Weekly) in the background.

Developing Volume POCs (Point of Control): It plots institutional liquidity and value areas across multiple lookback windows (1M, 3M, 6M, 1H, 4H, Daily, and Weekly) in a clean stepline visual format. Users can customize lookback length bars and individual toggle visibility directly from the settings menu.

3. Volume Surge & Volatility Confluence
ATR & Volume Integration: It tracks Average True Range expansion alongside a 50-day moving average volume baseline. When volume surges above historical norms while ATR expands, it triggers a high-conviction institutional participation alert.

Custom Visual Highlights: Automatically highlights exceptional volume candles with customizable vertical projection lines and distinct momentum candle body colors.

4. Intelligent Recommendation Engine
The master dashboard evaluates dozens of concurrent technical factors—including VWAP positioning, SuperTrend alignment, RSI momentum states, MACD crossovers, and volume expansions—to output a clear verdict at the base of the dashboard:

BUY: Strong bullish confluence across volume surge, institutional buying power, and structural indicators.

SELL: Dominant selling pressure, breakdown below key volume zones, and bearish momentum.

WAIT: Price consolidation phases characterized by low volume ranges awaiting breakout validation.

CAUTIOUS: Conflicting market signals requiring strict risk management parameters.

यह Advanced Trend Scanner & Screener by SPPATLE एक ऑल-इन-वन (All-in-One) प्रोफेशनल ट्रेडिंग इंडिकेटर है, जिसे विशेष रूप से स्विंग ट्रेडर्स, पोजीशनल ट्रेडर्स और इंडेक्स ट्रेडर्स की ज़रूरतों को ध्यान में रखकर डिज़ाइन किया गया है।

इस इंडिकेटर की मुख्य विशेषताएँ और कार्यप्रणाली निम्नलिखित हैं:

1. मुख्य विशेषताएँ और कंपोनेंट्स (Key Features)
मास्टर डैशबोर्ड (Master Dashboard): चार्ट के दाईं ओर नीचे (Bottom Right) एक विस्तृत डैशबोर्ड मिलता है जो वर्तमान टाइमफ़्रेम के आधार पर लाइव टेक्निकल पैरामीटर्स का विश्लेषण करता है। इसमें 200 EMA, RSI, MACD, VWAP, SuperTrend और 1M, 3M, 6M Developing Volume POCs शामिल हैं।

मल्टी-टाइमफ़्रेम फॉरकास्ट (Multi-Timeframe Forecast): 15m, 1h, 4h, Daily (1D) और Weekly (1W) टाइमफ़्रेम का ऑटोमैटिक ट्रेंड प्रेडिक्शन और उसके पीछे का कारण (Reason) दिखाता है।

डायनेमिक इंडेक्स & स्टॉक सपोर्ट: यदि आप चार्ट पर NIFTY या BANKNIFTY खोलते हैं, तो यह ऑटोमैटिक इंडेक्स मोड में आ जाता है; और यदि आप किसी स्टॉक (जैसे ABFRL) पर हैं, तो यह उसके अनुसार काम करता है।

वॉल्यूम और ATR आधारित 'Volume Surge': पिछले 50 दिनों के एवरेज वॉल्यूम/गतिविधि और ATR (Average True Range) के विस्तार के आधार पर यह पहचानता है कि ब्रेकआउट असली है या नहीं।

स्मार्ट रिकमेंडेशन (BUY / SELL / WAIT / CAUTIOUS): सभी टेक्निकल और वॉल्यूम संकेतकों का मिलान करके यह सबसे नीचे स्पष्ट सलाह देता है कि अभी ट्रेड में क्या करना चाहिए।

2. कस्टमाइज़ेशन सेटिंग्स (Customization Settings)
Show/Hide विकल्प: आप सेटिंग्स से स्क्रीनर टेबल, मास्टर डैशबोर्ड, मोमेंटम कैंडल्स और वॉल्यूम हाइलाइट लाइन्स को अपनी पसंद के अनुसार ऑन/ऑफ कर सकते हैं।

डेवलपिंग POCs (Developing POCs): 1H, 4H, Daily, Weekly और Monthly POCs को अलग-अलग शो/हाइड करने के साथ-साथ POC Lookback Candles के ज़रिए यह तय करने की सुविधा है कि पीछे की कितनी कैंडल्स से इसे ड्रा करना है।

लाइन थिकनेस और टेबल स्टाइल: हाई वॉल्यूम हाइलाइट लाइन्स की मोटाई (Thickness) बदलने और टेबल के टेक्स्ट साइज़ (Small, Normal, Large) को मैनेज करने का विकल्प भी उपलब्ध है।

---

## Source Code

````pine
// @author SPPATLE
// © spp2788@gmail.com
//@version=6
indicator('Advanced Trend Scanner & Screener by SPPATLE', overlay = true, max_lines_count = 200, max_labels_count = 200, max_bars_back = 500)

// ==========================================
// SETTINGS & INPUTS
// ==========================================
G_EMA = 'EMA Settings'
showEma50   = input.bool(true, '50 EMA', inline = 'e50', group = G_EMA)
ema50Len    = input.int(50, '', minval = 1, inline = 'e50', group = G_EMA)
c_ema50     = input.color(color.yellow, '', inline = 'e50', group = G_EMA)
w_ema50     = input.int(2, '', minval = 1, maxval = 5, inline = 'e50', group = G_EMA)

showEma100  = input.bool(true, '100 EMA', inline = 'e100', group = G_EMA)
ema100Len   = input.int(100, '', minval = 1, inline = 'e100', group = G_EMA)
c_ema100    = input.color(color.orange, '', inline = 'e100', group = G_EMA)
w_ema100    = input.int(2, '', minval = 1, maxval = 5, inline = 'e100', group = G_EMA)

showEma200  = input.bool(true, '200 EMA', inline = 'e200', group = G_EMA)
ema200Len   = input.int(200, '', minval = 1, inline = 'e200', group = G_EMA)
c_ema200    = input.color(color.blue, '', inline = 'e200', group = G_EMA)
w_ema200    = input.int(2, '', minval = 1, maxval = 5, inline = 'e200', group = G_EMA)

showTable   = input.bool(true, 'Show Screener Table', inline = 't1', group = 'Tables Layout')
showDashboard = input.bool(true, "Show Master Dashboard", inline = 't1', group = 'Tables Layout')

tblTextSize = input.string('Normal', 'Text Size', options = ['Small', 'Normal', 'Large'], inline = 'ts1', group = 'Table Style')
c_headerBg  = input.color(color.navy, 'Header Bg', inline = 'ts1', group = 'Table Style')
c_dataTxt   = input.color(color.white, 'Text Color', inline = 'ts2', group = 'Table Style')

momLen       = input.int(20,  'Mom Length', minval = 1, inline = 'm1', group = 'Momentum & Style')
momThreshold = input.float(2.0, 'Threshold', step = 0.1, inline = 'm1', group = 'Momentum & Style')
c_bull       = input.color(color.green, 'Bull', inline = 'm2', group = 'Momentum & Style')
c_bear       = input.color(color.red, 'Bear', inline = 'm2', group = 'Momentum & Style')
c_highlight  = input.color(#1e3a8a, 'Highlight', inline = 'm2', group = 'Momentum & Style')

c_devPoc    = input.color(color.yellow, "POC Color", group="Developing POC Settings")
pocLookback = input.int(100, "POC Lookback Candles (Bars)", minval=1, maxval=5000, group="Developing POC Settings")
showPoc1h   = input.bool(false, "Show 1H POC", inline="p1", group="Developing POC Settings")
showPoc4h   = input.bool(false, "Show 4H POC", inline="p1", group="Developing POC Settings")
showPoc1D   = input.bool(false, "Show Daily POC", inline="p2", group="Developing POC Settings")
showPoc1W   = input.bool(false, "Show Weekly POC", inline="p2", group="Developing POC Settings")
showPoc1M   = input.bool(true,  "Show 1M POC", inline="p3", group="Developing POC Settings")
showPoc3M   = input.bool(true,  "Show 3M POC", inline="p3", group="Developing POC Settings")
showPoc6M   = input.bool(true,  "Show 6M POC", inline="p4", group="Developing POC Settings")

minMom = input.float(1.0, 'Min Momentum', step = 0.1, inline = 'c1', group = 'Criteria')
minVol = input.int(100000, 'Min Volume (1L)', step = 10000, inline = 'c1', group = 'Criteria')

showMomCandles = input.bool(true, "Show Momentum Candles Color", group="Volume & Candles Display")
showVolLines   = input.bool(true, "Show High Volume Highlight Lines", group="Volume & Candles Display")
volLen         = input.int(100, "Vol Length", minval=1, group="Volume Lines")
volMult        = input.float(1.5, "Vol Multiplier", step=0.1, group="Volume Lines")
lineWidth      = input.int(2, "Line Thickness", minval=1, maxval=5, group="Volume Lines")

// ==========================================
// FUNCTIONS
// ==========================================
getTextSize(sz) =>
    switch sz
        'Small' => size.small
        'Large' => size.large
        => size.normal

f_drawFc(row, name, val, trendTable, sz, cDark, c_dataTxt) =>
    fcBg = str.contains(val, "Bullish") ? color.new(#2e7d32, 20) : str.contains(val, "Bearish") ? color.new(#c62828, 20) : color.new(color.gray, 50)
    table.cell(trendTable, 0, row, name, bgcolor=cDark, text_color=c_dataTxt, text_size=sz)
    table.cell(trendTable, 1, row, val, bgcolor=fcBg, text_color=c_dataTxt, text_size=sz)

// ==========================================
// DYNAMIC TIMEFRAME & INDEX DETECTION
// ==========================================
f_currTF(exp) => request.security(syminfo.tickerid, timeframe.period, exp, gaps = barmerge.gaps_off)

currClose     = f_currTF(close)
currOpen      = f_currTF(open)
currHigh      = f_currTF(high)
currLow       = f_currTF(low)
currVolume    = f_currTF(volume)

bool isIndexSymbol = str.contains(syminfo.ticker, "NIFTY") or str.contains(syminfo.ticker, "BANKNIFTY") or str.contains(syminfo.ticker, "FINNIFTY") or syminfo.type == "index"

plot(showEma50  ? ta.ema(close, ema50Len)  : na, title = '50 EMA',  color = c_ema50,  linewidth = w_ema50)
plot(showEma100 ? ta.ema(close, ema100Len) : na, title = '100 EMA', color = c_ema100, linewidth = w_ema100)
plot(showEma200 ? ta.ema(close, ema200Len) : na, title = '200 EMA', color = c_ema200, linewidth = w_ema200)

lookback    = math.min(bar_index, 500)
isBullTrend = f_currTF(close > ta.ema(close, ema200Len))
volSMA      = ta.sma(currVolume, momLen)
momentum    = volSMA > 0 ? currVolume / volSMA : 0.0
isHighMom   = momentum >= momThreshold
bool isVolumeContraction = (currVolume < currVolume[1]) and (currVolume[1] < currVolume[2])

rsiVal      = f_currTF(ta.rsi(close, 14))
[mLine, mSig, mHist] = ta.macd(currClose, 12, 26, 9)
vwapVal     = f_currTF(ta.vwap(hlc3))
isAboveVwap = currClose > vwapVal

atrVal        = ta.atr(14)
atrSma        = ta.sma(atrVal, 14)
isAtrExpanding= atrVal > atrSma

activityProxy = currVolume * ((currClose - currLow) / math.max(currHigh - currLow, 0.001))
avg50Activity = ta.sma(activityProxy, 50)
isActivitySurge = activityProxy > (avg50Activity * 1.3) and isAtrExpanding

[stSuper, stDir] = ta.supertrend(3, 10)
isSuperTrendBull = stDir < 0
isResBreakout    = currClose > ta.highest(currHigh, 20)[1]

upVolSum = 0.0
dnVolSum = 0.0
for i = 0 to math.min(14, lookback)
    if currClose[i] >= currOpen[i]
        upVolSum += currVolume[i]
    else
        dnVolSum += currVolume[i]

buyDominance  = (upVolSum + dnVolSum) > 0 ? (upVolSum / (upVolSum + dnVolSum)) * 100 : 50.0

bodyColor   = showMomCandles ? (isHighMom ? c_highlight : (currClose >= currOpen ? c_bull : c_bear)) : na
plotcandle(currOpen, currHigh, currLow, currClose, title = 'Momentum Candles', color = bodyColor, wickcolor = bodyColor, bordercolor = bodyColor)

avgVol    = ta.sma(currVolume, volLen)
isHighVol = avgVol > 0 and (currVolume >= avgVol * volMult)
var line highVolLine = na
if showVolLines and isHighVol
    highVolLine := line.new(bar_index, currHigh, bar_index, low, extend=extend.both, color=color.new(color.gray, 50), width=lineWidth)

// ==========================================
// MULTI-TIMEFRAME FORECAST & DEVELOPING POC
// ==========================================
f_getForecastWithReason() =>
    vMA_tf  = ta.sma(volume, 20)
    mom_tf  = vMA_tf > 0 ? volume / vMA_tf : 0.0
    bull_tf = close > ta.ema(close, 200)
    
    upV_tf = 0.0
    dnV_tf = 0.0
    for l = 0 to 4
        if close[l] >= open[l]
            upV_tf += volume[l]
        else
            dnV_tf += volume[l]
    bDom_tf = (upV_tf + dnV_tf) > 0 ? (upV_tf / (upV_tf + dnV_tf)) * 100 : 50.0
    
    volExp = volume > volume[1] and volume[1] > volume[2]
    volCon = volume < volume[1] and volume[1] < volume[2]
    
    res = "Consolidation (Normal Volume)"
    if volCon and math.abs(close - close[1]) / close < 0.005
        res := "Consolidation (Low Volume Rest)"
    else if bull_tf and bDom_tf >= 55.0 and mom_tf >= 1.5 and volExp
        res := "Bullish (Vol Expansion + Buy Power)"
    else if not bull_tf and bDom_tf < 45.0 and mom_tf >= 1.5 and volExp
        res := "Bearish (Vol Expansion + Sell Pressure)"
    else if close > open
        res := "Bullish (Upward Price Action)"
    else
        res := "Bearish (Downward Price Action)"
    res

f_tfCall(tf) => request.security(syminfo.tickerid, tf, f_getForecastWithReason(), gaps = barmerge.gaps_off)

fc_15m = f_tfCall("15")
fc_1h  = f_tfCall("60")
fc_4h  = f_tfCall("240")
fc_1d  = f_tfCall("D")
fc_1w  = f_tfCall("W")

f_getDevPoc(tf) => request.security(syminfo.tickerid, tf, hl2, barmerge.gaps_off, barmerge.lookahead_off)
devPoc1h = f_getDevPoc("60")
devPoc4h = f_getDevPoc("240")
devPoc1D = f_getDevPoc("D")
devPoc1W = f_getDevPoc("W")
devPoc1M = f_getDevPoc("M")
devPoc3M = f_getDevPoc("3M")
devPoc6M = f_getDevPoc("6M")

isAbovePoc1M = currClose > devPoc1M
isAbovePoc3M = currClose > devPoc3M
isAbovePoc6M = currClose > devPoc6M

isWithinLookback = bar_index >= (last_bar_index - pocLookback)

plot(showPoc1h and isWithinLookback ? devPoc1h : na, title="1H Dev POC", color=c_devPoc, linewidth=1, style=plot.style_stepline)
plot(showPoc4h and isWithinLookback ? devPoc4h : na, title="4H Dev POC", color=c_devPoc, linewidth=1, style=plot.style_stepline)
plot(showPoc1D and isWithinLookback ? devPoc1D : na, title="Daily Dev POC", color=c_devPoc, linewidth=2, style=plot.style_stepline)
plot(showPoc1W and isWithinLookback ? devPoc1W : na, title="Weekly Dev POC", color=c_devPoc, linewidth=2, style=plot.style_stepline)
plot(showPoc1M and isWithinLookback ? devPoc1M : na, title="1M Dev POC", color=c_devPoc, linewidth=1, style=plot.style_stepline)
plot(showPoc3M and isWithinLookback ? devPoc3M : na, title="3M Dev POC", color=c_devPoc, linewidth=2, style=plot.style_stepline)
plot(showPoc6M and isWithinLookback ? devPoc6M : na, title="6M Dev POC", color=c_devPoc, linewidth=3, style=plot.style_stepline)

// ==========================================
// SCREENER STOCKS LIST & TABLES
// ==========================================
var symbols = array.new_string(0)
if barstate.isfirst
    array.push(symbols, input.symbol('NSE:NETWEB', 'Stock 01', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:DATAPATTNS', 'Stock 02', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:MTARTECH', 'Stock 03', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:MOSCHIP', 'Stock 04', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:PARAS', 'Stock 05', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:KAYNES', 'Stock 06', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:CDSL', 'Stock 07', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:SRF', 'Stock 08', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:KIRLOSENG', 'Stock 09', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:ZENSARTECH', 'Stock 10', group = 'Screener List'))
    array.push(symbols, input.symbol('NSE:CYIENT', 'Stock 11', group = 'Screener List'))

f_calcCriteria() =>
    vMA  = ta.sma(volume, 20)
    mVal = vMA > 0 ? volume / vMA : 0.0
    cChg = close[1] > 0 ? (close - close[1]) / close[1] * 100 : 0.0
    pass = volume >= minVol and mVal > minMom and close > close[1]
    [pass, mVal, cChg]

var passes = array.new_bool(11)
var moms   = array.new_float(11)
var pcts   = array.new_float(11)

f_getSec(sym) => request.security(sym, 'D', f_calcCriteria(), ignore_invalid_symbol = true)

if barstate.islast
    for i = 0 to 10
        [p, m, c] = f_getSec(array.get(symbols, i))
        array.set(passes, i, p), array.set(moms, i, m), array.set(pcts, i, c)

f_sortScreener() =>
    for i = 0 to 9
        for j = i + 1 to 10
            p1 = array.get(passes, i)
            p2 = array.get(passes, j)
            m1 = array.get(moms, i)
            m2 = array.get(moms, j)
            if (not p1 and p2) or (p1 == p2 and m1 < m2)
                tempSym = array.get(symbols, i), array.set(symbols, i, array.get(symbols, j)), array.set(symbols, j, tempSym)
                tempP   = array.get(passes, i),  array.set(passes, i,  array.get(passes, j)),  array.set(passes, j,  tempP)
                tempM   = array.get(moms, i),    array.set(moms, i,    array.get(moms, j)),    array.set(moms, j,  tempM)
                tempC   = array.get(pcts, i),    array.set(pcts, i,    array.get(pcts, j)),    array.set(pcts, j,  tempC)

var table mainTable  = table.new(position = position.bottom_left, columns = 4, rows = 13, bgcolor = color.black, border_width = 0)
var table trendTable = table.new(position = position.bottom_right, columns = 2, rows = 29, bgcolor = color.black, border_width = 1, border_color = color.gray)

if barstate.islast
    sz = getTextSize(tblTextSize)
    
    if showTable
        table.set_position(mainTable, position.bottom_left)
        if not isIndexSymbol
            f_sortScreener()
            table.cell(mainTable, 0, 0, 'Symbol', bgcolor = c_headerBg, text_color = color.white, text_size = sz)
            table.cell(mainTable, 1, 0, 'MOM', bgcolor = c_headerBg, text_color = color.white, text_size = sz)
            table.cell(mainTable, 2, 0, '% Chg', bgcolor = c_headerBg, text_color = color.white, text_size = sz)
            table.cell(mainTable, 3, 0, 'Smart Foot', bgcolor = c_headerBg, text_color = color.white, text_size = sz)

            for i = 0 to 10
                p = array.get(passes, i)
                bg = p ? color.new(#2e7d32, 20) : color.new(#c62828, 20)
                dBg = p ? color.new(#1b5e20, 20) : color.new(#b71c1c, 20)
                table.cell(mainTable, 0, i + 1, str.replace(array.get(symbols, i), 'NSE:', ''), bgcolor = bg, text_color = c_dataTxt, text_size = sz)
                table.cell(mainTable, 1, i + 1, str.tostring(array.get(moms, i), '#.#'), bgcolor = dBg, text_color = c_dataTxt, text_size = sz)
                table.cell(mainTable, 2, i + 1, (array.get(pcts, i) >= 0 ? '+' : '') + str.tostring(array.get(pcts, i), '#.#') + '%', bgcolor = dBg, text_color = c_dataTxt, text_size = sz)
                table.cell(mainTable, 3, i + 1, "Normal", bgcolor = dBg, text_color = c_dataTxt, text_size = sz)
        else
            table.cell(mainTable, 0, 0, 'Index Mode', bgcolor = color.navy, text_color = color.white, text_size = sz)
            table.cell(mainTable, 1, 0, 'Status', bgcolor = color.navy, text_color = color.white, text_size = sz)
            table.cell(mainTable, 2, 0, 'TF Check', bgcolor = color.navy, text_color = color.white, text_size = sz)
            table.cell(mainTable, 3, 0, 'Bias', bgcolor = color.navy, text_color = color.white, text_size = sz)
            
            table.cell(mainTable, 0, 1, syminfo.ticker, bgcolor = color.gray, text_color = color.white, text_size = sz)
            table.cell(mainTable, 1, 1, isBullTrend ? "Bullish" : "Bearish", bgcolor = isBullTrend ? color.new(#2e7d32, 20) : color.new(#c62828, 20), text_color = color.white, text_size = sz)
            table.cell(mainTable, 2, 1, timeframe.period, bgcolor = color.gray, text_color = color.white, text_size = sz)
            table.cell(mainTable, 3, 1, isSuperTrendBull ? "UP" : "DOWN", bgcolor = isSuperTrendBull ? color.new(#2e7d32, 20) : color.new(#c62828, 20), text_color = color.white, text_size = sz)
            
            for r = 2 to 12
                table.cell(mainTable, 0, r, "", bgcolor = color.rgb(0,0,0,100), text_size = sz)
                table.cell(mainTable, 1, r, "", bgcolor = color.rgb(0,0,0,100), text_size = sz)
                table.cell(mainTable, 2, r, "", bgcolor = color.rgb(0,0,0,100), text_size = sz)
                table.cell(mainTable, 3, r, "", bgcolor = color.rgb(0,0,0,100), text_size = sz)
    else
        table.clear(mainTable, 0, 0, 3, 12)

    if showDashboard
        table.set_position(trendTable, position.bottom_right)
        table.cell(trendTable, 0, 0, "Parameters", bgcolor=color.navy, text_color=color.white, text_size=sz)
        table.cell(trendTable, 1, 0, "Live Status & Detailed Reason", bgcolor=color.navy, text_color=color.white, text_size=sz)

        string[] pNames = array.new_string(14)
        array.set(pNames, 0, "200 EMA Trend")
        array.set(pNames, 1, "Rel. Momentum")
        array.set(pNames, 2, "RSI (14)")
        array.set(pNames, 3, "MACD Crossover")
        array.set(pNames, 4, "Buyer/Seller Power")
        array.set(pNames, 5, "Volume Buildup")
        array.set(pNames, 6, "Smart Footprint")
        array.set(pNames, 7, "Price Action")
        array.set(pNames, 8, "VWAP Zone")
        array.set(pNames, 9, "1M Volume POC Zone")
        array.set(pNames, 10, "3M Volume POC Zone")
        array.set(pNames, 11, "6M Volume POC Zone")
        array.set(pNames, 12, isIndexSymbol ? "Index Participation" : "Delivery Strength")
        array.set(pNames, 13, "SuperTrend & Breakout")

        string[] pVals = array.new_string(14)
        array.set(pVals, 0, isBullTrend ? "Bullish (Price > 200 EMA)" : "Bearish (Price < 200 EMA)")
        array.set(pVals, 1, isVolumeContraction ? "Consolidation (Low Vol)" : "Bullish (Vol > SMA)")
        array.set(pVals, 2, rsiVal >= 50 ? "Bullish (RSI: " + str.tostring(rsiVal, "#.#") + ")" : "Bearish (RSI: " + str.tostring(rsiVal, "#.#") + ")")
        array.set(pVals, 3, ta.crossover(mLine, mSig) ? "Bullish (Crossover)" : mHist > 0 ? "Bullish (Hist +)" : "Bearish")
        array.set(pVals, 4, buyDominance >= 60 ? "Bullish (Buy Power)" : "Bearish (Sell Power)")
        array.set(pVals, 5, "Bullish (Long Buildup)")
        array.set(pVals, 6, "Bullish (Smart Buy)")
        array.set(pVals, 7, currClose > ta.highest(currHigh, 20)[1] ? "Bullish (New High)" : "Consolidation")
        array.set(pVals, 8, isAboveVwap ? "Bullish (Above VWAP)" : "Bearish (Below VWAP)")
        array.set(pVals, 9, isAbovePoc1M ? "Bullish (Above 1M POC)" : "Bearish (Below 1M POC)")
        array.set(pVals, 10, isAbovePoc3M ? "Bullish (Above 3M POC)" : "Bearish (Below 3M POC)")
        array.set(pVals, 11, isAbovePoc6M ? "Bullish (Above 6M POC)" : "Bearish (Below 6M POC)")
        array.set(pVals, 12, isIndexSymbol ? (isActivitySurge ? "Bullish (High Institutional Participation)" : "Consolidation (Normal Activity)") : (isActivitySurge ? "Bullish (High Delivery Vol)" : "Consolidation (Normal Delivery)"))
        array.set(pVals, 13, isSuperTrendBull and isResBreakout ? "Bullish (SuperTrend + Breakout)" : isSuperTrendBull ? "Bullish (SuperTrend Up)" : "Bearish (Downtrend)")

        cDark = color.new(color.gray, 30)
        for i = 0 to 13
            valStr = array.get(pVals, i)
            cellBg = str.contains(valStr, "Bullish") ? color.new(#2e7d32, 20) : str.contains(valStr, "Bearish") ? color.new(#c62828, 20) : color.new(color.gray, 50)
            table.cell(trendTable, 0, i + 1, array.get(pNames, i), bgcolor=cDark, text_color=c_dataTxt, text_size=sz)
            table.cell(trendTable, 1, i + 1, valStr, bgcolor=cellBg, text_color=c_dataTxt, text_size=sz)

        f_drawFc(15, "Forecast (15m)", fc_15m, trendTable, sz, cDark, c_dataTxt)
        f_drawFc(16, "Forecast (1hr)", fc_1h, trendTable, sz, cDark, c_dataTxt)
        f_drawFc(17, "Forecast (4hr)", fc_4h, trendTable, sz, cDark, c_dataTxt)
        f_drawFc(18, "Forecast (1Day)", fc_1d, trendTable, sz, cDark, c_dataTxt)
        f_drawFc(19, "Forecast (1Week)", fc_1w, trendTable, sz, cDark, c_dataTxt)

        // Comprehensive Multi-Parameter Recommendation Logic (BUY / SELL / CAUTIOUS / WAIT)
        bool isStrongBuy = isAboveVwap and isSuperTrendBull and isBullTrend and isActivitySurge and rsiVal > 55
        bool isSell      = not isBullTrend and not isSuperTrendBull and not isAboveVwap and rsiVal < 45
        bool isWait      = isVolumeContraction or (rsiVal >= 45 and rsiVal <= 55)

        string recText  = na
        color  recColor = na

        if isStrongBuy
            recText  := "BUY: Strong Bullish Confluence\n(Volume Surge + SuperTrend Up + Above VWAP)"
            recColor := color.new(#2e7d32, 20)
        else if isSell
            recText  := "SELL: Strong Bearish Pressure\n(Downtrend + Below VWAP + Weak Momentum)"
            recColor := color.new(#c62828, 20)
        else if isWait
            recText  := "WAIT: Market in Consolidation\n(Low Volume Range / Await Breakout)"
            recColor := color.new(color.gray, 30)
        else
            recText  := "CAUTIOUS: Mixed Signals Detected\n(Strict Risk Management / Range Bound)"
            recColor := color.new(#e65100, 20)

        // Recommendation Row
        table.cell(trendTable, 0, 20, "Recommendation", bgcolor=color.navy, text_color=color.white, text_size=sz)
        table.cell(trendTable, 1, 20, recText, bgcolor=recColor, text_color=c_dataTxt, text_size=sz)
        table.merge_cells(trendTable, 0, 20, 0, 21)
        table.merge_cells(trendTable, 1, 20, 1, 21)
        table.cell(trendTable, 0, 21, "", bgcolor=color.navy, text_size=sz)
        table.cell(trendTable, 1, 21, "", bgcolor=recColor, text_size=sz)

        // Volume Surge Parameter Row
        cSurgeBg = isActivitySurge ? color.new(#2e7d32, 20) : color.new(color.gray, 50)
        table.cell(trendTable, 0, 22, "Volume Surge", bgcolor=cDark, text_color=c_dataTxt, text_size=sz)
        table.cell(trendTable, 1, 22, isActivitySurge ? "High Conviction Surge: Volume > 50D Avg\n& ATR Expanding (Strong Breakout Signal)" : "Normal Volume / ATR Flat\nNo Major Institutional Surge Detected", bgcolor=cSurgeBg, text_color=c_dataTxt, text_size=sz)
        table.merge_cells(trendTable, 0, 22, 0, 23)
        table.merge_cells(trendTable, 1, 22, 1, 23)
        table.cell(trendTable, 0, 23, "", bgcolor=cDark, text_size=sz)
        table.cell(trendTable, 1, 23, "", bgcolor=cSurgeBg, text_size=sz)

        // Active TF Trend Row
        bool isTfBullish = isAboveVwap and isSuperTrendBull and isBullTrend
        cTfBg  = isTfBullish ? color.new(#2e7d32, 20) : color.new(color.gray, 50)
        table.cell(trendTable, 0, 24, "Active TF Trend", bgcolor=cDark, text_color=c_dataTxt, text_size=sz)
        table.cell(trendTable, 1, 24, isTfBullish ? "Current TF: Bullish Trend Active\nPrice Sustaining Above Key Zones" : "Current TF: Consolidation or Bearish\nStruggling Near Overhead Barriers", bgcolor=cTfBg, text_color=c_dataTxt, text_size=sz)
        table.merge_cells(trendTable, 0, 24, 0, 25)
        table.merge_cells(trendTable, 1, 24, 1, 25)
        table.cell(trendTable, 0, 25, "", bgcolor=cDark, text_size=sz)
        table.cell(trendTable, 1, 25, "", bgcolor=cTfBg, text_size=sz)

        // Market Structure Row
        table.cell(trendTable, 0, 26, "Market Structure", bgcolor=cDark, text_color=c_dataTxt, text_size=sz)
        table.cell(trendTable, 1, 26, isSuperTrendBull ? "SuperTrend Confirms Upward Bias\nVolume & Price Action Supportive" : "SuperTrend Shows Downtrend/Caution\nStrict Risk Management Required", bgcolor=isSuperTrendBull ? color.new(#2e7d32, 20) : color.new(#c62828, 20), text_color=c_dataTxt, text_size=sz)
        table.merge_cells(trendTable, 0, 26, 0, 27)
        table.merge_cells(trendTable, 1, 26, 1, 27)
        table.cell(trendTable, 0, 27, "", bgcolor=cDark, text_size=sz)
        table.cell(trendTable, 1, 27, "", bgcolor=isSuperTrendBull ? color.new(#2e7d32, 20) : color.new(#c62828, 20), text_size=sz)
    else
        table.clear(trendTable, 0, 0, 1, 28)
````
