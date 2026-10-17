# Flops - Orderblocks

- url: https://www.tradingview.com/script/6fTU5TgI-Flops-Orderblocks/
- type: indicator
- pine_id: PUB;ae540b3ba67444c98558ef45438fffd9
- version: 1.0

## Description

Description

The Advanced Flops - Orderblock indicator is a sophisticated, algorithmic supply and demand tracking system. It dynamically identifies trend-following institutional structures by detecting "Flops" (often known as Orderblocks) in real-time, visualizing exact areas where momentum aggressively shifted.

Instead of relying on a rigid, single-candle definition, this engine operates on a multi-timeframe perspective natively. It simultaneously evaluates 1-Candle, 2-Candle, and 3-Candle breakout logic on every single bar to validate structural breaks and paint flawless institutional supply/demand zones on your chart.

🎯 How It Works: The 1, 2, 3 Logic
The engine evaluates the market looking for a sequence of momentum candles that break structure against the previous opposing candle. By running the 1, 2, and 3-candle logic simultaneously, the script guarantees it catches both immediate V-shape reversals (1-candle) and slower, grinding structural breaks (3-candle) without drawing overlapping or duplicated zones.

Bullish ( Flops - Orderblock ): Formed when the price forcefully breaks the high of the last bearish candle. This indicates newly created demand.
Bearish ( Flops - Orderblock ): Formed when the price forcefully breaks the low of the last bullish candle. This indicates newly created supply.

✨ Key Features
Simultaneous Multi-Candle Logic: Runs three independent sequence checkers at the exact same time to ensure no valid Orderblock is ever missed.
Dynamic Mitigation Engine: Active zones project forward indefinitely into future price action until they are touched or closed through (customizable).
Single Mitigated Memory: A sleek visual feature that automatically deletes old, invalidated zones. It keeps only the absolute last mitigated zone on your chart to show you the most recent point of failure, without cluttering your screen with historical noise.
Trend Deactivation: The script understands market structure. If the dominant trend fully flips (e.g., from Bullish to Bearish based on a 3-candle sequence), all opposing active ( Flops - Orderblock ) zones are immediately deactivated and labeled as "Trend Flip", preventing you from taking trades against a confirmed structural shift.
Boundary Customization: Choose exactly how you want your Orderblock zones measured—either wick-to-wick (High/Low) or body-to-body (Open/Close).

⚙️ Settings
Flop Boundary: Define zones using full Wicks or strictly Candle Bodies.
Mitigation Mode: Choose whether a zone is invalidated the moment a wick "Touches" it, or only when a candle "Closes" fully through the zone.
Show Only Last Mitigated Flop: Keep your charts clean by automatically erasing old mitigated lines and only leaving the single most recent mitigated Orderblock on the chart.
Deactivate on Trend Flip: Automatically invalidate all active supply zones if the macro trend shifts bullish (and vice versa).
Full Visual Control: Customize colors, line widths, line styles (solid, dashed, dotted), and label visibility to fit your exact chart aesthetic.

## Source Code

