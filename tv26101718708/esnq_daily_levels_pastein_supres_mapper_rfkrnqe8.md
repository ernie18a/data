# ES/NQ Daily Levels Paste-In Sup/Res Mapper

- url: https://www.tradingview.com/script/rFkRNQE8-ES-NQ-Daily-Levels-Paste-In-Sup-Res-Mapper/
- type: indicator
- pine_id: PUB;3543d5e01846402db67ed12f90662f3b
- version: 2.0

## Description

Daily Levels is a manual, paste-in mapping tool. Paste a list of price levels into the settings and it draws them on your chart as clean lines and shaded zones with labels. It does not calculate signals or repaint — it simply renders the levels you enter.

Works on any symbol — ES, NQ, SPY, SPX, stocks, futures, forex, and crypto. Just paste levels that match that instrument's price.

Leave the box blank and it shows a few sample reference levels around current price (clearly tagged "sample", 10 points apart by default) so you can see how it works on any chart. The samples auto-hide the moment you paste your own levels. (The 10-point default spacing suits ES/NQ; for other instruments set the spacing to fit, or set it to 0 for auto.)

WHAT IT DRAWS
- Single prices → horizontal lines with labels
- Ranges (e.g. 5200-5205) → shaded zones
- Section groups you can label: Resistances, Supports, and special groups (Backtest, Add, Breakdown, Short)
- Tag any level "(major)" and it renders thicker

DYNAMIC S/R FLIP (optional)
When enabled, each level you paste under Supports/Resistances is colored by where price is right now:
- Price above the level → acts as support (green, "S")
- Price below the level → acts as resistance (red, "R")
- Price inside a zone → neutral / in-play (yellow)
Turn it off to keep the exact section labels you pasted.

HOW TO USE
1. Add the indicator to your chart.
2. Open its settings → "PASTE YOUR DAILY LEVELS HERE".
3. Paste your levels, one section per line, for example:
     Resistances: 5210, 5218 (major), 5225-5228
     Supports: 5188, 5175 (major)
4. Lines, zones, and labels draw automatically. Colors, widths, spacing, and label styling are all configurable.

NOTE
The sample levels are auto-generated placeholders for demonstration only — they are not recommended levels and should not be used for trading. This tool does not generate, suggest, or predict levels; it only displays the ones you enter.

For educational purpose

## Source Code

````pine
//@version=6
// ES / NQ Daily Levels — Paste-In Support/Resistance Mapper
// Paste your own price levels in the settings ("PASTE YOUR DAILY LEVELS HERE")
// Last updated: 2026-09-12 (Minor / Major / A+ visibility toggles; A+ takes display precedence)
// A level tagged (major) draws thicker; a level tagged (A+) draws as a top A+
// tier (thicker still + a diamond). This draws them as clean lines/zones. It does NOT
// generate, suggest, or recommend levels — it only displays the ones you enter.
// When left blank it shows a few auto reference levels around current price
// (tagged "sample") so it's never empty — these auto-hide the moment you paste
// your own. For educational purposes only. Not financial advice.
indicator("ES / NQ Daily Levels — Paste-In Support/Resistance Mapper", shorttitle="ES/NQ Daily Levels", overlay=true, max_lines_count=500, max_boxes_count=200, max_labels_count=500)

// Paste your own levels here (in the settings). Leave blank to see auto sample
// reference levels around current price instead (clearly tagged "sample").
levelsText = input.text_area("", "PASTE YOUR DAILY LEVELS HERE")

resColor   = input.color(color.new(color.red,   0), "Resistance color")
supColor   = input.color(color.new(color.green, 0), "Support color")
specColor  = input.color(color.new(color.yellow,0), "Special color")
zoneResBg  = input.color(color.new(color.red,   88), "Resistance zone fill")
zoneSupBg  = input.color(color.new(color.green, 88), "Support zone fill")
zoneSpecBg = input.color(color.new(color.yellow,88), "Special zone fill")
labelBg    = input.color(color.new(color.black, 60), "Label background")
labelText  = input.color(color.white, "Label text color")

// dynamic S/R flip. When on, any level pasted under "Supports" or
// "Resistances" is colored by where PRICE is right now, not by its section:
//   price above the level -> acts as SUPPORT  -> green "S"
//   price below the level -> acts as RESISTANCE-> red   "R"
//   price inside a zone   -> NEUTRAL (yellow), level is in-play
// Special sections (Backtest/Add/Breakdown/Short) are unaffected.
i_flip = input.bool(true, "Flip S/R by price", tooltip="Recolor Support/Resistance levels and zones based on current price. Off = use the pasted section headers as before.")

