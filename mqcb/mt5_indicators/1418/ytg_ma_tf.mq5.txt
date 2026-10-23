//+------------------------------------------------------------------+
//|                                                    ytg_MA_TF.mq5 |
//|                                               Yuriy Tokman (YTG) |
//|                                                http://ytg.com.ua |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua"
#property version   "1.00"
#property  description "ytg_MA_TF"
#property description " "
#property description "site:  http://ytg.com.ua"
#property description " "
#property description "mail:  ytg@ytg.com.ua "
#property description " "
#property description "Skype:  yuriy.g.t"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  3
#property indicator_label1  "ytg_MA_TF"
#property indicator_style1  STYLE_SOLID

input ENUM_TIMEFRAMES      TimeFrame = PERIOD_H4;//Chart period
input int                  Period_MA = 5;//Moving Average period
input ENUM_MA_METHOD       Method    = MODE_SMA;//method of averaging
input ENUM_APPLIED_PRICE   Applied   = PRICE_HIGH;//Applied price

double                     MaBuffer_High[];//indicator buffer
double                     MaArray_TF2[];
int                        MaHandle_High;

string label_name="ytg_1";
string label_nama="ytg_2";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,MaBuffer_High,INDICATOR_DATA);//values of the calculated indicator
   ArraySetAsSeries(MaBuffer_High,true);//Set the AS_SERIES flag for the specified object of dynamic array. The array elements indexing as in time series.
   ArraySetAsSeries(MaArray_TF2,true);//Set the AS_SERIES flag for the specified object of dynamic array. The array elements indexing as in time series.
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"ytg_MA_TF("+string(Period_MA)+")");//Indicator short name
   
   MaHandle_High=iMA(NULL,TimeFrame,Period_MA,0,Method,Applied);// indicator handle   
//----   
   ytg_label2();ytg_label1();                                      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectFind(0,label_name)>=0)ObjectDelete(0,label_name);
   if(ObjectFind(0,label_nama)>=0)ObjectDelete(0,label_nama);      
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
 ArraySetAsSeries(time,true);//the array elements indexing as in time series.

 int bars_TF2=Bars(NULL,TimeFrame);//Returns the count of history bars by the current symbol and time frame.
 if(bars_TF2<Period_MA)return(0);

 int calculated_TF2;
 calculated_TF2=BarsCalculated(MaHandle_High);//Returns the count of the calculated data for the requested indicator.
 if(calculated_TF2<bars_TF2)
  {
   Print("Not all data of MaHandle_High has been calculated (",calculated_TF2," bars). Error",GetLastError());
   return(0);
  }

 int limit;
 if(prev_calculated<=0 || prev_calculated>rates_total) limit=rates_total-1;
 else limit=rates_total-prev_calculated;

 for(int i=limit;i>=0 && !IsStopped();i--)
  {
   datetime tempTimeArray_TF2[];
   CopyTime(NULL,TimeFrame,calculated_TF2-1,1,tempTimeArray_TF2);
   
   if(time[i]<tempTimeArray_TF2[0])
    {
     MaBuffer_High[i]=EMPTY_VALUE;
     continue;
    }

   if(CopyBuffer(MaHandle_High,0,time[i],1,MaArray_TF2)<=0)
    {
     Print("Getting MA TF failed! Error",GetLastError());
     return(0);
    }
   else MaBuffer_High[i]=MaArray_TF2[0];
  }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---
void ytg_label1()
 {
  if(ObjectFind(0,label_name)>=0)ObjectDelete(0,label_name);   
  ObjectCreate(0,label_name,OBJ_LABEL,0,0,0);  //--- create the Label object
  ObjectSetInteger(0,label_name,OBJPROP_CORNER,CORNER_LEFT_LOWER);  //--- set binding to an angle of the chart                  
  ObjectSetInteger(0,label_name,OBJPROP_XDISTANCE,10);  //--- set X coordinate
  ObjectSetInteger(0,label_name,OBJPROP_YDISTANCE,25);  //--- set Y coordinate
  ObjectSetInteger(0,label_name,OBJPROP_COLOR,clrLime);  //--- set text color
  ObjectSetString(0,label_name,OBJPROP_TEXT,"YTG.COM.UA");  //--- set text for the Label object
  ObjectSetString(0,label_name,OBJPROP_FONT,"Arial Black");  //--- set font of the inscription
  ObjectSetInteger(0,label_name,OBJPROP_FONTSIZE,10);  //--- set font size
  ObjectSetInteger(0,label_name,OBJPROP_SELECTABLE,false);  //--- disable selection of the object using a mouse     
  ObjectSetInteger(0,label_nama,OBJPROP_BACK,false);//--- background object  
  ChartRedraw(0);  //--- draw on the chart 
 }
//---
void ytg_label2()
 {
  if(ObjectFind(0,label_nama)>=0)ObjectDelete(0,label_nama);// the object already exists - delete it     
  ObjectCreate(0,label_nama,OBJ_RECTANGLE_LABEL,0,0,0);//--- create the Label object     
  ObjectSetInteger(0,label_nama,OBJPROP_CORNER,CORNER_LEFT_LOWER);//--- set binding to an angle of the chart                    
  ObjectSetInteger(0,label_nama,OBJPROP_XDISTANCE,5);//--- set X coordinate  
  ObjectSetInteger(0,label_nama,OBJPROP_YDISTANCE,26);//--- set Y coordinate  
  ObjectSetInteger(0,label_nama,OBJPROP_BGCOLOR,clrGray);//--- set color   
  ObjectSetInteger(0,label_nama,OBJPROP_BORDER_TYPE,BORDER_RAISED);//set border type
  ObjectSetInteger(0,label_nama,OBJPROP_XSIZE,102);// set the size by х coordinate
  ObjectSetInteger(0,label_nama,OBJPROP_YSIZE,21);// set the size by y coordinate   
  ObjectSetInteger(0,label_nama,OBJPROP_SELECTABLE,false);//--- disable selection of the object using a mouse
  ObjectSetInteger(0,label_nama,OBJPROP_BACK,false);//--- background object        
  ChartRedraw(0);//--- draw on the chart 
 }