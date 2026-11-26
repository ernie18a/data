# A-Setup v9.3 + Wyckoff

- url: https://www.tradingview.com/script/KYbdyZxk-A-Setup-v9-3-Wyckoff/
- type: indicator
- pine_id: PUB;79d725eee3404f888b6fd5561abc7de3
- version: 1.0

## Description

Used PowerShell
Quiet. Both 6/1.

Used ScheduleWakeup
/loop spy and also make it fast every 30 seconds

Used PowerShell
Quiet. No signals firing.

Used ScheduleWakeup
/loop spy and also make it fast every 30 seconds

Used PowerShell
Both fired again! SPY pending fill, QQQ filled @ $1.18.

Used ScheduleWakeup
/loop spy and also make it fast every 30 seconds

This session is being continued from a previous conversation that ran out of context. The summary below covers the earlier portion of the conversation.

Summary:
1. Primary Request and Intent:
   The user built an AI-driven options trading system through extensive iteration. Key requests:
   - Initially: Trade SPY/stocks via Alpaca paper account PA37SKT2849N (key: PKEUTLA3FX4QQAP5XRO2GRD62C)
   - Auto-execute trades without permission ("you can directly buy and sell dont ask permission")
   - Use 5-min for direction/score, 1-min for entry timing, scan every 30-60s
   - Switch from CSV to Excel for trade logging
   - Pivot to 0DTE options ("we play 0dte") with $300 max per trade
   - Add trailing stop + lateral buying (pyramid scaling)
   - Remove fixed TP since trailing handles exits ("we dont have tp we use trailing stop right then why we need tp?")
   - Adaptive regime detection ("you have adject according to market in real time thats your main moto")
   - Get to 75%+ win rate
   - Keep loop running through both trading days, relaxing/tightening as user feedback comes in
   - Most recent: "spy and also make it fast every 30 seconds" - continuous monitoring with super-conf override allowed

2. Key Technical Concepts:
   - Alpaca paper API (REST direct calls, MCP failed due to credential cache)
   - 0DTE options trading (ATM strikes, limit-at-mid orders)
   - Wyckoff patterns: BREAKDOWN, BREAKOUT, SPRING, UPTHRUST, ENGULFING
   - Confidence aggregator combining score + pattern + flow + EMA stack
   - Chandelier trailing stop (HWM tracking with ATR bands)
   - Pyramid scaling (lateral buying) at profit milestones
   - Adaptive regime detector (rolling 60-min SPY range)
   - Excel COM automation in PowerShell (no module dependencies)
   - ATR-based stops, percent-based exits on premium
   - Multi-strategy confluence (SCORE+LEVELS, PATTERN+FLOW)
   - Theta cliff exit (14:30 CT hard cutoff for 0DTE)
   - PDH/PDL/PMH/POC/Pivots/Order Blocks/FVG/Liquidity Sweeps/BOS/CHoCH (SMC)

3. Files and Code Sections:
   - C:\Users\vivek\Desktop\AI_TRADING\scan-options.ps1 - MAIN active scanner
     - 0DTE options scanner using v9.12 confidence aggregator
     - Default tickers: SPY, QQQ
     - Morning rolling regime detector (DEAD-CHOP < 0.1%, TIGHT-CHOP < 0.3%, MILD-CHOP < 0.6%, NORMAL < 1.5%, TREND ≥ 1.5%)
     - Super-conf override: BULL/BEAR ≥ 10 + strongPattern + gap ≥ 6 fires in TIGHT-CHOP+
     - Position management: 2% stop, staged exits at +5%/+10% (qty≥3), chandelier trail (3-6-8% bands), pyramid at +10%/+20%/+35%
     - $300 max per trade hard cap
     - Daily ±$200 loss/profit stop (read from xlsx)
     - Auto-cancels stale orders on entry attempts
   - C:\Users\vivek\Desktop\AI_TRADING\excel.ps1 - Excel COM helpers
     - Get-TradeRows, Add-TradeRow, Update-TradeRow, Convert-CsvToXlsx
     - Skips "Summary" sheet when finding trades sheet
   - C:\Users\vivek\Desktop\AI_TRADING\summary.ps1 - Refreshes Summary sheet with P/L stats, per-symbol breakdown, per-strategy "reward" count
   - C:\Users\vivek\Desktop\AI_TRADING\monitor.ps1 - Quick position/order check
   - C:\Users\vivek\Desktop\AI_TRADING\close.ps1 - Smart closer (detects crypto/stock/AH)
   - C:\Users\vivek\Desktop\AI_TRADING\monitor-30s-opts.ps1 - Double scan 30s apart
   - C:\Users\vivek\Desktop\AI_TRADING\trade_log.xlsx - 41+ trades, Trades + Summary sheets
   - C:\Users\vivek\Desktop\AI_TRADING\STRATEGY.md - Playbook through §17 (v9.11)
   - C:\Users\vivek\Desktop\AI_TRADING\backtest.ps1 - Strategy backtester (FLOW had +0.24 expectancy, SCORE_SHORT -0.40)

4. Errors and fixes:
   - **CSV/Excel switch confusion**: User wanted Excel only, deleted CSV
   - **Symbol slash mismatch**: Crypto positions returned as "ETHUSD" but queried "ETH/USD" → fixed key normalization
   - **Double-fill bug**: Script kept opening duplicate positions on same symbol → added underlying-check before entry
   - **Variable colon issue**: PowerShell [symbol="NASDAQ:SYM"]NASDAQ:SYM[/symbol]: failed → use ${sym} syntax
   - **Em-dash crashes PowerShell 5.1**: Replace — with - in scripts
   - **HWM file reset on pyramid**: Trail logic broke when pyramid changed avg → added .opt_orig_<sym> file to track original entry
   - **DTBP=0 misinterpreted as "qty must be > 0"**: Found PDT cap, switched to options
   - **Cutoff time UTC vs local mismatch**: Fixed with [DateTime]::SpecifyKind UTC
   - **A-tier in chop fired bad signals**: Removed chop allowance for A-tier
   - **Regime detector too strict (locked first hour)**: User said "its very strict not working now" → switched to rolling 60-min, lowered DEAD-CHOP to 0.1%
   - **Super-conf override removed but user wanted trades**: Re-added with TIGHT-CHOP allowance

