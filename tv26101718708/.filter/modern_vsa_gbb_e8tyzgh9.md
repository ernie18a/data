# Modern VSA [GBB]

- url: https://www.tradingview.com/script/e8TyzgH9-Modern-VSA-GBB/
- type: indicator
- pine_id: PUB;592e8415cf2f40c49fed3be227d1e22c
- version: 1.0

## Description

Modern VSA marks Volume Spread Analysis bars on the chart, but only the ones that held up when they were checked against real order flow. It is a confluence tool: read the labels together with your own levels, structure and context, not on their own.

[b]HOW IT WORKS[/b]

Volume Spread Analysis reads each candle as effort (volume) against result (the bar's range and where it closes). Classic VSA names a pattern and then assumes what the hidden buyers and sellers did. Modern VSA tested that assumption for every classic label, using aggressor-classified trades (who hit the bid, who lifted the offer) on ES and NQ futures.
[b]
WHAT YOU SEE[/b]

• Spring ▲ below a bar: price broke the low of the previous 10 bars on above-average volume, then closed back in the top 30% of the bar.
• Upthrust ▼ above a bar: the mirror image at the high of the previous 10 bars, closing in the bottom 30%.
• Outlook fan from the latest signal: how price moved over the next 10 bars after the same pattern on this chart's own history (last 5,000 bars), in ATR units, next to a grey band for unlabelled bars of similar volume. Hover the signal label for the numbers: the number of separate cases, how often price went the claimed way compared with bars of the same colour, and the chance check.
• Chance check: the pattern's cases are compared with 200 random placements on the same history. "Rare by chance" means fewer than 5% of the random tries showed a gap this large. Random signals read "rare" about 5% of the time, so a few rare readings on any chart are expected.
• Effort-vs-result candle tint (optional): warm when a bar took more volume than its body suggests, cool when it moved easily. Display only; not tested as a signal.

[b]WHY ONLY TWO LABELS ARE ON[/b]

Each classic label was tested on a year of ES and NQ 1-minute data held out from development, then on 2011–2025 tick data that had never been used. The question: does the label's context show the order flow VSA claims, beyond what the candle's own shape, volume and colour already imply?

• Spring and Upthrust: yes. The trapped traders VSA describes are visible in the tape. These bars show the claimed counter-side aggression about 5 to 7 percentage points more often than a plain break of the 10-bar extreme, and the effect was positive in each of the 15 years on both markets. A later, simpler check (against bars of the same colour) found the same flow on gold futures 1-minute bars.
• Climax, Absorption, No Supply and No Demand: no. They looked no different from ordinary bars of the same shape and volume. They are off by default; "Show unchecked labels" brings them back, drawn hollow, for traditional VSA readers.

[b]WHAT IT DOES NOT DO[/b]

The labels describe the bar that has just closed. They are not entry signals and do not forecast direction on their own. Apart from a slight lean towards reversal on 1-minute bars, the labels showed no directional edge on 5m, 15m or 1h, before or after costs. Simple trades with or against Spring and Upthrust on ES and NQ, from 15m to 4h, with market or limit entries, did not make money after costs in any tested setup. Use a label as one more piece of evidence at a level you are already watching.

[b]SETTINGS[/b]

• Judge volume by time of day (on by default): volume is compared with the same time of day over the last 20 sessions, so the session open does not flag every busy bar. It needs 5 sessions of history at the chart's timeframe; until then the 100-bar average is used and the chart says so.
• Session filter: bars outside the session are never labelled and never enter any calculation.
• Higher-timeframe trend filter (off): an untested convenience. It hides labels against the higher-timeframe EMA slope; it does not make the remaining labels better.
• Classic mode: every label on, plain 100-bar average volume, no Outlook.
• Outlook: latest signal or every signal, keep past fans with the path that followed, fan statistics as text.
• Palette, theme, label size, stats table.
• Alerts: Spring, Upthrust, either of the two, and each unchecked label.
[b]
NOTES[/b]

• Labels and alerts appear only when the bar closes and are not redrawn afterwards.
• The indicator needs volume data. The order-flow check was done on ES and NQ futures; on other markets the labels follow the same price-and-volume rules, but their order flow has not been checked there.
• The fan and its numbers are descriptive statistics of this chart's own history, not a forecast.

Modern VSA is a confluence tool, not a buy or sell signal.

## Source Code

````pine
//@version=6
// Modern VSA [GBB]  
indicator("Modern VSA [GBB]", "MVSA", overlay = true, max_labels_count = 500, max_polylines_count = 100, max_lines_count = 300, max_boxes_count = 300, max_bars_back = 500)

// ---------------------------------------------------------------- inputs
grpM = "Mode"
modeSel = input.string("Modern", "Mode", options = ["Modern", "Classic"], group = grpM,
     tooltip = "Classic: plain 100-bar average volume, every label on, no Outlook.")

grpL = "Labels"
showUpthrust   = input.bool(true, "Upthrust (flow-consistent)", group = grpL,
     tooltip = "On ES/NQ 1m an Upthrust bar carried 5.1 (ES) and 7.6 (NQ) points more aggressive buying than a new high alone; 7.6 and 5.1 on 2011-2025.")
showSpring     = input.bool(true, "Spring (flow-consistent, owner override)", group = grpL,
     tooltip = "Spring missed the pre-registered rule by 0.1 point in the study (6.0 ES, 4.9 NQ) and showed the same effect as Upthrust on 2011-2025 (7.2 ES, 5.1 NQ). On by the owner's decision.")
showUnchecked  = input.bool(false, "Show unchecked labels", group = grpL,
     tooltip = "Climax, Absorption, No Supply and No Demand did not show the order flow VSA claims beyond what the candle's own shape, volume and colour imply. Drawn hollow when shown.")
showClimax     = input.bool(true, "    Climax", group = grpL)
showAbsorption = input.bool(true, "    Absorption", group = grpL)
showNoSD       = input.bool(true, "    No Supply / No Demand", group = grpL)

grpV = "Volume"
inDiurnal = input.bool(true, "Judge volume by time of day", group = grpV,
     tooltip = "Volume is compared with the same time of day over the last 20 sessions, so the session open does not flag every bar. Needs 5 sessions of history at the chart's timeframe; until then the 100-bar average is used, and the chart says so.")
useSess = input.bool(false, "Session filter", group = grpV, tooltip = "Bars outside the session are never labelled and never enter any calculation.")
sessStr = input.session("0930-1600", "Session", group = grpV)

grpB = "Background"
htfFilter = input.bool(false, "HTF trend filter (untested convenience)", group = grpB,
     tooltip = "Shows only labels in the direction of the higher-timeframe EMA(50) slope. Not tested in the study; it hides labels, it does not make them better.")
htfSel    = input.timeframe("", "HTF (blank = 4x chart)", group = grpB)

grpO = "Outlook"
outOn       = input.bool(true, "Outlook fan", group = grpO,
     tooltip = "How price moved after the same pattern on this chart's own history (last 5,000 bars, 10 bars ahead), next to a grey fan of similar-volume bars.")
fanMode     = input.string("Latest signal", "Show for", options = ["Latest signal", "Every signal"], group = grpO)
honesty     = input.bool(false, "Keep past fans with the path that followed", group = grpO)
fanText     = input.bool(false, "Show the fan statistics as text", group = grpO,
     tooltip = "Off: no text on the chart; hover the signal label to see the numbers.")

grpS = "Style"
paletteSel   = input.string("GBB", "Palette", options = ["GBB", "Mono"], group = grpS)
themeSel     = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpS)
tintOn       = input.bool(true, "Effort-vs-result candle tint", group = grpS,
     tooltip = "Warm body: more volume than the candle's body suggests. Cool body: an easy move. Wick and border keep the candle's direction. Display only; not tested as a signal.")
