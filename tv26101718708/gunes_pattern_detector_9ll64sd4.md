# Gunes - Pattern Detector

- url: https://www.tradingview.com/script/9lL64Sd4/
- type: indicator
- pine_id: PUB;bc08f2ffd87745ab98897fd89339b7c9
- version: 1.0

## Description

Elliott dalgaları, omuz-baş-omuz, üçgen ve kama formasyonlarını otomatik tespit eden ZigZag tabanlı gösterge.

## Source Code

````pine
//@version=5
indicator("TR Formasyon Dedektörü", overlay=true, max_lines_count=500, max_labels_count=300)

pivot_len     = input.int(5,   "Pivot Uzunluğu",            minval=2, maxval=20, group="Ayarlar")
max_pivots    = input.int(20,  "Geri Bakış (Pivot Sayısı)", minval=6, maxval=50,  group="Ayarlar")
show_elliott  = input.bool(true, "Elliott Dalgaları",        group="Göster")
show_triangle = input.bool(true, "Üçgen & Kama",             group="Göster")
show_hs       = input.bool(true, "Omuz-Baş-Omuz",           group="Göster")
show_zigzag   = input.bool(true, "ZigZag Çizgileri",         group="Göster")
show_pivots   = input.bool(true, "Pivot H/L Etiketleri",     group="Göster")

ph = ta.pivothigh(high, pivot_len, pivot_len)
pl = ta.pivotlow (low,  pivot_len, pivot_len)

var float[] zz_p = array.new_float()
var int[]   zz_b = array.new_int()
var bool[]  zz_h = array.new_bool()

if not na(ph)
    n = array.size(zz_p)
    lastIsHigh = n > 0 ? array.get(zz_h, n - 1) : false
    if n == 0 or not lastIsHigh
        array.push(zz_p, ph)
        array.push(zz_b, bar_index - pivot_len)
        array.push(zz_h, true)
    else if ph > array.get(zz_p, n - 1)
        array.set(zz_p, n - 1, ph)
        array.set(zz_b, n - 1, bar_index - pivot_len)

if not na(pl)
    n = array.size(zz_p)
    lastIsHigh = n > 0 ? array.get(zz_h, n - 1) : false
    if n == 0 or lastIsHigh
        array.push(zz_p, pl)
        array.push(zz_b, bar_index - pivot_len)
        array.push(zz_h, false)
    else if pl < array.get(zz_p, n - 1)
        array.set(zz_p, n - 1, pl)
        array.set(zz_b, n - 1, bar_index - pivot_len)

while array.size(zz_p) > max_pivots
    array.shift(zz_p)
    array.shift(zz_b)
    array.shift(zz_h)

var line[]  d_lines  = array.new_line()
var label[] d_labels = array.new_label()

