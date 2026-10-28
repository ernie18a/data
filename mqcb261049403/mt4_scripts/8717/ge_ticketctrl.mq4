//+------------------------------------------------------------------+
//|  ge_ErrorMT4.mq4                                                 |
//| Copyright © 2008, ver 1.0                                        |
//| Forte928                                                         |
//+------------------------------------------------------------------+
#property copyright "Forte928"
#property link ""
//#property library

//#define		IndicatorPrefix "LR_MA"	

#define gnCount		"CE_Count"
#define gnTime			"CE_Time"
#define gnEmulate		"_Emulated"
#define gnCalculate	"_CW_"
#define gnPauseCount	"_PauseCount"

string	CWName			="";			// уникальное имя индикатора
extern	bool	cwEmulated		=false;	//	флаг разрешения реагирования на моделируемые тики
bool				cwCalculated	=false;
bool				cwChecked		=false;
datetime			cwTime			=0;

void InitTicket(string PrefixValueIndicator)
{
	MathSrand(TimeLocal());
	CWName=gnCalculate+PrefixValueIndicator+MathRand();
	Print(CWName);
	return;
}
bool StartTicket(int iShift)	//bool iEmulate)
{
	//cwEmulated		=iEmulate;	//
	cwCalculated	=false;
	cwChecked		=false;
	if ((GlobalVariableCheck(gnEmulate)==true)&&(cwEmulated==true))
	{
		//cwEmulated=GlobalVariableGet(cwEmulated);
		if (GlobalVariableCheck(CWName)==false) GlobalVariableSet(CWName,true);
		cwCalculated=GlobalVariableGet(CWName);
		if ((GlobalVariableCheck(gnTime)==true)&&(cwCalculated==false))
		{
			cwTime=GlobalVariableGet(gnTime);
			//Print(TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)," : Chart Tick ",TimeToStr(cwTime,TIME_DATE|TIME_SECONDS));
			if (iBarShift(NULL,0,cwTime,false)==iShift) 
			{
				cwCalculated=true;
				GlobalVariableSet(CWName,true);
			}
		}
		cwChecked=true;
	}
	return(cwChecked);
}
void ReadValueTicket(int& iShift,int& iCount)
{
	if (cwChecked==true)
	{
		iShift=iBarShift(NULL,0,cwTime,false);
		iCount=GlobalVariableGet(gnCount);
	}
	return;
}
void CalculateFinishedTicket()
{
	if ((cwChecked==true)&&(cwCalculated==false)) GlobalVariableSet(CWName,true);
	return;
}
void DoneTicket()
{
	if (GlobalVariableCheck(CWName)==true) GlobalVariableDel(CWName);	
	Print("Delete Global Variable");
	return;
}
//+------------------------------------------------------------------------------------------+