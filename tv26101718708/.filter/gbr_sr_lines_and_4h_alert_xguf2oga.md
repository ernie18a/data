# GBR S/R Lines and 4h Alert

- url: https://www.tradingview.com/script/XGUf2oGA-GBR-S-R-Lines-and-4h-Alert/
- type: indicator
- pine_id: PUB;83b32d367dc048238602521bccce1b33
- version: 1.0

## Description

GBR Dynamic S/R Lines & 4H Alerts is a purpose-built, institutional-grade indicator designed for prop firm traders and day traders who need absolute precision without chart clutter.

Instead of getting chopped up in lower timeframe noise, this indicator automatically identifies major liquidity pools and pivot points. Its most powerful feature is the Forced Multi-Timeframe (MTF) Logic: it calculates the higher-timeframe structural levels (default: 4-Hour) and projects them directly onto your active execution chart (e.g., 1m, 5m, or 15m).

🔥 Key Features:

Forced 4H Levels: Never lose sight of the macro picture. See where the "big money" steps in while trading on the micro timeframes.

Zero Clutter: Stripped of messy vertical connecting lines. It only plots clean, unbroken horizontal S/R lines.

Dynamic Price Labels: Automatically updates and displays the exact price value of the active Support/Resistance levels on the right side of the chart.

Built-in Sniper Alerts: Set it and forget it. Includes pre-configured alert conditions that trigger the exact moment the price tests a critical structural level.

Fully Customizable: Adjust the pivot sensitivity (Left/Right bars) to filter out minor swings and only focus on major turning points.

🎯 How to use:
Treat this indicator as your radar. Keep it running in the background, wait for the push alert to trigger at a major 4H zone, and then execute your standard entry setups (reversals or breakouts) on your lower timeframe with maximum confidence.

## Source Code

````pine
//@version=6
indicator("FreeLab GBR S/R Vonalak", overlay=true, max_lines_count=50, max_labels_count=50)

// --- BEÁLLÍTÁSOK ---
leftLen = input.int(10, title="Bal oldali gyertyák (Érzékenység)")
rightLen = input.int(10, title="Jobb oldali gyertyák (Érzékenység)")
use4H = input.bool(true, title="4 Órás (4H) szintek kényszerítése")

// --- FREELAB ARCULAT ---
colRes = color.new(#FF0033, 0) // GBR UV Piros (Ellenállás)
colSup = color.new(#FFFF00, 0) // GBR UV Sárga (Támasz)

// --- PIVOT LOGIKA ---
get_pivots() =>
    ph = ta.pivothigh(high, leftLen, rightLen)
    pl = ta.pivotlow(low, leftLen, rightLen)
    [ph, pl]

[chart_ph, chart_pl] = get_pivots()
[htf_ph, htf_pl] = request.security(syminfo.tickerid, "240", get_pivots(), lookahead=barmerge.lookahead_on)

active_ph = use4H ? htf_ph : chart_ph
active_pl = use4H ? htf_pl : chart_pl

var float currentRes = na
var float currentSup = na

var line resLine = na
var label resLabel = na
var line supLine = na
var label supLabel = na

// --- VONALAK ÉS ÉRTÉKEK RAJZOLÁSA ---
if not na(active_ph)
    currentRes := active_ph
    resLine := line.new(x1=bar_index, y1=currentRes, x2=bar_index, y2=currentRes, color=colRes, width=2, style=line.style_solid)
    resLabel := label.new(x=bar_index, y=currentRes, text=str.tostring(currentRes, "#.##"), color=color.new(color.white, 100), textcolor=colRes, style=label.style_label_left, size=size.normal)

if not na(active_pl)
    currentSup := active_pl
    supLine := line.new(x1=bar_index, y1=currentSup, x2=bar_index, y2=currentSup, color=colSup, width=2, style=line.style_solid)
    supLabel := label.new(x=bar_index, y=currentSup, text=str.tostring(currentSup, "#.##"), color=color.new(color.white, 100), textcolor=colSup, style=label.style_label_left, size=size.normal)

// Vonalak meghosszabbítása a jelenlegi gyertyáig és a feliratok jobbra tolása
if not na(resLine)
    line.set_x2(resLine, bar_index)
    label.set_xy(resLabel, bar_index + 3, currentRes)

if not na(supLine)
    line.set_x2(supLine, bar_index)
    label.set_xy(supLabel, bar_index + 3, currentSup)

// --- 4H RIASZTÁSOK ---
testRes = ta.crossover(close, currentRes) or (high >= currentRes and close <= currentRes)
testSup = ta.crossunder(close, currentSup) or (low <= currentSup and close >= currentSup)

alertcondition(testRes, title="🔥 GBR: UV Piros 4H!", message="Mesterlövész figyelem! Az árfolyam megérintette a 4 órás UV Piros ellenállást!")
alertcondition(testSup, title="⚡ GBR: UV Sárga 4H!", message="Mesterlövész figyelem! Az árfolyam beesett a 4 órás UV Sárga támaszra!")
````
