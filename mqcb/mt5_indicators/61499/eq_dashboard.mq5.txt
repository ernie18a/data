//+---------------------------------------------------------------------------+
//|                                                          EQ Dashboard.mq5 |
//|                                            Copyright 2025, by Ivan Butko  |
//|                                https://www.mql5.com/ru/users/capitalplus  |
//+---------------------------------------------------------------------------+
//|            Historical equity of virtual positions with dynamic            |
//|                           interactive dashboard                           |
//|---------------------------------------------------------------------------|
//| PURPOSE:                                                                  |
//| - Calculate virtual equity of a portfolio                                 |
//| - Provide a dynamic, interactive dashboard for managing symbols,          |
//|   volumes, and directions                                                 |
//| - Facilitate identification of volatile-flat structures                   |
//| - Analyze spread trading efficiency                                       |
//| - Help determine entry/exit points for equity trading                     |
//|                                                                           |
//| OPERATION PRINCIPLE:                                                      |
//| - Users activate/deactivate symbols via dashboard buttons                 |
//| - Adjust volumes and trade directions interactively                       |
//| - Equity line dynamically recalculates based on current selections        |
//| - Cumulative profit/loss from all active positions is displayed           |
//| - Dashboard provides quick control of settings and visualization          |
//|                                                                           |
//| HOW TO USE:                                                               |
//| 1. Use the dashboard to select symbols and set buy/sell directions        |
//| 2. Adjust lot sizes using volume controls in the dashboard                |
//| 3. Configure history depth and initial balance in inputs                  |
//| 4. Monitor historical virtual equity line and adjust parameters as needed |
//+---------------------------------------------------------------------------+

#property copyright "Copyright © 2025, iboot@yandex.ru, https://t.me/bootelega"
#property link      "https://www.mql5.com/ru/users/capitalplus/seller"
#property version   "1.1"
#property strict

//--- Indicator description ------------------------------------------
#property description "Historical virtual equity indicator with dynamic dashboard"
#property description "Purpose:"
#property description "- Model portfolio behavior with interactive symbol management"
#property description "- Visualize combined instrument movements with adjustable settings"
#property description "Applications:"
#property description "- Identify volatility-flat patterns for spread and equity trading"
#property description "- Evaluate spread and equity trading strategies using visual feedback"
#property description "- Dynamic control of portfolio components via on-chart dashboard"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots    1
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDodgerBlue
#property indicator_width1   1
#property indicator_label1   "Virtual Equity"

//+------------------------------------------------------------------+
//| === Calculation Settings ===                                     |
//+------------------------------------------------------------------+
input group " -------- Calculation Settings -------- "
input int    Bars_to_calculate = 1000;     // Number of bars to calculate
input double Initial_balance   = 0;        // Initial virtual balance

//+------------------------------------------------------------------+
//| === Dashboard Positioning Parameters ===                         |
//+------------------------------------------------------------------+
input group " -------- Dashboard Positioning Parameters -------- "
input int Dashboard_Base_X = 50;           // Base X coordinate
input int Dashboard_Base_Y = 50;           // Base Y coordinate

// === Symbols ===
input group " -------- Symbols -------- "
input color  Sym_ActiveClr        = C'102,187,106';  // Active button color (bright grass green)
input color  Sym_InactiveClr      = C'240,243,248';  // Inactive button background (very light)
input color  Sym_TextClr          = C'36,42,56';     // Button text color
input int    SymbolBut_Height     = 25;              // Button height
input int    FntSize_SymbolButs   = 10;              // Button font size

// === Buy/Sell Buttons ===
input group " -------- Buy/Sell Buttons -------- "
input color  BuySell_BuyClr       = C'100,160,210';  // Buy button background color (light steel blue)
input color  BuySell_SellClr      = C'255,138,128';  // Sell button background color (light scarlet)
input color  BuySell_TextClr      = C'36,42,56';     // Buy/Sell button text color
input int    BuySellBut_Width     = 40;              // Button width
input int    BuySellBut_Height    = 25;              // Button height
input string BuySell_BuyText      = "BUY";           // Buy button text
input string BuySell_SellText     = "SELL";          // Sell button text
input int    FntSize_BuySellButs  = 10;              // Button font size

// === Volume Management Buttons ===
input group " -------- Volume Management Buttons -------- "
input color  VolMng_ButClr        = C'240,243,248';  // Background color (light gray-blue)
input color  VolMng_TextClr       = C'36,42,56';     // Text color
input int    VolMng_ButWidth      = 20;              // Button width
input int    VolMng_ButHeight     = 25;              // Button height
input string VolMng_LotMns01Text  = "«";             // Lot decrease by 0.1 button text
input string VolMng_LotMns001Text = "‹";             // Lot decrease by 0.01 button text
input string VolMng_LotPls001Text = "›";             // Lot increase by 0.01 button text
input string VolMng_LotPls01Text  = "»";             // Lot increase by 0.1 button text
input int    FntSize_VolButs      = 15;              // Font size

// === Input Field ===
input group " -------- Input Field -------- "
input int    LotInput_Width       = 50;              // Input field width
input int    LotInput_Height      = 25;              // Input field height
input color  InputField_BgdClr    = C'245,245,245';  // Background color
input color  InputField_TextClr   = C'36,42,56';     // Text color
input int    FntSize_InputField   = 11;              // Font size

// === Columns Background ===
input group " -------- Columns Background -------- "
input color  Bgd_Clr             = C'220,225,230';  // Background color (soft bluish)
input color  Bgd_BrdClr          = C'180,185,195';  // Border color (slightly darker)
input int    Bgd_Width           = 280;             // Width
input int    Bgd_Height          = 80;              // Height

// === Dashboard Header ===
input group " -------- Dashboard Header -------- "
input color  Hdr_BgdClr           = C'245,247,250';  // Background color
input color  Hdr_BrdClr           = C'220,224,230';  // Border color
input string Hdr_Title            = "EQ";            // Title text
input color  Hdr_TitleClr         = C'40,44,52';     // Title color
input int    Hdr_Width            = 280;             // Width
input int    Hdr_Height           = 25;              // Height
input int    FntSize_HdrAndTopButs = 10;             // Font size for header and top buttons

