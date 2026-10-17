# RS Levels

- url: https://www.tradingview.com/script/Jg6UgoPF-RS-Levels/
- type: indicator
- pine_id: PUB;c586057e88764cd8a0ef96cb39dee770
- version: 8.0

## Description

This indicator is a daily market reference map that projects a set of predefined bullish, bearish, and key reference levels onto the current chart and keeps them visible throughout the trading session.

** Note this only works on the ES or MES instruments and they MUST be set to the 1 Minute timeframe. Other timeframes will not produce the correct result. If you need the levels on other timeframes, make hozizontal lines on the 1M and change to another timeframe. **


At the start of the regular trading day, it establishes a relationship between the instrument being charted and a reference market. Using that relationship, it translates a collection of important price zones and levels onto the chart so they remain aligned with the current session.

The display includes:

Bullish zones (green highlighted areas) that represent upside target or support regions.
Bearish zones (red highlighted areas) that represent downside target or resistance regions.
Opening and closing reference levels from the reference market.
A midpoint level between the open and close, labeled as a point of control (POC).
A predefined daily low and daily high range.
Additional custom reference levels labeled MHP and HP.

The script automatically:

Draws the zones and levels once each trading day.
Labels every zone and line for easy identification.
Extends all zones, lines, and labels forward as new bars appear so the map remains visible throughout the session.
Allows each individual level or zone to be turned on or off through settings.

In practical terms, this acts as a session framework tool that overlays a set of predetermined support, resistance, target, and reference areas onto the chart, giving traders a visual roadmap of where important reactions may occur during the trading day.

## Source Code

````pine
//@version=6
indicator("Rocket Scooter is Fraud NOTICE: This indicator has been discontinued", overlay = true)


// This script has been intentionally cleared. 
// The methodology previously associated with this indicator is simply on up days buy. 
// There is not way to know if it is an up day. But if you buy and hold in a bull trend you will win ~60% of the time.
// Rocket Scooter takes the basic stat and has you buy every day. On many days IF you and hold long enough it may work.
// The most likely outcome is that you will bust out the account.
// He is a affiliate of may Prop Firms. The more accounts you bust out the more money he makes. 
// so, if it works you pay a month fee. If it does not you say nothing is perfect. WHEN you bust out accounts, you use his code and make him money.
//  I stopped this code becuase I do not want to be affiliated with this fruad once i discovered it
// Please exercise caution with financial products sold via this system.
plot(na)
````
