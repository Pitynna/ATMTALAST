// Commodity market and NPC traders (ideas from Goonstation 13, code written anew).

/// How many past prices each commodity keeps.
#define COMMODITY_HISTORY_LENGTH 12
/// Least time between two market shifts.
#define MARKET_SHIFT_MIN (15 MINUTES)
/// Most time between two market shifts.
#define MARKET_SHIFT_MAX (20 MINUTES)
/// Lowest multiplier market prices can give to quest rewards.
#define MARKET_QUEST_MIN 0.75
/// Highest multiplier market prices can give to quest rewards.
#define MARKET_QUEST_MAX 1.3

#define COMMODITY_MINERALS "Minerals"
#define COMMODITY_ORES "Ores"
#define COMMODITY_FOOD "Food"
#define COMMODITY_MEDICAL "Medical"
#define COMMODITY_ENGINEERING "Engineering"
#define COMMODITY_TEXTILES "Textiles"
#define COMMODITY_SCIENCE "Science"
#define COMMODITY_CONTRABAND "Contraband"
