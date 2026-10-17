# Open Range Breakout - By Sajan

- url: https://www.tradingview.com/script/Le8Swaqy-Open-Range-Breakout-By-Sajan/
- type: indicator
- pine_id: PUB;696c7fbb019148d8bdec6b4983504e00
- version: 1.0

## Description

This is a specialized Opening Range Breakout indicator tailored for day traders focusing on Crude Oil, Gold, Indices, and Overnight futures markets.

Unlike standard ORB scripts that require manual time inputs every time you switch charts, this indicator comes hardcoded with the exact institutional opening windows for specific asset classes. Furthermore, all times are strictly pegged to New York Time (EST/EDT)—meaning whether you are trading from Canada, London, or Tokyo, the indicator dynamically aligns with the correct NY market hours without requiring manual timezone math.

Key Features
Asset-Specific Fixed Sessions: Pre-configured with the most widely respected opening ranges:

Crude Oil: 7:00 AM (5m) & 9:00 AM (5m)

Gold: 8:00 AM (5m) & 8:20 AM (30m)

Indices (ES/NQ): 8:00 AM (15m) & 9:30 AM (15m & 30m)

Overnight (Globex): 6:00 PM (5m & 15m)

Midpoint Tracking: Automatically plots dashed midpoint lines for each active ORB session to act as dynamic intraday support, resistance, or targets.

Decluttered UI: Toggle specific sessions on or off via the settings menu with a single click. Keep your chart clean by only displaying the exact ranges you are actively trading.

How to Use:
Apply the indicator to your chart and open the settings menu.

Toggle on the asset sessions you are currently trading (e.g., indices at 9:30 AM).

Use the top and bottom borders of the drawn box for breakout entries or stop-loss placements.

Watch the dashed midline for mean-reversion plays or intraday pivots.

(Note: All times are hardcoded to the "America/New_York" timezone to ensure perfect alignment regardless of your local chart settings.)

## Source Code

````pine
//@version=6
indicator("ORB", overlay=true, max_boxes_count=500, max_lines_count=500)

// ============================================================
// GLOBAL
// ============================================================
showBoxes     = input.bool(true, "Show ORB Session Boxes", group="ORB Session Selection")
showMidpoints = input.bool(true, "Show ORB Midpoints",     group="ORB Session Selection")

// ============================================================
// OIL SESSIONS (fixed: 7:00am & 9:00am ET, 5min, end 2:30pm ET)
// ============================================================
enOil1     = input.bool(false, "Enable", group="Oil — 7:00am ET (5min)")
borderOil1 = input.color(color.gray, "Border Color", group="Oil — 7:00am ET (5min)")
fillOil1   = input.color(color.new(color.gray, 85), "Fill Color", group="Oil — 7:00am ET (5min)")

enOil2     = input.bool(false, "Enable", group="Oil — 9:00am ET (5min)")
borderOil2 = input.color(color.navy, "Border Color", group="Oil — 9:00am ET (5min)")
fillOil2   = input.color(color.new(color.navy, 70), "Fill Color", group="Oil — 9:00am ET (5min)")

// ============================================================
// GOLD SESSIONS (fixed: 8:00am (5min) & 8:20am (30min) ET, end 1:30pm ET)
// ============================================================
enGold1     = input.bool(false, "Enable", group="Gold — 8:00am ET (5min)")
borderGold1 = input.color(color.gray, "Border Color", group="Gold — 8:00am ET (5min)")
fillGold1   = input.color(color.new(color.gray, 85), "Fill Color", group="Gold — 8:00am ET (5min)")

enGold2     = input.bool(false, "Enable", group="Gold — 8:20am ET (30min)")
borderGold2 = input.color(color.purple, "Border Color", group="Gold — 8:20am ET (30min)")
fillGold2   = input.color(color.new(color.purple, 80), "Fill Color", group="Gold — 8:20am ET (30min)")

// ============================================================
// INDICES SESSIONS (fixed: 8:00am 15min, 9:30am 30min, 9:30am 15min, end 4:00pm ET)
// ============================================================
enIdx1     = input.bool(false, "Enable", group="Indices — 8:00am ET (15min)")
borderIdx1 = input.color(color.gray, "Border Color", group="Indices — 8:00am ET (15min)")
fillIdx1   = input.color(color.new(color.gray, 85), "Fill Color", group="Indices — 8:00am ET (15min)")

