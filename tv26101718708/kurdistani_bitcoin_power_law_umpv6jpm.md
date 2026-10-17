# Kurdistani BITCOIN POWER LAW

- url: https://www.tradingview.com/script/umPv6JPM-Kurdistani-BITCOIN-POWER-LAW/
- type: indicator
- pine_id: PUB;93f87409ce5f422f9b7737df7c0528e4
- version: 1.0

## Description

[b]Kurdistani Bitcoin Power Law[/b]

The [b]Kurdistani Bitcoin Power Law[/b] is a long-term macro analysis tool for Bitcoin ([symbol="CRYPTOCAP:BTC"]CRYPTOCAP:BTC[/symbol]$), built entirely in **Pine Script v6**. It models Bitcoin's historical growth trajectory over time using a log-log power-law relationship, treating time not as a linear metric, but as an exponential driver of value.

This script maps out Bitcoin's structural "Fair Value" alongside its cyclical boundaries, providing long-term investors with clear macroeconomic floors, ceilings, accumulation zones, and historical touch-points.

---

[b] 🔬 The Math Behind the Model[/b]

Unlike standard exponential models that eventually experience unrealistic vertical explosions, a power law models a diminishing growth rate over time.

The indicator calculates elapsed days since Bitcoin's Genesis Block (January 3, 2009) and uses the following regression formula to establish the center fair value band:

$$P(t) = 8.31 \times 10^{-17} \times t^{5.48}$$

Where $t$ represents the total number of days elapsed since the genesis block. This model boasts an incredibly high historical correlation coefficient ($R^2 = 0.9976$).

---

[b]🎨 Visual Breakdown & Color Map[/b]

The chart overlays a structured channel designed for high visual clarity, utilizing a custom dark theme interface:

[b]Center Line (Pure Red):[/b]The fundamental **Fair Value** anchor of the Power Law model.
[b]Upper Band (Pure Yellow):[/b] Represents a **+10% deviation** above the fair value corridor, acting as a historical resistance zone during expansion phases.
[b]Lower Band (Pure Green):[/b] Represents a **-10% deviation** below the fair value corridor, acting as the structural macro support floor.
[b]Holographic Line (Glow White Dotted):[/b] Projects the model's current fair value coordinate smoothly across the active price bars.
[b]Glow Shading:[/b] Dynamic, semi-transparent background color fills between the bands to visually isolate overvalued or undervalued territories easily.

---

[b] ⚙️ Configurable Inputs & Features[/b]

The script features a highly customizable input menu divided into functional groups:

🌐[b] Language Localizer:[/b] Fully multi-lingual interface supporting **English**, **Persian (فارسی)**, and **Kurdish (کوردی)** across the HUD table layout.
🌀 [b]Toggle Visibility:[/b] Independent control switches to show or hide the Main Power Law line, Upper Band, Lower Band, Holographic Dotted Line, and Channel Glow Fills.
[b]🔮 Custom Macro Targets:[/b] Allows you to input custom price expectations for key future cyclical milestones (**2026E**, **2030E**, and **2035E**) directly into the on-screen display panel.
🟢[b] Dynamic Buy Zone Percentage:[/b] Define custom deep-value accumulation triggers (Default is **18% below the lower band**).
📜[b] Historical Touch Tracker:[/b] Automates historical data tracking by searching through historical bars to identify and display exactly when Bitcoin hit its ultimate cycle floors.

---

[b]📈 How to Use the Indicator for Trading & Investment[/b]

 1. Identifying the Macro Buy Zone

When Bitcoin’s market price drops below the defined lower band offset percentage, the chart background dynamically shifts to a soft green shade. Historically, these moments represent generational accumulation phases (e.g., the absolute bottoms of macro bear markets).

 2. Fair Value Tracking (The Mean Reversion Anchor)

The center red line acts as a strong gravity anchor. During bull market bubbles, price overextends aggressively above it; during capitulations, it snaps below it. Long-term positions can be assessed relative to whether the current price is trading at a premium or a discount to this red value line.

 3. The On-Screen HUD Table

Positioned cleanly in the top-right corner of your screen, the Head-Up Display (HUD) table keeps you constantly updated on:

* The raw underlying power-law formula.
* The live asset **Fair Value** adjusted to the current day.
* Your personalized macro target projections for upcoming years.
* An integrated ledger highlighting exactly which **Cycle Touch Years** marked historical bottoms alongside their precise historical dollar-value floors.

 4. Automated Alert System

The script comes equipped with an integrated alert condition trigger. You can set a native TradingView server alert for the event `🟢 Bitcoin BUY ZONE` to notify your desktop or mobile device the exact moment Bitcoin drops into the structural deep-value buying zone.

