# GoAlgo - Multi-TF Fibo Entry Finder 

- url: https://www.tradingview.com/script/DbgZDijD-GoAlgo-Multi-TF-Fibo-Entry-Finder/
- type: indicator
- pine_id: PUB;8c20abfcac484044af50ebfc782a1505
- version: 1.0

## Description

GoAlgo: Multi-TF Fibo Entry Finder is an advanced multi-timeframe indicator designed to help traders pinpoint precise entry zones using Fibonacci levels combined with market structure tracking and automated alert systems.

🌟 Key Features:
Multi-Timeframe (Multi-TF) Analysis: Tracks higher timeframe structures and key levels to align your trades with the broader market trend.

4 Tiered Entry Zones: Provides 4 distinct Fibonacci-based zones (including the precision 0.67–0.69 reversal area) for structured scaling and optimal entry positioning.

Smart Fibonacci Entry Zones: Automatically calculates optimized Fibonacci retracement levels to spot high-probability entry points.

Overlap Confirmation: Highlights confluence zones where multi-timeframe structures overlap for higher accuracy.

Overlap Confirmation & Structure Guide: Highlights confluence zones using dotted boundary lines and dynamic colors to easily identify market conditions:

    Green Dotted Box (Bullish Structure): Indicates a clear uptrend where price remains above key support levels.

    Red Dotted Box (Bearish Structure): Indicates a clear downtrend where price remains below key resistance levels.

    Gray / Unclear Zone (Consolidation): Signifies that the market is resting, ranging, or lacking a clear directional bias before choosing a breakout path.
Smart Alerts & Multi-Language Support: Includes alerts for structural shifts and price zones, supporting multi-language outputs for automated voice notifications (such as Siri).

Smart Alerts & Multi-Language Support: Includes alerts for structural shifts and price zones, supporting multi-language outputs for automated voice notifications (such as Siri).

⚙️ How to Use:
Add the indicator to your chart.

Select your preferred language for alerts in the settings.

Monitor the background zones and structural lines across the 4 entry tiers to identify optimal Buy/Sell entry points.

## Source Code

````pine
//@version=6
indicator("GoAlgo - Multi-TF Fibo Entry Finder ", overlay=true, max_boxes_count=500)


var int buyAlertState = 0
var int sellAlertState = 0

showHILO = input.bool(true, "Show HI-LO DASH")



// --- STEP 1: Language Selection ---
// --- STEP 1: Language Selection Input ---
langInput = input.string("Thai", "Select Siri Language", options=["Thai", "Chinese", "English", "Vietnamese", "French", "German", "Japanese"])


