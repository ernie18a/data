# Maor Beniash - D9 Indicator

- url: https://www.tradingview.com/script/CQgqNeap/
- type: indicator
- pine_id: PUB;28cb4c45136e4e18afeeb9874dbaf87c
- version: 1.0

## Description

Maor Beniash - D9 Indicator

אינדיקטור ה-D9 נועד לסייע בזיהוי נקודות קיצון פוטנציאליות, התשת מגמה ואזורי היפוך אפשריים על בסיס ספירת רצפים של סגירות מחיר. האינדיקטור בנוי בצורה נקייה וברורה, ומותאם במיוחד לסוחרי סווינג המחפשים תזמון מדויק יותר בכניסה ויציאה מעסקאות, במיוחד על גבי גרפים יומיים ושבועיים.

איך הלוגיקה עובדת?
האלגוריתם עוקב אחר רצף של נרות שבהם שער הסגירה גבוה (או נמוך) משער הסגירה של 4 נרות אחורה. כאשר מתחיל להיווצר רצף מובהק, האינדיקטור מתריע על כך ישירות על הגרף:

במהלך עליות (פוטנציאל לתיקון מטה): יוצגו משולשים אדומים מעל הנרות עבור הספירות 7 ו-8. השלמת הרצף (נר 9) תסומן ב-❌, מה שמזהיר מפני התשה אפשרית של כוח הקונים.

במהלך ירידות (פוטנציאל להיפוך מעלה): יוצגו משולשים ירוקים מתחת לנרות עבור הספירות 7 ו-8. השלמת הרצף (נר 9) תסומן ב-✅, מה שמצביע על פוטנציאל לסיום גל הירידות וחזרת הקונים.

תכונות עיקריות (Settings):
שליטה מלאה בויזואליות: אפשרות נוחה להדליק ולכבות את התצוגה של לוגיקת ה-D9 בלחיצת כפתור (הגדרות כלליות).

חלונית סטטוס (Status Box): תצוגה צפה המראה האם האינדיקטור פעיל (ON/OFF). ניתן לבחור את מיקום החלונית (בכל אחת מארבע פינות הגרף) ולהגדיר את מרווח השורות (Padding) כדי לשמור על סביבת עבודה נקייה ולמנוע הסתרה של אינדיקטורים אחרים.

## Source Code

````pine
//@version=5
indicator("Maor Beniash - D9 Indicator", overlay=true)

// --- הגדרות משתמש ---
group_logic = "General Settings"
showIndicator = input.bool(true, "Enable D9 Logic", group=group_logic)

group_visuals = "Visuals"
showStatusBox = input.bool(true, "Show Status Table", group=group_visuals)
posInput = input.string("Top Left", "Box Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=group_visuals)
paddingInput = input.int(6, "Lines of Space Before Text (Max 20)", minval=0, maxval=20, group=group_visuals)

// מיפוי בחירת המיקום
var tablePos = posInput == "Top Left" ? position.top_left : 
               posInput == "Top Right" ? position.top_right : 
               posInput == "Bottom Left" ? position.bottom_left : position.bottom_right

// --- לוגיקה של אינדיקטור D9 ---
var float upCount = na
var float downCount = na

upCount := showIndicator and close > close[4] ? (na(upCount[1]) ? 1 : upCount[1] + 1) : 0
downCount := showIndicator and close < close[4] ? (na(downCount[1]) ? 1 : downCount[1] + 1) : 0

upSignal = upCount - ta.valuewhen(upCount < upCount[1], upCount, 1)
downSignal = downCount - ta.valuewhen(downCount < downCount[1], downCount, 1)

// --- ציור על הגרף ---
plotshape(showIndicator and upSignal == 7 ? true : na, style=shape.triangledown, text="7", color=color.red, location=location.abovebar, size=size.tiny)
plotshape(showIndicator and upSignal == 8 ? true : na, style=shape.triangledown, text="8", color=color.red, location=location.abovebar, size=size.tiny)
plotshape(showIndicator and upSignal == 9 ? true : na, style=shape.triangledown, text="❌", color=color.red, location=location.abovebar, size=size.tiny)

plotshape(showIndicator and downSignal == 7 ? true : na, style=shape.triangleup, text="7", color=color.green, location=location.belowbar, size=size.tiny)
plotshape(showIndicator and downSignal == 8 ? true : na, style=shape.triangleup, text="8", color=color.green, location=location.belowbar, size=size.tiny)
plotshape(showIndicator and downSignal == 9 ? true : na, style=shape.triangleup, text="✅", color=color.green, location=location.belowbar, size=size.tiny)

// --- יצירת תצוגת סטטוס (Status Box) ---
var table statusTable = table.new(tablePos, 1, 21)

if barstate.islast and showStatusBox
    // ניקוי מלא של הטבלה כדי למנוע שאריות צבע מהרצות קודמות
    for j = 0 to 20
        table.cell(statusTable, 0, j, text="", bgcolor=color.new(color.black, 100))
    
    // יצירת שורות רווח עם ירידת שורה אחת (\n) - גובה בינוני ומדויק
    if paddingInput > 0
        for i = 0 to paddingInput - 1
            table.cell(statusTable, 0, i, text="\n", bgcolor=color.new(color.black, 100))
            
    // הגדרת תא הסטטוס בשורה שנבחרה
    string statusText = showIndicator ? "D9: ON" : "D9: OFF"
    color bgColor = showIndicator ? color.new(color.green, 20) : color.new(color.red, 20)
    
    table.cell(statusTable, 0, paddingInput, statusText, bgcolor=bgColor, text_color=color.white, text_size=size.normal)
````
