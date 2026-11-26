# MTF Matrix Strategy

- url: https://www.tradingview.com/script/FQVb4qo4/
- type: strategy
- pine_id: PUB;1660e5407414485ebaad220c924df9b4
- version: 7.0

## Description

**MTF Matrix & Hybrid Strategy V2: Smart Trend & Ambush System**

> **⚠️ DISCLAIMER:** *This script and the following explanations are strictly for educational and algorithmic coding purposes. It is NOT financial or investment advice. Always backtest strategies thoroughly and apply your own risk management before using them in live markets.*

This strategy is designed to eliminate overtrading and only enter the market during the highest-probability moments. It strips away the noise of complex charts: it identifies a strong trend, waits for a discount, and protects your capital with a mathematical armor.

**How Does It Work? (3 Simple Steps)**

1. **Confirms the Direction (Trend Filter):** The system first checks the 5, 8, and 13 Simple Moving Averages (SMA). If they are aligned perfectly (5 > 8 > 13), it confirms a strong uptrend and activates its "Long-only" mode.
2. **Sets the Ambush (The Pullback):** A smart trader never buys the top (No FOMO). This strategy waits for the price to cool down and pull back to the **SMA 8** baseline. This specific zone is defined as the "Ambush Area".
3. **Pulls the Trigger (Candle Confirmation):** Once the price drops into the ambush zone, the system doesn't buy blindly. It waits for visual proof of a reversal using Price Action. It executes the trade only if it detects a valid reversal pattern like a Pin Bar, Engulfing, Doji, or Morning Star.

**How Does It Manage Risk? (Hybrid Exit Mechanism)**

Entering a trade is only half the battle; keeping the money is the real challenge. The system uses a two-layered defense:

* **Step-by-Step Profit Locking (D-Levels):** The algorithm calculates invisible Fibonacci targets (D1, D2, D3...) based on the Higher Timeframe (HTF). As the price climbs and breaches these levels, the system automatically trails your stop-loss up to the previous level, locking in your profits step-by-step.
* **Dynamic Trailing Stop (The Safety Net):** Just in case of sudden market crashes, it maintains a dynamic trailing stop based on a percentage (e.g., 2%) below the highest seen price. As the peak rises, the stop rises. If the price drops by that percentage, it closes the trade to secure gains or minimize losses.

**Customizable Features (Inputs)**
* **Ambush Sensitivity (ATR %):** Adjust how close the price needs to get to the moving average before triggering an entry. Widen or narrow the zone based on market volatility.
* **Price Action Filters:** Toggle specific candlestick patterns on or off based on your personal preference.
* **Live Dashboard:** A sleek panel on the top right gives you real-time visibility of your current stop price, HTF targets, and trade status at a single glance.

---

### 🇹🇷 TÜRKÇE AÇIKLAMA

**MTF Matrix & Hybrid Strategy V2: Akıllı Trend ve Pusu Sistemi**

> **⚠️ YASAL UYARI:** *Bu strateji kodu ve aşağıdaki açıklamalar tamamen algoritmik düşünce yapısını incelemek ve kodlama eğitimi amacıyla hazırlanmıştır. Kesinlikle finansal veya yatırım tavsiyesi (YTD) değildir. Gerçek piyasalarda işlem yapmadan önce sistemin matematiğini anlayın, test edin ve kendi risk yönetiminizi uygulayın.*

Bu strateji, piyasada sürekli işlem yapma hastalığını ortadan kaldırmak ve sadece "en güvenli" anlarda oyuna dahil olmak için tasarlanmıştır. Karmaşık grafik analizlerini bir kenara bırakır; güçlü bir trend bulur, fiyatın ucuzlamasını bekler ve kârı matematiksel bir zırhla korur. 

**Sistem Nasıl Çalışır? (3 Basit Adım)**

