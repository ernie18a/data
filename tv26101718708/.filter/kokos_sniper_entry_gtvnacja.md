# Koko's Sniper Entry 

- url: https://www.tradingview.com/script/GTvNACja-Koko-s-Sniper-Entry/
- type: indicator
- pine_id: PUB;1b010f076f7a458c84e45d5e12778730
- version: 1.0

## Description

This indicator is built around one core idea: wait for everything to align, then strike with precision.

Koko's Sniper Entry combines a dynamic EMA channel with a 4-hour bias filter and 5-minute entry confirmation to identify high-probability trade setups across futures and crypto markets. Designed for YM, MYM, MGC, NQ, SI, and LTCUSD.

How it works:
The EMA channel defines the range. When price breaks out with a strong clearing bar, the system checks three things before firing a signal — the 4-hour candle's wick rejection (which direction is the market actually defending), whether the 5-minute entry candle shows clean intent with no wicks fighting the move, and whether the session timing is right.
Only when all of those align does the indicator mark a signal. That's the sniper shot.
Signal types:

BUY-E / SELL-E — Early signal. Clearing bar confirmed, watching for full entry.
BUY-S / SELL-S — Smart signal. Full confirmation. This is the entry.

Built-in features:

4-hour bias filter using wick rejection analysis
ATR-based stop loss and take profit levels
Session filter for Asia, London, and NY
4-hour trade window — auto-expires after the setup window closes
PickMyTrade webhook alerts for automated execution
On-chart dashboard showing bias, session, signal state, and ATR

The philosophy:
Most traders overtrade. This system is designed to make you wait — and when the moment comes, you already feel it before you see it. The indicator just confirms what you know.
For educational purposes. Not financial advice. Always trade within your prop firm rules and risk parameters.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ds4014

//@version=6


// ─────────────────────────────────────────────────────────────────────────────
indicator(title="Koko Clean Trade v2", overlay=true)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 1 — CHANNEL SETTINGS (unchanged from original)
// ═══════════════════════════════════════════════════════════════════════════
g01 = "Channel Setting"
len  = input.int(20, title="Length", minval=1, group=g01)
src  = input(high, title="Upper Band Source", group=g01)
src2 = input(low,  title="Lower Band Source", group=g01)

upper = ta.ema(src,  len)
lower = ta.ema(src2, len)

