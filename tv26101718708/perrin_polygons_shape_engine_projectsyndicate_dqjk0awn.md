# Perrin Polygons Shape Engine | ProjectSyndicate

- url: https://www.tradingview.com/script/dqjk0aWN-Perrin-Polygons-Shape-Engine-ProjectSyndicate/
- type: indicator
- pine_id: PUB;65117135d62f4a50811f4ed1ab0bcefd
- version: 1.0

## Description

Perrin Polygons — Shape Engine

Ten tabs of real dot-lattice mathematics, constructed live on your chart. Not a picture of figurate numbers — the actual construction, built dot by dot, every bar.

What it is

Most "Fibonacci" tools draw three lines and call it geometry. This one builds the geometry.

Perrin Polygons renders figurate numbers — the ancient dot-lattices that gave us triangular, square, pentagonal and hexagonal numbers — as living constructions on a chart canvas. Every dot is placed by the formula that defines it. Nothing is an image, nothing is hardcoded, nothing is traced.

The polygonal number

            (s-2)·n²  −  (s-4)·n
 P(s,n)  =  ──────────────────────────
                        2

is built here the way it is drawn, not the way it is written: as n nested gnomons. Gnomon k is the path W₁→W₂→…→W₍ₛ₋₁₎ of a regular s-gon of side k anchored at the origin, and it carries exactly (s-2)k + 1 dots. Stack k = 0 … n-1 and the total is P(s,n) — exactly, for every s and every n.

That construction is the engine. Everything else is what you can see once you have it.


The idea: why Perrin and polygons belong together

The Perrin sequence

 P(n) = P(n-2) + P(n-3),   P(0)=3, P(1)=0, P(2)=2
 →  3 · 0 · 2 · 3 · 2 · 5 · 5 · 7 · 10 · 12 · 17 · 22 · 29 · 39 · 51 · 68 …

is the plastic ratio's answer to Fibonacci — it grows by ρ = 1.3247179572, the real root of x³ = x + 1, where Fibonacci grows by φ = 1.618.

It looks like an unrelated curiosity. It isn't. It touches polygons twice, and both are shapes:

1 · The Perrin sequence is a list of polygons.
Read the terms as side counts: 3, 5, 7, 10, 12, 17, 22, 29 → triangle, pentagon, heptagon, decagon, dodecagon, 17-gon, 22-gon, 29-gon. The sequence doesn't describe polygons. It enumerates them.

2 · The Perrin numbers count polygons.
P(n) is exactly the number of maximal independent sets of the n-vertex cycle graph — and a cycle graph is a polygon. Choose vertices so no two are adjacent and no vertex is left uncovered; the number of ways is the nth Perrin number.

Tabs 02 and 05 draw those two facts. They are the reason this indicator exists.

The ten tabs

#TabWhat it draws01ATLASThe whole polygonal family. s = 3…8 across, n = 1…4 down. Every dot the same size, so the shapes grow with n — the sequence made visible.02PERRIN POLYGONSThe Perrin sequence as side counts: eight lattices from triangle to 29-gon.03GNOMONSOne shape, then the same shape taken apart ring by ring — (s-2)k+1 dots at a time.04CENTEREDCentered polygonal numbers: concentric rings of s·k dots around a single centre.05CYCLE GRAPHC(n) plus every one of its maximal independent sets, each drawn as a highlighted polygon. The count is brute-forced live and checked against P(n) on screen.06ROSETTEs = 12→3 nested, each radius divided by a power of ρ.07SPIRALSPlastic spiral (ρ per 120°) beside the golden spiral (φ per 90°) — why the plastic whirl is ~3× tighter.08RADAR ▸ liveThe market as a polygon: one vertex per Perrin-length RSI.09MARKET LATTICE ▸ liveThe last P(s,n) bars poured into a lattice — oldest at the centre, newest on the outer ring, coloured by direction.10IDENTITYA proof you can see: P(s+1,n) − P(s,n) = T(n-1). Three lattices, one shared pitch, counts checked live.

The formula panel

The dead chart space to the left of the shapes carries 30 formula cards — three per tab, switching with the tab.

Pine has no LaTeX. But its labels are monospace, so the panel renders genuine fraction bars instead of collapsing everything into (...)/2:

           √( 8(s-2)·x + (s-4)² )  +  (s-4)
  n   =   ──────────────────────────────────
                        2(s-2)

Every card carries live values substituted in, not just symbols — the identity and its evaluation at your current settings. Set the atlas to n=4 and the gnomon card reads rings: 1 + 7 + 13 + 19 = 40.

Font size is yours (up to huge). Nothing is locked small.

Why it's unique

It computes; it doesn't illustrate. The gnomon construction, the plastic ratio, the maximal independent sets, the inverse of P(s,n) — all evaluated on your chart, from first principles.

It checks itself in public. Tab 05 brute-forces every maximal independent set of C(n) across all 2ⁿ subsets, counts them, and prints the result against the Perrin number with a ✓ or ✗. It isn't asserting the theorem at you. It's demonstrating it, and it would show you if it failed.

Every claim was verified before it was drawn. The gnomon construction was checked against P(s,n) for s = 3…12, n = 1…6 (dot counts and totals). MIS(Cₙ) = P(n) was brute-forced for n = 2…13. The inverse formula was checked to be exact for s = 3…12, n = 3…8. None of it was transcribed on trust.

The lattice actually reads. Dots are drawn in canvas units as a fraction of the lattice pitch, not in fixed pixels — so a 40-dot octagon stays legible instead of collapsing into a blob. Comparison tabs share one pitch across every shape, which is what makes a figurate sequence look like a sequence rather than a row of unrelated blobs.

Colour carries information. Five perceptual ramps (Magma, Viridis, Plasma, Ember, Ice) run inner→outer, so ring colour encodes gnomon order rather than fighting it.

Practical applications

1 · A non-Fibonacci lookback family.
Everyone uses 8/13/21/34/55. The Perrin sequence gives 5, 7, 10, 12, 17, 22, 29, 39, 51, 68, 90, 119 — a different, slower-growing ladder (ρ = 1.325 vs φ = 1.618), so the periods are more tightly spaced and sample the middle horizons that Fibonacci skips.

2 · RADAR — read many horizons as one shape.
Instead of stacking eight RSI panes, read the polygon. A swollen shape means every horizon is extended the same way — broad-based pressure. A shrunken shape is the mirror. A lopsided shape — fast vertices pushed out, slow vertices pulled in — is short-term extension against a slower base, which is the geometry of a divergence. One glance replaces eight readings.

3 · MARKET LATTICE — regime texture at a glance.
The last P(s,n) bars, oldest at the centre. Directional runs appear as coloured arcs; chop appears as speckle. The up-fraction is printed underneath. It's a compact way to see whether recent history is trending or shuffling.

4 · Reference geometry for plastic-ratio work.
Exact constants and identities for anyone building ρ-based levels: ρ³ = ρ+1, and the exact "plastic pocket" 1/ρ² + 1/ρ³ = 1 (0.569840 + 0.430160), the plastic analogue of the golden pocket.

5 · Teaching and content.
Figurate numbers, gnomon growth, the plastic ratio, and a graph-theory identity, all on one canvas with the formulas beside them. For educators, students, and anyone publishing.

Settings that matter

◧ Shape aspect (x per y) — the one dial you must set.
Pine cannot read a pane's pixel size, so nothing can automate this. Set it to:

    aspect  =  (Canvas width / 100) × (pane height ÷ pane width)

Default 1.80 = a 440-bar canvas on a pane roughly 2.4× wider than tall. Shapes squashed flat → raise it. Stretched tall → lower it. They are only true polygons when this is right.

Everything else is optional: Lattice dot size (× pitch), five palettes, independent heading / caption / tab / formula text sizes, manual text colours, panel widths, and per-tab shape parameters.

On the tab strip: it is an index, not a button bar. Pine Script exposes no click, mouse or hover events — no TradingView indicator can have a working on-chart button. Tabs switch in Settings → Canvas → Tab.

What this is not

Stated plainly, because the space is full of tools that won't:

It generates no signals. No buy/sell arrows, no alerts, no strategy, no entries, no targets.
It reports no performance. No win rate, no profit factor, no backtest, no equity curve — because it makes no claims that would need them. Nothing here has been shown to have an edge, and nothing here pretends to.
The two live tabs are readouts, not forecasts. RADAR is RSI across Perrin lookbacks. MARKET LATTICE is bar direction. Neither predicts anything.
The plastic ratio is not magic. ρ is a real constant with real mathematics behind it. That it appears in a market tool does not mean markets obey it.


This is an instrument and a teaching engine. It shows you mathematics and it shows you your data. What you conclude is yours.

