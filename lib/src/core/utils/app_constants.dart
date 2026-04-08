class AppConstants {
  AppConstants._();

  static const defaultLeagueId = 7; // English Premier League

  static const List<int> availableLeagues = [
    // Top 5 European Leagues
    7, // English Premier League
    11, // La Liga
    17, // Serie A
    25, // Bundesliga
    35, // Ligue 1

    // Other Major Leagues
    552, // Egyptian Premier League
    73, // Liga Portugal
    57, // Eredivisie
    649, // Saudi Pro League

    // European Cups
    572, // UEFA Champions League
    573, // UEFA Europa League

    // International Competitions
    570, // Friendly International
    321, // Club Friendlies
    595, // FIFA World Cup Qualification
    5930, // FIFA World Cup
    9034, // FIFA Series
    322, // Euro U21 Qualification
    591, // Euro U21
    588, // Africa Cup of Nations Qualification
    167, // Africa Cup of Nations (AFCON)
    5788, // World Cup Playoff Tournament
  ];

  static const apiBaseUrl = 'https://webws.365scores.com/web';
  static const baseImageUrl = 'https://imagecache.365scores.com/image/upload/';

  static String clubImage(String clubId, {String size = '24'}) {
    return '${baseImageUrl}f_png,w_$size,h_$size,c_limit,q_auto:eco,dpr_3,d_Competitors:default1.png/v7/Competitors/$clubId';
  }

  static String competitionImage(int competitionId, {String size = '24'}) {
    return '${baseImageUrl}f_png,w_$size,h_$size,c_limit,q_auto:eco,dpr_3,d_Countries:default1.png/v7/Competitions/$competitionId';
  }
}
