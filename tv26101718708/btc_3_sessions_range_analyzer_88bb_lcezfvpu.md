# BTC 3 Sessions Range Analyzer [88BB]

- url: https://www.tradingview.com/script/LceZfvPu/
- type: indicator
- pine_id: PUB;073db563f0e84e4284d87caf1aac1ed2
- version: 1.0

## Description

BTC 3 Sessions Range Analyzer [88BB] is an intraday session range analysis tool designed for BTC traders who want to study how price behaves during the Asia, London, and US trading sessions.

The indicator tracks each session’s high, low, total range, candle body movement, average range, median range, and percentile-based volatility levels. It is built to help traders understand session behavior, compare historical volatility, and prepare more structured intraday trading plans.

This tool does not generate buy or sell signals.
It is a session statistics and range analysis tool.

Key Features

1. Three Major Trading Sessions

The indicator tracks:

Asia Session
London Session
US Session

Each session can be enabled or disabled individually from the settings panel.

2. Fully Selectable Timezone

The timezone is no longer limited to UTC+8.

Users can select from common global timezones and UTC offsets, including:

UTC-12 to UTC+14
Asia / Singapore
Asia / Kuala Lumpur
Asia / Shanghai
Asia / Taipei
Asia / Tokyo
Europe / London
Europe / Berlin
America / New York
America / Chicago
America / Los Angeles
Australia / Sydney

A custom timezone option is also available for users who want to manually enter a TradingView-supported timezone.

Default timezone: UTC+8

3. Session Range Boxes

The indicator can draw visual session boxes on the chart to show the high and low of each session.

This helps traders quickly identify:

Session high
Session low
Session range
Price expansion
Low-volatility sessions
High-volatility sessions
Breakout or compression behavior after a session ends

4. Current Session High / Low Lines

During an active session, the indicator can display the live session high and low.

This allows traders to observe whether BTC is still building range, expanding beyond the session high, or sweeping below the session low.

5. Historical Range Statistics

For each session, the dashboard calculates:

Current range
Average range
Median range
70% range level
85% range level
Average body size
Suggested TP reference zone
Suggested SL reference zone

These values are based on the selected historical lookback sessions.

6. TP / SL Reference Zones

The TP and SL values shown in the dashboard are statistical reference ranges based on historical session median range.

They are not entry signals and should not be used alone.

They are designed only to help traders estimate whether a target or stop distance is reasonable compared with historical BTC session volatility.

7. English / Chinese Language Support

The dashboard supports:

English
Chinese

Users can switch the display language directly from the settings.

8. No Repainting Design

This indicator does not use request.security() and does not rely on future data.

Completed session statistics are only calculated after the session ends.

How This Indicator Can Be Used

This tool can help traders answer questions such as:

How wide is the current Asia / London / US session range?
Is today’s BTC session range small, normal, active, or unusually volatile?
Is the current session already larger than its historical median?
Is BTC expanding after a compressed session?
Is the market too quiet for active trading?
Is the expected TP / SL distance reasonable compared with session volatility?
Which session usually gives better volatility for the selected BTC market?
Recommended Usage

This indicator is best used on lower intraday timeframes such as:

3-minute
5-minute
15-minute

Recommended market:

BTC perpetual futures
BTC spot markets
Other highly liquid BTC pairs

For best results, use normal candlestick charts.

Important Notes

This indicator is a volatility and session range study tool.

It does not predict price direction.
It does not provide financial advice.
It does not guarantee trading results.
It does not tell users when to buy or sell.

All trading decisions should be made with proper risk management, market structure analysis, liquidity context, position sizing, and personal trading rules.

Disclaimer

This script is provided for educational and analytical purposes only.

Trading involves risk.
Past session behavior does not guarantee future results.
Users are responsible for their own trading decisions.

Tags / Keywords

BTC, Bitcoin, Session Range, Asia Session, London Session, US Session, Intraday Range, Volatility, Range Analyzer, Timezone, 88BB, Session Statistics, Trading Session, Market Range, Crypto Trading Tool

## Source Code

````pine
//@version=6
indicator("BTC 3 Sessions Range Analyzer [88BB]", overlay=true, max_labels_count=500, max_boxes_count=500)