// === Reset Settings Button ===
input group " -------- Reset Settings Button -------- "
input color  RstSet_ButClr        = C'255,138,128';  // Background color (light red)
input color  RstSet_TextClr       = C'255,255,255';  // Text color (white)
input int    RstAllBut_Width      = 20;              // Width
input int    RstAllBut_Height     = 20;              // Height
input string RstAllBut_Text       = "R";             // Text

// === Theme Switch Button ===
input group " -------- Theme Switch Button -------- "
input color  ThemeSwitch_ButClr   = C'144,176,160';  // Background color (light moss green)
input color  ThemeSwitch_TextClr  = C'255,255,255';  // Text color (white)
input int    ThemeSwitchBut_Width = 20;              // Width
input int    ThemeSwitchBut_Height= 20;              // Height
input string ThemeSwitchBut_Text  = "☼";             // Text

// === Dashboard Scaling Buttons ===
input group " -------- Dashboard Scaling Buttons -------- "
input color  SclPlsBut_Clr        = C'170,210,240';  // Background color (light blue)
input color  SclPlsBut_TextClr    = C'36,42,56';     // Text color
input int    SclPlsBut_Width      = 20;              // Width
input int    SclPlsBut_Height     = 20;              // Height
input string SclPlsBut_Text       = "+";             // Text

input color  SclMnsBut_Clr        = C'170,210,240';  // Background color (light blue)
input color  SclMnsBut_TextClr    = C'36,42,56';     // Text color
input int    SclMnsBut_Width      = 20;              // Width
input int    SclMnsBut_Height     = 20;              // Height
input string SclMnsBut_Text       = "–";             // Text

input int    FntSize_SclButs      = 10;              // Font size

// === Column Management Buttons ===
input group " -------- Column Management Buttons -------- "
input color  ClnMng_ButClr        = C'180,190,210';  // Background color (light gray-purple)
input color  ClnMng_TextClr       = C'36,42,56';     // Text color
input int    DcrClnsBut_Width     = 20;              // Decrease columns button width
input int    DcrClnsBut_Height    = 20;              // Decrease columns button height
input string DcrClnsBut_Text      = "<";             // Decrease columns button text
input int    IcrClnsBut_Width     = 20;              // Increase columns button width
input int    IcrClnsBut_Height    = 20;              // Increase columns button height
input string IcrClnsBut_Text      = ">";             // Increase columns button text

// === Collapse/Expand Button ===
input group " -------- Collapse/Expand Button -------- "
input color  Hid_ButClr           = C'255,236,140';  // Background color (light yellow)
input color  Hid_TextClr          = C'36,42,56';     // Text color
input int    HidBut_Width         = 20;              // Width
input int    HidBut_Height        = 20;              // Height
input string Hid_CollapseText     = "—";             // Text when collapsed
input string Hid_ExpandText       = "+";             // Text when expanded

// === Close (Delete Indicator) Button ===
input group " -------- Close (Delete Indicator) Button -------- "
input color  CloseDelete_ButClr   = C'255,138,128';  // Background color (light red)
input color  CloseDelete_TextClr  = C'255,255,255';  // Text color (white)
input int    CloseDeleteBut_Width = 20;              // Width
input int    CloseDeleteBut_Height= 20;              // Height
input string CloseDeleteBut_Text  = "X";             // Text



//+------------------------------------------------------------------+
//| Structure to simplify UI state management                         |
//+------------------------------------------------------------------+
struct SymbolState
{
    bool   active;           // Symbol active state
    bool   is_sell;          // Sell or buy direction
    double lot_value;        // Lot size
    string symbol_name;      // Symbol name

    SymbolState() : active(false), is_sell(false), lot_value(0.1) {}
};

//+------------------------------------------------------------------+
//| Global positioning constants                                     |
//+------------------------------------------------------------------+
const int Cln_Width  = 300;  // Width of a column (used for X offset positioning)
const int Row_Height = 30;   // Height of a row (used for Y offset positioning)

//+------------------------------------------------------------------+
//| Theme switching                                                  |
//+------------------------------------------------------------------+
enum ThemeType { THEME_DARK = 0, THEME_LIGHT = 1, THEME_CUSTOM = 2 };
ThemeType g_theme = THEME_CUSTOM;  // Default theme is custom

//+------------------------------------------------------------------+
//| UI variables                                                     |
//+------------------------------------------------------------------+
const string PFX                = "Dashboard_";  // Prefix for UI object names
int          g_clnCnt           = 1;            // Number of columns currently displayed
bool         g_panelExpanded    = true;          // Dashboard panel expansion flag
bool         g_manualDeletion   = false;         // Manual indicator deletion flag
string       g_indName;                          // Indicator name string
SymbolState  g_symSts[];                        // Array holding state for each symbol
int          g_ttlSym;                          // Total number of symbols available
double       g_scl              = 1.0;           // Current UI scaling factor
string       g_hdrTitle         = "EQ";          // Header title string
string       g_loadHistoryLabel = "EQ_LoadHistoryLabel"; // Label for loading history

// Auto-calculated symbol button width
int          g_symButW          = 100;

// Calculation buffers and flags
double       E_buf[];                           // Buffer for equity values
double       g_initlPrs[];                      // Array of initial prices
int          g_dir[];                           // Trade direction: 1=buy, -1=sell
bool         g_startFlag        = true;          // First run flag
bool         g_startChartFlag   = true;          // Chart redraw trigger flag


//+------------------------------------------------------------------+
//| Initialization function: sets up indicator and UI               |
//+------------------------------------------------------------------+
int OnInit()
{
    // Get the name of this indicator program
    g_indName = MQL5InfoString(MQL5_PROGRAM_NAME);

    // Get total number of symbols available in Market Watch
    g_ttlSym = SymbolsTotal(true);

    // Resize symbol state array to total symbols count
    ArrayResize(g_symSts, g_ttlSym);

    // Initialize symbol names in the symbol state array
    InitializeSymbolNames();

    // Calculate button width for symbols dynamically based on symbol name lengths
    CalcSymbolButWidth();

    // Load saved states from previous sessions (active symbols, lots, directions)
    LoadStates();

    // Apply colors according to selected theme
    ApplyThemeColors();

    // Create the user interface elements (buttons, labels, etc)
    CreateUI();

    // Set timer event to trigger every 100 milliseconds for UI updates
    EventSetMillisecondTimer(100);

    // Initialize calculation buffers to hold initial prices and directions
    ArrayResize(g_initlPrs, g_ttlSym);
    ArrayResize(g_dir, g_ttlSym);

    // Bind the indicator buffer to E_buf for plotting virtual equity line
    SetIndexBuffer(0, E_buf, INDICATOR_DATA);

    // Set buffer to be indexed as series (time series with index 0 as latest bar)
    ArraySetAsSeries(E_buf, true);

    // Set number of decimal digits for indicator values
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    return(INIT_SUCCEEDED);  // Initialization successful
}

