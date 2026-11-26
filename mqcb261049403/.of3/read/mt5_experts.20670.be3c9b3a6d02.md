Long: At bar close, indicator value on the previous bar > its value two bars ago AND its current value <= its value on the previous bar AND long-entry permission is enabled
Short: At bar close, indicator value on the previous bar < its value two bars ago AND its current value >= its value on the previous bar AND short-entry permission is enabled
Exit: short, At bar close, indicator value on the previous bar > its value two bars ago AND its current value <= its value on the previous bar AND short-exit permission is enabled AND long-entry permission is disabled
Exit: long, At bar close, indicator value on the previous bar < its value two bars ago AND its current value >= its value on the previous bar AND long-exit permission is enabled AND short-entry permission is disabled
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance