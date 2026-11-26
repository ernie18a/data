# Edge Confirmation System (ECS) v2.0

- url: https://www.tradingview.com/script/PBV9IFFj-Edge-Confirmation-System-ECS-v2-0/
- type: indicator
- pine_id: PUB;ad7a8536a367476dab02ca5d0e133f38
- version: 1.0

## Description

ECS — Edge Confirmation System v2.0

A multi-layer confluence indicator built for SPX and SPY options traders who scalp and day trade. Instead of relying on a single signal, ECS combines three independent layers — trend direction, momentum, and volume — and only fires a BUY or SELL label when all three agree. No more entering too early or chasing moves.
What's inside:

Trend Ribbon — Three EMAs (8, 21, 50) form a color-coded ribbon. Green means the market is moving up, red means down, grey means choppy. If the ribbon is grey, there is no trade.

Momentum Pulse — A custom normalized oscillator (not RSI, not MACD) that measures price velocity and filters out flat, low-energy moves before they waste your time or money.
Volume Surge Detector — Identifies candles where institutional-level volume is present. Entries are blocked on weak low-volume moves, which is where most retail traders get chopped up.

BUY / SELL Labels — Clean text labels print directly on price only when all three layers confirm. No clutter, no noise.

Live Dashboard — A real-time panel in plain English showing market direction, momentum, volume activity, setup strength (★★★ rated), live signal, and today's bias so you know whether to focus on calls or puts before the open.

5 Built-in Alerts — BUY signal, SELL signal, exit warning, and volume surge, ready to connect to your phone or automation.


This indicator does not repaint. Signals are confirmed on the current bar close. Past performance does not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ============================================================
//  EDGE CONFIRMATION SYSTEM (ECS) v2.0 — Pine Script v6
//  Built for: SPX & SPY Options — Scalping & Day Trading
//  Platform: TradingView (Pine Script v6)
//
//  CHANGES IN v2.0:
//  - Removed X exit marks from chart (clean look)
//  - BUY / SELL shown as clean price labels on chart
//  - Full dashboard redesign: plain English, better colors
// ============================================================

//@version=6
indicator("Edge Confirmation System (ECS) v2.0", shorttitle="ECS v2.0", overlay=true, max_lines_count=10, max_labels_count=500)

// ─────────────────────────────────────────────
// ░░ INPUTS
// ─────────────────────────────────────────────

trendFastLen  = input.int(8,      "Fast EMA Length",          group="⚡ Trend Ribbon")
trendSlowLen  = input.int(21,     "Slow EMA Length",          group="⚡ Trend Ribbon")
trendBaseLen  = input.int(50,     "Base EMA Length",          group="⚡ Trend Ribbon")
showRibbon    = input.bool(true,  "Show Trend Ribbon",        group="⚡ Trend Ribbon")

mpFastLen     = input.int(5,      "Momentum Fast Period",     group="🔥 Momentum Pulse")
mpSlowLen     = input.int(13,     "Momentum Slow Period",     group="🔥 Momentum Pulse")
mpSignalLen   = input.int(3,      "Momentum Smoothing",       group="🔥 Momentum Pulse")
mpOBLevel     = input.float(0.8,  "Overbought Level",         group="🔥 Momentum Pulse", minval=0.1,  maxval=1.5)
mpOSLevel     = input.float(-0.8, "Oversold Level",           group="🔥 Momentum Pulse", minval=-1.5, maxval=-0.1)

volLookback   = input.int(20,     "Volume Average Period",    group="📊 Volume Surge")
volMultiplier = input.float(1.5,  "Surge Threshold (x Avg)", group="📊 Volume Surge", minval=1.0, maxval=4.0)
showVolBars   = input.bool(true,  "Highlight Surge Candles", group="📊 Volume Surge")

showEntries   = input.bool(true,  "Show BUY / SELL Labels",  group="🎯 Signals")
requireVolume = input.bool(true,  "Require Volume Surge",    group="🎯 Signals")
showDash      = input.bool(true,  "Show Dashboard",          group="🎯 Signals")


