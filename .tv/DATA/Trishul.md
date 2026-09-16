<!-- tradingview-pine-id: PUB;d034bf20a47742729dee9a3aee198d95 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trishul

Source: https://www.tradingview.com/script/lgNhcbwD-Three-Drives-Pivot-Scanner-Trishul/

## Description

1. Description
The Three Drives pattern is a structural price formation made up of three sequential directional drive-legs, each separated by a corrective retracement. Each successive drive extends beyond the last within defined Fibonacci proportions, while each retracement holds within a defined range relative to the preceding move. The completed structure is traditionally read as an exhaustion pattern, with the completion of the third drive forming a Potential Reversal Zone (PRZ).

Three Drives Pivot Scanner [Trishul] detects Three Drives structures automatically using a pivot based detection system and, provides two concurrent methods:

[*]Pivot Confirmed — waits for the complete six-point structure to be confirmed. 
[*]Live Projection — projects the PRZ while the third drive is still forming and identifies when price first trades into the projected zone. 
[image]https://www.tradingview.com/x/FCEFHXsh/[/image]
2. Features

[*]Pivot-Based Structural Detection
Structural swing highs and swing lows are identified using Pine Script's built-in pivot functions. The pivot length is user adjustable, allowing the detector to be tuned from more reactive short-term structures to broader, slower moving structures. Confirmed pivots are stored in an array and evaluated sequentially to determine whether the resulting swing structure satisfies the Three Drives geometric requirements.
[pine]pivot high = ta.pivothigh(high, pivLen, pivLen)
pivot low = ta.pivotlow(low, pivLen, pivLen)
// default pivot length is 5. 
// shorter pivot length produces more patterns,[/pine][image] https://www.tradingview.com/x/gModdyGN/[/image]
[*]Method 1 — Pivot Confirmed
The Pivot Confirmed method requires all six pivot points (start.  three drives , two retracements) to already be confirmed pivots before plotting. This is the most structural complete interpretation  but by nature introduces delay inherent in pivot confirmation. A confirmed pattern is rendered as a polyline connecting all six pivot points.[image]https://www.tradingview.com/x/zn1BewTY/[/image]
[*]Method 2 — Live Projection 
The Live Projection method is designed to identify the potential completion of a Three Drives pattern before the final drive is confirmed. 

Once the first five pivot points have been established, Trishul calculates the Fibonacci based  Projected Reversal Zone ( PRZ) for the anticipated third drive and projects that zone forward. Instead of waiting for a validated swing high/low on the current bar, the script actively scans forward bar-by-bar to identify the moment price first intersects the PRZ. This continuous, intra-bar scanning ensures the PRZ is never ignored or bypassed, capturing the earliest possible structural touch. The developing pattern is rendered as a bull/bear colored polyline with numbered drive labels (1, 2, 3) and a dashed projected-zone box.[image]https://www.tradingview.com/x/1u9ZeyIC/[/image]Unlike the Pivot Confirmed method, the Live Projection method does not require the third drive to subsequently become a confirmed pivot before the potential completion is identified. Both methods are plotted by default so users can compare and contrast their behavior, with the option to turn either one off.[image]https://www.tradingview.com/x/5dleATBX/[/image]
[*]Pattern Time–Price Symmetry
When in Live Projection, Trishul validates the Three Drives pattern using both price and time symmetry. It measures the bar width between Drive 1 and Drive 2 as a reference interval. To pass validation, the time elapsed between Drive 2 and Drive 3 must reach the projected reversal zone (PRZ) within a window of 0.5× to 2.628× that reference interval. Moves occurring too early lack structural development, while those taking too long break temporal symmetry and are rejected.[image]https://www.tradingview.com/x/uPqDzJGP/[/image]
[*]Pattern Age Filter  
A maximum pivot array size and configurable maximum pattern bar-width settings keep only structurally recent patterns on the chart rather than accumulating stale historical ones indefinitely.3. Future Development
Trishul is a demonstration of how a pivot-based architecture can be applied to automated pattern recognition. The underlying framework can be further expanded to identify or construct a variety of price structures including trend lines, channels and multi-leg patterns. Future planned development will extend the framework into harmonic pattern detection systems (Gartley, Butterfly, Bat, Crab, and others).

