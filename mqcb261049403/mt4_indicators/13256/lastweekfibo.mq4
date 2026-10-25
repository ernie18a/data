//+------------------------------------------------------------------+
//|                                                 LastWeekFibo.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- input parameters
extern int startWeekDayOfWeek=1; //Start Week Day 1 For East 7 For West
input ENUM_TIMEFRAMES minTimeFrames= PERIOD_H1; // Min Time Frames
input ENUM_TIMEFRAMES maxTimeFrames= PERIOD_D1; // Max Time Frames
input color TimeRangeColor=clrRed; //Time Range Line Color
input color PriceRangeColor=clrRed; //Price Range Line Color
input color PriceMarkColor=clrBlue; //Price Mark Color
input color GoldenSectionColor=clrBlue; //Golden Section Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(Period()>=minTimeFrames && Period()<=maxTimeFrames && Period()<PERIOD_W1)
     {
      return(INIT_SUCCEEDED);
        }else{
      Print("Init Failed TimeFrame Less than One Week");
      //return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,"LastWeekStartDateTime");
   ObjectDelete(0,"LastWeekEndDateTime");
   ObjectDelete(0,"LastWeekHighPrice");
   ObjectDelete(0,"LastWeekLowPrice");
   ObjectDelete(0,"LastWeekHighPriceValue");
   ObjectDelete(0,"LastWeekLowPriceValue");
   ObjectDelete(0,"FibooLastWeek");
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
//---
   LastWeekFibo();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| LastWeekFibo function                                            |
//+------------------------------------------------------------------+
void LastWeekFibo()
  {
/**
Calculate the start and end for week
East:Market From  Before Weeek Saturday（6）  00:00 To Last Week Friday（5） 23:59  
West:Market From  Before Weeek Friday（5） 00:00 To Last Week Thursday 23:59

A week of market began ( USA EAST UTC -5 ) 17:00 in  EST on Sunday, the market continues on Friday 17:00
**/
   datetime TimeCurrentDateTime=TimeCurrent();// Local DateTime
   datetime ToDayStartDateTime=StringToTime(TimeToString(TimeCurrent(),TIME_DATE));//  ToDay Start From 00:00;
//---
   datetime LastWeekEndDateTime=NULL;
   datetime LastWeekStartDateTime=NULL;
//---
   int ToDayWeek=TimeDayOfWeek(ToDayStartDateTime);
//--- 1st Day Of  Market
   if(ToDayWeek==startWeekDayOfWeek)
     {
      LastWeekEndDateTime=ToDayStartDateTime-2*24*60*60 -1;
      LastWeekStartDateTime=ToDayStartDateTime-9*24*60*60;
     }
   else
     {
      LastWeekEndDateTime=ToDayStartDateTime-(2+ToDayWeek-1)*24*60*60-1;
      LastWeekStartDateTime=ToDayStartDateTime-(9+ToDayWeek-1)*24*60*60;
     }
   if(Period()>=minTimeFrames && Period()<=maxTimeFrames && Period()<PERIOD_W1)
     {
      int StartShift=iBarShift(NULL,NULL,LastWeekEndDateTime,false);//Shift Number Of  End Date Time
      int EndShift=iBarShift(NULL,NULL,LastWeekStartDateTime,false);//Shift Number Of Start Date Time
      //---
      int ShiftCount=EndShift -StartShift+1;//PERIOD_D1/Period();// Current Period Shift Count
      //---
      int LastWeekHighPriceIndex=iHighest(NULL,NULL,MODE_HIGH,ShiftCount,StartShift);//High Price Shift Number
      int LastWeekLowPriceIndex=iLowest(NULL,NULL,MODE_LOW,ShiftCount,StartShift);//Low Price Shift Number
      //---
      double LastWeekHighPrice=iHigh(NULL,NULL,LastWeekHighPriceIndex);//High Price
      double LastWeekLowPrice=iLow(NULL,NULL,LastWeekLowPriceIndex);//Low Price
      //--- Time Range Line
      DrawVLine("LastWeekStartDateTime",Time[EndShift]);
      ObjectSetStyle("LastWeekStartDateTime","Time Range Line",TimeRangeColor,STYLE_SOLID,1);
      DrawVLine("LastWeekEndDateTime",Time[StartShift]);
      ObjectSetStyle("LastWeekEndDateTime","Time Range Line",TimeRangeColor,STYLE_SOLID,1);
      //--- Price Range Line
      DrawHLine("LastWeekHighPrice",LastWeekHighPrice);
      ObjectSetStyle("LastWeekHighPrice","Price Range Line",PriceRangeColor,STYLE_SOLID,1);
      DrawHLine("LastWeekLowPrice",LastWeekLowPrice);
      ObjectSetStyle("LastWeekLowPrice","Price Range Line",PriceRangeColor,STYLE_SOLID,1);
      //--- Price Value Mark
      DrawArrow("LastWeekHighPriceValue",Time[LastWeekHighPriceIndex],LastWeekHighPrice,6);
      ObjectSetStyle("LastWeekHighPriceValue","Price Value Mark ",PriceMarkColor,STYLE_SOLID,1);
      DrawArrow("LastWeekLowPriceValue",Time[LastWeekLowPriceIndex],LastWeekLowPrice,6);
      ObjectSetStyle("LastWeekLowPriceValue","Price Value Mark ",PriceMarkColor,STYLE_SOLID,1);
      //--- Golden Section
      if(LastWeekHighPriceIndex>LastWeekLowPriceIndex)
        {
         DrawFiboComplete("FibooLastWeek",Time[LastWeekHighPriceIndex],LastWeekHighPrice,Time[LastWeekLowPriceIndex],LastWeekLowPrice);
        }
      else
        {
         DrawFiboComplete("FibooLastWeek",Time[LastWeekLowPriceIndex],LastWeekLowPrice,Time[LastWeekHighPriceIndex],LastWeekHighPrice);
        }
      ObjectSetStyle("FibooLastWeek","Golden Section",GoldenSectionColor,STYLE_DOT,1);
      ObjectSetLevelStyle("FibooLastWeek","Golden Section",GoldenSectionColor,STYLE_SOLID,1);
     }
  }
//+------------------------------------------------------------------+
//| DrawHLine Function                                               |
//+------------------------------------------------------------------+
void DrawHLine(string hlineName,double price)
  {
   ObjectCreate(hlineName,OBJ_HLINE,0,NULL,price);
  }
//+------------------------------------------------------------------+
//| DrawVLine Function                                               |
//+------------------------------------------------------------------+
void DrawVLine(string vlineName,datetime time)
  {
   ObjectCreate(vlineName,OBJ_VLINE,0,time,NULL);
  }
//+------------------------------------------------------------------+
//|                DrawArrow Function                                |
//+------------------------------------------------------------------+
void DrawArrow(string arrowName,datetime time,double price,uint arrowCode)
  {
   ObjectCreate(arrowName,OBJ_ARROW,0,time,price);
   ObjectSet(arrowName,OBJPROP_ARROWCODE,arrowCode);
  }
//+------------------------------------------------------------------+
//| DrawFiboComplete Function From -100% To +100%                    | 
//+------------------------------------------------------------------+
void DrawFiboComplete(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   ObjectCreate(fiboName,OBJ_FIBO,0,firstTime,firstPrice,secondTime,secondPrice);
//---
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,25);
//---
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+18,-1.000);ObjectSetFiboDescription(fiboName,+18,"-100.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+17,-0.764);ObjectSetFiboDescription(fiboName,+17,"-76.4%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+16,-0.618);ObjectSetFiboDescription(fiboName,+16,"-61.8%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+15,-0.50);ObjectSetFiboDescription(fiboName,+15,"-50.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+14,-0.382);ObjectSetFiboDescription(fiboName,+14,"-38.2%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+13,-0.236);ObjectSetFiboDescription(fiboName,+13,"-23.6%% = %$");
//---
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,0.000);ObjectSetFiboDescription(fiboName,0,"00.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,0.236);ObjectSetFiboDescription(fiboName,1,"23.6%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,0.382);ObjectSetFiboDescription(fiboName,2,"38.2%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.500);ObjectSetFiboDescription(fiboName,3,"50.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,0.618);ObjectSetFiboDescription(fiboName,4,"61.8%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,0.764);ObjectSetFiboDescription(fiboName,5,"76.4%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,1.000);ObjectSetFiboDescription(fiboName,6,"100.0%% = %$");
//---
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+7,1.236);ObjectSetFiboDescription(fiboName,7,"123.6%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+8,1.382);ObjectSetFiboDescription(fiboName,8,"138.2%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+9,1.50);ObjectSetFiboDescription(fiboName,9,"150.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+10,1.618);ObjectSetFiboDescription(fiboName,10,"161.8%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+11,1.764);ObjectSetFiboDescription(fiboName,11,"176.4%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+12,2.000);ObjectSetFiboDescription(fiboName,12,"200.0%% = %$");
   ObjectSet(fiboName,OBJPROP_RAY,true);
  }
