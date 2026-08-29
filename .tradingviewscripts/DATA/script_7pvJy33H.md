<!-- tradingview-pine-id: PUB;1c010d7de68c44c8b97468d4b3355b68 -->
<!-- tradingviewscripts-format: 1 -->
# დეი თრეიდინგის ხელსაწყოები

Source: https://www.tradingview.com/script/7pvJy33H-Day-Trading-Tools-Geo/

## Description

day trading tools. author zentrading

Description — Zen Trading Toolkit v1.8

This indicator combines three independent research modules for day trading, built on pure Price Action logic — no indicators, just statistical measurement of daily volatility.

Module 1 — ABR Measured Moves
Projects target levels (0.5x / 1.0x / 1.5x / 2.0x) from yesterday's RTH close (y.Close), based on the Average Bar Range (ABR) over a configurable N-day lookback. It also plots yesterday's high/low and the additional measured moves derived from them.

Module 2 — Opening Range
Builds a box from the high/low of the first N bars (default 18) and projects levels from it (0.25x–2.0x), useful for identifying retail trader traps and breakout levels.

Module 3 — Volatility Statistics Table
Displays a side panel with ABR/ADR readings for both RTH and ETH sessions, today's range as a % of ADR (turns red at ≥80%), the Opening Range's % of ADR, and separate "Swing" and "Scalp" targets (configurable % of ADR — default 40% and 10%). All metrics are also output to the Data Window independently of the table.

The tool supports ES, FDAX, HSI, Nikkei, and a custom session/timezone configuration, automatically adjusting to the corresponding trading hours.

აღწერა — Zen Trading Toolkit v1.8

ეს ინდიკატორი დღიური ვაჭრობის (day trading) სამი დამოუკიდებელი კვლევითი მოდულის ერთობლიობაა, აგებული სუფთა ფასის მოძრაობის (Price Action) ლოგიკაზე — ინდიკატორების გარეშე, მხოლოდ დღიური ვოლატილობის სტატისტიკურ გაზომვაზე დაყრდნობით.

მოდული 1 — ABR გაზომილი სვლები (Measured Moves)
გუშინდელი დღის დახურვის ფასიდან (y.Close) აშენებს პროექციულ დონეებს (0.5x / 1.0x / 1.5x / 2.0x), რომლებიც ეფუძნება საშუალო დღიურ დიაპაზონს (Average Bar Range, N-დღიანი მოძრავი პერიოდით). ასევე გამოაქვს გუშინდელი მაქსიმუმი/მინიმუმი და მათგან აგებული დამატებითი გაზომილი სვლები.

მოდული 2 — გახსნის დიაპაზონი (Opening Range)
პირველი N ბარის (ნაგულისხმევად 18) მაქსიმუმ-მინიმუმზე აშენებს ყუთს და მისგან პროექციებს (0.25x–2.0x), რაც პრაქტიკულად რითეილ თრეიდერების ხაფანგებისა და გარღვევის დონეების იდენტიფიცირებას ემსახურება.

მოდული 3 — ვოლატილობის სტატისტიკის ცხრილი
გვერდით პანელზე აჩვენებს RTH და ETH სესიების ABR/ADR მაჩვენებლებს, დღევანდელი დიაპაზონის %-ს ADR-იდან (წითლდება 80%-ზე მეტისას), Opening Range-ის %-ს ADR-იდან და ცალკეულ "სვინგის" და "სკალპის" სამიზნეებს (ADR-ის მორგებადი % — ნაგულისხმევად 40% და 10%). ყველა მეტრიკა ასევე გამოტანილია Data Window-ში, ცხრილისგან დამოუკიდებლად.

ინსტრუმენტი მხარდაჭერს ES, FDAX, HSI, Nikkei და საკუთარი სესია/დროის სარტყელის კონფიგურაციას, ავტომატურად ითვალისწინებს შესაბამის სავაჭრო საათებს.

---

## Source Code

