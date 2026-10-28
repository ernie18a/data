#property copyright     "Mokara"
#property link          "https://www.mql5.com/en/users/mokara"
#property description   "Simple Simulator"
#property version       "1.0"
#property indicator_chart_window

input uint barBegin = 1000;  //Beginning Bar
input uint timeSpeed = 2;    //Speed (Seconds)

MqlRates Rates[];
bool endProgram = false;
bool firstRun = true;
uint chWidth = 0;
int c = 0;

double tOpen = 0, tPrice = 0, tResult = 0, tProfit = 0;
string tType = "NONE";

string infoNames[5] = {"INFO_TRADE", "INFO_OPEN", "INFO_PRICE", "INFO_RESULT", "INFO_PROFIT"};
string infoTitles[5] = {"Trade Type: ", "Trade Open: ", "Trade Price: ", "Trade Result: ", "Total Profit: "};
string infoValues[5] = {"", "", "", "", ""};
string btnNames[5] = {"LONG", "SHORT", "CLOSE", "PAUSE", "END"};

void MakeButton(string name, int index)
{
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, chWidth / 2 + index * 70);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
   ObjectSetString(0, name, OBJPROP_TEXT, name);
}

void MakeLabel(string name, string text, int index)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, chWidth / 2 - 140);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, index * 20 + 30);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Black");
}

void EditLabels()
{
   infoValues[0] = tType;
   infoValues[1] = DoubleToString(tOpen, 5);
   infoValues[2] = DoubleToString(tPrice, 5);
   infoValues[3] = DoubleToString(tResult, 0);
   infoValues[4] = DoubleToString(tProfit, 0);
   for(int i = 0; i < ArraySize(infoNames); i++)
   {
      ObjectSetString(0, infoNames[i], OBJPROP_TEXT, infoTitles[i] + infoValues[i]);
   }
}

void DisableButtons()
{
   for(int i = 0; i < ArraySize(btnNames); i++) ObjectSetInteger(0, btnNames[i], OBJPROP_STATE, false);  
}

int OnInit()
{   
   EventSetTimer(timeSpeed);
   IndicatorSetString(INDICATOR_SHORTNAME, "SimSim");   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   Alert("Net Profit/Loss: " + DoubleToString(NormalizeDouble(tProfit, 0), 0) + " pips.");
   EventKillTimer();
   ObjectsDeleteAll(0);
}

void OnTimer()
{
   if(firstRun == true)
   {
      if(barBegin > Bars(_Symbol, _Period))
      {
         Alert("ERROR: not enough bars.");
         endProgram = true;
         firstRun = false;
         return;
      }
      
      c = -1 * barBegin;
      ChartNavigate(0, CHART_BEGIN, c);
      chWidth = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      ChartSetInteger(0, CHART_AUTOSCROLL, false);
      ChartSetInteger(0, CHART_SHIFT, false);
      ChartNavigate(0, CHART_END, -1 * barBegin - 1);      
      ArraySetAsSeries(Rates, true);
      ArrayResize(Rates, barBegin+10);
      CopyRates(_Symbol, _Period, 0, barBegin+10, Rates);
      for(int i = 0; i < ArraySize(btnNames); i++) MakeButton(btnNames[i], i-2);   
      for(int i = 0; i < ArraySize(infoNames); i++) MakeLabel(infoNames[i], infoTitles[i], i);
      tPrice = Rates[barBegin - 1].close;
      EditLabels();
      ChartRedraw();
      firstRun = false;
   }
   
   if(c == 0 || endProgram == true)
   {
      Alert("The End.");
      ChartIndicatorDelete(0, 0, "SimSim");
   }
   
   if(ObjectGetInteger(0, "PAUSE", OBJPROP_STATE) == true)
   {
      return;
   }  
   
   ChartNavigate(0, CHART_END, c);
   
   c++;
   tPrice = Rates[-1 * c].close;
   if(tType == "LONG")
   {
      tResult = (tPrice - tOpen) / _Point;
   }
   
   if(tType == "SHORT")
   {
      tResult = (tOpen - tPrice) / _Point;
   }
   
    
   
   EditLabels();
   ChartRedraw();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{    
   if(ObjectGetInteger(0, "END", OBJPROP_STATE) == true)
   {    
      Alert("Simulation manually terminated.");
      ChartIndicatorDelete(0, 0, "SimSim");
   }
   
   if(ObjectGetInteger(0, "LONG", OBJPROP_STATE) == true)
   {
      ObjectSetInteger(0, "LONG", OBJPROP_STATE, false);
      if(tType == "NONE")
      {
         tOpen = tPrice;
         tType = "LONG";
      }
   }
   
   if(ObjectGetInteger(0, "SHORT", OBJPROP_STATE) == true)
   {
      ObjectSetInteger(0, "SHORT", OBJPROP_STATE, false);
      if(tType == "NONE")
      {
         tOpen = tPrice;
         tType = "SHORT";
      }
   } 
   
   if(ObjectGetInteger(0, "CLOSE", OBJPROP_STATE) == true && tType != "NONE")
   {
      ObjectSetInteger(0, "CLOSE", OBJPROP_STATE, false);
      if(tType != "NONE")
      {
         tOpen = 0;
         tProfit += tResult;
         tResult = 0;
         tType = "NONE";
      }
   }
   
   if(ObjectGetInteger(0, "CLOSE", OBJPROP_STATE) == true && tType == "NONE")
   {
      ObjectSetInteger(0, "CLOSE", OBJPROP_STATE, false);
   }
   
   EditLabels();
   ChartRedraw();
}

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
   return(rates_total);
}