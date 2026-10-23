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
   //--- Цвет фона индикатора
   color             m_bg_color1;
   //--- Размер графика
   int               m_x_size;
   int               m_y_size;
public:
                     CHexagon(void);
                    ~CHexagon(void);
   //--- Создает индикатор
   void              Create(string name,int x,int y);
   //--- Удаляет индикатор
   void              Delete(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CHexagon::CHexagon(void) : m_bg_color(clrWhite),
                           m_bg_color1(clrYellowGreen),
                           m_x_size(200),
                           m_y_size(400)
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
   int a[4],b[4],c[4],d[4];
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
//---
   m_canvas.FillTriangle(XSize()/2,0,0,YSize()/6,XSize(),YSize()/6,ColorToARGB(m_bg_color));
   m_canvas.FillRectangle(0,YSize()/6,XSize(),5*YSize()/6,ColorToARGB(m_bg_color));
   m_canvas.FillTriangle(0,5*YSize()/6,XSize(),5*YSize()/6,XSize()/2,YSize(),ColorToARGB(m_bg_color));
//---
   m_canvas.FillTriangle(XSize()/2,15,15,YSize()/6,XSize()-15,YSize()/6,ColorToARGB(m_bg_color1));
   m_canvas.FillRectangle(15,YSize()/6,XSize()-15,1.7*YSize()/6,ColorToARGB(m_bg_color1));
   m_canvas.FillTriangle(15,1.7*YSize()/6,XSize()-15,1.7*YSize()/6,XSize()/2,2.5*YSize()/6,ColorToARGB(m_bg_color1));
//---
   a[0]=15;
   a[1]=XSize()-15;
   a[2]=XSize()/2;
   a[3]=15;
   b[0]=YSize()/6;
   b[1]=1.7*YSize()/6;
   b[2]=2.5*YSize()/6;
   b[3]=1.7*YSize()/6;
   m_canvas.FillPolygon(a,b,ColorToARGB(clrForestGreen));
//---
   c[0]=XSize()/2;
   c[1]=XSize()-15;
   c[2]=XSize()-15;
   c[3]=15;
   d[0]=YSize()-15;
   d[1]=5*YSize()/6;
   d[2]=4.3*YSize()/6;
   d[3]=5*YSize()/6;
   m_canvas.FillPolygon(c,d,ColorToARGB(clrLightGreen));
//---
   m_canvas.FontSizeSet(85);
   m_canvas.TextOut(XSize()/2,2.7*YSize()/12,"A",ColorToARGB(m_bg_color),TA_CENTER|TA_VCENTER);
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
