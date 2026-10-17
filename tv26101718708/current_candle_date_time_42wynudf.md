# Current Candle Date & Time

- url: https://www.tradingview.com/script/42wyNUDF-Current-Candle-Date-Time/
- type: indicator
- pine_id: PUB;ba95c119986d4f2cb6c32291e7584597
- version: 1.0

## Description

Current Candle Date & Time

Current Candle Date & Time is a lightweight utility for TradingView that displays the open and close time of the current candle directly on your chart.

Designed for both Live Charts and Replay Mode, this indicator helps traders quickly identify the exact candle they are analyzing without needing to hover over the chart timeline.

## Features

• Displays the open time of the current candle  
• Displays the close time of the current candle  
• Automatically adapts to the selected chart timeframe  
• Built-in timezone dropdown selector  
• Supports major global financial centers and timezones  
• Clean top-right overlay  
• Works on both Live Charts and Replay Mode  

## Useful For

• Backtesting  
• Trade journaling  
• Replay analysis  
• Reviewing historical setups  
• Monitoring candle timing during live market conditions  
• Comparing market activity across different timezones  

## Why Use This Indicator?

When backtesting or reviewing historical charts, it can be difficult to quickly determine the exact candle being analyzed. This indicator displays the candle's opening and closing timestamps directly on the chart, allowing traders to focus on analysis instead of constantly checking the chart timeline.

## Timezone Support

The indicator includes a built-in dropdown menu allowing you to select your preferred timezone without modifying any code.

Supported options include:

• UTC  
• Exchange Time  
• Sydney  
• Brisbane  
• Adelaide  
• Tokyo  
• Seoul  
• Singapore  
• Hong Kong  
• Shanghai  
• Perth  
• Bangkok  
• Jakarta  
• Dubai  
• Muscat  
• Karachi  
• Kolkata  
• Dhaka  
• London  
• Paris  
• Berlin  
• Amsterdam  
• Madrid  
• Rome  
• Zurich  
• Johannesburg  
• New York  
• Toronto  
• Chicago  
• Denver  
• Los Angeles  
• Vancouver  
• Mexico City  
• Sao Paulo  
• Buenos Aires  

and many more.

Simply open the indicator settings, select your preferred timezone from the dropdown list, and click OK.

## Timeframe Compatibility

The indicator automatically adjusts to the chart timeframe selected.

### Examples

10-Minute Chart
- Open: 04:10
- Close: 04:20

2-Hour Chart
- Open: 02:00
- Close: 04:00

1-Day Chart
- Open: 11 Jun 2026
- Close: 12 Jun 2026

No manual adjustments are required when switching between timeframes.

## Notes

• Works on all TradingView-supported timeframes.  
• Supports both Replay Mode and Live Charts.  
• Open-source and fully customizable.  
• Uses TradingView-supported timezone standards for accurate timestamp conversion.  
• Designed as a simple utility tool for traders who want quick access to candle timestamps while trading, backtesting, journaling, and reviewing historical market data.

## Source Code

````pine
//@version=6
indicator("Current Candle Date & Time", overlay=true)

