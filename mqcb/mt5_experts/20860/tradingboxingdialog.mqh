//+------------------------------------------------------------------+
//|                                          TradingBoxingDialog.mqh |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include "SpinEditDouble.mqh"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CTradingBoxingDialog                                       |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CTradingBoxingDialog : public CAppDialog
  {
private:
   CEdit             m_edit;                          // the display field object
   CButton           m_button1;                       // the button object
   CButton           m_button2;                       // the button object
   CButton           m_button3;                       // the button object
   CButton           m_button4;                       // the button object
   CButton           m_button5;                       // the button object
   CButton           m_button6;                       // the button object
   CButton           m_button7;                       // the button object
   CButton           m_button8;                       // the button object
   CButton           m_button9;                       // the button object
   CButton           m_button10;                      // the button object
   CButton           m_button11;                      // the button object
   CButton           m_button12;                      // the button object
   CSpinEditDouble   m_spin_edit1;                    // the spinedit object
   CSpinEditDouble   m_spin_edit2;                    // the spinedit object
   CSpinEditDouble   m_spin_edit3;                    // the spinedit object
   CSpinEditDouble   m_spin_edit4;                    // the spinedit object
   CSpinEditDouble   m_spin_edit5;                    // the spinedit object
   CSpinEditDouble   m_spin_edit6;                    // the spinedit object
   CSpinEditDouble   m_spin_edit7;                    // the spinedit object
   CSpinEditDouble   m_spin_edit8;                    // the spinedit object
   CSpinEditDouble   m_spin_edit9;                    // the spinedit object
   CSpinEditDouble   m_spin_edit10;                   // the spinedit object
   //---
   CPositionInfo     m_position;                      // trade position object
   CTrade            m_trade;                         // trading object
   CSymbolInfo       m_symbol;                        // symbol info object
   COrderInfo        m_order;                         // pending orders object
   //---
   ulong             m_magic;                         // magic number
   ulong             m_slippage;                      // slippage
   //--- refresh rates
   bool              RefreshRates(void);
   //--- close positions  
   void              ClosePositions(const ENUM_POSITION_TYPE pos_type);
   //--- calculate positions                              
   int               CalculatePositions(const ENUM_POSITION_TYPE pos_type);
   //--- delete pending orders                                                
   void              DeleteOrders(const ENUM_ORDER_TYPE order_type);
   //--- calculate pending orders                                                
   int               CalculateOrders(const ENUM_ORDER_TYPE order_type);
   //---
   bool              bln_close_buys;
   bool              bln_close_sells;
   bool              bln_del_buy_stops;
   bool              bln_del_buy_limits;
   bool              bln_del_sell_stops;
   bool              bln_del_sell_limits;

   double            dbl_volume_buy;
   bool              bln_open_buy;

   double            dbl_volume_sell;
   bool              bln_open_sell;

   double            dbl_volume_buy_stop;
   double            dbl_price_buy_stop;
   bool              bln_buy_stop;

   double            dbl_volume_buy_limit;
   double            dbl_price_buy_limit;
   bool              bln_buy_limit;

   double            dbl_volume_sell_stop;
   double            dbl_price_sell_stop;
   bool              bln_sell_stop;

   double            dbl_volume_sell_limit;
   double            dbl_price_sell_limit;
   bool              bln_sell_limit;

public:
                     CTradingBoxingDialog(void);
                    ~CTradingBoxingDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                            const int x2,const int y2,const ulong magic);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
   void              OnTick(void);

