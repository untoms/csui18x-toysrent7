package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.model.Barang;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.PagingAndSortingRepository;

public interface BarangRepository extends PagingAndSortingRepository<Barang, Long> {

    Page<Barang> findByKondisi(String kondisi, Pageable pageable);

}
