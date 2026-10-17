# AMD

- url: https://www.tradingview.com/script/BFH87fmb/
- type: indicator
- pine_id: PUB;65b45090f85248b79abc82c5fedc5a4d
- version: 1.0

## Description

Highlight zone d'accumulation, manipulation et distribution avec FVG

## Source Code

````pine
//@version=6
indicator("SMC â€” Accumulation Â· Manipulation Â· FVG", overlay=true,
          max_boxes_count=300, max_labels_count=300, max_lines_count=100)

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  INPUTS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

// â”€â”€ Accumulation
g_a    = "ðŸ”µ  ACCUMULATION"
show_a = input.bool(true,  "Afficher",                 group=g_a)
a_len  = input.int(15,     "Nb bougies consolidation", group=g_a, minval=5, maxval=100)
a_pct  = input.float(0.6,  "Seuil range (%)",          group=g_a, minval=0.1, step=0.05)
a_col  = input.color(color.new(#2962FF, 78), "Couleur zone",    group=g_a)
a_bord = input.color(color.new(#2962FF, 10), "Couleur bordure", group=g_a)

// â”€â”€ Manipulation
g_m    = "ðŸŸ   MANIPULATION (Liquidity Sweep)"
show_m = input.bool(true, "Afficher",        group=g_m)
m_sw   = input.int(5,     "Swing lookback",  group=g_m, minval=2, maxval=20)
m_col  = input.color(color.new(#FF6D00, 72), "Couleur zone",    group=g_m)
m_bord = input.color(#FF6D00,                "Couleur bordure", group=g_m)

// â”€â”€ FVG
g_f      = "ðŸŸ¢ðŸ”´  FAIR VALUE GAP"
show_f   = input.bool(true, "Afficher",           group=g_f)
f_bull_c = input.color(color.new(#00C853, 72), "FVG Haussier",       group=g_f)
f_bear_c = input.color(color.new(#D50000, 72), "FVG Baissier",       group=g_f)
f_ext    = input.int(50,    "Extension (bougies)", group=g_f, minval=1, maxval=500)
f_mit    = input.bool(true, "Effacer si mitigÃ©",  group=g_f)

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  1. ACCUMULATION  (zone de consolidation)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Logique : si le range sur acc_len bougies est infÃ©rieur au seuil
//  en % et qu'il ne l'Ã©tait pas Ã  la bougie prÃ©cÃ©dente â†’ dÃ©but de
//  consolidation â†’ on dessine la boÃ®te.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

if show_a and bar_index >= a_len
    h      = ta.highest(high, a_len)
    l      = ta.lowest(low, a_len)
    h_prev = ta.highest(high, a_len)[1]
    l_prev = ta.lowest (low,  a_len)[1]

    rng      = (h - l) / l * 100
    rng_prev = (h_prev - l_prev) / l_prev * 100

    if rng <= a_pct and rng_prev > a_pct
        box.new(bar_index - a_len + 1, h, bar_index, l,
                 bgcolor      = a_col,
                 border_color = a_bord,
                 border_style = line.style_dashed,
                 border_width = 1)
        label.new(bar_index - a_len + 1, h,
                   "ACCUMULATION",
                   style     = label.style_label_right,
                   color     = color.new(#2962FF, 10),
                   textcolor = color.white,
                   size      = size.small)

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  2. MANIPULATION  (Liquidity Sweep / Stop Hunt)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Logique : le prix dÃ©passe un pivot swing en mÃ¨che, mais clÃ´ture
//  de l'autre cÃ´tÃ© â†’ manipulation de liquiditÃ©.
//
//  Bearish : mÃ¨che au-dessus du pivot high  + clÃ´ture en dessous
//  Bullish  : mÃ¨che en dessous du pivot low + clÃ´ture au-dessus
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

if show_m
    ph = ta.pivothigh(high, m_sw, m_sw)
    pl = ta.pivotlow(low, m_sw, m_sw)

    // Pivot confirmÃ© Ã  bar_index - m_sw
    // Bougie du sweep = m_sw - 1 offsets depuis maintenant
    if not na(ph)
        sweep_hi = high[m_sw - 1]
        sweep_cl = close[m_sw - 1]
        if sweep_hi > ph and sweep_cl < ph
            sb = bar_index - m_sw + 1
            box.new(sb - 1, sweep_hi, sb + 2, ph,
                     bgcolor      = m_col,
                     border_color = m_bord,
                     border_width = 2)
            label.new(sb, sweep_hi,
                       "âš¡ MANIPULATION BAISSIÃˆRE",
                       style     = label.style_label_down,
                       color     = #FF6D00,
                       textcolor = color.white,
                       size      = size.small)

    if not na(pl)
        sweep_lo = low[m_sw - 1]
        sweep_cl = close[m_sw - 1]
        if sweep_lo < pl and sweep_cl > pl
            sb = bar_index - m_sw + 1
            box.new(sb - 1, pl, sb + 2, sweep_lo,
                     bgcolor      = m_col,
                     border_color = m_bord,
                     border_width = 2)
            label.new(sb, sweep_lo,
                       "âš¡ MANIPULATION HAUSSIÃˆRE",
                       style     = label.style_label_up,
                       color     = #FF6D00,
                       textcolor = color.white,
                       size      = size.small)

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  3. FAIR VALUE GAP  (DÃ©sÃ©quilibre / Imbalance)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  Pattern 3 bougies :
//   FVG Haussier : low[0]  > high[2]  â†’ gap entre high[2] et low[0]
//   FVG Baissier : high[0] < low[2]   â†’ gap entre high[0] et low[2]
//
//  Zone colorÃ©e + label bien visible + extension horizontale.
//  Si "Effacer si mitigÃ©" = true, la boÃ®te disparaÃ®t quand le prix
//  rentre dans le gap.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

var box[]   fvg_bx   = array.new_box()
var bool[]  fvg_bull = array.new_bool()
var float[] fvg_t    = array.new_float()
var float[] fvg_b    = array.new_float()

if show_f and bar_index >= 2 and barstate.isconfirmed

    // â”€â”€ FVG HAUSSIER
    if low > high[2]
        top_ = low
        bot_ = high[2]
        mid_ = math.avg(top_, bot_)
        bx   = box.new(bar_index - 2, top_, bar_index + f_ext, bot_,
                        bgcolor      = f_bull_c,
                        border_color = color.new(#00C853, 0),
                        border_width = 1)
        label.new(bar_index - 1, mid_,
                   "â—†  FVG  â–²  HAUSSIER",
                   style     = label.style_label_right,
                   color     = #00C853,
                   textcolor = color.white,
                   size      = size.normal)
        array.push(fvg_bx,   bx)
        array.push(fvg_bull, true)
        array.push(fvg_t,    top_)
        array.push(fvg_b,    bot_)

    // â”€â”€ FVG BAISSIER
    if high < low[2]
        top_ = low[2]
        bot_ = high
        mid_ = math.avg(top_, bot_)
        bx   = box.new(bar_index - 2, top_, bar_index + f_ext, bot_,
                        bgcolor      = f_bear_c,
                        border_color = color.new(#D50000, 0),
                        border_width = 1)
        label.new(bar_index - 1, mid_,
                   "â—†  FVG  â–¼  BAISSIER",
                   style     = label.style_label_right,
                   color     = #D50000,
                   textcolor = color.white,
                   size      = size.normal)
        array.push(fvg_bx,   bx)
        array.push(fvg_bull, false)
        array.push(fvg_t,    top_)
        array.push(fvg_b,    bot_)

// â”€â”€ Mitigation : supprime le FVG quand le prix rentre dans la zone
if f_mit and array.size(fvg_bx) > 0
    i = array.size(fvg_bx) - 1
    while i >= 0
        bx_  = array.get(fvg_bx,   i)
        bull = array.get(fvg_bull,  i)
        t_   = array.get(fvg_t,    i)
        b_   = array.get(fvg_b,    i)
        // Haussier : prix redescend dans le gap (low entre bot et top)
        // Baissier : prix remonte dans le gap (high entre bot et top)
        mitigated = bull ? (low <= t_ and low >= b_) : (high >= b_ and high <= t_)
        if mitigated
            box.delete(bx_)
            array.remove(fvg_bx,   i)
            array.remove(fvg_bull,  i)
            array.remove(fvg_t,    i)
            array.remove(fvg_b,    i)
        i -= 1
````
