<!-- tradingview-pine-id: PUB;342175b32a064bfb82bbc6731d3402aa -->
<!-- tradingviewscripts-format: 1 -->
# MTF Liquidity Density Ladder [PhenLabs]

Source: https://www.tradingview.com/script/cBBRVopo-MTF-Liquidity-Density-Ladder-PhenLabs/

## Description

📊 MTF Liquidity Density Ladder [PhenLabs]

Version: PineScript™ v6

📌 Description
The MTF Liquidity Density Ladder maps buy-side and sell-side liquidity as a clean, ranked ladder — not a wall of equal-level spam. Equal highs (BSL) and equal lows (SSL) earn a density score from repeat touches, relative volume, and higher-timeframe confluence, then move through a simple lifecycle: Fresh → Tapped → Raided → Restack.

By default the chart stays quiet: short soft rays for only the densest nearby pools, one label per side, raided levels hidden, and a compact five-row dashboard. When a dense pool is raided, a cascade magnet marks the next densest untapped pool on that side so you always know where liquidity is likely to pull price next.

Built for ICT/SMC traders who want multi-timeframe liquidity context without burying price action.

🚀 Points of Innovation

[*]Density-ranked BSL/SSL ladder instead of unweighted equal-level clutter
[*]Clean-by-default display: proximity filter, top-N visible pools, short rays, raided levels hidden
[*]Full pool lifecycle with restack detection after raids
[*]HTF pivot confluence boost so higher-timeframe equals dominate ranking
[*]Cascade magnet arms the next densest same-side pool after a raid
[*]Compact dashboard with adjustable Table Size (Tiny → Large)

🔧 Core Components

[*]Pool Seeder: swing pivots register BSL (equal highs) and SSL (equal lows)
[*]Merge Engine: nearby pivots collapse into one pool inside an ATR tolerance
[*]Density Scorer: touches × weight + volume score + optional HTF boost
[*]Raid Detector: wick-through with optional close-beyond confirmation
[*]Restack Tracker: new equals reforming after a recent raid
[*]Cascade Magnet: next densest same-side untapped pool after a raid
[*]Clean Display Layer: proximity, max visible, short rays, soft colors

🔥 Key Features

[*]Only the top densest nearby pools drawn per side (default 2)
[*]Short rays instead of chart-wide lines
[*]One compact label per side (▲ density / ▼ density)
[*]Raided pools hidden by default
[*]Quiet raid dots; cascade triangle markers optional
[*]Dashboard: Above · Below · Magnet · Event
[*]Table Size setting scales the whole dashboard for readability
[*]Alerts for raids, cascade magnets, and restacks

🎨 Visualization

[*]Soft red ray above price = best nearby buy-side liquidity (BSL)
[*]Soft teal ray below price = best nearby sell-side liquidity (SSL)
[*]Dashed blue ray = active cascade magnet
[*]Tiny raid dots on confirmed dense-pool raids
[*]Compact panel: LDL header, Above, Below, Magnet, Event
[*]Muted palette with adjustable line transparency

📖 Usage Guidelines

[*]Swing Pivot Length — Default: 5 — Raise on noisy lower timeframes
[*]Merge Tolerance (× ATR) — Default: 0.45 — Higher merges more equals into fewer cleaner pools
[*]Enable HTF Confluence — Default: true — Boosts density when LTF pools align with HTF pivots
[*]HTF Timeframe — Default: 60 — Match your execution ladder (e.g. 15m → 1H)
[*]Min Density (signals + draw) — Default: 2.0 — Filters weak pools from chart and alerts
[*]Max Visible Pools / Side — Default: 2 — Hard cap on drawn levels for clarity
[*]Proximity Filter (× ATR) — Default: 4.0 — Hides pools far from current price
[*]Ray Length / Extend — Defaults: 35 / 8 — Keeps levels local to recent price action
[*]Hide Raided Pools — Default: true — Shows resting liquidity only
[*]Table Size — Default: Small — Tiny / Small / Normal / Large dashboard text scale
[*]Dashboard Position — Default: Top Right — Move the panel anywhere on chart

✅ Best Use Cases

[*]ICT/SMC traders mapping BSL/SSL without hand-drawing every equal
[*]Continuation after a dense pool raid toward the cascade magnet
[*]Fade context when price approaches a high-density untapped pool
[*]FX, indices, and liquid crypto on intraday or swing timeframes
[*]Alert-driven raid → magnet → restack workflows

⚠️ Limitations

[*]Density is a relative score, not a guaranteed fill
[*]Pivot-based equals lag by design (no lookahead)
[*]Very choppy markets may need higher merge tolerance or min density
[*]Cascade magnets assume same-side liquidity runs; opposing narrative can invalidate
[*]Analytical aid only — pair with bias, structure, and risk rules

💡 What Makes This Unique

[*]Ranks liquidity by density so weak equals stay off the chart
[*]Clean display defaults designed for publish-ready screenshots
[*]Restack + cascade magnet answer both “what was taken?” and “where next?”
[*]Table Size control makes the dashboard readable on any screen without code edits

