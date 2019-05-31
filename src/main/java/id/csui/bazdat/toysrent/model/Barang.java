package id.csui.bazdat.toysrent.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Data
@Builder
@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "barang")
public class Barang {

    @Id
    @Column(name = "id_barang")
    private String idBarang;

    @Column(name = "kodisi")
    private String kondisi;

    @Column(name = "lama_penggunaan")
    private Integer lamaPenggunaan;

    @Column(name = "nama_item")
    private String namaItem;

    @Column(name = "no_ktp_penyewa")
    private String noKtpPenyewa;

    @Column(name = "url_foto")
    private String urlPhoto;

    @Column(name = "warna")
    private String warna;

    private Item item;
    private User penyewa;

}
