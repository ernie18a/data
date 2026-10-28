# Strong Retest Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/azhOm7fF-Strong-Retest-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;3a11b15514e44cdfacc33da9da67bf42
- version: 1.0

## Description

Strong Retest Zones automatically maps and power-ranks the swing-based levels that price keeps reacting to. It tracks each level through its full life — formation, tests, breakout, and retest — scores it 0–10 from real interaction, and shows only the zones that earn their place, keeping the chart clean and focused on levels that matter.

🎯 Power-Ranking System (0–10) — every zone earns a live score from three things: how many times it's been tested/retested, the volume traded while it was active, and the depth of the rejection wicks off it. An idle-decay lets ignored levels fade while respected ones stay strong, so the score reflects current relevance.
🔁 Double-Shaded Break & Retest Zones — each level is drawn in two tones: one shade while it holds, a contrasting shade once price breaks through. You see at a glance whether a zone is still defending or has flipped.
🏷️ In-Zone Strength Labels — every zone carries its grade inside it: stars, the X.X/10 score, a tier (FORMING → WEAK → MODERATE → STRONG → ELITE), and the live retest count (R:) — quality reads instantly without a separate panel.
🧹 Overlap Suppression — when a new zone would stack on top of an existing one, it's skipped so each price area shows a single clean level instead of a cluster.

⭐ Strong-Only Filter — hide everything below a score threshold (default 5/10); weak zones that never earn the score are discarded rather than kept, so the chart only carries proven levels.
🔔 Comprehensive Native Alerts — proximity alerts for bullish and bearish zones, dedicated STRONG-zone proximity alerts (configurable, e.g. 7/10+), plus touch/retest and break events, so you never miss a key level interaction.
⚙️ Uniform or Natural Zone Height — normalize every zone to one ATR- or %-based thickness for a clean look, or anchor to the raw swing.
🚦 Performance Guards — a lookback window and a max-zones-kept cap keep load times fast on long histories; retired zones are fully removed, not just hidden.
🔧 Fully Customizable — std-dev color palette, transparency, borders, label size (Large by default), marker mode, scoring weights, pivot sensitivity, and max levels shown — all adjustable.

🎯 Why this algo is unique — standard pivot tools flood the chart with equal-weight lines. Strong Retest Zones filters, dedupes, and ranks them, then keeps only the levels that have proven they matter. It doesn't just show where a level was — it quantifies how strong it is from real interaction (touches, volume, rejection), giving you a clear read on which levels are holding and which are likely to break.
🚀 Apply to Gold (XAUUSD), Forex, Crypto, and Indices on any timeframe. Pivot sensitivity, zone height, lookback, and the strong threshold adapt it from scalping to swing trading.
🎯 How to use this? Focus on zones rated 7/10 or higher — these have the highest probability of producing a significant reaction. Watch the two-tone state to judge whether a level is holding or has flipped, and use the proximity and strong-zone alerts to prepare entries or exits.

⚠️ IMPORTANT NOTICE: This indicator identifies high-probability retest zones. It should NOT be used as a standalone signal for entering trades. Always use it alongside your own trading strategy, price action analysis, and other technical indicators to confirm setups and manage risk.

## Source Code

