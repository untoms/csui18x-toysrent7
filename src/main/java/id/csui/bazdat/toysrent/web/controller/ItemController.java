package id.csui.bazdat.toysrent.web.controller;

import id.csui.bazdat.toysrent.model.Category;
import id.csui.bazdat.toysrent.model.Item;
import id.csui.bazdat.toysrent.repository.ItemRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.ModelAndView;

import javax.validation.Valid;

@Controller
public class ItemController {

    private Logger logger = LoggerFactory.getLogger(ItemController.class);

    private final ItemRepository itemRepository;

    @Autowired
    public ItemController(ItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    @ModelAttribute("categories")
    public Iterable<Category> categories(){
        return itemRepository.getCategories();
    }

    @PostMapping("item/form")
    public String submitForm( @ModelAttribute @Valid Item item, BindingResult errors){

        if(errors.hasErrors()) {
            logger.error("submitForm" +errors.getAllErrors());
            return "item/form";
        }

        Item oldItem = itemRepository.getByName(item.getName());

        if(oldItem == null )
            itemRepository.save(item);
        else
            itemRepository.update(item);
        return "redirect:list";

    }

    @GetMapping("/item/list")
    public String itemslist(){

        return "/item/list";
    }

    @GetMapping("item/form")
    public void showForm(
            @RequestParam(required = false, name = "name") String itemName,
            @RequestParam(required = false, name = "item")Item item, ModelMap modelMap){

        logger.debug("show form itemname = "+itemName);

        if (itemName != null && !itemName.trim().isEmpty()) {

            item = itemRepository.getByName(itemName);

            logger.debug("show form item = "+item);

            modelMap.addAttribute("item", item);
        }

        if(item != null)
            modelMap.addAttribute("item",item);
        else
            modelMap.addAttribute("item",new Item());
    }

    @GetMapping("item/delete")
    public void showDetailsForm(
            @RequestParam(name = "name") String itemName,
            @RequestParam(required = false, name = "item")Item item, ModelMap modelMap){

        logger.debug("show form itemname = "+itemName);

        if (itemName != null && !itemName.trim().isEmpty()) {

            item = itemRepository.getByName(itemName);

            logger.debug("show form item = "+item);

            modelMap.addAttribute("item", item);
        }

        if(item != null)
            modelMap.addAttribute("item",item);
        else
            modelMap.addAttribute("item",new Item());
    }

    @PostMapping("item/delete")
    public Object doDeletion(@ModelAttribute Item item, SessionStatus status) {
        try{

            itemRepository.delete(item.getName());
        } catch (DataIntegrityViolationException exception) {
            status.setComplete();
            return new ModelAndView("error/errorDelete")
                    .addObject("entityId", item.getName())
                    .addObject("entityName", "item")
                    .addObject("errorCause", exception.getRootCause().getMessage())
                    .addObject("backLink","/item/list");
        }
        status.setComplete();
        return "redirect:/item/list";
    }
}