````pine
//@version=6
// ============================================================================
// ZEN TRADING TOOLKIT v1.8 (ზენ თრეიდინგის ინსტრუმენტების ნაკრები)
// ============================================================================
// სამი კვლევითი მოდული, თითოეული ფუნქციის დამოუკიდებლად ჩართვა-გამორთვის შესაძლებლობით.
// არ არის დამოკიდებული გარე ბიბლიოთეკებზე. ინსტრუმენტების პარამეტრები დროის სარტყელის მიხედვით.
//
//   მოდული 1 — ABR გაზომილი სვლები (გუშინდელი დახურვიდან - y.Close)
//   მოდული 2 — გახსნის დიაპაზონი (N-ბარიანი ყუთი კალენდარული დღის აღმოჩენით)
//   მოდული 3 — ვოლატილობის სტატისტიკის ცხრილი (ABR + ADR RTH/ETH სესიები)
//
// v1.4 შესწორება: სესიის ნიმუში და განახლება ორივე ხდება პირველ ბარზე (first_bar).
// მუშაობს მხოლოდ RTH (ძირითადი სესია) გრაფიკებზე და გაფართოებულ საათებზეც (ETH).
//
// v1.5 ცვლილებები:
//   - სტატისტიკის ცხრილი: % ADR სტრიქონი წითლდება, როცა მიიღწევა >= 80% (მყარი ლიმიტი)
//   - სტატისტიკის ცხრილი: ახალი OR % სტრიქონი, რომელიც აჩვენებს 18-ბარიან გახსნის დიაპაზონს როგორც RTH ADR-ის %-ს
//     (მხოლოდ RTH სვეტში; ცარიელია სანამ OR არ დაიბლოკება მე-18 ბარზე)
//   - მოდული 2: დაემატა 0.25x OR პროექციის გადამრთველი და ფერის შესაყვანი
//
// v1.7 ცვლილებები:
//   - სტატისტიკის ცხრილი: ახალი სვინგის (Swing) სტრიქონი (ADR * მორგებადი %, ნაგულისხმევი 40%) — მხოლოდ RTH
//   - სტატისტიკის ცხრილი: ახალი სკალპინგის (Scalp) სტრიქონი (ADR * მორგებადი %, ნაგულისხმევი 10%) — მხოლოდ RTH
//   - ორივე სტრიქონი დამოუკიდებლად ირთვება; ETH სვეტი აჩვენებს '-'-ს
//
// v1.8 ცვლილებები:
//   - ყველა სტატისტიკის მეტრიკა გამოტანილია მონაცემთა ფანჯრის გრაფიკებად (display.data_window)
//   - გრაფიკები მუშაობს ცხრილისგან დამოუკიდებლად — ცხრილი რომც დამალოთ, მნიშვნელობებს მაინც დაინახავთ გვერდითა პანელზე
//   - მთავარ გრაფიკზე არაფერი იხატება; სუფთა გვერდითა პანელის გამონატანია
//
// v1.8.1 ცვლილებები:
//   - Swing / Scalp გადამრთველი და % შეყვანა მოთავსებულია ერთ ხაზზე პარამეტრებში,
//     რათა 40 და 10 გამოჩნდეს პირდაპირ დასახელების გვერდით (მინიშნების გარეშე)
// ============================================================================

indicator("დეი თრეიდინგის ხელსაწყოები", shorttitle="დეი თრეიდინგის ხელსაწყოები",
     overlay=true, max_lines_count=500, max_labels_count=500,
     max_boxes_count=500, format=format.inherit)

// ============================================================================
// საერთო პარამეტრები — ინსტრუმენტის წინასწარი პარამეტრები + სესია
// ============================================================================

grpSession = "სესია"
string instrument = input.string("ES", "ინსტრუმენტი",
     options=["ES", "FDAX", "HSI", "Nikkei", "Custom"], group=grpSession,
     tooltip="ავტომატურად ირჩევს RTH სესიას და დროის სარტყელს.\nES: 0830-1600 ჩიკაგო\nFDAX: 0900-1730 ბერლინი\nHSI: 0915-1630 ჰონგ კონგი\nNikkei: 0845-1550 ტოკიო\nCustom: მიუთითეთ თქვენი საკუთარი")
string custom_session = input.session("0830-1600", "საკუთარი სესია", group=grpSession,
     tooltip="გამოიყენება მხოლოდ მაშინ, როცა ინსტრუმენტი = Custom")
string custom_tz = input.string("America/Chicago", "საკუთარი დროის სარტყელი", group=grpSession,
     options=["America/Chicago", "America/New_York", "America/Los_Angeles", "America/Denver",
              "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich",
              "Asia/Hong_Kong", "Asia/Tokyo", "Asia/Singapore", "Asia/Shanghai",
              "Australia/Sydney", "Pacific/Auckland"],
     tooltip="გამოიყენება მხოლოდ მაშინ, როცა ინსტრუმენტი = Custom")

int lookback = input.int(8, "ანალიზის პერიოდი (დღეები)", minval=1, maxval=50, group=grpSession,
     tooltip="მოძრავი პერიოდი ABR/ADR-ისთვის. გამოიყენება ყველა მოდულის მიერ. 8 არის კვლევის ნაგულისხმევი მნიშვნელობა.")

string rth_session = switch instrument
    "ES"     => "0830-1600"
    "FDAX"   => "0900-1730"
    "HSI"    => "0915-1630"
    "Nikkei" => "0845-1550"
    => custom_session

string rth_tz = switch instrument
    "ES"     => "America/Chicago"
    "FDAX"   => "Europe/Berlin"
    "HSI"    => "Asia/Hong_Kong"
    "Nikkei" => "Asia/Tokyo"
    => custom_tz

string session_display = switch instrument
    "ES"     => "ES 0830-1600 ჩიკაგო"
    "FDAX"   => "FDAX 0900-1730 ბერლინი"
    "HSI"    => "HSI 0915-1630 ჰონგ კონგი"
    "Nikkei" => "NK 0845-1550 ტოკიო"
    => "საკუთარი პარამეტრები"

// ============================================================================
// მოდული 1 პარამეტრები — ABR გაზომილი სვლები (MEASURED MOVES)
// ============================================================================

