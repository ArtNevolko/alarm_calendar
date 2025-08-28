String daysToString(List<int> days) {
  const weekDays = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
  if (days.isEmpty) return 'Без повторов';
  return days.map((i) => weekDays[i % 7]).join(', ');
}
