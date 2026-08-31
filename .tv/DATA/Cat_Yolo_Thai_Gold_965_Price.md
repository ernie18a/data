<!-- tradingview-pine-id: PUB;9356efa4cd6e4f85a285605b8c61441a -->
<!-- tradingviewscripts-format: 1 -->
# Cat Yolo - Thai Gold 96.5% Price

Source: https://www.tradingview.com/script/jRKl4HXV-Cat-Yolo-Thai-Gold-96-5-Price/

## Description

See the Thai 96.5% gold price (per baht) directly on your XAUUSD chart — no need to switch to a gold-shop website.

HOW IT WORKS (why it's original)
Thai gold is quoted per baht-weight at 96.5% purity, while global gold trades in USD per troy ounce. This indicator converts the live XAUUSD price into the Thai 96.5% price using the real physical constants:
1 baht of Thai gold = 15.244 g at 96.5% purity = 14.709 g pure gold = 0.47292 troy oz.
So: Thai gold (THB) = XAUUSD × 0.47292 × USD/THB + calibration premium.
It then draws a re-centering horizontal grid on the actual XAUUSD levels and labels each level with its THB equivalent, so you can read the Thai baht price at any point on the chart.

WHY THE PREMIUM INPUT
Official shop/association prices include a dealer margin/spread that changes over time and cannot be derived from spot alone. The Premium inputs let you calibrate the Sell/Buy values once to match the announced price; the whole grid shifts with it.

FEATURES
• Dynamic price grid that re-centers as price moves; labels shown in THB (฿)
• Current-price line with a live Thai gold price tag
• Summary table: Sell / Buy / Spot / XAUUSD / USD-THB + daily % change
• Adjustable step size, line count, colors, width, and label offset
• Separate Sell & Buy premium calibration

HOW TO USE
Open OANDA:XAUUSD, add the indicator, then set the Premium inputs so the Sell/Buy values match your local gold association or dealer quote.

SETTINGS (English guide to the on-chart Thai labels)
• Step Size (USD) — spacing between grid lines
• Total lines — number of grid lines
• Recenter trigger (lines) — redraw grid when price moves this many steps from center
• Line color / Line width
• Show price labels (THB) / Label color / Label offset
• Reference formula — troy ounce (g), 1-baht weight (g), purity
• Premium Sell (ขายออก) / Premium Buy (รับซื้อ)
• Table position / text size

NOTES & LIMITATIONS
• The grid and labels are current reference levels drawn on the latest bars. This is a price-conversion tool, not a buy/sell signal generator.
• USD/THB is read on the daily timeframe, so the baht value updates once per day and stays fixed intraday until the daily close.
• No lookahead is used — historical values do not repaint.
• Prices are an approximate reference and may not exactly match official quotes.

For reference/educational use only — not financial advice.

© Yolocat · CAT YOLO

---

## Source Code

````pine
//@version=6
// © Yolocat / CAT YOLO. All rights reserved. For reference/educational use only — not financial advice.
indicator(title = 'Cat Yolo - Thai Gold 96.5% Price', overlay = true, max_lines_count = 500)

// ============================================================
//  Cat Yolo - Thai Gold 96.5% Price
//  Converts live XAUUSD (USD/oz) into the Thai 96.5% gold price
//  (THB per baht) and draws a re-centering reference grid.
//  Thai gold: 1 baht = 15.244 g @ 96.5% = 0.47292 troy oz.
//  © Yolocat / CAT YOLO — unauthorized resale prohibited.
// ============================================================

// --- Reference / calibration ---
troy_oz_g     = input.float(31.1035, 'Troy Ounce (g)', group = 'Reference Formula')
baht_weight_g = input.float(15.244,  'Thai 1-Baht Weight (g)', group = 'Reference Formula')
purity        = input.float(0.965,   'Purity (0.965 = 96.5%)', step = 0.001, group = 'Reference Formula')
premium_ask   = input.float(0.0, 'Premium: Sell / ขายออก (THB)', group = 'Calibration')
premium_bid   = input.float(0.0, 'Premium: Buy / รับซื้อ (THB)', group = 'Calibration')
days_back     = input.int(1, 'Days for % Change', minval = 1, group = 'Growth')

// --- Grid inputs ---
stepSize      = input.float(10.0, 'Step Size (USD) / ระยะห่างเส้น', minval = 0.1, group = 'Grid')
numLines      = input.int(60, 'Total Lines / จำนวนเส้น', minval = 10, maxval = 500, group = 'Grid')
updateTrigger = input.int(20, 'Recenter Trigger (lines) / อัปเดตเมื่อห่าง', minval = 1, group = 'Grid')
lineColor     = input.color(color.new(#9E9E9E, 35), 'Line Color / สีเส้น', group = 'Grid')
lineWidth     = input.int(1, 'Line Width / ความหนา', minval = 1, maxval = 10, group = 'Grid')
showLabels    = input.bool(true, 'Show Price Labels (THB) / แสดงป้ายบาท', group = 'Grid')
labelColor    = input.color(#333333, 'Label Color / สีป้าย', group = 'Grid')
labelOffset   = input.int(40, 'Label Offset (bars) / ระยะป้าย', minval = 0, group = 'Grid')

// --- Fetch (no lookahead -> no repainting of history) ---
usdthb      = request.security('OANDA:USDTHB', 'D', close)
xauusd_prev = request.security('OANDA:XAUUSD', 'D', close[days_back])
usdthb_prev = request.security('OANDA:USDTHB', 'D', close[days_back])

// --- USD gold -> Thai baht (96.5%) converter ---
baht_to_oz = (baht_weight_g * purity) / troy_oz_g   // ≈ 0.47292
round10(p) => math.round(p / 10) * 10
usd_to_baht(pUsd, prem) => round10(pUsd * baht_to_oz * usdthb + prem)

// current values (close = XAUUSD because chart is XAUUSD)
xauusd    = close
gold_sell = usd_to_baht(xauusd, premium_ask)
gold_buy  = usd_to_baht(xauusd, premium_bid)
gold_spot = round10(xauusd * baht_to_oz * usdthb)

// previous day for % change
gold_sell_prev = round10(xauusd_prev * baht_to_oz * usdthb_prev + premium_ask)

// --- % change ---
calc_growth(c, p) => p != 0 ? ((c - p) / p) * 100 : na
gcol(p) => p >= 0 ? #1B7A2E : #C1121F
g_gold = calc_growth(gold_sell, gold_sell_prev)
g_xau  = calc_growth(xauusd, xauusd_prev)
g_thb  = calc_growth(usdthb, usdthb_prev)
fmt(p) => str.tostring(p, '#.##') + '%'

// ============================================================
//  DYNAMIC GRID on XAUUSD price, labels converted to THB
// ============================================================
var lineArray  = array.new_line()
var labelArray = array.new_label()
var float lastCenterPrice = 0.0

// keep labels pinned to the latest bar
if showLabels and array.size(labelArray) > 0
    for i = 0 to array.size(labelArray) - 1
        label.set_x(array.get(labelArray, i), bar_index + labelOffset)

if barstate.islast
    float currentDist = math.abs(close - lastCenterPrice) / stepSize

    if lastCenterPrice == 0.0 or currentDist >= updateTrigger
        if array.size(lineArray) > 0
            for i = 0 to array.size(lineArray) - 1
                line.delete(array.get(lineArray, i))
                label.delete(array.get(labelArray, i))
            array.clear(lineArray)
            array.clear(labelArray)

        float newCenter = math.round(close / stepSize) * stepSize
        lastCenterPrice := newCenter

        int half = math.floor(numLines / 2)
        for i = -half to half
            float pUsd  = newCenter + (i * stepSize)   // USD level (matches candles)
            float pBaht = usd_to_baht(pUsd, premium_ask)

            line l = line.new(bar_index - 1, pUsd, bar_index, pUsd, color = lineColor, width = lineWidth, extend = extend.both)
            array.push(lineArray, l)

            if showLabels
                label lb = label.new(bar_index + labelOffset, pUsd, str.tostring(pBaht, '#,###') + ' THB', style = label.style_none, textcolor = labelColor, size = size.small, textalign = text.align_left)
                array.push(labelArray, lb)

// --- Current price line + THB label ---
var line  curLine  = na
var label curLabel = na
if barstate.islast
    line.delete(curLine)
    label.delete(curLabel)
    curLine := line.new(bar_index - 1, close, bar_index, close, color = #C1121F, width = 2, style = line.style_dashed, extend = extend.both)
    curLabel := label.new(bar_index, close, str.tostring(gold_sell, '#,###') + ' THB', xloc = xloc.bar_index, style = label.style_label_left, color = #C1121F, textcolor = color.white, size = size.normal)

// --- Table (black text / white bg / tiny) ---
tpos  = input.string('bottom_left', 'Table Position', options = ['top_left','top_right','bottom_left','bottom_right'], group = 'Table')
tszin = input.string('tiny', 'Table Text Size', options = ['tiny','small','normal'], group = 'Table')
tsz   = tszin == 'tiny' ? size.tiny : tszin == 'small' ? size.small : size.normal

var table t = table.new(tpos, 3, 7, border_width = 1, frame_color = color.new(color.black, 40), bgcolor = color.white)
table.cell(t, 0, 0, 'GOLD SELL 96.5%', text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 1, 0, str.tostring(gold_sell, '#,###'), text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 2, 0, fmt(g_gold), text_color = gcol(g_gold), bgcolor = color.white, text_size = tsz)
table.cell(t, 0, 1, 'GOLD BUY 96.5%', text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 1, 1, str.tostring(gold_buy, '#,###'), text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 2, 1, '', bgcolor = color.white, text_size = tsz)
table.cell(t, 0, 2, 'SPOT (no premium)', text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 1, 2, str.tostring(gold_spot, '#,###'), text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 2, 2, '', bgcolor = color.white, text_size = tsz)
table.cell(t, 0, 3, 'XAUUSD', text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 1, 3, str.tostring(xauusd, '#,###.##'), text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 2, 3, fmt(g_xau), text_color = gcol(g_xau), bgcolor = color.white, text_size = tsz)
table.cell(t, 0, 4, 'USD/THB', text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 1, 4, str.tostring(usdthb, '#.###'), text_color = color.black, bgcolor = color.white, text_size = tsz)
table.cell(t, 2, 4, fmt(g_thb), text_color = gcol(g_thb), bgcolor = color.white, text_size = tsz)
table.cell(t, 0, 5, 'Approx. reference only', text_color = color.new(color.black, 45), bgcolor = color.white, text_size = size.tiny)
table.cell(t, 1, 5, '', bgcolor = color.white, text_size = size.tiny)
table.cell(t, 2, 5, '', bgcolor = color.white, text_size = size.tiny)
table.cell(t, 0, 6, 'Cat Yolo', text_color = color.new(color.black, 55), bgcolor = color.white, text_size = size.tiny)
table.cell(t, 1, 6, '', bgcolor = color.white, text_size = size.tiny)
table.cell(t, 2, 6, '', bgcolor = color.white, text_size = size.tiny)

// ============================================================
//  DISCLAIMER
//  Thai gold price shown is an APPROXIMATE reference, computed as
//  XAUUSD x USD/THB x 96.5% purity + a user-set premium.
//  It may NOT exactly match Gold Traders Association / dealer
//  quotes, because real dealer margins and spreads vary.
//  Price-conversion tool only — no buy/sell signals.
//  For reference/educational use only — not financial advice.
//  © Yolocat / CAT YOLO
// ============================================================
````
