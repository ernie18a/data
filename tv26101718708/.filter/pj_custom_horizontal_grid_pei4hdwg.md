# PJ : Custom Horizontal Grid  

- url: https://www.tradingview.com/script/PEI4hDwg-PJ-Custom-Horizontal-Grid/
- type: indicator
- pine_id: PUB;d0a8d75b824240e0974392958c82bb35
- version: 2.0

## Description

Here is a comprehensive description of the **"PJ : Custom Horizontal Grid  "** Pine Script that we built. You can use this as documentation or as notes for future reference.

### **Overview**
This Pine Script is a custom chart overlay indicator designed to draw a highly customizable grid of horizontal lines. It calculates a central base price, applies an offset (if desired), and generates a series of equidistant lines above and below the center. It also features clean, "floating" text labels that display both the base price and the offset price without obstructing the chart lines.

---

### **Key Features**
*   **Dynamic Grid Generation:** Automatically draws a central line and a user-defined number of grid lines above and below it based on a specific point step (distance).
*   **Price Offsetting (ทดราคา):** Allows the user to input a positive or negative offset. The script will calculate the "Actual Price" (Base Price + Offset) and draw the line at the actual price while still referencing the original base price.
*   **Floating Text Labels:** Displays the price directly on the chart using the format `BasePrice (ActualPrice)`. The text is anchored using `style_label_lower_left`, allowing it to float neatly above the line to prevent visual overlap.
*   **Independent Aesthetics:** Users can style the lines (color, thickness, solid/dashed/dotted) entirely independently from the text labels (color, size) via grouped settings.
*   **Auto-Cleanup (Memory Management):** Uses Pine Script arrays (`array.new_line()` and `array.new_label()`) to track drawn objects. On every real-time tick (`barstate.islast`), it deletes the old lines and labels before drawing new ones, preventing chart clutter and memory issues.

---

### **Input Parameters (Settings)**

The script organizes its settings into three distinct groups for user convenience:

#### **1. Base Settings (No Group)**
*   **Base Start (ราคาเริ่มต้น):** The central anchor price for the grid (e.g., 5000.0).
*   **Offset +/- (ราคาที่ทด):** A fractional value added to or subtracted from the base price to shift the actual drawing location (e.g., -5.0).
*   **Step Distance (ระยะห่างแต่ละเส้น):** The price distance between each subsequent grid line (e.g., 10.0).
*   **Number of Lines +/- (จำนวนเส้นด้านบนและล่าง):** The quantity of lines to draw in *each* direction. (e.g., `5` means 5 above, 5 below, plus 1 center line = 11 lines total).

#### **2. Line Settings (--- ตั้งค่าเส้น ---)**
*   **Line Color:** Color picker for the horizontal grid lines.
*   **Line Width:** Thickness of the lines (1 to 4).
*   **Line Style:** Dropdown to select Solid, Dotted, or Dashed lines.

#### **3. Text Settings (--- ตั้งค่าตัวหนังสือ ---)**
*   **Text Color:** Color picker for the floating price labels.
*   **Text Size:** Dropdown to adjust the font size (Tiny, Small, Normal, Large).

---

### **How the Logic Works (Under the Hood)**

1.  **Helper Functions:** 
    *   `getLineStyle()` and `getSize()` convert the user's string inputs from the dropdown menus into built-in Pine Script variables (e.g., `line.style_dashed`, `size.normal`).
2.  **`drawLineAndLabel(basePrice)` Function:**
    *   Calculates `actualPrice = basePrice + offsetPrice`.
    *   Uses `line.new()` to draw the line extending infinitely to the left and right (`extend=extend.both`).
    *   Formats the text string to 4 decimal places: `strBase (strOffset)`.
    *   Uses `label.new()` at `bar_index + 2` (slightly to the right of the current candle) to render the floating text.
    *   Pushes the generated line and label IDs into their respective arrays.
3.  **Execution Loop (`if barstate.islast`):**
    *   This ensures the script only updates on the most recent candle.
    *   It loops through the arrays, deletes the previous tick's drawings, and clears the arrays.
    *   It calls `drawLineAndLabel()` for the starting price.
    *   It runs a `for` loop to calculate and draw the required `numLines` above (`+ (stepDist * i)`) and below (`- (stepDist * i)`).

## Source Code

````pine
//@version=5
indicator("PJ Grid - OI/IV", overlay=true, max_lines_count=500, max_labels_count=500)

