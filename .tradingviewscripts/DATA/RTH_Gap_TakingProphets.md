<!-- tradingview-pine-id: PUB;554dd86f91d84c1ca4e9abfd1c77d319 -->
<!-- tradingviewscripts-format: 1 -->
# RTH Gap [TakingProphets]

Source: https://www.tradingview.com/script/dPu4PEyP-RTH-Gap-TakingProphets/

## Description

OVERVIEW

RTH Gap [TakingProphets] marks the Opening Range Gap: the gap between the prior regular-session close and the next regular-session open.

It measures from the prior RTH close at 4:14 PM New York time to the next RTH open at 9:30 AM New York time, draws that range as a box, and overlays quadrant levels at 0, 25, 50, 75, and 100 percent.

This indicator does not provide trading signals, entries, or forecasts. It is a visualization aid for studying the Opening Range Gap within an ICT-style analytical framework.

The Opening Range Gap (ORG) is the space between where the regular session closed and where it reopened the next day. Within ICT-style education, this gap and its internal quadrants, especially the 50 percent midpoint, are studied for how price reacts when it trades back into them. This tool marks the gap and its quadrants automatically so they can be reviewed objectively rather than drawn by hand.

PURPOSE AND SCOPE
-----------------------------------------------------------------------------------------------

The tool serves as a research and study aid to document and analyze the Opening Range Gap and its internal levels.

It is commonly used to:

Automate the marking of the daily RTH gap and its quadrants.

Study how price reacts at the 50 percent midpoint and the other quadrant levels.

Keep several prior gaps on the chart for multi-day review.

Journal how often a gap is filled, respected, or rejected.

Teach the Opening Range Gap concept in a mentorship or training context.

LOGIC STRUCTURE
-----------------------------------------------------------------------------------------------

RTH Gap detects the gap on the 1-minute series and displays it consistently on any chart timeframe.

Detection

The prior RTH close is captured at 4:14 PM New York time.

The next RTH open is captured at 9:30 AM New York time.

The gap between those two prices becomes the range for that session.

Detection runs on the 1-minute series and its values are latched, so the gap displays correctly whether the chart is on a low or high timeframe.

Quadrants

The gap is drawn as a box, with horizontal levels at 0, 25, 50, 75, and 100 percent of the range.

Each level can be toggled, colored, and styled independently, and optionally labeled with its percentage and formation date.

Selection and Retention

The number of gaps shown is user controlled.

Gaps can be selected either by how recently they formed or by proximity of their midpoint to current price.

An IPDA lookback setting controls how far back gaps are retained before being pruned.

COMPONENTS AND VISUALS
-----------------------------------------------------------------------------------------------

Gap Box — The range between the prior RTH close and the next RTH open.

Quadrant Levels — Horizontal lines at 0, 25, 50, 75, and 100 percent of the gap.

Quadrant Labels — Optional labels showing each level's percentage and, if enabled, the gap's formation date.

INPUT CATEGORIES
-----------------------------------------------------------------------------------------------

General — Enable toggle, IPDA lookback length, date-prefix and quadrant-label toggles, and the selection mode (Most recent or Proximity).

Opening Range Gaps — Master visibility and how many gaps to display.

Opening Range Gap Style — Box color, fill and border options, gradient toggle, label color and size, and independent visibility, color, style, and width for each of the five quadrant levels.

USAGE GUIDELINES
-----------------------------------------------------------------------------------------------

RTH Gap is suited for the review and documentation of Opening Range Gap behavior.

Recommended educational workflows:

Mark the daily RTH gap and review how price interacts with its 50 percent midpoint.

Keep two or three prior gaps on the chart to study multi-day reactions.

Compare gaps that fill quickly against those that hold as support or resistance.

Switch between Most recent and Proximity modes depending on the study.

Teach the Opening Range Gap concept in mentorship or training sessions.

The tool is oriented toward regular-session index futures, where the RTH gap is most applicable.

OPERATIONAL NOTES AND LIMITATIONS
-----------------------------------------------------------------------------------------------

Detection is based on the 4:14 PM and 9:30 AM New York session times and is oriented toward regular-session instruments.

Gap values are latched from the 1-minute series so they display on any chart timeframe.

The selection mode and display count control which gaps appear, not how many are detected.

The IPDA lookback setting controls how far back gaps are retained.

