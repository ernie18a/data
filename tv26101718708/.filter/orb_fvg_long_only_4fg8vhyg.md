# ORB + FVG Long Only

- url: https://www.tradingview.com/script/4fg8vhYG-ORB-FVG-Long-Only/
- type: indicator
- pine_id: PUB;cc762470c3bc4206a88a6d0ccd1fc991
- version: 1.0

## Description

🎯 TL;DR
Opening Range Breakout for NQ futures, long-only. Marks the first 15
minutes after NY open, then signals a BUY when price breaks above that
range during the morning Power Hour — but only if 6 smart filters
confirm the conditions are right. Auto-draws your full trade plan
(Entry, Stop, TP1, TP2) the moment a signal fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 SUPER SIMPLE — How To Use This

1. Watch your chart during 9:30–11:00 AM EST.

2. Wait for a GREEN TRIANGLE 🔺 with a "🚀 BUY 🚀" label.

3. When you see it:
   • BUY at the black line (Entry)
   • Stop loss at the RED line
   • Take Profit 1 at the GREEN line
   • Take Profit 2 at the LIME line

4. Walk away. The lines are drawn for you.

No triangle = no trade. The indicator checks everything for you —
you just execute what it draws.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 OPENING RANGE BREAKOUT + FAIR VALUE GAPS
Long-Only · Built for NQ/MNQ futures · NY session

🟢 WHAT IT DOES
This indicator combines the classic Opening Range Breakout setup with
ICT Fair Value Gap detection and a stack of smart filters designed to
skip low-quality, choppy days. When a clean bullish breakout fires, it
auto-plots a complete trade plan — Entry, Stop Loss, and two Take
Profit targets — with R-multiples and dollar values, right on your
chart.

📋 HOW IT WORKS
1. Marks the High and Low of the first 15 minutes after NY open
   (9:30–9:45 AM EST) — the "Opening Range"
2. Watches for a breakout above the OR High during the morning
   Power Hour window (9:30–11:00 AM EST)
3. Confirms the breakout against 6 smart filters
4. Fires a single, clear BUY signal with an alert
5. Auto-draws the trade plan: Entry / SL / TP1 / TP2

🔍 6 SMART FILTERS
✅ Bullish daily bias — price above today's open
✅ 20-EMA uptrend — daily trend confirmation
✅ Trend-day filter — yesterday closed strong
✅ Power Hour window — restricts signals to the highest-quality hours
✅ Loss streak protection — pauses after consecutive weak days
✅ Volume confirmation (optional) — breakout backed by real volume
✅ FVG confluence (optional) — require a fresh bullish Fair Value Gap

📈 AUTO-PLOTTED TRADE PLAN
When a BUY fires, the indicator instantly draws:
• Entry line (black)
• Stop Loss (red) — configurable: OR Low / OR Midpoint / ATR-based
• TP1 (green) — default 2R
• TP2 (lime) — default 4R
• Labels showing prices AND dollar amounts
Lines auto-cap at 4 PM EST so they never bleed into the next day.

🎛️ FAIR VALUE GAPS
• Detects bullish and bearish 3-candle imbalances
• Drawn as clean translucent boxes
• Close-based mitigation — gaps are removed once price closes through
  them (stricter, more accurate than wick-touch)
• Optional: require a recent bullish FVG before a BUY can fire

🕐 OPENING RANGE VISUALIZATION
• OR box over the 9:30–9:45 window
• OR High / Low / Midpoint lines extend through the session
• Price labels on the right edge

📊 FILTER STATUS DASHBOARD
A compact panel shows each filter's live status (✓ / ✗) and an
overall READY 🟢 / 🔴 light — so you can see at a glance how close
the setup is to triggering.

📱 ALERTS
Built-in alert fires on every BUY signal — works with TradingView's
push notification system for phone alerts. Custom message includes
ticker, breakout price, and entry.

