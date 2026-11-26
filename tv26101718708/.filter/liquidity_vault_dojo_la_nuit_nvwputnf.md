# Liquidity Vault [Dojo La Nuit]

- url: https://www.tradingview.com/script/NVWpuTNf/
- type: indicator
- pine_id: PUB;ee789f79addf4de5b579fd1ae2c02535
- version: 1.0

## Description

Liquidity Vault maps resting liquidity on your chart as clean horizontal levels and tracks what happens to them — without any buy/sell signals or predictions. It is a pure visualization tool for traders who read price around liquidity.

HOW IT WORKS
The script detects swing pivots and clusters nearby highs (and nearby lows) into single liquidity zones using an ATR-based tolerance, so the levels travel across instruments without re-tuning. Each zone gets a strength score from 0 to 100 built from three factors:
• Touches — how many times price reacted at the level
• Freshness — recent levels score higher and decay over time (configurable half-life)
• Volume — relative volume that accumulated at the level

HOW TO READ IT
• Red lines = sell-side liquidity (resting above price)
• Green lines = buy-side liquidity (resting below price)
• Opacity = strength: the stronger the zone, the more solid the line
• Dimmed, dotted lines = zones that have already been swept (price wicked through the level). They are kept as context, not removed.

SETTINGS
• Zone Detection — adaptive or fixed pivot length, clustering tolerance, lookback, max live zones
• Zone Strength — minimum score to display, freshness half-life, volume weighting on/off
• Visuals — theme (auto/dark/light), strength-based intensity, keep swept zones, line width
• Colors — fully customizable buy-side / sell-side colors

NOTES
Strength is shown through line opacity by design, to keep the chart minimal. Zones are recalculated on confirmed bars. This tool highlights where liquidity rests and when it gets taken — it does not generate entries, targets or signals.

This indicator is for educational and analytical purposes only. It is not financial advice. Always do your own research and manage your own risk.

─────────────────────────

🌙 LIQUIDITY VAULT — Dojo La Nuit

Liquidity Vault mostra la liquidità presente sul grafico come livelli orizzontali puliti e ne traccia l'evoluzione, senza segnali di acquisto/vendita e senza previsioni. È uno strumento puramente visivo per chi opera attorno alla liquidità.

COME FUNZIONA
Lo script individua i pivot di mercato e raggruppa i massimi (e i minimi) vicini in un'unica zona di liquidità tramite una tolleranza basata sull'ATR, così i livelli funzionano su strumenti diversi senza dover ritoccare i parametri. A ogni zona viene assegnato un punteggio di forza da 0 a 100, calcolato su tre fattori:
• Tocchi — quante volte il prezzo ha reagito al livello
• Freschezza — i livelli recenti pesano di più e si attenuano nel tempo (half-life configurabile)
• Volume — il volume relativo accumulato sul livello

