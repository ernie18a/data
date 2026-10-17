# Candle Streak Highlighter

- url: https://www.tradingview.com/script/ApxqHHEM-Candle-Streak-Highlighter/
- type: indicator
- pine_id: PUB;b582ea62ad394495b97b1e68ce483fe7
- version: 3.0

## Description

Candle Streak Highlighter is a clean visual indicator designed to highlight consecutive bullish and bearish candle streaks directly on the chart.

Unlike a basic candle-coloring script, this indicator identifies the exact candle number inside a directional streak from 2 through 10 candles. Each streak count can be individually enabled or disabled, allowing traders to focus only on the continuation or exhaustion zones that matter to their strategy.

Bullish and bearish streaks use separate color progressions, making it easier to quickly identify when directional pressure is building, extending, or becoming stretched. Early streaks can help traders spot potential continuation, while longer streaks may help identify areas where momentum is extended and caution may be needed.

The indicator is built for clean chart reading with no labels, tables, or unnecessary clutter. It simply highlights the active candle streak so traders can visually track consecutive candle behavior in real time.

Key Features:

Highlights bullish and bearish candle streaks from 2 through 10 candles
Allows each streak number to be enabled or disabled individually
Uses separate bullish and bearish default color progressions
Helps visually identify continuation pressure and extended candle runs
Keeps the chart clean with candle coloring only
Color settings are controlled from the Inputs tab for easier customization
Works directly on the price chart as a simple visual aid

Use Case:

Candle Streak Highlighter can be used to study how price behaves during consecutive bullish or bearish candle runs. Traders may use it to spot early continuation, track strengthening directional pressure, or recognize when a move may be getting extended after several same-direction candle

## Source Code

````pine
//@version=6
indicator("Candle Streak Highlighter", overlay=true)

// ─────────────────────────────────────────────
// Enable / Disable Streak Numbers
// ─────────────────────────────────────────────
showStreak2  = input.bool(true, "Show 2 Candle Streak")
showStreak3  = input.bool(true, "Show 3 Candle Streak")
showStreak4  = input.bool(true, "Show 4 Candle Streak")
showStreak5  = input.bool(true, "Show 5 Candle Streak")
showStreak6  = input.bool(true, "Show 6 Candle Streak")
showStreak7  = input.bool(true, "Show 7 Candle Streak")
showStreak8  = input.bool(true, "Show 8 Candle Streak")
showStreak9  = input.bool(true, "Show 9 Candle Streak")
showStreak10 = input.bool(true, "Show 10 Candle Streak")

// ─────────────────────────────────────────────
// Bullish Streak Colors
// Default: White
// ─────────────────────────────────────────────
bullColor2  = input.color(color.white, "Bullish 2 Streak Color")
bullColor3  = input.color(color.white, "Bullish 3 Streak Color")
bullColor4  = input.color(color.white, "Bullish 4 Streak Color")
bullColor5  = input.color(color.white, "Bullish 5 Streak Color")
bullColor6  = input.color(color.white, "Bullish 6 Streak Color")
bullColor7  = input.color(color.white, "Bullish 7 Streak Color")
bullColor8  = input.color(color.white, "Bullish 8 Streak Color")
bullColor9  = input.color(color.white, "Bullish 9 Streak Color")
bullColor10 = input.color(color.white, "Bullish 10 Streak Color")

// ─────────────────────────────────────────────
// Bearish Streak Colors
// Default: Darkest RGB Black
// ─────────────────────────────────────────────
bearColor2  = input.color(color.rgb(0, 0, 0), "Bearish 2 Streak Color")
bearColor3  = input.color(color.rgb(0, 0, 0), "Bearish 3 Streak Color")
bearColor4  = input.color(color.rgb(0, 0, 0), "Bearish 4 Streak Color")
bearColor5  = input.color(color.rgb(0, 0, 0), "Bearish 5 Streak Color")
bearColor6  = input.color(color.rgb(0, 0, 0), "Bearish 6 Streak Color")
bearColor7  = input.color(color.rgb(0, 0, 0), "Bearish 7 Streak Color")
bearColor8  = input.color(color.rgb(0, 0, 0), "Bearish 8 Streak Color")
bearColor9  = input.color(color.rgb(0, 0, 0), "Bearish 9 Streak Color")
bearColor10 = input.color(color.rgb(0, 0, 0), "Bearish 10 Streak Color")

