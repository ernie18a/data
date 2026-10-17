# Ask yourself before you buy!

- url: https://www.tradingview.com/script/gGF5O3QR/
- type: indicator
- pine_id: PUB;8747a6ffa94840f09e4842b87b926e1a
- version: 1.0

## Description

Remeber it everyone!

Remeber it everyone!

Remeber it everyone!

Important thing I will say three time!

Good luck everyone!

## Source Code

````pine
//@version=6
indicator("交易谨记与自检模板", overlay=true)

// =====================================================
// 固定模板：谨记标签 + 自检表格
// 只在最后一根K线用 var 创建一次，避免重复绘制
// =====================================================

if barstate.islast
    
    // ===== 2. 自检表格 =====
    var table checkTable = na
    if na(checkTable)
        cHeader   = color.new(#ffffff, 0)
        cSepBefore= color.new(#ffffff, 55)
        cSepAfter = color.new(#ffffff, 55)
        cEven     = color.new(#ffffff, 50)
        cOdd      = color.new(#ffffff, 50)
        cWhite    = color.rgb(0, 0, 0)
        cOrange   = color.new(#ff0000, 0)
        cTeal     = color.new(#ffffff, 0)

        checkTable := table.new(
         position = position.top_right,
         columns  = 3,
         rows     = 13,
         bgcolor  = color.new(#ffffff, 100),
         border_width = 1,
         border_color = color.gray
        )

        // ---- Row 0: 表头 ----
        table.cell(checkTable, 0, 0, "序", bgcolor=cHeader, text_color=cWhite, width=2)
        table.cell(checkTable, 1, 0, "入场前自检", bgcolor=cHeader, text_color=cWhite, width=16)
        table.cell(checkTable, 2, 0, "回答", bgcolor=cHeader, text_color=cWhite, width=4)

        // ---- Row 1: ★ 入场前分隔 ----
        table.cell(checkTable, 0, 1, "", bgcolor=cSepBefore)
        table.cell(checkTable, 1, 1, "永远尊重眼前正在发生的图表事实，\n而不是你头脑中期待的幻想。", bgcolor=cSepBefore, text_color=cOrange,text_size = 22 )
        table.cell(checkTable, 2, 1, "", bgcolor=cSepBefore)

        // ---- Row 2 ----
        table.cell(checkTable, 0, 2, "1", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 2, "现在的市场处于什么周期阶段？高级别是什么周期？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 2, "", bgcolor=cEven)

        // ---- Row 3 ----
        table.cell(checkTable, 0, 3, "2", bgcolor=cOdd, text_color=cWhite)
        table.cell(checkTable, 1, 3, "价格与EMA20的位置关系如何？", bgcolor=cOdd, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 3, "", bgcolor=cOdd)

        // ---- Row 4 ----
        table.cell(checkTable, 0, 4, "3", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 4, "这根信号棒足够强吗？是否收在极值附近？位置是否被证明过？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 4, "", bgcolor=cEven)

        // ---- Row 5 ----
        table.cell(checkTable, 0, 5, "4", bgcolor=cOdd, text_color=cWhite)
        table.cell(checkTable, 1, 5, "若进场，保护性止损应放在哪里？这个代价能否承受？", bgcolor=cOdd, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 5, "", bgcolor=cOdd)

        // ---- Row 6 ----
        table.cell(checkTable, 0, 6, "5", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 6, "止盈目标至少是风险的 2 倍吗？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 6, "", bgcolor=cEven)

        // ---- Row 7: ★ 入场后分隔 ----
        table.cell(checkTable, 0, 7, "", bgcolor=cSepAfter)
        table.cell(checkTable, 1, 7, "入场后自检", bgcolor=cSepAfter, text_color=cWhite)
        table.cell(checkTable, 2, 7, "", bgcolor=cSepAfter)

        // ---- Row 8 ----
        table.cell(checkTable, 0, 8, "1", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 8, "这根新 K 线是否印证了我的入场逻辑？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 8, "", bgcolor=cEven)

        // ---- Row 9 ----
        table.cell(checkTable, 0, 9, "2", bgcolor=cOdd, text_color=cWhite)
        table.cell(checkTable, 1, 9, "我最初进场的理由是否依然成立？", bgcolor=cOdd, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 9, "", bgcolor=cOdd)

        // ---- Row 10 ----
        table.cell(checkTable, 0, 10, "3", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 10, "若现在空仓，会在此刻顺着原方向建仓吗？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 10, "", bgcolor=cEven)

        // ---- Row 11 ----
        table.cell(checkTable, 0, 11, "4", bgcolor=cOdd, text_color=cWhite)
        table.cell(checkTable, 1, 11, "保护性止损现在可以收紧吗？", bgcolor=cOdd, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 11, "", bgcolor=cOdd)

        // ---- Row 12 ----
        table.cell(checkTable, 0, 12, "5", bgcolor=cEven, text_color=cWhite)
        table.cell(checkTable, 1, 12, "眼前的价格行为，是否要求我改变止盈策略？", bgcolor=cEven, text_color=cWhite,text_halign = text.align_left)
        table.cell(checkTable, 2, 12, "", bgcolor=cEven)
````
