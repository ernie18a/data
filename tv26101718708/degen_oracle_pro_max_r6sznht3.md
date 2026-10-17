# Degen Oracle Pro Max

- url: https://www.tradingview.com/script/R6SZnht3-Degen-Oracle-Pro-Max/
- type: indicator
- pine_id: PUB;47e02c629ecb419a86428f9b4919badd
- version: 1.0

## Description

Description:
Tired of drawing 47 different Fibonacci retracements only to get stopped out anyway? Enter the Degen Oracle Pro Max.

While other indicators use complex quantitative analysis to lose your money, this one skips the middleman and uses pure "vibes." Designed as a completely unserious, highly customizable dashboard, this indicator is built to break the tension during those stressful, choppy trading sessions by giving you highly questionable market predictions on a countdown timer.

Wait, what does it actually do?
Beneath the jokes and neon lights, the Degen Oracle actually has a "Smart-ish" algorithm. It doesn't just guess; it checks the market pulse first. Here is the actual logic under the hood:

Trend Detection: It checks if the current close is above or below the 50 EMA.

Momentum: It reads the 14 RSI to check for extreme overbought or oversold conditions.

The "Secret Sauce" (Chaos): Once it knows the general market direction, it passes those probabilities through a pseudo-random number generator (using a math.sin time-based equation).

The Result: If the market is genuinely trending up, it has a roughly 60% chance to shout "PUMP IT 🚀". But there is always a chance it ignores logic entirely and tells you the market is dumping because "Mercury is in Gatorade."

🌟 Key Features

Customizable Prediction Windows: Set the timer (e.g., 15 minutes). When the countdown hits zero, the Oracle rolls the dice and gives you a new "Vibe Shift" (Long, Flat, or Short).

OLED Dark Mode Aesthetics: Deep OLED blacks, toxic neon greens, and bright panic-sell reds. The inactive signals dim out so the active prediction visually pops on your chart.

Dynamic "Source of Truth": Every prediction comes with a highly credible source, ranging from "Bogdanoff called" to "My Hamster said so."

Fully Movable & Resizable UI: TradingView doesn't allow drag-and-drop, so we built a custom layout engine. You can anchor the dashboard anywhere, adjust the internal padding, and even shuffle the order of the UI elements (e.g., put the title at the bottom).

"Rage Quit" Auto-Hide: Set the dashboard to automatically disappear after a few minutes if you are tired of it judging your trades.

How to Use It:
Slap it on your chart, place it in the corner, and use it as your official trading mascot. When the market is chopping sideways and you're fighting the urge to overtrade, just look at the Degen Oracle. If it says to short the bottom because a coin flip told it to, you'll remember to take a deep breath, step away from the keyboard, and go touch grass.

Disclaimer (The Serious Part):
This script is published as a joke and a UI design experiment for Pine Script v6 tables. It is for ENTERTAINMENT PURPOSES ONLY. The "signals" generated are heavily randomized and should absolutely never, under any circumstances, be used to make actual financial decisions. Protect your capital and trade responsibly!

## Source Code

````pine
//@version=6
indicator("🔮 Degen Oracle Pro Max", overlay = true)

//────────────────────────────────────────────────────────────────────
// 🎛️ INPUTS: THE DEGEN SETTINGS
//────────────────────────────────────────────────────────────────────

predictionMinutes = input.int(
     15,
     "New Prediction Every (Minutes)",
     minval = 1,
     group = "🧠 Artificial Incompetence",
     tooltip = "How long until the algorithm hallucinates a new trend."
)

//────────────────────────────────────────────────────────────────────
// 📍 INPUTS: MOVABILITY & POSITIONING
//────────────────────────────────────────────────────────────────────

positionInput = input.string(
     "Top Right",
     "Dashboard Anchor",
     options = [
         "Top Left", "Top Center", "Top Right",
         "Middle Left", "Middle Center", "Middle Right",
         "Bottom Left", "Bottom Center", "Bottom Right"
     ],
     group = "📍 Position & Layout"
)

internalLayout = input.string(
     "Classic (Title Top)",
     "Internal Layout",
     options = ["Classic (Title Top)", "Timer Top (Sweaty)", "Upside Down"],
     group = "📍 Position & Layout",
     tooltip = "Rearrange the objects inside the dashboard."
)

spacingPreset = input.string(
     "Normal",
     "Horizontal Spacing (Width)",
     options = ["Compact", "Normal", "Wide"],
     group = "📍 Position & Layout"
)

//────────────────────────────────────────────────────────────────────
// 🕶️ INPUTS: DARK MODE AESTHETICS
//────────────────────────────────────────────────────────────────────

