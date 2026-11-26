# Almaghamsi Price Engineering Protocol (APEP).

- url: https://www.tradingview.com/script/uDyFA0fB/
- type: indicator
- pine_id: PUB;672a6e77681444ce8ad27f31e51731db
- version: 1.0

## Description

Title: Almaghamsi Price Engineering Protocol (APEP)
English Description (For Moderators)
The Almaghamsi Price Engineering Protocol (APEP) is an advanced analytical tool designed to merge classical geometric market theories with modern liquidity analysis. This script provides a comprehensive multi-layered framework for identifying institutional behavior and price targets through technical confluence.

Key Technical Features:

Gann Square of Nine Integration: Automatically calculates geometric price targets (90°, 180°, and 360°) based on institutional accumulation anchors.

Liquidity Absorption Engine: Uses a proprietary volume-spread analysis to identify "Absorption Clusters" where large-scale accumulation or distribution occurs.

Order Flow Metrics: Features a real-time dashboard displaying Net Delta, Total Volume, and Money Flow Index (MFI) strength to confirm trend sustainability.

Smart Momentum Filtering: Signals are filtered by volatility-adjusted EMAs and MFI thresholds to reduce noise and highlight high-probability momentum shifts.

Disclaimer:
This script is provided for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or an offer to buy or sell any security. Trading involves significant risk, and past performance is not indicative of future results. The author is not responsible for any financial losses incurred from the use of this tool. Use at your own risk.

الوصف العربي (للمستخدمين)
بروتوكول المغامسي لهندسة الأسعار (APEP) هو أداة تحليلية متطورة تم ابتكارها لدمج نظريات الهندسة السعرية الكلاسيكية مع تحليل تدفق السيولة الحديث. يوفر هذا المؤشر إطاراً فنياً متكاملاً لرصد سلوك "صناع السوق" وتحديد الأهداف السعرية بدقة رياضية.

المميزات الرئيسية:

الإسقاطات الهندسية (Gann): حساب أهداف "مربع التسعة" (90، 180، 360 درجة) آلياً بمجرد رصد نقطة ارتكاز مؤسسية.

محرك امتصاص السيولة: التعرف على مناطق "التجميع" و"التصريف" من خلال تحليل العلاقة بين حجم التداول والمدى السعري.

لوحة البيانات (Dashboard): عرض مباشر لصافي الدلتا (Net Delta)، إجمالي السيولة، وقوة التدفق (MFI) لتأكيد صحة الاختراقات.

نظام التنبيه الذكي: تنبيهات مشروطة بقوة الزخم، تضمن عدم التفاعل مع الإشارات الضعيفة أو الوهمية.

إخلاء مسؤولية:
هذا المؤشر هو أداة تعليمية وفنية فقط، ولا يعتبر بأي حال من الأحوال نصيحة استثمارية أو دعوة للشراء أو البيع. التداول في الأسواق المالية ينطوي على مخاطر عالية، والنتائج السابقة لا تضمن النتائج المستقبلية. يتحمل المستخدم كامل المسؤولية عن قراراته الاستثمارية، ولا يتحمل المطور أي مسؤولية عن أي خسائر مالية قد تنتج عن استخدام هذه الأداة.

## Source Code

````pine
//@version=5
indicator("Almaghamsi Price Engineering Protocol", shorttitle="APEP v15.7", overlay=true, max_labels_count=500)

// --- [ 1. Global Configuration ] ---
lang_opt = input.string("العربية", "Language / اللغة", options=["English", "العربية"], group="Global Settings")
exec_mode = input.string("Daily (Balanced)", "Logic Mode", options=["Scalping (Fast)", "Daily (Balanced)", "Swing (Long)"], group="Algorithm Core")
mfi_limit = input.int(55, "Min MFI for Alerts / أدنى قوة تدفق للتنبيه", minval=1, maxval=99, group="Alert Filters")

var int lookback = exec_mode == "Scalping (Fast)" ? 7 : exec_mode == "Daily (Balanced)" ? 10 : 20
var float vol_coeff = exec_mode == "Scalping (Fast)" ? 1.2 : exec_mode == "Daily (Balanced)" ? 1.5 : 2.0

// --- [ 2. Liquidity Engine ] ---
gann_coeff = input.float(0.125, "Gann Coefficient", group="Math")
fast_ema = ta.ema(close, lookback)
slow_ema = ta.ema(close, lookback * 2)

bar_spread = high - low + 0.00001
rel_delta = (close - open) / bar_spread * volume
avg_vol = ta.sma(volume, 20)

is_abs = volume > avg_vol * vol_coeff and math.abs(close - open) < bar_spread * 0.4
is_acc = is_abs and (rel_delta > 0 or close > ta.vwap)
is_dist = is_abs and (rel_delta < 0 or close < ta.vwap)

// --- [ 3. Gann Projections ] ---
var float anchor_p = na
if is_acc
    anchor_p := close

