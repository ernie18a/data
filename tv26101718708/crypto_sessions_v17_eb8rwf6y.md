# Crypto Sessions V1.7 

- url: https://www.tradingview.com/script/EB8Rwf6y-Crypto-Sessions-V1-7/
- type: indicator
- pine_id: PUB;bde0ed0db48247d9a6156dd44b609756
- version: 1.0

## Description

Crypto Sessions V1.7 is a complete session trading toolkit built for forex, crypto, indices, and gold traders who trade around key market sessions and liquidity movements.

It highlights the major trading sessions directly on your chart, tracks session highs and lows, plots previous day levels, and includes advanced tools like Fibonacci Golden Zones and custom session controls.

For the best experience, use Crypto Sessions V1.7 together with the D20Trades Previous Day Levels indicator to build a complete liquidity-based trading system.

Features

• Asia Session Box
• London Session Box
• New York Session Box
• Customisable session colours and opacity
• Session high and low levels
• Previous Day High and Previous Day Low integration
• Daily Open line
• Fibonacci Golden Zone extension
• Multi-timeframe support
• Day filtering options
• Session labels
• Full customisation controls
• Clean chart layout designed for active traders

How To Use

1. Session Trading

Use the session boxes to identify where liquidity builds during the trading day.

The Asia session often creates the range. London and New York commonly provide the breakout and expansion moves.

Watch for:
• Liquidity sweeps above session highs
• Liquidity sweeps below session lows
• Breakouts from consolidation
• Rejections from session extremes

2. Use With D20Trades Previous Day Levels

Crypto Sessions V1.7 works best when combined with the D20Trades Previous Day Levels indicator.

The Previous Day High, Previous Day Low, and Daily Open are major liquidity zones where price often reacts.

Use both indicators together to identify:
• Liquidity targets
• Market direction
• Session manipulation
• High-probability reversals
• Breakout continuation setups

Example workflow:
• Mark Previous Day High and Low
• Wait for London or New York session expansion
• Watch for liquidity sweep or rejection
• Enter after market structure confirmation

3. Fibonacci Golden Zone

The built-in Golden Zone helps identify premium and discount retracement areas.

Use the Golden Zone after:
• Strong impulsive moves
• Session breakouts
• Liquidity grabs

Look for confirmation such as:
• Market Structure Shift
• Candle rejection
• Order block reaction
• Fair Value Gap entries

4. Multi-Timeframe Analysis

The indicator works across all timeframes.

Recommended usage:
• Higher timeframes for directional bias
• Lower timeframes for execution and entries

Best combinations:
• H1 for structure
• M15 for setup formation
• M5 for execution

Best Markets

• Forex
• Crypto
• Gold
• Indices

Best Trading Times

• London Open
• New York Open
• London and New York overlap

Tips

• Combine session highs and lows with previous day liquidity levels
• Wait for confirmation before entering trades
• Use stop losses beyond liquidity zones
• Avoid trading during low volatility conditions

Crypto Sessions V1.7 was created to help traders simplify session analysis and focus on high-probability trading opportunities using liquidity, session timing, and smart money concepts.

## Source Code

````pine
/// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © D20Trades

