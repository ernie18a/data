# OB + Supply & Demand (SMC)

- url: https://www.tradingview.com/script/acAISqIK-OB-Supply-Demand-SMC/
- type: indicator
- pine_id: PUB;1c65874c1a074148bb3bf848d0340a24
- version: 1.0

## Description

OVERVIEW
This indicator marks Order Blocks (OB) and Supply/Demand zones, but only after price confirms them with a Break of Structure (BOS). A zone is drawn only when a candle BODY closes beyond the most recent swing high/low. Wicks do not count.

HOW ZONES ARE DEFINED
- Bullish OB: a bearish candle that sweeps the previous candle's low, is followed by a bullish Fair Value Gap (FVG) with the next candle, and sits in the discount half of the range.
- Bearish OB: the mirror. A bullish candle that sweeps the previous candle's high, with a bearish FVG, in the premium half.
- Demand: a bearish candle between two bullish candles, creating a bullish FVG, in discount.
- Supply: a bullish candle between two bearish candles, creating a bearish FVG, in premium.

Premium/Discount: highest high and lowest low over a lookback (default 50 bars). The equilibrium is set by the Fib level (default 0.5).

HOW THE BOS CONFIRMATION WORKS
When a candidate forms, the script stores the latest swing high (bullish zones) or swing low (bearish zones). The zone is drawn only when a candle closes beyond that level. The box starts at the original zone candle and a dashed BOS line marks the broken swing. If price closes through the zone first, or no break comes within the "Max Bars To Wait" setting, the candidate is discarded.

WHY IT IS DIFFERENT
It combines liquidity sweep, FVG, premium/discount and a body-close BOS filter in one process. This removes many unconfirmed zones that simpler OB indicators show.

HOW TO USE
- Zones extend to the right until mitigated (price closes through them; wick option available). Mitigated zones turn grey or can be deleted.
- Use Swing Length to control which swings count as structure. Smaller values give more internal-structure signals, larger values give fewer major ones.
- Alerts fire when a zone is confirmed by BOS.

LIMITATIONS
- Zones are drawn on the bar where the BOS confirms, but their boxes start at the earlier zone candle. On history they look as if they were visible earlier than they would have been in real time.
- Swing points need "Swing Length" bars on the right to confirm, so structure is always slightly delayed.
- In strong trends or low volatility, few zones may pass all the filters. Settings suit different timeframes and markets and need adjusting.
- This is a charting tool, not a strategy. It makes no claim about profitability and is not financial advice.

INPUTS
Show toggles, zone range (full candle or body), premium/discount filter and lookback, mitigation type, swing length, max wait bars, colors, labels.

## Source Code