````pine
//@version=6
indicator("Strong Retest Zones", "Strong Retest Zones", overlay = true, max_labels_count = 500, max_boxes_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
//                               INPUTS
// ═══════════════════════════════════════════════════════════════════════════
gD = "═══ Display ═══"
mode        = input.string("Bullish AND Bearish", "Zone Side", options = ["Bullish OR Bearish", "Bullish AND Bearish", "Bearish", "Bullish"], group = gD)
markMode    = input.string("All", "Touch Markers", options = ["All", "Last", "None"], group = gD)
showInfo    = input.bool(true, "Show Strength Labels", group = gD)
labSizeS    = input.string("Large", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
lookbackBars= input.int(2000, "Lookback (bars, 0 = all loaded)", minval = 0, group = gD, tooltip = "Only build zones within this many recent bars. 0 = use everything loaded.")
maxZones    = input.int(60, "Max Zones Kept (history)", minval = 1, maxval = 200, group = gD, tooltip = "Oldest zones are removed past this so loading stays fast.")
hideOverlap = input.bool(true, "Hide Overlapping Zones", group = gD, tooltip = "If a new zone overlaps an existing one, it is skipped so only one zone shows in that price area.")
overlapThr  = input.int(10, "Overlap Threshold (%)", minval = 1, maxval = 100, group = gD)

gS = "═══ Swing Detection ═══"
leftBars  = input.int(10, "Pivot Left",  minval = 1, group = gS)
rightBars = input.int(1,  "Pivot Right", minval = 1, group = gS)
maxLife   = input.int(500, "Max Zone Life (bars)", minval = 10, group = gS)
markGap   = input.int(0, "Min Bars Between Touch Markers", minval = 0, group = gS)
markCap   = input.int(6, "Max Markers Per Zone", minval = 1, maxval = 50, group = gS)
setBack   = input.bool(true, "Snap Right Edge To Last Touch", group = gS)

gH = "═══ Zone Height ═══"
normHeight = input.bool(true, "Normalize All Zone Heights", group = gH, tooltip = "Force every zone to the same thickness, centered on the swing level.")
heightMode = input.string("ATR Based", "Height Method", options = ["ATR Based", "Fixed Percentage"], group = gH)
heightATR  = input.float(0.5, "Zone Height (ATR Mult)", minval = 0.05, maxval = 10.0, step = 0.05, group = gH)
heightPct  = input.float(0.30, "Zone Height (% of Price)", minval = 0.01, maxval = 5.0, step = 0.05, group = gH)
atrLen     = input.int(200, "ATR Length", minval = 1, maxval = 500, group = gH)

gStr = "═══ Strength Scoring (0–10) ═══"
onlyStrong= input.bool(true, "Show Only Strong Zones", group = gStr, tooltip = "Only display zones whose live strength reaches the threshold below.")
strongThr = input.float(5.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
volLen    = input.int(20, "Volume Baseline Length", minval = 1, group = gStr)
touchNorm = input.float(4.0, "Touches For Full Score", minval = 1, step = 0.5, group = gStr)
wTouch    = input.float(0.40, "Weight: Touches / Retests", minval = 0, maxval = 1, step = 0.05, group = gStr)
wVol      = input.float(0.30, "Weight: Volume", minval = 0, maxval = 1, step = 0.05, group = gStr)
wWick     = input.float(0.30, "Weight: Rejection Wick", minval = 0, maxval = 1, step = 0.05, group = gStr)
useDecay  = input.bool(true, "Decay Strength While Ignored", group = gStr)
decayBars = input.int(300, "Full Decay Over (idle bars)", minval = 20, maxval = 5000, group = gStr)
decayFloor= input.float(0.65, "Decay Floor", minval = 0.1, maxval = 1.0, step = 0.05, group = gStr)

gC = "═══ Style (Std-Dev Palette) ═══"
supCol    = input.color(#21c997, "Tone A (zone holding)", group = gC)
resCol    = input.color(#cc24e2, "Tone B (after break)", group = gC)
fillTransp= input.int(80, "Zone Transparency", minval = 50, maxval = 96, group = gC)
showBord  = input.bool(true, "Show Zone Borders", group = gC)
bordTransp= input.int(35, "Border Transparency", minval = 0, maxval = 100, group = gC)

gA = "═══ Alerts ═══"
alertProx = input.float(0.10, "Proximity (% of price)", minval = 0.0, step = 0.01, group = gA, tooltip = "Alerts fire when price is within this % of a zone's midline.")
instThr   = input.float(7.0, "Strong / Institutional Score", minval = 0, maxval = 10, step = 0.5, group = gA, tooltip = "Score at or above which proximity counts as a STRONG-zone alert.")

// ═══════════════════════════════════════════════════════════════════════════
//                               HELPERS
// ═══════════════════════════════════════════════════════════════════════════
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_stars(sc) => sc >= 8 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5 ? "★★" : sc >= 3 ? "★" : "·"
f_tier(sc)  => sc >= 8 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5 ? "MODERATE" : sc >= 3 ? "WEAK" : "FORMING"
f_ageF(age) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(age / math.max(decayBars, 1), 1.0), decayFloor)
f_zoneHeight(atr_) => heightMode == "ATR Based" ? atr_ * heightATR : close * (heightPct / 100.0)
f_vis(sc) => not onlyStrong or sc >= strongThr

// Significant price-range overlap between two zones?
f_rangeOverlap(float t1, float b1, float t2, float b2) =>
    float ov   = math.min(t1, t2) - math.max(b1, b2)
    float minH = math.min(t1 - b1, t2 - b2)
    ov > 0 and minH > 0 and ov / minH >= overlapThr / 100.0

// Combined 0–10 strength: touches + volume intensity + rejection-wick depth, with idle decay.
f_score(int touches, float volSum, float wickSum, int wickN, int held, int age, float volBase, float atrv) =>
    tF = math.min(touches / math.max(touchNorm, 1.0), 1.0)
    vF = volBase > 0 and held > 0 ? math.min((volSum / held) / volBase, 1.0) : 0.0
    wF = atrv > 0 and wickN > 0 ? math.min((wickSum / wickN) / atrv, 1.0) : 0.0
    wSum = wTouch + wVol + wWick
    raw  = wSum > 0 ? (tF * wTouch + vF * wVol + wF * wWick) / wSum : 0.0
    math.min(math.max(raw * 10.0 * f_ageF(age), 0.0), 10.0)

// ═══════════════════════════════════════════════════════════════════════════
//                               TYPES + HISTORY POOL
// ═══════════════════════════════════════════════════════════════════════════
type swingZone
    box          setupBox = na
    box          breakBox = na
    int          phase    = 0
    float        top      = na
    float        bot      = na
    float        mid      = na
    int          bornBar  = na
    int          lastBar  = na
    int          touches  = 0
    float        volSum   = 0.0
    float        wickSum  = 0.0
    int          wickN    = 0
    array<label> marks    = na
    label        tag      = na
    float        score    = 0.0

type zoneRec
    box          a
    box          b
    label        t
    array<label> m
    float        price
    float        sc
    int          dir

var array<zoneRec> hist = array.new<zoneRec>()

f_killRec(zoneRec r) =>
    box.delete(r.a)
    box.delete(r.b)
    label.delete(r.t)
    if array.size(r.m) > 0
        for x in r.m
            label.delete(x)
        array.clear(r.m)

f_archive(box a, box b, label t, array<label> m, float price, float sc, int dir) =>
    array.push(hist, zoneRec.new(a, b, t, m, price, sc, dir))
    while array.size(hist) > maxZones
        f_killRec(array.shift(hist))

// Does a prospective zone overlap any archived zone?
f_overlapsHist(float t, float b) =>
    bool hit = false
    if array.size(hist) > 0
        for r in hist
            if not na(r.a) and f_rangeOverlap(t, b, box.get_top(r.a), box.get_bottom(r.a))
                hit := true
    hit

// ═══════════════════════════════════════════════════════════════════════════
//                               METHODS
// ═══════════════════════════════════════════════════════════════════════════
method canMark(swingZone self) =>
    markMode == "None" ? false : self.marks.size() == 0 ? true : (markMode == "Last" ? true : bar_index - self.marks.first().get_x() > markGap)

method mark(swingZone self, color col, bool up, string glyph) =>
    if markMode != "None"
        sty = up ? label.style_label_up : label.style_label_down
        yy  = up ? self.bot : self.top
        lab = label.new(bar_index, yy, glyph, style = sty, color = color(na), textcolor = col, size = size.tiny)
        self.marks.unshift(lab)
        if markMode == "Last" and self.marks.size() > 1
            label.delete(self.marks.pop())
        else if self.marks.size() > markCap
            label.delete(self.marks.pop())

method newCycle(swingZone self) =>
    self.touches := 0
    self.volSum  := 0.0
    self.wickSum := 0.0
    self.wickN   := 0
    self.tag     := na
    self.marks   := array.new<label>()

method freezeTag(swingZone self, box b) =>
    if showInfo and not na(self.tag) and not na(b)
        label.set_style(self.tag, label.style_label_right)
        label.set_x(self.tag, box.get_right(b))

// Toggle a zone's two boxes between visible and hidden (for the strong-only filter).
method setVis(swingZone self, bool vis, color fS, color bS, color fB, color bB) =>
    box.set_bgcolor(self.setupBox, vis ? fS : na)
    box.set_border_color(self.setupBox, vis ? bS : na)
    if not na(self.breakBox)
        box.set_bgcolor(self.breakBox, vis ? fB : na)
        box.set_border_color(self.breakBox, vis ? bB : na)

// Strength readout INSIDE the zone, hidden when the zone is filtered out.
method refreshTag(swingZone self, string head, float sc, color tcol, int x, bool vis) =>
    if showInfo
        if vis
            txt = head + "  " + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  (" + f_tier(sc) + ")  ·  R:" + str.tostring(self.touches)
            if na(self.tag)
                self.tag := label.new(x, self.mid, txt, style = label.style_label_right, color = color.new(color.black, 100), textcolor = tcol, size = f_size(labSizeS))
            else
                label.set_text(self.tag, txt)
                label.set_xy(self.tag, x, self.mid)
            label.set_textcolor(self.tag, tcol)
        else
            if not na(self.tag)
                label.set_text(self.tag, "")

// Retire a structure: archive it (keep) or delete every drawing (drop).
method finalize(swingZone self, box keepBox, bool keep, int dir, float sc) =>
    if keep
        self.freezeTag(keepBox)
        f_archive(self.setupBox, self.breakBox, self.tag, self.marks, self.mid, sc, dir)
    else
        box.delete(self.setupBox)
        box.delete(self.breakBox)
        label.delete(self.tag)
        self.tag := na
        if self.marks.size() > 0
            for x in self.marks
                label.delete(x)
            self.marks.clear()

// ═══════════════════════════════════════════════════════════════════════════
//                               STATE
// ═══════════════════════════════════════════════════════════════════════════
n        = bar_index
atrRaw   = nz(ta.atr(atrLen), ta.cum(high - low) / (n + 1))
volBase  = ta.sma(volume, volLen)
ph       = ta.pivothigh(leftBars, rightBars)
pl       = ta.pivotlow(leftBars, rightBars)
fillA    = color.new(supCol, fillTransp)
fillB    = color.new(resCol, fillTransp)
bordA    = showBord ? color.new(supCol, bordTransp) : color(na)
bordB    = showBord ? color.new(resCol, bordTransp) : color(na)
inWindow = lookbackBars <= 0 or (last_bar_index - n) <= lookbackBars

var swingZone bull = swingZone.new()
var swingZone bear = swingZone.new()
if barstate.isfirst
    bull.marks := array.new<label>()
    bear.marks := array.new<label>()

bullOn = mode == "Bullish" or mode == "Bullish AND Bearish" or (mode == "Bullish OR Bearish" and bear.phase == 0)
bearOn = mode == "Bearish" or mode == "Bullish AND Bearish" or (mode == "Bullish OR Bearish" and bull.phase == 0)

bool evTouch = false
bool evBreak = false

// ═══════════════════════════════════════════════════════════════════════════
//                               BULLISH ENGINE   (tone A → tone B on break)
// ═══════════════════════════════════════════════════════════════════════════
if bullOn
    switch bull.phase
        0 =>
            if not na(pl) and inWindow
                float h    = f_zoneHeight(atrRaw)
                float nTop = normHeight ? pl + h / 2.0 : pl + h
                float nBot = normHeight ? pl - h / 2.0 : pl
                bool  clash = hideOverlap and ((bear.phase > 0 and f_rangeOverlap(nTop, nBot, bear.top, bear.bot)) or f_overlapsHist(nTop, nBot))
                if not clash
                    bull.newCycle()
                    bull.top      := nTop
                    bull.bot      := nBot
                    bull.mid      := (nTop + nBot) / 2.0
                    bull.bornBar  := n - rightBars
                    bull.lastBar  := n
                    bull.volSum   := nz(volume)
                    bull.setupBox := box.new(n - rightBars, nTop, n, nBot, bgcolor = fillA, border_color = bordA, border_width = 1)
                    bull.breakBox := na
                    bull.phase    := 1
        1 =>
            if n - bull.bornBar >= maxLife
                if bull.touches == 0
                    bull.finalize(bull.setupBox, false, 1, 0.0)
                else
                    float scN = f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, n - bull.lastBar, volBase, atrRaw)
                    bool keep = f_vis(scN)
                    if keep and setBack and bull.marks.size() > 0
                        box.set_right(bull.setupBox, bull.marks.first().get_x())
                    bull.finalize(bull.setupBox, keep, 1, scN)
                bull.phase := 0
            else
                box.set_right(bull.setupBox, n)
                bull.volSum += nz(volume)
                if close < bull.bot
                    bull.breakBox := box.new(n, bull.top, n, bull.bot, bgcolor = fillB, border_color = bordB, border_width = 1)
                    bull.phase    := 2
                    evBreak       := true
                else if low <= bull.top and close > bull.top and bull.canMark()
                    bull.touches += 1
                    evTouch      := true
                    bull.wickSum += math.max(bull.top - low, 0)
                    bull.wickN   += 1
                    bull.lastBar := n
                    if f_vis(f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, 0, volBase, atrRaw))
                        bull.mark(supCol, true, "▲")
        2 =>
            if n - bull.bornBar >= maxLife
                float scN = f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, n - bull.lastBar, volBase, atrRaw)
                bool keep = f_vis(scN)
                if keep and setBack and bull.marks.size() > 0
                    box.set_right(bull.breakBox, bull.marks.first().get_x())
                bull.finalize(bull.breakBox, keep, 1, scN)
                bull.phase := 0
            else
                box.set_right(bull.breakBox, n)
                bull.volSum += nz(volume)
                if close > bull.top
                    float scN = f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, n - bull.lastBar, volBase, atrRaw)
                    bull.finalize(bull.breakBox, f_vis(scN), 1, scN)
                    bull.phase := 0
                else if high >= bull.bot and close < bull.bot and bull.canMark()
                    bull.touches += 1
                    evTouch      := true
                    bull.wickSum += math.max(high - bull.bot, 0)
                    bull.wickN   += 1
                    bull.lastBar := n
                    if f_vis(f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, 0, volBase, atrRaw))
                        bull.mark(resCol, false, "▽")

    if bull.phase == 1 or bull.phase == 2
        scB  = f_score(bull.touches, bull.volSum, bull.wickSum, bull.wickN, n - bull.bornBar, n - bull.lastBar, volBase, atrRaw)
        bull.score := scB
        visB = f_vis(scB)
        bull.setVis(visB, fillA, bordA, fillB, bordB)
        boxB = bull.phase == 2 ? bull.breakBox : bull.setupBox
        bull.refreshTag("▲ Retest Zone", scB, bull.phase == 1 ? supCol : resCol, box.get_right(boxB), visB)