// 88BB BTC 3 Sessions Range Analyzer
// Default timezone: UTC+8. User can select global UTC offsets or use custom IANA timezone.
// Sessions: Asia, London, US.
// Dashboard position: bottom center.
// Language switch: English / Chinese.
// Recommended chart: BTCUSDT.P, normal candles, 3m or 5m.
// Anti-lookahead: no request.security(), no calc_on_order_fills, no lookahead.

//==============================
// Inputs
//==============================
lang = input.string("English", "Language / 语言", options=["English", "中文"])

tzPreset = input.string("UTC+8", "Timezone Preset / 时区预设", options=[
     "UTC-12", "UTC-11", "UTC-10", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1",
     "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+5:30", "UTC+6", "UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12", "UTC+13", "UTC+14",
     "Asia/Singapore", "Asia/Kuala_Lumpur", "Asia/Shanghai", "Asia/Taipei", "Asia/Tokyo", "Asia/Seoul",
     "Europe/London", "Europe/Berlin", "Europe/Paris",
     "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles",
     "Australia/Sydney", "Custom"])
tzCustom = input.string("Asia/Singapore", "Custom Timezone / 自定义时区")
tz = tzPreset == "Custom" ? tzCustom : tzPreset
lookback = input.int(60, "Lookback Sessions", minval=5, maxval=250)

asiaSess   = input.session("0800-1100", "Asia Session")
londonSess = input.session("1500-1800", "London Session")
usSess     = input.session("2130-2300", "US Session")

showAsia = input.bool(true, "Show Asia Session")
showLondon = input.bool(true, "Show London Session")
showUS = input.bool(true, "Show US Session")
showBoxes = input.bool(true, "Show Session Boxes")
showDash = input.bool(true, "Show Dashboard")
showCurrentLines = input.bool(true, "Show Current Session High/Low")

//==============================
// Text helper
//==============================
isCN = lang == "中文"

t_title     = isCN ? "88BB 三大盘 Range" : "88BB Sessions Range"
t_sample    = isCN ? "样本" : "Sample"
t_now       = isCN ? "当前" : "Now"
t_avg       = isCN ? "平均" : "Avg"
t_median    = isCN ? "中位数" : "Median"
t_p70       = isCN ? "70%波幅" : "70%"
t_p85       = isCN ? "85%波幅" : "85%"
t_body      = isCN ? "实体" : "Body"
t_tpsl      = isCN ? "TP/SL" : "TP/SL"
t_trade     = isCN ? "建议" : "Trade?"
t_asia      = isCN ? "亚洲盘" : "Asia"
t_london    = isCN ? "伦敦盘" : "London"
t_us        = isCN ? "美盘" : "US"
t_noData    = isCN ? "无资料" : "N/A"
t_low       = isCN ? "低波动" : "Low"
t_ok        = isCN ? "可观察" : "OK"
t_good      = isCN ? "适合做" : "Good"
t_hot       = isCN ? "高波动" : "Hot"
t_note      = isCN ? "说明" : "Guide"
t_lowGuide  = isCN ? "低<250" : "Low<250"
t_okGuide   = isCN ? "观察250-500" : "OK 250-500"
t_goodGuide = isCN ? "适合500-900" : "Good 500-900"
t_hotGuide  = isCN ? "高>900" : "Hot>900"
t_tpGuideTx = isCN ? "TP=中位35-60%" : "TP=35-60% Med"
t_slGuideTx = isCN ? "SL=中位18-30%" : "SL=18-30% Med"
t_levGuide  = isCN ? "100x小止损" : "100x small SL"
t_candle    = isCN ? "普通K线" : "Normal candles"
t_noRepaint = isCN ? "不重绘" : "No repaint"
t_points    = isCN ? " 点" : " pts"
t_tz        = isCN ? "时区" : "TZ"

//==============================
// Functions
//==============================
f_avg(arr) =>
    sz = array.size(arr)
    if sz == 0
        na
    else
        sum = 0.0
        for i = 0 to sz - 1
            sum += array.get(arr, i)
        sum / sz

