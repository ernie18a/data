# SMC OB

- url: https://www.tradingview.com/script/LirgZOhj/
- type: indicator
- pine_id: PUB;d7e0ac181fa7432bae86affa9b44f960
- version: 1.0

## Description

This is a professional, high-impact English introduction for your indicator. It is designed to look great on the TradingView "Public Library" or for your own promotional use. It highlights the features we just fixed and focuses on the **Smart Money Concepts (SMC)** logic.

---

## **SMC Order Block Pro | High-Probability Institutional Zones**

### **Overview**
The **SMC Order Block Pro** is a professional-grade tool designed for traders utilizing **Smart Money Concepts (SMC)** and **ICT** methodologies. This indicator automates the tedious task of identifying Market Structure Breaks (**BOS**) and the specific **Order Blocks (OB)** that follow, providing you with high-precision institutional entry zones.

Unlike generic indicators that clutter your chart with every single candle, this Pro version uses a **dual-confluence filtering system** (Engulfing + FVG) to ensure you only see the highest-probability setups.

---

### **Key Features**

* **⚡ Automated BOS Detection:** Automatically identifies "Break of Structure" points to confirm trend shifts and market intent.
* **📦 Smart Order Block Identification:** Scans historical price action to find the exact "last opposite candle" before a significant move.
* **🔍 High-Probability Filters:**
    * **Engulfing Confirmation:** Only validates OBs that show immediate institutional strength.
    * **FVG (Fair Value Gap) Detection:** Filters for OBs accompanied by price imbalances, a hallmark of big-bank participation.
* **🎯 Real-Time Mitigation Tracking:** Zones automatically change color or disappear once they are "mitigated" (tested by price), keeping your chart clean and relevant.
* **📊 Live Statistics Dashboard:** A sleek table showing total identified zones versus unmitigated opportunities.

---

### **How to Use It**

1.  **Identify the BOS:** Wait for the indicator to signal a Break of Structure.
2.  **Wait for the OB:** Look for the Blue (Bullish) or Red (Bearish) boxes to appear.
3.  **Check for Warnings:** The indicator will label OBs as *"No FVG"* or *"Unconfirmed"* if they don't meet the high-probability criteria, allowing you to exercise caution.
4.  **The Entry:** Look for a return to the "Unmitigated" zone for a potential high R:R entry.

---

### **Technical Settings**
* **BOS Confirmation:** Adjust how many candles are needed to confirm a structural break.
* **OB Scanning Range:** Control how far back the script looks to find the valid supply/demand zone.
* **FVG Threshold:** Fine-tune the sensitivity of the imbalance detection.

---

### **Disclaimer**
*This indicator is for educational and analytical purposes only. Trading involves significant risk, and past performance is not indicative of future results. Always use proper risk management.*

---

### **Suggested Tags for TradingView:**
#SMC #ICT #OrderBlock #PriceAction #SmartMoney #SupplyAndDemand #BOS #FVG

---

### **Pro-tip for your post:**
When you post this on TradingView, **attach a screenshot** showing a clear BOS followed by price retracing into one of the blue/red boxes and bouncing. People love seeing the "mitigation" in action!

**Do you need me to adjust the tone to be more aggressive (marketing-heavy) or more academic?**

## Source Code

````pine
//@version=5
indicator(title="Advanced SMC Order Block Indicator", shorttitle="SMC OB Pro", overlay=true, max_boxes_count=500, max_labels_count=500)

// ================================================================================================
// 第一部分: 用戶輸入面板
// ================================================================================================
group_bos = "BOS 檢測設置"
enableBOS = input.bool(true, "啟用 BOS 識別", group=group_bos)
bosCandles = input.int(2, "BOS 確認柱數", minval=1, maxval=10, group=group_bos)

group_ob = "OB 定義設置"
enableOB = input.bool(true, "啟用 OB 識別", group=group_ob)
obRange = input.int(20, "OB 掃描範圍(柱數)", minval=5, maxval=100, group=group_ob)

group_engulfing = "吞噬確認篩選"
enableEngulfing = input.bool(true, "啟用吞噬確認", group=group_engulfing)
engulfingStrength = input.float(0.5, "吞噬強度(%)", minval=0.0, maxval=1.0, step=0.1, group=group_engulfing)

group_fvg = "FVG 伴隨檢測"
enableFVG = input.bool(true, "啟用 FVG 檢測", group=group_fvg)
fvgThreshold = input.float(0.5, "FVG 尺寸倍數", minval=0.1, maxval=2.0, step=0.1, group=group_fvg)

group_colors = "色彩與透明度"
bullishOBColor = input.color(color.new(color.blue, 80), "看漲 OB 顏色", group=group_colors)
bearishOBColor = input.color(color.new(color.red, 80), "看跌 OB 顏色", group=group_colors)
mitigatedOBColor = input.color(color.new(color.gray, 90), "已觸及 OB 顏色", group=group_colors)
borderColor = input.color(color.new(color.black, 50), "邊框顏色", group=group_colors)

group_alerts = "標籤與告警"
showLabels = input.bool(true, "顯示標籤", group=group_alerts)
enableAlerts = input.bool(true, "啟用告警", group=group_alerts)
showMitigated = input.bool(false, "顯示已觸及區塊", group=group_alerts)

