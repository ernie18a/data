# Inside Day Breakout Strategy

- url: https://www.tradingview.com/script/E7jfjUgH-Inside-Day-Breakout-Strategy/
- type: strategy
- pine_id: PUB;a61d290170384ee49bab9a3ed00d59b4
- version: 1.0

## Description

# Inside Day Breakout Strategy

The **Inside Day Breakout Strategy** is a price action volatility breakout system designed to capture strong directional moves after periods of market compression.

An **Inside Day** occurs when the entire daily trading range remains inside the previous day’s range, reflecting temporary equilibrium between buyers and sellers. These low-volatility conditions are often followed by expansionary price movements, making the pattern ideal for breakout trading strategies.

The script automatically identifies Inside Day structures and places breakout stop orders above and below the Inside Day range.

---

# 📌 Strategy Concept

The core idea behind this strategy is simple:

> **Trade volatility expansion after price compression.**

When the market contracts into a smaller range, it often precedes a significant directional move. The strategy attempts to capture that move by entering only when price breaks beyond the Inside Day boundaries.

---

# 🔍 1. Inside Day Detection

An Inside Day is detected when the previous day’s range is fully contained within the range of two days ago.

Condition:

High_{1} < High_{2}\quad \text{and} \quad Low_{1} > Low_{2}

Where:

* **High₁** → Previous day high
* **Low₁** → Previous day low
* **High₂** → High from two days ago
* **Low₂** → Low from two days ago

This pattern represents:

* declining volatility
* temporary market balance
* potential breakout energy buildup

When the condition is met, the script highlights the setup visually on the chart.

---

# 🚀 2. Breakout Entry Logic

Once an Inside Day is confirmed, the strategy places pending breakout orders:

### Long Breakout

* Buy stop order above the previous day’s high

### Short Breakout

* Sell stop order below the previous day’s low

Supported trade modes:

* **Both Directions**
* **Long Only**
* **Short Only**

The strategy only allows one active directional position at a time to prevent overlapping exposure.

---

# 💰 3. Position Sizing

The strategy uses an aggressive **100% equity allocation model**.

Position size is dynamically calculated using:

* current account equity
* breakout entry price

This ensures the strategy continuously compounds position sizing based on account growth or drawdown.

---

# 🛡️ 4. Stop Loss Management

Risk management is based on the structure of the Inside Day itself.

### For Long Positions

* Stop Loss = Previous day low

### For Short Positions

* Stop Loss = Previous day high

This creates a clean structural invalidation level:

* if price re-enters the Inside Day range,
* the breakout thesis is considered invalid.

---

# 🎯 5. Optional ATR-Based Take Profit

The strategy optionally supports a fixed take profit target using Daily ATR.

Take profit distance:

TP\ Distance = Daily\ ATR \times Multiplier

### Long Position

* TP = Entry Price + ATR Distance

### Short Position

* TP = Entry Price − ATR Distance

If Take Profit is disabled:

* positions remain open until Stop Loss is triggered
* or until End-of-Day closing occurs

This allows traders to choose between:

* fixed reward targets
* or open-ended trend capture

---

# ⏰ 6. End-of-Day (EOD) Risk Management

To reduce overnight exposure and gap risk, the strategy can automatically close all positions at:

### **16:55 New York Time**

This occurs 5 minutes before market close.

EOD closing can be enabled or disabled through the strategy inputs.

---

# 🔔 7. Webhook Alert System

The script includes fully structured **JSON webhook alerts** for automation and external execution systems.

Alert payload includes:

* Strategy name
* Trading symbol
* Signal type
* Order action
* Entry/exit price
* Position size
* Net profit
* Win rate
* Current equity
* Timestamp

This makes the strategy compatible with:

* trading bots
* exchange APIs
* automation platforms
* copy trading systems

---

# ✨ Key Features

* Automatic Inside Day pattern detection
* Volatility breakout trading system
* Dynamic stop-entry breakout orders
* Optional ATR-based take profit
* Structural stop loss placement
* End-of-day auto close protection
* Webhook-ready JSON alerts
* Long-only / Short-only / Bi-directional modes
* Dynamic 100% equity position sizing

---

# 📈 Best Market Conditions

This strategy tends to perform best during:

✅ Volatility expansion phases
✅ Trending market environments
✅ Momentum-driven sessions
✅ Post-consolidation breakouts

---

# ⚠️ Challenging Market Conditions

Performance may weaken during:

❌ Choppy sideways markets
❌ False breakout environments
❌ Extremely low-volatility conditions
❌ Mean-reverting market behavior

---

# ⚠️ Risk Disclaimer

This strategy uses aggressive capital allocation by deploying **100% of account equity per trade**.

While this approach can maximize returns during strong trends, it can also significantly increase drawdowns during adverse market conditions.

Before using this strategy in live markets, traders should carefully evaluate:

* leverage usage
* slippage
* execution quality
* broker limitations
* personal risk tolerance

Always forward test and paper trade before deploying real capital.

## Source Code