Pine Script® v6 · separate pane · no repainting · no external data.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//  PERRIN POLYGONS · Figurate Shape Engine
//
//  Draws real dot-lattice figurate numbers — not formulas about them.
//
//  NOTE ON THE TAB STRIP: it is an INDEX, not a button bar. Pine Script exposes
//  no click, mouse or hover events, so no drawing can ever be clickable. Tabs
//  are switched in Settings → Canvas → Tab.
//
//  Polygonal (s-gonal) numbers            P(s,n) = ((s-2)n² - (s-4)n) / 2
//  are built here the way they are drawn: as n nested GNOMONS. Gnomon k is the
//  path W1→W2→…→W(s-1) of a regular s-gon of side k anchored at the origin, and
//  carries exactly (s-2)k + 1 dots. Summing k = 0…n-1 gives P(s,n) exactly.
//
//  The Perrin sequence  P(n) = P(n-2) + P(n-3),  P(0)=3, P(1)=0, P(2)=2
//      3, 0, 2, 3, 2, 5, 5, 7, 10, 12, 17, 22, 29, 39, 51, 68 …
//  is itself a sequence of POLYGON SIDE COUNTS — triangle, pentagon, heptagon,
//  decagon, dodecagon, 17-gon … and it counts the maximal independent sets of
//  the n-vertex cycle graph, which is a polygon. Those two facts are the bridge
//  between the two ideas, and tabs 2 and 5 draw them.
//
//  Its characteristic equation x³ = x + 1 has real root ρ ≈ 1.3247179572, the
//  PLASTIC RATIO — the shape constant of tabs 6 and 7.
// ═══════════════════════════════════════════════════════════════════════════════
indicator("Perrin Polygons Shape Engine", overlay = false, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_polylines_count = 100, max_bars_back = 500)

RHO = 1.3247179572447454
PHI = 1.618033988749895

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
gT = "◧  Canvas"
tabSel  = input.string("01 · ATLAS", "Tab", options = ["01 · ATLAS", "02 · PERRIN POLYGONS", "03 · GNOMONS", "04 · CENTERED", "05 · CYCLE GRAPH", "06 · ROSETTE", "07 · SPIRALS", "08 · RADAR", "09 · MARKET LATTICE", "10 · IDENTITY"], group = gT, tooltip = "THIS is the tab switch. The strip drawn across the top of the pane is only an index — Pine Script has no click or mouse events, so nothing drawn on a chart can ever be a working button.")
theme   = input.string("Magma", "Palette", options = ["Magma", "Viridis", "Plasma", "Ember", "Ice (light)"], group = gT)
canvasW = input.int(440, "Canvas width (bars)", minval = 140, maxval = 480, group = gT, tooltip = "x is quantised to whole bars, so a wider canvas means finer dot placement. Keep this high unless the panel is cramped.")
aspect  = input.float(1.80, "Shape aspect (x per y)", minval = 0.15, maxval = 8.0, step = 0.05, group = gT, tooltip = "Pine cannot read the pane's pixel size, so this is the one manual dial. Set it to:  (Canvas width / 100) × (pane height ÷ pane width).  Default 1.80 = 440-bar canvas on a pane roughly 2.4× wider than tall. If shapes look squashed FLAT/WIDE, raise it. If stretched TALL/THIN, lower it. Shapes are only true polygons when this is right.")
dotFill = input.float(0.34, "Lattice dot size (× pitch)", minval = 0.10, maxval = 0.75, step = 0.02, group = gT, tooltip = "Lattice dots are drawn in CANVAS units as a fraction of the gap between neighbouring dots, so the structure stays readable at any shape size. 0.34 leaves two thirds of the gap as space. Raise for chunkier dots, lower to see fine lattices.")
dotSz   = input.string("tiny", "Node size (graph tabs)", options = ["tiny", "small", "normal"], group = gT, tooltip = "Only used by CYCLE / ROSETTE / SPIRAL / RADAR, which have few nodes and draw them as fixed-pixel circles.")
showEdge = input.bool(true, "Draw gnomon edges", group = gT)
showSpoke = input.bool(true, "Draw spines", group = gT)
showStrip = input.bool(true, "Show tab strip", group = gT)

gF = "∑  Formula panel"
formOn  = input.bool(true, "Show formula panel", group = gF, tooltip = "Renders the governing identities for the ACTIVE tab in the empty chart space to the left of the shapes, with live values substituted in. Needs canvasW + this width of bars on the chart, otherwise it is skipped and the shapes still draw.")
formW   = input.int(430, "Formula panel width (bars)", minval = 120, maxval = 900, group = gF)
szForm  = input.string("large",  "Formula size",  options = ["tiny", "small", "normal", "large", "huge"], group = gF)
szFormC = input.string("normal", "Formula caption size", options = ["tiny", "small", "normal", "large", "huge"], group = gF)

