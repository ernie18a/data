<!-- tradingview-pine-id: PUB;bb61809e310241f3841760c98874b910 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# [Kpt-Ahab] Savings Plan IND

Source: https://www.tradingview.com/script/wIcaya2Q/

## Description

[Kpt-Ahab] Savings Plan Indicator

This indicator simulates and documents a complete savings plan directly on the TradingView chart. Deposits, dividends, purchases, sales, and costs are processed through a shared savings-plan account, making the cash balance and cash flow transparent and traceable.

Features:

- Initial capital with first purchase
- Regular deposits with optional periodic increases
- Fractional or whole units
- Automatic use of available cash when the regular DCA budget is insufficient to purchase the minimum tradable quantity
- Chart warning when a DCA purchase cannot be executed
- Four manual or adaptive DIP-buy levels
- Automatic profiles: Defensive, Balanced, and Aggressive
- Manual or automatic profit taking with trailing and cash rebalancing
- Minimum price increase required between two TP sales
- Transactions at the confirmed bar close or at the bar open
- Dividend processing
- Transaction, broker, custody, and dividend costs
- TradingView alerts for DCA, DIP, and TP events
- Detailed purchase and sale labels
- Marking of the highest profit point and the largest portfolio drawdown
- Full statistics table or compact mobile view
- Tables, labels, and alert messages in English, German, or French

The statistics include, among other values, deposits, cash balance, units held, cost basis, market value, portfolio value, realized and unrealized results, total costs, drawdowns, cumulative return, and the annualized return (XIRR).

Mobile Table

A reduced mobile view can be enabled for smaller screens. It displays the most important portfolio, return, drawdown, cost, and transaction information using shorter labels and smaller text.

Transaction and Alert Notes

With "Confirmed close", signals are triggered only after the bar has been confirmed at its closing price. On daily charts, the exchange may already be closed by the time the signal becomes available.

With "Bar open", the evaluation is performed at the opening price of the new bar. The Auto model uses only confirmed data from the previous bar. The opening price of the new bar is not necessarily identical to the previous closing price, for example when a price gap occurs.

The indicator does not place real orders. Automatic settings and historical results do not guarantee future performance and do not constitute investment advice.

---

## Source Code

````pine
// © Kpt-Ahab
// [Kpt-Ahab] Savings Plan Indicator v2.1

//@version=6
indicator(
     "[Kpt-Ahab] Savings Plan IND",
     overlay = true,
     max_labels_count = 500)

// ---------------------------------------------------
// Groups
// ---------------------------------------------------
string groupLanguage = "Language"
string groupPlan = "Savings Plan"
string groupDividends = "Dividends"
string groupProfit = "Profit Taking"
string groupDip = "Dip Buys"
string groupSizing = "Order Sizing"
string groupDisplay = "Display"
string groupAutomation = "Automation"
string groupCosts = "Costs"
string groupAlerts = "Alerts"

// ---------------------------------------------------
// Tooltip Constants
// ---------------------------------------------------
const string TT_LANGUAGE = "EN: Selects the language used in the statistics table.\nDE: Wählt die Sprache der Statistiktabelle.\nFR: Sélectionne la langue du tableau de statistiques."
const string TT_PLAN_START = "EN: First date from which the savings-plan accounting may start. The actual start is the first eligible chart bar on or after this date.\nDE: Erstes Datum, ab dem die Sparplanbuchhaltung starten darf. Der tatsächliche Start ist die erste zulässige Chartkerze an oder nach diesem Datum.\nFR: Première date à partir de laquelle la comptabilité du plan peut démarrer. Le départ réel est la première bougie admissible à cette date ou après."
const string TT_INITIAL_CAPITAL = "EN: External cash credited to the savings account at the plan start and immediately allocated to the first purchase. The purchase budget includes enabled transaction costs. The actual debit depends on the selected quantity mode; any remainder stays in or is reserved inside the account.\nDE: Externes Geld, das beim Planstart zuerst dem Sparplankonto gutgeschrieben und unmittelbar dem ersten Kauf zugeteilt wird. Das Kaufbudget schließt aktivierte Transaktionskosten ein. Die tatsächliche Belastung hängt vom Mengenmodus ab; ein Rest bleibt im Konto oder wird dort reserviert.\nFR: Apport externe crédité au compte au démarrage puis immédiatement affecté au premier achat. Le budget inclut les frais de transaction activés. Le débit réel dépend du mode de quantité; le reliquat reste sur le compte ou y est réservé."
const string TT_REGULAR_DEPOSIT = "EN: Regular cash contribution. The first regular deposit occurs only after the selected interval has elapsed from the actual plan start. No earlier deposits are backfilled.\nDE: Regelmäßige Einzahlung. Die erste Einzahlung erfolgt erst nach Ablauf des gewählten Intervalls ab dem tatsächlichen Planstart. Frühere Einzahlungen werden nicht nachgebucht.\nFR: Versement régulier. Le premier versement n'a lieu qu'après l'intervalle choisi à compter du démarrage réel du plan. Aucun versement antérieur n'est rattrapé."
const string TT_DIRECT_BUY = "EN: Normal account allocation from each regular deposit for the immediate savings-plan purchase, including enabled transaction costs. In whole-unit modes, if this allocation cannot buy the minimum quantity, available savings-account cash tops it up only as far as required for one minimum unit. If the complete account cash is still insufficient, no purchase is booked and the money remains in the account.\nDE: Reguläre Kontozuteilung aus jeder Einzahlung für den unmittelbaren Sparplankauf einschließlich aktivierter Transaktionskosten. Reicht diese Zuteilung in einem Ganzanteilsmodus nicht für die Mindestmenge, wird sie mit verfügbarem Cash aus dem Sparplankonto nur bis zum erforderlichen Betrag für eine Mindestmenge aufgestockt. Reicht auch das gesamte Kontoguthaben nicht aus, wird kein Kauf verbucht und das Geld bleibt im Konto.\nFR: Allocation normale de chaque versement pour l’achat immédiat, frais de transaction inclus. Dans les modes en unités entières, si cette allocation ne permet pas d’acheter la quantité minimale, les liquidités disponibles du compte la complètent uniquement jusqu’au montant requis pour une quantité minimale. Si le solde total reste insuffisant, aucun achat n’est comptabilisé et l’argent reste sur le compte."
const string TT_INCREASE_YEARS = "EN: After each completed period, the regular deposit and direct purchase increase from the next scheduled deposit onward.\nDE: Nach jedem vollständig abgelaufenen Zeitraum erhöhen sich Einzahlung und Direktkauf ab der nächsten fälligen Einzahlung.\nFR: Après chaque période complète, le versement régulier et l'achat direct augmentent à partir du versement suivant."
const string TT_DEPOSIT_INCREASE = "EN: Amount added to the regular deposit after each completed increase period.\nDE: Betrag, um den die regelmäßige Einzahlung nach jedem abgeschlossenen Erhöhungszeitraum steigt.\nFR: Montant ajouté au versement régulier après chaque période d'augmentation complète."
const string TT_DIRECT_INCREASE = "EN: Amount added to the direct purchase after each completed increase period. It is always capped by the corresponding regular deposit.\nDE: Betrag, um den der Direktkauf nach jedem abgeschlossenen Erhöhungszeitraum steigt. Er wird immer auf die zugehörige Einzahlung begrenzt.\nFR: Montant ajouté à l'achat direct après chaque période d'augmentation complète. Il est toujours plafonné au versement correspondant."
const string TT_DEPOSIT_INTERVAL = "EN: Number of calendar days between regular deposits.\nDE: Anzahl Kalendertage zwischen den regelmäßigen Einzahlungen.\nFR: Nombre de jours calendaires entre les versements réguliers."
const string TT_EXECUTION = "EN: Fractional units uses virtual fractions. Whole units - remainder to savings leaves unused purchase cash freely available. Whole units - carry to next purchase reserves the unused purchase allocation and retries it at the next scheduled savings-plan purchase. In both whole-unit modes, free savings-account cash can complete an otherwise too-small scheduled DCA allocation up to one minimum tradable quantity.\nDE: Bruchanteile verwenden virtuelle Teilstücke. Ganze Anteile - Rest ins Konto lässt nicht verwendetes Kaufgeld frei verfügbar. Ganze Anteile - Übertrag reserviert die nicht verwendete Kaufzuteilung und versucht sie beim nächsten planmäßigen Sparplankauf erneut. In beiden Ganzanteilsmodi kann freies Cash aus dem Sparplankonto eine sonst zu kleine planmäßige DCA-Zuteilung bis zu einer handelbaren Mindestmenge ergänzen.\nFR: Fractions d’unités utilise des fractions virtuelles. Unités entières - reliquat au compte laisse le solde libre. Unités entières - report réserve l’allocation inutilisée et la réessaie lors du prochain achat programmé. Dans les deux modes en unités entières, les liquidités libres du compte peuvent compléter une allocation DCA insuffisante jusqu’à une quantité minimale négociable."
const string TT_DCA_CASH_WARNING = "EN: Shows one persistent warning on the latest chart bar after a scheduled initial or regular DCA purchase cannot buy the minimum tradable quantity. The script first tries to complete the scheduled allocation with free savings-account cash. If the complete account cash remains insufficient, no debit is made and the cash continues to accumulate. The warning remains visible until a later DCA purchase executes.\nDE: Zeigt einen dauerhaften Hinweis an der letzten Chartkerze, sobald ein geplanter Erst- oder regulärer DCA-Kauf die handelbare Mindestmenge nicht kaufen kann. Das Skript versucht zuerst, die planmäßige Zuteilung mit freiem Cash aus dem Sparplankonto zu ergänzen. Reicht auch das gesamte Kontoguthaben nicht aus, erfolgt keine Belastung und das Cash wird weiter angesammelt. Der Hinweis bleibt sichtbar, bis später wieder ein DCA-Kauf ausgeführt wird.\nFR: Affiche un avertissement persistant sur la dernière bougie lorsqu’un achat initial ou DCA programmé ne peut pas acheter la quantité minimale négociable. Le script tente d’abord de compléter l’allocation avec les liquidités libres du compte. Si le solde total reste insuffisant, aucun débit n’est effectué et les liquidités continuent de s’accumuler. L’avertissement reste visible jusqu’à une exécution DCA ultérieure."
const string TT_TIMEFRAME = "EN: When enabled, account transactions are processed only on daily and weekly charts.\nDE: Wenn aktiviert, werden Kontotransaktionen nur in Tages- und Wochencharts verarbeitet.\nFR: Si activé, les transactions du compte ne sont traitées que sur les graphiques journaliers et hebdomadaires."
const string TT_DIVIDENDS = "EN: Off disables dividend processing. Savings account credits the gross dividend less any enabled dividend costs as free cash. Next savings-plan buy reserves that net dividend for the next regular purchase. If no dividend data exists, the savings-plan logic stays unchanged.\nDE: Aus deaktiviert die Dividendenverarbeitung. Dem Sparplankonto wird die Bruttodividende abzüglich aktivierter Dividendenkosten als freies Cash gutgeschrieben. Nächster Sparplankauf reserviert diese Nettodividende für den nächsten regulären Kauf. Fehlen Dividendendaten, bleibt die Sparplanlogik unverändert.\nFR: Désactivé coupe le traitement. Le compte reçoit le dividende brut moins les frais activés. Prochain achat réserve ce dividende net pour le prochain achat régulier."
const string TT_PROFIT_MODE = "EN: Off = no sales. Trailing = sells a fixed position percentage after a trailing pullback. Regular portfolio rebalancing checks the cash ratio at fixed intervals. Cash-ratio rebalancing reacts when cash falls below its trigger. Cash-ratio at trailing trigger uses the trailing trigger for timing and then sells only enough to reach the target cash ratio. All sale proceeds go to the savings account.\nDE: Aus = keine Verkäufe. Trailing = verkauft nach einem Trailing-Rücksetzer einen festen Positionsanteil. Regelmäßiges Portfolio-Rebalancing prüft die Cashquote in festen Intervallen. Cashquote-Rebalancing reagiert bei Unterschreitung des Triggers. Cashquote am Trailing-Trigger nutzt den Trailing-Trigger als Zeitpunkt und verkauft nur so viel, bis die Ziel-Cashquote erreicht ist. Alle Verkaufserlöse gehen auf das Sparplankonto.\nFR: Désactivé = aucune vente. Trailing = vend une part fixe de la position après un repli du trailing. Le rééquilibrage régulier contrôle la part de liquidités à intervalles fixes. Le rééquilibrage par liquidités réagit sous son seuil. Liquidités au déclencheur trailing utilise le trailing pour le timing puis vend uniquement ce qui est nécessaire pour atteindre la part cible de liquidités. Tous les produits de vente vont au compte d'épargne."
const string TT_TRAILING_ACTIVATION = "EN: Arms the trailing logic once the selected transaction price is at least this percentage above the current average purchase price.\nDE: Aktiviert die Trailing-Logik, sobald der gewählte Transaktionskurs mindestens diesen Prozentsatz über dem aktuellen durchschnittlichen Einkaufspreis liegt.\nFR: Active le trailing lorsque le prix de transaction sélectionné dépasse le prix d'achat moyen actuel de ce pourcentage."
const string TT_TRAILING_DISTANCE = "EN: After activation, the highest selected transaction price is tracked. A decline by this percentage triggers the trailing event.\nDE: Nach Aktivierung wird der höchste gewählte Transaktionskurs verfolgt. Ein Rückgang um diesen Prozentsatz löst das Trailing-Ereignis aus.\nFR: Après activation, le prix de transaction sélectionné le plus élevé est suivi. Une baisse de ce pourcentage déclenche le trailing."
const string TT_TRAILING_SELL = "EN: Position percentage sold by the pure Trailing mode when its trailing trigger fires.\nDE: Positionsanteil, der im reinen Trailing-Modus beim Trailing-Trigger verkauft wird.\nFR: Pourcentage de la position vendu par le mode Trailing lorsque son déclencheur se produit."
const string TT_TP_REARM_RISE = "EN: After an actual profit-taking sale, no further profit-taking rule can arm or execute until the selected transaction price has risen by at least this percentage above the last TP execution price. Once that level has been reached, the rule remains unlocked during the following pullback so a new trailing TP can trigger. The filter applies to Manual and Auto and to every profit-taking mode. A value of 0 disables it. A complete liquidation resets the reference so a future position starts a new TP cycle.\nDE: Nach einer tatsächlich ausgeführten Gewinnmitnahme kann keine Gewinnmitnahme-Regel erneut aktiviert oder ausgeführt werden, bis der gewählte Transaktionskurs mindestens um diesen Prozentsatz über den Ausführungskurs des letzten TP gestiegen ist. Sobald dieses Niveau einmal erreicht wurde, bleibt die Regel während des anschließenden Rücksetzers freigegeben, sodass ein neuer Trailing-TP auslösen kann. Der Filter gilt für Manuell und Auto sowie für alle Gewinnmitnahme-Modi. Der Wert 0 deaktiviert ihn. Bei einer vollständigen Veräußerung wird die Referenz zurückgesetzt, sodass eine spätere Position einen neuen TP-Zyklus beginnt.\nFR: Après une prise de bénéfices réellement exécutée, aucune nouvelle règle de prise de bénéfices ne peut être armée ou exécutée tant que le prix de transaction sélectionné n’a pas progressé d’au moins ce pourcentage au-dessus du prix d’exécution du dernier TP. Une fois ce niveau atteint, la règle reste déverrouillée pendant le repli suivant afin qu’un nouveau TP trailing puisse se déclencher. Le filtre s’applique aux modes Manuel et Auto et à tous les modes de prise de bénéfices. La valeur 0 le désactive. Une liquidation complète réinitialise la référence afin qu’une position future commence un nouveau cycle TP."
const string TT_REBALANCE_INTERVAL = "EN: Used only by regular portfolio rebalancing. The first check occurs after this many months from the actual plan start.\nDE: Nur für regelmäßiges Portfolio-Rebalancing. Die erste Prüfung erfolgt nach dieser Anzahl Monate ab dem tatsächlichen Planstart.\nFR: Utilisé uniquement par le rééquilibrage régulier. Le premier contrôle intervient après ce nombre de mois depuis le démarrage réel du plan."
const string TT_REGULAR_TARGET = "EN: At each regular rebalance check, a profitable position is partially sold until this target cash ratio is reached.\nDE: Bei jeder regelmäßigen Rebalancing-Prüfung wird eine profitable Position teilweise verkauft, bis diese Ziel-Cashquote erreicht ist.\nFR: À chaque contrôle régulier, une position profitable est partiellement vendue jusqu'à atteindre cette part cible de liquidités."
const string TT_CASH_TRIGGER = "EN: Used only by cash-ratio rebalancing. Falling below this cash ratio can trigger a partial sale.\nDE: Nur für Cashquote-Rebalancing. Das Unterschreiten dieser Cashquote kann einen Teilverkauf auslösen.\nFR: Utilisé uniquement par le rééquilibrage par liquidités. Un passage sous ce seuil peut déclencher une vente partielle."
const string TT_CASH_TARGET = "EN: Target cash ratio after cash-ratio rebalancing. In the trailing-trigger cash-ratio mode, this is the cash target reached when the trailing event fires.\nDE: Ziel-Cashquote nach dem Cashquote-Rebalancing. Im Cashquote-am-Trailing-Trigger-Modus ist dies die Cashquote, die beim Trailing-Ereignis angestrebt wird.\nFR: Part cible de liquidités après rééquilibrage. Dans le mode liquidités au déclencheur trailing, il s'agit de la cible atteinte lorsque le trailing se déclenche."
const string TT_DIP_ENABLE = "EN: Each enabled drawdown level can trigger once per drawdown cycle. All levels reset after a new high in the selected transaction-price series.\nDE: Jede aktivierte Drawdown-Stufe kann pro Drawdown-Zyklus einmal auslösen. Nach einem neuen Hoch der gewählten Transaktionskursreihe werden alle Stufen zurückgesetzt.\nFR: Chaque niveau peut se déclencher une fois par cycle. Tous les niveaux sont réinitialisés après un nouveau plus haut du prix de transaction sélectionné."
const string TT_DIP_MODE = "EN: Selects which level-specific order-size field is used. Equity applies that level's percentage to the currently unreserved savings-account cash. Cash uses that level's fixed account amount. Levels are processed from 1 to 4 and purchases never exceed unreserved cash. If several levels execute on the same bar, all Equity percentages use the same cash balance available before those dip buys.\nDE: Wählt, welches levelbezogene Feld für die Ordergröße verwendet wird. Equity wendet den Prozentsatz der jeweiligen Stufe auf das aktuell nicht reservierte Sparplankonto an. Cash verwendet den festen Kontobetrag der jeweiligen Stufe. Die Stufen werden von 1 bis 4 verarbeitet und Käufe überschreiten niemals das nicht reservierte Cash. Werden mehrere Stufen auf derselben Kerze ausgeführt, verwenden alle Equity-Prozentsätze denselben vor diesen Dip-Käufen verfügbaren Cashbestand.\nFR: Sélectionne le champ de taille propre à chaque niveau. Equity applique le pourcentage du niveau aux liquidités actuellement non réservées. Cash utilise le montant fixe du niveau. Les niveaux sont traités de 1 à 4 et les achats ne dépassent jamais les liquidités non réservées. Si plusieurs niveaux sont exécutés sur la même bougie, tous les pourcentages Equity utilisent le même solde disponible avant ces achats."
const string TT_DIP_THRESHOLD = "EN: Sets this level's drawdown threshold from the latest high in the selected transaction-price series. A value of 0 disables the level. Each level can execute once per cycle and is marked as used only after an actual quantity is purchased.\nDE: Legt die Drawdown-Schwelle dieser Stufe ab dem letzten Hoch der gewählten Transaktionskursreihe fest. Der Wert 0 deaktiviert die Stufe. Jede Stufe kann pro Zyklus einmal ausgeführt werden und gilt erst nach einem tatsächlichen Anteilskauf als verwendet.\nFR: Définit le seuil depuis le dernier plus haut du prix de transaction sélectionné. La valeur 0 désactive le niveau. Chaque niveau peut être exécuté une fois par cycle et n'est utilisé qu'après un achat réel."
const string TT_DIP_LEVEL_SIZE = "EN: Equity (%) uses this percentage of the currently unreserved savings-account cash. Cash uses this fixed account budget. Enabled transaction costs are included in that budget, so the purchased notional is reduced enough to keep the complete debit within it. Only the selected size field is applied. If several manual Equity levels execute on the same bar, they use the same pre-dip cash base; Auto levels use the remaining free cash sequentially.\nDE: Equity (%) verwendet diesen Prozentsatz des aktuell nicht reservierten Sparplankontos. Cash verwendet dieses feste Kontobudget. Aktivierte Transaktionskosten sind in diesem Budget enthalten; der gekaufte Handelswert wird so reduziert, dass die vollständige Kontobelastung innerhalb des Budgets bleibt. Ausgeführt wird nur das gewählte Größenfeld. Mehrere manuelle Equity-Stufen verwenden auf derselben Kerze denselben Cashbestand vor den Dip-Käufen; Auto-Stufen verwenden nacheinander das verbleibende freie Cash.\nFR: Equity (%) utilise ce pourcentage des liquidités non réservées. Cash définit un budget de compte fixe. Les frais de transaction activés sont inclus dans ce budget. Plusieurs niveaux Equity manuels utilisent la même base initiale; les niveaux Auto utilisent successivement les liquidités restantes."
const string TT_PROFITABLE_POINT = "EN: Marks the confirmed bar with the highest total profit. Total profit equals portfolio value minus all external deposits, so a new deposit cannot create a false profit record. The label also shows the portfolio value.\nDE: Markiert die bestätigte Kerze mit dem höchsten Gesamtgewinn. Der Gesamtgewinn entspricht dem Portfoliowert abzüglich aller externen Einzahlungen, sodass eine neue Einzahlung keinen falschen Gewinnrekord erzeugt. Das Label zeigt zusätzlich den Portfoliowert.\nFR: Marque la bougie confirmée présentant le gain total le plus élevé. Le gain total correspond à la valeur du portefeuille moins tous les apports externes; un nouvel apport ne peut donc pas créer un faux record. Le label affiche aussi la valeur du portefeuille."
const string TT_MAX_PORTFOLIO_DRAWDOWN = "EN: Marks the confirmed bar with the largest drawdown of the cash-flow-adjusted portfolio performance index from its prior peak. External deposits are removed from the bar return, so deposits do not count as gains or hide losses. The label shows the actual portfolio value, total profit and return on deposits at the drawdown point.\nDE: Markiert die bestätigte Kerze mit dem größten Drawdown des um externe Geldflüsse bereinigten Portfolio-Performance-Index gegenüber seinem vorherigen Hoch. Externe Einzahlungen werden aus der Balkenrendite herausgerechnet und zählen daher weder als Gewinn noch verdecken sie Verluste. Das Label zeigt am Drawdown-Punkt den tatsächlichen Portfoliowert, den Gesamtgewinn und die Rendite auf Einzahlungen.\nFR: Marque la bougie confirmée présentant le plus grand drawdown de l'indice de performance du portefeuille corrigé des flux externes. Les apports externes sont retirés du rendement de la bougie et ne comptent donc ni comme gains ni comme masque des pertes. Le label affiche la valeur réelle du portefeuille, le gain total et le rendement sur apports au point de drawdown."
const string TT_DCA_TRANSACTION_LABEL = "EN: Shows detailed labels for the initial purchase and regular DCA purchases, including purchased units and the savings-account debit.\nDE: Zeigt detaillierte Labels für den Erstkauf und reguläre DCA-Käufe einschließlich gekaufter Anteile und Kontobelastung.\nFR: Affiche des labels détaillés pour l'achat initial et les achats DCA réguliers, avec les unités achetées et le débit du compte."
const string TT_DIP_TRANSACTION_LABEL = "EN: Shows detailed dip-buy labels with purchased units, account debit and the executed drawdown levels.\nDE: Zeigt detaillierte Dip-Kauflabels mit gekauften Anteilen, Kontobelastung und den ausgeführten Drawdown-Stufen.\nFR: Affiche des labels détaillés pour les achats sur baisse, avec les unités, le débit du compte et les niveaux exécutés."
const string TT_TP_TRANSACTION_LABEL = "EN: Shows detailed profit-taking labels with sold units, account credit, sold cost basis and realized profit or loss.\nDE: Zeigt detaillierte TP-Labels mit verkauften Anteilen, Kontogutschrift, verkaufter Kostenbasis und realisiertem Gewinn oder Verlust.\nFR: Affiche des labels détaillés de prise de bénéfices avec les unités vendues, le crédit du compte, le prix de revient vendu et le résultat réalisé."
const string TT_QTY_STEP = "EN: Quantity step used for virtual fractional accounting. Whole-unit modes additionally respect syminfo.mincontract.\nDE: Mengenschritt für die virtuelle Bruchanteils-Buchhaltung. Modi mit ganzen Anteilen berücksichtigen zusätzlich syminfo.mincontract.\nFR: Pas de quantité utilisé pour la comptabilité des fractions virtuelles. Les modes en unités entières respectent aussi syminfo.mincontract."
const string TT_POINT_VALUE = "EN: Uses TradingView's symbol point value when enabled. Disable to use the custom point value below.\nDE: Verwendet bei Aktivierung den TradingView-Punktwert des Symbols. Deaktivieren, um den eigenen Punktwert darunter zu verwenden.\nFR: Utilise la valeur du point du symbole TradingView si activé. Désactiver pour utiliser la valeur personnalisée ci-dessous."