// Show / hide levels by DISPLAY TIER. Each checkbox owns exactly one group:
//     plain token               -> MINOR  (including auto sample levels)
//     "(major)" without "(A+)"  -> MAJOR
//     anything with "(A+)"      -> A+     (even if it also carries "(major)")
// A+ takes rendering precedence: a level tagged BOTH is an A+ level for display
// and obeys ONLY the A+ checkbox. This does not erase the underlying (major)
// annotation — it is still parsed and still present in the pasted text; it just
// does not control that level's visibility. Consequence, and the point of the
// design: unticking "Show A+ levels" removes EVERY A+ line, and "Show major
// levels" shows the promoted levels that are not A+.
i_showMajor = input.bool(true, "Show major levels", group="Level visibility", tooltip="Show levels tagged (major) that are NOT also tagged (A+). Turn off to hide them.")
i_showMinor = input.bool(true, "Show minor levels", group="Level visibility", tooltip="Show plain levels carrying neither (major) nor (A+), including auto sample levels. Turn off to hide them.")
i_showAplus  = input.bool(true, "Show A+ levels", group="Level visibility", tooltip="Show every level tagged (A+), including ones also tagged (major). Turn Minor and Major off and leave this on to see only your A+ levels; turn this off to remove every A+ line.")
i_aplusWidth = input.int(3, "A+ line width (thicker than major)", minval=1, maxval=8, group="Level visibility")
i_aplusMark  = input.bool(true, "Mark A+ levels with a diamond", group="Level visibility")

// Sample reference levels (shown only when you haven't pasted your own levels)
i_sample      = input.bool(true, "Show sample levels around price", tooltip="Draws a few reference levels above/below current price so the tool isn't blank on any chart. Auto-hides the moment you paste your own levels. Turn off to hide entirely.")
i_sampleCount = input.int(4, "Sample levels per side", minval=1, maxval=10)
i_sampleStep  = input.float(10.0, "Sample spacing (0 = auto)", minval=0.0, tooltip="Points between sample levels. Default 10. Set 0 to auto-pick a round spacing from price.")

// How far the level lines/zones reach. Labels always stay pinned at current price.
i_extendFull    = input.bool(true, "Extend lines fully across chart", tooltip="On = each level runs all the way across the chart (as far back and forward as it goes). Off = extend back only the hours set below. Labels always stay at current price.")
i_lineHoursBack = input.float(3.0, "…or extend back this many hours (when above is off)", minval=0.0, tooltip="Used only when 'Extend lines fully' is off. Hours to the left the lines and zones reach.")
lookbackBars = i_lineHoursBack <= 0 ? 0 : math.max(0, int(i_lineHoursBack * 3600 / timeframe.in_seconds()))
lvlExtend = i_extendFull ? extend.both : extend.right

f_trim(s) => str.trim(s)
f_isMajor(s) => str.contains(str.lower(s), "(major)")
f_isAplus(s) => str.contains(str.lower(s), "(a+)")

f_cleanToken(s) =>
    x = str.replace_all(s, "(major)", "")
    x := str.replace_all(x, "major", "")
    x := str.replace_all(x, "Major", "")
    x := str.replace_all(x, "(a+)", "")
    x := str.replace_all(x, "(A+)", "")
    f_trim(x)

f_parseRange(token) =>
    tok = f_cleanToken(token)
    parts = str.split(tok, "-")
    float lo = na
    float hi = na
    if array.size(parts) == 2
        a = f_trim(array.get(parts, 0))
        b = f_trim(array.get(parts, 1))
        aa = str.tonumber(a)
        bbRaw = str.tonumber(b)
        if not na(aa) and not na(bbRaw)
            bLen = str.length(b)
            aLen = str.length(a)
            prefixLen = math.max(aLen - bLen, 0)
            bb = bbRaw
            if prefixLen > 0
                prefix = str.substring(a, 0, prefixLen)
                bb := str.tonumber(prefix + b)
            hi := math.max(aa, bb)
            lo := math.min(aa, bb)
    [lo, hi]

f_parseNumber(token) =>
    tok = f_cleanToken(token)
    tok := str.replace_all(tok, ",", "")
    str.tonumber(tok)

// Auto-pick a "nice" round spacing (~0.3% of price, snapped to 1/2/5 x 10^n)
f_niceStep(p) =>
    step = 0.0
    if p > 0
        raw = p * 0.003
        mag = math.pow(10, math.floor(math.log10(raw)))
        n = raw / mag
        mult = n < 1.5 ? 1.0 : n < 3.5 ? 2.0 : n < 7.5 ? 5.0 : 10.0
        step := mult * mag
    step

var line[]  gLines  = array.new_line()
var box[]   gBoxes  = array.new_box()
var label[] gLabels = array.new_label()

f_clearAll() =>
    // delete lines
    while array.size(gLines) > 0
        l = array.pop(gLines)
        line.delete(l)

    // delete boxes
    while array.size(gBoxes) > 0
        b = array.pop(gBoxes)
        box.delete(b)

    // delete labels
    while array.size(gLabels) > 0
        lb = array.pop(gLabels)
        label.delete(lb)

f_makeLabel(y, txt) =>
    lb = label.new(bar_index, y, txt, style=label.style_label_right, textcolor=labelText, color=labelBg)
    array.push(gLabels, lb)

f_hline(y, isMaj, isApl, tag, col, sty) =>
    w = isApl ? i_aplusWidth : isMaj ? 2 : 1
    l = line.new(bar_index - lookbackBars, y, bar_index + 1, y, extend=lvlExtend, width=w, style=sty, color=col)
    array.push(gLines, l)
    star = (isApl and i_aplusMark) ? "✦ " : ""
    tier = isApl ? " (A+)" : isMaj ? " (MAJOR)" : ""
    f_makeLabel(y, star + str.tostring(y) + "  " + tag + tier)

