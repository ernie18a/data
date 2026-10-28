# Futures to CFD Precision Mapper & Dynamic SL Calculator 

- url: https://www.tradingview.com/script/pOecPGQm/
- type: indicator
- pine_id: PUB;71417519f4494108bd8a18d7eef0d7bc
- version: 1.0

## Description

Day trading CFDs (Spot) while analyzing Futures charts (like GC1! or NQ1!) provides a massive edge in reading true volume and liquidity. However, manually calculating the dynamic basis (price difference) and adjusting for decimal precision when placing Stop Loss (SL) or Take Profit (TP) orders is tedious and error-prone. 

This indicator acts as a bridge, allowing you to seamlessly analyze Futures while getting exact, actionable order prices for your CFD broker (optimized for Pepperstone).

### 🌟 Key Features

🤖 Auto-Symbol Recognition
No need to manually type ticker names when switching charts. The script automatically detects the Futures root and maps it to the corresponding CFD:
• GC1! ➔ XAUUSD
• NQ1! ➔ NAS100
• ES1! ➔ US500
• SI1! ➔ XAGUSD
• CL1! ➔ XTIUSD

🎯 Interactive Visual Mapping
Use the "Crosshair" tool inside the indicator settings to drop a reference line anywhere on your Futures chart. The built-in dashboard will instantly calculate the exact corresponding price for your CFD broker.

🛡️ Dynamic Spread Defense (Volatility Buffer)
The basis between Futures and CFDs isn't static. During high-impact news, spreads widen. This script calculates the 20-period Standard Deviation of the basis to provide a "Safe Buffer". The dashboard displays dynamically adjusted Long/Short SL levels to protect you from being stopped out by artificial broker spread widening (Stop Hunts).

📏 Strict Mintick Precision Formatting
TradingView often drops trailing zeros (e.g., showing 4825.6 instead of 4825.60). This script forces strict adherence to the broker's minimum tick precision, ensuring the numbers you see are exactly what you need to input into your trading terminal (MT4/MT5/cTrader).

🆘 "Anti-Lost" Reset Toggle
If you change timeframes or symbols and lose your reference line, simply check the "Emergency Center" box in the settings to instantly snap the line back to the current market price.

### ⚙️ How to Use (Crucial!)
Since Pine Script cannot create draggable lines that save their coordinates automatically, follow these steps to place your SL/TP line:
1. Open the Indicator Settings (⚙️).
2. Find the "Target Price" input.
3. Click the "Crosshair" icon next to the input field.
4. Click anywhere on your chart to drop the line and save its coordinates. The dashboard will update instantly.

### ⚠️ Disclaimer
This script is designed for educational and analytical purposes. The dynamic buffer is a mathematical estimation based on recent standard deviation and does not guarantee protection against extreme slippage. Always manage your risk.

## Source Code

````pine
//@version=6
indicator("Pepperstone 終極精確版 (修正原油代號)", overlay=true)

// ================= 1. 自動商品映射 =================
string autoSpot = switch syminfo.root
    "GC" => "PEPPERSTONE:XAUUSD"
    "NQ" => "PEPPERSTONE:NAS100"
    "ES" => "PEPPERSTONE:US500"
    "SI" => "PEPPERSTONE:XAGUSD"
    // 💡 修正：Pepperstone 的 WTI 原油代號通常為 XTIUSD
    "CL" => "PEPPERSTONE:XTIUSD"
    => "PEPPERSTONE:XAUUSD"

spotSymbol = input.symbol("", title="手動指定現貨 (留空則自動識別)")
finalSpot = spotSymbol == "" ? autoSpot : spotSymbol

// ================= 2. 座標與防走失設定 =================
refPrice = input.price(4850.1, title="🎯 拖曳位 (點右側十字準心可存檔)")
forceCenter = input.bool(false, title="🚨 緊急找回：勾選此框強制拉回現價")

// ================= 3. 數據獲取與計算 =================
[sPrice, sMintick] = request.security(finalSpot, timeframe.period, [close, syminfo.mintick])
fPrice = close
basis = fPrice - sPrice

actualRef = forceCenter ? fPrice : refPrice
mappedSpotPrice = actualRef - basis
safeBuffer = ta.stdev(basis, 20) * 2.0

// ================= 4. 強制精度顯示 (Pepperstone .00) =================
f_format(val, m) =>
    fmt = m <= 0.0001 ? "#.0000" : m <= 0.001 ? "#.000" : m <= 0.01 ? "#.00" : m <= 0.1 ? "#.0" : "#"
    str.tostring(val, fmt)

// ================= 5. 視覺呈現 =================
themeColor = color.rgb(215, 214, 222)
var line refLine = line.new(bar_index, actualRef, bar_index + 10, actualRef, width=1, color=color.rgb(212, 211, 220, 50), extend=extend.both, style=line.style_dashed)
line.set_y1(refLine, actualRef)
line.set_y2(refLine, actualRef)

var label pLabel = label.new(bar_index, actualRef, text="", style=label.style_label_left, color=color.rgb(0,0,0,100), textcolor=themeColor)
label.set_xy(pLabel, last_bar_index + 3, actualRef)

statusText = forceCenter ? "⚠️ 鎖定現價中" : ("➔ 期貨設定: " + str.tostring(actualRef, format.mintick))
label.set_text(pLabel, statusText + "\n➔ 現貨下單: " + f_format(mappedSpotPrice, sMintick))

var table infoTable = table.new(position.bottom_right, 2, 5, bgcolor=color.rgb(0, 0, 0, 80), border_width=1, border_color=color.rgb(100,100,100,50))
if barstate.islast
    table.cell(infoTable, 0, 0, "識別商品", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 0, finalSpot, text_color=color.white, text_size=size.small)
    
    table.cell(infoTable, 0, 1, "現貨即時現價", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 1, f_format(sPrice, sMintick), text_color=color.yellow)

    table.cell(infoTable, 0, 2, "目前拉線座標", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(actualRef, format.mintick), text_color=color.white)
    
    table.cell(infoTable, 0, 3, "多單安全止損", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 3, f_format(mappedSpotPrice - safeBuffer, sMintick), text_color=color.rgb(33, 206, 30))
    
    table.cell(infoTable, 0, 4, "空單安全止損", text_color=color.gray, text_size=size.small)
    table.cell(infoTable, 1, 4, f_format(mappedSpotPrice + safeBuffer, sMintick), text_color=color.rgb(226, 24, 24))
````
