# ATR Stop Loss levels

- url: https://www.tradingview.com/script/xKnoLvKT/
- type: indicator
- pine_id: PUB;7cd80a81a4144ed584f7465a2b2cd406
- version: 2.0

## Description

[b]ATR Dynamic Stop Loss [/b]

BASED ON ATR Srop-Loss by Captaincoinflip INDICATOR

This indicator plots two reference points per bar — one above and one below price — representing the zone where normal market noise can reach based on current volatility. Its purpose is to help you place stops that won't get hunted by natural price movement, only by moves with real directional conviction. Hope you find it helpful.

[image]https://www.tradingview.com/x/KGhNoOkF/[/image]

[b]- How it works[/b]
The calculation is based on the ATR (Average True Range), developed by J. Welles Wilder in 1978. ATR measures the real average range of each bar including session gaps, making it a more accurate volatility reference than a simple high-low range.
The formula is straightforward:

Upper point = base price + (ATR × multiplier)
Lower point = base price − (ATR × multiplier)

The higher the volatility, the wider the points. The calmer the market, the tighter they sit.

[b]- Settings[/b]
ATR Period — number of bars averaged to calculate the ATR. 14 is Wilder's standard. Lower values react faster to recent volatility changes; higher values give a more stable reading.
Multiplier — how many ATRs of distance are projected from the base price. A value of 1.5 means the points sit 1.5 times the ATR away from price. Adjust to your style: scalping (1.0–1.5), intraday (1.5–2.0), swing (2.0–3.0).
Base price source — the reference point from which the SL levels are measured:

High/Low: upper point from the bar's high, lower from the low. The most natural option for intraday trading.
HL2: average of high and low — more centered and stable.
HLC3: typical price (high + low + close) / 3. A classic technical analysis reference.
OHLC4: average of all four bar prices. The smoothest option.
Close: both points from the closing price.
Open: both points from the opening price. Useful for gap context.

ATR Smoothing — how the True Range is averaged:

No smoothing: raw True Range of each bar. Most reactive.
RMA (Wilder): the original method. Long memory, stable. Recommended.
SMA: simple average. Equal weight to all bars.
EMA: exponential. More reactive to recent volatility.
WMA: linearly weighted. More weight to recent bars.

Visible bars — how many recent bars display the points. Default is 5. The rest of the chart stays clean.
Color and size — full visual customization of the dots: Tiny, Small, Normal or Large.

[b]- Technical note[/b]
When hiding and re-showing the indicator, or when changing timeframes, the points recalculate correctly. This is standard TradingView behavior when the chart reloads.
This script is open source and released to the public domain — use it, modify it, build on it, do whatever you want with it. And remember: you are the only one responsible for the results you get.

LOVE AND PROFITS

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
// ATR Stop Band — v1.4
// ────────────────────────────────────────────────────────────────────────────
// Uso exclusivo y confidencial del autor.
// Prohibida su distribución, copia o modificación sin autorización expresa.
// ════════════════════════════════════════════════════════════════════════════
indicator("ATR Stop Band", overlay=true)

G_SL  = "▸ Stop Band"
G_PNL = "▸ Panel ATR"

i_len  = input.int(14, "ATR Period", minval=1, group=G_SL, tooltip="Número de barras para el cálculo del ATR.")
i_mult = input.float(1.5, "Multiplicador", step=0.1, minval=0.1, group=G_SL, tooltip="Distancia de los puntos respecto al precio base en múltiplos de ATR.\nEjemplo: ATR=10, mult=1.5 → puntos a 15 pts del precio base.")
i_src  = input.string("High/Low — máx y mín de la vela", "Fuente precio base", group=G_SL,
         options=[
             "High/Low — máx y mín de la vela",
             "HL2 — (máx + mín) / 2",
             "HLC3 — (máx + mín + cierre) / 3",
             "OHLC4 — (apertura + máx + mín + cierre) / 4",
             "Close — precio de cierre",
             "Open — precio de apertura"
         ],
         tooltip="Precio desde el que se proyectan los puntos SL arriba y abajo:\n\n• High/Low: el punto superior sale del máximo de la vela, el inferior del mínimo.\n\n• HL2: media entre máximo y mínimo.\n\n• HLC3: precio típico (máx + mín + cierre) / 3.\n\n• OHLC4: media de los cuatro precios de la vela.\n\n• Close: ambos puntos desde el cierre.\n\n• Open: ambos puntos desde la apertura.")
i_sm   = input.string("RMA (Wilder — clásico ATR)", "Suavizado ATR", group=G_SL,
         options=[
             "Sin suavizado — True Range directo",
             "RMA (Wilder — clásico ATR)",
             "SMA — media simple",
             "EMA — exponencial estándar",
             "WMA — ponderada"
         ],
         tooltip="Cómo se suaviza el True Range:\n\n• Sin suavizado: True Range crudo de cada vela.\n\n• RMA (Wilder): el método original. Recomendado.\n\n• SMA: media simple.\n\n• EMA: exponencial estándar.\n\n• WMA: ponderada.")
