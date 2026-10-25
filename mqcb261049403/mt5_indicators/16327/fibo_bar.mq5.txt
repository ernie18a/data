//+------------------------------------------------------------------+
//|                                                     Fibo_Bar.mq5 |
//|                                                  © Tecciztecatl  |
//+------------------------------------------------------------------+
#property copyright     "© Tecciztecatl 2016"
#property link          "https://www.mql5.com/en/users/tecciztecatl"
#property version       "1.00"
#property description   "This indicator draws Fibo levels on the last bar."
#property strict
#property indicator_chart_window
#property indicator_plots 0

input string comm0="";                      // ---- FIBO ----
input ENUM_TIMEFRAMES Fibo_Bar=PERIOD_D1;   // Last Bar for Fibo
input color  fibo_color1=clrSkyBlue;        // Upper color 
input color  fibo_color0=clrLimeGreen;      // Main color 
input color  fibo_color2=clrOrange;         // Lower color 
input ENUM_LINE_STYLE fibo_style=STYLE_DOT; // Style lines
input int    fibo_width=1;                  // Line Width

double FIBO_levels[];
double FIBO_prices[];
string fibo_txt[];
string fibo_levels0="0 23.6 38.2 50 61.8 76.4 100";
string fibo_levels1="123.6 138.2 150 161.8 176.4 200 223.6 238.2 250 261.8 276.4 300 323.6 338.2 350 361.8 376.4 400";
string fibo_levels2="-23.6 -38.2 -50 -61.8 -76.4 -100 -123.6 -138.2 -150 -161.8 -176.4 -200 -223.6 -238.2 -250 -261.8 -276.4 -300 -323.6 -338.2 -350 -361.8 -376.4 -400";
string Label_prefix="Fibo_";
int    allBars;
long   chart_ID;
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjects();
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   chart_ID=ChartID();
   return(INIT_SUCCEEDED);
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
   if(allBars!=Bars(_Symbol,Fibo_Bar) || ObjectFind(chart_ID,Label_prefix+"f0")<0)
     {
      allBars=Bars(_Symbol,Fibo_Bar);
      BuildLevels();
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuildLevels()
  {
   double Maximum = iHigh(NULL,Fibo_Bar,1);
   double Minimum = iLow (NULL,Fibo_Bar,1);
   datetime time1 = iTime(NULL,Fibo_Bar,0)+PeriodSeconds(Fibo_Bar)*7;
   datetime time2 = iTime(NULL,Fibo_Bar,1);
   string   tf=TFtoStr(Fibo_Bar);

   MakeFibo(fibo_levels0);
   SetFibo(Label_prefix+"f0",time1,Maximum,time2,Minimum,fibo_color0,fibo_width,clrNONE);
   ObjectSetString(chart_ID,Label_prefix+"f0",OBJPROP_LEVELTEXT,6,"High last "+tf+" "+ObjectGetString(chart_ID,Label_prefix+"f0",OBJPROP_LEVELTEXT,6));
   ObjectSetString(chart_ID,Label_prefix+"f0",OBJPROP_LEVELTEXT,0,"Low last "+tf+" "+ObjectGetString(chart_ID,Label_prefix+"f0",OBJPROP_LEVELTEXT,0));

   MakeFibo(fibo_levels1);
   SetFibo(Label_prefix+"f1",time1,Maximum,time2,Minimum,fibo_color1,fibo_width,clrNONE);

   MakeFibo(fibo_levels2);
   SetFibo(Label_prefix+"f2",time1,Maximum,time2,Minimum,fibo_color2,fibo_width,clrNONE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetFibo(const string   nname,
             datetime        time1,
             double          price1,
             datetime        time2,
             double          price2,
             color           cvet,
             int             wiDth,
             color           cvet_full,
             )
  {
   int levels=ArraySize(FIBO_levels);
   if(ObjectFind(chart_ID,nname)<0)
     {
      ObjectCreate(chart_ID,nname,OBJ_FIBO,0,time1,price1,time2,price2);
      ObjectSetInteger(chart_ID,nname,OBJPROP_COLOR,cvet_full);
      ObjectSetInteger(chart_ID,nname,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(chart_ID,nname,OBJPROP_WIDTH,1);
      ObjectSetInteger(chart_ID,nname,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(chart_ID,nname,OBJPROP_SELECTED,false);
      ObjectSetInteger(chart_ID,nname,OBJPROP_BACK,true);
      ObjectSetInteger(chart_ID,nname,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(chart_ID,nname,OBJPROP_HIDDEN,true);
     }
   else
     {
      ObjectMove(chart_ID,nname,0,time1,price1);
      ObjectMove(chart_ID,nname,1,time2,price2);
     }

   ObjectSetInteger(chart_ID,nname,OBJPROP_LEVELS,levels);
   for(int i=0;i<levels;i++)
     {
      FIBO_prices[i]=NormalizeDouble((price1-price2)*FIBO_levels[i]+price2,_Digits);
      ObjectSetDouble(chart_ID,nname,OBJPROP_LEVELVALUE,i,FIBO_levels[i]);
      ObjectSetString(chart_ID,nname,OBJPROP_LEVELTEXT,i,"("+DoubleToString(100*FIBO_levels[i],1)+") "+DoubleToString(FIBO_prices[i],_Digits));
      ObjectSetInteger(chart_ID,nname,OBJPROP_LEVELCOLOR,i,cvet);
      ObjectSetInteger(chart_ID,nname,OBJPROP_LEVELWIDTH,i,wiDth);
      ObjectSetInteger(chart_ID,nname,OBJPROP_LEVELSTYLE,i,fibo_style);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFtoStr(ENUM_TIMEFRAMES TimeFrameInt)
  {
   string TimeFrame;
   if(TimeFrameInt==PERIOD_M1)TimeFrame="M1";
   if(TimeFrameInt==PERIOD_M2)TimeFrame="M2";
   if(TimeFrameInt==PERIOD_M3)TimeFrame="M3";
   if(TimeFrameInt==PERIOD_M4)TimeFrame="M4";
   if(TimeFrameInt==PERIOD_M5)TimeFrame="M5";
   if(TimeFrameInt==PERIOD_M6)TimeFrame="M6";
   if(TimeFrameInt==PERIOD_M10)TimeFrame="M10";
   if(TimeFrameInt==PERIOD_M12)TimeFrame="M12";
   if(TimeFrameInt==PERIOD_M15)TimeFrame="M15";
   if(TimeFrameInt==PERIOD_M30)TimeFrame="M20";
   if(TimeFrameInt==PERIOD_M30)TimeFrame="M30";
   if(TimeFrameInt==PERIOD_H1)TimeFrame="H1";
   if(TimeFrameInt==PERIOD_H2)TimeFrame="H2";
   if(TimeFrameInt==PERIOD_H3)TimeFrame="H3";
   if(TimeFrameInt==PERIOD_H4)TimeFrame="H4";
   if(TimeFrameInt==PERIOD_H6)TimeFrame="H6";
   if(TimeFrameInt==PERIOD_H8)TimeFrame="H8";
   if(TimeFrameInt==PERIOD_H12)TimeFrame="H12";
   if(TimeFrameInt==PERIOD_D1)TimeFrame="D1";
   if(TimeFrameInt==PERIOD_W1)TimeFrame="W1";
   if(TimeFrameInt==PERIOD_MN1)TimeFrame="MN1";
   return(TimeFrame);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MakeFibo(string   text)
  {
   ushort u_sep=StringGetCharacter(" ",0);
   int num_levels=StringSplit(text,u_sep,fibo_txt);
   ArrayResize(FIBO_levels,num_levels);
   ArrayResize(FIBO_prices,num_levels);
   for(int i=0;i<num_levels;i++)
      FIBO_levels[i]=NormalizeDouble(StringToDouble(fibo_txt[i])/100,3);
   ArraySort(FIBO_levels);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects()
  {
   ObjectsDeleteAll(chart_ID,Label_prefix,-1,-1);
   ChartRedraw(chart_ID);
  }
//+------------------------------------------------------------------+