🔬 How It Works

[*]Confirmed swing highs seed or merge into BSL pools; swing lows into SSL pools
[*]Density = touches×weight + average volume score×weight + HTF boost
[*]A raid needs a wick through the pool (and optional close beyond)
[*]On raid, the densest remaining same-side untapped pool beyond that price becomes the magnet
[*]Only nearby, high-density, non-raided (by default) pools are drawn as short rays
[*]Dashboard summarizes the best level above, best below, magnet, and last event

💡 Note:
Use the MTF Liquidity Density Ladder as a liquidity map and confluence layer. Prefer higher-density untapped pools and wait for bar close on raid events. This is an analytical aid, not financial advice.

---

## Source Code

````pine
//@version=6
indicator("MTF Liquidity Density Ladder [PhenLabs]", shorttitle="MTF-LDL", overlay=true, max_lines_count=60, max_labels_count=20, max_boxes_count=20, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
string G_CORE = "Pool Detection"
int    swingLen   = input.int(5, "Swing Pivot Length", minval=2, maxval=30, group=G_CORE)
float  mergeAtr   = input.float(0.45, "Merge Tolerance (× ATR)", minval=0.05, maxval=2.0, step=0.05, group=G_CORE, tooltip="Higher = fewer, cleaner pools.")
int    maxPools   = input.int(6, "Max Pools Tracked / Side", minval=2, maxval=12, group=G_CORE)
int    atrLen     = input.int(14, "ATR Length", minval=5, maxval=50, group=G_CORE)
int    volLen     = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=G_CORE)
int    poolAge    = input.int(200, "Max Pool Age (bars)", minval=50, maxval=2000, group=G_CORE)

string G_MTF = "Multi-Timeframe"
bool   useHtf     = input.bool(true, "Enable HTF Confluence", group=G_MTF)
string htfTf      = input.timeframe("60", "HTF Timeframe", group=G_MTF)
int    htfSwing   = input.int(3, "HTF Swing Length", minval=2, maxval=20, group=G_MTF)
float  htfBoost   = input.float(2.0, "HTF Density Boost", minval=0.5, maxval=5.0, step=0.1, group=G_MTF)

string G_SCORE = "Density / Raid Logic"
float  touchW     = input.float(1.0, "Touch Weight", minval=0.1, maxval=5.0, step=0.1, group=G_SCORE)
float  volW       = input.float(0.75, "Volume Weight", minval=0.0, maxval=5.0, step=0.05, group=G_SCORE)
float  raidWick   = input.float(0.05, "Raid Wick Buffer (× ATR)", minval=0.0, maxval=1.0, step=0.05, group=G_SCORE)
bool   raidClose  = input.bool(true, "Require Close Beyond Pool", group=G_SCORE)
bool   showRestack = input.bool(true, "Track Restacks", group=G_SCORE)
int    restackBars = input.int(40, "Restack Window (bars)", minval=5, maxval=200, group=G_SCORE)
float  minDensSig = input.float(2.0, "Min Density (signals + draw)", minval=0.5, maxval=20.0, step=0.5, group=G_SCORE)

string G_CLEAN = "Clean Display"
int    maxVisible = input.int(2, "Max Visible Pools / Side", minval=1, maxval=6, group=G_CLEAN, tooltip="Only the densest nearby pools are drawn.")
float  nearAtr    = input.float(4.0, "Proximity Filter (× ATR)", minval=1.0, maxval=20.0, step=0.5, group=G_CLEAN, tooltip="Hide pools farther than this from price.")
int    rayBars    = input.int(35, "Ray Length (bars)", minval=10, maxval=150, group=G_CLEAN, tooltip="Short rays instead of chart-wide lines.")
int    rayRight   = input.int(8, "Ray Extend Right", minval=0, maxval=40, group=G_CLEAN)
bool   hideRaided = input.bool(true, "Hide Raided Pools", group=G_CLEAN)
bool   showLabs   = input.bool(true, "Label Top Pool Only", group=G_CLEAN, tooltip="One label per side on the #1 visible pool.")
bool   showMagnetLn = input.bool(true, "Show Magnet Ray", group=G_CLEAN)
bool   showRaidSig  = input.bool(true, "Raid Dots", group=G_CLEAN)
bool   showCascSig  = input.bool(false, "Cascade Markers", group=G_CLEAN)
bool   showDash     = input.bool(true, "Compact Dashboard", group=G_CLEAN)
string dashPos      = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=G_CLEAN)
string tableSizeIn  = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=G_CLEAN, tooltip="Scales dashboard text size. Tiny = densest panel, Large = easiest to read.")

