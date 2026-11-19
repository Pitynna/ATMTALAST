// Galactic stock exchange (idea from Goonstation 13, code written anew).

/// Name of the newscaster channel that carries market news.
#define NEWS_CHANNEL_STOCKS "Галактическая биржевая лента"
	#define EDITOR_STOCKS "Редакция биржевой ленты"

/// How many price points each company keeps for its chart.
#define STOCK_HISTORY_LENGTH 90
/// How many articles the exchange keeps in its news feed.
#define STOCK_NEWS_LENGTH 40
/// How many trade log lines a portfolio keeps.
#define STOCK_LOG_LENGTH 20
/// How many companies are listed at round start.
#define STOCK_COMPANY_COUNT 9
/// Lowest possible share price.
#define STOCK_MIN_PRICE 1
/// Exchange fee charged on every buy and sell, in percent of the deal.
#define STOCK_TRADE_FEE 1.5
/// Fewest credits taken as a fee for any deal.
#define STOCK_MIN_FEE 5
/// Most shares in one buy or sell order.
#define STOCK_MAX_ORDER 5000

/// Share of the collateral value that can be borrowed on margin.
#define STOCK_LOAN_LTV 0.5
/// Above this debt to collateral ratio holdings get sold off.
#define STOCK_LOAN_MARGIN_CALL 0.75
/// Interest added to the loan debt every exchange tick, in percent.
#define STOCK_LOAN_INTEREST 0.1
/// Most credits one account can owe on margin.
#define STOCK_LOAN_CAP 100000

/// Most broker offers per company at once.
#define STOCK_MAX_BROKER_OFFERS 2

// Event phases shown in the UI.
#define STOCK_EVENT_HIDDEN 0
#define STOCK_EVENT_VISIBLE 1
#define STOCK_EVENT_DONE 2

// How much an article is worth to the newscaster.
/// Only the exchange console shows it.
#define STOCK_NEWS_MINOR 0
/// Posted to the newscaster channel.
#define STOCK_NEWS_POSTED 1
/// Posted and newscasters announce it.
#define STOCK_NEWS_ALERT 2
