//+------------------------------------------------------------------+
//|                                            Profit Calculator.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#define VERSION     "2.85"
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   VERSION
#property description "Calculate the profit or risk money for a trade."
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\CheckBox.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include "SpinEditDouble.mqh"
#include "Functions.mqh"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define CONTROLS_GAP_X                      (20)      // gap by X coordinate
#define CONTROLS_GAP_Y                      (10)      // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (240)     // size by X coordinate
#define BUTTON_HEIGHT                       (27)      // size by Y coordinate
//--- for the indication area
#define EDIT_WIDTH                          (110)     // size by X coordinate
#define EDIT_HEIGHT                         (27)      // size by Y coordinate
#define LABEL_HEIGHT                        (10)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CLabel            m_lbl_symbol;
   CLabel            m_lbl_ordertype;
   CLabel            m_lbl_volume;
   CLabel            m_lbl_currency;
   CLabel            m_lbl_days;
   CLabel            m_lbl_open_price;
   CLabel            m_lbl_close_price;
   CLabel            m_lbl_profit_pts;
   CLabel            m_lbl_profit;
   CLabel            m_lbl_swap;
   CComboBox         m_symbol;                        // the dropdown list object
   CComboBox         m_ordertype;                     // the dropdown list object
   CSpinEditDouble   m_volume;                        // the display field object
   CSpinEditDouble   m_days;                          // the display field object
   CSpinEditDouble   m_open_price;                    // the display field object
   CSpinEditDouble   m_close_price;                   // the display field object
   CCheckBox         m_use_points;
   CEdit             m_currency;                      // the display field object
   CEdit             m_profit;                        // the display field object
   CEdit             m_swap;                          // the display field object
   CButton           m_calculate;                     // the button object

   CAccountInfo      m_account;
   CSymbolInfo       m_sym;
   int               m_font_size;                     // object font size

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateControlSymbol(void);
   bool              CreateControlVolume(void);
   bool              CreateControlCurrency(void);
   bool              CreateControlHoldingDays(void);
   bool              CreateControlOpenPrice(void);
   bool              CreateControlClosePrice(void);
   bool              CreateControlOrderType(void);
   bool              CreateControlUsePoints(void);
   bool              CreateControlCalculate(void);
   bool              CreateControlProfit(void);
   bool              CreateControlSwap(void);
   //--- handlers of the dependent controls events
   virtual void      OnClickButtonClose(void);
   void              OnChangeComboSymbol(void);
   void              OnChangeOrderType(void);
   void              OnChangeChkUsePoints(void);
   void              OnClickButtonCalculate(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
   ON_EVENT(ON_CHANGE,m_symbol,OnChangeComboSymbol)
   ON_EVENT(ON_CHANGE,m_ordertype,OnChangeOrderType)
   ON_EVENT(ON_CHANGE,m_use_points,OnChangeChkUsePoints)
   ON_EVENT(ON_CLICK,m_calculate,OnClickButtonCalculate)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
   m_sym.Name(Symbol());
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- scale controls font size to screen dpi
   double screen_dpi=(double)TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   m_font_size=(int)MathRound(CONTROLS_FONT_SIZE * 96.0 / screen_dpi);
//--- create dependent controls
   if(!CreateControlSymbol())
      return(false);
   if(!CreateControlVolume())
      return(false);
   if(!CreateControlCurrency())
      return(false);
   if(!CreateControlHoldingDays())
      return(false);
   if(!CreateControlOpenPrice())
      return(false);
   if(!CreateControlClosePrice())
      return(false);
   if(!CreateControlOrderType())
      return(false);
   if(!CreateControlUsePoints())
      return(false);
   if(!CreateControlCalculate())
      return(false);
   if(!CreateControlProfit())
      return(false);
   if(!CreateControlSwap())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_symbol" combo box                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlSymbol(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_symbol.Create(m_chart_id,m_name+"m_lbl_symbol",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_symbol.Text("Symbol:"))
      return(false);
   if(!m_lbl_symbol.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_symbol))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_symbol.Create(m_chart_id,m_name+"m_symbol",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_symbol))
      return(false);
