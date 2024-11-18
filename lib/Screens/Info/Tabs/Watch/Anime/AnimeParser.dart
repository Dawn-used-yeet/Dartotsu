import 'package:dantotsu/Screens/Info/Tabs/Watch/BaseParser.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../../../DataClass/Episode.dart';
import '../../../../../DataClass/Media.dart';
import '../../../../../Preferences/PrefManager.dart';
import '../../../../../Preferences/Preferences.dart';
import '../../../../../api/EpisodeDetails/Anify/Anify.dart';
import '../../../../../api/EpisodeDetails/Jikan/Jikan.dart';
import '../../../../../api/EpisodeDetails/Kitsu/Kitsu.dart';
import '../../../../../api/Mangayomi/Eval/dart/model/m_chapter.dart';
import '../../../../../api/Mangayomi/Eval/dart/model/m_manga.dart';
import '../../../../../api/Mangayomi/Model/Source.dart';
import '../../../../../api/Mangayomi/Search/get_detail.dart';
import '../Functions/ParseChapterNumber.dart';

class AnimeParser extends BaseParser {
  var episodeList = Rxn<Map<String, Episode>>(null);
  var anifyEpisodeList = Rxn<Map<String, Episode>>(null);
  var kitsuEpisodeList = Rxn<Map<String, Episode>>(null);
  var fillerEpisodesList = Rxn<Map<String, Episode>>(null);
  var viewType = 0.obs;
  var dataLoaded = false.obs;


  void init(Media mediaData) async {
    if (dataLoaded.value) return;
    viewType.value = mediaData.selected?.recyclerStyle ??
        PrefManager.getVal(PrefName.AnimeDefaultView);
    await Future.wait([
      getEpisodeData(mediaData),
      getFillerEpisodes(mediaData),
    ]);
  }

  @override
  Future<void> wrongTitle(context, mediaData, onChange) async {
    super.wrongTitle(context, mediaData, (m) {
      episodeList.value = null;
      getEpisode(m, source.value!);
    });
  }

  @override
  Future<void> searchMedia(source, mediaData, {onFinish}) async {
    episodeList.value = null;
    super.searchMedia(source, mediaData, onFinish: (r) => getEpisode(r, source));
  }

  void getEpisode(MManga media, Source source) async {
    if (media.link == null) return;
    var m = await getDetail(url: media.link!, source: source);
    dataLoaded.value = true;
    var chapters = m.chapters;
    episodeList.value = Map.fromEntries(
      chapters?.reversed.map((e) {
          final episode = MChapterToEpisode(e, media);
          return MapEntry(episode.number, episode);
        },
      ) ?? [],
    );
  }

  var episodeDataLoaded = false.obs;

  Future<void> getEpisodeData(Media mediaData) async {
    var a = await Anify.fetchAndParseMetadata(mediaData);
    var k = await Kitsu.getKitsuEpisodesDetails(mediaData);
    anifyEpisodeList.value ??= a;
    kitsuEpisodeList.value ??= k;
    episodeDataLoaded.value = true;
  }

  Future<void> getFillerEpisodes(Media mediaData) async {
    var res = await Jikan.getEpisodes(mediaData);
    fillerEpisodesList.value ??= res;
  }

  Episode MChapterToEpisode(MChapter chapter, MManga? selectedMedia) {
    var episodeNumber = ChapterRecognition.parseChapterNumber(selectedMedia?.name ?? '', chapter.name ?? '');
    return Episode(
      number: episodeNumber != -1 ? episodeNumber.toString() : chapter.name ?? '',
      link: chapter.url,
      title: chapter.name,
      thumb: null,
      desc: null,
      filler: false,
      mChapter: chapter,
    );
  }
}

