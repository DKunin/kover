import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/models/user_model.dart';
import 'package:kover/models/want_to_find_model.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/riverpod/providers/want_to_find.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/utils/logging.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:kover/widgets/lists/adaptive_sliver_grid.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class WantToFindPage extends StatelessWidget {
  const WantToFindPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBody: true,
      body: LoginGuard(child: _WantToFindPageContent()),
    );
  }
}

class _WantToFindPageContent extends ConsumerWidget {
  const _WantToFindPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(wantToFindListProvider);
    final isReadOnly = ref.watch(
      currentUserProvider.select(
        (user) => user.value?.isReadOnly ?? true,
      ),
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(wantToFindListProvider);
        await ref.read(wantToFindListProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: Text(l.wantToFind),
            actions: [
              if (!isReadOnly)
                IconButton(
                  tooltip: l.wantToFindAdd,
                  icon: const Icon(KoverIcons.add),
                  onPressed: () => _editItem(context),
                ),
            ],
          ),
          AsyncSliver(
            asyncValue: items,
            data: (data) {
              if (data.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyWantToFind(
                    onAdd: isReadOnly ? null : () => _editItem(context),
                  ),
                );
              }

              return SliverPadding(
                padding: LayoutConstants.smallEdgeInsets,
                sliver: AdaptiveSliverGrid(
                  itemCount: data.length,
                  compactCrossAxisCount: 3,
                  childAspectRatio: 0.54,
                  mainAxisSpacing: LayoutConstants.smallPadding,
                  crossAxisSpacing: LayoutConstants.smallPadding,
                  builder: (context, index) => _WantToFindCard(
                    item: data[index],
                    isReadOnly: isReadOnly,
                    onResolve: () => _resolveItem(context, data[index]),
                    onEdit: () => _editItem(context, data[index]),
                    onDelete: () => _deleteItem(context, ref, data[index]),
                  ),
                ),
              );
            },
          ),
          const SliverBottomPadding(),
        ],
      ),
    );
  }
}

class _EmptyWantToFind extends StatelessWidget {
  const _EmptyWantToFind({this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: LayoutConstants.largeEdgeInsets,
      child: Column(
        mainAxisAlignment: .center,
        spacing: LayoutConstants.mediumPadding,
        children: [
          const Icon(KoverIcons.wantToFind, size: LayoutConstants.largestIcon),
          Text(
            l.wantToFindEmptyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: .center,
          ),
          Text(l.wantToFindEmptyDescription, textAlign: .center),
          if (onAdd != null)
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(KoverIcons.add),
              label: Text(l.wantToFindAdd),
            ),
        ],
      ),
    );
  }
}

enum _CardAction { resolve, edit, openSource, delete }

class _WantToFindCard extends StatelessWidget {
  const _WantToFindCard({
    required this.item,
    required this.isReadOnly,
    required this.onResolve,
    required this.onEdit,
    required this.onDelete,
  });

  final WantToFindModel item;
  final bool isReadOnly;
  final VoidCallback onResolve;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final coverUri = Uri.tryParse(item.coverUrl ?? '');
    final parsedSourceUri = Uri.tryParse(item.sourceUrl ?? '');
    final sourceUri = parsedSourceUri?.hasScheme ?? false
        ? parsedSourceUri
        : null;

