# U.S. Economic Calendar Master - Spectre Trades 

- url: https://www.tradingview.com/script/Ad9XZwgX-U-S-Economic-Calendar-Master-Spectre-Trades/
- type: indicator
- pine_id: PUB;541dcd0316f74e7c92650f0142d12cb2
- version: 1.0

## Description

U.S. Economic Calendar Master - Spectre Trades is a chart-overlay fully customizable indicator that marks major U.S. economic releases directly on the price chart using clear, customizable labels. It includes CPI, PPI, NFP, FOMC decisions, Core PCE, GDP, JOLTS, Retail Sales, ISM reports, ADP employment, Jobless Claims, Durable Goods, Consumer Confidence, housing data, Michigan Sentiment, Import/Export Prices, and the Employment Cost Index.

The purpose of this indicator is to help traders quickly identify sessions that may experience increased volatility, wider spreads, rapid liquidity sweeps, false breakouts, or sudden directional expansion. Instead of constantly switching between the chart and an external economic calendar, traders can see the event name, date, scheduled release time, and selected time zone directly on the chart.

Each event category can be turned on or off independently, and the labels can be customized by title, subtitle, color, text color, transparency, size, placement, date format, time format, and time-zone display. This allows traders to keep the chart clean while showing only the events that are relevant to their market and trading plan.

This indicator may help traders:

Prepare for high-impact trading sessions
Avoid entering trades immediately before scheduled news
Adjust position size and risk around volatile releases
Review historical market reactions to economic events
Improve opening-range, liquidity, VWAP, and market-structure analysis
Separate normal price movement from news-driven volatility

The indicator does not predict the outcome of an economic report or the direction of price. Its purpose is to provide advance awareness and improve risk management by making important economic dates and times visible within the trader’s normal chart workflow.

Disclaimer

This indicator is provided for informational and educational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

Economic release dates and times may be revised, postponed, canceled, or changed by the issuing organization. Traders should always confirm upcoming events through an official government source or a current economic calendar.

This indicator does not display actual, forecast, or previous economic data, and it does not determine whether a release is bullish or bearish. It does not guarantee increased volatility or predict how the market will react.

Trading futures, stocks, options, forex, and other leveraged products involves substantial risk. Users are solely responsible for their trading decisions, risk management, position sizing, and verification of all scheduled events.

## Source Code

````pine
//@version=6
indicator("Spectre U.S. Economic Calendar Master v10 — Label Times [2026]", shorttitle="Economic Labels v10", overlay=true, max_labels_count=500, max_lines_count=500)

// LABELS ONLY by default. Every event title, subtitle, color, visibility, and label appearance is customizable.
// Dates are manually programmed for calendar year 2026 and should be reviewed if agencies revise schedules.

const string G_MASTER = "01 — Master Controls"
const string G_TIME = "02 — Time Zone Controls"
const string G_TEXT = "03 — Shared Label Text"
const string G_POS = "04 — Shared Label Position"
const string G_LINE = "05 — Optional Event Lines"
const string G_LIMIT = "06 — Retention"
const string G_CPI = "06 — CPI Label"
const string G_PPI = "07 — PPI Label"
const string G_NFP = "08 — NFP Label"
const string G_FOMC = "09 — FOMC Label"
const string G_PCE = "10 — PCE Label"
const string G_GDP = "11 — GDP Label"
const string G_JOLTS = "12 — JOLTS Label"
const string G_RETAIL = "13 — RETAIL Label"
const string G_ISMM = "14 — ISMM Label"
const string G_ISMS = "15 — ISMS Label"
const string G_ADP = "16 — ADP Label"
const string G_CLAIMS = "17 — CLAIMS Label"
const string G_DURABLE = "18 — DURABLE Label"
const string G_CONF = "19 — CONF Label"
const string G_HOUSING = "20 — HOUSING Label"
const string G_NEWHOME = "21 — NEWHOME Label"
const string G_MICH = "22 — MICH Label"
const string G_IMPORT = "23 — IMPORT Label"
const string G_ECI = "24 — ECI Label"

bool enabled = input.bool(true, "Enable Indicator", group=G_MASTER)
bool intradayOnly = input.bool(true, "Intraday Charts Only", group=G_MASTER)
bool showHistorical = input.bool(true, "Show Historical Labels", group=G_MASTER)
bool showFuture = input.bool(true, "Show Future Labels When Bars Exist", group=G_MASTER)
const string SCHEDULE_TIMEZONE = "America/New_York"
int calendarShiftDays = input.int(0, "Shift Every Date by Days", minval=-10, maxval=10, group=G_MASTER)

string displayTimezonePreset = input.string(
     "America/Chicago",
     "Display Time Zone",
     options=[
          "America/New_York",
          "America/Chicago",
          "America/Denver",
          "America/Phoenix",
          "America/Los_Angeles",
          "America/Anchorage",
          "Pacific/Honolulu",
          "Europe/London",
          "Europe/Paris",
          "Asia/Tokyo",
          "Asia/Hong_Kong",
          "Asia/Singapore",
          "Australia/Sydney",
          "UTC",
          "Custom IANA"
     ],
     tooltip="Changes the date and time shown inside every event label. Official U.S. release timestamps remain anchored to New York time.",
     group=G_TIME)
string customDisplayTimezone = input.string(
     "America/Chicago",
     "Custom IANA Time Zone",
     tooltip="Used only when Display Time Zone is set to Custom IANA. Examples: America/Chicago, Europe/London, Asia/Tokyo.",
     group=G_TIME)
string displayTimezone = displayTimezonePreset == "Custom IANA" ? customDisplayTimezone : displayTimezonePreset
string timezoneTextMode = input.string(
     "Custom Text",
     "Time-Zone Label Text",
     options=["Custom Text", "Selected IANA Zone", "Hide"],
     group=G_TIME)
