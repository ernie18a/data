//+------------------------------------------------------------------+
//|                                                 Risk Translation |
//|                                            Copyright 2024, phade |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, phade"
#property link      "https://www.mql5.com/en/users/phade"
#property version   "1.02"

#define OBJ_PREFIX MQLInfoString(MQL_PROGRAM_NAME)

int fontSize = 10;
string objName, panelName;
bool processComplete = false;

bool labelsDrawn = false;

void OnStart() {

   double priceMax = ChartGetDouble(0, CHART_PRICE_MAX);
   double priceMin = ChartGetDouble(0, CHART_PRICE_MIN);
   datetime timeStart = iTime(_Symbol, _Period, 10);
   datetime timeEnd = TimeCurrent();

   string riskInfo[12];
   string deposit_currency_symbol = AccountInfoString(ACCOUNT_CURRENCY) + " ";
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   

   for (int i = 1; i <= 10; i++){
   
      riskInfo[i] = IntegerToString(i) + "%: " + deposit_currency_symbol + DoubleToString((balance / 100.0) * i, 2);
   }

   panelName = OBJ_PREFIX + "RiskSheet";

   if (ObjectFind(0, panelName) < 0) {
      ObjectCreate(0, panelName, OBJ_RECTANGLE, 0, timeStart, priceMax, timeEnd, priceMin);
   }
   ObjectSetInteger(0, panelName, OBJPROP_COLOR, clrPink);
   ObjectSetInteger(0, panelName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, panelName, OBJPROP_WIDTH, 4);
   ObjectSetInteger(0, panelName, OBJPROP_FILL, true);
   ObjectSetInteger(0, panelName, OBJPROP_BACK, true);
   
   ChartSetInteger(0, CHART_SHOW, 0, false);


   for (int i = 1; i <= 10; i++){
   
      makeLabel(170, 20 + (i * 20), CORNER_RIGHT_UPPER, fontSize, clrBlack, riskInfo[i], i);
      
      if(i == 10){
         labelsDrawn = true;
         ChartNavigate(0, CHART_END);
      }
   }

   if(labelsDrawn){
   
      Sleep(2000);
   }
 
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartSetInteger(0, CHART_SHOW, 0, true);
}

void makeLabel(int xPos, int yPos, ENUM_BASE_CORNER corner, int textFontSize, color fontColor, string info, int index) {

   objName = OBJ_PREFIX + "InfoPanel" + IntegerToString(index);

   // Create object if it doesn't exist and update otherwise
   if (ObjectFind(0, objName) < 0) {
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
   }

   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, xPos);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yPos);
   ObjectSetInteger(0, objName, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, textFontSize);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, fontColor);
   ObjectSetString(0, objName, OBJPROP_TEXT, info);
 // ObjectSetInteger(0, objName, OBJPROP_BACK, false);
}
