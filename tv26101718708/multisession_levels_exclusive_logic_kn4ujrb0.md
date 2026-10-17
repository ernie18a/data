# Multi-Session Levels (Exclusive Logic)

- url: https://www.tradingview.com/script/kN4Ujrb0-Multi-Session-Levels-Exclusive-Logic/
- type: indicator
- pine_id: PUB;c3ef144964f3410698dd6670d06a8827
- version: 8.0

## Description

[b]Overview[/b]
[b]Multi-Session Levels (Exclusive Logic)[/b] is a specialized technical analysis tool designed for intraday traders who rely on session-based liquidity and reference levels (Highs, Lows, Opens, and Pivots). Unlike standard session indicators that often clutter the chart with overlapping historical data, this script utilizes a custom "Exclusive Display Logic" to ensure that traders only see the most relevant historical context based on the current time of day.

The primary innovation of this script is its context-aware filtering. When a specific market session is active (e.g., London), the script automatically hides that session's own previous day levels to prevent visual "intrusion" or bias. Instead, it projects the locked reference levels of the other major global sessions (Asia and New York) onto the current price action. This allows traders to focus on cross-session liquidity grabs and breakout retests without the distraction of redundant data.

[b]Technical Methodology & Calculations[/b]
The script calculates levels based on the official exchange market hours using native timezones to ensure 100% accuracy regardless of the user's local clock:

[b]Asia[/b] (Tokyo Stock Exchange): 09:00 - 15:00 JST
[b]London[/b] (London Stock Exchange): 08:00 - 16:30 GMT/BST
[b]New York[/b] (New York Stock Exchange): 09:30 - 16:00 EST/EDT

[b]Key Calculations:[/b]

[b]PSH / PSL [/b](Previous Session High/Low): Uses a state-machine tracking algorithm that captures the absolute high and low of the defined session window. Once the session window closes, these values are "locked" and projected forward to the next relevant trading day.
[b]PSO [/b](Previous Session Open): Captures the open price of the very first bar within the session string.
[b]PSP [/b](Previous Session Pivot): Calculated as the Midpoint $(High + Low) / 2$ of the completed session, serving as a critical mean-reversion level.
[b]Current Session Open:[/b] Identifies the real-time opening price of the active session to monitor current-day bias.

[b]How to Use[/b]
[b]Identify Liquidity Pools:[/b] Use the PSH (Previous Session High) and PSL (Previous Session Low) labels to identify where "buy-side" and "sell-side" liquidity may be resting from previous global sessions.
[b]Monitor Cross-Session Breaks:[/b] While trading London, watch how price reacts to the Asia PSH/PSL. A break and retest of these levels often signals a trend continuation or a fake-out (liquidity sweep).
[b]Pivot Midpoints:[/b] Use the PSP (Dashed line) as a value area. Price trading above the PSP generally indicates a bullish session bias, while trading below indicates a bearish bias.
Customization: Use the "Visibility" toggles in the settings to isolate specific levels (like just the Open or just the High/Low) depending on your specific trading strategy.

[b]Settings[/b]
[b]Market Hours: [/b]Users can refine the session strings if they wish to track "Pre-market" or "Electronic Trading Hours" instead of official exchange hours.
Visibility: Toggle PSH, PSL, PSP, and PSO individually.
Styling: Full control over session colors to match your chart theme.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb





//@version=6
indicator("Multi-Session Levels ( Exclusive Logic )", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// --- Market Hours (Official New York EST/EDT Time) ---
G_MKT = "Market Hours (EST/EDT Time)"
asiaSessInput    = input.session("1800-0300", "Asia / Globex Session", group = G_MKT, tooltip = "US Futures Overnight liquidity (EST).")
tokyoSessInput   = input.session("2000-0100", "Tokyo (TSE) Session", group = G_MKT, tooltip = "Official TSE hours in EST (09:00-15:00 JST).")
londonSessInput  = input.session("0300-0930", "London Session", group = G_MKT)
nySessInput      = input.session("0930-1600", "NY Session (RTH)", group = G_MKT)

G_TZ = "Session Timezone"
globalTzInput    = input.string("America/New_York", "Base Timezone", group = G_TZ)

// --- INDEPENDENT VISIBILITY SETTINGS (24 Toggles) ---

// ASIA / GLOBEX
G_ASIA_V = "Asia/Globex - Visibility"
asiaCol          = input.color(#5b9cf6, "Asia Color Theme", group = G_ASIA_V)
showAsiaHigh     = input.bool(true, "Prev High", group = G_ASIA_V, inline = "A1")
showAsiaLow      = input.bool(true, "Prev Low", group = G_ASIA_V, inline = "A1")
showAsiaPivot    = input.bool(true, "Prev Pivot", group = G_ASIA_V, inline = "A2")
showAsiaOpen     = input.bool(true, "Prev Open", group = G_ASIA_V, inline = "A2")
showAsiaClose    = input.bool(true, "Prev Close", group = G_ASIA_V, inline = "A3")
showAsiaCurOpen  = input.bool(true, "Current Open", group = G_ASIA_V, inline = "A3")

// TOKYO (TSE)
G_TKY_V = "Tokyo (TSE) - Visibility"
tokyoCol         = input.color(#9c27b0, "Tokyo Color Theme", group = G_TKY_V)
showTkyHigh      = input.bool(true, "Prev High", group = G_TKY_V, inline = "T1")
showTkyLow       = input.bool(true, "Prev Low", group = G_TKY_V, inline = "T1")
showTkyPivot     = input.bool(true, "Prev Pivot", group = G_TKY_V, inline = "T2")
showTkyOpen      = input.bool(true, "Prev Open", group = G_TKY_V, inline = "T2")
showTkyClose     = input.bool(true, "Prev Close", group = G_TKY_V, inline = "T3")
showTkyCurOpen   = input.bool(true, "Current Open", group = G_TKY_V, inline = "T3")

// LONDON
G_LDN_V = "London - Visibility"
londonCol        = input.color(#089981, "London Color Theme", group = G_LDN_V)
showLdnHigh      = input.bool(true, "Prev High", group = G_LDN_V, inline = "L1")
showLdnLow       = input.bool(true, "Prev Low", group = G_LDN_V, inline = "L1")
showLdnPivot     = input.bool(true, "Prev Pivot", group = G_LDN_V, inline = "L2")
showLdnOpen      = input.bool(true, "Prev Open", group = G_LDN_V, inline = "L2")
showLdnClose     = input.bool(true, "Prev Close", group = G_LDN_V, inline = "L3")
showLdnCurOpen   = input.bool(true, "Current Open", group = G_LDN_V, inline = "L3")

// NEW YORK
G_NY_V = "New York - Visibility"
nyCol            = input.color(#f23645, "NY Color Theme", group = G_NY_V)
showNyHigh       = input.bool(true, "Prev High", group = G_NY_V, inline = "N1")
showNyLow        = input.bool(true, "Prev Low", group = G_NY_V, inline = "N1")
showNyPivot      = input.bool(true, "Prev Pivot", group = G_NY_V, inline = "N2")
showNyOpen       = input.bool(true, "Prev Open", group = G_NY_V, inline = "N2")
showNyClose      = input.bool(true, "Prev Close", group = G_NY_V, inline = "N3")
showNyCurOpen    = input.bool(true, "Current Open", group = G_NY_V, inline = "N3")

// --- Global Design Settings ---
G_STYLE = "Line Styles (Global Design)"
styleH = input.string("Dotted", "High Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
styleL = input.string("Dotted", "Low Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
styleP = input.string("Dashed", "Pivot Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
styleO = input.string("Dotted", "Open Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
styleC = input.string("Dotted", "Close Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
styleCO = input.string("Dotted", "Current Open Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)
lineWidth = input.int(2, "Global Line Width", minval = 1, maxval = 5, group = G_STYLE)

// --- Text Customization ---
G_TEXT = "Text Customization"
asiaName    = input.string("Asia", "Asia Session Name", group = G_TEXT)
tokyoName   = input.string("Tokyo", "Tokyo Session Name", group = G_TEXT)
londonName  = input.string("London", "London Session Name", group = G_TEXT)
nyName      = input.string("NY", "NY Session Name", group = G_TEXT)
pshLabel    = input.string("Previous Session High", "High Label", group = G_TEXT)
pslLabel    = input.string("Previous Session Low", "Low Label", group = G_TEXT)
pspLabel    = input.string("Previous Session Pivot", "Pivot Label", group = G_TEXT)
psoLabel    = input.string("Previous Session Open", "Open Label", group = G_TEXT)
pscLabel    = input.string("Previous Session Close", "Close Label", group = G_TEXT)
csoLabel    = input.string("Current Session Open", "Current Open Label", group = G_TEXT)

// --- Logic ---
is_in_sess(sess, tz) => not na(time(timeframe.period, sess, tz))
get_style(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// Session Tracking Function
track_session(sess, tz) =>
    bool inS = is_in_sess(sess, tz)
    bool st  = inS and not (inS[1] == true)
    bool en  = not inS and (inS[1] == true)
    var float cH = na, var float cL = na, var float cO = na, var float cC = na
    var float pH = na, var float pL = na, var float pO = na, var float pC = na
    var int idx = na
    if st
        cH := high, cL := low, cO := open, idx := bar_index
    else if inS
        cH := math.max(nz(cH, high), high)
        cL := math.min(nz(cL, low), low)
        cC := close
    if en
        pH := cH, pL := cL, pO := cO, pC := cC
        cH := na, cL := na, cO := na, cC := na
    [pH, pL, pO, pC, cO, idx, inS]

[aPH, aPL, aPO, aPC, aCurO, aIdx, inA] = track_session(asiaSessInput, globalTzInput)
[tPH, tPL, tPO, tPC, tCurO, tIdx, inT] = track_session(tokyoSessInput, globalTzInput)
[lPH, lPL, lPO, lPC, lCurO, lIdx, inL] = track_session(londonSessInput, globalTzInput)
[nPH, nPL, nPO, nPC, nCurO, nIdx, inN] = track_session(nySessInput, globalTzInput)

// --- Drawing Implementation ---
draw_levels(float ph, float pl, float po, float pc, float co, int idx, color col, string name, bool active, bool vH, bool vL, bool vP, bool vO, bool vC, bool vCO) =>
    var line hL = na, var line lL = na, var line pL_ = na, var line oL = na, var line cL = na, var line coL = na
    var label hT = na, var label lT = na, var label pT = na, var label oT = na, var label cT = na, var label coT = na
    
    line.delete(hL), line.delete(lL), line.delete(pL_), line.delete(oL), line.delete(cL), line.delete(coL)
    label.delete(hT), label.delete(lT), label.delete(pT), label.delete(oT), label.delete(cT), label.delete(coT)
    
    // Previous Levels: Hide ONLY when this specific session is active
    if not active and not na(ph)
        x1 = bar_index - 50, x2 = bar_index
        if vH
            hL := line.new(x1, ph, x2, ph, color = col, style = get_style(styleH), width = lineWidth)
            hT := label.new(x2, ph, name + " " + pshLabel + " (" + str.tostring(ph, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)
        if vL
            lL := line.new(x1, pl, x2, pl, color = col, style = get_style(styleL), width = lineWidth)
            lT := label.new(x2, pl, name + " " + pslLabel + " (" + str.tostring(pl, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)
        if vP
            pL_ := line.new(x1, (ph+pl)/2, x2, (ph+pl)/2, color = col, style = get_style(styleP), width = lineWidth)
            pT := label.new(x2, (ph+pl)/2, name + " " + pspLabel + " (" + str.tostring((ph+pl)/2, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)
        if vO
            oL := line.new(x1, po, x2, po, color = col, style = get_style(styleO), width = lineWidth)
            oT := label.new(x2, po, name + " " + psoLabel + " (" + str.tostring(po, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)
        if vC
            cL := line.new(x1, pc, x2, pc, color = col, style = get_style(styleC), width = lineWidth)
            cT := label.new(x2, pc, name + " " + pscLabel + " (" + str.tostring(pc, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)
            
    // Current Open: Show only when active
    if active and vCO and not na(co)
        coL := line.new(idx, co, bar_index, co, color = col, style = get_style(styleCO), width = lineWidth)
        coT := label.new(bar_index, co, name + " " + csoLabel + " (" + str.tostring(co, format.mintick) + ")", color = #00000000, textcolor = col, style = label.style_label_left, size = size.small)

if barstate.islast
    draw_levels(aPH, aPL, aPO, aPC, aCurO, aIdx, asiaCol, asiaName, inA, showAsiaHigh, showAsiaLow, showAsiaPivot, showAsiaOpen, showAsiaClose, showAsiaCurOpen)
    draw_levels(tPH, tPL, tPO, tPC, tCurO, tIdx, tokyoCol, tokyoName, inT, showTkyHigh, showTkyLow, showTkyPivot, showTkyOpen, showTkyClose, showTkyCurOpen)
    draw_levels(lPH, lPL, lPO, lPC, lCurO, lIdx, londonCol, londonName, inL, showLdnHigh, showLdnLow, showLdnPivot, showLdnOpen, showLdnClose, showLdnCurOpen)
    draw_levels(nPH, nPL, nPO, nPC, nCurO, nIdx, nyCol, nyName, inN, showNyHigh, showNyLow, showNyPivot, showNyOpen, showNyClose, showNyCurOpen)
````
