import 'dart:convert';
import 'dart:math';

import 'package:dantotsu/Functions/Function.dart';
import 'package:dantotsu/Preferences/Preferences.dart';
import 'package:dantotsu/api/Anilist/Anilist.dart';
import 'package:flutter_qjs/quickjs/ffi.dart';

import '../../DataClass/Author.dart';
import '../../DataClass/Character.dart';
import '../../DataClass/Media.dart';
import '../../DataClass/SearchResults.dart';
import '../../DataClass/User.dart';
import '../../Preferences/PrefManager.dart';
import 'Data/data.dart';
import 'Data/media.dart' as api;
import 'Data/page.dart';
import 'Data/staff.dart';


part 'AnilistQueries/GetBannerImages.dart';
part 'AnilistQueries/GetHomePageData.dart';
part 'AnilistQueries/GetMediaData.dart';
part 'AnilistQueries/GetMediaDetails.dart';
part 'AnilistQueries/GetUserData.dart';
part 'AnilistQueries/Search.dart';
part 'AnilistQueries/GetAnimeMangaListData.dart';
part 'AnilistQueries/GetUserMediaList.dart';
part 'AnilistQueries/GetGenresAndTags.dart';
part 'AnilistQueries/GetCalendarData.dart';

class AnilistQueries {
  // main function in the [Anilist.dart]
  final Future<T?> Function<T>(String query,
      {String variables, bool force, bool useToken, bool show}) executeQuery;

  AnilistQueries(this.executeQuery);

  /// Fetches user data and returns a [bool] indicating success.
  Future<bool> getUserData() => _getUserData();

  /// Retrieves media details for the given [id].
  ///
  /// If [mal] is true, it will use MyAnimeList's mapping for the ID.
  /// Returns a [Media] object if found.
  Future<Media?> getMedia(int id, {bool mal = true}) => _getMedia(id, mal: mal);

  /// Fetches additional media details for the provided [media] object.
  /// Returns an updated [media] object.
  Future<Media?> mediaDetails(Media media) => _mediaDetails(media);

  /// Initializes and returns media data for the homepage in the form of a map.
  /// The keys are section names, and values are lists of [Media] objects.
  Future<Map<String, List<Media>>> initHomePage() => _initHomePage();

  /// Fetches Genres and Tags data.
  /// Returns a [bool] indicating success.
  Future<bool> getGenresAndTags() => _getGenresAndTags();

  /// Fetches the user's media lists.
  ///
  /// Required:
  /// - [anime]: If true, fetches anime lists. If false, fetches manga lists.
  /// - [userId]: The user's ID.
  /// - [sortOrder]: Sort order for the lists.
  /// Returns a map where the keys are list categories and values are lists of [Media] objects.
  Future<Map<String, List<Media>>> getMediaLists({
    required bool anime,
    required int userId,
    String? sortOrder,
  }) =>
      _getMediaLists(
      anime: anime,
      userId: userId,
      sortOrder: sortOrder,
  );

  /// Retrieves a list of banner image URLs for the homepage.
  /// Returns a list of [String] representing the URLs.
  Future<List<String?>> getBannerImages() => _getBannerImages();

  /// Fetches the user's anime list.
  /// Returns a map where the keys are list categories and values are lists of [Media] objects.
  Future<Map<String, List<Media>>> getAnimeList() => _getAnimeList();

  /// Fetches the user's manga list.
  /// Returns a map where the keys are list categories and values are lists of [Media] objects.
  Future<Map<String, List<Media>>> getMangaList() => _getMangaList();

  /// Fetches the user's calender data.
  /// Returns a list of [Media] objects.
  Future<List<Media>> getCalendarData() => _getCalendarData();

  /// Searches for media based on various parameters.
  ///
  /// Required:
  /// - [type]: Type of media (e.g., anime, manga).
  ///
  /// Optional:
  /// - [page], [perPage]: Pagination options.
  /// - [search]: Search query.
  /// - [sort]: Sorting method.
  /// - [genres], [tags]: Filters by genre or tag.
  /// - [status], [source], [format], [countryOfOrigin]: Additional filters.
  /// - [isAdult]: Include adult content if true.
  /// - [onList]: If true, only media on the user's list is included.
  /// - [excludedGenres], [excludedTags]: Exclude specific genres or tags.
  /// - [startYear], [seasonYear], [season]: Filter by year or season.
  /// - [id]: Specific media ID.
  /// - [hd], [adultOnly]: Additional display and filtering options.
  ///
  /// Returns a [SearchResults] object containing the search results.
  Future<SearchResults?> search({
    required String type,
    int? page,
    int? perPage,
    String? search,
    String? sort,
    List<String>? genres,
    List<String>? tags,
    String? status,
    String? source,
    String? format,
    String? countryOfOrigin,
    bool isAdult = false,
    bool? onList,
    List<String>? excludedGenres,
    List<String>? excludedTags,
    int? startYear,
    int? seasonYear,
    String? season,
    int? id,
    bool hd = false,
  }) =>
      _search(
        type: type,
        page: page,
        perPage: perPage,
        search: search,
        sort: sort,
        genres: genres,
        tags: tags,
        status: status,
        source: source,
        format: format,
        countryOfOrigin: countryOfOrigin,
        isAdult: isAdult,
        onList: onList,
        excludedGenres: excludedGenres,
        excludedTags: excludedTags,
        startYear: startYear,
        seasonYear: seasonYear,
        season: season,
        id: id,
        hd: hd,
      );
}
