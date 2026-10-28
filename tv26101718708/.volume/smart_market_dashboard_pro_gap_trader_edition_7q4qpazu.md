# Smart Market Dashboard PRO Gap Trader Edition

- url: https://www.tradingview.com/script/7q4QpaZu-Smart-Market-Dashboard-PRO-Gap-Trader-Edition/
- type: indicator
- pine_id: PUB;1ad4f1c9624448e4b72da19b97928cbd
- version: 1.0

## Description

A comprehensive intraday dashboard designed specifically for Borsa Istanbul (BIST) equity traders. This indicator focuses on opening gap analysis, combining volume, delta, and price action to help traders make informed decisions at market open.
Key Features:

[list]
[*]
[/list]Gap Detection & Classification – Automatically identifies and labels opening gaps (Full Gap Up/Down, Partial Gap Up/Down) with configurable minimum gap % threshold
[list]
[*]
[/list] Volume & Delta Analysis – Displays real-time cumulative delta, buy/sell volume ratio, and VWAP deviation
[list]
[*]
[/list] Multi-Timeframe Data – Fetches previous day’s OHLCV data to calculate gap reference levels accurately
[list]
[*]
[/list] Visual Dashboard – A clean on-chart table showing key metrics: gap size, volume trend, delta direction, and gap fill probability
[list]
[*]
[/list] Smart Alerts – Configurable alerts for gap setups, gap fill events, and volume anomalies

How It Works:

[list]
[*]
[/list]Gap levels are calculated using End-of-Day (previous session close) as the reference price
[list]
[*]
[/list]All calculations are based on confirmed bar data (barmerge.lookahead_off) to prevent repainting on historical bars
[list]
[*]
https://www.tradingview.com/x/bsKTGKdR/

Recommended Usage:

[*]Timeframe: 1–15 minute charts
[*]Market: BIST stocks (optimized for Turkish market open at 10:00 AM)
[*]Works best during the first 30–60 minutes of the trading session

Disclaimer: This indicator is for educational and informational purposes only. It does not constitute financial advice. Always manage your risk accordingly.
[/list]Note: As with all intraday indicators, values may update within the current live bar until it closes

## Source Code

````pine
// @version=6
indicator("Smart Market Dashboard PRO Gap Trader Edition",
     overlay = true, max_boxes_count = 300, max_labels_count = 500)

// ============================================================
// USER SETTINGS
// ============================================================
tablePosInput    = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
tableSizeInput   = input.string("normal", "Table Size", options = ["tiny", "small", "normal", "large"])
htfInput         = input.timeframe("60", "Higher Timeframe (HTF)")
gapThreshold     = input.int(50, "Min Probability for Setup (%)", minval=10, maxval=100)
gapVolumeMult    = input.float(1.8, "Volume Spike Multiplier")
gapDeltaStrength = input.float(0.15, "Delta Strength Multiplier")
bistCloseHour    = input.int(18, "BIST Close Hour (TradingView Time)", minval=0, maxval=23)
bistCloseMin     = input.int(0,  "BIST Close Minute", minval=0, maxval=59)
lookbackWindow   = input.int(30, "End-of-Day Window in Minutes", minval=10, maxval=120)
filterThursday   = input.bool(true,  "Disable Signal on Thursday (BIST Friday-Eve)")
minDailyVolume   = input.float(1.0,  "Min Daily Volume (Millions)", minval=0.1)
minDailyRange    = input.float(0.02, "Min Daily Range % (e.g. 0.02 = 2%)", minval=0.001)
filterPrevGap    = input.bool(true,  "Filter Out if Yesterday Had Gap Up")

enableOrderBookFilter = input.bool(true,  "Enable Order Book Filter (Sell Queue)")
sellQueueRatio        = input.float(3.0,  "Max Sell/Buy Queue Ratio", minval=1.0, maxval=10.0)

enableStopLoss = input.bool(true,  "Enable Stop Loss")
stopLossPct    = input.float(2.0,  "Stop Loss % Below Entry", minval=0.5, maxval=10.0)

enablePressureScore = input.bool(true, "Enable Market Pressure Score")
minPressureScore    = input.int(60,   "Min Market Pressure Score (%)", minval=0, maxval=100)

// ============================================================
// HUMAN READABLE VOLUME
// ============================================================
f_humanVol(val) =>
    absVal = math.abs(val)
    string result = ""
    if absVal >= 1e6
        result := str.tostring(val / 1e6, "#.##") + "M"
    else if absVal >= 1e3
        result := str.tostring(val / 1e3, "#.##") + "K"
    else
        result := str.tostring(val, "#")
    result

