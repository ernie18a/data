# Nexus Global 15m ORB

- url: https://www.tradingview.com/script/kefMWe2O-Nexus-Global-15m-ORB/
- type: indicator
- pine_id: PUB;42edc8f9da5a4303b4682eb88cb91536
- version: 1.0

## Description

[b]Introduction[/b]
The [b]Nexus Global 15m ORB[/b] indicator is a comprehensive opening range tool designed to map the initial 15-minute price action across the three major global trading sessions: Tokyo, London, and New York. Beyond simply marking the high and low of the opening range, this script integrates Fibonacci-based Optimal Trade Entry (OTE) zones, mathematical trend extensions, and Higher Timeframe (HTF) structural confluence to help traders identify high-probability reversal and continuation zones.

[b]Core Concepts & What It Does[/b]
Opening Range Breakout (ORB) strategies rely on the volatility generated at the start of a trading session. The first 15 minutes often establish a support and resistance framework for the hours that follow. This indicator automatically detects these 15-minute windows and projects the range forward until the next session begins.

However, a standard ORB is often not enough to build a complete trading plan. To address this, the indicator incorporates:

- [b]Internal Fibonacci Levels & OTE Zone:[/b] Calculates key retracement levels (38.2% and 50%) and highlights a specific Optimal Trade Entry (OTE) box between the 61.8% and 78.6% levels of the session's range.

- [b]Session Trend Extensions:[/b] Projects standard Fibonacci extensions (0.618, 1.272, and 1.618) outward from the ORB high and low to serve as dynamic take-profit targets or exhaustion levels.

- [b]HTF Institutional Pivots:[/b] Pulls structural swing highs and lows from a user-defined higher timeframe (e.g., 4-hour) and calculates its own macro Fibonacci levels. When these macro levels intersect with the micro 15m ORB range, the indicator highlights them as "Institutional Pivots."

[b]How It Calculates (Underlying Logic)[/b]

- [b]Session Tracking:[/b] Uses time() functions to detect the exact 15-minute timeframe of the Tokyo (0845-0900 JST), London (0800-0815 GMT), and New York (0930-0945 EST) opens. It dynamically tracks the high and low during this window and locks the values once the window closes.

- [b]Internal Mathematics:[/b] The range size (rng) is calculated as ORB High - ORB Low. Internal levels are found by subtracting percentages of the range from the ORB High (e.g., ORB High - (rng * 0.5) for the 50% level).

- [b]HTF Confluence:[/b] Utilizes request.security() alongside ta.highest() and ta.lowest() over a customizable lookback period to establish the macro structural range. It then checks if the macro 38.2%, 50%, or 61.8% levels fall sequentially inside the current active ORB boundaries, plotting them distinctly when true.

- [b]Performance Optimization:[/b] To ensure the indicator does not cause chart lag (a common issue with heavy line/box drawing scripts), the drawing engine is restricted to update visual arrays strictly on barstate.islast, ensuring lightning-fast load times even on the 1-minute chart.*

[b]How to Use It[/b]

- [b]Breakout & Retest:[/b] Watch for price to break the ORB High or Low, and then wait for a retracement back to the 38.2% or 50% internal levels to join the trend toward the 1.272 or 1.618 extensions.

- [b]OTE Reversals:[/b] If a false breakout (fake-out) occurs, look for price to return to the highlighted OTE Zone (61.8% - 78.6%). This zone often acts as a strong area of defense for institutional order flow, providing excellent risk-to-reward entries back toward the opposite side of the ORB.

- [b]Institutional Pivots:[/b] When an HTF line populates inside the session range, treat it as a heavy magnet or resistance. Trades taken in confluence with these pivots carry a much higher structural weighting.

[b]Originality & Usefulness[/b]
While there are many ORB tools on TradingView, the vast majority only display horizontal lines for the high and low. This script is highly original because it combines micro-session timing with macro-structural Fibonacci confluence. By mashing up session tracking with HTF swing analysis and deep optimization drawing methods, it provides a complete, lag-free institutional framework in a single indicator, saving traders from needing multiple overlapping scripts to achieve the same result.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb



//@version=6
indicator("Nexus Global 15m ORB", overlay = true, max_lines_count = 500, max_boxes_count = 500)

// --- Settings ---
groupT = "Tokyo Session (JST)"
showT  = input.bool(true, "Show Tokyo ORB", group = groupT)
sessT  = input.session("0845-0900", "Tokyo ORB Window", group = groupT)
tzT    = "Asia/Tokyo"

groupL = "London Session (BST/GMT)"
showL  = input.bool(true, "Show London ORB", group = groupL)
sessL  = input.session("0800-0815", "London ORB Window", group = groupL)
tzL    = "Europe/London"

