# FS - Strat Full TF Table

- url: https://www.tradingview.com/script/PMEqVbjT-FS-Strat-Full-TF-Table/
- type: indicator
- pine_id: PUB;283abd262d02488b87ae133b2155955e
- version: 11.0

## Description

FS - Strat Full TF Table

Description:
Frecuencia Strat - Full Timeframe Continuity Table.
Displays the Strat candle type (1, 2U, 2D, 3) across 9 simultaneous timeframes:
5m, 15m, 30m, 1h, 130m, Daily, Weekly, Quarterly and Yearly.
Includes SMA10 Freshness counter on Daily and Weekly (A=above, B=below SMA10).
Bullish/Bearish alignment score from 0 to 9.
Color coding: Green=2U, Red=2D, Yellow=1, Magenta=3




Frecuencia Strat - Full Timeframe Continuity Table.
Muestra el tipo de vela Strat (1, 2U, 2D, 3) en 9 timeframes simultaneos:
5m, 15m, 30m, 1h, 130m, Diario, Semanal, Trimestral y Anual.
Incluye contador de SMA10 Freshness en Diario y Semanal (A=sobre, B=bajo).
Score de alineacion bullish/bearish de 0 a 9.

## Source Code

````pine
//@version=6
// ============================================
// FRECUENCIA STRAT — FULL TIMEFRAME TABLE v2.4
// Autor: Frecuencia Strat
// Pine Script v6 — 40 securities exactos
// Y:4 Q:4 M:6 W:6 D:8 130m:4 TF4:2 TF3:2 TF2:2 TF1:2
// ============================================

indicator("FS - Strat Full TF Table v2.4", overlay=true, max_labels_count=500)

// ============================================
// PARAMETROS
// ============================================
var string GP0 = "Timeframes Activos (Mayor a Menor)"
show_Y    = input.bool(true,  "Y (Anual)",     group=GP0, inline="tf1")
show_Q    = input.bool(true,  "Q (Trimestre)", group=GP0, inline="tf1")
show_M    = input.bool(true,  "M (Mes)",       group=GP0, inline="tf1")
show_W    = input.bool(true,  "W (Semana)",    group=GP0, inline="tf2")
show_D    = input.bool(true,  "D (Dia)",       group=GP0, inline="tf2")
show_130m = input.bool(true,  "130m",          group=GP0, inline="tf3")
show_tf4  = input.bool(true,  "TF4",           group=GP0, inline="tf3")
show_tf3  = input.bool(true,  "TF3",           group=GP0, inline="tf3")
show_tf2  = input.bool(true,  "TF2",           group=GP0, inline="tf3")
show_tf1  = input.bool(true,  "TF1",           group=GP0, inline="tf3")

var string GP0B = "Minutos TFs Pequenos (configurables)"
tf4_min = input.int(60, "TF4 min", group=GP0B, minval=1, maxval=1440)
tf3_min = input.int(30, "TF3 min", group=GP0B, minval=1, maxval=1440)
tf2_min = input.int(15, "TF2 min", group=GP0B, minval=1, maxval=1440)
tf1_min = input.int(5,  "TF1 min", group=GP0B, minval=1, maxval=1440)

var string GP1 = "Freshness SMA10 — barras CERRADAS por TF"
show_freshD = input.bool(true, "Day",   group=GP1, inline="fr1")
show_freshW = input.bool(true, "Week",  group=GP1, inline="fr1")
show_freshM = input.bool(true, "Month", group=GP1, inline="fr1")
sma_length  = input.int(10, "Periodo SMA", group=GP1)

var string GP2 = "Volumen"
show_vol   = input.bool(true, "Mostrar Volumen", group=GP2)
vol_period = input.int(20, "Periodo promedio", group=GP2, minval=5, maxval=50)

var string GP3 = "Tabla"
pos_tabla     = input.string("top_right", "Posicion", options=["top_right","top_left","bottom_right","bottom_left"], group=GP3)
tamanio_texto = input.string("small", "Tamano texto", options=["tiny","small","normal","large"], group=GP3)

var string GP4 = "Scanner"
filtro_dir = input.string("Bullish", "Direccion", options=["Bullish","Bearish","Ambos"], group=GP4)
min_score  = input.int(5, "Minimo TF alineados", minval=1, maxval=10, group=GP4)

