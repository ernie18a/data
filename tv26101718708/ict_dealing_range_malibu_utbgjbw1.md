# ICT Dealing Range [Malibu]

- url: https://www.tradingview.com/script/UTbGjBW1/
- type: indicator
- pine_id: PUB;88b30b1756f741aa876db8e54d47aeec
- version: 1.0

## Description

ICT Dealing Range Engine [Malibu] is an open-source market structure and imbalance indicator built to organize multiple ICT-style concepts inside a single live dealing range framework. Instead of plotting Fair Value Gaps, Order Blocks, Breaker Blocks, and equilibrium zones as disconnected elements, this script uses the active dealing range as a structural engine that helps filter, organize, and maintain the most relevant zones around current price.

The purpose of this indicator is not to flood the chart with every possible imbalance or block. Its purpose is to build a cleaner, more contextual map of price by combining dealing range logic, equilibrium, liquidity interaction, market structure shifts, Fair Value Gaps, Inverted Fair Value Gaps, Order Blocks, and Breaker Blocks into one coordinated framework. This makes the script especially useful for traders who want to study price delivery inside a living range rather than treat each concept as an isolated label.

At the center of the script is a rolling dealing range calculated from a user-defined lookback window. The highest high and lowest low within that window define the active range boundaries, while the midpoint defines the equilibrium level. These values are not drawn as static references. They continuously update with market movement, which allows the range to function as a live structural context rather than a fixed historical box. The range can be visually extended to the right and styled with its own fill and boundary colors so that it remains readable without overwhelming the chart.

This range engine is what gives the script its identity. Many indicators can detect FVGs, Order Blocks, or swing-based zones, but they often do so everywhere on the chart without a hierarchy of relevance. In this script, the dealing range can act as a filter, meaning zones can be accepted, preserved, or removed according to whether they belong to the active structural window. That design choice helps reduce clutter and keeps the chart focused on what is currently most relevant from a structural perspective. Instead of treating the range as decoration, the script turns it into the framework that governs how other zones are interpreted.

The indicator can display the active dealing range itself, including the range high, range low, and optional equilibrium line. On top of that structural layer, it can detect bullish and bearish Fair Value Gaps, convert broken gaps into Inverted Fair Value Gaps, identify bullish and bearish Order Blocks after liquidity and structure conditions are met, and build bullish and bearish Breaker Blocks from recent swing relationships. Each of these zone categories can be managed independently, which gives the user control over both logic and presentation.

The Fair Value Gap engine uses a classic three-candle imbalance relationship. A bullish FVG forms when the older candle’s high is below the current candle’s low, creating a void that suggests upward displacement. A bearish FVG forms when the older candle’s low is above the current candle’s high, creating a downward imbalance. This script does not stop at merely finding such gaps. It can also require the gap to be meaningful relative to ATR, which helps ignore very thin or insignificant imbalances that often clutter lower timeframes. Once a qualifying gap is found, it is projected forward as a live zone so the user can monitor future interaction with it.

The Inverted Fair Value Gap logic extends that idea further. If a bullish FVG later breaks to the downside by close, the script can convert it into a bearish IFVG. If a bearish FVG later breaks to the upside by close, it can become a bullish IFVG. This is important because failed imbalances often retain analytical value after polarity changes. Instead of treating a broken gap as useless, the script can reinterpret it as a new directional zone. This creates a more complete picture of how imbalance evolves as price transitions from one state to another.

The Order Block logic is intentionally more selective than simple “last opposite candle” approaches. The script first tracks confirmed pivot highs and pivot lows using the chosen pivot length. Those pivots are then monitored for liquidity sweeps. A move above a stored pivot high marks buy-side liquidity taken, while a move below a stored pivot low marks sell-side liquidity taken. These events alone do not create an Order Block. Instead, they establish the context needed for the next confirmation step.

