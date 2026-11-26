# Studio SMS: Volume-Confirmed Fair Value Gaps

- url: https://www.tradingview.com/script/kOKW3hAO-Studio-SMS-Volume-Confirmed-Fair-Value-Gaps/
- type: indicator
- pine_id: PUB;a3a015e2f2c24d3897a4e13730273827
- version: 2.0

## Description

[b]Studio SMS — Volume-Confirmed Fair Value Gaps (FVG)[/b]

This indicator detects Fair Value Gaps based on Smart Money Concepts (SMC) and enhances them using volume confirmation logic.

Key Features:
• Detects Bullish and Bearish Fair Value Gaps automatically
• Volume validation on FVG creation candle
• Highlights institutional displacement moves
• Filters weak / low-participation gaps
• Designed for scalping, intraday, and trend continuation trading

Volume Logic:
FVG zones formed with a volume spike indicate stronger institutional participation.
Low-volume gaps are intentionally filtered or visually downgraded to avoid weak setups.

Best Usage Guidelines:
• Always evaluate FVG zones together with nearby volume structure
• Strong reactions typically occur when FVG aligns with high-volume areas or liquidity zones
• Works best when combined with Market Structure (BOS / Trend Bias)
• Avoid trading isolated FVGs formed during low-volume consolidation

Important:
This tool is a decision-support indicator and should be used with proper risk management and drawdown control.
Suitable for discretionary trading as well as automation using TradingView webhook / Algo API integrations.

⚠️ Notes

This indicator provides structural guidance, not financial advice.
Always use proper risk management.

👨‍💻 Developer
Inder Singh
🌐 indersingh.com

## Source Code

````pine
//────────────────────────────────────────────────────────────
//  Studio Market Structure: Volume-Confirmed Fair Value Gaps
//  Developed by Inder Singh @ North Web Studio
//  Website: https://indersingh.com
//────────────────────────────────────────────────────────────
//@version=6
indicator("Studio SMS: Volume-Confirmed Fair Value Gaps 2.0", shorttitle="SFVG2.0", overlay = true, max_boxes_count = 500)

// --- Groups ---
string GRP1 = "FVG Settings"
string GRP2 = "Style"
string GRP3 = "Retest Settings"

// --- Inputs ---
bool  filterHL2Input = input.bool(false, "Filter: Prev Candle is High/Low of 2", group = GRP1)
bool  hideMitigated  = input.bool(false, "Hide Mitigated FVGs", group = GRP1)
int   maxBoxes       = input.int(50, "Max Recent Boxes", minval = 1, maxval = 500, group = GRP1)
int   durationInput  = input.int(20, "Box Duration (Bars)", minval = 1, group = GRP1)
float minGapFactor   = input.float(0.5, "Min Gap Factor (Ticks)", minval = 0.0, step = 0.5, group = GRP1)

color bullColorInput = input.color(color.new(#089981, 80), "Bullish FVG", group = GRP2)
color bearColorInput = input.color(color.new(#f23645, 80), "Bearish FVG", group = GRP2)
color bullBorder     = input.color(color.new(#089981, 50), "Bullish Border", group = GRP2)
color bearBorder     = input.color(color.new(#f23645, 50), "Bearish Border", group = GRP2)

// Retest Inputs
bool showRetest      = input.bool(true, "Show Retest Signals", group = GRP3)
color bullRetestCol  = input.color(color.new(#089981, 0), "Bull Retest Color", group = GRP3)
color bearRetestCol  = input.color(color.new(#f23645, 0), "Bear Retest Color", group = GRP3)

GRP_VOL = "Volume"
rangeLookback        = input.int(14,    "Volume Lookback (Bars)", minval=5, display=display.none, group = GRP_VOL)
VOL_MULT             = input.float(1.5,  "Volume Spike Mult", group=GRP_VOL, display=display.none)
USE_VOL_CHK          = input.bool(false, "Volume Spike check for FVGs", group = GRP_VOL)

// Volume check
FAST_MVA_VOL = ta.sma(volume, rangeLookback)
IS_VOLUME_LOW   = volume < FAST_MVA_VOL * 0.6
IS_VOLUME_SPIKE = volume > FAST_MVA_VOL * VOL_MULT

// --- Types & Storage ---
type FVG
    box   bx
    float top
    float bottom
    bool  isBull
    int   endBar
    bool  mitigated
    bool  retested // Tracking if this specific gap has been retested

var fvgArray = array.new<FVG>()

// --- Logic ---
float minGapThreshold = minGapFactor * syminfo.mintick
bool isBullFVG = (low[0] - high[2]) >= minGapThreshold
bool isBearFVG = (low[2] - high[0]) >= minGapThreshold

if filterHL2Input
    bool midIsLowest = low[2] <= low[3] and low[2] <= low[4]
    bool midIsHighest = high[2] >= high[3] and high[2] >= high[4]
    isBullFVG := isBullFVG and midIsLowest and IS_VOLUME_SPIKE
    isBearFVG := isBearFVG and midIsHighest and IS_VOLUME_SPIKE

isBullFVG := isBullFVG and not IS_VOLUME_LOW
isBearFVG := isBearFVG and not IS_VOLUME_LOW

if USE_VOL_CHK
    isBullFVG := isBullFVG and IS_VOLUME_SPIKE
    isBearFVG := isBearFVG and IS_VOLUME_SPIKE

// --- Execution ---
int boxEndIndex = bar_index + durationInput

if isBullFVG
    float top    = low[0]
    float bottom = high[2]
    box bx = box.new(bar_index[2], top, boxEndIndex, bottom, border_color = bullBorder, bgcolor = bullColorInput)
    array.push(fvgArray, FVG.new(bx, top, bottom, true, boxEndIndex, false, false))

if isBearFVG
    float top    = low[2]
    float bottom = high[0]
    box bx = box.new(bar_index[2], top, boxEndIndex, bottom, border_color = bearBorder, bgcolor = bearColorInput)
    array.push(fvgArray, FVG.new(bx, top, bottom, false, boxEndIndex, false, false))


// --- Retest Detection ---
bool bullRetestSignal = false
bool bearRetestSignal = false

if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        FVG item = array.get(fvgArray, i)
        
        if not item.mitigated
            // Check for Bullish Retest
            if item.isBull and not isBullFVG
                if low <= item.top and low >= item.bottom and not item.retested
                    bullRetestSignal := true
                    item.retested := true
            else if not isBearFVG// This handles Bearish
                if high >= item.bottom and high <= item.top and not item.retested
                    bearRetestSignal := true
                    item.retested := true

            // Mitigation Logic
            bool mit = item.isBull ? low < item.bottom : high > item.top
            if mit
                item.mitigated := true
                box.set_right(item.bx, bar_index)
                if hideMitigated
                    box.delete(item.bx)

// --- Visual Refinement (Custom Symbols) ---
// --- High-Visibility Retest Labels ---
if bullRetestSignal
    label.new(bar_index, low, "🎯 ", 
         color=#ffffff00, 
         textcolor=bullRetestCol, 
         style=label.style_label_up, 
         size=size.normal)

if bearRetestSignal
    label.new(bar_index, high, "⚡ ", 
         color=#ffffff00, 
         textcolor= bearRetestCol, 
         style=label.style_label_down, 
         size=size.normal)

// Keep the background highlight for extra visibility
bgcolor(bullRetestSignal ? color.new(#089981, 85) : na)
bgcolor(bearRetestSignal ? color.new(#f23645, 85) : na)
````
