# Choppy Soup Indicator - Range Market Filter

- url: https://www.tradingview.com/script/F2cUOoa7/
- type: indicator
- pine_id: PUB;f483d4bdcc9d48a5a3de3db03cce657b
- version: 1.0

## Description

Every trend trader knows the frustration of giving back hard-earned profits during sideways, choppy market phases. Trend-following indicators will inevitably produce false signals when the price is simply ping-ponging within a range.

The Choppy Soup Indicator is designed to solve exactly this problem. It is not an entry trigger; it is a strict confluence filter. Its primary purpose is to give you the confidence to sit on your hands and NOT enter a trade when the market is trapped in a range.

By analyzing multiple dimensions of the market simultaneously, it acts as a shield against the "choppy soup," ensuring you only allocate capital when true momentum is present.

The Golden Rule: All Signals Must Align
This indicator operates on an uncompromising "All or Nothing" logic. The built-in dashboard tracks up to five critical market conditions (Session Timing, ADX Trend Strength, Volume Confirmation, Higher Timeframe Trend, and Market Structure Breakouts).

For a Long or Short signal to be validated, every single active filter must agree. If even one condition points to a choppy or contradictory market state, the master signal will default to "WAIT". There are no exceptions.

Recommended Combination for Maximum Confluence
To build a complete and robust trading system, the Choppy Soup Indicator is designed to act as a final gatekeeper for a trend trading setup using e.g. these 2 Indicators as a basic framework:

Indicator 1: https://de.tradingview.com/v/5m7lZmll/

Indicator 2: https://de.tradingview.com/v/ypZ7TSjN/

How to trade the system:

Wait for a clear Long or Short entry signal from the two indicators linked above.
They must align and the signals should be fresh.

Before executing the trade, check the Choppy Soup Indicator dashboard.

If the dashboard displays "READY" for your specific trade direction, all confluence factors are aligned, and you have a high-probability setup.

If the dashboard displays "WAIT", the market lacks the necessary momentum or structure. You must ignore the entry signal to avoid getting chopped out.

Core Filter Features (Fully Adjustable):

Session Time Filter: Automatically blocks trades during historically low-volume hours (e.g., lunch breaks or late evenings).

ADX Filter: Measures pure trend strength. If the ADX drops below your defined threshold, the market is classified as sideways.

Volume Confirmation: Requires a volume spike above the moving average to validate that real capital is driving the move.

MTFA (Multi-Timeframe Analysis): Prevents you from trading against the dominant trend of a higher timeframe.

Market Structure: Ensures price action has actually broken out of a recent high or low before validating a move.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quantastics_ai

//@version=6
indicator('Choppy Soup Sniffer', shorttitle = 'Choppy Soup', overlay = true)

// =============================================================================
// 1. INPUTS & SETTINGS
// =============================================================================

// --- Session Filter ---
grp_sess = '1. Session Timing'
useSess = input.bool(true, 'Enable Session Filter', group = grp_sess)
sessTime = input.session('0900-1130,1530-1700', 'Trading Hours', group = grp_sess, tooltip = 'High volume time windows (e.g., European/US Open).')
tzOffset = input.string('Europe/Berlin', 'Timezone', options = ['Exchange', 'UTC', 'America/New_York', 'Europe/London', 'Europe/Berlin', 'Asia/Tokyo', 'Australia/Sydney'], group = grp_sess, tooltip = 'Select your preferred timezone for the session filter.')

// --- ADX (Trend Strength) ---
grp_adx = '2. ADX (Trend Strength)'
useAdx = input.bool(true, 'Enable ADX Filter', group = grp_adx)
adxLen = input.int(14, 'ADX Length', group = grp_adx, minval = 1)
adxThresh = input.int(20, 'ADX Minimum Level', group = grp_adx, minval = 10, tooltip = 'Values below 20/25 indicate ranging/choppy markets.')

