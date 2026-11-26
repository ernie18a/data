# Global Liquidity Index by EBB

- url: https://www.tradingview.com/script/sabWQJla/
- type: indicator
- pine_id: PUB;b36fc65e62eb44a78d0a3579e09458e1
- version: 1.0

## Description

v1.1 - Fix MOVE adjustment. GLI bruto se dibuja detrás como referencia naranja y GLI efectivo se dibuja encima como línea principal. TVC:MOVE usa ignore_invalid_symbol=true para no romper la serie si MOVE no carga. Metodología, inputs y tabla se mantienen sin cambios respecto a v1.0.

## Source Code

````pine
// Cambios respecto a v1.0:
//   - Fix MOVE: la linea bruta se dibuja detras y la efectiva encima.
//   - MOVE usa ignore_invalid_symbol para no romper la serie principal si TVC:MOVE no carga.
//   - Etiquetas explicitas: GLI efectivo (post-MOVE adj) y GLI bruto (pre-MOVE adj).
//   - Mantiene metodologia, inputs y tabla de v1.0.

//@version=6
indicator(title = 'Global Liquidity Index by EBB', shorttitle = 'GLI by EBB', overlay = true, scale = scale.left)

// ═══════════════════════════════════════════════════════════════
// GRUPO 1 — BANCOS CENTRALES
// ═══════════════════════════════════════════════════════════════
fed_on = input.bool(true, 'FED (Federal Reserve)',        group = 'Bancos Centrales')
tga_on = input.bool(true, 'TGA (Treasury General Acct)', group = 'Bancos Centrales')
rrp_on = input.bool(true, 'RRP (Reverse Repo Fed)',       group = 'Bancos Centrales')
ecb_on = input.bool(true, 'ECB (Banco Central Europeo)',  group = 'Bancos Centrales')
pbc_on = input.bool(true, 'PBC (Banco Popular China)',    group = 'Bancos Centrales')
boj_on = input.bool(true, 'BOJ (Banco de Japon)',         group = 'Bancos Centrales')
ocb_on = input.bool(true, 'Otros Bancos Centrales',       group = 'Bancos Centrales')

// ═══════════════════════════════════════════════════════════════
// GRUPO 2 — M2 (MASA MONETARIA)
// Master switch OFF = modo solo bancos centrales
// ═══════════════════════════════════════════════════════════════
m2_all = input.bool(true, 'Activar todos los M2  (OFF = solo bancos centrales)', group = 'M2 — Masa Monetaria')
m2_usa = input.bool(true, 'USM2 (EEUU)',   group = 'M2 — Masa Monetaria')
m2_eu  = input.bool(true, 'EUM2 (Europa)', group = 'M2 — Masa Monetaria')
m2_cn  = input.bool(true, 'CNM2 (China)',  group = 'M2 — Masa Monetaria')
m2_jp  = input.bool(true, 'JPM2 (Japon)',  group = 'M2 — Masa Monetaria')
m2_ot  = input.bool(true, 'Otros M2',      group = 'M2 — Masa Monetaria')

// ═══════════════════════════════════════════════════════════════
// GRUPO 3 — SEÑAL
//
// SMA: suaviza la linea para reducir el ruido de publicaciones mensuales.
//   Valor recomendado: 4-8. Con 0 no hay suavizado.
//
// ROC (Rate of Change — velocidad de cambio):
//   0 = modo nivel: muestra la suma de liquidez en billones USD.
//   >0 = modo velocidad: muestra la variacion % respecto a N barras atras.
//   Referencia: 60 barras ~= 3 meses en chart diario (horizonte trimestral).
//   Nota: valores bajos como 1-5 generan ruido extremo, evitar.
//
// Fast / Slow: longitudes de las medias que generan la senal BULL/BEAR.
//   Con datos que se publican mensualmente, 60/120 (~3m/6m) reduce
//   las falsas senales causadas por movimientos de divisas diarios.
// ═══════════════════════════════════════════════════════════════
sma_raw = input.int(0,   'Suavizado SMA  (0 = sin suavizado · recomendado: 4-8)',
     minval = 0, group = 'Señal')

