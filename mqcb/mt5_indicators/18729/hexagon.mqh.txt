//+------------------------------------------------------------------+
//|                                                     CHexagon.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Круглый индикатор с численным значением и дуговой индикацией     |
//+------------------------------------------------------------------+
class CHexagon : public CCanvasBase
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
   //--- Размер индикатора
   int               m_size;
   //--- Размер шрифта описания
   int               m_label_font_size;
   //--- Размер шрифта значения
   int               m_value_font_size;
   //--- Описание индикатора
   string            m_label_value;
public:
                     CHexagon(void);
                    ~CHexagon(void);
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
   int               Size(void)                                      { return(m_size);                }
   void              Size(const int r)                               { m_size=r;                      }
   //--- Устанавливает и возвращает размер шрифта описания
   int               LabelSize(void)                                 { return(m_label_font_size);     }
   void              LabelSize(const int sz)                         { m_label_font_size=sz;          }
   //--- Устанавливает и возвращает размер шрифта описания
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
CHexagon::CHexagon(void) : m_bg_color(C'105,200,240'),
                           m_label_color(clrWhite),
                           m_value_color(clrWhite),
                           m_transparency(255),
                           m_size(100),
                           m_label_font_size(20),
                           m_value_font_size(20),
                           m_label_value("Label")
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CHexagon::~CHexagon(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CHexagon::Create(string name,int x,int y)
  {
   int a,r;
   r=m_size;
//--- Коррекция положения индикатор относительно
   x=(x<r/2)?r/2:x;
   y=(y<r/2)?r/2:y;
   Name(name);
   X(x);
   Y(y);
   XSize(r);
   YSize(r);
   if(!CreateCanvas())
      Print("Error. Can not create Canvas.");
//--- Вычисление высоты треугольников
   a=int(YSize()/2*MathSin(30*M_PI/180));
//--- Шестиугольная форма
   m_canvas.FillTriangle(XSize()/2,0,0,a,XSize(),a,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillRectangle(0,a,XSize(),a+YSize()/2,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillTriangle(0,a+YSize()/2,XSize(),a+YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
//--- Описание и численные значения
   m_canvas.FontNameSet("Trebuchet MS");
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r/2,r/2,"-",ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r/2,r/2+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CHexagon::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CHexagon::NewValue(double value,int digits=2)
  {
   int a,r;
   r=m_size;
//--- Вычисление высоты треугольников
   a=int(YSize()/2*MathSin(30*M_PI/180));
//--- Шестиугольная форма
   m_canvas.FillTriangle(XSize()/2,0,0,a,XSize(),a,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillRectangle(0,a,XSize(),a+YSize()/2,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillTriangle(0,a+YSize()/2,XSize(),a+YSize()/2,XSize()/2,YSize(),ColorToARGB(m_bg_color,m_transparency));
//--- Текст
   m_canvas.FontNameSet("Trebuchet MS");
   m_canvas.FontSizeSet(m_value_font_size);
   m_canvas.TextOut(r/2,r/2,DoubleToString(value,digits),ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.FontSizeSet(m_label_font_size);
   m_canvas.TextOut(r/2,r/2+m_value_font_size,m_label_value,ColorToARGB(m_label_color,m_transparency),TA_CENTER|TA_VCENTER);
//---
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
