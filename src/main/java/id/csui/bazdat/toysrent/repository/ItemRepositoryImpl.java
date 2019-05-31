package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.model.Category;
import id.csui.bazdat.toysrent.model.Item;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.*;

@Repository
public class ItemRepositoryImpl implements ItemRepository {

    private final String Q_ITEM_SELECT_COUNT = "select count(1) ";

    private final String Q_ITEM_SELECT_ALL = "select " +
            "i.nama AS name, " +
            "i.bahan AS material, " +
            "i.deskripsi AS description, " +
            "i.usia_dari AS ageMin, " +
            "i.usia_sampai AS ageMax, " +
            "k.nama AS category_name, " +
            "k.level AS category_level, " +
            "k.sub_dari AS category_parent_id ";

    private final String Q_ITEM_SELECT_JOIN = "from item i " +
            "JOIN kategori_item ki on i.nama=ki.nama_item " +
            "JOIN kategori k on ki.nama_kategori=k.nama ";

    private final String Q_CATEGORY_SELECT_ALL = "SELECT level as category_level, nama as category_name, sub_dari as category_parent_id FROM kategori";

    private final String Q_INSERT_ITEM = "INSERT INTO item ( nama, bahan, deskripsi, usia_dari, usia_sampai) VALUES ( :name, :material, :desc, :age_min, :age_max)";
    private final String Q_UPDATE_ITEM = "UPDATE item SET bahan= :material, deskripsi=:desc, usia_dari= :age_min, usia_sampai= :age_max where nama = :name";
    private final String Q_INSERT_ITEM_CATEGORY = "INSERT INTO kategori_item ( nama_item, nama_kategori) VALUES ( :item, :category)";
    private final String Q_DELETE_ITEM_CATEGORY = "DELETE FROM kategori_item where nama_item= :item AND nama_kategori= :category";
    private final String Q_DELETE_ITEM = "DELETE FROM item where nama= :name";

    public static final String KEY_I_NAME = "I_NAME";
    public static final String KEY_C_NAME = "C_NAME";

    private static final Map<String, String> criteriaFields;
    static {
        Map<String, String> aMap = new HashMap<>();
        aMap.put(KEY_I_NAME, "i.nama");
        aMap.put(KEY_C_NAME, "c.nama");
        criteriaFields = Collections.unmodifiableMap(aMap);
    }

    public final static RowMapper<Item> itemMapper = BeanPropertyRowMapper.newInstance(Item.class);
    public final static RowMapper<Category> categoryMapper = BeanPropertyRowMapper.newInstance(Category.class);

    private final NamedParameterJdbcTemplate template;

    @Autowired
    public ItemRepositoryImpl(NamedParameterJdbcTemplate template) {
        this.template = template;
    }

    @Override
    public int countItems(Map<String, String> filterField) {

        SqlParameterSource params = new MapSqlParameterSource().addValues(filterField);

        String sql = Q_ITEM_SELECT_COUNT+Q_ITEM_SELECT_JOIN+createCriteriaQuery(filterField, null, null, null);

        return template.queryForObject(sql, params, Integer.class);
    }

    @Override
    public List<Item> getItems(Map<String, String> filterField, String orderField, SearchBuilder.OrderDirection direction, int[] limit) {

        SqlParameterSource params = new MapSqlParameterSource().addValues(filterField);

        String sql = Q_ITEM_SELECT_ALL+Q_ITEM_SELECT_JOIN+createCriteriaQuery(filterField, orderField, direction, limit);

        return template.query(sql, params, new ResultSetExtractor<List<Item>>() {
            @Override
            public List<Item> extractData(ResultSet rs) throws SQLException, DataAccessException {
                Set<Item> items = new HashSet<>();

                String itemName = null;
                Item currentItem = null;
                int itemIdx = 0;
                int idx = 0;

                while (rs.next()){
                    // first row or when item changes
                    if (currentItem == null || !itemName.equals(rs.getString("name"))){
                        itemName = rs.getString("name");
                        currentItem = itemMapper.mapRow(rs, itemIdx++);
                        idx = 0;
                        items.add(currentItem);
                    }
                    currentItem.addCategory(categoryMapper.mapRow(rs,idx++));
                }

                return new ArrayList<>(items);

            }
        });
    }

