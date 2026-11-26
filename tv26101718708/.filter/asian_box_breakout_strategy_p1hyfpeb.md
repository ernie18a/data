# Asian Box Breakout Strategy

- url: https://www.tradingview.com/script/P1hYfpeB-Asian-Box-Breakout-Strategy/
- type: strategy
- pine_id: PUB;686f5d1381044f0bb7d8f8659bfae5c4
- version: 1.0

## Description

# Asian Box Breakout Strategy

The **Asian Box Breakout Strategy** is a session-based momentum breakout system designed to capture explosive price movements that often occur after the low-volatility Asian trading session.

The strategy builds a price range — known as the **Asian Box** — using the high and low formed during the Asian session, then trades breakouts when the market transitions into higher volatility trading hours such as the London or New York sessions.

This methodology is widely used in:

* Forex markets
* Crypto markets
* Indices
* Futures markets

where volatility expansion frequently follows overnight consolidation.

---

# 📌 Strategy Concept

The core idea behind the strategy is:

> **Trade momentum expansion after session consolidation.**

During the Asian session, markets often move within relatively tight ranges. As liquidity and participation increase during London and US sessions, price may aggressively break out from these ranges.

The strategy attempts to capture these directional moves automatically.

---

# 🌏 1. Asian Session Range Detection

The script continuously tracks the highest and lowest price during a predefined Asian trading session (UTC+7 timezone by default).

### Asian Box Components

* **Asian High** → Highest price during the session
* **Asian Low** → Lowest price during the session

These levels define the session breakout range.

The strategy visually plots these levels on the chart, creating the “Asian Box”.

---

# 🚀 2. Breakout Entry Logic

Once the Asian session ends and the trading session begins, the strategy places pending breakout stop orders.

### Long Breakout

* Buy stop order above the Asian High

### Short Breakout

* Sell stop order below the Asian Low

Supported trade modes:

* **Both Directions**
* **Long Only**
* **Short Only**

To reduce overtrading and duplicate signals:

* only **one trade per day** is allowed.

Once one side triggers:

* the opposite pending order is automatically cancelled.

---

# 💰 3. Position Sizing

The strategy uses a dynamic **100% equity allocation model**.

Position size is automatically calculated using:

* current account equity
* breakout entry price

This creates a fully compounding position sizing system where trade size adapts dynamically as account equity changes over time.

---

# 🛡️ 4. ATR-Based Stop Loss Management

Risk management is handled using the **Daily ATR (Average True Range)** to adapt stop loss distance to current market volatility.

Stop loss calculation:

SL\ Distance = Daily\ ATR \times Multiplier

### Long Position

* Stop Loss = Entry Price − ATR Distance

### Short Position

* Stop Loss = Entry Price + ATR Distance

Using ATR-based stops helps:

* avoid overly tight stops during volatile periods
* normalize risk across different market environments
* improve adaptability across instruments

---

# ⏰ 5. End-of-Day (EOD) Exit

To avoid overnight exposure and session gap risk, all open positions are automatically closed at the end of the trading session.

This keeps the strategy focused on:

* intraday momentum
* session volatility expansion
* short-term directional movement

---

# 🔔 6. Webhook Alert System

The script includes fully structured **JSON webhook alerts** for automation and external trade execution systems.

Alert payload includes:

* Strategy name
* Trading symbol
* Signal type
* Order action
* Entry/exit price
* Quantity
* Position size
* Net profit
* Win rate
* Account equity
* Timestamp

This allows seamless integration with:

* trading bots
* exchange APIs
* automation workflows
* copy trading systems

---

# ✨ Key Features

* Session-based breakout methodology
* Automatic Asian range detection
* Dynamic breakout stop entries
* ATR-based adaptive stop loss
* One-trade-per-day protection
* Automatic cancellation of opposite breakout order
* End-of-day auto close protection
* Webhook-ready JSON alerts
* Long-only / Short-only / Bi-directional modes
* Dynamic 100% equity position sizing

---

# 📈 Best Market Conditions

This strategy tends to perform best during:

✅ Trending market environments
✅ Volatility expansion phases
✅ Strong London session momentum
✅ Strong New York session momentum
✅ Post-consolidation breakouts

---

# ⚠️ Challenging Market Conditions

Performance may weaken during:

❌ Choppy sideways markets
❌ False breakout environments
❌ Extremely low-volatility sessions
❌ Range-bound market conditions

---

# ⚠️ Risk Disclaimer

This strategy uses aggressive capital allocation by deploying **100% of account equity per trade**.

While this approach may amplify returns during strong directional moves, it can also significantly increase drawdowns during adverse market conditions.

Before using this strategy in live trading, traders should carefully evaluate:

* leverage exposure
* slippage
* execution quality
* broker limitations
* personal risk tolerance

## Source Code

