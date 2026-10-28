# VWAP DELTA

- url: https://www.tradingview.com/script/4lrFYGmT/
- type: indicator
- pine_id: PUB;0126e1a0a14b4ec1bb483b6a040df7e4
- version: 1.0

## Description

🇬🇧 ENGLISH

VWAP DELTA is a Volume Weighted Average Price that uses delta volume magnitude as its weighting factor instead of total volume. Unlike a standard VWAP — where every bar contributes proportionally to its raw volume — VWAP DELTA gives more weight to bars where buyers or sellers clearly dominated, and less weight to bars where volume was balanced between both sides. The result is a price level that better reflects where the market agreed during high-conviction moves.

HOW IT WORKS:
Delta volume is estimated from each candle's shape by splitting volume between buyers and sellers using the high-low range. Bars that close near the high have high buy delta; bars that close near the low have high sell delta. The VWAP is then computed weighting each price by the absolute value of its delta, so only directional pressure counts.

COMPONENTS:
1. Delta Volume — Estimated as: Buy Vol = Volume × (Close − Low) / (High − Low), Sell Vol = Volume × (High − Close) / (High − Low). Delta = Buy Vol − Sell Vol.
2. VWAP Delta — Formula: Sum(HLC3 × |Delta|) / Sum(|Delta|), anchored and reset at each new period (Session, Week, Month, Quarter or Year).
3. Standard Deviation Bands — Delta-weighted variance bands above and below the VWAP Delta, showing price extension during high-conviction moves. Useful as dynamic support and resistance zones.
4. Dynamic Color — The line turns teal when cumulative session delta is positive (buyers dominating the strong moves) and red when negative (sellers dominating). At a glance you know which side has been more active in the meaningful bars of the session.

USE CASES:
• Confirm the direction of "active money" — price above VWAP Delta means high-conviction moves were bullish.
• Filter false signals — balanced-volume candles barely move the indicator, reducing noise.
• Spot divergences — price rising but VWAP Delta lagging or falling signals a rally with weak buying conviction.
• Intraday bias — color tells you who dominated the strong bars of the session without reading order flow tools.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🇪🇸 ESPAÑOL

VWAP DELTA es un Precio Medio Ponderado por Volumen que usa la magnitud del volumen delta como factor de ponderación en lugar del volumen total. A diferencia del VWAP estándar — donde cada vela contribuye de forma proporcional a su volumen bruto — VWAP DELTA otorga más peso a las velas donde compradores o vendedores dominaron claramente, y menos peso a las velas donde el volumen estuvo equilibrado entre ambos lados. El resultado es un nivel de precio que refleja mejor dónde acordó el mercado durante los movimientos de alta convicción.

CÓMO FUNCIONA:
El volumen delta se estima a partir de la forma de cada vela dividiendo el volumen entre compradores y vendedores usando el rango high-low. Las velas que cierran cerca del máximo tienen alto delta comprador; las que cierran cerca del mínimo tienen alto delta vendedor. El VWAP se calcula ponderando cada precio por el valor absoluto de su delta, de modo que sólo cuenta la presión direccional.

COMPONENTES:
1. Volumen Delta — Estimado como: Vol Comprador = Volumen × (Close − Low) / (High − Low), Vol Vendedor = Volumen × (High − Close) / (High − Low). Delta = Vol Comprador − Vol Vendedor.
2. VWAP Delta — Fórmula: Sum(HLC3 × |Delta|) / Sum(|Delta|), anclado y reiniciado en cada nuevo período (Sesión, Semana, Mes, Trimestre o Año).
3. Bandas de Desviación Estándar — Bandas de varianza ponderada por delta por encima y por debajo del VWAP Delta, que muestran la extensión del precio durante movimientos de alta convicción. Útiles como zonas dinámicas de soporte y resistencia.
4. Color Dinámico — La línea se muestra en verde azulado cuando el delta neto de la sesión es positivo (compradores dominando los movimientos fuertes) y en rojo cuando es negativo (vendedores dominando). De un vistazo sabes qué lado ha sido más activo en las velas importantes de la sesión.

CASOS DE USO:
• Confirmar la dirección del "dinero activo" — precio por encima del VWAP Delta significa que los movimientos de alta convicción fueron alcistas.
• Filtrar señales falsas — las velas de volumen equilibrado apenas mueven el indicador, reduciendo el ruido.
• Detectar divergencias — precio subiendo pero VWAP Delta plano o bajando señala un rally sin convicción compradora real.
• Sesgo intradiario — el color indica quién dominó las velas importantes de la sesión sin necesidad de herramientas de order flow.

