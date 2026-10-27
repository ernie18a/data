# K-JohnWick : Oscillator Plus (with BB)

- url: https://www.tradingview.com/script/Jexva41Y-K-JohnWick-Oscillator-Plus-with-BB/
- type: indicator
- pine_id: PUB;2dcbe1cdf6ce4d4583d3afdf6e0f160b
- version: 1.0

## Description

Exclusive Advantages of K-JohnWick: Osc+ BB

1. The Power of Convergence: Volatility Bands Matched with Low-Lag Oscillator
Unlike standalone indicators that only show overbought or oversold levels, this advanced oscillator is dynamically integrated with volatility bands. It continuously calculates real-time price expansion and contraction inside the oscillator matrix.

The Advantage: It gives you an absolute edge in identifying mathematical exhaustion points (the exact macro tops and bottoms), preventing you from entering a trade too early or too late.

2. High-Probability Twin-Engine Entry Strategy (The Perfect Combo)
The true magic happens when you combine this oscillator with the K-Johnwick Triple Sniper on your main chart. It creates an institutional-grade, high-probability confirmation system.

🚀 Perfect Long (Buy) Entry Setup:

The Triple Sniper confirms a dominant bullish trend (the main chart transitions to a blue background).

You wait for a temporary price correction where the oscillator line turns Red (indicating a short-term pullback).

The moment the red oscillator line touches or pierces the lower volatility band, it signals an extreme discount zone. This is your high-conviction, low-risk Long entry trigger.

📉 Perfect Short (Sell) Entry Setup:

The Triple Sniper confirms a dominant bearish trend (the main chart transitions to a red background).

You wait for a temporary upward bounce where the oscillator line turns Green.

The moment the green oscillator line touches or breaks above the upper volatility band, it signals an overextended rip. This is your definitive Short entry trigger to ride the macro wave down.

## Source Code

````pine
//@version=6
indicator("K-JohnWick : Oscillator Plus (with BB)", shorttitle="K-JohnWick : Osc+ BB", overlay=false)

// ----------------------------------------------------------------------
// 0. 프리미엄 지표 홍보 섹션 (Premium Promotion)
// ----------------------------------------------------------------------
group_promo = "⚡ K-JohnWick Premium Info"
promo_info1 = input.string("K-JohnWick : Triple Sniper", title="★ Premium Match :", group=group_promo, confirm=true)
promo_info2 = input.string("Perfect synergy with Upper Ribbon!", title="Notice :", group=group_promo, confirm=true)

// ----------------------------------------------------------------------
// 1. 위장된 설정 (Inputs)
// ----------------------------------------------------------------------
group_main = "Primary Matrix Tuning"
val_alpha  = input.int(14, "Alpha Factor", group=group_main)
val_beta   = input.int(10, "Beta Factor", group=group_main)
data_src   = input(close, "Execution Source", group=group_main)

group_bb   = "Secondary Volatility Core"
show_node  = input.bool(true, "Activate Grid Range", group=group_bb)
val_gamma  = input.int(20, "Gamma Factor", group=group_bb)
val_delta  = input.float(2.0, "Delta Multiplier", group=group_bb)

group_mf   = "Flow Vector Tracking"
val_epsilon = input.int(14, "Epsilon Factor", group=group_mf)

// ----------------------------------------------------------------------
// 2. 메인 오실레이터 리본 (Low-Lag Ribbon)
// ----------------------------------------------------------------------
base_node    = ta.rsi(data_src, val_alpha)
smooth_main  = ta.hma(base_node, val_beta)
smooth_sig   = ta.hma(smooth_main, 5)

// 내부 연산에 따른 색상 정의
col_vector_a = color.new(#00ff00, 30)
col_vector_b = color.new(#ff5252, 30)
col_vector_c = color.new(#ff0000, 30)
col_vector_d = color.new(#4caf50, 30)

ribbon_color = smooth_main > smooth_sig ? (smooth_main > 50 ? col_vector_a : col_vector_b) : (smooth_main < 50 ? col_vector_c : col_vector_d)

p1 = plot(smooth_main, "Main Ribbon", color=ribbon_color, linewidth=2)
p2 = plot(smooth_sig, "Signal Ribbon", color=color.gray, linewidth=1)
fill(p1, p2, color=ribbon_color, title="Ribbon Fill")

// ----------------------------------------------------------------------
// 3. 변동성 보정 라인 (Volatility Bands on Oscillator)
// ----------------------------------------------------------------------
[bb_mid, bb_up, bb_dn] = ta.bb(smooth_main, val_gamma, val_delta)

plot(show_node ? bb_up : na, "BB Upper", color=color.new(color.blue, 50), style=plot.style_line)
plot(show_node ? bb_dn : na, "BB Lower", color=color.new(color.blue, 50), style=plot.style_line)

hline(50, "Mid Line", color=color.gray, linestyle=hline.style_dotted)
hline(80, "Overbought", color=color.red, linestyle=hline.style_dotted)
hline(20, "Oversold", color=color.green, linestyle=hline.style_dotted)

// ----------------------------------------------------------------------
// 4. 자금 유동성 매트릭스 (Money Flow)
// ----------------------------------------------------------------------
flow_calc = ta.mfi(data_src, val_epsilon)

bgcolor(flow_calc > 50 ? color.new(color.green, 90) : color.new(color.red, 90), title="Money Flow Background")

// ----------------------------------------------------------------------
// 5. 시그널 디텍터 (Divergence 감지)
// ----------------------------------------------------------------------
bear_div = (ta.highest(data_src, 5) > ta.highest(data_src[1], 5)) and (ta.highest(smooth_main, 5) < ta.highest(smooth_main[1], 5)) and (smooth_main > 70)
bull_div = (ta.lowest(data_src, 5) < ta.lowest(data_src[1], 5)) and (ta.lowest(smooth_main, 5) > ta.lowest(smooth_main[1], 5)) and (smooth_main < 30)

plotshape(bear_div, title="Bearish Divergence", style=shape.labeldown, location=location.top, color=color.red, text="D", textcolor=color.white)
plotshape(bull_div, title="Bullish Divergence", style=shape.labelup, location=location.bottom, color=color.green, text="D", textcolor=color.white)

// ----------------------------------------------------------------------
// 알림 매트릭스 (Alerts - 홍보 문구 연동)
// ----------------------------------------------------------------------
alertcondition(bull_div, title="Bullish Divergence Alert", message="[K-JohnWick] Bullish Divergence! Check 'Triple Sniper' Ribbon on Main Chart for Perfect Entry Entry.")
alertcondition(bear_div, title="Bearish Divergence Alert", message="[K-JohnWick] Bearish Divergence! Check 'Triple Sniper' Ribbon on Main Chart for Perfect Short Entry.")
alertcondition(ta.crossover(smooth_main, smooth_sig), title="Ribbon Bullish Cross", message="[K-JohnWick] Ribbon Turned Green. Sync with Upper 'Triple Sniper' Trend.")
alertcondition(ta.crossunder(smooth_main, smooth_sig), title="Ribbon Bearish Cross", message="[K-JohnWick] Ribbon Turned Red. Sync with Upper 'Triple Sniper' Trend.")
alertcondition(ta.crossover(smooth_main, bb_up), title="BB Upper Breakout", message="[K-JohnWick] Volatility Upper Breakout! Cross-check with Premium 'Triple Sniper'.")
alertcondition(ta.crossunder(smooth_main, bb_dn), title="BB Lower Breakout", message="[K-JohnWick] Volatility Lower Breakout! Cross-check with Premium 'Triple Sniper'.")
````
