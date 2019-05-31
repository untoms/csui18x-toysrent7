package id.csui.bazdat.toysrent.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class Dummy {

    @GetMapping("/dashboard")
    public String dashboard(){

        return "/dashboard";
    }

}