//+------------------------------------------------------------------+
//| Deinitialization function: cleans up on indicator removal       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Stop the timer event
    EventKillTimer();

    // If indicator was not deleted manually, save states and remove UI objects
    if (!g_manualDeletion)
    {
        SaveStates();       // Save current symbol states to persistent storage
        DeleteAllObjects(); // Remove all created UI objects from chart
    }

    // Remove loading history label if it exists
    if (ObjectFind(0, g_loadHistoryLabel) != -1)
        ObjectDelete(0, g_loadHistoryLabel);

    // Redraw chart to update display after cleanup
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Calculation entry point: called on each new tick or bar update   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
    // Perform main calculation and UI update
    Main();

    // Return total bars processed to MetaTrader engine
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer event handler: called every 100 ms to update UI           |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Checks for new Market Watch symbols and adds them to the dashboard without resetting settings.
    SyncAndRebuildDashboard();
    // Run main update logic on timer event
    Main();
}

//+------------------------------------------------------------------+
//| Main calculation and update function                             |
//+------------------------------------------------------------------+
void Main()
{
    // Update the header title text on the dashboard
    UpdateHdrTitle();

    // Arrays to hold active symbol info: names, directions, and lot sizes
    string actSym[];
    int actDir[];
    double actLot[];

    // Retrieve currently active symbols and their parameters
    GetActiveSymbols(actSym, actDir, actLot);

    // Count how many symbols are active
    int actCnt = ArraySize(actSym);

    // If no active symbols, clear equity buffer and exit
    if(actCnt == 0)
    {
        ArrayInitialize(E_buf, 0.0);  // Reset equity buffer to zero
        return;
    }

    int start = 0; // Starting bar index for calculation

    // On first run, initialize buffers and read initial prices
    if(g_startFlag)
    {
        ArrayInitialize(E_buf, EMPTY_VALUE);  // Mark equity buffer as empty initially

        // Resize arrays to active symbols count
        ArrayResize(g_initlPrs, actCnt);
        ArrayResize(g_dir, actCnt);

        // Loop through each active symbol
        for(int i = 0; i < actCnt; i++)
        {
            // Validate symbol availability and history
            if(!CheckSymbol(actSym[i]))
                return;  // Exit if symbol data is not ready

            // Store trade direction for symbol (1 for buy, -1 for sell)
            g_dir[i] = actDir[i];

            // Store initial opening price at Bars_to_calculate offset for symbol
            g_initlPrs[i] = iOpen(actSym[i], _Period, Bars_to_calculate);
        }

        // Start calculation from Bars_to_calculate bars ago
        start = Bars_to_calculate;

        // Clear the start flag after initialization
        g_startFlag = false;
    }
    else
    {
        // On subsequent runs, start from the latest bar (index 0)
        start = 0;

        // If chart redraw is pending, trigger it once
        if(g_startChartFlag)
        {
            ChartRedraw();
            g_startChartFlag = false;
        }
    }

    // Loop backwards through bars from start to 0 (latest bar)
    for(int i = start; i >= 0; i--)
    {
        double equity = Initial_balance;  // Reset equity to initial balance at each bar

        // Loop through all active symbols to calculate equity contribution
        for(int j = 0; j < actCnt; j++)
        {
            string symbol = actSym[j];  // Current symbol name

            // Get close price for symbol at bar i
            double curClose = iClose(symbol, _Period, i);

            // Skip if close price is zero (invalid data)
            if(curClose == 0)
                continue;

            // Calculate price change in points from initial price
            double priceChange = (curClose - g_initlPrs[j]) / SymbolInfoDouble(symbol, SYMBOL_POINT);

            // Calculate point value for symbol (monetary value per point)
            double pointValue = CalculatePointValue(symbol);

            // Update equity by adding price change * direction * lot size * point value
            equity += priceChange * g_dir[j] * actLot[j] * pointValue;
        }

        // Store calculated equity value in buffer for plotting
        E_buf[i] = equity;

        // If first equity value is empty, redraw chart to update display
        if(E_buf[0] == EMPTY_VALUE)
            ChartRedraw();
    }
}

//+------------------------------------------------------------------+
//| Symbol validation: checks if symbol is available and has history|
//+------------------------------------------------------------------+
bool CheckSymbol(string symbol)
{
    // Try to select symbol in Market Watch, returns false if symbol not found
    if(!SymbolSelect(symbol, true))
    {
        Print(symbol + " - error: symbol not found in Market Watch!");
        return false;
    }

    // Check if close price at Bars_to_calculate is valid (non-zero)
    if(iClose(symbol, PERIOD_CURRENT, Bars_to_calculate) <= 0)
    {
        // Show loading message for symbol history
        Comment("LOADING HISTORY: " + symbol);
        return false;
    }

    // Symbol is valid and has sufficient history
    return true;
}

//+------------------------------------------------------------------+
//| Calculate point value for symbol: monetary value per symbol point|
//+------------------------------------------------------------------+
double CalculatePointValue(string symbol)
{
    // Get tick value in account currency for the symbol
    double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);

    // Get tick size (minimum price change) for the symbol
    double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

    // Get point size for the symbol (usually equal to tick size or fraction)
    double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

    // Calculate and return monetary value of one point move for the symbol
    return tickValue * (point / tickSize);
}





































//+--------------------------------------------------------------------+
//| ========================= DASHBOARD ============================== |
//+--------------------------------------------------------------------+