tzSelection = input.string(
     "(UTC+10) Sydney",
     "Timezone",
     options=[
         "UTC", "Exchange",
         "(UTC-10) Honolulu", "(UTC-8) Anchorage", "(UTC-8) Juneau",
         "(UTC-7) Los Angeles", "(UTC-7) Phoenix", "(UTC-7) Vancouver",
         "(UTC-6) Denver", "(UTC-6) Mexico City", "(UTC-6) San Salvador",
         "(UTC-5) Bogota", "(UTC-5) Chicago", "(UTC-5) Lima",
         "(UTC-4) Caracas", "(UTC-4) New York", "(UTC-4) Santiago", "(UTC-4) Toronto",
         "(UTC-3) Buenos Aires", "(UTC-3) Halifax", "(UTC-3) Sao Paulo",
         "(UTC) Azores", "(UTC) Reykjavik",
         "(UTC+1) Casablanca", "(UTC+1) Dublin", "(UTC+1) Lagos", "(UTC+1) Lisbon", "(UTC+1) London", "(UTC+1) Tunis",
         "(UTC+2) Amsterdam", "(UTC+2) Belgrade", "(UTC+2) Berlin", "(UTC+2) Bratislava", "(UTC+2) Brussels",
         "(UTC+2) Budapest", "(UTC+2) Copenhagen", "(UTC+2) Johannesburg", "(UTC+2) Ljubljana",
         "(UTC+2) Luxembourg", "(UTC+2) Madrid", "(UTC+2) Malta", "(UTC+2) Oslo", "(UTC+2) Paris",
         "(UTC+2) Prague", "(UTC+2) Rome", "(UTC+2) Stockholm", "(UTC+2) Vienna", "(UTC+2) Warsaw",
         "(UTC+2) Zagreb", "(UTC+2) Zurich",
         "(UTC+3) Athens", "(UTC+3) Bahrain", "(UTC+3) Bucharest", "(UTC+3) Cairo", "(UTC+3) Helsinki",
         "(UTC+3) Istanbul", "(UTC+3) Jerusalem", "(UTC+3) Kuwait", "(UTC+3) Moscow", "(UTC+3) Nairobi",
         "(UTC+3) Nicosia", "(UTC+3) Qatar", "(UTC+3) Riga", "(UTC+3) Riyadh", "(UTC+3) Sofia",
         "(UTC+3) Tallinn", "(UTC+3) Vilnius",
         "(UTC+3:30) Tehran", "(UTC+4) Dubai", "(UTC+4) Muscat", "(UTC+4:30) Kabul",
         "(UTC+5) Ashgabat", "(UTC+5) Astana", "(UTC+5) Karachi",
         "(UTC+5:30) Colombo", "(UTC+5:30) Kolkata", "(UTC+5:45) Kathmandu",
         "(UTC+6) Dhaka", "(UTC+6:30) Yangon",
         "(UTC+7) Bangkok", "(UTC+7) Ho Chi Minh", "(UTC+7) Jakarta",
         "(UTC+8) Chongqing", "(UTC+8) Hong Kong", "(UTC+8) Kuala Lumpur", "(UTC+8) Manila",
         "(UTC+8) Perth", "(UTC+8) Shanghai", "(UTC+8) Singapore", "(UTC+8) Taipei",
         "(UTC+9) Seoul", "(UTC+9) Tokyo", "(UTC+9:30) Adelaide", "(UTC+10) Brisbane", "(UTC+10) Sydney",
         "(UTC+11) Norfolk Island", "(UTC+12) New Zealand", "(UTC+12:45) Chatham Islands", "(UTC+13) Tokelau"
     ]
)