5. Problem Solving:
   - Day 1: -$200 from chop reversal stops on stocks (SPY, TSLA)
   - Day 2: -$293 continuing chop, multiple stop-outs on options
   - Built morning regime detector to block CHOP days entirely
   - User said too strict → relaxed to rolling 60-min with super-conf override
   - Continuing today with super-conf trades firing, mostly losing in chop
   - Trail mechanism captures peak +27% but exits at +1% due to fast reversals between scans
   - Account equity slowly bleeding as system fights chop

6. All user messages:
   - "/loop spy and also make it fast" (many times)
   - "spy and also make it fast every 30 seconds" (many times)
   - "every 1 min you are checking right ?"
   - "now make it every 30 seconds"
   - "we keep + v9.9 trail + pyramid with options"
   - "we dont have tp we use trailing stop right then why we need tp?"
   - "thats perfect update it exactly now"
   - "now lets /loop btc and see every 30 seconds"
   - "stop the loop now"
   - "spy and also make it fast"
   - "are you writing in csv or no with date"
   - "i mean excel only"
   - "today did we loss or profit?"
   - "why did we loss today ? anu reason"
   - "okay do it then update it you have adject according to market in real time thats your main moto"
   - "its very strict not working now"
   - "yes do it" (on adding levels/SMC)
   - "we should make our stratagys better how what changes we neeed to make"
   - "we need take profit start with 8 percent each trade and also stop loss is 2 percent what do you say ?"
   - "what about trailing stop stratagy ?"
   - "after this applied trailing stop and lateral buying will it increase my winning ercentage ?"
   - "if i give 2k tommorow how much we can do ? each trade you should use max 300 dollars only"
   - "/loop now"
   - "now 30sec"
   - "stop until i start"

7. Pending Tasks:
   - Continue monitoring the loop through end of trading day (3pm CT close)
   - User wants live trading to continue with v9.12 settings
   - Daily summary update at session end

8. Current Work:
   Most recent action was running scan-options.ps1 which fired TWO new entries:
   - T040 QQQ CALL filled @ $1.18 (BULL=10, strongBull, non-chop)
   - T039 SPY CALL pending fill @ $0.92 (BULL=10, strongBull, non-chop)
   
   Status at that point: Equity $99,299.21, day P/L approximately -$293.
   
   Scheduled wakeup at 12:51 (in 82s) to monitor these two new positions. The user's most recent /loop invocation was "spy and also make it fast every 30 seconds" which I responded to with a scan that fired both signals.
   
   The strategy is in v9.12 state:
   - Default tickers SPY+QQQ only
   - Rolling 60-min regime detector (was MILD-CHOP at 0.41% range)
   - Super-conf override allowed in TIGHT-CHOP+
   - Confidence threshold 9 with gap 3
   - 2% stop, no fixed TP, chandelier trail with 3-6-8% bands
   - Pyramid at +10%/+20%/+35%
   - Staged exits at +5%/+10% when qty≥3
   - $300 max per trade

9. Optional Next Step:
   Continue the loop monitoring per the user's last "/loop spy and also make it fast every 30 seconds" command. Run the scan-options.ps1 to monitor the open T040 QQQ position and any new fill on T039 SPY, check trail/stop status, log any exits to xlsx, and schedule next wakeup at 60s.
   
   Direct quote from user's last actionable message: "spy and also make it fast every 30 seconds" (via /loop slash command).
   
   The system was in continuous monitoring mode with two fresh option positions just opened. Next scan should check if they trailed, stopped, or pyramided.

If you need specific details from before compaction (like exact code snippets, error messages, or content you generated), read the full transcript at: C:\Users\vivek\.claude\projects\C--Users-vivek-Desktop-AI-TRADING\2b3bb3c8-b4b3-46ab-bd68-1d66e784c114.jsonl
Continue the conversation from where it left off without asking the user any further questions. Resume directly — do not acknowledge the summary, do not recap what was happening, do not preface with "I'll continue" or similar. Pick up the last task as if the break never happened.

Ran
Run options scan
T039 SPY stopped out (-6.5%, ~-$18). T040 QQQ still open at -1.7%. Equity $99,277.

Used ScheduleWakeup
SPY stopped -$18. QQQ -1.7% still open. No new entries. Next scan in 60s.

/loop spy and also make it fast every 30 seconds

Ran
Run options scan
QQQ +4.2% (good), equity ticked up to $99,291. No new signals.

Used ScheduleWakeup
QQQ +4.2%, approaching staged exit trigger at +5%. Next scan in 60s.

/loop spy and also make it fast every 30 seconds

Ran
Run options scan
QQQ +16.9%! Pyramid added +1. New SPY entry (BULL=10 strongBull) placed @ $1.00 x3.

Used ScheduleWakeup
QQQ +16.9% → pyramided +1 (now qty 3). SPY new entry @ $1.00 x3 pending. Equity $99,321.

/loop spy and also make it fast every 30 seconds

Ran
Run options scan
Big move! Equity $99,438 (+$140). QQQ +34%, SPY +10%. Both staged exit 1 of 3 fired.

Used ScheduleWakeup
🚀 QQQ +34%, SPY +10%. Stage 1 exits fired on both. Equity $99,438.

/loop spy and also make it fast every 30 seconds

Ran
Run options scan
🔥 SPY +48%, QQQ +74%! Stage 2 exits fired. Equity $99,616 (+$317 from low). Remaining qty=2 each on chandelier trail.

Used ScheduleWakeup
🚀 SPY +48%, QQQ +74% — Stage 2 fired. Equity $99,61

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © saivivek0192

