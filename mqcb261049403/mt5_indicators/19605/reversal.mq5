//+------------------------------------------------------------------+
//|                                          Indicator: reversal.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Sergey Vradiy"
#property version   "1.00"
#property description ""

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 3
#property indicator_color1 0x0000FF
#property indicator_label1 "Sell"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 3
#property indicator_color2 0xFFAA00
#property indicator_label2 "Buy"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

input int Interval=10;
datetime time_alert;     //used when sending alert
input bool Send_Email=true;
double myPoint; //initialized in OnInit
double High[];
double Close[];
double Open[];
double Low[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void myAlert(string type,string message)
  {
   if(type=="print")
      Print(message);
   else if(type=="error")
     {
      Print(type+" | reversal @ "+Symbol()+","+(string)Period()+" | "+message);
     }
   else if(type=="order")
     {
     }
   else if(type=="modify")
     {
     }
   else if(type=="indicator")
     {
      if(Send_Email) SendMail("reversal",type+" | reversal @ "+Symbol()+","+(string)Period()+" | "+message);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(string objname,double price,int count,int start_index) //creates or modifies existing object if necessary
  {
   if((price<0) && ObjectFind(0,objname)>=0)
     {
      ObjectDelete(0,objname);
     }
   else if(ObjectFind(0,objname)>=0 && ObjectGetInteger(0,objname,OBJPROP_TYPE)==OBJ_TREND)
     {
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(Symbol(),Period(),0,start_index+count,Time);
      ObjectSetInteger(0,objname,OBJPROP_TIME,Time[start_index]);
      ObjectSetDouble(0,objname,OBJPROP_PRICE,price);
      ObjectSetInteger(0,objname,OBJPROP_TIME,1,Time[start_index+count-1]);
      ObjectSetDouble(0,objname,OBJPROP_PRICE,1,price);
     }
   else
     {
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(Symbol(),Period(),0,start_index+count,Time);
      ObjectCreate(0,objname,OBJ_TREND,0,Time[start_index],price,Time[start_index+count-1],price);
      ObjectSetInteger(0,objname,OBJPROP_RAY_LEFT,0);
      ObjectSetInteger(0,objname,OBJPROP_RAY_RIGHT,0);
      ObjectSetInteger(0,objname,OBJPROP_COLOR,C'0x00,0x00,0xFF');
      ObjectSetInteger(0,objname,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,objname,OBJPROP_WIDTH,2);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Support(int time_interval,bool fixed_tod,int hh,int mm,bool draw,int shift)
  {
   int start_index=shift;
   int count=time_interval/PeriodSeconds();
   if(fixed_tod)
     {
      datetime start_time;
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(Symbol(),Period(),0,Bars(Symbol(),Period())-count,Time);
      if(shift==0)
         start_time=TimeCurrent();
      else
         start_time=Time[shift-1];
      datetime dt=StringToTime(TimeToString(start_time,TIME_DATE)+" "+(string)hh+":"+(string)mm); //closest time hh:mm
      if(dt>start_time)
         dt-=86400; //go 24 hours back
      int dt_index = iBarShift(Symbol(), Period(), dt, true);
      datetime dt2 = dt;
      while(dt_index<0 && dt>Time[Bars(Symbol(),Period())-1-count]) //bar not found => look a few days back
        {
         dt-=86400; //go 24 hours back
         dt_index=iBarShift(Symbol(),Period(),dt,true);
        }
      if(dt_index<0) //still not found => find nearest bar
         dt_index =iBarShift(Symbol(), Period(), dt2, false);
      start_index=dt_index+1; //bar after S/R opens at dt
     }
   double _Low[];
   ArraySetAsSeries(_Low,true);
   CopyLow(Symbol(),Period(),start_index,count,_Low);
   double ret=_Low[ArrayMinimum(_Low,0,count)];
   if(draw) DrawLine("Support",ret,count,start_index);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Resistance(int time_interval,bool fixed_tod,int hh,int mm,bool draw,int shift)
  {
   int start_index=shift;
   int count=time_interval/PeriodSeconds();
   if(fixed_tod)
     {
      datetime start_time;
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(Symbol(),Period(),0,Bars(Symbol(),Period())-count,Time);
      if(shift==0)
         start_time=TimeCurrent();
      else
         start_time=Time[shift-1];
      datetime dt=StringToTime(TimeToString(start_time,TIME_DATE)+" "+(string)hh+":"+(string)mm); //closest time hh:mm
      if(dt>start_time)
         dt-=86400; //go 24 hours back
      int dt_index = iBarShift(Symbol(), Period(), dt, true);
      datetime dt2 = dt;
      while(dt_index<0 && dt>Time[Bars(Symbol(),Period())-1-count]) //bar not found => look a few days back
        {
         dt-=86400; //go 24 hours back
         dt_index=iBarShift(Symbol(),Period(),dt,true);
        }
      if(dt_index<0) //still not found => find nearest bar
         dt_index =iBarShift(Symbol(), Period(), dt2, false);
      start_index=dt_index+1; //bar after S/R opens at dt
     }
   double _High[];
   ArraySetAsSeries(_High,true);
   CopyHigh(Symbol(),Period(),start_index,count,_High);
   double ret=_High[ArrayMaximum(_High,0,count)];
   if(draw) DrawLine("Resistance",ret,count,start_index);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time,bool exact=false)
  {
   datetime LastBar;
   if(!SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE,LastBar))
     {
      datetime opentimelastbar[1];
      if(CopyTime(symbol,timeframe,0,1,opentimelastbar)==1)
         LastBar=opentimelastbar[0];
      else
         return(-1);
     }
   int shift=Bars(symbol,timeframe,time,LastBar);
   datetime checkcandle[1];
   if(CopyTime(symbol,timeframe,time,1,checkcandle)==1)
     {
      if(checkcandle[0]==time)
         return(shift-1);
      else if(exact && time>checkcandle[0]+PeriodSeconds(timeframe))
         return(-1);
      else
         return(shift);
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,Buffer1);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_ARROW,242);
   SetIndexBuffer(1,Buffer2);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(1,PLOT_ARROW,241);
//initialize myPoint
   myPoint=Point();
   if(Digits()==5 || Digits()==3)
     {
      myPoint*=10;
     }
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
   int limit=rates_total-prev_calculated;
//--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Buffer2,true);
//--- initial zero
   if(prev_calculated<1)
     {
      ArrayInitialize(Buffer1,0);
      ArrayInitialize(Buffer2,0);
     }
   else
      limit++;
   datetime Time[];

   if(CopyHigh(Symbol(), PERIOD_H6, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High,true);
   if(CopyClose(Symbol(), PERIOD_H6, 0, rates_total, Close) <= 0) return(rates_total);
   ArraySetAsSeries(Close,true);
   if(CopyOpen(Symbol(), PERIOD_H6, 0, rates_total, Open) <= 0) return(rates_total);
   ArraySetAsSeries(Open,true);
   if(CopyLow(Symbol(), PERIOD_H6, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low,true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time,true);
//--- main loop
   for(int i=limit-1; i>=0; i--)
     {
      if(i>=MathMin(5000-1,rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
                                                        //Indicator Buffer 1
      if(High[1+i]==Resistance(Interval*PeriodSeconds(),false,00,00,false,i) //Candlestick High is equal to Resistance
         && Close[1+i]<Open[1+i]//Candlestick Close < Candlestick Open
         )
        {
         Buffer1[i]=High[i]; //Set indicator value at Candlestick High
         if(i==1 && Time[1]!=time_alert) myAlert("indicator","Sell"); //Alert on next bar open
         time_alert=Time[1];
        }
      else
        {
         Buffer1[i]=0;
        }
      //Indicator Buffer 2
      if(Low[1+i]==Support(Interval*PeriodSeconds(),false,00,00,false,i) //Candlestick Low is equal to Support
         && Close[1+i]>Open[1+i]//Candlestick Close > Candlestick Open
         )
        {
         Buffer2[i]=Low[i]; //Set indicator value at Candlestick Low
         if(i==1 && Time[1]!=time_alert) myAlert("indicator","Buy"); //Alert on next bar open
         time_alert=Time[1];
        }
      else
        {
         Buffer2[i]=0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
