# Trend Grading Dashboard V1.0

- url: https://www.tradingview.com/script/fovehB8g/
- type: indicator
- pine_id: PUB;7c1552589c904e59b8a3750c47802742
- version: 6.0

## Description

Trend Grading Dashboard By Piyacham

Logic Overview:
Trend Determination:
BUY: EMA14 is above EMA60.
SELL: EMA14 is below EMA60.

Grading System:
Grade A: The trend is strong; price is trading "beyond" the fast EMA (Above EMA14 for BUY, Below EMA14 for SELL).
Grade B: The price is in a retracement zone between the two EMAs.
Grade C: The price has crossed below the slow EMA (for BUY) or above it (for SELL), suggesting a potential trend weakness or reversal.

Timeframes: The dashboard automatically tracks M1, M3, M5, H1, and H4 regardless of your current chart timeframe.

Key Features:
Configurable EMAs: You can change the lengths of both EMAs in the settings.
Customizable Dashboard: You can move the dashboard to any corner of the chart and adjust colors for the text and headers.
Visual Clarity: The dashboard cells are color-coded based on the trend (Green for BUY, Red for SELL) for quick scanning.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © LuxAlgo (Trend Grading Dashboard, modified) + Supply and Demand Zones — merged
// Merged indicator: Trend Grading Dashboard V4.0 + Supply and Demand Zones

//@version=6
indicator("Trend Grading Dashboard + Supply/Demand Zones", shorttitle = "TGD + S/D Zones", overlay = true, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 100)

// =========================================================================
// ===================  SECTION 1: TREND GRADING DASHBOARD  ==============
// =========================================================================

// --- Constants ---
string GRP_EMA  = "EMA Settings"
string GRP_DASH = "Dashboard Settings"

// --- Inputs ---
int emaLen1 = input.int(14, "EMA 1 Length", minval = 1, group = GRP_EMA, tooltip = "Length for the fast EMA")
int emaLen2 = input.int(60, "EMA 2 Length", minval = 1, group = GRP_EMA, tooltip = "Length for the slow EMA")

enableSignalSetting = input.bool(false, title="Enable Signal Buy/Sell when momentum shift", group = GRP_EMA)
bullSignal  = input.color(color.white, "Bullish Cross Color", tooltip = "Candle color when price crosses above EMA 14", group = GRP_EMA)
bearSignal  = input.color(color.white, "Bearish Cross Color", tooltip = "Candle color when price crosses below EMA 14", group = GRP_EMA)

