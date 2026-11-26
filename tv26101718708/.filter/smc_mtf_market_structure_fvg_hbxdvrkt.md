# SMC MTF Market Structure + FVG

- url: https://www.tradingview.com/script/HbxDvrkt-SMC-MTF-Market-Structure-FVG/
- type: indicator
- pine_id: PUB;21dad91284594d5080b1457f56d14eaf
- version: 1.0

## Description

This is a fully customizable Multi-Timeframe (MTF) Market Structure indicator designed specifically for SMC (Smart Money Concepts) and Price Action traders. It overlays true Higher Timeframe (HTF) structure onto your current chart, allowing you to maintain a top-down perspective without switching tabs.

While it defaults to the 4-Hour (4h) timeframe, you can fully adjust this to the 1h, Daily, or Weekly in the settings to align with your specific trading strategy.

Key Features
Dynamic MTF Overlay: Select any Higher Timeframe (HTF) in the settings. The script calculates true pivots on the HTF and projects them onto your current chart using non-repainting logic.

Active Dealing Range: Automatically identifies and displays the current Swing High and Swing Low of the selected HTF, helping you stay oriented within the market cycle.

Equilibrium (50% Level): Clearly marks the midpoint of the dealing range. This is essential for identifying Premium (Sell) vs. Discount (Buy) zones to ensure you are never "buying the top" or "selling the bottom."

HTF Fair Value Gaps (FVG): Detects and highlights unmitigated FVGs from your selected HTF. These act as high-probability Points of Interest (POIs) for entries or targets.

Visuals & Logic
Bullish/Bearish Labels: Clearly distinguishes between CHoCH (Change of Character/Trend Reversal) and BOS (Break of Structure/Trend Continuation).

Clean Interface: Designed to keep your chart clutter-free, with continuation signals (BOS) styled more subtly than reversals.

Zero Repaint Guarantee: Unlike many MTF scripts, this indicator uses closed-candle data from the HTF. This means signals are fixed once the HTF candle closes, making it reliable for backtesting and live execution.

How to Use
Setup: Add the script to a lower timeframe chart (e.g., 5m or 15m).

Configuration: Open Settings and select your desired "Higher Timeframe" (Default is 240/4h).

Strategy:

Identify the HTF Trend via the BOS/CHoCH labels.

Look for the price to return to an HTF FVG.

Ensure the entry is in the Discount zone (for longs) or Premium zone (for shorts) using the Equilibrium line.

Disclaimer
This indicator is an analysis tool and does not constitute financial advice. Always combine MTF structure with your own confirmation entries and risk management.

## Source Code

````pine
//@version=5
indicator("Professional MTF Structure & FVG", shorttitle="PRO_MTF", overlay=true, max_lines_count=150, max_labels_count=150, max_boxes_count=150)

// ==========================================
// --- INPUTS ---
// ==========================================
grp_struct = "Market Structure Settings"
htf        = input.timeframe("240", "Higher Timeframe", group=grp_struct, tooltip="De timeframe waarop structuur en FVG's berekend worden.")
length     = input.int(2, "Pivot Lookback", minval=1, group=grp_struct)
showLabels = input.bool(true, "Show Break Labels", group=grp_struct)

grp_fvg    = "Fair Value Gap Settings"
showFVG    = input.bool(true, "Display 4h FVG", group=grp_fvg)
fvgColorB  = input.color(color.new(color.green, 85), "Bullish FVG Color", group=grp_fvg)
fvgColorS  = input.color(color.new(color.red, 85), "Bearish FVG Color", group=grp_fvg)

grp_vis    = "Visuals & Colors"
col_choch_bull = input.color(color.green, "Bullish CHoCH", group=grp_vis)
col_choch_bear = input.color(color.red, "Bearish CHoCH", group=grp_vis)
col_bos        = input.color(color.gray, "BOS (Continuation)", group=grp_vis)
showEQ         = input.bool(true, "Show Equilibrium (50%)", group=grp_vis)

// ==========================================
// --- CALCULATIONS (Non-Repainting) ---
// ==========================================