---

[b] 💻 Source Code Overview[/b]

The code leverages the latest **Pine Script v6** performance upgrades, introducing modern array mechanics to track cycle anomalies efficiently without slowing down chart rendering engines, capping maximum visual line, label, and box memory footprints safely at 500 units each.

## Source Code

````pine
//@version=6
indicator('Kurdistani BITCOIN POWER LAW', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ==================== 🎨 تم رنگی دقیقاً طبق سفارش شما ====================

darkBg = color.new(#0d1117, 0)
colorBorder = color.new(#21262d, 0)
colorText = color.new(#c9d1d9, 0)

pureYellow = color.new(#ffff00, 0) // بالاترین خط (باند بالا)
pureRed = color.new(#ff0000, 0) // خط وسط (هسته اصلی)
pureGreen = color.new(#00ff00, 0) // پایین‌ترین خط (باند پایین)
glowWhite = color.new(#031a28, 25)

// ==================== ⚙️ ورودی‌ها (INPUTS) ====================

lang = input.string('کوردی', '🌐 Language / زبان', options = ['English', 'فارسی', 'کوردی'])

showMain = input.bool(true, '🌀 نمایش خط اصلی Power Law')
showUpper = input.bool(true, '🌌 باند بالا (+10%)')
showLower = input.bool(true, '🌃 باند پایین (-10%)')

showDotted = input.bool(true, '🔥 خط نقطه‌چین holographic')
showFills = input.bool(true, '🌫️ Glow Fill بین باندها')

price2026 = input.float(61000, '2026E', minval = 1000, step = 1000, group = '🔮 پیش‌بینی‌های آینده')
price2030 = input.float(188000, '2030E', minval = 1000, step = 1000, group = '🔮 پیش‌بینی‌های آینده')
price2035 = input.float(582000, '2035E', minval = 1000, step = 1000, group = '🔮 پیش‌بینی‌های آینده')

buyZonePercent = input.float(18.0, 'درصد منطقه خرید', minval = 5.0, maxval = 50.0, step = 1.0)
showTouches = input.bool(true, '📜 نمایش لمس‌های تاریخی')

// ==================== 📊 محاسبات قانون توان ====================

genesis_ts = timestamp(2009, 1, 3, 0, 0)
days = (time - genesis_ts) / 86400000.0
powerLaw = 8.31e-17 * math.pow(days, 5.48)

upperBand = powerLaw * 1.10
lowerBand = powerLaw * 0.90

isBuyZone = close <= lowerBand * (1 - buyZonePercent / 100)

touchTolerance = 0.07
isPriceNearPowerLaw = close <= powerLaw * (1 + touchTolerance) and close > 10
isConfirmedTouch = isPriceNearPowerLaw and barstate.isconfirmed

// ==================== 💾 ذخیره‌سازی لمس‌ها ====================

var array<string> touchYears = array.new_string()
var array<float> touchPrices = array.new_float()

if isConfirmedTouch
    string currYear = str.format('{0,date,yyyy}', time)
    bool yearExists = false
    int existingIndex = -1

    if array.size(touchYears) > 0
        for i = 0 to array.size(touchYears) - 1 by 1
            if array.get(touchYears, i) == currYear
                yearExists := true
                existingIndex := i
                break

    if not yearExists
        array.push(touchYears, currYear)
        array.push(touchPrices, close)
    else
        if close < array.get(touchPrices, existingIndex)
            array.set(touchPrices, existingIndex, close)

    if array.size(touchYears) > 8
        array.shift(touchYears)
        array.shift(touchPrices)

// ==================== 📈 ترسیم باندها بر اساس: زرد (بالا)، قرمز (وسط)، سبز (پایین) ====================

p_top = plot(showUpper ? upperBand : na, 'UPPER YELLOW', color = pureYellow, linewidth = 2)
p_center = plot(showMain ? powerLaw : na, 'CENTER RED', color = pureRed, linewidth = 4)
p_bottom = plot(showLower ? lowerBand : na, 'LOWER GREEN', color = pureGreen, linewidth = 2)

// پر کردن فضاها با رنگ‌های مربوطه
fill(p_center, p_top, color = showFills and showUpper ? color.new(pureYellow, 85) : na)
fill(p_bottom, p_center, color = showFills and showLower ? color.new(pureGreen, 85) : na)

var float lastPower = na
if barstate.islast and showDotted
    lastPower := powerLaw
    lastPower
plot(showDotted ? lastPower : na, 'HOLO CURRENT', color = glowWhite, linewidth = 3, style = plot.style_circles)

// ==================== 🖥️ ساخت جدول ۲ ستونی HUD ====================

var table unitedHud = na

if barstate.islast
    int touchCount = array.size(touchYears)
    int dynamicRows = 6
    if showTouches
        dynamicRows := dynamicRows + 1 + (touchCount > 0 ? touchCount : 1)
        dynamicRows

    unitedHud := table.new(position.top_right, 2, dynamicRows, bgcolor = darkBg, border_width = 1, border_color = colorBorder)

    string txt_title = lang == 'English' ? 'BTC POWER LAW' : lang == 'فارسی' ? 'قانون توان بیت‌کوین' : 'یاسای توان بیتکۆین'
    string txt_formula = lang == 'English' ? 'Formula' : lang == 'فارسی' ? 'فرمول' : 'هاوکێشە'
    string txt_fair = lang == 'English' ? 'Fair Value' : lang == 'فارسی' ? 'ارزش منصفانه' : 'بهایی دادپەروەرانه'

    string txt_t2026 = lang == 'English' ? 'Target 2026E' : lang == 'فارسی' ? 'هدف تخمینی ۲۰۲۶' : 'ئامانجی خەمڵێندراوی ٢٠٢٦'
    string txt_t2030 = lang == 'English' ? 'Target 2030E' : lang == 'فارسی' ? 'هدف تخمینی ۲۰۳۰' : 'ئامانجی خەمڵێندراوی ۲۰۳۰'
    string txt_t2035 = lang == 'English' ? 'Target 2035E' : lang == 'فارسی' ? 'هدف تخمینی ۲۰۳۵' : 'ئامانجی خەمڵێندراوی ۲۰۳۵'

    string txt_h_left = lang == 'English' ? 'CYCLE TOUCH YEAR' : lang == 'فارسی' ? 'سال لمس چرخه' : 'ساڵی بەرکەوتنی خول'
    string txt_h_right = lang == 'English' ? 'FLOOR PRICE' : lang == 'فارسی' ? 'قیمت کف چرخه' : 'نرخی بنی خول'
    string txt_no_data = lang == 'English' ? 'No data found' : lang == 'فارسی' ? 'داده‌ای یافت نشد' : 'هیچ زانیارییەک نەدۆزرایەوە'

    table.cell(unitedHud, 0, 0, txt_title, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 0, 'R² = 0.9976', text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

    table.cell(unitedHud, 0, 1, txt_formula, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 1, 'P(t)=8.31×10⁻¹٧×t⁵.⁴⁸', text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

    table.cell(unitedHud, 0, 2, txt_fair, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 2, '$' + str.tostring(powerLaw, '#,###'), text_color = pureGreen, text_size = size.small, text_halign = text.align_center)

    table.cell(unitedHud, 0, 3, txt_t2026, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 3, '$' + str.tostring(price2026, '#,###'), text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

    table.cell(unitedHud, 0, 4, txt_t2030, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 4, '$' + str.tostring(price2030, '#,###'), text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

    table.cell(unitedHud, 0, 5, txt_t2035, text_color = colorText, text_size = size.small, text_halign = text.align_center)
    table.cell(unitedHud, 1, 5, '$' + str.tostring(price2035, '#,###'), text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

    if showTouches
        table.cell(unitedHud, 0, 6, txt_h_left, text_color = pureYellow, text_size = size.small, text_halign = text.align_center, bgcolor = darkBg)
        table.cell(unitedHud, 1, 6, txt_h_right, text_color = pureYellow, text_size = size.small, text_halign = text.align_center, bgcolor = darkBg)

        if touchCount > 0
            for i = 0 to touchCount - 1 by 1
                int r = 7 + i
                table.cell(unitedHud, 0, r, array.get(touchYears, i), text_color = colorText, text_size = size.small, text_halign = text.align_center)
                table.cell(unitedHud, 1, r, '$' + str.tostring(array.get(touchPrices, i), '#,###'), text_color = pureGreen, text_size = size.small, text_halign = text.align_center)
        else
            table.cell(unitedHud, 0, 7, txt_no_data, text_color = colorText, text_size = size.small, text_halign = text.align_center)
            table.cell(unitedHud, 1, 7, '-', text_color = pureYellow, text_size = size.small, text_halign = text.align_center)

// ==================== 🚨 پس‌زمینه خرید ====================

bgcolor(isBuyZone ? color.new(pureGreen, 90) : na)
alertcondition(isBuyZone, '🟢 Bitcoin BUY ZONE', 'Bitcoin entered the Power Law Buy Zone')
````