COME SI LEGGE
• Linee rosse = liquidità sell-side (sopra il prezzo)
• Linee verdi = liquidità buy-side (sotto il prezzo)
• Opacità = forza: più la zona è forte, più la linea è piena
• Linee attenuate e puntinate = zone già spazzate (il prezzo ha bucato il livello con un'ombra). Restano come contesto, non vengono rimosse.

IMPOSTAZIONI
• Rilevamento zone — pivot adattivo o fisso, tolleranza di clustering, lookback, numero massimo di zone attive
• Forza zone — punteggio minimo da mostrare, half-life della freschezza, peso del volume on/off
• Visual — tema (auto/scuro/chiaro), intensità in base alla forza, mantieni zone spazzate, spessore linea
• Colori — colori buy-side / sell-side completamente personalizzabili

NOTE
La forza è rappresentata tramite l'opacità della linea, per scelta, per mantenere il grafico minimale. Le zone vengono ricalcolate sulle barre confermate. Lo strumento evidenzia dove si trova la liquidità e quando viene presa: non genera entrate, target o segnali.

Questo indicatore è a scopo puramente didattico e di analisi. Non è consulenza finanziaria. Fai sempre le tue valutazioni e gestisci il tuo rischio.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  LIQUIDITY VAULT  —  Dojo La Nuit
//  Liquidity zone mapping · sweep tracking (visual only)
// ═══════════════════════════════════════════════════════════════════════════

indicator(
     title           = "Liquidity Vault",
     shorttitle      = "LV",
     overlay         = true,
     max_lines_count = 500,
     max_bars_back   = 5000)

// ═══════════════════════════════════════════════════════════════════════════
//  GROUP LABELS
// ═══════════════════════════════════════════════════════════════════════════
G_ZONE  = "1 · Zone Detection"
G_SCORE = "2 · Zone Strength"
G_VIS   = "3 · Visuals"
G_BRAND = "4 · Brand"
G_CLR   = "5 · Colors"

int ZONE_ACTIVE = 0
int ZONE_SWEPT  = 1

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS — ZONE DETECTION
// ═══════════════════════════════════════════════════════════════════════════
autoPivot = input.bool(true, "Auto pivot length", group = G_ZONE,
     tooltip = "ON: pivot window scales with volatility. OFF: uses the fixed length below.")
pivotLen = input.int(8, "Fixed pivot length", minval = 2, maxval = 50, group = G_ZONE,
     tooltip = "Bars on each side of a pivot when Auto is OFF. 5-8 intraday · 10-15 swing · 20+ position.")
confirmBars = input.int(2, "Confirmation bars", minval = 1, maxval = 10, group = G_ZONE)
clusterTol = input.float(0.25, "Cluster tolerance (×ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = G_ZONE,
     tooltip = "Two pivots merge into one zone when their gap ≤ this × ATR. ATR-scaled, so it travels across symbols.")
mergeWindow = input.int(200, "Merge lookback (bars)", minval = 50, maxval = 1000, group = G_ZONE)
maxZones = input.int(40, "Max live zones", minval = 5, maxval = 100, group = G_ZONE)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS — ZONE STRENGTH
// ═══════════════════════════════════════════════════════════════════════════
minScoreShow = input.int(0, "Hide zones below score", minval = 0, maxval = 100, group = G_SCORE,
     tooltip = "Visual filter. 0 shows everything.")
halfLife = input.int(150, "Freshness half-life (bars)", minval = 20, maxval = 1000, group = G_SCORE)
weightVolume = input.bool(true, "Weight by volume", group = G_SCORE,
     tooltip = "Adds volume-at-level to the score. Turn off on feeds with unreliable volume.")

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS — VISUALS
// ═══════════════════════════════════════════════════════════════════════════
theme = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = G_VIS)
showZones = input.bool(true, "Show liquidity zones", group = G_VIS)
intensityLine = input.bool(true, "Strength-based intensity", group = G_VIS,
     tooltip = "Stronger zones are drawn more opaque.")
