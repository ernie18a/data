//+------------------------------------------------------------------+
//|                                           SlopeDirection_MTF.mq4 |
//|                      Copyright © 2007, ASystem Group             |
//|                                        asystem2000@rambler.ru    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Asystem2000"
#property link      "asystem2000@rambler.ru"

#property indicator_chart_window 
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern int       TimeFrame=0;
extern int       period=80; 
extern int       method=3;                         // MODE_SMA 
extern int       price=0;                          // PRICE_CLOSE 
extern string    Note="Можете поменять имя инидикатора, если не совпадает";
extern string    Indicator="Slope Direction Line";

//---- buffers
double B_Up[];
double B_Dn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  if (TimeFrame!=0)
  { 
  if (TimeFrame<Period())
     {
       Alert("Настраиваемый таймфрейм должен быть больше текущего или равен 0");
       deinit();
       return(0);
     }
  }
  bool OK_Period=false;   
  switch (TimeFrame)
  {
    case 0:OK_Period=true;break;
    case 1:OK_Period=true;break;
    case 5:OK_Period=true;break;
    case 15:OK_Period=true;break;
    case 30:OK_Period=true;break;
    case 60:OK_Period=true;break;
    case 240:OK_Period=true;break;
    case 1440:OK_Period=true;break;
    case 10080:OK_Period=true;break;
    case 43200:OK_Period=true;break;
  }
  if (OK_Period==false)
     {
       Alert("Вы ввели некорректную цифру таймфрейма");
       deinit();
       return(0);
     }
  
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0,B_Up);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1,B_Dn);
   
   IndicatorShortName("Slope Direction Line - MTF ("+period+")");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit;
   if (TimeFrame>0) limit=Bars-counted_bars-(TimeFrame/Period());
   else limit=Bars-counted_bars-1;
   int    C_time;
   int    Bar_Shift;
   if (limit==0) return(0);
//----
   int i=limit;
   while(i>=0)
   {
     C_time=Time[i];
     Bar_Shift=iBarShift(NULL,TimeFrame,C_time,false);
     B_Up[i]=iCustom(NULL,TimeFrame,Indicator,period,method,price,0,Bar_Shift);
     B_Dn[i]=iCustom(NULL,TimeFrame,Indicator,period,method,price,1,Bar_Shift); 
     i--;
   }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+