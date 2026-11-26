# Maghamsi Market Radar [Multi-Asset]

- url: https://www.tradingview.com/script/r05iR190/
- type: indicator
- pine_id: PUB;21bea58c436a4ee5a3c5fa51bb0d9c68
- version: 1.0

## Description

Maghamsi Market Radar [Multi-Asset]
Overview The Maghamsi Market Radar is a comprehensive multi-asset monitoring tool designed to track the trend and momentum of up to 40 financial instruments simultaneously. It provides a real-time dashboard directly on your chart, helping traders identify potential opportunities across the Saudi Stock Exchange (TASI), NASDAQ, or any other market supported by TradingView.
Technical Logic The indicator evaluates assets based on two primary technical layers:
1.	Trend Confirmation: Uses a Long-term Exponential Moving Average (EMA) to determine the overall market direction.
2.	Momentum Analysis: Utilizes a Linear Regression-based momentum oscillator to detect strength and early shifts in price action.
3.	Volume Surge (SOS): Monitors significant volume spikes relative to the average to identify institutional interest.
Key Features
•	Dual-Language Support: Toggle between English and Arabic interfaces via settings.
•	Customizable Layout: Move the dashboard to any corner of your chart to maintain visibility.
•	Full Asset Names: Displays both the ticker and the company description for better clarity.
Disclaimer This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading involves significant risk, and you should always conduct your own research before making any investment decisions.
________________________________________
الوصف باللغة العربية
رادار المغامسي للسوق [متعدد الأصول]
نظرة عامة يعد "رادار المغامسي" أداة مراقبة متطورة مصممة لتتبع الاتجاه والزخم لـ 40 ورقة مالية في وقت واحد. يوفر المؤشر لوحة تحكم فورية مباشرة على الرسم البياني، مما يساعد المتداول على تحديد الفرص المحتملة في السوق السعودي (تاسي)، أو الأسواق العالمية مثل نيزداك، أو أي سوق تدعمه منصة تريدنق فيو.
المنطق الفني يقوم المؤشر بتقييم الأصول بناءً على طبقتين فنيتين أساسيتين:
1.	تأكيد الاتجاه: استخدام المتوسط المتحرك الأسي (EMA) طويل المدى لتحديد المسار العام للسوق.
2.	تحليل الزخم: يعتمد على مذبذب الزخم المبني على الانحدار الخطي (Linear Regression) لاكتشاف القوة والتحولات المبكرة في حركة السعر.
3.	طفرات الأحجام (SOS): مراقبة الزيادات الكبيرة في أحجام التداول بالنسبة للمتوسط للكشف عن دخول السيولة.
الميزات الرئيسية
•	دعم ثنائي اللغة: إمكانية التبديل بين الواجهة الإنجليزية والعربية من الإعدادات.
•	تخصيص الموقع: يمكنك تحريك لوحة الرادار إلى أي زاوية في الشاشة لضمان وضوح الرسم البياني.
•	أسماء الشركات كاملة: يعرض الرمز مع وصف الشركة لزيادة الدقة في المتابعة.
إخلاء المسؤولية هذا المؤشر مخصص للأغراض التعليمية والمعلوماتية فقط، ولا يعتبر توصية فنية أو نصيحة استثمارية. ينطوي التداول على مخاطر كبيرة، ويجب عليك دائماً إجراء بحثك الخاص قبل اتخاذ أي قرار استثماري.

## Source Code

````pine
// © WaleedAlmaghamsi
// @version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Eng. Waleed Almaghamsi (Abu Abdulrahman)

indicator("Maghamsi Market Radar [Multi-Asset]", overlay=true, max_bars_back=500)

// ==========================================
// 1. SETTINGS & LOCALIZATION
// ==========================================
grp_lang = "Language Settings"
lang_opt = input.string("English", "Select Language", options=["English", "Arabic"], group=grp_lang)

// Translation Function
f_translate(en_text, ar_text) => 
    lang_opt == "English" ? en_text : ar_text

grp_pos = "Table Position"
table_pos = input.string("Middle Right", "Location", 
     options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group=grp_pos)

pos_val = table_pos == "Top Right" ? position.top_right : 
          table_pos == "Middle Right" ? position.middle_right : 
          table_pos == "Bottom Right" ? position.bottom_right : 
          table_pos == "Top Left" ? position.top_left : 
          table_pos == "Middle Left" ? position.middle_left : position.bottom_left

grp_set = "Technical Parameters"
ema_len = input.int(200, "Trend EMA Length", minval=1, group=grp_set)
mom_len = input.int(20, "Momentum Length", minval=1, group=grp_set)

