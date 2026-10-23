//+------------------------------------------------------------------+ 
//|                                             VGridLine_Custom.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.10"
#property description "Временная координатная сетка. Шаг сетки - 1 день."
#property description "Индикатор работает на всех таймфреймах меньше дневного."
//---- количество индикаторных буферов 0
#property indicator_buffers 0 
//---- использовано ноль графических построений
#property indicator_plots   0
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для хранения значения, возврат которого OnCalculate() приведёт к пересчёту индикатора
#define DAILY_PERIOD_SECOND 86400 // Количество секунд в недельном дневном периоде
//+----------------------------------------------+
//|  Объявление перечисления часов суток         |
//+----------------------------------------------+
enum HOURS
  {
   ENUM_HOUR_0=0,   //0
   ENUM_HOUR_1,     //1
   ENUM_HOUR_2,     //2
   ENUM_HOUR_3,     //3
   ENUM_HOUR_4,     //4
   ENUM_HOUR_5,     //5
   ENUM_HOUR_6,     //6
   ENUM_HOUR_7,     //7
   ENUM_HOUR_8,     //8
   ENUM_HOUR_9,     //9
   ENUM_HOUR_10,     //10
   ENUM_HOUR_11,     //11   
   ENUM_HOUR_12,     //12
   ENUM_HOUR_13,     //13
   ENUM_HOUR_14,     //14
   ENUM_HOUR_15,     //15
   ENUM_HOUR_16,     //16
   ENUM_HOUR_17,     //17
   ENUM_HOUR_18,     //18
   ENUM_HOUR_19,     //19
   ENUM_HOUR_20,     //20
   ENUM_HOUR_21,     //21  
   ENUM_HOUR_22,     //22
   ENUM_HOUR_23      //23    
  };
//+----------------------------------------------+
//|  Объявление перечисления минут часов         |
//+----------------------------------------------+
enum MINUTS
  {
   ENUM_MINUT_0=0,   //0
   ENUM_MINUT_1,     //1
   ENUM_MINUT_2,     //2
   ENUM_MINUT_3,     //3
   ENUM_MINUT_4,     //4
   ENUM_MINUT_5,     //5
   ENUM_MINUT_6,     //6
   ENUM_MINUT_7,     //7
   ENUM_MINUT_8,     //8
   ENUM_MINUT_9,     //9
   ENUM_MINUT_10,     //10
   ENUM_MINUT_11,     //11   
   ENUM_MINUT_12,     //12
   ENUM_MINUT_13,     //13
   ENUM_MINUT_14,     //14
   ENUM_MINUT_15,     //15
   ENUM_MINUT_16,     //16
   ENUM_MINUT_17,     //17
   ENUM_MINUT_18,     //18
   ENUM_MINUT_19,     //19
   ENUM_MINUT_20,     //20
   ENUM_MINUT_21,     //21  
   ENUM_MINUT_22,     //22
   ENUM_MINUT_23,     //23
   ENUM_MINUT_24,     //24
   ENUM_MINUT_25,     //25
   ENUM_MINUT_26,     //26
   ENUM_MINUT_27,     //27
   ENUM_MINUT_28,     //28
   ENUM_MINUT_29,     //29
   ENUM_MINUT_30,     //30
   ENUM_MINUT_31,     //31  
   ENUM_MINUT_32,     //32
   ENUM_MINUT_33,     //33
   ENUM_MINUT_34,     //34
   ENUM_MINUT_35,     //35
   ENUM_MINUT_36,     //36
   ENUM_MINUT_37,     //37
   ENUM_MINUT_38,     //38
   ENUM_MINUT_39,     //39 
   ENUM_MINUT_40,     //40
   ENUM_MINUT_41,     //41  
   ENUM_MINUT_42,     //42
   ENUM_MINUT_43,     //43
   ENUM_MINUT_44,     //44
   ENUM_MINUT_45,     //45
   ENUM_MINUT_46,     //46
   ENUM_MINUT_47,     //47
   ENUM_MINUT_48,     //48
   ENUM_MINUT_49,     //49
   ENUM_MINUT_50,     //50
   ENUM_MINUT_51,     //51  
   ENUM_MINUT_52,     //52
   ENUM_MINUT_53,     //53
   ENUM_MINUT_54,     //54
   ENUM_MINUT_55,     //55
   ENUM_MINUT_56,     //56
   ENUM_MINUT_57,     //57
   ENUM_MINUT_58,     //58
   ENUM_MINUT_59      //59             
  };
