package id.csui.bazdat.toysrent.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class Dummy {

    @GetMapping("/login")
    public String login(){

        return "login";
    }

    @GetMapping("/register")
    public String register(){

        return "/register";
    }

    @GetMapping("/dashboard")
    public String dashboard(){

        return "/dashboard";
    }

    @GetMapping("/item/list")
    public String itemslist(){

        return "/item/list";
    }

    @GetMapping("/item/form")
    public String itemsForm(){

        return "/item/form";
    }
}