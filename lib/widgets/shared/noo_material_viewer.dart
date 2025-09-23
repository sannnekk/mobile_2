import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_2/core/entities/course.dart';
import 'package:mobile_2/core/entities/media.dart';
import 'package:mobile_2/core/entities/poll.dart';
import 'package:mobile_2/core/entities/video.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/core/utils/api_response_handler.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/widgets/shared/noo_card.dart';
import 'package:mobile_2/widgets/shared/noo_file_card.dart';
import 'package:mobile_2/widgets/shared/noo_score_widget.dart';
import 'package:mobile_2/widgets/shared/noo_reaction_widget.dart';
import 'package:mobile_2/widgets/shared/noo_rich_text_display.dart';
import 'package:mobile_2/widgets/shared/noo_status_tags.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class MaterialViewer extends ConsumerStatefulWidget {
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
  ConsumerState<MaterialViewer> createState() => _MaterialViewerState();
}

class _MaterialViewerState extends ConsumerState<MaterialViewer> {
  bool _isCreatingWork = false;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 226),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.path.isNotEmpty) ...[
            _buildBreadcrumbs(context, widget.path),
            const SizedBox(height: 8),
          ],
          NooTextTitle(widget.material.name),
          if (widget.material.workId != null) ...[
            const SizedBox(height: 8),
            _buildToWorkButton(),
            const SizedBox(height: 8),
            _buildWorkProgressBlock(widget.material.workId!),
          ],
          const SizedBox(height: 12),
          if (widget.material.description != null &&
              widget.material.description!.isNotEmpty) ...[
            NooText(widget.material.description!),
            const SizedBox(height: 16),
          ],
          if (widget.material.content != null) ...[
            NooRichTextDisplay(
              richText: widget.material.content!,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            ),
          ],
          if (widget.material.videos != null &&
              widget.material.videos!.isNotEmpty) ...[
            _buildVideosSection(context, widget.material.videos!),
            const SizedBox(height: 16),
          ],
          if (widget.material.poll != null) ...[
            _buildPollSection(context, widget.material.poll!),
          ],
          if (widget.material.files.isNotEmpty) ...[
            _buildFilesSection(context, widget.material.files),
            const SizedBox(height: 16),
          ],
          if (widget.onToggleReaction != null) ...[
            const SizedBox(height: 24),
            ReactionWidget(
              currentReaction: widget.material.myReaction,
              availableReactions: const ['thinking', 'check'],
              onToggle: widget.onToggleReaction!,
            ),
            const SizedBox(height: 6),
            NooText(
              "Реакции видны только Вам. Они помогают отслеживать прогресс.",
              dimmed: true,
            ),
          ],
        ],
      ),
    );

    if (widget.embedded) {
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

  Widget _buildToWorkButton() {
    return SizedBox(
      width: double.infinity,
      child: NooButton(
        onPressed: _isCreatingWork ? null : _createAssignedWork,
        loading: _isCreatingWork,
        label: 'К работе',
      ),
    );
  }

  Future<void> _createAssignedWork() async {
    setState(() => _isCreatingWork = true);
    try {
      final service = await ref.read(assignedWorkServiceProvider.future);
      final result = await ApiResponseHandler.handleCall<String?>(
        () => service.createAssignedWorkFromMaterial(widget.material.slug),
      );
      if (result.isSuccess && result.data != null) {
        if (mounted) context.go('/assigned_work/${result.data}');
      }
    } catch (e) {
      // Handle error - maybe show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось создать работу')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingWork = false);
    }
  }

  Widget _buildWorkProgressBlock(String workId) {
    final progressAsync = ref.watch(assignedWorkProgressProvider(workId));
    return progressAsync.when(
      data: (progress) {
        return NooCard(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NooText('Прогресс по работе'),
                  const SizedBox(height: 8),
                  NooStatusTags(
                    solveStatus: progress.solveStatus,
                    checkStatus: progress.checkStatus,
                  ),
                  const SizedBox(height: 8),
                  NooScoreWidget(
                    score: progress.score,
                    maxScore: progress.maxScore,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: NooText('Работа не начата', dimmed: true),
      ),
    );
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
