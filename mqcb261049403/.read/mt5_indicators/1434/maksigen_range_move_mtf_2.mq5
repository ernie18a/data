//+------------------------------------------------------------------+
//|                                          MaksiGen_Range_Move.mq4 |
//|                MaksiGen - MT3 by OlegVS ( olegvs2003@yahoo.com ) |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "MaksiGen - MT3 by OlegVS ( olegvs2003@yahoo.com )"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1


//---- input parameters

input int               Pfast          =  5;
input int               Pslow          =  8;
input double            K_RangeOpen    =1.4;
input ENUM_TIMEFRAMES   TimeFrame      =  0;
input string            UniqueID       = "MaksiGen1";
input color             HiColor1       = Silver;
input color             LoColor1       = Silver;
input color             HiColor2       = Silver;
input color             LoColor2       = Silver;
input color             Bar1Color      = OliveDrab;
input color             BarFastColor   = LightSkyBlue;
input color             BarSlowColor   = Blue;
input color             TrendHighColor = Gold;
input color             TrendLowColor  = Gold;
input color             SellStopColor  = Red;
input color             BuyStopColor   = Blue;

ENUM_TIMEFRAMES  tf;
double hi1, lo1, hi2, lo2, Range;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   if(TimeFrame <= Period()) tf = Period(); else tf = TimeFrame; 
//---- Objects
   ObjectCreate(0,UniqueID+"hi1",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"hi1",OBJPROP_COLOR,HiColor1); ObjectSetInteger(0,UniqueID+"hi1",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate(0,UniqueID+"lo1",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"lo1",OBJPROP_COLOR,LoColor1); ObjectSetInteger(0,UniqueID+"lo1",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate(0,UniqueID+"hi2",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"hi2",OBJPROP_COLOR,HiColor2); ObjectSetInteger(0,UniqueID+"hi2",OBJPROP_STYLE,STYLE_DASH);
   ObjectCreate(0,UniqueID+"lo2",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"lo2",OBJPROP_COLOR,LoColor2); ObjectSetInteger(0,UniqueID+"lo2",OBJPROP_STYLE,STYLE_DASH);

   ObjectCreate(0,UniqueID+"Bar#1",    OBJ_VLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"Bar#1",    OBJPROP_COLOR,Bar1Color   ); ObjectSetInteger(0,UniqueID+"Bar#1",    OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate(0,UniqueID+"Bar#Pfast",OBJ_VLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"Bar#Pfast",OBJPROP_COLOR,BarFastColor); ObjectSetInteger(0,UniqueID+"Bar#Pfast",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate(0,UniqueID+"Bar#Pslow",OBJ_VLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"Bar#Pslow",OBJPROP_COLOR,BarSlowColor); ObjectSetInteger(0,UniqueID+"Bar#Pslow",OBJPROP_STYLE,STYLE_DOT);

   ObjectCreate(0,UniqueID+"TrendHIGH",OBJ_TREND,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_COLOR,TrendHighColor); ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_STYLE,STYLE_SOLID); ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_RAY_RIGHT,1);
   ObjectCreate(0,UniqueID+"Trend_LOW",OBJ_TREND,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_COLOR,TrendLowColor ); ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_STYLE,STYLE_SOLID); ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_RAY_RIGHT,1);

   ObjectCreate(0,UniqueID+"SELLSTOP",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"SELLSTOP",OBJPROP_COLOR,SellStopColor); ObjectSetInteger(0,UniqueID+"SELLSTOP",OBJPROP_STYLE,STYLE_DOT);
   ObjectCreate(0,UniqueID+"BUY_STOP",OBJ_HLINE,0,0,0,0,0,0,0); ObjectSetInteger(0,UniqueID+"BUY_STOP",OBJPROP_COLOR,BuyStopColor ); ObjectSetInteger(0,UniqueID+"BUY_STOP",OBJPROP_STYLE,STYLE_DOT);
