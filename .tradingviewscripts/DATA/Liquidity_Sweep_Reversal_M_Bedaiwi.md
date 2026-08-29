<!-- tradingview-pine-id: PUB;744d6947ed6e490eb6d3abb3702d7209 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Reversal | M. Bedaiwi

Source: https://www.tradingview.com/script/6DiYTZif-Liquidity-Sweep-Reversal-M-Bedaiwi/

## Description

Liquidity Sweep Reversal | M. Bedaiwi

Overview

Liquidity Sweep Reversal is a price-action indicator designed to identify potential market reversals following liquidity sweeps above previous highs or below previous lows.

The indicator monitors a higher-period liquidity range. When price moves beyond one side of that range, it waits for a subsequent Market Structure Shift (MSS) before generating a potential Buy or Sell signal.

A liquidity sweep alone does not generate an entry. Market structure confirmation is an essential part of the setup.

How It Works

• A sweep below the previous liquidity low prepares a potential long setup.
• A sweep above the previous liquidity high prepares a potential short setup.
• Entry confirmation is based on a Market Structure Shift using the selected MSS Swing Length.
• Liquidity sweeps can be detected using candle wicks or closing prices.
• Classic and Adaptive entry methods are available.
• If the selected Higher Timeframe is equal to or lower than the chart timeframe, the indicator automatically uses a reference period equivalent to four chart bars.

The indicator calculates a rolling liquidity range on the current chart equivalent to the selected reference period. It does not request independent higher-timeframe candles through `request.security()`.

Features

• Liquidity sweep detection
• Market structure confirmation
• Potential long and short signals
• Classic and Adaptive entry methods
• Higher-timeframe safety handling
• Automatic four-bar fallback
• Fixed or ATR-based TP/SL levels
• Entry, take-profit and stop-loss alerts
• Optional liquidity zones and sweep markers
• Historical performance dashboard
• Pine Script v6 compatibility

How to Use

1. Select the Chart Timeframe

Choose the chart timeframe according to your trading style:

• 5–15 minutes: Intraday trading
• 1–4 hours: Short-term or swing trading
• Daily: Medium-term trading

Standard candlestick charts are recommended.

2. Select the Higher Timeframe

The Higher Timeframe setting defines the reference period used to calculate liquidity highs and lows.

Suggested combinations:

• 5-minute chart → 30 or 60 minutes
• 15-minute chart → 60 or 240 minutes
• 1-hour chart → 4 hours
• 4-hour chart → Daily
• Daily chart → Weekly

The selected Higher Timeframe should normally be higher than the chart timeframe.

If it is equal to or lower than the chart timeframe, the indicator automatically uses a period equivalent to four chart bars. The liquidity label displays “Auto x4” when this fallback is active.

3. Configure Liquidity Sweep Detection

Breakout Method provides two options:

Wick

Detects a sweep when the candle wick crosses the liquidity level.

• Earlier detection
• More frequent signals
• Greater sensitivity to temporary price spikes

Close

Requires the candle to close beyond the liquidity level.

• Stronger confirmation
• Fewer signals
• Filters some wick-only sweeps

4. Configure Market Structure Confirmation

MSS Swing Length controls the number of candles used to calculate the swing high and swing low for Market Structure Shift confirmation.

• Lower values generate faster and more frequent signals.
• Higher values generate slower and more selective signals.

The default value is 10. A range between 5 and 15 may be used as a starting point, depending on the asset and timeframe.

5. Select the Entry Method

Classic

Uses the traditional reversal approach:

• A sweep below the previous liquidity low prepares a potential long setup.
• A sweep above the previous liquidity high prepares a potential short setup.

Classic mode is generally easier to understand and evaluate.

Adaptive

Uses the indicator’s internal historical behavior to adjust the potential trade direction.

Depending on its internal long and short performance counters, Adaptive mode may occasionally select a continuation direction instead of the traditional reversal direction.

Adaptive mode is experimental, and its behavior may vary between assets and timeframes.

6. Interpret the Signals

Potential Long Setup

• Price sweeps below the previous liquidity low.
• The indicator detects a bullish Market Structure Shift on a later candle.
• A Buy label appears after confirmation.
• Entry, take-profit and stop-loss levels are calculated.

Potential Short Setup

• Price sweeps above the previous liquidity high.
• The indicator detects a bearish Market Structure Shift on a later candle.
• A Sell label appears after confirmation.
• Entry, take-profit and stop-loss levels are calculated.

Liquidity sweep markers show where price crossed a previous liquidity level. Do not enter solely because a sweep marker appears. Wait for the subsequent structure confirmation and Buy or Sell label.

7. Configure Take Profit and Stop Loss

The indicator provides two TP/SL calculation methods:

Dynamic Method

Uses:

• A five-bar ATR
• The selected Risk setting
• The MSS swing high or low
• An internal reward-to-risk multiplier of approximately 0.9

For long trades, the stop-loss is placed below the MSS swing low with an additional ATR-based distance. The target is calculated above the entry using the entry-to-stop distance.

