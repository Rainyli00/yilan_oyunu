import 'dart:async';// Timer için
import 'yilan.dart';

void main() {
  final oyun = YilanOyunu();

  void oyundongu() {
    oyun.adimAt();//Yılanı hareket ettirir
    oyun.ciz();//oyun ekranını çizer

    Timer(oyun.adimSuresi, oyundongu);//belli bir süre sonunda döngü tekrar çalıştırılır
  }

  oyundongu();// oyunu başlatır
}