color bullColor = input.color(#089981, "Bullish Color", group = GRP_EMA)
color bearColor = input.color(#f23645, "Bearish Color", group = GRP_EMA)

showDash    = input.bool(true, "Show Dashboard Table", group = GRP_DASH, tooltip = "Turn off to highly speed up Backtesting")
string tablePos    = input.string("top_right", "Dashboard Position", options = ["top_right", "bottom_right", "top_left", "bottom_left"], group = GRP_DASH)
color  textColorDash = input.color(color.white, "Text Color", group = GRP_DASH)
color  headerColor = input.color(color.gray, "Header Color", group = GRP_DASH)

// --- Types ---
type MarketState
    float e1
    float e2
    float price

// --- Calculations ---
ema14 = ta.ema(close, emaLen1)
ema60 = ta.ema(close, emaLen2)

priceCrossUp   = ta.crossover(close, ema14)
priceCrossDown = ta.crossunder(close, ema14)
emaCrossUp     = ema14 > ema60

getState() =>
    MarketState.new(ta.ema(close, emaLen1), ta.ema(close, emaLen2), close)

// Fetching data for multiple timeframes (only loads when dashboard is enabled)
m1  = showDash ? request.security(syminfo.tickerid, "1", getState()) : na
m3  = showDash ? request.security(syminfo.tickerid, "3", getState()) : na
m5  = showDash ? request.security(syminfo.tickerid, "5", getState()) : na
h1  = showDash ? request.security(syminfo.tickerid, "60", getState()) : na
h4  = showDash ? request.security(syminfo.tickerid, "240", getState()) : na
d1  = showDash ? request.security(syminfo.tickerid, "D", getState()) : na

// --- Logic Function ---
getTrendAndGrade(MarketState state) =>
    string trend = "N/A"
    string grade = "N/A"
    color  c     = color.gray

    if not na(state) and not na(state.e1) and not na(state.e2)
        bool isBuy = state.e1 > state.e2
        trend := isBuy ? "BUY" : "SELL"
        c     := isBuy ? bullColor : bearColor

        if isBuy
            grade := state.price > state.e1 ? "A" : (state.price > state.e2 ? "B" : "C")
        else
            grade := state.price < state.e1 ? "A" : (state.price < state.e2 ? "B" : "C")

    [trend, grade, c]

// Helper to fill row
fillRow(table dash, int row, string tfName, MarketState m, color txt) =>
    [t, g, c] = getTrendAndGrade(m)
    table.cell(dash, 0, row, tfName, text_color = txt)
    table.cell(dash, 1, row, t, bgcolor = c, text_color = color.white)
    table.cell(dash, 2, row, g, text_color = txt)

// --- Plotting ---
p1 = plot(ema14, "EMA 14", color = emaCrossUp ? bullColor : bearColor, linewidth = 2)
p2 = plot(ema60, "EMA 60", color = color.gray, linewidth = 1)

fill(p1, p2, ema14 > ema60 ? color.new(bullColor, 80) : color.new(bearColor, 80), "EMA Cross Shading")

barcolor(priceCrossUp ? bullSignal : priceCrossDown ? bearSignal : na, title = "Price Cross EMA 14")

// Dashboard table
var table dash = table.new(tablePos, 3, 7, frame_color = color.gray, frame_width = 1, border_color = color.gray, border_width = 1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "TF", bgcolor = headerColor, text_color = textColorDash)
    table.cell(dash, 1, 0, "Trend", bgcolor = headerColor, text_color = textColorDash)
    table.cell(dash, 2, 0, "Grade", bgcolor = headerColor, text_color = textColorDash)

    fillRow(dash, 1, "M1", m1, textColorDash)
    fillRow(dash, 2, "M3", m3, textColorDash)
    fillRow(dash, 3, "M5", m5, textColorDash)
    fillRow(dash, 4, "H1", h1, textColorDash)
    fillRow(dash, 5, "H4", h4, textColorDash)
    fillRow(dash, 6, "D1", d1, textColorDash)

// --- Alerts ---
alertcondition(priceCrossUp, title="Buy Alert", message="Price crossed above EMA 14 (Bullish Momentum)")
alertcondition(priceCrossDown, title="Sell Alert", message="Price crossed below EMA 14 (Bearish Momentum)")

if priceCrossUp
    alert("Price crossed above EMA 14 (Bullish Momentum)!", alert.freq_once_per_bar)

if priceCrossDown
    alert("Price crossed below EMA 14 (Bearish Momentum)!", alert.freq_once_per_bar)

buyCondition  = priceCrossUp and enableSignalSetting
sellCondition = priceCrossDown and enableSignalSetting

plotshape(series=buyCondition, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="BUY", textcolor=color.white)
plotshape(series=sellCondition, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="SELL", textcolor=color.white)


// =========================================================================
// ===================  SECTION 2: SUPPLY AND DEMAND ZONES  ==============
// =========================================================================

// --- Inputs ---
candleDifferenceScale = input.float(defval = 1.8, minval = 1, title = 'Zone Difference Scale', tooltip = 'The scale of how much a candle needs to be larger than a previous to be considered a zone. (candleChange / candleChange[1] > {value}, minimum value 1.0, default 1.8)', group = 'Zone Settings')

zoneOffset = input.int(defval = 15, minval = 0, title="Zone Extension", group = 'Display Settings', tooltip = 'How much to extend zones to the right of latest bar. (In bars)')
displayLowerTFZones = input.bool(false, title="Display Lower Timeframe Zones", group = 'Display Settings', tooltip = 'Whether to or not to display zones from a lower timeframe. ie. 2h zones on 4h timeframe (Recommended OFF).')

supplyEnable = input.bool(true, title = "Enable Supply Zones", group = "Zone Personalization")
supplyColor = input.color(defval = color.rgb(242, 54, 69, 70), title = 'Supply Background Color', group = 'Zone Personalization')
supplyBorderColor = input.color(defval = color.rgb(209, 212, 220, 90), title = 'Supply Border Color', group = 'Zone Personalization')

demandEnable = input.bool(true, title = "Enable Demand Zones", group = "Zone Personalization")
demandColor = input.color(defval = color.rgb(76, 175, 80, 70), title = 'Demand Background Color', group = 'Zone Personalization')
demandBorderColor = input.color(defval = color.rgb(209, 212, 220, 80), title = 'Demand Border Color', group = 'Zone Personalization')

textEnable = input.bool(true, title = "Display Text", group = 'Text Settings')
displayHL = input.bool(false, title="Display High/Low", group = 'Text Settings', tooltip = 'Whether to or not to display the tops and bottoms of a zone as text. ie. Top: 4000.00 Bottom: 3900.00.')
textColorSD = input.color(defval = color.rgb(255, 255, 255), title = 'Text Color', group = 'Text Settings')
textSizeInput = input.string("Small", title="Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group = 'Text Settings')
halignInput = input.string("Right", title="Horizontal Alignment", options=["Left", "Center", "Right"], group = 'Text Settings')
supplyValignInput = input.string("Bottom", title="Vertical Alignment (Supply)", options=["Top", "Center", "Bottom"], group = 'Text Settings')
demandValignInput = input.string("Top", title="Vertical Alignment (Demand)", options=["Top", "Center", "Bottom"], group = 'Text Settings')

displayFormingZones = input.bool(false, title="Show Forming Zones", group = 'Timeframe Options', tooltip = 'Shows zones that could potentially form (unclosed candles)')
display30m = input.bool(false, title="Show 30m Zones", group = 'Timeframe Options')
display45m = input.bool(false, title="Show 45m Zones", group = 'Timeframe Options')
display1h = input.bool(true, title="Show 1h Zones", group = 'Timeframe Options')
display2h = input.bool(false, title="Show 2h Zones", group = 'Timeframe Options')
display3h = input.bool(false, title="Show 3h Zones", group = 'Timeframe Options')
display4h = input.bool(true, title="Show 4h Zones", group = 'Timeframe Options')
displayD = input.bool(false, title="Show Daily Zones", group = 'Timeframe Options')
displayW = input.bool(false, title="Show Weekly Zones", group = 'Timeframe Options')

// --- Variables ---
currentTimeframe = timeframe.period

if currentTimeframe == 'D'
    currentTimeframe := '1440'
if currentTimeframe == 'W'
    currentTimeframe := '10080'
if displayLowerTFZones
    currentTimeframe := '1'

momentCTD = math.round(time(timeframe.period) + (zoneOffset * 60000 * str.tonumber(currentTimeframe)))

var string textSize = size.small
if textSizeInput == 'Auto'
    textSize := size.auto
if textSizeInput == 'Tiny'
    textSize := size.tiny
if textSizeInput == 'Small'
    textSize := size.small
if textSizeInput == 'Normal'
    textSize := size.normal
if textSizeInput == 'Large'
    textSize := size.large
if textSizeInput == 'Huge'
    textSize := size.huge

var string halign = text.align_right
if halignInput == 'Left'
    halign := text.align_left
if halignInput == 'Center'
    halign := text.align_center
if halignInput == 'Right'
    halign := text.align_right

var string supplyValign = text.align_bottom
if supplyValignInput == 'Bottom'
    supplyValign := text.align_bottom
if supplyValignInput == 'Center'
    supplyValign := text.align_center
if supplyValignInput == 'Top'
    supplyValign := text.align_top

var string demandValign = text.align_top
if demandValignInput == 'Bottom'
    demandValign := text.align_bottom
if demandValignInput == 'Center'
    demandValign := text.align_center
if demandValignInput == 'Top'
    demandValign := text.align_top

var box[] supply_HT = array.new_box()
var box[] demand_HT = array.new_box()

// --- Plotting zones ---
createSupplyDemandZones(timeframe) =>

    [open_HT, high_HT, low_HT, close_HT] = request.security(syminfo.tickerid, timeframe, [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

    var timeframeFormatted = ''

    if timeframe == '1'
        timeframeFormatted := '1m'
    else if timeframe == '3'
        timeframeFormatted := '3m'
    else if timeframe == '5'
        timeframeFormatted := '5m'
    else if timeframe == '15'
        timeframeFormatted := '15m'
    else if timeframe == '30'
        timeframeFormatted := '30m'
    else if timeframe == '45'
        timeframeFormatted := '45m'
    else if timeframe == '60'
        timeframeFormatted := '1h'
    else if timeframe == '120'
        timeframeFormatted := '2h'
    else if timeframe == '180'
        timeframeFormatted := '3h'
    else if timeframe == '240'
        timeframeFormatted := '4h'
    else if timeframe == 'D'
        timeframeFormatted := 'D'
    else if timeframe == 'W'
        timeframeFormatted := 'W'

    redCandle_HT = close_HT < open_HT
    greenCandle_HT = close_HT > open_HT
    neutralCandle_HT = close_HT == open_HT
    candleChange_HT = math.abs(close_HT - open_HT)

    var float bottomBox_HT = na
    var float topBox_HT = na
    momentCTD_HT = time(timeframe)[2]

    if (((redCandle_HT and greenCandle_HT[1]) or (redCandle_HT and neutralCandle_HT[1])) and (candleChange_HT / candleChange_HT[1]) >= candleDifferenceScale and (barstate.isconfirmed[1] or displayFormingZones) and supplyEnable and close_HT[1] >= close_HT and open_HT[1] <= open_HT)
        if displayFormingZones and barstate.isconfirmed[1] == false
            timeframeFormatted := timeframeFormatted + '(Forming)'
        if displayHL
            timeframeFormatted := timeframeFormatted + '\nTop: ' + str.tostring(topBox_HT) + '\nBottom: ' + str.tostring(open_HT[1])

        if high_HT >= high_HT[1]
            topBox_HT := high_HT
        else
            topBox_HT := high_HT[1]

        box supply = box.new(left=momentCTD_HT, top=topBox_HT, right=momentCTD, bgcolor=supplyColor, bottom=open_HT[1], xloc=xloc.bar_time)
        box.set_border_color(supply, supplyBorderColor)
        if textEnable
            box.set_text(supply, timeframeFormatted)
            box.set_text_size(supply, textSize)
            box.set_text_color(supply, textColorSD)
            box.set_text_halign(supply, halign)
            box.set_text_valign(supply, supplyValign)
        array.push(supply_HT, supply)

    if (((greenCandle_HT and redCandle_HT[1]) or (greenCandle_HT and neutralCandle_HT[1])) and (candleChange_HT / candleChange_HT[1]) >= candleDifferenceScale and (barstate.isconfirmed[1] or displayFormingZones) and demandEnable and close_HT[1] <= close_HT and open_HT[1] >= open_HT)
        if displayFormingZones and barstate.isconfirmed[1] == false
            timeframeFormatted := timeframeFormatted + ' (Forming)'
        if displayHL
            timeframeFormatted := timeframeFormatted + '\nTop: ' + str.tostring(open_HT[1]) + '\nBottom: ' + str.tostring(bottomBox_HT)

        if low_HT <= low_HT[1]
            bottomBox_HT := low_HT
        else
            bottomBox_HT := low_HT[1]

        box demand = box.new(left=momentCTD_HT, top=open_HT[1], right=momentCTD, bottom=bottomBox_HT, bgcolor=demandColor, xloc=xloc.bar_time)
        box.set_border_color(demand, demandBorderColor)
        if textEnable
            box.set_text(demand, timeframeFormatted)
            box.set_text_size(demand, textSize)
            box.set_text_color(demand, textColorSD)
            box.set_text_halign(demand, halign)
            box.set_text_valign(demand, demandValign)
        array.push(demand_HT, demand)

// --- Initiation ---
if display30m and str.tonumber(currentTimeframe) <= 30
    createSupplyDemandZones('30')
if display45m and str.tonumber(currentTimeframe) <= 45
    createSupplyDemandZones('45')
if display1h and str.tonumber(currentTimeframe) <= 60
    createSupplyDemandZones('60')
if display2h and str.tonumber(currentTimeframe) <= 120
    createSupplyDemandZones('120')
if display3h and str.tonumber(currentTimeframe) <= 180
    createSupplyDemandZones('180')
if display4h and str.tonumber(currentTimeframe) <= 240
    createSupplyDemandZones('240')
if displayD and str.tonumber(currentTimeframe) <= 1440
    createSupplyDemandZones('D')
if displayW and str.tonumber(currentTimeframe) <= 10080
    createSupplyDemandZones('W')
    // createSupplyDemandZones('M') // enabling this will break replay mode

// --- Remove broken supply zones ---
i = 0
while i < array.size(supply_HT) and array.size(supply_HT) > 0
    box currentBox = array.get(supply_HT, i)
    float breakLevel = box.get_top(currentBox)
    if high > breakLevel
        array.remove(supply_HT, i)
        box.delete(currentBox)
        int(na)
    else
        box.set_right(currentBox, momentCTD)
        i += 1
        int(na)

// --- Remove broken demand zones ---
i2 = 0
while i2 < array.size(demand_HT) and array.size(demand_HT) > 0
    box currentBox = array.get(demand_HT, i2)
    float breakLevel = box.get_bottom(currentBox)
    if low < breakLevel
        array.remove(demand_HT, i2)
        box.delete(currentBox)
        int(na)
    else
        box.set_right(currentBox, momentCTD)
        i2 += 1
        int(na)


// =========================================================================
// ===========  SECTION 3: SUPPORT / RESISTANCE (H4 PAIR TOUCHES)  =========
// =========================================================================
const string G_SR = "แนวรับ-แนวต้าน (จุดสัมผัสแท่งคู่)"
bool   showSR     = input.bool(true, "แสดงแนวรับ-แนวต้าน", group = G_SR)
string srMode     = input.string("Swing High/Low (ไส้)", "วิธีหาแนวรับ-แนวต้าน", options = ["จุดชนเนื้อเทียน (แบบเดิม)", "Swing High/Low (ไส้)"], group = G_SR,
                    tooltip = "จุดชนเนื้อเทียน: ราคาที่เนื้อเทียน 2 แท่งเปลี่ยนสีมาชนกัน | Swing High/Low: ยอดและก้นของไส้เทียน (ปลายไส้ที่สูง/ต่ำกว่าแท่งรอบข้าง)")
string srTf       = input.timeframe("240", "TF ที่ใช้หาจุดสัมผัส", group = G_SR)
int    srCount    = input.int(5, "จำนวนเส้นแต่ละฝั่ง (บน/ล่าง)", minval = 1, maxval = 10, group = G_SR)
int    srMinTouch = input.int(4, "จำนวนจุดสัมผัสขั้นต่ำต่อเส้น (แบบเดิม)", minval = 2, maxval = 20, group = G_SR)
int    srSwLen    = input.int(3, "Swing: จำนวนแท่งซ้าย/ขวา", minval = 1, maxval = 20, group = G_SR,
                    tooltip = "ยอด/ก้นต้องสูง/ต่ำกว่าแท่งรอบข้างฝั่งละกี่แท่ง ยิ่งมากยิ่งได้เฉพาะยอด/ก้นใหญ่")
int    srSwMin    = input.int(1, "Swing: จำนวนจุดขั้นต่ำต่อเส้น", minval = 1, maxval = 20, group = G_SR)
bool   srSwMode   = srMode == "Swing High/Low (ไส้)"
int    srMinN     = srSwMode ? srSwMin : srMinTouch
float  srTolMult  = input.float(0.25, "ระยะรวมจุดสัมผัสเป็นเส้นเดียว (× ATR14 ของ TF)", minval = 0.05, maxval = 2, step = 0.05, group = G_SR,
                    tooltip = "จุดสัมผัสที่ราคาห่างกันไม่เกินระยะนี้ จะถูกรวมเป็นเส้นเดียว")
int    srMax      = input.int(500, "จำนวนจุดสัมผัสย้อนหลังที่ใช้คำนวณ", minval = 50, maxval = 3000, group = G_SR)
color  colRes     = input.color(#EF5350, "สีแนวต้าน", inline = "src", group = G_SR)
color  colSup     = input.color(#81D4FA, "สีแนวรับ",  inline = "src", group = G_SR)
bool   srGlow       = input.bool(true, "แสดงออร่ารอบเส้น", group = G_SR)
float  srGlowMult   = input.float(0.035, "ความหนาออร่า (ขึ้น/ลง × ATR14 ของ TF)", minval = 0.005, maxval = 3, step = 0.005, group = G_SR)
int    srGlowLayers = input.int(7, "จำนวนชั้นออร่า (มาก = ไล่สีนุ่มขึ้น)", minval = 1, maxval = 10, group = G_SR)
int    srGlowTransp = input.int(92, "ความโปร่งแต่ละชั้น", minval = 50, maxval = 99, group = G_SR)

// ───────────── แนวรับ-แนวต้าน จากจุดสัมผัสแท่งคู่ ─────────────
// จุดสัมผัสแท่งคู่ = แท่งติดกัน 2 แท่งที่เปลี่ยนสี (แดง→เขียว หรือ เขียว→แดง)
// ราคาที่เนื้อเทียน 2 แท่งมาชนกัน (ราคาปิดแท่งแรก / ราคาเปิดแท่งถัดไป) คือ 1 จุดสัมผัส
// หลายจุดสัมผัสที่ราคาใกล้กัน = 1 เส้นแนวรับ/แนวต้าน
// ดึงแค่ "จุดสัมผัสของแท่งล่าสุด" (ค่าเดียว) จาก TF ที่เลือก แล้วสะสมเองบนกราฟ
// (ไม่ส่ง array ผ่าน request.security เพราะกินหน่วยความจำมากจน Bar Replay ค้าง)
pairTouch() =>
    int dA = close[2] > open[2] ? 1 : close[2] < open[2] ? -1 : 0
    int dB = close[1] > open[1] ? 1 : close[1] < open[1] ? -1 : 0
    dA != 0 and dB != 0 and dA != dB ? (close[2] + open[1]) / 2 : na

// Swing High / Low จากแท่งที่ปิดแล้ว (ใช้ [1] กันค่าเปลี่ยนระหว่างแท่งยังไม่ปิด)
swingPts() =>
    [ta.pivothigh(high, srSwLen, srSwLen)[1], ta.pivotlow(low, srSwLen, srSwLen)[1]]

[srTouch, srTfTime] = request.security(syminfo.tickerid, srTf, [pairTouch(), time], lookahead = barmerge.lookahead_off)
[srSwH, srSwL]      = request.security(syminfo.tickerid, srTf, swingPts(), lookahead = barmerge.lookahead_off)
float srAtr = request.security(syminfo.tickerid, srTf, ta.atr(14)[1])

var array<float> srPts = array.new<float>()
pushPt(float p) =>
    if not na(p)
        srPts.push(p)
        if srPts.size() > srMax
            srPts.shift()

if showSR and srTfTime != srTfTime[1]
    if srSwMode
        pushPt(srSwH)
        pushPt(srSwL)
    else
        pushPt(srTouch)

var array<line>  srLines  = array.new<line>()
var array<label> srLabels = array.new<label>()
var array<box>   srGlows  = array.new<box>()

drawSR(float lv, int n, int rank, bool isRes) =>
    color cl = isRes ? colRes : colSup
    // ออร่า: กล่องโปร่งซ้อนกันหลายชั้น ตรงกลางเข้ม ขอบจาง
    if srGlow and not na(srAtr) and srGlowLayers > 0
        float gH = srAtr * srGlowMult
        for k = 1 to srGlowLayers
            float half = gH * k / srGlowLayers
            srGlows.push(box.new(bar_index, lv + half, bar_index + 1, lv - half, extend = extend.both,
                                 border_color = color.new(cl, 100), bgcolor = color.new(cl, srGlowTransp)))
    srLines.push(line.new(bar_index, lv, bar_index + 1, lv, extend = extend.both, color = color.new(cl, 15),
                          width = n >= math.max(srMinN * 2, 3) ? 2 : 1, style = line.style_solid))
    srLabels.push(label.new(bar_index + 4, lv, (isRes ? "R" : "S") + str.tostring(rank) + "  " +
                            str.tostring(lv, format.mintick) + "  ×" + str.tostring(n),
                            style = label.style_label_left, color = color.new(color.black, 100),
                            textcolor = cl, size = size.normal))

if showSR and barstate.islast
    for ln in srLines
        line.delete(ln)
    for lb in srLabels
        label.delete(lb)
    for gb in srGlows
        box.delete(gb)
    srLines.clear()
    srLabels.clear()
    srGlows.clear()
    if srPts.size() > 1 and not na(srAtr)
        float tol = srAtr * srTolMult
        array<float> pts = srPts.copy()
        pts.sort(order.ascending)
        // รวมจุดสัมผัสที่ใกล้กันเป็นเส้นเดียว
        array<float> lv  = array.new<float>()
        array<int>   cnt = array.new<int>()
        float sum = 0.0
        int   n   = 0
        for p in pts
            if n > 0 and p - sum / n > tol
                if n >= srMinN
                    lv.push(sum / n)
                    cnt.push(n)
                sum := 0.0
                n   := 0
            sum += p
            n   += 1
        if n >= srMinN
            lv.push(sum / n)
            cnt.push(n)
        // แนวต้าน: ใกล้ราคาที่สุดเหนือราคาปัจจุบัน / แนวรับ: ใกล้ที่สุดใต้ราคา
        int k = lv.size()
        if k > 0
            int first = k
            for si = 0 to k - 1
                if lv.get(si) > close
                    first := si
                    break
            int drawn = 0
            if first < k
                for si = first to k - 1
                    if drawn >= srCount
                        break
                    drawn += 1
                    drawSR(lv.get(si), cnt.get(si), drawn, true)
            drawn := 0
            if first > 0
                for si = first - 1 to 0
                    if drawn >= srCount
                        break
                    drawn += 1
                    drawSR(lv.get(si), cnt.get(si), drawn, false)
````
