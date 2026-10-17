# SMC By Alex Melo

- url: https://www.tradingview.com/script/uG0Pe1Ni/
- type: indicator
- pine_id: PUB;db86bb27f19e42afa1bb6ff2b45f1f5b
- version: 1.0

## Description

SMC By Alex Melo

Este indicador é uma fusão institucional avançada baseada nos conceitos de Smart Money (SMC), combinando o rastreio de liquidez com a mitigação inteligente de ineficiências de preço. 

Foi desenvolvido para manter o gráfico "limpo", eliminando ruído visual à medida que as zonas são mitigadas, permitindo uma leitura de fluxo de ordens (Order Flow) de alta precisão.

Principais Funcionalidades (O Setup Tríplice):
1. Radar de Liquidez (EQH / EQL): Identifica e marca automaticamente zonas de topos e fundos iguais, revelando onde estão os Stop Losses do retalho (varejo) e para onde o Smart Money irá arrastar o preço.
2. Estrutura e Ineficiência (Auto-Limpeza): Imprime quebras de estrutura (BOS e CHoCH) com filtro opcional de "Fechamento de Corpo". Identifica Fair Value Gaps (FVG) e Order Blocks (OB), com um diferencial de limpeza automática: assim que o preço mitiga (preenche) o bloco ou o FVG, a zona é automaticamente apagada ou reduzida no gráfico.
3. Golden Pocket Institucional (0.705 Fibo): Calcula e projeta de forma automática a zona de desconto/prémio perfeita (Optimal Trade Entry - OTE entre 0.705 e 0.786) na perna de tendência atual, eliminando a necessidade de traçar a ferramenta de Fibonacci manualmente a cada novo movimento.

Instruções de Uso:
Aguarde a varredura da liquidez (EQL/EQH). Confirme a mudança de tendência com um CHoCH validado. Posicione as suas ordens limitadas dentro da caixa "Golden Pocket" que será desenhada automaticamente dentro do Fair Value Gap mais recente.

Gestão de Risco:
Utilize sempre lotes dinâmicos com risco fixo por operação. Não opere contra a tendência macro de 4 Horas.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Desenvolvido e Codificado por Gemini IA (A pedido do Diretor de Risco)
// Fusão Definitiva: Liquidez (LuxAlgo) + Limpeza de Ineficiência (LudoGH68) + Golden Pocket Institucional.