f_zone(lo, hi, isMaj, isApl, tag, fillCol) =>
    if not na(lo) and not na(hi)
        top = math.max(lo, hi)
        bot = math.min(lo, hi)
        b = box.new(bar_index - lookbackBars, top, bar_index + 1, bot, extend=lvlExtend, border_width=isApl ? i_aplusWidth : isMaj ? 2 : 1, bgcolor=fillCol, border_color=color.new(color.gray, 0))
        array.push(gBoxes, b)
        mid = (top + bot) / 2.0
        star = (isApl and i_aplusMark) ? "✦ " : ""
        tier = isApl ? " (A+)" : isMaj ? " (MAJOR)" : ""
        f_makeLabel(mid, star + str.tostring(bot) + "-" + str.tostring(top) + "  " + tag + tier)

if barstate.islast
    f_clearAll()

    px = close   // current price used for the S/R flip

    // Sample reference levels around price — only when nothing is pasted.
    // Samples are minor, so they honor the "Show minor levels" toggle.
    if i_sample and i_showMinor and str.length(str.trim(levelsText)) == 0
        sstep = i_sampleStep > 0 ? i_sampleStep : f_niceStep(px)
        if sstep > 0
            fa = math.floor(px / sstep) * sstep + sstep
            fb = math.ceil(px / sstep) * sstep - sstep
            for k = 0 to i_sampleCount - 1
                f_hline(fa + k * sstep, false, false, "R (sample)", resColor, line.style_dotted)
                f_hline(fb - k * sstep, false, false, "S (sample)", supColor, line.style_dotted)

    linesArr = str.split(levelsText, "\n")
    string section = ""

    for i = 0 to array.size(linesArr) - 1
        ln = f_trim(array.get(linesArr, i))
        if str.length(ln) == 0
            continue

        ll = str.lower(ln)
        if str.contains(ll, "resistances")
            section := "res"
        else if str.contains(ll, "supports")
            section := "sup"
        else if str.contains(ll, "backtest")
            section := "backtest"
        else if str.contains(ll, "add")
            section := "add"
        else if str.contains(ll, "breakdown")
            section := "breakdown"
        else if str.contains(ll, "short")
            section := "short"

        content = ln
        if str.contains(ln, ":")
            content := f_trim(array.get(str.split(ln, ":"), 1))

        toks = str.split(content, ",")
        for t = 0 to array.size(toks) - 1
            tok0 = f_trim(array.get(toks, t))
            if str.length(tok0) == 0
                continue

            isMaj = f_isMajor(tok0)
            isApl = f_isAplus(tok0)

            // Skip levels whose display tier is toggled off. A+ takes
            // precedence: any (A+) level obeys ONLY the A+ checkbox, even when
            // it also carries (major). So the three groups are disjoint and
            // each checkbox does exactly what its name says.
            vis = isApl ? i_showAplus : isMaj ? i_showMajor : i_showMinor
            if not vis
                continue

            tag = "LEVEL"
            col = color.gray
            sty = line.style_solid
            fill = color.new(color.gray, 85)

            if section == "res"
                tag := "R"
                col := resColor
                fill := zoneResBg
            else if section == "sup"
                tag := "S"
                col := supColor
                fill := zoneSupBg
            else if section == "backtest"
                tag := "BACKTEST"
                col := specColor
                sty := line.style_dashed
                fill := zoneSpecBg
            else if section == "add"
                tag := "ADD"
                col := specColor
                sty := line.style_dotted
                fill := zoneSpecBg
            else if section == "breakdown"
                tag := "BREAKDOWN"
                col := specColor
                sty := line.style_dashed
                fill := zoneSpecBg
            else if section == "short"
                tag := "SHORT"
                col := specColor
                sty := line.style_solid
                fill := zoneSpecBg

            // dynamic flip applies ONLY to Support/Resistance sections.
            dynamic = i_flip and (section == "res" or section == "sup")

            if str.contains(tok0, "-")
                [lo, hi] = f_parseRange(tok0)
                if dynamic and not na(lo) and not na(hi)
                    ztop = math.max(lo, hi)
                    zbot = math.min(lo, hi)
                    if px > ztop
                        // price above the whole zone -> support
                        tag  := "S"
                        fill := zoneSupBg
                    else if px < zbot
                        // price below the whole zone -> resistance
                        tag  := "R"
                        fill := zoneResBg
                    else
                        // price inside the zone -> neutral / in-play
                        tag  := "NEUTRAL"
                        fill := zoneSpecBg
                f_zone(lo, hi, isMaj, isApl, tag + " ZONE", fill)
            else
                y = f_parseNumber(tok0)
                if not na(y)
                    if dynamic
                        if px >= y
                            // price at or above the level -> support
                            tag := "S"
                            col := supColor
                        else
                            // price below the level -> resistance
                            tag := "R"
                            col := resColor
                    f_hline(y, isMaj, isApl, tag, col, sty)
````
