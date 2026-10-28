# Monday 15:15 Monthly and Weekly Open Signals

- url: https://www.tradingview.com/script/KZDneDja-Monday-15-15-Monthly-and-Weekly-Open-Signals/
- type: indicator
- pine_id: PUB;c9ddf80f35704ac4a8bf10f89cc8c899
- version: 2.0

## Description

This indicator checks the relationship between the monthly open, weekly open, and the opening price of the Monday candle stamped 15:15 India Standard Time (IST). It is designed for standard 1-hour candlestick charts using regular trading hours, such as the NSE NIFTY and BANKNIFTY index charts.

The blue line shows the open of the first chart candle in the current month. The orange line shows the open of the first chart candle in the current week. At the start of Monday's 15:15 candle, the indicator displays one of three labels:

BUY PUT: Monthly open > Weekly open > 15:15 candle open.
BUY CALL: Monthly open < Weekly open < 15:15 candle open.
NO SETUP: Neither strict ordering is present.

The indicator provides separate Buy Put and Buy Call alert conditions. For a notification when the 15:15 candle begins, create an alert from the relevant condition and select "Once per bar".

The comparison uses the index chart's opening prices. It does not analyze an option contract's strike, premium, expiry, liquidity, or profit and loss. The labels identify a directional price setup; they are not a tested prediction or a complete options trading strategy.

The script checks Mondays only. It produces no Monday signal when that Monday is not a trading day. If the monthly and weekly opens are equal, neither strict Buy Put nor strict Buy Call condition can be met. Candle timing and opening levels depend on the chart's symbol, session, and data feed.

## Source Code

````pine
//@version=6
indicator(
     "Monday 15:15 Option Signal — All Timeframes",
     overlay = true,
     max_labels_count = 500,
     dynamic_requests = true)

// Capture the first available opening price of each week and month
// in the timeframe being sampled.
f_sample() =>
    var float monthOpen = na
    var float weekOpen = na

    if timeframe.change("M")
        monthOpen := open
    if timeframe.change("W")
        weekOpen := open

    [time, open, monthOpen, weekOpen, timeframe.change("1")]

f_isMonday1515(int t) =>
    dayofweek(t, "Asia/Kolkata") == dayofweek.monday and
     hour(t, "Asia/Kolkata") == 15 and
     minute(t, "Asia/Kolkata") == 15

f_signal(float price, float monthOpen, float weekOpen) =>
    string result = "NO SETUP"

    if not na(monthOpen) and not na(weekOpen)
        if monthOpen > weekOpen and weekOpen > price
            result := "BUY PUT"
        else if monthOpen < weekOpen and weekOpen < price
            result := "BUY CALL"

    result

f_draw(int t, float price, string signal) =>
    color labelColor = signal == "BUY PUT" ? color.red :
         signal == "BUY CALL" ? color.green : color.gray

    label.new(
         x = t,
         y = price,
         text = signal + "\n15:15 IST",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_down,
         color = labelColor,
         textcolor = color.white,
         size = size.small)

// Prevent repeat alerts while the current chart candle updates.
varip int lastAlertTime = na

bool useChartBars =
     (timeframe.isseconds and timeframe.multiplier == 1) or
     (timeframe.isminutes and timeframe.multiplier == 1)

if timeframe.isticks
    runtime.error("Use a time-based chart. Tick bars cannot guarantee an exact 15:15 price.")

else if useChartBars
    [sampleTime, samplePrice, monthOpen, weekOpen, newMinute] = f_sample()

    if newMinute and f_isMonday1515(sampleTime)
        string signal = f_signal(samplePrice, monthOpen, weekOpen)
        f_draw(sampleTime, samplePrice, signal)

        if barstate.isrealtime and (na(lastAlertTime) or lastAlertTime != sampleTime)
            if signal != "NO SETUP"
                alert(
                     signal + " | " + syminfo.ticker +
                     " | Monday 15:15 IST | Price: " +
                     str.tostring(samplePrice, format.mintick),
                     alert.freq_all)
            lastAlertTime := sampleTime

else
    // Seconds charts use 1-second data; charts up to 15 minutes
    // use 1-minute data; larger charts use 15-minute data.
    string lowerTf = timeframe.isseconds ? "1S" :
         timeframe.in_seconds() <= 15 * 60 ? "1" : "15"

    [times, prices, monthOpens, weekOpens, newMinutes] =
         request.security_lower_tf(syminfo.tickerid, lowerTf, f_sample())

    int count = array.size(times)

    if count > 0
        for i = 0 to count - 1
            int sampleTime = array.get(times, i)

            if array.get(newMinutes, i) and f_isMonday1515(sampleTime)
                float samplePrice = array.get(prices, i)
                float monthOpen = array.get(monthOpens, i)
                float weekOpen = array.get(weekOpens, i)

                string signal = f_signal(samplePrice, monthOpen, weekOpen)
                f_draw(sampleTime, samplePrice, signal)

                // Alert only when this is the newest available smaller candle.
                if barstate.isrealtime and i == count - 1 and
                     (na(lastAlertTime) or lastAlertTime != sampleTime)
                    if signal != "NO SETUP"
                        alert(
                             signal + " | " + syminfo.ticker +
                             " | Monday 15:15 IST | Price: " +
                             str.tostring(samplePrice, format.mintick),
                             alert.freq_all)
                    lastAlertTime := sampleTime
````