//----

}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit( const int reason )
{
//---- 
   deleteObj (UniqueID);
   
//----
   return;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double   &Open[],
                const double   &High[],
                const double   &Low[],
                const double   &Close[],
                const long     &TickVolume[],
                const long     &Volume[],
                const int      &Spread[])
{
   int copied;
   
   datetime TimesArray[]; //ArraySetAsSeries(timesArray,true);
   double HighArray[], LowArray[]; //ArraySetAsSeries(ratesArray,true);
   
   ArraySetAsSeries(HighArray,true);
   copied = CopyHigh(Symbol(),tf,Time[rates_total-1],Time[0],HighArray);
   if(copied <= 0) {Print("not all rates copied. Will try on next tick"); return(0);}
   
   ArraySetAsSeries(LowArray,true);
   copied = CopyLow(Symbol(),tf,Time[rates_total-1],Time[0],LowArray);
   if(copied <= 0) {Print("not all rates copied. Will try on next tick"); return(0);}
   
   ArraySetAsSeries(TimesArray,true);
   copied =  CopyTime(Symbol(),tf,Time[rates_total-1],Time[0],TimesArray);
   if(copied <= 0) {Print("not all times copied. Will try on next tick"); return(0);}

//---- 
   hi1 = Highest(HighArray,Pfast,1);
   lo1 = Lowest (LowArray ,Pfast,1);
   hi2 = Highest(HighArray,Pslow,1);
   lo2 = Lowest (LowArray ,Pslow,1);
   
   
//---- horizontal lines
   ObjectMove(0,UniqueID+"hi1",0,Time[Pfast-1],hi1);
   ObjectMove(0,UniqueID+"lo1",0,Time[Pfast-1],lo1);
   ObjectMove(0,UniqueID+"hi2",0,Time[Pslow-1],hi2);
   ObjectMove(0,UniqueID+"lo2",0,Time[Pslow-1],lo2);
//---- vertical lines
   ObjectMove(0,UniqueID+"Bar#1",    0,TimesArray[1]    ,HighArray[1]);
   ObjectMove(0,UniqueID+"Bar#Pfast",0,TimesArray[Pfast],HighArray[1]);
   ObjectMove(0,UniqueID+"Bar#Pslow",0,TimesArray[Pslow],HighArray[1]);
//---- trend lines
   ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_TIME,0,TimesArray[Pslow]); ObjectSetDouble(0,UniqueID+"TrendHIGH",OBJPROP_PRICE,0,hi2);
   ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_TIME,1,TimesArray[Pfast]); ObjectSetDouble(0,UniqueID+"TrendHIGH",OBJPROP_PRICE,1,hi1);

   ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_TIME,0,TimesArray[Pslow]); ObjectSetDouble(0,UniqueID+"Trend_LOW",OBJPROP_PRICE,0,lo2);
   ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_TIME,1,TimesArray[Pfast]); ObjectSetDouble(0,UniqueID+"Trend_LOW",OBJPROP_PRICE,1,lo1);

   if (hi1 - lo1 == hi2 - lo2)
   {
   Range = (hi1 - lo1)*K_RangeOpen;
   
   ObjectMove(0,UniqueID+"SELLSTOP",0,TimesArray[Pfast-1],lo1-Range);
   ObjectMove(0,UniqueID+"BUY_STOP",0,TimesArray[Pfast-1],hi1+Range);

   ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_TIME,0,TimesArray[Pslow-1]); ObjectSetDouble(0,UniqueID+"TrendHIGH",OBJPROP_PRICE,0,hi2);
   ObjectSetInteger(0,UniqueID+"TrendHIGH",OBJPROP_TIME,1,TimesArray[Pfast-1]); ObjectSetDouble(0,UniqueID+"TrendHIGH",OBJPROP_PRICE,1,hi1);

   ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_TIME,0,TimesArray[Pslow]-1); ObjectSetDouble(0,UniqueID+"Trend_LOW",OBJPROP_PRICE,0,lo2);
   ObjectSetInteger(0,UniqueID+"Trend_LOW",OBJPROP_TIME,1,TimesArray[Pfast]-1); ObjectSetDouble(0,UniqueID+"Trend_LOW",OBJPROP_PRICE,1,lo1);
   }

ChartRedraw();

return(rates_total);
}


//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double&array[],int range,int fromIndex)
{
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i<fromIndex+range;i++)
   {
      if(res<array[i]) res=array[i];
   }
//---
   return(res);
}
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double&array[],int range,int fromIndex)
{
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i<fromIndex+range;i++)
   {
      if(res>array[i]) res=array[i];
   }
//---
   return(res);
}
  
void deleteObj (string prefix)
{	
	string	name	= "";
	int		total	= ObjectsTotal(0) - 1;
	
	for(int i=total;i>=0;i--)
	{
	name = ObjectName(0,i);
	if(StringFind(name,prefix) >= 0) {ObjectDelete(0,name);}
	}
}      