const string TT_TRANSACTION_TIMING = "EN: Confirmed close preserves the existing behavior and processes transactions on the closing update. Bar open processes once at the first update of each chart bar using its opening price, so signals are available at that bar’s open. On a weekly chart this means the weekly open. The Auto model still learns only from confirmed closes; in Bar open mode it uses the previous confirmed bar to avoid future leakage.\nDE: Bestätigter Schlusskurs behält das bisherige Verhalten bei und verarbeitet Transaktionen beim Kerzenschluss. Kerzeneröffnung verarbeitet einmal beim ersten Update jeder Chartkerze zum Eröffnungskurs, sodass Signale zu diesem Kerzenbeginn verfügbar sind. Im Wochenchart ist damit die Wocheneröffnung gemeint. Das Auto-Modell lernt weiterhin nur aus bestätigten Schlusskursen und verwendet im Open-Modus ausschließlich die vorherige bestätigte Kerze, um Zukunftsdaten auszuschließen.\nFR: Clôture confirmée conserve le comportement actuel. Ouverture traite une fois au premier update de chaque bougie du graphique avec son prix d’ouverture; sur un graphique hebdomadaire, il s’agit de l’ouverture de la semaine. Le modèle Auto apprend uniquement sur des clôtures confirmées et utilise la bougie précédente en mode ouverture."
const string TT_TRANSACTION_COST = "EN: Percentage charged on the gross value of every purchase and sale. It can represent commission, order fees, stamp or transaction taxes and an estimated slippage allowance. Buy costs are included in the position cost basis; sell costs reduce the account credit and realized profit. Purchase budgets include these costs.\nDE: Prozentsatz auf den Bruttowert jedes Kaufs und Verkaufs. Er kann Courtage, Ordergebühren, Stempel- oder Transaktionssteuern sowie einen geschätzten Slippage-Aufschlag abbilden. Kaufkosten werden in die Kostenbasis aufgenommen; Verkaufskosten reduzieren Kontogutschrift und realisierten Gewinn. Kaufbudgets schließen diese Kosten ein.\nFR: Pourcentage appliqué à la valeur brute de chaque achat et vente. Il peut représenter courtage, frais d’ordre, taxes de transaction et slippage estimé. Les frais d’achat entrent dans le prix de revient; les frais de vente réduisent le crédit et le gain réalisé."
const string TT_BROKER_COST = "EN: Recurring broker or custody cost charged after each selected interval as a percentage of the net portfolio value (cash plus securities minus unpaid broker costs) at the selected transaction price. Existing unpaid costs are paid before purchases. If cash is insufficient, the unpaid amount remains as a liability, reduces portfolio value and is paid from later cash inflows. Broker costs have priority over internal purchase reservations; if necessary, reserved dividend cash and then purchase carry cash are reduced to the remaining account cash.\nDE: Regelmäßige Broker- oder Depotkosten nach jedem gewählten Intervall als Prozentsatz des Netto-Portfoliowerts (Cash plus Wertpapiere minus offene Brokerkosten) zum gewählten Transaktionskurs. Bereits offene Kosten werden vor Käufen bezahlt. Reicht das Cash nicht aus, bleibt der Rest als Verbindlichkeit bestehen, reduziert den Portfoliowert und wird aus späteren Geldeingängen bezahlt. Brokerkosten haben Vorrang vor internen Kaufreservierungen; falls nötig, werden zuerst reserviertes Dividendencash und danach der Kaufübertrag auf das verbleibende Kontoguthaben reduziert.\nFR: Frais récurrents de courtage ou de garde, prélevés après chaque intervalle en pourcentage de la valeur nette du portefeuille. Les frais impayés sont réglés avant les achats; le solde impayé reste une dette qui réduit la valeur du portefeuille. Ces frais ont priorité sur les réserves internes; si nécessaire, la réserve de dividendes puis le report d’achat sont réduits au solde disponible."
const string TT_DIVIDEND_COST = "EN: Percentage deducted from every gross dividend before it is credited to the savings account. It can represent withholding tax, distribution fees or other dividend-related deductions. Only the net dividend is available for purchases and contributes to cash.\nDE: Prozentsatz, der von jeder Bruttodividende abgezogen wird, bevor sie dem Sparplankonto gutgeschrieben wird. Er kann Quellensteuer, Ausschüttungsgebühren oder andere dividendenbezogene Abzüge darstellen. Nur die Nettodividende steht für Käufe und als Cash zur Verfügung.\nFR: Pourcentage déduit de chaque dividende brut avant crédit sur le compte. Il peut représenter retenue à la source, frais de distribution ou autres déductions. Seul le dividende net est disponible."

const string TT_DCA_ALERT = "EN: Enables detailed alert() events for the initial purchase and every executed regular DCA purchase. A separate DCA alert condition is also available in TradingView's Create Alert dialog.\nDE: Aktiviert detaillierte alert()-Ereignisse für den Erstkauf und jeden ausgeführten regulären DCA-Kauf. Zusätzlich steht im TradingView-Dialog Alarm erstellen eine eigene DCA-Alarmbedingung zur Verfügung.\nFR: Active les événements alert() détaillés pour le premier achat et chaque achat DCA exécuté. Une condition d'alerte DCA distincte est également disponible dans la boîte de dialogue Créer une alerte."
const string TT_DIP_ALERT = "EN: Enables detailed alert() events whenever one or more dip levels execute an actual purchase. A separate DIP alert condition is also available in TradingView's Create Alert dialog.\nDE: Aktiviert detaillierte alert()-Ereignisse, sobald eine oder mehrere Dip-Stufen einen tatsächlichen Kauf ausführen. Zusätzlich steht im TradingView-Dialog Alarm erstellen eine eigene DIP-Alarmbedingung zur Verfügung.\nFR: Active les événements alert() détaillés lorsqu'un ou plusieurs niveaux de baisse exécutent un achat réel. Une condition d'alerte DIP distincte est également disponible dans la boîte de dialogue Créer une alerte."
const string TT_TP_ALERT = "EN: Enables detailed alert() events whenever a profit-taking sale is actually executed. A separate TP alert condition is also available in TradingView's Create Alert dialog.\nDE: Aktiviert detaillierte alert()-Ereignisse, sobald ein Gewinnmitnahme-Verkauf tatsächlich ausgeführt wird. Zusätzlich steht im TradingView-Dialog Alarm erstellen eine eigene TP-Alarmbedingung zur Verfügung.\nFR: Active les événements alert() détaillés lorsqu'une vente de prise de bénéfices est réellement exécutée. Une condition d'alerte TP distincte est également disponible dans la boîte de dialogue Créer une alerte."
const string TT_MOBILE_TABLE = "EN: Reduces the statistics table to the most important 19 metrics plus the header, uses compact language-specific abbreviations and smaller text for mobile screens. Calculations and hidden outputs remain unchanged.\nDE: Reduziert die Statistiktabelle auf die 19 wichtigsten Kennzahlen plus Kopfzeile, verwendet sprachabhängige Abkürzungen und kleinere Schrift für Mobilgeräte. Berechnungen und ausgeblendete Ausgaben bleiben unverändert.\nFR: Réduit le tableau aux 19 indicateurs essentiels plus l'en-tête, utilise des abréviations adaptées à la langue et un texte plus petit pour les écrans mobiles. Les calculs et sorties masquées restent inchangés."

const string TT_AUTO_MODE = "EN: Manual preserves the existing inputs. Auto learns only from completed closing-high drawdown cycles and combines recent drawdown and recovery statistics with trend, volatility and movement speed. Confirmed-close mode applies the model on the confirmed bar; Bar-open mode applies it at the next bar open using only the previous confirmed close data. Automatic dip percentages use the remaining unreserved cash at each triggered level, so a price gap across several levels can still distribute cash among the deeper levels. Dip and profit-taking automation can be enabled independently.\nDE: Manuell verwendet die bisherigen Eingaben. Auto lernt ausschließlich aus abgeschlossenen Drawdown-Zyklen zwischen Schlusshochs und kombiniert Drawdown- und Erholungsstatistiken mit Trend, Volatilität und Bewegungsgeschwindigkeit. Im Schlusskursmodus wird das Modell auf der bestätigten Kerze angewendet; im Open-Modus am nächsten Kerzenbeginn ausschließlich mit Daten der vorherigen bestätigten Schlusskerze. Automatische Dip-Prozentsätze beziehen sich bei jeder ausgelösten Stufe auf das dann noch verbleibende unreservierte Cash, sodass auch ein Kurssprung über mehrere Levels Cash auf die tieferen Stufen verteilen kann. Dip- und Gewinnmitnahme-Automatik können unabhängig aktiviert werden.\nFR: Manuel conserve les entrées existantes. Auto apprend uniquement à partir de cycles clôturés et combine drawdowns, reprises, tendance, volatilité et vitesse. En mode clôture, le modèle est appliqué sur la bougie confirmée; en mode ouverture, il est appliqué à l’ouverture suivante avec uniquement les données confirmées précédentes. Les pourcentages automatiques utilisent les liquidités non réservées restantes à chaque niveau. Les deux automatismes peuvent être activés séparément."
const string TT_AUTO_PROFILE = "EN: Defensive uses at least 20% of remaining free cash at Level 1 and 55% at Level 4. Balanced uses at least 30% and 72%. Aggressive uses at least 50% and 85%; learning can raise deep-level sizing to 100%. Defensive keeps more cash and uses the closest profit-taking trail, while Aggressive deploys cash faster and allows a wider trail. Asset-specific thresholds and effective sizes remain adaptive.\nDE: Defensiv verwendet an Level 1 mindestens 20% und an Level 4 mindestens 55% des jeweils verbleibenden freien Cash. Ausgewogen verwendet mindestens 30% und 72%. Aggressiv verwendet mindestens 50% und 85%; das Learning kann tiefe Stufen bis auf 100% erhöhen. Defensiv hält mehr Cash und verwendet den engsten Gewinnmitnahme-Trailing-Abstand, Aggressiv setzt Cash schneller ein und lässt einen weiteren Abstand zu. Assetspezifische Schwellen und wirksame Größen bleiben adaptiv.\nFR: Défensif utilise au moins 20% des liquidités libres restantes au niveau 1 et 55% au niveau 4. Équilibré utilise au moins 30% et 72%. Agressif utilise au moins 50% et 85%; l’apprentissage peut porter les niveaux profonds à 100%. Défensif conserve davantage de liquidités et utilise le trailing le plus proche, tandis qu’Agressif déploie les liquidités plus vite avec un trailing plus large. Les seuils et tailles effectifs restent adaptatifs."
const string TT_AUTO_WINDOW = "EN: Maximum number of the most recent completed market cycles retained by the adaptive model. Older cycles are removed, so structural changes can gradually replace older behavior.\nDE: Maximale Anzahl der zuletzt abgeschlossenen Marktzyklen im adaptiven Modell. Ältere Zyklen werden entfernt, damit strukturelle Veränderungen das frühere Verhalten schrittweise ersetzen können.\nFR: Nombre maximal de cycles récents conservés par le modèle adaptatif."
const string TT_AUTO_MIN_CYCLES = "EN: Number of completed cycles required for full statistical confidence. Before this count is reached, learned percentiles are blended with ATR-based fallback parameters. The effective value is capped by Learning cycles.\nDE: Anzahl abgeschlossener Zyklen für vollständiges statistisches Vertrauen. Bis dahin werden gelernte Perzentile mit ATR-basierten Rückfallwerten gemischt. Der wirksame Wert wird auf Learning cycles begrenzt.\nFR: Nombre de cycles terminés requis pour une confiance statistique complète. Avant cela, les percentiles appris sont mélangés à des valeurs de repli basées sur l’ATR."
const string TT_AUTO_MIN_DRAWDOWN = "EN: Completed cycles with a smaller maximum drawdown are ignored by the learning sample. This filters ordinary market noise while the current ATR fallback remains available.\nDE: Abgeschlossene Zyklen mit einem kleineren maximalen Drawdown werden nicht in die Lernstichprobe aufgenommen. Dadurch wird gewöhnliches Marktrauschen gefiltert; der aktuelle ATR-Rückfallwert bleibt verfügbar.\nFR: Les cycles dont le drawdown maximal est inférieur à cette valeur sont ignorés par l’échantillon d’apprentissage."

// ---------------------------------------------------
// Language Input
// ---------------------------------------------------
string languageInput = input.string(
     "English",
     "Language",
     options = ["English", "German", "French"],
     tooltip = TT_LANGUAGE,
     group = groupLanguage)

// ---------------------------------------------------
// Savings Plan Inputs
// ---------------------------------------------------
int planStartInput = input.time(
     timestamp("01 Jan 2010 00:00 +0000"),
     "Plan start",
     tooltip = TT_PLAN_START,
     group = groupPlan)

float initialCapitalInput = input.float(
     1000.0,
     "Initial capital / first purchase",
     minval = 0.0,
     step = 100.0,
     tooltip = TT_INITIAL_CAPITAL,
     group = groupPlan)

float regularDepositInput = input.float(
     200.0,
     "Regular deposit",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_REGULAR_DEPOSIT,
     group = groupPlan)

float regularDirectBuyInput = input.float(
     150.0,
     "Direct purchase from deposit",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIRECT_BUY,
     group = groupPlan)

int depositIntervalDaysInput = input.int(
     30,
     "Deposit every N days",
     minval = 1,
     maxval = 3650,
     tooltip = TT_DEPOSIT_INTERVAL,
     group = groupPlan)

float regularDepositIncreaseInput = input.float(
     100.0,
     "Regular deposit increase",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DEPOSIT_INCREASE,
     group = groupPlan)

float directBuyIncreaseInput = input.float(
     100.0,
     "Direct purchase increase",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIRECT_INCREASE,
     group = groupPlan)

int increaseEveryYearsInput = input.int(
     5,
     "Increase every N years",
     minval = 1,
     maxval = 100,
     tooltip = TT_INCREASE_YEARS,
     group = groupPlan)

string executionModeInput = input.string(
     "Fractional units",
     "Purchase execution",
     options = ["Fractional units", "Whole units - remainder to savings", "Whole units - carry to next purchase"],
     tooltip = TT_EXECUTION,
     group = groupPlan)

string transactionTimingInput = input.string(
     "Bar open",
     "Transaction timing",
     options = ["Confirmed close", "Bar open"],
     tooltip = TT_TRANSACTION_TIMING,
     group = groupPlan)

bool restrictTimeframeInput = input.bool(
     true,
     "Restrict transactions to daily/weekly charts",
     tooltip = TT_TIMEFRAME,
     group = groupPlan)



// ---------------------------------------------------
// Dividend Inputs
// ---------------------------------------------------
string dividendHandlingInput = input.string(
     "Next savings-plan buy",
     "Dividend handling",
     options = ["Off", "Savings account", "Next savings-plan buy"],
     tooltip = TT_DIVIDENDS,
     group = groupDividends)

// ---------------------------------------------------
// Cost Inputs
// ---------------------------------------------------
bool enableTransactionCostsInput = input.bool(
     false,
     "Enable transaction costs",
     tooltip = TT_TRANSACTION_COST,
     group = groupCosts)

float transactionCostPctInput = input.float(
     0.25,
     "Cost per trade (%)",
     minval = 0.0,
     maxval = 99.0,
     step = 0.01,
     tooltip = TT_TRANSACTION_COST,
     active = enableTransactionCostsInput,
     group = groupCosts)

bool enableBrokerCostsInput = input.bool(
     false,
     "Enable recurring broker costs",
     tooltip = TT_BROKER_COST,
     group = groupCosts)

string brokerCostIntervalInput = input.string(
     "Yearly",
     "Broker cost interval",
     options = ["Monthly", "Quarterly", "Yearly"],
     tooltip = TT_BROKER_COST,
     active = enableBrokerCostsInput,
     group = groupCosts,
     inline = "BROKER_COST")

float brokerCostPctInput = input.float(
     0.20,
     "Cost per interval (%)",
     minval = 0.0,
     maxval = 99.0,
     step = 0.01,
     tooltip = TT_BROKER_COST,
     active = enableBrokerCostsInput,
     group = groupCosts,
     inline = "BROKER_COST")

bool enableDividendCostsInput = input.bool(
     false,
     "Enable dividend costs",
     tooltip = TT_DIVIDEND_COST,
     group = groupCosts)

float dividendCostPctInput = input.float(
     35.0,
     "Gross dividend cost (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     tooltip = TT_DIVIDEND_COST,
     active = enableDividendCostsInput,
     group = groupCosts)

// ---------------------------------------------------
// Alert Inputs
// ---------------------------------------------------
bool enableDcaAlertsInput = input.bool(
     true,
     "DCA alerts",
     tooltip = TT_DCA_ALERT,
     group = groupAlerts)

bool enableDipAlertsInput = input.bool(
     true,
     "DIP alerts",
     tooltip = TT_DIP_ALERT,
     group = groupAlerts)

bool enableTpAlertsInput = input.bool(
     true,
     "TP alerts",
     tooltip = TT_TP_ALERT,
     group = groupAlerts)

// ---------------------------------------------------
// Automation Inputs
// ---------------------------------------------------
string dipParameterModeInput = input.string(
     "Manual",
     "Dip parameters",
     options = ["Manual", "Auto"],
     tooltip = TT_AUTO_MODE,
     group = groupAutomation,
     inline = "AUTO_MODE")

string profitParameterModeInput = input.string(
     "Manual",
     "Profit taking",
     options = ["Manual", "Auto"],
     tooltip = TT_AUTO_MODE,
     group = groupAutomation,
     inline = "AUTO_MODE")

bool useAutoDipInput = dipParameterModeInput == "Auto"
bool useAutoProfitInput = profitParameterModeInput == "Auto"
bool automationActiveInput = useAutoDipInput or useAutoProfitInput

string autoProfileInput = input.string(
     "Balanced",
     "Auto profile",
     options = ["Defensive", "Balanced", "Aggressive"],
     tooltip = TT_AUTO_PROFILE,
     active = automationActiveInput,
     group = groupAutomation)

int autoLearningCyclesInput = input.int(
     16,
     "Learning cycles",
     minval = 4,
     maxval = 50,
     tooltip = TT_AUTO_WINDOW,
     active = automationActiveInput,
     group = groupAutomation)

int autoMinimumCyclesInput = input.int(
     6,
     "Minimum completed cycles",
     minval = 1,
     maxval = 50,
     tooltip = TT_AUTO_MIN_CYCLES,
     active = automationActiveInput,
     group = groupAutomation)

float autoMinimumLearningDrawdownInput = input.float(
     4.0,
     "Minimum learning drawdown (%)",
     minval = 0.5,
     maxval = 30.0,
     step = 0.5,
     tooltip = TT_AUTO_MIN_DRAWDOWN,
     active = automationActiveInput,
     group = groupAutomation)

// ---------------------------------------------------
// Profit Taking Inputs
// ---------------------------------------------------
bool manualProfitInputsActive = not useAutoProfitInput

string profitTakingModeInput = input.string(
     "Off",
     "Profit-taking mode",
     options = ["Off", "Trailing", "Regular portfolio rebalancing", "Cash-ratio rebalancing", "Trailing cash-ratio rebalancing"],
     tooltip = TT_PROFIT_MODE,
     active = manualProfitInputsActive,
     group = groupProfit)

bool profitTakingRearmInputActive = useAutoProfitInput or profitTakingModeInput != "Off"

float minimumRiseAfterProfitTakePctInput = input.float(
     20.0,
     "Minimum rise after last TP (%)",
     minval = 0.0,
     maxval = 1000.0,
     step = 0.5,
     tooltip = TT_TP_REARM_RISE,
     active = profitTakingRearmInputActive,
     group = groupProfit)

bool trailingSettingsActiveInput =
     manualProfitInputsActive and
     (profitTakingModeInput == "Trailing" or profitTakingModeInput == "Trailing cash-ratio rebalancing")
bool trailingSellActiveInput = manualProfitInputsActive and profitTakingModeInput == "Trailing"
bool regularRebalanceSettingsActiveInput = manualProfitInputsActive and profitTakingModeInput == "Regular portfolio rebalancing"
bool cashRatioTriggerActiveInput = manualProfitInputsActive and profitTakingModeInput == "Cash-ratio rebalancing"
bool cashRatioTargetActiveInput =
     manualProfitInputsActive and
     (profitTakingModeInput == "Cash-ratio rebalancing" or profitTakingModeInput == "Trailing cash-ratio rebalancing")

float trailingActivationPctInput = input.float(
     50.0,
     "Trailing activation profit (%)",
     minval = 0.0,
     maxval = 1000.0,
     step = 1.0,
     tooltip = TT_TRAILING_ACTIVATION,
     active = trailingSettingsActiveInput,
     group = groupProfit)

float trailingDistancePctInput = input.float(
     3.0,
     "Trailing distance from high (%)",
     minval = 0.1,
     maxval = 90.0,
     step = 0.5,
     tooltip = TT_TRAILING_DISTANCE,
     active = trailingSettingsActiveInput,
     group = groupProfit)

float trailingSellPctInput = input.float(
     20.0,
     "Trailing sell position (%)",
     minval = 0.1,
     maxval = 100.0,
     step = 1.0,
     tooltip = TT_TRAILING_SELL,
     active = trailingSellActiveInput,
     group = groupProfit)

int regularRebalanceMonthsInput = input.int(
     12,
     "Rebalancing every N months",
     minval = 1,
     maxval = 1200,
     tooltip = TT_REBALANCE_INTERVAL,
     active = regularRebalanceSettingsActiveInput,
     group = groupProfit)

