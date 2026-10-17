# SMC Setup: Sweep + CHoCH + FVG v21.1

- url: https://www.tradingview.com/script/HIlQgly0-SMC-Setup-Sweep-CHoCH-FVG-v21-1/
- type: indicator
- pine_id: PUB;5f8d28e71e1c4517aab04cd4436ed51f
- version: 1.0

## Description

SMC Setup: Sweep + CHoCH + FVG v21.1 (Multi-Timeframe Execution Engine)
Introducing a complete, institutional-grade Smart Money Concepts (SMC) execution algorithm. This is not just a standard sweep indicator; it is a "3D" Top-Down Analysis Engine designed to flawlessly mimic how professional human traders track order flow across multiple timeframes, natively executing on your lower-timeframe charts.

Built to solve the common pitfalls of algorithmic SMC (such as repainting, MTF blindness, and zero-width visual crashes), this indicator tracks Major (External) and Minor (Internal) liquidity simultaneously and automates your entire entry and trade management visualization.

🔥 Core Features
Multi-Timeframe (MTF) "Time-Warp" Engine: Track 15-minute and 5-minute structural liquidity sweeps natively on the 1-minute execution chart. The script uses internal mathematical multipliers and a massive 5000-bar deep memory buffer to track HTF structure without relying on laggy or repainting request.security() calls.

Dual-Fractal Liquidity Tracking: * Solid Blue Lines: Tracks Major/External Higher Timeframe liquidity peaks.

Dotted Blue Lines: Tracks Minor/Internal Lower Timeframe pullbacks for aggressive continuation order flow.

Two Selectable Entry Models:

BOS Breakout: For aggressive momentum traders. Executes the exact millisecond the micro-structure BOS (Break of Structure/CHoCH) line is cracked.

FVG Pullback: For conservative traders. Waits for a Break of Structure, verifies a Fair Value Gap has formed, and sets a limit entry exactly at the FVG boundary.

Dynamic Visual Trade Management: The script automatically generates a physical Risk Zone Box (mimicking the native TradingView Short/Long Position tools) and projects dynamic, trailing lines for your Entry, Stop Loss, TP1, TP2, and Full Target based on customizable Risk:Reward settings.

Webhook-Ready Alerts: Generates highly detailed, once-per-bar-close alerts containing dynamic strings for Entry Price, Stop Loss, and all Take Profit targets, making it perfect for automated execution via 3Commas, PineConnector, etc.

⚙️ How It Works (The Logic Flow)
The Hunt: The algorithm maps higher timeframe peaks (e.g., 15m/5m) and local micro-peaks simultaneously.

The Sweep: When price sweeps a mapped liquidity line, the algorithm "arms" the setup and locks the Stop Loss to the highest point of the sweep.

The CHoCH/BOS: It tracks the immediate local pullback prior to the sweep. If price breaks this micro-structure support, the setup is confirmed.

The Execution: Depending on your selected model, it either triggers instantly on the BOS breakout or waits for a bearish FVG pullback.

The Management: Target lines trail alongside price action and automatically lock into place the moment the trade hits the Full Target or the Stop Loss.

💡 Best Practices
Optimal Use: Load this indicator on the 1-minute chart. Set the Major HTF Multiplier to 15 and the Minor HTF Multiplier to 5. This allows the script to see 15m and 5m market structure while leveraging the 1-minute candles for surgical entries.

Asset Classes: Highly effective on high-volume assets like Indices (NAS100, US30, SPX) and Forex (EURUSD, XAUUSD) during the London or New York sessions.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gemini