//--- fill out with market watch symbols
   int total=SymbolsTotal(true);
   CArrayString array;
   array.Sort();
   for(int i=0; i<total; i++)
      if(!array.InsertSort(SymbolName(i,true)))
         return(false);
   for(int i=0; i<total; i++)
      if(!m_symbol.ItemAdd(array.At(i)))
         return(false);
   if(!m_symbol.Select(0))
      return(false);
   if(!m_symbol.SelectByText(Symbol()))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_volume" edit                                       |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlVolume(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_volume.Create(m_chart_id,m_name+"m_lbl_volume",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_volume.Text("Trade size (in lots):"))
      return(false);
   if(!m_lbl_volume.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_volume))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_volume.Create(m_chart_id,m_name+"m_volume",m_subwin,x1,y1,x2,y2))
      return(false);
   m_volume.SetParameters(1.00,m_sym.LotsMin(),m_sym.LotsMax(),10*m_sym.LotsStep(),GetDigits(m_sym.LotsStep()));
   if(!m_volume.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!Add(m_volume))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_currency" edit                                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlCurrency(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT+EDIT_HEIGHT+CONTROLS_GAP_Y*2);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_currency.Create(m_chart_id,m_name+"m_lbl_currency",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_currency.Text("Account currency:"))
      return(false);
   if(!m_lbl_currency.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_currency))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_currency.Create(m_chart_id,m_name+"m_currency",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_currency.ReadOnly(true))
      return(false);
   if(!m_currency.Text(m_account.Currency()))
      return(false);
   if(!m_currency.ColorBackground(clrGainsboro))
      return(false);
   if(!m_currency.FontSize(m_font_size))
      return(false);
   if(!Add(m_currency))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_days" edit                                         |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlHoldingDays(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT+EDIT_HEIGHT+CONTROLS_GAP_Y*2);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_days.Create(m_chart_id,m_name+"m_lbl_days",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_days.Text("Holding days:"))
      return(false);
   if(!m_lbl_days.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_days))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_days.Create(m_chart_id,m_name+"m_days",m_subwin,x1,y1,x2,y2))
      return(false);
   m_days.SetParameters(1,0,9999,1,0);
   if(!m_days.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!Add(m_days))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_open_price" edit                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlOpenPrice(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_open_price.Create(m_chart_id,m_name+"m_lbl_open_price",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_open_price.Text("Open price:"))
      return(false);
   if(!m_lbl_open_price.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_open_price))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_open_price.Create(m_chart_id,m_name+"m_open_price",m_subwin,x1,y1,x2,y2))
      return(false);
   m_sym.RefreshRates();
   m_open_price.SetParameters(m_sym.Ask(),0.0,DBL_MAX,10*m_sym.TickSize(),m_sym.Digits());
   if(!m_open_price.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!Add(m_open_price))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_close_price" edit                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlClosePrice(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_close_price.Create(m_chart_id,m_name+"m_lbl_close_price",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_close_price.Text("Close price:"))
      return(false);
   if(!m_lbl_close_price.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_close_price))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_close_price.Create(m_chart_id,m_name+"m_close_price",m_subwin,x1,y1,x2,y2))
      return(false);
   m_sym.RefreshRates();
   m_close_price.SetParameters(m_sym.Ask()+100*m_sym.TickSize(),0.0,DBL_MAX,10*m_sym.TickSize(),m_sym.Digits());
   if(!m_close_price.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!Add(m_close_price))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_ordertype" combo box                               |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlOrderType(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*3+CONTROLS_GAP_Y*6);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_ordertype.Create(m_chart_id,m_name+"m_lbl_ordertype",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_ordertype.Text("Order type:"))
      return(false);
   if(!m_lbl_ordertype.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_ordertype))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_ordertype.Create(m_chart_id,m_name+"m_ordertype",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_ordertype))
      return(false);
