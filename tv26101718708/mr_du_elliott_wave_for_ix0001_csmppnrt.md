# MR DU Elliott Wave FOR IX0001

- url: https://www.tradingview.com/script/cSmpPNRT-MR-DU-Elliott-Wave-FOR-IX0001/
- type: indicator
- pine_id: PUB;8d156300b79845c98795d499daa6aa96
- version: 1.0

## Description

Curtis, here's the English translation:

🌊 Complete Elliott Wave Structure Breakdown for Taiwan Stock Market (Figure 3-167)
Starting Point: Beginning of the 8th Major Stock Market Cycle
Key LevelDate (ROC Calendar)Description3,955.43 (Cycle Low)Nov 21, 2008 (ROC 97)Previous cycle trough; declined 5,904 points / -59.88%22,975.71 (Opening)Jan 2, 2025 (ROC 114)Observation starting point for this cycle
Wave I (Initial Advance)

Start: 17,306.97 (Apr 9, 2025 — tariff-shock low)
High: 28,594.61 (Nov 4, 2025)
Gain: +11,787.19 points (+68.16%)

Wave II (Corrective Wave)

Multiple minor pullbacks within the correction zone:

25,469.04 (Sep 26, 2025): down 924.99 pts / -3.50%
26,395.98 (Nov 21, 2025): down 2,158.63 pts / -7.56%
27,350.77 (Dec 28, 2025): down 1,217.25 pts / -4.26%


Although consolidation lasted roughly 5 months, the magnitude remained moderate.

Wave III (Main Advance) — Current Position
MilestoneDateLevelCumulative GainWave III startApr 9, 202517,306.97—Wave I highNov 4, 202528,594.61+65.22%Wave II highJan 29, 202632,090.07+85.4%Wave III peakFeb 26, 202635,579.34+105.58%Pullback lowMar 9, 202631,529.36Down 4,049.98 pts / -11.38%V-shaped new highApr 16, 202637,135.55+114.57%Closing priceApr 16, 202637,132.02YTD +28.02%
Wave III has now lasted 13 months, consistent with Teacher Du's original forecast of "April 2025 to April 2026, totaling 13 months."
📐 Fibonacci Target Price Calculations
Teacher Du provided two methods for calculating target levels:

1.618× target zone:
11,787 × 1.618 + 17,096 ≈ 36,378 points (already reached during the initial advance)
2.0× target zone:
11,787 × 2.0 + 17,306 ≈ 40,880 points (maximum extension target for the main advance)

Assessment: The main advance could end around 36,378 (already surpassed). If it extends further, the upper limit is approximately 40,880. At 37,135, the index has already exceeded the 1.618× target, meaning the main advance may conclude at any time, transitioning into the Wave IV correction.
Wave IV (Corrective Phase) — Approaching

Pattern: A 5-month sideways a-b-c-x-a-b-c-x box-range consolidation ("correction through time rather than price")
Estimated low: approximately 31,000 points (-16.5% from 37,135)
Expected bottom: before the October 2026 local elections
Strategic implication: Do not chase rallies in Q2/Q3 2026; wait patiently for the pullback.

Wave V (Final Advance) — Launching October 2026

Rally starting point: approximately 31,000 points
Price target: 43,000 points by May 2027
Volume: combined TWSE + OTC turnover expected to expand to NT$2.4 trillion
TSMC target price: NT$2,400

## Source Code

````pine
//@version=5
indicator("杜金龍 Elliott Wave 台股預測", shorttitle="杜金龍 Elliott", overlay=true,
          max_labels_count=50, max_lines_count=20, max_boxes_count=5)

// ════════════ 顯示設定 ════════════
show_labels = input.bool(true,  "波浪轉折標籤",       group="顯示設定")
show_fibs   = input.bool(true,  "費波南希目標線",      group="顯示設定")
show_proj   = input.bool(true,  "IV→V 預測路徑",      group="顯示設定")
show_zone   = input.bool(true,  "IV 波整理區間",       group="顯示設定")

// ════════════ Elliott Wave 關鍵點位 ════════════
// 已發生
float W1_START = 17306.97  // ① 起點   2025/04/09 關稅股災低點
float W1_HIGH  = 28594.61  // ① 高點   2025/11/04  +68.16%
float W3_PEAK  = 35579.34  // ③ 主高   2026/02/26  +105.58%
float W3_DIP   = 31529.36  // ③ 回檔   2026/03/09  -11.38%
float W3_HIGH  = 37135.55  // ③ V型高  2026/04/16  +114.57% ⚠️
// 預測
float W4_LOW   = 31000.00  // ④ 估低   2026/10 前（縣市長選舉前）
float W5_TGT   = 43000.00  // ⑤ 目標   2027/05（含 OTC 量 2.4兆）

// ════════════ 費波南希滿足點 ════════════
// 初升段 11,787 點 × 倍數 + 起漲點
float FIB_1618 = 36378.0   // 1.618× ✅ 已達（主升段可能結束）
float FIB_2000 = 40880.0   // 2.000× 主升段最大延伸
float FIB_2382 = 41225.0   // 2.382× 積極滿足
float FIB_2500 = 43267.0   // 2.500× V波末升段目標 2027/5
float FIB_2618 = 45310.0   // 2.618× 終極滿足區

