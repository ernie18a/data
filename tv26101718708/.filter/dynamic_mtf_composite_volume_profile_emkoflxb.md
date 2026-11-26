# Dynamic MTF Composite Volume Profile

- url: https://www.tradingview.com/script/eMkofLxB-Dynamic-MTF-Composite-Volume-Profile/
- type: indicator
- pine_id: PUB;4b9216a1ae814017813cac7712b8b4ea
- version: 2.0

## Description

🔷[b] Overview[/b]

The Dynamic MTF Composite Volume Profile is a multi-timeframe volume-based analysis tool designed to help traders identify key market zones where significant trading activity has occurred. It builds a dynamic structure using higher timeframe volume behavior to approximate institutional interest areas such as Point of Control (POC) and High Volume Zones (HVZ).

This indicator is optimized for [b]Gold (XAUUSD)[/b] but also performs well on Forex, Indices, Crypto, and Futures markets.

----------------------------

⚙️ [b]Indicator Concept[/b]
Unlike traditional indicators that rely only on price movement, this tool combines [b]multi-timeframe volume + price structure[/b] to estimate where the market is most active.

It helps traders understand:

* Where smart money is likely active
* Where price may react or consolidate
* Where trend bias is shifting

------------------------------------

📌 [b]Features[/b]

• Multi-Timeframe Volume Structure (MTF)
• Dynamic Composite Volume Calculation
• Approximate Point of Control (POC)
• High Volume Zone (HVZ) Detection
• Volume-Based Trend Bias
• Support & Resistance Estimation
• Clean Visual Layout
• Lightweight and Fast Execution
• Works on All Timeframes

-----------------------------------------

📈 [b]How It Works[/b]

🔴 [b]Dynamic POC[/b]

The POC represents the price level where the highest relative volume activity occurs within the selected lookback period.

* Acts as a [b]market equilibrium zone[/b]
* Price often reacts or reverts near this level

----------------------------------------

🟢 [b]High Volume Zone (HVZ)[/b]
🟠 [b]low Volume Zone (HVZ)[/b]

The HVZ highlights the range where most trading activity occurred.
* Often acts as [b]support or resistance[/b]
* Can indicate accumulation or distribution areas

📊 [b]Trend Bias[/b]

* Price above POC → Bullish bias
* Price below POC → Bearish bias
* Strong reactions near HVZ confirm structure shifts

🧠 [b]Trading Strategy (Simple Setup)[/b]
https://www.tradingview.com/x/D767HGcl/
🔼 [b]Buy Setup[/b]
* Price is above Dynamic POC
* Price pulls back into HVZ or near POC
* Bullish candle confirmation appears
* Enter long with stop below zone

🔽 [b]Sell Setup[/b]
* Price is below Dynamic POC
* Price retraces into HVZ or near POC
* Bearish rejection appears
* Enter short with stop above zone

⏱️ [b]Recommended Timeframes[/b]

* M5 (Scalping)
* M15 (Intraday entries)
* H1 (Swing confirmation)
* H4 (Trend structure)

🌍 [b]Best Markets[/b]

* 🟡 XAUUSD (Gold)
* 💱 Forex pairs
* 📊 Indices (US30, NAS100, S&P500)
* ₿ Crypto markets
* 📦 Futures

---------------------------------------------

⚠️ [b]Important Notes[/b]

This indicator uses approximate volume modeling due to Pine Script limitations. TradingView does not allow full volume-at-price reconstruction in custom scriptsIt is intended for educational and analytical purposes only and should be combined with price action or other confirmation tools.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Dynamic MTF Composite Volume Profile", overlay=true, max_lines_count=500, max_boxes_count=500)

//==================== Inputs ====================//
tf = input.timeframe("240", "Higher Timeframe")
length = input.int(100, "Composite Length", minval=20)
showPOC = input.bool(true, "Show Dynamic POC")
showHVZ = input.bool(true, "Show High Volume Zone")

//==================== MTF Data ====================//
htfClose = request.security(syminfo.tickerid, tf, close)
htfHigh  = request.security(syminfo.tickerid, tf, high)
htfLow   = request.security(syminfo.tickerid, tf, low)
htfVol   = request.security(syminfo.tickerid, tf, volume)

//==================== Composite Volume ====================//
compVol = ta.sma(htfVol, length)

//==================== Dynamic POC (Approximation) ====================//
highestVol = ta.highest(htfVol, length)
pocPrice = ta.valuewhen(htfVol == highestVol, htfClose, 0)

//==================== High Volume Zone ====================//
zoneHigh = ta.highest(htfHigh, length)
zoneLow  = ta.lowest(htfLow, length)

//==================== Plot ====================//
plot(showPOC ? pocPrice : na,
     title="Dynamic POC",
     color=color.red,
     linewidth=3)

plot(showHVZ ? zoneHigh : na,
     color=color.new(color.green,40),
     title="HVZ High")

plot(showHVZ ? zoneLow : na,
     color=color.new(color.orange,40),
     title="HVZ Low")

//==================== Trend ====================//
trendColor = close > pocPrice ? color.lime : color.red

barcolor(trendColor)

//==================== Table ====================//
var table t = table.new(position.top_right,2,4)

if barstate.islast
    table.cell(t,0,0,"MTF")
    table.cell(t,1,0,tf)

    table.cell(t,0,1,"Composite Vol")
    table.cell(t,1,1,str.tostring(compVol))

    table.cell(t,0,2,"POC")
    table.cell(t,1,2,str.tostring(pocPrice))

    table.cell(t,0,3,"Trend")
    table.cell(t,1,3,close>pocPrice?"Bullish":"Bearish")
````