//+------------------------------------------------------------------+
//| DrawFiboSimple Function From 0% To +100%                         | 
//+------------------------------------------------------------------+
void DrawFiboSimple(string fiboName,datetime firstTime,double firstPrice,datetime secondTime,double secondPrice)
  {
   ObjectCreate(fiboName,OBJ_FIBO,0,firstTime,firstPrice,secondTime,secondPrice);
   ObjectSet(fiboName,OBJPROP_FIBOLEVELS,20);
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+0,0.000);ObjectSetFiboDescription(fiboName,0,"00.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+1,0.236);ObjectSetFiboDescription(fiboName,1,"23.6%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+2,0.382);ObjectSetFiboDescription(fiboName,2,"38.2%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+3,0.500);ObjectSetFiboDescription(fiboName,3,"50.0%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+4,0.618);ObjectSetFiboDescription(fiboName,4,"61.8%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+5,0.764);ObjectSetFiboDescription(fiboName,5,"76.4%% = %$");
   ObjectSet(fiboName,OBJPROP_FIRSTLEVEL+6,1.000);ObjectSetFiboDescription(fiboName,6,"100.0%% = %$");
   ObjectSet(fiboName,OBJPROP_RAY,true);
  }
//+------------------------------------------------------------------+
//| ObjectSetStyle Function                                          |
//+------------------------------------------------------------------+
void ObjectSetStyle(string objectName,string devation,color _color,uint style,uint width)
  {
//ObjectSet(objectName,OBJPROP_DEVIATION,ObjectDescription(devation));
   ObjectSet(objectName,OBJPROP_COLOR,_color);
   ObjectSet(objectName,OBJPROP_STYLE,style);
   ObjectSet(objectName,OBJPROP_WIDTH,width);
  }
//+------------------------------------------------------------------+
//| ObjectSetLevelStyle Function                                     |
//+------------------------------------------------------------------+
void ObjectSetLevelStyle(string objectName,string devation,color _color,uint style,uint width)
  {
   ObjectSet(objectName,OBJPROP_LEVELCOLOR,_color);
   ObjectSet(objectName,OBJPROP_LEVELSTYLE,style);
   ObjectSet(objectName,OBJPROP_LEVELWIDTH,width);
  }
//+------------------------------------------------------------------+
