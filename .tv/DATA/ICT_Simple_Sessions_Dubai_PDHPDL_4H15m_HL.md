<!-- tradingview-pine-id: PUB;42c298e3dbdb4c3086cb0600130a21fe -->
<!-- tradingviewscripts-format: 1 -->
# ICT Simple - Sessions (Dubai) + PDH/PDL + 4H/15m HL

Source: https://www.tradingview.com/script/UxC1ycyn-ICT-Simple-Sessions-Dubai-PDH-PDL-4H-15m-HL/

## Description

ICT Simple - Sessions (Dubai) + PDH/PDL + 4H/15m HL

---

## Source Code

````pine
//@version=6
indicator("ICT Simple - Sessions (Dubai) + PDH/PDL + 4H/15m HL", shorttitle="ICT Simple DXB", overlay=true, max_lines_count=200, max_labels_count=200)

// ══════════════════════════════════════════════════════════════════
// █ INPUTS
// ══════════════════════════════════════════════════════════════════

grpGen = "General"
i_tz = input.string("Asia/Dubai", "Timezone", group=grpGen)
i_style = input.string("Dashed", "Level Line Style", options=["Solid","Dashed","Dotted"], group=grpGen)
i_width = input.int(1, "Level Line Width", minval=1, maxval=4, group=grpGen)
i_showLabels = input.bool(true, "Show Labels", group=grpGen)
i_mergeTicks = input.int(5, "Merge Labels Within (ticks)", minval=0, group=grpGen, tooltip="If two or more levels land within this many ticks of each other, they're combined into a single label separated by '/'.")

