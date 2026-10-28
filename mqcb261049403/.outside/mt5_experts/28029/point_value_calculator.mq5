//+------------------------------------------------------------------+
//|                                       Point Value Calculator.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#define VERSION     "2.85"
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   VERSION
#property description "Calculate the money value of one point change for a trade."
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
   CLabel            m_lbl_pointsize;
   CLabel            m_lbl_ordertype;
   CLabel            m_lbl_lotsize;
   CLabel            m_lbl_pointvalue;
   CComboBox         m_symbol;                        // the dropdown list object
   CComboBox         m_ordertype;                     // the dropdown list object
   CSpinEditDouble   m_volume;                        // the display field object
   CEdit             m_currency;                      // the display field object
   CEdit             m_pointsize;                     // the display field object
   CEdit             m_pointvalue;                    // the display field object
   CEdit             m_lotsize;                       // the display field object
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
   bool              CreateControlPointSize(void);
   bool              CreateControlOrderType(void);
   bool              CreateControLotSize(void);
   bool              CreateControlCalculate(void);
   bool              CreateControlPointValue(void);
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
   if(!CreateControlPointSize())
      return(false);
   if(!CreateControlOrderType())
      return(false);
   if(!CreateControLotSize())
      return(false);
   if(!CreateControlCalculate())
      return(false);
   if(!CreateControlPointValue())
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
//| Create the "m_pointsize" edit                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlPointSize(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT+EDIT_HEIGHT+CONTROLS_GAP_Y*2);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_pointsize.Create(m_chart_id,m_name+"m_lbl_pointsize",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_pointsize.Text("Point size:"))
      return(false);
   if(!m_lbl_pointsize.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_pointsize))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_pointsize.Create(m_chart_id,m_name+"m_pointsize",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_pointsize.ReadOnly(true))
      return(false);
   if(!m_pointsize.Text(DoubleToString(m_sym.Point(),m_sym.Digits())))
      return(false);
   if(!m_pointsize.ColorBackground(clrGainsboro))
      return(false);
   if(!m_pointsize.FontSize(m_font_size))
      return(false);
   if(!Add(m_pointsize))
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
//| Create the "m_lotsize" edit                                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControLotSize(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(EDIT_WIDTH+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(LABEL_HEIGHT*2+EDIT_HEIGHT*2+CONTROLS_GAP_Y*4);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_lotsize.Create(m_chart_id,m_name+"m_lbl_lotsize",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_lotsize.Text("Units/lot:"))
      return(false);
   if(!m_lbl_lotsize.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_lotsize))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lotsize.Create(m_chart_id,m_name+"m_lotsize",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lotsize.ReadOnly(true))
      return(false);
   if(!m_lotsize.Text(FormatDouble(m_sym.ContractSize(),0)))
      return(false);
   if(!m_lotsize.ColorBackground(clrGainsboro))
      return(false);
   if(!m_lotsize.FontSize(m_font_size))
      return(false);
   if(!Add(m_lotsize))
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
//| Create the "m_pointvalue" edit                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateControlPointValue(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(LABEL_HEIGHT*4+EDIT_HEIGHT*3+BUTTON_HEIGHT+CONTROLS_GAP_Y*8);
   int x2=x1+EDIT_WIDTH;
   int y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_lbl_pointvalue.Create(m_chart_id,m_name+"m_lbl_pointvalue",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_lbl_pointvalue.Text("Point value: ("+m_account.Currency()+")"))
      return(false);
   if(!m_lbl_pointvalue.FontSize(m_font_size))
      return(false);
   if(!Add(m_lbl_pointvalue))
      return(false);

//--- coordinates
   y1=y1+(LABEL_HEIGHT+CONTROLS_GAP_Y);
   x2=x1+BUTTON_WIDTH;
   y2=y1+EDIT_HEIGHT;
//--- create
   if(!m_pointvalue.Create(m_chart_id,m_name+"m_pointvalue",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_pointvalue.ReadOnly(true))
      return(false);
   if(!m_pointvalue.TextAlign(ALIGN_CENTER))
      return(false);
   if(!m_pointvalue.Color(clrGreen))
      return(false);
   if(!m_pointvalue.Font("Arial Bold"))
      return(false);
   if(!m_pointvalue.FontSize(m_font_size+1))
      return(false);
   if(!ObjectSetString(m_chart_id,m_name+"m_pointvalue",OBJPROP_TOOLTIP,"The profit/loss for the trade, in account currency, per one point change in price."))
      return(false);
   if(!Add(m_pointvalue))
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
   m_pointsize.Text(DoubleToString(m_sym.Point(),m_sym.Digits()));
   m_lotsize.Text(FormatDouble(m_sym.ContractSize(),0));
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCalculate(void)
  {
   const string symbol=m_symbol.Select();
   const double volume=m_volume.Value();
   const long order_type=m_ordertype.Value();
//---
   double PointValue=mPointValue(symbol,(bool)order_type);
   double PointValueLots=PointValue*volume;
//---
   m_pointvalue.Text(DoubleToString(PointValueLots,5));
   m_pointvalue.Color((order_type>0)?clrRed:clrGreen);
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
   if(!ExtDialog.Create(0,"Point Value Calculator v"+VERSION,0,100,100,374,432))
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