color Hdr_BgdClr_work, Hdr_BrdClr_work, Hdr_TitleClr_work;
color RstSet_ButClr_work, RstSet_TextClr_work;
color SclPlsBut_Clr_work, SclPlsBut_TextClr_work, SclMnsBut_Clr_work, SclMnsBut_TextClr_work;
color ClnMng_ButClr_work, ClnMng_TextClr_work;
color Hid_ButClr_work, Hid_TextClr_work;
color CloseDelete_ButClr_work, CloseDelete_TextClr_work;
color Sym_ActiveClr_work, Sym_InactiveClr_work, Sym_TextClr_work;
color BuySell_BuyClr_work, BuySell_SellClr_work, BuySell_TextClr_work;
color VolMng_ButClr_work, VolMng_TextClr_work;
color InputField_BgdClr_work, InputField_TextClr_work;
color Bgd_Clr_work, Bgd_BrdClr_work;
color ThemeSwitch_ButClr_work, ThemeSwitch_TextClr_work;

int Sht_HdrBg_X = 0;
int Sht_HdrBg_Y = 0;

int Sht_HdrTitle_X = 5;
int Sht_HdrTitle_Y = 5;

int Sht_RstAllBut_X = 117;
int Sht_RstAllBut_Y = 2;

int Sht_ThemeSwitchBut_X = 137;
int Sht_ThemeSwitchBut_Y = 2;

int Sht_SclPlsBut_X = 157;
int Sht_SclPlsBut_Y = 2;

int Sht_SclMnsBut_X = 177;
int Sht_SclMnsBut_Y = 2;

int Sht_DcrClnsBut_X = 197;
int Sht_DcrClnsBut_Y = 2;

int Sht_IcrClnsBut_X = 217;
int Sht_IcrClnsBut_Y = 2;

int Sht_HidBut_X = 237;
int Sht_HidBut_Y = 2;

int Sht_DltIndBut_X = 257;
int Sht_DltIndBut_Y = 2;

int Sht_ClnBgd_X = 0;
int Sht_ClnBgd_Y = 0;

int Sht_SymbolBut_X = 5;
int Sht_SymbolBut_Y = -5;

int Sht_BuySellBut_X = 80;
int Sht_BuySellBut_Y = 0;

int Sht_LotMns01But_X = 130;
int Sht_LotMns01But_Y = 0;

int Sht_LotMns001But_X = 150;
int Sht_LotMns001But_Y = 0;

int Sht_LotInput_X = 175;
int Sht_LotInput_Y = 0;

int Sht_LotPls001But_X = 230;
int Sht_LotPls001But_Y = 0;

int Sht_LotPls01But_X = 250;
int Sht_LotPls01But_Y = 0;

void CalcSymbolButWidth()
{
    int maxLen = 0;
    for(int i=0; i<g_ttlSym; i++)
    {
        int len = StringLen(g_symSts[i].symbol_name);
        if(len > maxLen)
            maxLen = len;
    }
    g_symButW = 8 * maxLen + 24;
    if(g_symButW < 60) g_symButW = 60;
    if(g_symButW > 200) g_symButW = 200; 
}


void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if(id != CHARTEVENT_OBJECT_CLICK && id != CHARTEVENT_OBJECT_ENDEDIT) return;

    bool needRecalc = false;

    if(id == CHARTEVENT_OBJECT_CLICK)
    {
        SetButState(sparam, true);
        needRecalc = ProcessClick(sparam);
        SetButState(sparam, false);
    }
    else if(id == CHARTEVENT_OBJECT_ENDEDIT)
    {
        needRecalc = ProcessInputEdit(sparam);
    }

    if(needRecalc)
    {
        g_startFlag = true;
        Main();
        ChartRedraw();
    }
}

bool ProcessClick(string objName)
{
    if(objName == PFX + "RstAllBut")      {        RstAllStates();        return true;    }
    if(objName == PFX + "ThemeSwitchBut") {        SwitchTheme();          return false;      }
    if(objName == PFX + "SclPlsBut")      {        g_scl += 0.1;        if(g_scl > 3.0) g_scl = 3.0;        RecreateUI();        return false;    }
    if(objName == PFX + "SclMnsBut")      {        g_scl -= 0.1;        if(g_scl < 0.5) g_scl = 0.5;        RecreateUI();        return false;    }
    if(objName == PFX + "IcrClnsBut")     {        ChangeClnCount(g_clnCnt + 1);        return false;    }
    if(objName == PFX + "DcrClnsBut")     {        ChangeClnCount(MathMax(1, g_clnCnt - 1));        return false;    }    
    if(objName == PFX + "HidBut")         {        TogglePanel();        return false;    }
    if(objName == PFX + "DltIndBut")      {        DltInd();        return false;    }

    return ProcessSymbolClick(objName);
}

void RecreateUI()
{
    DeleteAllObjects(); 
    CreateUI();    
    ChartRedraw();      
}

bool ProcessSymbolClick(string objName)
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        string symName = g_symSts[i].symbol_name;

        if(objName == PFX + "Symbol_" + symName)
        {
            g_symSts[i].active = !g_symSts[i].active;
            UpdateSymbolBut(i);
            SaveStates();
            return true;
        }

        if(objName == PFX + "BuySell_" + symName)
        {
            g_symSts[i].is_sell = !g_symSts[i].is_sell;
            UpdateBuySellBut(i);
            SaveStates();
            if (g_symSts[i].active) return true;
            else return false;
        }

        string lotButs[] = {"Lot1_", "Lot2_", "Lot3_", "Lot4_"};
        double lotChanges[] = {-0.1, -0.01, 0.01, 0.1};

        for(int j = 0; j < 4; j++)
        {
            if(objName == PFX + lotButs[j] + symName)
            {
                g_symSts[i].lot_value = MathMax(0, g_symSts[i].lot_value + lotChanges[j]);
                UpdateLotInput(i);
                SaveStates();
                if (g_symSts[i].active) return true;
                  else return false;
            }
        }
    }
    return false;
}

bool ProcessInputEdit(string objName)
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        if(objName == PFX + "LotInput_" + g_symSts[i].symbol_name)
        {
            g_symSts[i].lot_value = StringToDouble(ObjectGetString(0, objName, OBJPROP_TEXT));
            SaveStates();
            return true;
        }
    }
    return false;
}

void CreateUI()
{
    CreateHdrPanel();
    CreateTopButs();
    if(g_panelExpanded)
    {
        CreateClnBgds();
        CreateSymbolButs();
        ApplyStates();
    }
}

