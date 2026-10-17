# BRN HILo CloudGrid Master

- url: https://www.tradingview.com/script/oDwFNVTT/
- type: indicator
- pine_id: PUB;7eebf9b419244ee7bf9e8bdff052f077
- version: 1.0

## Description

The BRN HILo CloudGrid Master is an institutional-grade indicator developed for TradingView. It merges fluid trend reading (via multiple HILo Clouds) with the mathematical precision of pullback zones (via a dynamic Operational Grid/Channel). The system's primary goal is to capture major market cycle reversals and provide pinpoint, risk-controlled re-entries.

The anatomy of the indicator is built upon three main pillars: The Trend Engine, The Precision Grid, and the Signal Module.

1. The Trend Engine (The Clouds)
The system does not analyze the trend from a single angle. It utilizes three layers of HILo Clouds to determine the flow of capital:

Long Cloud (Macro): Acts as the primary structural support or resistance. When this cloud is valid, the market has a clear and defined direction.

Structural Frontier (Filter): Acts as the market's "referee." When this frontier crosses and "mitigates" the Long Cloud, the system understands that the institutional strength of that trend is exhausted, paving the way for a reversal.

Fast Cloud (Trigger): Provides a dynamic short-term price reading. The "birth" of this cloud in the direction of the macro trend is what unlocks the pullback opportunities.

2. The Precision Grid (Operational Channel)
Instead of relying on invisible moving averages, the indicator projects a dynamic visual channel based on extreme volatility (highs and lows) calculated from the Fast Cloud.

Inside this channel, the system plots the 1/4 Lines (Upper and Lower). These lines act as institutional liquidity zones. The system requires the Price Action to interact with these lines milimetrically to validate pullbacks, ensuring you don't buy the top or sell the bottom of an overextended move. Visually, the background of this channel dynamically changes color (Light Green or Light Red) to immediately indicate which cycle is currently dominant.

3. Signal Types (BRK and PLB)
The indicator generates two categories of operational signals, which are programmed to never overlap on the same candle:

BRK (Breakout) Signals: These are the cycle definers. They occur when the Long Cloud is mitigated and there is a structural break on the current candle (a higher high for a buy, or a lower low for a sell). A Buy BRK initiates the "Bull Cycle," and a Sell BRK initiates the "Bear Cycle."

PLB (Pullback) Signals: These trade in the direction of the current cycle. They require the Long Cloud to be intact and valid. The confirmation for a PLB is strict: the candle must sweep liquidity by opening "outside" the 1/4 line of the operational channel and gain enough momentum to close "inside" the channel, validating the rejection of that zone.

4. The 7 Operational Modes
To adapt to any risk profile, the system features 7 selectable operational modes via the settings panel:

Complete: Plots absolutely all possible breakouts and pullbacks.

Structural: Plots only the first structural break that shifts the trend (1st BRK) and then all subsequent pullbacks (PLBs) in that direction.

Breakouts: Hides pullbacks and focuses strictly on expansion signals (BRKs).

Reversal: The cleanest mode. Plots strictly the exact candle that initiated the macro cycle reversal.

Retractions: Hides breakouts and focuses solely on mean-reversion trades (PLBs).

Alternation: An institutional safety mode. It requires a BRK, locks the system until a PLB occurs, and then locks it again until a new BRK appears.

DCA CloudGrid (Exclusive Mode): Optimized for position building (Dollar Cost Averaging). It signals the cycle reversal (1st BRK) and, from then on, bypasses the Fast Cloud filter to generate PLB signals every single time the price respects the Price Action trigger on the 1/4 lines of the grid.

5. The Integrated Dashboard
The system features a real-time side panel that eliminates the need to interpret confusing lines. It instantly displays:

The current cycle (Bull, Bear, or Waiting).

The validity status of the Macro and Trigger clouds.

The current channel width (in points/ticks and price percentage).

The live confirmation of the mathematical candle rules.

The active signal and the currently selected mode.

## Source Code

````pine
//@version=6
indicator(title = 'BRN HILo CloudGrid Master', shorttitle = 'BRN CloudGrid', overlay = true, max_labels_count = 50)