gX = "✎  Text"
szHead  = input.string("large",  "Heading size",    options = ["tiny", "small", "normal", "large", "huge"], group = gX)
szBody  = input.string("normal", "Caption size",    options = ["tiny", "small", "normal", "large", "huge"], group = gX)
szTab   = input.string("normal", "Tab strip size",  options = ["tiny", "small", "normal", "large", "huge"], group = gX)
autoTxt = input.bool(true, "Auto text colour (follows palette)", group = gX)
inkIn   = input.color(#FFFFFF, "Text colour", group = gX, tooltip = "Used when Auto is off. Auto picks near-white on the dark palettes and near-black on Ice (light).")
dimIn   = input.color(#C9C2E6, "Secondary text colour", group = gX)

gS = "◆  Shapes"
atlasN  = input.int(4, "Atlas stages (n)", minval = 2, maxval = 4, group = gS, tooltip = "Rows are s = 3…8, columns are n = 1…this. Every dot is a label and Pine caps those at 500: n=4 is 270 dots and 72 polylines, n=5 would be 510 dots and 108 polylines — over both caps, and Pine would silently drop the oldest objects. Capped at 4 for that reason. For bigger single shapes use the GNOMONS tab.")
perrinN = input.int(3, "Perrin-polygon stage (n)", minval = 2, maxval = 3, group = gS, tooltip = "n=3 draws 291 dots across the eight Perrin polygons. n=4 would need 566 — over Pine's 500-label cap.")
gnoS    = input.int(6, "Gnomon polygon sides (s)", minval = 3, maxval = 12, group = gS)
gnoN    = input.int(5, "Gnomon stages (n)", minval = 2, maxval = 7, group = gS)
cenN    = input.int(4, "Centered stages (n)", minval = 2, maxval = 5, group = gS)
cycN    = input.int(7, "Cycle graph vertices (n)", minval = 3, maxval = 12, group = gS, tooltip = "Brute-forces every maximal independent set of C(n) over all 2^n subsets. The count is the nth Perrin number.")
idS     = input.int(5, "Identity base sides (s)", minval = 3, maxval = 10, group = gS)
idN     = input.int(5, "Identity stage (n)", minval = 3, maxval = 6, group = gS)
mktS    = input.int(6, "Market lattice sides (s)", minval = 3, maxval = 12, group = gS)
mktN    = input.int(6, "Market lattice stages (n)", minval = 3, maxval = 8, group = gS)
radDepth = input.int(8, "Radar vertices (Perrin periods)", minval = 3, maxval = 12, group = gS)

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTE — the ring spectrum is the point of this indicator
// ─────────────────────────────────────────────────────────────────────────────
isMag = theme == "Magma"
isVir = theme == "Viridis"
isPla = theme == "Plasma"
isEmb = theme == "Ember"
isIce = theme == "Ice (light)"

colBg    = isMag ? #07050C : isVir ? #04100B : isPla ? #0A0416 : isEmb ? #120705 : #EFF4F9
colPanel = colBg
colFrame = isIce ? #BFD0E0 : #2B2440
colInk   = isIce ? #0D1620 : #F4F2FC
colTxt   = autoTxt ? (isIce ? #0B1118 : #F8F6FF) : inkIn
colTxt2  = autoTxt ? (isIce ? #46586E : #C4BCE2) : dimIn
colDim   = isIce ? #5D7389 : #9C93C4

// five-stop ramp, inner ring → outer ring. Dark themes run dark→bright so the
// outer gnomons (which carry the most dots) read loudest; the light theme runs
// light→dark for the same reason.
k0 = isMag ? #6A176E : isVir ? #440154 : isPla ? #6A00A8 : isEmb ? #6B1D00 : #B9D2E9
k1 = isMag ? #B63679 : isVir ? #3B528B : isPla ? #B12A90 : isEmb ? #A83B00 : #79A9D6
k2 = isMag ? #F1605D : isVir ? #21918C : isPla ? #E16462 : isEmb ? #E85D04 : #3D7EB8
k3 = isMag ? #FEAF77 : isVir ? #5EC962 : isPla ? #FCA636 : isEmb ? #FFA200 : #1B4E88
k4 = isMag ? #FCFDBF : isVir ? #FDE725 : isPla ? #F0F921 : isEmb ? #FFE66D : #082440

colUp = isIce ? #15803D : #34D399
colDn = isIce ? #B91C1C : #FB7185

mapSz(string v) => v == "tiny" ? size.tiny : v == "small" ? size.small : v == "normal" ? size.normal : v == "large" ? size.large : size.huge
zHead = mapSz(szHead)
zBody = mapSz(szBody)
zTab  = mapSz(szTab)
zForm = mapSz(szForm)
zFrmC = mapSz(szFormC)

ramp5(float t) =>
    float u = math.max(0.0, math.min(1.0, t)) * 4.0
    int i = math.min(3, int(u))
    color a = i == 0 ? k0 : i == 1 ? k1 : i == 2 ? k2 : k3
    color b = i == 0 ? k1 : i == 1 ? k2 : i == 2 ? k3 : k4
    color.from_gradient(u - i, 0.0, 1.0, a, b)

specCol(int i) => ramp5((i % 10) / 9.0)

// ring k of an n-stage shape, ordered inner → outer along the ramp
ringCol(int k, int n) => n <= 1 ? k4 : ramp5(k / float(n - 1))

dsz = dotSz == "tiny" ? size.tiny : dotSz == "small" ? size.small : size.normal

// ─────────────────────────────────────────────────────────────────────────────
//  FIGURATE GEOMETRY
// ─────────────────────────────────────────────────────────────────────────────
type Fig
    array<float> ux
    array<float> uy
    array<int>   rk

pgon(int s, int n) => ((s - 2) * n * n - (s - 4) * n) / 2
tri(int n) => n * (n + 1) / 2

// vertices of a regular s-gon of side L, W0 at the origin, first edge along +x
figVerts(int s, float L) =>
    array<float> vx = array.new<float>()
    array<float> vy = array.new<float>()
    float x = 0.0
    float y = 0.0
    for j = 0 to s - 1
        vx.push(x)
        vy.push(y)
        float h = j * 2.0 * math.pi / s
        x += L * math.cos(h)
        y += L * math.sin(h)
    [vx, vy]

// s-gonal number as n nested gnomons — ring k holds exactly (s-2)k + 1 dots
figurate(int s, int n) =>
    array<float> ux = array.new<float>()
    array<float> uy = array.new<float>()
    array<int>   rk = array.new<int>()
    for k = 0 to n - 1
        if k == 0
            ux.push(0.0)
            uy.push(0.0)
            rk.push(0)
        else
            [vx, vy] = figVerts(s, float(k))
            for e = 1 to s - 2
                float eax = vx.get(e)
                float eay = vy.get(e)
                float ebx = vx.get(e + 1)
                float eby = vy.get(e + 1)
                for t = 0 to k - 1
                    ux.push(eax + (ebx - eax) * t / k)
                    uy.push(eay + (eby - eay) * t / k)
                    rk.push(k)
            ux.push(vx.get(s - 1))
            uy.push(vy.get(s - 1))
            rk.push(k)
    Fig.new(ux, uy, rk)

// centered s-gonal number: concentric rings, ring k carries s·k dots
centeredFig(int s, int n) =>
    array<float> ux = array.new<float>()
    array<float> uy = array.new<float>()
    array<int>   rk = array.new<int>()
    ux.push(0.0)
    uy.push(0.0)
    rk.push(0)
    for k = 1 to n - 1
        for e = 0 to s - 1
            float a1 = math.pi * 0.5 + e * 2.0 * math.pi / s
            float a2 = math.pi * 0.5 + (e + 1) * 2.0 * math.pi / s
            float eax = k * math.cos(a1)
            float eay = k * math.sin(a1)
            float ebx = k * math.cos(a2)
            float eby = k * math.sin(a2)
            for t = 0 to k - 1
                ux.push(eax + (ebx - eax) * t / k)
                uy.push(eay + (eby - eay) * t / k)
                rk.push(k)
    Fig.new(ux, uy, rk)

// ─────────────────────────────────────────────────────────────────────────────
//  CANVAS
// ─────────────────────────────────────────────────────────────────────────────
var array<box>      BX = array.new<box>()
var array<label>    LB = array.new<label>()
var array<line>     LN = array.new<line>()
var array<polyline> PL = array.new<polyline>()

clearAll() =>
    if BX.size() > 0
        for i = 0 to BX.size() - 1
            box.delete(BX.get(i))
        BX.clear()
    if LB.size() > 0
        for i = 0 to LB.size() - 1
            label.delete(LB.get(i))
        LB.clear()
    if LN.size() > 0
        for i = 0 to LN.size() - 1
            line.delete(LN.get(i))
        LN.clear()
    if PL.size() > 0
        for i = 0 to PL.size() - 1
            polyline.delete(PL.get(i))
        PL.clear()

bxNew(int l, float t, int r, float b, color bg, color bd, int w) =>
    BX.push(box.new(l, t, r, b, xloc = xloc.bar_index, border_color = bd, border_width = w, bgcolor = bg))

txt(int x, float y, string s, color c, string align, string sz) =>
    LB.push(label.new(x, y, s, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = c, size = sz, textalign = align, text_font_family = font.family_monospace))

// fixed-pixel circle — only for the sparse graph tabs (few nodes, no lattice)
cdot(int x, float y, color c, string sz) =>
    LB.push(label.new(x, y, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_circle, color = c, size = sz))

// LATTICE DOT. label.style_circle is sized in PIXELS, so on a dense lattice the
// dots stay ~13px while the pitch shrinks and every shape turns into a blob.
// These are boxes measured in canvas units — half-extents hx (bars) and hy
// (y-units) derived from the lattice pitch — so dot size tracks the spacing and
// the structure survives at any scale.
sdot(int x, float y, float hx, float hy, color c) =>
    int l = int(x - hx)
    int r = int(x + hx)
    if r <= l
        r := l + 1
    BX.push(box.new(l, y + hy, r, y - hy, xloc = xloc.bar_index, border_color = color.new(c, 100), border_width = 0, bgcolor = c))

lnNew(int x1, float y1, int x2, float y2, color c, string st, int w) =>
    LN.push(line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = c, style = st, width = w))

arrMin(array<float> a) =>
    float m = na
    if a.size() > 0
        for i = 0 to a.size() - 1
            float v = a.get(i)
            if not na(v)
                m := na(m) ? v : math.min(m, v)
    m
arrMax(array<float> a) =>
    float m = na
    if a.size() > 0
        for i = 0 to a.size() - 1
            float v = a.get(i)
            if not na(v)
                m := na(m) ? v : math.max(m, v)
    m

// ── draw a figurate lattice centred in a cell (cw in bars, ch in y-units) ──
// largest pitch (y-units per lattice step) at which this shape still fits a cell
figFit(Fig f, float cw, float ch) =>
    float w = math.max(arrMax(f.ux) - arrMin(f.ux), 0.001)
    float h = math.max(arrMax(f.uy) - arrMin(f.uy), 0.001)
    f.ux.size() == 1 ? 1e9 : math.min(cw / (aspect * w), ch / h)

// Draw at a GIVEN pitch. Comparison tabs pass one pitch for every shape, so the
// dots are all the same size and the shapes grow with n — which is the whole
// point of a figurate sequence. Fitting each shape to its own cell instead made
// a 1-dot shape balloon to a cell-sized block.
drawFigAt(Fig f, int n, int cx, float cy, float sc, bool edges, bool spines, bool dots) =>
    int cnt = f.ux.size()
    float mnx = arrMin(f.ux)
    float mxx = arrMax(f.ux)
    float mny = arrMin(f.uy)
    float mxy = arrMax(f.uy)
    float ox = (mnx + mxx) * 0.5
    float oy = (mny + mxy) * 0.5
    // gnomon paths, one polyline per ring
    if edges and n > 1
        for k = 1 to n - 1
            array<chart.point> pts = array.new<chart.point>()
            for i = 0 to cnt - 1
                if f.rk.get(i) == k
                    pts.push(chart.point.from_index(int(cx + (f.ux.get(i) - ox) * sc * aspect), cy + (f.uy.get(i) - oy) * sc))
            if pts.size() > 1
                PL.push(polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(ringCol(k, n), 62), line_width = 1, line_style = line.style_solid))
    // the two spines running from the origin along the anchored edges
    if spines and n > 1
        array<chart.point> sa = array.new<chart.point>()
        array<chart.point> sb = array.new<chart.point>()
        sa.push(chart.point.from_index(int(cx + (0.0 - ox) * sc * aspect), cy + (0.0 - oy) * sc))
        sb.push(chart.point.from_index(int(cx + (0.0 - ox) * sc * aspect), cy + (0.0 - oy) * sc))
        for k = 1 to n - 1
            int fi = -1
            int la = -1
            for i = 0 to cnt - 1
                if f.rk.get(i) == k
                    if fi < 0
                        fi := i
                    la := i
            if fi >= 0
                sa.push(chart.point.from_index(int(cx + (f.ux.get(fi) - ox) * sc * aspect), cy + (f.uy.get(fi) - oy) * sc))
                sb.push(chart.point.from_index(int(cx + (f.ux.get(la) - ox) * sc * aspect), cy + (f.uy.get(la) - oy) * sc))
        if sa.size() > 1
            PL.push(polyline.new(sa, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(colDim, 70), line_width = 1, line_style = line.style_solid))
            PL.push(polyline.new(sb, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(colDim, 55), line_width = 1, line_style = line.style_solid))
    if dots
        // the figurate lattice has a pitch of exactly 1 shape-unit, so the dot
        // half-extent is simply sc · dotFill / 2 in y (× aspect in bars)
        float hy = sc * dotFill * 0.5
        float hx = hy * aspect
        for i = 0 to cnt - 1
            sdot(int(cx + (f.ux.get(i) - ox) * sc * aspect), cy + (f.uy.get(i) - oy) * sc, hx, hy, ringCol(f.rk.get(i), n))
    sc

// convenience: fit this one shape to its cell, then draw it
drawFig(Fig f, int n, int cx, float cy, float cw, float ch, bool edges, bool spines, bool dots) =>
    float sc = figFit(f, cw, ch)
    drawFigAt(f, n, cx, cy, sc == 1e9 ? math.min(cw / aspect, ch) * 0.5 : sc, edges, spines, dots)

// ── regular polygon outline as a closed polyline centred on (cx, cy) ──
ringPoly(int s, int cx, float cy, float r, float rot, color c, int w, color fill) =>
    array<chart.point> p = array.new<chart.point>()
    for j = 0 to s - 1
        float a = rot + j * 2.0 * math.pi / s
        p.push(chart.point.from_index(int(cx + r * math.cos(a) * aspect), cy + r * math.sin(a)))
    PL.push(polyline.new(p, curved = false, closed = true, xloc = xloc.bar_index, line_color = c, line_width = w, line_style = line.style_solid, fill_color = fill))


// ─────────────────────────────────────────────────────────────────────────────
//  PERRIN
// ─────────────────────────────────────────────────────────────────────────────
perrinFwd(int n) =>
    array<int> a = array.new<int>()
    a.push(3)
    a.push(0)
    a.push(2)
    if n > 2
        for i = 3 to n
            a.push(a.get(i - 2) + a.get(i - 3))
    a

bitAt(int m, int i) => int(m / math.pow(2, i)) % 2

// every maximal independent set of the cycle graph C(n), as bitmasks.
// |result| is the nth Perrin number — brute-forced, not asserted.
misSets(int n) =>
    array<int> res = array.new<int>()
    int lim = int(math.pow(2, n))
    for m = 1 to lim - 1
        bool indep = true
        for i = 0 to n - 1
            if bitAt(m, i) == 1 and bitAt(m, (i + 1) % n) == 1
                indep := false
                break
        if indep
            bool maximal = true
            for v = 0 to n - 1
                if bitAt(m, v) == 0 and bitAt(m, (v + n - 1) % n) == 0 and bitAt(m, (v + 1) % n) == 0
                    maximal := false
                    break
            if maximal
                res.push(m)
    res

// ─────────────────────────────────────────────────────────────────────────────
//  LIVE SERIES (tabs 08 / 09)
// ─────────────────────────────────────────────────────────────────────────────
q01 = ta.rsi(close, 5)
q02 = ta.rsi(close, 7)
q03 = ta.rsi(close, 10)
q04 = ta.rsi(close, 12)
q05 = ta.rsi(close, 17)
q06 = ta.rsi(close, 22)
q07 = ta.rsi(close, 29)
q08 = ta.rsi(close, 39)
q09 = ta.rsi(close, 51)
q10 = ta.rsi(close, 68)
q11 = ta.rsi(close, 90)
q12 = ta.rsi(close, 119)
rsiAt(int k) => k == 0 ? q01 : k == 1 ? q02 : k == 2 ? q03 : k == 3 ? q04 : k == 4 ? q05 : k == 5 ? q06 : k == 6 ? q07 : k == 7 ? q08 : k == 8 ? q09 : k == 9 ? q10 : k == 10 ? q11 : q12
perLen(int k) => k == 0 ? 5 : k == 1 ? 7 : k == 2 ? 10 : k == 3 ? 12 : k == 4 ? 17 : k == 5 ? 22 : k == 6 ? 29 : k == 7 ? 39 : k == 8 ? 51 : k == 9 ? 68 : k == 10 ? 90 : 119

// ─────────────────────────────────────────────────────────────────────────────
//  CANVAS GEOMETRY (global, so each tab can be a short top-level block)
// ─────────────────────────────────────────────────────────────────────────────
bool canDraw = barstate.islast and bar_index > canvasW + 5
int   x0 = bar_index - canvasW
int   x1 = bar_index
int   cxC = int((x0 + x1) / 2)
// formula panel occupies the dead chart space to the LEFT of the shape canvas
int   xF1 = x0 - 10
int   xF0 = xF1 - formW
int   cxF = int((xF0 + xF1) / 2)
bool  fDraw = barstate.islast and formOn and bar_index > canvasW + formW + 15

float top = showStrip ? 89.0 : 96.0
float bot = 6.0
int   wid = x1 - x0

// ── formula card ────────────────────────────────────────────────────────────
// Pine has no LaTeX. But the labels are monospace, so a multi-line string with
// a box-drawing rule lines up into a genuine fraction instead of collapsing to
// an inline "(...)/2".

fcard(int i, int n, string title, string body, string val, color acc) =>
    float H  = (top - bot) / n
    float yT = top - i * H - H * 0.04
    float yB = top - (i + 1) * H + H * 0.04
    float h  = yT - yB
    bxNew(xF0, yT, xF1, yB, color.new(colFrame, 86), color.new(colFrame, 30), 1)
    bxNew(xF0, yT, xF0 + int((xF1 - xF0) * 0.20), yT - h * 0.04, acc, color.new(acc, 100), 0)
    txt(cxF, yT - h * 0.13, title, colTxt2, text.align_center, zFrmC)
    txt(cxF, (yT + yB) * 0.5 - h * 0.03, body, colTxt, text.align_left, zForm)
    txt(cxF, yB + h * 0.12, val, acc, text.align_center, zFrmC)

if canDraw
    clearAll()
    bxNew(x0, 100.0, x1, 0.0, color.new(colBg, 8), color.new(colFrame, 40), 1)

if fDraw
    bxNew(xF0, 100.0, xF1, 0.0, color.new(colBg, 8), color.new(colFrame, 40), 1)
    txt(cxF, 95.0, str.replace_all(tabSel, "·", "—") + "   ·   governing identities", colTxt, text.align_center, zTab)
    if showStrip
        // ── INDEX, NOT BUTTONS ──────────────────────────────────────────────
        // Pine Script has no click / mouse / hover events of any kind, so this
        // strip cannot be clickable. It exists only to report which tab is live
        // and what the other nine are. Earlier it drew a bordered box around
        // every entry, which read as a row of buttons — that was a lie about
        // what it does. Now only the ACTIVE entry is filled and underlined; the
        // rest are plain text on a hairline, i.e. a legend. The switch lives in
        // Settings → Canvas → Tab, and the hint below says so.
        array<string> tabs = array.from("01 ATLAS", "02 PERRIN", "03 GNOMON", "04 CENTERED", "05 CYCLE", "06 ROSETTE", "07 SPIRAL", "08 RADAR", "09 MARKET", "10 IDENTITY")
        float tw = wid / 10.0
        lnNew(x0 + 2, 92.2, x1 - 2, 92.2, color.new(colFrame, 25), line.style_solid, 1)
        for i = 0 to 9
            string tag = i < 9 ? "0" + str.tostring(i + 1) : "10"
            bool act = str.startswith(tabSel, tag)
            int bl = int(x0 + i * tw + 2)
            int br = int(x0 + (i + 1) * tw - 2)
            if act
                bxNew(bl, 97.8, br, 92.2, color.new(specCol(i), 80), color.new(specCol(i), 100), 0)
                bxNew(bl, 93.0, br, 92.2, specCol(i), color.new(specCol(i), 100), 0)
            txt(int((bl + br) / 2), 95.0, tabs.get(i), act ? colTxt : colTxt2, text.align_center, zTab)
        txt(cxC, 99.0, "index only — Pine has no click events · switch tabs in  Settings ⚙ → Canvas → Tab", colTxt2, text.align_center, zTab)

// ═══════════════════════════════════ 01 · ATLAS ═════════════════════════════
// s = 3…8 down the rows, n = 1…atlasN across — the whole polygonal family
if canDraw and str.startswith(tabSel, "01")
    // s across the columns, n down the rows: the pane is ~2.4:1, and this way
    // round roughly doubles the lattice pitch.
    int nr = atlasN
    float colW = wid / 6.4
    float tot = 0.0
    for r = 0 to nr - 1
        tot += r + 1.0
    // row r is given height proportional to n = r+1, because at a shared pitch
    // the shapes genuinely grow with n and equal rows would waste the canvas
    array<float> rowY = array.new<float>()
    array<float> rowH = array.new<float>()
    float yc = top
    for r = 0 to nr - 1
        float hR = (top - bot) * (r + 1.0) / tot
        rowH.push(hR)
        rowY.push(yc - hR * 0.5)
        yc -= hR
    // ONE pitch, the tightest fit across every shape in the grid
    float pitch = 1e9
    for c = 0 to 5
        for r = 0 to nr - 1
            pitch := math.min(pitch, figFit(figurate(c + 3, r + 1), colW * 0.90, rowH.get(r) * 0.82))
    for c = 0 to 5
        int s = c + 3
        int cx = int(x0 + colW * (0.4 + c + 0.5))
        txt(cx, top + 1.6, "s = " + str.tostring(s), colTxt, text.align_center, zHead)
        for r = 0 to nr - 1
            int n = r + 1
            drawFigAt(figurate(s, n), n, cx, rowY.get(r), pitch, showEdge, showSpoke, true)
            txt(cx, rowY.get(r) - rowH.get(r) * 0.40, str.tostring(pgon(s, n)), colTxt, text.align_center, zBody)
    for r = 0 to nr - 1
        txt(int(x0 + colW * 0.17), rowY.get(r), "n=" + str.tostring(r + 1), colTxt2, text.align_center, zHead)
    txt(cxC, bot - 3.4, "P(s,n) = ((s-2)n² - (s-4)n)/2   ·   every dot is the same size, so the shapes grow with n   ·   each ring is one gnomon of (s-2)k+1 dots, coloured inner → outer   ·   figure under each shape is its dot count", colTxt2, text.align_center, zBody)

// ══════════════════════════ 02 · PERRIN POLYGONS ════════════════════════════
// the Perrin sequence read as SIDE COUNTS: 3, 5, 7, 10, 12, 17, 22, 29
if canDraw and str.startswith(tabSel, "02")
    array<int> sides = array.from(3, 5, 7, 10, 12, 17, 22, 29)
    array<int> idx   = array.from(3, 5, 7, 8, 9, 10, 11, 12)
    float colW = wid / 4.0
    float rowH = (top - bot) / 2.0
    float pitch = 1e9
    for i = 0 to 7
        pitch := math.min(pitch, figFit(figurate(sides.get(i), perrinN), colW * 0.72, rowH * 0.56))
    for i = 0 to 7
        int s = sides.get(i)
        int cx = int(x0 + colW * (i % 4 + 0.5))
        float cy = top - rowH * (int(i / 4) + 0.5)
        drawFigAt(figurate(s, perrinN), perrinN, cx, cy, pitch, showEdge, false, true)
        txt(cx, cy - rowH * 0.36, str.tostring(s) + "-gon   P(" + str.tostring(idx.get(i)) + ")=" + str.tostring(s), colTxt, text.align_center, zBody)
        txt(cx, cy - rowH * 0.44, str.tostring(pgon(s, perrinN)) + " dots", colTxt2, text.align_center, zBody)
    txt(cxC, bot - 2.5, "the Perrin sequence 3 · 0 · 2 · 3 · 2 · 5 · 5 · 7 · 10 · 12 · 17 · 22 · 29 IS a list of polygons   ·   stage n = " + str.tostring(perrinN), colTxt2, text.align_center, zBody)

// ═══════════════════════════════ 03 · GNOMONS ═══════════════════════════════
// one shape, then the same shape taken apart ring by ring
if canDraw and str.startswith(tabSel, "03")
    float bigW = wid * 0.42
    int cxL = int(x0 + wid * 0.23)
    float cyL = (top + bot) * 0.5
    Fig f = figurate(gnoS, gnoN)
    drawFig(f, gnoN, cxL, cyL, bigW * 0.86, (top - bot) * 0.72, showEdge, showSpoke, true)
    txt(cxL, top - 2.0, str.tostring(gnoS) + "-gonal number, stage " + str.tostring(gnoN) + "  =  " + str.tostring(pgon(gnoS, gnoN)) + " dots", colTxt, text.align_center, zBody)
    // exploded rings
    float cellW = wid * 0.52 / gnoN
    float cyR = (top + bot) * 0.5
    for k = 0 to gnoN - 1
        int cx = int(x0 + wid * 0.47 + cellW * (k + 0.5))
        Fig g = figurate(gnoS, k + 1)
        // isolate ring k by keeping only its dots
        array<float> ux = array.new<float>()
        array<float> uy = array.new<float>()
        array<int>   rr = array.new<int>()
        for i = 0 to g.ux.size() - 1
            if g.rk.get(i) == k
                ux.push(g.ux.get(i))
                uy.push(g.uy.get(i))
                rr.push(k)
        int cnt = ux.size()
        // draw the isolated gnomon in its own colour
        float mnx = arrMin(ux)
        float mxx = arrMax(ux)
        float mny = arrMin(uy)
        float mxy = arrMax(uy)
        float w = math.max(mxx - mnx, 0.001)
        float h = math.max(mxy - mny, 0.001)
        float sc = cnt == 1 ? math.min(cellW * 0.6 / aspect, (top - bot) * 0.18) : math.min(cellW * 0.62 / (aspect * w), (top - bot) * 0.30 / h)
        array<chart.point> pts = array.new<chart.point>()
        float hy = sc * dotFill * 0.5
        float hx = hy * aspect
        for i = 0 to cnt - 1
            int px = int(cx + (ux.get(i) - (mnx + mxx) * 0.5) * sc * aspect)
            float py = cyR + (uy.get(i) - (mny + mxy) * 0.5) * sc
            pts.push(chart.point.from_index(px, py))
            sdot(px, py, hx, hy, ringCol(k, gnoN))
        if pts.size() > 1 and showEdge
            PL.push(polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(ringCol(k, gnoN), 62), line_width = 1, line_style = line.style_solid))
        txt(cx, cyR - (top - bot) * 0.24, "k=" + str.tostring(k), colTxt2, text.align_center, zBody)
        txt(cx, cyR - (top - bot) * 0.30, "+" + str.tostring(cnt), colTxt, text.align_center, zBody)
    txt(int(x0 + wid * 0.73), top - 2.0, "the same shape, one gnomon at a time", colTxt, text.align_center, zBody)
    txt(int(x0 + wid * 0.73), bot - 2.5, "ring k adds (s-2)k + 1 dots   ·   " + str.tostring(gnoN) + " rings sum to " + str.tostring(pgon(gnoS, gnoN)), colTxt2, text.align_center, zBody)

// ══════════════════════════════ 04 · CENTERED ═══════════════════════════════
// centered s-gonal numbers: concentric rings of s·k dots around one centre
if canDraw and str.startswith(tabSel, "04")
    float colW = wid / 6.0
    float cy = (top + bot) * 0.5
    float pitch = 1e9
    for r = 0 to 5
        pitch := math.min(pitch, figFit(centeredFig(r + 3, cenN), colW * 0.78, (top - bot) * 0.58))
    for r = 0 to 5
        int s = r + 3
        int cx = int(x0 + colW * (r + 0.5))
        drawFigAt(centeredFig(s, cenN), cenN, cx, cy, pitch, showEdge, false, true)
        int cnt = s * cenN * (cenN - 1) / 2 + 1
        txt(cx, cy - (top - bot) * 0.36, "centered " + str.tostring(s) + "-gonal", colTxt, text.align_center, zBody)
        txt(cx, cy - (top - bot) * 0.42, str.tostring(cnt) + " dots", colTxt, text.align_center, zBody)
    txt(cxC, bot - 2.5, "C(s,n) = s·n(n-1)/2 + 1   ·   ring k carries s·k dots   ·   stage n = " + str.tostring(cenN), colTxt2, text.align_center, zBody)

// ════════════════════════════ 05 · CYCLE GRAPH ══════════════════════════════
// the polygon that counts Perrin: maximal independent sets of C(n)
if canDraw and str.startswith(tabSel, "05")
    array<int> sets = misSets(cycN)
    array<int> pf = perrinFwd(math.max(cycN, 3))
    int cnt = sets.size()
    // the graph itself, large on the left
    int cxL = int(x0 + wid * 0.17)
    float cyL = (top + bot) * 0.5 + 1.0
    float rL = (top - bot) * 0.30
    ringPoly(cycN, cxL, cyL, rL, math.pi * 0.5, color.new(colDim, 30), 1, na)
    for j = 0 to cycN - 1
        float a = math.pi * 0.5 + j * 2.0 * math.pi / cycN
        cdot(int(cxL + rL * math.cos(a) * aspect), cyL + rL * math.sin(a), colInk, size.small)
    txt(cxL, top - 2.0, "C(" + str.tostring(cycN) + ")", colTxt, text.align_center, zHead)
    txt(cxL, cyL - rL - 4.0, "maximal independent sets = " + str.tostring(cnt), colTxt, text.align_center, zBody)
    txt(cxL, cyL - rL - 7.5, "Perrin P(" + str.tostring(cycN) + ") = " + str.tostring(pf.get(cycN)) + (cnt == pf.get(cycN) ? "   ✓ match" : "   mismatch"), cnt == pf.get(cycN) ? colUp : colDn, text.align_center, zBody)
    // gallery of every set
    int shown = math.min(cnt, 24)
    int gc = 6
    int gr = int(math.ceil(shown / float(gc)))
    float gw = wid * 0.66 / gc
    float gh = (top - bot) / math.max(gr, 1)
    for i = 0 to shown - 1
        int m = sets.get(i)
        int cx = int(x0 + wid * 0.34 + gw * (i % gc + 0.5))
        float cy = top - gh * (int(i / gc) + 0.5)
        float rr = math.min(gw * 0.34 / aspect, gh * 0.30)
        ringPoly(cycN, cx, cy, rr, math.pi * 0.5, color.new(colDim, 55), 1, na)
        for j = 0 to cycN - 1
            float a = math.pi * 0.5 + j * 2.0 * math.pi / cycN
            bool on = bitAt(m, j) == 1
            cdot(int(cx + rr * math.cos(a) * aspect), cy + rr * math.sin(a), on ? specCol(i % 7) : color.new(colDim, 62), on ? size.small : size.tiny)
    txt(int(x0 + wid * 0.67), bot - 2.5, (cnt > shown ? "showing 24 of " + str.tostring(cnt) : "all " + str.tostring(cnt) + " sets") + "   ·   filled = in the set, no two adjacent, every vertex covered", colTxt2, text.align_center, zBody)

// ══════════════════════════════ 06 · ROSETTE ════════════════════════════════
// s = 3…12 nested, each radius scaled by the plastic ratio
if canDraw and str.startswith(tabSel, "06")
    float cy = (top + bot) * 0.5
    float rMax = (top - bot) * 0.42
    for i = 0 to 9
        int s = 12 - i
        float r = rMax / math.pow(RHO, i * 0.55)
        ringPoly(s, cxC, cy, r, math.pi * 0.5, color.new(specCol(i), 25), 2, color.new(specCol(i), 93))
        for j = 0 to s - 1
            float a = math.pi * 0.5 + j * 2.0 * math.pi / s
            cdot(int(cxC + r * math.cos(a) * aspect), cy + r * math.sin(a), specCol(i), size.tiny)
        txt(int(cxC + r * aspect * 1.02), cy + r * 0.02, str.tostring(s), colTxt, text.align_left, zBody)
    txt(cxC, top - 2.0, "polygon rosette · s = 12 → 3, each radius divided by ρ^0.55", colTxt, text.align_center, zBody)
    txt(cxC, bot - 2.5, "ρ = 1.3247179572  is the real root of x³ = x + 1 — the plastic ratio, the Perrin sequence's growth constant", colTxt2, text.align_center, zBody)

// ══════════════════════════════ 07 · SPIRALS ════════════════════════════════
// plastic vs golden logarithmic spirals
if canDraw and str.startswith(tabSel, "07")
    float cy = (top + bot) * 0.5
    int cxA = int(x0 + wid * 0.27)
    int cxB = int(x0 + wid * 0.73)
    float rBase = (top - bot) * 0.40
    // plastic: radius × ρ every third of a turn  →  ρ³ = 2.3247 per turn
    array<chart.point> pa = array.new<chart.point>()
    for i = 0 to 240
        float th = -i / 240.0 * 6.0 * math.pi
        float r = rBase * math.pow(RHO, 3.0 * th / (2.0 * math.pi))
        pa.push(chart.point.from_index(int(cxA + r * math.cos(th) * aspect), cy + r * math.sin(th)))
    PL.push(polyline.new(pa, curved = true, closed = false, xloc = xloc.bar_index, line_color = k4, line_width = 2, line_style = line.style_solid))
    // golden: radius × φ every quarter turn  →  φ⁴ = 6.854 per turn
    array<chart.point> pb = array.new<chart.point>()
    for i = 0 to 240
        float th = -i / 240.0 * 6.0 * math.pi
        float r = rBase * math.pow(PHI, 2.0 * th / math.pi)
        pb.push(chart.point.from_index(int(cxB + r * math.cos(th) * aspect), cy + r * math.sin(th)))
    PL.push(polyline.new(pb, curved = true, closed = false, xloc = xloc.bar_index, line_color = k2, line_width = 2, line_style = line.style_solid))
    // Padovan tick marks every third of a turn on the plastic spiral
    for i = 0 to 9
        float th = -i * 2.0 * math.pi / 3.0
        float r = rBase * math.pow(RHO, 3.0 * th / (2.0 * math.pi))
        if r > 0.15
            cdot(int(cxA + r * math.cos(th) * aspect), cy + r * math.sin(th), specCol(i % 7), size.tiny)
    for i = 0 to 5
        float th = -i * math.pi / 2.0
        float r = rBase * math.pow(PHI, 2.0 * th / math.pi)
        if r > 0.15
            cdot(int(cxB + r * math.cos(th) * aspect), cy + r * math.sin(th), specCol(i % 7), size.tiny)
    txt(cxA, top - 2.0, "PLASTIC   ρ per 120°", colTxt, text.align_center, zBody)
    txt(cxB, top - 2.0, "GOLDEN   φ per 90°", colTxt, text.align_center, zBody)
    txt(cxA, bot - 2.5, "ρ³ = 2.3247 per turn — a slow, tight whirl", colTxt2, text.align_center, zBody)
    txt(cxB, bot - 2.5, "φ⁴ = 6.8541 per turn — three times faster", colTxt2, text.align_center, zBody)

// ═══════════════════════════════ 08 · RADAR ═════════════════════════════════
// the market as a live polygon: one vertex per Perrin-length RSI
if canDraw and str.startswith(tabSel, "08")
    float cy = (top + bot) * 0.5
    float rMax = (top - bot) * 0.40
    int sv = radDepth
    // grid rings at RSI 30 / 50 / 70
    ringPoly(sv, cxC, cy, rMax, math.pi * 0.5, color.new(colFrame, 30), 1, na)
    ringPoly(sv, cxC, cy, rMax * 0.70, math.pi * 0.5, color.new(colDn, 65), 1, na)
    ringPoly(sv, cxC, cy, rMax * 0.50, math.pi * 0.5, color.new(colDim, 55), 1, na)
    ringPoly(sv, cxC, cy, rMax * 0.30, math.pi * 0.5, color.new(colUp, 65), 1, na)
    array<chart.point> shape = array.new<chart.point>()
    float avg = 0.0
    for j = 0 to sv - 1
        float v = rsiAt(j)
        float rv = na(v) ? 0.5 : math.max(0.04, math.min(1.0, v / 100.0))
        avg += na(v) ? 50.0 : v
        float a = math.pi * 0.5 + j * 2.0 * math.pi / sv
        int px = int(cxC + rMax * rv * math.cos(a) * aspect)
        float py = cy + rMax * rv * math.sin(a)
        shape.push(chart.point.from_index(px, py))
        cdot(px, py, specCol(j % 7), size.small)
        txt(int(cxC + rMax * 1.16 * math.cos(a) * aspect), cy + rMax * 1.16 * math.sin(a), str.tostring(perLen(j)), colTxt2, text.align_center, zBody)
    avg /= sv
    color sc = avg > 55.0 ? colUp : avg < 45.0 ? colDn : k4
    PL.push(polyline.new(shape, curved = false, closed = true, xloc = xloc.bar_index, line_color = sc, line_width = 2, line_style = line.style_solid, fill_color = color.new(sc, 82)))
    txt(cxC, top - 2.0, str.tostring(sv) + "-gon · RSI at Perrin lengths", colTxt, text.align_center, zBody)
    txt(cxC, bot - 2.5, "vertex labels are the Perrin periods · rings are RSI 30 / 50 / 70 · mean " + str.tostring(avg, "0.0") + "  →  " + (avg > 55.0 ? "swollen = pressure up" : avg < 45.0 ? "shrunken = pressure down" : "balanced"), colTxt2, text.align_center, zBody)

// ══════════════════════════ 09 · MARKET LATTICE ═════════════════════════════
// the last P(s,n) bars poured into a polygonal lattice, oldest at the centre
if canDraw and str.startswith(tabSel, "09")
    Fig f = figurate(mktS, mktN)
    int cnt = f.ux.size()
    int cx = int(x0 + wid * 0.42)
    float cy = (top + bot) * 0.5
    float mnx = arrMin(f.ux)
    float mxx = arrMax(f.ux)
    float mny = arrMin(f.uy)
    float mxy = arrMax(f.uy)
    float w = math.max(mxx - mnx, 0.001)
    float h = math.max(mxy - mny, 0.001)
    float sc = math.min(wid * 0.62 / (aspect * w), (top - bot) * 0.80 / h)
    float ox = (mnx + mxx) * 0.5
    float oy = (mny + mxy) * 0.5
    int up = 0
    for i = 0 to cnt - 1
        int b = cnt - 1 - i                       // dot 0 = oldest bar
        float c0 = close[b]
        float o0 = open[b]
        bool isUp = not na(c0) and not na(o0) and c0 >= o0
        if isUp
            up += 1
        sdot(int(cx + (f.ux.get(i) - ox) * sc * aspect), cy + (f.uy.get(i) - oy) * sc, sc * dotFill * 0.5 * aspect, sc * dotFill * 0.5, na(c0) ? color.new(colDim, 60) : (isUp ? colUp : colDn))
    if showEdge and mktN > 1
        for k = 1 to mktN - 1
            array<chart.point> pts = array.new<chart.point>()
            for i = 0 to cnt - 1
                if f.rk.get(i) == k
                    pts.push(chart.point.from_index(int(cx + (f.ux.get(i) - ox) * sc * aspect), cy + (f.uy.get(i) - oy) * sc))
            if pts.size() > 1
                PL.push(polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(colDim, 62), line_width = 1, line_style = line.style_solid))
    txt(cx, top - 2.0, syminfo.ticker + " · last " + str.tostring(cnt) + " bars as a " + str.tostring(mktS) + "-gonal number", colTxt, text.align_center, zBody)
    txt(cx, bot - 2.5, "centre = oldest, outer ring = newest · green up / red down · " + str.tostring(up) + " up of " + str.tostring(cnt) + "  (" + str.tostring(up / float(cnt) * 100.0, "0.0") + "%)", colTxt2, text.align_center, zBody)

