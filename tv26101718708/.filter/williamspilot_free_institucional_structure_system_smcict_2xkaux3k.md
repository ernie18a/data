# Williamspilot free -  institucional structure system (SMC/ICT)

- url: https://www.tradingview.com/script/2XKaUx3K-Williamspilot-free-institucional-structure-system-SMC-ICT/
- type: indicator
- pine_id: PUB;c34fb3771ad546ecab9c56bdb8281eff
- version: 1.0

## Description

**Williamspilot Free — Institutional Market Structure Reading System**

Free indicator based on Williamspilot®'s institutional methodology. Built for traders who want to read market structure clearly, without cluttering the chart.

**Includes:**

▸ **Premium / Equilibrium / Discount zones** with lines and exact price labels at the right edge of the chart
▸ **Market structure**: automatic HH / LH / HL / LL with color coding (green bullish, red bearish)
▸ **BOS** (Break of Structure) and **CHoCH** (Change of Character) with horizontal line connecting swing → break candle
▸ **Previous levels**: PDH, PDL, PWH, PWL with exact value at the right edge
▸ **Fair Value Gaps (FVG)** bullish and bearish with automatic mitigation
▸ **Info table** showing current zone, structure state, last event, and timeframe
▸ **Configurable alerts**: BOS/CHoCH breaks, new FVGs, PDH/PDL crosses, Premium or Discount zone entries

**How to use:**

1. Add to any symbol and timeframe (recommended: 5m to 1h on futures, forex, indices)
2. Identify the current zone from the table (Premium / EQ / Discount)
3. Wait for a BOS or CHoCH as institutional direction confirmation
4. Use FVGs and previous levels (PDH/PDL) as entry zones and targets

**Tips:**

- On low timeframes (1m, 3m) FVGs mitigate quickly and barely show. Use 5m-1h for best results.
- If too many swing labels (HH/LH/HL/LL) saturate the chart, increase "Sensibilidad del pivote" from 10 to 15-20.
- Default zone calculation is "Lookback 50 bars". For session-based zones (D/W/M), change in settings.

**About the methodology:**

Williamspilot Free is the introductory version of a broader institutional reading system. The full methodology includes institutional filters (intention, volume, minimum displacement), Order Blocks, HTF (High Timeframe) reading, flow dashboard, and an Institutional Notebook. More info at **williamspilot.com**

