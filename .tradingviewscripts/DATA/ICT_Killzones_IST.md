<!-- tradingview-pine-id: PUB;70a11757947b4ea095a3399dc9b4f647 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Killzones - IST

Source: https://www.tradingview.com/script/TDoJDz7U-OTS-FOREX-ICT-Killzones-Asian-london-newyork-IST-TIME/

## Description

This indicator marks ICT Killzone for every session automatically according to IST time. 

1. Asian = 05:30 AM – 07:30 AM	= Characterized by tight consolidation ranges and liquidity building. Focuses heavily on AUD, NZD, and JPY pairs.

2. London Open	= 11:30 AM – 02:30 PM = High volatility. This window often sweeps Asian range liquidity and establishes the high or low of the trading day.

3. New York Open = 04:30 PM – 06:30 PM = The most liquid window of the day as London and NY overlap. Subject to intense volatility from major US economic data releases (usually at 6:00 PM IST).

4. London Close = 07:30 PM – 09:30 PM = European institutional traders close out their daily positions, frequently resulting in price retracements or reversals away from daily extremes.

Feel free to use them and try our other indicators also

---

## Source Code

````pine
//@version=6
indicator("ICT Killzones - IST", "ICT KZ IST", overlay = true, max_boxes_count = 500)
// All sessions in this script are fixed to Indian Standard Time (Asia/Kolkata, UTC+5:30).
// Defaults below match the ICT windows supplied by the user while New York is observing daylight saving time.
// When New York returns to standard time, add one hour to each session in the Inputs tab.
const string IST = "Asia/Kolkata"
const string GROUP_SESSIONS = "Killzones (IST / GMT+5:30)"
const string GROUP_STYLE = "Style"
showAsia        = input.bool(true, "Show Asia", group = GROUP_SESSIONS)
asiaSession     = input.session("0530-0730", "Asia KZ", group = GROUP_SESSIONS)
showLondon      = input.bool(true, "Show London", group = GROUP_SESSIONS)
londonSession   = input.session("1130-1430", "London Open KZ", group = GROUP_SESSIONS)
showNyAm        = input.bool(true, "Show New York AM", group = GROUP_SESSIONS)
nyAmSession     = input.session("1630-1830", "New York Open KZ", group = GROUP_SESSIONS)
showLondonClose = input.bool(true, "Show London Close", group = GROUP_SESSIONS)
londonCloseSession = input.session("1930-2130", "London Close KZ", group = GROUP_SESSIONS)
showNames  = input.bool(true, "Show session names", group = GROUP_STYLE)
opacity    = input.int(88, "Box transparency", minval = 0, maxval = 100, group = GROUP_STYLE)
asiaColor  = input.color(color.rgb(66, 133, 244), "Asia", group = GROUP_STYLE)
londonColor = input.color(color.rgb(156, 39, 176), "London", group = GROUP_STYLE)
nyAmColor  = input.color(color.rgb(0, 150, 136), "New York AM", group = GROUP_STYLE)
londonCloseColor = input.color(color.rgb(255, 193, 7), "London Close", group = GROUP_STYLE)
// Killzone times are meaningful only on intraday charts. The fixed IST timezone keeps
// the windows independent from the chart's selected timezone.
isIntraday = timeframe.isintraday
asiaActive = isIntraday and not na(time(timeframe.period, asiaSession, IST))
londonActive = isIntraday and not na(time(timeframe.period, londonSession, IST))
nyAmActive = isIntraday and not na(time(timeframe.period, nyAmSession, IST))
londonCloseActive = isIntraday and not na(time(timeframe.period, londonCloseSession, IST))
newAsia = asiaActive and not asiaActive[1]
newLondon = londonActive and not londonActive[1]
newNyAm = nyAmActive and not nyAmActive[1]
newLondonClose = londonCloseActive and not londonCloseActive[1]
var box asiaBox = na
var box londonBox = na
var box nyAmBox = na
var box londonCloseBox = na
if showAsia and newAsia
    asiaBox := box.new(bar_index, high, bar_index, low, border_color = asiaColor, bgcolor = color.new(asiaColor, opacity))
    if showNames
        box.set_text(asiaBox, "Asia\nIST")
        box.set_text_color(asiaBox, asiaColor)
        box.set_text_size(asiaBox, size.small)
        box.set_text_halign(asiaBox, text.align_left)
if showAsia and asiaActive and not na(asiaBox)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, math.max(box.get_top(asiaBox), high))
    box.set_bottom(asiaBox, math.min(box.get_bottom(asiaBox), low))
if showLondon and newLondon
    londonBox := box.new(bar_index, high, bar_index, low, border_color = londonColor, bgcolor = color.new(londonColor, opacity))
    if showNames
        box.set_text(londonBox, "London\nIST")
        box.set_text_color(londonBox, londonColor)
        box.set_text_size(londonBox, size.small)
        box.set_text_halign(londonBox, text.align_left)
if showLondon and londonActive and not na(londonBox)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, math.max(box.get_top(londonBox), high))
    box.set_bottom(londonBox, math.min(box.get_bottom(londonBox), low))
if showNyAm and newNyAm
    nyAmBox := box.new(bar_index, high, bar_index, low, border_color = nyAmColor, bgcolor = color.new(nyAmColor, opacity))
    if showNames
        box.set_text(nyAmBox, "New York Open\nIST")
        box.set_text_color(nyAmBox, nyAmColor)
        box.set_text_size(nyAmBox, size.small)
        box.set_text_halign(nyAmBox, text.align_left)
if showNyAm and nyAmActive and not na(nyAmBox)
    box.set_right(nyAmBox, bar_index)
    box.set_top(nyAmBox, math.max(box.get_top(nyAmBox), high))
    box.set_bottom(nyAmBox, math.min(box.get_bottom(nyAmBox), low))
if showLondonClose and newLondonClose
    londonCloseBox := box.new(bar_index, high, bar_index, low, border_color = londonCloseColor, bgcolor = color.new(londonCloseColor, opacity))
    if showNames
        box.set_text(londonCloseBox, "London Close\nIST")
        box.set_text_color(londonCloseBox, londonCloseColor)
        box.set_text_size(londonCloseBox, size.small)
        box.set_text_halign(londonCloseBox, text.align_left)
if showLondonClose and londonCloseActive and not na(londonCloseBox)
    box.set_right(londonCloseBox, bar_index)
    box.set_top(londonCloseBox, math.max(box.get_top(londonCloseBox), high))
    box.set_bottom(londonCloseBox, math.min(box.get_bottom(londonCloseBox), low))
// Create TradingView alerts from the indicator's Alerts menu after adding it to a chart.
alertcondition(showAsia and newAsia, "Asia Killzone begins (IST)", "ICT Asia Killzone has begun — IST")
alertcondition(showLondon and newLondon, "London Killzone begins (IST)", "ICT London Killzone has begun — IST")
alertcondition(showNyAm and newNyAm, "New York Open Killzone begins (IST)", "ICT New York Open Killzone has begun - IST")
alertcondition(showLondonClose and newLondonClose, "London Close Killzone begins (IST)", "ICT London Close Killzone has begun — IST")
````