// ══════════════════════════════ 10 · IDENTITY ═══════════════════════════════
// a shape proof: P(s+1,n) - P(s,n) = T(n-1)
if canDraw and str.startswith(tabSel, "10")
    float colW = wid / 3.0
    float cy = (top + bot) * 0.5
    int a = pgon(idS, idN)
    int b = pgon(idS + 1, idN)
    int t = tri(idN - 1)
    int cxA = int(x0 + colW * 0.5)
    int cxB = int(x0 + colW * 1.5)
    int cxT = int(x0 + colW * 2.5)
    Fig fa = figurate(idS, idN)
    Fig fb = figurate(idS + 1, idN)
    Fig ft = figurate(3, idN - 1)
    // one pitch across all three — you cannot compare dot counts at three scales
    float pitch = math.min(figFit(fa, colW * 0.66, (top - bot) * 0.58), math.min(figFit(fb, colW * 0.66, (top - bot) * 0.58), figFit(ft, colW * 0.52, (top - bot) * 0.44)))
    drawFigAt(fa, idN, cxA, cy, pitch, showEdge, showSpoke, true)
    drawFigAt(fb, idN, cxB, cy, pitch, showEdge, showSpoke, true)
    drawFigAt(ft, idN - 1, cxT, cy, pitch, showEdge, showSpoke, true)
    txt(cxA, top - 2.0, str.tostring(idS) + "-gonal, n=" + str.tostring(idN), colTxt, text.align_center, zBody)
    txt(cxB, top - 2.0, str.tostring(idS + 1) + "-gonal, n=" + str.tostring(idN), colTxt, text.align_center, zBody)
    txt(cxT, top - 2.0, "triangular, n=" + str.tostring(idN - 1), colTxt, text.align_center, zBody)
    txt(cxA, cy - (top - bot) * 0.36, str.tostring(a) + " dots", colTxt, text.align_center, zHead)
    txt(cxB, cy - (top - bot) * 0.36, str.tostring(b) + " dots", colTxt, text.align_center, zHead)
    txt(cxT, cy - (top - bot) * 0.30, str.tostring(t) + " dots", colTxt, text.align_center, zHead)
    txt(int(x0 + colW * 1.0), cy, "→", colTxt2, text.align_center, zHead)
    txt(int(x0 + colW * 2.0), cy, "−  =", colTxt2, text.align_center, zHead)
    txt(cxC, bot - 2.5, str.tostring(b) + " − " + str.tostring(a) + " = " + str.tostring(b - a) + "   and   T(" + str.tostring(idN - 1) + ") = " + str.tostring(t) + (b - a == t ? "   ✓  adding one side to a polygon always costs one triangular number" : ""), b - a == t ? colUp : colDn, text.align_center, zBody)