// =================================================================
// 1. ส่วนตั้งค่าราคาและการตีเส้น
// =================================================================
startPrice  = input.float(title="ราคาเริ่มต้น (Base Start)", defval=5000.0, step=0.1)
offsetPrice = input.float(title="ราคาที่ทด (Offset +/-)", defval=-5.0, step=0.1)
stepDist    = input.float(title="ระยะห่างแต่ละเส้น (Step Distance)", defval=10.0, step=0.1)
numLines    = input.int(title="จำนวนเส้นด้านบนและล่าง (+/-)", defval=5, minval=0)

// =================================================================
// 2. ส่วนตั้งค่าความสวยงาม (แยกเส้น และ ตัวหนังสือ)
// =================================================================
grpLine = "--- ตั้งค่าเส้น (Line Settings) ---"
lineColor   = input.color(title="สีเส้น", defval=color.new(color.gray, 50), group=grpLine)
lineWidth   = input.int(title="ความหนาเส้น", defval=1, minval=1, maxval=4, group=grpLine)
lineStyle   = input.string(title="รูปแบบเส้น", defval="Dashed", options=["Solid", "Dotted", "Dashed"], group=grpLine)

grpText = "--- ตั้งค่าตัวหนังสือ (Text Settings) ---"
textColor   = input.color(title="สีตัวหนังสือ", defval=color.blue, group=grpText)
textSizeStr = input.string(title="ขนาดตัวหนังสือ", defval="Normal", options=["Tiny", "Small", "Normal", "Large"], group=grpText)

// =================================================================
// 3. ฟังก์ชันแปลงค่า Settings
// =================================================================
getLineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dotted" ? line.style_dotted : line.style_dashed

getSize(sz) =>
    sz == "Tiny" ? size.tiny : sz == "Small" ? size.small : sz == "Normal" ? size.normal : size.large

// สร้าง Array เก็บข้อมูลเพื่อใช้ลบของเก่า
var line[] gridLines = array.new_line()
var label[] gridLabels = array.new_label()

// =================================================================
// 4. ส่วนคำนวณและวาดกราฟ
// =================================================================
drawLineAndLabel(basePrice) =>
    actualPrice = basePrice + offsetPrice
    
    // 4.1 วาดเส้น (ใช้ค่าสีและความหนาจากกลุ่ม Line Settings)
    l = line.new(x1=bar_index[1], y1=actualPrice, x2=bar_index, y2=actualPrice, color=lineColor, width=lineWidth, style=getLineStyle(lineStyle), extend=extend.both)
    array.push(gridLines, l)
    
    // 4.2 จัดฟอร์แมตตัวเลข และนำมารวมกัน เช่น "5000 (4995)"
    strBase   = str.tostring(basePrice, "#.####")
    strOffset = str.tostring(actualPrice, "#.####")
    txtCombined = "Option price : " + strBase + " -> ( Spot price : " + strOffset + ")"

    // 4.3 สร้างป้ายราคา (ใช้ค่าสีและขนาดจากกลุ่ม Text Settings)
    // style_label_lower_left จะดันให้ข้อความลอยอยู่เหนือพิกัด y (ลอยเหนือเส้น)
    lb = label.new(x=bar_index + 2, y=actualPrice, text=txtCombined, color=color.new(color.white, 100), textcolor=textColor, style=label.style_label_lower_left, size=getSize(textSizeStr))
    array.push(gridLabels, lb)

if barstate.islast
    // ลบเส้นและป้ายเก่าออกให้หมดก่อนวาดใหม่
    if array.size(gridLines) > 0
        for i = 0 to array.size(gridLines) - 1
            line.delete(array.get(gridLines, i))
    if array.size(gridLabels) > 0
        for i = 0 to array.size(gridLabels) - 1
            label.delete(array.get(gridLabels, i))
            
    array.clear(gridLines)
    array.clear(gridLabels)
    
    // วาดชุดเส้นทั้งหมด
    drawLineAndLabel(startPrice)
    if numLines > 0
        for i = 1 to numLines
            drawLineAndLabel(startPrice + (stepDist * i))
            drawLineAndLabel(startPrice - (stepDist * i))


// =================================================================
// 5. Vol2Vol Expected Range Layer (CME-style ±1σ / ±2σ / ±3σ)
//    Expected move = Settlement × (IV/100) × √(DTE/365)
// =================================================================
grpVol       = "--- Vol2Vol Expected Range ---"
showVol      = input.bool(true,  title="Show Vol2Vol Layer", group=grpVol)
autoSettle   = input.bool(true,  title="Auto Settlement = ราคาเปิดวันนี้ + Offset", group=grpVol,
     tooltip="เปิดไว้ = ใช้ราคาเปิดของวันนั้น + Offset อัตโนมัติทุกวัน. ปิดเพื่อกรอก Manual เอง")
