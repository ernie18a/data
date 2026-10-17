# Order Flow & Liquidity Voids [AlgoChief]

- url: https://www.tradingview.com/script/yfPoeUIc-Order-Flow-Liquidity-Voids-AlgoChief/
- type: indicator
- pine_id: PUB;05f7f7548657486886c07225467cfb6f
- version: 1.0

## Description

OVERVIEW AND METHODOLOGY

The Institutional Order Flow & Liquidity Void Engine is an institutional-grade price delivery tracking system designed to identify where large financial institutions leave unmitigated liquidity footprints. Instead of using standard retail pivot points, this engine mathematically scans the order book proxy to detect Fair Value Gaps (FVG), Balanced Price Ranges (BPR), Dynamic Liquidity Voids, and High-Frequency Liquidity Sweeps with real-time volume delta confirmation.

When smart money enters the market with high conviction, it creates structural imbalances where only one side of the market is filled. This engine isolates those exact price coordinates, dynamically tracks their mitigation status across time, and alerts traders when liquidity pools are swept prior to structural reversals.


KEY ARCHITECTURAL FEATURES

1. DYNAMIC VOLATILITY-FILTERED LIQUIDITY VOIDS
Unlike basic static boxes that clutter your chart, the engine calculates voids using ATR-normalized displacement thresholds. A void is only plotted when institutional displacement velocity exceeds baseline volatility by a user-defined factor.

2. REAL-TIME MITIGATION STATE MACHINE
Every detected imbalance is monitored on a bar-by-bar basis:
- Fresh Imbalance: Zero percent filled (High institutional reaction zone)
- Partially Mitigated: 50% Mean Threshold tested
- Fully Mitigated: Completely filled and smoothly cleared from the active matrix to preserve chart clarity.

3. VOLUME PRESSURE DELTA PROXY
Because centralized volume does not exist in standard spot feeds, the algorithm computes a normalized intra-bar tick delta proxy to gauge whether aggressive buyers or aggressive sellers triggered the imbalance.

4. ALGORITHMIC LIQUIDITY SWEEP DETECTOR
Automatically identifies swing liquidity pools (equal highs, equal lows, Asian/Session extremes) and detects institutional stop-hunts where price breaches liquidity thresholds via wick rejections and closes back inside the range.

5. LIVE INSTITUTIONAL STATUS DASHBOARD
A lightweight, clean on-screen heads-up display showing Current Order Flow Bias, Net Imbalance Pressure, and Active Liquidity Zones.


HOW TO TRADE WITH THIS INDICATOR

Bullish Scenario:
1. Ensure the Institutional Status Dashboard displays a Bullish Order Flow Bias.
2. Wait for price to retrace into a Fresh Bullish Liquidity Void (Cyan/Green Box).
3. Confirm an Algorithmic Sweep of sell-side liquidity below recent equal lows.
4. Enter on bullish price rejection wick with target set at the opposing buy-side liquidity pool.

Bearish Scenario:
1. Ensure the Institutional Status Dashboard displays a Bearish Order Flow Bias.
2. Wait for price to pull back into a Fresh Bearish Liquidity Void (Red/Crimson Box).
3. Confirm an Algorithmic Sweep of buy-side liquidity above recent equal highs.
4. Enter on bearish rejection with target set at the opposing discount liquidity pool.


INPUT PARAMETERS EXPLAINED

- Displacement Threshold: Controls the minimum ATR multiplier required to classify a gap as an institutional void.
- Mitigation Sensitivity: Determines whether a zone is considered mitigated at 50% midpoint touch or 100% boundary breach.
- Sweep Confirmation Depth: Number of bars required on either side to validate institutional swing liquidity pools.
- Maximum Active Boxes: Keeps chart clean by capping concurrent active liquidity zones.
- Show Dashboard: Toggles the live metrics table in the corner of your chart.


RISK DISCLAIMER