// =========================================================================
// 1. VARIÁVEIS DE ENTRADA E CONFIGURAÇÕES
// =========================================================================
grpAjuste = '⚙️ CONFIGURAÇÕES DE AJUSTE'

opM1 = 'Modo 1 - Completo: Todos BRKs e PLBs'
opM2 = 'Modo 2 - Estrutural: 1º BRK + Todos PLBs'
opM3 = 'Modo 3 - Rompimento: Apenas Todos BRKs'
opM4 = 'Modo 4 - Reversão: Apenas 1º BRK do Ciclo'
opM5 = 'Modo 5 - Retração: Apenas Todos PLBs'
opM6 = 'Modo 6 - Alternância: Travado (BRK → PLB)'
opM7 = 'Modo 7 - DCA CloudGrid: 1º BRK + PLBs na Grid'

modoOperacional = input.string(opM7, title = 'Modo Operacional', options = [opM1, opM2, opM3, opM4, opM5, opM6, opM7], group = grpAjuste)
periodoRapido = input.int(200, title = 'Período da Nuvem Rápida', group = grpAjuste)
periodoMedio = input.int(500, title = 'Período da Fronteira Estrutural', group = grpAjuste)
periodoLongo = input.int(1000, title = 'Período da Nuvem Longa', group = grpAjuste)

grpSinais = '🎯 CONFIGURAÇÕES DE SINAIS (TAGS)'
enableSig = input.bool(true, title = 'Ligar/Desligar Todos os Sinais', group = grpSinais)
showDirTxt = input.bool(true, title = 'Mostrar Nomeclatura de Direção (BUY / SELL)', group = grpSinais)
showTypeTxt = input.bool(true, title = 'Mostrar Tag de Tipo (BRK / PLB)', group = grpSinais)

grpVisual = '🎨 CONFIGURAÇÕES VISUAIS'
showDash = input.bool(true, title = 'Mostrar Dashboard de Status', group = grpVisual)
showNames = input.bool(true, title = 'Mostrar Textos das Nuvens e Canal', group = grpVisual)
labelOffset = input.int(5, title = 'Distância dos Textos à Direita', minval = 1, group = grpVisual)
showCanalFill = input.bool(false, title = 'Pintar Canal Operacional Dinâmico', group = grpVisual)
colorLine = input.color(color.black, title = 'Cor das Linhas da Grid', group = grpVisual)
c_nl_res = input.color(color.rgb(255, 0, 0, 70), title = 'Cor Nuvem Longa Resistência', group = grpVisual)
c_nl_sup = input.color(color.rgb(50, 234, 50, 70), title = 'Cor Nuvem Longa Suporte', group = grpVisual)
c_nr_res = input.color(color.rgb(255, 0, 0, 85), title = 'Cor Nuvem Rápida Resistência', group = grpVisual)
c_nr_sup = input.color(color.rgb(50, 234, 50, 85), title = 'Cor Nuvem Rápida Suporte', group = grpVisual)

// =========================================================================
// 2. FUNÇÕES CUSTOMIZADAS (OTIMIZAÇÃO DE CÓDIGO)
// =========================================================================
f_calc_hilo(_high, _low, _len) =>
    var float _up = na
    var float _dn = na
    alpha = 2.0 / (_len + 1)
    _up := na(_up[1]) ? _high : _high >= _up[1] ? _high : alpha * (_high - _up[1]) + _up[1]
    _dn := na(_dn[1]) ? _low : _low <= _dn[1] ? _low : alpha * (_low - _dn[1]) + _dn[1]
    [_up, _dn]

f_atualiza_label(_lbl_var, _show, _x, _y, _txt, _cor) =>
    if _show
        if na(_lbl_var)
            label.new(_x, _y, _txt, xloc = xloc.bar_index, style = label.style_label_left, color = _cor, textcolor = color.white, size = size.small)
        else
            label.set_xy(_lbl_var, _x, _y)
            label.set_text(_lbl_var, _txt)
            label.set_color(_lbl_var, _cor)
            _lbl_var
    else
        if not na(_lbl_var)
            label.delete(_lbl_var)
        na