grpMM2 = "მოდული 1: სამიზნეები"
mm_show05x  = input.bool(true,  "0.5x ABR სამიზნეების ჩვენება", group=grpMM2)
mm_show1x   = input.bool(true,  "1.0x ABR სამიზნეების ჩვენება", group=grpMM2)
mm_show15x  = input.bool(false, "1.5x ABR სამიზნეების ჩვენება", group=grpMM2)
mm_show2x   = input.bool(false, "2.0x ABR სამიზნეების ჩვენება", group=grpMM2,
     tooltip="2x სამიზნე სრულდება შემთხვევების ~1%-ში. გამორთულია ნაგულისხმევად გრაფიკის გადატვირთვის თავიდან ასაცილებლად.")

grpMM3 = "მოდული 1: საორიენტაციო ხაზები"
mm_showYClose = input.bool(false,  "გუშინდელი RTH დახურვა (y.Close)",  group=grpMM3)
mm_showYHiLo  = input.bool(true, "გუშინდელი RTH მაქს / მინ (y.Hi/Lo)", group=grpMM3)
mm_showYdMM   = input.bool(true, "გუშინდელი დიაპაზონის MM (1x ექსტრემუმებიდან)", group=grpMM3,
     tooltip="აფროექტებს y.Hi + yRange ზევით და y.Lo - yRange ქვევით. ორიგინალი გაზომილი სვლა გუშინდელი დიაპაზონის კიდეებიდან.")

grpMM4 = "მოდული 1: ვიზუალიზაცია"
mm_lineExt    = input.int(20, "ხაზის გაგრძელება (ბარები)", minval=10, maxval=500, group=grpMM4)
mm_lineWidth  = input.int(1,  "ხაზის სისქე",            minval=1, maxval=4,    group=grpMM4)
mm_showLabels = input.bool(true, "წარწერების ჩვენება",         group=grpMM4)
mm_showTable  = input.bool(false, "სამიზნეების ცხრილის ჩვენება (დიაგნოსტიკა)", group=grpMM4,
     tooltip="MM სამიზნეების დიაგნოსტიკის ცხრილი. დამოუკიდებელია ძირითადი ხაზებისგან.")
mm_tableSize  = input.string("small", "ცხრილის ტექსტის ზომა",
     options=["tiny", "small", "normal", "large"], group=grpMM4)
mm_labelOff   = input.int(5,  "წარწერის დაშორება მარჯვნივ (ბარები)", minval=0, maxval=50, group=grpMM4)

