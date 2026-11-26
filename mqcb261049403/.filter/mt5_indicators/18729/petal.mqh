//+------------------------------------------------------------------+
//|                                                        Petal.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Лепестковый индикатор                                            |
//+------------------------------------------------------------------+
enum ENUM_POSITION
  {
   TOPRIGHT=1,
   TOPLEFT=2,
   BOTTOMRIGHT=3,
   BOTTOMLEFT=4,
   BOTHRIGHT=5,
   BOTHLEFT=6
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPetal : public CCanvasBase
  {
private:
   //--- Цвет фона индикатора
   color             m_bg_color;
   //--- Цвет описания индикатора 
   color             m_label_color;
   //--- Цвет значения индикатора
   color             m_value_color;
   //--- Прозрачность индикатора
   uchar             m_transparency;
   //--- Тип ориентации индикатора
   ENUM_POSITION     m_orientation;
   //--- Размер 
   int               m_radius;
   //--- Размер шрифта описания
   int               m_label_font_size;
   //--- Размер шрифта значения
   int               m_value_font_size;
   //--- Описание индикатора
   string            m_label_value;
public:
                     CPetal(void);
                    ~CPetal(void);
   //--- Устанавливает и возвращает тип ориентации шкалы
   void              Orientation(const ENUM_POSITION orietation)     { m_orientation=orietation;      }
   ENUM_POSITION     Orientation(void)                               { return(m_orientation);         }
   //--- Устанавливает и возвращает цвет фона
   color             BgColor(void)                                   { return(m_bg_color);            }
   void              BgColor(const color clr)                        { m_bg_color=clr;                }
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
   //--- Устанавливает и возвращает размер шрифта описания
   int               LabelSize(void)                                 { return(m_label_font_size);     }
   void              LabelSize(const int sz)                         { m_label_font_size=sz;          }
   //--- Устанавливает и возвращает размер шрифта значения
   int               ValueSize(void)                                 { return(m_value_font_size);     }
   void              ValueSize(const int sz)                         { m_value_font_size=sz;          }
   //--- Устанавливает и возвращает описание индикатора
   string            LabelValue(void)                                { return(m_label_value);         }
   void              LabelValue(const string str)                    { m_label_value=str;             }
   //--- Создает индикатор
   void              Create(string name,int x,int y);
   //--- Удаляет индикатор
   void              Delete(void);
   //--- Устанавливает и обновляет значение индикатора
   void              NewValue(double value,int digits);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPetal::CPetal(void) : m_bg_color(clrDodgerBlue),
                       m_label_color(clrWhite),
                       m_value_color(clrWhite),
                       m_transparency(255),
                       m_orientation(TOPLEFT),
                       m_radius(50),
                       m_label_font_size(20),
                       m_value_font_size(20),
                       m_label_value("Label")
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPetal::~CPetal(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CPetal::Create(string name,int x,int y)
  {
   int r=m_radius;
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
   m_canvas.FillCircle(r,r,r,ColorToARGB(m_bg_color,m_transparency));
   if(m_orientation==TOPRIGHT)
      m_canvas.FillTriangle(XSize()/2,0,XSize(),0,XSize(),YSize()/2,ColorToARGB(m_bg_color,m_transparency));
   else if(m_orientation==TOPLEFT)
      m_canvas.FillTriangle(0,0,XSize()/2,0,0,YSize()/2,ColorToARGB(m_bg_color,m_transparency));
   else if(m_orientation==BOTTOMRIGHT)
      m_canvas.FillTriangle(XSize(),YSize(),XSize(),YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
   else if(m_orientation==BOTTOMLEFT)
      m_canvas.FillTriangle(0,YSize(),0,YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
   else if(m_orientation==BOTHRIGHT)
     {
      m_canvas.FillTriangle(XSize()/2,0,XSize(),0,XSize(),YSize()/2,ColorToARGB(m_bg_color,m_transparency));
      m_canvas.FillTriangle(0,YSize(),0,YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
     }
   else if(m_orientation==BOTHLEFT)
     {
      m_canvas.FillTriangle(0,0,XSize()/2,0,0,YSize()/2,ColorToARGB(m_bg_color,m_transparency));
      m_canvas.FillTriangle(XSize(),YSize(),XSize(),YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
     }
//--- Описание и численные значения
   m_canvas.FontNameSet("Trebuchet MS");
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,"-",ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CPetal::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CPetal::NewValue(double value,int digits)
  {
   int r=m_radius;
//---
   m_canvas.FillCircle(r,r,r,ColorToARGB(m_bg_color,m_transparency));
//--- Описание и численные значения
   m_canvas.FontNameSet("Trebuchet MS");
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r,r,"-",ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