roc_len = input.int(0,   'ROC — velocidad de cambio  (0 = nivel absoluto · 60 = variacion trimestral)',
     minval = 0, group = 'Señal')

fast_l  = input.int(60,  'Longitud media rapida  (senal BULL/BEAR)',
     minval = 1, group = 'Señal')

slow_l  = input.int(120, 'Longitud media lenta   (senal BULL/BEAR)',
     minval = 2, group = 'Señal')

corr_p  = input.string('3M', 'Periodo de correlacion GLI ↔ ticker',
     options = ['3M','6M','9M','1Y','3Y','5Y','10Y'], group = 'Señal')

// ═══════════════════════════════════════════════════════════════
// GRUPO 4 — OFFSET  (desfase GLI vs precio, en semanas)
//
// + = el GLI se desplaza a la derecha en el chart:
//     lo que ves en la barra actual es el GLI de N semanas atras.
//     Usalo para validar si el GLI lidera al precio.
//     Referencia Howell: ~13 semanas para BTC / ETH / SOL.
//
// - = el GLI se desplaza a la izquierda (el precio lidera al GLI).
//
// Cada semana = 5 barras (dias habiles).
// Ejemplo: offset +13 -> GLI desplazado 65 barras a la derecha.
// ═══════════════════════════════════════════════════════════════
off_w = input.int(0,
     'Semanas de offset  [+ GLI lidera precio / - precio lidera GLI]  |  Howell cripto: +13  |  rango -20 a +20',
     minval = -20, maxval = 20, step = 1, group = 'Offset — desfase GLI / precio')

// ═══════════════════════════════════════════════════════════════
// GRUPO 5 — AJUSTES DE CALIDAD
//
// AJUSTE MOVE (TVC:MOVE):
//   El MOVE mide la volatilidad implicita de los bonos del Tesoro.
//   Cuando sube, los haircuts en repo suben y la liquidez efectiva
//   es menor que la bruta (mecanismo Howell).
//   Con ajuste ON: linea amarilla = GLI efectivo · naranja = GLI bruto.
//   Umbrales canonicos: < 120 verde · 120-140 ambar · > 140 rojo.
//
// REPO STRESS (SOFR - Fed Funds):
//   Tension en el mercado interbancario de repos.
//   Solo visible en la tabla esquina inferior derecha.
//   No modifica la linea GLI.
//   Umbrales: > 5bp ambar  ·  > 15bp rojo.
// ═══════════════════════════════════════════════════════════════
move_on = input.bool(false, 'Activar ajuste de calidad MOVE  (ticker: TVC:MOVE)', group = 'Ajustes de calidad')
repo_on = input.bool(true,  'Mostrar estres repo SOFR-FF en tabla',               group = 'Ajustes de calidad')

// ═══════════════════════════════════════════════════════════════
// DATOS — BANCOS CENTRALES
// ═══════════════════════════════════════════════════════════════
d_fed  = fed_on ? request.security('ECONOMICS:USCBBS',                  'D', close, currency = currency.USD) : 0.0
d_rrp  = rrp_on ? request.security('FRED:RRPONTSYD',                    'D', close, currency = currency.USD) : 0.0
d_tga  = tga_on ? request.security('FRED:WTREGEN',                      'D', close, currency = currency.USD) : 0.0
d_ecb  = ecb_on ? request.security('ECONOMICS:EUCBBS * FX_IDC:EURUSD',  'D', close, currency = currency.USD) : 0.0
d_pbc  = pbc_on ? request.security('ECONOMICS:CNCBBS * FX_IDC:CNYUSD',  'D', close, currency = currency.USD) : 0.0
d_boj  = boj_on ? request.security('ECONOMICS:JPCBBS * FX_IDC:JPYUSD',  'D', close, currency = currency.USD) : 0.0
d_boe  = ocb_on ? request.security('ECONOMICS:GBCBBS * FX_IDC:GBPUSD',  'D', close, currency = currency.USD) : 0.0
d_boc  = ocb_on ? request.security('ECONOMICS:CACBBS * FX_IDC:CADUSD',  'D', close, currency = currency.USD) : 0.0
d_rba  = ocb_on ? request.security('ECONOMICS:AUCBBS * FX_IDC:AUDUSD',  'D', close, currency = currency.USD) : 0.0
d_rbi  = ocb_on ? request.security('ECONOMICS:INCBBS * FX_IDC:INRUSD',  'D', close, currency = currency.USD) : 0.0
d_snb  = ocb_on ? request.security('ECONOMICS:CHCBBS * FX_IDC:CHFUSD',  'D', close, currency = currency.USD) : 0.0
d_cbr  = ocb_on ? request.security('ECONOMICS:RUCBBS * FX_IDC:RUBUSD',  'D', close, currency = currency.USD) : 0.0
d_bcb  = ocb_on ? request.security('ECONOMICS:BRCBBS * FX_IDC:BRLUSD',  'D', close, currency = currency.USD) : 0.0
d_bok  = ocb_on ? request.security('ECONOMICS:KRCBBS * FX_IDC:KRWUSD',  'D', close, currency = currency.USD) : 0.0
d_nz   = ocb_on ? request.security('ECONOMICS:NZCBBS * FX_IDC:NZDUSD',  'D', close, currency = currency.USD) : 0.0
d_se   = ocb_on ? request.security('ECONOMICS:SECBBS * FX_IDC:SEKUSD',  'D', close, currency = currency.USD) : 0.0
d_my   = ocb_on ? request.security('ECONOMICS:MYCBBS * FX_IDC:MYRUSD',  'D', close, currency = currency.USD) : 0.0

