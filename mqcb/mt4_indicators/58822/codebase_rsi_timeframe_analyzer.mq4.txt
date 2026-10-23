//+------------------------------------------------------------------+
//|                              codebase_RSI Timeframe Analyzer.mq4 |
//|                                                          Manasvi |
//|                        Reference:  https://t.me/StrategyNotebook |
//| This indicator was developed as part of an experimental research |
//|                                                          series. |
//|       From time to time, variations or test builds may be shared | 
//|                                                       externally |
//|                                 for study and analysis purposes. |
//+------------------------------------------------------------------+

#property link          "https://t.me/StrategyNotebook"
#property version       "1.00"
#property strict
#property copyright     "StrategyNotebook by Manasvi"
#property description   "This indicator was developed as part of an experimental research series. From time to time, variations or test builds may be shared externally"
#property description   " "
#property description   "Find more at t.me/StrategyNotebook"

#property indicator_chart_window
#property indicator_buffers 1

#include <MQLTA Utils.mqh>

enum ENUM_CANDLE_TO_CHECK
{

    CLOSED_CANDLE = 1    //PREVIOUS CANDLE
};

input string Comment_1 = "====================";   // Indicator Settings
input int RSIPeriod = 14;                          // RSI Period
input int RSIHighLimit = 70;                       // RSI High Limit
input int RSILowLimit = 30;                        // RSI Low Limit
ENUM_APPLIED_PRICE RSIAppliedPrice = PRICE_CLOSE;   // RSI Applied Price
ENUM_CANDLE_TO_CHECK CandleToCheck = CLOSED_CANDLE; // Candle To Use For Analysis
input string Comment_2b = "===================="; // Enabled Timeframes
input bool TFM1 = true;                           // Enable Timeframe M1
input bool TFM5 = true;                           // Enable Timeframe M5
input bool TFM15 = true;                          // Enable Timeframe M15
input bool TFM30 = true;                          // Enable Timeframe M30
input bool TFH1 = true;                           // Enable Timeframe H1
input bool TFH4 = true;                           // Enable Timeframe H4
input bool TFD1 = true;                           // Enable Timeframe D1
input bool TFW1 = true;                           // Enable Timeframe W1
input bool TFMN1 = true;                          // Enable Timeframe MN1
int Xoff = 20;                              // Horizontal spacing for the control panel
int Yoff = 20;                              // Vertical spacing for the control panel
ENUM_BASE_CORNER ChartCorner = CORNER_LEFT_UPPER;
int FontSize = 8;                           // Font Size
string IndicatorName = "RSI-Timeframe-Analyzer";      // Indicator Name (to name the objects)

double IndCurr[9], IndPrevDiff[9], IndCurrAdd[9];

bool Overbought = false;
bool Oversold = false;
bool InRange = false;

bool TFEnabled[9];
int TFValues[9];
string TFText[9];
int TFIndValue[9];

double BufferZero[1];

double LastAlertDirection = 2; // Signal that was alerted on previous alert. Double because BufferZero is double. "2" because "EMPTY_VALUE", "0", "1", and "-1" are taken for signals.

double DPIScale; // Scaling parameter for the panel based on the screen DPI.
int PanelMovX, PanelMovY, PanelLabX, PanelLabY, PanelRecX;

//+------------------------------------------------------------------+
//| Custom indicator initialization function.                        |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    CleanChart();

    TFEnabled[0] = TFM1;
    TFEnabled[1] = TFM5;
    TFEnabled[2] = TFM15;
    TFEnabled[3] = TFM30;
    TFEnabled[4] = TFH1;
    TFEnabled[5] = TFH4;
    TFEnabled[6] = TFD1;
    TFEnabled[7] = TFW1;
    TFEnabled[8] = TFMN1;
    TFValues[0] = PERIOD_M1;
    TFValues[1] = PERIOD_M5;
    TFValues[2] = PERIOD_M15;
    TFValues[3] = PERIOD_M30;
    TFValues[4] = PERIOD_H1;
    TFValues[5] = PERIOD_H4;
    TFValues[6] = PERIOD_D1;
    TFValues[7] = PERIOD_W1;
    TFValues[8] = PERIOD_MN1;
    TFText[0] = "M1";
    TFText[1] = "M5";
    TFText[2] = "M15";
    TFText[3] = "M30";
    TFText[4] = "H1";
    TFText[5] = "H4";
    TFText[6] = "D1";
    TFText[7] = "W1";
    TFText[8] = "MN1";

    ArrayInitialize(TFIndValue, 0);
    SetIndexBuffer(0, BufferZero);
    SetIndexStyle(0, DRAW_NONE);
    
    DPIScale = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;

    PanelMovX = (int)MathRound(40 * DPIScale);
    PanelMovY = (int)MathRound(20 * DPIScale);
    PanelLabX = (PanelMovX + 1) * 3 + 2;
    PanelLabY = PanelMovY;
    PanelRecX = PanelLabX + 4;

    CalculateLevels();

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function.                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    CalculateLevels();

    FillBuffers();
  

    DrawPanel();
    