    @Override
    public List<Category> getCategories() {

        return template.query(Q_CATEGORY_SELECT_ALL, categoryMapper);
    }

    @Override
    @Transactional
    public Item save(Item item) {

        SqlParameterSource paramsItem = new MapSqlParameterSource()
                .addValue("name", item.getName())
                .addValue("material", item.getMaterial())
                .addValue("desc", item.getDescription())
                .addValue("age_min", item.getAgeMin())
                .addValue("age_max", item.getAgeMax());

        int result = template.update(Q_INSERT_ITEM, paramsItem);

        item.getCategoryIds().forEach( c -> {
            SqlParameterSource paramsCateg = new MapSqlParameterSource()
                    .addValue("item", item.getName())
                    .addValue("category", c);
            template.update(Q_INSERT_ITEM_CATEGORY,paramsCateg);
        });

        return getByName(item.getName());
    }

    @Override
    @Transactional
    public Item update(Item item) {

        Item oldItem = getByName(item.getName());
        oldItem.getCategories().forEach( c -> {
            SqlParameterSource paramsCateg = new MapSqlParameterSource()
                    .addValue("item", oldItem.getName())
                    .addValue("category", c.getCategoryName());
            template.update(Q_DELETE_ITEM_CATEGORY,paramsCateg);
        });

        SqlParameterSource paramsItem = new MapSqlParameterSource()
                .addValue("name", item.getName())
                .addValue("material", item.getMaterial())
                .addValue("desc", item.getDescription())
                .addValue("age_min", item.getAgeMin())
                .addValue("age_max", item.getAgeMax());

        int result = template.update(Q_UPDATE_ITEM, paramsItem);

        item.getCategoryIds().forEach( c -> {
            SqlParameterSource paramsCateg = new MapSqlParameterSource()
                    .addValue("item", item.getName())
                    .addValue("category", c);
            template.update(Q_INSERT_ITEM_CATEGORY,paramsCateg);
        });

        return getByName(item.getName());
    }

    @Override
    @Transactional
    public void delete(String name) {

        Item oldItem = getByName(name);
        oldItem.getCategories().forEach( c -> {
            SqlParameterSource paramsCateg = new MapSqlParameterSource()
                    .addValue("item", oldItem.getName())
                    .addValue("category", c.getCategoryName());
            template.update(Q_DELETE_ITEM_CATEGORY,paramsCateg);
        });

        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("name", name);

        template.update(Q_DELETE_ITEM,params);

    }

    @Override
    public Item getByName(String name) {
        Map<String, String> param = new HashMap<>();
        param.put(KEY_I_NAME, name);
        List<Item> result = getItems(param, null, null, null);

        if (result == null || result.isEmpty())
            return null;
        return result.get(0);
    }

    private String createCriteriaQuery(Map<String, String> filterField, String orderField, SearchBuilder.OrderDirection direction, int[] limit){
        StringBuilder criteria = new StringBuilder();
        String andQuery = " AND ";

        if (!filterField.isEmpty()){

            criteria.append("WHERE ");
            filterField.forEach((k,v)->{
                criteria.append(criteriaFields.get(k)+"= :"+k);
                criteria.append(andQuery);
            });

            criteria.delete(criteria.length()-andQuery.length(),criteria.length());

        }

        if (orderField != null)
            criteria.append(" ORDER BY "+criteriaFields.get(orderField)+" "+direction);

        if (limit != null){
            if (limit.length == 2){
                criteria.append(" LIMIT "+limit[0]+" OFFSET "+limit[1]);
            }

            if(limit.length == 1){
                criteria.append(" LIMIT "+limit[0]);
            }
        }

        return criteria.toString();
    }

    public static void main(String[] args) {
        ItemRepositoryImpl item = new ItemRepositoryImpl(null);

        Map<String, String> map = new HashMap<>();
        map.put(KEY_I_NAME,"item");
        map.put(KEY_C_NAME,"categ");
        String crit = item.createCriteriaQuery(map, KEY_C_NAME, SearchBuilder.OrderDirection.ASC,null);
        System.out.println(crit);
    }
}
