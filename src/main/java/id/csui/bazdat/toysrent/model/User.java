package id.csui.bazdat.toysrent.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;

import java.io.Serializable;
import java.util.Date;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@JsonIgnoreProperties(ignoreUnknown = true)
public class User implements Serializable {

    private String noKtp;
    private String email;
    private String fullName;
    private String phone;
    private Date dob;

    //member attr
    private String level;
    private Float point;

    private Boolean isAdmin;

    public Boolean isAdmin(){
        return isAdmin;
    }

}