// ============================================
// COLORES
// ============================================
color C_HDR     = color.new(color.gray,    55)
color C_HDR_TXT = color.new(color.gray,    10)
color C_BLACK   = color.new(color.black,    0)
color C_2U      = color.new(#66bb6a,       25)
color C_2D      = color.new(#ef5350,       25)
color C_1       = color.new(#b0bec5,       15)
color C_3       = color.new(#ba68c8,       25)
color C_FA      = color.new(#a5d6a7,       10)
color C_FB      = color.new(#ef9a9a,       10)
color C_VHI     = color.new(#4dd0e1,       15)
color C_VMD     = color.new(#a5d6a7,       15)
color C_VLO     = color.new(#cfd8dc,       15)
color C_SBG_B   = color.new(#a5d6a7,       10)
color C_SBG_R   = color.new(#ef9a9a,       10)
color C_SBG_N   = color.new(#cfd8dc,       10)
color C_STX_B   = color.new(#1b5e20,        0)
color C_STX_R   = color.new(#b71c1c,        0)
color C_STX_N   = color.new(#37474f,        0)
color C_BORDER  = color.new(color.gray,    65)
color C_FRAME   = color.new(color.gray,    45)

// ============================================
// FUNCIONES
// ============================================
f_strat(float h, float l, float ph, float pl) =>
    bool inside  = h <= ph and l >= pl
    bool outside = h >  ph and l <  pl
    bool up      = h >  ph and l >= pl
    inside ? 1 : outside ? 3 : up ? 2 : -2

f_label(int t) =>
    t == 1 ? "1" : t == 2 ? "2U" : t == -2 ? "2D" : "3"

f_color_bg(int t) =>
    t == 2 ? C_2U : t == -2 ? C_2D : t == 1 ? C_1 : C_3

f_fmt(int n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

f_vol(float v) =>
    string r = ""
    if v >= 1000000
        r := str.tostring(v / 1000000, "#.##") + "M"
    else if v >= 1000
        r := str.tostring(v / 1000, "#") + "k"
    else
        r := str.tostring(v, "#")
    r

f_tf_lbl(int mins) =>
    mins >= 60 ? str.tostring(mins / 60) + "h" : str.tostring(mins) + "m"

// ============================================
// TF STRINGS Y LABELS
// ============================================
tf4_str = str.tostring(tf4_min)
tf3_str = str.tostring(tf3_min)
tf2_str = str.tostring(tf2_min)
tf1_str = str.tostring(tf1_min)

string tf4_lbl = f_tf_lbl(tf4_min)
string tf3_lbl = f_tf_lbl(tf3_min)
string tf2_lbl = f_tf_lbl(tf2_min)
string tf1_lbl = f_tf_lbl(tf1_min)

// ============================================
// REQUEST.SECURITY — 40 EXACTAS
// CAMBIO CLAVE: lookahead=OFF en todos los TFs
// high   = vela ACTUAL del TF (en curso)
// high[1] = vela ANTERIOR del TF (cerrada)
// Esto es exactamente lo que Strat necesita
// ============================================

// Yearly — 4
hY  = request.security(syminfo.tickerid, "12M", high,    lookahead=barmerge.lookahead_off)
lY  = request.security(syminfo.tickerid, "12M", low,     lookahead=barmerge.lookahead_off)
phY = request.security(syminfo.tickerid, "12M", high[1], lookahead=barmerge.lookahead_off)
plY = request.security(syminfo.tickerid, "12M", low[1],  lookahead=barmerge.lookahead_off)

// Quarterly — 4
hQ  = request.security(syminfo.tickerid, "3M",  high,    lookahead=barmerge.lookahead_off)
lQ  = request.security(syminfo.tickerid, "3M",  low,     lookahead=barmerge.lookahead_off)
phQ = request.security(syminfo.tickerid, "3M",  high[1], lookahead=barmerge.lookahead_off)
plQ = request.security(syminfo.tickerid, "3M",  low[1],  lookahead=barmerge.lookahead_off)

// Monthly — 6
hM   = request.security(syminfo.tickerid, "M", high,                        lookahead=barmerge.lookahead_off)
lM   = request.security(syminfo.tickerid, "M", low,                         lookahead=barmerge.lookahead_off)
phM  = request.security(syminfo.tickerid, "M", high[1],                     lookahead=barmerge.lookahead_off)
plM  = request.security(syminfo.tickerid, "M", low[1],                      lookahead=barmerge.lookahead_off)
cM   = request.security(syminfo.tickerid, "M", close[1],                    lookahead=barmerge.lookahead_off)
smaM = request.security(syminfo.tickerid, "M", ta.sma(close, sma_length)[1],lookahead=barmerge.lookahead_off)

// Weekly — 6
hW   = request.security(syminfo.tickerid, "W", high,                        lookahead=barmerge.lookahead_off)
lW   = request.security(syminfo.tickerid, "W", low,                         lookahead=barmerge.lookahead_off)
phW  = request.security(syminfo.tickerid, "W", high[1],                     lookahead=barmerge.lookahead_off)
plW  = request.security(syminfo.tickerid, "W", low[1],                      lookahead=barmerge.lookahead_off)
cW   = request.security(syminfo.tickerid, "W", close[1],                    lookahead=barmerge.lookahead_off)
smaW = request.security(syminfo.tickerid, "W", ta.sma(close, sma_length)[1],lookahead=barmerge.lookahead_off)

// Daily — 8
hD   = request.security(syminfo.tickerid, "D", high,                        lookahead=barmerge.lookahead_off)
lD   = request.security(syminfo.tickerid, "D", low,                         lookahead=barmerge.lookahead_off)
phD  = request.security(syminfo.tickerid, "D", high[1],                     lookahead=barmerge.lookahead_off)
plD  = request.security(syminfo.tickerid, "D", low[1],                      lookahead=barmerge.lookahead_off)
cD   = request.security(syminfo.tickerid, "D", close[1],                    lookahead=barmerge.lookahead_off)
smaD = request.security(syminfo.tickerid, "D", ta.sma(close, sma_length)[1],lookahead=barmerge.lookahead_off)
vD   = request.security(syminfo.tickerid, "D", volume,                      lookahead=barmerge.lookahead_off)
vaD  = request.security(syminfo.tickerid, "D", ta.sma(volume, vol_period),  lookahead=barmerge.lookahead_off)

// 130m — 4
h130  = request.security(syminfo.tickerid, "130", high,    lookahead=barmerge.lookahead_off)
l130  = request.security(syminfo.tickerid, "130", low,     lookahead=barmerge.lookahead_off)
ph130 = request.security(syminfo.tickerid, "130", high[1], lookahead=barmerge.lookahead_off)
pl130 = request.security(syminfo.tickerid, "130", low[1],  lookahead=barmerge.lookahead_off)

// TF4 — 2
h4    = request.security(syminfo.tickerid, tf4_str, high,    lookahead=barmerge.lookahead_off)
l4    = request.security(syminfo.tickerid, tf4_str, low,     lookahead=barmerge.lookahead_off)
float ph4 = request.security(syminfo.tickerid, tf4_str, high[1], lookahead=barmerge.lookahead_off)
float pl4 = request.security(syminfo.tickerid, tf4_str, low[1],  lookahead=barmerge.lookahead_off)

// TF3 — 2
h3    = request.security(syminfo.tickerid, tf3_str, high,    lookahead=barmerge.lookahead_off)
l3    = request.security(syminfo.tickerid, tf3_str, low,     lookahead=barmerge.lookahead_off)
float ph3 = request.security(syminfo.tickerid, tf3_str, high[1], lookahead=barmerge.lookahead_off)
float pl3 = request.security(syminfo.tickerid, tf3_str, low[1],  lookahead=barmerge.lookahead_off)

// TF2 — 2
h2    = request.security(syminfo.tickerid, tf2_str, high,    lookahead=barmerge.lookahead_off)
l2    = request.security(syminfo.tickerid, tf2_str, low,     lookahead=barmerge.lookahead_off)
float ph2 = request.security(syminfo.tickerid, tf2_str, high[1], lookahead=barmerge.lookahead_off)
float pl2 = request.security(syminfo.tickerid, tf2_str, low[1],  lookahead=barmerge.lookahead_off)

// TF1 — 2
h1    = request.security(syminfo.tickerid, tf1_str, high,    lookahead=barmerge.lookahead_off)
l1    = request.security(syminfo.tickerid, tf1_str, low,     lookahead=barmerge.lookahead_off)
float ph1 = request.security(syminfo.tickerid, tf1_str, high[1], lookahead=barmerge.lookahead_off)
float pl1 = request.security(syminfo.tickerid, tf1_str, low[1],  lookahead=barmerge.lookahead_off)

// ============================================
// TIPO DE VELA
// ============================================
int tY   = f_strat(hY,   lY,   phY,   plY)
int tQ   = f_strat(hQ,   lQ,   phQ,   plQ)
int tM   = f_strat(hM,   lM,   phM,   plM)
int tW   = f_strat(hW,   lW,   phW,   plW)
int tD   = f_strat(hD,   lD,   phD,   plD)
int t130 = f_strat(h130, l130, ph130, pl130)
int t4   = f_strat(h4,   l4,   ph4,   pl4)
int t3   = f_strat(h3,   l3,   ph3,   pl3)
int t2   = f_strat(h2,   l2,   ph2,   pl2)
int t1   = f_strat(h1,   l1,   ph1,   pl1)

// ============================================
// FRESHNESS — sin cambios
// ============================================
bool sobreD   = cD > smaD
bool newBarD  = ta.change(cD) != 0
var int  cntD = 1
var bool estD = sobreD
if newBarD
    if sobreD == estD
        cntD += 1
    else
        cntD  := 1
        estD  := sobreD
string freshD    = (sobreD ? "A" : "B") + f_fmt(cntD)
color  freshD_bg = sobreD ? C_FA : C_FB

bool sobreW   = cW > smaW
bool newBarW  = ta.change(cW) != 0
var int  cntW = 1
var bool estW = sobreW
if newBarW
    if sobreW == estW
        cntW += 1
    else
        cntW  := 1
        estW  := sobreW
string freshW    = (sobreW ? "A" : "B") + f_fmt(cntW)
color  freshW_bg = sobreW ? C_FA : C_FB

bool sobreM   = cM > smaM
bool newBarM  = ta.change(cM) != 0
var int  cntM = 1
var bool estM = sobreM
if newBarM
    if sobreM == estM
        cntM += 1
    else
        cntM  := 1
        estM  := sobreM
string freshM    = (sobreM ? "A" : "B") + f_fmt(cntM)
color  freshM_bg = sobreM ? C_FA : C_FB

// ============================================
// VOLUMEN — sin cambios
// ============================================
float  vol_ratio  = vaD > 0 ? vD / vaD : 1.0
string avg_str    = f_vol(vaD)
string vol_str    = f_vol(vD)
color  vol_dia_bg = vol_ratio >= 2.0 ? C_VHI : vol_ratio >= 1.0 ? C_VMD : C_VLO

// ============================================
// SCORE — sin cambios
// ============================================
to_bull(int t, bool s) => s and t ==  2 ? 1 : 0
to_bear(int t, bool s) => s and t == -2 ? 1 : 0

int score_bull = to_bull(tY,show_Y)+to_bull(tQ,show_Q)+to_bull(tM,show_M)+to_bull(tW,show_W)+to_bull(tD,show_D)+to_bull(t130,show_130m)+to_bull(t4,show_tf4)+to_bull(t3,show_tf3)+to_bull(t2,show_tf2)+to_bull(t1,show_tf1)
int score_bear = to_bear(tY,show_Y)+to_bear(tQ,show_Q)+to_bear(tM,show_M)+to_bear(tW,show_W)+to_bear(tD,show_D)+to_bear(t130,show_130m)+to_bear(t4,show_tf4)+to_bear(t3,show_tf3)+to_bear(t2,show_tf2)+to_bear(t1,show_tf1)

int aY=show_Y?1:0
int aQ=show_Q?1:0
int aM=show_M?1:0
int aW=show_W?1:0
int aD=show_D?1:0
int a130=show_130m?1:0
int a4=show_tf4?1:0
int a3=show_tf3?1:0
int a2=show_tf2?1:0
int a1=show_tf1?1:0
int total_tf = aY+aQ+aM+aW+aD+a130+a4+a3+a2+a1
int nFresh   = (show_freshD?1:0)+(show_freshW?1:0)+(show_freshM?1:0)
int nVol     = show_vol ? 2 : 0
int nTotal   = total_tf + nFresh + nVol

string bull_txt = "Bull " + str.tostring(score_bull) + "/" + str.tostring(total_tf)
string bear_txt = "Bear " + str.tostring(score_bear) + "/" + str.tostring(total_tf)
color  bull_bg  = score_bull > 0 ? C_SBG_B : C_SBG_N
color  bear_bg  = score_bear > 0 ? C_SBG_R : C_SBG_N
color  bull_tc  = score_bull > 0 ? C_STX_B : C_STX_N
color  bear_tc  = score_bear > 0 ? C_STX_R : C_STX_N

// ============================================
// POSICION — sin cambios
// ============================================
var tbl_pos = switch pos_tabla
    "top_left"     => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left"  => position.bottom_left
    => position.top_right

// ============================================
// TABLA — sin cambios
// ============================================
var table tbl = table.new(position=tbl_pos, columns=18, rows=3, border_width=1, border_color=C_BORDER, frame_width=1, frame_color=C_FRAME)

cell_draw(int c, string lbl, string val, color bg_val, color tc_val) =>
    table.cell(tbl, c, 0, text=lbl, text_color=C_HDR_TXT, bgcolor=C_HDR,  text_size=tamanio_texto, text_halign=text.align_center, text_valign=text.align_center)
    table.cell(tbl, c, 1, text=val, text_color=tc_val,    bgcolor=bg_val, text_size=tamanio_texto, text_halign=text.align_center, text_valign=text.align_center)

array<string> tf_names   = array.from("Y","Q","M","W","D","130m",tf4_lbl,tf3_lbl,tf2_lbl,tf1_lbl)
array<int>    tf_types   = array.from(tY,tQ,tM,tW,tD,t130,t4,t3,t2,t1)
array<bool>   tf_visible = array.from(show_Y,show_Q,show_M,show_W,show_D,show_130m,show_tf4,show_tf3,show_tf2,show_tf1)

var int col = 0
col := 0

for i = 0 to 9
    if array.get(tf_visible, i)
        int    t  = array.get(tf_types, i)
        string nm = array.get(tf_names, i)
        cell_draw(col, nm, f_label(t), f_color_bg(t), C_BLACK)
        col += 1

if show_freshD
    cell_draw(col, "Day", freshD, freshD_bg, C_BLACK)
    col += 1

if show_freshW
    cell_draw(col, "Week", freshW, freshW_bg, C_BLACK)
    col += 1

if show_freshM
    cell_draw(col, "Month", freshM, freshM_bg, C_BLACK)
    col += 1

if show_vol
    cell_draw(col, "Avg", avg_str, C_HDR, C_HDR_TXT)
    col += 1
    cell_draw(col, "Vol", vol_str, vol_dia_bg, C_BLACK)
    col += 1

// Score — 2 celdas fusionadas sin rayitas
int half     = nTotal / 2
int last_col = nTotal - 1

for c = 0 to last_col
    if c < half
        table.cell(tbl, c, 2, text="", bgcolor=bull_bg, text_size=tamanio_texto)
    else
        table.cell(tbl, c, 2, text="", bgcolor=bear_bg, text_size=tamanio_texto)

if half > 0
    table.merge_cells(tbl, 0, 2, half - 1, 2)
    table.cell(tbl, 0, 2, text=bull_txt, text_color=bull_tc, bgcolor=bull_bg, text_size=tamanio_texto, text_halign=text.align_center, text_valign=text.align_center)

if last_col > half
    table.merge_cells(tbl, half, 2, last_col, 2)
    table.cell(tbl, half, 2, text=bear_txt, text_color=bear_tc, bgcolor=bear_bg, text_size=tamanio_texto, text_halign=text.align_center, text_valign=text.align_center)
else
    table.cell(tbl, half, 2, text=bear_txt, text_color=bear_tc, bgcolor=bear_bg, text_size=tamanio_texto, text_halign=text.align_center, text_valign=text.align_center)

// ============================================
// PLOTS SCREENER
// ============================================
plot(score_bull, "Score_Bull", display=display.none)
plot(score_bear, "Score_Bear", display=display.none)

// ============================================
// ALERTAS
// ============================================
bool sig_bull = score_bull >= min_score
bool sig_bear = score_bear >= min_score
bool sig_scan = filtro_dir == "Bullish" ? sig_bull : filtro_dir == "Bearish" ? sig_bear : sig_bull or sig_bear

alertcondition(sig_scan, title="FS Strat Scanner Alert", message="Frecuencia Strat - Alineacion detectada")
````
