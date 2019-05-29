package id.csui.bazdat.toysrent.mapper;

import id.csui.bazdat.toysrent.model.Address;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

public class AddressRowMapper  implements RowMapper<Address> {
    @Override
    public Address mapRow(ResultSet rs, int i) throws SQLException {

        Address address = new Address().builder()
                .city(rs.getString("kota"))
                .name(rs.getString("nama"))
                .no(rs.getInt("nomor"))
                .noKtp(rs.getString("no_ktp_anggota"))
                .postalCode(rs.getString("kodepos"))
                .street(rs.getString("jalan"))
                .build();
        return address;
    }
}