float regularRebalanceTargetCashPctInput = input.float(
     15.0,
     "Regular rebalancing target cash (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     tooltip = TT_REGULAR_TARGET,
     active = regularRebalanceSettingsActiveInput,
     group = groupProfit)

float cashRatioTriggerPctInput = input.float(
     10.0,
     "Cash-ratio trigger (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     tooltip = TT_CASH_TRIGGER,
     active = cashRatioTriggerActiveInput,
     group = groupProfit)

float cashRatioTargetPctInput = input.float(
     30.0,
     "Cash-ratio target (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     tooltip = TT_CASH_TARGET,
     active = cashRatioTargetActiveInput,
     group = groupProfit)

// ---------------------------------------------------
// Dip Buy Inputs
// ---------------------------------------------------
bool enableDipBuysInput = input.bool(
     true,
     "Drawdown dip buys /",
     tooltip = TT_DIP_ENABLE,
     group = groupDip,
     inline = "DIP_MODE")

bool manualDipSettingsActiveInput = enableDipBuysInput and not useAutoDipInput

string dipSizeModeInput = input.string(
     "Equity",
     "Size mode",
     options = ["Equity", "Cash"],
     tooltip = TT_DIP_MODE,
     active = manualDipSettingsActiveInput,
     group = groupDip,
     inline = "DIP_MODE")

bool dipEquitySizingActiveInput =
     manualDipSettingsActiveInput and
     dipSizeModeInput == "Equity"
bool dipCashSizingActiveInput =
     manualDipSettingsActiveInput and
     dipSizeModeInput == "Cash"

float drawdownLevel1Input = input.float(
     10.0,
     "Level 1 (%)",
     minval = 0.0,
     maxval = 90.0,
     step = 0.5,
     tooltip = TT_DIP_THRESHOLD,
     active = manualDipSettingsActiveInput,
     group = groupDip)

float dipEquityPctLevel1Input = input.float(
     50.0,
     "Equity (%)    ",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     active = dipEquitySizingActiveInput,
     group = groupDip,
     inline = "DIP_L1_SIZE")

float dipCashLevel1Input = input.float(
     500.0,
     "Cash",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIP_LEVEL_SIZE,
     active = dipCashSizingActiveInput,
     group = groupDip,
     inline = "DIP_L1_SIZE")

float drawdownLevel2Input = input.float(
     20.0,
     "Level 2 (%)",
     minval = 0.0,
     maxval = 90.0,
     step = 0.5,
     tooltip = TT_DIP_THRESHOLD,
     active = manualDipSettingsActiveInput,
     group = groupDip)

float dipEquityPctLevel2Input = input.float(
     50.0,
     "Equity (%)    ",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     active = dipEquitySizingActiveInput,
     group = groupDip,
     inline = "DIP_L2_SIZE")

float dipCashLevel2Input = input.float(
     500.0,
     "Cash",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIP_LEVEL_SIZE,
     active = dipCashSizingActiveInput,
     group = groupDip,
     inline = "DIP_L2_SIZE")

float drawdownLevel3Input = input.float(
     30.0,
     "Level 3 (%)",
     minval = 0.0,
     maxval = 90.0,
     step = 0.5,
     tooltip = TT_DIP_THRESHOLD,
     active = manualDipSettingsActiveInput,
     group = groupDip)

float dipEquityPctLevel3Input = input.float(
     50.0,
     "Equity (%)    ",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     active = dipEquitySizingActiveInput,
     group = groupDip,
     inline = "DIP_L3_SIZE")

float dipCashLevel3Input = input.float(
     500.0,
     "Cash",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIP_LEVEL_SIZE,
     active = dipCashSizingActiveInput,
     group = groupDip,
     inline = "DIP_L3_SIZE")

float drawdownLevel4Input = input.float(
     40.0,
     "Level 4 (%)",
     minval = 0.0,
     maxval = 90.0,
     step = 0.5,
     tooltip = TT_DIP_THRESHOLD,
     active = manualDipSettingsActiveInput,
     group = groupDip)

float dipEquityPctLevel4Input = input.float(
     50.0,
     "Equity (%)    ",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     active = dipEquitySizingActiveInput,
     group = groupDip,
     inline = "DIP_L4_SIZE")

float dipCashLevel4Input = input.float(
     500.0,
     "Cash",
     minval = 0.0,
     step = 10.0,
     tooltip = TT_DIP_LEVEL_SIZE,
     active = dipCashSizingActiveInput,
     group = groupDip,
     inline = "DIP_L4_SIZE")

// ---------------------------------------------------
// Order Sizing Inputs
// ---------------------------------------------------
float quantityStepInput = input.float(
     0.000001,
     "Virtual quantity step",
     minval = 0.000001,
     step = 0.000001,
     tooltip = TT_QTY_STEP,
     group = groupSizing)

bool useSymbolPointValueInput = input.bool(
     true,
     "Use symbol point value",
     tooltip = TT_POINT_VALUE,
     group = groupSizing)

float customPointValueInput = input.float(
     1.0,
     "Custom point value",
     minval = 0.000001,
     step = 0.1,
     tooltip = "EN: Custom monetary value of one price point per unit when symbol point value is disabled.\nDE: Eigener Geldwert eines Kurspunktes je Einheit, wenn der Symbol-Punktwert deaktiviert ist.\nFR: Valeur monétaire personnalisée d’un point de prix par unité lorsque la valeur du point du symbole est désactivée.",
     active = not useSymbolPointValueInput,
     group = groupSizing)

// ---------------------------------------------------
// Display Inputs
// ---------------------------------------------------
bool effectiveProfitTakingEnabledInput = useAutoProfitInput or profitTakingModeInput != "Off"

bool showPlanSignalsInput = input.bool(true, "Show savings-plan buys", group = groupDisplay)
bool showDipSignalsInput = input.bool(true, "Show dip buys", active = enableDipBuysInput, group = groupDisplay)
bool showProfitTakingSignalsInput = input.bool(
     true,
     "Show profit taking",
     active = effectiveProfitTakingEnabledInput,
     group = groupDisplay)
bool showDcaPurchaseLabelsInput = input.bool(
     false,
     "Show DCA buy labels",
     tooltip = TT_DCA_TRANSACTION_LABEL,
     group = groupDisplay)
bool showInsufficientDcaCashWarningInput = input.bool(
     true,
     "Show DCA cash warning",
     tooltip = TT_DCA_CASH_WARNING,
     group = groupDisplay)
bool showDipPurchaseLabelsInput = input.bool(
     false,
     "Show dip buy labels",
     tooltip = TT_DIP_TRANSACTION_LABEL,
     active = enableDipBuysInput,
     group = groupDisplay)
bool showTpLabelsInput = input.bool(
     false,
     "Show TP labels",
     tooltip = TT_TP_TRANSACTION_LABEL,
     active = effectiveProfitTakingEnabledInput,
     group = groupDisplay)
bool transactionLabelsEnabledInput =
     showDcaPurchaseLabelsInput or
     (enableDipBuysInput and showDipPurchaseLabelsInput) or
     (effectiveProfitTakingEnabledInput and showTpLabelsInput)
int transactionLabelLimitInput = input.int(
     100,
     "Transaction labels to keep",
     minval = 10,
     maxval = 496,
     active = transactionLabelsEnabledInput,
     group = groupDisplay)
bool showMostProfitablePointInput = input.bool(
     true,
     "Show most profitable point",
     tooltip = TT_PROFITABLE_POINT,
     group = groupDisplay)
bool showMaximumPortfolioDrawdownInput = input.bool(
     true,
     "Show maximum portfolio drawdown",
     tooltip = TT_MAX_PORTFOLIO_DRAWDOWN,
     group = groupDisplay)
bool showAveragePriceInput = input.bool(true, "Show average purchase price", group = groupDisplay)
bool showTableInput = input.bool(true, "Show statistics table", group = groupDisplay)
bool mobileTableModeInput = input.bool(
     false,
     "Mobile table mode",
     tooltip = TT_MOBILE_TABLE,
     active = showTableInput,
     group = groupDisplay)

string tablePositionInput = input.string(
     "Top right",
     "Table position",
     options = ["Top right", "Top left", "Middle right", "Middle left", "Bottom right", "Bottom left"],
     group = groupDisplay)

// ---------------------------------------------------
// Constants and Storage
// ---------------------------------------------------
const int millisecondsPerDay = 24 * 60 * 60 * 1000
const float millisecondsPerYear = 365.2425 * millisecondsPerDay

varip array<int> contributionTimes = array.new_int()
varip array<float> contributionAmounts = array.new_float()
var array<label> transactionLabels = array.new_label()
var label mostProfitablePointLabel = na
var label maximumPortfolioDrawdownLabel = na
var label insufficientDcaCashLabel = na

varip array<float> autoDrawdownSamples = array.new_float()
varip array<float> autoRecoverySamples = array.new_float()
varip array<float> autoDeclineSpeedSamples = array.new_float()
varip array<float> autoRecoverySpeedSamples = array.new_float()

varip float autoLearningPeak = na
varip int autoLearningPeakBar = na
varip float autoLearningTrough = na
varip int autoLearningTroughBar = na
varip float autoLearningMaximumDrawdownPct = 0.0

varip float autoLearnedDrawdownQ25 = na
varip float autoLearnedDrawdownQ50 = na
varip float autoLearnedDrawdownQ75 = na
varip float autoLearnedDrawdownQ90 = na
varip float autoLearnedRecoveryQ70 = na
varip float autoLearnedDeclineSpeedMedian = na
varip float autoLearnedRecoverySpeedMedian = na

varip float autoCycleDrawdownLevel1 = na
varip float autoCycleDrawdownLevel2 = na
varip float autoCycleDrawdownLevel3 = na
varip float autoCycleDrawdownLevel4 = na
varip float autoCycleAllocationLevel1Pct = na
varip float autoCycleAllocationLevel2Pct = na
varip float autoCycleAllocationLevel3Pct = na
varip float autoCycleAllocationLevel4Pct = na

varip float armedTrailingDistancePct = na
varip float armedCashRatioTargetPct = na
varip float armedAutoMaximumSellPct = na
varip float armedAutoWeaknessMultiplier = na

// ---------------------------------------------------
// Functions
// ---------------------------------------------------
f_roundDownToStep(float value, float step) =>
    step > 0.0 ? math.floor(value / step + 1e-10) * step : value

f_cashToQty(float cashAmount, float contractValue, float step) =>
    contractValue > 0.0 and cashAmount > 0.0 ? f_roundDownToStep(cashAmount / contractValue, step) : 0.0

f_buyBudgetToQty(float accountBudget, float contractValue, float step, float transactionCostRate) =>
    float unitAccountDebit = contractValue * (1.0 + transactionCostRate)
    unitAccountDebit > 0.0 and accountBudget > 0.0 ? f_roundDownToStep(accountBudget / unitAccountDebit, step) : 0.0

f_targetGrossSaleValue(float currentNetCash, float portfolioValue, float targetCashPct, float transactionCostRate) =>
    float targetRatio = math.max(0.0, math.min(targetCashPct / 100.0, 1.0))
    float cashShortfall = math.max(portfolioValue * targetRatio - currentNetCash, 0.0)
    float denominator = math.max(1.0 - transactionCostRate * (1.0 - targetRatio), 0.000001)
    cashShortfall / denominator

f_money(float value) =>
    str.tostring(value, "#,##0.00") + " " + syminfo.currency

f_signedMoney(float value) =>
    (value > 0.0 ? "+" : "") + f_money(value)

f_signedPercent(float value) =>
    (value > 0.0 ? "+" : "") + str.tostring(value, "#,##0.00") + "%"

f_percent(float value) =>
    str.tostring(value, "#,##0.00") + "%"

f_quantity(float value) =>
    str.tostring(value, "#,##0.######")

f_text(string englishText, string germanText, string frenchText) =>
    languageInput == "English" ? englishText : languageInput == "French" ? frenchText : germanText

f_runtime(int totalDays) =>
    int years = int(math.floor(float(totalDays) / 365.2425))
    int remainingAfterYears = totalDays - int(math.floor(years * 365.2425))
    int months = int(math.floor(float(remainingAfterYears) / 30.436875))
    int days = remainingAfterYears - int(math.floor(months * 30.436875))
    string yearUnit = f_text("Y", "J", "A")
    string monthUnit = "M"
    string dayUnit = f_text("D", "T", "J")
    str.tostring(years) + yearUnit + " " + str.tostring(months) + monthUnit + " " + str.tostring(days) + dayUnit

f_storeTransactionLabel(label newLabel, array<label> labels, int limit) =>
    array.push(labels, newLabel)
    if array.size(labels) > limit
        label.delete(array.shift(labels))
    array.size(labels)

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(value, maximum))

f_pushLimited(array<float> values, float value, int limit) =>
    array.push(values, value)
    if array.size(values) > limit
        array.shift(values)
    array.size(values)

f_percentile(array<float> values, float percentile) =>
    float result = na
    int count = array.size(values)

    if count > 0
        array<float> sortedValues = array.copy(values)
        array.sort(sortedValues, order.ascending)
        float constrainedPercentile = f_clamp(percentile, 0.0, 100.0)
        float rank = constrainedPercentile / 100.0 * (count - 1)
        int lowerIndex = int(math.floor(rank))
        int upperIndex = int(math.ceil(rank))
        float weight = rank - lowerIndex
        float lowerValue = array.get(sortedValues, lowerIndex)
        float upperValue = array.get(sortedValues, upperIndex)
        result := lowerValue + (upperValue - lowerValue) * weight

    result

f_futureValueDifference(float annualRate, int valuationTime, float finalPortfolioValue) =>
    float difference = finalPortfolioValue
    int flowCount = array.size(contributionTimes)

    if flowCount > 0
        for flowIndex = 0 to flowCount - 1
            int flowTime = array.get(contributionTimes, flowIndex)
            float flowAmount = array.get(contributionAmounts, flowIndex)
            float elapsedYears = math.max(float(valuationTime - flowTime) / millisecondsPerYear, 0.0)
            difference -= flowAmount * math.pow(1.0 + annualRate, elapsedYears)

    difference

f_moneyWeightedAnnualReturn(int valuationTime, float finalPortfolioValue) =>
    float result = na
    int flowCount = array.size(contributionTimes)
    int earliestFlowTime = flowCount > 0 ? array.get(contributionTimes, 0) : na
    bool sufficientTimeElapsed = not na(earliestFlowTime) and valuationTime - earliestFlowTime >= millisecondsPerDay

    if flowCount > 0 and finalPortfolioValue > 0.0 and sufficientTimeElapsed
        float lowRate = -0.9999
        float highRate = 10.0
        float lowDifference = f_futureValueDifference(lowRate, valuationTime, finalPortfolioValue)
        float highDifference = f_futureValueDifference(highRate, valuationTime, finalPortfolioValue)
        int expansionCount = 0

        while highDifference > 0.0 and expansionCount < 8
            highRate *= 2.0
            highDifference := f_futureValueDifference(highRate, valuationTime, finalPortfolioValue)
            expansionCount += 1

        float functionTolerance = math.max(math.abs(finalPortfolioValue), 1.0) * 1e-12
        bool rateChangesEquation = math.abs(lowDifference - highDifference) > functionTolerance

        if rateChangesEquation and lowDifference >= 0.0 and highDifference <= 0.0
            for iteration = 0 to 59
                float middleRate = (lowRate + highRate) * 0.5
                float middleDifference = f_futureValueDifference(middleRate, valuationTime, finalPortfolioValue)

                if middleDifference > 0.0
                    lowRate := middleRate
                else
                    highRate := middleRate

            result := (lowRate + highRate) * 0.5

    result

// ---------------------------------------------------
// Market Calculations
// ---------------------------------------------------
int depositIntervalMs = depositIntervalDaysInput * millisecondsPerDay
int increaseIntervalMs = int(math.round(float(increaseEveryYearsInput) * millisecondsPerYear))
int regularRebalanceIntervalMs = int(math.round(float(regularRebalanceMonthsInput) * 30.436875 * millisecondsPerDay))
int effectiveAutoMinimumCycles = math.max(math.min(autoMinimumCyclesInput, autoLearningCyclesInput), 1)

bool useBarOpenTransactions = transactionTimingInput == "Bar open"
bool transactionProcessingEvent = useBarOpenTransactions ? barstate.isnew : barstate.isconfirmed
float transactionPrice = useBarOpenTransactions ? open : close
int transactionTime = useBarOpenTransactions ? time : time_close

bool supportedTimeframe = timeframe.isdaily or timeframe.isweekly
bool timeframeAllowed = not restrictTimeframeInput or supportedTimeframe
bool dateReached = not na(transactionTime) and transactionTime >= planStartInput

float transactionCostRate = enableTransactionCostsInput ? transactionCostPctInput / 100.0 : 0.0
float dividendCostRate = enableDividendCostsInput ? dividendCostPctInput / 100.0 : 0.0
float brokerCostRate = enableBrokerCostsInput ? brokerCostPctInput / 100.0 : 0.0
int brokerCostIntervalMonths = brokerCostIntervalInput == "Monthly" ? 1 : brokerCostIntervalInput == "Quarterly" ? 3 : 12
int brokerCostIntervalMs = int(math.round(float(brokerCostIntervalMonths) * 30.436875 * millisecondsPerDay))

float selectedPointValue = useSymbolPointValueInput ? syminfo.pointvalue : customPointValueInput
float pointValue = math.max(nz(selectedPointValue, 1.0), 0.000001)
float contractValue = transactionPrice * pointValue
float valuationContractValue = close * pointValue
float symbolMinimumQty = math.max(nz(syminfo.mincontract, quantityStepInput), 0.000001)
float virtualQuantityStep = math.max(quantityStepInput, 0.000001)
bool useFractionalExecution = executionModeInput == "Fractional units"
bool carryDirectBuyRemainder = executionModeInput == "Whole units - carry to next purchase"
float accountingQuantityStep = useFractionalExecution ? virtualQuantityStep : math.max(virtualQuantityStep, symbolMinimumQty)
float minimumPlanOrderDebit = accountingQuantityStep * contractValue * (1.0 + transactionCostRate)

// ---------------------------------------------------
// Automatic Market Learning
// ---------------------------------------------------
// Auto learning remains close-based. In Bar open mode, all model inputs are
// shifted to the previous confirmed bar, while the current open may still be
// compared with those confirmed trend references. This avoids future leakage.
float autoAtrValueRaw = ta.atr(14)
float autoAtrPctRaw = close > 0.0 ? autoAtrValueRaw / close * 100.0 : na
float autoAtrBaselinePctRaw = ta.ema(autoAtrPctRaw, 100)
float autoFastEmaRaw = ta.ema(close, 50)
float autoSlowEmaRaw = ta.ema(close, 200)
float autoRoc20PctRaw = ta.roc(close, 20)

float autoAtrPct = useBarOpenTransactions ? autoAtrPctRaw[1] : autoAtrPctRaw
float autoAtrBaselinePct = useBarOpenTransactions ? autoAtrBaselinePctRaw[1] : autoAtrBaselinePctRaw
float autoFastEma = useBarOpenTransactions ? autoFastEmaRaw[1] : autoFastEmaRaw
float autoSlowEma = useBarOpenTransactions ? autoSlowEmaRaw[1] : autoSlowEmaRaw
float autoSlowEmaPast = useBarOpenTransactions ? autoSlowEmaRaw[21] : autoSlowEmaRaw[20]
float autoRoc20Pct = useBarOpenTransactions ? autoRoc20PctRaw[1] : autoRoc20PctRaw
float autoLearningPrice = useBarOpenTransactions ? close[1] : close
int autoLearningBarIndex = useBarOpenTransactions ? bar_index - 1 : bar_index
float autoCurrentMoveSpeedPctPerBar = not na(autoRoc20Pct) ? math.abs(autoRoc20Pct) / 20.0 : 0.0

int autoCurrentTrendRegime =
     not na(autoSlowEmaPast) and transactionPrice > autoSlowEma and autoFastEma > autoSlowEma and autoSlowEma > autoSlowEmaPast ? 1 :
     not na(autoSlowEmaPast) and transactionPrice < autoSlowEma and autoFastEma < autoSlowEma and autoSlowEma < autoSlowEmaPast ? -1 :
     0

if transactionProcessingEvent and not na(autoLearningPrice) and autoLearningPrice > 0.0 and automationActiveInput
    if na(autoLearningPeak)
        autoLearningPeak := autoLearningPrice
        autoLearningPeakBar := autoLearningBarIndex
        autoLearningTrough := autoLearningPrice
        autoLearningTroughBar := autoLearningBarIndex
        autoLearningMaximumDrawdownPct := 0.0
    else if autoLearningPrice > autoLearningPeak
        if autoLearningMaximumDrawdownPct >= autoMinimumLearningDrawdownInput
            int declineBars = math.max(autoLearningTroughBar - autoLearningPeakBar, 1)
            int recoveryBars = math.max(autoLearningBarIndex - autoLearningTroughBar, 1)
            float recoveryPct = autoLearningTrough > 0.0 ? (autoLearningPrice / autoLearningTrough - 1.0) * 100.0 : 0.0
            float declineSpeedPctPerBar = autoLearningMaximumDrawdownPct / declineBars
            float recoverySpeedPctPerBar = recoveryPct / recoveryBars

            f_pushLimited(autoDrawdownSamples, autoLearningMaximumDrawdownPct, autoLearningCyclesInput)
            f_pushLimited(autoRecoverySamples, recoveryPct, autoLearningCyclesInput)
            f_pushLimited(autoDeclineSpeedSamples, declineSpeedPctPerBar, autoLearningCyclesInput)
            f_pushLimited(autoRecoverySpeedSamples, recoverySpeedPctPerBar, autoLearningCyclesInput)

            autoLearnedDrawdownQ25 := f_percentile(autoDrawdownSamples, 25.0)
            autoLearnedDrawdownQ50 := f_percentile(autoDrawdownSamples, 50.0)
            autoLearnedDrawdownQ75 := f_percentile(autoDrawdownSamples, 75.0)
            autoLearnedDrawdownQ90 := f_percentile(autoDrawdownSamples, 90.0)
            autoLearnedRecoveryQ70 := f_percentile(autoRecoverySamples, 70.0)
            autoLearnedDeclineSpeedMedian := f_percentile(autoDeclineSpeedSamples, 50.0)
            autoLearnedRecoverySpeedMedian := f_percentile(autoRecoverySpeedSamples, 50.0)

        autoLearningPeak := autoLearningPrice
        autoLearningPeakBar := autoLearningBarIndex
        autoLearningTrough := autoLearningPrice
        autoLearningTroughBar := autoLearningBarIndex
        autoLearningMaximumDrawdownPct := 0.0
    else
        float learningDrawdownPct = autoLearningPeak > 0.0 ? (1.0 - autoLearningPrice / autoLearningPeak) * 100.0 : 0.0

        if learningDrawdownPct > autoLearningMaximumDrawdownPct
            autoLearningMaximumDrawdownPct := learningDrawdownPct
            autoLearningTrough := autoLearningPrice
            autoLearningTroughBar := autoLearningBarIndex