f_median(arr) =>
    sz = array.size(arr)
    if sz == 0
        na
    else
        tmp = array.copy(arr)
        array.sort(tmp, order.ascending)
        mid = math.floor(sz / 2)
        sz % 2 == 1 ? array.get(tmp, mid) : (array.get(tmp, mid - 1) + array.get(tmp, mid)) / 2

f_pct(arr, p) =>
    sz = array.size(arr)
    if sz == 0
        na
    else
        tmp = array.copy(arr)
        array.sort(tmp, order.ascending)
        idx = math.max(0, math.min(sz - 1, math.round((sz - 1) * p)))
        array.get(tmp, idx)

f_push(arrR, arrB, r, b) =>
    array.unshift(arrR, r)
    array.unshift(arrB, b)
    if array.size(arrR) > lookback
        array.pop(arrR)
        array.pop(arrB)

f_score(medR) =>
    na(medR) ? t_noData :
     medR < 250 ? t_low :
     medR < 500 ? t_ok :
     medR < 900 ? t_good :
     t_hot

f_scoreColor(score) =>
    score == t_low ? color.red :
     score == t_ok ? color.orange :
     score == t_good ? color.lime :
     score == t_hot ? color.aqua :
     color.white

f_tpGuide(medR) =>
    na(medR) ? t_noData : str.tostring(medR * 0.35, "#") + "-" + str.tostring(medR * 0.60, "#")

f_slGuide(medR) =>
    na(medR) ? t_noData : str.tostring(medR * 0.18, "#") + "-" + str.tostring(medR * 0.30, "#")

//==============================
// Data arrays
//==============================
var float[] asiaRanges = array.new_float()
var float[] asiaBodies = array.new_float()
var float[] londonRanges = array.new_float()
var float[] londonBodies = array.new_float()
var float[] usRanges = array.new_float()
var float[] usBodies = array.new_float()

//==============================
// Asia Session
//==============================
inAsia = not na(time(timeframe.period, asiaSess, tz))
newAsia = inAsia and not inAsia[1]
endAsia = not inAsia and inAsia[1]

var float aH = na
var float aL = na
var float aO = na
var float aC = na
var int aStart = na

if newAsia
    aH := high
    aL := low
    aO := open
    aC := close
    aStart := bar_index

if inAsia
    aH := math.max(nz(aH, high), high)
    aL := math.min(nz(aL, low), low)
    aC := close

if endAsia and not na(aH) and not na(aL)
    r = aH - aL
    b = math.abs(aC - aO)
    f_push(asiaRanges, asiaBodies, r, b)
    if showBoxes and showAsia
        box.new(aStart, aH, bar_index[1], aL, bgcolor=color.new(color.blue, 91), border_color=color.new(color.blue, 25))
        label.new(bar_index[1], aH, t_asia + "\n" + str.tostring(r, "#") + t_points, style=label.style_label_down, color=color.new(color.blue, 0), textcolor=color.white)
    aH := na
    aL := na
    aO := na
    aC := na
    aStart := na

//==============================
// London Session
//==============================
inLondon = not na(time(timeframe.period, londonSess, tz))
newLondon = inLondon and not inLondon[1]
endLondon = not inLondon and inLondon[1]

var float lH = na
var float lL = na
var float lO = na
var float lC = na
var int lStart = na

if newLondon
    lH := high
    lL := low
    lO := open
    lC := close
    lStart := bar_index

if inLondon
    lH := math.max(nz(lH, high), high)
    lL := math.min(nz(lL, low), low)
    lC := close

if endLondon and not na(lH) and not na(lL)
    r = lH - lL
    b = math.abs(lC - lO)
    f_push(londonRanges, londonBodies, r, b)
    if showBoxes and showLondon
        box.new(lStart, lH, bar_index[1], lL, bgcolor=color.new(color.orange, 91), border_color=color.new(color.orange, 25))
        label.new(bar_index[1], lH, t_london + "\n" + str.tostring(r, "#") + t_points, style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.white)
    lH := na
    lL := na
    lO := na
    lC := na
    lStart := na

//==============================
// US Session
//==============================
inUS = not na(time(timeframe.period, usSess, tz))
newUS = inUS and not inUS[1]
endUS = not inUS and inUS[1]

var float uH = na
var float uL = na
var float uO = na
var float uC = na
var int uStart = na

if newUS
    uH := high
    uL := low
    uO := open
    uC := close
    uStart := bar_index

