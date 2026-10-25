//+------------------------------------------------------------------+
//|                                          BasicRiskCalculator.mq5 |
//|                                         Copyright 2025, Hezekiah |
//|                    https://www.mql5.com/en/market/product/162502 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hezekiah"
#property link      "https://www.mql5.com/en/market/product/162502"
#property version   "1.00"
#property description "Basic Risk Calculator for Position Sizing"
#property description "FREE VERSION - Get Pro Risk Manager for advanced features https://www.mql5.com/en/market/product/162502 "
#property strict

//--- Input parameters
input group "=== Panel Settings ==="
input int PanelX = 20;
input int PanelY = 50;

//--- GUI Objects
string prefix = "BasicRC_";
int panelWidth = 260;
int panelHeight = 320;

//--- Variables
double accountBalance;
double riskPercent = 1.0;
double entryPrice = 0;
double stopLossPips = 50;
double calculatedLots = 0;
double potentialLoss = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   entryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   CreatePanel();
   UpdateCalculations();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllObjects();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == prefix + "BtnClose")
      {
         ExpertRemove();
         return;
      }
      
      if(sparam == prefix + "BtnCalculate")
      {
         ReadInputValues();
         UpdateCalculations();
         ObjectSetInteger(0, prefix + "BtnCalculate", OBJPROP_STATE, false);
      }
      else if(sparam == prefix + "BtnUpgrade")
      {
         Alert("Get PRO RISK MANAGER from MQL5 Market for advanced features:\n" +
               "✓ Current Price / Specific Price Mode\n" +
               "✓ Auto-Refresh\n" +
               "✓ Risk Preset Buttons (1%, 2%, 3%)\n" +
               "✓ Take Profit Calculator\n" +
               "✓ Risk:Reward Ratio\n" +
               "✓ Auto Price/Pips Conversion\n" +
               "✓ Professional Design");
         ObjectSetInteger(0, prefix + "BtnUpgrade", OBJPROP_STATE, false);
      }
      
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
//| Create the panel GUI                                             |
//+------------------------------------------------------------------+
void CreatePanel()
{
   color panelColor = clrDimGray;
   color textColor = clrWhiteSmoke;
   
   // Main panel background
   CreateRectangle(prefix + "BgPanel", PanelX, PanelY, panelWidth, panelHeight, panelColor);
   
   // Title bar
   CreateRectangle(prefix + "TitleBar", PanelX, PanelY, panelWidth, 28, clrSlateGray);
   CreateLabel(prefix + "Title", "BASIC RISK CALCULATOR", PanelX + 8, PanelY + 7, clrWhite, 9, "Arial Bold");
   
   // Close button
   CreateButton(prefix + "BtnClose", "X", PanelX + panelWidth - 26, PanelY + 2, 24, 24, clrCrimson);
   
   int yPos = PanelY + 38;
   
   // Account Balance
   CreateLabel(prefix + "LblBalance", "Account Balance:", PanelX + 10, yPos, textColor, 8);
   CreateEdit(prefix + "EditBalance", DoubleToString(accountBalance, 2), PanelX + 135, yPos - 2, 115, 18);
   yPos += 28;
   
   // Risk Percentage
   CreateLabel(prefix + "LblRisk", "Risk %:", PanelX + 10, yPos, textColor, 8);
   CreateEdit(prefix + "EditRisk", DoubleToString(riskPercent, 2), PanelX + 135, yPos - 2, 115, 18);
   yPos += 28;
   
   // Entry Price
   CreateLabel(prefix + "LblEntry", "Entry Price:", PanelX + 10, yPos, textColor, 8);
   CreateEdit(prefix + "EditEntry", DoubleToString(entryPrice, _Digits), PanelX + 135, yPos - 2, 115, 18);
   yPos += 28;
   
   // Stop Loss Pips
   CreateLabel(prefix + "LblSLPips", "Stop Loss (Pips):", PanelX + 10, yPos, textColor, 8);
   CreateEdit(prefix + "EditSLPips", DoubleToString(stopLossPips, 1), PanelX + 135, yPos - 2, 115, 18);
   yPos += 35;
   
   // Calculate button
   CreateButton(prefix + "BtnCalculate", "CALCULATE", PanelX + 10, yPos, panelWidth - 20, 26, clrRoyalBlue);
   yPos += 35;
   
   // Results section
   CreateRectangle(prefix + "ResultsBg", PanelX + 5, yPos - 5, panelWidth - 10, 100, clrBlack);
   CreateLabel(prefix + "LblResults", "RESULTS:", PanelX + 10, yPos, clrYellow, 9, "Arial Bold");
   yPos += 22;
   
   // Position Size
   CreateLabel(prefix + "LblLots", "Position Size:", PanelX + 10, yPos, textColor, 8);
   CreateLabel(prefix + "ResultLots", "0.00 lots", PanelX + 135, yPos, clrLime, 9, "Arial Bold");
   yPos += 22;
   
   // Potential Loss
   CreateLabel(prefix + "LblLoss", "Potential Loss:", PanelX + 10, yPos, textColor, 8);
   CreateLabel(prefix + "ResultLoss", "$0.00", PanelX + 135, yPos, clrOrangeRed, 9, "Arial Bold");
   yPos += 30;
   
   // Upgrade button
   CreateButton(prefix + "BtnUpgrade", "⭐ UPGRADE TO PRO VERSION ⭐", PanelX + 10, yPos, panelWidth - 20, 28, clrGold);
   yPos += 35;
   
   // Footer
   CreateLabel(prefix + "Footer", "FREE Version | v1.00", PanelX + 10, yPos, clrGray, 7);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Read values from input fields                                    |
//+------------------------------------------------------------------+
void ReadInputValues()
{
   accountBalance = StringToDouble(ObjectGetString(0, prefix + "EditBalance", OBJPROP_TEXT));
   riskPercent = StringToDouble(ObjectGetString(0, prefix + "EditRisk", OBJPROP_TEXT));
   entryPrice = StringToDouble(ObjectGetString(0, prefix + "EditEntry", OBJPROP_TEXT));
   stopLossPips = StringToDouble(ObjectGetString(0, prefix + "EditSLPips", OBJPROP_TEXT));
   
   if(entryPrice == 0)
      entryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

//+------------------------------------------------------------------+
//| Update all calculations                                          |
//+------------------------------------------------------------------+
void UpdateCalculations()
{
   ReadInputValues();
   
   // Calculate position size
   double riskAmount = accountBalance * (riskPercent / 100.0);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Calculate pip value
   double pipValue = 0;
   if(tickSize > 0 && point > 0)
   {
      pipValue = (pointValue / tickSize) * point * 10;
   }
   
   if(stopLossPips > 0 && pipValue > 0)
   {
      calculatedLots = riskAmount / (stopLossPips * pipValue);
      
      // Round to valid lot size
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      if(lotStep > 0)
      {
         calculatedLots = MathFloor(calculatedLots / lotStep) * lotStep;
         calculatedLots = MathMax(minLot, MathMin(maxLot, calculatedLots));
      }
   }
   else
   {
      calculatedLots = 0;
   }
   
   // Calculate potential loss
   if(pipValue > 0)
   {
      potentialLoss = calculatedLots * stopLossPips * pipValue;
   }
   
   // Update display
   ObjectSetString(0, prefix + "ResultLots", OBJPROP_TEXT, DoubleToString(calculatedLots, 2) + " lots");
   ObjectSetString(0, prefix + "ResultLoss", OBJPROP_TEXT, "$" + DoubleToString(potentialLoss, 2));
   
   // Update edit fields
   ObjectSetString(0, prefix + "EditBalance", OBJPROP_TEXT, DoubleToString(accountBalance, 2));
   ObjectSetString(0, prefix + "EditRisk", OBJPROP_TEXT, DoubleToString(riskPercent, 2));
   ObjectSetString(0, prefix + "EditEntry", OBJPROP_TEXT, DoubleToString(entryPrice, _Digits));
   ObjectSetString(0, prefix + "EditSLPips", OBJPROP_TEXT, DoubleToString(stopLossPips, 1));
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Helper functions to create GUI objects                          |
//+------------------------------------------------------------------+
void CreateRectangle(string name, int x, int y, int width, int height, color clr)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void CreateLabel(string name, string text, int x, int y, color clr, int size = 8, string font = "Arial")
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void CreateEdit(string name, string text, int x, int y, int width, int height)
{
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrGray);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, name, OBJPROP_READONLY, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void CreateButton(string name, string text, int x, int y, int width, int height, color clr)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void DeleteAllObjects()
{
   int obj_total = ObjectsTotal(0, 0, -1);
   for(int i = obj_total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
   }
   ChartRedraw();
}
//+------------------------------------------------------------------+