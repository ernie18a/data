# Multi-Session ORB Specialist

- url: https://www.tradingview.com/script/231kHSUt-Multi-Session-ORB-Specialist/
- type: indicator
- pine_id: PUB;8768622d3e114df1ba179ab645e0bdd5
- version: 1.0

## Description

Overview
The [b]Multi Session ORB Specialist [/b] is a precision volatility-capture tool designed for professional index traders (Nikkei 225, NASDAQ, DAX). It focuses on the "Initial Balance"—the high-intensity first 15 minutes of the Tokyo, London, and New York opens—to define the structural boundaries for the entire trading day.

Unlike traditional ORB indicators that clutter the chart with infinite lines, this specialist version utilizes Dynamic Session-Break Logic. Targets and range boundaries extend only until the subsequent market session begins, ensuring a clean, focused, and professional workspace that prevents "analysis paralysis."

Key Features:

Triple-Session Intelligence: Independent tracking of Tokyo (JST), London (GMT/BST), and New York (EST/EDT) opens.
The Golden Zone: Automatically plots the 38.2%, 50%, and 61.8% Fibonacci levels within the Opening Range to identify "Optimal Trade Entry" (OTE) retracements.
Algorithmic RR Targets: Precision-calculated Risk-to-Reward levels (1:1, 1:2, 1:3) based on the volatility of the opening 15-minute range.
Institutional Aesthetics: Professional-grade visual management using dashed/dotted hierarchy and clean bounding boxes to differentiate between range establishment and expansion phases.
Timezone Synchronization: Native support for global exchanges to ensure your ranges are captured exactly when the bell rings.

📈 Professional Trading Advice: How to Trade the ORB
The Opening Range (OR) represents the battle between institutional "Big Money" orders and retail reactions. Here is how to trade it professionally:

[b]1. The "Broken Wing" Entry (Breakout)[/b]
The Setup: Wait for a 5-minute candle to close outside the ORH (High) or ORL (Low).
The Logic: A close outside the range indicates that one side (Bulls or Bears) has successfully absorbed the morning’s liquidity.
Stop Loss: Place your stop at the 50% Mid-Point of the OR box. If the price returns to the mid-point after a breakout, the breakout is likely a "fakeout."

[b]2. The "Optimal Trade Entry" (Retest)[/b]
The Setup: Often, the Nikkei or NASDAQ will break out, then pull back before the real move happens.
The Logic: Look for a retracement into the Golden Zone (61.8% or 50%) inside the blue/green/orange box after a breakout has occurred.
The Trade: Enter when price touches the 61.8% level, targeting the 1:2 RR line. This provides a much higher R-multiplied return than chasing the initial break.

[b]3. The "Targeting" Strategy[/b]
1:1 Level: This is "Bread and Butter." Many traders move their stop-loss to Breakeven (BE) once the 1:1 target is hit.
1:2 Level: This is the institutional standard. In a trending market, the 1:2 level is the most common mathematical "gravity point" for the session.
1:3 Level: Only hold for this level if the higher timeframe (1H or 4H) trend aligns with your breakout direction.

[b]4. The Session Synergy Rule[/b]
If Tokyo breaks out to the upside and London also opens with a bullish breakout, the probability of New York continuing that trend is over 70%.
If London breaks out in the opposite direction of Tokyo, expect a "Range Bound" day and focus strictly on the 1:1 targets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb

//@version=6
indicator("Multi-Session ORB Specialist ", overlay = true, max_lines_count = 500, max_boxes_count = 500)

// --- Settings ---
groupT = "Tokyo Session (JST)"
showT  = input.bool(true, "Show Tokyo ORB", group = groupT)
sessT  = input.session("0845-0900", "Tokyo Range Window", group = groupT)
tzT    = input.string("Asia/Tokyo", "Tokyo Timezone", group = groupT)

groupL = "London Session (BST/GMT)"
showL  = input.bool(true, "Show London ORB", group = groupL)
sessL  = input.session("0800-0815", "London Range Window", group = groupL)
tzL    = input.string("Europe/London", "London Timezone", group = groupL)

groupN = "New York Session (EDT/EST)"
showN  = input.bool(true, "Show NY ORB", group = groupN)
sessN  = input.session("0930-0945", "NY Range Window", group = groupN)
tzN    = input.string("America/New_York", "NY Timezone", group = groupN)

groupFeat = "Features"
showFibs  = input.bool(true, "Show Golden Zone (38.2%, 50%, 61.8%)", group = groupFeat)
showRR    = input.bool(true, "Show RR Targets (1:1, 1:2, 1:3)", group = groupFeat)

