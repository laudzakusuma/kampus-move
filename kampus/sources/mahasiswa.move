module kampus::data_mahasiswa_lengkap {
    use std::string::String;
    
    // Struct lengkap mahasiswa
    public struct Mahasiswa has key {
        id: UID,
        nama: String,
        nim: u32,
        jurusan: String,
        umur: u8,
        total_sks: u64,
        aktif: bool,
        lulus: bool,
    }
    
    // Fungsi untuk membuat mahasiswa baru
    public fun daftar_mahasiswa(
        nama: String,
        nim: u32,
        jurusan: String,
        umur: u8,
        ctx: &mut TxContext
    ): Mahasiswa {
        Mahasiswa {
            id: object::new(ctx),
            nama,
            nim,
            jurusan,
            umur,
            total_sks: 0,
            aktif: true,
            lulus: false,
        }
    }
    
    // Fungsi untuk ambil mata kuliah (tambah SKS)
    public fun ambil_mata_kuliah(mhs: &mut Mahasiswa, sks: u64) {
        mhs.total_sks = mhs.total_sks + sks;
    }
    
    // Fungsi untuk lulus
    public fun set_lulus(mhs: &mut Mahasiswa) {
        // Syarat lulus: minimal 144 SKS
        if (mhs.total_sks >= 144) {
            mhs.lulus = true;
        }
    }
    
    // Fungsi untuk get info mahasiswa
    public fun get_info(mhs: &Mahasiswa): (String, u32, u64, bool) {
        (mhs.nama, mhs.nim, mhs.total_sks, mhs.lulus)
    }
}