4. Default Settings
Pivot Point length:	                     5	
Retracement Ratio:	             0.5 - 0.886	
Extension Ratio:	                     1.13 - 1.618	
Tolerance:  0.9 - 1.1
3rd Drive Time Multiplier:            0.5 - 2.628
Max Pattern Bar Width:	             300 bars

日本語概要 (Japanese Summary)
Three Drives Pivot Scanner [Trishul] は、3つの連続する推進波（ドライブ）と2つの調整波（リトレースメント）からなる構造的な価格パターンを自動検出する高機能インジケーターです。各波動はフィボナッチ比率に基づいて厳格に評価され、パターンの完成時にトレンド転換の可能性が高い領域である Potential Reversal Zone (PRZ) を形成します。内蔵されたジグザグ機能とピボットポイントのアルゴリズムを用いることで、相場の重要な節目を正確に捉えながら、ユーザーの設定に合わせたピボット長や比率の柔軟なカスタマイズを可能にしています。

本スクリプトの最大の特徴は、アプローチの異なる2つの検出方法をリアルタイムに同時提供する点にあります。6つすべての構造ポイントが完全に確定してから綺麗なパターンを描写する保守的な「Pivot-Confirmed」と、最初の5つのポイントから最終レッグの到達点を先読みして価格がPRZに達した瞬間にリアルタイム検知する「Live Projection」を搭載しています。これにより、確定済みの信頼性を重視するトレーダーと、未確定の段階から一歩先んじて反転ゾーンを狙いたいトレーダーの両方のニーズに同時に応えるインジケーターとなっています。

中文概要（Chinese Summary）
Three Drives Pivot Scanner [Trishul] 是一款結構分析指標，能自動檢測由三個連續推進浪（Drive）與兩個修正浪（Retracement）所組成的結構性價格形態。各個波段皆依據斐波那契比率進行嚴格評估，並在第三個推進浪完成附近形成可能發生趨勢反轉的目標區域（Potential Reversal Zone, PRZ）。該指標內建 ZigZag 功能與轉折點（Pivot Points）演算法，能精確捕捉市場的關鍵拐點，同時允許用戶根據自身需求，靈活調整轉折點長度、回撤與擴展比率及容許誤差。                                                                                                                                         
	
本腳本的核心優勢在於同步提供兩種互補的偵測模式。保守的「Pivot-Confirmed」模式會等待所有六個結構點完全確認後，才在圖表上繪製出完整的形態，有效過濾虛假訊號；而「Live Projection」模式則在前面五個結構點成形時，便提前推算最終浪的落點，並在價格首次觸及 PRZ 預測分區的瞬間實時觸發告警。這項設計讓重視訊號確認的穩健型交易者，與傾向在形態完成前搶先佈局反轉點的左側交易者，都能兼顧各自的策略需求。

Disclaimer:
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

---

## Source Code

````pine
// Three Drives Pivot Scanner [Trishul]
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Part of the ET Massif Framework

//@version=6
indicator("Trishul", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=100)


// ─────────────────────────────────────────────
// Display
// ─────────────────────────────────────────────

showPivot3Drive = input.bool(true, "Show Pivot Point Confirmed Three Drives")
showThreeDrives = input.bool(true, "Detect Pivot Point Projected Three Drives")

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grpStructure = "Structural Pivot Settings"
blank = "⠀"
pivLen       = input.int(5, "Pivot Point Length", minval=2, maxval=15, step=1, tooltip="Adjust between 2 and 15 for macro structural tracking.")