//@version=5
indicator("Crypto Sessions V1.7", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================

useCustomUTC = input.bool(false, "Use Custom UTC Offset")

utcOffsetH = input.int(0, "UTC Offset Hours", minval=-12, maxval=14)
utcOffsetM = input.int(0, "UTC Offset Minutes", minval=0, maxval=59)

// =====================================================
// SESSION SETTINGS
// =====================================================

showAsiaSession   = input.bool(true, "Asia Session")
showLondonSession = input.bool(true, "London Session")
showNYSession     = input.bool(true, "New York Session")

showPreviousDays = input.bool(false, "Show Previous Day Sessions")

// =====================================================
// SESSION COLOURS
// =====================================================

asiaSessionColor   = input.color(color.blue, "Asia Session Color")
londonSessionColor = input.color(color.green, "London Session Color")
nySessionColor     = input.color(color.red, "New York Session Color")

asiaSessionOpacity   = input.int(90, "Asia Session Opacity", minval=0, maxval=100)
londonSessionOpacity = input.int(90, "London Session Opacity", minval=0, maxval=100)
nySessionOpacity     = input.int(90, "New York Session Opacity", minval=0, maxval=100)

// =====================================================
// VOL WINDOWS
// =====================================================

showLondonVol = input.bool(true, "London Volatility Window")
showNYVol     = input.bool(true, "New York Volatility Window")
showAsiaVol   = input.bool(false, "Asia Volatility Window")

volWindowColor   = input.color(color.purple, "Volatility Window Color")
volWindowOpacity = input.int(88, "Volatility Window Opacity", minval=0, maxval=100)

// =====================================================
// SILVER BULLET
// =====================================================

showSilverBullet = input.bool(true, "Silver Bullet Windows")

silverBulletColor   = input.color(color.orange, "Silver Bullet Color")
silverBulletOpacity = input.int(88, "Silver Bullet Opacity", minval=0, maxval=100)

// =====================================================
// ASIA LEVEL SETTINGS
// =====================================================

showAsiaLevels = input.bool(true, "Asia High / Low")
showAsiaMid    = input.bool(true, "Asia Mid")

asiaLineLength = input.int(120, "Asia Line Length", minval=10, maxval=5000)
midLineLength  = input.int(120, "Mid Line Length", minval=10, maxval=5000)

asiaHighColor = input.color(color.aqua, "Asia High Colour")
asiaLowColor  = input.color(color.orange, "Asia Low Colour")
asiaMidColor  = input.color(color.gray, "Asia Mid Colour")

asiaHighLabelColor = input.color(color.aqua, "Asia High Label Colour")
asiaLowLabelColor  = input.color(color.orange, "Asia Low Label Colour")
asiaMidLabelColor  = input.color(color.gray, "Asia Mid Label Colour")

// =====================================================
// SIGNALS
// =====================================================

showSweeps  = input.bool(true, "Strict Sweeps")
showBOS     = input.bool(true, "BOS")
showEntries = input.bool(true, "Entry Signals")
showJudas   = input.bool(true, "Judas Swings")

// =====================================================
// FIB SETTINGS
// =====================================================

showFib = input.bool(true, "Auto Fibonacci")
showGoldenZone = input.bool(true, "Fib Golden Zone")

fib50Color  = input.color(color.gray, "Fib 50 Color")
fib618Color = input.color(color.orange, "Fib 0.618 Color")
fib705Color = input.color(color.red, "Fib 0.705 Color")

goldenZoneColor = input.color(color.new(color.orange, 85), "Golden Zone Fill")

goldenZoneExtendLeft  = input.int(0, "Golden Zone Extend Left", minval=0, maxval=5000)
goldenZoneExtendRight = input.int(120, "Golden Zone Extend Right", minval=1, maxval=5000)

// =====================================================
// TIME
// =====================================================

offsetMs = (utcOffsetH * 60 + utcOffsetM) * 60000
adjTime = useCustomUTC ? time + offsetMs : time

hh = hour(adjTime)
mm = minute(adjTime)

hm = hh * 60 + mm

// =====================================================
// CURRENT DAY FILTER
// =====================================================

currentDay = dayofmonth(time, "Europe/London")
todayDay = dayofmonth(timenow, "Europe/London")

isCurrentDay = currentDay == todayDay

// =====================================================
// SESSION STATES
// =====================================================

inAsia = false
inLondon = false
inNY = false

if useCustomUTC
    inAsia := hm >= 0 and hm < 360
    inLondon := hm >= 420 and hm < 960
    inNY := hm >= 750 and hm < 1260
else
    inAsia := not na(time(timeframe.period, "0000-0600", "Europe/London"))
    inLondon := not na(time(timeframe.period, "0700-1600", "Europe/London"))
    inNY := not na(time(timeframe.period, "1230-2100", "Europe/London"))

// =====================================================
// VOL WINDOWS
// =====================================================

inLondonVol = hm >= 420 and hm < 600
inNYVol = hm >= 750 and hm < 960
inAsiaVol = hm >= 0 and hm < 180

inVolWindow =
     (showLondonVol and inLondonVol) or
     (showNYVol and inNYVol) or
     (showAsiaVol and inAsiaVol)

// =====================================================
// SILVER BULLET WINDOWS
// =====================================================

inLondonSB = not na(time(timeframe.period, "1000-1100", "Europe/London"))
inNYAMSB = not na(time(timeframe.period, "1500-1600", "Europe/London"))
inNYPMSB = not na(time(timeframe.period, "2000-2100", "Europe/London"))

inSilverBullet = inLondonSB or inNYAMSB or inNYPMSB

// =====================================================
// VARIABLES
// =====================================================

var float aHigh = na
var float aLow = na
var float aMid = na

var float prevHigh = na
var float prevLow = na

var float londonHigh = na
var float londonLow = na

var float nyHigh = na
var float nyLow = na

var float volHigh = na
var float volLow = na

var float sbHigh = na
var float sbLow = na

// =====================================================
// BOXES
// =====================================================

var box asiaBox = na
var box londonBox = na
var box nyBox = na
var box volBox = na
var box sbBox = na

// =====================================================
// LINES
// =====================================================

var line asiaHighLine = na
var line asiaLowLine = na
var line asiaMidLine = na

var line fib50 = na
var line fib618 = na
var line fib705 = na

var linefill goldenZoneFill = na

// =====================================================
// ASIA SESSION
// =====================================================

if showAsiaSession and (showPreviousDays or isCurrentDay)

    if inAsia and not inAsia[1]

        aHigh := high
        aLow := low

        asiaBox := box.new(
             bar_index,
             high,
             bar_index,
             low,
             bgcolor=color.new(asiaSessionColor, asiaSessionOpacity),
             border_color=color.new(asiaSessionColor, 40))

    if inAsia

        aHigh := math.max(aHigh, high)
        aLow := math.min(aLow, low)

        box.set_right(asiaBox, bar_index)
        box.set_top(asiaBox, aHigh)
        box.set_bottom(asiaBox, aLow)

// =====================================================
// ASIA LEVELS + FIB
// =====================================================

if not inAsia and inAsia[1] and (showPreviousDays or isCurrentDay)

    prevHigh := aHigh
    prevLow := aLow

    aMid := (aHigh + aLow) / 2

    if showAsiaLevels

        asiaHighLine := line.new(
             bar_index,
             aHigh,
             bar_index + asiaLineLength,
             aHigh,
             color=asiaHighColor,
             width=1,
             style=line.style_dotted)

        asiaLowLine := line.new(
             bar_index,
             aLow,
             bar_index + asiaLineLength,
             aLow,
             color=asiaLowColor,
             width=1,
             style=line.style_dotted)

        label.new(
             bar_index + asiaLineLength,
             aHigh,
             "Asia High",
             style=label.style_none,
             textcolor=asiaHighLabelColor)

        label.new(
             bar_index + asiaLineLength,
             aLow,
             "Asia Low",
             style=label.style_none,
             textcolor=asiaLowLabelColor)

    if showAsiaMid

        asiaMidLine := line.new(
             bar_index,
             aMid,
             bar_index + midLineLength,
             aMid,
             color=asiaMidColor,
             width=1,
             style=line.style_dotted)

        label.new(
             bar_index + midLineLength,
             aMid,
             "Asia Mid",
             style=label.style_none,
             textcolor=asiaMidLabelColor)

    if showFib

        asiaRange = aHigh - aLow

        fib50Price  = aLow + asiaRange * 0.5
        fib618Price = aLow + asiaRange * 0.618
        fib705Price = aLow + asiaRange * 0.705

        leftBars  = math.max(bar_index - goldenZoneExtendLeft, 0)
        rightBars = bar_index + goldenZoneExtendRight

        if not na(fib50)
            line.delete(fib50)

        if not na(fib618)
            line.delete(fib618)

        if not na(fib705)
            line.delete(fib705)

        fib50 := line.new(
             leftBars,
             fib50Price,
             rightBars,
             fib50Price,
             color=fib50Color,
             width=1)

        fib618 := line.new(
             leftBars,
             fib618Price,
             rightBars,
             fib618Price,
             color=fib618Color,
             width=2)

        fib705 := line.new(
             leftBars,
             fib705Price,
             rightBars,
             fib705Price,
             color=fib705Color,
             width=2)

        if showGoldenZone

            if not na(goldenZoneFill)
                linefill.delete(goldenZoneFill)

            goldenZoneFill := linefill.new(
                 fib618,
                 fib705,
                 color=goldenZoneColor)

// =====================================================
// LONDON SESSION
// =====================================================

if showLondonSession and (showPreviousDays or isCurrentDay)

    if inLondon and not inLondon[1]

        londonHigh := high
        londonLow := low

        londonBox := box.new(
             bar_index,
             high,
             bar_index,
             low,
             bgcolor=color.new(londonSessionColor, londonSessionOpacity),
             border_color=color.new(londonSessionColor, 40))

    if inLondon

        londonHigh := math.max(londonHigh, high)
        londonLow := math.min(londonLow, low)

        box.set_right(londonBox, bar_index)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)

