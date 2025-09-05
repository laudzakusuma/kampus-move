Kampus Token System (Sui Move)

Proyek ini adalah implementasi Sui Move Module untuk sistem token sederhana bernama Kampus.
Modul ini digunakan sebagai latihan dari dokumentasi Sui Day1 Module 1: Token System
.

📦 Struktur Project
kampus/
├── Move.toml
├── sources/
│   └── mahasiswa.move


Move.toml → Konfigurasi paket Move.

mahasiswa.move → Modul utama berisi definisi token/sistem mahasiswa.

⚙️ Prasyarat

Sebelum menjalankan proyek ini, pastikan kamu sudah:

Menginstal Sui CLI
.

Memiliki local environment dengan Sui (devnet/testnet).

Sudah menambahkan akun (address) dengan sui client new-address dan memilih default address dengan sui client switch.

🚀 Build & Test
1. Build Package

Untuk membangun package:

sui move build

2. Test Package

Menjalankan unit test:

sui move test

📖 Deploy ke Jaringan
1. Publish Package

Gunakan perintah:

sui client publish --gas-budget 100000000


Setelah publish, catat Package ID.

Ganti alamat @kampus di Move.toml dengan Package ID yang baru.

2. Jalankan Fungsi Modul

Setelah deploy, kamu bisa memanggil fungsi di modul mahasiswa menggunakan:

sui client call \
  --package <PACKAGE_ID> \
  --module mahasiswa \
  --function <NAMA_FUNGSI> \
  --args <ARGUMENTS> \
  --gas-budget 100000000


Contoh (misalnya untuk mendaftarkan mahasiswa baru):

sui client call \
  --package <PACKAGE_ID> \
  --module mahasiswa \
  --function register_mahasiswa \
  --args <ALAMAT_MAHASISWA> <NAMA> \
  --gas-budget 100000000

📌 Catatan

Ganti <PACKAGE_ID>, <ALAMAT_MAHASISWA>, <NAMA> sesuai kebutuhanmu.

Setiap kali kamu melakukan perubahan kode di mahasiswa.move, perlu deploy ulang dan update Move.toml.




Kampus Token (Sui Move)

Proyek ini adalah implementasi Sui Move smart contract sederhana bernama Kampus Token.
Kontrak ini digunakan sebagai latihan dari dokumentasi Sui Day1 Module 2: Intro to Sui
.

📦 Struktur Project
kampus_token/
├── Move.toml
├── sources/
│   └── kampus_coin.move


Move.toml → File konfigurasi paket Move.

kampus_coin.move → Modul utama berisi logika pembuatan token.

⚙️ Prasyarat

Sebelum menjalankan proyek ini, pastikan kamu sudah:

Menginstal Sui CLI
.

Memiliki wallet address di Sui (buat dengan sui client new-address).

Sudah memilih default address dengan sui client switch.

🚀 Build & Test
1. Build Package

Untuk membangun package:

sui move build

2. Test Package

Menjalankan unit test (jika ada):

sui move test

📖 Deploy ke Jaringan
1. Publish Package

Gunakan perintah:

sui client publish --gas-budget 100000000


Setelah publish, catat Package ID.

Ganti alamat @kampus_token di Move.toml dengan Package ID tersebut.

2. Panggil Fungsi Modul

Setelah deploy, kamu bisa memanggil fungsi di modul kampus_coin.
Contoh untuk mint token:

sui client call \
  --package <PACKAGE_ID> \
  --module kampus_coin \
  --function mint \
  --args <TREASURY_CAP_OBJECT_ID> <JUMLAH_TOKEN> <ALAMAT_PENERIMA> \
  --gas-budget 100000000

📌 Catatan

Ganti <PACKAGE_ID>, <TREASURY_CAP_OBJECT_ID>, <JUMLAH_TOKEN>, dan <ALAMAT_PENERIMA> sesuai hasil deploy.

Gunakan sui client objects untuk melihat daftar objek milikmu.

Token hasil mint bisa dibagi (split-coin) atau ditransfer (transfer-sui).






Sistem Kampus Lengkap (Sui Move)

Proyek ini adalah implementasi Sui Move smart contract untuk sistem kampus sederhana.
Modul ini menggabungkan konsep token system dan data mahasiswa sebagai latihan dari dokumentasi Sui Day1 Module 3: Token System
.