f_add_row(_tbl, _row, _title, _val, _bg_title, _bg_val) =>
    table.cell(_tbl, 0, _row, _title, text_color = color.white, bgcolor = _bg_title, text_size = size.small)
    table.cell(_tbl, 1, _row, _val, text_color = color.white, bgcolor = _bg_val, text_size = size.small)

// =========================================================================
// 3. CÁLCULO DA GRID E DAS NUVENS
// =========================================================================
[upper, lower] = f_calc_hilo(high, low, periodoRapido)
[upper1, lower1] = f_calc_hilo(high, low, periodoMedio)
[upper2, lower2] = f_calc_hilo(high, low, periodoLongo)

middleLine = (upper + lower) / 2.0
gridSuperiorInterno = middleLine + (upper - lower) / 4.0
gridInferiorInterno = middleLine - (upper - lower) / 4.0

larguraCanalInterno = math.abs(gridSuperiorInterno - gridInferiorInterno)
larguraCanalInternoPct = close != 0 ? larguraCanalInterno / close * 100.0 : na

// =========================================================================
// 4. ESTADO ESTRUTURAL DAS NUVENS E NASCIMENTO
// =========================================================================
stRapidaSuporte = lower > lower1 ? 'VÁLIDA' : 'MITIGADA'
stRapidaResistencia = upper < upper1 ? 'VÁLIDA' : 'MITIGADA'
stLongaSuporte = lower1 > lower2 ? 'VÁLIDA' : 'MITIGADA'
stLongaResistencia = upper1 < upper2 ? 'VÁLIDA' : 'MITIGADA'

nasceuRapidaSuporte = stRapidaSuporte[1] == 'MITIGADA' and stRapidaSuporte == 'VÁLIDA'
nasceuRapidaResistencia = stRapidaResistencia[1] == 'MITIGADA' and stRapidaResistencia == 'VÁLIDA'

// =========================================================================
// 5. MOTOR DE CICLO — BREAKOUT DEFINE E INVERTE O CICLO
// =========================================================================
var string cicloAtual = 'AGUARDANDO'
cicloAntes = cicloAtual

brkBuyRaw = stLongaResistencia == 'MITIGADA' and high > high[1]
brkSellRaw = stLongaSuporte == 'MITIGADA' and low < low[1]

brkBuyInicioCiclo = brkBuyRaw and cicloAntes != 'ALTA'
brkSellInicioCiclo = brkSellRaw and cicloAntes != 'BAIXA'

if brkBuyRaw
    cicloAtual := 'ALTA'
    cicloAtual
if brkSellRaw
    cicloAtual := 'BAIXA'
    cicloAtual

// =========================================================================
// 6. CONTEXTO DO PULLBACK E LIBERAÇÃO
// =========================================================================
contextoPlbBuy = cicloAtual == 'ALTA' and stLongaSuporte == 'VÁLIDA'
contextoPlbSell = cicloAtual == 'BAIXA' and stLongaResistencia == 'VÁLIDA'

plbPermitidoNaVela = not(brkBuyRaw or brkSellRaw)

var bool plbBuyLiberado = false
var bool plbSellLiberado = false

if not contextoPlbBuy
    plbBuyLiberado := false
    plbBuyLiberado
else if nasceuRapidaSuporte
    plbBuyLiberado := true
    plbBuyLiberado

if not contextoPlbSell
    plbSellLiberado := false
    plbSellLiberado
else if nasceuRapidaResistencia
    plbSellLiberado := true
    plbSellLiberado

confirmaPlbBuy = open < gridInferiorInterno and close > gridInferiorInterno
confirmaPlbSell = open > gridSuperiorInterno and close < gridSuperiorInterno

plbBuyRaw = plbPermitidoNaVela and contextoPlbBuy and plbBuyLiberado and confirmaPlbBuy
plbSellRaw = plbPermitidoNaVela and contextoPlbSell and plbSellLiberado and confirmaPlbSell

