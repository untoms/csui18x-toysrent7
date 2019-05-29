package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.mapper.UserRowMapper;
import id.csui.bazdat.toysrent.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Types;

@Repository
public class UserRepositoryImpl implements UserRepository{

    private final String Q_GetUserByEmail = "select " +
            "p.*," +
            "COALESCE(ag.poin,-1) as poin," +
            "ag.level," +
            "CASE WHEN a.no_ktp IS NULL " +
            "            THEN 0 " +
            "            ELSE 1 " +
            "    END AS is_admin " +
            "from pengguna p " +
            "left join \"admin\" a on p.no_ktp=a.no_ktp " +
            "LEFT JOIN anggota ag on p.no_ktp=ag.no_ktp " +
            "where p.email = :username ";

    private final String Q_InsertUser = "INSERT INTO pengguna ( email, nama_lengkap, no_ktp, no_telp, tanggal_lahir) VALUES ( :email, :name, :ktp, :phone, :dob )";
    private final String Q_InsertAdmin = "INSERT INTO admin VALUES ( :ktp )";
    private final String Q_InsertMember = "INSERT INTO anggota ( level, no_ktp, poin) VALUES ( :level, :ktp, :point );";

    private final NamedParameterJdbcTemplate template;

    @Autowired
    public UserRepositoryImpl(NamedParameterJdbcTemplate template) {
        this.template = template;
    }

    @Override
    public User getUerByUserName(String userName) {

        SqlParameterSource params = new MapSqlParameterSource().addValue("username", userName);

        User user = template.queryForObject(Q_GetUserByEmail, params ,new UserRowMapper());
        return user;
    }

    @Override
    @Transactional
    public User save(User user) {

        SqlParameterSource paramsUser = new MapSqlParameterSource()
                .addValue("email", user.getEmail())
                .addValue("name", user.getFullName())
                .addValue("ktp", user.getNoKtp())
                .addValue("phone", user.getPhone())
                .addValue("dob", user.getDob(), Types.DATE);

        template.update(Q_InsertUser, paramsUser);

        if (user.isAdmin()){

            SqlParameterSource paramsAdmin = new MapSqlParameterSource().addValue("ktp", user.getNoKtp());

            template.update(Q_InsertAdmin, paramsAdmin);

        } else {

            SqlParameterSource paramsMember = new MapSqlParameterSource()
                    .addValue("level", user.getLevel())
                    .addValue("ktp", user.getNoKtp())
                    .addValue("point", user.getPoint());

            template.update(Q_InsertMember, paramsMember);
        }

        SqlParameterSource params = new MapSqlParameterSource().addValue("username", user.getEmail());
        return template.queryForObject(Q_GetUserByEmail, params,new UserRowMapper());
    }
}