protected:
   //--- create dependent controls
   bool              CreateButton1(void);
   bool              CreateButton2(void);
   bool              CreateButton3(void);
   bool              CreateButton4(void);
   bool              CreateButton5(void);
   bool              CreateButton6(void);
   bool              CreateButton7(void);
   bool              CreateButton8(void);
   bool              CreateButton9(void);
   bool              CreateButton10(void);
   bool              CreateButton11(void);
   bool              CreateButton12(void);
   bool              CreateSpinEdit1(void);
   bool              CreateSpinEdit2(void);
   bool              CreateSpinEdit3(void);
   bool              CreateSpinEdit4(void);
   bool              CreateSpinEdit5(void);
   bool              CreateSpinEdit6(void);
   bool              CreateSpinEdit7(void);
   bool              CreateSpinEdit8(void);
   bool              CreateSpinEdit9(void);
   bool              CreateSpinEdit10(void);
   //--- override the parent method
   virtual void      Minimize(void);
   //--- handlers of the dependent controls events
   void              OnClickButton1(void)       { bln_close_buys        = true;                    OnTick();   }
   void              OnClickButton2(void)       { bln_close_sells       = true;                    OnTick();   }
   void              OnClickButton3(void)       { bln_del_buy_stops     = true;                    OnTick();   }
   void              OnClickButton4(void)       { bln_del_buy_limits    = true;                    OnTick();   }
   void              OnClickButton5(void)       { bln_del_sell_stops    = true;                    OnTick();   }
   void              OnClickButton6(void)       { bln_del_sell_limits   = true;                    OnTick();   }
   void              OnClickButton7(void)       { bln_open_buy          = true;                    OnTick();   }
   void              OnClickButton8(void)       { bln_open_sell         = true;                    OnTick();   }
   void              OnClickButton9(void)       { bln_buy_stop          = true;                    OnTick();   }
   void              OnClickButton10(void)      { bln_buy_limit         = true;                    OnTick();   }
   void              OnClickButton11(void)      { bln_sell_stop         = true;                    OnTick();   }
   void              OnClickButton12(void)      { bln_sell_limit        = true;                    OnTick();   }
   void              OnChangeSpinEdit1(void)    { dbl_volume_buy        = m_spin_edit1.Value();    OnTick();   }
   void              OnChangeSpinEdit2(void)    { dbl_volume_sell       = m_spin_edit2.Value();    OnTick();   }
   void              OnChangeSpinEdit3(void)    { dbl_volume_buy_stop   = m_spin_edit3.Value();    OnTick();   }
   void              OnChangeSpinEdit4(void)    { dbl_volume_buy_limit  = m_spin_edit4.Value();    OnTick();   }
   void              OnChangeSpinEdit5(void)    { dbl_price_buy_stop    = m_spin_edit5.Value();    OnTick();   }
   void              OnChangeSpinEdit6(void)    { dbl_price_buy_limit   = m_spin_edit6.Value();    OnTick();   }
   void              OnChangeSpinEdit7(void)    { dbl_volume_sell_stop  = m_spin_edit7.Value();    OnTick();   }
   void              OnChangeSpinEdit8(void)    { dbl_volume_sell_limit = m_spin_edit8.Value();    OnTick();   }
   void              OnChangeSpinEdit9(void)    { dbl_price_sell_stop   = m_spin_edit9.Value();    OnTick();   }
   void              OnChangeSpinEdit10(void)   { dbl_price_sell_limit  = m_spin_edit10.Value();   OnTick();   }
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CTradingBoxingDialog)
ON_EVENT(ON_CLICK,m_button1,OnClickButton1)
ON_EVENT(ON_CLICK,m_button2,OnClickButton2)
ON_EVENT(ON_CLICK,m_button3,OnClickButton3)
ON_EVENT(ON_CLICK,m_button4,OnClickButton4)
ON_EVENT(ON_CLICK,m_button5,OnClickButton5)
ON_EVENT(ON_CLICK,m_button6,OnClickButton6)
ON_EVENT(ON_CLICK,m_button7,OnClickButton7)
ON_EVENT(ON_CLICK,m_button8,OnClickButton8)
ON_EVENT(ON_CLICK,m_button9,OnClickButton9)
ON_EVENT(ON_CLICK,m_button10,OnClickButton10)
ON_EVENT(ON_CLICK,m_button11,OnClickButton11)
ON_EVENT(ON_CLICK,m_button12,OnClickButton12)
ON_EVENT(ON_CHANGE,m_spin_edit1,OnChangeSpinEdit1)
ON_EVENT(ON_CHANGE,m_spin_edit2,OnChangeSpinEdit2)
ON_EVENT(ON_CHANGE,m_spin_edit3,OnChangeSpinEdit3)
ON_EVENT(ON_CHANGE,m_spin_edit4,OnChangeSpinEdit4)
ON_EVENT(ON_CHANGE,m_spin_edit5,OnChangeSpinEdit5)
ON_EVENT(ON_CHANGE,m_spin_edit6,OnChangeSpinEdit6)
ON_EVENT(ON_CHANGE,m_spin_edit7,OnChangeSpinEdit7)
ON_EVENT(ON_CHANGE,m_spin_edit8,OnChangeSpinEdit8)
ON_EVENT(ON_CHANGE,m_spin_edit9,OnChangeSpinEdit9)
ON_EVENT(ON_CHANGE,m_spin_edit10,OnChangeSpinEdit10)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradingBoxingDialog::CTradingBoxingDialog(void) : m_magic(335685240),
                                                   m_slippage(10),
                                                   bln_close_buys(false),
                                                   bln_close_sells(false),
                                                   bln_del_buy_stops(false),
                                                   bln_del_buy_limits(false),
                                                   bln_del_sell_stops(false),
                                                   bln_del_sell_limits(false),
                                                   bln_open_buy(false),
                                                   bln_open_sell(false),
                                                   bln_buy_stop(false),
                                                   bln_buy_limit(false),
                                                   bln_sell_stop(false),
                                                   bln_sell_limit(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradingBoxingDialog::~CTradingBoxingDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                                  const int x2,const int y2,const ulong magic)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(false);
   RefreshRates();
   m_magic=magic;
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- create dependent controls
   if(!CreateButton1())
      return(false);
   if(!CreateButton2())
      return(false);
   if(!CreateButton3())
      return(false);
   if(!CreateButton4())
      return(false);
   if(!CreateButton5())
      return(false);
   if(!CreateButton6())
      return(false);
   if(!CreateButton7())
      return(false);
   if(!CreateButton8())
      return(false);
   if(!CreateSpinEdit1())
      return(false);
   if(!CreateSpinEdit2())
      return(false);
   if(!CreateButton9())
      return(false);
   if(!CreateButton10())
      return(false);
   if(!CreateSpinEdit3())
      return(false);
   if(!CreateSpinEdit4())
      return(false);
   if(!CreateSpinEdit5())
      return(false);
   if(!CreateSpinEdit6())
      return(false);
   if(!CreateButton11())
      return(false);
   if(!CreateButton12())
      return(false);
   if(!CreateSpinEdit7())
      return(false);
   if(!CreateSpinEdit8())
      return(false);
   if(!CreateSpinEdit9())
      return(false);
   if(!CreateSpinEdit10())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int CTradingBoxingDialog::CalculatePositions(const ENUM_POSITION_TYPE pos_type)
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Calculate Orders                                                    |
//+------------------------------------------------------------------+
int CTradingBoxingDialog::CalculateOrders(const ENUM_ORDER_TYPE order_type)
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button1.Create(m_chart_id,m_name+"Button1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button1.Text("Close Buys"))
      return(false);
   if(!Add(m_button1))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button2" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button2.Create(m_chart_id,m_name+"Button2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button2.Text("Close Sells"))
      return(false);
   if(!Add(m_button2))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button3" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton3(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button3.Create(m_chart_id,m_name+"Button3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button3.Text("Del Buy stops"))
      return(false);
   if(!Add(m_button3))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button4" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton4(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button4.Create(m_chart_id,m_name+"Button4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button4.Text("Del Buy limits"))
      return(false);
   if(!Add(m_button4))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button5" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton5(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button5.Create(m_chart_id,m_name+"Button5",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button5.Text("Del Sell stops"))
      return(false);
   if(!Add(m_button5))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button6" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton6(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button6.Create(m_chart_id,m_name+"Button6",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button6.Text("Del Sell limits"))
      return(false);
   if(!Add(m_button6))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button7" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton7(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button7.Create(m_chart_id,m_name+"Button7",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button7.Text("Buy"))
      return(false);
   if(!Add(m_button7))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button8" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton8(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button8.Create(m_chart_id,m_name+"Button8",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button8.Text("Sell"))
      return(false);
   if(!Add(m_button8))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit1" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit1.Create(m_chart_id,m_name+"SpinEdit1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit1))
      return(false);
   m_spin_edit1.DisplayedDigits(2);
   m_spin_edit1.MinValue(m_symbol.LotsMin());
   m_spin_edit1.MaxValue(m_symbol.LotsMax());
   m_spin_edit1.Value(m_symbol.LotsMin());
   dbl_volume_buy=m_spin_edit1.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit2" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit2.Create(m_chart_id,m_name+"SpinEdit2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit2))
      return(false);
   m_spin_edit2.DisplayedDigits(2);
   m_spin_edit2.MinValue(m_symbol.LotsMin());
   m_spin_edit2.MaxValue(m_symbol.LotsMax());
   m_spin_edit2.Value(m_symbol.LotsMin());
   dbl_volume_sell=m_spin_edit2.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button9" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton9(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=3*INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button9.Create(m_chart_id,m_name+"Button9",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button9.Text("Buy stop"))
      return(false);
   if(!Add(m_button9))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button10" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton10(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=3*INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button10.Create(m_chart_id,m_name+"Button10",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button10.Text("Buy limit"))
      return(false);
   if(!Add(m_button10))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit3" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit3(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=3*INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit3.Create(m_chart_id,m_name+"SpinEdit3",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit3))
      return(false);
   m_spin_edit3.DisplayedDigits(2);
   m_spin_edit3.MinValue(m_symbol.LotsMin());
   m_spin_edit3.MaxValue(m_symbol.LotsMax());
   m_spin_edit3.Value(m_symbol.LotsMin());
   dbl_volume_buy_stop=m_spin_edit3.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit4" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit4(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=3*INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit4.Create(m_chart_id,m_name+"SpinEdit4",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit4))
      return(false);
   m_spin_edit4.DisplayedDigits(2);
   m_spin_edit4.MinValue(m_symbol.LotsMin());
   m_spin_edit4.MaxValue(m_symbol.LotsMax());
   m_spin_edit4.Value(m_symbol.LotsMin());
   dbl_volume_buy_limit=m_spin_edit4.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit5" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit5(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=3*INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit5.Create(m_chart_id,m_name+"SpinEdit5",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit5))
      return(false);
   m_spin_edit5.DisplayedDigits(m_symbol.Digits());
   m_spin_edit5.MinValue(m_symbol.TickSize()*10.0);
   m_spin_edit5.MaxValue(m_symbol.Bid()*3.0);
   m_spin_edit5.Value(m_symbol.Bid());
   dbl_price_buy_stop=m_spin_edit5.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit6" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit6(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=3*INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit6.Create(m_chart_id,m_name+"SpinEdit6",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit6))
      return(false);
   m_spin_edit6.DisplayedDigits(m_symbol.Digits());
   m_spin_edit6.MinValue(m_symbol.TickSize()*10.0);
   m_spin_edit6.MaxValue(m_symbol.Bid()*3.0);
   m_spin_edit6.Value(m_symbol.Bid());
   dbl_price_buy_limit=m_spin_edit6.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button11" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton11(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=4*INDENT_TOP+8*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button11.Create(m_chart_id,m_name+"Button11",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button11.Text("Sell stop"))
      return(false);
   if(!Add(m_button11))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button12" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButton12(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=4*INDENT_TOP+8*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button12.Create(m_chart_id,m_name+"Button12",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button12.Text("Sell limit"))
      return(false);
   if(!Add(m_button12))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit7" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit7(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=4*INDENT_TOP+9*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit7.Create(m_chart_id,m_name+"SpinEdit7",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit7))
      return(false);
   m_spin_edit7.DisplayedDigits(2);
   m_spin_edit7.MinValue(m_symbol.LotsMin());
   m_spin_edit7.MaxValue(m_symbol.LotsMax());
   m_spin_edit7.Value(m_symbol.LotsMin());
   dbl_volume_sell_stop=m_spin_edit7.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit8" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit8(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=4*INDENT_TOP+9*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit8.Create(m_chart_id,m_name+"SpinEdit8",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit8))
      return(false);
   m_spin_edit8.DisplayedDigits(2);
   m_spin_edit8.MinValue(m_symbol.LotsMin());
   m_spin_edit8.MaxValue(m_symbol.LotsMax());
   m_spin_edit8.Value(m_symbol.LotsMin());
   dbl_volume_sell_limit=m_spin_edit8.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit9" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit9(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=4*INDENT_TOP+10*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit9.Create(m_chart_id,m_name+"SpinEdit9",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit9))
      return(false);
   m_spin_edit9.DisplayedDigits(m_symbol.Digits());
   m_spin_edit9.MinValue(m_symbol.TickSize()*10.0);
   m_spin_edit9.MaxValue(m_symbol.Bid()*3.0);
   m_spin_edit9.Value(m_symbol.Bid());
   dbl_price_sell_stop=m_spin_edit9.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit10" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit10(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=4*INDENT_TOP+10*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit10.Create(m_chart_id,m_name+"SpinEdit10",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit10))
      return(false);
   m_spin_edit10.DisplayedDigits(m_symbol.Digits());
   m_spin_edit10.MinValue(m_symbol.TickSize()*10.0);
   m_spin_edit10.MaxValue(m_symbol.Bid()*3.0);
   m_spin_edit10.Value(m_symbol.Bid());
   dbl_price_sell_limit=m_spin_edit10.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Minimize                                                         |
