//+------------------------------------------------------------------+ 
//|                                            ytg_Alert_New_Bar.mq5 | 
//|                                   Copyright © 2009, Yuriy Tokman | 
//|                                            yuriytokman@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link "yuriytokman@gmail.com"
#property description "Sound signal of new bar"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input bool On_Alert = false;               //making an alert
input bool On_Play_Sound = false;          //making a sound signal
input string NameFileSound = "expert.wav";  //name of the file with sound
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=2;

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"ytg_Alert_New_Bar");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//----
   if(rates_total!=prev_calculated && prev_calculated>0)
     {
      if(On_Play_Sound) PlaySound(NameFileSound);
      if(On_Alert) Alert("New bar!"," Time Frame - ",
         GetStringTimeframe(PERIOD_CURRENT),"; CurTime=",TimeToString(TimeCurrent(),TIME_MINUTES));
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