int autoModelSampleCount = array.size(autoDrawdownSamples)
float autoModelConfidence = math.min(float(autoModelSampleCount) / effectiveAutoMinimumCycles, 1.0)
float autoSafeAtrBaselinePct = math.max(nz(autoAtrBaselinePct, 1.0), 0.1)
float autoSafeAtrPct = math.max(nz(autoAtrPct, autoSafeAtrBaselinePct), 0.1)
float autoVolatilityRatio = f_clamp(autoSafeAtrPct / autoSafeAtrBaselinePct, 0.5, 2.5)
float autoMedianDeclineSpeed = nz(autoLearnedDeclineSpeedMedian, math.max(autoSafeAtrBaselinePct / 10.0, 0.05))
float autoMedianRecoverySpeed = nz(autoLearnedRecoverySpeedMedian, autoMedianDeclineSpeed)
float autoRecoveryStrength = f_clamp(autoMedianRecoverySpeed / math.max(autoMedianDeclineSpeed, 0.000001), 0.5, 2.0)
float autoSpeedRatio = f_clamp(autoCurrentMoveSpeedPctPerBar / math.max(autoMedianDeclineSpeed, 0.05), 0.5, 2.0)

float autoFallbackLevel1 = math.max(3.0, autoSafeAtrBaselinePct * 2.10)
float autoFallbackLevel2 = math.max(7.5, autoSafeAtrBaselinePct * 4.50)
float autoFallbackLevel3 = math.max(16.0, autoSafeAtrBaselinePct * 8.80)
float autoFallbackLevel4 = math.max(30.0, autoSafeAtrBaselinePct * 15.00)

// Existing drawdown percentiles are deliberately stretched. The first level
// starts earlier than the historical lower quartile, while the fourth level
// extends beyond the historical 90th percentile to create a broader ladder.
float autoLearnedLevel1 = na(autoLearnedDrawdownQ25) ? autoFallbackLevel1 : autoLearnedDrawdownQ25 * 0.78
float autoLearnedLevel2 = na(autoLearnedDrawdownQ50) ? autoFallbackLevel2 : autoLearnedDrawdownQ50 * 0.95
float autoLearnedLevel3 = na(autoLearnedDrawdownQ75) ? autoFallbackLevel3 : autoLearnedDrawdownQ75 * 1.05
float autoLearnedLevel4 = na(autoLearnedDrawdownQ90) ? autoFallbackLevel4 : autoLearnedDrawdownQ90 * 1.18

float autoLevelRegimeFactor =
     f_clamp(math.sqrt(autoVolatilityRatio), 0.84, 1.24) *
     (autoCurrentTrendRegime == 1 ? 0.93 : autoCurrentTrendRegime == -1 ? 1.12 : 1.0) *
     f_clamp(math.pow(autoSpeedRatio, 0.12), 0.91, 1.11)

float autoLevelProfileFactor1 = switch autoProfileInput
    "Defensive" => 1.04
    "Aggressive" => 0.86
    => 0.96

float autoLevelProfileFactor2 = switch autoProfileInput
    "Defensive" => 1.06
    "Aggressive" => 0.98
    => 1.02

float autoLevelProfileFactor3 = switch autoProfileInput
    "Defensive" => 1.10
    "Aggressive" => 1.10
    => 1.10

float autoLevelProfileFactor4 = switch autoProfileInput
    "Defensive" => 1.14
    "Aggressive" => 1.22
    => 1.18

float autoRawLevel1 =
     (autoFallbackLevel1 * (1.0 - autoModelConfidence) + autoLearnedLevel1 * autoModelConfidence) *
     autoLevelRegimeFactor * autoLevelProfileFactor1

float autoRawLevel2 =
     (autoFallbackLevel2 * (1.0 - autoModelConfidence) + autoLearnedLevel2 * autoModelConfidence) *
     autoLevelRegimeFactor * autoLevelProfileFactor2

float autoRawLevel3 =
     (autoFallbackLevel3 * (1.0 - autoModelConfidence) + autoLearnedLevel3 * autoModelConfidence) *
     autoLevelRegimeFactor * autoLevelProfileFactor3

float autoRawLevel4 =
     (autoFallbackLevel4 * (1.0 - autoModelConfidence) + autoLearnedLevel4 * autoModelConfidence) *
     autoLevelRegimeFactor * autoLevelProfileFactor4

float autoModelDrawdownLevel1 = f_clamp(autoRawLevel1, 3.0, 38.0)
float autoModelDrawdownLevel2 = f_clamp(math.max(autoRawLevel2, autoModelDrawdownLevel1 + 4.0), 7.0, 58.0)
float autoModelDrawdownLevel3 = f_clamp(math.max(autoRawLevel3, autoModelDrawdownLevel2 + 7.0), 14.0, 78.0)
float autoModelDrawdownLevel4 = f_clamp(math.max(autoRawLevel4, autoModelDrawdownLevel3 + 10.0), 24.0, 92.0)

// Profile floors create a clear distinction between defensive and aggressive
// deployment. Learning and the current regime can scale values inside the
// profile range, but cannot reduce them below the stated minimums.
float autoBaseAllocationLevel1Pct = switch autoProfileInput
    "Defensive" => 22.0
    "Aggressive" => 52.0
    => 35.0

float autoBaseAllocationLevel2Pct = switch autoProfileInput
    "Defensive" => 32.0
    "Aggressive" => 66.0
    => 48.0

float autoBaseAllocationLevel3Pct = switch autoProfileInput
    "Defensive" => 45.0
    "Aggressive" => 82.0
    => 64.0

float autoBaseAllocationLevel4Pct = switch autoProfileInput
    "Defensive" => 60.0
    "Aggressive" => 94.0
    => 80.0

float autoMinimumAllocationLevel1Pct = switch autoProfileInput
    "Defensive" => 20.0
    "Aggressive" => 50.0
    => 30.0

float autoMinimumAllocationLevel2Pct = switch autoProfileInput
    "Defensive" => 28.0
    "Aggressive" => 60.0
    => 42.0

float autoMinimumAllocationLevel3Pct = switch autoProfileInput
    "Defensive" => 40.0
    "Aggressive" => 75.0
    => 56.0

float autoMinimumAllocationLevel4Pct = switch autoProfileInput
    "Defensive" => 55.0
    "Aggressive" => 85.0
    => 72.0

float autoMaximumAllocationLevel1Pct = switch autoProfileInput
    "Defensive" => 30.0
    "Aggressive" => 66.0
    => 46.0

float autoMaximumAllocationLevel2Pct = switch autoProfileInput
    "Defensive" => 42.0
    "Aggressive" => 80.0
    => 60.0

float autoMaximumAllocationLevel3Pct = switch autoProfileInput
    "Defensive" => 58.0
    "Aggressive" => 94.0
    => 78.0

float autoMaximumAllocationLevel4Pct = switch autoProfileInput
    "Defensive" => 72.0
    "Aggressive" => 100.0
    => 92.0

float autoAllocationSeverity =
     f_clamp(
          math.max(autoVolatilityRatio - 1.0, 0.0) * 0.30 +
          (autoCurrentTrendRegime == -1 ? 0.20 : 0.0) +
          math.max(autoSpeedRatio - 1.0, 0.0) * 0.10,
          0.0,
          0.40)

float autoRecoveryAllocationFactor = f_clamp(math.pow(autoRecoveryStrength, 0.16), 0.90, 1.10)

float autoRawAllocationLevel1Pct =
     autoBaseAllocationLevel1Pct * autoRecoveryAllocationFactor *
     (1.0 - 0.18 * autoAllocationSeverity)

float autoRawAllocationLevel2Pct =
     autoBaseAllocationLevel2Pct * autoRecoveryAllocationFactor *
     (1.0 - 0.10 * autoAllocationSeverity)

float autoRawAllocationLevel3Pct =
     autoBaseAllocationLevel3Pct * autoRecoveryAllocationFactor *
     (1.0 + 0.10 * autoAllocationSeverity)

float autoRawAllocationLevel4Pct =
     autoBaseAllocationLevel4Pct * autoRecoveryAllocationFactor *
     (1.0 + 0.18 * autoAllocationSeverity)

float autoModelAllocationLevel1Pct =
     f_clamp(autoRawAllocationLevel1Pct, autoMinimumAllocationLevel1Pct, autoMaximumAllocationLevel1Pct)

float autoModelAllocationLevel2Pct =
     f_clamp(autoRawAllocationLevel2Pct, autoMinimumAllocationLevel2Pct, autoMaximumAllocationLevel2Pct)

float autoModelAllocationLevel3Pct =
     f_clamp(autoRawAllocationLevel3Pct, autoMinimumAllocationLevel3Pct, autoMaximumAllocationLevel3Pct)

float autoModelAllocationLevel4Pct =
     f_clamp(autoRawAllocationLevel4Pct, autoMinimumAllocationLevel4Pct, autoMaximumAllocationLevel4Pct)

float autoMinimumActivationPct = switch autoProfileInput
    "Defensive" => 14.0
    "Aggressive" => 27.0
    => 19.0

float autoActivationLevel3Multiplier = switch autoProfileInput
    "Defensive" => 0.95
    "Aggressive" => 1.28
    => 1.10

float autoBullActivationFactor = switch autoProfileInput
    "Defensive" => 1.03
    "Aggressive" => 1.15
    => 1.08

float autoFallbackActivationPct =
     math.max(autoMinimumActivationPct, autoModelDrawdownLevel3 * autoActivationLevel3Multiplier)

float autoLearnedActivationPct =
     na(autoLearnedRecoveryQ70) ?
     autoFallbackActivationPct :
     math.max(autoModelDrawdownLevel2 * 1.35, autoLearnedRecoveryQ70 * 0.90)

float autoModelTrailingActivationPct =
     (autoFallbackActivationPct * (1.0 - autoModelConfidence) +
      math.max(autoFallbackActivationPct, autoLearnedActivationPct) * autoModelConfidence) *
     (autoCurrentTrendRegime == 1 ? autoBullActivationFactor : autoCurrentTrendRegime == -1 ? 0.93 : 1.0) *
     f_clamp(math.pow(autoRecoveryStrength, 0.12), 0.93, 1.10)

autoModelTrailingActivationPct := f_clamp(autoModelTrailingActivationPct, autoMinimumActivationPct, 140.0)

// The trailing distance remains volatility-aware but is intentionally closer
// to price than in v2.3. Defensive is closest, Aggressive retains more room.
float autoMinimumTrailingDistancePct = switch autoProfileInput
    "Defensive" => 2.75
    "Aggressive" => 3.75
    => 3.25

float autoAtrTrailingMultiplier = switch autoProfileInput
    "Defensive" => 1.45
    "Aggressive" => 2.05
    => 1.75

float autoTrailingLevel1Multiplier = switch autoProfileInput
    "Defensive" => 0.42
    "Aggressive" => 0.62
    => 0.52

float autoLearnedTrailingMultiplier = switch autoProfileInput
    "Defensive" => 0.45
    "Aggressive" => 0.65
    => 0.55

float autoFallbackTrailingDistancePct =
     math.max(
          autoMinimumTrailingDistancePct,
          math.max(
               autoModelDrawdownLevel1 * autoTrailingLevel1Multiplier,
               autoSafeAtrPct * autoAtrTrailingMultiplier))

float autoLearnedTrailingDistancePct =
     na(autoLearnedDrawdownQ25) ?
     autoFallbackTrailingDistancePct :
     math.max(autoMinimumTrailingDistancePct, autoLearnedDrawdownQ25 * autoLearnedTrailingMultiplier)

float autoModelTrailingDistancePct =
     (autoFallbackTrailingDistancePct * (1.0 - autoModelConfidence) +
      autoLearnedTrailingDistancePct * autoModelConfidence) *
     f_clamp(math.sqrt(autoVolatilityRatio), 0.90, 1.17) *
     (autoCurrentTrendRegime == -1 ? 0.92 : 1.0) *
     f_clamp(math.pow(autoSpeedRatio, 0.10), 0.93, 1.08) *
     f_clamp(math.pow(autoRecoveryStrength, 0.05), 0.97, 1.04)

autoModelTrailingDistancePct := f_clamp(autoModelTrailingDistancePct, autoMinimumTrailingDistancePct, 28.0)

float autoTargetCashBasePct = switch autoProfileInput
    "Defensive" => 14.0
    "Aggressive" => 7.0
    => 10.0

float autoTargetCashLevel4Multiplier = switch autoProfileInput
    "Defensive" => 0.32
    "Aggressive" => 0.20
    => 0.26

float autoTargetCashMinimumPct = switch autoProfileInput
    "Defensive" => 18.0
    "Aggressive" => 10.0
    => 14.0

float autoTargetCashMaximumPct = switch autoProfileInput
    "Defensive" => 40.0
    "Aggressive" => 28.0
    => 34.0

float autoTargetProfileFactor = switch autoProfileInput
    "Defensive" => 1.06
    "Aggressive" => 0.96
    => 1.00

float autoModelTargetCashRatioPct =
     f_clamp(
          autoTargetCashBasePct + autoTargetCashLevel4Multiplier * autoModelDrawdownLevel4,
          autoTargetCashMinimumPct,
          autoTargetCashMaximumPct) *
     autoTargetProfileFactor /
     f_clamp(math.pow(autoRecoveryStrength, 0.16), 0.91, 1.10)

autoModelTargetCashRatioPct := f_clamp(autoModelTargetCashRatioPct, 10.0, 40.0)

float autoBaseMaximumSellPct = switch autoProfileInput
    "Defensive" => 24.0
    "Aggressive" => 12.0
    => 18.0

float autoModelMaximumSellPct =
     f_clamp(
          autoBaseMaximumSellPct /
          f_clamp(math.pow(autoRecoveryStrength, 0.18), 0.91, 1.13),
          6.0,
          30.0)

float autoModelWeaknessMultiplier = switch autoProfileInput
    "Defensive" => 1.00
    "Aggressive" => 1.16
    => 1.08

string effectiveProfitTakingMode =
     useAutoProfitInput ?
     "Trailing cash-ratio rebalancing" :
     profitTakingModeInput

bool useTrailingProfitTaking = effectiveProfitTakingMode == "Trailing"
bool useRegularRebalancing = effectiveProfitTakingMode == "Regular portfolio rebalancing"
bool useCashRatioRebalancing = effectiveProfitTakingMode == "Cash-ratio rebalancing"
bool useTrailingCashRatioRebalancing = effectiveProfitTakingMode == "Trailing cash-ratio rebalancing"
bool useTrailingTrigger = useTrailingProfitTaking or useTrailingCashRatioRebalancing

float effectiveCurrentTrailingActivationPct =
     useAutoProfitInput ?
     autoModelTrailingActivationPct :
     trailingActivationPctInput

float effectiveCurrentTrailingDistancePct =
     useAutoProfitInput ?
     autoModelTrailingDistancePct :
     trailingDistancePctInput

float effectiveCurrentCashRatioTargetPct =
     useAutoProfitInput ?
     autoModelTargetCashRatioPct :
     cashRatioTargetPctInput

float effectiveCashRatioTargetPct =
     useAutoProfitInput ?
     autoModelTargetCashRatioPct :
     math.max(cashRatioTargetPctInput, cashRatioTriggerPctInput)

float effectiveCurrentMaximumSellPct =
     useAutoProfitInput ?
     autoModelMaximumSellPct :
     100.0

float effectiveCurrentWeaknessMultiplier =
     useAutoProfitInput ?
     autoModelWeaknessMultiplier :
     1.0

bool dividendsEnabled = dividendHandlingInput != "Off"
bool reserveDividendsForNextPlanBuy = dividendsEnabled and dividendHandlingInput == "Next savings-plan buy"
string dividendTicker = ticker.standard(syminfo.tickerid)
float dividendPerUnit = na

if dividendsEnabled
    dividendPerUnit := request.dividends(
         dividendTicker,
         dividends.gross,
         gaps = barmerge.gaps_on,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true)

// ---------------------------------------------------
// Savings-Plan Account and Portfolio Accounting
// ---------------------------------------------------
varip bool planStarted = false
varip int actualStartTime = na
varip int processedIntervals = 0
varip int processedRebalanceIntervals = 0
varip int processedBrokerCostIntervals = 0
varip int externalDepositCount = 0
varip int planBuyCount = 0
varip int dipBuyCount = 0
varip int profitTakeCount = 0
varip int dividendEventCount = 0
varip int brokerCostEventCount = 0

varip float totalExternalDeposits = 0.0
varip float totalGrossDividendsReceived = 0.0
varip float totalDividendsReceived = 0.0
varip float totalDividendCosts = 0.0
varip float totalGrossSaleProceeds = 0.0
varip float totalSaleProceeds = 0.0
varip float totalPurchaseOutflows = 0.0
varip float totalPlanPurchaseOutflows = 0.0
varip float totalDipPurchaseOutflows = 0.0
varip float totalSoldCostBasis = 0.0
varip float totalTransactionCosts = 0.0
varip float totalPlanTransactionCosts = 0.0
varip float totalDipTransactionCosts = 0.0
varip float totalSaleTransactionCosts = 0.0
varip float totalBrokerCostsAccrued = 0.0
varip float totalBrokerCostsPaid = 0.0
varip float outstandingBrokerCosts = 0.0
varip float savingsAccountCash = 0.0
varip float directPurchaseCarryCash = 0.0
varip float dividendPurchaseCash = 0.0
varip float planQty = 0.0
varip float dipQty = 0.0
varip float planCostBasis = 0.0
varip float dipCostBasis = 0.0
varip float realizedProfit = 0.0
varip float initialPurchaseQty = 0.0
varip float initialPurchaseCost = 0.0
varip float previousPortfolioValue = na
varip float cashFlowAdjustedPortfolioIndex = 100.0
varip float cashFlowAdjustedPortfolioPeak = 100.0
varip float highestTotalProfit = na
varip float maximumPortfolioDrawdownPct = 0.0

varip float drawdownPeak = na
varip bool drawdownLevel1Used = false
varip bool drawdownLevel2Used = false
varip bool drawdownLevel3Used = false
varip bool drawdownLevel4Used = false
varip bool dividendDataAvailable = false

varip bool trailingActive = false
varip float trailingPeak = na
varip float trailingRearmAbove = na
varip float lastProfitTakePrice = na
varip bool profitTakeRiseUnlocked = true
varip bool dcaInsufficientCashActive = false
varip int dcaInsufficientAttemptCount = 0
varip float dcaInsufficientBudgetAtLastAttempt = na

varip bool startEvent = false
varip bool initialBuyEvent = false
varip bool planBuyEvent = false
varip bool dipBuyEvent = false
varip bool profitTakeEvent = false
varip int newRegularDeposits = 0
varip int dipLevelsExecutedThisBar = 0
varip float externalDepositsThisBar = 0.0
varip float regularDirectBuyCashDue = 0.0
varip float planOrderQty = 0.0
varip float planOrderNotionalThisBar = 0.0
varip float planTransactionCostThisBar = 0.0
varip float planOrderValueThisBar = 0.0
varip float planCashTopUpThisBar = 0.0
varip float dipOrderQty = 0.0
varip float dipOrderNotionalThisBar = 0.0
varip float dipTransactionCostThisBar = 0.0
varip float dipOrderValueThisBar = 0.0
varip float dipLevel1OrderQty = 0.0
varip float dipLevel1OrderValueThisBar = 0.0
varip float dipLevel2OrderQty = 0.0
varip float dipLevel2OrderValueThisBar = 0.0
varip float dipLevel3OrderQty = 0.0
varip float dipLevel3OrderValueThisBar = 0.0
varip float dipLevel4OrderQty = 0.0
varip float dipLevel4OrderValueThisBar = 0.0
varip float profitTakeOrderQty = 0.0
varip float profitTakeGrossProceedsThisBar = 0.0
varip float profitTakeTransactionCostThisBar = 0.0
varip float profitTakeProceedsThisBar = 0.0
varip float profitTakeCostBasisThisBar = 0.0
varip float realizedProfitThisBar = 0.0
varip float grossDividendIncomeThisBar = 0.0
varip float dividendCostThisBar = 0.0
varip float dividendIncomeThisBar = 0.0
varip float brokerCostAccruedThisBar = 0.0
varip float brokerCostPaidThisBar = 0.0
varip float heldQtyBeforeTransactions = 0.0
varip string dipLevelBreakdownText = ""
varip string dipLevelAlertText = ""
varip string profitTakeReason = ""

if barstate.isnew
    startEvent := false
    initialBuyEvent := false
    planBuyEvent := false
    dipBuyEvent := false
    profitTakeEvent := false
    newRegularDeposits := 0
    dipLevelsExecutedThisBar := 0
    externalDepositsThisBar := 0.0
    regularDirectBuyCashDue := 0.0
    planOrderQty := 0.0
    planOrderNotionalThisBar := 0.0
    planTransactionCostThisBar := 0.0
    planOrderValueThisBar := 0.0
    planCashTopUpThisBar := 0.0
    dipOrderQty := 0.0
    dipOrderNotionalThisBar := 0.0
    dipTransactionCostThisBar := 0.0
    dipOrderValueThisBar := 0.0
    dipLevel1OrderQty := 0.0
    dipLevel1OrderValueThisBar := 0.0
    dipLevel2OrderQty := 0.0
    dipLevel2OrderValueThisBar := 0.0
    dipLevel3OrderQty := 0.0
    dipLevel3OrderValueThisBar := 0.0
    dipLevel4OrderQty := 0.0
    dipLevel4OrderValueThisBar := 0.0
    profitTakeOrderQty := 0.0
    profitTakeGrossProceedsThisBar := 0.0
    profitTakeTransactionCostThisBar := 0.0
    profitTakeProceedsThisBar := 0.0
    profitTakeCostBasisThisBar := 0.0
    realizedProfitThisBar := 0.0
    grossDividendIncomeThisBar := 0.0
    dividendCostThisBar := 0.0
    dividendIncomeThisBar := 0.0
    brokerCostAccruedThisBar := 0.0
    brokerCostPaidThisBar := 0.0
    heldQtyBeforeTransactions := 0.0
    dipLevelBreakdownText := ""
    dipLevelAlertText := ""
    profitTakeReason := ""

if dividendsEnabled and not na(dividendPerUnit)
    dividendDataAvailable := true