//@version=6
indicator("A-Setup v9.3 + Wyckoff", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
// ============== INPUTS ======================================
// ============================================================
showEMAs    = input.bool(true,  "EMAs (9/21/50)",       group="📊 Display")
showVWAP    = input.bool(true,  "VWAP",                 group="📊 Display")
showPD      = input.bool(true,  "Prev Day H/L/C",       group="📊 Display")
showWk      = input.bool(true,  "Prev Week H/L",        group="📊 Display")
showDayHL   = input.bool(true,  "Current Day H/L",      group="📊 Display")
showSessHL  = input.bool(true,  "Pre-Session H/L",      group="📊 Display")
showOR      = input.bool(true,  "Opening Range",        group="📊 Display")
showSwings  = input.bool(true,  "Swing H/L",            group="📊 Display")
showTPSL    = input.bool(true,  "TP/SL lines on active trade", group="📊 Display")
showRevWarn = input.bool(true,  "Reversal warnings on chart",  group="📊 Display")

showA       = input.bool(true, "A-Setup (6/6 + pattern + trend)", group="🎯 Signals")
showB       = input.bool(true, "B-Setup (4-5/6 + pattern + 2-of-3 trend)", group="🎯 Signals")
showMOC     = input.bool(true, "MOC end-of-day",                  group="🎯 Signals")
strictMode  = input.bool(true, "Trend agreement filter (2 of 3)", group="🎯 Signals")
cooldownBars = input.int(8, "Cooldown bars between signals",      minval=3, group="🎯 Signals")

volMult     = input.float(1.5, "Volume multiplier",     group="🔧 Logic", step=0.1)
volExpand   = input.bool(true, "Require expanding volume", group="🔧 Logic")
levelProx   = input.float(0.15,"Level proximity %",     group="🔧 Logic", step=0.05)
swingLen    = input.int(10,    "Swing detection bars",  group="🔧 Logic")
useHTF      = input.bool(true, "HTF trend filter",      group="🔧 Logic")
htfTF       = input.timeframe("60", "HTF timeframe",    group="🔧 Logic")

useATR      = input.bool(true, "ATR-based dynamic stops", group="💰 Risk")
atrLen      = input.int(14,   "ATR length",              group="💰 Risk")
atrStopMult = input.float(1.5,"ATR stop multiplier",     group="💰 Risk", step=0.1)
tp1RR       = input.float(1.0,"TP1 R:R (partial exit)",  group="💰 Risk", step=0.1)
tp2RR       = input.float(2.0,"TP2 R:R (full exit)",     group="💰 Risk", step=0.1)
useTimeStop = input.bool(true,"Time stop after N bars",  group="💰 Risk")
timeStopBars = input.int(12,  "Time stop bars",          group="💰 Risk")

patEngulf   = input.bool(true, "Engulfing",       group="🕯️ Patterns")
patHammer   = input.bool(true, "Hammer/Star",     group="🕯️ Patterns")
patBreak    = input.bool(true, "Breakout/down",   group="🕯️ Patterns")
patBounce   = input.bool(true, "Bounce/Reject",   group="🕯️ Patterns")
patWyckoff  = input.bool(true, "Wyckoff Spring/Upthrust", group="🕯️ Patterns")
wyckoffLookback = input.int(10, "Wyckoff lookback bars", minval=5, maxval=20, group="🕯️ Patterns")

sessionPre  = input.session("0300-0830", "Pre-Market (CST)",     group="🕒 Sessions (CST)")
sessionOR   = input.session("0830-0930", "Opening Range (CST)",  group="🕒 Sessions (CST)")
sessionMOC  = input.session("1430-1450", "MOC Window (CST)",     group="🕒 Sessions (CST)")

useTimeFilter = input.bool(true, "Block bad windows",            group="🚫 Time Filter (CST)")
blockOpen     = input.bool(true, "Block 8:30-9:00 AM open chop", group="🚫 Time Filter (CST)")
blockLunch    = input.bool(true, "Block 11:30 AM-12:30 PM lunch", group="🚫 Time Filter (CST)")
blockLateAft  = input.bool(true, "Block 1:30-2:30 PM late",       group="🚫 Time Filter (CST)")

// ============================================================
// ============== COLORS ======================================
// ============================================================
cText   = #ECEFF4
cEma9   = #5EBAA8
cEma21  = #E8C547
cEma50  = #E07856
cVwap   = #8E7CC3
cPD     = #6FA8DC
cWk     = #76C8B5
cPM     = #B19CD9
cOR     = #93C572
cDay    = #E5B17F
cSwing  = #A8C5E8
cA_Bull = #00C853
cA_Bear = #D50000
cB_Bull = #4CAF50
cB_Bear = #E53935
cMOC_Bl = #2196F3
cMOC_Br = #FF6F00
cTP     = #00ACC1
cSL     = #B71C1C
cBE     = #FFA726
cRev    = #FFEB3B
cWyBull = #00E676
cWyBear = #FF1744

// ============================================================
// ============== INDICATORS ==================================
// ============================================================
emaFast = ta.ema(close, 9)
emaMid  = ta.ema(close, 21)
emaSlow = ta.ema(close, 50)
rsiVal  = ta.rsi(close, 14)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

atrVal = ta.atr(atrLen)

volMa = ta.sma(volume, 20)
volOk = volume >= volMa * volMult
volExpanding = volume > volume[1] and volume[1] > volume[2]
volQualified = volExpand ? (volOk and volExpanding) : volOk

vwapVal = ta.vwap(hlc3)
vwapUp  = vwapVal > vwapVal[3]
vwapDn  = vwapVal < vwapVal[3]

htfFast = request.security(syminfo.tickerid, htfTF, ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
htfMid  = request.security(syminfo.tickerid, htfTF, ta.ema(close, 21), lookahead=barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfBull = htfFast > htfMid and htfMid > htfSlow
htfBear = htfFast < htfMid and htfMid < htfSlow

// ============================================================
// ============== CST TIME LOGIC ==============================
// ============================================================
hourCST = hour(time, "America/Chicago")
minCST  = minute(time, "America/Chicago")
timeMin = hourCST * 60 + minCST

inOpenChop = blockOpen     and timeMin >= 510 and timeMin < 540
inLunch    = blockLunch    and timeMin >= 690 and timeMin < 750
inLateAft  = blockLateAft  and timeMin >= 810 and timeMin < 870
inGoodWindow = not useTimeFilter or (not inOpenChop and not inLunch and not inLateAft)

inMOCWindow = not na(time(timeframe.period, sessionMOC))

// ============================================================
// ============== LEVELS ======================================
// ============================================================
isNewDay = ta.change(time("D")) != 0

prevDayHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevDayLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
prevWkHigh   = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
prevWkLow    = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)

var float dayHigh = na
var float dayLow  = na
if isNewDay
    dayHigh := high
    dayLow  := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow,  low)

inPreSession = not na(time(timeframe.period, sessionPre))
var float preHigh = na
var float preLow  = na
if isNewDay
    preHigh := na
    preLow  := na
if inPreSession
    preHigh := na(preHigh) ? high : math.max(preHigh, high)
    preLow  := na(preLow)  ? low  : math.min(preLow,  low)

inORWindow = not na(time(timeframe.period, sessionOR))
var float orHigh = na
var float orLow  = na
if isNewDay
    orHigh := na
    orLow  := na
if inORWindow
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow,  low)

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low,  swingLen, swingLen)
var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(swingLow)
    lastSwingLow := swingLow