// ═══════════════════════════════════════════════════════════════
// DATOS — M2
// ═══════════════════════════════════════════════════════════════
m2_usa_v = (m2_all and m2_usa) ? request.security('ECONOMICS:USM2',                 'D', close, currency = currency.USD) : 0.0
m2_eu_v  = (m2_all and m2_eu)  ? request.security('ECONOMICS:EUM2 * FX_IDC:EURUSD', 'D', close, currency = currency.USD) : 0.0
m2_cn_v  = (m2_all and m2_cn)  ? request.security('ECONOMICS:CNM2 * FX_IDC:CNYUSD', 'D', close, currency = currency.USD) : 0.0
m2_jp_v  = (m2_all and m2_jp)  ? request.security('ECONOMICS:JPM2 * FX_IDC:JPYUSD', 'D', close, currency = currency.USD) : 0.0
m2_uk_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:GBM2 * FX_IDC:GBPUSD', 'D', close, currency = currency.USD) : 0.0
m2_ca_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:CAM2 * FX_IDC:CADUSD', 'D', close, currency = currency.USD) : 0.0
m2_au_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:AUM3 * FX_IDC:AUDUSD', 'D', close, currency = currency.USD) : 0.0
m2_in_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:INM2 * FX_IDC:INRUSD', 'D', close, currency = currency.USD) : 0.0
m2_ch_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:CHM2 * FX_IDC:CHFUSD', 'D', close, currency = currency.USD) : 0.0
m2_ru_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:RUM2 * FX_IDC:RUBUSD', 'D', close, currency = currency.USD) : 0.0
m2_br_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:BRM2 * FX_IDC:BRLUSD', 'D', close, currency = currency.USD) : 0.0
m2_kr_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:KRM2 * FX_IDC:KRWUSD', 'D', close, currency = currency.USD) : 0.0
m2_mx_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:MXM2 * FX_IDC:MXNUSD', 'D', close, currency = currency.USD) : 0.0
m2_id_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:IDM2 * FX_IDC:IDRUSD', 'D', close, currency = currency.USD) : 0.0
m2_za_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:ZAM2 * FX_IDC:ZARUSD', 'D', close, currency = currency.USD) : 0.0
m2_my_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:MYM2 * FX_IDC:MYRUSD', 'D', close, currency = currency.USD) : 0.0
m2_se_v  = (m2_all and m2_ot)  ? request.security('ECONOMICS:SEM2 * FX_IDC:SEKUSD', 'D', close, currency = currency.USD) : 0.0