````pine
//@version=5
strategy("Inside Day Breakout [Antigravity] - Webhook", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
trade_dir       = input.string("Both", title="Trade Direction", options=["Both", "Long Only", "Short Only"], group="Strategy Settings")
use_tp          = input.bool(false, "Use Fixed Take Profit", group="Strategy Settings", tooltip="หากปิด บอทจะถือออเดอร์ไปจนกว่าจะโดน SL หรือถูกบังคับปิดตอนจบวัน (EOD)")
tp_multiplier   = input.float(1.5, "Take Profit (x Daily ATR)", step=0.1, group="Strategy Settings")
atr_length      = input.int(14, "Daily ATR Length", group="Strategy Settings")
use_eod         = input.bool(true, "Close Position at EOD (16:55 NY Time)", group="Time Management", tooltip="บังคับปิดออเดอร์ 5 นาทีก่อนตลาดปิด เพื่อเลี่ยงการข้ามวัน")

// =========================================================================
// 2. TIME & SESSION MANAGEMENT
// =========================================================================
trade_session = "1800-1655"
in_session = not na(time(timeframe.period, trade_session, "America/New_York"))

// =========================================================================
// 3. FETCH DAILY DATA
// =========================================================================
[d_high1, d_low1, d_high2, d_low2, d_atr] = request.security(syminfo.tickerid, "D", [high[1], low[1], high[2], low[2], ta.atr(atr_length)[1]], lookahead=barmerge.lookahead_on)

// =========================================================================
// 4. CONDITIONS & POSITION SIZING (100% All-in)
// =========================================================================
is_inside_day = (d_high1 < d_high2) and (d_low1 > d_low2)

long_qty  = d_high1 > 0 ? strategy.equity / d_high1 : 0
short_qty = d_low1 > 0 ? strategy.equity / d_low1 : 0

// =========================================================================
// 5. PERFORMANCE METRICS
// =========================================================================
total_trades = strategy.closedtrades
win_trades   = strategy.wintrades
win_rate     = total_trades > 0 ? (win_trades / total_trades) * 100 : 0.0

// =========================================================================
// 6. ALERT JSON FUNCTION (บรรทัดเดียว ป้องกัน Error)
// =========================================================================
f_alert(_signal, _order_id, _action, _price, _qty) =>
    msg = '{"strategy":"Inside Day Breakout","symbol":"' + syminfo.ticker + '","signal":"' + _signal + '","order_id":"' + _order_id + '","action":"' + _action + '","price":"' + str.tostring(_price, "#.####") + '","qty":"' + str.tostring(_qty, "#.####") + '","position_size":"' + str.tostring(strategy.position_size) + '","net_profit":"' + str.tostring(strategy.netprofit, "#.##") + '","win_rate":"' + str.tostring(win_rate, "#.##") + '","equity":"' + str.tostring(strategy.equity, "#.##") + '","time":"{{time}}"}'
    msg

// =========================================================================
// 7. TRADING LOGIC
// =========================================================================
is_new_day = ta.change(time("D")) != 0

if is_new_day or (use_eod and not in_session)
    strategy.cancel_all()

if is_inside_day and strategy.position_size == 0 and in_session
    if trade_dir == "Both" or trade_dir == "Long Only"
        strategy.entry("Long Breakout", strategy.long, qty=long_qty, stop=d_high1, alert_message=f_alert("OPEN_LONG", "Long Breakout", "buy", d_high1, long_qty))
    
    if trade_dir == "Both" or trade_dir == "Short Only"
        strategy.entry("Short Breakout", strategy.short, qty=short_qty, stop=d_low1, alert_message=f_alert("OPEN_SHORT", "Short Breakout", "sell", d_low1, short_qty))

// =========================================================================
// 8. STOP LOSS, TAKE PROFIT & EOD MANAGEMENT
// =========================================================================
if strategy.position_size > 0
    tp_level_long = use_tp ? strategy.opentrades.entry_price(0) + (d_atr * tp_multiplier) : na
    strategy.exit("Exit Long", "Long Breakout", stop=d_low1, limit=tp_level_long, alert_message=f_alert("CLOSE_LONG", "Exit Long", "sell", d_low1, math.abs(strategy.position_size)))
    strategy.cancel("Short Breakout") 

if strategy.position_size < 0
    tp_level_short = use_tp ? strategy.opentrades.entry_price(0) - (d_atr * tp_multiplier) : na
    strategy.exit("Exit Short", "Short Breakout", stop=d_high1, limit=tp_level_short, alert_message=f_alert("CLOSE_SHORT", "Exit Short", "buy", d_high1, math.abs(strategy.position_size)))
    strategy.cancel("Long Breakout") 

// 🔴 บังคับปิดออเดอร์ตอนจบวัน (End of Day Close)
if use_eod and not in_session and strategy.position_size != 0
    strategy.close_all(comment="EOD Close", alert_message=f_alert("CLOSE_EOD", "EOD Close", strategy.position_size > 0 ? "sell" : "buy", close, math.abs(strategy.position_size)))

// =========================================================================
// 9. VISUALIZATION
// =========================================================================
bgcolor(is_inside_day ? color.new(color.blue, 90) : na, title="Inside Day Alert")
plot(is_inside_day and (trade_dir == "Both" or trade_dir == "Long Only") ? d_high1 : na, "Long Breakout Level", color=color.green, style=plot.style_linebr, linewidth=2)
plot(is_inside_day and (trade_dir == "Both" or trade_dir == "Short Only") ? d_low1 : na, "Short Breakout Level", color=color.red, style=plot.style_linebr, linewidth=2)
````
