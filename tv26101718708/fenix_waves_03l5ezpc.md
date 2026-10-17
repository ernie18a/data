# FENIX Waves

- url: https://www.tradingview.com/script/03L5EzPC/
- type: indicator
- pine_id: PUB;3acea78323bc4e39b976fdfaedda3dd8
- version: 7.0

## Description

# FENIX Waves · pacote de publicação (TV House Rules)

Script: FENIX Waves (EN, self-contained) · fonte local: fenix_waves.pine
Status: injetado + compilado + salvo no editor (slot novo aberto pelo user 29/05).

## Passos manuais no TV (user faz · eu não consigo publicar)
1. Renomear o script SALVO pra "FENIX Waves" (o título on-chart já é FENIX Waves via indicator(); o nome do script salvo pode ter ficado "Meu script").
2. Add to chart → deixar SÓ o FENIX Waves visível (esconder Buy Sell, EMA, RSI, etc) → gráfico LIMPO (House Rule #4).
3. Publicar → colar o título e a descrição abaixo (inglês primeiro).
4. Marcar como Open-source (recomendado · descrição é o que o usuário lê).

## Título da publicação (EN only)
FENIX Waves — Elliott A-B-C visualizer with colored HMA line + projection

## Descrição (EN · colar)
FENIX Waves turns a discretionary Elliott Wave count into a clean, always-on chart overlay.

What it does
- Paints a smooth Hull Moving Average (HMA) line that follows price and RE-COLORS per wave: Wave A (down) red, Wave B (up) green, and the sub-waves of Wave C in amber (down legs) / cyan (up legs), so the active wave is obvious at a glance.
- Labels every turning point. When a macro turn and a sub-wave turn fall on the same candle, the labels MERGE into one (e.g. "C-i") instead of overlapping.
- Draws a dashed PROJECTION of the path you expect next (wave-2 target → wave-3 bottom → extension). The projection is measured in candles via bar_index, so it stays consistent on every timeframe. A "Nearest target only" switch hides the deep legs so the price scale stays tight.

How it works
- You mark the pivots by date in the settings: the macro A/B/C turns (top, bottom of A, top of B) and, as the count develops, the ends of sub-waves i…iv of C. The script segments the HMA by those timestamps and colors/labels each segment accordingly. Label distance from price auto-scales with ATR.
- Nothing is auto-detected: this is a VISUALIZATION engine for YOUR count, not a wave-finder. That keeps it honest — it shows exactly the structure you mapped.

How to use
1. Add to chart. The defaults show a sample BTC A-B-C count.
2. Open settings → Macro: set Wave A start, A→B (bottom of A), B→C (top of B) to your own pivots (by date).
3. Sub-waves of C: set the end of each sub-wave as price confirms it (leave far-future to disable).
4. Projection: set the price targets and how many candles ahead each leg should reach.

What makes it original
- Not a mashup and not another auto-ZigZag. It is a manual Elliott mapping tool: a single colored line that encodes the whole A-B-C + sub-wave count, with coincident-label merging and a timeframe-consistent forward projection — a compact way to keep a discretionary wave thesis visible and unambiguous across timeframes.

Notes
- Works on any symbol/timeframe. Best read on the timeframe where you defined the pivots.
- Open-source — read the code to see exactly how segmentation and projection are computed.

## Checklist House Rules (do TV_PUBLISH_REGRAS.md)
- [x] Título em inglês
- [x] UI/inputs/labels em inglês (self-contained)
- [x] Descrição EN detalhada · método + como usar + originalidade
- [x] Não é mashup · motor de visualização próprio
- [ ] Gráfico LIMPO na publicação (esconder outros estudos) · passo manual
- [x] Desenhos explicados (linha colorida, labels A/B/i.., projeção tracejada)

## Source Code

````pine
//@version=6
// OverViewBTC · Elliott wave map of BTC (public snapshot). Values embedded from the counting engine.
// rev 6 · 2026-08-08 · Renamed to OverViewBTC. Count refreshed: C-3 is the live working wave since
//   the C-2 top locked at 67.276. Trade content REMOVED (entry zone and stop line are gone) — this
//   indicator maps structure and levels only, it does not suggest positions.
indicator("OverViewBTC", overlay=true, max_lines_count=300, max_labels_count=300, max_boxes_count=80)

// ---- macro ABC (zigzag down) ----
a_start_p = 126150.0
a_start_t = 1759708800
a_end_p   = 59888.0
a_end_t   = 1770336000
b_end_p   = 82811.0
b_end_t   = 1778025600
// ---- wave C sub-structure ----
c1_end_p  = 59081.4          // C-1 low (down impulse, locked)
c1_end_t  = 1780675200
c2_end_p  = 67276.0          // C-2 top (up correction, locked) = C-3 start
c2_end_t  = 1781524800
mark_p    = 65048.1          // last counted price (snapshot 2026-08-08)
mark_t    = 1786202554
// ---- C-3 projection = Fibonacci extension of C-1 (82.8k->59.1k, mag 23730) from the C-2 top ----
// C-1 is extended, so by Elliott alternation C-3 tends NOT to extend -> primary target = 0.618xC-1.
c3_tgt_618 = 52611.0         // primary C-3 target (0.618 x C-1)
c3_tgt_100 = 43546.0         // stretch (1.0 x C-1)
c3_min     = 59081.4         // minimum: C-3 must break the C-1 low to qualify as wave 3
// ---- whole wave C targets (fraction of wave A) ----
tgt_382 = 57498.9
tgt_500 = 49680.0            // 0.5xA magnet (likely end of the whole correction)
tgt_618 = 41861.1
// ---- thresholds ----
inval   = 82811.0            // close above = bearish ABC invalidated
deelect = 66937.7            // close above = re-opens the C-2 leg (cancels the C-3-down read)

ms(tsec) => int(tsec) * 1000

var line[]  LNS = array.new_line()
var label[] LBS = array.new_label()
var box[]   BXS = array.new_box()
var table PANEL = table.new(position.top_right, 1, 6, bgcolor=color.new(color.black,15), border_width=1, border_color=color.new(color.gray,60))

cUp = color.new(color.teal, 0)
cDn = color.new(color.red, 0)

clearAll() =>
    for ln in LNS
        line.delete(ln)
    array.clear(LNS)
    for lb in LBS
        label.delete(lb)
    array.clear(LBS)
    for bx in BXS
        box.delete(bx)
    array.clear(BXS)

drawPath(int[] ts, float[] ps, string[] ls) =>
    prevT = 0
    prevP = 0.0
    for i = 0 to array.size(ts) - 1
        t = array.get(ts, i)
        p = array.get(ps, i)
        l = array.get(ls, i)
        if t > 0 and p > 0
            if prevT > 0
                col = p < prevP ? cDn : cUp
                array.push(LNS, line.new(prevT, prevP, t, p, xloc=xloc.bar_time, color=col, width=2))
            if l != ""
                segCol = prevT > 0 ? (p < prevP ? cDn : cUp) : color.gray
                lblT = prevT > 0 ? int((prevT + t) / 2) : t
                lblP = prevT > 0 ? (prevP + p) / 2 : p
                array.push(LBS, label.new(lblT, lblP, l, xloc=xloc.bar_time, color=color.new(segCol, 20), textcolor=color.white, style=label.style_label_center, size=size.large))
            prevT := t
            prevP := p

tagRight(x, y, txt, col) =>
    array.push(LBS, label.new(x, y, txt, xloc=xloc.bar_time, color=color.new(col,30), textcolor=color.white, style=label.style_label_left, size=size.small))

drawLevel(px, lab, lcol, sty, leftA, rightT) =>
    if px > 0
        array.push(LNS, line.new(leftA, px, rightT, px, xloc=xloc.bar_time, color=lcol, style=sty, width=1))
        if lab != ""
            tagRight(rightT, px, lab, lcol)

// projection line · orange dashed, from price to the target, label at the far end
drawProj(t0, p0, p1, endT, lab) =>
    if t0 > 0 and p0 > 0 and p1 > 0
        array.push(LNS, line.new(t0, p0, endT, p1, xloc=xloc.bar_time, color=color.new(color.orange,10), style=line.style_dashed, width=2))
        if lab != ""
            tagRight(endT, p1, lab, color.orange)

kfmt(p) => str.tostring(p / 1000.0, "#.#") + "k"

if barstate.islast
    clearAll()
    tf = timeframe.period
    isMacro = tf == "D" or tf == "1D" or tf == "W" or tf == "1W" or tf == "M" or tf == "1M"
    bardur = time - time[1]
    leftA  = time - bardur * 12
    rightT = time + bardur * 8

    ts = array.new_int()
    ps = array.new_float()
    ls = array.new_string()
    if isMacro
        array.push(ts, ms(a_start_t))
        array.push(ps, a_start_p)
        array.push(ls, "")
        array.push(ts, ms(a_end_t))
        array.push(ps, a_end_p)
        array.push(ls, "A")
        array.push(ts, ms(b_end_t))
        array.push(ps, b_end_p)
        array.push(ls, "B")
        array.push(ts, ms(mark_t))
        array.push(ps, mark_p)
        array.push(ls, "C  ·  OverViewBTC")
    else
        array.push(ts, ms(b_end_t))
        array.push(ps, b_end_p)
        array.push(ls, "")
        array.push(ts, ms(c1_end_t))
        array.push(ps, c1_end_p)
        array.push(ls, "C-1")
        array.push(ts, ms(c2_end_t))
        array.push(ps, c2_end_p)
        array.push(ls, "C-2")
        array.push(ts, ms(mark_t))
        array.push(ps, mark_p)
        array.push(ls, "C-3  ·  OverViewBTC")
    drawPath(ts, ps, ls)

    // key thresholds + targets
    drawLevel(inval,   "INVALIDATION close > " + kfmt(inval),         color.new(color.red,0),   line.style_dashed, leftA, rightT)
    drawLevel(deelect, "C-3 reset " + kfmt(deelect) + " (close above cancels the down read)", color.new(color.red,45), line.style_dotted, leftA, rightT)
    drawLevel(c3_min,  "C-3 MIN " + kfmt(c3_min) + " (must break C-1)", color.new(color.teal,10), line.style_dotted, leftA, rightT)
    drawLevel(tgt_500, "Wave C magnet " + kfmt(tgt_500) + " (0.5xA)",   color.new(color.teal,0),  line.style_dotted, leftA, rightT)

    // projection: macro -> whole-C magnet · intra -> C-3 Fib target
    if isMacro
        drawProj(ms(mark_t), mark_p, tgt_500,    rightT, "Wave C target " + kfmt(tgt_500) + " (0.5xA magnet)")
    else
        drawProj(ms(mark_t), mark_p, c3_tgt_618, rightT, "C-3 target " + kfmt(c3_tgt_618) + " (0.618xC-1) · stretch " + kfmt(c3_tgt_100))

    l0 = "OverViewBTC · Elliott wave map · ABC zigzag DOWN"
    l1 = "A " + kfmt(a_start_p) + "->" + kfmt(a_end_p) + " · B ->" + kfmt(b_end_p) + " · C impulse down (live)"
    l2 = "C-1 ->" + kfmt(c1_end_p) + " done · C-2 ->" + kfmt(c2_end_p) + " done · C-3 LIVE down"
    l3 = "C-3 target " + kfmt(c3_tgt_618) + " (0.618xC-1) · stretch " + kfmt(c3_tgt_100) + " · min " + kfmt(c3_min)
    l4 = "Wave C targets " + kfmt(tgt_382) + "/" + kfmt(tgt_500) + "/" + kfmt(tgt_618) + " · magnet " + kfmt(tgt_500)
    l5 = "Structure map · invalid close > " + kfmt(inval) + " · snapshot (updates on republish)"
    table.cell(PANEL, 0, 0, l0, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(PANEL, 0, 1, l1, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(PANEL, 0, 2, l2, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(PANEL, 0, 3, l3, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(PANEL, 0, 4, l4, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(PANEL, 0, 5, l5, text_color=color.white, text_size=size.normal, text_halign=text.align_left)
````