// --- STEP 2: Localization Dictionary (Native Script for Global Siri) ---
get_msg(key) =>
    string m = ""
    if langInput == "Thai"
        m := key == "g_to_r"    ? "โครงสร้างทามเฟรมถัดไป เปลี่ยนเป็นขาลงแล้ว เตรียมหาจังหวะเข้าเซล" :
             key == "r_to_g"    ? "โครงสร้างทามเฟรมถัดไป ได้เปลี่ยนเป็นขาขึ้นแล้ว เตรียมหาจังหวะเข้าบาย" :
             key == "to_gray"   ? "โครงสร้างทามเฟรมถัดไป เริ่มพักตัว ยังไม่มีทิศทางชัดเจน" :
             key == "gray_to_r" ? "โครงสร้างทามเฟรมถัดไป จบการพักตัว เริ่มมีแรงขายเข้ามาแล้ว" :
             key == "gray_to_g" ? "โครงสร้างทามเฟรมถัดไป จบการพักตัว เริ่มมีแรงซื้อเข้ามาแล้ว" :
             key == "break_up"  ? "ราคากำลังทะลุกรอบแนวต้าน ขึ้นไปแล้ว รอย่อเพื่อหาจุดบาย" :
             key == "break_down"? "ราคากำลังทะลุกรอบแนวรับ ลงไปแล้ว รอเด้งเพื่อหาจุดเซล" :
             key == "lq_up"     ? "แอลคิว ขาขึ้น ราคามีโอกาสปรับตัว ขึ้นไปหาแอลคิว ด้านบน" :
             key == "lq_down"   ? "แอลคิว ขาลง ราคามีโอกาสปรับตัว ลงไปหาแอลคิว ด้านล่าง" :
             key == "buy_z1"    ? "ถึงจุด บายโซนหนึ่ง" :
             key == "buy_z_new" ? "ถึงจุด บายโซน 0.67-0.69" :
             key == "buy_z2"    ? "ถึงจุด บายโซนสอง" :
             key == "buy_last"  ? "ถึงจุด บายโซนสุดท้าย" :
             key == "sell_z1"   ? "ถึงจุด เซลล์โซนหนึ่ง" :
             key == "sell_z_new"? "ถึงจุด เซลล์โซน 0.67-0.69" :
             key == "sell_z2"   ? "ถึงจุด เซลล์โซนสอง" :
             key == "sell_last" ? "ถึงจุด เซลล์โซนสุดท้าย" : ""
    else if langInput == "Chinese"
        m := key == "g_to_r"    ? "下一时段结构转为看跌 准备做空" :
             key == "r_to_g"    ? "下一时段结构转为看涨 准备做多" :
             key == "to_gray"   ? "下一时段结构正在调整 方向不明" :
             key == "gray_to_r" ? "下一时段结构选择向下 抛售压力介入" :
             key == "gray_to_g" ? "下一时段结构选择向上 买盘压力介入" :
             key == "break_up"  ? "价格突破阻力位 有进一步上涨的潜力" :
             key == "break_down"? "价格跌破支撑位 有进一步下跌的潜力" :
             key == "lq_up"     ? "流动性向上转移 价格可能移至上方区域" :
             key == "lq_down"   ? "流动性向下转移 价格可能移至下方区域" :
             key == "buy_z1"    ? "到达买入一区" :
             key == "buy_z_new" ? "到达买入 0.67-0.69 区" :
             key == "buy_z2"    ? "到达买入二区" :
             key == "buy_last"  ? "到达最后买入区" :
             key == "sell_z1"   ? "到达卖出一区" :
             key == "sell_z_new"? "到达卖出 0.67-0.69 区" :
             key == "sell_z2"   ? "到达卖出二区" :
             key == "sell_last" ? "到达最后卖出区" : ""
    else if langInput == "Vietnamese"
        m := key == "g_to_r"    ? "Cấu trúc giảm chuẩn bị bán" :
             key == "r_to_g"    ? "Cấu trúc tăng chuẩn bị mua" :
             key == "to_gray"   ? "Thị trường đang tích lũy" :
             key == "gray_to_r" ? "Thị trường chọn hướng xuống" :
             key == "gray_to_g" ? "Thị trường chọn hướng lên" :
             key == "break_up"  ? "Phá vỡ kháng cự mua" :
             key == "break_down"? "Phá vỡ hỗ trợ bán" :
             key == "lq_up"     ? "Thanh khoản tăng giá" :
             key == "lq_down"   ? "Thanh khoản giảm giá" :
             key == "buy_z1"    ? "Đến vùng mua một" :
             key == "buy_z_new" ? "Đến vùng mua 0.67-0.69" :
             key == "buy_z2"    ? "Đến vùng mua hai" :
             key == "buy_last"  ? "Đến vùng mua cuối" :
             key == "sell_z1"   ? "Đến vùng bán một" :
             key == "sell_z_new"? "Đến vùng bán 0.67-0.69" :
             key == "sell_z2"   ? "Đến vùng bán hai" :
             key == "sell_last" ? "Đến vùng bán cuối" : ""
    else if langInput == "French"
        m := key == "g_to_r"    ? "Structure baissière préparer la vente" :
             key == "r_to_g"    ? "Structure haussière préparer l'achat" :
             key == "to_gray"   ? "Le marché se repose direction incertaine" :
             key == "gray_to_r" ? "Marché à la baisse pression de vente" :
             key == "gray_to_g" ? "Marché à la hausse pression d'achat" :
             key == "break_up"  ? "Cassure de la résistance achat possible" :
             key == "break_down"? "Cassure du support vente possible" :
             key == "lq_up"     ? "Liquidité vers le haut" :
             key == "lq_down"   ? "Liquidité vers le bas" :
             key == "buy_z1"    ? "Zone d'achat un" :
             key == "buy_z_new" ? "Zone d'achat 0.67-0.69" :
             key == "buy_z2"    ? "Zone d'achat deux" :
             key == "buy_last"  ? "Dernière zone d'achat" :
             key == "sell_z1"   ? "Zone de vente un" :
             key == "sell_z_new"? "Zone de vente 0.67-0.69" :
             key == "sell_z2"   ? "Zone de vente deux" :
             key == "sell_last" ? "Dernière zone de vente" : ""
    else if langInput == "German"
        m := key == "g_to_r"    ? "Abwärtsstruktur Verkauf vorbereiten" :
             key == "r_to_g"    ? "Aufwärtsstruktur Kauf vorbereiten" :
             key == "to_gray"   ? "Markt ruht Richtung unklar" :
             key == "gray_to_r" ? "Markt wählt Abwärtsseite Verkaufsdruck" :
             key == "gray_to_g" ? "Markt wählt Aufwärtsseite Kaufdruck" :
             key == "break_up"  ? "Widerstand gebrochen Aufwärtspotenzial" :
             key == "break_down"? "Unterstützung gebrochen Abwärtspotenzial" :
             key == "lq_up"     ? "Liquidität steigt Preis steigt" :
             key == "lq_down"   ? "Liquidität sinkt Preis sinkt" :
             key == "buy_z1"    ? "Kaufzone eins erreicht" :
             key == "buy_z_new" ? "Kaufzone 0.67-0.69 erreicht" :
             key == "buy_z2"    ? "Kaufzone zwei erreicht" :
             key == "buy_last"  ? "Letzte Kaufzone erreicht" :
             key == "sell_z1"   ? "Verkaufszone eins erreicht" :
             key == "sell_z_new"? "Verkaufszone 0.67-0.69 erreicht" :
             key == "sell_z2"   ? "Verkaufszone zwei erreicht" :
             key == "sell_last" ? "Letzte Verkaufszone erreicht" : ""
    else if langInput == "Japanese"
        m := key == "g_to_r"    ? "下降構造 売り準備" :
             key == "r_to_g"    ? "上昇構造 買い準備" :
             key == "to_gray"   ? "保ち合い 転換待ち" :
             key == "gray_to_r" ? "下落トレンド確定 売圧流入" :
             key == "gray_to_g" ? "上昇トレンド確定 買圧流入" :
             key == "break_up"  ? "抵抗線突破 上昇の可能性" :
             key == "break_down"? "支持線突破 下落の可能性" :
             key == "lq_up"     ? "流動性が上方に移動中" :
             key == "lq_down"   ? "流動性が下方に移動中" :
             key == "buy_z1"    ? "買いゾーン一に到達" :
             key == "buy_z_new" ? "買いゾーン 0.67-0.69 に到達" :
             key == "buy_z2"    ? "買いゾーン二に到達" :
             key == "buy_last"  ? "最終買いゾーンに到達" :
             key == "sell_z1"   ? "売りゾーン一に到達" :
             key == "sell_z_new"? "売りゾーン 0.67-0.69 に到達" :
             key == "sell_z2"   ? "売りゾーン二に到達" :
             key == "sell_last" ? "最終売りゾーンに到達" : ""
    else
        m := key == "g_to_r"    ? "Next timeframe structure shifted to Bearish Prepare to Sell" :
             key == "r_to_g"    ? "Next timeframe structure shifted to Bullish Prepare to Buy" :
             key == "to_gray"   ? "Next timeframe structure is resting No clear direction" :
             key == "gray_to_r" ? "Next timeframe structure chose Downside Selling pressure entering" :
             key == "gray_to_g" ? "Next timeframe structure chose Upside Buying pressure entering" :
             key == "break_up"  ? "Price is breaking through Resistance Potential for further upside" :
             key == "break_down"? "Price is breaking through Support Potential for further downside" :
             key == "lq_up"     ? "Liquidity Shift UP Price likely moving to upper zone" :
             key == "lq_down"   ? "Liquidity Shift DOWN Price likely moving to lower zone" :
             key == "buy_z1"    ? "Reached BUY Zone 1" :
             key == "buy_z_new" ? "Reached BUY Zone 0.67-0.69" :
             key == "buy_z2"    ? "Reached BUY Zone 2" :
             key == "buy_last"  ? "Reached BUY Last Zone" :
             key == "sell_z1"   ? "Reached SELL Zone 1" :
             key == "sell_z_new"? "Reached SELL Zone 0.67-0.69" :
             key == "sell_z2"   ? "Reached SELL Zone 2" :
             key == "sell_last" ? "Reached SELL Last Zone" : ""
    m





