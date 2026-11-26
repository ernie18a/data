# VP+HVP+OBV

- url: https://www.tradingview.com/script/NepNkOCe/
- type: indicator
- pine_id: PUB;a730d81e90d54e409fe64f8cae782df8
- version: 5.0

## Description

orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]orijg['sapzotijhsport9hj]v

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
//  量價整合 — Volume Profile + High Volume Points + OBV Traffic Lights
//  僅供個人使用,請勿公開發布(含 CC BY-NC / BY-NC-SA 授權元件)
//  搭配獨立腳本「CVD副圖.pine」一起使用
//
//  元件出處與授權:
//   - Volume Profile / Fixed Range — (c) LonesomeTheBlue, MPL 2.0
//   - High Volume Points — (c) BigBeluga, CC BY-NC-SA 4.0
//   - OBV Traffic Lights — (c) Anton "lejmer" Berlin / 概念 Peter Whipp, CC BY-NC 4.0
//   - 整合、多週期 POC — 2026-06, for Morris
//
//  版面:
//   - 主圖(force_overlay 投影):VP 量價分布 + 多週期 POC 色帶(5/10/20/60/120)+ HVP 水平線/量標籤 + EMA 5/10/20/60/120
//   - 副圖:OBV Traffic Lights(真實值,右軸=OBV 原始刻度)
// ════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("量價整合 VP+HVP+OBV", "量價整合", overlay = false, format = format.volume,
     max_boxes_count = 200, max_lines_count = 500, max_labels_count = 500,
     max_bars_back = 1000)

// ═════════════════════════════════ 輸入 ═════════════════════════════════════

