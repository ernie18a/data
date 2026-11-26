# PIVOTRIX 

- url: https://www.tradingview.com/script/fVbGrv2o-PIVOTRIX/
- type: indicator
- pine_id: PUB;7dcb0a891ffd4c6b8b71ec891ad0726c
- version: 1.0

## Description

1. Multi-Timeframe Footprint Filtering
The script continually looks into the 1-Hour (60-minute) timeframe to analyze transaction profiles. When it captures an hourly candle with trading volume exceeding its 20-period moving average by 1.5 times, it registers the candle's structural high or low as a fresh Institutional Order Block (OB).
2. Proximity Confluence Engine
Instead of mapping standard, rigid pivot levels (\(R1\), \(S2\), etc.), the script calculates an expanded array of Daily Floor Pivots (\(R1\)-\(R3\) and \(S1\)-\(S3\)). It then runs an intelligent proximity sort at the market open:It looks at the asset's exact opening price at 9:16 AM.It cross-references the raw pivots with any overlapping 1-hour Order Blocks. If an institutional block sits within 1% of a pivot, the script warps the level onto the order block's exact coordinates.It selects the two closest resistance levels strictly above the opening price, and the two closest support levels strictly below it.
3. Continuous Unbroken Drawing
Once the script flags the four optimal structural boundaries at the opening anchor candle, it locks the values for the remainder of the session. This bypasses intraday price fluctuations and prevents the lines from repainting or fracturing. The channels are drawn continuously using native series plotting from the opening bell to the market close.
4. Volatility-Scaled Narrow Bands
To construct readable structural zones rather than standard microscopic lines, the script applies an Average True Range (ATR) offset. To ensure the zones remain slim, sharp, and do not crowd your chart, the indicator inputs a 10% compression factor (Daily ATR * Multiplier * 0.1). This locks in narrow channels scaled directly to the asset's active multi-day volatility index.

5. Market Open Context 
At 09:16 AM, look at where the asset price sits relative to the four narrow bands.

The Golden Bracket: 
The script locks the nearest structural levels based on volatility. 
If the distance between Resistance 1 and Support 1 is very narrow, expect a high-volatility breakout day. 
If the distance is wide, expect a choppy, range-bound day.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © svennela

//@version=6
indicator("PIVOTRIX by VS", overlay=true, max_labels_count=100)

// --- CONFIGURATION INPUTS ---
gp_session = "Session Configuration"
targetTime = input.string("0916", title="Calculation Trigger Time (HHMM)", tooltip="Wipes historical 1H OBs and locks the proximity bands at this exact minute.", group=gp_session)
timeZone   = input.string("Asia/Kolkata", title="Exchange Timezone", tooltip="Match this to your local market timezone.", group=gp_session)

