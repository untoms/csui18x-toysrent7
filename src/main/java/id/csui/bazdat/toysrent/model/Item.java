package id.csui.bazdat.toysrent.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Item {

    private String name;
    private String material;
    private String description;
    private Integer ageMin;
    private Integer ageMax;
    private Set<Category> categories;

    public void addCategory(Category c){

        if ( c == null )
            return;

        if (categories == null)
            categories = new HashSet<>();

        categories.add(c);

    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Item)) return false;
        Item item = (Item) o;
        return Objects.equals(name, item.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}
