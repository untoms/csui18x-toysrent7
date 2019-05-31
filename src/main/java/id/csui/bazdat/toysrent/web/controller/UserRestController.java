package id.csui.bazdat.toysrent.web.controller;

import id.csui.bazdat.toysrent.service.RegistrationService;
import id.csui.bazdat.toysrent.web.dto.RegistrationDto;
import id.csui.bazdat.toysrent.web.dto.ServiceResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.text.ParseException;
import java.text.SimpleDateFormat;

@RestController
public class UserRestController {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());


    private final RegistrationService registrationService;

    @Autowired
    public UserRestController(RegistrationService registrationService) {
        this.registrationService = registrationService;
    }

    @PostMapping("/register")
    public ResponseEntity<Object> registration(@RequestBody RegistrationDto regisData){

        RegistrationDto result = new RegistrationDto();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        try {
            if (regisData.getDob() != null && !regisData.getDob().trim().isEmpty())
                regisData.getUser().setDob(sdf.parse(regisData.getDob()));


            registrationService.register(regisData.getUser(), regisData.getAddress());
        } catch (ParseException e) {
            logger.error("ParseException Error parsing date", e);
            ServiceResponse<String> response = new ServiceResponse<>("error", "Tanggal lahir tidak valid");
            return new ResponseEntity<Object>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }catch (Exception e){
            logger.error("Error parsing date", e);
            ServiceResponse<String> response = new ServiceResponse<>("error", e.getMessage());
            return new ResponseEntity<Object>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }

        ServiceResponse<RegistrationDto> response = new ServiceResponse<>("success", result);
        return new ResponseEntity<Object>(response, HttpStatus.OK);
    }


}
