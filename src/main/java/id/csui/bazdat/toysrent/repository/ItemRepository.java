package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.model.Category;
import id.csui.bazdat.toysrent.model.Item;

import java.util.List;
import java.util.Map;

public interface ItemRepository {

    int countItems(Map<String, String> filterField);

    List<Item> getItems(Map<String, String> filterField, String orderField, SearchBuilder.OrderDirection direction, int[] limit);

    List<Category> getCategories();

    Item save(Item item);

    Item update(Item item);

    void delete(String name);

    Item getByName(String name);
}