// ============================================================
// CORE CALCULATIONS
// ============================================================
priceRange = high - low
float buyVol = priceRange != 0 ? nz(volume * ((close - low) / priceRange), 0.0) : (close >= open ? volume : 0.0)
sellVol      = volume - buyVol
delta        = buyVol - sellVol
avgVol       = ta.sma(volume, 20)
volumeSpike  = volume > avgVol * gapVolumeMult

// ============================================================
// TREND & RSI
// ============================================================
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ltfTrend = ema9 > ema21 ? 1 : -1

h9       = request.security(syminfo.tickerid, htfInput, ta.ema(close, 9))
h21      = request.security(syminfo.tickerid, htfInput, ta.ema(close, 21))
htfTrend = h9 > h21 ? 1 : -1
rsi      = ta.rsi(close, 14)
breakout = close > ta.highest(high[1], 10)

// ============================================================
// DAILY DATA
// ============================================================
dOpen      = request.security(syminfo.tickerid, "D", open)
dHigh      = request.security(syminfo.tickerid, "D", high)
dLow       = request.security(syminfo.tickerid, "D", low)
dClose     = request.security(syminfo.tickerid, "D", close)
dVol       = request.security(syminfo.tickerid, "D", volume)
dPrevClose = request.security(syminfo.tickerid, "D", close[1])

dRange  = dHigh - dLow
dReturn = dOpen != 0 ? (dClose - dOpen) / dOpen : 0.0

strongDailyReturn = dReturn >= 0.02
closeNearHigh     = dRange > 0 ? (dClose - dLow) / dRange > 0.8 : false
dailyStrength     = strongDailyReturn and closeNearHigh

float dailyBuy   = dRange != 0 ? nz(dVol * ((dClose - dLow) / dRange), 0.0) : (dClose >= dOpen ? dVol : 0.0)
dailyDelta       = dailyBuy - (dVol - dailyBuy)
strongDailyDelta = dailyDelta > dVol * 0.08

// ============================================================
// LIMIT PRESSURE & GAP SCORE
// ============================================================
intradayRange       = high - low
nearHighIntraday    = intradayRange > 0 ? (close - low) / intradayRange > 0.80 : (close >= open)
strongIntradayDelta = delta > volume * 0.12
highVolumePressure  = volume > avgVol * 1.4
limitPressure       = nearHighIntraday and strongIntradayDelta and highVolumePressure and breakout

dailyFilter = (dailyStrength and strongDailyDelta) or limitPressure

gapScore = (volumeSpike ? 2 : 0) + (delta > volume * gapDeltaStrength ? 3 : 0) + (breakout ? 2 : 0) + (ltfTrend == 1 ? 1 : 0) + (htfTrend == 1 ? 1 : 0) + (rsi > 55 ? 1 : 0)

gapProb = math.min(gapScore * 10, 100)

// ============================================================
// ORDER BOOK FILTER
// ============================================================
recentBuyVol   = math.sum(buyVol, 5)
recentSellVol  = math.sum(sellVol, 5)
orderBookRatio = recentBuyVol > 0 ? recentSellVol / recentBuyVol : 999.0
orderBookFilter = enableOrderBookFilter ? orderBookRatio < sellQueueRatio : true

orderBookScore = orderBookRatio < 1.0 ? 100 : orderBookRatio < 2.0 ? 100 - (orderBookRatio - 1.0) * 20 : orderBookRatio < 3.0 ? 80 - (orderBookRatio - 2.0) * 20 : math.max(0, 60 - (orderBookRatio - 3.0) * 10)

// ============================================================
// MARKET PRESSURE SCORE
// ============================================================
deltaRatio = volume > 0 ? math.abs(delta) / volume : 0.0
deltaScore = math.min(deltaRatio * 500, 100.0)

volRatio = avgVol > 0 ? volume / avgVol : 1.0
volScore = math.max(0.0, math.min((volRatio - 1.0) * 50, 100.0))

priceActionScore = intradayRange > 0 ? ((close - low) / intradayRange) * 100.0 : 50.0
trendScore       = (ltfTrend == 1 ? 50.0 : 0.0) + (htfTrend == 1 ? 50.0 : 0.0)

marketPressureScore = (orderBookScore * 0.30) + (deltaScore * 0.25) + (volScore * 0.20) + (priceActionScore * 0.15) + (trendScore * 0.10)

pressureFilter = enablePressureScore ? marketPressureScore >= minPressureScore : true