// ─────────────────────────────────────────────
// ░░ LAYER 1: TREND RIBBON
// ─────────────────────────────────────────────

float emaFast = ta.ema(close, trendFastLen)
float emaSlow = ta.ema(close, trendSlowLen)
float emaBase = ta.ema(close, trendBaseLen)

bool trendBull    = close > emaBase and emaFast > emaSlow
bool trendBear    = close < emaBase and emaFast < emaSlow
bool trendNeutral = not trendBull and not trendBear

color ribbonColor = trendBull ? color.new(#26A69A, 78) : trendBear ? color.new(#EF5350, 78) : color.new(#78909C, 88)

p1 = plot(showRibbon ? emaFast : na, color=color.new(#26A69A, 50), linewidth=1, title="EMA Fast")
p2 = plot(showRibbon ? emaSlow : na, color=color.new(#EF5350, 50), linewidth=1, title="EMA Slow")
plot(showRibbon ? emaBase : na,      color=color.new(#FFB74D, 40), linewidth=2, title="EMA Base (50)")
fill(p1, p2, color=ribbonColor, title="Trend Ribbon")


// ─────────────────────────────────────────────
// ░░ LAYER 2: MOMENTUM PULSE
// ─────────────────────────────────────────────

float emaF     = ta.ema(close, mpFastLen)
float emaS     = ta.ema(close, mpSlowLen)
float mpRaw    = (emaF - emaS) / emaS * 100.0
float mpHigh   = ta.highest(mpRaw, 50)
float mpLow    = ta.lowest(mpRaw,  50)
float mpRange  = mpHigh - mpLow
float mpNorm   = mpRange > 0.0 ? 2.0 * ((mpRaw - mpLow) / mpRange) - 1.0 : 0.0
float mpSignal = ta.ema(mpNorm, mpSignalLen)

bool mpBullish = mpNorm > 0.0 and mpNorm > mpSignal
bool mpBearish = mpNorm < 0.0 and mpNorm < mpSignal
bool mpOB      = mpNorm >= mpOBLevel
bool mpOS      = mpNorm <= mpOSLevel


// ─────────────────────────────────────────────
// ░░ LAYER 3: VOLUME SURGE
// ─────────────────────────────────────────────

float avgVol       = ta.sma(volume, volLookback)
bool  volSurge     = volume >= avgVol * volMultiplier
bool  volBullSurge = volSurge and close > open
bool  volBearSurge = volSurge and close < open

barcolor(showVolBars and volBullSurge ? color.new(#26A69A, 25) :
         showVolBars and volBearSurge ? color.new(#EF5350, 25) : na,
         title="Volume Surge Candle")


// ─────────────────────────────────────────────
// ░░ LAYER 4: ENTRY SIGNALS
// ─────────────────────────────────────────────

int bullScore = (trendBull     ? 1 : 0) + (mpBullish ? 1 : 0) + (volBullSurge ? 1 : 0)
int bearScore = (trendBear     ? 1 : 0) + (mpBearish ? 1 : 0) + (volBearSurge ? 1 : 0)

bool longCondition  = trendBull and mpBullish and not mpOB and (requireVolume ? volBullSurge : true)
bool shortCondition = trendBear and mpBearish and not mpOS and (requireVolume ? volBearSurge : true)

var int lastSignal = 0
bool longEntry  = longCondition  and lastSignal != 1
bool shortEntry = shortCondition and lastSignal != -1

if longEntry
    lastSignal := 1
if shortEntry
    lastSignal := -1

// ── Clean price labels on chart (no arrows, just crisp text boxes) ──
if showEntries and longEntry
    label.new(bar_index, low - (low * 0.0005),
         text      = "▲  BUY",
         style     = label.style_label_up,
         color     = #26A69A,
         textcolor = color.white,
         size      = size.normal)

if showEntries and shortEntry
    label.new(bar_index, high + (high * 0.0005),
         text      = "▼  SELL",
         style     = label.style_label_down,
         color     = #EF5350,
         textcolor = color.white,
         size      = size.normal)


// ─────────────────────────────────────────────
// ░░ LAYER 5: EXIT DETECTION (dashboard only, no chart marks)
// ─────────────────────────────────────────────

bool exitLong  = lastSignal == 1  and (mpBearish or (mpOB and mpNorm < mpSignal))
bool exitShort = lastSignal == -1 and (mpBullish or (mpOS and mpNorm > mpSignal))


// ─────────────────────────────────────────────
// ░░ LAYER 6: DASHBOARD — plain English, clean colors
// ─────────────────────────────────────────────

// ── Trend Direction ──
string trendText = trendBull ? "Going UP  ▲"  : trendBear ? "Going DOWN  ▼" : "No Clear Direction"
color  trendBg   = trendBull ? color.new(#1B5E20, 10) : trendBear ? color.new(#B71C1C, 15) : color.new(#37474F, 20)
color  trendTxt  = trendBull ? #69F0AE : trendBear ? #FF5252 : #90A4AE

// ── Momentum ──
string mpText = mpBullish ? "Gaining Speed  ▲" : mpBearish ? "Losing Speed  ▼" : "Flat / Unclear"
color  mpBg   = mpBullish ? color.new(#1B5E20, 20) : mpBearish ? color.new(#B71C1C, 25) : color.new(#37474F, 20)
color  mpTxt  = mpBullish ? #69F0AE : mpBearish ? #FF5252 : #90A4AE

// ── Volume ──
string volText = volBullSurge ? "Big Buy Volume  🔥" : volBearSurge ? "Big Sell Volume  🔥" : "Normal Volume"
color  volBg   = volBullSurge ? color.new(#1B5E20, 20) : volBearSurge ? color.new(#B71C1C, 25) : color.new(#263238, 20)
color  volTxt  = volBullSurge ? #69F0AE : volBearSurge ? #FF5252 : #90A4AE

// ── Overextended Warning ──
string extText = mpOB ? "⚠  Getting Stretched — Watch Exit" : mpOS ? "⚠  Getting Stretched — Watch Exit" : "✓  No Warning"
color  extBg   = (mpOB or mpOS) ? color.new(#E65100, 15) : color.new(#263238, 20)
color  extTxt  = (mpOB or mpOS) ? #FFAB40 : #69F0AE

// ── Confluence Score ──
int    activeScore = trendBull ? bullScore : bearScore
string scoreText = activeScore == 3 ? "★★★  All 3 Confirmed — Strong Setup" : activeScore == 2 ? "★★☆  2 of 3 — Use Smaller Size" : "★☆☆  Weak — Skip This Trade"
color  scoreBg   = activeScore == 3 ? color.new(#1B5E20, 10) : activeScore == 2 ? color.new(#E65100, 20) : color.new(#37474F, 25)
color  scoreTxt  = activeScore == 3 ? #69F0AE : activeScore == 2 ? #FFAB40 : #90A4AE

// ── Current Signal ──
string sigText = longEntry ? ">>> BUY NOW — Enter Long" : shortEntry ? ">>> SELL NOW — Enter Short" : (exitLong or exitShort) ? "Momentum Fading — Consider Exit" : "Watching... No Signal Yet"
color  sigBg   = longEntry ? color.new(#1B5E20, 5) : shortEntry ? color.new(#B71C1C, 10) : (exitLong or exitShort) ? color.new(#E65100, 15) : color.new(#263238, 15)
color  sigTxt  = longEntry ? #69F0AE : shortEntry ? #FF5252 : (exitLong or exitShort) ? #FFAB40 : #78909C

// ── Today's Bias ──
string biasText = trendBull ? "Focus on CALLS & LONGS today" : trendBear ? "Focus on PUTS & SHORTS today" : "Choppy — Trade Small or Wait"
color  biasBg   = trendBull ? color.new(#1B5E20, 15) : trendBear ? color.new(#B71C1C, 20) : color.new(#37474F, 20)
color  biasTxt  = trendBull ? #69F0AE : trendBear ? #FF5252 : #FFAB40

// ── Draw the Table ──
if showDash and barstate.islast
    var table dash = table.new(position.top_right, 2, 9,
         bgcolor      = color.new(#0D1117, 0),
         border_color = color.new(#30363D, 0),
         border_width = 1,
         frame_color  = color.new(#30363D, 0),
         frame_width  = 2)

    // Header
    table.cell(dash, 0, 0, "⚡ ECS  EDGE SYSTEM",
         text_color  = #E6EDF3,
         bgcolor     = color.new(#161B22, 0),
         text_halign = text.align_center,
         text_size   = size.small)
    table.cell(dash, 1, 0, "v2.0",
         text_color  = #8B949E,
         bgcolor     = color.new(#161B22, 0),
         text_halign = text.align_center,
         text_size   = size.small)

    // Divider label row
    table.cell(dash, 0, 1, "WHAT TO KNOW",
         text_color  = color.new(#8B949E, 0),
         bgcolor     = color.new(#161B22, 0),
         text_size   = size.tiny,
         text_halign = text.align_left)
    table.cell(dash, 1, 1, "STATUS",
         text_color  = color.new(#8B949E, 0),
         bgcolor     = color.new(#161B22, 0),
         text_size   = size.tiny,
         text_halign = text.align_center)

    // Row: Trend
    table.cell(dash, 0, 2, "Market Direction",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 2, trendText,
         text_color  = trendTxt,
         bgcolor     = trendBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Momentum
    table.cell(dash, 0, 3, "Momentum",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 3, mpText,
         text_color  = mpTxt,
         bgcolor     = mpBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Volume
    table.cell(dash, 0, 4, "Volume Activity",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 4, volText,
         text_color  = volTxt,
         bgcolor     = volBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Overextended
    table.cell(dash, 0, 5, "Overextended?",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 5, extText,
         text_color  = extTxt,
         bgcolor     = extBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Confluence Score
    table.cell(dash, 0, 6, "Setup Strength",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 6, scoreText,
         text_color  = scoreTxt,
         bgcolor     = scoreBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Live Signal
    table.cell(dash, 0, 7, "Live Signal",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 7, sigText,
         text_color  = sigTxt,
         bgcolor     = sigBg,
         text_size   = size.small,
         text_halign = text.align_center)

    // Row: Today's Bias
    table.cell(dash, 0, 8, "Today's Bias",
         text_color  = #8B949E,
         bgcolor     = color.new(#0D1117, 0),
         text_size   = size.small,
         text_halign = text.align_left)
    table.cell(dash, 1, 8, biasText,
         text_color  = biasTxt,
         bgcolor     = biasBg,
         text_size   = size.small,
         text_halign = text.align_center)


// ─────────────────────────────────────────────
// ░░ ALERTS
// ─────────────────────────────────────────────

alertcondition(longEntry,  title="ECS — BUY Signal",       message="⚡ ECS BUY on {{ticker}} at {{close}} — All layers confirmed. Look for CALLS.")
alertcondition(shortEntry, title="ECS — SELL Signal",      message="⚡ ECS SELL on {{ticker}} at {{close}} — All layers confirmed. Look for PUTS.")
alertcondition(exitLong,   title="ECS — Consider Exit Long",  message="⚠ ECS: Momentum fading on {{ticker}}. Consider exiting your CALLS.")
alertcondition(exitShort,  title="ECS — Consider Exit Short", message="⚠ ECS: Momentum fading on {{ticker}}. Consider exiting your PUTS.")
alertcondition(volSurge,   title="ECS — Volume Surge",     message="🔥 ECS: Big volume detected on {{ticker}}. Watch for directional move.")
````
