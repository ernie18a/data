# NASDAQ Diamond Shot

- url: https://www.tradingview.com/script/I6GLWZQR/
- type: indicator
- pine_id: PUB;fb5863ba7a71421dbf0695dccc257b03
- version: 1.0

## Description

NASDAQ Diamond Shot is an elite, institutional-grade algorithmic indicator custom-engineered specifically for Nasdaq 100 (US100 / NQ) futures and CFD traders targeting the volatile New York session opening bell (09:30 AM EST) and ongoing session momentum.

    ⚡ Recommended Timeframe & Asset: Designed to perform best on timeframes of 15 minutes or higher (15m+) on US100 / Nasdaq. Using a 15-minute chart or higher effectively cuts through opening market noise, filtering out false signals while capturing high-probability institutional expansion moves with surgical precision.

    Features a flexible 1-Shot Mode toggle in the settings: keep it enabled for strict single-trade discipline per session, or disable it to catch multiple high-momentum expansion setups throughout the entire trading window.

    Key Features

        Nasdaq Optimized: Calibrated to match the volatility profile of the US100 index during the New York session.

        Minimum 15m Recommended: Performs exceptionally well from the 15-minute timeframe upwards to ensure clean institutional execution and noise reduction.

        Flexible 1-Shot / Multi-Shot Mode: By default, restricts entries to one high-quality trade per session, but can be easily toggled off in settings to capture all qualifying momentum candles during session hours.

        NY Session Precision: Automatically locks onto the New York opening hours, filtering out dead zones and chop.

        Diamond Momentum Filter: Demands strict body dominance (default 60%+) combined with range expansion relative to the 24 SMA.

        Trend Alignment (DEMA 24): Integrates a 24-period Double Exponential Moving Average filter to ensure trades flow strictly with short-term institutional momentum.

        Clean Fractional Targets & Time Stop: Dynamically calculates an optimal fractional TP based on the trigger candle size and tracks performance over a strict bar window.

        Sleek Visuals & Alerts: Instant trade markers, live target projection lines, performance labels, and robust alert integration.

    How to Use

        Apply to US100 (Nasdaq) on a 15-minute (15m) or higher timeframe.

        Ensure your timezone is set to New York (America/New_York).

        Configure the 1-Shot Mode toggle in the settings based on whether you want a single session trade or multiple shots!

    Disclaimer: For educational and informational purposes only. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("NASDAQ Diamond Shot", overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500)

// --- SESSION PARAMETERS (NEW YORK) ---
i_startHour   = input.int(9, "Session Start Hour", minval=0, maxval=23, group="New York Session Hours")
i_startMinute = input.int(30, "Session Start Minute", minval=0, maxval=59, group="New York Session Hours")
i_endHour     = input.int(16, "Session End Hour", minval=0, maxval=23, group="New York Session Hours")
i_endMinute   = input.int(0, "Session End Minute", minval=0, maxval=59, group="New York Session Hours")
i_days        = input.string("23456", "Days of Week (2=Mon, ..., 6=Fri, 7=Sat, 1=Sun)", group="New York Session Hours")
i_tz          = input.string("America/New_York", "Timezone", group="New York Session Hours")

// --- TRADING MODE ---
i_oneShot     = input.bool(true, "1-Shot Mode (Limit to 1 trade per session)", group="Trading Mode", tooltip="If enabled, takes only the first valid candle per session. If disabled, takes all valid signals during session hours.")

// --- CANDLE CONDITIONS ---
i_minBodyPct  = input.float(60.0, "Min Body % of Total Range", minval=0.0, maxval=100.0, group="Candle Conditions")
i_maLength    = input.int(24, "Range Moving Average Period (SMA)", minval=1, group="Candle Conditions")
i_maxMult     = input.float(10.0, "Max Size Multiplier (SMA Range)", minval=1.0, maxval=10.0, step=0.1, group="Candle Conditions (Data Filter)")

// --- % SIZE FILTER ---
i_useMinPct   = input.bool(false, "Enable Min Candle Size in %", group="Min Range in % (from price)")
i_minPctSize  = input.float(0.08, "Min Range (High-Low) in %", minval=0.001, maxval=10.0, step=0.01, group="Min Range in % (from price)")

// --- DEMA 24 FILTER ---
i_useDema24   = input.bool(true, "Filter by DEMA 24 Alignment", group="DEMA 24 Filter")
i_demaLength  = input.int(24, "DEMA Period", minval=1, group="DEMA 24 Filter")

// --- TP & TIME PARAMETERS ---
i_tpRatio     = input.float(0.15, "TP Ratio (0.15 of candle size)", minval=0.01, maxval=1.0, step=0.01, group="Take Profit Management")
i_barsCount   = input.int(1, "Max Trade Duration Bars", minval=1, maxval=10, group="Take Profit Management", tooltip="Select 1 or 2 bars for trade duration")

i_showTable   = input.bool(false, "Show Info Panel on Chart", group="Info Panel")
i_showBg      = input.bool(true, "Highlight Session Hours on Chart", group="Appearance")
i_colorBg     = input.color(color.new(color.blue, 92), "Session Background Color", group="Appearance")

// --- SESSION & DAY CHECK ---
startStr = (i_startHour < 10 ? "0" : "") + str.tostring(i_startHour) + (i_startMinute < 10 ? "0" : "") + str.tostring(i_startMinute)
endStr   = (i_endHour < 10 ? "0" : "") + str.tostring(i_endHour) + (i_endMinute < 10 ? "0" : "") + str.tostring(i_endMinute)
sessionString = startStr + "-" + endStr + ":" + i_days

inSession = not na(time(timeframe.period, sessionString, i_tz))
isNewDay  = ta.change(time("D", i_tz)) != 0

