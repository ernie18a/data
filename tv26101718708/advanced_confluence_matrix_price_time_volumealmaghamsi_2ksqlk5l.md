# Advanced Confluence Matrix: Price, Time & Volume[Almaghamsi]

- url: https://www.tradingview.com/script/2KsQlK5l/
- type: indicator
- pine_id: PUB;cf2f812d11b946bea9e713de42384a48
- version: 1.0

## Description

Advanced Confluence Matrix [Almaghamsi] 
Summary:
This indicator is a comprehensive technical analysis tool designed to identify high-probability market setups by integrating price action, time cycles, and institutional liquidity tracking. It utilizes an advanced multi-layered engine to detect Market Structure Breaks (MSB) and filter signals through a digital Confluence Scoring system. By projecting Fibonacci-based time nodes and dynamic wave extensions, it provides traders with clear, objective price targets ranging from conservative to extreme projections.
Key Features:
•	Dual-Language Interface: Supports both English and Arabic.
•	Liquidity Tracking: Identifies institutional "Liquidity Grabs" (B-LS/S-LS).
•	Time Partitioning: Forecasts potential reversal windows using Fibonacci time ratios.
•	Smart Dashboard: Provides real-time metrics on trend strength and momentum.
Disclaimer :
English: This script is for educational and informational purposes only. It does not constitute financial advice or an invitation to trade. Trading involves significant risk, and past performance is not indicative of future results. Use this tool as part of a comprehensive trading strategy and at your own risk.

________________________________________
ملخص المؤشر: 
يعد هذا المؤشر أداة تحليل فني متكاملة صُممت لتحديد أفضل الفرص في الأسواق المالية عبر دمج حركة السعر، الدورات الزمنية، وتتبع سيولة المؤسسات. يعتمد المحرك البرمجي على رصد اختراقات هيكل السوق (MSB) وفلترة الإشارات عبر نظام "نقاط الالتقاء الرقمي" لتقييم قوة الفرصة بموضوعية. كما يقوم المؤشر بالتنبؤ بالفترات الزمنية القادمة باستخدام نسب فيبوناتشي وتحديد أهداف سعرية دقيقة تعتمد على قياسات الموجات الهندسية.
أهم المميزات:
•	واجهة ثنائية اللغة: دعم كامل للعربية والإنجليزية.
•	تتبع السيولة الذكية: كشف مصائد السيولة وسحب السيولة المؤسساتي.
•	التقسيم الزمني: التنبؤ بمواعيد الانعكاسات المتوقعة عبر نسب فيبوناتشي الزمنية.
•	لوحة تحكم ذكية: عرض مباشر لقوة الاتجاه والزخم وحالة الهيكل.
________________________________________
إخلاء مسؤولية
العربية: هذا المؤشر مخصص للأغراض التعليمية والمعلوماتية فقط، ولا يشكل نصيحة مالية أو دعوة للتداول. ينطوي التداول على مخاطر كبيرة، والنتائج السابقة لا تضمن الأداء المستقبلي. يجب استخدام هذه الأداة كجزء من استراتيجية تداول شاملة، وعلى مسؤوليتك الشخصية الكاملة.

## Source Code

````pine
//@version=5
indicator("Advanced Confluence Matrix: Price, Time & Volume[Almaghamsi]", overlay=true, max_lines_count=500, max_boxes_count=500)
 
// ── إعدادات اللغة / Language Settings ──
langInput = input.string("Arabic", "Language / اللغة", options=["English", "Arabic"])
isEn = langInput == "English"
 
// ── إعدادات صندوق البيانات / Dashboard Settings──
showDash = input.bool(true, "إظهار صندوق البيانات / Show Dashboard")
dashLoc  = input.string("Top Right", "موقع الصندوق", options=["Top Right", "Bottom Right", "Top Left"])
 
// ── نصوص الواجهة Interface Texts──
txtNear     = isEn ? "Near Target(0.618): " : "(0.618) هدف قريب: "
txtPartial  = isEn ? "Partial Target(1): " : "(1) هدف جزئي: "
txtGolden   = isEn ? "Golden Target(1.414): " : "(1.414) الهدف الذهبي: "
txtDiamond  = isEn ? "Diamond Target (1.618): " : "الهدف الماسي (1.618): "
txtHistory  = isEn ? "Historical Target (2.0): " : "الهدف التاريخي (2.0): "
txtCosmic   = isEn ? "Cosmic Target (2.618): " : "الهدف الكوني (2.618): "
txtAstron   = isEn ? "Astronomic Target (3.0): " : "الهدف الفلكي (3.0): "
txtSupern   = isEn ? "Supernova Target (3.618): " : "هدف السوبر نوفا (3.618): "
txtExtreme  = isEn ? "Extreme Target (4.0): " : "هدف الانفجار الكامل (4.0): "
txtDemand   = isEn ? "Demand Zone (Buy OB)" : "منطقة طلب (Buy OB)"
txtSupply   = isEn ? "Supply Zone (Sell OB)" : "منطقة عرض (Sell OB)"
txtBLS      = isEn ? "B-LS" : "سحب سيولة شرائي"
txtSLS      = isEn ? "S-LS" : "سحب سيولة بيعي"
txtT1       = isEn ? "Time Node 1" : "الفترة الزمنية 1"
txtT2       = isEn ? "Time Node 2" : "الفترة الزمنية 2"
txtT3       = isEn ? "Golden Node" : "الفترة الذهبية"
txtConf     = isEn ? "Opportunity Strength" : "قوة الفرصة"
 
