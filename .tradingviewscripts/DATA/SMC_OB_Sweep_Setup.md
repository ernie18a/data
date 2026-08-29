<!-- tradingview-pine-id: PUB;4c70f469372e4e81aed0bff745882008 -->
<!-- tradingviewscripts-format: 1 -->
# SMC OB & Sweep Setup

Source: https://www.tradingview.com/script/NYrFIfKP/

## Description

PolarLabs - SMC OB & Sweep Setup

SMC OB & Sweep Setup is a price-action indicator built around Smart Money Concepts (SMC). It looks for potential trade setups by combining liquidity sweeps, market structure breaks, Fair Value Gaps (FVGs), and Order Blocks (OBs).

The script follows a confirmation-based process:

1. Liquidity Sweep
It detects when price sweeps a previous swing high or swing low, then rejects back inside the level with a meaningful wick. This may indicate a potential liquidity grab.

2. Market Structure Confirmation
After a sweep, the indicator waits for price to break the opposing swing structure:
• Bearish setup: sweep above a swing high, followed by a bearish break of structure.
• Bullish setup: sweep below a swing low, followed by a bullish break of structure.

3. Fair Value Gap Filter
A valid setup also requires a Fair Value Gap to be present during the confirmation move, helping filter for stronger displacement.

4. Order Block and Risk Levels
Once confirmed, the script draws:
• The Order Block zone
• The Break of Structure (BOS) level
• Suggested Stop Loss level
• Take Profit 1 at 1:1 risk-to-reward
• Take Profit 2 at 1:2 risk-to-reward

Risk buffers can be calculated using either:
• ATR-based buffer — adapts to current market volatility
• Order Block range percentage — uses the size of the detected Order Block

How to read the chart:
• “Sweep” label: price has taken liquidity above/below a previous swing point and rejected.
• “BOS” label: market structure has been broken and the setup is confirmed.
• Red Order Block: potential bearish zone.
• Green Order Block: potential bullish zone.
• Red dotted line: Stop Loss.
• Green dotted line: TP1 (1R).
• Blue dotted line: TP2 (2R).

Important:
This indicator is designed to highlight potential SMC-based setups, not to guarantee profitable trades. Market structure, liquidity concepts, and Fair Value Gaps are interpreted algorithmically and may not match every trader’s discretionary definition. Always confirm setups with your own analysis and apply proper risk management.

Feedback, suggestions, and improvement ideas are welcome!

---

## Source Code

````pine
//@version=6
indicator('SMC OB & Sweep Setup', overlay = true, max_boxes_count = 50, max_lines_count = 50, max_labels_count = 50)

// ==========================================
// 1. 使用者輸入參數 (Inputs)
// ==========================================
// 結構參數
leftBars = input.int(5, title = 'Pivot 左側 K 線數', group = '市場結構 (Market Structure)')
rightBars = input.int(5, title = 'Pivot 右側 K 線數', group = '市場結構 (Market Structure)')

// 掠奪參數
wick_ratio_threshold = input.float(0.4, title = '影線比例閾值 (0.0~1.0)', step = 0.05, group = '流動性掠奪 (Liquidity Sweep)')

// 風險管理參數
buffer_mode = input.string('ATR 模式', title = 'Buffer 計算模式', options = ['ATR 模式', 'OB 比例模式'], group = '風險管理 (Risk Management)')
atr_length = input.int(14, title = 'ATR 長度', group = '風險管理 (Risk Management)')
atr_multiplier = input.float(0.2, title = 'ATR 乘數', step = 0.1, group = '風險管理 (Risk Management)')
ob_range_pct = input.float(0.15, title = 'OB 比例乘數', step = 0.05, group = '風險管理 (Risk Management)')

// ==========================================
// 2. 基礎結構定義 (Swing High / Swing Low)
// ==========================================
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float swing_high = na
var float swing_low = na

if not na(ph)
    swing_high := ph
    swing_high
if not na(pl)
    swing_low := pl
    swing_low

// ==========================================
// 3. 核心函數定義 (Functions)
// ==========================================
// 計算單根 K 線的總長度
getRange() =>
    high - low

// 判斷看跌掠奪 (掃蕩前高 BSL)
isBearishSweep(sh) =>
    penetration = high > sh
    rejection = close <= sh
    upper_wick = high - math.max(open, close)
    wick_ratio = getRange() > 0 ? upper_wick / getRange() : 0
    penetration and rejection and wick_ratio >= wick_ratio_threshold

// 判斷看漲掠奪 (掃蕩前低 SSL)
isBullishSweep(sl) =>
    penetration = low < sl
    rejection = close >= sl
    lower_wick = math.min(open, close) - low
    wick_ratio = getRange() > 0 ? lower_wick / getRange() : 0
    penetration and rejection and wick_ratio >= wick_ratio_threshold

// 判斷 FVG
hasBearishFVG() =>
    high < low[2]
hasBullishFVG() =>
    low > high[2]