string customTimezoneText = input.string("CT", "Custom Time-Zone Text", group=G_TIME)
string anchorTimezoneMode = input.string(
     "Event Time Zone",
     "Anchor Time Zone",
     options=["Event Time Zone", "Display Time Zone"],
     tooltip="Release Bar always uses the true event timestamp. Start of Day and Custom Hour can use either New York time or your selected display time zone.",
     group=G_TIME)

bool showMainTitle = input.bool(true, "Show Main Title", group=G_TEXT)
bool showSubtitle = input.bool(false, "Show Subtitle", group=G_TEXT)
bool showDate = input.bool(true, "Show Date", group=G_TEXT)
bool showTime = input.bool(true, "Show Release Time", group=G_TEXT)
string timeFormatIn = input.string("12-Hour", "Time Format", options=["12-Hour", "24-Hour"], group=G_TEXT)
string dateTitle = input.string("Date:", "Date Prefix", group=G_TEXT)
string timeTitle = input.string("Release:", "Time Prefix", group=G_TEXT)
string dateFormatIn = input.string("MMM d, yyyy", "Date Format", options=["MMM d, yyyy", "MM/dd/yyyy", "yyyy-MM-dd", "EEEE, MMM d"], group=G_TEXT)
string lineSeparator = input.string("New Line", "Text Separator", options=["New Line", " • ", " | ", " — ", " Space"], group=G_TEXT)
string labelSizeIn = input.string("Large", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_TEXT)
string textAlignIn = input.string("Center", "Text Alignment", options=["Left", "Center", "Right"], group=G_TEXT)

string labelDirection = input.string("Label Down", "Label Shape", options=["Label Down", "Label Up", "Label Left", "Label Right"], group=G_POS)
string anchorMode = input.string("Release Bar", "Horizontal Anchor", options=["Release Bar", "Start of Calendar Day", "New York Open", "Custom Hour"], group=G_POS)
int customAnchorHour = input.int(8, "Custom Anchor Hour", minval=0, maxval=23, inline="anchor", group=G_POS)
int customAnchorMin = input.int(30, "Minute", minval=0, maxval=59, inline="anchor", group=G_POS)
string verticalMode = input.string("Above Bar", "Vertical Placement", options=["Above Bar", "Below Bar", "ATR Above", "ATR Below", "Absolute Price"], group=G_POS)
int atrLength = input.int(14, "ATR Length", minval=1, group=G_POS)
float atrOffset = input.float(1.0, "ATR Offset", minval=0.0, step=0.1, group=G_POS)
float absolutePrice = input.float(0.0, "Absolute Label Price", step=0.25, group=G_POS)
int horizontalOffset = input.int(0, "Horizontal Offset (Minutes)", minval=-1440, maxval=1440, group=G_POS)

bool showEventLine = input.bool(false, "Show Vertical Event Lines", group=G_LINE)
string lineStyleIn = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_LINE)
int lineWidth = input.int(1, "Line Width", minval=1, maxval=5, group=G_LINE)
int lineTransparency = input.int(30, "Line Transparency", minval=0, maxval=100, group=G_LINE)
int maxLabelsStored = input.int(450, "Maximum Labels", minval=1, maxval=490, group=G_LIMIT)
int maxLinesStored = input.int(250, "Maximum Lines", minval=1, maxval=490, group=G_LIMIT)

bool showCPI = input.bool(true, "Show CPI Labels", group=G_CPI)
string titleCPI = input.string("CPI DAY", "Main Title", group=G_CPI)
string subtitleCPI = input.string("Consumer Price Index", "Subtitle", group=G_CPI)
color bgCPI = input.color(color.rgb(220,55,55), "Background Color", group=G_CPI)
color textCPI = input.color(color.white, "Text Color", group=G_CPI)
int transpCPI = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_CPI)

bool showPPI = input.bool(true, "Show PPI Labels", group=G_PPI)
string titlePPI = input.string("PPI DAY", "Main Title", group=G_PPI)
string subtitlePPI = input.string("Producer Price Index", "Subtitle", group=G_PPI)
color bgPPI = input.color(color.rgb(245,135,35), "Background Color", group=G_PPI)
color textPPI = input.color(color.white, "Text Color", group=G_PPI)
int transpPPI = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_PPI)

bool showNFP = input.bool(true, "Show NFP Labels", group=G_NFP)
string titleNFP = input.string("NFP DAY", "Main Title", group=G_NFP)
string subtitleNFP = input.string("Employment Situation", "Subtitle", group=G_NFP)
color bgNFP = input.color(color.rgb(170,70,220), "Background Color", group=G_NFP)
color textNFP = input.color(color.white, "Text Color", group=G_NFP)
int transpNFP = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_NFP)

bool showFOMC = input.bool(true, "Show FOMC Labels", group=G_FOMC)
string titleFOMC = input.string("FOMC DAY", "Main Title", group=G_FOMC)
string subtitleFOMC = input.string("Federal Reserve Rate Decision", "Subtitle", group=G_FOMC)
color bgFOMC = input.color(color.rgb(35,120,225), "Background Color", group=G_FOMC)
color textFOMC = input.color(color.white, "Text Color", group=G_FOMC)
int transpFOMC = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_FOMC)

bool showPCE = input.bool(true, "Show PCE Labels", group=G_PCE)
string titlePCE = input.string("CORE PCE DAY", "Main Title", group=G_PCE)
string subtitlePCE = input.string("Personal Income and Outlays", "Subtitle", group=G_PCE)
color bgPCE = input.color(color.rgb(225,75,150), "Background Color", group=G_PCE)
color textPCE = input.color(color.white, "Text Color", group=G_PCE)
int transpPCE = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_PCE)

bool showGDP = input.bool(true, "Show GDP Labels", group=G_GDP)
string titleGDP = input.string("GDP DAY", "Main Title", group=G_GDP)
string subtitleGDP = input.string("Gross Domestic Product", "Subtitle", group=G_GDP)
color bgGDP = input.color(color.rgb(40,155,115), "Background Color", group=G_GDP)
color textGDP = input.color(color.white, "Text Color", group=G_GDP)
int transpGDP = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_GDP)

