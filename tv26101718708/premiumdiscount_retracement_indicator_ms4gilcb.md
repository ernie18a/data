# Premium/Discount Retracement Indicator

- url: https://www.tradingview.com/script/ms4gILCB-Premium-Discount-Retracement-Indicator/
- type: indicator
- pine_id: PUB;92038c66117b427fa4825a6b8fe6c3c9
- version: 5.0

## Description

The indicator works in four layers.

**The major swing** — it scans the chart for a significant impulse move using a pivot-based lookback. Once it finds a clear swing low and swing high (or high then low), it locks that range in and draws a horizontal 50% line across the middle. Everything above that line is premium, everything below is discount.

**The retracement zone** — after the major move, it watches for a smaller pullback forming within the range. When that pullback produces its own local high and local low, those two levels become the zone boundaries. The zone is drawn as a two-colour box: teal on top, red on the bottom, split at the midpoint. Only zones sitting in the discount area qualify for buys, and only zones in the premium area qualify for sells, so it automatically filters out setups that go against the structure.

**The entry** — a limit order line sits at the exact midpoint of the zone. Nothing happens until price returns to that level. If price dips into the zone but reverses before touching the midpoint and then closes back above the zone boundary, the zone is marked as rejected and the limit is cancelled automatically. This handles the scenario where price taps the upper portion of the zone but doesn't commit.

**Trade levels** — once the limit is hit, three levels are displayed. The stop loss is placed just beyond the outer zone boundary with a small buffer. The take profit is calculated at 1:2 risk-to-reward from the entry. A break-even line sits at the 1:1 level, and an alert fires when price reaches it so you know when to move your stop to entry.

There are also four alerts: zone created, order filled, zone cancelled, and move to break even.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Abyan Quant Wala", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Group Name: Settings ---
swingLenInput  = input.int(10, "Main Swing Length", minval = 5, tooltip = "Length for main structure pivots (BOS/MSS)")
minorLenInput  = input.int(2, "Internal Retracement Length", minval = 1, tooltip = "Length for internal pullback pivots")
rrInput        = input.float(2.0, "Risk:Reward Ratio", minval = 0.1, step = 0.1)
beRRInput      = input.float(1.0, "Break Even RR", minval = 0.1, step = 0.1)
approachInput  = input.float(0.05, "Alert Approach (%)", minval = 0.01, step = 0.01)
hideMitigated  = input.bool(true, "Hide Mitigated Zones", tooltip = "If true, zones will disappear once price touches the midpoint (entry)")

// --- Group Name: Style ---
bullColor      = input.color(color.new(#089981, 85), "Bullish Zone Color", inline = "Zones")
bearColor      = input.color(color.new(#f23645, 85), "Bearish Zone Color", inline = "Zones")
eqColor        = input.color(color.gray, "Equilibrium Line Color")
longColor      = #089981
shortColor     = #f23645

// --- Types ---
type Zone
    float top
    float bottom
    float mid
    int   direction // 1 for Long, -1 for Short
    box   boxId
    line  lineId
    bool  mitigated = false

var Zone[] activeZones = array.new<Zone>()

// --- Pivot Detection ---
float mainPh = ta.pivothigh(high, swingLenInput, swingLenInput)
float mainPl = ta.pivotlow(low, swingLenInput, swingLenInput)
float miPh   = ta.pivothigh(high, minorLenInput, minorLenInput)
float miPl   = ta.pivotlow(low, minorLenInput, minorLenInput)

var float lastMainPh = na
var float lastMainPl = na
var int   lastMainPhIdx = na
var int   lastMainPlIdx = na

if not na(mainPh)
    lastMainPh := mainPh
    lastMainPhIdx := bar_index - swingLenInput
if not na(mainPl)
    lastMainPl := mainPl
    lastMainPlIdx := bar_index - swingLenInput

// Detect Break of Structure (BOS)
bool bullBOS = not na(lastMainPh) and ta.crossover(close, lastMainPh)
bool bearBOS = not na(lastMainPl) and ta.crossunder(close, lastMainPl)

// --- Zone Identification (Strict P/D + BOS Required) ---
if bullBOS and not na(lastMainPlIdx)
    float legHigh = high
    float legLow  = lastMainPl
    float legMid  = (legHigh + legLow) / 2
    
    int lookback = bar_index - lastMainPlIdx
    for i = lookback to 0
        if not na(miPh[i])
            for j = math.max(0, i - 1) to 0
                if not na(miPl[j])
                    float rTop = high[i + minorLenInput]
                    float rBot = low[j + minorLenInput]
                    float rMid = (rTop + rBot) / 2
                    
                    // Rule: ENTIRE zone must be in discount (top < legMid)
                    if rTop < legMid
                        box  b = box.new(bar_index - (i + minorLenInput), rTop, bar_index, rBot, bgcolor = bullColor, border_color = color.new(bullColor, 40))
                        line l = line.new(bar_index - (i + minorLenInput), rMid, bar_index, rMid, color = longColor, width = 1, style = line.style_dashed)
                        activeZones.push(Zone.new(rTop, rBot, rMid, 1, b, l, false))
                    break 

if bearBOS and not na(lastMainPhIdx)
    float legLow  = low
    float legHigh = lastMainPh
    float legMid  = (legHigh + legLow) / 2
    
    int lookback = bar_index - lastMainPhIdx
    for i = lookback to 0
        if not na(miPl[i])
            for j = math.max(0, i - 1) to 0
                if not na(miPh[j])
                    float rBot = low[i + minorLenInput]
                    float rTop = high[j + minorLenInput]
                    float rMid = (rTop + rBot) / 2
                    
                    // Rule: ENTIRE zone must be in premium (bottom > legMid)
                    if rBot > legMid
                        box  b = box.new(bar_index - (i + minorLenInput), rTop, bar_index, rBot, bgcolor = bearColor, border_color = color.new(bearColor, 40))
                        line l = line.new(bar_index - (i + minorLenInput), rMid, bar_index, rMid, color = shortColor, width = 1, style = line.style_dashed)
                        activeZones.push(Zone.new(rTop, rBot, rMid, -1, b, l, false))
                    break

// --- Mitigation Logic & Visualization Update ---
if activeZones.size() > 0
    for i = activeZones.size() - 1 to 0
        Zone z = activeZones.get(i)
        if not z.mitigated
            // Check for Mitigation (price taps midpoint)
            bool touched = (z.direction == 1 and low <= z.mid) or (z.direction == -1 and high >= z.mid)
            
            if touched
                z.mitigated := true
                if hideMitigated
                    box.delete(z.boxId)
                    line.delete(z.lineId)
                else
                    box.set_bgcolor(z.boxId, color.new(color.gray, 90))
                    line.set_color(z.lineId, color.new(color.gray, 50))
                
                alert("Zone Mitigated: Price tapped midpoint at " + str.tostring(z.mid), alert.freq_once_per_bar)
            else
                // Extend active zones to current bar
                box.set_right(z.boxId, bar_index)
                line.set_x2(z.lineId, bar_index)
                
                // Approach Alert Logic
                float dist = math.abs(close - z.mid) / z.mid * 100
                if dist <= approachInput
                    alert("Price approaching " + (z.direction == 1 ? "Discount" : "Premium") + " Zone: " + str.tostring(z.mid), alert.freq_once_per_bar)

// --- Visuals: Swing Equilibrium ---
var float swingMid = na
if bullBOS or bearBOS
    swingMid := (lastMainPh + lastMainPl) / 2
plot(swingMid, "Swing Equilibrium", color.new(eqColor, 50), 1, plot.style_linebr)
````