if inUS
    uH := math.max(nz(uH, high), high)
    uL := math.min(nz(uL, low), low)
    uC := close

if endUS and not na(uH) and not na(uL)
    r = uH - uL
    b = math.abs(uC - uO)
    f_push(usRanges, usBodies, r, b)
    if showBoxes and showUS
        box.new(uStart, uH, bar_index[1], uL, bgcolor=color.new(color.green, 91), border_color=color.new(color.green, 25))
        label.new(bar_index[1], uH, t_us + "\n" + str.tostring(r, "#") + t_points, style=label.style_label_down, color=color.new(color.green, 0), textcolor=color.white)
    uH := na
    uL := na
    uO := na
    uC := na
    uStart := na

//==============================
// Stats
//==============================
aAvg = f_avg(asiaRanges)
aMed = f_median(asiaRanges)
a70 = f_pct(asiaRanges, 0.70)
a85 = f_pct(asiaRanges, 0.85)
aBody = f_avg(asiaBodies)

lAvg = f_avg(londonRanges)
lMed = f_median(londonRanges)
l70 = f_pct(londonRanges, 0.70)
l85 = f_pct(londonRanges, 0.85)
lBody = f_avg(londonBodies)

uAvg = f_avg(usRanges)
uMed = f_median(usRanges)
u70 = f_pct(usRanges, 0.70)
u85 = f_pct(usRanges, 0.85)
uBody = f_avg(usBodies)

aScore = f_score(aMed)
lScore = f_score(lMed)
uScore = f_score(uMed)

currentAsiaR = inAsia and not na(aH) and not na(aL) ? aH - aL : na
currentLondonR = inLondon and not na(lH) and not na(lL) ? lH - lL : na
currentUSR = inUS and not na(uH) and not na(uL) ? uH - uL : na

//==============================
// Plots
//==============================
plot(showCurrentLines and showAsia and inAsia ? aH : na, "Asia High / 亚洲盘高点", color=color.new(color.blue, 0), style=plot.style_linebr, linewidth=2)
plot(showCurrentLines and showAsia and inAsia ? aL : na, "Asia Low / 亚洲盘低点", color=color.new(color.blue, 0), style=plot.style_linebr, linewidth=2)

plot(showCurrentLines and showLondon and inLondon ? lH : na, "London High / 伦敦盘高点", color=color.new(color.orange, 0), style=plot.style_linebr, linewidth=2)
plot(showCurrentLines and showLondon and inLondon ? lL : na, "London Low / 伦敦盘低点", color=color.new(color.orange, 0), style=plot.style_linebr, linewidth=2)

plot(showCurrentLines and showUS and inUS ? uH : na, "US High / 美盘高点", color=color.new(color.lime, 0), style=plot.style_linebr, linewidth=2)
plot(showCurrentLines and showUS and inUS ? uL : na, "US Low / 美盘低点", color=color.new(color.red, 0), style=plot.style_linebr, linewidth=2)

//==============================
// Dashboard
//==============================
var table d = table.new(position.bottom_center, 10, 6, border_width=1)

