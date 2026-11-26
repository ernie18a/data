// Rabbit
#property copyright "Jon Katana, VDV Soft (vdv_2001@mail.ru)"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1

input int Yesterday=0;
input int Levels=20;
input int FontSize=16;
input color FontColor=White;
input color LineColor=DeepSkyBlue;
string Prefix="Rabbit ";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(0);
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
   MqlRates rates[];
   string obj_name;
   int shift=Yesterday+1;
   if(CopyRates(NULL,PERIOD_D1,0,shift+1,rates)<=0)
     {
      return(0);
     }
   double S=NormalizeDouble((rates[0].high-rates[0].low)*0.236,_Digits);
   double D=NormalizeDouble(rates[0].low+(rates[0].high-rates[0].low)*(0.618-Levels*0.236),_Digits);
   obj_name=Prefix+"S";
   if(ObjectFind(0,obj_name)==-1)
     {
      ObjectCreate(0,obj_name,OBJ_LABEL,0,0,0);
     }
   ObjectSetInteger(0,obj_name,OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,obj_name,OBJPROP_YDISTANCE,int(MathCeil(1.5*FontSize)));
   ObjectSetInteger(0,obj_name,OBJPROP_COLOR,FontColor);
   ObjectSetInteger(0,obj_name,OBJPROP_FONTSIZE,FontSize);
   ObjectSetString(0,obj_name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,obj_name,OBJPROP_TEXT,"S = "+DoubleToString(S,_Digits));
   for(int z=0; z<Levels*2; z++)
     {
      double U=NormalizeDouble(D+(rates[0].high-rates[0].low)*z*0.236,_Digits);
      obj_name=Prefix+"U"+string(z);
      if(ObjectFind(0,obj_name)==-1)
        {
         ObjectCreate(0,obj_name,OBJ_TEXT,0,time[rates_total-1],U);
        }
      ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,time[rates_total-1]-PeriodSeconds(PERIOD_CURRENT));
      ObjectSetDouble(0,obj_name,OBJPROP_PRICE,0,U);
      ObjectSetString(0,obj_name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,obj_name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,obj_name,OBJPROP_FONTSIZE,FontSize);
      ObjectSetInteger(0,obj_name,OBJPROP_COLOR,FontColor);
      ObjectSetString(0,obj_name,OBJPROP_TEXT,DoubleToString(U,_Digits));
      obj_name=Prefix+"U Line"+string(z);
      if(ObjectFind(0,obj_name)==-1)
        {
         ObjectCreate(0,obj_name,OBJ_HLINE,0,time[rates_total-1],U);
        }
      ObjectSetInteger(0,obj_name,OBJPROP_TIME,0,time[rates_total-1]);
      ObjectSetDouble(0,obj_name,OBJPROP_PRICE,0,U);
      ObjectSetInteger(0,obj_name,OBJPROP_COLOR,LineColor);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteObjectPrefix(Prefix);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjectPrefix(string prefix)
  {
   int i=0;
   string objname;
   for(i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      objname=ObjectName(0,i);
      if(StringFind(objname,prefix)==-1) continue;
      else ObjectDelete(0,objname);
     }
  }
//+------------------------------------------------------------------+