// --- DAILY TRADE COUNTER ---
var int tradesToday = 0
if isNewDay
    tradesToday := 0

// --- DEMA CALCULATIONS ---
f_dema(src, length) =>
    e1 = ta.ema(src, length)
    e2 = ta.ema(e1, length)
    2 * e1 - e2

demaValue = f_dema(close, i_demaLength)

// --- CONDITION CALCULATIONS ---
candleRange = high - low
bodySize = math.abs(close - open)
bodyPct = candleRange > 0 ? (bodySize / candleRange) * 100.0 : 0.0
avgRange = ta.sma(candleRange, i_maLength)
candlePctSize = (candleRange / close) * 100.0

isMinCondition = (bodyPct >= i_minBodyPct) and (candleRange >= avgRange)
isNotTooBig    = candleRange <= (avgRange * i_maxMult)
isMinPctValid  = not i_useMinPct or (candlePctSize >= i_minPctSize)

isBullish      = close >= open
isDemaValid    = not i_useDema24 or (isBullish ? (close > demaValue) : (close < demaValue))

// Check condition considering 1-Shot mode
canTradeCheck  = not i_oneShot or (tradesToday == 0)
isTargetCandle = inSession and canTradeCheck and isMinCondition and isNotTooBig and isMinPctValid and isDemaValid

// --- ACTIVE TP STATE ---
var bool   isTradeActive = false
var float  activeEntry   = na
var float  activeTp      = na
var label  activeLabel   = na
var line   activeTpLine  = na
var bool   isTradeBull   = true
var int    tradeBarIndex = 0

// Monitor active trade based on selected bar count
if isTradeActive
    if not na(activeTpLine)
        line.set_x2(activeTpLine, bar_index)

    hitTp = isTradeBull ? (high >= activeTp) : (low <= activeTp)
    barsElapsed = bar_index - tradeBarIndex
    isTimeOut = barsElapsed >= i_barsCount

    if hitTp
        res = ((activeTp - activeEntry) / activeEntry) * 100
        if not isTradeBull
            res := ((activeEntry - activeTp) / activeEntry) * 100
            
        label.set_text(activeLabel, (isTradeBull ? "LONG" : "SHORT") + " - TP HIT ✅\nResult: +" + str.tostring(res, "#.##") + "%")
        label.set_color(activeLabel, color.navy)
        if not na(activeTpLine)
            line.set_extend(activeTpLine, extend.none)
        isTradeActive := false
    else if isTimeOut
        res = ((close - activeEntry) / activeEntry) * 100
        if not isTradeBull
            res := ((activeEntry - close) / activeEntry) * 100
            
        label.set_text(activeLabel, (isTradeBull ? "LONG" : "SHORT") + " - NO TP ❌\nResult: " + str.tostring(res, "#.##") + "%")
        label.set_color(activeLabel, color.maroon)
        if not na(activeTpLine)
            line.set_extend(activeTpLine, extend.none)
        isTradeActive := false

// --- SNIPER ENTRY / NEW SIGNAL ---
if isTargetCandle and not isTradeActive
    isTradeBull   := isBullish
    activeEntry   := close
    activeTp      := isBullish ? (close + candleRange * i_tpRatio) : (close - candleRange * i_tpRatio)
    isTradeActive := true
    tradeBarIndex := bar_index
    tradesToday   := tradesToday + 1 
    
    tpPercent = (candleRange * i_tpRatio / close) * 100
    labelText = (isBullish ? "NASDAQ LONG Diamond\nTP: " : "NASDAQ SHORT Diamond\nTP: ") + str.tostring(tpPercent, "#.##") + "%"
    
    activeLabel  := label.new(bar_index, isBullish ? low - (candleRange * 0.1) : high + (candleRange * 0.1), text=labelText, color=isBullish ? color.green : color.red, textcolor=color.white, style=isBullish ? label.style_label_up : label.style_label_down, size=size.normal)
    activeTpLine := line.new(bar_index, activeTp, bar_index, activeTp, color=isBullish ? color.green : color.red, width=2, extend=extend.right)

    alert("NASDAQ Diamond Shot Triggered!", alert.freq_once_per_bar)

// --- VISUALIZATION ---
bgcolor(i_showBg and inSession ? i_colorBg : na)
barcolor(isTargetCandle ? (isBullish ? color.lime : color.red) : na)
plot(i_useDema24 ? demaValue : na, title="DEMA 24", color=color.orange, linewidth=2)

// --- INFO PANEL ---
var label infoLabel = label.new(x=na, y=na, text="", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.black, textcolor=color.white)

if barstate.islast and i_showTable
    sStatus = inSession ? (not i_oneShot or tradesToday == 0 ? "ACTIVE (Waiting)" : "USED (1/1)") : "OUT OF SESSION"
    sRange  = str.tostring(candleRange / syminfo.mintick / 10, "#.1") + " pips"
    sAvg    = str.tostring(avgRange / syminfo.mintick / 10, "#.1") + " pips"
    sBody   = str.tostring(bodyPct, "#.1") + "%"
    sTp     = str.tostring((candleRange * i_tpRatio) / syminfo.mintick / 10, "#.1") + " pips"
    
    fullText = "STATUS: " + sStatus + "\n" +
               "Range: " + sRange + "\n" +
               "SMA(24): " + sAvg + "\n" +
               "Body: " + sBody + "\n" +
               "Target TP: " + sTp

    label.set_xy(infoLabel, bar_index, high)
    label.set_text(infoLabel, fullText)
    label.set_color(infoLabel, color.new(color.black, 20))

// --- ALERTS ---
alertcondition(isTargetCandle, title="NASDAQ Diamond Shot", message="Valid diamond momentum candle triggered on US100 during NY session.")
````