//--- fill out with order types
   string items[2]= {"Buy / Long","Sell / Short"};
   for(int i=0; i<2; i++)
      if(!m_ordertype.ItemAdd(items[i]))
         return(false);
   if(!m_ordertype.Select(0))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_use_points" check box                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlUsePoints(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*4+EDIT_HEIGHT*3+CONTROLS_GAP_Y*7);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_use_points.Create(m_chart_id,m_name+"m_use_points",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_use_points.Text("Use P/L points"))
      return(false);
   if(!m_use_points.Checked(false))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_use_points",OBJPROP_TOOLTIP,"Use profit or loss points instead of the close price."))
      return(false);
   if(!Add(m_use_points))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_calculate" button                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlCalculate(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*5+EDIT_HEIGHT*4+CONTROLS_GAP_Y*8);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_calculate.Create(m_chart_id,m_name+"m_calculate",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_calculate.Text("Calculate"))
      return(false);
   if(!m_calculate.FontSize(m_font_size))
      return(false);
   if(!Add(m_calculate))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_profit" edit                                       |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlProfit(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*6+EDIT_HEIGHT*4+BUTTON_HEIGHT+CONTROLS_GAP_Y*9);
   int x2=x1+EDIT_HEIGHT;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_profit.Create(m_chart_id,m_name+"m_lbl_profit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_profit.Text("Profit/Loss: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_profit.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_profit))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   x2=x1+BUTTON_WIDTH;
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_profit.Create(m_chart_id,m_name+"m_profit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_profit.ReadOnly(true))
      return(false);
   if(!m_profit.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_profit.Color(clrGreen))
      return(false);
   if(!m_profit.Font("Arial Bold"))
      return(false);
   if(!m_profit.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_profit",OBJPROP_TOOLTIP,"The profit value depends upon the trade size, trade type, symbol's \ntick values, and the number of P/L ticks."))
      return(false);
   if(!Add(m_profit))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_swap" edit                                         |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlSwap(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*8+EDIT_HEIGHT*4+BUTTON_HEIGHT+CONTROLS_GAP_Y*13);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_swap.Create(m_chart_id,m_name+"m_lbl_swap",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_swap.Text("Swap: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_swap.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_swap))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   x2=x1+BUTTON_WIDTH;
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_swap.Create(m_chart_id,m_name+"m_swap",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_swap.ReadOnly(true))
      return(false);
   if(!m_swap.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_swap.Color(clrGreen))
      return(false);
   if(!m_swap.Font("Arial Bold"))
      return(false);
   if(!m_swap.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_swap",OBJPROP_TOOLTIP,"The swap value depends upon the trade size, trade type, symbol's \nswap rates, and the number of holding days."))
      return(false);
   if(!Add(m_swap))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonClose(void)
  {
   string text="Do you want to remove the program from the chart?";
   int mb_res=MessageBox(text,NULL,MB_YESNO|MB_ICONQUESTION);
   if(mb_res==IDYES)
     {
      CAppDialog::OnClickButtonClose();
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeComboSymbol(void)
  {
   const string symbol=m_symbol.Select();
   const long order_type=m_ordertype.Value();
//---
   m_sym.Name(symbol);
   m_sym.RefreshRates();
   m_volume.SetParameters(m_volume.Value(),m_sym.LotsMin(),m_sym.LotsMax(),10*m_sym.LotsStep(),GetDigits(m_sym.LotsStep()));
   double price=((ENUM_ORDER_TYPE)order_type==ORDER_TYPE_BUY)?m_sym.Ask():m_sym.Bid();
   double price2=price+100*m_sym.TickSize();
   double step=10*m_sym.TickSize();
   m_open_price.SetParameters(price,0.0,DBL_MAX,step,m_sym.Digits());
   if(!m_use_points.Checked())
      //--- set close price
      m_close_price.SetParameters(price2,0.0,DBL_MAX,step,m_sym.Digits());
   else
      //--- set p/l points
      m_close_price.SetParameters(100,-DBL_MAX,DBL_MAX,10,0);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeOrderType(void)
  {
   const long order_type=m_ordertype.Value();
//---
   m_sym.RefreshRates();
   double price=((ENUM_ORDER_TYPE)order_type==ORDER_TYPE_BUY)?m_sym.Ask():m_sym.Bid();
   m_open_price.Value(price);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeChkUsePoints(void)
  {
   const double open_price=m_open_price.Value();
   const long order_type=m_ordertype.Value();
//---
   if(m_use_points.Checked())
     {
      if(m_lbl_close_price.Text()=="Close price:")
        {
         m_lbl_close_price.Text("P/L points:");
         //--- calculate p/l points
         double close_price=m_close_price.Value();
         double diff=(ENUM_ORDER_TYPE)order_type==ORDER_TYPE_BUY ? close_price - open_price : open_price - close_price;
         double profit_pts=diff/m_sym.Point();
         m_close_price.SetParameters(profit_pts,-DBL_MAX,DBL_MAX,10,0);
        }
     }
   else
     {
      if(m_lbl_close_price.Text()=="P/L points:")
        {
         m_lbl_close_price.Text("Close price:");
         //--- calculate close price based on p/l points
         double profit_pts=m_close_price.Value();
         double diff=profit_pts*m_sym.Point();
         double close_price=(ENUM_ORDER_TYPE)order_type==ORDER_TYPE_BUY ? open_price + diff : open_price - diff;
         m_close_price.SetParameters(close_price,0.0,DBL_MAX,10*m_sym.TickSize(),m_sym.Digits());
        }
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCalculate(void)
  {
   const string symbol=m_symbol.Select();
   const double volume=m_volume.Value();
   const int num_days=(int)m_days.Value();
   const double open_price=m_open_price.Value();
   double close_price=m_close_price.Value();
   const long order_type=m_ordertype.Value();
//---
   if(m_use_points.Checked())
     {
      //--- calculate close price based on p/l points
      double profit_pts=m_close_price.Value();
      double diff=profit_pts*m_sym.Point();
      close_price=(ENUM_ORDER_TYPE)order_type==ORDER_TYPE_BUY ? open_price + diff : open_price - diff;
     }
//---
   double profit=0;
   double swap=0;
   if(OrderCalcProfit((ENUM_ORDER_TYPE)order_type,symbol,volume,open_price,close_price,profit))
     {
      swap=OrderCalcSwap((ENUM_ORDER_TYPE)order_type,symbol,volume) * num_days;
     }
//---
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   m_profit.Text(FormatDouble(profit,acc_digits));
   m_swap.Text(FormatDouble(swap,acc_digits));
   m_profit.Color((profit<0)?clrRed:clrGreen);
   m_swap.Color((swap<0)?clrRed:clrGreen);
  }
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog
   if(!ExtDialog.Create(0,"Profit Calculator v"+VERSION,0,100,100,374,550))
      return(INIT_FAILED);
//--- read the previous state of the program
   //ExtDialog.IniFileLoad();
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
//--- disable automatic minimization on chart change.
   if(id==CHARTEVENT_CHART_CHANGE)
      if(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)<ExtDialog.Height())
         return;
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+

// https://www.forexpeacearmy.com/tools/forex-calculator
// https://www.fxpro.com/trading-tools/calculators/all-in-one
