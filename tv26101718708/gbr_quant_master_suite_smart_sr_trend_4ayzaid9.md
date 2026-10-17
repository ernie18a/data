# GBR Quant Master Suite [Smart S/R + Trend]

- url: https://www.tradingview.com/script/4aYzAiD9-GBR-Quant-Master-Suite-Smart-S-R-Trend/
- type: indicator
- pine_id: PUB;a276220ae4cd4e44a430d527dcfbb9bc
- version: 1.0

## Description

The GBR Quant Master Suite is the ultimate all-in-one algorithmic weapon for professional prop firm traders and aggressive day traders. It combines a highly sensitive multi-timeframe (MTF) trend ribbon with a smart, self-cleaning Support & Resistance network.

Built for those who demand raw price action without the visual clutter.

🔥 Core Features:

Self-Cleaning Adaptive S/R: Automatically detects major structural pivot points and draws clean support/resistance lines.

Auto-Breakout Logic: The moment a level is broken by a candle close, the long line is instantly deleted to keep your chart pristine. It leaves behind a minimal Break ▲ or Break ▼ marker for historical reference.

Dynamic Trend Ribbon: A zero-lag, smoothed moving average band that instantly shifts between Bullish (Green) and Bearish (Red) to keep you on the right side of the momentum.

Minimal Radar Dashboard: A sleek, transparent, non-intrusive HUD in the bottom right corner that continuously tracks the exact price distance of the closest active Resistance and Support levels.

Institutional Grade: Zero noise. No repainting. Just pure market geometry.

🎯 How to execute:
Wait for the Trend Ribbon to align with a breakout. If the ribbon turns Green and you get a Break ▲ signal at a major resistance, that is your sniper entry.

## Source Code

````pine
//@version=6
indicator("GBR Quant Master Suite", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. SETTINGS (UI)
// ==========================================
grp1 = "GBR Dynamic Trend Ribbon"
trendLen = input.int(14, title="Ribbon Sensitivity", group=grp1)
trendTf  = input.timeframe("", title="Ribbon Timeframe (Empty = Chart)", group=grp1)

grp2 = "GBR Adaptive S/R (Auto-Cleanup)"
pivotLen = input.int(10, title="Pivot Detection Length", group=grp2)

// ==========================================
// 2. GBR CORPORATE IDENTITY (UV COLORS)
// ==========================================
colGreen  = color.new(#00FF00, 0) // UV Green (Buy / Breakout)
colRed    = color.new(#FF0033, 0) // UV Red (Sell / Resistance)
colYellow = color.new(#FFFF00, 0) // UV Yellow (Support)

// ==========================================
// 3. TREND RIBBON LOGIC
// ==========================================
smoothTrend = ta.hma(close, trendLen)
mtfTrend    = request.security(syminfo.tickerid, trendTf, smoothTrend)
trendColor  = close > mtfTrend ? colGreen : colRed

plot(mtfTrend, title="GBR Ribbon", color=trendColor, linewidth=3)

// ==========================================
// 4. ADAPTIVE S/R & BREAKOUT LOGIC
// ==========================================
// Adatszerkezet a szintek tárolására
type Level
    float price
    line ln
    bool isRes

var array<Level> activeLevels = array.new<Level>()

// Pivotok keresése
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph) and bar_index > pivotLen
    ln = line.new(bar_index[pivotLen], ph, bar_index, ph, color=colRed, style=line.style_solid, width=2)
    activeLevels.push(Level.new(ph, ln, true))

if not na(pl) and bar_index > pivotLen
    ln = line.new(bar_index[pivotLen], pl, bar_index, pl, color=colYellow, style=line.style_solid, width=2)
    activeLevels.push(Level.new(pl, ln, false))

// Vonalak meghosszabbítása és törések (Breaks) figyelése
var float closestRes = na
var float closestSup = na

closestRes := na
closestSup := na
minResDist = 999999.9
minSupDist = 999999.9

if activeLevels.size() > 0
    for i = activeLevels.size() - 1 to 0
        lvl = activeLevels.get(i)
        line.set_x2(lvl.ln, bar_index) // Vonal húzása a jelenbe
        
        isBroken = false
        // Ha ellenállás és az ár felette zár
        if lvl.isRes and close > lvl.price
            isBroken := true
            label.new(bar_index, lvl.price, text="Break ▲", color=color.new(colGreen, 85), textcolor=colGreen, style=label.style_label_down, size=size.tiny)
        // Ha támasz és az ár alatta zár
        else if not lvl.isRes and close < lvl.price
            isBroken := true
            label.new(bar_index, lvl.price, text="Break ▼", color=color.new(colRed, 85), textcolor=colRed, style=label.style_label_up, size=size.tiny)
            
        if isBroken
            line.delete(lvl.ln) // Vonal törlése a chartról
            activeLevels.remove(i) // Szint törlése a memóriából
        else
            // Legközelebbi aktív szintek számolása a Dashboardhoz
            if lvl.isRes
                dist = lvl.price - close
                if dist > 0 and dist < minResDist
                    minResDist := dist
                    closestRes := lvl.price
            else
                dist = close - lvl.price
                if dist > 0 and dist < minSupDist
                    minSupDist := dist
                    closestSup := lvl.price

// ==========================================
// 5. GBR RADAR DASHBOARD
// ==========================================
var table dash = table.new(position.bottom_right, 2, 3, frame_color=color.new(color.gray, 80), frame_width=1, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    table.cell(dash, 0, 0, "GBR RADAR", text_color=color.white, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 0, "LEVEL", text_color=color.white, bgcolor=color.new(color.black, 40))
    
    resText = na(closestRes) ? "N/A" : str.tostring(closestRes, "#.##")
    table.cell(dash, 0, 1, "Resistance", text_color=colRed, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 1, resText, text_color=colRed, bgcolor=color.new(color.black, 40))
    
    supText = na(closestSup) ? "N/A" : str.tostring(closestSup, "#.##")
    table.cell(dash, 0, 2, "Support", text_color=colYellow, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 2, supText, text_color=colYellow, bgcolor=color.new(color.black, 40))
````
