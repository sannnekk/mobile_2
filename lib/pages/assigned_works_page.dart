import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/entities/assigned_work.dart';
import 'package:mobile_2/core/providers/assigned_work_providers.dart';
import 'package:mobile_2/widgets/shared/noo_app_scaffold.dart';
import 'package:mobile_2/widgets/shared/noo_assigned_work_card.dart';
import 'package:mobile_2/widgets/shared/noo_empty_list.dart';
import 'package:mobile_2/widgets/shared/noo_error_view.dart';
import 'package:mobile_2/widgets/shared/noo_grouped_list_by_date.dart';
import 'package:mobile_2/widgets/shared/noo_loader.dart';
import 'package:mobile_2/widgets/shared/noo_pagination.dart';
import 'package:mobile_2/widgets/shared/noo_tab_bar.dart';

class AssignedWorksPage extends ConsumerStatefulWidget {
  const AssignedWorksPage({super.key});

  @override
  ConsumerState<AssignedWorksPage> createState() => _AssignedWorksPageState();
}

class _AssignedWorksPageState extends ConsumerState<AssignedWorksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<bool> _loaded;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loaded = [true, false, false, false, false];
    _tabController.addListener(_handleTabChange);
    // Load the first tab
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTab(0));
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadTab(_tabController.index);
    }
  }

  void _loadTab(int index) {
    if (!_loaded[index]) {
      final tab = AssignedWorkTab.values[index];
      ref.read(assignedWorksNotifierProvider(tab).notifier).loadWorks();
      _loaded[index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NooAppScaffold(
      title: 'Работы',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Поиск',
          onPressed: () {
            setState(() {
              if (!_showSearch) {
                final currentTab = AssignedWorkTab.values[_tabController.index];
                final state = ref.read(
                  assignedWorksNotifierProvider(currentTab),
                );
                // Prefill controller with existing tab query
                _searchController.text = state.searchQuery;
              }
              _showSearch = !_showSearch;
            });
          },
        ),
      ],
      child: Column(
        children: [
          _buildSearchBar(),
          NooTabBar(
            controller: _tabController,
            tabs: const [
              Text('Все'),
              Text('Нерешенные'),
              Text('Непроверенные'),
              Text('Проверенные'),
              Text('Архив'),
            ],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWorksTab(AssignedWorkTab.all),
                _buildWorksTab(AssignedWorkTab.unsolved),
                _buildWorksTab(AssignedWorkTab.unchecked),
                _buildWorksTab(AssignedWorkTab.checked),
                _buildWorksTab(AssignedWorkTab.archived),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final currentTab = AssignedWorkTab.values[_tabController.index];
    final notifier = ref.read(
      assignedWorksNotifierProvider(currentTab).notifier,
    );
    final theme = Theme.of(context);
    if (!_showSearch) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => notifier.setSearchQuery(value),
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Поиск работ',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    notifier.setSearchQuery('');
                    setState(() {});
                  },
                ),
            ],
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildWorksTab(AssignedWorkTab tab) {
    final worksState = ref.watch(assignedWorksNotifierProvider(tab));
    final worksNotifier = ref.read(assignedWorksNotifierProvider(tab).notifier);

    // Show loading if we're loading
    if (worksState.isLoading) {
      return const Center(child: NooLoader());
    }

    if (worksState.error != null) {
      return NooErrorView(
        error: worksState.error!,
        onRetry: () => worksNotifier.refreshWorks(),
      );
    }

    final works = worksState.works;

    if (works.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => worksNotifier.refreshWorks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                200, // Account for tab bar and app bar
            child: NooEmptyList(
              title: 'Нет работ',
              message: 'В этом разделе нет пока работ.',
              child: tab == AssignedWorkTab.all
                  ? const Text(
                      'Чтобы получить работы, перейдите в курс и нажмите "К работе" в нужном материале.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => worksNotifier.refreshWorks(),
      child: NooGroupedListByDate<AssignedWorkEntity>(
        items: works,
        dateExtractor: (work) => work.createdAt,
        itemBuilder: (work) => AssignedWorkCard(
          work: work,
          actions: _getActionsForWork(work, worksNotifier),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        bottomWidget: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: NooPagination(
            currentPage: worksState.currentPage,
            totalPages: worksState.totalPages,
            hasNextPage: worksState.hasNextPage,
            hasPreviousPage: worksState.hasPreviousPage,
            onNextPage: worksNotifier.loadNextPage,
            onPreviousPage: worksNotifier.loadPreviousPage,
            onPageSelected: worksNotifier.goToPage,
            isLoading: worksState.isLoading,
          ),
        ),
      ),
    );
  }

  List<AssignedWorkAction> _getActionsForWork(
    AssignedWorkEntity work,
    AssignedWorksNotifier notifier,
  ) {
    final actions = <AssignedWorkAction>[];

    // Archive action (available for all non-archived works)
    if (!work.isArchivedByStudent) {
      actions.add((
        label: 'Архивировать',
        icon: Icons.archive,
        onPressed: () => notifier.archiveWork(work.id),
      ));
    }

    // Delete action (only for not-started or in-progress)
    if (work.solveStatus == AssignedWorkSolveStatus.notStarted ||
        work.solveStatus == AssignedWorkSolveStatus.inProgress) {
      actions.add((
        label: 'Удалить',
        icon: Icons.delete,
        onPressed: () => notifier.deleteWork(work.id),
      ));
    }

    return actions;
  }
}
