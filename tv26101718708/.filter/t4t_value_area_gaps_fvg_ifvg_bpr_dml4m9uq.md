# T4T Value Area Gaps - FVG / IFVG / BPR

- url: https://www.tradingview.com/script/dMl4m9uQ-T4T-Value-Area-Gaps-FVG-IFVG-BPR/
- type: indicator
- pine_id: PUB;eb9061785428474286350b37d8626c39
- version: 2.0

## Description

[b]T4T VA Gaps - FVG / iFVG / BPR[/b]

This indicator filters Fair Value Gaps, Inverted Fair Value Gaps and Balanced Price Ranges by whether it sit on the previous session's value area: the Value Area High (PDVAH), Value Area Low (PDVAL) and Point of Control (PDPOC). Gap tools on their own mark every imbalance on the chart. Volume profile tools on their own show where volume traded, but not where price left inefficiencies. Combining them shows only the imbalance that lines up with prior-session value.

[b]How It Works[/b]

[b]1. Previous Session Value Area[/b]
- The script builds volume profile for each session (default: 1 day) using lower-timeframe intrabar data (default: 1 minute).
- Each intrabar's volume is spread across the price rows its high-low range covered, in proportion to overlap.
- The POC is the row with highest volume.
- The value area expands outward from the POC, adding the higher-volume neighbouring row each step, until it holds the chosen percentage of the total volume (default 70%).
- When a new session begins, the completed session's VAH, VAL and POC are plotted and carried through the current session.  
- If the symbol has no volume data, the profile falls back to time-at-price.

[b]2. Point of Control extension[/b]
- Each PDPOC can extend to the right across later sessions until a candle's range trades through it (mitigation).
- Mitigated POC's can be removed or kept, ending at the candle that touched them.

[b]3. Fair Value Gaps[/b]
- A bullish FVG forms when the current low is above the high from two bars earlier.
- A bearish FVG forms when the current high is below the low from the two bars earlier.
- Gaps smaller than a set multiple of ATR(14) are ignored.

[b]4. Inverted Fair Value Gaps[/b]
- An FVG becomes an iFVG when a candle closes through its far side. The zone then takes the opposite bias.
- An iFVG is invalidated when price closes back through it the other way.

[b]5. Balanced Price Range[/b]
- When a new FVG forms within the pairing window of an opposing gap, the overlapping price range between the two is marked as a BPR.
- A BPR is invalidated on a close through its opposite edge.

[b]6. Alignment Filter[/b]
- A zone counts as aligned when a selected level (PDVAH, PDVAL and/or PDPOC) is inside the zone, or within a tolerance of its edge (default 0.25 x ATR).
- Aligned zones are labelled with the levels they touch, for example "FVG+ VAH POC".
- When a new session produces new levels, active zones that were not aligned before are checked again.

[b]How To Use[/b]
- Add the indicator to an intraday chart below the Session Anchor timeframe. For example, use a 15m-4h chart with a daily anchor.
- "Aligned Only" mode shows only zones that touch prior value.
- "Highlight Aligned" mode shows every zone and emphasises the aligned ones, which is useful for studying context.
- A common way to read it: when price returns to an aligned zone, watch how it reacts at prior-session value. For example, it may reject from a bullish FVG on PDVAL, or fail at bearish iFVG on PDVAH. Treat this as context alongside your own analysis, not a standalone signal.
- The dashboard shows the current PD levels, whether price is above, inside or below prior value, and the number of active aligned zones by type.
- Alerts are available for new aligned bullish or bearish FVG's, iFVG's and BPR's. Alerts are evaluated at bar close.

[b]Settings[/b]
- Previous Day Value Area: session anchor, intrabar resolution, profile rows, value area %, level history, colours, POC extension and mitigation behaviour.
- Gap Detection: toggles and colours for each zone type, minimum gap size (x ATR), BPR pairing window, maximum zone age and detection of invalidated zones.
- Value Area Alignment: display mode, tolerance, and which levels count toward alignment.
- Style: fill transparency, zone labels and dashboard position.

[b]Notes & Limitations[/b] 
- Levels are calculated by this script, so they can differ slightly from TradingView's built-in Session Volume Profile depending on row count and data resolution. Adjust Profile Rows to bring them closer.
- TradingView limits how many intrabars a script can request. Older sessions beyond that limit are built from chart bars, which gives a coarser profile.
- The first session on the chart may be incomplete, so its levels may not be representative.
- Zones and levels are confirmed at bar close. gaps that form on the live bar can appear and disappear until the bar until the bar closes.
- The Session Anchor must be a higher timeframe than the chart.

