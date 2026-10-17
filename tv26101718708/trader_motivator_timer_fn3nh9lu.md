# Trader Motivator Timer

- url: https://www.tradingview.com/script/FN3nh9lU-Trader-Motivator-Timer/
- type: indicator
- pine_id: PUB;ff38a07c7cf54175bf012d54787fd1b6
- version: 1.0

## Description

Trader Motivator Timer (TMT) is a simple on-chart tool designed to help traders stay focused and disciplined during live market conditions.

It displays:

A real-time countdown timer for the current candle
The number of points price has moved from the open
A rotating motivational message (updates every 60 seconds) to reinforce patience and execution

This tool does not provide buy or sell signals. Instead, it serves as a discipline and awareness overlay, helping traders stay engaged, avoid impulsive decisions, and maintain consistency throughout the trading session.

Fully customizable position, text size, and background transparency.

## Source Code

````pine
// This Pine Script™ code is subject to MPL 2.0
// © aarondchannel

//@version=6
indicator("Trader Motivator Timer", shorttitle="TMT", overlay=true)

// ─────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────
showTable = input.bool(true, "Show Table")
messageRotationSeconds = input.int(60, "Message Rotation Seconds", minval=10)
tablePosition = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
textSizeInput = input.string("Large", "Text Size", options=["Small", "Normal", "Large", "Huge"])
bgOpacity = input.int(20, "Background Opacity / Transparency", minval=0, maxval=100)

// ─────────────────────────────────────────────
// Position / Size
// ─────────────────────────────────────────────
pos = tablePosition == "Top Right" ? position.top_right :
      tablePosition == "Top Left" ? position.top_left :
      tablePosition == "Bottom Right" ? position.bottom_right :
      position.bottom_left

txtSize = textSizeInput == "Small" ? size.small :
          textSizeInput == "Normal" ? size.normal :
          textSizeInput == "Large" ? size.large :
          size.huge

// ─────────────────────────────────────────────
// Messages
// ─────────────────────────────────────────────
var string[] messages = array.from(
     "Keep pushing forward!",
     "Stay positive, work hard!",
     "Believe in your strategy!",
     "Mistakes are stepping stones to success!",
     "Patience is key!",
     "Keep learning!",
     "Trust your process!",
     "Every day is a new opportunity!",
     "Stay disciplined, Risk Proper!",
     "You're capable of amazing things!",
     "Success is built one trade at a time!",
     "Your mindset is your greatest asset!",
     "Stay calm, stay focused, Let Price Print!",
     "Losses are lessons, not failures!",
     "Confidence comes from consistency!",
     "Every setback is a setup for a comeback!",
     "Trade your plan, plan your trade!",
     "Small gains lead to big victories!",
     "The market rewards patience!",
     "Trade Smart, Trade Safe, Trade Happy!"
)

// ─────────────────────────────────────────────
// TIMER
// ─────────────────────────────────────────────
secondsLeft = math.max(0, int((time_close - timenow) / 1000))

mins = int(secondsLeft / 60)
secs = secondsLeft % 60

countdownText = str.format("{0}:{1,number,00}", mins, secs)

// ─────────────────────────────────────────────
// POINTS
// ─────────────────────────────────────────────
candleTravel = close - open

pointsText = candleTravel >= 0 ? 
     "+" + str.tostring(candleTravel, format.mintick) :
     str.tostring(candleTravel, format.mintick)

// ─────────────────────────────────────────────
// Rotating Message
// ─────────────────────────────────────────────
rotationIndex = int(math.floor(timenow / 1000 / messageRotationSeconds)) % array.size(messages)
selectedMessage = "🎯 " + array.get(messages, rotationIndex)

// ─────────────────────────────────────────────
// Background Colors With Overall Opacity
// ─────────────────────────────────────────────
timerColorBase = secondsLeft <= 10 ? color.red :
                 secondsLeft <= 30 ? color.orange :
                 color.rgb(0, 120, 255)

pointsColorBase = candleTravel >= 0 ? color.green : color.red

timerColor = color.new(timerColorBase, bgOpacity)
pointsColor = color.new(pointsColorBase, bgOpacity)
messageBg = color.new(color.rgb(25, 25, 25), bgOpacity)

// ─────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────
var table msgTable = table.new(pos, 1, 3)

// ─────────────────────────────────────────────
// Display
// ─────────────────────────────────────────────
if showTable and barstate.islast
    table.cell(
         msgTable,
         0,
         0,
         "TIMER: " + countdownText,
         text_color=color.white,
         text_size=txtSize,
         bgcolor=timerColor
     )

    table.cell(
         msgTable,
         0,
         1,
         "Points: " + pointsText,
         text_color=color.white,
         text_size=txtSize,
         bgcolor=pointsColor
     )

    table.cell(
         msgTable,
         0,
         2,
         selectedMessage,
         text_color=color.white,
         text_size=txtSize,
         bgcolor=messageBg
     )
````