if transactionProcessingEvent and timeframeAllowed and dateReached and contractValue > 0.0
    // The first eligible bar starts the ledger. Initial capital is first credited
    // to the savings account and is then allocated to the initial purchase.
    if not planStarted
        planStarted := true
        startEvent := true
        actualStartTime := transactionTime
        processedIntervals := 0
        processedRebalanceIntervals := 0
        processedBrokerCostIntervals := 0

        if initialCapitalInput > 0.0
            totalExternalDeposits += initialCapitalInput
            externalDepositsThisBar += initialCapitalInput
            savingsAccountCash += initialCapitalInput
            externalDepositCount += 1
            array.push(contributionTimes, actualStartTime)
            array.push(contributionAmounts, initialCapitalInput)

    heldQtyBeforeTransactions := planQty + dipQty

    // Dividends are internal portfolio income. They are credited before any
    // purchase or sale on the same bar and are never counted as deposits.
    if dividendsEnabled and heldQtyBeforeTransactions > 0.0 and not na(dividendPerUnit) and dividendPerUnit > 0.0
        grossDividendIncomeThisBar := dividendPerUnit * heldQtyBeforeTransactions * pointValue
        dividendCostThisBar := grossDividendIncomeThisBar * dividendCostRate
        dividendIncomeThisBar := math.max(grossDividendIncomeThisBar - dividendCostThisBar, 0.0)

        if grossDividendIncomeThisBar > 0.0
            savingsAccountCash += dividendIncomeThisBar
            totalGrossDividendsReceived += grossDividendIncomeThisBar
            totalDividendsReceived += dividendIncomeThisBar
            totalDividendCosts += dividendCostThisBar
            dividendEventCount += 1

            if reserveDividendsForNextPlanBuy
                dividendPurchaseCash += dividendIncomeThisBar

    // Every scheduled external contribution is credited individually at its
    // scheduled timestamp. This also keeps the XIRR cash-flow dates accurate.
    int intervalsDueNow = planStarted and not na(actualStartTime) ? math.max(int(math.floor(float(transactionTime - actualStartTime) / float(depositIntervalMs))), 0) : 0
    newRegularDeposits := math.max(intervalsDueNow - processedIntervals, 0)

    if newRegularDeposits > 0
        for depositOffset = 1 to newRegularDeposits
            int scheduledInterval = processedIntervals + depositOffset
            int scheduledDepositTime = actualStartTime + scheduledInterval * depositIntervalMs
            int completedIncreasePeriods = increaseIntervalMs > 0 ? math.max(int(math.floor(float(scheduledDepositTime - actualStartTime) / float(increaseIntervalMs))), 0) : 0
            float scheduledDeposit = regularDepositInput + completedIncreasePeriods * regularDepositIncreaseInput
            float scheduledDirectBuy = math.min(regularDirectBuyInput + completedIncreasePeriods * directBuyIncreaseInput, scheduledDeposit)

            regularDirectBuyCashDue += scheduledDirectBuy

            if scheduledDeposit > 0.0
                totalExternalDeposits += scheduledDeposit
                externalDepositsThisBar += scheduledDeposit
                savingsAccountCash += scheduledDeposit
                externalDepositCount += 1
                array.push(contributionTimes, scheduledDepositTime)
                array.push(contributionAmounts, scheduledDeposit)

        processedIntervals := intervalsDueNow

    // Existing broker-cost liabilities are paid from available account cash
    // before new purchases. Newly due costs are accrued on the net portfolio
    // value and paid immediately where cash permits; any remainder stays as a
    // liability and reduces the reported portfolio value.
    if enableBrokerCostsInput and outstandingBrokerCosts > 0.0 and savingsAccountCash > 0.0
        float priorBrokerCostPayment = math.min(outstandingBrokerCosts, savingsAccountCash)
        savingsAccountCash -= priorBrokerCostPayment
        outstandingBrokerCosts -= priorBrokerCostPayment
        totalBrokerCostsPaid += priorBrokerCostPayment
        brokerCostPaidThisBar += priorBrokerCostPayment

    int brokerCostIntervalsDueNow =
         enableBrokerCostsInput and planStarted and not na(actualStartTime) and brokerCostIntervalMs > 0 ?
         math.max(int(math.floor(float(transactionTime - actualStartTime) / float(brokerCostIntervalMs))), 0) :
         0

    int newBrokerCostIntervals = math.max(brokerCostIntervalsDueNow - processedBrokerCostIntervals, 0)

    if enableBrokerCostsInput and newBrokerCostIntervals > 0
        for brokerCostOffset = 1 to newBrokerCostIntervals
            float heldValueForBrokerCost = (planQty + dipQty) * contractValue
            float netPortfolioValueForBrokerCost = math.max(savingsAccountCash + heldValueForBrokerCost - outstandingBrokerCosts, 0.0)
            float recurringBrokerCost = netPortfolioValueForBrokerCost * brokerCostRate

            if recurringBrokerCost > 0.0
                totalBrokerCostsAccrued += recurringBrokerCost
                outstandingBrokerCosts += recurringBrokerCost
                brokerCostAccruedThisBar += recurringBrokerCost
                brokerCostEventCount += 1

            if outstandingBrokerCosts > 0.0 and savingsAccountCash > 0.0
                float brokerCostPayment = math.min(outstandingBrokerCosts, savingsAccountCash)
                savingsAccountCash -= brokerCostPayment
                outstandingBrokerCosts -= brokerCostPayment
                totalBrokerCostsPaid += brokerCostPayment
                brokerCostPaidThisBar += brokerCostPayment

        processedBrokerCostIntervals := brokerCostIntervalsDueNow

    // Broker costs are real account expenses and therefore take priority over
    // internal purchase reservations. If a payment has reduced account cash
    // below the reserved total, dividend cash is released first and purchase
    // carry cash second. This prevents phantom reservations above actual cash.
    float reservedCashAfterBrokerCosts =
         (carryDirectBuyRemainder ? directPurchaseCarryCash : 0.0) +
         (reserveDividendsForNextPlanBuy ? dividendPurchaseCash : 0.0)

    if reservedCashAfterBrokerCosts > savingsAccountCash
        float reservationShortfall = reservedCashAfterBrokerCosts - savingsAccountCash

        if reserveDividendsForNextPlanBuy and reservationShortfall > 0.0
            float dividendReservationReduction = math.min(dividendPurchaseCash, reservationShortfall)
            dividendPurchaseCash := math.max(dividendPurchaseCash - dividendReservationReduction, 0.0)
            reservationShortfall -= dividendReservationReduction

        if carryDirectBuyRemainder and reservationShortfall > 0.0
            directPurchaseCarryCash := math.max(directPurchaseCarryCash - reservationShortfall, 0.0)

    // Plan purchases remain tied to the normal schedule. If a whole-unit DCA
    // allocation is too small for the minimum tradable quantity, available cash
    // in the savings account tops it up only to that minimum. If total cash is
    // still insufficient, nothing is debited and the allocation remains cash.
    bool planAllocationEvent = startEvent or newRegularDeposits > 0
    float dividendCashForPlanBuy = reserveDividendsForNextPlanBuy and newRegularDeposits > 0 ? math.min(dividendPurchaseCash, savingsAccountCash) : 0.0
    float newPlanAllocation = (startEvent ? initialCapitalInput : 0.0) + regularDirectBuyCashDue + dividendCashForPlanBuy
    float requestedPlanCash = newPlanAllocation

    if dividendCashForPlanBuy > 0.0
        dividendPurchaseCash := math.max(dividendPurchaseCash - dividendCashForPlanBuy, 0.0)

    if carryDirectBuyRemainder
        directPurchaseCarryCash += newPlanAllocation
        directPurchaseCarryCash := math.min(directPurchaseCarryCash, savingsAccountCash)
        requestedPlanCash := planAllocationEvent ? directPurchaseCarryCash : 0.0

    bool planPurchaseRequested = planAllocationEvent and requestedPlanCash > 0.0
    float baseAvailablePlanCash = math.min(requestedPlanCash, savingsAccountCash)
    float availablePlanCash = baseAvailablePlanCash
    float planFundingTolerance = math.max(0.0000001, minimumPlanOrderDebit * 1e-10)
    bool scheduledBudgetCannotBuyMinimum =
         planPurchaseRequested and
         not useFractionalExecution and
         f_buyBudgetToQty(baseAvailablePlanCash, contractValue, accountingQuantityStep, transactionCostRate) <= 0.0

    if scheduledBudgetCannotBuyMinimum and savingsAccountCash + planFundingTolerance >= minimumPlanOrderDebit
        availablePlanCash := math.min(minimumPlanOrderDebit, savingsAccountCash)

    if availablePlanCash > 0.0
        planOrderQty := f_buyBudgetToQty(availablePlanCash, contractValue, accountingQuantityStep, transactionCostRate)
        planOrderNotionalThisBar := planOrderQty * contractValue
        planTransactionCostThisBar := planOrderNotionalThisBar * transactionCostRate
        planOrderValueThisBar := planOrderNotionalThisBar + planTransactionCostThisBar

        if planOrderQty > 0.0 and planOrderValueThisBar > 0.0
            planCashTopUpThisBar := math.max(planOrderValueThisBar - baseAvailablePlanCash, 0.0)
            savingsAccountCash := math.max(savingsAccountCash - planOrderValueThisBar, 0.0)

            if carryDirectBuyRemainder
                directPurchaseCarryCash := math.max(directPurchaseCarryCash - planOrderValueThisBar, 0.0)

            planQty += planOrderQty
            planCostBasis += planOrderValueThisBar
            totalPurchaseOutflows += planOrderValueThisBar
            totalPlanPurchaseOutflows += planOrderValueThisBar
            totalTransactionCosts += planTransactionCostThisBar
            totalPlanTransactionCosts += planTransactionCostThisBar
            planBuyEvent := true
            planBuyCount += 1

    bool dcaInsufficientCashThisBar =
         planPurchaseRequested and
         not useFractionalExecution and
         planOrderQty <= 0.0

    if dcaInsufficientCashThisBar
        if not dcaInsufficientCashActive
            dcaInsufficientAttemptCount := 0

        int missedDcaDatesThisBar = startEvent ? 1 : math.max(newRegularDeposits, 1)
        dcaInsufficientCashActive := true
        dcaInsufficientAttemptCount += missedDcaDatesThisBar
        dcaInsufficientBudgetAtLastAttempt := requestedPlanCash
    else if planBuyEvent
        dcaInsufficientCashActive := false
        dcaInsufficientAttemptCount := 0
        dcaInsufficientBudgetAtLastAttempt := na

    if startEvent
        initialPurchaseQty := planOrderQty
        initialPurchaseCost := planOrderValueThisBar
        initialBuyEvent := planBuyEvent

    // Drawdown levels reset only after a strictly higher closing high.
    // Automatic levels and allocations are frozen for the complete drawdown
    // cycle so thresholds cannot move away from price after the decline starts.
    bool newTransactionPriceHigh = na(drawdownPeak) or transactionPrice > drawdownPeak

    if newTransactionPriceHigh
        drawdownPeak := transactionPrice
        drawdownLevel1Used := false
        drawdownLevel2Used := false
        drawdownLevel3Used := false
        drawdownLevel4Used := false

        if useAutoDipInput
            autoCycleDrawdownLevel1 := autoModelDrawdownLevel1
            autoCycleDrawdownLevel2 := autoModelDrawdownLevel2
            autoCycleDrawdownLevel3 := autoModelDrawdownLevel3
            autoCycleDrawdownLevel4 := autoModelDrawdownLevel4
            autoCycleAllocationLevel1Pct := autoModelAllocationLevel1Pct
            autoCycleAllocationLevel2Pct := autoModelAllocationLevel2Pct
            autoCycleAllocationLevel3Pct := autoModelAllocationLevel3Pct
            autoCycleAllocationLevel4Pct := autoModelAllocationLevel4Pct

    float activeDrawdownLevel1 =
         useAutoDipInput ?
         nz(autoCycleDrawdownLevel1, autoModelDrawdownLevel1) :
         drawdownLevel1Input

    float activeDrawdownLevel2 =
         useAutoDipInput ?
         nz(autoCycleDrawdownLevel2, autoModelDrawdownLevel2) :
         drawdownLevel2Input

    float activeDrawdownLevel3 =
         useAutoDipInput ?
         nz(autoCycleDrawdownLevel3, autoModelDrawdownLevel3) :
         drawdownLevel3Input

    float activeDrawdownLevel4 =
         useAutoDipInput ?
         nz(autoCycleDrawdownLevel4, autoModelDrawdownLevel4) :
         drawdownLevel4Input

    float activeDipAllocationLevel1Pct =
         useAutoDipInput ?
         nz(autoCycleAllocationLevel1Pct, autoModelAllocationLevel1Pct) :
         dipEquityPctLevel1Input

    float activeDipAllocationLevel2Pct =
         useAutoDipInput ?
         nz(autoCycleAllocationLevel2Pct, autoModelAllocationLevel2Pct) :
         dipEquityPctLevel2Input

    float activeDipAllocationLevel3Pct =
         useAutoDipInput ?
         nz(autoCycleAllocationLevel3Pct, autoModelAllocationLevel3Pct) :
         dipEquityPctLevel3Input

    float activeDipAllocationLevel4Pct =
         useAutoDipInput ?
         nz(autoCycleAllocationLevel4Pct, autoModelAllocationLevel4Pct) :
         dipEquityPctLevel4Input

    bool useEquityDipSizing = useAutoDipInput or dipSizeModeInput == "Equity"
    float confirmedDrawdownPct = not na(drawdownPeak) and drawdownPeak > 0.0 ? (transactionPrice / drawdownPeak - 1.0) * 100.0 : na

    // Dip purchases debit the same account. Only explicitly reserved purchase
    // allocations are protected from dip spending. Triggered levels are handled
    // independently from Level 1 to Level 4. Manual Equity sizing keeps the
    // original same-bar cash base; Auto sizing uses the remaining free cash after
    // each preceding level so gaps can still distribute cash across deeper levels.
    // A level becomes used only after an actual quantity has been purchased.
    float protectedDirectPurchaseCash = carryDirectBuyRemainder ? directPurchaseCarryCash : 0.0
    float protectedDividendCash = reserveDividendsForNextPlanBuy ? dividendPurchaseCash : 0.0
    float protectedPurchaseCash = math.min(protectedDirectPurchaseCash + protectedDividendCash, savingsAccountCash)
    float dipSpendableCash = math.max(savingsAccountCash - protectedPurchaseCash, 0.0)
    float remainingDipSpendableCash = dipSpendableCash

    if enableDipBuysInput and not na(confirmedDrawdownPct)
        if activeDrawdownLevel1 > 0.0 and not drawdownLevel1Used and confirmedDrawdownPct <= -activeDrawdownLevel1 and remainingDipSpendableCash > 0.0
            float level1CashBase = useAutoDipInput ? remainingDipSpendableCash : dipSpendableCash
            float requestedLevel1Cash = useEquityDipSizing ? level1CashBase * activeDipAllocationLevel1Pct / 100.0 : dipCashLevel1Input
            float availableLevel1Cash = math.min(requestedLevel1Cash, remainingDipSpendableCash)
            dipLevel1OrderQty := f_buyBudgetToQty(availableLevel1Cash, contractValue, accountingQuantityStep, transactionCostRate)
            float dipLevel1OrderNotionalThisBar = dipLevel1OrderQty * contractValue
            float dipLevel1TransactionCostThisBar = dipLevel1OrderNotionalThisBar * transactionCostRate
            dipLevel1OrderValueThisBar := dipLevel1OrderNotionalThisBar + dipLevel1TransactionCostThisBar

            if dipLevel1OrderQty > 0.0 and dipLevel1OrderValueThisBar > 0.0
                drawdownLevel1Used := true
                remainingDipSpendableCash := math.max(remainingDipSpendableCash - dipLevel1OrderValueThisBar, 0.0)
                dipOrderQty += dipLevel1OrderQty
                dipOrderNotionalThisBar += dipLevel1OrderNotionalThisBar
                dipTransactionCostThisBar += dipLevel1TransactionCostThisBar
                dipOrderValueThisBar += dipLevel1OrderValueThisBar
                dipLevelsExecutedThisBar += 1
                dipLevelBreakdownText += "\nL1 " + f_quantity(dipLevel1OrderQty) + " / " + f_money(dipLevel1OrderValueThisBar)
                dipLevelAlertText += "L1"

        if activeDrawdownLevel2 > 0.0 and not drawdownLevel2Used and confirmedDrawdownPct <= -activeDrawdownLevel2 and remainingDipSpendableCash > 0.0
            float level2CashBase = useAutoDipInput ? remainingDipSpendableCash : dipSpendableCash
            float requestedLevel2Cash = useEquityDipSizing ? level2CashBase * activeDipAllocationLevel2Pct / 100.0 : dipCashLevel2Input
            float availableLevel2Cash = math.min(requestedLevel2Cash, remainingDipSpendableCash)
            dipLevel2OrderQty := f_buyBudgetToQty(availableLevel2Cash, contractValue, accountingQuantityStep, transactionCostRate)
            float dipLevel2OrderNotionalThisBar = dipLevel2OrderQty * contractValue
            float dipLevel2TransactionCostThisBar = dipLevel2OrderNotionalThisBar * transactionCostRate
            dipLevel2OrderValueThisBar := dipLevel2OrderNotionalThisBar + dipLevel2TransactionCostThisBar

            if dipLevel2OrderQty > 0.0 and dipLevel2OrderValueThisBar > 0.0
                drawdownLevel2Used := true
                remainingDipSpendableCash := math.max(remainingDipSpendableCash - dipLevel2OrderValueThisBar, 0.0)
                dipOrderQty += dipLevel2OrderQty
                dipOrderNotionalThisBar += dipLevel2OrderNotionalThisBar
                dipTransactionCostThisBar += dipLevel2TransactionCostThisBar
                dipOrderValueThisBar += dipLevel2OrderValueThisBar
                dipLevelsExecutedThisBar += 1
                dipLevelBreakdownText += "\nL2 " + f_quantity(dipLevel2OrderQty) + " / " + f_money(dipLevel2OrderValueThisBar)
                dipLevelAlertText += (dipLevelAlertText == "" ? "" : ", ") + "L2"

        if activeDrawdownLevel3 > 0.0 and not drawdownLevel3Used and confirmedDrawdownPct <= -activeDrawdownLevel3 and remainingDipSpendableCash > 0.0
            float level3CashBase = useAutoDipInput ? remainingDipSpendableCash : dipSpendableCash
            float requestedLevel3Cash = useEquityDipSizing ? level3CashBase * activeDipAllocationLevel3Pct / 100.0 : dipCashLevel3Input
            float availableLevel3Cash = math.min(requestedLevel3Cash, remainingDipSpendableCash)
            dipLevel3OrderQty := f_buyBudgetToQty(availableLevel3Cash, contractValue, accountingQuantityStep, transactionCostRate)
            float dipLevel3OrderNotionalThisBar = dipLevel3OrderQty * contractValue
            float dipLevel3TransactionCostThisBar = dipLevel3OrderNotionalThisBar * transactionCostRate
            dipLevel3OrderValueThisBar := dipLevel3OrderNotionalThisBar + dipLevel3TransactionCostThisBar

            if dipLevel3OrderQty > 0.0 and dipLevel3OrderValueThisBar > 0.0
                drawdownLevel3Used := true
                remainingDipSpendableCash := math.max(remainingDipSpendableCash - dipLevel3OrderValueThisBar, 0.0)
                dipOrderQty += dipLevel3OrderQty
                dipOrderNotionalThisBar += dipLevel3OrderNotionalThisBar
                dipTransactionCostThisBar += dipLevel3TransactionCostThisBar
                dipOrderValueThisBar += dipLevel3OrderValueThisBar
                dipLevelsExecutedThisBar += 1
                dipLevelBreakdownText += "\nL3 " + f_quantity(dipLevel3OrderQty) + " / " + f_money(dipLevel3OrderValueThisBar)
                dipLevelAlertText += (dipLevelAlertText == "" ? "" : ", ") + "L3"

        if activeDrawdownLevel4 > 0.0 and not drawdownLevel4Used and confirmedDrawdownPct <= -activeDrawdownLevel4 and remainingDipSpendableCash > 0.0
            float level4CashBase = useAutoDipInput ? remainingDipSpendableCash : dipSpendableCash
            float requestedLevel4Cash = useEquityDipSizing ? level4CashBase * activeDipAllocationLevel4Pct / 100.0 : dipCashLevel4Input
            float availableLevel4Cash = math.min(requestedLevel4Cash, remainingDipSpendableCash)
            dipLevel4OrderQty := f_buyBudgetToQty(availableLevel4Cash, contractValue, accountingQuantityStep, transactionCostRate)
            float dipLevel4OrderNotionalThisBar = dipLevel4OrderQty * contractValue
            float dipLevel4TransactionCostThisBar = dipLevel4OrderNotionalThisBar * transactionCostRate
            dipLevel4OrderValueThisBar := dipLevel4OrderNotionalThisBar + dipLevel4TransactionCostThisBar

            if dipLevel4OrderQty > 0.0 and dipLevel4OrderValueThisBar > 0.0
                drawdownLevel4Used := true
                remainingDipSpendableCash := math.max(remainingDipSpendableCash - dipLevel4OrderValueThisBar, 0.0)
                dipOrderQty += dipLevel4OrderQty
                dipOrderNotionalThisBar += dipLevel4OrderNotionalThisBar
                dipTransactionCostThisBar += dipLevel4TransactionCostThisBar
                dipOrderValueThisBar += dipLevel4OrderValueThisBar
                dipLevelsExecutedThisBar += 1
                dipLevelBreakdownText += "\nL4 " + f_quantity(dipLevel4OrderQty) + " / " + f_money(dipLevel4OrderValueThisBar)
                dipLevelAlertText += (dipLevelAlertText == "" ? "" : ", ") + "L4"

    if dipOrderQty > 0.0 and dipOrderValueThisBar > 0.0
        savingsAccountCash := math.max(savingsAccountCash - dipOrderValueThisBar, 0.0)
        dipQty += dipOrderQty
        dipCostBasis += dipOrderValueThisBar
        totalPurchaseOutflows += dipOrderValueThisBar
        totalDipPurchaseOutflows += dipOrderValueThisBar
        totalTransactionCosts += dipTransactionCostThisBar
        totalDipTransactionCosts += dipTransactionCostThisBar
        dipBuyEvent := true
        dipBuyCount += dipLevelsExecutedThisBar

    // ---------------------------------------------------
    // Profit Taking
    // ---------------------------------------------------
    float qtyBeforeProfitTake = planQty + dipQty
    float costBasisBeforeProfitTake = planCostBasis + dipCostBasis
    float marketValueBeforeProfitTake = qtyBeforeProfitTake * contractValue
    float netCashPositionBeforeProfitTake = savingsAccountCash - outstandingBrokerCosts
    float portfolioValueBeforeProfitTake = netCashPositionBeforeProfitTake + marketValueBeforeProfitTake
    float cashRatioBeforeProfitTake = portfolioValueBeforeProfitTake > 0.0 ? netCashPositionBeforeProfitTake / portfolioValueBeforeProfitTake * 100.0 : na
    float averagePriceBeforeProfitTake = qtyBeforeProfitTake > 0.0 ? costBasisBeforeProfitTake / (qtyBeforeProfitTake * pointValue) : na
    float estimatedNetExitPrice = transactionPrice * (1.0 - transactionCostRate)
    float profitAboveAveragePct = not na(averagePriceBeforeProfitTake) and averagePriceBeforeProfitTake > 0.0 ? (estimatedNetExitPrice / averagePriceBeforeProfitTake - 1.0) * 100.0 : na
    float netOpenProfitBeforeProfitTake = marketValueBeforeProfitTake * (1.0 - transactionCostRate) - costBasisBeforeProfitTake
    float requestedProfitTakeGrossValue = 0.0
    float requestedProfitTakeQty = 0.0
    // A completed partial TP locks every profit-taking mode. The lock opens
    // only after the selected transaction-price series has reached the required
    // rise above the actual last TP execution price. Once reached, it stays open
    // during the following pullback so a newly armed trailing rule can trigger.
    float profitTakeUnlockPriceBeforeTrade =
         not na(lastProfitTakePrice) and minimumRiseAfterProfitTakePctInput > 0.0 ?
         lastProfitTakePrice * (1.0 + minimumRiseAfterProfitTakePctInput / 100.0) :
         na
    if na(profitTakeUnlockPriceBeforeTrade)
        profitTakeRiseUnlocked := true
    else if not profitTakeRiseUnlocked and transactionPrice >= profitTakeUnlockPriceBeforeTrade
        profitTakeRiseUnlocked := true

    bool profitTakeRiseRequirementMet = profitTakeRiseUnlocked
    bool profitTakingAllowedThisBar =
         not planBuyEvent and
         not dipBuyEvent and
         profitTakeRiseRequirementMet

    if not useTrailingTrigger
        trailingActive := false
        trailingPeak := na
        trailingRearmAbove := na
        armedTrailingDistancePct := na
        armedCashRatioTargetPct := na
        armedAutoMaximumSellPct := na
        armedAutoWeaknessMultiplier := na

    if useTrailingTrigger and not profitTakeRiseRequirementMet
        trailingActive := false
        trailingPeak := na
        armedTrailingDistancePct := na
        armedCashRatioTargetPct := na
        armedAutoMaximumSellPct := na
        armedAutoWeaknessMultiplier := na

    if useTrailingTrigger and profitTakeRiseRequirementMet and qtyBeforeProfitTake > 0.0 and not na(profitAboveAveragePct)
        bool trailingCanArm = na(trailingRearmAbove) or transactionPrice > trailingRearmAbove

        if not trailingActive and trailingCanArm and profitAboveAveragePct >= effectiveCurrentTrailingActivationPct
            trailingActive := true
            trailingPeak := transactionPrice
            armedTrailingDistancePct := effectiveCurrentTrailingDistancePct
            armedCashRatioTargetPct := effectiveCurrentCashRatioTargetPct
            armedAutoMaximumSellPct := effectiveCurrentMaximumSellPct
            armedAutoWeaknessMultiplier := effectiveCurrentWeaknessMultiplier

        if trailingActive
            trailingPeak := math.max(nz(trailingPeak, transactionPrice), transactionPrice)
            float activeTrailingDistancePct = nz(armedTrailingDistancePct, effectiveCurrentTrailingDistancePct)
            float activeCashRatioTargetPct = nz(armedCashRatioTargetPct, effectiveCurrentCashRatioTargetPct)
            float activeWeaknessMultiplier = nz(armedAutoWeaknessMultiplier, effectiveCurrentWeaknessMultiplier)
            float trailingStopPrice = trailingPeak * (1.0 - activeTrailingDistancePct / 100.0)
            float trailingPullbackPct = trailingPeak > 0.0 ? (1.0 - transactionPrice / trailingPeak) * 100.0 : 0.0
            bool autoTrendWeakness = transactionPrice < autoFastEma or autoCurrentTrendRegime != 1
            bool autoTriggerAllowed =
                 not useAutoProfitInput or
                 autoTrendWeakness or
                 trailingPullbackPct >= activeTrailingDistancePct * activeWeaknessMultiplier

            if transactionPrice <= trailingStopPrice and autoTriggerAllowed and profitTakingAllowedThisBar
                if useTrailingProfitTaking
                    requestedProfitTakeQty := qtyBeforeProfitTake * trailingSellPctInput / 100.0
                    profitTakeReason := "Trailing"
                else if useTrailingCashRatioRebalancing and netOpenProfitBeforeProfitTake > 0.0 and not na(cashRatioBeforeProfitTake)
                    requestedProfitTakeGrossValue := f_targetGrossSaleValue(netCashPositionBeforeProfitTake, portfolioValueBeforeProfitTake, activeCashRatioTargetPct, transactionCostRate)
                    profitTakeReason := useAutoProfitInput ? "Auto adaptive trailing cash ratio" : "Trailing cash-ratio rebalancing"

                trailingActive := false
                trailingRearmAbove := trailingPeak
                trailingPeak := na

    if useRegularRebalancing and profitTakingAllowedThisBar and qtyBeforeProfitTake > 0.0 and regularRebalanceIntervalMs > 0
        int rebalanceIntervalsDueNow = planStarted and not na(actualStartTime) ? math.max(int(math.floor(float(transactionTime - actualStartTime) / float(regularRebalanceIntervalMs))), 0) : 0
        int newRebalanceIntervals = math.max(rebalanceIntervalsDueNow - processedRebalanceIntervals, 0)

        if newRebalanceIntervals > 0

            if netOpenProfitBeforeProfitTake > 0.0 and not na(cashRatioBeforeProfitTake) and cashRatioBeforeProfitTake < regularRebalanceTargetCashPctInput
                requestedProfitTakeGrossValue := f_targetGrossSaleValue(netCashPositionBeforeProfitTake, portfolioValueBeforeProfitTake, regularRebalanceTargetCashPctInput, transactionCostRate)
                profitTakeReason := "Regular portfolio rebalancing"

            processedRebalanceIntervals := rebalanceIntervalsDueNow

    if useCashRatioRebalancing and profitTakingAllowedThisBar and qtyBeforeProfitTake > 0.0 and netOpenProfitBeforeProfitTake > 0.0 and not na(cashRatioBeforeProfitTake)
        if cashRatioBeforeProfitTake < cashRatioTriggerPctInput
            requestedProfitTakeGrossValue := f_targetGrossSaleValue(netCashPositionBeforeProfitTake, portfolioValueBeforeProfitTake, effectiveCashRatioTargetPct, transactionCostRate)
            profitTakeReason := "Cash-ratio rebalancing"

    if requestedProfitTakeGrossValue > 0.0
        requestedProfitTakeQty := f_cashToQty(requestedProfitTakeGrossValue, contractValue, accountingQuantityStep)

    if useAutoProfitInput and requestedProfitTakeQty > 0.0
        float activeMaximumSellPct = nz(armedAutoMaximumSellPct, effectiveCurrentMaximumSellPct)
        requestedProfitTakeQty := math.min(requestedProfitTakeQty, qtyBeforeProfitTake * activeMaximumSellPct / 100.0)

    if requestedProfitTakeQty > 0.0 and qtyBeforeProfitTake > 0.0
        float cappedProfitTakeQty = math.min(requestedProfitTakeQty, qtyBeforeProfitTake)
        profitTakeOrderQty := cappedProfitTakeQty >= qtyBeforeProfitTake - accountingQuantityStep * 1e-9 ? qtyBeforeProfitTake : f_roundDownToStep(cappedProfitTakeQty, accountingQuantityStep)

        if profitTakeOrderQty > 0.0
            float soldFraction = math.min(profitTakeOrderQty / qtyBeforeProfitTake, 1.0)
            profitTakeCostBasisThisBar := costBasisBeforeProfitTake * soldFraction
            profitTakeGrossProceedsThisBar := profitTakeOrderQty * contractValue
            profitTakeTransactionCostThisBar := profitTakeGrossProceedsThisBar * transactionCostRate
            profitTakeProceedsThisBar := math.max(profitTakeGrossProceedsThisBar - profitTakeTransactionCostThisBar, 0.0)
            realizedProfitThisBar := profitTakeProceedsThisBar - profitTakeCostBasisThisBar

            // Only net sale proceeds are credited. The transaction cost reduces
            // the account credit and realized profit; it is never credited twice.
            savingsAccountCash += profitTakeProceedsThisBar
            totalGrossSaleProceeds += profitTakeGrossProceedsThisBar
            totalSaleProceeds += profitTakeProceedsThisBar
            totalSoldCostBasis += profitTakeCostBasisThisBar
            totalTransactionCosts += profitTakeTransactionCostThisBar
            totalSaleTransactionCosts += profitTakeTransactionCostThisBar
            realizedProfit += realizedProfitThisBar

            planQty *= 1.0 - soldFraction
            dipQty *= 1.0 - soldFraction
            planCostBasis *= 1.0 - soldFraction
            dipCostBasis *= 1.0 - soldFraction

            profitTakeEvent := true
            profitTakeCount += 1
            lastProfitTakePrice := transactionPrice
            profitTakeRiseUnlocked := minimumRiseAfterProfitTakePctInput <= 0.0

            if soldFraction >= 1.0 - 1e-10
                planQty := 0.0
                dipQty := 0.0
                planCostBasis := 0.0
                dipCostBasis := 0.0
                trailingActive := false
                trailingPeak := na
                trailingRearmAbove := na
                lastProfitTakePrice := na
                profitTakeRiseUnlocked := true
                armedTrailingDistancePct := na
                armedCashRatioTargetPct := na
                armedAutoMaximumSellPct := na
                armedAutoWeaknessMultiplier := na

    if enableBrokerCostsInput and outstandingBrokerCosts > 0.0 and savingsAccountCash > 0.0
        float postSaleBrokerCostPayment = math.min(outstandingBrokerCosts, savingsAccountCash)
        savingsAccountCash -= postSaleBrokerCostPayment
        outstandingBrokerCosts -= postSaleBrokerCostPayment
        totalBrokerCostsPaid += postSaleBrokerCostPayment
        brokerCostPaidThisBar += postSaleBrokerCostPayment

        float reservedCashAfterSaleCostPayment =
             (carryDirectBuyRemainder ? directPurchaseCarryCash : 0.0) +
             (reserveDividendsForNextPlanBuy ? dividendPurchaseCash : 0.0)

        if reservedCashAfterSaleCostPayment > savingsAccountCash
            float postSaleReservationShortfall = reservedCashAfterSaleCostPayment - savingsAccountCash

            if reserveDividendsForNextPlanBuy and postSaleReservationShortfall > 0.0
                float postSaleDividendReservationReduction = math.min(dividendPurchaseCash, postSaleReservationShortfall)
                dividendPurchaseCash := math.max(dividendPurchaseCash - postSaleDividendReservationReduction, 0.0)
                postSaleReservationShortfall -= postSaleDividendReservationReduction

            if carryDirectBuyRemainder and postSaleReservationShortfall > 0.0
                directPurchaseCarryCash := math.max(directPurchaseCarryCash - postSaleReservationShortfall, 0.0)

    if enableDcaAlertsInput and planBuyEvent
        string planCashTopUpAlertText =
             planCashTopUpThisBar > 0.0 ?
             " | " + f_text("Cash top-up: ", "Cash-Aufstockung: ", "Complément cash : ") + f_money(planCashTopUpThisBar) :
             ""
        string planAlertMessage = "DCA | " + syminfo.ticker +
             " | " + f_text("Price: ", "Kurs: ", "Prix : ") + f_money(transactionPrice) +
             " | " + f_text("Qty: ", "Anzahl: ", "Qté : ") + f_quantity(planOrderQty) +
             " | " + f_text("Costs: ", "Kosten: ", "Frais : ") + f_money(planTransactionCostThisBar) +
             " | " + f_text("Account debit: ", "Kontobelastung: ", "Débit du compte : ") + f_money(planOrderValueThisBar) +
             planCashTopUpAlertText
        alert(planAlertMessage, alert.freq_all)

    if enableDipAlertsInput and dipBuyEvent
        string dipAlertMessage = "DIP | " + syminfo.ticker +
             " | " + f_text("Levels: ", "Stufen: ", "Niveaux : ") + dipLevelAlertText +
             " | " + f_text("Price: ", "Kurs: ", "Prix : ") + f_money(transactionPrice) +
             " | " + f_text("Qty: ", "Anzahl: ", "Qté : ") + f_quantity(dipOrderQty) +
             " | " + f_text("Costs: ", "Kosten: ", "Frais : ") + f_money(dipTransactionCostThisBar) +
             " | " + f_text("Account debit: ", "Kontobelastung: ", "Débit du compte : ") + f_money(dipOrderValueThisBar)
        alert(dipAlertMessage, alert.freq_all)

    if enableTpAlertsInput and profitTakeEvent
        float nextProfitTakeUnlockPriceForAlert =
             not na(lastProfitTakePrice) and minimumRiseAfterProfitTakePctInput > 0.0 ?
             lastProfitTakePrice * (1.0 + minimumRiseAfterProfitTakePctInput / 100.0) :
             na
        string profitTakeRearmAlertText =
             not na(nextProfitTakeUnlockPriceForAlert) ?
             " | " + f_text("Next TP unlock: ", "Nächste TP-Freigabe: ", "Prochain déverrouillage TP : ") +
                  f_money(nextProfitTakeUnlockPriceForAlert) + " (+" + f_percent(minimumRiseAfterProfitTakePctInput) + ")" :
             ""
        string saleAlertMessage = "TP | " + syminfo.ticker +
             " | " + f_text("Price: ", "Kurs: ", "Prix : ") + f_money(transactionPrice) +
             " | " + f_text("Qty: ", "Anzahl: ", "Qté : ") + f_quantity(profitTakeOrderQty) +
             " | " + f_text("Gross: ", "Brutto: ", "Brut : ") + f_money(profitTakeGrossProceedsThisBar) +
             " | " + f_text("Costs: ", "Kosten: ", "Frais : ") + f_money(profitTakeTransactionCostThisBar) +
             " | " + f_text("Account credit: ", "Kontogutschrift: ", "Crédit du compte : ") + f_money(profitTakeProceedsThisBar) +
             " | " + f_text("Realized P/L: ", "Realisierter G/V: ", "G/P réalisé : ") + f_signedMoney(realizedProfitThisBar) +
             profitTakeRearmAlertText + " | " + profitTakeReason
        alert(saleAlertMessage, alert.freq_all)

