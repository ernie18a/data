# Bacon's Stoch Highlight

- url: https://www.tradingview.com/script/V1fhUD7w-Bacon-s-Stoch-Highlight/
- type: indicator
- pine_id: PUB;1cfb6c1977f54474b81370cccfe0a06d
- version: 1.0

## Description

Bacon's Stoch Highlight
.....
Bacon's Stoch Highlight
.....
Bacon's Stoch Highlight
.....
Bacon's Stoch Highlight
.....

## Source Code

````pine
//@version=6
indicator("Bacon's Stoch Highlight", overlay=false)

// ===== INPUT =====
periodK = input.int(9)
smoothK = input.int(3)
periodD = input.int(3)

// ===== CALC =====
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)

overbought = 80
oversold = 20

// ===== PLOT เส้น =====
plot(k, color=#2962FF, linewidth=2)
plot(d, color=#FF6D00, linewidth=2)

// ===== เส้นโซน =====
hOB = hline(overbought)
hOS = hline(oversold)

// ===== 👇 จุดสำคัญ =====
// สร้าง plot เฉพาะตอนเข้าโซน

k_ob = k > overbought ? k : na
k_os = k < oversold ? k : na

top = 100
bottom = 0

p_top = plot(top, display=display.none)
p_bottom = plot(bottom, display=display.none)

// ===== fill เฉพาะช่วง =====
// 🔴 Overbought
fill(plot(k_ob), p_top, color=color.new(color.red, 85))

// 🟢 Oversold
fill(plot(k_os), p_bottom, color=color.new(color.green, 85))
````