// =========================================================================
// 7. MODO 6 — SEQUÊNCIA TRAVADA (BRK → PLB)
// =========================================================================
var bool m6BuyAguardandoBrk = true
var bool m6BuyAguardandoPlb = false
var bool m6SellAguardandoBrk = true
var bool m6SellAguardandoPlb = false

if cicloAtual != 'ALTA'
    m6BuyAguardandoBrk := true
    m6BuyAguardandoPlb := false
    m6BuyAguardandoPlb
if cicloAtual != 'BAIXA'
    m6SellAguardandoBrk := true
    m6SellAguardandoPlb := false
    m6SellAguardandoPlb

m6BuyBrkRaw = brkBuyRaw and (cicloAntes != 'ALTA' or m6BuyAguardandoBrk)
m6SellBrkRaw = brkSellRaw and (cicloAntes != 'BAIXA' or m6SellAguardandoBrk)
m6BuyPlbRaw = plbBuyRaw and m6BuyAguardandoPlb
m6SellPlbRaw = plbSellRaw and m6SellAguardandoPlb

if m6BuyBrkRaw
    m6BuyAguardandoBrk := false
    m6BuyAguardandoPlb := true
    m6SellAguardandoBrk := true
    m6SellAguardandoPlb := false
    m6SellAguardandoPlb
if m6SellBrkRaw
    m6SellAguardandoBrk := false
    m6SellAguardandoPlb := true
    m6BuyAguardandoBrk := true
    m6BuyAguardandoPlb := false
    m6BuyAguardandoPlb
if m6BuyPlbRaw
    m6BuyAguardandoPlb := false
    m6BuyAguardandoBrk := true
    m6BuyAguardandoBrk
if m6SellPlbRaw
    m6SellAguardandoPlb := false
    m6SellAguardandoBrk := true
    m6SellAguardandoBrk

// =========================================================================
// 8. FILTRO POR MODO OPERACIONAL
// =========================================================================
isM1 = modoOperacional == opM1
isM2 = modoOperacional == opM2
isM3 = modoOperacional == opM3
isM4 = modoOperacional == opM4
isM5 = modoOperacional == opM5
isM6 = modoOperacional == opM6
isM7 = modoOperacional == opM7

dcaPlbBuyRaw = plbPermitidoNaVela and cicloAtual == 'ALTA' and confirmaPlbBuy
dcaPlbSellRaw = plbPermitidoNaVela and cicloAtual == 'BAIXA' and confirmaPlbSell

showBuyBrk = isM1 or isM3 ? brkBuyRaw : isM2 or isM4 or isM7 ? brkBuyInicioCiclo : isM6 ? m6BuyBrkRaw : false
showSellBrk = isM1 or isM3 ? brkSellRaw : isM2 or isM4 or isM7 ? brkSellInicioCiclo : isM6 ? m6SellBrkRaw : false
showBuyPlb = isM1 or isM2 or isM5 ? plbBuyRaw : isM6 ? m6BuyPlbRaw : isM7 ? dcaPlbBuyRaw : false
showSellPlb = isM1 or isM2 or isM5 ? plbSellRaw : isM6 ? m6SellPlbRaw : isM7 ? dcaPlbSellRaw : false

if showBuyPlb
    plbBuyLiberado := false
    plbBuyLiberado
if showSellPlb
    plbSellLiberado := false
    plbSellLiberado

// =========================================================================
// 9. PLOTAGEM DOS SINAIS (COM CONTROLE DINÂMICO DE TAGS)
// =========================================================================
// SINAIS BUY BRK
condBB = enableSig and showBuyBrk
plotshape(condBB and showDirTxt and showTypeTxt, title = 'BUY BRK', text = 'BUY\nBRK', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 0), textcolor = color.white, size = size.normal)
plotshape(condBB and showDirTxt and not showTypeTxt, title = 'BUY', text = 'BUY', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 0), textcolor = color.white, size = size.normal)
plotshape(condBB and not showDirTxt and showTypeTxt, title = 'BRK', text = 'BRK', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 0), textcolor = color.white, size = size.normal)
plotshape(condBB and not showDirTxt and not showTypeTxt, title = 'Seta', style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0), size = size.normal)

