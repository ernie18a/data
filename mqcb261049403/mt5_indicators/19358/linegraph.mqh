//+------------------------------------------------------------------+
//|                                                    LineGraph.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include "..\CanvasBase.mqh"
//+------------------------------------------------------------------+
//| Линейный график                                                  |
//+------------------------------------------------------------------+
class CLineGraph : public CCanvasBase
  {
private:
   //--- Цвет заднего фона графика
   color             m_bg_color;
   //--- Цвет фона графика
   color             m_bg_graph_color;
   //--- Цвет рамки графика
   color             m_border_color;
   //--- Цвет значений осей графика
   color             m_axis_color;
   //--- Цвет сетки графика
   color             m_grid_color;
   //--- Цвет делений на осях графика
   color             m_scale_color;
   //--- Цвет линий графика
   color             m_graph_color;
   //--- Размер графика
   int               m_x_size;
   int               m_y_size;
   //--- Отступ графика от края заднего фона
   int               m_gap;
   //--- Размер шрифта значений на осях графика
   int               m_font_size;
   //--- Массив значений оси ординат(y)
   int               m_x[];
   //--- Минимальное и максимальное значение оси ординат
   double            m_y_min;
   double            m_y_max;
   //--- Количество делений оси ординат
   int               m_num_grid;
   //--- Прозрачность графика
   uchar             m_transparency;
public:
                     CLineGraph(void);
                    ~CLineGraph(void);
   //--- Устанавливает и возвращает цвет заднего фона графика
   color             BgColor(void)                                   { return(m_bg_color);                  }
   void              BgColor(const color clr)                        { m_bg_color=clr;                      }
   //--- Устанавливает и возвращает цвет фона графика
   color             BgGraphColor(void)                              { return(m_bg_graph_color);            }
   void              BgGraphColor(const color clr)                   { m_bg_graph_color=clr;                }
   //--- Устанавливает и возвращает цвет рамки графика
   color             BorderColor(void)                               { return(m_border_color);              }
   void              BorderColor(const color clr)                    { m_border_color=clr;                  }
   //--- Устанавливает и возвращает цвет значений осей графика
   color             AxisColor(void)                                 { return(m_axis_color);                }
   void              AxisColor(const color clr)                      { m_axis_color=clr;                    }
   //--- Устанавливает и возвращает цвет сетки графика
   color             GridColor(void)                                 { return(m_grid_color);                }
   void              GridColor(const color clr)                      { m_grid_color=clr;                    }
   //--- Устанавливает и возвращает цвет делений на осях графика
   color             ScaleColor(void)                                { return(m_scale_color);               }
   void              ScaleColor(const color clr)                     { m_scale_color=clr;                   }
   //--- Устанавливает и возвращает цвет линий графика
   color             GraphColor(void)                                { return(m_graph_color);               }
   void              GraphColor(const color clr)                     { m_graph_color=clr;                   }
   //--- Устанавливает и возвращает размеры графика
   int               XGraphSize(void)                                { return(m_x_size);                    }
   void              XGraphSize(const int x_size)                    { m_x_size=x_size;                     }
   int               YGraphSize(void)                                { return(m_y_size);                    }
   void              YGraphSize(const int y_size)                    { m_y_size=y_size;                     }
   //--- Устанавливает и возвращает размер шрифта значений на осях графика
   int               FontSize(void)                                  { return(m_font_size);                 }
   void              FontSize(const int fontzise)                    { m_font_size=fontzise;                }
   //--- Устанавливает и возвращает отступ графика от края заднего фона
   int               Gap(void)                                       { return(m_gap);                       }
   void              Gap(const int g)                                { m_gap=g;                             }
   //--- Устанавливает и возвращает минимальное и максимальное значение оси ординат
   double            YMin(void)                                      { return(m_y_min);                     }
   void              YMin(const double ymin)                         { m_y_min=ymin;                        }
   double            YMax(void)                                      { return(m_y_max);                     }
   void              YMax(const double ymax)                         { m_y_max=ymax;                        }
   //--- Устанавливает и возвращает количество делений оси ординат
   int               NumGrid(void)                                   { return(m_num_grid);                  }
   void              NumGrid(const int num)                          { m_num_grid=num;                      }
   //--- Создает график
   void              Create(string name,int x,int y);
   //--- Удаляет график 
   void              Delete(void);
   //--- Устанавливает массив входных данных
   void              SetArrayValue(double &data[]);
private:
   //---
   void              VerticalScale(double min,double max,int num_grid);
   void              HorizontalScale(int num_grid);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CLineGraph::CLineGraph(void) : m_bg_color(clrWhite),
                               m_bg_graph_color(clrWhite),
                               m_border_color(clrBlack),
                               m_axis_color(clrNavy),
                               m_grid_color(clrGray),
                               m_scale_color(clrNavy),
                               m_graph_color(clrBlack),
                               m_x_size(500),
                               m_y_size(300),
                               m_gap(40),
                               m_font_size(16),
                               m_y_min(0),
                               m_y_max(100),
                               m_num_grid(5),
                               m_transparency(255)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CLineGraph::~CLineGraph(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает график                                                   |
//+------------------------------------------------------------------+
void CLineGraph::Create(string name,int x,int y)
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
//--- Создание рамки графика и заднего фона
   m_canvas.FillRectangle(0,0,XSize(),YSize(),ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillRectangle(1,1,XSize()-2,YSize()-2,ColorToARGB(m_bg_color,m_transparency));
//--- Создание осей и фона графика
   m_canvas.FillRectangle(m_gap-1,m_gap-1,XSize()-m_gap+1,YSize()-m_gap+1,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillRectangle(m_gap,m_gap,XSize()-m_gap,YSize()-m_gap,ColorToARGB(m_bg_graph_color,m_transparency));
//--- Создание делений оси и их значений
   VerticalScale(m_y_min,m_y_max,m_num_grid);
   HorizontalScale(5);
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Удаляет график                                                   |
//+------------------------------------------------------------------+
void CLineGraph::Delete(void)
  {
   DeleteCanvas();
  }
//+------------------------------------------------------------------+
//| Устанавливает массив входных данных                              |
//+------------------------------------------------------------------+
void CLineGraph::SetArrayValue(double &data[])
  {
   int y0,y1;
//--- Создание рамки графика и заднего фона
   m_canvas.FillRectangle(0,0,XSize(),YSize(),ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillRectangle(1,1,XSize()-2,YSize()-2,ColorToARGB(m_bg_color,m_transparency));
//--- Создание осей и фона графика
   m_canvas.FillRectangle(m_gap-1,m_gap-1,XSize()-m_gap+1,YSize()-m_gap+1,ColorToARGB(m_border_color,m_transparency));
   m_canvas.FillRectangle(m_gap,m_gap,XSize()-m_gap,YSize()-m_gap,ColorToARGB(m_bg_graph_color,m_transparency));
//--- Если максимальное значение в массиве данных превышает верхний предел оси Y, то масштабируем ось.
   if(data[ArrayMaximum(data)]>m_y_max)
      m_y_max=data[ArrayMaximum(data)];
//--- Создание делений оси и их значений
   VerticalScale(m_y_min,m_y_max,m_num_grid);
   HorizontalScale(ArraySize(data));
//--- Построение графика по массиву данных
   for(int i=0;i<ArraySize(data)-1;i++)
     {
      y0=int((YSize()-2*m_gap)*(1-data[i]/m_y_max));
      y0=int((YSize()-m_gap)-(YSize()-2*m_gap)/m_y_max*data[i]);
      y0=(y0<m_gap)?m_gap:y0;
      y1=int((YSize()-m_gap)-(YSize()-2*m_gap)/m_y_max*data[i+1]);
      y1=(y1<m_gap)?m_gap:y1;
      m_canvas.LineAA(m_x[i+1],y0,m_x[i+2],y1,ColorToARGB(m_graph_color,m_transparency),STYLE_SOLID);
      m_canvas.FillCircle(m_x[i+1],y0,2,ColorToARGB(m_graph_color,m_transparency));
      m_canvas.FillCircle(m_x[i+2],y1,2,ColorToARGB(m_graph_color,m_transparency));
     }
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Установка параметров оси Y                                       |
//+------------------------------------------------------------------+
void CLineGraph::VerticalScale(const double min,const double max,const int num_grid)
  {
   double s,v,scale;
   s=(YSize()-2*m_gap)/num_grid;
   m_canvas.FontSizeSet(m_font_size);
   m_canvas.TextOut(m_gap-20,YSize()-m_gap,DoubleToString(min,0),ColorToARGB(m_axis_color,m_transparency),TA_CENTER|TA_VCENTER);
   for(int i=num_grid;i>=1;i--)
     {
      scale=YSize()-m_gap-s*i;
      v=(max-min)/(num_grid)*i;
      m_canvas.TextOut(m_gap-20,int(scale),DoubleToString(v,0),ColorToARGB(m_axis_color,m_transparency),TA_CENTER|TA_VCENTER);
      m_canvas.LineAA(m_gap,int(scale),XSize()-m_gap,int(scale),ColorToARGB(m_grid_color,m_transparency),STYLE_DOT);
      m_canvas.LineHorizontal(m_gap-5,m_gap+5,int(scale),ColorToARGB(m_scale_color,m_transparency));
     }
  }
//+------------------------------------------------------------------+
//| Установка параметров оси X                                       |
//+------------------------------------------------------------------+
void CLineGraph::HorizontalScale(int num_grid)
  {
   if(num_grid<2)
      return;
   ArrayResize(m_x,num_grid+1);
   m_x[0]=m_gap;
   double s,scale;
   s=(XSize()-2*m_gap)/num_grid;
   m_canvas.FontSizeSet(m_font_size);
   for(int i=num_grid;i>=1;i--)
     {
      scale=m_gap+s*i;
      scale=(i==num_grid)?XSize()-m_gap:scale;
      m_canvas.LineVertical(int(scale),YSize()-m_gap-5,YSize()-m_gap+5,ColorToARGB(m_scale_color,m_transparency));
      m_canvas.TextOut(int(scale),YSize()-m_gap+20,IntegerToString(i),ColorToARGB(m_axis_color,m_transparency),TA_CENTER|TA_VCENTER);
      m_x[i]=int(scale);
     }
  }
//+------------------------------------------------------------------+