// ═══════════════════════ FORMULA PANEL · one block per tab ══════════════════
if fDraw and str.startswith(tabSel, "01")
    int vs = 8
    int vn = atlasN
    string gsum = ""
    for k = 0 to vn - 1
        gsum += (k > 0 ? " + " : "") + str.tostring(k == 0 ? 1 : (vs - 2) * k + 1)
    fcard(0, 3, "POLYGONAL NUMBER   P(s,n)", "            (s-2)·n²  −  (s-4)·n\n P(s,n)  =  ──────────────────────────\n                        2", str.tostring(vs) + "-gonal, n = " + str.tostring(vn) + "   →   P = " + str.tostring(pgon(vs, vn)) + " dots", k4)
    fcard(1, 3, "VIA TRIANGULAR NUMBERS", " P(s,n)  =  (s-2)·T(n-1)  +  n\n\n         =  (s-3)·T(n-1)  +  T(n)\n\n                  n·(n+1)\n T(n)    =  ──────────────\n                     2", "T(" + str.tostring(vn - 1) + ") = " + str.tostring(tri(vn - 1)) + "   →   " + str.tostring(vs - 2) + "·" + str.tostring(tri(vn - 1)) + " + " + str.tostring(vn) + "  =  " + str.tostring(pgon(vs, vn)), k2)
    fcard(2, 3, "GNOMON GROWTH", " P(s,n+1) − P(s,n)  =  (s-2)·n + 1\n\n ring k carries  (s-2)·k + 1  dots\n\n         n-1\n P(s,n) =  Σ   [ (s-2)·k + 1 ]\n         k=0", "s = " + str.tostring(vs) + "   rings:  " + gsum + "   =  " + str.tostring(pgon(vs, vn)), k3)

