# Method 20 Checklist

- url: https://www.tradingview.com/script/WRRiYcRm/
- type: indicator
- pine_id: PUB;5b2b52f37c6a4617a1405426de308301
- version: 1.0

## Description

צק ליסט ממוצע 20
מרחק ממוצע 20
סוג נר
האם יש עוצמת קונים
מי בשליטה הקונים או המוכרים

## Source Code

````pine
//@version=5
indicator("Micha Stocks - Method 20 Checklist", overlay=true)

// --- הגדרות משתמש ---
tablePosInput = input.string("Top Right", "מיקום הטבלה", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"])
pos = tablePosInput == "Top Right" ? position.top_right : tablePosInput == "Middle Right" ? position.middle_right : tablePosInput == "Bottom Right" ? position.bottom_right : tablePosInput == "Top Left" ? position.top_left : position.bottom_left

// --- חישובים ---
// 1. ממוצע 20 ומרחק ממנו
sma20 = ta.sma(close, 20)
distSMA = ((close - sma20) / sma20) * 100

// 2. נתונים לנרות יפניים
body = math.abs(close - open)
rng = high - low
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

isGreen = close > open
isRed = close < open

// זיהוי תבניות בסיסי (דוג'י, פטיש, בולען/מרבוזו)
isDoji = body <= (rng * 0.15) // גוף קטן מאוד ביחס לנר
isHammer = lowerWick >= (body * 2.0) and upperWick <= (body * 0.5) // זנב תחתון ארוך
isMarubozu = body >= (rng * 0.85) // גוף בשרני, כמעט בלי פתילים

patternText = isDoji ? "דוג'י/סביבון" : isHammer ? "פטיש (Hammer)" : isMarubozu ? "מרבוזו/מומנטום" : "נר רגיל"
patternColor = isDoji ? color.new(color.yellow, 0) : isHammer ? color.new(color.green, 0) : isMarubozu and isGreen ? color.new(color.green, 0) : isMarubozu and isRed ? color.new(color.red, 0) : color.new(color.white, 0)

// 3. ווליום
volUp = volume > volume[1]
volText = volUp ? "בעלייה (מגביר קצב)" : "בירידה (התעייפות)"
volColor = volUp ? color.new(color.orange, 0) : color.new(color.gray, 0)

// 4. CCI
cci20 = ta.cci(close, 20)
cciText = str.tostring(math.round(cci20, 2))
cciColor = cci20 <= -100 ? color.new(color.green, 0) : cci20 >= 100 ? color.new(color.red, 0) : color.new(color.yellow, 0)
cciRemark = cci20 <= -100 ? "מכירת יתר (חפש היפוך)" : cci20 >= 100 ? "קניית יתר (חפש תיקון)" : "ניטרלי"

// 5. גאפים (פערים מהיום הקודם)
gapUp = low > high[1]
gapDown = high < low[1]
gapText = gapUp ? "גאפ פתוח למטה" : gapDown ? "גאפ פתוח למעלה" : "אין גאפ חדש"

// --- בניית הטבלה ---
var tbl = table.new(pos, 3, 7, border_width=1, border_color=color.rgb(65, 65, 65), frame_color=color.rgb(65, 65, 65), frame_width=1, bgcolor=color.rgb(20, 20, 20, 10))

if barstate.islast
    // כותרות
    table.cell(tbl, 0, 0, "פרמטר (שיטת ה-20)", text_color=color.white, bgcolor=color.rgb(40, 40, 150))
    table.cell(tbl, 1, 0, "סטטוס נוכחי", text_color=color.white, bgcolor=color.rgb(40, 40, 150))
    table.cell(tbl, 2, 0, "הערות / משמעות", text_color=color.white, bgcolor=color.rgb(40, 40, 150))

    // שורה 1: מי בשליטה?
    table.cell(tbl, 0, 1, "מי בשליטה?", text_color=color.white)
    table.cell(tbl, 1, 1, isGreen ? "קונים 🟢" : isRed ? "מוכרים 🔴" : "תיקו ⚪", text_color=isGreen ? color.green : isRed ? color.red : color.white)
    table.cell(tbl, 2, 1, "עפי פתיחה מול סגירה", text_color=color.gray)

    // שורה 2: תצורת נר
    table.cell(tbl, 0, 2, "תצורת הנר", text_color=color.white)
    table.cell(tbl, 1, 2, patternText, text_color=patternColor)
    table.cell(tbl, 2, 2, "מחפשים שינוי כיוון/מומנטום", text_color=color.gray)

    // שורה 3: ווליום
    table.cell(tbl, 0, 3, "ווליום (לעומת אתמול)", text_color=color.white)
    table.cell(tbl, 1, 3, volText, text_color=volColor)
    table.cell(tbl, 2, 3, isGreen and volUp ? "קונים דוחפים" : isRed and volUp ? "מוכרים לוחצים" : "מורידים הילוך", text_color=color.gray)

    // שורה 4: ממוצע 20
    table.cell(tbl, 0, 4, "מרחק מממוצע 20", text_color=color.white)
    table.cell(tbl, 1, 4, str.tostring(math.round(distSMA, 2)) + "%", text_color=color.white)
    table.cell(tbl, 2, 4, distSMA > 5 ? "מתוח מדי למעלה" : distSMA < -5 ? "מתוח מדי למטה" : "קרוב לממוצע", text_color=color.gray)

    // שורה 5: CCI
    table.cell(tbl, 0, 5, "מתנד CCI (20)", text_color=color.white)
    table.cell(tbl, 1, 5, cciText, text_color=cciColor)
    table.cell(tbl, 2, 5, cciRemark, text_color=color.gray)

    // שורה 6: גאפים
    table.cell(tbl, 0, 6, "פערים (Gaps)", text_color=color.white)
    table.cell(tbl, 1, 6, gapText, text_color=gapUp ? color.green : gapDown ? color.red : color.white)
    table.cell(tbl, 2, 6, "גאפים משמשים כמגנט", text_color=color.gray)

// ציור ממוצע 20 על הגרף לנוחות
plot(sma20, color=color.blue, title="SMA 20", linewidth=2)
````
