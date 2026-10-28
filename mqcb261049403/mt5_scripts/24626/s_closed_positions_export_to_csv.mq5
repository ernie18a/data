//+------------------------------------------------------------------+
//|                             s_Closed Positions Export to CSV.mq5 |
//|                                                 Fernando Morales |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Fernando Morales"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

input datetime 	deals_from 	= D'2010.10.01 00:00';		// Start Date
input datetime 	deals_to   	= D'2019.02.28 00:00';		// End date
input string 	FileName  	= "history_positions.csv";	// File name to export data

void OnStart() 
{
	Print("##### START SCRIPT ####");
//---
	
	if ( deals_from > deals_to ) 
	{
		Alert ("ERROR: The start date is earlier than the end date");
		return;
	}
	
	// Creamos el manejador del archivo del archivo de salida (WRITE)
	int file_handle= FileOpen(FileName,FILE_TXT|FILE_WRITE);
	
	// Mostramos error si hubo problema en crear el archivo
	if(file_handle == INVALID_HANDLE)
	{
		Alert("File open failed, error ",_LastError);
		return;
	}
	
	// Rescatamos info del histórico
	if ( HistorySelect( deals_from, deals_to ))
	{
		// Enviamos al archivo el nombre de las columnas
		FileWrite(file_handle, "Position ID\tType\tSymbol\tVolume\tOpen Date/Time\tOpen Price\tClose Date/Time\tClose Price\tTakeProfit\tStopLoss\tPosition PnL\tSwap\tCommission\tTotal PnL\tMagicNumber\tComment\tDeal in ID\tDeal out ID");

		ulong deal_out_ticket=-1;
		ulong deal_in_ticket=-1;
		int deals_cnt=0;
		
		// Cargamos los históricos de DEALs
		int deals_total = HistoryDealsTotal();
		
		// Ciclamos por todos los DEALs del histórico rescatado
		for( int i = deals_total; i >= 0; i-- )
			
			// Seleccionamos por los DEAL por su ticket y filtramos por aquellos que son DEAL_ENTRY_OUT
			if( (deal_out_ticket=HistoryDealGetTicket( i )) > 0 && HistoryDealGetInteger(deal_out_ticket, DEAL_ENTRY)==DEAL_ENTRY_OUT ) 
	        {
				deals_cnt++;
				ulong  _posID=HistoryDealGetInteger(deal_out_ticket,DEAL_POSITION_ID);

				long	deal_order      = HistoryDealGetInteger(deal_out_ticket, DEAL_ORDER);
				long	close_time      = HistoryDealGetInteger(deal_out_ticket, DEAL_TIME);
				long	_magic     	 	= HistoryDealGetInteger(deal_out_ticket, DEAL_MAGIC);
				long	deal_type       = HistoryDealGetInteger(deal_out_ticket, DEAL_TYPE);
				double	close_price		= HistoryDealGetDouble (deal_out_ticket, DEAL_PRICE);
				double	deal_volume     = HistoryDealGetDouble (deal_out_ticket, DEAL_VOLUME);
				double	_commission 	= HistoryDealGetDouble (deal_out_ticket, DEAL_COMMISSION);
				double	_swap       	= HistoryDealGetDouble (deal_out_ticket, DEAL_SWAP);
				double	_profit     	= HistoryDealGetDouble (deal_out_ticket, DEAL_PROFIT);
				string	_symbol    	 	= HistoryDealGetString (deal_out_ticket, DEAL_SYMBOL);
				string	_comment		= HistoryDealGetString (deal_out_ticket, DEAL_COMMENT)+"/";
				
				double	open_price=-1;
				long	open_time=-1;
				long 	_direction=-1;
				double	_tp	= -1;
				double	_sl	= -1;
				
				// Buscamos los DEALs que tienen el mismo POSITION_IDENTIFIER y son diferentes de ENTRY_OUT
				for( int j = 0; j <= deals_total; j++ )
				{
					if(( deal_in_ticket=HistoryDealGetTicket( j )) > 0 && 
						 HistoryDealGetInteger(deal_in_ticket,DEAL_POSITION_ID) == _posID && 
						 HistoryDealGetInteger(deal_in_ticket,DEAL_ENTRY)!=DEAL_ENTRY_OUT ) 
			        {
			        	_commission += HistoryDealGetDouble (deal_in_ticket, DEAL_COMMISSION);
						_swap       += HistoryDealGetDouble (deal_in_ticket, DEAL_SWAP);
						_profit		+= HistoryDealGetDouble (deal_in_ticket, DEAL_PROFIT);
						open_price	 = HistoryDealGetDouble (deal_in_ticket, DEAL_PRICE);
						open_time	 = HistoryDealGetInteger(deal_in_ticket, DEAL_TIME);
						_direction	 = HistoryDealGetInteger(deal_in_ticket, DEAL_TYPE);
						_comment	+= HistoryDealGetString (deal_in_ticket, DEAL_COMMENT);
					}
				}
			
				// Rescatamos datos de Tp y SL de la ORDER de salida
				if ( HistoryOrderSelect(deal_order))
				{
					HistoryOrderGetDouble( deal_order, ORDER_TP, _tp );
					HistoryOrderGetDouble( deal_order, ORDER_SL, _sl );
				}
				
				// Vamos a reemplazar los puntos (.) en la fecha por guiones (-) para que Excel la reconozca automáticamente
				string _closetime = TimeToString(close_time);
				StringReplace( _closetime, ".", "-");
				
				string _opentime  = TimeToString(open_time);  
				StringReplace( _opentime,  ".", "-");
				
				// Preparamos la cadena de texto con los datos a exportar
				string data = StringFormat("%u\t%s\t%s\t%g\t%s\t%g\t%s\t%g\t%g\t%g\t%.2f\t%.2f\t%.2f\t%.2f\t%u\t%s\t%u\t%u",
							_posID, GetDealDescription(int(_direction)), _symbol, deal_volume, _opentime, 
							open_price, _closetime, close_price, _tp, _sl, _profit, _swap, _commission, _profit+_swap+_commission,
							_magic, _comment, deal_in_ticket, deal_out_ticket);
							
				// Escribimos en el archivo de salida
				FileWrite( file_handle,data);
     
	        }//end if deal_ticket
		printf("Processed %d deals", deals_cnt );
	}
	
	FileClose(file_handle);
	
	


//---  
	Print("##### END SCRIPT ####");
}

