# Raja OI Grid Lines

- url: https://www.tradingview.com/script/XTb94KVL-Raja-OI-Grid-Lines/
- type: indicator
- pine_id: PUB;ad98a736c9ce42199bcb4d5ea2c6213c
- version: 1.0

## Description

Raja OI Grid Lines is a dynamic Pine Script v6 indicator designed for traders using Spot charts (such as XAUUSD) while tracking Futures or Options Open Interest (OI) levels. It automatically plots horizontal grid lines at precise Spot price levels while labeling them with their corresponding rounded Option Strike Prices based on a customizable daily Basis Offset.

🌟 Key Features
Spot-to-Future Price Alignment: Plots grid lines directly at actual Spot price levels on the chart while displaying the equivalent Futures/Options Strike Price labels (Spot + Basis).

Daily Open Anchor: Uses the Daily Open price as a baseline reference, ensuring grid levels remain stable throughout the trading day without fluctuating with intraday movements.

Automatic Strike Rounding: Automatically rounds target levels to clean, standard Option Strike intervals (e.g., 4000, 4025, 4050, 4075).

Fully Customizable Inputs: Easily update the daily Basis Offset via the settings panel, and adjust line colors, styles, thickness, or the number of displayed grid lines.

💡 How It Works
Example: If Spot XAUUSD is at 4,170 and your Basis Offset is set to 30:

The indicator plots a grid line on the Spot chart at 4,170.

The right-hand label displays 4200 (4,170 + 30).

The next grid line above is drawn at Spot 4,195 with a label showing 4225 (spacing out at standard $25 intervals).

⚙️ Inputs Guide
Basis Offset (USD): The daily difference between Spot and Futures/Options prices to apply.

Grid Step Size (USD): The price interval between Option Strike levels (Default: $25).

Number of Lines (Above/Below): Sets how many grid lines to generate above and below the center anchor (Default: ±20 lines).

Show Strike Price Labels: Toggles the visibility of Futures/Options Strike Price labels on the right edge of the chart.

## Source Code

````pine
//@version=6
indicator("Raja OI Grid Lines", overlay=true)

// ==========================================
// 1. INPUTS
// ==========================================
basisOffset    = input.float(30.0, title="Basis Offset (USD)", tooltip="ค่าส่วนต่าง Basis ที่นำไปบวกเพิ่มเข้ากับราคา Spot เพื่อคำนวณราคา Future/Option")
stepSize       = input.float(25.0, title="Grid Step Size (USD)", minval=0.1, tooltip="ระยะห่างของ Strike Price")
linesCount     = input.int(20, title="Number of Lines (Above/Below)", minval=1, maxval=100, tooltip="จำนวนเส้นที่จะแสดงด้านบนและด้านล่าง")
lineColor      = input.color(color.blue, title="Line Color")
lineStyleInput = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"])
lineWidth      = input.int(1, title="Line Width", minval=1, maxval=4)
showLabels     = input.bool(true, title="Show Strike Price Labels", tooltip="เปิด/ปิด การแสดงป้ายตัวเลขราคา Future")

// ==========================================
// 2. HELPER FUNCTIONS
// ==========================================
getLineStyle(string styleStr) =>
    switch styleStr
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// ==========================================
// 3. CALCULATIONS
// ==========================================
// 1. ดึงราคาเปิด (Open) ของแท่งวันปัจจุบันบนกราฟ Spot (XAUUSD)
float dailyOpenSpot = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)

// 2. คำนวณราคา Future อ้างอิงชั่วคราว เพื่อหา Center Strike Price ที่ลงตัว
float rawFuturePrice = dailyOpenSpot + basisOffset
float centerFutureStrike = math.round(rawFuturePrice / stepSize) * stepSize

// 3. คำนวณราคา Center Spot สำหรับวาดเส้นลงบนกราฟจริง
float centerSpotLevel = centerFutureStrike - basisOffset

// ==========================================
// 4. DRAW GRID LINES & LABELS
// ==========================================
// ฟังก์ชันวาดเส้นที่ราคา Spot แต่แสดงป้ายตัวเลขเป็นราคา Future
drawLineWithLabel(float spotPrice, float futurePrice, color col, string style, int width) =>
    // วาดเส้น Grid ที่ระดับราคา Spot บนกราฟ
    line.new(bar_index - 500, spotPrice, bar_index + 100, spotPrice, 
             color=col, style=style, width=width, extend=extend.both)
    
    // แสดงป้ายตัวเลขราคา Future (Spot + Basis) ทางด้านขวา
    if showLabels
        label.new(x=bar_index + 10, y=spotPrice, 
                  text=str.tostring(futurePrice, "#.##"), 
                  style=label.style_none, 
                  textcolor=col, 
                  textalign=text.align_left)

if barstate.islast
    style = getLineStyle(lineStyleInput)
    
    // 1. วาดเส้น Center Line
    drawLineWithLabel(centerSpotLevel, centerFutureStrike, lineColor, style, lineWidth + 1)
    
    // 2. วาดเส้นระดับราคาด้านบนและด้านล่าง (+- ทีละ $25 ตาม Strike Price)
    for i = 1 to linesCount
        // ระดับราคาด้านบน
        float upperSpotLevel   = centerSpotLevel + (i * stepSize)
        float upperFuturePrice = centerFutureStrike + (i * stepSize)
        drawLineWithLabel(upperSpotLevel, upperFuturePrice, lineColor, style, lineWidth)
        
        // ระดับราคาด้านล่าง
        float lowerSpotLevel   = centerSpotLevel - (i * stepSize)
        float lowerFuturePrice = centerFutureStrike - (i * stepSize)
        drawLineWithLabel(lowerSpotLevel, lowerFuturePrice, lineColor, style, lineWidth)
````