// ── الإعدادات الفنية والزمنية / Technical & Time Settings──
lookback = input.int(12, "Structure Sensitivity", minval=5)
showTrends = input.bool(true, "Show Matrix Trends")
atrMult = input.float(1.0, "OB Width", step=0.1)
timeRatio = input.float(1.414, "Golden Node Ratio (Fib)", options=[1.272, 1.414, 1.618, 2.0, 2.618])
 
// ── محرك هيكل السوق / Market Structure Engine──
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low, lookback, lookback)
float lastH = ta.valuewhen(not na(ph), ph, 0)
float lastL = ta.valuewhen(not na(pl), pl, 0)
int lastH_bar = ta.valuewhen(not na(ph), bar_index[lookback], 0)
int lastL_bar = ta.valuewhen(not na(pl), bar_index[lookback], 0)
bool msbUp   = ta.crossover(close, lastH)
bool msbDown = ta.crossunder(close, lastL)
 
// ── سحب السيولة / Liquidity Grab──
stdDev = ta.stdev(close, 20)
isB_LS = low < lastL and close > lastL + (stdDev * 0.1)
isS_LS = high > lastH and close < lastH - (stdDev * 0.1)

// ── Confluence Score  ──
float confScore = 0
if (close > lastH) or msbUp
    confScore += 30
if isB_LS or isS_LS
    confScore += 25
momentum = ta.rsi(close, 14)
if (momentum > 50 and close > lastH) or (momentum < 50 and close < lastL)
    confScore += 20
if (low <= (lastL + ta.atr(14))) or (high >= (lastH - ta.atr(14)))
    confScore += 25

color scoreColor = confScore >= 75 ? color.lime : confScore >= 50 ? color.orange : color.red
 