void CreateHdrPanel()
{
    CreateBgd(PFX + "HdrBg", Dashboard_Base_X + Sht_HdrBg_X, Dashboard_Base_Y + Sht_HdrBg_Y, Hdr_Width, Hdr_Height, Hdr_BgdClr_work, Hdr_BrdClr_work);

    string name = PFX + "HdrTitle";
    int relX = Sht_HdrTitle_X;
    int relY = Sht_HdrTitle_Y;
    int sclX = Dashboard_Base_X + int(relX * g_scl);
    int sclY = Dashboard_Base_Y + int(relY * g_scl);
    int sclFntSize = MathMax(8, int(FntSize_HdrAndTopButs * g_scl));

    if(ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, sclX);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, sclY);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sclFntSize);
        ObjectSetInteger(0, name, OBJPROP_COLOR, Hdr_TitleClr_work);
        ObjectSetInteger(0, name, OBJPROP_CORNER, 0);
        ObjectSetString(0, name, OBJPROP_TEXT, g_hdrTitle);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
    }
}

void CreateTopButs()
{
    struct TopBtn { string name, text; int x, y, w, h; color bg, fg; int fontSize; };
    TopBtn buttons[] = {
        {"DcrClnsBut", DcrClnsBut_Text,
            Dashboard_Base_X + Sht_DcrClnsBut_X,
            Dashboard_Base_Y + Sht_DcrClnsBut_Y,
            DcrClnsBut_Width, DcrClnsBut_Height,
            ClnMng_ButClr_work, ClnMng_TextClr_work,
            FntSize_HdrAndTopButs},
            
        {"ThemeSwitchBut", ThemeSwitchBut_Text, 
            Dashboard_Base_X + Sht_ThemeSwitchBut_X, 
            Dashboard_Base_Y + Sht_ThemeSwitchBut_Y, 
            ThemeSwitchBut_Width, ThemeSwitchBut_Height, 
            ThemeSwitch_ButClr_work, ThemeSwitch_TextClr_work, 
            FntSize_HdrAndTopButs},

        {"IcrClnsBut", IcrClnsBut_Text,
            Dashboard_Base_X + Sht_IcrClnsBut_X,
            Dashboard_Base_Y + Sht_IcrClnsBut_Y,
            IcrClnsBut_Width, IcrClnsBut_Height,
            ClnMng_ButClr_work, ClnMng_TextClr_work,
            FntSize_HdrAndTopButs},

        {"RstAllBut", RstAllBut_Text,
            Dashboard_Base_X + Sht_RstAllBut_X,
            Dashboard_Base_Y + Sht_RstAllBut_Y,
            RstAllBut_Width, RstAllBut_Height,
            RstSet_ButClr_work, RstSet_TextClr_work,
            FntSize_HdrAndTopButs},

        // Кнопка "+" масштабирования
        {"SclPlsBut", SclPlsBut_Text,
            Dashboard_Base_X + Sht_SclPlsBut_X,
            Dashboard_Base_Y + Sht_SclPlsBut_Y,
            SclPlsBut_Width, SclPlsBut_Height,
            SclPlsBut_Clr_work, SclPlsBut_TextClr_work,
            FntSize_SclButs},

        // Кнопка "–" масштабирования
        {"SclMnsBut", SclMnsBut_Text,
            Dashboard_Base_X + Sht_SclMnsBut_X,
            Dashboard_Base_Y + Sht_SclMnsBut_Y,
            SclMnsBut_Width, SclMnsBut_Height,
            SclMnsBut_Clr_work, SclMnsBut_TextClr_work,
            FntSize_SclButs},

        {"HidBut", g_panelExpanded ? Hid_CollapseText : Hid_ExpandText,
            Dashboard_Base_X + Sht_HidBut_X,
            Dashboard_Base_Y + Sht_HidBut_Y,
            HidBut_Width, HidBut_Height,
            Hid_ButClr_work, Hid_TextClr_work,
            FntSize_HdrAndTopButs},

        {"DltIndBut", CloseDeleteBut_Text,
            Dashboard_Base_X + Sht_DltIndBut_X,
            Dashboard_Base_Y + Sht_DltIndBut_Y,
            CloseDeleteBut_Width, CloseDeleteBut_Height,
            CloseDelete_ButClr_work, CloseDelete_TextClr_work,
            FntSize_HdrAndTopButs}
    };

    for(int i = 0; i < ArraySize(buttons); i++)
    {
        CreateBut(PFX + buttons[i].name,
                     buttons[i].x, buttons[i].y,
                     buttons[i].w, buttons[i].h,
                     buttons[i].bg, buttons[i].fg,
                     buttons[i].text, buttons[i].fontSize);
    }
}

void CreateSymbolButs()
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        string symName = g_symSts[i].symbol_name;
        int col = i % g_clnCnt;
        int row = i / g_clnCnt;
        int xShift = col * Cln_Width;
        int yShift = row * Row_Height;

        int baseX = Dashboard_Base_X + xShift + Sht_SymbolBut_X;
        int baseY = Dashboard_Base_Y + Hdr_Height + 10 + yShift + Sht_SymbolBut_Y;

        color symbolBg = g_symSts[i].active ? Sym_ActiveClr : Sym_InactiveClr;
        int butW = g_symButW;
        int butH = SymbolBut_Height;

        CreateBut(PFX + "Symbol_" + symName, baseX, baseY, butW, butH, symbolBg, Sym_TextClr_work, symName, FntSize_SymbolButs);

        // Кнопка Buy/Sell
        color buySellBg = g_symSts[i].is_sell ? BuySell_SellClr_work : BuySell_BuyClr_work;
        string buySellText = g_symSts[i].is_sell ? BuySell_SellText : BuySell_BuyText;
        CreateBut(PFX + "BuySell_" + symName,
                     baseX + Sht_BuySellBut_X, baseY + Sht_BuySellBut_Y,
                     BuySellBut_Width, BuySellBut_Height,
                     buySellBg, BuySell_TextClr_work, buySellText, FntSize_BuySellButs);

        CreateBut(PFX + "Lot1_" + symName, baseX + Sht_LotMns01But_X, baseY + Sht_LotMns01But_Y,
                     VolMng_ButWidth, VolMng_ButHeight, VolMng_ButClr_work, VolMng_TextClr_work, VolMng_LotMns01Text, FntSize_VolButs);
        CreateBut(PFX + "Lot2_" + symName, baseX + Sht_LotMns001But_X, baseY + Sht_LotMns001But_Y,
                     VolMng_ButWidth, VolMng_ButHeight, VolMng_ButClr_work, VolMng_TextClr_work, VolMng_LotMns001Text, FntSize_VolButs);

        CreateInputField(PFX + "LotInput_" + symName, baseX + Sht_LotInput_X, baseY + Sht_LotInput_Y,
                         LotInput_Width, LotInput_Height, InputField_BgdClr_work, InputField_TextClr_work,
                         DoubleToString(g_symSts[i].lot_value, 2));

        CreateBut(PFX + "Lot3_" + symName, baseX + Sht_LotPls001But_X, baseY + Sht_LotPls001But_Y,
                     VolMng_ButWidth, VolMng_ButHeight, VolMng_ButClr_work, VolMng_TextClr_work, VolMng_LotPls001Text, FntSize_VolButs);
        CreateBut(PFX + "Lot4_" + symName, baseX + Sht_LotPls01But_X, baseY + Sht_LotPls01But_Y,
                     VolMng_ButWidth, VolMng_ButHeight, VolMng_ButClr_work, VolMng_TextClr_work, VolMng_LotPls01Text, FntSize_VolButs);
    }
}