if fDraw and str.startswith(tabSel, "02")
    fcard(0, 3, "PERRIN RECURRENCE", " P(n)  =  P(n-2) + P(n-3)\n\n P(0)=3    P(1)=0    P(2)=2", "3 · 0 · 2 · 3 · 2 · 5 · 5 · 7 · 10 · 12 · 17 · 22 · 29", k4)
    fcard(1, 3, "PLASTIC RATIO   x³ = x + 1", "                  P(n+1)\n  lim       ──────────   =  ρ\n n→∞            P(n)\n\n ρ  =  1.32471795724474602596", "the Perrin analogue of φ — growth per step", k2)
    fcard(2, 3, "SIDE COUNTS  →  DOT COUNTS", " P(s,3)  =  3·s − 3\n\n s taken from the Perrin sequence:\n 3 · 5 · 7 · 10 · 12 · 17 · 22 · 29", "29-gon at n=" + str.tostring(perrinN) + "   →   " + str.tostring(pgon(29, perrinN)) + " dots", k3)

if fDraw and str.startswith(tabSel, "03")
    string gsum3 = ""
    for k = 0 to gnoN - 1
        gsum3 += (k > 0 ? " + " : "") + str.tostring(k == 0 ? 1 : (gnoS - 2) * k + 1)
    fcard(0, 3, "GNOMON GROWTH LAW", " P(s,n+1) − P(s,n)  =  (s-2)·n + 1", "s = " + str.tostring(gnoS) + "   →   each ring adds " + str.tostring(gnoS - 2) + "·k + 1", k4)
    fcard(1, 3, "THE RINGS SUM TO THE WHOLE", "           n-1\n P(s,n)  =   Σ   [ (s-2)·k + 1 ]\n           k=0\n\n           (s-2)·n·(n-1)\n        =  ─────────────────  +  n\n                  2", "rings:  " + gsum3 + "   =  " + str.tostring(pgon(gnoS, gnoN)), k2)
    fcard(2, 3, "POLYGONAL NUMBER", "            (s-2)·n²  −  (s-4)·n\n P(s,n)  =  ──────────────────────────\n                        2", "s = " + str.tostring(gnoS) + ", n = " + str.tostring(gnoN) + "   →   " + str.tostring(pgon(gnoS, gnoN)) + " dots", k3)

