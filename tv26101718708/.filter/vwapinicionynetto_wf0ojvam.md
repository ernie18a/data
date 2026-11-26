# vwap_inicio_ny_Netto

- url: https://www.tradingview.com/script/Wf0OjVAm/
- type: indicator
- pine_id: PUB;0a84a8447e9146a3bae9ed1d0c6998dc
- version: 1.0

## Description

Indicador inicia vwap e seus desvios padões no horario da abertura das açoes de NY

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// VWAP Diária baseada no RTH (Regular Trading Hours) de Nova York
// Reseta automaticamente na abertura do mercado à vista de NY (09:30 ET)
// Ajuste automático para horário de verão dos EUA (DST)

//@version=5
indicator("VWAP RTH NY [Bandas Desvio Padrão]", "VWAP RTH", overlay = true, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Configurações Gerais
// ═══════════════════════════════════════════════════════════════
grpGeral = "═══ Configurações Gerais ═══"
source_input = input.string('hlc3', 'Fonte do Preço', 
     options = ['open', 'high', 'low', 'close', 'hl2', 'hlc3', 'ohlc4', 'hlcc4'], group = grpGeral)

useCustomSession = input.bool(false, "Usar Sessão Personalizada (sobrescreve RTH automático)", group = grpGeral)
customSession = input.session("0930-1600", "Sessão Personalizada (horário NY)", group = grpGeral, 
     tooltip = "Formato HHMM-HHMM no fuso de Nova York. Padrão RTH: 0930-1600")

// ═══════════════════════════════════════════════════════════════
// INPUTS - Linha VWAP
// ═══════════════════════════════════════════════════════════════
grpVWAP = "═══ Linha VWAP ═══"
showVWAP   = input.bool(true, "Mostrar VWAP", group = grpVWAP, inline = "vwap")
colorVWAP  = input.color(color.new(#2962FF, 0), "Cor", group = grpVWAP, inline = "vwap")
widthVWAP  = input.int(2, "Espessura", minval = 1, maxval = 10, group = grpVWAP, inline = "vwap")
styleVWAP  = input.string("Sólida", "Estilo", options = ["Sólida", "Tracejada", "Pontilhada"], group = grpVWAP)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Banda 1º Desvio Padrão
// ═══════════════════════════════════════════════════════════════
grpLVL1 = "═══ Banda 1º Desvio Padrão ═══"
showLVL1   = input.bool(true, "Mostrar 1º DP", group = grpLVL1, inline = "lvl1")
mp1        = input.float(1.0, "Multiplicador", step = 0.1, group = grpLVL1, inline = "lvl1")
colorLVL1  = input.color(color.new(#00C853, 0), "Cor", group = grpLVL1, inline = "lvl1cor")
widthLVL1  = input.int(1, "Espessura", minval = 1, maxval = 10, group = grpLVL1, inline = "lvl1cor")
styleLVL1  = input.string("Sólida", "Estilo", options = ["Sólida", "Tracejada", "Pontilhada"], group = grpLVL1)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Banda 2º Desvio Padrão
// ═══════════════════════════════════════════════════════════════
grpLVL2 = "═══ Banda 2º Desvio Padrão ═══"
showLVL2   = input.bool(true, "Mostrar 2º DP", group = grpLVL2, inline = "lvl2")
mp2        = input.float(2.0, "Multiplicador", step = 0.1, group = grpLVL2, inline = "lvl2")
colorLVL2  = input.color(color.new(#FF9800, 0), "Cor", group = grpLVL2, inline = "lvl2cor")
widthLVL2  = input.int(1, "Espessura", minval = 1, maxval = 10, group = grpLVL2, inline = "lvl2cor")
styleLVL2  = input.string("Sólida", "Estilo", options = ["Sólida", "Tracejada", "Pontilhada"], group = grpLVL2)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Banda 3º Desvio Padrão
// ═══════════════════════════════════════════════════════════════
grpLVL3 = "═══ Banda 3º Desvio Padrão ═══"
showLVL3   = input.bool(true, "Mostrar 3º DP", group = grpLVL3, inline = "lvl3")
mp3        = input.float(3.0, "Multiplicador", step = 0.1, group = grpLVL3, inline = "lvl3")
colorLVL3  = input.color(color.new(#D50000, 0), "Cor", group = grpLVL3, inline = "lvl3cor")
widthLVL3  = input.int(1, "Espessura", minval = 1, maxval = 10, group = grpLVL3, inline = "lvl3cor")
styleLVL3  = input.string("Sólida", "Estilo", options = ["Sólida", "Tracejada", "Pontilhada"], group = grpLVL3)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Preenchimentos
// ═══════════════════════════════════════════════════════════════
grpFill = "═══ Preenchimento entre Bandas ═══"
showFills = input.bool(true, "Ativar Preenchimentos", group = grpFill)
fillLow   = input.color(color.new(#00C853, 92), "Cor VWAP ↔ 1º DP", group = grpFill)
fillMid   = input.color(color.new(#FF9800, 92), "Cor 1º DP ↔ 2º DP", group = grpFill)
fillHigh  = input.color(color.new(#D50000, 92), "Cor 2º DP ↔ 3º DP", group = grpFill)

// ═══════════════════════════════════════════════════════════════
// INPUTS - Labels e Visual
// ═══════════════════════════════════════════════════════════════
grpLabel = "═══ Labels ═══"
showLabels = input.bool(true, "Mostrar Labels nas Linhas", group = grpLabel)
labelSize  = input.string("Pequeno", "Tamanho", options = ["Minúsculo", "Pequeno", "Normal", "Grande"], group = grpLabel)
labelOffset = input.int(5, "Deslocamento à Direita (barras)", minval = 0, maxval = 50, group = grpLabel)

// ═══════════════════════════════════════════════════════════════
// FONTE DO PREÇO
// ═══════════════════════════════════════════════════════════════
src = switch source_input
    'open'  => open
    'high'  => high
    'low'   => low
    'close' => close
    'hl2'   => hl2
    'hlc3'  => hlc3
    'ohlc4' => ohlc4
    'hlcc4' => hlcc4

// ═══════════════════════════════════════════════════════════════
// DETECÇÃO DA SESSÃO RTH DE NOVA YORK COM AJUSTE AUTOMÁTICO DST
// ═══════════════════════════════════════════════════════════════
// A função time() com timezone "America/New_York" ajusta automaticamente
// para horário de verão (EDT: UTC-4) e horário padrão (EST: UTC-5).
// Em Brasília (UTC-3, sem DST desde 2019):
//   - Horário Padrão (EST):  09:30 NY = 11:30 Brasília
//   - Horário de Verão (EDT): 09:30 NY = 10:30 Brasília

sessionString = useCustomSession ? customSession : "0930-1600"
nyTimezone = "America/New_York"

inSession = not na(time(timeframe.period, sessionString, nyTimezone))

// Detecta a abertura do RTH (primeira barra dentro da sessão após estar fora)
sessionStart = inSession and not inSession[1]

// ═══════════════════════════════════════════════════════════════
// CÁLCULO DO VWAP E DESVIO PADRÃO ACUMULADO NA SESSÃO RTH
// ═══════════════════════════════════════════════════════════════
var float sumSrcVol  = 0.0  // Σ (preço × volume)
var float sumSrc2Vol = 0.0  // Σ (preço² × volume)
var float sumVol     = 0.0  // Σ volume
var float vwapValue  = na
var float stdev      = na

if sessionStart
    // Reseta acumuladores na abertura da sessão
    sumSrcVol  := src * volume
    sumSrc2Vol := src * src * volume
    sumVol     := volume
else if inSession
    // Acumula durante a sessão
    sumSrcVol  += src * volume
    sumSrc2Vol += src * src * volume
    sumVol     += volume

if inSession and sumVol > 0
    vwapValue := sumSrcVol / sumVol
    variance = sumSrc2Vol / sumVol - vwapValue * vwapValue
    stdev := math.sqrt(math.max(variance, 0))
else
    vwapValue := na
    stdev := na

// ═══════════════════════════════════════════════════════════════
// CÁLCULO DAS BANDAS
// ═══════════════════════════════════════════════════════════════
upper1 = vwapValue + stdev * mp1
upper2 = vwapValue + stdev * mp2
upper3 = vwapValue + stdev * mp3
lower1 = vwapValue - stdev * mp1
lower2 = vwapValue - stdev * mp2
lower3 = vwapValue - stdev * mp3

// ═══════════════════════════════════════════════════════════════
// CONVERSÃO DE ESTILO DE LINHA
// ═══════════════════════════════════════════════════════════════
getLineStyle(s) =>
    switch s
        "Sólida"     => plot.style_linebr
        "Tracejada"  => plot.style_linebr  // será aplicado via line.new se necessário
        "Pontilhada" => plot.style_linebr
        => plot.style_linebr

// Para aplicar estilos diferentes (tracejado/pontilhado), usaremos plot com linestyle
// Pine Script v5 plot suporta apenas alguns estilos; vamos usar linhas extras para isso
// Solução: usar plot.style_linebr combinado com largura, e para tracejado/pontilhado
// usar técnica de plot condicional

// Como plot() não suporta dash/dotted diretamente, vamos manter plot para estilo sólido
// e desenhar com line.new() se o usuário escolher tracejado/pontilhado.
// Para simplificar e manter performance, usamos plot.style_linebr (linha quebrável)
// e a customização principal será via espessura.

// ═══════════════════════════════════════════════════════════════
// PLOTAGEM DAS LINHAS PRINCIPAIS (estilo sólido via plot)
// ═══════════════════════════════════════════════════════════════
plotVWAP_  = plot(showVWAP and styleVWAP == "Sólida" and inSession ? vwapValue : na, "VWAP", 
     color = colorVWAP, linewidth = widthVWAP, style = plot.style_linebr)
plotU1_    = plot(showLVL1 and styleLVL1 == "Sólida" and inSession ? upper1 : na, "+1 DP", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_linebr)
plotU2_    = plot(showLVL2 and styleLVL2 == "Sólida" and inSession ? upper2 : na, "+2 DP", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_linebr)
plotU3_    = plot(showLVL3 and styleLVL3 == "Sólida" and inSession ? upper3 : na, "+3 DP", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_linebr)
plotL1_    = plot(showLVL1 and styleLVL1 == "Sólida" and inSession ? lower1 : na, "-1 DP", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_linebr)
plotL2_    = plot(showLVL2 and styleLVL2 == "Sólida" and inSession ? lower2 : na, "-2 DP", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_linebr)
plotL3_    = plot(showLVL3 and styleLVL3 == "Sólida" and inSession ? lower3 : na, "-3 DP", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_linebr)

// Plots para estilo TRACEJADO (usando style_circles espaçados não funciona; usaremos line.style)
// Como plot() não tem tracejado nativo em v5, criamos linhas tracejadas/pontilhadas
// com line.new() para cada barra final da sessão.
// Para simplicidade e performance, vamos plotar dashed/dotted via plot com circles/cross.

plotVWAP_d = plot(showVWAP and styleVWAP == "Tracejada" and inSession and bar_index % 3 < 2 ? vwapValue : na, "VWAP_d", 
     color = colorVWAP, linewidth = widthVWAP, style = plot.style_linebr)
plotU1_d   = plot(showLVL1 and styleLVL1 == "Tracejada" and inSession and bar_index % 3 < 2 ? upper1 : na, "+1 DP_d", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_linebr)
plotU2_d   = plot(showLVL2 and styleLVL2 == "Tracejada" and inSession and bar_index % 3 < 2 ? upper2 : na, "+2 DP_d", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_linebr)
plotU3_d   = plot(showLVL3 and styleLVL3 == "Tracejada" and inSession and bar_index % 3 < 2 ? upper3 : na, "+3 DP_d", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_linebr)
plotL1_d   = plot(showLVL1 and styleLVL1 == "Tracejada" and inSession and bar_index % 3 < 2 ? lower1 : na, "-1 DP_d", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_linebr)
plotL2_d   = plot(showLVL2 and styleLVL2 == "Tracejada" and inSession and bar_index % 3 < 2 ? lower2 : na, "-2 DP_d", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_linebr)
plotL3_d   = plot(showLVL3 and styleLVL3 == "Tracejada" and inSession and bar_index % 3 < 2 ? lower3 : na, "-3 DP_d", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_linebr)

// Plots para estilo PONTILHADO (usando circles)
plotVWAP_p = plot(showVWAP and styleVWAP == "Pontilhada" and inSession ? vwapValue : na, "VWAP_p", 
     color = colorVWAP, linewidth = widthVWAP, style = plot.style_circles)
plotU1_p   = plot(showLVL1 and styleLVL1 == "Pontilhada" and inSession ? upper1 : na, "+1 DP_p", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_circles)
plotU2_p   = plot(showLVL2 and styleLVL2 == "Pontilhada" and inSession ? upper2 : na, "+2 DP_p", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_circles)
plotU3_p   = plot(showLVL3 and styleLVL3 == "Pontilhada" and inSession ? upper3 : na, "+3 DP_p", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_circles)
plotL1_p   = plot(showLVL1 and styleLVL1 == "Pontilhada" and inSession ? lower1 : na, "-1 DP_p", 
     color = colorLVL1, linewidth = widthLVL1, style = plot.style_circles)
plotL2_p   = plot(showLVL2 and styleLVL2 == "Pontilhada" and inSession ? lower2 : na, "-2 DP_p", 
     color = colorLVL2, linewidth = widthLVL2, style = plot.style_circles)
plotL3_p   = plot(showLVL3 and styleLVL3 == "Pontilhada" and inSession ? lower3 : na, "-3 DP_p", 
     color = colorLVL3, linewidth = widthLVL3, style = plot.style_circles)

// ═══════════════════════════════════════════════════════════════
// PREENCHIMENTOS ENTRE BANDAS
// ═══════════════════════════════════════════════════════════════
fill(plotVWAP_, plotU1_, color = showFills and showVWAP and showLVL1 ? fillLow  : na, title = "Fill VWAP↔+1")
fill(plotVWAP_, plotL1_, color = showFills and showVWAP and showLVL1 ? fillLow  : na, title = "Fill VWAP↔-1")
fill(plotU1_,   plotU2_, color = showFills and showLVL1 and showLVL2 ? fillMid  : na, title = "Fill +1↔+2")
fill(plotL1_,   plotL2_, color = showFills and showLVL1 and showLVL2 ? fillMid  : na, title = "Fill -1↔-2")
fill(plotU2_,   plotU3_, color = showFills and showLVL2 and showLVL3 ? fillHigh : na, title = "Fill +2↔+3")
fill(plotL2_,   plotL3_, color = showFills and showLVL2 and showLVL3 ? fillHigh : na, title = "Fill -2↔-3")

// ═══════════════════════════════════════════════════════════════
// LABELS NAS LINHAS (lado direito)
// ═══════════════════════════════════════════════════════════════
labelSizeValue = switch labelSize
    "Minúsculo" => size.tiny
    "Pequeno"   => size.small
    "Normal"    => size.normal
    "Grande"    => size.large

var label lbVWAP = na
var label lbU1   = na
var label lbU2   = na
var label lbU3   = na
var label lbL1   = na
var label lbL2   = na
var label lbL3   = na

if barstate.islast and showLabels
    label.delete(lbVWAP)
    label.delete(lbU1)
    label.delete(lbU2)
    label.delete(lbU3)
    label.delete(lbL1)
    label.delete(lbL2)
    label.delete(lbL3)
    
    if showVWAP and not na(vwapValue)
        lbVWAP := label.new(bar_index + labelOffset, vwapValue, "VWAP", 
             color = color.new(colorVWAP, 80), textcolor = colorVWAP, 
             style = label.style_label_left, size = labelSizeValue)
    
    if showLVL1 and not na(upper1)
        lbU1 := label.new(bar_index + labelOffset, upper1, "+" + str.tostring(mp1, "#.#") + "σ", 
             color = color.new(colorLVL1, 80), textcolor = colorLVL1, 
             style = label.style_label_left, size = labelSizeValue)
        lbL1 := label.new(bar_index + labelOffset, lower1, "-" + str.tostring(mp1, "#.#") + "σ", 
             color = color.new(colorLVL1, 80), textcolor = colorLVL1, 
             style = label.style_label_left, size = labelSizeValue)
    
    if showLVL2 and not na(upper2)
        lbU2 := label.new(bar_index + labelOffset, upper2, "+" + str.tostring(mp2, "#.#") + "σ", 
             color = color.new(colorLVL2, 80), textcolor = colorLVL2, 
             style = label.style_label_left, size = labelSizeValue)
        lbL2 := label.new(bar_index + labelOffset, lower2, "-" + str.tostring(mp2, "#.#") + "σ", 
             color = color.new(colorLVL2, 80), textcolor = colorLVL2, 
             style = label.style_label_left, size = labelSizeValue)
    
    if showLVL3 and not na(upper3)
        lbU3 := label.new(bar_index + labelOffset, upper3, "+" + str.tostring(mp3, "#.#") + "σ", 
             color = color.new(colorLVL3, 80), textcolor = colorLVL3, 
             style = label.style_label_left, size = labelSizeValue)
        lbL3 := label.new(bar_index + labelOffset, lower3, "-" + str.tostring(mp3, "#.#") + "σ", 
             color = color.new(colorLVL3, 80), textcolor = colorLVL3, 
             style = label.style_label_left, size = labelSizeValue)

// ═══════════════════════════════════════════════════════════════
// ALERTAS
// ═══════════════════════════════════════════════════════════════
alertcondition(ta.crossover(close, vwapValue),  "Cruzou VWAP para Cima",   "Preço cruzou VWAP RTH para cima")
alertcondition(ta.crossunder(close, vwapValue), "Cruzou VWAP para Baixo",  "Preço cruzou VWAP RTH para baixo")
alertcondition(ta.crossover(close, upper2),     "Rompeu +2 DP",            "Preço rompeu banda +2σ")
alertcondition(ta.crossunder(close, lower2),    "Rompeu -2 DP",            "Preço rompeu banda -2σ")
alertcondition(ta.crossover(close, upper3),     "Rompeu +3 DP",            "Preço rompeu banda +3σ (extremo)")
alertcondition(ta.crossunder(close, lower3),    "Rompeu -3 DP",            "Preço rompeu banda -3σ (extremo)")
````
