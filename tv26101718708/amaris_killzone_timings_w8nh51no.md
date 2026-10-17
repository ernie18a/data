# Amari's Killzone Timings

- url: https://www.tradingview.com/script/W8nh51nO-Amari-s-Killzone-Timings/
- type: indicator
- pine_id: PUB;a289db43064b4930812535ed1b34092a
- version: 1.0

## Description

Kill Zone Timings where the banks make their main moves

See the market’s key trading windows at a glance.

Stop wasting time manually tracking session times. ICT Kill Zone Boxes automatically highlights the key liquidity windows on your chart, giving you a clean visual reference for where important intraday price action may develop.

🎯 Four Key Sessions

The indicator automatically marks:

🔵 Asia — 10:00 PM to 7:00 AM

🟠 London — 8:00 AM to 9:00 AM

🔴 New York — 2:00 PM to 3:00 PM

🟣 London Close — 4:00 PM to 8:00 PM

Each session is displayed as a clean, transparent box that tracks the high and low formed during the session, making the range immediately visible without cluttering your chart.

⚡ Designed for Clean Charts

No unnecessary lines. No distracting borders. No complicated settings.

The boxes are intentionally minimal so you can keep your focus on price action, liquidity, and market structure.

The indicator also automatically hides itself when you switch to Daily or higher timeframes, keeping your higher-timeframe analysis clean.

🧠 Built for Intraday Traders & Swing Traders

Whether you're trading liquidity sweeps, session highs and lows, breakouts, reversals, or ICT/SMC-style setups, having the major trading windows clearly marked can help you understand when and where price is moving.

Know the session. Know the range. Read the reaction.

A cleaner way to visualise the market's most important intraday windows.

Disclaimer: This indicator is a charting and visualisation tool and does not provide financial advice or guarantee trading results.

## Source Code

````pine
 //@version=6
indicator("Amari's Killzone Timings", overlay=true, max_boxes_count=500)

// ───── Only show on intraday timeframes ─────
showIndicator = timeframe.isintraday

// ───── Colors ─────
asiaColor        = input.color(color.new(color.blue, 85), "Asia")
londonColor      = input.color(color.new(color.orange, 85), "London")
newYorkColor     = input.color(color.new(color.red, 85), "New York")
londonCloseColor = input.color(color.new(color.purple, 85), "London Close")

// ───── Session times ─────
asiaSession        = "2200-0700"
londonSession      = "0800-0900"
newYorkSession     = "1400-1500"
londonCloseSession = "1600-2000"

tz = "Europe/London"

// ───── Session states ─────
inAsia        = showIndicator and not na(time(timeframe.period, asiaSession, tz))
inLondon      = showIndicator and not na(time(timeframe.period, londonSession, tz))
inNewYork     = showIndicator and not na(time(timeframe.period, newYorkSession, tz))
inLondonClose = showIndicator and not na(time(timeframe.period, londonCloseSession, tz))

// ───── Variables ─────
var box asiaBox = na
var float asiaHigh = na
var float asiaLow = na

var box londonBox = na
var float londonHigh = na
var float londonLow = na

var box nyBox = na
var float nyHigh = na
var float nyLow = na

var box lcBox = na
var float lcHigh = na
var float lcLow = na

// ═══════════════════════════════════════
// ASIA
// ═══════════════════════════════════════
asiaStart = inAsia and not inAsia[1]

if asiaStart
    asiaHigh := high
    asiaLow := low

    asiaBox := box.new(
         left=bar_index,
         top=high,
         right=bar_index,
         bottom=low,
         bgcolor=asiaColor,
         border_color=na)

if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

    box.set_top(asiaBox, asiaHigh)
    box.set_bottom(asiaBox, asiaLow)
    box.set_right(asiaBox, bar_index)

// ═══════════════════════════════════════
// LONDON
// ═══════════════════════════════════════
londonStart = inLondon and not inLondon[1]

if londonStart
    londonHigh := high
    londonLow := low

    londonBox := box.new(
         left=bar_index,
         top=high,
         right=bar_index,
         bottom=low,
         bgcolor=londonColor,
         border_color=na)

if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)
    box.set_right(londonBox, bar_index)

// ═══════════════════════════════════════
// NEW YORK
// ═══════════════════════════════════════
nyStart = inNewYork and not inNewYork[1]

if nyStart
    nyHigh := high
    nyLow := low

    nyBox := box.new(
         left=bar_index,
         top=high,
         right=bar_index,
         bottom=low,
         bgcolor=newYorkColor,
         border_color=na)

if inNewYork
    nyHigh := math.max(nyHigh, high)
    nyLow := math.min(nyLow, low)

    box.set_top(nyBox, nyHigh)
    box.set_bottom(nyBox, nyLow)
    box.set_right(nyBox, bar_index)

// ═══════════════════════════════════════
// LONDON CLOSE
// ═══════════════════════════════════════
lcStart = inLondonClose and not inLondonClose[1]

if lcStart
    lcHigh := high
    lcLow := low

    lcBox := box.new(
         left=bar_index,
         top=high,
         right=bar_index,
         bottom=low,
         bgcolor=londonCloseColor,
         border_color=na)

if inLondonClose
    lcHigh := math.max(lcHigh, high)
    lcLow := math.min(lcLow, low)

    box.set_top(lcBox, lcHigh)
    box.set_bottom(lcBox, lcLow)
    box.set_right(lcBox, bar_index)
````
