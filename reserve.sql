CREATE DATABASE IF NOT EXISTS rda_reserve_db;
USE rda_reserve_db;

-- ==========================================
-- 1. MANAJEMEN PENGGUNA & AKSES
-- ==========================================
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE program_studi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_prodi VARCHAR(100) NOT NULL,
    fakultas VARCHAR(100) NOT NULL
);

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(20) UNIQUE NOT NULL,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    prodi_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (prodi_id) REFERENCES program_studi(id)
);

-- ==========================================
-- 2. INTI RESERVASI (CORE)
-- ==========================================
CREATE TABLE jadwal_operasional (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hari ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu') UNIQUE NOT NULL,
    jam_buka TIME NOT NULL,
    jam_tutup TIME NOT NULL,
    is_libur BOOLEAN DEFAULT FALSE
);

CREATE TABLE peminjaman (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    tanggal_kegiatan DATE NOT NULL,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    tujuan_kegiatan TEXT NOT NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELED', 'COMPLETED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE detail_persetujuan (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    peminjaman_id BIGINT NOT NULL,
    admin_id BIGINT NOT NULL,
    catatan_admin VARCHAR(255),
    waktu_persetujuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (peminjaman_id) REFERENCES peminjaman(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

CREATE TABLE dokumen_persyaratan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_dokumen VARCHAR(100) NOT NULL, -- Contoh: Surat Izin Kajur
    deskripsi TEXT
);

CREATE TABLE lampiran_peminjaman (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    peminjaman_id BIGINT NOT NULL,
    dokumen_id INT NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    FOREIGN KEY (peminjaman_id) REFERENCES peminjaman(id) ON DELETE CASCADE,
    FOREIGN KEY (dokumen_id) REFERENCES dokumen_persyaratan(id)
);

-- ==========================================
-- 3. MANAJEMEN INVENTARIS LAB
-- ==========================================
CREATE TABLE kategori_barang (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL -- Contoh: Elektronik, Furniture
);

CREATE TABLE inventaris_barang (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    kode_barang VARCHAR(50) UNIQUE NOT NULL,
    nama_barang VARCHAR(100) NOT NULL,
    kategori_id INT NOT NULL,
    kondisi ENUM('BAIK', 'RUSAK_RINGAN', 'RUSAK_BERAT') DEFAULT 'BAIK',
    jumlah INT DEFAULT 1,
    FOREIGN KEY (kategori_id) REFERENCES kategori_barang(id)
);

CREATE TABLE peminjaman_barang (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    peminjaman_id BIGINT NOT NULL,
    barang_id BIGINT NOT NULL,
    jumlah_dipinjam INT NOT NULL,
    FOREIGN KEY (peminjaman_id) REFERENCES peminjaman(id) ON DELETE CASCADE,
    FOREIGN KEY (barang_id) REFERENCES inventaris_barang(id)
);

-- ==========================================
-- 4. MANAJEMEN KOMPUTER & SOFTWARE
-- ==========================================
CREATE TABLE software_lab (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_software VARCHAR(100) NOT NULL,
    versi VARCHAR(50)
);

CREATE TABLE lisensi_software (
    id INT AUTO_INCREMENT PRIMARY KEY,
    software_id INT NOT NULL,
    kunci_lisensi VARCHAR(100) NOT NULL,
    tanggal_expired DATE NOT NULL,
    FOREIGN KEY (software_id) REFERENCES software_lab(id) ON DELETE CASCADE
);

CREATE TABLE instalasi_software (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    barang_id BIGINT NOT NULL, -- ID Komputer dari inventaris_barang
    software_id INT NOT NULL,
    FOREIGN KEY (barang_id) REFERENCES inventaris_barang(id) ON DELETE CASCADE,
    FOREIGN KEY (software_id) REFERENCES software_lab(id) ON DELETE CASCADE
);

-- ==========================================
-- 5. PEMELIHARAAN & PELANGGARAN
-- ==========================================
CREATE TABLE log_perawatan_lab (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_id BIGINT NOT NULL,
    tanggal_perawatan DATE NOT NULL,
    kegiatan TEXT NOT NULL, -- Contoh: Pembersihan AC, Update OS
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

CREATE TABLE jenis_pelanggaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_pelanggaran VARCHAR(100) NOT NULL,
    poin_penalti INT NOT NULL
);

CREATE TABLE sanksi_pengguna (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    pelanggaran_id INT NOT NULL,
    peminjaman_id BIGINT,
    tanggal_diberikan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (pelanggaran_id) REFERENCES jenis_pelanggaran(id),
    FOREIGN KEY (peminjaman_id) REFERENCES peminjaman(id)
);

-- ==========================================
-- 6. SISTEM INFORMASI & KOMUNIKASI
-- ==========================================
CREATE TABLE pengumuman (
    id INT AUTO_INCREMENT PRIMARY KEY,
    judul VARCHAR(150) NOT NULL,
    konten TEXT NOT NULL,
    tanggal_publikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ulasan_lab (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    peminjaman_id BIGINT UNIQUE NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    komentar TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (peminjaman_id) REFERENCES peminjaman(id) ON DELETE CASCADE
);

CREATE TABLE konfigurasi_sistem (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kunci_pengaturan VARCHAR(50) UNIQUE NOT NULL, -- Contoh: MAX_DURASI_PINJAM
    nilai_pengaturan VARCHAR(100) NOT NULL
);