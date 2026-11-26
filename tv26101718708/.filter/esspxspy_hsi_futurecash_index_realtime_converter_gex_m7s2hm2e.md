# ES/SPX/SPY & HSI Future/Cash Index Realtime converter + GEX

- url: https://www.tradingview.com/script/M7S2hm2e-ES-SPX-SPY-HSI-Future-Cash-Index-Realtime-converter-GEX/
- type: indicator
- pine_id: PUB;fead143da7f84ac0afbcbf7c5333b0bc
- version: 3.0

## Description

This script is designed for traders who monitor Gamma Exposure (GEX) levels on cash indices (SPX, HSI) but execute trades on their respective Futures (ES, HSI!) or ETFs (SPY).

Because of the "Basis" (the price difference caused by interest rates and dividends), cash levels and futures prices do not align perfectly. This indicator solves that problem by calculating the real-time basis and automatically mapping your GEX levels to your current chart.

[b]🚀 Key Features[/b]
[list]
[*]Real-Time Basis Calculation: Automatically calculates the spread between Futures and Cash for both the S&P 500 and the Hang Seng Index.
[*]Dynamic GEX Mapping: Input your daily Call Wall, Put Wall, and Zero Gamma levels for the cash index, and the script will plot them at the mathematically correct price on your Futures chart.
[*]Dual-Price Labels: Labels display both the original Cash level and the converted "Futures Equivalent" price for instant clarity.
[/list]
Multi-Asset Support: 
[list]
[*]US Market: ES (Futures), SPX (Index), and SPY (ETF).
[*]HK Market: HSI (Index) and HSI! (Futures).
[/list]
Integrated Dashboard:
[list]
[*]Showing Current Basis (+/- points).
[*]Estimated SPX/SPY prices during non-RTH hours.
[*]US20Y Yield Monitor: Includes a warning emoji if bond yields cross the 5% threshold.
[*]Price Mapping Table: A quick-reference table showing cash levels in 50/100 point increments and their corresponding futures prices.
[/list]
[b]🛠️ How to Use[/b]
[list=1]
[*]Inputs: Every morning, update the SPX GEX Levels or HSI GEX Levels in the settings with data from your preferred gamma provider.
[*]Date Monitor: Set the GEX Data Date. If you forget to update your levels the next day, a large watermark will appear to warn you that the data is expired.
[*]UI Customization: You can move the Info Board and Levels Table to any corner of your screen to avoid cluttering your specific chart layout.
[/list]
[b]📊 Technical Details[/b]
[list]
[*]Pine Script® v6: Built using the latest version for maximum performance and stability.
[*]Sync Logic: Uses request.security to pull data from multiple tickers simultaneously, ensuring the basis calculation is always based on the most recent available tick.
[/list]

[b]Disclaimer[/b]: This indicator is a tool for visual mapping and data organization. It does not provide financial advice or automated signals. GEX levels must be sourced and input manually by the user.

## Source Code

````pine
//@version=6
indicator("ES/SPX & HSI + GEX", overlay=true)

// ==========================================
// 1. Symbol Recognition & Filtering
// ==========================================
isES  = syminfo.root == "ES" or str.contains(syminfo.ticker, "ES1!")
isSPX = syminfo.ticker == "SPX" or syminfo.ticker == "SPX500" or syminfo.ticker == "US500" or str.contains(syminfo.ticker, "SPX500")
isSPY = syminfo.ticker == "SPY"
isSPX_Group = isES or isSPX or isSPY

isHSI_Cash = syminfo.ticker == "HSI" or str.contains(syminfo.ticker, "HK33") or str.contains(syminfo.ticker, "HK50")
isHSI_Future = (syminfo.root == "HSI" or str.startswith(syminfo.ticker, "HSI")) and not isHSI_Cash
isHSI_Group = isHSI_Cash or isHSI_Future

canShow = isSPX_Group or isHSI_Group

