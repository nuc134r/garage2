import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../data/attachment_repository.dart';
import '../data/file_viewer.dart';

/// An attachment shown in the UI: already stored, or picked and waiting for the entry to be saved.
sealed class AttachmentItem {
  const AttachmentItem();

  String get name;
  String get mimeType;
  int get size;

  /// Unique per item; also the Hero tag between a thumbnail and the viewer.
  String get key;

  bool get isImage => mimeType.startsWith('image/');
}

class StoredAttachment extends AttachmentItem {
  const StoredAttachment(this.info);

  final AttachmentInfo info;

  @override
  String get name => info.name;
  @override
  String get mimeType => info.mimeType;
  @override
  int get size => info.size;
  @override
  String get key => 'attachment-${info.id}';
}

class PendingAttachment extends AttachmentItem {
  PendingAttachment({required this.name, required this.mimeType, required this.bytes});

  @override
  final String name;
  @override
  final String mimeType;
  final Uint8List bytes;

  @override
  int get size => bytes.length;
  @override
  String get key => 'attachment-pending-${identityHashCode(this)}';
}

/// Content of an item, loading it from the database for stored ones.
Future<Uint8List?> attachmentBytes(WidgetRef ref, AttachmentItem item) => switch (item) {
      StoredAttachment(:final info) => ref.read(attachmentBytesProvider(info.id).future),
      PendingAttachment(:final bytes) => Future.value(bytes),
    };

String mimeTypeFor(String name) => switch (name.split('.').last.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      'pdf' => 'application/pdf',
      'txt' => 'text/plain',
      _ => 'application/octet-stream',
    };

IconData _fileIcon(String mimeType) => switch (mimeType) {
      'application/pdf' => Icons.picture_as_pdf,
      final m when m.startsWith('image/') => Icons.image,
      final m when m.startsWith('text/') => Icons.article,
      _ => Icons.insert_drive_file,
    };

enum _Source { camera, gallery, file }

/// Asks where to take files from and returns them; files over the size limit are skipped with a message.
Future<List<PendingAttachment>> pickAttachments(BuildContext context) async {
  final l10n = context.l10n;
  final source = await showModalBottomSheet<_Source>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(l10n.attachTakePhoto),
            onTap: () => Navigator.pop(context, _Source.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.attachChoosePhotos),
            onTap: () => Navigator.pop(context, _Source.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.attachChooseFile),
            subtitle: Text(l10n.attachChooseFileHint),
            onTap: () => Navigator.pop(context, _Source.file),
          ),
        ],
      ),
    ),
  );
  if (source == null) return const [];

  final picked = <(String name, String? mime, Future<Uint8List> Function() read)>[];
  try {
    // Photos are downscaled: bills stay readable and backups stay small.
    const maxSide = 2400.0;
    const quality = 85;
    final picker = ImagePicker();
    switch (source) {
      case _Source.camera:
        final x = await picker.pickImage(source: ImageSource.camera, maxWidth: maxSide, maxHeight: maxSide, imageQuality: quality);
        if (x != null) picked.add((x.name, x.mimeType, x.readAsBytes));
      case _Source.gallery:
        final xs = await picker.pickMultiImage(maxWidth: maxSide, maxHeight: maxSide, imageQuality: quality);
        picked.addAll([for (final x in xs) (x.name, x.mimeType, x.readAsBytes)]);
      case _Source.file:
        final files = await FilePicker.pickFiles();
        picked.addAll([for (final f in files) (f.name, null, f.readAsBytes)]);
    }
  } on PlatformException catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric(e.message ?? e.code));
    return const [];
  }

  final result = <PendingAttachment>[];
  for (final (name, mime, read) in picked) {
    final bytes = await read();
    if (bytes.length > AttachmentRepository.maxSize) {
      if (context.mounted) showSnack(context, l10n.attachmentTooLarge(name, AttachmentRepository.maxSize ~/ (1024 * 1024)));
      continue;
    }
    result.add(PendingAttachment(name: name, mimeType: mime ?? mimeTypeFor(name), bytes: bytes));
  }
  return result;
}

/// Wrapping grid of attachment thumbnails, with an optional "attach" tile.
class AttachmentGrid extends StatelessWidget {
  const AttachmentGrid({super.key, required this.items, required this.onOpen, this.onAdd, this.onRemove});

  final List<AttachmentItem> items;
  final void Function(int index) onOpen;
  final VoidCallback? onAdd;

  /// Shows a remove badge on each thumbnail when set.
  final void Function(AttachmentItem item)? onRemove;