After liquidity is taken, the script waits for a close-based Market Structure Shift. This means price must actually close through a relevant structural level in the opposite direction before an Order Block candidate is allowed to form. Once that sequence completes, the script scans backward over a configurable number of bars to find the first qualifying opposite candle and uses that candle’s range as the Order Block. In practical terms, after sell-side liquidity is swept and bullish structure shifts, the script searches for a bearish candle to define a bullish OB. After buy-side liquidity is swept and bearish structure shifts, it searches for a bullish candle to define a bearish OB. This makes the Order Block engine more conditional, more context-aware, and less arbitrary than approaches that mark every local opposite candle before a move.

The Breaker Block logic is also structure-driven rather than purely cosmetic. For bearish breakers, the script looks for a high-low-high relationship in which the more recent high exceeds the previous one and price later closes below the intervening low. For bullish breakers, it looks for a low-high-low relationship in which the more recent low undercuts the previous one and price later closes above the intervening high. When those conditions are met, the corresponding region is marked as a Breaker Block. This approach makes breaker creation dependent on actual structural sequencing rather than on a simple visual approximation. To keep the chart readable, the script can also suppress near-duplicate breakers using ATR-based distance checks and remove breaker zones once they exceed a user-defined maximum age.

A major strength of the script is that all of these zones can optionally be filtered through the active dealing range. If enabled, only FVGs, IFVGs, OBs, and BBs that belong to the current structural window are retained. This is one of the main reasons the indicator is useful as a full framework rather than as a loose collection of concepts. The range is not merely a backdrop. It acts as a relevance filter that helps keep attention on the most structurally important zones around current price.

The script also includes a maintenance layer for zone management. Once zones are created, they can be extended forward for continued monitoring. If price invalidates or mitigates a zone, that zone can either be deleted or faded depending on the user’s preference. This is especially useful for traders who want to preserve historical context without keeping fully active boxes on the chart. Breakers can also expire based on age, and every major category has a cap on how many active regions can remain on screen. These controls are important not only for visual clarity but also for overall chart performance and usability.

From a user interface standpoint, the indicator is organized into functional groups so the settings remain easy to understand. The Dealing Range section controls the rolling range window, midpoint visibility, forward extension, and styling for the box and lines. The FVG / IFVG section manages gap detection, range filtering, extension length, and directional colors. The Order Blocks section controls pivot sensitivity, activation, range filtering, extension, scan depth, and color settings. The Breaker Blocks section manages activation, range filtering, extension, age limits, and directional styling. Finally, the Style / Performance section controls label visibility, label color, mitigation fading, faded opacity, and the maximum number of retained zones per category.

This layout is intentional. The script is meant to remain usable for both visual traders and more process-oriented users who want to adjust sensitivity and chart density. A lower pivot length will make the structure engine more reactive, while a higher pivot length will usually produce cleaner but slower structural responses. A shorter range lookback will make the dealing range more adaptive, while a larger one will emphasize broader price boundaries. FVG filtering, zone retention, and fading options can all be adjusted depending on how minimal or information-dense the chart should be.

A practical workflow is to first identify the active dealing range and its equilibrium. That establishes the structural frame. From there, the user can observe which imbalances and reaction zones are forming inside that range, whether price is operating above or below equilibrium, and whether recent liquidity events are producing valid structure shifts. Bullish or bearish FVGs can then be evaluated in the context of current price location, while Order Blocks and Breaker Blocks can be interpreted as more conditionally derived zones that reflect structural responses rather than raw candle patterns. If price later invalidates an FVG and flips it into an IFVG, that polarity change remains visible and can be studied as part of the evolving delivery process.

Key features:
• Rolling dealing range with optional equilibrium line
• Optional dealing-range filter for FVG, IFVG, OB, and BB zones
• ATR-based Fair Value Gap thickness filter
• Sweep + close-based Market Structure Shift logic for Order Blocks
• Structure-based Breaker Block detection
• Inverted Fair Value Gap polarity flips after invalidation
• Zone extension, cleanup, fading, and age controls
• Per-category retention limits for better chart clarity
• Organized input groups for range, FVG/IFVG, OB, BB, and style/performance settings

How to use:
Use the dealing range to define the current structural window, then use equilibrium as the internal reference point of that range. Monitor which FVGs, OBs, and BBs form inside that context, and pay attention to whether price respects, mitigates, invalidates, or flips those zones. The script is most useful when its zones are read as contextual structural areas rather than as automatic signals.

