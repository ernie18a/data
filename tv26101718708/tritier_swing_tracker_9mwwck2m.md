# Tri-Tier Swing Tracker

- url: https://www.tradingview.com/script/9MWWck2m-Tri-Tier-Swing-Tracker/
- type: indicator
- pine_id: PUB;5060160339a44299845c5e820c388186
- version: 1.0

## Description

Tri-Tier Swing Tracker (TTST)

Market structure on one chart, at three scales at once.

Most swing tools show one zig-zag, so you have to keep changing settings to see the trend and the pullbacks together. TTST draws three independent swing layers on the same chart: Minor, Intermediate and Major. You can read short-term rhythm inside the larger structure without switching settings.

━━━ HOW IT WORKS ━━━

Each tier runs its own swing engine built on confirmed pivot highs and pivot lows. A pivot is only accepted once the chosen number of bars has closed to its right.

The engine keeps highs and lows strictly alternating (H, L, H, L):
- A high followed by a lower high is ignored.
- A high followed by a higher high replaces the earlier one. The old line and label are deleted and redrawn from the last anchor to the new extreme.
- A change in direction locks the previous tip in place as the new anchor.

The result is a clean chain of swings with no clusters of same-direction points.

━━━ THE THREE TIERS ━━━

Blue, thin: Minor swings, defaults Left 5 / Right 3
Red, medium: Intermediate swings, defaults Left 13 / Right 5
Green, thick: Major swings, defaults Left 34 / Right 8

Left is how many bars before the pivot must be lower (for a high) or higher (for a low). Right is how many bars after must confirm it. Higher values give fewer, larger swings.

━━━ FEATURES ━━━

- Independent show/hide for each tier
- Separate toggles for lines, H/L labels and the live extension line
- Custom color and line width per tier
- Live dashed "Extend Last" segment from the last confirmed pivot to the current bar
- 8 alert conditions: new high or low pivot for any tier, plus one for each individual tier

━━━ HOW TO USE IT ━━━

- Trend context: when all three tiers make higher highs and higher lows, the structure is aligned. When the Minor tier turns against the Major tier, that's often just a pullback.
- Structure breaks: a break of the most recent Major swing low or high is a stronger signal than a break at the Minor scale.
- Confluence: use levels where several tiers put a pivot near the same price as support/resistance candidates.
- Timeframes: works on any symbol and timeframe. Lower timeframes usually need larger Left/Right values to cut noise.

━━━ IMPORTANT NOTES ━━━

- Confirmation lag: because pivots need Right bars to confirm, a swing point is only drawn that many bars after it happened. Confirmed swing points do not repaint. Alerts fire on confirmation, not at the exact extreme.
- The dashed extension line repaints by design. It follows the current bar and is only there to show the pending leg. Turn it off if you want a fully static chart.
- There is no minimum-percentage move filter. Noise is controlled only through the Left/Right settings.
- This is a charting and analysis tool, not a buy/sell signal generator. It doesn't predict price. Always combine it with your own analysis and risk management.

Feedback and suggestions are welcome in the comments. Moreover you can contact for developments of custom indicators.

## Source Code

````pine
//@version=6
indicator("Tri-Tier Swing Tracker", shorttitle = "TTST", overlay = true,
         max_lines_count = 500, max_labels_count = 500)

var string GRP_S = "── Tier 1  (Minor Swings)"
var string GRP_M = "── Tier 2  (Intermediate Swings)"
var string GRP_L = "── Tier 3  (Major Swings)"
var string GRP_A = "── Alerts"

s_on      = input.bool(true,  title = "Show",        group = GRP_S, inline = "sv")
s_ln      = input.bool(true,  title = "Lines",       group = GRP_S, inline = "sv",
             tooltip = "Toggle the swing lines on/off independently of labels")
s_lb      = input.bool(true,  title = "H/L Labels",  group = GRP_S, inline = "sv")
s_ext     = input.bool(true,  title = "Extend Last", group = GRP_S, inline = "sv",
             tooltip = "Draw a live dashed line from the last confirmed pivot to the current bar (repaints)")