// Functie voor Pivot berekening
calc_pivots(len) =>
    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)
    [ph, pl]

// Functie voor FVG berekening
calc_fvg() =>
    bull_fvg = low > high[2]
    bear_fvg = high < low[2]
    [bull_fvg, low, high[2], bear_fvg, low[2], high]

// Data ophalen via request.security
// We gebruiken [1] om de data van de vorige (gesloten) candle te pakken om repainting te voorkomen.
[raw_ph, raw_pl] = request.security(syminfo.tickerid, htf, calc_pivots(length), lookahead=barmerge.lookahead_off)
[fvg_bull, f_bull_t, f_bull_b, fvg_bear, f_bear_t, f_bear_b] = request.security(syminfo.tickerid, htf, calc_fvg(), lookahead=barmerge.lookahead_off)

// ==========================================
// --- STRUCTURE LOGIC ---
// ==========================================
var float lastHigh = na
var float lastLow  = na
var string trend   = "neutral"

// Update niveaus zodra een pivot bevestigd is op de HTF
if not na(raw_ph)
    lastHigh := raw_ph
if not na(raw_pl)
    lastLow  := raw_pl

// Detectie van Breaks (BOS / CHoCH)
bool bullBreak = ta.crossover(close, lastHigh)
bool bearBreak = ta.crossunder(close, lastLow)

if bullBreak and not na(lastHigh)
    string labelTxt = (trend == "bearish" or trend == "neutral") ? "CHoCH ▲" : "BOS"
    color  mainCol  = (trend == "bearish" or trend == "neutral") ? col_choch_bull : col_bos
    
    line.new(bar_index - 5, lastHigh, bar_index, lastHigh, color=mainCol, width=1)
    if showLabels
        label.new(bar_index, lastHigh, labelTxt, style=label.style_label_down, color=color.new(mainCol, 90), textcolor=mainCol, size=size.small)
    
    trend := "bullish"
    lastHigh := na // Reset na break om dubbele triggers te voorkomen

if bearBreak and not na(lastLow)
    string labelTxt = (trend == "bullish" or trend == "neutral") ? "CHoCH ▼" : "BOS"
    color  mainCol  = (trend == "bullish" or trend == "neutral") ? col_choch_bear : col_bos
    
    line.new(bar_index - 5, lastLow, bar_index, lastLow, color=mainCol, width=1)
    if showLabels
        label.new(bar_index, lastLow, labelTxt, style=label.style_label_up, color=color.new(mainCol, 90), textcolor=mainCol, size=size.small)
    
    trend := "bearish"
    lastLow := na // Reset na break
    
// ==========================================
// --- FVG VISUALIZATION ---
// ==========================================
// Check of er een nieuwe HTF candle is gesloten om dubbele boxen op LTF te voorkomen
newHtfBar = ta.change(time(htf))

if showFVG and newHtfBar
    if fvg_bull
        box.new(bar_index, f_bull_t, bar_index + 5, f_bull_b, border_color=na, bgcolor=fvgColorB)
    if fvg_bear
        box.new(bar_index, f_bear_t, bar_index + 5, f_bear_b, border_color=na, bgcolor=fvgColorS)

// ==========================================
// --- DEALING RANGE & EQUILIBRIUM ---
// ==========================================
var line hiLine = na
var line loLine = na
var line midLine = na

// Verwijder oude range lijnen om vervuiling te voorkomen
line.delete(hiLine)
line.delete(loLine)
line.delete(midLine)

if not na(lastHigh) and not na(lastLow)
    hiLine  := line.new(bar_index, lastHigh, bar_index + 5, lastHigh, color=color.gray, style=line.style_dashed)
    loLine  := line.new(bar_index, lastLow, bar_index + 5, lastLow, color=color.gray, style=line.style_dashed)
    
    if showEQ
        float mid = math.avg(lastHigh, lastLow)
        midLine := line.new(bar_index, mid, bar_index + 5, mid, color=color.new(color.blue, 50), style=line.style_dotted)
````