For short trades, the stop-loss is placed above the MSS swing high with an additional ATR-based distance. The target is calculated below the entry using the entry-to-stop distance.

Fixed Method

Uses user-defined percentages from the entry price.

Default values:

• Take Profit: 0.3%
• Stop Loss: 0.4%

These values should be adjusted according to the asset’s volatility and the selected timeframe.

Risk Setting

The Risk setting controls the ATR multiplier used to determine the Dynamic stop-loss distance:

• Highest: 10
• High: 6.5
• Normal: 5.5
• Low: 3.5
• Lowest: 1.15

This setting controls the distance of the stop-loss. It does not calculate position size or the monetary amount at risk.

A wider stop-loss should normally be combined with a smaller position size.

8. Select the TP/SL Layout

Default

Displays dashed lines with TP and SL labels.

Alternative

Displays take-profit and stop-loss areas as colored boxes.

This setting changes only the visual layout and does not change the calculated prices.

9. Enable Visual Elements

• Show Liquidity Zones: Displays the reference liquidity areas.
• Liq Grabs: Displays detected liquidity sweep markers.
• TP / SL: Displays entry, take-profit and stop-loss levels.
• Buy and Sell Colors: Controls the signal and zone colors.
• Text Color: Controls the color of labels and displayed values.

10. Create Alerts

Alerts are available for:

• Buy Signal
• Sell Signal
• Take-Profit Signal
• Stop-Loss Signal

To create an alert:

1. Open TradingView’s alert menu.

2. Select Liquidity Sweep Reversal.

3. Choose the required alert condition.

4. Select the notification method.

5. Consider using “Once Per Bar Close” to reduce intrabar signals.

6. Apply Practical Confirmation

For more selective setups, consider confirming signals with:

• Higher-timeframe trend direction
• Support and resistance levels
• Trading volume
• Market session and available liquidity
• Supply and demand zones
• Candle-close confirmation

Always review the displayed entry, target and stop-loss levels before taking a trade. Calculate position size independently according to the stop-loss distance.

Example Starting Configuration

For a 15-minute chart:

• Higher Timeframe: 60 minutes
• MSS Swing Length: 10
• Breakout Method: Close
• Entry Method: Classic
• TP / SL Method: Dynamic
• Risk: Low

These settings are only a starting point and are not universally optimal.

Historical Dashboard

The Liquidity Sweep Backtest dashboard displays:

• Total Entries
• Wins
• Losses
• Win Rate
• Average Profit
• Total Profit

The dashboard is intended for approximate comparison between settings. The script is an indicator, not a strategy, and the dashboard is not equivalent to TradingView’s Strategy Tester.

The calculations do not include:

• Brokerage commissions
• Slippage
• Bid-ask spread
• Position sizing
• Price gaps
• Actual order execution
• Taxes or financing costs

Historical results do not guarantee future performance.

Practical Limitations

The indicator may be less effective during:

• Strong one-directional trends
• Low-liquidity market conditions
• Major news releases
• Large price gaps
• Narrow or random consolidation
• Highly volatile intrabar movement
• Non-standard chart types
• Poorly matched timeframe settings

The indicator processes approximately the most recent 4,900 bars to maintain performance. Results may change when the symbol, timeframe or settings are changed.

Attribution and Modifications

Original open-source code by fluxchart.

Modified by Mohammed Bedaiwi (mbedaiwi2).

Modifications include:

• Conversion to Pine Script v6
• Safer higher-timeframe handling
• Automatic four-bar fallback when the selected timeframe is not higher than the chart timeframe
• Dashboard calculation safeguards
• Independent indicator naming and presentation

The modified source code remains available under the Mozilla Public License 2.0.

Important Notice

This indicator is provided for educational and analytical purposes only. It does not constitute financial advice, an investment recommendation or a guarantee of profitable results.

Trading and investing involve substantial risk. Users should perform independent analysis, apply appropriate position sizing and risk management, and avoid risking funds they cannot afford to lose.

────────────────────────────

الوصف العربي

نظرة عامة

مؤشر Liquidity Sweep Reversal هو مؤشر لتحليل حركة السعر، صُمم لاكتشاف فرص الانعكاس المحتملة بعد سحب السيولة أعلى القمم السابقة أو أسفل القيعان السابقة.

يراقب المؤشر نطاقًا مرجعيًا للسيولة. عندما يتحرك السعر خارج أحد طرفي هذا النطاق، ينتظر المؤشر تغيرًا لاحقًا في هيكل السوق قبل إصدار إشارة شراء أو بيع محتملة.

لا يؤدي سحب السيولة وحده إلى إصدار إشارة دخول، بل يجب ظهور تأكيد لاحق من هيكل السوق.

طريقة العمل

