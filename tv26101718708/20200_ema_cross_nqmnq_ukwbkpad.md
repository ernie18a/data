# 20/200 EMA Cross [NQ/MNQ]

- url: https://www.tradingview.com/script/UKwbKPAd-20-200-EMA-Cross-NQ-MNQ/
- type: indicator
- pine_id: PUB;62cd950f04bb4931b6187811b6b90208
- version: 1.0

## Description

Signals:

▲ BUY label — fires when the 20 EMA crosses above the 200 EMA (golden cross)
▼ SELL label — fires when the 20 EMA crosses below the 200 EMA (death cross)

Visual:

Green background while 20 EMA is above 200 EMA (bullish bias)
Red background while 20 EMA is below 200 EMA (bearish bias)
Both EMA lines plotted — gold for the 20, blue for the 200

Alerts:

Separate alerts for bull cross, bear cross, and any cross
All three are available when you set up alerts in TradingView

Settings you can adjust:

EMA lengths (default 20/200)
All colors
Background opacity
Toggle EMA lines on/off

## Source Code

````pine
//@version=6
indicator("20/200 EMA Cross [NQ/MNQ]", overlay=true)

// ═══════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════
grp1 = "EMA Settings"
fast_len  = input.int(20,  "Fast EMA Length", minval=1, group=grp1)
slow_len  = input.int(200, "Slow EMA Length", minval=1, group=grp1)

grp2 = "Display"
bull_col  = input.color(color.new(#00E676, 0),  "Bullish Color", group=grp2)
bear_col  = input.color(color.new(#FF1744, 0),  "Bearish Color", group=grp2)
ema_fast_col = input.color(color.new(#FFD700, 0), "Fast EMA Color", group=grp2)
ema_slow_col = input.color(color.new(#2962FF, 0), "Slow EMA Color", group=grp2)
show_emas = input.bool(true, "Show EMA Lines", group=grp2)
bg_opacity = input.int(93, "Background Opacity", minval=50, maxval=99, group=grp2)

// ═══════════════════════════════════════════════════════════
//  EMA CALCULATIONS
// ═══════════════════════════════════════════════════════════
fast_ema = ta.ema(close, fast_len)
slow_ema = ta.ema(close, slow_len)

// ═══════════════════════════════════════════════════════════
//  CROSS DETECTION
// ═══════════════════════════════════════════════════════════
bull_cross = ta.crossover(fast_ema,  slow_ema)  // 20 crosses above 200 → BUY
bear_cross = ta.crossunder(fast_ema, slow_ema)  // 20 crosses below 200 → SELL

// Current bias
is_bullish = fast_ema > slow_ema
is_bearish = fast_ema < slow_ema

// ═══════════════════════════════════════════════════════════
//  PLOTS — EMA LINES
// ═══════════════════════════════════════════════════════════
plot(show_emas ? fast_ema : na, "20 EMA", color=ema_fast_col, linewidth=2)
plot(show_emas ? slow_ema : na, "200 EMA", color=ema_slow_col, linewidth=2)

// ═══════════════════════════════════════════════════════════
//  SIGNAL LABELS
// ═══════════════════════════════════════════════════════════
if bull_cross
    label.new(bar_index, low * 0.9995,
              "▲ BUY\n20 EMA ✕ 200 EMA",
              color=bull_col, textcolor=color.white,
              style=label.style_label_up, size=size.normal)

if bear_cross
    label.new(bar_index, high * 1.0005,
              "▼ SELL\n20 EMA ✕ 200 EMA",
              color=bear_col, textcolor=color.white,
              style=label.style_label_down, size=size.normal)

// ═══════════════════════════════════════════════════════════
//  BACKGROUND COLOR
// ═══════════════════════════════════════════════════════════
bgcolor(is_bullish ? color.new(bull_col, bg_opacity) : na, title="Bullish Bias")
bgcolor(is_bearish ? color.new(bear_col, bg_opacity) : na, title="Bearish Bias")

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(bull_cross, "EMA Bull Cross", "BUY SIGNAL - 20 EMA crossed above 200 EMA. Bullish bias confirmed.")
alertcondition(bear_cross, "EMA Bear Cross", "SELL SIGNAL - 20 EMA crossed below 200 EMA. Bearish bias confirmed.")
alertcondition(bull_cross or bear_cross, "EMA Any Cross", "EMA Cross detected - check chart for direction.")
````
