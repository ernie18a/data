# REN FVG Detector - Candle Pattern

- url: https://www.tradingview.com/script/EbXL0xDl/
- type: indicator
- pine_id: PUB;c30a211431d2419894552e79574f57bc
- version: 1.0

## Description

FVGを自動検知します

## Source Code

````pine
//@version=5
indicator("FVG Detector - Candle Pattern [DEBUG]", "FVG Pattern", overlay = true,
 max_lines_count = 500, max_labels_count = 500)

// ─── Inputs ───────────────────────────────────────────────────────────────────
VFVGFilter     = input.string('On',  'FVG Filter', ['On', 'Off'], group = 'FVG Setting')
VFVGFilterType = input.string('Defensive', 'FVG Filter Type',
 ['Very Aggressive', 'Aggressive', 'Defensive', 'Very Defensive'], group = 'FVG Setting')
VShowDeFVG = input.bool(true, 'Show Demand FVG')
VShowSuFVG = input.bool(true, 'Show Supply FVG')

// ─── デバッグ用input ──────────────────────────────────────────────────────────
VDebug = input.bool(false, 'Debug Mode（条件ラベル表示）', group = 'Debug')

// ─── Main Function ─────────────────────────────────────────────────────────────
FVGDetector(FVGFilter, FVGFilterType, ShowDeFVG, ShowSuFVG, DebugMode) =>

    var float DDFVG   = 0.0
    var float DPFVG   = 0.0
    var float SDFVG   = 0.0
    var float SPFVG   = 0.0
    var int   BarDFVG = 0
    var int   BarSFVG = 0

    var line     DDistal   = na
    var line     DProximal = na
    var linefill Dfillline = na
    var label    DFVGLabel = na

    var line     SDistal   = na
    var line     SProximal = na
    var linefill Sfillline = na
    var label    SFVGLabel = na

    var bool DMitigated = true
    var bool SMitigated = true

    ATR = ta.atr(55)

    // ── ローソク足パターン条件 ──
    // 買い：[2]陰線 + [1]陽線 + [0]陽線
    demandPattern = (close[2] < open[2]) and (close[1] > open[1]) and (close > open)
    // 売り：[2]陽線 + [1]陰線 + [0]陰線
    supplyPattern = (close[2] > open[2]) and (close[1] < open[1]) and (close < open)

    // ── ギャップ基本条件 ──
    gapUp   = low  > high[2]
    gapDown = high < low[2]

    // ── デバッグ：ギャップのみ成立でラベル表示 ──
    if DebugMode
        if gapUp and not demandPattern
            label.new(bar_index, low,
             text  = '✗Pat\n[2]' + (close[2]<open[2]?'▼':'▲') +
                     ' [1]' + (close[1]>open[1]?'▲':'▼') +
                     ' [0]' + (close>open?'▲':'▼'),
             style = label.style_label_up,
             color = color.rgb(255,200,0,20), textcolor = color.black,
             size  = size.small)
        if gapDown and not supplyPattern
            label.new(bar_index, high,
             text  = '✗Pat\n[2]' + (close[2]>open[2]?'▲':'▼') +
                     ' [1]' + (close[1]<open[1]?'▼':'▲') +
                     ' [0]' + (close<open?'▼':'▲'),
             style = label.style_label_down,
             color = color.rgb(255,200,0,20), textcolor = color.black,
             size  = size.small)
        if gapUp and demandPattern
            // ATRフィルター確認
            atrOk  = (high[1] - low[1]) >= (1.5 * ATR)
            bodyOk = math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7
            label.new(bar_index, low,
             text  = '△Gap+Pat\nATR:' + (atrOk?'OK':'NG') +
                     ' Body:' + (bodyOk?'OK':'NG'),
             style = label.style_label_up,
             color = color.rgb(0,200,255,20), textcolor = color.black,
             size  = size.small)
        if gapDown and supplyPattern
            atrOk  = (high[1] - low[1]) >= (1.5 * ATR)
            bodyOk = math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7
            label.new(bar_index, high,
             text  = '△Gap+Pat\nATR:' + (atrOk?'OK':'NG') +
                     ' Body:' + (bodyOk?'OK':'NG'),
             style = label.style_label_down,
             color = color.rgb(0,200,255,20), textcolor = color.black,
             size  = size.small)

    // ── Demand FVG フィルター条件 ──
    DConditionFVG = false
    if FVGFilter == 'Off'
        DConditionFVG := gapUp and demandPattern
    else
        if FVGFilterType == 'Very Aggressive'
            DConditionFVG := gapUp and demandPattern and (high > high[1])
        else if FVGFilterType == 'Aggressive'
            DConditionFVG := gapUp and demandPattern and (high > high[1]) and
             ((high[1] - low[1]) >= (1.0 * ATR))
        else if FVGFilterType == 'Defensive'
            DConditionFVG := gapUp and demandPattern and (high > high[1]) and
             ((high[1] - low[1]) >= (1.5 * ATR)) and
             (math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7)
        else if FVGFilterType == 'Very Defensive'
            DConditionFVG := gapUp and demandPattern and (high > high[1]) and
             ((high[1] - low[1]) >= (1.5 * ATR)) and
             (math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7) and
             (math.abs((close[2] - open[2]) / (high[2] - low[2])) > 0.35) and
             (math.abs((close   - open  ) / (high   - low  )) > 0.35)

    // ── Supply FVG フィルター条件 ──
    SConditionFVG = false
    if FVGFilter == 'Off'
        SConditionFVG := gapDown and supplyPattern
    else
        if FVGFilterType == 'Very Aggressive'
            SConditionFVG := gapDown and supplyPattern and (low < low[1])
        else if FVGFilterType == 'Aggressive'
            SConditionFVG := gapDown and supplyPattern and (low < low[1]) and
             ((high[1] - low[1]) >= (1.0 * ATR))
        else if FVGFilterType == 'Defensive'
            SConditionFVG := gapDown and supplyPattern and (low < low[1]) and
             ((high[1] - low[1]) >= (1.5 * ATR)) and
             (math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7)
        else if FVGFilterType == 'Very Defensive'
            SConditionFVG := gapDown and supplyPattern and (low < low[1]) and
             ((high[1] - low[1]) >= (1.5 * ATR)) and
             (math.abs((close[1] - open[1]) / (high[1] - low[1])) > 0.7) and
             (math.abs((close[2] - open[2]) / (high[2] - low[2])) > 0.35) and
             (math.abs((close   - open  ) / (high   - low  )) > 0.35)

    // ─────────────────────────────────────────────────────────────────────────
    // Demand FVG 描画 & Mitigation
    // ─────────────────────────────────────────────────────────────────────────
    if DConditionFVG and ShowDeFVG
        DDFVG   := high[2]
        DPFVG   := low
        BarDFVG := bar_index
        DDistal   := line.new(BarDFVG, DDFVG, BarDFVG, DDFVG,
         color = color.rgb(0,0,0), style = line.style_dotted, width = 1)
        DProximal := line.new(BarDFVG, DPFVG, BarDFVG, DPFVG,
         color = color.rgb(0,0,0), style = line.style_dotted, width = 1)
        Dfillline := linefill.new(DDistal, DProximal, color = #a9d60580)
        DFVGLabel := label.new(BarDFVG, DDFVG, text = 'FVG ▲',
         style = label.style_label_up,
         color = color.rgb(255,255,255,100), textcolor = color.rgb(0,120,0),
         textalign = text.align_center, size = size.small)

    if ((low > DDFVG) or DDFVG == DDFVG[1]) and DMitigated == true
        line.set_x2(DDistal,   bar_index + 1)
        line.set_x2(DProximal, bar_index + 1)
        label.set_x(DFVGLabel, math.round((BarDFVG + bar_index) / 2))

    if (low[1] >= DPFVG) and (low <= DPFVG)
        DMitigated := false

    if DConditionFVG
        DMitigated := true

    // ─────────────────────────────────────────────────────────────────────────
    // Supply FVG 描画 & Mitigation
    // ─────────────────────────────────────────────────────────────────────────
    if SConditionFVG and ShowSuFVG
        SDFVG   := low[2]
        SPFVG   := high
        BarSFVG := bar_index
        SDistal   := line.new(BarSFVG, SDFVG, BarSFVG + 10, SDFVG,
         color = color.rgb(0,0,0), style = line.style_dotted, width = 1)
        SProximal := line.new(BarSFVG, SPFVG, BarSFVG + 10, SPFVG,
         color = color.rgb(0,0,0), style = line.style_dotted, width = 1)
        Sfillline := linefill.new(SDistal, SProximal, color = #ff7d044d)
        SFVGLabel := label.new(BarSFVG, SDFVG, text = 'FVG ▼',
         style = label.style_label_down,
         color = color.rgb(255,255,255,100), textcolor = color.rgb(180,0,0),
         textalign = text.align_center, size = size.small)

    if ((high < SDFVG) or SDFVG == SDFVG[1]) and SMitigated == true
        line.set_x2(SDistal,   bar_index + 1)
        line.set_x2(SProximal, bar_index + 1)
        label.set_x(SFVGLabel, math.round((BarSFVG + bar_index) / 2))

    if (high >= SPFVG) and (high[1] <= SPFVG)
        SMitigated := false

    if SConditionFVG
        SMitigated := true

// ─── 関数呼び出し ──────────────────────────────────────────────────────────────
FVGDetector(VFVGFilter, VFVGFilterType, VShowDeFVG, VShowSuFVG, VDebug)
````
