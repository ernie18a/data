//+------------------------------------------------------------------+
//|                                                          IGO.mqh |
//|                                       Interactive graphic object |
//|                                           Copyright 2016, DC2008 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, DC2008"
#property link      "https://www.mql5.com/ru/users/dc2008"
#property version   "1.00"
//--- Объявление констант
#define  c_bar    25    // номер бара для определения цены деления по умолчанию
#define  Event_1  1     // номер сообщения [изменилась базовая точка привязки]
#define  Event_2  2     // номер сообщения [изменился базовый угол привязки]
#define  clrISO   clrSilver   // цвет объекта IGO
#define  styleISO STYLE_DASH  // стиль объекта IGO
//+------------------------------------------------------------------+
//| Структура координат                                              |
//+------------------------------------------------------------------+
struct sXY
  {
   int               X;       // координата в системе "Картина" [pixel]
   int               Y;       // координата в системе "Картина" [pixel]
  };
//+------------------------------------------------------------------+
//| преобразования координат "График" -> "Картина"                   |
//+------------------------------------------------------------------+
sXY TimePriceToXY(datetime time,
                  double price,
                  sXY &xy)
  {
   sXY res=xy;
   int x=NULL,y=NULL;
   if(ChartTimePriceToXY(0,0,time,price,x,y))// пояснить в статье про x=0 y=0
     {
      res.X=x; // координата объекта по оси X в системе "Картина" [pixel]
      res.Y=y; // координата объекта по оси Y в системе "Картина" [pixel]
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Время на выбранном баре                                          |
//+------------------------------------------------------------------+
datetime T(const int bar)
  {
   datetime m_time[];
   if(ArraySetAsSeries(m_time,true) && CopyTime(_Symbol,_Period,bar,1,m_time)>0)
      return(m_time[0]);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Class CIGO: базовый класс интерактивных графических объектов IGO |
//+------------------------------------------------------------------+
class CIGO
  {
protected:
   bool              on_event;      // флаг обработки событий
   int               m_layer;       // слой которому принадлежит IGO объект
   //---
   double            SetPrice(double def,int prop_modifier=0);
public:
   string            m_name;        // имя IGO объекта
   double            m_price;       // базовая точка привязки IGO объекта [цена]
   double            m_angle;       // значение угла привязки IGO объекта [град]
                     CIGO();
                    ~CIGO();
   //---
   virtual     // Метод: создать IGO объект
   void              Create(string name) {on_event=true;}
   virtual     // Метод: перерисовать IGO объект
   void              Redraw() {ChartRedraw();}
   virtual     // Метод обработки события OnChartEvent
   bool              OnEvent(const int id,         // идентификатор события
                             const long &lparam,   // параметр события типа long
                             const double &dparam, // параметр события типа double
                             const string &sparam, // параметр события типа string
                             int iparamemr=0,      // идентификатор события IGO
                             double dparametr=0.0);// параметр события IGO типа double
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CIGO::SetPrice(double def,int prop_modifier=0)
  {
   if(m_price==NULL) // если нет значения переменной
      m_price=ObjectGetDouble(0,m_name,OBJPROP_PRICE,prop_modifier);
   if(m_price==NULL)             // если нет координат
      m_price=def;               // значение по умолчанию
   return(m_price);
  }
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CIGO::CIGO()
  {
   on_event=false;                  // запрещаем обработку событий
   m_layer=0;                       // объект находится на 0 слое
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
CIGO::~CIGO()
  {
  }
//+------------------------------------------------------------------+
//| Метод обработки события OnChartEvent базового класса C3DObject   |
//+------------------------------------------------------------------+
bool CIGO::OnEvent(const int id,
                   const long &lparam,
                   const double &dparam,
                   const string &sparam,
                   int iparamemr=0,
                   double dparametr=0.0)
  {
   bool res=false;
   if(on_event) // обработка событий разрешена
     {
      // Удаление графического объекта
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_DELETE && sparam==m_name)
        {
         Create(m_name);
        }
      // Изменение размеров графика или изменение свойств графика через диалог свойств
      if((ENUM_CHART_EVENT)id==CHARTEVENT_CHART_CHANGE)
        {
         Redraw();
        }
      // Перетаскивание графического объекта
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_DRAG)
         if(ObjectGetInteger(0,sparam,OBJPROP_SELECTED)==1 && sparam==m_name)
           {
            m_price=ObjectGetDouble(0,m_name,OBJPROP_PRICE);
            Redraw();
            res=true;   // сообщаем, что изменилась базовая точка привязки для тех кому это интересно
           }
      // нажатие мышки не на этом графическом объекте
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_CLICK && sparam!=m_name)
        {
         ObjectSetInteger(0,m_name,OBJPROP_SELECTED,0);
         ChartRedraw();
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Класс OBJ_ARROW_RIGHT_PRICE: объект "Правая ценовая метка"       |
//+------------------------------------------------------------------+
class C_OBJ_ARROW_RIGHT_PRICE:public CIGO
  {
public:
   virtual     // Метод: создать объект
   void              Create(string name);
   virtual     // Метод: перерисовать объект
   void              Redraw();
  };
//+------------------------------------------------------------------+
//| Метод: создать объект                                            |
//+------------------------------------------------------------------+
void C_OBJ_ARROW_RIGHT_PRICE::Create(string name)
  {
   m_name=name;
   m_price=SetPrice((ChartGetDouble(0,CHART_PRICE_MAX)+ChartGetDouble(0,CHART_PRICE_MIN))/2);
   ObjectCreate(0,m_name,OBJ_ARROW_RIGHT_PRICE,0,0,0);
   ObjectSetInteger(0,m_name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(0,m_name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,m_name,OBJPROP_COLOR,clrISO);
//---
   ObjectSetInteger(0,m_name,OBJPROP_TIME,0,T(0));
   ObjectSetDouble(0,m_name,OBJPROP_PRICE,0,m_price);
//---
   ChartRedraw();
   on_event=true; // разрешаем обработку событий
  }
//+------------------------------------------------------------------+
//| Метод: перерисовать объект                                       |
//+------------------------------------------------------------------+
void C_OBJ_ARROW_RIGHT_PRICE::Redraw()
  {
   ObjectSetInteger(0,m_name,OBJPROP_TIME,0,T(0));
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Класс OBJ_TREND: объект "Трендовая линия"                        |
//+------------------------------------------------------------------+
class C_OBJ_TREND:public CIGO
  {
public:
   virtual     // Метод: создать объект
   void              Create(string name);
   virtual     // Метод: перерисовать объект
   void              Redraw();
  };
//+------------------------------------------------------------------+
//| Метод: создать объект                                            |
//+------------------------------------------------------------------+
void C_OBJ_TREND::Create(string name)
  {
   m_name=name;
   m_price=(ChartGetDouble(0,CHART_PRICE_MAX)+ChartGetDouble(0,CHART_PRICE_MIN))/2;
   ObjectCreate(0,m_name,OBJ_TREND,0,0,0);
   ObjectSetInteger(0,m_name,OBJPROP_COLOR,clrISO);
   ObjectSetInteger(0,m_name,OBJPROP_WIDTH,0);
   ObjectSetInteger(0,m_name,OBJPROP_STYLE,styleISO);
   ObjectSetDouble(0,m_name,OBJPROP_PRICE,0,m_price);
   ObjectSetInteger(0,m_name,OBJPROP_TIME,0,T(0));
   ObjectSetDouble(0,m_name,OBJPROP_PRICE,1,m_price+1);
   ObjectSetInteger(0,m_name,OBJPROP_TIME,1,T(0));
   ObjectSetInteger(0,m_name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,m_name,OBJPROP_RAY_LEFT,true);
   ObjectSetInteger(0,m_name,OBJPROP_BACK,true);
   ObjectSetInteger(0,m_name,OBJPROP_SELECTABLE,false);
//---
   ChartRedraw();
   on_event=true; // разрешаем обработку событий
  }
//+------------------------------------------------------------------+
//| Метод: перерисовать объект                                       |
//+------------------------------------------------------------------+
void C_OBJ_TREND::Redraw()
  {
   ObjectSetInteger(0,m_name,OBJPROP_TIME,0,T(0));
   ObjectSetInteger(0,m_name,OBJPROP_TIME,1,T(0));
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Класс OBJ_TRENDBYANGLE: объект "Трендовая линия по углу"         |
//+------------------------------------------------------------------+
class C_OBJ_TRENDBYANGLE:public CIGO
  {
protected:
   int               m_bar;   // номер бара для привязки 2-ой базовой точки
   //---
   double SetAngle(double def)
     {
      if(m_angle==NULL) // если нет значения переменной
         m_angle=ObjectGetDouble(0,m_name,OBJPROP_ANGLE);
      if(m_angle==NULL)       // если нет координат
         m_angle=def;         // значение по умолчанию
      return(m_angle);
     }
public:
                     C_OBJ_TRENDBYANGLE();
   virtual     // Метод: создать объект
   void              Create(string name,double price,double angle);
   virtual     // Метод: перерисовать объект
   void              Redraw();
   virtual     // Метод обработки события OnChartEvent
   bool              OnEvent(const int id,
                             const long &lparam,
                             const double &dparam,
                             const string &sparam,
                             int iparamemr=0,
                             double dparametr=0.0);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
C_OBJ_TRENDBYANGLE::C_OBJ_TRENDBYANGLE()
  {
   m_bar=c_bar;
  }
//+------------------------------------------------------------------+
//| Метод: создать объект                                            |
//+------------------------------------------------------------------+
void C_OBJ_TRENDBYANGLE::Create(string name,double price,double angle)
  {
   datetime time=T(0);
   datetime deltaT=T(m_bar)-time;
   m_name=name;
   m_price=SetPrice(price);
   m_angle=SetAngle(angle);
   ObjectCreate(0,m_name,OBJ_TRENDBYANGLE,0,time,m_price,time+deltaT,m_price);
   ObjectSetInteger(0,m_name,OBJPROP_COLOR,clrISO);
   ObjectSetInteger(0,m_name,OBJPROP_WIDTH,0);
   ObjectSetInteger(0,m_name,OBJPROP_STYLE,styleISO);
   ObjectSetInteger(0,m_name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,m_name,OBJPROP_RAY_LEFT,true);
   ObjectSetInteger(0,m_name,OBJPROP_BACK,true);
   ObjectSetInteger(0,m_name,OBJPROP_SELECTABLE,true);
//--- изменяем угол наклона трендовой линии; в процессе изменения угла, координата второй 
//--- точки линии переопределится автоматически в соответствии с новым значением угла 
   ObjectSetDouble(0,m_name,OBJPROP_ANGLE,m_angle);
   ChartRedraw();
//---
   on_event=true; // разрешаем обработку событий
  }
//+------------------------------------------------------------------+
//| Метод: перерисовать объект                                       |
//+------------------------------------------------------------------+
void C_OBJ_TRENDBYANGLE::Redraw()
  {
   ObjectSetInteger(0,m_name,OBJPROP_TIME,T(0));
   ObjectSetInteger(0,m_name,OBJPROP_TIME,1,T(0)+T(m_bar)-T(0));
   ObjectSetDouble(0,m_name,OBJPROP_PRICE,m_price);
   ObjectSetDouble(0,m_name,OBJPROP_ANGLE,m_angle);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Метод обработки события OnChartEvent                             |
//+------------------------------------------------------------------+
bool C_OBJ_TRENDBYANGLE::OnEvent(const int id,
                                 const long &lparam,
                                 const double &dparam,
                                 const string &sparam,
                                 int iparamemr=0,
                                 double dparametr=0.0)
  {
//---
   bool res=false;
   if(on_event) // обработка событий разрешена
     {
      // Удаление графического объекта
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_DELETE && sparam==m_name)
        {
         Create(m_name,m_price,m_angle);
        }
      // Изменение размеров графика или изменение свойств графика через диалог свойств
      if((ENUM_CHART_EVENT)id==CHARTEVENT_CHART_CHANGE)
        {
         Redraw();
        }
      // Перетаскивание графического объекта
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_DRAG)
        {
         //---
         if(ObjectGetInteger(0,sparam,OBJPROP_SELECTED)==1 && sparam==m_name)
           {
            m_angle=ObjectGetDouble(0,m_name,OBJPROP_ANGLE);
            Create(m_name,m_price,m_angle);
            res=true;   // сообщаем, что изменилась базовая точка привязки для тех кому это интересно
           }
         if(iparamemr==Event_1)// получили сообщение об изменении базовой точки
           {
            m_price=dparametr;
            Create(m_name,m_price,m_angle);
           }
         if(iparamemr==Event_2)// получили сообщение об изменении базового угла
           {
            m_angle=dparametr;
            Create(m_name,m_price,m_angle);
           }
        }
      // нажатие мышки не на этом графическом объекте
      if((ENUM_CHART_EVENT)id==CHARTEVENT_OBJECT_CLICK && sparam!=m_name)
        {
         ObjectSetInteger(0,m_name,OBJPROP_SELECTED,0);
         ChartRedraw();
        }
     }
   return(res);
  }