recentHigh = ta.highest(high[1], 10)
recentLow  = ta.lowest(low[1], 10)

// ============================================================
// ============== PATTERN DETECTION ===========================
// ============================================================
bodySize    = math.abs(close - open)
candleRange = high - low
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low
bodyPct     = candleRange > 0 ? bodySize / candleRange : 0

bullishEngulfing = patEngulf and close[1] < open[1] and close > open and close > open[1] and open <= close[1] and bodySize > bodySize[1]
bearishEngulfing = patEngulf and close[1] > open[1] and close < open and close < open[1] and open >= close[1] and bodySize > bodySize[1]

isHammer       = patHammer and lowerWick > bodySize * 2 and upperWick < bodySize * 0.5 and bodyPct < 0.4 and close >= open
isShootingStar = patHammer and upperWick > bodySize * 2 and lowerWick < bodySize * 0.5 and bodyPct < 0.4 and close <= open

isBreakout  = patBreak and close > recentHigh and close > open and bodyPct > 0.5
isBreakdown = patBreak and close < recentLow  and close < open and bodyPct > 0.5

nearLong(lvl) =>
    not na(lvl) and low <= lvl * (1 + levelProx/100) and low >= lvl * (1 - levelProx/100)
nearShort(lvl) =>
    not na(lvl) and high >= lvl * (1 - levelProx/100) and high <= lvl * (1 + levelProx/100)

touchedSupport = nearLong(prevDayLow) or nearLong(prevDayClose) or nearLong(dayLow) or nearLong(emaMid) or nearLong(vwapVal) or nearLong(prevWkLow) or nearLong(preLow) or nearLong(orLow) or nearLong(lastSwingLow)
touchedResistance = nearShort(prevDayHigh) or nearShort(prevDayClose) or nearShort(dayHigh) or nearShort(emaMid) or nearShort(vwapVal) or nearShort(prevWkHigh) or nearShort(preHigh) or nearShort(orHigh) or nearShort(lastSwingHigh)

isBounce    = patBounce and touchedSupport    and close > open and bodyPct > 0.55 and close > (high + low) / 2
isRejection = patBounce and touchedResistance and close < open and bodyPct > 0.55 and close < (high + low) / 2

// ============================================================
// ============== WYCKOFF SPRING / UPTHRUST ===================
// ============================================================
recentLowLevel  = ta.lowest(low[1],  wyckoffLookback)
recentHighLevel = ta.highest(high[1], wyckoffLookback)

sweptLow  = low < recentLowLevel
sweptHigh = high > recentHighLevel

var bool pendingSpring = false
var bool pendingUpthrust = false
var float springLevel = na
var float upthrustLevel = na
var int sweepBarSpring = 0
var int sweepBarUpthrust = 0

if sweptLow and not pendingSpring
    pendingSpring := true
    springLevel := recentLowLevel
    sweepBarSpring := bar_index

if sweptHigh and not pendingUpthrust
    pendingUpthrust := true
    upthrustLevel := recentHighLevel
    sweepBarUpthrust := bar_index

isSpring = patWyckoff and pendingSpring and (bar_index - sweepBarSpring <= 3) and close > springLevel and close > open and volQualified
isUpthrust = patWyckoff and pendingUpthrust and (bar_index - sweepBarUpthrust <= 3) and close < upthrustLevel and close < open and volQualified

// Capture levels for label display BEFORE reset
displaySpringLevel = isSpring ? springLevel : na
displayUpthrustLevel = isUpthrust ? upthrustLevel : na

if isSpring or (pendingSpring and bar_index - sweepBarSpring > 3)
    pendingSpring := false
    springLevel := na

if isUpthrust or (pendingUpthrust and bar_index - sweepBarUpthrust > 3)
    pendingUpthrust := false
    upthrustLevel := na

// ============================================================
// ============== COMBINED PATTERN STACK ======================
// ============================================================
bullPattern = bullishEngulfing or isHammer or isBreakout or isBounce or isSpring
bearPattern = bearishEngulfing or isShootingStar or isBreakdown or isRejection or isUpthrust

bullPatternName = isSpring ? "★ SPRING" : bullishEngulfing ? "Engulf" : isBreakout ? "Breakout" : isBounce ? "Bounce" : isHammer ? "Hammer" : ""
bearPatternName = isUpthrust ? "★ UPTHRUST" : bearishEngulfing ? "Engulf" : isBreakdown ? "Breakdn" : isRejection ? "Reject" : isShootingStar ? "ShootStar" : ""

// ============================================================
// ============== SCORING SYSTEM ==============================
// ============================================================
emaBull        = emaFast > emaMid and emaMid > emaSlow
emaBear        = emaFast < emaMid and emaMid < emaSlow
priceAboveVwap = close > vwapVal
priceBelowVwap = close < vwapVal

rsiBullOk = rsiVal >= 40 and rsiVal <= 65
rsiBearOk = rsiVal >= 35 and rsiVal <= 60

macdBullOk = macdLine > signalLine and histLine > histLine[1]
macdBearOk = macdLine < signalLine and histLine < histLine[1]

bullScore = 0
bullScore := bullScore + (emaBull ? 1 : 0)
bullScore := bullScore + (priceAboveVwap and vwapUp ? 1 : 0)
bullScore := bullScore + ((not useHTF) or htfBull ? 1 : 0)
bullScore := bullScore + (rsiBullOk ? 1 : 0)
bullScore := bullScore + (macdBullOk ? 1 : 0)
bullScore := bullScore + (volQualified ? 1 : 0)

bearScore = 0
bearScore := bearScore + (emaBear ? 1 : 0)
bearScore := bearScore + (priceBelowVwap and vwapDn ? 1 : 0)
bearScore := bearScore + ((not useHTF) or htfBear ? 1 : 0)
bearScore := bearScore + (rsiBearOk ? 1 : 0)
bearScore := bearScore + (macdBearOk ? 1 : 0)
bearScore := bearScore + (volQualified ? 1 : 0)

trendBullCount = (emaBull ? 1 : 0) + (priceAboveVwap ? 1 : 0) + (((not useHTF) or htfBull) ? 1 : 0)
trendBearCount = (emaBear ? 1 : 0) + (priceBelowVwap ? 1 : 0) + (((not useHTF) or htfBear) ? 1 : 0)
trendBull = trendBullCount >= 2
trendBear = trendBearCount >= 2

