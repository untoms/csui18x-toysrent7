package id.csui.bazdat.toysrent.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Category {

    private String categoryName;
    private String categoryLevel;
    private String categoryParentId;
}
