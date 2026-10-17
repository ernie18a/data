# SESSION TIME LEVELS (BRT) Xau24k

- url: https://www.tradingview.com/script/P4uNCHYq/
- type: indicator
- pine_id: PUB;2bea26d844c54f8abe25dc5ce4165608
- version: 1.0

## Description

📍 SESSION TIME LEVELS (BRT)
Automatically marks the High and Low of up to 3 custom candles per day — defined by hour and minute in Brasília time (BRT). Each level is drawn as a horizontal line that extends forward throughout the session, with an optional fill zone between High and Low.

━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 WHAT THIS INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━

Many trading strategies rely on the High and Low of specific candles — session opens, liquidity sweeps, institutional reference times. This tool automates that marking process for up to 3 configurable times per day, in Brasília time (UTC−3), with full historical replay.

At each defined time, the indicator:
• Captures the High and Low of that exact candle
• Draws a Max line (upper level) and a Min line (lower level)
• Fills the range between them with a transparent color zone
• Labels each level with the time and exact price
• Extends lines forward through the session (frozen at day close)
• Preserves up to 20 days of history on the chart

━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━

1. At the exact bar matching the configured hour and minute (in BRT), the indicator captures that candle's High and Low.
2. Two horizontal lines are drawn — one for the High (Max), one for the Low (Min) — extended to the right until the session ends.
3. A fill box is drawn between them as a visual reference zone.
4. At the turn of each new day (BRT), all lines and boxes from the previous session are frozen at their last bar — keeping history clean and readable.
5. Lines and boxes older than the configured history window are automatically excluded.

━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 VISUAL ELEMENTS
━━━━━━━━━━━━━━━━━━━━━━━━━━

For each active time slot:
• Max line — upper level of the reference candle (fully customizable color)
• Min line — lower level of the reference candle (fully customizable color)
• Fill zone — transparent box between Max and Min (customizable fill color)
• Labels — show time (HH:MM BRT) and price at High and Low

Lines extend to the right during the current session and freeze at day-end. Historical days are preserved for visual reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ CONFIGURABLE SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━

TIME SLOTS (up to 3, independently toggleable):
• Enable/disable each slot individually
• Hour and minute in BRT (Brasília time)
• Max line color, Min line color, Fill zone color — all fully customizable per slot

VISUAL OPTIONS:
• Line style: Solid / Dashed / Dotted
• Line thickness: 1 to 4
• History depth: 0 (today only) up to 20 days
• Show/hide labels
• BRT UTC offset (default −3; adjust to −2 during daylight saving time)

━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 USAGE NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━

• Works on any asset and any intraday timeframe
• Designed around Brasília time (BRT / UTC−3) — adjust the offset if your broker uses a different timezone
• If your region observes daylight saving time, change the offset to −2 during summer
• Setting history to 0 shows only today's levels — useful for clean intraday charts
• The fill zone helps visually identify premium/discount areas between the High and Low

━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is for educational and informational purposes only. It does not constitute financial advice. Always manage your risk appropriately.

## Source Code

