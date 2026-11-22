//+------------------------------------------------------------------+
//|                                              Swap Calculator.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#define VERSION     "2.85"
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   VERSION
#property description "Calculate the swap money accumulated for a trade."
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh>
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
   CLabel            m_lbl_days;
   CLabel            m_lbl_swap_mode;
   CLabel            m_lbl_triple_swap;
   CLabel            m_lbl_swap_long;
   CLabel            m_lbl_swap_short;
   CComboBox         m_symbol;                        // the dropdown list object
   CSpinEditDouble   m_volume;                        // the display field object
   CSpinEditDouble   m_days;                          // the display field object
   CEdit             m_currency;                      // the display field object
   CEdit             m_swap_mode;                     // the display field object
   CEdit             m_triple_swap;                   // the display field object
   CEdit             m_swap_long;                     // the display field object
   CEdit             m_swap_short;                    // the display field object
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
   bool              CreateControSwapMode(void);
   bool              CreateControTripleSwap(void);
   bool              CreateControlCalculate(void);
   bool              CreateControSwapLong(void);
   bool              CreateControSwapShort(void);
   //--- handlers of the dependent controls events
   virtual void      OnClickButtonClose(void);
   void              OnChangeComboSymbol(void);
   void              OnClickButtonCalculate(void);

private:
   string            SwapModeDescription(long swap_mode);
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
   if(!CreateControlHoldingDays())
      return(false);
   if(!CreateControSwapMode())
      return(false);
   if(!CreateControTripleSwap())
      return(false);
   if(!CreateControlCalculate())
      return(false);
   if(!CreateControSwapLong())
      return(false);
   if(!CreateControSwapShort())
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
//| Create the "m_swap_mode" edit                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControSwapMode(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_swap_mode.Create(m_chart_id,m_name+"m_lbl_swap_mode",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_swap_mode.Text("Swap mode:"))
      return(false);
   if(!m_lbl_swap_mode.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_swap_mode))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_swap_mode.Create(m_chart_id,m_name+"m_swap_mode",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_swap_mode.ReadOnly(true))
      return(false);
   if(!m_swap_mode.Text(SwapModeDescription(m_sym.SwapMode())))
      return(false);
   if(!m_swap_mode.ColorBackground(clrGainsboro))
      return(false);
   if(!m_swap_mode.FontSize(m_font_size))
      return(false);
   if(!Add(m_swap_mode))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_triple_swap" edit                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControTripleSwap(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_triple_swap.Create(m_chart_id,m_name+"m_lbl_triple_swap",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_triple_swap.Text("Triple swap:"))
      return(false);
   if(!m_lbl_triple_swap.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_triple_swap))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_triple_swap.Create(m_chart_id,m_name+"m_triple_swap",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_triple_swap.ReadOnly(true))
      return(false);
   if(!m_triple_swap.Text(m_sym.SwapRollover3daysDescription()))
      return(false);
   if(!m_triple_swap.ColorBackground(clrGainsboro))
      return(false);
   if(!m_triple_swap.FontSize(m_font_size))
      return(false);
   if(!Add(m_triple_swap))
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
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*3+CONTROLS_GAP_Y*7);
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
//| Create the "m_swap_long" edit                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControSwapLong(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*3+BUTTON_HEIGHT+CONTROLS_GAP_Y*9);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_swap_long.Create(m_chart_id,m_name+"m_lbl_swap_long",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_swap_long.Text("Swap long: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_swap_long.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_swap_long))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_swap_long.Create(m_chart_id,m_name+"m_swap_long",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_swap_long.ReadOnly(true))
      return(false);
   if(!m_swap_long.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_swap_long.Color(clrGreen))
      return(false);
   if(!m_swap_long.Font("Arial Bold"))
      return(false);
   if(!m_swap_long.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_swap_long",OBJPROP_TOOLTIP,"The long swap value depends upon the trade size, symbol's \nlong swap rates, and the number of holding days."))
      return(false);
   if(!Add(m_swap_long))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_swap_short" edit                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControSwapShort(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*3+BUTTON_HEIGHT+CONTROLS_GAP_Y*9);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_swap_short.Create(m_chart_id,m_name+"m_lbl_swap_short",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_swap_short.Text("Swap short: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_swap_short.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_swap_short))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_swap_short.Create(m_chart_id,m_name+"m_swap_short",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_swap_short.ReadOnly(true))
      return(false);
   if(!m_swap_short.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_swap_short.Color(clrGreen))
      return(false);
   if(!m_swap_short.Font("Arial Bold"))
      return(false);
   if(!m_swap_short.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_swap_short",OBJPROP_TOOLTIP,"The short swap value depends upon the trade size, symbol's \nshort swap rates, and the number of holding days."))
      return(false);
   if(!Add(m_swap_short))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Get the property value "SYMBOL_SWAP_MODE" as string              |
//+------------------------------------------------------------------+
string CControlsDialog::SwapModeDescription(long swap_mode)
  {
   string str;
//---
   switch((ENUM_SYMBOL_SWAP_MODE)swap_mode)
     {
      case SYMBOL_SWAP_MODE_DISABLED:
         str="Disabled";
         break;
      case SYMBOL_SWAP_MODE_POINTS:
         str="Points";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
         str="Base currency";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
         str="Margin currency";
         break;
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         str=m_account.Currency();
         break;
      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
         str="Interest (Current)";
         break;
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
         str="Interest (Open)";
         break;
      case SYMBOL_SWAP_MODE_REOPEN_CURRENT:
         str="Reopening";
         break;
      case SYMBOL_SWAP_MODE_REOPEN_BID:
         str="Reopening";
         break;
      default:
         str="Unknown mode";
     }
//--- result
   return(str);
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
   m_swap_mode.Text(SwapModeDescription(m_sym.SwapMode()));
   m_triple_swap.Text(m_sym.SwapRollover3daysDescription());
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCalculate(void)
  {
   const string symbol=m_symbol.Select();
   const double volume=m_volume.Value();
   const int num_days=(int)m_days.Value();
//---
   double swap_long=OrderCalcSwap(ORDER_TYPE_BUY,symbol,volume)*num_days;
   double swap_short=OrderCalcSwap(ORDER_TYPE_SELL,symbol,volume)*num_days;
//---
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   m_swap_long.Text(FormatDouble(swap_long,acc_digits));
   m_swap_short.Text(FormatDouble(swap_short,acc_digits));
   m_swap_long.Color((swap_long<0)?clrRed:clrGreen);
   m_swap_short.Color((swap_short<0)?clrRed:clrGreen);
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
   if(!ExtDialog.Create(0,"Swap Calculator v"+VERSION,0,100,100,374,433))
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
