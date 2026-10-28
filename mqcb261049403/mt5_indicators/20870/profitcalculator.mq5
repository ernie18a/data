//+------------------------------------------------------------------+
//|                                             ProfitCalculator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers   0
#property indicator_plots     0
//--- defines
#define PANEL_WIDTH           (200)
#define PANEL_HEIGHT          (92)
//--- enums
enum ENUM_TEXT_CORNER
  {
   CORNER_CHART_LEFT_UPPER    =  CORNER_LEFT_UPPER,   // Left-upper
   CORNER_CHART_LEFT_LOWER    =  CORNER_LEFT_LOWER,   // Left-lower
   CORNER_CHART_RIGHT_LOWER   =  CORNER_RIGHT_LOWER,  // Right-lower
   CORNER_CHART_RIGHT_UPPER   =  CORNER_RIGHT_UPPER,  // Right-upper
  };
enum ENUM_WEEK_BEGIN
  {
   BEGINNING_ON_MONDAY,    // Monday
   BIGINNING_ON_SUNDAY     // Sunday
  };
enum ENUM_VALUE_METHOD
  {
   VALUE_PROFIT_CURRENT,
   VALUE_NUM_BUY_CURRENT,
   VALUE_NUM_SELL_CURRENT,
   VALUE_PROFIT_DAY,
   VALUE_NUM_BUY_DAY,
   VALUE_NUM_SELL_DAY,
   VALUE_PROFIT_WEEK,
   VALUE_NUM_BUY_WEEK,
   VALUE_NUM_SELL_WEEK,
   VALUE_PROFIT_MONTH,
   VALUE_NUM_BUY_MONTH,
   VALUE_NUM_SELL_MONTH,
   VALUE_PROFIT_YEAR,
   VALUE_NUM_BUY_YEAR,
   VALUE_NUM_SELL_YEAR,
   VALUE_PROFIT_ACCOUNT,
   VALUE_NUM_BUY_ACCOUNT,
   VALUE_NUM_SELL_ACCOUNT,
  };
//--- includes
#include <Trade\AccountInfo.mqh>
#include <Canvas\Canvas.mqh>
//+------------------------------------------------------------------+
//| Базовый класс для создания графики                               |
//+------------------------------------------------------------------+
class CSubstrate
  {
private:
   string            m_name;
   int               m_chart_id;
   int               m_subwin;
   int               m_x;
   int               m_y;
   int               m_w;
   int               m_h;
   int               m_x2;
   int               m_y2;
public:
   CCanvas           m_canvas;
   string            Name(void)        const { return this.m_name;   }
   void              Name(const string name) { this.m_name=name;     }
   int               XSize(void)       const { return this.m_w;      }
   void              XSize(const int w)      { this.m_w=w;           }
   int               YSize(void)       const { return this.m_h;      }
   void              YSize(const int h)      { this.m_h=h;           }
   int               XDistance(void)   const { return this.m_x;      }
   void              XDistance(const int x)  { this.m_x=x;           }
   int               YDistance(void)   const { return this.m_y;      }
   void              YDistance(const int y)  { this.m_y=y;           }
   int               X2(void)          const { return m_x+m_w;       }
   int               Y2(void)          const { return m_y+m_h;       }
   CCanvas*          GetCanvasPointer(void)  { return &m_canvas;     }
   bool              Create(void);
   bool              Delete(void);
                     CSubstrate(void) : m_chart_id(0),m_subwin(0),m_x(10),m_y(20),m_w(200),m_h(92) {}
                    ~CSubstrate(void){;}
  };