// ═══════════════════════════════════════════════════════════════════════════
//                               BEARISH ENGINE   (tone B → tone A on break)
// ═══════════════════════════════════════════════════════════════════════════
if bearOn
    switch bear.phase
        0 =>
            if not na(ph) and inWindow
                float h    = f_zoneHeight(atrRaw)
                float nTop = normHeight ? ph + h / 2.0 : ph
                float nBot = normHeight ? ph - h / 2.0 : ph - h
                bool  clash = hideOverlap and ((bull.phase > 0 and f_rangeOverlap(nTop, nBot, bull.top, bull.bot)) or f_overlapsHist(nTop, nBot))
                if not clash
                    bear.newCycle()
                    bear.top      := nTop
                    bear.bot      := nBot
                    bear.mid      := (nTop + nBot) / 2.0
                    bear.bornBar  := n - rightBars
                    bear.lastBar  := n
                    bear.volSum   := nz(volume)
                    bear.setupBox := box.new(n - rightBars, nTop, n, nBot, bgcolor = fillB, border_color = bordB, border_width = 1)
                    bear.breakBox := na
                    bear.phase    := 1
        1 =>
            if n - bear.bornBar >= maxLife
                if bear.touches == 0
                    bear.finalize(bear.setupBox, false, -1, 0.0)
                else
                    float scN = f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, n - bear.lastBar, volBase, atrRaw)
                    bool keep = f_vis(scN)
                    if keep and setBack and bear.marks.size() > 0
                        box.set_right(bear.setupBox, bear.marks.first().get_x())
                    bear.finalize(bear.setupBox, keep, -1, scN)
                bear.phase := 0
            else
                box.set_right(bear.setupBox, n)
                bear.volSum += nz(volume)
                if close > bear.top
                    bear.breakBox := box.new(n, bear.top, n, bear.bot, bgcolor = fillA, border_color = bordA, border_width = 1)
                    bear.phase    := 2
                    evBreak       := true
                else if high >= bear.bot and close < bear.bot and bear.canMark()
                    bear.touches += 1
                    evTouch      := true
                    bear.wickSum += math.max(high - bear.bot, 0)
                    bear.wickN   += 1
                    bear.lastBar := n
                    if f_vis(f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, 0, volBase, atrRaw))
                        bear.mark(resCol, false, "▼")
        2 =>
            if n - bear.bornBar >= maxLife
                float scN = f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, n - bear.lastBar, volBase, atrRaw)
                bool keep = f_vis(scN)
                if keep and setBack and bear.marks.size() > 0
                    box.set_right(bear.breakBox, bear.marks.first().get_x())
                bear.finalize(bear.breakBox, keep, -1, scN)
                bear.phase := 0
            else
                box.set_right(bear.breakBox, n)
                bear.volSum += nz(volume)
                if close < bear.bot
                    float scN = f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, n - bear.lastBar, volBase, atrRaw)
                    bear.finalize(bear.breakBox, f_vis(scN), -1, scN)
                    bear.phase := 0
                else if low <= bear.top and close > bear.top and bear.canMark()
                    bear.touches += 1
                    evTouch      := true
                    bear.wickSum += math.max(bear.top - low, 0)
                    bear.wickN   += 1
                    bear.lastBar := n
                    if f_vis(f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, 0, volBase, atrRaw))
                        bear.mark(supCol, true, "△")

    if bear.phase == 1 or bear.phase == 2
        scR  = f_score(bear.touches, bear.volSum, bear.wickSum, bear.wickN, n - bear.bornBar, n - bear.lastBar, volBase, atrRaw)
        bear.score := scR
        visR = f_vis(scR)
        bear.setVis(visR, fillB, bordB, fillA, bordA)
        boxR = bear.phase == 2 ? bear.breakBox : bear.setupBox
        bear.refreshTag("▼ Retest Zone", scR, bear.phase == 1 ? resCol : supCol, box.get_right(boxR), visR)