//+----------------------------------------------+ 
//|  объявление перечислений                     |
//+----------------------------------------------+ 
enum ENUM_WIDTH //Тип константы
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input string LinesSirname="VLine_Grid_Custom_";     //название линии
input HOURS  LineHours=ENUM_HOUR_0;                 //Время установки линии (Часы)
input MINUTS LineMinuts=ENUM_MINUT_0;               //Время установки линии (Минуты)
input color Line_Color=clrMagenta;                  //цвет линии
input ENUM_LINE_STYLE Line_Style=STYLE_DASHDOTDOT;  //стиль изображения линии
input ENUM_WIDTH Line_Width=w_1;                    //толщина линии
input bool SetBackground=true;                      //фоновое отображение линий
input uint LinesTotal=10;                           //количество линий на истории
input uint FutureTotal=1;                           //количество линий на пустой истории будущего
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
uint Count[];
datetime VLineTime[];
//---- Объявление целых переменных начала отсчёта данных
uint LinesTotal_;
//+------------------------------------------------------------------+
//|  проверка бара на момент времени                                 |
//+------------------------------------------------------------------+   
bool CheckVLinePoint(datetime bartime1,datetime bartime0)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   MqlDateTime tm0,tm1;
   TimeToStruct(bartime0,tm0);
   TimeToStruct(bartime1,tm1);
//----
   if(tm0.hour==LineHours && tm0.min==LineMinuts) return(true);
//----
   if(!LineMinuts)
     {
      if(tm0.day_of_year==tm1.day_of_year) if(tm1.hour<LineHours && tm0.hour>LineHours) return(true);
      if(tm0.day_of_year!=tm1.day_of_year) if(tm0.hour>=LineHours) return(true);
     }
//----
   if(LineMinuts)
     {
      if(tm0.hour==LineHours && tm1.min<LineMinuts && tm0.min>=LineMinuts) return(true);
      if(tm0.day_of_year==tm1.day_of_year && tm1.hour<LineHours && tm0.hour>LineHours)  return(true);
      if(tm0.day_of_year!=tm1.day_of_year) if(tm0.hour>LineHours) return(true);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos
(
 int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
 int Size // количество элементов в кольцевом буфере
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//|  Переименование вертикальной линии                               |
//+------------------------------------------------------------------+
bool RenameVline
(
 long     chart_id,      // идентификатор графика
 string   oldname,       // старое имя объекта
 string   newname        // новое имя объекта
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,oldname)>0)
     {
      ObjectSetString(chart_id,oldname,OBJPROP_NAME,newname);
      return(true);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//|  Создание вертикальной линии                                     |
//+------------------------------------------------------------------+
void CreateVline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время вертикального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); //запрет всплывающей подсказки
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка вертикальной линии                                |
//+------------------------------------------------------------------+
void SetVline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 datetime time1,         // время вертикального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- проверка периода графика на достаточность для расчёта
   if(Period()>PERIOD_H12) return;
   Deinit();
//---- Инициализация переменных начала отсчёта данных
   LinesTotal_=LinesTotal+FutureTotal;

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,LinesTotal_);
   ArrayResize(VLineTime,LinesTotal_);

//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"VLine_Grid_Custom(",LinesSirname,", ",LinesTotal,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//----
   ObjectsDeleteAll(0,LinesSirname,-1,OBJ_VLINE);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
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
//---- проверка периода графика на достаточность для расчёта
   if(Period()>PERIOD_H12) return(RESET);
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<2) return(RESET);
   if(prev_calculated==rates_total) return(rates_total);

//---- объявления локальных переменных 
   string Name;
   datetime Time;
   int limit,bar;
   static datetime LastTime=0;

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(time,true);

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-2; // стартовый номер для расчёта всех баров
      uint VLineCount=0;
      ArrayInitialize(Count,NULL);
      for(bar=0; bar<=limit && !IsStopped(); bar++)
         if(CheckVLinePoint(time[bar+1],time[bar]))
           {
            VLineCount++;
            if(VLineCount>=LinesTotal) break;
           }

      if(bar<limit) limit=bar;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- цикл расчёта индикатора на текущих барах
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(CheckVLinePoint(time[bar+1],time[bar]))
        {
         Name=LinesSirname+TimeToString(time[bar]);
         RenameVline(0,LinesSirname+TimeToString(VLineTime[Count[FutureTotal]]),Name);
         SetVline(0,Name,0,time[bar],Line_Color,Line_Style,Line_Width,SetBackground,"дневной бар");
         VLineTime[Count[FutureTotal]]=time[bar];
         if(bar>0) Recount_ArrayZeroPos(Count,LinesTotal_);
         LastTime=time[bar];
        }
     }

//---- цикл расчёта индикатора на будущем 
   for(int numb=int(FutureTotal)-1; numb>=0 && !IsStopped(); numb--)
     {
      Time=LastTime+DAILY_PERIOD_SECOND*(FutureTotal-numb);
      Name=LinesSirname+TimeToString(Time);
      RenameVline(0,LinesSirname+TimeToString(VLineTime[Count[numb]]),Name);
      SetVline(0,Name,0,Time,Line_Color,Line_Style,Line_Width,SetBackground,"дневной бар");
      VLineTime[Count[numb]]=Time;
     }
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