// Three Drives thresholds
symmetry3DMin  = input.float(0.5, "Retracement", minval=0.382, maxval=0.886, step=0.05, group=grpStructure, inline="ret", tooltip="Expected depth of structural pullbacks")
symmetry3DMax  = input.float(0.886, "-", minval=0.5, maxval=1, step=0.05, group=grpStructure, inline="ret", tooltip="Expected depth of structural pullbacks")
extension3DMin  = input.float(1.13, "Extension⠀⠀", minval=1, maxval=2.5, step=0.1, group=grpStructure, inline="ext", tooltip="Extension ceiling for Drives 2 and 3")
extension3DMax  = input.float(1.618, "-", minval=1.5, maxval=3, step=0.1, group=grpStructure,inline="ext", tooltip="Extension ceiling for Drives 2 and 3")
toleranceMin  = input.float(0.9, "Tolerance⠀⠀", minval=0.75, maxval=1, step=0.05, group=grpStructure, inline="tol", tooltip="Deviation tolerance from defined ratio")
toleranceMax  = input.float(1.1, "-", minval=1, maxval=1.25, step=0.05, group=grpStructure,inline="tol",  tooltip="Deviation tolerance from defined ratio")
timesymmetryMin  = input.float(0.5, "3rd Drive Time Multiplier", minval=0.25, maxval=1, step=0.1, group=grpStructure, inline="d", tooltip="Duration based on the distance between Drive 1 and Drive 2")
timesymmetrMax  = input.float(2.628, "-", minval=1.1, maxval=3.5, step=0.1, group=grpStructure, inline="d",  tooltip="Duration based on the distance between Drive 1 and Drive 2")



// Pivot point look back
int searchDepth  = 6  // fixed do no not change