calc_t(base, step) => base > 0 ? math.pow(math.sqrt(base) + (step * gann_coeff), 2) : na
g_90 = calc_t(anchor_p, 2), g_180 = calc_t(anchor_p, 4), g_360 = calc_t(anchor_p, 8)

// --- [ 4. Visuals & Signals ] ---
mfi_val = ta.mfi(hlc3, 14)
bgcolor(mfi_val > 60 ? color.new(color.green, 90) : mfi_val < 40 ? color.new(color.red, 90) : na)

// إشارات التجميع والتصريف (Labels)
if is_acc
    label.new(bar_index, high, lang_opt == "العربية" ? "تجميع" : "ACCUM", color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_down, size=size.small)
if is_dist
    label.new(bar_index, high, lang_opt == "العربية" ? "تصريف" : "DISTR", color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

// إشارات الشراء والبيع (Buy/Sell Shapes) - تمت إعادتها
trend_buy  = ta.crossover(fast_ema, slow_ema)
trend_sell = ta.crossunder(fast_ema, slow_ema)

plotshape(trend_buy,  title="Trend Buy",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(trend_sell, title="Trend Sell", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)

plot(anchor_p, "Anchor", color=color.new(#FFEB3B, 20), style=plot.style_linebr, linewidth=2)
plot(g_90, "90°", color=color.new(#00FFFF, 50), style=plot.style_linebr)
plot(g_180, "180°", color=color.new(#FF9800, 50), style=plot.style_linebr)
plot(g_360, "360°", color=color.new(#FFD700, 20), style=plot.style_linebr, linewidth=3)

// --- [ 5. Dashboard ] ---
var table apes_tab = table.new(position.top_right, 2, 9, bgcolor=color.new(#000000, 50), border_width=1, border_color=#808080)
f_get_t(en, ar) => lang_opt == "العربية" ? ar : en

if barstate.islast
    table.cell(apes_tab, 0, 0, f_get_t("Gann Anchor", "ارتكاز جان"), text_color=color.white)
    table.cell(apes_tab, 1, 0, str.tostring(anchor_p, "#.##"), text_color=color.yellow)
    table.cell(apes_tab, 0, 1, f_get_t("Target 90°", "هدف 90°"), text_color=color.white)
    table.cell(apes_tab, 1, 1, str.tostring(g_90, "#.##"), text_color=color.aqua)
    table.cell(apes_tab, 0, 2, f_get_t("Target 180°", "هدف 180°"), text_color=color.white)
    table.cell(apes_tab, 1, 2, str.tostring(g_180, "#.##"), text_color=color.orange)
    table.cell(apes_tab, 0, 3, f_get_t("Target 360°", "هدف 360°"), text_color=color.white)
    table.cell(apes_tab, 1, 3, str.tostring(g_360, "#.##"), text_color=#FFD700)
    table.cell(apes_tab, 0, 4, f_get_t("Volume", "إجمالي السيولة"), text_color=color.white)
    vol_str = volume >= 1000000 ? str.tostring(volume/1000000, "#.##") + "M" : str.tostring(volume/1000, "#.#") + "K"
    table.cell(apes_tab, 1, 4, vol_str, text_color=color.white)
    table.cell(apes_tab, 0, 5, f_get_t("Net Delta", "صافي الدلتا"), text_color=color.white)
    table.cell(apes_tab, 1, 5, str.tostring((rel_delta/volume)*100, "0.0") + "%", text_color=(rel_delta > 0 ? color.green : color.red))
    table.cell(apes_tab, 0, 6, f_get_t("MFI Strength", "قوة التدفق"), text_color=color.white)
    table.cell(apes_tab, 1, 6, str.tostring(mfi_val, "0") + "%", text_color=(mfi_val > 50 ? color.green : color.red))
    table.cell(apes_tab, 0, 7, f_get_t("Mode", "النمط"), text_color=color.white)
    table.cell(apes_tab, 1, 7, exec_mode == "Scalping (Fast)" ? f_get_t("Fast", "لحظي") : f_get_t("Daily", "يومي"), text_color=color.aqua)
    table.cell(apes_tab, 0, 8, f_get_t("Trend", "الاتجاه"), text_color=color.white)
    table.cell(apes_tab, 1, 8, fast_ema > slow_ema ? f_get_t("BULLISH", "صاعد") : f_get_t("BEARISH", "هابط"), text_color=(fast_ema > slow_ema ? color.green : color.red))

// --- [ 6. Smart Alerts with MFI Filter ] ---
alert_long  = trend_buy and mfi_val >= mfi_limit
alert_short = trend_sell and mfi_val <= (100 - mfi_limit)

alertcondition(alert_long,  "Strong Buy (MFI Verified)", "Bullish trend confirmed with strong liquidity flow!")
alertcondition(alert_short, "Strong Sell (MFI Verified)", "Bearish trend confirmed with liquidity outflow!")
alertcondition(is_acc,      "Accumulation Detected", "Institutional Accumulation cluster identified.")
````