// ─────────────────────────────────────────────
// User Configurable alert() Function Call Alerts
// Use TradingView alert option: "Any alert() function call"
// ─────────────────────────────────────────────
enableFunctionAlerts = input.bool(true, "Enable Configurable Function Call Alerts", group="Function Call Alerts")
alertOnBarClose      = input.bool(true, "Trigger Function Alerts Only After Candle Close", group="Function Call Alerts")

alertBullish = input.bool(true, "Alert Bullish Streaks", group="Function Call Alerts")
alertBearish = input.bool(true, "Alert Bearish Streaks", group="Function Call Alerts")

alertStreak2  = input.bool(true, "Alert 2 Candle Streak", group="Function Call Alerts")
alertStreak3  = input.bool(true, "Alert 3 Candle Streak", group="Function Call Alerts")
alertStreak4  = input.bool(true, "Alert 4 Candle Streak", group="Function Call Alerts")
alertStreak5  = input.bool(true, "Alert 5 Candle Streak", group="Function Call Alerts")
alertStreak6  = input.bool(true, "Alert 6 Candle Streak", group="Function Call Alerts")
alertStreak7  = input.bool(true, "Alert 7 Candle Streak", group="Function Call Alerts")
alertStreak8  = input.bool(true, "Alert 8 Candle Streak", group="Function Call Alerts")
alertStreak9  = input.bool(true, "Alert 9 Candle Streak", group="Function Call Alerts")
alertStreak10 = input.bool(true, "Alert 10 Candle Streak", group="Function Call Alerts")

// ─────────────────────────────────────────────
// Candle Direction Logic
// ─────────────────────────────────────────────
isBull = close >= open

var int streak = 1

if bar_index > 0
    prevBull = close[1] >= open[1]

    if isBull == prevBull
        streak += 1
    else
        streak := 1

// ─────────────────────────────────────────────
// Enabled Streak Filter
// ─────────────────────────────────────────────
showCurrentStreak =
     streak == 2  and showStreak2  or
     streak == 3  and showStreak3  or
     streak == 4  and showStreak4  or
     streak == 5  and showStreak5  or
     streak == 6  and showStreak6  or
     streak == 7  and showStreak7  or
     streak == 8  and showStreak8  or
     streak == 9  and showStreak9  or
     streak >= 10 and showStreak10

// ─────────────────────────────────────────────
// Color Selection
// ─────────────────────────────────────────────
bullStreakColor =
     streak == 2  ? bullColor2  :
     streak == 3  ? bullColor3  :
     streak == 4  ? bullColor4  :
     streak == 5  ? bullColor5  :
     streak == 6  ? bullColor6  :
     streak == 7  ? bullColor7  :
     streak == 8  ? bullColor8  :
     streak == 9  ? bullColor9  :
     streak >= 10 ? bullColor10 :
     na

bearStreakColor =
     streak == 2  ? bearColor2  :
     streak == 3  ? bearColor3  :
     streak == 4  ? bearColor4  :
     streak == 5  ? bearColor5  :
     streak == 6  ? bearColor6  :
     streak == 7  ? bearColor7  :
     streak == 8  ? bearColor8  :
     streak == 9  ? bearColor9  :
     streak >= 10 ? bearColor10 :
     na

barColor =
     showCurrentStreak ?
          isBull ? bullStreakColor : bearStreakColor
     : na

// editable=false keeps the color controls in Inputs and removes confusing generic Style colors.
barcolor(barColor, editable=false)

