import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_2/core/api/api_response.dart';
import 'package:mobile_2/core/entities/calendar.dart';
import 'package:mobile_2/core/providers/calendar_providers.dart';
import 'package:mobile_2/core/services/calendar_service.dart';
import 'package:mobile_2/widgets/shared/noo_button.dart';
import 'package:mobile_2/widgets/shared/noo_text.dart';
import 'package:mobile_2/widgets/shared/noo_text_input.dart';
import 'package:mobile_2/widgets/shared/noo_text_title.dart';

class CreateEventDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const CreateEventDialog({super.key, required this.selectedDate});

  @override
  ConsumerState<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends ConsumerState<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  CalendarEventVisibility _visibility = CalendarEventVisibility.private;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = CalendarService();
      final response = await service.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        visibility: _visibility,
      );

      if (response is ApiSingleResponse<CalendarEventEntity> && mounted) {
        // Refresh calendar events
        ref
            .read(calendarEventsProvider.notifier)
            .loadEventsForMonth(_selectedDate);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Событие создано успешно')),
        );
      } else if (response is ApiErrorResponse) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка: ${response.error}')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Неизвестная ошибка')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: screenHeight * 0.8,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NooTextTitle('Создать событие', size: NooTitleSize.medium),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NooTextInput(
                          controller: _titleController,
                          label: 'Название',
                          hint: 'Введите название события',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Название обязательно';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NooText('Описание'),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Введите описание события (необязательно)',
                                hintStyle: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.45),
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withOpacity(0.6),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor.withOpacity(0.6),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1.6,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                // Description is now optional
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        NooText('Дата события'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _selectDate(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Изменить',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        NooText('Видимость'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CalendarEventVisibility>(
                              value: _visibility,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: CalendarEventVisibility.all,
                                  child: NooText('Все'),
                                ),
                                DropdownMenuItem(
                                  value: CalendarEventVisibility.ownMentor,
                                  child: NooText('Свой ментор'),
                                ),
                                DropdownMenuItem(
                                  value: CalendarEventVisibility.private,
                                  child: NooText('Приватно'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _visibility = value);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: NooButton(
                      label: 'Отмена',
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: NooButtonStyle.secondary,
                      expanded: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NooButton(
                      label: _isLoading ? '' : 'Создать',
                      onPressed: _isLoading ? null : _submit,
                      style: NooButtonStyle.primary,
                      loading: _isLoading,
                      expanded: false,
                    ),
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
