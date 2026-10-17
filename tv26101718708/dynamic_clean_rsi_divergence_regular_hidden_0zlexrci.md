# Dynamic Clean RSI Divergence (Regular & Hidden)

- url: https://www.tradingview.com/script/0ZlEXrCI-Dynamic-Clean-RSI-Divergence-Regular-Hidden/
- type: indicator
- pine_id: PUB;feeeb32189d640ae8b4bb98c28c5c628
- version: 6.0

## Description

Most divergence indicators on TradingView clutter your screen by leaving every historical divergence line on the chart. This indicator is specifically designed for traders who prefer a minimalist and clean workspace. The Dynamic Clean RSI Divergence indicator scans the market dynamically and plots only the most recent valid divergences on your chart. Once a new divergence is confirmed, the old one is automatically removed, keeping your focus purely on the current price action.

It effectively detects both Regular and Hidden (Irregular) divergences using Pivot High/Low points and works flawlessly across all timeframes.

Key Features

Zero Chart Clutter: Only the last confirmed bullish and bearish divergence lines are kept on the screen.

Regular & Hidden Divergences: Scans for trend-reversal (regular) and trend-continuation (hidden) divergences simultaneously.

Visual Clarity: Uses distinct line styles and labels to instantly identify the type of divergence:

Bull (Solid Green Line): Regular Bullish Divergence

Bear (Solid Red Line): Regular Bearish Divergence

H-Bull (Dashed Green Line): Hidden Bullish Divergence

H-Bear (Dashed Red Line): Hidden Bearish Divergence

Fully Customizable: You can adjust the RSI Length, RSI Moving Average Length, and the Pivot Lookback (Left/Right bars) to fine-tune the sensitivity according to your trading strategy.

How to Set It Up (Important)
Due to TradingView’s standard limitations, a single indicator script cannot dynamically draw lines on both the main price chart and a separate lower oscillator pane at the same time. To achieve the perfect visual setup where divergences are connected on both the price action and the RSI oscillator, you need to apply the indicator twice.

Follow these exact steps:

Step 1: Apply to the Main Chart (Price Action)

Add the indicator to your chart.

By default, the settings are configured for the main chart. It will automatically draw the divergence lines connecting the highs and lows of the candlesticks.

Step 2: Apply to the Lower Pane (RSI View)

Add the exact same indicator to your chart a second time. It will temporarily overlay on top of your price chart.

Open the Settings of this second indicator.

Under the Inputs tab, find the "Çizim Yeri" (Drawing Location) setting and change it from "Grafik (Fiyat)" to "RSI Alt Penceresi".

Now, hover your mouse over the name of this second indicator in the top-left corner of your chart.

Click on the Three Dots (...) for the "More" menu.

Hover over "Move to" and select "New pane below".

Result: You will now have a beautifully synchronized setup with a fully styled RSI (Purple line, Yellow MA, and shaded 30-70 background) in the bottom pane, and divergence lines perfectly mirroring each other on both the price and the RSI!

## Source Code

````pine
//@version=5
indicator("Dynamic Clean RSI Divergence (Regular & Hidden) V5", overlay=true, max_lines_count=10, max_labels_count=10)

// --- MAIN SETTINGS ---
len = input.int(14, title="RSI Length", group="Main Settings")
pivot_left = input.int(5, title="Pivot Lookback Left", group="Main Settings")
pivot_right = input.int(5, title="Pivot Lookback Right", group="Main Settings")

// Draw mode selection
draw_mode = input.string("Main Chart (Price)", title="Drawing Location", options=["Main Chart (Price)", "RSI Lower Pane"], group="Main Settings")
is_price_mode = draw_mode == "Main Chart (Price)"

rsi_ma_len = input.int(14, title="RSI MA Length", group="Main Settings")

// --- ALERT SETTINGS ---
chat_id = input.string("", title="Telegram Chat ID", group="Alert Settings (Telegram Webhook)")
thread_id = input.string("", title="Telegram Topic (Thread) ID (Opsiyonel)", group="Alert Settings (Telegram Webhook)", tooltip="Eğer mesajın gruptaki belirli bir alt konuya (topic) gitmesini istiyorsan, o konunun ID rakamını buraya yaz (Örn: 15). Normal gruba veya kişiye atıyorsan boş bırak.")

// Thread ID JSON String Oluşturucu
thread_str = thread_id != "" ? '"message_thread_id": ' + thread_id + ', ' : ''