float nextProfitTakeUnlockPrice =
     not na(lastProfitTakePrice) and minimumRiseAfterProfitTakePctInput > 0.0 ?
     lastProfitTakePrice * (1.0 + minimumRiseAfterProfitTakePctInput / 100.0) :
     na
float riseSinceLastProfitTakePct =
     not na(lastProfitTakePrice) and lastProfitTakePrice > 0.0 ?
     (transactionPrice / lastProfitTakePrice - 1.0) * 100.0 :
     na
bool profitTakeRiseGateOpen =
     na(nextProfitTakeUnlockPrice) or
     profitTakeRiseUnlocked

// Detailed transaction labels are rendered on every realtime update in Bar open
// mode because drawing objects created on an unconfirmed tick are rolled back.
// Only the closing rendering is stored in the historical label array.
bool renderTransactionLabels =
     useBarOpenTransactions ?
     (barstate.ishistory or barstate.isrealtime) :
     transactionProcessingEvent

if renderTransactionLabels
    // Detailed transaction labels can be enabled independently for DCA buys,
    // dip buys and profit-taking sales. If selected DCA and dip buys occur on
    // the same bar, their details are combined into one non-overlapping label.
    bool showDcaLabelThisBar = showDcaPurchaseLabelsInput and planBuyEvent
    bool showDipLabelThisBar = showDipPurchaseLabelsInput and dipBuyEvent

    if showDcaLabelThisBar or showDipLabelThisBar
        float displayedBuyQty = (showDcaLabelThisBar ? planOrderQty : 0.0) + (showDipLabelThisBar ? dipOrderQty : 0.0)
        float displayedBuyValue = (showDcaLabelThisBar ? planOrderValueThisBar : 0.0) + (showDipLabelThisBar ? dipOrderValueThisBar : 0.0)

        if displayedBuyQty > 0.0 and displayedBuyValue > 0.0
            string buyTypeText = initialBuyEvent and showDcaLabelThisBar ? f_text("INITIAL BUY", "ERSTKAUF", "ACHAT INITIAL") : showDcaLabelThisBar and showDipLabelThisBar ? f_text("DCA + DIP BUY", "DCA + DIP-KAUF", "ACHAT DCA + BAISSE") : showDcaLabelThisBar ? f_text("DCA BUY", "DCA-KAUF", "ACHAT DCA") : f_text("DIP BUY", "DIP-KAUF", "ACHAT SUR BAISSE")
            string buyBreakdownText = showDcaLabelThisBar and showDipLabelThisBar ? "\nDCA " + f_quantity(planOrderQty) + " / " + f_money(planOrderValueThisBar) + "\nDIP " + f_quantity(dipOrderQty) + " / " + f_money(dipOrderValueThisBar) : ""
            buyBreakdownText += showDipLabelThisBar ? dipLevelBreakdownText : ""
            float displayedBuyNotional = (showDcaLabelThisBar ? planOrderNotionalThisBar : 0.0) + (showDipLabelThisBar ? dipOrderNotionalThisBar : 0.0)
            float displayedBuyCost = (showDcaLabelThisBar ? planTransactionCostThisBar : 0.0) + (showDipLabelThisBar ? dipTransactionCostThisBar : 0.0)
            string planCashTopUpLabelText =
                 showDcaLabelThisBar and planCashTopUpThisBar > 0.0 ?
                 "\n" + f_text("Top-up from account cash: ", "Aufstockung aus Kontocash: ", "Complément depuis le cash : ") + f_money(planCashTopUpThisBar) :
                 ""
            string buyLabelText = buyTypeText + "\n" + f_text("Units: ", "Anteile: ", "Unités : ") + f_quantity(displayedBuyQty) + "\n" + f_text("Execution price: ", "Ausführungskurs: ", "Prix d’exécution : ") + f_money(transactionPrice) + "\n" + f_text("Trade value: ", "Handelswert: ", "Valeur négociée : ") + f_money(displayedBuyNotional) + "\n" + f_text("Transaction cost: ", "Transaktionskosten: ", "Frais de transaction : ") + f_money(displayedBuyCost) + "\n" + f_text("Account debit: ", "Kontobelastung: ", "Débit du compte : ") + f_money(displayedBuyValue) + planCashTopUpLabelText + buyBreakdownText
            color buyLabelColor = showDcaLabelThisBar and not showDipLabelThisBar ? color.blue : color.teal
            label buyLabel = label.new(
                 bar_index,
                 low,
                 buyLabelText,
                 xloc = xloc.bar_index,
                 yloc = yloc.belowbar,
                 style = label.style_label_up,
                 color = buyLabelColor,
                 textcolor = color.white,
                 size = size.small)
            if barstate.isconfirmed
                f_storeTransactionLabel(buyLabel, transactionLabels, transactionLabelLimitInput)

    if showTpLabelsInput and profitTakeEvent
        string nextProfitTakeLabelText =
             not na(nextProfitTakeUnlockPrice) ?
             "\n" + f_text("Next TP unlock: ", "Nächste TP-Freigabe: ", "Prochain TP autorisé : ") + f_money(nextProfitTakeUnlockPrice) + " (+" + f_percent(minimumRiseAfterProfitTakePctInput) + ")" :
             ""
        string sellLabelText = f_text("SALE", "VERKAUF", "VENTE") + "\n" + f_text("Units: ", "Anteile: ", "Unités : ") + f_quantity(profitTakeOrderQty) + "\n" + f_text("Execution price: ", "Ausführungskurs: ", "Prix d’exécution : ") + f_money(transactionPrice) + "\n" + f_text("Gross proceeds: ", "Bruttoerlös: ", "Produit brut : ") + f_money(profitTakeGrossProceedsThisBar) + "\n" + f_text("Transaction cost: ", "Transaktionskosten: ", "Frais de transaction : ") + f_money(profitTakeTransactionCostThisBar) + "\n" + f_text("Account credit: ", "Kontogutschrift: ", "Crédit du compte : ") + f_money(profitTakeProceedsThisBar) + "\n" + f_text("Cost basis: ", "Kostenbasis: ", "Prix de revient : ") + f_money(profitTakeCostBasisThisBar) + "\n" + f_text("Realized P/L: ", "Realisierter G/V: ", "P/L réalisé : ") + f_signedMoney(realizedProfitThisBar) + nextProfitTakeLabelText
        label sellLabel = label.new(
             bar_index,
             high,
             sellLabelText,
             xloc = xloc.bar_index,
             yloc = yloc.abovebar,
             style = label.style_label_down,
             color = color.orange,
             textcolor = color.black,
             size = size.small)
        if barstate.isconfirmed
            f_storeTransactionLabel(sellLabel, transactionLabels, transactionLabelLimitInput)


// ---------------------------------------------------
// Portfolio Statistics and Reconciliation
// ---------------------------------------------------
float totalQty = planQty + dipQty
float currentCostBasis = planCostBasis + dipCostBasis
float marketValue = totalQty * valuationContractValue
float netCashPosition = savingsAccountCash - outstandingBrokerCosts
float portfolioValue = netCashPosition + marketValue
float unrealizedProfit = marketValue - currentCostBasis
float unrealizedProfitPct = currentCostBasis > 0.0 ? unrealizedProfit / currentCostBasis * 100.0 : na
float totalProfit = portfolioValue - totalExternalDeposits
float totalReturnOnDepositsPct = totalExternalDeposits > 0.0 ? totalProfit / totalExternalDeposits * 100.0 : na
float averagePurchasePrice = totalQty > 0.0 ? currentCostBasis / (totalQty * pointValue) : na
float cashRatioPct = portfolioValue > 0.0 ? netCashPosition / portfolioValue * 100.0 : na

float effectiveDrawdownLevel1 =
     useAutoDipInput ?
     nz(autoCycleDrawdownLevel1, autoModelDrawdownLevel1) :
     drawdownLevel1Input

float effectiveDrawdownLevel2 =
     useAutoDipInput ?
     nz(autoCycleDrawdownLevel2, autoModelDrawdownLevel2) :
     drawdownLevel2Input

float effectiveDrawdownLevel3 =
     useAutoDipInput ?
     nz(autoCycleDrawdownLevel3, autoModelDrawdownLevel3) :
     drawdownLevel3Input

float effectiveDrawdownLevel4 =
     useAutoDipInput ?
     nz(autoCycleDrawdownLevel4, autoModelDrawdownLevel4) :
     drawdownLevel4Input

float effectiveDipAllocationLevel1Pct =
     useAutoDipInput ?
     nz(autoCycleAllocationLevel1Pct, autoModelAllocationLevel1Pct) :
     dipEquityPctLevel1Input

float effectiveDipAllocationLevel2Pct =
     useAutoDipInput ?
     nz(autoCycleAllocationLevel2Pct, autoModelAllocationLevel2Pct) :
     dipEquityPctLevel2Input

float effectiveDipAllocationLevel3Pct =
     useAutoDipInput ?
     nz(autoCycleAllocationLevel3Pct, autoModelAllocationLevel3Pct) :
     dipEquityPctLevel3Input

float effectiveDipAllocationLevel4Pct =
     useAutoDipInput ?
     nz(autoCycleAllocationLevel4Pct, autoModelAllocationLevel4Pct) :
     dipEquityPctLevel4Input

float currentDrawdownPct = planStarted and not na(drawdownPeak) and drawdownPeak > 0.0 ? (transactionPrice / drawdownPeak - 1.0) * 100.0 : na
float displayedTrailingDistancePct = nz(armedTrailingDistancePct, effectiveCurrentTrailingDistancePct)
float activeTrailingStopPrice = useTrailingTrigger and trailingActive and not na(trailingPeak) ? trailingPeak * (1.0 - displayedTrailingDistancePct / 100.0) : na
float totalCashInflows = totalExternalDeposits + totalDividendsReceived + totalSaleProceeds
float expectedSavingsAccountCash = totalCashInflows - totalPurchaseOutflows - totalBrokerCostsPaid
float cashLedgerDifference = savingsAccountCash - expectedSavingsAccountCash
float costBasisDifference = totalPurchaseOutflows - totalSoldCostBasis - currentCostBasis
float brokerCostLiabilityDifference = totalBrokerCostsAccrued - totalBrokerCostsPaid - outstandingBrokerCosts
float expectedTotalProfit = totalDividendsReceived + realizedProfit + unrealizedProfit - totalBrokerCostsAccrued
float profitDifference = totalProfit - expectedTotalProfit
float totalCosts = totalTransactionCosts + totalDividendCosts + totalBrokerCostsAccrued
float accountingTolerance = math.max(0.0001, math.abs(totalCashInflows) * 1e-9)
bool cashLedgerInSync = math.abs(cashLedgerDifference) <= accountingTolerance
bool costBasisInSync = math.abs(costBasisDifference) <= accountingTolerance
bool brokerCostsInSync = math.abs(brokerCostLiabilityDifference) <= accountingTolerance
bool profitInSync = math.abs(profitDifference) <= accountingTolerance
bool accountingInSync = cashLedgerInSync and costBasisInSync and brokerCostsInSync and profitInSync

// External deposits are removed from each confirmed bar return before updating
// the portfolio performance index. This prevents contributions from creating
// false performance highs or masking portfolio drawdowns.
float cashFlowAdjustedPortfolioReturnPct = planStarted ? cashFlowAdjustedPortfolioIndex - 100.0 : na
float currentPortfolioDrawdownPct = planStarted and cashFlowAdjustedPortfolioPeak > 0.0 ? (cashFlowAdjustedPortfolioIndex / cashFlowAdjustedPortfolioPeak - 1.0) * 100.0 : na