//|   --> https://www.mql5.com/ru/articles/4503#para10               |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::Minimize(void)
  {
//--- переменная для получения панели быстрой торговли
   long one_click_visible=-1;  // 0 - панели быстрой торговли нет 
   if(!ChartGetInteger(m_chart_id,CHART_SHOW_ONE_CLICK,0,one_click_visible))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- минимальный отступ для свернутой панели приложения
   int min_y_indent=28;
   if(one_click_visible)
      min_y_indent=100;  // отступ, если быстрая торговля показана на графике
//--- получим текущий отступ для свернутой панели приложения
   int current_y_top=m_min_rect.top;
   int current_y_bottom=m_min_rect.bottom;
   int height=current_y_bottom-current_y_top;
//--- вычислим новый минимальный отступ от верха для свернутой панели приложения
   if(m_min_rect.top!=min_y_indent)
     {
      m_min_rect.top=min_y_indent;
      //--- сместим также нижнюю границу свернутой иконки
      m_min_rect.bottom=m_min_rect.top+height;
     }
//--- теперь можно вызвать метод базового класса
   CAppDialog::Minimize();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::OnTick(void)
  {
   if(bln_close_buys)
     {
      ClosePositions(POSITION_TYPE_BUY);
      if(CalculatePositions(POSITION_TYPE_BUY)>0)
         return;
      bln_close_buys=false;
     }
//---
   if(bln_close_sells)
     {
      ClosePositions(POSITION_TYPE_SELL);
      if(CalculatePositions(POSITION_TYPE_SELL)>0)
         return;
      bln_close_sells=false;
     }
//---
   if(bln_del_buy_stops)
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      if(CalculateOrders(ORDER_TYPE_BUY_STOP)>0)
         return;
      bln_del_buy_stops=false;
     }
//---
   if(bln_del_buy_limits)
     {
      DeleteOrders(ORDER_TYPE_BUY_LIMIT);
      if(CalculateOrders(ORDER_TYPE_BUY_LIMIT)>0)
         return;
      bln_del_buy_limits=false;
     }
//---
   if(bln_del_sell_stops)
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      if(CalculateOrders(ORDER_TYPE_SELL_STOP)>0)
         return;
      bln_del_sell_stops=false;
     }
