# ICT Sessions & Gaps - profdro

- url: https://www.tradingview.com/script/WQNStjVZ-ICT-Sessions-Gaps-profdro/
- type: indicator
- pine_id: PUB;f70d94d9bef34ace966ba48690bccc11
- version: 1.0

## Description

ICT session times with (inverse) fair value gaps on multiple timeframes (4hr,1hr,15m,5m). Expiration time of gaps can be adjusted in settings. Watermark feature included.

## Source Code

````pine
//@version=6
indicator("ICT Multi-Timeframe Toolkit v17",
     shorttitle="ICT MTF v17",
     overlay=true,
     max_lines_count=500,
     max_boxes_count=500,
     max_labels_count=500)

// ============================================================================
// ICT MULTI-TIMEFRAME TOOLKIT — v17
//
// CHANGES FROM v16 (two BPR fixes):
//   1. BPR formation now requires OPPOSITE directions — a bullish FVG
//      paired with a bearish IFVG, or a bearish FVG paired with a
//      bullish IFVG. Same-direction overlaps (e.g. bullish FVG + bullish
//      IFVG) no longer form a BPR — they aren't actually balanced
//      zones, just two same-direction signals stacked, and the FVG/IFVG
//      stay as separate boxes.
//
//   2. BPRs are now close-mitigated. When price closes outside the BPR
//      range (either above or below), the BPR is deleted. Previously
//      BPRs only expired by time, which left stale BPRs visible long
//      after the underlying FVG/IFVG would have been invalidated. Uses
//      the same per-tag HTF close as FVG/IFVG mitigation so behavior
//      stays consistent across chart timeframes.
//
// Everything else from v16 is unchanged.
// ============================================================================


// ============================================================================
//  INPUTS
// ============================================================================

// --- Watermark ---
gWM = "Watermark"
wmTitle    = input.string("Thanksnq", "Title", group=gWM)
wmSubtitle = input.string("GOD | FAMILY | FREEDOM", "Subtitle", group=gWM)
wmColor    = input.color(color.black, "Color", group=gWM)
wmBold     = input.bool(false, "Bold",   group=gWM, inline="wmfmt")
wmItalic   = input.bool(false, "Italic", group=gWM, inline="wmfmt")