void CreateBut(string name, int x, int y, int w, int h, color bg, color fg, string text, int baseFntSize = 10)
{
    int relX = x - Dashboard_Base_X;
    int relY = y - Dashboard_Base_Y;
    int sclX = Dashboard_Base_X + int(relX * g_scl);
    int sclY = Dashboard_Base_Y + int(relY * g_scl);
    int sclW = int(w * g_scl);
    int sclH = int(h * g_scl);
    int sclFntSize = MathMax(8, int(baseFntSize * g_scl));  // минимум 8 для читаемости

    if(ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0))
    {
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, sclX);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, sclY);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, sclW);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, sclH);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
        ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sclFntSize);
        ObjectSetInteger(0, name, OBJPROP_STATE, false);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
    }
}

void CreateInputField(string name, int x, int y, int w, int h, color bg, color fg, string text)
{
    int relX = x - Dashboard_Base_X;
    int relY = y - Dashboard_Base_Y;
    int sclX = Dashboard_Base_X + int(relX * g_scl);
    int sclY = Dashboard_Base_Y + int(relY * g_scl);
    int sclW = int(w * g_scl);
    int sclH = int(h * g_scl);
    int sclFntSize = MathMax(8, int(FntSize_InputField * g_scl));

    if(ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0))
    {
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, sclX);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, sclY);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, sclW);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, sclH);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
        ObjectSetInteger(0, name, OBJPROP_COLOR, fg);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sclFntSize);
        ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
    }
}

void CreateBgd(string name, int x, int y, int w, int h, color bgclr, color brdclr)
{
    int relX = x - Dashboard_Base_X;
    int relY = y - Dashboard_Base_Y;
    int sclX = Dashboard_Base_X + int(relX * g_scl);
    int sclY = Dashboard_Base_Y + int(relY * g_scl);
    int sclW = int(w * g_scl);
    int sclH = int(h * g_scl);

    if(ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, sclX);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, sclY);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, sclW);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, sclH);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgclr);
        ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, brdclr);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, name, OBJPROP_ZORDER, -1);
    }
}

void UpdateSymbolBut(int idx)
{
    string name = PFX + "Symbol_" + g_symSts[idx].symbol_name;
    color bg = g_symSts[idx].active ? Sym_ActiveClr_work : Sym_InactiveClr_work;
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
}

void UpdateBuySellBut(int idx)
{
    string name = PFX + "BuySell_" + g_symSts[idx].symbol_name;
    color bg = g_symSts[idx].is_sell ? BuySell_SellClr_work : BuySell_BuyClr_work;
    string text = g_symSts[idx].is_sell ? BuySell_SellText : BuySell_BuyText;
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
}

void UpdateLotInput(int idx)
{
    string name = PFX + "LotInput_" + g_symSts[idx].symbol_name;
    ObjectSetString(0, name, OBJPROP_TEXT, DoubleToString(g_symSts[idx].lot_value, 2));
}

void SetButState(string name, bool state)
{
    ObjectSetInteger(0, name, OBJPROP_STATE, state);
    ChartRedraw();
}


void InitializeSymbolNames()
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        g_symSts[i].symbol_name = SymbolName(i, true);
    }
}

void DltInd()
{
    g_manualDeletion = true;
    SaveStates();
    DeleteAllObjects();

    int window = ChartWindowFind(0, g_indName);
    if(window != -1)
        ChartIndicatorDelete(0, window, g_indName);
}

void RstAllStates()
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        g_symSts[i].active = false;
        g_symSts[i].is_sell = false;
        g_symSts[i].lot_value = 0.1;
    }
    ApplyStates();
    SaveStates();
}

void TogglePanel()
{
    g_panelExpanded = !g_panelExpanded;

    if(g_panelExpanded)
    {
        CreateClnBgds();
        CreateSymbolButs();
        ApplyStates();
    }
    else
    {
        DeleteSymbolObjects();
    }

    ObjectSetString(0, PFX + "HidBut", OBJPROP_TEXT,
                   g_panelExpanded ? Hid_CollapseText : Hid_ExpandText);
    SaveStates();
}

void ChangeClnCount(int newCount)
{
    g_clnCnt = newCount;
    DeleteSymbolObjects();
    CreateClnBgds();
    CreateSymbolButs();
    ApplyStates();
    SaveStates();
}

void CreateClnBgds()
{
    int total = g_ttlSym;
    int cln = g_clnCnt;

    int minRows = total / cln;
    int extra = total % cln;

    int gap = Cln_Width - Bgd_Width;

    for(int col = 0; col < cln; col++)
    {
        int rowsInCln = minRows + (col < extra ? 1 : 0);
        if(rowsInCln <= 0) continue;

        int x = Dashboard_Base_X + col * Cln_Width - gap * col + Sht_ClnBgd_X;
        int y = Dashboard_Base_Y + Hdr_Height + Sht_ClnBgd_Y;
        int w = Bgd_Width + gap * col;
        int h = rowsInCln * Row_Height + 5;

        CreateBgd(PFX + "ColBg_" + IntegerToString(col), x, y, w, h, Bgd_Clr_work, Bgd_BrdClr_work);
    }
}