⚙️ FULLY CONFIGURABLE
• Opening Range window time
• Trade window (Power Hour) time
• Every filter individually toggleable
• R-multiples for TP1 / TP2
• Stop loss placement method
• Line extension length
• Label sizes (tiny → huge)
• Zen Mode — hides all context, shows only the signal + trade plan

🛡️ ANTI-REPAINT
Signals confirm on bar close — what you see is final. No flickering,
no after-the-fact repainting.

⚠️ DISCLAIMER
This indicator is for educational and informational purposes only.
It is not financial advice. Trading futures involves substantial risk
of loss and is not suitable for everyone. Always practice on a demo
account before risking real capital. The author is not responsible
for any trading losses incurred using this tool.

🚀 INITIAL RELEASE — v1.0

Features:
• Opening Range Breakout detection (configurable window)
• 6-filter confluence system for high-quality entries
• Auto-plotted trade plan — Entry / SL / TP1 / TP2 with R-multiples
  and dollar values
• Fair Value Gap detection with close-based mitigation
• Optional FVG confluence requirement for entries
• Optional volume confirmation filter
• Filter status dashboard with READY light
• Configurable stop placement (OR Low / OR Midpoint / ATR)
• Lines auto-cap at 4 PM EST — no overflow into the next day
• Anti-repaint — signals confirm on bar close
• Zen Mode for clean, distraction-free execution
• Comma-formatted price labels, adjustable label sizes
• Built-in alerts compatible with mobile push notifications

Notes:
• Long-only by design
• Built and tuned for NQ/MNQ — works on other liquid instruments
• Default trade window is the morning Power Hour (9:30–11:00 EST)
• Always forward-test on a demo account before going live

## Source Code