bool showJOLTS = input.bool(true, "Show JOLTS Labels", group=G_JOLTS)
string titleJOLTS = input.string("JOLTS DAY", "Main Title", group=G_JOLTS)
string subtitleJOLTS = input.string("Job Openings and Labor Turnover", "Subtitle", group=G_JOLTS)
color bgJOLTS = input.color(color.rgb(95,125,210), "Background Color", group=G_JOLTS)
color textJOLTS = input.color(color.white, "Text Color", group=G_JOLTS)
int transpJOLTS = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_JOLTS)

bool showRETAIL = input.bool(true, "Show RETAIL Labels", group=G_RETAIL)
string titleRETAIL = input.string("RETAIL SALES DAY", "Main Title", group=G_RETAIL)
string subtitleRETAIL = input.string("Advance Retail Sales", "Subtitle", group=G_RETAIL)
color bgRETAIL = input.color(color.rgb(205,105,45), "Background Color", group=G_RETAIL)
color textRETAIL = input.color(color.white, "Text Color", group=G_RETAIL)
int transpRETAIL = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_RETAIL)

bool showISMM = input.bool(true, "Show ISMM Labels", group=G_ISMM)
string titleISMM = input.string("ISM MFG DAY", "Main Title", group=G_ISMM)
string subtitleISMM = input.string("ISM Manufacturing PMI", "Subtitle", group=G_ISMM)
color bgISMM = input.color(color.rgb(55,145,205), "Background Color", group=G_ISMM)
color textISMM = input.color(color.white, "Text Color", group=G_ISMM)
int transpISMM = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_ISMM)

bool showISMS = input.bool(true, "Show ISMS Labels", group=G_ISMS)
string titleISMS = input.string("ISM SERVICES DAY", "Main Title", group=G_ISMS)
string subtitleISMS = input.string("ISM Services PMI", "Subtitle", group=G_ISMS)
color bgISMS = input.color(color.rgb(65,170,190), "Background Color", group=G_ISMS)
color textISMS = input.color(color.white, "Text Color", group=G_ISMS)
int transpISMS = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_ISMS)

bool showADP = input.bool(true, "Show ADP Labels", group=G_ADP)
string titleADP = input.string("ADP DAY", "Main Title", group=G_ADP)
string subtitleADP = input.string("ADP Employment Report", "Subtitle", group=G_ADP)
color bgADP = input.color(color.rgb(120,90,200), "Background Color", group=G_ADP)
color textADP = input.color(color.white, "Text Color", group=G_ADP)
int transpADP = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_ADP)

bool showCLAIMS = input.bool(true, "Show CLAIMS Labels", group=G_CLAIMS)
string titleCLAIMS = input.string("JOBLESS CLAIMS", "Main Title", group=G_CLAIMS)
string subtitleCLAIMS = input.string("Initial Jobless Claims", "Subtitle", group=G_CLAIMS)
color bgCLAIMS = input.color(color.rgb(115,125,140), "Background Color", group=G_CLAIMS)
color textCLAIMS = input.color(color.white, "Text Color", group=G_CLAIMS)
int transpCLAIMS = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_CLAIMS)

bool showDURABLE = input.bool(true, "Show DURABLE Labels", group=G_DURABLE)
string titleDURABLE = input.string("DURABLE GOODS DAY", "Main Title", group=G_DURABLE)
string subtitleDURABLE = input.string("Advance Durable Goods", "Subtitle", group=G_DURABLE)
color bgDURABLE = input.color(color.rgb(180,115,45), "Background Color", group=G_DURABLE)
color textDURABLE = input.color(color.white, "Text Color", group=G_DURABLE)
int transpDURABLE = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_DURABLE)

bool showCONF = input.bool(true, "Show CONF Labels", group=G_CONF)
string titleCONF = input.string("CONSUMER CONFIDENCE", "Main Title", group=G_CONF)
string subtitleCONF = input.string("Conference Board Consumer Confidence", "Subtitle", group=G_CONF)
color bgCONF = input.color(color.rgb(220,165,45), "Background Color", group=G_CONF)
color textCONF = input.color(color.white, "Text Color", group=G_CONF)
int transpCONF = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_CONF)

bool showHOUSING = input.bool(true, "Show HOUSING Labels", group=G_HOUSING)
string titleHOUSING = input.string("HOUSING STARTS DAY", "Main Title", group=G_HOUSING)
string subtitleHOUSING = input.string("Housing Starts and Building Permits", "Subtitle", group=G_HOUSING)
color bgHOUSING = input.color(color.rgb(85,155,95), "Background Color", group=G_HOUSING)
color textHOUSING = input.color(color.white, "Text Color", group=G_HOUSING)
int transpHOUSING = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_HOUSING)

bool showNEWHOME = input.bool(true, "Show NEWHOME Labels", group=G_NEWHOME)
string titleNEWHOME = input.string("NEW HOME SALES DAY", "Main Title", group=G_NEWHOME)
string subtitleNEWHOME = input.string("New Residential Sales", "Subtitle", group=G_NEWHOME)
color bgNEWHOME = input.color(color.rgb(70,135,95), "Background Color", group=G_NEWHOME)
color textNEWHOME = input.color(color.white, "Text Color", group=G_NEWHOME)
int transpNEWHOME = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_NEWHOME)

bool showMICH = input.bool(true, "Show MICH Labels", group=G_MICH)
string titleMICH = input.string("MICHIGAN SENTIMENT", "Main Title", group=G_MICH)
string subtitleMICH = input.string("University of Michigan Sentiment", "Subtitle", group=G_MICH)
color bgMICH = input.color(color.rgb(225,185,45), "Background Color", group=G_MICH)
color textMICH = input.color(color.white, "Text Color", group=G_MICH)
int transpMICH = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_MICH)

