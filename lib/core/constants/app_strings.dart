class AppStrings {
  // General
  static const String appName = "Abone Kontrol";
  static const String dashboard = "Ana Menü";
  static const String analytics = "Analizler";
  static const String settings = "Ayarlar";
  static const String version = "abonekontrol.com";
  static const String versionBeta = "destek@abonekontrol.com";
  static const String madeBy = "STmobile tarafından";

  // Dashboard
  static const String yourSubscriptions = "Aboneliklerim";
  static const String noSubsYet = "Abonelik henüz yok.";
  static const String sortBy = "Sırala";
  static const String sortNameAsc = "Ad (A-Z)";
  static const String sortNameDesc = "Ad (Z-A)";
  static const String sortPriceHigh = "Fiyat (Yüksekten Düşüğe)";
  static const String sortPriceLow = "Fiyat (Düşükten Yükseğe)";
  static const String sortDateNewest = "Tarihe göre en yeni";
  static const String sortDateOldest = "Tarihe göre en eski";
  static const String subZeroCard = "ABONEKONTROL MENÜ";
  static const String totalMonthlySpend = "Toplam Aylık Harcama";
  static const String spendingBreakdown = "Harcama Dağılımı";

  // Settings
  static const String general = "Genel";
  static const String currency = "Para Birimi";
  static const String language = "Dil";
  static const String appearance = "Görünüş";
  static const String theme = "Tema";
  static const String cyberDark = "Karanlık Mod";
  static const String lightMode = "Açık Mod";
  static const String notifications = "Bildirimler";
  static const String billingReminders = "Ödeme Hatırlatıcıları";
  static const String billingRemindersEnabled = "Ödemelerden önce bildirim alın";
  static const String billingRemindersDisabled = "Bildirimler devre dışı bırakıldı";
  static const String data = "Veri";
  static const String backupRestore = "Yedekleme ve Geri Yükleme";
  static const String backupRestoreSubtitle = "Verilerinizi yerel olarak kaydedin";
  static const String clearAllData = "Tüm Verileri Temizle";
  static const String clearAllDataSubtitle = "Uygulamayı varsayılana sıfırla";
  static const String about = "Hakkında";
  static const String selectCurrency = "Para Birimi Seçin";
  static const String selectLanguage = "Dil Seçiniz";
  static const String clearDataDialogTitle = "Tüm Veriler Temizlensin mi?";
  static const String clearDataDialogContent =
      "Bu işlem tüm aboneliklerinizi silecektir ve ayarlarınızı sıfırlayacaktır. Bu işlem geri alınamaz.";
  static const String cancel = "İptal Et";
  static const String delete = "Sil";
  static const String createBackup = "Yedekleme Oluştur";
  static const String createBackupSubtitle = "Verilerinizi bir dosyaya kaydedin";
  static const String creatingBackup = "Yedek oluşturuluyor...";
  static const String backupSuccess = "Yedekleme başarıyla oluşturuldu!";
  static const String backupFailed = "Yedekleme oluşturulamadı.";
  static const String restoreBackup = "Yedeklemeyi Geri Yükle";
  static const String restoreBackupSubtitle = "Dosyadan veri geri yükleme";
  static const String restoringBackup = "Yedekleme geri yükleniyor...";
  static const String restoreSuccess =
      "Veriler başarıyla geri yüklendi! Lütfen uygulamayı yeniden başlatın.";
  static const String restoreFailed = "Yedekleme geri yükleme işlemi başarısız oldu.";

  // Add Subscription
  static const String editSubscription = "Aboneliği Düzenle";
  static const String newSubscription = "Yeni Abonelik Ekle";
  static const String quickAdd = "Hızlı Ekle";
  static const String enterNamePrice = "Lütfen Bir İsim Ve Fiyat Girin.";
  static const String serviceName = "Hizmet Adı";
  static const String category = "Kategori";
  static const String priceMonthly = "Fiyat (Aylık)";
  static const String cancelUrlOptional = "İptal URL'si (Opsiyonel)";
  static const String firstBill = "İlk Ödeme: ";
  static const String cycle = "Döngü: ";
  static const String monthly = "Aylık";
  static const String yearly = "Yıllık";

  // Internal billing cycle values (do not translate)
  static const String monthlyValue = "Monthly";
  static const String yearlyValue = "Yearly";

  /// Converts internal billing cycle values (Monthly/Yearly) to localized labels.
    // Subscription Detail
  static const String nextBilling = "Sonraki Ödeme";
  static const String cancelSubscription = "Aboneliği İptal Et";
  static const String edit = "Düzenle";
  static const String subscriptionNotFound = "Abonelik bulunamadı";
  static const String subscriptionRemoved = "Abonelik silindi";


  /// Formats a DateTime as dd/MM/yyyy (e.g., 27/01/2026)
  static String formatDate(DateTime dt) {
    final String d = dt.day.toString().padLeft(2, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String y = dt.year.toString();
    return "$d/$m/$y";
  }
static String billingCycleLabel(String value) {
    switch (value) {
      case monthlyValue:
      case "Aylık":
        return monthly;
      case yearlyValue:
      case "Yıllık":
        return yearly;
      default:
        return value;
    }
  }


  static const String saveSubscription = "ABONELİĞİ KAYDET";
  static const String upcomingCharge = "Yaklaşan Abonelik Ödemesi: ";
  static const String youWillBeCharged = "Abonelik İçin Sizden Ödeme Alınacak ";
  static const String chargeDisclaimer =
      "Ödeme tarihine 1 gün kaldı. İhtiyacın yoksa aboneliği iptal et!";
}
