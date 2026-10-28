//+------------------------------------------------------------------+
//|                                                  LineRounded.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Закругленный линейный индикатор                                  |
//+------------------------------------------------------------------+
class CLineRounded : public CCanvasBase
  {
private:
   //--- Цвет заднего фона
   color             m_bg_color;
   //--- Цвет рамки индикатора
   color             m_border_color;
   //--- Цвет шкалы индикатора
   color             m_scale_color;
   //--- Цвет численного значения
   color             m_value_color;
   //--- Размер индикатора
   int               m_x_size;
   int               m_y_size;
   //--- Толщина рамки
   int               m_border;
   //--- Размер шрифта численного значения
   int               m_font_size;
   //--- Прозрачность
   uchar             m_transparency;
public:
                     CLineRounded(void);
                    ~CLineRounded(void);
   //--- Устанавливает и возвращает цвет заднего фона
   color             BgColor(void)                                   { return(m_bg_color);                  }
   void              BgColor(const color clr)                        { m_bg_color=clr;                      }
   //--- Устанавливает и возвращает цвет рамки индикатора
   color             BorderColor(void)                               { return(m_border_color);              }
   void              BorderColor(const color clr)                    { m_border_color=clr;                  }
   //--- Устанавливает и возвращает цвет шкалы индикатора
   color             ScaleColor(void)                                { return(m_scale_color);               }
   void              ScaleColor(const color clr)                     { m_scale_color=clr;                   }
   //--- Устанавливает и возвращает цвет линий индикатора
   color             ValueColor(void)                                { return(m_value_color);               }
   void              ValueColor(const color clr)                     { m_value_color=clr;                   }
   //--- Устанавливает и возвращает размеры индикатора
   int               XSizeInd(void)                                  { return(m_x_size);                    }
   void              XSizeInd(const int x_size)                      { m_x_size=x_size;                     }
   int               YSizeInd(void)                                  { return(m_y_size);                    }
   void              YSizeInd(const int y_size)                      { m_y_size=y_size;                     }
   //--- Устанавливает и возвращает толщину рамки
   int               Border(void)                                    { return(m_border);                    }
   void              Border(const int border)                        { m_border=border;                     }
   //--- Устанавливает и возвращает размер шрифта численного значения
   int               FontSize(void)                                  { return(m_font_size);                 }
   void              FontSize(const int fontzise)                    { m_font_size=fontzise;                }
   //--- Устанавливает и возвращает прозрачность
   uchar             Alpha(void)                                     { return(m_transparency);              }
   void              Alpha(const uchar alpha)                        { m_transparency=alpha;                }
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
CLineRounded::CLineRounded(void) : m_bg_color(clrGainsboro),
                                   m_border_color(C'100,200,255'),
                                   m_scale_color(clrForestGreen),
                                   m_x_size(300),
                                   m_y_size(20),
                                   m_border(5),
                                   m_font_size(16),
                                   m_transparency(255)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLineRounded::~CLineRounded(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CLineRounded::Create(string name,int x,int y)
  {
//--- Коррекция положения индикатор относительно
   x=(x<m_x_size/2)?m_x_size/2:x;
   y=(y<m_y_size/2)?m_y_size/2:y;
   Name(name);
   X(x);
   Y(y);
   XSize(m_x_size);
   YSize(m_y_size);
   if(!CreateCanvas())
      Print("Error. Can not create Canvas.");
//--- Рамка
   m_canvas.FillRectangle(YSize()/2,0,XSize()-YSize()/2,YSize(),ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillCircle(YSize()/2,YSize()/2-1,YSize()/2,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillCircle(XSize()-YSize()/2-1,YSize()/2,YSize()/2,ColorToARGB(m_border_color,m_transparency));
//--- Задний фон
   m_canvas.FillRectangle(YSize()/2,m_border,XSize()-YSize()/2,YSize()-m_border,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillCircle(YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillCircle(XSize()-YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CLineRounded::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CLineRounded::NewValue(double value,double maxvalue,int digits=0)
  {
   int v;
   v=int((XSize()-YSize()/2)/maxvalue*value);

//--- Задний фон
   m_canvas.FillRectangle(YSize()/2,m_border,XSize()-YSize()/2,YSize()-m_border,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillCircle(YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_bg_color,m_transparency));
   m_canvas.FillCircle(XSize()-YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_bg_color,m_transparency));
//--- Шкала
   if(v>=YSize()/2 && v<=(XSize()-YSize()/2))
     {
      m_canvas.FillRectangle(YSize()/2,m_border,v,YSize()-m_border,ColorToARGB(m_scale_color,m_transparency));
      m_canvas.FillCircle(YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_scale_color,m_transparency));
      m_canvas.FillCircle(v,YSize()/2,YSize()/2-m_border,ColorToARGB(m_scale_color,m_transparency));
     }
   else if(v>(XSize()-YSize()/2))
     {
      m_canvas.FillRectangle(YSize()/2,m_border,XSize()-YSize()/2,YSize()-m_border,ColorToARGB(m_scale_color,m_transparency));
      m_canvas.FillCircle(YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_scale_color,m_transparency));
      m_canvas.FillCircle(XSize()-YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_scale_color,m_transparency));
     }
   else if(v>0 && v<YSize()/2)
      m_canvas.FillCircle(YSize()/2,YSize()/2,YSize()/2-m_border,ColorToARGB(m_scale_color,m_transparency));

//--- Численное значение
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.TextOut(XSize()/2,YSize()/2,DoubleToString(value,digits),ColorToARGB(m_value_color,m_transparency),TA_CENTER|TA_VCENTER);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
