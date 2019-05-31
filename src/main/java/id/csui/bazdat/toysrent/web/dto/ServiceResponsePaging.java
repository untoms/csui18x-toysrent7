package id.csui.bazdat.toysrent.web.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class ServiceResponsePaging<T>{

    private String status;
    private T data;
    private int total;
}