string G_VIS = "Colors"
color  colBsl   = input.color(color.new(#EF5350, 0), "BSL", group=G_VIS)
color  colSsl   = input.color(color.new(#26A69A, 0), "SSL", group=G_VIS)
color  colRest  = input.color(color.new(#AB47BC, 0), "Restack", group=G_VIS)
color  colMag   = input.color(color.new(#42A5F5, 0), "Magnet", group=G_VIS)
color  colDash  = input.color(color.new(#B0BEC5, 0), "Dashboard", group=G_VIS)
int    lineFade = input.int(55, "Line Transparency", minval=0, maxval=90, group=G_VIS)

// ═══════════════════════════════════════════════════════════════
// PURE HELPERS
// ═══════════════════════════════════════════════════════════════
f_pos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

f_tableSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

f_dens(float touches, float volScore, float htfExtra) =>
    touches * touchW + volScore * volW + htfExtra

f_stateShort(int st) =>
    st == 0 ? "F" : st == 1 ? "T" : st == 2 ? "R" : st == 3 ? "RS" : "?"

f_stateName(int st) =>
    st == 0 ? "Fresh" : st == 1 ? "Tapped" : st == 2 ? "Raided" : st == 3 ? "Restack" : "—"

// nth densest among indices that pass a visibility mask array (1=visible)
f_topVis(array<float> densArr, array<int> visArr, int rank) =>
    int n = array.size(densArr)
    int out = -1
    if n > 0 and array.size(visArr) == n
        float thr = 1e20
        for r = 0 to rank
            float best = -1.0
            int bi = -1
            for i = 0 to n - 1
                if array.get(visArr, i) == 1
                    float d = array.get(densArr, i)
                    if d > best and d < thr
                        best := d
                        bi := i
            thr := best
            if r == rank
                out := bi
    out

// ═══════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════
var array<float> bslPx    = array.new_float()
var array<float> bslDens  = array.new_float()
var array<float> bslVol   = array.new_float()
var array<int>   bslTouch = array.new_int()
var array<int>   bslState = array.new_int()
var array<int>   bslBorn  = array.new_int()
var array<int>   bslLast  = array.new_int()
var array<int>   bslRaidB = array.new_int()
var array<float> bslHtf   = array.new_float()
var array<line>  bslLn    = array.new_line()
var array<label> bslLb    = array.new_label()

var array<float> sslPx    = array.new_float()
var array<float> sslDens  = array.new_float()
var array<float> sslVol   = array.new_float()
var array<int>   sslTouch = array.new_int()
var array<int>   sslState = array.new_int()
var array<int>   sslBorn  = array.new_int()
var array<int>   sslLast  = array.new_int()
var array<int>   sslRaidB = array.new_int()
var array<float> sslHtf   = array.new_float()
var array<line>  sslLn    = array.new_line()
var array<label> sslLb    = array.new_label()

var float magPx   = na
var int   magSide = 0
var line  magLn   = na
var label magLb   = na

var int    lastEventSide = 0
var float  lastEventPx   = na
var string lastEventTxt  = "—"
var float  lastEventDens = na
var int    lastEventCode = 0
var int    prevEventCode = 0

float atr = ta.atr(atrLen)
float volSma = ta.sma(volume, volLen)
float volScoreBar = not na(volSma) and volSma > 0 ? math.min(volume / volSma, 4.0) : 1.0
float mergeDist = not na(atr) ? atr * mergeAtr : syminfo.mintick * 10.0
float raidBuf = not na(atr) ? atr * raidWick : syminfo.mintick * 2.0
float nearDist = not na(atr) ? atr * nearAtr : syminfo.mintick * 50.0

float htfPh = useHtf ? request.security(syminfo.tickerid, htfTf, ta.pivothigh(high, htfSwing, htfSwing), barmerge.gaps_off, barmerge.lookahead_off) : na
float htfPl = useHtf ? request.security(syminfo.tickerid, htfTf, ta.pivotlow(low, htfSwing, htfSwing), barmerge.gaps_off, barmerge.lookahead_off) : na
float ltfPh = ta.pivothigh(high, swingLen, swingLen)
float ltfPl = ta.pivotlow(low, swingLen, swingLen)

// ═══════════════════════════════════════════════════════════════
// REGISTER BSL
// ═══════════════════════════════════════════════════════════════
if not na(ltfPh) and not na(atr)
    int found = -1
    if array.size(bslPx) > 0
        for i = 0 to array.size(bslPx) - 1
            if math.abs(array.get(bslPx, i) - ltfPh) <= mergeDist
                found := i
                break
    float htfExtra = 0.0
    if useHtf and not na(htfPh) and math.abs(htfPh - ltfPh) <= mergeDist * 1.5
        htfExtra := htfBoost
    if found >= 0
        int t = array.get(bslTouch, found) + 1
        float v = array.get(bslVol, found) + volScoreBar
        float px = (array.get(bslPx, found) * (t - 1) + ltfPh) / t
        float he = math.max(array.get(bslHtf, found), htfExtra)
        array.set(bslTouch, found, t)
        array.set(bslVol, found, v)
        array.set(bslPx, found, px)
        array.set(bslLast, found, bar_index)
        array.set(bslHtf, found, he)
        array.set(bslDens, found, f_dens(t, v / t, he))
        int st = array.get(bslState, found)
        if showRestack and st == 2 and array.get(bslRaidB, found) >= 0 and (bar_index - array.get(bslRaidB, found)) <= restackBars
            array.set(bslState, found, 3)
            lastEventSide := 1
            lastEventPx := px
            lastEventDens := array.get(bslDens, found)
            lastEventTxt := "Restack ↑"
            lastEventCode := 3
        else if st == 0
            array.set(bslState, found, 1)
    else
        array.push(bslPx, ltfPh)
        array.push(bslTouch, 1)
        array.push(bslVol, volScoreBar)
        array.push(bslHtf, htfExtra)
        array.push(bslDens, f_dens(1, volScoreBar, htfExtra))
        array.push(bslState, 0)
        array.push(bslBorn, bar_index - swingLen)
        array.push(bslLast, bar_index)
        array.push(bslRaidB, -1)
        array.push(bslLn, na)
        array.push(bslLb, na)

if useHtf and not na(htfPh) and not na(atr)
    int foundH = -1
    if array.size(bslPx) > 0
        for i = 0 to array.size(bslPx) - 1
            if math.abs(array.get(bslPx, i) - htfPh) <= mergeDist * 1.5
                foundH := i
                break
    if foundH >= 0
        float he = math.max(array.get(bslHtf, foundH), htfBoost)
        array.set(bslHtf, foundH, he)
        float t = array.get(bslTouch, foundH)
        float vAvg = t > 0 ? array.get(bslVol, foundH) / t : 0.0
        array.set(bslDens, foundH, f_dens(t, vAvg, he))
    else
        array.push(bslPx, htfPh)
        array.push(bslTouch, 1)
        array.push(bslVol, volScoreBar)
        array.push(bslHtf, htfBoost)
        array.push(bslDens, f_dens(1, volScoreBar, htfBoost))
        array.push(bslState, 0)
        array.push(bslBorn, bar_index)
        array.push(bslLast, bar_index)
        array.push(bslRaidB, -1)
        array.push(bslLn, na)
        array.push(bslLb, na)

// ═══════════════════════════════════════════════════════════════
// REGISTER SSL
// ═══════════════════════════════════════════════════════════════
if not na(ltfPl) and not na(atr)
    int found = -1
    if array.size(sslPx) > 0
        for i = 0 to array.size(sslPx) - 1
            if math.abs(array.get(sslPx, i) - ltfPl) <= mergeDist
                found := i
                break
    float htfExtra = 0.0
    if useHtf and not na(htfPl) and math.abs(htfPl - ltfPl) <= mergeDist * 1.5
        htfExtra := htfBoost
    if found >= 0
        int t = array.get(sslTouch, found) + 1
        float v = array.get(sslVol, found) + volScoreBar
        float px = (array.get(sslPx, found) * (t - 1) + ltfPl) / t
        float he = math.max(array.get(sslHtf, found), htfExtra)
        array.set(sslTouch, found, t)
        array.set(sslVol, found, v)
        array.set(sslPx, found, px)
        array.set(sslLast, found, bar_index)
        array.set(sslHtf, found, he)
        array.set(sslDens, found, f_dens(t, v / t, he))
        int st = array.get(sslState, found)
        if showRestack and st == 2 and array.get(sslRaidB, found) >= 0 and (bar_index - array.get(sslRaidB, found)) <= restackBars
            array.set(sslState, found, 3)
            lastEventSide := -1
            lastEventPx := px
            lastEventDens := array.get(sslDens, found)
            lastEventTxt := "Restack ↓"
            lastEventCode := 4
        else if st == 0
            array.set(sslState, found, 1)
    else
        array.push(sslPx, ltfPl)
        array.push(sslTouch, 1)
        array.push(sslVol, volScoreBar)
        array.push(sslHtf, htfExtra)
        array.push(sslDens, f_dens(1, volScoreBar, htfExtra))
        array.push(sslState, 0)
        array.push(sslBorn, bar_index - swingLen)
        array.push(sslLast, bar_index)
        array.push(sslRaidB, -1)
        array.push(sslLn, na)
        array.push(sslLb, na)

if useHtf and not na(htfPl) and not na(atr)
    int foundH = -1
    if array.size(sslPx) > 0
        for i = 0 to array.size(sslPx) - 1
            if math.abs(array.get(sslPx, i) - htfPl) <= mergeDist * 1.5
                foundH := i
                break
    if foundH >= 0
        float he = math.max(array.get(sslHtf, foundH), htfBoost)
        array.set(sslHtf, foundH, he)
        float t = array.get(sslTouch, foundH)
        float vAvg = t > 0 ? array.get(sslVol, foundH) / t : 0.0
        array.set(sslDens, foundH, f_dens(t, vAvg, he))
    else
        array.push(sslPx, htfPl)
        array.push(sslTouch, 1)
        array.push(sslVol, volScoreBar)
        array.push(sslHtf, htfBoost)
        array.push(sslDens, f_dens(1, volScoreBar, htfBoost))
        array.push(sslState, 0)
        array.push(sslBorn, bar_index)
        array.push(sslLast, bar_index)
        array.push(sslRaidB, -1)
        array.push(sslLn, na)
        array.push(sslLb, na)

// ═══════════════════════════════════════════════════════════════
// TOUCH + RAID
// ═══════════════════════════════════════════════════════════════
bool bslRaidNow = false
bool sslRaidNow = false
float bslRaidPx = na
float sslRaidPx = na
float bslRaidDens = na
float sslRaidDens = na

if array.size(bslPx) > 0
    for i = 0 to array.size(bslPx) - 1
        float px = array.get(bslPx, i)
        int st = array.get(bslState, i)
        if high >= px and low <= px and st < 2
            if st == 0
                array.set(bslState, i, 1)
            array.set(bslLast, i, bar_index)
        bool wickRaid = high >= px + raidBuf
        bool closeRaid = not raidClose or close > px
        if st < 2 and wickRaid and closeRaid
            array.set(bslState, i, 2)
            array.set(bslRaidB, i, bar_index)
            array.set(bslLast, i, bar_index)
            bslRaidNow := true
            bslRaidPx := px
            bslRaidDens := array.get(bslDens, i)
            lastEventSide := 1
            lastEventPx := px
            lastEventDens := array.get(bslDens, i)
            lastEventTxt := "Raid ↑"
            lastEventCode := 1

if array.size(sslPx) > 0
    for i = 0 to array.size(sslPx) - 1
        float px = array.get(sslPx, i)
        int st = array.get(sslState, i)
        if low <= px and high >= px and st < 2
            if st == 0
                array.set(sslState, i, 1)
            array.set(sslLast, i, bar_index)
        bool wickRaid = low <= px - raidBuf
        bool closeRaid = not raidClose or close < px
        if st < 2 and wickRaid and closeRaid
            array.set(sslState, i, 2)
            array.set(sslRaidB, i, bar_index)
            array.set(sslLast, i, bar_index)
            sslRaidNow := true
            sslRaidPx := px
            sslRaidDens := array.get(sslDens, i)
            lastEventSide := -1
            lastEventPx := px
            lastEventDens := array.get(sslDens, i)
            lastEventTxt := "Raid ↓"
            lastEventCode := 2

// ═══════════════════════════════════════════════════════════════
// CASCADE MAGNET
// ═══════════════════════════════════════════════════════════════
bool cascBsl = false
bool cascSsl = false

if bslRaidNow and array.size(bslPx) > 0 and not na(bslRaidPx)
    float bestD = -1.0
    float bestP = na
    for i = 0 to array.size(bslPx) - 1
        int st = array.get(bslState, i)
        float px = array.get(bslPx, i)
        float d = array.get(bslDens, i)
        if st < 2 and px > bslRaidPx and d >= minDensSig and d > bestD
            bestD := d
            bestP := px
    if not na(bestP)
        magPx := bestP
        magSide := 1
        cascBsl := true

if sslRaidNow and array.size(sslPx) > 0 and not na(sslRaidPx)
    float bestD = -1.0
    float bestP = na
    for i = 0 to array.size(sslPx) - 1
        int st = array.get(sslState, i)
        float px = array.get(sslPx, i)
        float d = array.get(sslDens, i)
        if st < 2 and px < sslRaidPx and d >= minDensSig and d > bestD
            bestD := d
            bestP := px
    if not na(bestP)
        magPx := bestP
        magSide := -1
        cascSsl := true

if not na(magPx) and magSide == 1 and array.size(bslPx) > 0
    for i = 0 to array.size(bslPx) - 1
        if math.abs(array.get(bslPx, i) - magPx) <= mergeDist and array.get(bslState, i) >= 2
            magPx := na
            magSide := 0
if not na(magPx) and magSide == -1 and array.size(sslPx) > 0
    for i = 0 to array.size(sslPx) - 1
        if math.abs(array.get(sslPx, i) - magPx) <= mergeDist and array.get(sslState, i) >= 2
            magPx := na
            magSide := 0

// ═══════════════════════════════════════════════════════════════
// PRUNE
// ═══════════════════════════════════════════════════════════════
if array.size(bslPx) > 0
    for i = array.size(bslPx) - 1 to 0
        if bar_index - array.get(bslLast, i) > poolAge
            line oldL = array.get(bslLn, i)
            label oldLb = array.get(bslLb, i)
            if not na(oldL)
                line.delete(oldL)
            if not na(oldLb)
                label.delete(oldLb)
            array.remove(bslPx, i)
            array.remove(bslDens, i)
            array.remove(bslVol, i)
            array.remove(bslTouch, i)
            array.remove(bslState, i)
            array.remove(bslBorn, i)
            array.remove(bslLast, i)
            array.remove(bslRaidB, i)
            array.remove(bslHtf, i)
            array.remove(bslLn, i)
            array.remove(bslLb, i)

if array.size(sslPx) > 0
    for i = array.size(sslPx) - 1 to 0
        if bar_index - array.get(sslLast, i) > poolAge
            line oldL = array.get(sslLn, i)
            label oldLb = array.get(sslLb, i)
            if not na(oldL)
                line.delete(oldL)
            if not na(oldLb)
                label.delete(oldLb)
            array.remove(sslPx, i)
            array.remove(sslDens, i)
            array.remove(sslVol, i)
            array.remove(sslTouch, i)
            array.remove(sslState, i)
            array.remove(sslBorn, i)
            array.remove(sslLast, i)
            array.remove(sslRaidB, i)
            array.remove(sslHtf, i)
            array.remove(sslLn, i)
            array.remove(sslLb, i)

while array.size(bslPx) > maxPools
    float worstD = 1e20
    int worstI = 0
    for i = 0 to array.size(bslPx) - 1
        float score = array.get(bslDens, i) - (array.get(bslState, i) >= 2 ? 100.0 : 0.0)
        if score < worstD
            worstD := score
            worstI := i
    line oldL = array.get(bslLn, worstI)
    label oldLb = array.get(bslLb, worstI)
    if not na(oldL)
        line.delete(oldL)
    if not na(oldLb)
        label.delete(oldLb)
    array.remove(bslPx, worstI)
    array.remove(bslDens, worstI)
    array.remove(bslVol, worstI)
    array.remove(bslTouch, worstI)
    array.remove(bslState, worstI)
    array.remove(bslBorn, worstI)
    array.remove(bslLast, worstI)
    array.remove(bslRaidB, worstI)
    array.remove(bslHtf, worstI)
    array.remove(bslLn, worstI)
    array.remove(bslLb, worstI)

while array.size(sslPx) > maxPools
    float worstD = 1e20
    int worstI = 0
    for i = 0 to array.size(sslPx) - 1
        float score = array.get(sslDens, i) - (array.get(sslState, i) >= 2 ? 100.0 : 0.0)
        if score < worstD
            worstD := score
            worstI := i
    line oldL = array.get(sslLn, worstI)
    label oldLb = array.get(sslLb, worstI)
    if not na(oldL)
        line.delete(oldL)
    if not na(oldLb)
        label.delete(oldLb)
    array.remove(sslPx, worstI)
    array.remove(sslDens, worstI)
    array.remove(sslVol, worstI)
    array.remove(sslTouch, worstI)
    array.remove(sslState, worstI)
    array.remove(sslBorn, worstI)
    array.remove(sslLast, worstI)
    array.remove(sslRaidB, worstI)
    array.remove(sslHtf, worstI)
    array.remove(sslLn, worstI)
    array.remove(sslLb, worstI)

// ═══════════════════════════════════════════════════════════════
// VISIBILITY MASK — proximity + density + state + top-N
// ═══════════════════════════════════════════════════════════════
array<int> bslVis = array.new_int()
array<int> sslVis = array.new_int()

if array.size(bslPx) > 0
    for i = 0 to array.size(bslPx) - 1
        float px = array.get(bslPx, i)
        int st = array.get(bslState, i)
        float d = array.get(bslDens, i)
        bool okState = st == 3 or not hideRaided or st < 2
        bool okDens = d >= minDensSig
        bool okNear = math.abs(px - close) <= nearDist
        // BSL should generally sit above or near price; still allow slightly below if just raided restack
        bool okSide = px >= close - nearDist * 0.25
        array.push(bslVis, okState and okDens and okNear and okSide ? 1 : 0)

if array.size(sslPx) > 0
    for i = 0 to array.size(sslPx) - 1
        float px = array.get(sslPx, i)
        int st = array.get(sslState, i)
        float d = array.get(sslDens, i)
        bool okState = st == 3 or not hideRaided or st < 2
        bool okDens = d >= minDensSig
        bool okNear = math.abs(px - close) <= nearDist
        bool okSide = px <= close + nearDist * 0.25
        array.push(sslVis, okState and okDens and okNear and okSide ? 1 : 0)

// Zero out non top-N so only densest nearby pools draw
if array.size(bslVis) > 0
    array<int> keepB = array.new_int(array.size(bslVis), 0)
    for r = 0 to maxVisible - 1
        int idx = f_topVis(bslDens, bslVis, r)
        if idx >= 0
            array.set(keepB, idx, 1)
    bslVis := keepB

if array.size(sslVis) > 0
    array<int> keepS = array.new_int(array.size(sslVis), 0)
    for r = 0 to maxVisible - 1
        int idx = f_topVis(sslDens, sslVis, r)
        if idx >= 0
            array.set(keepS, idx, 1)
    sslVis := keepS

int topB = f_topVis(bslDens, bslVis, 0)
int topS = f_topVis(sslDens, sslVis, 0)

// ═══════════════════════════════════════════════════════════════
// DRAW — short soft rays, labels only on #1 each side
// ═══════════════════════════════════════════════════════════════
int x1 = math.max(0, bar_index - rayBars)
int x2 = bar_index + rayRight

if array.size(bslPx) > 0
    for i = 0 to array.size(bslPx) - 1
        bool vis = array.size(bslVis) > i and array.get(bslVis, i) == 1
        line ln = array.get(bslLn, i)
        label lb = array.get(bslLb, i)
        if not vis
            if not na(ln)
                line.delete(ln)
            if not na(lb)
                label.delete(lb)
            array.set(bslLn, i, na)
            array.set(bslLb, i, na)
        else
            float px = array.get(bslPx, i)
            int st = array.get(bslState, i)
            float d = array.get(bslDens, i)
            bool isTop = i == topB
            bool isMag = not na(magPx) and math.abs(px - magPx) <= mergeDist and magSide == 1
            color baseC = st == 3 ? colRest : colBsl
            int fade = isTop ? math.max(lineFade - 25, 10) : lineFade
            color c = color.new(baseC, fade)
            int w = isTop or isMag ? 2 : 1
            if na(ln)
                ln := line.new(x1, px, x2, px, color=c, style=isMag ? line.style_dashed : line.style_solid, width=w)
                array.set(bslLn, i, ln)
            else
                line.set_xy1(ln, x1, px)
                line.set_xy2(ln, x2, px)
                line.set_color(ln, c)
                line.set_style(ln, isMag ? line.style_dashed : line.style_solid)
                line.set_width(ln, w)
            // label only top pool
            if showLabs and isTop
                string txt = "▲ " + str.tostring(d, "#.0")
                if st == 3
                    txt := txt + " RS"
                if na(lb)
                    lb := label.new(x2, px, txt, style=label.style_label_left, color=color.new(baseC, 85), textcolor=color.new(baseC, 0), size=size.small)
                    array.set(bslLb, i, lb)
                else
                    label.set_xy(lb, x2, px)
                    label.set_text(lb, txt)
                    label.set_textcolor(lb, color.new(baseC, 0))
                    label.set_color(lb, color.new(baseC, 85))
            else
                if not na(lb)
                    label.delete(lb)
                    array.set(bslLb, i, na)

if array.size(sslPx) > 0
    for i = 0 to array.size(sslPx) - 1
        bool vis = array.size(sslVis) > i and array.get(sslVis, i) == 1
        line ln = array.get(sslLn, i)
        label lb = array.get(sslLb, i)
        if not vis
            if not na(ln)
                line.delete(ln)
            if not na(lb)
                label.delete(lb)
            array.set(sslLn, i, na)
            array.set(sslLb, i, na)
        else
            float px = array.get(sslPx, i)
            int st = array.get(sslState, i)
            float d = array.get(sslDens, i)
            bool isTop = i == topS
            bool isMag = not na(magPx) and math.abs(px - magPx) <= mergeDist and magSide == -1
            color baseC = st == 3 ? colRest : colSsl
            int fade = isTop ? math.max(lineFade - 25, 10) : lineFade
            color c = color.new(baseC, fade)
            int w = isTop or isMag ? 2 : 1
            if na(ln)
                ln := line.new(x1, px, x2, px, color=c, style=isMag ? line.style_dashed : line.style_solid, width=w)
                array.set(sslLn, i, ln)
            else
                line.set_xy1(ln, x1, px)
                line.set_xy2(ln, x2, px)
                line.set_color(ln, c)
                line.set_style(ln, isMag ? line.style_dashed : line.style_solid)
                line.set_width(ln, w)
            if showLabs and isTop
                string txt = "▼ " + str.tostring(d, "#.0")
                if st == 3
                    txt := txt + " RS"
                if na(lb)
                    lb := label.new(x2, px, txt, style=label.style_label_left, color=color.new(baseC, 85), textcolor=color.new(baseC, 0), size=size.small)
                    array.set(sslLb, i, lb)
                else
                    label.set_xy(lb, x2, px)
                    label.set_text(lb, txt)
                    label.set_textcolor(lb, color.new(baseC, 0))
                    label.set_color(lb, color.new(baseC, 85))
            else
                if not na(lb)
                    label.delete(lb)
                    array.set(sslLb, i, na)

// Magnet — single soft dashed ray + tiny tag (no triangle spam)
if showMagnetLn and not na(magPx)
    color mc = color.new(colMag, 35)
    if na(magLn)
        magLn := line.new(x1, magPx, x2 + 4, magPx, color=mc, style=line.style_dashed, width=2)
    else
        line.set_xy1(magLn, x1, magPx)
        line.set_xy2(magLn, x2 + 4, magPx)
        line.set_color(magLn, mc)
    if showLabs
        string mtxt = magSide == 1 ? "MAG ▲" : "MAG ▼"
        if na(magLb)
            magLb := label.new(x2 + 4, magPx, mtxt, style=label.style_label_left, color=color.new(colMag, 80), textcolor=color.new(colMag, 0), size=size.small)
        else
            label.set_xy(magLb, x2 + 4, magPx)
            label.set_text(magLb, mtxt)
else
    if not na(magLn)
        line.delete(magLn)
        magLn := na
    if not na(magLb)
        label.delete(magLb)
        magLb := na

// ═══════════════════════════════════════════════════════════════
// SIGNALS — dots only, no text clutter
// ═══════════════════════════════════════════════════════════════
bool showBslRaid = bslRaidNow and showRaidSig and not na(bslRaidDens) and bslRaidDens >= minDensSig
bool showSslRaid = sslRaidNow and showRaidSig and not na(sslRaidDens) and sslRaidDens >= minDensSig
bool showCascB = cascBsl and showCascSig
bool showCascS = cascSsl and showCascSig

plotshape(showBslRaid, title="BSL Raid", style=shape.circle, location=location.abovebar, color=color.new(colBsl, 20), size=size.tiny)
plotshape(showSslRaid, title="SSL Raid", style=shape.circle, location=location.belowbar, color=color.new(colSsl, 20), size=size.tiny)
plotshape(showCascB, title="Cascade BSL", style=shape.triangledown, location=location.abovebar, color=color.new(colMag, 30), size=size.tiny)
plotshape(showCascS, title="Cascade SSL", style=shape.triangleup, location=location.belowbar, color=color.new(colMag, 30), size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// COMPACT DASHBOARD — 5 rows only
// ═══════════════════════════════════════════════════════════════
var table dash = table.new(f_pos(dashPos), 2, 5, bgcolor=color.new(#0D1117, 25), border_color=color.new(#30363D, 40), border_width=1)

bool restackBslAlert = lastEventCode == 3 and prevEventCode != 3
bool restackSslAlert = lastEventCode == 4 and prevEventCode != 4

if barstate.islast
    if showDash
        float bPx = topB >= 0 ? array.get(bslPx, topB) : na
        float bD  = topB >= 0 ? array.get(bslDens, topB) : na
        int   bSt = topB >= 0 ? array.get(bslState, topB) : -1
        float sPx = topS >= 0 ? array.get(sslPx, topS) : na
        float sD  = topS >= 0 ? array.get(sslDens, topS) : na
        int   sSt = topS >= 0 ? array.get(sslState, topS) : -1

        string aboveTxt = na(bPx) ? "—" : str.tostring(bPx, format.mintick) + "  d" + str.tostring(bD, "#.0") + "  " + f_stateName(bSt)
        string belowTxt = na(sPx) ? "—" : str.tostring(sPx, format.mintick) + "  d" + str.tostring(sD, "#.0") + "  " + f_stateName(sSt)
        string magTxt = na(magPx) ? "—" : str.tostring(magPx, format.mintick) + (magSide == 1 ? "  ↑" : "  ↓")
        string evtTxt = lastEventTxt
        if not na(lastEventPx)
            evtTxt := lastEventTxt + "  " + str.tostring(lastEventPx, format.mintick)

        table.cell(dash, 0, 0, "LDL", text_color=color.new(colDash, 10), text_size=f_tableSize(tableSizeIn), bgcolor=color.new(#151A21, 0))
        table.cell(dash, 1, 0, "PhenLabs", text_color=color.new(colDash, 45), text_size=f_tableSize(tableSizeIn), bgcolor=color.new(#151A21, 0))
        table.cell(dash, 0, 1, "Above", text_color=color.new(colBsl, 25), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 1, 1, aboveTxt, text_color=color.new(colBsl, 0), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 0, 2, "Below", text_color=color.new(colSsl, 25), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 1, 2, belowTxt, text_color=color.new(colSsl, 0), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 0, 3, "Magnet", text_color=color.new(colMag, 25), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 1, 3, magTxt, text_color=color.new(colMag, 0), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 0, 4, "Event", text_color=color.new(colDash, 40), text_size=f_tableSize(tableSizeIn))
        table.cell(dash, 1, 4, evtTxt, text_color=color.new(colDash, 10), text_size=f_tableSize(tableSizeIn))
    else
        table.clear(dash, 0, 0, 1, 4)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(showBslRaid, title="BSL Liquidity Raid", message="MTF-LDL: Buy-side liquidity pool raided")
alertcondition(showSslRaid, title="SSL Liquidity Raid", message="MTF-LDL: Sell-side liquidity pool raided")
alertcondition(showCascB or (cascBsl and showMagnetLn), title="BSL Cascade Magnet", message="MTF-LDL: Next densest BSL cascade magnet armed")
alertcondition(showCascS or (cascSsl and showMagnetLn), title="SSL Cascade Magnet", message="MTF-LDL: Next densest SSL cascade magnet armed")
alertcondition(restackBslAlert, title="BSL Restack", message="MTF-LDL: Buy-side liquidity restacked after raid")
alertcondition(restackSslAlert, title="SSL Restack", message="MTF-LDL: Sell-side liquidity restacked after raid")

prevEventCode := lastEventCode
````
