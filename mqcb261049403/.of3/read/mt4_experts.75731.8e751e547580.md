Calculation: daily account result = sum(profit + swap + commission for market trades closed since day start and all open market trades)
Exit: long, daily account result <= -daily loss limit
Exit: short, daily account result <= -daily loss limit
Exit: long, daily account result >= daily profit target
Exit: short, daily account result >= daily profit target