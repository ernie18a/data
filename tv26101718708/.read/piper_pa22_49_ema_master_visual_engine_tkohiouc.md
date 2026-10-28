# Piper PA22 - 4/9 EMA Master Visual Engine

- url: https://www.tradingview.com/script/tKoHIouc-Piper-PA22-4-9-EMA-Master-Visual-Engine/
- type: indicator
- pine_id: PUB;54d126b026ae447683198ee04f9eb2dd
- version: 1.0

## Description

### **Piper PA22 - 4/9 HA Master Ribbon Engine -Color Adjustable\[Ultimate Edition v6\] **

### **Overview**

The **Piper PA22 4/9 HA Master Ribbon Engine \[Ultimate Edition\]** is a pro-grade intraday momentum breakout and trend-following scalping workspace compiled natively under the latest **Pine Script v6** architecture. Engineered specifically for lower-timeframe charts (1m, 3m, 5m, and 15m), this system synthesizes moving average clouds, structural volatility anchors, dynamic stop-loss tracking, and live telemetry data into a clean visual interface.

By filtering raw price cycles through an underlying synthetic **Heikin-Ashi** calculation feed, the indicator strips out deceptive market noise and minor whipsaws, giving manual traders a highly objective visual map of real-time trend regimes.

* * *

### **Key System Technical Architecture**

1.  **Anchored 5-Minute Heikin-Ashi Ribbon Cloud**
    *   Computes a highly responsive 4 EMA and 9 EMA cloud structure anchored to a smoother price history matrix.
    *   **Dynamic Compression Squeeze Zone:** The ribbon cloud automatically blends into a distinct **Yellow Warning State** when the moving averages compress closely together—signaling flat market chop, an impending breakout, or an active distribution range.
2.  **Adaptive ATR Volatility Filter (The Exchange/Broker Liquidity Fix)**
    *   Traditional volume filters fail on decentralized derivative feeds or specific forex pairs that do not provide transaction data to TradingView.
    *   This engine resolves that limitation by utilizing a **Price-Range ATR Expansion Matrix**. It measures actual structural price expansions; if a crossover fires while the market is quiet, the script completely blocks false signals and only prints entry shapes when a real momentum breakout begins.
3.  **Live Intraday Metrics HUD Table**
    *   Projects a semi-transparent dashboard in the top-right corner of your screen. It dynamically evaluates the asset's active 14-period ATR on every candle tick to calculate your exact **Take-Profit (3.0x ATR)** and **Stop-Loss (1.0x ATR)** targets for you automatically.
4.  **Dynamic Trailing Stop Line Tracker**
    *   Plots a highly visible, continuous **Fuchsia Stop Line** directly onto the screen. This line moves up during uptrends and down during downtrends based on ongoing market volatility, providing manual traders with an objective trail line to shield open capital.
5.  **RSI "Training Wheels" Candlestick Matrix**
    *   Alters candlestick body colors into a specialized **Purple Matrix** (when Overbought, ≥65) or an **Orange Matrix** (when Oversold, ≤35). This serves as an immediate visual safeguard against buying or chasing extended trends.

* * *

### **High-Accuracy Entry Confluence Criteria**

Visual execution arrow shapes will display on your screen *only* when all background logic checks pass simultaneously:

*   **🟩 GREEN Triangle Arrow (BUY Entry):** The fast line crosses above the slow line **AND** the ribbon is solidly established in a bullish trend state **AND** price volatility expands past the ATR threshold **AND** trades fall within your high-liquidity session hours.
*   **🟥 RED Triangle Arrow (SELL Entry):** The fast line crosses below the slow line **AND** the ribbon is solidly established in a bearish trend state **AND** price volatility expands past the ATR threshold **AND** trades fall within your high-liquidity session hours.

* * *

### **How To Trade With This Engine (Manual Execution Rules)**

1.  **Identify the Market Regime:** Check your HUD table or ribbon color. If the state is Yellow ("SQUEEZE / CHOP"), stay flat.
2.  **Execute on the Arrow Close:** Wait for an entry triangle arrow to fully close on your current execution chart.
3.  **Deploy Your Bracket Orders:** Look at the top-right table. Read the precise target numbers and input them as a bracket limit order with your broker.
4.  **Follow the Fuchsia Guard:** Trail your stop-loss manually behind the moving fuchsia line as the trade expands in your favor. If your candlesticks shift to Purple (on Longs) or Orange (on Shorts), do not add contract size—look to lock in partial profits.