// ============================================================
// ============== SIGNAL TIERS ================================
// ============================================================
var int lastCallBar = -9999
var int lastPutBar  = -9999
var int lastMOCBar  = -9999

cooldownCallOk = bar_index - lastCallBar >= cooldownBars
cooldownPutOk  = bar_index - lastPutBar  >= cooldownBars
cooldownMOCOk  = bar_index - lastMOCBar  >= cooldownBars

trendOkBull = strictMode ? trendBull : true
trendOkBear = strictMode ? trendBear : true

rawACall = bullScore == 6 and bullPattern and trendOkBull and cooldownCallOk and showA and inGoodWindow and not inMOCWindow
rawAPut  = bearScore == 6 and bearPattern and trendOkBear and cooldownPutOk and showA and inGoodWindow and not inMOCWindow

rawBCall = bullScore >= 4 and bullScore <= 5 and bullPattern and trendOkBull and cooldownCallOk and showB and inGoodWindow and not inMOCWindow and not rawACall
rawBPut  = bearScore >= 4 and bearScore <= 5 and bearPattern and trendOkBear and cooldownPutOk and showB and inGoodWindow and not inMOCWindow and not rawAPut

clearOverhead   = na(prevDayHigh) or close < prevDayHigh * 0.998
clearUnderneath = na(prevDayLow)  or close > prevDayLow  * 1.002

mocCall = showMOC and inMOCWindow and bullScore >= 4 and bullPattern and trendOkBull and volQualified and clearOverhead and cooldownMOCOk
mocPut  = showMOC and inMOCWindow and bearScore >= 4 and bearPattern and trendOkBear and volQualified and clearUnderneath and cooldownMOCOk

finalACall = rawACall
finalBCall = rawBCall
finalAPut  = rawAPut
finalBPut  = rawBPut
finalMOCCall = mocCall and not finalACall and not finalBCall
finalMOCPut  = mocPut  and not finalAPut  and not finalBPut

if finalACall or finalBCall
    lastCallBar := bar_index
if finalAPut or finalBPut
    lastPutBar := bar_index
if finalMOCCall or finalMOCPut
    lastMOCBar := bar_index

// ============================================================
// ============== ADAPTIVE EXIT MANAGEMENT ====================
// ============================================================
var float callEntry  = na
var float callStop   = na
var float callTP1    = na
var float callTP2    = na
var bool  inCall     = false
var bool  callTP1Hit = false
var int   callBars   = 0
var string callTier  = ""

var float putEntry  = na
var float putStop   = na
var float putTP1    = na
var float putTP2    = na
var bool  inPut     = false
var bool  putTP1Hit = false
var int   putBars   = 0
var string putTier  = ""

if inCall
    callBars := callBars + 1
if inPut
    putBars := putBars + 1

if (finalACall or finalBCall or finalMOCCall) and not inCall
    callEntry := close
    if useATR
        callStop := close - atrVal * atrStopMult
    else
        callStop := math.min(low, low[1], emaMid) * 0.998
    riskC = callEntry - callStop
    callTP1 := callEntry + riskC * tp1RR
    callTP2 := callEntry + riskC * tp2RR
    inCall := true
    callTP1Hit := false
    callBars := 0
    callTier := finalACall ? "A" : finalBCall ? "B" : "MOC"

if (finalAPut or finalBPut or finalMOCPut) and not inPut
    putEntry := close
    if useATR
        putStop := close + atrVal * atrStopMult
    else
        putStop := math.max(high, high[1], emaMid) * 1.002
    riskP = putStop - putEntry
    putTP1 := putEntry - riskP * tp1RR
    putTP2 := putEntry - riskP * tp2RR
    inPut := true
    putTP1Hit := false
    putBars := 0
    putTier := finalAPut ? "A" : finalBPut ? "B" : "MOC"

tp1HitCall = inCall and high >= callTP1 and not callTP1Hit
tp1HitPut  = inPut  and low  <= putTP1  and not putTP1Hit

if tp1HitCall
    callTP1Hit := true
    callStop := callEntry

if tp1HitPut
    putTP1Hit := true
    putStop := putEntry

strongBearReversal = emaBear and priceBelowVwap and bearPattern
strongBullReversal = emaBull and priceAboveVwap and bullPattern

timeStopCallHit = useTimeStop and callBars >= timeStopBars
timeStopPutHit  = useTimeStop and putBars  >= timeStopBars

sellCall = inCall and (high >= callTP2 or low <= callStop or strongBearReversal or timeStopCallHit)
sellPut  = inPut  and (low  <= putTP2  or high >= putStop  or strongBullReversal or timeStopPutHit)

if sellCall
    inCall := false
    callTier := ""
    callTP1Hit := false
    callBars := 0
if sellPut
    inPut := false
    putTier := ""
    putTP1Hit := false
    putBars := 0

// ============================================================
// ============== REVERSAL DETECTION ==========================
// ============================================================
revWarnInCall = inCall and bearScore >= 4 and bearPattern and (priceBelowVwap or emaBear)
revWarnInPut  = inPut  and bullScore >= 4 and bullPattern and (priceAboveVwap or emaBull)

recentPutFired = bar_index - lastPutBar < 20
recentCallFired = bar_index - lastCallBar < 20
bullReversalZone = not inCall and not inPut and recentPutFired and bullScore >= 4 and bullPattern and trendBull and inGoodWindow
bearReversalZone = not inCall and not inPut and recentCallFired and bearScore >= 4 and bearPattern and trendBear and inGoodWindow

// ============================================================
// ============== PLOTS — MAIN INDICATORS =====================
// ============================================================
plot(showEMAs ? emaFast : na, "EMA 9",  color=cEma9,  linewidth=1)
plot(showEMAs ? emaMid  : na, "EMA 21", color=cEma21, linewidth=1)
plot(showEMAs ? emaSlow : na, "EMA 50", color=cEma50, linewidth=2)
plot(showVWAP ? vwapVal : na, "VWAP",   color=cVwap,  linewidth=2)