// ==========================================
// 2. UI & Display Settings 
// ==========================================
grp_ui = "UI Position Settings"
posInfo = input.string(position.top_right, "Info Board Position", options=[position.top_right, position.top_left, position.top_center, position.bottom_right, position.bottom_left, position.bottom_center, position.middle_right, position.middle_left], group=grp_ui)
posLevels = input.string(position.bottom_right, "Levels Table Position", options=[position.top_right, position.top_left, position.top_center, position.bottom_right, position.bottom_left, position.bottom_center, position.middle_right, position.middle_left], group=grp_ui)

// ==========================================
// 3. GEX Data Inputs (Multiple Values Supported)
// ==========================================
grp_gex_spx = "SPX GEX Levels"
callWallSpxStr = input.string("6605, 6650", "SPX Call Walls (Comma separated)", group=grp_gex_spx)
putWallSpxStr  = input.string("6500, 6450", "SPX Put Walls (Comma separated)", group=grp_gex_spx)
zeroGammaSPX   = input.float(6554.8, "SPX Zero Gamma", group=grp_gex_spx)

grp_gex_hsi = "HSI GEX Levels"
callWallHsiStr = input.string("24600,25800,26000", "HSI Call Walls (Comma separated)", group=grp_gex_hsi, display=display.none)
putWallHsiStr  = input.string("24000, 23800,23200,23000", "HSI Put Walls (Comma separated)", group=grp_gex_hsi, display=display.none)
zeroGammaHSI   = input.float(24300.0, "HSI Zero Gamma", group=grp_gex_hsi)

grp_time = "Data Expiration Monitor"
showGexLines = input.bool(true, "Show GEX Lines", group=grp_time)
dataDate = input.time(timestamp("2026-04-06 00:00"), "GEX Data Date", group=grp_time, tooltip="Set to current date. Warns if expired.")

// 🌟 NEW: Data Sources Configuration
grp_src = "Underlying Data Sources (Bypass Delays)"
src_spx = input.symbol("SPX", "SPX Index Source (Use TVC:SPX or OANDA:SPX500USD for real-time)", group=grp_src, display=display.none)
src_spy = input.symbol("SPY", "SPY Source", group=grp_src, display=display.none)
src_hsi = input.symbol("HSI", "HSI Index Source (Use HSI1! or OANDA:HK33HKD for real-time)", group=grp_src, display=display.none)
src_us20y = input.symbol("US20Y", "US20Y Source", group=grp_src, display=display.none)

// Expiration Check Logic (Timezone Adaptive)
string tz = isHSI_Group ? "Asia/Hong_Kong" : "America/New_York"
curYear = year(timenow, tz), curMonth = month(timenow, tz), curDay = dayofmonth(timenow, tz)
dYear = year(dataDate, tz), dMonth = month(dataDate, tz), dDay = dayofmonth(dataDate, tz)
isExpired = (curYear != dYear) or (curMonth != dMonth) or (curDay != dDay)

// ==========================================
// 4. Core Data Engine & Timers
// ==========================================
float raw_spx = isSPX_Group ? close : request.security(src_spx, timeframe.period, close)
float raw_spy = isSPY ? close : request.security(src_spy, timeframe.period, close)
float raw_hsi = isHSI_Cash ? close : request.security(src_hsi, timeframe.period, close)
float raw_us20y = request.security(src_us20y, timeframe.period, close)

var float safe_spx = na
safe_spx := not na(raw_spx) ? raw_spx : safe_spx

var float safe_spy = na
safe_spy := not na(raw_spy) ? raw_spy : safe_spy

var float safe_hsi = na
safe_hsi := not na(raw_hsi) ? raw_hsi : safe_hsi

var float safe_us20y = na
safe_us20y := not na(raw_us20y) ? raw_us20y : safe_us20y

isRTH_US_Cash = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))
isRTH_HK_Cash = not na(time(timeframe.period, "0930-1200,1300-1600:23456", "Asia/Hong_Kong"))
isRTH_HK_Fut  = not na(time(timeframe.period, "0915-1200,1300-1630:23456", "Asia/Hong_Kong"))

bool isCashOpen = isHSI_Group ? isRTH_HK_Cash : isRTH_US_Cash
bool isFutRTH   = isHSI_Group ? isRTH_HK_Fut : isRTH_US_Cash