if showDash and barstate.islast
    table.cell(d, 0, 0, t_title, bgcolor=color.black, text_color=color.white)
    table.cell(d, 1, 0, t_sample, bgcolor=color.black, text_color=color.white)
    table.cell(d, 2, 0, t_now, bgcolor=color.black, text_color=color.white)
    table.cell(d, 3, 0, t_avg, bgcolor=color.black, text_color=color.white)
    table.cell(d, 4, 0, t_median, bgcolor=color.black, text_color=color.white)
    table.cell(d, 5, 0, t_p70, bgcolor=color.black, text_color=color.white)
    table.cell(d, 6, 0, t_p85, bgcolor=color.black, text_color=color.white)
    table.cell(d, 7, 0, t_body, bgcolor=color.black, text_color=color.white)
    table.cell(d, 8, 0, t_tpsl, bgcolor=color.black, text_color=color.white)
    table.cell(d, 9, 0, t_trade, bgcolor=color.black, text_color=color.white)

    table.cell(d, 0, 1, t_asia + "\n" + asiaSess, text_color=color.blue)
    table.cell(d, 1, 1, str.tostring(array.size(asiaRanges)), text_color=color.white)
    table.cell(d, 2, 1, na(currentAsiaR) ? "-" : str.tostring(currentAsiaR, "#"), text_color=color.yellow)
    table.cell(d, 3, 1, na(aAvg) ? t_noData : str.tostring(aAvg, "#"), text_color=color.white)
    table.cell(d, 4, 1, na(aMed) ? t_noData : str.tostring(aMed, "#"), text_color=color.lime)
    table.cell(d, 5, 1, na(a70) ? t_noData : str.tostring(a70, "#"), text_color=color.orange)
    table.cell(d, 6, 1, na(a85) ? t_noData : str.tostring(a85, "#"), text_color=color.orange)
    table.cell(d, 7, 1, na(aBody) ? t_noData : str.tostring(aBody, "#"), text_color=color.white)
    table.cell(d, 8, 1, f_tpGuide(aMed) + "/" + f_slGuide(aMed), text_color=color.white)
    table.cell(d, 9, 1, aScore, text_color=f_scoreColor(aScore))

    table.cell(d, 0, 2, t_london + "\n" + londonSess, text_color=color.orange)
    table.cell(d, 1, 2, str.tostring(array.size(londonRanges)), text_color=color.white)
    table.cell(d, 2, 2, na(currentLondonR) ? "-" : str.tostring(currentLondonR, "#"), text_color=color.yellow)
    table.cell(d, 3, 2, na(lAvg) ? t_noData : str.tostring(lAvg, "#"), text_color=color.white)
    table.cell(d, 4, 2, na(lMed) ? t_noData : str.tostring(lMed, "#"), text_color=color.lime)
    table.cell(d, 5, 2, na(l70) ? t_noData : str.tostring(l70, "#"), text_color=color.orange)
    table.cell(d, 6, 2, na(l85) ? t_noData : str.tostring(l85, "#"), text_color=color.orange)
    table.cell(d, 7, 2, na(lBody) ? t_noData : str.tostring(lBody, "#"), text_color=color.white)
    table.cell(d, 8, 2, f_tpGuide(lMed) + "/" + f_slGuide(lMed), text_color=color.white)
    table.cell(d, 9, 2, lScore, text_color=f_scoreColor(lScore))

    table.cell(d, 0, 3, t_us + "\n" + usSess, text_color=color.lime)
    table.cell(d, 1, 3, str.tostring(array.size(usRanges)), text_color=color.white)
    table.cell(d, 2, 3, na(currentUSR) ? "-" : str.tostring(currentUSR, "#"), text_color=color.yellow)
    table.cell(d, 3, 3, na(uAvg) ? t_noData : str.tostring(uAvg, "#"), text_color=color.white)
    table.cell(d, 4, 3, na(uMed) ? t_noData : str.tostring(uMed, "#"), text_color=color.lime)
    table.cell(d, 5, 3, na(u70) ? t_noData : str.tostring(u70, "#"), text_color=color.orange)
    table.cell(d, 6, 3, na(u85) ? t_noData : str.tostring(u85, "#"), text_color=color.orange)
    table.cell(d, 7, 3, na(uBody) ? t_noData : str.tostring(uBody, "#"), text_color=color.white)
    table.cell(d, 8, 3, f_tpGuide(uMed) + "/" + f_slGuide(uMed), text_color=color.white)
    table.cell(d, 9, 3, uScore, text_color=f_scoreColor(uScore))

    table.cell(d, 0, 5, t_note, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(d, 1, 5, t_lowGuide, text_color=color.red)
    table.cell(d, 2, 5, t_okGuide, text_color=color.orange)
    table.cell(d, 3, 5, t_goodGuide, text_color=color.lime)
    table.cell(d, 4, 5, t_hotGuide, text_color=color.aqua)
    table.cell(d, 5, 5, t_tpGuideTx, text_color=color.white)
    table.cell(d, 6, 5, t_slGuideTx, text_color=color.white)
    table.cell(d, 7, 5, t_levGuide, text_color=color.red)
    table.cell(d, 8, 5, t_tz + ": " + tz, text_color=color.white)
    table.cell(d, 9, 5, t_noRepaint, text_color=color.lime)
````
