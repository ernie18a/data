<!-- tradingview-pine-id: PUB;a2075b1dbc7a404f9acb56816f0c4b35 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR + True RTH Day Range

Source: https://www.tradingview.com/script/SOChp4Ix-ATR-True-RTH-Day-Range/

## Description

RTH Range & Daily ATR Monitor

Track the regular trading session’s price range and compare it with the daily Average True Range (ATR), using a compact panel on your chart.

Panel Values

• ATR(D): Daily ATR with a configurable lookback, set to 14 periods by default.
• Range RTH: The difference between the highest and lowest prices recorded during the regular session.
• Used: The RTH range expressed as a percentage of daily ATR.

Used = RTH Range ÷ Daily ATR × 100

For example, a session range of 3.87 and a daily ATR of 6.22 produces approximately 62.23%. The calculation uses unrounded values.

Regular Session Only

The session range uses standard one-minute candles from the regular-session data feed, filtered to 9:30 a.m.–4:00 p.m., Monday through Friday, in America/New_York time. Daylight saving time is handled automatically.

Premarket and after-hours prices are excluded from the range calculation, whether extended hours are visible on the chart or hidden.

The daily ATR also uses an explicitly selected regular-session feed.

Session Tracking

At the first available RTH candle of each new session, the indicator saves the preceding session’s high and low, then resets the current range.

During RTH, the range expands as new highs or lows form. Outside RTH, the panel retains the latest available regular-session values until the next session begins.

Panel Colors

The background compares the latest RTH price with the preceding RTH session’s range:

• Green: Above the previous session’s high.
• Red: Below the previous session’s low.
• Gray: Inside the previous session’s range, equal to either boundary, or without sufficient previous-session data.

Extended-hours price movements do not change this directional comparison.

Display Options

• Always: Displays the latest available RTH information, including after the session ends.
• Only Today: Displays the panel only when its RTH data belongs to the current New York calendar date. Before today’s RTH session begins, the panel remains hidden.

Understanding the ATR Percentage

The percentage compares the session’s high-to-low range with daily ATR. It does not measure the total distance traveled by price or predict how much movement remains.

Values above 100% are possible when the session range exceeds the ATR.

ATR uses True Range, which accounts for gaps relative to the previous daily close. Range RTH measures only the session’s high minus its low. These are related but different measurements.

Timeframes and Updates

Designed for intraday charts, the indicator calculates the session range from one-minute data rather than the visible chart candles. Update timing depends on the chart timeframe and available data.

The daily ATR includes the developing daily candle and can change during the regular session. It is not a fixed previous-day ATR reference.

Purpose

A compact tool for monitoring regular-session range expansion, daily volatility, and price position relative to the previous RTH session. It does not generate trade entries, execute orders, or provide backtest results.

---

## Source Code

````pine
//@version=6
indicator("ATR + True RTH Day Range", overlay=true)

atrLength = input.int(14, "ATR Length", minval=1)
mode = input.string("Always", "Display Mode", options=["Always", "Only Today"])
string rthTimezone = "America/New_York"
// Explicit regular-session standard candles, independent of chart session/type.
string rthTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular)

calculateRTH() =>
    bool inside = not na(time("1", "0930-1600:23456", rthTimezone))
    int dateKey = year(time, rthTimezone) * 10000 + month(time, rthTimezone) * 100 + dayofmonth(time, rthTimezone)
    var int sessionDate = na
    var float sessionHigh = na
    var float sessionLow = na
    var float sessionClose = na
    var float priorHigh = na
    var float priorLow = na
    if inside
        if na(sessionDate) or dateKey != sessionDate
            priorHigh := sessionHigh
            priorLow := sessionLow
            sessionHigh := high
            sessionLow := low
            sessionDate := dateKey
        else
            sessionHigh := math.max(sessionHigh, high)
            sessionLow := math.min(sessionLow, low)
        sessionClose := close
    [sessionHigh, sessionLow, sessionClose, priorHigh, priorLow, sessionDate]

[dayHigh, dayLow, rthLastClose, previousDayHigh, previousDayLow, rthDate] = request.security(rthTicker, "1", calculateRTH(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dailyATR = request.security(rthTicker, "D", ta.atr(atrLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dayRange = dayHigh - dayLow
atrUsed = dailyATR > 0 ? dayRange / dailyATR * 100 : na
abovePreviousHigh = not na(previousDayHigh) and rthLastClose > previousDayHigh
belowPreviousLow = not na(previousDayLow) and rthLastClose < previousDayLow
bg = abovePreviousHigh ? color.green : belowPreviousLow ? color.red : color.gray

int todayKey = year(timenow, rthTimezone) * 10000 + month(timenow, rthTimezone) * 100 + dayofmonth(timenow, rthTimezone)
showData = mode == "Always" or rthDate == todayKey
var table t = table.new(position.top_right, 1, 2)
txt = "ATR(D): " + str.tostring(dailyATR, format.mintick) + "\nRange RTH: " + str.tostring(dayRange, format.mintick) + "\nUsed: " + str.tostring(atrUsed, "#.##") + "%"
if barstate.islast
    if showData
        table.cell(t, 0, 0, "\n", text_color=color.new(color.white, 100), bgcolor=color.new(bg, 100))
        table.cell(t, 0, 1, txt, text_color=color.white, bgcolor=bg, text_size=size.normal)
    else
        table.clear(t, 0, 0, 0, 1)
````
