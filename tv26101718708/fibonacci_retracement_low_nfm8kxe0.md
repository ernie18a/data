# Fibonacci Retracement Low

- url: https://www.tradingview.com/script/nFm8kXE0/
- type: indicator
- pine_id: PUB;8a73e9c570344720a70edbc258cf5691
- version: 1.0

## Description

[image]https://www.tradingview.com/x/xp6bHgpf/[/image]

Fibonacci Retracement Low for bitcoin and other coins.


# Fibonacci Retracement Low — Bitcoin & Altcoins

## 📐 What is Fibonacci Retracement?

Fibonacci Retracement is a technical analysis tool derived from the **Fibonacci sequence**, a mathematical series discovered by Leonardo Fibonacci in the 13th century. The sequence — 0, 1, 1, 2, 3, 5, 8, 13, 21... — produces a ratio (~1.618) known as the **Golden Ratio (φ)**, which appears repeatedly in nature, art, and financial markets.

In trading, key retracement levels are calculated as:
- **23.6%** — shallow pullback zone
- **38.2%** — moderate support/resistance
- **50.0%** — psychological midpoint (not a Fibonacci number, but widely respected)
- **61.8%** — the "Golden Pocket," most critical level
- **78.6%** — deep retracement, often a last line of defense before trend invalidation

---

## 🔍 Theoretical Background

### Why Does It Work in Markets?

Markets are driven by **human psychology**, and crowd behavior tends to cluster around mathematically significant levels. Traders worldwide watch the same Fibonacci levels, creating **self-fulfilling prophecies** — the more traders act on a level, the more significant that level becomes.

### Retracement vs. Reversal

A retracement is a **temporary price pullback** within a larger trend. The core thesis of Fibonacci Retracement analysis is:

> *"A strong trending asset will not give back all its gains — it will retrace to a predictable mathematical level and resume its primary trend."*

The chart identifies the **Retracement Low**, meaning the deepest point of a corrective wave before the next major upward impulse.

---

## ₿ Bitcoin & Altcoin Context

### Bitcoin as the Anchor

Bitcoin dominates the crypto market, and its Fibonacci structure sets the **macro framework** for the entire cycle. Historically:

| Cycle | Retracement Level | Outcome |
|---|---|---|
| 2018–2019 Bear | ~84% drawdown | Bounced at 0.786 |
| 2020 COVID Crash | ~50% level | V-shape recovery |
| 2021–2022 Bear | ~77% drawdown | Major accumulation zone |

### Altcoin Behavior

Altcoins tend to **amplify** Bitcoin's Fibonacci structure:
- They retrace **deeper** (often 85–95%)
- But they also **bounce harder** from key levels
- The 61.8% and 78.6% zones act as **high-probability accumulation targets** for risk-on capital rotation

---

## 📊 Practical Application

When the chart marks the **Fibonacci Retracement Low**, it signals:

1. **Price has reached a historically significant mathematical support**
2. **Risk/reward is favorable** — downside is limited relative to potential upside
3. **Confluence with other indicators** (volume, RSI divergence, on-chain data) strengthens the signal
4. **Macro cycle positioning** — these lows often coincide with the final capitulation phase before a new bull run

---

## ⚠️ Key Caveats

- Fibonacci levels are **not guarantees** — they are probability zones
- In extreme bear markets, price can **overshoot** below the 78.6% level temporarily
- Always combine with **volume analysis**, **market structure**, and **macro conditions**
- Bitcoin halving cycles historically influence which Fibonacci level acts as the ultimate bottom

---

The identification of a Fibonacci Retracement Low, particularly across both Bitcoin and altcoins simultaneously, is often interpreted as a **generational buying opportunity** — a zone where patient, thesis-driven investors accumulate positions before the next major market expansion phase.

## Source Code

````pine
//@version=5
indicator("피보나치 저점 기준", overlay=true)

// ===== 🟡 사용자 입력: 저점, 시작 시간 =====
low_price = input.float(defval=0.0, title="저점 가격(Low Price)", minval=0.0)
start_time = input.time(defval=timestamp("2026-01-01 00:00"), title="시작 시간대(Start Time)")

// ===== 🟡 고점은 시작 시간 이후부터 자동 갱신 =====
var float high_price = na
is_after_start = time >= start_time

// 시작 시간 이후부터 최고가 자동 추적
if is_after_start
    if na(high_price) or high > high_price
        high_price := high

// Fibonacci retracement levels
fib_0 = low_price
fib_146 = low_price + (high_price - low_price) * 0.146
fib_236 = low_price + (high_price - low_price) * 0.236
fib_382 = low_price + (high_price - low_price) * 0.382
fib_50 = low_price + (high_price - low_price) * 0.5
fib_618 = low_price + (high_price - low_price) * 0.618
fib_764 = low_price + (high_price - low_price) * 0.764
fib_854 = low_price + (high_price - low_price) * 0.854
fib_100 = high_price

// Fibonacci extension levels
fib_1618 = high_price + (high_price - low_price) * 0.618
fib_2618 = high_price + (high_price - low_price) * 1.618
fib_4236 = high_price + (high_price - low_price) * 2.618

// Level plots (optional visual confirmation)
plot(is_after_start ? fib_0 : na, color=color.blue, linewidth=1, title="Fib 0%")
plot(is_after_start ? fib_146 : na, color=#af8e8e, linewidth=1, title="Fib 14.6%")
plot(is_after_start ? fib_236 : na, color=color.red, linewidth=1, title="Fib 23.6%")
plot(is_after_start ? fib_382 : na, color=#81c784, linewidth=1, title="Fib 38.2%")
plot(is_after_start ? fib_50 : na, color=#4caf50, linewidth=1, title="Fib 50%")
plot(is_after_start ? fib_618 : na, color=#089981, linewidth=1, title="Fib 61.8%")
plot(is_after_start ? fib_764 : na, color=#00bcd4, linewidth=1, title="Fib 76.4%")
plot(is_after_start ? fib_854 : na, color=#673ab7, linewidth=1, title="Fib 85.4%")
plot(is_after_start ? fib_100 : na, color=color.green, linewidth=1, title="Fib 100%")
plot(is_after_start ? fib_1618 : na, color=color.white, linewidth=1, title="Fib 161.8%")
plot(is_after_start ? fib_2618 : na, color=color.white, linewidth=1, title="Fib 261.8%")
plot(is_after_start ? fib_4236 : na, color=color.white, linewidth=1, title="Fib 423.6%")

if barstate.islast and is_after_start
    label.new(bar_index, fib_0, str.tostring(fib_0, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=color.blue, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_146, str.tostring(fib_146, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#af8e8e, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_236, str.tostring(fib_236, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=color.red, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_382, str.tostring(fib_382, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#81c784, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_50, str.tostring(fib_50, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#4caf50, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_618, str.tostring(fib_618, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#089981, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_764, str.tostring(fib_764, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#00bcd4, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_854, str.tostring(fib_854, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=#673ab7, style=label.style_label_left, size=size.normal)
    label.new(bar_index, fib_100, str.tostring(fib_100, "#.##"), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.blue, 100), textcolor=color.green, style=label.style_label_left, size=size.normal)
````