grpMM5 = "მოდული 1: ზრდის (Bull) ფერები"
mm_colBull05 = input.color(color.new(#059669, 60), "Bull 0.5x", group=grpMM5)
mm_colBull1  = input.color(color.new(#059669, 30), "Bull 1.0x", group=grpMM5)
mm_colBull15 = input.color(color.new(#059669, 15), "Bull 1.5x", group=grpMM5)
mm_colBull2  = input.color(color.new(#059669, 0),  "Bull 2.0x", group=grpMM5)

grpMM6 = "მოდული 1: კლების (Bear) ფერები"
mm_colBear05 = input.color(color.new(#DC2626, 60), "Bear 0.5x", group=grpMM6)
mm_colBear1  = input.color(color.new(#DC2626, 30), "Bear 1.0x", group=grpMM6)
mm_colBear15 = input.color(color.new(#DC2626, 15), "Bear 1.5x", group=grpMM6)
mm_colBear2  = input.color(color.new(#DC2626, 0),  "Bear 2.0x", group=grpMM6)

grpMM7 = "მოდული 1: საორიენტაციო ფერები"
mm_colYClose = input.color(color.new(#F59E0B, 30), "გუშინდელი დახურვა",    group=grpMM7)
mm_colYHiLo  = input.color(color.new(color.gray, 50), "გუშინდელი მაქს/მინ", group=grpMM7)
mm_colYdMM   = input.color(color.new(color.teal, 0),  "გუშინდელი დიაპაზონის MM", group=grpMM7)

// ============================================================================
// მოდული 2 პარამეტრები — გახსნის დიაპაზონი (OPENING RANGE)
// ============================================================================

grpOR1 = "მოდული 2: ყუთის პარამეტრები"
or_bars      = input.int(18, "გახსნის დიაპაზონის ბარები", minval=2, maxval=100, group=grpOR1,
     tooltip="ბარების რაოდენობა დღის გახსნიდან. 18 ბარი 5-წუთიანზე = 90 წუთი.")
or_showBox   = input.bool(true,  "ყუთის ჩვენება",       group=grpOR1)
or_boxColor  = input.color(color.orange, "ყუთის ფერი", group=grpOR1)
or_boxTrans  = input.int(80, "ყუთის გამჭვირვალობა", minval=0, maxval=100, group=grpOR1)
or_showLabel = input.bool(false,  "დიაპაზონის წარწერის ჩვენება", group=grpOR1)
or_lblColor  = input.color(color.white, "წარწერის ფერი", group=grpOR1)

grpOR2 = "მოდული 2: პროექციები"
or_projLen = input.int(40, "პროექციის სიგრძე (ბარები)", group=grpOR2)

// v1.5: დაემატა 0.25x პროექცია
or_show025 = input.bool(false, "0.25x", inline="or0", group=grpOR2)
or_col025  = input.color(color.new(color.yellow, 30),  "", inline="or0", group=grpOR2)
or_show050 = input.bool(true,  "0.50x", inline="or1", group=grpOR2)
or_col050  = input.color(color.new(color.teal, 30),   "", inline="or1", group=grpOR2)
or_show075 = input.bool(false, "0.75x", inline="or2", group=grpOR2)
or_col075  = input.color(color.new(color.blue, 30),   "", inline="or2", group=grpOR2)
or_show100 = input.bool(true,  "1.00x", inline="or3", group=grpOR2)
or_col100  = input.color(color.new(color.gray, 30),   "", inline="or3", group=grpOR2)
or_show150 = input.bool(false, "1.50x", inline="or4", group=grpOR2)
or_col150  = input.color(color.new(color.orange, 30), "", inline="or4", group=grpOR2)
or_show200 = input.bool(false, "2.00x", inline="or5", group=grpOR2)
or_col200  = input.color(color.new(color.red, 30),    "", inline="or5", group=grpOR2)
or_showProjLbl = input.bool(false, "სამიზნე წარწერების ჩვენება", group=grpOR2)

// ============================================================================
// მოდული 3 პარამეტრები — ვოლატილობის სტატისტიკის ცხრილი
// ============================================================================

grpST = "მოდული 3: სტატისტიკის ცხრილი"
st_showTable = input.bool(true, "სტატისტიკის ცხრილის ჩვენება", group=grpST)
st_position  = input.string("Top Right", "ცხრილის პოზიცია",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpST)
bool st_showSession = input.bool(true, "სესიის ინფორმაციის ჩვენება", group=grpST)

// v1.7: სტრიქონების გადამრთველები + Swing/Scalp % შეყვანა
// v1.8.1: გადამრთველი და % მოთავსებულია ერთ ხაზზე, რათა 40/10 გამოჩნდეს წარწერის გვერდით
grpSTRows = "მოდული 3: ცხრილის სტრიქონები"
bool  st_showSwing = input.bool(true,  "სვინგის სტრიქონი (% RTH ADR-იდან)", inline="swing", group=grpSTRows)
float st_swingPct  = input.float(40.0, "",                                  inline="swing", group=grpSTRows,
     minval=1, maxval=100, step=5,
     tooltip="სვინგის სამიზნე = RTH ADR × ეს %. ნაგულისხმევი 40%.")
bool  st_showScalp = input.bool(true,  "სკალპის სტრიქონი (% RTH ADR-იდან)", inline="scalp", group=grpSTRows)
float st_scalpPct  = input.float(10.0, "",                                  inline="scalp", group=grpSTRows,
     minval=1, maxval=100, step=1,
     tooltip="სკალპის სამიზნე = RTH ADR × ეს %. ნაგულისხმევი 10%.")

grpSTCol = "მოდული 3: ცხრილის ფერები"
st_colHdrRTH = input.color(color.blue,   "RTH სათაურის ფონი",  group=grpSTCol)
st_colHdrETH = input.color(color.purple, "ETH სათაურის ფონი",  group=grpSTCol)
st_colHdrTxt = input.color(color.white,  "სათაურის ტექსტი",    group=grpSTCol)
st_colLabel  = input.color(color.gray,   "სტრიქონის დასახელება", group=grpSTCol)
st_colValue  = input.color(color.black,  "მნიშვნელობები",         group=grpSTCol)

// ============================================================================
// საერთო სესიის დეტექცია (დროის სარტყელის გათვალისწინებით)
// ============================================================================

bool in_session    = not na(time(timeframe.period, rth_session, rth_tz))
bool session_start = in_session and not in_session[1]
bool day_change    = ta.change(time("D")) != 0
bool first_bar     = session_start or (day_change and in_session and not session_start)

// ============================================================================
// RTH OHLC თრექინგი (ყოველთვის მუშაობს — კვებავს მოდულ 1-ს და მოდულ 3-ს)
// ============================================================================

var float rthOpen  = na
var float rthHigh  = na
var float rthLow   = na
var float rthClose = na

var float yOpen  = na
var float yHigh  = na
var float yLow   = na
var float yClose = na
var float yRange = na

if first_bar
    yOpen  := rthOpen
    yHigh  := rthHigh
    yLow   := rthLow
    yClose := rthClose
    yRange := not na(rthHigh) and not na(rthLow) ? rthHigh - rthLow : na
    rthOpen  := open
    rthHigh  := high
    rthLow   := low
    rthClose := close
else if in_session
    rthHigh  := math.max(nz(rthHigh), high)
    rthLow   := math.min(nz(rthLow), low)
    rthClose := close

// ============================================================================
// ABR გაანგარიშება — მოძრავი N დღიური RTH დიაპაზონები (ყოველთვის მუშაობს)
// ============================================================================

var float[] dailyRanges = array.new_float(0)
var float   currentABR  = na

if first_bar and not na(yRange) and yRange > 0
    array.push(dailyRanges, yRange)
    if array.size(dailyRanges) > lookback + 5
        array.shift(dailyRanges)

if first_bar and array.size(dailyRanges) >= lookback
    float sumR = 0.0
    int startIdx = array.size(dailyRanges) - lookback
    for i = startIdx to array.size(dailyRanges) - 1
        sumR += array.get(dailyRanges, i)
    currentABR := sumR / lookback
else if first_bar and array.size(dailyRanges) > 0
    float sumR = 0.0
    for i = 0 to array.size(dailyRanges) - 1
        sumR += array.get(dailyRanges, i)
    currentABR := sumR / array.size(dailyRanges)

// ============================================================================
// მოდული 1 — სამიზნეების გაანგარიშება
// ============================================================================

var float bull05 = na, var float bull1  = na
var float bull15 = na, var float bull2  = na
var float bear05 = na, var float bear1  = na
var float bear15 = na, var float bear2  = na

if first_bar and not na(yClose) and not na(currentABR)
    bull05 := yClose + 0.5 * currentABR
    bull1  := yClose + 1.0 * currentABR
    bull15 := yClose + 1.5 * currentABR
    bull2  := yClose + 2.0 * currentABR
    bear05 := yClose - 0.5 * currentABR
    bear1  := yClose - 1.0 * currentABR
    bear15 := yClose - 1.5 * currentABR
    bear2  := yClose - 2.0 * currentABR

// ============================================================================
// მოდული 1 — ხაზების ხატვა
// ============================================================================

f_drawLevel(float _price, color _col, string _style, string _txt) =>
    ln = line.new(bar_index, _price, bar_index + mm_lineExt, _price,
         xloc.bar_index, color=_col,
         style=_style == "solid" ? line.style_solid : _style == "dashed" ? line.style_dashed : line.style_dotted,
         width=mm_lineWidth)
    lb = mm_showLabels ? label.new(bar_index + mm_lineExt + mm_labelOff, _price,
         text=_txt + " " + str.tostring(_price, format.mintick),
         xloc=xloc.bar_index, style=label.style_none, textcolor=_col,
         size=size.small) : na
    [ln, lb]

if first_bar and not na(yClose) and not na(currentABR)
    if mm_show05x
        f_drawLevel(bull05, mm_colBull05, "solid", "ზრდა 0.5x")
        f_drawLevel(bear05, mm_colBear05, "solid", "კლება 0.5x")
    if mm_show1x
        f_drawLevel(bull1, mm_colBull1, "solid", "ზრდა 1.0x")
        f_drawLevel(bear1, mm_colBear1, "solid", "კლება 1.0x")
    if mm_show15x
        f_drawLevel(bull15, mm_colBull15, "dashed", "ზრდა 1.5x")
        f_drawLevel(bear15, mm_colBear15, "dashed", "კლება 1.5x")
    if mm_show2x
        f_drawLevel(bull2, mm_colBull2, "dashed", "ზრდა 2.0x")
        f_drawLevel(bear2, mm_colBear2, "dashed", "კლება 2.0x")

    if mm_showYClose
        f_drawLevel(yClose, mm_colYClose, "dotted", "y.Close")
    if mm_showYHiLo and not na(yHigh)
        f_drawLevel(yHigh, mm_colYHiLo, "dotted", "y.Hi")
        f_drawLevel(yLow,  mm_colYHiLo, "dotted", "y.Lo")
    if mm_showYdMM and not na(yHigh) and not na(yLow)
        f_drawLevel(yHigh + yRange, mm_colYdMM, "dotted", "yd MM ზევით")
        f_drawLevel(yLow  - yRange, mm_colYdMM, "dotted", "yd MM ქვევით")

// ============================================================================
// მოდული 1 — სამიზნეების ცხრილი (დიაგნოსტიკა, დამოუკიდებლად ჩართვადი)
// ============================================================================

if mm_showTable and barstate.islast and not na(currentABR)
    sz = switch mm_tableSize
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

    var table mmTbl = table.new(position.top_left, 2, 12,
         bgcolor=color.new(#1a1a2e, 10), border_color=color.new(color.gray, 70),
         border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

    table.cell(mmTbl, 0, 0, "ABR MM სამიზნეები", text_color=color.white,
         text_size=sz, bgcolor=color.new(#059669, 20), text_halign=text.align_left)
    table.cell(mmTbl, 1, 0, "y.Close-დან", text_color=color.gray,
         text_size=sz, bgcolor=color.new(#059669, 20), text_halign=text.align_right)

    table.cell(mmTbl, 0, 1, "y.Close", text_color=mm_colYClose,
         text_size=sz, text_halign=text.align_left)
    table.cell(mmTbl, 1, 1, str.tostring(yClose, format.mintick), text_color=mm_colYClose,
         text_size=sz, text_halign=text.align_right)

    table.cell(mmTbl, 0, 2, "ABR (" + str.tostring(lookback) + "დ)",
         text_color=color.white, text_size=sz, text_halign=text.align_left)
    table.cell(mmTbl, 1, 2, str.tostring(currentABR, "#.##"), text_color=color.white,
         text_size=sz, text_halign=text.align_right)

    table.cell(mmTbl, 0, 3, "y.Range", text_color=color.gray,
         text_size=sz, text_halign=text.align_left)
    table.cell(mmTbl, 1, 3, str.tostring(yRange, "#.##") + " (" +
         str.tostring(not na(yRange) and currentABR > 0 ? yRange / currentABR : na, "#.##") + "x ABR)",
         text_color=color.gray, text_size=sz, text_halign=text.align_right)

    table.cell(mmTbl, 0, 4, "--- ზრდა (Bull) ---", text_color=mm_colBull1,
         text_size=sz, text_halign=text.align_left)
    table.cell(mmTbl, 1, 4, "", text_size=sz)

    int row = 5
    if mm_show05x
        table.cell(mmTbl, 0, row, "ზრდა 0.5x", text_color=mm_colBull05, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bull05, format.mintick), text_color=mm_colBull05, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show1x
        table.cell(mmTbl, 0, row, "ზრდა 1.0x", text_color=mm_colBull1, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bull1, format.mintick), text_color=mm_colBull1, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show15x
        table.cell(mmTbl, 0, row, "ზრდა 1.5x", text_color=mm_colBull15, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bull15, format.mintick), text_color=mm_colBull15, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show2x
        table.cell(mmTbl, 0, row, "ზრდა 2.0x", text_color=mm_colBull2, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bull2, format.mintick), text_color=mm_colBull2, text_size=sz, text_halign=text.align_right)
        row += 1

    table.cell(mmTbl, 0, row, "--- კლება (Bear) ---", text_color=mm_colBear1,
         text_size=sz, text_halign=text.align_left)
    table.cell(mmTbl, 1, row, "", text_size=sz)
    row += 1

    if mm_show05x
        table.cell(mmTbl, 0, row, "კლება 0.5x", text_color=mm_colBear05, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bear05, format.mintick), text_color=mm_colBear05, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show1x
        table.cell(mmTbl, 0, row, "კლება 1.0x", text_color=mm_colBear1, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bear1, format.mintick), text_color=mm_colBear1, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show15x
        table.cell(mmTbl, 0, row, "კლება 1.5x", text_color=mm_colBear15, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bear15, format.mintick), text_color=mm_colBear15, text_size=sz, text_halign=text.align_right)
        row += 1
    if mm_show2x
        table.cell(mmTbl, 0, row, "კლება 2.0x", text_color=mm_colBear2, text_size=sz, text_halign=text.align_left)
        table.cell(mmTbl, 1, row, str.tostring(bear2, format.mintick), text_color=mm_colBear2, text_size=sz, text_halign=text.align_right)

// ============================================================================
// მოდული 2 — გახსნის დიაპაზონი (OPENING RANGE)
// ============================================================================

or_new_day = ta.change(time("D")) != 0
or_bars_since = ta.barssince(or_new_day)

var float or_hi = na
var float or_lo = na
var float or_lockedHigh = na
var float or_lockedLow  = na

if or_bars_since == 0
    or_hi := high
    or_lo := low
    or_lockedHigh := na
    or_lockedLow  := na
else if or_bars_since < or_bars
    or_hi := math.max(or_hi, high)
    or_lo := math.min(or_lo, low)

if or_bars_since == or_bars - 1
    or_lockedHigh := or_hi
    or_lockedLow  := or_lo

or_dailyHigh  = request.security(syminfo.tickerid, "D", high)
or_dailyLow   = request.security(syminfo.tickerid, "D", low)
or_dailyRange = or_dailyHigh - or_dailyLow
or_adr        = ta.sma(or_dailyRange, lookback)
or_range18    = or_lockedHigh - or_lockedLow
or_rangePct   = or_adr != 0 ? (or_range18 / or_adr) * 100 : na

or_drawProj(bool show, float mult, color col, string tag, int x1, int x2, float rHi, float rLo, float rng) =>
    if show
        float upTgt = rHi + mult * rng
        float dnTgt = rLo - mult * rng
        line.new(x1, upTgt, x2, upTgt, color=col, style=line.style_dashed, width=1)
        line.new(x1, dnTgt, x2, dnTgt, color=col, style=line.style_dashed, width=1)
        if or_showProjLbl
            label.new(x2, upTgt, tag, style=label.style_label_left, textcolor=col, size=size.small, color=color.new(color.black, 100))
            label.new(x2, dnTgt, tag, style=label.style_label_left, textcolor=col, size=size.small, color=color.new(color.black, 100))

if or_bars_since == or_bars - 1
    if or_showBox
        box.new(bar_index - (or_bars - 1), or_lockedHigh, bar_index, or_lockedLow,
             border_color=or_boxColor,
             bgcolor=color.new(or_boxColor, or_boxTrans))

    if or_showLabel
        label.new(bar_index, or_lockedHigh,
             str.tostring(or_range18, format.mintick) +
             "\nდღიური: " + str.tostring(or_dailyRange, format.mintick) +
             "\n%: " + str.tostring(or_rangePct, "#.##") + "%",
             style=label.style_label_down, textcolor=or_lblColor, size=size.normal)

    int x1 = bar_index + 1
    int x2 = bar_index + or_projLen
    // v1.5: 0.25x დაემატა პირველი
    or_drawProj(or_show025, 0.25, or_col025, "0.25x", x1, x2, or_lockedHigh, or_lockedLow, or_range18)
    or_drawProj(or_show050, 0.50, or_col050, "0.5x",  x1, x2, or_lockedHigh, or_lockedLow, or_range18)
    or_drawProj(or_show075, 0.75, or_col075, "0.75x", x1, x2, or_lockedHigh, or_lockedLow, or_range18)
    or_drawProj(or_show100, 1.00, or_col100, "1.0x",  x1, x2, or_lockedHigh, or_lockedLow, or_range18)
    or_drawProj(or_show150, 1.50, or_col150, "1.5x",  x1, x2, or_lockedHigh, or_lockedLow, or_range18)
    or_drawProj(or_show200, 2.00, or_col200, "2.0x",  x1, x2, or_lockedHigh, or_lockedLow, or_range18)

// ============================================================================
// მოდული 3 — ვოლატილობის სტატისტიკის ცხრილი
// ============================================================================

// --- გრაფიკის თაიმფრეიმის ABR ---
float st_bar_range = high - low
float st_abr_raw   = math.sum(st_bar_range, lookback) / lookback

var float st_abr = na
if barstate.isconfirmed
    st_abr := st_abr_raw

// --- RTH ADR (ძირითადი სესია) ---
var float st_ses_hi = na
var float st_ses_lo = na
var array<float> st_completed_ranges = array.new_float(0)

if first_bar
    if not na(st_ses_hi) and not na(st_ses_lo)
        array.push(st_completed_ranges, st_ses_hi - st_ses_lo)
        if array.size(st_completed_ranges) > lookback
            array.shift(st_completed_ranges)
    st_ses_hi := high
    st_ses_lo := low
else if in_session
    st_ses_hi := math.max(nz(st_ses_hi, high), high)
    st_ses_lo := math.min(nz(st_ses_lo, low), low)

float st_rth_adr   = array.size(st_completed_ranges) > 0 ? array.avg(st_completed_ranges) : na
float st_rth_today = not na(st_ses_hi) and not na(st_ses_lo) ? st_ses_hi - st_ses_lo : na
float st_rth_pct   = not na(st_rth_adr) and st_rth_adr > 0 and not na(st_rth_today) ? (st_rth_today / st_rth_adr) * 100.0 : 0.0

// --- ETH ADR (გაფართოებული სესია) ---
string st_eth_ticker = ticker.modify(syminfo.tickerid, session=session.extended)

float st_eth_d_hi = request.security(st_eth_ticker, 'D', high)
float st_eth_d_lo = request.security(st_eth_ticker, 'D', low)

st_eth_adr_calc() =>
    float s = 0.0
    for i = 1 to lookback
        s += (high[i] - low[i])
    s / lookback

float st_eth_adr   = request.security(st_eth_ticker, 'D', st_eth_adr_calc())
float st_eth_today = st_eth_d_hi - st_eth_d_lo
float st_eth_pct   = not na(st_eth_adr) and st_eth_adr > 0 ? (st_eth_today / st_eth_adr) * 100.0 : 0.0

// --- % ADR ფერი ---
// v1.5: >= 80% = მყარი წითელი; წინააღმდეგ შემთხვევაში გამოიყენება მორგებადი ფერი
color st_rth_pct_col = st_rth_pct >= 80 ? color.red : st_colValue
color st_eth_pct_col = st_eth_pct >= 80 ? color.red : st_colValue

// --- OR % ADR (სტატისტიკის ცხრილის სტრიქონისთვის) ---
float st_or_pct = not na(or_lockedHigh) and not na(or_lockedLow) and not na(st_rth_adr) and st_rth_adr > 0 ? ((or_lockedHigh - or_lockedLow) / st_rth_adr) * 100.0 : na

// --- v1.7: Swing / Scalp აბსოლუტური მნიშვნელობები (RTH ADR-იდან) ---
float st_swing = not na(st_rth_adr) ? st_rth_adr * (st_swingPct / 100.0) : na
float st_scalp = not na(st_rth_adr) ? st_rth_adr * (st_scalpPct / 100.0) : na

// --- ცხრილის პოზიცია ---
stPos = switch st_position
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

// --- სტატისტიკის ცხრილის ხატვა ---
// v1.7: ცხრილი გაფართოვდა 10 სტრიქონამდე Swing + Scalp-ის დასატევად
if st_showTable and (barstate.islastconfirmedhistory or barstate.isrealtime)
    var table stTbl = table.new(stPos, 3, 10, border_width=1)

    int row = 0

    if st_showSession
        table.cell(stTbl, 0, row, session_display, text_color=color.gray, text_size=size.tiny)
        table.cell(stTbl, 1, row, '', text_size=size.tiny)
        table.cell(stTbl, 2, row, '', text_size=size.tiny)
        table.merge_cells(stTbl, 0, row, 2, row)
        row += 1

    // სათაურები
    table.cell(stTbl, 0, row, '',    text_size=size.small)
    table.cell(stTbl, 1, row, 'RTH', text_color=st_colHdrTxt, text_size=size.small,
         bgcolor=color.new(st_colHdrRTH, 70))
    table.cell(stTbl, 2, row, 'ETH', text_color=st_colHdrTxt, text_size=size.small,
         bgcolor=color.new(st_colHdrETH, 70))
    row += 1

    // ABR
    table.cell(stTbl, 0, row, 'ABR (' + str.tostring(lookback) + ')', text_color=st_colLabel, text_size=size.small)
    table.cell(stTbl, 1, row, str.tostring(st_abr, format.mintick),    text_color=st_colValue, text_size=size.small)
    table.cell(stTbl, 2, row, '',                                       text_color=st_colLabel, text_size=size.small)
    row += 1

    // ADR
    table.cell(stTbl, 0, row, 'ADR (' + str.tostring(lookback) + ')',             text_color=st_colLabel, text_size=size.small)
    table.cell(stTbl, 1, row, str.tostring(math.round(nz(st_rth_adr)), '#'),      text_color=st_colValue, text_size=size.small)
    table.cell(stTbl, 2, row, str.tostring(math.round(nz(st_eth_adr)), '#'),      text_color=st_colValue, text_size=size.small)
    row += 1

    // დღეს
    table.cell(stTbl, 0, row, 'დღეს',                                             text_color=st_colLabel, text_size=size.small)
    table.cell(stTbl, 1, row, str.tostring(math.round(nz(st_rth_today)), '#'),    text_color=st_colValue, text_size=size.small)
    table.cell(stTbl, 2, row, str.tostring(math.round(nz(st_eth_today)), '#'),    text_color=st_colValue, text_size=size.small)
    row += 1

    // % ADR — v1.5: წითლდება როცა მიაღწევს >= 80%
    table.cell(stTbl, 0, row, '% ADR',                                             text_color=st_colLabel,    text_size=size.small)
    table.cell(stTbl, 1, row, str.tostring(math.round(st_rth_pct), '#') + '%',    text_color=st_rth_pct_col, text_size=size.small)
    table.cell(stTbl, 2, row, str.tostring(math.round(st_eth_pct), '#') + '%',    text_color=st_eth_pct_col, text_size=size.small)
    row += 1

    // OR % — v1.5: მხოლოდ RTH სვეტი, ცარიელია სანამ OR არ დაიბლოკება
    table.cell(stTbl, 0, row, 'OR %',                                             text_color=st_colLabel, text_size=size.small)
    table.cell(stTbl, 1, row, not na(st_or_pct) ? str.tostring(math.round(st_or_pct), '#') + '%' : '-', text_color=st_colValue, text_size=size.small)
    table.cell(stTbl, 2, row, '-',                                                text_color=st_colLabel, text_size=size.small)
    row += 1

    // v1.7: Swing — RTH ADR * swing% (მხოლოდ RTH)
    if st_showSwing
        table.cell(stTbl, 0, row, 'სვინგი ' + str.tostring(math.round(st_swingPct), '#') + '%', text_color=st_colLabel, text_size=size.small)
        table.cell(stTbl, 1, row, not na(st_swing) ? str.tostring(math.round(st_swing), '#') : '-', text_color=st_colValue, text_size=size.small)
        table.cell(stTbl, 2, row, '-',                                            text_color=st_colLabel, text_size=size.small)
        row += 1

    // v1.7: Scalp — RTH ADR * scalp% (მხოლოდ RTH)
    if st_showScalp
        table.cell(stTbl, 0, row, 'სკალპი ' + str.tostring(math.round(st_scalpPct), '#') + '%', text_color=st_colLabel, text_size=size.small)
        table.cell(stTbl, 1, row, not na(st_scalp) ? str.tostring(math.round(st_scalp), '#') : '-', text_color=st_colValue, text_size=size.small)
        table.cell(stTbl, 2, row, '-',                                            text_color=st_colLabel, text_size=size.small)
        row += 1

// ============================================================================
// მოდული 3 — მონაცემთა ფანჯრის გრაფიკები (DATA WINDOW PLOTS v1.8)
// ============================================================================
// ეს მნიშვნელობები ასახავს სტატისტიკის ცხრილს, მაგრამ ცოცხლობს გვერდითა Data Window პანელში.
// მუშაობს დამოუკიდებლად st_showTable-სგან — ცხრილი რომც დამალოთ, ესენი მაინც გამოჩნდება.
// display=display.data_window ნიშნავს, რომ გრაფიკზე ხაზები არ იხატება.

plot(st_abr,       title="ABR",       display=display.data_window)
plot(st_rth_adr,   title="ADR RTH",   display=display.data_window)
plot(st_eth_adr,   title="ADR ETH",   display=display.data_window)
plot(st_rth_today, title="Today RTH",  display=display.data_window)
plot(st_eth_today, title="Today ETH",  display=display.data_window)
plot(st_rth_pct,   title="% ADR RTH",  display=display.data_window)
plot(st_eth_pct,   title="% ADR ETH",  display=display.data_window)
plot(st_or_pct,    title="OR %",       display=display.data_window)
plot(st_swing,     title="Swing",      display=display.data_window)
plot(st_scalp,     title="Scalp",      display=display.data_window)

// ============================================================================
// დასასრული
// ============================================================================
````
