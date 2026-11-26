# AWR 5MA 3TF - Advanced Multi-Timeframe Moving Average Dashboard

- url: https://www.tradingview.com/script/HwAX0i9f/
- type: indicator
- pine_id: PUB;24c5f7c15cf141f88726b5af7187f7ca
- version: 7.0

## Description

AWR_5MA_3TF est un outil d'analyse de tendance tout-en-un conçu pour offrir une vision claire et synthétique du marché à travers de multiples unités de temps (Multi-Timeframe). Que vous fassiez du scalping, du day trading ou du swing trading, cet indicateur regroupe vos moyennes mobiles et calcule leur distance par rapport au prix sur trois horizons de temps différents, le tout dans un tableau de bord ultra-lisible.

🌟 Fonctionnalités Principales
1. 5 Moyennes Mobiles 100% Personnalisables
Affichez jusqu'à 5 moyennes mobiles sur votre graphique. Pour chacune, vous pouvez configurer individuellement :

La longueur (Length) : 7, 20, 50, 100, 200 par défaut.

Le type de moyenne : EMA, SMA, WMA, RMA, VWMA, HMA.

L'unité de temps (Timeframe).

L'esthétique : Couleur, transparence et épaisseur de ligne.

2. Système "Master" (Gain de temps)
L'indicateur inclut une fonction "Master Timeframe" et "Master Type". En un clic, vous pouvez forcer toutes les moyennes mobiles affichées ou celles du tableau à adopter la même unité de temps ou le même type (ex: basculer tout en EMA ou tout en H4), sans avoir à modifier les 5 MAs une par une.

3. Tableau de Bord Récapitulatif (3 Timeframes)
C'est le cœur de l'indicateur. Un tableau personnalisable s'affiche sur votre graphique et compare vos 5 MAs sur 3 unités de temps distinctes (TF A, TF B, TF C - par défaut : 1h, Journalier, Hebdomadaire).

Distance en % : Affiche la distance exacte en pourcentage entre le prix actuel (Close) et chaque moyenne mobile. Idéal pour repérer les sur-extensions (marché suracheté/survendu).

Code Couleur Visuel : Les pourcentages bénéficient d'un gradient de couleur (du vert au rouge) et d'un ajustement de la transparence en fonction de l'éloignement.

4. L'Harmonie des Moyennes (Ranking Visuel Intelligent)
Le tableau ne se contente pas d'afficher des chiffres purs : il intègre un algorithme de classement dynamique qui évalue la position relative de vos 5 moyennes mobiles. Un code couleur spécifique est appliqué au fond de chaque cellule pour vous permettre de lire l'état du marché en une fraction de seconde :

