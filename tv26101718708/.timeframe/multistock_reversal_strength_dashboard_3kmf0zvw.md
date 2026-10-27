# Multi-Stock Reversal & Strength Dashboard 

- url: https://www.tradingview.com/script/3kmF0ZVW-Multi-Stock-Reversal-Strength-Dashboard/
- type: indicator
- pine_id: PUB;97a873f6238c4d9ea9e03cb2e0ae4409
- version: 1.0

## Description

**Brahmastra Pro – Multi-Stock Reversal & Strength Dashboard (EMA 252/365 + RS + CPR/VWAP)**

This script is a multi-stock dashboard designed to identify high-probability swing and positional opportunities using a combination of long-term trend, momentum, relative strength, and intraday alignment.

---

### 🔍 What This Indicator Does

It scans a custom list of stocks and ranks them based on:

* Trend strength (EMA 252 & EMA 365)
* Momentum (RSI + Volume expansion)
* Relative strength vs NIFTY
* Reversal signals after deep corrections
* Intraday alignment using CPR and VWAP
* Automated Entry, Stop Loss, and Target levels

The result is a compact dashboard that helps you focus only on the strongest candidates instead of scanning charts manually.

---

### 📊 Core Logic

**1. Trend & Reversal Detection**

* EMA 252 → Medium/long-term trend
* EMA 365 → Deep cycle trend
* Reversal signals when price crosses above EMA 252 or bounces near EMA 365

**2. Momentum Confirmation**

* RSI strength (>55)
* Volume above average
* Filters out weak breakouts

**3. Relative Strength (RS)**

* Compares stock performance vs NIFTY
* RS > 1 → outperforming the market

**4. CPR + VWAP Alignment**

* CPR (Central Pivot Range) from previous day
* VWAP for intraday bias
* Bullish setup when price is above both

**5. Scoring System (0–10)**
Each stock is scored based on trend, momentum, and reversal factors:

* 8–10 → Strong trend continuation
* 6–7 → Early reversal candidates
* Below 5 → Weak / avoid

---

### 🎯 Trade Levels (Auto-Generated)

* **Entry** → Current price / breakout confirmation
* **Stop Loss** → ATR-based dynamic level
* **Target** → Risk-reward based projection

This ensures consistent risk management across all trades.

---

### 📈 How to Use

1. Add your preferred stocks in the input section
2. Use on **Daily timeframe** for scanning
3. Confirm entries on **15m / 1H charts**

Focus only on stocks where:

* Score ≥ 7
* RS > 1
* Alignment = YES
* Signal = BUY

These represent the strongest setups.

---

### ⚠️ Important Notes

* This is a decision-support tool, not a standalone trading system
* Works best for swing and positional trading
* VWAP alignment is more effective on intraday timeframes
* Stock list must be updated manually (Pine limitation)

---

### 🚀 Ideal For

* Traders who want a structured watchlist instead of random scanning
* Swing traders looking for early trend reversals
* Traders who combine technical + relative strength analysis

---

This script is designed to simplify decision-making by combining multiple high-value signals into one dashboard. Customize the stock list and parameters based on your strategy.

## Source Code

````pine
//@version=6
indicator("Brahmastra Stock Ranking System (PortFolio)", overlay=false)

// ==========================
// SETTINGS
// ==========================
indexSym = input.symbol("NSE:NIFTY", "Index")
atrLen   = input.int(14, "ATR Length")
atrMult  = input.float(1.5, "SL ATR Multiplier")
rr       = input.float(2.0, "Risk Reward")

// ==========================
// INDEX DATA (SINGLE LINE)
// ==========================
[idx, idx30] = request.security(indexSym, "D", [close, close[30]])
idxRet = (idx - idx30) / idx30 * 100

// ==========================
// STOCKS
// ==========================
s1 = input.symbol("NSE:RELIANCE")
s2 = input.symbol("NSE:TCS")
s3 = input.symbol("NSE:HDFCBANK")
s4 = input.symbol("NSE:ICICIBANK")
s5 = input.symbol("NSE:INFY")
s6 = input.symbol("NSE:LT")
s7 = input.symbol("NSE:SBIN")
s8 = input.symbol("NSE:AXISBANK")
s9 = input.symbol("NSE:ITC")
s10 = input.symbol("NSE:TATAMOTORS")

