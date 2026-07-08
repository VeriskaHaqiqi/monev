String formatRupiah(double amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs().toStringAsFixed(0);

  final buffer = StringBuffer();
  for (int i = 0; i < absAmount.length; i++) {
    final reverseIndex = absAmount.length - i;
    buffer.write(absAmount[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
  }

  return '${isNegative ? '-' : ''}Rp${buffer.toString()}';
}