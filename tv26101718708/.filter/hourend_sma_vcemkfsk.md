# Hour-End SMA

- url: https://www.tradingview.com/script/VCeMkFSK-Hour-End-SMA/
- type: indicator
- pine_id: PUB;a867bee498674145968a0d177be9ebba
- version: 3.0

## Description

Calculates a Simple Moving Average using TRUE RTH hour-end prices.
Uses 30-minute bars to derive hour-end "LAST" prices

## Source Code

````pine
//@version=6
//-----------------------------------------------------------------------------
//  RTH True Hour-End SMA (30m base)
//-----------------------------------------------------------------------------
//  Calculates a Simple Moving Average using TRUE RTH hour-end prices
//  (10:00–16:00 ET), even when TradingView's 1H RTH candles are misaligned.
//
//  - Uses 30-minute bars to derive hour-end "LAST" prices
//  - Matches TC2000-style RTH hour-end SMA values
//  - Works on any chart timeframe
//  - Chart timezone independent (anchored to New York RTH)
//-----------------------------------------------------------------------------
//
//  Author: skywalkerhim MAVR
//  Version: 1.3 (Pine v6)
//-----------------------------------------------------------------------------
indicator("Hour-End SMA", overlay=true, format=format.price, precision=2, max_labels_count=500, max_bars_back=5000)

//=============================================================================
// Inputs
//=============================================================================
refSymInput   = input.string("", "Reference Symbol (blank = chart symbol)", display = display.data_window)
refSym        = refSymInput == "" ? syminfo.tickerid : refSymInput

len           = input.int(20, "SMA Length", minval=1)
col           = input.color(color.white, "SMA Color")
lineW         = input.int(2, "Line width", minval=1, maxval=5, display = display.data_window)
offsetBars    = input.int(0, "Offset (bars)", minval=-200, maxval=200, display = display.data_window)

showPriceLine = input.bool(false, "Show SMA Price Line (dotted)")
resetDaily    = input.bool(false, "Reset SMA each day at RTH open (09:30 ET)")

// Debug toggles (OFF by default)
showLabels    = input.bool(false, "Debug: show hour-end labels (1H custom only)", display = display.data_window)
showDots      = input.bool(false, "Debug: show hour-end last dots (1H custom only)", display = display.data_window)
maxLabDay     = input.int(12, "Debug: max labels per day", minval=0, maxval=30, active = showLabels, display = display.data_window)

//=============================================================================
// Constants
//=============================================================================
const string TZ = "America/New_York"

//=============================================================================
// Only apply custom logic on 1H charts. Otherwise, behave like default SMA.
//=============================================================================
is1H = timeframe.isminutes and timeframe.multiplier == 60

//=============================================================================
// Custom SMA computation on 30-minute stream (from refSym)
// Hour-end events based on CLOSE TIME of 30m bar: 10:00..16:00 ET
//=============================================================================
calcOn30m() =>
    tOpen  = time
    tClose = time_close

    hO = hour(tOpen, TZ)
    mO = minute(tOpen, TZ)

    hC = hour(tClose, TZ)
    mC = minute(tClose, TZ)

    // Daily reset at first RTH 30m bar open (09:30 ET)
    isRthStart = (hO == 9 and mO == 30)

    // Hour-end events: 10:00..16:00 ET (minute==0 on bar close)
    isHourEnd  = (mC == 0) and (hC >= 10) and (hC <= 16)

    // Rolling SMA state
    var float sum = 0.0
    var array<float> q = array.new_float()

    // Held outputs
    var float smaHeld    = na
    var float lastUsed   = na
    var int   lastUsedT  = na

    if resetDaily and isRthStart
        sum := 0.0
        array.clear(q)
        smaHeld := na
        lastUsed := na
        lastUsedT := na

    if isHourEnd
        evtPx = close
        evtT  = tClose

        lastUsed  := evtPx
        lastUsedT := evtT

        array.push(q, evtPx)
        sum += evtPx

        if array.size(q) > len
            old = array.shift(q)
            sum -= old

        smaHeld := sum / array.size(q)

    // carry forward between hour-end events
    smaHeld   := na(smaHeld)   ? smaHeld[1]   : smaHeld
    lastUsed  := na(lastUsed)  ? lastUsed[1]  : lastUsed
    lastUsedT := na(lastUsedT) ? lastUsedT[1] : lastUsedT

    evtF = isHourEnd ? 1 : 0
    [smaHeld, lastUsed, lastUsedT, evtF]

// Pull from reference symbol at 30-minute resolution
[sma_30m, lastUsed_30m, lastUsedT_30m, evtF_30m] = request.security(refSym, "30", calcOn30m(), barmerge.gaps_off, barmerge.lookahead_off)

// Default SMA (for all non-1H timeframes)
sma_default = ta.sma(close, len)

// Final plotted value: custom on 1H, default otherwise
sma_final = is1H ? sma_30m : sma_default

//=============================================================================
// Plot (continuous line default)
// trackprice OFF by default; user can enable via input.
//=============================================================================
plot(sma_final, title="SMA", linewidth=lineW, color=col, trackprice=showPriceLine, offset=offsetBars)

//=============================================================================
// Debug (ONLY on 1H custom mode)
// Dots hidden by default in Style using display.none.
//=============================================================================
isEvent = is1H and (evtF_30m == 1) and (lastUsed_30m != lastUsed_30m[1])

plot((showDots and isEvent) ? lastUsed_30m : na, title="Hour-End LAST (dot)", style=plot.style_circles, linewidth=4, display=display.none)

// Label rate limiting per NY day
dateKey  = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
dateKey1 = year(time[1], TZ) * 10000 + month(time[1], TZ) * 100 + dayofmonth(time[1], TZ)
newDay   = dateKey != dateKey1

var int labelsToday = 0
if newDay
    labelsToday := 0

if showLabels and isEvent and labelsToday < maxLabDay
    labelsToday += 1
    label.new( bar_index, lastUsed_30m, text  = "Used: " + str.tostring(lastUsed_30m, format.mintick) + "\n@ " + str.format("{0,date,HH:mm}", lastUsedT_30m) + "\nSMA(" + str.tostring(len) + "): " + str.tostring(sma_30m, format.mintick), style = label.style_label_left, textcolor=color.white, color=color.new(color.black, 0))
````