//Display settings
grpVis = "Aesthetics & Display"
colBull  = input.color(#00BCD4, "Projected Bullish Three Drives", group=grpVis)
colBear  = input.color(#E91E63, "Projected Bearish Three Drives", group=grpVis)
colBox   = input.color(color.new(#787b86, 92), "PRZ Range Box", group=grpVis)
colOpera  = input.color(#FCE205, "Confirmed Pivot Three Drives", group=grpVis)

// Maximum No of bars
int maxPatternAge = input.int(300, "Max Pattern Bar Width", group=grpStructure)

// ─────────────────────────────────────────────
// STRUCTURAL ZIGZAG MATRIX 
// ─────────────────────────────────────────────

//1. Initialize ZigZag type
type ZigZagPoint
    int   barIndex
    float price
    bool  isHigh

var ZigZagPoint[] zzHistory = array.new<ZigZagPoint>()


//2. Obtain back dated Pivot points
pHi = ta.pivothigh(high, pivLen, pivLen)
pLo = ta.pivotlow(low, pivLen, pivLen)

//3. Create Zig Zag Array
if not na(pHi)
    int pBar = bar_index - pivLen
    if array.size(zzHistory) > 0
        ZigZagPoint lastP = array.last(zzHistory)
        if lastP.isHigh
            if pHi > lastP.price
                lastP.price := pHi
                lastP.barIndex := pBar
        else
            array.push(zzHistory, ZigZagPoint.new(pBar, pHi, true))
    else
        array.push(zzHistory, ZigZagPoint.new(pBar, pHi, true))

if not na(pLo)
    int pBar = bar_index - pivLen
    if array.size(zzHistory) > 0
        ZigZagPoint lastP = array.last(zzHistory)
        if not lastP.isHigh
            if pLo < lastP.price
                lastP.price := pLo
                lastP.barIndex := pBar
        else
            array.push(zzHistory, ZigZagPoint.new(pBar, pLo, false))
    else
        array.push(zzHistory, ZigZagPoint.new(pBar, pLo, false))

if array.size(zzHistory) > 500
    array.shift(zzHistory)  // remove old pivots

// ─────────────────────────────────────────────
// PERSISTENT HISTORICAL PATTERN TRACKER
// ─────────────────────────────────────────────
var string[] confirmedPatterns = array.new<string>()
var int lastConfirmedXBar = -999



// ─────────────────────────────────────────────
// Method 1: PERSISTENT HISTORICAL PATTERN TRACKER
// ─────────────────────────────────────────────
var string[] confirmed3DPatterns = array.new<string>()

int sz = array.size(zzHistory)

// Ensure enough data points to evaluate a 6-point sequence
if array.size(zzHistory) >= 6 and showPivot3Drive 

    // Limit max search depth
    int maxSearch = math.min(sz - 6, searchDepth - 1)
    
    for offset = 0 to maxSearch
        int i = (sz - 1) - offset
    
        ZigZagPoint pDrive3   = array.get(zzHistory, i)     // The final PRZ target leg
        ZigZagPoint pRetract2 = array.get(zzHistory, i - 1)
        ZigZagPoint pDrive2   = array.get(zzHistory, i - 2)
        ZigZagPoint pRetract1 = array.get(zzHistory, i - 3)
        ZigZagPoint pDrive1   = array.get(zzHistory, i - 4)
        ZigZagPoint pStart    = array.get(zzHistory, i - 5) // Where the whole sequence began

        // Enforce pattern lifecycle window boundaries
        if (bar_index - pStart.barIndex) <= maxPatternAge
            
            // 1. Alternation Pattern Direction Checks
            bool isBearish3D = pDrive3.isHigh and not pRetract2.isHigh and pDrive2.isHigh and not pRetract1.isHigh and pDrive1.isHigh and not pStart.isHigh
            bool isBullish3D = not pDrive3.isHigh and pRetract2.isHigh and not pDrive2.isHigh and pRetract1.isHigh and not pDrive1.isHigh and pStart.isHigh
            
            // Generate unique historical fingerprint to avoid duplicate processing loops across ticks
            string pattern3DId = str.tostring(pStart.barIndex) + "_" + str.tostring(pDrive3.barIndex)
            
            if (isBearish3D or isBullish3D) and not array.includes(confirmed3DPatterns, pattern3DId)
                
                // 2. Structural Validation (Making sure highs are higher or lows are lower)
                bool structValid = false
                if isBearish3D
                    structValid := pDrive1.price > pStart.price and pDrive2.price > pDrive1.price and pDrive3.price > pDrive2.price and pRetract1.price > pStart.price and pRetract2.price > pRetract1.price
                else
                    structValid := pDrive1.price < pStart.price and pDrive2.price < pDrive1.price and pDrive3.price < pDrive2.price and pRetract1.price < pStart.price and pRetract2.price < pRetract1.price
                
                if structValid
                    // 3. Fibonacci Proportional Measurements
                    float move1 = math.abs(pDrive1.price - pStart.price)
                    float ret1  = math.abs(pDrive1.price - pRetract1.price) / move1
                    
                    float move2 = math.abs(pDrive2.price - pRetract1.price)
                    float ret2  = math.abs(pDrive2.price - pRetract2.price) / move2
                    
                    float ext1  = math.abs(pDrive2.price - pRetract1.price) / math.abs(pDrive1.price - pRetract1.price)
                    float ext2  = math.abs(pDrive3.price - pRetract2.price) / math.abs(pDrive2.price - pRetract2.price)
                    
                    // Allow classic harmonic tolerances around your inputs (typically 0.618 - 0.786 retracements)
                    bool ratiosValid = ret1 >= symmetry3DMin * toleranceMin and ret1 <= symmetry3DMax* toleranceMax and ret2 >= symmetry3DMin *toleranceMin and ret2 <= symmetry3DMax*toleranceMax and ext1 >= extension3DMin * toleranceMin and ext1 <= extension3DMax *toleranceMax and ext2 >= extension3DMin * toleranceMin  and ext2 <= extension3DMax*toleranceMax
                    
                    if ratiosValid
                        array.push(confirmed3DPatterns, pattern3DId)
                        color patternColor = isBearish3D ? colBear : colBull
                        
                        
                        // 4. Render Geometric Polyline
                        chart.point[] pts = array.new<chart.point>()
                        array.push(pts, chart.point.from_index(pStart.barIndex, pStart.price))
                        array.push(pts, chart.point.from_index(pDrive1.barIndex, pDrive1.price))
                        array.push(pts, chart.point.from_index(pRetract1.barIndex, pRetract1.price))
                        array.push(pts, chart.point.from_index(pDrive2.barIndex, pDrive2.price))
                        array.push(pts, chart.point.from_index(pRetract2.barIndex, pRetract2.price))
                        array.push(pts, chart.point.from_index(pDrive3.barIndex, pDrive3.price))
                        
                        if showPivot3Drive
                            polyline.new(points=pts, line_color=colOpera, line_width=1)  // optional
                        
            
                        // 6. Dynamic Potential Reversal Zone (PRZ) Target Box
                        // Calculated as the 1.272 to 1.618 harmonic extensions projected from the final retracement node
                        float przTop = isBearish3D ? pRetract2.price + (math.abs(pDrive2.price - pRetract2.price) * 1.618) : pRetract2.price - (math.abs(pDrive2.price - pRetract2.price) * 1.272)
                        float przBot = isBearish3D ? pRetract2.price + (math.abs(pDrive2.price - pRetract2.price) * 1.272) : pRetract2.price - (math.abs(pDrive2.price - pRetract2.price) * 1.618)
                        



// ─────────────────────────────────────────────
// Method 2: PERSISTENT LIVE-TOUCH PATTERN TRACKER
// ─────────────────────────────────────────────
var string[] confirmed3DTouchPatterns = array.new<string>()

// Ensure enough data points to evaluate a 5-point harmonic chassis
if array.size(zzHistory) >= 5 and showThreeDrives

    //int sz = array.size(zzHistory) -- already initialized
    // Limit max search depth
    int maxSearch = math.min(sz - 5, searchDepth - 1)

    
    for offset = 0 to maxSearch
        int i = (sz - 1) - offset
    
        // Pulling the 5 confirmed historical structural anchors
        ZigZagPoint pRetract2 = array.get(zzHistory, i)     // The launch pad for the live 3rd drive
        ZigZagPoint pDrive2   = array.get(zzHistory, i - 1)
        ZigZagPoint pRetract1 = array.get(zzHistory, i - 2)
        ZigZagPoint pDrive1   = array.get(zzHistory, i - 3)
        ZigZagPoint pStart    = array.get(zzHistory, i - 4) // Sequence root

        // Enforce pattern lifecycle window boundaries
        if (bar_index - pStart.barIndex) <= maxPatternAge
            
            // 1. Alternation Pattern Direction Checks
            bool isBearish3D = not pRetract2.isHigh and pDrive2.isHigh and not pRetract1.isHigh and pDrive1.isHigh and not pStart.isHigh
            bool isBullish3D = pRetract2.isHigh and not pDrive2.isHigh and pRetract1.isHigh and not pDrive1.isHigh and pStart.isHigh
            
            // Generate unique fingerprint based on the sequence root and the 2nd retracement anchor
            string pattern3DId = str.tostring(pStart.barIndex) + "_" + str.tostring(pRetract2.barIndex)
            
            if (isBearish3D or isBullish3D) and not array.includes(confirmed3DTouchPatterns, pattern3DId)
                
                // 2. Strict Structural Validation
                bool structValid = false
                if isBearish3D
                    structValid := pDrive1.price > pStart.price and pDrive2.price > pDrive1.price and pRetract1.price > pStart.price and pRetract2.price > pRetract1.price
                else
                    structValid := pDrive1.price < pStart.price and pDrive2.price < pDrive1.price and pRetract1.price < pStart.price and pRetract2.price < pRetract1.price
                
                if structValid
                    // 3. Fibonacci Proportional Measurements for Initial Tiers
                    float move1 = math.abs(pDrive1.price - pStart.price)
                    float ret1  = math.abs(pDrive1.price - pRetract1.price) / move1
                    
                    float move2 = math.abs(pDrive2.price - pRetract1.price)
                    float ret2  = math.abs(pDrive2.price - pRetract2.price) / move2
                    
                    float ext1  = math.abs(pDrive2.price - pRetract1.price) / math.abs(pDrive1.price - pRetract1.price)
                    
                    bool ratiosValid = ret1 >= symmetry3DMin * toleranceMin and ret1 <= symmetry3DMax * toleranceMax and 
                                       ret2 >= symmetry3DMin * toleranceMin and ret2 <= symmetry3DMax * toleranceMax and 
                                       ext1 >= extension3DMin * toleranceMin and ext1 <= extension3DMax * toleranceMax
                    
                    if ratiosValid
                        // 4. Mathematical PRZ Boundary Projections
                        float przTop = isBearish3D ? pRetract2.price + (math.abs(pDrive2.price - pRetract2.price) * extension3DMax * toleranceMax) : pRetract2.price - (math.abs(pDrive2.price - pRetract2.price) * extension3DMin * toleranceMin)
                        float przBot = isBearish3D ? pRetract2.price + (math.abs(pDrive2.price - pRetract2.price) * extension3DMin * toleranceMin) : pRetract2.price - (math.abs(pDrive2.price - pRetract2.price) * extension3DMax * toleranceMax)
                        
                        // 5. Symmetric Time Spacing (Measured cleanly between Drive 1 and Drive 2)
                        int baseWidth = pDrive2.barIndex - pDrive1.barIndex
                        int minTouchBar = pDrive2.barIndex + math.round(baseWidth * 0.5)
                        int maxTouchBar = pDrive2.barIndex + math.round(baseWidth * 2.628)
                        
                        // Scan forward from pRetract2 to isolate the first touch bar
                        int endScanBar = (i == sz - 1) ? bar_index : array.get(zzHistory, i + 1).barIndex
                        int touchBar = -1
                        float touchPrice = 0.0
                        
                        int scanStart = math.max(pRetract2.barIndex + 1, minTouchBar)
                        int scanEnd = math.min(endScanBar, maxTouchBar)
                        
                        if scanStart <= scanEnd
                            for b = scanStart to scanEnd
                                int barOffset = bar_index - b
                                if barOffset >= 0
                                    float checkHigh = high[barOffset]
                                    float checkLow  = low[barOffset]
                                    
                                    // True range intersection checks (Prevents overshoot omission)
                                    if isBearish3D and checkHigh >= przBot and checkLow <= przTop
                                        touchBar := b
                                        touchPrice := checkHigh
                                        break
                                    else if isBullish3D and checkLow <= przTop and checkHigh >= przBot
                                        touchBar := b
                                        touchPrice := checkLow
                                        break
                        
                        // If an authentic touch point was registered within the structural parameters, execute rendering
                        if touchBar != -1
                            array.push(confirmed3DTouchPatterns, pattern3DId)
                            color patternColor = isBearish3D ? colBear : colBull
                            //countthreeDrives += 1
                            
                            // 6. Render Geometric Polyline to the Touch Coordinate
                            chart.point[] pts = array.new<chart.point>()
                            array.push(pts, chart.point.from_index(pStart.barIndex, pStart.price))
                            array.push(pts, chart.point.from_index(pDrive1.barIndex, pDrive1.price))
                            array.push(pts, chart.point.from_index(pRetract1.barIndex, pRetract1.price))
                            array.push(pts, chart.point.from_index(pDrive2.barIndex, pDrive2.price))
                            array.push(pts, chart.point.from_index(pRetract2.barIndex, pRetract2.price))
                            array.push(pts, chart.point.from_index(touchBar, touchPrice))
                            
                            polyline.new(points=pts, line_color=patternColor, line_width=1)
                            
                            // 7. Render Execution Labels
                            label.new(chart.point.from_index(pDrive1.barIndex, pDrive1.price), text="1", color=patternColor, textcolor=color.white, style=isBearish3D ? label.style_label_down : label.style_label_up)
                            label.new(chart.point.from_index(pDrive2.barIndex, pDrive2.price), text="2", color=patternColor, textcolor=color.white, style=isBearish3D ? label.style_label_down : label.style_label_up)
                            label.new(chart.point.from_index(touchBar, touchPrice), text="3", color=patternColor, textcolor=color.white, style=isBearish3D ? label.style_label_down : label.style_label_up)
                            
                            // 8. Projection Box anchoring from the touch instance forward to current execution state
                            box.new(left=touchBar, top=przTop, right=bar_index, bottom=przBot, bgcolor=colBox, border_color=patternColor, border_style=line.style_dashed)
````
