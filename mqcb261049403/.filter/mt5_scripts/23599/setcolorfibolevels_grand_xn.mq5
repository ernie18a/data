//+------------------------------------------------------------------+
//|                                  SetColorFiboLevels_Grand_xN.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- описание 
#property description "Скрипт строит графический объект \"Уровни Фибоначчи\"" 
#property description "с расширенными возможностями графического отображения."
#property description "Координаты точек привязки задаются хаем и лоу закрытой дневной свечи при настройках по умолчанию." 
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET     0            // Константа для возврата терминалу команды на пересчет индикатора
#define FIBO_LINES_TOTAL 7     // Константа для количества уровней фибо внутри одного сегмента Фибы
//+----------------------------------------------+
//--- покажем окно входных параметров при запуске скрипта 
#property script_show_inputs
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES Timeframe=PERIOD_D1;                //Таймфрейм свечи для расчета уровней Фибоначи
input uint   NumberofBar=1;                               //Номер бара для расчета уровней Фибоначи
//----
//--- входные параметры скрипта 
input string          InpName="ColorFiboLevels_Grand_xN"; //Имя объекта
input uint            FiboTotal=6;               // Количество дополнительных секторов Фибо сверху или снизу 
input color           InpColor=clrBlueViolet;    // Цвет объекта 
input ENUM_LINE_STYLE InpStyle=STYLE_SOLID;      // Стиль линии 
input int             InpWidth=2;                // Толщина линии 
input bool            InpBack=false;             // Объект на заднем плане 
input bool            InpSelection=true;         // Выделить для перемещений 
input bool            InpRayLeft=false;          // Продолжение объекта влево 
input bool            InpRayRight=true;          // Продолжение объекта вправо 
input bool            InpHidden=true;            // Скрыт в списке объектов 
input long            InpZOrder=0;               // Приоритет на нажатие мышью 
//+----------------------------------------------+
//| Входные параметры фибоуровней                |
//+----------------------------------------------+
input double  FiboLevel1 =0.000;                    //значение фибоуровня 1
input ENUM_LINE_STYLE StyleLevel1=STYLE_SOLID;      //стиль линии фибоуровня 1
input uint   WidthLevel1=5;                         //толщина линии фибоуровня 1
input color  Color_Level1 = clrDodgerBlue;          //цвет фибоуровня 1
//----
input double  FiboLevel2=0.236;                     //значение фибоуровня 2
input ENUM_LINE_STYLE StyleLevel2=STYLE_SOLID;      //стиль линии фибоуровня 2
input uint    WidthLevel2=1;                        //толщина линии фибоуровня 2
input color   Color_Level2= clrDarkViolet;          //цвет фибоуровня 2
//----
input double  FiboLevel3 =0.382;                    //значение фибоуровня 3
input ENUM_LINE_STYLE StyleLevel3=STYLE_DASH;       //стиль линии фибоуровня 3
input uint    WidthLevel3=1;                        //толщина линии фибоуровня 3
input color   Color_Level3 = clrOrange;             //цвет фибоуровня 3
//----
input double  FiboLevel4 =0.500;                    //значение фибоуровня 4
input ENUM_LINE_STYLE StyleLevel4=STYLE_SOLID;      //стиль линии фибоуровня 4
input uint    WidthLevel4=4;                        //толщина линии фибоуровня 4
input color   Color_Level4 = clrRed;                //цвет фибоуровня 4
//----  
input double  FiboLevel5 =0.618;                    //значение фибоуровня 5
input ENUM_LINE_STYLE StyleLevel5=STYLE_DASH;       //стиль линии фибоуровня 5
input uint    WidthLevel5=1;                        //толщина линии фибоуровня 5
input color   Color_Level5 = clrBlue;               //цвет фибоуровня 5
//----
input double  FiboLevel6=0.764;                     //значение фибоуровня 6
input ENUM_LINE_STYLE StyleLevel6=STYLE_SOLID;      //стиль линии фибоуровня 6
input uint    WidthLevel6=1;                        //толщина линии фибоуровня 6
input color   Color_Level6 = clrGray;               //цвет фибоуровня 6
//----
input double  FiboLevel7 = 1.000;                   //значение фибоуровня 7
input ENUM_LINE_STYLE StyleLevel7=STYLE_SOLID;      //стиль линии фибоуровня 7
input uint    WidthLevel7=4;                        //толщина линии фибоуровня 7
input color   Color_Level7 = clrDodgerBlue;         //цвет фибоуровня 7
//+----------------------------------------------+
#define FIBO_LINES_TOTAL_XN_FULL FIBO_LINES_TOTAL*(1+FiboTotal*2)-FiboTotal*2    // Константа для количества уровней фибо
//---- массивы переменных для линий Фибо
double Values[];
color Colors[];
ENUM_LINE_STYLE Styles[];
uint Widths[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int _Init()
  {
//---- распределение памяти и инициализация переменных
   ArrayResize(Values,FIBO_LINES_TOTAL_XN_FULL);
   ArrayResize(Colors,FIBO_LINES_TOTAL_XN_FULL);
   ArrayResize(Styles,FIBO_LINES_TOTAL_XN_FULL);
   ArrayResize(Widths,FIBO_LINES_TOTAL_XN_FULL);
//----  
   Values[0]=FiboLevel1;
   Values[1]=FiboLevel2;
   Values[2]=FiboLevel3;
   Values[3]=FiboLevel4;
   Values[4]=FiboLevel5;
   Values[5]=FiboLevel6;
   Values[6]=FiboLevel7;
//----   
   Colors[0]=Color_Level1;
   Colors[1]=Color_Level2;
   Colors[2]=Color_Level3;
   Colors[3]=Color_Level4;
   Colors[4]=Color_Level5;
   Colors[5]=Color_Level6;
   Colors[6]=Color_Level7;
//----   
   Styles[0]=StyleLevel1;
   Styles[1]=StyleLevel2;
   Styles[2]=StyleLevel3;
   Styles[3]=StyleLevel4;
   Styles[4]=StyleLevel5;
   Styles[5]=StyleLevel6;
   Styles[6]=StyleLevel7;
//----   
   Widths[0]=WidthLevel1;
   Widths[1]=WidthLevel2;
   Widths[2]=WidthLevel3;
   Widths[3]=WidthLevel4;
   Widths[4]=WidthLevel5;
   Widths[5]=WidthLevel6;
   Widths[6]=WidthLevel7;
//---- 
    
   for(int count=1; count<=int(FiboTotal); count++)
      for(int lev=1; lev<7; lev++)
        {
         int kkk=lev+6*(2*count-1);
         Values[kkk]=Values[lev]+count;
         Colors[kkk]=Colors[lev];
         Styles[kkk]=Styles[lev];
         Widths[kkk]=Widths[lev];
         //----
         kkk=lev+6*(2*count);
         Values[kkk]=-Values[7-lev]-count+1;
         Colors[kkk]=Colors[lev-1];
         Styles[kkk]=Styles[lev-1];
         Widths[kkk]=Widths[lev-1];
        }
//--- создадим объект 
   if(!FiboLevelsCreate(0,InpName,0,0,0,0,0,InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder))
     {
      Print("Не удалось создать Фибо!");
      return(INIT_FAILED);
     }
   if(!FiboLevelsSet(FIBO_LINES_TOTAL_XN_FULL,Values,Colors,Styles,Widths,0,InpName))
     {
      Print("Не удалось настроить Фибо!");
      return(INIT_FAILED);
     }
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Script program start function                                    | 
//+------------------------------------------------------------------+ 
void OnStart()
  {
//----
   double nOpen[1],nClose[1],nHigh[1],nLow[1],P1,P2;
   datetime nTime[1];
   int to_copy;
   datetime D1,D2;
   _Init();

//---- индексация элементов в массивах как в таймсериях  
   to_copy=1;
//----
   if(CopyTime(NULL,Timeframe,NumberofBar,to_copy,nTime)<to_copy)return;
   if(CopyOpen(NULL,Timeframe,NumberofBar,to_copy,nOpen)<to_copy)return;
   if(CopyHigh(NULL,Timeframe,NumberofBar,to_copy,nHigh)<to_copy)return;
   if(CopyLow(NULL,Timeframe,NumberofBar,to_copy,nLow)<to_copy)return;
   if(CopyClose(NULL,Timeframe,NumberofBar,to_copy,nClose)<to_copy)return;
//----   
   if(nOpen[0]>nClose[0])
     {
      P1=nHigh[0];
      P2=nLow[0];
     }
   else
     {
      P1=nLow[0];
      P2=nHigh[0];
     }
   D1=nTime[0];
   D2=TimeCurrent();
//----
   if(!FiboLevelsPointChange(0,InpName,0,D1,P1)) return;
   if(!FiboLevelsPointChange(0,InpName,1,D2,P2)) return;
//----
   ChartRedraw(0);
   return;
  }
//+------------------------------------------------------------------+ 
//| Cоздает "Уровни Фибоначчи" по заданным координатам               | 
//+------------------------------------------------------------------+ 
bool FiboLevelsCreate(const long            chart_ID=0,        // ID графика 
                      const string          name="FiboLevels", // имя объекта 
                      const int             sub_window=0,      // номер подокна  
                      datetime              time1=0,           // время первой точки 
                      double                price1=0,          // цена первой точки 
                      datetime              time2=0,           // время второй точки 
                      double                price2=0,          // цена второй точки 
                      const color           clr=clrRed,        // цвет объекта 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии объекта 
                      const int             width=1,           // толщина линии объекта 
                      const bool            back=false,        // на заднем плане 
                      const bool            selection=true,    // выделить для перемещений 
                      const bool            ray_left=false,    // продолжение объекта влево 
                      const bool            ray_right=false,   // продолжение объекта вправо 
                      const bool            hidden=true,       // скрыт в списке объектов 
                      const long            z_order=0)         // приоритет на нажатие мышью 
  {
//--- установим координаты точек привязки, если они не заданы 
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
//--- сбросим значение ошибки 
   ResetLastError();
//--- создадим "Уровни Фибоначчи" по заданным координатам 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": не удалось создать \"Уровни Фибоначчи\"! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим цвет 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим выделения объекта для перемещений 
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект 
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection 
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- включим (true) или отключим (false) режим продолжения отображения объекта влево 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- включим (true) или отключим (false) режим продолжения отображения объекта вправо 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установи приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Задает количество уровней и их параметры                         | 
//+------------------------------------------------------------------+ 
bool FiboLevelsSet(int             levels,            // количество линий уровня 
                   double          &values[],         // значения линий уровня 
                   color           &colors[],         // цвет линий уровня 
                   ENUM_LINE_STYLE &styles[],         // стиль линий уровня 
                   int             &widths[],         // толщина линий уровня 
                   const long      chart_ID=0,        // ID графика 
                   const string    name="FiboLevels") // имя объекта 
  {
//--- проверим размеры массивов 
   if(levels!=ArraySize(colors) || levels!=ArraySize(styles) ||
      levels!=ArraySize(widths) || levels!=ArraySize(widths))
     {
      Print(__FUNCTION__,": длина массива не соответствует количеству уровней, ошибка!");
      return(false);
     }
//--- установим количество уровней 
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels);
//--- установим свойства уровней в цикле 
   for(int i=0;i<levels;i++)
     {
      //--- значение уровня 
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]);
      //--- цвет уровня 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,colors[i]);
      //--- стиль уровня 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,i,styles[i]);
      //--- толщина уровня 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,widths[i]);
      //--- описание уровня 
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,DoubleToString(100*values[i],1));
     }
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Перемещает точку привязки "Уровней Фибоначчи"                    | 
//+------------------------------------------------------------------+ 
bool FiboLevelsPointChange(const long   chart_ID=0,        // ID графика 
                           const string name="FiboLevels", // имя объекта 
                           const int    point_index=0,     // номер точки привязки 
                           datetime     time=0,            // координата времени точки привязки 
                           double       price=0)           // координата цены точки привязки 
  {
//--- если координаты точки не заданы, то перемещаем ее на текущий бар с ценой Bid 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- сбросим значение ошибки 
   ResetLastError();
//--- переместим точку привязки 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": не удалось переместить точку привязки! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Удаляет "Уровни Фибоначчи"                                       | 
//+------------------------------------------------------------------+ 
bool FiboLevelsDelete(const long   chart_ID=0,        // ID графика 
                      const string name="FiboLevels") // имя объекта 
  {
//--- сбросим значение ошибки 
   ResetLastError();
//--- удалим объект 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": не удалось удалить \"Уровни Фибоначчи\"! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Проверяет значения точек привязки "Уровней Фибоначчи" и для      | 
//| пустых значений устанавливает значения по умолчанию              | 
//+------------------------------------------------------------------+ 
void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                 datetime &time2,double &price2)
  {
//--- если время второй точки не задано, то она будет на текущем баре 
   if(!time2)
      time2=TimeCurrent();
//--- если цена второй точки не задана, то она будет иметь значение Bid 
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- если время первой точки не задано, то она лежит на 9 баров левее второй 
   if(!time1)
     {
      //--- массив для приема времени открытия 10 последних баров 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- установим первую точку на 9 баров левее второй 
      time1=temp[0];
     }
//--- если цена первой точки не задана, то сдвинем ее на 200 пунктов ниже второй 
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }
//+------------------------------------------------------------------+ 