// ═══════════════════════════════════════════════════════════════════════════
//                               ALERTS  (native TradingView)
// ═══════════════════════════════════════════════════════════════════════════
bool nearBull       = false
bool nearBear       = false
bool nearStrongBull = false
bool nearStrongBear = false
float prox = close * alertProx / 100.0

// live structures
if bull.phase > 0 and f_vis(bull.score) and math.abs(close - bull.mid) <= prox
    nearBull := true
    if bull.score >= instThr
        nearStrongBull := true
if bear.phase > 0 and f_vis(bear.score) and math.abs(close - bear.mid) <= prox
    nearBear := true
    if bear.score >= instThr
        nearStrongBear := true

// archived (frozen) zones
if array.size(hist) > 0
    for r in hist
        if math.abs(close - r.price) <= prox
            if r.dir == 1
                nearBull := true
                if r.sc >= instThr
                    nearStrongBull := true
            else
                nearBear := true
                if r.sc >= instThr
                    nearStrongBear := true

alertcondition(nearBull,       "Bullish Zone Proximity",        "Price approaching a bullish retest zone.")
alertcondition(nearBear,       "Bearish Zone Proximity",        "Price approaching a bearish retest zone.")
alertcondition(nearStrongBull, "STRONG Bullish Zone Proximity", "Price approaching a strong bullish retest zone.")
alertcondition(nearStrongBear, "STRONG Bearish Zone Proximity", "Price approaching a strong bearish retest zone.")
alertcondition(evTouch,        "Zone Touch / Retest",           "Price tested a retest zone.")
alertcondition(evBreak,        "Zone Break",                    "A retest zone was broken and flipped tone.")
````
