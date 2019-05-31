package id.csui.bazdat.toysrent.mapper;

import id.csui.bazdat.toysrent.model.User;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

public class UserRowMapper implements RowMapper<User> {

    @Override
    public User mapRow(ResultSet rs, int i) throws SQLException {

        User user = new User(
                rs.getString("no_ktp"),
                rs.getString("email"),
                rs.getString("nama_lengkap"),
                rs.getString("no_telp"),
                rs.getDate("tanggal_lahir"),
                rs.getString("level"),
                rs.getFloat("poin"),
                rs.getBoolean("is_admin"));

        return user;
    }
}