````pine
//@version=6
indicator("TheBitcoin537 | OB + Supply & Demand (SMC)", shorttitle="TB537 OB/S&D", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
grpShow = "Show Zones"
showBullOB = input.bool(true, "Bullish Order Block", group=grpShow)
showBearOB = input.bool(true, "Bearish Order Block", group=grpShow)
showDemand = input.bool(true, "Demand Zone",         group=grpShow)
showSupply = input.bool(true, "Supply Zone",         group=grpShow)

grpLogic = "Logic"
zoneSrc  = input.string("Full Candle", "Zone Range", options=["Full Candle", "Body Only"], group=grpLogic)
usePD    = input.bool(true, "Premium / Discount Filter", group=grpLogic)
rangeLen = input.int(50, "Fib Range Lookback", minval=5, group=grpLogic)
fibLevel = input.float(0.5, "Equilibrium Fib Level", minval=0.1, maxval=0.9, step=0.05, group=grpLogic, tooltip="0.5 = equilibrium. Below = Discount, above = Premium.")
mitMode  = input.string("Close", "Mitigation Type", options=["Close", "Wick"], group=grpLogic)
hideMit  = input.bool(false, "Delete Mitigated Zones", group=grpLogic)
maxZones = input.int(30, "Max Zones On Chart", minval=4, maxval=200, group=grpLogic)

grpBOS   = "Structure Break (BOS)"
swingLen = input.int(5, "Swing Length", minval=1, group=grpBOS, tooltip="Bars on each side needed to confirm a swing high / low.")
maxWait  = input.int(50, "Max Bars To Wait For Break", minval=1, group=grpBOS, tooltip="Zone is discarded if no candle body closes beyond the swing within this many bars.")
showBOS  = input.bool(true, "Show BOS Line", group=grpBOS)

grpVis   = "Style"
cBullOB  = input.color(#00c85333, "Bullish OB",     group=grpVis)
cBearOB  = input.color(#ff174433, "Bearish OB",     group=grpVis)
cDemand  = input.color(#2979ff33, "Demand",         group=grpVis)
cSupply  = input.color(#ff910033, "Supply",         group=grpVis)
cMit     = input.color(#9e9e9e1f, "Mitigated Zone", group=grpVis)
cBosBull = input.color(#00c853,   "Bullish BOS",    group=grpVis)
cBosBear = input.color(#ff1744,   "Bearish BOS",    group=grpVis)
showText = input.bool(true,  "Show Zone Labels",           group=grpVis)
showEq   = input.bool(false, "Show Range High / Low / EQ", group=grpVis)

// ============================================================
// PREMIUM / DISCOUNT RANGE
// ============================================================
rHigh = ta.highest(high, rangeLen)
rLow  = ta.lowest(low, rangeLen)
eqLvl = rLow + (rHigh - rLow) * fibLevel

plot(showEq ? rHigh : na, "Range High",  color=color.new(color.red, 50))
plot(showEq ? rLow  : na, "Range Low",   color=color.new(color.green, 50))
plot(showEq ? eqLvl : na, "Equilibrium", color=color.new(color.gray, 30), style=plot.style_circles)

// ============================================================
// SWING HIGH / LOW TRACKING
// ============================================================
var float lastSH    = na
var int   lastSHbar = na
var float lastSL    = na
var int   lastSLbar = na

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
if not na(ph)
    lastSH    := ph
    lastSHbar := bar_index - swingLen
if not na(pl)
    lastSL    := pl
    lastSLbar := bar_index - swingLen

// ============================================================
// OBJECTS
// kind: 1 = Bull OB, 2 = Bear OB, 3 = Demand, 4 = Supply
// ============================================================
type Zone
    box   bx
    int   kind
    float top
    float bot
    bool  mitigated = false

type Pending
    int   kind
    int   left
    float top
    float bot
    float level
    int   levelBar
    int   born

var array<Zone>    zones = array.new<Zone>()
var array<Pending> pend  = array.new<Pending>()

// ============================================================
// MITIGATION HANDLING (active zones)
// ============================================================
if barstate.isconfirmed
    int i = array.size(zones) - 1
    while i >= 0
        Zone z = array.get(zones, i)
        if not z.mitigated
            bool  isBullZone = z.kind == 1 or z.kind == 3
            float px  = isBullZone ? (mitMode == "Close" ? close : low) : (mitMode == "Close" ? close : high)
            bool  hit = isBullZone ? px < z.bot : px > z.top
            if hit
                if hideMit
                    box.delete(z.bx)
                    array.remove(zones, i)
                else
                    z.mitigated := true
                    box.set_extend(z.bx, extend.none)
                    box.set_right(z.bx, bar_index)
                    box.set_bgcolor(z.bx, cMit)
                    box.set_border_color(z.bx, color.new(color.gray, 70))
        i -= 1

// ============================================================
// DEFINITIONS
// candle[2] = zone candle
// candle[1] = very next candle (displacement)
// candle[0] = candle that completes the FVG
// candle[3] = candle before the zone candle
// ============================================================
bullFVG = low  > high[2]     // gap between zone candle high and candle[0] low
bearFVG = high < low[2]      // gap between zone candle low and candle[0] high

c3Bull = close[3] > open[3]
c3Bear = close[3] < open[3]
c2Bull = close[2] > open[2]
c2Bear = close[2] < open[2]
c1Bull = close[1] > open[1]
c1Bear = close[1] < open[1]

float zTopV  = zoneSrc == "Full Candle" ? high[2] : math.max(open[2], close[2])
float zBotV  = zoneSrc == "Full Candle" ? low[2]  : math.min(open[2], close[2])
float zMid   = (zTopV + zBotV) / 2
float eqZone = eqLvl[2]

bool inDisc = not usePD or zMid < eqZone
bool inPrem = not usePD or zMid > eqZone

// Bullish OB: selling candle, swept previous candle low, bullish FVG with next candle, discount
bool bullOBc = c2Bear and low[2] < low[3] and bullFVG and inDisc
// Bearish OB: buying candle, swept previous candle high, bearish FVG with next candle, premium
bool bearOBc = c2Bull and high[2] > high[3] and bearFVG and inPrem
// Demand: selling candle between two buying candles, bullish FVG, discount
bool demandC = c3Bull and c2Bear and c1Bull and bullFVG and inDisc
// Supply: buying candle between two selling candles, bearish FVG, premium
bool supplyC = c3Bear and c2Bull and c1Bear and bearFVG and inPrem

bool hasSH = not na(lastSH) and lastSH > zTopV
bool hasSL = not na(lastSL) and lastSL < zBotV

// ============================================================
// REGISTER CANDIDATES AS PENDING (waiting for BOS)
// ============================================================
if barstate.isconfirmed
    if showBullOB and bullOBc and hasSH
        array.push(pend, Pending.new(1, bar_index - 2, zTopV, zBotV, lastSH, lastSHbar, bar_index))
    if showBearOB and bearOBc and hasSL
        array.push(pend, Pending.new(2, bar_index - 2, zTopV, zBotV, lastSL, lastSLbar, bar_index))
    if showDemand and demandC and hasSH
        array.push(pend, Pending.new(3, bar_index - 2, zTopV, zBotV, lastSH, lastSHbar, bar_index))
    if showSupply and supplyC and hasSL
        array.push(pend, Pending.new(4, bar_index - 2, zTopV, zBotV, lastSL, lastSLbar, bar_index))

// ============================================================
// CONFIRM PENDING ZONES ON BODY-CLOSE BREAK
// ============================================================
bool newBullOB = false
bool newBearOB = false
bool newDemand = false
bool newSupply = false

if barstate.isconfirmed
    int j = array.size(pend) - 1
    while j >= 0
        Pending p = array.get(pend, j)
        bool isBull = p.kind == 1 or p.kind == 3
        bool broke  = isBull ? close > p.level : close < p.level
        bool dead   = (isBull ? close < p.bot : close > p.top) or (bar_index - p.born > maxWait)
        if broke
            color  col = p.kind == 1 ? cBullOB : p.kind == 2 ? cBearOB : p.kind == 3 ? cDemand : cSupply
            string txt = p.kind == 1 ? "Bull OB" : p.kind == 2 ? "Bear OB" : p.kind == 3 ? "Demand" : "Supply"
            box bx = box.new(left=p.left, top=p.top, right=bar_index, bottom=p.bot,
                 border_color=color.new(col, 30), border_width=1, extend=extend.right, bgcolor=col,
                 text=showText ? txt : "", text_size=size.tiny, text_color=color.white,
                 text_halign=text.align_right, text_valign=text.align_center)
            array.push(zones, Zone.new(bx, p.kind, p.top, p.bot))
            if showBOS
                color bc = isBull ? cBosBull : cBosBear
                line.new(p.levelBar, p.level, bar_index, p.level, color=bc, style=line.style_dashed, width=1)
                label.new(bar_index, p.level, "BOS", style=label.style_none, textcolor=bc, size=size.tiny)
            if p.kind == 1
                newBullOB := true
            else if p.kind == 2
                newBearOB := true
            else if p.kind == 3
                newDemand := true
            else
                newSupply := true
            array.remove(pend, j)
        else if dead
            array.remove(pend, j)
        j -= 1

while array.size(zones) > maxZones
    Zone old = array.shift(zones)
    box.delete(old.bx)

while array.size(pend) > 200
    array.shift(pend)

// ============================================================
// ALERTS (fire when zone is confirmed by BOS)
// ============================================================
alertcondition(newBullOB, "Bullish OB Confirmed",  "Bullish Order Block + BOS on {{ticker}} {{interval}}")
alertcondition(newBearOB, "Bearish OB Confirmed",  "Bearish Order Block + BOS on {{ticker}} {{interval}}")
alertcondition(newDemand, "Demand Zone Confirmed", "Demand Zone + BOS on {{ticker}} {{interval}}")
alertcondition(newSupply, "Supply Zone Confirmed", "Supply Zone + BOS on {{ticker}} {{interval}}")
````