// ===================================================//
//                  🔥  MACD                          //
// ===================================================//
[macd, signal, hist] = ta.macd(close, 12, 26, 9)

// ==================== HI-LO DASH ===================//

// ===================================================//
//                  🔥  flip                          //
// ===================================================//
flipUp   = hist > 0 and hist[1] < 0
flipDown = hist < 0 and hist[1] > 0

// ===== STORAGE =====
var float swingHigh = na
var float swingLow  = na

var float levelHigh = na
var float levelLow  = na

var float prevHigh = na
var float prevLow  = na

// 🔥 SIGNAL FLAGS
var bool isHL = false
var bool isLH = false

var bool inBull = hist > 0


// ===================================================//
//                  🔥  LOGIC                         //
// ===================================================//

if showHILO
    if inBull
        swingHigh := na(swingHigh) ? high : math.max(swingHigh, high)

        if flipDown
            prevHigh := levelHigh
            levelHigh := swingHigh

            txtHigh = na(prevHigh) ? "HH" : levelHigh > prevHigh ? "HH" : "LH"
            isLH := not na(prevHigh) and levelHigh < prevHigh

            label.new(bar_index, levelHigh, txtHigh,style=label.style_label_down,color=color.new(color.red, 100),textcolor=color.rgb(161, 164, 161), size=size.tiny)

            swingHigh := na
            swingLow := low
            inBull := false

    if not inBull
        swingLow := na(swingLow) ? low : math.min(swingLow, low)

        if flipUp
            prevLow := levelLow
            levelLow := swingLow

            txtLow = na(prevLow) ? "LL" : levelLow < prevLow ? "LL" : "HL"
            isHL := not na(prevLow) and levelLow > prevLow

            label.new(bar_index, levelLow, txtLow, style=label.style_label_up,color=color.new(color.green, 100),textcolor=color.rgb(161, 164, 161), size=size.tiny)

            swingLow := na
            swingHigh := high
            inBull := true

