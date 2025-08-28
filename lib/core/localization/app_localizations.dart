import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Поддерживаемые языки
enum AppLanguage { russian, english, ukrainian }

// Состояние Bloc
class LocalizationState {
  final AppLanguage language;

  const LocalizationState({this.language = AppLanguage.russian});

  LocalizationState copyWith({AppLanguage? language}) {
    return LocalizationState(
      language: language ?? this.language,
    );
  }
}

// События Bloc
abstract class LocalizationEvent {}

class ChangeLanguageEvent extends LocalizationEvent {
  final AppLanguage language;

  ChangeLanguageEvent(this.language);
}

class InitLocalizationEvent extends LocalizationEvent {}

// Bloc для управления локализацией
class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc() : super(const LocalizationState()) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<InitLocalizationEvent>(_onInitLocalization);

    // Автоматически определяем язык системы при создании блока
    add(InitLocalizationEvent());
  }

  void _onChangeLanguage(
      ChangeLanguageEvent event, Emitter<LocalizationState> emit) {
    emit(state.copyWith(language: event.language));
  }

  void _onInitLocalization(InitLocalizationEvent event, Emitter<LocalizationState> emit) {
    final String systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    AppLanguage detectedLanguage;

    switch (systemLocale) {
      case 'en':
        detectedLanguage = AppLanguage.english;
        break;
      case 'uk':
        detectedLanguage = AppLanguage.ukrainian;
        break;
      case 'ru':
        detectedLanguage = AppLanguage.russian;
        break;
      default:
        detectedLanguage = AppLanguage.russian; // Язык по умолчанию
        break;
    }

    emit(state.copyWith(language: detectedLanguage));
  }
}