bool showIMPORT = input.bool(true, "Show IMPORT Labels", group=G_IMPORT)
string titleIMPORT = input.string("IMPORT/EXPORT PRICES", "Main Title", group=G_IMPORT)
string subtitleIMPORT = input.string("U.S. Import and Export Price Indexes", "Subtitle", group=G_IMPORT)
color bgIMPORT = input.color(color.rgb(95,145,165), "Background Color", group=G_IMPORT)
color textIMPORT = input.color(color.white, "Text Color", group=G_IMPORT)
int transpIMPORT = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_IMPORT)

bool showECI = input.bool(true, "Show ECI Labels", group=G_ECI)
string titleECI = input.string("ECI DAY", "Main Title", group=G_ECI)
string subtitleECI = input.string("Employment Cost Index", "Subtitle", group=G_ECI)
color bgECI = input.color(color.rgb(155,90,120), "Background Color", group=G_ECI)
color textECI = input.color(color.white, "Text Color", group=G_ECI)
int transpECI = input.int(0, "Background Transparency", minval=0, maxval=100, group=G_ECI)

const int T_CPI = 0
const int T_PPI = 1
const int T_NFP = 2
const int T_FOMC = 3
const int T_PCE = 4
const int T_GDP = 5
const int T_JOLTS = 6
const int T_RETAIL = 7
const int T_ISMM = 8
const int T_ISMS = 9
const int T_ADP = 10
const int T_CLAIMS = 11
const int T_DURABLE = 12
const int T_CONF = 13
const int T_HOUSING = 14
const int T_NEWHOME = 15
const int T_MICH = 16
const int T_IMPORT = 17
const int T_ECI = 18
const int MS_MIN = 60000

