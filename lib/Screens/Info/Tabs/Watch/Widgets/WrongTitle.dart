import 'package:dantotsu/Adaptor/Media/MediaAdaptor.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../../../DataClass/Media.dart';
import '../../../../../Widgets/CustomBottomDialog.dart';
import '../../../../../api/Mangayomi/Eval/dart/model/m_manga.dart';
import '../../../../../api/Mangayomi/Eval/dart/model/m_pages.dart';
import '../../../../../api/Mangayomi/Model/Source.dart';
import '../../../../../api/Mangayomi/Search/search.dart';

class WrongTitleDialog extends StatefulWidget {
  final Source source;
  final Rxn<MManga?>? selectedMedia;
  final Media mediaData;
  final Function(MManga)? onChanged;

  const WrongTitleDialog({
    super.key,
    required this.source,
    required this.mediaData,
    this.selectedMedia,
    this.onChanged,
  });

  @override
  WrongTitleDialogState createState() => WrongTitleDialogState();
}

class WrongTitleDialogState extends State<WrongTitleDialog> {
  final TextEditingController textEditingController = TextEditingController();
  late Future<MPages?> searchFuture;

  @override
  void initState() {
    super.initState();
    final initialSearchText = widget.selectedMedia?.value?.name ??  widget.mediaData.mainName(); '';
    textEditingController.text = initialSearchText;
    searchFuture = _performSearch(initialSearchText);
  }

  Future<MPages?> _performSearch(String query) {
    return search(
      source: widget.source,
      page: 1,
      query: query,
      filterList: [],
    );
  }

  void _onSubmitted(String value) {
    setState(() {
      searchFuture = _performSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return CustomBottomDialog(
      title: widget.source.name,
      viewList: [
        _buildSearchInput(theme),
        const SizedBox(height: 16.0),
        FutureBuilder<MPages?>(
          future: searchFuture,
          builder: (context, snapshot) {
            return _buildResultList(snapshot, theme);
          },
        ),
      ],
    );
  }

  Widget _buildSearchInput(ColorScheme theme) {
    return TextField(
      controller: textEditingController,
      onSubmitted: _onSubmitted,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        color: theme.onSurface,
      ),
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.search, color: theme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(
            color: theme.primaryContainer,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildResultList(AsyncSnapshot<MPages?> snapshot, ColorScheme theme) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No results found',
          style: TextStyle(
            color: theme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final mediaList = snapshot.data!.list.map((e) {
      return Media(
        id: e.hashCode,
        name: e.name,
        cover: e.imageUrl,
        nameRomaji: e.name ?? '',
        userPreferredName: e.name ?? '',
        isAdult: false,
        minimal: true,
      );
    }).toList();

    return MediaAdaptor(
      type: 3,
      mediaList: mediaList,
      onMediaTap: (i) {
        widget.onChanged?.call(snapshot.data!.list[i]);
        Navigator.of(context).pop();
      },
    );
  }
}
