//+------------------------------------------------------------------+
//|                                                    CircleArc.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Круглый индикатор с численным значением и дуговой индикацией     |
//+------------------------------------------------------------------+
class CCircleArc : public CCanvasBase
  {
private:
   //--- Цвет фона индикатора
   color             m_bg_color;
   //--- Цвет дуги индикатора
   color             m_arc_color;
   //--- Цвет области индикации 
   color             m_area_color;
   //--- Цвет описания индикатора 
   color             m_label_color;
   //--- Цвет значения индикатора
   color             m_value_color;
   //--- Прозрачность индикатора
   uchar             m_transparency;
   //--- Размер индикатора
   int               m_radius;
   //--- Толщина шкалы индикатора 
   int               m_scale_width;
   //--- Размер шрифта описания
   int               m_label_font_size;
   //--- Размер шрифта значения
   int               m_value_font_size;
   //--- Описание индикатора
   string            m_label_value;
   //--- Тип ориентации шкалы индикатора
   ENUM_ORIENTATION  m_orientation;
public:
                     CCircleArc(void);
                    ~CCircleArc(void);
   //--- Устанавливает и возвращает цвет фона индикатора
   color             BgColor(void)                                   { return(m_bg_color);            }
   void              BgColor(const color clr)                        { m_bg_color=clr;                }
   //--- Устанавливает и возвращает цвет дуги индикацтора
   color             ArcColor(void)                                  { return(m_arc_color);           }
   void              ArcColor(const color clr)                       { m_arc_color=clr;               }
   //--- Устанавливает и возвращает цвет области индикации
   color             AreaColor(void)                                 { return(m_area_color);          }
   void              AreaColor(const color clr)                      { m_area_color=clr;              }
   //--- Устанавливает и возвращает цвет описания индикатора 
   color             LabelColor(void)                                { return(m_label_color);         }
   void              LabelColor(const color clr)                     { m_label_color=clr;             }
   //--- Устанавливает и возвращает цвет значения индикатора
   color             ValueColor(void)                                { return(m_value_color);         }
   void              ValueColor(const color clr)                     { m_value_color=clr;             }
   //--- Устанавливает и возвращает прозрачность индикатора 
   uchar             Alpha(void)                                     { return(m_transparency);        }
   void              Alpha(const uchar trn)                          { m_transparency=trn;            }
   //--- Устанавливает и возвращает размер индикатора
   int               Radius(void)                                    { return(m_radius);              }
   void              Radius(const int r)                             { m_radius=r;                    }
   //--- Устанавливает и возвращает толщину шкалы индикатора
   int               Width(void)                                     { return(m_scale_width);         }
   void              Width(const int w)                              { m_scale_width=w;               }
   //--- Устанавливает и возвращает размер шрифта описания
   int               LabelSize(void)                                 { return(m_label_font_size);     }
   void              LabelSize(const int sz)                         { m_label_font_size=sz;          }
   //--- Устанавливает и возвращает размер шрифта описания
   int               ValueSize(void)                                 { return(m_value_font_size);     }
   void              ValueSize(const int sz)                         { m_value_font_size=sz;          }
   //--- Устанавливает и возвращает описание индикатора
   string            LabelValue(void)                                { return(m_label_value);         }
   void              LabelValue(const string str)                    { m_label_value=str;             }
   //--- Устанавливает и возвращает тип ориентации шкалы
   void              Orientation(const ENUM_ORIENTATION orietation)  { m_orientation=orietation;      }
   ENUM_ORIENTATION  Orientation(void)                               { return(m_orientation);         }
   //--- Создает индикатор
   void              Create(string name,int x,int y);
   //--- Удаляет индикатор
   void              Delete(void);
   //--- Устанавливает и обновляет значение индикатора
   void              NewValue(double value,double maxvalue,int digits);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCircleArc::CCircleArc(void) : m_bg_color(clrSilver),
                               m_arc_color(clrYellowGreen),
                               m_area_color(clrAliceBlue),
                               m_label_color(clrBlack),
                               m_value_color(clrBlack),
                               m_transparency(255),
                               m_radius(50),
                               m_scale_width(10),
                               m_label_font_size(20),
                               m_value_font_size(20),
                               m_label_value(""),
                               m_orientation(VERTICAL)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCircleArc::~CCircleArc(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CCircleArc::Create(string name,int x,int y)
  {
   int r=m_radius;
   double a,b;
//--- Установка начального положения индикатора
   a=(m_orientation==VERTICAL)?M_PI_2:0;
   b=(m_orientation==VERTICAL)?M_PI_2:0;
   b+=90*M_PI/180;
//--- Коррекция положения индикатор относительно радиуса
   x=(x<r)?r:x;
   y=(y<r)?r:y;
   Name(name);
   X(x);
   Y(y);
   XSize(2*r+1);
   YSize(2*r+1);
   if(!CreateCanvas())
      Print("Error. Can not create Canvas.");

   m_canvas.FillCircle(r,r,r,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.Pie(r,r,XSize()/2,YSize()/2,a,b,ColorToARGB(m_arc_color,m_transparency),ColorToARGB(m_arc_color,m_transparency));
   m_canvas.FillCircle(r,r,r-m_scale_width,ColorToARGB(m_area_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,"0",ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_label_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CCircleArc::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CCircleArc::NewValue(double value,double maxvalue,int digits=2)
  {
   int r=m_radius;
   double a,b,result;
//--- Проверки на выход за пределы диапазона
   value=(value>maxvalue)?maxvalue:value;
   value=(value<0)?0:value;
//--- Установка начального положения индикатора
   a=(m_orientation==VERTICAL)?M_PI_2:0;
   b=(m_orientation==VERTICAL)?M_PI_2:0;
//---
   result=value*(360.0/maxvalue);
   b+=result*M_PI/180;
   if(b>=2*M_PI)
      b=2*M_PI-0.02;
//---
   m_canvas.FillCircle(r,r,r,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.Pie(r,r,XSize()/2,YSize()/2,a,b,ColorToARGB(m_arc_color,m_transparency),ColorToARGB(m_arc_color,m_transparency));
   m_canvas.FillCircle(r,r,r-m_scale_width,ColorToARGB(m_area_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,DoubleToString(value,digits),ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_label_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