// ============================================================
// STRATEGIC FILTERS
// ============================================================
isThursday     = dayofweek == dayofweek.thursday
thursdayFilter = filterThursday ? not isThursday : true

volFilterOK   = dVol >= minDailyVolume * 1e6
rangeFilterOK = dOpen != 0 ? (dRange / dOpen) >= minDailyRange : (dClose >= dOpen)

prevDayGapUp  = dPrevClose != 0 ? (dOpen - dPrevClose) / dPrevClose > 0.01 : false
gapPrevFilter = filterPrevGap ? not prevDayGapUp : true

allFilters = thursdayFilter and volFilterOK and rangeFilterOK and gapPrevFilter and orderBookFilter and pressureFilter

// ============================================================
// END-OF-DAY WINDOW
// ============================================================
closeInMinutes       = bistCloseHour * 60 + bistCloseMin
windowStartInMinutes = closeInMinutes - lookbackWindow
currentInMinutes     = hour * 60 + minute

isEndOfDayWindow = timeframe.isintraday ? (currentInMinutes >= windowStartInMinutes and currentInMinutes <= closeInMinutes) : false

// ============================================================
// MEMORY ENGINE
// ============================================================
var bool  persistentGapSetup = false
var float entryPrice         = na

isNewDay  = ta.change(time("D")) != 0
gapSignal = gapProb >= gapThreshold and delta > 0 and dailyFilter and allFilters

if isEndOfDayWindow and gapSignal
    persistentGapSetup := true
    entryPrice         := close

// ============================================================
// STOP LOSS LOGIC
// ============================================================
stopLossPrice = enableStopLoss and not na(entryPrice) ? entryPrice * (1.0 - stopLossPct / 100.0) : na

stopLossHit = enableStopLoss and persistentGapSetup and not na(stopLossPrice) and close < stopLossPrice

// ============================================================
// EXIT SIGNAL
// ============================================================
isMarketOpen = timeframe.isintraday and hour == 10 and minute < 30
sellTrigger  = isMarketOpen and persistentGapSetup[1]

if isNewDay or sellTrigger or stopLossHit
    persistentGapSetup := false
    entryPrice         := na

// ============================================================
// VISUAL SIGNALS
// ============================================================
buyColor  = color.rgb(0, 255, 120)
sellColor = color.rgb(255, 50, 50)
stopColor = color.rgb(255, 165, 0)

plotshape(persistentGapSetup and not persistentGapSetup[1],"Gap Entry", shape.labelup, location.belowbar,
     color=buyColor, text="BUY FOR GAP", textcolor=color.black, size=size.small)

plotshape(sellTrigger,
     "Gap Exit", shape.labeldown, location.abovebar,
     color=sellColor, text="SELL (TAKE PROFIT)", textcolor=color.white, size=size.small)

plotshape(stopLossHit,
     "Stop Loss", shape.labeldown, location.abovebar,
     color=stopColor, text="STOP LOSS", textcolor=color.black, size=size.small)

plot(persistentGapSetup and not na(stopLossPrice) ? stopLossPrice : na,
     "Stop Loss Level", color=stopColor, linewidth=2, style=plot.style_linebr)

// ============================================================
// DASHBOARD
// ============================================================
t_size = switch tableSizeInput
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.large

table_pos = switch tablePosInput
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    => position.bottom_left

neutralColor = color.rgb(30, 30, 30)
textCol      = color.white
bgSolid      = color.rgb(0, 0, 0)

