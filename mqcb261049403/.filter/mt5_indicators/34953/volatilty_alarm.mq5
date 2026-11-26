//+------------------------------------------------------------------+
//|                                               Volatility Alarm   |
//|                                                   Copyright 2022 |
//|                                               drdz9876@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022"
#property link "drdz9876@gmail.com"
#property version     "1.1"
//----
#property indicator_chart_window
#property indicator_buffers 5
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
input color             CandleColor         = clrGreen;             //Text Color
input color             CandleAlarm         = clrYellow;            //Text Color when Alarm
input bool              EnableAlert         = false;                //Enable Alert
input bool              EnableNotif         = false;                //Enable Notification
input bool              EnableSound         = false;                //Enable Sound
input string            SoundsFile          = "alert.wav";          //Sounds File

long chartID = 0;
double DigitMultiplier;
double Range[];
double HIGH[],LOW[],CLOSE[],OPEN[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicator line
   SetIndexBuffer(0,Range);
   SetIndexBuffer(1,HIGH);
   SetIndexBuffer(2,LOW);
   SetIndexBuffer(3,CLOSE);
   SetIndexBuffer(4,OPEN);
   
   if(Digits()==3 || Digits()==5)
      DigitMultiplier = 0.1;
   else
      DigitMultiplier = 1;

   createObject("vol"," ",15,20,16,CandleColor);
   createObject("spreadS"," ",15,50,16,clrRed);

   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility Scalper");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(chartID,"vol");
   ObjectDelete(chartID,"spreadS");
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
   ArraySetAsSeries(Range,true);
   ArrayInitialize(Range,0.0);
   
   ArraySetAsSeries(HIGH,true);
   ArraySetAsSeries(LOW,true);
   ArraySetAsSeries(CLOSE,true);
   ArraySetAsSeries(OPEN,true);


  if(CopyHigh(Symbol(),CandleTF,0,Bars(Symbol(),CandleTF),HIGH) < 0)
   return(0);
  if(CopyLow(Symbol(),CandleTF,0,Bars(Symbol(),CandleTF),LOW) < 0)
   return(0);
  if(CopyClose(Symbol(),CandleTF,0,Bars(Symbol(),CandleTF),CLOSE) < 0)
   return(0);
  if(CopyOpen(Symbol(),CandleTF,0,Bars(Symbol(),CandleTF),OPEN) < 0)
   return(0);
   

   int   i;
   int   limit;
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;

   for(i=0; i<limit && !IsStopped(); i++)
     {
      if(Mode == HiLo)
         Range[i] = (MathAbs(HIGH[i]-LOW[i])/Point())*DigitMultiplier;
      else
         if(Mode == Body)
            Range[i] = (MathAbs(CLOSE[i]-OPEN[i])/Point())*DigitMultiplier;

     }
   if(Range[0] >= PipAlarm)
     {
      doAlert("Volatility is : "+DoubleToString(Range[0],1));
      ObjectSetInteger(chartID,"vol",OBJPROP_COLOR,CandleAlarm);
     }
    
   ObjectSetString(chartID,"vol",OBJPROP_TEXT,"Volatility: "+DoubleToString(Range[0],1)); 
   ObjectSetString(chartID,"spreadS",OBJPROP_TEXT,"Spread: "+IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD))); 
     
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

   if(previousAlert != doWhat || previousTime != iTime(NULL,0,0))
     {
      previousAlert  = doWhat;
      previousTime   = iTime(NULL,0,0);

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
   ObjectSetInteger(chartID,name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chartID,name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartID,name, OBJPROP_YDISTANCE, y);
   ObjectSetString(chartID,name, OBJPROP_TEXT, text);
   ObjectSetString(chartID,name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(chartID,name, OBJPROP_COLOR, clr);
   ObjectSetInteger(chartID,name, OBJPROP_FONTSIZE, 16);
   
   return (true);
  }
//+------------------------------------------------------------------+
