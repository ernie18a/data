# Nexus Global Initial Balance (IB)

- url: https://www.tradingview.com/script/hgjaoeCr-Nexus-Global-Initial-Balance-IB/
- type: indicator
- pine_id: PUB;54a25ae966974e88b888550e14c5159c
- version: 3.0

## Description

📝 Publication Description
Title: [b]Nexus Global Initial Balance (IB)[/b] : Institutional Flow & Macro Confluence System

Overview
The [b]Nexus Global Initial Balance (IB)[/b] is a sophisticated volatility-mapping engine designed for elite index and forex traders. It utilizes the Initial Balance (IB)—the critical first 60 minutes of the Tokyo, London, and New York sessions—to establish the "Structural DNA" of the trading day.

While most traders focus on simple breakouts, this indicator uncovers the hidden institutional "pivot zones" by overlapping session volatility with macro-structural Fibonacci context. It identifies where the "Big Money" is likely to defend positions and where trend expansions are mathematically projected to exhaust.

Key Institutional Features:

Triple-Session IB Architecture: Dynamic, color-coded 1-hour ranges for Tokyo (JST), London (GMT/BST), and New York (EST/EDT).

The Session Golden Zone: Automated shading of the 50% – 61.8% retracement area within each IB box, identifying the high-probability "Institutional Re-entry" zone.

Macro-to-Micro Confluence Engine: A master HTF source toggle that scans higher timeframes (15m to Daily) for structural Fibonacci levels and highlights them as "Institutional Pivots" when they intersect with your session range.

Trend-Based Expansion Projections: Algorithmic price targets based on Fibonacci extensions (0.618, 1.272, 1.618) to define precise take-profit areas.

Pro-Tier Visual Customization: Full control over line weights, styles (Dashed/Dotted/Solid), and session colors to maintain a clean, high-performance trading environment.

📈 The "Nexus Method": Professional Trading Rules
To trade this indicator successfully, follow these institutional protocols:

Rule 1: Establish the "Macro Bias"
The Check: Before the session opens, check the HTF 50% Level (the Daily or 4-hour midpoint).
The Rule: If the price is trading above the HTF 50%, look for Bullish IB breakouts. If below, look for Bearish IB breakdowns.

Rule 2: The "Golden Zone" Retest (Highest Probability)
Setup: Wait for the 1-hour IB range to form.
Action: If the price breaks out of the IBH (High), do not chase it. Wait for a pullback into the shaded Golden Zone (50-61.8%) within the box.
Confirmation: Look for an Institutional Pivot (Red line) sitting inside that Golden Zone.
Entry: Buy when price touches the confluence of the Golden Zone and the Institutional Pivot.
Stop Loss: 5 ticks below the IBL (Low).

Rule 3: The "Expansion Target" Protocol
Take Profit 1 (0.618 Ext): Move stop-loss to Breakeven. This is the "Safety Target."
Take Profit 2 (1.272 Ext): The institutional target for "Trend Days." Close 75% of the position here.
Take Profit 3 (1.618 Ext): The "Exhaustion Point." Close the remainder of the position.

Rule 4: The "Failed IB" (Mean Reversion)
The Setup: Price breaks the IBH but cannot reach the 0.618 extension and falls back into the box.
The Rule: This is a "Range Day." Target the opposite side of the box (IBL). This usually occurs when there is no confluence between the session range and the HTF levels.

Rule 5: Session Synergy
Always watch the Tokyo IB levels during the London open. If London opens inside the Tokyo Golden Zone, it often indicates a massive expansion move is coming as the two sessions' liquidity pools overlap.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb


//@version=6
indicator("Nexus Global Initial Balance (IB)", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 4000)

// --- Settings ---
groupT = "Tokyo Session (JST)"
showT  = input.bool(true, "Show Tokyo IB", group = groupT)
sessT  = input.session("0845-0945", "Tokyo IB Window", group = groupT)
tzT    = "Asia/Tokyo"

groupL = "London Session (BST/GMT)"
showL  = input.bool(true, "Show London IB", group = groupL)
sessL  = input.session("0800-0900", "London IB Window", group = groupL)
tzL    = "Europe/London"

groupN = "New York Session (EDT/EST)"
showN  = input.bool(true, "Show NY IB", group = groupN)
sessN  = input.session("0930-1030", "NY IB Window", group = groupN)
tzN    = "America/New_York"

groupFib = "Fibonacci Logic"
showHTF   = input.bool(true, "Show HTF Structural Fibs (Source Toggle)", group = groupFib, tooltip = "Master toggle for HTF-based levels and Institutional Pivot detection.")
fibTF     = input.timeframe("240", "HTF Fib Source", options = ["15", "30", "60", "240", "D"], group = groupFib)
lookback  = input.int(100, "Swing Lookback (HTF Bars)", minval = 10, group = groupFib)
showGZ    = input.bool(true, "Highlight Session OTE Zone (61.8-78.6%)", group = groupFib)
showInt   = input.bool(true, "Show Internal Fibs (38.2% & 50%)", group = groupFib)
showExt   = input.bool(true, "Show Session Trend Extensions", group = groupFib)

