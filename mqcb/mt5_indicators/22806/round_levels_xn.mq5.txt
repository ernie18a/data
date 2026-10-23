//+------------------------------------------------------------------+
//|                                              Round_Levels_XN.mq5 |
//|                                         Copyright © 2007, Martes |
//|               http://championship.mql4.com/2007/ru/users/Martes/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2007, Martes"
//---- ссылка на сайт автора
#property link      "http://championship.mql4.com/2007/ru/users/Martes/"

#property description "This code draws 4 horizontal lines with 00 at the end of"
#property description "the vertical coordinate (price). This 4 horizontal lines with"
#property description "this property are closest to current price."

//---- отрисовка индикатора в главном окне
#property indicator_chart_window 

//---- для расчёта и отрисовки индикатора использовано ноль буферов
#property indicator_buffers 0
//---- использовано ноль графических построений
#property indicator_plots   0
//+------------------------------------------------+ 
//| Перечисление для толщины уровня                |
//+------------------------------------------------+ 
enum ENUM_WIDTH //Тип константы
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------+ 
//| Перечисление для стиля линии уровня            |
//+------------------------------------------------+ 
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+------------------------------------------------+
//| Входные параметры индикатора                   |
//+------------------------------------------------+
input uint ZeroCount=2;                      //количество нулей для округления
input string levels_sirname="Price_Level_1"; //лейба уровней
input uint XNCount=3;                        //количество повторов всего набора линий
//----
input color Up_level_color2=clrBlue;    //цвет второго верхнего уровня
input STYLE Up_level_style2=SOLID_;     //стиль второго верхнего уровня
input ENUM_WIDTH Up_level_width2=w_3;   //толщина второго верхнего уровня
//----
input color Up_level_color1=clrLime;    //цвет первого верхнего уровня
input STYLE Up_level_style1=SOLID_;     //стиль первого верхнего уровня
input ENUM_WIDTH Up_level_width1=w_3;   //толщина первого верхнего уровня
//----
input color Dn_level_color1=clrRed;     //цвет первого нижнего уровня
input STYLE Dn_level_style1=SOLID_;     //стиль первого нижнего уровня
input ENUM_WIDTH Dn_level_width1=w_3;   //толщина первого нижнего уровня
//----
input color Dn_level_color2=clrMagenta; //цвет второго нижнего уровня
input STYLE Dn_level_style2=SOLID_;     //стиль второго нижнего уровня
input ENUM_WIDTH Dn_level_width2=w_3;   //толщина второго нижнего уровня
//+----------------------------------------------+
double VShift;
int Normalize;
string UpName2[],UpName1[],DnName1[],DnName2[];
//+------------------------------------------------------------------+
//|  Создание горизонтальной линии                                   |
//+------------------------------------------------------------------+
void CreateHline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 double   price,         // цена горизонтального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,nwin,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка горизонтальной линии                              |
//+------------------------------------------------------------------+
void SetHline
(
 long     chart_id,      // идентификатор графика
 string   name,          // имя объекта
 int      nwin,          // индекс окна
 double   price,         // цена горизонтального уровня
 color    Color,         // цвет линии
 int      style,         // стиль линии
 int      width,         // толщина линии
 bool     background,// фоновое отображение линии
 string   text           // текст
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
//---- распределение памяти под массивы переменных  
   ArrayResize(UpName2,XNCount+1);
   ArrayResize(UpName1,XNCount+1);
   ArrayResize(DnName1,XNCount+1);
   ArrayResize(DnName2,XNCount+1);
   for(int count=0;  count<int(XNCount+1); count++)
     {
      UpName2[count]=levels_sirname+"_UpName2."+string(count);
      UpName1[count]=levels_sirname+"_UpName1."+string(count);
      DnName1[count]=levels_sirname+"_DnName1."+string(count);
      DnName2[count]=levels_sirname+"_DnName2."+string(count);
     }
   Normalize=_Digits-int(ZeroCount);
   VShift=_Point*MathPow(10,ZeroCount);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---- удаляем уровени
   for(int count=0;  count<int(XNCount+1); count++)
     {
      ObjectDelete(0,UpName2[count]);
      ObjectDelete(0,UpName1[count]);
      ObjectDelete(0,DnName1[count]);
      ObjectDelete(0,DnName2[count]);
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- объявления локальных переменных 
   double UpLevel2,UpLevel1,DnLevel2;
   static double DnLevel1;
//----
   DnLevel1=NormalizeDouble(close[rates_total-1],_Digits-ZeroCount);   
   UpLevel1=DnLevel1+VShift;
   UpLevel2=UpLevel1+VShift;
   DnLevel2=DnLevel1-VShift;

   for(int count=0;  count<int(XNCount+1); count++)
     {
      SetHline(0,UpName2[count],0,UpLevel2+2*count*VShift,Up_level_color2,Up_level_style2,Up_level_width2,false,UpName1[count]);
      SetHline(0,UpName1[count],0,UpLevel1+2*count*VShift,Up_level_color1,Up_level_style1,Up_level_width1,false,UpName1[count]);
      SetHline(0,DnName1[count],0,DnLevel1-2*count*VShift,Dn_level_color1,Dn_level_style1,Dn_level_width1,false,DnName1[count]);
      SetHline(0,DnName2[count],0,DnLevel2-2*count*VShift,Dn_level_color2,Dn_level_style2,Dn_level_width2,false,DnName2[count]);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
