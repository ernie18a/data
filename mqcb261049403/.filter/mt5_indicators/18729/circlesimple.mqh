//+------------------------------------------------------------------+
//|                                                 CircleSimple.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Круглый индикатор с численным значением и описанием              |
//+------------------------------------------------------------------+
class CCircleSimple : public CCanvasBase
  {
private:
   //--- Цвет фона 
   color             m_bg_color;
   //--- Цвет рамки
   color             m_border_color;
   //--- Цвет текста значения
   color             m_font_color;
   //--- Цвет текста надписи
   color             m_label_color;
   //--- Прозрачность
   uchar             m_transparency;
   //--- Толщина рамки
   int               m_border;
   //--- Размер индикатора
   int               m_radius;
   //--- Размер шрифта значения
   int               m_font_size;
   //--- Размер шрифта надписи
   int               m_label_font_size;
   //---
   int               m_digits;
   //--- Надпись
   string            m_label;
public:
                     CCircleSimple(void);
                    ~CCircleSimple(void);
   //--- Устанавливает и возвращает цвет фона
   color             Color(void)                      { return(m_bg_color);            }
   void              Color(const color clr)           { m_bg_color=clr;                }
   //--- Устанавливает и возвращает размер
   int               Radius(void)                     { return(m_radius);              }
   void              Radius(const int r)              { m_radius=r;                    }
   //--- Устанавливает и возвращает размер шрифта значения
   int               FontSize(void)                   { return(m_font_size);           }
   void              FontSize(const int fontsize)     { m_font_size=fontsize;          }
   //--- Устанавливает и возвращает размер шрифта надписи
   int               LabelSize(void)                  { return(m_label_font_size);    }
   void              LabelSize(const int fontsize)    { m_label_font_size=fontsize;   }
   //--- Устанавливает и возвращает цвет шрифта значения
   color             FontColor(void)                  { return(m_font_color);          }
   void              FontColor(const color fontcolor) { m_font_color=fontcolor;        }
   //--- Устанавливает и возвращает цвет шрифта надписи
   color             LabelColor(void)                 { return(m_label_color);         }
   void              LabelColor(const color fontcolor){ m_label_color=fontcolor;       }
   //--- Устанавливает цвет и толщину рамки
   void              BorderColor(const color clr)     { m_border_color=clr;            }
   void              BorderSize(const int border)     { m_border=border;               }
   //--- Устанавливает и возвращает прозрачность
   uchar             Alpha(void)                      { return(m_transparency);        }
   void              Alpha(const uchar alpha)         { m_transparency=alpha;          }
   //--- Устанавливает и возвращает значение надписи
   string            Label(void)                      { return(m_label);               }
   void              Label(const string label)        { m_label=label;                 }
   //--- Создает индикатор
   void              Create(string name,int x,int y);
   //--- Удаляет индикатор
   void              Delete(void);
   //--- Устанавливает и обновляет значение индикатора
   void              NewValue(int value);
   void              NewValue(double value);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCircleSimple::CCircleSimple(void) : m_bg_color(clrAliceBlue),
                                     m_border_color(clrRoyalBlue),
                                     m_font_color(clrBlack),
                                     m_label_color(clrBlack),
                                     m_transparency(255),
                                     m_border(5),
                                     m_radius(40),
                                     m_font_size(17),
                                     m_label_font_size(20),
                                     m_digits(2),
                                     m_label("label")
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCircleSimple::~CCircleSimple(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CCircleSimple::Create(string name,int x,int y)
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
   if(m_border>0)
      m_canvas.FillCircle(r,r,r,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillCircle(r,r,r-m_border,ColorToARGB(m_bg_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.TextOut(r,r,"0",ColorToARGB(m_font_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_label_font_size,m_label,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CCircleSimple::NewValue(int value)
  {
   int r=m_radius;
   m_canvas.FillCircle(r,r,r-m_border,ColorToARGB(m_bg_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.TextOut(r,r,IntegerToString(value),ColorToARGB(m_font_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_label_font_size,m_label,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CCircleSimple::NewValue(double value)
  {
   int r=m_radius;
   m_canvas.FillCircle(r,r,r-m_border,ColorToARGB(m_bg_color,m_transparency));
//---
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.TextOut(r,r,DoubleToString(value,m_digits),ColorToARGB(m_font_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r,r+m_label_font_size,m_label,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CCircleSimple::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