if barstate.islast
    for ln in d_lines
        line.delete(ln)
    for lb in d_labels
        label.delete(lb)
    array.clear(d_lines)
    array.clear(d_labels)

    n = array.size(zz_p)

    if show_zigzag and n >= 2
        for i = 0 to n - 2
            b1 = array.get(zz_b, i)
            p1 = array.get(zz_p, i)
            b2 = array.get(zz_b, i + 1)
            p2 = array.get(zz_p, i + 1)
            isH = array.get(zz_h, i)
            array.push(d_lines, line.new(b1, p1, b2, p2,
                 color=isH ? color.new(color.red, 40) : color.new(color.green, 40), width=1))

    if show_pivots and n > 0
        for i = 0 to n - 1
            pb  = array.get(zz_b, i)
            pv  = array.get(zz_p, i)
            isH = array.get(zz_h, i)
            array.push(d_labels, label.new(pb, pv,
                 isH ? "H" : "L",
                 style=isH ? label.style_label_down : label.style_label_up,
                 size=size.tiny,
                 color=isH ? color.new(color.red, 20) : color.new(color.green, 20),
                 textcolor=color.white))

    if show_elliott and n >= 6
        for i = 0 to 4
            idx1 = n - 6 + i
            idx2 = n - 5 + i
            b1 = array.get(zz_b, idx1)
            p1 = array.get(zz_p, idx1)
            b2 = array.get(zz_b, idx2)
            p2 = array.get(zz_p, idx2)
            isUp = not array.get(zz_h, idx1)
            wc   = isUp ? color.lime : color.red
            array.push(d_lines, line.new(b1, p1, b2, p2, color=wc, width=3))
            array.push(d_labels, label.new(b2, p2,
                 str.tostring(i + 1),
                 style=isUp ? label.style_label_up : label.style_label_down,
                 size=size.normal, color=wc, textcolor=color.black))

    if show_hs and n >= 5
        h1 = array.get(zz_p, n - 5)
        h2 = array.get(zz_p, n - 3)
        h3 = array.get(zz_p, n - 1)
        b1 = array.get(zz_b, n - 5)
        b2 = array.get(zz_b, n - 3)
        b3 = array.get(zz_b, n - 1)
        if array.get(zz_h, n-5) and array.get(zz_h, n-3) and array.get(zz_h, n-1)
            if h2 > h1 and h2 > h3 and math.abs(h1 - h3) / h2 < 0.25
                nk = (array.get(zz_p, n-4) + array.get(zz_p, n-2)) / 2
                array.push(d_lines, line.new(b1, nk, b3 + 5, nk,
                     color=color.orange, width=2, style=line.style_dashed))
                array.push(d_labels, label.new(b2, h2, "OBO\nSATIS",
                     style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.normal))

    if show_hs and n >= 5
        l1 = array.get(zz_p, n - 5)
        l2 = array.get(zz_p, n - 3)
        l3 = array.get(zz_p, n - 1)
        b1 = array.get(zz_b, n - 5)
        b2 = array.get(zz_b, n - 3)
        b3 = array.get(zz_b, n - 1)
        if not array.get(zz_h, n-5) and not array.get(zz_h, n-3) and not array.get(zz_h, n-1)
            if l2 < l1 and l2 < l3 and math.abs(l1 - l3) / math.abs(l2) < 0.25
                nk = (array.get(zz_p, n-4) + array.get(zz_p, n-2)) / 2
                array.push(d_lines, line.new(b1, nk, b3 + 5, nk,
                     color=color.teal, width=2, style=line.style_dashed))
                array.push(d_labels, label.new(b2, l2, "Ters OBO\nALIM",
                     style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.normal))

    if show_triangle and n >= 4
        pa  = array.get(zz_p, n-4)
        pb2 = array.get(zz_p, n-3)
        pc  = array.get(zz_p, n-2)
        pd  = array.get(zz_p, n-1)
        ba  = array.get(zz_b, n-4)
        bb  = array.get(zz_b, n-3)
        bc  = array.get(zz_b, n-2)
        bd  = array.get(zz_b, n-1)
        if array.get(zz_h, n-4) and array.get(zz_h, n-2)
            dbc = float(bc - ba)
            dbd = float(bd - bb)
            us  = dbc > 0 ? (pc - pa) / dbc : 0.0
            ls  = dbd > 0 ? (pd - pb2) / dbd : 0.0
            converging = (us < 0 and ls > 0) or (us < ls)
            if converging
                pc2 = color.purple
                pn  = "SIM.\nUCGEN"
                if math.abs(us) < 0.0001 and ls > 0
                    pn  := "YUK. UCGEN\nALIM"
                    pc2 := color.green
                else if us < 0 and math.abs(ls) < 0.0001
                    pn  := "AS. UCGEN\nSATIS"
                    pc2 := color.red
                else if us > 0 and ls > 0 and us < ls
                    pn  := "YUK. KAMA\nSATIS"
                    pc2 := color.red
                else if us < 0 and ls < 0 and us > ls
                    pn  := "AS. KAMA\nALIM"
                    pc2 := color.green
                ext = bar_index + 10
                array.push(d_lines, line.new(ba, pa, ext, pc + us * (ext - bc), color=pc2, width=2))
                array.push(d_lines, line.new(bb, pb2, ext, pd + ls * (ext - bd), color=pc2, width=2))
                array.push(d_labels, label.new(int((ba + bd) / 2), (pa + pd) / 2, pn,
                     style=label.style_label_center, color=pc2, textcolor=color.white, size=size.normal))
````