// ═══════════════════════════════════════════════════════════════
// TOTAL BRUTO (en billones USD)
// ═══════════════════════════════════════════════════════════════
cb_sum    = d_fed - d_rrp - d_tga + d_ecb + d_pbc + d_boj + d_boe + d_boc + d_rba + d_rbi + d_snb + d_cbr + d_bcb + d_bok + d_nz + d_se + d_my
m2_sum    = m2_usa_v + m2_eu_v + m2_cn_v + m2_jp_v + m2_uk_v + m2_ca_v + m2_au_v + m2_in_v  + m2_ch_v + m2_ru_v + m2_br_v + m2_kr_v + m2_mx_v + m2_id_v + m2_za_v + m2_my_v + m2_se_v
total_raw = (cb_sum + m2_sum) / 1e12

// ═══════════════════════════════════════════════════════════════
// AJUSTE MOVE
// Parametros internos fijos:
//   base = 100 · penalizacion max = 30% · sensibilidad = 500
//   -> MOVE 120 -> -4% · MOVE 140 -> -8% · MOVE 200 -> -20%
// ═══════════════════════════════════════════════════════════════
move_val_raw = request.security('TVC:MOVE', 'D', close, ignore_invalid_symbol = true)
move_val     = move_on ? move_val_raw : na
move_factor  = (move_on and not na(move_val_raw)) ? math.max(0.70, 1.0 - math.max(0.0, move_val_raw - 100.0) / 500.0) : 1.0
total_final  = total_raw * move_factor

// ═══════════════════════════════════════════════════════════════
// PROCESAMIENTO DE SEÑAL
// ═══════════════════════════════════════════════════════════════
sma_len  = sma_raw == 0 ? 1 : sma_raw
off_bars = off_w * 5    // 1 semana = 5 barras (dias habiles)

// Serie principal (ajustada por MOVE si ON)
s_final   = ta.sma(total_final, sma_len)
roc_final = roc_len == 0 ? s_final : ta.sma(ta.roc(total_final, roc_len), sma_len)

// Serie bruta de referencia (naranja, visible cuando MOVE ON)
s_raw     = ta.sma(total_raw, sma_len)
roc_raw   = roc_len == 0 ? s_raw : ta.sma(ta.roc(total_raw, roc_len), sma_len)

// ═══════════════════════════════════════════════════════════════
// TENDENCIA — cruce EMA rapida/lenta
// ═══════════════════════════════════════════════════════════════
ma_fast = ta.ema(s_final, fast_l)
ma_slow = ta.ema(s_final, slow_l)

bull    = ma_fast > ma_slow
bear    = ma_fast < ma_slow
is_bull = bear[1] and bull
is_bear = bull[1] and bear

// ═══════════════════════════════════════════════════════════════
// CORRELACION GLI ↔ TICKER ACTIVO
// ═══════════════════════════════════════════════════════════════
is_crypto = syminfo.type == 'crypto'
td        = is_crypto ? 30 : 21

int c_bars = td * 3
if corr_p == '6M'
    c_bars := td * 6
else if corr_p == '9M'
    c_bars := td * 9
else if corr_p == '1Y'
    c_bars := td * 12
else if corr_p == '3Y'
    c_bars := td * 36
else if corr_p == '5Y'
    c_bars := td * 60
else if corr_p == '10Y'
    c_bars := td * 120

abs_ob  = math.abs(off_bars)
gli_c   = off_bars > 0 ? roc_final[abs_ob] : roc_final
p_base  = ta.sma(close, sma_len)
roc_p   = roc_len == 0 ? p_base : ta.sma(ta.roc(close, roc_len), sma_len)
price_c = off_bars < 0 ? roc_p[abs_ob] : roc_p
corr_v  = ta.correlation(gli_c, price_c, c_bars)

// ═══════════════════════════════════════════════════════════════
// REPO STRESS — SOFR vs Fed Funds
// Umbrales fijos: ambar > 5bp · rojo > 15bp
// ═══════════════════════════════════════════════════════════════
sofr_v      = repo_on ? request.security('FRED:SOFR', 'D', close) : na
ff_v        = repo_on ? request.security('FRED:DFF',  'D', close) : na
repo_spread = (not na(sofr_v) and not na(ff_v)) ? sofr_v - ff_v : na
repo_red    = not na(repo_spread) and repo_spread > 0.15
repo_amb    = not na(repo_spread) and repo_spread > 0.05 and not repo_red
repo_ok     = not na(repo_spread) and repo_spread <= 0.05