⚠ **Disclaimer:** This indicator is for educational purposes. Trading involves risk of loss. It does not constitute financial advice or an investment recommendation. Past results do not guarantee future results. Each user is responsible for their own trading decisions. ```

## Source Code

````pine
//@version=5
indicator("Williamspilot Free — Zonas + Estructura + FVG", shorttitle="WP Free", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================================
//  WILLIAMSPILOT FREE v2.2
//  Indicador institucional: zonas + estructura + niveles previos + FVG
//  williamspilot.com
//
//  CAMBIOS v2.2:
//   - Premium / EQ / Discount ahora tienen LÍNEAS + ETIQUETAS con precio
//     en el borde derecho (antes solo el fill, no se veía claro).
//     Premium: línea sólida roja + label "PREMIUM 7565.50"
//     EQ:      línea dashed púrpura + label "EQ 7560.00"
//     Discount: línea sólida verde + label "DISCOUNT 7554.50"
//
//  CAMBIOS v2.1 (look profesional con cajas):
//   - HH/LH/HL/LL ahora son CAJAS con fondo coloreado (estilo v3.8)
//     Texto blanco sobre verde/rojo según dirección
//   - BOS/CHoCH también son CAJAS con fondo coloreado, en el MEDIO de la línea
//     Texto blanco sobre verde/rojo/naranja
//   - Offsets unificados a 0.15 × ATR para ambos: "cerca pero no pegado"
//   - Las cajas evitan el problema de v2.0 donde la línea atravesaba el texto
//
//  CAMBIOS v2.0:
//   - struct_offset reducido a 0.15 × ATR
//
//  CAMBIOS v1.9:
//   - Texto "bos"/"choch" se coloca en el MEDIO de la línea horizontal
//
//  CAMBIOS v1.8:
//   - BOS/CHoCH ahora son solo texto (sin caja), igual que HH/LH/HL/LL
//   - Texto en minúscula ("bos", "choch") para coherencia con el resto
//   - Color del texto: verde (BOS alcista), rojo (BOS bajista), naranja (CHoCH)
//   - Conservan el offset (0.5 × ATR) para no tapar HH/LH/HL/LL
//
//  CAMBIOS v1.7:
//   - Cajas BOS/CHoCH con offset chico (0.5 × ATR) para no tapar
//     el texto HH/LH/HL/LL. La línea queda exactamente en el swing.
//
//  CAMBIOS v1.6:
//   - Bloque de detección BOS/CHoCH portado COMPLETO del WP All-in-One v3.8
//
//  CAMBIOS v1.4 (separación visual):
//   - HH/LH/HL/LL ahora flotan con offset chico (0.25 × ATR) — no pegados a la vela
//   - BOS/CHoCH flotan con offset mayor (0.6 × ATR) sobre/bajo la línea fina
//     → ya no los tapan las velas
//   - La línea fina sigue exactamente al nivel del swing (sin offset)
//
//  CAMBIOS v1.3:
//   - HH/LH/HL/LL ahora son solo texto (sin caja)
//   - Esto evita la colisión visual con las cajas de BOS/CHoCH
//
//  CAMBIOS v1.2 (visual BOS/CHoCH alineado con All-in-One v3.8):
//   - Línea SÓLIDA del swing a la vela de ruptura (antes punteada)
//   - Etiqueta anclada al SWING (no a la vela de ruptura)
//   - CHoCH siempre en NARANJA (sin importar dirección)
//   - BOS usa color direccional (verde/rojo)
//   - Sin flechas ↑↓ en el texto (color + posición ya lo indican)
//   - Mismo tamaño (size.small) para BOS y CHoCH
//
//  CAMBIOS v1.1:
//   - Niveles previos: PDH, PDL, PWH, PWL
//   - Fair Value Gaps (FVG) con mitigación automática
// ============================================

// ============================================
//  SETTINGS: ZONAS
// ============================================
g_zones = "▮  Zonas Premium / Equilibrium / Discount"
zone_method = input.string("Lookback", "Método de cálculo", options=["Lookback", "Sesión Diaria", "Sesión Semanal", "Sesión Mensual"], group=g_zones, tooltip="Lookback: rango de las últimas N velas. Sesión: rango de la sesión actual D/W/M")
zone_lookback = input.int(50, "Lookback (velas)", minval=10, maxval=500, group=g_zones, tooltip="Solo aplica al método 'Lookback'")
show_premium = input.bool(true, "Mostrar zona Premium", group=g_zones)
show_equilibrium = input.bool(true, "Mostrar zona Equilibrium", group=g_zones)
show_discount = input.bool(true, "Mostrar zona Discount", group=g_zones)
color_premium = input.color(color.new(#ef4444, 80), "Color Premium", group=g_zones)
color_equilibrium = input.color(color.new(#94a3b8, 90), "Color Equilibrium", group=g_zones)
color_discount = input.color(color.new(#10b981, 80), "Color Discount", group=g_zones)

// ============================================
//  SETTINGS: NIVELES PREVIOS (PDH/PDL/PWH/PWL)
// ============================================
g_levels = "▮  Niveles previos (PDH / PDL / PWH / PWL)"
show_pdh = input.bool(true, "Mostrar Previous Day High (PDH)", group=g_levels)
show_pdl = input.bool(true, "Mostrar Previous Day Low (PDL)", group=g_levels)
show_pwh = input.bool(false, "Mostrar Previous Week High (PWH)", group=g_levels)
show_pwl = input.bool(false, "Mostrar Previous Week Low (PWL)", group=g_levels)
color_pd = input.color(#fbbf24, "Color PDH/PDL", group=g_levels)
color_pw = input.color(#a78bfa, "Color PWH/PWL", group=g_levels)
levels_style_input = input.string("Dashed", "Estilo de línea", options=["Solid", "Dashed", "Dotted"], group=g_levels)
levels_extend_left = input.int(100, "Extensión hacia la izquierda (velas)", minval=10, maxval=500, group=g_levels)
show_level_price = input.bool(true, "Mostrar precio en la etiqueta", group=g_levels)

// ============================================
//  SETTINGS: FVG (FAIR VALUE GAPS)
// ============================================
g_fvg = "▮  Fair Value Gaps (FVG)"
show_fvg = input.bool(true, "Mostrar FVG", group=g_fvg)
fvg_only_unmitigated = input.bool(true, "Solo mostrar no mitigados", group=g_fvg, tooltip="Si está activo, el FVG desaparece cuando el precio lo toca")
fvg_extend = input.int(50, "Extensión hacia adelante (velas)", minval=5, maxval=500, group=g_fvg)
color_fvg_bull = input.color(color.new(#10b981, 80), "Color FVG alcista", group=g_fvg)
color_fvg_bear = input.color(color.new(#ef4444, 80), "Color FVG bajista", group=g_fvg)

// ============================================
//  SETTINGS: ESTRUCTURA
// ============================================
g_struct = "▮  Estructura del mercado"
show_swings = input.bool(true, "Mostrar HH/HL/LH/LL", group=g_struct)
show_bos = input.bool(true, "Mostrar BOS (Break of Structure)", group=g_struct)
show_choch = input.bool(true, "Mostrar CHoCH (Change of Character)", group=g_struct)
swing_length = input.int(10, "Sensibilidad del pivote", minval=2, maxval=50, group=g_struct, tooltip="Mayor número = pivots más significativos pero menos frecuentes")
color_bullish = input.color(#10b981, "Color alcista", group=g_struct)
color_bearish = input.color(#ef4444, "Color bajista", group=g_struct)

// ============================================
//  SETTINGS: TABLA INFO
// ============================================
g_table = "▮  Tabla de información"
show_table = input.bool(true, "Mostrar tabla", group=g_table)
table_position_input = input.string("Top Right", "Posición", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=g_table)
table_size_input = input.string("Normal", "Tamaño de texto", options=["Tiny", "Small", "Normal", "Large"], group=g_table)

// ============================================
//  ATR PARA OFFSETS DE LABELS
// ============================================
// Con cajas, el offset = distancia entre el punto exacto (vela/línea) y el
// puntero de la caja. Mantener pequeño para que se vea "cerca pero no pegado".
atr_val = ta.atr(14)
swing_offset  = atr_val * 0.15   // Gap entre vela y caja HH/LH/HL/LL
struct_offset = atr_val * 0.15   // Gap entre línea y caja BOS/CHoCH

// ============================================
//  CÁLCULO DE ZONAS
// ============================================
var float range_high = na
var float range_low = na

is_new_daily = ta.change(time("D")) != 0
is_new_weekly = ta.change(time("W")) != 0
is_new_monthly = ta.change(time("M")) != 0

if zone_method == "Lookback"
    range_high := ta.highest(high, zone_lookback)
    range_low := ta.lowest(low, zone_lookback)
else if zone_method == "Sesión Diaria"
    if is_new_daily
        range_high := high
        range_low := low
    else
        range_high := math.max(nz(range_high, high), high)
        range_low := math.min(nz(range_low, low), low)
else if zone_method == "Sesión Semanal"
    if is_new_weekly
        range_high := high
        range_low := low
    else
        range_high := math.max(nz(range_high, high), high)
        range_low := math.min(nz(range_low, low), low)
else
    if is_new_monthly
        range_high := high
        range_low := low
    else
        range_high := math.max(nz(range_high, high), high)
        range_low := math.min(nz(range_low, low), low)

range_total = range_high - range_low
premium_low = range_low + (range_total * 0.7)
discount_high = range_low + (range_total * 0.3)
eq_level = (range_high + range_low) / 2

p_premium_top = plot(show_premium ? range_high : na, "Premium Top", color=color.new(color.black, 100))
p_premium_bot = plot(show_premium ? premium_low : na, "Premium Bot", color=color.new(color.black, 100))
p_eq_top = plot(show_equilibrium ? premium_low : na, "Eq Top", color=color.new(color.black, 100))
p_eq_bot = plot(show_equilibrium ? discount_high : na, "Eq Bot", color=color.new(color.black, 100))
p_discount_top = plot(show_discount ? discount_high : na, "Discount Top", color=color.new(color.black, 100))
p_discount_bot = plot(show_discount ? range_low : na, "Discount Bot", color=color.new(color.black, 100))

fill(p_premium_top, p_premium_bot, color=color_premium, title="Premium fill")
fill(p_eq_top, p_eq_bot, color=color_equilibrium, title="Equilibrium fill")
fill(p_discount_top, p_discount_bot, color=color_discount, title="Discount fill")

current_zone = close >= premium_low ? "PREMIUM" : close <= discount_high ? "DISCOUNT" : "EQUILIBRIUM"

// ============================================
//  LÍNEAS Y ETIQUETAS PREMIUM / EQ / DISCOUNT
//  Sobre el fill, para que los niveles exactos sean legibles
// ============================================
var line  line_prem = na
var line  line_eq   = na
var line  line_disc = na
var label lbl_prem  = na
var label lbl_eq    = na
var label lbl_disc  = na

if barstate.islast
    line.delete(line_prem)
    line.delete(line_eq)
    line.delete(line_disc)
    label.delete(lbl_prem)
    label.delete(lbl_eq)
    label.delete(lbl_disc)

    if show_premium and not na(range_high)
        line_prem := line.new(bar_index - levels_extend_left, range_high, bar_index + 5, range_high, color=color.new(color.red, 0), style=line.style_solid, width=1)
        lbl_prem := label.new(bar_index + 5, range_high, "PREMIUM " + str.tostring(range_high, format.mintick), style=label.style_label_left, color=color.new(color.red, 30), textcolor=color.white, size=size.small)

    if show_equilibrium and not na(eq_level)
        line_eq := line.new(bar_index - levels_extend_left, eq_level, bar_index + 5, eq_level, color=color.new(color.purple, 0), style=line.style_dashed, width=1)
        lbl_eq := label.new(bar_index + 5, eq_level, "EQ " + str.tostring(eq_level, format.mintick), style=label.style_label_left, color=color.new(color.purple, 30), textcolor=color.white, size=size.small)

    if show_discount and not na(range_low)
        line_disc := line.new(bar_index - levels_extend_left, range_low, bar_index + 5, range_low, color=color.new(color.green, 0), style=line.style_solid, width=1)
        lbl_disc := label.new(bar_index + 5, range_low, "DISCOUNT " + str.tostring(range_low, format.mintick), style=label.style_label_left, color=color.new(color.green, 30), textcolor=color.white, size=size.small)

// ============================================
//  NIVELES PREVIOS (PDH / PDL / PWH / PWL)
// ============================================
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

level_line_style = levels_style_input == "Solid" ? line.style_solid : levels_style_input == "Dashed" ? line.style_dashed : line.style_dotted

var line line_pdh = na
var line line_pdl = na
var line line_pwh = na
var line line_pwl = na
var label lbl_pdh = na
var label lbl_pdl = na
var label lbl_pwh = na
var label lbl_pwl = na

if barstate.islast
    line.delete(line_pdh)
    line.delete(line_pdl)
    line.delete(line_pwh)
    line.delete(line_pwl)
    label.delete(lbl_pdh)
    label.delete(lbl_pdl)
    label.delete(lbl_pwh)
    label.delete(lbl_pwl)

    pdh_txt = show_level_price and not na(pdh) ? "PDH " + str.tostring(pdh, format.mintick) : "PDH"
    pdl_txt = show_level_price and not na(pdl) ? "PDL " + str.tostring(pdl, format.mintick) : "PDL"
    pwh_txt = show_level_price and not na(pwh) ? "PWH " + str.tostring(pwh, format.mintick) : "PWH"
    pwl_txt = show_level_price and not na(pwl) ? "PWL " + str.tostring(pwl, format.mintick) : "PWL"

    if show_pdh and not na(pdh)
        line_pdh := line.new(bar_index - levels_extend_left, pdh, bar_index + 5, pdh, color=color_pd, style=level_line_style, width=1)
        lbl_pdh := label.new(bar_index + 5, pdh, pdh_txt, style=label.style_label_left, color=color.new(color_pd, 80), textcolor=color_pd, size=size.small)
    if show_pdl and not na(pdl)
        line_pdl := line.new(bar_index - levels_extend_left, pdl, bar_index + 5, pdl, color=color_pd, style=level_line_style, width=1)
        lbl_pdl := label.new(bar_index + 5, pdl, pdl_txt, style=label.style_label_left, color=color.new(color_pd, 80), textcolor=color_pd, size=size.small)
    if show_pwh and not na(pwh)
        line_pwh := line.new(bar_index - levels_extend_left, pwh, bar_index + 5, pwh, color=color_pw, style=level_line_style, width=1)
        lbl_pwh := label.new(bar_index + 5, pwh, pwh_txt, style=label.style_label_left, color=color.new(color_pw, 80), textcolor=color_pw, size=size.small)
    if show_pwl and not na(pwl)
        line_pwl := line.new(bar_index - levels_extend_left, pwl, bar_index + 5, pwl, color=color_pw, style=level_line_style, width=1)
        lbl_pwl := label.new(bar_index + 5, pwl, pwl_txt, style=label.style_label_left, color=color.new(color_pw, 80), textcolor=color_pw, size=size.small)

// ============================================
//  FAIR VALUE GAPS (FVG)
//  Bullish FVG: low > high[2] (hueco alcista entre vela actual y la de 2 atrás)
//  Bearish FVG: high < low[2] (hueco bajista)
// ============================================
bullish_fvg = show_fvg and low > high[2]
bearish_fvg = show_fvg and high < low[2]

var array<box>   fvg_bull_boxes = array.new<box>()
var array<float> fvg_bull_tops  = array.new<float>()
var array<float> fvg_bull_bots  = array.new<float>()

var array<box>   fvg_bear_boxes = array.new<box>()
var array<float> fvg_bear_tops  = array.new<float>()
var array<float> fvg_bear_bots  = array.new<float>()

if bullish_fvg
    bt = low
    bb = high[2]
    nb = box.new(bar_index - 2, bt, bar_index + fvg_extend, bb, bgcolor=color_fvg_bull, border_color=color.new(color_fvg_bull, 40), border_width=1)
    array.push(fvg_bull_boxes, nb)
    array.push(fvg_bull_tops, bt)
    array.push(fvg_bull_bots, bb)

if bearish_fvg
    bt2 = low[2]
    bb2 = high
    nb2 = box.new(bar_index - 2, bt2, bar_index + fvg_extend, bb2, bgcolor=color_fvg_bear, border_color=color.new(color_fvg_bear, 40), border_width=1)
    array.push(fvg_bear_boxes, nb2)
    array.push(fvg_bear_tops, bt2)
    array.push(fvg_bear_bots, bb2)

// Mitigación: si el precio entra al FVG, se borra automáticamente
if fvg_only_unmitigated
    // Bullish: mitigado cuando el low cruza por debajo del top del FVG
    i_bull = 0
    while i_bull < array.size(fvg_bull_boxes)
        top_i = array.get(fvg_bull_tops, i_bull)
        if low < top_i
            box.delete(array.get(fvg_bull_boxes, i_bull))
            array.remove(fvg_bull_boxes, i_bull)
            array.remove(fvg_bull_tops, i_bull)
            array.remove(fvg_bull_bots, i_bull)
        else
            i_bull += 1

    // Bearish: mitigado cuando el high cruza por encima del bottom del FVG
    i_bear = 0
    while i_bear < array.size(fvg_bear_boxes)
        bot_i = array.get(fvg_bear_bots, i_bear)
        if high > bot_i
            box.delete(array.get(fvg_bear_boxes, i_bear))
            array.remove(fvg_bear_boxes, i_bear)
            array.remove(fvg_bear_tops, i_bear)
            array.remove(fvg_bear_bots, i_bear)
        else
            i_bear += 1

// ============================================
//  DETECCIÓN DE ESTRUCTURA (BOS / CHoCH)
//  Bloque portado del WP Smart Flow All-in-One v3.8
//  Único cambio vs v3.8: HH/LH/HL/LL llevan un offset chico de ATR
//  para no quedar pegados a la vela.
// ============================================

// Pivots
ph = ta.pivothigh(high, swing_length, swing_length)
pl = ta.pivotlow(low, swing_length, swing_length)

var float last_pivot_high = na
var float prev_pivot_high = na
var float last_pivot_low  = na
var float prev_pivot_low  = na

if not na(ph)
    prev_pivot_high := last_pivot_high
    last_pivot_high := ph
if not na(pl)
    prev_pivot_low := last_pivot_low
    last_pivot_low := pl

// HH/LH/HL/LL — cajas con fondo coloreado (estilo v3.8), con respiro chico de swing_offset
if show_swings and not na(ph) and not na(prev_pivot_high)
    is_hh = ph > prev_pivot_high
    col_sw_hi = is_hh ? color_bullish : color_bearish
    label.new(bar_index - swing_length, ph + swing_offset,
              is_hh ? "HH" : "LH",
              style=label.style_label_down,
              color=color.new(col_sw_hi, 30),
              textcolor=color.white,
              size=size.small)
if show_swings and not na(pl) and not na(prev_pivot_low)
    is_hl = pl > prev_pivot_low
    col_sw_lo = is_hl ? color_bullish : color_bearish
    label.new(bar_index - swing_length, pl - swing_offset,
              is_hl ? "HL" : "LL",
              style=label.style_label_up,
              color=color.new(col_sw_lo, 30),
              textcolor=color.white,
              size=size.small)

// === Detección BOS / CHoCH (estilo v3.8) ===
var int   trend           = 0
var float last_swing_hi   = na
var float last_swing_lo   = na
var int   last_swing_hi_bar = na
var int   last_swing_lo_bar = na
var bool  swing_hi_used   = false
var bool  swing_lo_used   = false
var string structure_state = "RANGO"
var string last_event      = "—"

broke_up   = not na(last_swing_hi) and not swing_hi_used and ta.crossover(close,  last_swing_hi)
broke_down = not na(last_swing_lo) and not swing_lo_used and ta.crossunder(close, last_swing_lo)

if broke_up
    is_choch = trend == -1
    if (is_choch and show_choch) or (not is_choch and show_bos)
        col = is_choch ? color.orange : color_bullish
        // Línea sólida del swing a la vela de ruptura — al nivel exacto del swing
        line.new(last_swing_hi_bar, last_swing_hi, bar_index, last_swing_hi,
                 color=col, style=line.style_solid, width=1)
        // Caja en el MEDIO de la línea, con respiro chico (no toca la línea)
        mid_x_up = math.round((last_swing_hi_bar + bar_index) / 2)
        label.new(mid_x_up, last_swing_hi + struct_offset,
                  is_choch ? "CHoCH" : "BOS",
                  style=label.style_label_down,
                  color=color.new(col, 30),
                  textcolor=color.white,
                  size=size.small)
        last_event := is_choch ? "CHoCH alcista" : "BOS alcista"
    trend := 1
    swing_hi_used := true
    structure_state := "ALCISTA"

if broke_down
    is_choch = trend == 1
    if (is_choch and show_choch) or (not is_choch and show_bos)
        col = is_choch ? color.orange : color_bearish
        // Línea sólida del swing a la vela de ruptura — al nivel exacto del swing
        line.new(last_swing_lo_bar, last_swing_lo, bar_index, last_swing_lo,
                 color=col, style=line.style_solid, width=1)
        // Caja en el MEDIO de la línea, con respiro chico (no toca la línea)
        mid_x_dn = math.round((last_swing_lo_bar + bar_index) / 2)
        label.new(mid_x_dn, last_swing_lo - struct_offset,
                  is_choch ? "CHoCH" : "BOS",
                  style=label.style_label_up,
                  color=color.new(col, 30),
                  textcolor=color.white,
                  size=size.small)
        last_event := is_choch ? "CHoCH bajista" : "BOS bajista"
    trend := -1
    swing_lo_used := true
    structure_state := "BAJISTA"

// Registrar nuevo swing y resetear flag de "usado"
if not na(ph)
    last_swing_hi     := ph
    last_swing_hi_bar := bar_index - swing_length
    swing_hi_used     := false
if not na(pl)
    last_swing_lo     := pl
    last_swing_lo_bar := bar_index - swing_length
    swing_lo_used     := false

// ============================================
//  TABLA DE INFORMACIÓN
// ============================================
table_pos = table_position_input == "Top Right" ? position.top_right : table_position_input == "Top Left" ? position.top_left : table_position_input == "Bottom Right" ? position.bottom_right : position.bottom_left
text_sz = table_size_input == "Tiny" ? size.tiny : table_size_input == "Small" ? size.small : table_size_input == "Normal" ? size.normal : size.large

var table info = table.new(table_pos, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 70))

if barstate.islast
    if show_table
        table.cell(info, 0, 0, "WILLIAMSPILOT FREE", bgcolor=color.new(#1A4FFF, 0), text_color=color.white, text_size=text_sz)
        table.cell(info, 1, 0, "v2.2", bgcolor=color.new(#1A4FFF, 0), text_color=color.white, text_size=text_sz)

        table.cell(info, 0, 1, "Zona", text_color=color.new(color.white, 30), text_size=text_sz)
        zone_text_color = current_zone == "PREMIUM" ? color_bearish : current_zone == "DISCOUNT" ? color_bullish : color.gray
        table.cell(info, 1, 1, current_zone, text_color=zone_text_color, text_size=text_sz)

        table.cell(info, 0, 2, "Estructura", text_color=color.new(color.white, 30), text_size=text_sz)
        struct_text_color = structure_state == "ALCISTA" ? color_bullish : structure_state == "BAJISTA" ? color_bearish : color.gray
        table.cell(info, 1, 2, structure_state, text_color=struct_text_color, text_size=text_sz)

        table.cell(info, 0, 3, "Último evento", text_color=color.new(color.white, 30), text_size=text_sz)
        table.cell(info, 1, 3, last_event, text_color=color.white, text_size=text_sz)

        table.cell(info, 0, 4, "Timeframe", text_color=color.new(color.white, 30), text_size=text_sz)
        table.cell(info, 1, 4, timeframe.period, text_color=color.white, text_size=text_sz)

        table.cell(info, 0, 5, "williamspilot.com", bgcolor=color.new(color.black, 60), text_color=color.new(color.white, 40), text_size=size.tiny)
        table.cell(info, 1, 5, "Upgrade →", bgcolor=color.new(color.black, 60), text_color=color.new(#1A4FFF, 0), text_size=size.tiny)

// ============================================
//  ALERTAS
// ============================================
alertcondition(ta.crossover(close, premium_low), "Entrada a zona Premium", "Williamspilot: Precio entró en zona PREMIUM en {{ticker}} ({{interval}})")
alertcondition(ta.crossunder(close, discount_high), "Entrada a zona Discount", "Williamspilot: Precio entró en zona DISCOUNT en {{ticker}} ({{interval}})")
alertcondition(broke_up,   "Ruptura alcista (BOS/CHoCH)", "Williamspilot: Ruptura alcista en {{ticker}} ({{interval}})")
alertcondition(broke_down, "Ruptura bajista (BOS/CHoCH)", "Williamspilot: Ruptura bajista en {{ticker}} ({{interval}})")
alertcondition(bullish_fvg, "FVG alcista", "Williamspilot: FVG alcista en {{ticker}} ({{interval}})")
alertcondition(bearish_fvg, "FVG bajista", "Williamspilot: FVG bajista en {{ticker}} ({{interval}})")
alertcondition(not na(pdh) and ta.cross(close, pdh), "Cruce PDH", "Williamspilot: Cruce de PDH en {{ticker}} ({{interval}})")
alertcondition(not na(pdl) and ta.cross(close, pdl), "Cruce PDL", "Williamspilot: Cruce de PDL en {{ticker}} ({{interval}})")
````