// ==========================================
// 5. Basis Calculation & Price Mapping (读写分离架构)
// ==========================================
float currentCash = isHSI_Group ? safe_hsi : safe_spx

var float lockedFut = na
var float lockedCash = na
var float lockedSpy = na

if isFutRTH and barstate.isconfirmed
    lockedFut  := close
    lockedCash := currentCash
    lockedSpy  := safe_spy

float finalLockedFut  = nz(lockedFut, close)
float finalLockedCash = nz(lockedCash, currentCash)
float finalLockedSpy  = nz(lockedSpy, safe_spy)

float live_basis = isFutRTH ? (close - currentCash) : (finalLockedFut - finalLockedCash)

var float stable_basis = na
if barstate.isconfirmed or na(stable_basis)
    stable_basis := live_basis

float displayIndex = isCashOpen ? currentCash : (close - stable_basis)

float spyRatio = finalLockedSpy != 0 ? (finalLockedCash / finalLockedSpy) : 10.0
float displaySPY = isCashOpen ? safe_spy : (displayIndex / spyRatio)

int step = isHSI_Group ? 100 : 50
var float stable_anchor = na
if barstate.isconfirmed or na(stable_anchor)
    stable_anchor := math.floor(displayIndex / step) * step

// ==========================================
// 6. GEX Lines Mapping (Dual Price Display)
// ==========================================
f_parse_levels(string _str) =>
    float[] _arr = array.new_float()
    string[] _parts = str.split(_str, ",")
    if array.size(_parts) > 0
        for _p in _parts
            string _match = str.match(_p, "\\d+(\\.\\d+)?")
            if not na(_match)
                array.push(_arr, str.tonumber(_match))
    _arr

float[] targetCallArr = isHSI_Group ? f_parse_levels(callWallHsiStr) : f_parse_levels(callWallSpxStr)
float[] targetPutArr  = isHSI_Group ? f_parse_levels(putWallHsiStr)  : f_parse_levels(putWallSpxStr)
float targetZero      = isHSI_Group ? zeroGammaHSI : zeroGammaSPX

int oneWeekAgoTime = timenow - (7 * 24 * 60 * 60 * 1000)

var line[] lineCalls = array.new_line()
var label[] lblCalls = array.new_label()
var line[] linePuts  = array.new_line()
var label[] lblPuts  = array.new_label()

var line lineZero = line.new(na, na, na, na, xloc.bar_time, extend.right, color.new(color.gray, 20), line.style_solid, 2)
var label lblZero = label.new(na, na, "", xloc.bar_time, yloc.price, color.new(color.gray, 100), label.style_label_left, color.gray, size.small)

if barstate.islast and canShow and showGexLines
    if array.size(lineCalls) > 0
        for i = 0 to array.size(lineCalls) - 1
            line.delete(array.get(lineCalls, i))
            label.delete(array.get(lblCalls, i))
    array.clear(lineCalls)
    array.clear(lblCalls)
    
    if array.size(linePuts) > 0
        for i = 0 to array.size(linePuts) - 1
            line.delete(array.get(linePuts, i))
            label.delete(array.get(lblPuts, i))
    array.clear(linePuts)
    array.clear(lblPuts)

    if array.size(targetCallArr) > 0
        for i = 0 to array.size(targetCallArr) - 1
            float targetVal = array.get(targetCallArr, i)
            float drawVal = targetVal + ((isES or isHSI_Future) ? stable_basis : 0)
            array.push(lineCalls, line.new(oneWeekAgoTime, drawVal, time, drawVal, xloc.bar_time, extend.right, color.new(color.green, 20), line.style_solid, 2))
            array.push(lblCalls, label.new(time, drawVal, "Call Wall (" + str.tostring(targetVal, "#") + ", " + str.tostring(drawVal, "#.00") + ")", xloc.bar_time, yloc.price, color.new(color.green, 100), label.style_label_left, color.green, size.small))

    if array.size(targetPutArr) > 0
        for i = 0 to array.size(targetPutArr) - 1
            float targetVal = array.get(targetPutArr, i)
            float drawVal = targetVal + ((isES or isHSI_Future) ? stable_basis : 0)
            array.push(linePuts, line.new(oneWeekAgoTime, drawVal, time, drawVal, xloc.bar_time, extend.right, color.new(color.red, 20), line.style_solid, 2))
            array.push(lblPuts, label.new(time, drawVal, "Put Wall (" + str.tostring(targetVal, "#") + ", " + str.tostring(drawVal, "#.00") + ")", xloc.bar_time, yloc.price, color.new(color.red, 100), label.style_label_left, color.red, size.small))

    float drawZero = targetZero + ((isES or isHSI_Future) ? stable_basis : 0)
    line.set_xy1(lineZero, oneWeekAgoTime, drawZero)
    line.set_xy2(lineZero, time, drawZero)
    label.set_xy(lblZero, time, drawZero)
    label.set_text(lblZero, "Zero Gamma (" + str.tostring(targetZero, "#.00") + ", " + str.tostring(drawZero, "#.00") + ")")

