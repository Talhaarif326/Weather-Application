class TempConverter {
  static double convert(double kelvin, String unit) {
    if (unit == 'C') return kelvin - 273.15;
    return (kelvin - 273.15) * 9 / 5 + 32;
  }

  static String label(String unit) => unit == 'C' ? '°C' : '°F';
}