[b]DISCLAIMER[/b]
[i]This indicator is a charting and educational tool. It does not provide buy or sells signals or financial advise, and past behaviour at these levels does not guarantee future results. Always use your own risk management.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TysonT_345

//@version=6
indicator("T4T VA Gaps · FVG / IFVG / BPR", shorttitle = "T4T VA Gaps", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ════════════════════════════════════════════════════════════════
//  T4T VA Gaps v2 — The T is 4 Trading · "Patience Pays"
//  Previous Day / Previous Week value areas built from intrabar volume,
//  developing value area, optional custom session, higher-timeframe
//  gap source, consequent encroachment and zone state tracking.
// ════════════════════════════════════════════════════════════════

// ───────── Inputs · Previous Day Value Area ─────────
const string G_VP = "Previous Day Value Area"
string vpAnchor   = input.timeframe("D", "Session Anchor", group = G_VP, tooltip = "Profile period when Custom Session is off. 'D' = one profile per trading day. Must be higher than the chart timeframe.")
string vpLTF      = input.timeframe("1", "Intrabar Resolution", group = G_VP, tooltip = "Lower timeframe used to build the profiles. Lower = more accurate, less history. If the chart is at or below this, the chart's own bars are used.")
int    vpRows     = input.int(70, "Profile Rows", minval = 10, maxval = 250, group = G_VP)
float  vpPct      = input.float(70.0, "Value Area %", minval = 50, maxval = 95, step = 1, group = G_VP)
bool   showLvls   = input.bool(true, "Show PDVAH / PDVAL / PDPOC", group = G_VP)
int    lvlDays    = input.int(5, "Sessions of Levels to Keep", minval = 1, maxval = 50, group = G_VP)
color  cVA        = input.color(color.white, "VA Lines", inline = "lc", group = G_VP)
color  cPOC       = input.color(color.yellow, "POC", inline = "lc", group = G_VP)
int    lvlW       = input.int(1, "Width", minval = 1, maxval = 4, inline = "lc", group = G_VP)
bool   pocExt     = input.bool(true, "Extend POC Until Mitigated", group = G_VP, tooltip = "POC keeps extending right across later sessions until a candle trades through it.")
int    pocMax     = input.int(20, "Max Unmitigated POCs", minval = 1, maxval = 100, group = G_VP)
bool   pocKeep    = input.bool(true, "Keep Mitigated POCs", group = G_VP, tooltip = "On: a mitigated POC stays on the chart, ending at the bar that touched it. Off: it is removed.")
bool   showDev    = input.bool(true, "Show Developing Value Area", group = G_VP, tooltip = "Current session's VAH / VAL / POC, updating live (dotted). Context only — not used for alignment.")
bool   showDevLbl = input.bool(true, "Developing Labels", inline = "dl", group = G_VP, tooltip = "dVAH / dVAL / dPOC labels at the right edge, and their size.")
string devLblSz   = input.string("Small", "", options = ["Tiny", "Small", "Normal"], inline = "dl", group = G_VP)

// ───────── Inputs · Previous Week Value Area ─────────
const string G_PW = "Previous Week Value Area"
bool  showPW = input.bool(true, "Show PWVAH / PWVAL", group = G_PW)
color cPW    = input.color(#90A4AE, "PW Lines", inline = "pw", group = G_PW)
int   pwW    = input.int(2, "Width", minval = 1, maxval = 4, inline = "pw", group = G_PW)
int   pwKeep = input.int(2, "Weeks of Levels to Keep", minval = 1, maxval = 10, group = G_PW)

// ───────── Inputs · Session Control ─────────
const string G_SS = "Session Control"
bool   useSess = input.bool(false, "Use Custom Session", group = G_SS, tooltip = "Off: profiles use all data, split by Session Anchor. On: profiles only use intrabars inside the window below (e.g. RTH 09:30–16:00 New York). A session's levels are published on the first bar after the window closes. Applies to the daily, weekly and developing profiles.")
string sessStr = input.session("0930-1600", "Session Window", group = G_SS)
string sessTZ  = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "Europe/London", "UTC", "Asia/Tokyo"], group = G_SS)