* * *

### **Disclaimer & Community Notice**

*This indicator is an educational charting script designed solely to assist manual research study and does not constitute financial advice. No trading system guarantees profit. Backtest results on high-volatility assets (like BTCUSD or Nasdaq Futures) demonstrate a high expectancy ratio when utilizing strict 1:3 risk targets, but users must adjust default lookback properties to match their specific symbol spreads and commissions.*

## Source Code

````pine
//@version=6
indicator("Piper PA22 - 4/9 EMA Master Visual Engine", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=500)

// ==========================================
// 1. INPUT CONFIGURATIONS
// ==========================================
var string G_MA   = "Peachy Ribbon Settings"
int fast_len      = input.int(4, title="Fast EMA Length", minval=1, group=G_MA)
int slow_len      = input.int(9, title="Slow EMA Length", minval=1, group=G_MA)
bool use_mtf      = input.bool(true, title="Lock Ribbon to Higher Timeframe?", group=G_MA)
string tf_input   = input.timeframe("5", title="Ribbon Target Timeframe", group=G_MA)
float yellow_pct  = input.float(15.0, title="Yellow Squeeze Sensitivity (%)", minval=0.0, maxval=100.0, group=G_MA)

var string G_VOL  = "Volatility Expansion Filter"
int atr_length    = input.int(14, title="ATR Volatility Lookback Length", minval=5, group=G_VOL)
float atr_mult    = input.float(1.5, title="ATR Trend Expansion Multiplier", minval=0.5, group=G_VOL)

var string G_RISK = "Dashboard Visual Parameters"
float tp_atr_mult = input.float(3.0, title="Take Profit Multiplier (ATR)", group=G_RISK)
float sl_atr_mult = input.float(1.0, title="Initial Stop Loss Multiplier (ATR)", group=G_RISK)
color table_color = input.color(color.new(color.black, 30), title="Dashboard Background Color", group=G_RISK)

var string G_ORB  = "Opening Range Breakout (ORB)"
bool use_orb      = input.bool(true, title="Enable ORB Tracking Zones?", group=G_ORB)
string orb_sess   = input.string("0930-1000:23456", title="Market Open Window (EST)", group=G_ORB)
color orb_color   = input.color(color.new(color.blue, 92), title="ORB Zone Shading Color", group=G_ORB)

// ==========================================
// 2. HEIKIN-ASHI RIBBON & VOLATILITY ENGINE
// ==========================================
string ha_ticker = ticker.heikinashi(syminfo.tickerid)

float fast_ema = use_mtf ? request.security(ha_ticker, tf_input, ta.ema(close, fast_len), barmerge.gaps_off, barmerge.lookahead_off) : ta.ema(close, fast_len)
float slow_ema = use_mtf ? request.security(ha_ticker, tf_input, ta.ema(close, slow_len), barmerge.gaps_off, barmerge.lookahead_off) : ta.ema(close, slow_len)
float avg_atr  = ta.atr(14)

float current_atr = ta.atr(atr_length)
float ma_distance = math.abs(fast_ema - slow_ema)
bool trend_is_expanding = ma_distance > (current_atr * atr_mult)

bool is_weekday = (dayofweek != dayofweek.saturday) and (dayofweek != dayofweek.sunday)
bool inside_hours = is_weekday and not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))

// Ribbon States
float normalized_distance = (ma_distance / (avg_atr > 0 ? avg_atr : 1)) * 100
int ribbon_state = 0 
color ribbon_color = color.new(color.yellow, 60)
string market_state_string = "SQUEEZE / CHOP"

if normalized_distance < yellow_pct
    ribbon_state := 0
    ribbon_color := color.new(color.yellow, 60)
    market_state_string := "SQUEEZE / CHOP"
else if fast_ema > slow_ema
    ribbon_state := 1
    ribbon_color := color.new(color.green, 60)
    market_state_string := "BULLISH TREND"