The box, quadrant lines, and labels are visual study aids only.

This tool does not include setups, entries, targets, or alerts.

ORIGINALITY AND ATTRIBUTION
-----------------------------------------------------------------------------------------------

The detection and rendering engine is written from scratch in Pine v6, using a latched 1-minute session-time detector so the gap displays on any timeframe, a quadrant gradient system with per-level styling, two selection modes, and a lookback-based retention system.

Core concepts such as the Opening Range Gap and its quadrant levels are publicly taught within ICT-style market education. This implementation was designed and engineered by TakingProphets.

TERMS AND DISCLAIMER
-----------------------------------------------------------------------------------------------

This indicator is for educational and informational use only. It does not provide financial advice or predictive output. Historical patterns do not guarantee future results. All users remain responsible for their own decisions. Use of this script implies agreement with TradingView's Terms of Use.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TakingProphets
//
// RTH Gap
// Opening Range Gap from ICT Gradients: the gap between the prior RTH close (4:14 PM NY)
// and the next RTH open (9:30 AM NY), with quadrant gradients.
//
// Detection runs on the 1-minute series. Gap values are latched inside request.security so
// every chart timeframe sees them (the one-bar orgNew flag alone is lost on HTF charts).

//@version=6
indicator("RTH Gap [TakingProphets]", "RTH Gap [TakingProphets]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
var string G_GEN   = "General"
var string G_SRC   = "Opening Range Gaps"
var string G_STYLE = "Opening Range Gap Style"

enabled = input.bool(true, "Enable", group=G_GEN)
ipdaLookbackDaysOpt = input.string("180", "IPDA lookback (days)", options=["180", "120", "60", "40", "20"], group=G_GEN)
labelShowDate = input.bool(true, "Show date", group=G_GEN, inline="lbl", tooltip="Prefixes the gap's formation date (M/D) to the labels. Example: 2/17 RTH Gap 50%")
orgShowGradientLabels = input.bool(true, "Labels", group=G_GEN, inline="lbl", tooltip="Show quadrant labels (0% / 25% / 50% / 75% / 100%) on each RTH gap.")
selectionMode = input.string("Most recent", "Mode", options=["Proximity", "Most recent"], group=G_GEN, tooltip="Proximity: show gaps selected by proximity to their 50% (mid) level.\nMost recent: show the N most recently created gaps.")

showORG = input.bool(true, "Opening Range Gaps (ORG)", group=G_SRC, inline="src1")
orgVisibleOpt = input.string("3", "", options=["1", "2", "3"], group=G_SRC, inline="src1", tooltip="How many RTH gaps to display. Selection is controlled by Mode (Proximity to 50% mid, or Most recent created).")

orgBoxColor = input.color(color.new(color.red, 0), "Box", group=G_STYLE, inline="org_box")
orgRemoveFill = input.bool(false, "No fill", group=G_STYLE, inline="org_box")
orgShowBorder = input.bool(false, "Border", group=G_STYLE, inline="org_box")
orgShowGradients = input.bool(true, "Gradients", group=G_STYLE, inline="org_grad")
orgLabelColor = input.color(color.new(color.red, 0), "Label", group=G_STYLE, inline="org_grad")
orgLabelSizeSetting = input.string("Tiny", "", options=["Tiny", "Small", "Normal", "Large"], group=G_STYLE, inline="org_grad", display=display.none)
org_q0_show   = input.bool(true, "0%",   group=G_STYLE, inline="orgQ0")
org_q0_color  = input.color(color.new(color.red, 0), "", group=G_STYLE, inline="orgQ0")
org_q0_style  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=G_STYLE, inline="orgQ0", display=display.none)
org_q0_widthS = input.string("Thin", "", options=["Thin", "Medium", "Thick"], group=G_STYLE, inline="orgQ0", display=display.none)
org_q25_show   = input.bool(true, "25%", group=G_STYLE, inline="orgQ25")
org_q25_color  = input.color(color.new(color.red, 0), "", group=G_STYLE, inline="orgQ25")
org_q25_style  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=G_STYLE, inline="orgQ25", display=display.none)
org_q25_widthS = input.string("Thin", "", options=["Thin", "Medium", "Thick"], group=G_STYLE, inline="orgQ25", display=display.none)
org_q50_show   = input.bool(true, "50%", group=G_STYLE, inline="orgQ50")
org_q50_color  = input.color(color.new(color.red, 0), "", group=G_STYLE, inline="orgQ50")
org_q50_style  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=G_STYLE, inline="orgQ50", display=display.none)
org_q50_widthS = input.string("Thin", "", options=["Thin", "Medium", "Thick"], group=G_STYLE, inline="orgQ50", display=display.none)
org_q75_show   = input.bool(true, "75%", group=G_STYLE, inline="orgQ75")
org_q75_color  = input.color(color.new(color.red, 0), "", group=G_STYLE, inline="orgQ75")
org_q75_style  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=G_STYLE, inline="orgQ75", display=display.none)
org_q75_widthS = input.string("Thin", "", options=["Thin", "Medium", "Thick"], group=G_STYLE, inline="orgQ75", display=display.none)
org_q100_show   = input.bool(true, "100%", group=G_STYLE, inline="orgQ100")
org_q100_color  = input.color(color.new(color.red, 0), "", group=G_STYLE, inline="orgQ100")
org_q100_style  = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], group=G_STYLE, inline="orgQ100", display=display.none)
org_q100_widthS = input.string("Thin", "", options=["Thin", "Medium", "Thick"], group=G_STYLE, inline="orgQ100", display=display.none)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_q_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Solid" => line.style_solid
        => line.style_dotted