keepSwept = input.bool(true, "Keep swept zones (dimmed)", group = G_VIS)
zoneWidth = input.int(2, "Zone line width", minval = 1, maxval = 4, group = G_VIS)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS — BRAND
// ═══════════════════════════════════════════════════════════════════════════
showBrand = input.bool(true, "Show brand watermark", group = G_BRAND)
brandText = input.string("🌙 Dojo La Nuit", "Text", group = G_BRAND)
brandPosStr = input.string("Center", "Position",
     options = ["Center", "Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = G_BRAND)
brandSizeStr = input.string("Large", "Size", options = ["Small", "Normal", "Large", "Huge"], group = G_BRAND)
brandTransp = input.int(82, "Transparency", minval = 0, maxval = 100, group = G_BRAND,
     tooltip = "Higher = fainter. ~80 keeps it as a subtle watermark.")
brandClr = input.color(#8C9EFF, "Color", group = G_BRAND)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS — COLORS
// ═══════════════════════════════════════════════════════════════════════════
bullClr = input.color(#26C281, "Demand (buy-side) color", group = G_CLR)
bearClr = input.color(#E84A5F, "Supply (sell-side) color", group = G_CLR)

// ═══════════════════════════════════════════════════════════════════════════
//  THEME PALETTE
// ═══════════════════════════════════════════════════════════════════════════
isDark = switch theme
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

SWEPT_LINE = isDark ? color.new(#9AA0A6, 55) : color.new(#5F6368, 55)

// ═══════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════
safeDiv(float a, float b, float fb = 0.0) =>
    b != 0 and not na(a) and not na(b) ? a / b : fb

brandPos = switch brandPosStr
    "Center"       => position.middle_center
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    =>                position.middle_center

brandSize = switch brandSizeStr
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    =>          size.large

// score → line transparency (strong = opaque)
lineTransp(float s) =>
    int(70.0 - math.max(0.0, math.min(100.0, s)) * 0.60)

// ═══════════════════════════════════════════════════════════════════════════
//  VOLATILITY ENGINE
// ═══════════════════════════════════════════════════════════════════════════
float atrA = nz(ta.atr(14), 0.0)
float atrB = nz(ta.atr(50), 0.0)
float volR = safeDiv(atrA, atrB, 1.0)

int adaptLen = autoPivot ? int(math.round(math.max(4.0, math.min(16.0, 10.0 / math.max(0.5, volR))))) : pivotLen
int leftLen = adaptLen
int rightLen = confirmBars
float tol = atrA * clusterTol

int WARMUP = 60
bool warmed = bar_index >= WARMUP

// ═══════════════════════════════════════════════════════════════════════════
//  TYPE
// ═══════════════════════════════════════════════════════════════════════════
type LiquidityZone
    float price        // representative level
    int   lastTouch
    int   bornTime      // creation time (xloc.bar_time anchor)
    int   touches
    float volAtLevel
    bool  isHigh        // true = sell-side (highs), false = buy-side (lows)
    int   state
    int   sweptTime
    float cached
    line  zLine

// ═══════════════════════════════════════════════════════════════════════════
//  STORAGE
// ═══════════════════════════════════════════════════════════════════════════
var array<LiquidityZone> zones = array.new<LiquidityZone>()
var float volRef = na

// ═══════════════════════════════════════════════════════════════════════════
//  PIVOTS
// ═══════════════════════════════════════════════════════════════════════════
float ph = ta.pivothigh(leftLen, rightLen)
float pl = ta.pivotlow(leftLen, rightLen)

// ═══════════════════════════════════════════════════════════════════════════
//  SCORING METHOD
//  touches 45 · freshness 35 · volume 20  → clamp 0-100
// ═══════════════════════════════════════════════════════════════════════════
method score(LiquidityZone z) =>
    int   age   = bar_index - z.lastTouch
    float fresh = math.pow(0.5, safeDiv(age, halfLife, 0.0))
    float tPts  = math.min(45.0, (z.touches - 1) * 15.0)   // 1→0 2→15 3→30 4+→45
    float fPts  = 35.0 * fresh
    float vPts  = 0.0
    if weightVolume and not na(volRef) and volRef > 0
        float ratio = safeDiv(z.volAtLevel, volRef, 0.0)
        vPts := math.min(20.0, math.max(0.0, (ratio - 1.0) * 10.0))
    z.cached := math.max(0.0, math.min(100.0, tPts + fPts + vPts))
    z.cached

// ═══════════════════════════════════════════════════════════════════════════
//  ZONE MATCH / UPDATE / CREATE
// ═══════════════════════════════════════════════════════════════════════════
matchZone(float price, bool isHigh, float t) =>
    int found = -1
    int n = zones.size()
    if n > 0
        for i = 0 to n - 1
            LiquidityZone z = zones.get(i)
            if z.state == ZONE_ACTIVE and z.isHigh == isHigh
                if math.abs(price - z.price) <= t and (bar_index - z.lastTouch) <= mergeWindow
                    found := i
                    break
    found

touchZone(int idx, float price, int tIdx, float vol) =>
    LiquidityZone z = zones.get(idx)
    z.price      := (z.price * z.touches + price) / (z.touches + 1)
    z.lastTouch  := tIdx
    z.touches    := z.touches + 1
    z.volAtLevel := z.volAtLevel + vol
    z.touches

newZone(float price, int idx, int t, float vol, bool isHigh) =>
    color brd = isHigh ? bearClr : bullClr
    line l = line.new(t, price, t, price, color = color.new(brd, 30), style = line.style_solid, width = zoneWidth, xloc = xloc.bar_time)
    LiquidityZone z = LiquidityZone.new(price, idx, t, 1, vol, isHigh, ZONE_ACTIVE, 0, 0.0, l)
    zones.push(z)
    zones.size()

// ═══════════════════════════════════════════════════════════════════════════
//  PROCESS NEW PIVOTS
// ═══════════════════════════════════════════════════════════════════════════
if not na(ph) and warmed
    int   pIdx = bar_index - rightLen
    int   pT   = time[rightLen]
    float pV   = nz(volume[rightLen], 0.0)
    int m = matchZone(ph, true, tol)
    if m >= 0
        touchZone(m, ph, pIdx, pV)
    else
        newZone(ph, pIdx, pT, pV, true)

if not na(pl) and warmed
    int   pIdx = bar_index - rightLen
    int   pT   = time[rightLen]
    float pV   = nz(volume[rightLen], 0.0)
    int m = matchZone(pl, false, tol)
    if m >= 0
        touchZone(m, pl, pIdx, pV)
    else
        newZone(pl, pIdx, pT, pV, false)

// volume reference (median of zone volume)
if zones.size() >= 3 and (na(volRef) or bar_index % 25 == 0)
    array<float> vs = array.new<float>()
    for i = 0 to zones.size() - 1
        vs.push(zones.get(i).volAtLevel)
    if vs.size() > 0
        volRef := array.median(vs)

// ═══════════════════════════════════════════════════════════════════════════
//  VOLUME-AT-LEVEL ACCUMULATION
// ═══════════════════════════════════════════════════════════════════════════
if zones.size() > 0 and warmed and barstate.isconfirmed and weightVolume
    float bv = nz(volume, 0.0)
    if bv > 0
        for i = 0 to zones.size() - 1
            LiquidityZone z = zones.get(i)
            if z.state == ZONE_ACTIVE
                float zt = z.price + tol / 2.0
                float zb = z.price - tol / 2.0
                bool hit = (high >= zb and high <= zt) or (low >= zb and low <= zt) or (low <= zb and high >= zt)
                if hit and bar_index > z.lastTouch
                    z.volAtLevel := z.volAtLevel + bv

// ═══════════════════════════════════════════════════════════════════════════
//  SWEEP TRACKING (visual lifecycle only — no signals)
// ═══════════════════════════════════════════════════════════════════════════
if zones.size() > 0 and warmed and barstate.isconfirmed
    for i = 0 to zones.size() - 1
        LiquidityZone z = zones.get(i)
        if z.state == ZONE_ACTIVE and bar_index >= z.lastTouch + rightLen + 1
            bool wick = z.isHigh ? high > z.price + tol / 2.0 : low < z.price - tol / 2.0
            if wick
                z.state := ZONE_SWEPT
                z.sweptTime := time

// ═══════════════════════════════════════════════════════════════════════════
//  PRUNE ZONES
// ═══════════════════════════════════════════════════════════════════════════
if zones.size() > 0 and barstate.isconfirmed
    if not keepSwept
        array<int> rm = array.new<int>()
        for i = 0 to zones.size() - 1
            if zones.get(i).state != ZONE_ACTIVE
                rm.push(i)
        if rm.size() > 0
            for k = 0 to rm.size() - 1
                int idx = rm.get(rm.size() - 1 - k)
                line.delete(zones.get(idx).zLine)
                zones.remove(idx)

    if zones.size() > maxZones
        int oldIdx = -1
        int oldBar = bar_index + 1
        for i = 0 to zones.size() - 1
            LiquidityZone z = zones.get(i)
            if z.state != ZONE_ACTIVE and z.lastTouch < oldBar
                oldBar := z.lastTouch
                oldIdx := i
        if oldIdx >= 0
            line.delete(zones.get(oldIdx).zLine)
            zones.remove(oldIdx)
        else
            int worst = -1
            float wScore = 1e9
            for i = 0 to zones.size() - 1
                LiquidityZone z = zones.get(i)
                if z.state == ZONE_ACTIVE
                    float s = z.score()
                    if s < wScore
                        wScore := s
                        worst := i
            if worst >= 0
                line.delete(zones.get(worst).zLine)
                zones.remove(worst)

// ═══════════════════════════════════════════════════════════════════════════
//  RENDER ZONES (last bar only)
// ═══════════════════════════════════════════════════════════════════════════
if barstate.islast and zones.size() > 0
    for i = 0 to zones.size() - 1
        LiquidityZone z = zones.get(i)
        float s = z.score()
        bool vis = showZones and (z.state == ZONE_ACTIVE ? s >= minScoreShow : keepSwept)
        if vis
            int rT = z.state == ZONE_ACTIVE ? time : z.sweptTime
            line.set_x1(z.zLine, z.bornTime)
            line.set_x2(z.zLine, rT)
            line.set_y1(z.zLine, z.price)
            line.set_y2(z.zLine, z.price)
            color base = z.isHigh ? bearClr : bullClr
            int tr = intensityLine ? lineTransp(s) : 0
            color clr = z.state == ZONE_ACTIVE ? color.new(base, tr) : SWEPT_LINE
            line.set_color(z.zLine, clr)
            line.set_style(z.zLine, z.state == ZONE_ACTIVE ? line.style_solid : line.style_dotted)
        else
            line.set_x1(z.zLine, time)
            line.set_x2(z.zLine, time)

// ═══════════════════════════════════════════════════════════════════════════
//  BRAND TAG
// ═══════════════════════════════════════════════════════════════════════════
if showBrand and barstate.islast
    var table brand = table.new(brandPos, 1, 1, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), border_width = 0, frame_color = color.new(color.black, 100), frame_width = 0)
    table.cell(brand, 0, 0, brandText, text_color = color.new(brandClr, brandTransp), text_size = brandSize, text_halign = text.align_center, text_font_family = font.family_monospace)
// ═══════════════════════════════════════════════════════════════════════════
//  END
// ═══════════════════════════════════════════════════════════════════════════
````
