# Wick Fills

- url: https://www.tradingview.com/script/kvdfTPaD/
- type: indicator
- pine_id: PUB;d40c8e335e034d8581dbc707755cce75
- version: 1.0

## Description

General Concept: The "Wick Fill" StrategyIn trading, a long wick (shadow) on a candlestick shows that the price reached a certain extreme high or low but was quickly rejected.A popular market theory states that these wicks represent temporary market imbalances or "pockets of liquidity." Just like gaps (where the price jumps from one level to another without trading), the market has a strong tendency to return to these long wicks and trade through that price zone again. This indicator automatically finds these long wicks and tracks them until the price returns to "fill" them.

## Source Code

````pine
//@version=6
indicator("Wick Fills", overlay = true, max_boxes_count = 500)

// הגדרות קלט למשתמש
closeWicksPartially      = input.bool(false, "Close Wicks Partially", display = display.none)
boxLimitInput           = input.int(30, "Max Number of Active Wicks", minval = 1, maxval = 500, display = display.none)
minimalDeviationTooltip = "מגדיר את הגודל המינימלי של הפתיל באחוזים מתוך ממוצע הטווח (High-Low) של 14 הנרות האחרונים."
minimalDeviationInput   = nz(input.float(50.0, "Minimal Wick Size (%)", tooltip = minimalDeviationTooltip, minval=1, maxval=500, display = display.none) / 100 * ta.sma(high-low, 14))
limitBoxLengthBoolInput = input.bool(false, "Limit Max Wick Trail Length (bars)", inline = "Length Limit", display = display.none)
limitBoxLengthIntInput  = input.int(300, "", inline = "Length Limit", minval = 1, display = display.none, active = limitBoxLengthBoolInput)

groupName = "Border and fill colors"
colorUpBorderInput      = input.color(color.green, "Upper Wicks", inline = "Wick Up", group = groupName, display = display.none)
colorUpBackgroundInput  = input.color(color.new(color.green, 85), "", inline = "Wick Up", group = groupName, display = display.none)
colorDownBorderInput    = input.color(color.red, "Lower Wicks", inline = "Wick Down", group = groupName, display = display.none)
colorDownBackgroundInput= input.color(color.new(color.red, 85), "", inline = "Wick Down", group = groupName, display = display.none)

// מבנה נתונים להתראות
type AlertInfo
    int countOpenWick
    int countClosedWick

method hasOpenedWick(AlertInfo this) => this.countOpenWick > 0
method hasClosedWick(AlertInfo this) => this.countClosedWick > 0

AlertInfo alertInfo = AlertInfo.new(0, 0)

// מבנה נתונים לייצוג פתיל פתוח במערכת
type Wick
    bool isActive
    bool isUpper
    array<box> boxes

// מחיקת פתיל מהגרף
method delete(Wick this) =>
    for _box in this.boxes
        _box.delete()

// סגירה חלקית של פתיל (מילוי חלקי)
method partialClose(Wick this) =>
    activeBox = this.boxes.last()
    activeBox.set_extend(extend.none)

    top = this.isUpper ? activeBox.get_top() : low
    bottom = this.isUpper ? high : activeBox.get_bottom()

    if top > bottom
        this.boxes.push(box.new(
          bar_index,
          top,
          bar_index,
          bottom, 
          this.isUpper ? colorUpBorderInput : colorDownBorderInput, 
          bgcolor = this.isUpper ? colorUpBackgroundInput : colorDownBackgroundInput))

// סגירה מלאה של פתיל (מילוי מלא)
method fullClose(Wick this) =>
    alertInfo.countClosedWick += 1
    activeBox = this.boxes.last()
    activeBox.set_extend(extend.none)
    this.isActive := false
    if closeWicksPartially
        activeBox.delete()    

// בדיקה האם הנר הנוכחי כיסה או סגר את הפתיל
method checkForClose(Wick this) =>
    if this.isActive
        activeBox = this.boxes.last()
        top = activeBox.get_top() 
        bot = activeBox.get_bottom()
        isUpper = this.isUpper
        activeBox.set_right(bar_index)

        // בדיקה האם הגענו לתוך תחום הפתיל (מילוי חלקי או התחלת סגירה)
        if (high > bot and isUpper) or (low < top and not isUpper)
            if closeWicksPartially
                this.partialClose()                
            else
                this.fullClose()

        // בדיקה האם המחיר פרץ לחלוטין את קצה הפתיל או שעבר גבול הנרות שנקבע
        bool forceCloseBoxExceededLengthLimit = (limitBoxLengthBoolInput and bar_index - activeBox.get_left() >= limitBoxLengthIntInput)
        if ((high > top and isUpper) or (low < bot and not isUpper)) or forceCloseBoxExceededLengthLimit
            this.fullClose()

var allWicks = array.new<Wick>()

// חישוב גודל הפתיל הנוכחי
upperWickSize = high - math.max(open, close)
lowerWickSize = math.min(open, close) - low

// זיהוי פתילים חריגים לפי הגדרת המשתמש
isWickUp = upperWickSize >= minimalDeviationInput
isWickDown = lowerWickSize >= minimalDeviationInput

// פונקציית רישום פתיל חדש
registerNewWick(bool isUpper) => 
    alertInfo.countOpenWick += 1
    
    boxTop = isUpper ? high : math.min(open, close)
    boxBot = isUpper ? math.max(open, close) : low
    borderColor = isUpper ? colorUpBorderInput : colorDownBorderInput
    bgColor = isUpper ? colorUpBackgroundInput : colorDownBackgroundInput
    
    newBox = box.new(
      bar_index,
      boxTop,
      bar_index,
      boxBot,
      border_color = borderColor,
      bgcolor = bgColor,
      extend = extend.right)

    allWicks.push(Wick.new(true, isUpper, array.from(newBox)))

    if allWicks.size() > boxLimitInput
        allWicks.shift().delete()

// בדיקת כיסוי ומילוי פתילים קיימים על ידי הנר הנוכחי
for wick in allWicks
    wick.checkForClose()

// הוספת פתיל חדש לרשימה ומחיקת ישנים במידת הצורך
if isWickUp    
    registerNewWick(true)
if isWickDown
    registerNewWick(false)

// הודעת מערכת למקרה שלא נמצאו פתילים
if barstate.islastconfirmedhistory and allWicks.size() == 0
    noWickText = "לא נמצאו פתילים חריגים על הגרף.\nנסה להוריד את ערך ה-Minimal Wick Size (%) בהגדרות האינדיקטור."
    var infoTable = table.new(position.bottom_right, 1, 1)
    table.cell(infoTable, 0, 0, text = noWickText, text_color = chart.bg_color, bgcolor = chart.fg_color)

// הגדרת התראות מערכת
alertcondition(alertInfo.hasOpenedWick(), "New Wick Appeared", "פתיל ארוך חדש נוצר והחל מעקב מילוי.")
alertcondition(alertInfo.hasClosedWick(), "Wick Filled", "הפתיל נסגר ומולא במלואו על ידי המחיר.")
````
