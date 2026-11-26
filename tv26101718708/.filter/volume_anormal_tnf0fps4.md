# Volume Anormal

- url: https://www.tradingview.com/script/TnF0FPs4/
- type: indicator
- pine_id: PUB;80c427a69b1c447fbb1fb3f300686bbb
- version: 1.0

## Description

The **Abnormal Volume** is an advanced flow and participation analysis indicator designed to detect abnormal volume spikes across multiple timeframes simultaneously, helping traders identify areas of strong market activity, accumulation, distribution, absorption, and potentially explosive price movements.

Unlike traditional volume indicators that analyze only the current chart timeframe, this script performs a true multi-timeframe (MTF) analysis by comparing the current volume against a dynamic statistical reference window for each selected timeframe. Detection can be based on statistical percentiles (80th, 90th, or 95th percentile) or the highest volume within the selected window, allowing the indicator to adapt to different assets and trading styles.

The indicator continuously monitors both intraday and higher timeframes — from 5 minutes up to 6 months — searching for simultaneous abnormal volume events. The greater the number of timeframes aligned at the same moment, the more significant the market event is considered.

Main features include:

* Automatic abnormal volume detection using dynamic statistical thresholds;
* True multi-timeframe volume analysis;
* Cross-timeframe confluence system;
* Progressive visual highlighting based on signal strength;
* Automatic candle and background coloring;
* Informative labels displaying active aligned timeframes;
* Visual identification of strong and extreme signals;
* Fully customizable settings.

The main purpose of this indicator is to help traders identify moments when the market is experiencing unusually high participation, often associated with:

* institutional activity;
* important breakouts;
* major reversals;
* liquidity zones;
* market traps;
* volatility expansion;
* trend initiation or exhaustion.

The higher the confluence between timeframes, the greater the probability that the candle represents a meaningful flow event within the market.

## Source Code

````pine
//@version=6
indicator(title="Volume Anormal MTF v3", shorttitle="VolMTF v3", overlay=true)

// ─── JANELA DE REFERÊNCIA ───────────────────────────────────
grp_janela = "📏 Janela de Referência"

N = input.int(50, "Número de candles da janela",
     minval=10, maxval=500, step=5,
     tooltip="Quantos candles passados serão usados como referência em cada timeframe",
     group=grp_janela)

metodo = input.string("Percentil 95", "Método de detecção",
     options=["Percentil 80", "Percentil 90", "Percentil 95", "Máximo da janela"],
     tooltip="Como definir o limiar de volume anormal dentro da janela escolhida",
     group=grp_janela)

// ─── TIMEFRAMES INTRADAY (ativos por padrão) ────────────────
grp_intra = "📊 Timeframes"
usar_5m  = input.bool(true, "5 min",  group=grp_intra, inline="i1")
usar_15m = input.bool(true, "15 min", group=grp_intra, inline="i1")
usar_30m = input.bool(true, "30 min", group=grp_intra, inline="i2")
usar_1h  = input.bool(true, "1h",     group=grp_intra, inline="i2")
usar_2h  = input.bool(true, "2h",     group=grp_intra, inline="i3")
usar_4h  = input.bool(true, "4h",     group=grp_intra, inline="i3")
usar_1d  = input.bool(true, "Diário",    group=grp_intra, inline="s1")
usar_1w  = input.bool(true, "Semanal",   group=grp_intra, inline="s1")
usar_1m  = input.bool(true, "Mensal",    group=grp_intra, inline="s2")
usar_3m  = input.bool(true, "3 Meses",  group=grp_intra, inline="s2")
usar_6m  = input.bool(true, "6 Meses",  group=grp_intra, inline="s3")

// ─── CONFLUÊNCIA ────────────────────────────────────────────
grp_conf = "⚙️ Confluência"
min_confluencia = input.int(4, "Mínimo de TFs em confluência",
     minval=2, maxval=11,
     tooltip="Número mínimo de timeframes com spike simultâneo para pintar o candle",
     group=grp_conf)