Alignement Parfait (Tendance forte) : Si les couleurs forment une suite logique et ordonnée dans votre colonne (par exemple, la MA courte est strictement au-dessus de toutes les autres, jusqu'à la plus longue), vous avez la confirmation visuelle immédiate d'une tendance saine et harmonieuse (Full Bullish ou Full Bearish).

Chaos / Consolidation : Si les couleurs sont mélangées ou désordonnées, le marché est en phase de range, de compression ou en pleine inversion de tendance. C'est un filtre visuel redoutable pour éviter de trader dans de mauvaises conditions de marché !

5. Alertes Complètes et Marquages Graphiques
Le script est pensé pour le trading automatisé ou la notification en temps réel. Il surveille l'unité de temps C (TF C, hebdomadaire par défaut) pour déclencher des alertes sur :

Croisements Cours / MA : Le prix croise les MAs 20, 50, 100 ou 200.

Croisements MA / MA : Surveille les croisements majeurs (ex: 20/50, 20/200, et le fameux 50/200 - Golden Cross / Death Cross).

Signaux visuels : Des pastilles apparaissent directement sur le graphique lors des croisements 50/200 (cercle blanc pour haussier, orange pour baissier).

💡 Comment l'utiliser ?
Analyse de Tendance Multi-TF : Utilisez le tableau pour confirmer la tendance de fond (TF C), la tendance intermédiaire (TF B) et trouver votre point d'entrée (TF A). Si l'harmonie des couleurs est parfaite et que les pourcentages sont cohérents, la dynamique globale est claire.

Retour à la moyenne (Mean Reversion) : Surveillez la colonne "Dist %". Un pourcentage exceptionnellement élevé indique que le prix s'est trop éloigné de sa moyenne mobile, suggérant une potentielle correction à venir.

Golden / Death Cross : Activez les alertes pour être notifié instantanément lorsqu'un croisement majeur (50/200 par exemple) se produit sur votre unité de temps de référence, sans avoir à surveiller le graphique en permanence.

⚙️ Paramètres Clés
Master TF / Type : Activez l'écrasement global pour aligner toutes les configurations d'un seul clic.

Table Settings : Positionnez le tableau (haut, bas, gauche, droite), ajustez la taille de la police et désactivez-le si vous souhaitez un graphique épuré.

Gradient Settings : Réglez le pourcentage maximum (Max abs % for gradient, par défaut 15%) pour calibrer l'intensité des couleurs du tableau selon la volatilité de l'actif que vous tradez.

(Note : Cet indicateur est un outil d'aide à la décision et ne constitue pas un conseil financier. Utilisez-le en conjonction avec d'autres méthodes d'analyse comme le Price Action ou le volume.)

## Source Code

````pine
//@version=6
indicator('AWR_5MA_3TF_Optimized', overlay = true)

// ------------ Inputs
src = input.source(close, 'Source of MAs')
lineWidth = input.int(2, 'Line width', minval = 1, maxval = 5)

// Master TF / Type
use_master_tf = input.bool(true, 'Use master timeframe for plotting')
master_tf = input.timeframe('W', 'Master timeframe')
use_master_type = input.bool(true, 'Use master type for plotting')
master_type = input.string('EMA', 'Master type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])

// Table settings
use_master_type_table = input.bool(true, 'Use master type for table')
master_type_table = input.string('EMA', 'Master type table', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
showTable = input.bool(true, 'Show recap table')
table_pos = input.string('Bottom right', 'Table position', options = ['Top left', 'Top right', 'Bottom left', 'Bottom right'])
table_border = input.bool(true, 'Show table border')
font_size = input.string('small', 'Font size', options = ['small', 'normal', 'large'])

// 3 TF only
tfA = input.timeframe('60', 'Table TF A')
tfB = input.timeframe('D', 'Table TF B')
tfC = input.timeframe('W', 'Table TF C')

// Gradient settings
max_abs_pct = input.float(15.0, 'Max abs % for gradient', step = 0.05)
min_transp = 0
max_transp = 50

// ------------ 5 MAs only
len1 = input.int(7, 'MA 1 length')
type1 = input.string('EMA', 'MA 1 type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
tf1 = input.timeframe('', 'MA 1 timeframe')
col1 = input.color(color.gray, 'MA 1 color')
tr1 = input.int(90, 'MA 1 transparency', minval = 0, maxval = 100)
col1f = color.new(col1, tr1)

len2 = input.int(20, 'MA 2 length')
type2 = input.string('EMA', 'MA 2 type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
tf2 = input.timeframe('', 'MA 2 timeframe')
col2 = input.color(color.aqua, 'MA 2 color')
tr2 = input.int(80, 'MA 2 transparency', minval = 0, maxval = 100)
col2f = color.new(col2, tr2)

len3 = input.int(50, 'MA 3 length')
type3 = input.string('SMA', 'MA 3 type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
tf3 = input.timeframe('', 'MA 3 timeframe')
col3 = input.color(color.yellow, 'MA 3 color')
tr3 = input.int(50, 'MA 3 transparency', minval = 0, maxval = 100)
col3f = color.new(col3, tr3)

len4 = input.int(100, 'MA 4 length')
type4 = input.string('SMA', 'MA 4 type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
tf4 = input.timeframe('', 'MA 4 timeframe')
col4 = input.color(color.orange, 'MA 4 color')
tr4 = input.int(80, 'MA 4 transparency', minval = 0, maxval = 100)
col4f = color.new(col4, tr4)

len5 = input.int(200, 'MA 5 length')
type5 = input.string('SMA', 'MA 5 type', options = ['EMA', 'SMA', 'WMA', 'RMA', 'VWMA', 'HMA'])
tf5 = input.timeframe('', 'MA 5 timeframe')
col5 = input.color(color.white, 'MA 5 color')
tr5 = input.int(50, 'MA 5 transparency', minval = 0, maxval = 100)
col5f = color.new(col5, tr5)

// ---------------- GLOBAL ARRAYS POUR LE TABLEAU ----------------
var maA = array.new_float(5, na)
var maB = array.new_float(5, na)
var maC = array.new_float(5, na)

// ------------ Functions
f_ma(_src, _len, _type) =>
    switch _type
        'EMA' => ta.ema(_src, _len)
        'SMA' => ta.sma(_src, _len)
        'WMA' => ta.wma(_src, _len)
        'RMA' => ta.rma(_src, _len)
        'VWMA' => ta.vwma(_src, _len)
        'HMA' => ta.hma(_src, _len)
        => na

effective_tf(_tf) =>
    use_master_tf ? master_tf : _tf
effective_type(_type) =>
    use_master_type ? master_type : _type

get_ma_for_plot(_tf, _src, _len, _type) =>
    eff_tf = effective_tf(_tf)
    eff_ty = effective_type(_type)
    eff_tf == '' ? f_ma(_src, _len, eff_ty) : request.security(syminfo.tickerid, eff_tf, f_ma(_src, _len, eff_ty), lookahead = barmerge.lookahead_off)

table_type_eff(_type) =>
    use_master_type_table ? master_type_table : _type

ma_on_tf_table(tf_arg, _len_simple, _type_simple) =>
    type_eff = table_type_eff(_type_simple)
    tf_arg == '' ? f_ma(src, _len_simple, type_eff) : request.security(syminfo.tickerid, tf_arg, f_ma(src, _len_simple, type_eff), lookahead = barmerge.lookahead_off)

fmt(v) =>
    na(v) ? 'n/a' : str.tostring(v, format.mintick)
pct_val(ma) =>
    na(ma) ? na : (close - ma) / ma * 100.0

// ------------ Gradient helpers
bg_for_pct_raw(pctf) =>
    if na(pctf)
        color.new(color.black, 100)
    else
        absv = math.abs(pctf)
        norm = math.min(absv / max_abs_pct, 1)
        transp = math.round(max_transp - norm * (max_transp - min_transp))
        pctf >= 0 ? color.new(color.green, transp) : color.new(color.red, transp)

pct_text_color(pctf) =>
    na(pctf) ? color.white : math.abs(pctf) <= 1 ? color.yellow : color.white

// ------------ Palette
pal1 = #e3f86c
pal2 = color.rgb(238, 238, 238)
pal3 = color.rgb(189, 189, 189)
pal4 = color.rgb(150, 150, 150)
pal5 = color.rgb(120, 120, 120)
pal6 = color.rgb(85, 85, 85)
pal7 = color.rgb(46, 46, 46)
pal8 = #3a013a
palette = array.from(pal1, pal2, pal3, pal4, pal5, pal6, pal7, pal8)

// Ranking for 5 elements
rank5(vals) =>
    r = array.new_int(5, na)
    for i = 0 to 4 by 1
        vi = array.get(vals, i)
        if na(vi)
            array.set(r, i, na)
        else
            greater = 0
            for j = 0 to 4 by 1
                vj = array.get(vals, j)
                if not na(vj)
                    if vj > vi or vj == vi and j < i
                        greater := greater + 1
            array.set(r, i, greater + 1)
    r

// ------------ Chart MAs and plots
ma1 = get_ma_for_plot(tf1, src, len1, type1)
ma2 = get_ma_for_plot(tf2, src, len2, type2)
ma3 = get_ma_for_plot(tf3, src, len3, type3)
ma4 = get_ma_for_plot(tf4, src, len4, type4)
ma5 = get_ma_for_plot(tf5, src, len5, type5)

plot(ma1, title = 'MA 1', color = col1f, linewidth = math.max(1, lineWidth))
plot(ma2, title = 'MA 2', color = col2f, linewidth = math.max(1, lineWidth))
plot(ma3, title = 'MA 3', color = col3f, linewidth = math.max(1, lineWidth))
plot(ma4, title = 'MA 4', color = col4f, linewidth = math.max(1, lineWidth))
plot(ma5, title = 'MA 5', color = col5f, linewidth = math.max(1, lineWidth))

// =========================================================================
// --- EXTRACTION SÉCURISÉE DES SÉRIES (POUR LE TABLEAU VISUEL UNIQUEMENT) ---
// =========================================================================
m1A = ma_on_tf_table(tfA, len1, type1), m2A = ma_on_tf_table(tfA, len2, type2), m3A = ma_on_tf_table(tfA, len3, type3), m4A = ma_on_tf_table(tfA, len4, type4), m5A = ma_on_tf_table(tfA, len5, type5)
m1B = ma_on_tf_table(tfB, len1, type1), m2B = ma_on_tf_table(tfB, len2, type2), m3B = ma_on_tf_table(tfB, len3, type3), m4B = ma_on_tf_table(tfB, len4, type4), m5B = ma_on_tf_table(tfB, len5, type5)
m1C = ma_on_tf_table(tfC, len1, type1), m2C = ma_on_tf_table(tfC, len2, type2), m3C = ma_on_tf_table(tfC, len3, type3), m4C = ma_on_tf_table(tfC, len4, type4), m5C = ma_on_tf_table(tfC, len5, type5)

array.set(maA, 0, m1A), array.set(maA, 1, m2A), array.set(maA, 2, m3A), array.set(maA, 3, m4A), array.set(maA, 4, m5A)
array.set(maB, 0, m1B), array.set(maB, 1, m2B), array.set(maB, 2, m3B), array.set(maB, 3, m4B), array.set(maB, 4, m5B)
array.set(maC, 0, m1C), array.set(maC, 1, m2C), array.set(maC, 2, m3C), array.set(maC, 3, m4C), array.set(maC, 4, m5C)

// ------------ Table positioning
var table_pos_enum = position.bottom_right
if table_pos == 'Top left'
    table_pos_enum := position.top_left
else if table_pos == 'Top right'
    table_pos_enum := position.top_right
else if table_pos == 'Bottom left'
    table_pos_enum := position.bottom_left

var table_font = size.small
if font_size == 'normal'
    table_font := size.normal
else if font_size == 'large'
    table_font := size.large

var table myTable = na
tb_rows = 6
tb_cols = 8

if na(myTable)
    myTable := table.new(position = table_pos_enum, columns = tb_cols, rows = tb_rows, border_width = table_border ? 1 : 0)
else
    table.set_position(myTable, table_pos_enum)

bg_color = #00000000

text_for_bg(bg) =>
    bg == pal1 or bg == pal2 or bg == pal3 or bg == pal4 ? color.black : color.white

draw_row(table_id, row, len, type, col, maA_val, maB_val, maC_val, rankA, rankB, rankC, table_font) =>
    pvA = pct_val(maA_val), pvB = pct_val(maB_val), pvC = pct_val(maC_val)
    sA = na(pvA) ? 'n/a' : str.format('{0,number,0.00}%', pvA), sB = na(pvB) ? 'n/a' : str.format('{0,number,0.00}%', pvB), sC = na(pvC) ? 'n/a' : str.format('{0,number,0.00}%', pvC)
    bgA = na(rankA) ? bg_color : array.get(palette, math.min(math.max(rankA - 1, 0), 7))
    bgB = na(rankB) ? bg_color : array.get(palette, math.min(math.max(rankB - 1, 0), 7))
    bgC = na(rankC) ? bg_color : array.get(palette, math.min(math.max(rankC - 1, 0), 7))
    display_type = table_type_eff(type)
    
    table.cell(table_id, 0, row, str.tostring(len), text_color = color.white, bgcolor = col, text_size = table_font)
    table.cell(table_id, 1, row, display_type, text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(table_id, 2, row, na(maA_val) ? 'n/a' : fmt(maA_val), text_color = text_for_bg(bgA), bgcolor = bgA, text_size = table_font)
    table.cell(table_id, 3, row, sA, text_color = pct_text_color(pvA), bgcolor = bg_for_pct_raw(pvA), text_size = table_font)
    table.cell(table_id, 4, row, na(maB_val) ? 'n/a' : fmt(maB_val), text_color = text_for_bg(bgB), bgcolor = bgB, text_size = table_font)
    table.cell(table_id, 5, row, sB, text_color = pct_text_color(pvB), bgcolor = bg_for_pct_raw(pvB), text_size = table_font)
    table.cell(table_id, 6, row, na(maC_val) ? 'n/a' : fmt(maC_val), text_color = text_for_bg(bgC), bgcolor = bgC, text_size = table_font)
    table.cell(table_id, 7, row, sC, text_color = pct_text_color(pvC), bgcolor = bg_for_pct_raw(pvC), text_size = table_font)

if showTable and not na(myTable)
    table.cell(myTable, 0, 0, 'Len', text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 1, 0, 'Type', text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 2, 0, tfA == '' ? 'TF A' : str.tostring(tfA), text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 3, 0, 'Dist %', text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 4, 0, tfB == '' ? 'TF B' : str.tostring(tfB), text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 5, 0, 'Dist %', text_color = color.white, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 6, 0, tfC == '' ? 'TF C' : str.tostring(tfC), text_color = color.gray, bgcolor = bg_color, text_size = table_font)
    table.cell(myTable, 7, 0, 'Dist %', text_color = color.white, bgcolor = bg_color, text_size = table_font)
    
    draw_row(myTable, 1, len1, type1, col1, m1A, m1B, m1C, array.get(rank5(maA), 0), array.get(rank5(maB), 0), array.get(rank5(maC), 0), table_font)
    draw_row(myTable, 2, len2, type2, col2, m2A, m2B, m2C, array.get(rank5(maA), 1), array.get(rank5(maB), 1), array.get(rank5(maC), 1), table_font)
    draw_row(myTable, 3, len3, type3, col3, m3A, m3B, m3C, array.get(rank5(maA), 2), array.get(rank5(maB), 2), array.get(rank5(maC), 2), table_font)
    draw_row(myTable, 4, len4, type4, col4, m4A, m4B, m4C, array.get(rank5(maA), 3), array.get(rank5(maB), 3), array.get(rank5(maC), 3), table_font)
    draw_row(myTable, 5, len5, type5, col5, m5A, m5B, m5C, array.get(rank5(maA), 4), array.get(rank5(maB), 4), array.get(rank5(maC), 4), table_font)


// =========================================================================
// --- SYSTÈME D'ALERTES MULTI-TIMEFRAME (RÉÉCRIT ET SÉCURISÉ) ---
// =========================================================================

grp_al_tf = "Filtres d'Alertes (Timeframes)"
al_tfA = input.bool(false, "Activer alertes sur TF A", group = grp_al_tf)
al_tfB = input.bool(false, "Activer alertes sur TF B", group = grp_al_tf)
al_tfC = input.bool(true,  "Activer alertes sur TF C", group = grp_al_tf)

grp_al_struct = "Filtres d'Alertes (Structure du Marché)"
al_harm  = input.bool(true, "Activer alertes Harmonie (Alignement)", group = grp_al_struct)
al_sqz   = input.bool(true, "Activer alertes Squeeze (Compression)", group = grp_al_struct)
al_cross = input.bool(true, "Activer alertes Golden/Death Cross", group = grp_al_struct)
squeeze_limit = input.float(1.0, "Seuil Squeeze MAs (%)", group = grp_al_struct)

grp_al_ma = "Filtres d'Alertes (Prix ↔ MAs individuelles)"
al_ma1 = input.bool(false, "Surveiller MA 1", group = grp_al_ma)
al_ma2 = input.bool(false, "Surveiller MA 2", group = grp_al_ma)
al_ma3 = input.bool(true,  "Surveiller MA 3", group = grp_al_ma)
al_ma4 = input.bool(false, "Surveiller MA 4", group = grp_al_ma)
al_ma5 = input.bool(true,  "Surveiller MA 5", group = grp_al_ma)

// --- FONCTION MAÎTRESSE : Calcule toute la structure de marché dans son TF d'origine ---
f_evaluate_all_signals(l1, t1, l2, t2, l3, t3, l4, t4, l5, t5, sqz_lim) =>
    // Génération des MAs dans le contexte actuel de la fonction
    m1 = f_ma(src, l1, table_type_eff(t1))
    m2 = f_ma(src, l2, table_type_eff(t2))
    m3 = f_ma(src, l3, table_type_eff(t3))
    m4 = f_ma(src, l4, table_type_eff(t4))
    m5 = f_ma(src, l5, table_type_eff(t5))

    // 1. HARMONIE
    bull = m1 > m2 and m2 > m3 and m3 > m4 and m4 > m5
    bear = m1 < m2 and m2 < m3 and m3 < m4 and m4 < m5
    start_bull = bull and not bull[1]
    start_bear = bear and not bear[1]

    // 2. SQUEEZE
    tmp_arr = array.from(m1, m2, m3, m4, m5)
    array.sort(tmp_arr)
    s0 = array.get(tmp_arr, 0), s1 = array.get(tmp_arr, 1), s2 = array.get(tmp_arr, 2), s3 = array.get(tmp_arr, 3), s4 = array.get(tmp_arr, 4)
    
    sq5 = (s4 - s0) / close * 100
    sq4_a = (s3 - s0) / close * 100, sq4_b = (s4 - s1) / close * 100
    sq3_a = (s2 - s0) / close * 100, sq3_b = (s3 - s1) / close * 100, sq3_c = (s4 - s2) / close * 100
    
    sqz_count = 0
    if sq5 <= sqz_lim
        sqz_count := 5
    else if sq4_a <= sqz_lim or sq4_b <= sqz_lim
        sqz_count := 4
    else if sq3_a <= sqz_lim or sq3_b <= sqz_lim or sq3_c <= sqz_lim
        sqz_count := 3
        
    is_sqz = sqz_count >= 3
    start_sqz = is_sqz and not is_sqz[1]

    // 3. CROISEMENTS
    gc = ta.crossover(m3, m5)
    dc = ta.crossunder(m3, m5)

    // 4. PRICE ACTION (Utilise automatiquement le close/open/high/low du Timeframe supérieur !)
    xu1 = ta.crossover(close, m1), xd1 = ta.crossunder(close, m1)
    ap1 = low <= m1 and close > m1 and open > m1, re1 = high >= m1 and close < m1 and open < m1

    xu2 = ta.crossover(close, m2), xd2 = ta.crossunder(close, m2)
    ap2 = low <= m2 and close > m2 and open > m2, re2 = high >= m2 and close < m2 and open < m2

    xu3 = ta.crossover(close, m3), xd3 = ta.crossunder(close, m3)
    ap3 = low <= m3 and close > m3 and open > m3, re3 = high >= m3 and close < m3 and open < m3

    xu4 = ta.crossover(close, m4), xd4 = ta.crossunder(close, m4)
    ap4 = low <= m4 and close > m4 and open > m4, re4 = high >= m4 and close < m4 and open < m4

    xu5 = ta.crossover(close, m5), xd5 = ta.crossunder(close, m5)
    ap5 = low <= m5 and close > m5 and open > m5, re5 = high >= m5 and close < m5 and open < m5

    // On retourne un "Tuple" massif avec tous les booléens purs et stables
    [start_bull, start_bear, start_sqz, sqz_count, gc, dc, xu1, xd1, ap1, re1, xu2, xd2, ap2, re2, xu3, xd3, ap3, re3, xu4, xd4, ap4, re4, xu5, xd5, ap5, re5]


// --- ENCAPSULATION SECURITY ---
get_tf_data(tf_arg, l1, t1, l2, t2, l3, t3, l4, t4, l5, t5, sqz_lim) =>
    if tf_arg == ''
        f_evaluate_all_signals(l1, t1, l2, t2, l3, t3, l4, t4, l5, t5, sqz_lim)
    else
        request.security(syminfo.tickerid, tf_arg, f_evaluate_all_signals(l1, t1, l2, t2, l3, t3, l4, t4, l5, t5, sqz_lim), lookahead = barmerge.lookahead_off)

// --- RÉCUPÉRATION DES SIGNAUX STABLES ---
[start_bull_A, start_bear_A, start_sqz_A, sqz_c_A, gc_A, dc_A, xUp1_A, xDn1_A, app1_A, rej1_A, xUp2_A, xDn2_A, app2_A, rej2_A, xUp3_A, xDn3_A, app3_A, rej3_A, xUp4_A, xDn4_A, app4_A, rej4_A, xUp5_A, xDn5_A, app5_A, rej5_A] = get_tf_data(tfA, len1, type1, len2, type2, len3, type3, len4, type4, len5, type5, squeeze_limit)

[start_bull_B, start_bear_B, start_sqz_B, sqz_c_B, gc_B, dc_B, xUp1_B, xDn1_B, app1_B, rej1_B, xUp2_B, xDn2_B, app2_B, rej2_B, xUp3_B, xDn3_B, app3_B, rej3_B, xUp4_B, xDn4_B, app4_B, rej4_B, xUp5_B, xDn5_B, app5_B, rej5_B] = get_tf_data(tfB, len1, type1, len2, type2, len3, type3, len4, type4, len5, type5, squeeze_limit)

[start_bull_C, start_bear_C, start_sqz_C, sqz_c_C, gc_C, dc_C, xUp1_C, xDn1_C, app1_C, rej1_C, xUp2_C, xDn2_C, app2_C, rej2_C, xUp3_C, xDn3_C, app3_C, rej3_C, xUp4_C, xDn4_C, app4_C, rej4_C, xUp5_C, xDn5_C, app5_C, rej5_C] = get_tf_data(tfC, len1, type1, len2, type2, len3, type3, len4, type4, len5, type5, squeeze_limit)


// --- DÉCLENCHEUR D'ALERTE SÉCURISÉ ---
f_fire_alerts(is_active, tf_str, tf_label, s_bull, s_bear, s_sqz, sqz_count, gc, dc, xu1, xd1, ap1, re1, xu2, xd2, ap2, re2, xu3, xd3, ap3, re3, xu4, xd4, ap4, re4, xu5, xd5, ap5, re5) =>
    if is_active
        prefix = syminfo.ticker + " [" + tf_label + " : " + tf_str + "] - "
        
        if al_harm and s_bull
            alert(prefix + "🔥 Harmonie Haussière !", alert.freq_once_per_bar_close)
        if al_harm and s_bear
            alert(prefix + "🩸 Harmonie Baissière !", alert.freq_once_per_bar_close)
            
        if al_sqz and s_sqz
            alert(prefix + "🗜️ Squeeze : " + str.tostring(sqz_count) + " MAs compressées à " + str.tostring(squeeze_limit) + "%", alert.freq_once_per_bar_close)
            
        if al_cross and gc
            alert(prefix + "✨ Golden Cross (MA3 ↑ MA5) !", alert.freq_once_per_bar_close)
        if al_cross and dc
            alert(prefix + "💀 Death Cross (MA3 ↓ MA5) !", alert.freq_once_per_bar_close)

        if al_ma1
            if xu1
                alert(prefix + "↗️ Cassure haussière MA1", alert.freq_once_per_bar_close)
            if xd1
                alert(prefix + "↘️ Cassure baissière MA1", alert.freq_once_per_bar_close)
            if ap1
                alert(prefix + "📈 Appui sur MA1", alert.freq_once_per_bar_close)
            if re1
                alert(prefix + "📉 Rejet sous MA1", alert.freq_once_per_bar_close)
        
        if al_ma2
            if xu2
                alert(prefix + "↗️ Cassure haussière MA2", alert.freq_once_per_bar_close)
            if xd2
                alert(prefix + "↘️ Cassure baissière MA2", alert.freq_once_per_bar_close)
            if ap2
                alert(prefix + "📈 Appui sur MA2", alert.freq_once_per_bar_close)
            if re2
                alert(prefix + "📉 Rejet sous MA2", alert.freq_once_per_bar_close)

        if al_ma3
            if xu3
                alert(prefix + "↗️ Cassure haussière MA3", alert.freq_once_per_bar_close)
            if xd3
                alert(prefix + "↘️ Cassure baissière MA3", alert.freq_once_per_bar_close)
            if ap3
                alert(prefix + "📈 Appui sur MA3", alert.freq_once_per_bar_close)
            if re3
                alert(prefix + "📉 Rejet sous MA3", alert.freq_once_per_bar_close)

        if al_ma4
            if xu4
                alert(prefix + "↗️ Cassure haussière MA4", alert.freq_once_per_bar_close)
            if xd4
                alert(prefix + "↘️ Cassure baissière MA4", alert.freq_once_per_bar_close)
            if ap4
                alert(prefix + "📈 Appui sur MA4", alert.freq_once_per_bar_close)
            if re4
                alert(prefix + "📉 Rejet sous MA4", alert.freq_once_per_bar_close)

        if al_ma5
            if xu5
                alert(prefix + "↗️ Cassure haussière MA5", alert.freq_once_per_bar_close)
            if xd5
                alert(prefix + "↘️ Cassure baissière MA5", alert.freq_once_per_bar_close)
            if ap5
                alert(prefix + "📈 Appui sur MA5", alert.freq_once_per_bar_close)
            if re5
                alert(prefix + "📉 Rejet sous MA5", alert.freq_once_per_bar_close)

tfA_str = tfA == "" ? "Actuel" : str.tostring(tfA)
tfB_str = tfB == "" ? "Actuel" : str.tostring(tfB)
tfC_str = tfC == "" ? "Actuel" : str.tostring(tfC)

f_fire_alerts(al_tfA, tfA_str, "TF A", start_bull_A, start_bear_A, start_sqz_A, sqz_c_A, gc_A, dc_A, xUp1_A, xDn1_A, app1_A, rej1_A, xUp2_A, xDn2_A, app2_A, rej2_A, xUp3_A, xDn3_A, app3_A, rej3_A, xUp4_A, xDn4_A, app4_A, rej4_A, xUp5_A, xDn5_A, app5_A, rej5_A)
f_fire_alerts(al_tfB, tfB_str, "TF B", start_bull_B, start_bear_B, start_sqz_B, sqz_c_B, gc_B, dc_B, xUp1_B, xDn1_B, app1_B, rej1_B, xUp2_B, xDn2_B, app2_B, rej2_B, xUp3_B, xDn3_B, app3_B, rej3_B, xUp4_B, xDn4_B, app4_B, rej4_B, xUp5_B, xDn5_B, app5_B, rej5_B)
f_fire_alerts(al_tfC, tfC_str, "TF C", start_bull_C, start_bear_C, start_sqz_C, sqz_c_C, gc_C, dc_C, xUp1_C, xDn1_C, app1_C, rej1_C, xUp2_C, xDn2_C, app2_C, rej2_C, xUp3_C, xDn3_C, app3_C, rej3_C, xUp4_C, xDn4_C, app4_C, rej4_C, xUp5_C, xDn5_C, app5_C, rej5_C)

// =========================================================================
// --- MARQUAGES VISUELS SÉPARÉS PAR TIMEFRAME ---
// =========================================================================

plotshape(al_cross and gc_A, title = 'Golden Cross TF A', style = shape.triangleup, location = location.belowbar, color = color.new(color.teal, 100),   size = size.small,  text = "A", textcolor = color.new(color.white, 90))
plotshape(al_cross and gc_B, title = 'Golden Cross TF B', style = shape.triangleup, location = location.belowbar, color = color.new(color.blue, 100),   size = size.normal, text = "B", textcolor = color.new(color.white, 30))
plotshape(al_cross and gc_C, title = 'Golden Cross TF C', style = shape.triangleup, location = location.belowbar, color = color.new(color.purple,100),  size = size.large,  text = "C", textcolor = color.white)

plotshape(al_cross and dc_A, title = 'Death Cross TF A', style = shape.triangledown, location = location.abovebar, color = color.new(color.maroon, 100), size = size.small,  text = "A", textcolor = color.new(color.white, 90))
plotshape(al_cross and dc_B, title = 'Death Cross TF B', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 100),    size = size.normal, text = "B", textcolor = color.new(color.white, 30))
plotshape(al_cross and dc_C, title = 'Death Cross TF C', style = shape.triangledown, location = location.abovebar, color = color.new(color.orange, 100),  size = size.large,  text = "C", textcolor = color.white)
````
