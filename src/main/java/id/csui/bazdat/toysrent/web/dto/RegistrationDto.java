package id.csui.bazdat.toysrent.web.dto;

import id.csui.bazdat.toysrent.model.Address;
import id.csui.bazdat.toysrent.model.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class RegistrationDto {

    private String dob;
    private User user;
    private Address address;

}