// ─── CORES ──────────────────────────────────────────────────
grp_cores = "🎨 Cores por confluência"
cor_1  = input.color(color.new(#FFD700, 60), "1",  group=grp_cores, inline="c1")
cor_2  = input.color(color.new(#FFA500, 50), "2",  group=grp_cores, inline="c1")
cor_3  = input.color(color.new(#FF6600, 40), "3",  group=grp_cores, inline="c1")
cor_4  = input.color(color.new(#FF3300, 30), "4",  group=grp_cores, inline="c2")
cor_5  = input.color(color.new(#FF0000, 20), "5",  group=grp_cores, inline="c2")
cor_6  = input.color(color.new(#CC00FF, 10), "6",  group=grp_cores, inline="c2")
cor_7p = input.color(color.new(#FF00FF,  0), "7+", group=grp_cores, inline="c3")

// ─── VISUAL ─────────────────────────────────────────────────
grp_vis = "✨ Visual"
mostrar_label = input.bool(true, "Label com confluências e TFs ativos", group=grp_vis)
mostrar_bg    = input.bool(true, "Colorir fundo do candle",             group=grp_vis)
mostrar_barra = input.bool(true, "Colorir barra do candle",             group=grp_vis)

// ────────────────────────────────────────────────────────────
// FUNÇÃO: calcula limiar de volume dentro da janela N
// ────────────────────────────────────────────────────────────
calcular_limiar(vol_serie, janela, met) =>
    p80 = ta.percentile_nearest_rank(vol_serie, janela, 80)
    p90 = ta.percentile_nearest_rank(vol_serie, janela, 90)
    p95 = ta.percentile_nearest_rank(vol_serie, janela, 95)
    mx  = ta.highest(vol_serie, janela)
    met == "Percentil 80"  ? p80 :
     met == "Percentil 90" ? p90 :
     met == "Percentil 95" ? p95 :
     mx

// ────────────────────────────────────────────────────────────
// FUNÇÃO: detecta spike em um timeframe
// ────────────────────────────────────────────────────────────
detectar_spike(tf, janela, met) =>
    vol_tf    = request.security(syminfo.tickerid, tf, volume, lookahead=barmerge.lookahead_off)
    limiar_tf = request.security(syminfo.tickerid, tf, calcular_limiar(volume, janela, met), lookahead=barmerge.lookahead_off)
    vol_tf > limiar_tf

// ─── DETECÇÃO POR TIMEFRAME ──────────────────────────────────
// Intraday
spike_5m  = usar_5m  ? detectar_spike("5",   N, metodo) : false
spike_15m = usar_15m ? detectar_spike("15",  N, metodo) : false
spike_30m = usar_30m ? detectar_spike("30",  N, metodo) : false
spike_1h  = usar_1h  ? detectar_spike("60",  N, metodo) : false
spike_2h  = usar_2h  ? detectar_spike("120", N, metodo) : false
spike_4h  = usar_4h  ? detectar_spike("240", N, metodo) : false

// Maiores
spike_1d  = usar_1d  ? detectar_spike("D",  N, metodo) : false
spike_1w  = usar_1w  ? detectar_spike("W",  N, metodo) : false
spike_1m  = usar_1m  ? detectar_spike("M",  N, metodo) : false
// 3M e 6M: Pine não tem timeframe nativo "3M"/"6M", usamos "3M" e "6M" (meses)
spike_3m  = usar_3m  ? detectar_spike("3M", N, metodo) : false
spike_6m  = usar_6m  ? detectar_spike("6M", N, metodo) : false

// ─── CONTAGEM DE CONFLUÊNCIAS ────────────────────────────────
confluencias = (spike_5m  ? 1 : 0) +
               (spike_15m ? 1 : 0) +
               (spike_30m ? 1 : 0) +
               (spike_1h  ? 1 : 0) +
               (spike_2h  ? 1 : 0) +
               (spike_4h  ? 1 : 0) +
               (spike_1d  ? 1 : 0) +
               (spike_1w  ? 1 : 0) +
               (spike_1m  ? 1 : 0) +
               (spike_3m  ? 1 : 0) +
               (spike_6m  ? 1 : 0)

sinal = confluencias >= min_confluencia

// ─── COR BASEADA NA CONFLUÊNCIA ──────────────────────────────
cor = confluencias == 1 ? cor_1  :
      confluencias == 2 ? cor_2  :
      confluencias == 3 ? cor_3  :
      confluencias == 4 ? cor_4  :
      confluencias == 5 ? cor_5  :
      confluencias == 6 ? cor_6  :
      confluencias >= 7 ? cor_7p : na

// ─── OUTPUTS VISUAIS ─────────────────────────────────────────
bgcolor(mostrar_bg    and sinal ? cor : na, title="Fundo do candle")
barcolor(mostrar_barra and sinal ? cor : na, title="Cor da barra")

// ─── LABEL ───────────────────────────────────────────────────
if mostrar_label and sinal
    tfs = ""
    tfs := spike_5m  ? tfs + "5m "  : tfs
    tfs := spike_15m ? tfs + "15m " : tfs
    tfs := spike_30m ? tfs + "30m " : tfs
    tfs := spike_1h  ? tfs + "1h "  : tfs
    tfs := spike_2h  ? tfs + "2h "  : tfs
    tfs := spike_4h  ? tfs + "4h "  : tfs
    tfs := spike_1d  ? tfs + "D "   : tfs
    tfs := spike_1w  ? tfs + "W "   : tfs
    tfs := spike_1m  ? tfs + "M "   : tfs
    tfs := spike_3m  ? tfs + "3M "  : tfs
    tfs := spike_6m  ? tfs + "6M "  : tfs

    cor_label = confluencias >= 6 ? color.new(#CC00FF, 0) : confluencias >= 4 ? color.new(#FF0000, 0) : confluencias == 3 ? color.new(#FF6600, 0) : color.new(#FFD700, 0)

    label.new(
         x         = bar_index,
         y         = high,
         text      = "⚡ " + str.tostring(confluencias) + "x\n" + tfs,
         style     = label.style_label_down,
         color     = cor_label,
         textcolor = color.white,
         size      = size.small
         )

// ─── ÍCONES ABAIXO DA BARRA ───────────────────────────────────
plotchar(sinal and confluencias >= 6, char="★",
         location=location.belowbar, color=color.new(#FF00FF, 0),
         size=size.small, title="Sinal extremo (≥6 TFs)")

plotchar(sinal and confluencias >= 3 and confluencias < 6, char="◆",
         location=location.belowbar, color=color.new(#FF4500, 0),
         size=size.tiny, title="Sinal forte (3-5 TFs)")
````
