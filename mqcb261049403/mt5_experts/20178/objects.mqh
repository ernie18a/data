//+------------------------------------------------------------------+
//|                                                      Objects.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Класс объекта-линии                                              |
//+------------------------------------------------------------------+
class CLineObj : public CObject
  {
protected:
   long              m_chart_id;                            // Идентификатор графика
   string            m_symbol;                              // Символ графика
   string            m_name;                                // Имя
   string            m_descript;                            // Описание
   int               m_id_name;                           // Номер в конце имени линии (ID)
   ENUM_OBJECT       m_line_type;                           // Тип линии
   ENUM_LINE_STYLE   m_style;                               // Стиль линии
   ENUM_LINE_STYLE   m_inactive_style;                      // Стиль неактивного состояния линии
   datetime          m_time_0;                              // Время левой точки
   datetime          m_time_1;                              // Время правой точки
   double            m_price_0;                             // Цена левой точки
   double            m_price_1;                             // Цена правой точки
   bool              m_ray;                                 // Луч вправо
   //--- Уравнение прямой
   double            EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search) const;
   //--- Возвращает смещение бара по времени
   int               BarShift(const datetime time) const;
   //--- Возвращает время открытия текущего бара
   datetime          TimeBarCurrent(void) const;
public:
   //--- Возвращает описание типа линии
   string            DescriptTypeLine(void);
   //--- Возвращает описание линии (Description)
   string            Description(void) const { return this.m_descript;  }
   //--- Возвращает ID имени
   int               NameID(void)      const { return this.m_id_name; }
   //--- Возвращает тип линии
   ENUM_OBJECT       TypeLine(void)    const { return this.m_line_type; }
   //--- Возвращает/устанавливает стиль линии
   ENUM_LINE_STYLE   Style(void)       const { return this.m_style;     }
   void              Style(const ENUM_LINE_STYLE style);
   //--- Возвращает имя
   string            Name(void)        const { return this.m_name;      }
   //--- Возвращает время левой точки
   datetime          TimeLeft(void)    const;
   //--- Возвращает время правой точки
   datetime          TimeRight(void)   const;
   //--- Возвращает бар правой точки
   int               BarRight(void)    const;
   //--- Возвращает цену левой точки
   double            PriceLeft(void)   const;
   //--- Возвращает цену правой точки
   double            PriceRight(void)  const;
   //--- Возвращает флаг "луч вправо"
   bool              Ray(void)         const { return this.m_ray;       }
   //--- Возвращает флаг активного состояния линии
   bool              IsActive(void)    const { return(this.m_style!=this.m_inactive_style);  }
   //--- Возвращает значение цены на пересекаемом баре
   double            PriceValueForIntersection(const int intersecting_bar) const;
   //--- Установка значений
   void              SetParameters(const datetime x0,
                                   const double y0,
                                   const datetime x1,
                                   const double y1,
                                   const bool ray,
                                   const string descr,
                                   const ENUM_LINE_STYLE style,
                                   const ENUM_LINE_STYLE inactive_style
                                   );
   //--- Конструктор/деструктор
                     CLineObj(const long chart_id,const string name,const ENUM_OBJECT type);
                    ~CLineObj(void) {;}
  };
//+------------------------------------------------------------------+
//| Конструктор CLineObj                                             |
//+------------------------------------------------------------------+
CLineObj::CLineObj(const long chart_id,const string name,const ENUM_OBJECT type) : m_time_1(0),m_time_0(0),m_price_1(0),m_price_0(0),m_ray(false)
  {
   this.m_symbol=::Symbol();
   this.m_chart_id=chart_id;
   this.m_name=name;
   this.m_line_type=type;
  }
//+------------------------------------------------------------------+
//| Инициализация значениями                                         |
//+------------------------------------------------------------------+
void CLineObj::SetParameters(const datetime x0,
                             const double y0,
                             const datetime x1,
                             const double y1,
                             const bool ray,
                             const string descr,
                             const ENUM_LINE_STYLE style,
                             const ENUM_LINE_STYLE inactive_style
                             )
  {
   this.m_time_0=x0;
   this.m_time_1=x1;
   this.m_price_0=y0;
   this.m_price_1=y1;
   this.m_ray=ray;
   this.m_descript=descr;
   this.m_style=style;
   this.m_inactive_style=inactive_style;
   //--- ID линии в имени
   string descr_type=this.DescriptTypeLine();
   int beg=StringFind(this.m_name,descr_type);
   int len=StringLen(descr_type);
   this.m_id_name=(int)StringSubstr(this.m_name,(beg+len+1));
  }