## Source Code

````pine
//@version=6
// ============================================================================
// VWAP DELTA
// ============================================================================
// EN: A VWAP that uses delta volume magnitude as its weighting factor instead
//     of total volume. Bars where buyers or sellers clearly dominated receive
//     more influence on the average, filtering out neutral/balanced volume.
//
// ES: Un VWAP que usa la magnitud del volumen delta como factor de ponderación
//     en lugar del volumen total. Las velas donde compradores o vendedores
//     dominaron claramente tienen más peso, filtrando el volumen neutral.
//
// COMPONENTS / COMPONENTES:
//  1. Delta Volume  — buy_vol - sell_vol estimated from candle shape (HL range)
//  2. VWAP Delta    — Sum(hlc3 * |delta|) / Sum(|delta|), anchored per period
//  3. Std Dev Bands — delta-weighted variance bands above/below VWAP Delta
//  4. Dynamic Color — teal = net buying session | red = net selling session
// ============================================================================

indicator("VWAP DELTA", overlay=true, max_bars_back=5000)

// ── Inputs ───────────────────────────────────────────────────────────────────
anchor     = input.string("Session", "Anchor Period",
              options=["Session","Week","Month","Quarter","Year"])
show_bands = input.bool(true,  "Show Std Dev Bands")
band_mult  = input.float(1.0,  "Band Multiplier", step=0.25)
col_pos    = input.color(color.new(color.teal, 0), "Color Bullish")
col_neg    = input.color(color.new(color.red,  0), "Color Bearish")
col_band   = input.color(color.new(color.gray, 60), "Band Color")

// ── 1. Delta Volume ───────────────────────────────────────────────────────────
// Split each candle's volume into buy/sell using the high-low range proportion
hl_range  = high - low
buy_vol   = hl_range != 0 ? volume * (close - low)  / hl_range : volume * 0.5
sell_vol  = hl_range != 0 ? volume * (high - close) / hl_range : volume * 0.5
delta     = buy_vol - sell_vol
abs_delta = math.abs(delta)

// ── Anchor Reset ──────────────────────────────────────────────────────────────
is_new_period = switch anchor
    "Session"  => session.isfirstbar_regular
    "Week"     => weekofyear != weekofyear[1] or na(weekofyear[1])
    "Month"    => month != month[1] or na(month[1])
    "Quarter"  => (month == 1 or month == 4 or month == 7 or month == 10) and (month != month[1] or na(month[1]))
    "Year"     => year != year[1] or na(year[1])
    => false

// ── 2. Cumulative sums for VWAP Delta ────────────────────────────────────────
var float cum_pd      = 0.0   // Sum(hlc3 * |delta|)
var float cum_d       = 0.0   // Sum(|delta|)
var float cum_p2d     = 0.0   // Sum(hlc3² * |delta|) — for variance
var float cum_delta_net = 0.0 // Net delta — for color direction

if is_new_period
    cum_pd        := 0.0
    cum_d         := 0.0
    cum_p2d       := 0.0
    cum_delta_net := 0.0

cum_pd        += hlc3 * abs_delta
cum_d         += abs_delta
cum_p2d       += hlc3 * hlc3 * abs_delta
cum_delta_net += delta

// VWAP Delta — always returns a valid price level on the chart
vwap_d = cum_d != 0 ? cum_pd / cum_d : hlc3

// ── 3. Std Dev Bands ──────────────────────────────────────────────────────────
variance = cum_d != 0 ? (cum_p2d / cum_d) - vwap_d * vwap_d : 0.0
std_dev  = math.sqrt(math.max(variance, 0.0))
band_up  = vwap_d + band_mult * std_dev
band_dn  = vwap_d - band_mult * std_dev

// ── 4. Dynamic Color — net session delta direction ────────────────────────────
vwap_color = cum_delta_net >= 0 ? col_pos : col_neg

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(vwap_d,  "VWAP Delta", color=vwap_color, linewidth=2)
p_up = plot(show_bands ? band_up : na, "Upper Band", color=col_band, linewidth=1)
p_dn = plot(show_bands ? band_dn : na, "Lower Band", color=col_band, linewidth=1)
fill(p_up, p_dn, color=color.new(color.gray, 88), title="Band Fill")
````