if barstate.isconfirmed and planStarted and portfolioValue >= 0.0
    if na(previousPortfolioValue)
        cashFlowAdjustedPortfolioIndex := 100.0
        cashFlowAdjustedPortfolioPeak := 100.0
    else if previousPortfolioValue > 0.0
        float portfolioValueBeforeExternalFlow = math.max(portfolioValue - externalDepositsThisBar, 0.0)
        float confirmedPortfolioReturn = portfolioValueBeforeExternalFlow / previousPortfolioValue - 1.0
        cashFlowAdjustedPortfolioIndex *= math.max(1.0 + confirmedPortfolioReturn, 0.0)
        cashFlowAdjustedPortfolioPeak := math.max(cashFlowAdjustedPortfolioPeak, cashFlowAdjustedPortfolioIndex)

    previousPortfolioValue := portfolioValue
    cashFlowAdjustedPortfolioReturnPct := cashFlowAdjustedPortfolioIndex - 100.0
    currentPortfolioDrawdownPct := cashFlowAdjustedPortfolioPeak > 0.0 ? (cashFlowAdjustedPortfolioIndex / cashFlowAdjustedPortfolioPeak - 1.0) * 100.0 : na

    bool newHighestTotalProfit = na(highestTotalProfit) or totalProfit > highestTotalProfit

    if newHighestTotalProfit
        highestTotalProfit := totalProfit

        if showMostProfitablePointInput
            if not na(mostProfitablePointLabel)
                label.delete(mostProfitablePointLabel)

            string profitablePointText = f_text("MOST PROFITABLE POINT", "PROFITABELSTE STELLE", "POINT LE PLUS RENTABLE") + "\n" + f_text("Portfolio value: ", "Portfoliowert: ", "Valeur du portefeuille : ") + f_money(portfolioValue) + "\n" + f_text("Total profit: ", "Gesamtgewinn: ", "Gain total : ") + f_signedMoney(totalProfit) + "\n" + f_text("Return on deposits: ", "Rendite auf Einzahlungen: ", "Rendement sur apports : ") + (na(totalReturnOnDepositsPct) ? "-" : f_signedPercent(totalReturnOnDepositsPct))
            mostProfitablePointLabel := label.new(
                 bar_index,
                 high,
                 profitablePointText,
                 xloc = xloc.bar_index,
                 yloc = yloc.abovebar,
                 style = label.style_label_down,
                 color = color.green,
                 textcolor = color.white,
                 size = size.small)

    bool newMaximumPortfolioDrawdown = not na(currentPortfolioDrawdownPct) and currentPortfolioDrawdownPct < maximumPortfolioDrawdownPct

    if newMaximumPortfolioDrawdown
        maximumPortfolioDrawdownPct := currentPortfolioDrawdownPct

        if showMaximumPortfolioDrawdownInput
            if not na(maximumPortfolioDrawdownLabel)
                label.delete(maximumPortfolioDrawdownLabel)

            string maximumDrawdownText = f_text("MAXIMUM PORTFOLIO DRAWDOWN", "GRÖSSTER PORTFOLIO-DRAWDOWN", "DRAWDOWN MAXIMAL DU PORTEFEUILLE") + "\n" + f_text("Portfolio value: ", "Portfoliowert: ", "Valeur du portefeuille : ") + f_money(portfolioValue) + "\n" + f_text("Drawdown: ", "Drawdown: ", "Drawdown : ") + f_percent(currentPortfolioDrawdownPct) + "\n" + f_text("Total profit: ", "Gesamtgewinn: ", "Gain total : ") + f_signedMoney(totalProfit) + "\n" + f_text("Return on deposits: ", "Rendite auf Einzahlungen: ", "Rendement sur apports : ") + (na(totalReturnOnDepositsPct) ? "-" : f_signedPercent(totalReturnOnDepositsPct))
            maximumPortfolioDrawdownLabel := label.new(
                 bar_index,
                 low,
                 maximumDrawdownText,
                 xloc = xloc.bar_index,
                 yloc = yloc.belowbar,
                 style = label.style_label_up,
                 color = color.red,
                 textcolor = color.white,
                 size = size.small)

int statisticsTime = not na(time_close) ? math.min(timenow, time_close) : timenow
int currentIncreasePeriods = planStarted and not na(actualStartTime) and increaseIntervalMs > 0 ? math.max(int(math.floor(float(statisticsTime - actualStartTime) / float(increaseIntervalMs))), 0) : 0
float currentRegularDeposit = regularDepositInput + currentIncreasePeriods * regularDepositIncreaseInput
float currentDirectBuy = math.min(regularDirectBuyInput + currentIncreasePeriods * directBuyIncreaseInput, currentRegularDeposit)
float currentSavingsPerDeposit = math.max(currentRegularDeposit - currentDirectBuy, 0.0)
float currentProtectedDirectPurchaseCash = carryDirectBuyRemainder ? directPurchaseCarryCash : 0.0
float currentProtectedDividendCash = reserveDividendsForNextPlanBuy ? dividendPurchaseCash : 0.0
float currentProtectedPurchaseCash = math.min(currentProtectedDirectPurchaseCash + currentProtectedDividendCash, savingsAccountCash)
float runtimeDaysExact = planStarted and not na(actualStartTime) ? math.max(float(statisticsTime - actualStartTime) / float(millisecondsPerDay), 0.0) : 0.0
int runtimeDays = int(math.floor(runtimeDaysExact))

// One persistent label follows the latest chart bar while DCA is waiting for
// enough cash. This avoids creating one label for every missed purchase date.
if barstate.islast
    if showInsufficientDcaCashWarningInput and dcaInsufficientCashActive and not useFractionalExecution
        if not na(insufficientDcaCashLabel)
            label.delete(insufficientDcaCashLabel)

        float currentDcaAvailableCash = math.max(savingsAccountCash - outstandingBrokerCosts, 0.0)
        float currentDcaCashShortfall = math.max(minimumPlanOrderDebit - currentDcaAvailableCash, 0.0)
        bool currentCashCanFundMinimum =
             currentDcaAvailableCash + math.max(0.0000001, minimumPlanOrderDebit * 1e-10) >= minimumPlanOrderDebit
        string currentDcaFundingStatus =
             currentCashCanFundMinimum ?
             f_text("Cash is now sufficient; purchase at the next DCA date.", "Cash reicht jetzt; Kauf am nächsten DCA-Termin.", "Le cash suffit maintenant; achat à la prochaine date DCA.") :
             f_text("The unspent amount remains in the account and continues to accumulate.", "Der nicht verwendete Betrag bleibt im Konto und wird weiter angesammelt.", "Le montant non utilisé reste sur le compte et continue de s’accumuler.")
        string insufficientDcaCashText =
             f_text("DCA NOT EXECUTED", "DCA NICHT AUSGEFÜHRT", "DCA NON EXÉCUTÉ") +
             "\n" + f_text("Scheduled budget: ", "Kaufbudget: ", "Budget planifié : ") + f_money(nz(dcaInsufficientBudgetAtLastAttempt, currentDirectBuy)) +
             "\n" + f_text("Minimum quantity: ", "Mindestmenge: ", "Quantité minimale : ") + f_quantity(accountingQuantityStep) +
             "\n" + f_text("Required now: ", "Aktuell benötigt: ", "Montant requis : ") + f_money(minimumPlanOrderDebit) +
             "\n" + f_text("Available cash: ", "Verfügbares Cash: ", "Cash disponible : ") + f_money(currentDcaAvailableCash) +
             "\n" + f_text("Missing: ", "Fehlbetrag: ", "Montant manquant : ") + f_money(currentDcaCashShortfall) +
             "\n" + f_text("Missed DCA dates: ", "Ausgefallene DCA-Termine: ", "Dates DCA manquées : ") + str.tostring(dcaInsufficientAttemptCount) +
             "\n" + currentDcaFundingStatus
        color insufficientDcaLabelColor = currentCashCanFundMinimum ? color.orange : color.red

        insufficientDcaCashLabel := label.new(
             bar_index,
             high,
             insufficientDcaCashText,
             xloc = xloc.bar_index,
             yloc = yloc.abovebar,
             style = label.style_label_down,
             color = insufficientDcaLabelColor,
             textcolor = color.white,
             size = mobileTableModeInput ? size.tiny : size.small)
    else if not na(insufficientDcaCashLabel)
        label.delete(insufficientDcaCashLabel)
        insufficientDcaCashLabel := na

// ---------------------------------------------------
// Visuals
// ---------------------------------------------------
plot(showAveragePriceInput ? averagePurchasePrice : na, "Average purchase price", color = color.yellow, linewidth = 2, style = plot.style_stepline)
plot(showProfitTakingSignalsInput and useTrailingTrigger ? activeTrailingStopPrice : na, "Trailing profit-taking stop", color = color.orange, linewidth = 1, style = plot.style_stepline)

plotshape(
     showPlanSignalsInput and planBuyEvent,
     title = "Savings-plan buy",
     style = shape.circle,
     location = location.belowbar,
     color = color.blue,
     text = "DCA",
     textcolor = color.white,
     size = size.tiny)

plotshape(
     showDipSignalsInput and dipBuyEvent,
     title = "Dip buy",
     style = shape.labelup,
     location = location.belowbar,
     color = color.teal,
     text = "DIP",
     textcolor = color.white,
     size = size.tiny)

plotshape(
     showProfitTakingSignalsInput and profitTakeEvent,
     title = "Profit taking",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.orange,
     text = "TP",
     textcolor = color.black,
     size = size.tiny)

int signalout = dipBuyEvent ? +1 : 0
int transactionSignal = planBuyEvent or dipBuyEvent ? +1 : profitTakeEvent ? -1 : 0
plot(signalout, "Dip Buy Signal", display = display.none)
plot(planBuyEvent ? 1 : 0, "Savings Plan Buy Signal", display = display.none)
plot(profitTakeEvent ? 1 : 0, "Profit Taking Signal", display = display.none)
plot(transactionSignal, "Transaction Signal", display = display.none)
plot(currentDrawdownPct, "Current Drawdown %", display = display.none)
plot(transactionPrice, "Transaction Price", display = display.none)
plot(netCashPosition, "Net Cash Position", display = display.none)
plot(portfolioValue, "Portfolio Value", display = display.none)
plot(cashFlowAdjustedPortfolioIndex, "Cash-Flow-Adjusted Portfolio Index", display = display.none)
plot(cashFlowAdjustedPortfolioReturnPct, "Cash-Flow-Adjusted Portfolio Return %", display = display.none)
plot(currentPortfolioDrawdownPct, "Current Portfolio Drawdown %", display = display.none)
plot(planStarted ? maximumPortfolioDrawdownPct : na, "Maximum Portfolio Drawdown %", display = display.none)
plot(savingsAccountCash, "Savings Account Cash", display = display.none)
plot(cashRatioPct, "Savings Account Cash Ratio %", display = display.none)
plot(directPurchaseCarryCash, "Direct Purchase Carry Cash", display = display.none)
plot(dividendPurchaseCash, "Reserved Dividend Cash", display = display.none)
plot(grossDividendIncomeThisBar, "Gross Dividend Income", display = display.none)
plot(dividendCostThisBar, "Dividend Cost", display = display.none)
plot(dividendIncomeThisBar, "Net Dividend Income", display = display.none)
plot(realizedProfit, "Realized Profit", display = display.none)
plot(totalProfit, "Total Profit", display = display.none)
plot(totalQty, "Held Quantity", display = display.none)
plot(currentCostBasis, "Current Cost Basis", display = display.none)
plot(totalCashInflows, "Total Cash Inflows", display = display.none)
plot(totalPurchaseOutflows, "Total Purchase Outflows", display = display.none)
// Detailed notional, fee and per-level transaction values remain available
// in labels and the statistics table. Only aggregate hidden series are
// exported here to keep the script below TradingView's 64-plot limit.
plot(planOrderQty, "Plan Buy Quantity", display = display.none)
plot(planOrderValueThisBar, "Plan Buy Account Debit", display = display.none)
plot(dipOrderQty, "Dip Buy Quantity", display = display.none)
plot(dipOrderValueThisBar, "Dip Buy Account Debit", display = display.none)
plot(profitTakeOrderQty, "Sale Quantity", display = display.none)
plot(profitTakeProceedsThisBar, "Sale Account Credit", display = display.none)
plot(realizedProfitThisBar, "Realized Profit This Bar", display = display.none)
plot(effectiveDrawdownLevel1, "Effective Dip Level 1 %", display = display.none)
plot(effectiveDrawdownLevel2, "Effective Dip Level 2 %", display = display.none)
plot(effectiveDrawdownLevel3, "Effective Dip Level 3 %", display = display.none)
plot(effectiveDrawdownLevel4, "Effective Dip Level 4 %", display = display.none)
plot(effectiveDipAllocationLevel1Pct, "Effective Dip Allocation 1 %", display = display.none)
plot(effectiveDipAllocationLevel2Pct, "Effective Dip Allocation 2 %", display = display.none)
plot(effectiveDipAllocationLevel3Pct, "Effective Dip Allocation 3 %", display = display.none)
plot(effectiveDipAllocationLevel4Pct, "Effective Dip Allocation 4 %", display = display.none)
plot(autoModelTrailingActivationPct, "Auto Trailing Activation %", display = display.none)
plot(autoModelTrailingDistancePct, "Auto Trailing Distance %", display = display.none)
plot(autoModelTargetCashRatioPct, "Auto Target Cash Ratio %", display = display.none)
plot(autoModelMaximumSellPct, "Auto Maximum Sale %", display = display.none)
plot(float(autoModelSampleCount), "Auto Learning Samples", display = display.none)
plot(autoModelConfidence * 100.0, "Auto Model Confidence %", display = display.none)
plot(brokerCostAccruedThisBar, "Broker Cost Accrued This Bar", display = display.none)
plot(brokerCostPaidThisBar, "Broker Cost Paid This Bar", display = display.none)
plot(totalTransactionCosts, "Total Transaction Costs", display = display.none)
plot(totalDividendCosts, "Total Dividend Costs", display = display.none)
plot(totalBrokerCostsAccrued, "Total Broker Costs Accrued", display = display.none)
plot(outstandingBrokerCosts, "Outstanding Broker Costs", display = display.none)
plot(totalCosts, "Total Costs", display = display.none)
plot(cashLedgerDifference, "Cash Ledger Difference", display = display.none)

// ---------------------------------------------------
// TradingView Alert Conditions
// ---------------------------------------------------
bool dcaAlertCondition =
     enableDcaAlertsInput and planBuyEvent and transactionProcessingEvent
bool dipAlertCondition =
     enableDipAlertsInput and dipBuyEvent and transactionProcessingEvent
bool tpAlertCondition =
     enableTpAlertsInput and profitTakeEvent and transactionProcessingEvent

alertcondition(
     dcaAlertCondition,
     "DCA purchase / DCA-Kauf / Achat DCA",
     'DCA | {{exchange}}:{{ticker}} | {{interval}} | Price: {{plot("Transaction Price")}} | Qty: {{plot("Plan Buy Quantity")}} | Debit: {{plot("Plan Buy Account Debit")}}')

alertcondition(
     dipAlertCondition,
     "DIP purchase / DIP-Kauf / Achat DIP",
     'DIP | {{exchange}}:{{ticker}} | {{interval}} | Price: {{plot("Transaction Price")}} | Qty: {{plot("Dip Buy Quantity")}} | Debit: {{plot("Dip Buy Account Debit")}}')

alertcondition(
     tpAlertCondition,
     "TP sale / TP-Verkauf / Vente TP",
     'TP | {{exchange}}:{{ticker}} | {{interval}} | Price: {{plot("Transaction Price")}} | Qty: {{plot("Sale Quantity")}} | Credit: {{plot("Sale Account Credit")}} | Realized P/L: {{plot("Realized Profit This Bar")}}')

// ---------------------------------------------------
// Statistics Table
// ---------------------------------------------------
string dashboardPosition = switch tablePositionInput
    "Top left" => position.top_left
    "Middle right" => position.middle_right
    "Middle left" => position.middle_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right

int dashboardRowCount = mobileTableModeInput ? 20 : 40

var table dashboard = table.new(
     dashboardPosition,
     2,
     dashboardRowCount,
     bgcolor = color.black,
     frame_color = color.gray,
     frame_width = 1,
     border_color = color.new(color.gray, 35),
     border_width = 1)

bool updateDashboard = barstate.islast or barstate.islastconfirmedhistory
varip float cachedAnnualMoneyWeightedReturn = na

if barstate.islastconfirmedhistory or (barstate.islast and (barstate.isconfirmed or (useBarOpenTransactions and barstate.isnew)))
    cachedAnnualMoneyWeightedReturn := f_moneyWeightedAnnualReturn(statisticsTime, portfolioValue)