// ==========================================
// 4. 狀態機變數定義 (State Machine Variables)
// ==========================================
// 狀態: 0 = 無, 1 = 等待確認 (Awaiting Confirmation)
var int bear_state = 0
var float bear_ob_top = na
var float bear_ob_bot = na
var float bear_target_bos = na

var int bull_state = 0
var float bull_ob_top = na
var float bull_ob_bot = na
var float bull_target_bos = na

// ==========================================
// 5. 主邏輯 (Main Logic)
// ==========================================
current_atr = ta.atr(atr_length)

// ------------------------------------------
// 看跌 OB 狀態機 (Bearish Setup)
// ------------------------------------------
// 狀態 1: 觸發掠奪
if bear_state == 0 and not na(swing_high) and isBearishSweep(swing_high)
    bear_state := 1
    bear_ob_top := high
    bear_ob_bot := math.min(open, close)
    bear_target_bos := swing_low
    label.new(bar_index, high, 'Sweep', color = color.new(color.red, 50), style = label.style_label_down, textcolor = color.white, size = size.small)

// 狀態 2: 等待確認
else if bear_state == 1
    // 失效條件
    if close > bear_ob_top
        bear_state := 0
        bear_state
    // 確認條件 (向下 BOS 且包含 FVG)
    else if close < bear_target_bos and hasBearishFVG()
        // 計算 Buffer
        buffer = buffer_mode == 'ATR 模式' ? current_atr * atr_multiplier : (bear_ob_top - bear_ob_bot) * ob_range_pct

        // 計算點位
        entry_price = bear_ob_bot
        sl_price = bear_ob_top + buffer
        risk = sl_price - entry_price
        tp1_price = entry_price - risk // 1:1 RR
        tp2_price = entry_price - risk * 2 // 1:2 RR

        // 繪製 OB Box
        box.new(bar_index[1], bear_ob_top, bar_index + 5, bear_ob_bot, border_color = color.new(color.red, 0), bgcolor = color.new(color.red, 80))

        // 繪製 BOS 線
        line.new(bar_index[5], bear_target_bos, bar_index, bear_target_bos, color = color.red, style = line.style_dashed)
        label.new(bar_index, bear_target_bos, 'BOS', color = color.new(color.red, 100), textcolor = color.red, style = label.style_none, size = size.small)

        // 繪製 SL / TP 線
        line.new(bar_index, sl_price, bar_index + 5, sl_price, color = color.red, style = line.style_dotted)
        line.new(bar_index, tp1_price, bar_index + 5, tp1_price, color = color.green, style = line.style_dotted)
        line.new(bar_index, tp2_price, bar_index + 5, tp2_price, color = color.blue, style = line.style_dotted)

        // 重置狀態
        bear_state := 0
        bear_state

// ------------------------------------------
// 看漲 OB 狀態機 (Bullish Setup)
// ------------------------------------------
// 狀態 1: 觸發掠奪
if bull_state == 0 and not na(swing_low) and isBullishSweep(swing_low)
    bull_state := 1
    bull_ob_bot := low
    bull_ob_top := math.max(open, close)
    bull_target_bos := swing_high
    label.new(bar_index, low, 'Sweep', color = color.new(color.green, 50), style = label.style_label_up, textcolor = color.white, size = size.small)

// 狀態 2: 等待確認
else if bull_state == 1
    // 失效條件
    if close < bull_ob_bot
        bull_state := 0
        bull_state
    // 確認條件 (向上 BOS 且包含 FVG)
    else if close > bull_target_bos and hasBullishFVG()
        // 計算 Buffer
        buffer = buffer_mode == 'ATR 模式' ? current_atr * atr_multiplier : (bull_ob_top - bull_ob_bot) * ob_range_pct

        // 計算點位
        entry_price = bull_ob_top
        sl_price = bull_ob_bot - buffer
        risk = entry_price - sl_price
        tp1_price = entry_price + risk // 1:1 RR
        tp2_price = entry_price + risk * 2 // 1:2 RR

        // 繪製 OB Box
        box.new(bar_index[1], bull_ob_top, bar_index + 5, bull_ob_bot, border_color = color.new(color.green, 0), bgcolor = color.new(color.green, 80))

        // 繪製 BOS 線
        line.new(bar_index[5], bull_target_bos, bar_index, bull_target_bos, color = color.green, style = line.style_dashed)
        label.new(bar_index, bull_target_bos, 'BOS', color = color.new(color.green, 100), textcolor = color.green, style = label.style_none, size = size.small)

        // 繪製 SL / TP 線
        line.new(bar_index, sl_price, bar_index + 5, sl_price, color = color.red, style = line.style_dotted)
        line.new(bar_index, tp1_price, bar_index + 5, tp1_price, color = color.green, style = line.style_dotted)
        line.new(bar_index, tp2_price, bar_index + 5, tp2_price, color = color.blue, style = line.style_dotted)

        // 重置狀態
        bull_state := 0
        bull_state
````