````pine
//@version=6
indicator("ORB + FVG [NQ Long]", shorttitle="ORB+FVG", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =============================================================================
// INPUTS — same as ORB v2, plus FVG controls
// =============================================================================
grp_or = "Opening Range"
orSession   = input.session("0930-0945", "Opening Range Window (EST)", group=grp_or)
showORBox   = input.bool(true, "Show OR Box", group=grp_or)
colORBox    = input.color(color.new(color.blue, 85), "OR Box Color", group=grp_or)
showORLines = input.bool(true, "Show OR High/Low Lines", group=grp_or)
colORHigh   = input.color(color.new(color.lime, 30), "OR High Color", group=grp_or)
colORLow    = input.color(color.new(color.red, 30),  "OR Low Color",  group=grp_or)

grp_filter = "Smart Filters (v2)"
tradeSessionStr = input.session("0930-1100", "Trade Window (Power Hour)", group=grp_filter)
useDailyBias    = input.bool(true,  "Require Bullish Daily Bias", group=grp_filter)
useTrendFilter  = input.bool(true,  "Trend-Day Filter", group=grp_filter)
useMAFilter     = input.bool(true,  "Daily 20-EMA Uptrend Filter", group=grp_filter)
useLossStreakFilter = input.bool(true, "Skip After 2 Losing Days", group=grp_filter)
oneTradePerDay  = input.bool(true,  "Max 1 Long Per Day", group=grp_filter)
useVolumeFilter = input.bool(false, "Volume Confirmation", group=grp_filter, tooltip="Require breakout volume > N x 20-bar avg. Filters weak breakouts.")
volMultiplier   = input.float(1.2, "Volume Multiplier", minval=1.0, maxval=5.0, step=0.1, group=grp_filter, tooltip="Breakout bar volume must be > this × 20-bar SMA. Default 1.2 = 20% above avg.")

grp_fvg = "Fair Value Gaps"
showFVG         = input.bool(true, "Show Fair Value Gaps", group=grp_fvg)
fvgExtendBars   = input.int(30, "FVG Extension Bars", minval=5, maxval=200, group=grp_fvg)
mitigateFVG     = input.bool(true, "Auto-remove Filled FVGs", group=grp_fvg)
colBullFVG      = input.color(color.new(color.green, 80), "Bullish FVG Color", group=grp_fvg)
colBearFVG      = input.color(color.new(color.red, 85),   "Bearish FVG Color (resistance)", group=grp_fvg)
requireFVGConfluence = input.bool(false, "🔒 REQUIRE Bull FVG Confluence For Entry", group=grp_fvg, tooltip="When ON: only fire BUY signal if a bullish FVG formed within the lookback window. Makes signals stricter.")
fvgLookback     = input.int(10, "FVG Lookback (bars)", minval=1, maxval=50, group=grp_fvg, tooltip="How far back to check for bullish FVG when confluence is required")

grp_exit = "Exit & Risk (v2)"
stopType        = input.string("OR Midpoint", "Stop Loss Placement", options=["OR Low", "OR Midpoint", "Fixed ATR"], group=grp_exit)
atrStopMult     = input.float(1.5, "ATR Stop Multiplier", minval=0.5, maxval=5.0, step=0.1, group=grp_exit)
tp1RR           = input.float(1.0, "TP1 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, group=grp_exit)
tp2RR           = input.float(2.0, "TP2 Risk:Reward", minval=0.5, maxval=10.0, step=0.5, group=grp_exit)
useBreakeven    = input.bool(true, "SL → Breakeven After TP1 Hit", group=grp_exit)
showTradePlan   = input.bool(true, "Auto-plot Entry/SL/TP Lines", group=grp_exit)
maxLineBars     = input.int(60, "Max Line Extension (bars)", minval=5, maxval=500, group=grp_exit, tooltip="How far right to extend Entry/SL/TP lines. Lines auto-stop at 4 PM EST regardless.")
endLinesAtSession = input.bool(true, "Cap Lines at 4 PM EST", group=grp_exit, tooltip="Lines automatically end at NY session close so they don't bleed into next day. Past day lines remain visible.")

grp_view = "Visual"
zenMode = input.bool(false, "🧘 Zen Mode", group=grp_view)
showDashboards = input.bool(true, "Show Status Dashboards", group=grp_view, tooltip="Toggle the trade plan + filter status boxes on the chart")
labelSizeStr = input.string("normal", "Label Size", options=["tiny", "small", "normal", "large", "huge"], group=grp_view, tooltip="Size of Entry/SL/TP1/TP2 labels on chart")
labelSize = labelSizeStr == "tiny" ? size.tiny : labelSizeStr == "small" ? size.small : labelSizeStr == "normal" ? size.normal : labelSizeStr == "large" ? size.large : size.huge

// =============================================================================
// HELPERS
// =============================================================================
inSession(s) =>
    not na(time(timeframe.period, s, "America/New_York"))

orTime     = inSession(orSession)
tradeOK    = inSession(tradeSessionStr)
atr        = ta.atr(14)
dailyOpen  = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_off)
dailyEMA20 = request.security(syminfo.tickerid, "D", ta.ema(close, 20), lookahead=barmerge.lookahead_off)

// =============================================================================
// PRIOR DAY DATA (for trend filter)
// =============================================================================
priorDayHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_off)
priorDayLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_off)
priorDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)
priorDayRange = priorDayHigh - priorDayLow
priorDayClosePos = priorDayRange > 0 ? (priorDayClose - priorDayLow) / priorDayRange : 0.5
trendDayOK = priorDayClosePos >= 0.5

// =============================================================================
// TRACK OPENING RANGE
// =============================================================================
var float orHigh = na
var float orLow  = na
var bool  orLocked = false
var int   orStartBar = na
var int   orEndBar   = na
var bool  tradeTakenToday = false

newDay = ta.change(time("D")) != 0

if newDay
    orHigh := na
    orLow  := na
    orLocked := false
    orStartBar := na
    orEndBar := na
    tradeTakenToday := false

if orTime
    if na(orStartBar)
        orStartBar := bar_index
        orHigh := high
        orLow  := low
    else
        orHigh := math.max(orHigh, high)
        orLow  := math.min(orLow,  low)

