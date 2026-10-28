//+------------------------------------------------------------------+
//|                                                SL_Calculator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "StopLoss calculator"
#property indicator_chart_window
#property indicator_buffers   0
#property indicator_plots     0
//--- defines
#define PANEL_WIDTH           (200)
#define PANEL_HEIGHT          (58)
//--- enums
enum ENUM_TEXT_CORNER
  {
   CORNER_CHART_LEFT_UPPER    =  CORNER_LEFT_UPPER,   // Left-upper
   CORNER_CHART_LEFT_LOWER    =  CORNER_LEFT_LOWER,   // Left-lower
   CORNER_CHART_RIGHT_LOWER   =  CORNER_RIGHT_LOWER,  // Right-lower
   CORNER_CHART_RIGHT_UPPER   =  CORNER_RIGHT_UPPER,  // Right-upper
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
   int               Y2(void)          const { return m_y+m_h;       }
   CCanvas*          GetCanvasPointer(void)  { return &m_canvas;     }
   bool              Create(void);
   bool              Delete(void);
                     CSubstrate(void) : m_chart_id(0),m_subwin(0),m_x(10),m_y(20),m_w(200),m_h(58) {}
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
   return(ObjectDelete(m_chart_id,m_name));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Класс для создания панели                                        |
//+------------------------------------------------------------------+
class CPanel
  {
private:
   CSubstrate        m_panel_base;
   CSubstrate        m_loss_base;
   CSubstrate        m_wo_sl_base;
   CSubstrate        m_num_pos_base;
   string            m_panel_name;
   string            m_text_loss;
   string            m_value_loss;
   string            m_text_with_sl;
   string            m_value_with_sl;
   string            m_text_without_sl;
   string            m_value_without_sl;
   string            m_text_num_b;
   string            m_value_num_b;
   string            m_text_num_s;
   string            m_value_num_s;
   string            m_text_profit;
   string            m_value_profit;
   uchar             m_transparency;
   color             m_bg_color;
   color             m_bd_color;
   color             m_text_num_color;
   color             m_text_loss_color;
public:
   bool              SetLossValue(const double value,const bool redraw=false);
   bool              SetWOSLValue(const uint value_with,const uint value_without,const bool redraw=false);
   bool              SetNumPosValue(const uint value_buy,const uint value_sell,const double value_profit,const bool redraw=true);
   void              Transparency(const uchar transparency) { m_transparency=transparency;   }
   void              ColorBackground(const color clr)       { m_bg_color=clr;                }
   void              ColorBorder(const color clr)           { m_bd_color=clr;                }
   void              ColorTextPosAmount(const color clr)    { m_text_num_color=clr;          }
   void              ColorTextLoss(const color clr)         { m_text_loss_color=clr;         }
   bool              CreatePanel(const int x,const int y,const int w,const int h);
   void              DeletePanel(void);
                     CPanel(void) : m_panel_name(MQLInfoString(MQL_PROGRAM_NAME)+"_panel"),
                                    m_text_loss("Maximum possible loss: "),
                                    m_text_with_sl("Position with SL: "),
                                    m_text_without_sl(", without SL: "),
                                    m_text_num_b("Buy: "),
                                    m_text_num_s(", Sell: "),
                                    m_text_profit(", Profit: ")
                                    {}
                    ~CPanel(void){;}
  };
//+------------------------------------------------------------------+
//| Устанавливает значение убытка                                    |
//+------------------------------------------------------------------+
bool CPanel::SetLossValue(const double value,const bool redraw=false)
  {
   m_value_loss=::DoubleToString(value,2)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   CCanvas* mess=this.m_loss_base.GetCanvasPointer();
   if(mess==NULL)
      return false;
   mess.Erase();
   mess.FontSet("Calibri",-80,FW_NORMAL);
   mess.TextOut(5,6,m_text_loss+m_value_loss,ColorToARGB(this.m_text_loss_color),TA_LEFT|TA_VCENTER);
   mess.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает количество позиций, с/без StopLoss                 |
//+------------------------------------------------------------------+
bool CPanel::SetWOSLValue(const uint value_with,const uint value_without,const bool redraw=false)
  {
   m_value_with_sl=(string)value_with;
   m_value_without_sl=(string)value_without;
   string text=m_text_with_sl+m_value_with_sl+m_text_without_sl+m_value_without_sl;
   CCanvas* mess=this.m_wo_sl_base.GetCanvasPointer();
   if(mess==NULL)
      return false;
   mess.Erase();
   mess.FontSet("Calibri",-80,FW_NORMAL);
   mess.TextOut(5,6,text,ColorToARGB(this.m_text_num_color),TA_LEFT|TA_VCENTER);
   mess.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Устанавливает количество позиций по типам                        |
//+------------------------------------------------------------------+
bool CPanel::SetNumPosValue(const uint value_buy,const uint value_sell,const double value_profit,const bool redraw=true)
  {
   m_value_num_b=(string)value_buy;
   m_value_num_s=(string)value_sell;
   m_value_profit=::DoubleToString(value_profit,2)+" "+::AccountInfoString(ACCOUNT_CURRENCY);
   string text=m_text_num_b+m_value_num_b+m_text_num_s+m_value_num_s+m_text_profit+m_value_profit;
   CCanvas* mess=this.m_num_pos_base.GetCanvasPointer();
   if(mess==NULL)
      return false;
   mess.Erase();
   mess.FontSet("Calibri",-80,FW_NORMAL);
   mess.TextOut(5,6,text,ColorToARGB(this.m_text_num_color),TA_LEFT|TA_VCENTER);
   mess.Update(redraw);
   return true;
  }
//+------------------------------------------------------------------+
//| Создаёт панель                                                   |
//+------------------------------------------------------------------+
bool CPanel::CreatePanel(const int x,const int y,const int w,const int h)
  {
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
   canvas.FillRectangle(0,0,w,h,ColorToARGB(this.m_bg_color,this.m_transparency));
   canvas.Rectangle(0,0,w-1,h-1,ColorToARGB(this.m_bd_color,this.m_transparency));
   canvas.FillRectangle(0,0,w,14,ColorToARGB(clrDarkBlue,this.m_transparency));
   canvas.FontSet("Calibri",-80,FW_SEMIBOLD);
   canvas.Rectangle(2,16,w-3,h-3,ColorToARGB(this.m_bd_color,this.m_transparency));
   canvas.TextOut(5,6,"StopLoss Calculator",ColorToARGB(clrSeashell),TA_LEFT|TA_VCENTER);
   canvas.Update(true);
   //--- Текст размера возможного убытка
   int text_x=x+2;
   int text_w=w-4;
   int text_h=12;
   int text_y=y+16;
   this.m_loss_base.Name(this.m_panel_name+"_loss");
   this.m_loss_base.XDistance(text_x);
   this.m_loss_base.YDistance(text_y);
   this.m_loss_base.XSize(text_w);
   this.m_loss_base.YSize(text_h);
   if(!m_loss_base.Create())
      return false;
   this.SetLossValue(0);
   //--- Текст количества позиций с/без StopLoss
   text_y=m_loss_base.Y2();
   this.m_wo_sl_base.Name(this.m_panel_name+"_with");
   this.m_wo_sl_base.XDistance(text_x);
   this.m_wo_sl_base.YDistance(text_y);
   this.m_wo_sl_base.XSize(text_w);
   this.m_wo_sl_base.YSize(text_h);
   if(!m_wo_sl_base.Create())
      return false;
   this.SetWOSLValue(0,0);
   //--- Текст количества позиций по типам
   text_y=m_wo_sl_base.Y2();
   this.m_num_pos_base.Name(this.m_panel_name+"_num");
   this.m_num_pos_base.XDistance(text_x);
   this.m_num_pos_base.YDistance(text_y);
   this.m_num_pos_base.XSize(text_w);
   this.m_num_pos_base.YSize(text_h);
   if(!m_num_pos_base.Create())
      return false;
   this.SetNumPosValue(0,0,0);
   
   return true;
  }
//+------------------------------------------------------------------+
//| Удаляет панель                                                   |
//+------------------------------------------------------------------+
void CPanel::DeletePanel(void)
  {
   m_num_pos_base.Delete();
   m_wo_sl_base.Delete();
   m_loss_base.Delete();
   m_panel_base.Delete();
  }
//+------------------------------------------------------------------+

//--- input parameters
input ENUM_TEXT_CORNER  InpCorner            =  CORNER_CHART_RIGHT_UPPER;  // Panel corner
input uint              InpOffsetX           =  5;                         // Panel X offset
input uint              InpOffsetY           =  25;                        // Panel Y offset
input color             InpPanelColorBG      =  clrAliceBlue;              // Panel background color
input color             InpPanelColorBD      =  clrSilver;                 // Panel border color
input color             InpPanelColorLoss    =  clrBrown;                  // Loss value text color
input color             InpPanelColorTX      =  clrDimGray;                // Positions text color
input uchar             InpPanelTransparency =  127;                       // Panel transparency
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
double   stop_loss_amount;       // Общий размер StopLoss
double   prev_loss_amount;       // Предыдущий размер StopLoss
double   profit_amount;          // Размер прибыли
double   prev_profit_amount;     // Предыдущий размер прибыли
uint     num_with_sl;            // Количество позиций, имеющих StopLoss
uint     num_without_sl;         // Количество позиций, не имеющих StopLoss
uint     number_buy;             // Количество Buy
uint     number_sell;            // Количество Sell
uint     prev_number_buy;        // Предыдущее количество Buy
uint     prev_number_sell;       // Предыдущее количество Sell
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- checking for account type
   if(account_info.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
     {
      Print(account_info.MarginModeDescription(),"-account. EA should work on a hedge account.");
      return INIT_FAILED;
     }
//--- setting the timer to 500 milliseconds
   EventSetMillisecondTimer(100);
//--- setting global variables
   transparency_p=(InpPanelTransparency<48 ? 48 : InpPanelTransparency);
   prev_loss_amount=0;
   prev_profit_amount=0;
   prev_number_buy=0;
   prev_number_sell=0;
   //---
   prev_chart_w=0;
   prev_chart_h=0;
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
   CheckPositions();
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
         prev_loss_amount=prev_profit_amount=0;
         prev_number_buy=prev_number_sell=0;
         CheckPositions();
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
   ResetLastError();
   panel.ColorBackground(InpPanelColorBG);
   panel.ColorBorder(InpPanelColorBD);
   panel.ColorTextPosAmount(InpPanelColorTX);
   panel.ColorTextLoss(InpPanelColorLoss);
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
//| Проверка позиций                                                 |
//+------------------------------------------------------------------+
void CheckPositions(void)
  {
   num_with_sl=num_without_sl=number_buy=number_sell=0;
   profit_amount=stop_loss_amount=0;
//---
   int total=PositionsTotal();
   for(int i=total-1; i>WRONG_VALUE; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      double sl=PositionGetDouble(POSITION_SL);
      if(sl==0) 
         num_without_sl++;
      else 
         num_with_sl++;
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_BUY)
         number_buy++;
      else
         number_sell++;
      string symbol_name=PositionGetString(POSITION_SYMBOL);
      double open_price=PositionGetDouble(POSITION_PRICE_OPEN);
      double volume=PositionGetDouble(POSITION_VOLUME);
      double profit=(type==POSITION_TYPE_BUY ? open_price-sl : sl-open_price);
      stop_loss_amount+=GetLossPotential(symbol_name,profit,volume);
      profit_amount+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
     }
   //---
   if(prev_loss_amount!=stop_loss_amount || prev_number_buy!=number_buy || prev_number_sell!=number_sell || prev_profit_amount!=profit_amount)
     {
      panel.SetLossValue(stop_loss_amount);
      panel.SetWOSLValue(num_with_sl,num_without_sl);
      panel.SetNumPosValue(number_buy,number_sell,profit_amount);
      prev_loss_amount=stop_loss_amount;
      prev_profit_amount=profit_amount;
      prev_number_buy=number_buy;
      prev_number_sell=number_sell;
     }
   //---
  }
//+------------------------------------------------------------------+
//| Возвращает размер потенциального убытка                          |
//+------------------------------------------------------------------+
double GetLossPotential(const string symbol_name,const double profit,const double volume)
  {
   ENUM_SYMBOL_CALC_MODE calc_mode=(ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_CALC_MODE);
   double lot_size=SymbolInfoDouble(symbol_name,SYMBOL_TRADE_CONTRACT_SIZE);
   double tick_size=SymbolInfoDouble(symbol_name,SYMBOL_TRADE_TICK_SIZE);
   double tick_value=SymbolInfoDouble(symbol_name,SYMBOL_TRADE_TICK_VALUE);
   return
     (
     (calc_mode==SYMBOL_CALC_MODE_FOREX               ||
      calc_mode==SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE   ||
      calc_mode==SYMBOL_CALC_MODE_CFD                 ||
      calc_mode==SYMBOL_CALC_MODE_CFDINDEX            ||
      calc_mode==SYMBOL_CALC_MODE_CFDLEVERAGE         ||
      calc_mode==SYMBOL_CALC_MODE_EXCH_STOCKS)        ? /*profit*lot_size*volume*/ profit/tick_size*tick_value*volume   :
     (calc_mode==SYMBOL_CALC_MODE_EXCH_FUTURES        ||
      calc_mode==SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS) ? profit*volume*tick_value/tick_size   :
      calc_mode==SYMBOL_CALC_MODE_FUTURES             ? profit*tick_value/tick_size*volume   :
      0
     );
  }
//+------------------------------------------------------------------+
  