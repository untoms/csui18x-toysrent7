package id.csui.bazdat.toysrent.repository;

import org.hibernate.query.criteria.internal.CriteriaBuilderImpl;

import javax.persistence.criteria.CriteriaBuilder;
import java.util.Map;

public class SearchBuilder {

    private String query;
    private Object[] args;
    private Map<String,String> fields;

    public SearchBuilder(String query, Object[] args, Map<String, String> fields) {
        this.query = query;
        this.args = args;
        this.fields = fields;
    }

    public enum OPERATOR {
        EQ("="),
        LT("<"),
        LTE("<="),
        GT(">"),
        GTE(">=");

        private String name;

        OPERATOR(String name) {
            this.name = name;
        }
    }

    public enum OrderDirection{

        ASC,
        DESC;

    }
}