tz = switch tzSelection
    "UTC" => "Etc/UTC"
    "Exchange" => syminfo.timezone
    "(UTC-10) Honolulu" => "Pacific/Honolulu"
    "(UTC-8) Anchorage" => "America/Anchorage"
    "(UTC-8) Juneau" => "America/Juneau"
    "(UTC-7) Los Angeles" => "America/Los_Angeles"
    "(UTC-7) Phoenix" => "America/Phoenix"
    "(UTC-7) Vancouver" => "America/Vancouver"
    "(UTC-6) Denver" => "America/Denver"
    "(UTC-6) Mexico City" => "America/Mexico_City"
    "(UTC-6) San Salvador" => "America/El_Salvador"
    "(UTC-5) Bogota" => "America/Bogota"
    "(UTC-5) Chicago" => "America/Chicago"
    "(UTC-5) Lima" => "America/Lima"
    "(UTC-4) Caracas" => "America/Caracas"
    "(UTC-4) New York" => "America/New_York"
    "(UTC-4) Santiago" => "America/Santiago"
    "(UTC-4) Toronto" => "America/Toronto"
    "(UTC-3) Buenos Aires" => "America/Argentina/Buenos_Aires"
    "(UTC-3) Halifax" => "America/Halifax"
    "(UTC-3) Sao Paulo" => "America/Sao_Paulo"
    "(UTC) Azores" => "Atlantic/Azores"
    "(UTC) Reykjavik" => "Atlantic/Reykjavik"
    "(UTC+1) Casablanca" => "Africa/Casablanca"
    "(UTC+1) Dublin" => "Europe/Dublin"
    "(UTC+1) Lagos" => "Africa/Lagos"
    "(UTC+1) Lisbon" => "Europe/Lisbon"
    "(UTC+1) London" => "Europe/London"
    "(UTC+1) Tunis" => "Africa/Tunis"
    "(UTC+2) Amsterdam" => "Europe/Amsterdam"
    "(UTC+2) Belgrade" => "Europe/Belgrade"
    "(UTC+2) Berlin" => "Europe/Berlin"
    "(UTC+2) Bratislava" => "Europe/Bratislava"
    "(UTC+2) Brussels" => "Europe/Brussels"
    "(UTC+2) Budapest" => "Europe/Budapest"
    "(UTC+2) Copenhagen" => "Europe/Copenhagen"
    "(UTC+2) Johannesburg" => "Africa/Johannesburg"
    "(UTC+2) Ljubljana" => "Europe/Ljubljana"
    "(UTC+2) Luxembourg" => "Europe/Luxembourg"
    "(UTC+2) Madrid" => "Europe/Madrid"
    "(UTC+2) Malta" => "Europe/Malta"
    "(UTC+2) Oslo" => "Europe/Oslo"
    "(UTC+2) Paris" => "Europe/Paris"
    "(UTC+2) Prague" => "Europe/Prague"
    "(UTC+2) Rome" => "Europe/Rome"
    "(UTC+2) Stockholm" => "Europe/Stockholm"
    "(UTC+2) Vienna" => "Europe/Vienna"
    "(UTC+2) Warsaw" => "Europe/Warsaw"
    "(UTC+2) Zagreb" => "Europe/Zagreb"
    "(UTC+2) Zurich" => "Europe/Zurich"
    "(UTC+3) Athens" => "Europe/Athens"
    "(UTC+3) Bahrain" => "Asia/Bahrain"
    "(UTC+3) Bucharest" => "Europe/Bucharest"
    "(UTC+3) Cairo" => "Africa/Cairo"
    "(UTC+3) Helsinki" => "Europe/Helsinki"
    "(UTC+3) Istanbul" => "Europe/Istanbul"
    "(UTC+3) Jerusalem" => "Asia/Jerusalem"
    "(UTC+3) Kuwait" => "Asia/Kuwait"
    "(UTC+3) Moscow" => "Europe/Moscow"
    "(UTC+3) Nairobi" => "Africa/Nairobi"
    "(UTC+3) Nicosia" => "Asia/Nicosia"
    "(UTC+3) Qatar" => "Asia/Qatar"
    "(UTC+3) Riga" => "Europe/Riga"
    "(UTC+3) Riyadh" => "Asia/Riyadh"
    "(UTC+3) Sofia" => "Europe/Sofia"
    "(UTC+3) Tallinn" => "Europe/Tallinn"
    "(UTC+3) Vilnius" => "Europe/Vilnius"
    "(UTC+3:30) Tehran" => "Asia/Tehran"
    "(UTC+4) Dubai" => "Asia/Dubai"
    "(UTC+4) Muscat" => "Asia/Muscat"
    "(UTC+4:30) Kabul" => "Asia/Kabul"
    "(UTC+5) Ashgabat" => "Asia/Ashgabat"
    "(UTC+5) Astana" => "Asia/Almaty"
    "(UTC+5) Karachi" => "Asia/Karachi"
    "(UTC+5:30) Colombo" => "Asia/Colombo"
    "(UTC+5:30) Kolkata" => "Asia/Kolkata"
    "(UTC+5:45) Kathmandu" => "Asia/Kathmandu"
    "(UTC+6) Dhaka" => "Asia/Dhaka"
    "(UTC+6:30) Yangon" => "Asia/Yangon"
    "(UTC+7) Bangkok" => "Asia/Bangkok"
    "(UTC+7) Ho Chi Minh" => "Asia/Ho_Chi_Minh"
    "(UTC+7) Jakarta" => "Asia/Jakarta"
    "(UTC+8) Chongqing" => "Asia/Chongqing"
    "(UTC+8) Hong Kong" => "Asia/Hong_Kong"
    "(UTC+8) Kuala Lumpur" => "Asia/Kuala_Lumpur"
    "(UTC+8) Manila" => "Asia/Manila"
    "(UTC+8) Perth" => "Australia/Perth"
    "(UTC+8) Shanghai" => "Asia/Shanghai"
    "(UTC+8) Singapore" => "Asia/Singapore"
    "(UTC+8) Taipei" => "Asia/Taipei"
    "(UTC+9) Seoul" => "Asia/Seoul"
    "(UTC+9) Tokyo" => "Asia/Tokyo"
    "(UTC+9:30) Adelaide" => "Australia/Adelaide"
    "(UTC+10) Brisbane" => "Australia/Brisbane"
    "(UTC+10) Sydney" => "Australia/Sydney"
    "(UTC+11) Norfolk Island" => "Pacific/Norfolk"
    "(UTC+12) New Zealand" => "Pacific/Auckland"
    "(UTC+12:45) Chatham Islands" => "Pacific/Chatham"
    "(UTC+13) Tokelau" => "Pacific/Fakaofo"
    => "Australia/Sydney"

barMs = timeframe.in_seconds(timeframe.period) * 1000

candleOpenTime  = time - barMs
candleCloseTime = time_close - barMs

openText  = str.format_time(candleOpenTime, "dd MMM yyyy HH:mm", tz)
closeText = str.format_time(candleCloseTime, "dd MMM yyyy HH:mm", tz)

var table t = table.new(position.top_right, 1, 3, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Current Candle", text_color=color.white, bgcolor=color.black)
    table.cell(t, 0, 1, "Open: " + openText, text_color=color.white, bgcolor=color.blue)
    table.cell(t, 0, 2, "Close: " + closeText, text_color=color.white, bgcolor=color.blue)
````
