//+------------------------------------------------------------------+
//|                                                CircleRounded.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+--------------------------------------------------------------------------+
//| Круглый индикатор с численным значением и круговой секционной индикацией |
//+--------------------------------------------------------------------------+
class CCircleSection : public CCanvasBase
  {
private:
   //--- Цвет границы деления шкалы
   color             m_bg_color;
   //--- Цвет области индикации 
   color             m_area_color;
   //--- Цвет рамки области индикации
   color             m_border_color;
   //--- Цвет описания индикатора 
   color             m_label_color;
   //--- Цвет значения индикатора
   color             m_value_color;
   //--- Цвет активного/неактивного деления шкалы
   color             m_scale_color_on;
   color             m_scale_color_off;
   //--- Прозрачность индикатора
   uchar             m_transparency;
   //--- Размер индикатора
   int               m_radius;
   //--- Толщина шкалы индикатора 
   int               m_scale_width;
   //--- Толщина рамки области индикации
   int               m_border_size;
   //--- Размер шрифта описания
   int               m_label_font_size;
   //--- Размер шрифта значения
   int               m_value_font_size;
   //--- Описание индикатора
   string            m_label_value;
   //--- Тип ориентации шкалы индикатора
   ENUM_ORIENTATION  m_orientation;
public:
                     CCircleSection(void);
                    ~CCircleSection(void);
   //--- Устанавливает и возвращает цвет границы деления шкалы
   color             BgColor(void)                                   { return(m_bg_color);            }
   void              BgColor(const color clr)                        { m_bg_color=clr;                }
   //--- Устанавливает и возвращает цвет области индикации
   color             AreaColor(void)                                 { return(m_area_color);          }
   void              AreaColor(const color clr)                      { m_area_color=clr;              }
   //--- Устанавливает и возвращает цвет рамки области индикации
   color             BorderColor(void)                               { return(m_border_color);        }
   void              BorderColor(const color clr)                    { m_border_color=clr;            }
   //--- Устанавливает и возвращает цвет описания индикатора 
   color             LabelColor(void)                                { return(m_label_color);         }
   void              LabelColor(const color clr)                     { m_label_color=clr;             }
   //--- Устанавливает и возвращает цвет значения индикатора
   color             ValueColor(void)                                { return(m_value_color);         }
   void              ValueColor(const color clr)                     { m_value_color=clr;             }
   //--- Устанавливает цвет активного/неактивного деления шкалы
   void              ScaleColorOn(const color clr)                   { m_scale_color_on=clr;          }
   void              ScaleColorOff(const color clr)                  { m_scale_color_off=clr;         }
   //--- Устанавливает и возвращает прозрачность индикатора 
   uchar             Alpha(void)                                     { return(m_transparency);        }
   void              Alpha(const uchar trn)                          { m_transparency=trn;            }
   //--- Устанавливает и возвращает размер индикатора
   int               Radius(void)                                    { return(m_radius);              }
   void              Radius(const int r)                             { m_radius=r;                    }
   //--- Устанавливает и возвращает толщину шкалы индикатора
   int               ScaleWidth(void)                                { return(m_scale_width);         }
   void              ScaleWidth(const int scl)                       { m_scale_width=scl;             }
   //--- Устанавливает и возвращает толщину рамки области индикации
   int               BorderSize(void)                                { return(m_border_size);         }
   void              BorderSize(const int sz)                        { m_border_size=sz;              }
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
CCircleSection::CCircleSection(void) : m_bg_color(clrAliceBlue),
                                       m_area_color(clrCornflowerBlue),
                                       m_border_color(clrAliceBlue),
                                       m_label_color(clrWhite),
                                       m_value_color(clrWhite),
                                       m_scale_color_on(clrForestGreen),
                                       m_scale_color_off(clrSilver),
                                       m_transparency(255),
                                       m_radius(40),
                                       m_scale_width(10),
                                       m_border_size(5),
                                       m_label_font_size(20),
                                       m_value_font_size(20),
                                       m_label_value(""),
                                       m_orientation(VERTICAL)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCircleSection::~CCircleSection(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CCircleSection::Create(string name,int x,int y)
  {
   int r=m_radius;
   double a,b;
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
//---
   for(int i=0;i<10;i++)
     {
      if(m_orientation==HORIZONTAL)
        {
         a=36*i*M_PI/180;
         b=36*(i+1)*M_PI/180;
         if(a>2*M_PI)
            a-=2*M_PI;
         if(b>2*M_PI)
            b-=2*M_PI;
        }
      else
        {
         a=M_PI_2+36*i*M_PI/180;
         b=M_PI_2+36*(i+1)*M_PI/180;
         if(a>2*M_PI)
            a-=2*M_PI;
         if(b>2*M_PI)
            b-=2*M_PI;
        }
      m_canvas.Pie(r,r,XSize()/2,YSize()/2,a,b,ColorToARGB(m_bg_color,m_transparency),ColorToARGB(m_scale_color_off,m_transparency));
     }
//---
   m_canvas.FillCircle(r,r,XSize()/2-m_scale_width,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillCircle(r,r,XSize()/2-m_scale_width-m_border_size,ColorToARGB(m_area_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,"0",ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CCircleSection::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CCircleSection::NewValue(double value,double maxvalue=100,int digits=2)
  {
//---
   int r=m_radius;
   double a,b;
   color clr;
//---
   for(int i=0;i<10;i++)
     {
      if(m_orientation==HORIZONTAL)
        {
         a=36*i*M_PI/180;
         b=36*(i+1)*M_PI/180;
         if(a>2*M_PI)
            a-=2*M_PI;
         if(b>2*M_PI)
            b-=2*M_PI;
        }
      else
        {
         a=M_PI_2+36*i*M_PI/180;
         b=M_PI_2+36*(i+1)*M_PI/180;
         if(a>2*M_PI)
            a-=2*M_PI;
         if(b>2*M_PI)
            b-=2*M_PI;
        }
      clr=(maxvalue/10*(i+1)<=value)?m_scale_color_on:m_scale_color_off;
      m_canvas.Pie(r,r,XSize()/2,YSize()/2,a,b,ColorToARGB(m_bg_color,m_transparency),ColorToARGB(clr,m_transparency));
     }
//---
   m_canvas.FillCircle(r,r,XSize()/2-m_scale_width,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillCircle(r,r,XSize()/2-m_scale_width-m_border_size,ColorToARGB(m_area_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,DoubleToString(value,digits),ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