//+------------------------------------------------------------------+
//| CSubstrate Создаёт основу-подложку                               |
//+------------------------------------------------------------------+
bool CSubstrate::Create(void)
  {
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,m_name,m_x,m_y,m_w,m_h,COLOR_FORMAT_ARGB_NORMALIZE))
      return false;
   ::ObjectSetInteger(m_chart_id,m_name,OBJPROP_SELECTABLE,false);
   ::ObjectSetInteger(m_chart_id,m_name,OBJPROP_HIDDEN,true);
   ::ObjectSetInteger(m_chart_id,m_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ::ObjectSetInteger(m_chart_id,m_name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ::ObjectSetInteger(m_chart_id,m_name,OBJPROP_BACK,false);
   return true;
  }
//+------------------------------------------------------------------+
//| CSubstrate Удаляет основу-подложку                               |
//+------------------------------------------------------------------+
bool CSubstrate::Delete(void)
  {
   return(::ObjectDelete(m_chart_id,m_name));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Класс для создания панели                                        |
//+------------------------------------------------------------------+
class CPanel
  {
private:
   CSubstrate        m_panel_base;
   CSubstrate        m_base_curr;
   CSubstrate        m_base_day;
   CSubstrate        m_base_week;
   CSubstrate        m_base_month;
   CSubstrate        m_base_year;
   CSubstrate        m_base_acc;
   CSubstrate        m_base_num_b_curr;
   CSubstrate        m_base_num_s_curr;
   CSubstrate        m_base_num_b_day;
   CSubstrate        m_base_num_s_day;
   CSubstrate        m_base_num_b_week;
   CSubstrate        m_base_num_s_week;
   CSubstrate        m_base_num_b_month;
   CSubstrate        m_base_num_s_month;
   CSubstrate        m_base_num_b_year;
   CSubstrate        m_base_num_s_year;
   CSubstrate        m_base_num_b_acc;
   CSubstrate        m_base_num_s_acc;
   string            m_panel_name;
   string            m_currency;
   uchar             m_transparency;
   color             m_color_bg;
   color             m_color_bd;
   color             m_color_text;
   color             m_color_text_loss;
   color             m_color_text_profit;
//--- Приватные методы
   bool              SetTitles(const int x,const int y,const bool redraw=false);
   bool              SetValue(CSubstrate &base,const double value,const bool redraw=false);
   bool              SetValue(CSubstrate &base,const uint value,const bool redraw=false);
public:
   template<typename T>
   void              SetValue(const T value,const ENUM_VALUE_METHOD method,const bool redraw=false);
   void              Transparency(const uchar transparency) { m_transparency=transparency;   }
   void              ColorBackground(const color clr)       { m_color_bg=clr;                }
   void              ColorBorder(const color clr)           { m_color_bd=clr;                }
   void              ColorTextPosAmount(const color clr)    { m_color_text=clr;              }
   void              ColorTextLoss(const color clr)         { m_color_text_loss=clr;         }
   void              ColorTextProfit(const color clr)       { m_color_text_profit=clr;       }
   void              DeletePanel(void);
   bool              CreatePanel(const int x,const int y,const int w,const int h);
                     CPanel(void) : m_panel_name(::MQLInfoString(MQL_PROGRAM_NAME)+"_panel")
                                    { this.m_currency=::AccountInfoString(ACCOUNT_CURRENCY); }
                    ~CPanel(void){;}
  };
//+------------------------------------------------------------------+
//| Устанавливает значение по типу                                   |
//+------------------------------------------------------------------+
template<typename T>
void CPanel::SetValue(const T value,const ENUM_VALUE_METHOD method,const bool redraw=false)
  {
   switch(method)
     {
      case VALUE_PROFIT_DAY         :  this.SetValue(m_base_day,value,redraw);         break;
      case VALUE_NUM_BUY_DAY        :  this.SetValue(m_base_num_b_day,value,redraw);   break;
      case VALUE_NUM_SELL_DAY       :  this.SetValue(m_base_num_s_day,value,redraw);   break;
      
      case VALUE_PROFIT_WEEK        :  this.SetValue(m_base_week,value,redraw);        break;
      case VALUE_NUM_BUY_WEEK       :  this.SetValue(m_base_num_b_week,value,redraw);  break;
      case VALUE_NUM_SELL_WEEK      :  this.SetValue(m_base_num_s_week,value,redraw);  break;
      
      case VALUE_PROFIT_MONTH       :  this.SetValue(m_base_month,value,redraw);       break;
      case VALUE_NUM_BUY_MONTH      :  this.SetValue(m_base_num_b_month,value,redraw); break;
      case VALUE_NUM_SELL_MONTH     :  this.SetValue(m_base_num_s_month,value,redraw); break;
      
      case VALUE_PROFIT_YEAR        :  this.SetValue(m_base_year,value,redraw);        break;
      case VALUE_NUM_BUY_YEAR       :  this.SetValue(m_base_num_b_year,value,redraw);  break;
      case VALUE_NUM_SELL_YEAR      :  this.SetValue(m_base_num_s_year,value,redraw);  break;
      
      case VALUE_PROFIT_ACCOUNT     :  this.SetValue(m_base_acc,value,redraw);         break;
      case VALUE_NUM_BUY_ACCOUNT    :  this.SetValue(m_base_num_b_acc,value,redraw);   break;
      case VALUE_NUM_SELL_ACCOUNT   :  this.SetValue(m_base_num_s_acc,value,redraw);   break;
      
      case VALUE_NUM_BUY_CURRENT    :  this.SetValue(m_base_num_b_curr,value,redraw);  break;
      case VALUE_NUM_SELL_CURRENT   :  this.SetValue(m_base_num_s_curr,value,redraw);  break;
      //---VALUE_PROFIT_CURRENT
      default                       :  this.SetValue(m_base_curr,value,redraw);        break;
     }
  }
//+------------------------------------------------------------------+
//| Устанавливает double-значение                                    |
//+------------------------------------------------------------------+
bool CPanel::SetValue(CSubstrate &base,const double value,const bool redraw=false)
  {
   string text_value=::DoubleToString(value,2);
   CCanvas* canvas=base.GetCanvasPointer();
   if(canvas==NULL)
      return false;
   canvas.Erase();
   color clr=(value<0 ? m_color_text_loss : value>0 ? m_color_text_profit : m_color_text);
   canvas.FontSet("Calibri",-80,FW_NORMAL);
   canvas.TextOut(2,5,text_value,::ColorToARGB(clr),TA_LEFT|TA_VCENTER);
   canvas.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает int-значение                                       |
//+------------------------------------------------------------------+
bool CPanel::SetValue(CSubstrate &base,const uint value,const bool redraw=false)
  {
   string text_value=(string)value;
   CCanvas* canvas=base.GetCanvasPointer();
   if(canvas==NULL)
      return false;
   canvas.Erase();
   canvas.FontSet("Calibri",-80,FW_NORMAL);
   canvas.TextOut(2,5,text_value,::ColorToARGB(m_color_text),TA_LEFT|TA_VCENTER);
   canvas.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Рисует загловки значений                                         |
//+------------------------------------------------------------------+
bool CPanel::SetTitles(const int x,const int y,const bool redraw=false)
  {
   CCanvas* canvas=m_panel_base.GetCanvasPointer();
   if(canvas==NULL)
      return false;
   string titles[]={"Current","Day","Week","Month","Year","Account"};
   canvas.FontSet("Calibri",-80,FW_NORMAL);
   int n_y=y, total=::ArraySize(titles);
   for(int i=0;i<total;i++)
     {
      n_y+=12;
      canvas.TextOut(x,n_y,titles[i],::ColorToARGB(m_color_text),TA_LEFT|TA_VCENTER);
      canvas.TextOut(111,n_y,"B:",::ColorToARGB(m_color_text),TA_LEFT|TA_VCENTER);
      canvas.TextOut(155,n_y,"S:",::ColorToARGB(m_color_text),TA_LEFT|TA_VCENTER);
     }
   canvas.Line(50,y+7,50,n_y+6,::ColorToARGB(clrLightGray));
   canvas.Line(51,y+7,51,n_y+6,::ColorToARGB(clrWhite));
   canvas.Line(109,y+7,109,n_y+6,::ColorToARGB(clrLightGray));
   canvas.Line(110,y+7,110,n_y+6,::ColorToARGB(clrWhite));
   canvas.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Создаёт панель                                                   |
//+------------------------------------------------------------------+
bool CPanel::CreatePanel(const int x,const int y,const int w,const int h)
  {
   //---
   #define VALUE_X   (51)
   #define VALUE_W   (58)
   #define VALUE_H   (10)
   #define NUM_B_X   (121)
   #define NUM_S_X   (164)
   #define NUM_W     (33)
   //--- Создание основы панели
   this.m_panel_base.Name(this.m_panel_name);
   this.m_panel_base.XDistance(x);
   this.m_panel_base.YDistance(y);
   this.m_panel_base.XSize(w);
   this.m_panel_base.YSize(h);
   if(!m_panel_base.Create())
      return false;
   //--- Рисование элементов панели
   CCanvas* canvas=this.m_panel_base.GetCanvasPointer();
   if(canvas==NULL)
      return false;
   canvas.FillRectangle(0,0,w,h,::ColorToARGB(this.m_color_bg,this.m_transparency));
   canvas.Rectangle(0,0,w-1,h-1,::ColorToARGB(this.m_color_bd,this.m_transparency));
   canvas.FillRectangle(0,0,w,14,::ColorToARGB(clrDarkBlue,this.m_transparency));
   canvas.FontSet("Calibri",-80,FW_SEMIBOLD);
   canvas.Rectangle(2,16,w-3,h-3,::ColorToARGB(clrSilver,this.m_transparency));
   canvas.TextOut(5,7,"Profit Calculator "+m_currency,::ColorToARGB(clrSeashell),TA_LEFT|TA_VCENTER);
   this.SetTitles(6,10);
   canvas.Update(false);
//--- Значение размера текущего профита
   int v_y=y+17;
   this.m_base_curr.Name(this.m_panel_name+"_value_curr");
   this.m_base_curr.XSize(VALUE_W);
   this.m_base_curr.YSize(VALUE_H);
   this.m_base_curr.XDistance(x+VALUE_X);
   this.m_base_curr.YDistance(v_y);
   if(!m_base_curr.Create())
      return false;
   this.SetValue(m_base_curr,(double)0,false);
   //--- Количество текущих позиций Buy
   this.m_base_num_b_curr.Name(this.m_panel_name+"_num_b_curr");
   this.m_base_num_b_curr.XSize(NUM_W);
   this.m_base_num_b_curr.YSize(VALUE_H);
   this.m_base_num_b_curr.XDistance(x+NUM_B_X);
   this.m_base_num_b_curr.YDistance(v_y);
   if(!m_base_num_b_curr.Create())
      return false;
   this.SetValue(m_base_num_b_curr,(uint)0,false);
   //--- Количество текущих позиций Sell
   this.m_base_num_s_curr.Name(this.m_panel_name+"_num_s_curr");
   this.m_base_num_s_curr.XSize(NUM_W);
   this.m_base_num_s_curr.YSize(VALUE_H);
   this.m_base_num_s_curr.XDistance(x+NUM_S_X);
   this.m_base_num_s_curr.YDistance(v_y);
   if(!m_base_num_s_curr.Create())
      return false;
   this.SetValue(m_base_num_s_curr,(uint)0,false);
   
//--- Значение размера профита за день
   v_y=m_base_curr.Y2()+2;
   this.m_base_day.Name(this.m_panel_name+"_value_day");
   this.m_base_day.XSize(VALUE_W);
   this.m_base_day.YSize(VALUE_H);
   this.m_base_day.XDistance(x+VALUE_X);
   this.m_base_day.YDistance(v_y);
   if(!m_base_day.Create())
      return false;
   this.SetValue(m_base_day,(double)0,false);
   //--- Количество позиций Buy за день
   this.m_base_num_b_day.Name(this.m_panel_name+"_num_b_day");
   this.m_base_num_b_day.XSize(NUM_W);
   this.m_base_num_b_day.YSize(VALUE_H);
   this.m_base_num_b_day.XDistance(x+NUM_B_X);
   this.m_base_num_b_day.YDistance(v_y);
   if(!m_base_num_b_day.Create())
      return false;
   this.SetValue(m_base_num_b_day,(uint)0,false);
   //--- Количество позиций Sell за день
   this.m_base_num_s_day.Name(this.m_panel_name+"_num_s_day");
   this.m_base_num_s_day.XSize(NUM_W);
   this.m_base_num_s_day.YSize(VALUE_H);
   this.m_base_num_s_day.XDistance(x+NUM_S_X);
   this.m_base_num_s_day.YDistance(v_y);
   if(!m_base_num_s_day.Create())
      return false;
   this.SetValue(m_base_num_s_day,(uint)0,false);
   
//--- Значение размера профита за неделю
   v_y=m_base_day.Y2()+2;
   this.m_base_week.Name(this.m_panel_name+"_value_week");
   this.m_base_week.XSize(VALUE_W);
   this.m_base_week.YSize(VALUE_H);
   this.m_base_week.XDistance(x+VALUE_X);
   this.m_base_week.YDistance(v_y);
   if(!m_base_week.Create())
      return false;
   this.SetValue(m_base_week,(double)0,false);
   //--- Количество позиций Buy за неделю
   this.m_base_num_b_week.Name(this.m_panel_name+"_num_b_week");
   this.m_base_num_b_week.XSize(NUM_W);
   this.m_base_num_b_week.YSize(VALUE_H);
   this.m_base_num_b_week.XDistance(x+NUM_B_X);
   this.m_base_num_b_week.YDistance(v_y);
   if(!m_base_num_b_week.Create())
      return false;
   this.SetValue(m_base_num_b_week,(uint)0,false);
   //--- Количество позиций Sell за неделю
   this.m_base_num_s_week.Name(this.m_panel_name+"_num_s_week");
   this.m_base_num_s_week.XSize(NUM_W);
   this.m_base_num_s_week.YSize(VALUE_H);
   this.m_base_num_s_week.XDistance(x+NUM_S_X);
   this.m_base_num_s_week.YDistance(v_y);
   if(!m_base_num_s_week.Create())
      return false;
   this.SetValue(m_base_num_s_week,(uint)0,false);
   
//--- Значение размера профита за месяц
   v_y=m_base_week.Y2()+2;
   this.m_base_month.Name(this.m_panel_name+"_value_month");
   this.m_base_month.XSize(VALUE_W);
   this.m_base_month.YSize(VALUE_H);
   this.m_base_month.XDistance(x+VALUE_X);
   this.m_base_month.YDistance(v_y);
   if(!m_base_month.Create())
      return false;
   this.SetValue(m_base_month,(double)0,false);
   //--- Количество позиций Buy за месяц
   this.m_base_num_b_month.Name(this.m_panel_name+"_num_b_month");
   this.m_base_num_b_month.XSize(NUM_W);
   this.m_base_num_b_month.YSize(VALUE_H);
   this.m_base_num_b_month.XDistance(x+NUM_B_X);
   this.m_base_num_b_month.YDistance(v_y);
   if(!m_base_num_b_month.Create())
      return false;
   this.SetValue(m_base_num_b_month,(uint)0,false);
   //--- Количество позиций Sell за месяц
   this.m_base_num_s_month.Name(this.m_panel_name+"_num_s_month");
   this.m_base_num_s_month.XSize(NUM_W);
   this.m_base_num_s_month.YSize(VALUE_H);
   this.m_base_num_s_month.XDistance(x+NUM_S_X);
   this.m_base_num_s_month.YDistance(v_y);
   if(!m_base_num_s_month.Create())
      return false;
   this.SetValue(m_base_num_s_month,(uint)0,false);
   
//--- Значение размера профита за год
   v_y=m_base_month.Y2()+2;
   this.m_base_year.Name(this.m_panel_name+"_value_year");
   this.m_base_year.XSize(VALUE_W);
   this.m_base_year.YSize(VALUE_H);
   this.m_base_year.XDistance(x+VALUE_X);
   this.m_base_year.YDistance(v_y);
   if(!m_base_year.Create())
      return false;
   this.SetValue(m_base_year,(double)0,false);
   //--- Количество позиций Buy за год
   this.m_base_num_b_year.Name(this.m_panel_name+"_num_b_year");
   this.m_base_num_b_year.XSize(NUM_W);
   this.m_base_num_b_year.YSize(VALUE_H);
   this.m_base_num_b_year.XDistance(x+NUM_B_X);
   this.m_base_num_b_year.YDistance(v_y);
   if(!m_base_num_b_year.Create())
      return false;
   this.SetValue(m_base_num_b_year,(uint)0,false);
   //--- Количество позиций Sell за год
   this.m_base_num_s_year.Name(this.m_panel_name+"_num_s_year");
   this.m_base_num_s_year.XSize(NUM_W);
   this.m_base_num_s_year.YSize(VALUE_H);
   this.m_base_num_s_year.XDistance(x+NUM_S_X);
   this.m_base_num_s_year.YDistance(v_y);
   if(!m_base_num_s_year.Create())
      return false;
   this.SetValue(m_base_num_s_year,(uint)0,false);
   
//--- Значение размера профита на счёте
   v_y=m_base_year.Y2()+2;
   this.m_base_acc.Name(this.m_panel_name+"_value_acc");
   this.m_base_acc.XSize(VALUE_W);
   this.m_base_acc.YSize(VALUE_H);
   this.m_base_acc.XDistance(x+VALUE_X);
   this.m_base_acc.YDistance(v_y);
   if(!m_base_acc.Create())
      return false;
   this.SetValue(m_base_acc,(double)0,true);
   //--- Количество позиций Buy на счёте
   this.m_base_num_b_acc.Name(this.m_panel_name+"_num_b_acc");
   this.m_base_num_b_acc.XSize(NUM_W);
   this.m_base_num_b_acc.YSize(VALUE_H);
   this.m_base_num_b_acc.XDistance(x+NUM_B_X);
   this.m_base_num_b_acc.YDistance(v_y);
   if(!m_base_num_b_acc.Create())
      return false;
   this.SetValue(m_base_num_b_acc,(uint)0,false);
   //--- Количество позиций Sell на счёте
   this.m_base_num_s_acc.Name(this.m_panel_name+"_num_s_acc");
   this.m_base_num_s_acc.XSize(NUM_W);
   this.m_base_num_s_acc.YSize(VALUE_H);
   this.m_base_num_s_acc.XDistance(x+NUM_S_X);
   this.m_base_num_s_acc.YDistance(v_y);
   if(!m_base_num_s_acc.Create())
      return false;
   this.SetValue(m_base_num_s_acc,(uint)0,true);
   
   return true;
  }
//+------------------------------------------------------------------+
//| Удаляет панель                                                   |
//+------------------------------------------------------------------+
void CPanel::DeletePanel(void)
  {
   m_base_num_b_curr.Delete();
   m_base_num_s_curr.Delete();
   m_base_num_b_day.Delete();
   m_base_num_s_day.Delete();
   m_base_num_b_week.Delete();
   m_base_num_s_week.Delete();
   m_base_num_b_month.Delete();
   m_base_num_s_month.Delete();
   m_base_num_b_year.Delete();
   m_base_num_s_year.Delete();
   m_base_num_b_acc.Delete();
   m_base_num_s_acc.Delete();
   m_base_acc.Delete();
   m_base_year.Delete();
   m_base_month.Delete();
   m_base_week.Delete();
   m_base_day.Delete();
   m_base_curr.Delete();
   m_panel_base.Delete();
  }
//+------------------------------------------------------------------+

//--- input parameters
input ENUM_WEEK_BEGIN   InpWeekBegin         =  BEGINNING_ON_MONDAY;       // Start day of the week
input ENUM_TEXT_CORNER  InpCorner            =  CORNER_CHART_RIGHT_UPPER;  // Panel corner
input uint              InpOffsetX           =  5;                         // Panel X offset
input uint              InpOffsetY           =  25;                        // Panel Y offset
input uchar             InpPanelTransparency =  127;                       // Panel transparency
input color             InpPanelColorBG      =  clrAliceBlue;              // Panel background color
input color             InpPanelColorBD      =  clrSilver;                 // Panel border color
input color             InpPanelColorTX      =  clrDimGray;                // Panel text color
input color             InpPanelColorLoss    =  clrRed;                    // Loss value text color
input color             InpPanelColorProfit  =  clrGreen;                  // Profit value text color
//--- class-objects
CAccountInfo   account_info;     // Объект-CAccountInfo
CPanel   panel;
//--- global variables
uchar    transparency_p;
int      coord_x;
int      coord_y;
int      chart_w;
int      chart_h;
int      prev_chart_w;
int      prev_chart_h;
//---
double   profit_curr;            // Текущая прибыль
double   prev_profit_curr;       // Предыдущий размер текущей прибыли
//---
double   profit_day;             // Прибыль за день
double   profit_week;            // Прибыль за неделю
double   profit_month;           // Прибыль за месяц
double   profit_year;            // Прибыль за год
double   profit_acc;             // Прибыль на счёте
//---
double   prev_profit_day;        // Предыдущая прибыль за день
double   prev_profit_week;       // Предыдущая прибыль за неделю
double   prev_profit_month;      // Предыдущая прибыль за месяц
double   prev_profit_year;       // Предыдущая прибыль за год
double   prev_profit_acc;        // Предыдущая прибыль на счёте
//---
uint     num_b_curr;             // Количество текущих Buy
uint     num_s_curr;             // Количество текущих Sell
uint     prev_num_b_curr;        // Предыдущее количество текущих Buy
uint     prev_num_s_curr;        // Предыдущее количество текущих Sell
//---
uint     num_b_day;              // Количество Buy за день
uint     num_s_day;              // Количество Sell за день
uint     num_b_week;             // Количество Buy за неделю
uint     num_s_week;             // Количество Sell за неделю
uint     num_b_month;            // Количество Buy за месяц
uint     num_s_month;            // Количество Sell за месяц
uint     num_b_year;             // Количество Buy за год
uint     num_s_year;             // Количество Sell за год
uint     num_b_acc;              // Количество Buy на счёте
uint     num_s_acc;              // Количество Sell на счёте
//---
uint     prev_num_b_day;         // Предыдущее количество Buy за день
uint     prev_num_s_day;         // Предыдущее количество Sell за день
uint     prev_num_b_week;        // Предыдущее количество Buy за неделю
uint     prev_num_s_week;        // Предыдущее количество Sell за неделю
uint     prev_num_b_month;       // Предыдущее количество Buy за месяц
uint     prev_num_s_month;       // Предыдущее количество Sell за месяц
uint     prev_num_b_year;        // Предыдущее количество Buy за год
uint     prev_num_s_year;        // Предыдущее количество Sell за год
uint     prev_num_b_acc;         // Предыдущее количество Buy на счёте
uint     prev_num_s_acc;         // Предыдущее количество Sell на счёте
//---
datetime begin_day;              // Дата начала дня
datetime begin_week;             // Дата начала недели
datetime begin_month;            // Дата начала месяца
datetime begin_year;             // Дата начала года

datetime prev_begin_day;         // Предыдущая дата начала дня
datetime prev_begin_week;        // Предыдущая дата начала недели
datetime prev_begin_month;       // Предыдущая дата начала месяца
datetime prev_begin_year;        // Предыдущая дата начала года
//---
int      index_deal;             // Индекс последней исторической сделки
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- checking for account type
   if(account_info.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
     {
      Print(account_info.MarginModeDescription(),"-account. Indicator should work on a hedge account.");
      return INIT_FAILED;
     }
//--- setting the timer to 100 milliseconds
   EventSetMillisecondTimer(100);
//--- setting global variables
   transparency_p=(InpPanelTransparency<48 ? 48 : InpPanelTransparency);
   prev_begin_day=0;
   prev_begin_week=0;
   prev_begin_month=0;
   prev_begin_year=0;
   //---
   prev_chart_w=0;
   prev_chart_h=0;
   //---
   ResetDatas();
   SetCoords();
//--- create panel
   if(!CreatePanel())
     {
      Print("Failed to create a panel! Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletePanel();
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Проверка позиций
   CheckPositions(true);
   CheckPositions(false);
//---
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      if(SetCoords())
        {
         DeletePanel();
         CreatePanel();
         ResetDatas();
         CheckPositions(true);
         CheckPositions(false);
        }
     }
  }
//+------------------------------------------------------------------+
//| Устанавливает координаты панели                                  |
//+------------------------------------------------------------------+
bool SetCoords(void)
  {
   chart_w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   chart_h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   if(prev_chart_h!=chart_h || prev_chart_w!=chart_w)
     {
      coord_x=(int)InpOffsetX;
      coord_y=(int)InpOffsetY;
      if(InpCorner==CORNER_CHART_RIGHT_LOWER || InpCorner==CORNER_CHART_RIGHT_UPPER) coord_x=int(chart_w-PANEL_WIDTH-InpOffsetX);
      if(InpCorner==CORNER_CHART_RIGHT_LOWER || InpCorner==CORNER_CHART_LEFT_LOWER)  coord_y=int(chart_h-PANEL_HEIGHT-InpOffsetY);
      if(coord_x<0) coord_x=0;
      if(coord_y<0) coord_y=0;
      if(coord_x+PANEL_WIDTH>chart_w) coord_x=chart_w-PANEL_WIDTH-1;
      if(coord_y+PANEL_HEIGHT>chart_h) coord_y=chart_h-PANEL_HEIGHT-1;
      prev_chart_h=chart_h;
      prev_chart_w=chart_w;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Создаёт панель                                                   |
//+------------------------------------------------------------------+
bool CreatePanel(void)
  {
   panel.ColorBackground(InpPanelColorBG);
   panel.ColorBorder(InpPanelColorBD);
   panel.ColorTextPosAmount(InpPanelColorTX);
   panel.ColorTextLoss(InpPanelColorLoss);
   panel.ColorTextProfit(InpPanelColorProfit);
   panel.Transparency(transparency_p);
   return(panel.CreatePanel(coord_x,coord_y,PANEL_WIDTH,PANEL_HEIGHT));
  }
//+------------------------------------------------------------------+
//| Удаляет панель                                                   |
//+------------------------------------------------------------------+
void DeletePanel(void)
  {
   panel.DeletePanel();
  }
//+------------------------------------------------------------------+
//| Сброс данных                                                     |
//+------------------------------------------------------------------+
void ResetDatas(void)
  {
   prev_profit_curr=0;
   prev_num_b_curr=prev_num_s_curr=0;
   num_b_day=num_s_day=prev_num_b_day=prev_num_s_day=0;
   num_b_week=num_s_week=prev_num_b_week=prev_num_s_week=0;
   num_b_month=num_s_month=prev_num_b_month=prev_num_s_month=0;
   num_b_year=num_s_year=prev_num_b_year=prev_num_s_year=0;
   num_b_acc=num_s_acc=prev_num_b_acc=prev_num_s_acc=0;
   profit_day=prev_profit_day=0;
   profit_week=prev_profit_week=0;
   profit_month=prev_profit_month=0;
   profit_year=prev_profit_year=0;
   profit_acc=prev_profit_acc=0;
   index_deal=0;
  }
//+------------------------------------------------------------------+
//| Проверка позиций                                                 |
//+------------------------------------------------------------------+
void CheckPositions(bool current=false)
  {
   if(current)
     {
      num_b_curr=num_s_curr=0;
      profit_curr=0;
      int total=PositionsTotal();
      for(int i=total-1; i>WRONG_VALUE; i--)
        {
         ulong ticket=PositionGetTicket(i);
         if(ticket==0)
            continue;
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         datetime open_time=(datetime)PositionGetInteger(POSITION_TIME);
         profit_curr+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
         if(type==POSITION_TYPE_BUY)
            num_b_curr++;
         if(type==POSITION_TYPE_SELL)
            num_s_curr++;
        }
      if(prev_num_b_curr!=num_b_curr)
        {
         prev_num_b_curr=num_b_curr;
         panel.SetValue(num_b_curr,VALUE_NUM_BUY_CURRENT,true);
        }
      if(prev_num_s_curr!=num_s_curr)
        {
         prev_num_s_curr=num_s_curr;
         panel.SetValue(num_s_curr,VALUE_NUM_SELL_CURRENT,true);
        }
      if(prev_profit_curr!=profit_curr)
        {
         prev_profit_curr=profit_curr;
         panel.SetValue(profit_curr,VALUE_PROFIT_CURRENT,true);
        }
     }
   else
     {
      datetime time_current=TimeCurrent();
      if(!HistorySelect(0,time_current)) 
         return;
      begin_day=StartOfDay(time_current);
      begin_week=StartOfWeek(time_current);
      begin_month=StartOfMonth(time_current);
      begin_year=StartOfYear(time_current);
      if(prev_begin_day!=begin_day || prev_begin_week!=begin_week || prev_begin_month!=begin_month || prev_begin_year!=begin_year)
        {
         ResetDatas();
         prev_begin_day=begin_day;
         prev_begin_week=begin_week;
         prev_begin_month=begin_month;
         prev_begin_year=begin_year;
        }
      ulong deal_ticket=0;
      int total_deals=HistoryDealsTotal(), i=index_deal;
   //--- Сделки
      int bbb=0;
      for(; i<total_deals; i++)
        {
         bbb=1;
         deal_ticket=HistoryDealGetTicket(i);
         if(deal_ticket==0) continue;
         ENUM_DEAL_TYPE deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_ticket,DEAL_TYPE);
         ENUM_DEAL_ENTRY deal_entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket,DEAL_ENTRY);
         if(deal_type!=DEAL_TYPE_BUY && deal_type!=DEAL_TYPE_SELL)
            continue;
         if(deal_entry!=DEAL_ENTRY_OUT && deal_entry!=DEAL_ENTRY_INOUT && deal_entry!=DEAL_ENTRY_OUT_BY)
            continue;
         ENUM_POSITION_TYPE position_type=(deal_type==DEAL_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);
         datetime deal_time=(datetime)HistoryDealGetInteger(deal_ticket,DEAL_TIME);
         double deal_profit=HistoryDealGetDouble(deal_ticket,DEAL_PROFIT);
         double deal_commission=HistoryDealGetDouble(deal_ticket,DEAL_COMMISSION);
         double deal_swap=HistoryDealGetDouble(deal_ticket,DEAL_SWAP);
         double profit=deal_profit+deal_commission+deal_swap;
         
      //--- Прибыль и количество позиций на счёте
         profit_acc+=profit;
         if(position_type==POSITION_TYPE_BUY)
            num_b_acc++;
         else
            num_s_acc++;
      //--- Прибыль и количество позиций за год
         if(deal_time>=begin_year)
           {
            profit_year+=profit;
            if(position_type==POSITION_TYPE_BUY)
               num_b_year++;
            else
               num_s_year++;
           }
      //--- Прибыль и количество позиций за месяц
         if(deal_time>=begin_month)
           {
            profit_month+=profit;
            if(position_type==POSITION_TYPE_BUY)
               num_b_month++;
            else
               num_s_month++;
           }
      //--- Прибыль и количество позиций за неделю
         if(deal_time>=begin_week)
           {
            profit_week+=profit;
            if(position_type==POSITION_TYPE_BUY)
               num_b_week++;
            else
               num_s_week++;
           }
      //--- Прибыль и количество позиций за день
         if(deal_time>=begin_day)
           {
            profit_day+=profit;
            if(position_type==POSITION_TYPE_BUY)
               num_b_day++;
            else
               num_s_day++;
           }
        }
      //---
      if(prev_profit_acc!=profit_acc)
        {
         prev_profit_acc=profit_acc;
         panel.SetValue(profit_acc,VALUE_PROFIT_ACCOUNT,true);
        }
      if(prev_num_b_acc!=num_b_acc)
        {
         prev_num_b_acc=num_b_acc;
         panel.SetValue(num_b_acc,VALUE_NUM_BUY_ACCOUNT,true);
        }
      if(prev_num_s_acc!=num_s_acc)
        {
         prev_num_s_acc=num_s_acc;
         panel.SetValue(num_s_acc,VALUE_NUM_SELL_ACCOUNT,true);
        }
      //---
      if(prev_profit_year!=profit_year)
        {
         prev_profit_year=profit_year;
         panel.SetValue(profit_year,VALUE_PROFIT_YEAR,true);
        }
      if(prev_num_b_year!=num_b_year)
        {
         prev_num_b_year=num_b_year;
         panel.SetValue(num_b_year,VALUE_NUM_BUY_YEAR,true);
        }
      if(prev_num_s_year!=num_s_year)
        {
         prev_num_s_year=num_s_year;
         panel.SetValue(num_s_year,VALUE_NUM_SELL_YEAR,true);
        }
      //---
      if(prev_profit_month!=profit_month)
        {
         prev_profit_month=profit_month;
         panel.SetValue(profit_month,VALUE_PROFIT_MONTH,true);
        }
      if(prev_num_b_month!=num_b_month)
        {
         prev_num_b_month=num_b_month;
         panel.SetValue(num_b_month,VALUE_NUM_BUY_MONTH,true);
        }
      if(prev_num_s_month!=num_s_month)
        {
         prev_num_s_month=num_s_month;
         panel.SetValue(num_s_month,VALUE_NUM_SELL_MONTH,true);
        }
      //---
      if(prev_profit_week!=profit_week)
        {
         prev_profit_week=profit_week;
         panel.SetValue(profit_week,VALUE_PROFIT_WEEK,true);
        }
      if(prev_num_b_week!=num_b_week)
        {
         prev_num_b_week=num_b_week;
         panel.SetValue(num_b_week,VALUE_NUM_BUY_WEEK,true);
        }
      if(prev_num_s_week!=num_s_week)
        {
         prev_num_s_week=num_s_week;
         panel.SetValue(num_s_week,VALUE_NUM_SELL_WEEK,true);
        }
      //---
      if(prev_profit_day!=profit_day)
        {
         prev_profit_day=profit_day;
         panel.SetValue(profit_day,VALUE_PROFIT_DAY,true);
        }
      if(prev_num_b_day!=num_b_day)
        {
         prev_num_b_day=num_b_day;
         panel.SetValue(num_b_day,VALUE_NUM_BUY_DAY,true);
        }
      if(prev_num_s_day!=num_s_day)
        {
         prev_num_s_day=num_s_day;
         panel.SetValue(num_s_day,VALUE_NUM_SELL_DAY,true);
        }
      //---
      index_deal=i;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает флаг начала недели в понедельник                      |
//+------------------------------------------------------------------+
bool IsStartsWeekOnMonday()
  {
   return(InpWeekBegin==BEGINNING_ON_MONDAY);
  }
//+------------------------------------------------------------------+
//| Возвращает время начала дня                                      |
//+------------------------------------------------------------------+
datetime StartOfDay(const datetime time)
  {
   return((time/86400)*86400);
  }
//+------------------------------------------------------------------+
//| Возвращает время начала недели                                   |
//+------------------------------------------------------------------+
datetime StartOfWeek(const datetime time)
  {
   long tmp=time;
   long corrector=(IsStartsWeekOnMonday()) ? 259200 : 345600;
   tmp+=corrector;
   tmp=(tmp/604800)*604800;
   tmp-=corrector;
   return((datetime)tmp);
  }
//+------------------------------------------------------------------+
//| Возвращает время начала месяца                                   |
//+------------------------------------------------------------------+
datetime StartOfMonth(const datetime time)
  {
   MqlDateTime stm;
   ::TimeToStruct(time,stm);
   stm.day=1;
   stm.hour=0;
   stm.min=0;
   stm.sec=0;
   return(::StructToTime(stm));
  }
//+------------------------------------------------------------------+
//| Возвращает время начала года                                     |
//+------------------------------------------------------------------+
datetime StartOfYear(const datetime time)
  {
   MqlDateTime stm;
   ::TimeToStruct(time,stm);
   stm.day=1;
   stm.mon=1;
   stm.hour=0;
   stm.min=0;
   stm.sec=0;
   return(::StructToTime(stm));
  }
//+------------------------------------------------------------------+