groupN = "New York Session (EDT/EST)"
showN  = input.bool(true, "Show NY ORB", group = groupN)
sessN  = input.session("0930-0945", "NY ORB Window", group = groupN)
tzN    = "America/New_York"

groupFib = "Fibonacci Logic"
showHTF   = input.bool(true, "Show HTF Structural Fibs (Source Toggle)", group = groupFib, tooltip = "Master toggle for HTF-based levels and Institutional Pivot detection.")
fibTF     = input.timeframe("240", "HTF Fib Source", options = ["15", "30", "60", "240", "D"], group = groupFib)
lookback  = input.int(100, "Swing Lookback (HTF Bars)", minval = 10, group = groupFib)
showGZ    = input.bool(true, "Highlight Session OTE Zone (61.8%-78.6%)", group = groupFib)
show382   = input.bool(true, "Show 38.2% Internal Level", group = groupFib)
show500   = input.bool(true, "Show 50% Internal Level", group = groupFib)
showExt   = input.bool(true, "Show Session Trend Extensions", group = groupFib)

// --- Comprehensive Style Settings ---
groupStyle = "Global Visual Styles"
ibWidth    = input.int(2, "ORB Boundary Width", minval = 1, maxval = 10, group = groupStyle)
ibStyle    = input.string("Solid", "ORB Boundary Style", options = ["Solid", "Dashed", "Dotted"], group = groupStyle)
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
method draw(IBState self, color fill, bool show) =>
    if not na(self.h) and not na(self.l)
        for ln in self.lines
            line.delete(ln)
        array.clear(self.lines)
        for lb in self.labels
            label.delete(lb)
        array.clear(self.labels)
        box.delete(self.bx), box.delete(self.gzBox)

        if show
            x2 = na(self.stopBar) ? bar_index : self.stopBar
            rng = self.h - self.l
            
            curIBStyle  = f_get_line_style(ibStyle)
            curFibStyle = f_get_line_style(fibStyle)
            curTextSize = f_get_text_size(textSize)

            // IB Box & Boundaries
            self.bx := box.new(self.startBar, self.h, x2, self.l, bgcolor = fill, border_color = color.new(self.lCol, 50))
            array.push(self.lines, line.new(self.startBar, self.h, x2, self.h, color = self.lCol, width = ibWidth, style = curIBStyle))
            array.push(self.lines, line.new(self.startBar, self.l, x2, self.l, color = self.lCol, width = ibWidth, style = curIBStyle))

            // Internal Session OTE Zone
            gzTop382 = self.h - rng * 0.382
            gzTop500 = self.h - rng * 0.5
            gzBtm618 = self.h - rng * 0.618
            gzBtm705 = self.h - rng * 0.705
            gzBtm786 = self.h - rng * 0.786
            
            if showGZ
                self.gzBox := box.new(self.startBar, gzBtm618, x2, gzBtm786, bgcolor = color.new(self.lCol, 70), border_color = color.new(self.lCol, 100))
                
                array.push(self.lines, line.new(self.startBar, gzBtm618, x2, gzBtm618, color = self.lCol, style = curFibStyle, width = fibWidth))
                array.push(self.lines, line.new(self.startBar, gzBtm705, x2, gzBtm705, color = self.lCol, style = curFibStyle, width = fibWidth))
                array.push(self.lines, line.new(self.startBar, gzBtm786, x2, gzBtm786, color = self.lCol, style = curFibStyle, width = fibWidth))
                
                array.push(self.labels, label.new(x2, gzBtm618, "61.8%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
                array.push(self.labels, label.new(x2, gzBtm705, "70.5%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
                array.push(self.labels, label.new(x2, gzBtm786, "78.6%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

            if show382
                array.push(self.lines, line.new(self.startBar, gzTop382, x2, gzTop382, color = self.lCol, style = curFibStyle, width = fibWidth))
                array.push(self.labels, label.new(x2, gzTop382, "38.2%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

            if show500
                array.push(self.lines, line.new(self.startBar, gzTop500, x2, gzTop500, color = self.lCol, style = curFibStyle, width = fibWidth))
                array.push(self.labels, label.new(x2, gzTop500, "50%", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

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
            array.push(self.labels, label.new(x2, self.h, self.name + " ORB H", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))
            array.push(self.labels, label.new(x2, self.l, self.name + " ORB L", color = #00000000, textcolor = self.tCol, style = label.style_label_left, size = curTextSize))

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

    // Update session drawings strictly on the last bar to eliminate lag
    tokyo.draw(colorT, showT)
    london.draw(colorL, showL)
    ny.draw(colorN, showN)
````