var table dash = table.new(table_pos, 2, 16,
     bgcolor=bgSolid, frame_color=color.gray, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "METRIC",           text_color=textCol, text_size=t_size, bgcolor=color.rgb(50,50,50))
    table.cell(dash, 1, 0, "VALUE",            text_color=textCol, text_size=t_size, bgcolor=color.rgb(50,50,50))

    table.cell(dash, 0, 1, "Buy Vol",          text_color=textCol,  text_size=t_size)
    table.cell(dash, 1, 1, f_humanVol(buyVol), text_color=buyColor, text_size=t_size)

    table.cell(dash, 0, 2, "Sell Vol",           text_color=textCol,   text_size=t_size)
    table.cell(dash, 1, 2, f_humanVol(sellVol),  text_color=sellColor, text_size=t_size)

    table.cell(dash, 0, 3, "Delta",             text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 3, f_humanVol(delta),   text_color=delta > 0 ? buyColor : sellColor, text_size=t_size)

    table.cell(dash, 0, 4, "Daily Strength",    text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 4, dailyStrength ? "STRONG" : "WEAK", bgcolor=dailyStrength ? color.new(buyColor,30) : neutralColor, text_color=textCol, text_size=t_size)

    table.cell(dash, 0, 5, "Daily Delta",       text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 5, strongDailyDelta ? "POSITIVE" : "WEAK", bgcolor=strongDailyDelta ? color.new(buyColor,30) : neutralColor, text_color=textCol, text_size=t_size)

    table.cell(dash, 0, 6, "Limit Pressure",    text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 6, limitPressure ? "YES" : "NO", bgcolor=limitPressure ? color.new(buyColor,30) : neutralColor, text_color=textCol, text_size=t_size)

    table.cell(dash, 0, 7, "Gap Prob",          text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 7, str.tostring(gapProb) + "%", bgcolor=gapProb >= gapThreshold ? color.new(buyColor,40) : neutralColor, text_color=textCol, text_size=t_size)

    table.cell(dash, 0, 8, "RSI (14)",          text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 8, str.tostring(rsi, "#.#"), text_color=rsi > 70 ? sellColor : rsi > 55 ? buyColor : textCol, text_size=t_size)

    table.cell(dash, 0, 9, "HTF Trend",         text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 9, htfTrend == 1 ? "UP BULL" : "DOWN BEAR", text_color=htfTrend == 1 ? buyColor : sellColor, text_size=t_size)

    orderBookStatus = orderBookFilter ? "SAFE" : "HEAVY SELL"
    table.cell(dash, 0, 10, "Order Book",        text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 10, orderBookStatus + " (" + str.tostring(orderBookRatio, "#.#") + "x)", bgcolor=orderBookFilter ? color.new(buyColor,30) : color.new(sellColor,30), text_color=textCol, text_size=t_size)

    pressureColor = marketPressureScore >= 80 ? buyColor : marketPressureScore >= 60 ? color.yellow : marketPressureScore >= 40 ? color.orange : sellColor
    table.cell(dash, 0, 11, "Market Pressure",   text_color=textCol, text_size=t_size)
    table.cell(dash, 1, 11, str.tostring(marketPressureScore, "#") + "%", bgcolor=color.new(pressureColor, 70), text_color=pressureColor, text_size=t_size)

    table.cell(dash, 0, 12, "OB Score",          text_color=color.gray, text_size=t_size)
    table.cell(dash, 1, 12, str.tostring(orderBookScore, "#") + "%", text_color=orderBookScore >= 70 ? buyColor : color.gray, text_size=t_size)

    table.cell(dash, 0, 13, "Delta Score",       text_color=color.gray, text_size=t_size)
    table.cell(dash, 1, 13, str.tostring(deltaScore, "#") + "%", text_color=deltaScore >= 70 ? buyColor : color.gray, text_size=t_size)

    table.cell(dash, 0, 14, "Stop Loss",         text_color=textCol, text_size=t_size)
    slText = not na(entryPrice) and not na(stopLossPrice) ? str.tostring((close - stopLossPrice) / close * 100, "#.##") + "%" : "N/A"
    table.cell(dash, 1, 14, slText, bgcolor=stopLossHit ? color.new(stopColor,30) : neutralColor, text_color=stopLossHit ? stopColor : textCol, text_size=t_size)

    overnightText = persistentGapSetup ? "SIGNAL READY" : isEndOfDayWindow ? "CHECKING... " + str.tostring(gapProb) + "%" : "WAITING FOR WINDOW"
    overnightBg   = persistentGapSetup ? buyColor : isEndOfDayWindow ? color.rgb(60, 60, 0) : color.rgb(50, 50, 50)
    overnightTxt  = persistentGapSetup ? color.black : isEndOfDayWindow ? color.yellow : color.gray

    table.cell(dash, 0, 15, "OVERNIGHT",         text_color=color.yellow, text_size=t_size, bgcolor=color.rgb(40,40,40))
    table.cell(dash, 1, 15, overnightText,       bgcolor=overnightBg, text_color=overnightTxt, text_size=t_size)

// ============================================================
// ALERTS
// ============================================================
if isEndOfDayWindow and gapSignal and barstate.isconfirmed
    alert("GAP BUY: " + syminfo.ticker + " | Prob: " + str.tostring(gapProb) + "%" + " | Pressure: " + str.tostring(marketPressureScore, "#") + "%", alert.freq_once_per_bar)

if sellTrigger and barstate.isconfirmed
    alert("GAP SELL: " + syminfo.ticker, alert.freq_once_per_bar)

if stopLossHit and barstate.isconfirmed
    alert("STOP LOSS HIT: " + syminfo.ticker, alert.freq_once_per_bar)
````
