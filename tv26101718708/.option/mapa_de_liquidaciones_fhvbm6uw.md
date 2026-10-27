# Mapa de Liquidaciones

- url: https://www.tradingview.com/script/fHvBm6UW/
- type: indicator
- pine_id: PUB;1a987e2973c44fd789ad673fc4610636
- version: 4.0

## Description

MAPA DE LIQUIDACIONES

Indicador overlay que estima zonas de liquidación de posiciones
apalancadas (longs y shorts) mediante un mapa de calor.

FUNCIONAMIENTO
Calcula niveles teóricos por barra:

Long → precio × (1 − 1/leverage)
Short → precio × (1 + 1/leverage)

El volumen u Open Interest se acumula en cada nivel, mostrando
la densidad de posiciones en riesgo.

DATOS

Usa Open Interest real si está disponible
Si no, utiliza volumen como aproximación
Posibilidad de definir símbolo OI manual

COLORES
Verde → baja concentración
Amarillo→ media
Rojo → alta (nivel relevante)

Cada lado (long/short) se normaliza de forma independiente.

PARÁMETROS

Apalancamientos: 10x, 25x, 50x, 100x
Filas del mapa (resolución)
Ancho (barras)
Lookback histórico

LIMITACIÓN
Estimación basada en datos de TradingView.
No usa liquidaciones reales de exchanges.

## Source Code

````pine
//@version=6
indicator("Mapa de Liquidaciones", overlay=true, max_bars_back=5000, max_boxes_count=5000, max_labels_count=5)

// ── Grupos ─────────────────────────────────────────────────────────────────
grp_data = "Fuente de Datos"
grp_lev  = "Apalancamientos"
grp_vis  = "Visualización"

// ── Inputs ───────────────────────────────────────────────────────────────────
i_oi_sym = input.string("",
  title   = "Símbolo Open Interest (vacío = auto-detect)",
  tooltip = "Deja vacío para detección automática.\n\n• En futuros/perpetuos: se intenta usar Open Interest real.\n• En spot: se usa siempre Volumen + Precio como estimación.\n\nPara especificar manualmente introduce el símbolo OI.\nEjemplo: BINANCE:BTCUSDT.P_OI\n\nLa fuente activa se muestra como etiqueta en el mapa.",
  group   = grp_data)

i_lev1 = input.float(10,  "Apalancamiento A (x)", minval=2, maxval=5000, group=grp_lev)
i_lev2 = input.float(25,  "Apalancamiento B (x)", minval=2, maxval=5000, group=grp_lev)
i_lev3 = input.float(50,  "Apalancamiento C (x)", minval=2, maxval=5000, group=grp_lev)
i_lev4 = input.float(100, "Apalancamiento D (x)", minval=2, maxval=5000, group=grp_lev)

i_buckets  = input.int(40,  "Filas del mapa",    minval=10, maxval=80, group=grp_vis)
i_width    = input.int(50,  "Ancho (barras)",     minval=5,  maxval=100, group=grp_vis)
i_lookback = input.int(5000, "Barras a analizar",  minval=50, maxval=5000, group=grp_vis)

// ── Detectar tipo de instrumento ──────────────────────────────────────────────
bool is_futures = syminfo.type == "futures" or syminfo.type == "swap" or str.contains(str.lower(syminfo.ticker), "perp") or str.contains(syminfo.ticker, ".P")

// ── Datos de precio ───────────────────────────────────────────────────────────
// Acceso directo — evita request.security en el mismo símbolo/timeframe (causa error en _DLY y futuros ICE)
float real_close = close
float real_high  = high
float real_low   = low
float real_vol   = volume

// ── Open Interest: solo cuando el usuario especifica el símbolo ───────────────
// Sin request.security redundante — si no hay símbolo OI, usa volumen directamente
float raw_oi = str.length(i_oi_sym) > 0 ? request.security(i_oi_sym, timeframe.period, close, lookahead=barmerge.lookahead_off) : volume

// ── Gradiente Verde → Amarillo → Rojo ────────────────────────────────────────
f_heat(float intensity) =>
    float i = math.max(0.0, math.min(1.0, intensity))
    int r   = i < 0.5 ? int(i * 2.0 * 255.0) : 255
    int g   = i < 0.5 ? int(180.0 + i * 2.0 * 75.0) : int(255.0 * (1.0 - (i - 0.5) * 2.0))
    int b   = 0
    int t   = int((1.0 - i) * 80.0)
    color.rgb(r, g, b, t)

// ─────────────────────────────────────────────────────────────────────────────
start_time = chart.left_visible_bar_time

var array<box>   liq_boxes  = array.new_box()
var array<label> liq_labels = array.new_label()