u = plot(upper, "Upper", color=#fbbf68, linewidth=2)
l = plot(lower, "Lower", color=#a586ca, linewidth=2)
fill(u, l, upper, lower, color.new(#fbbf68,40), color.new(#a586ca,40), title="Channel Fill", display=display.none)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 2 — 4HR BIAS FILTER (NEW)
// Logic: read how the last closed 4hr candle reacted
//   Bullish bias  = candle rejected the low  (long lower wick > body, or close near high)
//   Bearish bias  = candle rejected the high (long upper wick > body, or close near low)
//   Neutral       = indecision — no trade
// ═══════════════════════════════════════════════════════════════════════════
g07 = "4HR Bias Filter"
use4hrBias     = input.bool(true,  "Enable 4HR Bias Filter", group=g07)
biasStrength   = input.float(0.3,  "Min Wick Rejection Ratio (0.0–1.0)", step=0.05, minval=0.0, maxval=1.0, group=g07,
                             tooltip="How dominant the rejecting wick must be relative to the candle range. 0.3 = wick is at least 30% of total range.")
showBiasLabel  = input.bool(true,  "Show 4HR Bias Label on Chart", group=g07)

// Pull 4hr OHLC — barmerge.lookahead_off so we only see confirmed closed candles
[htfO, htfH, htfL, htfC] = request.security(syminfo.tickerid, "240",
     [open[1], high[1], low[1], close[1]],
     lookahead=barmerge.lookahead_off)

// Candle metrics on the last closed 4hr bar
htfRange      = htfH - htfL
htfBody       = math.abs(htfC - htfO)
htfUpperWick  = htfH - math.max(htfO, htfC)   // wick above body
htfLowerWick  = math.min(htfO, htfC) - htfL   // wick below body

// Rejection logic
// Bullish rejection = lower wick is large (price pushed down, buyers rejected it → long)
// Bearish rejection = upper wick is large (price pushed up, sellers rejected it → short)
bullRejection = htfRange > 0 and (htfLowerWick / htfRange) >= biasStrength
bearRejection = htfRange > 0 and (htfUpperWick / htfRange) >= biasStrength

// Secondary confirmation: close position within the candle
// Bullish = close in upper 50% of range, Bearish = close in lower 50%
closePositionBull = htfC >= (htfL + htfRange * 0.5)
closePositionBear = htfC <= (htfL + htfRange * 0.5)

// Combined bias
htfBullBias = bullRejection and closePositionBull
htfBearBias = bearRejection and closePositionBear
htfNeutral  = not htfBullBias and not htfBearBias

// Bias label top-right
var label biasLbl = na
if showBiasLabel and barstate.islast
    label.delete(biasLbl)
    biasText  = htfBullBias ? "4HR BIAS: LONG ▲" : htfBearBias ? "4HR BIAS: SHORT ▼" : "4HR BIAS: NEUTRAL —"
    biasColor = htfBullBias ? color.new(#1D9E75,0) : htfBearBias ? color.new(#C93A1F,0) : color.new(#888780,0)
    biasLbl  := label.new(bar_index, high * 1.0005, biasText,
                          style=label.style_label_left,
                          color=biasColor,
                          textcolor=color.white,
                          size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 3 — SESSION FILTER (NEW)
// Times in Exchange timezone. Toggle each session on/off.
// ═══════════════════════════════════════════════════════════════════════════
g08 = "Session Filter"
useSessionFilter = input.bool(false, "Enable Session Filter", group=g08,
                              tooltip="When enabled, signals only fire during selected sessions.")
tradeAsia    = input.bool(true,  "Asia Session    (7:00–10:00 PM CT)", group=g08)
tradeLondon  = input.bool(true,  "London Session  (2:00–5:00 AM CT)",  group=g08)
tradeNY      = input.bool(true,  "NY Session      (8:00–11:00 AM CT)", group=g08)

// Convert to exchange time — using CT offsets (CST = UTC-6, CDT = UTC-5)
// TradingView session strings use exchange/broker time, so we use time() in UTC
asiaSession   = time(timeframe.period, "0100-0400:1234567")   // 7pm–10pm CT = 1am–4am UTC
londonSession = time(timeframe.period, "0800-1100:1234567")   // 2am–5am CT  = 8am–11am UTC
nySession     = time(timeframe.period, "1400-1700:1234567")   // 8am–11am CT = 2pm–5pm UTC

inAsia   = not na(asiaSession)
inLondon = not na(londonSession)
inNY     = not na(nySession)

sessionAllowed = not useSessionFilter or
     (tradeAsia   and inAsia)   or
     (tradeLondon and inLondon) or
     (tradeNY     and inNY)

currentSession = inAsia ? "Asia" : inLondon ? "London" : inNY ? "NY" : "Off-Hours"

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 4 — 4HR TRADE WINDOW (NEW)
// Once a signal fires, only allow entries for the next N bars on the 5min chart
// 4 hours on 5min = 48 bars
// ═══════════════════════════════════════════════════════════════════════════
g09 = "Trade Window"
useWindow     = input.bool(true,  "Enable 4HR Trade Window", group=g09)
windowBars    = input.int(48,     "Window Length (bars after signal)", minval=1, group=g09,
                          tooltip="On 5min chart: 48 bars = 4 hours. Adjust if using different timeframe.")

var int windowCountdown = 0
var bool inWindow = false

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 5 — CLEARING BAR (unchanged from original)
// ═══════════════════════════════════════════════════════════════════════════
g06 = "Clearing Bar Setting"
optionMode = input.string("Cross", "Clearing Bar Mode", options=["Cross","Over/Under"], group=g06)

clearCon1 = switch optionMode
    "Cross"      => ta.crossover(close, upper)
    "Over/Under" => close > upper

clearCon2 = switch optionMode
    "Cross"      => ta.crossunder(close, lower)
    "Over/Under" => close < lower

up = clearCon1
dn = clearCon2

ctop = math.max(open, close)
cbot = math.min(open, close)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 6 — CANDLE BODY (unchanged)
// ═══════════════════════════════════════════════════════════════════════════
g03 = "Candle Body Setting"
string i_maType2 = input.string("Body_Only", "Candle Body", options=["Body_Only","Full_Candle"], group=g03)

bool candle_body = switch i_maType2
    "Body_Only"   => ctop <= upper and cbot >= lower
    "Full_Candle" => high <= upper and low  >= lower

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 7 — INTENT (unchanged)
// ═══════════════════════════════════════════════════════════════════════════
g04 = "Intent Setting"
string i_maType = input.string("Bullish_Candle", "Bullish Intent", options=["Bullish_Candle","Close_Above_Previous_High","Close_Above_Previous_Midline"], group=g04)

bool bullish_intent = switch i_maType
    "Close_Above_Previous_High"    => close > high[1]
    "Close_Above_Previous_Midline" => close > hl2[1]
    "Bullish_Candle"               => close > open

string i_maType3 = input.string("Bearish_Candle", "Bearish Intent", options=["Bearish_Candle","Close_Below_Previous_Low","Close_Below_Previous_Midline"], group=g04)

bool bearish_intent = switch i_maType3
    "Close_Below_Previous_Low"     => close < low[1]
    "Close_Below_Previous_Midline" => close < hl2[1]
    "Bearish_Candle"               => close < open

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 8 — ATR FILTER (unchanged)
// ═══════════════════════════════════════════════════════════════════════════
g02 = "ATR Filter"
length    = input.int(14, "Length", minval=1, group=g02)
smoothing = input.string("RMA", "Smoothing", options=["RMA","SMA","EMA","WMA"], group=g02)

ma_function(source, length) =>
    switch smoothing
        "RMA" => ta.rma(source, length)
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        =>       ta.wma(source, length)

multi  = input.float(1.0, "Option A Multiplier", step=0.1, group=g02)
multi2 = input.float(0.8, "Option B Multiplier", step=0.1, group=g02)
tr     = ta.tr(true)
atr    = ma_function(tr, length) * multi
atr2   = ma_function(tr, length) * multi2

plot(atr,  "ATR",  color=color.new(#B71C1C,0), display=display.data_window, editable=false)
plot(atr2, "ATR2", color=color.new(#B71C1C,0), display=display.data_window, editable=false)

string i_maType8 = input.string("Clearing Bar Strength", "ATR Filter Type",
     options=["Clearing Bar Strength","Avoid Dead/Choppy Channels"], group=g02)

bool atrFilter = switch i_maType8
    "Clearing Bar Strength"      => tr >= atr
    "Avoid Dead/Choppy Channels" => (upper - lower) >= atr2

useAtr1 = input(true, "Enable Bull ATR filter", group=g02)
useAtr2 = input(true, "Enable Bear ATR filter", group=g02)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 9 — OPTIONAL SAFETY (unchanged)
// ═══════════════════════════════════════════════════════════════════════════
g05 = "Optional Safety"
os = input(false, "Enable Optional Safety", group=g05)

// ═══════════════════════════════════════════════════════════════════════════
// GROUP 10 — PICKMYTRADE / TELEGRAM ALERT SETTINGS (NEW)
// ═══════════════════════════════════════════════════════════════════════════
g10 = "Alert Settings (PickMyTrade + Telegram)"
accountId1   = input.string("ACCOUNT_1", "Account ID 1 (PickMyTrade)", group=g10,
                             tooltip="Your PickMyTrade account ID. Found in your PickMyTrade dashboard.")
accountId2   = input.string("",          "Account ID 2 (leave blank if not using)", group=g10)
accountId3   = input.string("",          "Account ID 3 (leave blank if not using)", group=g10)
contractQty  = input.int(1,              "Contracts per signal", minval=1, group=g10)
useSmartOnly = input.bool(false,         "Only alert on Smart signals (not Early)", group=g10,
                           tooltip="When on: only Buy Smart / Sell Smart trigger PickMyTrade. Early signals still show on chart.")
slMulti      = input.float(1.5,          "Stop Loss ATR multiplier", step=0.1, group=g10)
tpMulti      = input.float(2.5,          "Take Profit ATR multiplier", step=0.1, group=g10)

// ═══════════════════════════════════════════════════════════════════════════
// MAIN SIGNAL CALCULATION
// ═══════════════════════════════════════════════════════════════════════════
var pos = 0

// Bias gate — only allow signals aligned with 4hr bias
biasGateLong  = not use4hrBias or htfBullBias
biasGateShort = not use4hrBias or htfBearBias

if up and (useAtr1 ? atrFilter : true) and biasGateLong and sessionAllowed
    pos := 1
if dn and (useAtr2 ? atrFilter : true) and biasGateShort and sessionAllowed
    pos := -1

ebuy  = pos == 1  and pos[1] != 1
esell = pos == -1 and pos[1] != -1

// Optional safety
if os
    if pos == 1  and low  < lower
        pos := 0
    if pos == -1 and high > upper
        pos := 0

ff  = pos == 1  and candle_body and bullish_intent
ff2 = pos == -1 and candle_body and bearish_intent

// One entry per clearing bar
cr = input(true, "One Entry Per Clearing Bar", group=g06)
if cr
    if ff
        pos := 0
    if ff2
        pos := 0

// Trade window management
if ebuy or esell
    windowCountdown := windowBars
    inWindow        := true

if useWindow and windowCountdown > 0
    windowCountdown -= 1
    if windowCountdown == 0
        inWindow := false
        pos      := 0

// ═══════════════════════════════════════════════════════════════════════════
// VISUAL SIGNALS (unchanged from original + window indicator)
// ═══════════════════════════════════════════════════════════════════════════
showB1 = input.bool(true, "Show Early Buy")
showS1 = input.bool(true, "Show Early Sell")
showB2 = input.bool(true, "Show Smart Buy")
showS2 = input.bool(true, "Show Smart Sell")

flip_Alert = input(false, "Flip Alerts")

bullClear = flip_Alert == false ? pos == 1  and pos[1] != 1  : pos == -1 and pos[1] != -1
bearClear = flip_Alert == false ? pos == -1 and pos[1] != -1 : pos == 1  and pos[1] != 1
longSig   = flip_Alert == false ? ff  : ff2
shortSig  = flip_Alert == false ? ff2 : ff

dis = ta.atr(14)
ad1 = input(0.2, "Early Vertical", inline="t1")
tc1 = input.color(color.white, "", inline="t1")
ad2 = input(1.0, "Smart Vertical", inline="t2")
tc2 = input.color(color.white, "", inline="t2")

b2 = low  - dis * ad2
s2 = high + dis * ad2
b1 = low  - dis * ad1
s1 = high + dis * ad1

plotshape(ebuy  ? b1 : na, "Buy Early",  shape.labelup,   location.absolute, color.new(color.teal,40),   0, "BUY-E",  tc1, size=size.tiny, display=showB1 ? display.all : display.none)
plotshape(esell ? s1 : na, "Sell Early", shape.labeldown, location.absolute, color.new(color.maroon,40), 0, "SELL-E", tc1, size=size.tiny, display=showS1 ? display.all : display.none)
plotshape(ff    ? b2 : na, "Buy Smart",  shape.labelup,   location.absolute, color.green,                0, "BUY-S",  tc2, size=size.tiny, display=showB2 ? display.all : display.none)
plotshape(ff2   ? s2 : na, "Sell Smart", shape.labeldown, location.absolute, color.red,                  0, "SELL-S", tc2, size=size.tiny, display=showS2 ? display.all : display.none)

// Trade window background shading
windowColor = inWindow ? color.new(color.yellow, 92) : na
bgcolor(useWindow ? windowColor : na, title="Trade Window")

// ═══════════════════════════════════════════════════════════════════════════
// ON-CHART DASHBOARD TABLE (NEW)
// ═══════════════════════════════════════════════════════════════════════════
g11 = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=g11)
dashPos  = input.string("Top Right", "Position", options=["Top Right","Bottom Right","Top Left","Bottom Left"], group=g11)

tablePos = switch dashPos
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    =>               position.bottom_left

var table dash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(tablePos, 2, 7,
                          bgcolor=color.new(#0F0D0A, 15),
                          border_color=color.new(color.white, 70),
                          border_width=1,
                          frame_color=color.new(color.white, 50),
                          frame_width=1)

    // Header
    table.cell(dash, 0, 0, "KOKO CLEAN TRADE v2", text_color=color.new(#C8922A,0), text_size=size.small, bgcolor=color.new(#1A1714,0), text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    // 4hr bias row
    biasText  = htfBullBias ? "LONG ▲" : htfBearBias ? "SHORT ▼" : "NEUTRAL"
    biasCol   = htfBullBias ? color.new(#1D9E75,0) : htfBearBias ? color.new(#C93A1F,0) : color.new(#888780,0)
    table.cell(dash, 0, 1, "4HR Bias", text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 1, biasText,   text_color=biasCol, text_size=size.tiny)

    // Session row
    sessCol = sessionAllowed ? color.new(#1D9E75,0) : color.new(#888780,0)
    table.cell(dash, 0, 2, "Session",     text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 2, currentSession, text_color=sessCol, text_size=size.tiny)

    // Signal state
    sigText = pos == 1 ? "LONG ACTIVE" : pos == -1 ? "SHORT ACTIVE" : "WAITING"
    sigCol  = pos == 1 ? color.new(#1D9E75,0) : pos == -1 ? color.new(#C93A1F,0) : color.new(#888780,0)
    table.cell(dash, 0, 3, "Signal",  text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 3, sigText,   text_color=sigCol, text_size=size.tiny)

    // Window countdown
    winText = useWindow ? (inWindow ? str.tostring(windowCountdown) + " bars left" : "CLOSED") : "OFF"
    winCol  = inWindow ? color.new(#C8922A,0) : color.new(#888780,0)
    table.cell(dash, 0, 4, "Window",  text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 4, winText,   text_color=winCol, text_size=size.tiny)

    // ATR value
    table.cell(dash, 0, 5, "ATR(14)", text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(math.round(dis, 2)), text_color=color.new(color.white,20), text_size=size.tiny)

    // Instrument
    table.cell(dash, 0, 6, "Symbol", text_color=color.new(color.white,30), text_size=size.tiny)
    table.cell(dash, 1, 6, syminfo.ticker, text_color=color.new(color.white,20), text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// ALERT PAYLOADS
// ─────────────────────────────────────────────────────────────────────────
// Pine Script v6 rule:
//   alertcondition() → const string only (static names, no variables)
//   alert()          → series string OK  (dynamic JSON + Telegram messages)
//
// HOW TO USE:
//   1. In TradingView, create an alert on this indicator
//   2. Set condition to one of the alertcondition names below (e.g. "Buy Smart")
//   3. In the Message field, type: {{strategy.order.comment}}
//      — TradingView will substitute the live alert() message automatically
//   4. Paste your PickMyTrade webhook URL in the Webhook field
// ═══════════════════════════════════════════════════════════════════════════

// SL / TP levels based on ATR
slLevel_long  = close - dis * slMulti
tpLevel_long  = close + dis * tpMulti
slLevel_short = close + dis * slMulti
tpLevel_short = close - dis * tpMulti

// Build account list string for PickMyTrade multi-account JSON
acct2str = accountId2 != "" ? ',"' + accountId2 + '"' : ""
acct3str = accountId3 != "" ? ',"' + accountId3 + '"' : ""
acctList = '["' + accountId1 + '"' + acct2str + acct3str + ']'

// ─────────────────────────────────────────────────────────────────────────
// alertcondition — STATIC names only (required by Pine Script)
// These are the trigger conditions. TradingView shows these in the
// "Condition" dropdown when you create an alert.
// ─────────────────────────────────────────────────────────────────────────
alertcondition(bullClear, "Buy Early",  "Buy Early Signal")
alertcondition(bearClear, "Sell Early", "Sell Early Signal")
alertcondition(longSig,   "Buy Smart",  "Buy Smart Signal")
alertcondition(shortSig,  "Sell Smart", "Sell Smart Signal")

// ─────────────────────────────────────────────────────────────────────────
// alert() — DYNAMIC messages (series string — runs at bar close)
// These fire automatically when the condition is true.
// Each sends BOTH the PickMyTrade JSON and the Telegram message
// so one webhook handles both destinations.
// ─────────────────────────────────────────────────────────────────────────

// Early Buy — fires PickMyTrade + Telegram notification
if bullClear and not useSmartOnly
    pmtMsg = '{"accounts":' + acctList +
             ',"ticker":"' + syminfo.ticker +
             '","action":"buy","qty":' + str.tostring(contractQty) +
             ',"type":"market","comment":"BUY-E ' + currentSession + '"}'
    tgMsg  = "EARLY BUY - " + syminfo.ticker +
             "\nSession: " + currentSession +
             "\n4HR Bias: BULLISH" +
             "\nATR: " + str.tostring(math.round(dis, 2)) +
             "\nWaiting for Smart confirmation..."
    alert(pmtMsg + "||TG||" + tgMsg, alert.freq_once_per_bar_close)

// Early Sell
if bearClear and not useSmartOnly
    pmtMsg = '{"accounts":' + acctList +
             ',"ticker":"' + syminfo.ticker +
             '","action":"sell","qty":' + str.tostring(contractQty) +
             ',"type":"market","comment":"SELL-E ' + currentSession + '"}'
    tgMsg  = "EARLY SELL - " + syminfo.ticker +
             "\nSession: " + currentSession +
             "\n4HR Bias: BEARISH" +
             "\nATR: " + str.tostring(math.round(dis, 2)) +
             "\nWaiting for Smart confirmation..."
    alert(pmtMsg + "||TG||" + tgMsg, alert.freq_once_per_bar_close)

// Smart Buy — full PickMyTrade JSON with SL/TP + Telegram YES/NO prompt
if longSig
    pmtMsg = '{"accounts":' + acctList +
             ',"ticker":"' + syminfo.ticker +
             '","action":"buy","qty":' + str.tostring(contractQty) +
             ',"sl":' + str.tostring(math.round(slLevel_long, 2)) +
             ',"tp":' + str.tostring(math.round(tpLevel_long, 2)) +
             ',"type":"market","comment":"BUY-S ' + currentSession + '"}'
    tgMsg  = "SMART BUY - " + syminfo.ticker +
             "\nSession: " + currentSession +
             "\n4HR Bias: BULLISH (wick rejection)" +
             "\nEntry: " + str.tostring(math.round(close, 2)) +
             "\nSL: "    + str.tostring(math.round(slLevel_long, 2)) +
             "\nTP: "    + str.tostring(math.round(tpLevel_long, 2)) +
             "\nWindow: 4hrs" +
             "\n\nTake this trade? Reply YES or NO"
    alert(pmtMsg + "||TG||" + tgMsg, alert.freq_once_per_bar_close)

// Smart Sell — full PickMyTrade JSON with SL/TP + Telegram YES/NO prompt
if shortSig
    pmtMsg = '{"accounts":' + acctList +
             ',"ticker":"' + syminfo.ticker +
             '","action":"sell","qty":' + str.tostring(contractQty) +
             ',"sl":' + str.tostring(math.round(slLevel_short, 2)) +
             ',"tp":' + str.tostring(math.round(tpLevel_short, 2)) +
             ',"type":"market","comment":"SELL-S ' + currentSession + '"}'
    tgMsg  = "SMART SELL - " + syminfo.ticker +
             "\nSession: " + currentSession +
             "\n4HR Bias: BEARISH (wick rejection)" +
             "\nEntry: " + str.tostring(math.round(close, 2)) +
             "\nSL: "    + str.tostring(math.round(slLevel_short, 2)) +
             "\nTP: "    + str.tostring(math.round(tpLevel_short, 2)) +
             "\nWindow: 4hrs" +
             "\n\nTake this trade? Reply YES or NO"
    alert(pmtMsg + "||TG||" + tgMsg, alert.freq_once_per_bar_close)

plot(pos, display=display.data_window, editable=false)
````