//@version=5
indicator('SMC Híbrido Diretor 👑 [By IA]', 'SMC Híbrido IA', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// CONSTANTES & CONFIGURAÇÕES GLOBAIS
//---------------------------------------------------------------------------------------------------------------------{
BULLISH_LEG                     = 1
BEARISH_LEG                     = 0
BULLISH                         = +1
BEARISH                         = -1

GREEN                           = #089981
RED                             = #F23645
BLUE                            = #2157f3
GRAY                            = #878b94
GOLD                            = #ffb700
MONO_BULLISH                    = #b2b5be
MONO_BEARISH                    = #5d606b

ALL                             = 'Todos'
BOS                             = 'Apenas BOS'
CHOCH                           = 'Apenas CHoCH'

TINY                            = size.tiny
SMALL                           = size.small
NORMAL                          = size.normal

BODY_BREAK                      = 'Corpo da Vela (Ludo)'
WICK_BREAK                      = 'Pavio (Agressivo)'

SMART_GROUP                     = '🧠 Configurações Globais'
INTERNAL_GROUP                  = '🔬 Estrutura Interna (Gatilho)'
SWING_GROUP                     = '🧭 Estrutura Swing (Bússola)'
BLOCKS_GROUP                    = '🧱 Order Blocks (Híbrido)'
EQUAL_GROUP                     = '🧲 Radar de Liquidez (EQH/EQL)'
GAPS_GROUP                      = '🕳️ Fair Value Gaps (Auto-Limpeza)'
GP_GROUP                        = '🎯 Golden Pocket (0.705 Fibo)'

// Estilo Global
styleInput                      = input.string( 'Colorido',    'Estilo de Cores',           group = SMART_GROUP, options = ['Colorido', 'Monocromático'])
breakoutType                    = input.string( BODY_BREAK, 'Confirmação de Rompimento', group = SMART_GROUP, options = [BODY_BREAK, WICK_BREAK], tooltip = "Exigir fechamento de corpo blinda contra manipulações.")

// Estrutura Interna (Micro)
showInternalsInput              = input(        true,       'Mostrar Estrutura Interna',    group = INTERNAL_GROUP)
showInternalBullInput           = input.string( ALL,        'Estrutura de Alta',            group = INTERNAL_GROUP, inline = 'ibull', options = [ALL,BOS,CHOCH])
internalBullColorInput          = input(        GREEN,      '',                             group = INTERNAL_GROUP, inline = 'ibull')
showInternalBearInput           = input.string( ALL,        'Estrutura de Baixa' ,          group = INTERNAL_GROUP, inline = 'ibear', options = [ALL,BOS,CHOCH])
internalBearColorInput          = input(        RED,        '',                             group = INTERNAL_GROUP, inline = 'ibear')
internalStructureSize           = input.string( TINY,       'Tamanho da Etiqueta',          group = INTERNAL_GROUP, options = [TINY,SMALL,NORMAL])

// Estrutura Swing (Macro)
showStructureInput              = input(        true,       'Mostrar Estrutura Swing',      group = SWING_GROUP)
showSwingBullInput              = input.string( ALL,        'Estrutura de Alta',            group = SWING_GROUP,    inline = 'bull',    options = [ALL,BOS,CHOCH])
swingBullColorInput             = input(        GREEN,      '',                             group = SWING_GROUP,    inline = 'bull')
showSwingBearInput              = input.string( ALL,        'Estrutura de Baixa',           group = SWING_GROUP,    inline = 'bear',    options = [ALL,BOS,CHOCH])
swingBearColorInput             = input(        RED,        '',                             group = SWING_GROUP,    inline = 'bear')
swingStructureSize              = input.string( SMALL,      'Tamanho da Etiqueta',          group = SWING_GROUP,    options = [TINY,SMALL,NORMAL])
swingsLengthInput               = input.int(    50,         'Tamanho da Perna Swing',       group = SWING_GROUP,    minval = 10)

// Order Blocks
showInternalOrderBlocksInput    = input(        true,       'Mostrar OBs Internos' ,        group = BLOCKS_GROUP,   inline = 'iob')
internalOrderBlocksSizeInput    = input.int(    5,          'Qtd',                          group = BLOCKS_GROUP,   minval = 1, maxval = 20, inline = 'iob')
showSwingOrderBlocksInput       = input(        false,      'Mostrar OBs Swing',            group = BLOCKS_GROUP,   inline = 'ob')
swingOrderBlocksSizeInput       = input.int(    5,          'Qtd',                          group = BLOCKS_GROUP,   minval = 1, maxval = 20, inline = 'ob') 
orderBlockMitigationInput       = input.string( 'Pavio',    'Mitigar OB usando:',           group = BLOCKS_GROUP,   options = ['Corpo da Vela','Pavio']) 
internalBullishOrderBlockColor  = input.color(color.new(#3179f5, 80), 'OB Interno Alta',    group = BLOCKS_GROUP)
internalBearishOrderBlockColor  = input.color(color.new(#f77c80, 80), 'OB Interno Baixa',   group = BLOCKS_GROUP)
swingBullishOrderBlockColor     = input.color(color.new(#1848cc, 80), 'OB Swing Alta',      group = BLOCKS_GROUP)
swingBearishOrderBlockColor     = input.color(color.new(#b22833, 80), 'OB Swing Baixa',     group = BLOCKS_GROUP)

// Radar de Liquidez (EQH/EQL LuxAlgo)
showEqualHighsLowsInput         = input(        true,       'Ligar Radar de Liquidez (EQH/EQL)', group = EQUAL_GROUP)
equalHighsLowsLengthInput       = input.int(    3,          'Confirmação de Barras',        group = EQUAL_GROUP,    minval = 1)
equalHighsLowsThresholdInput    = input.float(  0.1,        'Sensibilidade (Ímã)',          group = EQUAL_GROUP,    minval = 0, maxval = 0.5, step = 0.1)
equalHighsLowsSizeInput         = input.string( TINY,       'Tamanho da Etiqueta',          group = EQUAL_GROUP,    options = [TINY,SMALL,NORMAL])

// Fair Value Gaps (FVG Auto-Limpeza)
showFairValueGapsInput          = input(        true,       'Mostrar Fair Value Gaps (FVG)',group = GAPS_GROUP)
fairValueGapsBullColorInput     = input.color(color.new(#00ff68, 70), 'Cor FVG de Alta' ,   group = GAPS_GROUP)
fairValueGapsBearColorInput     = input.color(color.new(#ff0008, 70), 'Cor FVG de Baixa' ,  group = GAPS_GROUP)
reduceMitigatedFvgInput         = input(        true,       'Apagar/Reduzir FVG Mitigado',  group = GAPS_GROUP)

// Golden Pocket Institucional (Nova Feature)
showGoldenPocketInput           = input(        true,       'Auto Fibo 0.705 (Golden Pocket)', group = GP_GROUP, tooltip="Desenha a zona premium/discount ideal automaticamente")
goldenPocketColorInput          = input.color(color.new(GOLD, 75), 'Cor da Zona OTE (0.705)',  group = GP_GROUP)


//---------------------------------------------------------------------------------------------------------------------}
// DATA STRUCTURES
//---------------------------------------------------------------------------------------------------------------------{
type trailingExtremes
    float top
    float bottom
    int barTime
    int barIndex
    int lastTopTime
    int lastBottomTime

type fairValueGap
    float top
    float bottom
    int bias
    box topBox
    box bottomBox
    bool mitigated

type trend
    int bias    

type equalDisplay
    line l_ine      = na
    label l_abel    = na

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime     = time
    int barIndex    = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime    
    int bias

var pivot swingHigh                 = pivot.new(na,na,false)
var pivot swingLow                  = pivot.new(na,na,false)
var pivot internalHigh              = pivot.new(na,na,false)
var pivot internalLow               = pivot.new(na,na,false)
var pivot equalHigh                 = pivot.new(na,na,false)
var pivot equalLow                  = pivot.new(na,na,false)
var trend swingTrend                = trend.new(0)
var trend internalTrend             = trend.new(0)
var equalDisplay equalHighDisplay   = equalDisplay.new()
var equalDisplay equalLowDisplay    = equalDisplay.new()

var array<fairValueGap> fairValueGaps = array.new<fairValueGap>()
var array<float> parsedHighs        = array.new<float>()
var array<float> parsedLows         = array.new<float>()
var array<float> highs              = array.new<float>()
var array<float> lows               = array.new<float>()
var array<int> times                = array.new<int>()
var trailingExtremes trailing       = trailingExtremes.new()

var array<orderBlock> swingOrderBlocks      = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks   = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes        = array.new<box>()
var array<box> internalOrderBlocksBoxes     = array.new<box>()

var swingBullishColor               = styleInput == 'Monocromático' ? MONO_BULLISH : swingBullColorInput
var swingBearishColor               = styleInput == 'Monocromático' ? MONO_BEARISH : swingBearColorInput
var fairValueGapBullishColor        = styleInput == 'Monocromático' ? color.new(MONO_BULLISH,70) : fairValueGapsBullColorInput
var fairValueGapBearishColor        = styleInput == 'Monocromático' ? color.new(MONO_BEARISH,70) : fairValueGapsBearColorInput

varip int currentBarIndex           = bar_index
varip int lastBarIndex              = bar_index
var initialTime                     = time

if barstate.isfirst
    if showSwingOrderBlocksInput
        for index = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na,na,na,na,xloc = xloc.bar_time,extend = extend.right))
    if showInternalOrderBlocksInput
        for index = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na,na,na,na,xloc = xloc.bar_time,extend = extend.right))

bearishOrderBlockMitigationSource   = orderBlockMitigationInput == 'Corpo da Vela' ? close : high
bullishOrderBlockMitigationSource   = orderBlockMitigationInput == 'Corpo da Vela' ? close : low
atrMeasure                          = ta.atr(200)
volatilityMeasure                   = atrMeasure
highVolatilityBar                   = (high - low) >= (2 * volatilityMeasure)
parsedHigh                          = highVolatilityBar ? low : high
parsedLow                           = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

//---------------------------------------------------------------------------------------------------------------------}
// FUNÇÕES DE LÓGICA DO ALGORITMO
//---------------------------------------------------------------------------------------------------------------------{
leg(int size) =>
    var leg     = 0    
    newLegHigh  = high[size] > ta.highest( size)
    newLegLow   = low[size]  < ta.lowest(  size)
    
    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG
    leg

startOfNewLeg(int leg)      => ta.change(leg) != 0
startOfBearishLeg(int leg)  => ta.change(leg) == -1
startOfBullishLeg(int leg)  => ta.change(leg) == +1

drawEqualHighLow(pivot p_ivot, float level, int size, bool equalHigh) =>
    equalDisplay e_qualDisplay = equalHigh ? equalHighDisplay : equalLowDisplay
    
    string tag          = 'EQL'
    color equalColor    = swingBullishColor
    string labelStyle   = label.style_label_up

    if equalHigh
        tag         := 'EQH'
        equalColor  := swingBearishColor
        labelStyle  := label.style_label_down

    line.delete(    e_qualDisplay.l_ine)
    label.delete(   e_qualDisplay.l_abel)
        
    e_qualDisplay.l_ine     := line.new(chart.point.new(p_ivot.barTime,na,p_ivot.currentLevel), chart.point.new(time[size],na,level), xloc = xloc.bar_time, color = equalColor, style = line.style_dotted)
    labelPosition           = math.round(0.5*(p_ivot.barIndex + bar_index - size))
    e_qualDisplay.l_abel    := label.new(chart.point.new(na,labelPosition,level), tag, xloc.bar_index, color = color(na), textcolor = equalColor, style = labelStyle, size = equalHighsLowsSizeInput)

updateTrailingExtremes() =>
    trailing.top            := math.max(high,trailing.top)
    trailing.lastTopTime    := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom         := math.min(low,trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

getCurrentStructure(int size,bool equalHighLow = false, bool internal = false) =>        
    currentLeg              = leg(size)
    newPivot                = startOfNewLeg(currentLeg)
    pivotLow                = startOfBullishLeg(currentLeg)
    pivotHigh               = startOfBearishLeg(currentLeg)

    if newPivot
        if pivotLow
            pivot p_ivot    = equalHighLow ? equalLow : internal ? internalLow : swingLow    

            if equalHighLow and math.abs(p_ivot.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure                
                drawEqualHighLow(p_ivot, low[size], size, false)

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := low[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]
            
            if not equalHighLow and not internal
                trailing.bottom         := p_ivot.currentLevel
                trailing.barTime        := p_ivot.barTime
                trailing.barIndex       := p_ivot.barIndex
                trailing.lastBottomTime := p_ivot.barTime

        else
            pivot p_ivot = equalHighLow ? equalHigh : internal ? internalHigh : swingHigh

            if equalHighLow and math.abs(p_ivot.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot,high[size],size,true)

            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]
            
            if not equalHighLow and not internal
                trailing.top            := p_ivot.currentLevel
                trailing.barTime        := p_ivot.barTime
                trailing.barIndex       := p_ivot.barIndex
                trailing.lastTopTime    := p_ivot.barTime

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>    
    var line l_ine      = line.new(na,na,na,na,xloc = xloc.bar_time)
    var label l_abel    = label.new(na,na)

    l_ine.delete()
    l_abel.delete()

    l_ine   := line.new(chart.point.new(p_ivot.barTime,na,p_ivot.currentLevel), chart.point.new(time,na,p_ivot.currentLevel), xloc.bar_time, color=structureColor, style=lineStyle)
    l_abel  := label.new(chart.point.new(na,math.round(0.5*(p_ivot.barIndex+bar_index)),p_ivot.currentLevel), tag, xloc.bar_index, color=color(na), textcolor=structureColor, style=labelStyle, size = labelSize)

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks

    for [index,eachOrderBlock] in orderBlocks
        bool crossedOderBlock = false
        if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
            crossedOderBlock := true
        else if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
            crossedOderBlock := true
            
        if crossedOderBlock                    
            orderBlocks.remove(index)            

storeOrdeBlock(pivot p_ivot,bool internal = false,int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> a_rray = na
        int parsedIndex = na

        if bias == BEARISH
            a_rray      := parsedHighs.slice(p_ivot.barIndex,bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.max())  
        else
            a_rray      := parsedLows.slice(p_ivot.barIndex,bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.min())                        

        orderBlock o_rderBlock          = orderBlock.new(parsedHighs.get(parsedIndex), parsedLows.get(parsedIndex), times.get(parsedIndex),bias)
        array<orderBlock> orderBlocks   = internal ? internalOrderBlocks : swingOrderBlocks
        
        if orderBlocks.size() >= 100
            orderBlocks.pop()
        orderBlocks.unshift(o_rderBlock)

drawOrderBlocks(bool internal = false) =>        
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    orderBlocksSize = orderBlocks.size()

    if orderBlocksSize > 0        
        maxOrderBlocks                      = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        array<orderBlock> parsedOrdeBlocks  = orderBlocks.slice(0, math.min(maxOrderBlocks,orderBlocksSize))
        array<box> b_oxes                   = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes        

        for [index,eachOrderBlock] in parsedOrdeBlocks
            orderBlockColor = styleInput == 'Monocromático' ? (eachOrderBlock.bias == BEARISH ? color.new(MONO_BEARISH,80) : color.new(MONO_BULLISH,80)) : internal ? (eachOrderBlock.bias == BEARISH ? internalBearishOrderBlockColor : internalBullishOrderBlockColor) : (eachOrderBlock.bias == BEARISH ? swingBearishOrderBlockColor : swingBullishOrderBlockColor)

            box b_ox        = b_oxes.get(index)
            b_ox.set_top_left_point(    chart.point.new(eachOrderBlock.barTime,na,eachOrderBlock.barHigh))
            b_ox.set_bottom_right_point(chart.point.new(last_bar_time,na,eachOrderBlock.barLow))        
            b_ox.set_border_color(      internal ? na : orderBlockColor)
            b_ox.set_bgcolor(           orderBlockColor)


displayStructure(bool internal = false) =>
    pivot p_ivot    = internal ? internalHigh : swingHigh
    trend t_rend    = internal ? internalTrend : swingTrend

    lineStyle       = internal ? line.style_dashed : line.style_solid
    labelSize       = internal ? internalStructureSize : swingStructureSize

    // LÓGICA DE ROMPIMENTO (CORPO VS PAVIO)
    bullishBreak = breakoutType == BODY_BREAK ? ta.crossover(close, p_ivot.currentLevel) : ta.crossover(high, p_ivot.currentLevel)
    bearishBreak = breakoutType == BODY_BREAK ? ta.crossunder(close, p_ivot.currentLevel) : ta.crossunder(low, p_ivot.currentLevel)
    
    bullishColor    = styleInput == 'Monocromático' ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput

    if bullishBreak and not p_ivot.crossed
        string tag = t_rend.bias == BEARISH ? CHOCH : BOS

        p_ivot.crossed  := true
        t_rend.bias     := BULLISH

        displayCondition = internal ? showInternalsInput and (showInternalBullInput == ALL or (showInternalBullInput == BOS and tag != CHOCH) or (showInternalBullInput == CHOCH and tag == CHOCH)) : showStructureInput and (showSwingBullInput == ALL or (showSwingBullInput == BOS and tag != CHOCH) or (showSwingBullInput == CHOCH and tag == CHOCH))

        if displayCondition                        
            drawStructure(p_ivot,tag,bullishColor,lineStyle,label.style_label_down,labelSize)

        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrdeBlock(p_ivot,internal,BULLISH)

    p_ivot          := internal ? internalLow : swingLow    
    bearishColor    = styleInput == 'Monocromático' ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput

    bearishBreak2 = breakoutType == BODY_BREAK ? ta.crossunder(close, p_ivot.currentLevel) : ta.crossunder(low, p_ivot.currentLevel)

    if bearishBreak2 and not p_ivot.crossed
        string tag = t_rend.bias == BULLISH ? CHOCH : BOS

        p_ivot.crossed := true
        t_rend.bias := BEARISH

        displayCondition = internal ? showInternalsInput and (showInternalBearInput == ALL or (showInternalBearInput == BOS and tag != CHOCH) or (showInternalBearInput == CHOCH and tag == CHOCH)) : showStructureInput and (showSwingBearInput == ALL or (showSwingBearInput == BOS and tag != CHOCH) or (showSwingBearInput == CHOCH and tag == CHOCH))
        
        if displayCondition                        
            drawStructure(p_ivot,tag,bearishColor,lineStyle,label.style_label_up,labelSize)

        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrdeBlock(p_ivot,internal,BEARISH)

fairValueGapBox(leftTime,rightTime,topPrice,bottomPrice,boxColor) => box.new(chart.point.new(leftTime,na,topPrice),chart.point.new(rightTime + (time-time[1]),na,bottomPrice), xloc=xloc.bar_time, border_color = boxColor, bgcolor = boxColor)

deleteFairValueGaps() =>
    for [index,eachFairValueGap] in fairValueGaps
        bool isMitigated = false
        
        if eachFairValueGap.bias == BULLISH
            if low <= eachFairValueGap.bottom 
                isMitigated := true
            else if reduceMitigatedFvgInput and low < eachFairValueGap.top
                eachFairValueGap.topBox.set_top(low)
                eachFairValueGap.bottomBox.set_top(low)
                
        else if eachFairValueGap.bias == BEARISH
            if high >= eachFairValueGap.top
                isMitigated := true
            else if reduceMitigatedFvgInput and high > eachFairValueGap.bottom
                eachFairValueGap.topBox.set_bottom(high)
                eachFairValueGap.bottomBox.set_bottom(high)
                
        if isMitigated
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            fairValueGaps.remove(index)
    
drawFairValueGaps() => 
    [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(syminfo.tickerid, "", [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],lookahead = barmerge.lookahead_on)

    barDeltaPercent     = (lastClose - lastOpen) / (lastOpen * 100)
    threshold           = ta.cum(math.abs(barDeltaPercent)) / bar_index * 2

    bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold 
    bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold 

    if bullishFairValueGap
        fairValueGaps.unshift(fairValueGap.new(currentLow,last2High,BULLISH,fairValueGapBox(lastTime,currentTime,currentLow,math.avg(currentLow,last2High),fairValueGapBullishColor),fairValueGapBox(lastTime,currentTime,math.avg(currentLow,last2High),last2High,fairValueGapBullishColor), false))
    if bearishFairValueGap
        fairValueGaps.unshift(fairValueGap.new(currentHigh,last2Low,BEARISH,fairValueGapBox(lastTime,currentTime,currentHigh,math.avg(currentHigh,last2Low),fairValueGapBearishColor),fairValueGapBox(lastTime,currentTime,math.avg(currentHigh,last2Low),last2Low,fairValueGapBearishColor), false))


// FUNÇÃO INÉDITA: GOLDEN POCKET 0.705
drawGoldenPocket() =>
    var box gpBox = box.new(na,na,na,na, bgcolor = goldenPocketColorInput, border_color = color(na), xloc = xloc.bar_time)
    var label gpLabel = label.new(na,na, text = "0.705 OTE", color = color(na), textcolor = goldenPocketColorInput, style = label.style_label_left, size = size.small)

    if trailing.top != 0 and trailing.bottom != 0
        float fiboRange = trailing.top - trailing.bottom
        float gpTop = na
        float gpBottom = na
        
        // Calcula 0.705 a 0.786 com base na tendência macro
        if swingTrend.bias == BULLISH
            gpTop := trailing.top - (fiboRange * 0.705)
            gpBottom := trailing.top - (fiboRange * 0.786)
        else
            gpTop := trailing.bottom + (fiboRange * 0.786)
            gpBottom := trailing.bottom + (fiboRange * 0.705)
            
        gpBox.set_top_left_point(chart.point.new(trailing.barTime, na, gpTop))
        gpBox.set_bottom_right_point(chart.point.new(last_bar_time + 10 * (time-time[1]), na, gpBottom))
        gpLabel.set_point(chart.point.new(last_bar_time + 10 * (time-time[1]), na, gpTop))


//---------------------------------------------------------------------------------------------------------------------}
// EXECUÇÃO PRINCIPAL
//---------------------------------------------------------------------------------------------------------------------{
if showGoldenPocketInput
    updateTrailingExtremes()

if showFairValueGapsInput
    deleteFairValueGaps()

getCurrentStructure(swingsLengthInput,false)
getCurrentStructure(5,false,true)

if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput,true)

if showInternalsInput or showInternalOrderBlocksInput
    displayStructure(true)

if showStructureInput or showSwingOrderBlocksInput
    displayStructure()

if showInternalOrderBlocksInput
    deleteOrderBlocks(true)

if showSwingOrderBlocksInput
    deleteOrderBlocks()

if showFairValueGapsInput
    drawFairValueGaps()

if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput        
        drawOrderBlocks(true)
        
    if showSwingOrderBlocksInput        
        drawOrderBlocks()
        
    if showGoldenPocketInput
        drawGoldenPocket()

lastBarIndex    := currentBarIndex
currentBarIndex := bar_index

// Fim do código - SMC Híbrido Diretor [By IA]
````