labelStyleSel = input.string("Tag", "Label style", options = ["Tag", "Marker", "Text"], group = grpS,
     tooltip = "Tag: pointed pill on the wick. Marker: triangle only, name in the tooltip. Text: the v0.1 look.")
labelSizeSel = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpS)
zonesOn      = input.bool(true, "Signal zones", group = grpS,
     tooltip = "Shades the signal bar's rejection wick and extends its extreme (Upthrust high, Spring low) until a bar closes through it or 40 bars pass. Display only; not tested as a signal.")


// ---------------------------------------------------------------- constants and palette
// Study parameters: fixed, not inputs (the published statistics belong to these values).
int D           = 20      // same-time bars in the slot median
int L           = 100     // rank window
int H           = 10      // Outlook horizon (bars)
int W           = 5000    // Outlook statistics window (bars)
int fanLookback = 300     // fans are computed for signals in the last 300 bars (raise in a copy for a parity export)
bool showInner  = true
bool showOuter  = true
bool showGrey   = true
bool chanceOn   = true
int K       = 10      // leg length
int ATRN    = 14
int EXTN    = 10      // prior bars for the Spring / Upthrust extreme
int MINSLOT = 5
int NSHIFT  = 200     // chance-check shifts
int CAP     = W + 5   // bars kept for the Outlook window
int ZMAX    = 40      // max zone extension (bars), display only

bool classic    = modeSel == "Classic"
bool useDiurnal = inDiurnal and not classic and not timeframe.isdwm
bool outlookOn  = outOn and not classic