````pine
//@version=6
indicator("Flops - Orderblocks", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
grp_general = "General Settings"
enableFlops       = input.bool(true, "Enable Flops", group=grp_general)
flopBoundary      = input.string("Wicks (High/Low)", "Flop Boundary", options=["Wicks (High/Low)", "Bodies (Open/Close)"], group=grp_general)
mitigateMode      = input.string("Touch", "Mitigation Mode", options=["Touch", "Close"], group=grp_general)

grp_display = "Display & Visuals"
showMitigated     = input.bool(false, "Show Only Last Mitigated Flop", group=grp_display)
deactivateOnTrend = input.bool(true, "Deactivate Flops on Trend Flip", group=grp_display)
showFlopLabels    = input.bool(true, "Show Flop Labels", group=grp_display)

i_fBullCol        = input.color(color.new(#4CAF50, 0), "Bullish Flop Color", group=grp_display)
i_fBearCol        = input.color(color.new(#F44336, 0), "Bearish Flop Color", group=grp_display)
flopLineWidth     = input.int(1, "Flop Line Width", minval=1, maxval=4, group=grp_display)
i_fLineStyle      = input.string("Solid", "Flop Line Style", options=["Solid", "Dotted", "Dashed"], group=grp_display)

// Helper: Convert line style string to Pine built-in string
_getLineStyle(s) =>
    switch s
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_solid


// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//              ENGINE — FLOPS
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

// --- STEP 1: Flop Trend Calculation ---
bool isBullSeq1 = (close[0] > open[0])
bool isBearSeq1 = (close[0] < open[0])
bool isBullSeq2 = isBullSeq1 and (close[1] > open[1])
bool isBearSeq2 = isBearSeq1 and (close[1] < open[1])
bool isBullSeq3 = isBullSeq2 and (close[2] > open[2])
bool isBearSeq3 = isBearSeq2 and (close[2] < open[2])

var int flopTrend = 0
// Trend flips based on a 3-candle sequence confirmation
if isBullSeq3
    flopTrend := 1
else if isBearSeq3
    flopTrend := -1

bool flopTrendChanged = ta.change(flopTrend) != 0

// --- STEP 2: Flop Data Type & Storage ---
type Flop
    float price_top
    float price_bottom
    int   start_bar
    bool  is_bullish
    line  ln_top
    line  ln_bottom
    label lbl
    bool  active

var array<Flop> activeFlops = array.new<Flop>()
var array<Flop> allFlops    = array.new<Flop>()
var array<Flop> lastMitigatedFlops = array.new<Flop>()

// --- STEP 3: Flop Mitigation ---
if enableFlops and array.size(activeFlops) > 0
    // Loop backwards so we can safely remove items from the array
    for i = array.size(activeFlops) - 1 to 0
        Flop f = array.get(activeFlops, i)
        bool isMitigated = false
        if f.is_bullish
            isMitigated := (mitigateMode == "Touch" ? low <= f.price_top : close <= f.price_top)
        else
            isMitigated := (mitigateMode == "Touch" ? high >= f.price_bottom : close >= f.price_bottom)
            
        if isMitigated
            f.active := false
            line.set_x2(f.ln_top, bar_index)
            line.set_x2(f.ln_bottom, bar_index)
            
            if not na(f.lbl)
                label.set_x(f.lbl, bar_index)
                label.set_text(f.lbl, "FLOP (Mitigated)")
                
            if showMitigated
                if array.size(lastMitigatedFlops) > 0
                    Flop oldF = array.shift(lastMitigatedFlops)
                    line.delete(oldF.ln_top)
                    line.delete(oldF.ln_bottom)
                    if not na(oldF.lbl)
                        label.delete(oldF.lbl)
                array.push(lastMitigatedFlops, f)
            else
                line.delete(f.ln_top)
                line.delete(f.ln_bottom)
                if not na(f.lbl)
                    label.delete(f.lbl)
            array.remove(activeFlops, i)
        else
            // Extend the active lines to the current bar
            line.set_x2(f.ln_top, bar_index)
            line.set_x2(f.ln_bottom, bar_index)
            if not na(f.lbl)
                label.set_x(f.lbl, bar_index)

// --- STEP 4: Flop Trend Change Deactivation ---
if enableFlops and flopTrendChanged and deactivateOnTrend
    if array.size(activeFlops) > 0
        for i = array.size(activeFlops) - 1 to 0
            Flop f = array.get(activeFlops, i)
            f.active := false
            if showFlopLabels and not na(f.lbl)
                label.set_text(f.lbl, "FLOP (Trend Flip)")
        array.clear(activeFlops)

// --- STEP 5: Flop Detection & Creation ---
if enableFlops and barstate.isconfirmed
    // Check 1, 2, and 3 Candle Logic Simultaneously
    for offset = 1 to 3
        bool isBullSeq = false
        bool isBearSeq = false
        
        if offset == 1
            isBullSeq := isBullSeq1
            isBearSeq := isBearSeq1
        else if offset == 2
            isBullSeq := isBullSeq2
            isBearSeq := isBearSeq2
        else if offset == 3
            isBullSeq := isBullSeq3
            isBearSeq := isBearSeq3

        // Checks if the candle preceding the sequence was opposing the trend
        bool isBullishFlopConfirmed = isBullSeq and (close[offset] <= open[offset])
        bool isBearishFlopConfirmed = isBearSeq and (close[offset] >= open[offset])
        
        if isBullishFlopConfirmed or isBearishFlopConfirmed
            float fTop   = na
            float fBottom = na
            
            // Define Boundaries
            if isBullishFlopConfirmed
                fTop    := flopBoundary == "Wicks (High/Low)" ? high[offset] : open[offset]
                fBottom := flopBoundary == "Wicks (High/Low)" ? low[offset]  : close[offset]
            else
                fTop    := flopBoundary == "Wicks (High/Low)" ? high[offset] : close[offset]
                fBottom := flopBoundary == "Wicks (High/Low)" ? low[offset]  : open[offset]
                
            // Validate Structure Break
            bool structureBroken = false
            if isBullishFlopConfirmed
                float maxC = close[0]
                if offset >= 2
                    maxC := math.max(maxC, close[1])
                if offset >= 3
                    maxC := math.max(maxC, close[2])
                structureBroken := maxC > fTop
            else
                float minC = close[0]
                if offset >= 2
                    minC := math.min(minC, close[1])
                if offset >= 3
                    minC := math.min(minC, close[2])
                structureBroken := minC < fBottom
                
            // Draw and Register New Flop
            if structureBroken
                int startBar  = bar_index - offset
                color flopCol = isBullishFlopConfirmed ? i_fBullCol : i_fBearCol
                string fLineStyle = _getLineStyle(i_fLineStyle)
                
                // Prevent duplicating flops
                bool alreadyExists = false
                if array.size(allFlops) > 0
                    for k = array.size(allFlops) - 1 to math.max(0, array.size(allFlops) - 10)
                        Flop existing = array.get(allFlops, k)
                        if existing.start_bar == startBar
                            alreadyExists := true
                            break
                            
                if not alreadyExists
                    line lnTop = line.new(
                         x1=startBar, y1=fTop, x2=bar_index, y2=fTop,
                         color=flopCol, width=flopLineWidth, style=fLineStyle)
                    line lnBottom = line.new(
                         x1=startBar, y1=fBottom, x2=bar_index, y2=fBottom,
                         color=flopCol, width=flopLineWidth, style=fLineStyle)
                         
                    label lbl = na
                    if showFlopLabels
                        float midPrice = math.avg(fTop, fBottom)
                        lbl := label.new(
                             x=startBar, y=midPrice, text="FLOP",
                             color=color.new(flopCol, 100), textcolor=flopCol,
                             style=label.style_none, size=size.tiny)
                             
                    Flop newFlop = Flop.new(fTop, fBottom, startBar, isBullishFlopConfirmed, lnTop, lnBottom, lbl, true)
                    array.push(activeFlops, newFlop)
                    array.push(allFlops, newFlop)
                    
                    // History pruning logic to prevent out-of-memory array limits
                    if array.size(allFlops) > 500
                        array.shift(allFlops)
````