// ===================================================//
//                       🔥 ZONE                      //
// ===================================================//
var int zone = 0
zone := hist > 0 ? 1 : hist < 0 ? -1 : zone[1]
zoneChange = zone != zone[1]

// ===== STRUCTURE =====
var float zoneHigh = na
var int highIndex = na
var float zoneLow = na
var int lowIndex = na

var line activeHighLine = na
var line activeLowLine  = na

var string phase = "WAIT"


// ===================================================//
//                  🔥 COLOR LOGIC                    //
// ===================================================//


// TRACK
if zone == 1
    if na(zoneHigh) or high > zoneHigh
        zoneHigh := high
        highIndex := bar_index

if zone == -1
    if na(zoneLow) or low < zoneLow
        zoneLow := low
        lowIndex := bar_index

// SWITCH
if zoneChange and zone[1] == 1
    activeHighLine := line.new(highIndex, zoneHigh, bar_index, zoneHigh, color=color.new(color.white, 90), width=2)
    phase := "WAIT BUY"
    zoneHigh := na

if zoneChange and zone[1] == -1
    activeLowLine := line.new(lowIndex, zoneLow, bar_index, zoneLow, color=color.new(color.white, 90), width=2)
    phase := "WAIT SELL"
    zoneLow := na

// EXTEND
if not na(activeHighLine)
    hp = line.get_y1(activeHighLine)
    if high < hp
        line.set_xy2(activeHighLine, bar_index, hp)

if not na(activeLowLine)
    lp = line.get_y1(activeLowLine)
    if low > lp
        line.set_xy2(activeLowLine, bar_index, lp)

// REF
refTop = not na(activeHighLine) ? line.get_y1(activeHighLine) : na
refBottom = not na(activeLowLine) ? line.get_y1(activeLowLine) : na

mid = (open + close) / 2

// ===================================================//
//                  🔥 GRADIENT                       //
// ===================================================//
var int phaseCount = 0
if phase != phase[1]
    phaseCount := 0
else
    phaseCount += 1

ratio = math.min(phaseCount / 20, 1.0)
alpha = 80 + int(15 * ratio)