if barstate.islast
    for bx in liq_boxes
        box.delete(bx)
    array.clear(liq_boxes)
    for lb in liq_labels
        label.delete(lb)
    array.clear(liq_labels)

    cur_price = real_close

    // ── Detectar si OI tiene datos válidos (solo cuando usuario especificó símbolo) ──
    float oi_sum  = 0.0
    int   check_n = math.min(30, bar_index)
    if is_futures and str.length(i_oi_sym) > 0
        for i = 0 to check_n - 1
            oi_sum += nz(raw_oi[i], 0.0)
    bool using_oi = is_futures and str.length(i_oi_sym) > 0 and oi_sum > 0.0

    // ── Rango de precios ──────────────────────────────────────────────────────
    int   n     = math.min(i_lookback, bar_index)
    float p_min = cur_price
    float p_max = cur_price

    for i = 0 to n - 1
        if not na(start_time) and time[i] >= start_time
            if not na(real_low[i])
                p_min := math.min(p_min, real_low[i])
            if not na(real_high[i])
                p_max := math.max(p_max, real_high[i])

    float rng = p_max - p_min
    if rng <= 0.0
        rng := p_max * 0.01
    p_min -= rng * 0.15
    p_max += rng * 0.15
    float bkt_h = (p_max - p_min) / i_buckets

    // ── Acumular liquidaciones ─────────────────────────────────────────────────
    array<float> long_arr  = array.new_float(i_buckets, 0.0)
    array<float> short_arr = array.new_float(i_buckets, 0.0)
    array<float> levs      = array.from(i_lev1, i_lev2, i_lev3, i_lev4)

    for i = 0 to n - 1
        if not na(start_time) and time[i] >= start_time
            if not na(real_close[i])
                float p = real_close[i]
                float w = using_oi ? nz(raw_oi[i], 0.0) : nz(real_vol[i], 0.0)
                if w > 0.0
                    for lev in levs
                        float liq_l = p * (1.0 - 1.0 / lev)
                        float liq_s = p * (1.0 + 1.0 / lev)
                        if liq_l < cur_price and liq_l >= p_min and liq_l < p_max
                            int bk = math.min(int((liq_l - p_min) / bkt_h), i_buckets - 1)
                            array.set(long_arr, bk, array.get(long_arr, bk) + w)
                        if liq_s > cur_price and liq_s >= p_min and liq_s < p_max
                            int bk = math.min(int((liq_s - p_min) / bkt_h), i_buckets - 1)
                            array.set(short_arr, bk, array.get(short_arr, bk) + w)

    // ── Normalización independiente por zona ──────────────────────────────────
    float max_l = math.max(nz(array.max(long_arr),  0.0), 1.0)
    float max_s = math.max(nz(array.max(short_arr), 0.0), 1.0)

    // ── Sub-filas para degradado suave ────────────────────────────────────────
    int sub_n = math.min(5, int(490 / (i_buckets * 2)))

    int   x1    = bar_index + 2
    int   x2    = bar_index + 2 + i_width
    float sub_h = bkt_h / float(sub_n)

    for bk = 0 to i_buckets - 1
        float y_lo = p_min + float(bk)     * bkt_h
        float y_hi = p_min + float(bk + 1) * bkt_h
        float lv   = array.get(long_arr,  bk)
        float sv   = array.get(short_arr, bk)

        float lv_prev = bk > 0             ? array.get(long_arr,  bk - 1) : lv
        float lv_next = bk < i_buckets - 1 ? array.get(long_arr,  bk + 1) : lv
        float sv_prev = bk > 0             ? array.get(short_arr, bk - 1) : sv
        float sv_next = bk < i_buckets - 1 ? array.get(short_arr, bk + 1) : sv

        float lv_bot = (lv_prev + lv) * 0.5
        float lv_top = (lv + lv_next) * 0.5
        float sv_bot = (sv_prev + sv) * 0.5
        float sv_top = (sv + sv_next) * 0.5

        for j = 0 to sub_n - 1
            float t        = (float(j) + 0.5) / float(sub_n)
            float sub_y_lo = y_lo + float(j)     * sub_h
            float sub_y_hi = y_lo + float(j + 1) * sub_h

            if lv > 0.0 and y_hi <= cur_price
                float inten = math.max(0.0, (lv_bot + t * (lv_top - lv_bot)) / max_l)
                color col   = f_heat(inten)
                array.push(liq_boxes, box.new(x1, sub_y_hi, x2, sub_y_lo,
                  bgcolor=col, border_color=color.new(color.black, 100), border_width=0))

            if sv > 0.0 and y_lo >= cur_price
                float inten = math.max(0.0, (sv_bot + t * (sv_top - sv_bot)) / max_s)
                color col   = f_heat(inten)
                array.push(liq_boxes, box.new(x1, sub_y_hi, x2, sub_y_lo,
                  bgcolor=col, border_color=color.new(color.black, 100), border_width=0))

    // ── Línea de precio actual ─────────────────────────────────────────────────
    array.push(liq_boxes, box.new(x1, cur_price * 1.0001, x2, cur_price * 0.9999,
      bgcolor=color.new(color.white, 40), border_color=color.new(color.white, 60)))

    // ── Etiqueta: tipo de instrumento + fuente de datos ───────────────────────
    string src_txt = not is_futures ? "Spot — Vol+Precio (estimado)" : using_oi ? "Futuros — Open Interest (real)" : "Futuros — Vol+Precio (estimado)"
    array.push(liq_labels, label.new(x1, p_max,
      "LIQ MAP  |  " + src_txt,
      color     = color.new(color.gray, 20),
      textcolor = color.white,
      size      = size.tiny,
      style     = label.style_label_lower_right))
````