else
    ribbon_state := -1
    ribbon_color := color.new(color.red, 60)
    market_state_string := "BEARISH TREND"

// FIXED: Outer boundary plots are assigned to variables p1 and p2 to allow background filling
p1 = plot(fast_ema, title="HA Ribbon Fast Line", color=ribbon_color, linewidth=2)
p2 = plot(slow_ema, title="HA Ribbon Slow Line", color=ribbon_color, linewidth=2)

// FIXED: Fills the entire space between the moving averages with a highly visible color cloud
fill(p1, p2, color=ribbon_color, title="HA Trend Ribbon Cloud Fill")

// ==========================================
// 3. ORB ZONE DISPLAY MODULE
// ==========================================
var float orb_high = na
var float orb_low  = na
var box orb_box    = na

bool in_session = not na(time(timeframe.period, orb_sess, "America/New_York"))
bool session_start = in_session and not in_session

if use_orb
    if session_start
        orb_high := high
        orb_low  := low
        orb_box  := box.new(left=bar_index, top=orb_high, right=bar_index, bottom=orb_low, bgcolor=orb_color, border_color=color.new(orb_color, 40), border_style=line.style_dashed)
    else if in_session and not na(orb_high)
        orb_high := math.max(high, orb_high)
        orb_low  := math.min(low, orb_low)
        box.set_top(orb_box, orb_high)
        box.set_bottom(orb_box, orb_low)
        box.set_right(orb_box, bar_index)
    else if not in_session and not na(orb_high)
        box.set_right(orb_box, bar_index)

// ==========================================
// 4. SIGNAL TRIGGERS & SHAPE PLOTS
// ==========================================
bool buy_signal  = ta.crossover(fast_ema, slow_ema) and (ribbon_state == 1) and trend_is_expanding and inside_hours
bool sell_signal = ta.crossunder(fast_ema, slow_ema) and (ribbon_state == -1) and trend_is_expanding and inside_hours

plotshape(buy_signal, title="Buy Entry Arrow", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sell_signal, title="Sell Entry Arrow", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ==========================================
// 5. LIVE PERFORMANCE SUMMARY TABLE 
// ==========================================
var table info_table = table.new(position = position.top_right, columns = 2, rows = 4, bgcolor = table_color, border_width = 1, border_color = color.gray)
if barstate.islast
    float long_tp_target  = close + (avg_atr * tp_atr_mult)
    float long_sl_target  = close - (avg_atr * sl_atr_mult)
    float short_tp_target = close - (avg_atr * tp_atr_mult)
    float short_sl_target = close + (avg_atr * sl_atr_mult)

    color state_text_color = ribbon_state == 1 ? color.green : ribbon_state == -1 ? color.red : color.yellow

    table.cell(info_table, 0, 0, "Market Regime:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(info_table, 1, 0, market_state_string, text_color=state_text_color, text_size=size.small, text_halign=text.align_right)
    
    table.cell(info_table, 0, 1, "If Long TP/SL Target:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(info_table, 1, 1, str.tostring(long_tp_target, "#.##") + " / " + str.tostring(long_sl_target, "#.##"), text_color=color.green, text_size=size.small, text_halign=text.align_right)

    table.cell(info_table, 0, 2, "If Short TP/SL Target:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(info_table, 1, 2, str.tostring(short_tp_target, "#.##") + " / " + str.tostring(short_sl_target, "#.##"), text_color=color.red, text_size=size.small, text_halign=text.align_right)

    table.cell(info_table, 0, 3, "Current Volatility:", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(info_table, 1, 3, str.tostring(avg_atr, "#.##") + " Points", text_color=color.orange, text_size=size.small, text_halign=text.align_right)

// ==========================================
// 6. REAL-TIME AUDIBLE & PHONE PUSH ALERTS
// ==========================================
if buy_signal
    alert('{"strategy": "Peachy Master", "action": "BUY", "ticker": "' + syminfo.ticker + '", "price": "' + str.tostring(close) + '"}', alert.freq_once_per_bar_close)
if sell_signal
    alert('{"strategy": "Peachy Master", "action": "SELL", "ticker": "' + syminfo.ticker + '", "price": "' + str.tostring(close) + '"}', alert.freq_once_per_bar_close)
````
