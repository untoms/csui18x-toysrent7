package id.csui.bazdat.toysrent.web.controller;

import id.csui.bazdat.toysrent.model.Barang;
import id.csui.bazdat.toysrent.repository.BarangRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.servlet.ModelAndView;

import javax.validation.Valid;

@Controller("barang")
public class BarangController {

    private final BarangRepository barangRepository;

    @Autowired
    public BarangController(BarangRepository barangRepository) {
        this.barangRepository = barangRepository;
    }

    @GetMapping("list")
    public String showList(
            @PageableDefault(size = 10) Pageable pageable,
            @RequestParam(name = "value", required = false) String value,
            Model model){

        if (value != null) {
            model.addAttribute("key", value);
            model.addAttribute("barangList", barangRepository.findByKondisi(value, pageable));
        } else {
            model.addAttribute("barangList", barangRepository.findAll(pageable));
        }

        return "barang/list";
    }

    @GetMapping(value = "form")
    public void showForm(
            @RequestParam (required = false, name = "id") Barang barang,
            ModelMap modelMap){

        if(barang != null )
            modelMap.addAttribute("barang",barang);
        else
            modelMap.addAttribute("barang", new Barang());
    }

    @PostMapping(value = "form")
    public String processForm(@ModelAttribute @Valid Barang barang, BindingResult hasilValidasi){
        if(hasilValidasi.hasErrors()){
            return "barang/form";
        }
        barangRepository.save(barang);
        return "redirect:list";
    }

    @GetMapping(value = "delete")
    public ModelMap deleteConfirm(@RequestParam(value = "id", required = true) Barang barang) {

        return new ModelMap("barang", barang);
    }

    @PostMapping(value = "delete")
    public Object doDeletion(@ModelAttribute Barang barang, SessionStatus status) {
        try{
            barangRepository.delete(barang);
        } catch (DataIntegrityViolationException exception) {
            status.setComplete();
            return new ModelAndView("error/errorDelete")
                    .addObject("entityId", barang.getIdBarang())
                    .addObject("entityName", "Barang")
                    .addObject("errorCause", exception.getRootCause().getMessage())
                    .addObject("backLink","barang/list");
        }
        status.setComplete();
        return "redirect:barang/list";
    }
}
