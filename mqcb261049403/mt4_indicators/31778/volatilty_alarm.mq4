//+------------------------------------------------------------------+
//|                                               Volatility Scalper |
//|                                                   Copyright 2020 |
//|                                               drdz9876@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Drdz"
#property version     "1.0"
//----
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 0
#property strict

enum CandleMode
  {
   HiLo,    //High to Low
   Body     //Body
  };
input ENUM_TIMEFRAMES   CandleTF            = PERIOD_M1;            //Candle Timeframe
input CandleMode        Mode                = HiLo;                 //Mode
input double            PipAlarm            = 5;                    //Pips to Alarm
input ENUM_BASE_CORNER  corner              = CORNER_RIGHT_UPPER;   //Text Position
input color             CandleColor         = clrWhite;             //Text Color
input color             CandleAlarm         = clrRed;               //Text Color when Alarm
input bool              EnableAlert         = false;                //Enable Alert
input bool              EnableNotif         = false;                //Enable Notification
input bool              EnableSound         = false;                //Enable Sound
input string            SoundsFile          = "test.wav";           //Sounds File

long chartID = 0;
double DigitMultiplier;
double Range[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicator line
   IndicatorBuffers(2);
   SetIndexBuffer(0,Range);
   SetIndexEmptyValue(0,0);
   SetIndexStyle(0,DRAW_NONE);

   if(Digits()==3 || Digits()==5)
      DigitMultiplier = 0.1;
   else
      DigitMultiplier = 1;

   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility Scalper");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(chartID,"vol");
   ObjectDelete(chartID,"spread");
   return;
  }


//+------------------------------------------------------------------+
//|                                                                  |
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
   RefreshRates();
   ArraySetAsSeries(Range,true);
   int   i;
   int   limit;
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(i=0; i<limit; i++)
     {
      Range[i] = EMPTY_VALUE;
      if(Mode == HiLo)
         Range[i] = (MathAbs(iHigh(Symbol(),CandleTF,i)-iLow(Symbol(),CandleTF,i))/Point())*DigitMultiplier;
      else
         if(Mode == Body)
            Range[i] = (MathAbs(iClose(Symbol(),CandleTF,i)-iOpen(Symbol(),CandleTF,i))/Point())*DigitMultiplier;

     }
   createObject("vol","Volatility: "+DoubleToString(Range[0],1),15,20,16,CandleColor);
   createObject("spread","Spread: "+IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD)),15,50,16,clrRed);
   if(Range[0] >= PipAlarm)
     {
      doAlert("Volatility is : "+DoubleToString(Range[0],1));
      ObjectSetInteger(chartID,"vol",OBJPROP_COLOR,CandleAlarm);
     }
   ResetLastError();
   ChartRedraw(chartID);
//----
   return(rates_total);
  }

//+------------------------------------------------------------------+
void doAlert(string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

   if(previousAlert != doWhat || previousTime != Time[0])
     {
      previousAlert  = doWhat;
      previousTime   = Time[0];

      message =  doWhat;
      if(EnableAlert)
         Alert(message);
      if(EnableNotif)
         SendNotification(message);
      if(EnableSound)
         PlaySound(SoundsFile);
     }
  }
//+------------------------------------------------------------------+
bool createObject(string name,string text,int x,int y,int size, int clr)
  {
   ObjectCreate(chartID,name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_CORNER, corner);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSetText(name, text, 16,"Arial", clr);

   return (true);
  }
//+------------------------------------------------------------------+
