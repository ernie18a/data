#  Aquila Price Levels - Multi-Timeframe Institutional Levels 

- url: https://www.tradingview.com/script/MwT1luTE/
- type: indicator
- pine_id: PUB;4b0464c09b29497997bfd42da5e06c25
- version: 1.0

## Description

🦅  Aquila Price Levels - Multi-Timeframe Institutional Levels 


The "Aquila Price Levels v1.1" script is a structural analysis tool developed to simultaneously map and visualize critical price levels across Daily (D), Weekly (W), and Monthly (M) timeframes directly on the operational chart.

The Importance of a Unified Visualization (Single Board):
Having a comprehensive overview of macro and micro levels in a single interface is critical for reading Order Flow and market structure. This centralized approach eliminates noise and the constant need to switch timeframes, allowing the user to:

Identify Confluences: Highlights zones where levels from different timeframes (e.g., Previous Week High and Current Daily Open) intersect, defining high-probability order blocks.

Map Liquidity: Makes external liquidity targets (PDH, PDL, weekly and monthly highs/lows) immediately visible. These are the primary targets exploited by algorithms and institutional players for positioning.

Define the Bias: Evaluating the real-time price position relative to macro Opens provides an objective reading of both short-term and long-term directional bias.

Manage Equilibrium Areas: Tracking the medians (H+L)/2 provides constant reference points for mean reversion setups.

Main Features:

Multi-Timeframe Tracking (Current & Previous): Automatic calculation and plotting of Open, High, Low, Close, and Median for the day, week, and month (both currently updating and previously consolidated).

Smart Label Management: The system dynamically groups labels on the horizontal axis if levels fall within a configurable tolerance threshold, preventing visual overlapping on the chart.

Summary Table (Dashboard): An integrated visual matrix (freely positionable) that summarizes the exact numerical values of all D/W/M levels, acting as an immediate control panel.

Operational Tooltips: Hovering over the price labels provides technical descriptions of the level's significance (e.g., directional watershed, macro wall, liquidity trap).

UI Customization: Total control over line thickness, styles, opacity for current periods, and label offsets.

Practical Application:
Particularly optimized for highly technical and volatile assets like XAUUSD (Gold), where millimeter precision on historical liquidity grabs and reactions to macro levels dictates the profitability of the operational setup.

🦅  Royal Eagles - Born to fly, born to dare.

## Source Code

