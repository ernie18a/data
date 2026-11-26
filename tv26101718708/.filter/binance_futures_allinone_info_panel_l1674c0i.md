# Binance Futures All-in-One Info Panel

- url: https://www.tradingview.com/script/L1674C0I-Binance-Futures-All-in-One-Info-Panel/
- type: indicator
- pine_id: PUB;7a8e15a7421648b282155879de98cfdd
- version: 2.0

## Description

Trading Binance Futures requires keeping an eye on multiple critical metrics simultaneously. The Ultimate Binance Futures Data Hub consolidates the most essential on-chain and exchange data—Open Interest, Funding Rates, Long/Short Ratios, and Rolling Volumes—into a single, sleek, and highly customizable dashboard directly on your chart. Stop switching tabs and get all the actionable insights you need at a glance.

🔥 Key Features:

📊 Lightning-Fast Open Interest (O.I.):
We bypassed the standard chart timeframe delays. The O.I. data updates every 1 minute regardless of the timeframe you are on. It displays the absolute value, the dynamic change (▲/▼) compared to the previous bar, and the total notional value in USDT.

💸 Funding Rates (F.R.):
Displays both the Current Rate (CR) and the Previous Rate (PR) to help you gauge market sentiment and premium index shifts instantly.

⏱️ Dynamic Countdown (C.D.):
A precise countdown timer to the next funding fee. Since Binance occasionally changes funding intervals for highly volatile coins, this indicator supports 1H, 4H, and standard 8H intervals (easily selectable in settings).

📈 Real-Time Volume (Vol.):
Tracks the volume of the current active candle, highlighting the difference from the previous candle alongside its USDT equivalent.

🌍 24h Rolling Volume (24h Vol.):
Automatically calculates the true rolling 24-hour volume and its USDT value based on your current chart's timeframe.

⚖️ Official Long/Short Ratio (L/S):
Instead of relying on volume estimations, this dashboard pulls the official Binance Accounts Long/Short Ratio (_LSR) data. It features a dynamic red-to-green color gradient for quick visual sentiment analysis.

🔍 5-Minute O.I. Micro-Trend:
A unique mini-histogram embedded in the table! It displays the Open Interest trend of the last five 5-minute bars. This allows you to spot micro O.I. trends instantly, even if you are viewing a 1-Hour or 4-Hour chart.

⚙️ Customization & Settings:
We know every trader's chart layout is unique. This indicator is built to adapt to your style:

Positioning: Move the panel to any corner or middle section of your screen (Top-Right, Bottom-Left, etc.).

Size: Choose between Small, Normal, or Large text sizes to fit your resolution.

Colors: Fully customizable background colors for the left-side labels to match your specific chart theme (Dark or Light mode).

💡 How to use the Funding Interval Setting:
By default, most Binance coins use an 8-Hour funding interval. However, for highly volatile assets, Binance may lower this to 4H or 1H. TradingView cannot automatically detect this shift. If you are trading a coin with a modified schedule, simply go to the indicator settings and change the "Funding Interval" to 1H or 4H to keep the countdown perfectly synced.

If you find this tool helpful for your daily trading, please leave a 👍 boost and share your feedback in the comments!
#Binance #Futures #OpenInterest #FundingRate #Volume #Dashboard #LSRatio #Crypto

## Source Code

````pine
//@version=5
indicator("Binance Futures Bilgi Tablosu", overlay=true)