// ── محرك صندوق البيانات / Dashboard Engine──
var table dash = na
if showDash
    pos = dashLoc == "Top Right" ? position.top_right : dashLoc == "Bottom Right" ? position.bottom_right : position.top_left
    dash := table.new(pos, 2, 5, bgcolor=color.new(#1a1a1a, 20), border_color=color.gray, border_width=1)
    table.cell(dash, 0, 0, isEn ? "Structure" : "الهيكل الحالي", text_color=color.white, text_size=size.small, width=13)
    table.cell(dash, 1, 0, close > lastH ? (isEn ? "Bullish" : "صاعد ↑") : (isEn ? "Bearish" : "هابط ↓"), bgcolor=close > lastH ? color.new(color.lime, 40) : color.new(color.red, 40), text_color=color.white)
    int timeToNode = int(math.abs(lastH_bar - lastL_bar) * 0.618) - (bar_index - math.max(lastH_bar, lastL_bar))
    table.cell(dash, 0, 1, isEn ? "Next Node In" : "الفترة القادمة", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(math.max(0, timeToNode)) + (isEn ? " Bars" : " شمعة"), text_color=#FFD700)
    table.cell(dash, 0, 2, isEn ? "Liquidity" : "حالة السيولة", text_color=color.white, text_size=size.small)
    ls_text = isB_LS ? (isEn ? "B-Liquidity" : "سحب شرائي") : isS_LS ? (isEn ? "S-Liquidity" : "سحب بيعي") : (isEn ? "Stable" : "مستقر")
    table.cell(dash, 1, 2, ls_text, text_color=isB_LS ? color.lime : isS_LS ? color.red : color.gray)
    table.cell(dash, 0, 3, isEn ? "Strength" : "قوة الزخم", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(momentum, "0.0"), text_color=momentum > 50 ? color.lime : color.red)
    // إضافة سطر الـ Confluence Score
    table.cell(dash, 0, 4, txtConf, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(confScore) + "%", text_color=scoreColor)
 
// ── الأهداف الفنية / Technical Targets──
var line t1_line = na, var line t2_line = na, var line t3_line = na, var line t4_line = na, var line t5_line = na, var line t5b_line = na, var line t6_line = na, var line t6b_line = na, var line t7_line = na
var label t1_lbl = na, var label t2_lbl = na, var label t3_lbl = na, var label t4_lbl = na, var label t5_lbl = na, var label t5b_lbl = na, var label t6_lbl = na, var label t6b_lbl = na, var label t7_lbl = na
 
var float alertLevel = na 
 
if msbUp
    float wave = lastH - lastL
    float t1 = lastH + (wave * 0.618), float t2 = lastH + (wave * 1.0), float t3 = lastH + (wave * 1.414)
    float t4 = lastH + (wave * 1.618), float t5 = lastH + (wave * 2.0), float t5b = lastH + (wave * 2.618), float t6 = lastH + (wave * 3.0), float t6b = lastH + (wave * 3.618), float t7 = lastH + (wave * 4.0)
    alertLevel := t1
    line.delete(t1_line), line.delete(t2_line), line.delete(t3_line), line.delete(t4_line), line.delete(t5_line), line.delete(t5b_line), line.delete(t6_line), line.delete(t6b_line), line.delete(t7_line)
    label.delete(t1_lbl), label.delete(t2_lbl), label.delete(t3_lbl), label.delete(t4_lbl), label.delete(t5_lbl), label.delete(t5b_lbl), label.delete(t6_lbl), label.delete(t6b_lbl), label.delete(t7_lbl)
    t1_line := line.new(bar_index, t1, bar_index + 60, t1, color=color.new(color.lime, 50), style=line.style_dashed, extend=extend.right)
    t1_lbl  := label.new(bar_index + 55, t1, txtNear + str.tostring(t1, "#.##"), color=color.new(color.black, 100), textcolor=color.lime, style=label.style_label_down, size=size.small)
    t2_line := line.new(bar_index, t2, bar_index + 60, t2, color=color.new(color.lime, 30), style=line.style_dotted, extend=extend.right)
    t2_lbl  := label.new(bar_index + 55, t2, txtPartial + str.tostring(t2, "#.##"), color=color.new(color.black, 100), textcolor=color.lime, style=label.style_label_down, size=size.small)
    t3_line := line.new(bar_index, t3, bar_index + 60, t3, color=color.rgb(255, 215, 0), width=1, extend=extend.right)
    t3_lbl  := label.new(bar_index + 55, t3, txtGolden + str.tostring(t3, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(255, 215, 0), style=label.style_label_down, size=size.small)
    t4_line := line.new(bar_index, t4, bar_index + 60, t4, color=color.rgb(0, 191, 255), width=1, extend=extend.right)
    t4_lbl  := label.new(bar_index + 55, t4, txtDiamond + str.tostring(t4, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(0, 191, 255), style=label.style_label_down, size=size.small)
    t5_line := line.new(bar_index, t5, bar_index + 60, t5, color=color.rgb(255, 255, 255), width=1, style=line.style_dotted, extend=extend.right)
    t5_lbl  := label.new(bar_index + 55, t5, txtHistory + str.tostring(t5, "#.##"), color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_down, size=size.small)
    t5b_line := line.new(bar_index, t5b, bar_index + 60, t5b, color=color.rgb(147, 112, 219), width=1, style=line.style_dashed, extend=extend.right)
    t5b_lbl  := label.new(bar_index + 55, t5b, txtCosmic + str.tostring(t5b, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(147, 112, 219), style=label.style_label_down, size=size.small)
    t6_line := line.new(bar_index, t6, bar_index + 60, t6, color=color.rgb(255, 0, 255), width=1, style=line.style_dashed, extend=extend.right)
    t6_lbl  := label.new(bar_index + 55, t6, txtAstron + str.tostring(t6, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(255, 0, 255), style=label.style_label_down, size=size.small)
    t6b_line := line.new(bar_index, t6b, bar_index + 60, t6b, color=color.rgb(255, 165, 0), width=1, style=line.style_dotted, extend=extend.right)
    t6b_lbl  := label.new(bar_index + 55, t6b, txtSupern + str.tostring(t6b, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(255, 165, 0), style=label.style_label_down, size=size.small)
    t7_line := line.new(bar_index, t7, bar_index + 60, t7, color=color.rgb(255, 255, 0), width=1, style=line.style_solid, extend=extend.right)
    t7_lbl  := label.new(bar_index + 55, t7, txtExtreme + str.tostring(t7, "#.##"), color=color.new(color.black, 100), textcolor=color.rgb(255, 255, 0), style=label.style_label_down, size=size.small)
 
if msbDown
    float wave = lastH - lastL
    float t1 = lastL - (wave * 0.618)
    alertLevel := t1
    line.delete(t1_line), line.delete(t2_line), line.delete(t3_line), line.delete(t4_line), line.delete(t5_line), line.delete(t5b_line), line.delete(t6_line), line.delete(t6b_line), line.delete(t7_line)
    label.delete(t1_lbl), label.delete(t2_lbl), label.delete(t3_lbl), label.delete(t4_lbl), label.delete(t5_lbl), label.delete(t5b_lbl), label.delete(t6_lbl), label.delete(t6b_lbl), label.delete(t7_lbl)
    t1_line := line.new(bar_index, t1, bar_index + 60, t1, color=color.new(color.red, 50), style=line.style_dashed, extend=extend.right)
    t1_lbl  := label.new(bar_index + 55, t1, txtNear + str.tostring(t1, "#.##"), color=color.new(color.black, 100), textcolor=color.red, style=label.style_label_up, size=size.small)
 
// ── التقسيم الزمني / Time Partitioning──
var line vT1 = na, var line vT2 = na, var line vT3 = na
var label lT1 = na, var label lT2 = na, var label lT3 = na
if not na(ph) or not na(pl)
    int timeDiff = math.abs(lastH_bar - lastL_bar)
    int node1 = bar_index + int(timeDiff * 0.618)
    int node2 = bar_index + int(timeDiff * 1.000)
    int node3 = bar_index + int(timeDiff * timeRatio) 
    line.delete(vT1), line.delete(vT2), line.delete(vT3)
    label.delete(lT1), label.delete(lT2), label.delete(lT3)
    vT1 := line.new(node1, low, node1, high, xloc=xloc.bar_index, extend=extend.both, color=color.new(#FFD700, 60), style=line.style_dashed)
    lT1 := label.new(node1, high, txtT1, color=color.new(#FFD700, 100), textcolor=#FFD700, size=size.tiny, style=label.style_label_down)
    vT2 := line.new(node2, low, node2, high, xloc=xloc.bar_index, extend=extend.both, color=color.new(#FFD700, 40), style=line.style_dotted)
    lT2 := label.new(node2, high, txtT2, color=color.new(#FFD700, 100), textcolor=#FFD700, size=size.tiny, style=label.style_label_down)
    vT3 := line.new(node3, low, node3, high, xloc=xloc.bar_index, extend=extend.both, color=color.new(#FFD700, 10), width=1)
    lT3 := label.new(node3, high, txtT3, color=color.new(#FFD700, 100), textcolor=#FFD700, size=size.tiny, style=label.style_label_down)
 
// ── مصفوفة الترندات والإشارات والأوردر بلوك / Matrix, Signals & OB──
var line trendH = na
var line trendL = na
if showTrends
    if not na(ph)
        line.delete(trendH), trendH := line.new(ta.valuewhen(not na(ph), bar_index[lookback], 1), ta.valuewhen(not na(ph), ph, 1), bar_index[lookback], ph, color=color.orange, width=2, extend=extend.right)
    if not na(pl)
        line.delete(trendL), trendL := line.new(ta.valuewhen(not na(pl), bar_index[lookback], 1), ta.valuewhen(not na(pl), pl, 1), bar_index[lookback], pl, color=color.blue, width=2, extend=extend.right)
 
plotshape(msbUp, title="BUY Signal", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(msbDown, title="SELL Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
 
var box buyZone = na
var box sellZone = na
if not na(pl)
    box.delete(buyZone), buyZone := box.new(bar_index[lookback], pl + (ta.atr(14) * atrMult), bar_index + 40, pl, bgcolor=color.rgb(0, 255, 0, 90), border_color=color.lime, extend=extend.right, text=txtDemand, text_color=color.lime, text_size=size.tiny, text_halign=text.align_right)
if not na(ph)
    box.delete(sellZone), sellZone := box.new(bar_index[lookback], ph, bar_index + 40, ph - (ta.atr(14) * atrMult), bgcolor=color.rgb(255, 0, 0, 90), border_color=color.red, extend=extend.right, text=txtSupply, text_color=color.red, text_size=size.tiny, text_halign=text.align_right)
 
if isB_LS
    label.new(bar_index, low, txtBLS, color=color.new(color.lime, 100), textcolor=color.lime, style=label.style_label_up, size=size.small, yloc=yloc.belowbar)
if isS_LS
    label.new(bar_index, high, txtSLS, color=color.new(color.red, 100), textcolor=color.red, style=label.style_label_down, size=size.small, yloc=yloc.abovebar)
 
// ── التنبيهات الديناميكية / Dynamic Alerts──
if not na(alertLevel) and ta.cross(close, alertLevel)
    alert(" Target Reached: 0.618", alert.freq_once_per_bar)
 
if msbUp
    alert("🚀 " +"Bullish Breakout  ", alert.freq_once_per_bar)
 
if msbDown
    alert("⚠️ " + " :  Bearish Breakdown", alert.freq_once_per_bar)
````
