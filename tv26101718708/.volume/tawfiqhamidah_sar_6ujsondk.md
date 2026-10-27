# Tawfiq_Hamidah - SAR

- url: https://www.tradingview.com/script/6ujSOnDk/
- type: indicator
- pine_id: PUB;f36040331ea74e45a1d256af9cd65219
- version: 3.0

## Description

https://www.tradingview.com/x/Qc8wIdfs/
The advanced SAR indicator accurately provides trend reversal signals, calculates liquidity, and includes other indicators.

مؤشر مطور ذكي SAR يعطي اشارات تحول الاتجاه بطريقة صحيحة حساب السيولة وغيرها من المؤشرات

## Source Code

````pine
//@version=5
indicator("Tawfiq_Hamidah - SAR", overlay=true, max_labels_count=500)

// ─── 1. إعدادات الإشارات والأسهم (حجم وسط) ───
grp_ball = "إعدادات الإشارات والأسهم"
min_pwr    = input.int(75, "الحد الأدنى للقوة (75%)", minval=1, maxval=100, group=grp_ball)
ball_trans = input.int(25, "شفافية السهم (25%)", minval=0, maxval=100, group=grp_ball)
c_buy      = input.color(#00ffaa, "لون سهم الشراء", group=grp_ball)
c_sell     = input.color(#ff0000, "لون سهم البيع", group=grp_ball)

// ─── 2. الفلتر الذكي لمنع فشل الصعود ───
grp_filter = "الفلتر الذكي والمطور"
use_trend_filter = input.bool(true, "تفعيل فلتر الاتجاه الذكي", group=grp_filter)

// ─── 3. إعدادات SAR والمتوسطات ───
grp_sar  = "إعدادات SAR الملون"
col_up   = input.color(color.green, "لون الصعود", inline="sar", group=grp_sar)
col_dn   = input.color(color.red, "لون الهبوط", inline="sar", group=grp_sar)

// ─── 4. الحسابات الفنية (تم إصلاح كافة أخطاء الـ Syntax) ───
// تم إلغاء استخدام => في الدوال البسيطة لتجنب الأخطاء
vol_calc = (high - low) == 0 ? 1.0 : (high - low)
buy_vol  = ta.ema(volume * ((close - low) / vol_calc), 3)
sell_vol = ta.ema(volume * ((high - close) / vol_calc), 3)
b_pct    = nz((buy_vol / (buy_vol + sell_vol + 0.000001)) * 100)
s_pct    = 100 - b_pct

// فلتر الزخم الذكي (ADX + RSI) لمنع الفشل
[_, _, adx_v] = ta.dmi(14, 14)
rsi_v = ta.rsi(close, 14)
is_strong = adx_v > 20 // الترند قوي وليس جانبي فاشل

psar   = ta.sar(0.02, 0.02, 0.2)
ema200 = ta.ema(close, 200)
is_news = ta.atr(14) > ta.sma(ta.atr(14), 20) * 1.5

// ─── 5. رسم المتوسطات و SAR ───
plot(ta.ema(close, 200), "EMA 200", color=color.new(color.white, 50), linewidth=2)
sar_color = psar < close ? col_up : col_dn
plot(psar, "SAR", style=plot.style_cross, color=sar_color, linewidth=1)

// ─── 6. منطق الإشارات المطور (ذكاء اصطناعي مبسط) ───
// منع فشل الصعود: لا شراء إذا كان RSI متضخم جداً أو الزخم ضعيف
buy_logic  = ta.crossover(close, psar) and b_pct >= min_pwr and (not use_trend_filter or (is_strong and rsi_v < 70))
sell_logic = ta.crossunder(close, psar) and s_pct >= min_pwr and (not use_trend_filter or (is_strong and rsi_v > 30))

if (buy_logic or sell_logic)
    float pwr = buy_logic ? b_pct : s_pct
    string txt = (buy_logic ? "BUY " : "SELL ") + str.tostring(math.round(pwr)) + "%"
    color b_col = buy_logic ? color.new(c_buy, 100 - ball_trans) : color.new(c_sell, 100 - ball_trans)
    
    label.new(bar_index, buy_logic ? low : high, 
         text=txt, 
         color=b_col, 
         style=buy_logic ? label.style_triangleup : label.style_triangledown, 
         textcolor=color.white, 
         size=size.normal, // حجم وسط مريح وبايّن
         yloc=buy_logic ? yloc.belowbar : yloc.abovebar)

// ─── 7. الجدول المطور (إصلاح قيم الـ NaN) ───
var table tab = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(tab, 0, 0, "المسار العام", text_color=color.white)
    table.cell(tab, 1, 0, close > ema200 ? "صاعد ↑" : "هابط ↓", text_color=close > ema200 ? color.green : color.red)
    table.cell(tab, 0, 1, "حالة السوق", text_color=color.white)
    table.cell(tab, 1, 1, is_news ? "⚠️ أخبار" : "✅ هادئ", text_color=is_news ? color.orange : color.green)
    table.cell(tab, 0, 2, "سيولة المشترين", text_color=color.white)
    table.cell(tab, 1, 2, str.tostring(math.round(b_pct)) + "%", text_color=color.green)
    table.cell(tab, 0, 3, "قوة الزخم (ADX)", text_color=color.white)
    table.cell(tab, 1, 3, str.tostring(math.round(adx_v)), text_color=color.yellow)
````
