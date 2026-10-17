# Forex Risk Calculator Pro

- url: https://www.tradingview.com/script/NeIlSvJr-Forex-Risk-Calculator-Pro/
- type: indicator
- pine_id: PUB;04fcb79248654bee83868295662eca91
- version: 5.0

## Description

Forex Risk Calculator Pro is a clean on-chart panel designed to provide a quick standardized lot size suggestion for Forex traders.

The indicator automatically detects the Forex pair currently opened on the chart and displays a suggested lot size based only on the account balance and the selected risk percentage.

It works only on Forex symbols recognized by TradingView. When applied to non-Forex markets, the panel will show that the tool is not applicable.

Key features:
• Automatic Forex pair detection
• Works with major, minor and exotic Forex pairs
• Account balance input
• Risk percentage input
• Standardized suggested lot size
• Clean on-chart panel
• Centered professional panel title
• Adjustable panel position
• Adjustable text size
• Customizable panel colors
• Forex-only filtering

Important:
This indicator provides a standardized lot size guide only. It does not calculate exact position sizing based on stop loss distance, broker commission, spread, slippage, swap, leverage, tick value or live broker conditions.

Always check your stop loss distance, broker costs and current market volatility before opening a trade.

This tool is intended for educational and planning purposes only and should not be considered financial advice.

## Source Code

````pine
//@version=6
indicator("Forex Risk & Session Dashboard", overlay = true)

groupRisk = "💰 Risk Settings"
groupSession = "🌍 Session Settings"
groupPanel = "🖥 Panel Settings"

accountBalance = input.float(5000, "Account Balance USD", minval = 1, step = 100, group = groupRisk)
riskPercent = input.float(0.5, "Risk per Trade %", minval = 0.01, step = 0.1, group = groupRisk, tooltip = "Attention! This is a standardized lot guide. Always check your SL distance, broker commission, spread, slippage and market volatility before opening a trade.")