//@version=5
// V21.1 FIX: Cleaned syntax formatting to bypass invisible copy-paste characters!
indicator("SMC Setup: Sweep + CHoCH + FVG v21.1", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// --- Settings ---
grpModel = "Entry Model"
entryModel = input.string("BOS Breakout", title="Entry Trigger Strategy", options=["FVG Pullback", "BOS Breakout"], group=grpModel)

grpMTF = "Top-Down Analysis (Timeframes)"
htfMajor = input.int(15, title="Major HTF Multiplier (e.g. 15 for 15m)", group=grpMTF, tooltip="Multiplies the lookback to track Higher Timeframe structure on a 1m chart.")
htfMinor = input.int(5, title="Minor HTF Multiplier (e.g. 5 for 5m)", group=grpMTF)

grpMacro = "External Liquidity (Major Tops)"
macLeft = input.int(8, title="Major Peak Left Length", group=grpMacro)
macRight = input.int(2, title="Major Peak Right Length", group=grpMacro)

grpMicro = "Internal Liquidity (Minor Tops)"
trackInternal = input.bool(true, title="Track Internal Sweeps?", group=grpMicro)
micLeft = input.int(2, title="Minor Peak Left Length", group=grpMicro) 
micRight = input.int(1, title="Minor Peak Right Length", group=grpMicro)

grpBos = "Micro-Structure (BOS) Settings"
bosLeft = input.int(3, title="BOS Low Left Length", group=grpBos)
bosRight = input.int(1, title="BOS Low Right Length", group=grpBos)

showEntryBox = input.bool(true, title="Show Entry Box")
boxColor = input.color(color.new(color.red, 80), title="Box Color")

// --- Target Settings (R:R) ---
grpTargets = "Trade Targets (Risk:Reward)"
t1_rr = input.float(3.0, title="Target 1 (R:R)", step=0.5, group=grpTargets)
t2_rr = input.float(8.0, title="Target 2 (R:R)", step=0.5, group=grpTargets)
full_rr = input.float(15.0, title="Full Target (R:R)", step=0.5, group=grpTargets)

// --- 1. MTF Dual-Fractal Liquidity Tracking ---
ph_mac = ta.pivothigh(high, macLeft * htfMajor, macRight * htfMajor)
ph_mic = ta.pivothigh(high, micLeft * htfMinor, micRight * htfMinor)
pl_bos = ta.pivotlow(low, bosLeft, bosRight)

var float lastMac = na
var float lastMic = na
var float lastBos = na
var float sweptMac = na
var float sweptMic = na

if not na(ph_mac)
    lastMac := ph_mac

if trackInternal and not na(ph_mic)
    if na(lastMac) or ph_mic < lastMac
        lastMic := ph_mic

if not na(pl_bos)
    lastBos := pl_bos

var line macLine = na
var line micLine = na
var bool macActive = false
var bool micActive = false

if not na(ph_mac)
    macLine := line.new(bar_index[macRight * htfMajor], ph_mac, bar_index, ph_mac, color=color.new(color.blue, 30), style=line.style_solid, width=2)
    macActive := true
else if not na(macLine) and macActive
    line.set_x2(macLine, bar_index)

if trackInternal and not na(ph_mic) and (na(lastMac) or ph_mic < lastMac)
    micLine := line.new(bar_index[micRight * htfMinor], ph_mic, bar_index, ph_mic, color=color.new(color.blue, 60), style=line.style_dotted, width=1)
    micActive := true
else if not na(micLine) and micActive
    line.set_x2(micLine, bar_index)

// --- 2. The Sweep & State Tracking ---
isMacSweep = not na(lastMac) and ta.crossover(high, lastMac) and lastMac != sweptMac
isMicSweep = trackInternal and not na(lastMic) and ta.crossover(high, lastMic) and lastMic != sweptMic

isSweep = isMacSweep or isMicSweep

var bool setupArmed = false
var bool bosConfirmed = false
var bool fvgConfirmed = false

var float setupPeak = na
var int setupPeakBar = na 
var float chochLevel = na 

var float fvgTop = na
var float fvgBottom = na
var int fvgLeft = na

if isSweep
    if isMacSweep
        sweptMac := lastMac
        macActive := false
    if isMicSweep
        sweptMic := lastMic
        micActive := false
        
    setupArmed := true
    bosConfirmed := false
    fvgConfirmed := false
    setupPeak := high 
    setupPeakBar := bar_index 
    chochLevel := lastBos 
    
plotshape(isSweep ? high : na, title="Liquidity Sweep", text="SWEEP", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.small)

// --- 3. The Dual Hunt (BOS & FVG) ---
if setupArmed
    if high > setupPeak
        setupPeak := high
        setupPeakBar := bar_index 
        chochLevel := lastBos 
        bosConfirmed := false 
        fvgConfirmed := false

    if not bosConfirmed and ta.crossunder(close, chochLevel)
        bosConfirmed := true
        label.new(bar_index, low, "BOS", color=color.red, style=label.style_label_up, textcolor=color.white, size=size.small)
        
        if entryModel == "BOS Breakout"
            fvgTop := setupPeak       
            fvgBottom := chochLevel   
            fvgLeft := setupPeakBar   
            fvgConfirmed := true

    if entryModel == "FVG Pullback"
        isFvg = low[2] > high[0] and close[1] < open[1]
        if not fvgConfirmed and isFvg
            fvgTop := low[2]
            fvgBottom := high[0]
            fvgLeft := bar_index[2]
            fvgConfirmed := true

// --- 4. Execution & Alerts ---
var box entryBox = na
var float activeFvgBottom = na

// V21 FIX: Float State Memory Variables (Immune to Garbage Collection)
var float activeTradeSL = na
var float activeTradeTP = na

var line activeSlLine = na
var line activeEntryLine = na
var line activeT1Line = na
var line activeT2Line = na
var line activeFullLine = na

if setupArmed and bosConfirmed and fvgConfirmed
    setupArmed := false 
    entryPrice = fvgBottom
    slPrice = setupPeak
    risk = slPrice - entryPrice
    
    if risk > 0
        activeFvgBottom := entryPrice
        activeTradeSL := slPrice
        
        safeLeft = fvgLeft == bar_index ? bar_index - 1 : fvgLeft
        
        if showEntryBox
            entryBox := box.new(left=safeLeft, top=fvgTop, right=bar_index, bottom=fvgBottom, bgcolor=boxColor, border_color=color.new(color.red, 50), text=entryModel == "BOS Breakout" ? "Risk Zone" : "Entry FVG", text_color=color.new(color.red, 20), text_size=size.tiny)
        
        t1Price = entryPrice - (risk * t1_rr)
        t2Price = entryPrice - (risk * t2_rr)
        fullPrice = entryPrice - (risk * full_rr)
        
        activeTradeTP := fullPrice
        
        // V21.1 FIX: Removed redundant style=line.style_solid to bypass the invisible character bug!
        activeSlLine := line.new(bar_index, slPrice, bar_index, slPrice, color=color.red, width=1)
        activeEntryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=color.gray, width=1, style=line.style_dashed)
        activeT1Line := line.new(bar_index, t1Price, bar_index, t1Price, color=color.new(color.green, 30), width=1, style=line.style_dashed)
        activeT2Line := line.new(bar_index, t2Price, bar_index, t2Price, color=color.new(color.green, 30), width=1, style=line.style_dashed)
        activeFullLine := line.new(bar_index, fullPrice, bar_index, fullPrice, color=color.green, width=2)
        
        label.new(bar_index, slPrice, "SL", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.tiny)
        label.new(bar_index, entryPrice, entryModel == "BOS Breakout" ? "BOS Breakout" : "FVG Entry", color=color.gray, style=label.style_label_down, textcolor=color.white, size=size.tiny)
        label.new(bar_index, t1Price, "T1", color=color.green, style=label.style_label_up, textcolor=color.white, size=size.tiny)
        label.new(bar_index, fullPrice, "Full Target", color=color.green, style=label.style_label_up, textcolor=color.white, size=size.tiny)

        alertText = syminfo.ticker + " SMC SETUP ARMED!\nModel: " + entryModel + "\nEntry: " + str.tostring(entryPrice, "#.###") + "\nStop Loss: " + str.tostring(slPrice, "#.###") + "\nFull Target: " + str.tostring(fullPrice, "#.###")
        alert(alertText, alert.freq_once_per_bar_close)

// --- 5. Dynamic Extensions ---
if not na(activeTradeSL)
    if not na(activeSlLine)
        line.set_x2(activeSlLine, bar_index)
    if not na(activeEntryLine)
        line.set_x2(activeEntryLine, bar_index)
    if not na(activeT1Line)
        line.set_x2(activeT1Line, bar_index)
    if not na(activeT2Line)
        line.set_x2(activeT2Line, bar_index)
    if not na(activeFullLine)
        line.set_x2(activeFullLine, bar_index)
    
    if entryModel == "BOS Breakout" and not na(entryBox)
        box.set_right(entryBox, bar_index) 
    
    if low <= activeTradeTP or high >= activeTradeSL
        activeTradeSL := na 
        activeTradeTP := na
        if entryModel == "BOS Breakout"
            entryBox := na 

if entryModel == "FVG Pullback" and not na(entryBox)
    if high >= activeFvgBottom
        box.set_right(entryBox, bar_index)
        entryBox := na 
    else
        box.set_right(entryBox, bar_index)
````