f_w(string s) =>
    switch s
        "Medium" => 2
        "Thick" => 3
        => 1

f_label_size(string s) =>
    switch s
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.tiny

org_q0_w = f_w(org_q0_widthS)
org_q25_w = f_w(org_q25_widthS)
org_q50_w = f_w(org_q50_widthS)
org_q75_w = f_w(org_q75_widthS)
org_q100_w = f_w(org_q100_widthS)

f_upd_hline(line ln, int x1, int x2, float y, bool want, color c, string st, int w) =>
    line out = ln
    if want
        if na(out)
            out := line.new(x1=x1, y1=y, x2=x2, y2=y, xloc=xloc.bar_time, extend=extend.none, color=c, style=f_q_style(st), width=w)
        else
            line.set_x1(out, x1), line.set_x2(out, x2), line.set_y1(out, y), line.set_y2(out, y)
            line.set_color(out, c), line.set_style(out, f_q_style(st)), line.set_width(out, w)
    else
        if not na(out)
            line.delete(out)
            out := na
    out

f_upd_qlabel(label lb, int x, float y, bool want, string txt, color c, sz) =>
    label out = lb
    if want
        if na(out)
            out := label.new(x=x, y=y, xloc=xloc.bar_time, text=txt, style=label.style_label_left, textcolor=c, color=color.new(c, 100), size=sz)
        else
            label.set_x(out, x), label.set_y(out, y), label.set_text(out, txt)
            label.set_textcolor(out, c), label.set_color(out, color.new(c, 100)), label.set_size(out, sz)
    else
        if not na(out)
            label.delete(out)
            out := na
    out

f_grad(float top, float bot, float pct) =>
    bot + (top - bot) * pct

f_md(int t) =>
    str.tostring(month(t, "America/New_York")) + "/" + str.tostring(dayofmonth(t, "America/New_York"))

padMs(bars) =>
    tfSec = timeframe.in_seconds()
    na(tfSec) ? 0 : int(math.round(bars * (tfSec * 1000)))

const float INTERNAL_EXTEND_BARS = 15.0
bool snapshotSafeNoDelete = barstate.islast and not barstate.isrealtime

f_ipda_lookback_days(string s) =>
    s == "120" ? 120 :
     s == "60" ? 60 :
     s == "40" ? 40 :
     s == "20" ? 20 :
     180

int ipdaLookbackDays = f_ipda_lookback_days(ipdaLookbackDaysOpt)
int ipdaLookbackMs = ipdaLookbackDays * 86400000

f_to_int(string s, int fallback) =>
    int v = int(na(str.tonumber(s)) ? fallback : str.tonumber(s))
    v

int orgVisibleCount = f_to_int(orgVisibleOpt, 3)
const int INTERNAL_MAX_STORED = 750
const string ORG_TZ = "America/New_York"