Notes:
This indicator is a chart analysis tool, not a promise of outcome. It does not guarantee direction, entries, or performance. Past market behavior does not guarantee future results. Like any structure- or imbalance-based model, it should be used together with confirmation, risk management, and broader market context.

This script is published as open-source so users can inspect the logic, study the implementation, and adapt the framework for their own research and education.

## Source Code

````pine
//@version=6
// =====================================================================
// ICT Dealing Range — Lookback Window + FVG / OB / BB Engine
// © 2026 malibuuu — Tüm hakları saklıdır.
// Bu kaynak kapalıdır. İzinsiz çoğaltma, yeniden dağıtma, satış, türev
// üretme veya yayın yasaktır. TradingView üzerinde Protected veya
// Invite-only olarak yayımlamak için bu lisans bildirimi yeterlidir.
// =====================================================================
indicator(title             = "ICT Dealing Range [Malibu]",
          shorttitle        = "ICT Dealing Range [Malibu]",
          overlay           = true,
          max_boxes_count   = 500,
          max_lines_count   = 500,
          max_labels_count  = 500)

// ---------------------------------------------------------------------
// Tip Tanımları
// ---------------------------------------------------------------------
type Pivot
    int    bar          // pivotun teyit edildiği bar
    float  price        // pivot fiyatı
    bool   taken        // likiditesi süpürüldü mü
    bool   shifted      // close ile yapısal kırılma yaşandı mı

type Region
    box    shape        // ekrandaki kutu
    float  hi           // bölgenin tavanı
    float  lo           // bölgenin tabanı
    int    born         // doğuş barı
    int    dir          // +1 long / -1 short
    bool   alive        // hâlâ mitige olmamış mı
    string kind         // "OB" | "BB" | "FVG" | "IFVG"

