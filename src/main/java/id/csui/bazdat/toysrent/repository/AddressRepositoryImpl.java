package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.mapper.AddressRowMapper;
import id.csui.bazdat.toysrent.model.Address;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.sql.Types;

@Repository
public class AddressRepositoryImpl implements AddressRepository {

    private final String Q_InsertAddress = "INSERT INTO alamat ( jalan, kodepos, kota, nama, no_ktp_anggota, nomor) VALUES ( :street, :postal_code, :city, :name, :no_ktp, :no )";
    private final String Q_FetchAddress = "SELECT jalan, kodepos, kota, nama, no_ktp_anggota, nomor from alamat where nama = :name and no_ktp_anggota = :no_ktp";

    private final NamedParameterJdbcTemplate template;

    @Autowired
    public AddressRepositoryImpl(NamedParameterJdbcTemplate template) {
        this.template = template;
    }

    @Override
    public Address save(Address address) {

        SqlParameterSource paramsAddr = new MapSqlParameterSource()
                .addValue("street", address.getStreet())
                .addValue("postal_code", address.getPostalCode())
                .addValue("city", address.getCity())
                .addValue("name", address.getName())
                .addValue("no_ktp", address.getNoKtp())
                .addValue("no", address.getNo(), Types.INTEGER);

        template.update(Q_InsertAddress, paramsAddr);

        Address addr = getById(address.getName(), address.getNoKtp());

        return addr;
    }

    @Override
    public Address getById(String name, String noKtp) {

        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("name", name)
                .addValue("no_ktp", noKtp);

        Address addr = template.queryForObject(Q_FetchAddress, params, new AddressRowMapper());

        return addr;
    }
}