````pine
//@version=6
indicator("🦅 Aquila Livelli Prezzo v1.1 giua64", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════
// GRUPPI ON/OFF
// ═══════════════════════════════════════════════════════
gG = "📅 GIORNO"
show_d_curr = input.bool(true, "Giorno ATTUALE",     group=gG)
show_d_prev = input.bool(true, "Giorno PRECEDENTE",  group=gG)

gW = "📆 WEEK"
show_w_curr = input.bool(true, "Week ATTUALE",       group=gW)
show_w_prev = input.bool(true, "Week PRECEDENTE",    group=gW)

gM = "🗓️ MESE"
show_m_curr = input.bool(true, "Mese ATTUALE",       group=gM)
show_m_prev = input.bool(true, "Mese PRECEDENTE",    group=gM)

// ═══════════════════════════════════════════════════════
// QUALI LIVELLI (O/H/L/C/MEDIANA)
// ═══════════════════════════════════════════════════════
gL = "📐 LIVELLI DA MOSTRARE"
show_open  = input.bool(true, "Open",    group=gL, inline="1")
show_high  = input.bool(true, "High",    group=gL, inline="1")
show_low   = input.bool(true, "Low",     group=gL, inline="1")
show_close = input.bool(true, "Close",   group=gL, inline="2")
show_mid   = input.bool(true, "Mediana", group=gL, inline="2")
hide_close_att = input.bool(true, "🚫 Nascondi Close ATTUALI (D/W/M ballano col prezzo)", group=gL)

// ═══════════════════════════════════════════════════════
// STILE LINEE / ETICHETTE
// ═══════════════════════════════════════════════════════
gS = "🎨 STILE"
showLines   = input.bool(true, "➖ Mostra Linee", group=gS)
showLineLbl = input.bool(true, "🏷️ Mostra Etichette", group=gS)
offsetX     = input.int(50, "➡️ Offset Orizzontale Etichette", minval=0, maxval=500, group=gS)
offsetY     = input.float(0.0, "⬆️ Offset Verticale Etichette (punti)", step=0.1, group=gS)
lblSize     = input.string("normal", "🔡 Dim. Etichette", options=["tiny","small","normal","large"], group=gS)

col_d = input.color(#00BCD4, "Colore Giorno (Daily)", group=gS)
col_w = input.color(#FF9800, "Colore Week",          group=gS)
col_m = input.color(#E91E63, "Colore Mese",          group=gS)
att_fade = input.int(25, "🌫️ Sfumatura ATTUALI (%)", minval=0, maxval=60, group=gS)

w_curr_line = input.int(1, "Spessore ATTUALE",    minval=1, maxval=4, group=gS)
w_prev_line = input.int(2, "Spessore PRECEDENTE", minval=1, maxval=4, group=gS)
style_curr  = input.string("dashed", "Stile ATTUALE",    options=["solid","dashed","dotted"], group=gS)
style_prev  = input.string("solid",  "Stile PRECEDENTE", options=["solid","dashed","dotted"], group=gS)

lsz = lblSize == "tiny" ? size.tiny : lblSize == "small" ? size.small : lblSize == "large" ? size.large : size.normal

// colori ATTUALI = stesso colore dei precedenti ma leggermente sfumati
col_d_att = color.new(col_d, att_fade)
col_w_att = color.new(col_w, att_fade)
col_m_att = color.new(col_m, att_fade)

// ═══════════════════════════════════════════════════════
// TABELLA
// ═══════════════════════════════════════════════════════
gT = "📋 TABELLA"
show_table = input.bool(true, "Mostra Tabella", group=gT)
posTab     = input.string("bottom_right", "📍 Posizione", options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group=gT)
sizeTab    = input.string("small", "🔡 Dimensione Testo", options=["tiny","small","normal","large"], group=gT)
confTol    = input.float(0.10, "⚡ Tolleranza Confluenza (%)", minval=0.01, maxval=1.0, step=0.01, group=gT)

// ═══════════════════════════════════════════════════════
// SECURITY CALLS — valori assoluti dei periodi (stabili al cambio TF)
// ═══════════════════════════════════════════════════════
[d_o_c, d_h_c, d_l_c, d_c_c] = request.security(syminfo.tickerid, "D", [open, high, low, close], lookahead=barmerge.lookahead_on)
[d_o_p, d_h_p, d_l_p, d_c_p] = request.security(syminfo.tickerid, "D", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[w_o_c, w_h_c, w_l_c, w_c_c] = request.security(syminfo.tickerid, "W", [open, high, low, close], lookahead=barmerge.lookahead_on)
[w_o_p, w_h_p, w_l_p, w_c_p] = request.security(syminfo.tickerid, "W", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)
[m_o_c, m_h_c, m_l_c, m_c_c] = request.security(syminfo.tickerid, "M", [open, high, low, close], lookahead=barmerge.lookahead_on)
[m_o_p, m_h_p, m_l_p, m_c_p] = request.security(syminfo.tickerid, "M", [open[1], high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

d_mid_c = (d_h_c + d_l_c) / 2
d_mid_p = (d_h_p + d_l_p) / 2
w_mid_c = (w_h_c + w_l_c) / 2
w_mid_p = (w_h_p + w_l_p) / 2
m_mid_c = (m_h_c + m_l_c) / 2
m_mid_p = (m_h_p + m_l_p) / 2

// ═══════════════════════════════════════════════════════
// FUNZIONI
// ═══════════════════════════════════════════════════════
f_fmt(v) => na(v) ? "—" : str.tostring(math.round(v, 2))
f_styN(s) => s == "solid" ? 0 : s == "dashed" ? 1 : 2
f_styL(n) => n == 0 ? line.style_solid : n == 1 ? line.style_dashed : line.style_dotted

// array di accumulo livelli (riempiti sull'ultima barra, poi disegnati)
var float[]  Lv_val  = array.new<float>(0)
var color[]  Lv_col  = array.new<color>(0)
var int[]    Lv_wid  = array.new<int>(0)
var int[]    Lv_sty  = array.new<int>(0)
var string[] Lv_txt  = array.new<string>(0)
var string[] Lv_tip  = array.new<string>(0)
var int[]    Lv_rank = array.new<int>(0)

var line[]  L  = array.new<line>(0)
var label[] LB = array.new<label>(0)

// _rank: 0=M, 1=W, 2=D | _pa: "P" (precedente) o "A" (attuale)
f_add(_show, _val, _col, _wid, _styN, _txt, _tip, _rank, _pa) =>
    if _show and not na(_val)
        array.push(Lv_val,  _val)
        array.push(Lv_col,  _col)
        array.push(Lv_wid,  _wid)
        array.push(Lv_sty,  _styN)
        array.push(Lv_txt,  _pa + " " + _txt)
        array.push(Lv_tip,  _tip)
        array.push(Lv_rank, _rank)

// conta timeframe distinti (D/W/M) in confluenza su una riga della tabella
f_row(_tab, r, lbl, dp, dc, wp, wc, mp, mc, _sz) =>
    _bg = color.rgb(30, 30, 30)
    _hd = color.rgb(45, 45, 45)
    table.cell(_tab, 0, r, lbl,       bgcolor=_hd, text_color=color.white, text_size=_sz)
    table.cell(_tab, 1, r, f_fmt(dp), bgcolor=_bg, text_color=color.white, text_size=_sz)
    table.cell(_tab, 2, r, f_fmt(dc), bgcolor=_bg, text_color=color.white, text_size=_sz)
    table.cell(_tab, 3, r, f_fmt(wp), bgcolor=_bg, text_color=color.white, text_size=_sz)
    table.cell(_tab, 4, r, f_fmt(wc), bgcolor=_bg, text_color=color.white, text_size=_sz)
    table.cell(_tab, 5, r, f_fmt(mp), bgcolor=_bg, text_color=color.white, text_size=_sz)
    table.cell(_tab, 6, r, f_fmt(mc), bgcolor=_bg, text_color=color.white, text_size=_sz)

// ═══════════════════════════════════════════════════════
// RACCOLTA + DISEGNO CON AFFIANCAMENTO CONFLUENZE
// ═══════════════════════════════════════════════════════
if barstate.islast
    for ln in L
        line.delete(ln)
    for lb in LB
        label.delete(lb)
    array.clear(L)
    array.clear(LB)
    array.clear(Lv_val)
    array.clear(Lv_col)
    array.clear(Lv_wid)
    array.clear(Lv_sty)
    array.clear(Lv_txt)
    array.clear(Lv_tip)
    array.clear(Lv_rank)

    scN = f_styN(style_curr)
    spN = f_styN(style_prev)

    // ── GIORNO (rank 2) ──
    if show_d_curr
        f_add(show_open,  d_o_c,   col_d_att, w_curr_line, scN, "D-O",   "Apertura Daily ATTUALE\nBias intraday: prezzo sopra = LONG, sotto = SHORT\nSpartiacque direzionale della giornata", 2, "A")
        f_add(show_high,  d_h_c,   col_d_att, w_curr_line, scN, "D-H",   "Massimo Daily ATTUALE (in aggiornamento)\nEspansione del range di oggi\nRottura = nuovo massimo di giornata", 2, "A")
        f_add(show_low,   d_l_c,   col_d_att, w_curr_line, scN, "D-L",   "Minimo Daily ATTUALE (in aggiornamento)\nEspansione del range di oggi\nRottura = nuovo minimo di giornata", 2, "A")
        f_add(show_close and not hide_close_att, d_c_c,   col_d_att, w_curr_line, scN, "D-C",   "Prezzo attuale (close Daily corrente)\nConsenso di prezzo in tempo reale", 2, "A")
        f_add(show_mid,   d_mid_c, col_d_att, w_curr_line, scN, "D-Med", "Mediana Daily ATTUALE (H+L)/2\nEquilibrio della giornata — mean reversion", 2, "A")
    if show_d_prev
        f_add(show_open,  d_o_p,   col_d, w_prev_line, spN, "D-O",   "Apertura del giorno PRECEDENTE\nMemoria intraday — spesso ritestata", 2, "P")
        f_add(show_high,  d_h_p,   col_d, w_prev_line, spN, "PDH",   "Previous Day High — Massimo di ieri\n⭐ Livello intraday chiave: Londra/NY cercano liquidità qui sopra\nTarget e trappola di liquidità quotidiana", 2, "P")
        f_add(show_low,   d_l_p,   col_d, w_prev_line, spN, "PDL",   "Previous Day Low — Minimo di ieri\n⭐ Livello intraday chiave: Londra/NY cercano liquidità qui sotto\nTarget e trappola di liquidità quotidiana", 2, "P")
        f_add(show_close, d_c_p,   col_d, w_prev_line, spN, "D-C",   "Chiusura del giorno PRECEDENTE\nConsenso giornaliero — riferimento istituzionale", 2, "P")
        f_add(show_mid,   d_mid_p, col_d, w_prev_line, spN, "D-Med", "Mediana del giorno precedente (H+L)/2\nEquilibrio del range di ieri — mean reversion", 2, "P")

    // ── WEEK (rank 1) ──
    if show_w_curr
        f_add(show_open,  w_o_c,   col_w_att, w_curr_line, scN, "W-O",   "Apertura Weekly ATTUALE\n⭐ Bias settimanale: sopra = LONG, sotto = SHORT\nSpartiacque direzionale della settimana", 1, "A")
        f_add(show_high,  w_h_c,   col_w_att, w_curr_line, scN, "W-H",   "Massimo Weekly ATTUALE (in aggiornamento)\nEspansione del range settimanale in tempo reale", 1, "A")
        f_add(show_low,   w_l_c,   col_w_att, w_curr_line, scN, "W-L",   "Minimo Weekly ATTUALE (in aggiornamento)\nEspansione del range settimanale in tempo reale", 1, "A")
        f_add(show_close and not hide_close_att, w_c_c,   col_w_att, w_curr_line, scN, "W-C",   "Prezzo attuale (close Weekly corrente)\nConsenso settimanale in formazione", 1, "A")
        f_add(show_mid,   w_mid_c, col_w_att, w_curr_line, scN, "W-Med", "Mediana Weekly ATTUALE (H+L)/2\nEquilibrio settimanale — mean reversion", 1, "A")
    if show_w_prev
        f_add(show_open,  w_o_p,   col_w, w_prev_line, spN, "W-O",   "Apertura settimana PRECEDENTE\nMemoria direzionale settimanale", 1, "P")
        f_add(show_high,  w_h_p,   col_w, w_prev_line, spN, "W-H",   "Massimo settimana PRECEDENTE\n⭐ Resistenza settimanale validata\nRottura con volume = inizio movimento direzionale", 1, "P")
        f_add(show_low,   w_l_p,   col_w, w_prev_line, spN, "W-L",   "Minimo settimana PRECEDENTE\n⭐ Supporto settimanale validato\nRottura con volume = inizio movimento direzionale", 1, "P")
        f_add(show_close, w_c_p,   col_w, w_prev_line, spN, "W-C",   "Chiusura settimana PRECEDENTE\nConsenso weekly — molto rispettato da algoritmi e istituzionali", 1, "P")
        f_add(show_mid,   w_mid_p, col_w, w_prev_line, spN, "W-Med", "Mediana settimana precedente (H+L)/2\nEquilibrio settimanale — mean reversion", 1, "P")

    // ── MESE (rank 0) ──
    if show_m_curr
        f_add(show_open,  m_o_c,   col_m_att, w_curr_line, scN, "M-O",   "Apertura Mensile ATTUALE\nBias macro del mese: sopra = LONG, sotto = SHORT\nLivello decisionale istituzionale", 0, "A")
        f_add(show_high,  m_h_c,   col_m_att, w_curr_line, scN, "M-H",   "Massimo Mensile ATTUALE (in aggiornamento)\nEspansione del range mensile in tempo reale", 0, "A")
        f_add(show_low,   m_l_c,   col_m_att, w_curr_line, scN, "M-L",   "Minimo Mensile ATTUALE (in aggiornamento)\nEspansione del range mensile in tempo reale", 0, "A")
        f_add(show_close and not hide_close_att, m_c_c,   col_m_att, w_curr_line, scN, "M-C",   "Prezzo attuale (close Mensile corrente)\nConsenso mensile in formazione", 0, "A")
        f_add(show_mid,   m_mid_c, col_m_att, w_curr_line, scN, "M-Med", "Mediana Mensile ATTUALE (H+L)/2\nEquilibrio del mese — mean reversion", 0, "A")
    if show_m_prev
        f_add(show_open,  m_o_p,   col_m, w_prev_line, spN, "M-O",   "Apertura mese PRECEDENTE\nMemoria direzionale macro", 0, "P")
        f_add(show_high,  m_h_p,   col_m, w_prev_line, spN, "M-H",   "Massimo mese PRECEDENTE\n⭐ Muro macro — resistenza mensile\nRaramente rotto senza vero driver (DXY + rendimenti reali)", 0, "P")
        f_add(show_low,   m_l_p,   col_m, w_prev_line, spN, "M-L",   "Minimo mese PRECEDENTE\n⭐ Muro macro — supporto mensile\nRaramente rotto senza vero driver (DXY + rendimenti reali)", 0, "P")
        f_add(show_close, m_c_p,   col_m, w_prev_line, spN, "M-C",   "Chiusura mese PRECEDENTE\nConsenso mensile — memoria di prezzo profonda", 0, "P")
        f_add(show_mid,   m_mid_p, col_m, w_prev_line, spN, "M-Med", "Mediana mese precedente (H+L)/2\nEquilibrio del range mensile — mean reversion", 0, "P")

    // ── ORDINAMENTO (prezzo desc, poi rank M→W→D) ──
    n = array.size(Lv_val)
    if n > 0
        idx = array.new<int>(0)
        for i = 0 to n - 1
            array.push(idx, i)
        for a = 0 to n - 2
            for b = 0 to n - 2 - a
                ia = array.get(idx, b)
                ib = array.get(idx, b + 1)
                va = array.get(Lv_val, ia)
                vb = array.get(Lv_val, ib)
                ra = array.get(Lv_rank, ia)
                rb = array.get(Lv_rank, ib)
                if va < vb or (va == vb and ra > rb)
                    array.set(idx, b, ib)
                    array.set(idx, b + 1, ia)

        // ── DISEGNO CON AFFIANCAMENTO ──
        x1    = bar_index - 1
        xLbl  = bar_index + offsetX
        stepW = math.max(6, int(offsetX * 0.35))

        prevVal = float(na)
        slot = 0
        for k = 0 to n - 1
            i = array.get(idx, k)
            v = array.get(Lv_val, i)
            same = not na(prevVal) and math.abs(v - prevVal) / math.max(v, 0.0001) * 100 <= confTol
            slot := same ? slot + 1 : 0
            prevVal := v

            col = array.get(Lv_col, i)
            wid = array.get(Lv_wid, i)
            sty = f_styL(array.get(Lv_sty, i))
            txt = array.get(Lv_txt, i)
            tip = array.get(Lv_tip, i)

            if showLines and slot == 0
                array.push(L, line.new(x1, v, xLbl, v, color=col, width=wid, style=sty, extend=extend.both))
            if showLineLbl
                xPos = xLbl + slot * stepW
                array.push(LB, label.new(xPos, v + offsetY, txt + " " + str.tostring(math.round(v, 2)), tooltip=tip, color=col, textcolor=color.white, style=label.style_label_left, size=lsz))

// ═══════════════════════════════════════════════════════
// TABELLA (colonne = periodi Prec|Corr, righe = O/H/L/C/Med)
// ═══════════════════════════════════════════════════════
var table tab = na
if show_table and barstate.islast
    if not na(tab)
        table.delete(tab)

    tPos = posTab == "top_left" ? position.top_left : posTab == "top_center" ? position.top_center : posTab == "top_right" ? position.top_right : posTab == "middle_left" ? position.middle_left : posTab == "middle_center" ? position.middle_center : posTab == "middle_right" ? position.middle_right : posTab == "bottom_left" ? position.bottom_left : posTab == "bottom_center" ? position.bottom_center : position.bottom_right

    tSz = sizeTab == "tiny" ? size.tiny : sizeTab == "small" ? size.small : sizeTab == "large" ? size.large : size.normal

    tab := table.new(tPos, 7, 6, border_width=1, border_color=color.new(color.gray, 60))
    c_hd = color.rgb(45, 45, 45)

    table.cell(tab, 0, 0, "",       bgcolor=c_hd, text_color=color.white, text_size=tSz)
    table.cell(tab, 1, 0, "D Prec", bgcolor=col_d, text_color=color.white, text_size=tSz)
    table.cell(tab, 2, 0, "D Att",  bgcolor=color.new(col_d, 40), text_color=color.white, text_size=tSz)
    table.cell(tab, 3, 0, "W Prec", bgcolor=col_w, text_color=color.white, text_size=tSz)
    table.cell(tab, 4, 0, "W Att",  bgcolor=color.new(col_w, 40), text_color=color.white, text_size=tSz)
    table.cell(tab, 5, 0, "M Prec", bgcolor=col_m, text_color=color.white, text_size=tSz)
    table.cell(tab, 6, 0, "M Att",  bgcolor=color.new(col_m, 40), text_color=color.white, text_size=tSz)

    if show_open
        f_row(tab, 1, "Open",  d_o_p, d_o_c, w_o_p, w_o_c, m_o_p, m_o_c, tSz)
    if show_high
        f_row(tab, 2, "High",  d_h_p, d_h_c, w_h_p, w_h_c, m_h_p, m_h_c, tSz)
    if show_low
        f_row(tab, 3, "Low",   d_l_p, d_l_c, w_l_p, w_l_c, m_l_p, m_l_c, tSz)
    if show_close
        f_row(tab, 4, "Close", d_c_p, d_c_c, w_c_p, w_c_c, m_c_p, m_c_c, tSz)
    if show_mid
        f_row(tab, 5, "Med",   d_mid_p, d_mid_c, w_mid_p, w_mid_c, m_mid_p, m_mid_c, tSz)
````
