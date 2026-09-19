<!-- tradingview-pine-id: PUB;a9660c243ad747bda37f4abab31ac74b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Fair Value Box John 

Source: https://www.tradingview.com/script/HbBce4su-Fair-Value-Box-John/

## Description

TITLE
Fair Value Box — Session Opening Range

DESCRIPTION
A precise, multi-timeframe Fair Value Box indicator that captures the exact opening minute's body range (open-close) at London and US market open, then extends it across the session as a visual reference.

KEY FEATURES
• Automatic session detection (London & US open times in exchange timezone)
• Captures the 1m opening candle's O/C range at exact session start — works identically on 1m, 5m, 15m, hourly, or any timeframe
• Fixed box range (no expansion during the session) — remains locked to the opening minute's body
• Two distinct box colors (teal for London, orange for US) with clean, semi-transparent fill
• Boxes grow right to track session progress; freeze at session close

USE CASES
• Identify institutional opening range behavior
• Track price acceptance/rejection of the session's first-minute range
• Reference level for scalping and intraday range trading
• Confluence with other key levels (previous day high/low, overnight moves)

TECHNICAL NOTES
Uses request.security_lower_tf() to reliably extract the 1m opening candle across all chart timeframes. Session times are timezone-aware and adjust automatically for daylight saving time.

SETTINGS
• Show Fair Value Box: Toggle on/off
• London Box Color: Customize London session box
• US Box Color: Customize US/Regular session box
• Session Timezone Inputs: Adjust for your broker's feed if needed

Perfect for traders who value precision opening range analysis on NAS100, indices, and forex during London and New York sessions.

---

## Source Code

````pine
//@version=6
indicator("Fair Value Box John ", overlay=true, max_boxes_count=500)

// ============================================================
// GROUPS
// ============================================================
G_SESS = "Session Times (exchange tz)"
G_FVB  = "Fair Value Box"

// ============================================================
// INPUTS — SESSION TIMES
// ============================================================
tzLondon    = input.string("Europe/London", "London Timezone", group=G_SESS)
tzUS        = input.string("America/New_York", "US Session Timezone", group=G_SESS)
sessLondon  = input.session("0800-1600", "London Session (local London time)", group=G_SESS)
sessRegular = input.session("0930-1600", "Regular Session (NY time)", group=G_SESS)

// ============================================================
// INPUTS — FAIR VALUE BOX
// ============================================================
fvbShow      = input.bool(true, "Show Fair Value Box", group=G_FVB)
fvbLondonCol = input.color(color.teal, "London Box Color", group=G_FVB)
fvbUSCol     = input.color(#D85A30, "US Box Color", group=G_FVB)

// ============================================================
// SESSION DETECTION
// ============================================================
inLondon  = not na(time(timeframe.period, sessLondon, tzLondon))
inRegular = not na(time(timeframe.period, sessRegular, tzUS))

newLondon  = inLondon  and not inLondon[1]
newRegular = inRegular and not inRegular[1]
newRegularClose = not inRegular and inRegular[1]

// ============================================================
// 1M SNAPSHOT — OPENING CANDLE O/C ONLY, ALL TIMEFRAMES
// ============================================================
// request.security_lower_tf() returns arrays of EVERY 1m bar inside
// the current chart bar. At session start (newLondon/newRegular),
// the FIRST element [0] is the 1m candle that opened at or after
// session start time. Lock its open and close.
//
// This works on 1m, 5m, 15m, hourly — anywhere.
// ============================================================
[ltfM1O, ltfM1C] = request.security_lower_tf(syminfo.tickerid, "1", [open, close])

var float m1OpenPrice  = na
var float m1ClosePrice = na

// Capture at session start: first 1m bar's open and close
if newLondon and array.size(ltfM1O) > 0
    m1OpenPrice  := array.get(ltfM1O, 0)
    m1ClosePrice := array.get(ltfM1C, 0)

if newRegular and array.size(ltfM1O) > 0
    m1OpenPrice  := array.get(ltfM1O, 0)
    m1ClosePrice := array.get(ltfM1C, 0)

// ============================================================
// FVB LOGIC — OPEN/CLOSE RANGE
// ============================================================
fvbBoxRange(oo, cc) =>
    top = math.max(oo, cc)
    bot = math.min(oo, cc)
    [top, bot]

var bool fvbLondonActive = false
var bool fvbUSActive     = false

if newLondon
    fvbLondonActive := true
    fvbUSActive     := false
if newRegular
    fvbUSActive     := true
    fvbLondonActive := false
if newRegularClose
    fvbUSActive := false

var box fvbLondonBox = na
var box fvbUSBox     = na

fvbDeleteBox(b) =>
    if not na(b)
        box.delete(b)

// Create London box at London open using the locked 1m opening candle O/C
if newLondon and fvbShow and not na(m1OpenPrice)
    [fvbT_London, fvbB_London] = fvbBoxRange(m1OpenPrice, m1ClosePrice)
    fvbDeleteBox(fvbLondonBox)
    fvbLondonBox := box.new(bar_index, fvbT_London, bar_index, fvbB_London, 
         border_color=fvbLondonCol, bgcolor=color.new(fvbLondonCol, 80), extend=extend.none)

// Create US box at US open using the locked 1m opening candle O/C
if newRegular and fvbShow and not na(m1OpenPrice)
    [fvbT_US, fvbB_US] = fvbBoxRange(m1OpenPrice, m1ClosePrice)
    fvbDeleteBox(fvbUSBox)
    fvbUSBox := box.new(bar_index, fvbT_US, bar_index, fvbB_US, 
         border_color=fvbUSCol, bgcolor=color.new(fvbUSCol, 80), extend=extend.none)

// Grow the boxes to the right as the session progresses
if fvbLondonActive and not na(fvbLondonBox)
    box.set_right(fvbLondonBox, bar_index)

if fvbUSActive and not na(fvbUSBox)
    box.set_right(fvbUSBox, bar_index)
````
