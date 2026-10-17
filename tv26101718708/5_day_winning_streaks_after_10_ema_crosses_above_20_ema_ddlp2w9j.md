# 5+ Day Winning Streaks After 10 EMA Crosses Above 20 EMA

- url: https://www.tradingview.com/script/DDlP2w9j-5-Day-Winning-Streaks-After-10-EMA-Crosses-Above-20-EMA/
- type: indicator
- pine_id: PUB;36b303bcefd2425296f135173edc06c0
- version: 1.0

## Description

5+ Day Winning Streaks After 10 EMA Crosses Above 20 EMA

## Source Code

````pine
//@version=6
indicator("5+ Day Winning Streaks After 10 EMA Crosses Above 20 EMA", overlay=true, max_labels_count=500)

// === Inputs ===
showLabels = input.bool(true, "Show streak labels on chart")
showEMAs = input.bool(true, "Show 10 EMA and 20 EMA")

// === EMAs ===
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)

bullCross = ta.crossover(ema10, ema20)
emaBullish = ema10 > ema20

plot(showEMAs ? ema10 : na, "10 EMA")
plot(showEMAs ? ema20 : na, "20 EMA")

// === Track whether we are after a bullish EMA cross ===
var bool afterBullCross = false

if bullCross
    afterBullCross := true

// Optional reset: once 10 EMA drops back below 20 EMA, stop qualifying streaks
if ta.crossunder(ema10, ema20)
    afterBullCross := false

// === Count close > prior close ===
upDay = close > close[1]

// Track current winning streak
var int streakLen = 0
var int streakStartMonth = na
var bool streakQualified = false

// Monthly counts: Jan=0, Feb=1, ... Dec=11
var array<int> monthCounts = array.new_int(12, 0)

var array<string> monthNames = array.from(
     "January", "February", "March", "April", "May", "June",
     "July", "August", "September", "October", "November", "December"
)

// === Winning streak logic ===
if upDay
    if streakLen == 0
        // First up day means the streak started on the prior bar
        streakStartMonth := month(time[1])

        // The streak qualifies only if the prior bar was after a bullish EMA cross
        // and 10 EMA was above 20 EMA at the streak start.
        streakQualified := afterBullCross[1] and ema10[1] > ema20[1]

    streakLen += 1
else
    // When streak ends, count it only if it reached 5+ up days and qualified
    if streakLen >= 5 and not na(streakStartMonth) and streakQualified
        idx = streakStartMonth - 1
        array.set(monthCounts, idx, array.get(monthCounts, idx) + 1)

        if showLabels
            label.new(
                 bar_index[1],
                 high[1],
                 str.tostring(streakLen) + " up days\nStarted: " + array.get(monthNames, idx) + "\nAfter 10/20 EMA cross",
                 style=label.style_label_down,
                 textcolor=color.white
            )

    streakLen := 0
    streakStartMonth := na
    streakQualified := false

// === Active streak label ===
if barstate.islast and streakLen >= 5 and streakQualified and not na(streakStartMonth)
    idx = streakStartMonth - 1
    label.new(
         bar_index,
         high,
         "Active qualified streak: " + str.tostring(streakLen) + " up days\nStarted: " + array.get(monthNames, idx),
         style=label.style_label_down,
         textcolor=color.white
    )

// === Table ===
var table t = table.new(position.top_right, 2, 13, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Month")
    table.cell(t, 1, 0, "Qualified 5+ Streaks")

    for i = 0 to 11
        table.cell(t, 0, i + 1, array.get(monthNames, i))
        table.cell(t, 1, i + 1, str.tostring(array.get(monthCounts, i)))
````
