enum EstablishmentType {
  pickup('pickup', 'Пункт самовывоза'),
  restaurant('restaurant', 'Ресторан');

  const EstablishmentType(this.value, this.displayName);

  final String value;
  final String displayName;

  static EstablishmentType fromString(String value) {
    return EstablishmentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EstablishmentType.pickup,
    );
  }
}