// Colors
colorT   = input.color(color.new(#5b9cf6, 85), "Tokyo Range Fill", group = "Style")
colorL   = input.color(color.new(#089981, 85), "London Range Fill", group = "Style")
colorN   = input.color(color.new(#fb8c00, 85), "NY Range Fill", group = "Style")
orbColorT = input.color(#5b9cf6, "Tokyo Line", group = "Style")
orbColorL = input.color(#089981, "London Line", group = "Style")
orbColorN = input.color(#fb8c00, "NY Line", group = "Style")

// --- State Management ---
type SessionState
    float h = na
    float l = na
    int startBar = na
    int stopBar = na
    line lineH = na
    line lineL = na
    line lineM = na
    line l382 = na
    line l618 = na
    line[] rrLines
    box bx = na
    label[] labels

// Initialize state
var tokyo  = SessionState.new(rrLines = array.new_line(), labels = array.new_label())
var london = SessionState.new(rrLines = array.new_line(), labels = array.new_label())
var ny     = SessionState.new(rrLines = array.new_line(), labels = array.new_label())

// Logic to check session entry/exit
f_get_status(string sess, string tz) =>
    t = time(timeframe.period, sess, tz)
    inSess = not na(t)
    isNew = inSess and na(t[1])
    isEnd = not inSess and not na(t[1])
    [inSess, isNew, isEnd]

[t_in, t_new, t_end] = f_get_status(sessT, tzT)
[l_in, l_new, l_end] = f_get_status(sessL, tzL)
[n_in, n_new, n_end] = f_get_status(sessN, tzN)

// --- Tokyo Range Capture ---
if showT
    if t_new
        tokyo.h := high, tokyo.l := low, tokyo.startBar := bar_index, tokyo.stopBar := na
    else if t_in
        tokyo.h := math.max(nz(tokyo.h, high), high)
        tokyo.l := math.min(nz(tokyo.l, low), low)
    // Tokyo stops extending when London starts
    if l_new
        tokyo.stopBar := bar_index

// --- London Range Capture ---
if showL
    if l_new
        london.h := high, london.l := low, london.startBar := bar_index, london.stopBar := na
    else if l_in
        london.h := math.max(nz(london.h, high), high)
        london.l := math.min(nz(london.l, low), low)
    // London stops extending when NY starts
    if n_new
        london.stopBar := bar_index

// --- NY Range Capture ---
if showN
    if n_new
        ny.h := high, ny.l := low, ny.startBar := bar_index, ny.stopBar := na
    else if n_in
        ny.h := math.max(nz(ny.h, high), high)
        ny.l := math.min(nz(ny.l, low), low)
    // NY stops extending when Tokyo starts (next day)
    if t_new
        ny.stopBar := bar_index

// --- Drawing Function ---
method draw(SessionState self, color fillCol, color lineCol, string name) =>
    if not na(self.h) and not na(self.l)
        // Cleanup old drawings for the current session to update them
        line.delete(self.lineH), line.delete(self.lineL), line.delete(self.lineM)
        line.delete(self.l382), line.delete(self.l618)
        box.delete(self.bx)
        for ln in self.rrLines
            line.delete(ln)
        array.clear(self.rrLines)
        for lbl in self.labels
            label.delete(lbl)
        array.clear(self.labels)

        x2 = na(self.stopBar) ? bar_index : self.stopBar
        rng = self.h - self.l
        mid = self.h - rng * 0.5
        
        // Base Lines & Box
        self.lineH := line.new(self.startBar, self.h, x2, self.h, color = lineCol, width = 2)
        self.lineL := line.new(self.startBar, self.l, x2, self.l, color = lineCol, width = 2)
        self.bx    := box.new(self.startBar, self.h, x2, self.l, bgcolor = fillCol, border_color = color.new(lineCol, 50))
        
        // Labels
        array.push(self.labels, label.new(x2, self.h, name + " ORH", color = #00000000, textcolor = lineCol, style = label.style_label_left, size = size.small))
        array.push(self.labels, label.new(x2, self.l, name + " ORL", color = #00000000, textcolor = lineCol, style = label.style_label_left, size = size.small))

        if showFibs
            self.lineM := line.new(self.startBar, mid, x2, mid, color = lineCol, style = line.style_dashed)
            self.l382  := line.new(self.startBar, self.h - rng * 0.382, x2, self.h - rng * 0.382, color = color.new(lineCol, 60), style = line.style_dotted)
            self.l618  := line.new(self.startBar, self.h - rng * 0.618, x2, self.h - rng * 0.618, color = color.new(lineCol, 60), style = line.style_dotted)
            array.push(self.labels, label.new(x2, mid, "50%", color = #00000000, textcolor = color.new(lineCol, 40), style = label.style_label_left, size = size.tiny))

        if showRR
            for i = 1 to 3
                tu = self.h + rng * i
                td = self.l - rng * i
                array.push(self.rrLines, line.new(self.startBar, tu, x2, tu, color = color.new(lineCol, 70), style = line.style_dashed))
                array.push(self.rrLines, line.new(self.startBar, td, x2, td, color = color.new(lineCol, 70), style = line.style_dashed))
                array.push(self.labels, label.new(x2, tu, str.tostring(i) + ":1", color = #00000000, textcolor = color.new(lineCol, 40), style = label.style_label_left, size = size.tiny))
                array.push(self.labels, label.new(x2, td, str.tostring(i) + ":1", color = #00000000, textcolor = color.new(lineCol, 40), style = label.style_label_left, size = size.tiny))

// --- Update Visuals ---
if not t_in or t_end
    tokyo.draw(colorT, orbColorT, "TKY")
if not l_in or l_end
    london.draw(colorL, orbColorL, "LDN")
if not n_in or n_end
    ny.draw(colorN, orbColorN, "NY")
````