// ==========================
// FUNCTION
// ==========================
f_calc(sym) =>
    [c, c1, c30, ema252, ema365, rsi, vol, volAvg, atr, ph, pl, pc] = request.security(sym, "D", [close, close[1], close[30], ta.ema(close,252), ta.ema(close,365), ta.rsi(close,14), volume, ta.sma(volume,20), ta.atr(atrLen), high[1], low[1], close[1]])

    ret = (c - c30) / c30 * 100
    rs  = idxRet != 0 ? ret / idxRet : 0

    emaBreak = c > ema252 and c1 < ema252
    near365  = math.abs(c - ema365) / c < 0.02
    deepRev  = near365 and rsi > 50 and vol > volAvg

    score = 0.0
    score += c > ema252 ? 2 : 0
    score += c > ema365 ? 2 : 0
    score += rsi > 55 ? 2 : 0
    score += vol > volAvg ? 2 : 0
    score += emaBreak ? 1 : 0
    score += deepRev ? 1 : 0

    signal = emaBreak or deepRev

    pivot = (ph + pl + pc) / 3
    bc = (ph + pl) / 2
    tc = pivot + (pivot - bc)

    vwap = ta.vwap
    bullish = c > vwap and c > tc

    entry  = c
    sl     = c - atrMult * atr
    target = c + rr * (c - sl)

    [score, rs, signal, bullish, entry, sl, target]

// ==========================
// CALL FUNCTION (DIRECT)
// ==========================
[s1_sc, s1_rs, s1_sig, s1_bull, s1_e, s1_sl, s1_t] = f_calc(s1)
[s2_sc, s2_rs, s2_sig, s2_bull, s2_e, s2_sl, s2_t] = f_calc(s2)
[s3_sc, s3_rs, s3_sig, s3_bull, s3_e, s3_sl, s3_t] = f_calc(s3)
[s4_sc, s4_rs, s4_sig, s4_bull, s4_e, s4_sl, s4_t] = f_calc(s4)
[s5_sc, s5_rs, s5_sig, s5_bull, s5_e, s5_sl, s5_t] = f_calc(s5)
[s6_sc, s6_rs, s6_sig, s6_bull, s6_e, s6_sl, s6_t] = f_calc(s6)
[s7_sc, s7_rs, s7_sig, s7_bull, s7_e, s7_sl, s7_t] = f_calc(s7)
[s8_sc, s8_rs, s8_sig, s8_bull, s8_e, s8_sl, s8_t] = f_calc(s8)
[s9_sc, s9_rs, s9_sig, s9_bull, s9_e, s9_sl, s9_t] = f_calc(s9)
[s10_sc, s10_rs, s10_sig, s10_bull, s10_e, s10_sl, s10_t] = f_calc(s10)

// ==========================
// TABLE
// ==========================
var table t = table.new(position.top_right, 8, 12)

if barstate.isfirst
    table.cell(t, 0, 0, "Stock")
    table.cell(t, 1, 0, "Score")
    table.cell(t, 2, 0, "RS")
    table.cell(t, 3, 0, "Align")
    table.cell(t, 4, 0, "Entry")
    table.cell(t, 5, 0, "SL")
    table.cell(t, 6, 0, "Target")
    table.cell(t, 7, 0, "Signal")

f_row(r, name, sc, rs, bull, e, sl, t1, sig) =>
    col = sc >= 7 and rs > 1 and bull ? color.green : color.orange

    table.cell(t, 0, r, name)
    table.cell(t, 1, r, str.tostring(sc), bgcolor=col)
    table.cell(t, 2, r, str.tostring(rs, "#.2"))
    table.cell(t, 3, r, bull ? "YES" : "NO")
    table.cell(t, 4, r, str.tostring(e))
    table.cell(t, 5, r, str.tostring(sl))
    table.cell(t, 6, r, str.tostring(t1))
    table.cell(t, 7, r, sig ? "BUY" : "-")

f_row(1, s1, s1_sc, s1_rs, s1_bull, s1_e, s1_sl, s1_t, s1_sig)
f_row(2, s2, s2_sc, s2_rs, s2_bull, s2_e, s2_sl, s2_t, s2_sig)
f_row(3, s3, s3_sc, s3_rs, s3_bull, s3_e, s3_sl, s3_t, s3_sig)
f_row(4, s4, s4_sc, s4_rs, s4_bull, s4_e, s4_sl, s4_t, s4_sig)
f_row(5, s5, s5_sc, s5_rs, s5_bull, s5_e, s5_sl, s5_t, s5_sig)
f_row(6, s6, s6_sc, s6_rs, s6_bull, s6_e, s6_sl, s6_t, s6_sig)
f_row(7, s7, s7_sc, s7_rs, s7_bull, s7_e, s7_sl, s7_t, s7_sig)
f_row(8, s8, s8_sc, s8_rs, s8_bull, s8_e, s8_sl, s8_t, s8_sig)
f_row(9, s9, s9_sc, s9_rs, s9_bull, s9_e, s9_sl, s9_t, s9_sig)
f_row(10, s10, s10_sc, s10_rs, s10_bull, s10_e, s10_sl, s10_t, s10_sig)
````