i_bars = input.int(5, "Barras visibles", minval=1, maxval=50, group=G_SL, tooltip="Número de barras recientes en las que aparecen los puntos SL.")
i_c_up = input.color(color.new(#ff4444, 10), "Color punto superior", group=G_SL)
i_c_dn = input.color(color.new(#44bb44, 10), "Color punto inferior", group=G_SL)
i_sz   = input.string("Normal", "Tamaño puntos", options=["Tiny","Pequeño","Normal","Grande"], group=G_SL)

i_pnl_on  = input.bool(true, "Mostrar panel ATR", group=G_PNL)
i_pnl_pos = input.string("Arriba derecha", "Posición", group=G_PNL,
            options=["Arriba derecha","Arriba centro","Abajo derecha","Abajo izquierda","Abajo centro"])
i_pnl_sz  = input.string("Small", "Tamaño texto", group=G_PNL,
            options=["Tiny","Small","Normal","Large"])

// ── ATR ──────────────────────────────────────────────────────────────────────
_tr = ta.tr(true)
_atr = switch i_sm
    "Sin suavizado — True Range directo" => _tr
    "SMA — media simple"                 => ta.sma(_tr, i_len)
    "EMA — exponencial estándar"         => ta.ema(_tr, i_len)
    "WMA — ponderada"                    => ta.wma(_tr, i_len)
    =>                                      ta.rma(_tr, i_len)

// ── FUENTE ───────────────────────────────────────────────────────────────────
_base_up = switch i_src
    "HL2 — (máx + mín) / 2"                             => hl2
    "HLC3 — (máx + mín + cierre) / 3"                   => hlc3
    "OHLC4 — (apertura + máx + mín + cierre) / 4"       => ohlc4
    "Close — precio de cierre"                           => close
    "Open — precio de apertura"                          => open
    =>                                                      high

_base_dn = switch i_src
    "HL2 — (máx + mín) / 2"                             => hl2
    "HLC3 — (máx + mín + cierre) / 3"                   => hlc3
    "OHLC4 — (apertura + máx + mín + cierre) / 4"       => ohlc4
    "Close — precio de cierre"                           => close
    "Open — precio de apertura"                          => open
    =>                                                      low

_sl_up = _base_up + i_mult * _atr
_sl_dn = _base_dn - i_mult * _atr

// ── VENTANA DESLIZANTE ────────────────────────────────────────────────────────
_in_rng = bar_index >= last_bar_index - i_bars + 1
_lw     = i_sz == "Tiny" ? 1 : i_sz == "Pequeño" ? 2 : i_sz == "Grande" ? 5 : 3

plot(_in_rng ? _sl_up : na, "SL Superior", color=i_c_up, linewidth=_lw, style=plot.style_circles)
plot(_in_rng ? _sl_dn : na, "SL Inferior", color=i_c_dn, linewidth=_lw, style=plot.style_circles)

// ── PANEL ATR ─────────────────────────────────────────────────────────────────
// Posiciones arriba llevan una fila vacía de padding para evitar los botones de TV
if i_pnl_on and barstate.islast
    _tpos = switch i_pnl_pos
        "Arriba centro"    => position.top_center
        "Abajo derecha"    => position.bottom_right
        "Abajo izquierda"  => position.bottom_left
        "Abajo centro"     => position.bottom_center
        =>                    position.top_right

    _tsz = switch i_pnl_sz
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

    _is_top = i_pnl_pos == "Arriba derecha" or i_pnl_pos == "Arriba centro"
    _rows   = _is_top ? 2 : 1   // fila extra de padding en posiciones superiores

    _tbl = table.new(_tpos, 2, _rows, border_width=1, border_color=color.new(color.gray, 60))

    // Fila de padding para bajar el panel y no tapar los botones de TV
    if _is_top
        table.cell(_tbl, 0, 0, "", bgcolor=color.new(color.black, 100), text_size=size.tiny)
        table.cell(_tbl, 1, 0, "", bgcolor=color.new(color.black, 100), text_size=size.tiny)

    _row = _is_top ? 1 : 0
    _dec = syminfo.mintick >= 1.0 ? 2 : syminfo.mintick >= 0.01 ? 2 : syminfo.mintick >= 0.001 ? 3 : 4
    _atr_val = barstate.isconfirmed ? _atr : _atr[1]

    table.cell(_tbl, 0, _row, "ATR", text_color=color.white, bgcolor=color.new(color.gray, 35), text_size=_tsz)
    table.cell(_tbl, 1, _row, str.tostring(_atr_val, "#." + str.repeat("0", _dec)), text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=_tsz)
````