// SINAIS BUY PLB
condBP = enableSig and showBuyPlb
plotshape(condBP and showDirTxt and showTypeTxt, title = 'BUY PLB', text = 'BUY\nPLB', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 20), textcolor = color.white, size = size.normal)
plotshape(condBP and showDirTxt and not showTypeTxt, title = 'BUY', text = 'BUY', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 20), textcolor = color.white, size = size.normal)
plotshape(condBP and not showDirTxt and showTypeTxt, title = 'PLB', text = 'PLB', style = shape.labelup, location = location.belowbar, color = color.new(color.lime, 20), textcolor = color.white, size = size.normal)
plotshape(condBP and not showDirTxt and not showTypeTxt, title = 'Seta', style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 20), size = size.normal)

// SINAIS SELL BRK
condSB = enableSig and showSellBrk
plotshape(condSB and showDirTxt and showTypeTxt, title = 'SELL BRK', text = 'SELL\nBRK', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), textcolor = color.white, size = size.normal)
plotshape(condSB and showDirTxt and not showTypeTxt, title = 'SELL', text = 'SELL', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), textcolor = color.white, size = size.normal)
plotshape(condSB and not showDirTxt and showTypeTxt, title = 'BRK', text = 'BRK', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 0), textcolor = color.white, size = size.normal)
plotshape(condSB and not showDirTxt and not showTypeTxt, title = 'Seta', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.normal)

// SINAIS SELL PLB
condSP = enableSig and showSellPlb
plotshape(condSP and showDirTxt and showTypeTxt, title = 'SELL PLB', text = 'SELL\nPLB', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 20), textcolor = color.white, size = size.normal)
plotshape(condSP and showDirTxt and not showTypeTxt, title = 'SELL', text = 'SELL', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 20), textcolor = color.white, size = size.normal)
plotshape(condSP and not showDirTxt and showTypeTxt, title = 'PLB', text = 'PLB', style = shape.labeldown, location = location.abovebar, color = color.new(color.red, 20), textcolor = color.white, size = size.normal)
plotshape(condSP and not showDirTxt and not showTypeTxt, title = 'Seta', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 20), size = size.normal)

// =========================================================================
// 10. PLOTAGEM DO CANAL OPERACIONAL E DAS NUVENS
// =========================================================================
plot(upper, color = colorLine, linewidth = 2)
plot(lower, color = colorLine, linewidth = 2)
plot(middleLine, color = colorLine, linewidth = 2)
plot(gridSuperiorInterno, color = colorLine, linewidth = 1)
plot(gridInferiorInterno, color = colorLine, linewidth = 1)

p_upper = plot(upper, display = display.none)
p_lower = plot(lower, display = display.none)
p_upper1 = plot(upper1, display = display.none)
p_lower1 = plot(lower1, display = display.none)
p_upper2 = plot(upper2, display = display.none)
p_lower2 = plot(lower2, display = display.none)

fill(p_upper2, p_upper1, color = c_nl_res)
fill(p_lower2, p_lower1, color = c_nl_sup)
fill(p_upper, p_upper1, color = c_nr_res)
fill(p_lower, p_lower1, color = c_nr_sup)

// Preenchimento Dinâmico do Canal Operacional Baseado no Ciclo
corCanalDin = cicloAtual == 'ALTA' ? color.new(color.green, 92) : cicloAtual == 'BAIXA' ? color.new(color.red, 92) : color.new(color.gray, 92)
fill(p_upper, p_lower, color = showCanalFill ? corCanalDin : na)

// =========================================================================
// 11. TEXTOS DE IDENTIFICAÇÃO À DIREITA DAS NUVENS
// =========================================================================
var label lblLongaSup = na
var label lblLongaRes = na
var label lblRapidaSup = na
var label lblRapidaRes = na
var label lblCanal = na

bool drawLbl = barstate.islast and showNames
pos_x = bar_index + labelOffset