• سحب السيولة أسفل القاع السابق يجهز فرصة شراء محتملة.
• سحب السيولة أعلى القمة السابقة يجهز فرصة بيع محتملة.
• يتم تأكيد الدخول بواسطة تغير هيكل السوق وفق إعداد MSS Swing Length.
• يمكن اكتشاف سحب السيولة بواسطة ظلال الشموع أو أسعار الإغلاق.
• يتوفر أسلوبا دخول Classic وAdaptive.
• إذا كان الإطار المرجعي مساويًا أو أقل من إطار الرسم، يستخدم المؤشر تلقائيًا فترة تعادل أربع شمعات.

الميزات

• اكتشاف سحب السيولة
• تأكيد تغير هيكل السوق
• إشارات شراء وبيع محتملة
• أسلوبا دخول Classic وAdaptive
• معالجة آمنة للإطار الزمني
• أهداف ووقف خسارة ثابتة أو مبنية على ATR
• تنبيهات الشراء والبيع والهدف ووقف الخسارة
• مناطق سيولة وعلامات سحب اختيارية
• لوحة نتائج تاريخية
• التوافق مع Pine Script v6

طريقة الاستخدام

1. اختر إطار الرسم

• 5–15 دقيقة: للتداول اليومي
• ساعة إلى 4 ساعات: للتداول قصير أو متوسط الأجل
• يومي: للتداول متوسط الأجل

يفضل استخدام رسم الشموع العادي.

2. اختر الإطار المرجعي الأعلى

إعدادات مقترحة:

• رسم 5 دقائق ← 30 أو 60 دقيقة
• رسم 15 دقيقة ← 60 أو 240 دقيقة
• رسم ساعة ← 4 ساعات
• رسم 4 ساعات ← يومي
• رسم يومي ← أسبوعي

إذا كان الإطار المختار مساويًا أو أقل من إطار الرسم، يستخدم المؤشر فترة تلقائية تعادل أربع شمعات، وتظهر عبارة `Auto x4`.

3. اختر طريقة اكتشاف سحب السيولة

Wick

يعتمد على اختراق ظل الشمعة:

• اكتشاف أسرع
• إشارات أكثر
• حساسية أعلى للحركات اللحظية

Close

يشترط إغلاق الشمعة بعد مستوى السيولة:

• تأكيد أقوى
• إشارات أقل
• تصفية بعض اختراقات الظلال

4. اضبط MSS Swing Length

يحدد عدد الشمعات المستخدمة لتأكيد تغير هيكل السوق.

• القيمة المنخفضة تعطي إشارات أسرع وأكثر عددًا.
• القيمة المرتفعة تعطي إشارات أقل وأكثر انتقائية.

القيمة الافتراضية هي 10، ويمكن البدء بنطاق بين 5 و15.

5. اختر أسلوب الدخول

Classic

• سحب سيولة القاع يؤدي إلى البحث عن شراء.
• سحب سيولة القمة يؤدي إلى البحث عن بيع.

Adaptive

يستخدم السلوك التاريخي الداخلي للمؤشر لتعديل اتجاه الصفقة المحتمل، وقد يختار أحيانًا اتجاهًا استمراريًا بدل الانعكاس التقليدي.

يفضل البدء بوضع Classic لأنه أسهل في الفهم والتقييم.

6. قراءة الإشارات

إشارة شراء محتملة:

• يسحب السعر السيولة أسفل القاع السابق.
• يظهر تغير صاعد في هيكل السوق على شمعة لاحقة.
• تظهر علامة Buy.
• يتم حساب الدخول والهدف ووقف الخسارة.

إشارة بيع محتملة:

• يسحب السعر السيولة أعلى القمة السابقة.
• يظهر تغير هابط في هيكل السوق على شمعة لاحقة.
• تظهر علامة Sell.
• يتم حساب الدخول والهدف ووقف الخسارة.

لا تدخل اعتمادًا على علامة سحب السيولة وحدها، بل انتظر تأكيد هيكل السوق وظهور Buy أو Sell.

7. إعداد الهدف ووقف الخسارة

Dynamic

يستخدم:

• ATR بطول خمس شمعات
• مستوى Risk المختار
• قمة أو قاع MSS
• نسبة عائد إلى مخاطرة داخلية تقارب 0.9

Fixed

يستخدم نسبًا ثابتة من سعر الدخول.

القيم الافتراضية:

• الهدف: 0.3%
• وقف الخسارة: 0.4%

يجب تعديل هذه القيم وفق تذبذب الأصل والإطار الزمني.

إعداد Risk يتحكم في المسافة بين الدخول ووقف الخسارة، ولا يحسب حجم الصفقة أو المبلغ المالي المعرض للخسارة.

8. العناصر المرئية

• Show Liquidity Zones: إظهار مناطق السيولة
• Liq Grabs: إظهار علامات سحب السيولة
• TP / SL: إظهار الدخول والهدف ووقف الخسارة
• Default Layout: عرض المستويات على شكل خطوط
• Alternative Layout: عرض المستويات على شكل مناطق ملونة

9. التنبيهات

يدعم المؤشر تنبيهات:

• الشراء
• البيع
• الوصول إلى الهدف
• الوصول إلى وقف الخسارة

يفضل ضبط التنبيه على مرة واحدة عند إغلاق الشمعة لتقليل الإشارات اللحظية.

10. التأكيد العملي

يمكن تحسين انتقائية الإشارات باستخدام:

• اتجاه الإطار الزمني الأعلى
• الدعم والمقاومة
• حجم التداول
• جلسة السوق والسيولة
• مناطق العرض والطلب
• تأكيد إغلاق الشمعة

يجب مراجعة الهدف ووقف الخسارة وحساب حجم الصفقة بصورة مستقلة قبل الدخول.

لوحة النتائج التاريخية

تعرض لوحة Liquidity Sweep Backtest:

• إجمالي الصفقات
• الصفقات الرابحة
• الصفقات الخاسرة
• نسبة النجاح
• متوسط النتيجة
• إجمالي النتيجة

اللوحة مخصصة للمقارنة التقريبية بين الإعدادات. السكريبت مؤشر وليس استراتيجية، ولذلك لا تعادل اللوحة Strategy Tester في TradingView.

لا تتضمن النتائج العمولات أو الانزلاق السعري أو فرق العرض والطلب أو حجم الصفقة أو إمكانية التنفيذ الفعلي.

حقوق الكود والتعديلات

الكود الأصلي مفتوح المصدر من تطوير fluxchart.

تم تعديله بواسطة Mohammed Bedaiwi (mbedaiwi2).

تشمل التعديلات:

• التحويل إلى Pine Script v6
• تحسين معالجة الإطار الزمني
• استخدام فترة تلقائية تعادل أربع شمعات عند الحاجة
• حماية حسابات لوحة النتائج
• تغيير اسم وهوية المؤشر بصورة مستقلة

يظل الكود المعدل خاضعًا لترخيص Mozilla Public License 2.0.

إخلاء المسؤولية

هذا المؤشر أداة تعليمية وتحليلية فقط، ولا يمثل توصية مالية أو ضمانًا للربح.

ينطوي التداول والاستثمار على مخاطر. يجب على المستخدم إجراء تحليله المستقل، واستخدام حجم صفقة مناسب، وتطبيق إدارة المخاطر وعدم المخاطرة بأموال لا يستطيع تحمل خسارتها.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mbedaiwi2
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at:
// https://mozilla.org/MPL/2.0/
//
// Original code © fluxchart
// Modified by Mohammed Bedaiwi (mbedaiwi2), 2026
// Modifications: Pine Script v6 conversion, safer higher-timeframe handling,
// dashboard calculation safeguards, and independent indicator naming.

//@version=6

const bool DEBUG = false
const int maxDistanceToLastBar = 4900 // Affects Running Time
const int atrLen = 5
const bool maxTPLastHour = false

var initRun = true

indicator("Liquidity Sweep Reversal | M. Bedaiwi", shorttitle = "LSR | MB", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = maxDistanceToLastBar + 100)

//pivotLenLiq = input.int(4, "Pivot Length", group = "General Configuration", display = display.none)
mssOffset = input.int(10, "MSS Swing Length", group = "General Configuration")
higherTimeframe = input.timeframe("60", "Higher Timeframe", group = "General Configuration", tooltip = "If this timeframe is not higher than the chart timeframe, the script automatically uses 4x the chart timeframe instead of stopping with an error.")
breakoutMethod = input.string("Wick", "Breakout Method", options = ["Close", "Wick"], group = "General Configuration")
entryMethod = input.string("Classic", "Entry Method", options = ["Classic", "Adaptive"], group = "General Configuration", tooltip = "The entry method for the indicator to use. Try changing this setting if you are getting poor results.")
dbgTPSLVersion = input.string("Default", "TP / SL Layout", options = ["Default", "Alternative"], group = "General Configuration")
dbgLabelSize = DEBUG ? input.string("Small", "[DBG] Label Size", ["Normal", "Small", "Tiny"], group = "General Configuration") : "Normal"
lblSize = (dbgLabelSize == "Small" ? size.small : dbgLabelSize == "Normal" ? size.normal : size.tiny)

showHL = input.bool(false, "Show Liquidity Zones", inline = "3", group = "General Configuration")
showLiqGrabs = input.bool(true, "Liq Grabs", inline = "3", group = "General Configuration")
showTPSL = input.bool(true, "TP / SL", inline = "3", group = "General Configuration")

tpslMethod = input.string("Dynamic", "TP / SL Method", options = ["Dynamic", "Fixed"], group = "TP / SL")
riskAmount = input.string("Low", "Risk", options = ["Highest", "High", "Normal", "Low", "Lowest"], group = "TP / SL", tooltip = "The risk amount when Dynamic TP / SL method is selected.\n\nDifferent assets may have different volatility so changing this setting may result in change of performance of the indicator.")
customSLATRMult = DEBUG ? input.float(6.5, "Custom Risk Mult", group = "TP / SL") : 6.5
tpPercent = input.float(0.3, "Take Profit %", group = "TP / SL")
slPercent = input.float(0.4, "Stop Loss %", group = "TP / SL")