s_lft     = input.int(5,      title = "Left",        group = GRP_S, inline = "sp", minval = 1)
s_rgt     = input.int(3,      title = "Right",       group = GRP_S, inline = "sp", minval = 1,
             tooltip = "Left = bars before the pivot  |  Right = bars after the pivot\nHigher values = fewer, larger swings")
s_clr     = input.color(color.new(#2962FF, 0), title = "Color", group = GRP_S, inline = "ss")
s_wid     = input.int(1,      title = "Width",       group = GRP_S, inline = "ss", minval = 1, maxval = 4)

m_on      = input.bool(true,  title = "Show",        group = GRP_M, inline = "mv")
m_ln      = input.bool(true,  title = "Lines",       group = GRP_M, inline = "mv",
             tooltip = "Toggle the swing lines on/off independently of labels")
m_lb      = input.bool(true,  title = "H/L Labels",  group = GRP_M, inline = "mv")
m_ext     = input.bool(true,  title = "Extend Last", group = GRP_M, inline = "mv")
m_lft     = input.int(13,     title = "Left",        group = GRP_M, inline = "mp", minval = 1)
m_rgt     = input.int(5,      title = "Right",       group = GRP_M, inline = "mp", minval = 1)
m_clr     = input.color(color.new(#FF1744, 0), title = "Color", group = GRP_M, inline = "ms")
m_wid     = input.int(2,      title = "Width",       group = GRP_M, inline = "ms", minval = 1, maxval = 4)

l_on      = input.bool(true,  title = "Show",        group = GRP_L, inline = "lv")
l_ln      = input.bool(true,  title = "Lines",       group = GRP_L, inline = "lv",
             tooltip = "Toggle the swing lines on/off independently of labels")
l_lb      = input.bool(true,  title = "H/L Labels",  group = GRP_L, inline = "lv")
l_ext     = input.bool(true,  title = "Extend Last", group = GRP_L, inline = "lv")
l_lft     = input.int(34,     title = "Left",        group = GRP_L, inline = "lp", minval = 1)
l_rgt     = input.int(8,      title = "Right",       group = GRP_L, inline = "lp", minval = 1)
l_clr     = input.color(color.new(#00C853, 0), title = "Color", group = GRP_L, inline = "ls")
l_wid     = input.int(3,      title = "Width",       group = GRP_L, inline = "ls", minval = 1, maxval = 4)

alertHi   = input.bool(true, title = "Alert — New High Pivot", group = GRP_A)
alertLo   = input.bool(true, title = "Alert — New Low Pivot",  group = GRP_A)

swingTracker(leftBars, rightBars, clr, wid, showLabels, showExt, showTier, showLines) =>

    var float anchorPx = na
    var int   anchorIx = na
    var float tipPx    = na
    var int   tipIx    = na
    var int   tipDir   = 0
    var line  tipLine  = na
    var label tipLabel = na
    var line  liveLine = na

    canDraw = showTier and showLines

    hiPivot = ta.pivothigh(high, leftBars, rightBars)
    loPivot = ta.pivotlow(low,   leftBars, rightBars)
    hasHi   = not na(hiPivot)
    hasLo   = not na(loPivot)
    pivIx   = bar_index - rightBars

    newHi = false
    newLo = false

    if hasHi
        if tipDir == 1
            if hiPivot > tipPx
                if not na(tipLine)
                    line.delete(tipLine)
                if not na(tipLabel)
                    label.delete(tipLabel)
                tipPx := hiPivot
                tipIx := pivIx
                if canDraw and not na(anchorIx)
                    tipLine := line.new(anchorIx, anchorPx, pivIx, hiPivot,
                                 color = clr, width = wid, style = line.style_solid)
                if showTier and showLabels
                    tipLabel := label.new(pivIx, hiPivot, "H",
                                style = label.style_label_down,
                                color = color.new(clr, 70),
                                textcolor = clr, size = size.tiny)
                newHi := true
        else
            anchorPx := tipPx
            anchorIx := tipIx
            tipLine  := na
            tipLabel := na
            tipPx    := hiPivot
            tipIx    := pivIx
            tipDir   := 1
            if canDraw and not na(anchorIx)
                tipLine := line.new(anchorIx, anchorPx, pivIx, hiPivot,
                             color = clr, width = wid, style = line.style_solid)
            if showTier and showLabels
                tipLabel := label.new(pivIx, hiPivot, "H",
                            style = label.style_label_down,
                            color = color.new(clr, 70),
                            textcolor = clr, size = size.tiny)
            newHi := true

    if hasLo
        if tipDir == -1
            if loPivot < tipPx
                if not na(tipLine)
                    line.delete(tipLine)
                if not na(tipLabel)
                    label.delete(tipLabel)
                tipPx := loPivot
                tipIx := pivIx
                if canDraw and not na(anchorIx)
                    tipLine := line.new(anchorIx, anchorPx, pivIx, loPivot,
                                 color = clr, width = wid, style = line.style_solid)
                if showTier and showLabels
                    tipLabel := label.new(pivIx, loPivot, "L",
                                style = label.style_label_up,
                                color = color.new(clr, 70),
                                textcolor = clr, size = size.tiny)
                newLo := true
        else
            anchorPx := tipPx
            anchorIx := tipIx
            tipLine  := na
            tipLabel := na
            tipPx    := loPivot
            tipIx    := pivIx
            tipDir   := -1
            if canDraw and not na(anchorIx)
                tipLine := line.new(anchorIx, anchorPx, pivIx, loPivot,
                             color = clr, width = wid, style = line.style_solid)
            if showTier and showLabels
                tipLabel := label.new(pivIx, loPivot, "L",
                            style = label.style_label_up,
                            color = color.new(clr, 70),
                            textcolor = clr, size = size.tiny)
            newLo := true

    if canDraw and showExt and not na(tipIx) and tipDir != 0
        if not na(liveLine)
            line.delete(liveLine)
        liveTip  = tipDir == 1 ? low : high
        liveLine := line.new(tipIx, tipPx, bar_index, liveTip,
                             color = color.new(clr, 55), width = wid,
                             style = line.style_dashed)
    if not canDraw and not na(liveLine)
        line.delete(liveLine)
        liveLine := na

    [newHi, newLo]

[sHi, sLo] = swingTracker(s_lft, s_rgt, s_clr, s_wid, s_lb, s_ext, s_on, s_ln)
[mHi, mLo] = swingTracker(m_lft, m_rgt, m_clr, m_wid, m_lb, m_ext, m_on, m_ln)
[lHi, lLo] = swingTracker(l_lft, l_rgt, l_clr, l_wid, l_lb, l_ext, l_on, l_ln)

alertcondition(alertHi and (sHi or mHi or lHi),
     title   = "Any Tier — New High Pivot",
     message = "TTST ▲ New HIGH pivot confirmed (any tier)")

alertcondition(alertLo and (sLo or mLo or lLo),
     title   = "Any Tier — New Low Pivot",
     message = "TTST ▼ New LOW pivot confirmed (any tier)")

alertcondition(alertHi and sHi,
     title   = "Tier 1 — New High Pivot",
     message = "TTST ▲ Tier 1 (Minor) — new HIGH pivot confirmed")

alertcondition(alertLo and sLo,
     title   = "Tier 1 — New Low Pivot",
     message = "TTST ▼ Tier 1 (Minor) — new LOW pivot confirmed")

alertcondition(alertHi and mHi,
     title   = "Tier 2 — New High Pivot",
     message = "TTST ▲ Tier 2 (Intermediate) — new HIGH pivot confirmed")

alertcondition(alertLo and mLo,
     title   = "Tier 2 — New Low Pivot",
     message = "TTST ▼ Tier 2 (Intermediate) — new LOW pivot confirmed")

alertcondition(alertHi and lHi,
     title   = "Tier 3 — New High Pivot",
     message = "TTST ▲ Tier 3 (Major) — new HIGH pivot confirmed")

alertcondition(alertLo and lLo,
     title   = "Tier 3 — New Low Pivot",
     message = "TTST ▼ Tier 3 (Major) — new LOW pivot confirmed")
````