displayTimezone = input.string("Europe/Bucharest", "Select Timezone", options = ["Etc/UTC", "Europe/London", "Europe/Dublin", "Europe/Lisbon", "Europe/Madrid", "Europe/Paris", "Europe/Amsterdam", "Europe/Brussels", "Europe/Berlin", "Europe/Zurich", "Europe/Rome", "Europe/Vienna", "Europe/Prague", "Europe/Warsaw", "Europe/Budapest", "Europe/Belgrade", "Europe/Zagreb", "Europe/Ljubljana", "Europe/Bratislava", "Europe/Bucharest", "Europe/Sofia", "Europe/Athens", "Europe/Helsinki", "Europe/Riga", "Europe/Tallinn", "Europe/Vilnius", "Europe/Chisinau", "Europe/Kyiv", "Europe/Istanbul", "Europe/Moscow", "Europe/Oslo", "Europe/Stockholm", "Europe/Copenhagen", "Europe/Malta", "Europe/Luxembourg", "Europe/Monaco", "Europe/Andorra", "Europe/Gibraltar", "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Phoenix", "America/Anchorage", "America/Adak", "America/Toronto", "America/Vancouver", "America/Winnipeg", "America/Edmonton", "America/Halifax", "America/St_Johns", "America/Mexico_City", "America/Monterrey", "America/Tijuana", "America/Guatemala", "America/Panama", "America/Bogota", "America/Lima", "America/Caracas", "America/La_Paz", "America/Santiago", "America/Argentina/Buenos_Aires", "America/Montevideo", "America/Sao_Paulo", "America/Asuncion", "America/Havana", "America/Jamaica", "America/Puerto_Rico", "Asia/Tokyo", "Asia/Seoul", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Taipei", "Asia/Singapore", "Asia/Kuala_Lumpur", "Asia/Manila", "Asia/Bangkok", "Asia/Jakarta", "Asia/Ho_Chi_Minh", "Asia/Yangon", "Asia/Kolkata", "Asia/Kathmandu", "Asia/Dhaka", "Asia/Karachi", "Asia/Kabul", "Asia/Dubai", "Asia/Muscat", "Asia/Qatar", "Asia/Bahrain", "Asia/Kuwait", "Asia/Riyadh", "Asia/Baghdad", "Asia/Tehran", "Asia/Jerusalem", "Asia/Amman", "Asia/Beirut", "Asia/Damascus", "Asia/Nicosia", "Asia/Baku", "Asia/Tbilisi", "Asia/Yerevan", "Asia/Almaty", "Asia/Tashkent", "Asia/Samarkand", "Asia/Bishkek", "Asia/Ashgabat", "Asia/Dushanbe", "Asia/Ulaanbaatar", "Australia/Sydney", "Australia/Melbourne", "Australia/Brisbane", "Australia/Adelaide", "Australia/Perth", "Australia/Darwin", "Australia/Hobart", "Pacific/Auckland", "Pacific/Chatham", "Pacific/Fiji", "Pacific/Guam", "Pacific/Honolulu", "Pacific/Tahiti", "Pacific/Port_Moresby", "Africa/Cairo", "Africa/Casablanca", "Africa/Algiers", "Africa/Tunis", "Africa/Lagos", "Africa/Accra", "Africa/Nairobi", "Africa/Johannesburg", "Africa/Addis_Ababa", "Africa/Abidjan", "Atlantic/Azores", "Atlantic/Cape_Verde", "Atlantic/Reykjavik", "Indian/Mauritius", "Indian/Maldives"], group = groupSession, tooltip = "Attention! Session times are based on New York time. The selected timezone only changes how times are displayed in this panel. For better visual understanding, set your TradingView chart timezone to the same timezone selected here. Default market session times are New York-based, and New York DST is handled automatically.")
timeFormatInput = input.string("24h", "Time Format", options = ["24h", "AM/PM"], group = groupSession)

panelPositionInput = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left", "Top Center", "Bottom Center"], group = groupPanel)
textSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel)

panelBg = color.new(color.black, 0)
headerBg = color.new(color.blue, 0)
sectionBg = color.new(color.gray, 0)
textColor = color.white
lotColor = color.lime
activeColor = color.lime
nextColor = color.orange
warningColor = color.orange

riskMoney = accountBalance * riskPercent / 100.0
baseCur = syminfo.basecurrency
quoteCur = syminfo.currency
isForex = syminfo.type == "forex"
detectedPair = baseCur + quoteCur
nyTz = "America/New_York"
dayMs = 86400000

f_position(pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        => position.bottom_left

f_textSize(sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.normal

f_quoteCoef(q) =>
    switch q
        "USD" => 0.0100
        "JPY" => 0.0068
        "GBP" => 0.0045
        "EUR" => 0.0045
        "CHF" => 0.0043
        "CAD" => 0.0045
        "AUD" => 0.0042
        "NZD" => 0.0038
        "SGD" => 0.0032
        "HKD" => 0.0025
        "CNH" => 0.0025
        "CNY" => 0.0025
        "MXN" => 0.0020
        "ZAR" => 0.0015
        "TRY" => 0.0008
        "NOK" => 0.0025
        "SEK" => 0.0025
        "DKK" => 0.0025
        "PLN" => 0.0020
        "HUF" => 0.0015
        "CZK" => 0.0018
        "RON" => 0.0015
        "ILS" => 0.0018
        "THB" => 0.0015
        "RUB" => 0.0005
        "BRL" => 0.0010
        "INR" => 0.0010
        "KRW" => 0.0008
        "TWD" => 0.0010
        => 0.0020

f_baseAdj(b) =>
    switch b
        "EUR" => 1.00
        "USD" => 1.00
        "GBP" => 0.85
        "JPY" => 0.90
        "CHF" => 0.90
        "CAD" => 0.90
        "AUD" => 0.85
        "NZD" => 0.80
        "SGD" => 0.75
        "HKD" => 0.70
        "CNH" => 0.70
        "CNY" => 0.70
        "MXN" => 0.65
        "ZAR" => 0.55
        "TRY" => 0.35
        "NOK" => 0.65
        "SEK" => 0.65
        "DKK" => 0.70
        "PLN" => 0.60
        "HUF" => 0.55
        "CZK" => 0.55
        "RON" => 0.50
        "ILS" => 0.55
        "THB" => 0.50
        "RUB" => 0.30
        "BRL" => 0.40
        "INR" => 0.40
        "KRW" => 0.35
        "TWD" => 0.40
        => 0.50

f_pairCoef(pair, b, q) =>
    switch pair
        "EURUSD" => 0.0120
        "GBPUSD" => 0.0100
        "USDJPY" => 0.0080
        "EURJPY" => 0.0080
        "GBPJPY" => 0.0048
        "AUDUSD" => 0.0095
        "NZDUSD" => 0.0090
        "USDCAD" => 0.0080
        "USDCHF" => 0.0080
        "EURGBP" => 0.0048
        "EURAUD" => 0.0042
        "EURNZD" => 0.0040
        "EURCAD" => 0.0055
        "EURCHF" => 0.0055
        "GBPAUD" => 0.0036
        "GBPNZD" => 0.0032
        "GBPCAD" => 0.0042
        "GBPCHF" => 0.0042
        "AUDJPY" => 0.0065
        "NZDJPY" => 0.0072
        "CADJPY" => 0.0065
        "CHFJPY" => 0.0060
        "AUDNZD" => 0.0040
        "AUDCAD" => 0.0050
        "AUDCHF" => 0.0050
        "NZDCAD" => 0.0048
        "NZDCHF" => 0.0048
        "CADCHF" => 0.0050
        => f_quoteCoef(q) * f_baseAdj(b)

f_roundLot(x) =>
    math.floor(x / 0.01) * 0.01

f_lotText(x) =>
    str.tostring(f_roundLot(x), "0.00")

f_money(x) =>
    "$" + str.tostring(x, "#.##")

f_todayNY(h, m) =>
    timestamp(nyTz, year(timenow, nyTz), month(timenow, nyTz), dayofmonth(timenow, nyTz), h, m, 0)

f_closeNY(sh, sm, eh, em) =>
    startTime = f_todayNY(sh, sm)
    endTime = f_todayNY(eh, em)
    endTime <= startTime ? endTime + dayMs : endTime

f_isActive(sh, sm, eh, em) =>
    startToday = f_todayNY(sh, sm)
    closeToday = f_closeNY(sh, sm, eh, em)
    startPrev = startToday - dayMs
    closePrev = closeToday - dayMs
    (timenow >= startToday and timenow < closeToday) or (timenow >= startPrev and timenow < closePrev)

f_nextOpen(sh, sm) =>
    openToday = f_todayNY(sh, sm)
    openToday > timenow ? openToday : openToday + dayMs

f_formatTime(ts) =>
    timeFormatInput == "AM/PM" ? str.format_time(ts, "hh:mm a", displayTimezone) : str.format_time(ts, "HH:mm", displayTimezone)

f_countdown(ts) =>
    diffMs = math.max(ts - timenow, 0)
    totalMin = int(math.floor(diffMs / 60000))
    h = int(math.floor(totalMin / 60))
    m = totalMin % 60
    str.tostring(h) + "h " + str.tostring(m) + "m"

coef = f_pairCoef(detectedPair, baseCur, quoteCur)
suggestedLot = isForex ? riskMoney * coef : na

asiaOpen = f_todayNY(17, 0)
asiaClose = f_closeNY(17, 0, 5, 0)
londonOpen = f_todayNY(3, 0)
londonClose = f_closeNY(3, 0, 12, 0)
newYorkOpen = f_todayNY(8, 0)
newYorkClose = f_closeNY(8, 0, 17, 0)
euBrinxOpen = f_todayNY(3, 0)
euBrinxClose = f_closeNY(3, 0, 4, 0)
usBrinxOpen = f_todayNY(9, 0)
usBrinxClose = f_closeNY(9, 0, 10, 0)
bestOpen = f_todayNY(8, 0)
bestClose = f_closeNY(8, 0, 12, 0)

asiaActive = f_isActive(17, 0, 5, 0)
sydneyActive = f_isActive(17, 0, 2, 0)
tokyoActive = f_isActive(20, 0, 5, 0)
londonActive = f_isActive(3, 0, 12, 0)
newYorkActive = f_isActive(8, 0, 17, 0)
nyAmActive = f_isActive(9, 30, 11, 0)
nyLunchActive = f_isActive(12, 0, 13, 0)
nyPmActive = f_isActive(13, 30, 16, 0)
euBrinxActive = f_isActive(3, 0, 4, 0)
usBrinxActive = f_isActive(9, 0, 10, 0)
bestActive = f_isActive(8, 0, 12, 0)

nySessionName = usBrinxActive and nyAmActive ? "New York AM / US Brinx" : usBrinxActive ? "New York / US Brinx" : nyAmActive ? "New York AM" : nyLunchActive ? "New York Lunch" : nyPmActive ? "New York PM" : newYorkActive ? "New York" : ""

activeSession = ""
activeSession := sydneyActive ? "Asia/Sydney" : activeSession
activeSession := tokyoActive ? (activeSession == "" ? "Asia/Tokyo" : activeSession + " / Asia/Tokyo") : activeSession
activeSession := londonActive ? (activeSession == "" ? "London" : activeSession + " / London") : activeSession
activeSession := euBrinxActive ? (activeSession == "" ? "EU Brinx" : activeSession + " / EU Brinx") : activeSession
activeSession := nySessionName != "" ? (activeSession == "" ? nySessionName : activeSession + " / " + nySessionName) : activeSession
activeSession := activeSession == "" ? "Between Sessions" : activeSession

asiaNext = f_nextOpen(17, 0)
londonNext = f_nextOpen(3, 0)
newYorkNext = f_nextOpen(8, 0)
euBrinxNext = f_nextOpen(3, 0)
usBrinxNext = f_nextOpen(9, 0)

nextTime = math.min(math.min(math.min(asiaNext, londonNext), math.min(newYorkNext, euBrinxNext)), usBrinxNext)

nextSession = ""
nextSession := asiaNext == nextTime ? "Asia" : nextSession
nextSession := londonNext == nextTime ? (nextSession == "" ? "London" : nextSession + " / London") : nextSession
nextSession := euBrinxNext == nextTime ? (nextSession == "" ? "EU Brinx" : nextSession + " / EU Brinx") : nextSession
nextSession := newYorkNext == nextTime ? (nextSession == "" ? "New York" : nextSession + " / New York") : nextSession
nextSession := usBrinxNext == nextTime ? (nextSession == "" ? "US Brinx" : nextSession + " / US Brinx") : nextSession

nextStartText = f_formatTime(nextTime)
countdownText = f_countdown(nextTime)

asiaHours = f_formatTime(asiaOpen) + " - " + f_formatTime(asiaClose)
londonHours = f_formatTime(londonOpen) + " - " + f_formatTime(londonClose)
newYorkHours = f_formatTime(newYorkOpen) + " - " + f_formatTime(newYorkClose)
euBrinxHours = f_formatTime(euBrinxOpen) + " - " + f_formatTime(euBrinxClose)
usBrinxHours = f_formatTime(usBrinxOpen) + " - " + f_formatTime(usBrinxClose)
bestHours = "London/NY " + f_formatTime(bestOpen) + " - " + f_formatTime(bestClose)

var table panel = table.new(f_position(panelPositionInput), 2, 18, border_width = 1, frame_color = color.new(color.white, 0), border_color = color.new(color.white, 0))
var bool merged = false

if not merged
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, 5, 1, 5)
    table.merge_cells(panel, 0, 12, 1, 12)
    merged := true

if barstate.islast
    tSize = f_textSize(textSizeInput)

    table.cell(panel, 0, 0, "Forex Risk & Session Dashboard Pro", text_color = color.white, bgcolor = headerBg, text_size = tSize, text_halign = text.align_center)

    table.cell(panel, 0, 1, "Detected Pair", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 1, isForex ? detectedPair : syminfo.ticker, text_color = isForex ? lotColor : warningColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 2, "Balance", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 2, f_money(accountBalance), text_color = textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 3, "Risk per Trade", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 3, str.tostring(riskPercent, "#.##") + "%", text_color = lotColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 4, "Suggested Lot", text_color = color.white, bgcolor = headerBg, text_size = tSize)
    table.cell(panel, 1, 4, isForex ? f_lotText(suggestedLot) + " lot" : "N/A", text_color = isForex ? lotColor : warningColor, bgcolor = headerBg, text_size = tSize)

    table.cell(panel, 0, 5, "Market Sessions", text_color = color.white, bgcolor = sectionBg, text_size = tSize, text_halign = text.align_center)

    table.cell(panel, 0, 6, "Current Session", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 6, activeSession, text_color = activeSession == "Between Sessions" ? nextColor : activeColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 7, "Next Session", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 7, nextSession, text_color = nextColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 8, "Starts At", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 8, nextStartText, text_color = nextColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 9, "Starts In", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 9, countdownText, text_color = nextColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 10, "Timezone", text_color = textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 10, displayTimezone, text_color = textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 11, "Best Time", text_color = bestActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 11, bestHours, text_color = bestActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 12, "Session Hours", text_color = color.white, bgcolor = sectionBg, text_size = tSize, text_halign = text.align_center)

    table.cell(panel, 0, 13, "Asia", text_color = asiaActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 13, asiaHours, text_color = asiaActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 14, "London", text_color = londonActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 14, londonHours, text_color = londonActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 15, "New York", text_color = newYorkActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 15, newYorkHours, text_color = newYorkActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 16, "EU Brinx", text_color = euBrinxActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 16, euBrinxHours, text_color = euBrinxActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)

    table.cell(panel, 0, 17, "US Brinx", text_color = usBrinxActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
    table.cell(panel, 1, 17, usBrinxHours, text_color = usBrinxActive ? activeColor : textColor, bgcolor = panelBg, text_size = tSize)
````
