# Vol Profile TotoMazter

- url: https://www.tradingview.com/script/wsDJSqy7/
- type: indicator
- pine_id: PUB;2986dd6903674e83b77e7771a94896ff
- version: 1.0

## Description

This indicator displays a Volume Profile anchored to the right side of the chart, decomposing volume into bullish (blue) and bearish (green) components at each price level.

HOW IT WORKS

For each of the last N candles (configurable from 1 to 50), the total volume is split into bullish and bearish fractions using a body/range proportional model:
- Bullish weight = 0.5 + (body/range) x 0.5 for bullish candles
- Bearish weight = 0.5 + (body/range) x 0.5 for bearish candles
- A doji (body = 0) gets 50/50 split. A marubozu gets 100/0.

ILU AMP

## Source Code

````pine
//@version=6
indicator("Vol Profile TotoMazter", overlay=true, max_boxes_count=500, max_lines_count=100)

// INPUTS
i_per  = input.int(10,  "Periodos",       minval=1,  maxval=50,  group="Perfil")
i_niv  = input.int(24,  "Niveles",        minval=8,  maxval=48,  group="Perfil")
i_anch = input.int(8,   "Ancho barras",   minval=2,  maxval=40,  group="Perfil")
i_off  = input.int(3,   "Offset derecha", minval=0,  maxval=20,  group="Perfil")
i_poc  = input.bool(true, "Mostrar POC",                               group="Perfil")
i_vsrc = input.string("Auto", "Fuente volumen",
         options=["Auto", "COMEX:GC1!", "OANDA:XAUUSD"],
         group="Perfil")
i_tbl  = input.bool(true, "Mostrar tabla",                             group="Tabla")
i_pos  = input.string("Bottom Right", "Posicion tabla",
         options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"],
         group="Tabla")
i_sz   = input.string("Small", "Tamano texto",
         options=["Tiny", "Small", "Normal"],
         group="Tabla")
