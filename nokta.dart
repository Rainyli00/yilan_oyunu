
class Nokta {
  int x,y ; 
  
  Nokta(this.x, this.y);

  // yılanın yeni noktası oluşturulur
  Nokta yeninokta(Nokta diger) {
    return Nokta(x + diger.x, y + diger.y);
  }

// Nokta diğer noktayla eşit mi kontrol edilir
  bool esitmi(Nokta diger) {
    return x == diger.x && y == diger.y;
  }

  // Nokta alanın içinde mi diye kontrol edilir
  bool alandami(int genislik, int yukseklik) {
    return x >= 0 && y >= 0 && x < genislik && y < yukseklik;
  }

 // noktanın hash kodunu döndürür ( set ve map için lazım)
  @override
  int get hashCode => x * 31 + y;

// Noktalar aynı yerdemi kontrol eder
  @override
  bool operator ==(Object diger) {
    return diger is Nokta && diger.x == x && diger.y == y;
  }


}
