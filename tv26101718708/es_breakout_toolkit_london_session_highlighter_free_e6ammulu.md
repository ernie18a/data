# ES Breakout Toolkit London Session Highlighter Free

- url: https://www.tradingview.com/script/e6AmMULu-ES-Breakout-Toolkit-London-Session-Highlighter-Free/
- type: indicator
- pine_id: PUB;180717ef757a45ab8ec4a24f4cb34660
- version: 1.0

## Description

PART OF THE ES BREAKOUT TOOLKIT 
This is one of several free, standalone indicators that make up the ES Breakout Toolkit series. Each indicator isolates a single component used in the full ES London Breakout Pro strategy. They are designed to be useful on their own and educational for traders studying London session price action on ES futures.

WHAT THIS INDICATOR DOES
The London Session Highlighter marks the 12:00 AM - 6:00 AM Pacific Time window directly on your chart. During this session, it tracks and displays the developing session high, session low, and session open price as real-time reference levels. When the session closes, it labels the total range in points.

A small dashboard in the top-right corner shows whether the session is currently active, the session high and low, and the current range expressed as a multiple of ATR(20). This gives you an immediate sense of whether the session is producing normal or extended price action relative to recent volatility.

HOW TO USE IT 
Apply this indicator to any ES futures chart on a 5-minute timeframe. The session start and end hours are adjustable in the inputs if you want to monitor a different window. The background highlight, range lines, and open line can each be toggled on or off depending on your preference.

The Range/ATR reading in the dashboard is particularly useful for gauging whether the session has room to expand or is already stretched. Values below 1.0x suggest a quiet session with potential for a breakout. Values above 2.0x suggest the session has already made a significant move.

KEY FEATURES
- Configurable session window (defaults to London 12AM-6AM PT)
- Real-time session high/low/open tracking
- Session range label on close
- Range vs ATR dashboard for context
- Clean, minimal chart overlay
- Alert not included — this is a visual reference tool

ABOUT THE ES BREAKOUT TOOLKIT
This indicator is part of a free series that breaks down the building blocks of a London session ES futures breakout strategy. Other free indicators in the series cover consolidation range detection, ADX regime filtering, breakout candle scanning, and momentum close analysis. Each is published separately on my profile.

The full ES London Breakout Pro indicator combines all of these components into a unified strategy with additional proprietary features including advanced risk management, trade qualification, and data tracking. It is available as an invite-only script on my profile. Use the access request instructions on that script's page if you are interested.

DISCLAIMER
This indicator is provided for educational and informational purposes only. It is NOT financial advice. It does not constitute a recommendation to buy, sell, or hold any financial instrument. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial advisor before making any trading decisions. You are solely responsible for your own trading activity.

## Source Code

````pine
//@version=6
indicator("[ES Breakout Toolkit] London Session Highlighter — Free", overlay=true)

// ==================== INPUTS ====================
sessionStart = input.int(0, "Session Start (PT Hour)", minval=0, maxval=23)
sessionEnd = input.int(6, "Session End (PT Hour)", minval=0, maxval=23)
showBackground = input.bool(true, "Highlight Session Background")
showRange = input.bool(true, "Show Session High/Low Range")
showOpenClose = input.bool(true, "Show Open/Close Lines")
bgColor = input.color(color.new(color.teal, 90), "Session Background Color")
rangeHighColor = input.color(color.new(color.lime, 30), "Range High Color")
rangeLowColor = input.color(color.new(color.red, 30), "Range Low Color")
openColor = input.color(color.new(color.white, 40), "Open Line Color")

// ==================== SESSION DETECTION ====================
ptHour = hour(time, "America/Los_Angeles")
inSession = ptHour >= sessionStart and ptHour < sessionEnd
prevInSession = hour(time[1], "America/Los_Angeles") >= sessionStart and hour(time[1], "America/Los_Angeles") < sessionEnd
sessionOpen = inSession and not prevInSession
sessionClose = not inSession and prevInSession

// ==================== SESSION RANGE TRACKING ====================
var float sessHigh = na
var float sessLow = na
var float sessOpenPx = na

if sessionOpen
    sessHigh := high
    sessLow := low
    sessOpenPx := open

if inSession
    sessHigh := math.max(nz(sessHigh, high), high)
    sessLow := math.min(nz(sessLow, low), low)

// ==================== SESSION STATS ====================
sessRange = inSession and not na(sessHigh) and not na(sessLow) ? sessHigh - sessLow : na
atr = ta.atr(20)
rangeVsATR = not na(sessRange) and atr > 0 ? sessRange / atr : na

// ==================== PLOTTING ====================
bgcolor(showBackground and inSession ? bgColor : na, title="Session Background")
plot(showRange and inSession ? sessHigh : na, title="Session High", color=rangeHighColor, style=plot.style_linebr, linewidth=2)
plot(showRange and inSession ? sessLow : na, title="Session Low", color=rangeLowColor, style=plot.style_linebr, linewidth=2)
plot(showOpenClose and inSession ? sessOpenPx : na, title="Session Open", color=openColor, style=plot.style_linebr, linewidth=1)

// ==================== SESSION CLOSE MARKER ====================
if sessionClose and not na(sessHigh) and not na(sessLow)
    rangeText = str.tostring(sessHigh - sessLow, "#.##") + " pts"
    label.new(bar_index, sessHigh, rangeText, style=label.style_label_down, color=color.new(color.teal, 50), textcolor=color.white, size=size.tiny)

// ==================== DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 10), border_width=1)
table.cell(dash, 0, 0, "London Session", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 1, 0, inSession ? "ACTIVE" : "CLOSED", text_color=inSession ? color.lime : color.gray, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 0, 1, "Status", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 1, str.tostring(sessionStart) + ":00 - " + str.tostring(sessionEnd) + ":00 PT", text_color=color.white, text_size=size.small)
table.cell(dash, 0, 2, "Session High", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 2, inSession and not na(sessHigh) ? str.tostring(sessHigh, "#.##") : "---", text_color=color.lime, text_size=size.small)
table.cell(dash, 0, 3, "Session Low", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 3, inSession and not na(sessLow) ? str.tostring(sessLow, "#.##") : "---", text_color=color.red, text_size=size.small)
table.cell(dash, 0, 4, "Range / ATR", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 4, not na(rangeVsATR) ? str.tostring(rangeVsATR, "#.##") + "x" : "---", text_color=not na(rangeVsATR) and rangeVsATR <= 1.5 ? color.lime : color.yellow, text_size=size.small)
````
