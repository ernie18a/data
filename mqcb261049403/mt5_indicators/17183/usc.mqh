//+------------------------------------------------------------------+
//|                                                          USC.mqh |
//|                                           Copyright 2016, DC2008 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, DC2008"
#property link      "https://www.mql5.com/ru/users/dc2008"
#property version   "1.00"
//--- Подключаем файлы классов
#include <3D\IGO.mqh>
#include <3D\GM.mqh>
//---
#define  ISO      120  // угол между осями X и Y в системе "Картина" [град]
#define  WP       108  // символ шрифта Wingdings
#define  FS       5    // Размер шрифта Wingdings
#define  ObjF1    ObjectSetString(0,name,OBJPROP_FONT,"Wingdings")
#define  ObjF2    ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER)
#define  ObjF3    ObjectSetString(0,name,OBJPROP_TEXT,CharToString(WP))
#define  ObjF4    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FS)
#define  ObjFont  ObjF1;ObjF2;ObjF3;ObjF4
//+------------------------------------------------------------------+
//| Структура координат                                              |
//+------------------------------------------------------------------+
struct sPointCoordinates
  {
   datetime          time;    // координата в системе "График"
   double            price;   // координата в системе "График"
  };
//+------------------------------------------------------------------+
//| Класс CUSC: объект "3-х мерная инерактивная система координат"   |
//+------------------------------------------------------------------+
class CUSC:public CIGO
  {
private:
   datetime          m_prev_bar;
   datetime          m_next_bar;
   //---
   C_OBJ_ARROW_RIGHT_PRICE Centr;   // объявление экземпляра класса C_OBJ_ARROW_RIGHT_PRICE
   C_OBJ_TREND       AxisZ;         // объявление экземпляра класса C_OBJ_TREND
   C_OBJ_TRENDBYANGLE AxisY,AxisX;  // объявление экземпляров класса C_OBJ_TRENDBYANGLE
   //---
   CGM               gCentr;        // объявление экземпляра класса CGM
   CGM               gAxisY,gAxisX; // объявление экземпляров класса CGM

public:
                     CUSC();
                    ~CUSC();
   //--- Расчёт координаты Z
   sPointCoordinates Z(double price,   // цена в системе координат "График"
                       int barX,       // смещение по оси X
                       int barY);      // смещение по оси Y
   //--- новый бар
   bool on_bar()
     {
      m_next_bar=T(0);
      if(m_next_bar>m_prev_bar)
        {
         m_prev_bar=m_next_bar;
         return(true);
        }
      return(false);
     }
   //---
   virtual     // Метод: создать IGO объект
   void              Create(string name);
   virtual     // Метод обработки события OnChartEvent
   void              OnEvent(const int id,
                             const long &lparam,
                             const double &dparam,
                             const string &sparam);
  };
//+------------------------------------------------------------------+
//| Метод расчёта координаты Z                                       |
//+------------------------------------------------------------------+
sPointCoordinates CUSC::Z(double price,int barX,int barY)
  {
   sPointCoordinates res;
   res.price=0;
   res.time=0;
   double dX,dY;
   dX=0;
   dX=gAxisX.R_ValueByTime(T(barX))-m_price;
   dY=0;
   dY=gAxisY.R_ValueByTime(T(-barY))-m_price;
   res.price=price+dX-dY;
   res.time=T(barX-barY);
   return(res);
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CUSC::CUSC()
  {
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,false);
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,0,true);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,0,true);
//---
   ChartSetInteger(0,CHART_COLOR_GRID,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrNONE);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrNONE);
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
CUSC::~CUSC()
  {
  }
//+------------------------------------------------------------------+
//| Метод: Create                                                    |
//+------------------------------------------------------------------+
void CUSC::Create(string name)
  {
//--- Центр 3-х мерной системы координат
   Centr.Create("Axis XYZ");        // создаём центр системы координат
   gCentr.Create(Centr.m_name);     // создаём объект графической памяти
   m_price=gCentr.R_OBJPROP_PRICE();
//--- Ось Z
   AxisZ.Create("Axis Z");          // создаём ось Z системы координат
//--- Ось Y
   AxisY.Create("Axis Y",                 // создаём ось Y системы координат
                gCentr.R_OBJPROP_PRICE(), // получим значение из GM
                30);                      // задаём угол наклона оси 30 градусов
   gAxisY.Create(AxisY.m_name);           // создаём объект графической памяти
   m_angle=gAxisY.R_OBJPROP_ANGLE();
//--- Ось X
   AxisX.Create("Axis X",                       // создаём ось X системы координат
                gCentr.R_OBJPROP_PRICE(),       // получим значение из GM
                gAxisY.R_OBJPROP_ANGLE()+ISO);  // получим значение из GM и увеличим его на ISO градусов
   gAxisX.Create(AxisX.m_name);                 // создаём объект графической памяти
//---
   ChartRedraw();
   on_event=true; // разрешаем обработку событий
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void CUSC::OnEvent(const int id,
                   const long &lparam,
                   const double &dparam,
                   const string &sparam)
  {
   if(on_event) // обработка событий разрешена
     {
      //--- трансляция событий OnChartEvent
      AxisZ.OnEvent(id,lparam,dparam,sparam);
      //---
      if(Centr.OnEvent(id,lparam,dparam,sparam))
        {// Перетаскивание графического объекта
         AxisY.OnEvent(id,lparam,dparam,sparam,Event_1,gCentr.R_OBJPROP_PRICE());
         AxisX.OnEvent(id,lparam,dparam,sparam,Event_1,gCentr.R_OBJPROP_PRICE());
        }
      else
        {
         if(AxisY.OnEvent(id,lparam,dparam,sparam))
           {// Изменение угла графического объекта
            AxisX.OnEvent(id,lparam,dparam,sparam,Event_2,gAxisY.R_OBJPROP_ANGLE()+ISO);
           }
         else
           {
            if(AxisX.OnEvent(id,lparam,dparam,sparam))
              {// Изменение угла графического объекта
               AxisY.OnEvent(id,lparam,dparam,sparam,Event_2,gAxisX.R_OBJPROP_ANGLE()-ISO);
              }
           }
        }
      ChartRedraw();
      m_price=gCentr.R_OBJPROP_PRICE();
      m_angle=gAxisY.R_OBJPROP_ANGLE();
     }
  }
//+------------------------------------------------------------------+
