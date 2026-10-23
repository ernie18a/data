//+------------------------------------------------------------------+
//|                                       GoldPositionSizeCalculator |
//|                    Copyright 2026, zqf2013111                    |
//+------------------------------------------------------------------+
//| A risk-based position size calculator built specifically for     |
//| Gold (XAUUSD) traders.                                           |
//|                                                                  |
//| The idea: most retail traders lose money not because of bad      |
//| entries, but because of wrong position sizes. Risking a fixed    |
//| lot size means every trade carries a different, unknown risk.    |
//| This indicator applies the classic risk-based sizing formula:    |
//|                                                                  |
//|   lot size = (balance x risk %) / (stop distance x contract)     |
//|                                                                  |
//| so that if the stop-loss is hit, the loss equals exactly the     |
//| chosen percentage of the account - no more, no less.             |
//|                                                                  |
//| The indicator draws entry / stop-loss / take-profit lines on     |
//| the chart and shows an info panel with all calculation results.  |
//| Contract size is read automatically from the symbol              |
//| specification, so any gold symbol works without manual setup.    |
//+------------------------------------------------------------------+
#property copyright   "zqf2013111"
#property version     "1.10"
#property description "Gold (XAUUSD) risk-based position size calculator."
#property description "Enter balance, risk %, entry and stop - get the correct lot size."
#property description "Auto-detects contract size from symbol specification."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Entry
#property indicator_label1  "Entry"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Stop
#property indicator_label2  "Stop"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot TP
#property indicator_label3  "TP"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- inputs
input group             "Risk Settings"
input double InpAccountBalance = 1000.0;   // Account balance
input double InpRiskPercent    = 1.0;      // Risk per trade (%)
input double InpEntryPrice     = 0.0;      // Entry price (0 = current close)
input double InpStopPrice      = 0.0;      // Stop-loss price (0 = not set)
input double InpTakeProfit     = 0.0;      // Take-profit price (0 = not set)
input group             "Instrument"
input double InpContractSize   = 0.0;     // Contract size per 1.00 lot (0 = auto from symbol specification)
input group             "Display"
input bool   InpShowLines      = true;     // Show entry / stop / TP lines
input bool   InpShowPanel      = true;     // Show info panel
input ENUM_BASE_CORNER InpPanelCorner = CORNER_LEFT_UPPER; // Panel corner
//--- indicator buffers: the three horizontal lines drawn on the chart
double EntryBuffer[];
double StopBuffer[];
double TpBuffer[];
//--- panel object names prefix and layout constants
#define PFX "GPS_"
#define PANEL_W 240
#define ROW_H   18
//+------------------------------------------------------------------+
//| Create the info panel                                            |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   string bg = PFX + "BG";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, 20);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE, PANEL_W);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE, 34 + 7 * ROW_H);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR, C'30,34,45');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_COLOR, C'80,86,102');
   ObjectSetInteger(0, bg, OBJPROP_BACK, false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN, true);

   CreateLabel(PFX + "TITLE", 12, 28, "GOLD POSITION SIZER", clrWhite, 10);
   string rows[7] = {"Balance", "Risk %", "Risk amount", "Stop distance", "Lot size", "R:R", "Pot. profit"};
   for(int i = 0; i < 7; i++)
     {
      int y = 46 + i * ROW_H;
      CreateLabel(PFX + "L" + IntegerToString(i), 12, y, rows[i], clrSilver, 9);
      CreateLabel(PFX + "V" + IntegerToString(i), 140, y, "", clrWhite, 9);
     }
  }
//+------------------------------------------------------------------+
//| Create a single label in the panel                               |
//+------------------------------------------------------------------+
void CreateLabel(const string name, const int x, const int y, const string text, const color clr, const int fontSize)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, InpPanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }
//+------------------------------------------------------------------+
//| Update one value row of the panel                                |
//+------------------------------------------------------------------+
void SetRow(const int i, const string value, const color clr)
  {
   ObjectSetString(0, PFX + "V" + IntegerToString(i), OBJPROP_TEXT, value);
   ObjectSetInteger(0, PFX + "V" + IntegerToString(i), OBJPROP_COLOR, clr);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, EntryBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, StopBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, TpBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   IndicatorSetString(INDICATOR_SHORTNAME, "Gold Position Size Calculator (Risk-Based)");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   if(InpShowPanel)
      CreatePanel();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, PFX);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total < 1)
      return(0);

   //--- resolve the entry price: use the current close if not set explicitly
   double entry   = (InpEntryPrice == 0.0) ? close[rates_total - 1] : InpEntryPrice;
   //--- the calculation is only meaningful once a stop-loss price is set
   bool   valid   = (InpStopPrice > 0.0 && entry > 0.0 && InpStopPrice != entry);
   //--- money risked on this trade, in account currency
   double riskAmt = InpAccountBalance * InpRiskPercent / 100.0;
   //--- distance between entry and stop-loss, in price units
   double stopDist = MathAbs(entry - InpStopPrice);
   //--- contract size per lot: manual input wins, otherwise read the symbol specification
   double contract   = (InpContractSize > 0.0) ? InpContractSize : SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   //--- money lost per 1.00 lot if the stop is hit
   double riskPerLot = stopDist * contract;
   //--- the core formula: risk amount divided by risk per lot
   double lots    = (riskPerLot > 0.0) ? riskAmt / riskPerLot : 0.0;
   //--- round down to the broker's 0.01 lot step
   lots = MathFloor(lots * 100.0) / 100.0;
   //--- risk/reward and potential profit are shown only when a take-profit is set
   bool   hasTp   = (InpTakeProfit > 0.0);
   double rr      = (hasTp && stopDist > 0.0) ? MathAbs(InpTakeProfit - entry) / stopDist : 0.0;
   double profit  = (hasTp) ? lots * MathAbs(InpTakeProfit - entry) * contract : 0.0;

   //--- draw the entry / stop / TP lines across the visible chart
   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   for(int i = start; i < rates_total; i++)
     {
      EntryBuffer[i] = (InpShowLines && valid) ? entry : EMPTY_VALUE;
      StopBuffer[i]  = (InpShowLines && valid) ? InpStopPrice : EMPTY_VALUE;
      TpBuffer[i]    = (InpShowLines && hasTp) ? InpTakeProfit : EMPTY_VALUE;
     }

   //--- refresh the panel values
   if(InpShowPanel)
     {
      SetRow(0, DoubleToString(InpAccountBalance, 2), clrWhite);
      SetRow(1, DoubleToString(InpRiskPercent, 2) + " %", clrWhite);
      SetRow(2, DoubleToString(riskAmt, 2), clrOrange);
      SetRow(3, DoubleToString(stopDist, _Digits), clrWhite);
      if(valid)
        {
         SetRow(4, DoubleToString(lots, 2), clrAqua);
         SetRow(5, hasTp ? DoubleToString(rr, 2) : "set TP", hasTp ? (rr >= 2.0 ? clrLime : clrYellow) : clrGray);
         SetRow(6, hasTp ? DoubleToString(profit, 2) : "set TP", hasTp ? clrLime : clrGray);
        }
      else
        {
         SetRow(4, "set stop", clrGray);
         SetRow(5, "-", clrGray);
         SetRow(6, "-", clrGray);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