    return Card.filled(
      clipBehavior: .antiAlias,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: isReadOnly ? null : onResolve,
              child: coverUri == null || !coverUri.hasScheme
                  ? const _CoverPlaceholder()
                  : Image.network(
                      coverUri.toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CoverPlaceholder(),
                    ),
            ),
          ),
          if (item.authors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LayoutConstants.smallPadding,
                LayoutConstants.smallPadding,
                LayoutConstants.smallPadding,
                0,
              ),
              child: Text(
                item.authors,
                maxLines: 2,
                overflow: .ellipsis,
                textAlign: .center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: LayoutConstants.smallEdgeInsets,
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: .ellipsis,
                    textAlign: .center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              if (!isReadOnly || sourceUri != null)
                PopupMenuButton<_CardAction>(
                  onSelected: (action) async {
                    switch (action) {
                      case .resolve:
                        onResolve();
                      case .edit:
                        onEdit();
                      case .openSource:
                        if (sourceUri != null) {
                          await launchUrl(
                            sourceUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      case .delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isReadOnly)
                      PopupMenuItem(
                        value: .resolve,
                        child: ListTile(
                          leading: const Icon(KoverIcons.markRead),
                          title: Text(l.wantToFindMarkFound),
                        ),
                      ),
                    if (!isReadOnly)
                      PopupMenuItem(
                        value: .edit,
                        child: ListTile(
                          leading: const Icon(KoverIcons.edit),
                          title: Text(l.wantToFindEdit),
                        ),
                      ),
                    if (sourceUri != null)
                      PopupMenuItem(
                        value: .openSource,
                        child: ListTile(
                          leading: const Icon(KoverIcons.externalLink),
                          title: Text(l.wantToFindOpenSource),
                        ),
                      ),
                    if (!isReadOnly)
                      PopupMenuItem(
                        value: .delete,
                        child: ListTile(
                          leading: Icon(
                            KoverIcons.trash,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(l.wantToFindDelete),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(
          KoverIcons.coverPlaceholder,
          size: LayoutConstants.largeIcon,
        ),
      ),
    );
  }
}

Future<void> _editItem(BuildContext context, [WantToFindModel? item]) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _WantToFindEditor(item: item),
  );
  if (saved != true || !context.mounted) return;
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(item == null ? l.wantToFindCreated : l.wantToFindUpdated),
    ),
  );
}

Future<void> _resolveItem(
  BuildContext context,
  WantToFindModel item,
) async {
  final resolved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ResolveWantToFind(item: item),
  );
  if (resolved != true || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).wantToFindResolved)),
  );
}

Future<void> _deleteItem(
  BuildContext context,
  WidgetRef ref,
  WantToFindModel item,
) async {
  final l = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.wantToFindDelete),
      content: Text(l.wantToFindDeleteConfirm(item.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.wantToFindDelete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(wantToFindListProvider.notifier).delete(item.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.wantToFindDeleted)),
    );
  } catch (error) {
    if (!context.mounted) return;
    _showFailure(context, error);
  }
}

class _WantToFindEditor extends HookConsumerWidget {
  const _WantToFindEditor({this.item});

