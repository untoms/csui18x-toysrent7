package id.csui.bazdat.toysrent.web.controller;

import id.csui.bazdat.toysrent.model.Category;
import id.csui.bazdat.toysrent.model.Item;
import id.csui.bazdat.toysrent.repository.ItemRepository;
import id.csui.bazdat.toysrent.repository.ItemRepositoryImpl;
import id.csui.bazdat.toysrent.repository.SearchBuilder;
import id.csui.bazdat.toysrent.web.dto.ServiceResponsePaging;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class ItemRestController {

    private final ItemRepository itemRepository;

    @Autowired
    public ItemRestController(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    @GetMapping("/item/list-data")
    public ResponseEntity<Object> fetchItems(HttpServletRequest request){

//        @RequestParam (name = "iDisplayLength", required = false, defaultValue = "25") int limit,
//        @RequestParam (name = "iDisplayStart", required = false, defaultValue = "0") int offset,
//        @RequestParam (name = "item_name", required = false) String itemName,
//        @RequestParam (name = "category_name", required = false) String categoryName,
//        @RequestParam (name = "order_by", required = false) String order,
//        @RequestParam (name = "order_direction", required = false) String orderDirection

        String limistStr = request.getParameter("iDisplayLength");
        String offsetStr = request.getParameter("iDisplayStart");
        String itemName = request.getParameter("item_name");
        String categoryName = request.getParameter("category_name");
        String order = request.getParameter("mDataProp_"+request.getParameter("iSortCol_0"));
        String orderDirection = request.getParameter("sSortDir_0");

        Map<String, String> filterFields = new HashMap<>();

//        if (!itemName.trim().isEmpty())
//            filterFields.put(ItemRepositoryImpl.KEY_I_NAME, itemName);
//
//        if (!categoryName.trim().isEmpty())
//            filterFields.put(ItemRepositoryImpl.KEY_I_NAME, categoryName);
//        int[] limitParam = {Integer.valueOf(limistStr), Integer.valueOf(offsetStr)};

        List<Item> items = itemRepository.getItems(filterFields, null, null,null);
        int total = items.size();

        ServiceResponsePaging<List<Item>> response = new ServiceResponsePaging<>("success",items, total);
        return new ResponseEntity<Object>(response, HttpStatus.OK);

    }

    @GetMapping("/item/categories")
    public ResponseEntity<Object> fetchCategories(){

        List<Category> categories = itemRepository.getCategories();

        ServiceResponsePaging<List<Category>> response = new ServiceResponsePaging<>("success",categories, categories.size());
        return new ResponseEntity<Object>(response, HttpStatus.OK);
    }
}