orJustEnded = not orTime and orTime[1]
if orJustEnded
    orLocked := true
    orEndBar := bar_index - 1

// =============================================================================
// LOSS STREAK PROXY
// =============================================================================
var int consecLossDays = 0
prevDayBearish = priorDayClose < priorDayLow + (priorDayRange * 0.4)
if newDay
    if prevDayBearish
        consecLossDays := consecLossDays + 1
    else
        consecLossDays := 0
lossStreakOK = useLossStreakFilter ? consecLossDays < 2 : true

// =============================================================================
// FAIR VALUE GAPS
// =============================================================================
var array<box> bullFVGs = array.new<box>()
var array<box> bearFVGs = array.new<box>()
var int lastBullFVGBar = -999  // for confluence check

bullFVGNew = low > high[2]
bearFVGNew = high < low[2]

if bullFVGNew
    lastBullFVGBar := bar_index
    if showFVG and not zenMode
        bx = box.new(bar_index - 2, low, bar_index + fvgExtendBars, high[2], border_color=na, bgcolor=colBullFVG)
        array.push(bullFVGs, bx)

if bearFVGNew
    if showFVG and not zenMode
        bx = box.new(bar_index - 2, high, bar_index + fvgExtendBars, low[2], border_color=na, bgcolor=colBearFVG)
        array.push(bearFVGs, bx)

// FVG mitigation: CLOSE-based (stricter ICT interpretation)
// Bull FVG: mitigated when bar CLOSE enters or passes the gap top (not just wick)
// Bear FVG: mitigated when bar CLOSE enters or passes the gap bottom
if mitigateFVG
    if array.size(bullFVGs) > 0
        for i = array.size(bullFVGs) - 1 to 0
            bx = array.get(bullFVGs, i)
            if close <= box.get_top(bx)
                box.delete(bx)
                array.remove(bullFVGs, i)
    if array.size(bearFVGs) > 0
        for i = array.size(bearFVGs) - 1 to 0
            bx = array.get(bearFVGs, i)
            if close >= box.get_bottom(bx)
                box.delete(bx)
                array.remove(bearFVGs, i)

// FVG confluence check (for entry filter)
barsSinceBullFVG = bar_index - lastBullFVGBar
fvgConfluence = requireFVGConfluence ? barsSinceBullFVG <= fvgLookback : true

// =============================================================================
// VISUAL: OR BOX + LINES
// =============================================================================
zShowBox   = zenMode ? false : showORBox
zShowLines = zenMode ? true  : showORLines

var box orBox = na
if orJustEnded and zShowBox and not na(orHigh)
    if not na(orBox)
        box.delete(orBox)
    orBox := box.new(orStartBar, orHigh, orEndBar, orLow, border_color=color.new(color.blue, 50), bgcolor=colORBox)

var line orHiLine = na
var line orLoLine = na
var line orMidLine = na
var label orHiLabel = na
var label orLoLabel = na

if orJustEnded and zShowLines and not na(orHigh)
    if not na(orHiLine)
        line.delete(orHiLine)
    if not na(orLoLine)
        line.delete(orLoLine)
    if not na(orMidLine)
        line.delete(orMidLine)
    if not na(orHiLabel)
        label.delete(orHiLabel)
    if not na(orLoLabel)
        label.delete(orLoLabel)
    midOR = (orHigh + orLow) / 2
    orHiLine := line.new(orEndBar, orHigh, bar_index + 80, orHigh, color=colORHigh, width=2)
    orLoLine := line.new(orEndBar, orLow,  bar_index + 80, orLow,  color=colORLow,  width=2)
    orMidLine := line.new(orEndBar, midOR, bar_index + 80, midOR, color=color.new(color.gray, 60), width=1, style=line.style_dotted)
    orHiLabel := label.new(bar_index + 80, orHigh, "OR Hi " + str.tostring(orHigh, "#,###.##"), style=label.style_label_left, color=color.new(color.lime, 60), textcolor=color.white, size=size.small)
    orLoLabel := label.new(bar_index + 80, orLow,  "OR Lo " + str.tostring(orLow, "#,###.##"),  style=label.style_label_left, color=color.new(color.red, 60),  textcolor=color.white, size=size.small)