  final WantToFindModel? item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final title = useTextEditingController(text: item?.title);
    final authors = useTextEditingController(text: item?.authors);
    final summary = useTextEditingController(text: item?.summary);
    final isbn = useTextEditingController(text: item?.isbn);
    final externalId = useTextEditingController(text: item?.externalId);
    final coverUrl = useTextEditingController(text: item?.coverUrl);
    final sourceUrl = useTextEditingController(text: item?.sourceUrl);
    final notes = useTextEditingController(text: item?.notes);
    final saving = useState(false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: .stretch,
            spacing: LayoutConstants.smallPadding,
            children: [
              Text(
                item == null ? l.wantToFindCreateTitle : l.wantToFindEditTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                controller: title,
                autofocus: true,
                maxLength: 256,
                decoration: InputDecoration(labelText: l.wantToFindTitleLabel),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l.wantToFindTitleRequired
                    : null,
              ),
              TextFormField(
                controller: authors,
                maxLength: 1024,
                decoration: InputDecoration(
                  labelText: l.wantToFindAuthorsLabel,
                ),
              ),
              TextFormField(
                controller: summary,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l.summary),
              ),
              TextFormField(
                controller: isbn,
                maxLength: 64,
                decoration: InputDecoration(labelText: l.wantToFindIsbnLabel),
              ),
              TextFormField(
                controller: externalId,
                maxLength: 256,
                decoration: InputDecoration(
                  labelText: l.wantToFindExternalIdLabel,
                ),
              ),
              TextFormField(
                controller: coverUrl,
                maxLength: 2048,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.wantToFindCoverUrlLabel,
                ),
                validator: (value) => _validateOptionalHttpUrl(value, l),
              ),
              TextFormField(
                controller: sourceUrl,
                maxLength: 2048,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.wantToFindSourceUrlLabel,
                ),
                validator: (value) => _validateOptionalHttpUrl(value, l),
              ),
              TextFormField(
                controller: notes,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l.wantToFindNotesLabel),
              ),
              Row(
                mainAxisAlignment: .end,
                spacing: LayoutConstants.smallPadding,
                children: [
                  TextButton(
                    onPressed: saving.value
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(l.cancel),
                  ),
                  FilledButton(
                    onPressed: saving.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            saving.value = true;
                            try {
                              await ref
                                  .read(wantToFindListProvider.notifier)
                                  .save(
                                    existing: item,
                                    draft: WantToFindDraft(
                                      title: title.text,
                                      authors: authors.text,
                                      summary: summary.text,
                                      isbn: isbn.text,
                                      externalId: externalId.text,
                                      coverUrl: coverUrl.text,
                                      sourceUrl: sourceUrl.text,
                                      notes: notes.text,
                                    ),
                                  );
                              if (context.mounted) Navigator.pop(context, true);
                            } catch (error) {
                              if (context.mounted) _showFailure(context, error);
                            } finally {
                              if (context.mounted) saving.value = false;
                            }
                          },
                    child: Text(l.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResolveWantToFind extends HookConsumerWidget {
  const _ResolveWantToFind({required this.item});

  final WantToFindModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final query = useTextEditingController(text: item.title);
    useListenable(query);
    final results = ref.watch(searchSeriesProvider(query.text));
    final selected = useState<SeriesModel?>(null);
    final addToWantToRead = useState(true);
    final saving = useState(false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: LayoutConstants.mediumEdgeInsets,
        child: Column(
          crossAxisAlignment: .stretch,
          spacing: LayoutConstants.smallPadding,
          children: [
            Text(
              l.wantToFindResolveTitle(item.title),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(l.wantToFindResolveDescription),
            TextField(
              controller: query,
              decoration: InputDecoration(
                labelText: l.wantToFindMatchedSeriesLabel,
                prefixIcon: const Icon(KoverIcons.search),
              ),
            ),
            Async(
              asyncValue: results,
              data: (series) => ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: series.length,
                  itemBuilder: (context, index) {
                    final candidate = series[index];
                    final isSelected = selected.value?.id == candidate.id;
                    return ListTile(
                      selected: isSelected,
                      leading: SizedBox.square(
                        dimension: LayoutConstants.largestIcon,
                        child: SeriesCoverImage(seriesId: candidate.id),
                      ),
                      title: Text(candidate.name),
                      trailing: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      onTap: () => selected.value = candidate,
                    );
                  },
                ),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: addToWantToRead.value,
              title: Text(l.wantToFindAddToWantToRead),
              onChanged: saving.value
                  ? null
                  : (value) => addToWantToRead.value = value ?? true,
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: LayoutConstants.smallPadding,
              children: [
                TextButton(
                  onPressed: saving.value ? null : () => Navigator.pop(context),
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: saving.value || selected.value == null
                      ? null
                      : () async {
                          saving.value = true;
                          try {
                            await ref
                                .read(wantToFindListProvider.notifier)
                                .resolve(
                                  wantToFindId: item.id,
                                  seriesId: selected.value!.id,
                                  addToWantToRead: addToWantToRead.value,
                                );
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (error) {
                            if (context.mounted) _showFailure(context, error);
                          } finally {
                            if (context.mounted) saving.value = false;
                          }
                        },
                  child: Text(l.wantToFindMarkFound),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String? _validateOptionalHttpUrl(String? value, AppLocalizations l) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) return null;
  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      !uri.hasAuthority ||
      !{'http', 'https'}.contains(uri.scheme)) {
    return l.wantToFindInvalidUrl;
  }
  return null;
}

void _showFailure(BuildContext context, Object error) {
  log.warning(
    'Want To Find mutation failed',
    attributes: {'error': error.toString()},
  );
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).wantToFindFailure),
      ),
    );
}