if fDraw and str.startswith(tabSel, "04")
    string cenList = ""
    for j = 3 to 8
        cenList += (j > 3 ? " · " : "") + str.tostring(j * cenN * (cenN - 1) / 2 + 1)
    fcard(0, 3, "CENTERED POLYGONAL NUMBER", "              s·n·(n-1)\n C(s,n)  =  ───────────────  +  1\n                   2", "n = " + str.tostring(cenN) + "   →   C(3..8) = " + cenList, k4)
    fcard(1, 3, "RING STRUCTURE", " ring k  carries  s·k  dots\n\n            n-1\n C(s,n) = 1 + Σ  s·k\n            k=1", "one centre + " + str.tostring(cenN - 1) + " concentric rings", k2)
    fcard(2, 3, "VS ORDINARY POLYGONAL", " C(s,n)  −  1   =   s·T(n-1)\n\n                  n·(n+1)\n T(n)    =  ──────────────\n                     2", "T(" + str.tostring(cenN - 1) + ") = " + str.tostring(tri(cenN - 1)) + "   →   s·" + str.tostring(tri(cenN - 1)) + " + 1", k3)

if fDraw and str.startswith(tabSel, "05")
    int misCnt = misSets(cycN).size()
    int perrinAt = perrinFwd(math.max(cycN, 3)).get(cycN)
    fcard(0, 3, "MAXIMAL INDEPENDENT SETS", " MIS( C(n) )   =   P(n)\n\n the n-vertex CYCLE GRAPH is a polygon,\n and its maximal independent sets are\n counted by the nth Perrin number", "C(" + str.tostring(cycN) + ")   →   " + str.tostring(misCnt) + " sets   ·   P(" + str.tostring(cycN) + ") = " + str.tostring(perrinAt) + (misCnt == perrinAt ? "   ✓" : "   ✗"), k4)
    fcard(1, 3, "PERRIN RECURRENCE", " P(n)  =  P(n-2) + P(n-3)\n\n P(0)=3    P(1)=0    P(2)=2", "brute-forced over all 2^" + str.tostring(cycN) + " = " + str.tostring(int(math.pow(2, cycN))) + " subsets", k2)
    fcard(2, 3, "LUCAS 1876", " n prime      ⇒      n | P(n)\n\n the converse is false — the smallest\n Perrin pseudoprime is 271441 = 521²", "a polygon that counts primes", k3)

