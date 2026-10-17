# TRADING SESSION WITH ASIA HIGH SEPERATION

- url: https://www.tradingview.com/script/j0Ehq9dP-TRADING-SESSION-WITH-ASIA-HIGH-SEPERATION/
- type: indicator
- pine_id: PUB;a028ab79ccee483ebd146e33d862b533
- version: 1.0

## Description

TRADING SESSION WITH ASIA HIGH SEPERATION is a clean, customizable trading session indicator designed to help forex traders visualize the three major global trading sessions while tracking Asian session price extremes.

The indicator highlights the Asian, London, and New York trading sessions using customizable background colors, making it easier to identify market activity throughout the trading day.

Key Features

1. Trading Session Visualization

Asian Session

London Session

New York Session

Customizable session times, colors, and transparency

Automatic daily session identification

2. Asian Session High & Low Tracking

The indicator automatically tracks the highest and lowest prices reached during the Asian trading session.

Unlike traditional horizontal high/low indicators, TRADING SESSION WITH ASIA HIGH SEPERATION uses a staircase-style display that updates as new session highs or lows are established.

These levels are displayed only during the Asian session and stop when the session ends, providing a clean historical view of price development.

3. Clean Chart Design

The indicator is designed to minimize chart clutter while allowing traders to easily distinguish between trading sessions and observe how price behaves during different market hours.

How Traders Can Use It

Identify Asian session price ranges.

Observe how highs and lows develop during Asia.

Analyze price behavior approaching the London open.

Study potential liquidity sweeps and session breakouts.

Compare price action across major trading sessions.

Incorporate session analysis into existing trading strategies.

Customization

Users can adjust session opening and closing times, timezone, background colors, transparency, staircase line colors, and line thickness.

Recommended Markets

Designed primarily for Forex trading, but can also be used on indices, commodities, and other markets with intraday trading activity.

Disclaimer

TRADING SESSION WITH ASIA HIGH SEPERATION is a market visualization tool, not a standalone buy or sell signal indicator. It does not guarantee profitable trades. Traders should combine session analysis with their own strategies and risk management. TRADING SESSION WITH ASIA HIGH SEPERATION is a clean, customizable trading session indicator designed to help forex traders visualize the three major global trading sessions while tracking Asian session price extremes.

The indicator highlights the Asian, London, and New York trading sessions using customizable background colors, making it easier to identify market activity throughout the trading day.

Key Features

1. Trading Session Visualization

Asian Session

London Session

New York Session

Customizable session times, colors, and transparency

Automatic daily session identification

2. Asian Session High & Low Tracking

The indicator automatically tracks the highest and lowest prices reached during the Asian trading session.

Unlike traditional horizontal high/low indicators, TRADING SESSION WITH ASIA HIGH SEPERATION uses a staircase-style display that updates as new session highs or lows are established.

These levels are displayed only during the Asian session and stop when the session ends, providing a clean historical view of price development.

3. Clean Chart Design

The indicator is designed to minimize chart clutter while allowing traders to easily distinguish between trading sessions and observe how price behaves during different market hours.

How Traders Can Use It

Identify Asian session price ranges.

Observe how highs and lows develop during Asia.

Analyze price behavior approaching the London open.

Study potential liquidity sweeps and session breakouts.

Compare price action across major trading sessions.

Incorporate session analysis into existing trading strategies.

Customization

Users can adjust session opening and closing times, timezone, background colors, transparency, staircase line colors, and line thickness.

Recommended Markets

Designed primarily for Forex trading, but can also be used on indices, commodities, and other markets with intraday trading activity.

Disclaimer

TRADING SESSION WITH ASIA HIGH SEPERATION is a market visualization tool, not a standalone buy or sell signal indicator. It does not guarantee profitable trades. Traders should combine session analysis with their own strategies and risk management.

## Source Code

````pine

 //@version=6
indicator("PATI TRADING SESSION", overlay=true)

// TIMEZONE
tz = input.string("America/New_York", "Timezone")

// SESSION TIMES
asia = input.session("1900-0300", "Asia Session")
london = input.session("0300-1100", "London Session")
ny = input.session("0800-1700", "New York Session")

// BACKGROUND COLORS
asiaBg = input.color(color.new(color.gray, 95), "Asia Background")
londonBg = input.color(color.new(#FF69B4, 75), "London Background")
nyBg = input.color(color.new(color.green, 75), "NY Background")

// LINE SETTINGS
stepColor = input.color(color.black, "Asia Step Line Color")
stepWidth = input.int(2, "Step Line Width", minval=1, maxval=5)

// SESSION DETECTION
inAsia = not na(time(timeframe.period, asia, tz))
inLondon = not na(time(timeframe.period, london, tz))
inNY = not na(time(timeframe.period, ny, tz))

asiaStart = inAsia and not inAsia[1]

// SESSION BACKGROUNDS
// New York takes priority during overlapping hours.
bgcolor(inNY ? nyBg : inLondon ? londonBg : inAsia ? asiaBg : na)

// TRACK ASIAN SESSION HIGH AND LOW
var float asiaHigh = na
var float asiaLow = na

// Reset when Asia begins
if asiaStart
    asiaHigh := high
    asiaLow := low
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

// Display connected staircase lines.
// Values become na outside Asia, so the lines stop.
plot(inAsia ? asiaHigh : na,
     title="Asia Stepped High",
     color=stepColor,
     linewidth=stepWidth,
     style=plot.style_steplinebr)

plot(inAsia ? asiaLow : na,
     title="Asia Stepped Low",
     color=stepColor,
     linewidth=stepWidth,
     style=plot.style_steplinebr)
````
