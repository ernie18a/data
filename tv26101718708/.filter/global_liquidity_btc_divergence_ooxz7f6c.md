# Global Liquidity + BTC Divergence

- url: https://www.tradingview.com/script/OOxz7f6c/
- type: indicator
- pine_id: PUB;2f08f41652064073aec6159360b5fd43
- version: 1.0

## Description

This Pine Script is essentially creating a:

“Global USD Liquidity vs BTC Price” divergence monitoring indicator.

The core idea is:

In theory:

Global liquidity ↑
BTC should also ↑

If the two move inconsistently,
that creates a “divergence.”

This is a very common macro trading framework.

---

# What This Indicator Measures

It combines:

| Data  | Meaning                       |
| ----- | ----------------------------- |
| WALCL | Federal Reserve balance sheet |
| TGA   | U.S. Treasury General Account |
| RRP   | Reverse Repo                  |
| BTC   | Bitcoin price                 |

into:

“Net USD Liquidity”

Then compares it against Bitcoin price.

---

# Overall Logic Flow

Indicator workflow:

Federal Reserve data
↓
Calculate net liquidity
↓
Normalize values
↓
Normalize BTC
↓
Calculate divergence
↓
EMA smoothing
↓
Visualization

---

# Part 1: Getting Macro Data

Code:

```pine
walcl = request.security("FRED:WALCL", "W", close)
tga   = request.security("FRED:WTREGEN", "W", close)
rrp   = request.security("FRED:RRPONTSYD", "W", close)
```

The data comes from:

Federal Reserve Economic Data (FRED)

---

# What Is WALCL?

# WALCL

Total assets held by the Federal Reserve

Including:

* QE
* Treasury bonds
* MBS

When it rises:

it generally means the Fed is injecting liquidity.

Usually:

risk assets tend to rise.

---

# What Is TGA?

# Treasury General Account

The U.S. Treasury’s account at the Federal Reserve

You can think of it as:

money parked by the Treasury at the Fed.

When TGA rises:

market liquidity gets drained.

Because funds move back into the Treasury account.

That’s why it is subtracted.

---

# What Is RRP?

Reverse Repo

This is:

the Fed absorbing liquidity from the market.

When RRP rises:

market liquidity decreases.

So it is also subtracted.

---

# The Real Net Liquidity Formula

Core formula:

```pine
liq = walcl - tga - rrp
```

This is essentially:

Net Liquidity

Many macro traders use this exact framework.

---

# Part 2: Getting BTC Data

```pine
btc = request.security("BINANCE:BTCUSDT", "W", close)
```

This pulls:

* Binance
* BTCUSDT
* Weekly timeframe

---

# Part 3: Normalization

This is one of the most important parts of the indicator.

---

# Why Normalize?

Because:

| Data      | Value Range       |
| --------- | ----------------- |
| Liquidity | Trillions         |
| BTC       | Tens of thousands |

They cannot be compared directly.

So the script compresses both into a 0–1 range.

---

# Normalization Formula

```pine
(value - low) / (high - low)
```

Result:

Lowest value = 0
Highest value = 1

This allows:

* The liquidity curve
* The BTC curve

to be overlaid and compared visually.

---

# Part 4: Divergence

Core logic:

```pine
divergence = liqNorm - btcNorm
```

Meaning:

---

## If > 0

Liquidity is stronger than BTC.

This suggests:

BTC may be undervalued.

Liquidity has already increased,

but BTC has not followed yet.

Many traders interpret this as:

potential upside catch-up.

Green bars.

---

## If < 0

BTC has risen too aggressively.

It is outperforming liquidity support.

This may indicate:

an overheated market.

Macro traders often interpret this as:

potential pullback risk.

Red bars.

---

# EMA Section

```pine
liqEma = ta.ema(liqNorm, emaLen)
btcEma = ta.ema(btcNorm, emaLen)
```

Here:

the EMA is calculated,

but never plotted.

So currently:

it has no practical effect.

It was probably intended for:

* smoothing
* trend analysis

but was not fully implemented.

---

# Chart Explanation

---

# Green Line

Liquidity
Global liquidity

---

# Orange Line

BTC price

---

# Histogram Bars

Divergence value

---

# Green Background

Liquidity > BTC

This implies:

a bullish environment.

---

# Red Background

BTC > Liquidity

This implies:

a potentially overheated market.

---