float bgLum = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) / 255
bool lightTheme = themeSel == "Light" or (themeSel == "Auto" and bgLum > 0.5)
color cBull  = paletteSel == "Mono" ? (lightTheme ? #212121 : #ffffff) : lightTheme ? #148f5c : #3ecf8e
color cBear  = paletteSel == "Mono" ? (lightTheme ? #757575 : #bdbdbd) : lightTheme ? #cc2f4a : #ef5368
color cWarm  = paletteSel == "Mono" ? #757575 : lightTheme ? #b3721c : #e2a349
color cCool  = paletteSel == "Mono" ? #9e9e9e : lightTheme ? #0b93a6 : #45c8da
color cFan   = paletteSel == "Mono" ? (lightTheme ? #424242 : #e0e0e0) : lightTheme ? #6a5fb5 : #9187d6
color cGrey  = #9e9e9e
color cInk   = lightTheme ? #0a0c10 : color.white
color cPanel = lightTheme ? color.white : #0a0c10
string lblSize = labelSizeSel == "Tiny" ? size.tiny : labelSizeSel == "Normal" ? size.normal : size.small

string DISCLAIMER = "Descriptive statistics of this chart's own history, not a forecast. Modern VSA is a confluence tool, not a buy or sell signal."

// ---------------------------------------------------------------- state
type SlotHist
    array<float> v

var map<int, SlotHist> slots = map.new<int, SlotHist>()
var array<float> wS   = array.new<float>()   // last L values of spread / ATR[1]
var array<float> wV   = array.new<float>()   // last L values of relative volume
var array<float> wB   = array.new<float>()   // last L values of |body| / ATR[1]
var array<float> wVol = array.new<float>()   // last L volumes (SMA fallback)

// one entry per accepted bar (in session), oldest first, at most CAP
var array<float> aC   = array.new<float>()
var array<float> aH   = array.new<float>()
var array<float> aL   = array.new<float>()
var array<float> aV   = array.new<float>()
var array<float> aATR = array.new<float>()
var array<int>   aCode = array.new<int>()
var array<int>   aGrp  = array.new<int>()
var array<int>   aSide = array.new<int>()
var array<int>   aDir  = array.new<int>()
var array<int>   aVq   = array.new<int>()
var array<int>   aBi   = array.new<int>()
var array<float> aUp  = array.new<float>()   // 1 / 0 once the H-bar outcome is complete, na before
var array<float> aDn  = array.new<float>()
var array<float> aRx  = array.new<float>()   // H-bar range / ATR at the bar

var float atrPrev = na
var float trSum   = 0.0
var int   trN     = 0
var float erEma   = na

// ---------------------------------------------------------------- functions
// Integer percentile rank: 2 x count(prior < x) + count(prior == x); -1 when na.
rank2(array<float> win, float x, int len) =>
    int r = -1
    if win.size() == len and not na(x)
        int lt = 0
        int eq = 0
        bool bad = false
        for v in win
            if na(v)
                bad := true
                break
            if v < x
                lt += 1
            else if v == x
                eq += 1
        r := bad ? -1 : 2 * lt + eq
    r

pushCap(array<float> win, float x, int len) =>
    win.push(x)
    if win.size() > len
        win.shift()

thr(int P) =>
    int(math.floor(2.0 * L * P / 100.0))

// close location >= a/10 and <= a/10, in integer ticks; a zero-spread bar counts as exactly 0.5
clGe(int clT, int spT, int a) =>
    spT == 0 ? a == 5 : 10 * clT >= a * spT

clLe(int clT, int spT, int a) =>
    spT == 0 ? a == 5 : 10 * clT <= a * spT

labelName(int code) =>
    code == 1 or code == 2 ? "Climax" : code == 3 or code == 4 ? "Absorption" : code == 5 ? "Spring" : code == 6 ? "Upthrust" : code == 7 ? "No Supply" : code == 8 ? "No Demand" : ""

groupName(int grp) =>
    grp == 0 ? "Climax" : grp == 1 ? "Absorption" : grp == 2 ? "Spring / Upthrust" : "No Supply / No Demand"

minCasesOf(int grp) =>
    grp == 0 ? 20 : 30

// The Outlook statistics at accepted bar t (local index) for a label group, as mvsa_outlook.outlook computes them.
outlookAt(int t, int grp, int sideSig, int sigTime) =>
    int w0 = math.max(0, t - W + 1)
    int weff = t - w0 + 1
    array<int> evAll = array.new<int>()
    for j = w0 to t
        if aGrp.get(j) == grp
            evAll.push(j)
    // separate cases: at least H bars after the previous counted event; then complete outcomes only
    array<int> cases = array.new<int>()
    int lastJ = -1000000000
    for j in evAll
        if j - lastJ >= H
            lastJ := j
            if j + H <= t
                cases.push(j)
    int n = cases.size()
    float hitRate = na
    float baseRate = na
    float gap = na
    float moveR = na
    float share = na
    array<float> q10 = array.new<float>()
    array<float> q25 = array.new<float>()
    array<float> q50 = array.new<float>()
    array<float> q75 = array.new<float>()
    array<float> q90 = array.new<float>()
    array<float> g25 = array.new<float>()
    array<float> g75 = array.new<float>()
    if n >= minCasesOf(grp) and t - H >= w0
        // same-direction baseline: rates of up / down H-bar moves for down, flat and up bars of the window
        array<float> cnt = array.new<float>(3, 0.0)
        array<float> ups = array.new<float>(3, 0.0)
        array<float> dns = array.new<float>(3, 0.0)
        for j = w0 to t - H
            int d = aDir.get(j) + 1
            cnt.set(d, cnt.get(d) + 1)
            ups.set(d, ups.get(d) + aUp.get(j))
            dns.set(d, dns.get(d) + aDn.get(j))
        array<float> upR = array.new<float>(3, na)
        array<float> dnR = array.new<float>(3, na)
        for d = 0 to 2
            if cnt.get(d) > 0
                upR.set(d, ups.get(d) / cnt.get(d))
                dnR.set(d, dns.get(d) / cnt.get(d))
        float hits = 0.0
        float bsum = 0.0
        for j in cases
            int s = aSide.get(j)
            int d = aDir.get(j) + 1
            hits += s > 0 ? aUp.get(j) : aDn.get(j)
            bsum += s > 0 ? upR.get(d) : dnR.get(d)
        hitRate := hits / n
        baseRate := bsum / n
        gap := hitRate - baseRate
        // movement: median of (case range multiple / median range multiple of unlabelled bars in its volume quintile)
        array<float> m0 = array.new<float>()
        array<float> m1 = array.new<float>()
        array<float> m2 = array.new<float>()
        array<float> m3 = array.new<float>()
        array<float> m4 = array.new<float>()
        for j = w0 to t - H
            int q = aVq.get(j)
            float rx = aRx.get(j)
            if aCode.get(j) == 0 and q >= 0 and not na(rx)
                if q == 0
                    m0.push(rx)
                else if q == 1
                    m1.push(rx)
                else if q == 2
                    m2.push(rx)
                else if q == 3
                    m3.push(rx)
                else
                    m4.push(rx)
        array<float> med = array.from(m0.size() > 0 ? m0.median() : na, m1.size() > 0 ? m1.median() : na,
             m2.size() > 0 ? m2.median() : na, m3.size() > 0 ? m3.median() : na, m4.size() > 0 ? m4.median() : na)
        array<float> ratios = array.new<float>()
        for j in cases
            int q = aVq.get(j)
            if q >= 0
                float r = aRx.get(j) / med.get(q)
                if not na(r)
                    ratios.push(r)
        moveR := ratios.size() > 0 ? ratios.median() : na
        // chance check: 200 circular shifts of the label's events inside the window, offsets from the LCG
        if chanceOn and weff - 10 * H > 0
            int x = int(math.floor(sigTime / 60000.0)) % 2147483646 + 1
            int span = weff - 10 * H
            int m = evAll.size()
            int reach = 0
            for b = 1 to NSHIFT
                x := (x * 48271) % 2147483647
                int off = 5 * H + x % span
                // the shifted list is the sorted list rotated: start at the first event that wraps
                int split = m
                for i = 0 to m - 1
                    if evAll.get(i) - w0 + off >= weff
                        split := i
                        break
                int lastP = -1000000000
                int c2 = 0
                float h2 = 0.0
                float b2 = 0.0
                for k = 0 to m - 1
                    int i = (split + k) % m
                    int p = (evAll.get(i) - w0 + off) % weff + w0
                    if p - lastP >= H
                        lastP := p
                        if p + H <= t
                            int s = aSide.get(evAll.get(i))
                            int d = aDir.get(p) + 1
                            c2 += 1
                            h2 += s > 0 ? aUp.get(p) : aDn.get(p)
                            b2 += s > 0 ? upR.get(d) : dnR.get(d)
                if c2 > 0
                    float g2 = h2 / c2 - b2 / c2
                    if math.abs(g2) >= math.abs(gap) - 1e-12
                        reach += 1
            share := (reach + 1.0) / (NSHIFT + 1.0)
        // fan: path quantiles in ATR units, signed by the claimed direction
        int vqT = aVq.get(t)
        int sSig = sideSig != 0 ? sideSig : 1
        for k = 1 to H
            array<float> vals = array.new<float>()
            for j in cases
                vals.push(aSide.get(j) * (aC.get(j + k) - aC.get(j)) / aATR.get(j))
            q10.push(vals.percentile_linear_interpolation(10))
            q25.push(vals.percentile_linear_interpolation(25))
            q50.push(vals.percentile_linear_interpolation(50))
            q75.push(vals.percentile_linear_interpolation(75))
            q90.push(vals.percentile_linear_interpolation(90))
            array<float> gv = array.new<float>()
            for j = w0 to t - H
                if aCode.get(j) == 0 and aVq.get(j) >= 0 and aVq.get(j) == vqT
                    gv.push(sSig * (aC.get(j + k) - aC.get(j)) / aATR.get(j))
            g25.push(gv.size() > 0 ? gv.percentile_linear_interpolation(25) : na)
            g75.push(gv.size() > 0 ? gv.percentile_linear_interpolation(75) : na)
    [n, hitRate, baseRate, gap, moveR, share, q10, q25, q50, q75, q90, g25, g75]

bandPoints(int bi, float c0, float a0, int s, array<float> upper, array<float> lower) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_index(bi, c0))
    for k = 1 to upper.size()
        pts.push(chart.point.from_index(bi + k, c0 + s * upper.get(k - 1) * a0))
    for k = lower.size() to 1
        pts.push(chart.point.from_index(bi + k, c0 + s * lower.get(k - 1) * a0))
    pts

linePoints(int bi, float c0, float a0, int s, array<float> q) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_index(bi, c0))
    for k = 1 to q.size()
        pts.push(chart.point.from_index(bi + k, c0 + s * q.get(k - 1) * a0))
    pts

// ---------------------------------------------------------------- the bar
string htfTf = htfSel == "" ? timeframe.from_seconds(timeframe.in_seconds() * 4) : htfSel
float htfSlope = request.security(syminfo.tickerid, htfTf, (ta.ema(close, 50) - ta.ema(close, 50)[1])[1], lookahead = barmerge.lookahead_on)

bool inSess = not useSess or not na(time(timeframe.period, sessStr, syminfo.timezone))
int code = 0
int sideNow = 0
int r2v = -1
int r2s = -1
int r2b = -1
int vqNow = -1
bool diurnalActive = false
bool isSignal = false

if inSess
    int n0 = aC.size()
    float prevC = n0 > 0 ? aC.last() : na
    int dirNow = na(prevC) ? 0 : close > prevC ? 1 : close < prevC ? -1 : 0
    // ATR(14), RMA seeded with the mean of the first 14 true ranges (ta.atr on the accepted bars)
    float tr = na(prevC) ? high - low : math.max(high - low, math.max(math.abs(high - prevC), math.abs(low - prevC)))
    float atrNow = na
    if na(atrPrev)
        trSum += tr
        trN += 1
        if trN == ATRN
            atrNow := trSum / ATRN
    else
        atrNow := (1.0 / ATRN) * tr + (1 - 1.0 / ATRN) * atrPrev
    float atr1 = n0 > 0 ? aATR.last() : na
    float xS = high - low
    xS := na(atr1) or atr1 == 0 ? na : xS / atr1
    float xB = na(atr1) or atr1 == 0 ? na : math.abs(close - open) / atr1
    // relative volume: by time of day when 5 same-slot bars exist, else against the 100-bar average
    float smaPrev = wVol.size() == L ? wVol.avg() : na
    float fallback = not na(smaPrev) and smaPrev > 0 ? volume / smaPrev : na
    float rv = fallback
    int slot = hour(time, syminfo.timezone) * 60 + minute(time, syminfo.timezone)
    if useDiurnal
        SlotHist sh = slots.get(slot)
        if na(sh)
            sh := SlotHist.new(array.new<float>())
            slots.put(slot, sh)
        if sh.v.size() >= MINSLOT
            float md = sh.v.median()
            rv := md > 0 ? volume / md : na
            diurnalActive := true
        sh.v.push(volume)
        if sh.v.size() > D
            sh.v.shift()
    r2s := rank2(wS, xS, L)
    r2v := rank2(wV, rv, L)
    r2b := rank2(wB, xB, L)
    vqNow := r2v >= 0 ? math.min(int(math.floor(r2v / math.floor(2.0 * L / 5.0))), 4) : -1
    float leg = n0 >= K + 1 and not na(atr1) and atr1 != 0 ? (aC.get(n0 - 1) - aC.get(n0 - 1 - K)) / atr1 : na
    bool vPrev2 = n0 >= 2 ? volume < aV.get(n0 - 1) and volume < aV.get(n0 - 2) : false
    float lowMin = na
    float highMax = na
    if n0 >= EXTN
        lowMin := aL.get(n0 - 1)
        highMax := aH.get(n0 - 1)
        for i = 2 to EXTN
            lowMin := math.min(lowMin, aL.get(n0 - i))
            highMax := math.max(highMax, aH.get(n0 - i))
    bool newLow = not na(lowMin) and low < lowMin
    bool newHigh = not na(highMax) and high > highMax
    int spT = int(math.round((high - low) / syminfo.mintick))
    int clT = int(math.round((close - low) / syminfo.mintick))
    bool valid = r2s >= 0 and r2v >= 0 and not na(leg)
    bool up = dirNow == 1
    bool dn = dirNow == -1
    if valid
        if dn and r2s <= thr(30) and r2v <= thr(30) and vPrev2
            code := 7
        if up and r2s <= thr(30) and r2v <= thr(30) and vPrev2
            code := 8
        if clGe(clT, spT, 7) and r2v >= thr(60) and newLow
            code := 5
        if clLe(clT, spT, 3) and r2v >= thr(60) and newHigh
            code := 6
        if r2v >= thr(85) and r2s <= thr(50) and clGe(clT, spT, 5) and leg <= -1.0
            code := 3
        if r2v >= thr(85) and r2s <= thr(50) and clLe(clT, spT, 5) and leg >= 1.0
            code := 4
        if r2v >= thr(95) and r2s >= thr(85) and dn and clGe(clT, spT, 4) and leg <= -1.0
            code := 1
        if r2v >= thr(95) and r2s >= thr(85) and up and clLe(clT, spT, 6) and leg >= 1.0
            code := 2
    sideNow := code == 0 ? 0 : code % 2 == 1 ? 1 : -1
    // windows and per-bar store
    pushCap(wS, xS, L)
    pushCap(wV, rv, L)
    pushCap(wB, xB, L)
    pushCap(wVol, volume, L)
    aC.push(close)
    aH.push(high)
    aL.push(low)
    aV.push(volume)
    aATR.push(atrNow)
    aCode.push(code)
    aGrp.push(code == 0 ? -1 : int((code - 1) / 2))
    aSide.push(sideNow)
    aDir.push(dirNow)
    aVq.push(vqNow)
    aBi.push(bar_index)
    aUp.push(na)
    aDn.push(na)
    aRx.push(na)
    if aC.size() > CAP
        aC.shift()
        aH.shift()
        aL.shift()
        aV.shift()
        aATR.shift()
        aCode.shift()
        aGrp.shift()
        aSide.shift()
        aDir.shift()
        aVq.shift()
        aBi.shift()
        aUp.shift()
        aDn.shift()
        aRx.shift()
    if not na(atrNow)
        atrPrev := atrNow
    // the outcome of the bar H accepted bars back is now complete
    int t = aC.size() - 1
    int j = t - H
    if j >= 0
        float hh = aH.get(j + 1)
        float ll = aL.get(j + 1)
        for i = j + 2 to t
            hh := math.max(hh, aH.get(i))
            ll := math.min(ll, aL.get(i))
        aRx.set(j, (hh - ll) / aATR.get(j))
        aUp.set(j, aC.get(t) > aC.get(j) ? 1.0 : 0.0)
        aDn.set(j, aC.get(t) < aC.get(j) ? 1.0 : 0.0)
    // effort-vs-result tint (display only)
    if r2v >= 0 and r2b >= 0
        float raw = (r2v - r2b) / (2.0 * L) * 100.0
        erEma := na(erEma) ? raw : erEma + (2.0 / 4.0) * (raw - erEma)

// ---------------------------------------------------------------- labels
int grpNow = code == 0 ? -1 : int((code - 1) / 2)
bool checkedSide = code == 5 or code == 6
bool sideToggle = code == 5 ? showSpring : code == 6 ? showUpthrust : grpNow == 0 ? showClimax : grpNow == 1 ? showAbsorption : grpNow == 3 ? showNoSD : false
bool shown = code > 0 and (classic or (sideToggle and (checkedSide or showUnchecked)))
shown := shown and (not htfFilter or na(htfSlope) or (sideNow > 0 ? htfSlope > 0 : htfSlope < 0))
isSignal := shown and barstate.isconfirmed

string FLOW_TIP_UP = "Upthrust: new 10-bar high on above-average volume, close in the lower 30%.\nFlow-consistent on ES/NQ 1m: +5.1 pts (CI +2.0 to +8.2) on ES, +7.6 pts (CI +5.2 to +10.1) on NQ more aggressive buying than a new high alone. Replicated on 2011-2025: +7.6 and +5.1.\nAbout the bar itself, not what follows."
string FLOW_TIP_SP = "Spring: new 10-bar low on above-average volume, close in the upper 30%.\nES/NQ 1m: +6.0 pts (CI +3.3 to +8.5) on ES, +4.9 pts (CI +2.3 to +7.4) on NQ more aggressive selling than a new low alone; 2011-2025: +7.2 and +5.1. On by owner override of the pre-registered rule (it missed by 0.1 point).\nAbout the bar itself, not what follows."
string UNCHECKED_TIP = "unchecked: on ES/NQ this label did not show the order flow VSA claims beyond what the candle's shape, volume and colour imply."

label sigLbl = na
string sigTip = ""
if isSignal
    color base = sideNow > 0 ? cBull : cBear
    bool solid = classic or checkedSide
    string glyph = sideNow > 0 ? "▲" : "▼"
    string nm = labelName(code)
    sigTip := code == 6 ? FLOW_TIP_UP : code == 5 ? FLOW_TIP_SP : nm + ", " + UNCHECKED_TIP
    string ly = sideNow > 0 ? yloc.belowbar : yloc.abovebar
    if labelStyleSel == "Tag"
        sigLbl := label.new(bar_index, close, nm, yloc = ly, style = sideNow > 0 ? label.style_label_up : label.style_label_down,
             color = solid ? base : color.new(base, 82), textcolor = solid ? cPanel : base, size = lblSize, tooltip = sigTip)
    else if labelStyleSel == "Marker"
        sigLbl := label.new(bar_index, close, "", yloc = ly, style = sideNow > 0 ? label.style_triangleup : label.style_triangledown,
             color = solid ? base : color.new(base, 55), size = size.tiny, tooltip = sigTip)
    else
        string txt = sideNow > 0 ? glyph + "\n" + nm : nm + "\n" + glyph
        sigLbl := label.new(bar_index, close, txt, yloc = ly, style = label.style_none,
             textcolor = solid ? color.new(base, 0) : color.new(base, 55), size = lblSize, tooltip = sigTip)

// ---------------------------------------------------------------- signal zones (display only)
var array<box>   zBox  = array.new<box>()
var array<line>  zLine = array.new<line>()
var array<float> zLvl  = array.new<float>()
var array<int>   zSide = array.new<int>()
var array<int>   zBi   = array.new<int>()
if barstate.isconfirmed and zBox.size() > 0
    for i = zBox.size() - 1 to 0
        float lv = zLvl.get(i)
        int zs = zSide.get(i)
        bool broken = zs < 0 ? close > lv : close < lv
        if broken or bar_index - zBi.get(i) >= ZMAX
            color zc = zs > 0 ? cBull : cBear
            zBox.get(i).set_right(bar_index)
            line ln = zLine.get(i)
            ln.set_x2(bar_index)
            if broken
                ln.set_style(line.style_dotted)
                ln.set_color(color.new(zc, 70))
                zBox.get(i).set_bgcolor(color.new(zc, 95))
            zBox.remove(i)
            zLine.remove(i)
            zLvl.remove(i)
            zSide.remove(i)
            zBi.remove(i)
        else
            zBox.get(i).set_right(bar_index + 1)
            zLine.get(i).set_x2(bar_index + 1)

if isSignal and zonesOn
    float lv = sideNow < 0 ? high : low
    float bodyEdge = sideNow < 0 ? math.max(open, close) : math.min(open, close)
    float atrZ = aATR.size() > 0 and not na(aATR.last()) ? aATR.last() : high - low
    float bh = math.min(math.abs(lv - bodyEdge), 0.25 * atrZ)
    float edge = lv + sideNow * bh
    bool solidZ = classic or checkedSide
    color zc = sideNow > 0 ? cBull : cBear
    if true
        zBox.push(box.new(bar_index, math.max(lv, edge), bar_index + 1, math.min(lv, edge), border_color = color.new(zc, 100),
             border_width = 0, bgcolor = color.new(zc, solidZ ? 86 : 94)))
        zLine.push(line.new(bar_index, lv, bar_index + 1, lv, color = color.new(zc, solidZ ? 20 : 60), style = line.style_dashed, width = 1))
        zLvl.push(lv)
        zSide.push(sideNow)
        zBi.push(bar_index)
        while zBox.size() > 40
            zBox.shift()
            zLine.shift()
            zLvl.shift()
            zSide.shift()
            zBi.shift()

// ---------------------------------------------------------------- Outlook fan
var array<polyline> fanPolys = array.new<polyline>()
var array<label> fanLabels = array.new<label>()
var array<int> pendBi = array.new<int>()        // honesty mode: fans waiting for their actual path
var array<int> pendTarget = array.new<int>()
var int accCount = 0
var label lastInfo = na
float outCases = na
float outHit = na
float outMove = na
float outChance = na
float outBase = na

if inSess
    accCount += 1

if isSignal and outlookOn and bar_index >= last_bar_index - fanLookback and aC.size() > 0
    int t = aC.size() - 1
    [n, hitRate, baseRate, gap, moveR, share, q10, q25, q50, q75, q90, g25, g75] = outlookAt(t, grpNow, sideNow, time)
    outCases := n
    outHit := hitRate
    outMove := moveR
    outChance := share
    outBase := baseRate
    if fanMode == "Latest signal" and not honesty
        for p in fanPolys
            p.delete()
        fanPolys.clear()
        for lb in fanLabels
            lb.delete()
        fanLabels.clear()
    string head = groupName(grpNow) + (sideNow > 0 ? " ▲" : " ▼")
    if n < minCasesOf(grpNow)
        string few = head + "\nNot enough separate cases yet (n = " + str.tostring(n) + ")"
        if fanText
            fanLabels.push(label.new(bar_index, close, few, style = label.style_label_left, color = color.new(cPanel, 25),
                 textcolor = color.new(cInk, 25), size = size.small, tooltip = DISCLAIMER))
        else
            sigLbl.set_tooltip(sigTip + "\n\n" + few)
    else
        float c0 = close
        float a0 = aATR.get(t)
        if showGrey and g25.size() == H and not na(g25.get(0))
            fanPolys.push(polyline.new(bandPoints(bar_index, c0, a0, sideNow, g75, g25), curved = true, closed = true,
                 line_color = color.new(cGrey, 55), line_style = line.style_dotted, fill_color = color.new(cGrey, 94)))
        if showOuter
            fanPolys.push(polyline.new(bandPoints(bar_index, c0, a0, sideNow, q90, q10), curved = true, closed = true,
                 line_color = color.new(cFan, 100), fill_color = color.new(cFan, 90)))
        if showInner
            fanPolys.push(polyline.new(bandPoints(bar_index, c0, a0, sideNow, q75, q25), curved = true, closed = true,
                 line_color = color.new(cFan, 100), fill_color = color.new(cFan, 78)))
        fanPolys.push(polyline.new(linePoints(bar_index, c0, a0, sideNow, q50), curved = true, line_color = color.new(cFan, 82), line_width = 6))
        fanPolys.push(polyline.new(linePoints(bar_index, c0, a0, sideNow, q50), curved = true, line_color = cFan, line_width = 2))
        string info = head + " · " + str.tostring(n) + " separate cases"
        if chanceOn and not na(share)
            info += "\nwent the claimed way after " + str.tostring(H) + " bars: " + str.tostring(hitRate * 100, "0") + "% (same-colour bars " + str.tostring(baseRate * 100, "0") + "%)"
        info += "\nmoves " + (na(moveR) ? "n/a" : str.tostring(moveR, "0.0") + "×") + " similar-volume bars"
        if chanceOn and not na(share)
            info += share < 0.05 ? "\nRare by chance (under 5% of random tries)" : "\nRandom bars show a gap this size in " + str.tostring(share * 100, "0") + "% of tries"
        if fanText
            label infoLbl = label.new(bar_index + H, c0 + sideNow * q50.get(H - 1) * a0, info, style = label.style_label_left,
                 color = color.new(cPanel, 25), textcolor = cInk, size = size.small,
                 tooltip = DISCLAIMER + "\nOn many labels and charts some 'rare' readings are expected by chance: about 5% for random bars.")
            fanLabels.push(infoLbl)
            lastInfo := infoLbl
        else
            // default: no text on the chart; the numbers are in the signal label's tooltip
            sigLbl.set_tooltip(sigTip + "\n\nWhat followed on this chart's history:\n" + info + "\n\n" + DISCLAIMER)
        if honesty
            pendBi.push(bar_index)
            pendTarget.push(accCount + H)
    // keep inside the drawing budget, oldest first
    while fanPolys.size() > 90
        fanPolys.shift().delete()
    while fanLabels.size() > 60
        fanLabels.shift().delete()

// latest-signal mode: once newer bars have run past the fan, park its text right of the last bar so it stays
// readable and does not sit on the candles that formed after the signal
if barstate.islast and fanMode == "Latest signal" and not honesty and not na(lastInfo)
    if lastInfo.get_x() < bar_index + 3
        lastInfo.set_x(bar_index + 3)

// honesty mode: draw the path that actually followed once it is complete
if honesty and inSess and pendTarget.size() > 0 and pendTarget.get(0) <= accCount
    int bi0 = pendBi.shift()
    pendTarget.shift()
    array<chart.point> pts = array.new<chart.point>()
    for i = 0 to aBi.size() - 1
        int b = aBi.get(i)
        if b >= bi0
            pts.push(chart.point.from_index(b, aC.get(i)))
    if pts.size() > 1
        fanPolys.push(polyline.new(pts, line_color = color.new(cInk, 30), line_width = 1, line_style = line.style_dotted))

// ---------------------------------------------------------------- candle tint
color tint = na
if tintOn and not na(erEma) and inSess
    if erEma >= 20
        tint := color.from_gradient(erEma, 20, 70, color.from_gradient(40, 0, 100, cPanel, cWarm), cWarm)
    else if erEma <= -20
        tint := color.from_gradient(erEma, -70, -20, cCool, color.from_gradient(40, 0, 100, cPanel, cCool))
bool tinted = not na(tint)
color dirC = close >= open ? cBull : cBear
plotcandle(tinted ? open : na, tinted ? high : na, tinted ? low : na, tinted ? close : na, "Effort vs result",
     color = tint, wickcolor = dirC, bordercolor = dirC, display = display.pane)

// ---------------------------------------------------------------- status
var table status = na
if barstate.islast
    if useDiurnal and not diurnalActive
        if na(status)
            status := table.new(position.bottom_right, 1, 1, bgcolor = color.new(cPanel, 25), border_width = 0)
        table.cell(status, 0, 0, "MVSA: time-of-day volume not active yet (needs 5 sessions at this timeframe); using the 100-bar average",
             text_color = color.new(cInk, 25), text_size = size.tiny)
    else if not na(status)
        status.delete()
        status := na

// ---------------------------------------------------------------- alerts
bool alUp = isSignal and code == 6
bool alSp = isSignal and code == 5
alertcondition(alUp, "Upthrust", "MVSA {{ticker}} {{interval}}: Upthrust (flow-consistent)")
alertcondition(alSp, "Spring", "MVSA {{ticker}} {{interval}}: Spring (flow-consistent, owner override)")
alertcondition(isSignal and code == 1, "Climax bull", "MVSA {{ticker}} {{interval}}: Climax bull (unchecked)")
alertcondition(isSignal and code == 2, "Climax bear", "MVSA {{ticker}} {{interval}}: Climax bear (unchecked)")
alertcondition(isSignal and code == 3, "Absorption bull", "MVSA {{ticker}} {{interval}}: Absorption bull (unchecked)")
alertcondition(isSignal and code == 4, "Absorption bear", "MVSA {{ticker}} {{interval}}: Absorption bear (unchecked)")
alertcondition(isSignal and code == 7, "No Supply", "MVSA {{ticker}} {{interval}}: No Supply (unchecked)")
alertcondition(isSignal and code == 8, "No Demand", "MVSA {{ticker}} {{interval}}: No Demand (unchecked)")
alertcondition(alUp or alSp, "Any flow-consistent label", "MVSA {{ticker}} {{interval}}: Spring or Upthrust")
if isSignal
    string msg = "MVSA " + syminfo.ticker + " " + timeframe.period + ": " + labelName(code) + (sideNow > 0 ? " (bull)" : " (bear)")
    if not na(outCases)
        msg += ", " + str.tostring(outCases) + " separate cases" + (not na(outChance) ? ", claimed way " + str.tostring(outHit * 100, "0") + "%, chance " + str.tostring(outChance * 100, "0") + "%" : "")
    alert(msg, alert.freq_once_per_bar_close)

// ---------------------------------------------------------------- data window (parity gate; keep the titles)
plot(volume, "MVSA volume", display = display.data_window)
plot(code, "MVSA label", display = display.data_window)
plot(r2v, "MVSA r2_v", display = display.data_window)
plot(r2s, "MVSA r2_s", display = display.data_window)
plot(vqNow, "MVSA vq", display = display.data_window)
plot(outCases, "MVSA out_cases", display = display.data_window)
plot(outHit, "MVSA out_hit", display = display.data_window)
plot(outMove, "MVSA out_move", display = display.data_window)
plot(outChance, "MVSA out_chance", display = display.data_window)
````
