<!-- tradingview-pine-id: PUB;b4511e1befc242f4bd3b0146e7b0e593 -->
<!-- tradingviewscripts-format: 1 -->
# Renko Timestamp Highlighter

Source: https://www.tradingview.com/script/DzR1Tvfz-Renko-Timestamp-Highlighter/

## Description

Renko Timestamp Highlighter — a Pine Script v6 overlay indicator that colors Renko bricks whose own formation-start timestamp matches a configurable hour:minute (default 9:15, NSE open), using exchange timezone. It compares hour(time, syminfo.timezone)/minute(...) against user inputs and applies barcolor(). Since Renko bricks form asynchronously, only bricks that happen to begin exactly at that minute get highlighted — gap bursts can highlight multiple bricks at once. Visual aid only, no signals.

This will be very useful to see the gaps in renko charts which is mostly non tradeable and understand the chart better

---

## Source Code

````pine
//@version=6
//@description Highlights Renko bricks whose own formation timestamp matches a chosen exchange-time hour and minute (default 9:15, NSE open)

// ============================================================================
// RENKO 9:15 SESSION-OPEN TIMESTAMP HIGHLIGHTER
// ============================================================================
//
// OVERVIEW
// ========
// On non-standard chart types (Renko, Point & Figure, Kagi), each brick
// carries its own "time" value — the moment it began forming, not a fixed
// clock interval. This script checks that timestamp against a configurable
// hour and minute (in the exchange's own timezone) and colors the brick when
// they match, making it easy to spot the session-open brick at a glance.
//
// FEATURES
// ========
// • Works with any Renko brick size or box configuration
// • Configurable target hour and minute (default 9:15 for NSE)
// • Configurable highlight color
// • Uses the exchange's own timezone (syminfo.timezone), not chart timezone
//
// NOTES
// =====
// • A brick's timestamp is its formation-START time. A gap can cause several
//   bricks to form in a burst sharing the same timestamp — all matching
//   bricks will be highlighted. This is expected Renko behavior.
// • A trading day is only highlighted if a brick happened to begin forming
//   exactly at the target minute; this is a property of how Renko bricks
//   form and is not adjustable.
// • Visual aid only — does not generate buy/sell signals or trading advice.
//
// ============================================================================

indicator("Renko Timestamp Highlighter", overlay=true)

highlightColor = input.color(#FFFFFF00, "Highlight Color", tooltip="Color for any box/brick whose own timestamp is exactly the session-open minute")
openHour = input.int(9, "Timestamp hour", minval=0, maxval=23, tooltip="Exchange-time hour to match (9 for NSE)")
openMinute = input.int(15, "Timestamp minute", minval=0, maxval=59, tooltip="Exchange-time minute to match (15 for NSE)")

// Matches the brick's own chart timestamp — on Renko that is the brick's
// formation-START time, so a day only gets a highlight if some brick began
// forming at exactly 9:15, and a gap burst can stamp several bricks with the
// same 9:15 time (all of them will be colored).
isStampMatch = hour(time, syminfo.timezone) == openHour and minute(time, syminfo.timezone) == openMinute

barcolor(isStampMatch ? highlightColor : na, title="9:15 Timestamp Box")
````