````pine
//@version=5
indicator("Níveis por Horário (BRT)", overlay=true, max_lines_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════
//  CONFIGURAÇÕES DE HORÁRIOS
// ═══════════════════════════════════════════════════════════

grp_h1 = "⏰ Horário 1"
h1_ativo     = input.bool(true,  "Ativo",      group=grp_h1, inline="h1")
h1_hora      = input.int(20,     "Hora (BRT)", minval=0, maxval=23, group=grp_h1, inline="h1")
h1_minuto    = input.int(0,      "Minuto",     minval=0, maxval=59, group=grp_h1, inline="h1")
h1_cor_max   = input.color(color.new(#00E5FF, 0), "Cor Máx", group=grp_h1, inline="h1_cor")
h1_cor_min   = input.color(color.new(#FF4081, 0), "Cor Mín", group=grp_h1, inline="h1_cor")
h1_cor_fill  = input.color(color.new(#00E5FF, 75), "Cor Fill", group=grp_h1, inline="h1_cor")

grp_h2 = "⏰ Horário 2"
h2_ativo     = input.bool(true,  "Ativo",      group=grp_h2, inline="h2")
h2_hora      = input.int(21,     "Hora (BRT)", minval=0, maxval=23, group=grp_h2, inline="h2")
h2_minuto    = input.int(0,      "Minuto",     minval=0, maxval=59, group=grp_h2, inline="h2")
h2_cor_max   = input.color(color.new(#76FF03, 0), "Cor Máx", group=grp_h2, inline="h2_cor")
h2_cor_min   = input.color(color.new(#FF6D00, 0), "Cor Mín", group=grp_h2, inline="h2_cor")
h2_cor_fill  = input.color(color.new(#76FF03, 75), "Cor Fill", group=grp_h2, inline="h2_cor")

grp_h3 = "⏰ Horário 3"
h3_ativo     = input.bool(true,  "Ativo",      group=grp_h3, inline="h3")
h3_hora      = input.int(22,     "Hora (BRT)", minval=0, maxval=23, group=grp_h3, inline="h3")
h3_minuto    = input.int(0,      "Minuto",     minval=0, maxval=59, group=grp_h3, inline="h3")
h3_cor_max   = input.color(color.new(#E040FB, 0), "Cor Máx", group=grp_h3, inline="h3_cor")
h3_cor_min   = input.color(color.new(#FFEA00, 0), "Cor Mín", group=grp_h3, inline="h3_cor")
h3_cor_fill  = input.color(color.new(#E040FB, 75), "Cor Fill", group=grp_h3, inline="h3_cor")

// ═══════════════════════════════════════════════════════════
//  CONFIGURAÇÕES VISUAIS
// ═══════════════════════════════════════════════════════════

grp_vis = "🎨 Visual"
estilo_linha   = input.string("Tracejado", "Estilo da Linha", options=["Sólido", "Tracejado", "Pontilhado"], group=grp_vis)
espessura      = input.int(1, "Espessura", minval=1, maxval=4, group=grp_vis)
dias_historico = input.int(5, "Dias de Histórico", minval=0, maxval=20, group=grp_vis, tooltip="Quantos dias anteriores exibir. 0 = apenas dia atual.")
mostrar_label  = input.bool(true, "Mostrar Labels", group=grp_vis)
offset_brt     = input.int(-3, "Offset BRT (UTC)", minval=-12, maxval=12, group=grp_vis, tooltip="Normalmente -3 para Brasília. Ajuste para -2 no horário de verão.")

// ═══════════════════════════════════════════════════════════
//  AUXILIARES
// ═══════════════════════════════════════════════════════════

f_estilo() =>
    switch estilo_linha
        "Sólido"    => line.style_solid
        "Tracejado" => line.style_dashed
        =>            line.style_dotted

f_hora_brt() => (hour + offset_brt + 24) % 24

f_is_target(hora_alvo, min_alvo) =>
    f_hora_brt() == hora_alvo and minute == min_alvo

f_dia_brt() =>
    t_brt = time + offset_brt * 3600000
    int(t_brt / 86400000)

dia_brt_atual = f_dia_brt()
dia_brt_ant   = f_dia_brt()[1]
virada_dia    = dia_brt_atual != dia_brt_ant and not barstate.isfirst

// ═══════════════════════════════════════════════════════════
//  ARRAYS — linhas e boxes históricos
// ═══════════════════════════════════════════════════════════

var line[] arr_linhas = array.new_line()
var int[]  arr_dias   = array.new_int()
var box[]  arr_boxes  = array.new_box()
var int[]  arr_box_dias = array.new_int()

// Na virada do dia: congela linhas e boxes do dia anterior
if virada_dia
    if array.size(arr_linhas) > 0
        for i = 0 to array.size(arr_linhas) - 1
            ln  = array.get(arr_linhas, i)
            dia = array.get(arr_dias, i)
            if not na(ln) and dia == dia_brt_ant
                line.set_x2(ln, bar_index - 1)
                line.set_extend(ln, extend.none)

    if array.size(arr_boxes) > 0
        for i = 0 to array.size(arr_boxes) - 1
            bx  = array.get(arr_boxes, i)
            dia = array.get(arr_box_dias, i)
            if not na(bx) and dia == dia_brt_ant
                box.set_right(bx, bar_index - 1)
                box.set_extend(bx, extend.none)

// ═══════════════════════════════════════════════════════════
//  LÓGICA PRINCIPAL
// ═══════════════════════════════════════════════════════════

f_draw(ativo, hora_alvo, min_alvo, cor_max, cor_min, cor_fill, prefixo) =>
    if ativo and f_is_target(hora_alvo, min_alvo)
        dias_atras = (timenow - time) / (1000 * 60 * 60 * 24)

        if dias_atras <= dias_historico
            eh_hoje = dias_atras < 1.0
            ext     = eh_hoje ? extend.right : extend.none

            // Linhas
            ln_max = line.new(
                 x1=bar_index, y1=high,
                 x2=bar_index + 1, y2=high,
                 extend=ext,
                 color=cor_max,
                 style=f_estilo(),
                 width=espessura)

            ln_min = line.new(
                 x1=bar_index, y1=low,
                 x2=bar_index + 1, y2=low,
                 extend=ext,
                 color=cor_min,
                 style=f_estilo(),
                 width=espessura)

            // Box de preenchimento entre max e min
            bx = box.new(
                 left=bar_index,
                 top=high,
                 right=bar_index + 1,
                 bottom=low,
                 extend=ext,
                 border_color=color.new(cor_fill, 100), // borda invisível
                 border_width=0,
                 bgcolor=cor_fill)

            // Registra no array com o dia BRT
            array.push(arr_linhas,   ln_max)
            array.push(arr_dias,     dia_brt_atual)
            array.push(arr_linhas,   ln_min)
            array.push(arr_dias,     dia_brt_atual)
            array.push(arr_boxes,    bx)
            array.push(arr_box_dias, dia_brt_atual)

            if mostrar_label
                label_txt = prefixo + " " + str.tostring(hora_alvo, "00") + ":" + str.tostring(min_alvo, "00") + " BRT"
                label.new(x=bar_index, y=high,
                     text="▲ " + label_txt + " " + str.tostring(high, format.mintick),
                     color=color.new(cor_max, 80), textcolor=cor_max,
                     style=label.style_label_down, size=size.small)
                label.new(x=bar_index, y=low,
                     text="▼ " + label_txt + " " + str.tostring(low, format.mintick),
                     color=color.new(cor_min, 80), textcolor=cor_min,
                     style=label.style_label_up, size=size.small)

f_draw(h1_ativo, h1_hora, h1_minuto, h1_cor_max, h1_cor_min, h1_cor_fill, "H1")
f_draw(h2_ativo, h2_hora, h2_minuto, h2_cor_max, h2_cor_min, h2_cor_fill, "H2")
f_draw(h3_ativo, h3_hora, h3_minuto, h3_cor_max, h3_cor_min, h3_cor_fill, "H3")
````