// ─────────────────────────────────────────────
// Alert Conditions: Bullish 2 Through 10
// These appear as selectable alert conditions in TradingView.
// ─────────────────────────────────────────────
bullStreak2Alert  = isBull and streak == 2
bullStreak3Alert  = isBull and streak == 3
bullStreak4Alert  = isBull and streak == 4
bullStreak5Alert  = isBull and streak == 5
bullStreak6Alert  = isBull and streak == 6
bullStreak7Alert  = isBull and streak == 7
bullStreak8Alert  = isBull and streak == 8
bullStreak9Alert  = isBull and streak == 9
bullStreak10Alert = isBull and streak == 10

alertcondition(bullStreak2Alert,  "Bullish 2 Candle Streak",  "Bullish 2 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak3Alert,  "Bullish 3 Candle Streak",  "Bullish 3 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak4Alert,  "Bullish 4 Candle Streak",  "Bullish 4 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak5Alert,  "Bullish 5 Candle Streak",  "Bullish 5 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak6Alert,  "Bullish 6 Candle Streak",  "Bullish 6 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak7Alert,  "Bullish 7 Candle Streak",  "Bullish 7 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak8Alert,  "Bullish 8 Candle Streak",  "Bullish 8 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak9Alert,  "Bullish 9 Candle Streak",  "Bullish 9 candle streak on {{ticker}} {{interval}}")
alertcondition(bullStreak10Alert, "Bullish 10 Candle Streak", "Bullish 10 candle streak on {{ticker}} {{interval}}")

// ─────────────────────────────────────────────
// Alert Conditions: Bearish 2 Through 10
// These appear as selectable alert conditions in TradingView.
// ─────────────────────────────────────────────
bearStreak2Alert  = not isBull and streak == 2
bearStreak3Alert  = not isBull and streak == 3
bearStreak4Alert  = not isBull and streak == 4
bearStreak5Alert  = not isBull and streak == 5
bearStreak6Alert  = not isBull and streak == 6
bearStreak7Alert  = not isBull and streak == 7
bearStreak8Alert  = not isBull and streak == 8
bearStreak9Alert  = not isBull and streak == 9
bearStreak10Alert = not isBull and streak == 10

alertcondition(bearStreak2Alert,  "Bearish 2 Candle Streak",  "Bearish 2 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak3Alert,  "Bearish 3 Candle Streak",  "Bearish 3 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak4Alert,  "Bearish 4 Candle Streak",  "Bearish 4 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak5Alert,  "Bearish 5 Candle Streak",  "Bearish 5 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak6Alert,  "Bearish 6 Candle Streak",  "Bearish 6 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak7Alert,  "Bearish 7 Candle Streak",  "Bearish 7 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak8Alert,  "Bearish 8 Candle Streak",  "Bearish 8 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak9Alert,  "Bearish 9 Candle Streak",  "Bearish 9 candle streak on {{ticker}} {{interval}}")
alertcondition(bearStreak10Alert, "Bearish 10 Candle Streak", "Bearish 10 candle streak on {{ticker}} {{interval}}")

// ─────────────────────────────────────────────
// Configurable Function Call Alert Logic
// User chooses which streaks trigger alerts in Inputs.
// In TradingView, create alert using:
// Condition: Candle Streak Highlighter
// Option: Any alert() function call
// ─────────────────────────────────────────────
selectedStreakAlert =
     streak == 2  and alertStreak2  or
     streak == 3  and alertStreak3  or
     streak == 4  and alertStreak4  or
     streak == 5  and alertStreak5  or
     streak == 6  and alertStreak6  or
     streak == 7  and alertStreak7  or
     streak == 8  and alertStreak8  or
     streak == 9  and alertStreak9  or
     streak == 10 and alertStreak10

selectedDirectionAlert =
     isBull and alertBullish or
     not isBull and alertBearish

canTriggerFunctionAlert =
     enableFunctionAlerts and
     selectedStreakAlert and
     selectedDirectionAlert and
     (alertOnBarClose ? barstate.isconfirmed : true)

if canTriggerFunctionAlert
    directionText = isBull ? "Bullish" : "Bearish"
    alert(directionText + " " + str.tostring(streak) + " candle streak on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar)
````