manualSettle = input.float(title="Manual Settlement Price (ใช้ตอนปิด Auto)", defval=2000.0, step=0.1, group=grpVol)
ivPct        = input.float(title="Implied Volatility (%)",                   defval=15.0,   step=0.1, minval=0.0, group=grpVol)
dte          = input.int(  title="Days to Expiry (DTE)",                     defval=1,      minval=1, group=grpVol)

// ราคาเปิดของวันนั้น (ดึงจาก Daily TF เพื่อให้ทำงานได้บน intraday chart ด้วย)
dayOpen     = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
settlePrice = autoSettle ? (dayOpen + offsetPrice) : manualSettle

grpVolStyle = "--- Vol2Vol Style ---"
band1Col    = input.color(color.new(color.gray, 55), title="±1σ Fill (เทาเข้ม)",  group=grpVolStyle)
band2Col    = input.color(color.new(color.gray, 72), title="±2σ Fill (เทา)",      group=grpVolStyle)
band3Col    = input.color(color.new(color.gray, 85), title="±3σ Fill (เทาอ่อน)",  group=grpVolStyle)
settleCol   = input.color(color.red,                   title="Settlement Line", group=grpVolStyle)
sigmaLineW  = input.int(  defval=1,  minval=1, maxval=4, title="σ Line Width",  group=grpVolStyle)
volTextSize = input.string(defval="Small", options=["Tiny", "Small", "Normal", "Large"], title="σ Label Size", group=grpVolStyle)

// คำนวณ expected move + band levels
expMove  = settlePrice * (ivPct / 100.0) * math.sqrt(dte / 365.0)
s1Up = settlePrice + expMove
s1Dn = settlePrice - expMove
s2Up = settlePrice + 2 * expMove
s2Dn = settlePrice - 2 * expMove
s3Up = settlePrice + 3 * expMove
s3Dn = settlePrice - 3 * expMove

// Array เก็บ object ของ vol layer (แยกจาก grid)
var line[]  volLines  = array.new_line()
var label[] volLabels = array.new_label()
var box[]   volBoxes  = array.new_box()

drawSigmaLine(yPrice, txt, col) =>
    l = line.new(x1=bar_index[1], y1=yPrice, x2=bar_index, y2=yPrice,
         color=col, width=sigmaLineW, style=line.style_dashed, extend=extend.both)
    array.push(volLines, l)
    lb = label.new(x=bar_index + 2, y=yPrice,
         text=txt + " : " + str.tostring(yPrice, "#.##"),
         color=color.new(color.white, 100), textcolor=col,
         style=label.style_label_lower_left, size=getSize(volTextSize))
    array.push(volLabels, lb)

drawBand(yTop, yBot, col) =>
    bx = box.new(left=bar_index[1], top=yTop, right=bar_index, bottom=yBot,
         border_color=color.new(color.white, 100), bgcolor=col, extend=extend.both)
    array.push(volBoxes, bx)

if barstate.islast
    // ลบของเก่าก่อนวาดใหม่ (ทำทุกครั้งเพื่อให้ toggle off แล้วจางหายไปจริง)
    if array.size(volLines) > 0
        for i = 0 to array.size(volLines) - 1
            line.delete(array.get(volLines, i))
    if array.size(volLabels) > 0
        for i = 0 to array.size(volLabels) - 1
            label.delete(array.get(volLabels, i))
    if array.size(volBoxes) > 0
        for i = 0 to array.size(volBoxes) - 1
            box.delete(array.get(volBoxes, i))
    array.clear(volLines)
    array.clear(volLabels)
    array.clear(volBoxes)

    if showVol
        // วาดแถบแรเงา (ล่างขึ้นบน — ในออกนอก)
        drawBand(s1Up, s1Dn, band1Col)   // ±1σ (ตรงกลาง)
        drawBand(s2Up, s1Up, band2Col)   // +1σ → +2σ
        drawBand(s1Dn, s2Dn, band2Col)   // −1σ → −2σ
        drawBand(s3Up, s2Up, band3Col)   // +2σ → +3σ
        drawBand(s2Dn, s3Dn, band3Col)   // −2σ → −3σ

        // วาดเส้น sigma + label
        drawSigmaLine(s3Up, "+3σ", band3Col)
        drawSigmaLine(s2Up, "+2σ", band2Col)
        drawSigmaLine(s1Up, "+1σ", band1Col)
        drawSigmaLine(s1Dn, "-1σ", band1Col)
        drawSigmaLine(s2Dn, "-2σ", band2Col)
        drawSigmaLine(s3Dn, "-3σ", band3Col)

        // วาดเส้น Settlement (เด่นกว่า) + label สรุปพารามิเตอร์
        sl = line.new(x1=bar_index[1], y1=settlePrice, x2=bar_index, y2=settlePrice,
             color=settleCol, width=2, style=line.style_dashed, extend=extend.both)
        array.push(volLines, sl)
        summaryTxt = "Settle: " + str.tostring(settlePrice, "#.##") +
             "  |  IV=" + str.tostring(ivPct, "#.##") + "%" +
             "  |  DTE=" + str.tostring(dte) +
             "  |  ±1σ=" + str.tostring(expMove, "#.##")
        slb = label.new(x=bar_index + 2, y=settlePrice, text=summaryTxt,
             color=color.new(color.white, 100), textcolor=settleCol,
             style=label.style_label_lower_left, size=size.normal)
        array.push(volLabels, slb)


