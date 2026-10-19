# AI Declaration — TechStep
**Nama:** Inesa Aisahwa  
**NPM:** 2413025042  
**Kelas:** 2024 B  
**Mata kuliah:** Mobile Programming  
**Proyek:** Edugame TechStep

## 1. Pernyataan penggunaan AI
ChatGPT digunakan sebagai alat bantu konsultasi teknis untuk memahami pesan error, mencari kemungkinan penyebab masalah, mendiskusikan alternatif, dan menyusun langkah pengujian. AI bukan fitur yang tertanam di aplikasi TechStep. Keputusan implementasi, penyesuaian, dan pengujian akhir tetap menjadi tanggung jawab pengembang.

**Catatan transparansi:** contoh prompt di bawah dirangkum dalam laporan UTS, bukan transkrip mentah seluruh percakapan. Cocokkan deklarasi dengan riwayat chat dan perubahan kode sebelum dipublikasikan.

## 2. Alat yang digunakan
- **ChatGPT:** bantuan penjelasan kendala teknis, alternatif solusi, serta ide skenario pengujian.
- **Visual Studio Code dan terminal:** mengedit project, menjalankan perintah, dan memeriksa hasil.
- **Android Emulator/Chrome/SQLite Viewer:** menguji aplikasi dan memeriksa penyimpanan data.

## 3. Pembagian peran
Pembagian peran selama pengembangan adalah sebagai berikut.

- **Konfigurasi Flutter, Java, dan Android SDK**
  - Bantuan AI: memberi saran untuk memeriksa error dan konfigurasi.
  - Pengembang: memasang komponen, memeriksa `JAVA_HOME` dan `PATH`, lalu mencoba ulang perintah.

- **Rancangan produk**
  - Bantuan AI: mendiskusikan alternatif jika diperlukan.
  - Pengembang: menentukan tujuan aplikasi, sasaran siswa kelas X TJKT, materi, dan prioritas fitur.

- **Login, Register, dan data akun**
  - Bantuan AI: membantu mengidentifikasi bagian yang perlu diperiksa.
  - Pengembang: mengintegrasikan fitur serta menguji validasi dan data akun aktif.

- **Quiz, Computer Challenge, dan Learning Analytics**
  - Bantuan AI: membantu memahami konsep dan menyusun skenario pengujian.
  - Pengembang: menyesuaikan alur serta menguji nilai, progres, dan pemetaan kompetensi.

- **Learning Report**
  - Bantuan AI: mendiskusikan bagian yang perlu diperiksa.
  - Pengembang: memeriksa hasil PDF dan kesesuaiannya dengan data belajar.

Pembagian ini menjelaskan jenis kontribusi, bukan atribusi setiap baris kode. Laporan tidak memetakan seluruh kode secara rinci ke AI atau pengembang, sehingga klaim lebih spesifik perlu disesuaikan dengan riwayat project yang benar-benar tersedia.

## 4. Studi kasus prompt

### Kasus 1 — Konfigurasi Java dan `sdkmanager`
**Contoh prompt:**

> Saya memasang Flutter 3.47.2 dan JDK 17.0.20.1 di Windows. `sdkmanager` meminta Java 17 atau lebih tinggi. Bantu saya memeriksa `java --version`, `JAVA_HOME`, dan `PATH`, serta cara memastikan perbaikannya berhasil.

**Bantuan yang diminta:** urutan pemeriksaan versi Java dan environment variable.  
**Pemeriksaan manual:** masalah yang tercatat adalah `JAVA_HOME` masih menunjuk Java 8. Konfigurasi diarahkan ke JDK 17, terminal dibuka ulang, lalu `java --version` dan perintah SDK dicoba kembali.

### Kasus 2 — Pemisahan progres per akun
**Contoh prompt:**

> Di TechStep dengan Flutter dan SQLite, hasil Quiz dan Computer Challenge harus tersimpan sesuai akun siswa. Bagian proses login, simpan/baca data, dan skenario dua akun apa yang perlu diperiksa agar progres tidak tercampur?

**Bantuan yang diminta:** daftar area kode dan skenario uji untuk penyimpanan serta pembacaan data berdasarkan akun aktif.  
**Pemeriksaan manual:** aktivitas berbeda dilakukan pada dua akun, lalu hasil Dashboard/Profile dan Nilai & Perkembangan dibandingkan. Logout dan login kembali juga digunakan untuk memeriksa bahwa data tetap tersedia dan tidak tertukar.

## 5. Keterbatasan dan evaluasi
- Jawaban AI dapat terlalu umum atau mengasumsikan versi package/struktur database yang berbeda.
- Perubahan yang menyelesaikan satu masalah bisa menimbulkan efek samping; ubah bertahap dan uji fitur terkait.
- AI tidak otomatis mengetahui seluruh project atau kondisi emulator tanpa konteks yang diberikan.
- Solusi harus diverifikasi melalui build, uji antarmuka, pemeriksaan data, dan skenario input yang tidak sesuai.
- Jangan masukkan password, token, atau data pribadi siswa ke prompt.

## 6. Kesimpulan
ChatGPT membantu mencari alternatif dan memahami kendala, tetapi tidak menggantikan pemahaman maupun pengujian pengembang. Penerimaan perubahan, validasi database, pengujian login, dan pemeriksaan pemisahan progres tetap menjadi tanggung jawab pengembang.