//+------------------------------------------------------------------+
//| Устанавливает стиль линии                                        |
//+------------------------------------------------------------------+
void CLineObj::Style(const ENUM_LINE_STYLE style)
  {
   ::ObjectSetInteger(this.m_chart_id,this.m_name,OBJPROP_STYLE,style);
   ::ChartRedraw(this.m_chart_id);
  }
//+------------------------------------------------------------------+
//| Возвращает значение цены на пересекаемом баре                    |
//+------------------------------------------------------------------+
double CLineObj::PriceValueForIntersection(const int intersecting_bar) const
  {
   int bar_left=this.BarShift(this.TimeLeft());
   int bar_right=this.BarShift(this.TimeRight());
   return this.EquationDirect(bar_left,this.PriceLeft(),bar_right,this.PriceRight(),intersecting_bar);
  }
//+------------------------------------------------------------------+
//| Уравнение прямой                                                 |
//+------------------------------------------------------------------+
double CLineObj::EquationDirect(const int left_bar,const double left_price,const int right_bar,const double right_price,const int bar_to_search) const
  {
   return(right_bar==left_bar ? left_price : (right_price-left_price)/(right_bar-left_bar)*(bar_to_search-left_bar)+left_price);
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия текущего бара                          |
//+------------------------------------------------------------------+
datetime CLineObj::TimeBarCurrent(void) const
  {
   datetime array[];
   if(CopyTime(this.m_symbol,PERIOD_CURRENT,0,1,array)==1) return array[0];
   return 0;
  }  
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//+------------------------------------------------------------------+
int CLineObj::BarShift(const datetime time) const
  {
   int res=WRONG_VALUE;
   datetime last_bar=0;
   if(::SeriesInfoInteger(m_symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE,last_bar))
     {
      if(time>last_bar) res=0;
      else
        {
         const int shift=::Bars(m_symbol,PERIOD_CURRENT,time,last_bar);
         if(shift>0) res=shift-1;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Возвращает бар правой точки привязки                             |
//+------------------------------------------------------------------+
int CLineObj::BarRight(void) const
  {
   return
     (
      this.m_line_type==OBJ_HLINE ? 0 :
      this.m_line_type==OBJ_VLINE ? this.BarShift(this.TimeRight()) :
      this.Ray() ? 0 : this.BarShift(this.TimeRight())
     );
  }
//+------------------------------------------------------------------+
//| Возвращает время правой точки привязки                            |
//+------------------------------------------------------------------+
datetime CLineObj::TimeRight(void) const
  {
   return
     (
      this.m_line_type==OBJ_VLINE ? this.m_time_0 :
      this.m_line_type==OBJ_HLINE ? this.TimeBarCurrent() :
      this.m_time_0>this.m_time_1 ? m_time_0 : m_time_1
     );
  }
//+------------------------------------------------------------------+
//| Возвращает время левой точки привязки                            |
//+------------------------------------------------------------------+
datetime CLineObj::TimeLeft(void) const
  {
   return
     (
      this.m_line_type==OBJ_VLINE ? this.m_time_0 :
      this.m_line_type==OBJ_HLINE ? this.TimeBarCurrent() :
      this.m_time_0<this.m_time_1 ? m_time_0 : m_time_1
     );
  }
//+------------------------------------------------------------------+
//| Возвращает цену левой точки привязки                            |
//+------------------------------------------------------------------+
double CLineObj::PriceLeft(void) const
  {
   return
     (
      this.m_line_type==OBJ_VLINE ? 0 :
      this.m_line_type==OBJ_HLINE ? (this.m_time_0>0 ? m_price_0 : m_price_1) :
      this.m_time_0<this.m_time_1 ? m_price_0 : m_price_1
     );
  }
//+------------------------------------------------------------------+
//| Возвращает цену правой точки привязки                            |
//+------------------------------------------------------------------+
double CLineObj::PriceRight(void) const
  {
   return
     (
      this.m_line_type==OBJ_VLINE ? 0 :
      this.m_line_type==OBJ_HLINE ? (this.m_time_0>0 ? m_price_0 : m_price_1) : 
      this.m_time_0>this.m_time_1 ? m_price_0 : m_price_1
     );
  }
//+------------------------------------------------------------------+
//| Возвращает описание типа линии                                                                 |
//+------------------------------------------------------------------+
string CLineObj::DescriptTypeLine(void)
  {
   return
     (
      this.TypeLine()==OBJ_VLINE ? "Vertical Line" :
      this.TypeLine()==OBJ_HLINE ? "Horizontal Line" :
      this.TypeLine()==OBJ_TREND ? "Trendline" :
      this.TypeLine()==OBJ_TRENDBYANGLE ? "Trend By Angle" : "Other line"
     );
  }
//+------------------------------------------------------------------+