// --- Volume (Confirmation) ---
grp_vol = '3. Volume Confirmation'
useVol = input.bool(true, 'Enable Volume Filter', group = grp_vol)
volLen = input.int(20, 'Volume SMA Length', group = grp_vol, minval = 1)
volMult = input.float(1.2, 'Volume Multiplier', step = 0.1, minval = 0.5, group = grp_vol, tooltip = '1.2 means: Current volume must be 20% higher than the moving average.')

// --- MTFA (Higher Timeframe Trend) ---
grp_mtf = '4. Multi-Timeframe Trend (MTFA)'
useMtf = input.bool(true, 'Enable MTFA Filter', group = grp_mtf)
mtfRes = input.timeframe('15', 'Higher Timeframe (HTF)', group = grp_mtf)
mtfMaLen = input.int(50, 'HTF EMA Length', group = grp_mtf, minval = 1)

// --- Market Structure (Breakout) ---
grp_str = '5. Market Structure (Breakout)'
useStr = input.bool(true, 'Enable Structure Filter', group = grp_str)
strLen = input.int(20, 'Lookback Periods', group = grp_str, minval = 1, tooltip = 'Checks if the current price closes above/below the highest high/lowest low of the last X bars.')

// --- Dashboard Settings ---
grp_dash = '6. Dashboard & Visuals'
showDash = input.bool(true, 'Show Dashboard', group = grp_dash)
dashPos = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = grp_dash)
dashSize = input.string('Normal', 'Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grp_dash)
showBg = input.bool(false, 'Highlight Background on Valid Setup', group = grp_dash)
showMkrs = input.bool(true, 'Show Chart Markers', group = grp_dash)

// =============================================================================
// 2. CALCULATIONS
// =============================================================================

// 1. Session Filter logic
inSession = time(timeframe.period, sessTime, tzOffset)
isSessOk = not useSess or not na(inSession)

// 2. ADX logic
[diplus, diminus, adxVal] = ta.dmi(adxLen, adxLen)
isAdxOk = not useAdx or adxVal >= adxThresh

// 3. Volume logic
volSma = ta.sma(volume, volLen)
isVolOk = not useVol or volume >= volSma * volMult

// 4. MTFA logic (Strict non-repainting using lookahead_off)
htfEma = request.security(syminfo.tickerid, mtfRes, ta.ema(close, mtfMaLen), barmerge.gaps_off, barmerge.lookahead_off)
mtfBull = close > htfEma
mtfBear = close < htfEma
isMtfLong = not useMtf or mtfBull
isMtfShort = not useMtf or mtfBear

// 5. Structure logic
highestHigh = ta.highest(high, strLen)[1]
lowestLow = ta.lowest(low, strLen)[1]
strBull = close > highestHigh
strBear = close < lowestLow
isStrLong = not useStr or strBull
isStrShort = not useStr or strBear

// --- Master Confluence ---
validLong = isSessOk and isAdxOk and isVolOk and isMtfLong and isStrLong
validShort = isSessOk and isAdxOk and isVolOk and isMtfShort and isStrShort

// Triggers for markers & alerts
longTrigger = validLong and not validLong[1]
shortTrigger = validShort and not validShort[1]

// =============================================================================
// 3. VISUALIZATION, DASHBOARD & ALERTS
// =============================================================================

// Helper functions for dashboard layout
getPos(p) =>
    p == 'Top Right' ? position.top_right : p == 'Top Left' ? position.top_left : p == 'Bottom Right' ? position.bottom_right : position.bottom_left

getSize(s) =>
    s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : s == 'Normal' ? size.normal : s == 'Large' ? size.large : size.huge

// Color logic: uses semi-transparent gray for inactive states
getColor(cond, defaultColor) =>
    cond ? defaultColor : color.new(color.gray, 60)

getIcon(cond) =>
    cond ? '✅' : '❌'

// Dashboard State Tracking (Prevents redundant table updates, renders only on the last bar)
var table tbl = table.new(getPos(dashPos), 3, 7, frame_color = #333333, frame_width = 1, border_width = 1, border_color = #333333)

// Update dashboard only if active and on the last bar (best performance)
if showDash and barstate.islast
    // Header
    table.cell(tbl, 0, 0, 'Filter Factor', text_color = color.white, bgcolor = #1a1a1a, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 0, 'Long Valid?', text_color = color.white, bgcolor = #1a1a1a, text_size = getSize(dashSize))
    table.cell(tbl, 2, 0, 'Short Valid?', text_color = color.white, bgcolor = #1a1a1a, text_size = getSize(dashSize))

    // 1. Session
    table.cell(tbl, 0, 1, 'Session Time', text_color = color.white, bgcolor = #262626, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 1, getIcon(isSessOk), text_color = getColor(isSessOk, color.green), bgcolor = #262626, text_size = getSize(dashSize))
    table.cell(tbl, 2, 1, getIcon(isSessOk), text_color = getColor(isSessOk, color.red), bgcolor = #262626, text_size = getSize(dashSize))

    // 2. ADX
    table.cell(tbl, 0, 2, 'ADX > ' + str.tostring(adxThresh), text_color = color.white, bgcolor = #262626, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 2, getIcon(isAdxOk), text_color = getColor(isAdxOk, color.green), bgcolor = #262626, text_size = getSize(dashSize))
    table.cell(tbl, 2, 2, getIcon(isAdxOk), text_color = getColor(isAdxOk, color.red), bgcolor = #262626, text_size = getSize(dashSize))

    // 3. Volume
    table.cell(tbl, 0, 3, 'Volume Spike', text_color = color.white, bgcolor = #262626, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 3, getIcon(isVolOk), text_color = getColor(isVolOk, color.green), bgcolor = #262626, text_size = getSize(dashSize))
    table.cell(tbl, 2, 3, getIcon(isVolOk), text_color = getColor(isVolOk, color.red), bgcolor = #262626, text_size = getSize(dashSize))

    // 4. MTFA
    table.cell(tbl, 0, 4, 'MTFA (' + mtfRes + ')', text_color = color.white, bgcolor = #262626, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 4, getIcon(isMtfLong), text_color = getColor(isMtfLong, color.green), bgcolor = #262626, text_size = getSize(dashSize))
    table.cell(tbl, 2, 4, getIcon(isMtfShort), text_color = getColor(isMtfShort, color.red), bgcolor = #262626, text_size = getSize(dashSize))

    // 5. Structure
    table.cell(tbl, 0, 5, 'Market Structure', text_color = color.white, bgcolor = #262626, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 5, getIcon(isStrLong), text_color = getColor(isStrLong, color.green), bgcolor = #262626, text_size = getSize(dashSize))
    table.cell(tbl, 2, 5, getIcon(isStrShort), text_color = getColor(isStrShort, color.red), bgcolor = #262626, text_size = getSize(dashSize))

    // 6. Master Signal
    masterBgLong = validLong ? color.new(color.green, 70) : #1a1a1a
    masterBgShort = validShort ? color.new(color.red, 70) : #1a1a1a
    table.cell(tbl, 0, 6, 'MASTER', text_color = color.white, bgcolor = #1a1a1a, text_size = getSize(dashSize), text_halign = text.align_left)
    table.cell(tbl, 1, 6, validLong ? 'READY' : 'WAIT', text_color = getColor(validLong, color.white), bgcolor = masterBgLong, text_size = getSize(dashSize))
    table.cell(tbl, 2, 6, validShort ? 'READY' : 'WAIT', text_color = getColor(validShort, color.white), bgcolor = masterBgShort, text_size = getSize(dashSize))

// Background Highlight
bgcolor(showBg ? validLong ? color.new(color.green, 90) : validShort ? color.new(color.red, 90) : na : na, title = 'Background Signal')

// Plot Markers
plotshape(showMkrs and longTrigger, title = 'Long Signal Marker', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(showMkrs and shortTrigger, title = 'Short Signal Marker', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)

// Alerts
alertcondition(longTrigger, title = 'Long Setup Ready', message = 'Confluence Filter: Long Setup is Valid!')
alertcondition(shortTrigger, title = 'Short Setup Ready', message = 'Confluence Filter: Short Setup is Valid!')
````