// --- Comprehensive Style Settings ---
groupStyle = "Global Visual Styles"
ibWidth    = input.int(2, "IB Boundary Width", minval = 1, maxval = 10, group = groupStyle)
ibStyle    = input.string("Solid", "IB Boundary Style", options = ["Solid", "Dashed", "Dotted"], group = groupStyle)
fibWidth   = input.int(1, "Internal/Ext Width", minval = 1, maxval = 10, group = groupStyle)
fibStyle   = input.string("Dashed", "Internal/Ext Style", options = ["Solid", "Dashed", "Dotted"], group = groupStyle)
textSize   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupStyle)

groupColors = "Session Colors (Fills & Lines)"
colorT     = input.color(color.new(#5b9cf6, 85), "Tokyo Fill", group = groupColors)
lineT      = input.color(#5b9cf6, "Tokyo Lines", group = groupColors)
textT      = input.color(#5b9cf6, "Tokyo Text", group = groupColors)

colorL     = input.color(color.new(#089981, 85), "London Fill", group = groupColors)
lineL      = input.color(#089981, "London Lines", group = groupColors)
textL      = input.color(#089981, "London Text", group = groupColors)

colorN     = input.color(color.new(#fb8c00, 85), "NY Fill", group = groupColors)
lineN      = input.color(#fb8c00, "NY Lines", group = groupColors)
textN      = input.color(#fb8c00, "NY Text", group = groupColors)

instCol    = input.color(#ff5252, "Institutional Signal Color", group = groupColors)

// --- Helper Functions ---
f_get_line_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_get_text_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

// --- HTF Structural Anchors (Calculated even if hidden to allow for toggle responsiveness) ---
[htfH, htfL] = request.security(syminfo.tickerid, fibTF, [ta.highest(high, lookback), ta.lowest(low, lookback)])
float htfRange = htfH - htfL
float htf382   = htfH - htfRange * 0.382
float htf500   = htfH - htfRange * 0.500
float htf618   = htfH - htfRange * 0.618

// --- State Management ---
type IBState
    float h = na
    float l = na
    int startBar = na
    int stopBar = na
    string name = ""
    color lCol = color.gray
    color tCol = color.gray
    line[] lines
    box bx = na
    box gzBox = na
    label[] labels

var tokyo  = IBState.new(name = "TKY", lCol = lineT, tCol = textT, lines = array.new_line(), labels = array.new_label())
var london = IBState.new(name = "LDN", lCol = lineL, tCol = textL, lines = array.new_line(), labels = array.new_label())
var ny     = IBState.new(name = "NY",  lCol = lineN, tCol = textN, lines = array.new_line(), labels = array.new_label())

// --- Session Logic ---
f_status(sess, tz) =>
    t = time(timeframe.period, sess, tz)
    [not na(t), not na(t) and na(t[1]), na(t) and not na(t[1])]

[t_in, t_new, t_end] = f_status(sessT, tzT)
[l_in, l_new, l_end] = f_status(sessL, tzL)
[n_in, n_new, n_end] = f_status(sessN, tzN)

if t_new
    tokyo.h := high, tokyo.l := low, tokyo.startBar := bar_index, tokyo.stopBar := na
else if t_in
    tokyo.h := math.max(nz(tokyo.h, high), high), tokyo.l := math.min(nz(tokyo.l, low), low)
if l_new
    tokyo.stopBar := bar_index

if l_new
    london.h := high, london.l := low, london.startBar := bar_index, london.stopBar := na
else if l_in
    london.h := math.max(nz(london.h, high), high), london.l := math.min(nz(london.l, low), low)
if n_new
    london.stopBar := bar_index

if n_new
    ny.h := high, ny.l := low, ny.startBar := bar_index, ny.stopBar := na
else if n_in
    ny.h := math.max(nz(ny.h, high), high), ny.l := math.min(nz(ny.l, low), low)
if t_new
    ny.stopBar := bar_index

// --- Drawing Method ---
method draw(IBState self, color fill) =>
    if not na(self.h) and not na(self.l)
        for ln in self.lines
            line.delete(ln)
        array.clear(self.lines)
        for lb in self.labels
            label.delete(lb)
        array.clear(self.labels)
        box.delete(self.bx), box.delete(self.gzBox)

        x2 = na(self.stopBar) ? bar_index : self.stopBar
        rng = self.h - self.l
        
        curIBStyle  = f_get_line_style(ibStyle)
        curFibStyle = f_get_line_style(fibStyle)
        curTextSize = f_get_text_size(textSize)

        // IB Box & Boundaries
        self.bx := box.new(self.startBar, self.h, x2, self.l, bgcolor = fill, border_color = color.new(self.lCol, 50))
        array.push(self.lines, line.new(self.startBar, self.h, x2, self.h, color = self.lCol, width = ibWidth, style = curIBStyle))
        array.push(self.lines, line.new(self.startBar, self.l, x2, self.l, color = self.lCol, width = ibWidth, style = curIBStyle))

        // Internal Session OTE Zone & Fibs (Only show if enabled)
        fib382 = self.h - rng * 0.382
        fib500 = self.h - rng * 0.500
        fib618 = self.h - rng * 0.618
        fib705 = self.h - rng * 0.705
        fib786 = self.h - rng * 0.786
        
        if showGZ
            // OTE Box (61.8% to 78.6%)
            self.gzBox := box.new(self.startBar, fib618, x2, fib786, bgcolor = color.new(self.lCol, 70), border_color = color.new(self.lCol, 100))
            
            // OTE Levels (61.8%, 70.5%, 78.6%)
            array.push(self.lines, line.new(self.startBar, fib618, x2, fib618, color = self.lCol, style = curFibStyle, width = fibWidth))
            array.push(self.labels, label.new(x2, fib618, "61.8%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
            
            array.push(self.lines, line.new(self.startBar, fib705, x2, fib705, color = self.lCol, style = curFibStyle, width = fibWidth))
            array.push(self.labels, label.new(x2, fib705, "70.5%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
            
            array.push(self.lines, line.new(self.startBar, fib786, x2, fib786, color = self.lCol, style = curFibStyle, width = fibWidth))
            array.push(self.labels, label.new(x2, fib786, "78.6%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

        if showInt
            // 38.2% & 50% outside box
            array.push(self.lines, line.new(self.startBar, fib382, x2, fib382, color = self.lCol, style = curFibStyle, width = fibWidth))
            array.push(self.labels, label.new(x2, fib382, "38.2%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
            
            array.push(self.lines, line.new(self.startBar, fib500, x2, fib500, color = self.lCol, style = curFibStyle, width = fibWidth))
            array.push(self.labels, label.new(x2, fib500, "50%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

        // Institutional HTF Confluence (Only show if Master HTF toggle is ON)
        if showHTF
            htfLevels = array.from(htf382, htf500, htf618)
            for i = 0 to 2
                lv = array.get(htfLevels, i)
                if lv <= self.h and lv >= self.l
                    array.push(self.lines, line.new(self.startBar, lv, x2, lv, color = instCol, width = ibWidth + 1, style = curIBStyle))
                    array.push(self.labels, label.new(self.startBar, lv, "INSTITUTIONAL PIVOT", color = #00000000, textcolor = instCol, style = label.style_label_right, size = curTextSize))

        // Session Extensions (Only show if enabled)
        if showExt
            exts = array.from(0.618, 1.272, 1.618)
            for ex in exts
                up = self.h + (rng * ex)
                dn = self.l - (rng * ex)
                array.push(self.lines, line.new(self.startBar, up, x2, up, color = color.new(self.lCol, 40), style = curFibStyle, width = fibWidth))
                array.push(self.lines, line.new(self.startBar, dn, x2, dn, color = color.new(self.lCol, 40), style = curFibStyle, width = fibWidth))
                array.push(self.labels, label.new(x2, up, str.tostring(ex) + " Ext", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
                array.push(self.labels, label.new(x2, dn, str.tostring(ex) + " Ext", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

        // ID Labels
        array.push(self.labels, label.new(x2, self.h, self.name + " IBH", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
        array.push(self.labels, label.new(x2, self.l, self.name + " IBL", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

// HTF Reference Lines (Drawn globally at the end)
var line htfLine382 = na, var label htfLbl382 = na
var line htfLine500 = na, var label htfLbl500 = na
var line htfLine618 = na, var label htfLbl618 = na

if barstate.islast
    // Cleanup old lines/labels
    line.delete(htfLine382), label.delete(htfLbl382)
    line.delete(htfLine500), label.delete(htfLbl500)
    line.delete(htfLine618), label.delete(htfLbl618)
    
    // Only redraw if the Master HTF toggle is enabled
    if showHTF
        cStyle = f_get_line_style(fibStyle)
        tSize  = f_get_text_size(textSize)
        htfLine382 := line.new(bar_index-1, htf382, bar_index, htf382, color = color.new(color.gray, 40), extend = extend.both, style = cStyle)
        htfLbl382  := label.new(bar_index, htf382, "HTF 38.2%", color = #00000000, textcolor = color.gray, style = label.style_label_left, size = tSize)
        
        htfLine500 := line.new(bar_index-1, htf500, bar_index, htf500, color = color.new(color.gray, 40), extend = extend.both, style = cStyle)
        htfLbl500  := label.new(bar_index, htf500, "HTF 50.0%", color = #00000000, textcolor = color.gray, style = label.style_label_left, size = tSize)
        
        htfLine618 := line.new(bar_index-1, htf618, bar_index, htf618, color = color.new(color.gray, 40), extend = extend.both, style = cStyle)
        htfLbl618  := label.new(bar_index, htf618, "HTF 61.8%", color = #00000000, textcolor = color.gray, style = label.style_label_left, size = tSize)

// Update session drawings
if showT and (t_end or barstate.islast)
    tokyo.draw(colorT)
if showL and (l_end or barstate.islast)
    london.draw(colorL)
if showN and (n_end or barstate.islast)
    ny.draw(colorN)
````