// --- AYARLAR ---
string pos_str = input.string("Sağ Üst", "Tablo Konumu", options=["Sağ Üst", "Sağ Alt", "Sol Üst", "Sol Alt", "Orta Sağ", "Orta Sol"], group="Görünüm Ayarları")
string size_str = input.string("Normal", "Tablo Boyutu", options=["Küçük", "Normal", "Büyük"], group="Görünüm Ayarları")
color label_bg_col = input.color(color.new(#2962ff, 50), "Sol Başlık Arka Plan Rengi", group="Görünüm Ayarları")
int fund_interval_h = input.int(4, "Fonlama Aralığı (Saat)", options=[1, 4, 8], tooltip="Binance periyodu değiştirdiğinde buradan manuel seçmelisiniz (TV otomatik tespit edemez).", group="Veri Ayarları")

string t_pos = pos_str == "Sağ Alt" ? position.bottom_right : pos_str == "Sol Üst" ? position.top_left : pos_str == "Sol Alt" ? position.bottom_left : pos_str == "Orta Sağ" ? position.middle_right : pos_str == "Orta Sol" ? position.middle_left : position.top_right
string t_size = size_str == "Küçük" ? size.small : size_str == "Büyük" ? size.large : size.normal

// --- 1. OPEN INTEREST (Açık Pozisyon) VERİSİ ---
oi_ticker = syminfo.prefix + ":" + syminfo.ticker + "_OI"
oi_data = request.security(oi_ticker, "1", close, ignore_invalid_symbol=true)
oi_prev = request.security(oi_ticker, timeframe.period, close[1], ignore_invalid_symbol=true)

float oi_diff = oi_data - oi_prev
string oi_arrow = oi_diff > 0 ? " ▲" : oi_diff < 0 ? " ▼" : " ▬"
color oi_color = oi_diff > 0 ? color.new(#00E676, 0) : oi_diff < 0 ? color.new(#FF5252, 0) : color.new(color.orange, 0)

string diff_str = oi_diff > 0 ? "+" + str.tostring(oi_diff, format.volume) : str.tostring(oi_diff, format.volume)
float oi_usdt = oi_data * close
string oi_usdt_str = na(oi_usdt) ? "" : " | " + str.tostring(oi_usdt, format.volume) + " USDT"
string oi_str = na(oi_data) ? "Veri Yok" : str.tostring(oi_data, format.volume) + oi_arrow + " (" + diff_str + ")" + oi_usdt_str

// --- 2. FUNDING RATE (GÜNCELLENDİ) ---
fr_ticker = syminfo.prefix + ":" + syminfo.ticker + "_FR"
cr_data = request.security(fr_ticker, timeframe.period, close, ignore_invalid_symbol=true)
pr_data = request.security(fr_ticker, str.tostring(fund_interval_h * 60), close[1], ignore_invalid_symbol=true)

// Virgülden sonra 5 basamak göstermesi için "0.00000" formatı eklendi
string cr_str = na(cr_data) ? "N/A" : str.tostring(cr_data * 100, "0.00000") + "%"
string pr_str = na(pr_data) ? "N/A" : str.tostring(pr_data * 100, "0.00000") + "%"
string fr_display = "CR: " + cr_str + " | PR: " + pr_str

// FR Değeri negatifse yeşil, pozitifse sarı renklendirme koşulu
color fr_color = na(cr_data) ? color.yellow : (cr_data < 0 ? color.new(#00E676, 0) : color.yellow)

// --- 3. FONLAMA GERİ SAYIMI ---
var int funding_interval = fund_interval_h * 60 * 60 * 1000 
int current_time = timenow
int next_funding_time = math.ceil(current_time / funding_interval) * funding_interval
int time_left = next_funding_time - current_time

int h = math.floor(time_left / 3600000)
int m = math.floor((time_left % 3600000) / 60000)
int s = math.floor((time_left % 60000) / 1000)
string countdown_str = str.format("{0,number,00}:{1,number,00}:{2,number,00}", h, m, s)
string interval_prefix = str.tostring(fund_interval_h) + "H / "

// --- 4. ANLIK HACİM (Mevcut Mum) ---
float current_vol = volume
float prev_vol = volume[1]
float vol_diff = current_vol - prev_vol

string vol_arrow = vol_diff > 0 ? " ▲" : vol_diff < 0 ? " ▼" : " ▬"
color vol_color = vol_diff > 0 ? color.new(#00E676, 0) : vol_diff < 0 ? color.new(#FF5252, 0) : color.new(color.orange, 0)

string vol_diff_str = vol_diff > 0 ? "+" + str.tostring(vol_diff, format.volume) : str.tostring(vol_diff, format.volume)
float vol_usdt = current_vol * close
string vol_usdt_str_disp = na(vol_usdt) ? "" : " | " + str.tostring(vol_usdt, format.volume) + " USDT"
string vol_str = str.tostring(current_vol, format.volume) + vol_arrow + " (" + vol_diff_str + ")" + vol_usdt_str_disp

// --- 5. 24 SAATLİK HACİM (Rolling 24h) ---
int sec_in_tf = timeframe.in_seconds("")
int bars_24h = sec_in_tf > 0 ? math.max(1, math.floor(86400 / sec_in_tf)) : 1
float vol_24h = math.sum(volume, bars_24h)
float vol_24h_usdt = math.sum(volume * close, bars_24h)

string vol_24h_str = str.tostring(vol_24h, format.volume) + " | " + str.tostring(vol_24h_usdt, format.volume) + " USDT"

// --- 6. LONG / SHORT ORANI ---
lsr_ticker = syminfo.prefix + ":" + syminfo.ticker + "_LSR"
lsr_data = request.security(lsr_ticker, timeframe.period, close, ignore_invalid_symbol=true)

float long_pct = 50.0
float short_pct = 50.0

if not na(lsr_data)
    long_pct := (lsr_data / (lsr_data + 1)) * 100
    short_pct := (1 / (lsr_data + 1)) * 100
else
    float buy_volume = (close >= open) ? volume : 0
    float sell_volume = (close < open) ? volume : 0
    float total_vol = ta.sma(buy_volume, 10) + ta.sma(sell_volume, 10)
    long_pct := total_vol > 0 ? (ta.sma(buy_volume, 10) / total_vol) * 100 : 50
    short_pct := total_vol > 0 ? (ta.sma(sell_volume, 10) / total_vol) * 100 : 50

// --- 7. 5 DAKİKALIK OI HISTOGRAMI ---
[oi5_0, oi5_1, oi5_2, oi5_3, oi5_4, oi5_5] = request.security(oi_ticker, "5", [close, close[1], close[2], close[3], close[4], close[5]], ignore_invalid_symbol=true)

float d0 = oi5_0 - oi5_1 
float d1 = oi5_1 - oi5_2
float d2 = oi5_2 - oi5_3
float d3 = oi5_3 - oi5_4
float d4 = oi5_4 - oi5_5 

f_bar_color(diff) => diff > 0 ? color.new(#00E676, 0) : diff < 0 ? color.new(#FF5252, 0) : color.new(color.gray, 0)
string d0_str = d0 > 0 ? "+" + str.tostring(d0, format.volume) : str.tostring(d0, format.volume)
string bar_char = "┃" 

// --- 8. TABLO OLUŞTURMA (UI) ---
var table info_table = table.new(t_pos, 7, 7, bgcolor=color.new(color.black, 80), border_color=color.gray, border_width=1)

if barstate.islast
    table.merge_cells(info_table, 1, 0, 6, 0) 
    table.merge_cells(info_table, 1, 1, 6, 1) 
    table.merge_cells(info_table, 1, 2, 6, 2) 
    table.merge_cells(info_table, 1, 3, 6, 3) 
    table.merge_cells(info_table, 1, 4, 6, 4) 
    table.merge_cells(info_table, 1, 5, 6, 5) 

    // OI Satırı (Row 0)
    table.cell(info_table, 0, 0, "O.I.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 0, oi_str, text_color=oi_color, text_halign=text.align_right, text_size=t_size)

    // FR Satırı (Row 1 - Renk GÜNCELLENDİ)
    table.cell(info_table, 0, 1, "F.R.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 1, fr_display, text_color=fr_color, text_halign=text.align_right, text_size=t_size)

    // Countdown Satırı (Row 2)
    table.cell(info_table, 0, 2, "C.D.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 2, interval_prefix + countdown_str, text_color=color.white, text_halign=text.align_right, text_size=t_size)

    // Anlık Hacim Satırı (Row 3)
    table.cell(info_table, 0, 3, "Vol.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 3, vol_str, text_color=vol_color, text_halign=text.align_right, text_size=t_size)

    // 24h Hacim Satırı (Row 4)
    table.cell(info_table, 0, 4, "24h Vol.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 4, vol_24h_str, text_color=color.white, text_halign=text.align_right, text_size=t_size)

    // L/S Satırı (Row 5)
    table.cell(info_table, 0, 5, "L/S", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 5, "L: %" + str.tostring(long_pct, "#.##") + " | S: %" + str.tostring(short_pct, "#.##"), text_color=color.from_gradient(long_pct, 0, 100, color.red, color.green), text_halign=text.align_right, text_size=t_size)

    // 5m OI Trend Satırı (Row 6)
    table.cell(info_table, 0, 6, "5m O.I.", text_color=color.white, bgcolor=label_bg_col, text_halign=text.align_left, text_size=t_size)
    table.cell(info_table, 1, 6, bar_char, text_color=f_bar_color(d4), text_size=t_size)
    table.cell(info_table, 2, 6, bar_char, text_color=f_bar_color(d3), text_size=t_size)
    table.cell(info_table, 3, 6, bar_char, text_color=f_bar_color(d2), text_size=t_size)
    table.cell(info_table, 4, 6, bar_char, text_color=f_bar_color(d1), text_size=t_size)
    table.cell(info_table, 5, 6, bar_char, text_color=f_bar_color(d0), text_size=t_size)
    table.cell(info_table, 6, 6, "(" + d0_str + ")", text_color=color.white, text_halign=text.align_right, text_size=t_size)
````