f_size(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge
f_style(string s) => s == "Label Up" ? label.style_label_up : s == "Label Left" ? label.style_label_left : s == "Label Right" ? label.style_label_right : label.style_label_down
f_align(string s) => s == "Left" ? text.align_left : s == "Right" ? text.align_right : text.align_center
f_lineStyle(string s) => s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed
f_sep() => lineSeparator == "New Line" ? "\n" : lineSeparator == " Space" ? " " : lineSeparator
f_ts(int m, int d, int h, int mn) => timestamp(SCHEDULE_TIMEZONE, 2026, m, d + calendarShiftDays, h, mn)

f_enabled(int t) =>
    switch t
        T_CPI => showCPI
        T_PPI => showPPI
        T_NFP => showNFP
        T_FOMC => showFOMC
        T_PCE => showPCE
        T_GDP => showGDP
        T_JOLTS => showJOLTS
        T_RETAIL => showRETAIL
        T_ISMM => showISMM
        T_ISMS => showISMS
        T_ADP => showADP
        T_CLAIMS => showCLAIMS
        T_DURABLE => showDURABLE
        T_CONF => showCONF
        T_HOUSING => showHOUSING
        T_NEWHOME => showNEWHOME
        T_MICH => showMICH
        T_IMPORT => showIMPORT
        T_ECI => showECI
        => false
f_title(int t) =>
    switch t
        T_CPI => titleCPI
        T_PPI => titlePPI
        T_NFP => titleNFP
        T_FOMC => titleFOMC
        T_PCE => titlePCE
        T_GDP => titleGDP
        T_JOLTS => titleJOLTS
        T_RETAIL => titleRETAIL
        T_ISMM => titleISMM
        T_ISMS => titleISMS
        T_ADP => titleADP
        T_CLAIMS => titleCLAIMS
        T_DURABLE => titleDURABLE
        T_CONF => titleCONF
        T_HOUSING => titleHOUSING
        T_NEWHOME => titleNEWHOME
        T_MICH => titleMICH
        T_IMPORT => titleIMPORT
        T_ECI => titleECI
        => "EVENT"
f_subtitle(int t) =>
    switch t
        T_CPI => subtitleCPI
        T_PPI => subtitlePPI
        T_NFP => subtitleNFP
        T_FOMC => subtitleFOMC
        T_PCE => subtitlePCE
        T_GDP => subtitleGDP
        T_JOLTS => subtitleJOLTS
        T_RETAIL => subtitleRETAIL
        T_ISMM => subtitleISMM
        T_ISMS => subtitleISMS
        T_ADP => subtitleADP
        T_CLAIMS => subtitleCLAIMS
        T_DURABLE => subtitleDURABLE
        T_CONF => subtitleCONF
        T_HOUSING => subtitleHOUSING
        T_NEWHOME => subtitleNEWHOME
        T_MICH => subtitleMICH
        T_IMPORT => subtitleIMPORT
        T_ECI => subtitleECI
        => ""
f_bg(int t) =>
    switch t
        T_CPI => bgCPI
        T_PPI => bgPPI
        T_NFP => bgNFP
        T_FOMC => bgFOMC
        T_PCE => bgPCE
        T_GDP => bgGDP
        T_JOLTS => bgJOLTS
        T_RETAIL => bgRETAIL
        T_ISMM => bgISMM
        T_ISMS => bgISMS
        T_ADP => bgADP
        T_CLAIMS => bgCLAIMS
        T_DURABLE => bgDURABLE
        T_CONF => bgCONF
        T_HOUSING => bgHOUSING
        T_NEWHOME => bgNEWHOME
        T_MICH => bgMICH
        T_IMPORT => bgIMPORT
        T_ECI => bgECI
        => color.gray
f_textColor(int t) =>
    switch t
        T_CPI => textCPI
        T_PPI => textPPI
        T_NFP => textNFP
        T_FOMC => textFOMC
        T_PCE => textPCE
        T_GDP => textGDP
        T_JOLTS => textJOLTS
        T_RETAIL => textRETAIL
        T_ISMM => textISMM
        T_ISMS => textISMS
        T_ADP => textADP
        T_CLAIMS => textCLAIMS
        T_DURABLE => textDURABLE
        T_CONF => textCONF
        T_HOUSING => textHOUSING
        T_NEWHOME => textNEWHOME
        T_MICH => textMICH
        T_IMPORT => textIMPORT
        T_ECI => textECI
        => color.white
f_transp(int t) =>
    switch t
        T_CPI => transpCPI
        T_PPI => transpPPI
        T_NFP => transpNFP
        T_FOMC => transpFOMC
        T_PCE => transpPCE
        T_GDP => transpGDP
        T_JOLTS => transpJOLTS
        T_RETAIL => transpRETAIL
        T_ISMM => transpISMM
        T_ISMS => transpISMS
        T_ADP => transpADP
        T_CLAIMS => transpCLAIMS
        T_DURABLE => transpDURABLE
        T_CONF => transpCONF
        T_HOUSING => transpHOUSING
        T_NEWHOME => transpNEWHOME
        T_MICH => transpMICH
        T_IMPORT => transpIMPORT
        T_ECI => transpECI
        => 0

f_anchor(int eventTs) =>
    string anchorTimezone = anchorTimezoneMode == "Display Time Zone" ? displayTimezone : SCHEDULE_TIMEZONE
    int y = year(eventTs, anchorTimezone)
    int m = month(eventTs, anchorTimezone)
    int d = dayofmonth(eventTs, anchorTimezone)
    int result = eventTs
    if anchorMode == "Start of Calendar Day"
        result := timestamp(anchorTimezone, y, m, d, 0, 0)
    else if anchorMode == "New York Open"
        int nyY = year(eventTs, SCHEDULE_TIMEZONE)
        int nyM = month(eventTs, SCHEDULE_TIMEZONE)
        int nyD = dayofmonth(eventTs, SCHEDULE_TIMEZONE)
        result := timestamp(SCHEDULE_TIMEZONE, nyY, nyM, nyD, 9, 30)
    else if anchorMode == "Custom Hour"
        result := timestamp(anchorTimezone, y, m, d, customAnchorHour, customAnchorMin)
    result + horizontalOffset * MS_MIN

f_labelText(int t, int ts) =>
    string sep = f_sep()
    string out = ""
    if showMainTitle
        out := f_title(t)
    if showSubtitle and str.length(f_subtitle(t)) > 0
        out := str.length(out) > 0 ? out + sep + f_subtitle(t) : f_subtitle(t)
    if showDate
        string p = (str.length(dateTitle) > 0 ? dateTitle + " " : "") + str.format_time(ts, dateFormatIn, displayTimezone)
        out := str.length(out) > 0 ? out + sep + p : p
    if showTime
        string zoneText = timezoneTextMode == "Selected IANA Zone" ? displayTimezone : timezoneTextMode == "Custom Text" ? customTimezoneText : ""
        string p = (str.length(timeTitle) > 0 ? timeTitle + " " : "") + str.format_time(ts, timeFormatIn == "24-Hour" ? "HH:mm" : "h:mm a", displayTimezone) + (str.length(zoneText) > 0 ? " " + zoneText : "")
        out := str.length(out) > 0 ? out + sep + p : p
    out

var array<int> eventTimes = array.new_int()
var array<int> eventTypes = array.new_int()
var array<label> labelQueue = array.new_label()
var array<line> lineQueue = array.new_line()
f_add(int t, int m, int d, int h, int mn) =>
    if f_enabled(t)
        array.push(eventTimes, f_ts(m,d,h,mn))
        array.push(eventTypes, t)
f_storeLabel(label id) =>
    array.push(labelQueue, id)
    if array.size(labelQueue) > maxLabelsStored
        label.delete(array.shift(labelQueue))
f_storeLine(line id) =>
    array.push(lineQueue, id)
    if array.size(lineQueue) > maxLinesStored
        line.delete(array.shift(lineQueue))

// Split schedule loaders prevent Pine's "if statement is too long" compiler error.
f_load_CPI() =>
    f_add(T_CPI, 1, 13, 8, 30)
    f_add(T_CPI, 2, 13, 8, 30)
    f_add(T_CPI, 3, 11, 8, 30)
    f_add(T_CPI, 4, 10, 8, 30)
    f_add(T_CPI, 5, 12, 8, 30)
    f_add(T_CPI, 6, 10, 8, 30)
    f_add(T_CPI, 7, 14, 8, 30)
    f_add(T_CPI, 8, 12, 8, 30)
    f_add(T_CPI, 9, 11, 8, 30)
    f_add(T_CPI, 10, 14, 8, 30)
    f_add(T_CPI, 11, 10, 8, 30)
    f_add(T_CPI, 12, 10, 8, 30)

f_load_PPI() =>
    f_add(T_PPI, 1, 14, 8, 30)
    f_add(T_PPI, 1, 30, 8, 30)
    f_add(T_PPI, 2, 27, 8, 30)
    f_add(T_PPI, 3, 18, 8, 30)
    f_add(T_PPI, 4, 14, 8, 30)
    f_add(T_PPI, 5, 13, 8, 30)
    f_add(T_PPI, 6, 11, 8, 30)
    f_add(T_PPI, 7, 15, 8, 30)
    f_add(T_PPI, 8, 13, 8, 30)
    f_add(T_PPI, 9, 10, 8, 30)
    f_add(T_PPI, 10, 15, 8, 30)
    f_add(T_PPI, 11, 13, 8, 30)
    f_add(T_PPI, 12, 15, 8, 30)

f_load_NFP() =>
    f_add(T_NFP, 1, 9, 8, 30)
    f_add(T_NFP, 2, 11, 8, 30)
    f_add(T_NFP, 3, 6, 8, 30)
    f_add(T_NFP, 4, 3, 8, 30)
    f_add(T_NFP, 5, 8, 8, 30)
    f_add(T_NFP, 6, 5, 8, 30)
    f_add(T_NFP, 7, 2, 8, 30)
    f_add(T_NFP, 8, 7, 8, 30)
    f_add(T_NFP, 9, 4, 8, 30)
    f_add(T_NFP, 10, 2, 8, 30)
    f_add(T_NFP, 11, 6, 8, 30)
    f_add(T_NFP, 12, 4, 8, 30)

f_load_FOMC() =>
    f_add(T_FOMC, 1, 28, 14, 0)
    f_add(T_FOMC, 3, 18, 14, 0)
    f_add(T_FOMC, 4, 29, 14, 0)
    f_add(T_FOMC, 6, 17, 14, 0)
    f_add(T_FOMC, 7, 29, 14, 0)
    f_add(T_FOMC, 9, 16, 14, 0)
    f_add(T_FOMC, 10, 28, 14, 0)
    f_add(T_FOMC, 12, 9, 14, 0)

f_load_PCE() =>
    f_add(T_PCE, 1, 22, 10, 0)
    f_add(T_PCE, 2, 20, 8, 30)
    f_add(T_PCE, 3, 13, 8, 30)
    f_add(T_PCE, 4, 9, 8, 30)
    f_add(T_PCE, 4, 30, 8, 30)
    f_add(T_PCE, 5, 28, 8, 30)
    f_add(T_PCE, 6, 25, 8, 30)
    f_add(T_PCE, 7, 30, 8, 30)
    f_add(T_PCE, 8, 26, 8, 30)
    f_add(T_PCE, 9, 30, 8, 30)
    f_add(T_PCE, 10, 29, 8, 30)
    f_add(T_PCE, 11, 25, 8, 30)
    f_add(T_PCE, 12, 23, 8, 30)

f_load_GDP() =>
    f_add(T_GDP, 1, 22, 8, 30)
    f_add(T_GDP, 2, 20, 8, 30)
    f_add(T_GDP, 3, 13, 8, 30)
    f_add(T_GDP, 4, 9, 8, 30)
    f_add(T_GDP, 4, 30, 8, 30)
    f_add(T_GDP, 5, 28, 8, 30)
    f_add(T_GDP, 6, 25, 8, 30)
    f_add(T_GDP, 7, 30, 8, 30)
    f_add(T_GDP, 8, 26, 8, 30)
    f_add(T_GDP, 9, 30, 8, 30)
    f_add(T_GDP, 10, 29, 8, 30)
    f_add(T_GDP, 11, 25, 8, 30)
    f_add(T_GDP, 12, 23, 8, 30)

f_load_JOLTS() =>
    f_add(T_JOLTS, 1, 7, 10, 0)
    f_add(T_JOLTS, 2, 5, 10, 0)
    f_add(T_JOLTS, 3, 13, 10, 0)
    f_add(T_JOLTS, 3, 31, 10, 0)
    f_add(T_JOLTS, 5, 5, 10, 0)
    f_add(T_JOLTS, 6, 2, 10, 0)
    f_add(T_JOLTS, 6, 30, 10, 0)
    f_add(T_JOLTS, 8, 4, 10, 0)
    f_add(T_JOLTS, 9, 1, 10, 0)
    f_add(T_JOLTS, 9, 29, 10, 0)
    f_add(T_JOLTS, 11, 3, 10, 0)
    f_add(T_JOLTS, 12, 1, 10, 0)

f_load_RETAIL() =>
    f_add(T_RETAIL, 1, 14, 8, 30)
    f_add(T_RETAIL, 2, 10, 8, 30)
    f_add(T_RETAIL, 3, 6, 8, 30)
    f_add(T_RETAIL, 4, 1, 8, 30)
    f_add(T_RETAIL, 4, 21, 8, 30)
    f_add(T_RETAIL, 5, 14, 8, 30)
    f_add(T_RETAIL, 6, 17, 8, 30)
    f_add(T_RETAIL, 7, 16, 8, 30)
    f_add(T_RETAIL, 8, 14, 8, 30)
    f_add(T_RETAIL, 9, 16, 8, 30)
    f_add(T_RETAIL, 10, 15, 8, 30)
    f_add(T_RETAIL, 11, 17, 8, 30)

f_load_ISMM() =>
    f_add(T_ISMM, 1, 5, 10, 0)
    f_add(T_ISMM, 2, 2, 10, 0)
    f_add(T_ISMM, 3, 2, 10, 0)
    f_add(T_ISMM, 4, 1, 10, 0)
    f_add(T_ISMM, 5, 1, 10, 0)
    f_add(T_ISMM, 6, 1, 10, 0)
    f_add(T_ISMM, 7, 1, 10, 0)
    f_add(T_ISMM, 8, 3, 10, 0)
    f_add(T_ISMM, 9, 1, 10, 0)
    f_add(T_ISMM, 10, 1, 10, 0)
    f_add(T_ISMM, 11, 2, 10, 0)
    f_add(T_ISMM, 12, 1, 10, 0)

f_load_ISMS() =>
    f_add(T_ISMS, 1, 7, 10, 0)
    f_add(T_ISMS, 2, 4, 10, 0)
    f_add(T_ISMS, 3, 4, 10, 0)
    f_add(T_ISMS, 4, 6, 10, 0)
    f_add(T_ISMS, 5, 5, 10, 0)
    f_add(T_ISMS, 6, 3, 10, 0)
    f_add(T_ISMS, 7, 6, 10, 0)
    f_add(T_ISMS, 8, 5, 10, 0)
    f_add(T_ISMS, 9, 3, 10, 0)
    f_add(T_ISMS, 10, 5, 10, 0)
    f_add(T_ISMS, 11, 4, 10, 0)
    f_add(T_ISMS, 12, 3, 10, 0)

f_load_ADP() =>
    f_add(T_ADP, 1, 7, 8, 15)
    f_add(T_ADP, 2, 4, 8, 15)
    f_add(T_ADP, 3, 4, 8, 15)
    f_add(T_ADP, 4, 1, 8, 15)
    f_add(T_ADP, 5, 6, 8, 15)
    f_add(T_ADP, 6, 3, 8, 15)
    f_add(T_ADP, 7, 1, 8, 15)
    f_add(T_ADP, 8, 5, 8, 15)
    f_add(T_ADP, 9, 2, 8, 15)
    f_add(T_ADP, 9, 30, 8, 15)
    f_add(T_ADP, 11, 4, 8, 15)
    f_add(T_ADP, 12, 2, 8, 15)

f_load_CLAIMS() =>
    f_add(T_CLAIMS, 1, 8, 8, 30)
    f_add(T_CLAIMS, 1, 15, 8, 30)
    f_add(T_CLAIMS, 1, 22, 8, 30)
    f_add(T_CLAIMS, 1, 29, 8, 30)
    f_add(T_CLAIMS, 2, 5, 8, 30)
    f_add(T_CLAIMS, 2, 12, 8, 30)
    f_add(T_CLAIMS, 2, 19, 8, 30)
    f_add(T_CLAIMS, 2, 26, 8, 30)
    f_add(T_CLAIMS, 3, 5, 8, 30)
    f_add(T_CLAIMS, 3, 12, 8, 30)
    f_add(T_CLAIMS, 3, 19, 8, 30)
    f_add(T_CLAIMS, 3, 26, 8, 30)
    f_add(T_CLAIMS, 4, 2, 8, 30)
    f_add(T_CLAIMS, 4, 9, 8, 30)
    f_add(T_CLAIMS, 4, 16, 8, 30)
    f_add(T_CLAIMS, 4, 23, 8, 30)
    f_add(T_CLAIMS, 4, 30, 8, 30)
    f_add(T_CLAIMS, 5, 7, 8, 30)
    f_add(T_CLAIMS, 5, 14, 8, 30)
    f_add(T_CLAIMS, 5, 21, 8, 30)
    f_add(T_CLAIMS, 5, 28, 8, 30)
    f_add(T_CLAIMS, 6, 4, 8, 30)
    f_add(T_CLAIMS, 6, 11, 8, 30)
    f_add(T_CLAIMS, 6, 18, 8, 30)
    f_add(T_CLAIMS, 6, 25, 8, 30)
    f_add(T_CLAIMS, 7, 2, 8, 30)
    f_add(T_CLAIMS, 7, 9, 8, 30)
    f_add(T_CLAIMS, 7, 16, 8, 30)
    f_add(T_CLAIMS, 7, 23, 8, 30)
    f_add(T_CLAIMS, 7, 30, 8, 30)
    f_add(T_CLAIMS, 8, 6, 8, 30)
    f_add(T_CLAIMS, 8, 13, 8, 30)
    f_add(T_CLAIMS, 8, 20, 8, 30)
    f_add(T_CLAIMS, 8, 27, 8, 30)
    f_add(T_CLAIMS, 9, 3, 8, 30)
    f_add(T_CLAIMS, 9, 10, 8, 30)
    f_add(T_CLAIMS, 9, 17, 8, 30)
    f_add(T_CLAIMS, 9, 24, 8, 30)
    f_add(T_CLAIMS, 10, 1, 8, 30)
    f_add(T_CLAIMS, 10, 8, 8, 30)
    f_add(T_CLAIMS, 10, 15, 8, 30)
    f_add(T_CLAIMS, 10, 22, 8, 30)
    f_add(T_CLAIMS, 10, 29, 8, 30)
    f_add(T_CLAIMS, 11, 5, 8, 30)
    f_add(T_CLAIMS, 11, 12, 8, 30)
    f_add(T_CLAIMS, 11, 19, 8, 30)
    f_add(T_CLAIMS, 11, 25, 8, 30)
    f_add(T_CLAIMS, 12, 3, 8, 30)
    f_add(T_CLAIMS, 12, 10, 8, 30)
    f_add(T_CLAIMS, 12, 17, 8, 30)
    f_add(T_CLAIMS, 12, 24, 8, 30)
    f_add(T_CLAIMS, 12, 31, 8, 30)

f_load_DURABLE() =>
    f_add(T_DURABLE, 1, 26, 8, 30)
    f_add(T_DURABLE, 2, 18, 8, 30)
    f_add(T_DURABLE, 3, 13, 8, 30)
    f_add(T_DURABLE, 4, 7, 8, 30)
    f_add(T_DURABLE, 4, 29, 8, 30)
    f_add(T_DURABLE, 5, 28, 8, 30)
    f_add(T_DURABLE, 6, 25, 8, 30)
    f_add(T_DURABLE, 7, 27, 8, 30)
    f_add(T_DURABLE, 8, 26, 8, 30)
    f_add(T_DURABLE, 9, 25, 8, 30)
    f_add(T_DURABLE, 10, 27, 8, 30)
    f_add(T_DURABLE, 11, 25, 8, 30)

f_load_CONF() =>
    f_add(T_CONF, 1, 27, 10, 0)
    f_add(T_CONF, 2, 24, 10, 0)
    f_add(T_CONF, 3, 31, 10, 0)
    f_add(T_CONF, 4, 28, 10, 0)
    f_add(T_CONF, 5, 26, 10, 0)
    f_add(T_CONF, 6, 30, 10, 0)
    f_add(T_CONF, 7, 28, 10, 0)
    f_add(T_CONF, 8, 25, 10, 0)
    f_add(T_CONF, 9, 29, 10, 0)
    f_add(T_CONF, 10, 27, 10, 0)
    f_add(T_CONF, 11, 24, 10, 0)
    f_add(T_CONF, 12, 29, 10, 0)

f_load_HOUSING() =>
    f_add(T_HOUSING, 1, 9, 8, 30)
    f_add(T_HOUSING, 2, 18, 8, 30)
    f_add(T_HOUSING, 3, 12, 8, 30)
    f_add(T_HOUSING, 4, 29, 8, 30)
    f_add(T_HOUSING, 5, 21, 8, 30)
    f_add(T_HOUSING, 6, 16, 8, 30)
    f_add(T_HOUSING, 7, 17, 8, 30)
    f_add(T_HOUSING, 8, 18, 8, 30)
    f_add(T_HOUSING, 9, 17, 8, 30)
    f_add(T_HOUSING, 10, 20, 8, 30)
    f_add(T_HOUSING, 11, 18, 8, 30)
    f_add(T_HOUSING, 12, 17, 8, 30)

f_load_NEWHOME() =>
    f_add(T_NEWHOME, 1, 13, 10, 0)
    f_add(T_NEWHOME, 2, 20, 10, 0)
    f_add(T_NEWHOME, 3, 19, 10, 0)
    f_add(T_NEWHOME, 5, 5, 10, 0)
    f_add(T_NEWHOME, 5, 28, 10, 0)
    f_add(T_NEWHOME, 6, 24, 10, 0)
    f_add(T_NEWHOME, 7, 24, 10, 0)
    f_add(T_NEWHOME, 8, 25, 10, 0)
    f_add(T_NEWHOME, 9, 24, 10, 0)
    f_add(T_NEWHOME, 10, 27, 10, 0)
    f_add(T_NEWHOME, 11, 25, 10, 0)

f_load_MICH() =>
    f_add(T_MICH, 1, 9, 10, 0)
    f_add(T_MICH, 1, 23, 10, 0)
    f_add(T_MICH, 2, 6, 10, 0)
    f_add(T_MICH, 2, 20, 10, 0)
    f_add(T_MICH, 3, 13, 10, 0)
    f_add(T_MICH, 3, 27, 10, 0)
    f_add(T_MICH, 4, 10, 10, 0)
    f_add(T_MICH, 4, 24, 10, 0)
    f_add(T_MICH, 5, 8, 10, 0)
    f_add(T_MICH, 5, 22, 10, 0)
    f_add(T_MICH, 6, 12, 10, 0)
    f_add(T_MICH, 6, 26, 10, 0)
    f_add(T_MICH, 7, 17, 10, 0)
    f_add(T_MICH, 7, 31, 10, 0)
    f_add(T_MICH, 8, 14, 10, 0)
    f_add(T_MICH, 8, 28, 10, 0)
    f_add(T_MICH, 9, 11, 10, 0)
    f_add(T_MICH, 9, 25, 10, 0)
    f_add(T_MICH, 10, 9, 10, 0)
    f_add(T_MICH, 10, 23, 10, 0)
    f_add(T_MICH, 11, 6, 10, 0)
    f_add(T_MICH, 11, 20, 10, 0)
    f_add(T_MICH, 12, 4, 10, 0)
    f_add(T_MICH, 12, 18, 10, 0)

f_load_IMPORT() =>
    f_add(T_IMPORT, 1, 15, 8, 30)
    f_add(T_IMPORT, 2, 10, 8, 30)
    f_add(T_IMPORT, 3, 5, 8, 30)
    f_add(T_IMPORT, 3, 25, 8, 30)
    f_add(T_IMPORT, 4, 15, 8, 30)
    f_add(T_IMPORT, 5, 14, 8, 30)
    f_add(T_IMPORT, 6, 16, 8, 30)
    f_add(T_IMPORT, 7, 17, 8, 30)
    f_add(T_IMPORT, 8, 18, 8, 30)
    f_add(T_IMPORT, 9, 16, 8, 30)
    f_add(T_IMPORT, 10, 16, 8, 30)
    f_add(T_IMPORT, 11, 17, 8, 30)
    f_add(T_IMPORT, 12, 17, 8, 30)

f_load_ECI() =>
    f_add(T_ECI, 2, 10, 8, 30)
    f_add(T_ECI, 4, 30, 8, 30)
    f_add(T_ECI, 7, 31, 8, 30)
    f_add(T_ECI, 10, 30, 8, 30)

if barstate.isfirst
    f_load_CPI()
    f_load_PPI()
    f_load_NFP()
    f_load_FOMC()
    f_load_PCE()
    f_load_GDP()
    f_load_JOLTS()
    f_load_RETAIL()
    f_load_ISMM()
    f_load_ISMS()
    f_load_ADP()
    f_load_CLAIMS()
    f_load_DURABLE()
    f_load_CONF()
    f_load_HOUSING()
    f_load_NEWHOME()
    f_load_MICH()
    f_load_IMPORT()
    f_load_ECI()
bool displayOK = enabled and (not intradayOnly or timeframe.isintraday)
float atr = ta.atr(atrLength)
bool anyEventNow = false
if displayOK and array.size(eventTimes) > 0
    for i = 0 to array.size(eventTimes) - 1
        int ts = array.get(eventTimes, i)
        int t = array.get(eventTypes, i)
        bool visible = (ts < timenow and showHistorical) or (ts >= timenow and showFuture)
        bool eventBar = time <= ts and time_close > ts
        if visible and eventBar
            int x = f_anchor(ts)
            bool below = verticalMode == "Below Bar" or verticalMode == "ATR Below"
            float y = below ? low : high
            if verticalMode == "ATR Above"
                y := high + atr * atrOffset
            else if verticalMode == "ATR Below"
                y := low - atr * atrOffset
            else if verticalMode == "Absolute Price"
                y := absolutePrice
            color bg = f_bg(t)
            label id = label.new(x=x, y=y, xloc=xloc.bar_time, yloc=yloc.price, text=f_labelText(t, ts), style=f_style(labelDirection), color=color.new(bg, f_transp(t)), textcolor=f_textColor(t), size=f_size(labelSizeIn), textalign=f_align(textAlignIn))
            f_storeLabel(id)
            if showEventLine
                line ln = line.new(x1=ts, y1=low, x2=ts, y2=high, xloc=xloc.bar_time, extend=extend.both, color=color.new(bg, lineTransparency), style=f_lineStyle(lineStyleIn), width=lineWidth)
                f_storeLine(ln)
            anyEventNow := true

alertcondition(anyEventNow, "Scheduled Economic Release", "A scheduled 2026 economic release is occurring now.")
````