📦 Struktur Project
sistem_kampus_lengkap/
├── Move.toml
├── sources/
│   └── kampus.move


Move.toml → File konfigurasi paket Move.

kampus.move → Modul utama yang berisi logika sistem kampus (registrasi mahasiswa, token, dsb).

⚙️ Prasyarat

Sebelum menjalankan proyek ini, pastikan kamu sudah:

Menginstal Sui CLI
.

Memiliki wallet address di Sui (buat dengan sui client new-address).

Sudah memilih default address dengan sui client switch.

🚀 Build & Test
1. Build Package

Untuk membangun package:

sui move build

2. Test Package

Menjalankan unit test (jika ada):

sui move test

📖 Deploy ke Jaringan
1. Publish Package

Gunakan perintah:

sui client publish --gas-budget 100000000


Setelah publish, catat Package ID.

Ganti alamat @sistem_kampus di Move.toml dengan Package ID tersebut.

⚡ Contoh Pemanggilan Fungsi
1. Registrasi Mahasiswa
sui client call \
  --package <PACKAGE_ID> \
  --module kampus \
  --function register_mahasiswa \
  --args <ALAMAT_MAHASISWA> <NAMA_MAHASISWA> \
  --gas-budget 100000000

2. Mint Token Kampus
sui client call \
  --package <PACKAGE_ID> \
  --module kampus \
  --function mint_token \
  --args <TREASURY_CAP_OBJECT_ID> <JUMLAH_TOKEN> <ALAMAT_PENERIMA> \
  --gas-budget 100000000

   <img width="940" height="377" alt="image" src="https://github.com/user-attachments/assets/586e8153-ecba-47fb-964f-f61d1d474010" />
   <img width="940" height="783" alt="image" src="https://github.com/user-attachments/assets/07ec0426-2300-4bd6-a6cc-3ae8899d0fde" />
   <img width="940" height="547" alt="image" src="https://github.com/user-attachments/assets/d4e5ab75-8922-46ee-8961-65efc947cbca" />




4. Split Token
sui client split-coin \
  --coin-id <COIN_OBJECT_ID> \
  --amounts <JUMLAH1> <JUMLAH2> \
  --gas-budget 100000000

   <img width="940" height="641" alt="image" src="https://github.com/user-attachments/assets/e221cf2b-7829-4e31-b03f-77aa976b9dba" />
   <img width="940" height="922" alt="image" src="https://github.com/user-attachments/assets/1541e6c8-677e-491c-8ebd-3c1eb1bd8214" />
   <img width="940" height="574" alt="image" src="https://github.com/user-attachments/assets/93d4095e-dc1a-4bb1-a008-f8fe57cb572c" />




6. Transfer Token
sui client transfer-sui \
  --to <ALAMAT_TUJUAN> \
  --sui-coin-object-id <COIN_OBJECT_ID> \
  --gas-budget 100000000

   <img width="940" height="543" alt="image" src="https://github.com/user-attachments/assets/b77b35ad-044d-43ca-a9d8-af05e1c323b9" />
   <img width="940" height="568" alt="image" src="https://github.com/user-attachments/assets/71375e2b-7b22-4ac0-bea9-2118b64d5b26" />
   <img width="940" height="413" alt="image" src="https://github.com/user-attachments/assets/2c8a8d6f-3f36-47db-830f-6fe028c3e481" />




📌 Catatan

Ganti <PACKAGE_ID>, <COIN_OBJECT_ID>, <TREASURY_CAP_OBJECT_ID>, <ALAMAT_MAHASISWA>, <NAMA_MAHASISWA> sesuai hasil deploy.

Gunakan sui client objects untuk melihat daftar objek yang kamu miliki.

Sistem ini bisa dikembangkan untuk menambahkan fitur lain (misalnya pembayaran kuliah dengan token kampus, reward mahasiswa, dll).


Ganti <PACKAGE_ID>, <ALAMAT_MAHASISWA>, <NAMA> sesuai kebutuhanmu.

Setiap kali kamu melakukan perubahan kode di mahasiswa.move, perlu deploy ulang dan update Move.toml.