// ----- Volume Profile(主圖)-----
string GRP_VP = "Volume Profile(主圖)"
bool  showVP     = input.bool(true,   "顯示 Volume Profile",            group = GRP_VP)
int   vpBars     = input.int(60,      "回看 K 棒數", minval = 1, maxval = 500, group = GRP_VP)
int   vpRows     = input.int(24,      "行數",        minval = 5, maxval = 100, group = GRP_VP)
float vpVaPct    = input.float(70.,   "Value Area %", minval = 0, maxval = 100, group = GRP_VP)
int pocLen1 = input.int(5,   "POC 週期", minval = 2, inline = "plen", group = GRP_VP)
int pocLen2 = input.int(10,  "",         minval = 2, inline = "plen", group = GRP_VP)
int pocLen3 = input.int(20,  "",         minval = 2, inline = "plen", group = GRP_VP)
int pocLen4 = input.int(60,  "",         minval = 2, inline = "plen", group = GRP_VP)
int pocLen5 = input.int(120, "",         minval = 2, inline = "plen", group = GRP_VP)
color pocCol1 = input.color(#E0E0E0, "POC 顏色", inline = "pcol", group = GRP_VP)
color pocCol2 = input.color(#26C6DA, "",         inline = "pcol", group = GRP_VP)
color pocCol3 = input.color(#AB47BC, "",         inline = "pcol", group = GRP_VP)
color pocCol4 = input.color(#FFD700, "",         inline = "pcol", group = GRP_VP)
color pocCol5 = input.color(#42A5F5, "",         inline = "pcol", group = GRP_VP)
color vpVupColor = input.color(color.new(color.blue,   85), "VA 上漲", group = GRP_VP)
color vpVdnColor = input.color(color.new(color.orange, 85), "VA 下跌", group = GRP_VP)
color vpUpColor  = input.color(color.new(color.blue,   93), "上漲量",  group = GRP_VP)
color vpDnColor  = input.color(color.new(color.orange, 93), "下跌量",  group = GRP_VP)
bool  vpShowPoc  = input.bool(true,   "顯示 POC 標籤",                  group = GRP_VP)

// ----- High Volume Points(主圖)-----
string GRP_HVP = "High Volume Points(主圖)"
bool  showHVP    = input.bool(true,  "顯示 HVP",                        group = GRP_HVP)
float hvpFilter  = input.float(2,    "量能門檻(0~6)", step = 0.1, minval = 0, maxval = 6, group = GRP_HVP)
int   hvpLeft    = input.int(5,      "Left Bars",                       group = GRP_HVP)
int   hvpRight   = input.int(2,      "Right Bars",                      group = GRP_HVP)
bool  hvpShowLvl = input.bool(true,  "顯示水平線",                      group = GRP_HVP)
color hvpUpCol   = input.color(#fda05e, "", inline = "hvpc",            group = GRP_HVP)
color hvpDnCol   = input.color(#2fd68e, "", inline = "hvpc",            group = GRP_HVP)

// ----- EMA(主圖)-----
string GRP_EMA = "EMA(主圖)"
bool showEMA = input.bool(true, "顯示 EMA", group = GRP_EMA)
int emaLen1 = input.int(5,   "EMA 週期", minval = 1, inline = "el", group = GRP_EMA)
int emaLen2 = input.int(10,  "",         minval = 1, inline = "el", group = GRP_EMA)
int emaLen3 = input.int(20,  "",         minval = 1, inline = "el", group = GRP_EMA)
int emaLen4 = input.int(60,  "",         minval = 1, inline = "el", group = GRP_EMA)
int emaLen5 = input.int(120, "",         minval = 1, inline = "el", group = GRP_EMA)
color emaCol1 = input.color(color.new(#E0E0E0, 50), "EMA 顏色", inline = "ec", group = GRP_EMA)
color emaCol2 = input.color(color.new(#26C6DA, 50), "",         inline = "ec", group = GRP_EMA)
color emaCol3 = input.color(color.new(#AB47BC, 50), "",         inline = "ec", group = GRP_EMA)
color emaCol4 = input.color(color.new(#FFD700, 50), "",         inline = "ec", group = GRP_EMA)
color emaCol5 = input.color(color.new(#42A5F5, 50), "",         inline = "ec", group = GRP_EMA)

// ----- OBV Traffic Lights(副圖)-----
string GRP_OBV = "OBV Traffic Lights(副圖)"
bool showOBV     = input.bool(true, "顯示 OBV",                         group = GRP_OBV)
int  obvFastLen  = input.int(5,  "Fast EMA",   minval = 2,              group = GRP_OBV)
int  obvMedLen   = input.int(10, "Medium EMA", minval = 3,              group = GRP_OBV)
int  obvSlowLen  = input.int(20, "Slow EMA",   minval = 4,              group = GRP_OBV)
int  obvDblLen   = input.int(60, "Donchian baseline 長度", minval = 2,  group = GRP_OBV)
int  obvSmooth   = input.int(1,  "平滑", minval = 1,                    group = GRP_OBV)
bool obvShowDbl  = input.bool(true,  "顯示 Donchian baseline",          group = GRP_OBV)
bool obvUseBg    = input.bool(false, "用背景色顯示整體方向",            group = GRP_OBV)

// ═══════════════════════ Volume Profile(主圖)═══════════════════════════════
// (c) LonesomeTheBlue — MPL 2.0

float vpTop  = ta.highest(vpBars)
float vpBot  = ta.lowest(vpBars)
float vpDist = (vpTop - vpBot) / 500
float vpStep = (vpTop - vpBot) / vpRows

// 各價格層的邊界
vpLevels = array.new_float(vpRows + 1)
for x = 0 to vpRows
    array.set(vpLevels, x, vpBot + vpStep * x)

// 取得 K 棒區段與價格層的重疊量
vpGetVol(y11, y12, y21, y22, height, vol) =>
    nz(math.max(math.min(math.max(y11, y12), math.max(y21, y22)) - math.max(math.min(y11, y12), math.min(y21, y22)), 0) * vol / height)

// 任意回看週期的 POC(手算迴圈版,可安全在 barstate.islast 內呼叫)
vpPocLevel(int lookback, int rows) =>
    float t = high
    float b = low
    for i = 0 to lookback - 1
        t := math.max(t, high[i])
        b := math.min(b, low[i])
    float stp = (t - b) / rows
    binVols = array.new_float(rows, 0.)
    for i = 0 to lookback - 1
        float bodyTop = math.max(close[i], open[i])
        float bodyBot = math.min(close[i], open[i])
        float topWick = high[i] - bodyTop
        float botWick = bodyBot - low[i]
        float body    = bodyTop - bodyBot
        float denom   = 2 * topWick + 2 * botWick + body
        float bodyVol    = body * volume[i] / denom
        float topWickVol = 2 * topWick * volume[i] / denom
        float botWickVol = 2 * botWick * volume[i] / denom
        for x = 0 to rows - 1
            float y1 = b + stp * x
            float y2 = b + stp * (x + 1)
            array.set(binVols, x, array.get(binVols, x)
                 + vpGetVol(y1, y2, bodyBot, bodyTop, body, bodyVol)
                 + vpGetVol(y1, y2, bodyTop, high[i], topWick, topWickVol)
                 + vpGetVol(y1, y2, bodyBot, low[i],  botWick, botWickVol))
    int idx = array.indexof(binVols, array.max(binVols))
    b + stp * (idx + 0.5)

if barstate.islast and showVP
    vols = array.new_float(vpRows * 2, 0.)
    for bars = 0 to vpBars - 1
        float bodyTop = math.max(close[bars], open[bars])
        float bodyBot = math.min(close[bars], open[bars])
        bool  isGreen = close[bars] >= open[bars]
        float topWick = high[bars] - bodyTop
        float botWick = bodyBot - low[bars]
        float body    = bodyTop - bodyBot
        float denom   = 2 * topWick + 2 * botWick + body
        float bodyVol    = body * volume[bars] / denom
        float topWickVol = 2 * topWick * volume[bars] / denom
        float botWickVol = 2 * botWick * volume[bars] / denom
        for x = 0 to vpRows - 1
            array.set(vols, x, array.get(vols, x)
                 + (isGreen ? vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyBot, bodyTop, body, bodyVol) : 0)
                 + vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyTop, high[bars], topWick, topWickVol) / 2
                 + vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyBot, low[bars],  botWick, botWickVol) / 2)
            array.set(vols, x + vpRows, array.get(vols, x + vpRows)
                 + (isGreen ? 0 : vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyBot, bodyTop, body, bodyVol))
                 + vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyTop, high[bars], topWick, topWickVol) / 2
                 + vpGetVol(array.get(vpLevels, x), array.get(vpLevels, x + 1), bodyBot, low[bars],  botWick, botWickVol) / 2)

    totalVols = array.new_float(vpRows, 0.)
    for x = 0 to vpRows - 1
        array.set(totalVols, x, array.get(vols, x) + array.get(vols, x + vpRows))

    int vpPoc = array.indexof(totalVols, array.max(totalVols))

    // Value Area
    float vaTarget = array.sum(totalVols) * vpVaPct / 100.
    float vaTotal  = array.get(totalVols, vpPoc)
    int vaUp = vpPoc
    int vaDn = vpPoc
    for x = 0 to vpRows - 1
        if vaTotal >= vaTarget
            break
        float upperVol = vaUp < vpRows - 1 ? array.get(totalVols, vaUp + 1) : 0.
        float lowerVol = vaDn > 0 ? array.get(totalVols, vaDn - 1) : 0.
        if upperVol == 0 and lowerVol == 0
            break
        if upperVol >= lowerVol
            vaTotal += upperVol
            vaUp += 1
        else
            vaTotal += lowerVol
            vaDn -= 1

    float vpMaxVol = array.max(totalVols)
    for x = 0 to vpRows * 2 - 1
        array.set(vols, x, array.get(vols, x) * vpBars / (3 * vpMaxVol))

    // 畫量價分布列
    var vpBoxes = array.new_box(vpRows * 2, na)
    for x = 0 to vpRows - 1
        box.delete(array.get(vpBoxes, x))
        box.delete(array.get(vpBoxes, x + vpRows))
        int x0 = bar_index - vpBars + 1  // 分布列畫在計算範圍左緣
        int x1 = x0 + math.round(array.get(vols, x))
        int x2 = x1 + math.round(array.get(vols, x + vpRows))
        array.set(vpBoxes, x, box.new(x0, array.get(vpLevels, x + 1) - vpDist, x1, array.get(vpLevels, x) + vpDist,
             border_width = 0, bgcolor = x >= vaDn and x <= vaUp ? vpVupColor : vpUpColor, force_overlay = true))
        array.set(vpBoxes, x + vpRows, box.new(x1, array.get(vpLevels, x + 1) - vpDist, x2, array.get(vpLevels, x) + vpDist,
             border_width = 0, bgcolor = x >= vaDn and x <= vaUp ? vpVdnColor : vpDnColor, force_overlay = true))

    // 多週期 POC 色帶:各覆蓋自己的回看範圍,85% 透明墊底
    float pocHalf = (vpTop - vpBot) / 200
    var pocBands  = array.new<box>()
    var pocLabels = array.new<label>()
    for bx in pocBands
        box.delete(bx)
    pocBands.clear()
    for lb in pocLabels
        label.delete(lb)
    pocLabels.clear()
    pocLens = array.from(pocLen1, pocLen2, pocLen3, pocLen4, pocLen5)
    pocCols = array.from(pocCol1, pocCol2, pocCol3, pocCol4, pocCol5)
    for k = 0 to 4
        int   pLen = array.get(pocLens, k)
        float pLvl = vpPocLevel(pLen, vpRows)
        pocBands.push(box.new(bar_index - pLen + 1, pLvl + pocHalf, bar_index, pLvl - pocHalf,
             border_color = color(na), bgcolor = color.new(array.get(pocCols, k), 50), force_overlay = true))
        if vpShowPoc
            pocLabels.push(label.new(bar_index + 2, pLvl,
                 text = "POC " + str.tostring(pLen) + "  " + str.tostring(math.round_to_mintick(pLvl)),
                 style = label.style_label_left, color = color(na), textcolor = array.get(pocCols, k),
                 size = size.small, force_overlay = true))

// ═══════════════════ High Volume Points(主圖)═══════════════════════════════
// (c) BigBeluga — CC BY-NC-SA 4.0

var hvpLevels = array.new<line>()

float ph = ta.pivothigh(hvpLeft, hvpRight)
float pl = ta.pivotlow(hvpLeft, hvpRight)

float hvpVolSum = math.sum(volume, hvpLeft * 2)
float hvpRefVol = ta.percentile_nearest_rank(hvpVolSum, 1000, 95)
float hvpNormVol = hvpVolSum / hvpRefVol * 5

// 水平線:被收盤穿越就轉虛線並停止延伸
hvpCheckCross(arrayOfLines) =>
    int qty = array.size(arrayOfLines)
    for lineNo = 0 to qty > 0 ? qty - 1 : na
        if lineNo < array.size(arrayOfLines)
            line cur = array.get(arrayOfLines, lineNo)
            float lvl = line.get_price(cur, bar_index)
            bool crossed = math.sign(close[1] - lvl) != math.sign(close - lvl)
            if crossed
                line.set_style(cur, line.style_dotted)
                array.remove(arrayOfLines, lineNo)
                int(na)
            else
                line.set_x2(cur, bar_index)
                int(na)

hvpDrawLevel(float src, int x, int w, color col) =>
    line.new(x1 = x, y1 = src, x2 = x, y2 = src, style = line.style_solid,
         width = math.max(1, math.round(w / 3)), color = color.new(col, 80), force_overlay = true)

int hvpW1 = 0
int hvpW2 = 0

if showHVP and last_bar_index - bar_index < 300
    // 高點(只計量能強度,作為水平線粗細;同心圓已移除)
    for i = 0 to 10
        if not na(ph) and hvpNormVol > i and hvpNormVol > hvpFilter and barstate.isconfirmed
            hvpW1 += 1
    if not na(ph) and hvpNormVol > hvpFilter and barstate.isconfirmed
        int n = bar_index - hvpRight
        float src = high[hvpRight]
        chart.point cp = chart.point.from_index(n, src)
        if hvpShowLvl
            hvpLevels.push(hvpDrawLevel(src, n, hvpW1, hvpUpCol))
        label.new(cp, textcolor = chart.fg_color, color = color.new(hvpUpCol, 30), style = label.style_circle, size = size.tiny, force_overlay = true)
        label.new(cp, text = str.tostring(hvpVolSum, format.volume), textcolor = chart.fg_color, color = color(na), style = label.style_label_down, force_overlay = true)
    // 低點
    for i = 10 to 0
        if not na(pl) and hvpNormVol > i and hvpNormVol > hvpFilter and barstate.isconfirmed
            hvpW2 += 1
    if not na(pl) and hvpNormVol > hvpFilter and barstate.isconfirmed
        int n = bar_index - hvpRight
        float src = low[hvpRight]
        chart.point cp = chart.point.from_index(n, src)
        if hvpShowLvl
            hvpLevels.push(hvpDrawLevel(src, n, hvpW2, hvpDnCol))
        label.new(cp, textcolor = chart.fg_color, color = color.new(hvpDnCol, 30), style = label.style_circle, size = size.tiny, force_overlay = true)
        label.new(cp, text = str.tostring(hvpVolSum, format.volume), textcolor = chart.fg_color, color = color(na), style = label.style_label_up, force_overlay = true)

hvpCheckCross(hvpLevels)

// ═══════════════════ OBV Traffic Lights(副圖)═══════════════════════════════
// (c) Anton "lejmer" Berlin / Peter Whipp — CC BY-NC 4.0

string haTicker = ticker.heikinashi(syminfo.tickerid)
[haOpenVal, haCloseVal] = request.security(haTicker, timeframe.period, [ta.ema(close[1], obvSmooth), ta.ema(close, obvSmooth)])

var float obvVal = 0.0
obvVal += nz(haCloseVal > haOpenVal ? volume : haCloseVal < haOpenVal ? -volume : 0.0)

float obvMa1 = ta.ema(obvVal, obvFastLen)
float obvMa2 = ta.ema(obvVal, obvMedLen)
float obvMa3 = ta.ema(obvVal, obvSlowLen)
float obvDbl = math.avg(ta.lowest(obvVal, obvDblLen), ta.highest(obvVal, obvDblLen))

// ═══════════════════════ 副圖繪製(真實值)═══════════════════════════════════
color obvLineCol = obvVal > obvMa3 ? color.green : obvVal < obvMa3 ? color.red : color.gray
oPlot  = plot(showOBV ? obvVal : na, "OBV",        color = obvLineCol,  linewidth = 2)
plot(showOBV ? obvMa1 : na,          "Fast EMA",   color = color.green, linewidth = 2)
plot(showOBV ? obvMa2 : na,          "Medium EMA", color = color.yellow, linewidth = 2)
sPlot  = plot(showOBV ? obvMa3 : na, "Slow EMA",   color = color.red,   linewidth = 2)
plot(showOBV and obvShowDbl ? obvDbl : na, "Donchian baseline", color = color.purple, linewidth = 2, style = plot.style_circles)
fill(oPlot, sPlot, color = color.new(obvVal > obvMa3 ? color.blue : obvVal < obvMa3 ? color.red : color.gray, 60))

// 背景:OBV 整體方向(預設關)
var color tlBg = na
tlBg := obvVal > obvMa3 and obvMa1 > obvMa3 ? color.blue : obvVal < obvMa3 and obvMa1 < obvMa3 ? color.red : tlBg[1]
bgcolor(obvUseBg ? color.new(tlBg, 90) : na)

// ═══════════════════════════ EMA(主圖)══════════════════════════════════════

float ema1 = ta.ema(close, emaLen1)
float ema2 = ta.ema(close, emaLen2)
float ema3 = ta.ema(close, emaLen3)
float ema4 = ta.ema(close, emaLen4)
float ema5 = ta.ema(close, emaLen5)
plot(showEMA ? ema1 : na, "EMA 5",   color = emaCol1, force_overlay = true)
plot(showEMA ? ema2 : na, "EMA 10",  color = emaCol2, force_overlay = true)
plot(showEMA ? ema3 : na, "EMA 20",  color = emaCol3, force_overlay = true)
plot(showEMA ? ema4 : na, "EMA 60",  color = emaCol4, force_overlay = true)
plot(showEMA ? ema5 : na, "EMA 120", color = emaCol5, force_overlay = true)

// 線右端的 EMA 標籤(文字用不透明版顏色,線維持 80% 透明)
emaLblCol(color c) =>
    color.rgb(color.r(c), color.g(c), color.b(c))

if showEMA and barstate.islast
    var emaLbls = array.new<label>()
    for l in emaLbls
        label.delete(l)
    emaLbls.clear()
    emaVals = array.from(ema1, ema2, ema3, ema4, ema5)
    emaLens = array.from(emaLen1, emaLen2, emaLen3, emaLen4, emaLen5)
    emaCols = array.from(emaCol1, emaCol2, emaCol3, emaCol4, emaCol5)
    for k = 0 to 4
        emaLbls.push(label.new(bar_index + 2, array.get(emaVals, k),
             text = "EMA " + str.tostring(array.get(emaLens, k)),
             style = label.style_label_left, color = color(na),
             textcolor = emaLblCol(array.get(emaCols, k)), size = size.small, force_overlay = true))

// ═══════════════════════════════ 錯誤防呆 ═══════════════════════════════════

if ta.cum(volume) == 0 and barstate.islast
    runtime.error("此商品沒有成交量資料,無法計算。")
````