// =====================================================
// NEW YORK SESSION
// =====================================================

if showNYSession and (showPreviousDays or isCurrentDay)

    if inNY and not inNY[1]

        nyHigh := high
        nyLow := low

        nyBox := box.new(
             bar_index,
             high,
             bar_index,
             low,
             bgcolor=color.new(nySessionColor, nySessionOpacity),
             border_color=color.new(nySessionColor, 40))

    if inNY

        nyHigh := math.max(nyHigh, high)
        nyLow := math.min(nyLow, low)

        box.set_right(nyBox, bar_index)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)

// =====================================================
// VOL WINDOWS
// =====================================================

if inVolWindow and (showPreviousDays or isCurrentDay)

    if not inVolWindow[1]

        volHigh := high
        volLow := low

        volBox := box.new(
             bar_index,
             high,
             bar_index,
             low,
             bgcolor=color.new(volWindowColor, volWindowOpacity),
             border_color=color.new(volWindowColor, 30))

    if inVolWindow

        volHigh := math.max(volHigh, high)
        volLow := math.min(volLow, low)

        box.set_right(volBox, bar_index)
        box.set_top(volBox, volHigh)
        box.set_bottom(volBox, volLow)

// =====================================================
// SILVER BULLET
// =====================================================

if showSilverBullet and inSilverBullet and (showPreviousDays or isCurrentDay)

    if not inSilverBullet[1]

        sbHigh := high
        sbLow := low

        sbBox := box.new(
             bar_index,
             high,
             bar_index,
             low,
             bgcolor=color.new(silverBulletColor, silverBulletOpacity),
             border_color=color.new(silverBulletColor, 30))

    if inSilverBullet

        sbHigh := math.max(sbHigh, high)
        sbLow := math.min(sbLow, low)

        box.set_right(sbBox, bar_index)
        box.set_top(sbBox, sbHigh)
        box.set_bottom(sbBox, sbLow)

