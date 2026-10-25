//+------------------------------------------------------------------+
//|                                            Margin Calculator.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#define VERSION     "2.85"
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   VERSION
#property description "Calculate the margin required for a trade."
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
   CLabel            m_lbl_volume;
   CLabel            m_lbl_currency;
   CLabel            m_lbl_leverage;
   CLabel            m_lbl_ordertype;
   CLabel            m_lbl_margin;
   CComboBox         m_symbol;                        // the dropdown list object
   CComboBox         m_ordertype;                     // the dropdown list object
   CSpinEditDouble   m_volume;                        // the display field object
   CEdit             m_currency;                      // the display field object
   CEdit             m_leverage;                      // the display field object
   CEdit             m_margin;                        // the display field object
   CButton           m_calculate;                     // the button object
   CCheckBox         m_no_hedging;

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
   bool              CreateControlLeverage(void);
   bool              CreateControlOrderType(void);
   bool              CreateControlNoHedging(void);
   bool              CreateControlCalculate(void);
   bool              CreateControlMargin(void);
   //--- handlers of the dependent controls events
   virtual void      OnClickButtonClose(void);
   void              OnChangeComboSymbol(void);
   void              OnClickButtonCalculate(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
   ON_EVENT(ON_CHANGE,m_symbol,OnChangeComboSymbol)
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
   if(!CreateControlLeverage())
      return(false);
   if(!CreateControlOrderType())
      return(false);
   if(!CreateControlNoHedging())
      return(false);
   if(!CreateControlCalculate())
      return(false);
   if(!CreateControlMargin())
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
//| Create the "m_leverage" edit                                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlLeverage(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT+EDIT_HEIGHT+CONTROLS_GAP_Y*2);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_leverage.Create(m_chart_id,m_name+"m_lbl_leverage",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_leverage.Text("Symbol leverage:"))
      return(false);
   if(!m_lbl_leverage.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_leverage))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_leverage.Create(m_chart_id,m_name+"m_leverage",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_leverage.ReadOnly(true))
      return(false);
// if(!m_leverage.Text("1:"+(string)m_account.Leverage()))
   if(!m_leverage.Text("1:"+(string)SymbolLeverage(Symbol())))
      return(false);
   if(!m_leverage.ColorBackground(clrGainsboro))
      return(false);
   if(!m_leverage.FontSize(m_font_size))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_leverage",OBJPROP_TOOLTIP,"The ratio of the required margin to the trade's notional value, in account currency."))
      return(false);
   if(!Add(m_leverage))
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
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
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
//| Create the "m_no_hedging" check box                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlNoHedging(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*2+CONTROLS_GAP_Y*5);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_no_hedging.Create(m_chart_id,m_name+"m_no_hedging",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_no_hedging.Text("Do not hedge"))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_no_hedging",OBJPROP_TOOLTIP,"Calculate the unhedged position margin."))
      return(false);
   if(!Add(m_no_hedging))
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
   int y1=INDENT_TOP+(LABEL_HEIGHT*4+EDIT_HEIGHT*3+CONTROLS_GAP_Y*6);
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
//| Create the "m_margin" edit                                       |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlMargin(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*4+EDIT_HEIGHT*3+BUTTON_HEIGHT+CONTROLS_GAP_Y*8);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_margin.Create(m_chart_id,m_name+"m_lbl_margin",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_margin.Text("Required new margin: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_margin.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_margin))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   x2=x1+BUTTON_WIDTH;
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_margin.Create(m_chart_id,m_name+"m_margin",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_margin.ReadOnly(true))
      return(false);
   if(!m_margin.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_margin.Color(clrGreen))
      return(false);
   if(!m_margin.Font("Arial Bold"))
      return(false);
   if(!m_margin.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_margin",OBJPROP_TOOLTIP,"The amount of money that will be \"locked up\" or \"released\" to open a position.\nIf margin is hedged, opposite open positions on the symbol are considered."))
      return(false);
   if(!Add(m_margin))
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
//---
   m_sym.Name(symbol);
   m_volume.SetParameters(m_volume.Value(),m_sym.LotsMin(),m_sym.LotsMax(),10*m_sym.LotsStep(),GetDigits(m_sym.LotsStep()));
// m_leverage.Text("1:"+(string)m_account.Leverage());
   m_leverage.Text("1:"+(string)SymbolLeverage(symbol));
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCalculate(void)
  {
   const string symbol=m_symbol.Select();
   const double volume=m_volume.Value();
   const bool no_hedging=m_no_hedging.Checked();
   const ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)m_ordertype.Value();
//---
   m_sym.RefreshRates();
   double margin=0.0;
   double price=(order_type==ORDER_TYPE_BUY)?m_sym.Ask():m_sym.Bid();
//---
   if(no_hedging)
      bool res=OrderCalcMargin(order_type,symbol,volume,price,margin);
   else
      margin=m_account.FreeMargin()-AccountFreeMarginCheck(order_type,symbol,volume,price);
//---
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   m_margin.Text(margin<m_account.FreeMargin()?FormatDouble(margin,acc_digits):"No enough money");
   m_margin.Color(margin<m_account.FreeMargin()&&margin>0?clrGreen:clrRed);  // insufficient or released margin is red
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
   if(!ExtDialog.Create(0,"Margin Calculator v"+VERSION,0,100,100,374,432))
      return(INIT_FAILED);
//--- read the previous state of the program
   ExtDialog.IniFileLoad();
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