// --- ZAMAN DİLİMİ (TIMEFRAME) ÇEVİRİCİ ---
readable_tf = switch timeframe.period
    "1" => "1m"
    "3" => "3m"
    "5" => "5m"
    "15" => "15m"
    "30" => "30m"
    "45" => "45m"
    "60" => "1h"
    "120" => "2h"
    "240" => "4h"
    "D" => "1D"
    "1D" => "1D"
    "W" => "1W"
    "1W" => "1W"
    => timeframe.period // Listede yoksa orijinalini yaz

// URL Oluşturucular (Binance ve TradingView Linkleri İçin)
clean_ticker = syminfo.basecurrency + syminfo.currency
binance_url = "https://www.binance.com/tr/futures/" + clean_ticker
tv_url = "https://www.tradingview.com/chart/?symbol=" + syminfo.prefix + ":" + syminfo.ticker

// --- RSI DISPLAY SETTINGS ---
rsi_col = input.color(color.new(#7E57C2, 0), title="RSI Line Color & Opacity", group="RSI Display Settings")
rsi_ma_col = input.color(color.new(#FFEB3B, 0), title="RSI MA Line Color & Opacity", group="RSI Display Settings")
rsi_bg_col = input.color(color.new(#7E57C2, 90), title="RSI Background Color & Opacity", group="RSI Display Settings")
rsi_band_col = input.color(color.new(#787B86, 50), title="RSI Bands Color & Opacity", group="RSI Display Settings")

// --- DIVERGENCE CUSTOMIZATION SETTINGS ---

// 1. Regular Bullish
reg_bull_text = input.string("Bull", title="Label Text", group="Regular Bullish Divergence")
reg_bull_col = input.color(color.new(color.green, 0), title="Line & Label BG Color", group="Regular Bullish Divergence")
reg_bull_txt_col = input.color(color.white, title="Label Text Color", group="Regular Bullish Divergence")
reg_bull_width = input.int(2, title="Line Width", minval=1, maxval=5, group="Regular Bullish Divergence")
reg_bull_style_str = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Regular Bullish Divergence")
reg_bull_style = reg_bull_style_str == "Solid" ? line.style_solid : reg_bull_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// 2. Regular Bearish
reg_bear_text = input.string("Bear", title="Label Text", group="Regular Bearish Divergence")
reg_bear_col = input.color(color.new(color.red, 0), title="Line & Label BG Color", group="Regular Bearish Divergence")
reg_bear_txt_col = input.color(color.white, title="Label Text Color", group="Regular Bearish Divergence")
reg_bear_width = input.int(2, title="Line Width", minval=1, maxval=5, group="Regular Bearish Divergence")
reg_bear_style_str = input.string("Solid", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Regular Bearish Divergence")
reg_bear_style = reg_bear_style_str == "Solid" ? line.style_solid : reg_bear_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// 3. Hidden Bullish
hid_bull_text = input.string("H-Bull", title="Label Text", group="Hidden Bullish Divergence")
hid_bull_col = input.color(color.new(color.green, 0), title="Line & Label BG Color", group="Hidden Bullish Divergence")
hid_bull_txt_col = input.color(color.white, title="Label Text Color", group="Hidden Bullish Divergence")
hid_bull_width = input.int(2, title="Line Width", minval=1, maxval=5, group="Hidden Bullish Divergence")
hid_bull_style_str = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Hidden Bullish Divergence")
hid_bull_style = hid_bull_style_str == "Solid" ? line.style_solid : hid_bull_style_str == "Dashed" ? line.style_dashed : line.style_dotted

// 4. Hidden Bearish
hid_bear_text = input.string("H-Bear", title="Label Text", group="Hidden Bearish Divergence")
hid_bear_col = input.color(color.new(color.red, 0), title="Line & Label BG Color", group="Hidden Bearish Divergence")
hid_bear_txt_col = input.color(color.white, title="Label Text Color", group="Hidden Bearish Divergence")
hid_bear_width = input.int(2, title="Line Width", minval=1, maxval=5, group="Hidden Bearish Divergence")
hid_bear_style_str = input.string("Dashed", title="Line Style", options=["Solid", "Dashed", "Dotted"], group="Hidden Bearish Divergence")
hid_bear_style = hid_bear_style_str == "Solid" ? line.style_solid : hid_bear_style_str == "Dashed" ? line.style_dashed : line.style_dotted


// --- CALCULATIONS ---
rsi_val = ta.rsi(close, len)
rsi_ma = ta.sma(rsi_val, rsi_ma_len)

// Draw RSI components if lower pane is selected
plot(is_price_mode ? na : rsi_val, color=rsi_col, title="RSI", linewidth=2)
plot(is_price_mode ? na : rsi_ma, color=rsi_ma_col, title="RSI MA", linewidth=1)

band1 = hline(is_price_mode ? na : 70, color=rsi_band_col, linestyle=hline.style_dashed)
band0 = hline(is_price_mode ? na : 30, color=rsi_band_col, linestyle=hline.style_dashed)
fill(band1, band0, color=is_price_mode ? na : rsi_bg_col, title="RSI Background")

// Find Pivots
pl = ta.pivotlow(low, pivot_left, pivot_right)
ph = ta.pivothigh(high, pivot_left, pivot_right)

// Historical pivot memory vars
var float last_pl_price = na
var float last_pl_rsi = na
var int last_pl_time = na

var float last_ph_price = na
var float last_ph_rsi = na
var int last_ph_time = na

// Object vars
var line bull_line = na
var label bull_label = na

var line bear_line = na
var label bear_label = na

var line h_bull_line = na
var label h_bull_label = na

var line h_bear_line = na
var label h_bear_label = na


// --- BULLISH (REGULAR & HIDDEN) CONTROL ---
if not na(pl)
    current_pl_price = low[pivot_right]
    current_pl_rsi = rsi_val[pivot_right]
    current_pl_time = time[pivot_right]

    if not na(last_pl_price)
        // 1. Regular Bullish Divergence
        if current_pl_price < last_pl_price and current_pl_rsi > last_pl_rsi
            y1 = is_price_mode ? last_pl_price : last_pl_rsi
            y2 = is_price_mode ? current_pl_price : current_pl_rsi

            if na(bull_line)
                bull_line := line.new(last_pl_time, y1, current_pl_time, y2, xloc.bar_time, color=reg_bull_col, width=reg_bull_width, style=reg_bull_style)
                bull_label := label.new(current_pl_time, y2, reg_bull_text, xloc.bar_time, yloc=yloc.price, color=reg_bull_col, textcolor=reg_bull_txt_col, style=label.style_label_up, size=size.small)
            else
                line.set_xy1(bull_line, last_pl_time, y1)
                line.set_xy2(bull_line, current_pl_time, y2)
                line.set_color(bull_line, reg_bull_col)
                line.set_width(bull_line, reg_bull_width)
                line.set_style(bull_line, reg_bull_style)
                
                label.set_xy(bull_label, current_pl_time, y2)
                label.set_text(bull_label, reg_bull_text)
                label.set_color(bull_label, reg_bull_col)
                label.set_textcolor(bull_label, reg_bull_txt_col)
            
            // DÜZENLİ POZİTİF ALARMI (Önizleme kapalı)
            alert('{"chat_id": "' + chat_id + '", ' + thread_str + '"parse_mode": "HTML", "disable_web_page_preview": true, "text": "🟢 <b>DİKKAT: ' + syminfo.ticker + '</b>\\n\\n' + readable_tf + ' grafiğinde <b>🟢 DÜZENLİ POZİTİF (Bull)</b> uyumsuzluk tespit edildi!\\n\\n🔗 <a href=\\"' + binance_url + '\\">Binance</a> | 📊 <a href=\\"' + tv_url + '\\">TradingView</a>"}', alert.freq_once_per_bar_close)
        
        // 2. Hidden Bullish Divergence
        else if current_pl_price > last_pl_price and current_pl_rsi < last_pl_rsi
            y1 = is_price_mode ? last_pl_price : last_pl_rsi
            y2 = is_price_mode ? current_pl_price : current_pl_rsi

            if na(h_bull_line)
                h_bull_line := line.new(last_pl_time, y1, current_pl_time, y2, xloc.bar_time, color=hid_bull_col, width=hid_bull_width, style=hid_bull_style)
                h_bull_label := label.new(current_pl_time, y2, hid_bull_text, xloc.bar_time, yloc=yloc.price, color=hid_bull_col, textcolor=hid_bull_txt_col, style=label.style_label_up, size=size.small)
            else
                line.set_xy1(h_bull_line, last_pl_time, y1)
                line.set_xy2(h_bull_line, current_pl_time, y2)
                line.set_color(h_bull_line, hid_bull_col)
                line.set_width(h_bull_line, hid_bull_width)
                line.set_style(h_bull_line, hid_bull_style)
                
                label.set_xy(h_bull_label, current_pl_time, y2)
                label.set_text(h_bull_label, hid_bull_text)
                label.set_color(h_bull_label, hid_bull_col)
                label.set_textcolor(h_bull_label, hid_bull_txt_col)
            
            // GİZLİ POZİTİF ALARMI (Önizleme kapalı)
            alert('{"chat_id": "' + chat_id + '", ' + thread_str + '"parse_mode": "HTML", "disable_web_page_preview": true, "text": "🟢 <b>DİKKAT: ' + syminfo.ticker + '</b>\\n\\n' + readable_tf + ' grafiğinde <b>🟢 GİZLİ POZİTİF (H-Bull)</b> uyumsuzluk tespit edildi!\\n\\n🔗 <a href=\\"' + binance_url + '\\">Binance</a> | 📊 <a href=\\"' + tv_url + '\\">TradingView</a>"}', alert.freq_once_per_bar_close)

    // Store latest pivot
    last_pl_price := current_pl_price
    last_pl_rsi := current_pl_rsi
    last_pl_time := current_pl_time


// --- BEARISH (REGULAR & HIDDEN) CONTROL ---
if not na(ph)
    current_ph_price = high[pivot_right]
    current_ph_rsi = rsi_val[pivot_right]
    current_ph_time = time[pivot_right]

    if not na(last_ph_price)
        // 1. Regular Bearish Divergence
        if current_ph_price > last_ph_price and current_ph_rsi < last_ph_rsi
            y1 = is_price_mode ? last_ph_price : last_ph_rsi
            y2 = is_price_mode ? current_ph_price : current_ph_rsi

            if na(bear_line)
                bear_line := line.new(last_ph_time, y1, current_ph_time, y2, xloc.bar_time, color=reg_bear_col, width=reg_bear_width, style=reg_bear_style)
                bear_label := label.new(current_ph_time, y2, reg_bear_text, xloc.bar_time, yloc=yloc.price, color=reg_bear_col, textcolor=reg_bear_txt_col, style=label.style_label_down, size=size.small)
            else
                line.set_xy1(bear_line, last_ph_time, y1)
                line.set_xy2(bear_line, current_ph_time, y2)
                line.set_color(bear_line, reg_bear_col)
                line.set_width(bear_line, reg_bear_width)
                line.set_style(bear_line, reg_bear_style)

                label.set_xy(bear_label, current_ph_time, y2)
                label.set_text(bear_label, reg_bear_text)
                label.set_color(bear_label, reg_bear_col)
                label.set_textcolor(bear_label, reg_bear_txt_col)
            
            // DÜZENLİ NEGATİF ALARMI (Önizleme kapalı)
            alert('{"chat_id": "' + chat_id + '", ' + thread_str + '"parse_mode": "HTML", "disable_web_page_preview": true, "text": "🔴 <b>DİKKAT: ' + syminfo.ticker + '</b>\\n\\n' + readable_tf + ' grafiğinde <b>🔴 DÜZENLİ NEGATİF (Bear)</b> uyumsuzluk tespit edildi!\\n\\n🔗 <a href=\\"' + binance_url + '\\">Binance</a> | 📊 <a href=\\"' + tv_url + '\\">TradingView</a>"}', alert.freq_once_per_bar_close)
                
        // 2. Hidden Bearish Divergence
        else if current_ph_price < last_ph_price and current_ph_rsi > last_ph_rsi
            y1 = is_price_mode ? last_ph_price : last_ph_rsi
            y2 = is_price_mode ? current_ph_price : current_ph_rsi

            if na(h_bear_line)
                h_bear_line := line.new(last_ph_time, y1, current_ph_time, y2, xloc.bar_time, color=hid_bear_col, width=hid_bear_width, style=hid_bear_style)
                h_bear_label := label.new(current_ph_time, y2, hid_bear_text, xloc.bar_time, yloc=yloc.price, color=hid_bear_col, textcolor=hid_bear_txt_col, style=label.style_label_down, size=size.small)
            else
                line.set_xy1(h_bear_line, last_ph_time, y1)
                line.set_xy2(h_bear_line, current_ph_time, y2)
                line.set_color(h_bear_line, hid_bear_col)
                line.set_width(h_bear_line, hid_bear_width)
                line.set_style(h_bear_line, hid_bear_style)

                label.set_xy(h_bear_label, current_ph_time, y2)
                label.set_text(h_bear_label, hid_bear_text)
                label.set_color(h_bear_label, hid_bear_col)
                label.set_textcolor(h_bear_label, hid_bear_txt_col)

            // GİZLİ NEGATİF ALARMI (Önizleme kapalı)
            alert('{"chat_id": "' + chat_id + '", ' + thread_str + '"parse_mode": "HTML", "disable_web_page_preview": true, "text": "🔴 <b>DİKKAT: ' + syminfo.ticker + '</b>\\n\\n' + readable_tf + ' grafiğinde <b>🔴 GİZLİ NEGATİF (H-Bear)</b> uyumsuzluk tespit edildi!\\n\\n🔗 <a href=\\"' + binance_url + '\\">Binance</a> | 📊 <a href=\\"' + tv_url + '\\">TradingView</a>"}', alert.freq_once_per_bar_close)

    // Store latest pivot
    last_ph_price := current_ph_price
    last_ph_rsi := current_ph_rsi
    last_ph_time := current_ph_time
````