// =====================================================
// SWEEPS
// =====================================================

bearSweep =
     high > prevHigh and
     close < prevHigh and
     close < open

bullSweep =
     low < prevLow and
     close > prevLow and
     close > open

plotshape(
     showSweeps and bearSweep,
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.small)

plotshape(
     showSweeps and bullSweep,
     location=location.belowbar,
     style=shape.triangleup,
     color=color.green,
     size=size.small)

// =====================================================
// BOS
// =====================================================

bullBOS = bullSweep and close > high[1]
bearBOS = bearSweep and close < low[1]

plotshape(
     showBOS and bullBOS,
     location=location.belowbar,
     style=shape.circle,
     color=color.lime,
     size=size.tiny)

plotshape(
     showBOS and bearBOS,
     location=location.abovebar,
     style=shape.circle,
     color=color.red,
     size=size.tiny)

// =====================================================
// ENTRY SIGNALS
// =====================================================

buyEntry = bullBOS and inVolWindow
sellEntry = bearBOS and inVolWindow

plotshape(
     showEntries and buyEntry,
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY")

plotshape(
     showEntries and sellEntry,
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL")

// =====================================================
// JUDAS
// =====================================================

bullJudas =
     low < prevLow and
     close > prevLow and
     close > open and
     inVolWindow

bearJudas =
     high > prevHigh and
     close < prevHigh and
     close < open and
     inVolWindow

plotshape(
     showJudas and bullJudas,
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="JUDAS BUY")

plotshape(
     showJudas and bearJudas,
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="JUDAS SELL")

// =====================================================
// ALERTS
// =====================================================

alertcondition(bearSweep, "Asia High Sweep", "Asia High swept")
alertcondition(bullSweep, "Asia Low Sweep", "Asia Low swept")
alertcondition(buyEntry, "BUY Entry", "Bullish crypto entry")
alertcondition(sellEntry, "SELL Entry", "Bearish crypto entry")
alertcondition(bullJudas, "Bullish Judas", "Bullish Judas detected")
alertcondition(bearJudas, "Bearish Judas", "Bearish Judas detected")
````