lblLongaSup := f_atualiza_label(lblLongaSup, drawLbl, pos_x, (lower1 + lower2) / 2, 'NUVEM LONGA\nSuporte Estrutural\n' + stLongaSuporte, stLongaSuporte == 'VÁLIDA' ? color.new(color.green, 10) : color.new(color.gray, 35))
lblLongaRes := f_atualiza_label(lblLongaRes, drawLbl, pos_x, (upper1 + upper2) / 2, 'NUVEM LONGA\nResistência Estrutural\n' + stLongaResistencia, stLongaResistencia == 'VÁLIDA' ? color.new(color.red, 10) : color.new(color.gray, 35))
lblRapidaSup := f_atualiza_label(lblRapidaSup, drawLbl, pos_x, (lower + lower1) / 2, 'NUVEM RÁPIDA\nSuporte Dinâmico\n' + stRapidaSuporte, stRapidaSuporte == 'VÁLIDA' ? color.new(color.lime, 10) : color.new(color.gray, 35))
lblRapidaRes := f_atualiza_label(lblRapidaRes, drawLbl, pos_x, (upper + upper1) / 2, 'NUVEM RÁPIDA\nResistência Dinâmica\n' + stRapidaResistencia, stRapidaResistencia == 'VÁLIDA' ? color.new(color.red, 10) : color.new(color.gray, 35))
lblCanal := f_atualiza_label(lblCanal, drawLbl, pos_x, middleLine, 'CANAL OPERACIONAL\nGrid Interno', color.new(color.black, 10))