//---
   if(bln_del_sell_limits)
     {
      DeleteOrders(ORDER_TYPE_SELL_LIMIT);
      if(CalculateOrders(ORDER_TYPE_SELL_LIMIT)>0)
         return;
      bln_del_sell_limits=false;
     }
//---
   if(bln_open_buy)
     {
      m_trade.Buy(dbl_volume_buy,m_symbol.Name());
      bln_open_buy=false;
     }
//---
   if(bln_open_sell)
     {
      m_trade.Sell(dbl_volume_sell,m_symbol.Name());
      bln_open_sell=false;
     }
//---
   if(bln_buy_stop)
     {
      if(m_trade.BuyStop(dbl_volume_buy_stop,m_symbol.NormalizePrice(dbl_price_buy_stop),m_symbol.Name()))
         Print("BUY_STOP - > true. ticket of order = ",m_trade.ResultOrder());
      else
         Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      bln_buy_stop=false;
     }
//---
   if(bln_buy_limit)
     {
      if(m_trade.BuyLimit(dbl_volume_buy_limit,m_symbol.NormalizePrice(dbl_price_buy_limit),m_symbol.Name()))
         Print("BUY_LIMIT - > true. ticket of order = ",m_trade.ResultOrder());
      else
         Print("BUY_LIMIT -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      bln_buy_limit=false;
     }
//---
   if(bln_sell_stop)
     {
      if(m_trade.SellStop(dbl_volume_sell_stop,m_symbol.NormalizePrice(dbl_price_sell_stop),m_symbol.Name()))
         Print("SELL_STOP - > true. ticket of order = ",m_trade.ResultOrder());
      else
         Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      bln_sell_stop=false;
     }
//---   
   if(bln_sell_limit)
     {
      if(m_trade.SellLimit(dbl_volume_sell_limit,m_symbol.NormalizePrice(dbl_price_sell_limit),m_symbol.Name()))
         Print("SELL_LIMIT - > true. ticket of order = ",m_trade.ResultOrder());
      else
         Print("SELL_LIMIT -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
      bln_sell_limit=false;
     }
//---  
  }
//+------------------------------------------------------------------+