//------------------------------------------------------------------------------
// Types / Storage
//------------------------------------------------------------------------------
type PDArray
    int leftT
    int rightT
    float top
    float bot
    bool bullish
    box bx = na
    line q0 = na
    line q25 = na
    line q50 = na
    line q75 = na
    line q100 = na
    label lq0 = na
    label lq25 = na
    label lq50 = na
    label lq75 = na
    label lq100 = na

var storeORG = array.new<PDArray>()

//------------------------------------------------------------------------------
// Drawing
//------------------------------------------------------------------------------
method delete(PDArray this) =>
    if not na(this.bx)
        box.delete(this.bx)
        this.bx := na
    if not na(this.q0)
        line.delete(this.q0), this.q0 := na
    if not na(this.q25)
        line.delete(this.q25), this.q25 := na
    if not na(this.q50)
        line.delete(this.q50), this.q50 := na
    if not na(this.q75)
        line.delete(this.q75), this.q75 := na
    if not na(this.q100)
        line.delete(this.q100), this.q100 := na
    if not na(this.lq0)
        label.delete(this.lq0), this.lq0 := na
    if not na(this.lq25)
        label.delete(this.lq25), this.lq25 := na
    if not na(this.lq50)
        label.delete(this.lq50), this.lq50 := na
    if not na(this.lq75)
        label.delete(this.lq75), this.lq75 := na
    if not na(this.lq100)
        label.delete(this.lq100), this.lq100 := na

method draw(PDArray this) =>
    int x1 = this.leftT
    int x2 = this.rightT
    float t = math.max(this.top, this.bot)
    float b = math.min(this.top, this.bot)

    int fillOp = 90
    color fill = orgRemoveFill ? color.new(orgBoxColor, 100) : color.new(orgBoxColor, fillOp)
    int bw = orgShowBorder ? 1 : 0
    color bc = color.new(orgBoxColor, 0)

    if na(this.bx)
        this.bx := box.new(left=x1, top=t, right=x2, bottom=b, xloc=xloc.bar_time, bgcolor=fill, border_width=bw, border_color=bc)
    else
        box.set_left(this.bx, x1)
        box.set_right(this.bx, x2)
        box.set_top(this.bx, t)
        box.set_bottom(this.bx, b)
        box.set_bgcolor(this.bx, fill)
        box.set_border_width(this.bx, bw)
        box.set_border_color(this.bx, bc)

    float y0 = f_grad(t, b, 0.00)
    float y25 = f_grad(t, b, 0.25)
    float y50 = f_grad(t, b, 0.50)
    float y75 = f_grad(t, b, 0.75)
    float y100 = f_grad(t, b, 1.00)

    this.q0 := f_upd_hline(this.q0, x1, x2, y0, orgShowGradients and org_q0_show, org_q0_color, org_q0_style, org_q0_w)
    this.q25 := f_upd_hline(this.q25, x1, x2, y25, orgShowGradients and org_q25_show, org_q25_color, org_q25_style, org_q25_w)
    this.q50 := f_upd_hline(this.q50, x1, x2, y50, orgShowGradients and org_q50_show, org_q50_color, org_q50_style, org_q50_w)
    this.q75 := f_upd_hline(this.q75, x1, x2, y75, orgShowGradients and org_q75_show, org_q75_color, org_q75_style, org_q75_w)
    this.q100 := f_upd_hline(this.q100, x1, x2, y100, orgShowGradients and org_q100_show, org_q100_color, org_q100_style, org_q100_w)

    bool wantLbl = orgShowGradients and orgShowGradientLabels
    lblSize = f_label_size(orgLabelSizeSetting)
    string datePfx = labelShowDate ? (f_md(this.leftT) + " ") : ""
    string kindTxt = "RTH Gap"

    this.lq0 := f_upd_qlabel(this.lq0, x2, y0, wantLbl and org_q0_show, datePfx + kindTxt + " 0%", orgLabelColor, lblSize)
    this.lq25 := f_upd_qlabel(this.lq25, x2, y25, wantLbl and org_q25_show, datePfx + kindTxt + " 25%", orgLabelColor, lblSize)
    this.lq50 := f_upd_qlabel(this.lq50, x2, y50, wantLbl and org_q50_show, datePfx + kindTxt + " 50%", orgLabelColor, lblSize)
    this.lq75 := f_upd_qlabel(this.lq75, x2, y75, wantLbl and org_q75_show, datePfx + kindTxt + " 75%", orgLabelColor, lblSize)
    this.lq100 := f_upd_qlabel(this.lq100, x2, y100, wantLbl and org_q100_show, datePfx + kindTxt + " 100%", orgLabelColor, lblSize)
    this