if fDraw and str.startswith(tabSel, "06")
    fcard(0, 3, "PLASTIC RATIO", " ρ³  =  ρ + 1\n\n ρ  =  1.32471795724474602596\n\n the real root of  x³ − x − 1 = 0", "the Perrin sequence grows by ρ per step", k4)
    fcard(1, 3, "THE PLASTIC POCKET", "   1        1\n ──────  +  ──────   =   1\n  ρ²        ρ³\n\n 0.569840  +  0.430160   =   1", "exact — divide ρ³ = ρ + 1 through by ρ³", k2)
    fcard(2, 3, "ROSETTE RADIUS LAW", "                r₀\n r(i)   =   ───────────\n              ρ^(0.55·i)\n\n s  =  12, 11, 10, … , 3", "each polygon steps inward by a power of ρ", k3)

if fDraw and str.startswith(tabSel, "07")
    fcard(0, 3, "PLASTIC SPIRAL", " r(θ)  =  r₀ · ρ^( 3θ / 2π )\n\n radius × ρ  every  120°", "ρ³  =  2.32472  per full turn", k4)
    fcard(1, 3, "GOLDEN SPIRAL", " r(θ)  =  r₀ · φ^( 2θ / π )\n\n radius × φ  every  90°", "φ⁴  =  6.85410  per full turn", k2)
    fcard(2, 3, "WHY THE PLASTIC WHIRL IS TIGHTER", " ρ³   =  2.32472\n φ⁴   =  6.85410\n\n φ⁴ / ρ³   ≈   2.95", "the golden spiral opens ~3× faster per turn", k3)

if fDraw and str.startswith(tabSel, "08")
    float radAvg = 0.0
    for j = 0 to radDepth - 1
        radAvg += nz(rsiAt(j), 50.0)
    radAvg /= radDepth
    fcard(0, 3, "RADAR MAP", "               RSI( Pⱼ )\n rⱼ   =   ────────────\n                 100\n\n vertex j at angle  π/2 + 2πj/s", "s = " + str.tostring(radDepth) + " vertices   ·   mean RSI = " + str.tostring(radAvg, "0.0"), k4)
    fcard(1, 3, "PERRIN PERIODS", " Pⱼ ∈ { 5, 7, 10, 12, 17, 22,\n        29, 39, 51, 68, 90, 119 }\n\n every lookback is a Perrin number", "the sequence sets the timeframes", k2)
    fcard(2, 3, "REGULAR POLYGON AREA", "            1              2π\n A   =   ───── · s · r² · sin( ──── )\n            2               s\n\n a swollen shape = broad-based pressure", "area scales with r² — extremes dominate", k3)

if fDraw and str.startswith(tabSel, "09")
    float xb = pgon(mktS, mktN)
    float invN = (math.sqrt(8.0 * (mktS - 2) * xb + math.pow(mktS - 4, 2)) + (mktS - 4)) / (2.0 * (mktS - 2))
    fcard(0, 3, "HOW MANY BARS FIT?", "            (s-2)·n²  −  (s-4)·n\n P(s,n)  =  ──────────────────────────\n                        2", "s = " + str.tostring(mktS) + ", n = " + str.tostring(mktN) + "   →   " + str.tostring(pgon(mktS, mktN)) + " bars on screen", k4)
    fcard(1, 3, "THE INVERSE  —  SOLVE FOR n", "           √( 8(s-2)·x + (s-4)² )  +  (s-4)\n  n   =   ──────────────────────────────────\n                        2(s-2)", "x = " + str.tostring(pgon(mktS, mktN)) + " bars, s = " + str.tostring(mktS) + "   →   n = " + str.tostring(invN, "0.###"), k2)
    fcard(2, 3, "READING ORDER", " ring 0   =  oldest bar\n ring n-1 =  newest bars\n\n ring k carries  (s-2)·k + 1  bars", "green = close ≥ open   ·   red = close < open", k3)

if fDraw and str.startswith(tabSel, "10")
    fcard(0, 3, "ADD ONE SIDE", " P(s+1,n)  −  P(s,n)   =   T(n-1)\n\n                  n·(n-1)\n T(n-1)  =  ──────────────\n                     2", "" + str.tostring(idS + 1) + "-gonal − " + str.tostring(idS) + "-gonal  =  " + str.tostring(pgon(idS + 1, idN) - pgon(idS, idN)) + "   ·   T(" + str.tostring(idN - 1) + ") = " + str.tostring(tri(idN - 1)), k4)
    fcard(1, 3, "ADD k SIDES", " P(s+k,n)  −  P(s,n)   =   k·T(n-1)\n\n                          n·(n-1)\n                =   k · ──────────────\n                             2", "the cost of a side is always one triangle", k2)
    fcard(2, 3, "THE THREE SHAPES ON SCREEN", " P(s,n)      =  (s-2)·T(n-1) + n\n P(s+1,n)    =  (s-1)·T(n-1) + n\n ─────────────────────────────────\n difference  =        T(n-1)", "" + str.tostring(pgon(idS + 1, idN)) + " − " + str.tostring(pgon(idS, idN)) + " = " + str.tostring(pgon(idS + 1, idN) - pgon(idS, idN)) + "  =  T(" + str.tostring(idN - 1) + ")", k3)

// scale anchors — pin the pane to the 0…100 canvas
plot(0.0, "lo", color.new(color.gray, 100), display = display.pane, editable = false)
plot(100.0, "hi", color.new(color.gray, 100), display = display.pane, editable = false)
````