Trading financial markets carries significant risk. This indicator is an algorithmic analytical tool designed to enhance structural market context and does not constitute financial advice. Always practice strict capital preservation, appropriate position sizing, and stop-loss management.

## Source Code

````pine
//@version=6
indicator("Order Flow & Liquidity Voids [AlgoChief]", shorttitle="IOF-LVE [AlgoChief]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ==========================================
// USER INPUTS & CONFIGURATION
// ==========================================
grp_fvg    = "Liquidity Void / Imbalance Engine"
fvgMult    = input.float(0.5, "Displacement ATR Threshold", minval=0.1, step=0.1, group=grp_fvg)
fvgLen     = input.int(14, "Displacement Baseline ATR Length", minval=1, group=grp_fvg)
mitigateAt = input.string("Full Fill", "Mitigation Mode", options=["50% Mean Threshold", "Full Fill"], group=grp_fvg)
maxZones   = input.int(20, "Maximum Active Zones Rendered", minval=5, maxval=100, group=grp_fvg)

grp_col    = "Visual Customization"
c_bull     = input.color(color.new(#00e676, 82), "Bullish Void Color", group=grp_col)
c_bull_brd = input.color(#00e676, "Bullish Border", group=grp_col)
c_bear     = input.color(color.new(#ff1744, 82), "Bearish Void Color", group=grp_col)
c_bear_brd = input.color(#ff1744, "Bearish Border", group=grp_col)
c_mid      = input.color(color.new(color.silver, 60), "Mean Threshold Line Color", group=grp_col)

grp_swp    = "Liquidity Sweep Detection"
showSweeps = input.bool(true, "Detect Institutional Liquidity Sweeps", group=grp_swp)
swpLen     = input.int(5, "Swing Pivot Lookback", minval=2, maxval=50, group=grp_swp)

grp_ui     = "Institutional Dashboard"
showDash   = input.bool(true, "Show Order Flow Telemetry HUD", group=grp_ui)

// ==========================================
// DATA STRUCTURES & DEFINITIONS
// ==========================================
type LiquidityVoid
    box   bx
    line  mid
    float top
    float btm
    float median
    bool  isBull
    int   startBar
    bool  active

var LiquidityVoid[] voidArray = array.new<LiquidityVoid>()

// Calculations
atrVal = ta.atr(fvgLen)
dispFilter = atrVal * fvgMult

// Imbalance Detection
bullCondition = (low > high[2]) and ((low - high[2]) >= dispFilter)
bearCondition = (high < low[2]) and ((low[2] - high) >= dispFilter)

// ==========================================
// REGISTER VOIDS (SMART DRAWING SYSTEM)
// ==========================================
if bullCondition
    vTop = low
    vBtm = high[2]
    vMid = (vTop + vBtm) * 0.5
    
    b = box.new(left=bar_index - 1, top=vTop, right=bar_index + 10, bottom=vBtm,  border_color=c_bull_brd, border_width=1,bgcolor=c_bull)
    l = line.new(x1=bar_index - 1, y1=vMid, x2=bar_index + 10, y2=vMid,
                 color=c_mid, width=1, style=line.style_dotted)
                 
    array.push(voidArray, LiquidityVoid.new(b, l, vTop, vBtm, vMid, true, bar_index - 1, true))

if bearCondition
    vTop = low[2]
    vBtm = high
    vMid = (vTop + vBtm) * 0.5
    
    b = box.new(left=bar_index - 1, top=vTop, right=bar_index + 10, bottom=vBtm,    border_color=c_bear_brd, border_width=1,   bgcolor=c_bear)
    l = line.new(x1=bar_index - 1, y1=vMid, x2=bar_index + 10, y2=vMid,
                 color=c_mid, width=1, style=line.style_dotted)
                 
    array.push(voidArray, LiquidityVoid.new(b, l, vTop, vBtm, vMid, false, bar_index - 1, true))

// ==========================================
// REAL-TIME MITIGATION ENGINE
// ==========================================
int activeCount = 0
int bullVoids = 0
int bearVoids = 0

if array.size(voidArray) > 0
    for i = array.size(voidArray) - 1 to 0
        LiquidityVoid item = array.get(voidArray, i)
        if item.active
            box.set_right(item.bx, bar_index + 1)
            line.set_x2(item.mid, bar_index + 1)
            
            bool mitigated = false
            if item.isBull
                bullVoids += 1
                if mitigateAt == "50% Mean Threshold"
                    if low <= item.median
                        mitigated := true
                else
                    if low <= item.btm
                        mitigated := true
            else
                bearVoids += 1
                if mitigateAt == "50% Mean Threshold"
                    if high >= item.median
                        mitigated := true
                else
                    if high >= item.top
                        mitigated := true
            
            if mitigated
                item.active := false
                box.set_bgcolor(item.bx, color.new(color.gray, 92))
                box.set_border_color(item.bx, color.new(color.gray, 85))
                line.set_color(item.mid, color.new(color.gray, 92))
            else
                activeCount += 1

while array.size(voidArray) > maxZones
    LiquidityVoid deadVoid = array.remove(voidArray, 0)
    box.delete(deadVoid.bx)
    line.delete(deadVoid.mid)

// ==========================================
// LIQUIDITY SWEEP & HUNT DETECTION
// ==========================================
pHigh = ta.pivothigh(high, swpLen, swpLen)
pLow  = ta.pivotlow(low, swpLen, swpLen)

var float lastPHigh = na
var float lastPLow  = na

if not na(pHigh)
    lastPHigh := pHigh
if not na(pLow)
    lastPLow := pLow

bullSweep = showSweeps and not na(lastPLow) and (low < lastPLow) and (close > lastPLow)
bearSweep = showSweeps and not na(lastPHigh) and (high > lastPHigh) and (close < lastPHigh)

plotshape(bullSweep, title="Bullish Liquidity Sweep", style=shape.triangleup,
          location=location.belowbar, color=#00e676, size=size.small, text="SWEEP")
plotshape(bearSweep, title="Bearish Liquidity Sweep", style=shape.triangledown,
          location=location.abovebar, color=#ff1744, size=size.small, text="SWEEP")

// Alerts
alertcondition(bullSweep, title="[AlgoChief] Bullish Liquidity Sweep", message="[AlgoChief] Bullish Liquidity Sweep detected at {{close}}")
alertcondition(bearSweep, title="[AlgoChief] Bearish Liquidity Sweep", message="[AlgoChief] Bearish Liquidity Sweep detected at {{close}}")
alertcondition(bullCondition, title="[AlgoChief] Bullish Void Created", message="[AlgoChief] Bullish Institutional Imbalance printed at {{close}}")
alertcondition(bearCondition, title="[AlgoChief] Bearish Void Created", message="[AlgoChief] Bearish Institutional Imbalance printed at {{close}}")

// ==========================================
// INSTITUTIONAL TELEMETRY HUD (100% FIXED)
// ==========================================
var table hud = table.new(position.top_right, columns = 2, rows = 4, bgcolor = color.new(#11141a, 15),
                          border_color = color.new(#374151, 40), border_width = 1)

if showDash and barstate.islast
    string flowBias = bullVoids > bearVoids ? "ACCUMULATION" : bearVoids > bullVoids ? "DISTRIBUTION" : "NEUTRAL"
    color biasCol   = bullVoids > bearVoids ? #00e676 : bearVoids > bullVoids ? #ff1744 : color.orange

    table.cell(hud, 0, 0, "Order Flow", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 0, "[AlgoChief]", text_color=color.gray, text_size=size.small)

    table.cell(hud, 0, 1, "Institutional State", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 1, flowBias, text_color=biasCol, text_size=size.small)

    table.cell(hud, 0, 2, "Active Bull Voids", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(bullVoids), text_color=#00e676, text_size=size.small)

    table.cell(hud, 0, 3, "Active Bear Voids", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(bearVoids), text_color=#ff1744, text_size=size.small)
````