//+------------------------------------------------------------------+
//|  devuelve la descripción literal de la transacción               |
//+------------------------------------------------------------------+
string GetDealDescription(int deal_type)
{
	string descr;

	switch(deal_type)
	{
		case DEAL_TYPE_BALANCE:                  return ("balance");
		case DEAL_TYPE_CREDIT:                   return ("credito");
		case DEAL_TYPE_CHARGE:                   return ("cargo");
		case DEAL_TYPE_CORRECTION:               return ("correccion");
		case DEAL_TYPE_BUY:                      return ("buy");
		case DEAL_TYPE_SELL:                     return ("sell");
		case DEAL_TYPE_BONUS:                    return ("bono");
		case DEAL_TYPE_COMMISSION:               return ("comision adicional");
		case DEAL_TYPE_COMMISSION_DAILY:         return ("comision diaria");
		case DEAL_TYPE_COMMISSION_MONTHLY:       return ("comision mensual");
		case DEAL_TYPE_COMMISSION_AGENT_DAILY:   return ("comision diaria del agente");
		case DEAL_TYPE_COMMISSION_AGENT_MONTHLY: return ("comision mensual del agente");
		case DEAL_TYPE_INTEREST:                 return ("tasa de interes");
		case DEAL_TYPE_BUY_CANCELED:             return ("buy cancelado");
		case DEAL_TYPE_SELL_CANCELED:            return ("sell cancelado");
	}
	
	return(descr);
}