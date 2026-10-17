# key level -she trades

- url: https://www.tradingview.com/script/23nhaZHf-key-level-she-trades/
- type: indicator
- pine_id: PUB;025ac6ba0e8a46b9a29b225cbb63ae17
- version: 2.0

## Description

Description:
key level -she trades is a professional-grade technical analysis tool designed to identify high-probability institutional zones based on mathematical price ranges. This indicator divides a user-defined price range into 8 precise "Octave" levels, helping traders visualize where price is likely to react, reverse, or consolidate.
🚀 Key Features:
Mathematical Precision: Automatically calculates 7 internal levels between your chosen High and Low prices using a balanced step logic (Gann/Murray Math style).
Dynamic Touch Detection: A unique visual feedback system where lines change color (Gold) and thickness in real-time when the price touches a key level.
Institutional Color Coding:
Black: Major structure boundaries (Top Range, Pivot Point, and Bottom Range).
Red (Neon): Premium Sell Zones for potential reversals or supply entries.
Blue (Neon): Discount Buy Zones for potential long entries or demand clusters.
Pro UI/UX: Clean, non-cluttering labels that display the exact price of each level for fast decision-making.
Smart Alerts: Built-in alert system to notify you the moment the price hits the Pivot Point or the extreme Buy/Sell zones.
📈 How to Use:
Identify the Range: Find a significant high and low on your current timeframe.
Input Prices: Enter these values into the indicator settings.
Execute:
Look for Sell setups in the Red Zones.
Look for Buy setups in the Blue Zones.
Use the Black Pivot as a target or a trend-bias confirmation.
Perfect For:
Scalpers looking for quick rejections.
Day traders identifying intraday ranges.
Price Action traders who need clean, mathematical levels.

## Source Code

````pine
//@version=5
indicator("Key Level - She Trades [Clean]", shorttitle="KL-SheTrades-Clean", overlay=true)

// --- Inputs ---
grp_set = "⚙️ الإعدادات"
highPrice   = input.float(4890.967, "أعلى سعر (High)", group=grp_set)
lowPrice    = input.float(4098.275, "أقل سعر (Low)", group=grp_set) 
labelOffset = input.int(15, "إزاحة التسمية", group=grp_set)

grp_clr = "🎨 الألوان والتنسيق"
colorMajor = input.color(#333333, "المستويات الرئيسية", group=grp_clr)
colorSell  = input.color(#e91e63, "مستويات البيع", group=grp_clr)       
colorBuy   = input.color(#2196f3, "مستويات الشراء", group=grp_clr)      
colorTouch = input.color(#ff9800, "عند اللمس", group=grp_clr)

// --- Logic ---
rangeVal = highPrice - lowPrice
step = rangeVal / 8
sensitivity = 0.03 

// Levels Calculation
float mid  = highPrice - step * 4
float lvl1 = highPrice - step      
float lvl2 = highPrice - step * 2  
float lvl3 = highPrice - step * 3  
float lvl5 = highPrice - step * 5  
float lvl6 = highPrice - step * 6  
float lvl7 = highPrice - step * 7  

is_touching(p) =>
    math.abs(close - p) <= (rangeVal * sensitivity / 100)

// --- Drawing Function (Simplified) ---
f_draw_level(price, txt, col, style, width) =>
    bool touching = is_touching(price)
    lineColor = touching ? colorTouch : col
    lineW     = touching ? width + 1 : width
    
    // رسم الخط
    var line l = na
    line.delete(l)
    l := line.new(bar_index, price, bar_index + 10, price, 
                  xloc = xloc.bar_index, extend = extend.both, 
                  color = color.new(lineColor, 20), // شفافية بسيطة للخطوط لراحة العين
                  width = lineW, 
                  style = style)
    
    // رسم النص (Label)
    var label lbl = na
    label.delete(lbl)
    lbl := label.new(bar_index + labelOffset, price, 
                     text = txt + " (" + str.tostring(price, "#.##") + ")", 
                     style = label.style_none,      
                     textcolor = lineColor,
                     size = size.small)

// --- التنفيذ (Execution) ---

// المستويات الأساسية (خطوط متصلة وعريضة قليلاً)
f_draw_level(highPrice, "TOP", colorMajor, line.style_solid, 2)
f_draw_level(mid,       "MID", colorMajor, line.style_solid, 2) 
f_draw_level(lowPrice,  "BOT", colorMajor, line.style_solid, 2)

// مستويات البيع والشراء (خطوط مقطعة ناعمة)
f_draw_level(lvl1, "SELL 1", colorSell, line.style_dashed, 1)
f_draw_level(lvl2, "SELL 2", colorSell, line.style_dashed, 1)
f_draw_level(lvl3, "SELL 3", colorSell, line.style_dashed, 1)

f_draw_level(lvl5, "BUY 1", colorBuy, line.style_dashed, 1)
f_draw_level(lvl6, "BUY 2", colorBuy, line.style_dashed, 1) 
f_draw_level(lvl7, "BUY 3", colorBuy, line.style_dashed, 1)

// --- Alerts ---
if is_touching(lvl1) or is_touching(lvl7) or is_touching(mid)
    alert("Price Hit a Level", alert.freq_once_per_bar)
````
