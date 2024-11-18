import 'dart:convert';
import 'package:dantotsu/api/Anilist/Data/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../Functions/Function.dart';
import '../../Preferences/PrefManager.dart';
import '../../Preferences/Preferences.dart';
import '../../Widgets/CustomBottomDialog.dart';
import 'AnilistMutations.dart';
import 'AnilistQueries.dart';
import 'AnilistViewModel.dart';
import 'Login.dart' as anilist_login;

var Anilist = Get.put(_AnilistController());

class _AnilistController extends GetxController { // TODO: better login page
  late final AnilistQueries query;
  late final AnilistMutations mutation;

  var token = "".obs;
  var username= "".obs;
  int? userid;
  var avatar = "".obs;
  String? bg;
  int? episodesWatched;
  int? chapterRead;
  int unreadNotificationCount = 0;
  List<String>? genres;
  Map<bool, List<String>>? tags;
  int rateLimitReset = 0;
  var isInitialized = false.obs;
  var run = true.obs;
  bool adult = false;
  String? titleLanguage;
  String? staffNameLanguage;
  bool airingNotifications = false;
  bool restrictMessagesToFollowing = false;
  String? scoreFormat;
  String? rowOrder;
  int? activityMergeTime;
  String? timezone;
  List<String>? animeCustomLists;
  List<String>? mangaCustomLists;

  final List<String> sortBy = [
    "SCORE_DESC", "POPULARITY_DESC", "TRENDING_DESC", "START_DATE_DESC",
    "TITLE_ENGLISH", "TITLE_ENGLISH_DESC", "SCORE"
  ];

  final List<String> authorRoles = ["Original Creator", "Story & Art", "Story"];
  final List<String> seasons = ["WINTER", "SPRING", "SUMMER", "FALL"];
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  _AnilistController() {
    query = AnilistQueries(_executeQuery);
    mutation = AnilistMutations(_executeQuery);
  }

  int get currentSeason {
    if (currentMonth <= 2) return 0;
    if (currentMonth <= 5) return 1;
    if (currentMonth <= 8) return 2;
    if (currentMonth <= 11) return 3;
    return 0;
  }

  Map<String, int> getSeason(bool next) {
    int season = currentSeason + (next ? 0 : -2);
    int year = currentYear;
    if (season > 3) { season = 0; year++; }
    if (season < 0) { season = 3; year--; }
    return {seasons[season]: year};
  }

  List<Map<String, int>> get currentSeasons => [
    getSeason(false),
    {seasons[currentSeason - 1]: currentYear},
    getSeason(true),
  ];

  bool getSavedToken() {
    token.value = PrefManager.getVal(PrefName.anilistToken);
    return token.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    PrefManager.setVal(PrefName.anilistToken, token);
    this.token.value = token;
    run.value = true;
    isInitialized.value = false;
    Refresh.allButNot(1);
  }
  void login(BuildContext context){
    showCustomBottomDialog(context, anilist_login.login(context));
  }
  void removeSavedToken() {
    token.value = '';
    username.value = '';
    adult = false;
    userid = null;
    avatar.value = '';
    bg = null;
    episodesWatched = null;
    chapterRead = null;
    unreadNotificationCount = 0;
    AnilistHomeViewModel.resetPageData();

    PrefManager.removeVal(PrefName.anilistToken);
    PrefManager.setCustomVal<String>("banner_ANIME_url", '');
    PrefManager.setCustomVal<String>("banner_MANGA_url", '');
    run.value = true;
    isInitialized.value = false;
    Refresh.allButNot(1);
  }

  Future<T?> _executeQuery<T>(
      String query, {
        String variables = "",
        bool force = false,
        bool useToken = true,
        bool show = true,
      }) async {
    try {
      if (rateLimitReset > DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        final secondsLeft = rateLimitReset - DateTime.now().millisecondsSinceEpoch ~/ 1000;
        snackString("Rate limited, wait ${secondsLeft}s");
        throw Exception("Rate limited, wait ${secondsLeft}s");
      }

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        if (token.isNotEmpty && useToken) 'Authorization': 'Bearer ${token.value}',
      };

      final response = await http.post(
        Uri.parse("https://graphql.anilist.co/"),
        headers: headers,
        body: jsonEncode({"query": query, "variables": variables}),
      );

      final remaining = int.parse(response.headers['x-ratelimit-remaining'] ?? '-1');
      debugPrint("Remaining requests: $remaining");

      if (response.statusCode == 429) {
        final retry = int.parse(response.headers['Retry-After'] ?? '-1');
        rateLimitReset = int.parse(response.headers['x-ratelimit-limit'] ?? '0');
        snackString("Rate limited, retry after $retry seconds");
        throw Exception("Rate limited, retry after $retry seconds");
      }

      final jsonResponse = json.decode(response.body);
      if (!response.body.startsWith("{")) {
        snackString("Anilist seems down, maybe use a VPN or wait.");
        throw Exception("Anilist API down");
      }

      if (jsonResponse.containsKey('errors')) return null;

      return TypeFactory.get<T>(jsonResponse);
    } catch (e) {
      if (show) snackString("Error fetching Anilist data: ${e.toString()}");
      return null;
    }
  }
}

typedef FromJson<T> = T Function(Map<String, dynamic> json);

class TypeFactory {
  static final Map<Type, FromJson> _factories = {};

  static void create<T>(FromJson<T> factory) => _factories[T] = factory;

  static T get<T>(Map<String, dynamic> json) {
    final factory = _factories[T];
    if (factory == null) throw Exception('Factory for type $T is not registered');
    return factory(json) as T;
  }
  static void registerAllTypes() {
    TypeFactory.create<JsonDecoder> (
            (json) => jsonDecode(json as String));
    TypeFactory.create<PageResponse>(
            (json) => PageResponse.fromJson(json));
    TypeFactory.create<MediaResponse>(
            (json) => MediaResponse.fromJson(json));
    TypeFactory.create<MediaListCollectionResponse>(
            (json) => MediaListCollectionResponse.fromJson(json));
    TypeFactory.create<ViewerResponse>(
            (json) => ViewerResponse.fromJson(json));
    TypeFactory.create<UserListResponse>(
            (json) => UserListResponse.fromJson(json));
    TypeFactory.create<AnimeListResponse>(
            (json) => AnimeListResponse.fromJson(json));
    TypeFactory.create<MangaListResponse>(
            (json) => MangaListResponse.fromJson(json));
    TypeFactory.create<UserListsResponse>(
            (json) => UserListsResponse.fromJson(json));
    TypeFactory.create<GenreCollectionResponse>(
            (json) => GenreCollectionResponse.fromJson(json));
    TypeFactory.create<MediaTagCollectionResponse>(
            (json) => MediaTagCollectionResponse.fromJson(json));
  }
}