i_cbul = input.color(color.new(#1565C0, 20), "Alcista",   group="Colores")
i_cber = input.color(color.new(#2E7D32, 20), "Bajista",   group="Colores")
i_cpoc = input.color(color.new(#FFD600,  0), "POC",        group="Colores")
i_chdr = input.color(color.new(#1e222d,  0), "Hdr tabla", group="Colores")
i_cbg  = input.color(color.new(#131722, 10), "Bg tabla",  group="Colores")

// FUENTE DE VOLUMEN
float vol_gc1   = request.security("COMEX:GC1!",   timeframe.period, volume, ignore_invalid_symbol=true)
float vol_oanda = request.security("OANDA:XAUUSD", timeframe.period, volume, ignore_invalid_symbol=true)

get_vol() =>
    float v = volume
    if i_vsrc == "COMEX:GC1!"
        v := vol_gc1
    else if i_vsrc == "OANDA:XAUUSD"
        v := vol_oanda
    else
        if na(v) or v == 0
            v := vol_gc1
        if na(v) or v == 0
            v := vol_oanda
        if na(v) or v == 0
            v := 1.0
    v

// FUNCIONES
f_vs(float v) =>
    string s = ""
    if v >= 1e9
        s := str.tostring(math.round(v / 1e9, 2)) + " B"
    else if v >= 1e6
        s := str.tostring(math.round(v / 1e6, 2)) + " M"
    else if v >= 1e3
        s := str.tostring(math.round(v / 1e3, 1)) + " K"
    else
        s := str.tostring(math.round(v, 0))
    s

f_bw(float o, float c, float h, float l) =>
    float rng  = h - l
    float body = math.abs(c - o)
    float bf   = rng > 0 ? body / rng : 0.5
    float w    = c >= o ? 0.5 + bf * 0.5 : 0.5 - bf * 0.5
    w

f_row(table t, int r, string lbl, string val, color vc, color bg, string sz) =>
    table.cell(t, 0, r, lbl,
         text_color=color.new(color.white, 40),
         text_size=sz, bgcolor=bg,
         text_halign=text.align_left)
    table.cell(t, 1, r, val,
         text_color=vc,
         text_size=sz, bgcolor=bg,
         text_halign=text.align_right)

// ESTADO
var box[]  bboxes = array.new_box()
var box[]  rboxes = array.new_box()
var line   pline  = na

tpos = i_pos == "Top Right"   ? position.top_right   :
       i_pos == "Top Left"    ? position.top_left    :
       i_pos == "Bottom Left" ? position.bottom_left :
                                  position.bottom_right
tsz  = i_sz == "Tiny"  ? size.tiny  :
       i_sz == "Normal" ? size.normal : size.small

var table tbl = table.new(tpos, 2, 6,
     bgcolor      = i_cbg,
     border_color = color.new(color.white, 85),
     border_width = 1,
     frame_color  = color.new(color.white, 70),
     frame_width  = 1)

// PERFIL
if barstate.islast
    for b in bboxes
        box.delete(b)
    for b in rboxes
        box.delete(b)
    array.clear(bboxes)
    array.clear(rboxes)
    if not na(pline)
        line.delete(pline)

    float[] ah  = array.new_float(0)
    float[] al  = array.new_float(0)
    float[] abv = array.new_float(0)
    float[] arv = array.new_float(0)

    for i = 0 to i_per - 1
        float bw  = f_bw(open[i], close[i], high[i], low[i])
        float vol = get_vol()[i]
        array.push(ah,  high[i])
        array.push(al,  low[i])
        array.push(abv, vol * bw)
        array.push(arv, vol * (1.0 - bw))

    float p_hi  = array.max(ah)
    float p_lo  = array.min(al)
    float p_rng = p_hi - p_lo

    if p_rng > 0
        float nsz   = math.max(p_rng / i_niv, syminfo.mintick)
        int   nreal = math.floor(p_rng / nsz) + 1

        float[] bacc = array.new_float(nreal, 0.0)
        float[] racc = array.new_float(nreal, 0.0)

        for i = 0 to array.size(ah) - 1
            float h2   = array.get(ah,  i)
            float l2   = array.get(al,  i)
            float vb   = array.get(abv, i)
            float vr   = array.get(arv, i)
            float crng = h2 - l2
            if crng > 0
                int nlo = math.floor((l2 - p_lo) / nsz)
                int nhi = math.floor((h2 - p_lo) / nsz)
                for n = nlo to math.min(nhi, nreal - 1)
                    float nb  = p_lo + n * nsz
                    float nt  = nb + nsz
                    float ovl = math.min(h2, nt) - math.max(l2, nb)
                    if ovl > 0
                        float fr = ovl / crng
                        array.set(bacc, n, array.get(bacc, n) + vb * fr)
                        array.set(racc, n, array.get(racc, n) + vr * fr)

        float max_tv  = 0.0
        int   poc_idx = 0
        float poc_vol = 0.0

        for n = 0 to nreal - 1
            float tv = array.get(bacc, n) + array.get(racc, n)
            if tv > max_tv
                max_tv := tv
            if tv > poc_vol
                poc_vol := tv
                poc_idx := n

        int br = bar_index + i_off

        if max_tv > 0
            for n = 0 to nreal - 1
                float vbull = array.get(bacc, n)
                float vbear = array.get(racc, n)
                float vtot  = vbull + vbear
                float fb    = vtot > 0 ? vbull / vtot : 0.5
                int   wt    = math.round(vtot / max_tv * i_anch)
                int   wb    = math.round(wt * fb)
                int   wr    = wt - wb
                float yb    = p_lo + n * nsz
                float yt    = yb + nsz * 0.92
                if wb > 0
                    array.push(bboxes, box.new(
                         left=br-wt, top=yt, right=br-wt+wb, bottom=yb,
                         bgcolor=i_cbul,
                         border_color=color.new(i_cbul, 60),
                         border_width=1))
                if wr > 0
                    array.push(rboxes, box.new(
                         left=br-wr, top=yt, right=br, bottom=yb,
                         bgcolor=i_cber,
                         border_color=color.new(i_cber, 60),
                         border_width=1))

            if i_poc
                float pp = p_lo + poc_idx * nsz + nsz * 0.5
                pline := line.new(
                     x1=bar_index - i_per, y1=pp,
                     x2=bar_index + i_off, y2=pp,
                     color=i_cpoc, width=1,
                     style=line.style_dashed)

// TABLA
if i_tbl and (barstate.islast or barstate.isrealtime)
    float bwc  = f_bw(open, close, high, low)
    float rawv = get_vol()
    float vbc  = rawv * bwc
    float vrc  = rawv * (1.0 - bwc)
    float ratc = vrc > 0 ? vbc / vrc : 999.0
    float pctc = rawv > 0 ? vbc / rawv * 100 : 50.0

    table.cell(tbl, 0, 0,
         "VOL  " + str.tostring(i_per) + "  velas",
         text_color=color.new(color.white, 20),
         text_size=size.tiny, bgcolor=i_chdr,
         text_halign=text.align_left)
    table.cell(tbl, 1, 0, "ultima barra",
         text_color=color.new(color.white, 50),
         text_size=size.tiny, bgcolor=i_chdr,
         text_halign=text.align_right)
    f_row(tbl, 1, "Alcista", f_vs(vbc),  i_cbul, i_cbg, tsz)
    f_row(tbl, 2, "Bajista", f_vs(vrc),  i_cber, i_cbg, tsz)
    f_row(tbl, 3, "Total",   f_vs(rawv),
         color.new(color.white, 30), i_cbg, tsz)
    f_row(tbl, 4, "Ratio",
         str.tostring(math.round(ratc, 2)),
         ratc > 1 ? i_cbul : i_cber, i_cbg, tsz)
    f_row(tbl, 5, "% Bull",
         str.tostring(math.round(pctc, 1)) + "%",
         pctc > 50 ? i_cbul : i_cber, i_cbg, tsz)
````