sizePreset = input.string(
     "Normal",
     "Ego Size (Visual Scale)",
     options = ["Small", "Normal", "Large"],
     group = "🕶️ Dark Mode UI"
)

autoHide = input.bool(
     false,
     "Auto-hide after time elapses?",
     group = "🙈 Hide The Shame"
)

hideAfterMinutes = input.int(
     5,
     "Hide After (Minutes)",
     minval = 1,
     group = "🙈 Hide The Shame"
)

//────────────────────────────────────────────────────────────────────
// 🛠️ UTILITIES & SIZES
//────────────────────────────────────────────────────────────────────

tablePosition = switch positionInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

titleSize = switch sizePreset
    "Small"  => size.small
    "Normal" => size.normal
    => size.large

circleSize = switch sizePreset
    "Small"  => size.normal
    "Normal" => size.large
    => size.huge

labelSize = switch sizePreset
    "Small"  => size.tiny
    "Normal" => size.small
    => size.normal

spacerText = switch spacingPreset
    "Compact" => " "
    "Normal"  => "     "
    => "          "

//────────────────────────────────────────────────────────────────────
// ⏱️ TIME WINDOW MATH
//────────────────────────────────────────────────────────────────────

durationMs = predictionMinutes * 60 * 1000
currentWindow = int(math.floor(time / durationMs))

windowStart = currentWindow * durationMs
windowEnd = windowStart + durationMs

currentTime = barstate.isrealtime ? timenow : time
elapsedMs = math.max(0, currentTime - windowStart)
isVisible = not autoHide or elapsedMs < (hideAfterMinutes * 60 * 1000)

remainingMs = math.max(0, windowEnd - currentTime)
remainingSeconds = int(math.ceil(remainingMs / 1000.0))

minutesLeft = int(math.floor(remainingSeconds / 60.0))
secondsLeft = remainingSeconds % 60
secondsText = secondsLeft < 10 ? "0" + str.tostring(secondsLeft) : str.tostring(secondsLeft)
countdownText = str.tostring(minutesLeft) + ":" + secondsText

//────────────────────────────────────────────────────────────────────
// 🧠 "SMART" PREDICTION ENGINE (Market Aware + RNG)
//────────────────────────────────────────────────────────────────────

var int savedResultIndex = 0
var int savedReasonIndex = 0
var int lastWindow = -1

// Only generate a new prediction when the time window rolls over
if currentWindow != lastWindow
    // Get actual market data to weight the probabilities
    float rsiVal = ta.rsi(close, 14)
    bool isUptrend = close > ta.ema(close, 50)
    
    // Generate pseudo-random noise between 0.0 and 1.0 based on current bar time
    float noise = math.abs(math.sin(time) * 100.0)
    noise := noise - math.floor(noise) 
    
    // Weighted Probability Engine
    if isUptrend and (na(rsiVal) or rsiVal > 40)
        // 60% Bullish, 30% Neutral, 10% Bearish
        savedResultIndex := noise > 0.4 ? 0 : (noise > 0.1 ? 2 : 1)
    else if not isUptrend and (na(rsiVal) or rsiVal < 60)
        // 60% Bearish, 30% Neutral, 10% Bullish
        savedResultIndex := noise > 0.4 ? 1 : (noise > 0.1 ? 2 : 0)
    else
        // 50% Neutral, 25% Bullish, 25% Bearish
        savedResultIndex := noise > 0.5 ? 2 : (noise > 0.25 ? 0 : 1)
        
    // Randomize a funny reason (0 to 7)
    savedReasonIndex := int(noise * 10) % 8
    lastWindow := currentWindow

// Map Results to Clear Text
trendText = switch savedResultIndex
    0 => "PUMP IT 🚀"
    1 => "DUMP IT 💥"
    => "CHOP FEST 🪚"

// Map Reasons to Funny Contexts
reasonText = switch savedReasonIndex
    0 => "Source: My Hamster said so"
    1 => "Source: RSI is looking spicy"
    2 => "Source: Moving Averages crossed bro"
    3 => "Source: Bogdanoff called"
    4 => "Source: Trust Me Bro™"
    5 => "Source: Magic 8-Ball"
    6 => "Source: A Coin Flip"
    => "Source: Whales are accumulating"

// Dark Mode Neon Colors
bullColor = color.rgb(0, 255, 128)      // Toxic Neon Green
bearColor = color.rgb(255, 85, 85)      // Bright Panic Red
neutralColor = color.rgb(255, 204, 0)   // Warning Yellow

