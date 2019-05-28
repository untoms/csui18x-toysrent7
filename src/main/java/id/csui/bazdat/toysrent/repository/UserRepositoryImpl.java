package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.mapper.UserRowMapper;
import id.csui.bazdat.toysrent.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class UserRepositoryImpl implements UserRepository{

    private final NamedParameterJdbcTemplate template;

    @Autowired
    public UserRepositoryImpl(NamedParameterJdbcTemplate template) {
        this.template = template;
    }

    @Override
    public User getUerByUserName(String userName) {

        SqlParameterSource params = new MapSqlParameterSource().addValue("username", userName);

        User user = template.queryForObject("select \n" +
                "p.*, \n" +
                "COALESCE(ag.poin,-1) as poin,\n" +
                "ag.level,\n" +
                "CASE WHEN a.no_ktp IS NULL \n" +
                "            THEN 0 \n" +
                "            ELSE 1 \n" +
                "    END AS is_admin \n" +
                "from pengguna p \n" +
                "left join \"admin\" a on p.no_ktp=a.no_ktp \n" +
                "LEFT JOIN anggota ag on p.no_ktp=ag.no_ktp " +
                "where p.email = :username ", params ,new UserRowMapper());
        return user;
    }

}