void DeleteSymbolObjects()
{
    for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
    {
        string name = ObjectName(0, i);
        if(StringFind(name, PFX) == 0 &&
           StringFind(name, "HdrBg") == -1 &&
           StringFind(name, "HdrTitle") == -1 &&          
           StringFind(name, "RstAllBut") == -1 &&
           StringFind(name, "ThemeSwitchBut") == -1 &&
           StringFind(name, "SclPlsBut") == -1 &&
           StringFind(name, "SclMnsBut") == -1 &&
           StringFind(name, "HidBut") == -1 &&
           StringFind(name, "IcrClnsBut") == -1 &&
           StringFind(name, "DcrClnsBut") == -1 && 
           StringFind(name, "DltIndBut") == -1)
        {
            ObjectDelete(0, name);
        }
    }
}

void DeleteAllObjects()
{
    for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--)
    {
        string name = ObjectName(0, i);
        if(StringFind(name, PFX) == 0)
            ObjectDelete(0, name);
    }
}

void ApplyStates()
{
    for(int i = 0; i < g_ttlSym; i++)
    {
        UpdateSymbolBut(i);
        UpdateBuySellBut(i);
        UpdateLotInput(i);
    }
}

void SaveStates()
{
    GlobalVariableSet(PFX + "ClnCount", g_clnCnt);
    GlobalVariableSet(PFX + "PanelExpanded", g_panelExpanded);

    for(int i = 0; i < g_ttlSym; i++)
    {
        string base = PFX + IntegerToString(i);
        GlobalVariableSet(base + "_Active", g_symSts[i].active);
        GlobalVariableSet(base + "_Sell", g_symSts[i].is_sell);
        GlobalVariableSet(base + "_Lot", g_symSts[i].lot_value);
    }
}

void LoadStates()
{
    if(GlobalVariableCheck(PFX + "ClnCount"))
        g_clnCnt = (int)GlobalVariableGet(PFX + "ClnCount");

    if(GlobalVariableCheck(PFX + "PanelExpanded"))
        g_panelExpanded = (bool)GlobalVariableGet(PFX + "PanelExpanded");

    for(int i = 0; i < g_ttlSym; i++)
    {
        string base = PFX + IntegerToString(i);

        if(GlobalVariableCheck(base + "_Active"))
            g_symSts[i].active = (bool)GlobalVariableGet(base + "_Active");

        if(GlobalVariableCheck(base + "_Sell"))
            g_symSts[i].is_sell = (bool)GlobalVariableGet(base + "_Sell");

        if(GlobalVariableCheck(base + "_Lot"))
            g_symSts[i].lot_value = GlobalVariableGet(base + "_Lot");
    }
}

void GetActiveSymbols(string& sym[], int& directions[], double& lots[])
{
    int cnt = 0;
    for(int i = 0; i < g_ttlSym; i++)
    {
        if(g_symSts[i].active)
            cnt++;
    }

    ArrayResize(sym, cnt);
    ArrayResize(directions, cnt);
    ArrayResize(lots, cnt);

    int idx = 0;
    for(int i = 0; i < g_ttlSym; i++)
    {
        if(g_symSts[i].active)
        {
            sym[idx] = g_symSts[i].symbol_name;
            directions[idx] = g_symSts[i].is_sell ? -1 : 1;
            lots[idx] = g_symSts[i].lot_value;
            idx++;
        }
    }
}

void UpdateHdrTitle()
{
    bool hasActivePair = false;
    for(int i = 0; i < g_ttlSym; i++)
    {
        if(g_symSts[i].active)
        {
            hasActivePair = true;
            break;
        }
    }

    bool isBufferEmpty = true;
    int bufSize = ArraySize(E_buf);
    if(bufSize > 0)
    {
        if(E_buf[0] != 0 && E_buf[0] != EMPTY_VALUE)
            isBufferEmpty = false;
        else Comment("");
    }

    string newTitle = "EQ";
    bool needShowLabel = false;

    if(hasActivePair && isBufferEmpty)
    {
        newTitle = "EQ (Loading...)";
        needShowLabel = true;
    }

    if(newTitle != g_hdrTitle)
    {
        g_hdrTitle = newTitle;
        string name = PFX + "HdrTitle";
        if(ObjectFind(0, name) != -1)
        {
            ObjectSetString(0, name, OBJPROP_TEXT, g_hdrTitle);
            ChartRedraw();
        }
    }

    ShowLoadHistoryLabel(needShowLabel);
}

void ShowLoadHistoryLabel(bool show)
{
    if(!show)
    {
        if(ObjectFind(0, g_loadHistoryLabel) != -1)
            {ObjectDelete(0, g_loadHistoryLabel); ChartRedraw();}
        return;
    }

    int wnd = ChartWindowFind(0, g_indName);
    if(wnd == -1) wnd = 1;

    long width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, wnd);
    long height = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, wnd);

    long x = width / 2;
    long y = height / 2;

    if(ObjectFind(0, g_loadHistoryLabel) == -1)
    {
        ObjectCreate(0, g_loadHistoryLabel, OBJ_LABEL, wnd, 0, 0);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_CORNER, 0);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_FONTSIZE, 24);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_COLOR, clrOrange);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_HIDDEN, false);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_BACK, false);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, g_loadHistoryLabel, OBJPROP_TEXT, "Loading history...");
    }
    else
    {
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, g_loadHistoryLabel, OBJPROP_YDISTANCE, y);
    }
}

void SyncAndRebuildDashboard()
{
    int marketCount = SymbolsTotal(true);  
    if(marketCount != g_ttlSym)
    {
        RebuildDashboard(marketCount);
        return;
    }

    for(int i = 0; i < marketCount; i++)
    {
        string marketSym = SymbolName(i, true);
        if(i >= g_ttlSym || g_symSts[i].symbol_name != marketSym)
        {
            RebuildDashboard(marketCount);
            return;
        }
    }
}

