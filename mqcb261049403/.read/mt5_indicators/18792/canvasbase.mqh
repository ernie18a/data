//+------------------------------------------------------------------+
//|                                                  CCanvasBase.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>
//+------------------------------------------------------------------+
//| Базовый класс для создания пользовательской графики              |
//+------------------------------------------------------------------+
enum ENUM_ORIENTATION
  {
   VERTICAL=1,
   HORIZONTAL=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCanvasBase
  {
private:
   //--- Имя холста
   string            m_canvas_name;
   //--- Координаты холста
   int               m_x;
   int               m_y;
   //--- Размер холста
   int               m_x_size;
   int               m_y_size;
protected:
   CCanvas           m_canvas;
   //--- Создает графический ресурс для объекта
   bool              CreateCanvas(void);
   //--- Удаляет графический ресурс
   bool              DeleteCanvas(void);
public:
                     CCanvasBase(void);
                    ~CCanvasBase(void);
   //--- Устанавливает и возвращает координаты
   void              X(const int x)                         { m_x=x;                      }
   void              Y(const int y)                         { m_y=y;                      }
   int               X(void)                                { return(m_x);                }
   int               Y(void)                                { return(m_y);                }
   //--- Устанавливает и возвращает размеры
   void              XSize(const int x_size)                { m_x_size=x_size;            }
   void              YSize(const int y_size)                { m_y_size=y_size;            }
   int               XSize(void)                            { return(m_x_size);           }
   int               YSize(void)                            { return(m_y_size);           }
   //--- Устанавливает имя индикатора при создании
   void              Name(const string canvas_name) { m_canvas_name=canvas_name;  }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCanvasBase::CCanvasBase(void) : m_x(0),
                                 m_y(0),
                                 m_x_size(200),
                                 m_y_size(200)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCanvasBase::~CCanvasBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Создает графический ресурс для объекта                           |
//+------------------------------------------------------------------+
bool CCanvasBase::CreateCanvas(void)
  {
   ObjectDelete(0,m_canvas_name);
   if(!m_canvas.CreateBitmapLabel(m_canvas_name,m_x,m_y,m_x_size,m_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
      return(false);
   ObjectSetInteger(0,m_canvas_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,m_canvas_name,OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetInteger(0,m_canvas_name,OBJPROP_BACK,false);
   return(true);
  }
//+------------------------------------------------------------------+
//| Удаляет графический ресурс                                       |
//+------------------------------------------------------------------+
bool CCanvasBase::DeleteCanvas()
  {
   return(ObjectDelete(0,m_canvas_name)?true:false);
  }
//+------------------------------------------------------------------+