enIdx2     = input.bool(true, "Enable", group="Indices — 9:30am ET (30min)")
borderIdx2 = input.color(color.purple, "Border Color", group="Indices — 9:30am ET (30min)")
fillIdx2   = input.color(color.new(color.purple, 80), "Fill Color", group="Indices — 9:30am ET (30min)")

enIdx3     = input.bool(false, "Enable", group="Indices — 9:30am ET (15min level)")
borderIdx3 = input.color(color.purple, "Border Color", group="Indices — 9:30am ET (15min level)")
fillIdx3   = input.color(color.new(color.purple, 65), "Fill Color", group="Indices — 9:30am ET (15min level)")

// ============================================================
// OVERNIGHT SESSIONS (fixed: 6:00pm 5min & 15min ET, end 3:00am ET)
// ============================================================
enOn1     = input.bool(false, "Enable", group="Overnight — 6:00pm ET (5min)")
borderOn1 = input.color(color.blue, "Border Color", group="Overnight — 6:00pm ET (5min)")
fillOn1   = input.color(color.new(color.blue, 80), "Fill Color", group="Overnight — 6:00pm ET (5min)")

enOn2     = input.bool(false, "Enable", group="Overnight — 6:00pm ET (15min)")
borderOn2 = input.color(color.orange, "Border Color", group="Overnight — 6:00pm ET (15min)")
fillOn2   = input.color(color.new(color.orange, 70), "Fill Color", group="Overnight — 6:00pm ET (15min)")

// ============================================================
// CORE ORB FUNCTION — Using xloc.bar_time to perfectly align with close
// ============================================================
orb_box(enable, captureSession, extendSession, borderColor, fillColor, drawBoxes, showMid) =>
    var box  b   = na
    var line mid = na

    t  = time(timeframe.period, captureSession, "America/New_York")
    te = time(timeframe.period, extendSession,  "America/New_York")
    newC = na(t[1]) and not na(t)

    if enable and drawBoxes
        if newC
            // Initialize with time instead of bar_index, extending to the bar's exact closing time
            b := box.new(time, high, time_close, low, xloc=xloc.bar_time, border_color=borderColor, bgcolor=fillColor, extend=extend.none)
            mid := na
        else if not na(t) and not na(b)
            box.set_top(b, math.max(box.get_top(b), high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))
            box.set_right(b, time_close)
        else if not na(te) and not na(b)
            // Push the right edge to the absolute closing second of the current bar
            box.set_right(b, time_close)
            if showMid
                topv = box.get_top(b)
                botv = box.get_bottom(b)
                midv = (topv + botv) / 2
                if na(mid)
                    mid := line.new(box.get_left(b), midv, time_close, midv, xloc=xloc.bar_time, color=borderColor, style=line.style_dashed)
                else
                    line.set_x2(mid, time_close)

    true

// ============================================================
// RUN ALL SLOTS 
// ============================================================
orb_box(enOil1,  "0700-0705", "0700-1430", borderOil1,  fillOil1,  showBoxes, showMidpoints)
orb_box(enOil2,  "0900-0905", "0900-1430", borderOil2,  fillOil2,  showBoxes, showMidpoints)
orb_box(enGold1, "0800-0805", "0800-1330", borderGold1, fillGold1, showBoxes, showMidpoints)
orb_box(enGold2, "0820-0850", "0820-1330", borderGold2, fillGold2, showBoxes, showMidpoints)
orb_box(enIdx1,  "0800-0815", "0800-1600", borderIdx1,  fillIdx1,  showBoxes, showMidpoints)
orb_box(enIdx2,  "0930-1000", "0930-1600", borderIdx2,  fillIdx2,  showBoxes, showMidpoints)
orb_box(enIdx3,  "0930-0945", "0930-1600", borderIdx3,  fillIdx3,  showBoxes, showMidpoints)
orb_box(enOn1,   "1800-1805", "1800-0300", borderOn1,   fillOn1,   showBoxes, showMidpoints)
orb_box(enOn2,   "1800-1815", "1800-0300", borderOn2,   fillOn2,   showBoxes, showMidpoints)
````