RR = DEBUG ? input.float(0.9, "Risk:Reward Ratio", group = "Debug") : 0.9

slATRMult = riskAmount == "Highest" ? 10 : riskAmount == "High" ? 6.5 : riskAmount == "Normal" ? 5.5 : riskAmount == "Low" ? 3.5 : riskAmount == "Lowest" ? 1.15 : customSLATRMult

backtestDisplayEnabled = input.bool(true, "Enabled", group = "Backtesting Dashboard", display = display.none)
backtestingLocation = input.string("Top Right", "Position", options = ["Top Right", "Right Center", "Top Center"], group = "Backtesting Dashboard", display = display.none)
fillBackgrounds = input.bool(true, "Fill Backgrounds", group = "Backtesting Dashboard", display = display.none)
screenerColor = input.color(#1B1F2B, 'Background', inline = "1", group = 'Backtesting Dashboard', display = display.none)

highColor = input.color(color.green, "Buy", inline = "colors", group = "Visuals")
lowColor = input.color(color.red, "Sell", inline = "colors", group = "Visuals")
textColor = input.color(color.white, "Text", inline = "colors", group = "Visuals")

buyAlertEnabled = input.bool(true, "Buy Signal", inline = "BS", group = "Alerts")
sellAlertEnabled = input.bool(true, "Sell Signal", inline = "BS", group = "Alerts")
tpAlertEnabled = input.bool(true, "Take-Profit Signal", inline = "TS", group = "Alerts")
slAlertEnabled = input.bool(true, "Stop-Loss Signal ", inline = "TS", group = "Alerts")

buyAlertTick = false
sellAlertTick = false
tpAlertTick = false
slAlertTick = false


type Sweep
    int startTime
    int endTime
    string side
    float price

type TurtleSoup
    string state
    int startTime

    int lastHour = na
    float lastHourHigh = na
    float lastHourLow = na
    Sweep brokenSweep = na
    float slTarget
    float tpTarget
    string entryType
    int entryTime
    int exitTime
    float entryPrice
    float exitPrice
    int dayEndedBeforeExit


var lineX = array.new<line>()
var boxX = array.new<box>()
var labelX = array.new<label>()

var TurtleSoup[] tsList = array.new<TurtleSoup>(0)
var TurtleSoup lastTS = na

atr = ta.atr(atrLen)

diffPercent (float val1, float val2) =>
    (math.abs(val1 - val2) / val2) * 100.0

getPosition (positionText) =>
    if positionText == "Top Right"
        position.top_right
    else if positionText == "Top Center"
        position.top_center
    else if positionText == "Right Center"
        position.middle_right
    else if positionText == "Left Center"
        position.middle_left
    else if positionText == "Bottom Center"
        position.bottom_center
    else if positionText == "Middle Center"
        position.middle_center

int chartTFSeconds = timeframe.in_seconds()
int selectedHTFSeconds = timeframe.in_seconds(higherTimeframe)
bool useSelectedHTF = selectedHTFSeconds > chartTFSeconds
int effectiveHTFSeconds = useSelectedHTF ? selectedHTFSeconds : chartTFSeconds * 4
string effectiveHTFLabel = useSelectedHTF ? higherTimeframe : "Auto x4"

//#region Liqs
// Fall back to four chart bars when the selected HTF is equal to or lower than
// the chart timeframe. This keeps the indicator running while preserving the
// original requirement that the liquidity range comes from a larger period.
int barLength = math.min(maxDistanceToLastBar, math.max(2, int(math.round(float(effectiveHTFSeconds) / chartTFSeconds))))
float high12 = ta.highest(barLength)
float low12 = ta.lowest(barLength)
float highMSS = ta.highest(mssOffset)
float lowMSS = ta.lowest(mssOffset)
int lastHourTime = time[barLength]
//#endregion

//#region Turtle Soup
var highBreaks = 0
var lowBreaks = 0

if bar_index > last_bar_index - maxDistanceToLastBar
    if true
        // Find Session Start
        createNewTS = true
        if not na(lastTS)
            if na(lastTS.exitPrice)
                createNewTS := false // Don't enter if a trade is already entered
                
        if createNewTS
            newTS = TurtleSoup.new("Waiting For Liquidity Break", time)
            newTS.lastHourHigh := high12
            newTS.lastHourLow := low12
            newTS.lastHour := lastHourTime
            tsList.unshift(newTS)
            lastTS := newTS
            log.info("New Turtle Soup")

        if not na(lastTS)
            // Find Liquidity Breaks
            if lastTS.state == "Waiting For Liquidity Break"
                log.info("Wait For Liq Grab")
                if time > lastTS.startTime
                    if (breakoutMethod == "Close" ? close : low) < lastTS.lastHourLow
                        log.info("Sellside Liq Grab")
                        if entryMethod == "Classic" or highBreaks > lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Sellside", lastTS.lastHourLow)
                            lastTS.entryType := "Long"
                        else if highBreaks <= lowBreaks
                            //lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Buyside", lastTS.lastHourHigh)
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Sellside", lastTS.lastHourLow)
                            lastTS.entryType := "Short"

                        lastTS.state := "Waiting For Execution"
                    
                    else if (breakoutMethod == "Close" ? close : high) > lastTS.lastHourHigh
                        log.info("Buyside Liq Grab")
                        if entryMethod == "Classic" or highBreaks <= lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Buyside", lastTS.lastHourHigh)
                            lastTS.entryType := "Short"
                        else if highBreaks > lowBreaks
                            //lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Sellside", lastTS.lastHourLow)
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Buyside", lastTS.lastHourHigh)
                            lastTS.entryType := "Long"
                        lastTS.state := "Waiting For Execution"
            // Execute
            if lastTS.state == "Waiting For Execution"
                if time > lastTS.brokenSweep.endTime
                    log.info("MSS Execution")
                    if lastTS.entryType == "Short"
                        if (breakoutMethod == "Close" ? close : low) < lowMSS[1]
                            sellAlertTick := true
                            lastTS.state := "Entry Taken"
                            lastTS.entryTime := time
                            lastTS.entryPrice := (breakoutMethod == "Close" ? close : lowMSS[1])
                            if tpslMethod == "Fixed"
                                lastTS.slTarget := lastTS.entryPrice * (1 + slPercent / 100.0)
                                lastTS.tpTarget := lastTS.entryPrice * (1 - tpPercent / 100.0)
                            else
                                lastTS.slTarget := highMSS + atr * slATRMult
                                lastTS.tpTarget := lastTS.entryPrice - (math.abs(lastTS.entryPrice - lastTS.slTarget) * RR)
                    else // Long
                        if (breakoutMethod == "Close" ? close : high) > highMSS[1]
                            buyAlertTick := true
                            lastTS.state := "Entry Taken"
                            lastTS.entryTime := time
                            lastTS.entryPrice := (breakoutMethod == "Close" ? close : highMSS[1])
                            if tpslMethod == "Fixed"
                                lastTS.slTarget := lastTS.entryPrice * (1 - slPercent / 100.0)
                                lastTS.tpTarget := lastTS.entryPrice * (1 + tpPercent / 100.0)
                            else
                                lastTS.slTarget := lowMSS - atr * slATRMult
                                lastTS.tpTarget := lastTS.entryPrice + (math.abs(lastTS.entryPrice - lastTS.slTarget) * RR)
    
    // Entry Taken
    if not na(lastTS)
        if lastTS.state == "Entry Taken"
            log.info("Entry Taken")
            if tpslMethod == "Fixed"
                // Take Profit
                if lastTS.entryType == "Long" and ((high / lastTS.entryPrice) - 1) * 100 >= tpPercent
                    tpAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 + tpPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    highBreaks += 1
                if lastTS.entryType == "Short" and ((low / lastTS.entryPrice) - 1) * 100 <= -tpPercent
                    tpAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 - tpPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    lowBreaks += 1
                
                // Stop Loss
                if lastTS.entryType == "Long" and ((low / lastTS.entryPrice) - 1) * 100 <= -slPercent
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 - slPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    highBreaks -= 1
                if lastTS.entryType == "Short" and ((high / lastTS.entryPrice) - 1) * 100 >= slPercent
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 + slPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    lowBreaks -= 1
            else
                // Take Profit
                if lastTS.entryType == "Long" and ((maxTPLastHour and high >= lastTS.lastHourHigh) or high >= lastTS.tpTarget)
                    tpAlertTick := true
                    lastTS.exitPrice := (high >= math.max(lastTS.lastHourHigh, lastTS.tpTarget) ? math.max(lastTS.lastHourHigh, lastTS.tpTarget) : math.min(lastTS.lastHourHigh, lastTS.tpTarget))
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    highBreaks += 1
                if lastTS.entryType == "Short" and ((maxTPLastHour and low <= lastTS.lastHourLow) or low <= lastTS.tpTarget)
                    tpAlertTick := true
                    lastTS.exitPrice := (low <= math.min(lastTS.lastHourLow, lastTS.tpTarget) ? math.min(lastTS.lastHourLow, lastTS.tpTarget) : math.max(lastTS.lastHourLow, lastTS.tpTarget))
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    lowBreaks += 1
                
                // Stop Loss
                if lastTS.entryType == "Long" and low <= lastTS.slTarget
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.slTarget
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    highBreaks -= 1
                if lastTS.entryType == "Short" and high >= lastTS.slTarget
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.slTarget
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    lowBreaks -= 1
//#endregion

//#region Render Turtle Soups

renderTopSL = false
renderBottomSL = false
renderTopTP = false
renderBottomTP = false

if not na(lastTS)
    if lastTS.state == "Stop Loss" and time >= lastTS.exitTime
        if lastTS.entryType == "Long"
            renderBottomSL := true
        else
            renderTopSL := true
        lastTS.state := "Done"
    if lastTS.state == "Take Profit"
        if lastTS.entryType == "Long"
            renderTopTP := true
        else
            renderBottomTP := true
        lastTS.state := "Done"

plotshape(renderTopSL, "", shape.circle, location.abovebar, color.red, textcolor = textColor, text = "SL", size = size.tiny)
plotshape(renderBottomSL, "", shape.circle, location.belowbar, color.red, textcolor = textColor, text = "SL", size = size.tiny)
plotshape(renderTopTP, "", shape.xcross, location.abovebar, color.blue, textcolor = textColor, text = "TP", size = size.tiny)
plotshape(renderBottomTP, "", shape.xcross, location.belowbar, color.blue, textcolor = textColor, text = "TP", size = size.tiny)

//#endregion

//#region Alerts
if barstate.islastconfirmedhistory
    initRun := false

alertcondition(buyAlertTick and not initRun, "Buy Signal", "")
alertcondition(sellAlertTick and not initRun, "Sell Signal", "")
alertcondition(tpAlertTick and not initRun, "Take-Profit Signal", "")
alertcondition(slAlertTick and not initRun, "Stop-Loss Signal", "")

if not initRun
    if buyAlertTick and buyAlertEnabled
        alert("Buy Signal")
    if sellAlertTick and sellAlertEnabled
        alert("Sell Signal")
    
    if tpAlertTick and tpAlertEnabled
        alert("Take-Profit Signal")
    if slAlertTick and slAlertEnabled
        alert("Stop-Loss Signal")

//#endregion

if barstate.isconfirmed
    if lineX.size() > 0
        for i = 0 to lineX.size() - 1
            line.delete(lineX.get(i))

    if boxX.size() > 0
        for i = 0 to boxX.size() - 1
            box.delete(boxX.get(i))
    
    if labelX.size() > 0
        for i = 0 to labelX.size() - 1
            label.delete(labelX.get(i))

    lineX.clear()
    boxX.clear()
    labelX.clear()
    
    if tsList.size() > 0
        for i = 0 to math.min(125, tsList.size() - 1)
            curTS = tsList.get(i)

            // Target Liquidity
            if not na(curTS.brokenSweep) and showHL
                offset = atr / 3.0
                if curTS.brokenSweep.price == curTS.lastHourHigh
                    boxX.push(box.new(curTS.brokenSweep.startTime, curTS.lastHourHigh + offset, curTS.brokenSweep.endTime, curTS.lastHourHigh - offset, text = "TARGET LIQUIDITY (" + effectiveHTFLabel + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(highColor, 50), text_size = size.small))
                    //lineX.push(line.new(curTS.brokenSweep.startTime, curTS.lastHourHigh, curTS.brokenSweep.endTime, curTS.lastHourHigh, xloc = xloc.bar_time, color = lowColor, style = line.style_dashed))
                else
                    boxX.push(box.new(curTS.brokenSweep.startTime, curTS.lastHourLow + offset, curTS.brokenSweep.endTime, curTS.lastHourLow - offset, text = "TARGET LIQUIDITY (" + effectiveHTFLabel + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(lowColor, 50), text_size = size.small))
                    //lineX.push(line.new(curTS.brokenSweep.startTime, curTS.lastHourLow, curTS.brokenSweep.endTime, curTS.lastHourLow, xloc = xloc.bar_time, color = highColor, style = line.style_dashed))

            // Liq Grab
            if not na(curTS.brokenSweep) and showLiqGrabs
                if curTS.brokenSweep.price == curTS.lastHourHigh
                    labelX.push(label.new(curTS.brokenSweep.endTime, high, yloc = yloc.abovebar, xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.new(lowColor, 50)))
                else
                    labelX.push(label.new(curTS.brokenSweep.endTime, low, yloc = yloc.belowbar, xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.new(highColor, 50)))

            if not na(curTS.entryTime)
                // Entry Label
                if curTS.entryType == "Long"
                    labelX.push(label.new(curTS.entryTime, close, "Buy", xloc = xloc.bar_time, yloc = yloc.belowbar, textcolor = textColor, color = highColor, style = label.style_label_up, size = lblSize))
                else
                    labelX.push(label.new(curTS.entryTime, close, "Sell", xloc = xloc.bar_time, yloc = yloc.abovebar, textcolor = textColor, color = lowColor, style = label.style_label_down, size = lblSize))
            
            // TP / SL
            if not na(curTS.entryTime)
                if showTPSL
                    if dbgTPSLVersion == "Alternative"
                        offset = atr / 3.0
                        endTime = nz(curTS.exitTime, time("", -15))
                        boxX.push(box.new(curTS.entryTime, curTS.tpTarget + offset, endTime, curTS.tpTarget - offset, text = "TAKE PROFIT (" + str.tostring(curTS.tpTarget, format.mintick) + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(highColor, 50), text_size = size.small))
                        boxX.push(box.new(curTS.entryTime, curTS.slTarget + offset, endTime, curTS.slTarget - offset, text = "STOP LOSS (" + str.tostring(curTS.slTarget, format.mintick) + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(lowColor, 50) , text_size = size.small))
                    else if dbgTPSLVersion == "Default"
                        endTime = nz(curTS.exitTime, time("", -15))
                        lineX.push(line.new(curTS.entryTime, curTS.entryPrice, curTS.entryTime, curTS.tpTarget, xloc = xloc.bar_time, color = highColor, style = line.style_dashed))
                        lineX.push(line.new(curTS.entryTime, curTS.tpTarget, endTime, curTS.tpTarget, xloc = xloc.bar_time, color = highColor, style = line.style_dashed))
                        labelX.push(label.new(endTime, curTS.tpTarget, "TP", xloc = xloc.bar_time, yloc = yloc.price, textcolor = textColor, color = color.new(highColor, 50), style = label.style_label_left, size = lblSize))
                        //
                        lineX.push(line.new(curTS.entryTime, curTS.entryPrice, curTS.entryTime, curTS.slTarget, xloc = xloc.bar_time, color = lowColor, style = line.style_dashed))
                        lineX.push(line.new(curTS.entryTime, curTS.slTarget, endTime, curTS.slTarget, xloc = xloc.bar_time, color = lowColor, style = line.style_dashed))
                        labelX.push(label.new(endTime, curTS.slTarget, "SL", xloc = xloc.bar_time, yloc = yloc.price, textcolor = textColor, color = color.new(lowColor, 50), style = label.style_label_left, size = lblSize))

            if not na(curTS.dayEndedBeforeExit)
                labelX.push(label.new(curTS.dayEndedBeforeExit, close, "Exit", xloc = xloc.bar_time, yloc = yloc.belowbar, textcolor = textColor, color = color.yellow, style = label.style_circle, size = size.tiny))

//#region Backtesting Dashboard

if barstate.islast and backtestDisplayEnabled
    var table backtestDisplay = table.new(getPosition(backtestingLocation), 2, 10, bgcolor = screenerColor, frame_width = 2, frame_color = color.black, border_width = 1, border_color = color.black)
    
    float totalTSProfitPercent = 0
    int successfulTrades = 0
    int unsuccessfulTrades = 0

    if tsList.size() > 0
        for i = 0 to tsList.size() - 1
            curTS = tsList.get(i)
            if not na(curTS.entryPrice)
                isSuccess = false
                if not na(curTS.exitPrice)
                    if (curTS.entryType == "Long" and curTS.exitPrice > curTS.entryPrice) or (curTS.entryType == "Short" and curTS.exitPrice < curTS.entryPrice)
                        totalTSProfitPercent += math.abs(diffPercent(curTS.entryPrice, curTS.exitPrice))
                        isSuccess := true
                    else
                        totalTSProfitPercent -= math.abs(diffPercent(curTS.entryPrice, curTS.exitPrice))
                        isSuccess := false

                if isSuccess
                    successfulTrades += 1
                else
                    unsuccessfulTrades += 1

    int totalTrades = successfulTrades + unsuccessfulTrades
    float winRate = totalTrades > 0 ? 100.0 * successfulTrades / totalTrades : 0.0
    float averageProfit = totalTrades > 0 ? totalTSProfitPercent / totalTrades : 0.0
    
    // Header
    table.merge_cells(backtestDisplay, 0, 0, 1, 0)
    table.cell(backtestDisplay, 0, 0, "Liquidity Sweep Backtest", text_color = color.white, bgcolor = screenerColor)

    // Total ORBs
    table.cell(backtestDisplay, 0, 1, "Total Entries", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 1, str.tostring(totalTrades), text_color = color.white, bgcolor = screenerColor)

    // Wins
    table.cell(backtestDisplay, 0, 2, "Wins", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 2, str.tostring(successfulTrades), text_color = color.white, bgcolor = screenerColor)

    // Losses
    table.cell(backtestDisplay, 0, 3, "Losses", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 3, str.tostring(unsuccessfulTrades), text_color = color.white, bgcolor = screenerColor)

    // Winrate
    table.cell(backtestDisplay, 0, 4, "Winrate", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 4, str.tostring(winRate, "#.##") + "%", text_color = color.white, bgcolor = screenerColor)

    // Average Profit %
    table.cell(backtestDisplay, 0, 5, "Average Profit", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 5, str.tostring(averageProfit, "#.##") + "%", text_color = color.white, bgcolor = screenerColor)

    // Total Profit %
    table.cell(backtestDisplay, 0, 6, "Total Profit", text_color = color.white, bgcolor = screenerColor)
    table.cell(backtestDisplay, 1, 6, str.tostring(totalTSProfitPercent, "#.##") + "%", text_color = color.white, bgcolor = screenerColor)

//#endregion
````
