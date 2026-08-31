<!-- tradingview-pine-id: PUB;5cfdfdad16d34145a2126a035b16c049 -->
<!-- tradingviewscripts-format: 1 -->
# Bias

Source: https://www.tradingview.com/script/Kkgksf6l-MSNR-Bias-HTF/

## Description

AKFX Storyline Alignment Dashboard (Multi-Timeframe Analysis)
The AKFX Storyline Alignment Dashboard is a multi-timeframe analysis tool designed to help traders quickly determine market bias and alignment across higher and lower timeframes using the concept of Market Storylines.

Instead of trading off single-timeframe signals, this indicator evaluates structural price action on higher timeframes (HTF) and confirms directional continuation via line-chart breakouts on the lower timeframe (LTF).

🟢 How the Storyline Logic Works
A Storyline is defined as the price movement initiated when price interacts with a higher timeframe zone and receives confirmation from the timeframe directly below it.

Weekly Storyline (Macro Bias):

Checks if Current Market Price (CMP) is reacting at a Weekly Support or Resistance zone.

Confirmed when a Daily line-chart breakout occurs (a Daily candle body closes past the local Daily swing high/low).

Daily Storyline (Intermediate Bias):

Checks if CMP is reacting at a Daily Support or Resistance zone.

Confirmed when a 4-Hour (H4) line-chart breakout occurs (an H4 candle body closes past the local H4 swing high/low).

Bias Alignment Status:

ALIGNED (BULLISH 🟢): Both Weekly and Daily storylines are confirmed Bullish. High-probability environment to look for Buy setups.

ALIGNED (BEARISH 🔴): Both Weekly and Daily storylines are confirmed Bearish. High-probability environment to look for Sell setups.

CONFLICTED 🔴: Weekly and Daily storylines point in opposite directions. Exercise caution or wait for alignment.

WAITING FOR SETUP ⚪: One or both storylines are in a neutral/unconfirmed state.

🎨 Key Customization Features
Customizable Dashboard Colors: Configure background fill, text, border, and header colors via the indicator settings.

Default High-Contrast Theme: Pre-styled with a dark gray fill, crisp black text, and a solid black border for maximum readability on any chart background.

Optional Status Highlighting: Includes a toggle (Use Green/Red Status Colors instead of Solid Gray) to instantly highlight alignment with green/red status boxes.

💡 How to Use in Your Trading Strategy
Add the dashboard to your preferred asset (Forex, Crypto, Indices, Stocks).

Check the Bias Alignment Status row:

When ALIGNED: Look for pullback entries at fresh Support/Resistance zones on your execution timeframe (e.g., H1 or 15m) in the direction of the alignment.

When CONFLICTED or WAITING: Sit on your hands or restrict trades to quick scalps, as higher timeframe momentum is divided.

---

## Source Code

````pine
//@version=6
indicator('Bias', overlay = true)

// ==========================================
// 1. COLOR & DASHBOARD INPUTS
// ==========================================
var string G_STORY = 'Table Styling Options'
col_bg = input.color(color.rgb(200, 200, 200), 'Box Background Color', group = G_STORY)
col_text = input.color(color.black, 'Text Color', group = G_STORY)
col_border = input.color(color.black, 'Border Color', group = G_STORY)
col_header = input.color(color.rgb(150, 150, 150), 'Header Color', group = G_STORY)

// Dynamic status colors (Used when color coding status)
use_status_colors = input.bool(false, 'Use Green/Red Status Colors instead of Solid Gray', group = G_STORY)

// ==========================================
// 2. HELPER FUNCTION: LINE CHART BREAKOUT LOGIC
// ==========================================
f_get_storyline(tf_htf, tf_ltf) =>
    htf_close = request.security(syminfo.tickerid, tf_htf, close[1])
    htf_high = request.security(syminfo.tickerid, tf_htf, high[2])
    htf_low = request.security(syminfo.tickerid, tf_htf, low[2])

    ltf_close = request.security(syminfo.tickerid, tf_ltf, close)
    ltf_last_high = request.security(syminfo.tickerid, tf_ltf, ta.highest(close, 5)[1])
    ltf_last_low = request.security(syminfo.tickerid, tf_ltf, ta.lowest(close, 5)[1])

    ltf_bull_break = ta.crossover(ltf_close, ltf_last_high)
    ltf_bear_break = ta.crossunder(ltf_close, ltf_last_low)

    var string storyline = 'NEUTRAL'
    if ltf_bull_break
        storyline := 'BULLISH'
        storyline
    else if ltf_bear_break
        storyline := 'BEARISH'
        storyline

    storyline

// ==========================================
// 3. CALCULATE STORYLINES & ALIGNMENT
// ==========================================
weekly_storyline = f_get_storyline('W', 'D')
daily_storyline = f_get_storyline('D', '240')

string bias_alignment = 'NEUTRAL'
if weekly_storyline == 'BULLISH' and daily_storyline == 'BULLISH'
    bias_alignment := 'ALIGNED (BULLISH 🟢)'
    bias_alignment
else if weekly_storyline == 'BEARISH' and daily_storyline == 'BEARISH'
    bias_alignment := 'ALIGNED (BEARISH 🔴)'
    bias_alignment
else if weekly_storyline == 'BULLISH' and daily_storyline == 'BEARISH' or weekly_storyline == 'BEARISH' and daily_storyline == 'BULLISH'
    bias_alignment := 'CONFLICTED 🔴'
    bias_alignment
else
    bias_alignment := 'WAITING FOR SETUP ⚪'
    bias_alignment

// ==========================================
// 4. DRAW DASHBOARD TABLE (GRAY FILL / BLACK TEXT & BORDER)
// ==========================================
var table dashboard = table.new(position = position.top_right, columns = 2, rows = 3, bgcolor = col_border, border_width = 2, border_color = col_border)

if barstate.islast
    // Resolve background colors based on settings
    color bg_w = use_status_colors ? weekly_storyline == 'BULLISH' ? color.green : weekly_storyline == 'BEARISH' ? color.red : col_bg : col_bg
    color bg_d = use_status_colors ? daily_storyline == 'BULLISH' ? color.green : daily_storyline == 'BEARISH' ? color.red : col_bg : col_bg
    color bg_b = use_status_colors ? str.contains(bias_alignment, 'ALIGNED') ? color.green : str.contains(bias_alignment, 'CONFLICTED') ? color.red : col_bg : col_bg

    // Row 1: Weekly Storyline
    table.cell(dashboard, 0, 0, 'Weekly Storyline', text_color = col_text, bgcolor = col_header)
    table.cell(dashboard, 1, 0, weekly_storyline, text_color = col_text, bgcolor = bg_w)

    // Row 2: Daily Storyline
    table.cell(dashboard, 0, 1, 'Daily Storyline', text_color = col_text, bgcolor = col_header)
    table.cell(dashboard, 1, 1, daily_storyline, text_color = col_text, bgcolor = bg_d)

    // Row 3: Bias Alignment
    table.cell(dashboard, 0, 2, 'Aligned?', text_color = col_text, bgcolor = col_header)
    table.cell(dashboard, 1, 2, bias_alignment, text_color = col_text, bgcolor = bg_b)
````
