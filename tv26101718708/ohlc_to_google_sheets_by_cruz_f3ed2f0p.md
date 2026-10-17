# OHLC to Google Sheets By Cruz

- url: https://www.tradingview.com/script/F3Ed2F0P-OHLC-to-Google-Sheets-By-Cruz/
- type: indicator
- pine_id: PUB;506d48eb1a314223b088587b6f69b81f
- version: 1.0

## Description

Link from trading view to google sheets
this app wil link trading view open and close data from the charts to google sheets alowing you to make detailed sheet data

## Source Code

````pine
//@version=6
indicator("OHLC to Google Sheets", overlay = true)

dateStr = str.format("{0,date,yyyy-MM-dd}", time)

payload = '{"symbol":"' + syminfo.ticker + '",' +
          '"time":"' + dateStr + '",' +
          '"open":' + str.tostring(open) + ',' +
          '"high":' + str.tostring(high) + ',' +
          '"low":' + str.tostring(low) + ',' +
          '"close":' + str.tostring(close) + '}'

alert(payload, alert.freq_once_per_bar_close)

plot(close, "Close", color = color.new(color.blue, 100))
````