gp_style  = "Visual Styling Configuration"
atrPeriod = input.int(14, title="ATR Reference Period", minval=1, group=gp_style)
devMult   = input.float(0.5, title="Zone ATR Multiplier", minval=0.01, step=0.05, tooltip="Lower values create narrower bands.", group=gp_style)
resColor  = input.color(color.new(#FFCC99, 80), title="Resistance Zones Color", group=gp_style)
supColor  = input.color(color.new(#99FF99, 80), title="Support Zones Color", group=gp_style)

// --- SESSION TIMING & CLOCK CONVERSIONS ---
// CRITICAL FIX: Explicitly convert the integer change into a strict boolean evaluation
int dayChange = ta.change(time("D"))
bool isNewDay = not na(dayChange) and dayChange != 0

int targetHour   = int(str.tonumber(str.substring(targetTime, 0, 2)))
int targetMinute = int(str.tonumber(str.substring(targetTime, 2, 4)))

int currentHour   = hour(time, timeZone)
int currentMinute = minute(time, timeZone)

// Identifies the exact baseline candle to lock the price bracket structure
bool isLockAnchor = (currentHour == targetHour and currentMinute == targetMinute) or (isNewDay and not ((currentHour > targetHour) or (currentHour == targetHour and currentMinute >= targetMinute)))

// --- 1-HOUR INSTITUTIONAL STRUCTURE (60M) ---
var float lastBullOB = na
var float lastBearOB = na

if isNewDay
    lastBullOB := na
    lastBearOB := na

float h_high   = request.security(syminfo.tickerid, "60", high, lookahead=barmerge.lookahead_off)
float h_low    = request.security(syminfo.tickerid, "60", low, lookahead=barmerge.lookahead_off)
float h_open   = request.security(syminfo.tickerid, "60", open, lookahead=barmerge.lookahead_off)
float h_close  = request.security(syminfo.tickerid, "60", close, lookahead=barmerge.lookahead_off)
float h_volume = request.security(syminfo.tickerid, "60", volume, lookahead=barmerge.lookahead_off)
float h_vol_ma = request.security(syminfo.tickerid, "60", ta.sma(volume, 20), lookahead=barmerge.lookahead_off)

if h_volume > (h_vol_ma * 1.5)
    if h_close > h_open
        lastBullOB := h_low
    if h_close < h_open
        lastBearOB := h_high

// --- EXPANDED DAILY PIVOT CALCULATIONS ---
float d_high   = request.security(syminfo.tickerid, "D", high, lookahead=barmerge.lookahead_off)
float d_low    = request.security(syminfo.tickerid, "D", low, lookahead=barmerge.lookahead_off)
float d_close  = request.security(syminfo.tickerid, "D", close, lookahead=barmerge.lookahead_off)
float d_atr    = request.security(syminfo.tickerid, "D", ta.atr(atrPeriod), lookahead=barmerge.lookahead_off)

float PP = (d_high + d_low + d_close) / 3.0
float R1_raw = (PP * 2) - d_low
float S1_raw = (PP * 2) - d_high
float R2_raw = PP + (d_high - d_low)
float S2_raw = PP - (d_high - d_low)
float R3_raw = d_high + 2.0 * (PP - d_low)
float S3_raw = d_low - 2.0 * (d_high - PP)

// Cross-match with previously formed 1H structural pivot zones (Order Blocks)
float R1 = not na(lastBearOB) and math.abs(R1_raw - lastBearOB) < (R1_raw * 0.01) ? lastBearOB : R1_raw
float R2 = not na(lastBearOB) and math.abs(R2_raw - lastBearOB) < (R2_raw * 0.01) ? lastBearOB : R2_raw
float R3 = not na(lastBearOB) and math.abs(R3_raw - lastBearOB) < (R3_raw * 0.01) ? lastBearOB : R3_raw
float S1 = not na(lastBullOB) and math.abs(S1_raw - lastBullOB) < (S1_raw * 0.01) ? lastBullOB : S1_raw
float S2 = not na(lastBullOB) and math.abs(S2_raw - lastBullOB) < (S2_raw * 0.01) ? lastBullOB : S2_raw
float S3 = not na(lastBullOB) and math.abs(S3_raw - lastBullOB) < (S3_raw * 0.01) ? lastBullOB : S3_raw

// --- PERSISTENT PROXIMITY LOCK ENGINE ---
var float active_R1 = na
var float active_R2 = na
var float active_S1 = na
var float active_S2 = na
var float active_offset = na

// Lock values and dynamic ATR heights for the day at the anchor bar
if isNewDay or isLockAnchor or na(active_R1)
    float refPrice = close
    active_offset := d_atr * devMult * 0.1 
    
    // Find closest 2 resistances strictly above opening reference price
    float r_diff1 = (R1 > refPrice) ? R1 - refPrice : 999999.0
    float r_diff2 = (R2 > refPrice) ? R2 - refPrice : 999999.0
    float r_diff3 = (R3 > refPrice) ? R3 - refPrice : 999999.0
    
    float min_r_diff = math.min(r_diff1, math.min(r_diff2, r_diff3))
    if min_r_diff == r_diff1
        active_R1 := R1
        active_R2 := (r_diff2 < r_diff3) ? R2 : R3
    else if min_r_diff == r_diff2
        active_R1 := R2
        active_R2 := (r_diff1 < r_diff3) ? R1 : R3
    else
        active_R1 := R3
        active_R2 := (r_diff1 < r_diff2) ? R1 : R2

    // Find closest 2 supports strictly below opening reference price
    float s_diff1 = (refPrice > S1) ? refPrice - S1 : 999999.0
    float s_diff2 = (refPrice > S2) ? refPrice - S2 : 999999.0
    float s_diff3 = (refPrice > S3) ? refPrice - S3 : 999999.0
    
    float min_s_diff = math.min(s_diff1, math.min(s_diff2, s_diff3))
    if min_s_diff == s_diff1
        active_S1 := S1
        active_S2 := (s_diff2 < s_diff3) ? S2 : S3
    else if min_s_diff == s_diff2
        active_S1 := S2
        active_S2 := (s_diff1 < s_diff3) ? S1 : S3
    else
        active_S1 := S3
        active_S2 := (s_diff1 < s_diff2) ? S1 : S2

// --- DYNAMIC ATR NARROW BAND CALCULATIONS ---
float R2_top = active_R2 + active_offset
float R2_btm = active_R2 - active_offset
float R1_top = active_R1 + active_offset
float R1_btm = active_R1 - active_offset

float S1_top = active_S1 + active_offset
float S1_btm = active_S1 - active_offset
float S2_top = active_S2 + active_offset
float S2_btm = active_S2 - active_offset

// --- NATIVE CONTINUOUS VISUALIZATION ---
plot_r2_t = plot(R2_top, "Resistance 2 Upper Band", color=color.new(resColor, 50))
plot_r2_b = plot(R2_btm, "Resistance 2 Lower Band", color=color.new(resColor, 50))
fill(plot_r2_t, plot_r2_b, color=resColor, title="Resistance 2 Filled Area Zone")

plot_r1_t = plot(R1_top, "Resistance 1 Upper Band", color=color.new(resColor, 50))
plot_r1_b = plot(R1_btm, "Resistance 1 Lower Band", color=color.new(resColor, 50))
fill(plot_r1_t, plot_r1_b, color=resColor, title="Resistance 1 Filled Area Zone")

plot_s1_t = plot(S1_top, "Support 1 Upper Band", color=color.new(supColor, 50))
plot_s1_b = plot(S1_btm, "Support 1 Lower Band", color=color.new(supColor, 50))
fill(plot_s1_t, plot_s1_b, color=supColor, title="Support 1 Filled Area Zone")

plot_s2_t = plot(S2_top, "Support 2 Upper Band", color=color.new(supColor, 50))
plot_s2_b = plot(S2_btm, "Support 2 Lower Band", color=color.new(supColor, 50))
fill(plot_s2_t, plot_s2_b, color=supColor, title="Support 2 Filled Area Zone")

// --- PERSISTENT LABELS ---
var label r2L = na
var label r1L = na
var label s1L = na
var label s2L = na

if isNewDay or isLockAnchor
    label.delete(r2L), label.delete(r1L), label.delete(s1L), label.delete(s2L)
    
    r2L := label.new(bar_index, active_R2, "Resistance 2", color=color.new(resColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
    r1L := label.new(bar_index, active_R1, "Resistance 1", color=color.new(resColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
    s1L := label.new(bar_index, active_S1, "Support 1", color=color.new(supColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
    s2L := label.new(bar_index, active_S2, "Support 2", color=color.new(supColor, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

if not na(r2L) and barstate.islast
    label.set_x(r2L, bar_index), label.set_x(r1L, bar_index)
    label.set_x(s1L, bar_index), label.set_x(s2L, bar_index)
````