buyColor  = color.new(#05437c, alpha)
sellColor = color.new(color.rgb(70, 40, 1), alpha)

// ===== BG =====
var box[] boxes = array.new_box()

if phase == "WAIT BUY" and not na(refBottom)
    array.push(boxes, box.new(bar_index-1, mid, bar_index, refBottom, bgcolor=buyColor, border_width=0))

if phase == "WAIT SELL" and not na(refTop)
    array.push(boxes, box.new(bar_index-1, refTop, bar_index, mid, bgcolor=sellColor, border_width=0))

if array.size(boxes) > 300
    box.delete(array.shift(boxes))

// ===================================================//
//                       🔥  FIBO                     //
// ===================================================//
var box buyFibo = na
var box sellFibo = na
var int buyState = 0
var int sellState = 0
boxWidth = 30

if phase != phase[1]
    buyState := 0
    sellState := 0
    box.delete(buyFibo)
    box.delete(sellFibo)

if not na(refTop) and not na(refBottom)

    rng = refTop - refBottom

    // BUY (เพิ่ม 0.67 ถึง 0.69)
    b5    = refTop - rng * 0.5
    b618  = refTop - rng * 0.618
    b67   = refTop - rng * 0.67
    b69   = refTop - rng * 0.69
    b764  = refTop - rng * 0.764
    b852  = refTop - rng * 0.852
    b971  = refTop - rng * 0.971
    b1056 = refTop - rng * 1.056

    if phase == "WAIT BUY"

        if buyState == 0 and buyState[1] != 1
            buyState := 1
            box.delete(buyFibo)
            buyFibo := box.new(bar_index, b5, bar_index, b618, bgcolor=color.new(color.gray,80), text="Follow Buy Zone", text_color=color.green, text_size=size.small)

        if buyState == 1 and buyState[1] != 2 and low < b618
            buyState := 2
            box.delete(buyFibo)
            buyFibo := box.new(bar_index, b67, bar_index, b69, bgcolor=color.new(color.green,82), text="Reversal Zone", text_color=color.green, text_size=size.small)

        if buyState == 2 and buyState[1] != 3 and low < b69
            buyState := 3
            box.delete(buyFibo)
            buyFibo := box.new(bar_index, b764, bar_index, b852, bgcolor=color.new(color.green,85), text="Turn upside down Zone", text_color=color.green, text_size=size.small)

        if buyState == 3 and buyState[1] != 4 and low < b852
            buyState := 4
            box.delete(buyFibo)
            buyFibo := box.new(bar_index, b971, bar_index, b1056, bgcolor=color.new(color.green,90), text="Last Buy Zone", text_color=color.green, text_size=size.small)

    // SELL (เพิ่ม 0.67 ถึง 0.69)
    s5    = refBottom + rng * 0.5
    s618  = refBottom + rng * 0.618
    s67   = refBottom + rng * 0.67
    s69   = refBottom + rng * 0.69
    s764  = refBottom + rng * 0.764
    s852  = refBottom + rng * 0.852
    s971  = refBottom + rng * 0.971
    s1056 = refBottom + rng * 1.056

    if phase == "WAIT SELL"

        if sellState == 0 and sellState[1] != 1
            sellState := 1
            box.delete(sellFibo)
            sellFibo := box.new(bar_index, s618, bar_index, s5, bgcolor=color.new(color.gray,80), text="Follow Sell Zone", text_color=color.red, text_size=size.small)

        if sellState == 1 and sellState[1] != 2 and high > s618
            sellState := 2
            box.delete(sellFibo)
            sellFibo := box.new(bar_index, s69, bar_index, s67, bgcolor=color.new(color.red,82), text="Reversal Zone", text_color=color.red, text_size=size.small)

        if sellState == 2 and sellState[1] != 3 and high > s69
            sellState := 3
            box.delete(sellFibo)
            sellFibo := box.new(bar_index, s852, bar_index, s764, bgcolor=color.new(color.red,85), text="Go back down Zone", text_color=color.red, text_size=size.small)

        if sellState == 3 and sellState[1] != 4 and high > s852
            sellState := 4
            box.delete(sellFibo)
            sellFibo := box.new(bar_index, s1056, bar_index, s971, bgcolor=color.new(color.red,90), text="Last Sell Zone", text_color=color.red, text_size=size.small)

    if buyState == 4 and low < b1056
        box.delete(buyFibo)
        buyState := 0

    if sellState == 4 and high > s1056
        box.delete(sellFibo)
        sellState := 0

if not na(buyFibo)
    box.set_right(buyFibo, bar_index)

if not na(sellFibo)
    box.set_right(sellFibo, bar_index)


// ===================================================//
//                 🔥 HTF TRUE LOCK                   //
// ===================================================//
tf_map =
     timeframe.period == "1"   ? "5"   :
     timeframe.period == "5"   ? "15"  :
     timeframe.period == "15"  ? "30"  :
     timeframe.period == "30"  ? "60"  :
     timeframe.period == "60"  ? "240" :
     timeframe.period == "240" ? "D"   :
     timeframe.period == "D"   ? "W"   :
     timeframe.period == "W"   ? "M"   : "D"

f_htf_high() =>
    [m,s,h]=ta.macd(close,12,26,9)
    var float zH=na
    var int z=0
    z:=h>0?1:h<0?-1:z[1]
    if z==1
        zH:=na(zH)?high:math.max(zH,high)
    float result = na
    if z!=z[1] and z[1]==1
        result := zH
        zH := na
    result

f_htf_low() =>
    [m,s,h]=ta.macd(close,12,26,9)
    var float zL=na
    var int z=0
    z:=h>0?1:h<0?-1:z[1]
    if z==-1
        zL:=na(zL)?low:math.min(zL,low)
    float result = na
    if z!=z[1] and z[1]==-1
        result := zL
        zL := na
    result


htfH_raw = request.security(syminfo.tickerid, tf_map, f_htf_high()[1], lookahead = barmerge.lookahead_off)

htfL_raw = request.security(syminfo.tickerid, tf_map, f_htf_low()[1], lookahead = barmerge.lookahead_off)



var float htfH = na
var float htfL = na

if not na(htfH_raw)
    htfH := htfH_raw

if not na(htfL_raw)
    htfL := htfL_raw

// ===================================================//
//                  🔥HTF MEMORY                      //
// ===================================================//
var float htfH_mem = na
var float htfL_mem = na

if not na(htfH)
    htfH_mem := htfH

if not na(htfL)
    htfL_mem := htfL

// ===================================================//
//                    🔥CONTROL                       //
// ===================================================//
showHTFZone = input.bool(true, "Show HTF Overlap")
showHTFFibo = input.bool(true, "Show HTF Fibo")

// ===================================================//
//               🔥 OVERLAP (DOTTED)                //
// ===================================================//
var line topLine = na
var line botLine = na
var line leftLine = na
var line rightLine = na

valid = not na(refBottom) and not na(refTop) and not na(htfH_mem) and not na(htfL_mem)
overlap = valid and (refBottom <= htfH_mem and refTop >= htfL_mem)

isBuy  = valid and refBottom > htfL_mem
isSell = valid and refTop < htfH_mem

borderCol = isBuy ? color.green : isSell ? color.red : color.gray

if overlap and showHTFZone
    top    = math.max(refTop, htfH_mem)
    bottom = math.min(refBottom, htfL_mem)

    line.delete(topLine)
    line.delete(botLine)
    line.delete(leftLine)
    line.delete(rightLine)

    topLine   := line.new(bar_index - 20, top,    bar_index + 20, top,    color=borderCol, style=line.style_dotted, width=1)
    botLine   := line.new(bar_index - 20, bottom, bar_index + 20, bottom, color=borderCol, style=line.style_dotted, width=1)
    leftLine  := line.new(bar_index - 20, bottom, bar_index - 20, top,    color=borderCol, style=line.style_dotted, width=1)
    rightLine := line.new(bar_index + 20, bottom, bar_index + 20, top,    color=borderCol, style=line.style_dotted, width=1)

// ===================================================//
//            🔥 OVERLAP FIBO (เพิ่มเป็น 4 โซน)         //
// ===================================================//

var box ofibo1 = na
var box ofibo2 = na
var box ofibo3 = na
var box ofibo4 = na // เพิ่มกล่องที่ 4

if overlap and showHTFFibo

    top    = math.max(refTop, htfH_mem)
    bottom = math.min(refBottom, htfL_mem)

    rng = top - bottom

    // ===== BUY (เพิ่ม 0.67 และ 0.69)
    ob5    = top - rng * 0.5
    ob618  = top - rng * 0.618
    ob67   = top - rng * 0.67
    ob69   = top - rng * 0.69
    ob764  = top - rng * 0.764
    ob852  = top - rng * 0.852
    ob971  = top - rng * 0.971
    ob1056 = top - rng * 1.056

    // ===== SELL (เพิ่ม 0.67 และ 0.69)
    os5    = bottom + rng * 0.5
    os618  = bottom + rng * 0.618
    os67   = bottom + rng * 0.67
    os69   = bottom + rng * 0.69
    os764  = bottom + rng * 0.764
    os852  = bottom + rng * 0.852
    os971  = bottom + rng * 0.971
    os1056 = bottom + rng * 1.056

    // ===== BUY SIDE (4 โซน)
    if isBuy

        // โซน 1 (0.5 - 0.618)
        if na(ofibo1)
            ofibo1 := box.new(bar_index-20, ob618, bar_index+20, ob5, bgcolor=color.new(color.gray,85), border_width=0)
        else
            box.set_left(ofibo1, bar_index-20), box.set_right(ofibo1, bar_index+20), box.set_top(ofibo1, ob5), box.set_bottom(ofibo1, ob618)

        // โซนใหม่ (0.67 - 0.69)
        if na(ofibo2)
            ofibo2 := box.new(bar_index-20, ob69, bar_index+20, ob67, bgcolor=color.new(#08f328, 80), border_width=0)
        else
            box.set_left(ofibo2, bar_index-20), box.set_right(ofibo2, bar_index+20), box.set_top(ofibo2, ob67), box.set_bottom(ofibo2, ob69)

        // โซน 2 เดิม (0.764 - 0.852)
        if na(ofibo3)
            ofibo3 := box.new(bar_index-20, ob852, bar_index+20, ob764, bgcolor=color.new(color.green,85), border_width=0)
        else
            box.set_left(ofibo3, bar_index-20), box.set_right(ofibo3, bar_index+20), box.set_top(ofibo3, ob764), box.set_bottom(ofibo3, ob852)

        // โซนสุดท้าย (0.971 - 1.056)
        if na(ofibo4)
            ofibo4 := box.new(bar_index-20, ob1056, bar_index+20, ob971, bgcolor=color.new(color.green,90), border_width=0)
        else
            box.set_left(ofibo4, bar_index-20), box.set_right(ofibo4, bar_index+20), box.set_top(ofibo4, ob971), box.set_bottom(ofibo4, ob1056)

    // ===== SELL SIDE (4 โซน)
    if isSell

        // โซน 1 (0.5 - 0.618)
        if na(ofibo1)
            ofibo1 := box.new(bar_index-20, os5, bar_index+20, os618, bgcolor=color.new(color.gray,85), border_width=0)
        else
            box.set_left(ofibo1, bar_index-20), box.set_right(ofibo1, bar_index+20), box.set_top(ofibo1, os618), box.set_bottom(ofibo1, os5)

        // โซนใหม่ (0.67 - 0.69)
        if na(ofibo2)
            ofibo2 := box.new(bar_index-20, os67, bar_index+20, os69, bgcolor=color.new(#f74040, 79), border_width=0)
        else
            box.set_left(ofibo2, bar_index-20), box.set_right(ofibo2, bar_index+20), box.set_top(ofibo2, os69), box.set_bottom(ofibo2, os67)

        // โซน 2 เดิม (0.764 - 0.852)
        if na(ofibo3)
            ofibo3 := box.new(bar_index-20, os764, bar_index+20, os852, bgcolor=color.new(color.red,85), border_width=0)
        else
            box.set_left(ofibo3, bar_index-20), box.set_right(ofibo3, bar_index+20), box.set_top(ofibo3, os852), box.set_bottom(ofibo3, os764)

        // โซนสุดท้าย (0.971 - 1.056)
        if na(ofibo4)
            ofibo4 := box.new(bar_index-20, os971, bar_index+20, os1056, bgcolor=color.new(color.red,90), border_width=0)
        else
            box.set_left(ofibo4, bar_index-20), box.set_right(ofibo4, bar_index+20), box.set_top(ofibo4, os971), box.set_bottom(ofibo4, os1056)

// ===== RESET (ล้างค่าทั้ง 4 กล่องเมื่อหลุดเงื่อนไข)
if not overlap or not showHTFFibo
    box.delete(ofibo1)
    box.delete(ofibo2)
    box.delete(ofibo3)
    box.delete(ofibo4)
    ofibo1 := na
    ofibo2 := na
    ofibo3 := na
    ofibo4 := na


// ===================================================//
//        🔔 HTF STRUCTURE SHIFT ALERT                //
// ===================================================//

var int htfState = 0   
newHTF =
     isBuy  ? 1 :
     isSell ? -1 : 0

cond_g_to_r    = (htfState == 1) and (newHTF == -1)
cond_r_to_g    = (htfState == -1) and (newHTF == 1)
cond_to_gray   = (htfState != 0) and (newHTF == 0)
cond_gray_to_r = (htfState == 0) and (newHTF == -1)
cond_gray_to_g = (htfState == 0) and (newHTF == 1)

alertcondition(cond_g_to_r, title="HTF Changed to Downtrend", message="Market structure has changed to a downtrend")
if cond_g_to_r
    alert(get_msg("g_to_r"), alert.freq_once_per_bar_close)

alertcondition(cond_r_to_g, title="HTF Changed to Uptrend", message="Market structure has changed to an uptrend")
if cond_r_to_g
    alert(get_msg("r_to_g"), alert.freq_once_per_bar_close)

alertcondition(cond_to_gray, title="HTF Consolidation", message="Market is in an unclear state or consolidating")
if cond_to_gray
    alert(get_msg("to_gray"), alert.freq_once_per_bar_close)

alertcondition(cond_gray_to_r, title="HTF Breakdown", message="Market ended consolidation and broke to the downside")
if cond_gray_to_r
    alert(get_msg("gray_to_r"), alert.freq_once_per_bar_close)

alertcondition(cond_gray_to_g, title="HTF Breakout", message="Market ended consolidation and broke to the upside")
if cond_gray_to_g
    alert(get_msg("gray_to_g"), alert.freq_once_per_bar_close)
htfState := newHTF





// =================================================== //
//       🔔 Direct Price Alert (อัปเดตครบทุกโซน)          //
// =================================================== //

if not na(refTop) and not na(refBottom)
    _rng = refTop - refBottom

    _b1    = refTop - _rng * 0.5
    _b_new = refTop - _rng * 0.69
    _b2    = refTop - _rng * 0.764
    _blz   = refTop - _rng * 0.971
    
    _s1    = refBottom + _rng * 0.5
    _s_new = refBottom + _rng * 0.69
    _s2    = refBottom + _rng * 0.764
    _slz   = refBottom + _rng * 0.971

    // --- ส่วนแจ้งเตือนฝั่ง BUY ---
    if low <= _blz and barstate.isconfirmed
        if buyAlertState < 4
            buyAlertState := 4
            alert(get_msg("Last buy zone"), alert.freq_once_per_bar_close)
    else if low <= _b2 and barstate.isconfirmed
        if buyAlertState < 3
            buyAlertState := 3
            alert(get_msg("Turn upside down zone"), alert.freq_once_per_bar_close)
    else if low <= _b_new and barstate.isconfirmed
        if buyAlertState < 2
            buyAlertState := 2
            alert(get_msg("Reversal zone"), alert.freq_once_per_bar_close)
    else if low <= _b1 and barstate.isconfirmed
        if buyAlertState < 1
            buyAlertState := 1
            alert(get_msg("Follow buy zone"), alert.freq_once_per_bar_close)
    
    // --- ส่วนแจ้งเตือนฝั่ง SELL ---
    if high >= _slz and barstate.isconfirmed
        if sellAlertState < 4
            sellAlertState := 4
            alert(get_msg("Last sell zone"), alert.freq_once_per_bar_close)
    else if high >= _s2 and barstate.isconfirmed
        if sellAlertState < 3
            sellAlertState := 3
            alert(get_msg("Go backdown zone"), alert.freq_once_per_bar_close)
    else if high >= _s_new and barstate.isconfirmed
        if sellAlertState < 2
            sellAlertState := 2
            alert(get_msg("Reversal zone"), alert.freq_once_per_bar_close)
    else if high >= _s1 and barstate.isconfirmed
        if sellAlertState < 1
            sellAlertState := 1
            alert(get_msg("Follow sell zone"), alert.freq_once_per_bar_close)

    // --- ระบบ Reset ---
    if low > _b1
        buyAlertState := 0
    if high < _s1
        sellAlertState := 0
````
