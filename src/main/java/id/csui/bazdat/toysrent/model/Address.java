package id.csui.bazdat.toysrent.model;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;

import java.io.Serializable;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@JsonIgnoreProperties(ignoreUnknown = true)
public class Address implements Serializable {

    private String name;
    private String noKtp;
    private String street;
    private String postalCode;
    private String city;
    private Integer no;

}