// =============================================================================
// LONG BREAKOUT SIGNAL
// =============================================================================
biasOK    = useDailyBias    ? close > dailyOpen : true
maOK      = useMAFilter     ? close > dailyEMA20 : true
trendOK   = useTrendFilter  ? trendDayOK : true
limitOK   = oneTradePerDay  ? not tradeTakenToday : true

// Volume filter (NEW): require breakout bar volume > N x 20-bar avg
avgVol    = ta.sma(volume, 20)
volumeOK  = useVolumeFilter ? volume > (avgVol * volMultiplier) : true

breakout = orLocked and close > orHigh and close[1] <= orHigh

// Require bar close confirmation to prevent intra-bar repaint of visuals/signals
confirmedBar = barstate.isconfirmed or barstate.ishistory

longSignal = breakout and tradeOK and biasOK and maOK and trendOK and lossStreakOK and limitOK and fvgConfluence and volumeOK and confirmedBar

if longSignal
    tradeTakenToday := true

// =============================================================================
// VISUAL BUY SIGNAL
// =============================================================================
plotshape(longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.large)
bgcolor(longSignal ? color.new(color.lime, 70) : na, title="Buy Flash")

if longSignal
    label.new(bar_index, high, "🚀 BUY 🚀", style=label.style_label_down, color=color.lime, textcolor=color.black, size=size.normal)

if longSignal
    alert("🚀 ORB+FVG LONG\nSymbol: " + syminfo.ticker + "\nBreakout: " + str.tostring(orHigh, "#.##") + "\nPrice: " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)

// =============================================================================
// TRADE PLAN — Lines drawn on signal, dashboard tracks ACTIVE trade only
// =============================================================================
var float lastEntry = na
var float lastSL    = na
var float lastTP1   = na
var float lastTP2   = na

// Keep latest signal levels visible (don't auto-clear)
// Track active/closed status for dashboard
var bool tradeWon  = false
var bool tradeLost = false

if not na(lastEntry)
    if high >= lastTP2
        tradeWon := true
    if low <= lastSL and not tradeWon
        tradeLost := true