// ---------------------------------------------------------------------
// Girdiler
// ---------------------------------------------------------------------
string GR_DR  = "Dealing Range"
int    drBars   = input.int(50,  "Lookback Bars",      minval=2, maxval=5000,                 group=GR_DR, display=display.none)
bool   drMid    = input.bool(true,  "Equilibrium (50%)",                                       group=GR_DR, display=display.none)
int    drRight  = input.int(15,  "Extend Right",       minval=0, maxval=500,                  group=GR_DR, display=display.none)
color  drFill   = input.color(color.new(#787B86, 78),  "Range Fill",                          group=GR_DR, display=display.none)
color  drTop    = input.color(color.new(#2962FF,  0),  "Top Line",                            group=GR_DR, display=display.none)
color  drBot    = input.color(color.new(#f23645,  0),  "Bottom Line",                         group=GR_DR, display=display.none)
color  drEq     = input.color(color.new(color.gray, 0),"Mid Line",                            group=GR_DR, display=display.none)

string GR_FVG = "FVG / IFVG"
bool   fvgOn    = input.bool(true,  "FVG",                                  inline="f1",       group=GR_FVG, display=display.none)
bool   fvgDR    = input.bool(true,  "DR Filter",                            inline="f1",       group=GR_FVG, tooltip="Keep only FVGs inside the dealing range.", display=display.none)
int    fvgExt   = input.int(8, "Extend", minval=1, maxval=500,              inline="f1",       group=GR_FVG, display=display.none)
color  fvgUp    = input.color(color.new(#4DD0E1, 80),  "Bull",              inline="f2",       group=GR_FVG, display=display.none)
color  fvgDn    = input.color(color.new(#F48FB1, 80),  "Bear",              inline="f2",       group=GR_FVG, display=display.none)
bool   ifvgOn   = input.bool(true,  "IFVG",                                 inline="f3",       group=GR_FVG, display=display.none)
color  ifvgUp   = input.color(color.new(#00BCD4, 75),  "iBull",             inline="f3",       group=GR_FVG, display=display.none)
color  ifvgDn   = input.color(color.new(#E91E63, 75),  "iBear",             inline="f3",       group=GR_FVG, display=display.none)

string GR_OB  = "Order Blocks"
int    pivLen   = input.int(10, "Pivot",  minval=1, maxval=50,              inline="o1",       group=GR_OB, tooltip="Pivot length used for OB/BB structure.", display=display.none)
bool   obOn     = input.bool(true,  "OB",                                   inline="o1",       group=GR_OB, display=display.none)
bool   obDR     = input.bool(true,  "DR Filter",                            inline="o1",       group=GR_OB, display=display.none)
int    obExt    = input.int(15, "Extend", minval=1, maxval=500,             inline="o1",       group=GR_OB, display=display.none)
int    obScan   = input.int(20, "OB Scan", minval=1, maxval=100,            inline="o2",       group=GR_OB, tooltip="Bars to scan back from MSS for the OB candle.", display=display.none)
color  obUp     = input.color(color.new(#00BCD4, 70),  "Bull",              inline="o3",       group=GR_OB, display=display.none)
color  obDn     = input.color(color.new(#9C27B0, 70),  "Bear",              inline="o3",       group=GR_OB, display=display.none)

string GR_BB  = "Breaker Blocks"
bool   bbOn     = input.bool(true,  "BB",                                   inline="b1",       group=GR_BB, display=display.none)
bool   bbDR     = input.bool(true,  "DR Filter",                            inline="b1",       group=GR_BB, display=display.none)
int    bbExt    = input.int(15, "Extend", minval=1, maxval=500,             inline="b1",       group=GR_BB, display=display.none)
int    bbAge    = input.int(80, "Max Age", minval=10, maxval=500,           inline="b2",       group=GR_BB, tooltip="Breakers older than this many bars are dropped.", display=display.none)
color  bbUp     = input.color(color.new(#089981, 70),  "Bull",              inline="b3",       group=GR_BB, display=display.none)
color  bbDn     = input.color(color.new(#f23645, 70),  "Bear",              inline="b3",       group=GR_BB, display=display.none)

string GR_ST  = "Style / Performance"
color  txtCol   = input.color(color.white, "Label Color",                                      group=GR_ST, display=display.none)
bool   showLbl  = input.bool(true,  "Show Labels",                                             group=GR_ST, display=display.none)
bool   keepDead = input.bool(false, "Fade Mitigated Zones",                                    group=GR_ST, display=display.none)
int    deadOp   = input.int(90, "Faded Opacity", minval=70, maxval=98,                         group=GR_ST, display=display.none)
int    perKind  = input.int(8,  "Max per Category", minval=2, maxval=15,                       group=GR_ST, display=display.none)

// ---------------------------------------------------------------------
// Kalıcı Durum
// ---------------------------------------------------------------------
var box  rngBox  = na
var line rngTop  = na
var line rngBot  = na
var line rngEq   = na

var array<Pivot>  highs   = array.new<Pivot>()
var array<Pivot>  lows    = array.new<Pivot>()
var array<Region> obBull  = array.new<Region>()
var array<Region> obBear  = array.new<Region>()
var array<Region> bbBull  = array.new<Region>()
var array<Region> bbBear  = array.new<Region>()
var array<Region> fvgBull = array.new<Region>()
var array<Region> fvgBear = array.new<Region>()

var int  bias       = 0       // +1 long / -1 short
var bool wantBullOB = false   // SSL sweep oldu, Bull MSS bekliyor
var bool wantBearOB = false   // BSL sweep oldu, Bear MSS bekliyor

// ---------------------------------------------------------------------
// Yardımcılar
// ---------------------------------------------------------------------
nzAtr() =>
    float a = ta.atr(14)
    na(a) ? 0.0 : a

// Kutu DR penceresi içinde mi?
inRange(float zHi, float zLo, float dHi, float dLo) =>
    not na(zHi) and not na(zLo) and not na(dHi) and not na(dLo) and zHi <= dHi and zLo >= dLo

// Doğuş barı pencere içinde mi?
inWindow(int birthBar, int leftEdge) =>
    birthBar >= leftEdge

// Bölgeyi listeye yerleştir, kategori kotasını koru
pushRegion(array<Region> bag, Region r) =>
    bag.unshift(r)
    if bag.size() > perKind
        Region drop = bag.pop()
        box.delete(drop.shape)

// Bölgeyi mitige et (sil veya soluklaştır)
killRegion(Region r, color paint) =>
    r.alive := false
    if keepDead
        box.set_bgcolor(r.shape, color.new(paint, deadOp))
        box.set_border_color(r.shape, color.new(paint, deadOp))
    else
        box.delete(r.shape)

// Bir bölge dizisini tarayıp mitige edilmişleri at, kalanları sağa uzat.
// Not: if/else kullanmak yerine iki ayrı if kullanıyoruz; çünkü bag.remove()
// Region döndürür, box.set_right() void döndürür ve Pine v6 CE10235 verir.
sweepGroup(array<Region> bag, color paint, int ext, bool useAge, int maxAge) =>
    if bag.size() > 0
        for i = bag.size() - 1 to 0
            Region r = bag.get(i)
            if r.alive
                bool gone = r.dir > 0 ? close < r.lo : close > r.hi
                bool old  = useAge and (bar_index - r.born) > maxAge
                bool drop = gone or old
                if drop
                    killRegion(r, paint)
                    bag.remove(i)
                if not drop
                    box.set_right(r.shape, bar_index + ext)

// DR dışına çıkan / pencere dışındaki bölgeleri at (filtre açıksa)
pruneOutsideDR(array<Region> bag, float dHi, float dLo, int leftEdge, bool filterOn) =>
    if filterOn and bag.size() > 0
        for i = bag.size() - 1 to 0
            Region r = bag.get(i)
            if not inRange(r.hi, r.lo, dHi, dLo) or not inWindow(r.born, leftEdge)
                box.delete(r.shape)
                bag.remove(i)

// MSS'ten geriye doğru ilk uygun OB mumunu bul
findOBCandle(int maxBack, bool needBearishCandle) =>
    int found = -1
    int n     = math.min(bar_index, maxBack)
    for k = 1 to n
        bool isBear = close[k] < open[k]
        bool isBull = close[k] > open[k]
        bool hit    = needBearishCandle ? isBear : isBull
        if hit
            found := k
            break
    found

// ---------------------------------------------------------------------
// Dealing Range Hesabı + Çizim
// ---------------------------------------------------------------------
float drHi   = ta.highest(high, drBars)
float drLo   = ta.lowest (low,  drBars)
float drMd   = (drHi + drLo) * 0.5
int   leftX  = math.max(bar_index - drBars + 1, 0)
int   rightX = bar_index + drRight
bool  drOk   = not na(drHi) and not na(drLo) and drHi > drLo

if drOk
    if na(rngBox)
        rngBox := box.new(leftX, drHi, rightX, drLo, xloc=xloc.bar_index, bgcolor=drFill, border_color=color.new(drFill, 40), border_width=1)
    else
        box.set_lefttop(rngBox, leftX, drHi)
        box.set_rightbottom(rngBox, rightX, drLo)
        box.set_bgcolor(rngBox, drFill)
        box.set_border_color(rngBox, color.new(drFill, 40))

    if na(rngTop)
        rngTop := line.new(leftX, drHi, rightX, drHi, xloc=xloc.bar_index, color=drTop, width=2)
    else
        line.set_xy1(rngTop, leftX, drHi)
        line.set_xy2(rngTop, rightX, drHi)
        line.set_color(rngTop, drTop)

    if na(rngBot)
        rngBot := line.new(leftX, drLo, rightX, drLo, xloc=xloc.bar_index, color=drBot, width=2)
    else
        line.set_xy1(rngBot, leftX, drLo)
        line.set_xy2(rngBot, rightX, drLo)
        line.set_color(rngBot, drBot)

    if drMid
        if na(rngEq)
            rngEq := line.new(leftX, drMd, rightX, drMd, xloc=xloc.bar_index, color=drEq, width=1, style=line.style_dashed)
        else
            line.set_xy1(rngEq, leftX, drMd)
            line.set_xy2(rngEq, rightX, drMd)
            line.set_color(rngEq, drEq)
    else
        if not na(rngEq)
            line.delete(rngEq)
            rngEq := na
else
    if not na(rngBox)
        box.delete(rngBox)
        rngBox := na
    if not na(rngTop)
        line.delete(rngTop)
        rngTop := na
    if not na(rngBot)
        line.delete(rngBot)
        rngBot := na
    if not na(rngEq)
        line.delete(rngEq)
        rngEq := na

float atrVal = nzAtr()
bool  atrOk  = atrVal > 0

// ---------------------------------------------------------------------
// Pivot Yakalama
// ---------------------------------------------------------------------
float pvH = ta.pivothigh(high, pivLen, pivLen)
float pvL = ta.pivotlow (low,  pivLen, pivLen)

if not na(pvH)
    int pvBar = bar_index - pivLen
    highs.unshift(Pivot.new(pvBar, pvH, false, false))
    if highs.size() > 15
        highs.pop()

if not na(pvL)
    int pvBar = bar_index - pivLen
    lows.unshift(Pivot.new(pvBar, pvL, false, false))
    if lows.size() > 15
        lows.pop()

// ---------------------------------------------------------------------
// Likidite Sweep
// ---------------------------------------------------------------------
bool bullSwept = false   // BSL alındı (yukarı sweep)
bool bearSwept = false   // SSL alındı (aşağı sweep)

if highs.size() > 0
    int loopN = math.min(highs.size() - 1, 10)
    for i = 0 to loopN
        Pivot p = highs.get(i)
        if not p.taken and high > p.price
            p.taken := true
            bullSwept := true
            highs.set(i, p)

if lows.size() > 0
    int loopN = math.min(lows.size() - 1, 10)
    for i = 0 to loopN
        Pivot p = lows.get(i)
        if not p.taken and low < p.price
            p.taken := true
            bearSwept := true
            lows.set(i, p)

// Sweep sonrası karşı yönde OB bekle
if bearSwept
    wantBullOB := true
if bullSwept
    wantBearOB := true

// ---------------------------------------------------------------------
// Market Structure Shift (close ile yapı kırılması)
// ---------------------------------------------------------------------
bool mssUp   = false
bool mssDown = false

if highs.size() >= 2
    int loopN = math.min(highs.size() - 1, 10)
    for i = 1 to loopN
        Pivot p = highs.get(i)
        if not p.shifted
            if close > p.price
                p.shifted := true
                bias      := 1
                mssUp     := true
                highs.set(i, p)
            break

if lows.size() >= 2
    int loopN = math.min(lows.size() - 1, 10)
    for i = 1 to loopN
        Pivot p = lows.get(i)
        if not p.shifted
            if close < p.price
                p.shifted := true
                bias      := -1
                mssDown   := true
                lows.set(i, p)
            break

// ---------------------------------------------------------------------
// Order Block (MSS + bekleyen yön)
// ---------------------------------------------------------------------
if obOn
    if mssUp and wantBullOB
        int back = findOBCandle(obScan, true)
        if back >= 0
            float oHi = high[back]
            float oLo = low[back]
            int   oId = bar_index - back
            bool  ok  = drOk and (not obDR or inRange(oHi, oLo, drHi, drLo)) and inWindow(oId, leftX)
            if ok
                box bx = box.new(oId, oHi, bar_index + obExt, oLo, bgcolor=obUp, border_width=1, border_color=obUp, text=showLbl ? "OB+" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                pushRegion(obBull, Region.new(bx, oHi, oLo, oId, 1, true, "OB"))
        wantBullOB := false

    if mssDown and wantBearOB
        int back = findOBCandle(obScan, false)
        if back >= 0
            float oHi = high[back]
            float oLo = low[back]
            int   oId = bar_index - back
            bool  ok  = drOk and (not obDR or inRange(oHi, oLo, drHi, drLo)) and inWindow(oId, leftX)
            if ok
                box bx = box.new(oId, oHi, bar_index + obExt, oLo, bgcolor=obDn, border_width=1, border_color=obDn, text=showLbl ? "OB-" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                pushRegion(obBear, Region.new(bx, oHi, oLo, oId, -1, true, "OB"))
        wantBearOB := false

// ---------------------------------------------------------------------
// Breaker Block — H-L-H (bear) ve L-H-L (bull) örüntüleri
// ---------------------------------------------------------------------
if bbOn and highs.size() >= 2 and lows.size() >= 2

    // Bearish BB: h2 > h1, arada midLow, close midLow altına kapanırsa
    bool placedBear = false
    int  hCap       = math.min(highs.size() - 2, 8)
    for hi = 0 to hCap
        if placedBear
            break
        Pivot h2 = highs.get(hi)
        Pivot h1 = highs.get(hi + 1)
        if h2.price > h1.price
            int lCap = math.min(lows.size() - 1, 8)
            for j = 0 to lCap
                Pivot mid = lows.get(j)
                if h1.bar < mid.bar and mid.bar < h2.bar
                    if close < mid.price
                        int lb = bar_index - mid.bar
                        if lb >= 0 and lb < 500
                            float zHi = high[lb]
                            float zLo = low[lb]
                            bool dup = false
                            if bbBear.size() > 0
                                for d = 0 to bbBear.size() - 1
                                    if atrOk and math.abs(bbBear.get(d).hi - zHi) < atrVal * 0.05
                                        dup := true
                                        break
                            bool ok = not dup and drOk and (not bbDR or inRange(zHi, zLo, drHi, drLo)) and inWindow(mid.bar, leftX)
                            if ok
                                box bx = box.new(mid.bar, zHi, bar_index + bbExt, zLo, bgcolor=bbDn, border_width=1, border_color=bbDn, text=showLbl ? "BB-" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                                pushRegion(bbBear, Region.new(bx, zHi, zLo, mid.bar, -1, true, "BB"))
                                placedBear := true
                    break

    // Bullish BB: l2 < l1, arada midHigh, close midHigh üzerine kapanırsa
    bool placedBull = false
    int  lCap2      = math.min(lows.size() - 2, 8)
    for li = 0 to lCap2
        if placedBull
            break
        Pivot l2 = lows.get(li)
        Pivot l1 = lows.get(li + 1)
        if l2.price < l1.price
            int hCap2 = math.min(highs.size() - 1, 8)
            for j = 0 to hCap2
                Pivot mid = highs.get(j)
                if l1.bar < mid.bar and mid.bar < l2.bar
                    if close > mid.price
                        int lb = bar_index - mid.bar
                        if lb >= 0 and lb < 500
                            float zHi = high[lb]
                            float zLo = low[lb]
                            bool dup = false
                            if bbBull.size() > 0
                                for d = 0 to bbBull.size() - 1
                                    if atrOk and math.abs(bbBull.get(d).lo - zLo) < atrVal * 0.05
                                        dup := true
                                        break
                            bool ok = not dup and drOk and (not bbDR or inRange(zHi, zLo, drHi, drLo)) and inWindow(mid.bar, leftX)
                            if ok
                                box bx = box.new(mid.bar, zHi, bar_index + bbExt, zLo, bgcolor=bbUp, border_width=1, border_color=bbUp, text=showLbl ? "BB+" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                                pushRegion(bbBull, Region.new(bx, zHi, zLo, mid.bar, 1, true, "BB"))
                                placedBull := true
                    break

// ---------------------------------------------------------------------
// Fair Value Gap (t-2 ve t arasında t-1 köprü mumlu boşluk)
// ---------------------------------------------------------------------
if fvgOn
    // Bullish FVG: high[2] < low (yukarı gap)
    float upBase = high[2]
    float upTop  = low
    bool  upGap  = not na(upBase) and not na(upTop) and upTop > upBase
    if upGap
        float thick   = upTop - upBase
        bool  thickOk = atrOk and thick >= atrVal * 0.1
        bool  win     = drOk and (not fvgDR or inRange(upTop, upBase, drHi, drLo)) and inWindow(bar_index - 1, leftX)
        if thickOk and win
            box bx = box.new(bar_index - 1, upTop, bar_index + fvgExt, upBase, bgcolor=fvgUp, border_width=1, border_color=fvgUp, text=showLbl ? "FVG+" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
            pushRegion(fvgBull, Region.new(bx, upTop, upBase, bar_index - 1, 1, true, "FVG"))

    // Bearish FVG: low[2] > high (aşağı gap)
    float dnBase = low[2]
    float dnBot  = high
    bool  dnGap  = not na(dnBase) and not na(dnBot) and dnBase > dnBot
    if dnGap
        float thick   = dnBase - dnBot
        bool  thickOk = atrOk and thick >= atrVal * 0.1
        bool  win     = drOk and (not fvgDR or inRange(dnBase, dnBot, drHi, drLo)) and inWindow(bar_index - 1, leftX)
        if thickOk and win
            box bx = box.new(bar_index - 1, dnBase, bar_index + fvgExt, dnBot, bgcolor=fvgDn, border_width=1, border_color=fvgDn, text=showLbl ? "FVG-" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
            pushRegion(fvgBear, Region.new(bx, dnBase, dnBot, bar_index - 1, -1, true, "FVG"))

// ---------------------------------------------------------------------
// Inverted FVG — close FVG'yi ters yönde kapatırsa polariteyi çevir
// ---------------------------------------------------------------------
if ifvgOn
    // Bull FVG aşağı kırıldı -> Bear IFVG yarat
    if fvgBull.size() > 0
        for i = fvgBull.size() - 1 to 0
            Region r = fvgBull.get(i)
            if r.alive and close < r.lo
                bool win = drOk and (not fvgDR or inRange(r.hi, r.lo, drHi, drLo)) and inWindow(r.born, leftX)
                if win
                    box bx = box.new(r.born, r.hi, bar_index + fvgExt, r.lo, bgcolor=ifvgDn, border_width=1, border_color=ifvgDn, text=showLbl ? "IFVG-" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                    pushRegion(fvgBear, Region.new(bx, r.hi, r.lo, r.born, -1, true, "IFVG"))
                box.delete(r.shape)
                fvgBull.remove(i)
                break

    // Bear FVG yukarı kırıldı -> Bull IFVG yarat
    if fvgBear.size() > 0
        for i = fvgBear.size() - 1 to 0
            Region r = fvgBear.get(i)
            if r.alive and close > r.hi
                bool win = drOk and (not fvgDR or inRange(r.hi, r.lo, drHi, drLo)) and inWindow(r.born, leftX)
                if win
                    box bx = box.new(r.born, r.hi, bar_index + fvgExt, r.lo, bgcolor=ifvgUp, border_width=1, border_color=ifvgUp, text=showLbl ? "IFVG+" : "", text_size=size.tiny, text_color=txtCol, text_halign=text.align_right)
                    pushRegion(fvgBull, Region.new(bx, r.hi, r.lo, r.born, 1, true, "IFVG"))
                box.delete(r.shape)
                fvgBear.remove(i)
                break

// ---------------------------------------------------------------------
// DR Dışı / Pencere Dışı Bölgeleri Temizle (filtre açıksa)
// ---------------------------------------------------------------------
pruneOutsideDR(obBull,  drHi, drLo, leftX, obDR)
pruneOutsideDR(obBear,  drHi, drLo, leftX, obDR)
pruneOutsideDR(bbBull,  drHi, drLo, leftX, bbDR)
pruneOutsideDR(bbBear,  drHi, drLo, leftX, bbDR)
pruneOutsideDR(fvgBull, drHi, drLo, leftX, fvgDR)
pruneOutsideDR(fvgBear, drHi, drLo, leftX, fvgDR)

// ---------------------------------------------------------------------
// Mitigation + Sağa Uzatma + Yaş Sınırı
// ---------------------------------------------------------------------
sweepGroup(obBull,  obUp,  obExt,  false, 0)
sweepGroup(obBear,  obDn,  obExt,  false, 0)
sweepGroup(bbBull,  bbUp,  bbExt,  true,  bbAge)
sweepGroup(bbBear,  bbDn,  bbExt,  true,  bbAge)
sweepGroup(fvgBull, fvgUp, fvgExt, false, 0)
sweepGroup(fvgBear, fvgDn, fvgExt, false, 0)
````