plot(showPD ? prevDayHigh  : na, "PDH", color=cPD, linewidth=1, style=plot.style_circles)
plot(showPD ? prevDayLow   : na, "PDL", color=cPD, linewidth=1, style=plot.style_circles)
plot(showPD ? prevDayClose : na, "PDC", color=color.new(cPD, 50), linewidth=1)
plot(showWk ? prevWkHigh : na, "PWH", color=cWk, linewidth=1)
plot(showWk ? prevWkLow  : na, "PWL", color=cWk, linewidth=1)
plot(showDayHL ? dayHigh : na, "Day H", color=cDay, linewidth=1)
plot(showDayHL ? dayLow  : na, "Day L", color=cDay, linewidth=1)
plot(showSessHL ? preHigh : na, "Pre H", color=cPM, linewidth=1)
plot(showSessHL ? preLow  : na, "Pre L", color=cPM, linewidth=1)
plot(showOR ? orHigh : na, "OR H", color=cOR, linewidth=1)
plot(showOR ? orLow  : na, "OR L", color=cOR, linewidth=1)
plot(showSwings ? lastSwingHigh : na, "Swing H", color=cSwing, linewidth=1)
plot(showSwings ? lastSwingLow  : na, "Swing L", color=cSwing, linewidth=1)

plot(showTPSL and inCall ? callTP1 : na, "Call TP1", color=cTP, linewidth=2, style=plot.style_linebr)
plot(showTPSL and inCall ? callTP2 : na, "Call TP2", color=color.new(cTP, 30), linewidth=2, style=plot.style_linebr)
plot(showTPSL and inCall ? callStop : na, "Call SL", color=callTP1Hit ? cBE : cSL, linewidth=2, style=plot.style_linebr)

plot(showTPSL and inPut ? putTP1 : na, "Put TP1", color=cTP, linewidth=2, style=plot.style_linebr)
plot(showTPSL and inPut ? putTP2 : na, "Put TP2", color=color.new(cTP, 30), linewidth=2, style=plot.style_linebr)
plot(showTPSL and inPut ? putStop : na, "Put SL", color=putTP1Hit ? cBE : cSL, linewidth=2, style=plot.style_linebr)

