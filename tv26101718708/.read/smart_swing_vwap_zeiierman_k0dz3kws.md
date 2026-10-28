# Smart Swing VWAP (Zeiierman)

- url: https://www.tradingview.com/script/K0dz3kws-Smart-Swing-VWAP-Zeiierman/
- type: indicator
- pine_id: PUB;3623c710ede145df9b2e536a90f2674c
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Smart Swing VWAP (Zeiierman)[/b] is an adaptive price-volume tool that automatically selects meaningful swing highs and lows as VWAP anchors. Instead of relying on one fixed swing period, the indicator analyzes five configurable swing scales and ranks their current structure using price movement, volatility, volume participation, swing size, and agreement between scales.

Once the strongest qualifying swing is selected, the indicator builds a decayed, volume-weighted average from that anchor. Recent price and volume receive more influence, while older data gradually loses importance. This allows the VWAP to remain responsive during active markets without becoming excessively noisy during quieter conditions.
[image]https://www.tradingview.com/x/gyEklfYP/[/image]
Blending multi-scale swing structure with an adaptive VWAP engine creates a dynamic fair-value path that stays connected to current market behavior. This makes trend pullbacks, structural breaks, retests, continuation setups, and mean-reversion areas easier to identify.
[quote][b]Smart Swing VWAP[/b] builds upon the foundation of [b][url=https://www.tradingview.com/script/SxgyrEde-Dynamic-Swing-Anchored-VWAP-Zeiierman/]Dynamic Swing Anchored VWAP (Zeiierman)[/url][/b], which introduced swing-based re-anchoring combined with an adaptive, decayed volume-weighted average. This version expands that concept with five-scale swing analysis, matrix-based anchor ranking, anchor quality filters, structural break handling, selectable line behavior, and automated retest detection.[/quote]
█ [b]How It Works[/b]

⚪ [b]Smart Swing Selection[/b]
The indicator tracks five swing scales simultaneously. Each candidate is evaluated using cross-scale agreement, swing range, directional progress, volatility expansion, and volume participation.
[pine]float sc = 100.0 * (0.25 * cs + 0.20 * rg + 0.55 * en)[/pine]
Only swings that pass the Minimum Anchor Score, Minimum Move Strength, and Bars Between New Anchors requirements can become the active VWAP anchor. This helps prevent constant re-anchoring during noisy or overlapping market structure.

⚪ [b]Adaptive VWAP[/b]
Once an anchor is selected, the script calculates a decayed volume-weighted average. Recent price and volume matter more, while older observations gradually lose influence.
[pine]pv := (1.0 - alx) * pv + alx * hlc3[i] * vi
vv := (1.0 - alx) * vv + alx * vi
vw := vv > 0 ? pv / vv : na[/pine]
Price Tracking Speed controls the base responsiveness. The optional volatility adjustment compares current ATR with its average, allowing the VWAP to react faster during volatility expansion and move more smoothly during quieter conditions.

⚪ [b]Structure And Line Behavior[/b]
After an anchor is accepted, the indicator tracks the strongest opposite swing. A confirmed close through the active structural level changes the bullish or bearish state.

[b]Users can choose between two behaviors:[/b]
[list]
[*][b]Recolor Entire Active Line:[/b] Keeps one continuous VWAP and recolors the complete active path when structure changes.
[*][b]Preserve Old Color And Start New Segment:[/b] Keeps the previous color visible and begins a new segment from the confirmed structure-break bar.
[/list]
⚪ [b]Historical Anchor Reconstruction[/b]
When a swing wins the ranking process, the indicator rebuilds the active VWAP from the original swing bar. This displays the complete price-volume path that developed from the selected structure point.

The anchor is only accepted after the ranking conditions are confirmed. The reconstructed historical line does not mean the winning swing was known in real time at the original pivot bar.

█  [b]Why This Adaptive Approach Beats a Simple VWAP[/b]
[quote]Standard anchored VWAP uses one manually selected starting point. Its usefulness depends heavily on whether that anchor remains important as market structure changes.

A cumulative VWAP can also become increasingly resistant to new price information because every historical price-volume observation remains permanently included. During long trends or multi-session moves, this can cause the VWAP to drift far away from the current price.

[b]Smart Swing VWAP addresses these problems in three ways:[/b]

⚪ [b]Smart Multi-Scale Anchoring[/b]
Instead of using one fixed swing period, the indicator compares several structural horizons.

Shorter scales react to fast local movement, while longer scales identify broader market pivots. The ranking system selects the swing with the strongest combination of agreement, range, movement quality, volatility, and volume participation.

⚪ [b]Decayed Price-Volume Weighting[/b]
Older information gradually loses influence instead of remaining permanently dominant.

This allows the VWAP to stay closer to the market’s current perception of fair value and can create more relevant pullbacks and retests than a traditional cumulative VWAP.

⚪ [b]Volatility-Aware Responsiveness[/b]
Markets do not move at one constant speed.
[list]
[*][b]High Volatility → faster tracking:[/b] The VWAP responds more quickly and remains closer to active price movement.
[*][b]Low Volatility → smoother tracking:[/b] The VWAP filters smaller fluctuations and remains more stable.
[/list]
[b]Result:[/b] A structure-aware VWAP that can adapt its anchor, responsiveness, and directional presentation as market conditions evolve.[/quote]

█ [b]How to Use[/b]

⚪ [b]Trend Trading[/b]
During bullish structure, the green VWAP can act as a dynamic support reference. Look for price to remain above the line, pull back toward it, and then show renewed buying pressure.
[image]https://www.tradingview.com/x/dlTsbZfd/[/image]

During bearish structure, the red VWAP can act as a dynamic resistance reference. Look for price to remain below the line, retrace toward it, and then show renewed selling pressure.
[image]https://www.tradingview.com/x/DnLfSv2T/[/image]

█ [b]Settings[/b]
[list]
[*][b]Pivot Scales:[/b] Enables or disables each swing scale used by the ranking engine. More active scales provide broader structural comparison.
[*][b]Length:[/b] Number of bars used to detect swing highs and lows for each scale. Smaller = faster and noisier; larger = slower and cleaner.
[*][b]After Structure Break:[/b] Chooses whether the entire active VWAP changes color or the previous color is preserved and a new segment begins.
[*][b]Price Tracking Speed:[/b] Sets the base VWAP reaction speed. Lower = faster and tighter to price; higher = smoother and slower.
[*][b]Adjust Speed With Volatility:[/b] When ON, tracking speed automatically adjusts using current ATR relative to its average. High volatility = faster; low volatility = smoother.
[*][b]Volatility Adjustment Strength:[/b] Controls how strongly volatility changes the tracking speed. Higher values = stronger adjustment.
[*][b]Minimum Anchor Score:[/b] Minimum total ranking score required before a swing can become the active VWAP anchor. Higher = fewer, more selective anchors.
[*][b]Minimum Move Strength:[/b] Requires directional progress, volatility expansion, and volume participation before accepting a swing. Higher = stronger moves only.
[*][b]Bars Between New Anchors:[/b] Minimum number of confirmed bars before another swing can replace the active anchor. Higher = fewer anchor changes.
[*][b]Retest Touch Zone (ATR):[/b] Maximum distance from the VWAP that counts as a retest touch. Higher = wider touch zone.
[*][b]Retest Setup Distance (ATR):[/b] Minimum distance price must first move away from the VWAP before a later return can trigger a retest.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//@version=6
// © Zeiierman {
indicator("Smart Swing VWAP (Zeiierman)", overlay = true, max_bars_back = 5000, max_labels_count = 500, max_polylines_count = 100)
// }

// ~~ Tooltips {
var string tScaleOn = "Enables this pivot scale in the multi-scale anchor ranking. Disable it to remove this scale from swing detection, agreement scoring, and anchor selection."
var string tScaleLen = "Lookback used to detect rolling swing highs and lows for this scale. Smaller values react faster and find more local swings. Larger values identify broader market structure."
var string tMode = "Choose what happens after price closes through the active structural swing. Recolor Entire Active Line keeps one continuous AVWAP and recolors its full active history. Preserve Old Color And Start New Segment keeps the completed color history and begins the new color from the confirmed break bar."
var string tAPT = "Controls how quickly the adaptive AVWAP follows new price and volume. Lower values react faster. Higher values create a smoother, slower line."
var string tAdapt = "Automatically adjusts the AVWAP tracking speed using the current ATR relative to its average. This makes the line react differently as volatility changes."
var string tVolBias = "Controls how strongly volatility changes the adaptive tracking speed. Higher values create a larger difference between calm and volatile conditions."
var string tQuality = "Minimum total score required before a swing can become a new AVWAP anchor. The score combines multi-scale agreement, swing size, and move strength. Higher values produce fewer anchors."
var string tStrength = "Minimum combined confirmation required from directional movement, volatility expansion, and volume participation. Higher values accept only stronger and more decisive moves."
var string tHold = "Minimum number of confirmed bars that must pass before another ranked swing can replace the current anchor. Higher values reduce frequent anchor changes."
var string tRetestZone = "Maximum distance from the active AVWAP that counts as a retest touch, measured in ATR. Larger values create a wider touch zone."
var string tRetestArm = "Price must first move this far away from the active AVWAP, measured in ATR, before a later return can trigger a retest alert."
var string tBullLabel = "Color used for bullish swing labels such as higher lows and lower lows selected as active structural points."
var string tBearLabel = "Color used for bearish swing labels such as higher highs and lower highs selected as active structural points."
var string tBullLine = "Color used when the active AVWAP has bullish structural polarity."
var string tBearLine = "Color used when the active AVWAP has bearish structural polarity."
var string tWidth = "Width of the active and completed AVWAP lines."
var string tShowLen = "Shows the winning pivot length inside each swing label, such as L10, L35, or L80."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
u1 = input.bool(true, "Scale 1", inline = "1", group = "Pivot Scales", tooltip = tScaleOn)
l1 = input.int(10, "Length", minval = 2, maxval = 500, inline = "1", group = "Pivot Scales", tooltip = tScaleLen)
u2 = input.bool(true, "Scale 2", inline = "2", group = "Pivot Scales", tooltip = tScaleOn)
l2 = input.int(20, "Length", minval = 2, maxval = 500, inline = "2", group = "Pivot Scales", tooltip = tScaleLen)
u3 = input.bool(true, "Scale 3", inline = "3", group = "Pivot Scales", tooltip = tScaleOn)
l3 = input.int(35, "Length", minval = 2, maxval = 500, inline = "3", group = "Pivot Scales", tooltip = tScaleLen)
u4 = input.bool(true, "Scale 4", inline = "4", group = "Pivot Scales", tooltip = tScaleOn)
l4 = input.int(50, "Length", minval = 2, maxval = 500, inline = "4", group = "Pivot Scales", tooltip = tScaleLen)
u5 = input.bool(true, "Scale 5", inline = "5", group = "Pivot Scales", tooltip = tScaleOn)
l5 = input.int(80, "Length", minval = 2, maxval = 500, inline = "5", group = "Pivot Scales", tooltip = tScaleLen)

lineMode  = input.string("Recolor Entire Active Line", "After Structure Break", options = ["Recolor Entire Active Line", "Preserve Old Color And Start New Segment"], group = "Line Behavior", tooltip = tMode)
shiftMode = lineMode == "Preserve Old Color And Start New Segment"

apt = input.float(20, "Price Tracking Speed", minval = 1, step = 1, group = "Adaptive VWAP", tooltip = tAPT)
adp = input.bool(false, "Adjust Speed With Volatility", group = "Adaptive VWAP", tooltip = tAdapt)
vb  = input.float(10, "Volatility Adjustment Strength", minval = 0.1, step = 0.1, group = "Adaptive VWAP", tooltip = tVolBias)

minQ = input.float(58, "Minimum Anchor Score", minval = 0, maxval = 100, step = 1, group = "Anchor Selection", tooltip = tQuality)
minE = input.float(0.35, "Minimum Move Strength", minval = 0, maxval = 1, step = 0.05, group = "Anchor Selection", tooltip = tStrength)
hold = input.int(8, "Bars Between New Anchors", minval = 0, maxval = 100, group = "Anchor Selection", tooltip = tHold)

rtZ = input.float(0.15, "Retest Touch Zone (ATR)", minval = 0.01, maxval = 1, step = 0.01, group = "Alerts", tooltip = tRetestZone)
rtA = input.float(0.75, "Retest Setup Distance (ATR)", minval = 0.10, maxval = 5, step = 0.05, group = "Alerts", tooltip = tRetestArm)

upL = input.color(color.lime, "Bullish Label Color", group = "Style", tooltip = tBullLabel)
dnL = input.color(color.red, "Bearish Label Color", group = "Style", tooltip = tBearLabel)
upC = input.color(color.lime, "Bullish VWAP Color", group = "Style", tooltip = tBullLine)
dnC = input.color(color.red, "Bearish VWAP Color", group = "Style", tooltip = tBearLine)
wid = input.int(2, "VWAP Line Width", minval = 1, maxval = 6, group = "Style", tooltip = tWidth)
showLen = input.bool(true, "Show Winning Pivot Length", group = "Style", tooltip = tShowLen)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Constants {
const int N = 5
const int ID = 0
const int LN = 1
const int DR = 2
const int BX = 3
const int PY = 4
const int RG = 5
const int TD = 6
const int VX = 7
const int VP = 8
const int EN = 9
const int CS = 10
const int SC = 11
const int OK = 12
const int NC = 13

const float MAR = 4.0
const float PAD = 0.50
const int BAD   = 3
const float SAT = 0.20
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Market Data {
b    = bar_index
v    = na(volume) or volume <= 0 ? 1.0 : volume
br   = math.max(nz(ta.tr(true), high - low), syminfo.mintick)
tr   = math.max(nz(ta.atr(50), syminfo.mintick), syminfo.mintick)
avg  = math.max(nz(ta.rma(tr, 50), tr), syminfo.mintick)
va   = math.max(nz(ta.rma(v, 50), v), 1.0)
ba   = math.max(nz(ta.rma(br, 50), br), syminfo.mintick)
rat  = avg > 0 ? tr / avg : 1.0
raw  = adp ? apt / math.pow(rat, vb) : apt
aptS = float(math.round(math.max(5, math.min(300, raw))))
cv = ta.cum(v)
ce = ta.cum(va)
cr = ta.cum(br)
cx = ta.cum(ba)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helper Functions {
alpha(float n) => 1.0 - math.exp(-math.log(2.0) / math.max(1.0, n))
clip(float x)  => math.max(0.0, math.min(1.0, x))

volAt(int i) =>
    float q = volume[i]
    na(q) or q <= 0 ? 1.0 : q
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Swing System {
type Sw
    float hi
    float lo
    int hx
    int lx
    int d

turn(Sw s, int hb, int lb) =>
    if na(s.hi) or hb == 0
        s.hi := high
        s.hx := b

    if na(s.lo) or lb == 0
        s.lo := low
        s.lx := b

    int nd = s.hx > s.lx ? 1 : -1
    bool chg = s.d != 0 and nd != s.d
    s.d := nd
    chg
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Matrix Functions {
put(matrix<float> m, int r, bool on, int id, int n, Sw s) =>
    int x = s.d > 0 ? s.lx : s.hx
    float y = s.d > 0 ? s.lo : s.hi
    int bb  = b - x
    bool ok = on and s.d != 0 and not na(y) and bb >= 0 and bb < 4999

    m.set(r, ID, float(id))
    m.set(r, LN, float(n))
    m.set(r, DR, float(s.d))
    m.set(r, BX, float(x))
    m.set(r, PY, y)
    m.set(r, OK, ok ? 1.0 : 0.0)

    if ok
        float sv = cv - nz(cv[bb], cv) + v[bb]
        float ev = ce - nz(ce[bb], ce) + va[bb]
        float sr = cr - nz(cr[bb], cr) + br[bb]
        float er = cx - nz(cx[bb], cx) + ba[bb]
        float dm = math.max(s.d * (close - y), 0.0)
        float ef = dm / math.max(sr, syminfo.mintick)
        float ds = dm / math.max(tr[bb] * 3.0, syminfo.mintick)
        float td = math.sqrt(clip(ef / 0.35) * clip(ds))
        float vx = clip((sr / math.max(er, syminfo.mintick) - 0.70) / 0.90)
        float vp = clip((sv / math.max(ev, 1.0) - 0.75) / 0.75)
        float wk = math.min(td, math.min(vx, vp))
        float gm = math.pow(math.max(td * vx * vp, 0.0), 1.0 / 3.0)
        float en = gm * (0.50 + 0.50 * wk)
        float rg = clip(math.abs(s.hi - s.lo) / tr / 4.0)

        m.set(r, RG, rg)
        m.set(r, TD, td)
        m.set(r, VX, vx)
        m.set(r, VP, vp)
        m.set(r, EN, en)
        m.set(r, CS, 0.0)
        m.set(r, SC, 0.0)
    else
        for c = RG to SC
            m.set(r, c, c == SC ? -1.0 : 0.0)

link(matrix<float> m, matrix<float> g) =>
    for i = 0 to N - 1
        for j = 0 to N - 1
            bool vi  = m.get(i, OK) > 0.5
            bool vj  = m.get(j, OK) > 0.5
            float di = m.get(i, DR)
            float dj = m.get(j, DR)
            float yi = m.get(i, PY)
            float yj = m.get(j, PY)
            float xi = m.get(i, BX)
            float xj = m.get(j, BX)
            float ps = math.exp(-math.abs(yi - yj) / math.max(PAD * tr, syminfo.mintick))
            float bs = math.exp(-math.abs(xi - xj) / float(BAD))
            float z  = vi and vj and di == dj ? math.max(ps, bs) : 0.0
            g.set(i, j, z)

score(matrix<float> m, matrix<float> g) =>
    int cnt = 0

    for i = 0 to N - 1
        if m.get(i, OK) > 0.5
            cnt += 1

    for i = 0 to N - 1
        if m.get(i, OK) > 0.5
            float sm = 0.0

            for j = 0 to N - 1
                sm += g.get(i, j)

            float cs = cnt > 0 ? sm / float(cnt) : 0.0
            float rg = m.get(i, RG)
            float en = m.get(i, EN)
            float sc = 100.0 * (0.25 * cs + 0.20 * rg + 0.55 * en)

            m.set(i, CS, cs)
            m.set(i, SC, sc)
        else
            m.set(i, SC, -1.0)

findSc(matrix<float> m, int x, int d) =>
    float z = na

    for i = 0 to N - 1
        bool ok = m.get(i, OK) > 0.5
        int px  = int(m.get(i, BX))
        int pd  = int(m.get(i, DR))

        if ok and px == x and pd == d
            z := m.get(i, SC)
            break

    z
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Scale Arrays {
var array<Sw> sw = array.new<Sw>()

if barstate.isfirst
    for i = 0 to N - 1
        sw.push(Sw.new(na, na, 0, 0, 0))

int h1 = ta.highestbars(high, l1)
int q1 = ta.lowestbars(low, l1)
int h2 = ta.highestbars(high, l2)
int q2 = ta.lowestbars(low, l2)
int h3 = ta.highestbars(high, l3)
int q3 = ta.lowestbars(low, l3)
int h4 = ta.highestbars(high, l4)
int q4 = ta.lowestbars(low, l4)
int h5 = ta.highestbars(high, l5)
int q5 = ta.lowestbars(low, l5)

array<int> hs   = array.from(h1, h2, h3, h4, h5)
array<int> qs   = array.from(q1, q2, q3, q4, q5)
array<bool> ons = array.from(u1, u2, u3, u4, u5)
array<bool> ch  = array.new<bool>(N, false)

if barstate.isconfirmed
    for i = 0 to N - 1
        ch.set(i, turn(sw.get(i), hs.get(i), qs.get(i)))
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Matrix Build {
matrix<float> cf = matrix.new<float>(N, NC, na)

put(cf, 0, u1, 1, l1, sw.get(0))
put(cf, 1, u2, 2, l2, sw.get(1))
put(cf, 2, u3, 3, l3, sw.get(2))
put(cf, 3, u4, 4, l4, sw.get(3))
put(cf, 4, u5, 5, l5, sw.get(4))

matrix<float> ag = matrix.new<float>(N, N, 0.0)
link(cf, ag)
score(cf, ag)

matrix<float> rk = cf.copy()
rk.sort(SC, order.descending)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Anchor State {
var int ai = 0
var int al = na
var int ad = 0
var int ax = na
var int asince = na
var float ay   = na
var float asc  = na
var float oldH = na
var float oldL = na

var int sd = 0
var int sx = na
var int ox = na
var float sy = na
var float oy = na

var label liveLab = na

bool newA   = false
bool flipUp = false
bool flipDn = false
string tag  = ""
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Rank Selection {
if barstate.isconfirmed
    bool evt = false

    for i = 0 to N - 1
        evt := evt or (ons.get(i) and ch.get(i))

    int mn = math.min(math.min(l1, l2), math.min(l3, math.min(l4, l5)))

    if evt or (ai == 0 and b >= mn)
        int wi = -1

        for i = 0 to N - 1
            bool ok  = rk.get(i, OK) > 0.5
            float sc = rk.get(i, SC)
            float en = rk.get(i, EN)

            if ok and sc >= minQ and en >= minE
                wi := i
                break

        if wi >= 0
            array<float> w = rk.row(wi)

            int wId  = int(w.get(ID))
            int wLen = int(w.get(LN))
            int wDir = int(w.get(DR))
            int wBar = int(w.get(BX))
            float wPx  = w.get(PY)
            float wSc  = w.get(SC)
            float live = findSc(cf, ax, ad)

            if not na(live)
                asc := live

            bool same = ai != 0 and wDir == ad and math.abs(wPx - ay) <= SAT * tr and math.abs(wBar - ax) <= BAD
            int age   = ai == 0 ? 100000 : b - nz(asince, b)
            bool pass = ai == 0 or wDir != ad or na(asc) or wSc >= asc + MAR

            if not same and age >= hold and pass
                ai := wId
                al := wLen
                ad := wDir
                ax := wBar
                ay := wPx
                asc := wSc
                asince := b

                sd := ad
                sx := ax
                sy := ay

                newA := true

                if ad > 0
                    tag := na(oldL) ? "" : ay < oldL ? "LL" : "HL"
                    oldL := ay
                else
                    tag := na(oldH) ? "" : ay > oldH ? "HH" : "LH"
                    oldH := ay
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Polarity Flip {
if barstate.isconfirmed and ai != 0 and not newA
    if shiftMode and not na(ay)
        if ad < 0
            if na(oy) or low < oy
                oy := low
                ox := b

            if close >= ay and not na(oy) and not na(ox)
                ad := 1
                ax := ox
                ay := oy
                asc := minQ
                asince := b

                sd := ad
                sx := ax
                sy := ay

                flipUp := true
                tag  := na(oldL) ? "" : ay < oldL ? "LL" : "HL"
                oldL := ay

                int bb = b - ax
                ox := ax
                oy := high[bb]

                for i = bb to 0 by 1
                    if high[i] >= oy
                        oy := high[i]
                        ox := b - i

        else if ad > 0
            if na(oy) or high > oy
                oy := high
                ox := b

            if close <= ay and not na(oy) and not na(ox)
                ad := -1
                ax := ox
                ay := oy
                asc := minQ
                asince := b

                sd := ad
                sx := ax
                sy := ay

                flipDn := true
                tag  := na(oldH) ? "" : ay > oldH ? "HH" : "LH"
                oldH := ay

                int bb = b - ax
                ox := ax
                oy := low[bb]

                for i = bb to 0 by 1
                    if low[i] <= oy
                        oy := low[i]
                        ox := b - i

    else if not shiftMode and not na(sy)
        if sd < 0
            if na(oy) or low < oy
                oy := low
                ox := b

            if close >= sy and not na(oy) and not na(ox)
                sd := 1
                sx := ox
                sy := oy

                flipUp := true
                tag  := na(oldL) ? "" : sy < oldL ? "LL" : "HL"
                oldL := sy

                int bb = b - sx
                ox := sx
                oy := high[bb]

                for i = bb to 0 by 1
                    if high[i] >= oy
                        oy := high[i]
                        ox := b - i

        else if sd > 0
            if na(oy) or high > oy
                oy := high
                ox := b

            if close <= sy and not na(oy) and not na(ox)
                sd := -1
                sx := ox
                sy := oy

                flipDn := true
                tag  := na(oldH) ? "" : sy > oldH ? "HH" : "LH"
                oldH := sy

                int bb = b - sx
                ox := sx
                oy := low[bb]

                for i = bb to 0 by 1
                    if low[i] <= oy
                        oy := low[i]
                        ox := b - i
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ VWAP System {
type Path
    array<chart.point> pts
    polyline live = na
    int d = 0

var Path ln = Path.new(array.new<chart.point>(), na, 0)
var array<polyline> done = array.new<polyline>()

var float pv = hlc3 * v
var float vv = v
var float vw = na

if barstate.isconfirmed
    if newA and not na(ax) and not na(ay)
        int bb = b - ax

        if bb >= 0 and bb < 5000
            ln.live.delete()

            if ln.pts.size() > 1
                polyline seg = polyline.new(ln.pts, false, false, line_color = ln.d > 0 ? upC : dnC, line_width = wid)
                done.push(seg)

                if done.size() > 99
                    polyline old = done.shift()
                    old.delete()

            ln.pts.clear()

            float av = volAt(bb)
            pv := ay * av
            vv := av
            vw := na

            sd := ad
            sx := ax
            sy := ay
            ox := ax
            oy := sd > 0 ? high[bb] : low[bb]

            for i = bb to 0 by 1
                float alx = alpha(aptS[i])
                float vi = volAt(i)

                pv := (1.0 - alx) * pv + alx * hlc3[i] * vi
                vv := (1.0 - alx) * vv + alx * vi
                vw := vv > 0 ? pv / vv : na

                ln.pts.push(chart.point.from_index(b - i, vw))

                if sd > 0 and high[i] >= oy
                    oy := high[i]
                    ox := b - i
                else if sd < 0 and low[i] <= oy
                    oy := low[i]
                    ox := b - i

            ln.d := sd
            ln.live := polyline.new(ln.pts, false, false, line_color = ln.d > 0 ? upC : dnC, line_width = wid)

            string txt = tag + (showLen ? "\nL" + str.tostring(al) : "")

            liveLab := label.new(sx, sy, txt, style = sd > 0 ? label.style_label_up : label.style_label_down, color = color.new(sd > 0 ? upL : dnL, 20), textcolor = color.white)

    else if ai != 0
        float alx = alpha(aptS)

        pv := (1.0 - alx) * pv + alx * hlc3 * v
        vv := (1.0 - alx) * vv + alx * v
        vw := vv > 0 ? pv / vv : na

        ln.live.delete()
        ln.pts.push(chart.point.from_index(b, vw))

        bool flip = flipUp or flipDn

        if flip and shiftMode
            if ln.pts.size() > 1
                polyline seg = polyline.new(ln.pts, false, false, line_color = ln.d > 0 ? upC : dnC, line_width = wid)
                done.push(seg)

                if done.size() > 99
                    polyline old = done.shift()
                    old.delete()

            ln.pts.clear()
            ln.pts.push(chart.point.from_index(b, vw))

            ln.d := sd
            ln.live := polyline.new(ln.pts, false, false, line_color = ln.d > 0 ? upC : dnC, line_width = wid)
        else
            ln.d := sd
            ln.live := polyline.new(ln.pts, false, false, line_color = ln.d > 0 ? upC : dnC, line_width = wid)

        if flip
            if not na(liveLab)
                liveLab.delete()

            string txt = tag + (showLen ? "\nL" + str.tostring(al) : "")

            liveLab := label.new(sx, sy, txt, style = sd > 0 ? label.style_label_up : label.style_label_down, color = color.new(sd > 0 ? upL : dnL, 20), textcolor = color.white)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alert State {
bool xUpRaw = ta.crossover(close, vw)
bool xDnRaw = ta.crossunder(close, vw)

bool xUp = barstate.isconfirmed and ai != 0 and not newA and not flipUp and not flipDn and xUpRaw
bool xDn = barstate.isconfirmed and ai != 0 and not newA and not flipUp and not flipDn and xDnRaw

var int arm = 0

bool rtUp = false
bool rtDn = false

if barstate.isconfirmed
    if newA or flipUp or flipDn or ai == 0 or na(vw)
        arm := 0
    else
        float zone = rtZ * tr
        float away = rtA * tr
        bool touch = low <= vw + zone and high >= vw - zone
        int prevArm = arm

        if prevArm == 1 and sd > 0 and touch and close > vw and close >= open
            rtUp := true
            arm := 0
        else if prevArm == -1 and sd < 0 and touch and close < vw and close <= open
            rtDn := true
            arm  := 0
        else if close > vw + away
            arm := 1
        else if close < vw - away
            arm := -1
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alert Logic {
bool anyAlert = newA or flipUp or flipDn or xUp or xDn or rtUp or rtDn

alertcondition(newA, "New ranked anchor", "A new matrix-ranked AVWAP anchor was accepted on {{ticker}} at {{close}}.")
alertcondition(flipUp, "Bullish polarity flip", "Price closed above the active swing-high structure. The selected polarity mode applied its bullish flip behavior on {{ticker}} at {{close}}.")
alertcondition(flipDn, "Bearish polarity flip", "Price closed below the active swing-low structure. The selected polarity mode applied its bearish flip behavior on {{ticker}} at {{close}}.")
alertcondition(xUp, "Cross above AVWAP", "Price crossed above the active ranked AVWAP on {{ticker}} at {{close}}.")
alertcondition(xDn, "Cross below AVWAP", "Price crossed below the active ranked AVWAP on {{ticker}} at {{close}}.")
alertcondition(rtUp, "Bullish AVWAP retest", "Price retested the bullish ranked AVWAP as support on {{ticker}} at {{close}}.")
alertcondition(rtDn, "Bearish AVWAP retest", "Price retested the bearish ranked AVWAP as resistance on {{ticker}} at {{close}}.")
alertcondition(anyAlert, "Any ranked AVWAP event", "A ranked AVWAP anchor, polarity flip, cross, or retest event occurred on {{ticker}} at {{close}}.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