//────────────────────────────────────────────────────────────────────
// 🖥️ DASHBOARD UI SETUP
//────────────────────────────────────────────────────────────────────

var table spinner = na
var string lastPosition = na
var string lastLayout = na
var string lastSpacing = na

layoutChanged = positionInput != lastPosition or internalLayout != lastLayout or spacingPreset != lastSpacing

if barstate.isfirst or layoutChanged
    if not na(spinner)
        table.delete(spinner)

    // Deep Dark Mode Backgrounds - pure OLED vibes
    bgColor = color.rgb(16, 16, 16) 
    frameColor = color.rgb(45, 45, 45) 

    spinner := table.new(
         tablePosition,
         columns = 5,
         rows = 5,
         bgcolor = bgColor,
         border_width = 0,
         frame_width = 1,
         frame_color = frameColor
    )

    lastPosition := positionInput
    lastLayout := internalLayout
    lastSpacing := spacingPreset

//────────────────────────────────────────────────────────────────────
// 🎨 RENDER DASHBOARD
//────────────────────────────────────────────────────────────────────

if barstate.islast
    table.clear(spinner, 0, 0, 4, 4)
    
    // Globally scoped transparent color for the table backgrounds
    transparent = color.new(color.black, 100)

    if isVisible
        // Dim the inactive colors heavily to make the active one glow
        bullDim = savedResultIndex == 0 ? bullColor : color.new(bullColor, 85)
        neutDim = savedResultIndex == 2 ? neutralColor : color.new(neutralColor, 85)
        bearDim = savedResultIndex == 1 ? bearColor : color.new(bearColor, 85)

        // Map layout rows dynamically based on user input
        rowTitle  = internalLayout == "Classic (Title Top)" ? 0 : internalLayout == "Timer Top (Sweaty)" ? 1 : 4
        rowTimer  = internalLayout == "Classic (Title Top)" ? 3 : internalLayout == "Timer Top (Sweaty)" ? 0 : 3
        rowCircle = internalLayout == "Classic (Title Top)" ? 1 : internalLayout == "Timer Top (Sweaty)" ? 2 : 2
        rowLabels = internalLayout == "Classic (Title Top)" ? 2 : internalLayout == "Timer Top (Sweaty)" ? 3 : 1
        rowSource = internalLayout == "Classic (Title Top)" ? 4 : internalLayout == "Timer Top (Sweaty)" ? 4 : 0

        // 1. TITLE
        table.cell(spinner, 2, rowTitle, "🔮 DEGEN ORACLE AI", text_color = color.white, bgcolor = transparent, text_size = titleSize)

        // 2. CIRCLES (The Spinner)
        table.cell(spinner, 0, rowCircle, "●", text_color = bullDim, bgcolor = transparent, text_size = circleSize)
        table.cell(spinner, 2, rowCircle, "●", text_color = neutDim, bgcolor = transparent, text_size = circleSize)
        table.cell(spinner, 4, rowCircle, "●", text_color = bearDim, bgcolor = transparent, text_size = circleSize)

        // 3. Spacers (Handles width of the dashboard)
        table.cell(spinner, 1, rowCircle, spacerText, bgcolor = transparent)
        table.cell(spinner, 3, rowCircle, spacerText, bgcolor = transparent)

        // 4. OUTCOME LABELS (Clear, readable text)
        table.cell(spinner, 0, rowLabels, "LONG", text_color = bullDim, bgcolor = transparent, text_size = labelSize)
        table.cell(spinner, 2, rowLabels, "FLAT", text_color = neutDim, bgcolor = transparent, text_size = labelSize)
        table.cell(spinner, 4, rowLabels, "SHORT", text_color = bearDim, bgcolor = transparent, text_size = labelSize)

        // 5. COUNTDOWN TIMER
        activeTrendColor = savedResultIndex == 0 ? bullColor : savedResultIndex == 1 ? bearColor : neutralColor
        timerMsg = "⏳ Next Vibe Shift: " + countdownText
        table.cell(spinner, 2, rowTimer, timerMsg, text_color = activeTrendColor, bgcolor = transparent, text_size = labelSize)

        // 6. SOURCE OF TRUTH (Dynamic funny reasons)
        table.cell(spinner, 2, rowSource, reasonText, text_color = color.rgb(150, 150, 150), bgcolor = transparent, text_size = size.tiny)

    else
        // Sleep Mode State
        table.cell(spinner, 2, 0, "💤 Oracle is sleeping... " + countdownText, text_color = color.rgb(100, 100, 100), bgcolor = transparent, text_size = labelSize)
````
