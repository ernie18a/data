//+------------------------------------------------------------------+
//|                                                FlatExecution.mq5 |
//|                                                              JLY |
//|                                               "Исполнение флэта" |
//+------------------------------------------------------------------+
#property copyright "JLY"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
input ENUM_TIMEFRAMES accuracyTF=PERIOD_CURRENT; //Точность
input color Execut=Blue;                         //Цвет исполнения
input color NotExecut=Red;                       //Цвет неисполнения
input int sub_window=0;                          //Подокно графика
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   ObjectsDeleteAll(0,sub_window,OBJ_ARROW);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,sub_window,OBJ_ARROW);
  }
//+------------------------------------------------------------------+
//| TFMigrate                                                        |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);

      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);
      default: return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//| iBarShift                                                        |
//+------------------------------------------------------------------+
int iBarShift(string symbol,int tf,datetime time,bool exact=false)
  {
   if(time<0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[],time1;
   CopyTime(symbol,timeframe,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      if(ArraySize(Arr)>2) return(ArraySize(Arr)-1);
      if(time<time1) return(1);
      else return(0);
     }
   else return(-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[])
  {
   string name;
   long time1NEW,time2NEW;
   double price1NEW,price2NEW,price3;

   for(int i=0;i<ObjectsTotal(0,sub_window,-1);i++)
     {
      if(ObjectGetInteger(0,ObjectName(0,i,sub_window,-1),OBJPROP_TYPE,0)==OBJ_TREND)
        {
         name=ObjectName(0,i,sub_window,-1);
         //--- забирает данные линии
         price1NEW = ObjectGetDouble(0,name,OBJPROP_PRICE,0);
         price2NEW = ObjectGetDouble(0,name,OBJPROP_PRICE,1);
         time1NEW  = ObjectGetInteger(0,name,OBJPROP_TIME,0);
         time2NEW  = ObjectGetInteger(0,name,OBJPROP_TIME,1);
         price3=price2NEW-(price1NEW-price2NEW);
         //--- задает параметры   
         ObjectSetInteger(0,name,OBJPROP_COLOR,Execut);
         ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
         //--- расчет времени исполнения через бары
         datetime Time[];double Open[];
         int bars=Bars(_Symbol,accuracyTF);
         ArraySetAsSeries(Time,true);
         CopyTime(Symbol(),accuracyTF,0,bars,Time);
         datetime time01=datetime(time1NEW);
         datetime time02=datetime(time2NEW);//Перевод секунд в дату времени
         int shift01=iBarShift(_Symbol,accuracyTF,time01,false);//Перевод 1-й точки линии в бар
         int shift02=iBarShift(_Symbol,accuracyTF,time02,false);//Перевод 2-й точки линии в бар
         int timeCHANGE=shift01-shift02;//разница между 1-й и 2-й точкой линии
         datetime T1970=D'1970.00.00 00:00:0';
         int timeBAR1970=iBarShift(_Symbol,accuracyTF,T1970,false);
         int timeBAR;
         timeBAR=(shift02-timeCHANGE);//прибавить разницу ко 2-й точке
         if(timeBAR<0)
           {//если бар меньше нуля
            timeBAR=timeBAR1970;
            ObjectSetInteger(0,name,OBJPROP_COLOR,NotExecut);
            ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
           }
         //--- перевод времени исполнения из бара в секунды
         long timeBARsec=Time[timeBAR];
         //--- описание для трендовой линии
         ObjectSetString(0,name,OBJPROP_TEXT,IntegerToString(timeCHANGE-1)+" bars");
         //---
         ArraySetAsSeries(Open,true);
         CopyOpen(Symbol(),accuracyTF,0,bars,Open);
         //--- удаление значков исполнения
         ObjectDelete(0,"Execution "+name);ObjectDelete(0,"ExecutionOnLine "+name);
         //--- перевод описания значка
         string ET=TimeToString(timeBARsec,TIME_DATE|TIME_MINUTES);
         string EP=DoubleToString(Open[timeBAR],4);
         //--- отрисовка визуального значка исполнения, на линии
         ObjectCreate(0,"ExecutionOnLine "+name,OBJ_ARROW,sub_window,timeBARsec,price3);
         ObjectSetInteger(0,"ExecutionOnLine "+name,OBJPROP_COLOR,Execut);
         ObjectSetInteger(0,"ExecutionOnLine "+name,OBJPROP_ARROWCODE,85);
         ObjectSetInteger(0,"ExecutionOnLine "+name,OBJPROP_BACK,false);
         ObjectSetString(0,"ExecutionOnLine "+name,OBJPROP_TEXT,ET);
         //--- отрисовка сигнального значка исполнения, на баре
         ObjectCreate(0,"Execution "+name,OBJ_ARROW,0,timeBARsec,Open[timeBAR]);
         ObjectSetInteger(0,"Execution "+name,OBJPROP_COLOR,Execut);
         ObjectSetInteger(0,"Execution "+name,OBJPROP_ARROWCODE,119);
         ObjectSetInteger(0,"Execution "+name,OBJPROP_BACK,false);
         ObjectSetString(0,"Execution "+name,OBJPROP_TEXT,ET+" * "+EP);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+