// ───────── Inputs · Gaps ─────────
const string G_GAP = "Gap Detection"
string gapTF    = input.timeframe("", "Gap Timeframe", group = G_GAP, tooltip = "Blank = chart timeframe. A higher timeframe detects gaps on that timeframe's confirmed candles and draws them on this chart (no repainting). Inversion and invalidation use that timeframe's closes.")
bool  showFVG   = input.bool(true, "Fair Value Gaps     ", inline = "f", group = G_GAP)
color cFvgBu    = input.color(#26A69A, "", inline = "f", group = G_GAP)
color cFvgBe    = input.color(#EF5350, "", inline = "f", group = G_GAP)
bool  showIFVG  = input.bool(true, "Inverted FVGs       ", inline = "i", group = G_GAP)
color cIfvgBu   = input.color(#2962FF, "", inline = "i", group = G_GAP)
color cIfvgBe   = input.color(#FF8C2E, "", inline = "i", group = G_GAP)
bool  showBPR   = input.bool(true, "Balanced Price Range", inline = "b", group = G_GAP)
color cBprBu    = input.color(#00BCD4, "", inline = "b", group = G_GAP)
color cBprBe    = input.color(#E040FB, "", inline = "b", group = G_GAP)
float minGapAtr = input.float(0.25, "Min Gap Size (× ATR)", minval = 0, step = 0.05, group = G_GAP, tooltip = "ATR(14) of the Gap Timeframe.")
int   bprWin    = input.int(15, "BPR Pairing Window (bars)", minval = 1, maxval = 100, group = G_GAP, tooltip = "Max Gap Timeframe candles between the two opposing FVGs that form a BPR.")
int   maxAge    = input.int(300, "Max Zone Age (bars)", minval = 10, maxval = 5000, group = G_GAP, tooltip = "Counted in Gap Timeframe candles.")
bool  delDead   = input.bool(true, "Delete Invalidated Zones", group = G_GAP)

// ───────── Inputs · Zone State & CE ─────────
const string G_ZS = "Zone State & Consequent Encroachment"
bool  showCE    = input.bool(true, "Consequent Encroachment (50%)", group = G_ZS, tooltip = "Dashed midline inside each zone.")
bool  showState = input.bool(true, "Show Zone State", group = G_ZS, tooltip = "Fresh = untouched since it formed (or since it inverted). T1, T2… = number of times price has returned into the zone. Tested zones fade slightly.")
bool  freshOnly = input.bool(false, "Fresh Zones Only", group = G_ZS, tooltip = "Hide a zone once price tests it.")

// ───────── Inputs · Alignment ─────────
const string G_AL = "Value Area Alignment"
string alMode = input.string("Aligned Only", "Display Mode", options = ["Aligned Only", "Highlight Aligned"], group = G_AL, tooltip = "Aligned Only: hide zones that don't touch a selected level. Highlight Aligned: show all, aligned zones get a stronger fill and tag.")
float  tolAtr = input.float(0.25, "Alignment Tolerance (× ATR)", minval = 0, step = 0.05, group = G_AL, tooltip = "ATR(14) of the Gap Timeframe. A zone aligns when a level is inside it, or within this distance of its edge.")
bool   useVAH = input.bool(true, "PDVAH", inline = "a", group = G_AL)
bool   usePOC = input.bool(true, "PDPOC", inline = "a", group = G_AL)
bool   useVAL = input.bool(true, "PDVAL", inline = "a", group = G_AL)
bool   usePWH = input.bool(true, "PWVAH", inline = "w", group = G_AL)
bool   usePWL = input.bool(true, "PWVAL", inline = "w", group = G_AL)

// ───────── Inputs · Style ─────────
const string G_ST = "Style"
int    zTransp  = input.int(80, "Zone Fill Transparency", minval = 0, maxval = 100, group = G_ST)
bool   showTxt  = input.bool(true, "Zone Labels", inline = "t", group = G_ST)
string txtSz    = input.string("Tiny", "", options = ["Tiny", "Small", "Normal"], inline = "t", group = G_ST)
bool   showDash = input.bool(true, "Dashboard", inline = "d", group = G_ST)
string dashPos  = input.string("Bottom Right", "", options = ["Top Right", "Bottom Right", "Bottom Left", "Top Left"], inline = "d", group = G_ST)

// ───────── Helpers ─────────
textSize(string s) => s == "Small" ? size.small : s == "Normal" ? size.normal : size.tiny
tblPos(string s) => s == "Top Right" ? position.top_right : s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : position.bottom_right
fmt(float x) => na(x) ? "—" : str.tostring(x, format.mintick)

int sMin = int(str.tonumber(str.substring(sessStr, 0, 2))) * 60 + int(str.tonumber(str.substring(sessStr, 2, 4)))
int eMin = int(str.tonumber(str.substring(sessStr, 5, 7))) * 60 + int(str.tonumber(str.substring(sessStr, 7, 9)))

inSession(int t) =>
    int m = hour(t, sessTZ) * 60 + minute(t, sessTZ)
    sMin <= eMin ? (m >= sMin and m < eMin) : (m >= sMin or m < eMin)

// Volume profile → [POC, VAH, VAL]
calcProfile(array<float> hs, array<float> ls, array<float> vs, int rows, float vaPct) =>
    float pPoc = na
    float pVah = na
    float pVal = na
    int n = hs.size()
    if n > 0
        float hi = hs.max()
        float lo = ls.min()
        float rng = hi - lo
        if rng > 0
            float rowH = rng / rows
            array<float> bins = array.new<float>(rows, 0.0)
            float tv = 0.0
            for x in vs
                tv += nz(x)
            bool tpo = tv <= 0   // no volume feed → time-at-price
            for i = 0 to n - 1
                float h  = hs.get(i)
                float l  = ls.get(i)
                float vv = tpo ? 1.0 : nz(vs.get(i))
                if not na(h) and not na(l) and vv > 0
                    int b0 = math.max(0, math.min(rows - 1, math.floor((l - lo) / rowH)))
                    int b1 = math.max(0, math.min(rows - 1, math.floor((h - lo) / rowH)))
                    if b1 == b0
                        bins.set(b0, bins.get(b0) + vv)
                    else
                        float barRng = h - l
                        for b = b0 to b1
                            float rLo = lo + b * rowH
                            float ov  = math.min(h, rLo + rowH) - math.max(l, rLo)
                            if ov > 0
                                bins.set(b, bins.get(b) + vv * ov / barRng)
            int   poc    = bins.indexof(bins.max())
            float target = bins.sum() * vaPct / 100.0
            float acc    = bins.get(poc)
            int   up     = poc
            int   dn     = poc
            while acc < target and (up < rows - 1 or dn > 0)
                float vUp = up < rows - 1 ? bins.get(up + 1) : -1.0
                float vDn = dn > 0 ? bins.get(dn - 1) : -1.0
                if vUp >= vDn
                    up  += 1
                    acc += vUp
                else
                    dn  -= 1
                    acc += vDn
            pPoc := lo + (poc + 0.5) * rowH
            pVah := lo + (up + 1) * rowH
            pVal := lo + dn * rowH
    [pPoc, pVah, pVal]

// ───────── Intrabar data (session-filtered) ─────────
string ltfRes = timeframe.in_seconds() <= timeframe.in_seconds(vpLTF) ? timeframe.period : vpLTF
[ltfH, ltfL, ltfV, ltfT] = request.security_lower_tf(syminfo.tickerid, ltfRes, [high, low, volume, time])

array<float> tH = array.new<float>()
array<float> tL = array.new<float>()
array<float> tV = array.new<float>()
int nIn = ltfH.size()
if nIn > 0
    for i = 0 to nIn - 1
        if not useSess or inSession(ltfT.get(i))
            tH.push(ltfH.get(i))
            tL.push(ltfL.get(i))
            tV.push(nz(ltfV.get(i)))
else if not useSess or inSession(time)
    tH.push(high)
    tL.push(low)
    tV.push(nz(volume))
bool anyIn = tH.size() > 0

// ───────── Profile state ─────────
var array<float> sH = array.new<float>()
var array<float> sL = array.new<float>()
var array<float> sV = array.new<float>()
var array<float> wH = array.new<float>()
var array<float> wL = array.new<float>()
var array<float> wV = array.new<float>()
var int   sessStart = na
var float pdPOC = na
var float pdVAH = na
var float pdVAL = na
var float pwVAH = na
var float pwVAL = na
var line  lnVAH = na
var line  lnVAL = na
var line  lnPOC = na
var line  lnPWH = na
var line  lnPWL = na
var array<line>  lvlHist = array.new<line>()
var array<line>  pwHist  = array.new<line>()
var array<line>  pocLn   = array.new<line>()   // unmitigated POCs
var array<float> pocPx   = array.new<float>()
var array<line>  pocDone = array.new<line>()   // mitigated POCs (if kept)

// POC mitigation — runs before a new POC is created, so a fresh POC starts checking on the next bar
if pocLn.size() > 0
    for i = pocLn.size() - 1 to 0
        line  ln = pocLn.get(i)
        float px = pocPx.get(i)
        ln.set_x2(bar_index)
        if low <= px and high >= px
            if pocKeep
                pocDone.push(ln)
                while pocDone.size() > lvlDays
                    pocDone.shift().delete()
            else
                ln.delete()
            pocLn.remove(i)
            pocPx.remove(i)

bool anchorChg = timeframe.change(vpAnchor)
bool newSess   = useSess ? (sH.size() > 0 and not anyIn) : anchorChg
bool newWeek   = timeframe.change("W")

// Daily (session) profile → PD levels
if newSess
    [p, vh, vl] = calcProfile(sH, sL, sV, vpRows, vpPct)
    pdPOC := p
    pdVAH := vh
    pdVAL := vl
    lnVAH := na
    lnVAL := na
    lnPOC := na
    if showLvls and not na(p)
        lnVAH := line.new(bar_index, vh, bar_index, vh, color = cVA, width = lvlW)
        lnVAL := line.new(bar_index, vl, bar_index, vl, color = cVA, width = lvlW)
        lvlHist.push(lnVAH)
        lvlHist.push(lnVAL)
        line pl = line.new(bar_index, p, bar_index, p, color = cPOC, width = lvlW, style = line.style_dashed)
        if pocExt
            pocLn.push(pl)
            pocPx.push(p)
            while pocLn.size() > pocMax
                pocLn.shift().delete()
                pocPx.shift()
        else
            lnPOC := pl
            lvlHist.push(pl)
        while lvlHist.size() > lvlDays * (pocExt ? 2 : 3)
            lvlHist.shift().delete()
    sH.clear()
    sL.clear()
    sV.clear()

// Weekly profile → PW levels
if newWeek
    [wp, wvh, wvl] = calcProfile(wH, wL, wV, vpRows, vpPct)
    pwVAH := wvh
    pwVAL := wvl
    lnPWH := na
    lnPWL := na
    if showPW and not na(wp)
        lnPWH := line.new(bar_index, wvh, bar_index, wvh, color = cPW, width = pwW)
        lnPWL := line.new(bar_index, wvl, bar_index, wvl, color = cPW, width = pwW)
        pwHist.push(lnPWH)
        pwHist.push(lnPWL)
        while pwHist.size() > pwKeep * 2
            pwHist.shift().delete()
    wH.clear()
    wL.clear()
    wV.clear()

if anyIn
    if sH.size() == 0
        sessStart := bar_index
    sH.concat(tH)
    sL.concat(tL)
    sV.concat(tV)
    wH.concat(tH)
    wL.concat(tL)
    wV.concat(tV)

if not na(lnVAH)
    lnVAH.set_x2(bar_index)
    lnVAL.set_x2(bar_index)
if not na(lnPOC)
    lnPOC.set_x2(bar_index)
if not na(lnPWH)
    lnPWH.set_x2(bar_index)
    lnPWL.set_x2(bar_index)

// ───────── Developing value area + right-edge labels ─────────
float dPOC = na
float dVAH = na
float dVAL = na
var array<line>  devLns = array.new<line>()
var array<label> rLbls  = array.new<label>()

if barstate.islast
    while devLns.size() > 0
        devLns.pop().delete()
    while rLbls.size() > 0
        rLbls.pop().delete()
    if showDev and sH.size() > 0
        [dp, dvh, dvl] = calcProfile(sH, sL, sV, vpRows, vpPct)
        dPOC := dp
        dVAH := dvh
        dVAL := dvl
        if not na(dp)
            color dVaC  = color.new(cVA, 40)
            color dPocC = color.new(cPOC, 40)
            devLns.push(line.new(sessStart, dvh, bar_index, dvh, color = dVaC, width = 1, style = line.style_dotted))
            devLns.push(line.new(sessStart, dvl, bar_index, dvl, color = dVaC, width = 1, style = line.style_dotted))
            devLns.push(line.new(sessStart, dp, bar_index, dp, color = dPocC, width = 1, style = line.style_dotted))
            if showDevLbl
                string dSz = textSize(devLblSz)
                rLbls.push(label.new(bar_index + 1, dvh, "dVAH", style = label.style_label_left, color = color(na), textcolor = dVaC, size = dSz))
                rLbls.push(label.new(bar_index + 1, dvl, "dVAL", style = label.style_label_left, color = color(na), textcolor = dVaC, size = dSz))
                rLbls.push(label.new(bar_index + 1, dp, "dPOC", style = label.style_label_left, color = color(na), textcolor = dPocC, size = dSz))
    if showLvls and not na(pdVAH)
        rLbls.push(label.new(bar_index + 1, pdVAH, "PDVAH", style = label.style_label_left, color = color(na), textcolor = cVA, size = size.small))
        rLbls.push(label.new(bar_index + 1, pdVAL, "PDVAL", style = label.style_label_left, color = color(na), textcolor = cVA, size = size.small))
        rLbls.push(label.new(bar_index + 1, pdPOC, "PDPOC", style = label.style_label_left, color = color(na), textcolor = cPOC, size = size.small))
    if showPW and not na(pwVAH)
        rLbls.push(label.new(bar_index + 1, pwVAH, "PWVAH", style = label.style_label_left, color = color(na), textcolor = cPW, size = size.small))
        rLbls.push(label.new(bar_index + 1, pwVAL, "PWVAL", style = label.style_label_left, color = color(na), textcolor = cPW, size = size.small))

// ───────── Gap source (chart or higher timeframe) ─────────
float atrC = ta.atr(14)

bool   useHTF = gapTF != "" and timeframe.in_seconds(gapTF) > timeframe.in_seconds()
string reqTF  = useHTF ? gapTF : timeframe.period
[hH0, hL0, hC0, hH2, hL2, hT2, hAtr] = request.security(syminfo.tickerid, reqTF, [high[1], low[1], close[1], high[3], low[3], time[3], ta.atr(14)[1]], lookahead = barmerge.lookahead_on)
bool reqChg = timeframe.change(reqTF)

bool  gNew = useHTF ? reqChg : true
float gH0  = useHTF ? hH0 : high
float gL0  = useHTF ? hL0 : low
float gC   = useHTF ? hC0 : close
float gH2  = useHTF ? hH2 : high[2]
float gL2  = useHTF ? hL2 : low[2]
int   gT2  = useHTF ? hT2 : time[2]
float gAtr = useHTF ? hAtr : atrC
float tol  = nz(gAtr) * tolAtr   // tolerance scales with the gap timeframe, so alignment is identical on any chart

var int gBar = 0
if gNew
    gBar += 1

// ───────── Zones ─────────
type Zone
    float  top
    float  bot
    int    dir
    int    origDir
    string kind
    int    left
    int    gIdx
    string tag = ""
    box    bx
    line   ce
    bool   drawn = false
    int    touches = 0
    bool   inside = false

alignTag(float top, float bot, float t) =>
    array<string> hits = array.new<string>()
    if usePWH and not na(pwVAH) and pwVAH <= top + t and pwVAH >= bot - t
        hits.push("wVAH")
    if useVAH and not na(pdVAH) and pdVAH <= top + t and pdVAH >= bot - t
        hits.push("VAH")
    if usePOC and not na(pdPOC) and pdPOC <= top + t and pdPOC >= bot - t
        hits.push("POC")
    if useVAL and not na(pdVAL) and pdVAL <= top + t and pdVAL >= bot - t
        hits.push("VAL")
    if usePWL and not na(pwVAL) and pwVAL <= top + t and pwVAL >= bot - t
        hits.push("wVAL")
    hits.join(" · ")

zColor(string kind, int dir) =>
    kind == "FVG" ? (dir == 1 ? cFvgBu : cFvgBe) : kind == "IFVG" ? (dir == 1 ? cIfvgBu : cIfvgBe) : (dir == 1 ? cBprBu : cBprBe)

kindOn(string kind) =>
    kind == "FVG" ? showFVG : kind == "IFVG" ? showIFVG : showBPR

zText(Zone z) =>
    string s = ""
    if showTxt
        s := z.kind + (z.dir == 1 ? "+" : "−")
        if z.tag != ""
            s += "  " + z.tag
        if showState
            s += "  · " + (z.touches == 0 ? "Fresh" : "T" + str.tostring(z.touches))
    s

zBg(Zone z) =>
    int tr = zTransp + (z.tag != "" ? 0 : 12) + (z.touches > 0 ? 8 : 0)
    color.new(zColor(z.kind, z.dir), math.min(100, tr))

eraseZone(Zone z) =>
    if z.drawn
        z.bx.delete()
        if not na(z.ce)
            z.ce.delete()
        z.drawn := false
    z.drawn

renderZone(Zone z, float t) =>
    z.tag := alignTag(z.top, z.bot, t)
    bool aligned = z.tag != ""
    if kindOn(z.kind) and (aligned or alMode == "Highlight Aligned") and not (freshOnly and z.touches > 0)
        color c = zColor(z.kind, z.dir)
        z.bx := box.new(z.left, z.top, time, z.bot, xloc = xloc.bar_time, border_color = color.new(c, aligned ? 0 : 60), border_width = 1, border_style = line.style_dotted, bgcolor = zBg(z), text = zText(z), text_color = color.new(c, aligned ? 0 : 40), text_size = textSize(txtSz), text_halign = text.align_right, text_valign = text.align_center)
        if showCE
            float mid = (z.top + z.bot) / 2
            z.ce := line.new(z.left, mid, time, mid, xloc = xloc.bar_time, color = color.new(c, aligned ? 10 : 50), style = line.style_dashed, width = 1)
        z.drawn := true
    aligned

var array<Zone> zones = array.new<Zone>()

bool aFvgBu  = false
bool aFvgBe  = false
bool aIfvgBu = false
bool aIfvgBe = false
bool aBprBu  = false
bool aBprBe  = false
bool aTestBu = false
bool aTestBe = false

// New day or week → new levels: re-check zones that weren't aligned before
if (newSess or newWeek) and zones.size() > 0
    for z in zones
        if not z.drawn
            renderZone(z, tol)

// Update existing zones: state, inversion, invalidation
if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        bool dead = gBar - z.gIdx > maxAge
        // State tracking on every chart bar
        if not dead
            bool touch = z.dir == 1 ? low <= z.top : high >= z.bot
            bool away  = z.dir == 1 ? low > z.top : high < z.bot
            if not z.inside and touch
                z.inside  := true
                z.touches += 1
                if z.touches == 1 and z.tag != "" and kindOn(z.kind)
                    if z.dir == 1
                        aTestBu := true
                    else
                        aTestBe := true
                if z.drawn
                    if freshOnly
                        eraseZone(z)
                    else
                        z.bx.set_text(zText(z))
                        z.bx.set_bgcolor(zBg(z))
            else if z.inside and away
                z.inside := false
        // Inversion / invalidation on the gap timeframe's close
        if not dead and gNew
            if z.kind == "FVG"
                bool inv = (z.dir == 1 and gC < z.bot) or (z.dir == -1 and gC > z.top)
                if inv
                    eraseZone(z)
                    z.kind    := "IFVG"
                    z.dir     := -z.dir
                    z.touches := 0
                    z.inside  := false
                    bool al = renderZone(z, tol)
                    if al and showIFVG
                        if z.dir == 1
                            aIfvgBu := true
                        else
                            aIfvgBe := true
            else
                dead := (z.dir == 1 and gC < z.bot) or (z.dir == -1 and gC > z.top)
        if dead
            if z.drawn
                if delDead
                    eraseZone(z)
                else
                    z.bx.set_right(time)
                    if not na(z.ce)
                        z.ce.set_x2(time)
            zones.remove(i)
        else if z.drawn
            z.bx.set_right(time)
            if not na(z.ce)
                z.ce.set_x2(time)

// Detect new FVGs (+ BPR pairing)
float minGap  = nz(gAtr) * minGapAtr
bool  bullGap = gNew and gL0 > gH2 and gL0 - gH2 >= minGap
bool  bearGap = gNew and gH0 < gL2 and gL2 - gH0 >= minGap

if bullGap or bearGap
    int   d  = bullGap ? 1 : -1
    float zt = bullGap ? gL0 : gL2
    float zb = bullGap ? gH2 : gH0
    Zone fz = Zone.new(top = zt, bot = zb, dir = d, origDir = d, kind = "FVG", left = gT2, gIdx = gBar)
    bool al = renderZone(fz, tol)
    if al and showFVG
        if d == 1
            aFvgBu := true
        else
            aFvgBe := true
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            Zone o = zones.get(i)
            if gBar - o.gIdx > bprWin
                break
            if o.kind != "BPR" and o.origDir == -d
                float ot = math.min(o.top, zt)
                float ob = math.max(o.bot, zb)
                if ot > ob
                    Zone bz = Zone.new(top = ot, bot = ob, dir = d, origDir = d, kind = "BPR", left = gT2, gIdx = gBar)
                    bool alB = renderZone(bz, tol)
                    if alB and showBPR
                        if d == 1
                            aBprBu := true
                        else
                            aBprBe := true
                    zones.push(bz)
                    break
    zones.push(fz)

while zones.size() > 250
    Zone old = zones.shift()
    eraseZone(old)

// ───────── Dashboard ─────────
dashRow(table t, int r, string k, string v, color vc) =>
    table.cell(t, 0, r, k, text_color = color.silver, text_size = size.tiny, text_font_family = font.family_monospace, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = vc, text_size = size.tiny, text_font_family = font.family_monospace, text_halign = text.align_right)

var table dash = table.new(tblPos(dashPos), 2, 11, bgcolor = color.new(#0A1426, 5), border_color = color.new(#FF8C2E, 70), border_width = 1, frame_color = #FF8C2E, frame_width = 1)
if barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)

if showDash and barstate.islast
    int nF = 0
    int nI = 0
    int nB = 0
    int nFresh = 0
    for z in zones
        if z.drawn and z.tag != ""
            if z.kind == "FVG"
                nF += 1
            else if z.kind == "IFVG"
                nI += 1
            else
                nB += 1
            if z.touches == 0
                nFresh += 1
    string loc  = na(pdVAH) ? "—" : close > pdVAH ? "Above Value" : close < pdVAL ? "Below Value" : "Inside Value"
    color  locC = na(pdVAH) ? color.silver : close > pdVAH ? #26A69A : close < pdVAL ? #EF5350 : color.silver
    string src  = "Gaps " + (useHTF ? gapTF : timeframe.period) + " · " + (useSess ? "Sess " + str.substring(sessStr, 0, 9) : "Anchor " + vpAnchor)
    table.cell(dash, 0, 0, "T4T VA GAPS", text_color = #FF8C2E, text_size = size.small, text_font_family = font.family_monospace)
    dashRow(dash, 1, "PWVAH", fmt(pwVAH), cPW)
    dashRow(dash, 2, "PDVAH", fmt(pdVAH), cVA)
    dashRow(dash, 3, "PDPOC", fmt(pdPOC), cPOC)
    dashRow(dash, 4, "PDVAL", fmt(pdVAL), cVA)
    dashRow(dash, 5, "PWVAL", fmt(pwVAL), cPW)
    dashRow(dash, 6, "dPOC", showDev ? fmt(dPOC) : "off", color.new(cPOC, 30))
    dashRow(dash, 7, "Price", loc, locC)
    dashRow(dash, 8, "Aligned", "FVG " + str.tostring(nF) + " · IFVG " + str.tostring(nI) + " · BPR " + str.tostring(nB), color.white)
    dashRow(dash, 9, "Fresh", str.tostring(nFresh) + " of " + str.tostring(nF + nI + nB), #FF8C2E)
    dashRow(dash, 10, "Source", src, color.silver)

// ───────── Data window ─────────
plot(pwVAH, "PWVAH", color = cPW, display = display.data_window)
plot(pdVAH, "PDVAH", color = cVA, display = display.data_window)
plot(pdPOC, "PDPOC", color = cPOC, display = display.data_window)
plot(pdVAL, "PDVAL", color = cVA, display = display.data_window)
plot(pwVAL, "PWVAL", color = cPW, display = display.data_window)

// ───────── Alerts ─────────
alertcondition(aFvgBu,  "Aligned Bullish FVG",  "T4T VA Gaps: Bullish FVG at value level on {{ticker}}")
alertcondition(aFvgBe,  "Aligned Bearish FVG",  "T4T VA Gaps: Bearish FVG at value level on {{ticker}}")
alertcondition(aIfvgBu, "Aligned Bullish IFVG", "T4T VA Gaps: Bullish IFVG at value level on {{ticker}}")
alertcondition(aIfvgBe, "Aligned Bearish IFVG", "T4T VA Gaps: Bearish IFVG at value level on {{ticker}}")
alertcondition(aBprBu,  "Aligned Bullish BPR",  "T4T VA Gaps: Bullish BPR at value level on {{ticker}}")
alertcondition(aBprBe,  "Aligned Bearish BPR",  "T4T VA Gaps: Bearish BPR at value level on {{ticker}}")
alertcondition(aTestBu, "First Test · Aligned Bullish Zone", "T4T VA Gaps: First test of an aligned bullish zone on {{ticker}}")
alertcondition(aTestBe, "First Test · Aligned Bearish Zone", "T4T VA Gaps: First test of an aligned bearish zone on {{ticker}}")

string msg = ""
msg += aFvgBu  ? "Bullish FVG · "  : ""
msg += aFvgBe  ? "Bearish FVG · "  : ""
msg += aIfvgBu ? "Bullish IFVG · " : ""
msg += aIfvgBe ? "Bearish IFVG · " : ""
msg += aBprBu  ? "Bullish BPR · "  : ""
msg += aBprBe  ? "Bearish BPR · "  : ""
msg += aTestBu ? "First test of aligned bullish zone · " : ""
msg += aTestBe ? "First test of aligned bearish zone · " : ""
if msg != ""
    alert("T4T VA Gaps " + syminfo.ticker + ": " + msg, alert.freq_once_per_bar_close)
````