// =========================================================================
// 12. PAINEL SIMPLIFICADO (DASHBOARD)
// =========================================================================
if showDash and barstate.islast
    var table dash = table.new(position.bottom_right, 2, 9, border_width = 1, border_color = color.new(color.gray, 55))

    tModo = isM1 ? 'MODO 1\nCOMPLETO' : isM2 ? 'MODO 2\nESTRUTURAL' : isM3 ? 'MODO 3\nROMPIMENTOS' : isM4 ? 'MODO 4\nREVERSÃO' : isM5 ? 'MODO 5\nRETRAÇÕES' : isM6 ? 'MODO 6\nALTERNÂNCIA' : 'MODO 7\nDCA CLOUDGRID'
    cModo = isM1 ? color.new(color.blue, 35) : isM2 ? color.new(color.orange, 35) : isM3 ? color.new(color.maroon, 35) : isM4 ? color.new(color.teal, 35) : isM5 ? color.new(color.purple, 35) : isM6 ? color.new(color.fuchsia, 35) : color.new(color.yellow, 35)

    cAlta = cicloAtual == 'ALTA'
    cBaixa = cicloAtual == 'BAIXA'

    tCiclo = cAlta ? '▲ ALTA' : cBaixa ? '▼ BAIXA' : 'AGUARDANDO'
    cCiclo = cAlta ? color.new(color.green, 15) : cBaixa ? color.new(color.red, 15) : color.new(color.gray, 40)

    tLado = cAlta ? 'COMPRA / SUPORTE' : cBaixa ? 'VENDA / RESISTÊNCIA' : 'SEM CICLO ATIVO'
    cLado = cAlta ? color.new(color.green, 30) : cBaixa ? color.new(color.red, 30) : color.new(color.gray, 45)

    tNuvLong = cAlta ? stLongaSuporte : cBaixa ? stLongaResistencia : '—'
    cNuvLong = cAlta ? stLongaSuporte == 'VÁLIDA' ? color.new(color.green, 25) : color.new(color.gray, 50) : cBaixa ? stLongaResistencia == 'VÁLIDA' ? color.new(color.red, 25) : color.new(color.gray, 50) : color.new(color.gray, 60)

    tNuvRap = cAlta ? stRapidaSuporte : cBaixa ? stRapidaResistencia : '—'
    cNuvRap = cAlta ? stRapidaSuporte == 'VÁLIDA' ? color.new(color.green, 25) : color.new(color.gray, 50) : cBaixa ? stRapidaResistencia == 'VÁLIDA' ? color.new(color.red, 25) : color.new(color.gray, 50) : color.new(color.gray, 60)

    tSeq = isM6 ? cAlta ? m6BuyAguardandoPlb ? 'AGUARDA PLB' : 'AGUARDA BRK' : cBaixa ? m6SellAguardandoPlb ? 'AGUARDA PLB' : 'AGUARDA BRK' : '—' : isM7 ? 'IGNORADO NO M7' : cAlta ? nasceuRapidaSuporte ? 'NASCEU' : '—' : cBaixa ? nasceuRapidaResistencia ? 'NASCEU' : '—' : '—'
    cSeq = isM6 ? cAlta ? m6BuyAguardandoPlb ? color.new(color.lime, 20) : color.new(color.gray, 60) : cBaixa ? m6SellAguardandoPlb ? color.new(color.red, 20) : color.new(color.gray, 60) : color.new(color.gray, 60) : isM7 ? color.new(color.gray, 60) : cAlta ? nasceuRapidaSuporte ? color.new(color.lime, 20) : color.new(color.gray, 60) : cBaixa ? nasceuRapidaResistencia ? color.new(color.red, 20) : color.new(color.gray, 60) : color.new(color.gray, 60)

    tConf = cAlta ? confirmaPlbBuy ? 'OK\nOpen < 1/4 Inf.\nClose > 1/4 Inf.' : '—' : cBaixa ? confirmaPlbSell ? 'OK\nOpen > 1/4 Sup.\nClose < 1/4 Sup.' : '—' : '—'
    cConf = cAlta ? confirmaPlbBuy ? color.new(color.green, 30) : color.new(color.gray, 60) : cBaixa ? confirmaPlbSell ? color.new(color.red, 30) : color.new(color.gray, 60) : color.new(color.gray, 60)

    tLargura = str.tostring(larguraCanalInterno, format.mintick) + ' pts\n' + str.tostring(larguraCanalInternoPct, '#.##') + '%'

    tSinal = showBuyBrk ? 'BUY BRK' : showBuyPlb ? 'BUY PLB' : showSellBrk ? 'SELL BRK' : showSellPlb ? 'SELL PLB' : '—'
    cSinal = showBuyBrk or showBuyPlb ? color.new(color.green, 20) : showSellBrk or showSellPlb ? color.new(color.red, 20) : color.new(color.gray, 60)

    f_add_row(dash, 0, 'BRN CLOUDGRID', tLado, color.new(color.black, 5), cLado)
    f_add_row(dash, 1, 'MODO', tModo, color.new(color.black, 25), cModo)
    f_add_row(dash, 2, 'CICLO', tCiclo, color.new(color.black, 25), cCiclo)
    f_add_row(dash, 3, 'NUVEM LONGA', tNuvLong, color.new(color.black, 35), cNuvLong)
    f_add_row(dash, 4, 'NUVEM RÁPIDA', tNuvRap, color.new(color.black, 35), cNuvRap)
    f_add_row(dash, 5, isM6 ? 'SEQUÊNCIA' : 'NASCIMENTO', tSeq, color.new(color.black, 35), cSeq)
    f_add_row(dash, 6, 'CONFIRMAÇÃO PLB', tConf, color.new(color.black, 35), cConf)
    f_add_row(dash, 7, 'LARGURA CANAL', tLargura, color.new(color.black, 35), color.new(color.blue, 45))
    f_add_row(dash, 8, 'SINAL ATUAL', tSinal, color.new(color.black, 20), cSinal)

// =========================================================================
// 13. ALERTAS
// =========================================================================
alertcondition(showBuyBrk or showSellBrk, '⚠️ SINAL BREAKOUT', 'BRN HILo CloudGrid: Sinal BRK.')
alertcondition(showBuyPlb or showSellPlb, '🔄 SINAL PULLBACK', 'BRN HILo CloudGrid: Sinal PLB.')
alertcondition(showBuyBrk, 'BUY BRK', 'BRN HILo CloudGrid: BUY BRK.')
alertcondition(showBuyPlb, 'BUY PLB', 'BRN HILo CloudGrid: BUY PLB.')
alertcondition(showSellBrk, 'SELL BRK', 'BRN HILo CloudGrid: SELL BRK.')
alertcondition(showSellPlb, 'SELL PLB', 'BRN HILo CloudGrid: SELL PLB.')
````