// Symbols 
s01 = input.symbol("NASDAQ:NVDA", "Asset 01"), s02 = input.symbol("TADAWUL:2222", "Asset 02")
s03 = input.symbol("NASDAQ:WLDN", "Asset 03"), s04 = input.symbol("TADAWUL:2020", "Asset 04")
s05 = input.symbol("NASDAQ:AMD", "Asset 05"), s06 = input.symbol("TADAWUL:1111", "Asset 06")
s07 = input.symbol("NASDAQ:SNDK", "Asset 07"), s08 = input.symbol("TADAWUL:2270", "Asset 08")
s09 = input.symbol("NASDAQ:AAPL", "Asset 09"), s10 = input.symbol("TADAWUL:2380", "Asset 10")
s11 = input.symbol("NASDAQ:DPRO", "Asset 11"), s12 = input.symbol("TADAWUL:6010", "Asset 12")
s13 = input.symbol("NASDAQ:PEP", "Asset 13"), s14 = input.symbol("TADAWUL:2082", "Asset 14")
s15 = input.symbol("NASDAQ:META", "Asset 15"), s16 = input.symbol("TADAWUL:4007", "Asset 16")
s17 = input.symbol("NASDAQ:AMZN", "Asset 17"), s18 = input.symbol("TADAWUL:2330", "Asset 18")
s19 = input.symbol("NASDAQ:TSLA", "Asset 19"), s20 = input.symbol("TADAWUL:1810", "Asset 20")
s21 = input.symbol("NASDAQ:MSFT", "Asset 21"), s22 = input.symbol("TADAWUL:6017", "Asset 22")
s23 = input.symbol("NASDAQ:AVGO", "Asset 23"), s24 = input.symbol("TADAWUL:2240", "Asset 24")
s25 = input.symbol("NASDAQ:GOOG", "Asset 25"), s26 = input.symbol("TADAWUL:4004", "Asset 26")
s27 = input.symbol("NASDAQ:MRAM", "Asset 27"), s28 = input.symbol("TADAWUL:3091", "Asset 28")
s29 = input.symbol("NASDAQ:LCID", "Asset 29"), s30 = input.symbol("TADAWUL:4008", "Asset 30")
s31 = input.symbol("NASDAQ:FLNC", "Asset 31"), s32 = input.symbol("TADAWUL:6015", "Asset 32")
s33 = input.symbol("NASDAQ:PHOE", "Asset 33"), s34 = input.symbol("TADAWUL:2230", "Asset 34")
s35 = input.symbol("NASDAQ:WEST", "Asset 35"), s36 = input.symbol("TADAWUL:7203", "Asset 36")
s37 = input.symbol("NASDAQ:AKAM", "Asset 37"), s38 = input.symbol("TADAWUL:2010", "Asset 38")
s39 = input.symbol("NASDAQ:ANPA", "Asset 39"), s40 = input.symbol("TADAWUL:1120", "Asset 40")

// ==========================================
// 2. CORE LOGIC
// ==========================================
calc_signal(s_name) =>
    [o, h, l, c, v, h_prev, v_ma, d] = request.security(s_name, timeframe.period, [open, high, low, close, volume, high[1], ta.sma(volume, 20), syminfo.description])
    
    ema_v = ta.ema(c, ema_len)
    mom = ta.linreg(c - math.avg(math.avg(ta.highest(h, mom_len), ta.lowest(l, mom_len)), ta.sma(c, mom_len)), mom_len, 0)
    sos = c > o and c > h_prev and v > v_ma * 1.5
    
    string res = f_translate("Neutral", "محايد")
    color col = color.gray
    if not na(c)
        if c > ema_v and mom > 0
            res := f_translate("BULLISH ↑", "إيجابي ↑"), col := color.green
        else if sos or (mom > 0 and mom > nz(mom[1]))
            res := f_translate("EARLY ⭐", "بداية ⭐"), col := color.blue
        else if c < ema_v
            res := f_translate("BEARISH ↓", "سلبي ↓"), col := color.red
    
    sym_ticker = str.replace_all(s_name, "TADAWUL:", "")
    display_name = sym_ticker + "\n" + d
    [res, col, display_name]