// =================================================================
// 6. Info Table — แสดงค่าทั้งหมดบนกราฟให้ดูง่าย
//    หมายเหตุ: Pine Script แก้ค่าบนกราฟตรงๆ ไม่ได้
//    → ดับเบิลคลิกชื่อ indicator → Settings → แก้ → กราฟอัปเดต
// =================================================================
grpTable  = "--- Info Table ---"
showTable = input.bool(true, title="Show Info Table บนกราฟ", group=grpTable)
tablePos  = input.string("Top Right", title="ตำแหน่ง",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"],
     group=grpTable)
tableTxt  = input.string("Normal", title="ขนาดตัวอักษร",
     options=["Tiny", "Small", "Normal", "Large"], group=grpTable)

getTablePos(p) =>
    p == "Top Left"      ? position.top_left      :
     p == "Top Right"    ? position.top_right     :
     p == "Bottom Left"  ? position.bottom_left   :
     p == "Bottom Right" ? position.bottom_right  :
     p == "Middle Left"  ? position.middle_left   :
                           position.middle_right

// ต้อง re-create table ทุกครั้งที่ตำแหน่งเปลี่ยน (Pine v5 ไม่ให้แก้ position หลังสร้าง)
var table infoTable = na
var string lastPos = ""

if barstate.islast
    if not na(infoTable) and (lastPos != tablePos or not showTable)
        table.delete(infoTable)
        infoTable := na

    if showTable
        if na(infoTable)
            infoTable := table.new(getTablePos(tablePos), columns=2, rows=5,
                 bgcolor=color.new(color.black, 10),
                 border_width=1, border_color=color.new(color.gray, 30))
            lastPos := tablePos

        sz = getSize(tableTxt)
        labelBg  = color.new(#404040, 0)   // เทาเข้ม ทึบ
        valBg    = color.new(color.black, 0)  // ดำทึบ
        labelCol = color.white
        valCol   = color.yellow              // ค่า — เหลืองสด อ่านง่าย

        table.cell(infoTable, 0, 0, "Settle",  text_color=labelCol, text_size=sz, bgcolor=labelBg)
        table.cell(infoTable, 1, 0, str.tostring(settlePrice, "#.##"), text_color=valCol, text_size=sz, bgcolor=valBg)
        table.cell(infoTable, 0, 1, "IV %",    text_color=labelCol, text_size=sz, bgcolor=labelBg)
        table.cell(infoTable, 1, 1, str.tostring(ivPct, "#.##"),       text_color=valCol, text_size=sz, bgcolor=valBg)
        table.cell(infoTable, 0, 2, "DTE",     text_color=labelCol, text_size=sz, bgcolor=labelBg)
        table.cell(infoTable, 1, 2, str.tostring(dte),                 text_color=valCol, text_size=sz, bgcolor=valBg)
        table.cell(infoTable, 0, 3, "Offset",  text_color=labelCol, text_size=sz, bgcolor=labelBg)
        table.cell(infoTable, 1, 3, str.tostring(offsetPrice, "#.##"), text_color=valCol, text_size=sz, bgcolor=valBg)
        table.cell(infoTable, 0, 4, "±1σ",     text_color=labelCol, text_size=sz, bgcolor=labelBg)
        table.cell(infoTable, 1, 4, str.tostring(expMove, "#.##"),     text_color=valCol, text_size=sz, bgcolor=valBg)
````
