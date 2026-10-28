# Pro Swing Analysis and Mitigation Zones

- url: https://www.tradingview.com/script/8kyKSAgR-Pro-Swing-Analysis-and-Mitigation-Zones/
- type: indicator
- pine_id: PUB;a8721e9f23ad4f7ebbae036c17451ed1
- version: 3.0

## Description

Pro Swing Analysis and Mitigation Zones
Introduction
The Pro Swing Analysis and Mitigation Zones is a technical analysis indicator designed to identify high-probability structural shifts and supply/demand levels. It is built for traders who focus on market structure and volume climaxes on higher timeframes such as Daily, Weekly, and Monthly charts.

Originality and Usefulness
This script is original in its approach to "Self-Mitigating Zones." While many indicators plot supply and demand zones, this script manages them dynamically using an internal array system. A zone is only kept on the chart as long as it remains "fresh"—as soon as price action closes through a zone (mitigating the structural level), the script automatically deletes it. This ensures the trader is always focused on active, unmitigated levels of interest.

Additionally, it features an automated Trendline Break logic. It constructs a dotted structural trendline based on the most recent two pivots of the same trend and monitors for price violations in real-time, providing early exit signals before a new structural high or low is even confirmed.

Underlying Logic
The indicator functions through three core layers of confirmation:

Fast Pivot Detection: It identifies local highs and lows confirmed by a 1-candle lookback for high responsiveness.
Volume Climax Confirmation: Every structural point is verified against a volume multiplier. A pivot is only considered a "Signal" if the volume on that bar significantly exceeds the recent average (10-period SMA).
Trend State Machine: The script tracks whether the market is currently in a Bullish or Bearish state to differentiate between new entries, re-entries, and structural exits.
Key Features
Multi-Timeframe Identity: Automatically applies colors based on the chart interval: Blue for Daily, Orange for Weekly, and Pink for Monthly.
Mitigation Zones: Supply and Demand zones that project into the future and self-delete upon price crossover.
Dynamic Dotted Trendlines: Automatically connects the last two structural points of the current trend to visualize momentum.
Bias Dashboard: A clean UI element in the corner of the chart summarizing the current trend bias and the number of active unmitigated zones.
How to Use
Entries: Look for the ENTER LONG/SHORT labels which appear on high-volume structural reversals.
Re-entries: Use the RE-ENTRY labels to scale into a trend during confirmed pullbacks.
Exits: Use the TL BREAK signal for early exits when price momentum fails, or wait for a full structural EXIT signal at a new opposing pivot.
Disclaimer
Trading involves a significant risk of loss. This indicator is for informational and educational purposes only and does not constitute financial advice. Past performance is not a guarantee of future results. Always use proper risk management and stop-loss orders.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant Expert
//@version=6
indicator("Pro Swing Analysis and Mitigation Zones", shorttitle="PSA Zones", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// --- Groups ---
group_set = "Detection Sensitivity"
group_ema = "Trend Filter (Hidden)"
group_vis = "Visual Style"
group_sur = "Resilient Mitigation Zones"

// --- User-Defined Types ---
type ZoneInfo
    box   boxId
    bool  isSupply
    float top
    float bot
    bool  active

// --- Inputs ---
swingLen      = input.int(3, "Swing Lookback", minval=1, group=group_set, tooltip="Lowered to 3 for better responsiveness. Number of bars on each side to confirm a pivot.")
volMult       = input.float(1.3, "Volume Multiplier", minval=0.5, step=0.1, group=group_set, tooltip="Lowered to 1.3 for more signals. Volume must exceed this multiplier of average.")
rangeMult     = input.float(1.1, "Volatility Multiplier", minval=0.5, step=0.1, group=group_set, tooltip="Lowered to 1.1. The candle's range must be above average.")

useEmaFilter  = input.bool(true, "Use EMA Trend Filter", group=group_ema, tooltip="If price is below EMA, Buy signals are filtered. If above, Sell signals are filtered.")
emaLength     = input.int(50, "EMA Filter Length", minval=1, group=group_ema, tooltip="Lowered to 50 for more flexibility. Standard filters are 50, 100, 200.")

tlWeight      = input.int(1, "Trendline Width", minval=1, maxval=10, group=group_vis)
labelStyleInput = input.string("Modern Bubble", "Signal Label Look", options=["Modern Bubble", "Floating Text"], group=group_vis)

// Ghost Zone Inputs
showZones     = input.bool(true, "Show Mitigation Zones", group=group_sur)
activeTransp  = input.int(85, "Active Zone Transparency", minval=0, maxval=100, group=group_sur)
ghostColor    = input.color(color.gray, "Ghost Line Color", group=group_sur)
ghostTransp   = input.int(30, "Ghost Line Brightness", minval=0, maxval=100, group=group_sur)
useGhostExits = input.bool(true, "Ghost Lines as Reversal Points", group=group_sur)
maxZones      = input.int(40, "Max Active/Ghost Zones", minval=10, maxval=100, group=group_sur)

// --- Constants & Colors ---
C_DAILY   = #5b9cf6
C_WEEKLY  = #ff9800
C_MONTHLY = #e91e63
C_BULL    = #089981
C_BEAR    = #f23645
C_TRANS   = #00000000

// --- Timeframe Detection ---
isDaily   = timeframe.isdaily and not timeframe.isweekly and not timeframe.ismonthly
isWeekly  = timeframe.isweekly and not timeframe.ismonthly
isMonthly = timeframe.ismonthly
isSupported = isDaily or isWeekly or isMonthly
tfColor   = isDaily ? C_DAILY : isWeekly ? C_WEEKLY : C_MONTHLY

// --- Helper Functions for Labels ---
f_createLabel(int x, float y, string txt, color clr, bool isUp) =>
    bool isModern = labelStyleInput == "Modern Bubble"
    label.new(x, y, txt, 
         color = isModern ? clr : C_TRANS, 
         textcolor = isModern ? chart.bg_color : clr, 
         style = isUp ? label.style_label_up : label.style_label_down, 
         size = size.tiny)

// --- Core Logic ---
vSMA  = ta.sma(volume, 20)
rSMA  = ta.sma(high - low, 20)
emaVal = ta.ema(close, emaLength)

fSH = ta.pivothigh(high, swingLen, 2)
fSL = ta.pivotlow(low, swingLen, 2)

vConf = volume[2] > vSMA[2] * volMult
rConf = (high[2] - low[2]) > rSMA[2] * rangeMult
climaxConfirmed = vConf and rConf

emaFilterLong  = not useEmaFilter or close[2] > emaVal[2]
emaFilterShort = not useEmaFilter or close[2] < emaVal[2]

// --- State and Persistent Variables ---
var int trendDir = 0 
var line trendline = na
var int l1x = na, var float l1y = na, var int l2x = na, var float l2y = na
var int h1x = na, var float h1y = na, var int h2x = na, var float h2y = na
var ZoneInfo[] zoneArray = array.new<ZoneInfo>()

atr = ta.atr(14)

// --- Trendline Break Logic ---
if not na(trendline) and isSupported
    float tlPrice = line.get_price(trendline, bar_index)
    if (trendDir == 1 and close < tlPrice)
        f_createLabel(bar_index, high + atr*0.3, "✖ EXIT", #f23645, false)
        line.delete(trendline), trendline := na, trendDir := 0
    else if (trendDir == -1 and close > tlPrice)
        f_createLabel(bar_index, low - atr*0.3, "✖ EXIT", #089981, true)
        line.delete(trendline), trendline := na, trendDir := 0

// --- Resilient Mitigation Zones Logic ---
if showZones and array.size(zoneArray) > 0
    for i = array.size(zoneArray) - 1 to 0
        z = array.get(zoneArray, i)
        if z.active
            if (z.isSupply and high > z.top) or (not z.isSupply and low < z.bot)
                z.active := false
                box.set_bgcolor(z.boxId, color.new(ghostColor, 100))
                box.set_border_color(z.boxId, color.new(ghostColor, 100 - ghostTransp))
        else
            if (z.isSupply and close < z.top) or (not z.isSupply and close > z.bot)
                z.active := true
                box.set_bgcolor(z.boxId, color.new(tfColor, activeTransp))
                box.set_border_color(z.boxId, color.new(tfColor, 70))
            
            if useGhostExits and not z.active and trendDir != 0
                bool hitSupplyGhost = trendDir == 1 and z.isSupply and high >= z.bot and low <= z.top
                bool hitDemandGhost = trendDir == -1 and not z.isSupply and low <= z.top and high >= z.bot
                if (hitSupplyGhost or hitDemandGhost)
                    f_createLabel(bar_index, hitSupplyGhost ? high + atr*0.3 : low - atr*0.3, "⚐ EXIT", ghostColor, hitDemandGhost)
                    trendDir := 0
                    if not na(trendline)
                        line.delete(trendline), trendline := na

// --- Signal Processing ---
bool bullishReversal = false, bool bearishReversal = false

if isSupported
    // Fix: Better handling for initial state trendDir == 0
    if not na(fSL) and climaxConfirmed and emaFilterLong
        bullishReversal := true
        string lblText = trendDir <= 0 ? "▲ BUY" : "▲ RE-ENTRY"
        f_createLabel(bar_index[2], fSL - atr * 0.4, lblText, tfColor, true)
        l2x := l1x, l2y := l1y, l1x := bar_index[2], l1y := fSL
        if trendDir != 1
            line.delete(trendline), trendline := na, h1x := na, h1y := na, h2x := na, h2y := na
        trendDir := 1
        if not na(l2x)
            line.delete(trendline), trendline := line.new(l2x, l2y, l1x, l1y, color=tfColor, width=tlWeight, style=line.style_dotted, extend=extend.right)
        if showZones
            float zTop = fSL + atr * 0.1, float zBot = fSL - atr * 0.1
            box b = box.new(bar_index[2], zTop, bar_index, zBot, bgcolor=color.new(tfColor, activeTransp), border_color=color.new(tfColor, 70), extend=extend.right)
            array.push(zoneArray, ZoneInfo.new(b, false, zTop, zBot, true))

    if not na(fSH) and climaxConfirmed and emaFilterShort
        bearishReversal := true
        string lblText = trendDir >= 0 ? "▼ SELL" : "▼ RE-ENTRY"
        f_createLabel(bar_index[2], fSH + atr * 0.4, lblText, tfColor, false)
        h2x := h1x, h2y := h1y, h1x := bar_index[2], h1y := fSH
        if trendDir != -1
            line.delete(trendline), trendline := na, l1x := na, l1y := na, l2x := na, l2y := na
        trendDir := -1
        if not na(h2x)
            line.delete(trendline), trendline := line.new(h2x, h2y, h1x, h1y, color=tfColor, width=tlWeight, style=line.style_dotted, extend=extend.right)
        if showZones
            float zTop = fSH + atr * 0.1, float zBot = fSH - atr * 0.1
            box b = box.new(bar_index[2], zTop, bar_index, zBot, bgcolor=color.new(tfColor, activeTransp), border_color=color.new(tfColor, 70), extend=extend.right)
            array.push(zoneArray, ZoneInfo.new(b, true, zTop, zBot, true))

// --- Dashboard ---
var table biasTable = table.new(position.top_right, 2, 3, border_width=1, frame_color=chart.fg_color, border_color=chart.fg_color)
if barstate.islast
    int activeCount = 0
    for z in zoneArray
        if z.active
            activeCount += 1
    
    table.cell(biasTable, 0, 0, "Trend Bias", bgcolor=chart.fg_color, text_color=chart.bg_color, text_size=size.small)
    table.cell(biasTable, 1, 0, trendDir == 1 ? "LONG" : trendDir == -1 ? "SHORT" : "EXITED", bgcolor=color.new(trendDir == 1 ? C_BULL : trendDir == -1 ? C_BEAR : chart.fg_color, 20), text_color=trendDir == 1 ? C_BULL : trendDir == -1 ? C_BEAR : chart.fg_color)
    
    table.cell(biasTable, 0, 1, "EMA Filter", bgcolor=chart.fg_color, text_color=chart.bg_color, text_size=size.small)
    table.cell(biasTable, 1, 1, not useEmaFilter ? "OFF" : close > emaVal ? "BULLISH" : "BEARISH", bgcolor=not useEmaFilter ? chart.fg_color : (close > emaVal ? C_BULL : C_BEAR), text_color=chart.bg_color)

    table.cell(biasTable, 0, 2, "Chart TF", bgcolor=chart.fg_color, text_color=chart.bg_color, text_size=size.small)
    table.cell(biasTable, 1, 2, isSupported ? (isDaily ? "DAILY" : isWeekly ? "WEEKLY" : "MONTHLY") : "UNSUPPORTED", bgcolor=isSupported ? tfColor : C_BEAR, text_color=chart.bg_color)
````