````pine
//@version=5
strategy("Asian Box Breakout [Antigravity] - Webhook Alert", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
trade_dir       = input.string("Both", title="Trade Direction", options=["Both", "Long Only", "Short Only"], group="Strategy Settings")
asian_session   = input.session("0500-1300", "Asian Session Time (UTC+7)", group="Time Settings")
trade_session   = input.session("1300-0400", "Trading Session (UTC+7)", group="Time Settings")
atr_length      = input.int(14, "Daily ATR Length", group="Risk Management")
sl_multiplier   = input.float(1.0, "Stop Loss (x Daily ATR)", step=0.1, group="Risk Management")

// =========================================================================
// 2. TIMEZONE & SESSIONS
// =========================================================================
in_asian_box  = not na(time(timeframe.period, asian_session, "Asia/Bangkok"))
in_trade_zone = not na(time(timeframe.period, trade_session, "Asia/Bangkok"))

// =========================================================================
// 3. ASIAN BOX CALCULATION
// =========================================================================
var float asian_high = na
var float asian_low  = na

if in_asian_box and not in_asian_box[1]
    asian_high := high
    asian_low  := low
else if in_asian_box
    asian_high := math.max(asian_high, high)
    asian_low  := math.min(asian_low, low)

// =========================================================================
// 4. DAILY ATR & POSITION SIZING (100% All-in)
// =========================================================================
d_atr = request.security(syminfo.tickerid, "D", ta.atr(atr_length)[1], lookahead=barmerge.lookahead_on)
sl_dist = d_atr * sl_multiplier

// คำนวณจำนวน Lot เพื่อให้ซื้อได้ 100% ของพอร์ต
long_qty  = asian_high > 0 ? strategy.equity / asian_high : 0
short_qty = asian_low > 0 ? strategy.equity / asian_low : 0

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
    msg = '{"strategy":"Asian Box Breakout","symbol":"' + syminfo.ticker + '","signal":"' + _signal + '","order_id":"' + _order_id + '","action":"' + _action + '","price":"' + str.tostring(_price, "#.####") + '","qty":"' + str.tostring(_qty, "#.####") + '","position_size":"' + str.tostring(strategy.position_size) + '","net_profit":"' + str.tostring(strategy.netprofit, "#.##") + '","win_rate":"' + str.tostring(win_rate, "#.##") + '","equity":"' + str.tostring(strategy.equity, "#.##") + '","time":"{{time}}"}'
    msg

// =========================================================================
// 7. TRADING LOGIC
// =========================================================================
var bool traded_today = false

// เคลียร์ค่าเมื่อเริ่ม Session เอเชียใหม่
if in_asian_box and not in_asian_box[1]
    traded_today := false
    strategy.cancel_all()

// วาง Pending Order เมื่อเข้าสู่ Trading Session
if in_trade_zone and not traded_today and strategy.position_size == 0 and not na(asian_high) and not na(asian_low)

    if trade_dir == "Both" or trade_dir == "Long Only"
        strategy.entry("Long Breakout", strategy.long, stop=asian_high, qty=long_qty, alert_message=f_alert("OPEN_LONG", "Long Breakout", "buy", asian_high, long_qty))

    if trade_dir == "Both" or trade_dir == "Short Only"
        strategy.entry("Short Breakout", strategy.short, stop=asian_low, qty=short_qty, alert_message=f_alert("OPEN_SHORT", "Short Breakout", "sell", asian_low, short_qty))

// เมื่อออเดอร์เปิดแล้ว ให้ล็อกสถานะและยกเลิกไม้ดักฝั่งตรงข้าม
if strategy.position_size != 0
    traded_today := true
    strategy.cancel_all()

// =========================================================================
// 8. EXITS (Stop Loss)
// =========================================================================
if strategy.position_size > 0
    sl_level_long = strategy.opentrades.entry_price(0) - sl_dist
    strategy.exit("Exit Long SL", "Long Breakout", stop=sl_level_long, alert_message=f_alert("CLOSE_LONG_SL", "Exit Long SL", "sell", sl_level_long, math.abs(strategy.position_size)))

if strategy.position_size < 0
    sl_level_short = strategy.opentrades.entry_price(0) + sl_dist
    strategy.exit("Exit Short SL", "Short Breakout", stop=sl_level_short, alert_message=f_alert("CLOSE_SHORT_SL", "Exit Short SL", "buy", sl_level_short, math.abs(strategy.position_size)))

// =========================================================================
// 9. EOD FORCE CLOSE
// =========================================================================
if not in_trade_zone and in_trade_zone[1] and strategy.position_size != 0
    strategy.close_all(comment="TP (EOD Close)", alert_message=f_alert("CLOSE_EOD", "TP (EOD Close)", strategy.position_size > 0 ? "sell" : "buy", close, math.abs(strategy.position_size)))

// =========================================================================
// 10. VISUALIZATION
// =========================================================================
bgcolor(in_asian_box ? color.new(color.gray, 90) : na, title="Asian Box Background")

plot(in_trade_zone and (trade_dir == "Both" or trade_dir == "Long Only") ? asian_high : na, title="Asian High", color=color.green, style=plot.style_linebr, linewidth=2)
plot(in_trade_zone and (trade_dir == "Both" or trade_dir == "Short Only") ? asian_low : na, title="Asian Low", color=color.red, style=plot.style_linebr, linewidth=2)
````