  static const size = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, item) in items.indexed)
          Stack(
            clipBehavior: Clip.none,
            children: [
              AttachmentThumb(item: item, onTap: () => onOpen(i)),
              if (onRemove != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.close),
                    onPressed: () => onRemove!(item),
                  ),
                ),
            ],
          ),
        if (onAdd != null)
          SizedBox.square(
            dimension: size,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAdd,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.attach_file),
                  const SizedBox(height: 4),
                  Text(l10n.attach, style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AttachmentThumb extends ConsumerWidget {
  const AttachmentThumb({super.key, required this.item, this.onTap});

  final AttachmentItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bytes = switch (item) {
      StoredAttachment(:final info) when item.isImage => ref.watch(attachmentBytesProvider(info.id)).value,
      PendingAttachment(:final bytes) => bytes,
      _ => null,
    };
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final Widget content = item.isImage && bytes != null
        ? Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: (AttachmentGrid.size * dpr).round(),
            errorBuilder: (_, _, _) => _FileFace(item: item),
          )
        : _FileFace(item: item);
    return SizedBox.square(
      dimension: AttachmentGrid.size,
      child: Hero(
        tag: item.key,
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(onTap: onTap, child: content),
        ),
      ),
    );
  }
}

class _FileFace extends StatelessWidget {
  const _FileFace({required this.item});

  final AttachmentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_fileIcon(item.mimeType), size: 32, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// Opens images in a full-screen gallery and other files in a viewer ([viewAttachment]).
Future<void> openAttachment(
  BuildContext context,
  WidgetRef ref,
  List<AttachmentItem> items,
  int index, {
  Future<bool> Function(AttachmentItem item)? onDelete,
}) async {
  final item = items[index];
  if (!item.isImage) {
    await viewAttachment(context, ref, item);
    return;
  }
  final images = items.where((i) => i.isImage).toList();
  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => AttachmentViewer(items: images, initialIndex: images.indexOf(item), onDelete: onDelete),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// Opens a document (PDF, …) in a viewer: the system viewer app on Android, a browser tab on the
/// web. Falls back to the share sheet when nothing can show it.
Future<void> viewAttachment(BuildContext context, WidgetRef ref, AttachmentItem item) async {
  try {
    final bytes = await attachmentBytes(ref, item);
    if (bytes == null) return;
    if (await viewFile(bytes, item.name, item.mimeType)) return;
  } catch (e) {
    // Opening failed for another reason than "no viewer app": say so rather than hide it.
    if (context.mounted) showSnack(context, context.l10n.errorGeneric('$e'));
    return;
  }
  // No app can view this type: offer to send it somewhere that can.
  if (context.mounted) await shareAttachment(context, ref, item);
}

Future<void> shareAttachment(BuildContext context, WidgetRef ref, AttachmentItem item) async {
  try {
    final bytes = await attachmentBytes(ref, item);
    if (bytes == null) return;
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, mimeType: item.mimeType, name: item.name)],
      fileNameOverrides: [item.name],
      downloadFallbackEnabled: true,
    ));
  } catch (e) {
    if (context.mounted) showSnack(context, context.l10n.errorGeneric('$e'));
  }
}

class AttachmentViewer extends ConsumerStatefulWidget {
  const AttachmentViewer({super.key, required this.items, required this.initialIndex, this.onDelete});

  final List<AttachmentItem> items;
  final int initialIndex;

  /// Returns true when the item was deleted.
  final Future<bool> Function(AttachmentItem item)? onDelete;

  @override
  ConsumerState<AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends ConsumerState<AttachmentViewer> {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = widget.items[_index];
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title: Text(
            widget.items.length > 1 ? '${_index + 1}/${widget.items.length} · ${item.name}' : item.name,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.share,
              onPressed: () => shareAttachment(context, ref, item),
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: l10n.delete,
                onPressed: () async {
                  if (await widget.onDelete!(item) && context.mounted) Navigator.pop(context);
                },
              ),
          ],
        ),
        body: PageView.builder(
          controller: _pages,
          itemCount: widget.items.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => _ImagePage(item: widget.items[i]),
        ),
      ),
    );
  }
}

class _ImagePage extends ConsumerWidget {
  const _ImagePage({required this.item});

  final AttachmentItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = switch (item) {
      StoredAttachment(:final info) => ref.watch(attachmentBytesProvider(info.id)).value,
      PendingAttachment(:final bytes) => bytes,
    };
    return InteractiveViewer(
      maxScale: 6,
      child: Center(
        child: Hero(
          tag: item.key,
          child: bytes == null ? const CircularProgressIndicator() : Image.memory(bytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Attachments of a saved entry, editable in place (used on the details screen).
class EntryAttachments extends ConsumerWidget {
  const EntryAttachments({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repo = ref.read(attachmentRepositoryProvider);
    final items = [for (final a in ref.watch(attachmentsProvider(entryId)).value ?? const []) StoredAttachment(a)];

    Future<bool> delete(AttachmentItem item) async {
      final ok = await confirm(context, title: l10n.deleteAttachmentTitle, action: l10n.delete, destructive: true);
      if (ok) await repo.delete((item as StoredAttachment).info.id);
      return ok;
    }

    return Island(
      title: l10n.attachments,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AttachmentGrid(
              items: items,
              onOpen: (i) => openAttachment(context, ref, items, i, onDelete: delete),
              onAdd: () async {
                final picked = await pickAttachments(context);
                for (final p in picked) {
                  await repo.add(entryId: entryId, name: p.name, mimeType: p.mimeType, data: p.bytes);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