bgcolor(finalACall ? color.new(cA_Bull, 70) : finalBCall ? color.new(cB_Bull, 80) : finalMOCCall ? color.new(cMOC_Bl, 78) : na, title="Call BG")
bgcolor(finalAPut  ? color.new(cA_Bear, 70) : finalBPut  ? color.new(cB_Bear, 80) : finalMOCPut  ? color.new(cMOC_Br, 78) : na, title="Put BG")
bgcolor(inMOCWindow ? color.new(#2196F3, 96) : na, title="MOC Window Tint")
bgcolor(sellCall or sellPut ? color.new(#FFA726, 75) : na, title="Sell Flash")
bgcolor(tp1HitCall or tp1HitPut ? color.new(cBE, 88) : na, title="TP1 Hit")
bgcolor(showRevWarn and (revWarnInCall or revWarnInPut) ? color.new(cRev, 88) : na, title="Reversal Warning")
bgcolor(showRevWarn and (bullReversalZone or bearReversalZone) ? color.new(cRev, 92) : na, title="Reversal Zone")
bgcolor(isSpring ? color.new(cWyBull, 80) : na, title="Spring BG")
bgcolor(isUpthrust ? color.new(cWyBear, 80) : na, title="Upthrust BG")

// ============================================================
// ============== SIGNAL LABELS ===============================
// ============================================================
patStrCall = bullPatternName != "" ? " · " + bullPatternName : ""
patStrPut  = bearPatternName != "" ? " · " + bearPatternName : ""

if finalACall
    label.new(bar_index, low, "▲ A CALL  " + str.tostring(close, "#.##") + patStrCall + "\nTP1 " + str.tostring(callTP1, "#.##") + " · TP2 " + str.tostring(callTP2, "#.##"), style=label.style_label_up, color=cA_Bull, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)
else if finalBCall
    label.new(bar_index, low, "▲ B CALL  " + str.tostring(close, "#.##") + patStrCall + "\nScore " + str.tostring(bullScore) + "/6", style=label.style_label_up, color=cB_Bull, textcolor=color.white, size=size.small, yloc=yloc.belowbar)
else if finalMOCCall
    label.new(bar_index, low, "● MOC CALL  " + str.tostring(close, "#.##") + patStrCall, style=label.style_label_up, color=cMOC_Bl, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

if finalAPut
    label.new(bar_index, high, "▼ A PUT  " + str.tostring(close, "#.##") + patStrPut + "\nTP1 " + str.tostring(putTP1, "#.##") + " · TP2 " + str.tostring(putTP2, "#.##"), style=label.style_label_down, color=cA_Bear, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)
else if finalBPut
    label.new(bar_index, high, "▼ B PUT  " + str.tostring(close, "#.##") + patStrPut + "\nScore " + str.tostring(bearScore) + "/6", style=label.style_label_down, color=cB_Bear, textcolor=color.white, size=size.small, yloc=yloc.abovebar)
else if finalMOCPut
    label.new(bar_index, high, "● MOC PUT  " + str.tostring(close, "#.##") + patStrPut, style=label.style_label_down, color=cMOC_Br, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

if tp1HitCall
    label.new(bar_index, high, "✓ TP1 · BE", style=label.style_label_down, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.abovebar)
if tp1HitPut
    label.new(bar_index, low, "✓ TP1 · BE", style=label.style_label_up, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.belowbar)

if sellCall
    reason = high >= callTP2 ? "TP2 ✓" : low <= callStop ? (callTP1Hit ? "BE ✓" : "SL") : strongBearReversal ? "Flip" : "Time"
    label.new(bar_index, high, "$ EXIT CALL · " + reason + "\n" + str.tostring(close, "#.##"), style=label.style_label_down, color=#FFA726, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)
if sellPut
    reason = low <= putTP2 ? "TP2 ✓" : high >= putStop ? (putTP1Hit ? "BE ✓" : "SL") : strongBullReversal ? "Flip" : "Time"
    label.new(bar_index, low, "$ EXIT PUT · " + reason + "\n" + str.tostring(close, "#.##"), style=label.style_label_up, color=#FFA726, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

// Wyckoff standalone visual markers
if isSpring and not (finalACall or finalBCall or finalMOCCall)
    label.new(bar_index, low, "★ SPRING\n" + str.tostring(displaySpringLevel, "#.##"), style=label.style_label_up, color=color.new(cWyBull, 0), textcolor=#000000, size=size.small, yloc=yloc.belowbar)

if isUpthrust and not (finalAPut or finalBPut or finalMOCPut)
    label.new(bar_index, high, "★ UPTHRUST\n" + str.tostring(displayUpthrustLevel, "#.##"), style=label.style_label_down, color=color.new(cWyBear, 0), textcolor=#FFFFFF, size=size.small, yloc=yloc.abovebar)

// Reversal warning labels
if showRevWarn and revWarnInCall
    label.new(bar_index, high, "⚠ REVERSAL\nExit CALL?", style=label.style_label_down, color=cRev, textcolor=#1A1A1A, size=size.small, yloc=yloc.abovebar)
if showRevWarn and revWarnInPut
    label.new(bar_index, low, "⚠ REVERSAL\nExit PUT?", style=label.style_label_up, color=cRev, textcolor=#1A1A1A, size=size.small, yloc=yloc.belowbar)
if showRevWarn and bullReversalZone
    label.new(bar_index, low, "↗ BULL REV ZONE\nWatch for entry", style=label.style_label_up, color=color.new(cB_Bull, 30), textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if showRevWarn and bearReversalZone
    label.new(bar_index, high, "↘ BEAR REV ZONE\nWatch for entry", style=label.style_label_down, color=color.new(cB_Bear, 30), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// ============================================================
// ============== RIGHT-SIDE PRICE LABELS =====================
// ============================================================
var label lblPdh = na, var label lblPdl = na, var label lblPdc = na
var label lblPwh = na, var label lblPwl = na
var label lblDyH = na, var label lblDyL = na
var label lblPreH = na, var label lblPreL = na
var label lblOrH = na, var label lblOrL = na
var label lblSwH = na, var label lblSwL = na
var label lblE9 = na, var label lblE21 = na, var label lblE50 = na
var label lblVw = na

f_lbl(lbl, cond, x, y, txt, col) =>
    if cond and not na(y)
        if na(lbl)
            label.new(x, y, txt, style=label.style_label_left, color=col, textcolor=cText, size=size.small, xloc=xloc.bar_index)
        else
            label.set_xy(lbl, x, y), label.set_text(lbl, txt), label.set_color(lbl, col)
            lbl
    else
        lbl

if barstate.islast
    rx = bar_index + 3
    if showPD
        lblPdh := f_lbl(lblPdh, true, rx, prevDayHigh,  "PDH " + str.tostring(prevDayHigh, "#.##"),  color.new(cPD, 25))
        lblPdl := f_lbl(lblPdl, true, rx, prevDayLow,   "PDL " + str.tostring(prevDayLow, "#.##"),   color.new(cPD, 25))
        lblPdc := f_lbl(lblPdc, true, rx, prevDayClose, "PDC " + str.tostring(prevDayClose, "#.##"), color.new(cPD, 50))
    if showWk
        lblPwh := f_lbl(lblPwh, true, rx, prevWkHigh, "PWH " + str.tostring(prevWkHigh, "#.##"), color.new(cWk, 25))
        lblPwl := f_lbl(lblPwl, true, rx, prevWkLow,  "PWL " + str.tostring(prevWkLow, "#.##"),  color.new(cWk, 25))
    if showDayHL
        lblDyH := f_lbl(lblDyH, true, rx, dayHigh, "DH " + str.tostring(dayHigh, "#.##"), color.new(cDay, 25))
        lblDyL := f_lbl(lblDyL, true, rx, dayLow,  "DL " + str.tostring(dayLow, "#.##"),  color.new(cDay, 25))
    if showSessHL
        lblPreH := f_lbl(lblPreH, true, rx, preHigh, "PreH " + str.tostring(preHigh, "#.##"), color.new(cPM, 25))
        lblPreL := f_lbl(lblPreL, true, rx, preLow,  "PreL " + str.tostring(preLow, "#.##"),  color.new(cPM, 25))
    if showOR
        lblOrH := f_lbl(lblOrH, true, rx, orHigh, "ORH " + str.tostring(orHigh, "#.##"), color.new(cOR, 25))
        lblOrL := f_lbl(lblOrL, true, rx, orLow,  "ORL " + str.tostring(orLow, "#.##"),  color.new(cOR, 25))
    if showSwings
        lblSwH := f_lbl(lblSwH, true, rx, lastSwingHigh, "SwH " + str.tostring(lastSwingHigh, "#.##"), color.new(cSwing, 25))
        lblSwL := f_lbl(lblSwL, true, rx, lastSwingLow,  "SwL " + str.tostring(lastSwingLow, "#.##"),  color.new(cSwing, 25))
    if showEMAs
        lblE9  := f_lbl(lblE9,  true, rx, emaFast, "9 "  + str.tostring(emaFast, "#.##"), color.new(cEma9, 25))
        lblE21 := f_lbl(lblE21, true, rx, emaMid,  "21 " + str.tostring(emaMid, "#.##"),  color.new(cEma21, 25))
        lblE50 := f_lbl(lblE50, true, rx, emaSlow, "50 " + str.tostring(emaSlow, "#.##"), color.new(cEma50, 25))
    if showVWAP
        lblVw := f_lbl(lblVw, true, rx, vwapVal, "VWAP " + str.tostring(vwapVal, "#.##"), color.new(cVwap, 25))

// ============================================================
// ============== DASHBOARD ===================================
// ============================================================
var table dash = table.new(position.top_right, 2, 16, bgcolor=color.new(#1A1F2E, 10), border_width=1, border_color=color.new(#2C3E50, 50), frame_color=color.new(#2C3E50, 50), frame_width=2)

cHeader = color.new(#34495E, 0)
cCellBg = color.new(#2C3E50, 60)

if barstate.islast
    cstStr = str.format("{0,number,00}:{1,number,00}", hourCST, minCST)

    timeStatus = inMOCWindow ? "MOC ●"     : inOpenChop ? "OPEN ✗"  : inLunch ? "LUNCH ✗" : inLateAft ? "LATE ✗"  : inGoodWindow ? "PRIME ✓" : "—"
    timeCol = inMOCWindow ? cMOC_Bl : (inOpenChop or inLunch or inLateAft) ? color.gray : cB_Bull

    trendStr = bullScore >= 5 ? "▲ STRONG BULL" : bullScore == 4 ? "▲ Bull" : bearScore >= 5 ? "▼ STRONG BEAR" : bearScore == 4 ? "▼ Bear" : "— Chop"
    trendCol = bullScore >= 5 ? cA_Bull : bullScore == 4 ? cB_Bull : bearScore >= 5 ? cA_Bear : bearScore == 4 ? cB_Bear : color.gray

    patStr = bullPatternName != "" ? "▲ " + bullPatternName : bearPatternName != "" ? "▼ " + bearPatternName : "—"
    patCol = isSpring ? cWyBull : isUpthrust ? cWyBear : bullPatternName != "" ? cB_Bull : bearPatternName != "" ? cB_Bear : color.gray

    actionStr = inCall ? "● IN " + callTier + " CALL" : inPut ? "● IN " + putTier + " PUT" : finalACall ? "▲ A CALL" : finalBCall ? "▲ B CALL" : finalMOCCall ? "● MOC CALL" : finalAPut ? "▼ A PUT" : finalBPut ? "▼ B PUT" : finalMOCPut ? "● MOC PUT" : "WAIT"
    actionCol = inCall or finalACall or finalBCall or finalMOCCall ? cB_Bull : inPut or finalAPut or finalBPut or finalMOCPut ? cB_Bear : color.new(color.gray, 30)

    revStr = revWarnInCall ? "⚠ EXIT CALL" : revWarnInPut ? "⚠ EXIT PUT" : bullReversalZone ? "↗ BULL ZONE" : bearReversalZone ? "↘ BEAR ZONE" : "—"
    revCol = revWarnInCall or revWarnInPut ? cRev : bullReversalZone ? cB_Bull : bearReversalZone ? cB_Bear : color.gray

    wyStr = isSpring ? "★ SPRING" : isUpthrust ? "★ UPTHRUST" : pendingSpring ? "Sweep ↓ pending" : pendingUpthrust ? "Sweep ↑ pending" : "—"
    wyCol = isSpring ? cWyBull : isUpthrust ? cWyBear : pendingSpring or pendingUpthrust ? cRev : color.gray

    table.cell(dash, 0, 0, "TIME (CST)", text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 0, cstStr,        text_color=cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 1, "WINDOW",      text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 1, timeStatus,    text_color=timeCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 2, "TREND",       text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 2, trendStr,      text_color=trendCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 3, "BULL",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(bullScore) + "/6", text_color=bullScore >= 5 ? cA_Bull : bullScore >= 4 ? cB_Bull : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 4, "BEAR",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(bearScore) + "/6", text_color=bearScore >= 5 ? cA_Bear : bearScore >= 4 ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 5, "RSI",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(rsiVal, "#.#"), text_color=rsiVal > 70 ? cA_Bear : rsiVal < 30 ? cA_Bull : cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 6, "MACD",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 6, macdBullOk ? "▲" : macdBearOk ? "▼" : "—", text_color=macdBullOk ? cB_Bull : macdBearOk ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 7, "VOL",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 7, volQualified ? "✓ HIGH" : "low", text_color=volQualified ? cB_Bull : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 8, "S/R",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 8, touchedSupport ? "SUPPORT" : touchedResistance ? "RESIST" : "—", text_color=touchedSupport ? cB_Bull : touchedResistance ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 9, "HTF",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 9, htfBull ? "▲" : htfBear ? "▼" : "—", text_color=htfBull ? cB_Bull : htfBear ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 10, "PATTERN",    text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 10, patStr,       text_color=patCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 11, "WYCKOFF",    text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 11, wyStr,        text_color=wyCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 12, "ATR",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 12, str.tostring(atrVal, "#.##"), text_color=cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 13, "REVERSAL",   text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 13, revStr,       text_color=revCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 14, "ACTION",     text_color=color.white, bgcolor=actionCol, text_size=size.normal)
    table.cell(dash, 1, 14, actionStr,    text_color=color.white, bgcolor=actionCol, text_size=size.normal)

    if inCall
        tpStr = callTP1Hit ? "TP2 " + str.tostring(callTP2, "#.##") + " · BE" : "TP1 " + str.tostring(callTP1, "#.##") + " · SL " + str.tostring(callStop, "#.##")
        table.cell(dash, 0, 15, "TGT/SL", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, tpStr, text_color=cText, bgcolor=cCellBg, text_size=size.small)
    else if inPut
        tpStr = putTP1Hit ? "TP2 " + str.tostring(putTP2, "#.##") + " · BE" : "TP1 " + str.tostring(putTP1, "#.##") + " · SL " + str.tostring(putStop, "#.##")
        table.cell(dash, 0, 15, "TGT/SL", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, tpStr, text_color=cText, bgcolor=cCellBg, text_size=size.small)
    else
        table.cell(dash, 0, 15, "PRICE", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, str.tostring(close, "#.##"), text_color=cText, bgcolor=cCellBg, text_size=size.small)

// ============================================================
// ============== ALERTS ======================================
// ============================================================
alertcondition(finalACall,    title="A CALL",     message="A-Setup CALL fired — 6/6 score")
alertcondition(finalBCall,    title="B CALL",     message="B-Setup CALL fired — 4-5/6 score")
alertcondition(finalAPut,     title="A PUT",      message="A-Setup PUT fired — 6/6 score")
alertcondition(finalBPut,     title="B PUT",      message="B-Setup PUT fired — 4-5/6 score")
alertcondition(finalMOCCall,  title="MOC CALL",   message="MOC CALL fired")
alertcondition(finalMOCPut,   title="MOC PUT",    message="MOC PUT fired")
alertcondition(tp1HitCall or tp1HitPut, title="TP1 Hit", message="TP1 hit — stop moved to breakeven")
alertcondition(sellCall,      title="EXIT CALL",  message="Exit call signal")
alertcondition(sellPut,       title="EXIT PUT",   message="Exit put signal")
alertcondition(revWarnInCall, title="Reversal Warning - In Call", message="Bearish reversal building while in CALL — consider exit")
alertcondition(revWarnInPut,  title="Reversal Warning - In Put",  message="Bullish reversal building while in PUT — consider exit")
alertcondition(bullReversalZone, title="Bull Reversal Zone", message="Bull reversal zone — watch for clean entry")
alertcondition(bearReversalZone, title="Bear Reversal Zone", message="Bear reversal zone — watch for clean entry")
alertcondition(isSpring,      title="★ SPRING",    message="Wyckoff Spring detected — bullish reversal")
alertcondition(isUpthrust,    title="★ UPTHRUST",  message="Wyckoff Upthrust detected — bearish reversal")
````