ObjectCreate("info", OBJ_LABEL, 0, 0, 0);
ObjectSetText("info", " Research extensions noted: t(.)me(/)StrategyNotebook", 14, "Arial", clrSalmon);
ObjectSetInteger(0, "info", OBJPROP_CORNER, 2); // Bottom-right
ObjectSetInteger(0, "info", OBJPROP_XDISTANCE, 10);
ObjectSetInteger(0, "info", OBJPROP_YDISTANCE, 40);

    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Indicator deinitialization.                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    CleanChart();
}

//+------------------------------------------------------------------+
//| Processes key presses and mouse clicks.                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_KEYDOWN)
    {
        if (lparam == 27) // Escape key pressed.
        {
            ChartIndicatorDelete(0, 0, IndicatorName);
        }
    }
    else if (id == CHARTEVENT_OBJECT_CLICK) // Timeframe switching.
    {
        if (StringFind(sparam, "-P-TF-") >= 0)
        {
            string ClickDesc = ObjectGetString(0, sparam, OBJPROP_TEXT);
            ChangeChartPeriod(ClickDesc);
        }
    }
}

//+------------------------------------------------------------------+
//| Delets all chart objects created by the indicator.               |
//+------------------------------------------------------------------+
void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}

//+------------------------------------------------------------------+
//| Switch chart timeframe.                                          |
//+------------------------------------------------------------------+
void ChangeChartPeriod(string Button)
{
    StringReplace(Button, "*", "");
    int NewPeriod = 0;
    if (Button == "M1") NewPeriod = PERIOD_M1;
    if (Button == "M5") NewPeriod = PERIOD_M5;
    if (Button == "M15") NewPeriod = PERIOD_M15;
    if (Button == "M30") NewPeriod = PERIOD_M30;
    if (Button == "H1") NewPeriod = PERIOD_H1;
    if (Button == "H4") NewPeriod = PERIOD_H4;
    if (Button == "D1") NewPeriod = PERIOD_D1;
    if (Button == "W1") NewPeriod = PERIOD_W1;
    if (Button == "MN1") NewPeriod = PERIOD_MN1;
    ChartSetSymbolPeriod(0, Symbol(), NewPeriod);
}

//+------------------------------------------------------------------+
//| Main function to detect OS, OB, In Range, Uncertain state.       |
//+------------------------------------------------------------------+
void CalculateLevels()
{
    int EnabledCount = 0;
    int OverboughtCount = 0;
    int OversoldCount = 0;
    int InRangeCount = 0;
    Overbought = false;
    Oversold = false;
    InRange = false;
    int Shift = 0;
    int MaxBars = RSIPeriod + Shift + 1;
    ArrayInitialize(TFIndValue, 0);
    ArrayInitialize(IndCurr, 0);
    ArrayInitialize(IndPrevDiff, 0);
    ArrayInitialize(IndCurrAdd, 0);
    for (int i = 0; i < ArraySize(TFIndValue); i++)
    {
        if (!TFEnabled[i]) continue;
        if (iBars(Symbol(), TFValues[i]) < MaxBars)
        {
            MaxBars = iBars(Symbol(), TFValues[i]);
            Print("Please load more historical candles. Current calculation only on ", MaxBars, " bars for timeframe ", TFText[i], ".");
            if (MaxBars < 0)
            {
                break;
            }
        }
        EnabledCount++;
        string TFDesc = TFText[i];
        double RSICurrMain = iRSI(Symbol(), TFValues[i], RSIPeriod, RSIAppliedPrice, Shift);
        double RSIPrevSign = iRSI(Symbol(), TFValues[i], RSIPeriod, RSIAppliedPrice, Shift + 1);
        if (RSICurrMain >= RSIHighLimit)
        {
            IndCurr[i] = 1;
            OverboughtCount++;
        }
        if (RSICurrMain <= RSILowLimit)
        {
            IndCurr[i] = -1;
            OversoldCount++;
        }
        if (RSICurrMain < RSIHighLimit && RSICurrMain > RSILowLimit)
        {
            IndCurr[i] = 0;
            InRangeCount++;
        }
        if (RSICurrMain > RSIPrevSign)
        {
            IndPrevDiff[i] = 1;
        }
        if (RSICurrMain < RSIPrevSign)
        {
            IndPrevDiff[i] = -1;
        }
    }
    if (OverboughtCount == EnabledCount) Overbought = true;
    if (OversoldCount == EnabledCount) Oversold = true;
    if (InRangeCount == EnabledCount) InRange = true;
}