// --- Sessions ---
gSess = "Sessions (exchange time)"
showAsiaHL    = input.bool(true,  "Asia H/L", group=gSess, inline="asia")
showAsiaBox   = input.bool(true,  "box",      group=gSess, inline="asia")
asiaColor     = input.color(color.new(#9575CD, 0), "", group=gSess, inline="asia")
asiaSessStr   = input.session("1800-2300", "Asia time",   group=gSess)

showLondonHL  = input.bool(true,  "London H/L", group=gSess, inline="london")
showLondonBox = input.bool(true,  "box",        group=gSess, inline="london")
londonColor   = input.color(color.new(#F7525F, 0), "", group=gSess, inline="london")
londonSessStr = input.session("0100-0400", "London time", group=gSess)

showNYHL      = input.bool(true,  "NY H/L", group=gSess, inline="ny")
showNYBox     = input.bool(true,  "box",    group=gSess, inline="ny")
nyColor       = input.color(color.new(#5B9CF6, 0), "", group=gSess, inline="ny")
nySessStr     = input.session("0730-1500", "NY time",     group=gSess)

sessBoxExpireDays = input.float(4.0, "Box expiry (days)", group=gSess, minval=0.1)

// --- PDH / PDL ---
gPDHL = "Previous Day H/L"
showPDHL = input.bool(true, "Show PDH/PDL", group=gPDHL)
pdhColor = input.color(color.black, "PDH color", group=gPDHL)
pdlColor = input.color(color.black, "PDL color", group=gPDHL)

// --- FVG ---
gFVG = "Fair Value Gaps"
showFVG_5m   = input.bool(true,  "5m FVG  (5m chart only)",   group=gFVG)
showFVG_15m  = input.bool(true,  "15m FVG (5m / 15m / 1H / 4H)", group=gFVG)
showFVG_1H   = input.bool(true,  "1H FVG  (5m / 15m / 1H)",   group=gFVG)
showFVG_4H   = input.bool(true,  "4H FVG  (any chart)",       group=gFVG)
fvgBullColor = input.color(color.new(#2196F3, 94), "Bullish FVG", group=gFVG)
fvgBearColor = input.color(color.new(#2196F3, 94), "Bearish FVG", group=gFVG)

// --- IFVG ---
gIFVG = "Inverse Fair Value Gaps"
showIFVG_5m   = input.bool(true, "5m IFVG  (5m chart only)",   group=gIFVG)
showIFVG_15m  = input.bool(true, "15m IFVG (5m / 15m / 1H / 4H)", group=gIFVG)
showIFVG_1H   = input.bool(true, "1H IFVG  (5m / 15m / 1H)",   group=gIFVG)
showIFVG_4H   = input.bool(true, "4H IFVG  (any chart)",       group=gIFVG)
ifvgBullColor = input.color(color.new(#F23645, 94), "Bullish IFVG", group=gIFVG)
ifvgBearColor = input.color(color.new(#F23645, 94), "Bearish IFVG", group=gIFVG)

// --- BPR ---
gBPR = "Balanced Price Range (BPR)"
showBPR_5m   = input.bool(true, "5m BPR  (5m chart only)",   group=gBPR)
showBPR_15m  = input.bool(true, "15m BPR (5m / 15m / 1H / 4H)", group=gBPR)
showBPR_1H   = input.bool(true, "1H BPR  (5m / 15m / 1H)",   group=gBPR)
showBPR_4H   = input.bool(true, "4H BPR  (any chart)",       group=gBPR)
bprColor     = input.color(color.new(#9C27B0, 94), "BPR color", group=gBPR)

// --- Text Style (global) ---
gText = "Text Style (applies to all labels)"
textColor      = input.color(color.black, "Text color", group=gText)
textBold       = input.bool(true, "Bold",   group=gText, inline="fmt")
textItalic     = input.bool(true, "Italic", group=gText, inline="fmt")
labelYOffMult  = input.float(0.15, "Above/below offset (× ATR)", group=gText, minval=0.0, step=0.05,
     tooltip="Distance between a line and its label, as a multiple of ATR(14).")

// --- Cleanup ---
gClean = "Cleanup / Expiry (FVG & IFVG)"
expire_5m_h  = input.float(1.0, "5m  (hours)", group=gClean, minval=0.1)
expire_15m_h = input.float(1.0, "15m (hours)", group=gClean, minval=0.1)
expire_1H_d  = input.float(2.0, "1H  (days)",  group=gClean, minval=0.1)
expire_4H_d  = input.float(7.0, "4H  (days)",  group=gClean, minval=0.1)


// ============================================================================
//  CONSTANTS / DERIVED
// ============================================================================

// Use the symbol's exchange timezone so session times match the chart axis.
TZ      = syminfo.timezone
MS_HOUR = 3600000
MS_DAY  = 86400000

CHART_SEC   = timeframe.in_seconds()
EXTEND_BARS = 2
EXTEND_MS   = CHART_SEC * 1000 * EXTEND_BARS

f_tf_match(simple string tf) =>
    CHART_SEC <= timeframe.in_seconds(tf)

showFVG_5m_eff  = showFVG_5m  and f_tf_match("5")
showFVG_15m_eff = showFVG_15m
showFVG_1H_eff  = showFVG_1H  and f_tf_match("60")
showFVG_4H_eff  = showFVG_4H  and f_tf_match("240")

// Per-tag HTF close — fetched with lookahead_off so each gap is
// mitigated by its own timeframe's close, not the chart's. When chart
// TF == tag TF we use the chart's `close` directly to avoid the one-bar
// lag request.security has on the same TF.
htf_close_5m  = request.security(syminfo.tickerid, "5",   close, lookahead=barmerge.lookahead_off)
htf_close_15m = request.security(syminfo.tickerid, "15",  close, lookahead=barmerge.lookahead_off)
htf_close_1H  = request.security(syminfo.tickerid, "60",  close, lookahead=barmerge.lookahead_off)
htf_close_4H  = request.security(syminfo.tickerid, "240", close, lookahead=barmerge.lookahead_off)

f_tag_close(string tag) =>
    out = close
    if tag == "5m"
        out := CHART_SEC < 300   ? nz(htf_close_5m,  close) : close
    else if tag == "15m"
        out := CHART_SEC < 900   ? nz(htf_close_15m, close) : close
    else if tag == "1H"
        out := CHART_SEC < 3600  ? nz(htf_close_1H,  close) : close
    else if tag == "4H"
        out := CHART_SEC < 14400 ? nz(htf_close_4H,  close) : close
    out

text_fmt = textBold and textItalic ? text.format_bold + text.format_italic :
           textBold                ? text.format_bold :
           textItalic              ? text.format_italic :
                                     text.format_none

wm_fmt = wmBold and wmItalic ? text.format_bold + text.format_italic :
         wmBold              ? text.format_bold :
         wmItalic            ? text.format_italic :
                              text.format_none

labelYOff = nz(ta.atr(14), close * 0.001) * labelYOffMult
TRANSP_BG = color.new(color.black, 100)


// ============================================================================
//  TYPES
// ============================================================================

type SessState
    float hi      = na
    float lo      = na
    int   startT  = na
    line  hiLine  = na
    line  loLine  = na
    label hiLb    = na
    label loLb    = na
    box   bx      = na
    bool  hiSwept = false
    bool  loSwept = false

type SessBox
    box bx       = na
    int createdT = na

type FVGObj
    box    bx
    label  lb
    float  top
    float  bottom
    int    formedT
    int    leftT
    bool   isBull
    string tag
    int    expireMs

type IFVGObj
    box    bx
    label  lb
    float  top
    float  bottom
    int    formedT
    bool   isBull
    string tag
    int    expireMs

type BPRObj
    box    bx
    label  lb
    float  top
    float  bottom
    int    formedT
    int    leftT
    string tag
    int    expireMs


// ============================================================================
//  SESSIONS
// ============================================================================

var SessState asia           = SessState.new()
var SessState london         = SessState.new()
var SessState ny             = SessState.new()
var array<SessBox> sessBoxes = array.new<SessBox>()

f_update_session(SessState s, string sessStr, bool showHL, bool showBox, color c, string prefix) =>
    inSess    = not na(time(timeframe.period, sessStr, TZ))
    sessStart = inSess and not inSess[1]
    sessEnd   = (not inSess) and inSess[1]

    if sessStart
        s.hi := high
        s.lo := low
        s.startT := time
        if showBox
            s.bx := box.new(time, high, time, low, xloc=xloc.bar_time,
                 bgcolor=color.new(c, 90), border_color=color.new(c, 50))

    if inSess and not sessStart
        if high > s.hi
            s.hi := high
        if low < s.lo
            s.lo := low
        if not na(s.bx)
            box.set_top(s.bx, s.hi)
            box.set_bottom(s.bx, s.lo)
            box.set_right(s.bx, time)

    if sessEnd
        if not na(s.bx)
            box.set_right(s.bx, time)
            array.push(sessBoxes, SessBox.new(s.bx, time))
        if showHL
            if not na(s.hiLine)
                line.delete(s.hiLine)
            if not na(s.loLine)
                line.delete(s.loLine)
            if not na(s.hiLb)
                label.delete(s.hiLb)
            if not na(s.loLb)
                label.delete(s.loLb)
            s.hiLine := line.new(s.startT, s.hi, time, s.hi, xloc=xloc.bar_time,
                 extend=extend.right, color=c, width=1)
            s.loLine := line.new(s.startT, s.lo, time, s.lo, xloc=xloc.bar_time,
                 extend=extend.right, color=c, width=1)
            s.hiLb := label.new(s.startT, s.hi + labelYOff, prefix + "H",
                 xloc=xloc.bar_time, style=label.style_none,
                 color=TRANSP_BG, textcolor=c, size=size.small,
                 text_formatting=text_fmt)
            s.loLb := label.new(s.startT, s.lo - labelYOff, prefix + "L",
                 xloc=xloc.bar_time, style=label.style_none,
                 color=TRANSP_BG, textcolor=c, size=size.small,
                 text_formatting=text_fmt)
            s.hiSwept := false
            s.loSwept := false

    // Sweep detection — line stops at the candle that takes out the level
    if not na(s.hiLine) and not s.hiSwept
        if high > line.get_y1(s.hiLine)
            line.set_extend(s.hiLine, extend.none)
            line.set_x2(s.hiLine, time)
            s.hiSwept := true

    if not na(s.loLine) and not s.loSwept
        if low < line.get_y1(s.loLine)
            line.set_extend(s.loLine, extend.none)
            line.set_x2(s.loLine, time)
            s.loSwept := true

f_update_session(asia,   asiaSessStr,   showAsiaHL,   showAsiaBox,   asiaColor,   "A")
f_update_session(london, londonSessStr, showLondonHL, showLondonBox, londonColor, "L")
f_update_session(ny,     nySessStr,     showNYHL,     showNYBox,     nyColor,     "N")

if array.size(sessBoxes) > 0
    sessBoxExpireMs = math.round(sessBoxExpireDays * MS_DAY)
    for i = array.size(sessBoxes) - 1 to 0
        sb = array.get(sessBoxes, i)
        if (time - sb.createdT) > sessBoxExpireMs
            box.delete(sb.bx)
            array.remove(sessBoxes, i)


// ============================================================================
//  PDH / PDL
// ============================================================================

var float todayHi    = na
var float todayLo    = na
var int   todayStart = na

var line  pdhLn      = na
var line  pdlLn      = na
var label pdhLb      = na
var label pdlLb      = na
var float pdhPx      = na
var float pdlPx      = na
var bool  pdhSwept   = false
var bool  pdlSwept   = false

newDay = ta.change(dayofmonth(time, TZ)) != 0

if newDay
    if not na(pdhLn)
        line.delete(pdhLn)
        pdhLn := na
    if not na(pdhLb)
        label.delete(pdhLb)
        pdhLb := na
    if not na(pdlLn)
        line.delete(pdlLn)
        pdlLn := na
    if not na(pdlLb)
        label.delete(pdlLb)
        pdlLb := na

    if showPDHL and not na(todayHi) and not na(todayStart)
        pdhLn := line.new(todayStart, todayHi, time, todayHi, xloc=xloc.bar_time,
             extend=extend.right, color=pdhColor, width=1)
        pdhLb := label.new(todayStart, todayHi + labelYOff, "PDH", xloc=xloc.bar_time,
             style=label.style_none, color=TRANSP_BG, textcolor=textColor,
             size=size.small, text_formatting=text_fmt)
        pdhPx := todayHi
        pdhSwept := false

        pdlLn := line.new(todayStart, todayLo, time, todayLo, xloc=xloc.bar_time,
             extend=extend.right, color=pdlColor, width=1)
        pdlLb := label.new(todayStart, todayLo - labelYOff, "PDL", xloc=xloc.bar_time,
             style=label.style_none, color=TRANSP_BG, textcolor=textColor,
             size=size.small, text_formatting=text_fmt)
        pdlPx := todayLo
        pdlSwept := false

    todayHi := high
    todayLo := low
    todayStart := time
else
    todayHi := na(todayHi) ? high : math.max(todayHi, high)
    todayLo := na(todayLo) ? low  : math.min(todayLo, low)
    if na(todayStart)
        todayStart := time

// Sweep detection — same pattern as session H/L
if not na(pdhLn) and not pdhSwept
    if high > line.get_y1(pdhLn)
        line.set_extend(pdhLn, extend.none)
        line.set_x2(pdhLn, time)
        pdhSwept := true

if not na(pdlLn) and not pdlSwept
    if low < line.get_y1(pdlLn)
        line.set_extend(pdlLn, extend.none)
        line.set_x2(pdlLn, time)
        pdlSwept := true


// ============================================================================
//  FVG / IFVG
// ============================================================================

var array<FVGObj>  activeFVGs  = array.new<FVGObj>()
var array<IFVGObj> activeIFVGs = array.new<IFVGObj>()

f_ifvg_enabled(string tag) =>
    out = false
    if tag == "5m"
        out := showIFVG_5m and f_tf_match("5")
    else if tag == "15m"
        out := showIFVG_15m
    else if tag == "1H"
        out := showIFVG_1H and f_tf_match("60")
    else if tag == "4H"
        out := showIFVG_4H and f_tf_match("240")
    out

f_detect_fvg(simple string tf, bool enabled, string tag, int expireMs) =>
    if enabled
        [h1, h3, l1, l3, t3] = request.security(syminfo.tickerid, tf,
             [high[1], high[3], low[1], low[3], time[3]],
             lookahead=barmerge.lookahead_on)

        newHTFBar = ta.change(time(tf)) != 0

        if newHTFBar and not na(h1) and not na(h3) and not na(l1) and not na(l3) and not na(t3)
            bullFVG = l1 > h3
            bearFVG = h1 < l3
            rightT  = time + EXTEND_MS

            if bullFVG
                bx = box.new(t3, l1, rightT, h3, xloc=xloc.bar_time,
                     bgcolor=fvgBullColor, border_color=color.new(fvgBullColor, 50))
                lb = label.new(rightT, (l1 + h3) / 2, tag + " FVG", xloc=xloc.bar_time,
                     style=label.style_label_right, color=TRANSP_BG,
                     textcolor=textColor, size=size.tiny,
                     text_formatting=text_fmt)
                array.push(activeFVGs, FVGObj.new(bx, lb, l1, h3, time, t3, true, tag, expireMs))

            if bearFVG
                bx = box.new(t3, l3, rightT, h1, xloc=xloc.bar_time,
                     bgcolor=fvgBearColor, border_color=color.new(fvgBearColor, 50))
                lb = label.new(rightT, (l3 + h1) / 2, tag + " FVG", xloc=xloc.bar_time,
                     style=label.style_label_right, color=TRANSP_BG,
                     textcolor=textColor, size=size.tiny,
                     text_formatting=text_fmt)
                array.push(activeFVGs, FVGObj.new(bx, lb, l3, h1, time, t3, false, tag, expireMs))

f_detect_fvg("5",   showFVG_5m_eff,  "5m",  math.round(expire_5m_h  * MS_HOUR))
f_detect_fvg("15",  showFVG_15m_eff, "15m", math.round(expire_15m_h * MS_HOUR))
f_detect_fvg("60",  showFVG_1H_eff,  "1H",  math.round(expire_1H_d  * MS_DAY))
f_detect_fvg("240", showFVG_4H_eff,  "4H",  math.round(expire_4H_d  * MS_DAY))

// FVG 1H vs 4H overlap dedup (same direction → drop 1H)
if array.size(activeFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        a = array.get(activeFVGs, i)
        if a.tag == "1H"
            shouldRemove = false
            if array.size(activeFVGs) > 0
                for j = 0 to array.size(activeFVGs) - 1
                    if j != i and not shouldRemove
                        b = array.get(activeFVGs, j)
                        if b.tag == "4H" and b.isBull == a.isBull
                            if a.top >= b.bottom and b.top >= a.bottom
                                shouldRemove := true
            if shouldRemove
                box.delete(a.bx)
                label.delete(a.lb)
                array.remove(activeFVGs, i)

// FVG right edge update
if array.size(activeFVGs) > 0
    rightT = time + EXTEND_MS
    for i = 0 to array.size(activeFVGs) - 1
        f = array.get(activeFVGs, i)
        box.set_right(f.bx, rightT)
        label.set_x(f.lb, rightT)

// FVG mitigation → IFVG creation (uses per-tag HTF close)
if array.size(activeFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        f = array.get(activeFVGs, i)
        mc = f_tag_close(f.tag)
        mitigated = false
        if f.isBull
            if mc < f.bottom
                mitigated := true
        else
            if mc > f.top
                mitigated := true

        if mitigated
            box.delete(f.bx)
            label.delete(f.lb)

            if f_ifvg_enabled(f.tag)
                isBullIFVG = not f.isBull
                ic = isBullIFVG ? ifvgBullColor : ifvgBearColor
                rightT2 = time + EXTEND_MS
                bx = box.new(f.leftT, f.top, rightT2, f.bottom, xloc=xloc.bar_time,
                     bgcolor=ic, border_color=color.new(ic, 50))
                lb = label.new(rightT2, (f.top + f.bottom) / 2, f.tag + " IFVG",
                     xloc=xloc.bar_time, style=label.style_label_right,
                     color=TRANSP_BG, textcolor=textColor, size=size.tiny,
                     text_formatting=text_fmt)
                array.push(activeIFVGs, IFVGObj.new(bx, lb, f.top, f.bottom, time,
                     isBullIFVG, f.tag, f.expireMs))

            array.remove(activeFVGs, i)

// IFVG 1H vs 4H overlap dedup (same direction → drop 1H)
if array.size(activeIFVGs) > 0
    for i = array.size(activeIFVGs) - 1 to 0
        a = array.get(activeIFVGs, i)
        if a.tag == "1H"
            shouldRemove = false
            if array.size(activeIFVGs) > 0
                for j = 0 to array.size(activeIFVGs) - 1
                    if j != i and not shouldRemove
                        b = array.get(activeIFVGs, j)
                        if b.tag == "4H" and b.isBull == a.isBull
                            if a.top >= b.bottom and b.top >= a.bottom
                                shouldRemove := true
            if shouldRemove
                box.delete(a.bx)
                label.delete(a.lb)
                array.remove(activeIFVGs, i)

// FVG expiry
if array.size(activeFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        f = array.get(activeFVGs, i)
        if (time - f.formedT) > f.expireMs
            box.delete(f.bx)
            label.delete(f.lb)
            array.remove(activeFVGs, i)

// IFVG right edge update
if array.size(activeIFVGs) > 0
    rightT3 = time + EXTEND_MS
    for i = 0 to array.size(activeIFVGs) - 1
        ifvg = array.get(activeIFVGs, i)
        box.set_right(ifvg.bx, rightT3)
        label.set_x(ifvg.lb, rightT3)

// IFVG mitigation (uses per-tag HTF close)
if array.size(activeIFVGs) > 0
    for i = array.size(activeIFVGs) - 1 to 0
        ifvg = array.get(activeIFVGs, i)
        mc = f_tag_close(ifvg.tag)
        mitigated = false
        if ifvg.isBull
            if mc < ifvg.bottom
                mitigated := true
        else
            if mc > ifvg.top
                mitigated := true

        if mitigated
            box.delete(ifvg.bx)
            label.delete(ifvg.lb)
            array.remove(activeIFVGs, i)

// IFVG expiry
if array.size(activeIFVGs) > 0
    for i = array.size(activeIFVGs) - 1 to 0
        ifvg = array.get(activeIFVGs, i)
        if (time - ifvg.formedT) > ifvg.expireMs
            box.delete(ifvg.bx)
            label.delete(ifvg.lb)
            array.remove(activeIFVGs, i)


// ============================================================================
//  BPR
//
//  Runs after every FVG/IFVG step above, so the components considered
//  here are exactly the ones that would otherwise be drawn on the chart.
// ============================================================================

var array<BPRObj> activeBPRs = array.new<BPRObj>()

f_bpr_enabled(string tag) =>
    out = false
    if tag == "5m"
        out := showBPR_5m and f_tf_match("5")
    else if tag == "15m"
        out := showBPR_15m
    else if tag == "1H"
        out := showBPR_1H and f_tf_match("60")
    else if tag == "4H"
        out := showBPR_4H and f_tf_match("240")
    out

// BPR detection — pair an FVG and an IFVG of the same tag, OPPOSITE
// direction, with overlapping price ranges. Both source boxes are
// deleted; the BPR covers only the intersection. Same-direction
// overlaps (bullish+bullish or bearish+bearish) don't form a BPR.
if array.size(activeFVGs) > 0 and array.size(activeIFVGs) > 0
    for i = array.size(activeFVGs) - 1 to 0
        if i < array.size(activeFVGs)
            f = array.get(activeFVGs, i)
            paired = false
            if f_bpr_enabled(f.tag) and array.size(activeIFVGs) > 0
                for j = array.size(activeIFVGs) - 1 to 0
                    if not paired and j < array.size(activeIFVGs)
                        ifvg = array.get(activeIFVGs, j)
                        if ifvg.tag == f.tag and f.isBull != ifvg.isBull and f.top >= ifvg.bottom and ifvg.top >= f.bottom
                            overlapTop = math.min(f.top, ifvg.top)
                            overlapBot = math.max(f.bottom, ifvg.bottom)
                            bprLeftT   = math.min(f.leftT, ifvg.formedT)
                            rightTb    = time + EXTEND_MS
                            bx = box.new(bprLeftT, overlapTop, rightTb, overlapBot,
                                 xloc=xloc.bar_time,
                                 bgcolor=bprColor, border_color=color.new(bprColor, 50))
                            lb = label.new(rightTb, (overlapTop + overlapBot) / 2, f.tag + " BPR",
                                 xloc=xloc.bar_time, style=label.style_label_right,
                                 color=TRANSP_BG, textcolor=textColor, size=size.tiny,
                                 text_formatting=text_fmt)
                            array.push(activeBPRs, BPRObj.new(bx, lb, overlapTop, overlapBot,
                                 time, bprLeftT, f.tag, f.expireMs))
                            box.delete(f.bx)
                            label.delete(f.lb)
                            array.remove(activeFVGs, i)
                            box.delete(ifvg.bx)
                            label.delete(ifvg.lb)
                            array.remove(activeIFVGs, j)
                            paired := true

// BPR 1H vs 4H overlap dedup — drop 1H BPR if its range overlaps a 4H
// BPR. Same precedence rule as FVG/IFVG dedup (4H wins).
if array.size(activeBPRs) > 0
    for i = array.size(activeBPRs) - 1 to 0
        a = array.get(activeBPRs, i)
        if a.tag == "1H"
            shouldRemove = false
            if array.size(activeBPRs) > 0
                for j = 0 to array.size(activeBPRs) - 1
                    if j != i and not shouldRemove
                        b = array.get(activeBPRs, j)
                        if b.tag == "4H"
                            if a.top >= b.bottom and b.top >= a.bottom
                                shouldRemove := true
            if shouldRemove
                box.delete(a.bx)
                label.delete(a.lb)
                array.remove(activeBPRs, i)

// BPR right edge update
if array.size(activeBPRs) > 0
    rightTb2 = time + EXTEND_MS
    for i = 0 to array.size(activeBPRs) - 1
        bpr = array.get(activeBPRs, i)
        box.set_right(bpr.bx, rightTb2)
        label.set_x(bpr.lb, rightTb2)

// BPR close mitigation — invalidate when price closes outside the BPR
// range in either direction. Uses per-tag HTF close (same as FVG/IFVG)
// so behavior is consistent across chart timeframes.
if array.size(activeBPRs) > 0
    for i = array.size(activeBPRs) - 1 to 0
        bpr = array.get(activeBPRs, i)
        mc = f_tag_close(bpr.tag)
        if mc < bpr.bottom or mc > bpr.top
            box.delete(bpr.bx)
            label.delete(bpr.lb)
            array.remove(activeBPRs, i)

// BPR time expiry (inherits from source FVG)
if array.size(activeBPRs) > 0
    for i = array.size(activeBPRs) - 1 to 0
        bpr = array.get(activeBPRs, i)
        if (time - bpr.formedT) > bpr.expireMs
            box.delete(bpr.bx)
            label.delete(bpr.lb)
            array.remove(activeBPRs, i)


// ============================================================================
//  WATERMARK + CHART INFO
// ============================================================================

var table watermarkTbl = table.new(position.top_center, 1, 2,
     bgcolor=na, frame_color=na, frame_width=0,
     border_color=na, border_width=0)

var table chartInfoTbl = table.new(position.bottom_center, 1, 2,
     bgcolor=na, frame_color=na, frame_width=0,
     border_color=na, border_width=0)

if barstate.islast
    // Top watermark
    table.cell(watermarkTbl, 0, 0, wmTitle,
         text_color=wmColor, text_size=size.huge,
         text_halign=text.align_center, text_formatting=wm_fmt)
    table.cell(watermarkTbl, 0, 1, wmSubtitle,
         text_color=wmColor, text_size=size.large,
         text_halign=text.align_center, text_formatting=wm_fmt)

    // Bottom chart info — date / pair | timeframe
    dateStr   = str.tostring(dayofmonth(time, TZ)) + "/" + str.tostring(month(time, TZ)) + "/" + str.tostring(year(time, TZ))
    tfStr     = str.tostring(math.round(timeframe.in_seconds() / 60)) + "M"
    pairTfStr = syminfo.ticker + " | " + tfStr
    infoColor = color.new(color.gray, 30)

    table.cell(chartInfoTbl, 0, 0, dateStr,
         text_color=infoColor, text_size=size.normal,
         text_halign=text.align_center)
    table.cell(chartInfoTbl, 0, 1, pairTfStr,
         text_color=infoColor, text_size=size.normal,
         text_halign=text.align_center)
````