// ================================================================================================
// 第二部分: 資料結構
// ================================================================================================
type OrderBlock
    int startBar
    int endBar
    float obHigh
    float obLow
    bool isBullish
    bool isMitigated
    box boxObj
    label labelObj
    bool hasEngulfing
    bool hasFVG

var array<OrderBlock> orderBlocks = array.new<OrderBlock>()

// ================================================================================================
// 第三部分: 核心邏輯
// ================================================================================================
float global_lowest = ta.lowest(low, bosCandles + 1)
float global_highest = ta.highest(high, bosCandles + 1)

f_isBullishBOS() =>
    enableBOS and bar_index >= bosCandles and close > global_lowest and close[1] <= global_lowest

f_isBearishBOS() =>
    enableBOS and bar_index >= bosCandles and close < global_highest and close[1] >= global_highest

f_findBullishOB(int startIdx) => 
    int fBar = -1, float fH = 0.0, float fL = 0.0
    for i = 1 to obRange
        if startIdx - i >= 0 and close[i] < open[i]
            fBar := bar_index - i, fH := high[i], fL := low[i]
            break
    [fBar, fH, fL]

f_findBearishOB(int startIdx) =>
    int fBar = -1, float fH = 0.0, float fL = 0.0
    for i = 1 to obRange
        if startIdx - i >= 0 and close[i] > open[i]
            fBar := bar_index - i, fH := high[i], fL := low[i]
            break
    [fBar, fH, fL]

f_verifyEngulfing(float obH, float obL, bool isBull) =>
    not enableEngulfing or (high > obH and low < obL)

f_detectFVG(float obH, float obL, bool isBull) =>
    bool res = true
    if enableFVG and bar_index >= 2
        float sz = (obH - obL) * fvgThreshold
        res := isBull ? (low - high[1] > sz) : (low[1] - high > sz)
    res

// ================================================================================================
// 第四部分: 繪製功能 (修正後的重點區域)
// ================================================================================================
f_drawOrderBlock(int sBar, int eBar, float obH, float obL, bool isBull, bool hasE, bool hasF) =>
    color bCol = isBull ? bullishOBColor : bearishOBColor
    if enableEngulfing and not hasE
        bCol := color.new(color.orange, 85)
    
    box bObj = box.new(sBar, obH, eBar, obL, xloc=xloc.bar_index, border_color=borderColor, bgcolor=bCol)
    
    label lObj = na
    if showLabels
        string txt = (isBull ? "Bullish OB" : "Bearish OB") + (hasE ? "" : "\n⚠ 未確認") + (hasF ? "" : "\n✗ 無FVG")
        float yPos = isBull ? obL : obH
        lObj := label.new(sBar, yPos, txt, xloc=xloc.bar_index, yloc=isBull ? yloc.belowbar : yloc.abovebar, color=bCol, textcolor=color.white, size=size.small, style=isBull ? label.style_label_up : label.style_label_down)
    [bObj, lObj]

// ================================================================================================
// 第五部分: 執行與管理
// ================================================================================================
if f_isBullishBOS()
    [b, h, l] = f_findBullishOB(bar_index)
    if b != -1 and l > 0
        hasE = f_verifyEngulfing(h, l, true), hasF = f_detectFVG(h, l, true)
        if (not enableEngulfing or hasE) and (not enableFVG or hasF)
            [bx, lb] = f_drawOrderBlock(b, bar_index, h, l, true, hasE, hasF)
            array.push(orderBlocks, OrderBlock.new(b, bar_index, h, l, true, false, bx, lb, hasE, hasF))

if f_isBearishBOS()
    [b, h, l] = f_findBearishOB(bar_index)
    if b != -1 and h > 0
        hasE = f_verifyEngulfing(h, l, false), hasF = f_detectFVG(h, l, false)
        if (not enableEngulfing or hasE) and (not enableFVG or hasF)
            [bx, lb] = f_drawOrderBlock(b, bar_index, h, l, false, hasE, hasF)
            array.push(orderBlocks, OrderBlock.new(b, bar_index, h, l, false, false, bx, lb, hasE, hasF))

// 觸及檢測
if array.size(orderBlocks) > 0
    for i = 0 to array.size(orderBlocks) - 1
        ob = array.get(orderBlocks, i)
        if not ob.isMitigated and bar_index > ob.endBar
            if (ob.isBullish and low <= ob.obLow) or (not ob.isBullish and high >= ob.obHigh)
                ob.isMitigated := true
                box.set_bgcolor(ob.boxObj, mitigatedOBColor)
                if not na(ob.labelObj)
                    label.set_text(ob.labelObj, (ob.isBullish ? "Bullish" : "Bearish") + " OB\n[已觸及]")

// 清理舊數據
if bar_index % 50 == 0 and array.size(orderBlocks) > 0
    int i = 0
    while i < array.size(orderBlocks)
        ob = array.get(orderBlocks, i)
        if bar_index - ob.endBar > 500 and ob.isMitigated
            box.delete(ob.boxObj), label.delete(ob.labelObj), array.remove(orderBlocks, i)
        else
            i += 1
````