// ════════════ 費波南希水平線（plot 支援開關）════════════
plot(show_fibs ? W1_START  : na, "①起點 17,307",          color=color.new(color.gray,   60), linewidth=1)
plot(show_fibs ? W4_LOW    : na, "④目標 31,000",           color=color.new(color.blue,   10), linewidth=1)
plot(show_fibs ? FIB_1618  : na, "1.618× 36,378 ✅",       color=color.new(color.orange,  0), linewidth=1)
plot(show_fibs ? FIB_2000  : na, "2.000× 40,880 主升極限", color=color.new(color.red,     0), linewidth=2)
plot(show_fibs ? FIB_2382  : na, "2.382× 41,225",          color=color.new(color.purple, 20), linewidth=1)
plot(show_fibs ? FIB_2500  : na, "2.500× 43,267 V波目標",  color=color.new(color.green,   0), linewidth=2)
plot(show_fibs ? FIB_2618  : na, "2.618× 45,310 終極",     color=color.new(color.teal,   30), linewidth=1)

// ════════════ 波浪轉折標籤 ════════════
// 只在目標日期第一根K線觸發
f_cross(y, m, d) =>
    int t = timestamp(y, m, d, 0, 0)
    time >= t and time[1] < t

if show_labels
    if f_cross(2025, 4, 9)
        label.new(bar_index, W1_START,
             "① 波起點\n17,307\n2025/4/9",
             style=label.style_label_up,
             color=color.new(color.navy, 0),
             textcolor=color.white, size=size.small)

    if f_cross(2025, 11, 4)
        label.new(bar_index, W1_HIGH,
             "① 波高點\n28,595\n+68.16%\n2025/11/4",
             style=label.style_label_down,
             color=color.new(color.navy, 0),
             textcolor=color.white, size=size.small)

    if f_cross(2026, 2, 26)
        label.new(bar_index, W3_PEAK,
             "③ 主高點\n35,579\n+105.58%\n2026/2/26",
             style=label.style_label_down,
             color=color.new(color.maroon, 0),
             textcolor=color.white, size=size.small)

    if f_cross(2026, 3, 9)
        label.new(bar_index, W3_DIP,
             "③ 回檔低\n31,529\n-11.38%\n2026/3/9",
             style=label.style_label_up,
             color=color.new(color.orange, 0),
             textcolor=color.white, size=size.small)

    if f_cross(2026, 4, 16)
        label.new(bar_index, W3_HIGH,
             "③ 滿足期 ⚠️\n37,136\n+114.57%\n主升段已達\n2026/4/16",
             style=label.style_label_down,
             color=color.new(color.red, 0),
             textcolor=color.white, size=size.normal)

// ════════════ 預測路徑 & IV波整理區間（最後一根K更新）════════════
var line  proj_dn = na
var line  proj_up = na
var label lbl_iv  = na
var label lbl_v   = na
var box   iv_box  = na

if barstate.islast
    // 日K估算：6個月≈130根，13個月≈285根
    int bars_iv = 130
    int bars_v  = 285

    // IV 波下跌 → V 波上漲預測線
    if show_proj
        line.delete(proj_dn)
        line.delete(proj_up)
        proj_dn := line.new(
             x1=bar_index,           y1=W3_HIGH,
             x2=bar_index + bars_iv, y2=W4_LOW,
             color=color.new(color.red, 20),
             style=line.style_dashed, width=2)
        proj_up := line.new(
             x1=bar_index + bars_iv, y1=W4_LOW,
             x2=bar_index + bars_v,  y2=W5_TGT,
             color=color.new(color.green, 20),
             style=line.style_dashed, width=2)

    // 未來轉折點標籤
    if show_proj or show_zone
        label.delete(lbl_iv)
        label.delete(lbl_v)
        lbl_iv := label.new(bar_index + bars_iv, W4_LOW,
             "④ 預估低點\n~31,000\n2026/10 前\n縣市長選舉",
             style=label.style_label_up,
             color=color.new(color.blue, 0),
             textcolor=color.white, size=size.small)
        lbl_v := label.new(bar_index + bars_v, W5_TGT,
             "⑤ 末升段目標\n43,000 點\n2027/5\n台積電 2,400",
             style=label.style_label_down,
             color=color.new(color.green, 0),
             textcolor=color.white, size=size.normal)

    // IV 波整理區間
    if show_zone
        box.delete(iv_box)
        iv_box := box.new(
             left=bar_index,           right=bar_index + bars_iv,
             top=W3_HIGH,              bottom=W4_LOW,
             bgcolor=color.new(color.blue, 88),
             border_color=color.new(color.blue, 40), border_width=1,
             text="④ 波 a-b-c-x-a-b-c-x 箱型整理\n不追高，等 31,000 布局 V 波",
             text_color=color.new(color.blue, 0),
             text_size=size.small,
             text_valign=text.align_top,
             text_halign=text.align_left)
````