// Класс с текстами для локализации
class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  // Статический метод для доступа к локализации из контекста
  static AppLocalizations of(BuildContext context) {
    return BlocProvider.of<LocalizationBloc>(context)
        .state
        .language
        .localizations;
  }

  // Добавление расширения для удобного доступа к локализации
  static AppLocalizations get localization => AppLanguage.russian.localizations;

  // Общие строки
  String get appTitle => _getLocalizedValue(
        ru: 'Будильник Pro',
        en: 'Alarm Pro',
        uk: 'Будильник Pro',
      );

  String get alarmListEmpty => _getLocalizedValue(
        ru: 'Нет будильников',
        en: 'No alarms',
        uk: 'Немає будильників',
      );

  String get addFirstAlarm => _getLocalizedValue(
        ru: 'Нажмите кнопку + чтобы создать\nпервый будильник',
        en: 'Press the + button to create\nyour first alarm',
        uk: 'Натисніть кнопку + щоб створити\nперший будильник',
      );

  String get newAlarm => _getLocalizedValue(
        ru: 'Новый будильник',
        en: 'New Alarm',
        uk: 'Новий будильник',
      );

  String get editAlarm => _getLocalizedValue(
        ru: 'Редактирование будильника',
        en: 'Edit Alarm',
        uk: 'Редагування будильника',
      );

  String get save => _getLocalizedValue(
        ru: 'Сохранить',
        en: 'Save',
        uk: 'Зберегти',
      );

  String get cancel => _getLocalizedValue(
        ru: 'Отмена',
        en: 'Cancel',
        uk: 'Скасувати',
      );

  String get clear => _getLocalizedValue(
        ru: 'Очистить',
        en: 'Clear',
        uk: 'Очистити',
      );

  String get delete => _getLocalizedValue(
        ru: 'Удалить',
        en: 'Delete',
        uk: 'Видалити',
      );

  String get alarmSaved => _getLocalizedValue(
        ru: 'Будильник сохранен',
        en: 'Alarm saved',
        uk: 'Будильник збережено',
      );

  String get alarmUpdated => _getLocalizedValue(
        ru: 'Будильник обновлен',
        en: 'Alarm updated',
        uk: 'Будильник оновлено',
      );

  String get alarmDeleted => _getLocalizedValue(
        ru: 'Будильник удален',
        en: 'Alarm deleted',
        uk: 'Будильник видалено',
      );

  String get confirmDeleteTitle => _getLocalizedValue(
        ru: 'Удалить будильник?',
        en: 'Delete alarm?',
        uk: 'Видалити будильник?',
      );

  String get confirmDeleteMessage => _getLocalizedValue(
        ru: 'Это действие нельзя отменить.',
        en: 'This action cannot be undone.',
        uk: 'Цю дію неможливо скасувати.',
      );

  String get languageSelection => _getLocalizedValue(
        ru: 'Выбор языка',
        en: 'Language Selection',
        uk: 'Вибір мови',
      );

  String get languageName => _getLocalizedValue(
        ru: 'Русский',
        en: 'English',
        uk: 'Українська',
      );

  String get selectDates => _getLocalizedValue(
        ru: 'Выберите даты',
        en: 'Select dates',
        uk: 'Виберіть дати',
      );

  String get selectRingtone => _getLocalizedValue(
        ru: 'Выберите мелодию',
        en: 'Select ringtone',
        uk: 'Виберіть мелодію',
      );

  String get tapToSelectTime => _getLocalizedValue(
        ru: 'Нажмите для выбора времени',
        en: 'Tap to select time',
        uk: 'Натисніть для вибору часу',
      );

  String get tapToSelectDates => _getLocalizedValue(
        ru: 'Нажмите для выбора дат',
        en: 'Tap to select dates',
        uk: 'Натисніть для вибору дат',
      );

  String get label => _getLocalizedValue(
        ru: 'Название',
        en: 'Label',
        uk: 'Назва',
      );

  String get dates => _getLocalizedValue(
        ru: 'Выбор дат',
        en: 'Date Selection',
        uk: 'Вибір дат',
      );

  String get ringtone => _getLocalizedValue(
        ru: 'Мелодия',
        en: 'Ringtone',
        uk: 'Мелодія',
      );

  String get saveAlarm => _getLocalizedValue(
        ru: 'Сохранить будильник',
        en: 'Save Alarm',
        uk: 'Зберегти будильник',
      );

  String get settings => _getLocalizedValue(
        ru: 'Настройки',
        en: 'Settings',
        uk: 'Налаштування',
      );

  String get timer => _getLocalizedValue(
        ru: 'Таймер',
        en: 'Timer',
        uk: 'Таймер',
      );

  String get timerInDevelopment => _getLocalizedValue(
        ru: 'Таймер в разработке',
        en: 'Timer in development',
        uk: 'Таймер у розробці',
      );

  String get selectedDates => _getLocalizedValue(
        ru: 'Выбранные даты',
        en: 'Selected dates',
        uk: 'Вибрані дати',
      );

  String selectedDatesCount(int count) => _getLocalizedValue(
        ru: 'Выбранные даты ($count):',
        en: 'Selected dates ($count):',
        uk: 'Вибрані дати ($count):',
      );

  String datesSelected(int count) => _getLocalizedValue(
        ru: 'Выбрано дат: $count',
        en: 'Dates selected: $count',
        uk: 'Вибрано дат: $count',
      );

  String alarmForDates(int count) {
    final String dateTerm = _getLocalizedValue(
      ru: count == 1 ? 'даты' : 'дат',
      en: count == 1 ? 'date' : 'dates',
      uk: count == 1 ? 'дати' : 'дат',
    );
    return _getLocalizedValue(
      ru: 'для $count $dateTerm',
      en: 'for $count $dateTerm',
      uk: 'для $count $dateTerm',
    );
  }

  String get needSelectDate => _getLocalizedValue(
        ru: 'Пожалуйста, выберите хотя бы одну дату',
        en: 'Please select at least one date',
        uk: 'Будь ласка, виберіть хоча б одну дату',
      );

  String get goodMorning => _getLocalizedValue(
        ru: 'доброе утро',
        en: 'good morning',
        uk: 'добрий ранок',
      );

  String get goodDay => _getLocalizedValue(
        ru: 'добрый день',
        en: 'good day',
        uk: 'добрий день',
      );

  String get goodEvening => _getLocalizedValue(
        ru: 'добрый вечер',
        en: 'good evening',
        uk: 'добрий вечір',
      );

  String get languageDetected => _getLocalizedValue(
        ru: 'Обнаружен русский язык',
        en: 'English language detected',
        uk: 'Виявлено українську мову',
      );

  // Локализованные месяцы
  List<String> get months => _getLocalizedValue(
        ru: [
          'января',
          'февраля',
          'марта',
          'апреля',
          'мая',
          'июня',
          'июля',
          'августа',
          'сентября',
          'октября',
          'ноября',
          'декабря'
        ],
        en: [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ],
        uk: [
          'січня',
          'лютого',
          'березня',
          'квітня',
          'травня',
          'червня',
          'липня',
          'серпня',
          'вересня',
          'жовтня',
          'листопада',
          'грудня'
        ],
      );

  List<String> get shortMonths => _getLocalizedValue(
        ru: [
          'янв',
          'фев',
          'мар',
          'апр',
          'май',
          'июн',
          'июл',
          'авг',
          'сен',
          'окт',
          'ноя',
          'дек'
        ],
        en: [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ],
        uk: [
          'січ',
          'лют',
          'бер',
          'кві',
          'тра',
          'чер',
          'лип',
          'сер',
          'вер',
          'жов',
          'лис',
          'гру'
        ],
      );

  List<String> get weekdays => _getLocalizedValue(
        ru: [
          'понедельник',
          'вторник',
          'среда',
          'четверг',
          'пятница',
          'суббота',
          'воскресенье'
        ],
        en: [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ],
        uk: [
          'понеділок',
          'вівторок',
          'середа',
          'четвер',
          'п\'ятниця',
          'субота',
          'неділя'
        ],
      );

  // Мелодии будильника
  String get defaultRingtone => _getLocalizedValue(
        ru: 'Стандартная мелодия',
        en: 'Default melody',
        uk: 'Стандартна мелодія',
      );

  String get birdsRingtone => _getLocalizedValue(
        ru: 'Птицы',
        en: 'Birds',
        uk: 'Птахи',
      );

  String get forestRingtone => _getLocalizedValue(
        ru: 'Лес',
        en: 'Forest',
        uk: 'Ліс',
      );

  String get seaRingtone => _getLocalizedValue(
        ru: 'Морской прибой',
        en: 'Sea waves',
        uk: 'Морський прибій',
      );

  String get rainRingtone => _getLocalizedValue(
        ru: 'Дождь',
        en: 'Rain',
        uk: 'Дощ',
      );

  String get meditationRingtone => _getLocalizedValue(
        ru: 'Медитация',
        en: 'Meditation',
        uk: 'Медитація',
      );

  // Метод для получения локализованных строк
  T _getLocalizedValue<T>({
    required T ru,
    required T en,
    required T uk,
  }) {
    switch (language) {
      case AppLanguage.english:
        return en;
      case AppLanguage.ukrainian:
        return uk;
      case AppLanguage.russian:
        return ru;
    }
  }
}

// Расширение для удобного доступа к локализации
extension AppLanguageExtension on AppLanguage {
  AppLocalizations get localizations => AppLocalizations(this);

  String get languageName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.ukrainian:
        return 'Українська';
      case AppLanguage.russian:
        return 'Русский';
    }
  }

  String get languageCode {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.ukrainian:
        return 'uk';
      case AppLanguage.russian:
        return 'ru';
    }
  }

  String get flagEmoji {
    switch (this) {
      case AppLanguage.english:
        return '🇺🇸';
      case AppLanguage.ukrainian:
        return '🇺🇦';
      case AppLanguage.russian:
        return '🇷🇺';
    }
  }
}