// ==========================================
// 7. Tables & Visual Dashboard
// ==========================================
if canShow
    string idxName = isHSI_Group ? "HSI" : "SPX"
    
    var table infoTable = table.new(posInfo, 2, 4, border_width=1)
    if barstate.islast
        table.cell(infoTable, 0, 0, isExpired ? "⚠️ EXPIRED" : "✅ LIVE", bgcolor=isExpired ? color.red : color.green, text_color=color.white)
        table.cell(infoTable, 1, 0, idxName + " Data", bgcolor=isExpired ? color.red : color.green, text_color=color.white)
        
        string basisSign = stable_basis >= 0 ? "+" : ""
        string indexDisplayStr = str.tostring(displayIndex, "#.00") + " (" + basisSign + str.tostring(stable_basis, "#.00") + ")"
        
        table.cell(infoTable, 0, 1, isCashOpen ? idxName : idxName + " (Est)", bgcolor=color.gray, text_color=color.white)
        table.cell(infoTable, 1, 1, indexDisplayStr, bgcolor=color.gray, text_color=isCashOpen ? color.white : color.yellow)
        
        if isSPX_Group
            table.cell(infoTable, 0, 2, isCashOpen ? "SPY" : "SPY (Est)", bgcolor=color.gray, text_color=color.white)
            table.cell(infoTable, 1, 2, str.tostring(displaySPY, "#.00"), bgcolor=color.gray, text_color=isCashOpen ? color.white : color.yellow)
            
        bool isYieldHigh = safe_us20y > 5.0
        string yieldStr = str.tostring(safe_us20y, "#.000") + "%" + (isYieldHigh ? " ⚠️" : "")
        color yieldColor = isYieldHigh ? color.red : (isFutRTH ? color.white : color.yellow)
        table.cell(infoTable, 0, 3, "US20Y", bgcolor=color.gray, text_color=color.white)
        table.cell(infoTable, 1, 3, yieldStr, bgcolor=color.gray, text_color=yieldColor)

    var table levelTable = table.new(posLevels, 2, 10, border_width=1, frame_color=color.gray)
    
    if barstate.islast
        table.cell(levelTable, 0, 0, idxName + " Levels", bgcolor=color.new(color.blue, 30), text_color=color.white)
        table.cell(levelTable, 1, 0, "Futures Eq.", bgcolor=color.new(color.orange, 30), text_color=color.white)
        for i = 0 to 8
            float tIdx = (stable_anchor - (4 * step)) + (i * step)
            float tFut = tIdx + stable_basis
            bool isNearest = math.abs(tIdx - displayIndex) < (step/2)
            color cellBg = isNearest ? color.new(color.black, 70) : color.new(color.black, 20)
            table.cell(levelTable, 0, i+1, str.tostring(tIdx), bgcolor=cellBg, text_color=color.white)
            table.cell(levelTable, 1, i+1, str.tostring(tFut, "#.00"), bgcolor=cellBg, text_color=color.yellow)

    if barstate.islast and isExpired
        var table warnTable = table.new(position.middle_center, 1, 1)
        table.cell(warnTable, 0, 0, "GEX DATA EXPIRED\nPLEASE UPDATE DATE", text_size=size.huge, text_color=color.new(color.red, 70))
````
