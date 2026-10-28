//+------------------------------------------------------------------+
//|                                     Position Size Calculator.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#define VERSION     "2.85"
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   VERSION
#property description "Calculate the position size for a trade."
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
   CLabel            m_lbl_stoploss;
   CLabel            m_lbl_currency;
   CLabel            m_lbl_balance;
   CLabel            m_lbl_risk;
   CLabel            m_lbl_commission;
   CLabel            m_lbl_ordertype;
   CLabel            m_lbl_position_size;
   CLabel            m_lbl_risk_money;
   CLabel            m_lbl_margin;
   CComboBox         m_symbol;                        // the dropdown list object
   CComboBox         m_ordertype;                     // the dropdown list object
   CSpinEditDouble   m_stoploss;                      // the display field object
   CSpinEditDouble   m_risk;                          // the display field object
   CSpinEditDouble   m_commission;                    // the display field object
   CEdit             m_currency;                      // the display field object
   CEdit             m_balance;                       // the display field object
   CEdit             m_position_size;                 // the display field object
   CEdit             m_risk_money;                    // the display field object
   CEdit             m_margin;                        // the display field object
   CButton           m_calculate;                     // the button object
   CCheckBox         m_use_equity;
   CCheckBox         m_switch_money;

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
   bool              CreateControlStopLoss(void);
   bool              CreateControlCurrency(void);
   bool              CreateControlBalance(void);
   bool              CreateControlRisk(void);
   bool              CreateControlCommission(void);
   bool              CreateControlOrderType(void);
   bool              CreateControlUseEquity(void);
   bool              CreateControlUseMoney(void);
   bool              CreateControlCalculate(void);
   bool              CreateControlPostionSize(void);
   bool              CreateControlRiskMoney(void);
   bool              CreateControlMargin(void);
   //--- handlers of the dependent controls events
   virtual void      OnClickButtonClose(void);
   void              OnChangeComboSymbol(void);
   void              OnChangeChkUseEquity(void);
   void              OnChangeChkSwitchMoney(void);
   void              OnClickButtonCalculate(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
   ON_EVENT(ON_CHANGE,m_symbol,OnChangeComboSymbol)
   ON_EVENT(ON_CHANGE,m_use_equity,OnChangeChkUseEquity)
   ON_EVENT(ON_CHANGE,m_switch_money,OnChangeChkSwitchMoney)
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
   if(!CreateControlStopLoss())
      return(false);
   if(!CreateControlCurrency())
      return(false);
   if(!CreateControlBalance())
      return(false);
   if(!CreateControlRisk())
      return(false);
   if(!CreateControlCommission())
      return(false);
   if(!CreateControlOrderType())
      return(false);
   if(!CreateControlUseEquity())
      return(false);
   if(!CreateControlUseMoney())
      return(false);
   if(!CreateControlCalculate())
      return(false);
   if(!CreateControlPostionSize())
      return(false);
   if(!CreateControlRiskMoney())
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
//| Create the "m_stoploss" edit                                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlStopLoss(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_stoploss.Create(m_chart_id,m_name+"m_lbl_stoploss",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_stoploss.Text("Stoploss (points):"))
      return(false);
   if(!m_lbl_stoploss.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_stoploss))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_stoploss.Create(m_chart_id,m_name+"m_stoploss",m_subwin,x1,y1,x2,y2))
      return(false);
   m_stoploss.SetParameters(100,1,DBL_MAX,10,0);
   if(!m_stoploss.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!Add(m_stoploss))
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
//| Create the "m_balance" edit                                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlBalance(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT+EDIT_HEIGHT+CONTROLS_GAP_Y*2);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_balance.Create(m_chart_id,m_name+"m_lbl_balance",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_balance.Text("Account balance:"))
      return(false);
   if(!m_lbl_balance.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_balance))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_balance.Create(m_chart_id,m_name+"m_balance",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_balance.ReadOnly(true))
      return(false);
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   if(!m_balance.Text(DoubleToString(m_account.Balance(),acc_digits)))
      return(false);
   if(!m_balance.ColorBackground(clrGainsboro))
      return(false);
   if(!m_balance.FontSize(m_font_size))
      return(false);
   if(!Add(m_balance))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_risk" edit                                         |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlRisk(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_risk.Create(m_chart_id,m_name+"m_lbl_risk",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_risk.Text("Risk percent, %:"))
      return(false);
   if(!m_lbl_risk.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_risk))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_risk.Create(m_chart_id,m_name+"m_risk",m_subwin,x1,y1,x2,y2))
      return(false);
   m_risk.SetParameters(2.0,0.0,100,0.1,2);
   if(!m_risk.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_risk",OBJPROP_TOOLTIP,"Percent risk tolerance, in percentage points from 0 to 100."))
      return(false);
   if(!Add(m_risk))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_use_equity" check box                              |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlUseEquity(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*3+EDIT_HEIGHT*3+CONTROLS_GAP_Y*6);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_use_equity.Create(m_chart_id,m_name+"m_use_equity",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_use_equity.Text("Use equity"))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_use_equity",OBJPROP_TOOLTIP,"Use the account equity instead of the account balance."))
      return(false);
   if(!Add(m_use_equity))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_switch_money" check box                            |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlUseMoney(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*4+EDIT_HEIGHT*3+CONTROLS_GAP_Y*8);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_switch_money.Create(m_chart_id,m_name+"m_switch_money",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_switch_money.Text("Switch money"))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_switch_money",OBJPROP_TOOLTIP,"Switch between risk percent (%) and risk money."))
      return(false);
   if(!Add(m_switch_money))
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
//| Create the "m_commission" edit                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlCommission(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_commission.Create(m_chart_id,m_name+"m_lbl_commission",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_commission.Text("Comm./lot: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_commission.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_commission))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_commission.Create(m_chart_id,m_name+"m_commission",m_subwin,x1,y1,x2,y2))
      return(false);
   m_commission.SetParameters(0,0.0,DBL_MAX,0.1,2);
   if(!m_commission.GetEditPointer().FontSize(m_font_size))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_commission",OBJPROP_TOOLTIP,"The broker's commission per lot per side, in account currency."))
      return(false);
   if(!Add(m_commission))
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
//| Create the "m_position_size" edit                                |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlPostionSize(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*6+EDIT_HEIGHT*4+BUTTON_HEIGHT+CONTROLS_GAP_Y*9);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_position_size.Create(m_chart_id,m_name+"m_lbl_position_size",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_position_size.Text("Position size: (Lots)"))
      return(false);
   if(!m_lbl_position_size.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_position_size))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   x2=x1+BUTTON_WIDTH;
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_position_size.Create(m_chart_id,m_name+"m_position_size",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_position_size.ReadOnly(true))
      return(false);
   if(!m_position_size.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_position_size.Color(clrGreen))
      return(false);
   if(!m_position_size.Font("Arial Bold"))
      return(false);
   if(!m_position_size.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_position_size",OBJPROP_TOOLTIP,"Calculated position size +/- adjustment to the broker's volume limits and account free margin."))
      return(false);
   if(!Add(m_position_size))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "m_risk_money" edit                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlRiskMoney(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*8+EDIT_HEIGHT*4+BUTTON_HEIGHT+CONTROLS_GAP_Y*13);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_risk_money.Create(m_chart_id,m_name+"m_lbl_risk_money",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_risk_money.Text("Risk money: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_risk_money.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_risk_money))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_risk_money.Create(m_chart_id,m_name+"m_risk_money",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_risk_money.ReadOnly(true))
      return(false);
   if(!m_risk_money.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_risk_money.Color(clrGreen))
      return(false);
   if(!m_risk_money.Font("Arial Bold"))
      return(false);
   if(!m_risk_money.FontSize(m_font_size))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_risk_money",OBJPROP_TOOLTIP,"The money that will be lost (including commissions) when position's stoploss is hit, in account currency."))
      return(false);
   if(!Add(m_risk_money))
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
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*8+EDIT_HEIGHT*4+BUTTON_HEIGHT+CONTROLS_GAP_Y*13);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_margin.Create(m_chart_id,m_name+"m_lbl_margin",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_margin.Text("Req. margin: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_margin.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_margin))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
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
   if(!m_margin.FontSize(m_font_size))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_margin",OBJPROP_TOOLTIP,"The amount of money that will be \"locked up\" or \"released\" to open a position.\nThis is a hedged margin considering opposite open positions on the symbol."))
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
   m_sym.Name(m_symbol.Select());
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeChkUseEquity(void)
  {
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   if(m_use_equity.Checked())
     {
      if(m_lbl_balance.Text()=="Account balance:")
        {
         m_lbl_balance.Text("Account equity:");
         m_balance.Text(DoubleToString(m_account.Equity(),acc_digits));
        }
     }
   else
     {
      if(m_lbl_balance.Text()=="Account equity:")
        {
         m_lbl_balance.Text("Account balance:");
         m_balance.Text(DoubleToString(m_account.Balance(),acc_digits));
        }
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeChkSwitchMoney(void)
  {
   if(m_switch_money.Checked())
     {
      if(m_lbl_risk.Text()=="Risk percent, %:")
        {
         m_lbl_risk.Text("Risk money: ("+m_account.Currency()+")");
         m_lbl_risk_money.Text("Risk percent, %:");
         ObjectSetString(m_chart_id,m_name+"m_risk",OBJPROP_TOOLTIP,"The money that will be lost (including commissions) when position's stoploss is hit, in account currency.");
         ObjectSetString(m_chart_id,m_name+"m_risk_money",OBJPROP_TOOLTIP,"Percent risk tolerance, in percentage points from 0 to 100.");
         string risk_money=m_risk_money.Text();
         StringReplace(risk_money,",","");
         int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
         m_risk.SetParameters(StringToDouble(risk_money),0.0,DBL_MAX,10,acc_digits);
         OnClickButtonCalculate();
        }
     }
   else
     {
      if(m_lbl_risk.Text()=="Risk money: ("+m_account.Currency()+")")
        {
         m_lbl_risk.Text("Risk percent, %:");
         m_lbl_risk_money.Text("Risk money: ("+m_account.Currency()+")");
         ObjectSetString(m_chart_id,m_name+"m_risk",OBJPROP_TOOLTIP,"Percent risk tolerance, in percentage points from 0 to 100.");
         ObjectSetString(m_chart_id,m_name+"m_risk_money",OBJPROP_TOOLTIP,"The money that will be lost (including commissions) when position's stoploss is hit, in account currency.");
         m_risk.SetParameters(StringToDouble(m_risk_money.Text()),0.0,100,0.1,2);
         OnClickButtonCalculate();
        }
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCalculate(void)
  {
   const string symbol=m_symbol.Select();
   const double sl_points=m_stoploss.Value();
   const double balance=StringToDouble(m_balance.Text());
   const double commission_lot=m_commission.Value(); //one-way commission
   const ENUM_ORDER_TYPE order_type=(ENUM_ORDER_TYPE)m_ordertype.Value();
   double risk_percent=m_risk.Value();
//---
   m_sym.RefreshRates();
   double risk_money=risk_percent/100.0*balance;
   double price=(order_type==ORDER_TYPE_BUY)?m_sym.Ask():m_sym.Bid();
   double price_sl=price-(order_type==ORDER_TYPE_BUY?1:-1)*sl_points*m_sym.Point();
   if(m_switch_money.Checked())
     {
      risk_money=risk_percent;
     }

//--- Position size calculation.
   double volume=OrderCalcVolume(order_type,symbol,risk_money,price,price_sl,commission_lot);

//--- Update risk money and margin after position size calculation.
   double margin=0.0;
   if(OrderCalcProfit(order_type,symbol,volume,price,price_sl,risk_money) && risk_money < 0)
     {
      risk_money=MathAbs(risk_money)+volume*2*commission_lot;
      risk_percent=risk_money/balance*100;
      margin=m_account.FreeMargin()-AccountFreeMarginCheck(order_type,symbol,volume,price);  // hedged_margin
     }
//---
   int acc_digits=(int)AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   m_position_size.Text(FormatDouble(volume,2));
   m_risk.Value(NormalizeDouble(risk_percent,2));
   m_risk_money.Text(FormatDouble(risk_money,acc_digits));
   m_margin.Text(FormatDouble(margin,acc_digits));
   m_margin.Color((margin<0)?clrRed:clrGreen);  // released margin is red
   if(m_switch_money.Checked())
     {
      m_risk.Value(NormalizeDouble(risk_money,acc_digits));
      m_risk_money.Text(FormatDouble(risk_percent,2));
     }
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
   if(!ExtDialog.Create(0,"Position Size Calculator v"+VERSION,0,100,100,374,550))
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

// https://www.myfxbook.com/en/forex-calculators/position-size
