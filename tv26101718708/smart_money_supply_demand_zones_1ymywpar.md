# Smart Money Supply & Demand Zones

- url: https://www.tradingview.com/script/1ymYwPaR-Smart-Money-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;749071605e644e9f88650d781cc3a750
- version: 1.0

## Description

How It Works:
Feature	Description
🔴 Supply Zones (Red)	Last bullish candle before a strong downward move — where institutions sold
🟢 Demand Zones (Green)	Last bearish candle before a strong upward move — where institutions bought
Displacement Filter	Uses ATR × 1.5 multiplier to ensure only high-momentum "institutional" moves create zones
Mitigation Tracking	Zones turn grey once price tests them — optional to hide tested zones
Zone Labels	Shows price range for quick reference
Auto-Cleanup	Keeps only the 10 most recent zones to avoid chart clutter
Settings You Can Adjust:
Input	Default	Purpose
Swing Lookback	5	Higher = fewer, larger "major" zones; Lower = more frequent "minor" zones
Displacement Multiplier	1.5	Higher = requires more aggressive price action to validate a zone
Show Tested Zones	true	false = only show fresh, untested zones
Max Zones to Display	10	Limit visual clutter
Trading Tips:
Best Entries: Price returning to an untested demand zone in an uptrend (or supply zone in a downtrend)
Invalidation: If price closes through the zone (not just touches), the zone is considered "mitigated"
Confluence: Combine with your existing SMC indicator (LuxAlgo) for stronger signals
Timeframes: Works on any TF — higher TFs = stronger zones

## Source Code

````pine
//@version=6
indicator("Smart Money Supply & Demand Zones", overlay=true, max_boxes_count=100, max_labels_count=100)

// --- Inputs ---
swingLen      = input.int(5, "Swing Lookback", minval=2, tooltip="Number of bars on each side for pivot detection")
atrLen        = input.int(14, "ATR Length", tooltip="Length for ATR displacement calculation")
displaceMult  = input.float(1.5, "Displacement Multiplier", minval=1.0, step=0.1, tooltip="Momentum requirement: Candle body must be > ATR * Multiplier")
showTested    = input.bool(true, "Show Tested Zones", tooltip="Keep zones on chart after price has touched them")
zoneLimit     = input.int(10, "Display Limit (Per Type)", minval=1, maxval=50, tooltip="Maximum number of active zones to display simultaneously")

// Colors
colorSupply   = input.color(color.new(color.red, 80), "Supply Color", group="Visuals")
colorDemand   = input.color(color.new(color.green, 80), "Demand Color", group="Visuals")
colorTested   = input.color(color.new(color.gray, 90), "Tested Color", group="Visuals")

// --- Types & Storage ---
type Zone
    box   b
    label l
    float top
    float bottom
    bool  isSupply
    bool  isTested
    int   startBar

var demandZones = array.new<Zone>()
var supplyZones = array.new<Zone>()

// --- Logic ---
atr = ta.atr(atrLen)

// Pivot Detection
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// Displacement Check (Momentum)
isDisplaced(index) =>
    body = math.abs(close[index] - open[index])
    body > atr[index] * displaceMult

// --- Zone Identification ---

// 1. Demand Zones (Bullish Order Block)
if not na(ph)
    for i = 1 to 10
        idx = swingLen + i
        if close[idx] < open[idx] and isDisplaced(idx - 1)
            zTop = high[idx]
            zBot = low[idx]
            
            b = box.new(bar_index[idx], zTop, bar_index, zBot, 
                 bgcolor=colorDemand, border_color=color.green, 
                 extend=extend.right)
            lab = label.new(bar_index, zTop, "Demand", 
                 style=label.style_label_up, color=color.new(color.green, 100), 
                 textcolor=color.green, size=size.small)
            
            array.unshift(demandZones, Zone.new(b, lab, zTop, zBot, false, false, bar_index[idx]))
            break

// 2. Supply Zones (Bearish Order Block)
if not na(pl)
    for i = 1 to 10
        idx = swingLen + i
        if close[idx] > open[idx] and isDisplaced(idx - 1)
            zTop = high[idx]
            zBot = low[idx]
            
            b = box.new(bar_index[idx], zTop, bar_index, zBot, 
                 bgcolor=colorSupply, border_color=color.red, 
                 extend=extend.right)
            lab = label.new(bar_index, zBot, "Supply", 
                 style=label.style_label_down, color=color.new(color.red, 100), 
                 textcolor=color.red, size=size.small)
            
            array.unshift(supplyZones, Zone.new(b, lab, zTop, zBot, true, false, bar_index[idx]))
            break

// --- Mitigation Logic (Testing Zones) ---
updateZones(array<Zone> zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            if not z.isTested
                // Check if price has entered the zone
                bool touched = z.isSupply ? high > z.bottom : low < z.top
                if touched
                    z.isTested := true
                    if showTested
                        box.set_bgcolor(z.b, colorTested)
                        box.set_border_color(z.b, color.gray)
                        box.set_extend(z.b, extend.none)
                        box.set_right(z.b, bar_index)
                        label.delete(z.l)
                    else
                        box.delete(z.b)
                        label.delete(z.l)
            
            // Clean up if we exceed limit
            if i >= zoneLimit
                box.delete(z.b)
                label.delete(z.l)
                array.remove(zones, i)

updateZones(demandZones)
updateZones(supplyZones)

// --- Alerts ---
alertcondition(ta.crossover(low, array.size(demandZones) > 0 ? array.get(demandZones, 0).top : na), "Price Entering Demand", "Price has touched a Demand Zone")
alertcondition(ta.crossunder(high, array.size(supplyZones) > 0 ? array.get(supplyZones, 0).bottom : na), "Price Entering Supply", "Price has touched a Supply Zone")
````