void RebuildDashboard(int marketCount)
{
    g_ttlSym = marketCount;
    ArrayResize(g_symSts, g_ttlSym);
    for(int i = 0; i < g_ttlSym; i++)
    {
        g_symSts[i].symbol_name = SymbolName(i, true);
        g_symSts[i].active = false;
        g_symSts[i].is_sell = false;
        g_symSts[i].lot_value = 0.1;
    }

    CalcSymbolButWidth();

    DeleteAllObjects();
    CreateUI();
    ApplyStates();

    SaveStates();
    ChartRedraw();
}



void SwitchTheme()
{
    g_theme = (ThemeType)((g_theme + 1) % 3);
    ApplyThemeColors();
    RecreateUI();
}
void ApplyThemeColors()
{
    if(g_theme == THEME_DARK)
    {
        Hdr_BgdClr_work           = C'38,43,51';
        Hdr_BrdClr_work           = C'60,65,75';
        Hdr_TitleClr_work         = C'220,230,240';

        RstSet_ButClr_work        = C'48,54,63';
        RstSet_TextClr_work       = C'200,90,100';

        SclPlsBut_Clr_work        = C'48,54,63';
        SclPlsBut_TextClr_work    = C'100,140,180';

        SclMnsBut_Clr_work        = C'48,54,63';
        SclMnsBut_TextClr_work    = C'100,140,180';

        ClnMng_ButClr_work        = C'48,54,63';
        ClnMng_TextClr_work       = C'120,90,160';

        Hid_ButClr_work           = C'48,54,63';
        Hid_TextClr_work          = C'200,180,60';

        CloseDelete_ButClr_work   = C'48,54,63';
        CloseDelete_TextClr_work  = C'255,99,132';

        Sym_ActiveClr_work        = C'0,184,148';
        Sym_InactiveClr_work      = C'38,43,51';
        Sym_TextClr_work          = C'220,230,240';

        BuySell_BuyClr_work       = C'9,132,227';
        BuySell_SellClr_work      = C'255,107,107';
        BuySell_TextClr_work      = C'255,255,255';

        VolMng_ButClr_work        = C'48,54,63';
        VolMng_TextClr_work       = C'220,230,240';

        InputField_BgdClr_work    = C'60,65,75';
        InputField_TextClr_work   = C'220,230,240';

        Bgd_Clr_work             = C'44,49,60';
        Bgd_BrdClr_work          = C'60,65,75';

        ThemeSwitch_ButClr_work   = C'48,54,63';
        ThemeSwitch_TextClr_work  = C'0,184,148';
    }
    else if(g_theme == THEME_LIGHT)
    {
        Hdr_BgdClr_work           = C'200,200,200';
        Hdr_BrdClr_work           = C'180,180,180';
        Hdr_TitleClr_work         = C'60,60,60';

        RstSet_ButClr_work        = C'200,90,100';
        RstSet_TextClr_work       = C'255,255,255';

        SclPlsBut_Clr_work        = C'100,140,180';
        SclPlsBut_TextClr_work    = C'255,255,255';

        SclMnsBut_Clr_work        = C'100,140,180';
        SclMnsBut_TextClr_work    = C'255,255,255';

        ClnMng_ButClr_work        = C'120,90,160';
        ClnMng_TextClr_work       = C'255,255,255';

        Hid_ButClr_work           = C'200,180,60';
        Hid_TextClr_work          = C'50,50,50';

        CloseDelete_ButClr_work   = C'180,60,60';
        CloseDelete_TextClr_work  = C'255,255,255';

        Sym_ActiveClr_work        = C'0,150,130';
        Sym_InactiveClr_work      = C'170,175,180';
        Sym_TextClr_work          = C'50,50,50';

        BuySell_BuyClr_work       = C'30,110,170';
        BuySell_SellClr_work      = C'180,40,45';
        BuySell_TextClr_work      = C'255,255,255';

        VolMng_ButClr_work        = C'170,175,180';
        VolMng_TextClr_work       = C'60,60,60';

        InputField_BgdClr_work    = C'220,225,230';
        InputField_TextClr_work   = C'50,50,50';

        Bgd_Clr_work             = C'210,215,220';
        Bgd_BrdClr_work          = C'160,165,170';

        ThemeSwitch_ButClr_work   = C'70,110,90';
        ThemeSwitch_TextClr_work  = C'255,255,255';
    }
    else
    {
        Hdr_BgdClr_work           = Hdr_BgdClr;
        Hdr_BrdClr_work           = Hdr_BrdClr;
        Hdr_TitleClr_work         = Hdr_TitleClr;

        RstSet_ButClr_work        = RstSet_ButClr;
        RstSet_TextClr_work       = RstSet_TextClr;

        SclPlsBut_Clr_work        = SclPlsBut_Clr;
        SclPlsBut_TextClr_work    = SclPlsBut_TextClr;

        SclMnsBut_Clr_work        = SclMnsBut_Clr;
        SclMnsBut_TextClr_work    = SclMnsBut_TextClr;

        ClnMng_ButClr_work        = ClnMng_ButClr;
        ClnMng_TextClr_work       = ClnMng_TextClr;

        Hid_ButClr_work           = Hid_ButClr;
        Hid_TextClr_work          = Hid_TextClr;

        CloseDelete_ButClr_work   = CloseDelete_ButClr;
        CloseDelete_TextClr_work  = CloseDelete_TextClr;

        Sym_ActiveClr_work        = Sym_ActiveClr;
        Sym_InactiveClr_work      = Sym_InactiveClr;
        Sym_TextClr_work          = Sym_TextClr;

        BuySell_BuyClr_work       = BuySell_BuyClr;
        BuySell_SellClr_work      = BuySell_SellClr;
        BuySell_TextClr_work      = BuySell_TextClr;

        VolMng_ButClr_work        = VolMng_ButClr;
        VolMng_TextClr_work       = VolMng_TextClr;

        InputField_BgdClr_work    = InputField_BgdClr;
        InputField_TextClr_work   = InputField_TextClr;

        Bgd_Clr_work             = Bgd_Clr;
        Bgd_BrdClr_work          = Bgd_BrdClr;

        ThemeSwitch_ButClr_work   = ThemeSwitch_ButClr;
        ThemeSwitch_TextClr_work  = ThemeSwitch_TextClr;
    }
}