1. **Yönü Teyit Eder (Trend Filtresi):** Sistem ilk olarak 5, 8 ve 13 günlük Basit Hareketli Ortalamalara (SMA) bakar. Eğer bu üçü kusursuz bir sıraya dizilmişse (5 > 8 > 13), piyasanın güçlü bir yükseliş trendinde olduğunu anlar ve sadece "Alım" (Long) yönlü fırsat aramaya başlar.
2. **Pusuya Yatar (Geri Çekilme):** Usta bir avcı avının üzerine koşmaz, bekler. Bu strateji de fiyatlar zirvedeyken alım yapmaz (FOMO'yu engeller). Fiyatın, trendin dinlenme bölgesi olan **SMA 8** çizgisine doğru geri çekilmesini bekler. Bu bölge sistemin "Pusu Alanı"dır.
3. **Tetiği Çeker (Mum Onayı):** Fiyat pusu alanına geldiğinde sistem körü körüne alım yapmaz. Dönüşün başladığını kanıtlayan bir Price Action (Fiyat Hareketi) mumu arar. Pin Bar, Yutan Mum (Engulfing), Doji veya Sabah Yıldızı formasyonlarından birini gördüğü an işleme girer.

**Riski Nasıl Yönetir? (Hibrit Çıkış Mekanizması)**

İşleme girmek işin sadece yarısıdır, asıl marifet parayı korumaktır. Sistem bu noktada devreye iki katmanlı bir zırh sokar:

* **Adım Adım Kâr Kilitleme (D-Seviyeleri):** Sistem, üst zaman diliminden (HTF) aldığı verilerle görünmez Fibonacci hedefleri (D1, D2, D3...) çizer. Fiyat yükselip bu hedefleri aştıkça, zarar kes (stop-loss) seviyenizi bir alt kademeye taşır. Böylece kazandığınız kârı piyasaya geri vermezsiniz.
* **Dinamik İzleyen Stop (Emniyet Kemeri):** İşler ters giderse diye, fiyatın gördüğü en yüksek zirveden belirlediğiniz bir yüzde (örn: %2) gerisine dinamik bir stop koyar. Zirve yükseldikçe stop da yükselir; fiyat aniden %2 düşerse işlemi kârla veya minimum zararla kapatır.

**Kullanıcı Dostu Özellikler (Ayarlar)**
* **Pusu Hassasiyeti (Ambush Sensitivity):** Fiyatın ortalamaya ne kadar yaklaşması gerektiğini ayarlarsınız. Piyasaya göre alanı daraltıp genişletebilirsiniz.
* **Fiyat Hareketi (PA) Filtreleri:** İstemediğiniz mum formasyonlarını ayarlardan kapatıp sadece güvendiklerinizle işlem yapabilirsiniz.
* **Bilgi Panosu (Dashboard):** Sağ üst köşedeki şık panel sayesinde anlık stop seviyenizi, hedeflerinizi ve piyasa durumunu tek bakışta görürsünüz.

## Source Code

````pine
//@version=5
strategy("MTF Matrix Strategy  RSI Divergence", shorttitle="MTF_Strat", overlay=true, initial_capital=100000, default_qty_type=strategy.fixed, default_qty_value=1, commission_type=strategy.commission.percent, commission_value=0.04, calc_on_every_tick=true, process_orders_on_close=false)

// ========================================================================= //
// 1. INPUTS & SETTINGS
// ========================================================================= //

grp_view = "DISPLAY SETTINGS"
show_dashboard = input.bool(true, "Show Top-Right Dashboard", group=grp_view)

grp_tf = "TIMEFRAME SETTINGS"
htf = input.timeframe("60", "Target Timeframe (D Levels)", group=grp_tf)

grp_tech = "TECHNICAL SETTINGS"
atr_per      = input.int(14, "ATR Period", group=grp_tech)
pusu_pct_in  = input.float(20.0, "Ambush Sensitivity (%)", minval=0, step=1, group=grp_tech)

// RSI Divergence Filter Settings
grp_div = "RSI DIVERGENCE FILTER"
use_div_filter = input.bool(true, "Enable Negative Divergence Filter", group=grp_div)
rsi_len        = input.int(14, "RSI Period", group=grp_div)
div_lookback   = input.int(7, "Pivot Lookback (Default: 7)", group=grp_div, tooltip="Number of bars to confirm high/low peaks. Higher value means more stable but slower detection.")

grp_exec  = "EXECUTION SETTINGS"
fast_mode = input.bool(false, "Fast Mode (Instant Entry)", group=grp_exec)

grp_risk = "RISK MANAGEMENT"
use_hybrid_ts = input.bool(true, "Hybrid Trailing Stop", group=grp_risk)
trail_percent = input.float(2.0, "Trailing Distance (%)", step=0.1, minval=0.1, group=grp_risk)

grp_pa = "PRICE ACTION FILTERS"
useMStar  = input.bool(true, "Morning Star", group=grp_pa)
useEngulf = input.bool(true, "Bullish Engulfing", group=grp_pa)
useHarami = input.bool(true, "Inside Bar (Harami)", group=grp_pa)
usePinbar = input.bool(true, "Pin Bar", group=grp_pa)
useDoji   = input.bool(true, "Doji", group=grp_pa)

// ========================================================================= //
// 2. CALCULATIONS
// ========================================================================= //

// Moving Averages
sma5   = ta.sma(close, 5)
sma8   = ta.sma(close, 8)
sma13  = ta.sma(close, 13)
ema21  = ta.ema(close, 21)
ema34  = ta.ema(close, 34)
ema55  = ta.ema(close, 55)
ema89  = ta.ema(close, 89)
ema100 = ta.ema(close, 100)
ema144 = ta.ema(close, 144)
ema200 = ta.ema(close, 200)
ema233 = ta.ema(close, 233)

// Plot MAs
plot(sma5,   color=color.rgb(255, 255, 255, 50), title="SMA 5")
plot(sma8,   color=color.yellow, title="SMA 8")
plot(sma13,  color=color.orange, title="SMA 13")
plot(ema21,  color=color.red,    title="EMA 21")
plot(ema34,  color=color.rgb(233, 30, 99), title="EMA 34")
plot(ema55,  color=color.purple, title="EMA 55")
plot(ema89,  color=color.blue,   title="EMA 89")
plot(ema100, color=color.aqua,   title="EMA 100")
plot(ema144, color=color.rgb(0, 250, 154), title="EMA 144")
plot(ema200, color=color.lime,   title="EMA 200")
plot(ema233, color=color.rgb(205, 220, 57), title="EMA 233")

// HTF Pivot Levels (D Levels)
[h_htf, l_htf, c_htf] = request.security(syminfo.tickerid, htf, [high[1], low[1], close[1]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pv   = (h_htf + l_htf + c_htf) / 3.0
diff = h_htf - l_htf
safe_diff = diff == 0 ? syminfo.mintick : diff

d1 = pv + safe_diff * 0.382
d2 = pv + safe_diff * 0.618
d3 = pv + safe_diff * 1.0
d4 = pv + safe_diff * 1.618
d5 = pv + safe_diff * 2.618

// --- RSI NEGATIVE DIVERGENCE LOGIC ---
rsi_val = ta.rsi(close, rsi_len)
ph = ta.pivothigh(high, div_lookback, div_lookback)

var float last_ph = na
var float prev_ph = na
var float last_rsi_peak = na
var float prev_rsi_peak = na
var bool has_neg_div = false

if not na(ph)
    prev_ph := last_ph
    last_ph := ph
    prev_rsi_peak := last_rsi_peak
    last_rsi_peak := rsi_val[div_lookback]
    
    // Condition: Price makes Higher High while RSI makes Lower High
    if last_ph > prev_ph and last_rsi_peak < prev_rsi_peak
        has_neg_div := true
    else
        has_neg_div := false

// Reset divergence filter if price breaks below SMA13 (Trend Reset)
if ta.crossunder(close, sma13)
    has_neg_div := false

// --- STRATEGY LOGIC ---
isTrend = sma5 > sma8 and sma8 > sma13
isZone  = isTrend and (low <= sma8 + (ta.atr(atr_per) * (pusu_pct_in / 100)))

mBody = math.abs(close - open)
lWick = math.min(open, close) - low
uWick = high - math.max(open, close)

f_star = useMStar  and (close[2] < open[2] and math.abs(close[1]-open[1]) < (math.abs(close[2]-open[2])*0.5) and close > open and close > (open[2]+close[2])/2)
f_eng  = useEngulf and (close > open and close[1] < open[1] and close > open[1])
f_har  = useHarami and (high < high[1] and low > low[1] and close > open)
f_pin  = usePinbar and (lWick > (mBody * 2) and lWick > uWick) 
f_doj  = useDoji   and (math.abs(close - open) <= ((high - low) * 0.1))

pa_type   = f_star ? "BUY-Star" : f_eng ? "BUY-Eng" : f_har ? "BUY-Har" : f_pin ? "BUY-Pin" : f_doj ? "BUY-Doj" : "None"

// Signal with optional Divergence Filter
buySignal = isZone and pa_type != "None" and (use_div_filter ? not has_neg_div : true)
entry_confirmed = fast_mode ? true : barstate.isconfirmed

// Visual feedback for divergence zones
bgcolor(use_div_filter and has_neg_div and isTrend ? color.new(color.red, 90) : na, title="Divergence Risk Zone")

// ========================================================================= //
// 3. STATE & EXECUTION
// ========================================================================= //

var float stop_px = na
var float max_seen_price = na
var string trade_status = "WAITING"
var string last_alert_status = "WAITING" 

// --- EXIT HANDLING & RESET ---
if ta.change(strategy.position_size) < 0
    alert("🛑 EXIT: Trade Closed. Price: " + str.tostring(close), alert.freq_once_per_bar)
    last_alert_status := "WAITING"
    trade_status := "WAITING"
    stop_px := na
    max_seen_price := na

// --- ACTIVE POSITION MANAGEMENT ---
if strategy.position_size > 0
    if trade_status == "WAITING" or trade_status == "ENTRY PENDING"
        trade_status := "ACTIVE"

    max_seen_price := math.max(high, nz(max_seen_price, high))
    float percent_stop_level = max_seen_price * (1 - trail_percent / 100)
    float entry_px = strategy.position_avg_price
    
    if high >= d1 and stop_px < entry_px
        stop_px := entry_px
        trade_status := "TRAILING (Entry)"
    if high >= d2 and stop_px < d1
        stop_px := d1
        trade_status := "TRAILING (D1)"
    if high >= d3 and stop_px < d2
        stop_px := d2
        trade_status := "TRAILING (D2)"
    if high >= d4 and stop_px < d3
        stop_px := d3
        trade_status := "TRAILING (D4)"

    if use_hybrid_ts and percent_stop_level > stop_px
        stop_px := percent_stop_level
        trade_status := "TRAILING (%)"

    if trade_status != last_alert_status and trade_status != "ACTIVE" and trade_status != "WAITING" and trade_status != "ENTRY PENDING"
        alert("🛡️ " + trade_status + " | SL: " + str.tostring(stop_px, "#.##"), alert.freq_once_per_bar)
        last_alert_status := trade_status

// --- FLAT STATE HANDLING ---
if strategy.position_size == 0
    if trade_status != "ENTRY PENDING"
        trade_status := "WAITING"
        max_seen_price := na
        stop_px := na

// --- NEW ENTRY TRIGGER ---
if buySignal and entry_confirmed and strategy.position_size == 0
    stop_px := low * (1 - trail_percent / 100)
    max_seen_price := high
    strategy.entry("LONG", strategy.long, comment=pa_type)
    trade_status := "ENTRY PENDING"
    
    alert_msg = "🚀 ENTRY: " + pa_type + "\nPrice: " + str.tostring(close) + "\nStop (SL): " + str.tostring(stop_px, "#.##") + "\nTarget (TP): " + str.tostring(d5, "#.##")
    alert(alert_msg, alert.freq_once_per_bar)
    last_alert_status := "ACTIVE"

// --- ORDER COMMANDS ---
strategy.exit("EXIT", "LONG", limit=d5, stop=stop_px, comment_loss=trade_status, comment_profit="TARGET REACHED")

// ========================================================================= //
// 4. MINIMALIST DASHBOARD
// ========================================================================= //
var table main_tbl = table.new(position.top_right, 2, 11, border_width=1, border_color=color.rgb(50, 50, 50))
if (barstate.islastconfirmedhistory or barstate.isrealtime) and show_dashboard
    table.cell(main_tbl, 0, 0, "Ticker", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 0, syminfo.ticker, bgcolor=color.black, text_color=color.yellow, text_size=size.small)
    table.cell(main_tbl, 0, 1, "Status", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 1, trade_status, bgcolor=color.black, text_color=color.lime, text_size=size.small)
    table.cell(main_tbl, 0, 2, "Entry", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 2, strategy.position_size > 0 ? str.tostring(strategy.position_avg_price, "#.##") : "-", bgcolor=color.black, text_color=color.aqua, text_size=size.small)
    table.cell(main_tbl, 0, 3, "Stop", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 3, na(stop_px) ? "-" : str.tostring(stop_px, "#.##"), bgcolor=color.black, text_color=color.red, text_size=size.small)
    
    // Dashboard RSI Status
    div_status_text = has_neg_div ? "WARNING (Neg. Div)" : "CLEAN"
    div_status_color = has_neg_div ? color.red : color.gray
    table.cell(main_tbl, 0, 4, "RSI Filter", bgcolor=color.rgb(20, 20, 20), text_color=color.gray, text_size=size.small)
    table.cell(main_tbl, 1, 4, div_status_text, bgcolor=color.rgb(20, 20, 20), text_color=div_status_color, text_size=size.small)
    
    tf_lbl = "(" + htf + ")"
    table.cell(main_tbl, 0, 5, "D1 " + tf_lbl, bgcolor=color.rgb(0, 40, 40), text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 5, str.tostring(d1, "#.##"), bgcolor=color.rgb(0, 40, 40), text_color=color.aqua, text_size=size.small)
    table.cell(main_tbl, 0, 6, "D2 " + tf_lbl, bgcolor=color.rgb(0, 40, 40), text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 6, str.tostring(d2, "#.##"), bgcolor=color.rgb(0, 40, 40), text_color=color.aqua, text_size=size.small)
    table.cell(main_tbl, 0, 7, "D3 " + tf_lbl, bgcolor=color.rgb(0, 40, 40), text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 7, str.tostring(d3, "#.##"), bgcolor=color.rgb(0, 40, 40), text_color=color.aqua, text_size=size.small)
    table.cell(main_tbl, 0, 8, "D4 " + tf_lbl, bgcolor=color.rgb(0, 40, 40), text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 8, str.tostring(d4, "#.##"), bgcolor=color.rgb(0, 40, 40), text_color=color.aqua, text_size=size.small)
    table.cell(main_tbl, 0, 9, "D5 " + tf_lbl, bgcolor=color.rgb(0, 40, 40), text_color=color.white, text_size=size.small)
    table.cell(main_tbl, 1, 9, str.tostring(d5, "#.##"), bgcolor=color.rgb(0, 40, 40), text_color=color.aqua, text_size=size.small)
````