grpSess = "Session Ranges (Dubai Time)"
i_showAsia   = input.bool(true, "Show Asia (4:00 AM - 1:00 PM)", group=grpSess)
i_asiaTime   = input.session("0400-1300", "Asia Session", group=grpSess)
i_asiaCol    = input.color(color.new(#2962ff, 0), "Asia Line Color", group=grpSess)

i_showLondon = input.bool(true, "Show London (11:00 AM - 8:00 PM)", group=grpSess)
i_londonTime = input.session("1100-2000", "London Session", group=grpSess)
i_londonCol  = input.color(color.new(#00c853, 0), "London Line Color", group=grpSess)

i_showNY     = input.bool(true, "Show New York (5:30 PM - 12:00 AM)", group=grpSess)
i_nyTime     = input.session("1730-0000", "New York Session", group=grpSess)
i_nyCol      = input.color(color.new(#ff6d00, 0), "NY Line Color", group=grpSess)

grpPrev = "Previous Day High/Low"
i_showPDHL = input.bool(true, "Show PDH / PDL", group=grpPrev)
i_pdCol    = input.color(color.new(#787b86, 0), "PDH/PDL Color", group=grpPrev)

grp4H = "4H High/Low"
i_show4H = input.bool(true, "Show 4H High/Low", group=grp4H)
i_col4H  = input.color(color.new(#aa00ff, 0), "4H Color", group=grp4H)

grp15 = "15m High/Low"
i_show15 = input.bool(true, "Show 15m High/Low", group=grp15)
i_col15  = input.color(color.new(#d50000, 0), "15m Color", group=grp15)

// ══════════════════════════════════════════════════════════════════
// █ HELPERS
// ══════════════════════════════════════════════════════════════════

f_lineStyle(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// Draws the previous, already-closed higher-timeframe candle's high/low as
// a single extending line, refreshed every time a new HTF candle opens (the
// old line is deleted first, so only the latest level is ever shown).
// Labels are NOT drawn here — they're collected centrally below so
// overlapping levels can be merged into one label.
f_htfLevel(bool show, string tf, bool isHigh, color col) =>
    var line  lvlLine  = na
    var float lvlPrice = na

    [tfH, tfL, tfT] = request.security(syminfo.tickerid, tf, [high[1], low[1], time], lookahead=barmerge.lookahead_off)
    newPeriod = ta.change(tfT) != 0
    price = isHigh ? tfH : tfL

    if show
        if newPeriod and not na(price)
            if not na(lvlLine)
                line.delete(lvlLine)
            lvlPrice := price
            lvlLine := line.new(bar_index, lvlPrice, bar_index, lvlPrice, color=col, style=f_lineStyle(i_style), width=i_width)
        else if not na(lvlLine)
            line.set_x2(lvlLine, bar_index)
    lvlPrice

// Tracks a session's high/low as two plain colored lines (no box, no
// labels here). While the session is active the lines follow the running
// high/low; once it closes they freeze and extend right until the next
// session begins, at which point the old pair is deleted and replaced.
f_session(bool show, string sess, string tz, color col) =>
    var line  hiLine = na
    var line  loLine = na
    var float sHi    = na
    var float sLo    = na

    t = time(timeframe.period, sess, tz)
    isIn = not na(t)

    if show
        if isIn and not isIn[1]
            if not na(hiLine)
                line.delete(hiLine)
                line.delete(loLine)
            sHi := high
            sLo := low
            hiLine := line.new(bar_index, sHi, bar_index, sHi, color=col, style=f_lineStyle(i_style), width=i_width)
            loLine := line.new(bar_index, sLo, bar_index, sLo, color=col, style=f_lineStyle(i_style), width=i_width)
        else if isIn
            sHi := math.max(sHi, high)
            sLo := math.min(sLo, low)
            line.set_y1(hiLine, sHi)
            line.set_y2(hiLine, sHi)
            line.set_x2(hiLine, bar_index)
            line.set_y1(loLine, sLo)
            line.set_y2(loLine, sLo)
            line.set_x2(loLine, bar_index)
        else if not na(hiLine)
            line.set_x2(hiLine, bar_index)
            line.set_x2(loLine, bar_index)
    [sHi, sLo, isIn]

// ══════════════════════════════════════════════════════════════════
// █ SESSIONS
// ══════════════════════════════════════════════════════════════════

[asiaHi, asiaLo, inAsia]       = f_session(i_showAsia,   i_asiaTime,   i_tz, i_asiaCol)
[londonHi, londonLo, inLondon] = f_session(i_showLondon, i_londonTime, i_tz, i_londonCol)
[nyHi, nyLo, inNY]             = f_session(i_showNY,     i_nyTime,     i_tz, i_nyCol)

// ══════════════════════════════════════════════════════════════════
// █ PREVIOUS DAY / 4H / 15m LEVELS
// ══════════════════════════════════════════════════════════════════

pdh = f_htfLevel(i_showPDHL, "D", true,  i_pdCol)
pdl = f_htfLevel(i_showPDHL, "D", false, i_pdCol)

h4  = f_htfLevel(i_show4H, "240", true,  i_col4H)
l4  = f_htfLevel(i_show4H, "240", false, i_col4H)

h15 = f_htfLevel(i_show15, "15", true,  i_col15)
l15 = f_htfLevel(i_show15, "15", false, i_col15)

// ══════════════════════════════════════════════════════════════════
// █ MERGED LABELS — combine any levels sharing (or near) the same price
// ══════════════════════════════════════════════════════════════════

var label[] labelPool = array.new<label>()

if i_showLabels
    for lbl in labelPool
        label.delete(lbl)
    array.clear(labelPool)

    prices = array.new<float>()
    texts  = array.new<string>()
    cols   = array.new<color>()

    if i_showAsia and not na(asiaHi)
        array.push(prices, asiaHi), array.push(texts, "Asia H"), array.push(cols, i_asiaCol)
    if i_showAsia and not na(asiaLo)
        array.push(prices, asiaLo), array.push(texts, "Asia L"), array.push(cols, i_asiaCol)
    if i_showLondon and not na(londonHi)
        array.push(prices, londonHi), array.push(texts, "London H"), array.push(cols, i_londonCol)
    if i_showLondon and not na(londonLo)
        array.push(prices, londonLo), array.push(texts, "London L"), array.push(cols, i_londonCol)
    if i_showNY and not na(nyHi)
        array.push(prices, nyHi), array.push(texts, "NY H"), array.push(cols, i_nyCol)
    if i_showNY and not na(nyLo)
        array.push(prices, nyLo), array.push(texts, "NY L"), array.push(cols, i_nyCol)
    if i_showPDHL and not na(pdh)
        array.push(prices, pdh), array.push(texts, "PDH"), array.push(cols, i_pdCol)
    if i_showPDHL and not na(pdl)
        array.push(prices, pdl), array.push(texts, "PDL"), array.push(cols, i_pdCol)
    if i_show4H and not na(h4)
        array.push(prices, h4), array.push(texts, "4H H"), array.push(cols, i_col4H)
    if i_show4H and not na(l4)
        array.push(prices, l4), array.push(texts, "4H L"), array.push(cols, i_col4H)
    if i_show15 and not na(h15)
        array.push(prices, h15), array.push(texts, "15m H"), array.push(cols, i_col15)
    if i_show15 and not na(l15)
        array.push(prices, l15), array.push(texts, "15m L"), array.push(cols, i_col15)

    n = array.size(prices)
    if n > 0
        order = array.sort_indices(prices, order.ascending)
        tol = i_mergeTicks * syminfo.mintick
        i = 0
        while i < n
            srcIdx = array.get(order, i)
            groupPrice = array.get(prices, srcIdx)
            groupColor = array.get(cols, srcIdx)
            parts = array.new<string>()
            array.push(parts, array.get(texts, srcIdx))
            j = i + 1
            while j < n and (array.get(prices, array.get(order, j)) - groupPrice) <= tol
                array.push(parts, array.get(texts, array.get(order, j)))
                j += 1
            mergedText = array.join(parts, " / ")
            newLbl = label.new(bar_index, groupPrice, mergedText, style=label.style_label_left, color=color.new(groupColor, 100), textcolor=groupColor, size=size.small)
            array.push(labelPool, newLbl)
            i := j
````
