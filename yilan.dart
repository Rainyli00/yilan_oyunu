import 'dart:io';
import 'dart:math';
import 'nokta.dart'; 

class YilanOyunu {
  //Oyun alanının boyutu
  final int genislik = 20;
  final int yukseklik = 10;

  List<Nokta> yilan = [Nokta(5, 5)];//Yılanın başlangıç konumu
  late Nokta yem;//yemin konumu
  int skor = 0;
  int seviye = 1;
  Duration adimSuresi = Duration(milliseconds: 200);//Yılanın hızı
  final rastgele = Random();//rastgele sayı üretir,yemi rastgele yerde üretmek için

  YilanOyunu() {
    yemUret();//oyun başladığında ilk yem üretilir
  }

//rastgele bir yerde yem üreten fonksiyon
void yemUret() {
  while (true) {
    // Rastgele bir konum üretilir
    int x = rastgele.nextInt(genislik);
    int y = rastgele.nextInt(yukseklik);
    Nokta yeniYem = Nokta(x, y);

     //yemi yılanın üstünde üretmemek için sağlanan kontrol
    bool yilanustundemi = false;
    for (var parca in yilan) {
      if (parca.esitmi(yeniYem)) {
        yilanustundemi = true;
        break;
      }
    }

    if (!yilanustundemi) {
      yem = yeniYem;
      break;
    }
  }
}

//Oyun alanını terminale çizen metod
  void ciz() {
    stdout.write("\x1B[2J\x1B[0;0H"); // Terminal ekranını temizler
    stdout.writeln("Skor: $skor | Seviye: $seviye | Hız: ${adimSuresi.inMilliseconds}ms\n");

//oyun alanında uygun semboller uygun yere çizilir
    for (int y = 0; y < yukseklik; y++) {
      for (int x = 0; x < genislik; x++) {
        final nokta = Nokta(x, y);
        if (yilan.first.esitmi(nokta)) {
          stdout.write('🟢'); // Yılanın başı
        } else if (yilan.any((parca) => parca.esitmi(nokta))) {
          stdout.write('🟩'); // Yılanın gövdesi
        } else if (yem.esitmi(nokta)) {
          stdout.write('🍎'); // Yem
        } else {
          stdout.write('░░'); //boş alanlar
        }
      }
      stdout.writeln();
    }
  }

//Yılanın hareketleri
  void adimAt() {
    // A* algoritması kullanılarak yeme giden en kısa yol bulunur
    final yol = yolBul(yilan.first, yem, yilan.toSet());
    //Yol bulunamazsa oyun biter
    if (yol == null || yol.isEmpty) {
      stdout.writeln("💀 Oyun Bitti: Yol bulunamadı.");
      exit(0);
    }

  //Yılan hareket eder
    final sonraki = yol.first;
    yilan.insert(0, sonraki); // Yeni baş

    // yılan kendisine çarparsa oyun biter
    if (yilan.skip(1).any((parca) => parca.esitmi(yilan.first))) {
      stdout.writeln("💥 Oyun Bitti: Kendine çarptı.");
      exit(0);
    }
//yılanın yemi yeme durumu
    if (sonraki.esitmi(yem)) {
      skor += 10;
      
      //Skor yemi her yeme durumunda 10 puan artar aynı zamanda yeni seviyeye geçilir
     if (skor < 50 && skor % 10 == 0) {
     seviye++;
     ciz();
     stdout.writeln("🎉 Seviye atladınız! Devam ediyor...");
     sleep(Duration(seconds: 2));// 2 sn boyunca ekran sabit kalır
      }
      //Skor 50 olduysa oyun biter
      if (skor >= 50) {
        ciz();
        stdout.writeln("🎉 Tebrikler! Skor: $skor - Oyunu Kazandınız!");
        exit(0);
      }

      yemUret();//yeni yem üretilir
    } else {
      yilan.removeLast(); // Yılan hareket ettiği için kuyruğu kısaltılır
    }

    // Seviyeye göre yılanın hızı ayarlanır
    switch (seviye) {
      case 2:
        adimSuresi = Duration(milliseconds: 160);
        break;
      case 3:
        adimSuresi = Duration(milliseconds: 130);
        break;
      case 4:
        adimSuresi = Duration(milliseconds: 100);
        break;
      case 5:
        adimSuresi = Duration(milliseconds: 80);
        break;
    }
  }
//A* algoritmasıyla hedefe giden en kısa yolu bulma
  List<Nokta>? yolBul(Nokta baslangic, Nokta hedef, Set<Nokta> engeller) {
    List<Nokta> acikListe = [baslangic];//keşfedilecek noktalar
    Map<Nokta, Nokta> oncekiadimlar = {};
    Map<Nokta, int> gSkor = {baslangic: 0};//gerçek maliyet
    Map<Nokta, int> fSkor = {baslangic: tahmin(baslangic, hedef)};//tahmini toplam maliyet,g+h

// Açık liste boşalana kadar A* algoritması çalışır
    while (acikListe.isNotEmpty) {
      // En düşük fSkor'a sahip nokta seçilir
      acikListe.sort((a, b) => fSkor[a]!.compareTo(fSkor[b]!));
      Nokta simdiki = acikListe.removeAt(0);

//hedef noktaya ulaşıldı mı kontrol eder ve hedefe ulaşıldıysada yolu döndürür
      if (simdiki.esitmi(hedef)) {
        List<Nokta> yol = [];
        Nokta? temp = simdiki;
        while (oncekiadimlar.containsKey(temp)) {
          yol.add(temp!);
          temp = oncekiadimlar[temp]!;
        }
        return yol.reversed.toList();
      }
// Komşu noktalar kontrol edilir engel,alan vesaire kontrol edilir
      for (Nokta yon in yonler) {
        Nokta komsu = simdiki.yeninokta(yon);
        if (!komsu.alandami(genislik, yukseklik) || engeller.contains(komsu)) {
          continue;
        }

        int g = gSkor[simdiki]! + 1;
        if (g < (gSkor[komsu] ?? 999999)) {
          oncekiadimlar[komsu] = simdiki;
          gSkor[komsu] = g;
          fSkor[komsu] = g + tahmin(komsu, hedef);
          if (!acikListe.contains(komsu)) {
            acikListe.add(komsu);
          }
        }
      }
    }

    return null;//yeni yol bulunmazsa null döner
  }
//Manhattan mesafesi,h(n)
  int tahmin(Nokta a, Nokta b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  // Yukarı, sağ, aşağı, sol
  final List<Nokta> yonler = [
    Nokta(0, -1),
    Nokta(1, 0),
    Nokta(0, 1),
    Nokta(-1, 0),
  ];
}
