# Hao_Gann Swing

- url: https://www.tradingview.com/script/KcqMYLuI-Hao-Gann-Swing/
- type: indicator
- pine_id: PUB;71f97607d578475693298265ab1f2eb0
- version: 1.0

## Description

This indicator is a custom dynamic swing structure tool built entirely on price action.

Key features:

• No use of candle color, indicators, or fixed fractals  
• Swing detection is based only on High/Low relationships between candles  
• Inside bars (fully contained candles) are ignored to reduce noise  

Structure logic:

• In an uptrend:
  - Higher highs extend the current swing high
  - A downside break creates a new swing low
  - If a strong outside bar breaks both sides and also breaks the previous swing low:
    → the current swing high is shifted to the new candle
    → a new swing low is formed immediately

• In a downtrend:
  - Lower lows extend the current swing low
  - An upside break creates a new swing high
  - If a strong outside bar breaks both sides and also breaks the previous swing high:
    → the current swing low is shifted to the new candle
    → a new swing high is formed immediately

Additional behavior:

• Outside bars do NOT automatically create reversals  
• Swings are updated (shifted) instead of duplicated  
• The structure remains continuous and smooth (no broken lines)

This approach closely mimics how experienced traders manually interpret market structure, making it suitable for price action analysis and advanced strategy development.

## Source Code

````pine
//@version=5
indicator("Ultimate Swing FIXED (Chuẩn cuối cùng)", overlay=true)

// ===== STATE =====
var float anchorHigh = na
var float anchorLow  = na

var float lastPrice = na
var int lastIndex = na
var int lastType = 0   // 1 = high, -1 = low

var float lastSwingLow = na
var float lastSwingHigh = na

var line currentLine = na

// ===== INIT =====
if na(anchorHigh)
    anchorHigh := high
    anchorLow  := low

// ===== BAR TYPE =====
inside  = high <= anchorHigh and low >= anchorLow
outside = high > anchorHigh and low < anchorLow

// ===== MAIN =====
if not inside

    strongBreakUp   = outside and not na(lastSwingLow) and low < lastSwingLow
    strongBreakDown = outside and not na(lastSwingHigh) and high > lastSwingHigh

    // ===== SÓNG TĂNG BỊ PHÁ MẠNH =====
    if lastType == 1 and strongBreakUp

        // 🔥 DỜI SWING HIGH (KHÔNG TẠO MỚI)
        lastSwingHigh := high
        lastPrice := high
        lastIndex := bar_index

        if not na(currentLine)
            line.set_xy2(currentLine, bar_index, high)

        // 🔥 TẠO SWING LOW MỚI
        currentLine := line.new(bar_index, high, bar_index, low, width=2)

        lastSwingLow := low
        lastPrice := low
        lastIndex := bar_index
        lastType := -1

        anchorHigh := high
        anchorLow  := low

    // ===== SÓNG GIẢM BỊ PHÁ MẠNH =====
    else if lastType == -1 and strongBreakDown

        // 🔥 DỜI SWING LOW (KHÔNG TẠO MỚI)
        lastSwingLow := low
        lastPrice := low
        lastIndex := bar_index

        if not na(currentLine)
            line.set_xy2(currentLine, bar_index, low)

        // 🔥 TẠO SWING HIGH MỚI
        currentLine := line.new(bar_index, low, bar_index, high, width=2)

        lastSwingHigh := high
        lastPrice := high
        lastIndex := bar_index
        lastType := 1

        anchorHigh := high
        anchorLow  := low

    // ===== OUTSIDE BAR THƯỜNG =====
    else if outside
        if lastType == 1
            lastPrice := high
            lastIndex := bar_index
            if not na(currentLine)
                line.set_xy2(currentLine, bar_index, high)

        if lastType == -1
            lastPrice := low
            lastIndex := bar_index
            if not na(currentLine)
                line.set_xy2(currentLine, bar_index, low)

        anchorHigh := high
        anchorLow  := low

    // ===== BREAK UP =====
    else if high > anchorHigh
        if lastType != 1
            if not na(lastPrice)
                currentLine := line.new(lastIndex, lastPrice, bar_index, high, width=2)

            lastPrice := high
            lastIndex := bar_index
            lastType := 1
        else
            lastPrice := high
            lastIndex := bar_index
            if not na(currentLine)
                line.set_xy2(currentLine, bar_index, high)

        lastSwingHigh := high
        anchorHigh := high
        anchorLow  := low

    // ===== BREAK DOWN =====
    else if low < anchorLow
        if lastType != -1
            if not na(lastPrice)
                currentLine := line.new(lastIndex, lastPrice, bar_index, low, width=2)

            lastPrice := low
            lastIndex := bar_index
            lastType := -1
        else
            lastPrice := low
            lastIndex := bar_index
            if not na(currentLine)
                line.set_xy2(currentLine, bar_index, low)

        lastSwingLow := low
        anchorHigh := high
        anchorLow  := low
````
