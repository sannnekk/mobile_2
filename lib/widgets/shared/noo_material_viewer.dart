import 'package:flutter/material.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/entities/poll.dart';
import 'package:mobile_2/core/entities/video.dart';
import 'package:mobile_2/widgets/shared/noo_file_card.dart';
import 'package:mobile_2/widgets/shared/noo_reaction_widget.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_display.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class MaterialViewer extends StatelessWidget {
  final CourseMaterialEntity material;
  final List<String> path;
  final bool embedded;
  final Function(String)? onToggleReaction;

  const MaterialViewer({
    super.key,
    required this.material,
    this.path = const [],
    this.embedded = false,
    this.onToggleReaction,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 226),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (path.isNotEmpty) ...[
            _buildBreadcrumbs(context, path),
            const SizedBox(height: 8),
          ],
          NooTextTitle(material.name),
          const SizedBox(height: 12),
          if (material.description != null &&
              material.description!.isNotEmpty) ...[
            NooText(material.description!),
            const SizedBox(height: 16),
          ],
          if (material.content != null) ...[
            NooRichTextDisplay(
              richText: material.content!,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            ),
          ],
          if (material.videos != null && material.videos!.isNotEmpty) ...[
            _buildVideosSection(context, material.videos!),
            const SizedBox(height: 16),
          ],
          if (material.poll != null) ...[
            _buildPollSection(context, material.poll!),
          ],
          if (material.files.isNotEmpty) ...[
            _buildFilesSection(context, material.files),
            const SizedBox(height: 16),
          ],
          if (onToggleReaction != null) ...[
            const SizedBox(height: 24),
            ReactionWidget(
              currentReaction: material.myReaction,
              availableReactions: const ['thinking', 'check'],
              onToggle: onToggleReaction!,
            ),
          ],
        ],
      ),
    );

    if (embedded) {
      return SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: content,
        ),
      );
    }

    return Scaffold(body: SingleChildScrollView(child: content));
  }

  Widget _buildBreadcrumbs(BuildContext context, List<String> path) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < path.length; i++) ...[
          NooText(path[i], dimmed: true),
          if (i < path.length - 1)
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
        ],
      ],
    );
  }

  Widget _buildFilesSection(BuildContext context, List<MediaEntity> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        NooTextTitle('Файлы'),
        const SizedBox(height: 8),
        ...files.map((file) => NooFileCard(media: file)),
      ],
    );
  }

  Widget _buildVideosSection(BuildContext context, List<VideoEntity> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NooTextTitle('Видео'),
        const SizedBox(height: 8),
        ...videos.map(
          (video) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPollSection(BuildContext context, PollEntity poll) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NooTextTitle('Опрос'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(poll.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 16),
                // TODO: Implement poll options and voting
                const Text('Опции опроса будут отображены здесь'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