//------------------------------------------------------------------------------
// Selection / prune
//------------------------------------------------------------------------------
f_select_closest_to_mid(arr, int maxN, float px) =>
    int n = array.size(arr)
    bool[] keep = array.new_bool(n, false)
    if n > 0 and maxN > 0
        int want = math.min(maxN, n)
        for _ = 0 to want - 1
            float best = na
            int bestIdx = na
            for i = 0 to n - 1
                if not array.get(keep, i)
                    PDArray p = array.get(arr, i)
                    float mid = (p.top + p.bot) * 0.5
                    float d = math.abs(px - mid)
                    if na(best) or d < best
                        best := d
                        bestIdx := i
            if not na(bestIdx)
                array.set(keep, bestIdx, true)
    keep

f_select_most_recent(arr, int maxN) =>
    int n = array.size(arr)
    bool[] keep = array.new_bool(n, false)
    if n > 0 and maxN > 0
        int want = math.min(maxN, n)
        int start = n - want
        for i = start to n - 1
            array.set(keep, i, true)
    keep

f_prune_store(arr, int cutoffT, int maxStored) =>
    int n = array.size(arr)
    if n > 0
        for i = n - 1 to 0
            PDArray p = array.get(arr, i)
            if p.leftT < cutoffT
                if not snapshotSafeNoDelete
                    p.delete()
                array.remove(arr, i)
    while array.size(arr) > maxStored
        PDArray p0 = array.shift(arr)
        if not snapshotSafeNoDelete
            p0.delete()

f_clear_store() =>
    int n = array.size(storeORG)
    if n > 0
        for i = n - 1 to 0
            array.get(storeORG, i).delete()
    array.clear(storeORG)

//------------------------------------------------------------------------------
// 1m ORG latch — keep latest gap values every bar (not a one-bar event flag)
//------------------------------------------------------------------------------
f_is_1614(int t) => hour(t, ORG_TZ) == 16 and minute(t, ORG_TZ) == 14
f_is_0930(int t) => hour(t, ORG_TZ) == 9 and minute(t, ORG_TZ) == 30

f_org_latched_1m() =>
    // Latch persists across 1m bars. Chart code detects a new gap when the returned
    // anchor time changes from the previous chart bar (works on 5m/15m/etc.).
    var float lastPrevClose = na
    var int   anchorT = na
    var float prevClose = na
    var float open930 = na

    if f_is_1614(time)
        lastPrevClose := close

    if f_is_0930(time) and not na(lastPrevClose)
        anchorT := time
        prevClose := lastPrevClose
        open930 := open

    [anchorT, prevClose, open930]

//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
[orgAT, orgPC, orgO930] = request.security(syminfo.tickerid, "1", f_org_latched_1m(), barmerge.gaps_off, barmerge.lookahead_off)

// Anchor change on the chart series = a new RTH gap became visible at this HTF bar.
bool orgChanged = not na(orgAT) and (barstate.isfirst or na(orgAT[1]) or orgAT != orgAT[1])

if enabled and showORG
    int cutoffT = time - ipdaLookbackMs
    f_prune_store(storeORG, cutoffT, INTERNAL_MAX_STORED)

    if orgChanged and not na(orgPC) and not na(orgO930)
        float top = math.max(orgPC, orgO930)
        float bot = math.min(orgPC, orgO930)
        bool dup = array.size(storeORG) > 0 and array.get(storeORG, array.size(storeORG) - 1).leftT == orgAT
        if not dup
            array.push(storeORG, PDArray.new(orgAT, time, top, bot, orgO930 >= orgPC))

    int n = array.size(storeORG)
    if n > 0
        bool[] keep = selectionMode == "Most recent" ? f_select_most_recent(storeORG, orgVisibleCount) : f_select_closest_to_mid(storeORG, orgVisibleCount, close)
        for i = 0 to n - 1
            PDArray p = array.get(storeORG, i)
            if array.get(keep, i)
                p.rightT := time + padMs(INTERNAL_EXTEND_BARS)
                p := p.draw()
            else
                if not snapshotSafeNoDelete
                    p.delete()
            array.set(storeORG, i, p)
else
    f_clear_store()
````