//+------------------------------------------------------------------+
//| Fills indicator buffers.                                         |
//+------------------------------------------------------------------+
void FillBuffers()
{
    if (Overbought) BufferZero[0] = 1;
    if (Oversold) BufferZero[0] = -1;
    if (InRange) BufferZero[0] = 0;
    if (!Overbought && !Oversold && !InRange) BufferZero[0] = EMPTY_VALUE;
}

//+------------------------------------------------------------------+
//| Alert processing.                                                |
//+------------------------------------------------------------------+


string PanelBase = IndicatorName + "-P-BAS";
string PanelLabel = IndicatorName + "-P-LAB";
string PanelDAbove = IndicatorName + "-P-DABOVE";
string PanelDBelow = IndicatorName + "-P-DBELOW";
string PanelSig = IndicatorName + "-P-SIG";
//+------------------------------------------------------------------+
//| Main panel drawing function.                                     |
//+------------------------------------------------------------------+
void DrawPanel()
{
    int SignX = 1;
    if ((ChartCorner == CORNER_RIGHT_UPPER) || (ChartCorner == CORNER_RIGHT_LOWER))
    {
        SignX = -1; // Correction for right-side panel position.
    }
    string IndicatorNameTextBox = "MT RSI";
    int Rows = 1;
    ObjectCreate(0, PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, PanelBase, OBJPROP_CORNER, ChartCorner);
    ObjectSetInteger(0, PanelBase, OBJPROP_XDISTANCE, Xoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_YDISTANCE, Yoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_COLOR, clrBlack);

    DrawEdit(PanelLabel,
             Xoff + 2 * SignX,
             Yoff + 2,
             PanelLabX,
             PanelLabY,
             true,
             FontSize + 2,
             "Multi Time Frame Indicator",
             ALIGN_CENTER,
             "Consolas",
             IndicatorNameTextBox,
             false,
             clrNavy,
             clrKhaki,
             clrBlack);
    ObjectSetInteger(0, PanelLabel, OBJPROP_CORNER, ChartCorner);

    for (int i = 0; i < ArraySize(TFIndValue); i++)
    {
        if (!TFEnabled[i]) continue;
        string TFRowObj = IndicatorName + "-P-TF-" + TFText[i];
        string IndCurrObj = IndicatorName + "-P-ICURR-V-" + TFText[i];
        string IndPrevDiffObj = IndicatorName + "-P-PREVDIFF-V-" + TFText[i];
        string IndCurrAddObj = IndicatorName + "-P-CURRADD-V-" + TFText[i];
        string TFRowText = TFText[i];
        string IndCurrText = "";
        string IndPrevDiffText = "";
        string IndCurrAddText = "";
        string IndCurrToolTip = "";
        string IndPrevDiffToolTip = "";
        string IndCurrAddToolTip = "";

        color IndCurrBackColor = clrKhaki;
        color IndCurrTextColor = clrNavy;
        color IndPrevDiffBackColor = clrKhaki;
        color IndPrevDiffTextColor = clrNavy;
        color IndCurrAddBackColor = clrKhaki;
        color IndCurrAddTextColor = clrNavy;

        if (IndCurr[i] == 1)
        {
            IndCurrText = "OB";
            IndCurrToolTip = "Currently Overbought";
            IndCurrBackColor = clrDarkRed;
            IndCurrTextColor = clrWhite;
        }
        if (IndCurr[i] == -1)
        {
            IndCurrText = "OS";
            IndCurrToolTip = "Currently Oversold";
            IndCurrBackColor = clrDarkRed;
            IndCurrTextColor = clrWhite;
        }
        if (IndCurr[i] == 0)
        {
            IndCurrText = "OK";
            IndCurrToolTip = "Currently in Range";
        }

        if (IndPrevDiff[i] == 1)
        {
            IndPrevDiffText = CharToString(225); // Up arrow.
            IndPrevDiffToolTip = "Current RSI Higher than Previous Candle";
            IndPrevDiffBackColor = clrDarkGreen;
            IndPrevDiffTextColor = clrWhite;
        }
        if (IndPrevDiff[i] == -1)
        {
            IndPrevDiffText = CharToString(226); // Down arrow.
            IndPrevDiffToolTip = "Current RSI Lower than Previous Candle";
            IndPrevDiffBackColor = clrDarkRed;
            IndPrevDiffTextColor = clrWhite;
        }

        DrawEdit(TFRowObj,
                 Xoff + 2 * SignX,
                 Yoff + (PanelMovY + 1) * Rows + 2,
                 PanelMovX,
                 PanelLabY,
                 true,
                 FontSize,
                 "Situation Detected in the Timeframe",
                 ALIGN_CENTER,
                 "Consolas",
                 TFRowText,
                 false,
                 clrNavy,
                 clrKhaki,
                 clrBlack);
        ObjectSetInteger(0, TFRowObj, OBJPROP_CORNER, ChartCorner);

        DrawEdit(IndCurrObj,
                 Xoff + (PanelMovX + 4) * SignX,
                 Yoff + (PanelMovY + 1) * Rows + 2,
                 PanelMovX,
                 PanelLabY,
                 true,
                 FontSize,
                 IndCurrToolTip,
                 ALIGN_CENTER,
                 "Consolas",
                 IndCurrText,
                 false,
                 IndCurrTextColor,
                 IndCurrBackColor,
                 clrBlack);
        ObjectSetInteger(0, IndCurrObj, OBJPROP_CORNER, ChartCorner);

        DrawEdit(IndPrevDiffObj,
                 Xoff + (PanelMovX * 2 + 6) * SignX,
                 Yoff + (PanelMovY + 1) * Rows + 2,
                 PanelMovX,
                 PanelLabY,
                 true,
                 8,
                 IndPrevDiffToolTip,
                 ALIGN_CENTER,
                 "Wingdings",
                 IndPrevDiffText,
                 false,
                 IndPrevDiffTextColor,
                 IndPrevDiffBackColor,
                 clrBlack);
        ObjectSetInteger(0, IndPrevDiffObj, OBJPROP_CORNER, ChartCorner);

        Rows++;
    }
    string SigText = "";
    color SigColor = clrNavy;
    color SigBack = clrKhaki;
    if (Overbought)
    {
        SigText = "Overbought";
        SigColor = clrWhite;
        SigBack = clrDarkRed;
    }
    if (Oversold)
    {
        SigText = "Oversold";
        SigColor = clrWhite;
        SigBack = clrDarkRed;
    }
    if (InRange)
    {
        SigText = "In Range";
        SigColor = clrWhite;
        SigBack = clrDarkGreen;
    }
    if (!Overbought && !Oversold && !InRange)
    {
        SigText = "Uncertain";
    }

    DrawEdit(PanelSig,
             Xoff + 2 * SignX,
             Yoff + (PanelMovY + 1) * Rows + 2,
             PanelLabX,
             PanelLabY,
             true,
             8,
             "Situation Considering All Timeframes",
             ALIGN_CENTER,
             "Consolas",
             SigText,
             false,
             SigColor,
             SigBack,
             clrBlack);
    ObjectSetInteger(0, PanelSig, OBJPROP_CORNER, ChartCorner);

    Rows++;

    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, (PanelMovY + 1) * Rows + 3);

  
    
}
//+------------------------------------------------------------------+