if updateDashboard
    float annualMoneyWeightedReturn = cachedAnnualMoneyWeightedReturn
    float monthlyMoneyWeightedEquivalent = not na(annualMoneyWeightedReturn) and annualMoneyWeightedReturn > -1.0 ? math.pow(1.0 + annualMoneyWeightedReturn, 1.0 / 12.0) - 1.0 : na

    color headerBg = dcaInsufficientCashActive ? color.new(color.orange, 10) : color.new(color.blue, 10)
    color labelBg = color.new(color.gray, 70)
    color valueBg = color.new(color.black, 0)
    color textColor = color.white
    color cashColor = color.aqua
    color inflowColor = color.lime
    color outflowColor = color.orange
    color unrealizedColor = unrealizedProfit >= 0.0 ? color.lime : color.red
    color totalProfitColor = totalProfit >= 0.0 ? color.lime : color.red
    color realizedColor = realizedProfit >= 0.0 ? color.lime : color.red
    color accountingColor = accountingInSync ? color.lime : color.red
    color xirrColor = na(annualMoneyWeightedReturn) ? textColor : annualMoneyWeightedReturn >= 0.0 ? color.lime : color.red

    string intervalUnitText = f_text(" days", " Tage", " jours")
    string buyWord = f_text(" buy", " Kauf", " achat")
    string cashWord = f_text(" account", " Konto", " compte")
    string autoProfileText =
         autoProfileInput == "Defensive" ?
         f_text("Defensive", "Defensiv", "Défensif") :
         autoProfileInput == "Aggressive" ?
         f_text("Aggressive", "Aggressiv", "Agressif") :
         f_text("Balanced", "Ausgewogen", "Équilibré")
    string dipParameterModeText = useAutoDipInput ? "Auto" : f_text("Manual", "Manuell", "Manuel")
    string profitParameterModeText = useAutoProfitInput ? "Auto" : f_text("Manual", "Manuell", "Manuel")
    string brokerCostIntervalText =
         brokerCostIntervalInput == "Monthly" ?
         f_text("Monthly", "Monatlich", "Mensuel") :
         brokerCostIntervalInput == "Quarterly" ?
         f_text("Quarterly", "Quartalsweise", "Trimestriel") :
         f_text("Yearly", "Jährlich", "Annuel")
    string initialPurchaseText = not planStarted ? f_money(initialCapitalInput) + f_text(" / pending", " / ausstehend", " / en attente") : f_money(initialCapitalInput) + " -> " + f_quantity(initialPurchaseQty) + f_text(" units / debit ", " Anteile / Belastung ", " unités / débit ") + f_money(initialPurchaseCost)
    string depositSchedule = f_money(currentRegularDeposit) + " / " + str.tostring(depositIntervalDaysInput) + intervalUnitText
    string depositSplitText = f_money(currentDirectBuy) + buyWord + " / " + f_money(currentSavingsPerDeposit) + cashWord
    string dividendModeText = not dividendsEnabled ? f_text("Off", "Aus", "Désactivé") : reserveDividendsForNextPlanBuy ? f_text("Credit account / reserve for next buy", "Kontogutschrift / für nächsten Kauf reservieren", "Crédit compte / réserver pour le prochain achat") : f_text("Credit savings account", "Sparplankonto gutschreiben", "Créditer le compte")
    string dividendReceivedText = not dividendsEnabled ? f_text("Disabled", "Deaktiviert", "Désactivé") : dividendDataAvailable ? f_text("Net ", "Netto ", "Net ") + f_money(totalDividendsReceived) + f_text(" / gross ", " / brutto ", " / brut ") + f_money(totalGrossDividendsReceived) + f_text(" / costs ", " / Kosten ", " / frais ") + f_money(totalDividendCosts) + " (" + str.tostring(dividendEventCount) + ")" : f_text("No dividend data", "Keine Dividendendaten", "Aucune donnée de dividende")
    string executionTimingText = useBarOpenTransactions ? f_text("Bar open", "Kerzeneröffnung", "Ouverture") : f_text("Confirmed close", "Bestätigter Schlusskurs", "Clôture confirmée")
    string executionText = executionTimingText + " / " + (useFractionalExecution ? f_text("Fractional units / step ", "Bruchanteile / Schritt ", "Fractions / pas ") + f_quantity(accountingQuantityStep) : carryDirectBuyRemainder ? f_text("Whole units / carry / step ", "Ganze Anteile / Übertrag / Schritt ", "Unités entières / report / pas ") + f_quantity(accountingQuantityStep) : f_text("Whole units / remainder free / step ", "Ganze Anteile / Rest frei / Schritt ", "Unités entières / reliquat libre / pas ") + f_quantity(accountingQuantityStep)) + (dcaInsufficientCashActive ? f_text(" / DCA waiting for cash", " / DCA wartet auf Cash", " / DCA en attente de cash") : "")
    string reservedCashText = f_money(currentProtectedPurchaseCash) + " (" + f_text("carry ", "Übertrag ", "report ") + f_money(currentProtectedDirectPurchaseCash) + " / " + f_text("dividends ", "Dividenden ", "dividendes ") + f_money(currentProtectedDividendCash) + ")"
    string profitTakingBaseText =
         useAutoProfitInput ?
         f_text("Auto ", "Auto ", "Auto ") + autoProfileText +
              f_text(" / activation ", " / Aktivierung ", " / activation ") + f_percent(autoModelTrailingActivationPct) +
              f_text(" / trailing ", " / Trailing ", " / trailing ") + f_percent(autoModelTrailingDistancePct) +
              f_text(" / target cash ", " / Ziel-Cash ", " / liquidités cibles ") + f_percent(autoModelTargetCashRatioPct) +
              f_text(" / max sale ", " / max. Verkauf ", " / vente max. ") + f_percent(autoModelMaximumSellPct) :
         profitTakingModeInput == "Off" ?
         f_text("Off", "Aus", "Désactivé") :
         useTrailingProfitTaking ?
         f_text("Trailing ", "Trailing ", "Trailing ") + f_percent(trailingActivationPctInput) + " / " + f_percent(trailingDistancePctInput) + f_text(" / sell ", " / Verkauf ", " / vente ") + f_percent(trailingSellPctInput) :
         useRegularRebalancing ?
         f_text("Regular ", "Regelmäßig ", "Régulier ") + str.tostring(regularRebalanceMonthsInput) + "M / " + f_text("target ", "Ziel ", "cible ") + f_percent(regularRebalanceTargetCashPctInput) :
         useCashRatioRebalancing ?
         f_text("Cash ratio ", "Cashquote ", "Liquidités ") + f_percent(cashRatioTriggerPctInput) + " -> " + f_percent(effectiveCashRatioTargetPct) :
         f_text("Trailing cash ratio ", "Trailing-Cashquote ", "Liquidités au trailing ") + f_percent(trailingActivationPctInput) + " / " + f_percent(trailingDistancePctInput) + " / " + f_text("target ", "Ziel ", "cible ") + f_percent(cashRatioTargetPctInput)
    string profitTakeRearmText =
         not effectiveProfitTakingEnabledInput ?
         "" :
         minimumRiseAfterProfitTakePctInput <= 0.0 ?
         f_text(" / TP rearm off", " / TP-Wiederfreigabe aus", " / réarmement TP désactivé") :
         na(nextProfitTakeUnlockPrice) ?
         f_text(" / TP rearm +", " / TP-Wiederfreigabe +", " / réarmement TP +") + f_percent(minimumRiseAfterProfitTakePctInput) :
         f_text(" / next TP >= ", " / nächster TP >= ", " / prochain TP >= ") + f_money(nextProfitTakeUnlockPrice) +
              (profitTakeRiseGateOpen ?
                   f_text(" / ready", " / bereit", " / prêt") :
                   f_text(" / current rise ", " / aktueller Anstieg ", " / hausse actuelle ") + f_signedPercent(riseSinceLastProfitTakePct))
    string profitTakingText = profitTakingBaseText + profitTakeRearmText
    string externalDepositsText = f_money(totalExternalDeposits) + " (" + str.tostring(externalDepositCount) + ")"
    string salesText = str.tostring(profitTakeCount) + f_text(" / net credit ", " / Nettogutschrift ", " / crédit net ") + f_money(totalSaleProceeds) + f_text(" / gross ", " / brutto ", " / brut ") + f_money(totalGrossSaleProceeds) + f_text(" / costs ", " / Kosten ", " / frais ") + f_money(totalSaleTransactionCosts)
    string purchaseOutflowsText = f_money(totalPurchaseOutflows) + " (DCA " + f_money(totalPlanPurchaseOutflows) + " / Dip " + f_money(totalDipPurchaseOutflows) + f_text(" / costs ", " / Kosten ", " / frais ") + f_money(totalPlanTransactionCosts + totalDipTransactionCosts) + ")"
    string heldQtyText = f_quantity(totalQty) + " (DCA " + f_quantity(planQty) + " / Dip " + f_quantity(dipQty) + ")"
    string currentCostBasisText = f_money(currentCostBasis) + " (DCA " + f_money(planCostBasis) + " / Dip " + f_money(dipCostBasis) + ")"
    string buyCountText = str.tostring(planBuyCount + dipBuyCount) + " (DCA " + str.tostring(planBuyCount) + " / Dip " + str.tostring(dipBuyCount) + ")"
    string accountingText = accountingInSync ? "OK" : f_text("Cash Δ ", "Cash Δ ", "Cash Δ ") + f_money(cashLedgerDifference) + " / " + f_text("basis Δ ", "Basis Δ ", "base Δ ") + f_money(costBasisDifference) + f_text(" / broker Δ ", " / Broker Δ ", " / courtier Δ ") + f_money(brokerCostLiabilityDifference) + " / P&L Δ " + f_money(profitDifference)
    string automationModeText =
         f_text("Dip ", "Dip ", "Dip ") + dipParameterModeText +
         f_text(" / Profit ", " / Gewinnmitnahme ", " / Profit ") + profitParameterModeText +
         (automationActiveInput ? " / " + autoProfileText : "")

    string autoTrendText =
         autoCurrentTrendRegime == 1 ?
         f_text("Bullish", "Bullisch", "Haussier") :
         autoCurrentTrendRegime == -1 ?
         f_text("Bearish", "Bärisch", "Baissier") :
         f_text("Neutral", "Neutral", "Neutre")

    string autoLearningText =
         not automationActiveInput ?
         f_text("Inactive", "Inaktiv", "Inactif") :
         str.tostring(autoModelSampleCount) + "/" + str.tostring(effectiveAutoMinimumCycles) +
              f_text(" cycles / confidence ", " Zyklen / Vertrauen ", " cycles / confiance ") +
              f_percent(autoModelConfidence * 100.0) +
              " / " + autoTrendText +
              f_text(" / vol x", " / Vol. x", " / vol. x") + str.tostring(autoVolatilityRatio, "#.00") +
              f_text(" / speed x", " / Tempo x", " / vitesse x") + str.tostring(autoSpeedRatio, "#.00")

    string effectiveDipLevelsText =
         f_percent(effectiveDrawdownLevel1) + " / " +
         f_percent(effectiveDrawdownLevel2) + " / " +
         f_percent(effectiveDrawdownLevel3) + " / " +
         f_percent(effectiveDrawdownLevel4)

    string effectiveDipSizingText =
         useAutoDipInput or dipSizeModeInput == "Equity" ?
         f_percent(effectiveDipAllocationLevel1Pct) + " / " +
              f_percent(effectiveDipAllocationLevel2Pct) + " / " +
              f_percent(effectiveDipAllocationLevel3Pct) + " / " +
              f_percent(effectiveDipAllocationLevel4Pct) +
              f_text(" of free cash", " vom freien Cash", " des liquidités libres") :
         f_money(dipCashLevel1Input) + " / " +
              f_money(dipCashLevel2Input) + " / " +
              f_money(dipCashLevel3Input) + " / " +
              f_money(dipCashLevel4Input)

    string effectiveAutoProfitText =
         useAutoProfitInput ?
         f_text("Activation ", "Aktivierung ", "Activation ") + f_percent(autoModelTrailingActivationPct) +
              f_text(" / distance ", " / Abstand ", " / distance ") + f_percent(autoModelTrailingDistancePct) +
              f_text(" / target ", " / Ziel ", " / cible ") + f_percent(autoModelTargetCashRatioPct) +
              f_text(" / max sale ", " / max. Verkauf ", " / vente max. ") + f_percent(autoModelMaximumSellPct) :
         f_text("Manual settings", "Manuelle Einstellungen", "Paramètres manuels")


    string transactionCostText =
         enableTransactionCostsInput ?
         f_percent(transactionCostPctInput) + f_text(" per trade / total ", " je Trade / gesamt ", " par transaction / total ") + f_money(totalTransactionCosts) +
              " (DCA " + f_money(totalPlanTransactionCosts) + " / Dip " + f_money(totalDipTransactionCosts) + f_text(" / sales ", " / Verkäufe ", " / ventes ") + f_money(totalSaleTransactionCosts) + ")" :
         f_text("Off", "Aus", "Désactivé")

    string brokerCostText =
         enableBrokerCostsInput ?
         brokerCostIntervalText + " " + f_percent(brokerCostPctInput) + f_text(" / accrued ", " / angefallen ", " / courus ") + f_money(totalBrokerCostsAccrued) +
              f_text(" / paid ", " / bezahlt ", " / payés ") + f_money(totalBrokerCostsPaid) +
              f_text(" / outstanding ", " / offen ", " / impayés ") + f_money(outstandingBrokerCosts) + " (" + str.tostring(brokerCostEventCount) + ")" :
         f_text("Off", "Aus", "Désactivé")

    string dividendCostText =
         enableDividendCostsInput ?
         f_percent(dividendCostPctInput) + f_text(" of gross dividends / total ", " der Bruttodividenden / gesamt ", " des dividendes bruts / total ") + f_money(totalDividendCosts) :
         f_text("Off", "Aus", "Désactivé")

    string totalCostText = f_money(totalCosts)

    string mobileCashText =
         f_money(savingsAccountCash) +
         (outstandingBrokerCosts > accountingTolerance ?
              f_text(" / net ", " / netto ", " / net ") + f_money(netCashPosition) :
              "")

    string mobileTransactionCountText =
         "DCA " + str.tostring(planBuyCount) +
         " | DIP " + str.tostring(dipBuyCount) +
         " | TP " + str.tostring(profitTakeCount) +
         (dcaInsufficientCashActive ? " | DCA!" : "")

    string mobileProfitRearmText =
         not effectiveProfitTakingEnabledInput or minimumRiseAfterProfitTakePctInput <= 0.0 ?
         "" :
         na(nextProfitTakeUnlockPrice) ?
         " | R+" + f_percent(minimumRiseAfterProfitTakePctInput) :
         profitTakeRiseGateOpen ?
         f_text(" | R ready", " | R bereit", " | R prêt") :
         " | R@" + f_money(nextProfitTakeUnlockPrice)

    string mobileProfitTakingText =
         not effectiveProfitTakingEnabledInput ?
         f_text("Off", "Aus", "Dés.") :
         useAutoProfitInput ?
         "AUTO " + autoProfileText +
              " | A " + f_percent(autoModelTrailingActivationPct) +
              " | T " + f_percent(autoModelTrailingDistancePct) +
              " | C " + f_percent(autoModelTargetCashRatioPct) +
              mobileProfitRearmText :
         useTrailingProfitTaking ?
         "TR " + f_percent(trailingActivationPctInput) + "/" + f_percent(trailingDistancePctInput) +
              " | S " + f_percent(trailingSellPctInput) + mobileProfitRearmText :
         useRegularRebalancing ?
         "REB " + str.tostring(regularRebalanceMonthsInput) + "M | C " +
              f_percent(regularRebalanceTargetCashPctInput) + mobileProfitRearmText :
         useCashRatioRebalancing ?
         "C " + f_percent(cashRatioTriggerPctInput) + "->" +
              f_percent(effectiveCashRatioTargetPct) + mobileProfitRearmText :
         "TR-C " + f_percent(trailingActivationPctInput) + "/" +
              f_percent(trailingDistancePctInput) + " | C " +
              f_percent(cashRatioTargetPctInput) + mobileProfitRearmText

    string mobileDipSizingText =
         useAutoDipInput or dipSizeModeInput == "Equity" ?
         "L1 " + f_percent(effectiveDipAllocationLevel1Pct) +
              " | L2 " + f_percent(effectiveDipAllocationLevel2Pct) +
              " | L3 " + f_percent(effectiveDipAllocationLevel3Pct) +
              " | L4 " + f_percent(effectiveDipAllocationLevel4Pct) :
         "L1 " + f_money(dipCashLevel1Input) +
              " | L2 " + f_money(dipCashLevel2Input) +
              " | L3 " + f_money(dipCashLevel3Input) +
              " | L4 " + f_money(dipCashLevel4Input)

    string mobileDipLevelsText =
         "L1 " + f_percent(effectiveDrawdownLevel1) +
         " | L2 " + f_percent(effectiveDrawdownLevel2) +
         " | L3 " + f_percent(effectiveDrawdownLevel3) +
         " | L4 " + f_percent(effectiveDrawdownLevel4)

    string mobileAccountingText =
         accountingInSync ? "OK" : f_text("ERROR", "FEHLER", "ERREUR")

    if showTableInput
        if mobileTableModeInput
            table.cell(dashboard, 0, 0, f_text("SAVINGS PLAN", "SPARPLAN", "PLAN D’EPARGNE"),
                 bgcolor = headerBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 0, syminfo.ticker,
                 bgcolor = headerBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 1, f_text("Duration", "Laufzeit", "Durée"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 1, f_runtime(runtimeDays),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 2, f_text("Contrib.", "Eingezahlt", "Versements"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 2, f_money(totalExternalDeposits),
                 bgcolor = valueBg,
                 text_color = inflowColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 3, f_text("Cash acct.", "Cashkonto", "Liquidités"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 3, mobileCashText,
                 bgcolor = valueBg,
                 text_color = outstandingBrokerCosts > accountingTolerance ? color.red : cashColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 4, f_text("Portf. value", "Depotwert", "Portefeuille"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 4, f_money(portfolioValue),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 5, f_text("Units", "Anteile", "Unités"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 5, f_quantity(totalQty),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 6, f_text("Cost basis", "Kostenbasis", "Coût de base"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 6, f_money(currentCostBasis),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 7, f_text("Avg cost", "Ø Kauf", "Prix moyen"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 7, na(averagePurchasePrice) ? "-" : f_money(averagePurchasePrice),
                 bgcolor = valueBg,
                 text_color = color.yellow,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 8, f_text("Total P/L", "Gesamt-G/V", "G/P total"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 8, f_money(totalProfit),
                 bgcolor = valueBg,
                 text_color = totalProfitColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 9, f_text("Total return", "Gesamtrendite", "Rend. total"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 9, na(totalReturnOnDepositsPct) ? "-" : f_percent(totalReturnOnDepositsPct),
                 bgcolor = valueBg,
                 text_color = totalProfitColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 10, f_text("Ann. return (XIRR)", "Jahresrend. (XIRR)", "Rend. ann. (XIRR)"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 10, na(annualMoneyWeightedReturn) ? "-" : f_percent(annualMoneyWeightedReturn * 100.0),
                 bgcolor = valueBg,
                 text_color = xirrColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 11, f_text("Monthly eq.", "Monatsäquiv.", "Équiv. mens."),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 11, na(monthlyMoneyWeightedEquivalent) ? "-" : f_percent(monthlyMoneyWeightedEquivalent * 100.0),
                 bgcolor = valueBg,
                 text_color = na(monthlyMoneyWeightedEquivalent) ? textColor : monthlyMoneyWeightedEquivalent >= 0.0 ? color.lime : color.red,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 12, f_text("Price DD", "Kurs-DD", "DD prix"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 12, na(currentDrawdownPct) ? "-" : f_percent(currentDrawdownPct),
                 bgcolor = valueBg,
                 text_color = na(currentDrawdownPct) ? textColor : currentDrawdownPct < 0.0 ? color.red : textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 13, f_text("Cash %", "Cashquote", "Liquidités %"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 13, na(cashRatioPct) ? "-" : f_percent(cashRatioPct),
                 bgcolor = valueBg,
                 text_color = cashColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 14, "DCA / DIP / TP",
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 14, mobileTransactionCountText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 15, f_text("TP rule", "TP-Regel", "Règle TP"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 15, mobileProfitTakingText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 16, f_text("DIP levels", "DIP-Level", "Niv. baisse"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 16, mobileDipLevelsText,
                 bgcolor = valueBg,
                 text_color = color.teal,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 17, f_text("DIP sizes", "DIP-Größen", "Tailles baisse"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 17, mobileDipSizingText,
                 bgcolor = valueBg,
                 text_color = color.teal,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 18, f_text("Costs", "Kosten", "Frais"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 18, totalCostText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.tiny)

            table.cell(dashboard, 0, 19, f_text("Ledger", "Abgleich", "Contrôle"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.tiny)
            table.cell(dashboard, 1, 19, mobileAccountingText,
                 bgcolor = valueBg,
                 text_color = accountingColor,
                 text_size = size.tiny)
        else
            table.cell(dashboard, 0, 0, f_text("SAVINGS PLAN", "SPARPLAN", "PLAN D’EPARGNE"),
                 bgcolor = headerBg,
                 text_color = textColor,
                 text_size = size.normal)
            table.cell(dashboard, 1, 0, syminfo.ticker,
                 bgcolor = headerBg,
                 text_color = textColor,
                 text_size = size.normal)

            table.cell(dashboard, 0, 1, f_text("Plan duration", "Sparplanlaufzeit", "Durée du plan"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 1, f_runtime(runtimeDays),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 2, f_text("Starting capital / first purchase", "Startkapital / Erstkauf", "Capital de départ / premier achat"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 2, initialPurchaseText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 3, f_text("Regular deposit / interval", "Regelmäßige Einzahlung / Intervall", "Versement régulier / intervalle"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 3, depositSchedule,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 4, f_text("Use of each deposit", "Verwendung je Einzahlung", "Utilisation de chaque versement"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 4, depositSplitText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 5, f_text("Execution time / purchase type", "Ausführungszeit / Kaufart", "Moment d’exécution / type d’achat"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 5, executionText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 6, f_text("Reserved cash", "Reserviertes Cash", "Liquidités réservées"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 6, reservedCashText,
                 bgcolor = valueBg,
                 text_color = cashColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 7, f_text("Dividend handling", "Dividendenverwendung", "Traitement des dividendes"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 7, dividendModeText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 8, f_text("Profit-taking rules", "Regeln für Gewinnmitnahmen", "Règles de prise de bénéfices"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 8, profitTakingText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 9, f_text("Total contributed", "Insgesamt eingezahlt", "Total versé"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 9, externalDepositsText,
                 bgcolor = valueBg,
                 text_color = inflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 10, f_text("Net dividends received", "Nettodividenden erhalten", "Dividendes nets reçus"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 10, dividendReceivedText,
                 bgcolor = valueBg,
                 text_color = inflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 11, f_text("Sales / net proceeds", "Verkäufe / Nettoerlöse", "Ventes / produits nets"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 11, salesText,
                 bgcolor = valueBg,
                 text_color = inflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 12, f_text("Total cash credited", "Cash-Zuflüsse gesamt", "Entrées de liquidités totales"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 12, f_money(totalCashInflows),
                 bgcolor = valueBg,
                 text_color = inflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 13, f_text("Purchases including costs", "Käufe einschließlich Kosten", "Achats frais inclus"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 13, purchaseOutflowsText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 14, f_text("Cash in savings account", "Cash im Sparplankonto", "Liquidités du plan"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 14, mobileCashText,
                 bgcolor = valueBg,
                 text_color = outstandingBrokerCosts > accountingTolerance ? color.red : cashColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 15, f_text("Ledger check", "Buchhaltungsprüfung", "Contrôle comptable"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 15, accountingText,
                 bgcolor = valueBg,
                 text_color = accountingColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 16, f_text("Cash share of portfolio", "Cashanteil am Portfolio", "Part de liquidités du portefeuille"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 16, na(cashRatioPct) ? "-" : f_percent(cashRatioPct),
                 bgcolor = valueBg,
                 text_color = cashColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 17, f_text("Units currently held", "Aktuell gehaltene Anteile", "Unités actuellement détenues"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 17, heldQtyText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 18, f_text("Cost basis of holdings", "Kostenbasis des Bestands", "Coût de base des positions"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 18, currentCostBasisText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 19, f_text("Current market value", "Aktueller Marktwert", "Valeur de marché actuelle"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 19, f_money(marketValue),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 20, f_text("Total portfolio value", "Gesamter Portfoliowert", "Valeur totale du portefeuille"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 20, f_money(portfolioValue),
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 21, f_text("Purchases made", "Ausgeführte Käufe", "Achats exécutés"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 21, buyCountText,
                 bgcolor = valueBg,
                 text_color = textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 22, f_text("Average cost per unit", "Ø Kaufpreis je Anteil", "Coût moyen par unité"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 22, na(averagePurchasePrice) ? "-" : f_money(averagePurchasePrice),
                 bgcolor = valueBg,
                 text_color = color.yellow,
                 text_size = size.small)

            table.cell(dashboard, 0, 23, f_text("Realized profit after costs", "Realisierter Gewinn nach Kosten", "Gain réalisé après frais"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 23, f_money(realizedProfit),
                 bgcolor = valueBg,
                 text_color = realizedColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 24, f_text("Unrealized profit", "Unrealisierter Gewinn", "Gain latent"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 24, f_money(unrealizedProfit),
                 bgcolor = valueBg,
                 text_color = unrealizedColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 25, f_text("Unrealized return on holdings", "Unrealisierte Bestandsrendite", "Rendement latent des positions"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 25, na(unrealizedProfitPct) ? "-" : f_percent(unrealizedProfitPct),
                 bgcolor = valueBg,
                 text_color = unrealizedColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 26, f_text("Total profit after costs", "Gesamtgewinn nach Kosten", "Gain total après frais"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 26, f_money(totalProfit),
                 bgcolor = valueBg,
                 text_color = totalProfitColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 27, f_text("Cumulative return on deposits", "Kumulative Rendite auf Einzahlungen", "Rendement cumulé sur apports"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 27, na(totalReturnOnDepositsPct) ? "-" : f_percent(totalReturnOnDepositsPct),
                 bgcolor = valueBg,
                 text_color = totalProfitColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 28, f_text("Annualized return (XIRR)", "Annualisierte Jahresrendite (XIRR)", "Rendement annualisé (XIRR)"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 28, na(annualMoneyWeightedReturn) ? "-" : f_percent(annualMoneyWeightedReturn * 100.0),
                 bgcolor = valueBg,
                 text_color = xirrColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 29, f_text("Monthly equivalent of annualized return", "Monatsäquivalent der Jahresrendite", "Équivalent mensuel du rendement annualisé"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 29, na(monthlyMoneyWeightedEquivalent) ? "-" : f_percent(monthlyMoneyWeightedEquivalent * 100.0),
                 bgcolor = valueBg,
                 text_color = na(monthlyMoneyWeightedEquivalent) ? textColor : monthlyMoneyWeightedEquivalent >= 0.0 ? color.lime : color.red,
                 text_size = size.small)

            table.cell(dashboard, 0, 30, f_text("Current price drawdown from high", "Aktueller Kursrückgang vom Hoch", "Baisse actuelle depuis le sommet"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 30, na(currentDrawdownPct) ? "-" : f_percent(currentDrawdownPct),
                 bgcolor = valueBg,
                 text_color = na(currentDrawdownPct) ? textColor : currentDrawdownPct < 0.0 ? color.red : textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 31, f_text("Manual / automatic modes", "Manuell-/Auto-Modi", "Modes manuel / automatique"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 31, automationModeText,
                 bgcolor = valueBg,
                 text_color = automationActiveInput ? color.aqua : textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 32, f_text("Auto model status", "Status des Auto-Modells", "État du modèle auto"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 32, autoLearningText,
                 bgcolor = valueBg,
                 text_color = not automationActiveInput ? textColor : autoModelConfidence >= 1.0 ? color.lime : color.orange,
                 text_size = size.small)

            table.cell(dashboard, 0, 33, f_text("Active dip thresholds", "Aktive Dip-Schwellen", "Seuils de baisse actifs"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 33, effectiveDipLevelsText,
                 bgcolor = valueBg,
                 text_color = color.teal,
                 text_size = size.small)

            table.cell(dashboard, 0, 34, f_text("Active dip purchase sizes", "Aktive Dip-Kaufgrößen", "Tailles d’achat actives"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 34, effectiveDipSizingText,
                 bgcolor = valueBg,
                 text_color = color.teal,
                 text_size = size.small)

            table.cell(dashboard, 0, 35, f_text("Active auto profit-taking", "Aktive Auto-Gewinnmitnahme", "Prise de bénéfices auto active"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 35, effectiveAutoProfitText,
                 bgcolor = valueBg,
                 text_color = useAutoProfitInput ? color.orange : textColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 36, f_text("Trading costs", "Handelskosten", "Frais de transaction"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 36, transactionCostText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 37, f_text("Broker / custody fees", "Broker- / Depotkosten", "Frais de courtage / garde"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 37, brokerCostText,
                 bgcolor = valueBg,
                 text_color = outstandingBrokerCosts > accountingTolerance ? color.red : outflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 38, f_text("Dividend taxes / fees", "Dividendensteuern / -gebühren", "Taxes / frais sur dividendes"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 38, dividendCostText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.small)

            table.cell(dashboard, 0, 39, f_text("Total costs deducted", "Abgezogene Gesamtkosten", "Total des frais déduits"),
                 bgcolor = labelBg,
                 text_color = textColor,
                 text_size = size.small)
            table.cell(dashboard, 1, 39, totalCostText,
                 bgcolor = valueBg,
                 text_color = outflowColor,
                 text_size = size.small)
    else
        for row = 0 to dashboardRowCount - 1
            table.cell(dashboard, 0, row, "", bgcolor = color.new(color.black, 100))
            table.cell(dashboard, 1, row, "", bgcolor = color.new(color.black, 100))
````
