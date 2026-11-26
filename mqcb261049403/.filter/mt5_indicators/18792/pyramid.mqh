//+------------------------------------------------------------------+
//|                                                      Pyramid.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Лепестковый индикатор                                            |
//+------------------------------------------------------------------+
class CPyramid : public CCanvasBase
  {
private:
   //--- Массив цветов активного состояния секций
   color             m_section_color[];
   //--- Цвет неактивного состояния секции
   color             m_bg_color;
   //--- Цвет делений шкалы
   color             m_scale_color;
   //--- Цвет значений шкалы
   color             m_label_color;
   //--- Размер индикатора
   int               m_size;
   //--- Размер шрифта описания
   int               m_font_size;
   //--- Массивы для коэффициентов уравнений прямых
   double            m_line1[];
   double            m_line2[];
   //--- Массив для координат точки пересечения прямых
   double            m_cross[];
   //--- Прозрачность индикатора
   uchar             m_transparency;
public:
                     CPyramid(void);
                    ~CPyramid(void);
   //--- Устанавливает цвет заданной секции
   void              SectionColor(color clr,int number);
   //--- Устанавливает и возвращает цвет неактивного состояния секции
   color             BgColor(void)                                   { return(m_bg_color);                  }
   void              BgColor(const color clr)                        { m_bg_color=clr;                      }
   //--- Устанавливает и возвращает цвет делений шкалы
   color             ScaleColor(void)                                { return(m_scale_color);               }
   void              ScaleColor(const color clr)                     { m_scale_color=clr;                   }
   //--- Устанавливает и возвращает цвет описания индикатора 
   color             LabelColor(void)                                { return(m_label_color);               }
   void              LabelColor(const color clr)                     { m_label_color=clr;                   }
   //--- Устанавливает и возвращает размер индикатора
   int               Size(void)                                      { return(m_size);                      }
   void              Size(const int size)                            { m_size=size;                         }
   //--- Устанавливает и возвращает размер индикатора
   int               FontSize(void)                                  { return(m_font_size);                 }
   void              FontSize(const int fontsize)                    { m_font_size=fontsize;                }
   //--- Устанавливает и возвращает прозрачность индикатора 
   uchar             Alpha(void)                                     { return(m_transparency);              }
   void              Alpha(const uchar trn)                          { m_transparency=trn;                  }
   //--- Создает индикатор
   void              Create(string name,int x,int y);
   //--- Удаляет индикатор
   void              Delete(void);
   //--- Устанавливает и обновляет значение индикатора
   void              NewValue(double value,double maxvalue);
private:
   //--- Записывает в массив коэффициенты уравнения прямой по двум точкам
   void              Equation(double x1,double y1,double x2,double y2,double &arr[]);
   //--- Записывает в массив координаты точки пересечения двух прямх по их коэффициентам
   void              Cross(double k1,double b1,double k2,double b2,double &arr[]);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPyramid::CPyramid(void) : m_bg_color(clrSilver),
                           m_scale_color(clrWhite),
                           m_label_color(clrWhite),
                           m_size(400),
                           m_font_size(14),
                           m_transparency(255)
  {
   ArrayResize(m_section_color,5);
   m_section_color[0]=C'240,0,0';
   m_section_color[1]=C'250,150,70';
   m_section_color[2]=C'0,175,80';
   m_section_color[3]=C'0,115,200';
   m_section_color[4]=clrMidnightBlue;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPyramid::~CPyramid(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает индикатор                                                |
//+------------------------------------------------------------------+
void CPyramid::Create(string name,int x,int y)
  {
   int size=m_size;
//--- Коррекция положения индикатор относительно его размера
   x=(x<size/2)?size/2:x;
   y=(y<size/2)?size/2:y;
   Name(name);
   X(x);
   Y(y);
   XSize(size);
   YSize(size);
   if(!CreateCanvas())
      Print("Error. Can not create Canvas.");
//--- Описание и численные значения
   m_canvas.FontNameSet("Trebuchet MS");
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.FontAngleSet(200);
//--- Нахождение уравнения прямой AB
   double x1,x2,y1,y2;
   x1=XSize()/2;y1=0;
   x2=0;y2=4*YSize()/5;
   Equation(x1,y1,x2,y2,m_line1);
//--- Построение левых секций индикатора
   for(int i=5;i>0;i--)
     {
      //--- Определение ординат двух точек 
      y1=i*YSize()/5;
      y2=(i-1)*YSize()/5;
      Equation(x1,y1,x2,y2,m_line2);
      //--- Определение координат точки пересечение ребра AB и прямой, параллельной стороне основания пирамиды
      Cross(m_line1[0],m_line1[1],m_line2[0],m_line2[1],m_cross);
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_section_color[i-1],m_transparency));
      //--- Построение делений шкалы
      m_canvas.LineAA(int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_scale_color,m_transparency));
     }
//--- Нахождение уравнения прямой AC
   x1=XSize()/2;y1=0;
   x2=XSize();y2=4*YSize()/5;
   Equation(x1,y1,x2,y2,m_line1);
//--- Построение правых секций индикатора
   for(int i=5;i>0;i--)
     {
      //--- Определение ординат двух точек 
      y1=i*YSize()/5;
      y2=(i-1)*YSize()/5;
      Equation(x1,y1,x2,y2,m_line2);
      //--- Определение координат точки пересечение ребра AС и прямой, параллельной стороне основания пирамиды
      Cross(m_line1[0],m_line1[1],m_line2[0],m_line2[1],m_cross);
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_section_color[i-1]));
      //--- Построение делений шкалы
      m_canvas.LineAA(int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_scale_color,m_transparency));
      //--- Построение значений шкалы
      m_canvas.TextOut(int(x1+2),int(y2+YSize()/6)," - ",ColorToARGB(m_label_color,m_transparency),TA_LEFT|TA_VCENTER);
     }
   m_canvas.LineVertical(XSize()/2,0,YSize(),ColorToARGB(m_scale_color,m_transparency));
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Устанавливает и обновляет значение индикатора                    |
//+------------------------------------------------------------------+
void CPyramid::NewValue(double value,double maxvalue)
  {
//---
   double s;
   color col;
//--- Нахождение уравнения прямой AB
   double x1,x2,y1,y2;
   x1=XSize()/2;y1=0;
   x2=0;y2=4*YSize()/5;
   Equation(x1,y1,x2,y2,m_line1);
//--- Построение левых секций индикатора
   for(int i=5;i>0;i--)
     {
      //--- Нахождение значений деления шкалы
      s=maxvalue-(i-1)*maxvalue/5;
      //--- Определение цвета секции
      col=(value>=s)?m_section_color[i-1]:m_bg_color;
      //--- Определение ординат двух точек 
      y1=i*YSize()/5;
      y2=(i-1)*YSize()/5;
      Equation(x1,y1,x2,y2,m_line2);
      //--- Определение координат точки пересечение ребра AB и прямой, параллельной стороне основания пирамиды
      Cross(m_line1[0],m_line1[1],m_line2[0],m_line2[1],m_cross);
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_section_color[i-1],m_transparency));
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(col,m_transparency));
      //--- Построение делений шкалы
      m_canvas.LineAA(int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(clrWhite));
     }