# What This Indicator Is Good For

Very suitable for:

| Scenario                 | Suitability |
| ------------------------ | ----------- |
| Macro trend analysis     | Excellent   |
| Weekly timeframe         | Excellent   |
| Long-term BTC investing  | Very good   |
| Bull/bear cycle analysis | Very good   |
| Short-term trading       | Poor        |
| High-frequency trading   | Poor        |

---

# Core Philosophy of the Indicator

The fundamental idea is:

BTC is largely driven by USD liquidity over the long term.

Meaning:

Fed liquidity injections
→ Risk assets rise
→ BTC rises

Many institutions:

* Global Macro funds
* Crypto hedge funds
* Liquidity-focused traders

use very similar models.

---

# But This Indicator Has Several Limitations

---

# 1. The Data Is Weekly

You used:

```pine
"W"
```

Which means:

updates are slow.

This is only suitable for higher timeframes.

---

# 2. BTC Is Not Driven Only by Liquidity

BTC is also influenced by:

* ETFs
* Halving cycles
* Leverage
* Stablecoins
* Market sentiment
* Regulation

---

# 3. Normalization Can Distort Reality

0–1 normalization:

only shows relative positioning,

not absolute valuation.

---

# 4. No Lead/Lag Modeling

In reality:

liquidity changes often lead BTC by several weeks or months.

But here:

they are compared simultaneously.

This reduces accuracy.

Professional models often:

shift liquidity forward.

For example:

```pine
liqShift = liqNorm[10]
```

Meaning:

liquidity leads BTC by 10 weeks.

---

# Professional Upgrade Ideas

You can improve this model further by adding:

---

## 1. Lead-Lag Analysis

Most important upgrade.

---

## 2. Global Central Banks

Not just the Fed:

* ECB
* BOJ
* PBOC

---

## 3. DXY

The U.S. Dollar Index is extremely important.

---

## 4. Stablecoin Supply

Such as:

* USDT
* USDC

---

## 5. Global M2

Global money supply.

---

# Who This Indicator Is Best For

Suitable for:

* Macro traders
* Long-term BTC investors
* Cycle analysis
* Liquidity research
* Crypto macro strategies

Not suitable for:

* High-frequency trading
* Intraday trading
* Scalping

---

# One-Sentence Summary

This indicator is essentially asking:

“Is BTC’s current price action supported by global USD liquidity?”

If:

Liquidity is strong
BTC is weak

Then:

BTC may eventually catch up higher.

If:

BTC is far stronger than liquidity

Then:

the market may be overheating.

## Source Code

````pine
//@version=5
indicator("Global Liquidity + BTC Divergence", overlay=false)

// =====================
// 流动性数据
// =====================
walcl = request.security("FRED:WALCL", "W", close)
tga   = request.security("FRED:WTREGEN", "W", close)
rrp   = request.security("FRED:RRPONTSYD", "W", close)

liq = walcl - tga - rrp

// =====================
// BTC
// =====================
btc = request.security("BINANCE:BTCUSDT", "W", close)

// =====================
// 标准化
// =====================
liqLow  = ta.lowest(liq, 100)
liqHigh = ta.highest(liq, 100)

btcLow  = ta.lowest(btc, 100)
btcHigh = ta.highest(btc, 100)

liqNorm = (liq - liqLow) / (liqHigh - liqLow)
btcNorm = (btc - btcLow) / (btcHigh - btcLow)

// =====================
// 背离
// =====================
divergence = liqNorm - btcNorm

// =====================
// EMA
// =====================
emaLen = input.int(12, title="EMA Length")

liqEma = ta.ema(liqNorm, emaLen)
btcEma = ta.ema(btcNorm, emaLen)

// =====================
// 绘图
// =====================
plot(liqNorm,
     title="Liquidity",
     color=color.lime,
     linewidth=2)

plot(btcNorm,
     title="BTC",
     color=color.orange,
     linewidth=2)

// =====================
// 背离柱
// =====================
divColor =
     divergence > 0
     ? color.new(color.green, 30)
     : color.new(color.red, 30)

plot(divergence,
     title="Divergence",
     style=plot.style_columns,
     color=divColor)

// =====================
// 背景
// =====================
bgcolor(
     divergence > 0
     ? color.new(color.green, 92)
     : color.new(color.red, 92))

// =====================
// 0轴
// =====================
hline(0)
````
