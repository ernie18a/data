//+------------------------------------------------------------------+
//|                                            HL Next Activator.mq4 |
//|                                                             Rosh |
//|                                       http://fx.winm.ru/book.htm |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://fx.winm.ru/book.htm"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int       ActivatorPeriod=3;
extern int       useFullPeriods=1;
//---- buffers
double SellActivator[];
double BuyActivator[];
int first,counterPeriod;
int DelimeterArray[30];
//+------------------------------------------------------------------+
//| Получим следующий период                                         |
//+------------------------------------------------------------------+
string GetNextPeriod(int __Period)
  {
   string nextPeriod="";
//---- 
   switch(__Period)
     {
      case 5: nextPeriod="H1"; break;
      case 15: nextPeriod="H1"; break;
      case 30: nextPeriod="H4"; break;
      case 60: nextPeriod="H4"; break;
      case 240: nextPeriod="D1"; break;
      case 1440: nextPeriod="W1"; break;
      case 10080: nextPeriod="M"; break;
      default: Print("Недопустимый период!!!");
     }
//----
   return(nextPeriod);
  }
//+------------------------------------------------------------------+
//| Проверим - разделитель диапазона или нет                         |
//+------------------------------------------------------------------+
bool isDelimeter(int __Period,int _shift)
  {
   bool result=false;
//---- 
   switch(__Period)
     {
      case 5:result=(TimeMinute(Time[_shift])==0); break;
      case 15:result=(TimeMinute(Time[_shift])==0); break;
      case 30:result=(TimeMinute(Time[_shift])==0)&& MathMod(TimeHour(Time[_shift]),4.0)==0.0; break;
      case 60:result=(TimeMinute(Time[_shift])==0)&& MathMod(TimeHour(Time[_shift]),4.0)==0.0;break;
      case 240:result=(TimeMinute(Time[_shift])==0) && (TimeHour(Time[_shift])==0); break;
      case 1440:result=(TimeDayOfWeek(Time[_shift])==1) && (TimeHour(Time[_shift])==0); break;
      case 10080:result=(TimeDay(Time[_shift])==1) || ((TimeDay(Time[_shift])==2 && TimeDay(Time[_shift+1])!=1)) || ((TimeDay(Time[_shift])==3 && TimeDay(Time[_shift+1])!=2)); break;
      default: Print("Недопустимый период!!!");
     }
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Вычислить средний High за  ActivatorPeriod периодов              |
//+------------------------------------------------------------------+
double AverageHigh(int _shift)
  {
   double AveragePeriodHigh=0.0,tempHigh;
   int cnt=_shift;
   first=0;
//---- 
   counterPeriod=0;
   while(counterPeriod<ActivatorPeriod+useFullPeriods)
     {
      while(!isDelimeter(Period(),cnt)) cnt++;
      if(first==0) first=cnt;
      DelimeterArray[counterPeriod]=cnt;
      cnt++;
      counterPeriod++;
     }
   cnt--;
   for(cnt=ActivatorPeriod-1;cnt>0;cnt--)
     {
      tempHigh=High[Highest(NULL,0,MODE_HIGH,DelimeterArray[cnt]-DelimeterArray[cnt-1],DelimeterArray[cnt-1]+1)];
      AveragePeriodHigh=AveragePeriodHigh+tempHigh;
     }
   if(useFullPeriods==1)
     {
      tempHigh=High[Highest(NULL,0,MODE_HIGH,DelimeterArray[ActivatorPeriod]-DelimeterArray[ActivatorPeriod-1],DelimeterArray[ActivatorPeriod-1]+1)];
      AveragePeriodHigh=AveragePeriodHigh+tempHigh;
      AveragePeriodHigh=AveragePeriodHigh/NormalizeDouble(ActivatorPeriod,0);
     }
   else
     {
      tempHigh=High[Highest(NULL,0,MODE_HIGH,DelimeterArray[0]-_shift,_shift)];
      AveragePeriodHigh=AveragePeriodHigh+tempHigh;
      AveragePeriodHigh=AveragePeriodHigh/NormalizeDouble(ActivatorPeriod,0);
     }
//----
   return(AveragePeriodHigh);
  }
//+------------------------------------------------------------------+
//| Вычислить средний Low за  ActivatorPeriod периодов              |
//+------------------------------------------------------------------+
double AverageLow(int _shift)
  {
   double AveragePeriodLow=0.0,tempLow;
   int cnt=_shift;
   first=0;
//---- 
   counterPeriod=0;
   while(counterPeriod<ActivatorPeriod+useFullPeriods)
     {
      while(!isDelimeter(Period(),cnt)) cnt++;
      if(first==0) first=cnt;
      DelimeterArray[counterPeriod]=cnt;
      cnt++;
      counterPeriod++;
     }
   cnt--;
   for(cnt=ActivatorPeriod-1;cnt>0;cnt--)
     {
      tempLow=Low[Lowest(NULL,0,MODE_LOW,DelimeterArray[cnt]-DelimeterArray[cnt-1],DelimeterArray[cnt-1]+1)];
      AveragePeriodLow=AveragePeriodLow+tempLow;
     }
   if(useFullPeriods==1)
     {
      tempLow=Low[Lowest(NULL,0,MODE_LOW,DelimeterArray[ActivatorPeriod]-DelimeterArray[ActivatorPeriod-1],DelimeterArray[ActivatorPeriod-1]+1)];
      AveragePeriodLow=AveragePeriodLow+tempLow;
      AveragePeriodLow=AveragePeriodLow/NormalizeDouble(ActivatorPeriod,0);
     }
   else
     {
      tempLow=Low[Lowest(NULL,0,MODE_LOW,DelimeterArray[0]-_shift,_shift)];
      AveragePeriodLow=AveragePeriodLow+tempLow;
      AveragePeriodLow=AveragePeriodLow/NormalizeDouble(ActivatorPeriod,0);
     }
//----
   return(AveragePeriodLow);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,SellActivator);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,BuyActivator);
   SetIndexEmptyValue(1,0.0);
   if(useFullPeriods!=0) useFullPeriods=1;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int cnt,limit=0;
   if(Period()>PERIOD_D1)
     {
      Print("Use D1 or lesser imeframes");
      return(-1);
     }

   if(counted_bars<0) return(-1);
   if(counted_bars>0) limit=Bars-counted_bars;
   if(counted_bars==0)
     {
      // найти первый и второй разделитель и установить limit
      cnt=Bars-1;
      while(!isDelimeter(Period(),cnt)) cnt--;
      first=cnt;
      cnt--;
      counterPeriod=0;
      while(counterPeriod<ActivatorPeriod)
        {
         while(!isDelimeter(Period(),cnt)) cnt--;
         cnt--;
         counterPeriod++;
        }
      cnt++;
      limit=cnt;
     }
//---- 
   for(int shift=limit;shift>=0;shift--)
     {
      if(Close[shift]>AverageHigh(shift))
        {
         SellActivator[shift]=AverageLow(shift);
         BuyActivator[shift]=0.0;
         continue;
        }
      if(Close[shift]<AverageLow(shift))
        {
         BuyActivator[shift]=AverageHigh(shift);
         SellActivator[shift]=0.0;
         continue;
        }
      if(BuyActivator[shift+1]!=0.0) BuyActivator[shift]=AverageHigh(shift);
      if(SellActivator[shift+1]!=0.0) SellActivator[shift]=AverageLow(shift);
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+