// ═══════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════

// Linea bruta de referencia: se pinta primero para no tapar la linea efectiva.
// Si ambas lineas coinciden, el ajuste MOVE es minimo (MOVE bajo).
// Si se separan, el MOVE esta elevado y la diferencia es la penalizacion.
plot(move_on ? roc_raw : na, 'GLI bruto (pre-MOVE adj)',
     color = color.new(color.orange, 55), linewidth = 2, offset = off_bars)

// Linea principal: GLI ajustado por MOVE cuando el ajuste esta activo.
plot(roc_final, 'GLI efectivo (post-MOVE adj)', color = color.yellow, linewidth = 2, offset = off_bars)

// ═══════════════════════════════════════════════════════════════
// TABLA (esquina inferior derecha)
// ═══════════════════════════════════════════════════════════════
var table t = table.new(position.bottom_right, 1, 4, border_width = 1)

// Fila 0 — Tendencia GLI (BULL / BEAR)
table.cell(t, 0, 0,
     text       = bull ? '▲ BULL' : '▼ BEAR',
     width      = 13,
     text_color = color.white,
     bgcolor    = bull ? color.new(color.green, 20) : color.new(color.red, 20))

// Fila 1 — Correlacion GLI ↔ ticker activo
table.cell(t, 0, 1,
     text       = 'r ' + str.tostring(corr_v, '#.##'),
     width      = 13,
     text_color = color.white,
     bgcolor    = corr_v > 0.7  ? color.new(color.green, 20) :
                  corr_v < -0.7 ? color.new(color.red,   20) : color.gray)

// Fila 2 — MOVE: valor actual + penalizacion aplicada (si adj ON)
move_pct  = move_on and not na(move_val) ? math.round((1.0 - move_factor) * 100) : 0
move_text = move_on and not na(move_val)
     ? 'MOVE ' + str.tostring(math.round(move_val)) +
       (move_pct > 0 ? ' -' + str.tostring(move_pct) + '%' : ' -0%')
     : 'MOVE —'
move_bg = move_on and not na(move_val)
     ? (move_val > 140 ? color.new(color.red,   20) :
        move_val > 120 ? color.new(#d97706,      20) :
                         color.new(color.green,  20))
     : color.gray

table.cell(t, 0, 2, text = move_text, width = 13, text_color = color.white, bgcolor = move_bg)

// Fila 3 — Repo stress SOFR-FF en basis points
repo_text = repo_on and not na(repo_spread)
     ? 'REPO ' + str.tostring(math.round(repo_spread * 100, 1)) + 'bp'
     : 'REPO —'
repo_bg = repo_on
     ? (repo_red ? color.new(color.red,   20) :
        repo_amb ? color.new(#d97706,      20) :
        repo_ok  ? color.new(color.green,  20) : color.gray)
     : color.gray

table.cell(t, 0, 3, text = repo_text, width = 13, text_color = color.white, bgcolor = repo_bg)

// ═══════════════════════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════════════════════
alertcondition(is_bull,
     'GLI — cruce alcista',
     'GLI: EMA rapida cruza EMA lenta al alza -> tendencia BULL')

alertcondition(is_bear,
     'GLI — cruce bajista',
     'GLI: EMA rapida cruza EMA lenta a la baja -> tendencia BEAR')

alertcondition(repo_on and repo_red and not repo_red[1],
     'Repo stress — ROJO (>15bp)',
     'SOFR-FF supera 15bp: estres repo activo')

alertcondition(repo_on and repo_amb and not repo_amb[1],
     'Repo stress — AMBAR (>5bp)',
     'SOFR-FF supera 5bp: vigilar repo')

alertcondition(move_on and not na(move_val) and move_val > 140.0 and move_val[1] <= 140.0,
     'MOVE > 140 — rojo canonico',
     'MOVE cruza 140 al alza: colateral bajo presion')

alertcondition(move_on and not na(move_val) and move_val < 120.0 and move_val[1] >= 120.0,
     'MOVE < 120 — sale zona ambar',
     'MOVE vuelve por debajo de 120: presion sobre colateral reduciendose')
````