if showTradePlan and longSignal
    tradeWon := false
    tradeLost := false
    midOR = (orHigh + orLow) / 2
    sl_calc = stopType == "OR Low" ? orLow : stopType == "OR Midpoint" ? midOR : close - (atr * atrStopMult)
    risk_calc = close - sl_calc
    if risk_calc > 0
        entry_calc = close
        tp1_calc   = entry_calc + (risk_calc * tp1RR)
        tp2_calc   = entry_calc + (risk_calc * tp2RR)
        lastEntry := entry_calc
        lastSL    := sl_calc
        lastTP1   := tp1_calc
        lastTP2   := tp2_calc

        // Calculate line end: cap at 4 PM EST and/or maxLineBars
        hrNY    = hour(time, "America/New_York")
        mnNY    = minute(time, "America/New_York")
        minLeft = math.max(0, (16 * 60) - (hrNY * 60 + mnNY))
        tfMinutes = timeframe.in_seconds(timeframe.period) / 60.0
        barsLeft = tfMinutes > 0 ? math.floor(minLeft / tfMinutes) : maxLineBars
        rightBar = endLinesAtSession ? bar_index + math.min(maxLineBars, barsLeft) : bar_index + maxLineBars
        if rightBar <= bar_index
            rightBar := bar_index + 1

        // BIG colored lines + labels — drawn NOW on signal bar, persist forever
        line.new(bar_index, entry_calc, rightBar, entry_calc, color=color.new(color.black, 0),  width=3, style=line.style_solid)
        line.new(bar_index, sl_calc,    rightBar, sl_calc,    color=color.new(color.red, 0),    width=4, style=line.style_solid)
        line.new(bar_index, tp1_calc,   rightBar, tp1_calc,   color=color.new(color.green, 0),  width=4, style=line.style_solid)
        line.new(bar_index, tp2_calc,   rightBar, tp2_calc,   color=color.new(color.lime, 0),   width=5, style=line.style_solid)

        label.new(rightBar, entry_calc, "⚫ ENTRY " + str.tostring(entry_calc, "#,###.##"),
                  style=label.style_label_left, color=color.new(color.black, 0), textcolor=color.white, size=labelSize)
        label.new(rightBar, sl_calc, "🔴 SL " + str.tostring(sl_calc, "#,###.##") + " (-$" + str.tostring((entry_calc - sl_calc) * 2, "#,###") + ")",
                  style=label.style_label_left, color=color.new(color.red, 0), textcolor=color.white, size=labelSize)
        label.new(rightBar, tp1_calc, "🟢 TP1 " + str.tostring(tp1_calc, "#,###.##") + " (+$" + str.tostring((tp1_calc - entry_calc) * 2, "#,###") + ")",
                  style=label.style_label_left, color=color.new(color.green, 0), textcolor=color.white, size=labelSize)
        label.new(rightBar, tp2_calc, "🟩 TP2 " + str.tostring(tp2_calc, "#,###.##") + " (+$" + str.tostring((tp2_calc - entry_calc) * 2, "#,###") + ")",
                  style=label.style_label_left, color=color.new(color.lime, 0), textcolor=color.black, size=labelSize)

// =============================================================================
// COMPACT TRADE DASHBOARD (top-left) — only if toggled on
// =============================================================================
// Top-left Trade Plan Dashboard — REMOVED per user request

// =============================================================================
// FILTER STATUS DASHBOARD
// =============================================================================
if barstate.islast and not zenMode and showDashboards
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.gray, 80), border_width=1)
    table.cell(dash, 0, 0, "ORB+FVG", text_color=color.white, bgcolor=color.new(color.blue, 30), text_size=size.small)
    table.cell(dash, 1, 0, "Status", bgcolor=color.new(color.blue, 30), text_color=color.white, text_size=size.small)
    table.cell(dash, 0, 1, "Daily bias", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, biasOK ? "✓" : "✗", text_color=biasOK ? color.lime : color.red, text_size=size.small)
    table.cell(dash, 0, 2, "20-EMA up", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, maOK ? "✓" : "✗", text_color=maOK ? color.lime : color.red, text_size=size.small)
    table.cell(dash, 0, 3, "Trend day", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, trendOK ? "✓" : "✗", text_color=trendOK ? color.lime : color.red, text_size=size.small)
    table.cell(dash, 0, 4, "Loss streak OK", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, lossStreakOK ? "✓" : "✗", text_color=lossStreakOK ? color.lime : color.red, text_size=size.small)
    table.cell(dash, 0, 5, "FVG confluence", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, fvgConfluence ? "✓" : (requireFVGConfluence ? "✗" : "—"), text_color=fvgConfluence ? color.lime : (requireFVGConfluence ? color.red : color.gray), text_size=size.small)
    table.cell(dash, 0, 6, "Volume OK", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, volumeOK ? "✓" : (useVolumeFilter ? "✗" : "—"), text_color=volumeOK ? color.lime : (useVolumeFilter ? color.red : color.gray), text_size=size.small)
    allReady = biasOK and maOK and trendOK and lossStreakOK and limitOK and fvgConfluence and volumeOK
    table.cell(dash, 0, 7, "READY", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 7, allReady ? "🟢" : "🔴", text_color=color.white, text_size=size.small)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(longSignal, title="ORB+FVG LONG", message="ORB+FVG LONG on {{ticker}} {{interval}} at {{close}}")
````