// ==========================================
// 3. EXECUTION
// ==========================================
[r01, cl01, n01] = calc_signal(s01), [r02, cl02, n02] = calc_signal(s02)
[r03, cl03, n03] = calc_signal(s03), [r04, cl04, n04] = calc_signal(s04)
[r05, cl05, n05] = calc_signal(s05), [r06, cl06, n06] = calc_signal(s06)
[r07, cl07, n07] = calc_signal(s07), [r08, cl08, n08] = calc_signal(s08)
[r09, cl09, n09] = calc_signal(s09), [r10, cl10, n10] = calc_signal(s10)
[r11, cl11, n11] = calc_signal(s11), [r12, cl12, n12] = calc_signal(s12)
[r13, cl13, n13] = calc_signal(s13), [r14, cl14, n14] = calc_signal(s14)
[r15, cl15, n15] = calc_signal(s15), [r16, cl16, n16] = calc_signal(s16)
[r17, cl17, n17] = calc_signal(s17), [r18, cl18, n18] = calc_signal(s18)
[r19, cl19, n19] = calc_signal(s19), [r20, cl20, n20] = calc_signal(s20)
[r21, cl21, n21] = calc_signal(s21), [r22, cl22, n22] = calc_signal(s22)
[r23, cl23, n23] = calc_signal(s23), [r24, cl24, n24] = calc_signal(s24)
[r25, cl25, n25] = calc_signal(s25), [r26, cl26, n26] = calc_signal(s26)
[r27, cl27, n27] = calc_signal(s27), [r28, cl28, n28] = calc_signal(s28)
[r29, cl29, n29] = calc_signal(s29), [r30, cl30, n30] = calc_signal(s30)
[r31, cl31, n31] = calc_signal(s31), [r32, cl32, n32] = calc_signal(s32)
[r33, cl33, n33] = calc_signal(s33), [r34, cl34, n34] = calc_signal(s34)
[r35, cl35, n35] = calc_signal(s35), [r36, cl36, n36] = calc_signal(s36)
[r37, cl37, n37] = calc_signal(s37), [r38, cl38, n38] = calc_signal(s38)
[r39, cl39, n39] = calc_signal(s39), [r40, cl40, n40] = calc_signal(s40)

// ==========================================
// 4. DRAWING THE TABLE (Manual Headers)
// ==========================================
var table scanner = table.new(pos_val, 8, 11, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

f_fill(row, col, name_str, signal_str, clr) =>
    table.cell(scanner, col, row, name_str, text_color=color.yellow, text_size=size.tiny)
    table.cell(scanner, col+1, row, signal_str, bgcolor=clr, text_color=color.white, text_size=size.small)

if barstate.islast
    h_c = f_translate("Asset", "الأصل")
    h_s = f_translate("Signal", "الإشارة")
    
    // Set Headers Manually to avoid Loop Errors in some environments
    table.cell(scanner, 0, 0, h_c, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 1, 0, h_s, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 2, 0, h_c, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 3, 0, h_s, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 4, 0, h_c, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 5, 0, h_s, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 6, 0, h_c, text_color=color.gray, text_size=size.tiny)
    table.cell(scanner, 7, 0, h_s, text_color=color.gray, text_size=size.tiny)

    // Populate Data
    f_fill(1, 0, n01, r01, cl01), f_fill(1, 2, n02, r02, cl02), f_fill(1, 4, n03, r03, cl03), f_fill(1, 6, n04, r04, cl04)
    f_fill(2, 0, n05, r05, cl05), f_fill(2, 2, n06, r06, cl06), f_fill(2, 4, n07, r07, cl07), f_fill(2, 6, n08, r08, cl08)
    f_fill(3, 0, n09, r09, cl09), f_fill(3, 2, n10, r10, cl10), f_fill(3, 4, n11, r11, cl11), f_fill(3, 6, n12, r12, cl12)
    f_fill(4, 0, n13, r13, cl13), f_fill(4, 2, n14, r14, cl14), f_fill(4, 4, n15, r15, cl15), f_fill(4, 6, n16, r16, cl16)
    f_fill(5, 0, n17, r17, cl17), f_fill(5, 2, n18, r18, cl18), f_fill(5, 4, n19, r19, cl19), f_fill(5, 6, n20, r20, cl20)
    f_fill(6, 0, n21, r21, cl21), f_fill(6, 2, n22, r22, cl22), f_fill(6, 4, n23, r23, cl23), f_fill(6, 6, n24, r24, cl24)
    f_fill(7, 0, n25, r25, cl25), f_fill(7, 2, n26, r26, cl26), f_fill(7, 4, n27, r27, cl27), f_fill(7, 6, n28, r28, cl28)
    f_fill(8, 0, n29, r29, cl29), f_fill(8, 2, n30, r30, cl30), f_fill(8, 4, n31, r31, cl31), f_fill(8, 6, n32, r32, cl32)
    f_fill(9, 0, n33, r33, cl33), f_fill(9, 2, n34, r34, cl34), f_fill(9, 4, n35, r35, cl35), f_fill(9, 6, n36, r36, cl36)
    f_fill(10, 0, n37, r37, cl37), f_fill(10, 2, n38, r38, cl38), f_fill(10, 4, n39, r39, cl39), f_fill(10, 6, n40, r40, cl40)
````