//--- Нахождение уравнения прямой AC
   x1=XSize()/2;y1=0;
   x2=XSize();y2=4*YSize()/5;
   Equation(x1,y1,x2,y2,m_line1);
//--- Построение правых секций индикатора
   for(int i=5;i>0;i--)
     {
      //--- Нахождение значений деления шкалы
      s=maxvalue-(i-1)*maxvalue/5;
      //--- Определение цвета секции
      col=(value>=s)?m_section_color[i-1]:m_bg_color;
      //--- Определение ординат двух точек 
      y1=i*YSize()/5;
      y2=(i-1)*YSize()/5;
      Equation(x1,y1,x2,y2,m_line2);
      //--- Определение координат точки пересечение ребра AС и прямой, параллельной стороне основания пирамиды
      Cross(m_line1[0],m_line1[1],m_line2[0],m_line2[1],m_cross);
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_section_color[i-1],m_transparency));
      m_canvas.FillTriangle(int(x1),0,int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(col,m_transparency));
      //--- Построение делений шкалы
      m_canvas.LineAA(int(x1),int(y1),int(m_cross[0]),int(m_cross[1]),ColorToARGB(m_scale_color,m_transparency));
      //--- Построение значений шкалы
      m_canvas.TextOut(int(x1+2),int(y2+YSize()/6),DoubleToString(s,0),ColorToARGB(m_label_color,m_transparency),TA_LEFT|TA_VCENTER);
     }
   m_canvas.LineVertical(XSize()/2,0,YSize(),ColorToARGB(m_scale_color,m_transparency));
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет индикатор                                                |
//+------------------------------------------------------------------+
void CPyramid::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPyramid::SectionColor(color clr,int number)
  {
   number=(number>5)?5:number;
   m_section_color[number-1]=clr;
  }
//+------------------------------------------------------------------+
//| Записывает в массив коэффициенты уравнения прямой по двум точкам |
//+------------------------------------------------------------------+
void CPyramid::Equation(double x1,double y1,double x2,double y2,double &arr[])
  {
   ArrayResize(arr,2);
   arr[0]=(y1-y2)/(x1-x2);
   arr[1]=y2-arr[0]*x2;
//printf("Уравнение прямой: y = %.2fx + %.2f",arr[0],arr[1]);
  }
//+----------------------------------------------------------------------------------+
//| Записывает в массив координаты точки пересечения двух прямых по их коэффициентам |
//+----------------------------------------------------------------------------------+
void CPyramid::Cross(double k1,double b1,double k2,double b2,double &arr[])
  {
   double x,y;
   ArrayResize(arr,2);
   y=(b1*k2-b2*k1)/(k2-k1);
   x=(y-b2)/k2;
   arr[0]=x;
   arr[1]=y;
//printf("Точка пересечения: (%.2f , %.2f)",arr[0],arr[1]);
  }
//+------------------------------------------------------------------+
